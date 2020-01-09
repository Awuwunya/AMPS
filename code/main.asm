	include	"error/Debugger.asm"
	include "code/macro.asm"
	include "AMPS/code/smps2asm.asm"
	include "AMPS/code/macro.asm"
	include "AMPS/lang.asm"

; ===========================================================================
	org 0
StartOfRom:	dc.l Stack, EntryPoint, BusError, AddressError
		dc.l IllegalInstr, ZeroDivide, ChkInstr, TrapvInstr
		dc.l PrivilegeViol, Trace, Line1010Emu, Line1111Emu
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
		dc.l ErrorExcept, ErrorTrap, ErrorTrap,	ErrorTrap
		dc.l ErrorExcept, ErrorTrap, VInt, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
HConsole:	dc.b 'SEGA SSF        ' ; Hardware system ID
		dc.b 'NATSUMI 2016-FEB' ; Release date
		dc.b "NATSUMI'S SEGA MEGA DRIVE SMPS PLAYER DEMO      " ; Domestic name
		dc.b "NATSUMI'S SEGA MEGA DRIVE SMPS PLAYER DEMO      " ; International name
		dc.b 'UNOFFICIAL-00 '   ; Serial/version number
		dc.w 0
		dc.b 'J               ' ; I/O support
		dc.l StartOfRom		; ROM start
		dc.l EndOfRom-1		; ROM end
		dc.l $FF0000		; RAM start
		dc.l $FFFFFF		; RAM end
		dc.b 'NO SRAM     '
		dc.b 'OPEN SOURCE SOFTWARE. YOU ARE WELCOME TO MAKE YOUR  '
		dc.b 'JUE '
		dc.b 'OWN MODIFICATIONS. PLEASE CREDIT WHEN USED'
; ===========================================================================
SystemPalette:
	incbin  "code/main.pal"		; system main palette
	even

SystemFont:
	incbin  "code/font.kos"		; System font - made by Bakayote
	even
; ===========================================================================

	include "code/init.asm"		; initialization code and main loop
	include "code/string.asm"	; string lib
	include "code/draw.asm"		; rendering and visualisation routines
	include "code/vint.asm"		; v-int routines
	include "code/decomp.asm"	; decompressor routines

; ===========================================================================
DualPCM:	z80prog 0
		include "AMPS/code/z80.asm"
DualPCM_sz:	z80prog

	align $10000
	include "AMPS/code/68k.asm"
	opt ae-

; ===========================================================================
	opt ae+
		include	"error/ErrorHandler.asm"
EndOfRom:	END
