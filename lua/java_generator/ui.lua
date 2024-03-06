local GeneratorUi = {}
local Buffer = require("java_generator.buffer")

Generator_win_id = nil
Generator_bufh = nil

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

--- @param bufnr number
local function appendOptions(bufnr)
    vim.api.nvim_buf_set_lines(Generator_bufh, 0, -1, false, {"Test", "david"})
end


function GeneratorUi.toggle_quick_menu()
    if Generator_win_id ~= nil and vim.api.nvim_win_is_valid(Generator_win_id) then
        close_menu()
        return
    end

    local win_info = create_window()

    Generator_win_id = win_info.win_id
    Generator_bufh = win_info.bufnr
    appendOptions(Generator_bufh)
    Buffer.navigation(Generator_bufh)
end

return GeneratorUi
