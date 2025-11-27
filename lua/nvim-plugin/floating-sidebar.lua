-- nvim-plugin floating sidebar: Educational example of a floating window sidebar panel
-- This module demonstrates an alternative sidebar approach using Neovim's floating window
-- API, providing more direct rendering control via extmarks and virtual text.
--
-- FLOATING WINDOW vs VERTICAL SPLIT SIDEBAR:
-- ==========================================
-- This implementation uses a floating window that overlays the editor, rather than
-- integrating with Neovim's window layout system like the vertical split sidebar does.
--
-- Key differences:
-- - Floating windows: Overlay content, positioned absolutely (relative="editor")
-- - Vertical splits: Integrate with layout, push other windows aside
-- - Floating windows: More control over positioning and rendering (extmarks)
-- - Vertical splits: Better integration with window navigation (<C-w> commands)
--
-- When to use each pattern:
-- - Floating windows: Modal overlays, temporary UI panels, popups
-- - Vertical splits: Persistent sidebars, file explorers, integrated panels
--
-- This example teaches critical plugin development patterns:
-- - Floating window creation and configuration (nvim_open_win)
-- - Extmark-based rendering for complete visual control
-- - Custom keybinding isolation in floating contexts
-- - State management for floating UI components
-- - Comparison with alternative approaches (see sidebar.lua)

-- ============================================================================
-- Module Pattern
-- ============================================================================
local M = {}

-- ============================================================================
-- State Management
-- ============================================================================
-- The floating sidebar maintains minimal state to track its buffer and window handles.
-- This allows us to reuse the same buffer across multiple open/close cycles
-- and detect whether the sidebar is currently open.

-- Namespace for extmarks and virtual text
-- Extmarks are used to add visual enhancements like icons, highlights, and virtual text
-- without modifying the actual buffer content
local ns = vim.api.nvim_create_namespace("nvim_plugin_floating_sidebar")

-- Buffer handle for the floating sidebar (number or nil)
-- We reuse this buffer across open/close cycles for efficiency
local buf = nil

-- Window handle for the floating sidebar (number or nil)
-- This is set when the sidebar is open and nil when closed
local win = nil

-- Floating window configuration
-- This defines the position, size, and appearance of the floating window
-- See Decision 1 in design.md for rationale behind these values
local config = {
  -- Position relative to the entire editor (not just current window)
  relative = "editor",
  
  -- Width: 32 columns (typical sidebar width)
  width = 32,
  
  -- Height: full height minus status/command line
  -- vim.o.lines gives total available lines in Neovim
  -- Subtracting 4 accounts for statusline, command-line, and padding
  height = vim.o.lines - 4,
  
  -- Position at top-left corner (col=0, row=0)
  col = 0,
  row = 0,
  
  -- Anchor point: NorthWest (top-left)
  -- This means col/row specify the top-left corner position
  anchor = "NW",
  
  -- Minimal style: disables standard UI elements (number, signcolumn, etc.)
  style = "minimal",
  
  -- Border: single-line border for visual separation
  border = "single",
  
  -- Z-index: 40 (above normal windows, below command-line)
  -- Higher values appear on top. Command-line is typically 50+
  zindex = 40,
}

-- ============================================================================
-- Private Helper Functions
-- ============================================================================

-- Forward declarations for functions that need to reference each other
local render

-- Create or reuse the floating sidebar buffer
-- This function ensures we have a valid buffer configured for floating sidebar use.
-- If the buffer already exists and is valid, we reuse it for efficiency.
-- Otherwise, we create a new buffer with all the options needed to make it
-- behave like a UI panel rather than an editable file.
--
-- IMPORTANT: Buffer Configuration Strategy (see Decision 3 in design.md)
-- -------------------------------------------------------------------------
-- We use the same buffer configuration as the vertical split sidebar for consistency.
-- This helps students compare the two implementations and see shared patterns.
--
-- buftype = "nofile"    : Not associated with a file on disk
-- bufhidden = "wipe"    : Delete buffer when hidden (keeps memory usage low)
-- swapfile = false      : No swap file needed (content is generated on demand)
-- modifiable = false    : Prevent editing (set by render() after populating content)
--
-- Returns: buffer handle (number)
local function create_or_get_buffer()
  -- Check if we already have a valid buffer
  if buf and vim.api.nvim_buf_is_valid(buf) then
    return buf
  end
  
  -- Create a new scratch buffer
  -- vim.api.nvim_create_buf(listed, scratch)
  -- - listed: false = don't show in buffer list
  -- - scratch: true = buffer is temporary
  buf = vim.api.nvim_create_buf(false, true)
  
  -- Set buffer name using a distinctive naming convention
  -- Using == delimiters to distinguish from regular buffers
  vim.api.nvim_buf_set_name(buf, "==NVIM-PLUGIN-FLOATING-SIDEBAR==")
  
  -- Configure buffer options to make it behave like a UI panel
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  
  -- Note: We don't set modifiable=false here
  -- The buffer starts as modifiable so we can set initial content
  -- The render() function will set it to read-only after populating content
  
  return buf
