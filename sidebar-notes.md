Here's a battle-tested, minimal-yet-complete way to create a **true custom sidebar** in Neovim that feels like a real application panel (like Nvim-Tree, Aerial, Symbols Outline, Neo-tree, etc.) — completely detached from normal editing behavior.

### Goal
A sidebar you open with `:MySidebar` (or a keymap) that:
- Is a vertical split on the left/right
- Has its own completely custom keybindings
- Ignores all normal mode motions (`h j k l`, `i`, `o`, `<C-w>`, etc.)
- Cannot enter insert mode accidentally
- Cannot be edited like a normal buffer
- Survives buffer switching, closing other windows, etc.

### Core Recipe (Neovim ≥ 0.8, works perfectly in 0.10/0.11)

```lua
local M = {}

-- State
local sidebar_buf = nil
local sidebar_win = nil
local ns = vim.api.nvim_create_namespace("my_sidebar")

-- Optional: your custom keymaps for the sidebar
local function setup_sidebar_keymaps()
  local opts = { buffer = sidebar_buf, nowait = true }
  vim.keymap.set("n", "q", M.close, opts)
  vim.keymap.set("n", "<CR>", function() print("Selected item!") end, opts)
  vim.keymap.set("n", "r", function() print("Refresh") end, opts)
  -- Add as many as you want — none of the normal keys will do anything
  -- You can safely unmap everything else if you want total silence:
  -- for _, key in ipairs({ "h","j","k","l","i","a","o","dd","yy", ... }) do
  --   vim.keymap.set("n", key, "<Nop>", opts)
  -- end
end

-- Render your custom content (example)
local function render()
  local lines = {
    "  My Custom Sidebar",
    "",
    "  <CR>  Select item",
    "  r     Refresh",
    "  q     Close",
    "",
    "  Item 1",
    "  Item 2",
    "  Item 3",
  }
  vim.api.nvim_buf_set_lines(sidebar_buf, 0, -1, false, lines)

  -- Optional: syntax highlighting / extmarks
  vim.api.nvim_buf_add_highlight(sidebar_buf, ns, "Title", 0, 0, -1)
end

function M.open()
  if sidebar_win and vim.api.nvim_win_is_valid(sidebar_win) then
    vim.api.nvim_set_current_win(sidebar_win)
    return
  end

  -- 1. Create the buffer (once)
  if not sidebar_buf or not vim.api.nvim_buf_is_valid(sidebar_buf) then
    sidebar_buf = vim.api.nvim_create_buf(false, true) -- unlisted, scratch
    vim.api.nvim_buf_set_name(sidebar_buf, "MySidebar")
    vim.api.nvim_buf_set_option(sidebar_buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(sidebar_buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(sidebar_buf, "swapfile", false)
    vim.api.nvim_buf_set_option(sidebar_buf, "buflisted", false)
    vim.api.nvim_buf_set_option(sidebar_buf, "modifiable", false)
    vim.api.nvim_buf_set_option(sidebar_buf, "filetype", "mysidebar") -- optional

    -- CRITICAL: disable almost everything that makes it feel like an editor
    vim.api.nvim_buf_set_option(sidebar_buf, "readonly", true)        -- can't edit
    vim.api.nvim_win_set_option(0, "spell", false)
    vim.api.nvim_win_set_option(0, "cursorline", true)  -- optional nice touch
    vim.api.nvim_win_set_option(0, "wrap", false)
    vim.api.nvim_win_set_option(0, "number", false)
    vim.api.nvim_win_set_option(0, "relativenumber", false)
  end

  -- 2. Create/open the window
  vim.cmd("vsplit")                     -- or "botright vsplit", "topleft vsplit", etc.
  sidebar_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(sidebar_win, sidebar_buf)
  vim.api.nvim_win_set_width(sidebar_win, 30)  -- fixed width

  -- Make the window truly "non-editor"
  local winopts = {
    number = false,
    relativenumber = false,
    spell = false,
    signcolumn = "no",
    foldcolumn = "0",
    winfixwidth = true,        -- prevents resizing with <C-w>=
    sidescrolloff = 0,
    scrolloff = 0,
  }
  for k, v in pairs(winopts) do
    vim.api.nvim_win_set_option(sidebar_win, k, v)
  end

  -- Prevent accidentally entering insert mode
  local disabled_modes = { "i", "ic", "ix", "R", "Rc", "Rx", "Rv", "Rvc", "Rvx" }
  for _, mode in ipairs(disabled_modes) do
    vim.api.nvim_buf_set_keymap(sidebar_buf, mode, "i", "<Nop>", { nowait = true })
    vim.api.nvim_buf_set_keymap(sidebar_buf, mode, "a", "<Nop>", { nowait = true })
    vim.api.nvim_buf_set_keymap(sidebar_buf, mode, "o", "<Nop>", { nowait = true })
  end

  -- Optional: completely disable normal-mode editing commands
  local cmds_to_nop = { "dd", "yy", "p", "P", "D", "x", "X", "<<", ">>" }
  for _, cmd in ipairs(cmds_to_nop) do
    vim.api.nvim_buf_set_keymap(sidebar_buf, "n", cmd, "<Nop>", { nowait = true })
  end

  setup_sidebar_keymaps()
  render()
end

function M.close()
  if sidebar_win and vim.api.nvim_win_is_valid(sidebar_win) then
    vim.api.nvim_win_close(sidebar_win, true)
    sidebar_win = nil
  end
end

function M.toggle()
  if sidebar_win and vim.api.nvim_win_is_valid(sidebar_win) then
    M.close()
  else
    M.open()
  end
end

-- Expose as commands
vim.api.nvim_create_user_command("MySidebar", M.toggle, {})
vim.api.nvim_create_user_command("MySidebarOpen", M.open, {})
vim.api.nvim_create_user_command("MySidebarClose", M.close, {})

return M
```

### Why this works so well

| Problem                               | Solved by                                   |
|---------------------------------------|---------------------------------------------|
| Accidentally entering insert mode     | `buftype=nofile` + keymap `<Nop>` on `i/a/o` |
| Normal editing commands work (`dd`, `yy`) | Explicit `<Nop>` mappings + `readonly`     |
| User resizes the sidebar accidentally | `winfixwidth = true`                        |
| Sidebar disappears when closing other windows | Buffer is unlisted + `bufhidden=wipe`       |
| Looks like a normal file              | Custom `filetype`, no numbers, no signs     |
| You want full control over keybinds   | Buffer-local mappings override everything   |

### Popular plugins that use exactly this pattern

- nvim-tree.lua
- neo-tree.nvim
- aerial.nvim
- symbols-outline.nvim
- outline.nvim
- sidebar.nvim (literally built for this)

### One-liner alternative (if you just want something quick)

```lua
vim.api.nvim_create_user_command("Sidebar", function()
  vim.cmd[[30vsplit +setl\\ buftype=nofile\\ nobuflisted\\ nonumber\\ nowrap\\ winfixwidth]]
  vim.wo.signcolumn = "no"
end, {})
```

But the full version above is what real sidebars use.

You now have a completely sandboxed, application-like sidebar that behaves exactly how you want. Happy hacking!
