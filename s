@echo off
setlocal enabledelayedexpansion

:: Define an array (a space-separated list of words)
set "WORDS=hello world bat script good example"

:: Get user input
set /p INPUT=Enter a word: 

:: Initialize a flag to track if a match is found
set MATCH_FOUND=0

:: Iterate over the array and check for a match
for %%A in (%WORDS%) do (
    if /I "%%A"=="%INPUT%" (
        set MATCH_FOUND=1
        goto :MATCH
    )
)

:: Check if a match was found
:MATCH
if %MATCH_FOUND%==1 (
    echo Good!
) else (
    echo Not found.
)

pause
