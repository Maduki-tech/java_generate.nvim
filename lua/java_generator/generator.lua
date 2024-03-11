local ts = require("vim.treesitter")
local ts_query = require("vim.treesitter.query")
local Logger = require("java_generator.logger")

---@class Generator
---@field currentPath string
---@field targetPath string
---@field className string
---@field methodes string[]
local Generator = {}

---@return Generator
function Generator:new()
    local o =
        setmetatable(
        {
            currentPath = nil,
            targetPath = nil,
            className = nil,
            methodes = nil
        },
        self
    )
    return o
end

Generator.__index = Generator

local function get_all_methodes()
    local parser = ts.get_parser(0, "java")
    local root_tree = parser:parse()[1]:root() -- Get the root of the syntax tree

    local query =
        ts_query.parse("java", [[
    (method_declaration
        name: (identifier) @method_name
        )
    
    ]])

    local methodes = {}

    for _, node in query:iter_captures(root_tree, 0, 0, -1) do
        if node then
            local name = vim.treesitter.get_node_text(node, 0)
            Logger:log("name " .. name)
            table.insert(methodes, name)
        end
    end

    return methodes
end

function Generator:get_Methodes()
    local methodes = get_all_methodes()
    for _, methode in ipairs(methodes) do
        print(methode)
    end
end

return Generator:new()
