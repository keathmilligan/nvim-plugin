-- nvim-plugin sidebar: Educational example of a custom sidebar panel
-- This module demonstrates the battle-tested pattern used by professional
-- Neovim plugins like nvim-tree, neo-tree, aerial, and symbols-outline.
--
-- A sidebar is a persistent, application-like UI panel that:
-- - Lives in a dedicated vertical split window
-- - Has completely custom keybindings isolated from normal editing
-- - Cannot be accidentally edited like a regular buffer
-- - Behaves like a true UI component, not a text file
--
-- This example teaches critical plugin development patterns:
-- - Advanced buffer configuration (buftype, bufhidden, modifiable, readonly)
-- - Window management and positioning
-- - Custom keybinding isolation (preventing normal mode commands)
-- - State management (tracking buffer/window handles)
-- - Toggle/open/close patterns

-- ============================================================================
-- Module Pattern
-- ============================================================================
local M = {}

-- ============================================================================
-- State Management
-- ============================================================================
-- The sidebar maintains minimal state to track its buffer and window handles.
-- This allows us to reuse the same buffer across multiple open/close cycles
-- and detect whether the sidebar is currently open.

-- Buffer handle for the sidebar (number or nil)
-- We reuse this buffer across open/close cycles for efficiency
local sidebar_buf = nil

-- Window handle for the sidebar (number or nil)
-- This is set when the sidebar is open and nil when closed
local sidebar_win = nil

-- Namespace for highlights and extmarks
-- Used for syntax highlighting and visual enhancements
local ns = vim.api.nvim_create_namespace("nvim_plugin_sidebar")

-- ============================================================================
-- Private Helper Functions
-- ============================================================================

-- Forward declarations for functions that need to reference each other
local render

-- Create or reuse the sidebar buffer
-- This function ensures we have a valid buffer configured for sidebar use.
-- If the buffer already exists and is valid, we reuse it for efficiency.
-- Otherwise, we create a new buffer with all the options needed to make it
-- behave like an application panel rather than an editable file.
--
-- IMPORTANT: Buffer Options Explained
-- ------------------------------------
-- buftype = "nofile"    : Not associated with a file on disk. This prevents
--                         Neovim from trying to read/write file content.
--                         Perfect for UI panels that display generated content.
--
-- buflisted = false     : Don't show in buffer list (:ls). Sidebars aren't
--                         "documents" that users edit, so hiding them reduces
--                         clutter in buffer navigation.
--
-- bufhidden = "wipe"    : Delete the buffer when it's hidden. This keeps memory
--                         usage low and ensures the buffer is cleaned up when
--                         the sidebar window closes.
--
-- swapfile = false      : No swap file. Swap files are for crash recovery of
--                         edited files. Our sidebar content is generated on
--                         demand, so there's nothing to recover.
--
-- modifiable = false    : Prevent editing. The buffer starts as modifiable so
--                         we can set initial content. The render() function
--                         will set this to false after populating content.
--
-- readonly = true       : Additional protection against editing. Works in
--                         combination with modifiable = false. Also set by
--                         render() after initial content is loaded.
--
-- filetype = "nvim-plugin-sidebar" : Custom filetype. This allows users to
--                         create custom syntax highlighting or define sidebar-
--                         specific autocommands if they want.
--
-- Returns: buffer handle (number)
local function create_or_get_buffer()
  -- Check if we already have a valid buffer
  if sidebar_buf and vim.api.nvim_buf_is_valid(sidebar_buf) then
    return sidebar_buf
  end
  
  -- Create a new buffer
  -- vim.api.nvim_create_buf(listed, scratch)
  -- - listed: false = don't show in buffer list
  -- - scratch: true = buffer is temporary (gets deleted when hidden)
  sidebar_buf = vim.api.nvim_create_buf(false, true)
  
  -- Set buffer name using URI-style naming convention
  -- The "nvim-plugin://" prefix is a convention used by many plugins
  -- to distinguish special buffers from regular files
  vim.api.nvim_buf_set_name(sidebar_buf, "nvim-plugin://sidebar")
  
  -- Configure buffer options to make it behave like a UI panel
  -- We use vim.bo[buffer] syntax which is cleaner than vim.api.nvim_buf_set_option()
  vim.bo[sidebar_buf].buftype = "nofile"
  vim.bo[sidebar_buf].bufhidden = "wipe"
  vim.bo[sidebar_buf].swapfile = false
  vim.bo[sidebar_buf].buflisted = false
  vim.bo[sidebar_buf].filetype = "nvim-plugin-sidebar"
  
  -- Note: We don't set modifiable=false or readonly=true here
  -- The buffer starts as modifiable so we can set initial content
  -- The render() function will set it to read-only after populating content
  
  return sidebar_buf
end

