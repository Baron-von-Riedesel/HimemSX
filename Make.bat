@echo off
rem JWasm used to create HimemSX.exe
if not exist "Release\NUL" mkdir Release
jwasm.exe -nologo -mz -Sg -Sn -D?ALTSTRAT=1 -Fl=Release\HimemSX.LST -Fo=Release\HimemSX.exe HimemSX.asm
