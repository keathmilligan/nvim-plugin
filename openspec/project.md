# Project Context

## Purpose
A **minimal example Neovim plugin** demonstrating the basics of plugin development for educational purposes. This project illustrates:
- Basic plugin structure and organization
- LazyVim plugin manager integration
- Simple command and keymap registration
- Neovim API usage patterns

## Tech Stack
- **Language**: Lua 5.1/LuaJIT (Neovim runtime)
- **Plugin Manager**: LazyVim
- **Target**: Neovim 0.8+

## Project Conventions

### Code Style
- 2-space indentation
- snake_case for functions and variables
- PascalCase for module names
- Use modern Neovim APIs (`vim.api.*`, `vim.keymap.set()`)
- Add explanatory comments for educational clarity

### Architecture Patterns
- Simple module pattern: `lua/nvim-plugin/init.lua` as entry point
- Minimal dependencies to keep example focused
- Direct API usage without unnecessary abstractions
- Single-file structure for simplicity (can expand to multiple modules if needed)

### Testing Strategy
- Manual testing in Neovim (this is an educational example)
- Users can test by loading in their LazyVim config
- No automated tests required for this minimal example

### Git Workflow
- Simple feature commits
- Clear, descriptive commit messages
- Keep history clean and easy to follow for learners

## Domain Context
This plugin teaches **Neovim plugin fundamentals**:
- How to structure a plugin directory
- How to create user commands (`:MyCommand`)
- How to register keymaps
- How to provide a setup function for configuration
- How to integrate with LazyVim's lazy-loading system

## Important Constraints
- **Keep it minimal**: This is a teaching tool, not a feature-rich plugin
- **Lua 5.1 compatibility**: Must work with Neovim's embedded LuaJIT
- **No external dependencies**: Should work standalone
- **LazyVim focus**: Example integration for LazyVim users

## External Dependencies
- Neovim 0.8 or higher (for modern API usage)
- LazyVim (for plugin management demonstrations)
