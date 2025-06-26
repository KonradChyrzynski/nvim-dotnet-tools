# dotnet_tools.nvim

A lightweight Lua plugin for Neovim to improve .NET and C# development workflow. It provides handy commands for running tests, building projects, managing Entity Framework commands, injecting C# code snippets, and adding project references using Telescope.

---

## 📦 Features

- 🔍 Automatically find the nearest `.csproj` file for the current file
- 🧪 Run individual unit tests under the cursor
- 🔨 Build the nearest project
- 📋 Generate C# code snippets (classes, interfaces, methods, etc.)
- 🧰 Easily add project references using Telescope UI
- ⚙️ Execute common Entity Framework Core CLI commands from within Neovim

---

## 📁 Project Structure

This plugin should be placed under your Neovim Lua config directory, e.g.:

~/.config/nvim/lua/dotnet_tools/


### File Overview

| File                        | Description                                                  | Status         |
|-----------------------------|--------------------------------------------------------------|----------------|
| `finder.lua`                | Finds nearest `.csproj` file relative to current buffer      | ✅ Finished     |
| `build.lua`                 | Builds the current project using the nearest `.csproj`       | ✅ Finished     |
| `tests.lua`                 | Runs tests under cursor / generates test commands            | 🚧 In Progress    |
| `snippets.lua`              | Inserts boilerplate C# code with smart cursor movement       | 🚧 In Progress   |
| `reference.lua`             | Adds project references interactively using Telescope         | ✅ Finished     |
| `csharp_eframework.lua`     | Run EF Core commands like migration and script generation     | 🚧 In Progress  |
| `ui.lua`                    | Placeholder for popup UI logic (planned)                     | 🚧 In Progress |

---

## ⚙️ Installation

Use with your favorite Neovim plugin manager. Example with [`lazy.nvim`](https://github.com/folke/lazy.nvim): -> This might not work yet, use the manual installation.

```lua
{
  "KonradChyrzynski/dotnet_tools.nvim",
  config = function()
    -- require or set up if necessary
  end
}
```

Or clone it manually:

git clone https://github.com/yourusername/dotnet_tools.nvim ~/.config/nvim/lua/dotnet_tools

🚀 Usage
Test Utilities (tests.lua)

```lua
-- Run test under cursor
:lua require("dotnet_tools.tests").test_under_cursor()

-- Generate test command string for copy/paste
:lua print(require("dotnet_tools.tests").test_string())
```
Build Tool (build.lua)
```lua
-- Build the current C# project
:lua require("dotnet_tools.build").build_current_project()
```
Add Project References (reference.lua)
```lua
-- Launch Telescope UI to add project references
:lua require("dotnet_tools.reference").AddDotnetProjectReferences()
```
Entity Framework CLI Helper (csharp_eframework.lua)
```lua
-- Add migration
:lua Add_migration("MigrationName", "YourProject.csproj", "StartupProject.csproj", "Migrations/")
-- Generate migration script
:lua Generate_migration_script("Initial", "Current", "YourProject.csproj", "StartupProject.csproj", "Scripts/")
```

📌 Notes
All commands use the nearest .csproj found within 5 parent directories of the current file.

Telescope is required for reference management (dependency on nvim-telescope/telescope.nvim and nvim-lua/plenary.nvim).

Example config:
```lua
local dotnet_reference = require("dotnet_tools.reference")
local dotnet_test = require("dotnet_tools.test")
local dotnet_build = require("dotnet_tools.build")
local dotnet_snippets = require("dotnet_tools.snippets")

--Add reference
vim.api.nvim_create_user_command("DotnetAddReferences", dotnet_reference.AddDotnetProjectReferences, {})
vim.api.nvim_create_user_command("DotnetSearchCsprojFiles", dotnet_reference.SearchCsprojFiles, {})

local opts = { noremap = true, silent = true }

--Build
vim.keymap.set("n", "<leader>lb", function() dotnet_build.build_current_project() end, { noremap = true, silent = true })

--Tests
vim.keymap.set("n", "<leader>tbn", function() dotnet_test.test_under_cursor(false) end, opts)
vim.keymap.set("n", "<leader>tbcn", function() print(dotnet_test.test_string(false)) end, opts)
vim.keymap.set("n", "<leader>tn", function() dotnet_test.test_under_cursor(true) end, opts)
vim.keymap.set("n", "<leader>tcn", function() print(dotnet_test.test_string(true)) end, opts)

vim.keymap.set("n", "<leader>ns", function() dotnet_snippets.CreateCsharpNamespaceSnippet() end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>cs", function() dotnet_snippets.CreateCsharpClassSnippet() end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>cc", function() dotnet_snippets.CreateCsharpConstructor() end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ie", function() dotnet_snippets.CreateCsharpInterfaceSnippet() end, { noremap = true, silent = true })

--Function snippets
vim.keymap.set("n", "<leader>nf", function() dotnet_snippets.CreateCsharpFuncitonSnippet() end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>af", function() dotnet_snippets.CreateCsharpAsycFuncitonSnippet() end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>prf", function() dotnet_snippets.CreateCsharpPrivateFuncitonSnippet() end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>sf", function() dotnet_snippets.CreateCsharpStaticFuncitonSnippet() end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>nasf", function() dotnet_snippets.CreateCsharpAsyncStaticFuncitonSnippet() end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rsf", function() dotnet_snippets.CreateCsharpPrivateStaticFuncitonSnippet() end, { noremap = true, silent = true })
--Function snippets
vim.keymap.set("n", "<leader>if", function() dotnet_snippets.CreateCsharpIfSnippet() end, { noremap = true, silent = true })
```

🛠 TODO
 ui.lua: Implement interactive popup-based UI (e.g., for status or input)
 Add automated tests
