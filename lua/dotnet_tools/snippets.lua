local M = {}

function M.CreateCsharpNamespaceSnippet()
	local namespace_name = "Edit"

	local current_file = vim.api.nvim_buf_get_name(0)
	local current_dir = vim.fn.fnamemodify(current_file, ":h")

	local cs_files = vim.fn.glob(current_dir .. "/*.cs", false, true)

	for _, file in ipairs(cs_files) do
		if file ~= current_file then
			local ok, lines = pcall(vim.fn.readfile, file)
			if ok then
				for _, line in ipairs(lines) do
					local match = string.match(line, "^%s*namespace%s+([%w_%.]+)")
					if match then
						namespace_name = match
						break
					end
				end
			end
		end
		if namespace_name ~= "Edit" then
			break
		end
	end

	local snippet = string.format("namespace %s {}", namespace_name)
	vim.api.nvim_put({ snippet }, "l", true, true)

	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	local line_text = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]

	local closing_bracket_col = string.find(line_text, "}")

	if closing_bracket_col then
		vim.api.nvim_win_set_cursor(0, { row, closing_bracket_col - 1 })
		vim.api.nvim_feedkeys("ci{", "n", false)
	end
end

function M.CreateCsharpClassSnippet()
	local filepath = vim.fn.getreg("%")
	local base_name = vim.fn.fnamemodify(filepath, ":t:r")

	local snippet = "public sealed class " .. base_name .. " {}"
	vim.api.nvim_put({ snippet }, "l", true, true)

	-- Move cousor betwen the curly brackets
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	local new_col = col + string.find(snippet, "}") - 1
	vim.api.nvim_win_set_cursor(0, { row - 1, new_col })

	vim.api.nvim_feedkeys("ci{", "n", false)
end

function M.CreateCsharpConstructor()
	local filepath = vim.fn.getreg("%")
	local base_name = vim.fn.fnamemodify(filepath, ":t:r")

	local snippet = "public " .. base_name .. "() {}"

	vim.api.nvim_put({ snippet }, "l", true, true)

	-- Move cousor betwen the curly brackets
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	local new_col = col + string.find(snippet, "}") - 1

	vim.api.nvim_win_set_cursor(0, { row - 1, new_col })

	vim.api.nvim_feedkeys("ci{", "n", false)
end

function M.CreateCsharpInterfaceSnippet()
	local filepath = vim.fn.getreg("%")
	local base_name = vim.fn.fnamemodify(filepath, ":t:r")

	local snippet = "public interface " .. base_name .. " {}"
	vim.api.nvim_put({ snippet }, "l", true, true)

	-- Move cousor betwen the curly brackets
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	local new_col = col + string.find(snippet, "}") - 1

	vim.api.nvim_win_set_cursor(0, { row - 1, new_col })
	vim.api.nvim_feedkeys("ci{", "n", false)
end

function M.CreateCsharpFuncitonSnippet()
	local function_name = vim.fn.input("Enter function name: ")

	local snippet = "public void " .. function_name .. "() {}"

	vim.api.nvim_put({ snippet }, "l", true, true)

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	-- Calculate the new column position (position of the first parenthesis + 1)
	local new_col = col + string.find(snippet, "}") - 1

	-- Set the cursor position to the correct place (row stays the same, column is new_col)
	vim.api.nvim_win_set_cursor(0, { row - 1, new_col })

	vim.api.nvim_feedkeys("ci{", "n", false)
end

function M.CreateCsharpAsycFuncitonSnippet()
	local function_name = vim.fn.input("Enter function name: ")

	local snippet = "public async Task " .. function_name .. "() {}"

	vim.api.nvim_put({ snippet }, "l", true, true)

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	-- Calculate the new column position (position of the first parenthesis + 1)
	local new_col = col + string.find(snippet, "}") - 1

	-- Set the cursor position to the correct place (row stays the same, column is new_col)
	vim.api.nvim_win_set_cursor(0, { row - 1, new_col })

	vim.api.nvim_feedkeys("ci{", "n", false)
end

function M.CreateCsharpStaticFuncitonSnippet()
	local function_name = vim.fn.input("Enter function name: ")

	local snippet = "public static void " .. function_name .. "() {}"

	vim.api.nvim_put({ snippet }, "l", true, true)

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	-- Calculate the new column position (position of the first parenthesis + 1)
	local new_col = col + string.find(snippet, "}") - 1

	-- Set the cursor position to the correct place (row stays the same, column is new_col)
	vim.api.nvim_win_set_cursor(0, { row - 1, new_col })

	-- Enter insert mode to allow the user to type the function name
	vim.api.nvim_feedkeys("ci{", "n", false)
end

function M.CreateCsharpAsyncStaticFuncitonSnippet()
	local function_name = vim.fn.input("Enter function name: ")

	local snippet = "public static async Task " .. function_name .. "() {}"

	vim.api.nvim_put({ snippet }, "l", true, true)

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	-- Calculate the new column position (position of the first parenthesis + 1)
	local new_col = col + string.find(snippet, "}") - 1

	-- Set the cursor position to the correct place (row stays the same, column is new_col)
	vim.api.nvim_win_set_cursor(0, { row - 1, new_col })

	-- Enter insert mode to allow the user to type the function name
	vim.api.nvim_feedkeys("ci{", "n", false)
end

function M.CreateCsharpPrivateFuncitonSnippet()
	local function_name = vim.fn.input("Enter function name: ")

	local snippet = "private void " .. function_name .. "() {}"

	vim.api.nvim_put({ snippet }, "l", true, true)

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	-- Get the current cursor position (row and column)

	-- Calculate the new column position (position of the first parenthesis + 1)
	local new_col = col + string.find(snippet, "}") - 1

	-- Set the cursor position to the correct place (row stays the same, column is new_col)
	vim.api.nvim_win_set_cursor(0, { row - 1, new_col })

	-- Enter insert mode to allow the user to type the function name
	vim.api.nvim_feedkeys("ci{", "n", false)
end

function M.CreateCsharpPrivateStaticFuncitonSnippet()
	-- Use vim.fn.input() to prompt the user for a function name
	local function_name = vim.fn.input("Enter function name: ")

	local snippet = "private static void " .. function_name .. "() {}"

	vim.api.nvim_put({ snippet }, "l", true, true)

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	-- Get the current cursor position (row and column)

	-- Calculate the new column position (position of the first parenthesis + 1)
	local new_col = col + string.find(snippet, "}") - 1

	-- Set the cursor position to the correct place (row stays the same, column is new_col)
	vim.api.nvim_win_set_cursor(0, { row - 1, new_col })

	-- Enter insert mode to allow the user to type the function name
	vim.api.nvim_feedkeys("ci{", "n", false)
end

function M.CreateCsharpIfSnippet()
	local snippet = "if () {}"
	vim.api.nvim_put({ snippet }, "l", true, true)

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	local new_col = col + string.find(snippet, "%(")

	vim.api.nvim_win_set_cursor(0, { row - 1, new_col })
	vim.api.nvim_feedkeys("ci(", "n", false)
end

return M
