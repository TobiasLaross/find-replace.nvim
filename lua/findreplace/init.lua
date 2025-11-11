--- @class FindReplaceConfig
--- @field keymaps { search_replace?: string, word_replace?: string, visual_replace?: string }|nil

local M = {}

--- Default configuration
--- @type FindReplaceConfig
local default_config = {
	keymaps = {
		search_replace = "<leader>rs",
		word_replace = "<leader>rw",
		visual_replace = "<leader>rv",
	},
}

--- @type FindReplaceConfig
local config = {}

--- Validate and merge user config with defaults
--- @param user_config table|nil
--- @return FindReplaceConfig
local function validate_config(user_config)
	if type(user_config) ~= "table" then
		return default_config
	end
	if user_config.keymaps ~= nil and type(user_config.keymaps) ~= "table" then
		user_config.keymaps = {}
	end
	return vim.tbl_deep_extend("force", default_config, user_config)
end

--- Execute replacement prompt using a preselected search term
--- @param search_term string
local function run_replace(search_term)
	vim.ui.input({ prompt = "󰛔 : replace " .. search_term }, function(replace_term)
		if not replace_term then
			return
		end
		vim.ui.input({ prompt = "Scope: ", default = "%" }, function(scope_input)
			local scope = scope_input == "" and "%" or scope_input
			local search_escaped = vim.fn.escape(search_term, "/\\")
			local replace_escaped = vim.fn.escape(replace_term, "/\\")
			local command = string.format("%ss/%s/%s/g", scope, search_escaped, replace_escaped)
			vim.cmd(command)
		end)
	end)
end

--- Prompt user for a search term, then run replace
function M.search_replace()
	vim.ui.input({ prompt = " : search" }, function(search_term)
		if search_term and search_term ~= "" then
			run_replace(search_term)
		end
	end)
end

--- Replace the word under cursor
function M.word_replace()
	local search_term = vim.fn.expand("<cword>")
	if search_term and search_term ~= "" then
		run_replace(search_term)
	end
end

--- Replace selected text (only if selection is within a single line)
function M.visual_replace()
	local _, start_row, start_col = unpack(vim.fn.getpos("v"))
	local _, end_row, end_col = unpack(vim.fn.getpos("."))

	if start_row ~= end_row then
		return
	end

	local text = vim.api.nvim_buf_get_text(0, start_row - 1, start_col - 1, end_row - 1, end_col, {})
	local selected = table.concat(text, "")
	if selected and selected ~= "" then
		run_replace(selected)
	end
end

--- Setup the plugin
--- @param opts FindReplaceConfig|nil
function M.setup(opts)
	config = validate_config(opts)
	local maps = config.keymaps
	if maps then
		if maps.search_replace then
			vim.keymap.set("n", maps.search_replace, M.search_replace)
		end
		if maps.word_replace then
			vim.keymap.set("n", maps.word_replace, M.word_replace)
		end
		if maps.visual_replace then
			vim.keymap.set("v", maps.visual_replace, M.visual_replace)
		end
	end
end

return M
