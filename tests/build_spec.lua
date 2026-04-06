---@diagnostic disable: undefined-field, duplicate-set-field

-- How to run this test:
-- nvim --headless -c "set runtimepath+=.,./lua" -c "PlenaryBustedFile tests/build_spec.lua" -c "qa!"

local finder = require("dotnet_tools.finder")
local build = require("dotnet_tools.build")

describe("build", function()
    local original_find_csproj = finder.find_csproj
    local original_cmd = vim.cmd

    after_each(function()
        finder.find_csproj = original_find_csproj
        vim.cmd = original_cmd
    end)

    it("build_current_project executes the correct dotnet build command", function()
        local csproj = "MyProject.csproj"
        finder.find_csproj = function() return csproj end
        
        local command_executed = ""
        vim.cmd = function(cmd) command_executed = cmd end
        
        build.build_current_project()
        assert.are.equal("!dotnet build \"MyProject.csproj\"", command_executed)
    end)

    it("build_current_project prints a message when no .csproj is found", function()
        finder.find_csproj = function() return "" end
        
        local command_executed = ""
        vim.cmd = function(cmd) command_executed = cmd end
        
        -- Mock print
        local original_print = print
        local printed_msg = ""
        _G.print = function(msg) printed_msg = msg end
        
        build.build_current_project()
        
        assert.are.equal("", command_executed)
        assert.are.equal("No matching .csproj file found.", printed_msg)
        
        _G.print = original_print
    end)
end)
