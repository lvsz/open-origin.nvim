# open-origin.nvim

Open files & directories in GitHub.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
-- nvim/init.lua
require('lazy').setup({
    -- ...
    'lvsz/open-origin.nvim',
    -- ...
})
```

## Getting started

```lua
-- nvim/after/plugin/open-origin.lua
local open_origin = require'open-origin'
vim.keymap.set('n', '<leader>K', open_origin.open_origin)
vim.keymap.set('n', '<leader>T', open_origin.open_origin_tree)
vim.keymap.set('n', '<leader>B', open_origin.open_origin_blame)
```

> [!Note]
> When using `netrw`, it's recommended to disable `netrw_keepdir`:
> ```lua
> vim.g.netrw_keepdir = 0
> ```
> This keeps the value of `vim.fn.getcwd` updated while navigating directories.
