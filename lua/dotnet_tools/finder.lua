local Job = require("plenary.job")
local M = {}

function M.find_csproj()
    local dir = vim.fn.expand('%:p:h') -- start from current file's directory
    for _ = 1, 5 do
        local csproj = vim.fn.glob(dir .. "/*.csproj", 0, 1)
        if #csproj > 0 then
            return csproj[1]
        end
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then break end -- reached root or can't go higher
        dir = parent
    end
    return ""
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


