local dotnet_finders = require("finder")
local Job = require("plenary.job")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

--[[
EF CORE PARAMETERS EXPLAINED:
-----------------------------
1. --project (The Logic/Domain):
   The project containing the DbContext and entity models (e.g., MyApp.Infrastructure or MyApp.Data).
   This is the project where EF scans for the database schema and model definitions.

2. --startup-project (The Configuration/Entry):
   The project that Neovim/EF "runs" to find configuration settings. 
   EF reads the appsettings.json from here to retrieve the Connection String 
   and DI container setup. Usually your Web API or Console application. (f. ex. appsettings.json)

3. --output-dir / -o (The Target Folder):
   The directory path (relative to the --project path) where the generated 
   migration C# files will be saved. Usually set to "Migrations".
]]

--TODO: Pick projects with telescope
local M = {}

-- Function to run a .NET EF command with custom variables
function M.run_dotnet_ef_command(command, project_path, startup_project_path, output_path)
	-- Construct the full command string
	local full_command = string.format(
		"dotnet ef %s --project %s --startup-project %s -o %s",
		command,
		project_path,
		startup_project_path,
		output_path
	)

	-- Execute the command
	vim.cmd("!" .. full_command)
end

-- Example usage: Running a migration command
function M.add_migration(migration_name, project_path, startup_project_path, output_path)
    --TODO: Get migration name from user input
	local command = string.format("migrations add %s", migration_name)
	M.run_dotnet_ef_command(command, project_path, startup_project_path, output_path)
end

-- Example usage: Running a script generation command
function M.generate_migration_script(from_migration, to_migration, project_path, startup_project_path, output_path)
    -- TODO: Add search for migration names
	local command = string.format("migrations script %s %s", from_migration, to_migration)
	M.run_dotnet_ef_command(command, project_path, startup_project_path, output_path)
end

local function pick_db_context_project(csproj_files, main_csproj, command)
	local other_projects = vim.tbl_filter(function(p)
		return p ~= main_csproj
	end, csproj_files)

	pickers
		.new({}, {
			prompt_title = "Select db context project",
			finder = finders.new_table({ results = other_projects }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)

				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry(prompt_bufnr)
					actions.close(prompt_bufnr)

					local db_context_project = vim.fn.fnamemodify(selection[1], ":p:h")
                    local startup_project_directory = vim.fn.fnamemodify(main_csproj, ":p:h")

                    if command == "add migration" then
                        M.add_migration("Temp name from", db_context_project, startup_project_directory, "C:\\ef_test")
                    end

				end)

				map("i", "<CR>", actions.select_default)
				map("i", "<Tab>", actions.toggle_selection + actions.move_selection_worse)
				map("i", "<S-Tab>", actions.toggle_selection + actions.move_selection_better)
				return true
			end,
		})
		:find()

end

local function pick_startup_project_for_reference(csproj_files)
	pickers
		.new({}, {
			prompt_title = "Select Startup Project",
			finder = finders.new_table({ results = csproj_files }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry(prompt_bufnr)
					actions.close(prompt_bufnr)
					local main = selection[1]
					pick_db_context_project(csproj_files, main)
				end)
				return true
			end,
		})
		:find()
end

function AddTemp()
    dotnet_finders.search_for_csproj_files(pick_startup_project_for_reference)
end

return M
