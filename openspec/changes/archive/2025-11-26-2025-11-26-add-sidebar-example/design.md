# Design: Example Sidebar Implementation

## Architecture Overview

The sidebar feature will be implemented as a self-contained module within the existing plugin structure. It follows the battle-tested pattern used by nvim-tree, neo-tree, and aerial.

## Component Design

### 1. Module Structure
```
lua/nvim-plugin/
  init.lua          (main plugin - adds sidebar commands/keymaps)
  sidebar.lua       (new - sidebar implementation)
```

**Rationale**: Separate module keeps concerns isolated while remaining simple enough for educational purposes.

### 2. State Management

The sidebar module will maintain minimal state:
- `sidebar_buf`: Buffer handle (number or nil)
- `sidebar_win`: Window handle (number or nil)
- `ns`: Namespace for highlights/extmarks

**Rationale**: Minimal state reduces complexity while enabling open/close/toggle functionality.

### 3. Buffer Configuration

The sidebar buffer will be configured as:
```lua
buftype = "nofile"       -- Not associated with a file
bufhidden = "wipe"       -- Delete buffer when hidden
swapfile = false         -- No swap file needed
buflisted = false        -- Don't show in buffer list
modifiable = false       -- Read-only (set to true only when updating)
readonly = true          -- Can't edit
filetype = "nvim-plugin-sidebar"  -- Custom filetype for potential syntax
```

**Rationale**: These options create a non-editable, application-like buffer that doesn't interfere with normal editing workflows.

### 4. Window Configuration

The sidebar window will be configured as:
```lua
number = false           -- No line numbers
relativenumber = false   -- No relative numbers
spell = false            -- No spell checking
signcolumn = "no"        -- No sign column
foldcolumn = "0"         -- No fold column
winfixwidth = true       -- Prevents resizing with <C-w>=
sidescrolloff = 0        -- No side scroll offset
scrolloff = 0            -- No scroll offset
cursorline = true        -- Highlight current line (optional nice touch)
wrap = false             -- No line wrapping
```

**Rationale**: These options create a clean, sidebar-like appearance that feels distinct from editing windows.

### 5. Keymap Isolation

The sidebar will define buffer-local keymaps:
- `q` - Close sidebar
- `<CR>` - Select item (placeholder for educational purposes)
- `r` - Refresh sidebar content

All insert mode keys (`i`, `a`, `o`, etc.) will be mapped to `<Nop>` to prevent accidental editing.

Common edit commands (`dd`, `yy`, `p`, etc.) will also be mapped to `<Nop>`.

**Rationale**: Complete keymap isolation prevents users from accidentally entering edit mode or executing edit commands, making the sidebar feel like a true UI panel.

### 6. Content Rendering

The sidebar will display:
```
  nvim-plugin Sidebar
  ===================

  Plugin Keybindings:
  <leader>ph  - Show greeting
  <leader>pt  - Toggle state
  <leader>pk  - Show keybindings
  <leader>pa  - Show all keybindings
  <leader>pc  - Show all commands
  <leader>ps  - Toggle sidebar

  Sidebar Commands:
  q     - Close sidebar
  <CR>  - Select (demo)
  r     - Refresh
```

**Rationale**: Shows real plugin data while demonstrating how to render dynamic content. Keeps it simple and educational.

### 7. Public API

The sidebar module will export:
```lua
M.open()    -- Open sidebar (create if needed, or focus if exists)
M.close()   -- Close sidebar window
M.toggle()  -- Toggle sidebar open/close
```

**Rationale**: Simple, clear API that matches user expectations from other sidebar plugins.

### 8. Command Integration

Three commands will be added to `init.lua`:
- `:NvimPluginSidebar` - Toggle (most common use case)
- `:NvimPluginSidebarOpen` - Explicit open
- `:NvimPluginSidebarClose` - Explicit close

**Rationale**: Mirrors the pattern used by professional plugins, provides both toggle and explicit open/close for different workflows.

### 9. Keymap Integration

One keymap will be added (when `enable_keymaps = true`):
- `<leader>ps` - Toggle sidebar

The `registered_keymaps` table in `init.lua` will be updated to include:
```lua
{ key = "<leader>ps", command = "NvimPluginSidebar", desc = "Toggle plugin sidebar" }
```

**Rationale**: Consistent with existing plugin keymap pattern (`<leader>p` prefix). The `s` suffix is mnemonic for "sidebar".

## Implementation Strategy

### Phase 1: Core Sidebar Module
1. Create `lua/nvim-plugin/sidebar.lua`
2. Implement buffer creation with proper options
3. Implement window creation with proper options
4. Implement open/close/toggle functions
5. Add comprehensive educational comments

### Phase 2: Content Rendering
1. Implement render function to display plugin keybindings
2. Make buffer modifiable for updates, then read-only again
3. Add refresh capability

### Phase 3: Keymap Isolation
1. Set up buffer-local keymaps (q, <CR>, r)
2. Disable insert mode keys
3. Disable edit command keys

### Phase 4: Integration
1. Update `init.lua` to require sidebar module
2. Add sidebar commands to `register_commands()`
3. Add sidebar keymap to `register_keymaps()`
4. Update `registered_keymaps` table

## Trade-offs

### Vertical Split vs. Floating Window
**Decision**: Use vertical split
- **Pros**: Matches real-world sidebar plugins, teaches window management, more stable/predictable
- **Cons**: Slightly more complex than floating window
- **Rationale**: Educational value and real-world applicability outweigh simplicity

### Dynamic Content vs. Static Content
**Decision**: Dynamic (show actual plugin keybindings)
- **Pros**: More useful, demonstrates data fetching/formatting
- **Cons**: Slightly more complex than static text
- **Rationale**: Shows practical example while remaining simple

### Separate Module vs. Inline in init.lua
**Decision**: Separate module
- **Pros**: Better organization, easier to understand, matches real-world patterns
- **Cons**: One additional file
- **Rationale**: Demonstrates proper code organization without significant complexity increase

## Testing Strategy

Manual testing checklist:
1. Open sidebar with `:NvimPluginSidebar` - should open on left
2. Try to edit content - should be prevented (read-only)
3. Try `i`, `a`, `o` - should do nothing (mapped to <Nop>)
4. Try `dd`, `yy` - should do nothing (mapped to <Nop>)
5. Press `q` - should close sidebar
6. Press `<leader>ps` - should toggle sidebar
7. Close other windows - sidebar should survive
8. Open multiple times - should reuse same buffer
9. Check width - should be fixed at 30 columns
10. Try `<C-w>=` - sidebar width should not change (winfixwidth)

## Documentation Strategy

Code comments will explain:
- Why each buffer option is set
- Why each window option is set
- How keymap isolation works
- State management pattern
- Common pitfalls and solutions

This follows the plugin's educational mission.
