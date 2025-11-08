vim.opt.rtp:prepend(".")
local plenary_path = vim.fn.stdpath("data") .. "/lazy/plenary.nvim"
if vim.fn.isdirectory(plenary_path) == 1 then
	vim.opt.rtp:prepend(plenary_path)
else
	error("plenary.nvim not found at " .. plenary_path)
end
vim.o.swapfile = false
vim.o.backup = false
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set up a temporary directory for test files
local temp_dir = vim.fn.tempname() .. "_findreplace_test"
vim.fn.mkdir(temp_dir, "p")
vim.env.FINDREPLACE_TEST_DIR = temp_dir
require("findreplace").setup({})
