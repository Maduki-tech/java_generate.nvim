local M = {}

function M:run_toggleCommand(key)
    local ui = require("java_generator.ui")
    ui.toggle_quick_menu()
end

--- @param bufnr number
function M.navigation(bufnr)
    if vim.api.nvim_buf_get_name(bufnr) == "" then
        vim.api.nvim_buf_set_name(bufnr, "test")
    end

    vim.api.nvim_set_option_value("filetype", "generator", {buf = bufnr})
    vim.api.nvim_set_option_value("buftype", "acwrite", {buf = bufnr})
end

return M
