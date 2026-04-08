# Entity Framework Core Extension for Neovim

This extension provides a streamlined interface for running EF Core commands directly from Neovim using Telescope for project selection and a floating scratch buffer for real-time output.

## How to Use

The primary entry point is the `menu()` function. You can map it in your Neovim configuration:

```lua
-- Example mapping
vim.keymap.set('n', '<leader>ef', function() 
    require('dotnet_tools.csharp_eframework').menu() 
end, { desc = "EF Core Menu" })
```

### First Run: Project Selection
The first time you run a command in a session, the extension will ask you to select two projects:
1. **Project (Context/Models):** The project containing your `DbContext` and Migrations.
2. **Startup Project (API/App):** The project EF runs to find configurations (e.g., `appsettings.json` and connection strings).

*These selections are cached for the duration of your Neovim session. Use **Reset Projects Selection** to change them.*

---

## Commands Explanation

### 1. Add Migration
- **Action:** Prompts for a migration name and an output directory (defaulting to `Migrations`).
- **Command:** `dotnet ef migrations add <name> --project <P> --startup-project <S> -o <O>`
- **Usage:** Use this when you've changed your models and want to generate a new migration file.

### 2. Remove Last Migration
- **Action:** Asks for confirmation before removing the last migration that hasn't been applied to the database.
- **Command:** `dotnet ef migrations remove --project <P> --startup-project <S>`
- **Usage:** Use this if you made a mistake in your latest migration and haven't updated the database yet.

### 3. List Migrations
- **Action:** Lists all migrations in the output buffer.
- **Command:** `dotnet ef migrations list --project <P> --startup-project <S>`
- **Usage:** Check which migrations exist and which have been applied.

### 4. Update Database
- **Action:** Prompts for an optional target migration. If left empty, it updates to the latest migration.
- **Command:** `dotnet ef database update [target] --project <P> --startup-project <S>`
- **Usage:** Sync your database schema with your migrations.

### 5. Drop Database
- **Action:** Asks for confirmation before completely deleting the database.
- **Command:** `dotnet ef database drop --force --project <P> --startup-project <S>`
- **Usage:** **Warning!** Deletes all data and the database itself. Useful for clean resets during development.

### 6. Reset Projects Selection
- **Action:** Clears the cached Project and Startup Project paths.
- **Usage:** Use this if you are working in a solution with multiple Contexts or need to switch your Startup project.

---

## Output Window
All commands run asynchronously. A floating window will appear showing:
- The exact command being executed.
- Real-time `stdout` (normal output).
- `[ERR]` prefixed lines for `stderr` (errors).
- A final success or failure notification.

You can close the output window at any time; it will not stop the background process.
