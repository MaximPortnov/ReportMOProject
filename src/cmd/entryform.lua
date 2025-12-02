mobdebug = require("mobdebug")
mobdebug.logging(true)
mobdebug.start('127.0.0.1', 8172)
mobdebug.output("stdout", "r")


local Actions = {}
function Actions.getCommands()
    return {
        {
            id = "DlgForm.CallApp",
            menuItem = "вызвать приложение",
            command = Actions.CallApp
        },
        {
            id = "DlgForm.ShowDm",
            menuItem = "Показать демо",
            command = Actions.ShowDemo
        },
        {
            id = "DlgForm.showMyTree",
            menuItem = "показать мое дерево",
            command = Actions.ShowMyTree
        },
        {
            id = "DlgForm.showDBTree",
            menuItem = "показать DB дерево",
            command = Actions.ShowDBTree
        },
        {
            id = "DlgForm.showWebView",
            menuItem = "показать webview",
            command = Actions.showWebView
        },
    }
end

function Actions.CallApp(context)
    local utils = require("cmd.externalGUI.utils")
    utils.runApp(context)
end

function Actions.ShowDemo(context)
    demo = require("cmd.demo.demo")
    if demo ~= nil then
        context.showDialog(demo.dlgBegin)
    else
        EditorAPI.messageBox("No Exists module 'demo'!")
    end
end

function Actions.ShowMyTree(context)
    frm = require("cmd.myTree.myTree")
    if frm ~= nil then
        frm:start(context)
    else
        EditorAPI.messageBox("No Exists module 'forms'!")
    end
end

function Actions.ShowDBTree(context)
    require("cmd.ConnectionManager.CMController"):start(context)
end

function Actions.showWebView(context)
    require("cmd.testWebView.testWebView"):start(context)
end

return Actions
