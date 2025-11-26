# Implementation Tasks

## 1. Core Implementation
- [x] 1.1 Create helper function to query all keymaps using `vim.api.nvim_get_keymap()` and `vim.api.nvim_buf_get_keymap()`
- [x] 1.2 Create helper function to filter out internal/unnamed mappings
- [x] 1.3 Create helper function to format keybindings grouped by mode
- [x] 1.4 Create function to display formatted keybindings in a new buffer
- [x] 1.5 Register `:NvimPluginAllKeybindings` command
- [x] 1.6 Add `<leader>pa` keymap (respecting `enable_keymaps` config)
- [x] 1.7 Update `registered_keymaps` table to include the new `<leader>pa` keymap

## 2. Documentation
- [x] 2.1 Add educational inline comments explaining keymap query APIs
- [x] 2.2 Add comments explaining mode abbreviations (n, i, v, etc.)
- [x] 2.3 Add comments explaining buffer format and filtering logic

## 3. Validation
- [x] 3.1 Manually test `:NvimPluginAllKeybindings` command in Neovim
- [x] 3.2 Verify `<leader>pa` keymap works when keymaps are enabled
- [x] 3.3 Verify command still works when `enable_keymaps = false`
- [x] 3.4 Check buffer displays keybindings from multiple sources (core, plugins, user)
- [x] 3.5 Verify mode grouping is clear and readable
