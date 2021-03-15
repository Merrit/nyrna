@echo off

set appName=Nyrna

:: Remember to update the version number before packaging.
setlocal
:PROMPT
SET /P AREYOUSURE=Did you update version in constants.dart, changelog, etc? (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END


:: Start the packaging process.


echo Changing working dir to project root
echo.
cd ..\..\

echo Cleaning project..
:: Make sure output directory is clean.
rmdir /s /Q %cd%\packaging\output
echo.
call flutter clean

echo Getting dependencies..
echo.
call flutter pub get

echo.
echo Building %appName% Windows version..
echo.
call flutter build windows

:: Create the base output directory.
mkdir %cd%\packaging\output

:: Set directory variables.
set buildDir=%cd%\build\windows\runner\Release
set outputDir=%cd%\packaging\output

echo Moving compiled bundle to $projectRoot\packaging\output
move %buildDir% %outputDir%\%appName%

echo.
echo Copying Visual C++ Redistributable libraries to output directory
echo.
xcopy C:\Windows\System32\msvcp140.dll %outputDir%\%appName%
xcopy C:\Windows\System32\vcruntime140.dll %outputDir%\%appName%
xcopy C:\Windows\System32\vcruntime140_1.dll %outputDir%\%appName%

echo Creating portable version archive..
call powershell Compress-Archive %outputDir%\%appName% %outputDir%\%appName%-windows-portable.zip 

echo Creating installer version..
call iscc %cd%\packaging\win32\inno_setup_script.iss

echo Finished building and packaging %appName%

:END
endlocal
