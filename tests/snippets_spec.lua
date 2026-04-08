---@diagnostic disable: undefined-field, duplicate-set-field

-- How to run this test:
-- nvim --headless -c "set runtimepath+=.,./lua" -c "PlenaryBustedFile tests/snippets_spec.lua" -c "qa!"

local snippets = require("dotnet_tools.snippets")

describe("snippets", function()
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
