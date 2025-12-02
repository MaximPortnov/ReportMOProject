demo = {}

--======================================================================
-- label
--======================================================================
demo.label = ui:Label {
    Name = "demo_lbl",
    Enabled = true,
    Size = Forms.Size(-1, -1),
    Text = "Hello, world!",
    Alignment = Forms.Alignment_TopLeft
}
local alignment = demo.label:getAlignment()
local color = demo.label:getColor()
local name = demo.label:getName()
local size = demo.label:getSize()
local text = demo.label:getText()
local isEnabled = demo.label:isEnabled()
demo.label:setAlignment(Forms.Alignment_MiddleCenter)
demo.label:setColor(Forms.Color(255, 0, 0))
demo.label:setEnabled(true)
demo.label:setName("demo_lbl")
demo.label:setSize(Forms.Size(-1, -1))
demo.label:setText("New text.")
--======================================================================
-- label
--======================================================================


--======================================================================
-- Button
--======================================================================
demo.button = ui:Button {
    Name = "demo_btn",
    Enabled = true,
    Size = Forms.Size(-1, -1),
    Title = "Начать обработку",
    OnClick = function()
    end
}
local name = demo.button:getName()
local isEnabled = demo.button:isEnabled()
local size = demo.button:getSize()
local title = demo.button:getTitle()
demo.button:setName("demo_btn")
demo.button:setEnabled(true)
demo.button:setSize(Forms.Size(-1, -1))
demo.button:setTitle("Начать обработку")
demo.button:setOnClick(
    function()
        local name = demo.button:getName()
        local isEnabled = demo.button:isEnabled()
        local size = demo.button:getSize()
        local title = demo.button:getTitle()
        EditorAPI.messageBox(
            "demo.button\n"
            .. "fun: OnClick\n"
            .. "name: " .. name .. "\n"
            .. "isEnabled: " .. (isEnabled and "true" or "false") .. "\n"
            .. "size: " .. size.width .. " " .. size.height .. "\n"
            .. "title: " .. title .. "\n"
        )
    end
)
--======================================================================
-- Button
--======================================================================


--======================================================================
-- CheckBox
--======================================================================
demo.checkBox = ui:CheckBox {
    Name = "demo_cb",
    Enabled = true,
    Size = Forms.Size(-1, -1),
    Title = "CheckBox1",
    State = Forms.CheckState_Unchecked,
    OnStateChanged = function(state)
    end
}
local name = demo.checkBox:getName()
local size = demo.checkBox:getSize()
local checkState = demo.checkBox:getState()
local isChecked = demo.checkBox:isChecked()
local isEnabled = demo.checkBox:isEnabled()
local title = demo.checkBox:getTitle()
demo.checkBox:setEnabled(true)
demo.checkBox:setName("demo_cb")
demo.checkBox:setSize(Forms.Size(-1, -1))
demo.checkBox:setState(Forms.CheckState_Unchecked)
demo.checkBox:setOnStateChanged(
    function(state)
        local name = demo.checkBox:getName()
        local size = demo.checkBox:getSize()
        local checkState = demo.checkBox:getState()
        local isChecked = demo.checkBox:isChecked()
        local isEnabled = demo.checkBox:isEnabled()
        local title = demo.checkBox:getTitle()
        EditorAPI.messageBox(
            "demo.checkBox\n"
            .. "fun: OnStateChanged\n"
            .. "name: " .. name .. "\n"
            .. "isEnabled: " .. (isEnabled and "true" or "false") .. "\n"
            .. "size: " .. size.width .. " " .. size.height .. "\n"
            .. "title: " .. title .. "\n"
            .. "checkState: "
            .. (checkState == Forms.CheckState_Checked and "CheckState_Checked" or "CheckState_Unchecked")
            .. "\n"
            .. "isChecked: " .. (isChecked and "true" or "false") .. "\n"

        )
    end
)
demo.checkBox2 = ui:CheckBox {
    Name = "demo_cb2",
    Title = "CheckBox2",
    OnStateChanged = function(state)
        EditorAPI.messageBox(
            "name: "
            .. demo.checkBox2:getName()
            .. "\nstate: "
            .. (state == Forms.CheckState_Checked and "CheckState_Checked" or "CheckState_Unchecked")
        )
    end
}
demo.checkBox3 = ui:CheckBox {
    Name = "demo_cb3",
    Title = "CheckBox3",
    OnStateChanged = function(state)
        EditorAPI.messageBox(
            "name: "
            .. demo.checkBox3:getName()
            .. "\nstate: "
            .. (state == Forms.CheckState_Checked and "CheckState_Checked" or "CheckState_Unchecked")
        )
    end
}

