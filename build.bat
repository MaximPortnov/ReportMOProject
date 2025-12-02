@echo off
setlocal

REM === Configuration ===
set MYOFFICE_PATH=C:\Program Files\MyOffice
set SOURCE_DIR=%~dp0src
set BIN_DIR=%~dp0bin
set PACKAGE_NAME=test.mox

REM === Check MyOffice path ===
if not exist "%MYOFFICE_PATH%\MySpreadsheet.exe" (
    echo [ERROR] MyOffice not found at "%MYOFFICE_PATH%"
    echo Please verify the correct path in build.bat
    pause
    exit /b
)

REM === Build and install the extension ===
echo Building and installing the extension...
"%MYOFFICE_PATH%\mox" create --delete --source="%SOURCE_DIR%" --package="%BIN_DIR%\%PACKAGE_NAME%"
"%MYOFFICE_PATH%\MySpreadsheet.exe" --installextension="%BIN_DIR%\%PACKAGE_NAME%" --installunsignedextension --installextensionmode=install

REM === Launch MyOffice ===
echo Launching MyOffice Spreadsheet...
start "" "%MYOFFICE_PATH%\MySpreadsheet.exe"

endlocal
