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

--- Generates and inserts a C# namespace snippet based on the current context.
--- 
--- STEP 1: It first attempts to infer the namespace by scanning other `.cs` files 
--- in the same directory to match their namespace declaration.
--- 
--- STEP 2: If no sibling files exist or no namespace is found, it falls back to 
--- finding the nearest `.csproj` file. It constructs the namespace using the 
--- project's name and the relative path of the current directory.
--- 
--- STEP 3: Finally, it inserts the snippet into the buffer and places the cursor 
--- inside the curly braces.
function M.CreateCsharpNamespaceSnippet()
    -- Default fallback name if no namespace can be determined
    local namespace_name = "Temp"

    -- Get the full absolute path of the current buffer and its directory
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir = vim.fn.fnamemodify(current_file, ":h")

    -- STEP 1: Look for other C# files in the same directory
    local cs_files = vim.fn.glob(current_dir .. "/*.cs", false, true)

    for _, file in ipairs(cs_files) do
        -- Skip the file we are currently editing
        if file ~= current_file then
            -- Safely attempt to read the contents of the sibling file
            local ok, lines = pcall(vim.fn.readfile, file)
            if ok then
                -- Iterate through the lines to find a namespace declaration
                for _, line in ipairs(lines) do
                    -- Regex match: looks for 'namespace' followed by spaces and captures the name
                    local match = string.match(line, "^%s*namespace%s+([%w_%.]+)")
                    if match then
                        namespace_name = match
                        break -- Stop reading lines once a namespace is found
                    end
                end
            end
        end
        -- Stop checking other files if we successfully found a namespace
        if namespace_name ~= "Temp" then
            break
        end
    end

    -- STEP 2: Fallback logic using the .csproj file if sibling scan failed
    if namespace_name == "Temp" then
        -- Find the nearest .csproj file going upwards in the directory tree
        local csproj_path = require("dotnet_tools.finder").find_csproj()
        if csproj_path and csproj_path ~= "" then
            -- Extract the directory containing the .csproj and the project name itself
            local project_dir = vim.fn.fnamemodify(csproj_path, ":h")
            local project_name = vim.fn.fnamemodify(csproj_path, ":t:r")

            if current_dir == project_dir then
                -- If we are in the root directory of the project, use just the project name
                namespace_name = project_name
            elseif string.sub(current_dir, 1, #project_dir) == project_dir then
                -- If we are in a subdirectory, calculate the relative path from the project root
                -- '+ 2' skips the project directory length and the trailing slash
                local relative_path = string.sub(current_dir, #project_dir + 2)
                -- Replace directory separators (slashes/backslashes) with dots
                local dot_path = relative_path:gsub("[/\\]", ".")
                -- Concatenate the project name with the dot-separated relative path
                namespace_name = project_name .. "." .. dot_path
                -- Optional: Sanitize the namespace by replacing invalid characters (like hyphens) with underscores
                -- namespace_name = namespace_name:gsub("-", "_"):gsub(" ", "_")
            end
        end
    end

    local snippet = string.format("namespace %s {}", namespace_name)

    -- Insert the text into the buffer at the cursor line
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
