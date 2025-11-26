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
  { key = "<leader>pa", command = "NvimPluginAllKeybindings", desc = "Show all Neovim keybindings" },
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
-- Global Keybindings Viewer Helper Functions
-- ============================================================================
-- The following functions implement a comprehensive keybindings viewer that
-- displays ALL keybindings from all sources (Neovim core, plugins, user config).
-- This demonstrates how to query and display Neovim's keymap state programmatically.
--
-- IMPORTANT: Built-in Neovim commands (like dd, yy, gg, <C-w>h, etc.) are NOT
-- exposed through vim.api.nvim_get_keymap() because they're handled internally
-- by Neovim's command processor. To discover these built-in keybindings, we
-- parse Neovim's runtime documentation file (doc/index.txt) which comprehensively
-- documents all ~1,264 built-in keybindings across all modes.

--
-- IMPORTANT: Understanding Built-in vs. Registered Keybindings
-- -------------------------------------------------------------
-- Neovim has two types of keybindings:
--
-- 1. REGISTERED KEYMAPS - Explicitly registered via vim.keymap.set(), nvim_set_keymap(),
--    or legacy :map commands. These are queryable via vim.api.nvim_get_keymap().
--    Examples: Plugin keymaps, user config keymaps, some Neovim defaults (like Y -> y$)
--
-- 2. BUILT-IN COMMANDS - Core Neovim functionality handled internally by the command
--    processor. These are NOT exposed through keymap APIs but ARE documented in help files.
--    Examples: dd (delete line), yy (yank line), gg (go to top), <C-w>h (window left)
--
-- The vim.api.nvim_get_keymap() API only returns registered keymaps. This means hundreds
-- of built-in commands (operators, motions, window commands, etc.) are invisible to that API.
-- To show a complete picture, we parse Neovim's runtime doc/index.txt file, which contains
-- comprehensive documentation of all ~1,264 built-in keybindings across all modes.
--
-- This approach:
-- - Uses the authoritative source (Neovim's own documentation)
-- - Automatically matches the installed Neovim version
-- - Avoids outdated or incorrect third-party documentation
-- - Requires no manual maintenance when Neovim updates

-- Cache for parsed built-in keybindings (parse once per session for performance)
local builtin_keymaps_cache = nil

-- Parse Neovim's runtime doc/index.txt to extract built-in keybindings
-- This is necessary because built-in commands like dd, yy, gg, <C-w>h, etc. are NOT
-- exposed through vim.api.nvim_get_keymap() - they're handled internally by the command processor.
-- The index.txt file contains comprehensive documentation of all ~1,264 built-in keybindings.
-- Returns: { [mode] = { {lhs, desc, source}, ... } }
local function parse_builtin_keybindings()
  -- Check cache first
  if builtin_keymaps_cache then
    return builtin_keymaps_cache
  end
  
  -- Initialize result structure
  local builtin_keymaps = {
    n = {},  -- Normal mode
    i = {},  -- Insert mode
    v = {},  -- Visual mode
    s = {},  -- Select mode
    o = {},  -- Operator-pending mode
    t = {},  -- Terminal mode
    c = {},  -- Command-line mode
  }
  
  -- Locate the runtime index.txt file
  -- This uses Neovim's runtime path to find the authoritative help documentation
  local index_files = vim.api.nvim_get_runtime_file('doc/index.txt', false)
  
  if #index_files == 0 then
    -- Fallback: index.txt not found (unusual but handle gracefully)
    vim.notify("Warning: doc/index.txt not found. Built-in keybindings will not be shown.", vim.log.levels.WARN)
    builtin_keymaps_cache = builtin_keymaps
    return builtin_keymaps
  end
  
  -- Read the index.txt file
  local index_file = index_files[1]
  local file = io.open(index_file, 'r')
  
  if not file then
    vim.notify("Warning: Could not read " .. index_file, vim.log.levels.WARN)
    builtin_keymaps_cache = builtin_keymaps
    return builtin_keymaps
  end
  
  local content = file:read('*all')
  file:close()
  
  -- Parse the file line by line
  -- Format: |tag|		key		description
  -- Example: |i_CTRL-W|		CTRL-W		delete word before the cursor
  -- Example: |dd|			dd		delete N lines [into register x]
  
  for line in content:gmatch('[^\r\n]+') do
    -- Match lines with the pattern: |tag|\t\tkey\t\tdescription
    -- The tag indicates the mode (e.g., i_CTRL-W for insert mode, no prefix for normal)
    local tag, key, desc = line:match('|([^|]+)|%s+(%S+)%s+(.+)')
    
    if tag and key and desc then
      -- Determine mode from tag prefix
      -- Tags like "i_CTRL-W" indicate insert mode
      -- Tags like "v_d" indicate visual mode
      -- Tags without prefix (like "dd", "gg") are normal mode
      local mode = 'n'  -- Default to normal mode
      
      if tag:match('^i_') then
        mode = 'i'
      elseif tag:match('^v_') then
        mode = 'v'
      elseif tag:match('^c_') then
        mode = 'c'
      elseif tag:match('^o_') then
        mode = 'o'
      elseif tag:match('^t_') then
        mode = 't'
      elseif tag:match('^s_') then
        mode = 's'
      end
      
      -- Clean up the key representation
      -- Convert documented format (e.g., "CTRL-W") to Neovim keycode format (e.g., "<C-W>")
      local cleaned_key = key
      
      -- CTRL-X -> <C-X>
      cleaned_key = cleaned_key:gsub('CTRL%-([A-Za-z0-9])', '<C-%1>')
      
      -- Handle special cases
      if cleaned_key == '<NL>' then cleaned_key = '<C-J>' end
      if cleaned_key == '<CR>' or cleaned_key == 'CTRL-M' then cleaned_key = '<CR>' end
      if cleaned_key == '<Esc>' or cleaned_key == 'CTRL-[' then cleaned_key = '<Esc>' end
      if cleaned_key == '<BS>' or cleaned_key == 'CTRL-H' then cleaned_key = '<BS>' end
      
      -- Add to the appropriate mode's keybindings
      table.insert(builtin_keymaps[mode], {
        lhs = cleaned_key,
        desc = desc,
        source = 'builtin',  -- Mark as built-in for source tracking
      })
    end
  end
  
  -- Cache the results for future calls
  builtin_keymaps_cache = builtin_keymaps
  
  return builtin_keymaps
end

-- Extract plugin name from keymap command or description
-- Attempts to identify which plugin registered a keymap by analyzing the command or description
-- Returns: plugin name string or empty string if unable to determine
local function extract_plugin_name(map)
  -- Check description first for common patterns like "Telescope: Find files"
  if map.desc and map.desc ~= "" then
    -- Pattern: "PluginName: ..." or "[PluginName] ..."
    local plugin = map.desc:match("^([%w%-_]+)%s*:")
    if plugin then return plugin end
    
    plugin = map.desc:match("^%[([%w%-_]+)%]")
    if plugin then return plugin end
  end
  
  -- Check command/rhs for common patterns
  if map.rhs and map.rhs ~= "" then
    -- Pattern: <cmd>PluginName ... or :PluginName
    local plugin = map.rhs:match("<[Cc][Mm][Dd]>%s*([%w%-_]+)")
    if plugin then return plugin end
    
    plugin = map.rhs:match("^:%s*([%w%-_]+)")
    if plugin then return plugin end
    
    -- Pattern: require("plugin-name") or require('plugin-name')
    plugin = map.rhs:match('require%s*%(?["\']([%w%-_%.]+)["\']%)?')
    if plugin then return plugin end
    
    -- Pattern: <cmd>lua require("plugin")
    plugin = map.rhs:match('<[Cc][Mm][Dd]>%s*lua%s+require%s*%(?["\']([%w%-_%.]+)["\']%)?')
    if plugin then return plugin end
  end
  
  return ""
end

-- Map mode character to human-readable name
-- Neovim uses single-character abbreviations for modes:
-- n = normal, i = insert, v = visual, s = select, o = operator-pending, t = terminal, c = command-line
local function get_mode_name(mode_char)
  local mode_names = {
    n = "Normal Mode",
    i = "Insert Mode",
    v = "Visual Mode",
    s = "Select Mode",
    o = "Operator-Pending Mode",
    t = "Terminal Mode",
    c = "Command-Line Mode",
  }
  return mode_names[mode_char] or "Unknown Mode"
end

-- Query all keymaps from Neovim's keymap state and merge with built-in keybindings
-- This function demonstrates how to use vim.api.nvim_get_keymap() and vim.api.nvim_buf_get_keymap()
-- to retrieve both global and buffer-local keymaps across all modes, then merges with built-in
-- commands parsed from doc/index.txt.
-- Returns: { [mode] = { {lhs, rhs, desc, buffer_local, source}, ... } }
local function get_all_keymaps()
  -- Define all modes we want to query
  -- These cover all possible contexts where keybindings can be defined
  local modes = { 'n', 'i', 'v', 's', 'o', 't', 'c' }
  local all_keymaps = {}
  
  for _, mode in ipairs(modes) do
    all_keymaps[mode] = {}
    
    -- Query global keymaps using vim.api.nvim_get_keymap(mode)
    -- This returns an array of keymap tables with fields: lhs, rhs, desc, silent, noremap, etc.
    -- Global keymaps are those registered with vim.keymap.set() or similar without buffer-specific options
    local global_maps = vim.api.nvim_get_keymap(mode)
    for _, map in ipairs(global_maps) do
      local plugin_name = extract_plugin_name(map)
      table.insert(all_keymaps[mode], {
        lhs = map.lhs,
        rhs = map.rhs or "",
        desc = map.desc or "",
        buffer_local = false,
        source = 'plugin',  -- Registered keymaps are from plugins or user config
        plugin = plugin_name,
      })
    end
    
    -- Query buffer-local keymaps using vim.api.nvim_buf_get_keymap(buffer, mode)
    -- Buffer-local keymaps are registered for specific buffers (e.g., LSP keymaps for code files)
    -- Using 0 as the buffer number means "current buffer"
    local buffer_maps = vim.api.nvim_buf_get_keymap(0, mode)
    for _, map in ipairs(buffer_maps) do
      local plugin_name = extract_plugin_name(map)
      table.insert(all_keymaps[mode], {
        lhs = map.lhs,
        rhs = map.rhs or "",
        desc = map.desc or "",
        buffer_local = true,
        source = 'plugin',  -- Buffer-local registered keymaps
        plugin = plugin_name,
      })
    end
  end
  
  -- Parse and merge built-in keybindings from doc/index.txt
  -- These are the core Neovim commands (dd, yy, gg, <C-w>h, etc.) that are NOT
  -- exposed through vim.api.nvim_get_keymap() because they're handled internally
  local builtin_keymaps = parse_builtin_keybindings()
  
  for mode, builtin_maps in pairs(builtin_keymaps) do
    for _, builtin_map in ipairs(builtin_maps) do
      table.insert(all_keymaps[mode], {
        lhs = builtin_map.lhs,
        rhs = "",  -- Built-in commands don't have an rhs (they're internal)
        desc = builtin_map.desc,
        buffer_local = false,
        source = 'builtin',  -- Mark as built-in for visual indicators
        plugin = "neovim",  -- Built-in commands are from Neovim core
      })
    end
  end
  
  return all_keymaps