--======================================================================
-- CheckBox
--======================================================================

--======================================================================
-- RadioButton
--======================================================================
demo.radioButton = ui:RadioButton {
    Name = "demo_rb",
    Enabled = true,
    Size = Forms.Size(-1, -1),
    Title = "RadioButton",
    State = Forms.CheckState_Checked,
    OnStateChanged = function(state)
    end
}
local name = demo.radioButton:getName()
local size = demo.radioButton:getSize()
local checkState = demo.radioButton:getState()
local isEnabled = demo.radioButton:isEnabled()
local title = demo.radioButton:getTitle()
demo.radioButton:setEnabled(true)
demo.radioButton:setName("demo_rb")
demo.radioButton:setSize(Forms.Size(-1, -1))
demo.radioButton:setState(Forms.CheckState_Checked)
demo.radioButton:setOnStateChanged(
    function(state)
        local name = demo.radioButton:getName()
        local size = demo.radioButton:getSize()
        local checkState = demo.radioButton:getState()
        local isEnabled = demo.radioButton:isEnabled()
        local title = demo.radioButton:getTitle()

        EditorAPI.messageBox(
            "demo.radioButton\n"
            .. "fun: OnStateChanged\n"
            .. "name: " .. name .. "\n"
            .. "isEnabled: " .. (isEnabled and "true" or "false") .. "\n"
            .. "size: " .. size.width .. " " .. size.height .. "\n"
            .. "title: " .. title .. "\n"
            .. "checkState: "
            .. (checkState == Forms.CheckState_Checked and "CheckState_Checked" or "CheckState_Unchecked")
            .. "\n"
        )
    end
)

demo.radioButton2 = ui:RadioButton {
    Name = "demo_rb2",
    Title = "RadioButton2",
    OnStateChanged = function(state)
        EditorAPI.messageBox(
            "name: "
            .. demo.radioButton2:getName()
            .. "\nstate: "
            .. (state == Forms.CheckState_Checked and "CheckState_Checked" or "CheckState_Unchecked")
        )
    end
}
demo.radioButton3 = ui:RadioButton {
    Name = "demo_rb3",
    Title = "RadioButton3",
    OnStateChanged = function(state)
        EditorAPI.messageBox(
            "name: "
            .. demo.radioButton2:getName()
            .. "\nstate: "
            .. (state == Forms.CheckState_Checked and "CheckState_Checked" or "CheckState_Unchecked")
        )
    end
}
--======================================================================
-- RadioButton
--======================================================================

--======================================================================
-- GroupBox
--======================================================================
demo.labelForGroupBox = ui:Label {
    Name  = "lblForGroupBox",
    Color = Forms.Color(0, 255, 0),
    Text  = "testGroupBox"
}

demo.groupBox = ui:GroupBox {

    Name    = "demo_gb",
    Enabled = true,
    Size    = Forms.Size(-1, -1),
    ui:Column {
        demo.labelForGroupBox,
        ui:Row {
            ui:Spacer {},
            demo.labelForGroupBox
        }
    }
}
local name = demo.groupBox:getName()
local size = demo.groupBox:getSize()
local isEnabled = demo.groupBox:isEnabled()
demo.groupBox:setEnabled(true)
demo.groupBox:setName("demo_gb")
demo.groupBox:setSize(Forms.Size(-1, -1))
--======================================================================
-- GroupBox
--======================================================================

local function getItemFromId(items, id)
    for i = 0, items:getCount() - 1 do
        local it = items:getItem(i)
        local t1 = it.id
        local t2 = it.text
        if it.id == id then
            return it
        end
    end
    return nil
end

--======================================================================
-- ListBox
--======================================================================
demo.listItemsForListBox = ui:ListItems {
    {
        text = "item 1",
        id = 3,
        checkState = Forms.CheckState_Unchecked
    },
    ui:Button {
        Name = "123",
        Title = "test btn"
    },
    {
        text = "item 2",
        id = 4,
        checkState = Forms.CheckState_Unchecked
    },
    {
        text = "item 3",
        id = 5,
        checkState = Forms.CheckState_Unchecked

    }
}

