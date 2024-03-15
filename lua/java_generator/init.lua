local M = {}
local ui = require("java_generator.ui")
local Generator = require("java_generator.generator")

function M.setup()
    vim.keymap.set("n", "<leader>ta", ui.toggle_quick_menu, {silent = true})
    vim.keymap.set(
        "n",
        "<leader>tb",
        (function()
            Generator:generate_test_file({})
        end),
        {silent = true}
    )
end

return M
