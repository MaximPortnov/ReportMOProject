local TWV = {}

local webviewLib = require('webview')

local function urlDecode(str)
    return (str:gsub('%%(%x%x)', function(hex)
        return string.char(tonumber(hex, 16))
    end))
end

---TWV:start
---@param context Context
function TWV:start(context)
    local content = [[<!DOCTYPE html>
<html>
  <body>
    <p id="sentence">Enter text and cell (e.g. A1) then click Send</p>
    <div style="margin-bottom:8px;">
      <input id="cellName" type="text" placeholder="Cell (e.g. A1)" value="A1" style="width:120px;"/>
      <input id="cellText" type="text" placeholder="Text for cell" style="width:240px;"/>
      <button onclick="sendText()">Send</button>
    </div>
  </body>
  <script type="text/javascript">
  function showText(value) {
    document.getElementById("sentence").innerHTML = value;
  }
  function sendText() {
    var cell = (document.getElementById("cellName").value || "A1").trim();
    var value = document.getElementById("cellText").value || "";
    window.external.invoke("settext?cell=" + encodeURIComponent(cell) + "&text=" + encodeURIComponent(value));
    showText("Last sent to " + cell + ": " + value);
  }
  </script>
</html>
]]

    content = string.gsub(content, "[ %c!#$%%&'()*+,/:;=?@%[%]]", function(c)
        return string.format('%%%02X', string.byte(c))
    end)

    local webview = webviewLib.new('data:text/html,' .. content, 'Example', 480, 240, true, true)

    webviewLib.callback(webview, function(value)
        if value == 'print_date' then
            print(os.date())
        elseif value == 'show_date' then
            webviewLib.eval(webview, 'showText("Lua date is ' .. os.date() .. '")', true)
        elseif value == 'fullscreen' then
            webviewLib.fullscreen(webview, true)
        elseif value == 'exit_fullscreen' then
            webviewLib.fullscreen(webview, false)
        elseif value == 'terminate' then
            webviewLib.terminate(webview, true)
        elseif string.find(value, '^title=') then
            webviewLib.title(webview, string.sub(value, 7))
        elseif string.find(value, '^settext%?') then
            local cellEncoded, textEncoded = string.match(value, '^settext%?cell=([^&]*)&text=(.*)$')
            local targetCell = cellEncoded and urlDecode(cellEncoded) or 'A1'
            local text = textEncoded and urlDecode(textEncoded) or ''
            
            context.doWithDocument(function(document)
                local tbl = document:getBlocks():getTable(0)
                local cell = tbl:getCell(targetCell)
                cell:setText(text)
            end)
        else
            print('callback received', value)
        end
    end)

    webviewLib.loop(webview)
    
end

return TWV
