@echo off
setlocal

:: Call the VBScript to select a file and get the file path
echo Set objDialog = CreateObject("UserAccounts.CommonDialog") > "%temp%\SelectFile.vbs"
echo objDialog.Filter = "All Files|*.*" >> "%temp%\SelectFile.vbs"
echo objDialog.InitialDir = "C:\" >> "%temp%\SelectFile.vbs"
echo objDialog.Flags = &H80000 >> "%temp%\SelectFile.vbs"
echo If objDialog.ShowOpen Then WScript.Echo objDialog.FileName >> "%temp%\SelectFile.vbs"

:: Run VBScript and capture the selected file path
for /f "delims=" %%I in ('cscript //nologo "%temp%\SelectFile.vbs"') do set "FILE_PATH=%%I"

:: Delete the temporary VBScript file
del "%temp%\SelectFile.vbs"

:: Extract file name from the full path
for %%I in ("%FILE_PATH%") do set "FILE_NAME=%%~nxI"

:: Print results
echo Full Path: %FILE_PATH%
echo File Name: %FILE_NAME%

endlocal
pause