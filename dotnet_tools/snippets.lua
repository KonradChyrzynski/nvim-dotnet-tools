function CreateCsharpNamespaceSnippet()
    local snippet = "namespace Edit {}"
    vim.api.nvim_put({snippet}, "l", true, true)

    -- Move cousor betwen the curly brackets
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    local new_col = col + string.find(snippet, "}") - 1

    vim.api.nvim_win_set_cursor(0, {row - 1, new_col})

    vim.api.nvim_feedkeys('ci{', 'n', false)
end

function CreateCsharpClassSnippet()
    local filepath = vim.fn.getreg('%')
    local base_name = vim.fn.fnamemodify(filepath, ":t:r")

    local snippet = "public sealed class " .. base_name .. " {}"
    vim.api.nvim_put({snippet}, "l", true, true)

    -- Move cousor betwen the curly brackets
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    local new_col = col + string.find(snippet, "}") - 1
    vim.api.nvim_win_set_cursor(0, {row - 1, new_col})

    vim.api.nvim_feedkeys('ci{', 'n', false)
end

function CreateCsharpConstructor()
    local filepath = vim.fn.getreg('%')
    local base_name = vim.fn.fnamemodify(filepath, ":t:r")

    local snippet = "public " .. base_name .. "() {}"

    vim.api.nvim_put({snippet}, "l", true, true)

    -- Move cousor betwen the curly brackets
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    local new_col = col + string.find(snippet, "}") - 1

    vim.api.nvim_win_set_cursor(0, {row - 1, new_col})

    vim.api.nvim_feedkeys('ci{', 'n', false)
end

function CreateCsharpInterfaceSnippet()
    local filepath = vim.fn.getreg('%')
    local base_name = vim.fn.fnamemodify(filepath, ":t:r")

    local snippet = "public interface " .. base_name .. " {}"
    vim.api.nvim_put({snippet}, "l", true, true)

    -- Move cousor betwen the curly brackets
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    local new_col = col + string.find(snippet, "}") - 1

    vim.api.nvim_win_set_cursor(0, {row - 1, new_col})
    vim.api.nvim_feedkeys('ci{', 'n', false)
end

function CreateCsharpFuncitonSnippet()

    local function_name = vim.fn.input("Enter function name: ")

    local snippet = "public void ".. function_name .. "() {}"

    vim.api.nvim_put({snippet}, "l", true, true)

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Calculate the new column position (position of the first parenthesis + 1)
    local new_col = col + string.find(snippet, "}") - 1

    -- Set the cursor position to the correct place (row stays the same, column is new_col)
    vim.api.nvim_win_set_cursor(0, {row - 1, new_col})

    vim.api.nvim_feedkeys('ci{', 'n', false)
end

function CreateCsharpAsycFuncitonSnippet()

    local function_name = vim.fn.input("Enter function name: ")

    local snippet = "public async Task ".. function_name .. "() {}"

    vim.api.nvim_put({snippet}, "l", true, true)

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Calculate the new column position (position of the first parenthesis + 1)
    local new_col = col + string.find(snippet, "}") - 1

    -- Set the cursor position to the correct place (row stays the same, column is new_col)
    vim.api.nvim_win_set_cursor(0, {row - 1, new_col})

    vim.api.nvim_feedkeys('ci{', 'n', false)
end

function CreateCsharpStaticFuncitonSnippet()

    local function_name = vim.fn.input("Enter function name: ")

    local snippet = "public static void ".. function_name .. "() {}"


    vim.api.nvim_put({snippet}, "l", true, true)

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Calculate the new column position (position of the first parenthesis + 1)
    local new_col = col + string.find(snippet, "}") - 1

    -- Set the cursor position to the correct place (row stays the same, column is new_col)
    vim.api.nvim_win_set_cursor(0, {row - 1, new_col})

    -- Enter insert mode to allow the user to type the function name
    vim.api.nvim_feedkeys('ci{', 'n', false)
end

function CreateCsharpAsyncStaticFuncitonSnippet()

    local function_name = vim.fn.input("Enter function name: ")

    local snippet = "public static async Task ".. function_name .. "() {}"

    vim.api.nvim_put({snippet}, "l", true, true)

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Calculate the new column position (position of the first parenthesis + 1)
    local new_col = col + string.find(snippet, "}") - 1

    -- Set the cursor position to the correct place (row stays the same, column is new_col)
    vim.api.nvim_win_set_cursor(0, {row - 1, new_col})

    -- Enter insert mode to allow the user to type the function name
    vim.api.nvim_feedkeys('ci{', 'n', false)
end


function CreateCsharpPrivateFuncitonSnippet()
    local function_name = vim.fn.input("Enter function name: ")

    local snippet = "private void ".. function_name .. "() {}"

    vim.api.nvim_put({snippet}, "l", true, true)

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    -- Get the current cursor position (row and column)

    -- Calculate the new column position (position of the first parenthesis + 1)
    local new_col = col + string.find(snippet, "}") - 1

    -- Set the cursor position to the correct place (row stays the same, column is new_col)
    vim.api.nvim_win_set_cursor(0, {row - 1, new_col})

    -- Enter insert mode to allow the user to type the function name
    vim.api.nvim_feedkeys('ci{', 'n', false)
end


function CreateCsharpPrivateStaticFuncitonSnippet()
    -- Use vim.fn.input() to prompt the user for a function name
    local function_name = vim.fn.input("Enter function name: ")

    local snippet = "private static void ".. function_name .. "() {}"

    vim.api.nvim_put({snippet}, "l", true, true)

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    -- Get the current cursor position (row and column)

    -- Calculate the new column position (position of the first parenthesis + 1)
    local new_col = col + string.find(snippet, "}") - 1

    -- Set the cursor position to the correct place (row stays the same, column is new_col)
    vim.api.nvim_win_set_cursor(0, {row - 1, new_col})

    -- Enter insert mode to allow the user to type the function name
    vim.api.nvim_feedkeys('ci{', 'n', false)
end

function CreateCsharpIfSnippet()
    local snippet = "if () {}"
    vim.api.nvim_put({snippet}, "l", true, true)

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    local new_col = col + string.find(snippet, "%(")

    vim.api.nvim_win_set_cursor(0, {row - 1, new_col})
    vim.api.nvim_feedkeys('ci(', 'n', false)
end

vim.api.nvim_set_keymap('n', '<leader>ns', ':lua CreateCsharpNamespaceSnippet()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cs', ':lua CreateCsharpClassSnippet()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cc', ':lua CreateCsharpConstructor()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ie', ':lua CreateCsharpInterfaceSnippet()<CR>', { noremap = true, silent = true })

--Function snippets
vim.api.nvim_set_keymap('n', '<leader>nf', ':lua CreateCsharpFuncitonSnippet()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>af', ':lua CreateCsharpAsycFuncitonSnippet()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>prf', ':lua CreateCsharpPrivateFuncitonSnippet()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sf', ':lua CreateCsharpStaticFuncitonSnippet()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>nasf', ':lua CreateCsharpAsyncStaticFuncitonSnippet()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rsf', ':lua CreateCsharpPrivateStaticFuncitonSnippet()<CR>', { noremap = true, silent = true })
--Function snippets
vim.api.nvim_set_keymap('n', '<leader>if', ':lua CreateCsharpIfSnippet()<CR>', { noremap = true, silent = true })
