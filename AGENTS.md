<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# Agent Instructions for nvim-plugin

## Project Purpose
This is a **minimal example project** demonstrating the basics of Neovim plugin development. Keep it simple and focused on teaching fundamentals.

## Build & Test Commands
- **Test**: Manual testing in Neovim (this is an example project, not production code)
- **Lint**: `luacheck .` (if configured)
- **Format**: `stylua .` (if configured)

## Code Style
- **Language**: Lua 5.1/LuaJIT (Neovim compatible)
- **Formatting**: 2-space indentation, simple and readable
- **Imports**: Use `require()` at top of file; keep dependencies minimal
- **Naming**: snake_case for functions/variables, PascalCase for modules
- **Comments**: Add explanatory comments for teaching purposes
- **API Usage**: Use modern `vim.api.*` and `vim.keymap.set()` to demonstrate current best practices

## Plugin Structure
- Place code in `lua/nvim-plugin/` directory
- Entry point: `lua/nvim-plugin/init.lua`
- LazyVim integration: Users load via LazyVim plugin spec
- Keep it minimal: Focus on demonstrating plugin basics, not complex features

## Development Notes
- This is an educational example, not a production plugin
- Prioritize clarity and simplicity over features
- Include helpful comments explaining Neovim plugin concepts
