# window_blocker.cpp — зачем и как работает

## Проблема и решение
- Контекст: надстройка для «Мой Офис» на Lua запускает внешнее приложение и обрабатывает его сигналы в цикле сообщений. Без вмешательства главное окно «зависает» (UI не отвечает) во время работы стороннего процесса.
- Требование: блокировать пользовательский ввод в главном окне, пока стороннее приложение выполняет задачи, но не ломать цикл сообщений и не «хардфризить» процесс. Нужно ощущение «приложение занято», но без статуса «Not Responding».
- Решение: создать прозрачное, но хитовое окно‑оверлей поверх активного окна «Мой Офис». Оно:
  - совпадает по размеру/позиции с исходным окном;
  - не перехватывает фокус (WS_EX_NOACTIVATE);
  - top-most, layered, toolwindow, поэтому не видно в таскбаре и остаётся поверх родителя;
  - принимает клики/клавиши, фактически блокируя взаимодействие с UI.
  Управление — через Lua-модуль с тонкой прослойкой на WinAPI.

## Поток выполнения от Lua до WinAPI
1) Lua вызывает экспорт из модуля `window_blocker`.
2) C++-прослойка берёт HWND активного окна (или сохранённый ранее), регистрирует класс окна блокера и создаёт layered top-most окно, совпадающее по координатам с родительским.
3) Окно получает стиль `WS_EX_NOACTIVATE`, поэтому не крадёт фокус, но благодаря `SetLayeredWindowAttributes(..., alpha=1)` остаётся невидимым и хитовым.

### Ключевые шаги в коде
**Поиск окна и запоминание HWND**
```cpp
static int l_find_window(lua_State* L) {
  HWND hwnd = GetActiveWindow();
  if (!hwnd) { lua_pushnil(L); lua_pushstring(L, "window not found"); return 2; }
  g_main_hwnd = hwnd;
  lua_pushinteger(L, (lua_Integer)reinterpret_cast<uintptr_t>(hwnd));
  lua_pushinteger(L, (lua_Integer)GetCurrentProcessId());
  return 2;
}
```

**Создание блокера**
```cpp
HWND create_blocker(HWND parent, std::string* err_out) {
  GetWindowRect(parent, &rc); // копируем позицию и размер
  ensure_blocker_class(inst); // регистрируем LuaExtBlockerWnd
  HWND blocker = CreateWindowExA(
    WS_EX_LAYERED | WS_EX_TOOLWINDOW | WS_EX_NOACTIVATE | WS_EX_TOPMOST,
    kBlockerClass, "", WS_POPUP, rc.left, rc.top, width, height,
    parent, nullptr, inst, nullptr);
  SetLayeredWindowAttributes(blocker, 0, 1, LWA_ALPHA); // невидимый, но ловит клики
  ShowWindow(blocker, SW_SHOW);
  return blocker;
}
```

**Авторазблокировка по таймеру (опционально)**
```cpp
static int l_lock_unlock(lua_State* L) {
  DestroyWindow(g_blocker_hwnd); // если уже был блокер
  HWND blocker = create_blocker(resolve_target_hwnd(), &err);
  SetTimer(blocker, kBlockerTimerId, 10'000, nullptr); // автоудаление через 10 с
  lua_pushboolean(L, 1);
  return 1;
}
```

## Lua API и сценарий использования
- `find_window()`: зафиксировать HWND «Мой Офис» перед дальнейшими вызовами.
- `lock_window()`: поставить блокер, если его ещё нет (возврат `true`).
- `unlock_window()`: снять блокер, если активен; иначе вернуть ошибку.
- `lock_unlock()`: пересоздать блокер и автоматически снять его через 10 секунд таймером.

Типичный сценарий: `find_window()` → запуск внешнего приложения → `lock_window()` на время обмена → по завершении `unlock_window()` или `lock_unlock()` для автосброса.

### Мини-пример Lua-скрипта
```lua
local wb = require("window_blocker")

local hwnd, pid = wb.find_window()
assert(hwnd, "не нашли окно: "..tostring(pid))

-- перед длительной операцией
assert(wb.lock_window())

-- здесь запускается внешнее приложение и идёт обмен
-- ... ваша логика ...

-- когда можно снова пускать пользователя
local ok, err = wb.unlock_window()
if not ok then print("unlock error", err) end
```

## Ограничения и заметки
- Не отслеживает перемещение/resize исходного окна после создания блокера.
- Предполагается вызов из одного потока (нет синхронизации).
- Блокируется только ввод; цикл сообщений продолжает работу, поэтому UI не «Not Responding».  
- Внешнее приложение всё ещё может показывать свои окна; блокируется только родительское окно «Мой Офис».
- Таймер в `lock_unlock` жёстко 10 секунд; при других сценариях используйте явный `unlock_window()`.
