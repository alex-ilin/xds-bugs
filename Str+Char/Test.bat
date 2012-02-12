@echo off
echo Testing the compiler...
echo.
xc =make Test.ob2 && echo. && echo Test passed! && del tmp.lnk Test.obj Test.sym Test.exe 1>nul 2>nul && goto :eof
echo.
echo Test failed.
