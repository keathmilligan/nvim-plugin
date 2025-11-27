# Implementation Tasks

## 1. Create Floating Sidebar Module
- [x] 1.1 Create `lua/nvim-plugin/floating-sidebar.lua` file
- [x] 1.2 Implement module state management (namespace, buffer handle, window handle)
- [x] 1.3 Create buffer configuration function for scratch floating buffer
- [x] 1.4 Implement floating window creation with configuration (position, size, borders, zindex)
- [x] 1.5 Set up window-local options for floating UI (disable UI elements, set minimal style)

## 2. Implement Extmark-Based Rendering
- [x] 2.1 Create render function using `nvim_buf_set_extmark` for virtual text
- [x] 2.2 Design content layout (header, plugin info, keybindings list)
- [x] 2.3 Implement namespace clearing before each render
- [x] 2.4 Add optional highlight groups for visual polish (title, sections)
- [x] 2.5 Set buffer to non-modifiable after rendering

## 3. Implement Keymap Isolation
- [x] 3.1 Create buffer-local keymaps for floating sidebar actions (q, <Esc>, <CR>)
- [x] 3.2 Disable insert mode keys (i, a, o, I, A, O, s, S)
- [x] 3.3 Disable edit command keys to prevent accidental modifications
- [x] 3.4 Add descriptive comments explaining keymap isolation pattern

## 4. Implement Public API Functions
- [x] 4.1 Implement `open()` function with focus-if-exists logic
- [x] 4.2 Implement `close()` function with validation
- [x] 4.3 Implement `toggle()` function
- [x] 4.4 Export module table with public functions

## 5. Integrate into Main Plugin
- [x] 5.1 Add `require("nvim-plugin.floating-sidebar")` to `init.lua`
- [x] 5.2 Register `:NvimPluginFloatingSidebar` command in `register_commands()`
- [x] 5.3 Register `:NvimPluginFloatingSidebarOpen` command
- [x] 5.4 Register `:NvimPluginFloatingSidebarClose` command
- [x] 5.5 Add `<leader>pf` keymap in `register_keymaps()` (respects `enable_keymaps` config)
- [x] 5.6 Update `registered_keymaps` table to include `<leader>pf` entry

## 6. Educational Documentation
- [x] 6.1 Add comprehensive module-level comments explaining floating window pattern
- [x] 6.2 Document buffer configuration options and their purposes
- [x] 6.3 Document floating window configuration (relative, width, height, col, row, anchor, style, border, zindex)
- [x] 6.4 Explain extmark-based rendering vs traditional buffer line updates
- [x] 6.5 Document differences between floating and split sidebar implementations
- [x] 6.6 Add inline comments explaining critical decisions and Neovim API usage

## 7. Validation
- [x] 7.1 Test opening floating sidebar (`:NvimPluginFloatingSidebarOpen`)
- [x] 7.2 Test closing floating sidebar (q key, <Esc> key, `:NvimPluginFloatingSidebarClose`)
- [x] 7.3 Test toggle behavior (`:NvimPluginFloatingSidebar`, `<leader>pf`)
- [x] 7.4 Verify keymap isolation (insert mode disabled, edit commands disabled)
- [x] 7.5 Verify both sidebars can coexist (open floating sidebar while split sidebar is open)
- [x] 7.6 Verify content renders correctly with extmarks
