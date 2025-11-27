# Sidebar Specification Delta

## ADDED Requirements

### Requirement: Floating Sidebar Module
The plugin SHALL provide a floating sidebar module that creates a persistent, application-like floating window sidebar panel using Neovim's floating window API with extmark-based rendering.

#### Scenario: Floating sidebar module can be required
- **WHEN** the main plugin requires the floating sidebar module
- **THEN** the module SHALL return a table with `open`, `close`, and `toggle` functions
- **AND** no errors SHALL be raised

#### Scenario: Floating sidebar module state management
- **WHEN** the floating sidebar module is loaded
- **THEN** it SHALL maintain state for the sidebar buffer handle
- **AND** it SHALL maintain state for the sidebar window handle
- **AND** it SHALL create a namespace for extmarks and virtual text

### Requirement: Floating Sidebar Buffer Configuration
The floating sidebar SHALL create a non-editable scratch buffer with configuration identical to the vertical split sidebar (buftype="nofile", bufhidden="wipe", etc.).

#### Scenario: Floating buffer is scratch and unlisted
- **WHEN** the floating sidebar buffer is created
- **THEN** the buffer SHALL have `buftype` set to "nofile"
- **AND** the buffer SHALL have `buflisted` set to false
- **AND** the buffer SHALL have `bufhidden` set to "wipe"
- **AND** the buffer SHALL not create a swapfile

#### Scenario: Floating buffer is read-only
- **WHEN** the floating sidebar buffer is created
- **THEN** the buffer SHALL have `modifiable` set to false (except during content updates)
- **AND** the buffer SHALL have `readonly` set to true
- **AND** users SHALL NOT be able to edit content through normal editing commands

#### Scenario: Floating buffer has custom filetype and name
- **WHEN** the floating sidebar buffer is created
- **THEN** the buffer SHALL be named "==NVIM-PLUGIN-FLOATING-SIDEBAR=="
- **AND** the buffer MAY set a custom filetype for syntax highlighting

### Requirement: Floating Window Configuration
The floating sidebar SHALL create a floating window using `nvim_open_win()` with configuration that makes it appear as a fixed-position overlay sidebar.

#### Scenario: Window is floating with fixed dimensions
- **WHEN** the floating sidebar window is created
- **THEN** it SHALL use `relative = "editor"` to position relative to the entire Neovim instance
- **AND** the width SHALL be set to 32 columns
- **AND** the height SHALL be calculated as `vim.o.lines - 4` (full height minus status/command line)
- **AND** the window SHALL be positioned at `col = 0` and `row = 0` (top-left corner)
- **AND** the window SHALL use `anchor = "NW"` (northwest anchor)

#### Scenario: Window has minimal floating style
- **WHEN** the floating sidebar window is created
- **THEN** it SHALL have `style = "minimal"` to disable standard UI elements
- **AND** it SHALL have `border = "single"` to display a single-line border
- **AND** it SHALL have `zindex = 40` to appear above normal windows but below command-line

#### Scenario: Window has no editor UI elements
- **WHEN** the floating sidebar window is created
- **THEN** line numbers SHALL be disabled (`number = false`)
- **AND** relative line numbers SHALL be disabled (`relativenumber = false`)
- **AND** spell checking SHALL be disabled (`spell = false`)
- **AND** sign column SHALL be disabled (`signcolumn = "no"`)
- **AND** fold column SHALL be disabled (`foldcolumn = "0"`)

#### Scenario: Window has cursor line highlighting
- **WHEN** the floating sidebar window is created
- **THEN** cursor line highlighting SHALL be enabled (`cursorline = true`)
- **AND** window highlight overrides MAY be set via `winhighlight` for visual polish

### Requirement: Extmark-Based Rendering
The floating sidebar SHALL use extmarks and virtual text for enhanced rendering control while maintaining base buffer lines for content.

#### Scenario: Render content using buffer lines
- **WHEN** the floating sidebar is rendered
- **THEN** base content SHALL be set using `nvim_buf_set_lines()`
- **AND** the content SHALL include header, plugin information, and keybinding list
- **AND** the content SHALL be well-formatted and readable

