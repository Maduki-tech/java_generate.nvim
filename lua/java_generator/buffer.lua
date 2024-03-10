local M = {}

--- adding the keybindings to the buffer
local function keybindings(bufnr)
    -- Confirm
    vim.keymap.set(
        "n",
        "<CR>",
        function()
            M.run_select_command()
        end,
        {buffer = bufnr, silent = true}
    )

    -- Close
    vim.keymap.set(
        "n",
        "<ESC>",
        function()
            M.run_toggleCommand()
        end,
        {buffer = bufnr, silent = true}
    )
end

function M.run_toggleCommand()
    local ui = require("java_generator.ui")
    ui.toggle_quick_menu()
end

function M.run_select_command()
    local ui = require("java_generator.ui")
    ui.run_select_command()
end

--- @param bufnr number
function M.navigation(bufnr)
    if vim.api.nvim_buf_get_name(bufnr) == "" then
        vim.api.nvim_buf_set_name(bufnr, "test")
    end

    vim.api.nvim_set_option_value("filetype", "generator", {buf = bufnr})
    vim.api.nvim_set_option_value("buftype", "acwrite", {buf = bufnr})
    keybindings(bufnr)
end

--- @param bufnr number
function M.appendOptions(bufnr)
    vim.api.nvim_buf_set_lines(
        bufnr,
        0,
        -1,
        false,
        {"Generate Tests for all methodes", "Select Tests for methode", "Go to Test file"}
    )
end

return M