demo.listBox = ui:ListBox {
    Name                 = "demo_lb",
    Enabled              = true,
    Size                 = Forms.Size(-1, -1),
    Items                = demo.listItemsForListBox,
    CurrentItem          = 3,
    OnCurrentItemChanged = function(id) end,
    OnItemStateChanged   = function(id, state) end
}
local currentItem = demo.listBox:getCurrentItem()
local items = demo.listBox:getItems()
local name = demo.listBox:getName()
local size = demo.listBox:getSize()
local isEnabled = demo.listBox:isEnabled()
demo.listBox:setItems(demo.listItemsForListBox)
demo.listBox:addItem("item 4", 6, Forms.CheckState_Unchecked)
demo.listBox:addItem("item 5", 7, Forms.CheckState_Unchecked)
demo.listBox:addItem("item 6", 8)
demo.listBox:removeItem(7)
demo.listBox:removeRow(3)
demo.listBox:setCurrentItem(1)
demo.listBox:setEnabled(true)
demo.listBox:setItemCheckState(1, Forms.CheckState_Unchecked)
demo.listBox:setName("demo_lb")
demo.listBox:setOnCurrentItemChanged(
    function(itemId)
        local name = demo.listBox:getName()
        local size = demo.listBox:getSize()
        local isEnabled = demo.listBox:isEnabled()
        local currentItem = demo.listBox:getCurrentItem()
        local items = demo.listBox:getItems()
        local item = getItemFromId(items, itemId)
        EditorAPI.messageBox(
            "demo.listBox\n"
            .. "fun: OnCurrentItemChanged\n"
            .. "name: " .. name .. "\n"
            .. "isEnabled: " .. (isEnabled and "true" or "false") .. "\n"
            .. "size: " .. size.width .. " " .. size.height .. "\n"
            .. "itemId: " .. itemId .. "\n"
            .. "currentItem: " .. currentItem .. "\n"
            .. "item.text: " .. item.text .. "\n"
        )
    end
)
demo.listBox:setOnItemStateChanged(
    function(itemId, itemState)
        local name = demo.listBox:getName()
        local size = demo.listBox:getSize()
        local isEnabled = demo.listBox:isEnabled()
        local currentItem = demo.listBox:getCurrentItem()
        local items = demo.listBox:getItems()
        local item = getItemFromId(items, itemId)
        EditorAPI.messageBox(
            "demo.listBox\n"
            .. "fun: OnItemStateChanged\n"
            .. "name: " .. name .. "\n"
            .. "isEnabled: " .. (isEnabled and "true" or "false") .. "\n"
            .. "size: " .. size.width .. " " .. size.height .. "\n"
            .. "itemId: " .. itemId .. "\n"
            .. "currentItem: " .. currentItem .. "\n"
            .. "itemState: " ..
            (itemState == Forms.CheckState_Checked and "CheckState_Checked" or "CheckState_Unchecked") .. "\n"
            .. "item.text: " .. item.text .. "\n"
        )
    end
)
--======================================================================
-- ListBox
--======================================================================


--======================================================================
-- ComboBox
--======================================================================
demo.listItemsForComboBox = ui:ListItems {
    {
        text = "Яблоко",
        id = 123,
        checkState = Forms.CheckState_Unchecked
    },
    {
        text = "Груша",
        id = 321,
        checkState = Forms.CheckState_Unchecked
    },
    {
        text = "Слива",
        id = 2332,
        checkState = Forms.CheckState_Unchecked

    }
}



demo.comboBox = ui:ComboBox {
    Name = "demo_com",
    Enabled = true,
    Size = Forms.Size(-1, -1),
    Items = demo.listItemsForComboBox,
    CurrentItem = 321,
    OnCurrentItemChanged = function(id) end
}
local currentItem = demo.comboBox:getCurrentItem()
local listItems = demo.comboBox:getItems()
local name = demo.comboBox:getName()
local size = demo.comboBox:getSize()
local isEnabled = demo.comboBox:isEnabled()
demo.comboBox:setItems(demo.listItemsForComboBox)
demo.comboBox:addItem("Персик", 4432, Forms.CheckState_Checked)
demo.comboBox:setCurrentItem(321)
demo.comboBox:removeItem(123)
demo.comboBox:removeRow(1)
demo.comboBox:setEnabled(true)
demo.comboBox:setName("demo_com")
demo.comboBox:setSize(Forms.Size(-1, -1))
demo.comboBox:setOnCurrentItemChanged(
    function(itemId)
        local name = demo.comboBox:getName()
        local size = demo.comboBox:getSize()
        local isEnabled = demo.comboBox:isEnabled()
        local currentItem = demo.comboBox:getCurrentItem()
        local items = demo.comboBox:getItems()
        local item = getItemFromId(items, itemId)
        EditorAPI.messageBox(
            "demo.comboBox\n"
            .. "fun: OnCurrentItemChanged\n"
            .. "name: " .. name .. "\n"
            .. "isEnabled: " .. (isEnabled and "true" or "false") .. "\n"
            .. "size: " .. size.width .. " " .. size.height .. "\n"
            .. "itemId: " .. itemId .. "\n"
            .. "currentItem: " .. currentItem .. "\n"
            .. "item.text: " .. item.text .. "\n"
        )
    end
)
--======================================================================
-- ComboBox
--======================================================================


