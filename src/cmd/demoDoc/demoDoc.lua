demoDoc = {}

demoDoc.btn_spiral = ui:Button {
    Name = "btn_spiral",
    Title = "Spiral",
    OnClick = function()
        local sheet = EditorAPI.getActiveWorksheet()
        demoDoc.context.doWithSelection(
            function(selection)
                if selection:isInstanceOf(DocumentAPI.CellRange) then
                    local top    = selection:getBeginRow()
                    local left   = selection:getBeginColumn()
                    local bottom = selection:getLastRow()
                    local right  = selection:getLastColumn()

                    local num    = 1
                    while left <= right and top <= bottom do
                        for c = left, right do
                            sheet:getCell(DocumentAPI.CellPosition(top, c)):setContent(num); num = num + 1
                        end
                        top = top + 1
                        if top > bottom then break end

                        for r = top, bottom do
                            sheet:getCell(DocumentAPI.CellPosition(r, right)):setContent(num); num = num + 1
                        end
                        right = right - 1
                        if left > right then break end

                        for c = right, left, -1 do
                            sheet:getCell(DocumentAPI.CellPosition(bottom, c)):setContent(num); num = num + 1
                        end
                        bottom = bottom - 1
                        if top > bottom then break end

                        for r = bottom, top, -1 do
                            sheet:getCell(DocumentAPI.CellPosition(r, left)):setContent(num); num = num + 1
                        end
                        left = left + 1
                    end
                end
            end
        )
    end
}

demoDoc.btn_testTable = ui:Button {
    Name = "btn_testTable",
    Title = "Test tbl",
    OnClick = function()
        demoDoc.context.doWithSelection(
            function(selection)
                local top       = selection:getBeginRow()
                local left      = selection:getBeginColumn()
                local bottom    = selection:getLastRow()
                local right     = selection:getLastColumn()
                local sheet     = EditorAPI.getActiveWorksheet()
                local generator = require("cmd.demoDoc.tableGenerator")
                local tableData = generator.build(right - left + 1, bottom - top)
                for i, v in ipairs(tableData.schema) do
                    sheet:getCell(DocumentAPI.CellPosition(top, left + i - 1)):setContent(v.title)
                    for j = 1, bottom - top do
                        local cell = sheet:getCell(DocumentAPI.CellPosition(top + j, left + i - 1))
                        cell:setContent(tableData.rows[j].data[v.id])

                        local sellType = "CellFormat_" .. v.dataType
                        cell:setFormat(DocumentAPI[sellType])
                    end
                end
            end
        )
    end
}

demoDoc.btn_showSQL = ui:Button {
    Name = "btn_showSQL",
    Title = "Show SQL",
    OnClick = function()
        local function toNumberIfNumeric(v)
            if type(v) == "string" and v:match("^[-+]?%d+%.?%d*$") then
                local n = tonumber(v)
                if n ~= nil then return n end
            end
            return v
        end

        local function insertCustomerAt00(db)
            demoDoc.context.doWithDocument(function(document)
                local sheet = EditorAPI.getActiveWorksheet()

                local startRow, startCol = 0, 0

                -- 1) Получаем имена колонок customer в объявленном порядке
                local columns = {}
                for info in db:nrows("PRAGMA table_info(customer)") do
                    -- info.name — имя столбца
                    table.insert(columns, info.name)
                end
                if #columns == 0 then
                    EditorAPI.messageBox("Не удалось получить схему customer (пустая таблица или нет прав).")
                    return
                end

                -- 2) Пишем заголовки
                for i, colName in ipairs(columns) do
                    local headerCell = sheet:getCell(DocumentAPI.CellPosition(startRow, startCol + i - 1))
                    headerCell:setContent(colName)
                    -- headerCell:setFormat(DocumentAPI.CellFormat_String)
                end

                -- 3) Забираем строки и вставляем
                local r = startRow + 1
                for row in db:nrows("SELECT * FROM customer") do
                    for c, colName in ipairs(columns) do
                        local v = row[colName]
                        v = toNumberIfNumeric(v)
                        local cell = sheet:getCell(DocumentAPI.CellPosition(r, startCol + c - 1))
                        cell:setContent(v == nil and "nil" or v)
                        -- local fmt = detectFormat(v)
                        -- local cellFormat = DocumentAPI[fmt] or DocumentAPI.CellFormat_String
                        -- cell:setFormat(cellFormat)
                    end
                    r = r + 1
                end
            end)
        end

        -- Пример: если у тебя уже есть открытая БД в переменной db
        -- insertCustomerAt00(db)

        -- Если БД открываешь здесь, раскомментируй и подставь путь:
        -- local sqlite3 = require("sqlite3")
        -- local db = sqlite3.open("path/to/your.db")
        insertCustomerAt00(db)
        -- db:close()
    end

}
-- demoDoc.btn_showSQL:setEnabled(false)

