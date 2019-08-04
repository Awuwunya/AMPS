@echo off
asm68k /m /p /o ae- /e safe=0 sonic1.asm, s1built.md, , .lst
if NOT EXIST s1built.md pause & exit
fixheadr.exe s1built.md
