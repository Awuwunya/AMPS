; ===========================================================================
; ---------------------------------------------------------------------------
; Equates
; ---------------------------------------------------------------------------

Main		SECTION org(0)
	opt l.			; local label symbol is .
	opt w-			; disable warnings

Z80_Space =	$2000		; The amount of space reserved for Z80 driver. The compressor tool may ask you to increase the size...

Drvmem =	$FFFFA480	; $4000	; sound driver memory location
Stack =		$FFFFA480	; $80	; end of stack
HBlankRAM =	$FFFFFFF0	; word	; jmp $00000000
HBlankRout =	HBlankRAM+$02	; long	; ''
VBlankRAM =	HBlankRout+$04	; word	; jmp $00000000
VBlankRout =	VBlankRAM+$02	; long	; ''
ConsoleRegion =	$FFFFFFEE	; byte	; region settings

	include	"error/Debugger.asm"
	include "AMPS/code/smps2asm.asm"
	include "AMPS/code/macro.asm"
	include "AMPS/lang.asm"
; ===========================================================================
; ---------------------------------------------------------------------------
; Macros
; ---------------------------------------------------------------------------

	; --- Alignment ---

align		macro
	cnop	0,\1
    endm

	; --- DMA to (a6) containing C00004 ---

DMA		macro	Size, Source, Destination
	move.l	#(((((\Size/$02)<<$08)&$FF0000)+((\Size/$02)&$FF))+$94009300),(a6)
	move.l	#((((((\Source&$FFFFFF)/$02)<<$08)&$FF0000)+(((\Source&$FFFFFF)/$02)&$FF))+$96009500),(a6)
	move.l	#(((((\Source&$FFFFFF)/$02)&$7F0000)+$97000000)+((\Destination>>$10)&$FFFF)),(a6)
	move.w	#((\Destination&$FF7F)|$80),(a6)
    endm

	; --- Code to handle v-sync ---

vsync		macro
	move	#$2300,sr
.loop\@	tst.b	($FFFFF62A).w
	bne.s	.loop\@
    endm

	; --- Macro for generating sound test strings ---

dtext		macro type, str
	if strlen(\str)>27
		inform 2, "too long music/sound effect name"
	endif

	if \type=0
		dc.b " SFX - "
	else
		dc.b " MUS - "
	endif

	duc \str
	dcb.b 27-strlen(\str), " "
	dc.b " ", 0
    endm

	; --- Macro for converting lowercase to uppercase ---

duc	macro	str
.lc = 0
	rept strlen(\str)
.cc		substr .lc+1,.lc+1,\str

		if ('\.cc'>='a')&('\.cc'<='z')
			dc.b ('\.cc'-'a'+'A')

		else
			dc.b '\.cc'
		endif

.lc =		.lc+1
	endr
    endm

; ===========================================================================
; ---------------------------------------------------------------------------
; Header
; ---------------------------------------------------------------------------

		dc.l Stack, EntryPoint, BusError, AddressError
		dc.l IllegalInstr, ZeroDivide, ChkInstr, TrapvInstr
		dc.l PrivilegeViol, Trace, Line1010Emu,	Line1111Emu
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
		dc.l ErrorExcept, ErrorTrap, ErrorTrap,	ErrorTrap
		dc.l HBlankRAM,	ErrorTrap, VBlankRAM, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
HConsole:	dc.b 'SEGA MEGA DRIVE '
		dc.b 'AURORAF 2020-MAY'
		dc.b 'AURORA FIELDS'' AMPS SOUND TESTING ROM           '
		dc.b 'AURORA FIELDS'' AMPS SOUND TESTING ROM           '
		dc.b 'UNOFFICIAL-20 '
		dc.w 0
		dc.b 'J               '
		dc.l 0, EndOfRom-1, $FF0000, $FFFFFF
		dc.b 'NO SRAM     '
		dc.b 'OPEN SOURCE SOFTWARE. YOU ARE WELCOME TO MAKE YOUR  '
		dc.b 'JUE '
		dc.b 'OWN MODIFICATIONS. PLEASE CREDIT WHEN USED'

; ===========================================================================
; ---------------------------------------------------------------------------
; Code section
; ---------------------------------------------------------------------------

EntryPoint:
		tst.l	$A10009-1		; test port A control
		bne.s	PortA_Ok
		tst.w	$A1000B-1		; test port C control

PortA_Ok:
		bne.s	PortC_Ok
		lea	SetupValues(pc),a5
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		move.b	-$10FF(a1),d0	; get hardware version
		andi.b	#$F,d0
		beq.s	SkipSecurity
		move.l	HConsole.w,$2F00(a1)

SkipSecurity:
		move.w	(a4),d0		; check	if VDP works
		moveq	#0,d0
		movea.l	d0,a6
		move.l	a6,usp		; set usp to $0

		moveq	#$17,d1
VDPInitLoop:
		move.b	(a5)+,d5	; add $8000 to value
		move.w	d5,(a4)		; move value to	VDP register
		add.w	d7,d5		; next register
		dbf	d1,VDPInitLoop

		move.l	(a5)+,(a4)
		move.w	d0,(a3)		; clear	the screen
		move.w	d7,(a1)		; stop the Z80
		move.w	d7,(a2)		; reset	the Z80

WaitForZ80:
		btst	d0,(a1)		; has the Z80 stopped?
		bne.s	WaitForZ80	; if not, branch
		moveq	#endinit-initz80-1,d2
