local GeneratorUi = {}
local Buffer = require("java_generator.buffer")
local Logger = require("java_generator.logger")

Generator_win_id = nil
Generator_bufh = nil
Current_buffer = nil

--- Closes the buffer and window
--- Also it is resetting the values to null
local function close_menu()
    if Generator_bufh ~= nil and vim.api.nvim_buf_is_valid(Generator_bufh) then
        vim.api.nvim_buf_delete(Generator_bufh, {force = true})
    end

    if Generator_win_id ~= nil and vim.api.nvim_win_is_valid(Generator_win_id) then
        vim.api.nvim_win_close(Generator_win_id, true)
    end
    Generator_win_id = nil
    Generator_bufh = nil
end

--- Creating the window
---@return {bufnr: number, win_id: number}
local function create_window()
    local width = 60
    local height = 10
    local bufnr = vim.api.nvim_create_buf(false, false)
    local win_id =
        vim.api.nvim_open_win(
        bufnr,
        true,
        {
            relative = "editor",
            title = "Generator",
            row = math.floor(((vim.o.lines - height) / 2) - 1),
            col = math.floor((vim.o.columns - width) / 2),
            height = height,
            width = width,
            style = "minimal",
            border = "single"
        }
    )

    if win_id == 0 then
        vim.api.nvim_buf_delete(bufnr, {force = true})
    end

    Generator_win_id = win_id

    vim.api.nvim_set_option_value("number", true, {win = win_id})

    return {
        bufnr = bufnr,
        win_id = Generator_win_id
    }
end

function GeneratorUi.toggle_quick_menu()

    Current_buffer = vim.api.nvim_get_current_buf()


    if Generator_win_id ~= nil and vim.api.nvim_win_is_valid(Generator_win_id) then
        close_menu()
        return
    end

    local win_info = create_window()

    Generator_win_id = win_info.win_id
    Generator_bufh = win_info.bufnr

    -- Setting up the Buffer UI
    Buffer.appendOptions(Generator_bufh)
    Buffer.navigation(Generator_bufh)
end

function GeneratorUi.run_select_command()
    -- get curretn line number
    local Generator = require("java_generator.generator")
    local line = vim.api.nvim_win_get_cursor(0)[1]
    if line == 1 then
        Logger:log("Line = 1")
        Generator:generate(Current_buffer)
        Logger:log("In UI: " .. vim.inspect(Generator:get_methodes()))
    end
end

return GeneratorUi
