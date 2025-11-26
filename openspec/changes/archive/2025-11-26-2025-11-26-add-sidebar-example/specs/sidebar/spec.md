# sidebar Specification Delta

## ADDED Requirements

### Requirement: Sidebar Module
The plugin SHALL provide a sidebar module that creates a persistent, application-like vertical split sidebar panel following professional Neovim plugin patterns.

#### Scenario: Sidebar module can be required
- **WHEN** the main plugin requires the sidebar module
- **THEN** the module SHALL return a table with `open`, `close`, and `toggle` functions
- **AND** no errors SHALL be raised

#### Scenario: Sidebar module state management
- **WHEN** the sidebar module is loaded
- **THEN** it SHALL maintain state for the sidebar buffer handle
- **AND** it SHALL maintain state for the sidebar window handle
- **AND** it SHALL create a namespace for highlights and extmarks

### Requirement: Sidebar Buffer Configuration
The sidebar SHALL create a non-editable scratch buffer with configuration that makes it behave like an application panel rather than an editable file.

#### Scenario: Buffer is scratch and unlisted
- **WHEN** the sidebar buffer is created
- **THEN** the buffer SHALL have `buftype` set to "nofile"
- **AND** the buffer SHALL have `buflisted` set to false
- **AND** the buffer SHALL have `bufhidden` set to "wipe"
- **AND** the buffer SHALL not create a swapfile

#### Scenario: Buffer is read-only
- **WHEN** the sidebar buffer is created
- **THEN** the buffer SHALL have `modifiable` set to false (except during content updates)
- **AND** the buffer SHALL have `readonly` set to true
- **AND** users SHALL NOT be able to edit content through normal editing commands

#### Scenario: Buffer has custom filetype
- **WHEN** the sidebar buffer is created
- **THEN** the buffer SHALL have `filetype` set to "nvim-plugin-sidebar"
- **AND** the buffer SHALL be named "nvim-plugin://sidebar"

#### Scenario: Buffer persistence
- **WHEN** the sidebar is opened multiple times
- **THEN** the same buffer SHALL be reused if it is still valid
- **AND** a new buffer SHALL only be created if the previous one was wiped

### Requirement: Sidebar Window Configuration
The sidebar SHALL create a vertical split window with configuration that makes it appear as a fixed-width sidebar panel.

#### Scenario: Window is vertical split with fixed width
- **WHEN** the sidebar window is created
- **THEN** it SHALL be created as a vertical split
- **AND** the width SHALL be set to 30 columns
- **AND** the window SHALL have `winfixwidth` set to true
- **AND** the width SHALL NOT change when executing `<C-w>=`

#### Scenario: Window has no editor UI elements
- **WHEN** the sidebar window is created
- **THEN** line numbers SHALL be disabled (`number = false`)
- **AND** relative line numbers SHALL be disabled (`relativenumber = false`)
- **AND** spell checking SHALL be disabled (`spell = false`)
- **AND** sign column SHALL be disabled (`signcolumn = "no"`)
- **AND** fold column SHALL be disabled (`foldcolumn = "0"`)

#### Scenario: Window has sidebar-appropriate UI settings
- **WHEN** the sidebar window is created
- **THEN** line wrapping SHALL be disabled (`wrap = false`)
- **AND** cursor line highlighting MAY be enabled (`cursorline = true`)
- **AND** side scroll offset SHALL be 0 (`sidescrolloff = 0`)
- **AND** scroll offset SHALL be 0 (`scrolloff = 0`)

### Requirement: Sidebar Open Function
The sidebar module SHALL provide an `open()` function that creates or focuses the sidebar.

#### Scenario: Open sidebar when not already open
- **WHEN** `open()` is called and the sidebar window does not exist
- **THEN** the sidebar buffer SHALL be created or reused
- **AND** the sidebar window SHALL be created with proper configuration
- **AND** the sidebar content SHALL be rendered
- **AND** the sidebar keymaps SHALL be configured
- **AND** the sidebar window SHALL be focused

