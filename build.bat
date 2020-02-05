@echo off
"AMPS\Includer.exe" ASM68K AMPS AMPS\.Data
asm68k /p /m code/main.asm, player.md, , .lst>.log
type .log
if not exist player.md pause & exit
error\convsym .lst player.md -input asm68k_lst -inopt "/localSign=. /localJoin=. /ignoreMacroDefs+ /ignoreMacroExp- /addMacrosAsOpcodes+" -a
del AMPS\.Data
