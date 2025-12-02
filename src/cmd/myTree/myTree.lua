local myTree = {}
local FILE_DIALOG_FILTER = "Lua (*.lua);;Text (*.txt);;All Files (*.*)"

local function getDefaultDirectory()
    local ok, dir = pcall(getWorkingDirectory)
    if ok and type(dir) == "string" then
        return dir
    end
    return ""
end

local function writeTextFile(path, content)
    local file, err = io.open(path, "w")
    if not file then
        return false, err
    end
    file:write(content)
    file:close()
    return true
end

local function readTextFile(path)
    local file, err = io.open(path, "r")
    if not file then
        return nil, err
    end
    local data = file:read("*a")
    file:close()
    return data
end

local function getFirstPathFromVector(vector)
    if vector == nil then
        return nil
    end
    if type(vector) == "string" and #vector > 0 then
        return vector
    end
    if type(vector.size) ~= "function" then
        return nil
    end
    if vector:size() == 0 then
        return nil
    end
    return vector[0]
end

local function ensureContext()
    if myTree.context == nil or myTree.context.showDialog == nil then
        EditorAPI.messageBox("Контекст интерфейса недоступен")
        return false
    end
    return true
end

myTree.currentItemId = 0
myTree.lb_tree = ui:ListBox {

}

myTree.lb_tree:setOnCurrentItemChanged(
    function(id)
        -- local node = myTree.treeData:getNodeFromId(id)
        -- if node.object.collapsed ~= nil then
        --     node.object.collapsed = not node.object.collapsed
        --     myTree:updateTreeList()
        -- end
        myTree.currentItemId = id
    end
)

myTree.lb_tree:setOnItemStateChanged(
    function(id, state)
        local node = myTree.treeData:getNodeFromId(id)
        if node.object.collapsed ~= nil then
            node.object.collapsed = not node.object.collapsed
            myTree.currentItemId = id
            myTree:updateTreeList()
        end
    end
)



function myTree:updateTreeList()
    local list = self.treeData:getExpandedTree()
    local collapsed_list = {}
    local skip = nil
    for i, node in ipairs(list) do
        if skip == nil or node.level <= skip then
            skip = nil
            if node.object["collapsed"] ~= nil and node.object["collapsed"] == true then
                skip = node.level
            end
            table.insert(collapsed_list, node)
        end
    end
    local newItems = ui:ListItems {}

    for i, node in ipairs(collapsed_list) do
        local col = nil
        -- local pre =  node.last and "└─" or "├─"
        local text = string.rep("     ", node.level) .. node.object.text
        if node.object.collapsed ~= nil then
            col = node.object.collapsed and Forms.CheckState_Unchecked or Forms.CheckState_Checked
            newItems:addItem(text, node.id, col)
        else
            text = "     " .. text
            newItems:addItem(text, node.id)
        end
    end
    self.lb_tree:setItems(newItems)
    self.lb_tree:setCurrentItem(myTree.currentItemId)
end

myTree.btn_collapseAll = ui:Button {
    Name = "btn1",
    Title = "развернуть все",
    OnClick = function()
        local list = myTree.treeData:getExpandedTree()
        for i, node in ipairs(list) do
            if node.object.collapsed ~= nil then
                node.object.collapsed = false
            end
        end
        myTree:updateTreeList()
    end

}
myTree.btn_expandAll = ui:Button {
    Name = "btn2",
    Title = "свернуть все",
    OnClick = function()
        local list = myTree.treeData:getExpandedTree()
        for i, node in ipairs(list) do
            if node.object.collapsed ~= nil then
                node.object.collapsed = true
            end
        end
        myTree:updateTreeList()
    end

}

myTree.btn_clearCurrentItem = ui:Button {
    Name = "btn_clearCurrentItem",
    Title = "очистить выделение",
    OnClick = function()
        -- myTree.currentItemId = nil
        -- myTree.lb_tree:setCurrentItem(-1)
    end
}

