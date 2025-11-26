# Change: Implement Minimal Neovim Plugin with LazyVim Integration

## Why

This project serves as an educational example for Neovim plugin development. Currently, the repository contains only documentation placeholders but no actual plugin code. We need to implement a minimal, fully-functional plugin that demonstrates:
- Modern Neovim plugin structure and conventions
- LazyVim integration patterns
- Basic plugin capabilities (commands, keymaps, configuration)

The implementation will follow current best practices (Neovim 0.8+ APIs, modern Lua patterns) to serve as a reference for learners.

## What Changes

- Add core plugin implementation in `lua/nvim-plugin/init.lua`
- Implement a `setup()` function with configuration options
- Create example user commands (`:NvimPluginHello`, `:NvimPluginToggle`)
- Register example keymaps demonstrating best practices
- Add configuration state management
- Create comprehensive documentation for LazyVim users
- Include inline code comments for educational clarity

All changes are **additions** (no breaking changes, as this is the initial implementation).

## Impact

- **Affected specs**: `plugin-core` (new capability)
- **Affected code**: 
  - `lua/nvim-plugin/init.lua` (new file)
  - `README.md` (updated with complete usage examples)
- **Dependencies**: None (uses only Neovim built-in APIs)
- **LazyVim compatibility**: Follows lazy-loading best practices
