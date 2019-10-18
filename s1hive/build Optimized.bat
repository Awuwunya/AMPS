@echo off
"..\driver\AMPS Includer.exe" ASM68K driver driver\.Data
asm68k /m /p /o ae- /e safe=0 sonic1.asm, s1built.dat, , .lst>.log
type .log
if NOT EXIST s1built.dat pause & exit
call driver/z80.bat
error\convsym .lst s1built.md -input asm68k_lst -inopt "/localSign=. /localJoin=. /ignoreMacroDefs+ /ignoreMacroExp- /addMacrosAsOpcodes+" -a
fixheadr.exe s1built.md
del driver\.Data
del driver\z80.bat
del driver\merge.asm
del driver\.z80
del driver\.z80.kos
del s1built.dat
