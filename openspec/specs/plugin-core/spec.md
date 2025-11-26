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

#### Scenario: Plugin keybindings keymap registration
- **WHEN** `setup()` is called with `enable_keymaps` true or unset
- **THEN** the keymap `<leader>pk` SHALL be registered in normal mode
- **AND** pressing `<leader>pk` SHALL execute `:NvimPluginKeybindings`

#### Scenario: All keybindings keymap registration
- **WHEN** `setup()` is called with `enable_keymaps` true or unset
- **THEN** the keymap `<leader>pa` SHALL be registered in normal mode
- **AND** pressing `<leader>pa` SHALL execute `:NvimPluginAllKeybindings`

#### Scenario: All commands keymap registration
- **WHEN** `setup()` is called with `enable_keymaps` true or unset
- **THEN** the keymap `<leader>pc` SHALL be registered in normal mode
- **AND** pressing `<leader>pc` SHALL execute `:NvimPluginAllCommands`

#### Scenario: Keymaps disabled
- **WHEN** `setup({ enable_keymaps = false })` is called
- **THEN** no keymaps SHALL be registered
- **AND** `<leader>ph`, `<leader>pt`, `<leader>pk`, `<leader>pa`, and `<leader>pc` SHALL not invoke plugin commands

#### Scenario: Keymap descriptions
- **WHEN** keymaps are registered
- **THEN** each keymap SHALL have a descriptive label
- **AND** the descriptions SHALL be "Show plugin greeting" for `<leader>ph`
- **AND** "Toggle plugin state" for `<leader>pt`
- **AND** "Show plugin keybindings" for `<leader>pk`
- **AND** "Show all Neovim keybindings" for `<leader>pa`
- **AND** "Show all Neovim commands" for `<leader>pc`

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

### Requirement: Commands Discovery
The plugin SHALL provide functionality to query and display ALL ex-commands in the current Neovim session, including built-in commands, global user-defined commands, and buffer-local user-defined commands.

#### Scenario: Query user-defined commands via API
- **WHEN** the commands viewer is invoked
- **THEN** global user-defined commands SHALL be retrieved using `vim.api.nvim_get_commands({})`
- **AND** buffer-local user-defined commands SHALL be retrieved using `vim.api.nvim_buf_get_commands(0, {})`
- **AND** the results SHALL include all user-defined commands from plugins and user configuration

#### Scenario: Parse built-in commands from documentation
- **WHEN** the commands viewer is invoked
- **THEN** built-in ex-commands SHALL be discovered by parsing the runtime `doc/index.txt` help file
- **AND** the `doc/index.txt` file SHALL be located using `vim.api.nvim_get_runtime_file('doc/index.txt', false)`
- **AND** parsing SHALL extract all documented ex-command entries matching the pattern `|:tag|\t\t:command[abbrev]\t\tdescription`
- **AND** the implementation approach SHALL be documented in inline comments explaining why parsing is necessary

#### Scenario: Built-in commands not in API
- **WHEN** commands are queried via `vim.api.nvim_get_commands()` and `vim.api.nvim_buf_get_commands()`
- **THEN** built-in ex-commands like `:help`, `:quit`, `:write`, `:substitute` SHALL NOT be returned
- **AND** the implementation SHALL use documentation parsing to discover these ~539 built-in commands
- **AND** comments SHALL explain that the API only returns user-defined commands

#### Scenario: Command metadata extraction
- **WHEN** commands are queried
- **THEN** user-defined commands SHALL include name, attributes (bang, range, count, etc.), and description
- **AND** built-in commands SHALL include name and description from help documentation
- **AND** source information SHALL distinguish built-in vs. user-defined commands

### Requirement: All Commands Display Command
The plugin SHALL provide a `:NvimPluginAllCommands` command that opens a new buffer displaying all discovered commands (built-in and user-defined) with their metadata.

#### Scenario: Execute all commands command
- **WHEN** `:NvimPluginAllCommands` is executed
- **THEN** a new buffer SHALL be opened
- **AND** the buffer SHALL display all built-in ex-commands from `doc/index.txt`
- **AND** the buffer SHALL display all global user-defined commands
- **AND** the buffer SHALL display all buffer-local user-defined commands for the current buffer
- **AND** each command SHALL be clearly labeled with its source

#### Scenario: Display format
- **WHEN** commands are displayed
- **THEN** each command entry SHALL show the command name in ex-command format (`:CommandName` or `:com[mand]` for abbreviated forms)
- **AND** each entry SHALL show a source indicator ([C] for core/built-in, [G] for global user-defined, [B] for buffer-local user-defined)
- **AND** each entry SHALL show relevant attributes (e.g., "bang", "range") for user-defined commands if present
- **AND** each entry SHALL show the description (if available)
- **AND** the output SHALL be formatted in readable columns

