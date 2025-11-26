# Change: Add Commands Viewer

## Why
Currently, the plugin provides `NvimPluginAllKeybindings` to discover all keybindings, but there's no equivalent for discovering ex-commands (`:...` style commands). Users need a way to programmatically discover all available commands from Neovim core, plugins, and user configuration to learn what commands are available in their environment.

**Critical limitation:** `vim.api.nvim_get_commands()` and `vim.api.nvim_buf_get_commands()` only return **user-defined** commands (created via `:command` or `nvim_create_user_command`). They do NOT return Neovim's ~539 built-in ex-commands like `:help`, `:quit`, `:write`, `:substitute`, etc. To provide complete command discovery, we must parse Neovim's runtime `doc/index.txt` file (similar to how the keybindings viewer parses built-in keybindings).

## What Changes
- Add a new `:NvimPluginAllCommands` command that opens a buffer displaying all discovered commands
- Add programmatic command discovery using:
  - `vim.api.nvim_get_commands({})` for global user-defined commands
  - `vim.api.nvim_buf_get_commands(0, {})` for buffer-local user-defined commands
  - **Parsing `doc/index.txt`** to extract Neovim's ~539 built-in ex-commands
- Add a default keymap `<leader>pc` to invoke the commands viewer (when `enable_keymaps` is true)
- Format the display with clear columns showing command name, source indicator, attributes, and description
- Include educational comments explaining how to query Neovim's command state and why parsing is necessary
- Display header explaining the difference between built-in and user-defined commands

## Impact
- Affected specs: `plugin-core`
- Affected code: `lua/nvim-plugin/init.lua`
- New capability: Comprehensive command discovery (built-in + user-defined)
- User-facing: One new command, one new default keymap (if enabled)
- Educational value: Demonstrates both API usage and documentation parsing for complete discovery
- **BREAKING**: None (purely additive feature)
