@echo off
echo ========================================================
echo   Setting up and Launching Battery Notification Manager  
echo ========================================================
echo.

:: Automatically add Flutter, System32, PowerShell, and Git to session PATH
set "PATH=C:\flutter\bin;C:\Windows\System32;C:\Windows\System32\WindowsPowerShell\v1.0;C:\Program Files\Git\cmd;%PATH%"
echo [Info] Configured session PATH with Flutter, System32, PowerShell, and Git.

echo [1/5] Initializing native Windows templates...
call flutter create --platforms=windows .
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to run flutter create. Make sure Flutter is installed and in your PATH.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/5] Restoring custom codebase...
copy pubspec.yaml.backup pubspec.yaml /Y
copy lib\main.dart.backup lib\main.dart /Y

echo.
echo [3/5] Setting up asset folder and icons...
if not exist assets (
    mkdir assets
)
copy "C:\Users\Deep\.gemini\antigravity\brain\878b8c34-7474-448c-ae67-280871b6f355\app_icon_1782313865577.png" "assets\app_icon.png" /Y
copy "C:\Users\Deep\.gemini\antigravity\brain\878b8c34-7474-448c-ae67-280871b6f355\app_icon_alert_1782313882179.png" "assets\app_icon_alert.png" /Y

echo.
echo [4/5] Pulling Flutter package dependencies...
call flutter pub get

echo.
echo [5/5] Compiling and running the Windows application...
call flutter run -d windows

pause
