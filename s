@echo off

setlocal

:ChooseFile
echo Please select a file:

for /f "delims=" %%a in ('powershell -Command "[System.Windows.Forms.OpenFileDialog]::new().ShowDialog() | Out-String" ') do (
  set "filePath=%%a"
)

if not defined filePath (
  echo No file selected.  Exiting.
  pause
  exit /b 1
)

echo File Path: "%filePath%"

REM Extract file name
for /f "delims=\" %%a in ("%filePath%") do (
  set "fileName=%%a"
)

echo File Name: "%fileName%"


REM Extract path without filename.  More robust method:
for /f "delims=" %%a in ("%filePath%") do (
  set "fullPath=%%~dpf a"  REM %%~dpf expands to drive and path
)

echo Full Path (without filename): "%fullPath%"

REM  Alternative method if you're SURE there's a drive letter:
REM set "pathOnly=%filePath:~0,-%fileName:~0%"
REM echo Path Only (alternative): "%pathOnly%"

echo.
echo Done!

endlocal
pause
