@echo off
cls

WHERE php >nul 2>nul
IF %ERRORLEVEL% NEQ 0 goto ERROR-NO-PHP

@REM -------------------------------------------
@REM CREATE SCENARIOS
@REM -------------------------------------------
set buildConfig=p
echo THE UNIVERSAL MISSION BUILDER SCRIPT:
echo - Build [P]ersianGulf debug theater only (default)
echo - Build all [D]ebug theaters
echo - Build all [R]elease theaters
echo - [C]ancel
echo.
set /p buildConfig=Your choice:
echo.

IF "%buildConfig%" == "p" goto BUILD-DEBUG-PERSIAN
IF "%buildConfig%" == "P" goto BUILD-DEBUG-PERSIAN
IF "%buildConfig%" == "d" goto BUILD-DEBUG-ALL
IF "%buildConfig%" == "D" goto BUILD-DEBUG-ALL
IF "%buildConfig%" == "r" goto BUILD-RELEASE
IF "%buildConfig%" == "R" goto BUILD-RELEASE
goto CANCEL-END

:BUILD-DEBUG-ALL
if exist *.miz del *.miz
c:\php\php Make.php debug
goto COPY-TO-DCS

:BUILD-DEBUG-PERSIAN
if exist *.miz del *.miz
c:\php\php Make.php debug persiangulf
goto COPY-TO-DCS

:BUILD-RELEASE
if exist *.miz del *.miz
c:\php\php Make.php release
goto COPY-TO-DCS

:BUILD-MANUAL
WHERE pandoc >nul 2>nul
IF %ERRORLEVEL% NEQ 0 goto ERROR-NO-PANDOC
pandoc README.md -o README.pdf
goto END

@REM -------------------------------------------
@REM COPY OUTPUT MIZ FILES TO DCS'S MISSIONS DIRECTORY
@REM -------------------------------------------
:COPY-TO-DCS
if not exist "%userprofile%\Saved Games\DCS\Missions\" goto END
if not exist *.miz goto END
echo Copying output MIZ files to %userprofile%\Saved Games\DCS\Missions...
copy /y *.miz "%userprofile%\Saved Games\DCS\Missions"
echo DONE
goto END

:CANCEL-END
echo.
echo Build cancelled.
goto END

:ERROR-NO-PHP
echo.
echo CRITICAL ERROR: PHP not found. Please install PHP and add it to the PATH.
goto END

:END
echo.
