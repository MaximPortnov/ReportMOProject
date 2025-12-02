--[[
Example usage:

local generator = require("cmd.demoDoc.tableGenerator")
local tableData = generator.build(4, 3)

-- tableData.schema -> metadata for each column
-- tableData.rows   -> generated rows with sample values
]]

local tableGenerator = {}

local DEFAULT_TYPES = {
    "General",
    "Percentage",
    "Number",
    "Text",
    "Currency",
    "Accounting",
    "Date",
    "Time",
    "DateTime",
    "Fraction",
    "Scientific",
}

---Produces a sample value for the given data type.
---@param dataType string
---@param rowIndex integer
---@param colIndex integer
---@return any
local function buildValue(dataType, rowIndex, colIndex)
    if dataType == "General" then
        return ("R%dC%d value"):format(rowIndex, colIndex)
    elseif dataType == "Percentage" then
        return ((rowIndex * colIndex) % 101) / 100
    elseif dataType == "Number" then
        return (rowIndex - 1) * 100 + colIndex
    elseif dataType == "Text" then
        return ("Text %d-%d"):format(rowIndex, colIndex)
    elseif dataType == "Currency" then
        return math.floor(((rowIndex + colIndex) * 123.45) % 10000) / 100
    elseif dataType == "Accounting" then
        return math.floor(((rowIndex * 3 + colIndex * 7) * 1.5) % 10000) / 100
    elseif dataType == "Date" then
        local base = os.time({ year = 2024, month = 1, day = 1 })
        return os.date("%Y-%m-%d", base + (rowIndex + colIndex) * 86400)
    elseif dataType == "Time" then
        local seconds = ((rowIndex - 1) * 3600 + colIndex * 300) % 86400
        return os.date("!%H:%M:%S", seconds)
    elseif dataType == "DateTime" then
        local base = os.time({ year = 2024, month = 1, day = 1, hour = 9 })
        return os.date("%Y-%m-%d %H:%M:%S", base + (rowIndex * 3600) + (colIndex * 60))
    elseif dataType == "Fraction" then
        local numerator = rowIndex * colIndex
        local denominator = colIndex + 1
        return ("%d/%d"):format(numerator, denominator)
    elseif dataType == "Scientific" then
        return ("%0.2e"):format((rowIndex * 10 + colIndex) * 1.234)
    else
        return nil
    end
end

---Creates a descriptor for a single column.
---@param columnIndex integer
---@return table
local function buildColumn(columnIndex)
    local typeIndex = ((columnIndex - 1) % #DEFAULT_TYPES) + 1
    local dataType = DEFAULT_TYPES[typeIndex]

    return {
        id = ("col_%02d"):format(columnIndex),
        title = ("Column %d"):format(columnIndex),
        dataType = dataType,
    }
end

---Builds a row payload keyed by column id.
---@param schema table[]
---@param rowIndex integer
---@return table
local function buildRow(schema, rowIndex)
    local row = {}

    for colIndex, descriptor in ipairs(schema) do
        local value
        value = buildValue(descriptor.dataType, rowIndex, colIndex)
        row[descriptor.id] = value
    end

    return row
end

---Generates a document-like table structure with schema metadata and row data.
---@param columnCount integer
---@param rowCount integer
---@return table
function tableGenerator.build(columnCount, rowCount)
    assert(type(columnCount) == "number" and columnCount > 0, "columnCount must be a positive number")
    assert(type(rowCount) == "number" and rowCount >= 0, "rowCount must be a non-negative number")

    local schema = {}
    for columnIndex = 1, math.floor(columnCount) do
        schema[#schema + 1] = buildColumn(columnIndex)
    end

    local rows = {}
    for rowIndex = 1, math.floor(rowCount) do
        rows[#rows + 1] = {
            index = rowIndex,
            data = buildRow(schema, rowIndex),
        }
    end

    return {
        schema = schema,
        rows = rows,
    }
end

return tableGenerator