#### Scenario: Open sidebar when already open
- **WHEN** `open()` is called and the sidebar window already exists and is valid
- **THEN** the existing sidebar window SHALL be focused
- **AND** no new buffer or window SHALL be created

#### Scenario: Open sidebar after window was closed
- **WHEN** `open()` is called after the sidebar window was closed but buffer still exists
- **THEN** the existing buffer SHALL be reused
- **AND** a new window SHALL be created
- **AND** the content SHALL be re-rendered
- **AND** the sidebar SHALL be ready for use

### Requirement: Sidebar Close Function
The sidebar module SHALL provide a `close()` function that closes the sidebar window.

#### Scenario: Close sidebar when open
- **WHEN** `close()` is called and the sidebar window exists and is valid
- **THEN** the sidebar window SHALL be closed using `nvim_win_close()`
- **AND** the window state SHALL be cleared (set to nil)
- **AND** the buffer SHALL NOT be deleted (it may be reused later)

#### Scenario: Close sidebar when already closed
- **WHEN** `close()` is called and the sidebar window does not exist or is invalid
- **THEN** no errors SHALL be raised
- **AND** the function SHALL complete silently

### Requirement: Sidebar Toggle Function
The sidebar module SHALL provide a `toggle()` function that alternates between opening and closing the sidebar.

#### Scenario: Toggle from closed to open
- **WHEN** `toggle()` is called and the sidebar window is closed or invalid
- **THEN** the sidebar SHALL open as if `open()` was called

#### Scenario: Toggle from open to closed
- **WHEN** `toggle()` is called and the sidebar window is open and valid
- **THEN** the sidebar SHALL close as if `close()` was called

#### Scenario: Toggle multiple times
- **WHEN** `toggle()` is called repeatedly
- **THEN** the sidebar state SHALL alternate between open and closed
- **AND** the behavior SHALL be consistent and predictable

### Requirement: Sidebar Content Rendering
The sidebar SHALL display formatted content showing plugin information.

#### Scenario: Render plugin keybindings
- **WHEN** the sidebar is opened
- **THEN** the content SHALL include a header "nvim-plugin Sidebar"
- **AND** the content SHALL list plugin keybindings with their descriptions
- **AND** the content SHALL include sidebar-specific commands (q, <CR>, r)
- **AND** the content SHALL be well-formatted and readable

#### Scenario: Content is read-only
- **WHEN** the sidebar content is rendered
- **THEN** the buffer SHALL be temporarily set to modifiable
- **AND** the content SHALL be updated using `nvim_buf_set_lines()`
- **AND** the buffer SHALL be set back to non-modifiable
- **AND** users SHALL NOT be able to edit the content

#### Scenario: Optional syntax highlighting
- **WHEN** the sidebar content is rendered
- **THEN** the header line MAY be highlighted using `nvim_buf_add_highlight()`
- **AND** syntax highlighting SHALL be optional but encouraged for educational purposes

### Requirement: Sidebar Keymap Isolation
The sidebar SHALL define custom buffer-local keymaps and disable normal editing keymaps to prevent accidental editing.

#### Scenario: Custom sidebar keymaps
- **WHEN** the sidebar buffer is created
- **THEN** the `q` key SHALL be mapped to close the sidebar
- **AND** the `<CR>` key SHALL be mapped to a placeholder action (demo/educational)
- **AND** the `r` key SHALL be mapped to refresh the sidebar content
- **AND** all mappings SHALL be buffer-local with `nowait = true`

#### Scenario: Insert mode keys disabled
- **WHEN** the sidebar buffer is created
- **THEN** insert mode trigger keys SHALL be mapped to `<Nop>`
- **AND** this SHALL include at minimum: `i`, `a`, `o`, `I`, `A`, `O`
- **AND** users SHALL NOT be able to enter insert mode accidentally

#### Scenario: Edit command keys disabled
- **WHEN** the sidebar buffer is created
- **THEN** common edit commands SHALL be mapped to `<Nop>` in normal mode
- **AND** this SHALL include at minimum: `dd`, `yy`, `p`, `P`, `D`, `x`, `X`, `<<`, `>>`
- **AND** users SHALL NOT be able to execute edit commands

