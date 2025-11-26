-- Test script to parse index.txt and extract keybindings programmatically
-- This demonstrates how to discover built-in Neovim keybindings from documentation

local function parse_index_txt()
  -- Find the index.txt file in Neovim's runtime
  local help_files = vim.api.nvim_get_runtime_file('doc/index.txt', false)
  if #help_files == 0 then
    print("Error: Could not find index.txt")
    return {}
  end
  
  local index_file = help_files[1]
  local f = io.open(index_file, 'r')
  if not f then
    print("Error: Could not open " .. index_file)
    return {}
  end
  
  local content = f:read('*a')
  f:close()
  
  -- Parse keybindings by mode section
  local keybindings = {
    n = {},  -- Normal mode
    i = {},  -- Insert mode
    v = {},  -- Visual mode
    x = {},  -- Visual block mode
    s = {},  -- Select mode
    o = {},  -- Operator-pending mode
    c = {},  -- Command-line mode
    t = {},  -- Terminal mode
  }
  
  local current_mode = nil
  local mode_patterns = {
    ['Insert mode'] = 'i',
    ['Normal mode'] = 'n',
    ['Visual mode'] = 'v',
    ['Select mode'] = 's',
    ['Operator%-pending mode'] = 'o',
    ['Command%-line editing'] = 'c',
    ['Terminal%-Job mode'] = 't',
  }
  
  for line in content:gmatch('[^\r\n]+') do
    -- Detect mode section headers
    for pattern, mode in pairs(mode_patterns) do
      if line:match('%d+%. ' .. pattern) then
        current_mode = mode
        break
      end
    end
    
    -- Parse keybinding entries
    -- Format: |tag|<tab>char<tab>note action/description
    local tag, char, rest = line:match('^|([^|]+)|%s+([^%s]+)%s+(.*)$')
    if tag and char and current_mode then
      -- Clean up the description
      local desc = rest:gsub('%s+', ' '):gsub('^%d+%s+', '')
      
      -- Determine actual mode from tag prefix
      local mode = current_mode
      if tag:match('^i_') then mode = 'i'
      elseif tag:match('^v_') then mode = 'v'
      elseif tag:match('^x_') then mode = 'x'
      elseif tag:match('^c_') then mode = 'c'
      elseif tag:match('^o_') then mode = 'o'
      elseif tag:match('^s_') then mode = 's'
      elseif tag:match('^t_') then mode = 't'
      end
      
      table.insert(keybindings[mode], {
        lhs = char,
        desc = desc,
        tag = tag,
      })
    end
  end
  
  return keybindings
end

-- Test the parser
local keybindings = parse_index_txt()

print("\n=== Keybinding Statistics ===")
for mode, bindings in pairs(keybindings) do
  print(string.format("%s mode: %d bindings", mode, #bindings))
end

print("\n=== Sample Normal Mode Bindings ===")
for i, binding in ipairs(keybindings.n) do
  if i <= 10 then
    print(string.format("%-15s %s", binding.lhs, binding.desc))
  end
end

print("\n=== Searching for 'dd' ===")
for _, binding in ipairs(keybindings.n) do
  if binding.lhs == '["x]dd' or binding.lhs:match('^dd') then
    print(string.format("Found: %-15s %s", binding.lhs, binding.desc))
  end
end

print("\n=== Searching for window commands ===")
for _, binding in ipairs(keybindings.n) do
  if binding.lhs:match('CTRL%-W') then
    print(string.format("%-15s %s", binding.lhs, binding.desc:sub(1, 50)))
  end
end
