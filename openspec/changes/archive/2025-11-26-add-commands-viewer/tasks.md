## 1. Implementation

- [x] 1.1 Create `parse_builtin_commands()` helper function to parse `doc/index.txt` and extract built-in ex-commands
- [x] 1.2 Add caching for parsed built-in commands (parse once per session for performance)
- [x] 1.3 Create `get_all_commands()` helper function using `vim.api.nvim_get_commands({})` and `vim.api.nvim_buf_get_commands(0, {})`
- [x] 1.4 Merge built-in and user-defined commands in `get_all_commands()`
- [x] 1.5 Create `format_all_commands()` helper function to format commands into readable text lines with source indicators
- [x] 1.6 Create `show_all_commands()` function to create buffer and display formatted commands
- [x] 1.7 Register `:NvimPluginAllCommands` user command in `register_commands()`
- [x] 1.8 Add `<leader>pc` keymap in `register_keymaps()` (when `enable_keymaps` is true)
- [x] 1.9 Update `registered_keymaps` table to include the new `<leader>pc` keymap
- [x] 1.10 Add educational comments explaining:
  - Why `nvim_get_commands()` only returns user-defined commands
  - Why parsing `doc/index.txt` is necessary for built-in commands
  - The structure of command data returned by Neovim APIs
  - The format of ex-command entries in `doc/index.txt`

## 2. Validation

- [x] 2.1 Manually test `:NvimPluginAllCommands` displays both built-in and user-defined commands
- [x] 2.2 Verify built-in commands like `:help`, `:quit`, `:write` are shown
- [x] 2.3 Verify user-defined commands (plugin commands, custom commands) are shown
- [x] 2.4 Verify `<leader>pc` keymap works when keymaps are enabled
- [x] 2.5 Verify command still works when `enable_keymaps = false`
- [x] 2.6 Test that both global and buffer-local user-defined commands are discovered
- [x] 2.7 Verify source indicators clearly distinguish built-in vs. user-defined commands
- [x] 2.8 Check that the header explains the data sources and approach
- [x] 2.9 Verify educational comments are clear and helpful
- [x] 2.10 Confirm parsing handles `doc/index.txt` format correctly (e.g., `:h[elp]` abbreviation syntax)
