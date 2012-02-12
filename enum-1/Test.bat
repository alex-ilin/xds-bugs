@echo off
:: make Definition.sym
echo.-makefile->makeDef.prj
echo.!module Definition>>makeDef.prj
xc.exe =p =a makeDef.prj

:: make Test.ob2
echo.!module Test.ob2>Test.prj
xc.exe =p Test.prj

if not exist Test.exe echo. && echo Test failed! && goto :done
echo.
Test.exe
echo.

:done
del tmp.lnk Test.obj Test.sym Test.exe Test.prj Definition.sym makeDef.prj 1>nul 2>nul
