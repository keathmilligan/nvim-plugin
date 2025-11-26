-- nvim-plugin: A minimal educational Neovim plugin example
-- This demonstrates modern Neovim plugin development patterns for LazyVim users

-- ============================================================================
-- Module Pattern
-- ============================================================================
-- Neovim plugins typically use the "module pattern" where we create a table (M)
-- that holds public functions. This allows users to require() the plugin and
-- call methods like setup().
local M = {}

-- ============================================================================
-- Default Configuration
-- ============================================================================
-- Define sensible defaults that users can override via setup().
-- This pattern is standard in the Neovim plugin ecosystem.
local default_config = {
  -- Customize the greeting message shown by :NvimPluginHello
  greeting = "Hello from nvim-plugin!",
  
  -- Enable or disable default keymaps (<leader>ph and <leader>pt)
  -- Users can set this to false and define their own keymaps in LazyVim
  enable_keymaps = true,
}

-- ============================================================================
-- Plugin State
-- ============================================================================
-- Store runtime state separately from configuration.
-- The 'state' table tracks mutable plugin behavior (like toggle status).
local state = {
  -- Track whether the plugin is "enabled" for the toggle command demo
  enabled = true,
  
  -- Store the merged configuration after setup() is called
  config = {},
}

-- ============================================================================
-- Keybinding Tracking
-- ============================================================================
-- Store metadata about registered keybindings for display purposes.
-- This table tracks our plugin's keymaps so we can show them to users.
-- Note: If you add new keymaps, update this table to keep display in sync!
local registered_keymaps = {
  { key = "<leader>ph", command = "NvimPluginHello", desc = "Show plugin greeting" },
  { key = "<leader>pt", command = "NvimPluginToggle", desc = "Toggle plugin state" },
  { key = "<leader>pk", command = "NvimPluginKeybindings", desc = "Show plugin keybindings" },
}

-- ============================================================================
-- Private Helper Functions
-- ============================================================================
-- These functions are local to this module and not exposed to users.
-- Keeping them private makes the API surface cleaner and easier to maintain.

-- Merge user configuration with defaults
-- Uses vim.tbl_deep_extend to recursively merge tables
local function merge_config(user_config)
  -- vim.tbl_deep_extend: "force" mode means user values override defaults
  -- This is the standard way to handle configuration in Neovim plugins
  return vim.tbl_deep_extend("force", default_config, user_config or {})
end

-- Display the greeting message
-- This is a simple helper that encapsulates the greeting logic
local function show_greeting()
  -- vim.notify() is the modern way to show messages in Neovim (0.5+)
  -- It's preferred over print() or vim.cmd("echo") because:
  -- - It supports log levels (INFO, WARN, ERROR)
  -- - It integrates with notification plugins like nvim-notify
  -- - It's more discoverable (messages go to :messages)
  vim.notify(state.config.greeting, vim.log.levels.INFO)
end

-- Toggle the plugin's enabled state
-- Demonstrates how to implement stateful plugin behavior
local function toggle_state()
  -- Flip the boolean state
  state.enabled = not state.enabled
  
  -- Provide user feedback about the new state
  local message = state.enabled and "nvim-plugin enabled" or "nvim-plugin disabled"
  vim.notify(message, vim.log.levels.INFO)
end

-- Get keybindings metadata based on current configuration
-- Returns an array of keybinding tables with key, command, and description
local function get_keybindings()
  -- If keymaps are disabled, return empty array
  -- This demonstrates how plugin behavior adapts to configuration
  if not state.config.enable_keymaps then
    return {}
  end
  
  -- Return a copy of the registered keymaps
  -- We return all keymaps including the keybindings display command itself
  return vim.deepcopy(registered_keymaps)
end

-- Format keybindings into human-readable text lines
-- Takes an array of keybinding tables and returns an array of strings
-- Demonstrates string formatting and data presentation in Lua
local function format_keybindings(bindings)
  local lines = {}
  
  -- Add header
  table.insert(lines, "nvim-plugin Keybindings")
  table.insert(lines, "=======================")
  table.insert(lines, "")
  
  -- Check if there are any keybindings to display
  if #bindings == 0 then
    table.insert(lines, "Default keymaps are disabled.")
    table.insert(lines, "")
    table.insert(lines, "To enable them, configure the plugin with:")
    table.insert(lines, '  require("nvim-plugin").setup({ enable_keymaps = true })')
    table.insert(lines, "")
    table.insert(lines, "Commands are still available:")
    table.insert(lines, "  :NvimPluginHello")
    table.insert(lines, "  :NvimPluginToggle")
    table.insert(lines, "  :NvimPluginKeybindings")
    return lines
  end
  
  -- Add column headers
  table.insert(lines, "Key             Command                   Description")
  table.insert(lines, "---             -------                   -----------")
  
  -- Add each keybinding as a row
  -- Use string.format() for aligned columns (demonstrates Lua string formatting)
  for _, binding in ipairs(bindings) do
    local line = string.format("%-15s %-25s %s",
      binding.key,
      ":" .. binding.command,
      binding.desc)
    table.insert(lines, line)
  end
  
  -- Add helpful note about the leader key
  table.insert(lines, "")
  table.insert(lines, "Note: <leader> is typically <Space> in LazyVim (or \\ by default)")
  
  return lines
