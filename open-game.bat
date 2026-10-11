@echo off
setlocal
cd /d "%~dp0"

set "NODE_EXE="
where node.exe >nul 2>nul
if not errorlevel 1 set "NODE_EXE=node.exe"
if not defined NODE_EXE if exist "%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe" set "NODE_EXE=%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"

if not defined NODE_EXE (
  echo Node.js 20 or newer is required to run the game.
  echo Install Node.js from https://nodejs.org then double-click this file again.
  pause
  exit /b 1
)

"%NODE_EXE%" -e "process.exit(Number(process.versions.node.split('.')[0]) >= 20 ? 0 : 1)"
if errorlevel 1 (
  echo Node.js 20 or newer is required. Please update Node.js.
  pause
  exit /b 1
)

if not exist "node_modules\vite\package.json" (
  echo Installing game dependencies - first run only...
  where npm.cmd >nul 2>nul
  if errorlevel 1 (
    echo npm was not found. Open a terminal in this folder and run: npm install
    pause
    exit /b 1
  )
  call npm.cmd install
  if errorlevel 1 (
    echo npm install failed. Check your internet connection and try again.
    pause
    exit /b 1
  )
)

if not exist "dist\index.html" (
  echo Building the game - first run only...
  "%NODE_EXE%" "%CD%\node_modules\vite\bin\vite.js" build
  if errorlevel 1 (
    echo Build failed. See the messages above.
    pause
    exit /b 1
  )
)

start "OPERATION HEBREW local site" /min "%NODE_EXE%" "%CD%\node_modules\vite\bin\vite.js" preview --host 127.0.0.1 --port 3001

set /a TRIES=0
:waitloop
powershell -NoProfile -Command "try { Invoke-WebRequest 'http://127.0.0.1:3001' -UseBasicParsing -TimeoutSec 1 | Out-Null; exit 0 } catch { exit 1 }" >nul 2>nul
if not errorlevel 1 goto ready
set /a TRIES+=1
if %TRIES% GEQ 20 (
  echo The local server did not start. Is port 3001 used by another program?
  pause
  exit /b 1
)
timeout /t 1 /nobreak >nul
goto waitloop

:ready
start "" "http://127.0.0.1:3001"
