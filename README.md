# nvim-plugin

A minimal example Neovim plugin demonstrating the basics of plugin development with modern APIs and LazyVim integration.

## Purpose

This is an **educational example** that illustrates fundamental concepts of Neovim plugin development:
- Basic plugin structure and organization (`lua/nvim-plugin/init.lua`)
- Creating user commands with `vim.api.nvim_create_user_command()`
- Registering keymaps with `vim.keymap.set()`
- Providing a setup function for user configuration
- Managing plugin state (stateful vs stateless behavior)
- Integration with LazyVim plugin manager
- Modern Neovim API usage (0.8+)

## Requirements

- Neovim 0.8 or higher
- LazyVim (or similar lazy-loading plugin manager)

## Quick Start

1. **Install the plugin** by adding to your LazyVim config
2. **Restart Neovim** or run `:Lazy reload nvim-plugin`
3. **Try the commands:**
   - Press `<leader>ph` to see the greeting
   - Press `<leader>pt` to toggle the plugin state
   - Or use `:NvimPluginHello` and `:NvimPluginToggle` directly

## Installation

> **Note**: All examples use the `opts = {}` pattern, which is the idiomatic LazyVim way. When you use `opts`, LazyVim automatically calls `require("nvim-plugin").setup(opts)` for you - no need for a manual `config = function()` block!

### LazyVim (Standard Installation - Simplest)

Create a new file in your LazyVim plugins directory (e.g., `~/.config/nvim/lua/plugins/nvim-plugin.lua`):

```lua
return {
  "yourusername/nvim-plugin",
  opts = {},
}
```

That's it! LazyVim automatically calls `require("nvim-plugin").setup(opts)` for you.

**With custom options:**
```lua
return {
  "yourusername/nvim-plugin",
  opts = {
    greeting = "Hello from nvim-plugin!",
    enable_keymaps = true,
  },
}
```

### Alternative: Explicit Config Function

If you need more control, you can use the explicit config function (but this is usually unnecessary):

```lua
return {
  "yourusername/nvim-plugin",
  config = function()
    require("nvim-plugin").setup({
      greeting = "Custom greeting!",
    })
  end,
}
```

### Local Development

To test the plugin locally before publishing:

```lua
return {
  dir = "/path/to/nvim-plugin",  -- Use absolute path to local directory
  opts = {},
}
```

**Windows example:**
```lua
return {
  dir = "C:/Users/yourname/projects/nvim-plugin",  -- Use forward slashes
  opts = {},
}
```

**Linux/macOS example:**
```lua
return {
  dir = "/home/yourname/projects/nvim-plugin",
  opts = {},
}
```

### Lazy-loading with Custom Keys

For better startup performance, configure lazy-loading with custom keymaps:

```lua
return {
  "yourusername/nvim-plugin",
  keys = {
    { "<leader>ph", "<cmd>NvimPluginHello<cr>", desc = "Show plugin greeting" },
    { "<leader>pt", "<cmd>NvimPluginToggle<cr>", desc = "Toggle plugin state" },
  },
  opts = {
    -- Disable default keymaps since we defined custom ones above
    enable_keymaps = false,
  },
}
```

### Alternative Keys Configuration

If you prefer different keymaps:

```lua
return {
  "yourusername/nvim-plugin",
  keys = {
    { "<leader>h", "<cmd>NvimPluginHello<cr>", desc = "Plugin greeting" },
    { "<leader>x", "<cmd>NvimPluginToggle<cr>", desc = "Toggle plugin" },
  },
  opts = {
    greeting = "Hi there!",
    enable_keymaps = false,  -- Don't use default <leader>ph and <leader>pt
  },
}
```

## Commands

After installation, the plugin provides the following user commands:

### `:NvimPluginHello`

Displays the configured greeting message using `vim.notify()`.

**Usage:**
```vim
:NvimPluginHello
" Shows: "Hello from nvim-plugin!" (or your custom greeting)
```

**In Lua:**
```lua
vim.cmd("NvimPluginHello")
```

**Customizing the greeting:**
```lua
require("nvim-plugin").setup({
  greeting = "Welcome! This is my custom greeting message."
})
```

### `:NvimPluginToggle`

Toggles the plugin's enabled/disabled state. This demonstrates stateful plugin behavior and provides user feedback.

**Usage:**
```vim
:NvimPluginToggle
" First call shows: "nvim-plugin disabled"
" Second call shows: "nvim-plugin enabled"
```

**The toggle persists during your Neovim session** but resets to enabled when you restart Neovim.

## Keymaps

