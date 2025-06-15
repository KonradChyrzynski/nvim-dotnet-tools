local finder = require("dotnet_tools.finder")
local M = {}

function M.create_console_project()
    local name = vim.fn.input("Enter project name: ")
    vim.cmd("!dotnet new console -n " .. name)
end

function M.add_common_nugets()
    local csproj = finder.find_csproj()
    if csproj == "" then
        print("No matching .csproj file found.")
        return
    end
    -- In the future, this could call Telescope UI to pick packages
    vim.cmd('!dotnet add "' .. csproj .. '" package Microsoft.EntityFrameworkCore.SqlServer')
end

return M
