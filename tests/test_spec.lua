---@diagnostic disable: undefined-field, duplicate-set-field

-- How to run this test:
-- nvim --headless -c "set runtimepath+=.,./lua" -c "PlenaryBustedFile tests/test_spec.lua" -c "qa!"

local finder = require("dotnet_tools.finder")
local test = require("dotnet_tools.test")

describe("test", function()
    local original_find_csproj = finder.find_csproj
    local original_cmd = vim.cmd
    local original_expand = vim.fn.expand
    local original_setreg = vim.fn.setreg

    after_each(function()
        finder.find_csproj = original_find_csproj
        vim.cmd = original_cmd
        vim.fn.expand = original_expand
        vim.fn.setreg = original_setreg
    end)

    it("test_under_cursor executes the correct dotnet test command", function()
        local csproj = "MyProject.csproj"
        finder.find_csproj = function() return csproj end
        vim.fn.expand = function() return "MyTest" end

        local command_executed = ""
        vim.cmd = function(cmd) command_executed = cmd end

        test.test_under_cursor(false)
        local expected = "!dotnet test \"MyProject.csproj\" " ..
                         "--filter FullyQualifiedName~MyTest"
        assert.are.equal(expected, command_executed)
    end)

    it("test_under_cursor executes with --no-build when requested", function()
        local csproj = "MyProject.csproj"
        finder.find_csproj = function() return csproj end
        vim.fn.expand = function() return "MyTest" end

        local command_executed = ""
        vim.cmd = function(cmd) command_executed = cmd end

        test.test_under_cursor(true)
        local expected = "!dotnet test \"MyProject.csproj\" " ..
                         "--no-build --filter FullyQualifiedName~MyTest"
        assert.are.equal(expected, command_executed)
    end)

    it("get_test_string saves correct command to register *", function()
        local csproj = "MyProject.csproj"
        finder.find_csproj = function() return csproj end
        vim.fn.expand = function() return "MyTest" end

        local reg_name = ""
        local reg_val = ""
        vim.fn.setreg = function(name, val) reg_name = name; reg_val = val end

        -- Mock print
        local original_print = print
        _G.print = function() end

        test.get_test_string(false, true)

        assert.are.equal("*", reg_name)
        local expected = "dotnet test \"MyProject.csproj\" " ..
                         "--filter FullyQualifiedName~MyTest"
        assert.are.equal(expected, reg_val)

        _G.print = original_print
    end)

    it("get_test_string saves command without test_under_cursor filter", function()
        local csproj = "MyProject.csproj"
        finder.find_csproj = function() return csproj end

        local reg_val = ""
        vim.fn.setreg = function(_, val) reg_val = val end

        -- Mock print
        local original_print = print
        _G.print = function() end

        test.get_test_string(true, false)

        assert.are.equal("dotnet test \"MyProject.csproj\" --no-build", reg_val)

        _G.print = original_print
    end)
end)
