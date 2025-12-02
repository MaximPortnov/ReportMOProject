local socket = require('socket') -- только для sleep; можешь заменить
local json   = require('dkjson') -- любой JSON-модуль, положи в lib/
-- ВНИМАНИЕ: этот модуль БЛОКИРУЮЩИЙ — он не вернёт управление, пока не придёт EXIT


local utils = {}

local function mkdir_p(path)
    local is_windows = package.config:sub(1, 1) == '\\'
    if is_windows then
        os.execute(('mkdir "%s" 2>nul'):format(path))
    else
        os.execute(('mkdir -p "%s" 2>/dev/null'):format(path))
    end
end

local function open_append(path)
    local f = io.open(path, "a+"); assert(f, "cannot open " .. path); f:seek("end", 0); return f
end

local function write_response(path, tbl)
    local f = open_append(path)
    f:write((json.encode(tbl) or "") .. "\n")
    f:flush()
    f:close()
end

-- Выполнение одной команды над документом (расширяй под себя)
local function apply_command(context, msg)
    local ok, result = true, nil

    if msg.cmd == "SET_CELL" then
        local a = msg.args or {}
        context.doWithDocument(function(document)
            local sheet = document:getBlocks():getTable(a.sheet or 0)
            local cell  = sheet:getCell(a.addr or "A1")
            cell:setText(a.text or "")
        end)
        result = { affected = 1 }
    elseif msg.cmd == "GET_CELL" then
        local a = msg.args or {}
        context.doWithDocument(function(document)
            local sheet = document:getBlocks():getTable(a.sheet or 0)
            local cell  = sheet:getCell(a.addr or "A1")
            result      = { value = cell:getFormattedValue() }
        end)
    elseif msg.cmd == "SAVE_AS" then
        local a = msg.args or {}
        context.doWithDocument(function(document)
            document:saveAs(a.path)
        end)
        result = { path = a.path }
    elseif msg.cmd == "EXIT" then
        result = { bye = true }
    else
        ok, result = false, { error = "Unknown command: " .. tostring(msg.cmd) }
    end

    return ok, result
end

utils.runApp = function(context)
    -- 1) PWD: рабочий каталог надстройки
    local work = getWorkingDirectory() -- офиц. функция SDK
    local ipcDir = work .. "/ipc"
    mkdir_p(ipcDir)
    local cmdPath = ipcDir .. "/command.log"
    local rspPath = ipcDir .. "/response.log"

    -- 2) Гарантируем, что файлы существуют
    do
        local f = io.open(cmdPath, "a+"); if f then f:close() end
    end
    do
        local f = io.open(rspPath, "a+"); if f then f:close() end
    end

    -- local path = getWorkingDirectory()
    -- local script = new_path .. "/cmd/main.py"
    -- local is_windows = package.config:sub(1, 1) == '\\'
    -- local cmd
    -- if is_windows then
    --     local py = os.getenv("PYTHONW") or "pythonw"
    --     cmd = string.format('start "" /B "%s" "%s"', py, script)
    -- else
    --     cmd = string.format('nohup python "%s" >/dev/null 2>&1 &', script)
    -- end
    -- os.execute(cmd)
    
    
    -- 3) Запускаем GUI и передаём путь к рабочей папке аргументом
    --    (так надёжнее, чем вычислять в Python; путь уже корректный по SDK)

    local is_windows = package.config:sub(1, 1) == '\\'
    local work_script = work:gsub("(/workspace)(/[^/]+)$", "%2")
    local script = work_script .. "/cmd/externalGUI/main.py"
    local py = os.getenv(is_windows and "PYTHONW" or "PYTHON") or (is_windows and "pythonw" or "python")

    local quoted_work = is_windows and ('"%s"'):format(work) or ("%q"):format(work)
    local quoted_script = is_windows and ('"%s"'):format(script) or ("%q"):format(script)
    local cmd

    if is_windows then
        cmd = string.format('start "" /B %s %s --ipc %s', py, quoted_script, quoted_work)
    else
        cmd = string.format('nohup %s %s --ipc %s >/dev/null 2>&1 &', py, quoted_script, quoted_work)
    end

    os.execute(cmd)

    -- 4) БЛОКИРУЮЩИЙ ЦИКЛ: «тэйл» файла команд до EXIT
    local fin = assert(io.open(cmdPath, "r"))
    fin:seek("end", 0) -- читаем только новые строки

    local running = true
    while running do
        local line = fin:read("*l")
        if not line then
            socket.sleep(0.05)
        else
            local msg, _, err = json.decode(line)
            local id = msg and msg.id or nil
            if not msg then
                write_response(rspPath, { id = id, ok = false, error = "bad json: " .. tostring(err) })
            else
                if msg.cmd == "EXIT" then
                    write_response(rspPath, { id = id, ok = true, result = { bye = true } })
                    running = false
                else
                    local ok, res = pcall(apply_command, context, msg)
                    if ok then
                        local ok2, result = res, select(2, res)
                        write_response(rspPath, { id = id, ok = ok2, result = result })
                    else
                        write_response(rspPath, { id = id, ok = false, error = tostring(res) })
                    end
                end
            end
        end
    end

    fin:close()


end

return utils
