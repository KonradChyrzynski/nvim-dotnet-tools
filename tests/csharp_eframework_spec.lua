---@diagnostic disable: undefined-field, duplicate-set-field

-- How to run this test:
-- nvim --headless -c "set runtimepath+=.,./lua" -c "PlenaryBustedFile tests/csharp_eframework_spec.lua" -c "qa!"

local ef = require("dotnet_tools.csharp_eframework")

describe("eframework", function()
    local original_run_ef_command = ef.run_ef_command
    local last_args = {}

    before_each(function()
        ef.run_ef_command = function(args)
            last_args = args
        end
    end)

    after_each(function()
        ef.run_ef_command = original_run_ef_command
        last_args = {}
    end)

    it("add_migration constructs correct arguments", function()
        ef.add_migration("InitialCreate", "Project.csproj", "Startup.csproj", "Migrations/")
        
        local expected = {
            "migrations", "add", "InitialCreate",
            "--project", "Project.csproj",
            "--startup-project", "Startup.csproj",
            "--output-dir", "Migrations/"
        }
        
        assert.are.same(expected, last_args)
    end)

    it("script_migration constructs correct arguments with all options", function()
        ef.script_migration("Migration1", "Migration2", "Script.sql", "Project.csproj", "Startup.csproj")
        
        local expected = {
            "migrations", "script", "Migration1", "Migration2",
            "--project", "Project.csproj",
            "--startup-project", "Startup.csproj",
            "--output", "Script.sql"
        }
        
        assert.are.same(expected, last_args)
    end)

    it("script_migration constructs correct arguments with default options", function()
        ef.script_migration("", "", "", "Project.csproj", "Startup.csproj")
        
        local expected = {
            "migrations", "script",
            "--project", "Project.csproj",
            "--startup-project", "Startup.csproj"
        }
        
        assert.are.same(expected, last_args)
    end)

    it("database_update constructs correct arguments", function()
        ef.database_update("TargetMig", "Project.csproj", "Startup.csproj")
        
        local expected = {
            "database", "update", "TargetMig",
            "--project", "Project.csproj",
            "--startup-project", "Startup.csproj"
        }
        
        assert.are.same(expected, last_args)
    end)

    it("database_drop constructs correct arguments", function()
        ef.database_drop("Project.csproj", "Startup.csproj")
        
        local expected = {
            "database", "drop", "--force",
            "--project", "Project.csproj",
            "--startup-project", "Startup.csproj"
        }
        
        assert.are.same(expected, last_args)
    end)
end)
