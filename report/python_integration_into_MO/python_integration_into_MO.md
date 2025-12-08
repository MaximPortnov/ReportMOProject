# Интеграция Python в надстройки МойОфис: практический гид

Хочется питоновских библиотек прямо из надстройки? В МойОфис это делается через модуль `pyxm`, который идет в комплекте. Ниже — выжимка из руководства SDK с примерами, оформленная в духе habr: что это, как подключить, как гонять данные туда‑обратно и что может пойти не так.

## Как это устроено
- `pyxm` — мост между Lua и Python: Lua вызывает Python-функции как обычные Lua-функции, аргументы и результаты автоматически конвертируются.
- Под капотом — Stable ABI (фиксированный бинарный интерфейс). Это значит: можно обновлять Python, не перекомпилируя модуль, пока ABI совместим.
- Платформы: Windows и Linux. Требуется, чтобы системные `python3.dll` (Win) или `libpython3.so` (Linux) были доступны по путям поиска.
- Где живет код: Lua-часть остается в надстройке, Python-файлы складываются в каталог `Python/` (или `python/`) рядом с Lua-кодом.

## Минимальный пример из руководства
Идея: вынести тяжёлую математику или доступ к библиотекам в Python, а из Lua только дергать результат.

**Python-файл** (`Python/PythonModule.py`):
```python
import math

def myFunction(number):
    return math.factorial(number)
```

**Lua-вызов** (любой модуль надстройки):
```lua
local engine = require("pyxm")
local module = engine.import("PythonModule") -- без .py

local function run(context)
    context.doWithDocument(function(document)
        local sheet = document:getBlocks():getTable(0)
        local indexR = sheet:getCell("B5"):getRowIndex()
        local newIndexR = module.myFunction(indexR)
        -- дальше можно писать результат в таблицу
    end)
end
```

Структура надстройки (ключевое — папка `Python/` рядом с Lua-кодом):
```
Extension_Name/
  cmd/CommandsProvider.lua
  Python/PythonModule.py
  META-INF/, LICENSE, Package.lua, …
```

## Пример (боевое демо)
Сценарии: вызвать Python для вычислений, для легкой сериализации данных и для работы с SQLite.

**Python-модуль** — три функции:
```python
import math, sqlite3
from typing import Any, Dict, Sequence

def factorial_summary(a: int, b: int) -> Dict[str, Any]:
    fa, fb = math.factorial(int(a)), math.factorial(int(b))
    return {"a": fa, "b": fb, "sum": fa + fb}

def describe_payload(payload: Dict[str, Any]) -> Dict[str, Any]:
    return {"keys": sorted(payload.keys()),
            "types": {k: type(v).__name__ for k, v in payload.items()}}

def run_sqlite_query(db_path: str, query: str) -> Dict[str, Any]:
    with sqlite3.connect(db_path) as conn:
        conn.row_factory = sqlite3.Row
        cur = conn.execute(query)
        cols: Sequence[str] = [c[0] for c in cur.description]
        rows = [dict(r) for r in cur.fetchall()]
    return {"columns": list(cols), "rows": rows}
```

**Lua-UI** — диалог с кнопками:
- `factorial_summary(4, 6)` — вызывает Python, получает факториалы и сумму, показывает в интерфейсе и пишет в лист.
- `describe_payload` — гоняет Lua-таблицу в Python, возвращает типы значений и список ключей (удобно для отладки форматов).
- `run_sqlite_query` — выполняет SQL через Python, возвращает строки и выводит их в таблицу редактора.

Ключевые куски:
```lua
local engine = require("pyxm")
local module = engine.import("TestPythonModule")

local function runSqliteQueryTest()
    local dbPath = [[C:\path\to\your\sqlite\file.sqlite]]
    local result = module.run_sqlite_query(dbPath, "SELECT id, name, email, city FROM customers;")
    -- writeTableToSheet(result) — запись заголовков и строк в активную таблицу
end
```

## Типы и конвертация (Python → Lua)
Важно: `pyxm` конвертирует только простые типы. Сложные объекты лучше приводить к dict/list перед возвратом.
| Python | Lua |
| --- | --- |
| None | nil |
| Bool | boolean |
| Int/Float | number |
| Str | string |
| List | array |
| Tuple | array (если вложен); на верхнем уровне — множественное возвращение |
| Dict | table |

## Зависимости и проверка среды
- **Linux**: если нет `libpython3.so`, делаем симлинк на установленную версию (включая минор):  
  `sudo ln -s /path/to/libpython3.XX.so /path/to/libpython3.so`
- **Windows**: ищем `python3.dll` в путях:  
  `$env:PATH -split ';' | ForEach-Object { Join-Path $_ 'python3.dll' } | Where-Object { Test-Path $_ }`

## Ограничения и подводные камни
- Python ≥ 3.6 обязателен.
- Embedded-режим: библиотеки, которые жёстко завязаны на C-расширения без поддержки встраивания (например, numpy), могут работать нестабильно.
- Типы: придерживаться таблицы конверсии; сложные объекты сериализовать в dict/list.
- Пути: убедиться, что `python3.dll`/`libpython3.so` действительно доступны из процесса редактора.

## Чек-лист внедрения (5 шагов)
1. Создать `Python/` (или `python/`) в надстройке и положить туда `.py` файлы.
2. Проверить наличие `python3.dll`/`libpython3.so` в системе; при необходимости добавить в пути или сделать симлинк.
3. В Lua подключить `pyxm`, импортировать модуль по имени файла (`engine.import("MyModule")`).
4. Вызывать функции, работая с документом через `context.doWithDocument` и `EditorAPI/DocumentAPI`.
5. Тестировать на целевой версии Python и нужных библиотеках; избегать неподдерживаемых embedded‑пакетов, валидировать конвертацию типов.
