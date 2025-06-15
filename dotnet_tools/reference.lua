local Job = require("plenary.job")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local M = {}

function M.run_dotnet_add(main_proj, refs)
  local args = { "add", main_proj, "reference" }
  vim.list_extend(args, refs)

  local output = {}
  Job:new({
    command = "dotnet",
    args = args,
    on_stdout = function(_, line)
      table.insert(output, line)
    end,
    on_stderr = function(_, line)
      table.insert(output, "[ERR] " .. line)
    end,
    on_exit = vim.schedule_wrap(function(code)
      local full_output = table.concat(output, "\n")
      if full_output:match("added to the project") then
        vim.notify("Reference(s) added successfully:\n" .. full_output, vim.log.levels.INFO)
      elseif code == 0 then
        vim.notify("dotnet exited with code 0:\n" .. full_output, vim.log.levels.INFO)
      else
        vim.notify("dotnet failed:\n" .. full_output, vim.log.levels.ERROR)
      end
    end)
  }):start()
end

function M.pick_projects_to_reference(csproj_files, main_csproj)
  local other_projects = vim.tbl_filter(function(p)
    return p ~= main_csproj
  end, csproj_files)

  pickers.new({}, {
    prompt_title = "Select Projects to Reference",
    finder = finders.new_table { results = other_projects },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local picker = action_state.get_current_picker(prompt_bufnr)

      actions.select_default:replace(function()
        local selected = picker:get_multi_selection()

        local refs = {}
        if #selected == 0 then
          local sel = action_state.get_selected_entry()
          table.insert(refs, sel[1])
        else
          for _, entry in ipairs(selected) do
            table.insert(refs, entry[1])
          end
        end

        M.run_dotnet_add(main_csproj, refs)
        actions.close(prompt_bufnr)
      end)

      map("i", "<CR>", actions.select_default)
      map("i", "<Tab>", actions.toggle_selection + actions.move_selection_worse)
      map("i", "<S-Tab>", actions.toggle_selection + actions.move_selection_better)
      return true
    end,
  }):find()
end

function M.pick_main_csproj(csproj_files)
  pickers.new({}, {
    prompt_title = "Select Main Project",
    finder = finders.new_table { results = csproj_files },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry(prompt_bufnr)
        actions.close(prompt_bufnr)
        local main = selection[1]
        M.pick_projects_to_reference(csproj_files, main)
      end)
      return true
    end
  }):find()
end

function M.AddDotnetProjectReferences()
  local csproj_files = {}
  Job:new({
    command = "rg",
    args = {
      "--files",
      "-g", "*.csproj",
      "-g", "!**/bin/**",
      "-g", "!**/obj/**",
      "--no-ignore"
    },
    on_stdout = function(_, line)
      table.insert(csproj_files, line)
    end,
    on_exit = vim.schedule_wrap(function()
      if #csproj_files == 0 then
        vim.notify("No .csproj files found", vim.log.levels.WARN)
        return
      end
      M.pick_main_csproj(csproj_files)
    end)
  }):start()
end

function M.SearchCsprojFiles()
  local results = {}

  Job:new({
    command = "rg",
    args = {
      "--files",
      "-g", "*.csproj",
      "-g", "!**/bin/**",
      "--no-ignore"
    },
    on_stdout = function(_, line)
      table.insert(results, {
        filename = line,
        lnum = 1,
        col = 1,
        text = line,
      })
    end,
    on_exit = function()
      if #results == 0 then
        vim.schedule(function()
          vim.api.nvim_out_write("No .csproj files found\n")
        end)
        return
      end

      vim.schedule(function()
        vim.fn.setqflist({}, " ", {
          title = ".csproj files",
          items = results,
        })
        vim.cmd("copen")
      end)
    end,
  }):start()
end

return M
