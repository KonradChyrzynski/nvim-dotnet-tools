local Job = require("plenary.job")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local M = {}

local function run_dotnet_sln_command(sln, refs, command, success_msg)
	local args = { "sln", sln, command }
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
			if full_output:match(success_msg) then
				vim.notify("Projects(s) " .. success_msg .. full_output, vim.log.levels.INFO)
			elseif code == 0 then
				vim.notify("dotnet exited with code 0:\n" .. full_output, vim.log.levels.INFO)
			else
				vim.notify("dotnet failed:\n" .. full_output, vim.log.levels.ERROR)
			end
		end),
	}):start()
end

local function run_dotnet_sln_add(sln, refs)
	run_dotnet_sln_command(sln, refs, "add", "added to the solution")
end

local function run_dotnet_sln_remove(sln, refs)
	run_dotnet_sln_command(sln, refs, "remove", "removed from the solution")
end

local function run_dotnet_add(main_proj, refs)
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
		end),
	}):start()
end

local function pick_projects_to_reference(csproj_files, main_csproj)
	local other_projects = vim.tbl_filter(function(p)
		return p ~= main_csproj
	end, csproj_files)

	pickers
		.new({}, {
			prompt_title = "Select Projects to Reference",
			finder = finders.new_table({ results = other_projects }),
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

					run_dotnet_add(main_csproj, refs)
					actions.close(prompt_bufnr)
				end)

				map("i", "<CR>", actions.select_default)
				map("i", "<Tab>", actions.toggle_selection + actions.move_selection_worse)
				map("i", "<S-Tab>", actions.toggle_selection + actions.move_selection_better)
				return true
			end,
		})
		:find()
end

--TODO: I think it is possible to also add .sln to solutions, extend it to support the .sln and slnx files
--It would create a lot of noise in the selector so it might require some selector like 1. csproj 2. all
--Or 2 different functions
local function pick_projects_to_reference_for_sln(sln, add)
	local csproj_files = {}
	Job:new({
		command = "rg",
		args = {
			"--files",
			"-g",
			"*.csproj",
			"-g",
			"!**/bin/**",
			"-g",
			"!**/obj/**",
			"--no-ignore",
		},
		on_stdout = function(_, line)
			table.insert(csproj_files, line)
		end,
		on_exit = vim.schedule_wrap(function()
			if #csproj_files == 0 then
				vim.notify("No .csproj files found", vim.log.levels.WARN)
				return
			end
			pickers
				.new({}, {
					prompt_title = "Select Projects to Reference",
					finder = finders.new_table({ results = csproj_files }),
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

							if add == nil or add == true then
								run_dotnet_sln_add(sln, refs)
							else
								run_dotnet_sln_remove(sln, refs)
							end
							actions.close(prompt_bufnr)
						end)

						map("i", "<CR>", actions.select_default)
						map("i", "<Tab>", actions.toggle_selection + actions.move_selection_worse)
						map("i", "<S-Tab>", actions.toggle_selection + actions.move_selection_better)
						return true
					end,
				})
				:find()
		end),
	}):start()
end

local function pick_main_csproj_for_reference(csproj_files)
	pickers
		.new({}, {
			prompt_title = "Select Main Project",
			finder = finders.new_table({ results = csproj_files }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry(prompt_bufnr)
					actions.close(prompt_bufnr)
					local main = selection[1]
					pick_projects_to_reference(csproj_files, main)
				end)
				return true
			end,
		})
		:find()
end

local function pick_main_sln(sln_files, add)
	pickers
		.new({}, {
			prompt_title = "Select Main Solution",
			finder = finders.new_table({ results = sln_files }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry(prompt_bufnr)
					actions.close(prompt_bufnr)
					local main = selection[1]
					pick_projects_to_reference_for_sln(main, add)
				end)
				return true
			end,
		})
		:find()
end

local function pick_sln_command(add)
	local sln_files = {}
	Job:new({
		command = "rg",
		args = {
			"--files",
			"-g",
			"*.{sln,slnx}",
			"-g",
			"!**/bin/**",
			"-g",
			"!**/obj/**",
			"--no-ignore",
		},
		on_stdout = function(_, line)
			table.insert(sln_files, line)
		end,
		on_exit = vim.schedule_wrap(function()
			if #sln_files == 0 then
				vim.notify("No .sln files found", vim.log.levels.WARN)
				return
			end
			pick_main_sln(sln_files, add)
		end),
	}):start()
end

function M.search_for_csproj_files(callback)
	local csproj_files = {}
	Job:new({
		command = "rg",
		args = {
			"--files",
			"-g",
			"*.csproj",
			"-g",
			"!**/bin/**",
			"-g",
			"!**/obj/**",
			"--no-ignore",
		},
		on_stdout = function(_, line)
			table.insert(csproj_files, line)
		end,
		on_exit = vim.schedule_wrap(function()
			if #csproj_files == 0 then
				vim.notify("No .csproj files found", vim.log.levels.WARN)
				return
			end
			callback(csproj_files)
		end),
	}):start()
end

function M.AddDotnetProjectReferences()
    M.search_for_csproj_files(pick_main_csproj_for_reference)
end

function M.AddDotnetProjectReferencesToSln()
	pick_sln_command(true)
end

function M.RemoveDotnetProjectReferencesFromSln()
	pick_sln_command(false)
end

return M