end

-- Create and configure the floating sidebar window
-- This function creates a floating window using nvim_open_win() and configures
-- window-local options to make it behave like a UI panel.
--
-- IMPORTANT: Floating Window Configuration (see Decision 1 in design.md)
-- -----------------------------------------------------------------------
-- Floating windows are created with nvim_open_win() which takes a buffer handle,
-- a boolean indicating whether to enter the window, and a configuration table.
--
-- Key configuration options:
-- - relative: "editor" = position relative to entire Neovim instance
-- - width/height: fixed dimensions in columns/lines
-- - col/row: position in screen coordinates
-- - anchor: which corner of the window col/row refers to
-- - style: "minimal" = disable standard UI elements
-- - border: border style (none, single, double, rounded, etc.)
-- - zindex: stacking order (higher values appear on top)
--
-- Window-local options (set via vim.wo[win]):
-- - number, relativenumber, spell, signcolumn, foldcolumn: disabled for clean UI
-- - cursorline: enabled for better UX (highlight current line)
-- - winhighlight: optional custom highlighting
--
-- Parameters:
--   buffer: buffer handle to display in the window
--
-- Returns: window handle (number)
local function create_window(buffer)
  -- Create floating window with our configuration
  -- nvim_open_win(buffer, enter, config)
  -- - buffer: the buffer to display
  -- - enter: true = focus the window immediately
  -- - config: table with position/size/style options
  local floating_win = vim.api.nvim_open_win(buffer, true, config)
  
  -- Configure window-local options for clean UI appearance
  -- These options are similar to the vertical split sidebar but in a floating context
  vim.wo[floating_win].number = false
  vim.wo[floating_win].relativenumber = false
  vim.wo[floating_win].signcolumn = "no"
  vim.wo[floating_win].foldcolumn = "0"
  vim.wo[floating_win].spell = false
  vim.wo[floating_win].cursorline = true
  
  -- Optional: Custom window highlighting for visual polish
  -- This overrides Normal and FloatBorder highlight groups for this window
  -- Uncomment to use default terminal colors (no special floating window styling)
  -- vim.wo[floating_win].winhighlight = "NormalFloat:Normal,FloatBorder:Normal"
  
  return floating_win
end

-- Set up sidebar-specific keymaps
-- This function creates buffer-local keymaps for the floating sidebar and disables
-- normal editing commands. This is CRITICAL for making the sidebar feel like
-- a UI panel rather than an editable buffer.
--
-- IMPORTANT: Keymap Isolation Strategy
-- -------------------------------------
-- We use the same keymap isolation pattern as the vertical split sidebar:
-- 1. Map useful sidebar actions (q/<Esc> to close, <CR> for select)
-- 2. Map all insert mode triggers to <Nop> to prevent entering insert mode
-- 3. Map common edit commands to <Nop> to prevent accidental edits
--
-- All mappings are buffer-local (buffer = buf option) so they ONLY apply in
-- the floating sidebar buffer, not in the user's normal editing buffers.
--
-- Parameters:
--   buffer: buffer handle to set up keymaps for
local function setup_sidebar_keymaps(buffer)
  local opts = { buffer = buffer, nowait = true, silent = true }
  
  -- Sidebar action keymaps
  -- q - Close the sidebar (standard convention)
  vim.keymap.set("n", "q", M.close, vim.tbl_extend("force", opts, {
    desc = "Close floating sidebar"
  }))
  
  -- <Esc> - Also close the sidebar (useful for floating window contexts)
  vim.keymap.set("n", "<Esc>", M.close, vim.tbl_extend("force", opts, {
    desc = "Close floating sidebar"
  }))
  
  -- <CR> (Enter) - Select/action (placeholder for educational purposes)
  vim.keymap.set("n", "<CR>", function()
    local line = vim.fn.line(".")
    vim.notify(string.format("Floating sidebar: selected line %d (demo)", line), vim.log.levels.INFO)
  end, vim.tbl_extend("force", opts, {
    desc = "Select item (demo)"
  }))
  
  -- CRITICAL: Disable insert mode keys
  -- Prevents users from accidentally entering insert mode in the UI panel
  local insert_keys = { "i", "a", "o", "I", "A", "O" }
  for _, key in ipairs(insert_keys) do
    vim.keymap.set("n", key, "<Nop>", opts)
  end
  
  -- CRITICAL: Disable common edit commands
  -- Prevents users from executing edit operations even though buffer is read-only
  -- This provides better UX (no error messages) and clearer intent
  -- Note: We disable fewer keys than the vertical split sidebar to keep this example simple
  local edit_keys = { "dd", "yy", "p", "P", "D", "x", "X" }
  for _, key in ipairs(edit_keys) do
    vim.keymap.set("n", key, "<Nop>", opts)
  end