end

-- Display keybindings in a new buffer
-- Creates a scratch buffer and fills it with formatted keybinding information
-- Demonstrates buffer creation, configuration, and content manipulation
local function show_keybindings()
  -- Get keybinding data and format it
  local bindings = get_keybindings()
  local lines = format_keybindings(bindings)
  
  -- Create a new buffer with a unique name
  -- The URI-style name "nvim-plugin://keybindings" follows Neovim conventions
  local bufname = "nvim-plugin://keybindings"
  
  -- Check if a buffer with this name already exists
  local existing_buf = vim.fn.bufnr(bufname)
  local buf
  
  if existing_buf ~= -1 then
    -- Reuse existing buffer
    buf = existing_buf
  else
    -- Create a new buffer
    -- vim.api.nvim_create_buf(listed, scratch)
    -- - listed: false = don't show in buffer list
    -- - scratch: true = temporary buffer, not saved to disk
    buf = vim.api.nvim_create_buf(false, true)
    
    -- Set the buffer name
    vim.api.nvim_buf_set_name(buf, bufname)
  end
  
  -- Configure buffer options
  -- These make the buffer read-only and suitable for display purposes
  vim.bo[buf].buftype = "nofile"      -- Not associated with a file
  vim.bo[buf].bufhidden = "wipe"      -- Delete buffer when hidden
  vim.bo[buf].swapfile = false        -- No swap file needed
  vim.bo[buf].modifiable = true       -- Temporarily allow modifications
  
  -- Set buffer content
  -- vim.api.nvim_buf_set_lines(buffer, start, end, strict_indexing, lines)
  -- Using 0, -1 replaces all content in the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Make buffer read-only after setting content
  vim.bo[buf].modifiable = false
  
  -- Open the buffer in the current window
  -- User can choose how to open it (split, vsplit, etc.) before running command
  vim.api.nvim_set_current_buf(buf)
end

-- ============================================================================
-- Command Registration
-- ============================================================================
-- Register user commands using the modern Neovim API.
-- These functions are called from setup() to ensure commands are only
-- registered when the user explicitly loads the plugin.

local function register_commands()
  -- vim.api.nvim_create_user_command() is the modern way to create commands (Neovim 0.7+)
  -- It's preferred over vim.cmd("command! ...") because:
  -- - Better error handling
  -- - Native Lua function callbacks (no need for vim.cmd wrappers)
  -- - Support for completion, arguments, ranges, etc.
  
  -- :NvimPluginHello - Display the configured greeting
  vim.api.nvim_create_user_command("NvimPluginHello", function()
    show_greeting()
  end, {
    desc = "Display the nvim-plugin greeting message",
  })
  
  -- :NvimPluginToggle - Toggle the plugin state (demonstrates stateful behavior)
  vim.api.nvim_create_user_command("NvimPluginToggle", function()
    toggle_state()
  end, {
    desc = "Toggle nvim-plugin enabled/disabled state",
  })
  
  -- :NvimPluginKeybindings - Display all plugin keybindings in a buffer
  vim.api.nvim_create_user_command("NvimPluginKeybindings", function()
    show_keybindings()
  end, {
    desc = "Show all plugin keybindings in a new buffer",
  })
end

-- ============================================================================
-- Keymap Registration
-- ============================================================================
-- Register default keymaps if enabled in configuration.
-- Users can disable these and define custom keymaps in their LazyVim config.

local function register_keymaps()
  -- Only register keymaps if the user hasn't disabled them
  if not state.config.enable_keymaps then
    return
  end
  
  -- vim.keymap.set() is the modern keymap API (Neovim 0.7+)
  -- It's preferred over vim.api.nvim_set_keymap() because:
  -- - Cleaner syntax (no need for {noremap = true, silent = true} boilerplate)
  -- - Direct Lua function callbacks (no need for <cmd>...<cr> wrappers)
  -- - Better defaults (noremap by default)
  
  -- <leader>ph - Plugin Hello
  vim.keymap.set("n", "<leader>ph", function()
    show_greeting()
  end, {
    desc = "Show plugin greeting",
  })
  
  -- <leader>pt - Plugin Toggle
  vim.keymap.set("n", "<leader>pt", function()
    toggle_state()
  end, {
    desc = "Toggle plugin state",
  })
  
  -- <leader>pk - Plugin Keybindings
  vim.keymap.set("n", "<leader>pk", function()
    show_keybindings()
  end, {
    desc = "Show plugin keybindings",
  })
end

-- ============================================================================
-- Public API: setup()
-- ============================================================================
-- The setup() function is the main entry point for users.
-- It should be called in the LazyVim plugin config function.

function M.setup(opts)
  -- Merge user configuration with defaults
  state.config = merge_config(opts)
  
  -- Register commands and keymaps
  -- Note: We register these every time setup() is called to support
  -- multiple setup() calls (last one wins). Neovim won't duplicate commands
  -- if they're registered with the same name.
  register_commands()
  register_keymaps()
end

-- ============================================================================
-- Module Export
-- ============================================================================
-- Return the module table so users can require() and use it.
-- Example: require("nvim-plugin").setup({ greeting = "Custom!" })
return M