#### Scenario: Enhance rendering with extmarks
- **WHEN** the floating sidebar is rendered
- **THEN** the namespace SHALL be cleared using `nvim_buf_clear_namespace()` before rendering
- **AND** extmarks MAY be added using `nvim_buf_set_extmark()` for virtual text decorations
- **AND** extmarks MAY use `virt_text` parameter for inline icons or enhanced formatting
- **AND** extmarks MAY use highlight groups for visual distinction

#### Scenario: Content is read-only
- **WHEN** the floating sidebar content is rendered
- **THEN** the buffer SHALL be temporarily set to modifiable
- **AND** the content SHALL be updated using `nvim_buf_set_lines()`
- **AND** extmarks SHALL be applied for visual enhancements
- **AND** the buffer SHALL be set back to non-modifiable
- **AND** users SHALL NOT be able to edit the content

### Requirement: Floating Sidebar Keymap Isolation
The floating sidebar SHALL define custom buffer-local keymaps and disable normal editing keymaps, identical to the vertical split sidebar pattern.

#### Scenario: Custom floating sidebar keymaps
- **WHEN** the floating sidebar buffer is created
- **THEN** the `q` key SHALL be mapped to close the floating sidebar
- **AND** the `<Esc>` key SHALL be mapped to close the floating sidebar
- **AND** the `<CR>` key SHALL be mapped to a placeholder action (demo/educational)
- **AND** all mappings SHALL be buffer-local with `nowait = true`

#### Scenario: Insert mode keys disabled
- **WHEN** the floating sidebar buffer is created
- **THEN** insert mode trigger keys SHALL be mapped to `<Nop>`
- **AND** this SHALL include at minimum: `i`, `a`, `o`, `I`, `A`, `O`, `s`, `S`
- **AND** users SHALL NOT be able to enter insert mode accidentally

#### Scenario: Edit command keys disabled
- **WHEN** the floating sidebar buffer is created
- **THEN** common edit commands SHALL be mapped to `<Nop>` in normal mode
- **AND** users SHALL NOT be able to execute edit commands

### Requirement: Floating Sidebar Open Function
The floating sidebar module SHALL provide an `open()` function that creates or focuses the floating sidebar.

#### Scenario: Open floating sidebar when not already open
- **WHEN** `open()` is called and the floating sidebar window does not exist
- **THEN** the floating sidebar buffer SHALL be created or reused
- **AND** the floating sidebar window SHALL be created with proper floating window configuration
- **AND** the floating sidebar content SHALL be rendered
- **AND** the floating sidebar keymaps SHALL be configured
- **AND** the floating sidebar window SHALL be focused

#### Scenario: Open floating sidebar when already open
- **WHEN** `open()` is called and the floating sidebar window already exists and is valid
- **THEN** the existing floating sidebar window SHALL be focused
- **AND** no new buffer or window SHALL be created

### Requirement: Floating Sidebar Close Function
The floating sidebar module SHALL provide a `close()` function that closes the floating sidebar window.

#### Scenario: Close floating sidebar when open
- **WHEN** `close()` is called and the floating sidebar window exists and is valid
- **THEN** the floating sidebar window SHALL be closed using `nvim_win_close()`
- **AND** the window state SHALL be cleared (set to nil)
- **AND** the buffer SHALL NOT be deleted (it may be reused later)

#### Scenario: Close floating sidebar when already closed
- **WHEN** `close()` is called and the floating sidebar window does not exist or is invalid
- **THEN** no errors SHALL be raised
- **AND** the function SHALL complete silently

### Requirement: Floating Sidebar Toggle Function
The floating sidebar module SHALL provide a `toggle()` function that alternates between opening and closing the floating sidebar.

#### Scenario: Toggle floating sidebar from closed to open
- **WHEN** `toggle()` is called and the floating sidebar window is closed or invalid
- **THEN** the floating sidebar SHALL open as if `open()` was called

#### Scenario: Toggle floating sidebar from open to closed
- **WHEN** `toggle()` is called and the floating sidebar window is open and valid
- **THEN** the floating sidebar SHALL close as if `close()` was called

### Requirement: Floating Sidebar Commands
The plugin SHALL provide user commands for controlling the floating sidebar, independent of the vertical split sidebar commands.

#### Scenario: Floating sidebar toggle command
- **WHEN** `:NvimPluginFloatingSidebar` is executed
- **THEN** the floating sidebar SHALL toggle between open and closed states
- **AND** the command SHALL have the description "Toggle floating plugin sidebar"