end

-- Filter out internal plugin mappings and command-line commands to reduce noise
-- Many plugins use internal mappings (starting with <Plug>) that aren't meant for direct user invocation
-- Command-line mode entries starting with ":" are commands, not keybindings
-- We keep all other keymaps, including core Neovim bindings that may not have descriptions
local function filter_keymaps(keymaps)
  local filtered = {}
  
  for mode, maps in pairs(keymaps) do
    filtered[mode] = {}
    
    for _, map in ipairs(maps) do
      -- Filter logic:
      -- 1. Skip internal plugin mappings (those starting with <Plug>)
      --    These are used internally by plugins and not meant for direct user invocation
      -- 2. Skip command-line commands (entries starting with ":")
      --    These are ex commands, not keybindings (e.g., ":help", ":quit")
      -- 3. Keep everything else, including core Neovim bindings without descriptions
      --    Many useful keymaps (like <C-w>h for window navigation) don't have descriptions
      local is_plug_mapping = map.lhs:match("^<Plug>") ~= nil
      local is_command = map.lhs:match("^:") ~= nil
      
      if not is_plug_mapping and not is_command then
        table.insert(filtered[mode], map)
      end
    end
  end
  
  return filtered
end

-- Make key sequences human-readable by converting invisible characters
-- Neovim's vim.api.nvim_get_keymap() returns keymaps with <leader> already expanded
-- to the literal key (e.g., a space character if leader is space). This function
-- converts those literal characters back to visible representations like <Space>.
local function make_key_readable(key_sequence)
  -- vim.api.nvim_get_keymap() returns keys with <leader> already expanded to the actual character
  -- For example, if leader is space, "<leader>ph" becomes " ph" (with a literal space)
  -- We need to convert these literal characters to visible representations
  
  local readable = key_sequence
  
  -- Replace leading space character with <Space> for visibility
  -- This is the most common case in LazyVim where leader is space
  readable = readable:gsub("^ ", "<Space>")
  
  -- Also handle spaces in the middle of sequences (less common but possible)
  -- Only replace if not already in <> notation
  readable = readable:gsub("([^<]) ([^>])", "%1<Space>%2")
  
  -- Handle other special characters that might be hard to see
  -- Tab character -> <Tab>
  readable = readable:gsub("\t", "<Tab>")
  
  -- Handle other control characters if present
  -- CR (carriage return) -> <CR>
  readable = readable:gsub("\r", "<CR>")
  
  -- Handle escape if present (though it's usually already in <Esc> notation)
  readable = readable:gsub("\27", "<Esc>")
  
  return readable
end

-- Format all keybindings into human-readable text lines grouped by mode
-- This creates a nicely formatted display with mode sections and aligned columns
local function format_all_keybindings(keymaps)
  local lines = {}
  
  -- Get leader key for display in header
  local leader = vim.g.mapleader or "\\"
  local leader_display = (leader == " ") and "<Space>" or leader
  
  -- Get Neovim version for header
  local nvim_version = vim.fn.has('nvim-0.9') == 1 and "0.9+" or 
                       vim.fn.has('nvim-0.8') == 1 and "0.8+" or
                       vim.fn.has('nvim-0.7') == 1 and "0.7+" or "Unknown"
  
  -- Count total keymaps and keymaps by source for statistics
  local total_count = 0
  local builtin_count = 0
  local plugin_count = 0
  for _, maps in pairs(keymaps) do
    for _, map in ipairs(maps) do
      total_count = total_count + 1
      if map.source == 'builtin' then
        builtin_count = builtin_count + 1
      else
        plugin_count = plugin_count + 1
      end
    end
  end
  
  -- Add comprehensive header
  table.insert(lines, "All Neovim Keybindings")
  table.insert(lines, "=======================")
  table.insert(lines, "")
  table.insert(lines, string.format("Showing %d total keybindings:", total_count))
  table.insert(lines, string.format("  - %d built-in Neovim commands (from runtime doc/index.txt)", builtin_count))
  table.insert(lines, string.format("  - %d registered keymaps (from plugins and user config)", plugin_count))
  table.insert(lines, "")
  table.insert(lines, "Source Indicators:")
  table.insert(lines, "  [C] - Core Neovim built-in command (from internal command processor)")
  table.insert(lines, "  [P] - Plugin or user-registered keymap (via vim.keymap.set())")
  table.insert(lines, "  [B] - Buffer-local keymap (specific to current buffer)")
  table.insert(lines, "")
  table.insert(lines, string.format("Neovim Version: %s", nvim_version))
  table.insert(lines, string.format("Leader key: %s", leader_display))
  table.insert(lines, "")
  table.insert(lines, "Understanding the Data Sources:")
  table.insert(lines, "  - BUILT-IN COMMANDS are parsed from Neovim's runtime doc/index.txt help file")
  table.insert(lines, "    These are core operations like 'dd', 'yy', 'gg', '<C-w>h' that are NOT exposed")
  table.insert(lines, "    through vim.api.nvim_get_keymap() because they're handled internally.")
  table.insert(lines, "  - REGISTERED KEYMAPS are queried via vim.api.nvim_get_keymap() and include")
  table.insert(lines, "    keybindings from plugins (LSP, Telescope, etc.) and your user configuration.")
  table.insert(lines, "")
  
  -- Define the order of modes for display (most common first)
  local mode_order = { 'n', 'i', 'v', 's', 'o', 't', 'c' }
  
  for _, mode in ipairs(mode_order) do
    local maps = keymaps[mode]
    
    -- Skip empty modes to keep output clean
    if maps and #maps > 0 then
      -- Add mode section header with count
      table.insert(lines, "")
      table.insert(lines, string.format("=== %s (%s) - %d keybindings ===", get_mode_name(mode), mode, #maps))
      table.insert(lines, "")
      -- Column headers: Src + Key (28 chars) + Plugin (20 chars) + Command (44 chars) + Description
      table.insert(lines, string.format("%-28s %-20s %-44s %s", "Key", "Plugin", "Command/Action", "Description"))
      
      -- Add each keybinding as a formatted row
      for _, map in ipairs(maps) do
        -- Convert key sequence to human-readable format (e.g., space -> <Space>)
        local readable_key = make_key_readable(map.lhs)
        
        -- Get plugin name and truncate if needed
        local plugin = map.plugin or ""
        if #plugin > 20 then
          plugin = string.sub(plugin, 1, 17) .. "..."
        end
        
        -- Truncate long commands to keep columns aligned
        local cmd = map.rhs
        if #cmd > 44 then
          cmd = string.sub(cmd, 1, 41) .. "..."
        end
        
        -- Determine prefix based on source and buffer-local status
        -- [C] = Core/built-in, [P] = Plugin/registered, [B] = Buffer-local
        local prefix
        if map.source == 'builtin' then
          prefix = "[C]"
        elseif map.buffer_local then
          prefix = "[B]"
        else
          prefix = "[P]"
        end
        
        -- Handle empty descriptions (many core Neovim keymaps don't have descriptions)
        local description = map.desc and map.desc ~= "" and map.desc or ""
        
        -- Combine prefix and key into a single column (28 chars total: 4 for prefix + 24 for key)
        local key_with_prefix = string.format("%s %s", prefix, readable_key)
        
        -- Format as fixed-width columns for readability
        -- Key (28 chars) + Plugin (20 chars) + Command (44 chars) + Description (unlimited)
        local line = string.format("%-28s %-20s %-44s %s",
          key_with_prefix,
          plugin,
          cmd,
          description)
        table.insert(lines, line)
      end
    end
  end
  
  -- Add helpful footer
  table.insert(lines, "")
  table.insert(lines, "---")
  table.insert(lines, "Tip: Use / to search within this buffer")
  
  return lines
end

-- Display all keybindings in a new buffer
-- This is the main entry point that orchestrates querying, filtering, formatting, and displaying
local function show_all_keybindings()
  -- Query all keymaps from Neovim
  local all_keymaps = get_all_keymaps()
  
  -- Filter out internal/unnamed mappings
  local filtered_keymaps = filter_keymaps(all_keymaps)
  
  -- Format into display lines
  local lines = format_all_keybindings(filtered_keymaps)
  
  -- Create a new buffer with a unique name
  local bufname = "nvim-plugin://all-keybindings"
  
  -- Check if buffer already exists
  local existing_buf = vim.fn.bufnr(bufname)
  local buf
  
  if existing_buf ~= -1 then
    buf = existing_buf
  else
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, bufname)
  end
  
  -- Configure buffer as scratch/read-only display buffer
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  
  -- Set content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Make read-only
  vim.bo[buf].modifiable = false
  
  -- Display in current window
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
  
  -- :NvimPluginAllKeybindings - Display ALL keybindings from all sources in a buffer
  vim.api.nvim_create_user_command("NvimPluginAllKeybindings", function()
    show_all_keybindings()
  end, {
    desc = "Show all Neovim keybindings (core, plugins, user config) grouped by mode",
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
  
  -- <leader>pa - Plugin All keybindings (global viewer)
  vim.keymap.set("n", "<leader>pa", function()
    show_all_keybindings()
  end, {
    desc = "Show all Neovim keybindings",
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
