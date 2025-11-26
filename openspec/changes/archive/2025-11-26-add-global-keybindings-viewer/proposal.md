# Change: Add Global Keybindings Viewer

## Why
Users need a way to discover and inspect ALL keybindings available in their Neovim session—not just the plugin's own keymaps. Currently, `:NvimPluginKeybindings` only shows this plugin's keybindings, which is limited for learning and troubleshooting. A comprehensive viewer would show keybindings from all plugins, Neovim core, and user configurations, grouped by mode (normal, insert, visual, etc.).

## What Changes
- Add a new command `:NvimPluginAllKeybindings` that queries all registered keymaps across all modes
- Add a new keymap `<leader>pa` to invoke the global keybindings viewer
- Display keybindings in a buffer grouped by mode with columns for: key, command/action, and description
- Include all modes (normal, insert, visual, select, operator-pending, terminal, command-line)
- Filter out internal/unnamed mappings to keep output focused on user-relevant bindings
- Add educational comments explaining how to query Neovim's keymap state programmatically

## Impact
- **Affected specs**: 
  - `global-keybindings` (new capability)
  - `plugin-core` (modified to add new command and keymap)
- **Affected code**: 
  - `lua/nvim-plugin/init.lua` (add new command, keymap, and helper functions)
