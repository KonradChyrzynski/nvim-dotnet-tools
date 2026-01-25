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

function M.get_test_string(no_build, test_under_cursor)
    local csproj = finder.find_csproj()
    if csproj == "" then return nil end
    local cmd = "dotnet test \"" .. csproj .. "\""
    if no_build then cmd = cmd .. " --no-build" end
    if test_under_cursor then cmd = cmd .. " --filter FullyQualifiedName~" .. vim.fn.expand("<cword>") end
    vim.fn.setreg('*', cmd)
    print("Test string saved: " .. cmd)
end

return M
