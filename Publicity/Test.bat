@echo off
echo Testing the compiler...
echo.
xc =p Test.prj
echo.
:: The compiler must fail to compile the B module, but currently it stops on the
:: Test module.
if exist B.obj echo Test failed! && goto :done
echo Test passed!
:done
del tmp.lnk *.obj *.sym *.exe 1>nul 2>nul 
