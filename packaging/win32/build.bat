@echo off

:: Run this script from project root

set appName=Nyrna

:: Remember to update the version number before packaging.
setlocal
:PROMPT
SET /P AREYOUSURE=Did you update VERSION? (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END


:: Start the packaging process.


echo Cleaning project..
:: Make sure output directory is clean.
rmdir /s /Q %cd%\build
echo.
call flutter clean

echo Getting dependencies..
echo.
call flutter pub get

echo.
echo Building %appName% Windows version..
echo.
call flutter build windows

echo Moving & renaming compiled bundle
move %cd%\build\windows\runner\Release %cd%\build\%appName%

:: Set directory variables.
set compiledFolder=%cd%\build\%appName%

echo.
echo Copying Visual C++ Redistributable libraries to output directory
echo.
xcopy C:\Windows\System32\msvcp140.dll %compiledFolder%
xcopy C:\Windows\System32\vcruntime140.dll %compiledFolder%
xcopy C:\Windows\System32\vcruntime140_1.dll %compiledFolder%


echo.
echo Copying VERSION into bundle
echo.
copy VERSION %compiledFolder%\VERSION

echo Creating installer version..
call iscc %cd%\packaging\win32\inno_setup_script.iss

echo.
echo Creating PORTABLE file before packaging portable version
echo.
echo null > %compiledFolder%\PORTABLE

echo Creating portable version archive..
call powershell Compress-Archive %compiledFolder% %cd%\build\%appName%-windows-portable.zip 


echo Finished building and packaging %appName%

:END
endlocal
