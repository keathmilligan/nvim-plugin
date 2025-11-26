## ADDED Requirements

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
