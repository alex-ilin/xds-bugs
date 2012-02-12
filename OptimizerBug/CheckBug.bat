@echo off

Test.exe 2>nul | grep "Start Init - End Init"
goto :result%errorlevel%

:result0
@echo.
@echo The Bug has disappeared
exit /b 1

:result1
Test.exe | grep "Start Init"
goto :result2%errorlevel%

:result20
@echo.
@echo The Bug is still present
exit /b 2

:result21
@echo.
@echo Error reproducing the Bug: test code never reached
exit /b 3
