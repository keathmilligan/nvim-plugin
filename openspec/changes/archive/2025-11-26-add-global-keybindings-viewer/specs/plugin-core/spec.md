# plugin-core Specification Delta

## ADDED Requirements

### Requirement: All Keybindings Command
The plugin SHALL provide a `:NvimPluginAllKeybindings` command that displays ALL keybindings from all sources (core Neovim, plugins, user config) grouped by mode.

#### Scenario: Execute all keybindings command
- **WHEN** `:NvimPluginAllKeybindings` is executed
- **THEN** a new buffer SHALL be opened displaying keybindings from all sources
- **AND** keybindings SHALL be grouped by mode (normal, insert, visual, etc.)
- **AND** each group SHALL have a clear header

#### Scenario: Command availability
- **WHEN** the plugin is set up
- **THEN** the `:NvimPluginAllKeybindings` command SHALL be registered
- **AND** the command SHALL work regardless of the `enable_keymaps` configuration option

### Requirement: All Keybindings Keymap
The plugin SHALL register a default keymap `<leader>pa` to invoke the all keybindings viewer when `enable_keymaps` is true.

#### Scenario: All keybindings keymap registration
- **WHEN** `setup()` is called with `enable_keymaps` true or unset
- **THEN** the keymap `<leader>pa` SHALL be registered in normal mode
- **AND** pressing `<leader>pa` SHALL execute `:NvimPluginAllKeybindings`
- **AND** the keymap SHALL have the description "Show all Neovim keybindings"

#### Scenario: All keybindings keymap disabled
- **WHEN** `setup({ enable_keymaps = false })` is called
- **THEN** the `<leader>pa` keymap SHALL not be registered
- **AND** the `:NvimPluginAllKeybindings` command SHALL still work when invoked directly

## MODIFIED Requirements

### Requirement: Default Keymaps
The plugin SHALL register default keymaps for common operations when `enable_keymaps` is true (default).

#### Scenario: Hello keymap registration
- **WHEN** `setup()` is called with `enable_keymaps` true or unset
- **THEN** the keymap `<leader>ph` SHALL be registered in normal mode
- **AND** pressing `<leader>ph` SHALL execute `:NvimPluginHello`

#### Scenario: Toggle keymap registration
- **WHEN** `setup()` is called with `enable_keymaps` true or unset
- **THEN** the keymap `<leader>pt` SHALL be registered in normal mode
- **AND** pressing `<leader>pt` SHALL execute `:NvimPluginToggle`

#### Scenario: Plugin keybindings keymap registration
- **WHEN** `setup()` is called with `enable_keymaps` true or unset
- **THEN** the keymap `<leader>pk` SHALL be registered in normal mode
- **AND** pressing `<leader>pk` SHALL execute `:NvimPluginKeybindings`

#### Scenario: All keybindings keymap registration
- **WHEN** `setup()` is called with `enable_keymaps` true or unset
- **THEN** the keymap `<leader>pa` SHALL be registered in normal mode
- **AND** pressing `<leader>pa` SHALL execute `:NvimPluginAllKeybindings`

#### Scenario: Keymaps disabled
- **WHEN** `setup({ enable_keymaps = false })` is called
- **THEN** no keymaps SHALL be registered
- **AND** `<leader>ph`, `<leader>pt`, `<leader>pk`, and `<leader>pa` SHALL not invoke plugin commands

#### Scenario: Keymap descriptions
- **WHEN** keymaps are registered
- **THEN** each keymap SHALL have a descriptive label
- **AND** the descriptions SHALL be "Show plugin greeting" for `<leader>ph`
- **AND** "Toggle plugin state" for `<leader>pt`
- **AND** "Show plugin keybindings" for `<leader>pk`
- **AND** "Show all Neovim keybindings" for `<leader>pa`
