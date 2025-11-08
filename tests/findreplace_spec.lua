local assert = require("luassert")

-- Helper to setup buffer with file
local function setup_buffer_with_file(filepath, content)
	vim.fn.writefile(content or { "test content" }, filepath)
	vim.cmd("edit " .. vim.fn.fnameescape(filepath))
	-- Ensure buffer is properly associated with file
	vim.api.nvim_buf_set_name(0, filepath)
	return filepath
end
---@diagnostic disable: duplicate-set-field
local function with_stubbed_input(sequence, run)
	local original_input = vim.ui.input

	vim.ui.input = function(options, callback)
		local key = options and options.prompt or ""
		local value = sequence[key]
		callback(value)
	end

	local ok, error_message = pcall(run)
	vim.ui.input = original_input
	if not ok then
		error(error_message)
	end
end

local function with_captured_cmd(run)
	local original_cmd = vim.cmd
	local captured = nil

	vim.cmd = function(command)
		captured = command
	end

	local ok, error_message = pcall(function()
		run(function()
			return captured
		end)
	end)

	vim.cmd = original_cmd
	if not ok then
		error(error_message)
	end
end

describe("find-replace.nvim", function()
	-- Global cleanup between all tests
	before_each(function() end)

	after_each(function() end)

	describe("setup", function()
		it("loads without errors", function()
			local find_replace = require("findreplace")
			assert.is_not_nil(find_replace)
			assert.is_function(find_replace.setup)
		end)

		it("has all required functions", function()
			local find_replace = require("findreplace")
			local required_functions = {
				"search_replace",
				"word_replace",
				"visual_replace",
			}

			for _, func_name in ipairs(required_functions) do
				assert.is_function(find_replace[func_name], func_name .. " should be a function")
			end
		end)
	end)

	describe("search and replace", function()
		local find_replace = require("findreplace")

		before_each(function() end)

		it("executes correct :%s command", function()
			with_captured_cmd(function(get_cmd)
				with_stubbed_input({
					[" : search"] = "value",
					["󰛔 : replace value"] = "result",
					["Scope: "] = "%",
				}, function()
					find_replace.search_replace()
				end)

				assert.equals("%s/value/result/g", get_cmd())
			end)
		end)
	end)

	describe("word replace", function()
		local test_file
		local find_replace = require("findreplace")

		before_each(function()
			local test_dir = vim.env.FINDREPLACE_TEST_DIR or vim.fn.tempname()
			test_file = test_dir .. "/word_test.lua"

			setup_buffer_with_file(test_file, {
				"local function test()",
				"  local value = false",
				"  if value then",
				"    return true",
				"  end",
				"  return false",
			})
		end)

		it("word_replace replaces the word under cursor", function()
			with_captured_cmd(function(get_cmd)
				with_stubbed_input({
					["󰛔 : replace value"] = "result",
					["Scope: "] = "%",
				}, function()
					vim.fn.cursor(2, 10)
					-- line is:   local value = false
					-- cursor on **value**
					find_replace.word_replace()
				end)

				assert.equals("%s/value/result/g", get_cmd())
			end)
		end)
	end)

	describe("visual replace", function()
		local test_file
		local find_replace = require("findreplace")

		before_each(function()
			local test_dir = vim.env.FINDREPLACE_TEST_DIR or vim.fn.tempname()
			test_file = test_dir .. "/visual_test.lua"

			setup_buffer_with_file(test_file, {
				"local function test()",
				"  local value = false",
				"  local value = true",
			})
		end)

		it("replaces the visually selected text", function()
			vim.fn.cursor(2, 9) -- put cursor *inside* `value`
			vim.cmd("normal! vllll") -- select `value`
			vim.cmd("normal! gv") -- restore visual mode

			with_captured_cmd(function(get_cmd)
				with_stubbed_input({
					["󰛔 : replace value"] = "result",
					["Scope: "] = "%",
				}, function()
					find_replace.visual_replace()
				end)

				assert.equals("%s/value/result/g", get_cmd())
			end)
		end)
	end)
end)
