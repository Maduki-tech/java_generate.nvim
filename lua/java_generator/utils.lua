
local M = {}

function M.trim(str)
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end
function M.remove_duplicate_whitespace(str)
    return str:gsub("%s+", " ")
end

---Splitting a string into a table
---@param str string to split
---@param sep string to split by
---@return string[]
function M.split(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, s)
    end
    return t
end

function M.is_white_space(str)
    return str:gsub("%s", "") == ""
end


return M
