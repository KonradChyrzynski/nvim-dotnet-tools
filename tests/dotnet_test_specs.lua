---@diagnostic disable: undefined-field, duplicate-set-field

-- How to run these tests:
--
-- 1. From within Neovim:
--    :PlenaryBustedFile %
--
-- 2. From the command line (root of the project):
--    nvim --headless -c "set runtimepath+=.,./lua" -c "PlenaryBustedFile tests/dotnet_test_specs.lua" -c "qa!"
--
-- Note: Requires 'nvim-lua/plenary.nvim' to be installed and in your runtimepath.

local finder = require("dotnet_tools.finder")
local build = require("dotnet_tools.build")
local test = require("dotnet_tools.test")
local ef = require("dotnet_tools.csharp_eframework")

describe("finder", function()
    local original_find = vim.fs.find
    local original_expand = vim.fn.expand

    after_each(function()
        vim.fs.find = original_find
        vim.fn.expand = original_expand
    end)

    it("find_csproj returns an empty string when no .csproj is found", function()
        vim.fs.find = function() return {} end
        vim.fn.expand = function() return "/tmp/test" end
        local result = finder.find_csproj()
        assert.are.equal("", result)
    end)

    it("find_csproj returns the first match when .csproj is found", function()
        local expected = "test.csproj"
        vim.fs.find = function() return {expected} end
        vim.fn.expand = function() return "/tmp/test" end
        local result = finder.find_csproj()
        assert.are.equal(expected, result)
    end)

    it("find_csproj uses getcwd when current_dir is empty", function()
        vim.fn.expand = function() return "" end
        vim.fn.getcwd = function() return "/work" end
        vim.fs.find = function(_, opts)
            if opts.path == "/work" then return {"/work/test.csproj"} end
            return {}
        end
        local result = finder.find_csproj()
        assert.are.equal("/work/test.csproj", result)
    end)
end)

describe("snippets", function()
    local snippets = require("dotnet_tools.snippets")
    local original_buf_get_name = vim.api.nvim_buf_get_name
    local original_fnamemodify = vim.fn.fnamemodify
    local original_put = vim.api.nvim_put
    local original_win_get_cursor = vim.api.nvim_win_get_cursor
    local original_win_set_cursor = vim.api.nvim_win_set_cursor
    local original_feedkeys = vim.api.nvim_feedkeys
    local original_getreg = vim.fn.getreg

    after_each(function()
        vim.api.nvim_buf_get_name = original_buf_get_name
        vim.fn.fnamemodify = original_fnamemodify
        vim.api.nvim_put = original_put
        vim.api.nvim_win_get_cursor = original_win_get_cursor
        vim.api.nvim_win_set_cursor = original_win_set_cursor
        vim.api.nvim_feedkeys = original_feedkeys
        vim.fn.getreg = original_getreg
    end)

    it("CreateCsharpClassSnippet inserts the correct class snippet", function()
        vim.fn.getreg = function(reg)
            if reg == "%" then return "MyClass.cs" end
            return ""
        end
        vim.fn.fnamemodify = function(path, mod)
            if mod == ":t:r" and path == "MyClass.cs" then return "MyClass" end
            return path
        end
        local put_text = ""
        vim.api.nvim_put = function(text) put_text = text[1] end

        -- Mocking functions used by get_inside_curly_braces
        vim.api.nvim_win_get_cursor = function() return {1, 0} end
        vim.api.nvim_win_set_cursor = function() end
        vim.api.nvim_feedkeys = function() end

        snippets.CreateCsharpClassSnippet()

        assert.are.equal("public sealed class MyClass {}", put_text)
    end)

    it("CreateCsharpInterfaceSnippet inserts the correct interface snippet", function()
        vim.fn.getreg = function(reg)
            if reg == "%" then return "IMyInterface.cs" end
            return ""
        end
        vim.fn.fnamemodify = function(path, mod)
            if mod == ":t:r" and path == "IMyInterface.cs" then return "IMyInterface" end
            return path
        end

        local put_text = ""
        vim.api.nvim_put = function(text) put_text = text[1] end

        -- Mocking functions used by get_inside_curly_braces
        vim.api.nvim_win_get_cursor = function() return {1, 0} end
        vim.api.nvim_win_set_cursor = function() end
        vim.api.nvim_feedkeys = function() end

        snippets.CreateCsharpInterfaceSnippet()

        assert.are.equal("public interface IMyInterface {}", put_text)
    end)
end)

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

describe("eframework", function()
    local original_cmd = vim.cmd

    after_each(function()
        vim.cmd = original_cmd
    end)

    it("add_migration executes correct dotnet ef command", function()
        local command_executed = ""
        vim.cmd = function(cmd) command_executed = cmd end

        ef.add_migration("InitialCreate", "Project.csproj", "Startup.csproj", "Migrations/")
        assert.are.equal("!dotnet ef migrations add InitialCreate --project Project.csproj --startup-project Startup.csproj -o Migrations/", command_executed)
    end)

    it("generate_migration_script executes correct dotnet ef command", function()
        local command_executed = ""
        vim.cmd = function(cmd) command_executed = cmd end

        ef.generate_migration_script("Migration1", "Migration2", "Project.csproj", "Startup.csproj", "Script.sql")
        assert.are.equal("!dotnet ef migrations script Migration1 Migration2 --project Project.csproj --startup-project Startup.csproj -o Script.sql", command_executed)
    end)
end)