--======================================================================
-- TextBox
--======================================================================
demo.textBox = ui:TextBox {
    Name = "demo_tb",
    Enabled = true,
    Size = Forms.Size(-1, -1),
    Text = "Type text here",
    OnTextChanged = function(text) end,
    OnEditingFinished = function() end
}
local name = demo.textBox:getName()
local size = demo.textBox:getSize()
local text = demo.textBox:getText()
local isEnabled = demo.textBox:isEnabled()
demo.textBox:setEnabled(true)
demo.textBox:setName("demo_tb")
demo.textBox:setSize(Forms.Size(-1, -1))
demo.textBox:setText("Type text here")
demo.textBox:setOnTextChanged(
    function(text)
        local name = demo.textBox:getName()
        local size = demo.textBox:getSize()
        local text1 = demo.textBox:getText()
        local isEnabled = demo.textBox:isEnabled()
        EditorAPI.messageBox(
            "demo.textBox\n"
            .. "fun: OnTextChanged\n"
            .. "name: " .. name .. "\n"
            .. "isEnabled: " .. (isEnabled and "true" or "false") .. "\n"
            .. "size: " .. size.width .. " " .. size.height .. "\n"
            .. "text1: " .. text1 .. "\n"
            .. "text: " .. text .. "\n"
        )
    end
)
demo.textBox:setOnEditingFinished(
    function()
        local name = demo.textBox:getName()
        local size = demo.textBox:getSize()
        local text = demo.textBox:getText()
        local isEnabled = demo.textBox:isEnabled()
        EditorAPI.messageBox(
            "demo.textBox\n"
            .. "fun: OnEditingFinished\n"
            .. "name: " .. name .. "\n"
            .. "isEnabled: " .. (isEnabled and "true" or "false") .. "\n"
            .. "size: " .. size.width .. " " .. size.height .. "\n"
            .. "text: " .. text .. "\n"
        )
    end
)

--======================================================================
-- TextBox
--======================================================================

local btnStart = ui:Button {
    Name = "btnStart",
    Title = "Начать обработку",
    OnClick = function()
        EditorAPI.messageBox("кнопка внизу")
    end
}

demo.uiDialogButtons = ui:DialogButtons {
    Forms.DialogButton_OK,
    btnStart,
}

demo.uiDialogButtons:addButton("Закрыть", Forms.DialogButtonRole_Reject)

local onDone = function(ret)
    if ret == Forms.DialogCode_Accepted then
        EditorAPI.messageBox("Forms.DialogCode_Accepted")
    elseif ret == Forms.DialogCode_Rejected then
        EditorAPI.messageBox("Forms.DialogCode_Rejected")
    end
end

demo.dlgBegin = ui:Dialog {
    Title = "Demo",
    Enabled = true,
    Size = Forms.Size(-1, -1),
    Buttons = demo.uiDialogButtons,
    OnDone = onDone,
    ui:Column {
        ui:Row {
            ui:Column {
                ui:Spacer {},
                ui:Column { demo.label },
                ui:Column { demo.button },
                ui:Column { demo.checkBox },
                ui:Column { demo.checkBox2 },
                ui:Column { demo.checkBox3 },
                ui:Column { demo.radioButton },
                ui:Column { demo.radioButton2 },
                ui:Column { demo.radioButton3 },
                ui:Column { demo.groupBox },
                ui:Column { demo.listBox },
                ui:Column { demo.comboBox },
                ui:Column { demo.textBox },
                ui:Spacer {}

            }
        }
    }
}

return demo
