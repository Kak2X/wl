@echo off
echo Assembling...
rgbds\rgbasm -v -o wl.o config_test.asm
if %ERRORLEVEL% neq 0 goto assemble_fail

echo Linking...
rgbds\rgblink -m wl.map -n wl.sym -d -o wl.gb wl.o
if %ERRORLEVEL% neq 0 goto link_fail

echo ==========================
echo   Build Success.
echo ==========================
echo Fixing header checksum...
rgbds\rgbfix -v wl.gb

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