-- Create and configure the sidebar window
-- This function creates a vertical split window and configures it to look
-- and behave like a sidebar panel (like nvim-tree, aerial, etc.).
--
-- IMPORTANT: Window Options Explained
-- -------------------------------------
-- number = false           : No line numbers. Sidebars display UI content,
--                            not line-by-line editable text.
--
-- relativenumber = false   : No relative line numbers. Same reason as above.
--
-- spell = false            : No spell checking. We're not editing prose.
--
-- signcolumn = "no"        : No sign column (used by LSP, git signs, etc.).
--                            Keeps the sidebar clean and UI-focused.
--
-- foldcolumn = "0"         : No fold column. We don't need code folding in
--                            a UI panel.
--
-- winfixwidth = true       : CRITICAL! Prevents the window from resizing when
--                            user executes <C-w>= (equalize window sizes).
--                            This keeps the sidebar at a fixed width.
--
-- sidescrolloff = 0        : No horizontal scroll offset. We disable wrapping
--                            anyway, so this isn't needed.
--
-- scrolloff = 0            : No vertical scroll offset. For UI panels, we
--                            want precise control over what's visible.
--
-- cursorline = true        : Highlight the current line. This is a nice UX
--                            touch that helps users see where they are.
--
-- wrap = false             : No line wrapping. Sidebar content should be
--                            formatted to fit the fixed width.
--
-- Parameters:
--   buf: buffer handle to display in the window
--
-- Returns: window handle (number)
local function create_window(buf)
  -- Create a vertical split
  -- This opens a new window to the left of the current window
  vim.cmd("vsplit")
  
  -- Get the handle for the window we just created
  -- nvim_get_current_win() returns the window ID (a number)
  local win = vim.api.nvim_get_current_win()
  
  -- Set the buffer to display in this window
  -- This connects our specially configured sidebar buffer to the window
  vim.api.nvim_win_set_buf(win, buf)
  
  -- Set window width to 30 columns
  -- This is a typical sidebar width - wide enough to be useful,
  -- narrow enough not to dominate the screen
  vim.api.nvim_win_set_width(win, 30)
  
  -- Configure window options to create a sidebar appearance
  -- We use vim.wo[window] syntax which is the modern Neovim API
  -- These options are window-local (different from buffer options)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].spell = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].winfixwidth = true  -- This is the key option for sidebar behavior
  vim.wo[win].sidescrolloff = 0
  vim.wo[win].scrolloff = 0
  vim.wo[win].cursorline = true   -- Nice UX touch
  vim.wo[win].wrap = false
  
  return win
end

-- Set up sidebar-specific keymaps
-- This function creates buffer-local keymaps for the sidebar and disables
-- normal editing commands. This is CRITICAL for making the sidebar feel like
-- a UI panel rather than an editable buffer.
--
-- The keymap isolation strategy:
-- 1. Map useful sidebar actions (q to close, r to refresh, <CR> for select)
-- 2. Map all insert mode triggers to <Nop> to prevent entering insert mode
-- 3. Map common edit commands to <Nop> to prevent accidental edits
--
-- IMPORTANT: Buffer-local keymaps vs Global keymaps
-- --------------------------------------------------
-- We use buffer-local keymaps (buffer = buf option) so these mappings ONLY
-- apply in the sidebar buffer. This prevents interfering with the user's
-- normal editing keymaps in other buffers.
--
-- The 'nowait = true' option means Neovim won't wait for additional keys
-- after pressing these. This makes the sidebar feel more responsive.
--
-- Parameters:
--   buf: buffer handle to set up keymaps for
local function setup_sidebar_keymaps(buf)
  local opts = { buffer = buf, nowait = true, silent = true }
  
  -- Sidebar action keymaps
  -- q - Close the sidebar (standard convention in Neovim sidebars)
  vim.keymap.set("n", "q", M.close, vim.tbl_extend("force", opts, {
    desc = "Close sidebar"
  }))
  
  -- <CR> (Enter) - Select/action (placeholder for educational purposes)
  -- In a real sidebar, this might jump to a file or expand a tree node
  vim.keymap.set("n", "<CR>", function()
    vim.notify("Sidebar select action (demo)", vim.log.levels.INFO)
  end, vim.tbl_extend("force", opts, {
    desc = "Select item (demo)"
  }))
  
  -- r - Refresh the sidebar content
  vim.keymap.set("n", "r", function()
    render(buf)
    vim.notify("Sidebar refreshed", vim.log.levels.INFO)
  end, vim.tbl_extend("force", opts, {
    desc = "Refresh sidebar"
  }))
  
  -- CRITICAL: Disable insert mode keys
  -- Mapping these to <Nop> prevents users from accidentally entering insert mode
  -- This is essential for making the sidebar feel like a read-only UI panel
  local insert_keys = { "i", "I", "a", "A", "o", "O", "s", "S" }
  for _, key in ipairs(insert_keys) do
    vim.keymap.set("n", key, "<Nop>", opts)
  end
  
  -- CRITICAL: Disable common edit commands
  -- Mapping these to <Nop> prevents users from executing edit operations
  -- Even though the buffer is read-only, these mappings provide extra protection
  -- and make the behavior more predictable (no error messages)
  local edit_keys = { "dd", "yy", "p", "P", "D", "d", "c", "C", "x", "X", "<<", ">>" }
  for _, key in ipairs(edit_keys) do
    vim.keymap.set("n", key, "<Nop>", opts)
  end