By default, the plugin registers the following keymaps in normal mode:

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>ph` | `:NvimPluginHello` | Show plugin greeting |
| `<leader>pt` | `:NvimPluginToggle` | Toggle plugin state |

**Note on `<leader>`:**
- The default leader key in Neovim is `\` (backslash)
- Most users (and LazyVim) remap it to `<Space>`
- So `<leader>ph` typically means: press `Space`, then `p`, then `h`

### Disabling Default Keymaps

You can disable default keymaps and define your own in the plugin spec:

```lua
return {
  "yourusername/nvim-plugin",
  keys = {
    -- Define your own custom keys
    { "<C-h>", "<cmd>NvimPluginHello<cr>", desc = "Show greeting" },
    { "<C-t>", "<cmd>NvimPluginToggle<cr>", desc = "Toggle plugin" },
  },
  opts = {
    enable_keymaps = false,  -- Disables default <leader>ph and <leader>pt
  },
}
```

Or disable keymaps entirely and define them elsewhere:

```lua
-- In your plugin spec
return {
  "yourusername/nvim-plugin",
  opts = {
    enable_keymaps = false,
  },
}

-- Then in your keymaps config (e.g., ~/.config/nvim/lua/config/keymaps.lua)
vim.keymap.set("n", "<C-h>", "<cmd>NvimPluginHello<cr>", { desc = "Show greeting" })
vim.keymap.set("n", "<C-t>", "<cmd>NvimPluginToggle<cr>", { desc = "Toggle plugin" })
```

## Configuration

The plugin supports the following configuration options:

```lua
-- In your LazyVim plugin spec (~/.config/nvim/lua/plugins/nvim-plugin.lua)
return {
  "yourusername/nvim-plugin",
  opts = {
    -- Customize the greeting message shown by :NvimPluginHello
    -- Type: string
    -- Default: "Hello from nvim-plugin!"
    greeting = "Hello from nvim-plugin!",
    
    -- Enable or disable default keymaps (<leader>ph and <leader>pt)
    -- Type: boolean
    -- Default: true
    enable_keymaps = true,
  },
}
```

### Configuration Examples

#### Example 1: Use all defaults (simplest)
```lua
return {
  "yourusername/nvim-plugin",
  opts = {},
}
-- greeting: "Hello from nvim-plugin!"
-- enable_keymaps: true
```

#### Example 2: Custom greeting only
```lua
return {
  "yourusername/nvim-plugin",
  opts = {
    greeting = "Welcome to my custom plugin!",
  },
}
-- Uses default keymaps: <leader>ph and <leader>pt
```

#### Example 3: Disable default keymaps
```lua
return {
  "yourusername/nvim-plugin",
  opts = {
    enable_keymaps = false,
  },
}
-- Commands still work, but no default keymaps
-- Define your own keymaps as needed
```

#### Example 4: Full customization
```lua
return {
  "yourusername/nvim-plugin",
  opts = {
    greeting = "Hi there! Plugin is ready.",
    enable_keymaps = false,
  },
}
-- Then define custom keymaps in the keys section if desired
```

## Usage Guide

### Getting Started

1. **Install the plugin** using one of the installation methods above
2. **Restart Neovim** or reload the plugin:
   ```vim
   :Lazy reload nvim-plugin
   ```
3. **Test the greeting command:**
   ```vim
   :NvimPluginHello
   ```
   You should see a notification with "Hello from nvim-plugin!"

4. **Test the toggle command:**
   ```vim
   :NvimPluginToggle
   ```
   You should see "nvim-plugin disabled", then "enabled" on the second call

5. **Test the keymaps** (if enabled):
   - Press `<Space>` + `p` + `h` for hello
   - Press `<Space>` + `p` + `t` for toggle

### Using with Different Leader Keys

If you've remapped your leader key to something other than space:

```lua
-- In your init.lua or config
vim.g.mapleader = ","  -- Set leader to comma
```

Then the keymaps become:
- `,ph` for hello
- `,pt` for toggle

### Checking If Keymaps Are Registered

To see if the plugin's keymaps are active:

```vim
:map <leader>ph
" Should show: n  <Space>ph   *@<Lua function>   Show plugin greeting

:map <leader>pt
" Should show: n  <Space>pt   *@<Lua function>   Toggle plugin state
```

### Using Commands from Lua Scripts

You can call the commands from Lua code:

```lua
-- Call the hello command
vim.cmd("NvimPluginHello")

-- Call the toggle command
vim.cmd("NvimPluginToggle")

-- Or use the API directly (not recommended, but possible)
require("nvim-plugin").setup({ greeting = "Dynamic greeting!" })
```

### Creating Your Own Wrapper Functions

You can create your own functions that use the plugin:

```lua
-- In your Neovim config
local function greet_and_toggle()
  vim.cmd("NvimPluginHello")
  vim.wait(1000)  -- Wait 1 second
  vim.cmd("NvimPluginToggle")
end

