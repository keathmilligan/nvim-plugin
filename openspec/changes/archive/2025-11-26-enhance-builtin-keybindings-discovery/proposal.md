# Change: Enhance Built-in Keybindings Discovery

## Why
The plugin currently shows registered keybindings from plugins and user config using `vim.api.nvim_get_keymap()`, but this API only returns **explicitly registered** keymaps. Many active bindings—especially core Neovim commands like `<C-w>h/j/k/l` (window navigation), `dd` (delete line), `gg` (go to top), etc.—are handled internally by Neovim's command processor and are not exposed through the keymap registration APIs. Users need a comprehensive view of ALL active keybindings to understand what keys are available or already bound in their session.

## What Changes
- Research and document lower-level APIs or alternative approaches to discover built-in Neovim keybindings that are not registered via the keymap system
- Enhance the `show_all_keybindings()` function to include built-in Neovim commands alongside registered keymaps
- Add clear visual indicators to distinguish between:
  - Built-in Neovim commands (core editor functionality)
  - Plugin-registered keymaps (from plugins like telescope, lsp, etc.)
  - User-defined keymaps (from config files)
- Update educational comments to explain the limitations of `vim.api.nvim_get_keymap()` and how the enhanced discovery works
- Document the approach in the display buffer so users understand what they're seeing

## Impact
- Affected specs: `global-keybindings`
- Affected code: `lua/nvim-plugin/init.lua` (functions: `get_all_keymaps()`, `filter_keymaps()`, `format_all_keybindings()`, `show_all_keybindings()`)
- User benefit: Complete visibility into ALL active keybindings, not just registered ones
- Educational value: Teaches users about Neovim's built-in commands and the distinction between registered vs. internal keybindings

## Technical Considerations
Built-in Neovim keybindings are not available through standard keymap APIs because they are handled internally by the command processor. However, they ARE comprehensively documented in Neovim's runtime help files.

**Research Findings:**
- Neovim ships with `doc/index.txt` containing ~1,264 documented keybinding entries across all modes
- This file is available at runtime via `vim.api.nvim_get_runtime_file('doc/index.txt', false)`
- The format is structured and parseable with consistent patterns like `|tag|\t\tkey\t\tdescription`
- Testing confirms that operators like `dd`, `yy`, window commands like `<C-w>h`, and motions like `gg` are NOT in `vim.api.nvim_get_keymap()` but ARE documented in index.txt

**Chosen Approach: Programmatic Parsing of index.txt**
Parse the runtime index.txt help file to extract built-in keybindings, then merge with registered keymaps. This approach:
- Uses the **authoritative source** (Neovim's own documentation)
- Stays **automatically up-to-date** with the installed Neovim version
- Avoids outdated/incorrect published documentation
- Is **programmatically discoverable** rather than hardcoded
- Works with any Neovim version without manual maintenance
