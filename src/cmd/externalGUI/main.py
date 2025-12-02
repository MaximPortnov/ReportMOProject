# main.py
import argparse
import atexit
import json
import os
import sys
import time
import tkinter as tk
from tkinter import messagebox, filedialog

# ========== IPC helpers ==========

class IPCClient:
    """
    Простой клиент, который:
    - дописывает JSON-строку (одна команда = одна строка) в command.log
    - ждёт ответ с таким же id в response.log
    """
    def __init__(self, work_dir: str):
        self.work_dir = work_dir
        self.ipc_dir = os.path.join(work_dir, "ipc")
        os.makedirs(self.ipc_dir, exist_ok=True)
        self.cmd_path = os.path.join(self.ipc_dir, "command.log")
        self.rsp_path = os.path.join(self.ipc_dir, "response.log")
        # гарантируем наличие файлов
        for p in (self.cmd_path, self.rsp_path):
            if not os.path.exists(p):
                open(p, "a", encoding="utf-8").close()
        self._next_id = int(time.time() * 1000)  # стартуем с «почти уникального» id

    def _append_jsonl(self, path: str, obj: dict):
        data = json.dumps(obj, ensure_ascii=False)
        with open(path, "a", encoding="utf-8") as f:
            f.write(data + "\n")
            f.flush()
            os.fsync(f.fileno())

    def _wait_response(self, req_id: int, timeout_sec: float = 10.0):
        """
        Ждём строку с нужным id в response.log.
        Читаем «с хвоста»: сначала запоминаем текущий размер файла.
        """
        start = time.time()
        # позиция хвоста на момент отправки
        try:
            with open(self.rsp_path, "r", encoding="utf-8") as f:
                f.seek(0, os.SEEK_END)
                tail_pos = f.tell()
        except FileNotFoundError:
            tail_pos = 0

        while True:
            # таймаут
            if time.time() - start > timeout_sec:
                raise TimeoutError("Не дождались ответа надстройки")

            with open(self.rsp_path, "r", encoding="utf-8") as f:
                f.seek(tail_pos, os.SEEK_SET)
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        obj = json.loads(line)
                    except Exception:
                        continue
                    if obj.get("id") == req_id:
                        return obj
                # обновим позицию хвоста
                tail_pos = f.tell()

            time.sleep(0.05)

    def send(self, cmd: str, args: dict | None = None, timeout_sec: float = 10.0):
        """
        Отправить команду и дождаться ответа.
        Возвращает dict ответа {id, ok, result|error}.
        """
        req_id = self._next_id
        self._next_id += 1

        packet = {"id": req_id, "cmd": cmd, "args": args or {}}
        self._append_jsonl(self.cmd_path, packet)
        return self._wait_response(req_id, timeout_sec=timeout_sec)

    def exit(self):
        """Мягко попросить надстройку завершить блокирующий цикл."""
        try:
            self.send("EXIT", {}, timeout_sec=3.0)
        except Exception:
            # даже если не успели — мы хотя бы попытались
            pass


# ========== GUI App ==========

class App(tk.Tk):
    def __init__(self, ipc: IPCClient):
        super().__init__()
        self.ipc = ipc
        self.title("Простое приложение с кнопками")
        self.geometry("360x240")

        # UI
        self._build_menu()
        self._build_body()

        # закрытие окна — обязательно EXIT
        self.protocol("WM_DELETE_WINDOW", self.on_close)

        # горячие клавиши
        self.bind_all("<Control-q>", lambda e: self.on_close())

    def _build_menu(self):
        menubar = tk.Menu(self)
        file_menu = tk.Menu(menubar, tearoff=0)
        file_menu.add_command(label="Сохранить как…", command=self.menu_save_as)
        file_menu.add_separator()
        file_menu.add_command(label="Выход", command=self.on_close, accelerator="Ctrl+Q")
        menubar.add_cascade(label="Файл", menu=file_menu)
        self.config(menu=menubar)

    def _build_body(self):
        # Кнопка 1 — SET_CELL
        button1 = tk.Button(
            self,
            text="Кнопка 1 (SET_CELL A1)",
            command=self.button1_click,
            bg="lightblue",
            fg="black",
            font=("Arial", 12),
            width=22,
            height=2,
        )
        button1.pack(pady=20)

        # Кнопка 2 — GET_CELL
        button2 = tk.Button(
            self,
            text="Кнопка 2 (GET_CELL A1)",
            command=self.button2_click,
            bg="lightgreen",
            fg="black",
            font=("Arial", 12),
            width=22,
            height=2,
        )
        button2.pack(pady=10)

    # === Команды ===

    def button1_click(self):
        # SET_CELL sheet=0 addr=A1 text="Hello from GUI"
        try:
            resp = self.ipc.send("SET_CELL", {"sheet": 0, "addr": "A1", "text": "Hello from GUI"})
            if resp.get("ok"):
                messagebox.showinfo("Кнопка 1", "Значение записано в A1.")
            else:
                messagebox.showerror("Ошибка", resp.get("error", "Неизвестная ошибка"))
        except Exception as e:
            messagebox.showerror("Сбой IPC", str(e))

    def button2_click(self):
        # GET_CELL sheet=0 addr=A1
        try:
            resp = self.ipc.send("GET_CELL", {"sheet": 0, "addr": "A1"})
            if resp.get("ok"):
                value = (resp.get("result") or {}).get("value")
                messagebox.showinfo("Кнопка 2", f"A1 = {value!r}")
            else:
                messagebox.showerror("Ошибка", resp.get("error", "Неизвестная ошибка"))
        except Exception as e:
            messagebox.showerror("Сбой IPC", str(e))

    def menu_save_as(self):
        path = filedialog.asksaveasfilename(
            title="Сохранить как…",
            defaultextension=".xlsx",
            filetypes=[("Excel files", "*.xlsx"), ("All files", "*.*")],
        )
        if not path:
            return
        try:
            resp = self.ipc.send("SAVE_AS", {"path": path})
            if resp.get("ok"):
                messagebox.showinfo("Сохранение", f"Сохранено:\n{path}")
            else:
                messagebox.showerror("Ошибка сохранения", resp.get("error", "Неизвестная ошибка"))
        except Exception as e:
            messagebox.showerror("Сбой IPC", str(e))

    # === Выход ===

    def on_close(self):
        """Всегда отправляем EXIT, потом закрываем окно."""
        try:
            self.ipc.exit()
        finally:
            self.destroy()


# ========== Bootstrap / safety ==========

def parse_args():
    p = argparse.ArgumentParser(description="Demo GUI for MyOffice IPC")
    p.add_argument("--ipc", required=True, help="Путь к getWorkingDirectory() надстройки")
    return p.parse_args()

def main():
    args = parse_args()
    ipc = IPCClient(args.ipc)

    # Гарантия EXIT при любом завершении процесса
    atexit.register(lambda: ipc.exit())

    # Перехватчик неотловленных исключений — тоже шлём EXIT
    def _excepthook(exc_type, exc, tb):
        try:
            ipc.exit()
        finally:
            # покажем пользователю и завершимся
            messagebox.showerror("Критическая ошибка", f"{exc_type.__name__}: {exc}")
            sys.__excepthook__(exc_type, exc, tb)
    sys.excepthook = _excepthook

    app = App(ipc)
    app.mainloop()

if __name__ == "__main__":
    main()
