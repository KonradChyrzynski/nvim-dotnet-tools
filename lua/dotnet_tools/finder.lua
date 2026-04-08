local Job = require("plenary.job")
local M = {}

function M.find_csproj()
    local current_dir = vim.fn.expand('%:p:h')
    -- Zabezpieczenie: jeśli jesteś w pustym buforze, użyjemy głównego katalogu roboczego
    if current_dir == "" then
        current_dir = vim.fn.getcwd()
    end

    -- Wyszukuje pierwszy plik z końcówką .csproj idąc w górę drzewa
    local match = vim.fs.find(function(name)
        return name:match('%.csproj$')
    end, {
        upward = true,
        path = current_dir,
        type = 'file'
    })

    -- vim.fs.find zwraca tablicę, więc pobieramy pierwszy element. 
    -- Jeśli nic nie znajdzie, zwracamy pusty string.
    return match[1] or ""
end

function M.search_for_csproj_files(callback)
	local csproj_files = {}
	Job:new({
		command = "rg",
		args = {
			"--files",
			"-g",
			"*.csproj",
			"-g",
			"!**/bin/**",
			"-g",
			"!**/obj/**",
			"--no-ignore",
		},
		on_stdout = function(_, line)
			table.insert(csproj_files, line)
		end,
		on_exit = vim.schedule_wrap(function()
			if #csproj_files == 0 then
				vim.notify("No .csproj files found", vim.log.levels.WARN)
				return
			end
			callback(csproj_files)
		end),
	}):start()
end

return M


