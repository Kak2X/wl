@echo off
setlocal enableextensions enabledelayedexpansion
set source=%~1
set filename=%~2
set comparison=%~3
if "%filename%" == "" (
	echo Don't execute this file directly.
	goto end
)
set searchStr=-nofix
call:inStr %*
set nofix=%ERRORLEVEL%

echo Assembling...
rgbds\rgbasm -h -L -vo -v -o %filename%.o %source%.asm
if %ERRORLEVEL% neq 0 goto assemble_fail

echo Linking...
rgbds\rgblink -m %filename%.map -n %filename%.sym -d -o %filename%.gb %filename%.o
if %ERRORLEVEL% neq 0 goto link_fail

echo ==========================
echo   Build Success.
echo ==========================

if %nofix% equ 0 (
	echo Fixing header checksum...
	rgbds\rgbfix -v %filename%.gb
)

if NOT "%comparison%" == "" if EXIST %comparison% ( fc /B %filename%.gb %comparison% | more )
goto end

:assemble_fail
echo Error while assembling.
goto fail
:link_fail
echo Error while linking.
:fail

echo ==========================
echo   Build failure.
echo ==========================

:end
pause
exit /b

:inStr
	set args=%*
	if not "x!args:%searchStr%=!"=="x%args%" ( exit /b 1 )
	exit /b 0