-- Create a keymap for your custom function
vim.keymap.set("n", "<leader>gt", greet_and_toggle, { desc = "Greet and toggle" })
```

## Troubleshooting

### Plugin commands not available

**Problem**: `:NvimPluginHello` shows "Not an editor command"

**Solutions:**
1. **Ensure plugin is configured:**
   - Check your LazyVim plugin spec has `opts = {}` (LazyVim automatically calls setup)
   - Or verify you have a `config = function()` that calls `require("nvim-plugin").setup()`
   
2. **Reload the plugin:**
   ```vim
   :Lazy reload nvim-plugin
   ```
   
3. **Check if plugin is loaded:**
   ```vim
   :Lazy
   ```
   Find `nvim-plugin` in the list - it should not show as "not loaded"

4. **Verify the plugin directory:**
   - If using local development, ensure the `dir` path is correct and absolute
   - Check that `lua/nvim-plugin/init.lua` exists in that directory

5. **Check for Lua errors:**
   ```vim
   :messages
   ```
   Look for any error messages about the plugin

### Keymaps not working

**Problem**: `<leader>ph` doesn't do anything

**Solutions:**
1. **Verify leader key:**
   ```vim
   :echo mapleader
   ```
   Should show a space (if using LazyVim default)

2. **Check if keymaps are enabled:**
   - Ensure `enable_keymaps` is not set to `false` in your config
   - Default is `true`, so if not specified, they should be enabled

3. **Check if keymap is registered:**
   ```vim
   :map <leader>ph
   ```
   Should show the mapping. If not, keymaps aren't being registered.

4. **Look for conflicts:**
   ```vim
   :verbose map <leader>ph
   ```
   Shows which plugin/config file set this keymap last

5. **Try the command directly:**
   ```vim
   :NvimPluginHello
   ```
   If this works but the keymap doesn't, it's a keymap registration issue

### Custom greeting not showing

**Problem**: Still seeing default greeting after configuration

**Solutions:**
1. **Verify syntax in your plugin spec:**
   ```lua
   return {
     "yourusername/nvim-plugin",
     opts = {
       greeting = "Custom message",  -- Correct
     },
   }
   ```
   Not:
   ```lua
   return {
     "yourusername/nvim-plugin",
     opts = {
       message = "Custom",  -- Wrong - should be "greeting"
     },
   }
   ```

2. **Restart Neovim:**
   - Changes to plugin configs often require a restart
   - Or use `:Lazy reload nvim-plugin`

3. **Check for typos:**
   - Option is `greeting` not `message` or `greetings`
   - Lua is case-sensitive

4. **Verify the config is being applied:**
   ```lua
   -- In your plugin spec, temporarily add:
   return {
     "yourusername/nvim-plugin",
     opts = {
       greeting = "Test message",
     },
     config = function(_, opts)
       print("Plugin setup called with:", vim.inspect(opts))
       require("nvim-plugin").setup(opts)
     end,
   }
   ```

### LazyVim lazy-loading issues

**Problem**: Plugin loads immediately instead of lazy-loading

**Solutions:**
1. **Use `keys` specification:**
   ```lua
   return {
     "yourusername/nvim-plugin",
     keys = {
       { "<leader>ph", "<cmd>NvimPluginHello<cr>", desc = "Show greeting" },
     },
     opts = {},
   }
   ```

2. **Don't use `lazy = false`:**
   ```lua
   return {
     "yourusername/nvim-plugin",
     lazy = false,  -- Remove this line for lazy-loading
     opts = {},
   }
   ```

3. **Check Lazy.nvim status:**
   ```vim
   :Lazy
   ```
   Look at when the plugin loaded (should be "on keys" if configured properly)

### Neovim version compatibility

**Problem**: Errors about unknown functions like `vim.keymap.set`

**Solutions:**
1. **Check your Neovim version:**
   ```vim
   :version
   ```
   Or from terminal:
   ```bash
   nvim --version
   ```

2. **This plugin requires Neovim 0.8+:**
   - `vim.keymap.set()` was added in Neovim 0.7
   - `vim.notify()` default behavior improved in 0.8
   - Upgrade if you're on an older version

3. **Upgrade Neovim:**
   - **Ubuntu/Debian:** Use the official PPA or AppImage
   - **macOS:** `brew upgrade neovim`
   - **Windows:** Download from [GitHub releases](https://github.com/neovim/neovim/releases)

### Plugin not found when using `dir`

**Problem**: Using local `dir` but plugin won't load

**Solutions:**
1. **Use absolute paths:**
   ```lua
   dir = "/home/user/projects/nvim-plugin",  -- Good (Linux/macOS)
   dir = "C:/Users/user/nvim-plugin",        -- Good (Windows, forward slashes)
   dir = "~/projects/nvim-plugin",           -- May not work - use full path
   ```

2. **Verify the path exists:**
   ```bash
   ls /path/to/nvim-plugin/lua/nvim-plugin/init.lua
   ```
   Should exist and be readable

3. **Check directory structure:**
   ```
   nvim-plugin/
   └── lua/
       └── nvim-plugin/
           └── init.lua
   ```

## Development

This is a minimal example project designed for learning. To use it as a reference:

### Setup for Learning

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/nvim-plugin.git
   cd nvim-plugin
   ```

