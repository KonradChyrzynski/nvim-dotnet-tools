# Testing Neovim Plugins: A Beginner's Guide

This document explains how we test the `nvim-dotnet-tools` plugin.
Testing Neovim plugins is unique because the code often depends on Neovim's internal functions
(like `vim.fn` or `vim.api`) which don't exist in a standard Lua environment.

## 1. The Tools

We use **Plenary.nvim**, specifically its `busted` implementation.

- **`describe`**: Groups related tests (e.g., "Testing the Finder module").
- **`it`**: Defines an individual test case (e.g., "it should find a .csproj file").
- **`assert`**: Checks if the result matches our expectations.

## 2. The Strategy: Mocking

Since we are running tests in a "headless" (no UI)
Neovim instance, functions like `vim.fn.input()` or `vim.api.nvim_put()`
won't work normally or would require manual interaction. To solve this, we use **Mocking**.

### What is Mocking?

Mocking is replacing a real function with a "fake" one that we control.

**Example from `build_spec.lua`:**
The real `build_current_project` calls `vim.cmd("!dotnet build ...")`.
In a test, we don't actually want to build a .NET project!

1. We save the original `vim.cmd`.
2. We replace `vim.cmd` with a function that just saves the string it was called with.
3. We run our code.
4. We check if the saved string matches the command we expected.
5. **Crucial:** We restore the original `vim.cmd` after the test.

## 3. The Lifecycle: Before and After

To keep tests "clean," we use `after_each`.

- **`after_each`**: Runs after every single `it` block.
  We use this to restore any Neovim functions we mocked,
  ensuring one test doesn't accidentally break the next one.

## 4. How to Read a Test File

Every test follows this pattern:

1. **Setup**: Define variables and "Mock" (fake) the Neovim functions.
2. **Execute**: Call the actual function from our plugin (e.g., `finder.find_csproj()`).
3. **Verify**: Use `assert` to make sure the function returned the right value or called the right command.
4. **Teardown**: Restore the original Neovim functions (handled by `after_each`).

## 5. Running the Tests

You can run all tests at once from your terminal:

```bash
nvim --headless -c "set runtimepath+=.,./lua" -c "PlenaryBustedDirectory tests/" -c "qa!"
```

- `--headless`: Runs Neovim without a GUI.
- `-c`: Runs a command inside Neovim.
- `set runtimepath+=.,./lua`: Tells Neovim where to find your plugin code.
- `PlenaryBustedDirectory tests/`: The magic command that finds and runs all `_spec.lua` files.
