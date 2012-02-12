@echo off

:: backup the module
copy /y BugHere.ob2 BugHere.ob2.bak >nul

:: compile the "fixed" version
mkdir obj 2>nul
del /q obj\* Test.exe 2>nul
xc =p Test.prj
if errorlevel 1 goto :compileError

call CheckBug.bat
if %errorlevel% neq 1 goto :cantReproduce

sed -e "/Another invalid location error in optimized code is removed by this call/d" < BugHere.ob2.bak > BugHere.ob2
del /q obj\BugHere.* Test.exe
:: compile the "broken" version
xc =p Test.prj
if errorlevel 1 goto :compileError

call CheckBug.bat
if %errorlevel% neq 2 goto :cantReproduce
goto :reproduced

:compileError
@echo.
@echo Compilation error.
goto :finalize

:cantReproduce
@echo.
@echo Can't reproduce the Bug!
goto :finalize

:reproduced
@echo.
@echo The Bug was reproduced successfully.
goto :finalize

:finalize
:: restore the module
copy /y BugHere.ob2.bak BugHere.ob2 >nul
