# Implementation Tasks

## 1. Research and Design
- [x] 1.1 Research available APIs and approaches for discovering built-in Neovim keybindings
- [x] 1.2 Test `vim.cmd('nmap')` and similar commands to see if they expose more bindings than `vim.api.nvim_get_keymap()`
- [x] 1.3 Investigate parsing Neovim help files (`:help index.txt`) for built-in command reference
- [x] 1.4 Document findings and select the best approach (hardcoded reference vs. runtime discovery vs. help parsing)
- [x] 1.5 Create a prototype to validate the chosen approach

## 2. Implementation
- [x] 2.1 Implement built-in keybindings discovery using the selected approach
- [x] 2.2 Create data structure to store built-in keybindings with metadata (mode, description, category)
- [x] 2.3 Update `get_all_keymaps()` to merge built-in keybindings with registered keymaps
- [x] 2.4 Add source tracking to distinguish built-in vs. plugin vs. user keybindings
- [x] 2.5 Update `filter_keymaps()` to handle built-in keybindings appropriately

## 3. Display Enhancements
- [x] 3.1 Update `format_all_keybindings()` to add visual indicators for keybinding sources
- [x] 3.2 Add legend or header explaining the different keybinding sources (built-in, plugin, user)
- [x] 3.3 Consider grouping or sorting options (by source, by key, by description)
- [x] 3.4 Update column widths and formatting to accommodate new metadata

## 4. Documentation and Education
- [x] 4.1 Add inline comments explaining the limitations of `vim.api.nvim_get_keymap()`
- [x] 4.2 Document why built-in commands require special handling
- [x] 4.3 Add comments explaining the chosen discovery approach and its trade-offs
- [x] 4.4 Update buffer display header to explain what users are seeing
- [x] 4.5 Update README.md with information about the enhanced keybindings viewer

## 5. Testing and Validation
- [x] 5.1 Test in a minimal Neovim config to verify built-in keybindings are shown
- [x] 5.2 Test with LazyVim to ensure plugin keybindings are still shown correctly
- [x] 5.3 Verify visual indicators correctly distinguish between sources
- [x] 5.4 Confirm all modes (n, i, v, s, o, t, c) show appropriate built-in commands
- [x] 5.5 Check that filtering still works and doesn't hide important built-in commands
