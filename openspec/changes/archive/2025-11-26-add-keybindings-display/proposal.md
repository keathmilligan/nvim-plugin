# Change: Add Keybindings Display Command

## Why
Users need a way to view all registered keybindings for the plugin in an organized, readable format. Currently, keybindings are only documented in the README or can be checked via `:map` commands, which is not user-friendly for discovering available shortcuts.

## What Changes
- Add a new command `:NvimPluginKeybindings` that opens a new buffer and displays all registered keybindings
- Add a default keymap `<leader>pk` (Plugin Keybindings) to invoke this command
- Display keybindings in a formatted, readable layout showing key combinations, commands, and descriptions
- Include both default keymaps (when enabled) and the keybindings display command itself in the output

## Impact
- Affected specs: `plugin-core`
- Affected code: `lua/nvim-plugin/init.lua` (register new command, add new keymap, implement buffer creation and formatting logic)
- Documentation: README will need to document the new command and keymap
