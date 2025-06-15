local finder = require("dotnet_tools.finder")
local M = {}

function M.build_current_project()
    local csproj = finder.find_csproj()
    if csproj == "" then
        print("No matching .csproj file found.")
        return
    end
    vim.cmd("!dotnet build \"" .. csproj .. "\"")
end

return M