2. **Examine the code structure:**
   ```
   nvim-plugin/
   ├── lua/
   │   └── nvim-plugin/
   │       └── init.lua      # Main plugin implementation (read this!)
   ├── README.md             # This file
   └── AGENTS.md             # Development guidelines
   ```

3. **Read `lua/nvim-plugin/init.lua`:**
   - Contains extensive inline comments
   - Explains the module pattern
   - Shows modern API usage with rationale
   - Demonstrates configuration handling
   - Includes state management example

4. **Test locally in Neovim:**
   - Add the plugin to your LazyVim config using `dir` (see Installation)
   - Make changes to `init.lua`
   - Reload with `:Lazy reload nvim-plugin`
   - Test your changes

### Experimentation Ideas

1. **Add a new command:**
   ```lua
   -- In init.lua, in the register_commands() function
   vim.api.nvim_create_user_command("NvimPluginInfo", function()
     vim.notify("nvim-plugin v1.0 - An example plugin", vim.log.levels.INFO)
   end, {
     desc = "Show plugin information",
   })
   ```

2. **Add a configuration option:**
   ```lua
   -- In default_config
   local default_config = {
     greeting = "Hello from nvim-plugin!",
     enable_keymaps = true,
     show_version = false,  -- New option
   }
   ```

3. **Create a multi-file structure:**
   ```
   lua/nvim-plugin/
   ├── init.lua          # Main entry point
   ├── config.lua        # Configuration handling
   ├── commands.lua      # Command definitions
   └── keymaps.lua       # Keymap registration
   ```

4. **Add Telescope integration:**
   ```lua
   -- Example: Create a Telescope picker
   vim.api.nvim_create_user_command("NvimPluginPick", function()
     require("telescope.builtin").find_files({
       prompt_title = "Plugin Files",
       cwd = vim.fn.stdpath("data") .. "/lazy/nvim-plugin",
     })
   end, {})
   ```

### Contributing

This is an educational example. Feel free to:
- Fork and modify for your own learning
- Use it as a template for your own plugins
- Share with others learning Neovim plugin development

## Learning Resources

To learn more about Neovim plugin development:

### Official Documentation
- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html) - Official Lua integration guide
- [Neovim API Documentation](https://neovim.io/doc/user/api.html) - Complete API reference
- [LazyVim Documentation](https://www.lazyvim.org/) - LazyVim-specific patterns

### Example Plugins to Study
- [mini.nvim](https://github.com/echasnovski/mini.nvim) - Collection of minimal, independent plugins
- [Comment.nvim](https://github.com/numToStr/Comment.nvim) - Simple, well-structured plugin
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Advanced plugin architecture

### Community Resources
- [r/neovim](https://reddit.com/r/neovim) - Active community
- [Neovim Discourse](https://neovim.discourse.group/) - Official forums
- [awesome-neovim](https://github.com/rockerBOO/awesome-neovim) - Curated list of plugins

## Key Concepts Demonstrated

This plugin demonstrates the following Neovim plugin development concepts:

### 1. Module Pattern
Using a Lua table (`M`) to export public functions:
```lua
local M = {}
function M.setup(opts)
  -- initialization
end
return M
```

### 2. Setup Function
Standard pattern for plugin initialization:
```lua
require("nvim-plugin").setup({ options })
```

### 3. Configuration Merging
Using `vim.tbl_deep_extend()` to merge user config with defaults:
```lua
local config = vim.tbl_deep_extend("force", defaults, user_opts or {})
```

### 4. Modern Command API
`vim.api.nvim_create_user_command()` instead of legacy `vim.cmd()`:
```lua
vim.api.nvim_create_user_command("CommandName", function()
  -- command logic
end, { desc = "Description" })
```

### 5. Modern Keymap API
`vim.keymap.set()` instead of deprecated alternatives:
```lua
vim.keymap.set("n", "<leader>key", function()
  -- keymap logic
end, { desc = "Description" })
```

### 6. User Notifications
`vim.notify()` for displaying messages:
```lua
vim.notify("Message", vim.log.levels.INFO)
```

### 7. State Management
Maintaining runtime state separate from configuration:
```lua
local state = { enabled = true }
```

### 8. LazyVim Integration
Proper setup for lazy-loading and configuration via LazyVim specs

### 9. Educational Comments
Extensive inline documentation explaining:
- Why each pattern is used
- What alternatives exist
- How things work under the hood

## License

MIT

---

**Note**: Replace `yourusername` with your actual GitHub username when publishing the plugin.
