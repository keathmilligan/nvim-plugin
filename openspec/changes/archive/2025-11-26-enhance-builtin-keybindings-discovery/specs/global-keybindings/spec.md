## MODIFIED Requirements

### Requirement: Global Keybindings Query
The plugin SHALL provide functionality to query and display ALL keybindings active in the current Neovim session, including built-in Neovim commands, keybindings from Neovim core APIs, all plugins, and user configurations.

#### Scenario: Query all modes
- **WHEN** the global keybindings viewer is invoked
- **THEN** keybindings SHALL be retrieved for all modes: normal (n), insert (i), visual (v), select (s), operator-pending (o), terminal (t), and command-line (c)

#### Scenario: Include all sources
- **WHEN** keybindings are queried
- **THEN** the results SHALL include built-in Neovim commands (e.g., dd, gg, <C-w>h)
- **AND** the results SHALL include keybindings registered via vim.api.nvim_get_keymap()
- **AND** the results SHALL include keybindings from all loaded plugins
- **AND** the results SHALL include user-defined keybindings

#### Scenario: Filter internal mappings
- **WHEN** keybindings are displayed
- **THEN** internal or unnamed mappings MAY be filtered to keep output focused on user-relevant bindings
- **AND** the filtering logic SHALL be documented in code comments

#### Scenario: Built-in keybindings discovery
- **WHEN** keybindings are queried
- **THEN** built-in Neovim commands SHALL be discovered by parsing the runtime index.txt help file
- **AND** the index.txt file SHALL be located using `vim.api.nvim_get_runtime_file('doc/index.txt', false)`
- **AND** parsing SHALL extract all documented keybindings matching the pattern `|tag|\t\tkey\t\tdescription`
- **AND** mode SHALL be determined from the tag prefix (e.g., `i_CTRL-A` → insert mode, no prefix → normal mode)
- **AND** the implementation approach SHALL be documented in inline comments explaining why parsing is necessary

### Requirement: Global Keybindings Display Command
The plugin SHALL provide a `:NvimPluginAllKeybindings` command that opens a new buffer displaying all active keybindings (built-in and registered) grouped by mode.

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

## ADDED Requirements

### Requirement: Keybinding Source Indicators
The plugin SHALL visually distinguish between different sources of keybindings to help users understand where each binding comes from.

#### Scenario: Visual source indicators
- **WHEN** keybindings are displayed
- **THEN** built-in Neovim commands SHALL be marked with `[C]` prefix
- **AND** plugin-registered keymaps SHALL be marked with `[P]` prefix
- **AND** buffer-local keymaps SHALL be marked with `[B]` prefix
- **AND** the buffer header SHALL include a legend explaining these prefixes

#### Scenario: Source detection
- **WHEN** keybindings are collected
- **THEN** built-in commands SHALL be identified from the reference list
- **AND** registered keymaps SHALL be identified via `vim.api.nvim_get_keymap()`
- **AND** buffer-local keymaps SHALL be identified via `vim.api.nvim_buf_get_keymap()`

### Requirement: Built-in Keybindings Parser
The plugin SHALL programmatically parse Neovim's runtime index.txt help file to extract all documented built-in commands.

#### Scenario: Parser implementation
- **WHEN** the built-in keybindings parser is invoked
- **THEN** it SHALL locate index.txt using `vim.api.nvim_get_runtime_file('doc/index.txt', false)`
- **AND** it SHALL read and parse the entire file to extract keybinding entries
- **AND** it SHALL handle all mode-specific sections (insert-index, normal-index, visual-index, cmdline-index, etc.)
- **AND** parsing results SHALL be cached for performance (parse once per session)

#### Scenario: Parsed data structure
- **WHEN** index.txt is parsed
- **THEN** each entry SHALL be organized by mode (n, i, v, s, o, t, c)
- **AND** each entry SHALL have an `lhs` field containing the key sequence
- **AND** each entry SHALL have a `desc` field containing the description
- **AND** the structure SHALL match the format returned by `vim.api.nvim_get_keymap()` for easy merging

#### Scenario: Parser coverage
- **WHEN** parsing is complete
- **THEN** all documented navigation commands SHALL be included (e.g., gg, G, <C-w>h/j/k/l)
- **AND** all documented editing commands SHALL be included (e.g., dd, yy, p, u)
- **AND** all documented visual mode operations SHALL be included (e.g., d, y, c in visual mode)
- **AND** all documented insert mode special keys SHALL be included (e.g., <C-w>, <C-u>)
- **AND** coverage SHALL be comprehensive (~1,264 entries across all modes)

#### Scenario: Documentation of approach
- **WHEN** the built-in keybindings feature is documented
- **THEN** inline comments SHALL explain why parsing index.txt is necessary
- **AND** comments SHALL explain the limitations of `vim.api.nvim_get_keymap()` (only shows registered keymaps)
- **AND** comments SHALL explain that operators like `dd`, `yy` are NOT registered but ARE documented
- **AND** the display header SHALL note that data comes from the runtime index.txt file
- **AND** the display SHALL indicate the Neovim version of the parsed documentation

### Requirement: Enhanced Display Header
The plugin SHALL provide a comprehensive header in the keybindings display buffer that explains what users are seeing and how to interpret the information.

#### Scenario: Header content
- **WHEN** the all keybindings buffer is displayed
- **THEN** the header SHALL explain that both built-in and registered keybindings are shown
- **AND** the header SHALL include a legend for source indicators ([C], [P], [B])
- **AND** the header SHALL note that built-in data is parsed from the runtime index.txt help file
- **AND** the header SHALL display the Neovim version used for parsing
- **AND** the header SHALL explain the difference between registered keymaps (from API) and built-in commands (from help docs)

#### Scenario: Educational clarity
- **WHEN** the header is read
- **THEN** users SHALL understand the distinction between built-in vs. registered keybindings
- **AND** users SHALL understand the limitations of programmatic keybinding discovery
- **AND** users SHALL know where to find more comprehensive Neovim documentation
