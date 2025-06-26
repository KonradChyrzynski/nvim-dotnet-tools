local finder = require("dotnet_tools.finder")
local M = {}

function M.test_under_cursor(no_build)
    local csproj = finder.find_csproj()
    if csproj == "" then
        print("No matching .csproj file found for the current file.")
        return
    end

    local cmd = "!dotnet test \"" .. csproj .. "\""
    if no_build then cmd = cmd .. " --no-build" end
    cmd = cmd .. " --filter FullyQualifiedName~" .. vim.fn.expand("<cword>")
    vim.cmd(cmd)
end

function M.test_string(no_build) --> Here it might be worth to copy that to the system register
    local csproj = finder.find_csproj()
    if csproj == "" then return nil end
    local cmd = "!dotnet test \"" .. csproj .. "\""
    if no_build then cmd = cmd .. " --no-build" end
    return cmd .. " --filter FullyQualifiedName~" .. vim.fn.expand("<cword>")
end

return M
