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
	local command = string.format("migrations add %s", migration_name)
	M.run_dotnet_ef_command(command, project_path, startup_project_path, output_path)
end

-- Example usage: Running a script generation command
function M.generate_migration_script(from_migration, to_migration, project_path, startup_project_path, output_path)
	local command = string.format("migrations script %s %s", from_migration, to_migration)
	M.run_dotnet_ef_command(command, project_path, startup_project_path, output_path)
end

return M