#### Scenario: Floating sidebar explicit open command
- **WHEN** `:NvimPluginFloatingSidebarOpen` is executed
- **THEN** the floating sidebar SHALL open (or focus if already open)
- **AND** the command SHALL have the description "Open floating plugin sidebar"

#### Scenario: Floating sidebar explicit close command
- **WHEN** `:NvimPluginFloatingSidebarClose` is executed
- **THEN** the floating sidebar SHALL close if open
- **AND** no errors SHALL occur if the floating sidebar is already closed
- **AND** the command SHALL have the description "Close floating plugin sidebar"

### Requirement: Floating Sidebar Keymap
The plugin SHALL register a default keymap for toggling the floating sidebar when keymaps are enabled.

#### Scenario: Floating sidebar keymap registration
- **WHEN** `setup()` is called with `enable_keymaps` true or unset
- **THEN** the keymap `<leader>pf` SHALL be registered in normal mode
- **AND** pressing `<leader>pf` SHALL execute the floating sidebar toggle function
- **AND** the keymap SHALL have the description "Toggle floating plugin sidebar"

#### Scenario: Floating sidebar keymap disabled
- **WHEN** `setup({ enable_keymaps = false })` is called
- **THEN** the `<leader>pf` keymap SHALL NOT be registered
- **AND** the floating sidebar commands SHALL still work when invoked directly

#### Scenario: Floating sidebar keymap in registered_keymaps
- **WHEN** the plugin tracks registered keymaps
- **THEN** the `registered_keymaps` table SHALL include an entry for `<leader>pf`
- **AND** the entry SHALL specify command as "NvimPluginFloatingSidebar"
- **AND** the entry SHALL specify description as "Toggle floating plugin sidebar"

### Requirement: Educational Code Quality for Floating Sidebar
The floating sidebar implementation SHALL include comprehensive comments explaining the floating window pattern and extmark rendering for educational purposes.

#### Scenario: Module-level documentation
- **WHEN** a developer reads `floating-sidebar.lua`
- **THEN** comments SHALL explain the floating window pattern and its use cases
- **AND** comments SHALL explain differences from vertical split sidebar approach
- **AND** comments SHALL reference the vertical split sidebar for comparison
- **AND** comments SHALL explain when to use floating vs split windows

#### Scenario: Floating window configuration documentation
- **WHEN** a developer reads the window creation code
- **THEN** comments SHALL explain each floating window option (relative, width, height, col, row, anchor, style, border, zindex)
- **AND** comments SHALL explain the purpose of each configuration value
- **AND** comments SHALL explain z-ordering and overlay behavior

#### Scenario: Extmark rendering documentation
- **WHEN** a developer reads the rendering code
- **THEN** comments SHALL explain how extmarks differ from buffer line updates
- **AND** comments SHALL explain when to use `nvim_buf_set_extmark()` vs `nvim_buf_set_lines()`
- **AND** comments SHALL document extmark parameters (virt_text, virt_text_pos, hl_mode)
- **AND** comments SHALL explain namespace clearing and why it's necessary

#### Scenario: Comparison with vertical split sidebar
- **WHEN** a developer studies both sidebar implementations
- **THEN** comments SHALL highlight key differences in approach
- **AND** comments SHALL explain trade-offs of floating vs split windows
- **AND** comments SHALL guide learners on when to choose each pattern

### Requirement: Coexistence with Vertical Split Sidebar
The floating sidebar SHALL operate independently from the vertical split sidebar with no shared state or conflicts.

#### Scenario: Both sidebars can be open simultaneously
- **WHEN** the vertical split sidebar is open
- **THEN** the floating sidebar MAY be opened independently
- **AND** both sidebars SHALL render correctly
- **AND** no conflicts or errors SHALL occur
- **AND** each sidebar SHALL maintain its own state

#### Scenario: Commands are independent
- **WHEN** `:NvimPluginSidebar` and `:NvimPluginFloatingSidebar` commands exist
- **THEN** they SHALL operate on different sidebar instances
- **AND** toggling one sidebar SHALL NOT affect the other sidebar
- **AND** closing one sidebar SHALL NOT close the other sidebar
