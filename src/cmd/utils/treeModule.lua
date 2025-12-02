-- mobdebug = require("mobdebug")
-- mobdebug.logging(true)
-- mobdebug.start('127.0.0.1', 8172)
-- mobdebug.output("stdout", "r")
-- -@field type integer        @Тип узла (можно использовать для логики отображения)
-- -@field text string         @Отображаемый текст
-- -@field collapsed boolean   @Состояние узла (свёрнут/развёрнут)

local serpent = require("cmd.utils.serpent")

---@class Node
---@field id string|number  @Уникальный идентификатор узла
---@field children Node[]     @Дочерние узлы
---@field object table      @хранимый объект
---@field last boolean
local Node = {}
Node.__index = Node

--- Node:new
---@param id integer
---@param children Node[]
---@param object table
function Node:new(id, children, object)
    local obj = setmetatable({}, Node)
    obj.id = id or -1
    obj.children = children or {}
    obj.object = object or {}
    obj.last = true
    -- obj.type = type or -1
    -- obj.text = text or ""
    -- obj.collapsed = true
    return obj
end

---@class Tree
---@field children Node[]
---@field private _id_generator integer
local Tree = {}
Tree.__index = Tree

local function reapplyNodeMeta(nodes)
    if type(nodes) ~= "table" then
        return
    end
    local lastIndex = #nodes
    for index, node in ipairs(nodes) do
        if type(node.children) ~= "table" then
            node.children = {}
        end
        if type(node.object) ~= "table" then
            node.object = {}
        end
        node.last = (index == lastIndex)
        setmetatable(node, Node)
        reapplyNodeMeta(node.children)
    end
end

local function getMaxNodeId(nodes, currentMax)
    currentMax = currentMax or 0
    if type(nodes) ~= "table" then
        return currentMax
    end
    for _, node in ipairs(nodes) do
        if type(node.id) == "number" and node.id > currentMax then
            currentMax = node.id
        end
        currentMax = getMaxNodeId(node.children, currentMax)
    end
    return currentMax
end

--- new
---@return Tree
function Tree:new()
    local obj = setmetatable({}, Tree)
    obj._id_generator = 2
    obj.children = {}
    return obj
end

-- Функция для рекурсивного вывода таблицы в строку
local function tableToString(tbl, indent)
    -- Если таблица не передана, создаем пустую строку
    indent = indent or ""
    local result = "" -- Переменная для накопления строки

    -- Проверяем, что переданный объект является таблицей
    if type(tbl) == "table" then
        for key, value in pairs(tbl) do
            -- Печатаем ключ
            if type(key) == "number" then
                key = string.format("[ %2u ]", key)
            else
                key = "\"" .. key .. "\""
            end

            -- Если значение является таблицей, рекурсивно вызываем функцию
            if type(value) == "table" then
                result = result .. indent .. key .. " = {\n"
                result = result .. tableToString(value, indent .. "\t") -- Увеличиваем отступ для вложенных таблиц
                result = result .. indent .. "}\n"
            else
                result = result .. indent .. key .. " = " .. tostring(value) .. "\n"
            end
        end
    else
        result = result .. tostring(tbl) .. "\n" -- Если это не таблица, выводим само значение
    end

    return result -- Возвращаем итоговую строку
end

function Tree:getExpandedTree()
    local expanded = {}
    local function rec(t, level)
        for i, node in ipairs(t) do
            table.insert(expanded, { id = node.id, last = node.last, level = level, object = node.object })
            rec(node.children, level + 1)
        end
    end
    rec(self.children, 0)
    return expanded
end

--! text function
function Tree:getStringList()
    local expanded = self:getExpandedTree()
    local list = {}
    for i, node in ipairs(expanded) do
        local o = node.object
        table.insert(list, string.rep("\t", node.level) .. node.id .. " " .. o.text)
    end
    return list
end

local function getTINFromId(tree, id)
    local res = nil
    local function rec(t, parent, level)
        if res ~= nil then
            return
        end
        for i, node in ipairs(t) do
            if node.id == id then
                res = { parent = parent, table = t, index = i, value = node }
                return
            end

            rec(node.children, node, level + 1)
        end
    end
    rec(tree.children, tree, 0)
    return res
end

--- func desc
---@param id integer
---@return Node|nil
function Tree:getNodeFromId(id)
    local TIN = getTINFromId(self, id)
    local res = nil;
    if TIN ~= nil then
        res = TIN.value
    end
    return res
end

function Tree:getParentNodeFromId(id)
    local TIN = getTINFromId(self, id)
    local res = nil;
    if TIN ~= nil then
        res = TIN.parent
    end
    return res
end

--- func addChildNode
---@param object table
---@param id nil|integer
---@return nil|integer      @ `nil` indicates `id` will not be found
function Tree:addChildNode(object, id)
    local res = nil
    local ref = nil
    if id == nil then
        ref = self
    else
        ref = self:getNodeFromId(id)
    end
    if ref ~= nil then
        res = self._id_generator
        local node = Node:new(
            self._id_generator,
            {},
            object
        )
        self._id_generator = self._id_generator + 1
        if #ref.children ~= 0 then
            ref.children[#ref.children].last = false
        end
        table.insert(ref.children, node)
    end
    return res
end

function Tree:removeChildNode(id)
    if id == nil then
        return false
    end
    local ref = getTINFromId(self, id)
    if ref == nil then
        return false
    end
    table.remove(ref.table, ref.index)
end

function Tree:serialize()
    return serpent.dump(self)
end

function Tree:deserialize(a)
    local ok, data = serpent.load(a)
    if not ok then
        return false, data or "не удалось прочитать данные"
    end
    if type(data) ~= "table" then
        return false, "неверный формат данных"
    end

    self.children = data.children or {}
    self._id_generator = data._id_generator or 2
    return true
end


-- local treeData = Tree:new()

-- local id = treeData:addChildNode({ type = 1, text = "root1" })
-- treeData:addChildNode({ type = 2, text = "child1_1" }, id)
-- treeData:addChildNode({ type = 2, text = "child1_2" }, id)
-- local id = treeData:addChildNode({ type = 1, text = "root2" })
-- treeData:addChildNode({ type = 2, text = "child2_1" }, id)
-- treeData:addChildNode({ type = 2, text = "child2_2" }, id)
-- treeData:addChildNode({ type = 2, text = "child2_3" }, id)
-- local id = treeData:addChildNode({ type = 1, text = "root3" })
-- treeData:addChildNode({ type = 2, text = "child3_1" }, id)
-- treeData:addChildNode({ type = 2, text = "child3_2" }, id)




-- print(tableToString(treeData))

-- local ExpandedTree = treeData:getExpandedTree()
-- print(tableToString(ExpandedTree))

-- local list = treeData:getStringList()
-- print(tableToString(list))

-- local node = getNodeFromId(treeData, "root2")
-- print(tableToString(node))
-- node.text = "qwe"
-- local node = getNodeFromId(treeData, "child1_2")
-- print(tableToString(node))
-- node.text = "rty"

-- local list = getStringList(treeData)
-- print(tableToString(list))

return Tree
