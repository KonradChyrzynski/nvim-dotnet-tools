local M = {}

function M.create_console_project()
    local name = vim.fn.input("Enter project name: ")
    vim.cmd("!dotnet new console -n " .. name)
end

return M