end

-- Render sidebar content using buffer lines and extmarks
-- This function demonstrates both traditional buffer line rendering and
-- extmark-based enhancements for complete visual control.
--
-- IMPORTANT: Extmark-Based Rendering (see Decision 2 in design.md)
-- -----------------------------------------------------------------
-- This implementation uses BOTH approaches for educational purposes:
--
-- 1. nvim_buf_set_lines() - Sets the base text content
--    - Provides stable, selectable, searchable line content
--    - Standard approach for buffer content
--
-- 2. nvim_buf_set_extmark() - Adds visual enhancements via extmarks
--    - Virtual text (appears in buffer but isn't part of actual content)
--    - Inline highlights
--    - Icons and decorations
--    - Can be positioned with pixel-perfect control
--
-- When to use each:
-- - Use buf_set_lines() for primary content that users should be able to search/select
-- - Use extmarks for decorations, icons, highlights, virtual text that enhances visuals
--
-- Extmark parameters explained:
-- - virt_text: array of {text, highlight_group} tuples for virtual text
-- - virt_text_pos: "eol" (end of line), "overlay", "right_align"
-- - hl_mode: "combine" (merge with existing highlights), "replace", "blend"
--
-- Parameters:
--   buffer: buffer handle to render content into
function render(buffer)
  -- Build the content lines array
  local lines = {
    " My Floating Sidebar",
    "",
    " Item 1",
    " Item 2",
    " Item 3",
    "",
    " q / <Esc>  Close",
  }
  
  -- CRITICAL: Clear existing extmarks before rendering
  -- This ensures we don't accumulate old extmarks on each render
  -- nvim_buf_clear_namespace(buffer, namespace, start_line, end_line)
  -- Using 0, -1 clears all lines in the buffer
  vim.api.nvim_buf_clear_namespace(buffer, ns, 0, -1)
  
  -- CRITICAL: Temporarily make buffer modifiable
  -- The buffer is configured as read-only to prevent accidental edits
  -- We need to allow modifications to update content, then set back to read-only
  vim.bo[buffer].modifiable = true
  
  -- Set the buffer content using traditional buffer lines
  -- This provides the base text that users can see and search
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  
  -- Add extmark enhancements for visual polish
  -- Example: Add a virtual text icon/indicator to the first line
  -- This demonstrates extmark capabilities without cluttering the example
  vim.api.nvim_buf_set_extmark(buffer, ns, 0, 0, {
    virt_text = { {" ➜ ", "Title"} },
    virt_text_pos = "eol",
    hl_mode = "combine",
  })
  
  -- Example: Highlight specific lines
  -- Line 0 (first line) gets Title highlight
  vim.api.nvim_buf_add_highlight(buffer, ns, "Title", 0, 0, -1)
  
  -- CRITICAL: Set buffer back to read-only
  -- This prevents users from editing the sidebar content
  vim.bo[buffer].modifiable = false
end

-- ============================================================================
-- Public API Functions
-- ============================================================================
-- These functions are exposed to users and other modules.
-- They provide the main interface for controlling the floating sidebar.

-- Open the floating sidebar
-- If the sidebar is already open, this just focuses the existing window.
-- Otherwise, it creates the buffer and window and renders content.
function M.open()
  -- Check if floating sidebar window already exists and is valid
  if win and vim.api.nvim_win_is_valid(win) then
    -- Window exists, just focus it
    vim.api.nvim_set_current_win(win)
    return
  end
  
  -- Create or get the sidebar buffer
  local sidebar_buf = create_or_get_buffer()
  
  -- Create the floating window
  win = create_window(sidebar_buf)
  
  -- Set up buffer-local keymaps for sidebar interactions
  setup_sidebar_keymaps(sidebar_buf)
  
  -- Render content
  render(sidebar_buf)
end

-- Close the floating sidebar
-- If the sidebar is already closed, this does nothing (no error).
function M.close()
  -- Check if floating sidebar window exists and is valid
  if win and vim.api.nvim_win_is_valid(win) then
    -- Close the window (true = force close)
    vim.api.nvim_win_close(win, true)
    
    -- Clear the window handle
    win = nil
  end
end

-- Toggle the floating sidebar
-- If open, close it. If closed, open it.
function M.toggle()
  -- Check if floating sidebar window exists and is valid
  if win and vim.api.nvim_win_is_valid(win) then
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
-- Return the module table so users can require() and use it.
-- Example: require("nvim-plugin.floating-sidebar").toggle()
return M