local function buildGrid(rows, cols)
    local grid = {}
    for i = 1, rows do
        grid[i] = {}
        for j = 1, cols do
            grid[i][j] = i .. "_" .. j
        end
    end
    return grid
end

local function ensureTableSize(tbl, rowsNeeded, colsNeeded)
    local currentRows = tbl:getRowsCount()
    local currentCols = tbl:getColumnsCount()

    if currentCols < colsNeeded then
        if currentCols == 0 then
            tbl:insertColumnBefore(0, false, colsNeeded)
        else
            tbl:insertColumnAfter(currentCols - 1, false, colsNeeded - currentCols)
        end
    end

    if currentRows < rowsNeeded then
        if currentRows == 0 then
            tbl:insertRowBefore(0, false, rowsNeeded)
        else
            tbl:insertRowAfter(currentRows - 1, false, rowsNeeded - currentRows)
        end
    end
end

local t = {}
local x = 300
local y = 26
t = buildGrid(x, y)
local squareSize = 100
local t100 = buildGrid(squareSize, squareSize)
local t_table = buildGrid(3000, 20)

local function fillTable(grid, rowsCount, colsCount)
    demoDoc.context.doWithDocument(
        function(document)
            local start_time = os.clock()
            local table0 = document:getBlocks():getTable(0)
            ensureTableSize(table0, rowsCount, colsCount)
            for r = 0, rowsCount - 1 do
                for c = 0, colsCount - 1 do
                    -- прямой доступ к ячейке быстрее, чем enumerate + div/mod
                    table0:getCell(DocumentAPI.CellPosition(r, c)):setContent(grid[r + 1][c + 1])
                end
            end
            local end_time = os.clock()
            local interval = end_time - start_time
            table0:getCell(DocumentAPI.CellPosition(0, 0)):setContent(interval)
        end
    )
end

local function fillTableEnumerate(grid, rowsCount, colsCount)
    demoDoc.context.doWithDocument(
        function(document)
            local start_time = os.clock()
            local table0 = document:getBlocks():getTable(0)
            ensureTableSize(table0, rowsCount, colsCount)
            local cellRange = table0:getCellRange(
                DocumentAPI.CellRangePosition(0, 0, rowsCount - 1, colsCount - 1)
            )
            local index = 0
            for cell in cellRange:enumerate() do
                local row = math.floor(index / colsCount)
                local col = index % colsCount
                cell:setContent(grid[row + 1][col + 1])
                index = index + 1
            end
            local end_time = os.clock()
            local interval = end_time - start_time
            table0:getCell(DocumentAPI.CellPosition(0, 1)):setContent(interval)
        end
    )
end

local function fillTableEnumerateSlice(grid, rowsCount, colsCount)
    local function colToA1(colIndex0)
        local col = colIndex0 + 1
        local name = ""
        while col > 0 do
            local remainder = (col - 1) % 26
            name = string.char(65 + remainder) .. name
            col = math.floor((col - 1) / 26)
        end
        return name
    end

    local chunkCount = 10
    local rowsPerChunk = math.ceil(rowsCount / chunkCount)
    local processedRows = 0
    local chunkIndex = 0

    while processedRows < rowsCount do
        local chunkStart = processedRows
        local chunkEnd = math.min(rowsCount, processedRows + rowsPerChunk) - 1
        local isLastChunk = chunkEnd >= rowsCount - 1
        local currentChunk = chunkIndex

        demoDoc.context.doWithDocument(function(document)
            local chunkStartTime = os.clock()
            local table0 = document:getBlocks():getTable(0)
            ensureTableSize(table0, rowsCount, colsCount)
            local cellRange = table0:getCellRange(
                DocumentAPI.CellRangePosition(chunkStart, 0, chunkEnd, colsCount - 1)
            )
            local index = chunkStart * colsCount
            for cell in cellRange:enumerate() do
                local row = math.floor(index / colsCount)
                local col = index % colsCount
                cell:setContent(grid[row + 1][col + 1])
                index = index + 1
            end

            local chunkEndTime = os.clock()
            local interval = chunkEndTime - chunkStartTime
            table0:getCell(DocumentAPI.CellPosition(0, currentChunk)):setContent(interval)

            if isLastChunk then
                local lastColLetter = colToA1(currentChunk)
                local formula = ("=SUM(A1:%s1)"):format(lastColLetter)
                table0:getCell(DocumentAPI.CellPosition(1, 0)):setContent(formula)
            end
        end)

        processedRows = chunkEnd + 1
        chunkIndex = chunkIndex + 1
    end
