local utils = require("java_generator.utils")

---@class GeneratorLog
---@field lines string[]
---@field max_lines number
---@field enable boolean
local GeneratorLog = {}

GeneratorLog.__index = GeneratorLog

---@return GeneratorLog
function GeneratorLog:new()
    local logger =
        setmetatable(
        {
            lines = {},
            max_lines = 100,
            enable = true
        },
        self
    )
    vim.keymap.set("n", "<leader>lg", ShowLogs, {silent = true})

    return logger
end

function GeneratorLog:disable()
    self.enable = false
end

function GeneratorLog:enable()
    self.enable = true
end

---@vararg any
function GeneratorLog:log(...)
    local prcessed = {}
    for i = 1, select("#", ...) do
        local item = select(i, ...)
        if type(item) == "table" then
            item = vim.inspect(item)
        end
        table.insert(prcessed, item)
    end

    local lines = {}
    for _, line in ipairs(prcessed) do
        local split = utils.split(line, "\n")
        for _, l in ipairs(split) do
            if not utils.is_white_space(l) then
                local ll = utils.trim(utils.remove_duplicate_whitespace(l))
                table.insert(lines, ll)
            end
        end
    end

    table.insert(self.lines, table.concat(lines, " "))

    while #self.lines > self.max_lines do
        table.remove(self.lines, 1)
    end
end

function GeneratorLog:clear()
    self.lines = {}
end

function GeneratorLog:show()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, self.lines)
    vim.api.nvim_win_set_buf(0, bufnr)
end

function ShowLogs()
    require("java_generator.logger"):show()
end

return GeneratorLog:new()
