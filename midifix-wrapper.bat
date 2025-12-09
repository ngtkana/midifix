@echo off
setlocal

set "MIDIFIX_EXE=%LOCALAPPDATA%\midifix\midifix.exe"

if not exist "%MIDIFIX_EXE%" (
    echo Error: midifix.exe not found
    pause
    exit /b 1
)

if "%~1"=="" (
    echo Error: No file specified
    pause
    exit /b 1
)

echo Processing: %~1
echo.

"%MIDIFIX_EXE%" %*

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Success! Check the output file.
) else (
    echo.
    echo Failed with error code %ERRORLEVEL%
)

echo.
pause
