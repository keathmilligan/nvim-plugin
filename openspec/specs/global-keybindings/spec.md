# global-keybindings Specification

## Purpose
TBD - created by archiving change add-global-keybindings-viewer. Update Purpose after archive.
## Requirements
### Requirement: Global Keybindings Query
The plugin SHALL provide functionality to query and display ALL keybindings registered in the current Neovim session, including keybindings from Neovim core, all plugins, and user configurations.

#### Scenario: Query all modes
- **WHEN** the global keybindings viewer is invoked
- **THEN** keybindings SHALL be retrieved for all modes: normal (n), insert (i), visual (v), select (s), operator-pending (o), terminal (t), and command-line (c)

#### Scenario: Include all sources
- **WHEN** keybindings are queried
- **THEN** the results SHALL include keybindings from Neovim core commands
- **AND** the results SHALL include keybindings from all loaded plugins
- **AND** the results SHALL include user-defined keybindings

#### Scenario: Filter internal mappings
- **WHEN** keybindings are displayed
- **THEN** internal or unnamed mappings MAY be filtered to keep output focused on user-relevant bindings
- **AND** the filtering logic SHALL be documented in code comments

### Requirement: Global Keybindings Display Command
The plugin SHALL provide a `:NvimPluginAllKeybindings` command that opens a new buffer displaying all registered keybindings grouped by mode.

#### Scenario: Execute all keybindings command
- **WHEN** `:NvimPluginAllKeybindings` is executed
- **THEN** a new buffer SHALL be opened
- **AND** the buffer SHALL display keybindings grouped by mode
- **AND** each mode section SHALL have a clear header

#### Scenario: Display format
- **WHEN** keybindings are displayed
- **THEN** each keybinding entry SHALL show the key combination
- **AND** each entry SHALL show the mapped command or action
- **AND** each entry SHALL show the description (if available)
- **AND** the output SHALL be formatted in readable columns

#### Scenario: Buffer properties
- **WHEN** the all keybindings buffer is opened
- **THEN** the buffer SHALL be a scratch buffer (not saved to disk)
- **AND** the buffer SHALL use a unique name like `nvim-plugin://all-keybindings`
- **AND** the buffer SHALL be read-only after content is set
- **AND** the buffer SHALL have `buftype` set to `nofile`

### Requirement: Global Keybindings Keymap
The plugin SHALL register a default keymap `<leader>pa` to invoke the global keybindings viewer when `enable_keymaps` is true.

#### Scenario: Global keybindings keymap registration
- **WHEN** `setup()` is called with `enable_keymaps` true or unset
- **THEN** the keymap `<leader>pa` SHALL be registered in normal mode
- **AND** pressing `<leader>pa` SHALL execute `:NvimPluginAllKeybindings`
- **AND** the keymap SHALL have the description "Show all Neovim keybindings"

#### Scenario: Global keybindings keymap disabled
- **WHEN** `setup({ enable_keymaps = false })` is called
- **THEN** the `<leader>pa` keymap SHALL not be registered
- **AND** the `:NvimPluginAllKeybindings` command SHALL still work when invoked directly

### Requirement: Mode Grouping
Keybindings SHALL be organized by mode with clear section headers to help users understand which context each binding applies to.

#### Scenario: Mode section headers
- **WHEN** keybindings are displayed
- **THEN** each mode SHALL have a section header (e.g., "Normal Mode", "Insert Mode")
- **AND** mode abbreviations SHALL be explained or clearly labeled
- **AND** empty modes (with no keybindings) MAY be omitted from the display

#### Scenario: Mode ordering
- **WHEN** keybindings are displayed
- **THEN** modes SHALL be presented in a logical order (typically: normal, insert, visual, select, operator-pending, terminal, command-line)
- **AND** the ordering SHALL be consistent across invocations

### Requirement: Educational Documentation
The global keybindings feature SHALL include clear inline comments explaining how to programmatically query Neovim's keymap state.

#### Scenario: API usage documentation
- **WHEN** a developer reads the implementation code
- **THEN** comments SHALL explain the use of `vim.api.nvim_get_keymap()`
- **AND** comments SHALL explain how to iterate over multiple modes
- **AND** comments SHALL explain the structure of keymap data returned by Neovim

#### Scenario: Mode explanation
- **WHEN** a developer reads the implementation code
- **THEN** comments SHALL explain mode abbreviations (n, i, v, s, o, t, c)
- **AND** comments SHALL clarify when each mode is relevant

