local M = {}

local function get_inside_curly_braces(snippet)
	-- Move cousor betwen the curly brackets
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	local new_col = col + string.find(snippet, "}") - 1

	vim.api.nvim_win_set_cursor(0, { row - 1, new_col })
	vim.api.nvim_feedkeys("ci{", "n", false)
end

local function get_inside_braces(snippet)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

	local new_col = col + string.find(snippet, "%(")

	vim.api.nvim_win_set_cursor(0, { row - 1, new_col })
	vim.api.nvim_feedkeys("ci(", "n", false)
end

function M.CreateCsharpNamespaceSnippet()
    local namespace_name = "Temp"

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
        if namespace_name ~= "Temp" then
            break
        end
    end

    if namespace_name == "Temp" then
        local csproj_path = require("dotnet_tools.finder").find_csproj()
        if csproj_path and csproj_path ~= "" then
            local project_dir = vim.fn.fnamemodify(csproj_path, ":h")
            local project_name = vim.fn.fnamemodify(csproj_path, ":t:r")

            if current_dir == project_dir then
                namespace_name = project_name
            elseif string.sub(current_dir, 1, #project_dir) == project_dir then
                local relative_path = string.sub(current_dir, #project_dir + 2)
                local dot_path = relative_path:gsub("[/\\]", ".")
                namespace_name = project_name .. "." .. dot_path
                -- namespace_name = namespace_name:gsub("-", "_"):gsub(" ", "_")
            end
        end
    end

    local snippet = string.format("namespace %s {}", namespace_name)
    vim.api.nvim_put({ snippet }, "l", true, true)

    get_inside_curly_braces(snippet)
end

function M.CreateCsharpClassSnippet()
	local filepath = vim.fn.getreg("%")
	local base_name = vim.fn.fnamemodify(filepath, ":t:r")

	local snippet = "public sealed class " .. base_name .. " {}"
	vim.api.nvim_put({ snippet }, "l", true, true)

    get_inside_curly_braces(snippet)
end

function M.CreateCsharpConstructor()
    local filepath = vim.api.nvim_buf_get_name(0)
    local base_name = vim.fn.fnamemodify(filepath, ":t:r")
    local class_name = base_name
    local cursor_row = vim.api.nvim_win_get_cursor(0)[1]

    for i = cursor_row, 1, -1 do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        local found_name = string.match(line, "class%s+([%a_][%w_]*)")
                        or string.match(line, "struct%s+([%a_][%w_]*)")
                        or string.match(line, "record%s+([%a_][%w_]*)")

        if found_name then
            class_name = found_name
            break
        end
    end

    local snippet = "public " .. class_name .. "() {}"

    vim.api.nvim_put({ snippet }, "l", true, true)

    get_inside_curly_braces(snippet)
end

function M.CreateCsharpInterfaceSnippet()
	local filepath = vim.fn.getreg("%")
	local base_name = vim.fn.fnamemodify(filepath, ":t:r")

	local snippet = "public interface " .. base_name .. " {}"
	vim.api.nvim_put({ snippet }, "l", true, true)

    get_inside_curly_braces(snippet)
end

function M.CreateCsharpFuncitonSnippet()
	local function_name = vim.fn.input("Enter function name: ")

	local snippet = "public void " .. function_name .. "() {}"

	vim.api.nvim_put({ snippet }, "l", true, true)

    get_inside_curly_braces(snippet)
end


function M.CreateCsharpAsycFuncitonSnippet()
	local function_name = vim.fn.input("Enter function name: ")

	local snippet = "public async Task " .. function_name .. "() {}"

	vim.api.nvim_put({ snippet }, "l", true, true)

    get_inside_curly_braces(snippet)
end

function M.CreateCsharpStaticFuncitonSnippet()
	local function_name = vim.fn.input("Enter function name: ")

	local snippet = "public static void " .. function_name .. "() {}"

	vim.api.nvim_put({ snippet }, "l", true, true)

    get_inside_curly_braces(snippet)
end

function M.CreateCsharpAsyncStaticFuncitonSnippet()
	local function_name = vim.fn.input("Enter function name: ")

	local snippet = "public static async Task " .. function_name .. "() {}"

	vim.api.nvim_put({ snippet }, "l", true, true)

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    get_inside_curly_braces(snippet)
end

function M.CreateCsharpPrivateFuncitonSnippet()
	local function_name = vim.fn.input("Enter function name: ")

	local snippet = "private void " .. function_name .. "() {}"

	vim.api.nvim_put({ snippet }, "l", true, true)

    get_inside_curly_braces(snippet)
end

function M.CreateCsharpPrivateStaticFuncitonSnippet()
	-- Use vim.fn.input() to prompt the user for a function name
	local function_name = vim.fn.input("Enter function name: ")

	local snippet = "private static void " .. function_name .. "() {}"

	vim.api.nvim_put({ snippet }, "l", true, true)

    get_inside_curly_braces(snippet)
end

function M.CreateCsharpIfSnippet()
	local snippet = "if () {}"
	vim.api.nvim_put({ snippet }, "l", true, true)

    get_inside_braces(snippet)
end

return M
