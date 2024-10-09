# open-origin.nvim

Open files & directories in a browser.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- nvim/init.lua
require("lazy").setup({
    ...
    "lvsz/open-origin.nvim",
    ...
})
```

## Getting started

```lua
-- nvim/after/plugin/open-origin.lua
local oo = require("open-origin")
vim.keymap.set("n", "<leader>oo", oo.open_origin)
vim.keymap.set("n", "<leader>ob", oo.open_origin_blame)
vim.keymap.set("n", "<leader>oc", oo.open_origin_commit)
vim.keymap.set("n", "<leader>ot", oo.open_origin_tree)
```
