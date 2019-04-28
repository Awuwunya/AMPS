@echo off
asm68k /p /m /j ../* Code/main.asm, player.md, , .lst>.log
type .log
if not exist player.md pause & exit
..\ErrorDebugger\convsym .lst player.md -input asm68k_lst -inopt "/localSign=. /localJoin=. /ignoreMacroDefs+ /ignoreMacroExp- /addMacrosAsOpcodes+" -a
