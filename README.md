# find-replace.nvim

Minimal search and replace helpers for Neovim.  
Designed to make replacing text in a file fast and simple.  
Provides three replace actions: search input, word under cursor, and visual selection (single line).

## Features
- Prompts for search and replace terms
- Prompts for scope (`%` default)
- Uses `vim.ui.input`
- Optional keymaps

## Installation
With Lazy:
```lua
{
	"tobiaslaross/find-replace.nvim",
	opts = {},
}
```

## Default Keymaps
```lua
<leader>rs  search and replace (prompt)
<leader>rw  replace word under cursor
<leader>rv  replace selected text (single line)
```

## Configuration
```lua
require("findreplace").setup({
  keymaps = {
    search_replace = "<leader>rs",
    word_replace = "<leader>rw",
    visual_replace = "<leader>rv",
  },
})
```

## Usage

```lua
:lua require("findreplace").search_replace()
:lua require("findreplace").word_replace()
:lua require("findreplace").visual_replace()
```
