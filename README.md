# nvim-plugin

A minimal example Neovim plugin demonstrating modern plugin development with LazyVim integration.

## Features

- **Command Registration**: Shows how to create user commands with `vim.api.nvim_create_user_command()`
- **Keymap Registration**: Demonstrates `vim.keymap.set()` with configurable keybindings
- **State Management**: Example of maintaining plugin state during runtime
- **Keybindings Viewer**: Display plugin-specific keybindings and ALL Neovim keybindings (built-in + registered)
- **Commands Viewer**: Display ALL Neovim commands (built-in core commands + user-defined commands)
- **Documentation Parsing**: Demonstrates programmatic parsing of Neovim's runtime help files

## Requirements

- Neovim 0.8+
- LazyVim (or similar plugin manager)

## Quick Start

Add to your LazyVim config:
```lua
return {
  "yourusername/nvim-plugin",
  opts = {},
}
```

Try the default keymaps:
- `<leader>ph` - Show greeting
- `<leader>pt` - Toggle plugin state
- `<leader>pk` - View plugin keybindings
- `<leader>pa` - View ALL Neovim keybindings (built-in + registered)
- `<leader>pc` - View ALL Neovim commands (built-in + user-defined)

## Installation

Create `~/.config/nvim/lua/plugins/nvim-plugin.lua`:

```lua
return {
  "yourusername/nvim-plugin",
  opts = {},
}
```

### Custom Configuration

```lua
return {
  "yourusername/nvim-plugin",
  opts = {
    greeting = "Custom greeting!",
    enable_keymaps = true,  -- Set to false to disable default keymaps
  },
}
```

### Local Development

```lua
return {
  dir = "/absolute/path/to/nvim-plugin",
  opts = {},
}
```

### Custom Keymaps

```lua
return {
  "yourusername/nvim-plugin",
  keys = {
    { "<leader>h", "<cmd>NvimPluginHello<cr>", desc = "Plugin greeting" },
    { "<leader>t", "<cmd>NvimPluginToggle<cr>", desc = "Toggle plugin" },
  },
  opts = {
    enable_keymaps = false,  -- Disable defaults
  },
}
```

## Commands

| Command | Description |
|---------|-------------|
| `:NvimPluginHello` | Display the configured greeting message |
| `:NvimPluginToggle` | Toggle plugin enabled/disabled state (session-only) |
| `:NvimPluginKeybindings` | Open buffer showing plugin keybindings |
| `:NvimPluginAllKeybindings` | Open buffer showing ALL Neovim keybindings |
| `:NvimPluginAllCommands` | Open buffer showing ALL Neovim commands |

### Keybindings Viewer (`:NvimPluginAllKeybindings`)

Displays comprehensive keybinding information from all sources:
- **Built-in Commands**: Parses Neovim's `doc/index.txt` (~1,264 core commands like dd, yy, gg, `<C-w>h`)
- **Registered Keymaps**: Queries `vim.api.nvim_get_keymap()` for plugin and user-defined keymaps
- **Source Indicators**: `[C]` Core built-in, `[P]` Plugin/User registered, `[B]` Buffer-local
- **Mode Grouping**: Organized by mode (Normal, Insert, Visual, etc.)
- **Plugin Detection**: Identifies which plugin registered each keymap
- **Searchable**: Use `/` to find specific keys or commands

### Commands Viewer (`:NvimPluginAllCommands`)

Displays comprehensive command information from all sources:
- **Built-in Commands**: Parses Neovim's `doc/index.txt` (~539 core ex-commands like `:help`, `:quit`, `:write`)
- **User-defined Commands**: Queries `vim.api.nvim_get_commands()` for global plugin and user commands
- **Buffer-local Commands**: Queries `vim.api.nvim_buf_get_commands()` for buffer-specific commands
- **Source Indicators**: `[C]` Core built-in, `[G]` Global user-defined, `[B]` Buffer-local
- **Searchable**: Use `/` to find specific commands

## Default Keymaps

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>ph` | `:NvimPluginHello` | Show greeting |
| `<leader>pt` | `:NvimPluginToggle` | Toggle state |
| `<leader>pk` | `:NvimPluginKeybindings` | Show plugin keybindings |
| `<leader>pa` | `:NvimPluginAllKeybindings` | Show all keybindings |
| `<leader>pc` | `:NvimPluginAllCommands` | Show all commands |

**Note**: `<leader>` is typically `<Space>` in LazyVim (default is `\`)

## Configuration Options

```lua
return {
  "yourusername/nvim-plugin",
  opts = {
    greeting = "Hello from nvim-plugin!",  -- Custom greeting message
    enable_keymaps = true,                  -- Enable/disable default keymaps
  },
}
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `greeting` | string | `"Hello from nvim-plugin!"` | Message shown by `:NvimPluginHello` |
| `enable_keymaps` | boolean | `true` | Enable default `<leader>p*` keymaps |

## Usage

After installation, reload with `:Lazy reload nvim-plugin` and try:
- `:NvimPluginHello` or `<leader>ph` - Show greeting
- `:NvimPluginToggle` or `<leader>pt` - Toggle state
- `:NvimPluginKeybindings` or `<leader>pk` - Show plugin keybindings
- `:NvimPluginAllKeybindings` or `<leader>pa` - Show all keybindings
- `:NvimPluginAllCommands` or `<leader>pc` - Show all commands

## Troubleshooting

### Commands not available
- Run `:Lazy reload nvim-plugin`
- Verify `opts = {}` is in your plugin spec
- Check `:messages` for errors
- Ensure `lua/nvim-plugin/init.lua` exists

### Keymaps not working
- Verify leader key: `:echo mapleader`
- Check registration: `:map <leader>ph`
- Ensure `enable_keymaps` is not `false`
- Try command directly: `:NvimPluginHello`

### Custom config not applied
- Restart Neovim or `:Lazy reload nvim-plugin`
- Check option spelling: `greeting` (not `message`)
- Use absolute paths for `dir` in local development

## Development

This is an educational example demonstrating plugin fundamentals.

### Structure
```
nvim-plugin/
├── lua/nvim-plugin/init.lua  # Main plugin (well-commented)
└── README.md                  # This file
```

### Key Concepts Demonstrated
- **Module Pattern**: Lua table exports with `M.setup()`
- **Configuration Merging**: `vim.tbl_deep_extend()` for user config
- **Modern APIs**: `vim.api.nvim_create_user_command()`, `vim.keymap.set()`, `vim.notify()`
- **State Management**: Runtime state separate from config
- **LazyVim Integration**: Lazy-loading patterns and `opts` convention
- **Documentation Parsing**: Programmatic parsing of Neovim's runtime `doc/index.txt` help file
- **API Limitations**: Understanding what's queryable (user-defined commands/keymaps) vs. built-in (requires parsing)
- **Buffer Management**: Creating scratch buffers for displaying formatted information
- **Plugin Detection**: Extracting plugin names from keymap metadata

### Learning Resources
- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html) - Official Lua integration
- [Neovim API Docs](https://neovim.io/doc/user/api.html) - Complete API reference
- [mini.nvim](https://github.com/echasnovski/mini.nvim) - Excellent plugin examples

## License

MIT

---

**Note**: This is an educational example project. See `lua/nvim-plugin/init.lua` for extensively commented code explaining each concept.