Z80InitLoop:
		move.b	(a5)+,(a0)+
		dbf	d2,Z80InitLoop

		move.w	d0,(a2)
		move.w	d0,(a1)		; start	the Z80
		move.w	d7,(a2)		; reset	the Z80
ClrRAMLoop:
		move.l	d0,-(a6)
		dbf	d6,ClrRAMLoop	; clear	the entire RAM

		move.l	(a5)+,(a4)	; set VDP display mode and increment
		move.l	(a5)+,(a4)	; set VDP to CRAM write
		moveq	#$1F,d3
ClrCRAMLoop:
		move.l	d0,(a3)
		dbf	d3,ClrCRAMLoop	; clear	the CRAM

		move.l	(a5)+,(a4)
		moveq	#$13,d4

ClrVDPStuff:
		move.l	d0,(a3)
		dbf	d4,ClrVDPStuff

		moveq	#3,d5
PSGInitLoop:
		move.b	(a5)+,$11(a3)		; reset	the PSG
		dbf	d5,PSGInitLoop

		move.w	d0,(a2)
		movem.l	(a6),d0-a6		; clear	all registers
		move	#$2700,sr		; set the sr

PortC_Ok:
		moveq	#$40,d0
		move.b	d0,$A10009
		move.b	d0,$A1000B
		move.b	d0,$A1000D
		bra.w	GameProgram

; ===========================================================================
SetupValues:	dc.w $8000		; XREF: PortA_Ok
		dc.w $3FFF
		dc.w $100

		dc.l $A00000		; start	of Z80 RAM
		dc.l $A11100		; Z80 bus request
		dc.l $A11200		; Z80 reset
		dc.l $C00000
		dc.l $C00004		; address for VDP registers

		dc.b 4,	$74, $30, $3C	; values for VDP registers
		dc.b 7,	$6C, 0,	0
		dc.b 0,	0, $FF,	0
		dc.b $81, $37, 0, 1
		dc.b 1,	0, 0, $FF
		dc.b $FF, 0, 0,	$80

		dc.l $40000080

initz80	z80prog 0
		di
		im	1
		ld	hl,YM_Buffer1			; we need to clear from YM_Buffer1
		ld	de,(YM_BufferEnd-YM_Buffer1)/8	; to end of Z80 RAM, setting it to 0FFh

.loop
		ld	a,0FFh				; load 0FFh to a
		rept 8
			ld	(hl),a			; save a to address
			inc	hl			; go to next address
		endr

		dec	de				; decrease loop counter
		ld	a,d				; load d to a
		zor	e				; check if both d and e are 0
		jr	nz, .loop			; if no, clear more memoty
.pc		jr	.pc				; trap CPU execution
	z80prog
		even
endinit
		dc.w $8174			; value	for VDP	display	mode
		dc.w $8F02			; value	for VDP	increment
		dc.l $C0000000			; value	for CRAM write mode
		dc.l $40000010

		dc.b $9F, $BF, $DF, $FF		; values for PSG channel volumes
; ===========================================================================

GameProgram:
		move	#$2700,sr			; disable interrupts

;		lea	$C00004,a6
;		move.w	#$8F01,(a6)			; VRAM pointer increment: $0001
;		move.l	#(($9400|((($FFFF)&$FF00)>>8))<<16)|($9300|(($FFFF)&$FF)),(a6) ; DMA length ...
;		move.w	#$9780,(a6)			; VRAM fill
;		move.l	#$40000080|((0&$3FFF)<<16)|((0&$C000)>>14),(a6) ; Start at ...
;		move.w	#0<<8,-4(a6)			; Fill with byte

;.loop		move.w	(a6),d1
;		btst	#1,d1
;		bne.s	.loop				; busy loop until the VDP is finished filling...
;		move.w	#$8F02,(a6)			; VRAM pointer increment: $0002

		move.b	$A10001,d0			; get System version bits
		andi.b	#$C0,d0
		move.b	d0,ConsoleRegion.w		; save into RAM

		move.w	#$4EF9,VBlankRAM.w
		move.l	#NullBlank,VBlankRout.w
		move.w	#$4EF9,HBlankRAM.w
		move.l	#NullBlank,HBlankRout.w
		jsr	LoadDualPCM			; load dual pcm
		jmp	SoundTest(pc)

; ===========================================================================
; ---------------------------------------------------------------------------
; Includes
; ---------------------------------------------------------------------------

		include "Routines.asm"			; code needed to support sound test
		include "Sound Test.asm"		; sound test program code

DualPCM:
		PUSHS					; store section information for Main
Z80Code		SECTION	org(0), file("AMPS/.z80")	; create a new section for Dual PCM
		z80prog 0				; init z80 program
		include "AMPS/code/z80.asm"		; code for Dual PCM
DualPCM_sz:	z80prog					; end z80 program
		POPS					; go back to Main section

		PUSHS					; store section information for Main
mergecode	SECTION	file("AMPS/.z80.dat"), org(0)	; create settings file for storing info about how to merge things
		dc.l offset(DualPCM), Z80_Space		; store info about location of file and size available

	if zchkoffs
		rept zfuturec
			popp zoff			; grab the location of the patch
			popp zbyte			; grab the correct byte
			dc.w zoff			; write the address
			dc.b zbyte, '>'			; write the byte and separator
		endr
	endif
		POPS					; go back to Main section

	ds.b Z80_Space					; reserve space for the Z80 driver
	even

		align $10000
		include "AMPS/code/68k.asm"

; ===========================================================================

	opt ae+
		include	"error/ErrorHandler.asm"
EndOfRom:	END
