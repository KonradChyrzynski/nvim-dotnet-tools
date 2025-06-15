local M = {}

function M.find_csproj()
    local dir = vim.fn.expand('%:p:h') -- start from current file's directory
    for _ = 1, 5 do
        local csproj = vim.fn.glob(dir .. "/*.csproj", 0, 1)
        if #csproj > 0 then
            return csproj[1]
        end
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then break end -- reached root or can't go higher
        dir = parent
    end
    return ""
end

return M


