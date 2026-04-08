local Job = require("plenary.job")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local dotnet_finders = require("dotnet_tools.finder")

local M = {}

-- Store selected projects for the session to avoid re-picking every time
local state = {
    project = nil,
    startup_project = nil,
    output_dir = "Migrations"
}

local function notify(msg, level)
    vim.notify("EF Core: " .. msg, level or vim.log.levels.INFO)
end

-- Function to run a .NET EF command asynchronously
function M.run_ef_command(args)
    local command = "dotnet"
    local full_args = { "ef" }
    for _, arg in ipairs(args) do
        table.insert(full_args, arg)
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_name(buf, "EF Core Output")
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
        col = math.floor(vim.o.columns * 0.1),
        row = math.floor(vim.o.lines * 0.1),
        style = "minimal",
        border = "rounded",
    })

    local function append_to_buf(line)
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, { line })
                -- Scroll to bottom
                local line_count = vim.api.nvim_buf_line_count(buf)
                vim.api.nvim_win_set_cursor(win, { line_count, 0 })
            end
        end)
    end

    append_to_buf("Running: " .. command .. " " .. table.concat(full_args, " "))
    append_to_buf("--------------------------------------------------")

    Job:new({
        command = command,
        args = full_args,
        on_exit = function(j, return_val)
            vim.schedule(function()
                if return_val == 0 then
                    notify("Command finished successfully", vim.log.levels.INFO)
                    append_to_buf("--------------------------------------------------")
                    append_to_buf("SUCCESS")
                else
                    notify("Command failed", vim.log.levels.ERROR)
                    append_to_buf("--------------------------------------------------")
                    append_to_buf("FAILED with exit code " .. return_val)
                end
            end)
        end,
        on_stdout = function(_, line)
            append_to_buf(line)
        end,
        on_stderr = function(_, line)
            append_to_buf("[ERR] " .. line)
        end,
    }):start()
end

local function get_project_and_startup(callback)
    if state.project and state.startup_project then
        callback(state.project, state.startup_project)
        return
    end

    dotnet_finders.search_for_csproj_files(function(csproj_files)
        pickers.new({}, {
            prompt_title = "Select Project (Context/Models)",
            finder = finders.new_table({ results = csproj_files }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    state.project = vim.fn.fnamemodify(selection[1], ":p:h")

                    -- Now pick startup project
                    pickers.new({}, {
                        prompt_title = "Select Startup Project (API/App)",
                        finder = finders.new_table({ results = csproj_files }),
                        sorter = conf.generic_sorter({}),
                        attach_mappings = function(startup_prompt_bufnr, _)
                            actions.select_default:replace(function()
                                local startup_selection = action_state.get_selected_entry()
                                actions.close(startup_prompt_bufnr)
                                state.startup_project = vim.fn.fnamemodify(startup_selection[1], ":p:h")
                                callback(state.project, state.startup_project)
                            end)
                            return true
                        end,
                    }):find()
                end)
                return true
            end,
        }):find()
    end)
end

function M.add_migration()
    get_project_and_startup(function(project, startup)
        vim.ui.input({ prompt = "Migration Name: " }, function(name)
            if not name or name == "" then return end
            vim.ui.input({ prompt = "Output Directory: ", default = state.output_dir }, function(out)
                if not out or out == "" then out = "Migrations" end
                state.output_dir = out
                M.run_ef_command({
                    "migrations", "add", name,
                    "--project", project,
                    "--startup-project", startup,
                    "--output-dir", out
                })
            end)
        end)
    end)
end

function M.remove_migration()
    get_project_and_startup(function(project, startup)
        vim.ui.select({ "No", "Yes" }, { prompt = "Are you sure you want to remove the last migration?" }, function(choice)
            if choice == "Yes" then
                M.run_ef_command({
                    "migrations", "remove",
                    "--project", project,
                    "--startup-project", startup
                })
            end
        end)
    end)
end

function M.list_migrations()
    get_project_and_startup(function(project, startup)
        M.run_ef_command({
            "migrations", "list",
            "--project", project,
            "--startup-project", startup
        })
    end)
end

function M.database_update()
    get_project_and_startup(function(project, startup)
        vim.ui.input({ prompt = "Target Migration (optional): " }, function(target)
            local args = { "database", "update" }
            if target and target ~= "" then
                table.insert(args, target)
            end
            table.insert(args, "--project")
            table.insert(args, project)
            table.insert(args, "--startup-project")
            table.insert(args, startup)
            M.run_ef_command(args)
        end)
    end)
end

function M.database_drop()
    get_project_and_startup(function(project, startup)
        vim.ui.select({ "No", "Yes" }, { prompt = "Are you sure you want to DROP the database?" }, function(choice)
            if choice == "Yes" then
                M.run_ef_command({
                    "database", "drop", "--force",
                    "--project", project,
                    "--startup-project", startup
                })
            end
        end)
    end)
end

function M.reset_projects()
    state.project = nil
    state.startup_project = nil
    notify("Projects reset")
end

function M.menu()
    local options = {
        "Add Migration",
        "Remove Last Migration",
        "List Migrations",
        "Update Database",
        "Drop Database",
        "Reset Projects Selection",
    }

    vim.ui.select(options, { prompt = "EF Core Commands" }, function(choice)
        if choice == "Add Migration" then
            M.add_migration()
        elseif choice == "Remove Last Migration" then
            M.remove_migration()
        elseif choice == "List Migrations" then
            M.list_migrations()
        elseif choice == "Update Database" then
            M.database_update()
        elseif choice == "Drop Database" then
            M.database_drop()
        elseif choice == "Reset Projects Selection" then
            M.reset_projects()
        end
    end)
end

return M
