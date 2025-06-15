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
| `tests.lua`                 | Runs tests under cursor / generates test commands            | ✅ Finished     |
| `snippets.lua`              | Inserts boilerplate C# code with smart cursor movement       | ✅ Finished     |
| `reference.lua`             | Adds project references interactively using Telescope         | ✅ Finished     |
| `csharp_eframework.lua`     | Run EF Core commands like migration and script generation     | ✅ Finished     |
| `ui.lua`                    | Placeholder for popup UI logic (planned)                     | 🚧 In Progress |

---

## ⚙️ Installation

Use with your favorite Neovim plugin manager. Example with [`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
{
  "yourgithub/dotnet_tools.nvim",
  config = function()
    -- require or set up if necessary
  end
}
```lua
Or clone it manually:

git clone https://github.com/yourusername/dotnet_tools.nvim ~/.config/nvim/lua/dotnet_tools

🚀 Usage
Test Utilities (tests.lua)

```lua
-- Run test under cursor
:lua require("dotnet_tools.tests").test_under_cursor()

-- Generate test command string for copy/paste
:lua print(require("dotnet_tools.tests").test_string())
```lua

Build Tool (build.lua)

```lua
-- Build the current C# project
:lua require("dotnet_tools.build").build_current_project()

Add Project References (reference.lua)
-- Launch Telescope UI to add project references
:lua require("dotnet_tools.reference").AddDotnetProjectReferences()

Entity Framework CLI Helper (csharp_eframework.lua)
-- Add migration
:lua Add_migration("MigrationName", "YourProject.csproj", "StartupProject.csproj", "Migrations/")

-- Generate migration script
:lua Generate_migration_script("Initial", "Current", "YourProject.csproj", "StartupProject.csproj", "Scripts/")
```lua

snippets.lua
Keybindings (normal mode):

Keybinding	Description
<leader>ns	Create namespace
<leader>cs	Create class
<leader>cc	Create constructor
<leader>ie	Create interface
<leader>nf	Create public function
<leader>af	Create async function
<leader>prf	Create private function
<leader>sf	Create static function
<leader>nasf	Create async static function
<leader>rsf	Create private static function
<leader>if	Insert if () {} block

📌 Notes
All commands use the nearest .csproj found within 5 parent directories of the current file.

Telescope is required for reference management (dependency on nvim-telescope/telescope.nvim and nvim-lua/plenary.nvim).

🛠 TODO
 ui.lua: Implement interactive popup-based UI (e.g., for status or input)
 Add automated tests
