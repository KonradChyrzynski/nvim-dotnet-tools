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

    local buf_name = "EF Core Output"
    local existing_buf = vim.fn.bufnr(buf_name)
    if existing_buf ~= -1 then
        vim.api.nvim_buf_delete(existing_buf, { force = true })
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_name(buf, buf_name)
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
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_set_cursor(win, { line_count, 0 })
                end
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

function M.add_migration(name, project, startup, out)
    local function execute(n, p, s, o)
        M.run_ef_command({
            "migrations", "add", n,
            "--project", p,
            "--startup-project", s,
            "--output-dir", o
        })
    end

    if name and project and startup and out then
        execute(name, project, startup, out)
        return
    end

    get_project_and_startup(function(p, s)
        vim.ui.input({ prompt = "Migration Name: " }, function(n)
            if not n or n == "" then return end
            vim.ui.input({ prompt = "Output Directory: ", default = state.output_dir }, function(o)
                if not o or o == "" then o = "Migrations" end
                state.output_dir = o
                execute(n, p, s, o)
            end)
        end)
    end)
end

function M.remove_migration(project, startup)
    local function execute(p, s)
        M.run_ef_command({
            "migrations", "remove",
            "--project", p,
            "--startup-project", s
        })
    end

    if project and startup then
        execute(project, startup)
        return
    end

    get_project_and_startup(function(p, s)
        vim.ui.select({ "No", "Yes" }, { prompt = "Are you sure you want to remove the last migration?" }, function(choice)
            if choice == "Yes" then
                execute(p, s)
            end
        end)
    end)
end

function M.list_migrations(project, startup)
    local function execute(p, s)
        M.run_ef_command({
            "migrations", "list",
            "--project", p,
            "--startup-project", s
        })
    end

    if project and startup then
        execute(project, startup)
        return
    end

    get_project_and_startup(function(p, s)
        execute(p, s)
    end)
end

function M.database_update(target, project, startup)
    local function execute(t, p, s)
        local args = { "database", "update" }
        if t and t ~= "" then
            table.insert(args, t)
        end
        table.insert(args, "--project")
        table.insert(args, p)
        table.insert(args, "--startup-project")
        table.insert(args, s)
        M.run_ef_command(args)
    end

    if project and startup then
        execute(target, project, startup)
        return
    end

    get_project_and_startup(function(p, s)
        vim.ui.input({ prompt = "Target Migration (optional): " }, function(t)
            execute(t, p, s)
        end)
    end)
end

function M.database_drop(project, startup)
    local function execute(p, s)
        M.run_ef_command({
            "database", "drop", "--force",
            "--project", p,
            "--startup-project", s
        })
    end

    if project and startup then
        execute(project, startup)
        return
    end

    get_project_and_startup(function(p, s)
        vim.ui.select({ "No", "Yes" }, { prompt = "Are you sure you want to DROP the database?" }, function(choice)
            if choice == "Yes" then
                execute(p, s)
            end
        end)
    end)
end

function M.script_migration(from, to, output, project, startup)
    local function execute(f, t, o, p, s)
        local args = { "migrations", "script" }
        if f and f ~= "" then
            table.insert(args, f)
            if t and t ~= "" then
                table.insert(args, t)
            end
        end

        table.insert(args, "--project")
        table.insert(args, p)
        table.insert(args, "--startup-project")
        table.insert(args, s)

        if o and o ~= "" then
            table.insert(args, "--output")
            table.insert(args, o)
        end

        M.run_ef_command(args)
    end

    if project and startup then
        execute(from, to, output, project, startup)
        return
    end

    get_project_and_startup(function(p, s)
        vim.ui.input({ prompt = "From Migration (optional): " }, function(f)
            vim.ui.input({ prompt = "To Migration (optional): " }, function(t)
                vim.ui.input({ prompt = "Output File (optional, e.g. script.sql): " }, function(o)
                    execute(f, t, o, p, s)
                end)
            end)
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
        "Script Migration",
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
        elseif choice == "Script Migration" then
            M.script_migration()
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
