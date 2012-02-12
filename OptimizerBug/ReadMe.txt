This project reproduces an optimizer bug in XDS Oberon-2 compiler.
See comments in BugHere.ob2.
Author: Alexander Iljin <ajsoft@yandex.ru>, 2012.
The original broken project was provided by GameHunter:
http://forum.oberoncore.ru/viewtopic.php?p=69079#p69079

Tools required: Native XDS-x86 v2.50+, sed.exe, grep.exe.
Test.prj contains the set of compiler options necessary to reproduce the bug.
The other options should have their installation-default values.

Call Run.bat to see if the bug is reproduced. The bat-file compiles and runs
the test project and calls CheckBug.bat to make sure the bug isn't there.
(Initially the bug is "fixed" by two dummy calls to Disp.String in
BugHere.NewField.) Then sed.exe is used to remove the Disp.String calls and
the test project is recompiled. CheckBug.bat is used again to make sure that
removing the dummy calls restored the bug. The conclusion is printed to the
console.