myTree.btn_createChild = ui:Button {
    Name = "btn_createChild",
    Title = "создать ребенка",
    OnClick = function()
        local id = myTree.lb_tree:getCurrentItem()
        if id <= 0 then
            return
        end
        local node = myTree.treeData:getNodeFromId(id)
        if node.object.collapsed == nil then
            node.object.collapsed = false
        end
        myTree.treeData:addChildNode({ type = 2, text = "child" .. "_" .. id .. "_" .. #node.children }, id)
        myTree:updateTreeList()
    end
}

myTree.btn_createRoot = ui:Button {
    Name = "btn_createRoot",
    Title = "создать родителя",
    OnClick = function()
        local id = myTree.treeData:addChildNode({ type = 1, text = "root" .. "_" .. #myTree.treeData.children })
        if id ~= nil then
            myTree.currentItemId = id
        end
        myTree:updateTreeList()
    end
}
myTree.btn_removeNode = ui:Button {
    Name = "btn_removeNode",
    Title = "удалить элемент",
    OnClick = function()
        local id = myTree.lb_tree:getCurrentItem()
        if id <= 0 then
            return
        end
        local parent = myTree.treeData:getParentNodeFromId(id)
        myTree.treeData:removeChildNode(id)
        if parent.id ~= nil then -- ! error
            myTree.currentItemId = parent.id
        elseif parent.children[1] ~= nil then
            myTree.currentItemId = parent.children[1].id     
        else
            myTree.currentItemId = 0
        end
        myTree:updateTreeList()
        -- myTree.lb_tree:setCurrentItem(myTree.currentItemId)
    end
}

myTree.btn_showCurrentItemId = ui:Button {
    Name = "btn_showCurrentItemId",
    Title = "показать id",
    OnClick = function()
        EditorAPI.messageBox("" .. myTree.lb_tree:getCurrentItem())
    end
}

myTree.btn_serialize = ui:Button {
    Name = "btn_serialize",
    Title = "сохранить дерево",
    OnClick = function()
        if not ensureContext() then
            return
        end
        local dialog = ui:FileSaveDialog {
            Title = "Сохранить дерево",
            InitialDirectory = getDefaultDirectory(),
            Filter = FILE_DIALOG_FILTER,
            OnDone = function(path)
                if not path or #path == 0 then
                    return
                end
                local serialized = myTree.treeData:serialize()
                local ok, err = writeTextFile(path, serialized)
                if not ok then
                    EditorAPI.messageBox("Не удалось сохранить файл:\n" .. tostring(err))
                    return
                end
                EditorAPI.messageBox("Дерево сохранено:\n" .. path)
            end
        }
        myTree.context.showDialog(dialog)
    end
}
myTree.btn_deserialize = ui:Button {
    Name = "btn_deserialize",
    Title = "загрузить дерево",
    OnClick = function()
        if not ensureContext() then
            return
        end
        local dialog = ui:FileOpenDialog {
            Title = "Загрузить дерево",
            InitialDirectory = getDefaultDirectory(),
            Filter = FILE_DIALOG_FILTER,
            AllowMultiSelect = false,
            OnDone = function(paths)
                local path = getFirstPathFromVector(paths)
                if not path then
                    return
                end
                local data, readErr = readTextFile(path)
                if not data then
                    EditorAPI.messageBox("Не удалось прочитать файл:\n" .. tostring(readErr))
                    return
                end
                local ok, deserializeErr = myTree.treeData:deserialize(data)
                if not ok then
                    EditorAPI.messageBox("Не удалось загрузить дерево:\n" .. tostring(deserializeErr))
                    return
                end
                myTree.currentItemId = 0
                myTree:updateTreeList()
                EditorAPI.messageBox("Дерево загружено:\n" .. path)
            end
        }
        myTree.context.showDialog(dialog)
    end
}



myTree.dlg = ui:Dialog {
    Title = "myTree",
    Size = Forms.Size(-1, -1),
    ui:Column {
        ui:Row {
            ui:Column {
                myTree.lb_tree,
            },
            ui:Column {
                myTree.btn_collapseAll,
                myTree.btn_expandAll,
                myTree.btn_clearCurrentItem,
                myTree.btn_createChild,
                myTree.btn_createRoot,
                myTree.btn_removeNode,
                myTree.btn_showCurrentItemId,
                myTree.btn_serialize,
                myTree.btn_deserialize,
            }
        }

    }
}

---@param context Context
function myTree:start(context)
    self.context = context
    local Tree = require("cmd.utils.treeModule")
    self.treeData = Tree:new()
    -- local id = self.treeData:addChildNode({ type = 1, text = "root1", collapsed = true })
    -- self.treeData:addChildNode({ type = 2, text = "child1_1" }, id)
    -- self.treeData:addChildNode({ type = 2, text = "child1_2" }, id)
    -- local id = self.treeData:addChildNode({ type = 1, text = "root2", collapsed = true })
    -- self.treeData:addChildNode({ type = 2, text = "child2_1" }, id)
    -- self.treeData:addChildNode({ type = 2, text = "child2_2" }, id)
    -- self.treeData:addChildNode({ type = 2, text = "child2_3" }, id)
    -- local id = self.treeData:addChildNode({ type = 1, text = "root3", collapsed = true })
    -- self.treeData:addChildNode({ type = 2, text = "child3_1" }, id)
    -- self.treeData:addChildNode({ type = 2, text = "child3_2" }, id)
    myTree:updateTreeList()


    context.showDialog(myTree.dlg)
end

return myTree
