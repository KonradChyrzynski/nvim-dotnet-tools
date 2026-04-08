---@diagnostic disable: undefined-field, duplicate-set-field

-- How to run this test:
-- nvim --headless -c "set runtimepath+=.,./lua" -c "PlenaryBustedFile tests/csharp_eframework_spec.lua" -c "qa!"

local ef = require("dotnet_tools.csharp_eframework")

describe("eframework", function()
    local original_cmd = vim.cmd

    after_each(function()
        vim.cmd = original_cmd
    end)

    it("add_migration executes correct dotnet ef command", function()
        local command_executed = ""
        vim.cmd = function(cmd) command_executed = cmd end
        
        ef.add_migration("InitialCreate", "Project.csproj", "Startup.csproj", "Migrations/")
        local expected = "!dotnet ef migrations add InitialCreate --project Project.csproj " ..
                         "--startup-project Startup.csproj -o Migrations/"
        assert.are.equal(expected, command_executed)
    end)

    it("generate_migration_script executes correct dotnet ef command", function()
        local command_executed = ""
        vim.cmd = function(cmd) command_executed = cmd end
        
        ef.generate_migration_script("Migration1", "Migration2", "Project.csproj", "Startup.csproj", "Script.sql")
        local expected = "!dotnet ef migrations script Migration1 Migration2 --project Project.csproj " ..
                         "--startup-project Startup.csproj -o Script.sql"
        assert.are.equal(expected, command_executed)
    end)
end)
