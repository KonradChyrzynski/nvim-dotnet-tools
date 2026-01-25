local Job = require("plenary.job")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local M = {}

--[[
  Prompts the user to pick a root directory for the LSP (Language Server Protocol).
  The `run_lsp_callback` is a function that will be called with the selected path.
  It should start or attach the LSP using the given path as the root directory.
]]
function M.dotnet_pick_root_for_lsp_interactive(run_lsp_callback)
  local sln_files = {}
  Job:new({
    command = "rg",
    args = {
      "--files",
      "-g", "*.sln",
      "-g", "!**/bin/**",
      "-g", "!**/obj/**",
      "--no-ignore"
    },
    on_stdout = function(_, line)
      table.insert(sln_files, line)
    end,
    on_exit = vim.schedule_wrap(function()
      if #sln_files == 0 then
        vim.notify("No .sln files found", vim.log.levels.WARN)
        return
      end
      M.pick_main_sln(sln_files, run_lsp_callback)
    end)
  }):start()
end

function M.pick_main_sln(sln_files, run_lsp_callback)
  pickers.new({}, {
    prompt_title = "Select root directory for LSP",
    finder = finders.new_table { results = sln_files },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry(prompt_bufnr)
        actions.close(prompt_bufnr)
        local main = vim.fn.fnamemodify(selection[1], ":p:h")
        print(main)
        run_lsp_callback(main)
      end)
      return true
    end
  }):find()
end

return M
