## ADDED Requirements

### Requirement: Keybindings Display Command
The plugin SHALL provide a `:NvimPluginKeybindings` command that opens a new buffer and displays all registered plugin keybindings in a readable format.

#### Scenario: Display keybindings with default keymaps enabled
- **WHEN** `:NvimPluginKeybindings` is executed with default keymaps enabled
- **THEN** a new buffer SHALL be opened
- **AND** the buffer SHALL display all registered keybindings including `<leader>ph`, `<leader>pt`, and `<leader>pk`
- **AND** each keybinding SHALL show the key combination, associated command, and description

#### Scenario: Display keybindings with keymaps disabled
- **WHEN** `:NvimPluginKeybindings` is executed with `enable_keymaps = false`
- **THEN** a new buffer SHALL be opened
- **AND** the buffer SHALL indicate that no default keymaps are registered
- **AND** the command itself SHALL still be available

#### Scenario: Buffer properties
- **WHEN** the keybindings buffer is opened
- **THEN** the buffer SHALL be modifiable initially
- **AND** the buffer SHALL have appropriate formatting (readable layout with columns or sections)
- **AND** the buffer SHALL use a unique name like `nvim-plugin://keybindings`

### Requirement: Keybindings Display Keymap
The plugin SHALL register a default keymap `<leader>pk` to invoke the keybindings display command when `enable_keymaps` is true.

#### Scenario: Keybindings keymap registration
- **WHEN** `setup()` is called with `enable_keymaps` true or unset
- **THEN** the keymap `<leader>pk` SHALL be registered in normal mode
- **AND** pressing `<leader>pk` SHALL execute `:NvimPluginKeybindings`
- **AND** the keymap SHALL have the description "Show plugin keybindings"

#### Scenario: Keybindings keymap disabled
- **WHEN** `setup({ enable_keymaps = false })` is called
- **THEN** the `<leader>pk` keymap SHALL not be registered
- **AND** the `:NvimPluginKeybindings` command SHALL still work when invoked directly

### Requirement: Keybindings Display Format
The displayed keybindings SHALL be formatted in a clear, educational manner consistent with the plugin's learning-focused purpose.

#### Scenario: Format includes all information
- **WHEN** keybindings are displayed
- **THEN** the output SHALL include a header indicating this is the plugin's keybindings list
- **AND** each keybinding entry SHALL show the key combination (e.g., `<leader>ph`)
- **AND** each entry SHALL show the associated command (e.g., `:NvimPluginHello`)
- **AND** each entry SHALL show the description (e.g., "Show plugin greeting")

#### Scenario: Format is educational
- **WHEN** keybindings are displayed
- **THEN** the output MAY include explanatory text about the leader key
- **AND** the output SHALL be formatted in a visually organized way (columns or clear sections)
- **AND** the output SHALL be easy to read and understand for learning purposes
