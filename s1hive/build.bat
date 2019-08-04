@echo off
asm68k /m /p /o ae- /e safe=1 sonic1.asm, s1built.md, , .lst
if NOT EXIST s1built.md pause & exit
error\convsym .lst s1built.md -input asm68k_lst -inopt "/localSign=. /localJoin=. /ignoreMacroDefs+ /ignoreMacroExp- /addMacrosAsOpcodes+" -a
fixheadr.exe s1built.md
