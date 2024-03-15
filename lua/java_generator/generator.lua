local ts = require("vim.treesitter")
local ts_query = require("vim.treesitter.query")
local Logger = require("java_generator.logger")

---Fill the paths of the current file and the target file
---@return {currentPath: string, targetPath: string, className: string}
local function fill_paths(buffer_id)
    -- Retrieve the file's full path for the specified buffer
    local buffer_file_path = vim.api.nvim_buf_get_name(buffer_id)
    -- Try to find an LSP client with a root directory defined for the specified buffer
    local lsp_root_dir = nil
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client.config.root_dir and vim.api.nvim_buf_is_loaded(buffer_id) then
            lsp_root_dir = client.config.root_dir
            break -- Found an LSP client with a root dir, no need to check further
        end
    end

    if not lsp_root_dir then
        print("No LSP client with root directory found for buffer " .. buffer_id)
        return {}
    end

    -- Calculate the relative path from the root directory to the buffer's file
    local relative_path = buffer_file_path:sub(#lsp_root_dir + 1)

    local currentPath = buffer_file_path
    local targetPath = relative_path:gsub("%.java$", "Test.java"):gsub("main", "test")
    local className = relative_path:gsub(".*/", ""):gsub("%.java$", "Test")

    -- Assuming Logger:log is correctly defined elsewhere
    Logger:log("Buffer ID: " .. buffer_id)
    Logger:log("currentPath: " .. currentPath)
    Logger:log("targetPath: " .. targetPath)
    Logger:log("className: " .. className)

    return {currentPath = currentPath, targetPath = targetPath, className = className}
end

---Using the treesitter to get all the methodes in the current file
---@return {methode_name: string, methode_parameter: string}[]
local function get_all_methods(current_buffer)
    print("In Function Buffer ID: " .. vim.api.nvim_get_current_buf())
    local parser = ts.get_parser(current_buffer, "java")
    local root_tree = parser:parse()[1]:root()

    local query =
        ts_query.parse(
        "java",
        [[
            (method_declaration
                name: (identifier) @method_name
                parameters: (formal_parameters) @method_parameters
            )
        ]]
    )

    local methods = {}

    for _, match in query:iter_matches(root_tree, current_buffer, 0, -1) do
        local method_name_node, method_parameters_node
        for id, node in ipairs(match) do
            local capture_name = query.captures[id]
            if capture_name == "method_name" then
                method_name_node = node
            elseif capture_name == "method_parameters" then
                method_parameters_node = node
            end
        end

        if method_name_node and method_parameters_node then
            local method_name = vim.treesitter.get_node_text(method_name_node, current_buffer)
            local method_parameters = vim.treesitter.get_node_text(method_parameters_node, current_buffer)
            table.insert(methods, {method_name, method_parameters})
        end
    end
    print("Methods function: " .. vim.inspect(methods))
    return methods
end

---@class Generator
---@field currentPath string
---@field targetPath string
---@field className string
---@field methodes {methode_name: string, methode_parameter: string}[]
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

function Generator:get_methodes()
    return self.methodes
end

function Generator:get_currentPath()
    return self.currentPath
end

function Generator:get_targetPath()
    return self.targetPath
end

function Generator:get_className()
    return self.className
end

function Generator:generate(current_buffer)
    local paths = fill_paths(current_buffer)
    local methodes = get_all_methods(current_buffer)
    self.currentPath = paths.currentPath
    self.targetPath = paths.targetPath
    self.className = paths.className
    self.methodes = methodes
    Logger:log("methodes: " .. vim.inspect(methodes))
    Logger:log("Generated the paths and methodes")
end

---Main file to generate the tests
function Generator:generate_test_file(methodes)
    self.targetPath = self.targetPath:gsub("^/", "")
    local test_file = io.open(self.targetPath, "w")

    if test_file then
        Logger:log("File created")
        test_file:write("package " .. self.className .. ";\n")
        test_file:write("import org.junit.jupiter.api.Test;\n")
        test_file:write("import static org.junit.jupiter.api.Assertions.*;\n")
        test_file:write("public class " .. self.className .. " {\n")
        for _, methode in ipairs(methodes) do
            Logger:log("methode: " .. vim.inspect(methode))
            Logger:log("methode[0]: " .. methode[1])
            Logger:log("methode[1]: " .. methode[2])

            local methode_name = methode[1] ---@type string
            local methode_parameters = methode[2] ---@type string
            Logger:log("public void " .. methode_name .. "_test" .. methode_parameters)
            local function_call = "public void " .. methode_name .. "_test" .. methode_parameters
            test_file:write("\t@Test\n")
            test_file:write("\t" .. function_call .. "{\n")
            test_file:write("\t\t// TODO: write the test for the " .. methode[1] .. " methode\n")
            test_file:write("\t}\n")
        end
        test_file:write("}\n")
        test_file:close()

        -- open the file
        vim.cmd("e " .. self.targetPath)
    else
        Logger:log("File not created")
    end
end

return Generator:new()