#### Scenario: Keymap descriptions
- **WHEN** sidebar keymaps are registered
- **THEN** each keymap SHALL have a clear description of its purpose
- **AND** the descriptions SHALL be included in the sidebar content for discoverability

### Requirement: Sidebar Commands
The plugin SHALL provide user commands for controlling the sidebar.

#### Scenario: Toggle command
- **WHEN** `:NvimPluginSidebar` is executed
- **THEN** the sidebar SHALL toggle between open and closed states
- **AND** the command SHALL have the description "Toggle nvim-plugin sidebar"

#### Scenario: Explicit open command
- **WHEN** `:NvimPluginSidebarOpen` is executed
- **THEN** the sidebar SHALL open (or focus if already open)
- **AND** the command SHALL have the description "Open nvim-plugin sidebar"

#### Scenario: Explicit close command
- **WHEN** `:NvimPluginSidebarClose` is executed
- **THEN** the sidebar SHALL close if open
- **AND** no errors SHALL occur if the sidebar is already closed
- **AND** the command SHALL have the description "Close nvim-plugin sidebar"

#### Scenario: Commands available after setup
- **WHEN** the plugin `setup()` function is called
- **THEN** all three sidebar commands SHALL be registered
- **AND** the commands SHALL be available regardless of the `enable_keymaps` configuration

### Requirement: Sidebar Keymap
The plugin SHALL register a default keymap for toggling the sidebar when keymaps are enabled.

#### Scenario: Sidebar keymap registration
- **WHEN** `setup()` is called with `enable_keymaps` true or unset
- **THEN** the keymap `<leader>ps` SHALL be registered in normal mode
- **AND** pressing `<leader>ps` SHALL execute the sidebar toggle function
- **AND** the keymap SHALL have the description "Toggle plugin sidebar"

#### Scenario: Sidebar keymap disabled
- **WHEN** `setup({ enable_keymaps = false })` is called
- **THEN** the `<leader>ps` keymap SHALL NOT be registered
- **AND** the sidebar commands SHALL still work when invoked directly

#### Scenario: Sidebar keymap in registered_keymaps
- **WHEN** the plugin tracks registered keymaps
- **THEN** the `registered_keymaps` table SHALL include an entry for `<leader>ps`
- **AND** the entry SHALL specify command as "NvimPluginSidebar"
- **AND** the entry SHALL specify description as "Toggle plugin sidebar"
- **AND** this SHALL ensure the keymap appears in `:NvimPluginKeybindings` output

### Requirement: Educational Code Quality for Sidebar
The sidebar implementation SHALL include comprehensive comments explaining the pattern for educational purposes.

#### Scenario: Module-level documentation
- **WHEN** a developer reads `sidebar.lua`
- **THEN** comments SHALL explain the sidebar pattern and its use cases
- **AND** comments SHALL reference similar plugins (nvim-tree, neo-tree, aerial)
- **AND** comments SHALL explain why this pattern is valuable to learn

#### Scenario: Buffer configuration documentation
- **WHEN** a developer reads the buffer creation code
- **THEN** comments SHALL explain each buffer option and why it is set
- **AND** comments SHALL explain the difference between scratch buffers and file buffers
- **AND** comments SHALL explain the purpose of read-only configuration

#### Scenario: Window configuration documentation
- **WHEN** a developer reads the window creation code
- **THEN** comments SHALL explain each window option and why it is set
- **AND** comments SHALL explain the purpose of `winfixwidth`
- **AND** comments SHALL explain why UI elements are disabled

#### Scenario: Keymap isolation documentation
- **WHEN** a developer reads the keymap setup code
- **THEN** comments SHALL explain the keymap isolation strategy
- **AND** comments SHALL explain why insert mode and edit commands are disabled
- **AND** comments SHALL explain buffer-local vs global keymaps

#### Scenario: State management documentation
- **WHEN** a developer reads the state management code
- **THEN** comments SHALL explain why buffer and window handles are tracked
- **AND** comments SHALL explain the lifecycle of buffers and windows
- **AND** comments SHALL explain how reuse vs recreation is handled
