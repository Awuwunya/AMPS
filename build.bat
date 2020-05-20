@echo off
"AMPS\Includer.exe" ASM68K AMPS AMPS\.Data
asm68k /p /m Main.asm, player.md, , .lst>.log
type .log
if not exist player.md pause & exit
"AMPS\Dual PCM Compress.exe" AMPS\.z80 AMPS\.z80.dat player.md _dlls\koscmp.exe
error\convsym .lst player.md -input asm68k_lst -inopt "/localSign=. /localJoin=. /ignoreMacroDefs+ /ignoreMacroExp- /addMacrosAsOpcodes+" -a
del AMPS\.Data
