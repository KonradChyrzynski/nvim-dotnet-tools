-- Function to run a .NET EF command with custom variables
function Run_dotnet_ef_command(command, project_path, startup_project_path, output_path)
  -- Construct the full command string
  local full_command = string.format("dotnet ef %s --project %s --startup-project %s -o %s", command, project_path, startup_project_path, output_path)
  -- Execute the command
  vim.cmd("!" .. full_command)
end

-- Example usage: Running a migration command
function Add_migration(migration_name, project_path, startup_project_path, output_path)
  local command = string.format("migrations add %s", migration_name)
  Run_dotnet_ef_command(command, project_path, startup_project_path, output_path)
end

-- Example usage: Running a script generation command
function Generate_migration_script(from_migration, to_migration, project_path, startup_project_path, output_path)
  local command = string.format("migrations script %s %s", from_migration, to_migration)
  Run_dotnet_ef_command(command, project_path, startup_project_path, output_path)
end

