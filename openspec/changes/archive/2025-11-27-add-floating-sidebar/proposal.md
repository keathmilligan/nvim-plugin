# Change: Add Floating Window Sidebar Implementation

## Why
The current sidebar implementation uses a vertical split window which integrates with Neovim's window layout system. A floating window sidebar demonstrates an alternative approach that provides more direct control over rendering using extmarks and virtual text, offering a UI that behaves more like a modal overlay rather than a buffer-integrated window. This educational example shows advanced techniques for building floating UI panels.

## What Changes
- Add new `floating-sidebar.lua` module with floating window implementation
- Implement extmark-based rendering system for complete visual control
- Create new commands `:NvimPluginFloatingSidebar`, `:NvimPluginFloatingSidebarOpen`, `:NvimPluginFloatingSidebarClose`
- Add keymap `<leader>pf` to toggle floating sidebar (when keymaps enabled)
- Keep existing vertical split sidebar unchanged (both implementations coexist for educational comparison)

## Impact
- Affected specs: `sidebar` (adding new floating window variant)
- Affected code: New file `lua/nvim-plugin/floating-sidebar.lua`, additions to `lua/nvim-plugin/init.lua` for command/keymap registration
- No breaking changes - existing sidebar functionality remains unchanged