end



demoDoc.btn_test100x100 = ui:Button {
    Name = "btn_test300x26",
    Title = "Show test 300x26",
    OnClick = function()
        fillTable(t, x, y)
    end
}

demoDoc.btn_testSquare100x100 = ui:Button {
    Name = "btn_testSquare100x100",
    Title = "Show test 100x100 square",
    OnClick = function()
        fillTable(t100, squareSize, squareSize)
    end
}
demoDoc.btn_testSquare100x100Enum = ui:Button {
    Name = "btn_testSquare100x100Enum",
    Title = "Show test 100x100 enum",
    OnClick = function()
        fillTableEnumerate(t100, squareSize, squareSize)
    end
}
demoDoc.btn_testSquare3000x20 = ui:Button {
    Name = "btn_testSquare3000x20",
    Title = "Show test 3000x20",
    OnClick = function()
        fillTable(t_table, 3000, 20)
    end
}

demoDoc.btn_testSquare3000x20enum = ui:Button {
    Name = "btn_testSquare3000x20enum",
    Title = "Show test 3000x20 enum",
    OnClick = function()
        fillTableEnumerate(t_table, 3000, 20)
    end
}
demoDoc.btn_testSquare3000x20enumFast = ui:Button {
    Name = "btn_testSquare3000x20enumFast",
    Title = "Show test 3000x20 enum Fast",
    OnClick = function()
        fillTableEnumerateSlice(t_table, 3000, 20)
    end
}



demoDoc.lb_info = ui:Label {
    Name = "lb_info",
    Text = ""
}


demoDoc.dialog = ui:Dialog {
    Title = "DemoDoc",
    Enabled = true,
    Size = Forms.Size(-1, -1),
    ui:Column {
        -- information
        ui:Row {
            demoDoc.lb_info
        },
        -- content
        ui:Row {
            ui:Column {
                demoDoc.btn_spiral,
                demoDoc.btn_testTable,
                demoDoc.btn_showSQL,
                demoDoc.btn_test100x100,
                demoDoc.btn_testSquare100x100,
                demoDoc.btn_testSquare100x100Enum,
                demoDoc.btn_testSquare3000x20,
                demoDoc.btn_testSquare3000x20enum,
                demoDoc.btn_testSquare3000x20enumFast,
            }
        },
        ui:Row {

        },
        ui:Row {

        }

    }
}

---@param context Context
function demoDoc.start(context)
    demoDoc.context = context
    local sheet = EditorAPI.getActiveWorksheet()
    local selection = EditorAPI.getSelection()
    -- local addressSettings = DocumentAPI.CellRangeAddressSettings()
    -- addressSettings.isFileNameRequired = true
    -- addressSettings.isWorksheetNameRequired = true
    -- addressSettings.addressFormat = DocumentAPI.CellRangeAddressFormat_A1
    -- addressSettings.isAbsoluteRow = true
    -- addressSettings.isAbsoluteColumn = false
    -- print(selection:getAddress(addressSettings))
    local s = ("beginColumn: %d\nbeginRow: %d\nlastColumn: %d\nlastRow: %d\n")
        :format(selection:getBeginColumn(), selection:getBeginRow(),
            selection:getLastColumn(), selection:getLastRow())
    demoDoc.lb_info:setText(s)
    context.showDialog(demoDoc.dialog)
end

return demoDoc
