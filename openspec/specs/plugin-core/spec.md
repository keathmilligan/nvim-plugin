# plugin-core Specification

## Purpose
TBD - created by archiving change implement-minimal-plugin. Update Purpose after archive.
## Requirements
### Requirement: Plugin Module Structure
The plugin SHALL provide a Lua module at `lua/nvim-plugin/init.lua` that exports a setup function and follows modern Neovim plugin conventions.

#### Scenario: Module can be required
- **WHEN** a user requires the plugin with `require("nvim-plugin")`
- **THEN** the module SHALL return a table with at least a `setup` function

#### Scenario: Module works without setup call
- **WHEN** the module is required but `setup()` is not called
- **THEN** the plugin SHALL not register commands or keymaps
- **AND** no errors SHALL be raised

### Requirement: Setup Function
The plugin SHALL provide a `setup()` function that accepts an optional configuration table and initializes the plugin with commands and keymaps.

#### Scenario: Setup with default configuration
- **WHEN** `setup()` is called with no arguments
- **THEN** the plugin SHALL use default configuration values
- **AND** all commands SHALL be registered
- **AND** default keymaps SHALL be registered

#### Scenario: Setup with custom configuration
- **WHEN** `setup({ greeting = "Custom!", enable_keymaps = false })` is called
- **THEN** the custom greeting SHALL be used by commands
- **AND** no keymaps SHALL be registered when `enable_keymaps` is false

#### Scenario: Setup called multiple times
- **WHEN** `setup()` is called more than once
- **THEN** the latest configuration SHALL take effect
- **AND** commands SHALL not be duplicated

### Requirement: Configuration Options
The plugin SHALL support the following configuration options with sensible defaults.

#### Scenario: Default greeting message
- **WHEN** no `greeting` option is provided
- **THEN** the default greeting SHALL be "Hello from nvim-plugin!"

#### Scenario: Custom greeting message
- **WHEN** `setup({ greeting = "Custom message" })` is called
- **THEN** the `:NvimPluginHello` command SHALL display "Custom message"

#### Scenario: Keymap toggle
- **WHEN** `setup({ enable_keymaps = false })` is called
- **THEN** no default keymaps SHALL be registered
- **AND** commands SHALL still work when invoked directly

### Requirement: Hello Command
The plugin SHALL provide a `:NvimPluginHello` command that displays a greeting message to the user.

#### Scenario: Execute hello command with defaults
- **WHEN** `:NvimPluginHello` is executed
- **THEN** the configured greeting message SHALL be displayed using `vim.notify()`
- **AND** the notification level SHALL be INFO

#### Scenario: Execute hello command with custom greeting
- **WHEN** setup is called with `{ greeting = "Hi there!" }` and `:NvimPluginHello` is executed
- **THEN** "Hi there!" SHALL be displayed

### Requirement: Toggle Command
The plugin SHALL provide a `:NvimPluginToggle` command that demonstrates stateful behavior by toggling an enabled/disabled state.

#### Scenario: Initial toggle state
- **WHEN** the plugin is first loaded
- **THEN** the toggle state SHALL be enabled by default

#### Scenario: Toggle to disabled
- **WHEN** `:NvimPluginToggle` is executed while enabled
- **THEN** the state SHALL change to disabled
- **AND** a notification SHALL display "nvim-plugin disabled"

#### Scenario: Toggle to enabled
- **WHEN** `:NvimPluginToggle` is executed while disabled
- **THEN** the state SHALL change to enabled
- **AND** a notification SHALL display "nvim-plugin enabled"

#### Scenario: Toggle state persistence
- **WHEN** `:NvimPluginToggle` is executed multiple times
- **THEN** the state SHALL alternate between enabled and disabled
- **AND** the notification SHALL reflect the current state each time

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

#### Scenario: Keymaps disabled
- **WHEN** `setup({ enable_keymaps = false })` is called
- **THEN** no keymaps SHALL be registered
- **AND** `<leader>ph` and `<leader>pt` SHALL not invoke plugin commands

#### Scenario: Keymap descriptions
- **WHEN** keymaps are registered
- **THEN** each keymap SHALL have a descriptive label
- **AND** the descriptions SHALL be "Show plugin greeting" for `<leader>ph`
- **AND** "Toggle plugin state" for `<leader>pt`

### Requirement: LazyVim Integration
The plugin SHALL be compatible with LazyVim's lazy-loading mechanism and configuration patterns.

#### Scenario: Lazy-loading compatibility
- **WHEN** the plugin is configured in LazyVim with a `config` function
- **THEN** the plugin SHALL only register commands and keymaps after setup is called
- **AND** lazy-loading SHALL work without errors

#### Scenario: LazyVim keys specification
- **WHEN** users define custom keys in their LazyVim plugin spec
- **THEN** those keys SHALL work alongside or replace default keymaps
- **AND** the plugin SHALL not conflict with user-defined keymaps

### Requirement: Modern Neovim API Usage
The plugin SHALL use modern Neovim APIs introduced in version 0.8 or later for all operations.

#### Scenario: User command creation
- **WHEN** commands are registered
- **THEN** `vim.api.nvim_create_user_command()` SHALL be used
- **AND** legacy `vim.cmd()` with command definitions SHALL NOT be used

#### Scenario: Keymap registration
- **WHEN** keymaps are registered
- **THEN** `vim.keymap.set()` SHALL be used
- **AND** deprecated `vim.api.nvim_set_keymap()` SHALL NOT be used

#### Scenario: Notifications
- **WHEN** messages are displayed to users
- **THEN** `vim.notify()` SHALL be used
- **AND** appropriate log levels SHALL be specified

### Requirement: Educational Code Quality
The plugin SHALL include clear, explanatory comments that help users understand Neovim plugin development concepts.

#### Scenario: Module structure comments
- **WHEN** a user reads `init.lua`
- **THEN** comments SHALL explain the module pattern
- **AND** comments SHALL explain why each section exists

#### Scenario: API usage comments
- **WHEN** Neovim APIs are used
- **THEN** comments SHALL explain what the API does
- **AND** comments SHALL note why that API is preferred over alternatives

#### Scenario: Configuration comments
- **WHEN** configuration is defined
- **THEN** comments SHALL explain the purpose of each option
- **AND** comments SHALL show example values

