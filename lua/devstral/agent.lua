-- Devstral Agent Assistant
-- Provides code analysis and suggestions

local M = {}
local api = require("devstral.api")
local config = require("devstral").config

function M.setup()
	-- Agent is ready to use
end

--- Run agent analysis on current buffer
function M.run_agent()
	if not config.agent.enabled then
		vim.notify("Devstral agent is disabled in configuration", vim.log.levels.WARN)
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local filetype = vim.bo[bufnr].filetype
	local code = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")

	if not code or code == "" then
		vim.notify("No code to analyze", vim.log.levels.WARN)
		return
	end

	-- Show progress
	vim.notify("Analyzing code with Devstral Agent...", vim.log.levels.INFO)

	-- Send to API
	local response, err = api.analyze_code(code, filetype, {
		context = {
			filename = vim.api.nvim_buf_get_name(bufnr),
			cursor_position = vim.api.nvim_win_get_cursor(0),
		},
	})

	if err then
		vim.notify("Agent analysis failed: " .. err, vim.log.levels.ERROR)
		return
	end

	-- Display results
	M._display_analysis_results(response)
end

--- Get suggestions from agent
function M.get_suggestions()
	if not config.agent.enabled then
		vim.notify("Devstral agent is disabled in configuration", vim.log.levels.WARN)
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local filetype = vim.bo[bufnr].filetype
	local code = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")

	if not code or code == "" then
		vim.notify("No code to analyze", vim.log.levels.WARN)
		return
	end

	-- Show progress
	vim.notify("Getting suggestions from Devstral Agent...", vim.log.levels.INFO)

	-- Send to API
	local response, err = api.get_suggestions(code, filetype)

	if err then
		vim.notify("Failed to get suggestions: " .. err, vim.log.levels.ERROR)
		return
	end

	-- Display suggestions
	M._display_suggestions(response)
end

--- Display analysis results
-- @param results table Analysis results from API
function M._display_analysis_results(results)
	if not results or not results.analysis then
		vim.notify("No analysis results received", vim.log.levels.WARN)
		return
	end

	local lines = {}

	-- Add header
	table.insert(lines, "# Devstral Agent Analysis")
	table.insert(lines, "")

	-- Add overall assessment
	if results.analysis.overall then
		table.insert(lines, "## Overall Assessment")
		table.insert(lines, results.analysis.overall)
		table.insert(lines, "")
	end

	-- Add issues
	if results.analysis.issues and #results.analysis.issues > 0 then
		table.insert(lines, "## Issues Found")
		table.insert(lines, "")

		for _, issue in ipairs(results.analysis.issues) do
			table.insert(lines, "### " .. issue.severity:upper() .. ": " .. issue.description)
			table.insert(lines, "Location: Line " .. issue.line .. " (" .. issue.type .. ")")

			if issue.suggestion then
				table.insert(lines, "Suggestion: " .. issue.suggestion)
			end

			table.insert(lines, "")
		end
	end

	-- Add suggestions
	if results.analysis.suggestions and #results.analysis.suggestions > 0 then
		table.insert(lines, "## Suggestions")
		table.insert(lines, "")

		for _, suggestion in ipairs(results.analysis.suggestions) do
			table.insert(lines, "- " .. suggestion)
		end
	end

	-- Show in a floating window
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
	vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

	local width = math.min(math.floor(vim.o.columns * 0.8), 100)
	local height = math.min(math.floor(vim.o.lines * 0.8), 40)

	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = "Devstral Agent Analysis",
		title_pos = "center",
	}

	local winid = vim.api.nvim_open_win(bufnr, true, win_opts)

	-- Set up keymaps
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>q<CR>", {
		noremap = true,
		silent = true,
		desc = "Close analysis window",
	})

	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "<cmd>q<CR>", {
		noremap = true,
		silent = true,
		desc = "Close analysis window",
	})
end

--- Display suggestions
-- @param suggestions table Suggestions from API
function M._display_suggestions(suggestions)
	if not suggestions or not suggestions.suggestions or #suggestions.suggestions == 0 then
		vim.notify("No suggestions received", vim.log.levels.WARN)
		return
	end

	local lines = {}

	-- Add header
	table.insert(lines, "# Devstral Agent Suggestions")
	table.insert(lines, "")

	-- Add suggestions
	for i, suggestion in ipairs(suggestions.suggestions) do
		table.insert(lines, i .. ". " .. suggestion.text)

		if suggestion.code then
			table.insert(lines, "")
			table.insert(lines, "```" .. (suggestion.language or ""))
			table.insert(lines, suggestion.code)
			table.insert(lines, "```")
		end

		table.insert(lines, "")
	end

	-- Show in a floating window
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
	vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

	local width = math.min(math.floor(vim.o.columns * 0.8), 100)
	local height = math.min(math.floor(vim.o.lines * 0.8), 40)

	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = "Devstral Agent Suggestions",
		title_pos = "center",
	}

	local winid = vim.api.nvim_open_win(bufnr, true, win_opts)

	-- Set up keymaps
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>q<CR>", {
		noremap = true,
		silent = true,
		desc = "Close suggestions window",
	})

	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "<cmd>q<CR>", {
		noremap = true,
		silent = true,
		desc = "Close suggestions window",
	})
end

--- Apply suggestion to current buffer
-- @param suggestion table Suggestion to apply
function M.apply_suggestion(suggestion)
	-- This would be implemented based on the suggestion format
	-- For now, just show a notification
	vim.notify("Applying suggestion: " .. (suggestion.text or "Unknown"), vim.log.levels.INFO)
end

return M

