---@diagnostic disable: undefined-field, duplicate-set-field

-- How to run this test:
-- nvim --headless -c "set runtimepath+=.,./lua" -c "PlenaryBustedFile tests/reference_spec.lua" -c "qa!"

local finder = require("dotnet_tools.finder")
local reference = require("dotnet_tools.reference")
local pickers = require("telescope.pickers")

describe("reference", function()
    local original_search = finder.search_for_csproj_files
    local original_pickers_new = pickers.new

    after_each(function()
        finder.search_for_csproj_files = original_search
        pickers.new = original_pickers_new
    end)

    it("AddDotnetProjectReferences calls search_for_csproj_files", function()
        local called = false
        finder.search_for_csproj_files = function(callback)
            called = true
            assert.is_function(callback)
        end

        reference.AddDotnetProjectReferences()
        assert.is_true(called)
    end)

    it("pick_main_csproj_for_reference (internal via AddDotnetProjectReferences) starts telescope picker", function()
        local picker_opts = nil
        pickers.new = function(opts, config)
            picker_opts = config
            return { find = function() end }
        end

        -- We need to trigger the callback that AddDotnetProjectReferences passes to search_for_csproj_files
        local saved_callback = nil
        finder.search_for_csproj_files = function(callback)
            saved_callback = callback
        end

        reference.AddDotnetProjectReferences()
        saved_callback({"Proj1.csproj", "Proj2.csproj"})

        assert.are.equal("Select Main Project", picker_opts.prompt_title)
    end)
end)