end

-- Render sidebar content
-- This function populates the sidebar buffer with formatted content showing
-- plugin keybindings and sidebar commands. It demonstrates how to:
-- - Build content dynamically as an array of strings
-- - Temporarily make a read-only buffer modifiable for updates
-- - Use nvim_buf_set_lines() to update buffer content
-- - Optionally add syntax highlighting with nvim_buf_add_highlight()
--
-- Parameters:
--   buf: buffer handle to render content into
function render(buf)
  -- Build the content lines array
  -- Each string becomes one line in the buffer
  local lines = {
    "  nvim-plugin Sidebar",
    "  ===================",
    "",
    "  Plugin Keybindings:",
    "  <leader>ph  - Show greeting",
    "  <leader>pt  - Toggle state",
    "  <leader>pk  - Show keybindings",
    "  <leader>pa  - Show all keybindings",
    "  <leader>pc  - Show all commands",
    "  <leader>ps  - Toggle sidebar",
    "",
    "  Sidebar Commands:",
    "  q     - Close sidebar",
    "  <CR>  - Select (demo)",
    "  r     - Refresh",
    "",
    "  Note: <leader> is usually",
    "  <Space> in LazyVim",
  }
  
  -- CRITICAL: Temporarily make buffer modifiable
  -- The buffer is configured as read-only (modifiable = false, readonly = true)
  -- to prevent accidental edits. We need to temporarily allow modifications to
  -- update the content, then set it back to read-only.
  -- We must disable readonly BEFORE setting modifiable, otherwise we get a warning.
  vim.bo[buf].readonly = false
  vim.bo[buf].modifiable = true
  
  -- Set the buffer content
  -- vim.api.nvim_buf_set_lines(buffer, start, end, strict_indexing, lines)
  -- - start: 0 = first line
  -- - end: -1 = last line (this replaces ALL content)
  -- - strict_indexing: false = allow out-of-bounds indices
  -- - lines: array of strings, each becomes one line
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Optional: Add syntax highlighting to the header
  -- This demonstrates how to use nvim_buf_add_highlight() for visual polish
  -- vim.api.nvim_buf_add_highlight(buffer, namespace, highlight_group, line, col_start, col_end)
  -- - line: 0-indexed line number (0 = first line)
  -- - col_start: 0 = start of line
  -- - col_end: -1 = end of line
  vim.api.nvim_buf_add_highlight(buf, ns, "Title", 0, 0, -1)  -- Header line
  vim.api.nvim_buf_add_highlight(buf, ns, "Comment", 1, 0, -1)  -- Separator line
  
  -- CRITICAL: Set buffer back to read-only
  -- This ensures users can't accidentally edit the sidebar content
  -- We set both modifiable=false and readonly=true for maximum protection
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
end

-- ============================================================================
-- Public API Functions
-- ============================================================================
-- These functions are exposed to users and other modules.
-- They provide the main interface for controlling the sidebar.

-- Open the sidebar
-- If the sidebar is already open, this just focuses the existing window.
-- Otherwise, it creates the buffer and window and renders content.
function M.open()
  -- Check if sidebar window already exists and is valid
  if sidebar_win and vim.api.nvim_win_is_valid(sidebar_win) then
    -- Window exists, just focus it
    vim.api.nvim_set_current_win(sidebar_win)
    return
  end
  
  -- Create or get the sidebar buffer
  local buf = create_or_get_buffer()
  
  -- Create the sidebar window
  sidebar_win = create_window(buf)
  
  -- Set up buffer-local keymaps for sidebar interactions
  setup_sidebar_keymaps(buf)
  
  -- Render content
  render(buf)
end

-- Close the sidebar
-- If the sidebar is already closed, this does nothing (no error).
function M.close()
  -- Check if sidebar window exists and is valid
  if sidebar_win and vim.api.nvim_win_is_valid(sidebar_win) then
    -- Close the window (true = force close)
    vim.api.nvim_win_close(sidebar_win, true)
    
    -- Clear the window handle
    sidebar_win = nil
  end
end

-- Toggle the sidebar
-- If open, close it. If closed, open it.
function M.toggle()
  -- Check if sidebar window exists and is valid
  if sidebar_win and vim.api.nvim_win_is_valid(sidebar_win) then
    -- Sidebar is open, close it
    M.close()
  else
    -- Sidebar is closed, open it
    M.open()
  end
end

-- ============================================================================
-- Module Export
-- ============================================================================
return M
