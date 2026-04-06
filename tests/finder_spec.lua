---@diagnostic disable: undefined-field, duplicate-set-field

-- How to run this test:
-- nvim --headless -c "set runtimepath+=.,./lua" -c "PlenaryBustedFile tests/finder_spec.lua" -c "qa!"

local finder = require("dotnet_tools.finder")

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
