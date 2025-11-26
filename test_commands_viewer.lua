-- Test script for commands viewer functionality
-- Run with: nvim --headless -S test_commands_viewer.lua

-- Add plugin to path
package.path = package.path .. ';lua/?.lua'

-- Load the plugin
local plugin = require('nvim-plugin')

-- Setup the plugin
plugin.setup()

print("=== Testing Commands Viewer ===\n")

-- Test 1: Check if command is registered
print("Test 1: Checking if :NvimPluginAllCommands is registered...")
local commands = vim.api.nvim_get_commands({})
if commands.NvimPluginAllCommands then
  print("✓ :NvimPluginAllCommands command is registered")
  print("  Description: " .. (commands.NvimPluginAllCommands.definition or "N/A"))
else
  print("✗ :NvimPluginAllCommands command NOT found!")
end

-- Test 2: Check if keymap is registered
print("\nTest 2: Checking if <leader>pc keymap is registered...")
local keymaps = vim.api.nvim_get_keymap('n')
local found_keymap = false
for _, map in ipairs(keymaps) do
  if map.lhs == ' pc' or map.lhs:match('pc$') then
    found_keymap = true
    print("✓ <leader>pc keymap is registered")
    print("  Description: " .. (map.desc or "N/A"))
    break
  end
end
if not found_keymap then
  print("✗ <leader>pc keymap NOT found!")
end

-- Test 3: Try to execute the command (without displaying buffer)
print("\nTest 3: Testing command execution (parsing built-in commands)...")
local success, err = pcall(function()
  -- Call the internal parser directly
  local parse_fn = debug.getregistry()['nvim_plugin_parse_builtin_commands']
  if not parse_fn then
    -- Try to find it another way - execute the command but capture any errors
    vim.cmd('NvimPluginAllCommands')
    print("✓ Command executed successfully")
    
    -- Check if buffer was created
    local bufname = "nvim-plugin://all-commands"
    local buf = vim.fn.bufnr(bufname)
    if buf ~= -1 then
      print("✓ Commands buffer created: " .. bufname)
      
      -- Get buffer contents and check for built-in commands
      local lines = vim.api.nvim_buf_get_lines(buf, 0, 50, false)
      local found_builtin = false
      local found_help = false
      local found_quit = false
      
      for _, line in ipairs(lines) do
        if line:match("%[C%]") then
          found_builtin = true
        end
        if line:match(":help") or line:match(":h%[elp%]") then
          found_help = true
        end
        if line:match(":quit") or line:match(":q%[uit%]") then
          found_quit = true
        end
      end
      
      if found_builtin then
        print("✓ Built-in commands ([C]) found in buffer")
      end
      if found_help then
        print("✓ :help command found in buffer")
      end
      if found_quit then
        print("✓ :quit command found in buffer")
      end
      
      -- Print first 30 lines for inspection
      print("\n--- First 30 lines of buffer ---")
      for i = 1, math.min(30, #lines) do
        print(lines[i])
      end
    else
      print("✗ Commands buffer NOT created!")
    end
  end
end)

if not success then
  print("✗ Error executing command: " .. tostring(err))
end

print("\n=== Tests Complete ===")

-- Quit Neovim
vim.cmd('quit!')