#### Scenario: Buffer properties
- **WHEN** the all commands buffer is opened
- **THEN** the buffer SHALL be a scratch buffer (not saved to disk)
- **AND** the buffer SHALL use a unique name like `nvim-plugin://all-commands`
- **AND** the buffer SHALL be read-only after content is set
- **AND** the buffer SHALL have `buftype` set to `nofile`

#### Scenario: Header information
- **WHEN** the commands buffer is displayed
- **THEN** the header SHALL include a title "All Neovim Commands"
- **AND** the header SHALL show the total count of commands
- **AND** the header SHALL show counts for built-in vs. user-defined commands separately
- **AND** the header SHALL explain the source indicators ([C], [G], and [B])
- **AND** the header SHALL explain that built-in commands are parsed from runtime `doc/index.txt`
- **AND** the header SHALL explain that user-defined commands are queried via `nvim_get_commands()` API
- **AND** the header SHALL include a tip about searching within the buffer

### Requirement: All Commands Keymap
The plugin SHALL register a default keymap `<leader>pc` to invoke the commands viewer when `enable_keymaps` is true.

#### Scenario: Commands keymap registration
- **WHEN** `setup()` is called with `enable_keymaps` true or unset
- **THEN** the keymap `<leader>pc` SHALL be registered in normal mode
- **AND** pressing `<leader>pc` SHALL execute `:NvimPluginAllCommands`
- **AND** the keymap SHALL have the description "Show all Neovim commands"

#### Scenario: Commands keymap disabled
- **WHEN** `setup({ enable_keymaps = false })` is called
- **THEN** the `<leader>pc` keymap SHALL not be registered
- **AND** the `:NvimPluginAllCommands` command SHALL still work when invoked directly

### Requirement: Built-in Commands Parser
The plugin SHALL programmatically parse Neovim's runtime `doc/index.txt` help file to extract all documented built-in ex-commands.

#### Scenario: Parser implementation
- **WHEN** the built-in commands parser is invoked
- **THEN** it SHALL locate `doc/index.txt` using `vim.api.nvim_get_runtime_file('doc/index.txt', false)`
- **AND** it SHALL read and parse the entire file to extract ex-command entries
- **AND** parsing SHALL handle the format `|:tag|\t\t:command[abbrev]\t\tdescription`
- **AND** parsing results SHALL be cached for performance (parse once per session)

#### Scenario: Parser coverage
- **WHEN** parsing is complete
- **THEN** all documented ex-commands SHALL be included (`:help`, `:quit`, `:write`, `:substitute`, etc.)
- **AND** coverage SHALL be comprehensive (~539 entries)
- **AND** command abbreviations SHALL be preserved in display (e.g., `:h[elp]`, `:q[uit]`)

#### Scenario: Documentation of approach
- **WHEN** the built-in commands feature is documented
- **THEN** inline comments SHALL explain why parsing `doc/index.txt` is necessary
- **AND** comments SHALL explain the limitations of `vim.api.nvim_get_commands()` (only returns user-defined commands)
- **AND** comments SHALL explain that built-in commands like `:help`, `:quit` are NOT accessible via API
- **AND** the display header SHALL note that built-in data comes from the runtime `doc/index.txt` file
- **AND** the display SHALL indicate the Neovim version of the parsed documentation

### Requirement: Educational Documentation for Commands
The commands viewer feature SHALL include clear inline comments explaining how to programmatically query Neovim's command state and why parsing is necessary.

#### Scenario: API usage documentation
- **WHEN** a developer reads the implementation code
- **THEN** comments SHALL explain the use of `vim.api.nvim_get_commands()`
- **AND** comments SHALL explain the use of `vim.api.nvim_buf_get_commands()`
- **AND** comments SHALL explain the structure of command data returned by Neovim
- **AND** comments SHALL explain why these APIs only return user-defined commands

#### Scenario: Parsing rationale documentation
- **WHEN** a developer reads the implementation code
- **THEN** comments SHALL explain why built-in commands are not exposed via API
- **AND** comments SHALL explain how `doc/index.txt` parsing works
- **AND** comments SHALL explain the format of ex-command entries in the help file

#### Scenario: Scope explanation
- **WHEN** a developer reads the implementation code
- **THEN** comments SHALL explain the difference between built-in, global user-defined, and buffer-local user-defined commands
- **AND** comments SHALL clarify when each category is relevant

