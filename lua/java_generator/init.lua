local M = {}
local ui = require("java_generator.ui")

function M.setup()
	vim.keymap.set("n", "<leader>ta", ui.toggle_quick_menu, {silent = true})
end

return M;
