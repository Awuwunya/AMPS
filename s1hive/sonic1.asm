Main		SECTION org(0)
Z80_Space =	2056		; The amount of space reserved for Z80 driver. The batch file may ask you to increase the size...
z80_ram:	equ $A00000
z80_bus_request	equ $A11100
z80_reset:	equ $A11200
ConsoleRegion	equ $FFFFFFF8

		include "driver/lang.asm"
		include "driver/code/macro.asm"
		include "error/debugger.asm"

align		macro
	cnop 0,\1
    endm

; Macro for playing a command
command		macro id
	move.b #id,mQueue.w
    endm

; Macro for playing music
music		macro id
	move.b #id,mQueue+1.w
    endm

; Macro for playing sound effect
sfx		macro id
	move.b #id,mQueue+2.w
    endm
		opt w-
; ===========================================================================
StartOfRom:
Vectors:	dc.l $FFFE00, EntryPoint, BusError, AddressError
		dc.l IllegalInstr, ZeroDivide, ChkInstr, TrapvInstr
		dc.l PrivilegeViol, Trace, Line1010Emu,	Line1111Emu
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
		dc.l ErrorExcept, ErrorTrap, ErrorTrap,	ErrorTrap
		dc.l PalToCRAM,	ErrorTrap, loc_B10, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
MEGADRIVE:	dc.b 'SEGA MEGA DRIVE ' ; Hardware system ID
Date:		dc.b '(C)SEGA 1991.APR' ; Release date
Title_Local:	dc.b 'SONIC THE               HEDGEHOG                ' ; Domestic name
Title_Int:	dc.b 'SONIC THE               HEDGEHOG                ' ; International name
Serial:		dc.b 'GM 00001009-00'   ; Serial/version number
Checksum:	dc.w 0
		dc.b 'J               ' ; I/O support
RomStartLoc:	dc.l StartOfRom		; ROM start
RomEndLoc:	dc.l EndOfRom-1		; ROM end
RamStartLoc:	dc.l $FF0000		; RAM start
RamEndLoc:	dc.l $FFFFFF		; RAM end
SRAMSupport:	dc.l $20202020		; change to $5241E020 to create	SRAM
		dc.l $20202020		; SRAM start
		dc.l $20202020		; SRAM end
Notes:		dc.b '                                                    '
		dc.b 'JUE             ' ; Region
; ===========================================================================

;ErrorTrap:
;		nop
;		nop
;		bra.s	ErrorTrap
; ===========================================================================

EntryPoint:
		tst.l	($A10008).l	; test port A control
		bne.s	PortA_Ok
		tst.w	($A1000C).l	; test port C control

PortA_Ok:
		bne.s	PortC_Ok
		lea	SetupValues(pc),a5
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		move.b	-$10FF(a1),d0	; get hardware version
		andi.b	#$F,d0
		beq.s	SkipSecurity
		move.l	MEGADRIVE.w,$2F00(a1)

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
		move.b	(a5)+,$11(a3)	; reset	the PSG
		dbf	d5,PSGInitLoop
		move.w	d0,(a2)
		movem.l	(a6),d0-a6	; clear	all registers
		move	#$2700,sr	; set the sr

PortC_Ok:
		bra.s	GameProgram
; ===========================================================================
SetupValues:	dc.w $8000		; XREF: PortA_Ok
		dc.w $3FFF
		dc.w $100

		dc.l $A00000		; start	of Z80 RAM
		dc.l $A11100		; Z80 bus request
		dc.l $A11200		; Z80 reset
		dc.l $C00000
		dc.l $C00004		; address for VDP registers

		dc.b 4,	$14, $30, $3C	; values for VDP registers
		dc.b 7,	$6C, 0,	0
		dc.b 0,	0, $FF,	0
		dc.b $81, $37, 0, 1
		dc.b 1,	0, 0, $FF
		dc.b $FF, 0, 0,	$80

		dc.l $40000080

initz80	z80prog 0
		di				; disable interrupts
.pc		jp	.pc			; loop in place
	z80prog
		even
endinit
		dc.w $8104		; value	for VDP	display	mode
		dc.w $8F02		; value	for VDP	increment
		dc.l $C0000000		; value	for CRAM write mode
		dc.l $40000010

		dc.b $9F, $BF, $DF, $FF	; values for PSG channel volumes
; ===========================================================================

GameProgram:
		tst.w	($C00004).l
		btst	#6,($A1000D).l
		beq.s	CheckSumCheck
		cmpi.l	#'init',($FFFFFFFC).w ; has checksum routine already run?
		beq.w	GameInit	; if yes, branch

CheckSumCheck:
		movea.l	#ErrorTrap,a0	; start	checking bytes after the header	($200)
		movea.l	#RomEndLoc,a1	; stop at end of ROM
		move.l	(a1),d0
		moveq	#0,d1

loc_32C:
		add.w	(a0)+,d1
		cmp.l	a0,d0
		bcc.s	loc_32C
		movea.l	#Checksum,a1	; read the checksum
		cmp.w	(a1),d1		; compare correct checksum to the one in ROM
	;	bne.w	CheckSumError	; if they don't match, branch
		lea	($FFFFFE00).w,a6
		moveq	#0,d7
		move.w	#$7F,d6

loc_348:
		move.l	d7,(a6)+
		dbf	d6,loc_348
		move.b	($A10001).l,d0
		andi.b	#$C0,d0
		move.b	d0,($FFFFFFF8).w
		move.l	#'init',($FFFFFFFC).w ; set flag so checksum won't be run again

GameInit:
		lea	($FF0000).l,a6
		moveq	#0,d7
		move.w	#$3F7F,d6

GameClrRAM:
		move.l	d7,(a6)+
		dbf	d6,GameClrRAM	; fill RAM ($0000-$FDFF) with $0
		bsr.w	VDPSetupGame
		jsr	LoadDualPCM
		bsr.w	JoypadInit
		move.b	#0,($FFFFF600).w ; set Game Mode to Sega Screen

MainGameLoop:
		move.b	($FFFFF600).w,d0 ; load	Game Mode
		andi.w	#$1C,d0
		jsr	GameModeArray(pc,d0.w) ; jump to apt location in ROM
		bra.s	MainGameLoop
; ===========================================================================
; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

GameModeArray:
		bra.w	SegaScreen	; Sega Screen ($00)
; ===========================================================================
		bra.w	TitleScreen	; Title	Screen ($04)
; ===========================================================================
		bra.w	Level		; Demo Mode ($08)
; ===========================================================================
		bra.w	Level		; Normal Level ($0C)
; ===========================================================================
		bra.w	SpecialStage	; Special Stage	($10)
; ===========================================================================
		bra.w	ContinueScreen	; Continue Screen ($14)
; ===========================================================================
		bra.w	EndingSequence	; End of game sequence ($18)
; ===========================================================================
		bra.w	Credits		; Credits ($1C)
; ===========================================================================
		rts
; ===========================================================================

CheckSumError:
		bsr.w	VDPSetupGame
		move.l	#$C0000000,($C00004).l ; set VDP to CRAM write
		moveq	#$3F,d7

CheckSum_Red:
		move.w	#$E,($C00000).l	; fill screen with colour red
		dbf	d7,CheckSum_Red	; repeat $3F more times

CheckSum_Loop:
		bra.s	CheckSum_Loop
; ===========================================================================

loc_43A:
		move	#$2700,sr
		addq.w	#2,sp
		move.l	(sp)+,($FFFFFC40).w
		addq.w	#2,sp
		movem.l	d0-a7,($FFFFFC00).w
		bsr.w	ShowErrorMsg
		move.l	2(sp),d0
		bsr.w	sub_5BA
		move.l	($FFFFFC40).w,d0
		bsr.w	sub_5BA
		bra.s	loc_478
; ===========================================================================

loc_462:
		move	#$2700,sr
		movem.l	d0-a7,($FFFFFC00).w
		bsr.w	ShowErrorMsg
		move.l	2(sp),d0
		bsr.w	sub_5BA

loc_478:
		bsr.w	ErrorWaitForC
		movem.l	($FFFFFC00).w,d0-a7
		move	#$2300,sr
		rte

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ShowErrorMsg:				; XREF: loc_43A; loc_462
		lea	($C00000).l,a6
		move.l	#$78000003,($C00004).l
		lea	(Art_Text).l,a0
		move.w	#$27F,d1

Error_LoadGfx:
		move.w	(a0)+,(a6)
		dbf	d1,Error_LoadGfx
		moveq	#0,d0		; clear	d0
		move.b	($FFFFFC44).w,d0 ; load	error code
		move.w	ErrorText(pc,d0.w),d0
		lea	ErrorText(pc,d0.w),a0
		move.l	#$46040003,($C00004).l ; position
		moveq	#$12,d1		; number of characters

Error_LoopChars:
		moveq	#0,d0
		move.b	(a0)+,d0
		addi.w	#$790,d0
		move.w	d0,(a6)
		dbf	d1,Error_LoopChars ; repeat for	number of characters
		rts
; End of function ShowErrorMsg

; ===========================================================================
ErrorText:	dc.w asc_4E8-ErrorText,	asc_4FB-ErrorText ; XREF: ShowErrorMsg
		dc.w asc_50E-ErrorText,	asc_521-ErrorText
		dc.w asc_534-ErrorText,	asc_547-ErrorText
		dc.w asc_55A-ErrorText,	asc_56D-ErrorText
		dc.w asc_580-ErrorText,	asc_593-ErrorText
		dc.w asc_5A6-ErrorText
asc_4E8:	dc.b 'ERROR EXCEPTION    '
asc_4FB:	dc.b 'BUS ERROR          '
asc_50E:	dc.b 'ADDRESS ERROR      '
asc_521:	dc.b 'ILLEGAL INSTRUCTION'
asc_534:	dc.b '@ERO DIVIDE        '
asc_547:	dc.b 'CHK INSTRUCTION    '
asc_55A:	dc.b 'TRAPV INSTRUCTION  '
asc_56D:	dc.b 'PRIVILEGE VIOLATION'
asc_580:	dc.b 'TRACE              '
asc_593:	dc.b 'LINE 1010 EMULATOR '
asc_5A6:	dc.b 'LINE 1111 EMULATOR '
		even

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_5BA:				; XREF: loc_43A; loc_462
		move.w	#$7CA,(a6)
		moveq	#7,d2

loc_5C0:
		rol.l	#4,d0
		bsr.s	sub_5CA
		dbf	d2,loc_5C0
		rts
; End of function sub_5BA


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_5CA:				; XREF: sub_5BA
		move.w	d0,d1
		andi.w	#$F,d1
		cmpi.w	#$A,d1
		bcs.s	loc_5D8
		addq.w	#7,d1

loc_5D8:
		addi.w	#$7C0,d1
		move.w	d1,(a6)
		rts
; End of function sub_5CA


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ErrorWaitForC:				; XREF: loc_478
		bsr.w	ReadJoypads
		cmpi.b	#$20,($FFFFF605).w ; is	button C pressed?
		bne.w	ErrorWaitForC	; if not, branch
		rts
; End of function ErrorWaitForC

; ===========================================================================

Art_Text:	incbin	artunc\menutext.bin	; text used in level select and debug mode
		even

; ===========================================================================

loc_B10:				; XREF: Vectors
		movem.l	d0-a6,-(sp)
		tst.b	($FFFFF62A).w
		beq.s	loc_B88
		move.w	($C00004).l,d0
		move.l	#$40000010,($C00004).l
		move.l	($FFFFF616).w,($C00000).l
		btst	#6,($FFFFFFF8).w
		beq.s	loc_B42
		move.w	#$700,d0

loc_B3E:
		dbf	d0,loc_B3E

loc_B42:
		move.b	($FFFFF62A).w,d0
		move.b	#0,($FFFFF62A).w
		move.w	#1,($FFFFF644).w
		andi.w	#$3E,d0
		move.w	off_B6E(pc,d0.w),d0
		jsr	off_B6E(pc,d0.w)

loc_B5E:				; XREF: loc_B88
		jsr	UpdateAMPS

loc_B64:				; XREF: loc_D50
		addq.l	#1,($FFFFFE0C).w
		movem.l	(sp)+,d0-a6
		rte
; ===========================================================================
off_B6E:	dc.w loc_B88-off_B6E, loc_C32-off_B6E
		dc.w loc_C44-off_B6E, loc_C5E-off_B6E
		dc.w loc_C6E-off_B6E, loc_DA6-off_B6E
		dc.w loc_E72-off_B6E, loc_F8A-off_B6E
		dc.w loc_C64-off_B6E, loc_F9A-off_B6E
		dc.w loc_C36-off_B6E, loc_FA6-off_B6E
		dc.w loc_E72-off_B6E
; ===========================================================================

loc_B88:				; XREF: loc_B10; off_B6E
		cmpi.b	#$8C,($FFFFF600).w
		beq.s	loc_B9A
		cmpi.b	#$C,($FFFFF600).w
		bne.w	loc_B5E

loc_B9A:
		cmpi.b	#1,($FFFFFE10).w ; is level LZ ?
		bne.w	loc_B5E		; if not, branch
		move.w	($C00004).l,d0
		btst	#6,($FFFFFFF8).w
		beq.s	loc_BBA
		move.w	#$700,d0

loc_BB6:
		dbf	d0,loc_BB6

loc_BBA:
		move.w	#1,($FFFFF644).w
		tst.b	($FFFFF64E).w
		bne.s	loc_BFE
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		bra.s	loc_C22
; ===========================================================================

loc_BFE:				; XREF: loc_BC8
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)

loc_C22:				; XREF: loc_BC8
		move.w	($FFFFF624).w,(a5)
		bra.w	loc_B5E
; ===========================================================================

loc_C32:				; XREF: off_B6E
		bsr.w	sub_106E

loc_C36:				; XREF: off_B6E
		tst.w	($FFFFF614).w
		beq.w	locret_C42
		subq.w	#1,($FFFFF614).w

locret_C42:
		rts
; ===========================================================================

loc_C44:				; XREF: off_B6E
		bsr.w	sub_106E
		bsr.w	sub_6886
		bsr.w	sub_1642
		tst.w	($FFFFF614).w
		beq.w	locret_C5C
		subq.w	#1,($FFFFF614).w

locret_C5C:
		rts
; ===========================================================================

loc_C5E:				; XREF: off_B6E
		bsr.w	sub_106E
		rts
; ===========================================================================

loc_C64:				; XREF: off_B6E
		cmpi.b	#$10,($FFFFF600).w ; is	game mode = $10	(special stage)	?
		beq.w	loc_DA6		; if yes, branch

loc_C6E:				; XREF: off_B6E
		bsr.w	ReadJoypads
		tst.b	($FFFFF64E).w
		bne.s	loc_CB0
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		bra.s	loc_CD4
; ===========================================================================

loc_CB0:				; XREF: loc_C76
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)

loc_CD4:				; XREF: loc_C76
		move.w	($FFFFF624).w,(a5)
		lea	($C00004).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96E69500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		tst.b	($FFFFF767).w
		beq.s	loc_D50
		lea	($C00004).l,a5
		move.l	#$94019370,(a5)
		move.l	#$96E49500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7000,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		move.b	#0,($FFFFF767).w

loc_D50:
		movem.l	($FFFFF700).w,d0-d7
		movem.l	d0-d7,($FFFFFF10).w
		movem.l	($FFFFF754).w,d0-d1
		movem.l	d0-d1,($FFFFFF30).w
		cmpi.b	#$60,($FFFFF625).w
		bcc.s	Demo_Time
		move.b	#1,($FFFFF64F).w
		addq.l	#4,sp
		bra.w	loc_B64

; ---------------------------------------------------------------------------
; Subroutine to	run a demo for an amount of time
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Demo_Time:				; XREF: loc_D50; PalToCRAM
		bsr.w	LoadTilesAsYouMove
		jsr	AniArt_Load
		jsr	HudUpdate
		bsr.w	sub_165E
		tst.w	($FFFFF614).w	; is there time	left on	the demo?
		beq.w	Demo_TimeEnd	; if not, branch
		subq.w	#1,($FFFFF614).w ; subtract 1 from time	left

Demo_TimeEnd:
		rts
; End of function Demo_Time

; ===========================================================================

loc_DA6:				; XREF: off_B6E
		bsr.w	ReadJoypads
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96E69500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		bsr.w	PalCycle_SS
		tst.b	($FFFFF767).w
		beq.s	loc_E64
		lea	($C00004).l,a5
		move.l	#$94019370,(a5)
		move.l	#$96E49500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7000,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		move.b	#0,($FFFFF767).w

loc_E64:
		tst.w	($FFFFF614).w
		beq.w	locret_E70
		subq.w	#1,($FFFFF614).w

locret_E70:
		rts
; ===========================================================================

loc_E72:				; XREF: off_B6E
		bsr.w	ReadJoypads
		tst.b	($FFFFF64E).w
		bne.s	loc_EB4
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		bra.s	loc_ED8
; ===========================================================================

loc_EB4:				; XREF: loc_E7A
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)

loc_ED8:				; XREF: loc_E7A
		move.w	($FFFFF624).w,(a5)
		lea	($C00004).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96E69500,(a5)

loc_EEE:
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		tst.b	($FFFFF767).w
		beq.s	loc_F54
		lea	($C00004).l,a5
		move.l	#$94019370,(a5)
		move.l	#$96E49500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7000,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		move.b	#0,($FFFFF767).w

loc_F54:
		movem.l	($FFFFF700).w,d0-d7
		movem.l	d0-d7,($FFFFFF10).w
		movem.l	($FFFFF754).w,d0-d1
		movem.l	d0-d1,($FFFFFF30).w
		bsr.w	LoadTilesAsYouMove
		jsr	AniArt_Load
		jsr	HudUpdate
		bsr.w	sub_1642
		rts
; ===========================================================================

loc_F8A:				; XREF: off_B6E
		bsr.w	sub_106E
		addq.b	#1,($FFFFF628).w
		move.b	#$E,($FFFFF62A).w
		rts
; ===========================================================================

loc_F9A:				; XREF: off_B6E
		bsr.w	sub_106E
		move.w	($FFFFF624).w,(a5)
		bra.w	sub_1642
; ===========================================================================

loc_FA6:				; XREF: off_B6E
		bsr.w	ReadJoypads
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96E69500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		tst.b	($FFFFF767).w
		beq.s	loc_1060
		lea	($C00004).l,a5
		move.l	#$94019370,(a5)
		move.l	#$96E49500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7000,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		move.b	#0,($FFFFF767).w

loc_1060:
		tst.w	($FFFFF614).w
		beq.w	locret_106C
		subq.w	#1,($FFFFF614).w

locret_106C:
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_106E:				; XREF: loc_C32; et al
		bsr.w	ReadJoypads
		tst.b	($FFFFF64E).w
		bne.s	loc_10B0
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		bra.s	loc_10D4
; ===========================================================================

loc_10B0:				; XREF: sub_106E
		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)

loc_10D4:				; XREF: sub_106E
		lea	($C00004).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		lea	($C00004).l,a5
		move.l	#$940193C0,(a5)
		move.l	#$96E69500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		rts
; End of function sub_106E

; ---------------------------------------------------------------------------
; Subroutine to	move pallets from the RAM to CRAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalToCRAM:
		move	#$2700,sr
		tst.w	($FFFFF644).w
		beq.s	locret_119C
		move.w	#0,($FFFFF644).w
		movem.l	a0-a1,-(sp)
		lea	($C00000).l,a1
		lea	($FFFFFA80).w,a0 ; load	pallet from RAM
		move.l	#$C0000000,4(a1) ; set VDP to CRAM write
		move.l	(a0)+,(a1)	; move pallet to CRAM
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.w	#$8ADF,4(a1)
		movem.l	(sp)+,a0-a1
		tst.b	($FFFFF64F).w
		bne.s	loc_119E

locret_119C:
		rte
; ===========================================================================

loc_119E:				; XREF: PalToCRAM
		clr.b	($FFFFF64F).w
		movem.l	d0-a6,-(sp)
		bsr.w	Demo_Time
		jsr	UpdateAMPS
		movem.l	(sp)+,d0-a6
		rte
; End of function PalToCRAM

; ---------------------------------------------------------------------------
; Subroutine to	initialise joypads
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


JoypadInit:				; XREF: GameClrRAM
		moveq	#$40,d0
		move.b	d0,($A10009).l	; init port 1 (joypad 1)
		move.b	d0,($A1000B).l	; init port 2 (joypad 2)
		move.b	d0,($A1000D).l	; init port 3 (extra)
		rts
; End of function JoypadInit

; ---------------------------------------------------------------------------
; Subroutine to	read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ReadJoypads:
		lea	($FFFFF604).w,a0 ; address where joypad	states are written
		lea	($A10003).l,a1	; first	joypad port
		bsr.s	Joypad_Read	; do the first joypad
		addq.w	#2,a1		; do the second	joypad

Joypad_Read:
		move.b	#0,(a1)
		nop
		nop
		move.b	(a1),d0
		lsl.b	#2,d0
		andi.b	#$C0,d0
		move.b	#$40,(a1)
		nop
		nop
		move.b	(a1),d1
		andi.b	#$3F,d1
		or.b	d1,d0
		not.b	d0
		move.b	(a0),d1
		eor.b	d0,d1
		move.b	d0,(a0)+
		and.b	d0,d1
		move.b	d1,(a0)+
		rts
; End of function ReadJoypads


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


VDPSetupGame:				; XREF: GameClrRAM; ChecksumError
		lea	($C00004).l,a0
		lea	($C00000).l,a1
		lea	(VDPSetupArray).l,a2
		moveq	#$12,d7

VDP_Loop:
		move.w	(a2)+,(a0)
		dbf	d7,VDP_Loop	; set the VDP registers

		move.w	(VDPSetupArray+2).l,d0
		move.w	d0,($FFFFF60C).w
		move.w	#$8ADF,($FFFFF624).w
		moveq	#0,d0
		move.l	#$C0000000,($C00004).l ; set VDP to CRAM write
		move.w	#$3F,d7

VDP_ClrCRAM:
		move.w	d0,(a1)
		dbf	d7,VDP_ClrCRAM	; clear	the CRAM

		clr.l	($FFFFF616).w
		clr.l	($FFFFF61A).w
		move.l	d1,-(sp)
		lea	($C00004).l,a5
		move.w	#$8F01,(a5)
		move.l	#$94FF93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000080,(a5)
		move.w	#0,($C00000).l	; clear	the screen

loc_128E:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_128E

		move.w	#$8F02,(a5)
		move.l	(sp)+,d1
		rts
; End of function VDPSetupGame

; ===========================================================================
VDPSetupArray:	dc.w $8004, $8134, $8230, $8328	; XREF: VDPSetupGame
		dc.w $8407, $857C, $8600, $8700
		dc.w $8800, $8900, $8A00, $8B00
		dc.w $8C81, $8D3F, $8E00, $8F02
		dc.w $9001, $9100, $9200

; ---------------------------------------------------------------------------
; Subroutine to	clear the screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ClearScreen:
		lea	($C00004).l,a5
		move.w	#$8F01,(a5)
		move.l	#$940F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000083,(a5)
		move.w	#0,($C00000).l

loc_12E6:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_12E6

		move.w	#$8F02,(a5)
		lea	($C00004).l,a5
		move.w	#$8F01,(a5)
		move.l	#$940F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$60000083,(a5)
		move.w	#0,($C00000).l

loc_1314:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_1314

		move.w	#$8F02,(a5)
		move.l	#0,($FFFFF616).w
		move.l	#0,($FFFFF61A).w
		lea	($FFFFF800).w,a1
		moveq	#0,d0
		move.w	#$A0,d1

loc_133A:
		move.l	d0,(a1)+
		dbf	d1,loc_133A

		lea	($FFFFCC00).w,a1
		moveq	#0,d0
		move.w	#$100,d1

loc_134A:
		move.l	d0,(a1)+
		dbf	d1,loc_134A
		rts
; End of function ClearScreen

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	play a music track
; ---------------------------------------------------------------------------

PlaySound:
		move.b	d0,mQueue.w
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	play a sound effect
; ---------------------------------------------------------------------------

PlaySound_Special:
		move.b	d0,mQueue+1.w
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	play a sound effect or a command
; ---------------------------------------------------------------------------

PlaySound_Special2:
		move.b	d0,mQueue+2.w
		rts

; ---------------------------------------------------------------------------
; Subroutine to	pause the game
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PauseGame:				; XREF: Level_MainLoop; et al
		nop
		tst.b	($FFFFFE12).w	; do you have any lives	left?
		beq.s	Unpause		; if not, branch
		tst.w	($FFFFF63A).w	; is game already paused?
		bne.s	loc_13BE	; if yes, branch
		btst	#7,($FFFFF605).w ; is Start button pressed?
		beq.s	Pause_DoNothing	; if not, branch

loc_13BE:
		move.w	#1,($FFFFF63A).w ; freeze time
	AMPS_MUSPAUSE			; pause music

loc_13CA:
		move.b	#$10,($FFFFF62A).w
		bsr.w	DelayProgram
		tst.b	($FFFFFFE1).w	; is slow-motion cheat on?
		beq.s	Pause_ChkStart	; if not, branch
		btst	#6,($FFFFF605).w ; is button A pressed?
		beq.s	Pause_ChkBC	; if not, branch
		move.b	#4,($FFFFF600).w ; set game mode to 4 (title screen)
		nop
		bra.s	loc_1404
; ===========================================================================

Pause_ChkBC:				; XREF: PauseGame
		btst	#4,($FFFFF604).w ; is button B pressed?
		bne.s	Pause_SlowMo	; if yes, branch
		btst	#5,($FFFFF605).w ; is button C pressed?
		bne.s	Pause_SlowMo	; if yes, branch

Pause_ChkStart:				; XREF: PauseGame
		btst	#7,($FFFFF605).w ; is Start button pressed?
		beq.s	loc_13CA	; if not, branch

loc_1404:				; XREF: PauseGame
	AMPS_MUSUNPAUSE			; unpause music

Unpause:				; XREF: PauseGame
		move.w	#0,($FFFFF63A).w ; unpause the game

Pause_DoNothing:			; XREF: PauseGame
		rts
; ===========================================================================

Pause_SlowMo:				; XREF: PauseGame
		move.w	#1,($FFFFF63A).w
	AMPS_MUSUNPAUSE			; unpause music
		rts
; End of function PauseGame

; ---------------------------------------------------------------------------
; Subroutine to	display	patterns via the VDP
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ShowVDPGraphics:			; XREF: SegaScreen; TitleScreen; SS_BGLoad
		lea	($C00000).l,a6
		move.l	#$800000,d4

loc_142C:
		move.l	d0,4(a6)
		move.w	d1,d3

loc_1432:
		move.w	(a1)+,(a6)
		dbf	d3,loc_1432
		add.l	d4,d0
		dbf	d2,loc_142C
		rts
; End of function ShowVDPGraphics

; ---------------------------------------------------------------------------
; Nemesis decompression	algorithm
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


NemDec:
		movem.l	d0-a1/a3-a5,-(sp)
		lea	(loc_1502).l,a3
		lea	($C00000).l,a4
		bra.s	loc_145C
; ===========================================================================
		movem.l	d0-a1/a3-a5,-(sp)
		lea	(loc_1518).l,a3

loc_145C:				; XREF: NemDec
		lea	($FFFFAA00).w,a1
		move.w	(a0)+,d2
		lsl.w	#1,d2
		bcc.s	loc_146A
		adda.w	#$A,a3

loc_146A:
		lsl.w	#2,d2
		movea.w	d2,a5
		moveq	#8,d3
		moveq	#0,d2
		moveq	#0,d4
		bsr.w	NemDec4
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		move.w	#$10,d6
		bsr.s	NemDec2
		movem.l	(sp)+,d0-a1/a3-a5
		rts
; End of function NemDec


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


NemDec2:				; XREF: NemDec
		move.w	d6,d7
		subq.w	#8,d7
		move.w	d5,d1
		lsr.w	d7,d1
		cmpi.b	#-4,d1
		bcc.s	loc_14D6
		andi.w	#$FF,d1
		add.w	d1,d1
		move.b	(a1,d1.w),d0
		ext.w	d0
		sub.w	d0,d6
		cmpi.w	#9,d6
		bcc.s	loc_14B2
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5

loc_14B2:
		move.b	1(a1,d1.w),d1
		move.w	d1,d0
		andi.w	#$F,d1
		andi.w	#$F0,d0

loc_14C0:				; XREF: NemDec3
		lsr.w	#4,d0

loc_14C2:				; XREF: NemDec3
		lsl.l	#4,d4
		or.b	d1,d4
		subq.w	#1,d3
		bne.s	loc_14D0
		jmp	(a3)
; End of function NemDec2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


NemDec3:				; XREF: loc_1502
		moveq	#0,d4
		moveq	#8,d3

loc_14D0:				; XREF: NemDec2
		dbf	d0,loc_14C2
		bra.s	NemDec2
; ===========================================================================

loc_14D6:				; XREF: NemDec2
		subq.w	#6,d6
		cmpi.w	#9,d6
		bcc.s	loc_14E4
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5

loc_14E4:				; XREF: NemDec3
		subq.w	#7,d6
		move.w	d5,d1
		lsr.w	d6,d1
		move.w	d1,d0
		andi.w	#$F,d1
		andi.w	#$70,d0
		cmpi.w	#9,d6
		bcc.s	loc_14C0
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5
		bra.s	loc_14C0
; End of function NemDec3

; ===========================================================================

loc_1502:				; XREF: NemDec
		move.l	d4,(a4)
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	NemDec3
		rts
; ===========================================================================
		eor.l	d4,d2
		move.l	d2,(a4)
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	NemDec3
		rts
; ===========================================================================

loc_1518:				; XREF: NemDec
		move.l	d4,(a4)+
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	NemDec3
		rts
; ===========================================================================
		eor.l	d4,d2
		move.l	d2,(a4)+
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	NemDec3
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


NemDec4:				; XREF: NemDec
		move.b	(a0)+,d0

loc_1530:
		cmpi.b	#-1,d0
		bne.s	loc_1538
		rts
; ===========================================================================

loc_1538:				; XREF: NemDec4
		move.w	d0,d7

loc_153A:
		move.b	(a0)+,d0
		cmpi.b	#$80,d0
		bcc.s	loc_1530
		move.b	d0,d1
		andi.w	#$F,d7
		andi.w	#$70,d1
		or.w	d1,d7
		andi.w	#$F,d0
		move.b	d0,d1
		lsl.w	#8,d1
		or.w	d1,d7
		moveq	#8,d1
		sub.w	d0,d1
		bne.s	loc_1568
		move.b	(a0)+,d0
		add.w	d0,d0
		move.w	d7,(a1,d0.w)
		bra.s	loc_153A
; ===========================================================================

loc_1568:				; XREF: NemDec4
		move.b	(a0)+,d0
		lsl.w	d1,d0
		add.w	d0,d0
		moveq	#1,d5
		lsl.w	d1,d5
		subq.w	#1,d5

loc_1574:
		move.w	d7,(a1,d0.w)
		addq.w	#2,d0
		dbf	d5,loc_1574
		bra.s	loc_153A
; End of function NemDec4

; ---------------------------------------------------------------------------
; Subroutine to	load pattern load cues
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadPLC:
		movem.l	a1-a2,-(sp)
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		lea	($FFFFF680).w,a2

loc_1598:
		tst.l	(a2)
		beq.s	loc_15A0
		addq.w	#6,a2
		bra.s	loc_1598
; ===========================================================================

loc_15A0:				; XREF: LoadPLC
		move.w	(a1)+,d0
		bmi.s	loc_15AC

loc_15A4:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		dbf	d0,loc_15A4

loc_15AC:
		movem.l	(sp)+,a1-a2
		rts
; End of function LoadPLC


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadPLC2:
		movem.l	a1-a2,-(sp)
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		bsr.s	ClearPLC
		lea	($FFFFF680).w,a2
		move.w	(a1)+,d0
		bmi.s	loc_15D8

loc_15D0:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		dbf	d0,loc_15D0

loc_15D8:
		movem.l	(sp)+,a1-a2
		rts
; End of function LoadPLC2

; ---------------------------------------------------------------------------
; Subroutine to	clear the pattern load cues
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ClearPLC:				; XREF: LoadPLC2
		lea	($FFFFF680).w,a2
		moveq	#$1F,d0

ClearPLC_Loop:
		clr.l	(a2)+
		dbf	d0,ClearPLC_Loop
		rts
; End of function ClearPLC

; ---------------------------------------------------------------------------
; Subroutine to	use graphics listed in a pattern load cue
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


RunPLC_RAM:				; XREF: Pal_FadeTo
		tst.l	($FFFFF680).w
		beq.s	locret_1640
		tst.w	($FFFFF6F8).w
		bne.s	locret_1640
		movea.l	($FFFFF680).w,a0
		lea	(loc_1502).l,a3
		lea	($FFFFAA00).w,a1
		move.w	(a0)+,d2
		bpl.s	loc_160E
		adda.w	#$A,a3

loc_160E:
		andi.w	#$7FFF,d2
		move.w	d2,($FFFFF6F8).w
		bsr.w	NemDec4
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6
		moveq	#0,d0
		move.l	a0,($FFFFF680).w
		move.l	a3,($FFFFF6E0).w
		move.l	d0,($FFFFF6E4).w
		move.l	d0,($FFFFF6E8).w
		move.l	d0,($FFFFF6EC).w
		move.l	d5,($FFFFF6F0).w
		move.l	d6,($FFFFF6F4).w

locret_1640:
		rts
; End of function RunPLC_RAM


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_1642:				; XREF: loc_C44; loc_F54; loc_F9A
		tst.w	($FFFFF6F8).w
		beq.w	locret_16DA
		move.w	#9,($FFFFF6FA).w
		moveq	#0,d0
		move.w	($FFFFF684).w,d0
		addi.w	#$120,($FFFFF684).w
		bra.s	loc_1676
; End of function sub_1642


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_165E:				; XREF: Demo_Time
		tst.w	($FFFFF6F8).w
		beq.s	locret_16DA
		move.w	#3,($FFFFF6FA).w
		moveq	#0,d0
		move.w	($FFFFF684).w,d0
		addi.w	#$60,($FFFFF684).w

loc_1676:				; XREF: sub_1642
		lea	($C00004).l,a4
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,(a4)
		subq.w	#4,a4
		movea.l	($FFFFF680).w,a0
		movea.l	($FFFFF6E0).w,a3
		move.l	($FFFFF6E4).w,d0
		move.l	($FFFFF6E8).w,d1
		move.l	($FFFFF6EC).w,d2
		move.l	($FFFFF6F0).w,d5
		move.l	($FFFFF6F4).w,d6
		lea	($FFFFAA00).w,a1

loc_16AA:				; XREF: sub_165E
		movea.w	#8,a5
		bsr.w	NemDec3
		subq.w	#1,($FFFFF6F8).w
		beq.s	loc_16DC
		subq.w	#1,($FFFFF6FA).w
		bne.s	loc_16AA
		move.l	a0,($FFFFF680).w
		move.l	a3,($FFFFF6E0).w
		move.l	d0,($FFFFF6E4).w
		move.l	d1,($FFFFF6E8).w
		move.l	d2,($FFFFF6EC).w
		move.l	d5,($FFFFF6F0).w
		move.l	d6,($FFFFF6F4).w

locret_16DA:				; XREF: sub_1642
		rts
; ===========================================================================

loc_16DC:				; XREF: sub_165E
		lea	($FFFFF680).w,a0
		moveq	#$15,d0

loc_16E2:				; XREF: sub_165E
		move.l	6(a0),(a0)+
		dbf	d0,loc_16E2
		rts
; End of function sub_165E

; ---------------------------------------------------------------------------
; Subroutine to	execute	the pattern load cue
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


RunPLC_ROM:
		lea	(ArtLoadCues).l,a1 ; load the PLC index
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		move.w	(a1)+,d1	; load number of entries in the	PLC

RunPLC_Loop:
		movea.l	(a1)+,a0	; get art pointer
		moveq	#0,d0
		move.w	(a1)+,d0	; get VRAM address
		lsl.l	#2,d0		; divide address by $20
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,($C00004).l	; put the VRAM address into VDP
		bsr.w	NemDec		; decompress
		dbf	d1,RunPLC_Loop	; loop for number of entries
		rts
; End of function RunPLC_ROM

; ---------------------------------------------------------------------------
; Enigma decompression algorithm
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


EniDec:
		movem.l	d0-d7/a1-a5,-(sp)
		movea.w	d0,a3
		move.b	(a0)+,d0
		ext.w	d0
		movea.w	d0,a5
		move.b	(a0)+,d4
		lsl.b	#3,d4
		movea.w	(a0)+,a2
		adda.w	a3,a2
		movea.w	(a0)+,a4
		adda.w	a3,a4
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6

loc_173E:				; XREF: loc_1768
		moveq	#7,d0
		move.w	d6,d7
		sub.w	d0,d7
		move.w	d5,d1
		lsr.w	d7,d1
		andi.w	#$7F,d1
		move.w	d1,d2
		cmpi.w	#$40,d1
		bcc.s	loc_1758
		moveq	#6,d0
		lsr.w	#1,d2

loc_1758:
		bsr.w	sub_188C
		andi.w	#$F,d2
		lsr.w	#4,d1
		add.w	d1,d1
		jmp	loc_17B4(pc,d1.w)
; End of function EniDec

; ===========================================================================

loc_1768:				; XREF: loc_17B4
		move.w	a2,(a1)+
		addq.w	#1,a2
		dbf	d2,loc_1768
		bra.s	loc_173E
; ===========================================================================

loc_1772:				; XREF: loc_17B4
		move.w	a4,(a1)+
		dbf	d2,loc_1772
		bra.s	loc_173E
; ===========================================================================

loc_177A:				; XREF: loc_17B4
		bsr.w	loc_17DC

loc_177E:
		move.w	d1,(a1)+
		dbf	d2,loc_177E
		bra.s	loc_173E
; ===========================================================================

loc_1786:				; XREF: loc_17B4
		bsr.w	loc_17DC

loc_178A:
		move.w	d1,(a1)+
		addq.w	#1,d1
		dbf	d2,loc_178A
		bra.s	loc_173E
; ===========================================================================

loc_1794:				; XREF: loc_17B4
		bsr.w	loc_17DC

loc_1798:
		move.w	d1,(a1)+
		subq.w	#1,d1
		dbf	d2,loc_1798
		bra.s	loc_173E
; ===========================================================================

loc_17A2:				; XREF: loc_17B4
		cmpi.w	#$F,d2
		beq.s	loc_17C4

loc_17A8:
		bsr.w	loc_17DC
		move.w	d1,(a1)+
		dbf	d2,loc_17A8
		bra.s	loc_173E
; ===========================================================================

loc_17B4:				; XREF: EniDec
		bra.s	loc_1768
; ===========================================================================
		bra.s	loc_1768
; ===========================================================================
		bra.s	loc_1772
; ===========================================================================
		bra.s	loc_1772
; ===========================================================================
		bra.s	loc_177A
; ===========================================================================
		bra.s	loc_1786
; ===========================================================================
		bra.s	loc_1794
; ===========================================================================
		bra.s	loc_17A2
; ===========================================================================

loc_17C4:				; XREF: loc_17A2
		subq.w	#1,a0
		cmpi.w	#$10,d6
		bne.s	loc_17CE
		subq.w	#1,a0

loc_17CE:
		move.w	a0,d0
		lsr.w	#1,d0
		bcc.s	loc_17D6
		addq.w	#1,a0

loc_17D6:
		movem.l	(sp)+,d0-d7/a1-a5
		rts
; ===========================================================================

loc_17DC:				; XREF: loc_17A2
		move.w	a3,d3
		move.b	d4,d1
		add.b	d1,d1
		bcc.s	loc_17EE
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_17EE
		ori.w	#-$8000,d3

loc_17EE:
		add.b	d1,d1
		bcc.s	loc_17FC
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_17FC
		addi.w	#$4000,d3

loc_17FC:
		add.b	d1,d1
		bcc.s	loc_180A
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_180A
		addi.w	#$2000,d3

loc_180A:
		add.b	d1,d1
		bcc.s	loc_1818
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_1818
		ori.w	#$1000,d3

loc_1818:
		add.b	d1,d1
		bcc.s	loc_1826
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_1826
		ori.w	#$800,d3

loc_1826:
		move.w	d5,d1
		move.w	d6,d7
		sub.w	a5,d7
		bcc.s	loc_1856
		move.w	d7,d6
		addi.w	#$10,d6
		neg.w	d7
		lsl.w	d7,d1
		move.b	(a0),d5
		rol.b	d7,d5
		add.w	d7,d7
		and.w	word_186C-2(pc,d7.w),d5
		add.w	d5,d1

loc_1844:				; XREF: loc_1868
		move.w	a5,d0
		add.w	d0,d0
		and.w	word_186C-2(pc,d0.w),d1
		add.w	d3,d1
		move.b	(a0)+,d5
		lsl.w	#8,d5
		move.b	(a0)+,d5
		rts
; ===========================================================================

loc_1856:				; XREF: loc_1826
		beq.s	loc_1868
		lsr.w	d7,d1
		move.w	a5,d0
		add.w	d0,d0
		and.w	word_186C-2(pc,d0.w),d1
		add.w	d3,d1
		move.w	a5,d0
		bra.s	sub_188C
; ===========================================================================

loc_1868:				; XREF: loc_1856
		moveq	#$10,d6

loc_186A:
		bra.s	loc_1844
; ===========================================================================
word_186C:	dc.w 1,	3, 7, $F, $1F, $3F, $7F, $FF, $1FF, $3FF, $7FF
		dc.w $FFF, $1FFF, $3FFF, $7FFF,	$FFFF	; XREF: loc_1856

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_188C:				; XREF: EniDec
		sub.w	d0,d6
		cmpi.w	#9,d6
		bcc.s	locret_189A
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5

locret_189A:
		rts
; End of function sub_188C

; ---------------------------------------------------------------------------
; Kosinski decompression algorithm
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


KosDec:

var_2		= -2
var_1		= -1

		subq.l	#2,sp
		move.b	(a0)+,2+var_1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4

loc_18A8:
		lsr.w	#1,d5
		move	sr,d6
		dbf	d4,loc_18BA
		move.b	(a0)+,2+var_1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4

loc_18BA:
		move	d6,ccr
		bcc.s	loc_18C2
		move.b	(a0)+,(a1)+
		bra.s	loc_18A8
; ===========================================================================

loc_18C2:				; XREF: KosDec
		moveq	#0,d3
		lsr.w	#1,d5
		move	sr,d6
		dbf	d4,loc_18D6
		move.b	(a0)+,2+var_1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4

loc_18D6:
		move	d6,ccr
		bcs.s	loc_1906
		lsr.w	#1,d5
		dbf	d4,loc_18EA
		move.b	(a0)+,2+var_1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4

loc_18EA:
		roxl.w	#1,d3
		lsr.w	#1,d5
		dbf	d4,loc_18FC
		move.b	(a0)+,2+var_1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4

loc_18FC:
		roxl.w	#1,d3
		addq.w	#1,d3
		moveq	#-1,d2
		move.b	(a0)+,d2
		bra.s	loc_191C
; ===========================================================================

loc_1906:				; XREF: loc_18C2
		move.b	(a0)+,d0
		move.b	(a0)+,d1
		moveq	#-1,d2
		move.b	d1,d2
		lsl.w	#5,d2
		move.b	d0,d2
		andi.w	#7,d1
		beq.s	loc_1928
		move.b	d1,d3
		addq.w	#1,d3

loc_191C:
		move.b	(a1,d2.w),d0
		move.b	d0,(a1)+
		dbf	d3,loc_191C
		bra.s	loc_18A8
; ===========================================================================

loc_1928:				; XREF: loc_1906
		move.b	(a0)+,d1
		beq.s	loc_1938
		cmpi.b	#1,d1
		beq.w	loc_18A8
		move.b	d1,d3
		bra.s	loc_191C
; ===========================================================================

loc_1938:				; XREF: loc_1928
		addq.l	#2,sp
		rts
; End of function KosDec

; ---------------------------------------------------------------------------
; Pallet cycling routine loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_Load:				; XREF: Demo; Level_MainLoop; End_MainLoop
		moveq	#0,d2
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0 ; get level number
		add.w	d0,d0		; multiply by 2
		move.w	PalCycle(pc,d0.w),d0 ; load animated pallets offset index into d0
		jmp	PalCycle(pc,d0.w) ; jump to PalCycle + offset index
; End of function PalCycle_Load

; ===========================================================================
; ---------------------------------------------------------------------------
; Pallet cycling routines
; ---------------------------------------------------------------------------
PalCycle:	dc.w PalCycle_GHZ-PalCycle
		dc.w PalCycle_LZ-PalCycle
		dc.w PalCycle_MZ-PalCycle
		dc.w PalCycle_SLZ-PalCycle
		dc.w PalCycle_SYZ-PalCycle
		dc.w PalCycle_SBZ-PalCycle
		dc.w PalCycle_GHZ-PalCycle

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_Title:				; XREF: TitleScreen
		lea	(Pal_TitleCyc).l,a0
		bra.s	loc_196A
; ===========================================================================

PalCycle_GHZ:				; XREF: PalCycle
		lea	(Pal_GHZCyc).l,a0

loc_196A:				; XREF: PalCycle_Title
		subq.w	#1,($FFFFF634).w
		bpl.s	locret_1990
		move.w	#5,($FFFFF634).w
		move.w	($FFFFF632).w,d0
		addq.w	#1,($FFFFF632).w
		andi.w	#3,d0
		lsl.w	#3,d0
		lea	($FFFFFB50).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)

locret_1990:
		rts
; End of function PalCycle_Title


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_LZ:				; XREF: PalCycle
		subq.w	#1,($FFFFF634).w
		bpl.s	loc_19D8
		move.w	#2,($FFFFF634).w
		move.w	($FFFFF632).w,d0
		addq.w	#1,($FFFFF632).w
		andi.w	#3,d0
		lsl.w	#3,d0
		lea	(Pal_LZCyc1).l,a0
		cmpi.b	#3,($FFFFFE11).w ; check if level is SBZ3
		bne.s	loc_19C0
		lea	(Pal_SBZ3Cyc1).l,a0 ; load SBZ3	pallet instead

loc_19C0:
		lea	($FFFFFB56).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)
		lea	($FFFFFAD6).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)

loc_19D8:
		move.w	($FFFFFE04).w,d0
		andi.w	#7,d0
		move.b	byte_1A3C(pc,d0.w),d0
		beq.s	locret_1A3A
		moveq	#1,d1
		tst.b	($FFFFF7C0).w
		beq.s	loc_19F0
		neg.w	d1

loc_19F0:
		move.w	($FFFFF650).w,d0
		andi.w	#3,d0
		add.w	d1,d0
		cmpi.w	#3,d0
		bcs.s	loc_1A0A
		move.w	d0,d1
		moveq	#0,d0
		tst.w	d1
		bpl.s	loc_1A0A
		moveq	#2,d0

loc_1A0A:
		move.w	d0,($FFFFF650).w
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	(Pal_LZCyc2).l,a0
		lea	($FFFFFB76).w,a1
		move.l	(a0,d0.w),(a1)+
		move.w	4(a0,d0.w),(a1)
		lea	(Pal_LZCyc3).l,a0
		lea	($FFFFFAF6).w,a1
		move.l	(a0,d0.w),(a1)+
		move.w	4(a0,d0.w),(a1)

locret_1A3A:
		rts
; End of function PalCycle_LZ

; ===========================================================================
byte_1A3C:	dc.b 1,	0, 0, 1, 0, 0, 1, 0
; ===========================================================================

PalCycle_MZ:				; XREF: PalCycle
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_SLZ:				; XREF: PalCycle
		subq.w	#1,($FFFFF634).w
		bpl.s	locret_1A80
		move.w	#7,($FFFFF634).w
		move.w	($FFFFF632).w,d0
		addq.w	#1,d0
		cmpi.w	#6,d0
		bcs.s	loc_1A60
		moveq	#0,d0

loc_1A60:
		move.w	d0,($FFFFF632).w
		move.w	d0,d1
		add.w	d1,d1
		add.w	d1,d0
		add.w	d0,d0
		lea	(Pal_SLZCyc).l,a0
		lea	($FFFFFB56).w,a1
		move.w	(a0,d0.w),(a1)
		move.l	2(a0,d0.w),4(a1)

locret_1A80:
		rts
; End of function PalCycle_SLZ


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_SYZ:				; XREF: PalCycle
		subq.w	#1,($FFFFF634).w
		bpl.s	locret_1AC6
		move.w	#5,($FFFFF634).w
		move.w	($FFFFF632).w,d0
		addq.w	#1,($FFFFF632).w
		andi.w	#3,d0
		lsl.w	#2,d0
		move.w	d0,d1
		add.w	d0,d0
		lea	(Pal_SYZCyc1).l,a0
		lea	($FFFFFB6E).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)
		lea	(Pal_SYZCyc2).l,a0
		lea	($FFFFFB76).w,a1
		move.w	(a0,d1.w),(a1)
		move.w	2(a0,d1.w),4(a1)

locret_1AC6:
		rts
; End of function PalCycle_SYZ


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_SBZ:				; XREF: PalCycle
		lea	(Pal_SBZCycList).l,a2
		tst.b	($FFFFFE11).w
		beq.s	loc_1ADA
		lea	(Pal_SBZCycList2).l,a2

loc_1ADA:
		lea	($FFFFF650).w,a1
		move.w	(a2)+,d1

loc_1AE0:
		subq.b	#1,(a1)
		bmi.s	loc_1AEA
		addq.l	#2,a1
		addq.l	#6,a2
		bra.s	loc_1B06
; ===========================================================================

loc_1AEA:				; XREF: PalCycle_SBZ
		move.b	(a2)+,(a1)+
		move.b	(a1),d0
		addq.b	#1,d0
		cmp.b	(a2)+,d0
		bcs.s	loc_1AF6
		moveq	#0,d0

loc_1AF6:
		move.b	d0,(a1)+
		andi.w	#$F,d0
		add.w	d0,d0
		movea.w	(a2)+,a0
		movea.w	(a2)+,a3
		move.w	(a0,d0.w),(a3)

loc_1B06:				; XREF: PalCycle_SBZ
		dbf	d1,loc_1AE0
		subq.w	#1,($FFFFF634).w
		bpl.s	locret_1B64
		lea	(Pal_SBZCyc4).l,a0
		move.w	#1,($FFFFF634).w
		tst.b	($FFFFFE11).w
		beq.s	loc_1B2E
		lea	(Pal_SBZCyc10).l,a0
		move.w	#0,($FFFFF634).w

loc_1B2E:
		moveq	#-1,d1
		tst.b	($FFFFF7C0).w
		beq.s	loc_1B38
		neg.w	d1

loc_1B38:
		move.w	($FFFFF632).w,d0
		andi.w	#3,d0
		add.w	d1,d0
		cmpi.w	#3,d0
		bcs.s	loc_1B52
		move.w	d0,d1
		moveq	#0,d0
		tst.w	d1
		bpl.s	loc_1B52
		moveq	#2,d0

loc_1B52:
		move.w	d0,($FFFFF632).w
		add.w	d0,d0
		lea	($FFFFFB58).w,a1
		move.l	(a0,d0.w),(a1)+
		move.w	4(a0,d0.w),(a1)

locret_1B64:
		rts
; End of function PalCycle_SBZ

; ===========================================================================
Pal_TitleCyc:	incbin	pallet\c_title.bin
Pal_GHZCyc:	incbin	pallet\c_ghz.bin
Pal_LZCyc1:	incbin	pallet\c_lz_wat.bin	; waterfalls pallet
Pal_LZCyc2:	incbin	pallet\c_lz_bel.bin	; conveyor belt pallet
Pal_LZCyc3:	incbin	pallet\c_lz_buw.bin	; conveyor belt (underwater) pallet
Pal_SBZ3Cyc1:	incbin	pallet\c_sbz3_w.bin	; waterfalls pallet
Pal_SLZCyc:	incbin	pallet\c_slz.bin
Pal_SYZCyc1:	incbin	pallet\c_syz_1.bin
Pal_SYZCyc2:	incbin	pallet\c_syz_2.bin

Pal_SBZCycList:
	include "_inc\SBZ pallet script 1.asm"

Pal_SBZCycList2:
	include "_inc\SBZ pallet script 2.asm"

Pal_SBZCyc1:	incbin	pallet\c_sbz_1.bin
Pal_SBZCyc2:	incbin	pallet\c_sbz_2.bin
Pal_SBZCyc3:	incbin	pallet\c_sbz_3.bin
Pal_SBZCyc4:	incbin	pallet\c_sbz_4.bin
Pal_SBZCyc5:	incbin	pallet\c_sbz_5.bin
Pal_SBZCyc6:	incbin	pallet\c_sbz_6.bin
Pal_SBZCyc7:	incbin	pallet\c_sbz_7.bin
Pal_SBZCyc8:	incbin	pallet\c_sbz_8.bin
Pal_SBZCyc9:	incbin	pallet\c_sbz_9.bin
Pal_SBZCyc10:	incbin	pallet\c_sbz_10.bin
; ---------------------------------------------------------------------------
; Subroutine to	fade out and fade in
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeTo:
		move.w	#$3F,($FFFFF626).w

Pal_FadeTo2:
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		moveq	#0,d1
		move.b	($FFFFF627).w,d0

Pal_ToBlack:
		move.w	d1,(a0)+
		dbf	d0,Pal_ToBlack	; fill pallet with $000	(black)

		move.w	#$15,d4

loc_1DCE:
		move.b	#$12,($FFFFF62A).w
		bsr.w	DelayProgram
		bsr.s	Pal_FadeIn
		bsr.w	RunPLC_RAM
		dbf	d4,loc_1DCE
		rts
; End of function Pal_FadeTo

; ---------------------------------------------------------------------------
; Pallet fade-in subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeIn:				; XREF: Pal_FadeTo
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		lea	($FFFFFB80).w,a1
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	($FFFFF627).w,d0

loc_1DFA:
		bsr.s	Pal_AddColor
		dbf	d0,loc_1DFA
		cmpi.b	#1,($FFFFFE10).w
		bne.s	locret_1E24
		moveq	#0,d0
		lea	($FFFFFA80).w,a0
		lea	($FFFFFA00).w,a1
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	($FFFFF627).w,d0

loc_1E1E:
		bsr.s	Pal_AddColor
		dbf	d0,loc_1E1E

locret_1E24:
		rts
; End of function Pal_FadeIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_AddColor:				; XREF: Pal_FadeIn
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	loc_1E4E
		move.w	d3,d1
		addi.w	#$200,d1	; increase blue	value
		cmp.w	d2,d1		; has blue reached threshold level?
		bhi.s	Pal_AddGreen	; if yes, branch
		move.w	d1,(a0)+	; update pallet
		rts
; ===========================================================================

Pal_AddGreen:				; XREF: Pal_AddColor
		move.w	d3,d1
		addi.w	#$20,d1		; increase green value
		cmp.w	d2,d1
		bhi.s	Pal_AddRed
		move.w	d1,(a0)+	; update pallet
		rts
; ===========================================================================

Pal_AddRed:				; XREF: Pal_AddGreen
		addq.w	#2,(a0)+	; increase red value
		rts
; ===========================================================================

loc_1E4E:				; XREF: Pal_AddColor
		addq.w	#2,a0
		rts
; End of function Pal_AddColor


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeFrom:
		move.w	#$3F,($FFFFF626).w
		move.w	#$15,d4

loc_1E5C:
		move.b	#$12,($FFFFF62A).w
		bsr.w	DelayProgram
		bsr.s	Pal_FadeOut
		bsr.w	RunPLC_RAM
		dbf	d4,loc_1E5C
		rts
; End of function Pal_FadeFrom

; ---------------------------------------------------------------------------
; Pallet fade-out subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeOut:				; XREF: Pal_FadeFrom
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		move.b	($FFFFF627).w,d0

loc_1E82:
		bsr.s	Pal_DecColor
		dbf	d0,loc_1E82

		moveq	#0,d0
		lea	($FFFFFA80).w,a0
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		move.b	($FFFFF627).w,d0

loc_1E98:
		bsr.s	Pal_DecColor
		dbf	d0,loc_1E98
		rts
; End of function Pal_FadeOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_DecColor:				; XREF: Pal_FadeOut
		move.w	(a0),d2
		beq.s	loc_1ECC
		move.w	d2,d1
		andi.w	#$E,d1
		beq.s	Pal_DecGreen
		subq.w	#2,(a0)+	; decrease red value
		rts
; ===========================================================================

Pal_DecGreen:				; XREF: Pal_DecColor
		move.w	d2,d1
		andi.w	#$E0,d1
		beq.s	Pal_DecBlue
		subi.w	#$20,(a0)+	; decrease green value
		rts
; ===========================================================================

Pal_DecBlue:				; XREF: Pal_DecGreen
		move.w	d2,d1
		andi.w	#$E00,d1
		beq.s	loc_1ECC
		subi.w	#$200,(a0)+	; decrease blue	value
		rts
; ===========================================================================

loc_1ECC:				; XREF: Pal_DecColor
		addq.w	#2,a0
		rts
; End of function Pal_DecColor

; ---------------------------------------------------------------------------
; Subroutine to	fill the pallet	with white (special stage)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_MakeWhite:				; XREF: SpecialStage
		move.w	#$3F,($FFFFF626).w
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		move.w	#$EEE,d1
		move.b	($FFFFF627).w,d0

PalWhite_Loop:
		move.w	d1,(a0)+
		dbf	d0,PalWhite_Loop
		move.w	#$15,d4

loc_1EF4:
		move.b	#$12,($FFFFF62A).w
		bsr.w	DelayProgram
		bsr.s	Pal_WhiteToBlack
		bsr.w	RunPLC_RAM
		dbf	d4,loc_1EF4
		rts
; End of function Pal_MakeWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_WhiteToBlack:			; XREF: Pal_MakeWhite
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		lea	($FFFFFB80).w,a1
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	($FFFFF627).w,d0

loc_1F20:
		bsr.s	Pal_DecColor2
		dbf	d0,loc_1F20

		cmpi.b	#1,($FFFFFE10).w
		bne.s	locret_1F4A
		moveq	#0,d0
		lea	($FFFFFA80).w,a0
		lea	($FFFFFA00).w,a1
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	($FFFFF627).w,d0

loc_1F44:
		bsr.s	Pal_DecColor2
		dbf	d0,loc_1F44

locret_1F4A:
		rts
; End of function Pal_WhiteToBlack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_DecColor2:				; XREF: Pal_WhiteToBlack
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	loc_1F78
		move.w	d3,d1
		subi.w	#$200,d1	; decrease blue	value
		bcs.s	loc_1F64
		cmp.w	d2,d1
		bcs.s	loc_1F64
		move.w	d1,(a0)+
		rts
; ===========================================================================

loc_1F64:				; XREF: Pal_DecColor2
		move.w	d3,d1
		subi.w	#$20,d1		; decrease green value
		bcs.s	loc_1F74
		cmp.w	d2,d1
		bcs.s	loc_1F74
		move.w	d1,(a0)+
		rts
; ===========================================================================

loc_1F74:				; XREF: loc_1F64
		subq.w	#2,(a0)+	; decrease red value
		rts
; ===========================================================================

loc_1F78:				; XREF: Pal_DecColor2
		addq.w	#2,a0
		rts
; End of function Pal_DecColor2

; ---------------------------------------------------------------------------
; Subroutine to	make a white flash when	you enter a special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_MakeFlash:				; XREF: SpecialStage
		move.w	#$3F,($FFFFF626).w
		move.w	#$15,d4

loc_1F86:
		move.b	#$12,($FFFFF62A).w
		bsr.w	DelayProgram
		bsr.s	Pal_ToWhite
		bsr.w	RunPLC_RAM
		dbf	d4,loc_1F86
		rts
; End of function Pal_MakeFlash


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_ToWhite:				; XREF: Pal_MakeFlash
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		move.b	($FFFFF627).w,d0

loc_1FAC:
		bsr.s	Pal_AddColor2
		dbf	d0,loc_1FAC
		moveq	#0,d0
		lea	($FFFFFA80).w,a0
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		move.b	($FFFFF627).w,d0

loc_1FC2:
		bsr.s	Pal_AddColor2
		dbf	d0,loc_1FC2
		rts
; End of function Pal_ToWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_AddColor2:				; XREF: Pal_ToWhite
		move.w	(a0),d2
		cmpi.w	#$EEE,d2
		beq.s	loc_2006
		move.w	d2,d1
		andi.w	#$E,d1
		cmpi.w	#$E,d1
		beq.s	loc_1FE2
		addq.w	#2,(a0)+	; increase red value
		rts
; ===========================================================================

loc_1FE2:				; XREF: Pal_AddColor2
		move.w	d2,d1
		andi.w	#$E0,d1
		cmpi.w	#$E0,d1
		beq.s	loc_1FF4
		addi.w	#$20,(a0)+	; increase green value
		rts
; ===========================================================================

loc_1FF4:				; XREF: loc_1FE2
		move.w	d2,d1
		andi.w	#$E00,d1
		cmpi.w	#$E00,d1
		beq.s	loc_2006
		addi.w	#$200,(a0)+	; increase blue	value
		rts
; ===========================================================================

loc_2006:				; XREF: Pal_AddColor2
		addq.w	#2,a0
		rts
; End of function Pal_AddColor2

; ---------------------------------------------------------------------------
; Pallet cycling routine - Sega	logo
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_Sega:				; XREF: SegaScreen
		tst.b	($FFFFF635).w
		bne.s	loc_206A
		lea	($FFFFFB20).w,a1
		lea	(Pal_Sega1).l,a0
		moveq	#5,d1
		move.w	($FFFFF632).w,d0

loc_2020:
		bpl.s	loc_202A
		addq.w	#2,a0
		subq.w	#1,d1
		addq.w	#2,d0
		bra.s	loc_2020
; ===========================================================================

loc_202A:				; XREF: PalCycle_Sega
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_2034
		addq.w	#2,d0

loc_2034:
		cmpi.w	#$60,d0
		bcc.s	loc_203E
		move.w	(a0)+,(a1,d0.w)

loc_203E:
		addq.w	#2,d0
		dbf	d1,loc_202A
		move.w	($FFFFF632).w,d0
		addq.w	#2,d0
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_2054
		addq.w	#2,d0

loc_2054:
		cmpi.w	#$64,d0
		blt.s	loc_2062
		move.w	#$401,($FFFFF634).w
		moveq	#-$C,d0

loc_2062:
		move.w	d0,($FFFFF632).w
		moveq	#1,d0
		rts
; ===========================================================================

loc_206A:				; XREF: loc_202A
		subq.b	#1,($FFFFF634).w
		bpl.s	loc_20BC
		move.b	#4,($FFFFF634).w
		move.w	($FFFFF632).w,d0
		addi.w	#$C,d0
		cmpi.w	#$30,d0
		bcs.s	loc_2088
		moveq	#0,d0
		rts
; ===========================================================================

loc_2088:				; XREF: loc_206A
		move.w	d0,($FFFFF632).w
		lea	(Pal_Sega2).l,a0
		lea	(a0,d0.w),a0
		lea	($FFFFFB04).w,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)
		lea	($FFFFFB20).w,a1
		moveq	#0,d0
		moveq	#$2C,d1

loc_20A8:
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_20B2
		addq.w	#2,d0

loc_20B2:
		move.w	(a0),(a1,d0.w)
		addq.w	#2,d0
		dbf	d1,loc_20A8

loc_20BC:
		moveq	#1,d0
		rts
; End of function PalCycle_Sega

; ===========================================================================

Pal_Sega1:	incbin	pallet\sega1.bin
Pal_Sega2:	incbin	pallet\sega2.bin

; ---------------------------------------------------------------------------
; Subroutines to load pallets
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad1:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		adda.w	#$80,a3
		move.w	(a1)+,d7

loc_2110:
		move.l	(a2)+,(a3)+
		dbf	d7,loc_2110
		rts
; End of function PalLoad1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad2:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		move.w	(a1)+,d7

loc_2128:
		move.l	(a2)+,(a3)+
		dbf	d7,loc_2128
		rts
; End of function PalLoad2

; ---------------------------------------------------------------------------
; Underwater pallet loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad3_Water:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		suba.w	#$80,a3
		move.w	(a1)+,d7

loc_2144:
		move.l	(a2)+,(a3)+
		dbf	d7,loc_2144
		rts
; End of function PalLoad3_Water


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad4_Water:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		suba.w	#$100,a3
		move.w	(a1)+,d7

loc_2160:
		move.l	(a2)+,(a3)+
		dbf	d7,loc_2160
		rts
; End of function PalLoad4_Water

; ===========================================================================
; ---------------------------------------------------------------------------
; Pallet pointers
; ---------------------------------------------------------------------------
PalPointers:
	include "_inc\Pallet pointers.asm"

; ---------------------------------------------------------------------------
; Pallet data
; ---------------------------------------------------------------------------
Pal_SegaBG:	incbin	pallet\sega_bg.bin
Pal_Title:	incbin	pallet\title.bin
Pal_LevelSel:	incbin	pallet\levelsel.bin
Pal_Sonic:	incbin	pallet\sonic.bin
Pal_GHZ:	incbin	pallet\ghz.bin
Pal_LZ:		incbin	pallet\lz.bin
Pal_LZWater:	incbin	pallet\lz_uw.bin	; LZ underwater pallets
Pal_MZ:		incbin	pallet\mz.bin
Pal_SLZ:	incbin	pallet\slz.bin
Pal_SYZ:	incbin	pallet\syz.bin
Pal_SBZ1:	incbin	pallet\sbz_act1.bin	; SBZ act 1 pallets
Pal_SBZ2:	incbin	pallet\sbz_act2.bin	; SBZ act 2 & Final Zone pallets
Pal_Special:	incbin	pallet\special.bin	; special stage pallets
Pal_SBZ3:	incbin	pallet\sbz_act3.bin	; SBZ act 3 pallets
Pal_SBZ3Water:	incbin	pallet\sbz_a3uw.bin	; SBZ act 3 (underwater) pallets
Pal_LZSonWater:	incbin	pallet\son_lzuw.bin	; Sonic (underwater in LZ) pallet
Pal_SBZ3SonWat:	incbin	pallet\son_sbzu.bin	; Sonic (underwater in SBZ act 3) pallet
Pal_SpeResult:	incbin	pallet\ssresult.bin	; special stage results screen pallets
Pal_SpeContinue:incbin	pallet\sscontin.bin	; special stage results screen continue pallet
Pal_Ending:	incbin	pallet\ending.bin	; ending sequence pallets

; ---------------------------------------------------------------------------
; Subroutine to	delay the program by ($FFFFF62A) frames
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DelayProgram:				; XREF: PauseGame
		move	#$2300,sr

loc_29AC:
		tst.b	($FFFFF62A).w
		bne.s	loc_29AC
		rts
; End of function DelayProgram

; ---------------------------------------------------------------------------
; Subroutine to	generate a pseudo-random number	in d0
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


RandomNumber:
		move.l	($FFFFF636).w,d1
		bne.s	loc_29C0
		move.l	#$2A6D365A,d1

loc_29C0:
		move.l	d1,d0
		asl.l	#2,d1
		add.l	d0,d1
		asl.l	#3,d1
		add.l	d0,d1
		move.w	d1,d0
		swap	d1
		add.w	d1,d0
		move.w	d0,d1
		swap	d1
		move.l	d1,($FFFFF636).w
		rts
; End of function RandomNumber


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CalcSine:				; XREF: SS_BGAnimate; et al
		andi.w	#$FF,d0
		add.w	d0,d0
		addi.w	#$80,d0
		move.w	Sine_Data(pc,d0.w),d1
		subi.w	#$80,d0
		move.w	Sine_Data(pc,d0.w),d0
		rts
; End of function CalcSine

; ===========================================================================

Sine_Data:	incbin	misc\sinewave.bin	; values for a 360º sine wave

; ===========================================================================
		movem.l	d1-d2,-(sp)
		move.w	d0,d1
		swap	d1
		moveq	#0,d0
		move.w	d0,d1
		moveq	#7,d2

loc_2C80:
		rol.l	#2,d1
		add.w	d0,d0
		addq.w	#1,d0
		sub.w	d0,d1
		bcc.s	loc_2C9A
		add.w	d0,d1
		subq.w	#1,d0
		dbf	d2,loc_2C80
		lsr.w	#1,d0
		movem.l	(sp)+,d1-d2
		rts
; ===========================================================================

loc_2C9A:
		addq.w	#1,d0
		dbf	d2,loc_2C80
		lsr.w	#1,d0
		movem.l	(sp)+,d1-d2
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CalcAngle:
		movem.l	d3-d4,-(sp)
		moveq	#0,d3
		moveq	#0,d4
		move.w	d1,d3
		move.w	d2,d4
		or.w	d3,d4
		beq.s	loc_2D04
		move.w	d2,d4
		tst.w	d3
		bpl.w	loc_2CC2
		neg.w	d3

loc_2CC2:
		tst.w	d4
		bpl.w	loc_2CCA
		neg.w	d4

loc_2CCA:
		cmp.w	d3,d4
		bcc.w	loc_2CDC
		lsl.l	#8,d4
		divu.w	d3,d4
		moveq	#0,d0
		move.b	Angle_Data(pc,d4.w),d0
		bra.s	loc_2CE6
; ===========================================================================

loc_2CDC:				; XREF: CalcAngle
		lsl.l	#8,d3
		divu.w	d4,d3
		moveq	#$40,d0
		sub.b	Angle_Data(pc,d3.w),d0

loc_2CE6:
		tst.w	d1
		bpl.w	loc_2CF2
		neg.w	d0
		addi.w	#$80,d0

loc_2CF2:
		tst.w	d2
		bpl.w	loc_2CFE
		neg.w	d0
		addi.w	#$100,d0

loc_2CFE:
		movem.l	(sp)+,d3-d4
		rts
; ===========================================================================

loc_2D04:				; XREF: CalcAngle
		move.w	#$40,d0
		movem.l	(sp)+,d3-d4
		rts
; End of function CalcAngle

; ===========================================================================

Angle_Data:	incbin	misc\angles.bin

; ===========================================================================

; ---------------------------------------------------------------------------
; Sega screen
; ---------------------------------------------------------------------------

SegaScreen:				; XREF: GameModeArray
		moveq	#Mus_Stop,d0
		bsr.w	PlaySound_Special ; stop music
		bsr.w	ClearPLC
		bsr.w	Pal_FadeFrom
		lea	($C00004).l,a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$8700,(a6)
		move.w	#$8B00,(a6)
		clr.b	($FFFFF64E).w
		move	#$2700,sr
		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		bsr.w	ClearScreen
		move.l	#$40000000,($C00004).l
		lea	(Nem_SegaLogo).l,a0 ; load Sega	logo patterns
		bsr.w	NemDec
		lea	($FF0000).l,a1
		lea	(Eni_SegaLogo).l,a0 ; load Sega	logo mappings
		move.w	#0,d0
		bsr.w	EniDec
		lea	($FF0000).l,a1
		move.l	#$65100003,d0
		moveq	#$17,d1
		moveq	#7,d2
		bsr.w	ShowVDPGraphics
		lea	($FF0180).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		bsr.w	ShowVDPGraphics
		moveq	#0,d0
		bsr.w	PalLoad2	; load Sega logo pallet
		move.w	#-$A,($FFFFF632).w
		move.w	#0,($FFFFF634).w
		move.w	#0,($FFFFF662).w
		move.w	#0,($FFFFF660).w
		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l

Sega_WaitPallet:
		move.b	#2,($FFFFF62A).w
		bsr.w	DelayProgram
		bsr.w	PalCycle_Sega
		bne.s	Sega_WaitPallet

		moveq	#mus_SEGA,d0
		bsr.w	PlaySound_Special ; play "SEGA"	sound
		move.b	#$14,($FFFFF62A).w
		bsr.w	DelayProgram

Sega_WaitEnd:
		move.b	#2,($FFFFF62A).w
		bsr.w	DelayProgram
		tst.b	mComm.w			; check if playback has ended
		bne.s	Sega_GotoTitle		; if yes, branch
		andi.b	#$80,($FFFFF605).w ; is	Start button pressed?
		beq.s	Sega_WaitEnd	; if not, branch

Sega_GotoTitle:
		move.b	#4,($FFFFF600).w ; go to title screen
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Title	screen
; ---------------------------------------------------------------------------

TitleScreen:				; XREF: GameModeArray
		moveq	#Mus_Stop,d0
		bsr.w	PlaySound_Special ; stop music
		bsr.w	ClearPLC
		bsr.w	Pal_FadeFrom
		moveq	#Mus_Reset,d0
		bsr.w	PlaySound_Special2	 ; fade reset music

		move	#$2700,sr
		lea	($C00004).l,a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$9001,(a6)
		move.w	#$9200,(a6)
		move.w	#$8B03,(a6)
		move.w	#$8720,(a6)
		clr.b	($FFFFF64E).w
		bsr.w	ClearScreen
		lea	($FFFFD000).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

Title_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,Title_ClrObjRam ; fill object RAM ($D000-$EFFF) with	$0

		move.l	#$40000000,($C00004).l
		lea	(Nem_JapNames).l,a0 ; load Japanese credits
		bsr.w	NemDec
		move.l	#$54C00000,($C00004).l
		lea	(Nem_CreditText).l,a0 ;	load alphabet
		bsr.w	NemDec
		lea	($FF0000).l,a1
		lea	(Eni_JapNames).l,a0 ; load mappings for	Japanese credits
		move.w	#0,d0
		bsr.w	EniDec
		lea	($FF0000).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		bsr.w	ShowVDPGraphics
		lea	($FFFFFB80).w,a1
		moveq	#0,d0
		move.w	#$1F,d1

Title_ClrPallet:
		move.l	d0,(a1)+
		dbf	d1,Title_ClrPallet ; fill pallet with 0	(black)

		moveq	#3,d0		; load Sonic's pallet
		bsr.w	PalLoad1
		move.b	#$8A,($FFFFD080).w ; load "SONIC TEAM PRESENTS"	object
		jsr	ObjectsLoad
		jsr	BuildSprites
		bsr.w	Pal_FadeTo
		move	#$2700,sr
		move.l	#$40000001,($C00004).l
		lea	(Nem_TitleFg).l,a0 ; load title	screen patterns
		bsr.w	NemDec
		move.l	#$60000001,($C00004).l
		lea	(Nem_TitleSonic).l,a0 ;	load Sonic title screen	patterns
		bsr.w	NemDec
		move.l	#$62000002,($C00004).l
		lea	(Nem_TitleTM).l,a0 ; load "TM" patterns
		bsr.w	NemDec
		lea	($C00000).l,a6
		move.l	#$50000003,4(a6)
		lea	(Art_Text).l,a5
		move.w	#$28F,d1

Title_LoadText:
		move.w	(a5)+,(a6)
		dbf	d1,Title_LoadText ; load uncompressed text patterns

		move.b	#0,($FFFFFE30).w ; clear lamppost counter
		move.w	#0,($FFFFFE08).w ; disable debug item placement	mode
		move.w	#0,($FFFFFFF0).w ; disable debug mode
		move.w	#0,($FFFFFFEA).w
		move.w	#0,($FFFFFE10).w ; set level to	GHZ (00)
		move.w	#0,($FFFFF634).w ; disable pallet cycling
		bsr.w	LevelSizeLoad
		bsr.w	DeformBgLayer
		lea	($FFFFB000).w,a1
		lea	(Blk16_GHZ).l,a0 ; load	GHZ 16x16 mappings
		move.w	#0,d0
		bsr.w	EniDec
		lea	(Blk256_GHZ).l,a0 ; load GHZ 256x256 mappings
		lea	($FF0000).l,a1
		bsr.w	KosDec
		bsr.w	LevelLayoutLoad
		bsr.w	Pal_FadeFrom
		move	#$2700,sr
		bsr.w	ClearScreen
		lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	($FFFFF708).w,a3
		lea	($FFFFA440).w,a4
		move.w	#$6000,d2
		bsr.w	LoadTilesFromStart2
		lea	($FF0000).l,a1
		lea	(Eni_Title).l,a0 ; load	title screen mappings
		move.w	#0,d0
		bsr.w	EniDec
		lea	($FF0000).l,a1
		move.l	#$42060003,d0
		moveq	#$21,d1
		moveq	#$15,d2
		bsr.w	ShowVDPGraphics
		move.l	#$40000000,($C00004).l
		lea	(Nem_GHZ_1st).l,a0 ; load GHZ patterns
		bsr.w	NemDec
		moveq	#1,d0		; load title screen pallet
		bsr.w	PalLoad1
		move.b	#0,($FFFFFFFA).w ; disable debug mode
		move.w	#$178,($FFFFF614).w	; run title screen for $178 frames (NTSC)
		btst	#6,$FFFFFFF8.w		; check if PAL
		beq.s	.NTSC			; branch if not
		move.w	#$180/6*5,($FFFFF614).w	; run title screen for $140 frames (PAL)

.NTSC		lea	($FFFFD080).w,a1
		moveq	#0,d0
		moveq	#$10-1,d1		; this was causing some problems, fixed the bug

Title_ClrObjRam2:
		move.l	d0,(a1)+
		dbf	d1,Title_ClrObjRam2

		move.b	#$E,($FFFFD040).w ; load big Sonic object
		move.b	#$F,($FFFFD080).w ; load "PRESS	START BUTTON" object
		move.b	#$F,($FFFFD0C0).w ; load "TM" object
		move.b	#3,($FFFFD0DA).w
		move.b	#$F,($FFFFD100).w
		move.b	#2,($FFFFD11A).w

		move.b	#4,($FFFFF62A).w	; we can not afford to run the sound driver too
		bsr.w	DelayProgram		; late, or we will lose the YM data and break music
		moveq	#mus_Title,d0		; play title screen music
		bsr.w	PlaySound
		jsr	ObjectsLoad
		bsr.w	DeformBgLayer
		jsr	BuildSprites
		moveq	#0,d0
		bsr.w	LoadPLC2
		move.w	#0,($FFFFFFE4).w
		move.w	#0,($FFFFFFE6).w
		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		bsr.w	Pal_FadeTo

loc_317C:
		move.b	#4,($FFFFF62A).w
		bsr.w	DelayProgram
		jsr	ObjectsLoad
		bsr.w	DeformBgLayer
		jsr	BuildSprites
		bsr.w	PalCycle_Title
		bsr.w	RunPLC_RAM
		move.w	($FFFFD008).w,d0
		addq.w	#2,d0
		move.w	d0,($FFFFD008).w ; move	Sonic to the right
		cmpi.w	#$1C00,d0	; has Sonic object passed x-position $1C00?
		bcs.s	Title_ChkRegion	; if not, branch
		move.b	#0,($FFFFF600).w ; go to Sega screen
		rts
; ===========================================================================

Title_ChkRegion:
		tst.b	($FFFFFFF8).w	; check	if the machine is US or	Japanese
		bpl.s	Title_RegionJ	; if Japanese, branch
		lea	(LevelSelectCode_US).l,a0 ; load US code
		bra.s	Title_EnterCheat
; ===========================================================================

Title_RegionJ:				; XREF: Title_ChkRegion
		lea	(LevelSelectCode_J).l,a0 ; load	J code

Title_EnterCheat:			; XREF: Title_ChkRegion
		move.w	($FFFFFFE4).w,d0
		adda.w	d0,a0
		move.b	($FFFFF605).w,d0 ; get button press
		andi.b	#$F,d0		; read only up/down/left/right buttons
		cmp.b	(a0),d0		; does button press match the cheat code?
		bne.s	loc_3210	; if not, branch
		addq.w	#1,($FFFFFFE4).w ; next	button press
		tst.b	d0
		bne.s	Title_CountC
		lea	($FFFFFFE0).w,a0
		move.w	($FFFFFFE6).w,d1
		lsr.w	#1,d1
		andi.w	#3,d1
		beq.s	Title_PlayRing
		tst.b	($FFFFFFF8).w
		bpl.s	Title_PlayRing
		moveq	#1,d1
		move.b	d1,1(a0,d1.w)

Title_PlayRing:
		move.b	#1,(a0,d1.w)	; activate cheat
		moveq	#sfx_RingRight,d0; play ring sound when code is entered
		bsr.w	PlaySound_Special
		bra.s	Title_CountC
; ===========================================================================

loc_3210:				; XREF: Title_EnterCheat
		tst.b	d0
		beq.s	Title_CountC
		cmpi.w	#9,($FFFFFFE4).w
		beq.s	Title_CountC
		move.w	#0,($FFFFFFE4).w

Title_CountC:
		move.b	($FFFFF605).w,d0
		andi.b	#$20,d0		; is C button pressed?
		beq.s	loc_3230	; if not, branch
		addq.w	#1,($FFFFFFE6).w ; increment C button counter

loc_3230:
		tst.w	($FFFFF614).w
		beq.w	Demo
		andi.b	#$80,($FFFFF605).w ; check if Start is pressed
		beq.w	loc_317C	; if not, branch

Title_ChkLevSel:
		tst.b	($FFFFFFE0).w	; check	if level select	code is	on
		beq.w	PlayLevel	; if not, play level
		btst	#6,($FFFFF604).w ; check if A is pressed
		beq.w	PlayLevel	; if not, play level
		moveq	#2,d0
		bsr.w	PalLoad2	; load level select pallet
		lea	($FFFFCC00).w,a1
		moveq	#0,d0
		move.w	#$DF,d1

Title_ClrScroll:
		move.l	d0,(a1)+
		dbf	d1,Title_ClrScroll ; fill scroll data with 0

		move.l	d0,($FFFFF616).w
		move	#$2700,sr
		lea	($C00000).l,a6
		move.l	#$60000003,($C00004).l
		move.w	#$3FF,d1

Title_ClrVram:
		move.l	d0,(a6)
		dbf	d1,Title_ClrVram ; fill	VRAM with 0

		move.w	#MusOff,($FFFFFF84).w
		bsr.w	LevSelTextLoad

; ---------------------------------------------------------------------------
; Level	Select
; ---------------------------------------------------------------------------

LevelSelect:
		move.b	#4,($FFFFF62A).w
		bsr.w	DelayProgram
		bsr.w	LevSelControls
		bsr.w	RunPLC_RAM
		tst.l	($FFFFF680).w
		bne.s	LevelSelect
		andi.b	#$F0,($FFFFF605).w ; is	A, B, C, or Start pressed?
		beq.s	LevelSelect	; if not, branch
		move.w	($FFFFFF82).w,d0
		cmpi.w	#$14,d0		; have you selected item $14 (sound test)?
		bne.s	LevSel_Level_SS	; if not, go to	Level/SS subroutine

		move.w	($FFFFFF84).w,d0
		tst.b	($FFFFFFE3).w	; is Japanese Credits cheat on?
		beq.s	LevSel_NoCheat	; if not, branch
		cmpi.w	#$9F,d0		; is sound $9F being played?
		beq.s	LevSel_Ending	; if yes, branch
		cmpi.w	#$9E,d0		; is sound $9E being played?
		beq.s	LevSel_Credits	; if yes, branch

LevSel_NoCheat:

LevSel_PlaySnd:
		bsr.w	PlaySound_Special
		bra.s	LevelSelect
; ===========================================================================

LevSel_Ending:				; XREF: LevelSelect
		move.b	#$18,($FFFFF600).w ; set screen	mode to	$18 (Ending)
		move.w	#$600,($FFFFFE10).w ; set level	to 0600	(Ending)
		rts
; ===========================================================================

LevSel_Credits:				; XREF: LevelSelect
		move.b	#$1C,($FFFFF600).w ; set screen	mode to	$1C (Credits)
		moveq	#mus_Credits,d0
		bsr.w	PlaySound_Special ; play credits music
		move.w	#0,($FFFFFFF4).w
		rts
; ===========================================================================

LevSel_Level_SS:			; XREF: LevelSelect
		add.w	d0,d0
		move.w	LSelectPointers(pc,d0.w),d0 ; load level number
		bmi.w	LevelSelect
		cmpi.w	#$700,d0	; check	if level is 0700 (Special Stage)
		bne.s	LevSel_Level	; if not, branch
		move.b	#$10,($FFFFF600).w ; set screen	mode to	$10 (Special Stage)
		clr.w	($FFFFFE10).w	; clear	level
		move.b	#3,($FFFFFE12).w ; set lives to	3
		moveq	#0,d0
		move.w	d0,($FFFFFE20).w ; clear rings
		move.l	d0,($FFFFFE22).w ; clear time
		move.l	d0,($FFFFFE26).w ; clear score
		rts
; ===========================================================================

LevSel_Level:				; XREF: LevSel_Level_SS
		andi.w	#$3FFF,d0
		move.w	d0,($FFFFFE10).w ; set level number

PlayLevel:				; XREF: ROM:00003246j ...
		move.b	#$C,($FFFFF600).w ; set	screen mode to $0C (level)
		move.b	#3,($FFFFFE12).w ; set lives to	3
		moveq	#0,d0
		move.w	d0,($FFFFFE20).w ; clear rings
		move.l	d0,($FFFFFE22).w ; clear time
		move.l	d0,($FFFFFE26).w ; clear score
		move.b	d0,($FFFFFE16).w ; clear special stage number
		move.b	d0,($FFFFFE57).w ; clear emeralds
		move.l	d0,($FFFFFE58).w ; clear emeralds
		move.l	d0,($FFFFFE5C).w ; clear emeralds
		move.b	d0,($FFFFFE18).w ; clear continues
		moveq	#Mus_FadeOut,d0
		bra.w	PlaySound_Special ; fade out music
; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select - level pointers
; ---------------------------------------------------------------------------
LSelectPointers:
		incbin	misc\ls_point.bin
		even
; ---------------------------------------------------------------------------
; Level	select codes
; ---------------------------------------------------------------------------
LevelSelectCode_J:
		incbin	misc\ls_jcode.bin
		even

LevelSelectCode_US:
		incbin	misc\ls_ucode.bin
		even
; ===========================================================================

; ---------------------------------------------------------------------------
; Demo mode
; ---------------------------------------------------------------------------

Demo:					; XREF: TitleScreen
		move.w	#$1E,($FFFFF614).w

loc_33B6:				; XREF: loc_33E4
		move.b	#4,($FFFFF62A).w
		bsr.w	DelayProgram
		bsr.w	DeformBgLayer
		bsr.w	PalCycle_Load
		bsr.w	RunPLC_RAM
		move.w	($FFFFD008).w,d0
		addq.w	#2,d0
		move.w	d0,($FFFFD008).w
		cmpi.w	#$1C00,d0
		bcs.s	loc_33E4
		move.b	#0,($FFFFF600).w ; set screen mode to 00 (level)
		rts
; ===========================================================================

loc_33E4:				; XREF: Demo
		andi.b	#$80,($FFFFF605).w ; is	Start button pressed?
		bne.w	Title_ChkLevSel	; if yes, branch
		tst.w	($FFFFF614).w
		bne.w	loc_33B6
		moveq	#Mus_FadeOut,d0
		bsr.w	PlaySound_Special ; fade out music
		move.w	($FFFFFFF2).w,d0 ; load	demo number
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Demo_Levels(pc,d0.w),d0	; load level number for	demo
		move.w	d0,($FFFFFE10).w
		addq.w	#1,($FFFFFFF2).w ; add 1 to demo number
		cmpi.w	#4,($FFFFFFF2).w ; is demo number less than 4?
		bcs.s	loc_3422	; if yes, branch
		move.w	#0,($FFFFFFF2).w ; reset demo number to	0

loc_3422:
		move.w	#1,($FFFFFFF0).w ; turn	demo mode on
		move.b	#8,($FFFFF600).w ; set screen mode to 08 (demo)
		cmpi.w	#$600,d0	; is level number 0600 (special	stage)?
		bne.s	Demo_Level	; if not, branch
		move.b	#$10,($FFFFF600).w ; set screen	mode to	$10 (Special Stage)
		clr.w	($FFFFFE10).w	; clear	level number
		clr.b	($FFFFFE16).w	; clear	special	stage number

Demo_Level:
		move.b	#3,($FFFFFE12).w ; set lives to	3
		moveq	#0,d0
		move.w	d0,($FFFFFE20).w ; clear rings
		move.l	d0,($FFFFFE22).w ; clear time
		move.l	d0,($FFFFFE26).w ; clear score
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Levels used in demos
; ---------------------------------------------------------------------------
Demo_Levels:	incbin	misc\dm_ord1.bin
		even

; ---------------------------------------------------------------------------
; Subroutine to	change what you're selecting in the level select
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevSelControls:				; XREF: LevelSelect
		move.b	($FFFFF605).w,d1
		andi.b	#3,d1		; is up/down pressed and held?
		bne.s	LevSel_UpDown	; if yes, branch
		subq.w	#1,($FFFFFF80).w ; subtract 1 from time	to next	move
		bpl.s	LevSel_SndTest	; if time remains, branch

LevSel_UpDown:
		move.w	#$B,($FFFFFF80).w ; reset time delay
		move.b	($FFFFF604).w,d1
		andi.b	#3,d1		; is up/down pressed?
		beq.s	LevSel_SndTest	; if not, branch
		move.w	($FFFFFF82).w,d0
		btst	#0,d1		; is up	pressed?
		beq.s	LevSel_Down	; if not, branch
		subq.w	#1,d0		; move up 1 selection
		bcc.s	LevSel_Down
		moveq	#$14,d0		; if selection moves below 0, jump to selection	$14

LevSel_Down:
		btst	#1,d1		; is down pressed?
		beq.s	LevSel_Refresh	; if not, branch
		addq.w	#1,d0		; move down 1 selection
		cmpi.w	#$15,d0
		bcs.s	LevSel_Refresh
		moveq	#0,d0		; if selection moves above $14,	jump to	selection 0

LevSel_Refresh:
		move.w	d0,($FFFFFF82).w ; set new selection
		bsr.w	LevSelTextLoad	; refresh text
		rts
; ===========================================================================

LevSel_SndTest:				; XREF: LevSelControls
		cmpi.w	#$14,($FFFFFF82).w ; is	item $14 selected?
		bne.s	LevSel_NoMove	; if not, branch
		move.b	($FFFFF605).w,d1
		andi.b	#$C,d1		; is left/right	pressed?
		beq.s	LevSel_NoMove	; if not, branch
		move.w	($FFFFFF84).w,d0
		btst	#2,d1		; is left pressed?
		beq.s	LevSel_Right	; if not, branch
		subq.w	#1,d0		; subtract 1 from sound	test
		bcc.s	LevSel_Right
		moveq	#SFXoff+SFXcount-1,d0; if sound test moves below 0, set to max

LevSel_Right:
		btst	#3,d1		; is right pressed?
		beq.s	LevSel_Refresh2	; if not, branch
		addq.w	#1,d0		; add 1	to sound test
		cmpi.w	#SFXoff+SFXcount,d0
		bcs.s	LevSel_Refresh2
		moveq	#0,d0		; if sound test	moves above max, set to	0

LevSel_Refresh2:
		move.w	d0,($FFFFFF84).w ; set sound test number
		bsr.w	LevSelTextLoad	; refresh text

LevSel_NoMove:
		rts
; End of function LevSelControls

; ---------------------------------------------------------------------------
; Subroutine to load level select text
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevSelTextLoad:				; XREF: TitleScreen
		lea	(LevelMenuText).l,a1
		lea	($C00000).l,a6
		move.l	#$62100003,d4	; screen position (text)
		move.w	#$E680,d3	; VRAM setting
		moveq	#$14,d1		; number of lines of text

loc_34FE:				; XREF: LevSelTextLoad+26j
		move.l	d4,4(a6)
		bsr.w	LevSel_ChgLine
		addi.l	#$800000,d4
		dbf	d1,loc_34FE
		moveq	#0,d0
		move.w	($FFFFFF82).w,d0
		move.w	d0,d1
		move.l	#$62100003,d4
		lsl.w	#7,d0
		swap	d0
		add.l	d0,d4
		lea	(LevelMenuText).l,a1
		lsl.w	#3,d1
		move.w	d1,d0
		add.w	d1,d1
		add.w	d0,d1
		adda.w	d1,a1
		move.w	#$C680,d3
		move.l	d4,4(a6)
		bsr.w	LevSel_ChgLine
		move.w	#$E680,d3
		cmpi.w	#$14,($FFFFFF82).w
		bne.s	loc_3550
		move.w	#$C680,d3

loc_3550:
		move.l	#$6C300003,($C00004).l ; screen	position (sound	test)
		move.w	($FFFFFF84).w,d0
		move.b	d0,d2
		lsr.b	#4,d0
		bsr.w	LevSel_ChgSnd
		move.b	d2,d0
		bsr.w	LevSel_ChgSnd
		rts
; End of function LevSelTextLoad


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevSel_ChgSnd:				; XREF: LevSelTextLoad
		andi.w	#$F,d0
		cmpi.b	#$A,d0
		bcs.s	loc_3580
		addi.b	#7,d0

loc_3580:
		add.w	d3,d0
		move.w	d0,(a6)
		rts
; End of function LevSel_ChgSnd


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevSel_ChgLine:				; XREF: LevSelTextLoad
		moveq	#$17,d2		; number of characters per line

loc_3588:
		moveq	#0,d0
		move.b	(a1)+,d0
		bpl.s	loc_3598
		move.w	#0,(a6)
		dbf	d2,loc_3588
		rts
; ===========================================================================

loc_3598:				; XREF: LevSel_ChgLine
		add.w	d3,d0
		move.w	d0,(a6)
		dbf	d2,loc_3588
		rts
; End of function LevSel_ChgLine

; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select menu text
; ---------------------------------------------------------------------------
LevelMenuText:	incbin	misc\menutext.bin
		even
; ---------------------------------------------------------------------------
; Music	playlist
; ---------------------------------------------------------------------------
MusicList:	dc.b mus_GHZ, mus_LZ, mus_MZ, mus_SLZ, mus_SYZ, mus_SBZ, mus_FZ
		even
; ===========================================================================

; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

Level:					; XREF: GameModeArray
		bset	#7,($FFFFF600).w ; add $80 to screen mode (for pre level sequence)
		tst.w	($FFFFFFF0).w
		bmi.s	loc_37B6
		moveq	#Mus_FadeOut,d0
		bsr.w	PlaySound_Special ; fade out music

loc_37B6:
		bsr.w	ClearPLC
		bsr.w	Pal_FadeFrom
		tst.w	($FFFFFFF0).w
		bmi.s	Level_ClrRam
		move	#$2700,sr
		move.l	#$70000002,($C00004).l
		lea	(Nem_TitleCard).l,a0 ; load title card patterns
		bsr.w	NemDec
		move	#$2300,sr
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		lsl.w	#4,d0
		lea	(MainLoadBlocks).l,a2
		lea	(a2,d0.w),a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	loc_37FC
		bsr.w	LoadPLC		; load level patterns

loc_37FC:
		moveq	#1,d0
		bsr.w	LoadPLC		; load standard	patterns

Level_ClrRam:
		lea	($FFFFD000).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

Level_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,Level_ClrObjRam ; clear object RAM

		lea	($FFFFF628).w,a1
		moveq	#0,d0
		move.w	#$15,d1

Level_ClrVars:
		move.l	d0,(a1)+
		dbf	d1,Level_ClrVars ; clear misc variables

		lea	($FFFFF700).w,a1
		moveq	#0,d0
		move.w	#$3F,d1

Level_ClrVars2:
		move.l	d0,(a1)+
		dbf	d1,Level_ClrVars2 ; clear misc variables

		lea	($FFFFFE60).w,a1
		moveq	#0,d0
		move.w	#$47,d1

Level_ClrVars3:
		move.l	d0,(a1)+
		dbf	d1,Level_ClrVars3 ; clear object variables

		move	#$2700,sr
		bsr.w	ClearScreen
		lea	($C00004).l,a6
		move.w	#$8B03,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$857C,(a6)
		move.w	#$9001,(a6)
		move.w	#$8004,(a6)
		move.w	#$8720,(a6)
		move.w	#$8ADF,($FFFFF624).w
		move.w	($FFFFF624).w,(a6)
		cmpi.b	#1,($FFFFFE10).w ; is level LZ?
		bne.s	Level_LoadPal	; if not, branch
		move.w	#$8014,(a6)
		moveq	#0,d0
		move.b	($FFFFFE11).w,d0
		add.w	d0,d0
		lea	(WaterHeight).l,a1 ; load water	height array
		move.w	(a1,d0.w),d0
		move.w	d0,($FFFFF646).w ; set water heights
		move.w	d0,($FFFFF648).w
		move.w	d0,($FFFFF64A).w
		clr.b	($FFFFF64D).w	; clear	water routine counter
		clr.b	($FFFFF64E).w	; clear	water movement
		move.b	#1,($FFFFF64C).w ; enable water

Level_LoadPal:
		move.w	#$1E,($FFFFFE14).w
		move	#$2300,sr
		moveq	#3,d0
		bsr.w	PalLoad2	; load Sonic's pallet line
		cmpi.b	#1,($FFFFFE10).w ; is level LZ?
		bne.s	Level_GetBgm	; if not, branch
		moveq	#$F,d0		; pallet number	$0F (LZ)
		cmpi.b	#3,($FFFFFE11).w ; is act number 3?
		bne.s	Level_WaterPal	; if not, branch
		moveq	#$10,d0		; pallet number	$10 (SBZ3)

Level_WaterPal:
		bsr.w	PalLoad3_Water	; load underwater pallet (see d0)
		tst.b	($FFFFFE30).w
		beq.s	Level_GetBgm
		move.b	($FFFFFE53).w,($FFFFF64E).w

Level_GetBgm:
		moveq	#Mus_Reset,d0
		bsr.w	PlaySound_Special2	 ; fade reset music
		tst.w	($FFFFFFF0).w
		bmi.s	loc_3946
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		cmpi.w	#$103,($FFFFFE10).w ; is level SBZ3?
		bne.s	Level_BgmNotLZ4	; if not, branch
		moveq	#5,d0		; move 5 to d0

Level_BgmNotLZ4:
		cmpi.w	#$502,($FFFFFE10).w ; is level FZ?
		bne.s	Level_PlayBgm	; if not, branch
		moveq	#6,d0		; move 6 to d0

Level_PlayBgm:
		lea	(MusicList).l,a1 ; load	music playlist
		move.b	(a1,d0.w),d0	; add d0 to a1
		bsr.w	PlaySound	; play music
		move.b	#$34,($FFFFD080).w ; load title	card object

Level_TtlCard:
		move.b	#$C,($FFFFF62A).w
		bsr.w	DelayProgram
		jsr	ObjectsLoad
		jsr	BuildSprites
		bsr.w	RunPLC_RAM
		move.w	($FFFFD108).w,d0
		cmp.w	($FFFFD130).w,d0 ; has title card sequence finished?
		bne.s	Level_TtlCard	; if not, branch
		tst.l	($FFFFF680).w	; are there any	items in the pattern load cue?
		bne.s	Level_TtlCard	; if yes, branch
		jsr	Hud_Base

loc_3946:
		moveq	#3,d0
		bsr.w	PalLoad1	; load Sonic's pallet line
		bsr.w	LevelSizeLoad
		bsr.w	DeformBgLayer
		bset	#2,($FFFFF754).w
		bsr.w	MainLoadBlockLoad ; load block mappings	and pallets
		bsr.w	LoadTilesFromStart
		jsr	FloorLog_Unk
		bsr.w	ColIndexLoad
		bsr.w	LZWaterEffects
		move.b	#1,($FFFFD000).w ; load	Sonic object
		tst.w	($FFFFFFF0).w
		bmi.s	Level_ChkDebug
		move.b	#$21,($FFFFD040).w ; load HUD object

Level_ChkDebug:
		tst.b	($FFFFFFE2).w	; has debug cheat been entered?
		beq.s	Level_ChkWater	; if not, branch
		btst	#6,($FFFFF604).w ; is A	button pressed?
		beq.s	Level_ChkWater	; if not, branch
		move.b	#1,($FFFFFFFA).w ; enable debug	mode

Level_ChkWater:
		move.w	#0,($FFFFF602).w
		move.w	#0,($FFFFF604).w
		cmpi.b	#1,($FFFFFE10).w ; is level LZ?
		bne.s	Level_LoadObj	; if not, branch
		move.b	#$1B,($FFFFD780).w ; load water	surface	object
		move.w	#$60,($FFFFD788).w
		move.b	#$1B,($FFFFD7C0).w
		move.w	#$120,($FFFFD7C8).w

Level_LoadObj:
		jsr	ObjPosLoad
		jsr	ObjectsLoad
		jsr	BuildSprites
		moveq	#0,d0
		tst.b	($FFFFFE30).w	; are you starting from	a lamppost?
		bne.s	loc_39E8	; if yes, branch
		move.w	d0,($FFFFFE20).w ; clear rings
		move.l	d0,($FFFFFE22).w ; clear time
		move.b	d0,($FFFFFE1B).w ; clear lives counter

loc_39E8:
		move.b	d0,($FFFFFE1A).w
		move.b	d0,($FFFFFE2C).w ; clear shield
		move.b	d0,($FFFFFE2D).w ; clear invincibility
		move.b	d0,($FFFFFE2E).w ; clear speed shoes
		move.b	d0,($FFFFFE2F).w
		move.w	d0,($FFFFFE08).w
		move.w	d0,($FFFFFE02).w
		move.w	d0,($FFFFFE04).w
		bsr.w	OscillateNumInit
		move.b	#1,($FFFFFE1F).w ; update score	counter
		move.b	#1,($FFFFFE1D).w ; update rings	counter
		move.b	#1,($FFFFFE1E).w ; update time counter
		move.w	#0,($FFFFF790).w
		lea	(Demo_Index).l,a1 ; load demo data
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		tst.w	($FFFFFFF0).w	; is demo mode on?
		bpl.s	Level_Demo	; if yes, branch
		lea	(Demo_EndIndex).l,a1 ; load ending demo	data
		move.w	($FFFFFFF4).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1

Level_Demo:
		move.b	1(a1),($FFFFF792).w ; load key press duration
		subq.b	#1,($FFFFF792).w ; subtract 1 from duration
		move.w	#1800,($FFFFF614).w
		tst.w	($FFFFFFF0).w
		bpl.s	Level_ChkWaterPal
		move.w	#540,($FFFFF614).w
		cmpi.w	#4,($FFFFFFF4).w
		bne.s	Level_ChkWaterPal
		move.w	#510,($FFFFF614).w

Level_ChkWaterPal:
		cmpi.b	#1,($FFFFFE10).w ; is level LZ/SBZ3?
		bne.s	Level_Delay	; if not, branch
		moveq	#$B,d0		; pallet $0B (LZ underwater)
		cmpi.b	#3,($FFFFFE11).w ; is level SBZ3?
		bne.s	Level_WaterPal2	; if not, branch
		moveq	#$D,d0		; pallet $0D (SBZ3 underwater)

Level_WaterPal2:
		bsr.w	PalLoad4_Water

Level_Delay:
		move.w	#3,d1

Level_DelayLoop:
		move.b	#8,($FFFFF62A).w
		bsr.w	DelayProgram
		dbf	d1,Level_DelayLoop

		move.w	#$202F,($FFFFF626).w
		bsr.w	Pal_FadeTo2
		tst.w	($FFFFFFF0).w
		bmi.s	Level_ClrCardArt
		addq.b	#2,($FFFFD0A4).w ; make	title card move
		addq.b	#4,($FFFFD0E4).w
		addq.b	#4,($FFFFD124).w
		addq.b	#4,($FFFFD164).w
		bra.s	Level_StartGame
; ===========================================================================

Level_ClrCardArt:
		moveq	#2,d0
		jsr	(LoadPLC).l	; load explosion patterns
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		addi.w	#$15,d0
		jsr	(LoadPLC).l	; load animal patterns (level no. + $15)

Level_StartGame:
		bclr	#7,($FFFFF600).w ; subtract 80 from screen mode

; ---------------------------------------------------------------------------
; Main level loop (when	all title card and loading sequences are finished)
; ---------------------------------------------------------------------------

Level_MainLoop:
		bsr.w	PauseGame
		move.b	#8,($FFFFF62A).w
		bsr.w	DelayProgram
		addq.w	#1,($FFFFFE04).w ; add 1 to level timer
		bsr.w	MoveSonicInDemo
		bsr.w	LZWaterEffects
		jsr	ObjectsLoad
		tst.w	($FFFFFE08).w
		bne.s	loc_3B10
		cmpi.b	#6,($FFFFD024).w
		bcc.s	loc_3B14

loc_3B10:
		bsr.w	DeformBgLayer

loc_3B14:
		jsr	BuildSprites
		jsr	ObjPosLoad
		bsr.w	PalCycle_Load
		bsr.w	RunPLC_RAM
		bsr.w	OscillateNumDo
		bsr.w	ChangeRingFrame
		bsr.w	SignpostArtLoad
		cmpi.b	#8,($FFFFF600).w
		beq.s	Level_ChkDemo	; if screen mode is 08 (demo), branch
		tst.w	($FFFFFE02).w	; is the level set to restart?
		bne.w	Level		; if yes, branch
		cmpi.b	#$C,($FFFFF600).w
		beq.w	Level_MainLoop	; if screen mode is $0C	(level), branch
		rts
; ===========================================================================

Level_ChkDemo:				; XREF: Level_MainLoop
		tst.w	($FFFFFE02).w	; is level set to restart?
		bne.s	Level_EndDemo	; if yes, branch
		tst.w	($FFFFF614).w	; is there time	left on	the demo?
		beq.s	Level_EndDemo	; if not, branch
		cmpi.b	#8,($FFFFF600).w
		beq.w	Level_MainLoop	; if screen mode is 08 (demo), branch
		move.b	#0,($FFFFF600).w ; go to Sega screen
		rts
; ===========================================================================

Level_EndDemo:				; XREF: Level_ChkDemo
		cmpi.b	#8,($FFFFF600).w ; is screen mode 08 (demo)?
		bne.s	loc_3B88	; if not, branch
		move.b	#0,($FFFFF600).w ; go to Sega screen
		tst.w	($FFFFFFF0).w	; is demo mode on?
		bpl.s	loc_3B88	; if yes, branch
		move.b	#$1C,($FFFFF600).w ; go	to credits

loc_3B88:
		move.w	#$3C,($FFFFF614).w
		move.w	#$3F,($FFFFF626).w
		clr.w	($FFFFF794).w

loc_3B98:
		move.b	#8,($FFFFF62A).w
		bsr.w	DelayProgram
		bsr.w	MoveSonicInDemo
		jsr	ObjectsLoad
		jsr	BuildSprites
		jsr	ObjPosLoad
		subq.w	#1,($FFFFF794).w
		bpl.s	loc_3BC8
		move.w	#2,($FFFFF794).w
		bsr.w	Pal_FadeOut

loc_3BC8:
		tst.w	($FFFFF614).w
		bne.s	loc_3B98
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	do special water effects in Labyrinth Zone
; ---------------------------------------------------------------------------

LZWaterEffects:				; XREF: Level
		cmpi.b	#1,($FFFFFE10).w ; check if level is LZ
		bne.s	locret_3C28	; if not, branch
		cmpi.b	#6,($FFFFD024).w
		bcc.s	LZMoveWater
		bsr.w	LZWindTunnels
		bsr.w	LZWaterSlides
		bsr.w	LZDynamicWater

LZMoveWater:
		clr.b	($FFFFF64E).w
		moveq	#0,d0
		move.b	($FFFFFE60).w,d0
		lsr.w	#1,d0
		add.w	($FFFFF648).w,d0
		move.w	d0,($FFFFF646).w
		move.w	($FFFFF646).w,d0
		sub.w	($FFFFF704).w,d0
		bcc.s	loc_3C1A
		tst.w	d0
		bpl.s	loc_3C1A
		move.b	#-$21,($FFFFF625).w
		move.b	#1,($FFFFF64E).w

loc_3C1A:
		cmpi.w	#$DF,d0
		bcs.s	loc_3C24
		move.w	#$DF,d0

loc_3C24:
		move.b	d0,($FFFFF625).w

locret_3C28:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Labyrinth default water heights
; ---------------------------------------------------------------------------
WaterHeight:	incbin	misc\lz_heigh.bin
		even
; ===========================================================================

; ---------------------------------------------------------------------------
; Labyrinth dynamic water routines
; ---------------------------------------------------------------------------

LZDynamicWater:				; XREF: LZWaterEffects
		moveq	#0,d0
		move.b	($FFFFFE11).w,d0
		add.w	d0,d0
		move.w	DynWater_Index(pc,d0.w),d0
		jsr	DynWater_Index(pc,d0.w)
		moveq	#0,d1
		move.b	($FFFFF64C).w,d1
		move.w	($FFFFF64A).w,d0
		sub.w	($FFFFF648).w,d0
		beq.s	locret_3C5A
		bcc.s	loc_3C56
		neg.w	d1

loc_3C56:
		add.w	d1,($FFFFF648).w

locret_3C5A:
		rts
; ===========================================================================
DynWater_Index:	dc.w DynWater_LZ1-DynWater_Index
		dc.w DynWater_LZ2-DynWater_Index
		dc.w DynWater_LZ3-DynWater_Index
		dc.w DynWater_SBZ3-DynWater_Index
; ===========================================================================

DynWater_LZ1:				; XREF: DynWater_Index
		move.w	($FFFFF700).w,d0
		move.b	($FFFFF64D).w,d2
		bne.s	loc_3CD0
		move.w	#$B8,d1
		cmpi.w	#$600,d0
		bcs.s	loc_3CB4
		move.w	#$108,d1
		cmpi.w	#$200,($FFFFD00C).w
		bcs.s	loc_3CBA
		cmpi.w	#$C00,d0
		bcs.s	loc_3CB4
		move.w	#$318,d1
		cmpi.w	#$1080,d0
		bcs.s	loc_3CB4
		move.b	#-$80,($FFFFF7E5).w
		move.w	#$5C8,d1
		cmpi.w	#$1380,d0
		bcs.s	loc_3CB4
		move.w	#$3A8,d1
		cmp.w	($FFFFF648).w,d1
		bne.s	loc_3CB4
		move.b	#1,($FFFFF64D).w

loc_3CB4:
		move.w	d1,($FFFFF64A).w
		rts
; ===========================================================================

loc_3CBA:				; XREF: DynWater_LZ1
		cmpi.w	#$C80,d0
		bcs.s	loc_3CB4
		move.w	#$E8,d1
		cmpi.w	#$1500,d0
		bcs.s	loc_3CB4
		move.w	#$108,d1
		bra.s	loc_3CB4
; ===========================================================================

loc_3CD0:				; XREF: DynWater_LZ1
		subq.b	#1,d2
		bne.s	locret_3CF4
		cmpi.w	#$2E0,($FFFFD00C).w
		bcc.s	locret_3CF4
		move.w	#$3A8,d1
		cmpi.w	#$1300,d0
		bcs.s	loc_3CF0
		move.w	#$108,d1
		move.b	#2,($FFFFF64D).w

loc_3CF0:
		move.w	d1,($FFFFF64A).w

locret_3CF4:
		rts
; ===========================================================================

DynWater_LZ2:				; XREF: DynWater_Index
		move.w	($FFFFF700).w,d0
		move.w	#$328,d1
		cmpi.w	#$500,d0
		bcs.s	loc_3D12
		move.w	#$3C8,d1
		cmpi.w	#$B00,d0
		bcs.s	loc_3D12
		move.w	#$428,d1

loc_3D12:
		move.w	d1,($FFFFF64A).w
		rts
; ===========================================================================

DynWater_LZ3:				; XREF: DynWater_Index
		move.w	($FFFFF700).w,d0
		move.b	($FFFFF64D).w,d2
		bne.s	loc_3D5E
		move.w	#$900,d1
		cmpi.w	#$600,d0
		bcs.s	loc_3D54
		cmpi.w	#$3C0,($FFFFD00C).w
		bcs.s	loc_3D54
		cmpi.w	#$600,($FFFFD00C).w
		bcc.s	loc_3D54
		move.w	#$4C8,d1
		move.b	#$4B,($FFFFA506).w ; change level layout
		move.b	#1,($FFFFF64D).w
		moveq	#sfx_Rumble,d0
		bsr.w	PlaySound_Special ; play sound $B7 (rumbling)

loc_3D54:
		move.w	d1,($FFFFF64A).w
		move.w	d1,($FFFFF648).w
		rts
; ===========================================================================

loc_3D5E:				; XREF: DynWater_LZ3
		subq.b	#1,d2
		bne.s	loc_3DA8
		move.w	#$4C8,d1
		cmpi.w	#$770,d0
		bcs.s	loc_3DA2
		move.w	#$308,d1
		cmpi.w	#$1400,d0
		bcs.s	loc_3DA2
		cmpi.w	#$508,($FFFFF64A).w
		beq.s	loc_3D8E
		cmpi.w	#$600,($FFFFD00C).w
		bcc.s	loc_3D8E
		cmpi.w	#$280,($FFFFD00C).w
		bcc.s	loc_3DA2

loc_3D8E:
		move.w	#$508,d1
		move.w	d1,($FFFFF648).w
		cmpi.w	#$1770,d0
		bcs.s	loc_3DA2
		move.b	#2,($FFFFF64D).w

loc_3DA2:
		move.w	d1,($FFFFF64A).w
		rts
; ===========================================================================

loc_3DA8:
		subq.b	#1,d2
		bne.s	loc_3DD2
		move.w	#$508,d1
		cmpi.w	#$1860,d0
		bcs.s	loc_3DCC
		move.w	#$188,d1
		cmpi.w	#$1AF0,d0
		bcc.s	loc_3DC6
		cmp.w	($FFFFF648).w,d1
		bne.s	loc_3DCC

loc_3DC6:
		move.b	#3,($FFFFF64D).w

loc_3DCC:
		move.w	d1,($FFFFF64A).w
		rts
; ===========================================================================

loc_3DD2:
		subq.b	#1,d2
		bne.s	loc_3E0E
		move.w	#$188,d1
		cmpi.w	#$1AF0,d0
		bcs.s	loc_3E04
		move.w	#$900,d1
		cmpi.w	#$1BC0,d0
		bcs.s	loc_3E04
		move.b	#4,($FFFFF64D).w
		move.w	#$608,($FFFFF64A).w
		move.w	#$7C0,($FFFFF648).w
		move.b	#1,($FFFFF7E8).w
		rts
; ===========================================================================

loc_3E04:
		move.w	d1,($FFFFF64A).w
		move.w	d1,($FFFFF648).w
		rts
; ===========================================================================

loc_3E0E:
		cmpi.w	#$1E00,d0
		bcs.s	locret_3E1A
		move.w	#$128,($FFFFF64A).w

locret_3E1A:
		rts
; ===========================================================================

DynWater_SBZ3:				; XREF: DynWater_Index
		move.w	#$228,d1
		cmpi.w	#$F00,($FFFFF700).w
		bcs.s	loc_3E2C
		move.w	#$4C8,d1

loc_3E2C:
		move.w	d1,($FFFFF64A).w
		rts

; ---------------------------------------------------------------------------
; Labyrinth Zone "wind tunnels"	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LZWindTunnels:				; XREF: LZWaterEffects
		tst.w	($FFFFFE08).w	; is debug mode	being used?
		bne.w	locret_3F0A	; if yes, branch
		lea	(LZWind_Data).l,a2
		moveq	#0,d0
		move.b	($FFFFFE11).w,d0
		lsl.w	#3,d0
		adda.w	d0,a2
		moveq	#0,d1
		tst.b	($FFFFFE11).w
		bne.s	loc_3E56
		moveq	#1,d1
		subq.w	#8,a2

loc_3E56:
		lea	($FFFFD000).w,a1

LZWind_Loop:
		move.w	8(a1),d0
		cmp.w	(a2),d0
		bcs.w	loc_3EF4
		cmp.w	4(a2),d0
		bcc.w	loc_3EF4
		move.w	$C(a1),d2
		cmp.w	2(a2),d2
		bcs.s	loc_3EF4
		cmp.w	6(a2),d2
		bcc.s	loc_3EF4
	;	move.b	($FFFFFE0F).w,d0
	;	andi.b	#$3F,d0
	;	bne.s	loc_3E90
	;	move.w	#$D0,d0
	;	jsr	(PlaySound_Special).l ;	play rushing water sound

loc_3E90:
		tst.b	($FFFFF7C9).w
		bne.w	locret_3F0A
		cmpi.b	#4,$24(a1)
		bcc.s	loc_3F06
		move.b	#1,($FFFFF7C7).w
		subi.w	#$80,d0
		cmp.w	(a2),d0
		bcc.s	LZWind_Move
		moveq	#2,d0
		cmpi.b	#1,($FFFFFE11).w
		bne.s	loc_3EBA
		neg.w	d0

loc_3EBA:
		add.w	d0,$C(a1)

LZWind_Move:
		addq.w	#4,8(a1)
		move.w	#$400,$10(a1)	; move Sonic horizontally
		move.w	#0,$12(a1)
		move.b	#$F,$1C(a1)	; use floating animation
		bset	#1,$22(a1)
		btst	#0,($FFFFF602).w ; is up pressed?
		beq.s	LZWind_MoveDown	; if not, branch
		subq.w	#1,$C(a1)	; move Sonic up

LZWind_MoveDown:
		btst	#1,($FFFFF602).w ; is down being pressed?
		beq.s	locret_3EF2	; if not, branch
		addq.w	#1,$C(a1)	; move Sonic down

locret_3EF2:
		rts
; ===========================================================================

loc_3EF4:				; XREF: LZWindTunnels
		addq.w	#8,a2
		dbf	d1,LZWind_Loop
		tst.b	($FFFFF7C7).w
		beq.s	locret_3F0A
		move.b	#0,$1C(a1)

loc_3F06:
		clr.b	($FFFFF7C7).w

locret_3F0A:
		rts
; End of function LZWindTunnels

; ===========================================================================
		dc.w $A80, $300, $C10, $380
LZWind_Data:	dc.w $F80, $100, $1410,	$180, $460, $400, $710,	$480, $A20
		dc.w $600, $1610, $6E0,	$C80, $600, $13D0, $680
					; XREF: LZWindTunnels
		even

; ---------------------------------------------------------------------------
; Labyrinth Zone water slide subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LZWaterSlides:				; XREF: LZWaterEffects
		lea	($FFFFD000).w,a1
		btst	#1,$22(a1)
		bne.s	loc_3F6A
		move.w	$C(a1),d0
		lsr.w	#1,d0
		andi.w	#$380,d0
		move.b	8(a1),d1
		andi.w	#$7F,d1
		add.w	d1,d0
		lea	($FFFFA400).w,a2
		move.b	(a2,d0.w),d0
		lea	byte_3FCF(pc),a2
		moveq	#6,d1

loc_3F62:
		cmp.b	-(a2),d0
		dbeq	d1,loc_3F62
		beq.s	LZSlide_Move

loc_3F6A:
		tst.b	($FFFFF7CA).w
		beq.s	locret_3F7A
		move.w	#5,$3E(a1)
		clr.b	($FFFFF7CA).w

locret_3F7A:
		rts
; ===========================================================================

LZSlide_Move:				; XREF: LZWaterSlides
		cmpi.w	#3,d1
		bcc.s	loc_3F84
		nop

loc_3F84:
		bclr	#0,$22(a1)
		move.b	byte_3FC0(pc,d1.w),d0
		move.b	d0,$14(a1)
		bpl.s	loc_3F9A
		bset	#0,$22(a1)

loc_3F9A:
		clr.b	$15(a1)
		move.b	#$1B,$1C(a1)	; use Sonic's "sliding" animation
		move.b	#1,($FFFFF7CA).w ; lock	controls (except jumping)
	;	move.b	($FFFFFE0F).w,d0
	;	andi.b	#$1F,d0
	;	bne.s	locret_3FBE
	;	move.w	#$D0,d0
	;	jsr	(PlaySound_Special).l ;	play water sound

locret_3FBE:
		rts
; End of function LZWaterSlides

; ===========================================================================
byte_3FC0:	dc.b $A, $F5, $A, $F6, $F5, $F4, $B, 0,	2, 7, 3, $4C, $4B, 8, 4
byte_3FCF:	dc.b 0			; XREF: LZWaterSlides
		even

; ---------------------------------------------------------------------------
; Subroutine to	move Sonic in demo mode
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MoveSonicInDemo:			; XREF: Level_MainLoop; et al
		tst.w	($FFFFFFF0).w	; is demo mode on?
		bne.s	MoveDemo_On	; if yes, branch
		rts
; ===========================================================================

; This is an unused subroutine for recording a demo

MoveDemo_Record:
		lea	($80000).l,a1
		move.w	($FFFFF790).w,d0
		adda.w	d0,a1
		move.b	($FFFFF604).w,d0
		cmp.b	(a1),d0
		bne.s	loc_3FFA
		addq.b	#1,1(a1)
		cmpi.b	#$FF,1(a1)
		beq.s	loc_3FFA
		rts
; ===========================================================================

loc_3FFA:				; XREF: MoveDemo_Record
		move.b	d0,2(a1)
		move.b	#0,3(a1)
		addq.w	#2,($FFFFF790).w
		andi.w	#$3FF,($FFFFF790).w
		rts
; ===========================================================================

MoveDemo_On:				; XREF: MoveSonicInDemo
		tst.b	($FFFFF604).w
		bpl.s	loc_4022
		tst.w	($FFFFFFF0).w
		bmi.s	loc_4022
		move.b	#4,($FFFFF600).w

loc_4022:
		lea	(Demo_Index).l,a1
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		cmpi.b	#$10,($FFFFF600).w
		bne.s	loc_4038
		moveq	#6,d0

loc_4038:
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		tst.w	($FFFFFFF0).w
		bpl.s	loc_4056
		lea	(Demo_EndIndex).l,a1
		move.w	($FFFFFFF4).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1

loc_4056:
		move.w	($FFFFF790).w,d0
		adda.w	d0,a1
		move.b	(a1),d0
		lea	($FFFFF604).w,a0
		move.b	d0,d1
		move.b	(a0),d2
		eor.b	d2,d0
		move.b	d1,(a0)+
		and.b	d1,d0
		move.b	d0,(a0)+
		subq.b	#1,($FFFFF792).w
		bcc.s	locret_407E
		move.b	3(a1),($FFFFF792).w
		addq.w	#2,($FFFFF790).w

locret_407E:
		rts
; End of function MoveSonicInDemo

; ===========================================================================
; ---------------------------------------------------------------------------
; Demo sequence	pointers
; ---------------------------------------------------------------------------
Demo_Index:
	include "_inc\Demo pointers for intro.asm"

Demo_EndIndex:
	include "_inc\Demo pointers for ending.asm"

		dc.b 0,	$8B, 8,	$37, 0,	$42, 8,	$5C, 0,	$6A, 8,	$5F, 0,	$2F, 8,	$2C
		dc.b 0,	$21, 8,	3, $28,	$30, 8,	8, 0, $2E, 8, $15, 0, $F, 8, $46
		dc.b 0,	$1A, 8,	$FF, 8,	$CA, 0,	0, 0, 0, 0, 0, 0, 0, 0,	0
		even

; ---------------------------------------------------------------------------
; Collision index loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ColIndexLoad:				; XREF: Level
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		lsl.w	#2,d0
		move.l	ColPointers(pc,d0.w),($FFFFF796).w
		rts
; End of function ColIndexLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Collision index pointers
; ---------------------------------------------------------------------------
ColPointers:
	include "_inc\Collision index pointers.asm"

; ---------------------------------------------------------------------------
; Oscillating number subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


OscillateNumInit:			; XREF: Level
		lea	($FFFFFE5E).w,a1
		lea	(Osc_Data).l,a2
		moveq	#$20,d1

Osc_Loop:
		move.w	(a2)+,(a1)+
		dbf	d1,Osc_Loop
		rts
; End of function OscillateNumInit

; ===========================================================================
Osc_Data:	dc.w $7C, $80		; baseline values
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$50F0
		dc.w $11E, $2080
		dc.w $B4, $3080
		dc.w $10E, $5080
		dc.w $1C2, $7080
		dc.w $276, $80
		dc.w 0,	$80
		dc.w 0
		even

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


OscillateNumDo:				; XREF: Level
		cmpi.b	#6,($FFFFD024).w
		bcc.s	locret_41C4
		lea	($FFFFFE5E).w,a1
		lea	(Osc_Data2).l,a2
		move.w	(a1)+,d3
		moveq	#$F,d1

loc_4184:
		move.w	(a2)+,d2
		move.w	(a2)+,d4
		btst	d1,d3
		bne.s	loc_41A4
		move.w	2(a1),d0
		add.w	d2,d0
		move.w	d0,2(a1)
		add.w	d0,0(a1)
		cmp.b	0(a1),d4
		bhi.s	loc_41BA
		bset	d1,d3
		bra.s	loc_41BA
; ===========================================================================

loc_41A4:				; XREF: OscillateNumDo
		move.w	2(a1),d0
		sub.w	d2,d0
		move.w	d0,2(a1)
		add.w	d0,0(a1)
		cmp.b	0(a1),d4
		bls.s	loc_41BA
		bclr	d1,d3

loc_41BA:
		addq.w	#4,a1
		dbf	d1,loc_4184
		move.w	d3,($FFFFFE5E).w

locret_41C4:
		rts
; End of function OscillateNumDo

; ===========================================================================
Osc_Data2:	dc.w 2,	$10		; XREF: OscillateNumDo
		dc.w 2,	$18
		dc.w 2,	$20
		dc.w 2,	$30
		dc.w 4,	$20
		dc.w 8,	8
		dc.w 8,	$40
		dc.w 4,	$40
		dc.w 2,	$50
		dc.w 2,	$50
		dc.w 2,	$20
		dc.w 3,	$30
		dc.w 5,	$50
		dc.w 7,	$70
		dc.w 2,	$10
		dc.w 2,	$10
		even

; ---------------------------------------------------------------------------
; Subroutine to	change object animation	variables (rings, giant	rings)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ChangeRingFrame:			; XREF: Level
		subq.b	#1,($FFFFFEC0).w
		bpl.s	loc_421C
		move.b	#$B,($FFFFFEC0).w
		subq.b	#1,($FFFFFEC1).w
		andi.b	#7,($FFFFFEC1).w

loc_421C:
		subq.b	#1,($FFFFFEC2).w
		bpl.s	loc_4232
		move.b	#7,($FFFFFEC2).w
		addq.b	#1,($FFFFFEC3).w
		andi.b	#3,($FFFFFEC3).w

loc_4232:
		subq.b	#1,($FFFFFEC4).w
		bpl.s	loc_4250
		move.b	#7,($FFFFFEC4).w
		addq.b	#1,($FFFFFEC5).w
		cmpi.b	#6,($FFFFFEC5).w
		bcs.s	loc_4250
		move.b	#0,($FFFFFEC5).w

loc_4250:
		tst.b	($FFFFFEC6).w
		beq.s	locret_4272
		moveq	#0,d0
		move.b	($FFFFFEC6).w,d0
		add.w	($FFFFFEC8).w,d0
		move.w	d0,($FFFFFEC8).w
		rol.w	#7,d0
		andi.w	#3,d0
		move.b	d0,($FFFFFEC7).w
		subq.b	#1,($FFFFFEC6).w

locret_4272:
		rts
; End of function ChangeRingFrame

; ---------------------------------------------------------------------------
; End-of-act signpost pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SignpostArtLoad:			; XREF: Level
		tst.w	($FFFFFE08).w	; is debug mode	being used?
		bne.w	Signpost_Exit	; if yes, branch
		cmpi.b	#2,($FFFFFE11).w ; is act number 02 (act 3)?
		beq.s	Signpost_Exit	; if yes, branch
		move.w	($FFFFF700).w,d0
		move.w	($FFFFF72A).w,d1
		subi.w	#$100,d1
		cmp.w	d1,d0		; has Sonic reached the	edge of	the level?
		blt.s	Signpost_Exit	; if not, branch
		tst.b	($FFFFFE1E).w
		beq.s	Signpost_Exit
		cmp.w	($FFFFF728).w,d1
		beq.s	Signpost_Exit
		move.w	d1,($FFFFF728).w ; move	left boundary to current screen	position
		moveq	#$12,d0
		bra.w	LoadPLC2	; load signpost	patterns
; ===========================================================================

Signpost_Exit:
		rts
; End of function SignpostArtLoad

; ===========================================================================
Demo_GHZ:	incbin	demodata\i_ghz.bin
Demo_MZ:	incbin	demodata\i_mz.bin
Demo_SYZ:	incbin	demodata\i_syz.bin
Demo_SS:	incbin	demodata\i_ss.bin
; ===========================================================================

; ---------------------------------------------------------------------------
; Special Stage
; ---------------------------------------------------------------------------

SpecialStage:				; XREF: GameModeArray
		moveq	#sfx_EnterSS,d0
		bsr.w	PlaySound_Special ; play special stage entry sound
		moveq	#Mus_Reset,d0
		bsr.w	PlaySound_Special2	 ; fade reset music

		bsr.w	Pal_MakeFlash
		move	#$2700,sr
		lea	($C00004).l,a6
		move.w	#$8B03,(a6)
		move.w	#$8004,(a6)
		move.w	#$8AAF,($FFFFF624).w
		move.w	#$9011,(a6)
		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		bsr.w	ClearScreen
		move	#$2300,sr
		lea	($C00004).l,a5
		move.w	#$8F01,(a5)
		move.l	#$946F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$50000081,(a5)
		move.w	#0,($C00000).l

loc_463C:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_463C
		move.w	#$8F02,(a5)
		bsr.w	SS_BGLoad
		moveq	#$14,d0
		bsr.w	RunPLC_ROM	; load special stage patterns
		lea	($FFFFD000).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

SS_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,SS_ClrObjRam	; clear	the object RAM

		lea	($FFFFF700).w,a1
		moveq	#0,d0
		move.w	#$3F,d1

SS_ClrRam:
		move.l	d0,(a1)+
		dbf	d1,SS_ClrRam	; clear	variables

		lea	($FFFFFE60).w,a1
		moveq	#0,d0
		move.w	#$27,d1

SS_ClrRam2:
		move.l	d0,(a1)+
		dbf	d1,SS_ClrRam2	; clear	variables

		lea	($FFFFAA00).w,a1
		moveq	#0,d0
		move.w	#$7F,d1

SS_ClrNemRam:
		move.l	d0,(a1)+
		dbf	d1,SS_ClrNemRam	; clear	Nemesis	buffer

		clr.b	($FFFFF64E).w
		clr.w	($FFFFFE02).w
		moveq	#$A,d0
		bsr.w	PalLoad1	; load special stage pallet
		jsr	SS_Load
		move.l	#0,($FFFFF700).w
		move.l	#0,($FFFFF704).w
		move.b	#9,($FFFFD000).w ; load	special	stage Sonic object
		bsr.w	PalCycle_SS
		clr.w	($FFFFF780).w	; set stage angle to "upright"
		move.w	#$40,($FFFFF782).w ; set stage rotation	speed
		moveq	#mus_SS,d0
		bsr.w	PlaySound	; play special stage BG	music
		move.w	#0,($FFFFF790).w
		lea	(Demo_Index).l,a1
		moveq	#6,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		move.b	1(a1),($FFFFF792).w
		subq.b	#1,($FFFFF792).w
		clr.w	($FFFFFE20).w
		clr.b	($FFFFFE1B).w
		move.w	#0,($FFFFFE08).w
		move.w	#1800,($FFFFF614).w
		tst.b	($FFFFFFE2).w	; has debug cheat been entered?
		beq.s	SS_NoDebug	; if not, branch
		btst	#6,($FFFFF604).w ; is A	button pressed?
		beq.s	SS_NoDebug	; if not, branch
		move.b	#1,($FFFFFFFA).w ; enable debug	mode

SS_NoDebug:
		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		bsr.w	Pal_MakeWhite

; ---------------------------------------------------------------------------
; Main Special Stage loop
; ---------------------------------------------------------------------------

SS_MainLoop:
		bsr.w	PauseGame
		move.b	#$A,($FFFFF62A).w
		bsr.w	DelayProgram
		bsr.w	MoveSonicInDemo
		move.w	($FFFFF604).w,($FFFFF602).w
		jsr	ObjectsLoad
		jsr	BuildSprites
		jsr	SS_ShowLayout
		bsr.w	SS_BGAnimate
		tst.w	($FFFFFFF0).w	; is demo mode on?
		beq.s	SS_ChkEnd	; if not, branch
		tst.w	($FFFFF614).w	; is there time	left on	the demo?
		beq.w	SS_ToSegaScreen	; if not, branch

SS_ChkEnd:
		cmpi.b	#$10,($FFFFF600).w ; is	game mode $10 (special stage)?
		beq.w	SS_MainLoop	; if yes, branch

		tst.w	($FFFFFFF0).w	; is demo mode on?
		bne.w	SS_ToSegaScreen	; if yes, branch
		move.b	#$C,($FFFFF600).w ; set	screen mode to $0C (level)
		cmpi.w	#$503,($FFFFFE10).w ; is level number higher than FZ?
		bcs.s	SS_End		; if not, branch
		clr.w	($FFFFFE10).w	; set to GHZ1

SS_End:
		move.w	#60,($FFFFF614).w ; set	delay time to 1	second
		move.w	#$3F,($FFFFF626).w
		clr.w	($FFFFF794).w

SS_EndLoop:
		move.b	#$16,($FFFFF62A).w
		bsr.w	DelayProgram
		bsr.w	MoveSonicInDemo
		move.w	($FFFFF604).w,($FFFFF602).w
		jsr	ObjectsLoad
		jsr	BuildSprites
		jsr	SS_ShowLayout
		bsr.w	SS_BGAnimate
		subq.w	#1,($FFFFF794).w
		bpl.s	loc_47D4
		move.w	#2,($FFFFF794).w
		bsr.w	Pal_ToWhite

loc_47D4:
		tst.w	($FFFFF614).w
		bne.s	SS_EndLoop

		move	#$2700,sr
		lea	($C00004).l,a6
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$9001,(a6)
		bsr.w	ClearScreen
		move.l	#$70000002,($C00004).l
		lea	(Nem_TitleCard).l,a0 ; load title card patterns
		bsr.w	NemDec
		jsr	Hud_Base
		move	#$2300,sr
		moveq	#$11,d0
		bsr.w	PalLoad2	; load results screen pallet
		moveq	#0,d0
		bsr.w	LoadPLC2
		moveq	#$1B,d0
		bsr.w	LoadPLC		; load results screen patterns
		move.b	#1,($FFFFFE1F).w ; update score	counter
		move.b	#1,($FFFFF7D6).w ; update ring bonus counter
		move.w	($FFFFFE20).w,d0
		mulu.w	#10,d0		; multiply rings by 10
		move.w	d0,($FFFFF7D4).w ; set rings bonus
		moveq	#mus_GotThroughAct,d0
		jsr	(PlaySound_Special).l ;	play end-of-level music
		lea	($FFFFD000).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

SS_EndClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,SS_EndClrObjRam ; clear object RAM

		move.b	#$7E,($FFFFD5C0).w ; load results screen object

SS_NormalExit:
		bsr.w	PauseGame
		move.b	#$C,($FFFFF62A).w
		bsr.w	DelayProgram
		jsr	ObjectsLoad
		jsr	BuildSprites
		bsr.w	RunPLC_RAM
		tst.w	($FFFFFE02).w
		beq.s	SS_NormalExit
		tst.l	($FFFFF680).w
		bne.s	SS_NormalExit
		moveq	#sfx_EnterSS,d0
		bsr.w	PlaySound_Special ; play special stage exit sound
		bsr.w	Pal_MakeFlash
		rts
; ===========================================================================

SS_ToSegaScreen:
		move.b	#0,($FFFFF600).w ; set screen mode to 00 (Sega screen)
		rts

; ---------------------------------------------------------------------------
; Special stage	background loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_BGLoad:				; XREF: SpecialStage
		lea	($FF0000).l,a1
		lea	(Eni_SSBg1).l,a0 ; load	mappings for the birds and fish
		move.w	#$4051,d0
		bsr.w	EniDec
		move.l	#$50000001,d3
		lea	($FF0080).l,a2
		moveq	#6,d7

loc_48BE:
		move.l	d3,d0
		moveq	#3,d6
		moveq	#0,d4
		cmpi.w	#3,d7
		bcc.s	loc_48CC
		moveq	#1,d4

loc_48CC:
		moveq	#7,d5

loc_48CE:
		movea.l	a2,a1
		eori.b	#1,d4
		bne.s	loc_48E2
		cmpi.w	#6,d7
		bne.s	loc_48F2
		lea	($FF0000).l,a1

loc_48E2:
		movem.l	d0-d4,-(sp)
		moveq	#7,d1
		moveq	#7,d2
		bsr.w	ShowVDPGraphics
		movem.l	(sp)+,d0-d4

loc_48F2:
		addi.l	#$100000,d0
		dbf	d5,loc_48CE
		addi.l	#$3800000,d0
		eori.b	#1,d4
		dbf	d6,loc_48CC
		addi.l	#$10000000,d3
		bpl.s	loc_491C
		swap	d3
		addi.l	#$C000,d3
		swap	d3

loc_491C:
		adda.w	#$80,a2
		dbf	d7,loc_48BE
		lea	($FF0000).l,a1
		lea	(Eni_SSBg2).l,a0 ; load	mappings for the clouds
		move.w	#$4000,d0
		bsr.w	EniDec
		lea	($FF0000).l,a1
		move.l	#$40000003,d0
		moveq	#$3F,d1
		moveq	#$1F,d2
		bsr.w	ShowVDPGraphics
		lea	($FF0000).l,a1
		move.l	#$50000003,d0
		moveq	#$3F,d1
		moveq	#$3F,d2
		bsr.w	ShowVDPGraphics
		rts
; End of function SS_BGLoad

; ---------------------------------------------------------------------------
; Pallet cycling routine - special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_SS:				; XREF: loc_DA6; SpecialStage
		tst.w	($FFFFF63A).w
		bne.s	locret_49E6
		subq.w	#1,($FFFFF79C).w
		bpl.s	locret_49E6
		lea	($C00004).l,a6
		move.w	($FFFFF79A).w,d0
		addq.w	#1,($FFFFF79A).w
		andi.w	#$1F,d0
		lsl.w	#2,d0
		lea	(byte_4A3C).l,a0
		adda.w	d0,a0
		move.b	(a0)+,d0
		bpl.s	loc_4992
		move.w	#$1FF,d0

loc_4992:
		move.w	d0,($FFFFF79C).w
		moveq	#0,d0
		move.b	(a0)+,d0
		move.w	d0,($FFFFF7A0).w
		lea	(byte_4ABC).l,a1
		lea	(a1,d0.w),a1
		move.w	#-$7E00,d0
		move.b	(a1)+,d0
		move.w	d0,(a6)
		move.b	(a1),($FFFFF616).w
		move.w	#-$7C00,d0
		move.b	(a0)+,d0
		move.w	d0,(a6)
		move.l	#$40000010,($C00004).l
		move.l	($FFFFF616).w,($C00000).l
		moveq	#0,d0
		move.b	(a0)+,d0
		bmi.s	loc_49E8
		lea	(Pal_SSCyc1).l,a1
		adda.w	d0,a1
		lea	($FFFFFB4E).w,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+

locret_49E6:
		rts
; ===========================================================================

loc_49E8:				; XREF: PalCycle_SS
		move.w	($FFFFF79E).w,d1
		cmpi.w	#$8A,d0
		bcs.s	loc_49F4
		addq.w	#1,d1

loc_49F4:
		mulu.w	#$2A,d1
		lea	(Pal_SSCyc2).l,a1
		adda.w	d1,a1
		andi.w	#$7F,d0
		bclr	#0,d0
		beq.s	loc_4A18
		lea	($FFFFFB6E).w,a2
		move.l	(a1),(a2)+
		move.l	4(a1),(a2)+
		move.l	8(a1),(a2)+

loc_4A18:
		adda.w	#$C,a1
		lea	($FFFFFB5A).w,a2
		cmpi.w	#$A,d0
		bcs.s	loc_4A2E
		subi.w	#$A,d0
		lea	($FFFFFB7A).w,a2

loc_4A2E:
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		adda.w	d0,a1
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		rts
; End of function PalCycle_SS

; ===========================================================================
byte_4A3C:	dc.b 3,	0, 7, $92, 3, 0, 7, $90, 3, 0, 7, $8E, 3, 0, 7,	$8C
					; XREF: PalCycle_SS
		dc.b 3,	0, 7, $8B, 3, 0, 7, $80, 3, 0, 7, $82, 3, 0, 7,	$84
		dc.b 3,	0, 7, $86, 3, 0, 7, $88, 7, 8, 7, 0, 7,	$A, 7, $C
		dc.b $FF, $C, 7, $18, $FF, $C, 7, $18, 7, $A, 7, $C, 7,	8, 7, 0
		dc.b 3,	0, 6, $88, 3, 0, 6, $86, 3, 0, 6, $84, 3, 0, 6,	$82
		dc.b 3,	0, 6, $81, 3, 0, 6, $8A, 3, 0, 6, $8C, 3, 0, 6,	$8E
		dc.b 3,	0, 6, $90, 3, 0, 6, $92, 7, 2, 6, $24, 7, 4, 6,	$30
		dc.b $FF, 6, 6,	$3C, $FF, 6, 6,	$3C, 7,	4, 6, $30, 7, 2, 6, $24
		even
byte_4ABC:	dc.b $10, 1, $18, 0, $18, 1, $20, 0, $20, 1, $28, 0, $28, 1
					; XREF: PalCycle_SS
		even

Pal_SSCyc1:	incbin	pallet\c_ss_1.bin
		even
Pal_SSCyc2:	incbin	pallet\c_ss_2.bin
		even

; ---------------------------------------------------------------------------
; Subroutine to	make the special stage background animated
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_BGAnimate:				; XREF: SpecialStage
		move.w	($FFFFF7A0).w,d0
		bne.s	loc_4BF6
		move.w	#0,($FFFFF70C).w
		move.w	($FFFFF70C).w,($FFFFF618).w

loc_4BF6:
		cmpi.w	#8,d0
		bcc.s	loc_4C4E
		cmpi.w	#6,d0
		bne.s	loc_4C10
		addq.w	#1,($FFFFF718).w
		addq.w	#1,($FFFFF70C).w
		move.w	($FFFFF70C).w,($FFFFF618).w

loc_4C10:
		moveq	#0,d0
		move.w	($FFFFF708).w,d0
		neg.w	d0
		swap	d0
		lea	(byte_4CCC).l,a1
		lea	($FFFFAA00).w,a3
		moveq	#9,d3

loc_4C26:
		move.w	2(a3),d0
		bsr.w	CalcSine
		moveq	#0,d2
		move.b	(a1)+,d2
		muls.w	d2,d0
		asr.l	#8,d0
		move.w	d0,(a3)+
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d2,(a3)+
		dbf	d3,loc_4C26
		lea	($FFFFAA00).w,a3
		lea	(byte_4CB8).l,a2
		bra.s	loc_4C7E
; ===========================================================================

loc_4C4E:				; XREF: SS_BGAnimate
		cmpi.w	#$C,d0
		bne.s	loc_4C74
		subq.w	#1,($FFFFF718).w
		lea	($FFFFAB00).w,a3
		move.l	#$18000,d2
		moveq	#6,d1

loc_4C64:
		move.l	(a3),d0
		sub.l	d2,d0
		move.l	d0,(a3)+
		subi.l	#$2000,d2
		dbf	d1,loc_4C64

loc_4C74:
		lea	($FFFFAB00).w,a3
		lea	(byte_4CC4).l,a2

loc_4C7E:
		lea	($FFFFCC00).w,a1
		move.w	($FFFFF718).w,d0
		neg.w	d0
		swap	d0
		moveq	#0,d3
		move.b	(a2)+,d3
		move.w	($FFFFF70C).w,d2
		neg.w	d2
		andi.w	#$FF,d2
		lsl.w	#2,d2

loc_4C9A:
		move.w	(a3)+,d0
		addq.w	#2,a3
		moveq	#0,d1
		move.b	(a2)+,d1
		subq.w	#1,d1

loc_4CA4:
		move.l	d0,(a1,d2.w)
		addq.w	#4,d2
		andi.w	#$3FC,d2
		dbf	d1,loc_4CA4
		dbf	d3,loc_4C9A
		rts
; End of function SS_BGAnimate

; ===========================================================================
byte_4CB8:	dc.b 9,	$28, $18, $10, $28, $18, $10, $30, $18,	8, $10,	0
		even
byte_4CC4:	dc.b 6,	$30, $30, $30, $28, $18, $18, $18
		even
byte_4CCC:	dc.b 8,	2, 4, $FF, 2, 3, 8, $FF, 4, 2, 2, 3, 8,	$FD, 4,	2, 2, 3, 2, $FF
		even
					; XREF: SS_BGAnimate
; ===========================================================================

; ---------------------------------------------------------------------------
; Continue screen
; ---------------------------------------------------------------------------

ContinueScreen:				; XREF: GameModeArray
		bsr.w	Pal_FadeFrom
		move	#$2700,sr
		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		lea	($C00004).l,a6
		move.w	#$8004,(a6)
		move.w	#$8700,(a6)
		bsr.w	ClearScreen
		lea	($FFFFD000).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

Cont_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,Cont_ClrObjRam ; clear object RAM

		move.l	#$70000002,($C00004).l
		lea	(Nem_TitleCard).l,a0 ; load title card patterns
		bsr.w	NemDec
		move.l	#$60000002,($C00004).l
		lea	(Nem_ContSonic).l,a0 ; load Sonic patterns
		bsr.w	NemDec
		move.l	#$6A200002,($C00004).l
		lea	(Nem_MiniSonic).l,a0 ; load continue screen patterns
		bsr.w	NemDec
		moveq	#10,d1
		jsr	ContScrCounter	; run countdown	(start from 10)
		moveq	#$12,d0
		bsr.w	PalLoad1	; load continue	screen pallet

		move.b	#$16,($FFFFF62A).w
		bsr.w	DelayProgram
		moveq	#mus_Continue,d0
		bsr.w	PlaySound	; play continue	music

		move.w	#659,($FFFFF614).w ; set time delay to 11 seconds
		clr.l	($FFFFF700).w
		move.l	#$1000000,($FFFFF704).w
		move.b	#$81,($FFFFD000).w ; load Sonic	object
		move.b	#$80,($FFFFD040).w ; load continue screen objects
		move.b	#$80,($FFFFD080).w
		move.b	#3,($FFFFD098).w
		move.b	#4,($FFFFD09A).w
		move.b	#$80,($FFFFD0C0).w
		move.b	#4,($FFFFD0E4).w
		jsr	ObjectsLoad
		jsr	BuildSprites
		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		bsr.w	Pal_FadeTo

; ---------------------------------------------------------------------------
; Continue screen main loop
; ---------------------------------------------------------------------------

Cont_MainLoop:
		move.b	#$16,($FFFFF62A).w
		bsr.w	DelayProgram
		cmpi.b	#6,($FFFFD024).w
		bcc.s	loc_4DF2
		move	#$2700,sr
		move.w	($FFFFF614).w,d1
		divu.w	#$3C,d1
		andi.l	#$F,d1
		jsr	ContScrCounter
		move	#$2300,sr

loc_4DF2:
		jsr	ObjectsLoad
		jsr	BuildSprites
		cmpi.w	#$180,($FFFFD008).w ; has Sonic	run off	screen?
		bcc.s	Cont_GotoLevel	; if yes, branch
		cmpi.b	#6,($FFFFD024).w
		bcc.s	Cont_MainLoop
		tst.w	($FFFFF614).w
		bne.w	Cont_MainLoop
		move.b	#0,($FFFFF600).w ; go to Sega screen
		rts
; ===========================================================================

Cont_GotoLevel:				; XREF: Cont_MainLoop
		move.b	#$C,($FFFFF600).w ; set	screen mode to $0C (level)
		move.b	#3,($FFFFFE12).w ; set lives to	3
		moveq	#0,d0
		move.w	d0,($FFFFFE20).w ; clear rings
		move.l	d0,($FFFFFE22).w ; clear time
		move.l	d0,($FFFFFE26).w ; clear score
		move.b	d0,($FFFFFE30).w ; clear lamppost count
		subq.b	#1,($FFFFFE18).w ; subtract 1 from continues
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Object 80 - Continue screen elements
; ---------------------------------------------------------------------------

Obj80:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj80_Index(pc,d0.w),d1
		jmp	Obj80_Index(pc,d1.w)
; ===========================================================================
Obj80_Index:	dc.w Obj80_Main-Obj80_Index
		dc.w Obj80_Display-Obj80_Index
		dc.w Obj80_MakeMiniSonic-Obj80_Index
		dc.w Obj80_ChkType-Obj80_Index
; ===========================================================================

Obj80_Main:				; XREF: Obj80_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj80,4(a0)
		move.w	#$8500,2(a0)
		move.b	#0,1(a0)
		move.b	#$3C,$19(a0)
		move.w	#$120,8(a0)
		move.w	#$C0,$A(a0)
		move.w	#0,($FFFFFE20).w ; clear rings

Obj80_Display:				; XREF: Obj80_Index
		jmp	DisplaySprite
; ===========================================================================
Obj80_MiniSonicPos:
		dc.w $116, $12A, $102, $13E, $EE, $152, $DA, $166, $C6
		dc.w $17A, $B2,	$18E, $9E, $1A2, $8A
; ===========================================================================

Obj80_MakeMiniSonic:			; XREF: Obj80_Index
		movea.l	a0,a1
		lea	(Obj80_MiniSonicPos).l,a2
		moveq	#0,d1
		move.b	($FFFFFE18).w,d1
		subq.b	#2,d1
		bcc.s	loc_4EC4
		jmp	DeleteObject
; ===========================================================================

loc_4EC4:				; XREF: Obj80_MakeMiniSonic
		moveq	#1,d3
		cmpi.b	#$E,d1
		bcs.s	loc_4ED0
		moveq	#0,d3
		moveq	#$E,d1

loc_4ED0:
		move.b	d1,d2
		andi.b	#1,d2

Obj80_MiniSonLoop:
		move.b	#$80,0(a1)	; load mini Sonic object
		move.w	(a2)+,8(a1)
		tst.b	d2
		beq.s	loc_4EEA
		subi.w	#$A,8(a1)

loc_4EEA:
		move.w	#$D0,$A(a1)
		move.b	#6,$1A(a1)
		move.b	#6,$24(a1)
		move.l	#Map_obj80,4(a1)
		move.w	#$8551,2(a1)
		move.b	#0,1(a1)
		lea	$40(a1),a1
		dbf	d1,Obj80_MiniSonLoop ; repeat for number of continues
		lea	-$40(a1),a1
		move.b	d3,$28(a1)

Obj80_ChkType:				; XREF: Obj80_Index
		tst.b	$28(a0)
		beq.s	loc_4F40
		cmpi.b	#6,($FFFFD024).w
		bcs.s	loc_4F40
		move.b	($FFFFFE0F).w,d0
		andi.b	#1,d0
		bne.s	loc_4F40
		tst.w	($FFFFD010).w
		bne.s	Obj80_Delete
		rts
; ===========================================================================

loc_4F40:				; XREF: Obj80_ChkType
		move.b	($FFFFFE0F).w,d0
		andi.b	#$F,d0
		bne.s	Obj80_Display2
		bchg	#0,$1A(a0)

Obj80_Display2:
		jmp	DisplaySprite
; ===========================================================================

Obj80_Delete:				; XREF: Obj80_ChkType
		jmp	DeleteObject
; ===========================================================================

; ---------------------------------------------------------------------------
; Object 81 - Sonic on the continue screen
; ---------------------------------------------------------------------------

Obj81:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj81_Index(pc,d0.w),d1
		jsr	Obj81_Index(pc,d1.w)
		jmp	DisplaySprite
; ===========================================================================
Obj81_Index:	dc.w Obj81_Main-Obj81_Index
		dc.w Obj81_ChkLand-Obj81_Index
		dc.w Obj81_Animate-Obj81_Index
		dc.w Obj81_Run-Obj81_Index
; ===========================================================================

Obj81_Main:				; XREF: Obj81_Index
		addq.b	#2,$24(a0)
		move.w	#$A0,8(a0)
		move.w	#$C0,$C(a0)
		move.l	#Map_Sonic,4(a0)
		move.w	#$780,2(a0)
		move.b	#4,1(a0)
		move.b	#2,$18(a0)
		move.b	#$1D,$1C(a0)	; use "floating" animation
		move.w	#$400,$12(a0)	; make Sonic fall from above

Obj81_ChkLand:				; XREF: Obj81_Index
		cmpi.w	#$1A0,$C(a0)	; has Sonic landed yet?
		bne.s	Obj81_ShowFall	; if not, branch
		addq.b	#2,$24(a0)
		clr.w	$12(a0)		; stop Sonic falling
		move.l	#Map_obj80,4(a0)
		move.w	#$8500,2(a0)
		move.b	#0,$1C(a0)
		bra.s	Obj81_Animate
; ===========================================================================

Obj81_ShowFall:				; XREF: Obj81_ChkLand
		jsr	SpeedToPos
		jsr	Sonic_Animate
		jmp	LoadSonicDynPLC
; ===========================================================================

Obj81_Animate:				; XREF: Obj81_Index
		tst.b	($FFFFF605).w	; is any button	pressed?
		bmi.s	Obj81_GetUp	; if yes, branch
		lea	(Ani_obj81).l,a1
		jmp	AnimateSprite
; ===========================================================================

Obj81_GetUp:				; XREF: Obj81_Animate
		addq.b	#2,$24(a0)
		move.l	#Map_Sonic,4(a0)
		move.w	#$780,2(a0)
		move.b	#$1E,$1C(a0)	; use "getting up" animation
		clr.w	$14(a0)
		subq.w	#8,$C(a0)
		moveq	#Mus_FadeOut,d0
		bsr.w	PlaySound_Special ; fade out music

Obj81_Run:				; XREF: Obj81_Index
		cmpi.w	#$800,$14(a0)	; check	Sonic's "run speed" (not moving)
		bne.s	Obj81_AddSpeed	; if too low, branch
		move.w	#$1000,$10(a0)	; move Sonic to	the right
		bra.s	Obj81_ShowRun
; ===========================================================================

Obj81_AddSpeed:				; XREF: Obj81_Run
		addi.w	#$20,$14(a0)	; increase "run	speed"

Obj81_ShowRun:				; XREF: Obj81_Run
		jsr	SpeedToPos
		jsr	Sonic_Animate
		jmp	LoadSonicDynPLC
; ===========================================================================
Ani_obj81:
	include "_anim\obj81.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Continue screen
; ---------------------------------------------------------------------------
Map_obj80:
	include "_maps\obj80.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Ending sequence in Green Hill	Zone
; ---------------------------------------------------------------------------

EndingSequence:				; XREF: GameModeArray
		moveq	#Mus_Stop,d0
		bsr.w	PlaySound_Special ; stop music
		bsr.w	Pal_FadeFrom
		lea	($FFFFD000).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

End_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,End_ClrObjRam ; clear object	RAM

		lea	($FFFFF628).w,a1
		moveq	#0,d0
		move.w	#$15,d1

End_ClrRam:
		move.l	d0,(a1)+
		dbf	d1,End_ClrRam	; clear	variables

		lea	($FFFFF700).w,a1
		moveq	#0,d0
		move.w	#$3F,d1

End_ClrRam2:
		move.l	d0,(a1)+
		dbf	d1,End_ClrRam2	; clear	variables

		lea	($FFFFFE60).w,a1
		moveq	#0,d0
		move.w	#$47,d1

End_ClrRam3:
		move.l	d0,(a1)+
		dbf	d1,End_ClrRam3	; clear	variables

		move	#$2700,sr
		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		bsr.w	ClearScreen
		lea	($C00004).l,a6
		move.w	#$8B03,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$857C,(a6)
		move.w	#$9001,(a6)
		move.w	#$8004,(a6)
		move.w	#$8720,(a6)
		move.w	#$8ADF,($FFFFF624).w
		move.w	($FFFFF624).w,(a6)
		move.w	#$1E,($FFFFFE14).w
		move.w	#$600,($FFFFFE10).w ; set level	number to 0600 (extra flowers)
		cmpi.b	#6,($FFFFFE57).w ; do you have all 6 emeralds?
		beq.s	End_LoadData	; if yes, branch
		move.w	#$601,($FFFFFE10).w ; set level	number to 0601 (no flowers)

End_LoadData:
		moveq	#$1C,d0
		bsr.w	RunPLC_ROM	; load ending sequence patterns
		jsr	Hud_Base
		bsr.w	LevelSizeLoad
		bsr.w	DeformBgLayer
		bset	#2,($FFFFF754).w
		bsr.w	MainLoadBlockLoad
		bsr.w	LoadTilesFromStart
		move.l	#Col_GHZ,($FFFFF796).w ; load collision	index
		move	#$2300,sr
		lea	(Kos_EndFlowers).l,a0 ;	load extra flower patterns
		lea	($FFFF9400).w,a1 ; RAM address to buffer the patterns
		bsr.w	KosDec
		moveq	#3,d0
		bsr.w	PalLoad1	; load Sonic's pallet
		moveq	#mus_Ending,d0
		bsr.w	PlaySound	; play ending sequence music
		btst	#6,($FFFFF604).w ; is button A pressed?
		beq.s	End_LoadSonic	; if not, branch
		move.b	#1,($FFFFFFFA).w ; enable debug	mode

End_LoadSonic:
		move.b	#1,($FFFFD000).w ; load	Sonic object
		bset	#0,($FFFFD022).w ; make	Sonic face left
		move.b	#1,($FFFFF7CC).w ; lock	controls
		move.w	#$400,($FFFFF602).w ; move Sonic to the	left
		move.w	#$F800,($FFFFD014).w ; set Sonic's speed
		move.b	#$21,($FFFFD040).w ; load HUD object
		jsr	ObjPosLoad
		jsr	ObjectsLoad
		jsr	BuildSprites
		moveq	#0,d0
		move.w	d0,($FFFFFE20).w
		move.l	d0,($FFFFFE22).w
		move.b	d0,($FFFFFE1B).w
		move.b	d0,($FFFFFE2C).w
		move.b	d0,($FFFFFE2D).w
		move.b	d0,($FFFFFE2E).w
		move.b	d0,($FFFFFE2F).w
		move.w	d0,($FFFFFE08).w
		move.w	d0,($FFFFFE02).w
		move.w	d0,($FFFFFE04).w
		bsr.w	OscillateNumInit
		move.b	#1,($FFFFFE1F).w
		move.b	#1,($FFFFFE1D).w
		move.b	#0,($FFFFFE1E).w
		move.w	#1800,($FFFFF614).w
		move.b	#$18,($FFFFF62A).w
		bsr.w	DelayProgram
		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		move.w	#$3F,($FFFFF626).w
		bsr.w	Pal_FadeTo

; ---------------------------------------------------------------------------
; Main ending sequence loop
; ---------------------------------------------------------------------------

End_MainLoop:
		bsr.w	PauseGame
		move.b	#$18,($FFFFF62A).w
		bsr.w	DelayProgram
		addq.w	#1,($FFFFFE04).w
		bsr.w	End_MoveSonic
		jsr	ObjectsLoad
		bsr.w	DeformBgLayer
		jsr	BuildSprites
		jsr	ObjPosLoad
		bsr.w	PalCycle_Load
		bsr.w	OscillateNumDo
		bsr.w	ChangeRingFrame
		cmpi.b	#$18,($FFFFF600).w ; is	scene number $18 (ending)?
		beq.s	loc_52DA	; if yes, branch
		move.b	#$1C,($FFFFF600).w ; set scene to $1C (credits)
		moveq	#mus_Credits,d0
		bsr.w	PlaySound_Special ; play credits music
		move.w	#0,($FFFFFFF4).w ; set credits index number to 0
		rts
; ===========================================================================

loc_52DA:
		tst.w	($FFFFFE02).w	; is level set to restart?
		beq.w	End_MainLoop	; if not, branch

		clr.w	($FFFFFE02).w
		move.w	#$3F,($FFFFF626).w
		clr.w	($FFFFF794).w

End_AllEmlds:				; XREF: loc_5334
		bsr.w	PauseGame
		move.b	#$18,($FFFFF62A).w
		bsr.w	DelayProgram
		addq.w	#1,($FFFFFE04).w
		bsr.w	End_MoveSonic
		jsr	ObjectsLoad
		bsr.w	DeformBgLayer
		jsr	BuildSprites
		jsr	ObjPosLoad
		bsr.w	OscillateNumDo
		bsr.w	ChangeRingFrame
		subq.w	#1,($FFFFF794).w
		bpl.s	loc_5334
		move.w	#2,($FFFFF794).w
		bsr.w	Pal_ToWhite

loc_5334:
		tst.w	($FFFFFE02).w
		beq.w	End_AllEmlds
		clr.w	($FFFFFE02).w
		move.w	#$2E2F,($FFFFA480).w ; modify level layout
		lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	($FFFFF700).w,a3
		lea	($FFFFA400).w,a4
		move.w	#$4000,d2
		bsr.w	LoadTilesFromStart2
		moveq	#$13,d0
		bsr.w	PalLoad1	; load ending pallet
		bsr.w	Pal_MakeWhite
		bra.w	End_MainLoop

; ---------------------------------------------------------------------------
; Subroutine controlling Sonic on the ending sequence
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


End_MoveSonic:				; XREF: End_MainLoop
		move.b	($FFFFF7D7).w,d0
		bne.s	End_MoveSonic2
		cmpi.w	#$90,($FFFFD008).w ; has Sonic passed $90 on y-axis?
		bcc.s	End_MoveSonExit	; if not, branch
		addq.b	#2,($FFFFF7D7).w
		move.b	#1,($FFFFF7CC).w ; lock	player's controls
		move.w	#$800,($FFFFF602).w ; move Sonic to the	right
		rts
; ===========================================================================

End_MoveSonic2:				; XREF: End_MoveSonic
		subq.b	#2,d0
		bne.s	End_MoveSonic3
		cmpi.w	#$A0,($FFFFD008).w ; has Sonic passed $A0 on y-axis?
		bcs.s	End_MoveSonExit	; if not, branch
		addq.b	#2,($FFFFF7D7).w
		moveq	#0,d0
		move.b	d0,($FFFFF7CC).w
		move.w	d0,($FFFFF602).w ; stop	Sonic moving
		move.w	d0,($FFFFD014).w
		move.b	#$81,($FFFFF7C8).w
		move.b	#3,($FFFFD01A).w
		move.w	#$505,($FFFFD01C).w ; use "standing" animation
		move.b	#3,($FFFFD01E).w
		rts
; ===========================================================================

End_MoveSonic3:				; XREF: End_MoveSonic
		subq.b	#2,d0
		bne.s	End_MoveSonExit
		addq.b	#2,($FFFFF7D7).w
		move.w	#$A0,($FFFFD008).w
		move.b	#$87,($FFFFD000).w ; load Sonic	ending sequence	object
		clr.w	($FFFFD024).w

End_MoveSonExit:
		rts
; End of function End_MoveSonic

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 87 - Sonic on ending sequence
; ---------------------------------------------------------------------------

Obj87:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj87_Index(pc,d0.w),d1
		jsr	Obj87_Index(pc,d1.w)
		jmp	DisplaySprite
; ===========================================================================
Obj87_Index:	dc.w Obj87_Main-Obj87_Index, Obj87_MakeEmlds-Obj87_Index
		dc.w Obj87_Animate-Obj87_Index,	Obj87_LookUp-Obj87_Index
		dc.w Obj87_ClrObjRam-Obj87_Index, Obj87_Animate-Obj87_Index
		dc.w Obj87_MakeLogo-Obj87_Index, Obj87_Animate-Obj87_Index
		dc.w Obj87_Leap-Obj87_Index, Obj87_Animate-Obj87_Index
; ===========================================================================

Obj87_Main:				; XREF: Obj87_Index
		cmpi.b	#6,($FFFFFE57).w ; do you have all 6 emeralds?
		beq.s	Obj87_Main2	; if yes, branch
		addi.b	#$10,$25(a0)	; else,	skip emerald sequence
		move.w	#$D8,$30(a0)
		rts
; ===========================================================================

Obj87_Main2:				; XREF: Obj87_Main
		addq.b	#2,$25(a0)
		move.l	#Map_obj87,4(a0)
		move.w	#$3E1,2(a0)
		move.b	#4,1(a0)
		clr.b	$22(a0)
		move.b	#2,$18(a0)
		move.b	#0,$1A(a0)
		move.w	#$50,$30(a0)	; set duration for Sonic to pause

Obj87_MakeEmlds:			; XREF: Obj87_Index
		subq.w	#1,$30(a0)	; subtract 1 from duration
		bne.s	Obj87_Wait
		addq.b	#2,$25(a0)
		move.w	#1,$1C(a0)
		move.b	#$88,($FFFFD400).w ; load chaos	emeralds objects

Obj87_Wait:
		rts
; ===========================================================================

Obj87_LookUp:				; XREF: Obj87_Index
		cmpi.w	#$2000,($FFD43C).l
		bne.s	locret_5480
		move.w	#1,($FFFFFE02).w ; set level to	restart	(causes	flash)
		move.w	#$5A,$30(a0)
		addq.b	#2,$25(a0)

locret_5480:
		rts
; ===========================================================================

Obj87_ClrObjRam:			; XREF: Obj87_Index
		subq.w	#1,$30(a0)
		bne.s	Obj87_Wait2
		lea	($FFFFD400).w,a1
		move.w	#$FF,d1

Obj87_ClrLoop:
		clr.l	(a1)+
		dbf	d1,Obj87_ClrLoop ; clear the object RAM
		move.w	#1,($FFFFFE02).w
		addq.b	#2,$25(a0)
		move.b	#1,$1C(a0)
		move.w	#$3C,$30(a0)

Obj87_Wait2:
		rts
; ===========================================================================

Obj87_MakeLogo:				; XREF: Obj87_Index
		subq.w	#1,$30(a0)
		bne.s	Obj87_Wait3
		addq.b	#2,$25(a0)
		move.w	#$B4,$30(a0)
		move.b	#2,$1C(a0)
		move.b	#$89,($FFFFD400).w ; load "SONIC THE HEDGEHOG" object

Obj87_Wait3:
		rts
; ===========================================================================

Obj87_Animate:				; XREF: Obj87_Index
		lea	(Ani_obj87).l,a1
		jmp	AnimateSprite
; ===========================================================================

Obj87_Leap:				; XREF: Obj87_Index
		subq.w	#1,$30(a0)
		bne.s	Obj87_Wait4
		addq.b	#2,$25(a0)
		move.l	#Map_obj87,4(a0)
		move.w	#$3E1,2(a0)
		move.b	#4,1(a0)
		clr.b	$22(a0)
		move.b	#2,$18(a0)
		move.b	#5,$1A(a0)
		move.b	#2,$1C(a0)	; use "leaping"	animation
		move.b	#$89,($FFFFD400).w ; load "SONIC THE HEDGEHOG" object
		bra.s	Obj87_Animate
; ===========================================================================

Obj87_Wait4:				; XREF: Obj87_Leap
		rts
; ===========================================================================
Ani_obj87:
	include "_anim\obj87.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 88 - chaos emeralds on	the ending sequence
; ---------------------------------------------------------------------------

Obj88:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj88_Index(pc,d0.w),d1
		jsr	Obj88_Index(pc,d1.w)
		jmp	DisplaySprite
; ===========================================================================
Obj88_Index:	dc.w Obj88_Main-Obj88_Index
		dc.w Obj88_Move-Obj88_Index
; ===========================================================================

Obj88_Main:				; XREF: Obj88_Index
		cmpi.b	#2,($FFFFD01A).w
		beq.s	Obj88_Main2
		addq.l	#4,sp
		rts
; ===========================================================================

Obj88_Main2:				; XREF: Obj88_Main
		move.w	($FFFFD008).w,8(a0) ; match X position with Sonic
		move.w	($FFFFD00C).w,$C(a0) ; match Y position	with Sonic
		movea.l	a0,a1
		moveq	#0,d3
		moveq	#1,d2
		moveq	#5,d1

Obj88_MainLoop:
		move.b	#$88,(a1)	; load chaos emerald object
		addq.b	#2,$24(a1)
		move.l	#Map_obj88,4(a1)
		move.w	#$3C5,2(a1)
		move.b	#4,1(a1)
		move.b	#1,$18(a1)
		move.w	8(a0),$38(a1)
		move.w	$C(a0),$3A(a1)
		move.b	d2,$1C(a1)
		move.b	d2,$1A(a1)
		addq.b	#1,d2
		move.b	d3,$26(a1)
		addi.b	#$2A,d3
		lea	$40(a1),a1
		dbf	d1,Obj88_MainLoop ; repeat 5 more times

Obj88_Move:				; XREF: Obj88_Index
		move.w	$3E(a0),d0
		add.w	d0,$26(a0)
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		moveq	#0,d4
		move.b	$3C(a0),d4
		muls.w	d4,d1
		asr.l	#8,d1
		muls.w	d4,d0
		asr.l	#8,d0
		add.w	$38(a0),d1
		add.w	$3A(a0),d0
		move.w	d1,8(a0)
		move.w	d0,$C(a0)
		cmpi.w	#$2000,$3C(a0)
		beq.s	loc_55FA
		addi.w	#$20,$3C(a0)

loc_55FA:
		cmpi.w	#$2000,$3E(a0)
		beq.s	loc_5608
		addi.w	#$20,$3E(a0)

loc_5608:
		cmpi.w	#$140,$3A(a0)
		beq.s	locret_5614
		subq.w	#1,$3A(a0)

locret_5614:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 89 - "SONIC THE HEDGEHOG" text	on the ending sequence
; ---------------------------------------------------------------------------

Obj89:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj89_Index(pc,d0.w),d1
		jmp	Obj89_Index(pc,d1.w)
; ===========================================================================
Obj89_Index:	dc.w Obj89_Main-Obj89_Index
		dc.w Obj89_Move-Obj89_Index
		dc.w Obj89_GotoCredits-Obj89_Index
; ===========================================================================

Obj89_Main:				; XREF: Obj89_Index
		addq.b	#2,$24(a0)
		move.w	#-$20,8(a0)	; object starts	outside	the level boundary
		move.w	#$D8,$A(a0)
		move.l	#Map_obj89,4(a0)
		move.w	#$5C5,2(a0)
		move.b	#0,1(a0)
		move.b	#0,$18(a0)

Obj89_Move:				; XREF: Obj89_Index
		cmpi.w	#$C0,8(a0)	; has object reached $C0?
		beq.s	Obj89_Delay	; if yes, branch
		addi.w	#$10,8(a0)	; move object to the right
		bra.w	DisplaySprite
; ===========================================================================

Obj89_Delay:				; XREF: Obj89_Move
		addq.b	#2,$24(a0)
		move.w	#120,$30(a0)	; set duration for delay (2 seconds)

Obj89_GotoCredits:			; XREF: Obj89_Index
		subq.w	#1,$30(a0)	; subtract 1 from duration
		bpl.s	Obj89_Display
		move.b	#$1C,($FFFFF600).w ; exit to credits

Obj89_Display:
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - Sonic on the ending	sequence
; ---------------------------------------------------------------------------
Map_obj87:
	include "_maps\obj87.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - chaos emeralds on the ending sequence
; ---------------------------------------------------------------------------
Map_obj88:
	include "_maps\obj88.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC THE HEDGEHOG" text on the ending sequence
; ---------------------------------------------------------------------------
Map_obj89:
	include "_maps\obj89.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Credits ending sequence
; ---------------------------------------------------------------------------

Credits:				; XREF: GameModeArray
		bsr.w	ClearPLC
		bsr.w	Pal_FadeFrom
		lea	($C00004).l,a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$9001,(a6)
		move.w	#$9200,(a6)
		move.w	#$8B03,(a6)
		move.w	#$8720,(a6)
		clr.b	($FFFFF64E).w
		bsr.w	ClearScreen
		lea	($FFFFD000).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

Cred_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,Cred_ClrObjRam ; clear object RAM

		move.l	#$74000002,($C00004).l
		lea	(Nem_CreditText).l,a0 ;	load credits alphabet patterns
		bsr.w	NemDec
		lea	($FFFFFB80).w,a1
		moveq	#0,d0
		move.w	#$1F,d1

Cred_ClrPallet:
		move.l	d0,(a1)+
		dbf	d1,Cred_ClrPallet ; fill pallet	with black ($0000)

		moveq	#3,d0
		bsr.w	PalLoad1	; load Sonic's pallet
		move.b	#$8A,($FFFFD080).w ; load credits object
		jsr	ObjectsLoad
		jsr	BuildSprites
		bsr.w	EndingDemoLoad
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		lsl.w	#4,d0
		lea	(MainLoadBlocks).l,a2 ;	load block mappings etc
		lea	(a2,d0.w),a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	loc_5862
		bsr.w	LoadPLC		; load level patterns

loc_5862:
		moveq	#1,d0
		bsr.w	LoadPLC		; load standard	level patterns
		move.w	#120,($FFFFF614).w ; display a credit for 2 seconds
		bsr.w	Pal_FadeTo

Cred_WaitLoop:
		move.b	#4,($FFFFF62A).w
		bsr.w	DelayProgram
		bsr.w	RunPLC_RAM
		tst.w	($FFFFF614).w	; have 2 seconds elapsed?
		bne.s	Cred_WaitLoop	; if not, branch
		tst.l	($FFFFF680).w	; have level gfx finished decompressing?
		bne.s	Cred_WaitLoop	; if not, branch
		cmpi.w	#9,($FFFFFFF4).w ; have	the credits finished?
		beq.w	TryAgainEnd	; if yes, branch
		rts

; ---------------------------------------------------------------------------
; Ending sequence demo loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


EndingDemoLoad:				; XREF: Credits
		move.w	($FFFFFFF4).w,d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	EndDemo_Levels(pc,d0.w),d0 ; load level	array
		move.w	d0,($FFFFFE10).w ; set level from level	array
		addq.w	#1,($FFFFFFF4).w
		cmpi.w	#9,($FFFFFFF4).w ; have	credits	finished?
		bcc.s	EndDemo_Exit	; if yes, branch
		move.w	#$8001,($FFFFFFF0).w ; force demo mode
		move.b	#8,($FFFFF600).w ; set game mode to 08 (demo)
		move.b	#3,($FFFFFE12).w ; set lives to	3
		moveq	#0,d0
		move.w	d0,($FFFFFE20).w ; clear rings
		move.l	d0,($FFFFFE22).w ; clear time
		move.l	d0,($FFFFFE26).w ; clear score
		move.b	d0,($FFFFFE30).w ; clear lamppost counter
		cmpi.w	#4,($FFFFFFF4).w ; is SLZ demo running?
		bne.s	EndDemo_Exit	; if not, branch
		lea	(EndDemo_LampVar).l,a1 ; load lamppost variables
		lea	($FFFFFE30).w,a2
		move.w	#8,d0

EndDemo_LampLoad:
		move.l	(a1)+,(a2)+
		dbf	d0,EndDemo_LampLoad

EndDemo_Exit:
		rts
; End of function EndingDemoLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Levels used in the end sequence demos
; ---------------------------------------------------------------------------
EndDemo_Levels:	incbin	misc\dm_ord2.bin

; ---------------------------------------------------------------------------
; Lamppost variables in the end sequence demo (Star Light Zone)
; ---------------------------------------------------------------------------
EndDemo_LampVar:
		dc.b 1,	1		; XREF: EndingDemoLoad
		dc.w $A00, $62C, $D
		dc.l 0
		dc.b 0,	0
		dc.w $800, $957, $5CC, $4AB, $3A6, 0, $28C, 0, 0, $308
		dc.b 1,	1
; ===========================================================================
; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screens
; ---------------------------------------------------------------------------

TryAgainEnd:				; XREF: Credits
		bsr.w	ClearPLC
		bsr.w	Pal_FadeFrom
		lea	($C00004).l,a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$9001,(a6)
		move.w	#$9200,(a6)
		move.w	#$8B03,(a6)
		move.w	#$8720,(a6)
		clr.b	($FFFFF64E).w
		bsr.w	ClearScreen
		lea	($FFFFD000).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

TryAg_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,TryAg_ClrObjRam ; clear object RAM

		moveq	#$1D,d0
		bsr.w	RunPLC_ROM	; load "TRY AGAIN" or "END" patterns
		lea	($FFFFFB80).w,a1
		moveq	#0,d0
		move.w	#$1F,d1

TryAg_ClrPallet:
		move.l	d0,(a1)+
		dbf	d1,TryAg_ClrPallet ; fill pallet with black ($0000)

		moveq	#$13,d0
		bsr.w	PalLoad1	; load ending pallet
		clr.w	($FFFFFBC0).w
		move.b	#$8B,($FFFFD080).w ; load Eggman object
		jsr	ObjectsLoad
		jsr	BuildSprites
		move.w	#1800,($FFFFF614).w ; show screen for 30 seconds
		bsr.w	Pal_FadeTo

; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screen main loop
; ---------------------------------------------------------------------------
TryAg_MainLoop:
		bsr.w	PauseGame
		move.b	#4,($FFFFF62A).w
		bsr.w	DelayProgram
		jsr	ObjectsLoad
		jsr	BuildSprites
		andi.b	#$80,($FFFFF605).w ; is	Start button pressed?
		bne.s	TryAg_Exit	; if yes, branch
		tst.w	($FFFFF614).w	; has 30 seconds elapsed?
		beq.s	TryAg_Exit	; if yes, branch
		cmpi.b	#$1C,($FFFFF600).w
		beq.s	TryAg_MainLoop

TryAg_Exit:
		move.b	#0,($FFFFF600).w ; go to Sega screen
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 8B - Eggman on "TRY AGAIN" and "END"	screens
; ---------------------------------------------------------------------------

Obj8B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj8B_Index(pc,d0.w),d1
		jsr	Obj8B_Index(pc,d1.w)
		jmp	DisplaySprite
; ===========================================================================
Obj8B_Index:	dc.w Obj8B_Main-Obj8B_Index
		dc.w Obj8B_Animate-Obj8B_Index
		dc.w Obj8B_Juggle-Obj8B_Index
		dc.w loc_5A8E-Obj8B_Index
; ===========================================================================

Obj8B_Main:				; XREF: Obj8B_Index
		addq.b	#2,$24(a0)
		move.w	#$120,8(a0)
		move.w	#$F4,$A(a0)
		move.l	#Map_obj8B,4(a0)
		move.w	#$3E1,2(a0)
		move.b	#0,1(a0)
		move.b	#2,$18(a0)
		move.b	#2,$1C(a0)	; use "END" animation
		cmpi.b	#6,($FFFFFE57).w ; do you have all 6 emeralds?
		beq.s	Obj8B_Animate	; if yes, branch
		move.b	#$8A,($FFFFD0C0).w ; load credits object
		move.w	#9,($FFFFFFF4).w ; use "TRY AGAIN" text
		move.b	#$8C,($FFFFD800).w ; load emeralds object on "TRY AGAIN" screen
		move.b	#0,$1C(a0)	; use "TRY AGAIN" animation

Obj8B_Animate:				; XREF: Obj8B_Index
		lea	(Ani_obj8B).l,a1
		jmp	AnimateSprite
; ===========================================================================

Obj8B_Juggle:				; XREF: Obj8B_Index
		addq.b	#2,$24(a0)
		moveq	#2,d0
		btst	#0,$1C(a0)
		beq.s	loc_5A6A
		neg.w	d0

loc_5A6A:
		lea	($FFFFD800).w,a1
		moveq	#5,d1

loc_5A70:
		move.b	d0,$3E(a1)
		move.w	d0,d2
		asl.w	#3,d2
		add.b	d2,$26(a1)
		lea	$40(a1),a1
		dbf	d1,loc_5A70
		addq.b	#1,$1A(a0)
		move.w	#112,$30(a0)

loc_5A8E:				; XREF: Obj8B_Index
		subq.w	#1,$30(a0)
		bpl.s	locret_5AA0
		bchg	#0,$1C(a0)
		move.b	#2,$24(a0)

locret_5AA0:
		rts
; ===========================================================================
Ani_obj8B:
	include "_anim\obj8B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 8C - chaos emeralds on	the "TRY AGAIN"	screen
; ---------------------------------------------------------------------------

Obj8C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj8C_Index(pc,d0.w),d1
		jsr	Obj8C_Index(pc,d1.w)
		jmp	DisplaySprite
; ===========================================================================
Obj8C_Index:	dc.w Obj8C_Main-Obj8C_Index
		dc.w Obj8C_Move-Obj8C_Index
; ===========================================================================

Obj8C_Main:				; XREF: Obj8C_Index
		movea.l	a0,a1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#5,d1
		sub.b	($FFFFFE57).w,d1

Obj8C_MakeEms:				; XREF: loc_5B42
		move.b	#$8C,(a1)	; load emerald object
		addq.b	#2,$24(a1)
		move.l	#Map_obj88,4(a1)
		move.w	#$3C5,2(a1)
		move.b	#0,1(a1)
		move.b	#1,$18(a1)
		move.w	#$104,8(a1)
		move.w	#$120,$38(a1)
		move.w	#$EC,$A(a1)
		move.w	$A(a1),$3A(a1)
		move.b	#$1C,$3C(a1)
		lea	($FFFFFE58).w,a3

Obj8C_ChkEms:
		moveq	#0,d0
		move.b	($FFFFFE57).w,d0
		subq.w	#1,d0
		bcs.s	loc_5B42

Obj8C_ChkEmLoop:
		cmp.b	(a3,d0.w),d2
		bne.s	loc_5B3E
		addq.b	#1,d2
		bra.s	Obj8C_ChkEms
; ===========================================================================

loc_5B3E:
		dbf	d0,Obj8C_ChkEmLoop ; checks which emeralds you have

loc_5B42:
		move.b	d2,$1A(a1)
		addq.b	#1,$1A(a1)
		addq.b	#1,d2
		move.b	#$80,$26(a1)
		move.b	d3,$1E(a1)
		move.b	d3,$1F(a1)
		addi.w	#$A,d3
		lea	$40(a1),a1
		dbf	d1,Obj8C_MakeEms

Obj8C_Move:				; XREF: Obj8C_Index
		tst.w	$3E(a0)
		beq.s	locret_5BBA
		tst.b	$1E(a0)
		beq.s	loc_5B78
		subq.b	#1,$1E(a0)
		bne.s	loc_5B80

loc_5B78:
		move.w	$3E(a0),d0
		add.w	d0,$26(a0)

loc_5B80:
		move.b	$26(a0),d0
		beq.s	loc_5B8C
		cmpi.b	#$80,d0
		bne.s	loc_5B96

loc_5B8C:
		clr.w	$3E(a0)
		move.b	$1F(a0),$1E(a0)

loc_5B96:
		jsr	(CalcSine).l
		moveq	#0,d4
		move.b	$3C(a0),d4
		muls.w	d4,d1
		asr.l	#8,d1
		muls.w	d4,d0
		asr.l	#8,d0
		add.w	$38(a0),d1
		add.w	$3A(a0),d0
		move.w	d1,8(a0)
		move.w	d0,$A(a0)

locret_5BBA:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - Eggman on	the "TRY AGAIN"	and "END" screens
; ---------------------------------------------------------------------------
Map_obj8B:
	include "_maps\obj8B.asm"

; ---------------------------------------------------------------------------
; Ending sequence demos
; ---------------------------------------------------------------------------
Demo_EndGHZ1:	incbin	demodata\e_ghz1.bin
		even
Demo_EndMZ:	incbin	demodata\e_mz.bin
		even
Demo_EndSYZ:	incbin	demodata\e_syz.bin
		even
Demo_EndLZ:	incbin	demodata\e_lz.bin
		even
Demo_EndSLZ:	incbin	demodata\e_slz.bin
		even
Demo_EndSBZ1:	incbin	demodata\e_sbz1.bin
		even
Demo_EndSBZ2:	incbin	demodata\e_sbz2.bin
		even
Demo_EndGHZ2:	incbin	demodata\e_ghz2.bin
		even

; ---------------------------------------------------------------------------
; Subroutine to	load level boundaries and start	locations
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevelSizeLoad:				; XREF: TitleScreen; Level; EndingSequence
		moveq	#0,d0
		move.b	d0,($FFFFF740).w
		move.b	d0,($FFFFF741).w
		move.b	d0,($FFFFF746).w
		move.b	d0,($FFFFF748).w
		move.b	d0,($FFFFF742).w
		move.w	($FFFFFE10).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	LevelSizeArray(pc,d0.w),a0 ; load level	boundaries
		move.w	(a0)+,d0
		move.w	d0,($FFFFF730).w
		move.l	(a0)+,d0
		move.l	d0,($FFFFF728).w
		move.l	d0,($FFFFF720).w
		move.l	(a0)+,d0
		move.l	d0,($FFFFF72C).w
		move.l	d0,($FFFFF724).w
		move.w	($FFFFF728).w,d0
		addi.w	#$240,d0
		move.w	d0,($FFFFF732).w
		move.w	#$1010,($FFFFF74A).w
		move.w	(a0)+,d0
		move.w	d0,($FFFFF73E).w
		bra.w	LevSz_ChkLamp
; ===========================================================================
; ---------------------------------------------------------------------------
; Level size array and ending start location array
; ---------------------------------------------------------------------------
LevelSizeArray:	incbin	misc\lvl_size.bin
		even

EndingStLocArray:
		incbin	misc\sloc_end.bin
		even

; ===========================================================================

LevSz_ChkLamp:				; XREF: LevelSizeLoad
		tst.b	($FFFFFE30).w	; have any lampposts been hit?
		beq.s	LevSz_StartLoc	; if not, branch
		jsr	Obj79_LoadInfo
		move.w	($FFFFD008).w,d1
		move.w	($FFFFD00C).w,d0
		bra.s	loc_60D0
; ===========================================================================

LevSz_StartLoc:				; XREF: LevelSizeLoad
		move.w	($FFFFFE10).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea	StartLocArray(pc,d0.w),a1 ; load Sonic's start location
		tst.w	($FFFFFFF0).w	; is demo mode on?
		bpl.s	LevSz_SonicPos	; if not, branch
		move.w	($FFFFFFF4).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		lea	EndingStLocArray(pc,d0.w),a1 ; load Sonic's start location

LevSz_SonicPos:
		moveq	#0,d1
		move.w	(a1)+,d1
		move.w	d1,($FFFFD008).w ; set Sonic's position on x-axis
		moveq	#0,d0
		move.w	(a1),d0
		move.w	d0,($FFFFD00C).w ; set Sonic's position on y-axis

loc_60D0:				; XREF: LevSz_ChkLamp
		subi.w	#$A0,d1
		bcc.s	loc_60D8
		moveq	#0,d1

loc_60D8:
		move.w	($FFFFF72A).w,d2
		cmp.w	d2,d1
		bcs.s	loc_60E2
		move.w	d2,d1

loc_60E2:
		move.w	d1,($FFFFF700).w
		subi.w	#$60,d0
		bcc.s	loc_60EE
		moveq	#0,d0

loc_60EE:
		cmp.w	($FFFFF72E).w,d0
		blt.s	loc_60F8
		move.w	($FFFFF72E).w,d0

loc_60F8:
		move.w	d0,($FFFFF704).w
		bsr.w	BgScrollSpeed
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		lsl.b	#2,d0
		move.l	LoopTileNums(pc,d0.w),($FFFFF7AC).w
		bra.w	LevSz_Unk
; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic	start location array
; ---------------------------------------------------------------------------
StartLocArray:	incbin	misc\sloc_lev.bin
		even

; ---------------------------------------------------------------------------
; Which	256x256	tiles contain loops or roll-tunnels
; ---------------------------------------------------------------------------
; Format - 4 bytes per zone, referring to which 256x256 evoke special events:
; loop,	loop, tunnel, tunnel
; ---------------------------------------------------------------------------
LoopTileNums:	incbin	misc\loopnums.bin
		even

; ===========================================================================

LevSz_Unk:				; XREF: LevelSizeLoad
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		lsl.w	#3,d0
		lea	dword_61B4(pc,d0.w),a1
		lea	($FFFFF7F0).w,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		rts
; End of function LevelSizeLoad

; ===========================================================================
dword_61B4:	dc.l $700100, $1000100
		dc.l $8000100, $1000000
		dc.l $8000100, $1000000
		dc.l $8000100, $1000000
		dc.l $8000100, $1000000
		dc.l $8000100, $1000000
		dc.l $700100, $1000100

; ---------------------------------------------------------------------------
; Subroutine to	set scroll speed of some backgrounds
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BgScrollSpeed:				; XREF: LevelSizeLoad
		tst.b	($FFFFFE30).w
		bne.s	loc_6206
		move.w	d0,($FFFFF70C).w
		move.w	d0,($FFFFF714).w
		move.w	d1,($FFFFF708).w
		move.w	d1,($FFFFF710).w
		move.w	d1,($FFFFF718).w

loc_6206:
		moveq	#0,d2
		move.b	($FFFFFE10).w,d2
		add.w	d2,d2
		move.w	BgScroll_Index(pc,d2.w),d2
		jmp	BgScroll_Index(pc,d2.w)
; End of function BgScrollSpeed

; ===========================================================================
BgScroll_Index:	dc.w BgScroll_GHZ-BgScroll_Index, BgScroll_LZ-BgScroll_Index
		dc.w BgScroll_MZ-BgScroll_Index, BgScroll_SLZ-BgScroll_Index
		dc.w BgScroll_SYZ-BgScroll_Index, BgScroll_SBZ-BgScroll_Index
		dc.w BgScroll_End-BgScroll_Index
; ===========================================================================

BgScroll_GHZ:				; XREF: BgScroll_Index
		bra.w	Deform_GHZ
; ===========================================================================

BgScroll_LZ:				; XREF: BgScroll_Index
		asr.l	#1,d0
		move.w	d0,($FFFFF70C).w
		rts
; ===========================================================================

BgScroll_MZ:				; XREF: BgScroll_Index
		rts
; ===========================================================================

BgScroll_SLZ:				; XREF: BgScroll_Index
		asr.l	#1,d0
		addi.w	#$C0,d0
		move.w	d0,($FFFFF70C).w
		rts
; ===========================================================================

BgScroll_SYZ:				; XREF: BgScroll_Index
		asl.l	#4,d0
		move.l	d0,d2
		asl.l	#1,d0
		add.l	d2,d0
		asr.l	#8,d0
		move.w	d0,($FFFFF70C).w
		move.w	d0,($FFFFF714).w
		rts
; ===========================================================================

BgScroll_SBZ:				; XREF: BgScroll_Index
		asl.l	#4,d0
		asl.l	#1,d0
		asr.l	#8,d0
		move.w	d0,($FFFFF70C).w
		rts
; ===========================================================================

BgScroll_End:				; XREF: BgScroll_Index
		move.w	#$1E,($FFFFF70C).w
		move.w	#$1E,($FFFFF714).w
		rts
; ===========================================================================
		move.w	#$A8,($FFFFF708).w
		move.w	#$1E,($FFFFF70C).w
		move.w	#-$40,($FFFFF710).w
		move.w	#$1E,($FFFFF714).w
		rts

; ---------------------------------------------------------------------------
; Background layer deformation subroutines
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DeformBgLayer:				; XREF: TitleScreen; Level; EndingSequence
		tst.b	($FFFFF744).w
		beq.s	loc_628E
		rts
; ===========================================================================

loc_628E:
		clr.w	($FFFFF754).w
		clr.w	($FFFFF756).w
		clr.w	($FFFFF758).w
		clr.w	($FFFFF75A).w
		bsr.w	ScrollHoriz
		bsr.w	ScrollVertical
		bsr.w	DynScrResizeLoad
		move.w	($FFFFF700).w,($FFFFF61A).w
		move.w	($FFFFF704).w,($FFFFF616).w
		move.w	($FFFFF708).w,($FFFFF61C).w
		move.w	($FFFFF70C).w,($FFFFF618).w
		move.w	($FFFFF718).w,($FFFFF620).w
		move.w	($FFFFF71C).w,($FFFFF61E).w
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		add.w	d0,d0
		move.w	Deform_Index(pc,d0.w),d0
		jmp	Deform_Index(pc,d0.w)
; End of function DeformBgLayer

; ===========================================================================
; ---------------------------------------------------------------------------
; Offset index for background layer deformation	code
; ---------------------------------------------------------------------------
Deform_Index:	dc.w Deform_GHZ-Deform_Index, Deform_LZ-Deform_Index
		dc.w Deform_MZ-Deform_Index, Deform_SLZ-Deform_Index
		dc.w Deform_SYZ-Deform_Index, Deform_SBZ-Deform_Index
		dc.w Deform_GHZ-Deform_Index
; ---------------------------------------------------------------------------
; Green	Hill Zone background layer deformation code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_GHZ:				; XREF: Deform_Index
		move.w	($FFFFF73A).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4
		moveq	#0,d5
		bsr.w	ScrollBlock1
		bsr.w	ScrollBlock4
		lea	($FFFFCC00).w,a1
		move.w	($FFFFF704).w,d0
		andi.w	#$7FF,d0
		lsr.w	#5,d0
		neg.w	d0
		addi.w	#$26,d0
		move.w	d0,($FFFFF714).w
		move.w	d0,d4
		bsr.w	ScrollBlock3
		move.w	($FFFFF70C).w,($FFFFF618).w
		move.w	#$6F,d1
		sub.w	d4,d1
		move.w	($FFFFF700).w,d0
		cmpi.b	#4,($FFFFF600).w
		bne.s	loc_633C
		moveq	#0,d0

loc_633C:
		neg.w	d0
		swap	d0
		move.w	($FFFFF708).w,d0
		neg.w	d0

loc_6346:
		move.l	d0,(a1)+
		dbf	d1,loc_6346
		move.w	#$27,d1
		move.w	($FFFFF710).w,d0
		neg.w	d0

loc_6356:
		move.l	d0,(a1)+
		dbf	d1,loc_6356
		move.w	($FFFFF710).w,d0
		addi.w	#0,d0
		move.w	($FFFFF700).w,d2
		addi.w	#-$200,d2
		sub.w	d0,d2
		ext.l	d2
		asl.l	#8,d2
		divs.w	#$68,d2
		ext.l	d2
		asl.l	#8,d2
		moveq	#0,d3
		move.w	d0,d3
		move.w	#$47,d1
		add.w	d4,d1

loc_6384:
		move.w	d3,d0
		neg.w	d0
		move.l	d0,(a1)+
		swap	d3
		add.l	d2,d3
		swap	d3
		dbf	d1,loc_6384
		rts
; End of function Deform_GHZ

; ---------------------------------------------------------------------------
; Labyrinth Zone background layer deformation code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_LZ:				; XREF: Deform_Index
		move.w	($FFFFF73A).w,d4
		ext.l	d4
		asl.l	#7,d4
		move.w	($FFFFF73C).w,d5
		ext.l	d5
		asl.l	#7,d5
		bsr.w	ScrollBlock1
		move.w	($FFFFF70C).w,($FFFFF618).w
		lea	($FFFFCC00).w,a1
		move.w	#$DF,d1
		move.w	($FFFFF700).w,d0
		neg.w	d0
		swap	d0
		move.w	($FFFFF708).w,d0
		neg.w	d0

loc_63C6:
		move.l	d0,(a1)+
		dbf	d1,loc_63C6
		move.w	($FFFFF646).w,d0
		sub.w	($FFFFF704).w,d0
		rts
; End of function Deform_LZ

; ---------------------------------------------------------------------------
; Marble Zone background layer deformation code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_MZ:				; XREF: Deform_Index
		move.w	($FFFFF73A).w,d4
		ext.l	d4
		asl.l	#6,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4
		moveq	#0,d5
		bsr.w	ScrollBlock1
		move.w	#$200,d0
		move.w	($FFFFF704).w,d1
		subi.w	#$1C8,d1
		bcs.s	loc_6402
		move.w	d1,d2
		add.w	d1,d1
		add.w	d2,d1
		asr.w	#2,d1
		add.w	d1,d0

loc_6402:
		move.w	d0,($FFFFF714).w
		bsr.w	ScrollBlock3
		move.w	($FFFFF70C).w,($FFFFF618).w
		lea	($FFFFCC00).w,a1
		move.w	#$DF,d1
		move.w	($FFFFF700).w,d0
		neg.w	d0
		swap	d0
		move.w	($FFFFF708).w,d0
		neg.w	d0

loc_6426:
		move.l	d0,(a1)+
		dbf	d1,loc_6426
		rts
; End of function Deform_MZ

; ---------------------------------------------------------------------------
; Star Light Zone background layer deformation code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_SLZ:				; XREF: Deform_Index
		move.w	($FFFFF73A).w,d4
		ext.l	d4
		asl.l	#7,d4
		move.w	($FFFFF73C).w,d5
		ext.l	d5
		asl.l	#7,d5
		bsr.w	ScrollBlock2
		move.w	($FFFFF70C).w,($FFFFF618).w
		bsr.w	Deform_SLZ_2
		lea	($FFFFA800).w,a2
		move.w	($FFFFF70C).w,d0
		move.w	d0,d2
		subi.w	#$C0,d0
		andi.w	#$3F0,d0
		lsr.w	#3,d0
		lea	(a2,d0.w),a2
		lea	($FFFFCC00).w,a1
		move.w	#$E,d1
		move.w	($FFFFF700).w,d0
		neg.w	d0
		swap	d0
		andi.w	#$F,d2
		add.w	d2,d2
		move.w	(a2)+,d0
		jmp	loc_6482(pc,d2.w)
; ===========================================================================

loc_6480:				; XREF: Deform_SLZ
		move.w	(a2)+,d0

loc_6482:
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		dbf	d1,loc_6480
		rts
; End of function Deform_SLZ


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_SLZ_2:				; XREF: Deform_SLZ
		lea	($FFFFA800).w,a1
		move.w	($FFFFF700).w,d2
		neg.w	d2
		move.w	d2,d0
		asr.w	#3,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#4,d0
		divs.w	#$1C,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		move.w	#$1B,d1

loc_64CE:
		move.w	d3,(a1)+
		swap	d3
		add.l	d0,d3
		swap	d3
		dbf	d1,loc_64CE
		move.w	d2,d0
		asr.w	#3,d0
		move.w	#4,d1

loc_64E2:
		move.w	d0,(a1)+
		dbf	d1,loc_64E2
		move.w	d2,d0
		asr.w	#2,d0
		move.w	#4,d1

loc_64F0:
		move.w	d0,(a1)+
		dbf	d1,loc_64F0
		move.w	d2,d0
		asr.w	#1,d0
		move.w	#$1D,d1

loc_64FE:
		move.w	d0,(a1)+
		dbf	d1,loc_64FE
		rts
; End of function Deform_SLZ_2

; ---------------------------------------------------------------------------
; Spring Yard Zone background layer deformation	code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_SYZ:				; XREF: Deform_Index
		move.w	($FFFFF73A).w,d4
		ext.l	d4
		asl.l	#6,d4
		move.w	($FFFFF73C).w,d5
		ext.l	d5
		asl.l	#4,d5
		move.l	d5,d1
		asl.l	#1,d5
		add.l	d1,d5
		bsr.w	ScrollBlock1
		move.w	($FFFFF70C).w,($FFFFF618).w
		lea	($FFFFCC00).w,a1
		move.w	#$DF,d1
		move.w	($FFFFF700).w,d0
		neg.w	d0
		swap	d0
		move.w	($FFFFF708).w,d0
		neg.w	d0

loc_653C:
		move.l	d0,(a1)+
		dbf	d1,loc_653C
		rts
; End of function Deform_SYZ

; ---------------------------------------------------------------------------
; Scrap	Brain Zone background layer deformation	code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_SBZ:				; XREF: Deform_Index
		move.w	($FFFFF73A).w,d4
		ext.l	d4
		asl.l	#6,d4
		move.w	($FFFFF73C).w,d5
		ext.l	d5
		asl.l	#4,d5
		asl.l	#1,d5
		bsr.w	ScrollBlock1
		move.w	($FFFFF70C).w,($FFFFF618).w
		lea	($FFFFCC00).w,a1
		move.w	#$DF,d1
		move.w	($FFFFF700).w,d0
		neg.w	d0
		swap	d0
		move.w	($FFFFF708).w,d0
		neg.w	d0

loc_6576:
		move.l	d0,(a1)+
		dbf	d1,loc_6576
		rts
; End of function Deform_SBZ

; ---------------------------------------------------------------------------
; Subroutine to	scroll the level horizontally as Sonic moves
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollHoriz:				; XREF: DeformBgLayer
		move.w	($FFFFF700).w,d4
		bsr.s	ScrollHoriz2
		move.w	($FFFFF700).w,d0
		andi.w	#$10,d0
		move.b	($FFFFF74A).w,d1
		eor.b	d1,d0
		bne.s	locret_65B0
		eori.b	#$10,($FFFFF74A).w
		move.w	($FFFFF700).w,d0
		sub.w	d4,d0
		bpl.s	loc_65AA
		bset	#2,($FFFFF754).w
		rts
; ===========================================================================

loc_65AA:
		bset	#3,($FFFFF754).w

locret_65B0:
		rts
; End of function ScrollHoriz


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollHoriz2:				; XREF: ScrollHoriz
		move.w	($FFFFD008).w,d0
		sub.w	($FFFFF700).w,d0
		subi.w	#$90,d0
		bcs.s	loc_65F6
		subi.w	#$10,d0
		bcc.s	loc_65CC
		clr.w	($FFFFF73A).w
		rts
; ===========================================================================

loc_65CC:
		cmpi.w	#$10,d0
		bcs.s	loc_65D6
		move.w	#$10,d0

loc_65D6:
		add.w	($FFFFF700).w,d0
		cmp.w	($FFFFF72A).w,d0
		blt.s	loc_65E4
		move.w	($FFFFF72A).w,d0

loc_65E4:
		move.w	d0,d1
		sub.w	($FFFFF700).w,d1
		asl.w	#8,d1
		move.w	d0,($FFFFF700).w
		move.w	d1,($FFFFF73A).w
		rts
; ===========================================================================

loc_65F6:				; XREF: ScrollHoriz2
		add.w	($FFFFF700).w,d0
		cmp.w	($FFFFF728).w,d0
		bgt.s	loc_65E4
		move.w	($FFFFF728).w,d0
		bra.s	loc_65E4
; End of function ScrollHoriz2

; ===========================================================================
		tst.w	d0
		bpl.s	loc_6610
		move.w	#-2,d0
		bra.s	loc_65F6
; ===========================================================================

loc_6610:
		move.w	#2,d0
		bra.s	loc_65CC

; ---------------------------------------------------------------------------
; Subroutine to	scroll the level vertically as Sonic moves
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollVertical:				; XREF: DeformBgLayer
		moveq	#0,d1
		move.w	($FFFFD00C).w,d0
		sub.w	($FFFFF704).w,d0
		btst	#2,($FFFFD022).w
		beq.s	loc_662A
		subq.w	#5,d0

loc_662A:
		btst	#1,($FFFFD022).w
		beq.s	loc_664A
		addi.w	#$20,d0
		sub.w	($FFFFF73E).w,d0
		bcs.s	loc_6696
		subi.w	#$40,d0
		bcc.s	loc_6696
		tst.b	($FFFFF75C).w
		bne.s	loc_66A8
		bra.s	loc_6656
; ===========================================================================

loc_664A:
		sub.w	($FFFFF73E).w,d0
		bne.s	loc_665C
		tst.b	($FFFFF75C).w
		bne.s	loc_66A8

loc_6656:
		clr.w	($FFFFF73C).w
		rts
; ===========================================================================

loc_665C:
		cmpi.w	#$60,($FFFFF73E).w
		bne.s	loc_6684
		move.w	($FFFFD014).w,d1
		bpl.s	loc_666C
		neg.w	d1

loc_666C:
		cmpi.w	#$800,d1
		bcc.s	loc_6696
		move.w	#$600,d1
		cmpi.w	#6,d0
		bgt.s	loc_66F6
		cmpi.w	#-6,d0
		blt.s	loc_66C0
		bra.s	loc_66AE
; ===========================================================================

loc_6684:
		move.w	#$200,d1
		cmpi.w	#2,d0
		bgt.s	loc_66F6
		cmpi.w	#-2,d0
		blt.s	loc_66C0
		bra.s	loc_66AE
; ===========================================================================

loc_6696:
		move.w	#$1000,d1
		cmpi.w	#$10,d0
		bgt.s	loc_66F6
		cmpi.w	#-$10,d0
		blt.s	loc_66C0
		bra.s	loc_66AE
; ===========================================================================

loc_66A8:
		moveq	#0,d0
		move.b	d0,($FFFFF75C).w

loc_66AE:
		moveq	#0,d1
		move.w	d0,d1
		add.w	($FFFFF704).w,d1
		tst.w	d0
		bpl.w	loc_6700
		bra.w	loc_66CC
; ===========================================================================

loc_66C0:
		neg.w	d1
		ext.l	d1
		asl.l	#8,d1
		add.l	($FFFFF704).w,d1
		swap	d1

loc_66CC:
		cmp.w	($FFFFF72C).w,d1
		bgt.s	loc_6724
		cmpi.w	#-$100,d1
		bgt.s	loc_66F0
		andi.w	#$7FF,d1
		andi.w	#$7FF,($FFFFD00C).w
		andi.w	#$7FF,($FFFFF704).w
		andi.w	#$3FF,($FFFFF70C).w
		bra.s	loc_6724
; ===========================================================================

loc_66F0:
		move.w	($FFFFF72C).w,d1
		bra.s	loc_6724
; ===========================================================================

loc_66F6:
		ext.l	d1
		asl.l	#8,d1
		add.l	($FFFFF704).w,d1
		swap	d1

loc_6700:
		cmp.w	($FFFFF72E).w,d1
		blt.s	loc_6724
		subi.w	#$800,d1
		bcs.s	loc_6720
		andi.w	#$7FF,($FFFFD00C).w
		subi.w	#$800,($FFFFF704).w
		andi.w	#$3FF,($FFFFF70C).w
		bra.s	loc_6724
; ===========================================================================

loc_6720:
		move.w	($FFFFF72E).w,d1

loc_6724:
		move.w	($FFFFF704).w,d4
		swap	d1
		move.l	d1,d3
		sub.l	($FFFFF704).w,d3
		ror.l	#8,d3
		move.w	d3,($FFFFF73C).w
		move.l	d1,($FFFFF704).w
		move.w	($FFFFF704).w,d0
		andi.w	#$10,d0
		move.b	($FFFFF74B).w,d1
		eor.b	d1,d0
		bne.s	locret_6766
		eori.b	#$10,($FFFFF74B).w
		move.w	($FFFFF704).w,d0
		sub.w	d4,d0
		bpl.s	loc_6760
		bset	#0,($FFFFF754).w
		rts
; ===========================================================================

loc_6760:
		bset	#1,($FFFFF754).w

locret_6766:
		rts
; End of function ScrollVertical


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollBlock1:				; XREF: Deform_GHZ; et al
		move.l	($FFFFF708).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,($FFFFF708).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	($FFFFF74C).w,d3
		eor.b	d3,d1
		bne.s	loc_679C
		eori.b	#$10,($FFFFF74C).w
		sub.l	d2,d0
		bpl.s	loc_6796
		bset	#2,($FFFFF756).w
		bra.s	loc_679C
; ===========================================================================

loc_6796:
		bset	#3,($FFFFF756).w

loc_679C:
		move.l	($FFFFF70C).w,d3
		move.l	d3,d0
		add.l	d5,d0
		move.l	d0,($FFFFF70C).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	($FFFFF74D).w,d2
		eor.b	d2,d1
		bne.s	locret_67D0
		eori.b	#$10,($FFFFF74D).w
		sub.l	d3,d0
		bpl.s	loc_67CA
		bset	#0,($FFFFF756).w
		rts
; ===========================================================================

loc_67CA:
		bset	#1,($FFFFF756).w

locret_67D0:
		rts
; End of function ScrollBlock1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollBlock2:				; XREF: Deform_SLZ
		move.l	($FFFFF708).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,($FFFFF708).w
		move.l	($FFFFF70C).w,d3
		move.l	d3,d0
		add.l	d5,d0
		move.l	d0,($FFFFF70C).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	($FFFFF74D).w,d2
		eor.b	d2,d1
		bne.s	locret_6812
		eori.b	#$10,($FFFFF74D).w
		sub.l	d3,d0
		bpl.s	loc_680C
		bset	#0,($FFFFF756).w
		rts
; ===========================================================================

loc_680C:
		bset	#1,($FFFFF756).w

locret_6812:
		rts
; End of function ScrollBlock2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollBlock3:				; XREF: Deform_GHZ; et al
		move.w	($FFFFF70C).w,d3
		move.w	d0,($FFFFF70C).w
		move.w	d0,d1
		andi.w	#$10,d1
		move.b	($FFFFF74D).w,d2
		eor.b	d2,d1
		bne.s	locret_6842
		eori.b	#$10,($FFFFF74D).w
		sub.w	d3,d0
		bpl.s	loc_683C
		bset	#0,($FFFFF756).w
		rts
; ===========================================================================

loc_683C:
		bset	#1,($FFFFF756).w

locret_6842:
		rts
; End of function ScrollBlock3


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollBlock4:				; XREF: Deform_GHZ
		move.w	($FFFFF710).w,d2
		move.w	($FFFFF714).w,d3
		move.w	($FFFFF73A).w,d0
		ext.l	d0
		asl.l	#7,d0
		add.l	d0,($FFFFF710).w
		move.w	($FFFFF710).w,d0
		andi.w	#$10,d0
		move.b	($FFFFF74E).w,d1
		eor.b	d1,d0
		bne.s	locret_6884
		eori.b	#$10,($FFFFF74E).w
		move.w	($FFFFF710).w,d0
		sub.w	d2,d0
		bpl.s	loc_687E
		bset	#2,($FFFFF758).w
		bra.s	locret_6884
; ===========================================================================

loc_687E:
		bset	#3,($FFFFF758).w

locret_6884:
		rts
; End of function ScrollBlock4


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6886:				; XREF: loc_C44
		lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	($FFFFF756).w,a2
		lea	($FFFFF708).w,a3
		lea	($FFFFA440).w,a4
		move.w	#$6000,d2
		bsr.w	sub_6954
		lea	($FFFFF758).w,a2
		lea	($FFFFF710).w,a3
		bra.w	sub_69F4
; End of function sub_6886

; ---------------------------------------------------------------------------
; Subroutine to	display	correct	tiles as you move
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesAsYouMove:			; XREF: Demo_Time
		lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	($FFFFFF32).w,a2
		lea	($FFFFFF18).w,a3
		lea	($FFFFA440).w,a4
		move.w	#$6000,d2
		bsr.w	sub_6954
		lea	($FFFFFF34).w,a2
		lea	($FFFFFF20).w,a3
		bsr.w	sub_69F4
		lea	($FFFFFF30).w,a2
		lea	($FFFFFF10).w,a3
		lea	($FFFFA400).w,a4
		move.w	#$4000,d2
		tst.b	(a2)
		beq.s	locret_6952
		bclr	#0,(a2)
		beq.s	loc_6908
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	sub_6C20
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	sub_6AD8

loc_6908:
		bclr	#1,(a2)
		beq.s	loc_6922
		move.w	#$E0,d4
		moveq	#-$10,d5
		bsr.w	sub_6C20
		move.w	#$E0,d4
		moveq	#-$10,d5
		bsr.w	sub_6AD8

loc_6922:
		bclr	#2,(a2)
		beq.s	loc_6938
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	sub_6C20
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	sub_6B04

loc_6938:
		bclr	#3,(a2)
		beq.s	locret_6952
		moveq	#-$10,d4
		move.w	#$140,d5
		bsr.w	sub_6C20
		moveq	#-$10,d4
		move.w	#$140,d5
		bsr.w	sub_6B04

locret_6952:
		rts
; End of function LoadTilesAsYouMove


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6954:				; XREF: sub_6886; LoadTilesAsYouMove
		tst.b	(a2)
		beq.w	locret_69F2
		bclr	#0,(a2)
		beq.s	loc_6972
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	sub_6C20
		moveq	#-$10,d4
		moveq	#-$10,d5
		moveq	#$1F,d6
		bsr.w	sub_6ADA

loc_6972:
		bclr	#1,(a2)
		beq.s	loc_698E
		move.w	#$E0,d4
		moveq	#-$10,d5
		bsr.w	sub_6C20
		move.w	#$E0,d4
		moveq	#-$10,d5
		moveq	#$1F,d6
		bsr.w	sub_6ADA

loc_698E:
		bclr	#2,(a2)
		beq.s	loc_69BE
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	sub_6C20
		moveq	#-$10,d4
		moveq	#-$10,d5
		move.w	($FFFFF7F0).w,d6
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d6
		blt.s	loc_69BE
		lsr.w	#4,d6
		cmpi.w	#$F,d6
		bcs.s	loc_69BA
		moveq	#$F,d6

loc_69BA:
		bsr.w	sub_6B06

loc_69BE:
		bclr	#3,(a2)
		beq.s	locret_69F2
		moveq	#-$10,d4
		move.w	#$140,d5
		bsr.w	sub_6C20
		moveq	#-$10,d4
		move.w	#$140,d5
		move.w	($FFFFF7F0).w,d6
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d6
		blt.s	locret_69F2
		lsr.w	#4,d6
		cmpi.w	#$F,d6
		bcs.s	loc_69EE
		moveq	#$F,d6

loc_69EE:
		bsr.w	sub_6B06

locret_69F2:
		rts
; End of function sub_6954


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_69F4:				; XREF: sub_6886; LoadTilesAsYouMove
		tst.b	(a2)
		beq.w	locret_6A80
		bclr	#2,(a2)
		beq.s	loc_6A3E
		cmpi.w	#$10,(a3)
		bcs.s	loc_6A3E
		move.w	($FFFFF7F0).w,d4
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		moveq	#-$10,d5
		bsr.w	sub_6C20
		move.w	(sp)+,d4
		moveq	#-$10,d5
		move.w	($FFFFF7F0).w,d6
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d6
		blt.s	loc_6A3E
		lsr.w	#4,d6
		subi.w	#$E,d6
		bcc.s	loc_6A3E
		neg.w	d6
		bsr.w	sub_6B06

loc_6A3E:
		bclr	#3,(a2)
		beq.s	locret_6A80
		move.w	($FFFFF7F0).w,d4
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		move.w	#$140,d5
		bsr.w	sub_6C20
		move.w	(sp)+,d4
		move.w	#$140,d5
		move.w	($FFFFF7F0).w,d6
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d6
		blt.s	locret_6A80
		lsr.w	#4,d6
		subi.w	#$E,d6
		bcc.s	locret_6A80
		neg.w	d6
		bsr.w	sub_6B06

locret_6A80:
		rts
; End of function sub_69F4

; ===========================================================================
		tst.b	(a2)
		beq.s	locret_6AD6
		bclr	#2,(a2)
		beq.s	loc_6AAC
		move.w	#$D0,d4
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		moveq	#-$10,d5
		bsr.w	sub_6C3C
		move.w	(sp)+,d4
		moveq	#-$10,d5
		moveq	#2,d6
		bsr.w	sub_6B06

loc_6AAC:
		bclr	#3,(a2)
		beq.s	locret_6AD6
		move.w	#$D0,d4
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		move.w	#$140,d5
		bsr.w	sub_6C3C
		move.w	(sp)+,d4
		move.w	#$140,d5
		moveq	#2,d6
		bsr.w	sub_6B06

locret_6AD6:
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6AD8:				; XREF: LoadTilesAsYouMove
		moveq	#$15,d6
; End of function sub_6AD8


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6ADA:				; XREF: sub_6954; LoadTilesFromStart2
		move.l	#$800000,d7
		move.l	d0,d1

loc_6AE2:
		movem.l	d4-d5,-(sp)
		bsr.w	sub_6BD6
		move.l	d1,d0
		bsr.w	sub_6B32
		addq.b	#4,d1
		andi.b	#$7F,d1
		movem.l	(sp)+,d4-d5
		addi.w	#$10,d5
		dbf	d6,loc_6AE2
		rts
; End of function sub_6ADA


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6B04:				; XREF: LoadTilesAsYouMove
		moveq	#$F,d6
; End of function sub_6B04


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6B06:				; XREF: sub_6954
		move.l	#$800000,d7
		move.l	d0,d1

loc_6B0E:
		movem.l	d4-d5,-(sp)
		bsr.w	sub_6BD6
		move.l	d1,d0
		bsr.w	sub_6B32
		addi.w	#$100,d1
		andi.w	#$FFF,d1
		movem.l	(sp)+,d4-d5
		addi.w	#$10,d4
		dbf	d6,loc_6B0E
		rts
; End of function sub_6B06


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6B32:				; XREF: sub_6ADA; sub_6B06
		or.w	d2,d0
		swap	d0
		btst	#4,(a0)
		bne.s	loc_6B6E
		btst	#3,(a0)
		bne.s	loc_6B4E
		move.l	d0,(a5)
		move.l	(a1)+,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.l	(a1)+,(a6)
		rts
; ===========================================================================

loc_6B4E:
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4
		swap	d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4
		swap	d4
		move.l	d4,(a6)
		rts
; ===========================================================================

loc_6B6E:
		btst	#3,(a0)
		bne.s	loc_6B90
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$10001000,d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$10001000,d5
		move.l	d5,(a6)
		rts
; ===========================================================================

loc_6B90:
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$18001800,d4
		swap	d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$18001800,d5
		swap	d5
		move.l	d5,(a6)
		rts
; End of function sub_6B32

; ===========================================================================
		rts
; ===========================================================================
		move.l	d0,(a5)
		move.w	#$2000,d5
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		move.w	(a1)+,d4
		add.w	d5,d4
		move.w	d4,(a6)
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6BD6:				; XREF: sub_6ADA; sub_6B06
		lea	($FFFFB000).w,a1
		add.w	4(a3),d4
		add.w	(a3),d5
		move.w	d4,d3
		lsr.w	#1,d3
		andi.w	#$380,d3
		lsr.w	#3,d5
		move.w	d5,d0
		lsr.w	#5,d0
		andi.w	#$7F,d0
		add.w	d3,d0
		moveq	#-1,d3
		move.b	(a4,d0.w),d3
		beq.s	locret_6C1E
		subq.b	#1,d3
		andi.w	#$7F,d3
		ror.w	#7,d3
		add.w	d4,d4
		andi.w	#$1E0,d4
		andi.w	#$1E,d5
		add.w	d4,d3
		add.w	d5,d3
		movea.l	d3,a0
		move.w	(a0),d3
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		adda.w	d3,a1

locret_6C1E:
		rts
; End of function sub_6BD6


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6C20:				; XREF: LoadTilesAsYouMove; et al
		add.w	4(a3),d4
		add.w	(a3),d5
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#3,d0
		swap	d0
		move.w	d4,d0
		rts
; End of function sub_6C20


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; not used


sub_6C3C:
		add.w	4(a3),d4
		add.w	(a3),d5
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#2,d0
		swap	d0
		move.w	d4,d0
		rts
; End of function sub_6C3C

; ---------------------------------------------------------------------------
; Subroutine to	load tiles as soon as the level	appears
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesFromStart:			; XREF: Level; EndingSequence
		lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	($FFFFF700).w,a3
		lea	($FFFFA400).w,a4
		move.w	#$4000,d2
		bsr.s	LoadTilesFromStart2
		lea	($FFFFF708).w,a3
		lea	($FFFFA440).w,a4
		move.w	#$6000,d2
; End of function LoadTilesFromStart


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesFromStart2:			; XREF: LoadTilesFromStart
		moveq	#-$10,d4
		moveq	#$F,d6

loc_6C82:
		movem.l	d4-d6,-(sp)
		moveq	#0,d5
		move.w	d4,d1
		bsr.w	sub_6C20
		move.w	d1,d4
		moveq	#0,d5
		moveq	#$1F,d6
		bsr.w	sub_6ADA
		movem.l	(sp)+,d4-d6
		addi.w	#$10,d4
		dbf	d6,loc_6C82
		rts
; End of function LoadTilesFromStart2

; ---------------------------------------------------------------------------
; Main Load Block loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MainLoadBlockLoad:			; XREF: Level; EndingSequence
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		lsl.w	#4,d0
		lea	(MainLoadBlocks).l,a2
		lea	(a2,d0.w),a2
		move.l	a2,-(sp)
		addq.l	#4,a2
		movea.l	(a2)+,a0
		lea	($FFFFB000).w,a1 ; RAM address for 16x16 mappings
		move.w	#0,d0
		bsr.w	EniDec
		movea.l	(a2)+,a0
		lea	($FF0000).l,a1	; RAM address for 256x256 mappings
		bsr.w	KosDec
		bsr.w	LevelLayoutLoad
		move.w	(a2)+,d0
		move.w	(a2),d0
		andi.w	#$FF,d0
		cmpi.w	#$103,($FFFFFE10).w ; is level SBZ3 (LZ4) ?
		bne.s	MLB_ChkSBZPal	; if not, branch
		moveq	#$C,d0		; use SB3 pallet

MLB_ChkSBZPal:
		cmpi.w	#$501,($FFFFFE10).w ; is level SBZ2?
		beq.s	MLB_UsePal0E	; if yes, branch
		cmpi.w	#$502,($FFFFFE10).w ; is level FZ?
		bne.s	MLB_NormalPal	; if not, branch

MLB_UsePal0E:
		moveq	#$E,d0		; use SBZ2/FZ pallet

MLB_NormalPal:
		bsr.w	PalLoad1	; load pallet (based on	d0)
		movea.l	(sp)+,a2
		addq.w	#4,a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	locret_6D10
		bsr.w	LoadPLC		; load pattern load cues

locret_6D10:
		rts
; End of function MainLoadBlockLoad

; ---------------------------------------------------------------------------
; Level	layout loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevelLayoutLoad:			; XREF: TitleScreen; MainLoadBlockLoad
		lea	($FFFFA400).w,a3
		move.w	#$1FF,d1
		moveq	#0,d0

LevLoad_ClrRam:
		move.l	d0,(a3)+
		dbf	d1,LevLoad_ClrRam ; clear the RAM ($FFFFA400-A7FF)

		lea	($FFFFA400).w,a3 ; RAM address for level layout
		moveq	#0,d1
		bsr.w	LevelLayoutLoad2 ; load	level layout into RAM
		lea	($FFFFA440).w,a3 ; RAM address for background layout
		moveq	#2,d1
; End of function LevelLayoutLoad

; "LevelLayoutLoad2" is	run twice - for	the level and the background

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevelLayoutLoad2:			; XREF: LevelLayoutLoad
		move.w	($FFFFFE10).w,d0
		lsl.b	#6,d0
		lsr.w	#5,d0
		move.w	d0,d2
		add.w	d0,d0
		add.w	d2,d0
		add.w	d1,d0
		lea	(Level_Index).l,a1
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		moveq	#0,d1
		move.w	d1,d2
		move.b	(a1)+,d1	; load level width (in tiles)
		move.b	(a1)+,d2	; load level height (in	tiles)

LevLoad_NumRows:
		move.w	d1,d0
		movea.l	a3,a0

LevLoad_Row:
		move.b	(a1)+,(a0)+
		dbf	d0,LevLoad_Row	; load 1 row
		lea	$80(a3),a3	; do next row
		dbf	d2,LevLoad_NumRows ; repeat for	number of rows
		rts
; End of function LevelLayoutLoad2

; ---------------------------------------------------------------------------
; Dynamic screen resize	loading	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DynScrResizeLoad:			; XREF: DeformBgLayer
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		add.w	d0,d0
		move.w	Resize_Index(pc,d0.w),d0
		jsr	Resize_Index(pc,d0.w)
		moveq	#2,d1
		move.w	($FFFFF726).w,d0
		sub.w	($FFFFF72E).w,d0
		beq.s	locret_6DAA
		bcc.s	loc_6DAC
		neg.w	d1
		move.w	($FFFFF704).w,d0
		cmp.w	($FFFFF726).w,d0
		bls.s	loc_6DA0
		move.w	d0,($FFFFF72E).w
		andi.w	#-2,($FFFFF72E).w

loc_6DA0:
		add.w	d1,($FFFFF72E).w
		move.b	#1,($FFFFF75C).w

locret_6DAA:
		rts
; ===========================================================================

loc_6DAC:				; XREF: DynScrResizeLoad
		move.w	($FFFFF704).w,d0
		addq.w	#8,d0
		cmp.w	($FFFFF72E).w,d0
		bcs.s	loc_6DC4
		btst	#1,($FFFFD022).w
		beq.s	loc_6DC4
		add.w	d1,d1
		add.w	d1,d1

loc_6DC4:
		add.w	d1,($FFFFF72E).w
		move.b	#1,($FFFFF75C).w
		rts
; End of function DynScrResizeLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Offset index for dynamic screen resizing
; ---------------------------------------------------------------------------
Resize_Index:	dc.w Resize_GHZ-Resize_Index, Resize_LZ-Resize_Index
		dc.w Resize_MZ-Resize_Index, Resize_SLZ-Resize_Index
		dc.w Resize_SYZ-Resize_Index, Resize_SBZ-Resize_Index
		dc.w Resize_Ending-Resize_Index
; ===========================================================================
; ---------------------------------------------------------------------------
; Green	Hill Zone dynamic screen resizing
; ---------------------------------------------------------------------------

Resize_GHZ:				; XREF: Resize_Index
		moveq	#0,d0
		move.b	($FFFFFE11).w,d0
		add.w	d0,d0
		move.w	Resize_GHZx(pc,d0.w),d0
		jmp	Resize_GHZx(pc,d0.w)
; ===========================================================================
Resize_GHZx:	dc.w Resize_GHZ1-Resize_GHZx
		dc.w Resize_GHZ2-Resize_GHZx
		dc.w Resize_GHZ3-Resize_GHZx
; ===========================================================================

Resize_GHZ1:
		move.w	#$300,($FFFFF726).w ; set lower	y-boundary
		cmpi.w	#$1780,($FFFFF700).w ; has the camera reached $1780 on x-axis?
		bcs.s	locret_6E08	; if not, branch
		move.w	#$400,($FFFFF726).w ; set lower	y-boundary

locret_6E08:
		rts
; ===========================================================================

Resize_GHZ2:
		move.w	#$300,($FFFFF726).w
		cmpi.w	#$ED0,($FFFFF700).w
		bcs.s	locret_6E3A
		move.w	#$200,($FFFFF726).w
		cmpi.w	#$1600,($FFFFF700).w
		bcs.s	locret_6E3A
		move.w	#$400,($FFFFF726).w
		cmpi.w	#$1D60,($FFFFF700).w
		bcs.s	locret_6E3A
		move.w	#$300,($FFFFF726).w

locret_6E3A:
		rts
; ===========================================================================

Resize_GHZ3:
		moveq	#0,d0
		move.b	($FFFFF742).w,d0
		move.w	off_6E4A(pc,d0.w),d0
		jmp	off_6E4A(pc,d0.w)
; ===========================================================================
off_6E4A:	dc.w Resize_GHZ3main-off_6E4A
		dc.w Resize_GHZ3boss-off_6E4A
		dc.w Resize_GHZ3end-off_6E4A
; ===========================================================================

Resize_GHZ3main:
		move.w	#$300,($FFFFF726).w
		cmpi.w	#$380,($FFFFF700).w
		bcs.s	locret_6E96
		move.w	#$310,($FFFFF726).w
		cmpi.w	#$960,($FFFFF700).w
		bcs.s	locret_6E96
		cmpi.w	#$280,($FFFFF704).w
		bcs.s	loc_6E98
		move.w	#$400,($FFFFF726).w
		cmpi.w	#$1380,($FFFFF700).w
		bcc.s	loc_6E8E
		move.w	#$4C0,($FFFFF726).w
		move.w	#$4C0,($FFFFF72E).w

loc_6E8E:
		cmpi.w	#$1700,($FFFFF700).w
		bcc.s	loc_6E98

locret_6E96:
		rts
; ===========================================================================

loc_6E98:
		move.w	#$300,($FFFFF726).w
		addq.b	#2,($FFFFF742).w
		rts
; ===========================================================================

Resize_GHZ3boss:
		cmpi.w	#$960,($FFFFF700).w
		bcc.s	loc_6EB0
		subq.b	#2,($FFFFF742).w

loc_6EB0:
		cmpi.w	#$2960,($FFFFF700).w
		bcs.s	locret_6EE8
		bsr.w	SingleObjLoad
		bne.s	loc_6ED0
		move.b	#$3D,0(a1)	; load GHZ boss	object
		move.w	#$2A60,8(a1)
		move.w	#$280,$C(a1)

loc_6ED0:
		moveq	#mus_Boss,d0
		bsr.w	PlaySound	; play boss music
		move.b	#1,($FFFFF7AA).w ; lock	screen
		addq.b	#2,($FFFFF742).w
		moveq	#$11,d0
		bra.w	LoadPLC		; load boss patterns
; ===========================================================================

locret_6EE8:
		rts
; ===========================================================================

Resize_GHZ3end:
		move.w	($FFFFF700).w,($FFFFF728).w
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Labyrinth Zone dynamic screen	resizing
; ---------------------------------------------------------------------------

Resize_LZ:				; XREF: Resize_Index
		moveq	#0,d0
		move.b	($FFFFFE11).w,d0
		add.w	d0,d0
		move.w	Resize_LZx(pc,d0.w),d0
		jmp	Resize_LZx(pc,d0.w)
; ===========================================================================
Resize_LZx:	dc.w Resize_LZ12-Resize_LZx
		dc.w Resize_LZ12-Resize_LZx
		dc.w Resize_LZ3-Resize_LZx
		dc.w Resize_SBZ3-Resize_LZx
; ===========================================================================

Resize_LZ12:
		rts
; ===========================================================================

Resize_LZ3:
		tst.b	($FFFFF7EF).w	; has switch $F	been pressed?
		beq.s	loc_6F28	; if not, branch
		lea	($FFFFA506).w,a1
		cmpi.b	#7,(a1)
		beq.s	loc_6F28
		move.b	#7,(a1)		; modify level layout
		moveq	#sfx_Rumble,d0
		bsr.w	PlaySound_Special ; play rumbling sound

loc_6F28:
		tst.b	($FFFFF742).w
		bne.s	locret_6F64
		cmpi.w	#$1CA0,($FFFFF700).w
		bcs.s	locret_6F62
		cmpi.w	#$600,($FFFFF704).w
		bcc.s	locret_6F62
		bsr.w	SingleObjLoad
		bne.s	loc_6F4A
		move.b	#$77,0(a1)	; load LZ boss object

loc_6F4A:
		moveq	#mus_Boss,d0
		bsr.w	PlaySound	; play boss music
		move.b	#1,($FFFFF7AA).w ; lock	screen
		addq.b	#2,($FFFFF742).w
		moveq	#$11,d0
		bra.w	LoadPLC		; load boss patterns
; ===========================================================================

locret_6F62:
		rts
; ===========================================================================

locret_6F64:
		rts
; ===========================================================================

Resize_SBZ3:
		cmpi.w	#$D00,($FFFFF700).w
		bcs.s	locret_6F8C
		cmpi.w	#$18,($FFFFD00C).w ; has Sonic reached the top of the level?
		bcc.s	locret_6F8C	; if not, branch
		clr.b	($FFFFFE30).w
		move.w	#1,($FFFFFE02).w ; restart level
		move.w	#$502,($FFFFFE10).w ; set level	number to 0502 (FZ)
		move.b	#1,($FFFFF7C8).w ; freeze Sonic

locret_6F8C:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Marble Zone dynamic screen resizing
; ---------------------------------------------------------------------------

Resize_MZ:				; XREF: Resize_Index
		moveq	#0,d0
		move.b	($FFFFFE11).w,d0
		add.w	d0,d0
		move.w	Resize_MZx(pc,d0.w),d0
		jmp	Resize_MZx(pc,d0.w)
; ===========================================================================
Resize_MZx:	dc.w Resize_MZ1-Resize_MZx
		dc.w Resize_MZ2-Resize_MZx
		dc.w Resize_MZ3-Resize_MZx
; ===========================================================================

Resize_MZ1:
		moveq	#0,d0
		move.b	($FFFFF742).w,d0
		move.w	off_6FB2(pc,d0.w),d0
		jmp	off_6FB2(pc,d0.w)
; ===========================================================================
off_6FB2:	dc.w loc_6FBA-off_6FB2
		dc.w loc_6FEA-off_6FB2
		dc.w loc_702E-off_6FB2
		dc.w loc_7050-off_6FB2
; ===========================================================================

loc_6FBA:
		move.w	#$1D0,($FFFFF726).w
		cmpi.w	#$700,($FFFFF700).w
		bcs.s	locret_6FE8
		move.w	#$220,($FFFFF726).w
		cmpi.w	#$D00,($FFFFF700).w
		bcs.s	locret_6FE8
		move.w	#$340,($FFFFF726).w
		cmpi.w	#$340,($FFFFF704).w
		bcs.s	locret_6FE8
		addq.b	#2,($FFFFF742).w

locret_6FE8:
		rts
; ===========================================================================

loc_6FEA:
		cmpi.w	#$340,($FFFFF704).w
		bcc.s	loc_6FF8
		subq.b	#2,($FFFFF742).w
		rts
; ===========================================================================

loc_6FF8:
		move.w	#0,($FFFFF72C).w
		cmpi.w	#$E00,($FFFFF700).w
		bcc.s	locret_702C
		move.w	#$340,($FFFFF72C).w
		move.w	#$340,($FFFFF726).w
		cmpi.w	#$A90,($FFFFF700).w
		bcc.s	locret_702C
		move.w	#$500,($FFFFF726).w
		cmpi.w	#$370,($FFFFF704).w
		bcs.s	locret_702C
		addq.b	#2,($FFFFF742).w

locret_702C:
		rts
; ===========================================================================

loc_702E:
		cmpi.w	#$370,($FFFFF704).w
		bcc.s	loc_703C
		subq.b	#2,($FFFFF742).w
		rts
; ===========================================================================

loc_703C:
		cmpi.w	#$500,($FFFFF704).w
		bcs.s	locret_704E
		move.w	#$500,($FFFFF72C).w
		addq.b	#2,($FFFFF742).w

locret_704E:
		rts
; ===========================================================================

loc_7050:
		cmpi.w	#$E70,($FFFFF700).w
		bcs.s	locret_7072
		move.w	#0,($FFFFF72C).w
		move.w	#$500,($FFFFF726).w
		cmpi.w	#$1430,($FFFFF700).w
		bcs.s	locret_7072
		move.w	#$210,($FFFFF726).w

locret_7072:
		rts
; ===========================================================================

Resize_MZ2:
		move.w	#$520,($FFFFF726).w
		cmpi.w	#$1700,($FFFFF700).w
		bcs.s	locret_7088
		move.w	#$200,($FFFFF726).w

locret_7088:
		rts
; ===========================================================================

Resize_MZ3:
		moveq	#0,d0
		move.b	($FFFFF742).w,d0
		move.w	off_7098(pc,d0.w),d0
		jmp	off_7098(pc,d0.w)
; ===========================================================================
off_7098:	dc.w Resize_MZ3boss-off_7098
		dc.w Resize_MZ3end-off_7098
; ===========================================================================

Resize_MZ3boss:
		move.w	#$720,($FFFFF726).w
		cmpi.w	#$1560,($FFFFF700).w
		bcs.s	locret_70E8
		move.w	#$210,($FFFFF726).w
		cmpi.w	#$17F0,($FFFFF700).w
		bcs.s	locret_70E8
		bsr.w	SingleObjLoad
		bne.s	loc_70D0
		move.b	#$73,0(a1)	; load MZ boss object
		move.w	#$19F0,8(a1)
		move.w	#$22C,$C(a1)

loc_70D0:
		moveq	#mus_Boss,d0
		bsr.w	PlaySound	; play boss music
		move.b	#1,($FFFFF7AA).w ; lock	screen
		addq.b	#2,($FFFFF742).w
		moveq	#$11,d0
		bra.w	LoadPLC		; load boss patterns
; ===========================================================================

locret_70E8:
		rts
; ===========================================================================

Resize_MZ3end:
		move.w	($FFFFF700).w,($FFFFF728).w
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Star Light Zone dynamic screen resizing
; ---------------------------------------------------------------------------

Resize_SLZ:				; XREF: Resize_Index
		moveq	#0,d0
		move.b	($FFFFFE11).w,d0
		add.w	d0,d0
		move.w	Resize_SLZx(pc,d0.w),d0
		jmp	Resize_SLZx(pc,d0.w)
; ===========================================================================
Resize_SLZx:	dc.w Resize_SLZ12-Resize_SLZx
		dc.w Resize_SLZ12-Resize_SLZx
		dc.w Resize_SLZ3-Resize_SLZx
; ===========================================================================

Resize_SLZ12:
		rts
; ===========================================================================

Resize_SLZ3:
		moveq	#0,d0
		move.b	($FFFFF742).w,d0
		move.w	off_7118(pc,d0.w),d0
		jmp	off_7118(pc,d0.w)
; ===========================================================================
off_7118:	dc.w Resize_SLZ3main-off_7118
		dc.w Resize_SLZ3boss-off_7118
		dc.w Resize_SLZ3end-off_7118
; ===========================================================================

Resize_SLZ3main:
		cmpi.w	#$1E70,($FFFFF700).w
		bcs.s	locret_7130
		move.w	#$210,($FFFFF726).w
		addq.b	#2,($FFFFF742).w

locret_7130:
		rts
; ===========================================================================

Resize_SLZ3boss:
		cmpi.w	#$2000,($FFFFF700).w
		bcs.s	locret_715C
		bsr.w	SingleObjLoad
		bne.s	loc_7144
		move.b	#$7A,(a1)	; load SLZ boss	object

loc_7144:
		moveq	#mus_Boss,d0
		bsr.w	PlaySound	; play boss music
		move.b	#1,($FFFFF7AA).w ; lock	screen
		addq.b	#2,($FFFFF742).w
		moveq	#$11,d0
		bra.w	LoadPLC		; load boss patterns
; ===========================================================================

locret_715C:
		rts
; ===========================================================================

Resize_SLZ3end:
		move.w	($FFFFF700).w,($FFFFF728).w
		rts
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Spring Yard Zone dynamic screen resizing
; ---------------------------------------------------------------------------

Resize_SYZ:				; XREF: Resize_Index
		moveq	#0,d0
		move.b	($FFFFFE11).w,d0
		add.w	d0,d0
		move.w	Resize_SYZx(pc,d0.w),d0
		jmp	Resize_SYZx(pc,d0.w)
; ===========================================================================
Resize_SYZx:	dc.w Resize_SYZ1-Resize_SYZx
		dc.w Resize_SYZ2-Resize_SYZx
		dc.w Resize_SYZ3-Resize_SYZx
; ===========================================================================

Resize_SYZ1:
		rts
; ===========================================================================

Resize_SYZ2:
		move.w	#$520,($FFFFF726).w
		cmpi.w	#$25A0,($FFFFF700).w
		bcs.s	locret_71A2
		move.w	#$420,($FFFFF726).w
		cmpi.w	#$4D0,($FFFFD00C).w
		bcs.s	locret_71A2
		move.w	#$520,($FFFFF726).w

locret_71A2:
		rts
; ===========================================================================

Resize_SYZ3:
		moveq	#0,d0
		move.b	($FFFFF742).w,d0
		move.w	off_71B2(pc,d0.w),d0
		jmp	off_71B2(pc,d0.w)
; ===========================================================================
off_71B2:	dc.w Resize_SYZ3main-off_71B2
		dc.w Resize_SYZ3boss-off_71B2
		dc.w Resize_SYZ3end-off_71B2
; ===========================================================================

Resize_SYZ3main:
		cmpi.w	#$2AC0,($FFFFF700).w
		bcs.s	locret_71CE
		bsr.w	SingleObjLoad
		bne.s	locret_71CE
		move.b	#$76,(a1)	; load blocks that boss	picks up
		addq.b	#2,($FFFFF742).w

locret_71CE:
		rts
; ===========================================================================

Resize_SYZ3boss:
		cmpi.w	#$2C00,($FFFFF700).w
		bcs.s	locret_7200
		move.w	#$4CC,($FFFFF726).w
		bsr.w	SingleObjLoad
		bne.s	loc_71EC
		move.b	#$75,(a1)	; load SYZ boss	object
		addq.b	#2,($FFFFF742).w

loc_71EC:
		moveq	#mus_Boss,d0
		bsr.w	PlaySound	; play boss music
		move.b	#1,($FFFFF7AA).w ; lock	screen
		moveq	#$11,d0
		bra.w	LoadPLC		; load boss patterns
; ===========================================================================

locret_7200:
		rts
; ===========================================================================

Resize_SYZ3end:
		move.w	($FFFFF700).w,($FFFFF728).w
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Scrap	Brain Zone dynamic screen resizing
; ---------------------------------------------------------------------------

Resize_SBZ:				; XREF: Resize_Index
		moveq	#0,d0
		move.b	($FFFFFE11).w,d0
		add.w	d0,d0
		move.w	Resize_SBZx(pc,d0.w),d0
		jmp	Resize_SBZx(pc,d0.w)
; ===========================================================================
Resize_SBZx:	dc.w Resize_SBZ1-Resize_SBZx
		dc.w Resize_SBZ2-Resize_SBZx
		dc.w Resize_FZ-Resize_SBZx
; ===========================================================================

Resize_SBZ1:
		move.w	#$720,($FFFFF726).w
		cmpi.w	#$1880,($FFFFF700).w
		bcs.s	locret_7242
		move.w	#$620,($FFFFF726).w
		cmpi.w	#$2000,($FFFFF700).w
		bcs.s	locret_7242
		move.w	#$2A0,($FFFFF726).w

locret_7242:
		rts
; ===========================================================================

Resize_SBZ2:
		moveq	#0,d0
		move.b	($FFFFF742).w,d0
		move.w	off_7252(pc,d0.w),d0
		jmp	off_7252(pc,d0.w)
; ===========================================================================
off_7252:	dc.w Resize_SBZ2main-off_7252
		dc.w Resize_SBZ2boss-off_7252
		dc.w Resize_SBZ2boss2-off_7252
		dc.w Resize_SBZ2end-off_7252
; ===========================================================================

Resize_SBZ2main:
		move.w	#$800,($FFFFF726).w
		cmpi.w	#$1800,($FFFFF700).w
		bcs.s	locret_727A
		move.w	#$510,($FFFFF726).w
		cmpi.w	#$1E00,($FFFFF700).w
		bcs.s	locret_727A
		addq.b	#2,($FFFFF742).w

locret_727A:
		rts
; ===========================================================================

Resize_SBZ2boss:
		cmpi.w	#$1EB0,($FFFFF700).w
		bcs.s	locret_7298
		bsr.w	SingleObjLoad
		bne.s	locret_7298
		move.b	#$83,(a1)	; load collapsing block	object
		addq.b	#2,($FFFFF742).w
		moveq	#$1E,d0
		bra.w	LoadPLC		; load SBZ2 Eggman patterns
; ===========================================================================

locret_7298:
		rts
; ===========================================================================

Resize_SBZ2boss2:
		cmpi.w	#$1F60,($FFFFF700).w
		bcs.s	loc_72B6
		bsr.w	SingleObjLoad
		bne.s	loc_72B0
		move.b	#$82,(a1)	; load SBZ2 Eggman object
		addq.b	#2,($FFFFF742).w

loc_72B0:
		move.b	#1,($FFFFF7AA).w ; lock	screen

loc_72B6:
		bra.s	loc_72C2
; ===========================================================================

Resize_SBZ2end:
		cmpi.w	#$2050,($FFFFF700).w
		bcs.s	loc_72C2
		rts
; ===========================================================================

loc_72C2:
		move.w	($FFFFF700).w,($FFFFF728).w
		rts
; ===========================================================================

Resize_FZ:
		moveq	#0,d0
		move.b	($FFFFF742).w,d0
		move.w	off_72D8(pc,d0.w),d0
		jmp	off_72D8(pc,d0.w)
; ===========================================================================
off_72D8:	dc.w Resize_FZmain-off_72D8, Resize_FZboss-off_72D8
		dc.w Resize_FZend-off_72D8, locret_7322-off_72D8
		dc.w Resize_FZend2-off_72D8
; ===========================================================================

Resize_FZmain:
		cmpi.w	#$2148,($FFFFF700).w
		bcs.s	loc_72F4
		addq.b	#2,($FFFFF742).w
		moveq	#$1F,d0
		bsr.w	LoadPLC		; load FZ boss patterns

loc_72F4:
		bra.s	loc_72C2
; ===========================================================================

Resize_FZboss:
		cmpi.w	#$2300,($FFFFF700).w
		bcs.s	loc_7312
		bsr.w	SingleObjLoad
		bne.s	loc_7312
		move.b	#$85,(a1)	; load FZ boss object
		addq.b	#2,($FFFFF742).w
		move.b	#1,($FFFFF7AA).w ; lock	screen

loc_7312:
		bra.s	loc_72C2
; ===========================================================================

Resize_FZend:
		cmpi.w	#$2450,($FFFFF700).w
		bcs.s	loc_7320
		addq.b	#2,($FFFFF742).w

loc_7320:
		bra.s	loc_72C2
; ===========================================================================

locret_7322:
		rts
; ===========================================================================

Resize_FZend2:
		bra.s	loc_72C2
; ===========================================================================
; ---------------------------------------------------------------------------
; Ending sequence dynamic screen resizing (empty)
; ---------------------------------------------------------------------------

Resize_Ending:				; XREF: Resize_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 11 - GHZ bridge
; ---------------------------------------------------------------------------

Obj11:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj11_Index(pc,d0.w),d1
		jmp	Obj11_Index(pc,d1.w)
; ===========================================================================
Obj11_Index:	dc.w Obj11_Main-Obj11_Index, Obj11_Action-Obj11_Index
		dc.w Obj11_Action2-Obj11_Index,	Obj11_Delete2-Obj11_Index
		dc.w Obj11_Delete2-Obj11_Index,	Obj11_Display2-Obj11_Index
; ===========================================================================

Obj11_Main:				; XREF: Obj11_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj11,4(a0)
		move.w	#$438E,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$80,$19(a0)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		move.b	0(a0),d4	; copy object number ($11) to d4
		lea	$28(a0),a2	; copy bridge subtype to a2
		moveq	#0,d1
		move.b	(a2),d1		; copy a2 to d1
		move.b	#0,(a2)+
		move.w	d1,d0
		lsr.w	#1,d0
		lsl.w	#4,d0
		sub.w	d0,d3
		subq.b	#2,d1
		bcs.s	Obj11_Action

Obj11_MakeBdg:
		bsr.w	SingleObjLoad
		bne.s	Obj11_Action
		addq.b	#1,$28(a0)
		cmp.w	8(a0),d3
		bne.s	loc_73B8
		addi.w	#$10,d3
		move.w	d2,$C(a0)
		move.w	d2,$3C(a0)
		move.w	a0,d5
		subi.w	#-$3000,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		addq.b	#1,$28(a0)

loc_73B8:				; XREF: ROM:00007398j
		move.w	a1,d5
		subi.w	#-$3000,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	#$A,$24(a1)
		move.b	d4,0(a1)	; load bridge object (d4 = $11)
		move.w	d2,$C(a1)
		move.w	d2,$3C(a1)
		move.w	d3,8(a1)
		move.l	#Map_obj11,4(a1)
		move.w	#$438E,2(a1)
		move.b	#4,1(a1)
		move.b	#3,$18(a1)
		move.b	#8,$19(a1)
		addi.w	#$10,d3
		dbf	d1,Obj11_MakeBdg ; repeat d1 times (length of bridge)

Obj11_Action:				; XREF: Obj11_Index
		bsr.s	Obj11_Solid
		tst.b	$3E(a0)
		beq.s	Obj11_Display
		subq.b	#4,$3E(a0)
		bsr.w	Obj11_Bend

Obj11_Display:
		bsr.w	DisplaySprite
		bra.w	Obj11_ChkDel

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj11_Solid:				; XREF: Obj11_Action
		moveq	#0,d1
		move.b	$28(a0),d1
		lsl.w	#3,d1
		move.w	d1,d2
		addq.w	#8,d1
		add.w	d2,d2
		lea	($FFFFD000).w,a1
		tst.w	$12(a1)
		bmi.w	locret_751E
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.w	locret_751E
		cmp.w	d2,d0
		bcc.w	locret_751E
		bra.s	Platform2
; End of function Obj11_Solid

; ---------------------------------------------------------------------------
; Platform subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PlatformObject:
		lea	($FFFFD000).w,a1
		tst.w	$12(a1)
		bmi.w	locret_751E
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.w	locret_751E
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.w	locret_751E

Platform2:
		move.w	$C(a0),d0
		subq.w	#8,d0

Platform3:
		move.w	$C(a1),d2
		move.b	$16(a1),d1
		ext.w	d1
		add.w	d2,d1
		addq.w	#4,d1
		sub.w	d1,d0
		bhi.w	locret_751E
		cmpi.w	#-$10,d0
		bcs.w	locret_751E
		tst.b	($FFFFF7C8).w
		bmi.w	locret_751E
		cmpi.b	#6,$24(a1)
		bcc.w	locret_751E
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,$C(a1)
		addq.b	#2,$24(a0)

loc_74AE:
		btst	#3,$22(a1)
		beq.s	loc_74DC
		moveq	#0,d0
		move.b	$3D(a1),d0
		lsl.w	#6,d0
		addi.l	#$FFD000,d0
		movea.l	d0,a2
		bclr	#3,$22(a2)
		clr.b	$25(a2)
		cmpi.b	#4,$24(a2)
		bne.s	loc_74DC
		subq.b	#2,$24(a2)

loc_74DC:
		move.w	a0,d0
		subi.w	#-$3000,d0
		lsr.w	#6,d0
		andi.w	#$7F,d0
		move.b	d0,$3D(a1)
		move.b	#0,$26(a1)
		move.w	#0,$12(a1)
		move.w	$10(a1),$14(a1)
		btst	#1,$22(a1)
		beq.s	loc_7512
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	Sonic_ResetOnFloor
		movea.l	(sp)+,a0

loc_7512:
		bset	#3,$22(a1)
		bset	#3,$22(a0)

locret_751E:
		rts
; End of function PlatformObject

; ---------------------------------------------------------------------------
; Sloped platform subroutine (GHZ collapsing ledges and	SLZ seesaws)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SlopeObject:				; XREF: Obj1A_Slope; Obj5E_Slope
		lea	($FFFFD000).w,a1
		tst.w	$12(a1)
		bmi.w	locret_751E
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	locret_751E
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.s	locret_751E
		btst	#0,1(a0)
		beq.s	loc_754A
		not.w	d0
		add.w	d1,d0

loc_754A:
		lsr.w	#1,d0
		moveq	#0,d3
		move.b	(a2,d0.w),d3
		move.w	$C(a0),d0
		sub.w	d3,d0
		bra.w	Platform3
; End of function SlopeObject


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj15_Solid:				; XREF: Obj15_SetSolid
		lea	($FFFFD000).w,a1
		tst.w	$12(a1)
		bmi.w	locret_751E
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.w	locret_751E
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.w	locret_751E
		move.w	$C(a0),d0
		sub.w	d3,d0
		bra.w	Platform3
; End of function Obj15_Solid

; ===========================================================================

Obj11_Action2:				; XREF: Obj11_Index
		bsr.s	Obj11_WalkOff
		bsr.w	DisplaySprite
		bra.w	Obj11_ChkDel

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk off a bridge
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj11_WalkOff:				; XREF: Obj11_Action2
		moveq	#0,d1
		move.b	$28(a0),d1
		lsl.w	#3,d1
		move.w	d1,d2
		addq.w	#8,d1
		bsr.s	ExitPlatform2
		bcc.s	locret_75BE
		lsr.w	#4,d0
		move.b	d0,$3F(a0)
		move.b	$3E(a0),d0
		cmpi.b	#$40,d0
		beq.s	loc_75B6
		addq.b	#4,$3E(a0)

loc_75B6:
		bsr.w	Obj11_Bend
		bsr.w	Obj11_MoveSonic

locret_75BE:
		rts
; End of function Obj11_WalkOff

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk or jump off	a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ExitPlatform:
		move.w	d1,d2

ExitPlatform2:
		add.w	d2,d2
		lea	($FFFFD000).w,a1
		btst	#1,$22(a1)
		bne.s	loc_75E0
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_75E0
		cmp.w	d2,d0
		bcs.s	locret_75F2

loc_75E0:
		bclr	#3,$22(a1)
		move.b	#2,$24(a0)
		bclr	#3,$22(a0)

locret_75F2:
		rts
; End of function ExitPlatform


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj11_MoveSonic:			; XREF: Obj11_WalkOff
		moveq	#0,d0
		move.b	$3F(a0),d0
		move.b	$29(a0,d0.w),d0
		lsl.w	#6,d0
		addi.l	#$FFD000,d0
		movea.l	d0,a2
		lea	($FFFFD000).w,a1
		move.w	$C(a2),d0
		subq.w	#8,d0
		moveq	#0,d1
		move.b	$16(a1),d1
		sub.w	d1,d0
		move.w	d0,$C(a1)	; change Sonic's position on y-axis
		rts
; End of function Obj11_MoveSonic


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj11_Bend:				; XREF: Obj11_Action; Obj11_WalkOff
		move.b	$3E(a0),d0
		bsr.w	CalcSine
		move.w	d0,d4
		lea	(Obj11_BendData2).l,a4
		moveq	#0,d0
		move.b	$28(a0),d0
		lsl.w	#4,d0
		moveq	#0,d3
		move.b	$3F(a0),d3
		move.w	d3,d2
		add.w	d0,d3
		moveq	#0,d5
		lea	(Obj11_BendData).l,a5
		move.b	(a5,d3.w),d5
		andi.w	#$F,d3
		lsl.w	#4,d3
		lea	(a4,d3.w),a3
		lea	$29(a0),a2

loc_765C:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#$FFD000,d0
		movea.l	d0,a1
		moveq	#0,d0
		move.b	(a3)+,d0
		addq.w	#1,d0
		mulu.w	d5,d0
		mulu.w	d4,d0
		swap	d0
		add.w	$3C(a1),d0
		move.w	d0,$C(a1)
		dbf	d2,loc_765C
		moveq	#0,d0
		move.b	$28(a0),d0
		moveq	#0,d3
		move.b	$3F(a0),d3
		addq.b	#1,d3
		sub.b	d0,d3
		neg.b	d3
		bmi.s	locret_76CA
		move.w	d3,d2
		lsl.w	#4,d3
		lea	(a4,d3.w),a3
		adda.w	d2,a3
		subq.w	#1,d2
		bcs.s	locret_76CA

loc_76A4:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#$FFD000,d0
		movea.l	d0,a1
		moveq	#0,d0
		move.b	-(a3),d0
		addq.w	#1,d0
		mulu.w	d5,d0
		mulu.w	d4,d0
		swap	d0
		add.w	$3C(a1),d0
		move.w	d0,$C(a1)
		dbf	d2,loc_76A4

locret_76CA:
		rts
; End of function Obj11_Bend

; ===========================================================================
; ---------------------------------------------------------------------------
; GHZ bridge-bending data
; (Defines how the bridge bends	when Sonic walks across	it)
; ---------------------------------------------------------------------------
Obj11_BendData:	incbin	misc\ghzbend1.bin
		even
Obj11_BendData2:incbin	misc\ghzbend2.bin
		even

; ===========================================================================

Obj11_ChkDel:				; XREF: Obj11_Display; Obj11_Action2
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj11_DelAll
		rts
; ===========================================================================

Obj11_DelAll:				; XREF: Obj11_ChkDel
		moveq	#0,d2
		lea	$28(a0),a2	; load bridge length
		move.b	(a2)+,d2	; move bridge length to	d2
		subq.b	#1,d2		; subtract 1
		bcs.s	Obj11_Delete

Obj11_DelLoop:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#$FFD000,d0
		movea.l	d0,a1
		cmp.w	a0,d0
		beq.s	loc_791E
		bsr.w	DeleteObject2

loc_791E:
		dbf	d2,Obj11_DelLoop ; repeat d2 times (bridge length)

Obj11_Delete:
		bsr.w	DeleteObject
		rts
; ===========================================================================

Obj11_Delete2:				; XREF: Obj11_Index
		bsr.w	DeleteObject
		rts
; ===========================================================================

Obj11_Display2:				; XREF: Obj11_Index
		bsr.w	DisplaySprite
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - GHZ	bridge
; ---------------------------------------------------------------------------
Map_obj11:
	include "_maps\obj11.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 15 - swinging platforms (GHZ, MZ, SLZ)
;	    - spiked ball on a chain (SBZ)
; ---------------------------------------------------------------------------

Obj15:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj15_Index(pc,d0.w),d1
		jmp	Obj15_Index(pc,d1.w)
; ===========================================================================
Obj15_Index:	dc.w Obj15_Main-Obj15_Index, Obj15_SetSolid-Obj15_Index
		dc.w Obj15_Action2-Obj15_Index,	Obj15_Delete-Obj15_Index
		dc.w Obj15_Delete-Obj15_Index, Obj15_Display-Obj15_Index
		dc.w Obj15_Action-Obj15_Index
; ===========================================================================

Obj15_Main:				; XREF: Obj15_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj15,4(a0) ; GHZ and MZ specific code
		move.w	#$4380,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$18,$19(a0)
		move.b	#8,$16(a0)
		move.w	$C(a0),$38(a0)
		move.w	8(a0),$3A(a0)
		cmpi.b	#3,($FFFFFE10).w ; check if level is SLZ
		bne.s	Obj15_NotSLZ
		move.l	#Map_obj15a,4(a0) ; SLZ	specific code
		move.w	#$43DC,2(a0)
		move.b	#$20,$19(a0)
		move.b	#$10,$16(a0)
		move.b	#$99,$20(a0)

Obj15_NotSLZ:
		cmpi.b	#5,($FFFFFE10).w ; check if level is SBZ
		bne.s	Obj15_SetLength
		move.l	#Map_obj15b,4(a0) ; SBZ	specific code
		move.w	#$391,2(a0)
		move.b	#$18,$19(a0)
		move.b	#$18,$16(a0)
		move.b	#$86,$20(a0)
		move.b	#$C,$24(a0)

Obj15_SetLength:
		move.b	0(a0),d4
		moveq	#0,d1
		lea	$28(a0),a2	; move chain length to a2
		move.b	(a2),d1		; move a2 to d1
		move.w	d1,-(sp)
		andi.w	#$F,d1
		move.b	#0,(a2)+
		move.w	d1,d3
		lsl.w	#4,d3
		addq.b	#8,d3
		move.b	d3,$3C(a0)
		subq.b	#8,d3
		tst.b	$1A(a0)
		beq.s	Obj15_MakeChain
		addq.b	#8,d3
		subq.w	#1,d1

Obj15_MakeChain:
		bsr.w	SingleObjLoad
		bne.s	loc_7A92
		addq.b	#1,$28(a0)
		move.w	a1,d5
		subi.w	#-$3000,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	#$A,$24(a1)
		move.b	d4,0(a1)	; load swinging	object
		move.l	4(a0),4(a1)
		move.w	2(a0),2(a1)
		bclr	#6,2(a1)
		move.b	#4,1(a1)
		move.b	#4,$18(a1)
		move.b	#8,$19(a1)
		move.b	#1,$1A(a1)
		move.b	d3,$3C(a1)
		subi.b	#$10,d3
		bcc.s	loc_7A8E
		move.b	#2,$1A(a1)
		move.b	#3,$18(a1)
		bset	#6,2(a1)

loc_7A8E:
		dbf	d1,Obj15_MakeChain ; repeat d1 times (chain length)

loc_7A92:
		move.w	a0,d5
		subi.w	#-$3000,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.w	#$4080,$26(a0)
		move.w	#-$200,$3E(a0)
		move.w	(sp)+,d1
		btst	#4,d1		; is object type $8X ?
		beq.s	loc_7AD4	; if not, branch
		move.l	#Map_obj48,4(a0) ; use GHZ ball	mappings
		move.w	#$43AA,2(a0)
		move.b	#1,$1A(a0)
		move.b	#2,$18(a0)
		move.b	#$81,$20(a0)	; make object hurt when	touched

loc_7AD4:
		cmpi.b	#5,($FFFFFE10).w ; is zone SBZ?
		beq.s	Obj15_Action	; if yes, branch

Obj15_SetSolid:				; XREF: Obj15_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		moveq	#0,d3
		move.b	$16(a0),d3
		bsr.w	Obj15_Solid

Obj15_Action:				; XREF: Obj15_Index
		bsr.w	Obj15_Move
		bsr.w	DisplaySprite
		bra.w	Obj15_ChkDel
; ===========================================================================

Obj15_Action2:				; XREF: Obj15_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		bsr.w	ExitPlatform
		move.w	8(a0),-(sp)
		bsr.w	Obj15_Move
		move.w	(sp)+,d2
		moveq	#0,d3
		move.b	$16(a0),d3
		addq.b	#1,d3
		bsr.w	MvSonicOnPtfm
		bsr.w	DisplaySprite
		bra.w	Obj15_ChkDel

		rts

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's position with a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MvSonicOnPtfm:
		lea	($FFFFD000).w,a1
		move.w	$C(a0),d0
		sub.w	d3,d0
		bra.s	MvSonic2
; End of function MvSonicOnPtfm

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's position with a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MvSonicOnPtfm2:
		lea	($FFFFD000).w,a1
		move.w	$C(a0),d0
		subi.w	#9,d0

MvSonic2:
		tst.b	($FFFFF7C8).w
		bmi.s	locret_7B62
		cmpi.b	#6,($FFFFD024).w
		bcc.s	locret_7B62
		tst.w	($FFFFFE08).w
		bne.s	locret_7B62
		moveq	#0,d1
		move.b	$16(a1),d1
		sub.w	d1,d0
		move.w	d0,$C(a1)
		sub.w	8(a0),d2
		sub.w	d2,8(a1)

locret_7B62:
		rts
; End of function MvSonicOnPtfm2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj15_Move:				; XREF: Obj15_Action; Obj15_Action2
		move.b	($FFFFFE78).w,d0
		move.w	#$80,d1
		btst	#0,$22(a0)
		beq.s	loc_7B78
		neg.w	d0
		add.w	d1,d0

loc_7B78:
		bra.s	Obj15_Move2
; End of function Obj15_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj48_Move:				; XREF: Obj48_Display2
		tst.b	$3D(a0)
		bne.s	loc_7B9C
		move.w	$3E(a0),d0
		addq.w	#8,d0
		move.w	d0,$3E(a0)
		add.w	d0,$26(a0)
		cmpi.w	#$200,d0
		bne.s	loc_7BB6
		move.b	#1,$3D(a0)
		bra.s	loc_7BB6
; ===========================================================================

loc_7B9C:
		move.w	$3E(a0),d0
		subq.w	#8,d0
		move.w	d0,$3E(a0)
		add.w	d0,$26(a0)
		cmpi.w	#-$200,d0
		bne.s	loc_7BB6
		move.b	#0,$3D(a0)

loc_7BB6:
		move.b	$26(a0),d0
; End of function Obj48_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj15_Move2:				; XREF: Obj15_Move; Obj48_Display
		bsr.w	CalcSine
		move.w	$38(a0),d2
		move.w	$3A(a0),d3
		lea	$28(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

loc_7BCE:
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#6,d4
		addi.l	#$FFD000,d4
		movea.l	d4,a1
		moveq	#0,d4
		move.b	$3C(a1),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,$C(a1)
		move.w	d5,8(a1)
		dbf	d6,loc_7BCE
		rts
; End of function Obj15_Move2

; ===========================================================================

Obj15_ChkDel:				; XREF: Obj15_Action; Obj15_Action2
		move.w	$3A(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj15_DelAll
		rts
; ===========================================================================

Obj15_DelAll:				; XREF: Obj15_ChkDel
		moveq	#0,d2
		lea	$28(a0),a2
		move.b	(a2)+,d2

Obj15_DelLoop:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#$FFD000,d0
		movea.l	d0,a1
		bsr.w	DeleteObject2
		dbf	d2,Obj15_DelLoop ; repeat for length of	chain
		rts
; ===========================================================================

Obj15_Delete:				; XREF: Obj15_Index
		bsr.w	DeleteObject
		rts
; ===========================================================================

Obj15_Display:				; XREF: Obj15_Index
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - GHZ	and MZ swinging	platforms
; ---------------------------------------------------------------------------
Map_obj15:
	include "_maps\obj15ghz.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - SLZ	swinging platforms
; ---------------------------------------------------------------------------
Map_obj15a:
	include "_maps\obj15slz.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 17 - helix of spikes on a pole	(GHZ)
; ---------------------------------------------------------------------------

Obj17:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj17_Index(pc,d0.w),d1
		jmp	Obj17_Index(pc,d1.w)
; ===========================================================================
Obj17_Index:	dc.w Obj17_Main-Obj17_Index
		dc.w Obj17_Action-Obj17_Index
		dc.w Obj17_Action-Obj17_Index
		dc.w Obj17_Delete-Obj17_Index
		dc.w Obj17_Display-Obj17_Index
; ===========================================================================

Obj17_Main:				; XREF: Obj17_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj17,4(a0)
		move.w	#$4398,2(a0)
		move.b	#7,$22(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#8,$19(a0)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		move.b	0(a0),d4
		lea	$28(a0),a2	; move helix length to a2
		moveq	#0,d1
		move.b	(a2),d1		; move a2 to d1
		move.b	#0,(a2)+
		move.w	d1,d0
		lsr.w	#1,d0
		lsl.w	#4,d0
		sub.w	d0,d3
		subq.b	#2,d1
		bcs.s	Obj17_Action
		moveq	#0,d6

Obj17_MakeHelix:
		bsr.w	SingleObjLoad
		bne.s	Obj17_Action
		addq.b	#1,$28(a0)
		move.w	a1,d5
		subi.w	#$D000,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	#8,$24(a1)
		move.b	d4,0(a1)
		move.w	d2,$C(a1)
		move.w	d3,8(a1)
		move.l	4(a0),4(a1)
		move.w	#$4398,2(a1)
		move.b	#4,1(a1)
		move.b	#3,$18(a1)
		move.b	#8,$19(a1)
		move.b	d6,$3E(a1)
		addq.b	#1,d6
		andi.b	#7,d6
		addi.w	#$10,d3
		cmp.w	8(a0),d3
		bne.s	loc_7D78
		move.b	d6,$3E(a0)
		addq.b	#1,d6
		andi.b	#7,d6
		addi.w	#$10,d3
		addq.b	#1,$28(a0)

loc_7D78:
		dbf	d1,Obj17_MakeHelix ; repeat d1 times (helix length)

Obj17_Action:				; XREF: Obj17_Index
		bsr.w	Obj17_RotateSpikes
		bsr.w	DisplaySprite
		bra.w	Obj17_ChkDel

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj17_RotateSpikes:			; XREF: Obj17_Action; Obj17_Display
		move.b	($FFFFFEC1).w,d0
		move.b	#0,$20(a0)	; make object harmless
		add.b	$3E(a0),d0
		andi.b	#7,d0
		move.b	d0,$1A(a0)	; change current frame
		bne.s	locret_7DA6
		move.b	#$84,$20(a0)	; make object harmful

locret_7DA6:
		rts
; End of function Obj17_RotateSpikes

; ===========================================================================

Obj17_ChkDel:				; XREF: Obj17_Action
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj17_DelAll
		rts
; ===========================================================================

Obj17_DelAll:				; XREF: Obj17_ChkDel
		moveq	#0,d2
		lea	$28(a0),a2	; move helix length to a2
		move.b	(a2)+,d2	; move a2 to d2
		subq.b	#2,d2
		bcs.s	Obj17_Delete

Obj17_DelLoop:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#$FFD000,d0
		movea.l	d0,a1
		bsr.w	DeleteObject2	; delete object
		dbf	d2,Obj17_DelLoop ; repeat d2 times (helix length)

Obj17_Delete:				; XREF: Obj17_Index
		bsr.w	DeleteObject
		rts
; ===========================================================================

Obj17_Display:				; XREF: Obj17_Index
		bsr.w	Obj17_RotateSpikes
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - helix of spikes on a pole (GHZ)
; ---------------------------------------------------------------------------
Map_obj17:
	include "_maps\obj17.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 18 - platforms	(GHZ, SYZ, SLZ)
; ---------------------------------------------------------------------------

Obj18:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj18_Index(pc,d0.w),d1
		jmp	Obj18_Index(pc,d1.w)
; ===========================================================================
Obj18_Index:	dc.w Obj18_Main-Obj18_Index
		dc.w Obj18_Solid-Obj18_Index
		dc.w Obj18_Action2-Obj18_Index
		dc.w Obj18_Delete-Obj18_Index
		dc.w Obj18_Action-Obj18_Index
; ===========================================================================

Obj18_Main:				; XREF: Obj18_Index
		addq.b	#2,$24(a0)
		move.w	#$4000,2(a0)
		move.l	#Map_obj18,4(a0)
		move.b	#$20,$19(a0)
		cmpi.b	#4,($FFFFFE10).w ; check if level is SYZ
		bne.s	Obj18_NotSYZ
		move.l	#Map_obj18a,4(a0) ; SYZ	specific code
		move.b	#$20,$19(a0)

Obj18_NotSYZ:
		cmpi.b	#3,($FFFFFE10).w ; check if level is SLZ
		bne.s	Obj18_NotSLZ
		move.l	#Map_obj18b,4(a0) ; SLZ	specific code
		move.b	#$20,$19(a0)
		move.w	#$4000,2(a0)
		move.b	#3,$28(a0)

Obj18_NotSLZ:
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.w	$C(a0),$2C(a0)
		move.w	$C(a0),$34(a0)
		move.w	8(a0),$32(a0)
		move.w	#$80,$26(a0)
		moveq	#0,d1
		move.b	$28(a0),d0
		cmpi.b	#$A,d0		; is object type $A (large platform)?
		bne.s	Obj18_SetFrame	; if not, branch
		addq.b	#1,d1		; use frame #1
		move.b	#$20,$19(a0)	; set width

Obj18_SetFrame:
		move.b	d1,$1A(a0)	; set frame to d1

Obj18_Solid:				; XREF: Obj18_Index
		tst.b	$38(a0)
		beq.s	loc_7EE0
		subq.b	#4,$38(a0)

loc_7EE0:
		moveq	#0,d1
		move.b	$19(a0),d1
		bsr.w	PlatformObject

Obj18_Action:				; XREF: Obj18_Index
		bsr.w	Obj18_Move
		bsr.w	Obj18_Nudge
		bsr.w	DisplaySprite
		bra.w	Obj18_ChkDel
; ===========================================================================

Obj18_Action2:				; XREF: Obj18_Index
		cmpi.b	#$40,$38(a0)
		beq.s	loc_7F06
		addq.b	#4,$38(a0)

loc_7F06:
		moveq	#0,d1
		move.b	$19(a0),d1
		bsr.w	ExitPlatform
		move.w	8(a0),-(sp)
		bsr.w	Obj18_Move
		bsr.w	Obj18_Nudge
		move.w	(sp)+,d2
		bsr.w	MvSonicOnPtfm2
		bsr.w	DisplaySprite
		bra.w	Obj18_ChkDel

		rts

; ---------------------------------------------------------------------------
; Subroutine to	move platform slightly when you	stand on it
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj18_Nudge:				; XREF: Obj18_Action; Obj18_Action2
		move.b	$38(a0),d0
		bsr.w	CalcSine
		move.w	#$400,d1
		muls.w	d1,d0
		swap	d0
		add.w	$2C(a0),d0
		move.w	d0,$C(a0)
		rts
; End of function Obj18_Nudge

; ---------------------------------------------------------------------------
; Subroutine to	move platforms
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj18_Move:				; XREF: Obj18_Action; Obj18_Action2
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	Obj18_TypeIndex(pc,d0.w),d1
		jmp	Obj18_TypeIndex(pc,d1.w)
; End of function Obj18_Move

; ===========================================================================
Obj18_TypeIndex:dc.w Obj18_Type00-Obj18_TypeIndex, Obj18_Type01-Obj18_TypeIndex
		dc.w Obj18_Type02-Obj18_TypeIndex, Obj18_Type03-Obj18_TypeIndex
		dc.w Obj18_Type04-Obj18_TypeIndex, Obj18_Type05-Obj18_TypeIndex
		dc.w Obj18_Type06-Obj18_TypeIndex, Obj18_Type07-Obj18_TypeIndex
		dc.w Obj18_Type08-Obj18_TypeIndex, Obj18_Type00-Obj18_TypeIndex
		dc.w Obj18_Type0A-Obj18_TypeIndex, Obj18_Type0B-Obj18_TypeIndex
		dc.w Obj18_Type0C-Obj18_TypeIndex
; ===========================================================================

Obj18_Type00:
		rts			; platform 00 doesn't move
; ===========================================================================

Obj18_Type05:
		move.w	$32(a0),d0
		move.b	$26(a0),d1	; load platform-motion variable
		neg.b	d1		; reverse platform-motion
		addi.b	#$40,d1
		bra.s	Obj18_01_Move
; ===========================================================================

Obj18_Type01:
		move.w	$32(a0),d0
		move.b	$26(a0),d1	; load platform-motion variable
		subi.b	#$40,d1

Obj18_01_Move:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,8(a0)	; change position on x-axis
		bra.w	Obj18_ChgMotion
; ===========================================================================

Obj18_Type0C:
		move.w	$34(a0),d0
		move.b	($FFFFFE6C).w,d1 ; load	platform-motion	variable
		neg.b	d1		; reverse platform-motion
		addi.b	#$30,d1
		bra.s	Obj18_02_Move
; ===========================================================================

Obj18_Type0B:
		move.w	$34(a0),d0
		move.b	($FFFFFE6C).w,d1 ; load	platform-motion	variable
		subi.b	#$30,d1
		bra.s	Obj18_02_Move
; ===========================================================================

Obj18_Type06:
		move.w	$34(a0),d0
		move.b	$26(a0),d1	; load platform-motion variable
		neg.b	d1		; reverse platform-motion
		addi.b	#$40,d1
		bra.s	Obj18_02_Move
; ===========================================================================

Obj18_Type02:
		move.w	$34(a0),d0
		move.b	$26(a0),d1	; load platform-motion variable
		subi.b	#$40,d1

Obj18_02_Move:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,$2C(a0)	; change position on y-axis
		bra.w	Obj18_ChgMotion
; ===========================================================================

Obj18_Type03:
		tst.w	$3A(a0)		; is time delay	set?
		bne.s	Obj18_03_Wait	; if yes, branch
		btst	#3,$22(a0)	; is Sonic standing on the platform?
		beq.s	Obj18_03_NoMove	; if not, branch
		move.w	#30,$3A(a0)	; set time delay to 0.5	seconds

Obj18_03_NoMove:
		rts
; ===========================================================================

Obj18_03_Wait:
		subq.w	#1,$3A(a0)	; subtract 1 from time
		bne.s	Obj18_03_NoMove	; if time is > 0, branch
		move.w	#32,$3A(a0)
		addq.b	#1,$28(a0)	; change to type 04 (falling)
		rts
; ===========================================================================

Obj18_Type04:
		tst.w	$3A(a0)
		beq.s	loc_8048
		subq.w	#1,$3A(a0)
		bne.s	loc_8048
		btst	#3,$22(a0)
		beq.s	loc_8042
		bset	#1,$22(a1)
		bclr	#3,$22(a1)
		move.b	#2,$24(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)
		move.w	$12(a0),$12(a1)

loc_8042:
		move.b	#8,$24(a0)

loc_8048:
		move.l	$2C(a0),d3
		move.w	$12(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d3,$2C(a0)
		addi.w	#$38,$12(a0)
		move.w	($FFFFF72E).w,d0
		addi.w	#$E0,d0
		cmp.w	$2C(a0),d0
		bcc.s	locret_8074
		move.b	#6,$24(a0)

locret_8074:
		rts
; ===========================================================================

Obj18_Type07:
		tst.w	$3A(a0)		; is time delay	set?
		bne.s	Obj18_07_Wait	; if yes, branch
		lea	($FFFFF7E0).w,a2 ; load	switch statuses
		moveq	#0,d0
		move.b	$28(a0),d0	; move object type ($x7) to d0
		lsr.w	#4,d0		; divide d0 by 8, round	down
		tst.b	(a2,d0.w)	; has switch no. d0 been pressed?
		beq.s	Obj18_07_NoMove	; if not, branch
		move.w	#60,$3A(a0)	; set time delay to 1 second

Obj18_07_NoMove:
		rts
; ===========================================================================

Obj18_07_Wait:
		subq.w	#1,$3A(a0)	; subtract 1 from time delay
		bne.s	Obj18_07_NoMove	; if time is > 0, branch
		addq.b	#1,$28(a0)	; change to type 08
		rts
; ===========================================================================

Obj18_Type08:
		subq.w	#2,$2C(a0)	; move platform	up
		move.w	$34(a0),d0
		subi.w	#$200,d0
		cmp.w	$2C(a0),d0	; has platform moved $200 pixels?
		bne.s	Obj18_08_NoStop	; if not, branch
		clr.b	$28(a0)		; change to type 00 (stop moving)

Obj18_08_NoStop:
		rts
; ===========================================================================

Obj18_Type0A:
		move.w	$34(a0),d0
		move.b	$26(a0),d1	; load platform-motion variable
		subi.b	#$40,d1
		ext.w	d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	d0,$2C(a0)	; change position on y-axis

Obj18_ChgMotion:
		move.b	($FFFFFE78).w,$26(a0) ;	update platform-movement variable
		rts
; ===========================================================================

Obj18_ChkDel:				; XREF: Obj18_Action; Obj18_Action2
		move.w	$32(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj18_Delete
		rts
; ===========================================================================

Obj18_Delete:				; XREF: Obj18_Index
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - unused
; ---------------------------------------------------------------------------
Map_obj18x:
	include "_maps\obj18x.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - GHZ	platforms
; ---------------------------------------------------------------------------
Map_obj18:
	include "_maps\obj18ghz.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - SYZ	platforms
; ---------------------------------------------------------------------------
Map_obj18a:
	include "_maps\obj18syz.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - SLZ	platforms
; ---------------------------------------------------------------------------
Map_obj18b:
	include "_maps\obj18slz.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 19 - blank
; ---------------------------------------------------------------------------

Obj19:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - swinging ball on a chain from GHZ boss
; ---------------------------------------------------------------------------
Map_obj48:
	include "_maps\obj48.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1A - GHZ collapsing ledge
; ---------------------------------------------------------------------------

Obj1A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj1A_Index(pc,d0.w),d1
		jmp	Obj1A_Index(pc,d1.w)
; ===========================================================================
Obj1A_Index:	dc.w Obj1A_Main-Obj1A_Index, Obj1A_ChkTouch-Obj1A_Index
		dc.w Obj1A_Touch-Obj1A_Index, Obj1A_Display-Obj1A_Index
		dc.w Obj1A_Delete-Obj1A_Index, Obj1A_WalkOff-Obj1A_Index
; ===========================================================================

Obj1A_Main:				; XREF: Obj1A_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj1A,4(a0)
		move.w	#$4000,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#7,$38(a0)	; set time delay for collapse
		move.b	#$64,$19(a0)
		move.b	$28(a0),$1A(a0)
		move.b	#$38,$16(a0)
		bset	#4,1(a0)

Obj1A_ChkTouch:				; XREF: Obj1A_Index
		tst.b	$3A(a0)		; has Sonic touched the	platform?
		beq.s	Obj1A_Slope	; if not, branch
		tst.b	$38(a0)		; has time reached zero?
		beq.w	Obj1A_Collapse	; if yes, branch
		subq.b	#1,$38(a0)	; subtract 1 from time

Obj1A_Slope:
		move.w	#$30,d1
		lea	(Obj1A_SlopeData).l,a2
		bsr.w	SlopeObject
		bra.w	MarkObjGone
; ===========================================================================

Obj1A_Touch:				; XREF: Obj1A_Index
		tst.b	$38(a0)
		beq.w	loc_847A
		move.b	#1,$3A(a0)	; set object as	"touched"
		subq.b	#1,$38(a0)

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj1A_WalkOff:				; XREF: Obj1A_Index
		move.w	#$30,d1
		bsr.w	ExitPlatform
		move.w	#$30,d1
		lea	(Obj1A_SlopeData).l,a2
		move.w	8(a0),d2
		bsr.w	SlopeObject2
		bra.w	MarkObjGone
; End of function Obj1A_WalkOff

; ===========================================================================

Obj1A_Display:				; XREF: Obj1A_Index
		tst.b	$38(a0)		; has time delay reached zero?
		beq.s	Obj1A_TimeZero	; if yes, branch
		tst.b	$3A(a0)		; has Sonic touched the	object?
		bne.w	loc_82D0	; if yes, branch
		subq.b	#1,$38(a0)	; subtract 1 from time
		bra.w	DisplaySprite
; ===========================================================================

loc_82D0:				; XREF: Obj1A_Display
		subq.b	#1,$38(a0)
		bsr.w	Obj1A_WalkOff
		lea	($FFFFD000).w,a1
		btst	#3,$22(a1)
		beq.s	loc_82FC
		tst.b	$38(a0)
		bne.s	locret_8308
		bclr	#3,$22(a1)
		bclr	#5,$22(a1)
		move.b	#1,$1D(a1)

loc_82FC:
		move.b	#0,$3A(a0)
		move.b	#6,$24(a0)	; run "Obj1A_Display" routine

locret_8308:
		rts
; ===========================================================================

Obj1A_TimeZero:				; XREF: Obj1A_Display
		bsr.w	ObjectFall
		bsr.w	DisplaySprite
		tst.b	1(a0)
		bpl.s	Obj1A_Delete
		rts
; ===========================================================================

Obj1A_Delete:				; XREF: Obj1A_Index
		bsr.w	DeleteObject
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 53 - collapsing floors	(MZ, SLZ, SBZ)
; ---------------------------------------------------------------------------

Obj53:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj53_Index(pc,d0.w),d1
		jmp	Obj53_Index(pc,d1.w)
; ===========================================================================
Obj53_Index:	dc.w Obj53_Main-Obj53_Index, Obj53_ChkTouch-Obj53_Index
		dc.w Obj53_Touch-Obj53_Index, Obj53_Display-Obj53_Index
		dc.w Obj53_Delete-Obj53_Index, Obj53_WalkOff-Obj53_Index
; ===========================================================================

Obj53_Main:				; XREF: Obj53_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj53,4(a0)
		move.w	#$42B8,2(a0)
		cmpi.b	#3,($FFFFFE10).w ; check if level is SLZ
		bne.s	Obj53_NotSLZ
		move.w	#$44E0,2(a0)	; SLZ specific code
		addq.b	#2,$1A(a0)

Obj53_NotSLZ:
		cmpi.b	#5,($FFFFFE10).w ; check if level is SBZ
		bne.s	Obj53_NotSBZ
		move.w	#$43F5,2(a0)	; SBZ specific code

Obj53_NotSBZ:
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#7,$38(a0)
		move.b	#$44,$19(a0)

Obj53_ChkTouch:				; XREF: Obj53_Index
		tst.b	$3A(a0)		; has Sonic touched the	object?
		beq.s	Obj53_Solid	; if not, branch
		tst.b	$38(a0)		; has time delay reached zero?
		beq.w	Obj53_Collapse	; if yes, branch
		subq.b	#1,$38(a0)	; subtract 1 from time

Obj53_Solid:
		move.w	#$20,d1
		bsr.w	PlatformObject
		tst.b	$28(a0)
		bpl.s	Obj53_MarkAsGone
		btst	#3,$22(a1)
		beq.s	Obj53_MarkAsGone
		bclr	#0,1(a0)
		move.w	8(a1),d0
		sub.w	8(a0),d0
		bcc.s	Obj53_MarkAsGone
		bset	#0,1(a0)

Obj53_MarkAsGone:
		bra.w	MarkObjGone
; ===========================================================================

Obj53_Touch:				; XREF: Obj53_Index
		tst.b	$38(a0)
		beq.w	loc_8458
		move.b	#1,$3A(a0)	; set object as	"touched"
		subq.b	#1,$38(a0)

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj53_WalkOff:				; XREF: Obj53_Index
		move.w	#$20,d1
		bsr.w	ExitPlatform
		move.w	8(a0),d2
		bsr.w	MvSonicOnPtfm2
		bra.w	MarkObjGone
; End of function Obj53_WalkOff

; ===========================================================================

Obj53_Display:				; XREF: Obj53_Index
		tst.b	$38(a0)		; has time delay reached zero?
		beq.s	Obj53_TimeZero	; if yes, branch
		tst.b	$3A(a0)		; has Sonic touched the	object?
		bne.w	loc_8402	; if yes, branch
		subq.b	#1,$38(a0)	; subtract 1 from time
		bra.w	DisplaySprite
; ===========================================================================

loc_8402:
		subq.b	#1,$38(a0)
		bsr.w	Obj53_WalkOff
		lea	($FFFFD000).w,a1
		btst	#3,$22(a1)
		beq.s	loc_842E
		tst.b	$38(a0)
		bne.s	locret_843A
		bclr	#3,$22(a1)
		bclr	#5,$22(a1)
		move.b	#1,$1D(a1)

loc_842E:
		move.b	#0,$3A(a0)
		move.b	#6,$24(a0)	; run "Obj53_Display" routine

locret_843A:
		rts
; ===========================================================================

Obj53_TimeZero:				; XREF: Obj53_Display
		bsr.w	ObjectFall
		bsr.w	DisplaySprite
		tst.b	1(a0)
		bpl.s	Obj53_Delete
		rts
; ===========================================================================

Obj53_Delete:				; XREF: Obj53_Index
		bsr.w	DeleteObject
		rts
; ===========================================================================

Obj53_Collapse:				; XREF: Obj53_ChkTouch
		move.b	#0,$3A(a0)

loc_8458:				; XREF: Obj53_Touch
		lea	(Obj53_Data2).l,a4
		btst	#0,$28(a0)
		beq.s	loc_846C
		lea	(Obj53_Data3).l,a4

loc_846C:
		moveq	#7,d1
		addq.b	#1,$1A(a0)
		bra.s	loc_8486
; ===========================================================================

Obj1A_Collapse:				; XREF: Obj1A_ChkTouch
		move.b	#0,$3A(a0)

loc_847A:				; XREF: Obj1A_Touch
		lea	(Obj53_Data1).l,a4
		moveq	#$18,d1
		addq.b	#2,$1A(a0)

loc_8486:				; XREF: Obj53_Collapse
		moveq	#0,d0
		move.b	$1A(a0),d0
		add.w	d0,d0
		movea.l	4(a0),a3
		adda.w	(a3,d0.w),a3
		addq.w	#1,a3
		bset	#5,1(a0)
		move.b	0(a0),d4
		move.b	1(a0),d5
		movea.l	a0,a1
		bra.s	loc_84B2
; ===========================================================================

loc_84AA:
		bsr.w	SingleObjLoad
		bne.s	loc_84F2
		addq.w	#5,a3

loc_84B2:
		move.b	#6,$24(a1)
		move.b	d4,0(a1)
		move.l	a3,4(a1)
		move.b	d5,1(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	2(a0),2(a1)
		move.b	$18(a0),$18(a1)
		move.b	$19(a0),$19(a1)
		move.b	(a4)+,$38(a1)
		cmpa.l	a0,a1
		bcc.s	loc_84EE
		bsr.w	DisplaySprite2

loc_84EE:
		dbf	d1,loc_84AA

loc_84F2:
		bsr.w	DisplaySprite
		moveq	#sfx_Collapse,d0
		jmp	(PlaySound_Special).l ;	play collapsing	sound
; ===========================================================================
; ---------------------------------------------------------------------------
; Disintegration data for collapsing ledges (MZ, SLZ, SBZ)
; ---------------------------------------------------------------------------
Obj53_Data1:	dc.b $1C, $18, $14, $10, $1A, $16, $12,	$E, $A,	6, $18,	$14, $10, $C, 8, 4
		dc.b $16, $12, $E, $A, 6, 2, $14, $10, $C, 0
Obj53_Data2:	dc.b $1E, $16, $E, 6, $1A, $12,	$A, 2
Obj53_Data3:	dc.b $16, $1E, $1A, $12, 6, $E,	$A, 2

; ---------------------------------------------------------------------------
; Sloped platform subroutine (GHZ collapsing ledges and	MZ platforms)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SlopeObject2:				; XREF: Obj1A_WalkOff; et al
		lea	($FFFFD000).w,a1
		btst	#3,$22(a1)
		beq.s	locret_856E
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		lsr.w	#1,d0
		btst	#0,1(a0)
		beq.s	loc_854E
		not.w	d0
		add.w	d1,d0

loc_854E:
		moveq	#0,d1
		move.b	(a2,d0.w),d1
		move.w	$C(a0),d0
		sub.w	d1,d0
		moveq	#0,d1
		move.b	$16(a1),d1
		sub.w	d1,d0
		move.w	d0,$C(a1)
		sub.w	8(a0),d2
		sub.w	d2,8(a1)

locret_856E:
		rts
; End of function SlopeObject2

; ===========================================================================
; ---------------------------------------------------------------------------
; Collision data for GHZ collapsing ledge
; ---------------------------------------------------------------------------
Obj1A_SlopeData:
		incbin	misc\ghzledge.bin
		even

; ---------------------------------------------------------------------------
; Sprite mappings - GHZ	collapsing ledge
; ---------------------------------------------------------------------------
Map_obj1A:
	include "_maps\obj1A.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - collapsing floors (MZ, SLZ,	SBZ)
; ---------------------------------------------------------------------------
Map_obj53:
	include "_maps\obj53.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1C - scenery (GHZ bridge stump, SLZ lava thrower)
; ---------------------------------------------------------------------------

Obj1C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj1C_Index(pc,d0.w),d1
		jmp	Obj1C_Index(pc,d1.w)
; ===========================================================================
Obj1C_Index:	dc.w Obj1C_Main-Obj1C_Index
		dc.w Obj1C_ChkDel-Obj1C_Index
; ===========================================================================

Obj1C_Main:				; XREF: Obj1C_Index
		addq.b	#2,$24(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; copy object type to d0
		mulu.w	#$A,d0		; multiply by $A
		lea	Obj1C_Var(pc,d0.w),a1
		move.l	(a1)+,4(a0)
		move.w	(a1)+,2(a0)
		ori.b	#4,1(a0)
		move.b	(a1)+,$1A(a0)
		move.b	(a1)+,$19(a0)
		move.b	(a1)+,$18(a0)
		move.b	(a1)+,$20(a0)

Obj1C_ChkDel:				; XREF: Obj1C_Index
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Variables for	object $1C are stored in an array
; ---------------------------------------------------------------------------
Obj1C_Var:	dc.l Map_obj1C		; mappings address
		dc.w $44D8		; VRAM setting
		dc.b 0,	8, 2, 0		; frame, width,	priority, collision response
		dc.l Map_obj1C
		dc.w $44D8
		dc.b 0,	8, 2, 0
		dc.l Map_obj1C
		dc.w $44D8
		dc.b 0,	8, 2, 0
		dc.l Map_obj11
		dc.w $438E
		dc.b 1,	$10, 1,	0
; ---------------------------------------------------------------------------
; Sprite mappings - SLZ	lava thrower
; ---------------------------------------------------------------------------
Map_obj1C:
	include "_maps\obj1C.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1D - switch that activates when Sonic touches it
; (this	is not used anywhere in	the game)
; ---------------------------------------------------------------------------

Obj1D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj1D_Index(pc,d0.w),d1
		jmp	Obj1D_Index(pc,d1.w)
; ===========================================================================
Obj1D_Index:	dc.w Obj1D_Main-Obj1D_Index
		dc.w Obj1D_Action-Obj1D_Index
		dc.w Obj1D_Delete-Obj1D_Index
; ===========================================================================

Obj1D_Main:				; XREF: Obj1D_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj1D,4(a0)
		move.w	#$4000,2(a0)
		move.b	#4,1(a0)
		move.w	$C(a0),$30(a0)	; save position	on y-axis
		move.b	#$10,$19(a0)
		move.b	#5,$18(a0)

Obj1D_Action:				; XREF: Obj1D_Index
		move.w	$30(a0),$C(a0)	; restore position on y-axis
		move.w	#$10,d1
		bsr.w	Obj1D_ChkTouch
		beq.s	Obj1D_ChkDel
		addq.w	#2,$C(a0)	; move object 2	pixels
		moveq	#1,d0
		move.w	d0,($FFFFF7E0).w ; set switch 0	as "pressed"

Obj1D_ChkDel:
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj1D_Delete
		rts
; ===========================================================================

Obj1D_Delete:				; XREF: Obj1D_Index
		bsr.w	DeleteObject
		rts
; ---------------------------------------------------------------------------
; Subroutine to	check if Sonic touches the object
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj1D_ChkTouch:				; XREF: Obj1D_Action
		lea	($FFFFD000).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_8918
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.s	loc_8918
		move.w	$C(a1),d2
		move.b	$16(a1),d1
		ext.w	d1
		add.w	d2,d1
		move.w	$C(a0),d0
		subi.w	#$10,d0
		sub.w	d1,d0
		bhi.s	loc_8918
		cmpi.w	#-$10,d0
		bcs.s	loc_8918
		moveq	#-1,d0
		rts
; ===========================================================================

loc_8918:
		moveq	#0,d0
		rts
; End of function Obj1D_ChkTouch

; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - object 1D
; ---------------------------------------------------------------------------
Map_obj1D:
	include "_maps\obj1D.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2A - doors (SBZ)
; ---------------------------------------------------------------------------

Obj2A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj2A_Index(pc,d0.w),d1
		jmp	Obj2A_Index(pc,d1.w)
; ===========================================================================
Obj2A_Index:	dc.w Obj2A_Main-Obj2A_Index
		dc.w Obj2A_OpenShut-Obj2A_Index
; ===========================================================================

Obj2A_Main:				; XREF: Obj2A_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj2A,4(a0)
		move.w	#$42E8,2(a0)
		ori.b	#4,1(a0)
		move.b	#8,$19(a0)
		move.b	#4,$18(a0)

Obj2A_OpenShut:				; XREF: Obj2A_Index
		move.w	#$40,d1
		clr.b	$1C(a0)		; use "closing"	animation
		move.w	($FFFFD008).w,d0
		add.w	d1,d0
		cmp.w	8(a0),d0
		bcs.s	Obj2A_Animate
		sub.w	d1,d0
		sub.w	d1,d0
		cmp.w	8(a0),d0
		bcc.s	Obj2A_Animate
		add.w	d1,d0
		cmp.w	8(a0),d0
		bcc.s	loc_899A
		btst	#0,$22(a0)
		bne.s	Obj2A_Animate
		bra.s	Obj2A_Open
; ===========================================================================

loc_899A:				; XREF: Obj2A_OpenShut
		btst	#0,$22(a0)
		beq.s	Obj2A_Animate

Obj2A_Open:				; XREF: Obj2A_OpenShut
		move.b	#1,$1C(a0)	; use "opening"	animation

Obj2A_Animate:				; XREF: Obj2A_OpenShut; loc_899A
		lea	(Ani_obj2A).l,a1
		bsr.w	AnimateSprite
		tst.b	$1A(a0)		; is the door open?
		bne.s	Obj2A_MarkAsUsed ; if yes, branch
		move.w	#$11,d1
		move.w	#$20,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	8(a0),d4
		bsr.w	SolidObject

Obj2A_MarkAsUsed:
		bra.w	MarkObjGone
; ===========================================================================
Ani_obj2A:
	include "_anim\obj2A.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - doors (SBZ)
; ---------------------------------------------------------------------------
Map_obj2A:
	include "_maps\obj2A.asm"

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj44_SolidWall:			; XREF: Obj44_Solid
		bsr.w	Obj44_SolidWall2
		beq.s	loc_8AA8
		bmi.w	loc_8AC4
		tst.w	d0
		beq.w	loc_8A92
		bmi.s	loc_8A7C
		tst.w	$10(a1)
		bmi.s	loc_8A92
		bra.s	loc_8A82
; ===========================================================================

loc_8A7C:
		tst.w	$10(a1)
		bpl.s	loc_8A92

loc_8A82:
		sub.w	d0,8(a1)
		move.w	#0,$14(a1)
		move.w	#0,$10(a1)

loc_8A92:
		btst	#1,$22(a1)
		bne.s	loc_8AB6
		bset	#5,$22(a1)
		bset	#5,$22(a0)
		rts
; ===========================================================================

loc_8AA8:
		btst	#5,$22(a0)
		beq.s	locret_8AC2
		move.w	#1,$1C(a1)

loc_8AB6:
		bclr	#5,$22(a0)
		bclr	#5,$22(a1)

locret_8AC2:
		rts
; ===========================================================================

loc_8AC4:
		tst.w	$12(a1)
		bpl.s	locret_8AD8
		tst.w	d3
		bpl.s	locret_8AD8
		sub.w	d3,$C(a1)
		move.w	#0,$12(a1)

locret_8AD8:
		rts
; End of function Obj44_SolidWall


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj44_SolidWall2:			; XREF: Obj44_SolidWall
		lea	($FFFFD000).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_8B48
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.s	loc_8B48
		move.b	$16(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	$C(a1),d3
		sub.w	$C(a0),d3
		add.w	d2,d3
		bmi.s	loc_8B48
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bcc.s	loc_8B48
		tst.b	($FFFFF7C8).w
		bmi.s	loc_8B48
		cmpi.b	#6,($FFFFD024).w
		bcc.s	loc_8B48
		tst.w	($FFFFFE08).w
		bne.s	loc_8B48
		move.w	d0,d5
		cmp.w	d0,d1
		bcc.s	loc_8B30
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5

loc_8B30:
		move.w	d3,d1
		cmp.w	d3,d2
		bcc.s	loc_8B3C
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

loc_8B3C:
		cmp.w	d1,d5
		bhi.s	loc_8B44
		moveq	#1,d4
		rts
; ===========================================================================

loc_8B44:
		moveq	#-1,d4
		rts
; ===========================================================================

loc_8B48:
		moveq	#0,d4
		rts
; End of function Obj44_SolidWall2

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1E - Ball Hog enemy (SBZ)
; ---------------------------------------------------------------------------

Obj1E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj1E_Index(pc,d0.w),d1
		jmp	Obj1E_Index(pc,d1.w)
; ===========================================================================
Obj1E_Index:	dc.w Obj1E_Main-Obj1E_Index
		dc.w Obj1E_Action-Obj1E_Index
; ===========================================================================

Obj1E_Main:				; XREF: Obj1E_Index
		move.b	#$13,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_obj1E,4(a0)
		move.w	#$2302,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#5,$20(a0)
		move.b	#$C,$19(a0)
		bsr.w	ObjectFall
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	locret_8BAC
		add.w	d1,$C(a0)
		move.w	#0,$12(a0)
		addq.b	#2,$24(a0)

locret_8BAC:
		rts
; ===========================================================================

Obj1E_Action:				; XREF: Obj1E_Index
		lea	(Ani_obj1E).l,a1
		bsr.w	AnimateSprite
		cmpi.b	#1,$1A(a0)	; is final frame (01) displayed?
		bne.s	Obj1E_SetBall	; if not, branch
		tst.b	$32(a0)		; is it	set to launch cannonball?
		beq.s	Obj1E_MakeBall	; if yes, branch
		bra.s	Obj1E_MarkAsGone
; ===========================================================================

Obj1E_SetBall:				; XREF: Obj1E_Action
		clr.b	$32(a0)		; set to launch	cannonball

Obj1E_MarkAsGone:			; XREF: Obj1E_Action
		bra.w	MarkObjGone
; ===========================================================================

Obj1E_MakeBall:				; XREF: Obj1E_Action
		move.b	#1,$32(a0)
		bsr.w	SingleObjLoad
		bne.s	loc_8C1A
		move.b	#$20,0(a1)	; load cannonball object ($20)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	#-$100,$10(a1)	; cannonball bounces to	the left
		move.w	#0,$12(a1)
		moveq	#-4,d0
		btst	#0,$22(a0)	; is Ball Hog facing right?
		beq.s	loc_8C0A	; if not, branch
		neg.w	d0
		neg.w	$10(a1)		; cannonball bounces to	the right

loc_8C0A:
		add.w	d0,8(a1)
		addi.w	#$C,$C(a1)
		move.b	$28(a0),$28(a1)	; copy object type from	Ball Hog

loc_8C1A:
		bra.s	Obj1E_MarkAsGone
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 20 - cannonball that Ball Hog throws (SBZ)
; ---------------------------------------------------------------------------

Obj20:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj20_Index(pc,d0.w),d1
		jmp	Obj20_Index(pc,d1.w)
; ===========================================================================
Obj20_Index:	dc.w Obj20_Main-Obj20_Index
		dc.w Obj20_Bounce-Obj20_Index
; ===========================================================================

Obj20_Main:				; XREF: Obj20_Index
		addq.b	#2,$24(a0)
		move.b	#7,$16(a0)
		move.l	#Map_obj1E,4(a0)
		move.w	#$2302,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$87,$20(a0)
		move.b	#8,$19(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; move object type to d0
		mulu.w	#60,d0		; multiply by 60 frames	(1 second)
		move.w	d0,$30(a0)	; set explosion	time
		move.b	#4,$1A(a0)

Obj20_Bounce:				; XREF: Obj20_Index
		jsr	ObjectFall
		tst.w	$12(a0)
		bmi.s	Obj20_ChkExplode
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	Obj20_ChkExplode
		add.w	d1,$C(a0)
		move.w	#-$300,$12(a0)
		tst.b	d3
		beq.s	Obj20_ChkExplode
		bmi.s	loc_8CA4
		tst.w	$10(a0)
		bpl.s	Obj20_ChkExplode
		neg.w	$10(a0)
		bra.s	Obj20_ChkExplode
; ===========================================================================

loc_8CA4:				; XREF: Obj20_Bounce
		tst.w	$10(a0)
		bmi.s	Obj20_ChkExplode
		neg.w	$10(a0)

Obj20_ChkExplode:			; XREF: Obj20_Bounce
		subq.w	#1,$30(a0)	; subtract 1 from explosion time
		bpl.s	Obj20_Animate	; if time is > 0, branch
		move.b	#$24,0(a0)
		move.b	#$3F,0(a0)	; change object	to an explosion	($3F)
		move.b	#0,$24(a0)	; reset	routine	counter
		bra.w	Obj3F		; jump to explosion code
; ===========================================================================

Obj20_Animate:				; XREF: Obj20_ChkExplode
		subq.b	#1,$1E(a0)	; subtract 1 from frame	duration
		bpl.s	Obj20_Display
		move.b	#5,$1E(a0)	; set frame duration to	5 frames
		bchg	#0,$1A(a0)	; change frame

Obj20_Display:
		bsr.w	DisplaySprite
		move.w	($FFFFF72E).w,d0
		addi.w	#$E0,d0
		cmp.w	$C(a0),d0	; has object fallen off	the level?
		bcs.w	DeleteObject	; if yes, branch
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 24 - explosion	from a destroyed monitor
; ---------------------------------------------------------------------------

Obj24:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj24_Index(pc,d0.w),d1
		jmp	Obj24_Index(pc,d1.w)
; ===========================================================================
Obj24_Index:	dc.w Obj24_Main-Obj24_Index
		dc.w Obj24_Animate-Obj24_Index
; ===========================================================================

Obj24_Main:				; XREF: Obj24_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj24,4(a0)
		move.w	#$41C,2(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#0,$20(a0)
		move.b	#$C,$19(a0)
		move.b	#9,$1E(a0)
		move.b	#0,$1A(a0)
		moveq	#sfx_BuzzExplode,d0
		jsr	PlaySound_Special ;	play explosion sound

Obj24_Animate:				; XREF: Obj24_Index
		subq.b	#1,$1E(a0)	; subtract 1 from frame	duration
		bpl.s	Obj24_Display
		move.b	#9,$1E(a0)	; set frame duration to	9 frames
		addq.b	#1,$1A(a0)	; next frame
		cmpi.b	#4,$1A(a0)	; is the final frame (04) displayed?
		beq.w	DeleteObject	; if yes, branch

Obj24_Display:
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 27 - explosion	from a destroyed enemy
; ---------------------------------------------------------------------------

Obj27:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj27_Index(pc,d0.w),d1
		jmp	Obj27_Index(pc,d1.w)
; ===========================================================================
Obj27_Index:	dc.w Obj27_LoadAnimal-Obj27_Index
		dc.w Obj27_Main-Obj27_Index
		dc.w Obj27_Animate-Obj27_Index
; ===========================================================================

Obj27_LoadAnimal:			; XREF: Obj27_Index
		addq.b	#2,$24(a0)
		bsr.w	SingleObjLoad
		bne.s	Obj27_Main
		move.b	#$28,0(a1)	; load animal object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	$3E(a0),$3E(a1)

Obj27_Main:				; XREF: Obj27_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj27,4(a0)
		move.w	#$5A0,2(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#0,$20(a0)
		move.b	#$C,$19(a0)
		move.b	#7,$1E(a0)	; set frame duration to	7 frames
		move.b	#0,$1A(a0)
		moveq	#sfx_Break,d0
		jsr	(PlaySound_Special).l ;	play breaking enemy sound

Obj27_Animate:				; XREF: Obj27_Index
		subq.b	#1,$1E(a0)	; subtract 1 from frame	duration
		bpl.s	Obj27_Display
		move.b	#7,$1E(a0)	; set frame duration to	7 frames
		addq.b	#1,$1A(a0)	; next frame
		cmpi.b	#5,$1A(a0)	; is the final frame (05) displayed?
		beq.w	DeleteObject	; if yes, branch

Obj27_Display:
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3F - explosion	from a destroyed boss, bomb or cannonball
; ---------------------------------------------------------------------------

Obj3F:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj3F_Index(pc,d0.w),d1
		jmp	Obj3F_Index(pc,d1.w)
; ===========================================================================
Obj3F_Index:	dc.w Obj3F_Main-Obj3F_Index
		dc.w Obj27_Animate-Obj3F_Index
; ===========================================================================

Obj3F_Main:				; XREF: Obj3F_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj3F,4(a0)
		move.w	#$5A0,2(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#0,$20(a0)
		move.b	#$C,$19(a0)
		move.b	#7,$1E(a0)
		move.b	#0,$1A(a0)
		moveq	#sfx_Explode,d0
		jmp	PlaySound_Special ;	play exploding bomb sound
; ===========================================================================
Ani_obj1E:
	include "_anim\obj1E.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Ball Hog enemy (SBZ)
; ---------------------------------------------------------------------------
Map_obj1E:
	include "_maps\obj1E.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - explosion
; ---------------------------------------------------------------------------
Map_obj24:
	include "_maps\obj24.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - explosion
; ---------------------------------------------------------------------------
Map_obj27:	dc.w byte_8ED0-Map_obj27, byte_8ED6-Map_obj27
		dc.w byte_8EDC-Map_obj27, byte_8EE2-Map_obj27
		dc.w byte_8EF7-Map_obj27
byte_8ED0:	dc.b 1
		dc.b $F8, 9, 0,	0, $F4
byte_8ED6:	dc.b 1
		dc.b $F0, $F, 0, 6, $F0
byte_8EDC:	dc.b 1
		dc.b $F0, $F, 0, $16, $F0
byte_8EE2:	dc.b 4
		dc.b $EC, $A, 0, $26, $EC
		dc.b $EC, 5, 0,	$2F, 4
		dc.b 4,	5, $18,	$2F, $EC
		dc.b $FC, $A, $18, $26,	$FC
byte_8EF7:	dc.b 4
		dc.b $EC, $A, 0, $33, $EC
		dc.b $EC, 5, 0,	$3C, 4
		dc.b 4,	5, $18,	$3C, $EC
		dc.b $FC, $A, $18, $33,	$FC
		even
; ---------------------------------------------------------------------------
; Sprite mappings - explosion from when	a boss is destroyed
; ---------------------------------------------------------------------------
Map_obj3F:	dc.w byte_8ED0-Map_obj3F
		dc.w byte_8F16-Map_obj3F
		dc.w byte_8F1C-Map_obj3F
		dc.w byte_8EE2-Map_obj3F
		dc.w byte_8EF7-Map_obj3F
byte_8F16:	dc.b 1
		dc.b $F0, $F, 0, $40, $F0
byte_8F1C:	dc.b 1
		dc.b $F0, $F, 0, $50, $F0
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 28 - animals
; ---------------------------------------------------------------------------

Obj28:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj28_Index(pc,d0.w),d1
		jmp	Obj28_Index(pc,d1.w)
; ===========================================================================
Obj28_Index:	dc.w Obj28_Ending-Obj28_Index, loc_912A-Obj28_Index
		dc.w loc_9184-Obj28_Index, loc_91C0-Obj28_Index
		dc.w loc_9184-Obj28_Index, loc_9184-Obj28_Index
		dc.w loc_9184-Obj28_Index, loc_91C0-Obj28_Index
		dc.w loc_9184-Obj28_Index, loc_9240-Obj28_Index
		dc.w loc_9260-Obj28_Index, loc_9260-Obj28_Index
		dc.w loc_9280-Obj28_Index, loc_92BA-Obj28_Index
		dc.w loc_9314-Obj28_Index, loc_9332-Obj28_Index
		dc.w loc_9314-Obj28_Index, loc_9332-Obj28_Index
		dc.w loc_9314-Obj28_Index, loc_9370-Obj28_Index
		dc.w loc_92D6-Obj28_Index

Obj28_VarIndex:	dc.b 0,	5, 2, 3, 6, 3, 4, 5, 4,	1, 0, 1

Obj28_Variables:dc.w $FE00, $FC00
		dc.l Map_obj28
		dc.w $FE00, $FD00	; horizontal speed, vertical speed
		dc.l Map_obj28a		; mappings address
		dc.w $FE80, $FD00
		dc.l Map_obj28
		dc.w $FEC0, $FE80
		dc.l Map_obj28a
		dc.w $FE40, $FD00
		dc.l Map_obj28b
		dc.w $FD00, $FC00
		dc.l Map_obj28a
		dc.w $FD80, $FC80
		dc.l Map_obj28b

Obj28_EndSpeed:	dc.w $FBC0, $FC00, $FBC0, $FC00, $FBC0,	$FC00, $FD00, $FC00
		dc.w $FD00, $FC00, $FE80, $FD00, $FE80,	$FD00, $FEC0, $FE80
		dc.w $FE40, $FD00, $FE00, $FD00, $FD80,	$FC80

Obj28_EndMap:	dc.l Map_obj28a, Map_obj28a, Map_obj28a, Map_obj28, Map_obj28
		dc.l Map_obj28,	Map_obj28, Map_obj28a, Map_obj28b, Map_obj28a
		dc.l Map_obj28b

Obj28_EndVram:	dc.w $5A5, $5A5, $5A5, $553, $553, $573, $573, $585, $593
		dc.w $565, $5B3
; ===========================================================================

Obj28_Ending:				; XREF: Obj28_Index
		tst.b	$28(a0)		; did animal come from a destroyed enemy?
		beq.w	Obj28_FromEnemy	; if yes, branch
		moveq	#0,d0
		move.b	$28(a0),d0	; move object type to d0
		add.w	d0,d0		; multiply d0 by 2
		move.b	d0,$24(a0)	; move d0 to routine counter
		subi.w	#$14,d0
		move.w	Obj28_EndVram(pc,d0.w),2(a0)
		add.w	d0,d0
		move.l	Obj28_EndMap(pc,d0.w),4(a0)
		lea	Obj28_EndSpeed(pc),a1
		move.w	(a1,d0.w),$32(a0) ; load horizontal speed
		move.w	(a1,d0.w),$10(a0)
		move.w	2(a1,d0.w),$34(a0) ; load vertical speed
		move.w	2(a1,d0.w),$12(a0)
		move.b	#$C,$16(a0)
		move.b	#4,1(a0)
		bset	#0,1(a0)
		move.b	#6,$18(a0)
		move.b	#8,$19(a0)
		move.b	#7,$1E(a0)
		bra.w	DisplaySprite
; ===========================================================================

Obj28_FromEnemy:			; XREF: Obj28_Ending
		addq.b	#2,$24(a0)
		bsr.w	RandomNumber
		andi.w	#1,d0
		moveq	#0,d1
		move.b	($FFFFFE10).w,d1
		add.w	d1,d1
		add.w	d0,d1
		lea	Obj28_VarIndex(pc),a1
		move.b	(a1,d1.w),d0
		move.b	d0,$30(a0)
		lsl.w	#3,d0
		lea	Obj28_Variables(pc),a1
		adda.w	d0,a1
		move.w	(a1)+,$32(a0)	; load horizontal speed
		move.w	(a1)+,$34(a0)	; load vertical	speed
		move.l	(a1)+,4(a0)	; load mappings
		move.w	#$580,2(a0)	; VRAM setting for 1st animal
		btst	#0,$30(a0)	; is 1st animal	used?
		beq.s	loc_90C0	; if yes, branch
		move.w	#$592,2(a0)	; VRAM setting for 2nd animal

loc_90C0:
		move.b	#$C,$16(a0)
		move.b	#4,1(a0)
		bset	#0,1(a0)
		move.b	#6,$18(a0)
		move.b	#8,$19(a0)
		move.b	#7,$1E(a0)
		move.b	#2,$1A(a0)
		move.w	#-$400,$12(a0)
		tst.b	($FFFFF7A7).w
		bne.s	loc_911C
		bsr.w	SingleObjLoad
		bne.s	Obj28_Display
		move.b	#$29,0(a1)	; load points object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	$3E(a0),d0
		lsr.w	#1,d0
		move.b	d0,$1A(a1)

Obj28_Display:
		bra.w	DisplaySprite
; ===========================================================================

loc_911C:
		move.b	#$12,$24(a0)
		clr.w	$10(a0)
		bra.w	DisplaySprite
; ===========================================================================

loc_912A:				; XREF: Obj28_Index
		tst.b	1(a0)
		bpl.w	DeleteObject
		bsr.w	ObjectFall
		tst.w	$12(a0)
		bmi.s	loc_9180
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_9180
		add.w	d1,$C(a0)
		move.w	$32(a0),$10(a0)
		move.w	$34(a0),$12(a0)
		move.b	#1,$1A(a0)
		move.b	$30(a0),d0
		add.b	d0,d0
		addq.b	#4,d0
		move.b	d0,$24(a0)
		tst.b	($FFFFF7A7).w
		beq.s	loc_9180
		btst	#4,($FFFFFE0F).w
		beq.s	loc_9180
		neg.w	$10(a0)
		bchg	#0,1(a0)

loc_9180:
		bra.w	DisplaySprite
; ===========================================================================

loc_9184:				; XREF: Obj28_Index
		bsr.w	ObjectFall
		move.b	#1,$1A(a0)
		tst.w	$12(a0)
		bmi.s	loc_91AE
		move.b	#0,$1A(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_91AE
		add.w	d1,$C(a0)
		move.w	$34(a0),$12(a0)

loc_91AE:
		tst.b	$28(a0)
		bne.s	loc_9224
		tst.b	1(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

loc_91C0:				; XREF: Obj28_Index
		bsr.w	SpeedToPos
		addi.w	#$18,$12(a0)
		tst.w	$12(a0)
		bmi.s	loc_91FC
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_91FC
		add.w	d1,$C(a0)
		move.w	$34(a0),$12(a0)
		tst.b	$28(a0)
		beq.s	loc_91FC
		cmpi.b	#$A,$28(a0)
		beq.s	loc_91FC
		neg.w	$10(a0)
		bchg	#0,1(a0)

loc_91FC:
		subq.b	#1,$1E(a0)
		bpl.s	loc_9212
		move.b	#1,$1E(a0)
		addq.b	#1,$1A(a0)
		andi.b	#1,$1A(a0)

loc_9212:
		tst.b	$28(a0)
		bne.s	loc_9224
		tst.b	1(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

loc_9224:				; XREF: Obj28_Index
		move.w	8(a0),d0
		sub.w	($FFFFD008).w,d0
		bcs.s	loc_923C
		subi.w	#$180,d0
		bpl.s	loc_923C
		tst.b	1(a0)
		bpl.w	DeleteObject

loc_923C:
		bra.w	DisplaySprite
; ===========================================================================

loc_9240:				; XREF: Obj28_Index
		tst.b	1(a0)
		bpl.w	DeleteObject
		subq.w	#1,$36(a0)
		bne.w	loc_925C
		move.b	#2,$24(a0)
		move.b	#3,$18(a0)

loc_925C:
		bra.w	DisplaySprite
; ===========================================================================

loc_9260:				; XREF: Obj28_Index
		bsr.w	sub_9404
		bcc.s	loc_927C
		move.w	$32(a0),$10(a0)
		move.w	$34(a0),$12(a0)
		move.b	#$E,$24(a0)
		bra.w	loc_91C0
; ===========================================================================

loc_927C:
		bra.w	loc_9224
; ===========================================================================

loc_9280:				; XREF: Obj28_Index
		bsr.w	sub_9404
		bpl.s	loc_92B6
		clr.w	$10(a0)
		clr.w	$32(a0)
		bsr.w	SpeedToPos
		addi.w	#$18,$12(a0)
		bsr.w	loc_93C4
		bsr.w	loc_93EC
		subq.b	#1,$1E(a0)
		bpl.s	loc_92B6
		move.b	#1,$1E(a0)
		addq.b	#1,$1A(a0)
		andi.b	#1,$1A(a0)

loc_92B6:
		bra.w	loc_9224
; ===========================================================================

loc_92BA:				; XREF: Obj28_Index
		bsr.w	sub_9404
		bpl.s	loc_9310
		move.w	$32(a0),$10(a0)
		move.w	$34(a0),$12(a0)
		move.b	#4,$24(a0)
		bra.w	loc_9184
; ===========================================================================

loc_92D6:				; XREF: Obj28_Index
		bsr.w	ObjectFall
		move.b	#1,$1A(a0)
		tst.w	$12(a0)
		bmi.s	loc_9310
		move.b	#0,$1A(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_9310
		not.b	$29(a0)
		bne.s	loc_9306
		neg.w	$10(a0)
		bchg	#0,1(a0)

loc_9306:
		add.w	d1,$C(a0)
		move.w	$34(a0),$12(a0)

loc_9310:
		bra.w	loc_9224
; ===========================================================================

loc_9314:				; XREF: Obj28_Index
		bsr.w	sub_9404
		bpl.s	loc_932E
		clr.w	$10(a0)
		clr.w	$32(a0)
		bsr.w	ObjectFall
		bsr.w	loc_93C4
		bsr.w	loc_93EC

loc_932E:
		bra.w	loc_9224
; ===========================================================================

loc_9332:				; XREF: Obj28_Index
		bsr.w	sub_9404
		bpl.s	loc_936C
		bsr.w	ObjectFall
		move.b	#1,$1A(a0)
		tst.w	$12(a0)
		bmi.s	loc_936C
		move.b	#0,$1A(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_936C
		neg.w	$10(a0)
		bchg	#0,1(a0)
		add.w	d1,$C(a0)
		move.w	$34(a0),$12(a0)

loc_936C:
		bra.w	loc_9224
; ===========================================================================

loc_9370:				; XREF: Obj28_Index
		bsr.w	sub_9404
		bpl.s	loc_93C0
		bsr.w	SpeedToPos
		addi.w	#$18,$12(a0)
		tst.w	$12(a0)
		bmi.s	loc_93AA
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_93AA
		not.b	$29(a0)
		bne.s	loc_93A0
		neg.w	$10(a0)
		bchg	#0,1(a0)

loc_93A0:
		add.w	d1,$C(a0)
		move.w	$34(a0),$12(a0)

loc_93AA:
		subq.b	#1,$1E(a0)
		bpl.s	loc_93C0
		move.b	#1,$1E(a0)
		addq.b	#1,$1A(a0)
		andi.b	#1,$1A(a0)

loc_93C0:
		bra.w	loc_9224
; ===========================================================================

loc_93C4:
		move.b	#1,$1A(a0)
		tst.w	$12(a0)
		bmi.s	locret_93EA
		move.b	#0,$1A(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	locret_93EA
		add.w	d1,$C(a0)
		move.w	$34(a0),$12(a0)

locret_93EA:
		rts
; ===========================================================================

loc_93EC:
		bset	#0,1(a0)
		move.w	8(a0),d0
		sub.w	($FFFFD008).w,d0
		bcc.s	locret_9402
		bclr	#0,1(a0)

locret_9402:
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_9404:
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		subi.w	#$B8,d0
		rts
; End of function sub_9404

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 29 - points that appear when you destroy something
; ---------------------------------------------------------------------------

Obj29:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj29_Index(pc,d0.w),d1
		jsr	Obj29_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Obj29_Index:	dc.w Obj29_Main-Obj29_Index
		dc.w Obj29_Slower-Obj29_Index
; ===========================================================================

Obj29_Main:				; XREF: Obj29_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj29,4(a0)
		move.w	#$2797,2(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#8,$19(a0)
		move.w	#-$300,$12(a0)	; move object upwards

Obj29_Slower:				; XREF: Obj29_Index
		tst.w	$12(a0)		; is object moving?
		bpl.w	DeleteObject	; if not, branch
		bsr.w	SpeedToPos
		addi.w	#$18,$12(a0)	; reduce object	speed
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - animals
; ---------------------------------------------------------------------------
Map_obj28:
	include "_maps\obj28.asm"

Map_obj28a:
	include "_maps\obj28a.asm"

Map_obj28b:
	include "_maps\obj28b.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - points that	appear when you	destroy	something
; ---------------------------------------------------------------------------
Map_obj29:
	include "_maps\obj29.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1F - Crabmeat enemy (GHZ, SYZ)
; ---------------------------------------------------------------------------

Obj1F:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj1F_Index(pc,d0.w),d1
		jmp	Obj1F_Index(pc,d1.w)
; ===========================================================================
Obj1F_Index:	dc.w Obj1F_Main-Obj1F_Index
		dc.w Obj1F_Action-Obj1F_Index
		dc.w Obj1F_Delete-Obj1F_Index
		dc.w Obj1F_BallMain-Obj1F_Index
		dc.w Obj1F_BallMove-Obj1F_Index
; ===========================================================================

Obj1F_Main:				; XREF: Obj1F_Index
		move.b	#$10,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_obj1F,4(a0)
		move.w	#$400,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#6,$20(a0)
		move.b	#$15,$19(a0)
		bsr.w	ObjectFall
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	locret_955A
		add.w	d1,$C(a0)
		move.b	d3,$26(a0)
		move.w	#0,$12(a0)
		addq.b	#2,$24(a0)

locret_955A:
		rts
; ===========================================================================

Obj1F_Action:				; XREF: Obj1F_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj1F_Index2(pc,d0.w),d1
		jsr	Obj1F_Index2(pc,d1.w)
		lea	(Ani_obj1F).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj1F_Index2:	dc.w Obj1F_WaitFire-Obj1F_Index2
		dc.w Obj1F_WalkOnFloor-Obj1F_Index2
; ===========================================================================

Obj1F_WaitFire:				; XREF: Obj1F_Index2
		subq.w	#1,$30(a0)	; subtract 1 from time delay
		bpl.s	locret_95B6
		tst.b	1(a0)
		bpl.s	Obj1F_Move
		bchg	#1,$32(a0)
		bne.s	Obj1F_MakeFire

Obj1F_Move:
		addq.b	#2,$25(a0)
		move.w	#127,$30(a0)	; set time delay to approx 2 seconds
		move.w	#$80,$10(a0)	; move Crabmeat	to the right
		bsr.w	Obj1F_SetAni
		addq.b	#3,d0
		move.b	d0,$1C(a0)
		bchg	#0,$22(a0)
		bne.s	locret_95B6
		neg.w	$10(a0)		; change direction

locret_95B6:
		rts
; ===========================================================================

Obj1F_MakeFire:				; XREF: Obj1F_WaitFire
		move.w	#$3B,$30(a0)
		move.b	#6,$1C(a0)	; use firing animation
		bsr.w	SingleObjLoad
		bne.s	Obj1F_MakeFire2
		move.b	#$1F,0(a1)	; load left fireball
		move.b	#6,$24(a1)
		move.w	8(a0),8(a1)
		subi.w	#$10,8(a1)
		move.w	$C(a0),$C(a1)
		move.w	#-$100,$10(a1)

Obj1F_MakeFire2:
		bsr.w	SingleObjLoad
		bne.s	locret_9618
		move.b	#$1F,0(a1)	; load right fireball
		move.b	#6,$24(a1)
		move.w	8(a0),8(a1)
		addi.w	#$10,8(a1)
		move.w	$C(a0),$C(a1)
		move.w	#$100,$10(a1)

locret_9618:
		rts
; ===========================================================================

Obj1F_WalkOnFloor:			; XREF: Obj1F_Index2
		subq.w	#1,$30(a0)
		bmi.s	loc_966E
		bsr.w	SpeedToPos
		bchg	#0,$32(a0)
		bne.s	loc_9654
		move.w	8(a0),d3
		addi.w	#$10,d3
		btst	#0,$22(a0)
		beq.s	loc_9640
		subi.w	#$20,d3

loc_9640:
		jsr	ObjHitFloor2
		cmpi.w	#-8,d1
		blt.s	loc_966E
		cmpi.w	#$C,d1
		bge.s	loc_966E
		rts
; ===========================================================================

loc_9654:				; XREF: Obj1F_WalkOnFloor
		jsr	ObjHitFloor
		add.w	d1,$C(a0)
		move.b	d3,$26(a0)
		bsr.w	Obj1F_SetAni
		addq.b	#3,d0
		move.b	d0,$1C(a0)
		rts
; ===========================================================================

loc_966E:				; XREF: Obj1F_WalkOnFloor
		subq.b	#2,$25(a0)
		move.w	#59,$30(a0)
		move.w	#0,$10(a0)
		bsr.w	Obj1F_SetAni
		move.b	d0,$1C(a0)
		rts
; ---------------------------------------------------------------------------
; Subroutine to	set the	correct	animation for a	Crabmeat
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj1F_SetAni:				; XREF: loc_966E
		moveq	#0,d0
		move.b	$26(a0),d3
		bmi.s	loc_96A4
		cmpi.b	#6,d3
		bcs.s	locret_96A2
		moveq	#1,d0
		btst	#0,$22(a0)
		bne.s	locret_96A2
		moveq	#2,d0

locret_96A2:
		rts
; ===========================================================================

loc_96A4:				; XREF: Obj1F_SetAni
		cmpi.b	#-6,d3
		bhi.s	locret_96B6
		moveq	#2,d0
		btst	#0,$22(a0)
		bne.s	locret_96B6
		moveq	#1,d0

locret_96B6:
		rts
; End of function Obj1F_SetAni

; ===========================================================================

Obj1F_Delete:				; XREF: Obj1F_Index
		bsr.w	DeleteObject
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sub-object - missile that the	Crabmeat throws
; ---------------------------------------------------------------------------

Obj1F_BallMain:				; XREF: Obj1F_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj1F,4(a0)
		move.w	#$400,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$87,$20(a0)
		move.b	#8,$19(a0)
		move.w	#-$400,$12(a0)
		move.b	#7,$1C(a0)

Obj1F_BallMove:				; XREF: Obj1F_Index
		lea	(Ani_obj1F).l,a1
		bsr.w	AnimateSprite
		bsr.w	ObjectFall
		bsr.w	DisplaySprite
		move.w	($FFFFF72E).w,d0
		addi.w	#$E0,d0
		cmp.w	$C(a0),d0	; has object moved below the level boundary?
		bcs.s	Obj1F_Delete2	; if yes, branch
		rts
; ===========================================================================

Obj1F_Delete2:
		bra.w	DeleteObject
; ===========================================================================
Ani_obj1F:
	include "_anim\obj1F.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Crabmeat enemy (GHZ, SYZ)
; ---------------------------------------------------------------------------
Map_obj1F:
	include "_maps\obj1F.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 22 - Buzz Bomber enemy	(GHZ, MZ, SYZ)
; ---------------------------------------------------------------------------

Obj22:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj22_Index(pc,d0.w),d1
		jmp	Obj22_Index(pc,d1.w)
; ===========================================================================
Obj22_Index:	dc.w Obj22_Main-Obj22_Index
		dc.w Obj22_Action-Obj22_Index
		dc.w Obj22_Delete-Obj22_Index
; ===========================================================================

Obj22_Main:				; XREF: Obj22_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj22,4(a0)
		move.w	#$444,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#8,$20(a0)
		move.b	#$18,$19(a0)

Obj22_Action:				; XREF: Obj22_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj22_Index2(pc,d0.w),d1
		jsr	Obj22_Index2(pc,d1.w)
		lea	(Ani_obj22).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj22_Index2:	dc.w Obj22_Move-Obj22_Index2
		dc.w Obj22_ChkNrSonic-Obj22_Index2
; ===========================================================================

Obj22_Move:				; XREF: Obj22_Index2
		subq.w	#1,$32(a0)	; subtract 1 from time delay
		bpl.s	locret_986C	; if time remains, branch
		btst	#1,$34(a0)	; is Buzz Bomber near Sonic?
		bne.s	Obj22_Fire	; if yes, branch
		addq.b	#2,$25(a0)
		move.w	#127,$32(a0)	; set time delay to just over 2	seconds
		move.w	#$400,$10(a0)	; move Buzz Bomber to the right
		move.b	#1,$1C(a0)	; use "flying" animation
		btst	#0,$22(a0)	; is Buzz Bomber facing	left?
		bne.s	locret_986C	; if not, branch
		neg.w	$10(a0)		; move Buzz Bomber to the left

locret_986C:
		rts
; ===========================================================================

Obj22_Fire:				; XREF: Obj22_Move
		bsr.w	SingleObjLoad
		bne.s	locret_98D0
		move.b	#$23,0(a1)	; load missile object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		addi.w	#$1C,$C(a1)
		move.w	#$200,$12(a1)	; move missile downwards
		move.w	#$200,$10(a1)	; move missile to the right
		move.w	#$18,d0
		btst	#0,$22(a0)	; is Buzz Bomber facing	left?
		bne.s	loc_98AA	; if not, branch
		neg.w	d0
		neg.w	$10(a1)		; move missile to the left

loc_98AA:
		add.w	d0,8(a1)
		move.b	$22(a0),$22(a1)
		move.w	#$E,$32(a1)
		move.l	a0,$3C(a1)
		move.b	#1,$34(a0)	; set to "already fired" to prevent refiring
		move.w	#$3B,$32(a0)
		move.b	#2,$1C(a0)	; use "firing" animation

locret_98D0:
		rts
; ===========================================================================

Obj22_ChkNrSonic:			; XREF: Obj22_Index2
		subq.w	#1,$32(a0)	; subtract 1 from time delay
		bmi.s	Obj22_ChgDir
		bsr.w	SpeedToPos
		tst.b	$34(a0)
		bne.s	locret_992A
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bpl.s	Obj22_SetNrSonic
		neg.w	d0

Obj22_SetNrSonic:
		cmpi.w	#$60,d0		; is Buzz Bomber within	$60 pixels of Sonic?
		bcc.s	locret_992A	; if not, branch
		tst.b	1(a0)
		bpl.s	locret_992A
		move.b	#2,$34(a0)	; set Buzz Bomber to "near Sonic"
		move.w	#29,$32(a0)	; set time delay to half a second
		bra.s	Obj22_Stop
; ===========================================================================

Obj22_ChgDir:				; XREF: Obj22_ChkNrSonic
		move.b	#0,$34(a0)	; set Buzz Bomber to "normal"
		bchg	#0,$22(a0)	; change direction
		move.w	#59,$32(a0)

Obj22_Stop:				; XREF: Obj22_SetNrSonic
		subq.b	#2,$25(a0)	; run "Obj22_Fire" routine
		move.w	#0,$10(a0)	; stop Buzz Bomber moving
		move.b	#0,$1C(a0)	; use "hovering" animation

locret_992A:
		rts
; ===========================================================================

Obj22_Delete:				; XREF: Obj22_Index
		bsr.w	DeleteObject
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 23 - missile that Buzz	Bomber throws
; ---------------------------------------------------------------------------

Obj23:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj23_Index(pc,d0.w),d1
		jmp	Obj23_Index(pc,d1.w)
; ===========================================================================
Obj23_Index:	dc.w Obj23_Main-Obj23_Index
		dc.w Obj23_Animate-Obj23_Index
		dc.w Obj23_FromBuzz-Obj23_Index
		dc.w Obj23_Delete-Obj23_Index
		dc.w Obj23_FromNewt-Obj23_Index
; ===========================================================================

Obj23_Main:				; XREF: Obj23_Index
		subq.w	#1,$32(a0)
		bpl.s	Obj23_ChkCancel
		addq.b	#2,$24(a0)
		move.l	#Map_obj23,4(a0)
		move.w	#$2444,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#8,$19(a0)
		andi.b	#3,$22(a0)
		tst.b	$28(a0)		; was object created by	a Newtron?
		beq.s	Obj23_Animate	; if not, branch
		move.b	#8,$24(a0)	; run "Obj23_FromNewt" routine
		move.b	#$87,$20(a0)
		move.b	#1,$1C(a0)
		bra.s	Obj23_Animate2
; ===========================================================================

Obj23_Animate:				; XREF: Obj23_Index
		bsr.s	Obj23_ChkCancel
		lea	(Ani_obj23).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
; Subroutine to	check if the Buzz Bomber which fired the missile has been
; destroyed, and if it has, then cancel	the missile
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj23_ChkCancel:			; XREF: Obj23_Main
		movea.l	$3C(a0),a1
		cmpi.b	#$27,0(a1)	; has Buzz Bomber been destroyed?
		beq.s	Obj23_Delete	; if yes, branch
		rts
; End of function Obj23_ChkCancel

; ===========================================================================

Obj23_FromBuzz:				; XREF: Obj23_Index
		btst	#7,$22(a0)
		bne.s	Obj23_Explode
		move.b	#$87,$20(a0)
		move.b	#1,$1C(a0)
		bsr.w	SpeedToPos
		lea	(Ani_obj23).l,a1
		bsr.w	AnimateSprite
		bsr.w	DisplaySprite
		move.w	($FFFFF72E).w,d0
		addi.w	#$E0,d0
		cmp.w	$C(a0),d0	; has object moved below the level boundary?
		bcs.s	Obj23_Delete	; if yes, branch
		rts
; ===========================================================================

Obj23_Explode:				; XREF: Obj23_FromBuzz
		move.b	#$24,0(a0)	; change object	to an explosion	(Obj24)
		move.b	#0,$24(a0)
		bra.w	Obj24
; ===========================================================================

Obj23_Delete:				; XREF: Obj23_Index
		bsr.w	DeleteObject
		rts
; ===========================================================================

Obj23_FromNewt:				; XREF: Obj23_Index
		tst.b	1(a0)
		bpl.s	Obj23_Delete
		bsr.w	SpeedToPos

Obj23_Animate2:				; XREF: Obj23_Main
		lea	(Ani_obj23).l,a1
		bsr.w	AnimateSprite
		bsr.w	DisplaySprite
		rts
; ===========================================================================
Ani_obj22:
	include "_anim\obj22.asm"

Ani_obj23:
	include "_anim\obj23.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Buzz Bomber	enemy
; ---------------------------------------------------------------------------
Map_obj22:
	include "_maps\obj22.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - missile that Buzz Bomber throws
; ---------------------------------------------------------------------------
Map_obj23:
	include "_maps\obj23.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 25 - rings
; ---------------------------------------------------------------------------

Obj25:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj25_Index(pc,d0.w),d1
		jmp	Obj25_Index(pc,d1.w)
; ===========================================================================
Obj25_Index:	dc.w Obj25_Main-Obj25_Index
		dc.w Obj25_Animate-Obj25_Index
		dc.w Obj25_Collect-Obj25_Index
		dc.w Obj25_Sparkle-Obj25_Index
		dc.w Obj25_Delete-Obj25_Index
; ---------------------------------------------------------------------------
; Distances between rings (format: horizontal, vertical)
; ---------------------------------------------------------------------------
Obj25_PosData:	dc.b $10, 0		; horizontal tight
		dc.b $18, 0		; horizontal normal
		dc.b $20, 0		; horizontal wide
		dc.b 0,	$10		; vertical tight
		dc.b 0,	$18		; vertical normal
		dc.b 0,	$20		; vertical wide
		dc.b $10, $10		; diagonal
		dc.b $18, $18
		dc.b $20, $20
		dc.b $F0, $10
		dc.b $E8, $18
		dc.b $E0, $20
		dc.b $10, 8
		dc.b $18, $10
		dc.b $F0, 8
		dc.b $E8, $10
; ===========================================================================

Obj25_Main:				; XREF: Obj25_Index
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		lea	2(a2,d0.w),a2
		move.b	(a2),d4
		move.b	$28(a0),d1
		move.b	d1,d0
		andi.w	#7,d1
		cmpi.w	#7,d1
		bne.s	loc_9B80
		moveq	#6,d1

loc_9B80:
		swap	d1
		move.w	#0,d1
		lsr.b	#4,d0
		add.w	d0,d0
		move.b	Obj25_PosData(pc,d0.w),d5 ; load ring spacing data
		ext.w	d5
		move.b	Obj25_PosData+1(pc,d0.w),d6
		ext.w	d6
		movea.l	a0,a1
		move.w	8(a0),d2
		move.w	$C(a0),d3
		lsr.b	#1,d4
		bcs.s	loc_9C02
		bclr	#7,(a2)
		bra.s	loc_9BBA
; ===========================================================================

Obj25_MakeRings:
		swap	d1
		lsr.b	#1,d4
		bcs.s	loc_9C02
		bclr	#7,(a2)
		bsr.w	SingleObjLoad
		bne.s	loc_9C0E

loc_9BBA:				; XREF: Obj25_Main
		move.b	#$25,0(a1)	; load ring object
		addq.b	#2,$24(a1)
		move.w	d2,8(a1)	; set x-axis position based on d2
		move.w	8(a0),$32(a1)
		move.w	d3,$C(a1)	; set y-axis position based on d3
		move.l	#Map_obj25,4(a1)
		move.w	#$27B2,2(a1)
		move.b	#4,1(a1)
		move.b	#2,$18(a1)
		move.b	#$47,$20(a1)
		move.b	#8,$19(a1)
		move.b	$23(a0),$23(a1)
		move.b	d1,$34(a1)

loc_9C02:
		addq.w	#1,d1
		add.w	d5,d2		; add ring spacing value to d2
		add.w	d6,d3		; add ring spacing value to d3
		swap	d1
		dbf	d1,Obj25_MakeRings ; repeat for	number of rings

loc_9C0E:
		btst	#0,(a2)
		bne.w	DeleteObject

Obj25_Animate:				; XREF: Obj25_Index
		move.b	($FFFFFEC3).w,$1A(a0) ;	set frame
		bsr.w	DisplaySprite
		move.w	$32(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj25_Delete
		rts
; ===========================================================================

Obj25_Collect:				; XREF: Obj25_Index
		addq.b	#2,$24(a0)
		move.b	#0,$20(a0)
		move.b	#1,$18(a0)
		bsr.w	CollectRing
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		move.b	$34(a0),d1
		bset	d1,2(a2,d0.w)

Obj25_Sparkle:				; XREF: Obj25_Index
		lea	(Ani_obj25).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Obj25_Delete:				; XREF: Obj25_Index
		bra.w	DeleteObject

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CollectRing:				; XREF: Obj25_Collect
		addq.w	#1,($FFFFFE20).w ; add 1 to rings
		ori.b	#1,($FFFFFE1D).w ; update the rings counter
		moveq	#sfx_RingRight,d0; play ring sound
		cmpi.w	#100,($FFFFFE20).w ; do	you have < 100 rings?
		bcs.s	Obj25_PlaySnd	; if yes, branch
		bset	#1,($FFFFFE1B).w ; update lives	counter
		beq.s	loc_9CA4
		cmpi.w	#200,($FFFFFE20).w ; do	you have < 200 rings?
		bcs.s	Obj25_PlaySnd	; if yes, branch
		bset	#2,($FFFFFE1B).w ; update lives	counter
		bne.s	Obj25_PlaySnd

loc_9CA4:
		addq.b	#1,($FFFFFE12).w ; add 1 to the	number of lives	you have
		addq.b	#1,($FFFFFE1C).w ; add 1 to the	lives counter
		moveq	#mus_ExtraLife,d0		; play extra life music

Obj25_PlaySnd:
		jmp	(PlaySound_Special).l
; End of function CollectRing

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 37 - rings flying out of Sonic	when he's hit
; ---------------------------------------------------------------------------

Obj37:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj37_Index(pc,d0.w),d1
		jmp	Obj37_Index(pc,d1.w)
; ===========================================================================
Obj37_Index:	dc.w Obj37_CountRings-Obj37_Index
		dc.w Obj37_Bounce-Obj37_Index
		dc.w Obj37_Collect-Obj37_Index
		dc.w Obj37_Sparkle-Obj37_Index
		dc.w Obj37_Delete-Obj37_Index
; ===========================================================================

Obj37_CountRings:			; XREF: Obj37_Index
		movea.l	a0,a1
		moveq	#0,d5
		move.w	($FFFFFE20).w,d5 ; check number	of rings you have
		moveq	#32,d0
		cmp.w	d0,d5		; do you have 32 or more?
		bcs.s	loc_9CDE	; if not, branch
		move.w	d0,d5		; if yes, set d5 to 32

loc_9CDE:
		subq.w	#1,d5
		move.w	#$288,d4
		bra.s	Obj37_MakeRings
; ===========================================================================

Obj37_Loop:
		bsr.w	SingleObjLoad
		bne.w	Obj37_ResetCounter

Obj37_MakeRings:			; XREF: Obj37_CountRings
		move.b	#$37,0(a1)	; load bouncing	ring object
		addq.b	#2,$24(a1)
		move.b	#8,$16(a1)
		move.b	#8,$17(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.l	#Map_obj25,4(a1)
		move.w	#$27B2,2(a1)
		move.b	#4,1(a1)
		move.b	#3,$18(a1)
		move.b	#$47,$20(a1)
		move.b	#8,$19(a1)
		move.b	#-1,($FFFFFEC6).w
		tst.w	d4
		bmi.s	loc_9D62
		move.w	d4,d0
		bsr.w	CalcSine
		move.w	d4,d2
		lsr.w	#8,d2
		asl.w	d2,d0
		asl.w	d2,d1
		move.w	d0,d2
		move.w	d1,d3
		addi.b	#$10,d4
		bcc.s	loc_9D62
		subi.w	#$80,d4
		bcc.s	loc_9D62
		move.w	#$288,d4

loc_9D62:
		move.w	d2,$10(a1)
		move.w	d3,$12(a1)
		neg.w	d2
		neg.w	d4
		dbf	d5,Obj37_Loop	; repeat for number of rings (max 31)

Obj37_ResetCounter:			; XREF: Obj37_Loop
		move.w	#0,($FFFFFE20).w ; reset number	of rings to zero
		move.b	#$80,($FFFFFE1D).w ; update ring counter
		move.b	#0,($FFFFFE1B).w
		moveq	#sfx_RingLoss,d0
		jsr	PlaySound_Special ;	play ring loss sound

Obj37_Bounce:				; XREF: Obj37_Index
		move.b	($FFFFFEC7).w,$1A(a0)
		bsr.w	SpeedToPos
		addi.w	#$18,$12(a0)
		bmi.s	Obj37_ChkDel
		move.b	($FFFFFE0F).w,d0
		add.b	d7,d0
		andi.b	#3,d0
		bne.s	Obj37_ChkDel
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	Obj37_ChkDel
		add.w	d1,$C(a0)
		move.w	$12(a0),d0
		asr.w	#2,d0
		sub.w	d0,$12(a0)
		neg.w	$12(a0)

Obj37_ChkDel:				; XREF: Obj37_Bounce
		tst.b	($FFFFFEC6).w
		beq.s	Obj37_Delete
		move.w	($FFFFF72E).w,d0
		addi.w	#$E0,d0
		cmp.w	$C(a0),d0	; has object moved below level boundary?
		bcs.s	Obj37_Delete	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

Obj37_Collect:				; XREF: Obj37_Index
		addq.b	#2,$24(a0)
		move.b	#0,$20(a0)
		move.b	#1,$18(a0)
		bsr.w	CollectRing

Obj37_Sparkle:				; XREF: Obj37_Index
		lea	(Ani_obj25).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Obj37_Delete:				; XREF: Obj37_Index
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4B - giant ring for entry to special stage
; ---------------------------------------------------------------------------

Obj4B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj4B_Index(pc,d0.w),d1
		jmp	Obj4B_Index(pc,d1.w)
; ===========================================================================
Obj4B_Index:	dc.w Obj4B_Main-Obj4B_Index
		dc.w Obj4B_Animate-Obj4B_Index
		dc.w Obj4B_Collect-Obj4B_Index
		dc.w Obj4B_Delete-Obj4B_Index
; ===========================================================================

Obj4B_Main:				; XREF: Obj4B_Index
		move.l	#Map_obj4B,4(a0)
		move.w	#$2400,2(a0)
		ori.b	#4,1(a0)
		move.b	#$40,$19(a0)
		tst.b	1(a0)
		bpl.s	Obj4B_Animate
		cmpi.b	#6,($FFFFFE57).w ; do you have 6 emeralds?
		beq.w	Obj4B_Delete	; if yes, branch
		cmpi.w	#50,($FFFFFE20).w ; do you have	at least 50 rings?
		bcc.s	Obj4B_Okay	; if yes, branch
		rts
; ===========================================================================

Obj4B_Okay:				; XREF: Obj4B_Main
		addq.b	#2,$24(a0)
		move.b	#2,$18(a0)
		move.b	#$52,$20(a0)
		move.w	#$C40,($FFFFF7BE).w

Obj4B_Animate:				; XREF: Obj4B_Index
		move.b	($FFFFFEC3).w,$1A(a0)
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

Obj4B_Collect:				; XREF: Obj4B_Index
		subq.b	#2,$24(a0)
		move.b	#0,$20(a0)
		bsr.w	SingleObjLoad
		bne.w	Obj4B_PlaySnd
		move.b	#$7C,0(a1)	; load giant ring flash	object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.l	a0,$3C(a1)
		move.w	($FFFFD008).w,d0
		cmp.w	8(a0),d0	; has Sonic come from the left?
		bcs.s	Obj4B_PlaySnd	; if yes, branch
		bset	#0,1(a1)	; reverse flash	object

Obj4B_PlaySnd:
		moveq	#sfx_BigRing,d0
		jsr	PlaySound_Special ;	play giant ring	sound
		bra.s	Obj4B_Animate
; ===========================================================================

Obj4B_Delete:				; XREF: Obj4B_Index
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 7C - flash effect when	you collect the	giant ring
; ---------------------------------------------------------------------------

Obj7C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj7C_Index(pc,d0.w),d1
		jmp	Obj7C_Index(pc,d1.w)
; ===========================================================================
Obj7C_Index:	dc.w Obj7C_Main-Obj7C_Index
		dc.w Obj7C_ChkDel-Obj7C_Index
		dc.w Obj7C_Delete-Obj7C_Index
; ===========================================================================

Obj7C_Main:				; XREF: Obj7C_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj7C,4(a0)
		move.w	#$2462,2(a0)
		ori.b	#4,1(a0)
		move.b	#0,$18(a0)
		move.b	#$20,$19(a0)
		move.b	#$FF,$1A(a0)

Obj7C_ChkDel:				; XREF: Obj7C_Index
		bsr.s	Obj7C_Collect
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj7C_Collect:				; XREF: Obj7C_ChkDel
		subq.b	#1,$1E(a0)
		bpl.s	locret_9F76
		move.b	#1,$1E(a0)
		addq.b	#1,$1A(a0)
		cmpi.b	#8,$1A(a0)	; has animation	finished?
		bcc.s	Obj7C_End	; if yes, branch
		cmpi.b	#3,$1A(a0)	; is 3rd frame displayed?
		bne.s	locret_9F76	; if not, branch
		movea.l	$3C(a0),a1
		move.b	#6,$24(a1)	; delete giant ring object (Obj4B)
		move.b	#$1C,($FFFFD01C).w ; make Sonic	invisible
		move.b	#1,($FFFFF7CD).w ; stop	Sonic getting bonuses
		clr.b	($FFFFFE2D).w	; remove invincibility
		clr.b	($FFFFFE2C).w	; remove shield

locret_9F76:
		rts
; ===========================================================================

Obj7C_End:				; XREF: Obj7C_Collect
		addq.b	#2,$24(a0)
		move.w	#0,($FFFFD000).w ; remove Sonic	object
		addq.l	#4,sp
		rts
; End of function Obj7C_Collect

; ===========================================================================

Obj7C_Delete:				; XREF: Obj7C_Index
		bra.w	DeleteObject
; ===========================================================================
Ani_obj25:
	include "_anim\obj25.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - rings
; ---------------------------------------------------------------------------
Map_obj25:
	include "_maps\obj25.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - giant ring
; ---------------------------------------------------------------------------
Map_obj4B:
	include "_maps\obj4B.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - flash effect when you collect the giant ring
; ---------------------------------------------------------------------------
Map_obj7C:
	include "_maps\obj7C.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 26 - monitors
; ---------------------------------------------------------------------------

Obj26:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj26_Index(pc,d0.w),d1
		jmp	Obj26_Index(pc,d1.w)
; ===========================================================================
Obj26_Index:	dc.w Obj26_Main-Obj26_Index
		dc.w Obj26_Solid-Obj26_Index
		dc.w Obj26_BreakOpen-Obj26_Index
		dc.w Obj26_Animate-Obj26_Index
		dc.w Obj26_Display-Obj26_Index
; ===========================================================================

Obj26_Main:				; XREF: Obj26_Index
		addq.b	#2,$24(a0)
		move.b	#$E,$16(a0)
		move.b	#$E,$17(a0)
		move.l	#Map_obj26,4(a0)
		move.w	#$680,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$F,$19(a0)
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		bclr	#7,2(a2,d0.w)
		btst	#0,2(a2,d0.w)	; has monitor been broken?
		beq.s	Obj26_NotBroken	; if not, branch
		move.b	#8,$24(a0)	; run "Obj26_Display" routine
		move.b	#$B,$1A(a0)	; use broken monitor frame
		rts
; ===========================================================================

Obj26_NotBroken:			; XREF: Obj26_Main
		move.b	#$46,$20(a0)
		move.b	$28(a0),$1C(a0)

Obj26_Solid:				; XREF: Obj26_Index
		move.b	$25(a0),d0	; is monitor set to fall?
		beq.s	loc_A1EC	; if not, branch
		subq.b	#2,d0
		bne.s	Obj26_Fall
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		bsr.w	ExitPlatform
		btst	#3,$22(a1)
		bne.w	loc_A1BC
		clr.b	$25(a0)
		bra.w	Obj26_Animate
; ===========================================================================

loc_A1BC:				; XREF: Obj26_Solid
		move.w	#$10,d3
		move.w	8(a0),d2
		bsr.w	MvSonicOnPtfm
		bra.w	Obj26_Animate
; ===========================================================================

Obj26_Fall:				; XREF: Obj26_Solid
		bsr.w	ObjectFall
		jsr	ObjHitFloor
		tst.w	d1
		bpl.w	Obj26_Animate
		add.w	d1,$C(a0)
		clr.w	$12(a0)
		clr.b	$25(a0)
		bra.w	Obj26_Animate
; ===========================================================================

loc_A1EC:				; XREF: Obj26_Solid
		move.w	#$1A,d1
		move.w	#$F,d2
		bsr.w	Obj26_SolidSides
		beq.w	loc_A25C
		tst.w	$12(a1)
		bmi.s	loc_A20A
		cmpi.b	#2,$1C(a1)	; is Sonic rolling?
		beq.s	loc_A25C	; if yes, branch

loc_A20A:
		tst.w	d1
		bpl.s	loc_A220
		sub.w	d3,$C(a1)
		bsr.w	loc_74AE
		move.b	#2,$25(a0)
		bra.w	Obj26_Animate
; ===========================================================================

loc_A220:
		tst.w	d0
		beq.w	loc_A246
		bmi.s	loc_A230
		tst.w	$10(a1)
		bmi.s	loc_A246
		bra.s	loc_A236
; ===========================================================================

loc_A230:
		tst.w	$10(a1)
		bpl.s	loc_A246

loc_A236:
		sub.w	d0,8(a1)
		move.w	#0,$14(a1)
		move.w	#0,$10(a1)

loc_A246:
		btst	#1,$22(a1)
		bne.s	loc_A26A
		bset	#5,$22(a1)
		bset	#5,$22(a0)
		bra.s	Obj26_Animate
; ===========================================================================

loc_A25C:
		btst	#5,$22(a0)
		beq.s	Obj26_Animate
		move.w	#1,$1C(a1)

loc_A26A:
		bclr	#5,$22(a0)
		bclr	#5,$22(a1)

Obj26_Animate:				; XREF: Obj26_Index
		lea	(Ani_obj26).l,a1
		bsr.w	AnimateSprite

Obj26_Display:				; XREF: Obj26_Index
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================

Obj26_BreakOpen:			; XREF: Obj26_Index
		addq.b	#2,$24(a0)
		move.b	#0,$20(a0)
		bsr.w	SingleObjLoad
		bne.s	Obj26_Explode
		move.b	#$2E,0(a1)	; load monitor contents	object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$1C(a0),$1C(a1)

Obj26_Explode:
		bsr.w	SingleObjLoad
		bne.s	Obj26_SetBroken
		move.b	#$27,0(a1)	; load explosion object
		addq.b	#2,$24(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

Obj26_SetBroken:
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		bset	#0,2(a2,d0.w)
		move.b	#9,$1C(a0)	; set monitor type to broken
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2E - contents of monitors
; ---------------------------------------------------------------------------

Obj2E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj2E_Index(pc,d0.w),d1
		jsr	Obj2E_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Obj2E_Index:	dc.w Obj2E_Main-Obj2E_Index
		dc.w Obj2E_Move-Obj2E_Index
		dc.w Obj2E_Delete-Obj2E_Index
; ===========================================================================

Obj2E_Main:				; XREF: Obj2E_Index
		addq.b	#2,$24(a0)
		move.w	#$680,2(a0)
		move.b	#$24,1(a0)
		move.b	#3,$18(a0)
		move.b	#8,$19(a0)
		move.w	#-$300,$12(a0)
		moveq	#0,d0
		move.b	$1C(a0),d0
		addq.b	#2,d0
		move.b	d0,$1A(a0)
		movea.l	#Map_obj26,a1
		add.b	d0,d0
		adda.w	(a1,d0.w),a1
		addq.w	#1,a1
		move.l	a1,4(a0)

Obj2E_Move:				; XREF: Obj2E_Index
		tst.w	$12(a0)		; is object moving?
		bpl.w	Obj2E_ChkEggman	; if not, branch
		bsr.w	SpeedToPos
		addi.w	#$18,$12(a0)	; reduce object	speed
		rts
; ===========================================================================

Obj2E_ChkEggman:			; XREF: Obj2E_Move
		addq.b	#2,$24(a0)
		move.w	#29,$1E(a0)
		move.b	$1C(a0),d0
		cmpi.b	#1,d0		; does monitor contain Eggman?
		bne.s	Obj2E_ChkSonic
		rts			; Eggman monitor does nothing
; ===========================================================================

Obj2E_ChkSonic:
		cmpi.b	#2,d0		; does monitor contain Sonic?
		bne.s	Obj2E_ChkShoes

ExtraLife:
		addq.b	#1,($FFFFFE12).w ; add 1 to the	number of lives	you have
		addq.b	#1,($FFFFFE1C).w ; add 1 to the	lives counter
		moveq	#mus_ExtraLife,d0
		jmp	(PlaySound).l	; play extra life music
; ===========================================================================

Obj2E_ChkShoes:
		cmpi.b	#3,d0		; does monitor contain speed shoes?
		bne.s	Obj2E_ChkShield
		move.b	#1,($FFFFFE2E).w ; speed up the	BG music
		move.w	#$4B0,($FFFFD034).w ; time limit for the power-up
		move.w	#$C00,($FFFFF760).w ; change Sonic's top speed
		move.w	#$18,($FFFFF762).w
		move.w	#$80,($FFFFF764).w
		moveq	#Mus_ShoesOn,d0
		jmp	(PlaySound).l	; Speed	up the music
; ===========================================================================

Obj2E_ChkShield:
		cmpi.b	#4,d0		; does monitor contain a shield?
		bne.s	Obj2E_ChkInvinc
		move.b	#1,($FFFFFE2C).w ; give	Sonic a	shield
		move.b	#$38,($FFFFD180).w ; load shield object	($38)
		moveq	#sfx_Shield,d0
		jmp	(PlaySound).l	; play shield sound
; ===========================================================================

Obj2E_ChkInvinc:
		cmpi.b	#5,d0		; does monitor contain invincibility?
		bne.s	Obj2E_ChkRings
		move.b	#1,($FFFFFE2D).w ; make	Sonic invincible
		move.w	#$4B0,($FFFFD032).w ; time limit for the power-up
		move.b	#$38,($FFFFD200).w ; load stars	object ($3801)
		move.b	#1,($FFFFD21C).w
		move.b	#$38,($FFFFD240).w ; load stars	object ($3802)
		move.b	#2,($FFFFD25C).w
		move.b	#$38,($FFFFD280).w ; load stars	object ($3803)
		move.b	#3,($FFFFD29C).w
		move.b	#$38,($FFFFD2C0).w ; load stars	object ($3804)
		move.b	#4,($FFFFD2DC).w
		tst.b	($FFFFF7AA).w	; is boss mode on?
		bne.s	Obj2E_NoMusic	; if yes, branch
		moveq	#mus_Invincibility,d0
		jmp	(PlaySound).l	; play invincibility music
; ===========================================================================

Obj2E_NoMusic:
		rts
; ===========================================================================

Obj2E_ChkRings:
		cmpi.b	#6,d0		; does monitor contain 10 rings?
		bne.s	Obj2E_ChkS
		addi.w	#$A,($FFFFFE20).w ; add	10 rings to the	number of rings	you have
		ori.b	#1,($FFFFFE1D).w ; update the ring counter
		cmpi.w	#100,($FFFFFE20).w ; check if you have 100 rings
		bcs.s	Obj2E_RingSound
		bset	#1,($FFFFFE1B).w
		beq.w	ExtraLife
		cmpi.w	#200,($FFFFFE20).w ; check if you have 200 rings
		bcs.s	Obj2E_RingSound
		bset	#2,($FFFFFE1B).w
		beq.w	ExtraLife

Obj2E_RingSound:
		move.w	#sfx_RingRight,d0
		jmp	(PlaySound).l	; play ring sound
; ===========================================================================

Obj2E_ChkS:
		cmpi.b	#7,d0		; does monitor contain 'S'
		bne.s	Obj2E_ChkEnd
		nop

Obj2E_ChkEnd:
		rts			; 'S' and goggles monitors do nothing
; ===========================================================================

Obj2E_Delete:				; XREF: Obj2E_Index
		subq.w	#1,$1E(a0)
		bmi.w	DeleteObject
		rts
; ---------------------------------------------------------------------------
; Subroutine to	make the sides of a monitor solid
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj26_SolidSides:			; XREF: loc_A1EC
		lea	($FFFFD000).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_A4E6
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.s	loc_A4E6
		move.b	$16(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	$C(a1),d3
		sub.w	$C(a0),d3
		add.w	d2,d3
		bmi.s	loc_A4E6
		add.w	d2,d2
		cmp.w	d2,d3
		bcc.s	loc_A4E6
		tst.b	($FFFFF7C8).w
		bmi.s	loc_A4E6
		cmpi.b	#6,($FFFFD024).w
		bcc.s	loc_A4E6
		tst.w	($FFFFFE08).w
		bne.s	loc_A4E6
		cmp.w	d0,d1
		bcc.s	loc_A4DC
		add.w	d1,d1
		sub.w	d1,d0

loc_A4DC:
		cmpi.w	#$10,d3
		bcs.s	loc_A4EA

loc_A4E2:
		moveq	#1,d1
		rts
; ===========================================================================

loc_A4E6:
		moveq	#0,d1
		rts
; ===========================================================================

loc_A4EA:
		moveq	#0,d1
		move.b	$19(a0),d1
		addq.w	#4,d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	8(a1),d1
		sub.w	8(a0),d1
		bmi.s	loc_A4E2
		cmp.w	d2,d1
		bcc.s	loc_A4E2
		moveq	#-1,d1
		rts
; End of function Obj26_SolidSides

; ===========================================================================
Ani_obj26:
	include "_anim\obj26.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - monitors
; ---------------------------------------------------------------------------
Map_obj26:
	include "_maps\obj26.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0E - Sonic on the title screen
; ---------------------------------------------------------------------------

Obj0E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj0E_Index(pc,d0.w),d1
		jmp	Obj0E_Index(pc,d1.w)
; ===========================================================================
Obj0E_Index:	dc.w Obj0E_Main-Obj0E_Index
		dc.w Obj0E_Delay-Obj0E_Index
		dc.w Obj0E_Move-Obj0E_Index
		dc.w Obj0E_Animate-Obj0E_Index
; ===========================================================================

Obj0E_Main:				; XREF: Obj0E_Index
		addq.b	#2,$24(a0)
		move.w	#$F0,8(a0)
		move.w	#$DE,$A(a0)
		move.l	#Map_obj0E,4(a0)
		move.w	#$2300,2(a0)
		move.b	#1,$18(a0)
		move.b	#29,$1F(a0)	; set time delay to 0.5	seconds
		lea	(Ani_obj0E).l,a1
		bsr.w	AnimateSprite

Obj0E_Delay:				; XREF: Obj0E_Index
		subq.b	#1,$1F(a0)	; subtract 1 from time delay
		bpl.s	Obj0E_Wait	; if time remains, branch
		addq.b	#2,$24(a0)	; go to	next routine
		bra.w	DisplaySprite
; ===========================================================================

Obj0E_Wait:				; XREF: Obj0E_Delay
		rts
; ===========================================================================

Obj0E_Move:				; XREF: Obj0E_Index
		subq.w	#8,$A(a0)
		cmpi.w	#$96,$A(a0)
		bne.s	Obj0E_Display
		addq.b	#2,$24(a0)

Obj0E_Display:
		bra.w	DisplaySprite
; ===========================================================================
		rts
; ===========================================================================

Obj0E_Animate:				; XREF: Obj0E_Index
		lea	(Ani_obj0E).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0F - "PRESS START BUTTON" and "TM" from title screen
; ---------------------------------------------------------------------------

Obj0F:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj0F_Index(pc,d0.w),d1
		jsr	Obj0F_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Obj0F_Index:	dc.w Obj0F_Main-Obj0F_Index
		dc.w Obj0F_PrsStart-Obj0F_Index
		dc.w locret_A6F8-Obj0F_Index
; ===========================================================================

Obj0F_Main:				; XREF: Obj0F_Index
		addq.b	#2,$24(a0)
		move.w	#$D0,8(a0)
		move.w	#$130,$A(a0)
		move.l	#Map_obj0F,4(a0)
		move.w	#$200,2(a0)
		cmpi.b	#2,$1A(a0)	; is object "PRESS START"?
		bcs.s	Obj0F_PrsStart	; if yes, branch
		addq.b	#2,$24(a0)
		cmpi.b	#3,$1A(a0)	; is the object	"TM"?
		bne.s	locret_A6F8	; if not, branch
		move.w	#$2510,2(a0)	; "TM" specific	code
		move.w	#$170,8(a0)
		move.w	#$F8,$A(a0)

locret_A6F8:				; XREF: Obj0F_Index
		rts
; ===========================================================================

Obj0F_PrsStart:				; XREF: Obj0F_Index
		lea	(Ani_obj0F).l,a1
		bra.w	AnimateSprite
; ===========================================================================
Ani_obj0E:
	include "_anim\obj0E.asm"

Ani_obj0F:
	include "_anim\obj0F.asm"

; ---------------------------------------------------------------------------
; Subroutine to	animate	a sprite using an animation script
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AnimateSprite:
		moveq	#0,d0
		move.b	$1C(a0),d0	; move animation number	to d0
		cmp.b	$1D(a0),d0	; is animation set to restart?
		beq.s	Anim_Run	; if not, branch
		move.b	d0,$1D(a0)	; set to "no restart"
		move.b	#0,$1B(a0)	; reset	animation
		move.b	#0,$1E(a0)	; reset	frame duration

Anim_Run:
		subq.b	#1,$1E(a0)	; subtract 1 from frame	duration
		bpl.s	Anim_Wait	; if time remains, branch
		add.w	d0,d0
		adda.w	(a1,d0.w),a1	; jump to appropriate animation	script
		move.b	(a1),$1E(a0)	; load frame duration
		moveq	#0,d1
		move.b	$1B(a0),d1	; load current frame number
		move.b	1(a1,d1.w),d0	; read sprite number from script
		bmi.s	Anim_End_FF	; if animation is complete, branch

Anim_Next:
		move.b	d0,d1
		andi.b	#$1F,d0
		move.b	d0,$1A(a0)	; load sprite number
		move.b	$22(a0),d0
		rol.b	#3,d1
		eor.b	d0,d1
		andi.b	#3,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		addq.b	#1,$1B(a0)	; next frame number

Anim_Wait:
		rts
; ===========================================================================

Anim_End_FF:
		addq.b	#1,d0		; is the end flag = $FF	?
		bne.s	Anim_End_FE	; if not, branch
		move.b	#0,$1B(a0)	; restart the animation
		move.b	1(a1),d0	; read sprite number
		bra.s	Anim_Next
; ===========================================================================

Anim_End_FE:
		addq.b	#1,d0		; is the end flag = $FE	?
		bne.s	Anim_End_FD	; if not, branch
		move.b	2(a1,d1.w),d0	; read the next	byte in	the script
		sub.b	d0,$1B(a0)	; jump back d0 bytes in	the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0	; read sprite number
		bra.s	Anim_Next
; ===========================================================================

Anim_End_FD:
		addq.b	#1,d0		; is the end flag = $FD	?
		bne.s	Anim_End_FC	; if not, branch
		move.b	2(a1,d1.w),$1C(a0) ; read next byte, run that animation

Anim_End_FC:
		addq.b	#1,d0		; is the end flag = $FC	?
		bne.s	Anim_End_FB	; if not, branch
		addq.b	#2,$24(a0)	; jump to next routine

Anim_End_FB:
		addq.b	#1,d0		; is the end flag = $FB	?
		bne.s	Anim_End_FA	; if not, branch
		move.b	#0,$1B(a0)	; reset	animation
		clr.b	$25(a0)		; reset	2nd routine counter

Anim_End_FA:
		addq.b	#1,d0		; is the end flag = $FA	?
		bne.s	Anim_End	; if not, branch
		addq.b	#2,$25(a0)	; jump to next routine

Anim_End:
		rts
; End of function AnimateSprite

; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - "PRESS START BUTTON" and "TM" from title screen
; ---------------------------------------------------------------------------
Map_obj0F:
	include "_maps\obj0F.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Sonic on the title screen
; ---------------------------------------------------------------------------
Map_obj0E:
	include "_maps\obj0E.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2B - Chopper enemy (GHZ)
; ---------------------------------------------------------------------------

Obj2B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj2B_Index(pc,d0.w),d1
		jsr	Obj2B_Index(pc,d1.w)
		bra.w	MarkObjGone
; ===========================================================================
Obj2B_Index:	dc.w Obj2B_Main-Obj2B_Index
		dc.w Obj2B_ChgSpeed-Obj2B_Index
; ===========================================================================

Obj2B_Main:				; XREF: Obj2B_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj2B,4(a0)
		move.w	#$47B,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#9,$20(a0)
		move.b	#$10,$19(a0)
		move.w	#-$700,$12(a0)	; set vertical speed
		move.w	$C(a0),$30(a0)

Obj2B_ChgSpeed:				; XREF: Obj2B_Index
		lea	(Ani_obj2B).l,a1
		bsr.w	AnimateSprite
		bsr.w	SpeedToPos
		addi.w	#$18,$12(a0)	; reduce speed
		move.w	$30(a0),d0
		cmp.w	$C(a0),d0
		bcc.s	Obj2B_ChgAni
		move.w	d0,$C(a0)
		move.w	#-$700,$12(a0)	; set vertical speed

Obj2B_ChgAni:
		move.b	#1,$1C(a0)	; use fast animation
		subi.w	#$C0,d0
		cmp.w	$C(a0),d0
		bcc.s	locret_ABB6
		move.b	#0,$1C(a0)	; use slow animation
		tst.w	$12(a0)		; is Chopper at	its highest point?
		bmi.s	locret_ABB6	; if not, branch
		move.b	#2,$1C(a0)	; use stationary animation

locret_ABB6:
		rts
; ===========================================================================
Ani_obj2B:
	include "_anim\obj2B.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Chopper enemy (GHZ)
; ---------------------------------------------------------------------------
Map_obj2B:
	include "_maps\obj2B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2C - Jaws enemy (LZ)
; ---------------------------------------------------------------------------

Obj2C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj2C_Index(pc,d0.w),d1
		jmp	Obj2C_Index(pc,d1.w)
; ===========================================================================
Obj2C_Index:	dc.w Obj2C_Main-Obj2C_Index
		dc.w Obj2C_Turn-Obj2C_Index
; ===========================================================================

Obj2C_Main:				; XREF: Obj2C_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj2C,4(a0)
		move.w	#$2486,2(a0)
		ori.b	#4,1(a0)
		move.b	#$A,$20(a0)
		move.b	#4,$18(a0)
		move.b	#$10,$19(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; load object subtype number
		lsl.w	#6,d0		; multiply d0 by 64
		subq.w	#1,d0
		move.w	d0,$30(a0)	; set turn delay time
		move.w	d0,$32(a0)
		move.w	#-$40,$10(a0)	; move Jaws to the left
		btst	#0,$22(a0)	; is Jaws facing left?
		beq.s	Obj2C_Turn	; if yes, branch
		neg.w	$10(a0)		; move Jaws to the right

Obj2C_Turn:				; XREF: Obj2C_Index
		subq.w	#1,$30(a0)	; subtract 1 from turn delay time
		bpl.s	Obj2C_Animate	; if time remains, branch
		move.w	$32(a0),$30(a0)	; reset	turn delay time
		neg.w	$10(a0)		; change speed direction
		bchg	#0,$22(a0)	; change Jaws facing direction
		move.b	#1,$1D(a0)	; reset	animation

Obj2C_Animate:
		lea	(Ani_obj2C).l,a1
		bsr.w	AnimateSprite
		bsr.w	SpeedToPos
		bra.w	MarkObjGone
; ===========================================================================
Ani_obj2C:
	include "_anim\obj2C.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Jaws enemy (LZ)
; ---------------------------------------------------------------------------
Map_obj2C:
	include "_maps\obj2C.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2D - Burrobot enemy (LZ)
; ---------------------------------------------------------------------------

Obj2D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj2D_Index(pc,d0.w),d1
		jmp	Obj2D_Index(pc,d1.w)
; ===========================================================================
Obj2D_Index:	dc.w Obj2D_Main-Obj2D_Index
		dc.w Obj2D_Action-Obj2D_Index
; ===========================================================================

Obj2D_Main:				; XREF: Obj2D_Index
		addq.b	#2,$24(a0)
		move.b	#$13,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_obj2D,4(a0)
		move.w	#$4A6,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#5,$20(a0)
		move.b	#$C,$19(a0)
		addq.b	#6,$25(a0)	; run "Obj2D_ChkSonic" routine
		move.b	#2,$1C(a0)

Obj2D_Action:				; XREF: Obj2D_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj2D_Index2(pc,d0.w),d1
		jsr	Obj2D_Index2(pc,d1.w)
		lea	(Ani_obj2D).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj2D_Index2:	dc.w Obj2D_ChgDir-Obj2D_Index2
		dc.w Obj2D_Move-Obj2D_Index2
		dc.w Obj2D_Jump-Obj2D_Index2
		dc.w Obj2D_ChkSonic-Obj2D_Index2
; ===========================================================================

Obj2D_ChgDir:				; XREF: Obj2D_Index2
		subq.w	#1,$30(a0)
		bpl.s	locret_AD42
		addq.b	#2,$25(a0)
		move.w	#$FF,$30(a0)
		move.w	#$80,$10(a0)
		move.b	#1,$1C(a0)
		bchg	#0,$22(a0)	; change direction the Burrobot	is facing
		beq.s	locret_AD42
		neg.w	$10(a0)		; change direction the Burrobot	is moving

locret_AD42:
		rts
; ===========================================================================

Obj2D_Move:				; XREF: Obj2D_Index2
		subq.w	#1,$30(a0)
		bmi.s	loc_AD84
		bsr.w	SpeedToPos
		bchg	#0,$32(a0)
		bne.s	loc_AD78
		move.w	8(a0),d3
		addi.w	#$C,d3
		btst	#0,$22(a0)
		bne.s	loc_AD6A
		subi.w	#$18,d3

loc_AD6A:
		jsr	ObjHitFloor2
		cmpi.w	#$C,d1
		bge.s	loc_AD84
		rts
; ===========================================================================

loc_AD78:				; XREF: Obj2D_Move
		jsr	ObjHitFloor
		add.w	d1,$C(a0)
		rts
; ===========================================================================

loc_AD84:				; XREF: Obj2D_Move
		btst	#2,($FFFFFE0F).w
		beq.s	loc_ADA4
		subq.b	#2,$25(a0)
		move.w	#$3B,$30(a0)
		move.w	#0,$10(a0)
		move.b	#0,$1C(a0)
		rts
; ===========================================================================

loc_ADA4:
		addq.b	#2,$25(a0)
		move.w	#-$400,$12(a0)
		move.b	#2,$1C(a0)
		rts
; ===========================================================================

Obj2D_Jump:				; XREF: Obj2D_Index2
		bsr.w	SpeedToPos
		addi.w	#$18,$12(a0)
		bmi.s	locret_ADF0
		move.b	#3,$1C(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	locret_ADF0
		add.w	d1,$C(a0)
		move.w	#0,$12(a0)
		move.b	#1,$1C(a0)
		move.w	#$FF,$30(a0)
		subq.b	#2,$25(a0)
		bsr.w	Obj2D_ChkSonic2

locret_ADF0:
		rts
; ===========================================================================

Obj2D_ChkSonic:				; XREF: Obj2D_Index2
		move.w	#$60,d2
		bsr.w	Obj2D_ChkSonic2
		bcc.s	locret_AE20
		move.w	($FFFFD00C).w,d0
		sub.w	$C(a0),d0
		bcc.s	locret_AE20
		cmpi.w	#-$80,d0
		bcs.s	locret_AE20
		tst.w	($FFFFFE08).w
		bne.s	locret_AE20
		subq.b	#2,$25(a0)
		move.w	d1,$10(a0)
		move.w	#-$400,$12(a0)

locret_AE20:
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj2D_ChkSonic2:			; XREF: Obj2D_ChkSonic
		move.w	#$80,d1
		bset	#0,$22(a0)
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_AE40
		neg.w	d0
		neg.w	d1
		bclr	#0,$22(a0)

loc_AE40:
		cmp.w	d2,d0
		rts
; End of function Obj2D_ChkSonic2

; ===========================================================================
Ani_obj2D:
	include "_anim\obj2D.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Burrobot enemy (LZ)
; ---------------------------------------------------------------------------
Map_obj2D:
	include "_maps\obj2D.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2F - large moving platforms (MZ)
; ---------------------------------------------------------------------------

Obj2F:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj2F_Index(pc,d0.w),d1
		jmp	Obj2F_Index(pc,d1.w)
; ===========================================================================
Obj2F_Index:	dc.w Obj2F_Main-Obj2F_Index
		dc.w Obj2F_Action-Obj2F_Index

Obj2F_Data:	dc.w Obj2F_Data1-Obj2F_Data 	; collision angle data
		dc.b 0,	$40			; frame	number,	platform width
		dc.w Obj2F_Data3-Obj2F_Data
		dc.b 1,	$40
		dc.w Obj2F_Data2-Obj2F_Data
		dc.b 2,	$20
; ===========================================================================

Obj2F_Main:				; XREF: Obj2F_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj2F,4(a0)
		move.w	#$C000,2(a0)
		move.b	#4,1(a0)
		move.b	#5,$18(a0)
		move.w	$C(a0),$2C(a0)
		move.w	8(a0),$2A(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		lsr.w	#2,d0
		andi.w	#$1C,d0
		lea	Obj2F_Data(pc,d0.w),a1
		move.w	(a1)+,d0
		lea	Obj2F_Data(pc,d0.w),a2
		move.l	a2,$30(a0)
		move.b	(a1)+,$1A(a0)
		move.b	(a1),$19(a0)
		andi.b	#$F,$28(a0)
		move.b	#$40,$16(a0)
		bset	#4,1(a0)

Obj2F_Action:				; XREF: Obj2F_Index
		bsr.w	Obj2F_Types
		tst.b	$25(a0)
		beq.s	Obj2F_Solid
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		bsr.w	ExitPlatform
		btst	#3,$22(a1)
		bne.w	Obj2F_Slope
		clr.b	$25(a0)
		bra.s	Obj2F_Display
; ===========================================================================

Obj2F_Slope:				; XREF: Obj2F_Action
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		movea.l	$30(a0),a2
		move.w	8(a0),d2
		bsr.w	SlopeObject2
		bra.s	Obj2F_Display
; ===========================================================================

Obj2F_Solid:				; XREF: Obj2F_Action
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		move.w	#$20,d2
		cmpi.b	#2,$1A(a0)
		bne.s	loc_AF8E
		move.w	#$30,d2

loc_AF8E:
		movea.l	$30(a0),a2
		bsr.w	SolidObject2F

Obj2F_Display:				; XREF: Obj2F_Action
		bsr.w	DisplaySprite
		bra.w	Obj2F_ChkDel

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj2F_Types:				; XREF: Obj2F_Action
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Obj2F_TypeIndex(pc,d0.w),d1
		jmp	Obj2F_TypeIndex(pc,d1.w)
; End of function Obj2F_Types

; ===========================================================================
Obj2F_TypeIndex:dc.w Obj2F_Type00-Obj2F_TypeIndex
		dc.w Obj2F_Type01-Obj2F_TypeIndex
		dc.w Obj2F_Type02-Obj2F_TypeIndex
		dc.w Obj2F_Type03-Obj2F_TypeIndex
		dc.w Obj2F_Type04-Obj2F_TypeIndex
		dc.w Obj2F_Type05-Obj2F_TypeIndex
; ===========================================================================

Obj2F_Type00:				; XREF: Obj2F_TypeIndex
		rts			; type 00 platform doesn't move
; ===========================================================================

Obj2F_Type01:				; XREF: Obj2F_TypeIndex
		move.b	($FFFFFE60).w,d0
		move.w	#$20,d1
		bra.s	Obj2F_Move
; ===========================================================================

Obj2F_Type02:				; XREF: Obj2F_TypeIndex
		move.b	($FFFFFE64).w,d0
		move.w	#$30,d1
		bra.s	Obj2F_Move
; ===========================================================================

Obj2F_Type03:				; XREF: Obj2F_TypeIndex
		move.b	($FFFFFE68).w,d0
		move.w	#$40,d1
		bra.s	Obj2F_Move
; ===========================================================================

Obj2F_Type04:				; XREF: Obj2F_TypeIndex
		move.b	($FFFFFE6C).w,d0
		move.w	#$60,d1

Obj2F_Move:
		btst	#3,$28(a0)
		beq.s	loc_AFF2
		neg.w	d0
		add.w	d1,d0

loc_AFF2:
		move.w	$2C(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)	; update position on y-axis
		rts
; ===========================================================================

Obj2F_Type05:				; XREF: Obj2F_TypeIndex
		move.b	$34(a0),d0
		tst.b	$25(a0)
		bne.s	loc_B010
		subq.b	#2,d0
		bcc.s	loc_B01C
		moveq	#0,d0
		bra.s	loc_B01C
; ===========================================================================

loc_B010:
		addq.b	#4,d0
		cmpi.b	#$40,d0
		bcs.s	loc_B01C
		move.b	#$40,d0

loc_B01C:
		move.b	d0,$34(a0)
		jsr	(CalcSine).l
		lsr.w	#4,d0
		move.w	d0,d1
		add.w	$2C(a0),d0
		move.w	d0,$C(a0)
		cmpi.b	#$20,$34(a0)
		bne.s	loc_B07A
		tst.b	$35(a0)
		bne.s	loc_B07A
		move.b	#1,$35(a0)
		bsr.w	SingleObjLoad2
		bne.s	loc_B07A
		move.b	#$35,0(a1)	; load sitting flame object
		move.w	8(a0),8(a1)
		move.w	$2C(a0),$2C(a1)
		addq.w	#8,$2C(a1)
		subq.w	#3,$2C(a1)
		subi.w	#$40,8(a1)
		move.l	$30(a0),$30(a1)
		move.l	a0,$38(a1)
		movea.l	a0,a2
		bsr.s	sub_B09C

loc_B07A:
		moveq	#0,d2
		lea	$36(a0),a2
		move.b	(a2)+,d2
		subq.b	#1,d2
		bcs.s	locret_B09A

loc_B086:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.w	#-$3000,d0
		movea.w	d0,a1
		move.w	d1,$3C(a1)
		dbf	d2,loc_B086

locret_B09A:
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_B09C:
		lea	$36(a2),a2
		moveq	#0,d0
		move.b	(a2),d0
		addq.b	#1,(a2)
		lea	1(a2,d0.w),a2
		move.w	a1,d0
		subi.w	#-$3000,d0
		lsr.w	#6,d0
		andi.w	#$7F,d0
		move.b	d0,(a2)
		rts
; End of function sub_B09C

; ===========================================================================

Obj2F_ChkDel:				; XREF: Obj2F_Display
		tst.b	$35(a0)
		beq.s	loc_B0C6
		tst.b	1(a0)
		bpl.s	Obj2F_DelFlames

loc_B0C6:
		move.w	$2A(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================

Obj2F_DelFlames:			; XREF: Obj2F_ChkDel
		moveq	#0,d2

loc_B0E8:
		lea	$36(a0),a2
		move.b	(a2),d2
		clr.b	(a2)+
		subq.b	#1,d2
		bcs.s	locret_B116

loc_B0F4:
		moveq	#0,d0
		move.b	(a2),d0
		clr.b	(a2)+
		lsl.w	#6,d0
		addi.w	#-$3000,d0
		movea.w	d0,a1
		bsr.w	DeleteObject2
		dbf	d2,loc_B0F4
		move.b	#0,$35(a0)
		move.b	#0,$34(a0)

locret_B116:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Collision data for large moving platforms (MZ)
; ---------------------------------------------------------------------------
Obj2F_Data1:	incbin	misc\mz_pfm1.bin
		even
Obj2F_Data2:	incbin	misc\mz_pfm2.bin
		even
Obj2F_Data3:	incbin	misc\mz_pfm3.bin
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 35 - fireball that sits on the	floor (MZ)
; (appears when	you walk on sinking platforms)
; ---------------------------------------------------------------------------

Obj35:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj35_Index(pc,d0.w),d1
		jmp	Obj35_Index(pc,d1.w)
; ===========================================================================
Obj35_Index:	dc.w Obj35_Main-Obj35_Index
		dc.w loc_B238-Obj35_Index
		dc.w Obj35_Move-Obj35_Index
; ===========================================================================

Obj35_Main:				; XREF: Obj35_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj14,4(a0)
		move.w	#$345,2(a0)
		move.w	8(a0),$2A(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#$8B,$20(a0)
		move.b	#8,$19(a0)
		moveq	#sfx_Lava,d0
		jsr	(PlaySound_Special).l ;	play flame sound
		tst.b	$28(a0)
		beq.s	loc_B238
		addq.b	#2,$24(a0)
		bra.w	Obj35_Move
; ===========================================================================

loc_B238:				; XREF: Obj35_Index
		movea.l	$30(a0),a1
		move.w	8(a0),d1
		sub.w	$2A(a0),d1
		addi.w	#$C,d1
		move.w	d1,d0
		lsr.w	#1,d0
		move.b	(a1,d0.w),d0
		neg.w	d0
		add.w	$2C(a0),d0
		move.w	d0,d2
		add.w	$3C(a0),d0
		move.w	d0,$C(a0)
		cmpi.w	#$84,d1
		bcc.s	loc_B2B0
		addi.l	#$10000,8(a0)
		cmpi.w	#$80,d1
		bcc.s	loc_B2B0
		move.l	8(a0),d0
		addi.l	#$80000,d0
		andi.l	#$FFFFF,d0
		bne.s	loc_B2B0
		bsr.w	SingleObjLoad2
		bne.s	loc_B2B0
		move.b	#$35,0(a1)
		move.w	8(a0),8(a1)
		move.w	d2,$2C(a1)
		move.w	$3C(a0),$3C(a1)
		move.b	#1,$28(a1)
		movea.l	$38(a0),a2
		bsr.w	sub_B09C

loc_B2B0:
		bra.s	Obj35_Animate
; ===========================================================================

Obj35_Move:				; XREF: Obj35_Index
		move.w	$2C(a0),d0
		add.w	$3C(a0),d0
		move.w	d0,$C(a0)

Obj35_Animate:				; XREF: loc_B238
		lea	(Ani_obj35).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================
Ani_obj35:
	include "_anim\obj35.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - large moving platforms (MZ)
; ---------------------------------------------------------------------------
Map_obj2F:
	include "_maps\obj2F.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - lava balls (MZ, SLZ)
; ---------------------------------------------------------------------------
Map_obj14:
	include "_maps\obj14.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 30 - large green glassy blocks	(MZ)
; ---------------------------------------------------------------------------

Obj30:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj30_Index(pc,d0.w),d1
		jsr	Obj30_Index(pc,d1.w)
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj30_Delete
		bra.w	DisplaySprite
; ===========================================================================

Obj30_Delete:
		bra.w	DeleteObject
; ===========================================================================
Obj30_Index:	dc.w Obj30_Main-Obj30_Index
		dc.w Obj30_Block012-Obj30_Index
		dc.w Obj30_Reflect012-Obj30_Index
		dc.w Obj30_Block34-Obj30_Index
		dc.w Obj30_Reflect34-Obj30_Index

Obj30_Vars1:	dc.b 2,	0, 0	; routine num, y-axis dist from	origin,	frame num
		dc.b 4,	0, 1
Obj30_Vars2:	dc.b 6,	0, 2
		dc.b 8,	0, 1
; ===========================================================================

Obj30_Main:				; XREF: Obj30_Index
		lea	(Obj30_Vars1).l,a2
		moveq	#1,d1
		move.b	#$48,$16(a0)
		cmpi.b	#3,$28(a0)	; is object type 0/1/2 ?
		bcs.s	loc_B40C	; if yes, branch
		lea	(Obj30_Vars2).l,a2
		moveq	#1,d1
		move.b	#$38,$16(a0)

loc_B40C:
		movea.l	a0,a1
		bra.s	Obj30_Load	; load main object
; ===========================================================================

Obj30_Loop:
		bsr.w	SingleObjLoad2
		bne.s	loc_B480

Obj30_Load:				; XREF: Obj30_Main
		move.b	(a2)+,$24(a1)
		move.b	#$30,0(a1)
		move.w	8(a0),8(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	$C(a0),d0
		move.w	d0,$C(a1)
		move.l	#Map_obj30,4(a1)
		move.w	#$C38E,2(a1)
		move.b	#4,1(a1)
		move.w	$C(a1),$30(a1)
		move.b	$28(a0),$28(a1)
		move.b	#$20,$19(a1)
		move.b	#4,$18(a1)
		move.b	(a2)+,$1A(a1)
		move.l	a0,$3C(a1)
		dbf	d1,Obj30_Loop	; repeat once to load "reflection object"

		move.b	#$10,$19(a1)
		move.b	#3,$18(a1)
		addq.b	#8,$28(a1)
		andi.b	#$F,$28(a1)

loc_B480:
		move.w	#$90,$32(a0)
		bset	#4,1(a0)

Obj30_Block012:				; XREF: Obj30_Index
		bsr.w	Obj30_Types
		move.w	#$2B,d1
		move.w	#$48,d2
		move.w	#$49,d3
		move.w	8(a0),d4
		bra.w	SolidObject
; ===========================================================================

Obj30_Reflect012:			; XREF: Obj30_Index
		movea.l	$3C(a0),a1
		move.w	$32(a1),$32(a0)
		bra.w	Obj30_Types
; ===========================================================================

Obj30_Block34:				; XREF: Obj30_Index
		bsr.w	Obj30_Types
		move.w	#$2B,d1
		move.w	#$38,d2
		move.w	#$39,d3
		move.w	8(a0),d4
		bra.w	SolidObject
; ===========================================================================

Obj30_Reflect34:			; XREF: Obj30_Index
		movea.l	$3C(a0),a1
		move.w	$32(a1),$32(a0)
		move.w	$C(a1),$30(a0)
		bra.w	*+4

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj30_Types:				; XREF: Obj30_Block012; et al
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Obj30_TypeIndex(pc,d0.w),d1
		jmp	Obj30_TypeIndex(pc,d1.w)
; End of function Obj30_Types

; ===========================================================================
Obj30_TypeIndex:dc.w Obj30_Type00-Obj30_TypeIndex
		dc.w Obj30_Type01-Obj30_TypeIndex
		dc.w Obj30_Type02-Obj30_TypeIndex
		dc.w Obj30_Type03-Obj30_TypeIndex
		dc.w Obj30_Type04-Obj30_TypeIndex
; ===========================================================================

Obj30_Type00:				; XREF: Obj30_TypeIndex
		rts
; ===========================================================================

Obj30_Type01:				; XREF: Obj30_TypeIndex
		move.b	($FFFFFE70).w,d0
		move.w	#$40,d1
		bra.s	loc_B514
; ===========================================================================

Obj30_Type02:				; XREF: Obj30_TypeIndex
		move.b	($FFFFFE70).w,d0
		move.w	#$40,d1
		neg.w	d0
		add.w	d1,d0

loc_B514:				; XREF: Obj30_Type01
		btst	#3,$28(a0)
		beq.s	loc_B526
		neg.w	d0
		add.w	d1,d0
		lsr.b	#1,d0
		addi.w	#$20,d0

loc_B526:
		bra.w	loc_B5EE
; ===========================================================================

Obj30_Type03:				; XREF: Obj30_TypeIndex
		btst	#3,$28(a0)
		beq.s	loc_B53E
		move.b	($FFFFFE70).w,d0
		subi.w	#$10,d0
		bra.w	loc_B5EE
; ===========================================================================

loc_B53E:
		btst	#3,$22(a0)
		bne.s	loc_B54E
		bclr	#0,$34(a0)
		bra.s	loc_B582
; ===========================================================================

loc_B54E:
		tst.b	$34(a0)
		bne.s	loc_B582
		move.b	#1,$34(a0)
		bset	#0,$35(a0)
		beq.s	loc_B582
		bset	#7,$34(a0)
		move.w	#$10,$36(a0)
		move.b	#$A,$38(a0)
		cmpi.w	#$40,$32(a0)
		bne.s	loc_B582
		move.w	#$40,$36(a0)

loc_B582:
		tst.b	$34(a0)
		bpl.s	loc_B5AA
		tst.b	$38(a0)
		beq.s	loc_B594
		subq.b	#1,$38(a0)
		bne.s	loc_B5AA

loc_B594:
		tst.w	$32(a0)
		beq.s	loc_B5A4
		subq.w	#1,$32(a0)
		subq.w	#1,$36(a0)
		bne.s	loc_B5AA

loc_B5A4:
		bclr	#7,$34(a0)

loc_B5AA:
		move.w	$32(a0),d0
		bra.s	loc_B5EE
; ===========================================================================

Obj30_Type04:				; XREF: Obj30_TypeIndex
		btst	#3,$28(a0)
		beq.s	Obj30_ChkSwitch
		move.b	($FFFFFE70).w,d0
		subi.w	#$10,d0
		bra.s	loc_B5EE
; ===========================================================================

Obj30_ChkSwitch:			; XREF: Obj30_Type04
		tst.b	$34(a0)
		bne.s	loc_B5E0
		lea	($FFFFF7E0).w,a2
		moveq	#0,d0
		move.b	$28(a0),d0	; load object type number
		lsr.w	#4,d0		; read only the	first nybble
		tst.b	(a2,d0.w)	; has switch number d0 been pressed?
		beq.s	loc_B5EA	; if not, branch
		move.b	#1,$34(a0)

loc_B5E0:
		tst.w	$32(a0)
		beq.s	loc_B5EA
		subq.w	#2,$32(a0)

loc_B5EA:
		move.w	$32(a0),d0

loc_B5EE:
		move.w	$30(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - large green	glassy blocks (MZ)
; ---------------------------------------------------------------------------
Map_obj30:
	include "_maps\obj30.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 31 - stomping metal blocks on chains (MZ)
; ---------------------------------------------------------------------------

Obj31:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj31_Index(pc,d0.w),d1
		jmp	Obj31_Index(pc,d1.w)
; ===========================================================================
Obj31_Index:	dc.w Obj31_Main-Obj31_Index
		dc.w loc_B798-Obj31_Index
		dc.w loc_B7FE-Obj31_Index
		dc.w Obj31_Display2-Obj31_Index
		dc.w loc_B7E2-Obj31_Index

Obj31_SwchNums:	dc.b 0,	0		; switch number, obj number
		dc.b 1,	0

Obj31_Var:	dc.b 2,	0, 0		; XREF: ROM:0000B6E0o
		dc.b 4,	$1C, 1		; routine number, y-position, frame number
		dc.b 8,	$CC, 3
		dc.b 6,	$F0, 2

word_B6A4:	dc.w $7000, $A000
		dc.w $5000, $7800
		dc.w $3800, $5800
		dc.w $B800
; ===========================================================================

Obj31_Main:				; XREF: Obj31_Index
		moveq	#0,d0
		move.b	$28(a0),d0
		bpl.s	loc_B6CE
		andi.w	#$7F,d0
		add.w	d0,d0
		lea	Obj31_SwchNums(pc,d0.w),a2
		move.b	(a2)+,$3A(a0)
		move.b	(a2)+,d0
		move.b	d0,$28(a0)

loc_B6CE:
		andi.b	#$F,d0
		add.w	d0,d0
		move.w	word_B6A4(pc,d0.w),d2
		tst.w	d0
		bne.s	loc_B6E0
		move.w	d2,$32(a0)

loc_B6E0:
		lea	(Obj31_Var).l,a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj31_MakeStomper
; ===========================================================================

Obj31_Loop:
		bsr.w	SingleObjLoad2
		bne.w	Obj31_SetSize

Obj31_MakeStomper:			; XREF: Obj31_Main
		move.b	(a2)+,$24(a1)
		move.b	#$31,0(a1)
		move.w	8(a0),8(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	$C(a0),d0
		move.w	d0,$C(a1)
		move.l	#Map_obj31,4(a1)
		move.w	#$300,2(a1)
		move.b	#4,1(a1)
		move.w	$C(a1),$30(a1)
		move.b	$28(a0),$28(a1)
		move.b	#$10,$19(a1)
		move.w	d2,$34(a1)
		move.b	#4,$18(a1)
		move.b	(a2)+,$1A(a1)
		cmpi.b	#1,$1A(a1)
		bne.s	loc_B76A
		subq.w	#1,d1
		move.b	$28(a0),d0
		andi.w	#$F0,d0
		cmpi.w	#$20,d0
		beq.s	Obj31_MakeStomper
		move.b	#$38,$19(a1)
		move.b	#$90,$20(a1)
		addq.w	#1,d1

loc_B76A:
		move.l	a0,$3C(a1)
		dbf	d1,Obj31_Loop

		move.b	#3,$18(a1)

Obj31_SetSize:
		moveq	#0,d0
		move.b	$28(a0),d0
		lsr.w	#3,d0
		andi.b	#$E,d0
		lea	Obj31_Var2(pc,d0.w),a2
		move.b	(a2)+,$19(a0)
		move.b	(a2)+,$1A(a0)
		bra.s	loc_B798
; ===========================================================================
Obj31_Var2:	dc.b $38, 0		; width, frame number
		dc.b $30, 9
		dc.b $10, $A
; ===========================================================================

loc_B798:				; XREF: Obj31_Index
		bsr.w	Obj31_Types
		move.w	$C(a0),($FFFFF7A4).w
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		move.w	#$C,d2
		move.w	#$D,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		btst	#3,$22(a0)
		beq.s	Obj31_Display
		cmpi.b	#$10,$32(a0)
		bcc.s	Obj31_Display
		movea.l	a0,a2
		lea	($FFFFD000).w,a0
		jsr	KillSonic
		movea.l	a2,a0

Obj31_Display:
		bsr.w	DisplaySprite
		bra.w	Obj31_ChkDel
; ===========================================================================

loc_B7E2:				; XREF: Obj31_Index
		move.b	#$80,$16(a0)
		bset	#4,1(a0)
		movea.l	$3C(a0),a1
		move.b	$32(a1),d0
		lsr.b	#5,d0
		addq.b	#3,d0
		move.b	d0,$1A(a0)

loc_B7FE:				; XREF: Obj31_Index
		movea.l	$3C(a0),a1
		moveq	#0,d0
		move.b	$32(a1),d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)

Obj31_Display2:				; XREF: Obj31_Index
		bsr.w	DisplaySprite

Obj31_ChkDel:				; XREF: Obj31_Display
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================

Obj31_Types:				; XREF: loc_B798
		move.b	$28(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	Obj31_TypeIndex(pc,d0.w),d1
		jmp	Obj31_TypeIndex(pc,d1.w)
; ===========================================================================
Obj31_TypeIndex:dc.w Obj31_Type00-Obj31_TypeIndex
		dc.w Obj31_Type01-Obj31_TypeIndex
		dc.w Obj31_Type01-Obj31_TypeIndex
		dc.w Obj31_Type03-Obj31_TypeIndex
		dc.w Obj31_Type01-Obj31_TypeIndex
		dc.w Obj31_Type03-Obj31_TypeIndex
		dc.w Obj31_Type01-Obj31_TypeIndex
; ===========================================================================

Obj31_Type00:				; XREF: Obj31_TypeIndex
		lea	($FFFFF7E0).w,a2 ; load	switch statuses
		moveq	#0,d0
		move.b	$3A(a0),d0	; move number 0	or 1 to	d0
		tst.b	(a2,d0.w)	; has switch (d0) been pressed?
		beq.s	loc_B8A8	; if not, branch
		tst.w	($FFFFF7A4).w
		bpl.s	loc_B872
		cmpi.b	#$10,$32(a0)
		beq.s	loc_B8A0

loc_B872:
		tst.w	$32(a0)
		beq.s	loc_B8A0
		move.b	($FFFFFE0F).w,d0
		andi.b	#$F,d0
		bne.s	loc_B892
		tst.b	1(a0)
		bpl.s	loc_B892
		moveq	#sfx_Chain,d0
		jsr	(PlaySound_Special).l ;	play rising chain sound

loc_B892:
		subi.w	#$80,$32(a0)
		bcc.s	Obj31_Restart
		move.w	#0,$32(a0)

loc_B8A0:
		move.w	#0,$12(a0)
		bra.s	Obj31_Restart
; ===========================================================================

loc_B8A8:				; XREF: Obj31_Type00
		move.w	$34(a0),d1
		cmp.w	$32(a0),d1
		beq.s	Obj31_Restart
		move.w	$12(a0),d0
		addi.w	#$70,$12(a0)	; make object fall
		add.w	d0,$32(a0)
		cmp.w	$32(a0),d1
		bhi.s	Obj31_Restart
		move.w	d1,$32(a0)
		move.w	#0,$12(a0)	; stop object falling
		tst.b	1(a0)
		bpl.s	Obj31_Restart
		moveq	#sfx_Stomp,d0
		jsr	(PlaySound_Special).l ;	play stomping sound

Obj31_Restart:
		moveq	#0,d0
		move.b	$32(a0),d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		rts
; ===========================================================================

Obj31_Type01:				; XREF: Obj31_TypeIndex
		tst.w	$36(a0)
		beq.s	loc_B938
		tst.w	$38(a0)
		beq.s	loc_B902
		subq.w	#1,$38(a0)
		bra.s	loc_B97C
; ===========================================================================

loc_B902:
		move.b	($FFFFFE0F).w,d0
		andi.b	#$F,d0
		bne.s	loc_B91C
		tst.b	1(a0)
		bpl.s	loc_B91C
		moveq	#sfx_Chain,d0
		jsr	(PlaySound_Special).l ;	play rising chain sound

loc_B91C:
		subi.w	#$80,$32(a0)
		bcc.s	loc_B97C
		move.w	#0,$32(a0)
		move.w	#0,$12(a0)
		move.w	#0,$36(a0)
		bra.s	loc_B97C
; ===========================================================================

loc_B938:				; XREF: Obj31_Type01
		move.w	$34(a0),d1
		cmp.w	$32(a0),d1
		beq.s	loc_B97C
		move.w	$12(a0),d0
		addi.w	#$70,$12(a0)	; make object fall
		add.w	d0,$32(a0)
		cmp.w	$32(a0),d1
		bhi.s	loc_B97C
		move.w	d1,$32(a0)
		move.w	#0,$12(a0)	; stop object falling
		move.w	#1,$36(a0)
		move.w	#$3C,$38(a0)
		tst.b	1(a0)
		bpl.s	loc_B97C
		moveq	#sfx_Stomp,d0
		jsr	(PlaySound_Special).l ;	play stomping sound

loc_B97C:
		bra.w	Obj31_Restart
; ===========================================================================

Obj31_Type03:				; XREF: Obj31_TypeIndex
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_B98C
		neg.w	d0

loc_B98C:
		cmpi.w	#$90,d0
		bcc.s	loc_B996
		addq.b	#1,$28(a0)

loc_B996:
		bra.w	Obj31_Restart
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 45 - spiked metal block from beta version (MZ)
; ---------------------------------------------------------------------------

Obj45:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj45_Index(pc,d0.w),d1
		jmp	Obj45_Index(pc,d1.w)
; ===========================================================================
Obj45_Index:	dc.w Obj45_Main-Obj45_Index
		dc.w Obj45_Solid-Obj45_Index
		dc.w loc_BA8E-Obj45_Index
		dc.w Obj45_Display-Obj45_Index
		dc.w loc_BA7A-Obj45_Index

Obj45_Var:	dc.b	2,   4,	  0	; routine number, x-position, frame number
		dc.b	4, $E4,	  1
		dc.b	8, $34,	  3
		dc.b	6, $28,	  2

word_B9BE:	dc.w $3800
		dc.w -$6000
		dc.w $5000
; ===========================================================================

Obj45_Main:				; XREF: Obj45_Index
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	word_B9BE(pc,d0.w),d2
		lea	(Obj45_Var).l,a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj45_Load
; ===========================================================================

Obj45_Loop:
		bsr.w	SingleObjLoad2
		bne.s	loc_BA52

Obj45_Load:				; XREF: Obj45_Main
		move.b	(a2)+,$24(a1)
		move.b	#$45,0(a1)
		move.w	$C(a0),$C(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	8(a0),d0
		move.w	d0,8(a1)
		move.l	#Map_obj45,4(a1)
		move.w	#$300,2(a1)
		move.b	#4,1(a1)
		move.w	8(a1),$30(a1)
		move.w	8(a0),$3A(a1)
		move.b	$28(a0),$28(a1)
		move.b	#$20,$19(a1)
		move.w	d2,$34(a1)
		move.b	#4,$18(a1)
		cmpi.b	#1,(a2)
		bne.s	loc_BA40
		move.b	#$91,$20(a1)

loc_BA40:
		move.b	(a2)+,$1A(a1)
		move.l	a0,$3C(a1)
		dbf	d1,Obj45_Loop	; repeat 3 times

		move.b	#3,$18(a1)

loc_BA52:
		move.b	#$10,$19(a0)

Obj45_Solid:				; XREF: Obj45_Index
		move.w	8(a0),-(sp)
		bsr.w	Obj45_Move
		move.w	#$17,d1
		move.w	#$20,d2
		move.w	#$20,d3
		move.w	(sp)+,d4
		bsr.w	SolidObject
		bsr.w	DisplaySprite
		bra.w	Obj45_ChkDel
; ===========================================================================

loc_BA7A:				; XREF: Obj45_Index
		movea.l	$3C(a0),a1
		move.b	$32(a1),d0
		addi.b	#$10,d0
		lsr.b	#5,d0
		addq.b	#3,d0
		move.b	d0,$1A(a0)

loc_BA8E:				; XREF: Obj45_Index
		movea.l	$3C(a0),a1
		moveq	#0,d0
		move.b	$32(a1),d0
		neg.w	d0
		add.w	$30(a0),d0
		move.w	d0,8(a0)

Obj45_Display:				; XREF: Obj45_Index
		bsr.w	DisplaySprite

Obj45_ChkDel:				; XREF: Obj45_Solid
		move.w	$3A(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj45_Move:				; XREF: Obj45_Solid
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	off_BAD6(pc,d0.w),d1
		jmp	off_BAD6(pc,d1.w)
; End of function Obj45_Move

; ===========================================================================
off_BAD6:	dc.w loc_BADA-off_BAD6
		dc.w loc_BADA-off_BAD6
; ===========================================================================

loc_BADA:				; XREF: off_BAD6
		tst.w	$36(a0)
		beq.s	loc_BB08
		tst.w	$38(a0)
		beq.s	loc_BAEC
		subq.w	#1,$38(a0)
		bra.s	loc_BB3C
; ===========================================================================

loc_BAEC:
		subi.w	#$80,$32(a0)
		bcc.s	loc_BB3C
		move.w	#0,$32(a0)
		move.w	#0,$10(a0)
		move.w	#0,$36(a0)
		bra.s	loc_BB3C
; ===========================================================================

loc_BB08:				; XREF: loc_BADA
		move.w	$34(a0),d1
		cmp.w	$32(a0),d1
		beq.s	loc_BB3C
		move.w	$10(a0),d0
		addi.w	#$70,$10(a0)
		add.w	d0,$32(a0)
		cmp.w	$32(a0),d1
		bhi.s	loc_BB3C
		move.w	d1,$32(a0)
		move.w	#0,$10(a0)
		move.w	#1,$36(a0)
		move.w	#$3C,$38(a0)

loc_BB3C:
		moveq	#0,d0
		move.b	$32(a0),d0
		neg.w	d0
		add.w	$30(a0),d0
		move.w	d0,8(a0)
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - metal stomping blocks on chains (MZ)
; ---------------------------------------------------------------------------
Map_obj31:
	include "_maps\obj31.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - spiked metal block from beta version (MZ)
; ---------------------------------------------------------------------------
Map_obj45:
	include "_maps\obj45.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 32 - switches (MZ, SYZ, LZ, SBZ)
; ---------------------------------------------------------------------------

Obj32:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj32_Index(pc,d0.w),d1
		jmp	Obj32_Index(pc,d1.w)
; ===========================================================================
Obj32_Index:	dc.w Obj32_Main-Obj32_Index
		dc.w Obj32_Pressed-Obj32_Index
; ===========================================================================

Obj32_Main:				; XREF: Obj32_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj32,4(a0)
		move.w	#$4513,2(a0)	; MZ specific code
		cmpi.b	#2,($FFFFFE10).w
		beq.s	loc_BD60
		move.w	#$513,2(a0)	; SYZ, LZ and SBZ specific code

loc_BD60:
		move.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#4,$18(a0)
		addq.w	#3,$C(a0)

Obj32_Pressed:				; XREF: Obj32_Index
		tst.b	1(a0)
		bpl.s	Obj32_Display
		move.w	#$1B,d1
		move.w	#5,d2
		move.w	#5,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		bclr	#0,$1A(a0)	; use "unpressed" frame
		move.b	$28(a0),d0
		andi.w	#$F,d0
		lea	($FFFFF7E0).w,a3
		lea	(a3,d0.w),a3
		moveq	#0,d3
		btst	#6,$28(a0)
		beq.s	loc_BDB2
		moveq	#7,d3

loc_BDB2:
		tst.b	$28(a0)
		bpl.s	loc_BDBE
		bsr.w	Obj32_MZBlock
		bne.s	loc_BDC8

loc_BDBE:
		tst.b	$25(a0)
		bne.s	loc_BDC8
		bclr	d3,(a3)
		bra.s	loc_BDDE
; ===========================================================================

loc_BDC8:
		tst.b	(a3)
		bne.s	loc_BDD6
		moveq	#sfx_Switch,d0
		jsr	(PlaySound_Special).l ;	play switch sound

loc_BDD6:
		bset	d3,(a3)
		bset	#0,$1A(a0)	; use "pressed"	frame

loc_BDDE:
		btst	#5,$28(a0)
		beq.s	Obj32_Display
		subq.b	#1,$1E(a0)
		bpl.s	Obj32_Display
		move.b	#7,$1E(a0)
		bchg	#1,$1A(a0)

Obj32_Display:
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj32_Delete
		rts
; ===========================================================================

Obj32_Delete:
		bsr.w	DeleteObject
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj32_MZBlock:				; XREF: Obj32_Pressed
		move.w	d3,-(sp)
		move.w	8(a0),d2
		move.w	$C(a0),d3
		subi.w	#$10,d2
		subq.w	#8,d3
		move.w	#$20,d4
		move.w	#$10,d5
		lea	($FFFFD800).w,a1 ; begin checking object RAM
		move.w	#$5F,d6

Obj32_MZLoop:
		tst.b	1(a1)
		bpl.s	loc_BE4E
		cmpi.b	#$33,(a1)	; is the object	a green	MZ block?
		beq.s	loc_BE5E	; if yes, branch

loc_BE4E:
		lea	$40(a1),a1	; check	next object
		dbf	d6,Obj32_MZLoop	; repeat $5F times

		move.w	(sp)+,d3
		moveq	#0,d0

locret_BE5A:
		rts
; ===========================================================================
Obj32_MZData:	dc.b $10, $10
; ===========================================================================

loc_BE5E:				; XREF: Obj32_MZBlock
		moveq	#1,d0
		andi.w	#$3F,d0
		add.w	d0,d0
		lea	Obj32_MZData-2(pc,d0.w),a2
		move.b	(a2)+,d1
		ext.w	d1
		move.w	8(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	loc_BE80
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	loc_BE84
		bra.s	loc_BE4E
; ===========================================================================

loc_BE80:
		cmp.w	d4,d0
		bhi.s	loc_BE4E

loc_BE84:
		move.b	(a2)+,d1
		ext.w	d1
		move.w	$C(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	loc_BE9A
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	loc_BE9E
		bra.s	loc_BE4E
; ===========================================================================

loc_BE9A:
		cmp.w	d5,d0
		bhi.s	loc_BE4E

loc_BE9E:
		move.w	(sp)+,d3
		moveq	#1,d0
		rts
; End of function Obj32_MZBlock

; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - switches (MZ, SYZ, LZ, SBZ)
; ---------------------------------------------------------------------------
Map_obj32:
	include "_maps\obj32.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 33 - pushable blocks (MZ, LZ)
; ---------------------------------------------------------------------------

Obj33:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj33_Index(pc,d0.w),d1
		jmp	Obj33_Index(pc,d1.w)
; ===========================================================================
Obj33_Index:	dc.w Obj33_Main-Obj33_Index
		dc.w loc_BF6E-Obj33_Index
		dc.w loc_C02C-Obj33_Index

Obj33_Var:	dc.b $10, 0	; object width,	frame number
		dc.b $40, 1
; ===========================================================================

Obj33_Main:				; XREF: Obj33_Index
		addq.b	#2,$24(a0)
		move.b	#$F,$16(a0)
		move.b	#$F,$17(a0)
		move.l	#Map_obj33,4(a0)
		move.w	#$42B8,2(a0)	; MZ specific code
		cmpi.b	#1,($FFFFFE10).w
		bne.s	loc_BF16
		move.w	#$43DE,2(a0)	; LZ specific code

loc_BF16:
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.w	8(a0),$34(a0)
		move.w	$C(a0),$36(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		andi.w	#$E,d0
		lea	Obj33_Var(pc,d0.w),a2
		move.b	(a2)+,$19(a0)
		move.b	(a2)+,$1A(a0)
		tst.b	$28(a0)
		beq.s	Obj33_ChkGone
		move.w	#$C2B8,2(a0)

Obj33_ChkGone:
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_BF6E
		bclr	#7,2(a2,d0.w)
		bset	#0,2(a2,d0.w)
		bne.w	DeleteObject

loc_BF6E:				; XREF: Obj33_Index
		tst.b	$32(a0)
		bne.w	loc_C046
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	8(a0),d4
		bsr.w	loc_C186
		cmpi.w	#$200,($FFFFFE10).w ; is the level MZ act 1?
		bne.s	loc_BFC6	; if not, branch
		bclr	#7,$28(a0)
		move.w	8(a0),d0
		cmpi.w	#$A20,d0
		bcs.s	loc_BFC6
		cmpi.w	#$AA1,d0
		bcc.s	loc_BFC6
		move.w	($FFFFF7A4).w,d0
		subi.w	#$1C,d0
		move.w	d0,$C(a0)
		bset	#7,($FFFFF7A4).w
		bset	#7,$28(a0)

loc_BFC6:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	loc_BFE6
		bra.w	DisplaySprite
; ===========================================================================

loc_BFE6:
		move.w	$34(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	loc_C016
		move.w	$34(a0),8(a0)
		move.w	$36(a0),$C(a0)
		move.b	#4,$24(a0)
		bra.s	loc_C02C
; ===========================================================================

loc_C016:
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_C028
		bclr	#0,2(a2,d0.w)

loc_C028:
		bra.w	DeleteObject
; ===========================================================================

loc_C02C:				; XREF: Obj33_Index
		bsr.w	ChkObjOnScreen2
		beq.s	locret_C044
		move.b	#2,$24(a0)
		clr.b	$32(a0)
		clr.w	$10(a0)
		clr.w	$12(a0)

locret_C044:
		rts
; ===========================================================================

loc_C046:				; XREF: loc_BF6E
		move.w	8(a0),-(sp)
		cmpi.b	#4,$25(a0)
		bcc.s	loc_C056
		bsr.w	SpeedToPos

loc_C056:
		btst	#1,$22(a0)
		beq.s	loc_C0A0
		addi.w	#$18,$12(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.w	loc_C09E
		add.w	d1,$C(a0)
		clr.w	$12(a0)
		bclr	#1,$22(a0)
		move.w	(a1),d0
		andi.w	#$3FF,d0
		cmpi.w	#$16A,d0
		bcs.s	loc_C09E
		move.w	$30(a0),d0
		asr.w	#3,d0
		move.w	d0,$10(a0)
		move.b	#1,$32(a0)
		clr.w	$E(a0)

loc_C09E:
		bra.s	loc_C0E6
; ===========================================================================

loc_C0A0:
		tst.w	$10(a0)
		beq.w	loc_C0D6
		bmi.s	loc_C0BC
		moveq	#0,d3
		move.b	$19(a0),d3
		jsr	ObjHitWallRight
		tst.w	d1		; has block touched a wall?
		bmi.s	Obj33_StopPush	; if yes, branch
		bra.s	loc_C0E6
; ===========================================================================

loc_C0BC:
		moveq	#0,d3
		move.b	$19(a0),d3
		not.w	d3
		jsr	ObjHitWallLeft
		tst.w	d1		; has block touched a wall?
		bmi.s	Obj33_StopPush	; if yes, branch
		bra.s	loc_C0E6
; ===========================================================================

Obj33_StopPush:
		clr.w	$10(a0)		; stop block moving
		bra.s	loc_C0E6
; ===========================================================================

loc_C0D6:
		addi.l	#$2001,$C(a0)
		cmpi.b	#-$60,$F(a0)
		bcc.s	loc_C104

loc_C0E6:
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	(sp)+,d4
		bsr.w	loc_C186
		bsr.s	Obj33_ChkLava
		bra.w	loc_BFC6
; ===========================================================================

loc_C104:
		move.w	(sp)+,d4
		lea	($FFFFD000).w,a1
		bclr	#3,$22(a1)
		bclr	#3,$22(a0)
		bra.w	loc_BFE6
; ===========================================================================

Obj33_ChkLava:
		cmpi.w	#$201,($FFFFFE10).w ; is the level MZ act 2?
		bne.s	Obj33_ChkLava2	; if not, branch
		move.w	#-$20,d2
		cmpi.w	#$DD0,8(a0)
		beq.s	Obj33_LoadLava
		cmpi.w	#$CC0,8(a0)
		beq.s	Obj33_LoadLava
		cmpi.w	#$BA0,8(a0)
		beq.s	Obj33_LoadLava
		rts
; ===========================================================================

Obj33_ChkLava2:
		cmpi.w	#$202,($FFFFFE10).w ; is the level MZ act 3?
		bne.s	Obj33_NoLava	; if not, branch
		move.w	#$20,d2
		cmpi.w	#$560,8(a0)
		beq.s	Obj33_LoadLava
		cmpi.w	#$5C0,8(a0)
		beq.s	Obj33_LoadLava

Obj33_NoLava:
		rts
; ===========================================================================

Obj33_LoadLava:
		bsr.w	SingleObjLoad
		bne.s	locret_C184
		move.b	#$4C,0(a1)	; load lava geyser object
		move.w	8(a0),8(a1)
		add.w	d2,8(a1)
		move.w	$C(a0),$C(a1)
		addi.w	#$10,$C(a1)
		move.l	a0,$3C(a1)

locret_C184:
		rts
; ===========================================================================

loc_C186:				; XREF: loc_BF6E
		move.b	$25(a0),d0
		beq.w	loc_C218
		subq.b	#2,d0
		bne.s	loc_C1AA
		bsr.w	ExitPlatform
		btst	#3,$22(a1)
		bne.s	loc_C1A4
		clr.b	$25(a0)
		rts
; ===========================================================================

loc_C1A4:
		move.w	d4,d2
		bra.w	MvSonicOnPtfm
; ===========================================================================

loc_C1AA:
		subq.b	#2,d0
		bne.s	loc_C1F2
		bsr.w	SpeedToPos
		addi.w	#$18,$12(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.w	locret_C1F0
		add.w	d1,$C(a0)
		clr.w	$12(a0)
		clr.b	$25(a0)
		move.w	(a1),d0
		andi.w	#$3FF,d0
		cmpi.w	#$16A,d0
		bcs.s	locret_C1F0
		move.w	$30(a0),d0
		asr.w	#3,d0
		move.w	d0,$10(a0)
		move.b	#1,$32(a0)
		clr.w	$E(a0)

locret_C1F0:
		rts
; ===========================================================================

loc_C1F2:
		bsr.w	SpeedToPos
		move.w	8(a0),d0
		andi.w	#$C,d0
		bne.w	locret_C2E4
		andi.w	#-$10,8(a0)
		move.w	$10(a0),$30(a0)
		clr.w	$10(a0)
		subq.b	#2,$25(a0)
		rts
; ===========================================================================

loc_C218:
		bsr.w	loc_FAC8
		tst.w	d4
		beq.w	locret_C2E4
		bmi.w	locret_C2E4
		tst.b	$32(a0)
		beq.s	loc_C230
		bra.w	locret_C2E4
; ===========================================================================

loc_C230:
		tst.w	d0
		beq.w	locret_C2E4
		bmi.s	loc_C268
		btst	#0,$22(a1)
		bne.w	locret_C2E4
		move.w	d0,-(sp)
		moveq	#0,d3
		move.b	$19(a0),d3
		jsr	ObjHitWallRight
		move.w	(sp)+,d0
		tst.w	d1
		bmi.w	locret_C2E4
		addi.l	#$10000,8(a0)
		moveq	#1,d0
		move.w	#$40,d1
		bra.s	loc_C294
; ===========================================================================

loc_C268:
		btst	#0,$22(a1)
		beq.s	locret_C2E4
		move.w	d0,-(sp)
		moveq	#0,d3
		move.b	$19(a0),d3
		not.w	d3
		jsr	ObjHitWallLeft
		move.w	(sp)+,d0
		tst.w	d1
		bmi.s	locret_C2E4
		subi.l	#$10000,8(a0)
		moveq	#-1,d0
		move.w	#-$40,d1

loc_C294:
		lea	($FFFFD000).w,a1
		add.w	d0,8(a1)
		move.w	d1,$14(a1)
		move.w	#0,$10(a1)
		move.w	d0,-(sp)
		moveq	#sfx_PushBlock,d0
		jsr	(PlaySound_Special).l ;	play pushing sound
		move.w	(sp)+,d0
		tst.b	$28(a0)
		bmi.s	locret_C2E4
		move.w	d0,-(sp)
		jsr	ObjHitFloor
		move.w	(sp)+,d0
		cmpi.w	#4,d1
		ble.s	loc_C2E0
		move.w	#$400,$10(a0)
		tst.w	d0
		bpl.s	loc_C2D8
		neg.w	$10(a0)

loc_C2D8:
		move.b	#6,$25(a0)
		bra.s	locret_C2E4
; ===========================================================================

loc_C2E0:
		add.w	d1,$C(a0)

locret_C2E4:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - pushable blocks (MZ, LZ)
; ---------------------------------------------------------------------------
Map_obj33:
	include "_maps\obj33.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 34 - zone title cards
; ---------------------------------------------------------------------------

Obj34:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj34_Index(pc,d0.w),d1
		jmp	Obj34_Index(pc,d1.w)
; ===========================================================================
Obj34_Index:	dc.w Obj34_CheckSBZ3-Obj34_Index
		dc.w Obj34_ChkPos-Obj34_Index
		dc.w Obj34_Wait-Obj34_Index
		dc.w Obj34_Wait-Obj34_Index
; ===========================================================================

Obj34_CheckSBZ3:			; XREF: Obj34_Index
		movea.l	a0,a1
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		cmpi.w	#$103,($FFFFFE10).w ; check if level is	SBZ 3
		bne.s	Obj34_CheckFZ
		moveq	#5,d0		; load title card number 5 (SBZ)

Obj34_CheckFZ:
		move.w	d0,d2
		cmpi.w	#$502,($FFFFFE10).w ; check if level is	FZ
		bne.s	Obj34_LoadConfig
		moveq	#6,d0		; load title card number 6 (FZ)
		moveq	#$B,d2		; use "FINAL" mappings

Obj34_LoadConfig:
		lea	(Obj34_ConData).l,a3
		lsl.w	#4,d0
		adda.w	d0,a3
		lea	(Obj34_ItemData).l,a2
		moveq	#3,d1

Obj34_Loop:
		move.b	#$34,0(a1)
		move.w	(a3),8(a1)	; load start x-position
		move.w	(a3)+,$32(a1)	; load finish x-position (same as start)
		move.w	(a3)+,$30(a1)	; load main x-position
		move.w	(a2)+,$A(a1)
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,d0
		bne.s	Obj34_ActNumber
		move.b	d2,d0

Obj34_ActNumber:
		cmpi.b	#7,d0
		bne.s	Obj34_MakeSprite
		add.b	($FFFFFE11).w,d0
		cmpi.b	#3,($FFFFFE11).w
		bne.s	Obj34_MakeSprite
		subq.b	#1,d0

Obj34_MakeSprite:
		move.b	d0,$1A(a1)	; display frame	number d0
		move.l	#Map_obj34,4(a1)
		move.w	#$8580,2(a1)
		move.b	#$78,$19(a1)
		move.b	#0,1(a1)
		move.b	#0,$18(a1)
		move.w	#60,$1E(a1)	; set time delay to 1 second
		lea	$40(a1),a1	; next object
		dbf	d1,Obj34_Loop	; repeat sequence another 3 times

Obj34_ChkPos:				; XREF: Obj34_Index
		moveq	#$10,d1		; set horizontal speed
		move.w	$30(a0),d0
		cmp.w	8(a0),d0	; has item reached the target position?
		beq.s	loc_C3C8	; if yes, branch
		bge.s	Obj34_Move
		neg.w	d1

Obj34_Move:
		add.w	d1,8(a0)	; change item's position

loc_C3C8:
		move.w	8(a0),d0
		bmi.s	locret_C3D8
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_C3D8	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C3D8:
		rts
; ===========================================================================

Obj34_Wait:				; XREF: Obj34_Index
		tst.w	$1E(a0)		; is time remaining zero?
		beq.s	Obj34_ChkPos2	; if yes, branch
		subq.w	#1,$1E(a0)	; subtract 1 from time
		bra.w	DisplaySprite
; ===========================================================================

Obj34_ChkPos2:				; XREF: Obj34_Wait
		tst.b	1(a0)
		bpl.s	Obj34_ChangeArt
		moveq	#$20,d1
		move.w	$32(a0),d0
		cmp.w	8(a0),d0	; has item reached the finish position?
		beq.s	Obj34_ChangeArt	; if yes, branch
		bge.s	Obj34_Move2
		neg.w	d1

Obj34_Move2:
		add.w	d1,8(a0)	; change item's position
		move.w	8(a0),d0
		bmi.s	locret_C412
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_C412	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C412:
		rts
; ===========================================================================

Obj34_ChangeArt:			; XREF: Obj34_ChkPos2
		cmpi.b	#4,$24(a0)
		bne.s	Obj34_Delete
		moveq	#2,d0
		jsr	(LoadPLC).l	; load explosion patterns
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		addi.w	#$15,d0
		jsr	(LoadPLC).l	; load animal patterns

Obj34_Delete:
		bra.w	DeleteObject
; ===========================================================================
Obj34_ItemData:	dc.w $D0	; y-axis position
		dc.b 2,	0	; routine number, frame	number (changes)
		dc.w $E4
		dc.b 2,	6
		dc.w $EA
		dc.b 2,	7
		dc.w $E0
		dc.b 2,	$A
; ---------------------------------------------------------------------------
; Title	card configuration data
; Format:
; 4 bytes per item (YYYY XXXX)
; 4 items per level (GREEN HILL, ZONE, ACT X, oval)
; ---------------------------------------------------------------------------
Obj34_ConData:	dc.w 0,	$120, $FEFC, $13C, $414, $154, $214, $154 ; GHZ
		dc.w 0,	$120, $FEF4, $134, $40C, $14C, $20C, $14C ; LZ
		dc.w 0,	$120, $FEE0, $120, $3F8, $138, $1F8, $138 ; MZ
		dc.w 0,	$120, $FEFC, $13C, $414, $154, $214, $154 ; SLZ
		dc.w 0,	$120, $FF04, $144, $41C, $15C, $21C, $15C ; SYZ
		dc.w 0,	$120, $FF04, $144, $41C, $15C, $21C, $15C ; SBZ
		dc.w 0,	$120, $FEE4, $124, $3EC, $3EC, $1EC, $12C ; FZ
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 39 - "GAME OVER" and "TIME OVER"
; ---------------------------------------------------------------------------

Obj39:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj39_Index(pc,d0.w),d1
		jmp	Obj39_Index(pc,d1.w)
; ===========================================================================
Obj39_Index:	dc.w Obj39_ChkPLC-Obj39_Index
		dc.w loc_C50C-Obj39_Index
		dc.w Obj39_Wait-Obj39_Index
; ===========================================================================

Obj39_ChkPLC:				; XREF: Obj39_Index
		tst.l	($FFFFF680).w	; are the pattern load cues empty?
		beq.s	Obj39_Main	; if yes, branch
		rts
; ===========================================================================

Obj39_Main:
		addq.b	#2,$24(a0)
		move.w	#$50,8(a0)	; set x-position
		btst	#0,$1A(a0)	; is the object	"OVER"?
		beq.s	loc_C4EC	; if not, branch
		move.w	#$1F0,8(a0)	; set x-position for "OVER"

loc_C4EC:
		move.w	#$F0,$A(a0)
		move.l	#Map_obj39,4(a0)
		move.w	#$855E,2(a0)
		move.b	#0,1(a0)
		move.b	#0,$18(a0)

loc_C50C:				; XREF: Obj39_Index
		moveq	#$10,d1		; set horizontal speed
		cmpi.w	#$120,8(a0)	; has item reached its target position?
		beq.s	Obj39_SetWait	; if yes, branch
		bcs.s	Obj39_Move
		neg.w	d1

Obj39_Move:
		add.w	d1,8(a0)	; change item's position
		bra.w	DisplaySprite
; ===========================================================================

Obj39_SetWait:				; XREF: Obj39_Main
		move.w	#720,$1E(a0)	; set time delay to 12 seconds
		addq.b	#2,$24(a0)
		rts
; ===========================================================================

Obj39_Wait:				; XREF: Obj39_Index
		move.b	($FFFFF605).w,d0
		andi.b	#$70,d0		; is button A, B or C pressed?
		bne.s	Obj39_ChgMode	; if yes, branch
		btst	#0,$1A(a0)
		bne.s	Obj39_Display
		tst.w	$1E(a0)		; has time delay reached zero?
		beq.s	Obj39_ChgMode	; if yes, branch
		subq.w	#1,$1E(a0)	; subtract 1 from time delay
		bra.w	DisplaySprite
; ===========================================================================

Obj39_ChgMode:				; XREF: Obj39_Wait
		tst.b	($FFFFFE1A).w	; is time over flag set?
		bne.s	Obj39_ResetLvl	; if yes, branch
		move.b	#$14,($FFFFF600).w ; set mode to $14 (continue screen)
		tst.b	($FFFFFE18).w	; do you have any continues?
		bne.s	Obj39_Display	; if yes, branch
		move.b	#0,($FFFFF600).w ; set mode to 0 (Sega screen)
		moveq	#Mus_Reset,d0
		jsr	PlaySound_Special2	 ; fade reset music
		bra.s	Obj39_Display
; ===========================================================================

Obj39_ResetLvl:				; XREF: Obj39_ChgMode
		move.w	#1,($FFFFFE02).w ; restart level

Obj39_Display:				; XREF: Obj39_ChgMode
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3A - "SONIC GOT THROUGH" title	card
; ---------------------------------------------------------------------------

Obj3A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj3A_Index(pc,d0.w),d1
		jmp	Obj3A_Index(pc,d1.w)
; ===========================================================================
Obj3A_Index:	dc.w Obj3A_ChkPLC-Obj3A_Index
		dc.w Obj3A_ChkPos-Obj3A_Index
		dc.w Obj3A_Wait-Obj3A_Index
		dc.w Obj3A_TimeBonus-Obj3A_Index
		dc.w Obj3A_Wait-Obj3A_Index
		dc.w Obj3A_NextLevel-Obj3A_Index
		dc.w Obj3A_Wait-Obj3A_Index
		dc.w Obj3A_ChkPos2-Obj3A_Index
		dc.w loc_C766-Obj3A_Index
; ===========================================================================

Obj3A_ChkPLC:				; XREF: Obj3A_Index
		tst.l	($FFFFF680).w	; are the pattern load cues empty?
		beq.s	Obj3A_Main	; if yes, branch
		rts
; ===========================================================================

Obj3A_Main:
		movea.l	a0,a1
		lea	(Obj3A_Config).l,a2
		moveq	#6,d1

Obj3A_Loop:
		move.b	#$3A,0(a1)
		move.w	(a2),8(a1)	; load start x-position
		move.w	(a2)+,$32(a1)	; load finish x-position (same as start)
		move.w	(a2)+,$30(a1)	; load main x-position
		move.w	(a2)+,$A(a1)	; load y-position
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,d0
		cmpi.b	#6,d0
		bne.s	loc_C5CA
		add.b	($FFFFFE11).w,d0 ; add act number to frame number

loc_C5CA:
		move.b	d0,$1A(a1)
		move.l	#Map_obj3A,4(a1)
		move.w	#$8580,2(a1)
		move.b	#0,1(a1)
		lea	$40(a1),a1
		dbf	d1,Obj3A_Loop	; repeat 6 times

Obj3A_ChkPos:				; XREF: Obj3A_Index
		moveq	#$10,d1		; set horizontal speed
		move.w	$30(a0),d0
		cmp.w	8(a0),d0	; has item reached its target position?
		beq.s	loc_C61A	; if yes, branch
		bge.s	Obj3A_Move
		neg.w	d1

Obj3A_Move:
		add.w	d1,8(a0)	; change item's position

loc_C5FE:				; XREF: loc_C61A
		move.w	8(a0),d0
		bmi.s	locret_C60E
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_C60E	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C60E:
		rts
; ===========================================================================

loc_C610:				; XREF: loc_C61A
		move.b	#$E,$24(a0)
		bra.w	Obj3A_ChkPos2
; ===========================================================================

loc_C61A:				; XREF: Obj3A_ChkPos
		cmpi.b	#$E,($FFFFD724).w
		beq.s	loc_C610
		cmpi.b	#4,$1A(a0)
		bne.s	loc_C5FE
		addq.b	#2,$24(a0)
		move.w	#180,$1E(a0)	; set time delay to 3 seconds

Obj3A_Wait:				; XREF: Obj3A_Index
		subq.w	#1,$1E(a0)	; subtract 1 from time delay
		bne.s	Obj3A_Display
		addq.b	#2,$24(a0)

Obj3A_Display:
		bra.w	DisplaySprite
; ===========================================================================

Obj3A_TimeBonus:			; XREF: Obj3A_Index
		bsr.w	DisplaySprite
		move.b	#1,($FFFFF7D6).w ; set time/ring bonus update flag
		moveq	#0,d0
		tst.w	($FFFFF7D2).w	; is time bonus	= zero?
		beq.s	Obj3A_RingBonus	; if yes, branch
		addi.w	#10,d0		; add 10 to score
		subi.w	#10,($FFFFF7D2).w ; subtract 10	from time bonus

Obj3A_RingBonus:
		tst.w	($FFFFF7D4).w	; is ring bonus	= zero?
		beq.s	Obj3A_ChkBonus	; if yes, branch
		addi.w	#10,d0		; add 10 to score
		subi.w	#10,($FFFFF7D4).w ; subtract 10	from ring bonus

Obj3A_ChkBonus:
		tst.w	d0		; is there any bonus?
		bne.s	Obj3A_AddBonus	; if yes, branch
		moveq	#sfx_Register,d0
		jsr	(PlaySound_Special).l ;	play "ker-ching" sound
		addq.b	#2,$24(a0)
		cmpi.w	#$501,($FFFFFE10).w
		bne.s	Obj3A_SetDelay
		addq.b	#4,$24(a0)

Obj3A_SetDelay:
		move.w	#180,$1E(a0)	; set time delay to 3 seconds

locret_C692:
		rts
; ===========================================================================

Obj3A_AddBonus:				; XREF: Obj3A_ChkBonus
		jsr	AddPoints
		move.b	($FFFFFE0F).w,d0
		andi.b	#3,d0
		bne.s	locret_C692
		moveq	#sfx_Switch,d0
		jmp	(PlaySound_Special).l ;	play "blip" sound
; ===========================================================================

Obj3A_NextLevel:			; XREF: Obj3A_Index
		move.b	($FFFFFE10).w,d0
		andi.w	#7,d0
		lsl.w	#3,d0
		move.b	($FFFFFE11).w,d1
		andi.w	#3,d1
		add.w	d1,d1
		add.w	d1,d0
		move.w	LevelOrder(pc,d0.w),d0 ; load level from level order array
		move.w	d0,($FFFFFE10).w ; set level number
		tst.w	d0
		bne.s	Obj3A_ChkSS
		move.b	#0,($FFFFF600).w ; set game mode to level (00)
		bra.s	Obj3A_Display2
; ===========================================================================

Obj3A_ChkSS:				; XREF: Obj3A_NextLevel
		clr.b	($FFFFFE30).w	; clear	lamppost counter
		tst.b	($FFFFF7CD).w	; has Sonic jumped into	a giant	ring?
		beq.s	loc_C6EA	; if not, branch
		move.b	#$10,($FFFFF600).w ; set game mode to Special Stage (10)
		bra.s	Obj3A_Display2
; ===========================================================================

loc_C6EA:				; XREF: Obj3A_ChkSS
		move.w	#1,($FFFFFE02).w ; restart level

Obj3A_Display2:				; XREF: Obj3A_NextLevel, Obj3A_ChkSS
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Level	order array
; ---------------------------------------------------------------------------
LevelOrder:	incbin	misc\lvl_ord.bin
		even
; ===========================================================================

Obj3A_ChkPos2:				; XREF: Obj3A_Index
		moveq	#$20,d1		; set horizontal speed
		move.w	$32(a0),d0
		cmp.w	8(a0),d0	; has item reached its finish position?
		beq.s	Obj3A_SBZ2	; if yes, branch
		bge.s	Obj3A_Move2
		neg.w	d1

Obj3A_Move2:
		add.w	d1,8(a0)	; change item's position
		move.w	8(a0),d0
		bmi.s	locret_C748
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_C748	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C748:
		rts
; ===========================================================================

Obj3A_SBZ2:				; XREF: Obj3A_ChkPos2
		cmpi.b	#4,$1A(a0)
		bne.w	DeleteObject
		addq.b	#2,$24(a0)
		clr.b	($FFFFF7CC).w	; unlock controls
		moveq	#mus_FZ,d0
		jmp	PlaySound	; play FZ music
; ===========================================================================

loc_C766:				; XREF: Obj3A_Index
		addq.w	#2,($FFFFF72A).w
;		cmpi.w	#$2100,($FFFFF72A).w
		beq.w	DeleteObject
		rts
; ===========================================================================
Obj3A_Config:	dc.w 4,	$124, $BC	; x-start, x-main, y-main
		dc.b 2,	0		; routine number, frame	number (changes)
		dc.w $FEE0, $120, $D0
		dc.b 2,	1
		dc.w $40C, $14C, $D6
		dc.b 2,	6
		dc.w $520, $120, $EC
		dc.b 2,	2
		dc.w $540, $120, $FC
		dc.b 2,	3
		dc.w $560, $120, $10C
		dc.b 2,	4
		dc.w $20C, $14C, $CC
		dc.b 2,	5
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 7E - special stage results screen
; ---------------------------------------------------------------------------

Obj7E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj7E_Index(pc,d0.w),d1
		jmp	Obj7E_Index(pc,d1.w)
; ===========================================================================
Obj7E_Index:	dc.w Obj7E_ChkPLC-Obj7E_Index
		dc.w Obj7E_ChkPos-Obj7E_Index
		dc.w Obj7E_Wait-Obj7E_Index
		dc.w Obj7E_RingBonus-Obj7E_Index
		dc.w Obj7E_Wait-Obj7E_Index
		dc.w Obj7E_Exit-Obj7E_Index
		dc.w Obj7E_Wait-Obj7E_Index
		dc.w Obj7E_Continue-Obj7E_Index
		dc.w Obj7E_Wait-Obj7E_Index
		dc.w Obj7E_Exit-Obj7E_Index
		dc.w loc_C91A-Obj7E_Index
; ===========================================================================

Obj7E_ChkPLC:				; XREF: Obj7E_Index
		tst.l	($FFFFF680).w	; are the pattern load cues empty?
		beq.s	Obj7E_Main	; if yes, branch
		rts
; ===========================================================================

Obj7E_Main:
		movea.l	a0,a1
		lea	(Obj7E_Config).l,a2
		moveq	#3,d1
		cmpi.w	#50,($FFFFFE20).w ; do you have	50 or more rings?
		bcs.s	Obj7E_Loop	; if no, branch
		addq.w	#1,d1		; if yes, add 1	to d1 (number of sprites)

Obj7E_Loop:
		move.b	#$7E,0(a1)
		move.w	(a2)+,8(a1)	; load start x-position
		move.w	(a2)+,$30(a1)	; load main x-position
		move.w	(a2)+,$A(a1)	; load y-position
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,$1A(a1)
		move.l	#Map_obj7E,4(a1)
		move.w	#$8580,2(a1)
		move.b	#0,1(a1)
		lea	$40(a1),a1
		dbf	d1,Obj7E_Loop	; repeat sequence 3 or 4 times

		moveq	#7,d0
		move.b	($FFFFFE57).w,d1
		beq.s	loc_C842
		moveq	#0,d0
		cmpi.b	#6,d1		; do you have all chaos	emeralds?
		bne.s	loc_C842	; if not, branch
		moveq	#8,d0		; load "Sonic got them all" text
		move.w	#$18,8(a0)
		move.w	#$118,$30(a0)	; change position of text

loc_C842:
		move.b	d0,$1A(a0)

Obj7E_ChkPos:				; XREF: Obj7E_Index
		moveq	#$10,d1		; set horizontal speed
		move.w	$30(a0),d0
		cmp.w	8(a0),d0	; has item reached its target position?
		beq.s	loc_C86C	; if yes, branch
		bge.s	Obj7E_Move
		neg.w	d1

Obj7E_Move:
		add.w	d1,8(a0)	; change item's position

loc_C85A:				; XREF: loc_C86C
		move.w	8(a0),d0
		bmi.s	locret_C86A
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_C86A	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C86A:
		rts
; ===========================================================================

loc_C86C:				; XREF: Obj7E_ChkPos
		cmpi.b	#2,$1A(a0)
		bne.s	loc_C85A
		addq.b	#2,$24(a0)
		move.w	#180,$1E(a0)	; set time delay to 3 seconds
		move.b	#$7F,($FFFFD800).w ; load chaos	emerald	object

Obj7E_Wait:				; XREF: Obj7E_Index
		subq.w	#1,$1E(a0)	; subtract 1 from time delay
		bne.s	Obj7E_Display
		addq.b	#2,$24(a0)

Obj7E_Display:
		bra.w	DisplaySprite
; ===========================================================================

Obj7E_RingBonus:			; XREF: Obj7E_Index
		bsr.w	DisplaySprite
		move.b	#1,($FFFFF7D6).w ; set ring bonus update flag
		tst.w	($FFFFF7D4).w	; is ring bonus	= zero?
		beq.s	loc_C8C4	; if yes, branch
		subi.w	#10,($FFFFF7D4).w ; subtract 10	from ring bonus
		moveq	#10,d0		; add 10 to score
		jsr	AddPoints
		move.b	($FFFFFE0F).w,d0
		andi.b	#3,d0
		bne.s	locret_C8EA
		moveq	#sfx_Switch,d0
		jmp	(PlaySound_Special).l ;	play "blip" sound
; ===========================================================================

loc_C8C4:				; XREF: Obj7E_RingBonus
		moveq	#sfx_Register,d0
		jsr	(PlaySound_Special).l ;	play "ker-ching" sound
		addq.b	#2,$24(a0)
		move.w	#180,$1E(a0)	; set time delay to 3 seconds
		cmpi.w	#50,($FFFFFE20).w ; do you have	at least 50 rings?
		bcs.s	locret_C8EA	; if not, branch
		move.w	#60,$1E(a0)	; set time delay to 1 second
		addq.b	#4,$24(a0)	; goto "Obj7E_Continue"	routine

locret_C8EA:
		rts
; ===========================================================================

Obj7E_Exit:				; XREF: Obj7E_Index
		move.w	#1,($FFFFFE02).w ; restart level
		bra.w	DisplaySprite
; ===========================================================================

Obj7E_Continue:				; XREF: Obj7E_Index
		move.b	#4,($FFFFD6DA).w
		move.b	#$14,($FFFFD6E4).w
		moveq	#sfx_Continue,d0
		jsr	(PlaySound_Special).l ;	play continues music
		addq.b	#2,$24(a0)
		move.w	#360,$1E(a0)	; set time delay to 6 seconds
		bra.w	DisplaySprite
; ===========================================================================

loc_C91A:				; XREF: Obj7E_Index
		move.b	($FFFFFE0F).w,d0
		andi.b	#$F,d0
		bne.s	Obj7E_Display2
		bchg	#0,$1A(a0)

Obj7E_Display2:
		bra.w	DisplaySprite
; ===========================================================================
Obj7E_Config:	dc.w $20, $120,	$C4	; start	x-pos, main x-pos, y-pos
		dc.b 2,	0		; rountine number, frame number
		dc.w $320, $120, $118
		dc.b 2,	1
		dc.w $360, $120, $128
		dc.b 2,	2
		dc.w $1EC, $11C, $C4
		dc.b 2,	3
		dc.w $3A0, $120, $138
		dc.b 2,	6
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 7F - chaos emeralds from the special stage results screen
; ---------------------------------------------------------------------------

Obj7F:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj7F_Index(pc,d0.w),d1
		jmp	Obj7F_Index(pc,d1.w)
; ===========================================================================
Obj7F_Index:	dc.w Obj7F_Main-Obj7F_Index
		dc.w Obj7F_Flash-Obj7F_Index

; ---------------------------------------------------------------------------
; X-axis positions for chaos emeralds
; ---------------------------------------------------------------------------
Obj7F_PosData:	dc.w $110, $128, $F8, $140, $E0, $158
; ===========================================================================

Obj7F_Main:				; XREF: Obj7F_Index
		movea.l	a0,a1
		lea	(Obj7F_PosData).l,a2
		moveq	#0,d2
		moveq	#0,d1
		move.b	($FFFFFE57).w,d1 ; d1 is number	of emeralds
		subq.b	#1,d1		; subtract 1 from d1
		bcs.w	DeleteObject	; if you have 0	emeralds, branch

Obj7F_Loop:
		move.b	#$7F,0(a1)
		move.w	(a2)+,8(a1)	; set x-position
		move.w	#$F0,$A(a1)	; set y-position
		lea	($FFFFFE58).w,a3 ; check which emeralds	you have
		move.b	(a3,d2.w),d3
		move.b	d3,$1A(a1)
		move.b	d3,$1C(a1)
		addq.b	#1,d2
		addq.b	#2,$24(a1)
		move.l	#Map_obj7F,4(a1)
		move.w	#$8541,2(a1)
		move.b	#0,1(a1)
		lea	$40(a1),a1	; next object
		dbf	d1,Obj7F_Loop	; loop for d1 number of	emeralds

Obj7F_Flash:				; XREF: Obj7F_Index
		move.b	$1A(a0),d0
		move.b	#6,$1A(a0)	; load 6th frame (blank)
		cmpi.b	#6,d0
		bne.s	Obj7F_Display
		move.b	$1C(a0),$1A(a0)	; load visible frame

Obj7F_Display:
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - zone title cards
; ---------------------------------------------------------------------------
Map_obj34:	dc.w byte_C9FE-Map_obj34
		dc.w byte_CA2C-Map_obj34
		dc.w byte_CA5A-Map_obj34
		dc.w byte_CA7A-Map_obj34
		dc.w byte_CAA8-Map_obj34
		dc.w byte_CADC-Map_obj34
		dc.w byte_CB10-Map_obj34
		dc.w byte_CB26-Map_obj34
		dc.w byte_CB31-Map_obj34
		dc.w byte_CB3C-Map_obj34
		dc.w byte_CB47-Map_obj34
		dc.w byte_CB8A-Map_obj34
byte_C9FE:	dc.b 9 			; GREEN HILL
		dc.b $F8, 5, 0,	$18, $B4
		dc.b $F8, 5, 0,	$3A, $C4
		dc.b $F8, 5, 0,	$10, $D4
		dc.b $F8, 5, 0,	$10, $E4
		dc.b $F8, 5, 0,	$2E, $F4
		dc.b $F8, 5, 0,	$1C, $14
		dc.b $F8, 1, 0,	$20, $24
		dc.b $F8, 5, 0,	$26, $2C
		dc.b $F8, 5, 0,	$26, $3C
byte_CA2C:	dc.b 9			; LABYRINTH
		dc.b $F8, 5, 0,	$26, $BC
		dc.b $F8, 5, 0,	0, $CC
		dc.b $F8, 5, 0,	4, $DC
		dc.b $F8, 5, 0,	$4A, $EC
		dc.b $F8, 5, 0,	$3A, $FC
		dc.b $F8, 1, 0,	$20, $C
		dc.b $F8, 5, 0,	$2E, $14
		dc.b $F8, 5, 0,	$42, $24
		dc.b $F8, 5, 0,	$1C, $34
byte_CA5A:	dc.b 6			; MARBLE
		dc.b $F8, 5, 0,	$2A, $CF
		dc.b $F8, 5, 0,	0, $E0
		dc.b $F8, 5, 0,	$3A, $F0
		dc.b $F8, 5, 0,	4, 0
		dc.b $F8, 5, 0,	$26, $10
		dc.b $F8, 5, 0,	$10, $20
		dc.b 0
byte_CA7A:	dc.b 9			; STAR	LIGHT
		dc.b $F8, 5, 0,	$3E, $B4
		dc.b $F8, 5, 0,	$42, $C4
		dc.b $F8, 5, 0,	0, $D4
		dc.b $F8, 5, 0,	$3A, $E4
		dc.b $F8, 5, 0,	$26, 4
		dc.b $F8, 1, 0,	$20, $14
		dc.b $F8, 5, 0,	$18, $1C
		dc.b $F8, 5, 0,	$1C, $2C
		dc.b $F8, 5, 0,	$42, $3C
byte_CAA8:	dc.b $A			; SPRING YARD
		dc.b $F8, 5, 0,	$3E, $AC
		dc.b $F8, 5, 0,	$36, $BC
		dc.b $F8, 5, 0,	$3A, $CC
		dc.b $F8, 1, 0,	$20, $DC
		dc.b $F8, 5, 0,	$2E, $E4
		dc.b $F8, 5, 0,	$18, $F4
		dc.b $F8, 5, 0,	$4A, $14
		dc.b $F8, 5, 0,	0, $24
		dc.b $F8, 5, 0,	$3A, $34
		dc.b $F8, 5, 0,	$C, $44
		dc.b 0
byte_CADC:	dc.b $A			; SCRAP BRAIN
		dc.b $F8, 5, 0,	$3E, $AC
		dc.b $F8, 5, 0,	8, $BC
		dc.b $F8, 5, 0,	$3A, $CC
		dc.b $F8, 5, 0,	0, $DC
		dc.b $F8, 5, 0,	$36, $EC
		dc.b $F8, 5, 0,	4, $C
		dc.b $F8, 5, 0,	$3A, $1C
		dc.b $F8, 5, 0,	0, $2C
		dc.b $F8, 1, 0,	$20, $3C
		dc.b $F8, 5, 0,	$2E, $44
		dc.b 0
byte_CB10:	dc.b 4			; ZONE
		dc.b $F8, 5, 0,	$4E, $E0
		dc.b $F8, 5, 0,	$32, $F0
		dc.b $F8, 5, 0,	$2E, 0
		dc.b $F8, 5, 0,	$10, $10
		dc.b 0
byte_CB26:	dc.b 2			; ACT 1
		dc.b 4,	$C, 0, $53, $EC
		dc.b $F4, 2, 0,	$57, $C
byte_CB31:	dc.b 2			; ACT 2
		dc.b 4,	$C, 0, $53, $EC
		dc.b $F4, 6, 0,	$5A, 8
byte_CB3C:	dc.b 2			; ACT 3
		dc.b 4,	$C, 0, $53, $EC
		dc.b $F4, 6, 0,	$60, 8
byte_CB47:	dc.b $D			; Oval
		dc.b $E4, $C, 0, $70, $F4
		dc.b $E4, 2, 0,	$74, $14
		dc.b $EC, 4, 0,	$77, $EC
		dc.b $F4, 5, 0,	$79, $E4
		dc.b $14, $C, $18, $70,	$EC
		dc.b 4,	2, $18,	$74, $E4
		dc.b $C, 4, $18, $77, 4
		dc.b $FC, 5, $18, $79, $C
		dc.b $EC, 8, 0,	$7D, $FC
		dc.b $F4, $C, 0, $7C, $F4
		dc.b $FC, 8, 0,	$7C, $F4
		dc.b 4,	$C, 0, $7C, $EC
		dc.b $C, 8, 0, $7C, $EC
		dc.b 0
byte_CB8A:	dc.b 5			; FINAL
		dc.b $F8, 5, 0,	$14, $DC
		dc.b $F8, 1, 0,	$20, $EC
		dc.b $F8, 5, 0,	$2E, $F4
		dc.b $F8, 5, 0,	0, 4
		dc.b $F8, 5, 0,	$26, $14
		even
; ---------------------------------------------------------------------------
; Sprite mappings - "GAME OVER"	and "TIME OVER"
; ---------------------------------------------------------------------------
Map_obj39:
	include "_maps\obj39.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC HAS PASSED" title card
; ---------------------------------------------------------------------------
Map_obj3A:	dc.w byte_CBEA-Map_obj3A
		dc.w byte_CC13-Map_obj3A
		dc.w byte_CC32-Map_obj3A
		dc.w byte_CC51-Map_obj3A
		dc.w byte_CC75-Map_obj3A
		dc.w byte_CB47-Map_obj3A
		dc.w byte_CB26-Map_obj3A
		dc.w byte_CB31-Map_obj3A
		dc.w byte_CB3C-Map_obj3A
byte_CBEA:	dc.b 8			; SONIC HAS
		dc.b $F8, 5, 0,	$3E, $B8
		dc.b $F8, 5, 0,	$32, $C8
		dc.b $F8, 5, 0,	$2E, $D8
		dc.b $F8, 1, 0,	$20, $E8
		dc.b $F8, 5, 0,	8, $F0
		dc.b $F8, 5, 0,	$1C, $10
		dc.b $F8, 5, 0,	0, $20
		dc.b $F8, 5, 0,	$3E, $30
byte_CC13:	dc.b 6			; PASSED
		dc.b $F8, 5, 0,	$36, $D0
		dc.b $F8, 5, 0,	0, $E0
		dc.b $F8, 5, 0,	$3E, $F0
		dc.b $F8, 5, 0,	$3E, 0
		dc.b $F8, 5, 0,	$10, $10
		dc.b $F8, 5, 0,	$C, $20
byte_CC32:	dc.b 6			; SCORE
		dc.b $F8, $D, 1, $4A, $B0
		dc.b $F8, 1, 1,	$62, $D0
		dc.b $F8, 9, 1,	$64, $18
		dc.b $F8, $D, 1, $6A, $30
		dc.b $F7, 4, 0,	$6E, $CD
		dc.b $FF, 4, $18, $6E, $CD
byte_CC51:	dc.b 7			; TIME BONUS
		dc.b $F8, $D, 1, $5A, $B0
		dc.b $F8, $D, 0, $66, $D9
		dc.b $F8, 1, 1,	$4A, $F9
		dc.b $F7, 4, 0,	$6E, $F6
		dc.b $FF, 4, $18, $6E, $F6
		dc.b $F8, $D, $FF, $F0,	$28
		dc.b $F8, 1, 1,	$70, $48
byte_CC75:	dc.b 7			; RING BONUS
		dc.b $F8, $D, 1, $52, $B0
		dc.b $F8, $D, 0, $66, $D9
		dc.b $F8, 1, 1,	$4A, $F9
		dc.b $F7, 4, 0,	$6E, $F6
		dc.b $FF, 4, $18, $6E, $F6
		dc.b $F8, $D, $FF, $F8,	$28
		dc.b $F8, 1, 1,	$70, $48
		even
; ---------------------------------------------------------------------------
; Sprite mappings - special stage results screen
; ---------------------------------------------------------------------------
Map_obj7E:	dc.w byte_CCAC-Map_obj7E
		dc.w byte_CCEE-Map_obj7E
		dc.w byte_CD0D-Map_obj7E
		dc.w byte_CB47-Map_obj7E
		dc.w byte_CD31-Map_obj7E
		dc.w byte_CD46-Map_obj7E
		dc.w byte_CD5B-Map_obj7E
		dc.w byte_CD6B-Map_obj7E
		dc.w byte_CDA8-Map_obj7E
byte_CCAC:	dc.b $D			; "CHAOS EMERALDS"
		dc.b $F8, 5, 0,	8, $90
		dc.b $F8, 5, 0,	$1C, $A0
		dc.b $F8, 5, 0,	0, $B0
		dc.b $F8, 5, 0,	$32, $C0
		dc.b $F8, 5, 0,	$3E, $D0
		dc.b $F8, 5, 0,	$10, $F0
		dc.b $F8, 5, 0,	$2A, 0
		dc.b $F8, 5, 0,	$10, $10
		dc.b $F8, 5, 0,	$3A, $20
		dc.b $F8, 5, 0,	0, $30
		dc.b $F8, 5, 0,	$26, $40
		dc.b $F8, 5, 0,	$C, $50
		dc.b $F8, 5, 0,	$3E, $60
byte_CCEE:	dc.b 6			; "SCORE"
		dc.b $F8, $D, 1, $4A, $B0
		dc.b $F8, 1, 1,	$62, $D0
		dc.b $F8, 9, 1,	$64, $18
		dc.b $F8, $D, 1, $6A, $30
		dc.b $F7, 4, 0,	$6E, $CD
		dc.b $FF, 4, $18, $6E, $CD
byte_CD0D:	dc.b 7
		dc.b $F8, $D, 1, $52, $B0
		dc.b $F8, $D, 0, $66, $D9
		dc.b $F8, 1, 1,	$4A, $F9
		dc.b $F7, 4, 0,	$6E, $F6
		dc.b $FF, 4, $18, $6E, $F6
		dc.b $F8, $D, $FF, $F8,	$28
		dc.b $F8, 1, 1,	$70, $48
byte_CD31:	dc.b 4
		dc.b $F8, $D, $FF, $D1,	$B0
		dc.b $F8, $D, $FF, $D9,	$D0
		dc.b $F8, 1, $FF, $E1, $F0
		dc.b $F8, 6, $1F, $E3, $40
byte_CD46:	dc.b 4
		dc.b $F8, $D, $FF, $D1,	$B0
		dc.b $F8, $D, $FF, $D9,	$D0
		dc.b $F8, 1, $FF, $E1, $F0
		dc.b $F8, 6, $1F, $E9, $40
byte_CD5B:	dc.b 3
		dc.b $F8, $D, $FF, $D1,	$B0
		dc.b $F8, $D, $FF, $D9,	$D0
		dc.b $F8, 1, $FF, $E1, $F0
byte_CD6B:	dc.b $C			; "SPECIAL STAGE"
		dc.b $F8, 5, 0,	$3E, $9C
		dc.b $F8, 5, 0,	$36, $AC
		dc.b $F8, 5, 0,	$10, $BC
		dc.b $F8, 5, 0,	8, $CC
		dc.b $F8, 1, 0,	$20, $DC
		dc.b $F8, 5, 0,	0, $E4
		dc.b $F8, 5, 0,	$26, $F4
		dc.b $F8, 5, 0,	$3E, $14
		dc.b $F8, 5, 0,	$42, $24
		dc.b $F8, 5, 0,	0, $34
		dc.b $F8, 5, 0,	$18, $44
		dc.b $F8, 5, 0,	$10, $54
byte_CDA8:	dc.b $F			; "SONIC GOT THEM ALL"
		dc.b $F8, 5, 0,	$3E, $88
		dc.b $F8, 5, 0,	$32, $98
		dc.b $F8, 5, 0,	$2E, $A8
		dc.b $F8, 1, 0,	$20, $B8
		dc.b $F8, 5, 0,	8, $C0
		dc.b $F8, 5, 0,	$18, $D8
		dc.b $F8, 5, 0,	$32, $E8
		dc.b $F8, 5, 0,	$42, $F8
		dc.b $F8, 5, 0,	$42, $10
		dc.b $F8, 5, 0,	$1C, $20
		dc.b $F8, 5, 0,	$10, $30
		dc.b $F8, 5, 0,	$2A, $40
		dc.b $F8, 5, 0,	0, $58
		dc.b $F8, 5, 0,	$26, $68
		dc.b $F8, 5, 0,	$26, $78
		even
; ---------------------------------------------------------------------------
; Sprite mappings - chaos emeralds from	the special stage results screen
; ---------------------------------------------------------------------------
Map_obj7F:
	include "_maps\obj7F.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 36 - spikes
; ---------------------------------------------------------------------------

Obj36:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj36_Index(pc,d0.w),d1
		jmp	Obj36_Index(pc,d1.w)
; ===========================================================================
Obj36_Index:	dc.w Obj36_Main-Obj36_Index
		dc.w Obj36_Solid-Obj36_Index

Obj36_Var:	dc.b 0,	$14		; frame	number,	object width
		dc.b 1,	$10
		dc.b 2,	4
		dc.b 3,	$1C
		dc.b 4,	$40
		dc.b 5,	$10
; ===========================================================================

Obj36_Main:				; XREF: Obj36_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj36,4(a0)
		move.w	#$51B,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	$28(a0),d0
		andi.b	#$F,$28(a0)
		andi.w	#$F0,d0
		lea	(Obj36_Var).l,a1
		lsr.w	#3,d0
		adda.w	d0,a1
		move.b	(a1)+,$1A(a0)
		move.b	(a1)+,$19(a0)
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$32(a0)

Obj36_Solid:				; XREF: Obj36_Index
		bsr.w	Obj36_Type0x	; make the object move
		move.w	#4,d2
		cmpi.b	#5,$1A(a0)	; is object type $5x ?
		beq.s	Obj36_SideWays	; if yes, branch
		cmpi.b	#1,$1A(a0)	; is object type $1x ?
		bne.s	Obj36_Upright	; if not, branch
		move.w	#$14,d2

; Spikes types $1x and $5x face	sideways

Obj36_SideWays:				; XREF: Obj36_Solid
		move.w	#$1B,d1
		move.w	d2,d3
		addq.w	#1,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		btst	#3,$22(a0)
		bne.s	Obj36_Display
		cmpi.w	#1,d4
		beq.s	Obj36_Hurt
		bra.s	Obj36_Display
; ===========================================================================

; Spikes types $0x, $2x, $3x and $4x face up or	down

Obj36_Upright:				; XREF: Obj36_Solid
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		btst	#3,$22(a0)
		bne.s	Obj36_Hurt
		tst.w	d4
		bpl.s	Obj36_Display

Obj36_Hurt:				; XREF: Obj36_SideWays; Obj36_Upright
		tst.b	($FFFFFE2D).w	; is Sonic invincible?
		bne.s	Obj36_Display	; if yes, branch
		move.l	a0,-(sp)
		movea.l	a0,a2
		lea	($FFFFD000).w,a0
		cmpi.b	#4,$24(a0)
		bcc.s	loc_CF20
		move.l	$C(a0),d3
		move.w	$12(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,$C(a0)
		jsr	HurtSonic

loc_CF20:
		movea.l	(sp)+,a0

Obj36_Display:
		bsr.w	DisplaySprite
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================

Obj36_Type0x:				; XREF: Obj36_Solid
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	Obj36_TypeIndex(pc,d0.w),d1
		jmp	Obj36_TypeIndex(pc,d1.w)
; ===========================================================================
Obj36_TypeIndex:dc.w Obj36_Type00-Obj36_TypeIndex
		dc.w Obj36_Type01-Obj36_TypeIndex
		dc.w Obj36_Type02-Obj36_TypeIndex
; ===========================================================================

Obj36_Type00:				; XREF: Obj36_TypeIndex
		rts			; don't move the object
; ===========================================================================

Obj36_Type01:				; XREF: Obj36_TypeIndex
		bsr.w	Obj36_Wait
		moveq	#0,d0
		move.b	$34(a0),d0
		add.w	$32(a0),d0
		move.w	d0,$C(a0)	; move the object vertically
		rts
; ===========================================================================

Obj36_Type02:				; XREF: Obj36_TypeIndex
		bsr.w	Obj36_Wait
		moveq	#0,d0
		move.b	$34(a0),d0
		add.w	$30(a0),d0
		move.w	d0,8(a0)	; move the object horizontally
		rts
; ===========================================================================

Obj36_Wait:
		tst.w	$38(a0)		; is time delay	= zero?
		beq.s	loc_CFA4	; if yes, branch
		subq.w	#1,$38(a0)	; subtract 1 from time delay
		bne.s	locret_CFE6
		tst.b	1(a0)
		bpl.s	locret_CFE6
		moveq	#sfx_SpikeMove,d0
		jsr	PlaySound_Special ;	play "spikes moving" sound
		bra.s	locret_CFE6
; ===========================================================================

loc_CFA4:
		tst.w	$36(a0)
		beq.s	loc_CFC6
		subi.w	#$800,$34(a0)
		bcc.s	locret_CFE6
		move.w	#0,$34(a0)
		move.w	#0,$36(a0)
		move.w	#60,$38(a0)	; set time delay to 1 second
		bra.s	locret_CFE6
; ===========================================================================

loc_CFC6:
		addi.w	#$800,$34(a0)
		cmpi.w	#$2000,$34(a0)
		bcs.s	locret_CFE6
		move.w	#$2000,$34(a0)
		move.w	#1,$36(a0)
		move.w	#60,$38(a0)	; set time delay to 1 second

locret_CFE6:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - spikes
; ---------------------------------------------------------------------------
Map_obj36:
	include "_maps\obj36.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3B - purple rock (GHZ)
; ---------------------------------------------------------------------------

Obj3B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj3B_Index(pc,d0.w),d1
		jmp	Obj3B_Index(pc,d1.w)
; ===========================================================================
Obj3B_Index:	dc.w Obj3B_Main-Obj3B_Index
		dc.w Obj3B_Solid-Obj3B_Index
; ===========================================================================

Obj3B_Main:				; XREF: Obj3B_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj3B,4(a0)
		move.w	#$63D0,2(a0)
		move.b	#4,1(a0)
		move.b	#$13,$19(a0)
		move.b	#4,$18(a0)

Obj3B_Solid:				; XREF: Obj3B_Index
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	#$10,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 49 - waterfall	sound effect (GHZ)
; ---------------------------------------------------------------------------

Obj49:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj49_Index(pc,d0.w),d1
		jmp	Obj49_Index(pc,d1.w)
; ===========================================================================
Obj49_Index:	dc.w Obj49_Main-Obj49_Index
		dc.w Obj49_PlaySnd-Obj49_Index
; ===========================================================================

Obj49_Main:				; XREF: Obj49_Index
		addq.b	#2,$24(a0)
		move.b	#4,1(a0)

Obj49_PlaySnd:				; XREF: Obj49_Index
;		move.b	($FFFFFE0F).w,d0
;		andi.b	#$3F,d0
;		bne.s	Obj49_ChkDel
;		move.w	#$D0,d0
;		jsr	(PlaySound_Special).l ;	play waterfall sound

Obj49_ChkDel:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - purple rock	(GHZ)
; ---------------------------------------------------------------------------
Map_obj3B:
	include "_maps\obj3B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3C - smashable	wall (GHZ, SLZ)
; ---------------------------------------------------------------------------

Obj3C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj3C_Index(pc,d0.w),d1
		jsr	Obj3C_Index(pc,d1.w)
		bra.w	MarkObjGone
; ===========================================================================
Obj3C_Index:	dc.w Obj3C_Main-Obj3C_Index
		dc.w Obj3C_Solid-Obj3C_Index
		dc.w Obj3C_FragMove-Obj3C_Index
; ===========================================================================

Obj3C_Main:				; XREF: Obj3C_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj3C,4(a0)
		move.w	#$450F,2(a0)
		move.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#4,$18(a0)
		move.b	$28(a0),$1A(a0)

Obj3C_Solid:				; XREF: Obj3C_Index
		move.w	($FFFFD010).w,$30(a0) ;	load Sonic's horizontal speed
		move.w	#$1B,d1
		move.w	#$20,d2
		move.w	#$20,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		btst	#5,$22(a0)
		bne.s	Obj3C_ChkRoll

locret_D180:
		rts
; ===========================================================================

Obj3C_ChkRoll:				; XREF: Obj3C_Solid
		cmpi.b	#2,$1C(a1)	; is Sonic rolling?
		bne.s	locret_D180	; if not, branch
		move.w	$30(a0),d0
		bpl.s	Obj3C_ChkSpeed
		neg.w	d0

Obj3C_ChkSpeed:
		cmpi.w	#$480,d0	; is Sonic's speed $480 or higher?
		bcs.s	locret_D180	; if not, branch
		move.w	$30(a0),$10(a1)
		addq.w	#4,8(a1)
		lea	(Obj3C_FragSpd1).l,a4 ;	use fragments that move	right
		move.w	8(a0),d0
		cmp.w	8(a1),d0	; is Sonic to the right	of the block?
		bcs.s	Obj3C_Smash	; if yes, branch
		subq.w	#8,8(a1)
		lea	(Obj3C_FragSpd2).l,a4 ;	use fragments that move	left

Obj3C_Smash:
		move.w	$10(a1),$14(a1)
		bclr	#5,$22(a0)
		bclr	#5,$22(a1)
		moveq	#7,d1		; load 8 fragments
		move.w	#$70,d2
		bsr.s	SmashObject

Obj3C_FragMove:				; XREF: Obj3C_Index
		bsr.w	SpeedToPos
		addi.w	#$70,$12(a0)	; make fragment	fall faster
		bsr.w	DisplaySprite
		tst.b	1(a0)
		bpl.w	DeleteObject
		rts

; ---------------------------------------------------------------------------
; Subroutine to	smash a	block (GHZ walls and MZ	blocks)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SmashObject:				; XREF: Obj3C_Smash
		moveq	#0,d0
		move.b	$1A(a0),d0
		add.w	d0,d0
		movea.l	4(a0),a3
		adda.w	(a3,d0.w),a3
		addq.w	#1,a3
		bset	#5,1(a0)
		move.b	0(a0),d4
		move.b	1(a0),d5
		movea.l	a0,a1
		bra.s	Smash_LoadFrag
; ===========================================================================

Smash_Loop:
		bsr.w	SingleObjLoad
		bne.s	Smash_PlaySnd
		addq.w	#5,a3

Smash_LoadFrag:				; XREF: SmashObject
		move.b	#4,$24(a1)
		move.b	d4,0(a1)
		move.l	a3,4(a1)
		move.b	d5,1(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	2(a0),2(a1)
		move.b	$18(a0),$18(a1)
		move.b	$19(a0),$19(a1)
		move.w	(a4)+,$10(a1)
		move.w	(a4)+,$12(a1)
		cmpa.l	a0,a1
		bcc.s	loc_D268
		move.l	a0,-(sp)
		movea.l	a1,a0
		bsr.w	SpeedToPos
		add.w	d2,$12(a0)
		movea.l	(sp)+,a0
		bsr.w	DisplaySprite2

loc_D268:
		dbf	d1,Smash_Loop

Smash_PlaySnd:
		moveq	#sfx_Smash,d0
		jmp	(PlaySound_Special).l ;	play smashing sound
; End of function SmashObject

; ===========================================================================
; Smashed block	fragment speeds
;
Obj3C_FragSpd1:	dc.w $400, $FB00	; x-move speed,	y-move speed
		dc.w $600, $FF00
		dc.w $600, $100
		dc.w $400, $500
		dc.w $600, $FA00
		dc.w $800, $FE00
		dc.w $800, $200
		dc.w $600, $600

Obj3C_FragSpd2:	dc.w $FA00, $FA00
		dc.w $F800, $FE00
		dc.w $F800, $200
		dc.w $FA00, $600
		dc.w $FC00, $FB00
		dc.w $FA00, $FF00
		dc.w $FA00, $100
		dc.w $FC00, $500
; ---------------------------------------------------------------------------
; Sprite mappings - smashable walls (GHZ, SLZ)
; ---------------------------------------------------------------------------
Map_obj3C:
	include "_maps\obj3C.asm"

; ---------------------------------------------------------------------------
; Object code loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjectsLoad:				; XREF: TitleScreen; et al
		lea	($FFFFD000).w,a0 ; set address for object RAM
		moveq	#$7F,d7
		moveq	#0,d0
		cmpi.b	#6,($FFFFD024).w
		bcc.s	loc_D362

loc_D348:
		move.b	(a0),d0		; load object number from RAM
		beq.s	loc_D358
		add.w	d0,d0
		add.w	d0,d0
		movea.l	Obj_Index-4(pc,d0.w),a1
		jsr	(a1)		; run the object's code
		moveq	#0,d0

loc_D358:
		lea	$40(a0),a0	; next object
		dbf	d7,loc_D348
		rts
; ===========================================================================

loc_D362:
		moveq	#$1F,d7
		bsr.s	loc_D348
		moveq	#$5F,d7

loc_D368:
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	loc_D378
		tst.b	1(a0)
		bpl.s	loc_D378
		bsr.w	DisplaySprite

loc_D378:
		lea	$40(a0),a0

loc_D37C:
		dbf	d7,loc_D368
		rts
; End of function ObjectsLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Object pointers
; ---------------------------------------------------------------------------
Obj_Index:
	include "_inc\Object pointers.asm"

; ---------------------------------------------------------------------------
; Subroutine to	make an	object fall downwards, increasingly fast
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjectFall:
		move.l	8(a0),d2
		move.l	$C(a0),d3
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	$12(a0),d0
		addi.w	#$38,$12(a0)	; increase vertical speed
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,8(a0)
		move.l	d3,$C(a0)
		rts
; End of function ObjectFall

; ---------------------------------------------------------------------------
; Subroutine translating object	speed to update	object position
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SpeedToPos:
		move.l	8(a0),d2
		move.l	$C(a0),d3
		move.w	$10(a0),d0	; load horizontal speed
		ext.l	d0
		asl.l	#8,d0		; multiply speed by $100
		add.l	d0,d2		; add to x-axis	position
		move.w	$12(a0),d0	; load vertical	speed
		ext.l	d0
		asl.l	#8,d0		; multiply by $100
		add.l	d0,d3		; add to y-axis	position
		move.l	d2,8(a0)	; update x-axis	position
		move.l	d3,$C(a0)	; update y-axis	position
		rts
; End of function SpeedToPos

; ---------------------------------------------------------------------------
; Subroutine to	display	a sprite/object, when a0 is the	object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DisplaySprite:
		lea	($FFFFAC00).w,a1
		move.w	$18(a0),d0
		lsr.w	#1,d0
		andi.w	#$380,d0
		adda.w	d0,a1
		cmpi.w	#$7E,(a1)
		bcc.s	locret_D620
		addq.w	#2,(a1)
		adda.w	(a1),a1
		move.w	a0,(a1)

locret_D620:
		rts
; End of function DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to	display	a 2nd sprite/object, when a1 is	the object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DisplaySprite2:
		lea	($FFFFAC00).w,a2
		move.w	$18(a1),d0
		lsr.w	#1,d0
		andi.w	#$380,d0
		adda.w	d0,a2
		cmpi.w	#$7E,(a2)
		bcc.s	locret_D63E
		addq.w	#2,(a2)
		adda.w	(a2),a2
		move.w	a1,(a2)

locret_D63E:
		rts
; End of function DisplaySprite2

; ---------------------------------------------------------------------------
; Subroutine to	delete an object
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DeleteObject:
		movea.l	a0,a1

DeleteObject2:
		moveq	#0,d1
		moveq	#$F,d0

loc_D646:
		move.l	d1,(a1)+	; clear	the object RAM
		dbf	d0,loc_D646	; repeat $F times (length of object RAM)
		rts
; End of function DeleteObject

; ===========================================================================
BldSpr_ScrPos:	dc.l 0			; blank
		dc.l $FFF700		; main screen x-position
		dc.l $FFF708		; background x-position	1
		dc.l $FFF718		; background x-position	2
; ---------------------------------------------------------------------------
; Subroutine to	convert	mappings (etc) to proper Megadrive sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSprites:				; XREF: TitleScreen; et al
		lea	($FFFFF800).w,a2 ; set address for sprite table
		moveq	#0,d5
		lea	($FFFFAC00).w,a4
		moveq	#7,d7

loc_D66A:
		tst.w	(a4)
		beq.w	loc_D72E
		moveq	#2,d6

loc_D672:
		movea.w	(a4,d6.w),a0
		tst.b	(a0)
		beq.w	loc_D726
		bclr	#7,1(a0)
		move.b	1(a0),d0
		move.b	d0,d4
		andi.w	#$C,d0
		beq.s	loc_D6DE
		movea.l	BldSpr_ScrPos(pc,d0.w),a1
		moveq	#0,d0
		move.b	$19(a0),d0
		move.w	8(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D726
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#$140,d1
		bge.s	loc_D726
		addi.w	#$80,d3
		btst	#4,d4
		beq.s	loc_D6E8
		moveq	#0,d0
		move.b	$16(a0),d0
		move.w	$C(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	loc_D726
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#$E0,d1
		bge.s	loc_D726
		addi.w	#$80,d2
		bra.s	loc_D700
; ===========================================================================

loc_D6DE:
		move.w	$A(a0),d2
		move.w	8(a0),d3
		bra.s	loc_D700
; ===========================================================================

loc_D6E8:
		move.w	$C(a0),d2
		sub.w	4(a1),d2
		addi.w	#$80,d2
		cmpi.w	#$60,d2
		bcs.s	loc_D726
		cmpi.w	#$180,d2
		bcc.s	loc_D726

loc_D700:
		movea.l	4(a0),a1
		moveq	#0,d1
		btst	#5,d4
		bne.s	loc_D71C
		move.b	$1A(a0),d1
		add.b	d1,d1
		adda.w	(a1,d1.w),a1
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	loc_D720

loc_D71C:
		bsr.w	sub_D750

loc_D720:
		bset	#7,1(a0)

loc_D726:
		addq.w	#2,d6
		subq.w	#2,(a4)
		bne.w	loc_D672

loc_D72E:
		lea	$80(a4),a4
		dbf	d7,loc_D66A
		move.b	d5,($FFFFF62C).w
		cmpi.b	#$50,d5
		beq.s	loc_D748
		move.l	#0,(a2)
		rts
; ===========================================================================

loc_D748:
		move.b	#0,-5(a2)
		rts
; End of function BuildSprites


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_D750:				; XREF: BuildSprites
		movea.w	2(a0),a3
		btst	#0,d4
		bne.s	loc_D796
		btst	#1,d4
		bne.w	loc_D7E4
; End of function sub_D750


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_D762:				; XREF: sub_D762; SS_ShowLayout
		cmpi.b	#$50,d5
		beq.s	locret_D794
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D78E
		addq.w	#1,d0

loc_D78E:
		move.w	d0,(a2)+
		dbf	d1,sub_D762

locret_D794:
		rts
; End of function sub_D762

; ===========================================================================

loc_D796:
		btst	#1,d4
		bne.w	loc_D82A

loc_D79E:
		cmpi.b	#$50,d5
		beq.s	locret_D7E2
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$800,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		neg.w	d0
		add.b	d4,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D7DC
		addq.w	#1,d0

loc_D7DC:
		move.w	d0,(a2)+
		dbf	d1,loc_D79E

locret_D7E2:
		rts
; ===========================================================================

loc_D7E4:				; XREF: sub_D750
		cmpi.b	#$50,d5
		beq.s	locret_D828
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		lsl.b	#3,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1000,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D822
		addq.w	#1,d0

loc_D822:
		move.w	d0,(a2)+
		dbf	d1,loc_D7E4

locret_D828:
		rts
; ===========================================================================

loc_D82A:
		cmpi.b	#$50,d5
		beq.s	locret_D87C
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		lsl.b	#3,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1800,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		neg.w	d0
		add.b	d4,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D876
		addq.w	#1,d0

loc_D876:
		move.w	d0,(a2)+
		dbf	d1,loc_D82A

locret_D87C:
		rts
; ---------------------------------------------------------------------------
; Subroutine to	check if an object is on the screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ChkObjOnScreen:
		move.w	8(a0),d0	; get object x-position
		sub.w	($FFFFF700).w,d0 ; subtract screen x-position
		bmi.s	NotOnScreen
		cmpi.w	#320,d0		; is object on the screen?
		bge.s	NotOnScreen	; if not, branch

		move.w	$C(a0),d1	; get object y-position
		sub.w	($FFFFF704).w,d1 ; subtract screen y-position
		bmi.s	NotOnScreen
		cmpi.w	#224,d1		; is object on the screen?
		bge.s	NotOnScreen	; if not, branch

		moveq	#0,d0		; set flag to 0
		rts
; ===========================================================================

NotOnScreen:				; XREF: ChkObjOnScreen
		moveq	#1,d0		; set flag to 1
		rts
; End of function ChkObjOnScreen


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ChkObjOnScreen2:
		moveq	#0,d1
		move.b	$19(a0),d1
		move.w	8(a0),d0
		sub.w	($FFFFF700).w,d0
		add.w	d1,d0
		bmi.s	NotOnScreen2
		add.w	d1,d1
		sub.w	d1,d0
		cmpi.w	#320,d0
		bge.s	NotOnScreen2

		move.w	$C(a0),d1
		sub.w	($FFFFF704).w,d1
		bmi.s	NotOnScreen2
		cmpi.w	#224,d1
		bge.s	NotOnScreen2

		moveq	#0,d0
		rts
; ===========================================================================

NotOnScreen2:				; XREF: ChkObjOnScreen2
		moveq	#1,d0
		rts
; End of function ChkObjOnScreen2

; ---------------------------------------------------------------------------
; Subroutine to	load a level's objects
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjPosLoad:				; XREF: Level; et al
		moveq	#0,d0
		move.b	($FFFFF76C).w,d0
		move.w	OPL_Index(pc,d0.w),d0
		jmp	OPL_Index(pc,d0.w)
; End of function ObjPosLoad

; ===========================================================================
OPL_Index:	dc.w OPL_Main-OPL_Index
		dc.w OPL_Next-OPL_Index
; ===========================================================================

OPL_Main:				; XREF: OPL_Index
		addq.b	#2,($FFFFF76C).w
		move.w	($FFFFFE10).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea	(ObjPos_Index).l,a0
		movea.l	a0,a1
		adda.w	(a0,d0.w),a0
		move.l	a0,($FFFFF770).w
		move.l	a0,($FFFFF774).w
		adda.w	2(a1,d0.w),a1
		move.l	a1,($FFFFF778).w
		move.l	a1,($FFFFF77C).w
		lea	($FFFFFC00).w,a2
		move.w	#$101,(a2)+
		move.w	#$5E,d0

OPL_ClrList:
		clr.l	(a2)+
		dbf	d0,OPL_ClrList	; clear	pre-destroyed object list

		lea	($FFFFFC00).w,a2
		moveq	#0,d2
		move.w	($FFFFF700).w,d6
		subi.w	#$80,d6
		bcc.s	loc_D93C
		moveq	#0,d6

loc_D93C:
		andi.w	#$FF80,d6
		movea.l	($FFFFF770).w,a0

loc_D944:
		cmp.w	(a0),d6
		bls.s	loc_D956
		tst.b	4(a0)
		bpl.s	loc_D952
		move.b	(a2),d2
		addq.b	#1,(a2)

loc_D952:
		addq.w	#6,a0
		bra.s	loc_D944
; ===========================================================================

loc_D956:
		move.l	a0,($FFFFF770).w
		movea.l	($FFFFF774).w,a0
		subi.w	#$80,d6
		bcs.s	loc_D976

loc_D964:
		cmp.w	(a0),d6
		bls.s	loc_D976
		tst.b	4(a0)
		bpl.s	loc_D972
		addq.b	#1,1(a2)

loc_D972:
		addq.w	#6,a0
		bra.s	loc_D964
; ===========================================================================

loc_D976:
		move.l	a0,($FFFFF774).w
		move.w	#-1,($FFFFF76E).w

OPL_Next:				; XREF: OPL_Index
		lea	($FFFFFC00).w,a2
		moveq	#0,d2
		move.w	($FFFFF700).w,d6
		andi.w	#$FF80,d6
		cmp.w	($FFFFF76E).w,d6
		beq.w	locret_DA3A
		bge.s	loc_D9F6
		move.w	d6,($FFFFF76E).w
		movea.l	($FFFFF774).w,a0
		subi.w	#$80,d6
		bcs.s	loc_D9D2

loc_D9A6:
		cmp.w	-6(a0),d6
		bge.s	loc_D9D2
		subq.w	#6,a0
		tst.b	4(a0)
		bpl.s	loc_D9BC
		subq.b	#1,1(a2)
		move.b	1(a2),d2

loc_D9BC:
		bsr.w	loc_DA3C
		bne.s	loc_D9C6
		subq.w	#6,a0
		bra.s	loc_D9A6
; ===========================================================================

loc_D9C6:
		tst.b	4(a0)
		bpl.s	loc_D9D0
		addq.b	#1,1(a2)

loc_D9D0:
		addq.w	#6,a0

loc_D9D2:
		move.l	a0,($FFFFF774).w
		movea.l	($FFFFF770).w,a0
		addi.w	#$300,d6

loc_D9DE:
		cmp.w	-6(a0),d6
		bgt.s	loc_D9F0
		tst.b	-2(a0)
		bpl.s	loc_D9EC
		subq.b	#1,(a2)

loc_D9EC:
		subq.w	#6,a0
		bra.s	loc_D9DE
; ===========================================================================

loc_D9F0:
		move.l	a0,($FFFFF770).w
		rts
; ===========================================================================

loc_D9F6:
		move.w	d6,($FFFFF76E).w
		movea.l	($FFFFF770).w,a0
		addi.w	#$280,d6

loc_DA02:
		cmp.w	(a0),d6
		bls.s	loc_DA16
		tst.b	4(a0)
		bpl.s	loc_DA10
		move.b	(a2),d2
		addq.b	#1,(a2)

loc_DA10:
		bsr.w	loc_DA3C
		beq.s	loc_DA02

loc_DA16:
		move.l	a0,($FFFFF770).w
		movea.l	($FFFFF774).w,a0
		subi.w	#$300,d6
		bcs.s	loc_DA36

loc_DA24:
		cmp.w	(a0),d6
		bls.s	loc_DA36
		tst.b	4(a0)
		bpl.s	loc_DA32
		addq.b	#1,1(a2)

loc_DA32:
		addq.w	#6,a0
		bra.s	loc_DA24
; ===========================================================================

loc_DA36:
		move.l	a0,($FFFFF774).w

locret_DA3A:
		rts
; ===========================================================================

loc_DA3C:
		tst.b	4(a0)
		bpl.s	OPL_MakeItem
		bset	#7,2(a2,d2.w)
		beq.s	OPL_MakeItem
		addq.w	#6,a0
		moveq	#0,d0
		rts
; ===========================================================================

OPL_MakeItem:
		bsr.w	SingleObjLoad
		bne.s	locret_DA8A
		move.w	(a0)+,8(a1)
		move.w	(a0)+,d0
		move.w	d0,d1
		andi.w	#$FFF,d0
		move.w	d0,$C(a1)
		rol.w	#2,d1
		andi.b	#3,d1
		move.b	d1,1(a1)
		move.b	d1,$22(a1)
		move.b	(a0)+,d0
		bpl.s	loc_DA80
		andi.b	#$7F,d0
		move.b	d2,$23(a1)

loc_DA80:
		move.b	d0,0(a1)
		move.b	(a0)+,$28(a1)
		moveq	#0,d0

locret_DA8A:
		rts
; ---------------------------------------------------------------------------
; Single object	loading	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SingleObjLoad:
		lea	($FFFFD800).w,a1 ; start address for object RAM
		move.w	#$5F,d0

loc_DA94:
		tst.b	(a1)		; is object RAM	slot empty?
		beq.s	locret_DAA0	; if yes, branch
		lea	$40(a1),a1	; goto next object RAM slot
		dbf	d0,loc_DA94	; repeat $5F times

locret_DAA0:
		rts
; End of function SingleObjLoad


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SingleObjLoad2:
		movea.l	a0,a1
		move.w	#-$1000,d0
		sub.w	a0,d0
		lsr.w	#6,d0
		subq.w	#1,d0
		bcs.s	locret_DABC

loc_DAB0:
		tst.b	(a1)
		beq.s	locret_DABC
		lea	$40(a1),a1
		dbf	d0,loc_DAB0

locret_DABC:
		rts
; End of function SingleObjLoad2

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 41 - springs
; ---------------------------------------------------------------------------

Obj41:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj41_Index(pc,d0.w),d1
		jsr	Obj41_Index(pc,d1.w)
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================
Obj41_Index:	dc.w Obj41_Main-Obj41_Index
		dc.w Obj41_Up-Obj41_Index
		dc.w Obj41_AniUp-Obj41_Index
		dc.w Obj41_ResetUp-Obj41_Index
		dc.w Obj41_LR-Obj41_Index
		dc.w Obj41_AniLR-Obj41_Index
		dc.w Obj41_ResetLR-Obj41_Index
		dc.w Obj41_Dwn-Obj41_Index
		dc.w Obj41_AniDwn-Obj41_Index
		dc.w Obj41_ResetDwn-Obj41_Index

Obj41_Powers:	dc.w -$1000		; power	of red spring
		dc.w -$A00		; power	of yellow spring
; ===========================================================================

Obj41_Main:				; XREF: Obj41_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj41,4(a0)
		move.w	#$523,2(a0)
		ori.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#4,$18(a0)
		move.b	$28(a0),d0
		btst	#4,d0		; does the spring face left/right?
		beq.s	loc_DB54	; if not, branch
		move.b	#8,$24(a0)	; use "Obj41_LR" routine
		move.b	#1,$1C(a0)
		move.b	#3,$1A(a0)
		move.w	#$533,2(a0)
		move.b	#8,$19(a0)

loc_DB54:
		btst	#5,d0		; does the spring face downwards?
		beq.s	loc_DB66	; if not, branch
		move.b	#$E,$24(a0)	; use "Obj41_Dwn" routine
		bset	#1,$22(a0)

loc_DB66:
		btst	#1,d0
		beq.s	loc_DB72
		bset	#5,2(a0)

loc_DB72:
		andi.w	#$F,d0
		move.w	Obj41_Powers(pc,d0.w),$30(a0)
		rts
; ===========================================================================

Obj41_Up:				; XREF: Obj41_Index
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#$10,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		tst.b	$25(a0)		; is Sonic on top of the spring?
		bne.s	Obj41_BounceUp	; if yes, branch
		rts
; ===========================================================================

Obj41_BounceUp:				; XREF: Obj41_Up
		addq.b	#2,$24(a0)
		addq.w	#8,$C(a1)
		move.w	$30(a0),$12(a1)	; move Sonic upwards
		bset	#1,$22(a1)
		bclr	#3,$22(a1)
		move.b	#$10,$1C(a1)	; use "bouncing" animation
		move.b	#2,$24(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)
		moveq	#sfx_Spring,d0
		jsr	(PlaySound_Special).l ;	play spring sound

Obj41_AniUp:				; XREF: Obj41_Index
		lea	(Ani_obj41).l,a1
		bra.w	AnimateSprite
; ===========================================================================

Obj41_ResetUp:				; XREF: Obj41_Index
		move.b	#1,$1D(a0)	; reset	animation
		subq.b	#4,$24(a0)	; goto "Obj41_Up" routine
		rts
; ===========================================================================

Obj41_LR:				; XREF: Obj41_Index
		move.w	#$13,d1
		move.w	#$E,d2
		move.w	#$F,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		cmpi.b	#2,$24(a0)
		bne.s	loc_DC0C
		move.b	#8,$24(a0)

loc_DC0C:
		btst	#5,$22(a0)
		bne.s	Obj41_BounceLR
		rts
; ===========================================================================

Obj41_BounceLR:				; XREF: Obj41_LR
		addq.b	#2,$24(a0)
		move.w	$30(a0),$10(a1)	; move Sonic to	the left
		addq.w	#8,8(a1)
		btst	#0,$22(a0)	; is object flipped?
		bne.s	loc_DC36	; if yes, branch
		subi.w	#$10,8(a1)
		neg.w	$10(a1)		; move Sonic to	the right

loc_DC36:
		move.w	#$F,$3E(a1)
		move.w	$10(a1),$14(a1)
		bchg	#0,$22(a1)
		btst	#2,$22(a1)
		bne.s	loc_DC56
		move.b	#0,$1C(a1)	; use running animation

loc_DC56:
		bclr	#5,$22(a0)
		bclr	#5,$22(a1)
		moveq	#sfx_Spring,d0
		jsr	(PlaySound_Special).l ;	play spring sound

Obj41_AniLR:				; XREF: Obj41_Index
		lea	(Ani_obj41).l,a1
		bra.w	AnimateSprite
; ===========================================================================

Obj41_ResetLR:				; XREF: Obj41_Index
		move.b	#2,$1D(a0)	; reset	animation
		subq.b	#4,$24(a0)	; goto "Obj41_LR" routine
		rts
; ===========================================================================

Obj41_Dwn:				; XREF: Obj41_Index
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#$10,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		cmpi.b	#2,$24(a0)
		bne.s	loc_DCA4
		move.b	#$E,$24(a0)

loc_DCA4:
		tst.b	$25(a0)
		bne.s	locret_DCAE
		tst.w	d4
		bmi.s	Obj41_BounceDwn

locret_DCAE:
		rts
; ===========================================================================

Obj41_BounceDwn:			; XREF: Obj41_Dwn
		addq.b	#2,$24(a0)
		subq.w	#8,$C(a1)
		move.w	$30(a0),$12(a1)
		neg.w	$12(a1)		; move Sonic downwards
		bset	#1,$22(a1)
		bclr	#3,$22(a1)
		move.b	#2,$24(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)
		moveq	#sfx_Spring,d0
		jsr	(PlaySound_Special).l ;	play spring sound

Obj41_AniDwn:				; XREF: Obj41_Index
		lea	(Ani_obj41).l,a1
		bra.w	AnimateSprite
; ===========================================================================

Obj41_ResetDwn:				; XREF: Obj41_Index
		move.b	#1,$1D(a0)	; reset	animation
		subq.b	#4,$24(a0)	; goto "Obj41_Dwn" routine
		rts
; ===========================================================================
Ani_obj41:
	include "_anim\obj41.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - springs
; ---------------------------------------------------------------------------
Map_obj41:
	include "_maps\obj41.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 42 - Newtron enemy (GHZ)
; ---------------------------------------------------------------------------

Obj42:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj42_Index(pc,d0.w),d1
		jmp	Obj42_Index(pc,d1.w)
; ===========================================================================
Obj42_Index:	dc.w Obj42_Main-Obj42_Index
		dc.w Obj42_Action-Obj42_Index
		dc.w Obj42_Delete-Obj42_Index
; ===========================================================================

Obj42_Main:				; XREF: Obj42_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj42,4(a0)
		move.w	#$49B,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$14,$19(a0)
		move.b	#$10,$16(a0)
		move.b	#8,$17(a0)

Obj42_Action:				; XREF: Obj42_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj42_Index2(pc,d0.w),d1
		jsr	Obj42_Index2(pc,d1.w)
		lea	(Ani_obj42).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj42_Index2:	dc.w Obj42_ChkDist-Obj42_Index2
		dc.w Obj42_Type00-Obj42_Index2
		dc.w Obj42_MatchFloor-Obj42_Index2
		dc.w Obj42_Speed-Obj42_Index2
		dc.w Obj42_Type01-Obj42_Index2
; ===========================================================================

Obj42_ChkDist:				; XREF: Obj42_Index2
		bset	#0,$22(a0)
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_DDEA
		neg.w	d0
		bclr	#0,$22(a0)

loc_DDEA:
		cmpi.w	#$80,d0		; is Sonic within $80 pixels of	the newtron?
		bcc.s	locret_DE12	; if not, branch
		addq.b	#2,$25(a0)
		move.b	#1,$1C(a0)
		tst.b	$28(a0)		; check	object type
		beq.s	locret_DE12	; if type is 00, branch
		move.w	#$249B,2(a0)
		move.b	#8,$25(a0)	; run type 01 newtron subroutine
		move.b	#4,$1C(a0)	; use different	animation

locret_DE12:
		rts
; ===========================================================================

Obj42_Type00:				; XREF: Obj42_Index2
		cmpi.b	#4,$1A(a0)	; has "appearing" animation finished?
		bcc.s	Obj42_Fall	; is yes, branch
		bset	#0,$22(a0)
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bcc.s	locret_DE32
		bclr	#0,$22(a0)

locret_DE32:
		rts
; ===========================================================================

Obj42_Fall:				; XREF: Obj42_Type00
		cmpi.b	#1,$1A(a0)
		bne.s	loc_DE42
		move.b	#$C,$20(a0)

loc_DE42:
		bsr.w	ObjectFall
		bsr.w	ObjHitFloor
		tst.w	d1		; has newtron hit the floor?
		bpl.s	locret_DE86	; if not, branch
		add.w	d1,$C(a0)
		move.w	#0,$12(a0)	; stop newtron falling
		addq.b	#2,$25(a0)
		move.b	#2,$1C(a0)
		btst	#5,2(a0)
		beq.s	Obj42_Move
		addq.b	#1,$1C(a0)

Obj42_Move:
		move.b	#$D,$20(a0)
		move.w	#$200,$10(a0)	; move newtron horizontally
		btst	#0,$22(a0)
		bne.s	locret_DE86
		neg.w	$10(a0)

locret_DE86:
		rts
; ===========================================================================

Obj42_MatchFloor:			; XREF: Obj42_Index2
		bsr.w	SpeedToPos
		bsr.w	ObjHitFloor
		cmpi.w	#-8,d1
		blt.s	loc_DEA2
		cmpi.w	#$C,d1
		bge.s	loc_DEA2
		add.w	d1,$C(a0)	; match	newtron's position with floor
		rts
; ===========================================================================

loc_DEA2:
		addq.b	#2,$25(a0)
		rts
; ===========================================================================

Obj42_Speed:				; XREF: Obj42_Index2
		bsr.w	SpeedToPos
		rts
; ===========================================================================

Obj42_Type01:				; XREF: Obj42_Index2
		cmpi.b	#1,$1A(a0)
		bne.s	Obj42_FireMissile
		move.b	#$C,$20(a0)

Obj42_FireMissile:
		cmpi.b	#2,$1A(a0)
		bne.s	locret_DF14
		tst.b	$32(a0)
		bne.s	locret_DF14
		move.b	#1,$32(a0)
		bsr.w	SingleObjLoad
		bne.s	locret_DF14
		move.b	#$23,0(a1)	; load missile object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		subq.w	#8,$C(a1)
		move.w	#$200,$10(a1)
		move.w	#$14,d0
		btst	#0,$22(a0)
		bne.s	loc_DF04
		neg.w	d0
		neg.w	$10(a1)

loc_DF04:
		add.w	d0,8(a1)
		move.b	$22(a0),$22(a1)
		move.b	#1,$28(a1)

locret_DF14:
		rts
; ===========================================================================

Obj42_Delete:				; XREF: Obj42_Index
		bra.w	DeleteObject
; ===========================================================================
Ani_obj42:
	include "_anim\obj42.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Newtron enemy (GHZ)
; ---------------------------------------------------------------------------
Map_obj42:
	include "_maps\obj42.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 43 - Roller enemy (SYZ)
; ---------------------------------------------------------------------------

Obj43:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj43_Index(pc,d0.w),d1
		jmp	Obj43_Index(pc,d1.w)
; ===========================================================================
Obj43_Index:	dc.w Obj43_Main-Obj43_Index
		dc.w Obj43_Action-Obj43_Index
; ===========================================================================

Obj43_Main:				; XREF: Obj43_Index
		move.b	#$E,$16(a0)
		move.b	#8,$17(a0)
		bsr.w	ObjectFall
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	locret_E052
		add.w	d1,$C(a0)	; match	roller's position with the floor
		move.w	#0,$12(a0)
		addq.b	#2,$24(a0)
		move.l	#Map_obj43,4(a0)
		move.w	#$4B8,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$10,$19(a0)

locret_E052:
		rts
; ===========================================================================

Obj43_Action:				; XREF: Obj43_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj43_Index2(pc,d0.w),d1
		jsr	Obj43_Index2(pc,d1.w)
		lea	(Ani_obj43).l,a1
		bsr.w	AnimateSprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bgt.w	Obj43_ChkGone
		bra.w	DisplaySprite
; ===========================================================================

Obj43_ChkGone:				; XREF: Obj43_Action
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Obj43_Delete
		bclr	#7,2(a2,d0.w)

Obj43_Delete:
		bra.w	DeleteObject
; ===========================================================================
Obj43_Index2:	dc.w Obj43_RollChk-Obj43_Index2
		dc.w Obj43_RollNoChk-Obj43_Index2
		dc.w Obj43_ChkJump-Obj43_Index2
		dc.w Obj43_MatchFloor-Obj43_Index2
; ===========================================================================

Obj43_RollChk:				; XREF: Obj43_Index2
		move.w	($FFFFD008).w,d0
		subi.w	#$100,d0
		bcs.s	loc_E0D2
		sub.w	8(a0),d0	; check	distance between Roller	and Sonic
		bcs.s	loc_E0D2
		addq.b	#4,$25(a0)
		move.b	#2,$1C(a0)
		move.w	#$700,$10(a0)	; move Roller horizontally
		move.b	#$8E,$20(a0)	; make Roller invincible

loc_E0D2:
		addq.l	#4,sp
		rts
; ===========================================================================

Obj43_RollNoChk:			; XREF: Obj43_Index2
		cmpi.b	#2,$1C(a0)
		beq.s	loc_E0F8
		subq.w	#1,$30(a0)
		bpl.s	locret_E0F6
		move.b	#1,$1C(a0)
		move.w	#$700,$10(a0)
		move.b	#$8E,$20(a0)

locret_E0F6:
		rts
; ===========================================================================

loc_E0F8:
		addq.b	#2,$25(a0)
		rts
; ===========================================================================

Obj43_ChkJump:				; XREF: Obj43_Index2
		bsr.w	Obj43_Stop
		bsr.w	SpeedToPos
		bsr.w	ObjHitFloor
		cmpi.w	#-8,d1
		blt.s	Obj43_Jump
		cmpi.w	#$C,d1
		bge.s	Obj43_Jump
		add.w	d1,$C(a0)
		rts
; ===========================================================================

Obj43_Jump:
		addq.b	#2,$25(a0)
		bset	#0,$32(a0)
		beq.s	locret_E12E
		move.w	#-$600,$12(a0)	; move Roller vertically

locret_E12E:
		rts
; ===========================================================================

Obj43_MatchFloor:			; XREF: Obj43_Index2
		bsr.w	ObjectFall
		tst.w	$12(a0)
		bmi.s	locret_E150
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	locret_E150
		add.w	d1,$C(a0)	; match	Roller's position with the floor
		subq.b	#2,$25(a0)
		move.w	#0,$12(a0)

locret_E150:
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj43_Stop:				; XREF: Obj43_ChkJump
		tst.b	$32(a0)
		bmi.s	locret_E188
		move.w	($FFFFD008).w,d0
		subi.w	#$30,d0
		sub.w	8(a0),d0
		bcc.s	locret_E188
		move.b	#0,$1C(a0)
		move.b	#$E,$20(a0)
		clr.w	$10(a0)
		move.w	#120,$30(a0)	; set waiting time to 2	seconds
		move.b	#2,$25(a0)
		bset	#7,$32(a0)

locret_E188:
		rts
; End of function Obj43_Stop

; ===========================================================================
Ani_obj43:
	include "_anim\obj43.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Roller enemy (SYZ)
; ---------------------------------------------------------------------------
Map_obj43:
	include "_maps\obj43.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 44 - walls (GHZ)
; ---------------------------------------------------------------------------

Obj44:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj44_Index(pc,d0.w),d1
		jmp	Obj44_Index(pc,d1.w)
; ===========================================================================
Obj44_Index:	dc.w Obj44_Main-Obj44_Index
		dc.w Obj44_Solid-Obj44_Index
		dc.w Obj44_Display-Obj44_Index
; ===========================================================================

Obj44_Main:				; XREF: Obj44_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj44,4(a0)
		move.w	#$434C,2(a0)
		ori.b	#4,1(a0)
		move.b	#8,$19(a0)
		move.b	#6,$18(a0)
		move.b	$28(a0),$1A(a0)	; copy object type number to frame number
		bclr	#4,$1A(a0)	; clear	4th bit	(deduct	$10)
		beq.s	Obj44_Solid	; make object solid if 4th bit = 0
		addq.b	#2,$24(a0)
		bra.s	Obj44_Display	; don't make it solid if 4th bit = 1
; ===========================================================================

Obj44_Solid:				; XREF: Obj44_Index
		move.w	#$13,d1
		move.w	#$28,d2
		bsr.w	Obj44_SolidWall

Obj44_Display:				; XREF: Obj44_Index
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - walls (GHZ)
; ---------------------------------------------------------------------------
Map_obj44:
	include "_maps\obj44.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 13 - lava ball	producer (MZ, SLZ)
; ---------------------------------------------------------------------------

Obj13:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj13_Index(pc,d0.w),d1
		jsr	Obj13_Index(pc,d1.w)
		bra.w	Obj14_ChkDel
; ===========================================================================
Obj13_Index:	dc.w Obj13_Main-Obj13_Index
		dc.w Obj13_MakeLava-Obj13_Index
; ---------------------------------------------------------------------------
;
; Lava ball production rates
;
Obj13_Rates:	dc.b 30, 60, 90, 120, 150, 180
; ===========================================================================

Obj13_Main:				; XREF: Obj13_Index
		addq.b	#2,$24(a0)
		move.b	$28(a0),d0
		lsr.w	#4,d0
		andi.w	#$F,d0
		move.b	Obj13_Rates(pc,d0.w),$1F(a0)
		move.b	$1F(a0),$1E(a0)	; set time delay for lava balls
		andi.b	#$F,$28(a0)

Obj13_MakeLava:				; XREF: Obj13_Index
		subq.b	#1,$1E(a0)	; subtract 1 from time delay
		bne.s	locret_E302	; if time still	remains, branch
		move.b	$1F(a0),$1E(a0)	; reset	time delay
		bsr.w	ChkObjOnScreen
		bne.s	locret_E302
		bsr.w	SingleObjLoad
		bne.s	locret_E302
		move.b	#$14,0(a1)	; load lava ball object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$28(a0),$28(a1)

locret_E302:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 14 - lava balls (MZ, SLZ)
; ---------------------------------------------------------------------------

Obj14:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj14_Index(pc,d0.w),d1
		jsr	Obj14_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Obj14_Index:	dc.w Obj14_Main-Obj14_Index
		dc.w Obj14_Action-Obj14_Index
		dc.w Obj14_Delete-Obj14_Index

Obj14_Speeds:	dc.w $FC00, $FB00, $FA00, $F900, $FE00
		dc.w $200, $FE00, $200,	0
; ===========================================================================

Obj14_Main:				; XREF: Obj14_Index
		addq.b	#2,$24(a0)
		move.b	#8,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_obj14,4(a0)
		move.w	#$345,2(a0)
		cmpi.b	#3,($FFFFFE10).w ; check if level is SLZ
		bne.s	loc_E35A
		move.w	#$480,2(a0)	; SLZ specific code

loc_E35A:
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$8B,$20(a0)
		move.w	$C(a0),$30(a0)
		tst.b	$29(a0)
		beq.s	Obj14_SetSpeed
		addq.b	#2,$18(a0)

Obj14_SetSpeed:
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	Obj14_Speeds(pc,d0.w),$12(a0) ;	load object speed (vertical)
		move.b	#8,$19(a0)
		cmpi.b	#6,$28(a0)	; is object type below $6 ?
		bcs.s	Obj14_PlaySnd	; if yes, branch
		move.b	#$10,$19(a0)
		move.b	#2,$1C(a0)	; use horizontal animation
		move.w	$12(a0),$10(a0)	; set horizontal speed
		move.w	#0,$12(a0)	; delete vertical speed

Obj14_PlaySnd:
		moveq	#sfx_LavaBall,d0
		jsr	(PlaySound_Special).l ;	play lava ball sound

Obj14_Action:				; XREF: Obj14_Index
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	Obj14_TypeIndex(pc,d0.w),d1
		jsr	Obj14_TypeIndex(pc,d1.w)
		bsr.w	SpeedToPos
		lea	(Ani_obj14).l,a1
		bsr.w	AnimateSprite

Obj14_ChkDel:				; XREF: Obj13
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================
Obj14_TypeIndex:dc.w Obj14_Type00-Obj14_TypeIndex, Obj14_Type00-Obj14_TypeIndex
		dc.w Obj14_Type00-Obj14_TypeIndex, Obj14_Type00-Obj14_TypeIndex
		dc.w Obj14_Type04-Obj14_TypeIndex, Obj14_Type05-Obj14_TypeIndex
		dc.w Obj14_Type06-Obj14_TypeIndex, Obj14_Type07-Obj14_TypeIndex
		dc.w Obj14_Type08-Obj14_TypeIndex
; ===========================================================================
; lavaball types 00-03 fly up and fall back down

Obj14_Type00:				; XREF: Obj14_TypeIndex
		addi.w	#$18,$12(a0)	; increase object's downward speed
		move.w	$30(a0),d0
		cmp.w	$C(a0),d0	; has object fallen back to its	original position?
		bcc.s	loc_E41E	; if not, branch
		addq.b	#2,$24(a0)	; goto "Obj14_Delete" routine

loc_E41E:
		bclr	#1,$22(a0)
		tst.w	$12(a0)
		bpl.s	locret_E430
		bset	#1,$22(a0)

locret_E430:
		rts
; ===========================================================================
; lavaball type	04 flies up until it hits the ceiling

Obj14_Type04:				; XREF: Obj14_TypeIndex
		bset	#1,$22(a0)
		bsr.w	ObjHitCeiling
		tst.w	d1
		bpl.s	locret_E452
		move.b	#8,$28(a0)
		move.b	#1,$1C(a0)
		move.w	#0,$12(a0)	; stop the object when it touches the ceiling

locret_E452:
		rts
; ===========================================================================
; lavaball type	05 falls down until it hits the	floor

Obj14_Type05:				; XREF: Obj14_TypeIndex
		bclr	#1,$22(a0)
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	locret_E474
		move.b	#8,$28(a0)
		move.b	#1,$1C(a0)
		move.w	#0,$12(a0)	; stop the object when it touches the floor

locret_E474:
		rts
; ===========================================================================
; lavaball types 06-07 move sideways

Obj14_Type06:				; XREF: Obj14_TypeIndex
		bset	#0,$22(a0)
		moveq	#-8,d3
		bsr.w	ObjHitWallLeft
		tst.w	d1
		bpl.s	locret_E498
		move.b	#8,$28(a0)
		move.b	#3,$1C(a0)
		move.w	#0,$10(a0)	; stop object when it touches a	wall

locret_E498:
		rts
; ===========================================================================

Obj14_Type07:				; XREF: Obj14_TypeIndex
		bclr	#0,$22(a0)
		moveq	#8,d3
		bsr.w	ObjHitWallRight
		tst.w	d1
		bpl.s	locret_E4BC
		move.b	#8,$28(a0)
		move.b	#3,$1C(a0)
		move.w	#0,$10(a0)	; stop object when it touches a	wall

locret_E4BC:
		rts
; ===========================================================================

Obj14_Type08:				; XREF: Obj14_TypeIndex
		rts
; ===========================================================================

Obj14_Delete:				; XREF: Obj14_Index
		bra.w	DeleteObject
; ===========================================================================
Ani_obj14:
	include "_anim\obj14.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 6D - flame thrower (SBZ)
; ---------------------------------------------------------------------------

Obj6D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj6D_Index(pc,d0.w),d1
		jmp	Obj6D_Index(pc,d1.w)
; ===========================================================================
Obj6D_Index:	dc.w Obj6D_Main-Obj6D_Index
		dc.w Obj6D_Action-Obj6D_Index
; ===========================================================================

Obj6D_Main:				; XREF: Obj6D_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj6D,4(a0)
		move.w	#$83D9,2(a0)
		ori.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.w	$C(a0),$30(a0)
		move.b	#$C,$19(a0)
		move.b	$28(a0),d0
		andi.w	#$F0,d0		; read 1st digit of object type
		add.w	d0,d0		; multiply by 2
		move.w	d0,$30(a0)
		move.w	d0,$32(a0)	; set flaming time
		move.b	$28(a0),d0
		andi.w	#$F,d0		; read 2nd digit of object type
		lsl.w	#5,d0		; multiply by $20
		move.w	d0,$34(a0)	; set pause time
		move.b	#$A,$36(a0)
		btst	#1,$22(a0)
		beq.s	Obj6D_Action
		move.b	#2,$1C(a0)
		move.b	#$15,$36(a0)

Obj6D_Action:				; XREF: Obj6D_Index
		subq.w	#1,$30(a0)	; subtract 1 from time
		bpl.s	loc_E57A	; if time remains, branch
		move.w	$34(a0),$30(a0)	; begin	pause time
		bchg	#0,$1C(a0)
		beq.s	loc_E57A
		move.w	$32(a0),$30(a0)	; begin	flaming	time
		moveq	#sfx_Flame,d0
		jsr	(PlaySound_Special).l ;	play flame sound

loc_E57A:
		lea	(Ani_obj6D).l,a1
		bsr.w	AnimateSprite
		move.b	#0,$20(a0)
		move.b	$36(a0),d0
		cmp.b	$1A(a0),d0
		bne.s	Obj6D_ChkDel
		move.b	#$A3,$20(a0)

Obj6D_ChkDel:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Ani_obj6D:
	include "_anim\obj6D.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - flame thrower (SBZ)
; ---------------------------------------------------------------------------
Map_obj6D:
	include "_maps\obj6D.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 46 - solid blocks and blocks that fall	from the ceiling (MZ)
; ---------------------------------------------------------------------------

Obj46:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj46_Index(pc,d0.w),d1
		jmp	Obj46_Index(pc,d1.w)
; ===========================================================================
Obj46_Index:	dc.w Obj46_Main-Obj46_Index
		dc.w Obj46_Action-Obj46_Index
; ===========================================================================

Obj46_Main:				; XREF: Obj46_Index
		addq.b	#2,$24(a0)
		move.b	#$F,$16(a0)
		move.b	#$F,$17(a0)
		move.l	#Map_obj46,4(a0)
		move.w	#$4000,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$10,$19(a0)
		move.w	$C(a0),$30(a0)
		move.w	#$5C0,$32(a0)

Obj46_Action:				; XREF: Obj46_Index
		tst.b	1(a0)
		bpl.s	Obj46_ChkDel
		moveq	#0,d0
		move.b	$28(a0),d0	; get object type
		andi.w	#7,d0		; read only the	1st digit
		add.w	d0,d0
		move.w	Obj46_TypeIndex(pc,d0.w),d1
		jsr	Obj46_TypeIndex(pc,d1.w)
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	8(a0),d4
		bsr.w	SolidObject

Obj46_ChkDel:
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================
Obj46_TypeIndex:dc.w Obj46_Type00-Obj46_TypeIndex
		dc.w Obj46_Type01-Obj46_TypeIndex
		dc.w Obj46_Type02-Obj46_TypeIndex
		dc.w Obj46_Type03-Obj46_TypeIndex
		dc.w Obj46_Type04-Obj46_TypeIndex
; ===========================================================================

Obj46_Type00:				; XREF: Obj46_TypeIndex
		rts
; ===========================================================================

Obj46_Type02:				; XREF: Obj46_TypeIndex
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_E888
		neg.w	d0

loc_E888:
		cmpi.w	#$90,d0		; is Sonic within $90 pixels of	the block?
		bcc.s	Obj46_Type01	; if not, resume wobbling
		move.b	#3,$28(a0)	; if yes, make the block fall

Obj46_Type01:				; XREF: Obj46_TypeIndex
		moveq	#0,d0
		move.b	($FFFFFE74).w,d0
		btst	#3,$28(a0)
		beq.s	loc_E8A8
		neg.w	d0
		addi.w	#$10,d0

loc_E8A8:
		move.w	$30(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)	; update the block's position to make it wobble
		rts
; ===========================================================================

Obj46_Type03:				; XREF: Obj46_TypeIndex
		bsr.w	SpeedToPos
		addi.w	#$18,$12(a0)	; increase falling speed
		bsr.w	ObjHitFloor
		tst.w	d1		; has the block	hit the	floor?
		bpl.w	locret_E8EE	; if not, branch
		add.w	d1,$C(a0)
		clr.w	$12(a0)		; stop the block falling
		move.w	$C(a0),$30(a0)
		move.b	#4,$28(a0)
		move.w	(a1),d0
		andi.w	#$3FF,d0
		cmpi.w	#$2E8,d0
		bcc.s	locret_E8EE
		move.b	#0,$28(a0)

locret_E8EE:
		rts
; ===========================================================================

Obj46_Type04:				; XREF: Obj46_TypeIndex
		moveq	#0,d0
		move.b	($FFFFFE70).w,d0
		lsr.w	#3,d0
		move.w	$30(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)	; make the block wobble
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - solid blocks and blocks that fall from the ceiling (MZ)
; ---------------------------------------------------------------------------
Map_obj46:
	include "_maps\obj46.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 12 - lamp (SYZ)
; ---------------------------------------------------------------------------

Obj12:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj12_Index(pc,d0.w),d1
		jmp	Obj12_Index(pc,d1.w)
; ===========================================================================
Obj12_Index:	dc.w Obj12_Main-Obj12_Index
		dc.w Obj12_Animate-Obj12_Index
; ===========================================================================

Obj12_Main:				; XREF: Obj12_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj12,4(a0)
		move.w	#0,2(a0)
		move.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#6,$18(a0)

Obj12_Animate:				; XREF: Obj12_Index
		subq.b	#1,$1E(a0)
		bpl.s	Obj12_ChkDel
		move.b	#7,$1E(a0)
		addq.b	#1,$1A(a0)
		cmpi.b	#6,$1A(a0)
		bcs.s	Obj12_ChkDel
		move.b	#0,$1A(a0)

Obj12_ChkDel:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - lamp (SYZ)
; ---------------------------------------------------------------------------
Map_obj12:
	include "_maps\obj12.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 47 - pinball bumper (SYZ)
; ---------------------------------------------------------------------------

Obj47:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj47_Index(pc,d0.w),d1
		jmp	Obj47_Index(pc,d1.w)
; ===========================================================================
Obj47_Index:	dc.w Obj47_Main-Obj47_Index
		dc.w Obj47_Hit-Obj47_Index
; ===========================================================================

Obj47_Main:				; XREF: Obj47_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj47,4(a0)
		move.w	#$380,2(a0)
		move.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#1,$18(a0)
		move.b	#$D7,$20(a0)

Obj47_Hit:				; XREF: Obj47_Index
		tst.b	$21(a0)		; has Sonic touched the	bumper?
		beq.w	Obj47_Display	; if not, branch
		clr.b	$21(a0)
		lea	($FFFFD000).w,a1
		move.w	8(a0),d1
		move.w	$C(a0),d2
		sub.w	8(a1),d1
		sub.w	$C(a1),d2
		jsr	(CalcAngle).l
		jsr	(CalcSine).l
		muls.w	#-$700,d1
		asr.l	#8,d1
		move.w	d1,$10(a1)	; bounce Sonic away
		muls.w	#-$700,d0
		asr.l	#8,d0
		move.w	d0,$12(a1)	; bounce Sonic away
		bset	#1,$22(a1)
		bclr	#4,$22(a1)
		bclr	#5,$22(a1)
		clr.b	$3C(a1)
		move.b	#1,$1C(a0)
		moveq	#sfx_Bumper,d0
		jsr	(PlaySound_Special).l ;	play bumper sound
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Obj47_Score
		cmpi.b	#$8A,2(a2,d0.w)	; has bumper been hit $8A times?
		bcc.s	Obj47_Display	; if yes, Sonic	gets no	points
		addq.b	#1,2(a2,d0.w)

Obj47_Score:
		moveq	#1,d0
		jsr	AddPoints	; add 10 to score
		bsr.w	SingleObjLoad
		bne.s	Obj47_Display
		move.b	#$29,0(a1)	; load points object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#4,$1A(a1)

Obj47_Display:
		lea	(Ani_obj47).l,a1
		bsr.w	AnimateSprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj47_ChkHit
		bra.w	DisplaySprite
; ===========================================================================

Obj47_ChkHit:				; XREF: Obj47_Display
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Obj47_Delete
		bclr	#7,2(a2,d0.w)

Obj47_Delete:
		bra.w	DeleteObject
; ===========================================================================
Ani_obj47:
	include "_anim\obj47.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - pinball bumper (SYZ)
; ---------------------------------------------------------------------------
Map_obj47:
	include "_maps\obj47.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0D - signpost at the end of a level
; ---------------------------------------------------------------------------

Obj0D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj0D_Index(pc,d0.w),d1
		jsr	Obj0D_Index(pc,d1.w)
		lea	(Ani_obj0D).l,a1
		bsr.w	AnimateSprite
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================
Obj0D_Index:	dc.w Obj0D_Main-Obj0D_Index
		dc.w Obj0D_Touch-Obj0D_Index
		dc.w Obj0D_Spin-Obj0D_Index
		dc.w Obj0D_SonicRun-Obj0D_Index
		dc.w locret_ED1A-Obj0D_Index
; ===========================================================================

Obj0D_Main:				; XREF: Obj0D_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj0D,4(a0)
		move.w	#$680,2(a0)
		move.b	#4,1(a0)
		move.b	#$18,$19(a0)
		move.b	#4,$18(a0)

Obj0D_Touch:				; XREF: Obj0D_Index
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bcs.s	locret_EBBA
		cmpi.w	#$20,d0		; is Sonic within $20 pixels of	the signpost?
		bcc.s	locret_EBBA	; if not, branch
		moveq	#sfx_Signpost,d0
		jsr	PlaySound_Special	; play signpost	sound
		clr.b	($FFFFFE1E).w	; stop time counter
		move.w	($FFFFF72A).w,($FFFFF728).w ; lock screen position
		addq.b	#2,$24(a0)

locret_EBBA:
		rts
; ===========================================================================

Obj0D_Spin:				; XREF: Obj0D_Index
		subq.w	#1,$30(a0)	; subtract 1 from spin time
		bpl.s	Obj0D_Sparkle	; if time remains, branch
		move.w	#60,$30(a0)	; set spin cycle time to 1 second
		addq.b	#1,$1C(a0)	; next spin cycle
		cmpi.b	#3,$1C(a0)	; have 3 spin cycles completed?
		bne.s	Obj0D_Sparkle	; if not, branch
		addq.b	#2,$24(a0)

Obj0D_Sparkle:
		subq.w	#1,$32(a0)	; subtract 1 from time delay
		bpl.s	locret_EC42	; if time remains, branch
		move.w	#$B,$32(a0)	; set time between sparkles to $B frames
		moveq	#0,d0
		move.b	$34(a0),d0
		addq.b	#2,$34(a0)
		andi.b	#$E,$34(a0)
		lea	Obj0D_SparkPos(pc,d0.w),a2 ; load sparkle position data
		bsr.w	SingleObjLoad
		bne.s	locret_EC42
		move.b	#$25,0(a1)	; load rings object
		move.b	#6,$24(a1)	; jump to ring sparkle subroutine
		move.b	(a2)+,d0
		ext.w	d0
		add.w	8(a0),d0
		move.w	d0,8(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	$C(a0),d0
		move.w	d0,$C(a1)
		move.l	#Map_obj25,4(a1)
		move.w	#$27B2,2(a1)
		move.b	#4,1(a1)
		move.b	#2,$18(a1)
		move.b	#8,$19(a1)

locret_EC42:
		rts
; ===========================================================================
Obj0D_SparkPos:	dc.b -$18,-$10		; x-position, y-position
		dc.b	8,   8
		dc.b -$10,   0
		dc.b  $18,  -8
		dc.b	0,  -8
		dc.b  $10,   0
		dc.b -$18,   8
		dc.b  $18, $10
; ===========================================================================

Obj0D_SonicRun:				; XREF: Obj0D_Index
		tst.w	($FFFFFE08).w	; is debug mode	on?
		bne.s	locret_EC42	; if yes, branch
		btst	#1,($FFFFD022).w
		bne.s	loc_EC70
		move.b	#1,($FFFFF7CC).w ; lock	controls
		move.w	#$800,($FFFFF602).w ; make Sonic run to	the right

loc_EC70:
		tst.b	($FFFFD000).w
		beq.s	loc_EC86
		move.w	($FFFFD008).w,d0
		move.w	($FFFFF72A).w,d1
		addi.w	#$128,d1
		cmp.w	d1,d0
		bcs.s	locret_EC42

loc_EC86:
		addq.b	#2,$24(a0)

; ---------------------------------------------------------------------------
; Subroutine to	set up bonuses at the end of an	act
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


GotThroughAct:				; XREF: Obj3E_EndAct
		tst.b	($FFFFD5C0).w
		bne.s	locret_ED1A
		move.w	($FFFFF72A).w,($FFFFF728).w
		clr.b	($FFFFFE2D).w	; disable invincibility
		clr.b	($FFFFFE1E).w	; stop time counter
		move.b	#$3A,($FFFFD5C0).w
		moveq	#$10,d0
		jsr	(LoadPLC2).l	; load title card patterns
		move.b	#1,($FFFFF7D6).w
		moveq	#0,d0
		move.b	($FFFFFE23).w,d0
		mulu.w	#60,d0		; convert minutes to seconds
		moveq	#0,d1
		move.b	($FFFFFE24).w,d1
		add.w	d1,d0		; add up your time
		divu.w	#15,d0		; divide by 15
		moveq	#$14,d1
		cmp.w	d1,d0		; is time 5 minutes or higher?
		bcs.s	loc_ECD0	; if not, branch
		move.w	d1,d0		; use minimum time bonus (0)

loc_ECD0:
		add.w	d0,d0
		move.w	TimeBonuses(pc,d0.w),($FFFFF7D2).w ; set time bonus
		move.w	($FFFFFE20).w,d0 ; load	number of rings
		mulu.w	#10,d0		; multiply by 10
		move.w	d0,($FFFFF7D4).w ; set ring bonus
		moveq	#mus_GotThroughAct,d0
		jmp	PlaySound_Special ;	play "Sonic got	through" music

; ===========================================================================

locret_ED1A:				; XREF: Obj0D_Index
		rts

; ===========================================================================
TimeBonuses:	dc.w 5000, 5000, 1000, 500, 400, 400, 300, 300,	200, 200
		dc.w 200, 200, 100, 100, 100, 100, 50, 50, 50, 50, 0
; ===========================================================================
Ani_obj0D:
	include "_anim\obj0D.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - signpost
; ---------------------------------------------------------------------------
Map_obj0D:
	include "_maps\obj0D.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4C - lava geyser / lavafall producer (MZ)
; ---------------------------------------------------------------------------

Obj4C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj4C_Index(pc,d0.w),d1
		jsr	Obj4C_Index(pc,d1.w)
		bra.w	Obj4D_ChkDel
; ===========================================================================
Obj4C_Index:	dc.w Obj4C_Main-Obj4C_Index
		dc.w loc_EDCC-Obj4C_Index
		dc.w loc_EE3E-Obj4C_Index
		dc.w Obj4C_MakeLava-Obj4C_Index
		dc.w Obj4C_Display-Obj4C_Index
		dc.w Obj4C_Delete-Obj4C_Index
; ===========================================================================

Obj4C_Main:				; XREF: Obj4C_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj4C,4(a0)
		move.w	#$E3A8,2(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#$38,$19(a0)
		move.w	#120,$34(a0)	; set time delay to 2 seconds

loc_EDCC:				; XREF: Obj4C_Index
		subq.w	#1,$32(a0)
		bpl.s	locret_EDF0
		move.w	$34(a0),$32(a0)
		move.w	($FFFFD00C).w,d0
		move.w	$C(a0),d1
		cmp.w	d1,d0
		bcc.s	locret_EDF0
		subi.w	#$170,d1
		cmp.w	d1,d0
		bcs.s	locret_EDF0
		addq.b	#2,$24(a0)

locret_EDF0:
		rts
; ===========================================================================

Obj4C_MakeLava:				; XREF: Obj4C_Index
		addq.b	#2,$24(a0)
		bsr.w	SingleObjLoad2
		bne.s	loc_EE18
		move.b	#$4D,0(a1)	; load lavafall	object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$28(a0),$28(a1)
		move.l	a0,$3C(a1)

loc_EE18:
		move.b	#1,$1C(a0)
		tst.b	$28(a0)		; is object type 00 (geyser) ?
		beq.s	Obj4C_Type00	; if yes, branch
		move.b	#4,$1C(a0)
		bra.s	Obj4C_Display
; ===========================================================================

Obj4C_Type00:				; XREF: Obj4C_MakeLava
		movea.l	$3C(a0),a1	; load geyser object
		bset	#1,$22(a1)
		move.w	#-$580,$12(a1)
		bra.s	Obj4C_Display
; ===========================================================================

loc_EE3E:				; XREF: Obj4C_Index
		tst.b	$28(a0)		; is object type 00 (geyser) ?
		beq.s	Obj4C_Display	; if yes, branch
		addq.b	#2,$24(a0)
		rts
; ===========================================================================

Obj4C_Display:				; XREF: Obj4C_Index
		lea	(Ani_obj4C).l,a1
		bsr.w	AnimateSprite
		bsr.w	DisplaySprite
		rts
; ===========================================================================

Obj4C_Delete:				; XREF: Obj4C_Index
		move.b	#0,$1C(a0)
		move.b	#2,$24(a0)
		tst.b	$28(a0)
		beq.w	DeleteObject
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4D - lava geyser / lavafall (MZ)
; ---------------------------------------------------------------------------

Obj4D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj4D_Index(pc,d0.w),d1
		jsr	Obj4D_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Obj4D_Index:	dc.w Obj4D_Main-Obj4D_Index
		dc.w Obj4D_Action-Obj4D_Index
		dc.w loc_EFFC-Obj4D_Index
		dc.w Obj4D_Delete-Obj4D_Index

Obj4D_Speeds:	dc.w $FB00, 0
; ===========================================================================

Obj4D_Main:				; XREF: Obj4D_Index
		addq.b	#2,$24(a0)
		move.w	$C(a0),$30(a0)
		tst.b	$28(a0)
		beq.s	loc_EEA4
		subi.w	#$250,$C(a0)

loc_EEA4:
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	Obj4D_Speeds(pc,d0.w),$12(a0)
		movea.l	a0,a1
		moveq	#1,d1
		bsr.s	Obj4D_MakeLava
		bra.s	loc_EF10
; ===========================================================================

Obj4D_Loop:
		bsr.w	SingleObjLoad2
		bne.s	loc_EF0A

Obj4D_MakeLava:				; XREF: Obj4D_Main
		move.b	#$4D,0(a1)
		move.l	#Map_obj4C,4(a1)
		move.w	#$63A8,2(a1)
		move.b	#4,1(a1)
		move.b	#$20,$19(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$28(a0),$28(a1)
		move.b	#1,$18(a1)
		move.b	#5,$1C(a1)
		tst.b	$28(a0)
		beq.s	loc_EF0A
		move.b	#2,$1C(a1)

loc_EF0A:
		dbf	d1,Obj4D_Loop
		rts
; ===========================================================================

loc_EF10:				; XREF: Obj4D_Main
		addi.w	#$60,$C(a1)
		move.w	$30(a0),$30(a1)
		addi.w	#$60,$30(a1)
		move.b	#$93,$20(a1)
		move.b	#$80,$16(a1)
		bset	#4,1(a1)
		addq.b	#4,$24(a1)
		move.l	a0,$3C(a1)
		tst.b	$28(a0)
		beq.s	Obj4D_PlaySnd
		moveq	#0,d1
		bsr.w	Obj4D_Loop
		addq.b	#2,$24(a1)
		bset	#4,2(a1)
		addi.w	#$100,$C(a1)
		move.b	#0,$18(a1)
		move.w	$30(a0),$30(a1)
		move.l	$3C(a0),$3C(a1)
		move.b	#0,$28(a0)

Obj4D_PlaySnd:
		moveq	#sfx_Lava,d0
		jsr	(PlaySound_Special).l ;	play flame sound

Obj4D_Action:				; XREF: Obj4D_Index
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	Obj4D_TypeIndex(pc,d0.w),d1
		jsr	Obj4D_TypeIndex(pc,d1.w)
		bsr.w	SpeedToPos
		lea	(Ani_obj4C).l,a1
		bsr.w	AnimateSprite

Obj4D_ChkDel:				; XREF: Obj4C
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================
Obj4D_TypeIndex:dc.w Obj4D_Type00-Obj4D_TypeIndex
		dc.w Obj4D_Type01-Obj4D_TypeIndex
; ===========================================================================

Obj4D_Type00:				; XREF: Obj4D_TypeIndex
		addi.w	#$18,$12(a0)	; increase object's falling speed
		move.w	$30(a0),d0
		cmp.w	$C(a0),d0
		bcc.s	locret_EFDA
		addq.b	#4,$24(a0)
		movea.l	$3C(a0),a1
		move.b	#3,$1C(a1)

locret_EFDA:
		rts
; ===========================================================================

Obj4D_Type01:				; XREF: Obj4D_TypeIndex
		addi.w	#$18,$12(a0)	; increase object's falling speed
		move.w	$30(a0),d0
		cmp.w	$C(a0),d0
		bcc.s	locret_EFFA
		addq.b	#4,$24(a0)
		movea.l	$3C(a0),a1
		move.b	#1,$1C(a1)

locret_EFFA:
		rts
; ===========================================================================

loc_EFFC:				; XREF: Obj4D_Index
		movea.l	$3C(a0),a1
		cmpi.b	#6,$24(a1)
		beq.w	Obj4D_Delete
		move.w	$C(a1),d0
		addi.w	#$60,d0
		move.w	d0,$C(a0)
		sub.w	$30(a0),d0
		neg.w	d0
		moveq	#8,d1
		cmpi.w	#$40,d0
		bge.s	loc_F026
		moveq	#$B,d1

loc_F026:
		cmpi.w	#$80,d0
		ble.s	loc_F02E
		moveq	#$E,d1

loc_F02E:
		subq.b	#1,$1E(a0)
		bpl.s	loc_F04C
		move.b	#7,$1E(a0)
		addq.b	#1,$1B(a0)
		cmpi.b	#2,$1B(a0)
		bcs.s	loc_F04C
		move.b	#0,$1B(a0)

loc_F04C:
		move.b	$1B(a0),d0
		add.b	d1,d0
		move.b	d0,$1A(a0)
		bra.w	Obj4D_ChkDel
; ===========================================================================

Obj4D_Delete:				; XREF: Obj4D_Index
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4E - advancing	wall of	lava (MZ)
; ---------------------------------------------------------------------------

Obj4E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj4E_Index(pc,d0.w),d1
		jmp	Obj4E_Index(pc,d1.w)
; ===========================================================================
Obj4E_Index:	dc.w Obj4E_Main-Obj4E_Index
		dc.w Obj4E_Solid-Obj4E_Index
		dc.w Obj4E_Action-Obj4E_Index
		dc.w Obj4E_Move2-Obj4E_Index
		dc.w Obj4E_Delete-Obj4E_Index
; ===========================================================================

Obj4E_Main:				; XREF: Obj4E_Index
		addq.b	#4,$24(a0)
		movea.l	a0,a1
		moveq	#1,d1
		bra.s	Obj4E_Main2
; ===========================================================================

Obj4E_Loop:
		bsr.w	SingleObjLoad2
		bne.s	loc_F0C8

Obj4E_Main2:				; XREF: Obj4E_Main
		move.b	#$4E,0(a1)	; load object
		move.l	#Map_obj4E,4(a1)
		move.w	#$63A8,2(a1)
		move.b	#4,1(a1)
		move.b	#$50,$19(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#1,$18(a1)
		move.b	#0,$1C(a1)
		move.b	#$94,$20(a1)
		move.l	a0,$3C(a1)

loc_F0C8:
		dbf	d1,Obj4E_Loop	; repeat sequence once

		addq.b	#6,$24(a1)
		move.b	#4,$1A(a1)

Obj4E_Action:				; XREF: Obj4E_Index
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bcc.s	Obj4E_ChkSonic
		neg.w	d0

Obj4E_ChkSonic:
		cmpi.w	#$C0,d0		; is Sonic within $C0 pixels (x-axis)?
		bcc.s	Obj4E_Move	; if not, branch
		move.w	($FFFFD00C).w,d0
		sub.w	$C(a0),d0
		bcc.s	loc_F0F4
		neg.w	d0

loc_F0F4:
		cmpi.w	#$60,d0		; is Sonic within $60 pixels (y-axis)?
		bcc.s	Obj4E_Move	; if not, branch
		move.b	#1,$36(a0)	; set object to	move
		bra.s	Obj4E_Solid
; ===========================================================================

Obj4E_Move:				; XREF: Obj4E_ChkSonic
		tst.b	$36(a0)		; is object set	to move?
		beq.s	Obj4E_Solid	; if not, branch
		move.w	#$180,$10(a0)	; set object speed
		subq.b	#2,$24(a0)

Obj4E_Solid:				; XREF: Obj4E_Index
		move.w	#$2B,d1
		move.w	#$18,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	8(a0),d4
		move.b	$24(a0),d0
		move.w	d0,-(sp)
		bsr.w	SolidObject
		move.w	(sp)+,d0
		move.b	d0,$24(a0)
		cmpi.w	#$6A0,8(a0)	; has object reached $6A0 on the x-axis?
		bne.s	Obj4E_Animate	; if not, branch
		clr.w	$10(a0)		; stop object moving
		clr.b	$36(a0)

Obj4E_Animate:
		lea	(Ani_obj4E).l,a1
		bsr.w	AnimateSprite
		cmpi.b	#4,($FFFFD024).w
		bcc.s	Obj4E_ChkDel
		bsr.w	SpeedToPos

Obj4E_ChkDel:
		bsr.w	DisplaySprite
		tst.b	$36(a0)
		bne.s	locret_F17E
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj4E_ChkGone

locret_F17E:
		rts
; ===========================================================================

Obj4E_ChkGone:				; XREF: Obj4E_ChkDel
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		bclr	#7,2(a2,d0.w)
		move.b	#8,$24(a0)
		rts
; ===========================================================================

Obj4E_Move2:				; XREF: Obj4E_Index
		movea.l	$3C(a0),a1
		cmpi.b	#8,$24(a1)
		beq.s	Obj4E_Delete
		move.w	8(a1),8(a0)	; move rest of lava wall
		subi.w	#$80,8(a0)
		bra.w	DisplaySprite
; ===========================================================================

Obj4E_Delete:				; XREF: Obj4E_Index
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 54 - invisible	lava tag (MZ)
; ---------------------------------------------------------------------------

Obj54:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj54_Index(pc,d0.w),d1
		jmp	Obj54_Index(pc,d1.w)
; ===========================================================================
Obj54_Index:	dc.w Obj54_Main-Obj54_Index
		dc.w Obj54_ChkDel-Obj54_Index

Obj54_Sizes:	dc.b $96, $94, $95, 0
; ===========================================================================

Obj54_Main:				; XREF: Obj54_Index
		addq.b	#2,$24(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		move.b	Obj54_Sizes(pc,d0.w),$20(a0)
		move.l	#Map_obj54,4(a0)
		move.b	#$84,1(a0)

Obj54_ChkDel:				; XREF: Obj54_Index
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		bmi.w	DeleteObject
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - invisible lava tag (MZ)
; ---------------------------------------------------------------------------
Map_obj54:
	include "_maps\obj54.asm"

Ani_obj4C:
	include "_anim\obj4C.asm"

Ani_obj4E:
	include "_anim\obj4E.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - lava geyser / lava that falls from the ceiling (MZ)
; ---------------------------------------------------------------------------
Map_obj4C:
	include "_maps\obj4C.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - advancing wall of lava (MZ)
; ---------------------------------------------------------------------------
Map_obj4E:
	include "_maps\obj4E.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 40 - Moto Bug enemy (GHZ)
; ---------------------------------------------------------------------------

Obj40:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj40_Index(pc,d0.w),d1
		jmp	Obj40_Index(pc,d1.w)
; ===========================================================================
Obj40_Index:	dc.w Obj40_Main-Obj40_Index
		dc.w Obj40_Action-Obj40_Index
		dc.w Obj40_Animate-Obj40_Index
		dc.w Obj40_Delete-Obj40_Index
; ===========================================================================

Obj40_Main:				; XREF: Obj40_Index
		move.l	#Map_obj40,4(a0)
		move.w	#$4F0,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$14,$19(a0)
		tst.b	$1C(a0)		; is object a smoke trail?
		bne.s	Obj40_SetSmoke	; if yes, branch
		move.b	#$E,$16(a0)
		move.b	#8,$17(a0)
		move.b	#$C,$20(a0)
		bsr.w	ObjectFall
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	locret_F68A
		add.w	d1,$C(a0)	; match	object's position with the floor
		move.w	#0,$12(a0)
		addq.b	#2,$24(a0)
		bchg	#0,$22(a0)

locret_F68A:
		rts
; ===========================================================================

Obj40_SetSmoke:				; XREF: Obj40_Main
		addq.b	#4,$24(a0)
		bra.w	Obj40_Animate
; ===========================================================================

Obj40_Action:				; XREF: Obj40_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj40_Index2(pc,d0.w),d1
		jsr	Obj40_Index2(pc,d1.w)
		lea	(Ani_obj40).l,a1
		bsr.w	AnimateSprite

; ---------------------------------------------------------------------------
; Routine to mark an enemy/monitor/ring	as destroyed
; ---------------------------------------------------------------------------

MarkObjGone:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Mark_ChkGone
		bra.w	DisplaySprite
; ===========================================================================

Mark_ChkGone:
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Mark_Delete
		bclr	#7,2(a2,d0.w)

Mark_Delete:
		bra.w	DeleteObject

; ===========================================================================
Obj40_Index2:	dc.w Obj40_Move-Obj40_Index2
		dc.w Obj40_FixToFloor-Obj40_Index2
; ===========================================================================

Obj40_Move:				; XREF: Obj40_Index2
		subq.w	#1,$30(a0)	; subtract 1 from pause	time
		bpl.s	locret_F70A	; if time remains, branch
		addq.b	#2,$25(a0)
		move.w	#-$100,$10(a0)	; move object to the left
		move.b	#1,$1C(a0)
		bchg	#0,$22(a0)
		bne.s	locret_F70A
		neg.w	$10(a0)		; change direction

locret_F70A:
		rts
; ===========================================================================

Obj40_FixToFloor:			; XREF: Obj40_Index2
		bsr.w	SpeedToPos
		jsr	ObjHitFloor
		cmpi.w	#-8,d1
		blt.s	Obj40_Pause
		cmpi.w	#$C,d1
		bge.s	Obj40_Pause
		add.w	d1,$C(a0)	; match	object's position with the floor
		subq.b	#1,$33(a0)
		bpl.s	locret_F756
		move.b	#$F,$33(a0)
		bsr.w	SingleObjLoad
		bne.s	locret_F756
		move.b	#$40,0(a1)	; load exhaust smoke object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$22(a0),$22(a1)
		move.b	#2,$1C(a1)

locret_F756:
		rts
; ===========================================================================

Obj40_Pause:				; XREF: Obj40_FixToFloor
		subq.b	#2,$25(a0)
		move.w	#59,$30(a0)	; set pause time to 1 second
		move.w	#0,$10(a0)	; stop the object moving
		move.b	#0,$1C(a0)
		rts
; ===========================================================================

Obj40_Animate:				; XREF: Obj40_Index
		lea	(Ani_obj40).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Obj40_Delete:				; XREF: Obj40_Index
		bra.w	DeleteObject
; ===========================================================================
Ani_obj40:
	include "_anim\obj40.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Moto Bug enemy (GHZ)
; ---------------------------------------------------------------------------
Map_obj40:
	include "_maps\obj40.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4F - blank
; ---------------------------------------------------------------------------

Obj4F:					; XREF: Obj_Index
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj50_ChkWall:				; XREF: Obj50_FixToFloor
		move.w	($FFFFFE04).w,d0
		add.w	d7,d0
		andi.w	#3,d0
		bne.s	loc_F836
		moveq	#0,d3
		move.b	$19(a0),d3
		tst.w	$10(a0)
		bmi.s	loc_F82C
		bsr.w	ObjHitWallRight
		tst.w	d1
		bpl.s	loc_F836

loc_F828:
		moveq	#1,d0
		rts
; ===========================================================================

loc_F82C:
		not.w	d3
		bsr.w	ObjHitWallLeft
		tst.w	d1
		bmi.s	loc_F828

loc_F836:
		moveq	#0,d0
		rts
; End of function Obj50_ChkWall

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 50 - Yadrin enemy (SYZ)
; ---------------------------------------------------------------------------

Obj50:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj50_Index(pc,d0.w),d1
		jmp	Obj50_Index(pc,d1.w)
; ===========================================================================
Obj50_Index:	dc.w Obj50_Main-Obj50_Index
		dc.w Obj50_Action-Obj50_Index
; ===========================================================================

Obj50_Main:				; XREF: Obj50_Index
		move.l	#Map_obj50,4(a0)
		move.w	#$247B,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$14,$19(a0)
		move.b	#$11,$16(a0)
		move.b	#8,$17(a0)
		move.b	#$CC,$20(a0)
		bsr.w	ObjectFall
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	locret_F89E
		add.w	d1,$C(a0)	; match	object's position with the floor
		move.w	#0,$12(a0)
		addq.b	#2,$24(a0)
		bchg	#0,$22(a0)

locret_F89E:
		rts
; ===========================================================================

Obj50_Action:				; XREF: Obj50_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj50_Index2(pc,d0.w),d1
		jsr	Obj50_Index2(pc,d1.w)
		lea	(Ani_obj50).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj50_Index2:	dc.w Obj50_Move-Obj50_Index2
		dc.w Obj50_FixToFloor-Obj50_Index2
; ===========================================================================

Obj50_Move:				; XREF: Obj50_Index2
		subq.w	#1,$30(a0)	; subtract 1 from pause	time
		bpl.s	locret_F8E2	; if time remains, branch
		addq.b	#2,$25(a0)
		move.w	#-$100,$10(a0)	; move object
		move.b	#1,$1C(a0)
		bchg	#0,$22(a0)
		bne.s	locret_F8E2
		neg.w	$10(a0)		; change direction

locret_F8E2:
		rts
; ===========================================================================

Obj50_FixToFloor:			; XREF: Obj50_Index2
		bsr.w	SpeedToPos
		bsr.w	ObjHitFloor
		cmpi.w	#-8,d1
		blt.s	Obj50_Pause
		cmpi.w	#$C,d1
		bge.s	Obj50_Pause
		add.w	d1,$C(a0)	; match	object's position to the floor
		bsr.w	Obj50_ChkWall
		bne.s	Obj50_Pause
		rts
; ===========================================================================

Obj50_Pause:				; XREF: Obj50_FixToFloor
		subq.b	#2,$25(a0)
		move.w	#59,$30(a0)	; set pause time to 1 second
		move.w	#0,$10(a0)
		move.b	#0,$1C(a0)
		rts
; ===========================================================================
Ani_obj50:
	include "_anim\obj50.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Yadrin enemy (SYZ)
; ---------------------------------------------------------------------------
Map_obj50:
	include "_maps\obj50.asm"

; ---------------------------------------------------------------------------
; Solid	object subroutine (includes spikes, blocks, rocks etc)
;
; variables:
; d1 = width
; d2 = height /	2 (when	jumping)
; d3 = height /	2 (when	walking)
; d4 = x-axis position
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SolidObject:
		tst.b	$25(a0)
		beq.w	loc_FAC8
		move.w	d1,d2
		add.w	d2,d2
		lea	($FFFFD000).w,a1
		btst	#1,$22(a1)
		bne.s	loc_F9FE
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_F9FE
		cmp.w	d2,d0
		bcs.s	loc_FA12

loc_F9FE:
		bclr	#3,$22(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)
		moveq	#0,d4
		rts
; ===========================================================================

loc_FA12:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts
; ===========================================================================

SolidObject71:				; XREF: Obj71_Solid
		tst.b	$25(a0)
		beq.w	loc_FAD0
		move.w	d1,d2
		add.w	d2,d2
		lea	($FFFFD000).w,a1
		btst	#1,$22(a1)
		bne.s	loc_FA44
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_FA44
		cmp.w	d2,d0
		bcs.s	loc_FA58

loc_FA44:
		bclr	#3,$22(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)
		moveq	#0,d4
		rts
; ===========================================================================

loc_FA58:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts
; ===========================================================================

SolidObject2F:				; XREF: Obj2F_Solid
		lea	($FFFFD000).w,a1
		tst.b	1(a0)
		bpl.w	loc_FB92
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.w	loc_FB92
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	loc_FB92
		move.w	d0,d5
		btst	#0,1(a0)
		beq.s	loc_FA94
		not.w	d5
		add.w	d3,d5

loc_FA94:
		lsr.w	#1,d5
		moveq	#0,d3
		move.b	(a2,d5.w),d3
		sub.b	(a2),d3
		move.w	$C(a0),d5
		sub.w	d3,d5
		move.b	$16(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	$C(a1),d3
		sub.w	d5,d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi.w	loc_FB92
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bcc.w	loc_FB92
		bra.w	loc_FB0E
; ===========================================================================

loc_FAC8:
		tst.b	1(a0)
		bpl.w	loc_FB92

loc_FAD0:
		lea	($FFFFD000).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.w	loc_FB92
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	loc_FB92
		move.b	$16(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	$C(a1),d3
		sub.w	$C(a0),d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi.w	loc_FB92
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bcc.w	loc_FB92

loc_FB0E:
		tst.b	($FFFFF7C8).w
		bmi.w	loc_FB92
		cmpi.b	#6,($FFFFD024).w
		bcc.w	loc_FB92
		tst.w	($FFFFFE08).w
		bne.w	loc_FBAC
		move.w	d0,d5
		cmp.w	d0,d1
		bcc.s	loc_FB36
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5

loc_FB36:
		move.w	d3,d1
		cmp.w	d3,d2
		bcc.s	loc_FB44
		subq.w	#4,d3
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

loc_FB44:
		cmp.w	d1,d5
		bhi.w	loc_FBB0
		cmpi.w	#4,d1
		bls.s	loc_FB8C
		tst.w	d0
		beq.s	loc_FB70
		bmi.s	loc_FB5E
		tst.w	$10(a1)
		bmi.s	loc_FB70
		bra.s	loc_FB64
; ===========================================================================

loc_FB5E:
		tst.w	$10(a1)
		bpl.s	loc_FB70

loc_FB64:
		move.w	#0,$14(a1)	; stop Sonic moving
		move.w	#0,$10(a1)

loc_FB70:
		sub.w	d0,8(a1)
		btst	#1,$22(a1)
		bne.s	loc_FB8C
		bset	#5,$22(a1)
		bset	#5,$22(a0)
		moveq	#1,d4
		rts
; ===========================================================================

loc_FB8C:
		bsr.s	loc_FBA0
		moveq	#1,d4
		rts
; ===========================================================================

loc_FB92:
		btst	#5,$22(a0)
		beq.s	loc_FBAC
		move.w	#1,$1C(a1)	; use walking animation

loc_FBA0:
		bclr	#5,$22(a0)
		bclr	#5,$22(a1)

loc_FBAC:
		moveq	#0,d4
		rts
; ===========================================================================

loc_FBB0:
		tst.w	d3
		bmi.s	loc_FBBC
		cmpi.w	#$10,d3
		bcs.s	loc_FBEE
		bra.s	loc_FB92
; ===========================================================================

loc_FBBC:
		tst.w	$12(a1)
		beq.s	loc_FBD6
		bpl.s	loc_FBD2
		tst.w	d3
		bpl.s	loc_FBD2
		sub.w	d3,$C(a1)
		move.w	#0,$12(a1)	; stop Sonic moving

loc_FBD2:
		moveq	#-1,d4
		rts
; ===========================================================================

loc_FBD6:
		btst	#1,$22(a1)
		bne.s	loc_FBD2
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	KillSonic
		movea.l	(sp)+,a0
		moveq	#-1,d4
		rts
; ===========================================================================

loc_FBEE:
		subq.w	#4,d3
		moveq	#0,d1
		move.b	$19(a0),d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	8(a1),d1
		sub.w	8(a0),d1
		bmi.s	loc_FC28
		cmp.w	d2,d1
		bcc.s	loc_FC28
		tst.w	$12(a1)
		bmi.s	loc_FC28
		sub.w	d3,$C(a1)
		subq.w	#1,$C(a1)
		bsr.s	sub_FC2C
		move.b	#2,$25(a0)
		bset	#3,$22(a0)
		moveq	#-1,d4
		rts
; ===========================================================================

loc_FC28:
		moveq	#0,d4
		rts
; End of function SolidObject


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_FC2C:				; XREF: SolidObject
		btst	#3,$22(a1)
		beq.s	loc_FC4E
		moveq	#0,d0
		move.b	$3D(a1),d0
		lsl.w	#6,d0
		addi.l	#$FFD000,d0
		movea.l	d0,a2
		bclr	#3,$22(a2)
		clr.b	$25(a2)

loc_FC4E:
		move.w	a0,d0
		subi.w	#-$3000,d0
		lsr.w	#6,d0
		andi.w	#$7F,d0
		move.b	d0,$3D(a1)
		move.b	#0,$26(a1)
		move.w	#0,$12(a1)
		move.w	$10(a1),$14(a1)
		btst	#1,$22(a1)
		beq.s	loc_FC84
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	Sonic_ResetOnFloor
		movea.l	(sp)+,a0

loc_FC84:
		bset	#3,$22(a1)
		bset	#3,$22(a0)
		rts
; End of function sub_FC2C

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 51 - smashable	green block (MZ)
; ---------------------------------------------------------------------------

Obj51:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj51_Index(pc,d0.w),d1
		jsr	Obj51_Index(pc,d1.w)
		bra.w	MarkObjGone
; ===========================================================================
Obj51_Index:	dc.w Obj51_Main-Obj51_Index
		dc.w Obj51_Solid-Obj51_Index
		dc.w Obj51_Display-Obj51_Index
; ===========================================================================

Obj51_Main:				; XREF: Obj51_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj51,4(a0)
		move.w	#$42B8,2(a0)
		move.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#4,$18(a0)
		move.b	$28(a0),$1A(a0)

Obj51_Solid:				; XREF: Obj51_Index
		move.w	($FFFFF7D0).w,$34(a0)
		move.b	($FFFFD01C).w,$32(a0) ;	load Sonic's animation number
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		btst	#3,$22(a0)
		bne.s	Obj51_Smash

locret_FCFC:
		rts
; ===========================================================================

Obj51_Smash:				; XREF: Obj51_Solid
		cmpi.b	#2,$32(a0)	; is Sonic rolling/jumping?
		bne.s	locret_FCFC	; if not, branch
		move.w	$34(a0),($FFFFF7D0).w
		bset	#2,$22(a1)
		move.b	#$E,$16(a1)
		move.b	#7,$17(a1)
		move.b	#2,$1C(a1)
		move.w	#-$300,$12(a1)	; bounce Sonic upwards
		bset	#1,$22(a1)
		bclr	#3,$22(a1)
		move.b	#2,$24(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)
		move.b	#1,$1A(a0)
		lea	(Obj51_Speeds).l,a4 ; load broken	fragment speed data
		moveq	#3,d1		; set number of	fragments to 4
		move.w	#$38,d2
		bsr.w	SmashObject
		bsr.w	SingleObjLoad
		bne.s	Obj51_Display
		move.b	#$29,0(a1)	; load points object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	($FFFFF7D0).w,d2
		addq.w	#2,($FFFFF7D0).w
		cmpi.w	#6,d2
		bcs.s	Obj51_Bonus
		moveq	#6,d2

Obj51_Bonus:
		moveq	#0,d0
		move.w	Obj51_Points(pc,d2.w),d0
		cmpi.w	#$20,($FFFFF7D0).w ; have 16 blocks been smashed?
		bcs.s	loc_FD98	; if not, branch
		move.w	#1000,d0	; give higher points for 16th block
		moveq	#10,d2

loc_FD98:
		jsr	AddPoints
		lsr.w	#1,d2
		move.b	d2,$1A(a1)

Obj51_Display:				; XREF: Obj51_Index
		bsr.w	SpeedToPos
		addi.w	#$38,$12(a0)
		bsr.w	DisplaySprite
		tst.b	1(a0)
		bpl.w	DeleteObject
		rts
; ===========================================================================
Obj51_Speeds:	dc.w $FE00, $FE00	; x-speed, y-speed
		dc.w $FF00, $FF00
		dc.w $200, $FE00
		dc.w $100, $FF00

Obj51_Points:	dc.w 10, 20, 50, 100
; ---------------------------------------------------------------------------
; Sprite mappings - smashable green block (MZ)
; ---------------------------------------------------------------------------
Map_obj51:
	include "_maps\obj51.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 52 - moving platform blocks (MZ, LZ, SBZ)
; ---------------------------------------------------------------------------

Obj52:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj52_Index(pc,d0.w),d1
		jmp	Obj52_Index(pc,d1.w)
; ===========================================================================
Obj52_Index:	dc.w Obj52_Main-Obj52_Index
		dc.w Obj52_Platform-Obj52_Index
		dc.w Obj52_StandOn-Obj52_Index

Obj52_Var:	dc.b $10, 0		; object width,	frame number
		dc.b $20, 1
		dc.b $20, 2
		dc.b $40, 3
		dc.b $30, 4
; ===========================================================================

Obj52_Main:				; XREF: Obj52_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj52,4(a0)
		move.w	#$42B8,2(a0)
		cmpi.b	#1,($FFFFFE10).w ; check if level is LZ
		bne.s	loc_FE44
		move.l	#Map_obj52a,4(a0) ; LZ specific	code
		move.w	#$43BC,2(a0)
		move.b	#7,$16(a0)

loc_FE44:
		cmpi.b	#5,($FFFFFE10).w ; check if level is SBZ
		bne.s	loc_FE60
		move.w	#$22C0,2(a0)	; SBZ specific code (object 5228)
		cmpi.b	#$28,$28(a0)	; is object 5228 ?
		beq.s	loc_FE60	; if yes, branch
		move.w	#$4460,2(a0)	; SBZ specific code (object 523x)

loc_FE60:
		move.b	#4,1(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		lsr.w	#3,d0
		andi.w	#$1E,d0
		lea	Obj52_Var(pc,d0.w),a2
		move.b	(a2)+,$19(a0)
		move.b	(a2)+,$1A(a0)
		move.b	#4,$18(a0)
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$32(a0)
		andi.b	#$F,$28(a0)

Obj52_Platform:				; XREF: Obj52_Index
		bsr.w	Obj52_Move
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(PlatformObject).l
		bra.s	Obj52_ChkDel
; ===========================================================================

Obj52_StandOn:				; XREF: Obj52_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(ExitPlatform).l
		move.w	8(a0),-(sp)
		bsr.w	Obj52_Move
		move.w	(sp)+,d2
		jsr	(MvSonicOnPtfm2).l

Obj52_ChkDel:				; XREF: Obj52_Platform
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

Obj52_Move:				; XREF: Obj52_Platform; Obj52_StandOn
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	Obj52_TypeIndex(pc,d0.w),d1
		jmp	Obj52_TypeIndex(pc,d1.w)
; ===========================================================================
Obj52_TypeIndex:dc.w Obj52_Type00-Obj52_TypeIndex, Obj52_Type01-Obj52_TypeIndex
		dc.w Obj52_Type02-Obj52_TypeIndex, Obj52_Type03-Obj52_TypeIndex
		dc.w Obj52_Type02-Obj52_TypeIndex, Obj52_Type05-Obj52_TypeIndex
		dc.w Obj52_Type06-Obj52_TypeIndex, Obj52_Type07-Obj52_TypeIndex
		dc.w Obj52_Type08-Obj52_TypeIndex, Obj52_Type02-Obj52_TypeIndex
		dc.w Obj52_Type0A-Obj52_TypeIndex
; ===========================================================================

Obj52_Type00:				; XREF: Obj52_TypeIndex
		rts
; ===========================================================================

Obj52_Type01:				; XREF: Obj52_TypeIndex
		move.b	($FFFFFE6C).w,d0
		move.w	#$60,d1
		btst	#0,$22(a0)
		beq.s	loc_FF26
		neg.w	d0
		add.w	d1,d0

loc_FF26:
		move.w	$30(a0),d1
		sub.w	d0,d1
		move.w	d1,8(a0)
		rts
; ===========================================================================

Obj52_Type02:				; XREF: Obj52_TypeIndex
		cmpi.b	#4,$24(a0)	; is Sonic standing on the platform?
		bne.s	Obj52_02_Wait
		addq.b	#1,$28(a0)	; if yes, add 1	to type

Obj52_02_Wait:
		rts
; ===========================================================================

Obj52_Type03:				; XREF: Obj52_TypeIndex
		moveq	#0,d3
		move.b	$19(a0),d3
		bsr.w	ObjHitWallRight
		tst.w	d1		; has the platform hit a wall?
		bmi.s	Obj52_03_End	; if yes, branch
		addq.w	#1,8(a0)	; move platform	to the right
		move.w	8(a0),$30(a0)
		rts
; ===========================================================================

Obj52_03_End:
		clr.b	$28(a0)		; change to type 00 (non-moving	type)
		rts
; ===========================================================================

Obj52_Type05:				; XREF: Obj52_TypeIndex
		moveq	#0,d3
		move.b	$19(a0),d3
		bsr.w	ObjHitWallRight
		tst.w	d1		; has the platform hit a wall?
		bmi.s	Obj52_05_End	; if yes, branch
		addq.w	#1,8(a0)	; move platform	to the right
		move.w	8(a0),$30(a0)
		rts
; ===========================================================================

Obj52_05_End:
		addq.b	#1,$28(a0)	; change to type 06 (falling)
		rts
; ===========================================================================

Obj52_Type06:				; XREF: Obj52_TypeIndex
		bsr.w	SpeedToPos
		addi.w	#$18,$12(a0)	; make the platform fall
		bsr.w	ObjHitFloor
		tst.w	d1		; has platform hit the floor?
		bpl.w	locret_FFA0	; if not, branch
		add.w	d1,$C(a0)
		clr.w	$12(a0)		; stop platform	falling
		clr.b	$28(a0)		; change to type 00 (non-moving)

locret_FFA0:
		rts
; ===========================================================================

Obj52_Type07:				; XREF: Obj52_TypeIndex
		tst.b	($FFFFF7E2).w	; has switch number 02 been pressed?
		beq.s	Obj52_07_ChkDel
		subq.b	#3,$28(a0)	; if yes, change object	type to	04

Obj52_07_ChkDel:
		addq.l	#4,sp
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================

Obj52_Type08:				; XREF: Obj52_TypeIndex
		move.b	($FFFFFE7C).w,d0
		move.w	#$80,d1
		btst	#0,$22(a0)
		beq.s	loc_FFE2
		neg.w	d0
		add.w	d1,d0

loc_FFE2:
		move.w	$32(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)
		rts
; ===========================================================================

Obj52_Type0A:				; XREF: Obj52_TypeIndex
		moveq	#0,d3
		move.b	$19(a0),d3
		add.w	d3,d3
		moveq	#8,d1
		btst	#0,$22(a0)
		beq.s	loc_10004
		neg.w	d1
		neg.w	d3

loc_10004:
		tst.w	$36(a0)		; is platform set to move back?
		bne.s	Obj52_0A_Back	; if yes, branch
		move.w	8(a0),d0
		sub.w	$30(a0),d0
		cmp.w	d3,d0
		beq.s	Obj52_0A_Wait
		add.w	d1,8(a0)	; move platform
		move.w	#300,$34(a0)	; set time delay to 5 seconds
		rts
; ===========================================================================

Obj52_0A_Wait:
		subq.w	#1,$34(a0)	; subtract 1 from time delay
		bne.s	locret_1002E	; if time remains, branch
		move.w	#1,$36(a0)	; set platform to move back to its original position

locret_1002E:
		rts
; ===========================================================================

Obj52_0A_Back:
		move.w	8(a0),d0
		sub.w	$30(a0),d0
		beq.s	Obj52_0A_Reset
		sub.w	d1,8(a0)	; return platform to its original position
		rts
; ===========================================================================

Obj52_0A_Reset:
		clr.w	$36(a0)
		subq.b	#1,$28(a0)
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - moving blocks (MZ, SBZ)
; ---------------------------------------------------------------------------
Map_obj52:
	include "_maps\obj52mz.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - moving block (LZ)
; ---------------------------------------------------------------------------
Map_obj52a:
	include "_maps\obj52lz.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 55 - Basaran enemy (MZ)
; ---------------------------------------------------------------------------

Obj55:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj55_Index(pc,d0.w),d1
		jmp	Obj55_Index(pc,d1.w)
; ===========================================================================
Obj55_Index:	dc.w Obj55_Main-Obj55_Index
		dc.w Obj55_Action-Obj55_Index
; ===========================================================================

Obj55_Main:				; XREF: Obj55_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj55,4(a0)
		move.w	#$84B8,2(a0)
		move.b	#4,1(a0)
		move.b	#$C,$16(a0)
		move.b	#2,$18(a0)
		move.b	#$B,$20(a0)
		move.b	#$10,$19(a0)

Obj55_Action:				; XREF: Obj55_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj55_Index2(pc,d0.w),d1
		jsr	Obj55_Index2(pc,d1.w)
		lea	(Ani_obj55).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj55_Index2:	dc.w Obj55_ChkDrop-Obj55_Index2
		dc.w Obj55_DropFly-Obj55_Index2
		dc.w Obj55_PlaySnd-Obj55_Index2
		dc.w Obj55_FlyUp-Obj55_Index2
; ===========================================================================

Obj55_ChkDrop:				; XREF: Obj55_Index2
		move.w	#$80,d2
		bsr.w	Obj55_ChkSonic
		bcc.s	Obj55_NoDrop
		move.w	($FFFFD00C).w,d0
		move.w	d0,$36(a0)
		sub.w	$C(a0),d0
		bcs.s	Obj55_NoDrop
		cmpi.w	#$80,d0		; is Sonic within $80 pixels of	basaran?
		bcc.s	Obj55_NoDrop	; if not, branch
		tst.w	($FFFFFE08).w	; is debug mode	on?
		bne.s	Obj55_NoDrop	; if yes, branch
		move.b	($FFFFFE0F).w,d0
		add.b	d7,d0
		andi.b	#7,d0
		bne.s	Obj55_NoDrop
		move.b	#1,$1C(a0)
		addq.b	#2,$25(a0)

Obj55_NoDrop:
		rts
; ===========================================================================

Obj55_DropFly:				; XREF: Obj55_Index2
		bsr.w	SpeedToPos
		addi.w	#$18,$12(a0)	; make basaran fall
		move.w	#$80,d2
		bsr.w	Obj55_ChkSonic
		move.w	$36(a0),d0
		sub.w	$C(a0),d0
		bcs.s	Obj55_ChkDel
		cmpi.w	#$10,d0
		bcc.s	locret_10180
		move.w	d1,$10(a0)	; make basaran fly horizontally
		move.w	#0,$12(a0)	; stop basaran falling
		move.b	#2,$1C(a0)
		addq.b	#2,$25(a0)

locret_10180:
		rts
; ===========================================================================

Obj55_ChkDel:				; XREF: Obj55_DropFly
		tst.b	1(a0)
		bpl.w	DeleteObject
		rts
; ===========================================================================

Obj55_PlaySnd:				; XREF: Obj55_Index2
		move.b	($FFFFFE0F).w,d0
		andi.b	#$F,d0
		bne.s	loc_101A0
		moveq	#sfx_Basaran,d0
		jsr	PlaySound_Special ;	play flapping sound

loc_101A0:
		bsr.w	SpeedToPos
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_101B0
		neg.w	d0

loc_101B0:
		cmpi.w	#$80,d0
		bcs.s	locret_101C6
		move.b	($FFFFFE0F).w,d0
		add.b	d7,d0
		andi.b	#7,d0
		bne.s	locret_101C6
		addq.b	#2,$25(a0)

locret_101C6:
		rts
; ===========================================================================

Obj55_FlyUp:				; XREF: Obj55_Index2
		bsr.w	SpeedToPos
		subi.w	#$18,$12(a0)	; make basaran fly upwards
		bsr.w	ObjHitCeiling
		tst.w	d1		; has basaran hit the ceiling?
		bpl.s	locret_101F4	; if not, branch
		sub.w	d1,$C(a0)
		andi.w	#$FFF8,8(a0)
		clr.w	$10(a0)		; stop basaran moving
		clr.w	$12(a0)
		clr.b	$1C(a0)
		clr.b	$25(a0)

locret_101F4:
		rts
; ===========================================================================

Obj55_ChkSonic:				; XREF: Obj55_ChkDrop
		move.w	#$100,d1
		bset	#0,$22(a0)
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_10214
		neg.w	d0
		neg.w	d1
		bclr	#0,$22(a0)

loc_10214:
		cmp.w	d2,d0
		rts
; ===========================================================================
		bsr.w	SpeedToPos
		bsr.w	DisplaySprite
		tst.b	1(a0)
		bpl.w	DeleteObject
		rts
; ===========================================================================
Ani_obj55:
	include "_anim\obj55.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Basaran enemy (MZ)
; ---------------------------------------------------------------------------
Map_obj55:
	include "_maps\obj55.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 56 - moving blocks (SYZ/SLZ), large doors (LZ)
; ---------------------------------------------------------------------------

Obj56:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj56_Index(pc,d0.w),d1
		jmp	Obj56_Index(pc,d1.w)
; ===========================================================================
Obj56_Index:	dc.w Obj56_Main-Obj56_Index
		dc.w Obj56_Action-Obj56_Index

Obj56_Var:	dc.b  $10, $10		; width, height
		dc.b  $20, $20
		dc.b  $10, $20
		dc.b  $20, $1A
		dc.b  $10, $27
		dc.b  $10, $10
		dc.b	8, $20
		dc.b  $40, $10
; ===========================================================================

Obj56_Main:				; XREF: Obj56_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj56,4(a0)
		move.w	#$4000,2(a0)
		cmpi.b	#1,($FFFFFE10).w ; check if level is LZ
		bne.s	loc_102C8
		move.w	#$43C4,2(a0)	; LZ specific code

loc_102C8:
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		lsr.w	#3,d0
		andi.w	#$E,d0
		lea	Obj56_Var(pc,d0.w),a2
		move.b	(a2)+,$19(a0)
		move.b	(a2),$16(a0)
		lsr.w	#1,d0
		move.b	d0,$1A(a0)
		move.w	8(a0),$34(a0)
		move.w	$C(a0),$30(a0)
		moveq	#0,d0
		move.b	(a2),d0
		add.w	d0,d0
		move.w	d0,$3A(a0)
		moveq	#0,d0
		cmpi.b	#1,($FFFFFE10).w ; check if level is LZ
		beq.s	loc_10332
		move.b	$28(a0),d0	; SYZ/SLZ specific code
		andi.w	#$F,d0
		subq.w	#8,d0
		bcs.s	loc_10332
		lsl.w	#2,d0
		lea	($FFFFFE8A).w,a2
		lea	(a2,d0.w),a2
		tst.w	(a2)
		bpl.s	loc_10332
		bchg	#0,$22(a0)

loc_10332:
		move.b	$28(a0),d0
		bpl.s	Obj56_Action
		andi.b	#$F,d0
		move.b	d0,$3C(a0)
		move.b	#5,$28(a0)
		cmpi.b	#7,$1A(a0)
		bne.s	Obj56_ChkGone
		move.b	#$C,$28(a0)
		move.w	#$80,$3A(a0)

Obj56_ChkGone:
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Obj56_Action
		bclr	#7,2(a2,d0.w)
		btst	#0,2(a2,d0.w)
		beq.s	Obj56_Action
		addq.b	#1,$28(a0)
		clr.w	$3A(a0)

Obj56_Action:				; XREF: Obj56_Index
		move.w	8(a0),-(sp)
		moveq	#0,d0
		move.b	$28(a0),d0	; get object type
		andi.w	#$F,d0		; read only the	2nd digit
		add.w	d0,d0
		move.w	Obj56_TypeIndex(pc,d0.w),d1
		jsr	Obj56_TypeIndex(pc,d1.w)
		move.w	(sp)+,d4
		tst.b	1(a0)
		bpl.s	Obj56_ChkDel
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	$16(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		bsr.w	SolidObject

Obj56_ChkDel:
		move.w	$34(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj56_TypeIndex:dc.w Obj56_Type00-Obj56_TypeIndex, Obj56_Type01-Obj56_TypeIndex
		dc.w Obj56_Type02-Obj56_TypeIndex, Obj56_Type03-Obj56_TypeIndex
		dc.w Obj56_Type04-Obj56_TypeIndex, Obj56_Type05-Obj56_TypeIndex
		dc.w Obj56_Type06-Obj56_TypeIndex, Obj56_Type07-Obj56_TypeIndex
		dc.w Obj56_Type08-Obj56_TypeIndex, Obj56_Type09-Obj56_TypeIndex
		dc.w Obj56_Type0A-Obj56_TypeIndex, Obj56_Type0B-Obj56_TypeIndex
		dc.w Obj56_Type0C-Obj56_TypeIndex, Obj56_Type0D-Obj56_TypeIndex
; ===========================================================================

Obj56_Type00:				; XREF: Obj56_TypeIndex
		rts
; ===========================================================================

Obj56_Type01:				; XREF: Obj56_TypeIndex
		move.w	#$40,d1
		moveq	#0,d0
		move.b	($FFFFFE68).w,d0
		bra.s	Obj56_Move_LR
; ===========================================================================

Obj56_Type02:				; XREF: Obj56_TypeIndex
		move.w	#$80,d1
		moveq	#0,d0
		move.b	($FFFFFE7C).w,d0

Obj56_Move_LR:
		btst	#0,$22(a0)
		beq.s	loc_10416
		neg.w	d0
		add.w	d1,d0

loc_10416:
		move.w	$34(a0),d1
		sub.w	d0,d1
		move.w	d1,8(a0)	; move object horizontally
		rts
; ===========================================================================

Obj56_Type03:				; XREF: Obj56_TypeIndex
		move.w	#$40,d1
		moveq	#0,d0
		move.b	($FFFFFE68).w,d0
		bra.s	Obj56_Move_UD
; ===========================================================================

Obj56_Type04:				; XREF: Obj56_TypeIndex
		move.w	#$80,d1
		moveq	#0,d0
		move.b	($FFFFFE7C).w,d0

Obj56_Move_UD:
		btst	#0,$22(a0)
		beq.s	loc_10444
		neg.w	d0
		add.w	d1,d0

loc_10444:
		move.w	$30(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)	; move object vertically
		rts
; ===========================================================================

Obj56_Type05:				; XREF: Obj56_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_104A4
		cmpi.w	#$100,($FFFFFE10).w ; is level LZ1 ?
		bne.s	loc_1047A	; if not, branch
		cmpi.b	#3,$3C(a0)
		bne.s	loc_1047A
		clr.b	($FFFFF7C9).w
		move.w	($FFFFD008).w,d0
		cmp.w	8(a0),d0
		bcc.s	loc_1047A
		move.b	#1,($FFFFF7C9).w

loc_1047A:
		lea	($FFFFF7E0).w,a2
		moveq	#0,d0
		move.b	$3C(a0),d0
		btst	#0,(a2,d0.w)
		beq.s	loc_104AE
		cmpi.w	#$100,($FFFFFE10).w ; is level LZ1 ?
		bne.s	loc_1049E	; if not, branch
		cmpi.b	#3,d0
		bne.s	loc_1049E
		clr.b	($FFFFF7C9).w

loc_1049E:
		move.b	#1,$38(a0)

loc_104A4:
		tst.w	$3A(a0)
		beq.s	loc_104C8
		subq.w	#2,$3A(a0)

loc_104AE:
		move.w	$3A(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_104BC
		neg.w	d0

loc_104BC:
		move.w	$30(a0),d1
		add.w	d0,d1
		move.w	d1,$C(a0)
		rts
; ===========================================================================

loc_104C8:
		addq.b	#1,$28(a0)
		clr.b	$38(a0)
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_104AE
		bset	#0,2(a2,d0.w)
		bra.s	loc_104AE
; ===========================================================================

Obj56_Type06:				; XREF: Obj56_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_10500
		lea	($FFFFF7E0).w,a2
		moveq	#0,d0
		move.b	$3C(a0),d0
		tst.b	(a2,d0.w)
		bpl.s	loc_10512
		move.b	#1,$38(a0)

loc_10500:
		moveq	#0,d0
		move.b	$16(a0),d0
		add.w	d0,d0
		cmp.w	$3A(a0),d0
		beq.s	loc_1052C
		addq.w	#2,$3A(a0)

loc_10512:
		move.w	$3A(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_10520
		neg.w	d0

loc_10520:
		move.w	$30(a0),d1
		add.w	d0,d1
		move.w	d1,$C(a0)
		rts
; ===========================================================================

loc_1052C:
		subq.b	#1,$28(a0)
		clr.b	$38(a0)
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_10512
		bclr	#0,2(a2,d0.w)
		bra.s	loc_10512
; ===========================================================================

Obj56_Type07:				; XREF: Obj56_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_1055E
		tst.b	($FFFFF7EF).w	; has switch number $F been pressed?
		beq.s	locret_10578
		move.b	#1,$38(a0)
		clr.w	$3A(a0)

loc_1055E:
		addq.w	#1,8(a0)
		move.w	8(a0),$34(a0)
		addq.w	#1,$3A(a0)
		cmpi.w	#$380,$3A(a0)
		bne.s	locret_10578
		clr.b	$28(a0)

locret_10578:
		rts
; ===========================================================================

Obj56_Type0C:				; XREF: Obj56_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_10598
		lea	($FFFFF7E0).w,a2
		moveq	#0,d0
		move.b	$3C(a0),d0
		btst	#0,(a2,d0.w)
		beq.s	loc_105A2
		move.b	#1,$38(a0)

loc_10598:
		tst.w	$3A(a0)
		beq.s	loc_105C0
		subq.w	#2,$3A(a0)

loc_105A2:
		move.w	$3A(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_105B4
		neg.w	d0
		addi.w	#$80,d0

loc_105B4:
		move.w	$34(a0),d1
		add.w	d0,d1
		move.w	d1,8(a0)
		rts
; ===========================================================================

loc_105C0:
		addq.b	#1,$28(a0)
		clr.b	$38(a0)
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_105A2
		bset	#0,2(a2,d0.w)
		bra.s	loc_105A2
; ===========================================================================

Obj56_Type0D:				; XREF: Obj56_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_105F8
		lea	($FFFFF7E0).w,a2
		moveq	#0,d0
		move.b	$3C(a0),d0
		tst.b	(a2,d0.w)
		bpl.s	loc_10606
		move.b	#1,$38(a0)

loc_105F8:
		move.w	#$80,d0
		cmp.w	$3A(a0),d0
		beq.s	loc_10624
		addq.w	#2,$3A(a0)

loc_10606:
		move.w	$3A(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_10618
		neg.w	d0
		addi.w	#$80,d0

loc_10618:
		move.w	$34(a0),d1
		add.w	d0,d1
		move.w	d1,8(a0)
		rts
; ===========================================================================

loc_10624:
		subq.b	#1,$28(a0)
		clr.b	$38(a0)
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_10606
		bclr	#0,2(a2,d0.w)
		bra.s	loc_10606
; ===========================================================================

Obj56_Type08:				; XREF: Obj56_TypeIndex
		move.w	#$10,d1
		moveq	#0,d0
		move.b	($FFFFFE88).w,d0
		lsr.w	#1,d0
		move.w	($FFFFFE8A).w,d3
		bra.s	Obj56_Move_Sqr
; ===========================================================================

Obj56_Type09:				; XREF: Obj56_TypeIndex
		move.w	#$30,d1
		moveq	#0,d0
		move.b	($FFFFFE8C).w,d0
		move.w	($FFFFFE8E).w,d3
		bra.s	Obj56_Move_Sqr
; ===========================================================================

Obj56_Type0A:				; XREF: Obj56_TypeIndex
		move.w	#$50,d1
		moveq	#0,d0
		move.b	($FFFFFE90).w,d0
		move.w	($FFFFFE92).w,d3
		bra.s	Obj56_Move_Sqr
; ===========================================================================

Obj56_Type0B:				; XREF: Obj56_TypeIndex
		move.w	#$70,d1
		moveq	#0,d0
		move.b	($FFFFFE94).w,d0
		move.w	($FFFFFE96).w,d3

Obj56_Move_Sqr:
		tst.w	d3
		bne.s	loc_1068E
		addq.b	#1,$22(a0)
		andi.b	#3,$22(a0)

loc_1068E:
		move.b	$22(a0),d2
		andi.b	#3,d2
		bne.s	loc_106AE
		sub.w	d1,d0
		add.w	$34(a0),d0
		move.w	d0,8(a0)
		neg.w	d1
		add.w	$30(a0),d1
		move.w	d1,$C(a0)
		rts
; ===========================================================================

loc_106AE:
		subq.b	#1,d2
		bne.s	loc_106CC
		subq.w	#1,d1
		sub.w	d1,d0
		neg.w	d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		addq.w	#1,d1
		add.w	$34(a0),d1
		move.w	d1,8(a0)
		rts
; ===========================================================================

loc_106CC:
		subq.b	#1,d2
		bne.s	loc_106EA
		subq.w	#1,d1
		sub.w	d1,d0
		neg.w	d0
		add.w	$34(a0),d0
		move.w	d0,8(a0)
		addq.w	#1,d1
		add.w	$30(a0),d1
		move.w	d1,$C(a0)
		rts
; ===========================================================================

loc_106EA:
		sub.w	d1,d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		neg.w	d1
		add.w	$34(a0),d1
		move.w	d1,8(a0)
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - moving blocks (SYZ/SLZ/LZ)
; ---------------------------------------------------------------------------
Map_obj56:
	include "_maps\obj56.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 57 - spiked balls (SYZ, LZ)
; ---------------------------------------------------------------------------

Obj57:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj57_Index(pc,d0.w),d1
		jmp	Obj57_Index(pc,d1.w)
; ===========================================================================
Obj57_Index:	dc.w Obj57_Main-Obj57_Index
		dc.w Obj57_Move-Obj57_Index
		dc.w Obj57_Display-Obj57_Index
; ===========================================================================

Obj57_Main:				; XREF: Obj57_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj57,4(a0)
		move.w	#$3BA,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#8,$19(a0)
		move.w	8(a0),$3A(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$98,$20(a0)	; SYZ specific code (chain hurts Sonic)
		cmpi.b	#1,($FFFFFE10).w ; check if level is LZ
		bne.s	loc_107E8
		move.b	#0,$20(a0)	; LZ specific code (chain doesn't hurt)
		move.w	#$310,2(a0)
		move.l	#Map_obj57a,4(a0)

loc_107E8:
		move.b	$28(a0),d1	; get object type
		andi.b	#$F0,d1		; read only the	1st digit
		ext.w	d1
		asl.w	#3,d1		; multiply by 8
		move.w	d1,$3E(a0)	; set object twirl speed
		move.b	$22(a0),d0
		ror.b	#2,d0
		andi.b	#-$40,d0
		move.b	d0,$26(a0)
		lea	$29(a0),a2
		move.b	$28(a0),d1	; get object type
		andi.w	#7,d1		; read only the	2nd digit
		move.b	#0,(a2)+
		move.w	d1,d3
		lsl.w	#4,d3
		move.b	d3,$3C(a0)
		subq.w	#1,d1		; set chain length (type-1)
		bcs.s	loc_10894
		btst	#3,$28(a0)
		beq.s	Obj57_MakeChain
		subq.w	#1,d1
		bcs.s	loc_10894

Obj57_MakeChain:
		bsr.w	SingleObjLoad
		bne.s	loc_10894
		addq.b	#1,$29(a0)
		move.w	a1,d5
		subi.w	#-$3000,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	#4,$24(a1)
		move.b	0(a0),0(a1)
		move.l	4(a0),4(a1)
		move.w	2(a0),2(a1)
		move.b	1(a0),1(a1)
		move.b	$18(a0),$18(a1)
		move.b	$19(a0),$19(a1)
		move.b	$20(a0),$20(a1)
		subi.b	#$10,d3
		move.b	d3,$3C(a1)
		cmpi.b	#1,($FFFFFE10).w
		bne.s	loc_10890
		tst.b	d3
		bne.s	loc_10890
		move.b	#2,$1A(a1)

loc_10890:
		dbf	d1,Obj57_MakeChain ; repeat for	length of chain

loc_10894:
		move.w	a0,d5
		subi.w	#-$3000,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		cmpi.b	#1,($FFFFFE10).w ; check if level is LZ
		bne.s	Obj57_Move
		move.b	#$8B,$20(a0)	; if yes, make last spikeball larger
		move.b	#1,$1A(a0)	; use different	frame

Obj57_Move:				; XREF: Obj57_Index
		bsr.w	Obj57_MoveSub
		bra.w	Obj57_ChkDel
; ===========================================================================

Obj57_MoveSub:				; XREF: Obj57_Move
		move.w	$3E(a0),d0
		add.w	d0,$26(a0)
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		move.w	$38(a0),d2
		move.w	$3A(a0),d3
		lea	$29(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

Obj57_MoveLoop:
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#6,d4
		addi.l	#$FFD000,d4
		movea.l	d4,a1
		moveq	#0,d4
		move.b	$3C(a1),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,$C(a1)
		move.w	d5,8(a1)
		dbf	d6,Obj57_MoveLoop
		rts
; ===========================================================================

Obj57_ChkDel:				; XREF: Obj57_Move
		move.w	$3A(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj57_Delete
		bra.w	DisplaySprite
; ===========================================================================

Obj57_Delete:				; XREF: Obj57_ChkDel
		moveq	#0,d2
		lea	$29(a0),a2
		move.b	(a2)+,d2

Obj57_DelLoop:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#$FFD000,d0
		movea.l	d0,a1
		bsr.w	DeleteObject2
		dbf	d2,Obj57_DelLoop ; delete all pieces of	chain

		rts
; ===========================================================================

Obj57_Display:				; XREF: Obj57_Index
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - chain of spiked balls (SYZ)
; ---------------------------------------------------------------------------
Map_obj57:
	include "_maps\obj57syz.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - spiked ball	on a chain (LZ)
; ---------------------------------------------------------------------------
Map_obj57a:
	include "_maps\obj57lz.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 58 - giant spiked balls (SYZ)
; ---------------------------------------------------------------------------

Obj58:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj58_Index(pc,d0.w),d1
		jmp	Obj58_Index(pc,d1.w)
; ===========================================================================
Obj58_Index:	dc.w Obj58_Main-Obj58_Index
		dc.w Obj58_Move-Obj58_Index
; ===========================================================================

Obj58_Main:				; XREF: Obj58_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj15b,4(a0)
		move.w	#$396,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$18,$19(a0)
		move.w	8(a0),$3A(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$86,$20(a0)
		move.b	$28(a0),d1	; get object type
		andi.b	#$F0,d1		; read only the	1st digit
		ext.w	d1
		asl.w	#3,d1		; multiply by 8
		move.w	d1,$3E(a0)	; set object speed
		move.b	$22(a0),d0
		ror.b	#2,d0
		andi.b	#$C0,d0
		move.b	d0,$26(a0)
		move.b	#$50,$3C(a0)	; set diameter of circle of rotation

Obj58_Move:				; XREF: Obj58_Index
		moveq	#0,d0
		move.b	$28(a0),d0	; get object type
		andi.w	#7,d0		; read only the	2nd digit
		add.w	d0,d0
		move.w	Obj58_TypeIndex(pc,d0.w),d1
		jsr	Obj58_TypeIndex(pc,d1.w)
		move.w	$3A(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj58_TypeIndex:dc.w Obj58_Type00-Obj58_TypeIndex
		dc.w Obj58_Type01-Obj58_TypeIndex
		dc.w Obj58_Type02-Obj58_TypeIndex
		dc.w Obj58_Type03-Obj58_TypeIndex
; ===========================================================================

Obj58_Type00:				; XREF: Obj58_TypeIndex
		rts
; ===========================================================================

Obj58_Type01:				; XREF: Obj58_TypeIndex
		move.w	#$60,d1
		moveq	#0,d0
		move.b	($FFFFFE6C).w,d0
		btst	#0,$22(a0)
		beq.s	loc_10A38
		neg.w	d0
		add.w	d1,d0

loc_10A38:
		move.w	$3A(a0),d1
		sub.w	d0,d1
		move.w	d1,8(a0)	; move object horizontally
		rts
; ===========================================================================

Obj58_Type02:				; XREF: Obj58_TypeIndex
		move.w	#$60,d1
		moveq	#0,d0
		move.b	($FFFFFE6C).w,d0
		btst	#0,$22(a0)
		beq.s	loc_10A5C
		neg.w	d0
		addi.w	#$80,d0

loc_10A5C:
		move.w	$38(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)	; move object vertically
		rts
; ===========================================================================

Obj58_Type03:				; XREF: Obj58_TypeIndex
		move.w	$3E(a0),d0
		add.w	d0,$26(a0)
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		move.w	$38(a0),d2
		move.w	$3A(a0),d3
		moveq	#0,d4
		move.b	$3C(a0),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,$C(a0)
		move.w	d5,8(a0)
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - SBZ	spiked ball on a chain
; ---------------------------------------------------------------------------
Map_obj15b:
	include "_maps\obj15sbz.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 59 - platforms	that move when you stand on them (SLZ)
; ---------------------------------------------------------------------------

Obj59:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj59_Index(pc,d0.w),d1
		jsr	Obj59_Index(pc,d1.w)
		move.w	$32(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj59_Index:	dc.w Obj59_Main-Obj59_Index
		dc.w Obj59_Platform-Obj59_Index
		dc.w Obj59_Action-Obj59_Index
		dc.w Obj59_MakeMulti-Obj59_Index

Obj59_Var1:	dc.b $28, 0		; width, frame number

Obj59_Var2:	dc.b $10, 1		; width, action	type
		dc.b $20, 1
		dc.b $34, 1
		dc.b $10, 3
		dc.b $20, 3
		dc.b $34, 3
		dc.b $14, 1
		dc.b $24, 1
		dc.b $2C, 1
		dc.b $14, 3
		dc.b $24, 3
		dc.b $2C, 3
		dc.b $20, 5
		dc.b $20, 7
		dc.b $30, 9
; ===========================================================================

Obj59_Main:				; XREF: Obj59_Index
		addq.b	#2,$24(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		bpl.s	Obj59_Main2
		addq.b	#4,$24(a0)
		andi.w	#$7F,d0
		mulu.w	#6,d0
		move.w	d0,$3C(a0)
		move.w	d0,$3E(a0)
		addq.l	#4,sp
		rts
; ===========================================================================

Obj59_Main2:
		lsr.w	#3,d0
		andi.w	#$1E,d0
		lea	Obj59_Var1(pc,d0.w),a2
		move.b	(a2)+,$19(a0)
		move.b	(a2)+,$1A(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		andi.w	#$1E,d0
		lea	Obj59_Var2(pc,d0.w),a2
		move.b	(a2)+,d0
		lsl.w	#2,d0
		move.w	d0,$3C(a0)
		move.b	(a2)+,$28(a0)
		move.l	#Map_obj59,4(a0)
		move.w	#$4000,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.w	8(a0),$32(a0)
		move.w	$C(a0),$30(a0)

Obj59_Platform:				; XREF: Obj59_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(PlatformObject).l
		bra.w	Obj59_Types
; ===========================================================================

Obj59_Action:				; XREF: Obj59_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(ExitPlatform).l
		move.w	8(a0),-(sp)
		bsr.w	Obj59_Types
		move.w	(sp)+,d2
		tst.b	0(a0)
		beq.s	locret_10BD4
		jmp	(MvSonicOnPtfm2).l
; ===========================================================================

locret_10BD4:
		rts
; ===========================================================================

Obj59_Types:
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	Obj59_TypeIndex(pc,d0.w),d1
		jmp	Obj59_TypeIndex(pc,d1.w)
; ===========================================================================
Obj59_TypeIndex:dc.w Obj59_Type00-Obj59_TypeIndex, Obj59_Type01-Obj59_TypeIndex
		dc.w Obj59_Type02-Obj59_TypeIndex, Obj59_Type01-Obj59_TypeIndex
		dc.w Obj59_Type04-Obj59_TypeIndex, Obj59_Type01-Obj59_TypeIndex
		dc.w Obj59_Type06-Obj59_TypeIndex, Obj59_Type01-Obj59_TypeIndex
		dc.w Obj59_Type08-Obj59_TypeIndex, Obj59_Type09-Obj59_TypeIndex
; ===========================================================================

Obj59_Type00:				; XREF: Obj59_TypeIndex
		rts
; ===========================================================================

Obj59_Type01:				; XREF: Obj59_TypeIndex
		cmpi.b	#4,$24(a0)	; check	if Sonic is standing on	the object
		bne.s	locret_10C0C
		addq.b	#1,$28(a0)	; if yes, add 1	to type

locret_10C0C:
		rts
; ===========================================================================

Obj59_Type02:				; XREF: Obj59_TypeIndex
		bsr.w	Obj59_Move
		move.w	$34(a0),d0
		neg.w	d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		rts
; ===========================================================================

Obj59_Type04:				; XREF: Obj59_TypeIndex
		bsr.w	Obj59_Move
		move.w	$34(a0),d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		rts
; ===========================================================================

Obj59_Type06:				; XREF: Obj59_TypeIndex
		bsr.w	Obj59_Move
		move.w	$34(a0),d0
		asr.w	#1,d0
		neg.w	d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		move.w	$34(a0),d0
		add.w	$32(a0),d0
		move.w	d0,8(a0)
		rts
; ===========================================================================

Obj59_Type08:				; XREF: Obj59_TypeIndex
		bsr.w	Obj59_Move
		move.w	$34(a0),d0
		asr.w	#1,d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		move.w	$34(a0),d0
		neg.w	d0
		add.w	$32(a0),d0
		move.w	d0,8(a0)
		rts
; ===========================================================================

Obj59_Type09:				; XREF: Obj59_TypeIndex
		bsr.w	Obj59_Move
		move.w	$34(a0),d0
		neg.w	d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		tst.b	$28(a0)
		beq.w	loc_10C94
		rts
; ===========================================================================

loc_10C94:
		btst	#3,$22(a0)
		beq.s	Obj59_Delete
		bset	#1,$22(a1)
		bclr	#3,$22(a1)
		move.b	#2,$24(a1)

Obj59_Delete:
		bra.w	DeleteObject

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj59_Move:				; XREF: Obj59_Type02; et al
		move.w	$38(a0),d0
		tst.b	$3A(a0)
		bne.s	loc_10CC8
		cmpi.w	#$800,d0
		bcc.s	loc_10CD0
		addi.w	#$10,d0
		bra.s	loc_10CD0
; ===========================================================================

loc_10CC8:
		tst.w	d0
		beq.s	loc_10CD0
		subi.w	#$10,d0

loc_10CD0:
		move.w	d0,$38(a0)
		ext.l	d0
		asl.l	#8,d0
		add.l	$34(a0),d0
		move.l	d0,$34(a0)
		swap	d0
		move.w	$3C(a0),d2
		cmp.w	d2,d0
		bls.s	loc_10CF0
		move.b	#1,$3A(a0)

loc_10CF0:
		add.w	d2,d2
		cmp.w	d2,d0
		bne.s	locret_10CFA
		clr.b	$28(a0)

locret_10CFA:
		rts
; End of function Obj59_Move

; ===========================================================================

Obj59_MakeMulti:			; XREF: Obj59_Index
		subq.w	#1,$3C(a0)
		bne.s	Obj59_ChkDel
		move.w	$3E(a0),$3C(a0)
		bsr.w	SingleObjLoad
		bne.s	Obj59_ChkDel
		move.b	#$59,0(a1)	; duplicate the	object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#$E,$28(a1)

Obj59_ChkDel:
		addq.l	#4,sp
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - platforms that move	when you stand on them (SLZ)
; ---------------------------------------------------------------------------
Map_obj59:
	include "_maps\obj59.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5A - platforms	moving in circles (SLZ)
; ---------------------------------------------------------------------------

Obj5A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj5A_Index(pc,d0.w),d1
		jsr	Obj5A_Index(pc,d1.w)
		move.w	$32(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj5A_Index:	dc.w Obj5A_Main-Obj5A_Index
		dc.w Obj5A_Platform-Obj5A_Index
		dc.w Obj5A_Action-Obj5A_Index
; ===========================================================================

Obj5A_Main:				; XREF: Obj5A_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj5A,4(a0)
		move.w	#$4000,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$18,$19(a0)
		move.w	8(a0),$32(a0)
		move.w	$C(a0),$30(a0)

Obj5A_Platform:				; XREF: Obj5A_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(PlatformObject).l
		bra.w	Obj5A_Types
; ===========================================================================

Obj5A_Action:				; XREF: Obj5A_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(ExitPlatform).l
		move.w	8(a0),-(sp)
		bsr.w	Obj5A_Types
		move.w	(sp)+,d2
		jmp	(MvSonicOnPtfm2).l
; ===========================================================================

Obj5A_Types:
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#$C,d0
		lsr.w	#1,d0
		move.w	Obj5A_TypeIndex(pc,d0.w),d1
		jmp	Obj5A_TypeIndex(pc,d1.w)
; ===========================================================================
Obj5A_TypeIndex:dc.w Obj5A_Type00-Obj5A_TypeIndex
		dc.w Obj5A_Type04-Obj5A_TypeIndex
; ===========================================================================

Obj5A_Type00:				; XREF: Obj5A_TypeIndex
		move.b	($FFFFFE80).w,d1
		subi.b	#$50,d1
		ext.w	d1
		move.b	($FFFFFE84).w,d2
		subi.b	#$50,d2
		ext.w	d2
		btst	#0,$28(a0)
		beq.s	loc_10E24
		neg.w	d1
		neg.w	d2

loc_10E24:
		btst	#1,$28(a0)
		beq.s	loc_10E30
		neg.w	d1
		exg	d1,d2

loc_10E30:
		add.w	$32(a0),d1
		move.w	d1,8(a0)
		add.w	$30(a0),d2
		move.w	d2,$C(a0)
		rts
; ===========================================================================

Obj5A_Type04:				; XREF: Obj5A_TypeIndex
		move.b	($FFFFFE80).w,d1
		subi.b	#$50,d1
		ext.w	d1
		move.b	($FFFFFE84).w,d2
		subi.b	#$50,d2
		ext.w	d2
		btst	#0,$28(a0)
		beq.s	loc_10E62
		neg.w	d1
		neg.w	d2

loc_10E62:
		btst	#1,$28(a0)
		beq.s	loc_10E6E
		neg.w	d1
		exg	d1,d2

loc_10E6E:
		neg.w	d1
		add.w	$32(a0),d1
		move.w	d1,8(a0)
		add.w	$30(a0),d2
		move.w	d2,$C(a0)
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - platforms that move	in circles (SLZ)
; ---------------------------------------------------------------------------
Map_obj5A:
	include "_maps\obj5A.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5B - blocks that form a staircase (SLZ)
; ---------------------------------------------------------------------------

Obj5B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj5B_Index(pc,d0.w),d1
		jsr	Obj5B_Index(pc,d1.w)
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj5B_Index:	dc.w Obj5B_Main-Obj5B_Index
		dc.w Obj5B_Move-Obj5B_Index
		dc.w Obj5B_Solid-Obj5B_Index
; ===========================================================================

Obj5B_Main:				; XREF: Obj5B_Index
		addq.b	#2,$24(a0)
		moveq	#$38,d3
		moveq	#1,d4
		btst	#0,$22(a0)
		beq.s	loc_10EDA
		moveq	#$3B,d3
		moveq	#-1,d4

loc_10EDA:
		move.w	8(a0),d2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj5B_MakeBlocks
; ===========================================================================

Obj5B_Loop:
		bsr.w	SingleObjLoad2
		bne.w	Obj5B_Move
		move.b	#4,$24(a1)

Obj5B_MakeBlocks:			; XREF: Obj5B_Main
		move.b	#$5B,0(a1)	; load another block object
		move.l	#Map_obj5B,4(a1)
		move.w	#$4000,2(a1)
		move.b	#4,1(a1)
		move.b	#3,$18(a1)
		move.b	#$10,$19(a1)
		move.b	$28(a0),$28(a1)
		move.w	d2,8(a1)
		move.w	$C(a0),$C(a1)
		move.w	8(a0),$30(a1)
		move.w	$C(a1),$32(a1)
		addi.w	#$20,d2
		move.b	d3,$37(a1)
		move.l	a0,$3C(a1)
		add.b	d4,d3
		dbf	d1,Obj5B_Loop	; repeat sequence 3 times

Obj5B_Move:				; XREF: Obj5B_Index
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Obj5B_TypeIndex(pc,d0.w),d1
		jsr	Obj5B_TypeIndex(pc,d1.w)

Obj5B_Solid:				; XREF: Obj5B_Index
		movea.l	$3C(a0),a2
		moveq	#0,d0
		move.b	$37(a0),d0
		move.b	(a2,d0.w),d0
		add.w	$32(a0),d0
		move.w	d0,$C(a0)
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		tst.b	d4
		bpl.s	loc_10F92
		move.b	d4,$36(a2)

loc_10F92:
		btst	#3,$22(a0)
		beq.s	locret_10FA0
		move.b	#1,$36(a2)

locret_10FA0:
		rts
; ===========================================================================
Obj5B_TypeIndex:dc.w Obj5B_Type00-Obj5B_TypeIndex
		dc.w Obj5B_Type01-Obj5B_TypeIndex
		dc.w Obj5B_Type02-Obj5B_TypeIndex
		dc.w Obj5B_Type01-Obj5B_TypeIndex
; ===========================================================================

Obj5B_Type00:				; XREF: Obj5B_TypeIndex
		tst.w	$34(a0)
		bne.s	loc_10FC0
		cmpi.b	#1,$36(a0)
		bne.s	locret_10FBE
		move.w	#$1E,$34(a0)

locret_10FBE:
		rts
; ===========================================================================

loc_10FC0:
		subq.w	#1,$34(a0)
		bne.s	locret_10FBE
		addq.b	#1,$28(a0)	; add 1	to type
		rts
; ===========================================================================

Obj5B_Type02:				; XREF: Obj5B_TypeIndex
		tst.w	$34(a0)
		bne.s	loc_10FE0
		tst.b	$36(a0)
		bpl.s	locret_10FDE
		move.w	#$3C,$34(a0)

locret_10FDE:
		rts
; ===========================================================================

loc_10FE0:
		subq.w	#1,$34(a0)
		bne.s	loc_10FEC
		addq.b	#1,$28(a0)	; add 1	to type
		rts
; ===========================================================================

loc_10FEC:
		lea	$38(a0),a1
		move.w	$34(a0),d0
		lsr.b	#2,d0
		andi.b	#1,d0
		move.b	d0,(a1)+
		eori.b	#1,d0
		move.b	d0,(a1)+
		eori.b	#1,d0
		move.b	d0,(a1)+
		eori.b	#1,d0
		move.b	d0,(a1)+
		rts
; ===========================================================================

Obj5B_Type01:				; XREF: Obj5B_TypeIndex
		lea	$38(a0),a1
		cmpi.b	#$80,(a1)
		beq.s	locret_11038
		addq.b	#1,(a1)
		moveq	#0,d1
		move.b	(a1)+,d1
		swap	d1
		lsr.l	#1,d1
		move.l	d1,d2
		lsr.l	#1,d1
		move.l	d1,d3
		add.l	d2,d3
		swap	d1
		swap	d2
		swap	d3
		move.b	d3,(a1)+
		move.b	d2,(a1)+
		move.b	d1,(a1)+

locret_11038:
		rts
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - blocks that	form a staircase (SLZ)
; ---------------------------------------------------------------------------
Map_obj5B:
	include "_maps\obj5B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5C - metal girders in foreground (SLZ)
; ---------------------------------------------------------------------------

Obj5C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj5C_Index(pc,d0.w),d1
		jmp	Obj5C_Index(pc,d1.w)
; ===========================================================================
Obj5C_Index:	dc.w Obj5C_Main-Obj5C_Index
		dc.w Obj5C_Display-Obj5C_Index
; ===========================================================================

Obj5C_Main:				; XREF: Obj5C_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj5C,4(a0)
		move.w	#$83CC,2(a0)
		move.b	#$10,$19(a0)

Obj5C_Display:				; XREF: Obj5C_Index
		move.l	($FFFFF700).w,d1
		add.l	d1,d1
		swap	d1
		neg.w	d1
		move.w	d1,8(a0)
		move.l	($FFFFF704).w,d1
		add.l	d1,d1
		swap	d1
		andi.w	#$3F,d1
		neg.w	d1
		addi.w	#$100,d1
		move.w	d1,$A(a0)
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - metal girders in foreground	(SLZ)
; ---------------------------------------------------------------------------
Map_obj5C:
	include "_maps\obj5C.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1B - water surface (LZ)
; ---------------------------------------------------------------------------

Obj1B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj1B_Index(pc,d0.w),d1
		jmp	Obj1B_Index(pc,d1.w)
; ===========================================================================
Obj1B_Index:	dc.w Obj1B_Main-Obj1B_Index
		dc.w Obj1B_Action-Obj1B_Index
; ===========================================================================

Obj1B_Main:				; XREF: Obj1B_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj1B,4(a0)
		move.w	#$C300,2(a0)
		move.b	#4,1(a0)
		move.b	#$80,$19(a0)
		move.w	8(a0),$30(a0)

Obj1B_Action:				; XREF: Obj1B_Index
		move.w	($FFFFF700).w,d1
		andi.w	#$FFE0,d1
		add.w	$30(a0),d1
		btst	#0,($FFFFFE05).w
		beq.s	loc_11114
		addi.w	#$20,d1

loc_11114:
		move.w	d1,8(a0)	; match	obj x-position to screen position
		move.w	($FFFFF646).w,d1
		move.w	d1,$C(a0)	; match	obj y-position to water	height
		tst.b	$32(a0)
		bne.s	Obj1B_Animate
		btst	#7,($FFFFF605).w ; is Start button pressed?
		beq.s	loc_1114A	; if not, branch
		addq.b	#3,$1A(a0)	; use different	frames
		move.b	#1,$32(a0)	; stop animation
		bra.s	Obj1B_Display
; ===========================================================================

Obj1B_Animate:				; XREF: loc_11114
		tst.w	($FFFFF63A).w	; is the game paused?
		bne.s	Obj1B_Display	; if yes, branch
		move.b	#0,$32(a0)	; resume animation
		subq.b	#3,$1A(a0)	; use normal frames

loc_1114A:				; XREF: loc_11114
		subq.b	#1,$1E(a0)
		bpl.s	Obj1B_Display
		move.b	#7,$1E(a0)
		addq.b	#1,$1A(a0)
		cmpi.b	#3,$1A(a0)
		bcs.s	Obj1B_Display
		move.b	#0,$1A(a0)

Obj1B_Display:
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - water surface (LZ)
; ---------------------------------------------------------------------------
Map_obj1B:
	include "_maps\obj1B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0B - pole that	breaks (LZ)
; ---------------------------------------------------------------------------

Obj0B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj0B_Index(pc,d0.w),d1
		jmp	Obj0B_Index(pc,d1.w)
; ===========================================================================
Obj0B_Index:	dc.w Obj0B_Main-Obj0B_Index
		dc.w Obj0B_Action-Obj0B_Index
		dc.w Obj0B_Display-Obj0B_Index
; ===========================================================================

Obj0B_Main:				; XREF: Obj0B_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj0B,4(a0)
		move.w	#$43DE,2(a0)
		move.b	#4,1(a0)
		move.b	#8,$19(a0)
		move.b	#4,$18(a0)
		move.b	#$E1,$20(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; get object type
		mulu.w	#60,d0		; multiply by 60 (1 second)
		move.w	d0,$30(a0)	; set breakage time

Obj0B_Action:				; XREF: Obj0B_Index
		tst.b	$32(a0)
		beq.s	Obj0B_Grab
		tst.w	$30(a0)
		beq.s	Obj0B_MoveUp
		subq.w	#1,$30(a0)
		bne.s	Obj0B_MoveUp
		move.b	#1,$1A(a0)	; break	the pole
		bra.s	Obj0B_Release
; ===========================================================================

Obj0B_MoveUp:				; XREF: Obj0B_Action
		lea	($FFFFD000).w,a1
		move.w	$C(a0),d0
		subi.w	#$18,d0
		btst	#0,($FFFFF604).w ; check if "up" is pressed
		beq.s	Obj0B_MoveDown
		subq.w	#1,$C(a1)	; move Sonic up
		cmp.w	$C(a1),d0
		bcs.s	Obj0B_MoveDown
		move.w	d0,$C(a1)

Obj0B_MoveDown:
		addi.w	#$24,d0
		btst	#1,($FFFFF604).w ; check if "down" is pressed
		beq.s	Obj0B_LetGo
		addq.w	#1,$C(a1)	; move Sonic down
		cmp.w	$C(a1),d0
		bcc.s	Obj0B_LetGo
		move.w	d0,$C(a1)

Obj0B_LetGo:
		move.b	($FFFFF603).w,d0
		andi.w	#$70,d0
		beq.s	Obj0B_Display

Obj0B_Release:				; XREF: Obj0B_Action
		clr.b	$20(a0)
		addq.b	#2,$24(a0)
		clr.b	($FFFFF7C8).w
		clr.b	($FFFFF7C9).w
		clr.b	$32(a0)
		bra.s	Obj0B_Display
; ===========================================================================

Obj0B_Grab:				; XREF: Obj0B_Action
		tst.b	$21(a0)		; has Sonic touched the	pole?
		beq.s	Obj0B_Display	; if not, branch
		lea	($FFFFD000).w,a1
		move.w	8(a0),d0
		addi.w	#$14,d0
		cmp.w	8(a1),d0
		bcc.s	Obj0B_Display
		clr.b	$21(a0)
		cmpi.b	#4,$24(a1)
		bcc.s	Obj0B_Display
		clr.w	$10(a1)		; stop Sonic moving
		clr.w	$12(a1)		; stop Sonic moving
		move.w	8(a0),d0
		addi.w	#$14,d0
		move.w	d0,8(a1)
		bclr	#0,$22(a1)
		move.b	#$11,$1C(a1)	; set Sonic's animation to "hanging" ($11)
		move.b	#1,($FFFFF7C8).w ; lock	controls
		move.b	#1,($FFFFF7C9).w ; disable wind	tunnel
		move.b	#1,$32(a0)	; begin	countdown to breakage

Obj0B_Display:				; XREF: Obj0B_Index
		bra.w	MarkObjGone
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - pole that breaks (LZ)
; ---------------------------------------------------------------------------
Map_obj0B:
	include "_maps\obj0B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0C - flapping door (LZ)
; ---------------------------------------------------------------------------

Obj0C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj0C_Index(pc,d0.w),d1
		jmp	Obj0C_Index(pc,d1.w)
; ===========================================================================
Obj0C_Index:	dc.w Obj0C_Main-Obj0C_Index
		dc.w Obj0C_OpenClose-Obj0C_Index
; ===========================================================================

Obj0C_Main:				; XREF: Obj0C_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj0C,4(a0)
		move.w	#$4328,2(a0)
		ori.b	#4,1(a0)
		move.b	#$28,$19(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; get object type
		mulu.w	#60,d0		; multiply by 60 (1 second)
		move.w	d0,$32(a0)	; set flap delay time

Obj0C_OpenClose:			; XREF: Obj0C_Index
		subq.w	#1,$30(a0)	; subtract 1 from time delay
		bpl.s	Obj0C_Solid	; if time remains, branch
		move.w	$32(a0),$30(a0)	; reset	time delay
		bchg	#0,$1C(a0)	; open/close door
		tst.b	1(a0)
		bpl.s	Obj0C_Solid
		moveq	#sfx_Door,d0
		jsr	(PlaySound_Special).l ;	play door sound

Obj0C_Solid:
		lea	(Ani_obj0C).l,a1
		bsr.w	AnimateSprite
		clr.b	($FFFFF7C9).w	; enable wind tunnel
		tst.b	$1A(a0)		; is the door open?
		bne.s	Obj0C_Display	; if yes, branch
		move.w	($FFFFD008).w,d0
		cmp.w	8(a0),d0	; is Sonic in front of the door?
		bcc.s	Obj0C_Display	; if yes, branch
		move.b	#1,($FFFFF7C9).w ; disable wind	tunnel
		move.w	#$13,d1
		move.w	#$20,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	8(a0),d4
		bsr.w	SolidObject	; make the door	solid

Obj0C_Display:
		bra.w	MarkObjGone
; ===========================================================================
Ani_obj0C:
	include "_anim\obj0C.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - flapping door (LZ)
; ---------------------------------------------------------------------------
Map_obj0C:
	include "_maps\obj0C.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 71 - invisible	solid blocks
; ---------------------------------------------------------------------------

Obj71:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj71_Index(pc,d0.w),d1
		jmp	Obj71_Index(pc,d1.w)
; ===========================================================================
Obj71_Index:	dc.w Obj71_Main-Obj71_Index
		dc.w Obj71_Solid-Obj71_Index
; ===========================================================================

Obj71_Main:				; XREF: Obj71_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj71,4(a0)
		move.w	#$8680,2(a0)
		ori.b	#4,1(a0)
		move.b	$28(a0),d0	; get object type
		move.b	d0,d1
		andi.w	#$F0,d0		; read only the	1st byte
		addi.w	#$10,d0
		lsr.w	#1,d0
		move.b	d0,$19(a0)	; set object width
		andi.w	#$F,d1		; read only the	2nd byte
		addq.w	#1,d1
		lsl.w	#3,d1
		move.b	d1,$16(a0)	; set object height

Obj71_Solid:				; XREF: Obj71_Index
		bsr.w	ChkObjOnScreen
		bne.s	Obj71_ChkDel
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	$16(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	8(a0),d4
		bsr.w	SolidObject71

Obj71_ChkDel:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj71_Delete
		tst.w	($FFFFFE08).w	; are you using	debug mode?
		beq.s	Obj71_NoDisplay	; if not, branch
		jmp	DisplaySprite	; if yes, display the object
; ===========================================================================

Obj71_NoDisplay:
		rts
; ===========================================================================

Obj71_Delete:
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - invisible solid blocks
; ---------------------------------------------------------------------------
Map_obj71:
	include "_maps\obj71.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5D - fans (SLZ)
; ---------------------------------------------------------------------------

Obj5D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj5D_Index(pc,d0.w),d1
		jmp	Obj5D_Index(pc,d1.w)
; ===========================================================================
Obj5D_Index:	dc.w Obj5D_Main-Obj5D_Index
		dc.w Obj5D_Delay-Obj5D_Index
; ===========================================================================

Obj5D_Main:				; XREF: Obj5D_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj5D,4(a0)
		move.w	#$43A0,2(a0)
		ori.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#4,$18(a0)

Obj5D_Delay:				; XREF: Obj5D_Index
		btst	#1,$28(a0)	; is object type 02/03?
		bne.s	Obj5D_Blow	; if yes, branch
		subq.w	#1,$30(a0)	; subtract 1 from time delay
		bpl.s	Obj5D_Blow	; if time remains, branch
		move.w	#120,$30(a0)	; set delay to 2 seconds
		bchg	#0,$32(a0)	; switch fan on/off
		beq.s	Obj5D_Blow	; if fan is off, branch
		move.w	#180,$30(a0)	; set delay to 3 seconds

Obj5D_Blow:
		tst.b	$32(a0)		; is fan switched on?
		bne.w	Obj5D_ChkDel	; if not, branch
		lea	($FFFFD000).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		btst	#0,$22(a0)
		bne.s	Obj5D_ChkSonic
		neg.w	d0

Obj5D_ChkSonic:
		addi.w	#$50,d0
		cmpi.w	#$F0,d0		; is Sonic more	than $A0 pixels	from the fan?
		bcc.s	Obj5D_Animate	; if yes, branch
		move.w	$C(a1),d1
		addi.w	#$60,d1
		sub.w	$C(a0),d1
		bcs.s	Obj5D_Animate
		cmpi.w	#$70,d1
		bcc.s	Obj5D_Animate
		subi.w	#$50,d0
		bcc.s	loc_1159A
		not.w	d0
		add.w	d0,d0

loc_1159A:
		addi.w	#$60,d0
		btst	#0,$22(a0)
		bne.s	loc_115A8
		neg.w	d0

loc_115A8:
		neg.b	d0
		asr.w	#4,d0
		btst	#0,$28(a0)
		beq.s	Obj5D_MoveSonic
		neg.w	d0

Obj5D_MoveSonic:
		add.w	d0,8(a1)	; push Sonic away from the fan

Obj5D_Animate:				; XREF: Obj5D_ChkSonic
		subq.b	#1,$1E(a0)
		bpl.s	Obj5D_ChkDel
		move.b	#0,$1E(a0)
		addq.b	#1,$1B(a0)
		cmpi.b	#3,$1B(a0)
		bcs.s	loc_115D8
		move.b	#0,$1B(a0)

loc_115D8:
		moveq	#0,d0
		btst	#0,$28(a0)
		beq.s	loc_115E4
		moveq	#2,d0

loc_115E4:
		add.b	$1B(a0),d0
		move.b	d0,$1A(a0)

Obj5D_ChkDel:				; XREF: Obj5D_Animate
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - fans (SLZ)
; ---------------------------------------------------------------------------
Map_obj5D:
	include "_maps\obj5D.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5E - seesaws (SLZ)
; ---------------------------------------------------------------------------

Obj5E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj5E_Index(pc,d0.w),d1
		jsr	Obj5E_Index(pc,d1.w)
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		bmi.w	DeleteObject
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj5E_Index:	dc.w Obj5E_Main-Obj5E_Index
		dc.w Obj5E_Slope-Obj5E_Index
		dc.w Obj5E_Slope2-Obj5E_Index
		dc.w Obj5E_Spikeball-Obj5E_Index
		dc.w Obj5E_MoveSpike-Obj5E_Index
		dc.w Obj5E_SpikeFall-Obj5E_Index
; ===========================================================================

Obj5E_Main:				; XREF: Obj5E_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj5E,4(a0)
		move.w	#$374,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$30,$19(a0)
		move.w	8(a0),$30(a0)
		tst.b	$28(a0)		; is object type 00 ?
		bne.s	loc_116D2	; if not, branch
		bsr.w	SingleObjLoad2
		bne.s	loc_116D2
		move.b	#$5E,0(a1)	; load spikeball object
		addq.b	#6,$24(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$22(a0),$22(a1)
		move.l	a0,$3C(a1)

loc_116D2:
		btst	#0,$22(a0)
		beq.s	loc_116E0
		move.b	#2,$1A(a0)

loc_116E0:
		move.b	$1A(a0),$3A(a0)

Obj5E_Slope:				; XREF: Obj5E_Index
		move.b	$3A(a0),d1
		bsr.w	loc_11766
		lea	(Obj5E_Data1).l,a2
		btst	#0,$1A(a0)
		beq.s	loc_11702
		lea	(Obj5E_Data2).l,a2

loc_11702:
		lea	($FFFFD000).w,a1
		move.w	$12(a1),$38(a0)
		move.w	#$30,d1
		jsr	(SlopeObject).l
		rts
; ===========================================================================

Obj5E_Slope2:				; XREF: Obj5E_Index
		bsr.w	loc_1174A
		lea	(Obj5E_Data1).l,a2
		btst	#0,$1A(a0)
		beq.s	loc_11730
		lea	(Obj5E_Data2).l,a2

loc_11730:
		move.w	#$30,d1
		jsr	(ExitPlatform).l
		move.w	#$30,d1
		move.w	8(a0),d2
		jsr	SlopeObject2
		rts
; ===========================================================================

loc_1174A:				; XREF: Obj5E_Slope2
		moveq	#2,d1
		lea	($FFFFD000).w,a1
		move.w	8(a0),d0
		sub.w	8(a1),d0
		bcc.s	loc_1175E
		neg.w	d0
		moveq	#0,d1

loc_1175E:
		cmpi.w	#8,d0
		bcc.s	loc_11766
		moveq	#1,d1

loc_11766:
		move.b	$1A(a0),d0
		cmp.b	d1,d0
		beq.s	locret_11790
		bcc.s	loc_11772
		addq.b	#2,d0

loc_11772:
		subq.b	#1,d0
		move.b	d0,$1A(a0)
		move.b	d1,$3A(a0)
		bclr	#0,1(a0)
		btst	#1,$1A(a0)
		beq.s	locret_11790
		bset	#0,1(a0)

locret_11790:
		rts
; ===========================================================================

Obj5E_Spikeball:			; XREF: Obj5E_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj5Ea,4(a0)
		move.w	#$4F0,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$8B,$20(a0)
		move.b	#$C,$19(a0)
		move.w	8(a0),$30(a0)
		addi.w	#$28,8(a0)
		move.w	$C(a0),$34(a0)
		move.b	#1,$1A(a0)
		btst	#0,$22(a0)
		beq.s	Obj5E_MoveSpike
		subi.w	#$50,8(a0)
		move.b	#2,$3A(a0)

Obj5E_MoveSpike:			; XREF: Obj5E_Index
		movea.l	$3C(a0),a1
		moveq	#0,d0
		move.b	$3A(a0),d0
		sub.b	$3A(a1),d0
		beq.s	loc_1183E
		bcc.s	loc_117FC
		neg.b	d0

loc_117FC:
		move.w	#-$818,d1
		move.w	#-$114,d2
		cmpi.b	#1,d0
		beq.s	loc_11822
		move.w	#-$AF0,d1
		move.w	#-$CC,d2
		cmpi.w	#$A00,$38(a1)
		blt.s	loc_11822
		move.w	#-$E00,d1
		move.w	#-$A0,d2

loc_11822:
		move.w	d1,$12(a0)
		move.w	d2,$10(a0)
		move.w	8(a0),d0
		sub.w	$30(a0),d0
		bcc.s	loc_11838
		neg.w	$10(a0)

loc_11838:
		addq.b	#2,$24(a0)
		bra.s	Obj5E_SpikeFall
; ===========================================================================

loc_1183E:				; XREF: Obj5E_MoveSpike
		lea	(Obj5E_Speeds).l,a2
		moveq	#0,d0
		move.b	$1A(a1),d0
		move.w	#$28,d2
		move.w	8(a0),d1
		sub.w	$30(a0),d1
		bcc.s	loc_1185C
		neg.w	d2
		addq.w	#2,d0

loc_1185C:
		add.w	d0,d0
		move.w	$34(a0),d1
		add.w	(a2,d0.w),d1
		move.w	d1,$C(a0)
		add.w	$30(a0),d2
		move.w	d2,8(a0)
		clr.w	$E(a0)
		clr.w	$A(a0)
		rts
; ===========================================================================

Obj5E_SpikeFall:			; XREF: Obj5E_Index
		tst.w	$12(a0)
		bpl.s	loc_1189A
		bsr.w	ObjectFall
		move.w	$34(a0),d0
		subi.w	#$2F,d0
		cmp.w	$C(a0),d0
		bgt.s	locret_11898
		bsr.w	ObjectFall

locret_11898:
		rts
; ===========================================================================

loc_1189A:				; XREF: Obj5E_SpikeFall
		bsr.w	ObjectFall
		movea.l	$3C(a0),a1
		lea	(Obj5E_Speeds).l,a2
		moveq	#0,d0
		move.b	$1A(a1),d0
		move.w	8(a0),d1
		sub.w	$30(a0),d1
		bcc.s	loc_118BA
		addq.w	#2,d0

loc_118BA:
		add.w	d0,d0
		move.w	$34(a0),d1
		add.w	(a2,d0.w),d1
		cmp.w	$C(a0),d1
		bgt.s	locret_11938
		movea.l	$3C(a0),a1
		moveq	#2,d1
		tst.w	$10(a0)
		bmi.s	Obj5E_Spring
		moveq	#0,d1

Obj5E_Spring:
		move.b	d1,$3A(a1)
		move.b	d1,$3A(a0)
		cmp.b	$1A(a1),d1
		beq.s	loc_1192C
		bclr	#3,$22(a1)
		beq.s	loc_1192C
		clr.b	$25(a1)
		move.b	#2,$24(a1)
		lea	($FFFFD000).w,a2
		move.w	$12(a0),$12(a2)
		neg.w	$12(a2)
		bset	#1,$22(a2)
		bclr	#3,$22(a2)
		clr.b	$3C(a2)
		move.b	#$10,$1C(a2)	; change Sonic's animation to "spring" ($10)
		move.b	#2,$24(a2)
		moveq	#sfx_Spring,d0
		jsr	(PlaySound_Special).l ;	play spring sound

loc_1192C:
		clr.w	$10(a0)
		clr.w	$12(a0)
		subq.b	#2,$24(a0)

locret_11938:
		rts
; ===========================================================================
Obj5E_Speeds:	dc.w $FFF8, $FFE4, $FFD1, $FFE4, $FFF8

Obj5E_Data1:	incbin	misc\slzssaw1.bin
		even
Obj5E_Data2:	incbin	misc\slzssaw2.bin
		even
; ---------------------------------------------------------------------------
; Sprite mappings - seesaws (SLZ)
; ---------------------------------------------------------------------------
Map_obj5E:
	include "_maps\obj5E.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - spiked balls on the	seesaws	(SLZ)
; ---------------------------------------------------------------------------
Map_obj5Ea:
	include "_maps\obj5Eballs.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5F - walking bomb enemy (SLZ, SBZ)
; ---------------------------------------------------------------------------

Obj5F:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj5F_Index(pc,d0.w),d1
		jmp	Obj5F_Index(pc,d1.w)
; ===========================================================================
Obj5F_Index:	dc.w Obj5F_Main-Obj5F_Index
		dc.w Obj5F_Action-Obj5F_Index
		dc.w Obj5F_Display-Obj5F_Index
		dc.w Obj5F_End-Obj5F_Index
; ===========================================================================

Obj5F_Main:				; XREF: Obj5F_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj5F,4(a0)
		move.w	#$400,2(a0)
		ori.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$C,$19(a0)
		move.b	$28(a0),d0
		beq.s	loc_11A3C
		move.b	d0,$24(a0)
		rts
; ===========================================================================

loc_11A3C:
		move.b	#$9A,$20(a0)
		bchg	#0,$22(a0)

Obj5F_Action:				; XREF: Obj5F_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj5F_Index2(pc,d0.w),d1
		jsr	Obj5F_Index2(pc,d1.w)
		lea	(Ani_obj5F).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj5F_Index2:	dc.w Obj5F_Walk-Obj5F_Index2
		dc.w Obj5F_Wait-Obj5F_Index2
		dc.w Obj5F_Explode-Obj5F_Index2
; ===========================================================================

Obj5F_Walk:				; XREF: Obj5F_Index2
		bsr.w	Obj5F_ChkSonic
		subq.w	#1,$30(a0)	; subtract 1 from time delay
		bpl.s	locret_11A96	; if time remains, branch
		addq.b	#2,$25(a0)
		move.w	#1535,$30(a0)	; set time delay to 25 seconds
		move.w	#$10,$10(a0)
		move.b	#1,$1C(a0)
		bchg	#0,$22(a0)
		beq.s	locret_11A96
		neg.w	$10(a0)		; change direction

locret_11A96:
		rts
; ===========================================================================

Obj5F_Wait:				; XREF: Obj5F_Index2
		bsr.w	Obj5F_ChkSonic
		subq.w	#1,$30(a0)	; subtract 1 from time delay
		bmi.s	loc_11AA8
		bsr.w	SpeedToPos
		rts
; ===========================================================================

loc_11AA8:
		subq.b	#2,$25(a0)
		move.w	#179,$30(a0)	; set time delay to 3 seconds
		clr.w	$10(a0)		; stop walking
		move.b	#0,$1C(a0)	; stop animation
		rts
; ===========================================================================

Obj5F_Explode:				; XREF: Obj5F_Index2
		subq.w	#1,$30(a0)
		bpl.s	locret_11AD0
		move.b	#$3F,0(a0)	; change bomb into an explosion
		move.b	#0,$24(a0)

locret_11AD0:
		rts
; ===========================================================================

Obj5F_ChkSonic:				; XREF: Obj5F_Walk; Obj5F_Wait
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_11ADE
		neg.w	d0

loc_11ADE:
		cmpi.w	#$60,d0
		bcc.s	locret_11B5E
		move.w	($FFFFD00C).w,d0
		sub.w	$C(a0),d0
		bcc.s	Obj5F_MakeFuse
		neg.w	d0

Obj5F_MakeFuse:
		cmpi.w	#$60,d0
		bcc.s	locret_11B5E
		tst.w	($FFFFFE08).w
		bne.s	locret_11B5E
		move.b	#4,$25(a0)
		move.w	#143,$30(a0)	; set fuse time
		clr.w	$10(a0)
		move.b	#2,$1C(a0)
		bsr.w	SingleObjLoad2
		bne.s	locret_11B5E
		move.b	#$5F,0(a1)	; load fuse object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	$C(a0),$34(a1)
		move.b	$22(a0),$22(a1)
		move.b	#4,$28(a1)
		move.b	#3,$1C(a1)
		move.w	#$10,$12(a1)
		btst	#1,$22(a0)
		beq.s	loc_11B54
		neg.w	$12(a1)

loc_11B54:
		move.w	#143,$30(a1)	; set fuse time
		move.l	a0,$3C(a1)

locret_11B5E:
		rts
; ===========================================================================

Obj5F_Display:				; XREF: Obj5F_Index
		bsr.s	loc_11B70
		lea	(Ani_obj5F).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================

loc_11B70:
		subq.w	#1,$30(a0)
		bmi.s	loc_11B7C
		bsr.w	SpeedToPos
		rts
; ===========================================================================

loc_11B7C:
		clr.w	$30(a0)
		clr.b	$24(a0)
		move.w	$34(a0),$C(a0)
		moveq	#3,d1
		movea.l	a0,a1
		lea	(Obj5F_ShrSpeed).l,a2 ;	load shrapnel speed data
		bra.s	Obj5F_MakeShrap
; ===========================================================================

Obj5F_Loop:
		bsr.w	SingleObjLoad2
		bne.s	loc_11BCE

Obj5F_MakeShrap:			; XREF: loc_11B7C
		move.b	#$5F,0(a1)	; load shrapnel	object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#6,$28(a1)
		move.b	#4,$1C(a1)
		move.w	(a2)+,$10(a1)
		move.w	(a2)+,$12(a1)
		move.b	#$98,$20(a1)
		bset	#7,1(a1)

loc_11BCE:
		dbf	d1,Obj5F_Loop	; repeat 3 more	times

		move.b	#6,$24(a0)

Obj5F_End:				; XREF: Obj5F_Index
		bsr.w	SpeedToPos
		addi.w	#$18,$12(a0)
		lea	(Ani_obj5F).l,a1
		bsr.w	AnimateSprite
		tst.b	1(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj5F_ShrSpeed:	dc.w $FE00, $FD00, $FF00, $FE00, $200, $FD00, $100, $FE00

Ani_obj5F:
	include "_anim\obj5F.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - walking bomb enemy (SLZ, SBZ)
; ---------------------------------------------------------------------------
Map_obj5F:
	include "_maps\obj5F.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 60 - Orbinaut enemy (LZ, SLZ, SBZ)
; ---------------------------------------------------------------------------

Obj60:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj60_Index(pc,d0.w),d1
		jmp	Obj60_Index(pc,d1.w)
; ===========================================================================
Obj60_Index:	dc.w Obj60_Main-Obj60_Index
		dc.w Obj60_ChkSonic-Obj60_Index
		dc.w Obj60_Display-Obj60_Index
		dc.w Obj60_MoveOrb-Obj60_Index
		dc.w Obj60_ChkDel2-Obj60_Index
; ===========================================================================

Obj60_Main:				; XREF: Obj60_Index
		move.l	#Map_obj60,4(a0)
		move.w	#$429,2(a0)	; SBZ specific code
		cmpi.b	#5,($FFFFFE10).w ; check if level is SBZ
		beq.s	loc_11D02
		move.w	#$2429,2(a0)	; SLZ specific code

loc_11D02:
		cmpi.b	#1,($FFFFFE10).w ; check if level is LZ
		bne.s	loc_11D10
		move.w	#$467,2(a0)	; LZ specific code

loc_11D10:
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$B,$20(a0)
		move.b	#$C,$19(a0)
		moveq	#0,d2
		lea	$37(a0),a2
		movea.l	a2,a3
		addq.w	#1,a2
		moveq	#3,d1

Obj60_MakeOrbs:
		bsr.w	SingleObjLoad2
		bne.s	loc_11D90
		addq.b	#1,(a3)
		move.w	a1,d5
		subi.w	#-$3000,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	0(a0),0(a1)	; load spiked orb object
		move.b	#6,$24(a1)
		move.l	4(a0),4(a1)
		move.w	2(a0),2(a1)
		ori.b	#4,1(a1)
		move.b	#4,$18(a1)
		move.b	#8,$19(a1)
		move.b	#3,$1A(a1)
		move.b	#$98,$20(a1)
		move.b	d2,$26(a1)
		addi.b	#$40,d2
		move.l	a0,$3C(a1)
		dbf	d1,Obj60_MakeOrbs ; repeat sequence 3 more times

loc_11D90:
		moveq	#1,d0
		btst	#0,$22(a0)
		beq.s	Obj60_Move
		neg.w	d0

Obj60_Move:
		move.b	d0,$36(a0)
		move.b	$28(a0),$24(a0)	; if type is 02, skip the firing rountine
		addq.b	#2,$24(a0)
		move.w	#-$40,$10(a0)	; move orbinaut	to the left
		btst	#0,$22(a0)	; is orbinaut reversed?
		beq.s	locret_11DBC	; if not, branch
		neg.w	$10(a0)		; move orbinaut	to the right

locret_11DBC:
		rts
; ===========================================================================

Obj60_ChkSonic:				; XREF: Obj60_Index
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_11DCA
		neg.w	d0

loc_11DCA:
		cmpi.w	#$A0,d0		; is Sonic within $A0 pixels of	orbinaut?
		bcc.s	Obj60_Animate	; if not, branch
		move.w	($FFFFD00C).w,d0
		sub.w	$C(a0),d0
		bcc.s	loc_11DDC
		neg.w	d0

loc_11DDC:
		cmpi.w	#$50,d0		; is Sonic within $50 pixels of	orbinaut?
		bcc.s	Obj60_Animate	; if not, branch
		tst.w	($FFFFFE08).w	; is debug mode	on?
		bne.s	Obj60_Animate	; if yes, branch
		move.b	#1,$1C(a0)	; use "angry" animation

Obj60_Animate:
		lea	(Ani_obj60).l,a1
		bsr.w	AnimateSprite
		bra.w	Obj60_ChkDel
; ===========================================================================

Obj60_Display:				; XREF: Obj60_Index
		bsr.w	SpeedToPos

Obj60_ChkDel:				; XREF: Obj60_Animate
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj60_ChkGone
		bra.w	DisplaySprite
; ===========================================================================

Obj60_ChkGone:				; XREF: Obj60_ChkDel
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_11E34
		bclr	#7,2(a2,d0.w)

loc_11E34:
		lea	$37(a0),a2
		moveq	#0,d2
		move.b	(a2)+,d2
		subq.w	#1,d2
		bcs.s	Obj60_Delete

loc_11E40:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#$FFD000,d0
		movea.l	d0,a1
		bsr.w	DeleteObject2
		dbf	d2,loc_11E40

Obj60_Delete:
		bra.w	DeleteObject
; ===========================================================================

Obj60_MoveOrb:				; XREF: Obj60_Index
		movea.l	$3C(a0),a1
		cmpi.b	#$60,0(a1)
		bne.w	DeleteObject
		cmpi.b	#2,$1A(a1)
		bne.s	Obj60_Circle
		cmpi.b	#$40,$26(a0)
		bne.s	Obj60_Circle
		addq.b	#2,$24(a0)
		subq.b	#1,$37(a1)
		bne.s	Obj60_FireOrb
		addq.b	#2,$24(a1)

Obj60_FireOrb:
		move.w	#-$200,$10(a0)	; move orb to the left (quickly)
		btst	#0,$22(a1)
		beq.s	Obj60_Display2
		neg.w	$10(a0)

Obj60_Display2:
		bra.w	DisplaySprite
; ===========================================================================

Obj60_Circle:				; XREF: Obj60_MoveOrb
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		asr.w	#4,d1
		add.w	8(a1),d1
		move.w	d1,8(a0)
		asr.w	#4,d0
		add.w	$C(a1),d0
		move.w	d0,$C(a0)
		move.b	$36(a1),d0
		add.b	d0,$26(a0)
		bra.w	DisplaySprite
; ===========================================================================

Obj60_ChkDel2:				; XREF: Obj60_Index
		bsr.w	SpeedToPos
		tst.b	1(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Ani_obj60:
	include "_anim\obj60.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Orbinaut enemy (LZ,	SLZ, SBZ)
; ---------------------------------------------------------------------------
Map_obj60:
	include "_maps\obj60.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 16 - harpoon (LZ)
; ---------------------------------------------------------------------------

Obj16:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj16_Index(pc,d0.w),d1
		jmp	Obj16_Index(pc,d1.w)
; ===========================================================================
Obj16_Index:	dc.w Obj16_Main-Obj16_Index
		dc.w Obj16_Move-Obj16_Index
		dc.w Obj16_Wait-Obj16_Index
; ===========================================================================

Obj16_Main:				; XREF: Obj16_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj16,4(a0)
		move.w	#$3CC,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	$28(a0),$1C(a0)
		move.b	#$14,$19(a0)
		move.w	#60,$30(a0)

Obj16_Move:				; XREF: Obj16_Index
		lea	(Ani_obj16).l,a1
		bsr.w	AnimateSprite
		moveq	#0,d0
		move.b	$1A(a0),d0	; move frame number to d0
		move.b	Obj16_Data(pc,d0.w),$20(a0) ; load collision response (based on	d0)
		bra.w	MarkObjGone
; ===========================================================================
Obj16_Data:	dc.b $9B, $9C, $9D, $9E, $9F, $A0
; ===========================================================================

Obj16_Wait:				; XREF: Obj16_Index
		subq.w	#1,$30(a0)
		bpl.s	Obj16_ChkDel
		move.w	#60,$30(a0)
		subq.b	#2,$24(a0)	; run "Obj16_Move" subroutine
		bchg	#0,$1C(a0)	; reverse animation

Obj16_ChkDel:
		bra.w	MarkObjGone
; ===========================================================================
Ani_obj16:
	include "_anim\obj16.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - harpoon (LZ)
; ---------------------------------------------------------------------------
Map_obj16:
	include "_maps\obj16.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 61 - blocks (LZ)
; ---------------------------------------------------------------------------

Obj61:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj61_Index(pc,d0.w),d1
		jmp	Obj61_Index(pc,d1.w)
; ===========================================================================
Obj61_Index:	dc.w Obj61_Main-Obj61_Index
		dc.w Obj61_Action-Obj61_Index

Obj61_Var:	dc.b $10, $10		; width, height
		dc.b $20, $C
		dc.b $10, $10
		dc.b $10, $10
; ===========================================================================

Obj61_Main:				; XREF: Obj61_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj61,4(a0)
		move.w	#$43E6,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		lsr.w	#3,d0
		andi.w	#$E,d0
		lea	Obj61_Var(pc,d0.w),a2
		move.b	(a2)+,$19(a0)
		move.b	(a2),$16(a0)
		lsr.w	#1,d0
		move.b	d0,$1A(a0)
		move.w	8(a0),$34(a0)
		move.w	$C(a0),$30(a0)
		move.b	$28(a0),d0
		andi.b	#$F,d0
		beq.s	Obj61_Action
		cmpi.b	#7,d0
		beq.s	Obj61_Action
		move.b	#1,$38(a0)

Obj61_Action:				; XREF: Obj61_Index
		move.w	8(a0),-(sp)
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	Obj61_TypeIndex(pc,d0.w),d1
		jsr	Obj61_TypeIndex(pc,d1.w)
		move.w	(sp)+,d4
		tst.b	1(a0)
		bpl.s	Obj61_ChkDel
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	$16(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		bsr.w	SolidObject
		move.b	d4,$3F(a0)
		bsr.w	loc_12180

Obj61_ChkDel:
		move.w	$34(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj61_TypeIndex:dc.w Obj61_Type00-Obj61_TypeIndex, Obj61_Type01-Obj61_TypeIndex
		dc.w Obj61_Type02-Obj61_TypeIndex, Obj61_Type01-Obj61_TypeIndex
		dc.w Obj61_Type04-Obj61_TypeIndex, Obj61_Type05-Obj61_TypeIndex
		dc.w Obj61_Type02-Obj61_TypeIndex, Obj61_Type07-Obj61_TypeIndex
; ===========================================================================

Obj61_Type00:				; XREF: Obj61_TypeIndex
		rts
; ===========================================================================

Obj61_Type01:				; XREF: Obj61_TypeIndex
		tst.w	$36(a0)		; is Sonic standing on the object?
		bne.s	loc_120D6	; if yes, branch
		btst	#3,$22(a0)
		beq.s	locret_120D4
		move.w	#30,$36(a0)	; wait for « second

locret_120D4:
		rts
; ===========================================================================

loc_120D6:
		subq.w	#1,$36(a0)	; subtract 1 from waiting time
		bne.s	locret_120D4	; if time remains, branch
		addq.b	#1,$28(a0)	; add 1	to type
		clr.b	$38(a0)
		rts
; ===========================================================================

Obj61_Type02:				; XREF: Obj61_TypeIndex
		bsr.w	SpeedToPos
		addq.w	#8,$12(a0)	; make object fall
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.w	locret_12106
		addq.w	#1,d1
		add.w	d1,$C(a0)
		clr.w	$12(a0)		; stop when it touches the floor
		clr.b	$28(a0)		; set type to 00 (non-moving type)

locret_12106:
		rts
; ===========================================================================

Obj61_Type04:				; XREF: Obj61_TypeIndex
		bsr.w	SpeedToPos
		subq.w	#8,$12(a0)	; make object rise
		bsr.w	ObjHitCeiling
		tst.w	d1
		bpl.w	locret_12126
		sub.w	d1,$C(a0)
		clr.w	$12(a0)		; stop when it touches the ceiling
		clr.b	$28(a0)		; set type to 00 (non-moving type)

locret_12126:
		rts
; ===========================================================================

Obj61_Type05:				; XREF: Obj61_TypeIndex
		cmpi.b	#1,$3F(a0)	; is Sonic touching the	object?
		bne.s	locret_12138	; if not, branch
		addq.b	#1,$28(a0)	; if yes, add 1	to type
		clr.b	$38(a0)

locret_12138:
		rts
; ===========================================================================

Obj61_Type07:				; XREF: Obj61_TypeIndex
		move.w	($FFFFF646).w,d0
		sub.w	$C(a0),d0
		beq.s	locret_1217E
		bcc.s	loc_12162
		cmpi.w	#-2,d0
		bge.s	loc_1214E
		moveq	#-2,d0

loc_1214E:
		add.w	d0,$C(a0)	; make the block rise with water level
		bsr.w	ObjHitCeiling
		tst.w	d1
		bpl.w	locret_12160
		sub.w	d1,$C(a0)

locret_12160:
		rts
; ===========================================================================

loc_12162:				; XREF: Obj61_Type07
		cmpi.w	#2,d0
		ble.s	loc_1216A
		moveq	#2,d0

loc_1216A:
		add.w	d0,$C(a0)	; make the block sink with water level
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.w	locret_1217E
		addq.w	#1,d1
		add.w	d1,$C(a0)

locret_1217E:
		rts
; ===========================================================================

loc_12180:				; XREF: Obj61_Action
		tst.b	$38(a0)
		beq.s	locret_121C0
		btst	#3,$22(a0)
		bne.s	loc_1219A
		tst.b	$3E(a0)
		beq.s	locret_121C0
		subq.b	#4,$3E(a0)
		bra.s	loc_121A6
; ===========================================================================

loc_1219A:
		cmpi.b	#$40,$3E(a0)
		beq.s	locret_121C0
		addq.b	#4,$3E(a0)

loc_121A6:
		move.b	$3E(a0),d0
		jsr	(CalcSine).l
		move.w	#$400,d1
		muls.w	d1,d0
		swap	d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)

locret_121C0:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - blocks (LZ)
; ---------------------------------------------------------------------------
Map_obj61:
	include "_maps\obj61.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 62 - gargoyle head (LZ)
; ---------------------------------------------------------------------------

Obj62:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj62_Index(pc,d0.w),d1
		jsr	Obj62_Index(pc,d1.w)
		bra.w	MarkObjGone
; ===========================================================================
Obj62_Index:	dc.w Obj62_Main-Obj62_Index
		dc.w Obj62_MakeFire-Obj62_Index
		dc.w Obj62_FireBall-Obj62_Index
		dc.w Obj62_AniFire-Obj62_Index

Obj62_SpitRate:	dc.b 30, 60, 90, 120, 150, 180,	210, 240
; ===========================================================================

Obj62_Main:				; XREF: Obj62_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj62,4(a0)
		move.w	#$42E9,2(a0)
		ori.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$10,$19(a0)
		move.b	$28(a0),d0	; get object type
		andi.w	#$F,d0		; read only the	2nd digit
		move.b	Obj62_SpitRate(pc,d0.w),$1F(a0)	; set fireball spit rate
		move.b	$1F(a0),$1E(a0)
		andi.b	#$F,$28(a0)

Obj62_MakeFire:				; XREF: Obj62_Index
		subq.b	#1,$1E(a0)
		bne.s	Obj62_NoFire
		move.b	$1F(a0),$1E(a0)
		bsr.w	ChkObjOnScreen
		bne.s	Obj62_NoFire
		bsr.w	SingleObjLoad
		bne.s	Obj62_NoFire
		move.b	#$62,0(a1)	; load fireball	object
		addq.b	#4,$24(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	1(a0),1(a1)
		move.b	$22(a0),$22(a1)

Obj62_NoFire:
		rts
; ===========================================================================

Obj62_FireBall:				; XREF: Obj62_Index
		addq.b	#2,$24(a0)
		move.b	#8,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_obj62,4(a0)
		move.w	#$2E9,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$98,$20(a0)
		move.b	#8,$19(a0)
		move.b	#2,$1A(a0)
		addq.w	#8,$C(a0)
		move.w	#$200,$10(a0)
		btst	#0,$22(a0)
		bne.s	Obj62_Sound
		neg.w	$10(a0)

Obj62_Sound:
		moveq	#sfx_LavaBall,d0
		jsr	(PlaySound_Special).l ;	play lava ball sound

Obj62_AniFire:				; XREF: Obj62_Index
		move.b	($FFFFFE05).w,d0
		andi.b	#7,d0
		bne.s	Obj62_StopFire
		bchg	#0,$1A(a0)	; switch between frame 01 and 02

Obj62_StopFire:
		bsr.w	SpeedToPos
		btst	#0,$22(a0)
		bne.s	Obj62_StopFire2
		moveq	#-8,d3
		bsr.w	ObjHitWallLeft
		tst.w	d1
		bmi.w	DeleteObject	; delete if the	fireball hits a	wall
		rts
; ===========================================================================

Obj62_StopFire2:
		moveq	#8,d3
		bsr.w	ObjHitWallRight
		tst.w	d1
		bmi.w	DeleteObject
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - gargoyle head (LZ)
; ---------------------------------------------------------------------------
Map_obj62:
	include "_maps\obj62.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 63 - platforms	on a conveyor belt (LZ)
; ---------------------------------------------------------------------------

Obj63:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj63_Index(pc,d0.w),d1
		jsr	Obj63_Index(pc,d1.w)
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	loc_1236A

Obj63_Display:				; XREF: loc_1236A
		bra.w	DisplaySprite
; ===========================================================================

loc_1236A:				; XREF: Obj63
		cmpi.b	#2,($FFFFFE11).w
		bne.s	loc_12378
		cmpi.w	#-$80,d0
		bcc.s	Obj63_Display

loc_12378:
		move.b	$2F(a0),d0
		bpl.w	DeleteObject
		andi.w	#$7F,d0
		lea	($FFFFF7C1).w,a2
		bclr	#0,(a2,d0.w)
		bra.w	DeleteObject
; ===========================================================================
Obj63_Index:	dc.w Obj63_Main-Obj63_Index
		dc.w loc_124B2-Obj63_Index
		dc.w loc_124C2-Obj63_Index
		dc.w loc_124DE-Obj63_Index
; ===========================================================================

Obj63_Main:				; XREF: Obj63_Index
		move.b	$28(a0),d0
		bmi.w	loc_12460
		addq.b	#2,$24(a0)
		move.l	#Map_obj63,4(a0)
		move.w	#$43F6,2(a0)
		ori.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#4,$18(a0)
		cmpi.b	#$7F,$28(a0)
		bne.s	loc_123E2
		addq.b	#4,$24(a0)
		move.w	#$3F6,2(a0)
		move.b	#1,$18(a0)
		bra.w	loc_124DE
; ===========================================================================

loc_123E2:
		move.b	#4,$1A(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		move.w	d0,d1
		lsr.w	#3,d0
		andi.w	#$1E,d0
		lea	Obj63_Data(pc),a2
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,$38(a0)
		move.w	(a2)+,$30(a0)
		move.l	a2,$3C(a0)
		andi.w	#$F,d1
		lsl.w	#2,d1
		move.b	d1,$38(a0)
		move.b	#4,$3A(a0)
		tst.b	($FFFFF7C0).w
		beq.s	loc_1244C
		move.b	#1,$3B(a0)
		neg.b	$3A(a0)
		moveq	#0,d1
		move.b	$38(a0),d1
		add.b	$3A(a0),d1
		cmp.b	$39(a0),d1
		bcs.s	loc_12448
		move.b	d1,d0
		moveq	#0,d1
		tst.b	d0
		bpl.s	loc_12448
		move.b	$39(a0),d1
		subq.b	#4,d1

loc_12448:
		move.b	d1,$38(a0)

loc_1244C:
		move.w	(a2,d1.w),$34(a0)
		move.w	2(a2,d1.w),$36(a0)
		bsr.w	Obj63_ChangeDir
		bra.w	loc_124B2
; ===========================================================================

loc_12460:				; XREF: Obj63_Main
		move.b	d0,$2F(a0)
		andi.w	#$7F,d0
		lea	($FFFFF7C1).w,a2
		bset	#0,(a2,d0.w)
		bne.w	DeleteObject
		add.w	d0,d0
		andi.w	#$1E,d0
		addi.w	#$70,d0
		lea	(ObjPos_Index).l,a2
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d1
		movea.l	a0,a1
		bra.s	Obj63_MakePtfms
; ===========================================================================

Obj63_Loop:
		bsr.w	SingleObjLoad
		bne.s	loc_124AA

Obj63_MakePtfms:			; XREF: loc_12460
		move.b	#$63,0(a1)
		move.w	(a2)+,8(a1)
		move.w	(a2)+,$C(a1)
		move.w	(a2)+,d0
		move.b	d0,$28(a1)

loc_124AA:
		dbf	d1,Obj63_Loop

		addq.l	#4,sp
		rts
; ===========================================================================

loc_124B2:				; XREF: Obj63_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(PlatformObject).l
		bra.w	sub_12502
; ===========================================================================

loc_124C2:				; XREF: Obj63_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(ExitPlatform).l
		move.w	8(a0),-(sp)
		bsr.w	sub_12502
		move.w	(sp)+,d2
		jmp	(MvSonicOnPtfm2).l
; ===========================================================================

loc_124DE:				; XREF: Obj63_Index
		move.w	($FFFFFE04).w,d0
		andi.w	#3,d0
		bne.s	loc_124FC
		moveq	#1,d1
		tst.b	($FFFFF7C0).w
		beq.s	loc_124F2
		neg.b	d1

loc_124F2:
		add.b	d1,$1A(a0)
		andi.b	#3,$1A(a0)

loc_124FC:
		addq.l	#4,sp
		bra.w	MarkObjGone

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_12502:				; XREF: loc_124B2; loc_124C2
		tst.b	($FFFFF7EE).w
		beq.s	loc_12520
		tst.b	$3B(a0)
		bne.s	loc_12520
		move.b	#1,$3B(a0)
		move.b	#1,($FFFFF7C0).w
		neg.b	$3A(a0)
		bra.s	loc_12534
; ===========================================================================

loc_12520:
		move.w	8(a0),d0
		cmp.w	$34(a0),d0
		bne.s	loc_1256A
		move.w	$C(a0),d0
		cmp.w	$36(a0),d0
		bne.s	loc_1256A

loc_12534:
		moveq	#0,d1
		move.b	$38(a0),d1
		add.b	$3A(a0),d1
		cmp.b	$39(a0),d1
		bcs.s	loc_12552
		move.b	d1,d0
		moveq	#0,d1
		tst.b	d0
		bpl.s	loc_12552
		move.b	$39(a0),d1
		subq.b	#4,d1

loc_12552:
		move.b	d1,$38(a0)
		movea.l	$3C(a0),a1
		move.w	(a1,d1.w),$34(a0)
		move.w	2(a1,d1.w),$36(a0)
		bsr.w	Obj63_ChangeDir

loc_1256A:
		bsr.w	SpeedToPos
		rts
; End of function sub_12502


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj63_ChangeDir:			; XREF: loc_123E2; sub_12502
		moveq	#0,d0
		move.w	#-$100,d2
		move.w	8(a0),d0
		sub.w	$34(a0),d0
		bcc.s	loc_12584
		neg.w	d0
		neg.w	d2

loc_12584:
		moveq	#0,d1
		move.w	#-$100,d3
		move.w	$C(a0),d1
		sub.w	$36(a0),d1
		bcc.s	loc_12598
		neg.w	d1
		neg.w	d3

loc_12598:
		cmp.w	d0,d1
		bcs.s	loc_125C2
		move.w	8(a0),d0
		sub.w	$34(a0),d0
		beq.s	loc_125AE
		ext.l	d0
		asl.l	#8,d0
		divs.w	d1,d0
		neg.w	d0

loc_125AE:
		move.w	d0,$10(a0)
		move.w	d3,$12(a0)
		swap	d0
		move.w	d0,$A(a0)
		clr.w	$E(a0)
		rts
; ===========================================================================

loc_125C2:				; XREF: Obj63_ChangeDir
		move.w	$C(a0),d1
		sub.w	$36(a0),d1
		beq.s	loc_125D4
		ext.l	d1
		asl.l	#8,d1
		divs.w	d0,d1
		neg.w	d1

loc_125D4:
		move.w	d1,$12(a0)
		move.w	d2,$10(a0)
		swap	d1
		move.w	d1,$E(a0)
		clr.w	$A(a0)
		rts
; End of function Obj63_ChangeDir

; ===========================================================================
Obj63_Data:	dc.w word_125F4-Obj63_Data
		dc.w word_12610-Obj63_Data
		dc.w word_12628-Obj63_Data
		dc.w word_1263C-Obj63_Data
		dc.w word_12650-Obj63_Data
		dc.w word_12668-Obj63_Data
word_125F4:	dc.w $18, $1070, $1078,	$21A, $10BE, $260, $10BE, $393
		dc.w $108C, $3C5, $1022, $390, $1022, $244
word_12610:	dc.w $14, $1280, $127E,	$280, $12CE, $2D0, $12CE, $46E
		dc.w $1232, $420, $1232, $2CC
word_12628:	dc.w $10, $D68,	$D22, $482, $D22, $5DE,	$DAE, $5DE, $DAE, $482
word_1263C:	dc.w $10, $DA0,	$D62, $3A2, $DEE, $3A2,	$DEE, $4DE, $D62, $4DE
word_12650:	dc.w $14, $D00,	$CAC, $242, $DDE, $242,	$DDE, $3DE, $C52, $3DE,	$C52, $29C
word_12668:	dc.w $10, $1300, $1252,	$20A, $13DE, $20A, $13DE, $2BE,	$1252, $2BE

; ---------------------------------------------------------------------------
; Sprite mappings - platforms on a conveyor belt (LZ)
; ---------------------------------------------------------------------------
Map_obj63:
	include "_maps\obj63.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 64 - bubbles (LZ)
; ---------------------------------------------------------------------------

Obj64:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj64_Index(pc,d0.w),d1
		jmp	Obj64_Index(pc,d1.w)
; ===========================================================================
Obj64_Index:	dc.w Obj64_Main-Obj64_Index
		dc.w Obj64_Animate-Obj64_Index
		dc.w Obj64_ChkWater-Obj64_Index
		dc.w Obj64_Display2-Obj64_Index
		dc.w Obj64_Delete3-Obj64_Index
		dc.w Obj64_BblMaker-Obj64_Index
; ===========================================================================

Obj64_Main:				; XREF: Obj64_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj64,4(a0)
		move.w	#$8348,2(a0)
		move.b	#$84,1(a0)
		move.b	#$10,$19(a0)
		move.b	#1,$18(a0)
		move.b	$28(a0),d0	; get object type
		bpl.s	Obj64_Bubble	; if type is $0-$7F, branch
		addq.b	#8,$24(a0)
		andi.w	#$7F,d0		; read only last 7 bits	(deduct	$80)
		move.b	d0,$32(a0)
		move.b	d0,$33(a0)
		move.b	#6,$1C(a0)
		bra.w	Obj64_BblMaker
; ===========================================================================

Obj64_Bubble:				; XREF: Obj64_Main
		move.b	d0,$1C(a0)
		move.w	8(a0),$30(a0)
		move.w	#-$88,$12(a0)	; float	bubble upwards
		jsr	(RandomNumber).l
		move.b	d0,$26(a0)

Obj64_Animate:				; XREF: Obj64_Index
		lea	(Ani_obj64).l,a1
		jsr	AnimateSprite
		cmpi.b	#6,$1A(a0)
		bne.s	Obj64_ChkWater
		move.b	#1,$2E(a0)

Obj64_ChkWater:				; XREF: Obj64_Index
		move.w	($FFFFF646).w,d0
		cmp.w	$C(a0),d0	; is bubble underwater?
		bcs.s	Obj64_Wobble	; if yes, branch

Obj64_Burst:				; XREF: Obj64_Wobble
		move.b	#6,$24(a0)
		addq.b	#3,$1C(a0)	; run "bursting" animation
		bra.w	Obj64_Display2
; ===========================================================================

Obj64_Wobble:				; XREF: Obj64_ChkWater
		move.b	$26(a0),d0
		addq.b	#1,$26(a0)
		andi.w	#$7F,d0
		lea	(Obj0A_WobbleData).l,a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	$30(a0),d0
		move.w	d0,8(a0)	; change bubble's horizontal position
		tst.b	$2E(a0)
		beq.s	Obj64_Display
		bsr.w	Obj64_ChkSonic	; has Sonic touched the	bubble?
		beq.s	Obj64_Display	; if not, branch

		bsr.w	ResumeMusic	; cancel countdown music
		moveq	#sfx_Bubble,d0
		jsr	PlaySound_Special ;	play collecting	bubble sound
		lea	($FFFFD000).w,a1
		clr.w	$10(a1)
		clr.w	$12(a1)
		clr.w	$14(a1)
		move.b	#$15,$1C(a1)
		move.w	#$23,$3E(a1)
		move.b	#0,$3C(a1)
		bclr	#5,$22(a1)
		bclr	#4,$22(a1)
		btst	#2,$22(a1)
		beq.w	Obj64_Burst
		bclr	#2,$22(a1)
		move.b	#$13,$16(a1)
		move.b	#9,$17(a1)
		subq.w	#5,$C(a1)
		bra.w	Obj64_Burst
; ===========================================================================

Obj64_Display:				; XREF: Obj64_Wobble
		bsr.w	SpeedToPos
		tst.b	1(a0)
		bpl.s	Obj64_Delete
		jmp	DisplaySprite
; ===========================================================================

Obj64_Delete:
		jmp	DeleteObject
; ===========================================================================

Obj64_Display2:				; XREF: Obj64_Index
		lea	(Ani_obj64).l,a1
		jsr	AnimateSprite
		tst.b	1(a0)
		bpl.s	Obj64_Delete2
		jmp	DisplaySprite
; ===========================================================================

Obj64_Delete2:
		jmp	DeleteObject
; ===========================================================================

Obj64_Delete3:				; XREF: Obj64_Index
		bra.w	DeleteObject
; ===========================================================================

Obj64_BblMaker:				; XREF: Obj64_Index
		tst.w	$36(a0)
		bne.s	loc_12874
		move.w	($FFFFF646).w,d0
		cmp.w	$C(a0),d0	; is bubble maker underwater?
		bcc.w	Obj64_ChkDel	; if not, branch
		tst.b	1(a0)
		bpl.w	Obj64_ChkDel
		subq.w	#1,$38(a0)
		bpl.w	loc_12914
		move.w	#1,$36(a0)

loc_1283A:
		jsr	(RandomNumber).l
		move.w	d0,d1
		andi.w	#7,d0
		cmpi.w	#6,d0
		bcc.s	loc_1283A

		move.b	d0,$34(a0)
		andi.w	#$C,d1
		lea	(Obj64_BblTypes).l,a1
		adda.w	d1,a1
		move.l	a1,$3C(a0)
		subq.b	#1,$32(a0)
		bpl.s	loc_12872
		move.b	$33(a0),$32(a0)
		bset	#7,$36(a0)

loc_12872:
		bra.s	loc_1287C
; ===========================================================================

loc_12874:				; XREF: Obj64_BblMaker
		subq.w	#1,$38(a0)
		bpl.w	loc_12914

loc_1287C:
		jsr	(RandomNumber).l
		andi.w	#$1F,d0
		move.w	d0,$38(a0)
		bsr.w	SingleObjLoad
		bne.s	loc_128F8
		move.b	#$64,0(a1)	; load bubble object
		move.w	8(a0),8(a1)
		jsr	(RandomNumber).l
		andi.w	#$F,d0
		subq.w	#8,d0
		add.w	d0,8(a1)
		move.w	$C(a0),$C(a1)
		moveq	#0,d0
		move.b	$34(a0),d0
		movea.l	$3C(a0),a2
		move.b	(a2,d0.w),$28(a1)
		btst	#7,$36(a0)
		beq.s	loc_128F8
		jsr	(RandomNumber).l
		andi.w	#3,d0
		bne.s	loc_128E4
		bset	#6,$36(a0)
		bne.s	loc_128F8
		move.b	#2,$28(a1)

loc_128E4:
		tst.b	$34(a0)
		bne.s	loc_128F8
		bset	#6,$36(a0)
		bne.s	loc_128F8
		move.b	#2,$28(a1)

loc_128F8:
		subq.b	#1,$34(a0)
		bpl.s	loc_12914
		jsr	(RandomNumber).l
		andi.w	#$7F,d0
		addi.w	#$80,d0
		add.w	d0,$38(a0)
		clr.w	$36(a0)

loc_12914:
		lea	(Ani_obj64).l,a1
		jsr	AnimateSprite

Obj64_ChkDel:				; XREF: Obj64_BblMaker
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		move.w	($FFFFF646).w,d0
		cmp.w	$C(a0),d0
		bcs.w	DisplaySprite
		rts
; ===========================================================================
; bubble production sequence

; 0 = small bubble, 1 =	large bubble

Obj64_BblTypes:	dc.b 0,	1, 0, 0, 0, 0, 1, 0, 0,	0, 0, 1, 0, 1, 0, 0, 1,	0

; ===========================================================================

Obj64_ChkSonic:				; XREF: Obj64_Wobble
		tst.b	($FFFFF7C8).w
		bmi.s	loc_12998
		lea	($FFFFD000).w,a1
		move.w	8(a1),d0
		move.w	8(a0),d1
		subi.w	#$10,d1
		cmp.w	d0,d1
		bcc.s	loc_12998
		addi.w	#$20,d1
		cmp.w	d0,d1
		bcs.s	loc_12998
		move.w	$C(a1),d0
		move.w	$C(a0),d1
		cmp.w	d0,d1
		bcc.s	loc_12998
		addi.w	#$10,d1
		cmp.w	d0,d1
		bcs.s	loc_12998
		moveq	#1,d0
		rts
; ===========================================================================

loc_12998:
		moveq	#0,d0
		rts
; ===========================================================================
Ani_obj64:
	include "_anim\obj64.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - bubbles (LZ)
; ---------------------------------------------------------------------------
Map_obj64:
	include "_maps\obj64.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 65 - waterfalls (LZ)
; ---------------------------------------------------------------------------

Obj65:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj65_Index(pc,d0.w),d1
		jmp	Obj65_Index(pc,d1.w)
; ===========================================================================
Obj65_Index:	dc.w Obj65_Main-Obj65_Index
		dc.w Obj65_Animate-Obj65_Index
		dc.w Obj65_ChkDel-Obj65_Index
		dc.w Obj65_FixHeight-Obj65_Index
		dc.w loc_12B36-Obj65_Index
; ===========================================================================

Obj65_Main:				; XREF: Obj65_Index
		addq.b	#4,$24(a0)
		move.l	#Map_obj65,4(a0)
		move.w	#$4259,2(a0)
		ori.b	#4,1(a0)
		move.b	#$18,$19(a0)
		move.b	#1,$18(a0)
		move.b	$28(a0),d0	; get object type
		bpl.s	loc_12AE6
		bset	#7,2(a0)

loc_12AE6:
		andi.b	#$F,d0		; read only the	2nd byte
		move.b	d0,$1A(a0)	; set frame number
		cmpi.b	#9,d0		; is object type $x9 ?
		bne.s	Obj65_ChkDel	; if not, branch
		clr.b	$18(a0)
		subq.b	#2,$24(a0)
		btst	#6,$28(a0)	; is object type $4x ?
		beq.s	loc_12B0A	; if not, branch
		move.b	#6,$24(a0)

loc_12B0A:
		btst	#5,$28(a0)	; is object type $Ax ?
		beq.s	Obj65_Animate	; if not, branch
		move.b	#8,$24(a0)

Obj65_Animate:				; XREF: Obj65_Index
		lea	(Ani_obj65).l,a1
		jsr	AnimateSprite

Obj65_ChkDel:				; XREF: Obj65_Index
		bra.w	MarkObjGone
; ===========================================================================

Obj65_FixHeight:			; XREF: Obj65_Index
		move.w	($FFFFF646).w,d0
		subi.w	#$10,d0
		move.w	d0,$C(a0)	; match	object position	to water height
		bra.s	Obj65_Animate
; ===========================================================================

loc_12B36:				; XREF: Obj65_Index
		bclr	#7,2(a0)
		cmpi.b	#7,($FFFFA506).w
		bne.s	Obj65_Animate2
		bset	#7,2(a0)

Obj65_Animate2:
		bra.s	Obj65_Animate
; ===========================================================================
Ani_obj65:
	include "_anim\obj65.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - waterfalls (LZ)
; ---------------------------------------------------------------------------
Map_obj65:
	include "_maps\obj65.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 01 - Sonic
; ---------------------------------------------------------------------------

Obj01:					; XREF: Obj_Index
		tst.w	($FFFFFE08).w	; is debug mode	being used?
		beq.s	Obj01_Normal	; if not, branch
		jmp	DebugMode
; ===========================================================================

Obj01_Normal:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj01_Index(pc,d0.w),d1
		jmp	Obj01_Index(pc,d1.w)
; ===========================================================================
Obj01_Index:	dc.w Obj01_Main-Obj01_Index
		dc.w Obj01_Control-Obj01_Index
		dc.w Obj01_Hurt-Obj01_Index
		dc.w Obj01_Death-Obj01_Index
		dc.w Obj01_ResetLevel-Obj01_Index
; ===========================================================================

Obj01_Main:				; XREF: Obj01_Index
		addq.b	#2,$24(a0)
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		move.l	#Map_Sonic,4(a0)
		move.w	#$780,2(a0)
		move.b	#2,$18(a0)
		move.b	#$18,$19(a0)
		move.b	#4,1(a0)
		move.w	#$600,($FFFFF760).w ; Sonic's top speed
		move.w	#$C,($FFFFF762).w ; Sonic's acceleration
		move.w	#$80,($FFFFF764).w ; Sonic's deceleration

Obj01_Control:				; XREF: Obj01_Index
		tst.w	($FFFFFFFA).w	; is debug cheat enabled?
		beq.s	loc_12C58	; if not, branch
		btst	#4,($FFFFF605).w ; is button C pressed?
		beq.s	loc_12C58	; if not, branch
		move.w	#1,($FFFFFE08).w ; change Sonic	into a ring/item
		clr.b	($FFFFF7CC).w
		rts
; ===========================================================================

loc_12C58:
		tst.b	($FFFFF7CC).w	; are controls locked?
		bne.s	loc_12C64	; if yes, branch
		move.w	($FFFFF604).w,($FFFFF602).w ; enable joypad control

loc_12C64:
		btst	#0,($FFFFF7C8).w ; are controls	locked?
		bne.s	loc_12C7E	; if yes, branch
		moveq	#0,d0
		move.b	$22(a0),d0
		andi.w	#6,d0
		move.w	Obj01_Modes(pc,d0.w),d1
		jsr	Obj01_Modes(pc,d1.w)

loc_12C7E:
		bsr.s	Sonic_Display
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Water
		move.b	($FFFFF768).w,$36(a0)
		move.b	($FFFFF76A).w,$37(a0)
		tst.b	($FFFFF7C7).w
		beq.s	loc_12CA6
		tst.b	$1C(a0)
		bne.s	loc_12CA6
		move.b	$1D(a0),$1C(a0)

loc_12CA6:
		bsr.w	Sonic_Animate
		tst.b	($FFFFF7C8).w
		bmi.s	loc_12CB6
		jsr	TouchResponse

loc_12CB6:
		bsr.w	Sonic_Loops
		bsr.w	LoadSonicDynPLC
		rts
; ===========================================================================
Obj01_Modes:	dc.w Obj01_MdNormal-Obj01_Modes
		dc.w Obj01_MdJump-Obj01_Modes
		dc.w Obj01_MdRoll-Obj01_Modes
		dc.w Obj01_MdJump2-Obj01_Modes

; ===========================================================================

Sonic_Display:				; XREF: loc_12C7E
		move.w	$30(a0),d0
		beq.s	Obj01_Display
		subq.w	#1,$30(a0)
		lsr.w	#3,d0
		bcc.s	Obj01_ChkInvin

Obj01_Display:
		jsr	DisplaySprite

Obj01_ChkInvin:
		tst.b	($FFFFFE2D).w	; does Sonic have invincibility?
		beq.s	Obj01_ChkShoes	; if not, branch
		tst.w	$32(a0)		; check	time remaining for invinciblity
		beq.s	Obj01_ChkShoes	; if no	time remains, branch
		subq.w	#1,$32(a0)	; subtract 1 from time
		bne.s	Obj01_ChkShoes
		tst.b	($FFFFF7AA).w
		bne.s	Obj01_RmvInvin
		cmpi.w	#$C,($FFFFFE14).w
		bcs.s	Obj01_RmvInvin
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		cmpi.w	#$103,($FFFFFE10).w ; check if level is	SBZ3
		bne.s	Obj01_PlayMusic
		moveq	#5,d0		; play SBZ music

Obj01_PlayMusic:
		lea	(MusicList).l,a1
		move.b	(a1,d0.w),d0
		jsr	(PlaySound).l	; play normal music

Obj01_RmvInvin:
		move.b	#0,($FFFFFE2D).w ; cancel invincibility

Obj01_ChkShoes:
		tst.b	($FFFFFE2E).w	; does Sonic have speed	shoes?
		beq.s	Obj01_ExitChk	; if not, branch
		tst.w	$34(a0)		; check	time remaining
		beq.s	Obj01_ExitChk
		subq.w	#1,$34(a0)	; subtract 1 from time
		bne.s	Obj01_ExitChk
		move.w	#$600,($FFFFF760).w ; restore Sonic's speed
		move.w	#$C,($FFFFF762).w ; restore Sonic's acceleration
		move.w	#$80,($FFFFF764).w ; restore Sonic's deceleration
		move.b	#0,($FFFFFE2E).w ; cancel speed	shoes
		moveq	#Mus_ShoesOff,d0
		jmp	(PlaySound).l	; run music at normal speed
; ===========================================================================

Obj01_ExitChk:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	record Sonic's previous positions for invincibility stars
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RecordPos:			; XREF: loc_12C7E; Obj01_Hurt; Obj01_Death
		move.w	($FFFFF7A8).w,d0
		lea	($FFFFCB00).w,a1
		lea	(a1,d0.w),a1
		move.w	8(a0),(a1)+
		move.w	$C(a0),(a1)+
		addq.b	#4,($FFFFF7A9).w
		rts
; End of function Sonic_RecordPos

; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Water:				; XREF: loc_12C7E
		cmpi.b	#1,($FFFFFE10).w ; is level LZ?
		beq.s	Obj01_InWater	; if yes, branch

locret_12D80:
		rts
; ===========================================================================

Obj01_InWater:
		move.w	($FFFFF646).w,d0
		cmp.w	$C(a0),d0	; is Sonic above the water?
		bge.s	Obj01_OutWater	; if yes, branch
		bset	#6,$22(a0)
		bne.s	locret_12D80
		bsr.w	ResumeMusic
		moveq	#Mus_ToWater,d0
		jsr	PlaySound_Special2	; get into water(tm)

		move.b	#$A,($FFFFD340).w ; load bubbles object	from Sonic's mouth
		move.b	#$81,($FFFFD368).w
		move.w	#$300,($FFFFF760).w ; change Sonic's top speed
		move.w	#6,($FFFFF762).w ; change Sonic's acceleration
		move.w	#$40,($FFFFF764).w ; change Sonic's deceleration
		asr	$10(a0)
		asr	$12(a0)
		asr	$12(a0)
		beq.s	locret_12D80
		move.b	#8,($FFFFD300).w ; load	splash object
		moveq	#sfx_Splash,d0
		jmp	(PlaySound_Special).l ;	play splash sound
; ===========================================================================

Obj01_OutWater:
		bclr	#6,$22(a0)
		beq.s	locret_12D80
		bsr.w	ResumeMusic
		moveq	#Mus_OutWater,d0
		jsr	PlaySound_Special2	; get out of water(tm)

		move.w	#$600,($FFFFF760).w ; restore Sonic's speed
		move.w	#$C,($FFFFF762).w ; restore Sonic's acceleration
		move.w	#$80,($FFFFF764).w ; restore Sonic's deceleration
		asl	$12(a0)
		beq.w	locret_12D80
		move.b	#8,($FFFFD300).w ; load	splash object
		cmpi.w	#-$1000,$12(a0)
		bgt.s	loc_12E0E
		move.w	#-$1000,$12(a0)	; set maximum speed on leaving water

loc_12E0E:
		moveq	#sfx_Splash,d0
		jmp	(PlaySound_Special).l ;	play splash sound
; End of function Sonic_Water

; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for controlling	Sonic
; ---------------------------------------------------------------------------

Obj01_MdNormal:				; XREF: Obj01_Modes
		bsr.w	Sonic_Jump
		bsr.w	Sonic_SlopeResist
		bsr.w	Sonic_Move
		bsr.w	Sonic_Roll
		bsr.w	Sonic_LevelBound
		jsr	SpeedToPos
		bsr.w	Sonic_AnglePos
		bsr.w	Sonic_SlopeRepel
		rts
; ===========================================================================

Obj01_MdJump:				; XREF: Obj01_Modes
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_ChgJumpDir
		bsr.w	Sonic_LevelBound
		jsr	ObjectFall
		btst	#6,$22(a0)
		beq.s	loc_12E5C
		subi.w	#$28,$12(a0)

loc_12E5C:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_Floor
		rts
; ===========================================================================

Obj01_MdRoll:				; XREF: Obj01_Modes
		bsr.w	Sonic_Jump
		bsr.w	Sonic_RollRepel
		bsr.w	Sonic_RollSpeed
		bsr.w	Sonic_LevelBound
		jsr	SpeedToPos
		bsr.w	Sonic_AnglePos
		bsr.w	Sonic_SlopeRepel
		rts
; ===========================================================================

Obj01_MdJump2:				; XREF: Obj01_Modes
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_ChgJumpDir
		bsr.w	Sonic_LevelBound
		jsr	ObjectFall
		btst	#6,$22(a0)
		beq.s	loc_12EA6
		subi.w	#$28,$12(a0)

loc_12EA6:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_Floor
		rts
; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Move:				; XREF: Obj01_MdNormal
		move.w	($FFFFF760).w,d6
		move.w	($FFFFF762).w,d5
		move.w	($FFFFF764).w,d4
		tst.b	($FFFFF7CA).w
		bne.w	loc_12FEE
		tst.w	$3E(a0)
		bne.w	Obj01_ResetScr
		btst	#2,($FFFFF602).w ; is left being pressed?
		beq.s	Obj01_NotLeft	; if not, branch
		bsr.w	Sonic_MoveLeft

Obj01_NotLeft:
		btst	#3,($FFFFF602).w ; is right being pressed?
		beq.s	Obj01_NotRight	; if not, branch
		bsr.w	Sonic_MoveRight

Obj01_NotRight:
		move.b	$26(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0		; is Sonic on a	slope?
		bne.w	Obj01_ResetScr	; if yes, branch
		tst.w	$14(a0)		; is Sonic moving?
		bne.w	Obj01_ResetScr	; if yes, branch
		bclr	#5,$22(a0)
		move.b	#5,$1C(a0)	; use "standing" animation
		btst	#3,$22(a0)
		beq.s	Sonic_Balance
		moveq	#0,d0
		move.b	$3D(a0),d0
		lsl.w	#6,d0
		lea	($FFFFD000).w,a1
		lea	(a1,d0.w),a1
		tst.b	$22(a1)
		bmi.s	Sonic_LookUp
		moveq	#0,d1
		move.b	$19(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#4,d2
		add.w	8(a0),d1
		sub.w	8(a1),d1
		cmpi.w	#4,d1
		blt.s	loc_12F6A
		cmp.w	d2,d1
		bge.s	loc_12F5A
		bra.s	Sonic_LookUp
; ===========================================================================

Sonic_Balance:
		jsr	ObjHitFloor
		cmpi.w	#$C,d1
		blt.s	Sonic_LookUp
		cmpi.b	#3,$36(a0)
		bne.s	loc_12F62

loc_12F5A:
		bclr	#0,$22(a0)
		bra.s	loc_12F70
; ===========================================================================

loc_12F62:
		cmpi.b	#3,$37(a0)
		bne.s	Sonic_LookUp

loc_12F6A:
		bset	#0,$22(a0)

loc_12F70:
		move.b	#6,$1C(a0)	; use "balancing" animation
		bra.s	Obj01_ResetScr
; ===========================================================================

Sonic_LookUp:
		btst	#0,($FFFFF602).w ; is up being pressed?
		beq.s	Sonic_Duck	; if not, branch
		move.b	#7,$1C(a0)	; use "looking up" animation
		cmpi.w	#$C8,($FFFFF73E).w
		beq.s	loc_12FC2
		addq.w	#2,($FFFFF73E).w
		bra.s	loc_12FC2
; ===========================================================================

Sonic_Duck:
		btst	#1,($FFFFF602).w ; is down being pressed?
		beq.s	Obj01_ResetScr	; if not, branch
		move.b	#8,$1C(a0)	; use "ducking"	animation
		cmpi.w	#8,($FFFFF73E).w
		beq.s	loc_12FC2
		subq.w	#2,($FFFFF73E).w
		bra.s	loc_12FC2
; ===========================================================================

Obj01_ResetScr:
		cmpi.w	#$60,($FFFFF73E).w ; is	screen in its default position?
		beq.s	loc_12FC2	; if yes, branch
		bcc.s	loc_12FBE
		addq.w	#4,($FFFFF73E).w ; move	screen back to default

loc_12FBE:
		subq.w	#2,($FFFFF73E).w ; move	screen back to default

loc_12FC2:
		move.b	($FFFFF602).w,d0
		andi.b	#$C,d0		; is left/right	pressed?
		bne.s	loc_12FEE	; if yes, branch
		move.w	$14(a0),d0
		beq.s	loc_12FEE
		bmi.s	loc_12FE2
		sub.w	d5,d0
		bcc.s	loc_12FDC
		move.w	#0,d0

loc_12FDC:
		move.w	d0,$14(a0)
		bra.s	loc_12FEE
; ===========================================================================

loc_12FE2:
		add.w	d5,d0
		bcc.s	loc_12FEA
		move.w	#0,d0

loc_12FEA:
		move.w	d0,$14(a0)

loc_12FEE:
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		muls.w	$14(a0),d1
		asr.l	#8,d1
		move.w	d1,$10(a0)
		muls.w	$14(a0),d0
		asr.l	#8,d0
		move.w	d0,$12(a0)

loc_1300C:
		move.b	$26(a0),d0
		addi.b	#$40,d0
		bmi.s	locret_1307C
		move.b	#$40,d1
		tst.w	$14(a0)
		beq.s	locret_1307C
		bmi.s	loc_13024
		neg.w	d1

loc_13024:
		move.b	$26(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	Sonic_WalkSpeed
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_1307C
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_13078
		cmpi.b	#$40,d0
		beq.s	loc_13066
		cmpi.b	#$80,d0
		beq.s	loc_13060
		add.w	d1,$10(a0)
		bset	#5,$22(a0)
		move.w	#0,$14(a0)
		rts
; ===========================================================================

loc_13060:
		sub.w	d1,$12(a0)
		rts
; ===========================================================================

loc_13066:
		sub.w	d1,$10(a0)
		bset	#5,$22(a0)
		move.w	#0,$14(a0)
		rts
; ===========================================================================

loc_13078:
		add.w	d1,$12(a0)

locret_1307C:
		rts
; End of function Sonic_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveLeft:				; XREF: Sonic_Move
		move.w	$14(a0),d0
		beq.s	loc_13086
		bpl.s	loc_130B2

loc_13086:
		bset	#0,$22(a0)
		bne.s	loc_1309A
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)

loc_1309A:
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_130A6
		move.w	d1,d0

loc_130A6:
		move.w	d0,$14(a0)
		move.b	#0,$1C(a0)	; use walking animation

locret_130E8:
		rts
; ===========================================================================

loc_130B2:				; XREF: Sonic_MoveLeft
		sub.w	d4,d0
		bcc.s	loc_130BA
		move.w	#-$80,d0

loc_130BA:
		move.w	d0,$14(a0)
		move.b	$26(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_130E8
		cmpi.w	#$400,d0
		blt.s	locret_130E8
		move.b	#$D,$1C(a0)	; use "stopping" animation
		bclr	#0,$22(a0)
		moveq	#sfx_Skid,d0
		jmp	PlaySound_Special ;	play stopping sound


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveRight:			; XREF: Sonic_Move
		move.w	$14(a0),d0
		bmi.s	loc_13118
		bclr	#0,$22(a0)
		beq.s	loc_13104
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)

loc_13104:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_1310C
		move.w	d6,d0

loc_1310C:
		move.w	d0,$14(a0)
		move.b	#0,$1C(a0)	; use walking animation

locret_1314E:
		rts
; ===========================================================================

loc_13118:				; XREF: Sonic_MoveRight
		add.w	d4,d0
		bcc.s	loc_13120
		move.w	#$80,d0

loc_13120:
		move.w	d0,$14(a0)
		move.b	$26(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_1314E
		cmpi.w	#-$400,d0
		bgt.s	locret_1314E
		move.b	#$D,$1C(a0)	; use "stopping" animation
		bset	#0,$22(a0)
		moveq	#sfx_Skid,d0
		jmp	PlaySound_Special ;	play stopping sound

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's speed as he rolls
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollSpeed:			; XREF: Obj01_MdRoll
		move.w	($FFFFF760).w,d6
		asl.w	#1,d6
		move.w	($FFFFF762).w,d5
		asr.w	#1,d5
		move.w	($FFFFF764).w,d4
		asr.w	#2,d4
		tst.b	($FFFFF7CA).w
		bne.w	loc_131CC
		tst.w	$3E(a0)
		bne.s	loc_13188
		btst	#2,($FFFFF602).w ; is left being pressed?
		beq.s	loc_1317C	; if not, branch
		bsr.w	Sonic_RollLeft

loc_1317C:
		btst	#3,($FFFFF602).w ; is right being pressed?
		beq.s	loc_13188	; if not, branch
		bsr.w	Sonic_RollRight

loc_13188:
		move.w	$14(a0),d0
		beq.s	loc_131AA
		bmi.s	loc_1319E
		sub.w	d5,d0
		bcc.s	loc_13198
		move.w	#0,d0

loc_13198:
		move.w	d0,$14(a0)
		bra.s	loc_131AA
; ===========================================================================

loc_1319E:				; XREF: Sonic_RollSpeed
		add.w	d5,d0
		bcc.s	loc_131A6
		move.w	#0,d0

loc_131A6:
		move.w	d0,$14(a0)

loc_131AA:
		tst.w	$14(a0)		; is Sonic moving?
		bne.s	loc_131CC	; if yes, branch
		bclr	#2,$22(a0)
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		move.b	#5,$1C(a0)	; use "standing" animation
		subq.w	#5,$C(a0)

loc_131CC:
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		muls.w	$14(a0),d0
		asr.l	#8,d0
		move.w	d0,$12(a0)
		muls.w	$14(a0),d1
		asr.l	#8,d1
		cmpi.w	#$1000,d1
		ble.s	loc_131F0
		move.w	#$1000,d1

loc_131F0:
		cmpi.w	#-$1000,d1
		bge.s	loc_131FA
		move.w	#-$1000,d1

loc_131FA:
		move.w	d1,$10(a0)
		bra.w	loc_1300C
; End of function Sonic_RollSpeed


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollLeft:				; XREF: Sonic_RollSpeed
		move.w	$14(a0),d0
		beq.s	loc_1320A
		bpl.s	loc_13218

loc_1320A:
		bset	#0,$22(a0)
		move.b	#2,$1C(a0)	; use "rolling"	animation
		rts
; ===========================================================================

loc_13218:
		sub.w	d4,d0
		bcc.s	loc_13220
		move.w	#-$80,d0

loc_13220:
		move.w	d0,$14(a0)
		rts
; End of function Sonic_RollLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollRight:			; XREF: Sonic_RollSpeed
		move.w	$14(a0),d0
		bmi.s	loc_1323A
		bclr	#0,$22(a0)
		move.b	#2,$1C(a0)	; use "rolling"	animation
		rts
; ===========================================================================

loc_1323A:
		add.w	d4,d0
		bcc.s	loc_13242
		move.w	#$80,d0

loc_13242:
		move.w	d0,$14(a0)
		rts
; End of function Sonic_RollRight

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's direction while jumping
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ChgJumpDir:			; XREF: Obj01_MdJump; Obj01_MdJump2
		move.w	($FFFFF760).w,d6
		move.w	($FFFFF762).w,d5
		asl.w	#1,d5
		btst	#4,$22(a0)
		bne.s	Obj01_ResetScr2
		move.w	$10(a0),d0
		btst	#2,($FFFFF602).w ; is left being pressed?
		beq.s	loc_13278	; if not, branch
		bset	#0,$22(a0)
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_13278
		move.w	d1,d0

loc_13278:
		btst	#3,($FFFFF602).w ; is right being pressed?
		beq.s	Obj01_JumpMove	; if not, branch
		bclr	#0,$22(a0)
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	Obj01_JumpMove
		move.w	d6,d0

Obj01_JumpMove:
		move.w	d0,$10(a0)	; change Sonic's horizontal speed

Obj01_ResetScr2:
		cmpi.w	#$60,($FFFFF73E).w ; is	the screen in its default position?
		beq.s	loc_132A4	; if yes, branch
		bcc.s	loc_132A0
		addq.w	#4,($FFFFF73E).w

loc_132A0:
		subq.w	#2,($FFFFF73E).w

loc_132A4:
		cmpi.w	#-$400,$12(a0)	; is Sonic moving faster than -$400 upwards?
		bcs.s	locret_132D2	; if yes, branch
		move.w	$10(a0),d0
		move.w	d0,d1
		asr.w	#5,d1
		beq.s	locret_132D2
		bmi.s	loc_132C6
		sub.w	d1,d0
		bcc.s	loc_132C0
		move.w	#0,d0

loc_132C0:
		move.w	d0,$10(a0)
		rts
; ===========================================================================

loc_132C6:
		sub.w	d1,d0
		bcs.s	loc_132CE
		move.w	#0,d0

loc_132CE:
		move.w	d0,$10(a0)

locret_132D2:
		rts
; End of function Sonic_ChgJumpDir

; ===========================================================================
; ---------------------------------------------------------------------------
; Unused subroutine to squash Sonic
; ---------------------------------------------------------------------------
		move.b	$26(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_13302
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	locret_13302
		move.w	#0,$14(a0)	; stop Sonic moving
		move.w	#0,$10(a0)
		move.w	#0,$12(a0)
		move.b	#$B,$1C(a0)	; use "warping"	animation

locret_13302:
		rts
; ---------------------------------------------------------------------------
; Subroutine to	prevent	Sonic leaving the boundaries of	a level
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_LevelBound:			; XREF: Obj01_MdNormal; et al
		move.l	8(a0),d1
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		swap	d1
		move.w	($FFFFF728).w,d0
		addi.w	#$10,d0
		cmp.w	d1,d0		; has Sonic touched the	side boundary?
		bhi.s	Boundary_Sides	; if yes, branch
		move.w	($FFFFF72A).w,d0
		addi.w	#$128,d0
		tst.b	($FFFFF7AA).w
		bne.s	loc_13332
		addi.w	#$40,d0

loc_13332:
		cmp.w	d1,d0		; has Sonic touched the	side boundary?
		bls.s	Boundary_Sides	; if yes, branch

loc_13336:
		move.w	($FFFFF72E).w,d0
		addi.w	#$E0,d0
		cmp.w	$C(a0),d0	; has Sonic touched the	bottom boundary?
		blt.s	Boundary_Bottom	; if yes, branch
		rts
; ===========================================================================

Boundary_Bottom:
		cmpi.w	#$501,($FFFFFE10).w ; is level SBZ2 ?
		bne.w	KillSonic	; if not, kill Sonic
		cmpi.w	#$2000,($FFFFD008).w
		bcs.w	KillSonic
		clr.b	($FFFFFE30).w	; clear	lamppost counter
		move.w	#1,($FFFFFE02).w ; restart the level
		move.w	#$103,($FFFFFE10).w ; set level	to SBZ3	(LZ4)
		rts
; ===========================================================================

Boundary_Sides:
		move.w	d0,8(a0)
		move.w	#0,$A(a0)
		move.w	#0,$10(a0)	; stop Sonic moving
		move.w	#0,$14(a0)
		bra.s	loc_13336
; End of function Sonic_LevelBound

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to roll when he's moving
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Roll:				; XREF: Obj01_MdNormal
		tst.b	($FFFFF7CA).w
		bne.s	Obj01_NoRoll
		move.w	$14(a0),d0
		bpl.s	loc_13392
		neg.w	d0

loc_13392:
		cmpi.w	#$80,d0		; is Sonic moving at $80 speed or faster?
		bcs.s	Obj01_NoRoll	; if not, branch
		move.b	($FFFFF602).w,d0
		andi.b	#$C,d0		; is left/right	being pressed?
		bne.s	Obj01_NoRoll	; if yes, branch
		btst	#1,($FFFFF602).w ; is down being pressed?
		bne.s	Obj01_ChkRoll	; if yes, branch

Obj01_NoRoll:
		rts
; ===========================================================================

Obj01_ChkRoll:
		btst	#2,$22(a0)	; is Sonic already rolling?
		beq.s	Obj01_DoRoll	; if not, branch
		rts
; ===========================================================================

Obj01_DoRoll:
		bset	#2,$22(a0)
		move.b	#$E,$16(a0)
		move.b	#7,$17(a0)
		move.b	#2,$1C(a0)	; use "rolling"	animation
		addq.w	#5,$C(a0)
		moveq	#sfx_Roll,d0
		jsr	(PlaySound_Special).l ;	play rolling sound
		tst.w	$14(a0)
		bne.s	locret_133E8
		move.w	#$200,$14(a0)

locret_133E8:
		rts
; End of function Sonic_Roll

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Jump:				; XREF: Obj01_MdNormal; Obj01_MdRoll
		move.b	($FFFFF603).w,d0
		andi.b	#$70,d0		; is A,	B or C pressed?
		beq.w	locret_1348E	; if not, branch
		moveq	#0,d0
		move.b	$26(a0),d0
		addi.b	#$80,d0
		bsr.w	sub_14D48
		cmpi.w	#6,d1
		blt.w	locret_1348E
		move.w	#$680,d2
		btst	#6,$22(a0)
		beq.s	loc_1341C
		move.w	#$380,d2

loc_1341C:
		moveq	#0,d0
		move.b	$26(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,$10(a0)	; make Sonic jump
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,$12(a0)	; make Sonic jump
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		addq.l	#4,sp
		move.b	#1,$3C(a0)
		clr.b	$38(a0)
		moveq	#sfx_Jump,d0
		jsr	PlaySound_Special ;	play jumping sound
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		btst	#2,$22(a0)
		bne.s	loc_13490
		move.b	#$E,$16(a0)
		move.b	#7,$17(a0)
		move.b	#2,$1C(a0)	; use "jumping"	animation
		bset	#2,$22(a0)
		addq.w	#5,$C(a0)

locret_1348E:
		rts
; ===========================================================================

loc_13490:
		bset	#4,$22(a0)
		rts
; End of function Sonic_Jump


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpHeight:			; XREF: Obj01_MdJump; Obj01_MdJump2
		tst.b	$3C(a0)
		beq.s	loc_134C4
		move.w	#-$400,d1
		btst	#6,$22(a0)
		beq.s	loc_134AE
		move.w	#-$200,d1

loc_134AE:
		cmp.w	$12(a0),d1
		ble.s	locret_134C2
		move.b	($FFFFF602).w,d0
		andi.b	#$70,d0		; is A,	B or C pressed?
		bne.s	locret_134C2	; if yes, branch
		move.w	d1,$12(a0)

locret_134C2:
		rts
; ===========================================================================

loc_134C4:
		cmpi.w	#-$FC0,$12(a0)
		bge.s	locret_134D2
		move.w	#-$FC0,$12(a0)

locret_134D2:
		rts
; End of function Sonic_JumpHeight

; ---------------------------------------------------------------------------
; Subroutine to	slow Sonic walking up a	slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_SlopeResist:			; XREF: Obj01_MdNormal
		move.b	$26(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bcc.s	locret_13508
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		muls.w	#$20,d0
		asr.l	#8,d0
		tst.w	$14(a0)
		beq.s	locret_13508
		bmi.s	loc_13504
		tst.w	d0
		beq.s	locret_13502
		add.w	d0,$14(a0)	; change Sonic's inertia

locret_13502:
		rts
; ===========================================================================

loc_13504:
		add.w	d0,$14(a0)

locret_13508:
		rts
; End of function Sonic_SlopeResist

; ---------------------------------------------------------------------------
; Subroutine to	push Sonic down	a slope	while he's rolling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollRepel:			; XREF: Obj01_MdRoll
		move.b	$26(a0),d0
		addi.b	#$60,d0
		cmpi.b	#-$40,d0
		bcc.s	locret_13544
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		muls.w	#$50,d0
		asr.l	#8,d0
		tst.w	$14(a0)
		bmi.s	loc_1353A
		tst.w	d0
		bpl.s	loc_13534
		asr.l	#2,d0

loc_13534:
		add.w	d0,$14(a0)
		rts
; ===========================================================================

loc_1353A:
		tst.w	d0
		bmi.s	loc_13540
		asr.l	#2,d0

loc_13540:
		add.w	d0,$14(a0)

locret_13544:
		rts
; End of function Sonic_RollRepel

; ---------------------------------------------------------------------------
; Subroutine to	push Sonic down	a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_SlopeRepel:			; XREF: Obj01_MdNormal; Obj01_MdRoll
		nop
		tst.b	$38(a0)
		bne.s	locret_13580
		tst.w	$3E(a0)
		bne.s	loc_13582
		move.b	$26(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	locret_13580
		move.w	$14(a0),d0
		bpl.s	loc_1356A
		neg.w	d0

loc_1356A:
		cmpi.w	#$280,d0
		bcc.s	locret_13580
		clr.w	$14(a0)
		bset	#1,$22(a0)
		move.w	#$1E,$3E(a0)

locret_13580:
		rts
; ===========================================================================

loc_13582:
		subq.w	#1,$3E(a0)
		rts
; End of function Sonic_SlopeRepel

; ---------------------------------------------------------------------------
; Subroutine to	return Sonic's angle to 0 as he jumps
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpAngle:			; XREF: Obj01_MdJump; Obj01_MdJump2
		move.b	$26(a0),d0	; get Sonic's angle
		beq.s	locret_135A2	; if already 0,	branch
		bpl.s	loc_13598	; if higher than 0, branch

		addq.b	#2,d0		; increase angle
		bcc.s	loc_13596
		moveq	#0,d0

loc_13596:
		bra.s	loc_1359E
; ===========================================================================

loc_13598:
		subq.b	#2,d0		; decrease angle
		bcc.s	loc_1359E
		moveq	#0,d0

loc_1359E:
		move.b	d0,$26(a0)

locret_135A2:
		rts
; End of function Sonic_JumpAngle

; ---------------------------------------------------------------------------
; Subroutine for Sonic to interact with	the floor after	jumping/falling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Floor:				; XREF: Obj01_MdJump; Obj01_MdJump2
		move.w	$10(a0),d1
		move.w	$12(a0),d2
		jsr	(CalcAngle).l
		move.b	d0,($FFFFFFEC).w
		subi.b	#$20,d0
		move.b	d0,($FFFFFFED).w
		andi.b	#$C0,d0
		move.b	d0,($FFFFFFEE).w
		cmpi.b	#$40,d0
		beq.w	loc_13680
		cmpi.b	#$80,d0
		beq.w	loc_136E2
		cmpi.b	#-$40,d0
		beq.w	loc_1373E
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_135F0
		sub.w	d1,8(a0)
		move.w	#0,$10(a0)

loc_135F0:
		bsr.w	sub_14EB4
		tst.w	d1
		bpl.s	loc_13602
		add.w	d1,8(a0)
		move.w	#0,$10(a0)

loc_13602:
		bsr.w	Sonic_HitFloor
		move.b	d1,($FFFFFFEF).w
		tst.w	d1
		bpl.s	locret_1367E
		move.b	$12(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	loc_1361E
		cmp.b	d2,d0
		blt.s	locret_1367E

loc_1361E:
		add.w	d1,$C(a0)
		move.b	d3,$26(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#0,$1C(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_1365C
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	loc_1364E
		asr	$12(a0)
		bra.s	loc_13670
; ===========================================================================

loc_1364E:
		move.w	#0,$12(a0)
		move.w	$10(a0),$14(a0)
		rts
; ===========================================================================

loc_1365C:
		move.w	#0,$10(a0)
		cmpi.w	#$FC0,$12(a0)
		ble.s	loc_13670
		move.w	#$FC0,$12(a0)

loc_13670:
		move.w	$12(a0),$14(a0)
		tst.b	d3
		bpl.s	locret_1367E
		neg.w	$14(a0)

locret_1367E:
		rts
; ===========================================================================

loc_13680:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_1369A
		sub.w	d1,8(a0)
		move.w	#0,$10(a0)
		move.w	$12(a0),$14(a0)
		rts
; ===========================================================================

loc_1369A:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_136B4
		sub.w	d1,$C(a0)
		tst.w	$12(a0)
		bpl.s	locret_136B2
		move.w	#0,$12(a0)

locret_136B2:
		rts
; ===========================================================================

loc_136B4:
		tst.w	$12(a0)
		bmi.s	locret_136E0
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	locret_136E0
		add.w	d1,$C(a0)
		move.b	d3,$26(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#0,$1C(a0)
		move.w	#0,$12(a0)
		move.w	$10(a0),$14(a0)

locret_136E0:
		rts
; ===========================================================================

loc_136E2:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_136F4
		sub.w	d1,8(a0)
		move.w	#0,$10(a0)

loc_136F4:
		bsr.w	sub_14EB4
		tst.w	d1
		bpl.s	loc_13706
		add.w	d1,8(a0)
		move.w	#0,$10(a0)

loc_13706:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	locret_1373C
		sub.w	d1,$C(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_13726
		move.w	#0,$12(a0)
		rts
; ===========================================================================

loc_13726:
		move.b	d3,$26(a0)
		bsr.w	Sonic_ResetOnFloor
		move.w	$12(a0),$14(a0)
		tst.b	d3
		bpl.s	locret_1373C
		neg.w	$14(a0)

locret_1373C:
		rts
; ===========================================================================

loc_1373E:
		bsr.w	sub_14EB4
		tst.w	d1
		bpl.s	loc_13758
		add.w	d1,8(a0)
		move.w	#0,$10(a0)
		move.w	$12(a0),$14(a0)
		rts
; ===========================================================================

loc_13758:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_13772
		sub.w	d1,$C(a0)
		tst.w	$12(a0)
		bpl.s	locret_13770
		move.w	#0,$12(a0)

locret_13770:
		rts
; ===========================================================================

loc_13772:
		tst.w	$12(a0)
		bmi.s	locret_1379E
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	locret_1379E
		add.w	d1,$C(a0)
		move.b	d3,$26(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#0,$1C(a0)
		move.w	#0,$12(a0)
		move.w	$10(a0),$14(a0)

locret_1379E:
		rts
; End of function Sonic_Floor

; ---------------------------------------------------------------------------
; Subroutine to	reset Sonic's mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ResetOnFloor:			; XREF: PlatformObject; et al
		btst	#4,$22(a0)
		beq.s	loc_137AE
		nop
		nop
		nop

loc_137AE:
		bclr	#5,$22(a0)
		bclr	#1,$22(a0)
		bclr	#4,$22(a0)
		btst	#2,$22(a0)
		beq.s	loc_137E4
		bclr	#2,$22(a0)
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		move.b	#0,$1C(a0)	; use running/walking animation
		subq.w	#5,$C(a0)

loc_137E4:
		move.b	#0,$3C(a0)
		move.w	#0,($FFFFF7D0).w
		rts
; End of function Sonic_ResetOnFloor

; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic	when he	gets hurt
; ---------------------------------------------------------------------------

Obj01_Hurt:				; XREF: Obj01_Index
		jsr	SpeedToPos
		addi.w	#$30,$12(a0)
		btst	#6,$22(a0)
		beq.s	loc_1380C
		subi.w	#$20,$12(a0)

loc_1380C:
		bsr.w	Sonic_HurtStop
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Animate
		bsr.w	LoadSonicDynPLC
		jmp	DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to	stop Sonic falling after he's been hurt
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_HurtStop:				; XREF: Obj01_Hurt
		move.w	($FFFFF72E).w,d0
		addi.w	#$E0,d0
		cmp.w	$C(a0),d0
		bcs.w	KillSonic
		bsr.w	Sonic_Floor
		btst	#1,$22(a0)
		bne.s	locret_13860
		moveq	#0,d0
		move.w	d0,$12(a0)
		move.w	d0,$10(a0)
		move.w	d0,$14(a0)
		move.b	#0,$1C(a0)
		subq.b	#2,$24(a0)
		move.w	#$78,$30(a0)

locret_13860:
		rts
; End of function Sonic_HurtStop

; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic	when he	dies
; ---------------------------------------------------------------------------

Obj01_Death:				; XREF: Obj01_Index
		bsr.w	GameOver
		jsr	ObjectFall
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Animate
		bsr.w	LoadSonicDynPLC
		jmp	DisplaySprite

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


GameOver:				; XREF: Obj01_Death
		move.w	($FFFFF72E).w,d0
		addi.w	#$100,d0
		cmp.w	$C(a0),d0
		bcc.w	locret_13900
		move.w	#-$38,$12(a0)
		addq.b	#2,$24(a0)
		clr.b	($FFFFFE1E).w	; stop time counter
		addq.b	#1,($FFFFFE1C).w ; update lives	counter
		subq.b	#1,($FFFFFE12).w ; subtract 1 from number of lives
		bne.s	loc_138D4
		move.w	#0,$3A(a0)
		move.b	#$39,($FFFFD080).w ; load GAME object
		move.b	#$39,($FFFFD0C0).w ; load OVER object
		move.b	#1,($FFFFD0DA).w ; set OVER object to correct frame
		clr.b	($FFFFFE1A).w

loc_138C2:
		moveq	#mus_GameOver,d0
		jsr	(PlaySound).l	; play game over music
		moveq	#3,d0
		jmp	(LoadPLC).l	; load game over patterns
; ===========================================================================

loc_138D4:
		move.w	#60,$3A(a0)	; set time delay to 1 second
		tst.b	($FFFFFE1A).w	; is TIME OVER tag set?
		beq.s	locret_13900	; if not, branch
		move.w	#0,$3A(a0)
		move.b	#$39,($FFFFD080).w ; load TIME object
		move.b	#$39,($FFFFD0C0).w ; load OVER object
		move.b	#2,($FFFFD09A).w
		move.b	#3,($FFFFD0DA).w
		bra.s	loc_138C2
; ===========================================================================

locret_13900:
		rts
; End of function GameOver

; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic	when the level is restarted
; ---------------------------------------------------------------------------

Obj01_ResetLevel:			; XREF: Obj01_Index
		tst.w	$3A(a0)
		beq.s	locret_13914
		subq.w	#1,$3A(a0)	; subtract 1 from time delay
		bne.s	locret_13914
		move.w	#1,($FFFFFE02).w ; restart the level

locret_13914:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	make Sonic run around loops (GHZ/SLZ)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Loops:				; XREF: Obj01_Control
		cmpi.b	#3,($FFFFFE10).w ; is level SLZ	?
		beq.s	loc_13926	; if yes, branch
		tst.b	($FFFFFE10).w	; is level GHZ ?
		bne.w	locret_139C2	; if not, branch

loc_13926:
		move.w	$C(a0),d0
		lsr.w	#1,d0
		andi.w	#$380,d0
		move.b	8(a0),d1
		andi.w	#$7F,d1
		add.w	d1,d0
		lea	($FFFFA400).w,a1
		move.b	(a1,d0.w),d1	; d1 is	the 256x256 tile Sonic is currently on
		cmp.b	($FFFFF7AE).w,d1
		beq.w	Obj01_ChkRoll
		cmp.b	($FFFFF7AF).w,d1
		beq.w	Obj01_ChkRoll
		cmp.b	($FFFFF7AC).w,d1
		beq.s	loc_13976
		cmp.b	($FFFFF7AD).w,d1
		beq.s	loc_13966
		bclr	#6,1(a0)
		rts
; ===========================================================================

loc_13966:
		btst	#1,$22(a0)
		beq.s	loc_13976
		bclr	#6,1(a0)	; send Sonic to	high plane
		rts
; ===========================================================================

loc_13976:
		move.w	8(a0),d2
		cmpi.b	#$2C,d2
		bcc.s	loc_13988
		bclr	#6,1(a0)	; send Sonic to	high plane
		rts
; ===========================================================================

loc_13988:
		cmpi.b	#-$20,d2
		bcs.s	loc_13996
		bset	#6,1(a0)	; send Sonic to	low plane
		rts
; ===========================================================================

loc_13996:
		btst	#6,1(a0)
		bne.s	loc_139B2
		move.b	$26(a0),d1
		beq.s	locret_139C2
		cmpi.b	#-$80,d1
		bhi.s	locret_139C2
		bset	#6,1(a0)	; send Sonic to	low plane
		rts
; ===========================================================================

loc_139B2:
		move.b	$26(a0),d1
		cmpi.b	#-$80,d1
		bls.s	locret_139C2
		bclr	#6,1(a0)	; send Sonic to	high plane

locret_139C2:
		rts
; End of function Sonic_Loops

; ---------------------------------------------------------------------------
; Subroutine to	animate	Sonic's sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Animate:				; XREF: Obj01_Control; et al
		lea	(SonicAniData).l,a1
		moveq	#0,d0
		move.b	$1C(a0),d0
		cmp.b	$1D(a0),d0	; is animation set to restart?
		beq.s	SAnim_Do	; if not, branch
		move.b	d0,$1D(a0)	; set to "no restart"
		move.b	#0,$1B(a0)	; reset	animation
		move.b	#0,$1E(a0)	; reset	frame duration

SAnim_Do:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1	; jump to appropriate animation	script
		move.b	(a1),d0
		bmi.s	SAnim_WalkRun	; if animation is walk/run/roll/jump, branch
		move.b	$22(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		subq.b	#1,$1E(a0)	; subtract 1 from frame	duration
		bpl.s	SAnim_Delay	; if time remains, branch
		move.b	d0,$1E(a0)	; load frame duration

SAnim_Do2:
		moveq	#0,d1
		move.b	$1B(a0),d1	; load current frame number
		move.b	1(a1,d1.w),d0	; read sprite number from script
		bmi.s	SAnim_End_FF	; if animation is complete, branch

SAnim_Next:
		move.b	d0,$1A(a0)	; load sprite number
		addq.b	#1,$1B(a0)	; next frame number

SAnim_Delay:
		rts
; ===========================================================================

SAnim_End_FF:
		addq.b	#1,d0		; is the end flag = $FF	?
		bne.s	SAnim_End_FE	; if not, branch
		move.b	#0,$1B(a0)	; restart the animation
		move.b	1(a1),d0	; read sprite number
		bra.s	SAnim_Next
; ===========================================================================

SAnim_End_FE:
		addq.b	#1,d0		; is the end flag = $FE	?
		bne.s	SAnim_End_FD	; if not, branch
		move.b	2(a1,d1.w),d0	; read the next	byte in	the script
		sub.b	d0,$1B(a0)	; jump back d0 bytes in	the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0	; read sprite number
		bra.s	SAnim_Next
; ===========================================================================

SAnim_End_FD:
		addq.b	#1,d0		; is the end flag = $FD	?
		bne.s	SAnim_End	; if not, branch
		move.b	2(a1,d1.w),$1C(a0) ; read next byte, run that animation

SAnim_End:
		rts
; ===========================================================================

SAnim_WalkRun:				; XREF: SAnim_Do
		subq.b	#1,$1E(a0)	; subtract 1 from frame	duration
		bpl.s	SAnim_Delay	; if time remains, branch
		addq.b	#1,d0		; is animation walking/running?
		bne.w	SAnim_RollJump	; if not, branch
		moveq	#0,d1
		move.b	$26(a0),d0	; get Sonic's angle
		move.b	$22(a0),d2
		andi.b	#1,d2		; is Sonic mirrored horizontally?
		bne.s	loc_13A70	; if yes, branch
		not.b	d0		; reverse angle

loc_13A70:
		addi.b	#$10,d0		; add $10 to angle
		bpl.s	loc_13A78	; if angle is $0-$7F, branch
		moveq	#3,d1

loc_13A78:
		andi.b	#$FC,1(a0)
		eor.b	d1,d2
		or.b	d2,1(a0)
		btst	#5,$22(a0)
		bne.w	SAnim_Push
		lsr.b	#4,d0		; divide angle by $10
		andi.b	#6,d0		; angle	must be	0, 2, 4	or 6
		move.w	$14(a0),d2	; get Sonic's speed
		bpl.s	loc_13A9C
		neg.w	d2

loc_13A9C:
		lea	(SonAni_Run).l,a1 ; use	running	animation
		cmpi.w	#$600,d2	; is Sonic at running speed?
		bcc.s	loc_13AB4	; if yes, branch
		lea	(SonAni_Walk).l,a1 ; use walking animation
		move.b	d0,d1
		lsr.b	#1,d1
		add.b	d1,d0

loc_13AB4:
		add.b	d0,d0
		move.b	d0,d3
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	loc_13AC2
		moveq	#0,d2

loc_13AC2:
		lsr.w	#8,d2
		move.b	d2,$1E(a0)	; modify frame duration
		bsr.w	SAnim_Do2
		add.b	d3,$1A(a0)	; modify frame number
		rts
; ===========================================================================

SAnim_RollJump:				; XREF: SAnim_WalkRun
		addq.b	#1,d0		; is animation rolling/jumping?
		bne.s	SAnim_Push	; if not, branch
		move.w	$14(a0),d2	; get Sonic's speed
		bpl.s	loc_13ADE
		neg.w	d2

loc_13ADE:
		lea	(SonAni_Roll2).l,a1 ; use fast animation
		cmpi.w	#$600,d2	; is Sonic moving fast?
		bcc.s	loc_13AF0	; if yes, branch
		lea	(SonAni_Roll).l,a1 ; use slower	animation

loc_13AF0:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	loc_13AFA
		moveq	#0,d2

loc_13AFA:
		lsr.w	#8,d2
		move.b	d2,$1E(a0)	; modify frame duration
		move.b	$22(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		bra.w	SAnim_Do2
; ===========================================================================

SAnim_Push:				; XREF: SAnim_RollJump
		move.w	$14(a0),d2	; get Sonic's speed
		bmi.s	loc_13B1E
		neg.w	d2

loc_13B1E:
		addi.w	#$800,d2
		bpl.s	loc_13B26
		moveq	#0,d2

loc_13B26:
		lsr.w	#6,d2
		move.b	d2,$1E(a0)	; modify frame duration
		lea	(SonAni_Push).l,a1
		move.b	$22(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		bra.w	SAnim_Do2
; End of function Sonic_Animate

; ===========================================================================
SonicAniData:
	include "_anim\Sonic.asm"

; ---------------------------------------------------------------------------
; Sonic	pattern	loading	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadSonicDynPLC:			; XREF: Obj01_Control; et al
		moveq	#0,d0
		move.b	$1A(a0),d0	; load frame number
		cmp.b	($FFFFF766).w,d0
		beq.s	locret_13C96
		move.b	d0,($FFFFF766).w
		lea	(SonicDynPLC).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1	; read "number of entries" value
		subq.b	#1,d1
		bmi.s	locret_13C96
		lea	($FFFFC800).w,a3
		move.b	#1,($FFFFF767).w

SPLC_ReadEntry:
		moveq	#0,d2
		move.b	(a2)+,d2
		move.w	d2,d0
		lsr.b	#4,d0
		lsl.w	#8,d2
		move.b	(a2)+,d2
		lsl.w	#5,d2
		lea	(Art_Sonic).l,a1
		adda.l	d2,a1

SPLC_LoadTile:
		movem.l	(a1)+,d2-d6/a4-a6
		movem.l	d2-d6/a4-a6,(a3)
		lea	$20(a3),a3	; next tile
		dbf	d0,SPLC_LoadTile ; repeat for number of	tiles

		dbf	d1,SPLC_ReadEntry ; repeat for number of entries

locret_13C96:
		rts
; End of function LoadSonicDynPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0A - drowning countdown numbers and small bubbles (LZ)
; ---------------------------------------------------------------------------

Obj0A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj0A_Index(pc,d0.w),d1
		jmp	Obj0A_Index(pc,d1.w)
; ===========================================================================
Obj0A_Index:	dc.w Obj0A_Main-Obj0A_Index, Obj0A_Animate-Obj0A_Index
		dc.w Obj0A_ChkWater-Obj0A_Index, Obj0A_Display-Obj0A_Index
		dc.w Obj0A_Delete2-Obj0A_Index,	Obj0A_Countdown-Obj0A_Index
		dc.w Obj0A_AirLeft-Obj0A_Index,	Obj0A_Display-Obj0A_Index
		dc.w Obj0A_Delete2-Obj0A_Index
; ===========================================================================

Obj0A_Main:				; XREF: Obj0A_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj64,4(a0)
		move.w	#$8348,2(a0)
		move.b	#$84,1(a0)
		move.b	#$10,$19(a0)
		move.b	#1,$18(a0)
		move.b	$28(a0),d0
		bpl.s	loc_13D00
		addq.b	#8,$24(a0)
		move.l	#Map_obj0A,4(a0)
		move.w	#$440,2(a0)
		andi.w	#$7F,d0
		move.b	d0,$33(a0)
		bra.w	Obj0A_Countdown
; ===========================================================================

loc_13D00:
		move.b	d0,$1C(a0)
		move.w	8(a0),$30(a0)
		move.w	#-$88,$12(a0)

Obj0A_Animate:				; XREF: Obj0A_Index
		lea	(Ani_obj0A).l,a1
		jsr	AnimateSprite

Obj0A_ChkWater:				; XREF: Obj0A_Index
		move.w	($FFFFF646).w,d0
		cmp.w	$C(a0),d0	; has bubble reached the water surface?
		bcs.s	Obj0A_Wobble	; if not, branch
		move.b	#6,$24(a0)
		addq.b	#7,$1C(a0)
		cmpi.b	#$D,$1C(a0)
		beq.s	Obj0A_Display
		bra.s	Obj0A_Display
; ===========================================================================

Obj0A_Wobble:
		tst.b	($FFFFF7C7).w
		beq.s	loc_13D44
		addq.w	#4,$30(a0)

loc_13D44:
		move.b	$26(a0),d0
		addq.b	#1,$26(a0)
		andi.w	#$7F,d0
		lea	(Obj0A_WobbleData).l,a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	$30(a0),d0
		move.w	d0,8(a0)
		bsr.s	Obj0A_ShowNumber
		jsr	SpeedToPos
		tst.b	1(a0)
		bpl.s	Obj0A_Delete
		jmp	DisplaySprite
; ===========================================================================

Obj0A_Delete:
		jmp	DeleteObject
; ===========================================================================

Obj0A_Display:				; XREF: Obj0A_Index
		bsr.s	Obj0A_ShowNumber
		lea	(Ani_obj0A).l,a1
		jsr	AnimateSprite
		jmp	DisplaySprite
; ===========================================================================

Obj0A_Delete2:				; XREF: Obj0A_Index
		jmp	DeleteObject
; ===========================================================================

Obj0A_AirLeft:				; XREF: Obj0A_Index
		cmpi.w	#$C,($FFFFFE14).w ; check air remaining
		bhi.s	Obj0A_Delete3	; if higher than $C, branch
		subq.w	#1,$38(a0)
		bne.s	Obj0A_Display2
		move.b	#$E,$24(a0)
		addq.b	#7,$1C(a0)
		bra.s	Obj0A_Display
; ===========================================================================

Obj0A_Display2:
		lea	(Ani_obj0A).l,a1
		jsr	AnimateSprite
		tst.b	1(a0)
		bpl.s	Obj0A_Delete3
		jmp	DisplaySprite
; ===========================================================================

Obj0A_Delete3:
		jmp	DeleteObject
; ===========================================================================

Obj0A_ShowNumber:			; XREF: Obj0A_Wobble; Obj0A_Display
		tst.w	$38(a0)
		beq.s	locret_13E1A
		subq.w	#1,$38(a0)
		bne.s	locret_13E1A
		cmpi.b	#7,$1C(a0)
		bcc.s	locret_13E1A
		move.w	#$F,$38(a0)
		clr.w	$12(a0)
		move.b	#$80,1(a0)
		move.w	8(a0),d0
		sub.w	($FFFFF700).w,d0
		addi.w	#$80,d0
		move.w	d0,8(a0)
		move.w	$C(a0),d0
		sub.w	($FFFFF704).w,d0
		addi.w	#$80,d0
		move.w	d0,$A(a0)
		move.b	#$C,$24(a0)

locret_13E1A:
		rts
; ===========================================================================
Obj0A_WobbleData:
		dc.b 0, 0, 0, 0, 0, 0,	1, 1, 1, 1, 1, 2, 2, 2,	2, 2, 2
		dc.b 2,	3, 3, 3, 3, 3, 3, 3, 3,	3, 3, 3, 3, 3, 3, 4, 3
		dc.b 3,	3, 3, 3, 3, 3, 3, 3, 3,	3, 3, 3, 3, 2, 2, 2, 2
		dc.b 2,	2, 2, 1, 1, 1, 1, 1, 0,	0, 0, 0, 0, 0, -1, -1
		dc.b -1, -1, -1, -2, -2, -2, -2, -2, -3, -3, -3, -3, -3
		dc.b -3, -3, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4
		dc.b -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4
		dc.b -4, -4, -4, -4, -4, -3, -3, -3, -3, -3, -3, -3, -2
		dc.b -2, -2, -2, -2, -1, -1, -1, -1, -1
; ===========================================================================

Obj0A_Countdown:			; XREF: Obj0A_Index
		tst.w	$2C(a0)
		bne.w	loc_13F86
		cmpi.b	#6,($FFFFD024).w
		bcc.w	locret_1408C
		btst	#6,($FFFFD022).w
		beq.w	locret_1408C
		subq.w	#1,$38(a0)
		bpl.w	loc_13FAC
		move.w	#59,$38(a0)
		move.w	#1,$36(a0)
		jsr	(RandomNumber).l
		andi.w	#1,d0
		move.b	d0,$34(a0)
		move.w	($FFFFFE14).w,d0 ; check air remaining
		cmpi.w	#$19,d0
		beq.s	Obj0A_WarnSound	; play sound if	air is $19
		cmpi.w	#$14,d0
		beq.s	Obj0A_WarnSound
		cmpi.w	#$F,d0
		beq.s	Obj0A_WarnSound
		cmpi.w	#$C,d0
		bhi.s	Obj0A_ReduceAir	; if air is above $C, branch
		bne.s	loc_13F02
		moveq	#mus_Drowning,d0
		jsr	(PlaySound).l	; play countdown music

loc_13F02:
		subq.b	#1,$32(a0)
		bpl.s	Obj0A_ReduceAir
		move.b	$33(a0),$32(a0)
		bset	#7,$36(a0)
		bra.s	Obj0A_ReduceAir
; ===========================================================================

Obj0A_WarnSound:			; XREF: Obj0A_Countdown
		moveq	#sfx_AirDing,d0
		jsr	PlaySound_Special ;	play "ding-ding" warning sound

Obj0A_ReduceAir:
		subq.w	#1,($FFFFFE14).w ; subtract 1 from air remaining
		bcc.w	Obj0A_GoMakeItem ; if air is above 0, branch
		bsr.w	ResumeMusic
		move.b	#$81,($FFFFF7C8).w ; lock controls
		moveq	#sfx_Drown,d0
		jsr	PlaySound_Special ;	play drowning sound
		move.b	#$A,$34(a0)
		move.w	#1,$36(a0)
		move.w	#$78,$2C(a0)
		move.l	a0,-(sp)
		lea	($FFFFD000).w,a0
		bsr.w	Sonic_ResetOnFloor
		move.b	#$17,$1C(a0)	; use Sonic's drowning animation
		bset	#1,$22(a0)
		bset	#7,2(a0)
		move.w	#0,$12(a0)
		move.w	#0,$10(a0)
		move.w	#0,$14(a0)
		move.b	#1,($FFFFF744).w
		movea.l	(sp)+,a0
		rts
; ===========================================================================

loc_13F86:
		subq.w	#1,$2C(a0)
		bne.s	loc_13F94
		move.b	#6,($FFFFD024).w
		rts
; ===========================================================================

loc_13F94:
		move.l	a0,-(sp)
		lea	($FFFFD000).w,a0
		jsr	SpeedToPos
		addi.w	#$10,$12(a0)
		movea.l	(sp)+,a0
		bra.s	loc_13FAC
; ===========================================================================

Obj0A_GoMakeItem:			; XREF: Obj0A_ReduceAir
		bra.s	Obj0A_MakeItem
; ===========================================================================

loc_13FAC:
		tst.w	$36(a0)
		beq.w	locret_1408C
		subq.w	#1,$3A(a0)
		bpl.w	locret_1408C

Obj0A_MakeItem:
		jsr	(RandomNumber).l
		andi.w	#$F,d0
		move.w	d0,$3A(a0)
		jsr	SingleObjLoad
		bne.w	locret_1408C
		move.b	#$A,0(a1)	; load object
		move.w	($FFFFD008).w,8(a1) ; match X position to Sonic
		moveq	#6,d0
		btst	#0,($FFFFD022).w
		beq.s	loc_13FF2
		neg.w	d0
		move.b	#$40,$26(a1)

loc_13FF2:
		add.w	d0,8(a1)
		move.w	($FFFFD00C).w,$C(a1)
		move.b	#6,$28(a1)
		tst.w	$2C(a0)
		beq.w	loc_1403E
		andi.w	#7,$3A(a0)
		addi.w	#0,$3A(a0)
		move.w	($FFFFD00C).w,d0
		subi.w	#$C,d0
		move.w	d0,$C(a1)
		jsr	(RandomNumber).l
		move.b	d0,$26(a1)
		move.w	($FFFFFE04).w,d0
		andi.b	#3,d0
		bne.s	loc_14082
		move.b	#$E,$28(a1)
		bra.s	loc_14082
; ===========================================================================

loc_1403E:
		btst	#7,$36(a0)
		beq.s	loc_14082
		move.w	($FFFFFE14).w,d2
		lsr.w	#1,d2
		jsr	(RandomNumber).l
		andi.w	#3,d0
		bne.s	loc_1406A
		bset	#6,$36(a0)
		bne.s	loc_14082
		move.b	d2,$28(a1)
		move.w	#$1C,$38(a1)

loc_1406A:
		tst.b	$34(a0)
		bne.s	loc_14082
		bset	#6,$36(a0)
		bne.s	loc_14082
		move.b	d2,$28(a1)
		move.w	#$1C,$38(a1)

loc_14082:
		subq.b	#1,$34(a0)
		bpl.s	locret_1408C
		clr.w	$36(a0)

locret_1408C:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	play music for LZ/SBZ3 after a countdown
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ResumeMusic:				; XREF: Obj64_Wobble; Sonic_Water; Obj0A_ReduceAir
		cmpi.w	#$C,($FFFFFE14).w
		bhi.s	loc_140AC
		moveq	#mus_LZ,d0	; play LZ music
		cmpi.w	#$103,($FFFFFE10).w ; check if level is	0103 (SBZ3)
		bne.s	loc_140A6
		moveq	#mus_SBZ,d0	; play SBZ music

loc_140A6:
		jsr	(PlaySound).l

loc_140AC:
		move.w	#$1E,($FFFFFE14).w
		clr.b	($FFFFD372).w
		rts
; End of function ResumeMusic

; ===========================================================================
Ani_obj0A:
	include "_anim\obj0A.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - drowning countdown numbers (LZ)
; ---------------------------------------------------------------------------
Map_obj0A:
	include "_maps\obj0A.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 38 - shield and invincibility stars
; ---------------------------------------------------------------------------

Obj38:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj38_Index(pc,d0.w),d1
		jmp	Obj38_Index(pc,d1.w)
; ===========================================================================
Obj38_Index:	dc.w Obj38_Main-Obj38_Index
		dc.w Obj38_Shield-Obj38_Index
		dc.w Obj38_Stars-Obj38_Index
; ===========================================================================

Obj38_Main:				; XREF: Obj38_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj38,4(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#$10,$19(a0)
		tst.b	$1C(a0)		; is object a shield?
		bne.s	Obj38_DoStars	; if not, branch
		move.w	#$541,2(a0)	; shield specific code
		rts
; ===========================================================================

Obj38_DoStars:
		addq.b	#2,$24(a0)	; stars	specific code
		move.w	#$55C,2(a0)
		rts
; ===========================================================================

Obj38_Shield:				; XREF: Obj38_Index
		tst.b	($FFFFFE2D).w	; does Sonic have invincibility?
		bne.s	Obj38_RmvShield	; if yes, branch
		tst.b	($FFFFFE2C).w	; does Sonic have shield?
		beq.s	Obj38_Delete	; if not, branch
		move.w	($FFFFD008).w,8(a0)
		move.w	($FFFFD00C).w,$C(a0)
		move.b	($FFFFD022).w,$22(a0)
		lea	(Ani_obj38).l,a1
		jsr	AnimateSprite
		jmp	DisplaySprite
; ===========================================================================

Obj38_RmvShield:
		rts
; ===========================================================================

Obj38_Delete:
		jmp	DeleteObject
; ===========================================================================

Obj38_Stars:				; XREF: Obj38_Index
		tst.b	($FFFFFE2D).w	; does Sonic have invincibility?
		beq.s	Obj38_Delete2	; if not, branch
		move.w	($FFFFF7A8).w,d0
		move.b	$1C(a0),d1
		subq.b	#1,d1
		bra.s	Obj38_StarTrail
; ===========================================================================
		lsl.b	#4,d1
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	$30(a0),d1
		sub.b	d1,d0
		addq.b	#4,d1
		andi.b	#$F,d1
		move.b	d1,$30(a0)
		bra.s	Obj38_StarTrail2a
; ===========================================================================

Obj38_StarTrail:			; XREF: Obj38_Stars
		lsl.b	#3,d1
		move.b	d1,d2
		add.b	d1,d1
		add.b	d2,d1
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	$30(a0),d1
		sub.b	d1,d0
		addq.b	#4,d1
		cmpi.b	#$18,d1
		bcs.s	Obj38_StarTrail2
		moveq	#0,d1

Obj38_StarTrail2:
		move.b	d1,$30(a0)

Obj38_StarTrail2a:
		lea	($FFFFCB00).w,a1
		lea	(a1,d0.w),a1
		move.w	(a1)+,8(a0)
		move.w	(a1)+,$C(a0)
		move.b	($FFFFD022).w,$22(a0)
		lea	(Ani_obj38).l,a1
		jsr	AnimateSprite
		jmp	DisplaySprite
; ===========================================================================

Obj38_Delete2:				; XREF: Obj38_Stars
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4A - special stage entry from beta
; ---------------------------------------------------------------------------

Obj4A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj4A_Index(pc,d0.w),d1
		jmp	Obj4A_Index(pc,d1.w)
; ===========================================================================
Obj4A_Index:	dc.w Obj4A_Main-Obj4A_Index
		dc.w Obj4A_RmvSonic-Obj4A_Index
		dc.w Obj4A_LoadSonic-Obj4A_Index
; ===========================================================================

Obj4A_Main:				; XREF: Obj4A_Index
		tst.l	($FFFFF680).w	; are pattern load cues	empty?
		beq.s	Obj4A_Main2	; if yes, branch
		rts
; ===========================================================================

Obj4A_Main2:
		addq.b	#2,$24(a0)
		move.l	#Map_obj4A,4(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#$38,$19(a0)
		move.w	#$541,2(a0)
		move.w	#120,$30(a0)	; set time for Sonic's disappearance to 2 seconds

Obj4A_RmvSonic:				; XREF: Obj4A_Index
		move.w	($FFFFD008).w,8(a0)
		move.w	($FFFFD00C).w,$C(a0)
		move.b	($FFFFD022).w,$22(a0)
		lea	(Ani_obj4A).l,a1
		jsr	AnimateSprite
		cmpi.b	#2,$1A(a0)
		bne.s	Obj4A_Display
		tst.b	($FFFFD000).w
		beq.s	Obj4A_Display
		move.b	#0,($FFFFD000).w ; remove Sonic
		moveq	#sfx_Goal,d0
		jsr	(PlaySound_Special).l ;	play Special Stage "GOAL" sound

Obj4A_Display:
		jmp	DisplaySprite
; ===========================================================================

Obj4A_LoadSonic:			; XREF: Obj4A_Index
		subq.w	#1,$30(a0)	; subtract 1 from time
		bne.s	Obj4A_Wait	; if time remains, branch
		move.b	#1,($FFFFD000).w ; load	Sonic object
		jmp	DeleteObject
; ===========================================================================

Obj4A_Wait:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 08 - water splash (LZ)
; ---------------------------------------------------------------------------

Obj08:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj08_Index(pc,d0.w),d1
		jmp	Obj08_Index(pc,d1.w)
; ===========================================================================
Obj08_Index:	dc.w Obj08_Main-Obj08_Index
		dc.w Obj08_Display-Obj08_Index
		dc.w Obj08_Delete-Obj08_Index
; ===========================================================================

Obj08_Main:				; XREF: Obj08_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj08,4(a0)
		ori.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#$10,$19(a0)
		move.w	#$4259,2(a0)
		move.w	($FFFFD008).w,8(a0) ; copy x-position from Sonic

Obj08_Display:				; XREF: Obj08_Index
		move.w	($FFFFF646).w,$C(a0) ; copy y-position from water height
		lea	(Ani_obj08).l,a1
		jsr	AnimateSprite
		jmp	DisplaySprite
; ===========================================================================

Obj08_Delete:				; XREF: Obj08_Index
		jmp	DeleteObject	; delete when animation	is complete
; ===========================================================================
Ani_obj38:
	include "_anim\obj38.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - shield and invincibility stars
; ---------------------------------------------------------------------------
Map_obj38:
	include "_maps\obj38.asm"

Ani_obj4A:
	include "_anim\obj4A.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - special stage entry	from beta
; ---------------------------------------------------------------------------
Map_obj4A:
	include "_maps\obj4A.asm"

Ani_obj08:
	include "_anim\obj08.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - water splash (LZ)
; ---------------------------------------------------------------------------
Map_obj08:
	include "_maps\obj08.asm"

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's angle & position as he walks along the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_AnglePos:				; XREF: Obj01_MdNormal; Obj01_MdRoll
		btst	#3,$22(a0)
		beq.s	loc_14602
		moveq	#0,d0
		move.b	d0,($FFFFF768).w
		move.b	d0,($FFFFF76A).w
		rts
; ===========================================================================

loc_14602:
		moveq	#3,d0
		move.b	d0,($FFFFF768).w
		move.b	d0,($FFFFF76A).w
		move.b	$26(a0),d0
		addi.b	#$20,d0
		bpl.s	loc_14624
		move.b	$26(a0),d0
		bpl.s	loc_1461E
		subq.b	#1,d0

loc_1461E:
		addi.b	#$20,d0
		bra.s	loc_14630
; ===========================================================================

loc_14624:
		move.b	$26(a0),d0
		bpl.s	loc_1462C
		addq.b	#1,d0

loc_1462C:
		addi.b	#$1F,d0

loc_14630:
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	Sonic_WalkVertL
		cmpi.b	#$80,d0
		beq.w	Sonic_WalkCeiling
		cmpi.b	#$C0,d0
		beq.w	Sonic_WalkVertR
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d3
		lea	($FFFFF76A).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_146BE
		bpl.s	loc_146C0
		cmpi.w	#-$E,d1
		blt.s	locret_146E6
		add.w	d1,$C(a0)

locret_146BE:
		rts
; ===========================================================================

loc_146C0:
		cmpi.w	#$E,d1
		bgt.s	loc_146CC

loc_146C6:
		add.w	d1,$C(a0)
		rts
; ===========================================================================

loc_146CC:
		tst.b	$38(a0)
		bne.s	loc_146C6
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts
; ===========================================================================

locret_146E6:
		rts
; End of function Sonic_AnglePos

; ===========================================================================
		move.l	8(a0),d2
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.l	d2,8(a0)
		move.w	#$38,d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,$C(a0)
		rts
; ===========================================================================

locret_1470A:
		rts
; ===========================================================================
		move.l	$C(a0),d3
		move.w	$12(a0),d0
		subi.w	#$38,d0
		move.w	d0,$12(a0)
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,$C(a0)
		rts
		rts
; ===========================================================================
		move.l	8(a0),d2
		move.l	$C(a0),d3
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.w	$12(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d2,8(a0)
		move.l	d3,$C(a0)
		rts

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's angle as he walks along the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Angle:				; XREF: Sonic_AnglePos; et al
		move.b	($FFFFF76A).w,d2
		cmp.w	d0,d1
		ble.s	loc_1475E
		move.b	($FFFFF768).w,d2
		move.w	d0,d1

loc_1475E:
		btst	#0,d2
		bne.s	loc_1476A
		move.b	d2,$26(a0)
		rts
; ===========================================================================

loc_1476A:
		move.b	$26(a0),d2
		addi.b	#$20,d2
		andi.b	#$C0,d2
		move.b	d2,$26(a0)
		rts
; End of function Sonic_Angle

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to	his right
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkVertR:			; XREF: Sonic_AnglePos
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF76A).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_147F0
		bpl.s	loc_147F2
		cmpi.w	#-$E,d1
		blt.w	locret_1470A
		add.w	d1,8(a0)

locret_147F0:
		rts
; ===========================================================================

loc_147F2:
		cmpi.w	#$E,d1
		bgt.s	loc_147FE

loc_147F8:
		add.w	d1,8(a0)
		rts
; ===========================================================================

loc_147FE:
		tst.b	$38(a0)
		bne.s	loc_147F8
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts
; End of function Sonic_WalkVertR

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk upside-down
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkCeiling:			; XREF: Sonic_AnglePos
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		movea.w	#-$10,a3
		move.w	#$1000,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	($FFFFF76A).w,a4
		movea.w	#-$10,a3
		move.w	#$1000,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_14892
		bpl.s	loc_14894
		cmpi.w	#-$E,d1
		blt.w	locret_146E6
		sub.w	d1,$C(a0)

locret_14892:
		rts
; ===========================================================================

loc_14894:
		cmpi.w	#$E,d1
		bgt.s	loc_148A0

loc_1489A:
		sub.w	d1,$C(a0)
		rts
; ===========================================================================

loc_148A0:
		tst.b	$38(a0)
		bne.s	loc_1489A
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts
; End of function Sonic_WalkCeiling

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to	his left
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkVertL:			; XREF: Sonic_AnglePos
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	($FFFFF768).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	($FFFFF76A).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_14934
		bpl.s	loc_14936
		cmpi.w	#-$E,d1
		blt.w	locret_1470A
		sub.w	d1,8(a0)

locret_14934:
		rts
; ===========================================================================

loc_14936:
		cmpi.w	#$E,d1
		bgt.s	loc_14942

loc_1493C:
		sub.w	d1,8(a0)
		rts
; ===========================================================================

loc_14942:
		tst.b	$38(a0)
		bne.s	loc_1493C
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts
; End of function Sonic_WalkVertL

; ---------------------------------------------------------------------------
; Subroutine to	find which tile	the object is standing on
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Floor_ChkTile:				; XREF: FindFloor; et al
		move.w	d2,d0
		lsr.w	#1,d0
		andi.w	#$380,d0
		move.w	d3,d1
		lsr.w	#8,d1
		andi.w	#$7F,d1
		add.w	d1,d0
		moveq	#-1,d1
		lea	($FFFFA400).w,a1
		move.b	(a1,d0.w),d1
		beq.s	loc_14996
		bmi.s	loc_1499A
		subq.b	#1,d1
		ext.w	d1
		ror.w	#7,d1
		move.w	d2,d0
		add.w	d0,d0
		andi.w	#$1E0,d0
		add.w	d0,d1
		move.w	d3,d0
		lsr.w	#3,d0
		andi.w	#$1E,d0
		add.w	d0,d1

loc_14996:
		movea.l	d1,a1
		rts
; ===========================================================================

loc_1499A:
		andi.w	#$7F,d1
		btst	#6,1(a0)
		beq.s	loc_149B2
		addq.w	#1,d1
		cmpi.w	#$29,d1
		bne.s	loc_149B2
		move.w	#$51,d1

loc_149B2:
		subq.b	#1,d1
		ror.w	#7,d1
		move.w	d2,d0
		add.w	d0,d0
		andi.w	#$1E0,d0
		add.w	d0,d1
		move.w	d3,d0
		lsr.w	#3,d0
		andi.w	#$1E,d0
		add.w	d0,d1
		movea.l	d1,a1
		rts
; End of function Floor_ChkTile


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FindFloor:				; XREF: Sonic_AnglePos; et al
		bsr.s	Floor_ChkTile
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$7FF,d0
		beq.s	loc_149DE
		btst	d5,d4
		bne.s	loc_149EC

loc_149DE:
		add.w	a3,d2
		bsr.w	FindFloor2
		sub.w	a3,d2
		addi.w	#$10,d1
		rts
; ===========================================================================

loc_149EC:
		movea.l	($FFFFF796).w,a2 ; load	collision index
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	loc_149DE
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d3,d1
		btst	#$B,d4
		beq.s	loc_14A12
		not.w	d1
		neg.b	(a4)

loc_14A12:
		btst	#$C,d4
		beq.s	loc_14A22
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_14A22:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(CollArray1).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$C,d4
		beq.s	loc_14A3E
		neg.w	d0

loc_14A3E:
		tst.w	d0
		beq.s	loc_149DE
		bmi.s	loc_14A5A
		cmpi.b	#$10,d0
		beq.s	loc_14A66
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
; ===========================================================================

loc_14A5A:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_149DE

loc_14A66:
		sub.w	a3,d2
		bsr.w	FindFloor2
		add.w	a3,d2
		subi.w	#$10,d1
		rts
; End of function FindFloor


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FindFloor2:				; XREF: FindFloor
		bsr.w	Floor_ChkTile
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$7FF,d0
		beq.s	loc_14A86
		btst	d5,d4
		bne.s	loc_14A94

loc_14A86:
		move.w	#$F,d1
		move.w	d2,d0
		andi.w	#$F,d0
		sub.w	d0,d1
		rts
; ===========================================================================

loc_14A94:
		movea.l	($FFFFF796).w,a2
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	loc_14A86
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d3,d1
		btst	#$B,d4
		beq.s	loc_14ABA
		not.w	d1
		neg.b	(a4)

loc_14ABA:
		btst	#$C,d4
		beq.s	loc_14ACA
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_14ACA:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(CollArray1).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$C,d4
		beq.s	loc_14AE6
		neg.w	d0

loc_14AE6:
		tst.w	d0
		beq.s	loc_14A86
		bmi.s	loc_14AFC
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
; ===========================================================================

loc_14AFC:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_14A86
		not.w	d1
		rts
; End of function FindFloor2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FindWall:				; XREF: Sonic_WalkVertR; et al
		bsr.w	Floor_ChkTile
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$7FF,d0
		beq.s	loc_14B1E
		btst	d5,d4
		bne.s	loc_14B2C

loc_14B1E:
		add.w	a3,d3
		bsr.w	FindWall2
		sub.w	a3,d3
		addi.w	#$10,d1
		rts
; ===========================================================================

loc_14B2C:
		movea.l	($FFFFF796).w,a2
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	loc_14B1E
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d2,d1
		btst	#$C,d4
		beq.s	loc_14B5A
		not.w	d1
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_14B5A:
		btst	#$B,d4
		beq.s	loc_14B62
		neg.b	(a4)

loc_14B62:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(CollArray2).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$B,d4
		beq.s	loc_14B7E
		neg.w	d0

loc_14B7E:
		tst.w	d0
		beq.s	loc_14B1E
		bmi.s	loc_14B9A
		cmpi.b	#$10,d0
		beq.s	loc_14BA6
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
; ===========================================================================

loc_14B9A:
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_14B1E

loc_14BA6:
		sub.w	a3,d3
		bsr.w	FindWall2
		add.w	a3,d3
		subi.w	#$10,d1
		rts
; End of function FindWall


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FindWall2:				; XREF: FindWall
		bsr.w	Floor_ChkTile
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$7FF,d0
		beq.s	loc_14BC6
		btst	d5,d4
		bne.s	loc_14BD4

loc_14BC6:
		move.w	#$F,d1
		move.w	d3,d0
		andi.w	#$F,d0
		sub.w	d0,d1
		rts
; ===========================================================================

loc_14BD4:
		movea.l	($FFFFF796).w,a2
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	loc_14BC6
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d2,d1
		btst	#$C,d4
		beq.s	loc_14C02
		not.w	d1
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_14C02:
		btst	#$B,d4
		beq.s	loc_14C0A
		neg.b	(a4)

loc_14C0A:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(CollArray2).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$B,d4
		beq.s	loc_14C26
		neg.w	d0

loc_14C26:
		tst.w	d0
		beq.s	loc_14BC6
		bmi.s	loc_14C3C
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
; ===========================================================================

loc_14C3C:
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_14BC6
		not.w	d1
		rts
; End of function FindWall2

; ---------------------------------------------------------------------------
; Unused floor/wall subroutine - logs something	to do with collision
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FloorLog_Unk:				; XREF: Level
		rts

		lea	(CollArray1).l,a1
		lea	(CollArray1).l,a2
		move.w	#$FF,d3

loc_14C5E:
		moveq	#$10,d5
		move.w	#$F,d2

loc_14C64:
		moveq	#0,d4
		move.w	#$F,d1

loc_14C6A:
		move.w	(a1)+,d0
		lsr.l	d5,d0
		addx.w	d4,d4
		dbf	d1,loc_14C6A

		move.w	d4,(a2)+
		suba.w	#$20,a1
		subq.w	#1,d5
		dbf	d2,loc_14C64

		adda.w	#$20,a1
		dbf	d3,loc_14C5E

		lea	(CollArray1).l,a1
		lea	(CollArray2).l,a2
		bsr.s	FloorLog_Unk2
		lea	(CollArray1).l,a1
		lea	(CollArray1).l,a2

; End of function FloorLog_Unk

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FloorLog_Unk2:				; XREF: FloorLog_Unk
		move.w	#$FFF,d3

loc_14CA6:
		moveq	#0,d2
		move.w	#$F,d1
		move.w	(a1)+,d0
		beq.s	loc_14CD4
		bmi.s	loc_14CBE

loc_14CB2:
		lsr.w	#1,d0
		bcc.s	loc_14CB8
		addq.b	#1,d2

loc_14CB8:
		dbf	d1,loc_14CB2

		bra.s	loc_14CD6
; ===========================================================================

loc_14CBE:
		cmpi.w	#-1,d0
		beq.s	loc_14CD0

loc_14CC4:
		lsl.w	#1,d0
		bcc.s	loc_14CCA
		subq.b	#1,d2

loc_14CCA:
		dbf	d1,loc_14CC4

		bra.s	loc_14CD6
; ===========================================================================

loc_14CD0:
		move.w	#$10,d0

loc_14CD4:
		move.w	d0,d2

loc_14CD6:
		move.b	d2,(a2)+
		dbf	d3,loc_14CA6

		rts

; End of function FloorLog_Unk2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkSpeed:			; XREF: Sonic_Move
		move.l	8(a0),d3
		move.l	$C(a0),d2
		move.w	$10(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d3
		move.w	$12(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d2
		swap	d2
		swap	d3
		move.b	d0,($FFFFF768).w
		move.b	d0,($FFFFF76A).w
		move.b	d0,d1
		addi.b	#$20,d0
		bpl.s	loc_14D1A
		move.b	d1,d0
		bpl.s	loc_14D14
		subq.b	#1,d0

loc_14D14:
		addi.b	#$20,d0
		bra.s	loc_14D24
; ===========================================================================

loc_14D1A:
		move.b	d1,d0
		bpl.s	loc_14D20
		addq.b	#1,d0

loc_14D20:
		addi.b	#$1F,d0

loc_14D24:
		andi.b	#$C0,d0
		beq.w	loc_14DF0
		cmpi.b	#$80,d0
		beq.w	loc_14F7C
		andi.b	#$38,d1
		bne.s	loc_14D3C
		addq.w	#8,d2

loc_14D3C:
		cmpi.b	#$40,d0
		beq.w	loc_1504A
		bra.w	loc_14EBC

; End of function Sonic_WalkSpeed


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_14D48:				; XREF: Sonic_Jump
		move.b	d0,($FFFFF768).w
		move.b	d0,($FFFFF76A).w
		addi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	loc_14FD6
		cmpi.b	#$80,d0
		beq.w	Sonic_DontRunOnWalls
		cmpi.b	#$C0,d0
		beq.w	sub_14E50

; End of function sub_14D48

; ---------------------------------------------------------------------------
; Subroutine to	make Sonic land	on the floor after jumping
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_HitFloor:				; XREF: Sonic_Floor
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	($FFFFF76A).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.w	(sp)+,d0
		move.b	#0,d2

loc_14DD0:
		move.b	($FFFFF76A).w,d3
		cmp.w	d0,d1
		ble.s	loc_14DDE
		move.b	($FFFFF768).w,d3
		exg	d0,d1

loc_14DDE:
		btst	#0,d3
		beq.s	locret_14DE6
		move.b	d2,d3

locret_14DE6:
		rts

; End of function Sonic_HitFloor

; ===========================================================================
		move.w	$C(a0),d2
		move.w	8(a0),d3

loc_14DF0:				; XREF: Sonic_WalkSpeed
		addi.w	#$A,d2
		lea	($FFFFF768).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$E,d5
		bsr.w	FindFloor
		move.b	#0,d2

loc_14E0A:				; XREF: sub_14EB4
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	locret_14E16
		move.b	d2,d3

locret_14E16:
		rts

; ---------------------------------------------------------------------------
; Subroutine allowing objects to interact with the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitFloor:
		move.w	8(a0),d3

; End of function ObjHitFloor


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitFloor2:
		move.w	$C(a0),d2
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		lea	($FFFFF768).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	locret_14E4E
		move.b	#0,d3

locret_14E4E:
		rts
; End of function ObjHitFloor2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_14E50:				; XREF: sub_14D48
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$E,d5
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF76A).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$E,d5
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#-$40,d2
		bra.w	loc_14DD0

; End of function sub_14E50


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_14EB4:				; XREF: Sonic_Floor
		move.w	$C(a0),d2
		move.w	8(a0),d3

loc_14EBC:
		addi.w	#$A,d3
		lea	($FFFFF768).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$E,d5
		bsr.w	FindWall
		move.b	#-$40,d2
		bra.w	loc_14E0A

; End of function sub_14EB4

; ---------------------------------------------------------------------------
; Subroutine to	detect when an object hits a wall to its right
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitWallRight:
		add.w	8(a0),d3
		move.w	$C(a0),d2
		lea	($FFFFF768).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$E,d5
		bsr.w	FindWall
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	locret_14F06
		move.b	#-$40,d3

locret_14F06:
		rts

; End of function ObjHitWallRight

; ---------------------------------------------------------------------------
; Subroutine preventing	Sonic from running on walls and	ceilings when he
; touches them
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_DontRunOnWalls:			; XREF: Sonic_Floor; et al
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		movea.w	#-$10,a3
		move.w	#$1000,d6
		moveq	#$E,d5
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	($FFFFF76A).w,a4
		movea.w	#-$10,a3
		move.w	#$1000,d6
		moveq	#$E,d5
		bsr.w	FindFloor
		move.w	(sp)+,d0
		move.b	#-$80,d2
		bra.w	loc_14DD0
; End of function Sonic_DontRunOnWalls

; ===========================================================================
		move.w	$C(a0),d2
		move.w	8(a0),d3

loc_14F7C:
		subi.w	#$A,d2
		eori.w	#$F,d2
		lea	($FFFFF768).w,a4
		movea.w	#-$10,a3
		move.w	#$1000,d6
		moveq	#$E,d5
		bsr.w	FindFloor
		move.b	#-$80,d2
		bra.w	loc_14E0A

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitCeiling:
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		lea	($FFFFF768).w,a4
		movea.w	#-$10,a3
		move.w	#$1000,d6
		moveq	#$E,d5
		bsr.w	FindFloor
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	locret_14FD4
		move.b	#-$80,d3

locret_14FD4:
		rts
; End of function ObjHitCeiling

; ===========================================================================

loc_14FD6:				; XREF: sub_14D48
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	($FFFFF768).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$E,d5
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	($FFFFF76A).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$E,d5
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#$40,d2
		bra.w	loc_14DD0

; ---------------------------------------------------------------------------
; Subroutine to	stop Sonic when	he jumps at a wall
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_HitWall:				; XREF: Sonic_Floor
		move.w	$C(a0),d2
		move.w	8(a0),d3

loc_1504A:
		subi.w	#$A,d3
		eori.w	#$F,d3
		lea	($FFFFF768).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$E,d5
		bsr.w	FindWall
		move.b	#$40,d2
		bra.w	loc_14E0A
; End of function Sonic_HitWall

; ---------------------------------------------------------------------------
; Subroutine to	detect when an object hits a wall to its left
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitWallLeft:
		add.w	8(a0),d3
		move.w	$C(a0),d2
		lea	($FFFFF768).w,a4
		move.b	#0,(a4)
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$E,d5
		bsr.w	FindWall
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	locret_15098
		move.b	#$40,d3

locret_15098:
		rts
; End of function ObjHitWallLeft

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 66 - rotating disc that grabs Sonic (SBZ)
; ---------------------------------------------------------------------------

Obj66:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj66_Index(pc,d0.w),d1
		jmp	Obj66_Index(pc,d1.w)
; ===========================================================================
Obj66_Index:	dc.w Obj66_Main-Obj66_Index
		dc.w Obj66_Action-Obj66_Index
		dc.w Obj66_Display-Obj66_Index
		dc.w Obj66_Release-Obj66_Index
; ===========================================================================

Obj66_Main:				; XREF: Obj66_Index
		addq.b	#2,$24(a0)
		move.w	#1,d1
		movea.l	a0,a1
		bra.s	Obj66_MakeItem
; ===========================================================================

Obj66_Loop:
		bsr.w	SingleObjLoad
		bne.s	loc_150FE
		move.b	#$66,0(a1)
		addq.b	#4,$24(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#3,$18(a1)
		move.b	#$10,$1A(a1)

Obj66_MakeItem:				; XREF: Obj66_Main
		move.l	#Map_obj66,4(a1)
		move.w	#$4348,2(a1)
		ori.b	#4,1(a1)
		move.b	#$38,$19(a1)

loc_150FE:
		dbf	d1,Obj66_Loop

		move.b	#$30,$19(a0)
		move.b	#4,$18(a0)
		move.w	#$3C,$30(a0)
		move.b	#1,$34(a0)
		move.b	$28(a0),$38(a0)

Obj66_Action:				; XREF: Obj66_Index
		bsr.w	Obj66_ChkSwitch
		tst.b	1(a0)
		bpl.w	Obj66_Display
		move.w	#$30,d1
		move.w	d1,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		btst	#5,$22(a0)
		beq.w	Obj66_Display
		lea	($FFFFD000).w,a1
		moveq	#$E,d1
		move.w	8(a1),d0
		cmp.w	8(a0),d0
		bcs.s	Obj66_GrabSonic
		moveq	#7,d1

Obj66_GrabSonic:
		cmp.b	$1A(a0),d1
		bne.s	Obj66_Display
		move.b	d1,$32(a0)
		addq.b	#4,$24(a0)
		move.b	#1,($FFFFF7C8).w ; lock	controls
		move.b	#2,$1C(a1)	; make Sonic use "rolling" animation
		move.w	#$800,$14(a1)
		move.w	#0,$10(a1)
		move.w	#0,$12(a1)
		bclr	#5,$22(a0)
		bclr	#5,$22(a1)
		bset	#1,$22(a1)
		move.w	8(a1),d2
		move.w	$C(a1),d3
		bsr.w	Obj66_ChgPos
		add.w	d2,8(a1)
		add.w	d3,$C(a1)
		asr	8(a1)
		asr	$C(a1)

Obj66_Display:				; XREF: Obj66_Index
		bra.w	MarkObjGone
; ===========================================================================

Obj66_Release:				; XREF: Obj66_Index
		move.b	$1A(a0),d0
		cmpi.b	#4,d0
		beq.s	loc_151C8
		cmpi.b	#7,d0
		bne.s	loc_151F8

loc_151C8:
		cmp.b	$32(a0),d0
		beq.s	loc_151F8
		lea	($FFFFD000).w,a1
		move.w	#0,$10(a1)
		move.w	#$800,$12(a1)
		cmpi.b	#4,d0
		beq.s	loc_151F0
		move.w	#$800,$10(a1)
		move.w	#$800,$12(a1)

loc_151F0:
		clr.b	($FFFFF7C8).w	; unlock controls
		subq.b	#4,$24(a0)

loc_151F8:
		bsr.s	Obj66_ChkSwitch
		bsr.s	Obj66_ChgPos
		bra.w	MarkObjGone

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj66_ChkSwitch:			; XREF: Obj66_Action
		lea	($FFFFF7E0).w,a2
		moveq	#0,d0
		move.b	$38(a0),d0
		btst	#0,(a2,d0.w)	; is switch pressed?
		beq.s	loc_15224	; if not, branch
		tst.b	$36(a0)		; has switch previously	been pressed?
		bne.s	Obj66_Animate	; if yes, branch
		neg.b	$34(a0)
		move.b	#1,$36(a0)	; set to "previously pressed"
		bra.s	Obj66_Animate
; ===========================================================================

loc_15224:
		clr.b	$36(a0)		; set to "not yet pressed"

Obj66_Animate:
		subq.b	#1,$1E(a0)
		bpl.s	locret_15246
		move.b	#7,$1E(a0)
		move.b	$34(a0),d1
		move.b	$1A(a0),d0
		add.b	d1,d0
		andi.b	#$F,d0
		move.b	d0,$1A(a0)

locret_15246:
		rts
; End of function Obj66_ChkSwitch


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj66_ChgPos:				; XREF: Obj66_GrabSonic
		lea	($FFFFD000).w,a1
		moveq	#0,d0
		move.b	$1A(a0),d0
		add.w	d0,d0
		lea	Obj66_PosData(pc,d0.w),a2
		move.b	(a2)+,d0
		ext.w	d0
		add.w	8(a0),d0
		move.w	d0,8(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	$C(a0),d0
		move.w	d0,$C(a1)
		rts
; End of function Obj66_ChgPos

; ===========================================================================
Obj66_PosData:	dc.b  $E0,   0,	$E2,  $E ; disc	x-pos, Sonic x-pos, disc y-pos,	Sonic y-pos
		dc.b  $E8, $18,	$F2, $1E
		dc.b	0, $20,	 $E, $1E
		dc.b  $18, $18,	$1E,  $E
		dc.b  $20,   0,	$1E, $F2
		dc.b  $18, $E8,	 $E, $E2
		dc.b	0, $E0,	$F2, $E2
		dc.b  $E8, $E8,	$E2, $F2
; ---------------------------------------------------------------------------
; Sprite mappings - rotating disc that grabs Sonic (SBZ)
; ---------------------------------------------------------------------------
Map_obj66:
	include "_maps\obj66.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 67 - disc that	you run	around (SBZ)
; ---------------------------------------------------------------------------

Obj67:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj67_Index(pc,d0.w),d1
		jmp	Obj67_Index(pc,d1.w)
; ===========================================================================
Obj67_Index:	dc.w Obj67_Main-Obj67_Index
		dc.w Obj67_Action-Obj67_Index
; ===========================================================================

Obj67_Main:				; XREF: Obj67_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj67,4(a0)
		move.w	#$C344,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#8,$19(a0)
		move.w	8(a0),$32(a0)
		move.w	$C(a0),$30(a0)
		move.b	#$18,$34(a0)
		move.b	#$48,$38(a0)
		move.b	$28(a0),d1	; get object type
		andi.b	#$F,d1		; read only the	2nd digit
		beq.s	loc_15546
		move.b	#$10,$34(a0)
		move.b	#$38,$38(a0)

loc_15546:
		move.b	$28(a0),d1	; get object type
		andi.b	#$F0,d1		; read only the	1st digit
		ext.w	d1
		asl.w	#3,d1
		move.w	d1,$36(a0)
		move.b	$22(a0),d0
		ror.b	#2,d0
		andi.b	#-$40,d0
		move.b	d0,$26(a0)

Obj67_Action:				; XREF: Obj67_Index
		bsr.w	Obj67_MoveSonic
		bsr.w	Obj67_MoveSpot
		bra.w	Obj67_ChkDel
; ===========================================================================

Obj67_MoveSonic:			; XREF: Obj67_Action
		moveq	#0,d2
		move.b	$38(a0),d2
		move.w	d2,d3
		add.w	d3,d3
		lea	($FFFFD000).w,a1
		move.w	8(a1),d0
		sub.w	$32(a0),d0
		add.w	d2,d0
		cmp.w	d3,d0
		bcc.s	loc_155A8
		move.w	$C(a1),d1
		sub.w	$30(a0),d1
		add.w	d2,d1
		cmp.w	d3,d1
		bcc.s	loc_155A8
		btst	#1,$22(a1)
		beq.s	loc_155B8
		clr.b	$3A(a0)
		rts
; ===========================================================================

loc_155A8:
		tst.b	$3A(a0)
		beq.s	locret_155B6
		clr.b	$38(a1)
		clr.b	$3A(a0)

locret_155B6:
		rts
; ===========================================================================

loc_155B8:
		tst.b	$3A(a0)
		bne.s	loc_155E2
		move.b	#1,$3A(a0)
		btst	#2,$22(a1)
		bne.s	loc_155D0
		clr.b	$1C(a1)

loc_155D0:
		bclr	#5,$22(a1)
		move.b	#1,$1D(a1)
		move.b	#1,$38(a1)

loc_155E2:
		move.w	$14(a1),d0
		tst.w	$36(a0)
		bpl.s	loc_15608
		cmpi.w	#-$400,d0
		ble.s	loc_155FA
		move.w	#-$400,$14(a1)
		rts
; ===========================================================================

loc_155FA:
		cmpi.w	#-$F00,d0
		bge.s	locret_15606
		move.w	#-$F00,$14(a1)

locret_15606:
		rts
; ===========================================================================

loc_15608:
		cmpi.w	#$400,d0
		bge.s	loc_15616
		move.w	#$400,$14(a1)
		rts
; ===========================================================================

loc_15616:
		cmpi.w	#$F00,d0
		ble.s	locret_15622
		move.w	#$F00,$14(a1)

locret_15622:
		rts
; ===========================================================================

Obj67_MoveSpot:				; XREF: Obj67_Action
		move.w	$36(a0),d0
		add.w	d0,$26(a0)
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		move.w	$30(a0),d2
		move.w	$32(a0),d3
		moveq	#0,d4
		move.b	$34(a0),d4
		lsl.w	#8,d4
		move.l	d4,d5
		muls.w	d0,d4
		swap	d4
		muls.w	d1,d5
		swap	d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,$C(a0)
		move.w	d5,8(a0)
		rts
; ===========================================================================

Obj67_ChkDel:				; XREF: Obj67_Action
		move.w	$32(a0),d0
		andi.w	#-$80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#-$80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj67_Delete
		jmp	DisplaySprite
; ===========================================================================

Obj67_Delete:
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - disc that you run around (SBZ)
; (It's just a small blob that moves around in a circle. The disc itself is
; part of the level tiles.)
; ---------------------------------------------------------------------------
Map_obj67:
	include "_maps\obj67.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 68 - conveyor belts (SBZ)
; ---------------------------------------------------------------------------

Obj68:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj68_Index(pc,d0.w),d1
		jmp	Obj68_Index(pc,d1.w)
; ===========================================================================
Obj68_Index:	dc.w Obj68_Main-Obj68_Index
		dc.w Obj68_Action-Obj68_Index
; ===========================================================================

Obj68_Main:				; XREF: Obj68_Index
		addq.b	#2,$24(a0)
		move.b	#128,$38(a0)	; set width to 128 pixels
		move.b	$28(a0),d1	; get object type
		andi.b	#$F,d1		; read only the	2nd digit
		beq.s	loc_156BA	; if zero, branch
		move.b	#56,$38(a0)	; set width to 56 pixels

loc_156BA:
		move.b	$28(a0),d1	; get object type
		andi.b	#$F0,d1		; read only the	1st digit
		ext.w	d1
		asr.w	#4,d1
		move.w	d1,$36(a0)	; set belt speed

Obj68_Action:				; XREF: Obj68_Index
		bsr.s	Obj68_MoveSonic
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj68_Delete
		rts
; ===========================================================================

Obj68_Delete:
		jmp	DeleteObject
; ===========================================================================

Obj68_MoveSonic:			; XREF: Obj68_Action
		moveq	#0,d2
		move.b	$38(a0),d2
		move.w	d2,d3
		add.w	d3,d3
		lea	($FFFFD000).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d2,d0
		cmp.w	d3,d0
		bcc.s	locret_1572E
		move.w	$C(a1),d1
		sub.w	$C(a0),d1
		addi.w	#$30,d1
		cmpi.w	#$30,d1
		bcc.s	locret_1572E
		btst	#1,$22(a1)
		bne.s	locret_1572E
		move.w	$36(a0),d0
		add.w	d0,8(a1)

locret_1572E:
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 69 - spinning platforms and trapdoors (SBZ)
; ---------------------------------------------------------------------------

Obj69:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj69_Index(pc,d0.w),d1
		jmp	Obj69_Index(pc,d1.w)
; ===========================================================================
Obj69_Index:	dc.w Obj69_Main-Obj69_Index
		dc.w Obj69_Trapdoor-Obj69_Index
		dc.w Obj69_Spinner-Obj69_Index
; ===========================================================================

Obj69_Main:				; XREF: Obj69_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj69,4(a0)
		move.w	#$4492,2(a0)
		ori.b	#4,1(a0)
		move.b	#$80,$19(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#$F,d0
		mulu.w	#$3C,d0
		move.w	d0,$32(a0)
		tst.b	$28(a0)
		bpl.s	Obj69_Trapdoor
		addq.b	#2,$24(a0)
		move.l	#Map_obj69a,4(a0)
		move.w	#$4DF,2(a0)
		move.b	#$10,$19(a0)
		move.b	#2,$1C(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; get object type
		move.w	d0,d1
		andi.w	#$F,d0		; read only the	2nd digit
		mulu.w	#6,d0		; multiply by 6
		move.w	d0,$30(a0)	; set time delay
		move.w	d0,$32(a0)
		andi.w	#$70,d1
		addi.w	#$10,d1
		lsl.w	#2,d1
		subq.w	#1,d1
		move.w	d1,$36(a0)
		bra.s	Obj69_Spinner
; ===========================================================================

Obj69_Trapdoor:				; XREF: Obj69_Index
		subq.w	#1,$30(a0)
		bpl.s	Obj69_Animate
		move.w	$32(a0),$30(a0)
		bchg	#0,$1C(a0)
		tst.b	1(a0)
		bpl.s	Obj69_Animate
		moveq	#sfx_Door,d0
		jsr	(PlaySound_Special).l ;	play door sound

Obj69_Animate:
		lea	(Ani_obj69).l,a1
		jsr	AnimateSprite
		tst.b	$1A(a0)		; is frame number 0 displayed?
		bne.s	Obj69_NotSolid	; if not, branch
		move.w	#$4B,d1
		move.w	#$C,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		bra.w	MarkObjGone
; ===========================================================================

Obj69_NotSolid:
		btst	#3,$22(a0)
		beq.s	Obj69_Display
		lea	($FFFFD000).w,a1
		bclr	#3,$22(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)

Obj69_Display:
		bra.w	MarkObjGone
; ===========================================================================

Obj69_Spinner:				; XREF: Obj69_Index
		move.w	($FFFFFE04).w,d0
		and.w	$36(a0),d0
		bne.s	Obj69_Delay
		move.b	#1,$34(a0)

Obj69_Delay:
		tst.b	$34(a0)
		beq.s	Obj69_Animate2
		subq.w	#1,$30(a0)
		bpl.s	Obj69_Animate2
		move.w	$32(a0),$30(a0)
		clr.b	$34(a0)
		bchg	#0,$1C(a0)

Obj69_Animate2:
		lea	(Ani_obj69).l,a1
		jsr	AnimateSprite
		tst.b	$1A(a0)		; check	if frame number	0 is displayed
		bne.s	Obj69_NotSolid2	; if not, branch
		move.w	#$1B,d1
		move.w	#7,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		bra.w	MarkObjGone
; ===========================================================================

Obj69_NotSolid2:
		btst	#3,$22(a0)
		beq.s	Obj69_Display2
		lea	($FFFFD000).w,a1
		bclr	#3,$22(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)

Obj69_Display2:
		bra.w	MarkObjGone
; ===========================================================================
Ani_obj69:
	include "_anim\obj69.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - trapdoor (SBZ)
; ---------------------------------------------------------------------------
Map_obj69:
	include "_maps\obj69.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - spinning platforms (SBZ)
; ---------------------------------------------------------------------------
Map_obj69a:
	include "_maps\obj69a.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 6A - ground saws and pizza cutters (SBZ)
; ---------------------------------------------------------------------------

Obj6A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj6A_Index(pc,d0.w),d1
		jmp	Obj6A_Index(pc,d1.w)
; ===========================================================================
Obj6A_Index:	dc.w Obj6A_Main-Obj6A_Index
		dc.w Obj6A_Action-Obj6A_Index
; ===========================================================================

Obj6A_Main:				; XREF: Obj6A_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj6A,4(a0)
		move.w	#$43B5,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$20,$19(a0)
		move.w	8(a0),$3A(a0)
		move.w	$C(a0),$38(a0)
		cmpi.b	#3,$28(a0)
		bcc.s	Obj6A_Action
		move.b	#$A2,$20(a0)

Obj6A_Action:				; XREF: Obj6A_Index
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Obj6A_TypeIndex(pc,d0.w),d1
		jsr	Obj6A_TypeIndex(pc,d1.w)
		move.w	$3A(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj6A_Delete
		jmp	DisplaySprite
; ===========================================================================

Obj6A_Delete:
		jmp	DeleteObject
; ===========================================================================
Obj6A_TypeIndex:dc.w Obj6A_Type00-Obj6A_TypeIndex, Obj6A_Type01-Obj6A_TypeIndex
		dc.w Obj6A_Type02-Obj6A_TypeIndex, Obj6A_Type03-Obj6A_TypeIndex
		dc.w Obj6A_Type04-Obj6A_TypeIndex
; ===========================================================================

Obj6A_Type00:				; XREF: Obj6A_TypeIndex
		rts
; ===========================================================================

Obj6A_Type01:				; XREF: Obj6A_TypeIndex
		move.w	#$60,d1
		moveq	#0,d0
		move.b	($FFFFFE6C).w,d0
		btst	#0,$22(a0)
		beq.s	Obj6A_Animate01
		neg.w	d0
		add.w	d1,d0

Obj6A_Animate01:
		move.w	$3A(a0),d1
		sub.w	d0,d1
		move.w	d1,8(a0)	; move saw sideways
		subq.b	#1,$1E(a0)
		bpl.s	loc_15A46
		move.b	#2,$1E(a0)	; time between frame changes
		bchg	#0,$1A(a0)	; change frame

loc_15A46:
		tst.b	1(a0)
		bpl.s	locret_15A60
		move.w	($FFFFFE04).w,d0
		andi.w	#$F,d0
		bne.s	locret_15A60
		moveq	#sfx_Saw,d0
		jsr	(PlaySound_Special).l ;	play saw sound

locret_15A60:
		rts
; ===========================================================================

Obj6A_Type02:				; XREF: Obj6A_TypeIndex
		move.w	#$30,d1
		moveq	#0,d0
		move.b	($FFFFFE64).w,d0
		btst	#0,$22(a0)
		beq.s	Obj6A_Animate02
		neg.w	d0
		addi.w	#$80,d0

Obj6A_Animate02:
		move.w	$38(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)	; move saw vertically
		subq.b	#1,$1E(a0)
		bpl.s	loc_15A96
		move.b	#2,$1E(a0)
		bchg	#0,$1A(a0)

loc_15A96:
		tst.b	1(a0)
		bpl.s	locret_15AB0
		move.b	($FFFFFE64).w,d0
		cmpi.b	#$18,d0
		bne.s	locret_15AB0
		moveq	#sfx_Saw,d0
		jsr	(PlaySound_Special).l ;	play saw sound

locret_15AB0:
		rts
; ===========================================================================

Obj6A_Type03:				; XREF: Obj6A_TypeIndex
		tst.b	$3D(a0)
		bne.s	Obj6A_Animate03
		move.w	($FFFFD008).w,d0
		subi.w	#$C0,d0
		bcs.s	loc_15B02
		sub.w	8(a0),d0
		bcs.s	loc_15B02
		move.w	($FFFFD00C).w,d0
		subi.w	#$80,d0
		cmp.w	$C(a0),d0
		bcc.s	locret_15B04
		addi.w	#$100,d0
		cmp.w	$C(a0),d0
		bcs.s	locret_15B04
		move.b	#1,$3D(a0)
		move.w	#$600,$10(a0)	; move object to the right
		move.b	#$A2,$20(a0)
		move.b	#2,$1A(a0)
		moveq	#sfx_Saw,d0
		jsr	(PlaySound_Special).l ;	play saw sound

loc_15B02:
		addq.l	#4,sp

locret_15B04:
		rts
; ===========================================================================

Obj6A_Animate03:			; XREF: ROM:00015AB6j
		jsr	SpeedToPos
		move.w	8(a0),$3A(a0)
		subq.b	#1,$1E(a0)
		bpl.s	locret_15B24
		move.b	#2,$1E(a0)
		bchg	#0,$1A(a0)

locret_15B24:
		rts
; ===========================================================================

Obj6A_Type04:				; XREF: Obj6A_TypeIndex
		tst.b	$3D(a0)
		bne.s	Obj6A_Animate04
		move.w	($FFFFD008).w,d0
		addi.w	#$E0,d0
		sub.w	8(a0),d0
		bcc.s	loc_15B74
		move.w	($FFFFD00C).w,d0
		subi.w	#$80,d0
		cmp.w	$C(a0),d0
		bcc.s	locret_15B76
		addi.w	#$100,d0
		cmp.w	$C(a0),d0
		bcs.s	locret_15B76
		move.b	#1,$3D(a0)
		move.w	#-$600,$10(a0)	; move object to the left
		move.b	#$A2,$20(a0)
		move.b	#2,$1A(a0)
		moveq	#sfx_Saw,d0
		jsr	(PlaySound_Special).l ;	play saw sound

loc_15B74:
		addq.l	#4,sp

locret_15B76:
		rts
; ===========================================================================

Obj6A_Animate04:
		jsr	SpeedToPos
		move.w	8(a0),$3A(a0)
		subq.b	#1,$1E(a0)
		bpl.s	locret_15B96
		move.b	#2,$1E(a0)
		bchg	#0,$1A(a0)

locret_15B96:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - ground saws	and pizza cutters (SBZ)
; ---------------------------------------------------------------------------
Map_obj6A:
	include "_maps\obj6A.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 6B - stomper (SBZ)
; ---------------------------------------------------------------------------

Obj6B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj6B_Index(pc,d0.w),d1
		jmp	Obj6B_Index(pc,d1.w)
; ===========================================================================
Obj6B_Index:	dc.w Obj6B_Main-Obj6B_Index
		dc.w Obj6B_Action-Obj6B_Index

Obj6B_Var:	dc.b  $40,  $C,	$80,   1 ; width, height, ????,	type number
		dc.b  $1C, $20,	$38,   3
		dc.b  $1C, $20,	$40,   4
		dc.b  $1C, $20,	$60,   4
		dc.b  $80, $40,	  0,   5
; ===========================================================================

Obj6B_Main:				; XREF: Obj6B_Index
		addq.b	#2,$24(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		lsr.w	#2,d0
		andi.w	#$1C,d0
		lea	Obj6B_Var(pc,d0.w),a3
		move.b	(a3)+,$19(a0)
		move.b	(a3)+,$16(a0)
		lsr.w	#2,d0
		move.b	d0,$1A(a0)
		move.l	#Map_obj6B,4(a0)
		move.w	#$22C0,2(a0)
		cmpi.b	#1,($FFFFFE10).w ; check if level is LZ/SBZ3
		bne.s	Obj6B_SBZ12	; if not, branch
		bset	#0,($FFFFF7CB).w
		beq.s	Obj6B_SBZ3

Obj6B_ChkGone:				; XREF: Obj6B_SBZ3
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Obj6B_Delete
		bclr	#7,2(a2,d0.w)

Obj6B_Delete:
		jmp	DeleteObject
; ===========================================================================

Obj6B_SBZ3:				; XREF: Obj6B_Main
		move.w	#$41F0,2(a0)
		cmpi.w	#$A80,8(a0)
		bne.s	Obj6B_SBZ12
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Obj6B_SBZ12
		btst	#0,2(a2,d0.w)
		beq.s	Obj6B_SBZ12
		clr.b	($FFFFF7CB).w
		bra.s	Obj6B_ChkGone
; ===========================================================================

Obj6B_SBZ12:				; XREF: Obj6B_Main
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.w	8(a0),$34(a0)
		move.w	$C(a0),$30(a0)
		moveq	#0,d0
		move.b	(a3)+,d0
		move.w	d0,$3C(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		bpl.s	Obj6B_Action
		andi.b	#$F,d0
		move.b	d0,$3E(a0)
		move.b	(a3),$28(a0)
		cmpi.b	#5,(a3)
		bne.s	Obj6B_ChkGone2
		bset	#4,1(a0)

Obj6B_ChkGone2:
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Obj6B_Action
		bclr	#7,2(a2,d0.w)

Obj6B_Action:				; XREF: Obj6B_Index
		move.w	8(a0),-(sp)
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	Obj6B_TypeIndex(pc,d0.w),d1
		jsr	Obj6B_TypeIndex(pc,d1.w)
		move.w	(sp)+,d4
		tst.b	1(a0)
		bpl.s	Obj6B_ChkDel
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	$16(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		bsr.w	SolidObject

Obj6B_ChkDel:
		move.w	$34(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	loc_15D64
		jmp	DisplaySprite
; ===========================================================================

loc_15D64:
		cmpi.b	#1,($FFFFFE10).w
		bne.s	Obj6B_Delete2
		clr.b	($FFFFF7CB).w
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Obj6B_Delete2
		bclr	#7,2(a2,d0.w)

Obj6B_Delete2:
		jmp	DeleteObject
; ===========================================================================
Obj6B_TypeIndex:dc.w Obj6B_Type00-Obj6B_TypeIndex, Obj6B_Type01-Obj6B_TypeIndex
		dc.w Obj6B_Type02-Obj6B_TypeIndex, Obj6B_Type03-Obj6B_TypeIndex
		dc.w Obj6B_Type04-Obj6B_TypeIndex, Obj6B_Type05-Obj6B_TypeIndex
; ===========================================================================

Obj6B_Type00:				; XREF: Obj6B_TypeIndex
		rts
; ===========================================================================

Obj6B_Type01:				; XREF: Obj6B_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_15DB4
		lea	($FFFFF7E0).w,a2
		moveq	#0,d0
		move.b	$3E(a0),d0
		btst	#0,(a2,d0.w)
		beq.s	loc_15DC2
		move.b	#1,$38(a0)

loc_15DB4:
		move.w	$3C(a0),d0
		cmp.w	$3A(a0),d0
		beq.s	loc_15DE0
		addq.w	#2,$3A(a0)

loc_15DC2:
		move.w	$3A(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_15DD4
		neg.w	d0
		addi.w	#$80,d0

loc_15DD4:
		move.w	$34(a0),d1
		sub.w	d0,d1
		move.w	d1,8(a0)
		rts
; ===========================================================================

loc_15DE0:
		addq.b	#1,$28(a0)
		move.w	#$B4,$36(a0)
		clr.b	$38(a0)
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_15DC2
		bset	#0,2(a2,d0.w)
		bra.s	loc_15DC2
; ===========================================================================

Obj6B_Type02:				; XREF: Obj6B_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_15E14
		subq.w	#1,$36(a0)
		bne.s	loc_15E1E
		move.b	#1,$38(a0)

loc_15E14:
		tst.w	$3A(a0)
		beq.s	loc_15E3C
		subq.w	#2,$3A(a0)

loc_15E1E:
		move.w	$3A(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_15E30
		neg.w	d0
		addi.w	#$80,d0

loc_15E30:
		move.w	$34(a0),d1
		sub.w	d0,d1
		move.w	d1,8(a0)
		rts
; ===========================================================================

loc_15E3C:
		subq.b	#1,$28(a0)
		clr.b	$38(a0)
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_15E1E
		bclr	#0,2(a2,d0.w)
		bra.s	loc_15E1E
; ===========================================================================

Obj6B_Type03:				; XREF: Obj6B_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_15E7C
		tst.w	$3A(a0)
		beq.s	loc_15E6A
		subq.w	#1,$3A(a0)
		bra.s	loc_15E8E
; ===========================================================================

loc_15E6A:
		subq.w	#1,$36(a0)
		bpl.s	loc_15E8E
		move.w	#$3C,$36(a0)
		move.b	#1,$38(a0)

loc_15E7C:
		addq.w	#8,$3A(a0)
		move.w	$3A(a0),d0
		cmp.w	$3C(a0),d0
		bne.s	loc_15E8E
		clr.b	$38(a0)

loc_15E8E:
		move.w	$3A(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_15EA0
		neg.w	d0
		addi.w	#$38,d0

loc_15EA0:
		move.w	$30(a0),d1
		add.w	d0,d1
		move.w	d1,$C(a0)
		rts
; ===========================================================================

Obj6B_Type04:				; XREF: Obj6B_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_15ED0
		tst.w	$3A(a0)
		beq.s	loc_15EBE
		subq.w	#8,$3A(a0)
		bra.s	loc_15EF0
; ===========================================================================

loc_15EBE:
		subq.w	#1,$36(a0)
		bpl.s	loc_15EF0
		move.w	#$3C,$36(a0)
		move.b	#1,$38(a0)

loc_15ED0:
		move.w	$3A(a0),d0
		cmp.w	$3C(a0),d0
		beq.s	loc_15EE0
		addq.w	#8,$3A(a0)
		bra.s	loc_15EF0
; ===========================================================================

loc_15EE0:
		subq.w	#1,$36(a0)
		bpl.s	loc_15EF0
		move.w	#$3C,$36(a0)
		clr.b	$38(a0)

loc_15EF0:
		move.w	$3A(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_15F02
		neg.w	d0
		addi.w	#$38,d0

loc_15F02:
		move.w	$30(a0),d1
		add.w	d0,d1
		move.w	d1,$C(a0)
		rts
; ===========================================================================

Obj6B_Type05:				; XREF: Obj6B_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_15F3E
		lea	($FFFFF7E0).w,a2
		moveq	#0,d0
		move.b	$3E(a0),d0
		btst	#0,(a2,d0.w)
		beq.s	locret_15F5C
		move.b	#1,$38(a0)
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_15F3E
		bset	#0,2(a2,d0.w)

loc_15F3E:
		subi.l	#$10000,8(a0)
		addi.l	#$8000,$C(a0)
		move.w	8(a0),$34(a0)
		cmpi.w	#$980,8(a0)
		beq.s	loc_15F5E

locret_15F5C:
		rts
; ===========================================================================

loc_15F5E:
		clr.b	$28(a0)
		clr.b	$38(a0)
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - stomper and	platforms (SBZ)
; ---------------------------------------------------------------------------
Map_obj6B:
	include "_maps\obj6B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 6C - vanishing	platforms (SBZ)
; ---------------------------------------------------------------------------

Obj6C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj6C_Index(pc,d0.w),d1
		jmp	Obj6C_Index(pc,d1.w)
; ===========================================================================
Obj6C_Index:	dc.w Obj6C_Main-Obj6C_Index
		dc.w Obj6C_Vanish-Obj6C_Index
		dc.w Obj6C_Vanish-Obj6C_Index
		dc.w loc_16068-Obj6C_Index
; ===========================================================================

Obj6C_Main:				; XREF: Obj6C_Index
		addq.b	#6,$24(a0)
		move.l	#Map_obj6C,4(a0)
		move.w	#$44C3,2(a0)
		ori.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#4,$18(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; get object type
		andi.w	#$F,d0		; read only the	2nd digit
		addq.w	#1,d0		; add 1
		lsl.w	#7,d0		; multiply by $80
		move.w	d0,d1
		subq.w	#1,d0
		move.w	d0,$30(a0)
		move.w	d0,$32(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; get object type
		andi.w	#$F0,d0		; read only the	1st digit
		addi.w	#$80,d1
		mulu.w	d1,d0
		lsr.l	#8,d0
		move.w	d0,$36(a0)
		subq.w	#1,d1
		move.w	d1,$38(a0)

loc_16068:				; XREF: Obj6C_Index
		move.w	($FFFFFE04).w,d0
		sub.w	$36(a0),d0
		and.w	$38(a0),d0
		bne.s	Obj6C_Animate
		subq.b	#4,$24(a0)
		bra.s	Obj6C_Vanish
; ===========================================================================

Obj6C_Animate:
		lea	(Ani_obj6C).l,a1
		jsr	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================

Obj6C_Vanish:				; XREF: Obj6C_Index
		subq.w	#1,$30(a0)
		bpl.s	loc_160AA
		move.w	#127,$30(a0)
		tst.b	$1C(a0)
		beq.s	loc_160A4
		move.w	$32(a0),$30(a0)

loc_160A4:
		bchg	#0,$1C(a0)

loc_160AA:
		lea	(Ani_obj6C).l,a1
		jsr	AnimateSprite
		btst	#1,$1A(a0)	; has platform vanished?
		bne.s	Obj6C_NotSolid	; if yes, branch
		cmpi.b	#2,$24(a0)
		bne.s	loc_160D6
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(PlatformObject).l
		bra.w	MarkObjGone
; ===========================================================================

loc_160D6:
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(ExitPlatform).l
		move.w	8(a0),d2
		jsr	(MvSonicOnPtfm2).l
		bra.w	MarkObjGone
; ===========================================================================

Obj6C_NotSolid:				; XREF: Obj6C_Vanish
		btst	#3,$22(a0)
		beq.s	Obj6C_Display
		lea	($FFFFD000).w,a1
		bclr	#3,$22(a1)
		bclr	#3,$22(a0)
		move.b	#2,$24(a0)
		clr.b	$25(a0)

Obj6C_Display:
		bra.w	MarkObjGone
; ===========================================================================
Ani_obj6C:
	include "_anim\obj6C.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - vanishing platforms	(SBZ)
; ---------------------------------------------------------------------------
Map_obj6C:
	include "_maps\obj6C.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 6E - electrocution orbs (SBZ)
; ---------------------------------------------------------------------------

Obj6E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj6E_Index(pc,d0.w),d1
		jmp	Obj6E_Index(pc,d1.w)
; ===========================================================================
Obj6E_Index:	dc.w Obj6E_Main-Obj6E_Index
		dc.w Obj6E_Shock-Obj6E_Index
; ===========================================================================

Obj6E_Main:				; XREF: Obj6E_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj6E,4(a0)
		move.w	#$47E,2(a0)
		ori.b	#4,1(a0)
		move.b	#$28,$19(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; read object type
		lsl.w	#4,d0		; multiply by $10
		subq.w	#1,d0
		move.w	d0,$34(a0)

Obj6E_Shock:				; XREF: Obj6E_Index
		move.w	($FFFFFE04).w,d0
		and.w	$34(a0),d0
		bne.s	Obj6E_Animate
		move.b	#1,$1C(a0)	; run "shocking" animation
		tst.b	1(a0)
		bpl.s	Obj6E_Animate
		moveq	#sfx_Electricity,d0
		jsr	(PlaySound_Special).l ;	play electricity sound

Obj6E_Animate:
		lea	(Ani_obj6E).l,a1
		jsr	AnimateSprite
		move.b	#0,$20(a0)
		cmpi.b	#4,$1A(a0)	; is frame number 4 displayed?
		bne.s	Obj6E_Display	; if not, branch
		move.b	#$A4,$20(a0)	; if yes, make object hurt Sonic

Obj6E_Display:
		bra.w	MarkObjGone
; ===========================================================================
Ani_obj6E:
	include "_anim\obj6E.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - electrocution orbs (SBZ)
; ---------------------------------------------------------------------------
Map_obj6E:
	include "_maps\obj6E.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 6F - spinning platforms that move around a conveyor belt (SBZ)
; ---------------------------------------------------------------------------

Obj6F:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj6F_Index(pc,d0.w),d1
		jsr	Obj6F_Index(pc,d1.w)
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	loc_1629A

Obj6F_Display:
		jmp	DisplaySprite
; ===========================================================================

loc_1629A:
		cmpi.b	#2,($FFFFFE11).w ; check if act	is 3
		bne.s	Obj6F_Act1or2	; if not, branch
		cmpi.w	#-$80,d0
		bcc.s	Obj6F_Display

Obj6F_Act1or2:
		move.b	$2F(a0),d0
		bpl.s	Obj6F_Delete
		andi.w	#$7F,d0
		lea	($FFFFF7C1).w,a2
		bclr	#0,(a2,d0.w)

Obj6F_Delete:
		jmp	DeleteObject
; ===========================================================================
Obj6F_Index:	dc.w Obj6F_Main-Obj6F_Index
		dc.w loc_163D8-Obj6F_Index
; ===========================================================================

Obj6F_Main:				; XREF: Obj6F_Index
		move.b	$28(a0),d0
		bmi.w	loc_16380
		addq.b	#2,$24(a0)
		move.l	#Map_obj69a,4(a0)
		move.w	#$4DF,2(a0)
		move.b	#$10,$19(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		move.w	d0,d1
		lsr.w	#3,d0
		andi.w	#$1E,d0
		lea	off_164A6(pc),a2
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,$38(a0)
		move.w	(a2)+,$30(a0)
		move.l	a2,$3C(a0)
		andi.w	#$F,d1
		lsl.w	#2,d1
		move.b	d1,$38(a0)
		move.b	#4,$3A(a0)
		tst.b	($FFFFF7C0).w
		beq.s	loc_16356
		move.b	#1,$3B(a0)
		neg.b	$3A(a0)
		moveq	#0,d1
		move.b	$38(a0),d1
		add.b	$3A(a0),d1
		cmp.b	$39(a0),d1
		bcs.s	loc_16352
		move.b	d1,d0
		moveq	#0,d1
		tst.b	d0
		bpl.s	loc_16352
		move.b	$39(a0),d1
		subq.b	#4,d1

loc_16352:
		move.b	d1,$38(a0)

loc_16356:
		move.w	(a2,d1.w),$34(a0)
		move.w	2(a2,d1.w),$36(a0)
		tst.w	d1
		bne.s	loc_1636C
		move.b	#1,$1C(a0)

loc_1636C:
		cmpi.w	#8,d1
		bne.s	loc_16378
		move.b	#0,$1C(a0)

loc_16378:
		bsr.w	Obj63_ChangeDir
		bra.w	loc_163D8
; ===========================================================================

loc_16380:				; XREF: Obj6F_Main
		move.b	d0,$2F(a0)
		andi.w	#$7F,d0
		lea	($FFFFF7C1).w,a2
		bset	#0,(a2,d0.w)
		beq.s	loc_1639A
		jmp	DeleteObject
; ===========================================================================

loc_1639A:
		add.w	d0,d0
		andi.w	#$1E,d0
		addi.w	#$80,d0
		lea	(ObjPos_Index).l,a2
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d1
		movea.l	a0,a1
		bra.s	Obj6F_LoadPform
; ===========================================================================

Obj6F_Loop:
		jsr	SingleObjLoad
		bne.s	loc_163D0

Obj6F_LoadPform:			; XREF: loc_1639A
		move.b	#$6F,0(a1)
		move.w	(a2)+,8(a1)
		move.w	(a2)+,$C(a1)
		move.w	(a2)+,d0
		move.b	d0,$28(a1)

loc_163D0:
		dbf	d1,Obj6F_Loop

		addq.l	#4,sp
		rts
; ===========================================================================

loc_163D8:				; XREF: Obj6F_Index
		lea	(Ani_obj6F).l,a1
		jsr	AnimateSprite
		tst.b	$1A(a0)
		bne.s	loc_16404
		move.w	8(a0),-(sp)
		bsr.w	loc_16424
		move.w	#$1B,d1
		move.w	#7,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	(sp)+,d4
		bra.w	SolidObject
; ===========================================================================

loc_16404:
		btst	#3,$22(a0)
		beq.s	loc_16420
		lea	($FFFFD000).w,a1
		bclr	#3,$22(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)

loc_16420:
		bra.w	*+4

loc_16424:
		move.w	8(a0),d0
		cmp.w	$34(a0),d0
		bne.s	loc_16484
		move.w	$C(a0),d0
		cmp.w	$36(a0),d0
		bne.s	loc_16484
		moveq	#0,d1
		move.b	$38(a0),d1
		add.b	$3A(a0),d1
		cmp.b	$39(a0),d1
		bcs.s	loc_16456
		move.b	d1,d0
		moveq	#0,d1
		tst.b	d0
		bpl.s	loc_16456
		move.b	$39(a0),d1
		subq.b	#4,d1

loc_16456:
		move.b	d1,$38(a0)
		movea.l	$3C(a0),a1
		move.w	(a1,d1.w),$34(a0)
		move.w	2(a1,d1.w),$36(a0)
		tst.w	d1
		bne.s	loc_16474
		move.b	#1,$1C(a0)

loc_16474:
		cmpi.w	#8,d1
		bne.s	loc_16480
		move.b	#0,$1C(a0)

loc_16480:
		bsr.w	Obj63_ChangeDir

loc_16484:
		jmp	SpeedToPos
; ===========================================================================
Ani_obj6F:
	include "_anim\obj6F.asm"

off_164A6:	dc.w word_164B2-off_164A6, word_164C6-off_164A6, word_164DA-off_164A6
		dc.w word_164EE-off_164A6, word_16502-off_164A6, word_16516-off_164A6
word_164B2:	dc.w $10, $E80,	$E14, $370, $EEF, $302,	$EEF, $340, $E14, $3AE
word_164C6:	dc.w $10, $F80,	$F14, $2E0, $FEF, $272,	$FEF, $2B0, $F14, $31E
word_164DA:	dc.w $10, $1080, $1014,	$270, $10EF, $202, $10EF, $240,	$1014, $2AE
word_164EE:	dc.w $10, $F80,	$F14, $570, $FEF, $502,	$FEF, $540, $F14, $5AE
word_16502:	dc.w $10, $1B80, $1B14,	$670, $1BEF, $602, $1BEF, $640,	$1B14, $6AE
word_16516:	dc.w $10, $1C80, $1C14,	$5E0, $1CEF, $572, $1CEF, $5B0,	$1C14, $61E
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 70 - large girder block (SBZ)
; ---------------------------------------------------------------------------

Obj70:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj70_Index(pc,d0.w),d1
		jmp	Obj70_Index(pc,d1.w)
; ===========================================================================
Obj70_Index:	dc.w Obj70_Main-Obj70_Index
		dc.w Obj70_Action-Obj70_Index
; ===========================================================================

Obj70_Main:				; XREF: Obj70_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj70,4(a0)
		move.w	#$42F0,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$60,$19(a0)
		move.b	#$18,$16(a0)
		move.w	8(a0),$32(a0)
		move.w	$C(a0),$30(a0)
		bsr.w	Obj70_Move2

Obj70_Action:				; XREF: Obj70_Index
		move.w	8(a0),-(sp)
		tst.w	$3A(a0)
		beq.s	Obj70_Move
		subq.w	#1,$3A(a0)
		bne.s	Obj70_Solid

Obj70_Move:
		jsr	SpeedToPos
		subq.w	#1,$34(a0)	; subtract 1 from movement duration
		bne.s	Obj70_Solid	; if time remains, branch
		bsr.w	Obj70_Move2	; if time is zero, branch

Obj70_Solid:
		move.w	(sp)+,d4
		tst.b	1(a0)
		bpl.s	Obj70_ChkDel
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	$16(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		bsr.w	SolidObject

Obj70_ChkDel:
		move.w	$32(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj70_Delete
		jmp	DisplaySprite
; ===========================================================================

Obj70_Delete:
		jmp	DeleteObject
; ===========================================================================

Obj70_Move2:				; XREF: Obj70_Main
		move.b	$38(a0),d0
		andi.w	#$18,d0
		lea	(Obj70_MoveData).l,a1
		lea	(a1,d0.w),a1
		move.w	(a1)+,$10(a0)
		move.w	(a1)+,$12(a0)
		move.w	(a1)+,$34(a0)
		addq.b	#8,$38(a0)	; use next movedata set
		move.w	#7,$3A(a0)
		rts
; ===========================================================================
Obj70_MoveData:	dc.w   $100,	 0,   $60,     0 ; x-speed, y-speed, duration, blank
		dc.w	  0,  $100,   $30,     0
		dc.w  $FF00, $FFC0,   $60,     0
		dc.w	  0, $FF00,   $18,     0
; ---------------------------------------------------------------------------
; Sprite mappings - large girder block (SBZ)
; ---------------------------------------------------------------------------
Map_obj70:
	include "_maps\obj70.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 72 - teleporter (SBZ)
; ---------------------------------------------------------------------------

Obj72:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj72_Index(pc,d0.w),d1
		jsr	Obj72_Index(pc,d1.w)
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj72_Delete
		rts
; ===========================================================================

Obj72_Delete:
		jmp	DeleteObject
; ===========================================================================
Obj72_Index:	dc.w Obj72_Main-Obj72_Index
		dc.w loc_166C8-Obj72_Index
		dc.w loc_1675E-Obj72_Index
		dc.w loc_16798-Obj72_Index
; ===========================================================================

Obj72_Main:				; XREF: Obj72_Index
		addq.b	#2,$24(a0)
		move.b	$28(a0),d0
		add.w	d0,d0
		andi.w	#$1E,d0
		lea	Obj72_Data(pc),a2
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,$3A(a0)
		move.l	a2,$3C(a0)
		move.w	(a2)+,$36(a0)
		move.w	(a2)+,$38(a0)

loc_166C8:				; XREF: Obj72_Index
		lea	($FFFFD000).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_166E0
		addi.w	#$F,d0

loc_166E0:
		cmpi.w	#$10,d0
		bcc.s	locret_1675C
		move.w	$C(a1),d1
		sub.w	$C(a0),d1
		addi.w	#$20,d1
		cmpi.w	#$40,d1
		bcc.s	locret_1675C
		tst.b	($FFFFF7C8).w
		bne.s	locret_1675C
		cmpi.b	#7,$28(a0)
		bne.s	loc_1670E
		cmpi.w	#50,($FFFFFE20).w
		bcs.s	locret_1675C

loc_1670E:
		addq.b	#2,$24(a0)
		move.b	#$81,($FFFFF7C8).w ; lock controls
		move.b	#2,$1C(a1)	; use Sonic's rolling animation
		move.w	#$800,$14(a1)
		move.w	#0,$10(a1)
		move.w	#0,$12(a1)
		bclr	#5,$22(a0)
		bclr	#5,$22(a1)
		bset	#1,$22(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		clr.b	$32(a0)
		moveq	#sfx_Roll,d0
		jmp	PlaySound_Special;	play Sonic rolling sound

locret_1675C:
locret_16796:
		rts
; ===========================================================================

loc_1675E:				; XREF: Obj72_Index
		lea	($FFFFD000).w,a1
		move.b	$32(a0),d0
		addq.b	#2,$32(a0)
		jsr	(CalcSine).l
		asr.w	#5,d0
		move.w	$C(a0),d2
		sub.w	d0,d2
		move.w	d2,$C(a1)
		cmpi.b	#$80,$32(a0)
		bne.s	locret_16796
		bsr.w	sub_1681C
		addq.b	#2,$24(a0)
		moveq	#sfx_Dash,d0
		jmp	PlaySound_Special ;	play teleport sound
; ===========================================================================

loc_16798:				; XREF: Obj72_Index
		addq.l	#4,sp
		lea	($FFFFD000).w,a1
		subq.b	#1,$2E(a0)
		bpl.s	loc_167DA
		move.w	$36(a0),8(a1)
		move.w	$38(a0),$C(a1)
		moveq	#0,d1
		move.b	$3A(a0),d1
		addq.b	#4,d1
		cmp.b	$3B(a0),d1
		bcs.s	loc_167C2
		moveq	#0,d1
		bra.s	loc_16800
; ===========================================================================

loc_167C2:
		move.b	d1,$3A(a0)
		movea.l	$3C(a0),a2
		move.w	(a2,d1.w),$36(a0)
		move.w	2(a2,d1.w),$38(a0)
		bra.w	sub_1681C
; ===========================================================================

loc_167DA:
		move.l	8(a1),d2
		move.l	$C(a1),d3
		move.w	$10(a1),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	$12(a1),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,8(a1)
		move.l	d3,$C(a1)
		rts
; ===========================================================================

loc_16800:
		andi.w	#$7FF,$C(a1)
		clr.b	$24(a0)
		clr.b	($FFFFF7C8).w
		move.w	#0,$10(a1)
		move.w	#$200,$12(a1)
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_1681C:
		moveq	#0,d0
		move.w	#$1000,d2
		move.w	$36(a0),d0
		sub.w	8(a1),d0
		bge.s	loc_16830
		neg.w	d0
		neg.w	d2

loc_16830:
		moveq	#0,d1
		move.w	#$1000,d3
		move.w	$38(a0),d1
		sub.w	$C(a1),d1
		bge.s	loc_16844
		neg.w	d1
		neg.w	d3

loc_16844:
		cmp.w	d0,d1
		bcs.s	loc_1687A
		moveq	#0,d1
		move.w	$38(a0),d1
		sub.w	$C(a1),d1
		swap	d1
		divs.w	d3,d1
		moveq	#0,d0
		move.w	$36(a0),d0
		sub.w	8(a1),d0
		beq.s	loc_16866
		swap	d0
		divs.w	d1,d0

loc_16866:
		move.w	d0,$10(a1)
		move.w	d3,$12(a1)
		tst.w	d1
		bpl.s	loc_16874
		neg.w	d1

loc_16874:
		move.w	d1,$2E(a0)
		rts
; ===========================================================================

loc_1687A:
		moveq	#0,d0
		move.w	$36(a0),d0
		sub.w	8(a1),d0
		swap	d0
		divs.w	d2,d0
		moveq	#0,d1
		move.w	$38(a0),d1
		sub.w	$C(a1),d1
		beq.s	loc_16898
		swap	d1
		divs.w	d0,d1

loc_16898:
		move.w	d1,$12(a1)
		move.w	d2,$10(a1)
		tst.w	d0
		bpl.s	loc_168A6
		neg.w	d0

loc_168A6:
		move.w	d0,$2E(a0)
		rts
; End of function sub_1681C

; ===========================================================================
Obj72_Data:	dc.w word_168BC-Obj72_Data, word_168C2-Obj72_Data, word_168C8-Obj72_Data
		dc.w word_168E6-Obj72_Data, word_168EC-Obj72_Data, word_1690A-Obj72_Data
		dc.w word_16910-Obj72_Data, word_1692E-Obj72_Data
word_168BC:	dc.w 4,	$794, $98C
word_168C2:	dc.w 4,	$94, $38C
word_168C8:	dc.w $1C, $794,	$2E8
		dc.w $7A4, $2C0, $7D0
		dc.w $2AC, $858, $2AC
		dc.w $884, $298, $894
		dc.w $270, $894, $190
word_168E6:	dc.w 4,	$894, $690
word_168EC:	dc.w $1C, $1194, $470
		dc.w $1184, $498, $1158
		dc.w $4AC, $FD0, $4AC
		dc.w $FA4, $4C0, $F94
		dc.w $4E8, $F94, $590
word_1690A:	dc.w 4,	$1294, $490
word_16910:	dc.w $1C, $1594, $FFE8
		dc.w $1584, $FFC0, $1560
		dc.w $FFAC, $14D0, $FFAC
		dc.w $14A4, $FF98, $1494
		dc.w $FF70, $1494, $FD90
word_1692E:	dc.w 4,	$894, $90
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 78 - Caterkiller enemy	(MZ, SBZ)
; ---------------------------------------------------------------------------

Obj78:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj78_Index(pc,d0.w),d1
		jmp	Obj78_Index(pc,d1.w)
; ===========================================================================
Obj78_Index:	dc.w Obj78_Main-Obj78_Index
		dc.w Obj78_Action-Obj78_Index
		dc.w Obj78_BodySeg1-Obj78_Index
		dc.w Obj78_BodySeg2-Obj78_Index
		dc.w Obj78_BodySeg1-Obj78_Index
		dc.w Obj78_Delete-Obj78_Index
		dc.w loc_16CC0-Obj78_Index
; ===========================================================================

locret_16950:
		rts
; ===========================================================================

Obj78_Main:				; XREF: Obj78_Index
		move.b	#7,$16(a0)
		move.b	#8,$17(a0)
		jsr	ObjectFall
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	locret_16950
		add.w	d1,$C(a0)
		clr.w	$12(a0)
		addq.b	#2,$24(a0)
		move.l	#Map_obj78,4(a0)
		move.w	#$22B0,2(a0)
		cmpi.b	#5,($FFFFFE10).w ; if level is SBZ, branch
		beq.s	loc_16996
		move.w	#$24FF,2(a0)	; MZ specific code

loc_16996:
		andi.b	#3,1(a0)
		ori.b	#4,1(a0)
		move.b	1(a0),$22(a0)
		move.b	#4,$18(a0)
		move.b	#8,$19(a0)
		move.b	#$B,$20(a0)
		move.w	8(a0),d2
		moveq	#$C,d5
		btst	#0,$22(a0)
		beq.s	loc_169CA
		neg.w	d5

loc_169CA:
		move.b	#4,d6
		moveq	#0,d3
		moveq	#4,d4
		movea.l	a0,a2
		moveq	#2,d1

Obj78_LoadBody:
		jsr	SingleObjLoad2
		bne.s	Obj78_QuitLoad
		move.b	#$78,0(a1)	; load body segment object
		move.b	d6,$24(a1)
		addq.b	#2,d6
		move.l	4(a0),4(a1)
		move.w	2(a0),2(a1)
		move.b	#5,$18(a1)
		move.b	#8,$19(a1)
		move.b	#$CB,$20(a1)
		add.w	d5,d2
		move.w	d2,8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$22(a0),$22(a1)
		move.b	$22(a0),1(a1)
		move.b	#8,$1A(a1)
		move.l	a2,$3C(a1)
		move.b	d4,$3C(a1)
		addq.b	#4,d4
		movea.l	a1,a2

Obj78_QuitLoad:
		dbf	d1,Obj78_LoadBody ; repeat sequence 2 more times

		move.b	#7,$2A(a0)
		clr.b	$3C(a0)

Obj78_Action:				; XREF: Obj78_Index
		tst.b	$22(a0)
		bmi.w	loc_16C96
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj78_Index2(pc,d0.w),d1
		jsr	Obj78_Index2(pc,d1.w)
		move.b	$2B(a0),d1
		bpl.s	Obj78_Display
		lea	(Ani_obj78).l,a1
		move.b	$26(a0),d0
		andi.w	#$7F,d0
		addq.b	#4,$26(a0)
		move.b	(a1,d0.w),d0
		bpl.s	Obj78_AniHead
		bclr	#7,$2B(a0)
		bra.s	Obj78_Display
; ===========================================================================

Obj78_AniHead:
		andi.b	#$10,d1
		add.b	d1,d0
		move.b	d0,$1A(a0)

Obj78_Display:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj78_ChkGone
		jmp	DisplaySprite
; ===========================================================================

Obj78_ChkGone:
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_16ABC
		bclr	#7,2(a2,d0.w)

loc_16ABC:
		move.b	#$A,$24(a0)	; run "Obj78_Delete" routine
		rts
; ===========================================================================

Obj78_Delete:				; XREF: Obj78_Index
		jmp	DeleteObject
; ===========================================================================
Obj78_Index2:	dc.w Obj78_Move-Obj78_Index2
		dc.w loc_16B02-Obj78_Index2
; ===========================================================================

Obj78_Move:				; XREF: Obj78_Index2
		subq.b	#1,$2A(a0)
		bmi.s	Obj78_Move2
		rts
; ===========================================================================

Obj78_Move2:
		addq.b	#2,$25(a0)
		move.b	#$10,$2A(a0)
		move.w	#-$C0,$10(a0)
		move.w	#$40,$14(a0)
		bchg	#4,$2B(a0)
		bne.s	loc_16AFC
		clr.w	$10(a0)
		neg.w	$14(a0)

loc_16AFC:
		bset	#7,$2B(a0)

loc_16B02:				; XREF: Obj78_Index2
		subq.b	#1,$2A(a0)
		bmi.s	loc_16B5E
		move.l	8(a0),-(sp)
		move.l	8(a0),d2
		move.w	$10(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_16B1E
		neg.w	d0

loc_16B1E:
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.l	d2,8(a0)
		jsr	ObjHitFloor
		move.l	(sp)+,d2
		cmpi.w	#-8,d1
		blt.s	loc_16B70
		cmpi.w	#$C,d1
		bge.s	loc_16B70
		add.w	d1,$C(a0)
		swap	d2
		cmp.w	8(a0),d2
		beq.s	locret_16B5C
		moveq	#0,d0
		move.b	$3C(a0),d0
		addq.b	#1,$3C(a0)
		andi.b	#$F,$3C(a0)
		move.b	d1,$2C(a0,d0.w)

locret_16B5C:
		rts
; ===========================================================================

loc_16B5E:
		subq.b	#2,$25(a0)
		move.b	#7,$2A(a0)
		move.w	#0,$10(a0)
		rts
; ===========================================================================

loc_16B70:
		move.l	d2,8(a0)
		bchg	#0,$22(a0)
		move.b	$22(a0),1(a0)
		moveq	#0,d0
		move.b	$3C(a0),d0
		move.b	#$80,$2C(a0,d0.w)
		addq.b	#1,$3C(a0)
		andi.b	#$F,$3C(a0)
		rts
; ===========================================================================

Obj78_BodySeg2:				; XREF: Obj78_Index
		movea.l	$3C(a0),a1
		move.b	$2B(a1),$2B(a0)
		bpl.s	Obj78_BodySeg1
		lea	(Ani_obj78).l,a1
		move.b	$26(a0),d0
		andi.w	#$7F,d0
		addq.b	#4,$26(a0)
		tst.b	4(a1,d0.w)
		bpl.s	Obj78_AniBody
		addq.b	#4,$26(a0)

Obj78_AniBody:
		move.b	(a1,d0.w),d0
		addq.b	#8,d0
		move.b	d0,$1A(a0)

Obj78_BodySeg1:				; XREF: Obj78_Index
		movea.l	$3C(a0),a1
		tst.b	$22(a0)
		bmi.w	loc_16C90
		move.b	$2B(a1),$2B(a0)
		move.b	$25(a1),$25(a0)
		beq.w	loc_16C64
		move.w	$14(a1),$14(a0)
		move.w	$10(a1),d0
		add.w	$14(a1),d0
		move.w	d0,$10(a0)
		move.l	8(a0),d2
		move.l	d2,d3
		move.w	$10(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_16C0C
		neg.w	d0

loc_16C0C:
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.l	d2,8(a0)
		swap	d3
		cmp.w	8(a0),d3
		beq.s	loc_16C64
		moveq	#0,d0
		move.b	$3C(a0),d0
		move.b	$2C(a1,d0.w),d1
		cmpi.b	#-$80,d1
		bne.s	loc_16C50
		swap	d3
		move.l	d3,8(a0)
		move.b	d1,$2C(a0,d0.w)
		bchg	#0,$22(a0)
		move.b	$22(a0),1(a0)
		addq.b	#1,$3C(a0)
		andi.b	#$F,$3C(a0)
		bra.s	loc_16C64
; ===========================================================================

loc_16C50:
		ext.w	d1
		add.w	d1,$C(a0)
		addq.b	#1,$3C(a0)
		andi.b	#$F,$3C(a0)
		move.b	d1,$2C(a0,d0.w)

loc_16C64:
		cmpi.b	#$C,$24(a1)
		beq.s	loc_16C90
		cmpi.b	#$27,0(a1)
		beq.s	loc_16C7C
		cmpi.b	#$A,$24(a1)
		bne.s	loc_16C82

loc_16C7C:
		move.b	#$A,$24(a0)

loc_16C82:
		jmp	DisplaySprite

; ===========================================================================
Obj78_FragSpeed:dc.w $FE00, $FE80, $180, $200
; ===========================================================================

loc_16C90:
		bset	#7,$22(a1)

loc_16C96:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj78_FragSpeed-2(pc,d0.w),d0
		btst	#0,$22(a0)
		beq.s	loc_16CAA
		neg.w	d0

loc_16CAA:
		move.w	d0,$10(a0)
		move.w	#-$400,$12(a0)
		move.b	#$C,$24(a0)
		andi.b	#-8,$1A(a0)

loc_16CC0:				; XREF: Obj78_Index
		jsr	ObjectFall
		tst.w	$12(a0)
		bmi.s	loc_16CE0
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_16CE0
		add.w	d1,$C(a0)
		move.w	#-$400,$12(a0)

loc_16CE0:
		tst.b	1(a0)
		bpl.w	Obj78_ChkGone
		jmp	DisplaySprite
; ===========================================================================
Ani_obj78:
	include "_anim\obj78.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Caterkiller	enemy (MZ, SBZ)
; ---------------------------------------------------------------------------
Map_obj78:
	include "_maps\obj78.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 79 - lamppost
; ---------------------------------------------------------------------------

Obj79:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj79_Index(pc,d0.w),d1
		jsr	Obj79_Index(pc,d1.w)
		jmp	MarkObjGone
; ===========================================================================
Obj79_Index:	dc.w Obj79_Main-Obj79_Index
		dc.w Obj79_BlueLamp-Obj79_Index
		dc.w Obj79_AfterHit-Obj79_Index
		dc.w Obj79_Twirl-Obj79_Index
; ===========================================================================

Obj79_Main:				; XREF: Obj79_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj79,4(a0)
		move.w	#$7A0,2(a0)
		move.b	#4,1(a0)
		move.b	#8,$19(a0)
		move.b	#5,$18(a0)
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		bclr	#7,2(a2,d0.w)
		btst	#0,2(a2,d0.w)
		bne.s	Obj79_RedLamp
		move.b	($FFFFFE30).w,d1
		andi.b	#$7F,d1
		move.b	$28(a0),d2	; get lamppost number
		andi.b	#$7F,d2
		cmp.b	d2,d1		; is lamppost number higher than the number hit?
		bcs.s	Obj79_BlueLamp	; if yes, branch

Obj79_RedLamp:
		bset	#0,2(a2,d0.w)
		move.b	#4,$24(a0)	; run "Obj79_AfterHit" routine
		move.b	#3,$1A(a0)	; use red lamppost frame
		rts
; ===========================================================================

Obj79_BlueLamp:				; XREF: Obj79_Index
		tst.w	($FFFFFE08).w	; is debug mode	being used?
		bne.w	locret_16F90	; if yes, branch
		tst.b	($FFFFF7C8).w
		bmi.w	locret_16F90
		move.b	($FFFFFE30).w,d1
		andi.b	#$7F,d1
		move.b	$28(a0),d2
		andi.b	#$7F,d2
		cmp.b	d2,d1
		bcs.s	Obj79_HitLamp
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		bset	#0,2(a2,d0.w)
		move.b	#4,$24(a0)
		move.b	#3,$1A(a0)
		bra.w	locret_16F90
; ===========================================================================

Obj79_HitLamp:
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		addq.w	#8,d0
		cmpi.w	#$10,d0
		bcc.w	locret_16F90
		move.w	($FFFFD00C).w,d0
		sub.w	$C(a0),d0
		addi.w	#$40,d0
		cmpi.w	#$68,d0
		bcc.s	locret_16F90
		moveq	#sfx_Lamppost,d0
		jsr	(PlaySound_Special).l ;	play lamppost sound
		addq.b	#2,$24(a0)
		jsr	SingleObjLoad
		bne.s	loc_16F76
		move.b	#$79,0(a1)	; load twirling	lamp object
		move.b	#6,$24(a1)	; use "Obj79_Twirl" routine
		move.w	8(a0),$30(a1)
		move.w	$C(a0),$32(a1)
		subi.w	#$18,$32(a1)
		move.l	#Map_obj79,4(a1)
		move.w	#$7A0,2(a1)
		move.b	#4,1(a1)
		move.b	#8,$19(a1)
		move.b	#4,$18(a1)
		move.b	#2,$1A(a1)
		move.w	#$20,$36(a1)

loc_16F76:
		move.b	#1,$1A(a0)	; use "post only" frame, with no lamp
		bsr.w	Obj79_StoreInfo
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		bset	#0,2(a2,d0.w)

locret_16F90:
		rts
; ===========================================================================

Obj79_AfterHit:				; XREF: Obj79_Index
		rts
; ===========================================================================

Obj79_Twirl:				; XREF: Obj79_Index
		subq.w	#1,$36(a0)
		bpl.s	loc_16FA0
		move.b	#4,$24(a0)

loc_16FA0:
		move.b	$26(a0),d0
		subi.b	#$10,$26(a0)
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	#$C00,d1
		swap	d1
		add.w	$30(a0),d1
		move.w	d1,8(a0)
		muls.w	#$C00,d0
		swap	d0
		add.w	$32(a0),d0
		move.w	d0,$C(a0)
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	store information when you hit a lamppost
; ---------------------------------------------------------------------------

Obj79_StoreInfo:			; XREF: Obj79_HitLamp
		move.b	$28(a0),($FFFFFE30).w 		; lamppost number
		move.b	($FFFFFE30).w,($FFFFFE31).w
		move.w	8(a0),($FFFFFE32).w		; x-position
		move.w	$C(a0),($FFFFFE34).w		; y-position
		move.w	($FFFFFE20).w,($FFFFFE36).w 	; rings
		move.b	($FFFFFE1B).w,($FFFFFE54).w 	; lives
		move.l	($FFFFFE22).w,($FFFFFE38).w 	; time
		move.b	($FFFFF742).w,($FFFFFE3C).w 	; routine counter for dynamic level mod
		move.w	($FFFFF72E).w,($FFFFFE3E).w 	; lower y-boundary of level
		move.w	($FFFFF700).w,($FFFFFE40).w 	; screen x-position
		move.w	($FFFFF704).w,($FFFFFE42).w 	; screen y-position
		move.w	($FFFFF708).w,($FFFFFE44).w 	; bg position
		move.w	($FFFFF70C).w,($FFFFFE46).w 	; bg position
		move.w	($FFFFF710).w,($FFFFFE48).w 	; bg position
		move.w	($FFFFF714).w,($FFFFFE4A).w 	; bg position
		move.w	($FFFFF718).w,($FFFFFE4C).w 	; bg position
		move.w	($FFFFF71C).w,($FFFFFE4E).w 	; bg position
		move.w	($FFFFF648).w,($FFFFFE50).w 	; water height
		move.b	($FFFFF64D).w,($FFFFFE52).w 	; rountine counter for water
		move.b	($FFFFF64E).w,($FFFFFE53).w 	; water direction
		rts

; ---------------------------------------------------------------------------
; Subroutine to	load stored info when you start	a level	from a lamppost
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj79_LoadInfo:				; XREF: LevelSizeLoad
		move.b	($FFFFFE31).w,($FFFFFE30).w
		move.w	($FFFFFE32).w,($FFFFD008).w
		move.w	($FFFFFE34).w,($FFFFD00C).w
		move.w	($FFFFFE36).w,($FFFFFE20).w
		move.b	($FFFFFE54).w,($FFFFFE1B).w
		clr.w	($FFFFFE20).w
		clr.b	($FFFFFE1B).w
		move.l	($FFFFFE38).w,($FFFFFE22).w
		move.b	#59,($FFFFFE25).w
		subq.b	#1,($FFFFFE24).w
		move.b	($FFFFFE3C).w,($FFFFF742).w
		move.b	($FFFFFE52).w,($FFFFF64D).w
		move.w	($FFFFFE3E).w,($FFFFF72E).w
		move.w	($FFFFFE3E).w,($FFFFF726).w
		move.w	($FFFFFE40).w,($FFFFF700).w
		move.w	($FFFFFE42).w,($FFFFF704).w
		move.w	($FFFFFE44).w,($FFFFF708).w
		move.w	($FFFFFE46).w,($FFFFF70C).w
		move.w	($FFFFFE48).w,($FFFFF710).w
		move.w	($FFFFFE4A).w,($FFFFF714).w
		move.w	($FFFFFE4C).w,($FFFFF718).w
		move.w	($FFFFFE4E).w,($FFFFF71C).w
		cmpi.b	#1,($FFFFFE10).w
		bne.s	loc_170E4
		move.w	($FFFFFE50).w,($FFFFF648).w
		move.b	($FFFFFE52).w,($FFFFF64D).w
		move.b	($FFFFFE53).w,($FFFFF64E).w

loc_170E4:
		tst.b	($FFFFFE30).w
		bpl.s	locret_170F6
		move.w	($FFFFFE32).w,d0
		subi.w	#$A0,d0
		move.w	d0,($FFFFF728).w

locret_170F6:
		rts
; End of function Obj79_LoadInfo

; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - lamppost
; ---------------------------------------------------------------------------
Map_obj79:
	include "_maps\obj79.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 7D - hidden points at the end of a level
; ---------------------------------------------------------------------------

Obj7D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj7D_Index(pc,d0.w),d1
		jmp	Obj7D_Index(pc,d1.w)
; ===========================================================================
Obj7D_Index:	dc.w Obj7D_Main-Obj7D_Index
		dc.w Obj7D_DelayDel-Obj7D_Index
; ===========================================================================

Obj7D_Main:				; XREF: Obj7D_Index
		moveq	#$10,d2
		move.w	d2,d3
		add.w	d3,d3
		lea	($FFFFD000).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d2,d0
		cmp.w	d3,d0
		bcc.s	Obj7D_ChkDel
		move.w	$C(a1),d1
		sub.w	$C(a0),d1
		add.w	d2,d1
		cmp.w	d3,d1
		bcc.s	Obj7D_ChkDel
		tst.w	($FFFFFE08).w
		bne.s	Obj7D_ChkDel
		tst.b	($FFFFF7CD).w
		bne.s	Obj7D_ChkDel
		addq.b	#2,$24(a0)
		move.l	#Map_obj7D,4(a0)
		move.w	#$84B6,2(a0)
		ori.b	#4,1(a0)
		move.b	#0,$18(a0)
		move.b	#$10,$19(a0)
		move.b	$28(a0),$1A(a0)
		move.w	#119,$30(a0)	; set display time to 2	seconds
		moveq	#sfx_Bonus,d0
		jsr	(PlaySound_Special).l ;	play bonus sound
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	Obj7D_Points(pc,d0.w),d0 ; load	bonus points array
		jsr	AddPoints

Obj7D_ChkDel:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj7D_Delete
		rts
; ===========================================================================

Obj7D_Delete:
		jmp	DeleteObject
; ===========================================================================
Obj7D_Points:	dc.w 0			; Bonus	points array
		dc.w 1000
		dc.w 100
		dc.w 1
; ===========================================================================

Obj7D_DelayDel:				; XREF: Obj7D_Index
		subq.w	#1,$30(a0)	; subtract 1 from display time
		bmi.s	Obj7D_Delete2	; if time is zero, branch
		move.w	8(a0),d0
		andi.w	#-$80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#-$80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj7D_Delete2
		jmp	DisplaySprite
; ===========================================================================

Obj7D_Delete2:
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - hidden points at the end of	a level
; ---------------------------------------------------------------------------
Map_obj7D:
	include "_maps\obj7D.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 8A - "SONIC TEAM PRESENTS" and	credits
; ---------------------------------------------------------------------------

Obj8A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj8A_Index(pc,d0.w),d1
		jmp	Obj8A_Index(pc,d1.w)
; ===========================================================================
Obj8A_Index:	dc.w Obj8A_Main-Obj8A_Index
		dc.w Obj8A_Display-Obj8A_Index
; ===========================================================================

Obj8A_Main:				; XREF: Obj8A_Index
		addq.b	#2,$24(a0)
		move.w	#$120,8(a0)
		move.w	#$F0,$A(a0)
		move.l	#Map_obj8A,4(a0)
		move.w	#$5A0,2(a0)
		move.w	($FFFFFFF4).w,d0 ; load	credits	index number
		move.b	d0,$1A(a0)	; display appropriate sprite
		move.b	#0,1(a0)
		move.b	#0,$18(a0)
		cmpi.b	#4,($FFFFF600).w ; is the scene	number 04 (title screen)?
		bne.s	Obj8A_Display	; if not, branch
		move.w	#$A6,2(a0)
		move.b	#$A,$1A(a0)	; display "SONIC TEAM PRESENTS"
		tst.b	($FFFFFFE3).w	; is hidden credits cheat on?
		beq.s	Obj8A_Display	; if not, branch
		cmpi.b	#$72,($FFFFF604).w ; is	Start+A+C+Down being pressed?
		bne.s	Obj8A_Display	; if not, branch
		move.w	#$EEE,($FFFFFBC0).w ; 3rd pallet, 1st entry = white
		move.w	#$880,($FFFFFBC2).w ; 3rd pallet, 2nd entry = cyan
		jmp	DeleteObject
; ===========================================================================

Obj8A_Display:				; XREF: Obj8A_Index
		jmp	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC TEAM	PRESENTS" and credits
; ---------------------------------------------------------------------------
Map_obj8A:
	include "_maps\obj8A.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3D - Eggman (GHZ)
; ---------------------------------------------------------------------------

Obj3D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj3D_Index(pc,d0.w),d1
		jmp	Obj3D_Index(pc,d1.w)
; ===========================================================================
Obj3D_Index:	dc.w Obj3D_Main-Obj3D_Index
		dc.w Obj3D_ShipMain-Obj3D_Index
		dc.w Obj3D_FaceMain-Obj3D_Index
		dc.w Obj3D_FlameMain-Obj3D_Index

Obj3D_ObjData:	dc.b 2,	0		; routine counter, animation
		dc.b 4,	1
		dc.b 6,	7
; ===========================================================================

Obj3D_Main:				; XREF: Obj3D_Index
		lea	(Obj3D_ObjData).l,a2
		movea.l	a0,a1
		moveq	#2,d1
		bra.s	Obj3D_LoadBoss
; ===========================================================================

Obj3D_Loop:
		jsr	SingleObjLoad2
		bne.s	loc_17772

Obj3D_LoadBoss:				; XREF: Obj3D_Main
		move.b	(a2)+,$24(a1)
		move.b	#$3D,0(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.l	#Map_Eggman,4(a1)
		move.w	#$400,2(a1)
		move.b	#4,1(a1)
		move.b	#$20,$19(a1)
		move.b	#3,$18(a1)
		move.b	(a2)+,$1C(a1)
		move.l	a0,$34(a1)
		dbf	d1,Obj3D_Loop	; repeat sequence 2 more times

loc_17772:
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$F,$20(a0)
		move.b	#8,$21(a0)	; set number of	hits to	8

Obj3D_ShipMain:				; XREF: Obj3D_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj3D_ShipIndex(pc,d0.w),d1
		jsr	Obj3D_ShipIndex(pc,d1.w)
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		move.b	$22(a0),d0
		andi.b	#3,d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================
Obj3D_ShipIndex:dc.w Obj3D_ShipStart-Obj3D_ShipIndex
		dc.w Obj3D_MakeBall-Obj3D_ShipIndex
		dc.w Obj3D_ShipMove-Obj3D_ShipIndex
		dc.w loc_17954-Obj3D_ShipIndex
		dc.w loc_1797A-Obj3D_ShipIndex
		dc.w loc_179AC-Obj3D_ShipIndex
		dc.w loc_179F6-Obj3D_ShipIndex
; ===========================================================================

Obj3D_ShipStart:			; XREF: Obj3D_ShipIndex
		move.w	#$100,$12(a0)	; move ship down
		bsr.w	BossMove
		cmpi.w	#$338,$38(a0)
		bne.s	loc_177E6
		move.w	#0,$12(a0)	; stop ship
		addq.b	#2,$25(a0)	; goto next routine

loc_177E6:
		move.b	$3F(a0),d0
		jsr	(CalcSine).l
		asr.w	#6,d0
		add.w	$38(a0),d0
		move.w	d0,$C(a0)
		move.w	$30(a0),8(a0)
		addq.b	#2,$3F(a0)
		cmpi.b	#8,$25(a0)
		bcc.s	locret_1784A
		tst.b	$22(a0)
		bmi.s	loc_1784C
		tst.b	$20(a0)
		bne.s	locret_1784A
		tst.b	$3E(a0)
		bne.s	Obj3D_ShipFlash
		move.b	#$20,$3E(a0)	; set number of	times for ship to flash
		moveq	#sfx_BossHit,d0
		jsr	(PlaySound_Special).l ;	play boss damage sound

Obj3D_ShipFlash:
		lea	($FFFFFB22).w,a1 ; load	2nd pallet, 2nd	entry
		moveq	#0,d0		; move 0 (black) to d0
		tst.w	(a1)
		bne.s	loc_1783C
		move.w	#$EEE,d0	; move 0EEE (white) to d0

loc_1783C:
		move.w	d0,(a1)		; load colour stored in	d0
		subq.b	#1,$3E(a0)
		bne.s	locret_1784A
		move.b	#$F,$20(a0)

locret_1784A:
		rts
; ===========================================================================

loc_1784C:				; XREF: loc_177E6
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#8,$25(a0)
		move.w	#$B3,$3C(a0)
		rts

; ---------------------------------------------------------------------------
; Defeated boss	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BossDefeated:
		move.b	($FFFFFE0F).w,d0
		andi.b	#7,d0
		bne.s	locret_178A2
		jsr	SingleObjLoad
		bne.s	locret_178A2
		move.b	#$3F,0(a1)	; load explosion object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		jsr	(RandomNumber).l
		move.w	d0,d1
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,8(a1)
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,$C(a1)

locret_178A2:
		rts
; End of function BossDefeated

; ---------------------------------------------------------------------------
; Subroutine to	move a boss
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BossMove:
		move.l	$30(a0),d2
		move.l	$38(a0),d3
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	$12(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,$30(a0)
		move.l	d3,$38(a0)
		rts
; End of function BossMove

; ===========================================================================

Obj3D_MakeBall:				; XREF: Obj3D_ShipIndex
		move.w	#-$100,$10(a0)
		move.w	#-$40,$12(a0)
		bsr.w	BossMove
		cmpi.w	#$2A00,$30(a0)
		bne.s	loc_17916
		move.w	#0,$10(a0)
		move.w	#0,$12(a0)
		addq.b	#2,$25(a0)
		jsr	SingleObjLoad2
		bne.s	loc_17910
		move.b	#$48,0(a1)	; load swinging	ball object
		move.w	$30(a0),8(a1)
		move.w	$38(a0),$C(a1)
		move.l	a0,$34(a1)

loc_17910:
		move.w	#$77,$3C(a0)

loc_17916:
		bra.w	loc_177E6
; ===========================================================================

Obj3D_ShipMove:				; XREF: Obj3D_ShipIndex
		subq.w	#1,$3C(a0)
		bpl.s	Obj3D_Reverse
		addq.b	#2,$25(a0)
		move.w	#$3F,$3C(a0)
		move.w	#$100,$10(a0)	; move the ship	sideways
		cmpi.w	#$2A00,$30(a0)
		bne.s	Obj3D_Reverse
		move.w	#$7F,$3C(a0)
		move.w	#$40,$10(a0)

Obj3D_Reverse:
		btst	#0,$22(a0)
		bne.s	loc_17950
		neg.w	$10(a0)		; reverse direction of the ship

loc_17950:
		bra.w	loc_177E6
; ===========================================================================

loc_17954:				; XREF: Obj3D_ShipIndex
		subq.w	#1,$3C(a0)
		bmi.s	loc_17960
		bsr.w	BossMove
		bra.s	loc_17976
; ===========================================================================

loc_17960:
		bchg	#0,$22(a0)
		move.w	#$3F,$3C(a0)
		subq.b	#2,$25(a0)
		move.w	#0,$10(a0)

loc_17976:
		bra.w	loc_177E6
; ===========================================================================

loc_1797A:				; XREF: Obj3D_ShipIndex
		subq.w	#1,$3C(a0)
		bmi.s	loc_17984
		bra.w	BossDefeated
; ===========================================================================

loc_17984:
		bset	#0,$22(a0)
		bclr	#7,$22(a0)
		clr.w	$10(a0)
		addq.b	#2,$25(a0)
		move.w	#-$26,$3C(a0)
		tst.b	($FFFFF7A7).w
		bne.s	locret_179AA
		move.b	#1,($FFFFF7A7).w

locret_179AA:
		rts
; ===========================================================================

loc_179AC:				; XREF: Obj3D_ShipIndex
		addq.w	#1,$3C(a0)
		beq.s	loc_179BC
		bpl.s	loc_179C2
		addi.w	#$18,$12(a0)
		bra.s	loc_179EE
; ===========================================================================

loc_179BC:
		clr.w	$12(a0)
		bra.s	loc_179EE
; ===========================================================================

loc_179C2:
		cmpi.w	#$30,$3C(a0)
		bcs.s	loc_179DA
		beq.s	loc_179E0
		cmpi.w	#$38,$3C(a0)
		bcs.s	loc_179EE
		addq.b	#2,$25(a0)
		bra.s	loc_179EE
; ===========================================================================

loc_179DA:
		subq.w	#8,$12(a0)
		bra.s	loc_179EE
; ===========================================================================

loc_179E0:
		clr.w	$12(a0)
		moveq	#mus_GHZ,d0
		jsr	(PlaySound).l	; play GHZ music

loc_179EE:
		bsr.w	BossMove
		bra.w	loc_177E6
; ===========================================================================

loc_179F6:				; XREF: Obj3D_ShipIndex
		move.w	#$400,$10(a0)
		move.w	#-$40,$12(a0)
		cmpi.w	#$2AC0,($FFFFF72A).w
		beq.s	loc_17A10
		addq.w	#2,($FFFFF72A).w
		bra.s	loc_17A16
; ===========================================================================

loc_17A10:
		tst.b	1(a0)
		bpl.s	Obj3D_ShipDel

loc_17A16:
		bsr.w	BossMove
		bra.w	loc_177E6
; ===========================================================================

Obj3D_ShipDel:
		jmp	DeleteObject
; ===========================================================================

Obj3D_FaceMain:				; XREF: Obj3D_Index
		moveq	#0,d0
		moveq	#1,d1
		movea.l	$34(a0),a1
		move.b	$25(a1),d0
		subq.b	#4,d0
		bne.s	loc_17A3E
		cmpi.w	#$2A00,$30(a1)
		bne.s	loc_17A46
		moveq	#4,d1

loc_17A3E:
		subq.b	#6,d0
		bmi.s	loc_17A46
		moveq	#$A,d1
		bra.s	loc_17A5A
; ===========================================================================

loc_17A46:
		tst.b	$20(a1)
		bne.s	loc_17A50
		moveq	#5,d1
		bra.s	loc_17A5A
; ===========================================================================

loc_17A50:
		cmpi.b	#4,($FFFFD024).w
		bcs.s	loc_17A5A
		moveq	#4,d1

loc_17A5A:
		move.b	d1,$1C(a0)
		subq.b	#2,d0
		bne.s	Obj3D_FaceDisp
		move.b	#6,$1C(a0)
		tst.b	1(a0)
		bpl.s	Obj3D_FaceDel

Obj3D_FaceDisp:
		bra.s	Obj3D_Display
; ===========================================================================

Obj3D_FaceDel:
		jmp	DeleteObject
; ===========================================================================

Obj3D_FlameMain:			; XREF: Obj3D_Index
		move.b	#7,$1C(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$C,$25(a1)
		bne.s	loc_17A96
		move.b	#$B,$1C(a0)
		tst.b	1(a0)
		bpl.s	Obj3D_FlameDel
		bra.s	Obj3D_FlameDisp
; ===========================================================================

loc_17A96:
		move.w	$10(a1),d0
		beq.s	Obj3D_FlameDisp
		move.b	#8,$1C(a0)

Obj3D_FlameDisp:
		bra.s	Obj3D_Display
; ===========================================================================

Obj3D_FlameDel:
		jmp	DeleteObject
; ===========================================================================

Obj3D_Display:				; XREF: Obj3D_FaceDisp; Obj3D_FlameDisp
		movea.l	$34(a0),a1
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		move.b	$22(a1),$22(a0)
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		move.b	$22(a0),d0
		andi.b	#3,d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 48 - ball on a	chain that Eggman swings (GHZ)
; ---------------------------------------------------------------------------

Obj48:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj48_Index(pc,d0.w),d1
		jmp	Obj48_Index(pc,d1.w)
; ===========================================================================
Obj48_Index:	dc.w Obj48_Main-Obj48_Index
		dc.w Obj48_Base-Obj48_Index
		dc.w Obj48_Display2-Obj48_Index
		dc.w loc_17C68-Obj48_Index
		dc.w Obj48_ChkVanish-Obj48_Index
; ===========================================================================

Obj48_Main:				; XREF: Obj48_Index
		addq.b	#2,$24(a0)
		move.w	#$4080,$26(a0)
		move.w	#-$200,$3E(a0)
		move.l	#Map_BossItems,4(a0)
		move.w	#$46C,2(a0)
		lea	$28(a0),a2
		move.b	#0,(a2)+
		moveq	#5,d1
		movea.l	a0,a1
		bra.s	loc_17B60
; ===========================================================================

Obj48_MakeLinks:
		jsr	SingleObjLoad2
		bne.s	Obj48_MakeBall
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#$48,0(a1)	; load chain link object
		move.b	#6,$24(a1)
		move.l	#Map_obj15,4(a1)
		move.w	#$380,2(a1)
		move.b	#1,$1A(a1)
		addq.b	#1,$28(a0)

loc_17B60:				; XREF: Obj48_Main
		move.w	a1,d5
		subi.w	#$D000,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	#4,1(a1)
		move.b	#8,$19(a1)
		move.b	#6,$18(a1)
		move.l	$34(a0),$34(a1)
		dbf	d1,Obj48_MakeLinks ; repeat sequence 5 more times

Obj48_MakeBall:
		move.b	#8,$24(a1)
		move.l	#Map_obj48,4(a1) ; load	different mappings for final link
		move.w	#$43AA,2(a1)	; use different	graphics
		move.b	#1,$1A(a1)
		move.b	#5,$18(a1)
		move.b	#$81,$20(a1)	; make object hurt Sonic
		rts
; ===========================================================================

Obj48_PosData:	dc.b 0,	$10, $20, $30, $40, $60	; y-position data for links and	giant ball

; ===========================================================================

Obj48_Base:				; XREF: Obj48_Index
		lea	(Obj48_PosData).l,a3
		lea	$28(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

loc_17BC6:
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#6,d4
		addi.l	#$FFD000,d4
		movea.l	d4,a1
		move.b	(a3)+,d0
		cmp.b	$3C(a1),d0
		beq.s	loc_17BE0
		addq.b	#1,$3C(a1)

loc_17BE0:
		dbf	d6,loc_17BC6

		cmp.b	$3C(a1),d0
		bne.s	loc_17BFA
		movea.l	$34(a0),a1
		cmpi.b	#6,$25(a1)
		bne.s	loc_17BFA
		addq.b	#2,$24(a0)

loc_17BFA:
		cmpi.w	#$20,$32(a0)
		beq.s	Obj48_Display
		addq.w	#1,$32(a0)

Obj48_Display:
		bsr.w	sub_17C2A
		move.b	$26(a0),d0
		jsr	(Obj15_Move2).l
		jmp	DisplaySprite
; ===========================================================================

Obj48_Display2:				; XREF: Obj48_Index
		bsr.w	sub_17C2A
		jsr	(Obj48_Move).l
		jmp	DisplaySprite

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_17C2A:				; XREF: Obj48_Display; Obj48_Display2
		movea.l	$34(a0),a1
		addi.b	#$20,$1B(a0)
		bcc.s	loc_17C3C
		bchg	#0,$1A(a0)

loc_17C3C:
		move.w	8(a1),$3A(a0)
		move.w	$C(a1),d0
		add.w	$32(a0),d0
		move.w	d0,$38(a0)
		move.b	$22(a1),$22(a0)
		tst.b	$22(a1)
		bpl.s	locret_17C66
		move.b	#$3F,0(a0)
		move.b	#0,$24(a0)

locret_17C66:
		rts
; End of function sub_17C2A

; ===========================================================================

loc_17C68:				; XREF: Obj48_Index
		movea.l	$34(a0),a1
		tst.b	$22(a1)
		bpl.s	Obj48_Display3
		move.b	#$3F,0(a0)
		move.b	#0,$24(a0)

Obj48_Display3:
		jmp	DisplaySprite
; ===========================================================================

Obj48_ChkVanish:			; XREF: Obj48_Index
		moveq	#0,d0
		tst.b	$1A(a0)
		bne.s	Obj48_Vanish
		addq.b	#1,d0

Obj48_Vanish:
		move.b	d0,$1A(a0)
		movea.l	$34(a0),a1
		tst.b	$22(a1)
		bpl.s	Obj48_Display4
		move.b	#0,$20(a0)
		bsr.w	BossDefeated
		subq.b	#1,$3C(a0)
		bpl.s	Obj48_Display4
		move.b	#$3F,(a0)
		move.b	#0,$24(a0)

Obj48_Display4:
		jmp	DisplaySprite
; ===========================================================================
Ani_Eggman:
	include "_anim\Eggman.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Eggman (boss levels)
; ---------------------------------------------------------------------------
Map_Eggman:
	include "_maps\Eggman.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - extra boss items (e.g. swinging ball on a chain in GHZ)
; ---------------------------------------------------------------------------
Map_BossItems:
	include "_maps\Boss items.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 77 - Eggman (LZ)
; ---------------------------------------------------------------------------

Obj77:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj77_Index(pc,d0.w),d1
		jmp	Obj77_Index(pc,d1.w)
; ===========================================================================
Obj77_Index:	dc.w Obj77_Main-Obj77_Index
		dc.w Obj77_ShipMain-Obj77_Index
		dc.w Obj77_FaceMain-Obj77_Index
		dc.w Obj77_FlameMain-Obj77_Index

Obj77_ObjData:	dc.b 2,	0		; routine number, animation
		dc.b 4,	1
		dc.b 6,	7
; ===========================================================================

Obj77_Main:				; XREF: Obj77_Index
		move.w	#$1E10,8(a0)
		move.w	#$5C0,$C(a0)
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$F,$20(a0)
		move.b	#8,$21(a0)	; set number of	hits to	8
		move.b	#4,$18(a0)
		lea	Obj77_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#2,d1
		bra.s	Obj77_LoadBoss
; ===========================================================================

Obj77_Loop:
		jsr	SingleObjLoad2
		bne.s	Obj77_ShipMain
		move.b	#$77,0(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

Obj77_LoadBoss:				; XREF: Obj77_Main
		bclr	#0,$22(a0)
		clr.b	$25(a1)
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,$1C(a1)
		move.b	$18(a0),$18(a1)
		move.l	#Map_Eggman,4(a1)
		move.w	#$400,2(a1)
		move.b	#4,1(a1)
		move.b	#$20,$19(a1)
		move.l	a0,$34(a1)
		dbf	d1,Obj77_Loop

Obj77_ShipMain:
		lea	($FFFFD000).w,a1
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj77_ShipIndex(pc,d0.w),d1
		jsr	Obj77_ShipIndex(pc,d1.w)
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================
Obj77_ShipIndex:dc.w loc_17F1E-Obj77_ShipIndex,	loc_17FA0-Obj77_ShipIndex
		dc.w loc_17FE0-Obj77_ShipIndex,	loc_1801E-Obj77_ShipIndex
		dc.w loc_180BC-Obj77_ShipIndex,	loc_180F6-Obj77_ShipIndex
		dc.w loc_1812A-Obj77_ShipIndex,	loc_18152-Obj77_ShipIndex
; ===========================================================================

loc_17F1E:				; XREF: Obj77_ShipIndex
		move.w	8(a1),d0
		cmpi.w	#$1DA0,d0
		bcs.s	loc_17F38
		move.w	#-$180,$12(a0)
		move.w	#$60,$10(a0)
		addq.b	#2,$25(a0)

loc_17F38:
		bsr.w	BossMove
		move.w	$38(a0),$C(a0)
		move.w	$30(a0),8(a0)

loc_17F48:
		tst.b	$3D(a0)
		bne.s	loc_17F8E
		tst.b	$22(a0)
		bmi.s	loc_17F92
		tst.b	$20(a0)
		bne.s	locret_17F8C
		tst.b	$3E(a0)
		bne.s	loc_17F70
		move.b	#$20,$3E(a0)
		moveq	#sfx_BossHit,d0
		jsr	(PlaySound_Special).l

loc_17F70:
		lea	($FFFFFB22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	loc_17F7E
		move.w	#$EEE,d0

loc_17F7E:
		move.w	d0,(a1)
		subq.b	#1,$3E(a0)
		bne.s	locret_17F8C
		move.b	#$F,$20(a0)

locret_17F8C:
		rts
; ===========================================================================

loc_17F8E:				; XREF: loc_17F48
		bra.w	BossDefeated
; ===========================================================================

loc_17F92:				; XREF: loc_17F48
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#-1,$3D(a0)
		rts
; ===========================================================================

loc_17FA0:				; XREF: Obj77_ShipIndex
		moveq	#-2,d0
		cmpi.w	#$1E48,$30(a0)
		bcs.s	loc_17FB6
		move.w	#$1E48,$30(a0)
		clr.w	$10(a0)
		addq.w	#1,d0

loc_17FB6:
		cmpi.w	#$500,$38(a0)
		bgt.s	loc_17FCA
		move.w	#$500,$38(a0)
		clr.w	$12(a0)
		addq.w	#1,d0

loc_17FCA:
		bne.s	loc_17FDC
		move.w	#$140,$10(a0)
		move.w	#-$200,$12(a0)
		addq.b	#2,$25(a0)

loc_17FDC:
		bra.w	loc_17F38
; ===========================================================================

loc_17FE0:				; XREF: Obj77_ShipIndex
		moveq	#-2,d0
		cmpi.w	#$1E70,$30(a0)
		bcs.s	loc_17FF6
		move.w	#$1E70,$30(a0)
		clr.w	$10(a0)
		addq.w	#1,d0

loc_17FF6:
		cmpi.w	#$4C0,$38(a0)
		bgt.s	loc_1800A
		move.w	#$4C0,$38(a0)
		clr.w	$12(a0)
		addq.w	#1,d0

loc_1800A:
		bne.s	loc_1801A
		move.w	#-$180,$12(a0)
		addq.b	#2,$25(a0)
		clr.b	$3F(a0)

loc_1801A:
		bra.w	loc_17F38
; ===========================================================================

loc_1801E:				; XREF: Obj77_ShipIndex
		cmpi.w	#$100,$38(a0)
		bgt.s	loc_1804E
		move.w	#$100,$38(a0)
		move.w	#$140,$10(a0)
		move.w	#-$80,$12(a0)
		tst.b	$3D(a0)
		beq.s	loc_18046
		asl	$10(a0)
		asl	$12(a0)

loc_18046:
		addq.b	#2,$25(a0)
		bra.w	loc_17F38
; ===========================================================================

loc_1804E:
		bset	#0,$22(a0)
		addq.b	#2,$3F(a0)
		move.b	$3F(a0),d0
		jsr	(CalcSine).l
		tst.w	d1
		bpl.s	loc_1806C
		bclr	#0,$22(a0)

loc_1806C:
		asr.w	#4,d0
		swap	d0
		clr.w	d0
		add.l	$30(a0),d0
		swap	d0
		move.w	d0,8(a0)
		move.w	$12(a0),d0
		move.w	($FFFFD00C).w,d1
		sub.w	$C(a0),d1
		bcs.s	loc_180A2
		subi.w	#$48,d1
		bcs.s	loc_180A2
		asr.w	#1,d0
		subi.w	#$28,d1
		bcs.s	loc_180A2
		asr.w	#1,d0
		subi.w	#$28,d1
		bcs.s	loc_180A2
		moveq	#0,d0

loc_180A2:
		ext.l	d0
		asl.l	#8,d0
		tst.b	$3D(a0)
		beq.s	loc_180AE
		add.l	d0,d0

loc_180AE:
		add.l	d0,$38(a0)
		move.w	$38(a0),$C(a0)
		bra.w	loc_17F48
; ===========================================================================

loc_180BC:				; XREF: Obj77_ShipIndex
		moveq	#-2,d0
		cmpi.w	#$1F4C,$30(a0)
		bcs.s	loc_180D2
		move.w	#$1F4C,$30(a0)
		clr.w	$10(a0)
		addq.w	#1,d0

loc_180D2:
		cmpi.w	#$C0,$38(a0)
		bgt.s	loc_180E6
		move.w	#$C0,$38(a0)
		clr.w	$12(a0)
		addq.w	#1,d0

loc_180E6:
		bne.s	loc_180F2
		addq.b	#2,$25(a0)
		bclr	#0,$22(a0)

loc_180F2:
		bra.w	loc_17F38
; ===========================================================================

loc_180F6:				; XREF: Obj77_ShipIndex
		tst.b	$3D(a0)
		bne.s	loc_18112
		cmpi.w	#$1EC8,8(a1)
		blt.s	loc_18126
		cmpi.w	#$F0,$C(a1)
		bgt.s	loc_18126
		move.b	#$32,$3C(a0)

loc_18112:
		moveq	#mus_LZ,d0
		jsr	(PlaySound).l	; play LZ music
		bset	#0,$22(a0)
		addq.b	#2,$25(a0)

loc_18126:
		bra.w	loc_17F38
; ===========================================================================

loc_1812A:				; XREF: Obj77_ShipIndex
		tst.b	$3D(a0)
		bne.s	loc_18136
		subq.b	#1,$3C(a0)
		bne.s	loc_1814E

loc_18136:
		clr.b	$3C(a0)
		move.w	#$400,$10(a0)
		move.w	#-$40,$12(a0)
		clr.b	$3D(a0)
		addq.b	#2,$25(a0)

loc_1814E:
		bra.w	loc_17F38
; ===========================================================================

loc_18152:				; XREF: Obj77_ShipIndex
		cmpi.w	#$2030,($FFFFF72A).w
		bcc.s	loc_18160
		addq.w	#2,($FFFFF72A).w
		bra.s	loc_18166
; ===========================================================================

loc_18160:
		tst.b	1(a0)
		bpl.s	Obj77_ShipDel

loc_18166:
		bra.w	loc_17F38
; ===========================================================================

Obj77_ShipDel:
		jmp	DeleteObject
; ===========================================================================

Obj77_FaceMain:				; XREF: Obj77_Index
		movea.l	$34(a0),a1
		move.b	(a1),d0
		cmp.b	(a0),d0
		bne.s	Obj77_FaceDel
		moveq	#0,d0
		move.b	$25(a1),d0
		moveq	#1,d1
		tst.b	$3D(a0)
		beq.s	loc_1818C
		moveq	#$A,d1
		bra.s	loc_181A0
; ===========================================================================

loc_1818C:
		tst.b	$20(a1)
		bne.s	loc_18196
		moveq	#5,d1
		bra.s	loc_181A0
; ===========================================================================

loc_18196:
		cmpi.b	#4,($FFFFD024).w
		bcs.s	loc_181A0
		moveq	#4,d1

loc_181A0:
		move.b	d1,$1C(a0)
		cmpi.b	#$E,d0
		bne.s	loc_181B6
		move.b	#6,$1C(a0)
		tst.b	1(a0)
		bpl.s	Obj77_FaceDel

loc_181B6:
		bra.s	Obj77_Display
; ===========================================================================

Obj77_FaceDel:
		jmp	DeleteObject
; ===========================================================================

Obj77_FlameMain:			; XREF: Obj77_Index
		move.b	#7,$1C(a0)
		movea.l	$34(a0),a1
		move.b	(a1),d0
		cmp.b	(a0),d0
		bne.s	Obj77_FlameDel
		cmpi.b	#$E,$25(a1)
		bne.s	loc_181F0
		move.b	#$B,$1C(a0)
		tst.b	1(a0)
		bpl.s	Obj77_FlameDel
		bra.s	loc_181F0
; ===========================================================================
		tst.w	$10(a1)
		beq.s	loc_181F0
		move.b	#8,$1C(a0)

loc_181F0:
		bra.s	Obj77_Display
; ===========================================================================

Obj77_FlameDel:				; XREF: Obj77_FlameMain
		jmp	DeleteObject
; ===========================================================================

Obj77_Display:
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		movea.l	$34(a0),a1
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		move.b	$22(a1),$22(a0)
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#-4,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 73 - Eggman (MZ)
; ---------------------------------------------------------------------------

Obj73:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj73_Index(pc,d0.w),d1
		jmp	Obj73_Index(pc,d1.w)
; ===========================================================================
Obj73_Index:	dc.w Obj73_Main-Obj73_Index
		dc.w Obj73_ShipMain-Obj73_Index
		dc.w Obj73_FaceMain-Obj73_Index
		dc.w Obj73_FlameMain-Obj73_Index
		dc.w Obj73_TubeMain-Obj73_Index

Obj73_ObjData:	dc.b 2,	0, 4		; routine number, animation, priority
		dc.b 4,	1, 4
		dc.b 6,	7, 4
		dc.b 8,	0, 3
; ===========================================================================

Obj73_Main:				; XREF: Obj73_Index
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$F,$20(a0)
		move.b	#8,$21(a0)	; set number of	hits to	8
		lea	Obj73_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj73_LoadBoss
; ===========================================================================

Obj73_Loop:
		jsr	SingleObjLoad2
		bne.s	Obj73_ShipMain
		move.b	#$73,0(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

Obj73_LoadBoss:				; XREF: Obj73_Main
		bclr	#0,$22(a0)
		clr.b	$25(a1)
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,$1C(a1)
		move.b	(a2)+,$18(a1)
		move.l	#Map_Eggman,4(a1)
		move.w	#$400,2(a1)
		move.b	#4,1(a1)
		move.b	#$20,$19(a1)
		move.l	a0,$34(a1)
		dbf	d1,Obj73_Loop	; repeat sequence 3 more times

Obj73_ShipMain:
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj73_ShipIndex(pc,d0.w),d1
		jsr	Obj73_ShipIndex(pc,d1.w)
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================
Obj73_ShipIndex:dc.w loc_18302-Obj73_ShipIndex
		dc.w loc_183AA-Obj73_ShipIndex
		dc.w loc_184F6-Obj73_ShipIndex
		dc.w loc_1852C-Obj73_ShipIndex
		dc.w loc_18582-Obj73_ShipIndex
; ===========================================================================

loc_18302:				; XREF: Obj73_ShipIndex
		move.b	$3F(a0),d0
		addq.b	#2,$3F(a0)
		jsr	(CalcSine).l
		asr.w	#2,d0
		move.w	d0,$12(a0)
		move.w	#-$100,$10(a0)
		bsr.w	BossMove
		cmpi.w	#$1910,$30(a0)
		bne.s	loc_18334
		addq.b	#2,$25(a0)
		clr.b	$28(a0)
		clr.l	$10(a0)

loc_18334:
		jsr	(RandomNumber).l
		move.b	d0,$34(a0)

loc_1833E:
		move.w	$38(a0),$C(a0)
		move.w	$30(a0),8(a0)
		cmpi.b	#4,$25(a0)
		bcc.s	locret_18390
		tst.b	$22(a0)
		bmi.s	loc_18392
		tst.b	$20(a0)
		bne.s	locret_18390
		tst.b	$3E(a0)
		bne.s	loc_18374
		move.b	#$28,$3E(a0)
		moveq	#sfx_BossHit,d0
		jsr	(PlaySound_Special).l ;	play boss damage sound

loc_18374:
		lea	($FFFFFB22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	loc_18382
		move.w	#$EEE,d0

loc_18382:
		move.w	d0,(a1)
		subq.b	#1,$3E(a0)
		bne.s	locret_18390
		move.b	#$F,$20(a0)

locret_18390:
		rts
; ===========================================================================

loc_18392:				; XREF: loc_1833E
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#4,$25(a0)
		move.w	#$B4,$3C(a0)
		clr.w	$10(a0)
		rts
; ===========================================================================

loc_183AA:				; XREF: Obj73_ShipIndex
		moveq	#0,d0
		move.b	$28(a0),d0
		move.w	off_183C2(pc,d0.w),d0
		jsr	off_183C2(pc,d0.w)
		andi.b	#6,$28(a0)
		bra.w	loc_1833E
; ===========================================================================
off_183C2:	dc.w loc_183CA-off_183C2
		dc.w Obj73_MakeLava2-off_183C2
		dc.w loc_183CA-off_183C2
		dc.w Obj73_MakeLava2-off_183C2
; ===========================================================================

loc_183CA:				; XREF: off_183C2
		tst.w	$10(a0)
		bne.s	loc_183FE
		moveq	#$40,d0
		cmpi.w	#$22C,$38(a0)
		beq.s	loc_183E6
		bcs.s	loc_183DE
		neg.w	d0

loc_183DE:
		move.w	d0,$12(a0)
		bra.w	BossMove
; ===========================================================================

loc_183E6:
		move.w	#$200,$10(a0)
		move.w	#$100,$12(a0)
		btst	#0,$22(a0)
		bne.s	loc_183FE
		neg.w	$10(a0)

loc_183FE:
		cmpi.b	#$18,$3E(a0)
		bcc.s	Obj73_MakeLava
		bsr.w	BossMove
		subq.w	#4,$12(a0)

Obj73_MakeLava:
		subq.b	#1,$34(a0)
		bcc.s	loc_1845C
		jsr	SingleObjLoad
		bne.s	loc_1844A
		move.b	#$14,0(a1)	; load lava ball object
		move.w	#$2E8,$C(a1)	; set Y	position
		jsr	(RandomNumber).l
		andi.l	#$FFFF,d0
		divu.w	#$50,d0
		swap	d0
		addi.w	#$1878,d0
		move.w	d0,8(a1)
		lsr.b	#7,d1
		move.w	#$FF,$28(a1)

loc_1844A:
		jsr	(RandomNumber).l
		andi.b	#$1F,d0
		addi.b	#$40,d0
		move.b	d0,$34(a0)

loc_1845C:
		btst	#0,$22(a0)
		beq.s	loc_18474
		cmpi.w	#$1910,$30(a0)
		blt.s	locret_1849C
		move.w	#$1910,$30(a0)
		bra.s	loc_18482
; ===========================================================================

loc_18474:
		cmpi.w	#$1830,$30(a0)
		bgt.s	locret_1849C
		move.w	#$1830,$30(a0)

loc_18482:
		clr.w	$10(a0)
		move.w	#-$180,$12(a0)
		cmpi.w	#$22C,$38(a0)
		bcc.s	loc_18498
		neg.w	$12(a0)

loc_18498:
		addq.b	#2,$28(a0)

locret_1849C:
		rts
; ===========================================================================

Obj73_MakeLava2:			; XREF: off_183C2
		bsr.w	BossMove
		move.w	$38(a0),d0
		subi.w	#$22C,d0
		bgt.s	locret_184F4
		move.w	#$22C,d0
		tst.w	$12(a0)
		beq.s	loc_184EA
		clr.w	$12(a0)
		move.w	#$50,$3C(a0)
		bchg	#0,$22(a0)
		jsr	SingleObjLoad
		bne.s	loc_184EA
		move.w	$30(a0),8(a1)
		move.w	$38(a0),$C(a1)
		addi.w	#$18,$C(a1)
		move.b	#$74,(a1)	; load lava ball object
		move.b	#1,$28(a1)

loc_184EA:
		subq.w	#1,$3C(a0)
		bne.s	locret_184F4
		addq.b	#2,$28(a0)

locret_184F4:
		rts
; ===========================================================================

loc_184F6:				; XREF: Obj73_ShipIndex
		subq.w	#1,$3C(a0)
		bmi.s	loc_18500
		bra.w	BossDefeated
; ===========================================================================

loc_18500:
		bset	#0,$22(a0)
		bclr	#7,$22(a0)
		clr.w	$10(a0)
		addq.b	#2,$25(a0)
		move.w	#-$26,$3C(a0)
		tst.b	($FFFFF7A7).w
		bne.s	locret_1852A
		move.b	#1,($FFFFF7A7).w
		clr.w	$12(a0)

locret_1852A:
		rts
; ===========================================================================

loc_1852C:				; XREF: Obj73_ShipIndex
		addq.w	#1,$3C(a0)
		beq.s	loc_18544
		bpl.s	loc_1854E
		cmpi.w	#$270,$38(a0)
		bcc.s	loc_18544
		addi.w	#$18,$12(a0)
		bra.s	loc_1857A
; ===========================================================================

loc_18544:
		clr.w	$12(a0)
		clr.w	$3C(a0)
		bra.s	loc_1857A
; ===========================================================================

loc_1854E:
		cmpi.w	#$30,$3C(a0)
		bcs.s	loc_18566
		beq.s	loc_1856C
		cmpi.w	#$38,$3C(a0)
		bcs.s	loc_1857A
		addq.b	#2,$25(a0)
		bra.s	loc_1857A
; ===========================================================================

loc_18566:
		subq.w	#8,$12(a0)
		bra.s	loc_1857A
; ===========================================================================

loc_1856C:
		clr.w	$12(a0)
		moveq	#mus_MZ,d0
		jsr	(PlaySound).l	; play MZ music

loc_1857A:
		bsr.w	BossMove
		bra.w	loc_1833E
; ===========================================================================

loc_18582:				; XREF: Obj73_ShipIndex
		move.w	#$500,$10(a0)
		move.w	#-$40,$12(a0)
		cmpi.w	#$1960,($FFFFF72A).w
		bcc.s	loc_1859C
		addq.w	#2,($FFFFF72A).w
		bra.s	loc_185A2
; ===========================================================================

loc_1859C:
		tst.b	1(a0)
		bpl.s	Obj73_ShipDel

loc_185A2:
		bsr.w	BossMove
		bra.w	loc_1833E
; ===========================================================================

Obj73_ShipDel:
		jmp	DeleteObject
; ===========================================================================

Obj73_FaceMain:				; XREF: Obj73_Index
		moveq	#0,d0
		moveq	#1,d1
		movea.l	$34(a0),a1
		move.b	$25(a1),d0
		subq.w	#2,d0
		bne.s	loc_185D2
		btst	#1,$28(a1)
		beq.s	loc_185DA
		tst.w	$12(a1)
		bne.s	loc_185DA
		moveq	#4,d1
		bra.s	loc_185EE
; ===========================================================================

loc_185D2:
		subq.b	#2,d0
		bmi.s	loc_185DA
		moveq	#$A,d1
		bra.s	loc_185EE
; ===========================================================================

loc_185DA:
		tst.b	$20(a1)
		bne.s	loc_185E4
		moveq	#5,d1
		bra.s	loc_185EE
; ===========================================================================

loc_185E4:
		cmpi.b	#4,($FFFFD024).w
		bcs.s	loc_185EE
		moveq	#4,d1

loc_185EE:
		move.b	d1,$1C(a0)
		subq.b	#4,d0
		bne.s	loc_18602
		move.b	#6,$1C(a0)
		tst.b	1(a0)
		bpl.s	Obj73_FaceDel

loc_18602:
		bra.s	Obj73_Display
; ===========================================================================

Obj73_FaceDel:
		jmp	DeleteObject
; ===========================================================================

Obj73_FlameMain:			; XREF: Obj73_Index
		move.b	#7,$1C(a0)
		movea.l	$34(a0),a1
		cmpi.b	#8,$25(a1)
		blt.s	loc_1862A
		move.b	#$B,$1C(a0)
		tst.b	1(a0)
		bpl.s	Obj73_FlameDel
		bra.s	loc_18636
; ===========================================================================

loc_1862A:
		tst.w	$10(a1)
		beq.s	loc_18636
		move.b	#8,$1C(a0)

loc_18636:
		bra.s	Obj73_Display
; ===========================================================================

Obj73_FlameDel:				; XREF: Obj73_FlameMain
		jmp	DeleteObject
; ===========================================================================

Obj73_Display:
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite

loc_1864A:
		movea.l	$34(a0),a1
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		move.b	$22(a1),$22(a0)
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#-4,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================

Obj73_TubeMain:				; XREF: Obj73_Index
		movea.l	$34(a0),a1
		cmpi.b	#8,$25(a1)
		bne.s	loc_18688
		tst.b	1(a0)
		bpl.s	Obj73_TubeDel

loc_18688:
		move.l	#Map_BossItems,4(a0)
		move.w	#$246C,2(a0)
		move.b	#4,$1A(a0)
		bra.s	loc_1864A
; ===========================================================================

Obj73_TubeDel:
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 74 - lava that	Eggman drops (MZ)
; ---------------------------------------------------------------------------

Obj74:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj74_Index(pc,d0.w),d0
		jsr	Obj74_Index(pc,d0.w)
		jmp	DisplaySprite
; ===========================================================================
Obj74_Index:	dc.w Obj74_Main-Obj74_Index
		dc.w Obj74_Action-Obj74_Index
		dc.w loc_18886-Obj74_Index
		dc.w Obj74_Delete3-Obj74_Index
; ===========================================================================

Obj74_Main:				; XREF: Obj74_Index
		move.b	#8,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_obj14,4(a0)
		move.w	#$345,2(a0)
		move.b	#4,1(a0)
		move.b	#5,$18(a0)
		move.w	$C(a0),$38(a0)
		move.b	#8,$19(a0)
		addq.b	#2,$24(a0)
		tst.b	$28(a0)
		bne.s	loc_1870A
		move.b	#$8B,$20(a0)
		addq.b	#2,$24(a0)
		bra.w	loc_18886
; ===========================================================================

loc_1870A:
		move.b	#$1E,$29(a0)
		moveq	#sfx_LavaBall,d0
		jsr	(PlaySound_Special).l ;	play lava sound

Obj74_Action:				; XREF: Obj74_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj74_Index2(pc,d0.w),d0
		jsr	Obj74_Index2(pc,d0.w)
		jsr	SpeedToPos
		lea	(Ani_obj14).l,a1
		jsr	AnimateSprite
		cmpi.w	#$2E8,$C(a0)
		bhi.s	Obj74_Delete
		rts
; ===========================================================================

Obj74_Delete:
		jmp	DeleteObject
; ===========================================================================
Obj74_Index2:	dc.w Obj74_Drop-Obj74_Index2
		dc.w Obj74_MakeFlame-Obj74_Index2
		dc.w Obj74_Duplicate-Obj74_Index2
		dc.w Obj74_FallEdge-Obj74_Index2
; ===========================================================================

Obj74_Drop:				; XREF: Obj74_Index2
		bset	#1,$22(a0)
		subq.b	#1,$29(a0)
		bpl.s	locret_18780
		move.b	#$8B,$20(a0)
		clr.b	$28(a0)
		addi.w	#$18,$12(a0)
		bclr	#1,$22(a0)
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	locret_18780
		addq.b	#2,$25(a0)

locret_18780:
		rts
; ===========================================================================

Obj74_MakeFlame:			; XREF: Obj74_Index2
		subq.w	#2,$C(a0)
		bset	#7,2(a0)
		move.w	#$A0,$10(a0)
		clr.w	$12(a0)
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$38(a0)
		move.b	#3,$29(a0)
		jsr	SingleObjLoad2
		bne.s	loc_187CA
		lea	(a1),a3
		lea	(a0),a2
		moveq	#3,d0

Obj74_Loop:
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		dbf	d0,Obj74_Loop

		neg.w	$10(a1)
		addq.b	#2,$25(a1)

loc_187CA:
		addq.b	#2,$25(a0)
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj74_Duplicate2:			; XREF: Obj74_Duplicate
		jsr	SingleObjLoad2
		bne.s	locret_187EE
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#$74,(a1)
		move.w	#$67,$28(a1)

locret_187EE:
		rts
; End of function Obj74_Duplicate2

; ===========================================================================

Obj74_Duplicate:			; XREF: Obj74_Index2
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	loc_18826
		move.w	8(a0),d0
		cmpi.w	#$1940,d0
		bgt.s	loc_1882C
		move.w	$30(a0),d1
		cmp.w	d0,d1
		beq.s	loc_1881E
		andi.w	#$10,d0
		andi.w	#$10,d1
		cmp.w	d0,d1
		beq.s	loc_1881E
		bsr.s	Obj74_Duplicate2
		move.w	8(a0),$32(a0)

loc_1881E:
		move.w	8(a0),$30(a0)
		rts
; ===========================================================================

loc_18826:
		addq.b	#2,$25(a0)
		rts
; ===========================================================================

loc_1882C:
		addq.b	#2,$24(a0)
		rts
; ===========================================================================

Obj74_FallEdge:				; XREF: Obj74_Index2
		bclr	#1,$22(a0)
		addi.w	#$24,$12(a0)	; make flame fall
		move.w	8(a0),d0
		sub.w	$32(a0),d0
		bpl.s	loc_1884A
		neg.w	d0

loc_1884A:
		cmpi.w	#$12,d0
		bne.s	loc_18856
		bclr	#7,2(a0)

loc_18856:
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	locret_1887E
		subq.b	#1,$29(a0)
		beq.s	Obj74_Delete2
		clr.w	$12(a0)
		move.w	$32(a0),8(a0)
		move.w	$38(a0),$C(a0)
		bset	#7,2(a0)
		subq.b	#2,$25(a0)

locret_1887E:
		rts
; ===========================================================================

Obj74_Delete2:
		jmp	DeleteObject
; ===========================================================================

loc_18886:				; XREF: Obj74_Index
		bset	#7,2(a0)
		subq.b	#1,$29(a0)
		bne.s	Obj74_Animate
		move.b	#1,$1C(a0)
		subq.w	#4,$C(a0)
		clr.b	$20(a0)

Obj74_Animate:
		lea	(Ani_obj14).l,a1
		jmp	AnimateSprite
; ===========================================================================

Obj74_Delete3:				; XREF: Obj74_Index
		jmp	DeleteObject
; ===========================================================================

Obj7A_Delete:
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 7A - Eggman (SLZ)
; ---------------------------------------------------------------------------

Obj7A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj7A_Index(pc,d0.w),d1
		jmp	Obj7A_Index(pc,d1.w)
; ===========================================================================
Obj7A_Index:	dc.w Obj7A_Main-Obj7A_Index
		dc.w Obj7A_ShipMain-Obj7A_Index
		dc.w Obj7A_FaceMain-Obj7A_Index
		dc.w Obj7A_FlameMain-Obj7A_Index
		dc.w Obj7A_TubeMain-Obj7A_Index

Obj7A_ObjData:	dc.b 2,	0, 4		; routine number, animation, priority
		dc.b 4,	1, 4
		dc.b 6,	7, 4
		dc.b 8,	0, 3
; ===========================================================================

Obj7A_Main:				; XREF: Obj7A_Index
		move.w	#$2188,8(a0)
		move.w	#$228,$C(a0)
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$F,$20(a0)
		move.b	#8,$21(a0)	; set number of	hits to	8
		lea	Obj7A_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj7A_LoadBoss
; ===========================================================================

Obj7A_Loop:
		jsr	SingleObjLoad2
		bne.s	loc_1895C
		move.b	#$7A,0(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

Obj7A_LoadBoss:				; XREF: Obj7A_Main
		bclr	#0,$22(a0)
		clr.b	$25(a1)
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,$1C(a1)
		move.b	(a2)+,$18(a1)
		move.l	#Map_Eggman,4(a1)
		move.w	#$400,2(a1)
		move.b	#4,1(a1)
		move.b	#$20,$19(a1)
		move.l	a0,$34(a1)
		dbf	d1,Obj7A_Loop	; repeat sequence 3 more times

loc_1895C:
		lea	($FFFFD040).w,a1
		lea	$2A(a0),a2
		moveq	#$5E,d0
		moveq	#$3E,d1

loc_18968:
		cmp.b	(a1),d0
		bne.s	loc_18974
		tst.b	$28(a1)
		beq.s	loc_18974
		move.w	a1,(a2)+

loc_18974:
		adda.w	#$40,a1
		dbf	d1,loc_18968

Obj7A_ShipMain:				; XREF: Obj7A_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj7A_ShipIndex(pc,d0.w),d0
		jsr	Obj7A_ShipIndex(pc,d0.w)
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================
Obj7A_ShipIndex:dc.w loc_189B8-Obj7A_ShipIndex
		dc.w loc_18A5E-Obj7A_ShipIndex
		dc.w Obj7A_MakeBall-Obj7A_ShipIndex
		dc.w loc_18B48-Obj7A_ShipIndex
		dc.w loc_18B80-Obj7A_ShipIndex
		dc.w loc_18BC6-Obj7A_ShipIndex
; ===========================================================================

loc_189B8:				; XREF: Obj7A_ShipIndex
		move.w	#-$100,$10(a0)
		cmpi.w	#$2120,$30(a0)
		bcc.s	loc_189CA
		addq.b	#2,$25(a0)

loc_189CA:
		bsr.w	BossMove
		move.b	$3F(a0),d0
		addq.b	#2,$3F(a0)
		jsr	(CalcSine).l
		asr.w	#6,d0
		add.w	$38(a0),d0
		move.w	d0,$C(a0)
		move.w	$30(a0),8(a0)
		bra.s	loc_189FE
; ===========================================================================

loc_189EE:
		bsr.w	BossMove
		move.w	$38(a0),$C(a0)
		move.w	$30(a0),8(a0)

loc_189FE:
		cmpi.b	#6,$25(a0)
		bcc.s	locret_18A44
		tst.b	$22(a0)
		bmi.s	loc_18A46
		tst.b	$20(a0)
		bne.s	locret_18A44
		tst.b	$3E(a0)
		bne.s	loc_18A28
		move.b	#$20,$3E(a0)
		moveq	#sfx_BossHit,d0
		jsr	(PlaySound_Special).l ;	play boss damage sound

loc_18A28:
		lea	($FFFFFB22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	loc_18A36
		move.w	#$EEE,d0

loc_18A36:
		move.w	d0,(a1)
		subq.b	#1,$3E(a0)
		bne.s	locret_18A44
		move.b	#$F,$20(a0)

locret_18A44:
		rts
; ===========================================================================

loc_18A46:
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#6,$25(a0)
		move.b	#$78,$3C(a0)
		clr.w	$10(a0)
		rts
; ===========================================================================

loc_18A5E:				; XREF: Obj7A_ShipIndex
		move.w	$30(a0),d0
		move.w	#$200,$10(a0)
		btst	#0,$22(a0)
		bne.s	loc_18A7C
		neg.w	$10(a0)
		cmpi.w	#$2008,d0
		bgt.s	loc_18A88
		bra.s	loc_18A82
; ===========================================================================

loc_18A7C:
		cmpi.w	#$2138,d0
		blt.s	loc_18A88

loc_18A82:
		bchg	#0,$22(a0)

loc_18A88:
		move.w	8(a0),d0
		moveq	#-1,d1
		moveq	#2,d2
		lea	$2A(a0),a2
		moveq	#$28,d4
		tst.w	$10(a0)
		bpl.s	loc_18A9E
		neg.w	d4

loc_18A9E:
		move.w	(a2)+,d1
		movea.l	d1,a3
		btst	#3,$22(a3)
		bne.s	loc_18AB4
		move.w	8(a3),d3
		add.w	d4,d3
		sub.w	d0,d3
		beq.s	loc_18AC0

loc_18AB4:
		dbf	d2,loc_18A9E

		move.b	d2,$28(a0)
		bra.w	loc_189CA
; ===========================================================================

loc_18AC0:
		move.b	d2,$28(a0)
		addq.b	#2,$25(a0)
		move.b	#$28,$3C(a0)
		bra.w	loc_189CA
; ===========================================================================

Obj7A_MakeBall:				; XREF: Obj7A_ShipIndex
		cmpi.b	#$28,$3C(a0)
		bne.s	loc_18B36
		moveq	#-1,d0
		move.b	$28(a0),d0
		ext.w	d0
		bmi.s	loc_18B40
		subq.w	#2,d0
		neg.w	d0
		add.w	d0,d0
		lea	$2A(a0),a1
		move.w	(a1,d0.w),d0
		movea.l	d0,a2
		lea	($FFFFD040).w,a1
		moveq	#$3E,d1

loc_18AFA:
		cmp.l	$3C(a1),d0
		beq.s	loc_18B40
		adda.w	#$40,a1
		dbf	d1,loc_18AFA

		move.l	a0,-(sp)
		lea	(a2),a0
		jsr	SingleObjLoad2
		movea.l	(sp)+,a0
		bne.s	loc_18B40
		move.b	#$7B,(a1)	; load spiked ball object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		addi.w	#$20,$C(a1)
		move.b	$22(a2),$22(a1)
		move.l	a2,$3C(a1)

loc_18B36:
		subq.b	#1,$3C(a0)
		beq.s	loc_18B40
		bra.w	loc_189FE
; ===========================================================================

loc_18B40:
		subq.b	#2,$25(a0)
		bra.w	loc_189CA
; ===========================================================================

loc_18B48:				; XREF: Obj7A_ShipIndex
		subq.b	#1,$3C(a0)
		bmi.s	loc_18B52
		bra.w	BossDefeated
; ===========================================================================

loc_18B52:
		addq.b	#2,$25(a0)
		clr.w	$12(a0)
		bset	#0,$22(a0)
		bclr	#7,$22(a0)
		clr.w	$10(a0)
		move.b	#-$18,$3C(a0)
		tst.b	($FFFFF7A7).w
		bne.s	loc_18B7C
		move.b	#1,($FFFFF7A7).w

loc_18B7C:
		bra.w	loc_189FE
; ===========================================================================

loc_18B80:				; XREF: Obj7A_ShipIndex
		addq.b	#1,$3C(a0)
		beq.s	loc_18B90
		bpl.s	loc_18B96
		addi.w	#$18,$12(a0)
		bra.s	loc_18BC2
; ===========================================================================

loc_18B90:
		clr.w	$12(a0)
		bra.s	loc_18BC2
; ===========================================================================

loc_18B96:
		cmpi.b	#$20,$3C(a0)
		bcs.s	loc_18BAE
		beq.s	loc_18BB4
		cmpi.b	#$2A,$3C(a0)
		bcs.s	loc_18BC2
		addq.b	#2,$25(a0)
		bra.s	loc_18BC2
; ===========================================================================

loc_18BAE:
		subq.w	#8,$12(a0)
		bra.s	loc_18BC2
; ===========================================================================

loc_18BB4:
		clr.w	$12(a0)
		moveq	#mus_SLZ,d0
		jsr	(PlaySound).l	; play SLZ music

loc_18BC2:
		bra.w	loc_189EE
; ===========================================================================

loc_18BC6:				; XREF: Obj7A_ShipIndex
		move.w	#$400,$10(a0)
		move.w	#-$40,$12(a0)
		cmpi.w	#$2160,($FFFFF72A).w
		bcc.s	loc_18BE0
		addq.w	#2,($FFFFF72A).w
		bra.s	loc_18BE8
; ===========================================================================

loc_18BE0:
		tst.b	1(a0)
		bpl.w	Obj7A_Delete

loc_18BE8:
		bsr.w	BossMove
		bra.w	loc_189CA
; ===========================================================================

Obj7A_FaceMain:				; XREF: Obj7A_Index
		moveq	#0,d0
		moveq	#1,d1
		movea.l	$34(a0),a1
		move.b	$25(a1),d0
		cmpi.b	#6,d0
		bmi.s	loc_18C06
		moveq	#$A,d1
		bra.s	loc_18C1A
; ===========================================================================

loc_18C06:
		tst.b	$20(a1)
		bne.s	loc_18C10
		moveq	#5,d1
		bra.s	loc_18C1A
; ===========================================================================

loc_18C10:
		cmpi.b	#4,($FFFFD024).w
		bcs.s	loc_18C1A
		moveq	#4,d1

loc_18C1A:
		move.b	d1,$1C(a0)
		cmpi.b	#$A,d0
		bne.s	loc_18C32
		move.b	#6,$1C(a0)
		tst.b	1(a0)
		bpl.w	Obj7A_Delete

loc_18C32:
		bra.s	loc_18C6C
; ===========================================================================

Obj7A_FlameMain:			; XREF: Obj7A_Index
		move.b	#8,$1C(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$A,$25(a1)
		bne.s	loc_18C56
		tst.b	1(a0)
		bpl.w	Obj7A_Delete
		move.b	#$B,$1C(a0)
		bra.s	loc_18C6C
; ===========================================================================

loc_18C56:
		cmpi.b	#8,$25(a1)
		bgt.s	loc_18C6C
		cmpi.b	#4,$25(a1)
		blt.s	loc_18C6C
		move.b	#7,$1C(a0)

loc_18C6C:
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite

loc_18C78:
		movea.l	$34(a0),a1
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		move.b	$22(a1),$22(a0)
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#-4,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================

Obj7A_TubeMain:				; XREF: Obj7A_Index
		movea.l	$34(a0),a1
		cmpi.b	#$A,$25(a1)
		bne.s	loc_18CB8
		tst.b	1(a0)
		bpl.w	Obj7A_Delete

loc_18CB8:
		move.l	#Map_BossItems,4(a0)
		move.w	#$246C,2(a0)
		move.b	#3,$1A(a0)
		bra.s	loc_18C78
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 7B - exploding	spikeys	that Eggman drops (SLZ)
; ---------------------------------------------------------------------------

Obj7B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj7B_Index(pc,d0.w),d0
		jsr	Obj7B_Index(pc,d0.w)
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		bmi.w	Obj7A_Delete
		cmpi.w	#$280,d0
		bhi.w	Obj7A_Delete
		jmp	DisplaySprite
; ===========================================================================
Obj7B_Index:	dc.w Obj7B_Main-Obj7B_Index
		dc.w Obj7B_Fall-Obj7B_Index
		dc.w loc_18DC6-Obj7B_Index
		dc.w loc_18EAA-Obj7B_Index
		dc.w Obj7B_Explode-Obj7B_Index
		dc.w Obj7B_MoveFrag-Obj7B_Index
; ===========================================================================

Obj7B_Main:				; XREF: Obj7B_Index
		move.l	#Map_obj5Ea,4(a0)
		move.w	#$518,2(a0)
		move.b	#1,$1A(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$8B,$20(a0)
		move.b	#$C,$19(a0)
		movea.l	$3C(a0),a1
		move.w	8(a1),$30(a0)
		move.w	$C(a1),$34(a0)
		bset	#0,$22(a0)
		move.w	8(a0),d0
		cmp.w	8(a1),d0
		bgt.s	loc_18D68
		bclr	#0,$22(a0)
		move.b	#2,$3A(a0)

loc_18D68:
		addq.b	#2,$24(a0)

Obj7B_Fall:				; XREF: Obj7B_Index
		jsr	ObjectFall
		movea.l	$3C(a0),a1
		lea	(word_19018).l,a2
		moveq	#0,d0
		move.b	$1A(a1),d0
		move.w	8(a0),d1
		sub.w	$30(a0),d1
		bcc.s	loc_18D8E
		addq.w	#2,d0

loc_18D8E:
		add.w	d0,d0
		move.w	$34(a0),d1
		add.w	(a2,d0.w),d1
		cmp.w	$C(a0),d1
		bgt.s	locret_18DC4
		movea.l	$3C(a0),a1
		moveq	#2,d1
		btst	#0,$22(a0)
		beq.s	loc_18DAE
		moveq	#0,d1

loc_18DAE:
		move.w	#$F0,$28(a0)
		move.b	#10,$1F(a0)	; set frame duration to	10 frames
		move.b	$1F(a0),$1E(a0)
		bra.w	loc_18FA2
; ===========================================================================

locret_18DC4:
		rts
; ===========================================================================

loc_18DC6:				; XREF: Obj7B_Index
		movea.l	$3C(a0),a1
		moveq	#0,d0
		move.b	$3A(a0),d0
		sub.b	$3A(a1),d0
		beq.s	loc_18E2A
		bcc.s	loc_18DDA
		neg.b	d0

loc_18DDA:
		move.w	#-$818,d1
		move.w	#-$114,d2
		cmpi.b	#1,d0
		beq.s	loc_18E00
		move.w	#-$960,d1
		move.w	#-$F4,d2
		cmpi.w	#$9C0,$38(a1)
		blt.s	loc_18E00
		move.w	#-$A20,d1
		move.w	#-$80,d2

loc_18E00:
		move.w	d1,$12(a0)
		move.w	d2,$10(a0)
		move.w	8(a0),d0
		sub.w	$30(a0),d0
		bcc.s	loc_18E16
		neg.w	$10(a0)

loc_18E16:
		move.b	#1,$1A(a0)
		move.w	#$20,$28(a0)
		addq.b	#2,$24(a0)
		bra.w	loc_18EAA
; ===========================================================================

loc_18E2A:				; XREF: loc_18DC6
		lea	(word_19018).l,a2
		moveq	#0,d0
		move.b	$1A(a1),d0
		move.w	#$28,d2
		move.w	8(a0),d1
		sub.w	$30(a0),d1
		bcc.s	loc_18E48
		neg.w	d2
		addq.w	#2,d0

loc_18E48:
		add.w	d0,d0
		move.w	$34(a0),d1
		add.w	(a2,d0.w),d1
		move.w	d1,$C(a0)
		add.w	$30(a0),d2
		move.w	d2,8(a0)
		clr.w	$E(a0)
		clr.w	$A(a0)
		subq.w	#1,$28(a0)
		bne.s	loc_18E7A
		move.w	#$20,$28(a0)
		move.b	#8,$24(a0)
		rts
; ===========================================================================

loc_18E7A:
		cmpi.w	#$78,$28(a0)
		bne.s	loc_18E88
		move.b	#5,$1F(a0)

loc_18E88:
		cmpi.w	#$3C,$28(a0)
		bne.s	loc_18E96
		move.b	#2,$1F(a0)

loc_18E96:
		subq.b	#1,$1E(a0)
		bgt.s	locret_18EA8
		bchg	#0,$1A(a0)
		move.b	$1F(a0),$1E(a0)

locret_18EA8:
		rts
; ===========================================================================

loc_18EAA:				; XREF: Obj7B_Index
		lea	($FFFFD040).w,a1
		moveq	#$7A,d0
		moveq	#$40,d1
		moveq	#$3E,d2

loc_18EB4:
		cmp.b	(a1),d0
		beq.s	loc_18EC0
		adda.w	d1,a1
		dbf	d2,loc_18EB4

		bra.s	loc_18F38
; ===========================================================================

loc_18EC0:
		move.w	8(a1),d0
		move.w	$C(a1),d1
		move.w	8(a0),d2
		move.w	$C(a0),d3
		lea	byte_19022(pc),a2
		lea	byte_19026(pc),a3
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d0
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d2
		cmp.w	d0,d2
		bcs.s	loc_18F38
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d0
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d2
		cmp.w	d2,d0
		bcs.s	loc_18F38
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d1
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d3
		cmp.w	d1,d3
		bcs.s	loc_18F38
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d1
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d3
		cmp.w	d3,d1
		bcs.s	loc_18F38
		addq.b	#2,$24(a0)
		clr.w	$28(a0)
		clr.b	$20(a1)
		subq.b	#1,$21(a1)
		bne.s	loc_18F38
		bset	#7,$22(a1)
		clr.w	$10(a0)
		clr.w	$12(a0)

loc_18F38:
		tst.w	$12(a0)
		bpl.s	loc_18F5C
		jsr	ObjectFall
		move.w	$34(a0),d0
		subi.w	#$2F,d0
		cmp.w	$C(a0),d0
		bgt.s	loc_18F58
		jsr	ObjectFall

loc_18F58:
		bra.w	loc_18E7A
; ===========================================================================

loc_18F5C:
		jsr	ObjectFall
		movea.l	$3C(a0),a1
		lea	(word_19018).l,a2
		moveq	#0,d0
		move.b	$1A(a1),d0
		move.w	8(a0),d1
		sub.w	$30(a0),d1
		bcc.s	loc_18F7E
		addq.w	#2,d0

loc_18F7E:
		add.w	d0,d0
		move.w	$34(a0),d1
		add.w	(a2,d0.w),d1
		cmp.w	$C(a0),d1
		bgt.s	loc_18F58
		movea.l	$3C(a0),a1
		moveq	#2,d1
		tst.w	$10(a0)
		bmi.s	loc_18F9C
		moveq	#0,d1

loc_18F9C:
		move.w	#0,$28(a0)

loc_18FA2:
		move.b	d1,$3A(a1)
		move.b	d1,$3A(a0)
		cmp.b	$1A(a1),d1
		beq.s	loc_19008
		bclr	#3,$22(a1)
		beq.s	loc_19008
		clr.b	$25(a1)
		move.b	#2,$24(a1)
		lea	($FFFFD000).w,a2
		move.w	$12(a0),$12(a2)
		neg.w	$12(a2)
		cmpi.b	#1,$1A(a1)
		bne.s	loc_18FDC
		asr	$12(a2)

loc_18FDC:
		bset	#1,$22(a2)
		bclr	#3,$22(a2)
		clr.b	$3C(a2)
		move.l	a0,-(sp)
		lea	(a2),a0
		jsr	Obj01_ChkRoll
		movea.l	(sp)+,a0
		move.b	#2,$24(a2)
		moveq	#sfx_Spring,d0
		jsr	(PlaySound_Special).l ;	play "spring" sound

loc_19008:
		clr.w	$10(a0)
		clr.w	$12(a0)
		addq.b	#2,$24(a0)
		bra.w	loc_18E7A
; ===========================================================================
word_19018:	dc.w $FFF8, $FFE4, $FFD1, $FFE4, $FFF8
		even
byte_19022:	dc.b $E8, $30, $E8, $30
		even
byte_19026:	dc.b 8,	$F0, 8,	$F0
		even
; ===========================================================================

Obj7B_Explode:				; XREF: Obj7B_Index
		move.b	#$3F,(a0)
		clr.b	$24(a0)
		cmpi.w	#$20,$28(a0)
		beq.s	Obj7B_MakeFrag
		rts
; ===========================================================================

Obj7B_MakeFrag:
		move.w	$34(a0),$C(a0)
		moveq	#3,d1
		lea	Obj7B_FragSpeed(pc),a2

Obj7B_Loop:
		jsr	SingleObjLoad
		bne.s	loc_1909A
		move.b	#$7B,(a1)	; load shrapnel	object
		move.b	#$A,$24(a1)
		move.l	#Map_obj7B,4(a1)
		move.b	#3,$18(a1)
		move.w	#$518,2(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	(a2)+,$10(a1)
		move.w	(a2)+,$12(a1)
		move.b	#$98,$20(a1)
		ori.b	#4,1(a1)
		bset	#7,1(a1)
		move.b	#$C,$19(a1)

loc_1909A:
		dbf	d1,Obj7B_Loop	; repeat sequence 3 more times

		rts
; ===========================================================================
Obj7B_FragSpeed:dc.w $FF00, $FCC0	; horizontal, vertical
		dc.w $FF60, $FDC0
		dc.w $100, $FCC0
		dc.w $A0, $FDC0
; ===========================================================================

Obj7B_MoveFrag:				; XREF: Obj7B_Index
		jsr	SpeedToPos
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$34(a0)
		addi.w	#$18,$12(a0)
		moveq	#4,d0
		and.w	($FFFFFE0E).w,d0
		lsr.w	#2,d0
		move.b	d0,$1A(a0)
		tst.b	1(a0)
		bpl.w	Obj7A_Delete
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - exploding spikeys that the SLZ boss	drops
; ---------------------------------------------------------------------------
Map_obj7B:
	include "_maps\obj7B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 75 - Eggman (SYZ)
; ---------------------------------------------------------------------------

Obj75:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj75_Index(pc,d0.w),d1
		jmp	Obj75_Index(pc,d1.w)
; ===========================================================================
Obj75_Index:	dc.w Obj75_Main-Obj75_Index
		dc.w Obj75_ShipMain-Obj75_Index
		dc.w Obj75_FaceMain-Obj75_Index
		dc.w Obj75_FlameMain-Obj75_Index
		dc.w Obj75_SpikeMain-Obj75_Index

Obj75_ObjData:	dc.b 2,	0, 5		; routine number, animation, priority
		dc.b 4,	1, 5
		dc.b 6,	7, 5
		dc.b 8,	0, 5
; ===========================================================================

Obj75_Main:				; XREF: Obj75_Index
		move.w	#$2DB0,8(a0)
		move.w	#$4DA,$C(a0)
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$F,$20(a0)
		move.b	#8,$21(a0)	; set number of	hits to	8
		lea	Obj75_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj75_LoadBoss
; ===========================================================================

Obj75_Loop:
		jsr	SingleObjLoad2
		bne.s	Obj75_ShipMain
		move.b	#$75,(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

Obj75_LoadBoss:				; XREF: Obj75_Main
		bclr	#0,$22(a0)
		clr.b	$25(a1)
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,$1C(a1)
		move.b	(a2)+,$18(a1)
		move.l	#Map_Eggman,4(a1)
		move.w	#$400,2(a1)
		move.b	#4,1(a1)
		move.b	#$20,$19(a1)
		move.l	a0,$34(a1)
		dbf	d1,Obj75_Loop	; repeat sequence 3 more times

Obj75_ShipMain:				; XREF: Obj75_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj75_ShipIndex(pc,d0.w),d1
		jsr	Obj75_ShipIndex(pc,d1.w)
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================
Obj75_ShipIndex:dc.w loc_191CC-Obj75_ShipIndex,	loc_19270-Obj75_ShipIndex
		dc.w loc_192EC-Obj75_ShipIndex,	loc_19474-Obj75_ShipIndex
		dc.w loc_194AC-Obj75_ShipIndex,	loc_194F2-Obj75_ShipIndex
; ===========================================================================

loc_191CC:				; XREF: Obj75_ShipIndex
		move.w	#-$100,$10(a0)
		cmpi.w	#$2D38,$30(a0)
		bcc.s	loc_191DE
		addq.b	#2,$25(a0)

loc_191DE:
		move.b	$3F(a0),d0
		addq.b	#2,$3F(a0)
		jsr	(CalcSine).l
		asr.w	#2,d0
		move.w	d0,$12(a0)

loc_191F2:
		bsr.w	BossMove
		move.w	$38(a0),$C(a0)
		move.w	$30(a0),8(a0)

loc_19202:
		move.w	8(a0),d0
		subi.w	#$2C00,d0
		lsr.w	#5,d0
		move.b	d0,$34(a0)
		cmpi.b	#6,$25(a0)
		bcc.s	locret_19256
		tst.b	$22(a0)
		bmi.s	loc_19258
		tst.b	$20(a0)
		bne.s	locret_19256
		tst.b	$3E(a0)
		bne.s	loc_1923A
		move.b	#$20,$3E(a0)
		moveq	#sfx_BossHit,d0
		jsr	(PlaySound_Special).l ;	play boss damage sound

loc_1923A:
		lea	($FFFFFB22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	loc_19248
		move.w	#$EEE,d0

loc_19248:
		move.w	d0,(a1)
		subq.b	#1,$3E(a0)
		bne.s	locret_19256
		move.b	#$F,$20(a0)

locret_19256:
		rts
; ===========================================================================

loc_19258:				; XREF: loc_19202
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#6,$25(a0)
		move.w	#$B4,$3C(a0)
		clr.w	$10(a0)
		rts
; ===========================================================================

loc_19270:				; XREF: Obj75_ShipIndex
		move.w	$30(a0),d0
		move.w	#$140,$10(a0)
		btst	#0,$22(a0)
		bne.s	loc_1928E
		neg.w	$10(a0)
		cmpi.w	#$2C08,d0
		bgt.s	loc_1929E
		bra.s	loc_19294
; ===========================================================================

loc_1928E:
		cmpi.w	#$2D38,d0
		blt.s	loc_1929E

loc_19294:
		bchg	#0,$22(a0)
		clr.b	$3D(a0)

loc_1929E:
		subi.w	#$2C10,d0
		andi.w	#$1F,d0
		subi.w	#$1F,d0
		bpl.s	loc_192AE
		neg.w	d0

loc_192AE:
		subq.w	#1,d0
		bgt.s	loc_192E8
		tst.b	$3D(a0)
		bne.s	loc_192E8
		move.w	($FFFFD008).w,d1
		subi.w	#$2C00,d1
		asr.w	#5,d1
		cmp.b	$34(a0),d1
		bne.s	loc_192E8
		moveq	#0,d0
		move.b	$34(a0),d0
		asl.w	#5,d0
		addi.w	#$2C10,d0
		move.w	d0,$30(a0)
		bsr.w	Obj75_FindBlocks
		addq.b	#2,$25(a0)
		clr.w	$28(a0)
		clr.w	$10(a0)

loc_192E8:
		bra.w	loc_191DE
; ===========================================================================

loc_192EC:				; XREF: Obj75_ShipIndex
		moveq	#0,d0
		move.b	$28(a0),d0
		move.w	off_192FA(pc,d0.w),d0
		jmp	off_192FA(pc,d0.w)
; ===========================================================================
off_192FA:	dc.w loc_19302-off_192FA
		dc.w loc_19348-off_192FA
		dc.w loc_1938E-off_192FA
		dc.w loc_193D0-off_192FA
; ===========================================================================

loc_19302:				; XREF: off_192FA
		move.w	#$180,$12(a0)
		move.w	$38(a0),d0
		cmpi.w	#$556,d0
		bcs.s	loc_19344
		move.w	#$556,$38(a0)
		clr.w	$3C(a0)
		moveq	#-1,d0
		move.w	$36(a0),d0
		beq.s	loc_1933C
		movea.l	d0,a1
		move.b	#-1,$29(a1)
		move.b	#-1,$29(a0)
		move.l	a0,$34(a1)
		move.w	#$32,$3C(a0)

loc_1933C:
		clr.w	$12(a0)
		addq.b	#2,$28(a0)

loc_19344:
		bra.w	loc_191F2
; ===========================================================================

loc_19348:				; XREF: off_192FA
		subq.w	#1,$3C(a0)
		bpl.s	loc_19366
		addq.b	#2,$28(a0)
		move.w	#-$800,$12(a0)
		tst.w	$36(a0)
		bne.s	loc_19362
		asr	$12(a0)

loc_19362:
		moveq	#0,d0
		bra.s	loc_1937C
; ===========================================================================

loc_19366:
		moveq	#0,d0
		cmpi.w	#$1E,$3C(a0)
		bgt.s	loc_1937C
		moveq	#2,d0
		btst	#1,$3D(a0)
		beq.s	loc_1937C
		neg.w	d0

loc_1937C:
		add.w	$38(a0),d0
		move.w	d0,$C(a0)
		move.w	$30(a0),8(a0)
		bra.w	loc_19202
; ===========================================================================

loc_1938E:				; XREF: off_192FA
		move.w	#$4DA,d0
		tst.w	$36(a0)
		beq.s	loc_1939C
		subi.w	#$18,d0

loc_1939C:
		cmp.w	$38(a0),d0
		blt.s	loc_193BE
		move.w	#8,$3C(a0)
		tst.w	$36(a0)
		beq.s	loc_193B4
		move.w	#$2D,$3C(a0)

loc_193B4:
		addq.b	#2,$28(a0)
		clr.w	$12(a0)
		bra.s	loc_193CC
; ===========================================================================

loc_193BE:
		cmpi.w	#-$40,$12(a0)
		bge.s	loc_193CC
		addi.w	#$C,$12(a0)

loc_193CC:
		bra.w	loc_191F2
; ===========================================================================

loc_193D0:				; XREF: off_192FA
		subq.w	#1,$3C(a0)
		bgt.s	loc_19406
		bmi.s	loc_193EE
		moveq	#-1,d0
		move.w	$36(a0),d0
		beq.s	loc_193E8
		movea.l	d0,a1
		move.b	#$A,$29(a1)

loc_193E8:
		clr.w	$36(a0)
		bra.s	loc_19406
; ===========================================================================

loc_193EE:
		cmpi.w	#-$1E,$3C(a0)
		bne.s	loc_19406
		clr.b	$29(a0)
		subq.b	#2,$25(a0)
		move.b	#-1,$3D(a0)
		bra.s	loc_19446
; ===========================================================================

loc_19406:
		moveq	#1,d0
		tst.w	$36(a0)
		beq.s	loc_19410
		moveq	#2,d0

loc_19410:
		cmpi.w	#$4DA,$38(a0)
		beq.s	loc_19424
		blt.s	loc_1941C
		neg.w	d0

loc_1941C:
		tst.w	$36(a0)
		add.w	d0,$38(a0)

loc_19424:
		moveq	#0,d0
		tst.w	$36(a0)
		beq.s	loc_19438
		moveq	#2,d0
		btst	#0,$3D(a0)
		beq.s	loc_19438
		neg.w	d0

loc_19438:
		add.w	$38(a0),d0
		move.w	d0,$C(a0)
		move.w	$30(a0),8(a0)

loc_19446:
		bra.w	loc_19202

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj75_FindBlocks:			; XREF: loc_192AE
		clr.w	$36(a0)
		lea	($FFFFD040).w,a1
		moveq	#$3E,d0
		moveq	#$76,d1
		move.b	$34(a0),d2

Obj75_FindLoop:
		cmp.b	(a1),d1		; is object a SYZ boss block?
		bne.s	loc_1946A	; if not, branch
		cmp.b	$28(a1),d2
		bne.s	loc_1946A
		move.w	a1,$36(a0)
		bra.s	locret_19472
; ===========================================================================

loc_1946A:
		lea	$40(a1),a1	; next object RAM entry
		dbf	d0,Obj75_FindLoop

locret_19472:
		rts
; End of function Obj75_FindBlocks

; ===========================================================================

loc_19474:				; XREF: Obj75_ShipIndex
		subq.w	#1,$3C(a0)
		bmi.s	loc_1947E
		bra.w	BossDefeated
; ===========================================================================

loc_1947E:
		addq.b	#2,$25(a0)
		clr.w	$12(a0)
		bset	#0,$22(a0)
		bclr	#7,$22(a0)
		clr.w	$10(a0)
		move.w	#-1,$3C(a0)
		tst.b	($FFFFF7A7).w
		bne.s	loc_194A8
		move.b	#1,($FFFFF7A7).w

loc_194A8:
		bra.w	loc_19202
; ===========================================================================

loc_194AC:				; XREF: Obj75_ShipIndex
		addq.w	#1,$3C(a0)
		beq.s	loc_194BC
		bpl.s	loc_194C2
		addi.w	#$18,$12(a0)
		bra.s	loc_194EE
; ===========================================================================

loc_194BC:
		clr.w	$12(a0)
		bra.s	loc_194EE
; ===========================================================================

loc_194C2:
		cmpi.w	#$20,$3C(a0)
		bcs.s	loc_194DA
		beq.s	loc_194E0
		cmpi.w	#$2A,$3C(a0)
		bcs.s	loc_194EE
		addq.b	#2,$25(a0)
		bra.s	loc_194EE
; ===========================================================================

loc_194DA:
		subq.w	#8,$12(a0)
		bra.s	loc_194EE
; ===========================================================================

loc_194E0:
		clr.w	$12(a0)
		moveq	#mus_SYZ,d0
		jsr	(PlaySound).l	; play SYZ music

loc_194EE:
		bra.w	loc_191F2
; ===========================================================================

loc_194F2:				; XREF: Obj75_ShipIndex
		move.w	#$400,$10(a0)
		move.w	#-$40,$12(a0)
		cmpi.w	#$2D40,($FFFFF72A).w
		bcc.s	loc_1950C
		addq.w	#2,($FFFFF72A).w
		bra.s	loc_19512
; ===========================================================================

loc_1950C:
		tst.b	1(a0)
		bpl.s	Obj75_ShipDelete

loc_19512:
		bsr.w	BossMove
		bra.w	loc_191DE
; ===========================================================================

Obj75_ShipDelete:
		jmp	DeleteObject
; ===========================================================================

Obj75_FaceMain:				; XREF: Obj75_Index
		moveq	#1,d1
		movea.l	$34(a0),a1
		moveq	#0,d0
		move.b	$25(a1),d0
		move.w	off_19546(pc,d0.w),d0
		jsr	off_19546(pc,d0.w)
		move.b	d1,$1C(a0)
		move.b	(a0),d0
		cmp.b	(a1),d0
		bne.s	Obj75_FaceDelete
		bra.s	loc_195BE
; ===========================================================================

Obj75_FaceDelete:
		jmp	DeleteObject
; ===========================================================================
off_19546:	dc.w loc_19574-off_19546, loc_19574-off_19546
		dc.w loc_1955A-off_19546, loc_19552-off_19546
		dc.w loc_19552-off_19546, loc_19556-off_19546
; ===========================================================================

loc_19552:				; XREF: off_19546
		moveq	#$A,d1
		rts
; ===========================================================================

loc_19556:				; XREF: off_19546
		moveq	#6,d1
		rts
; ===========================================================================

loc_1955A:				; XREF: off_19546
		moveq	#0,d0
		move.b	$28(a1),d0
		move.w	off_19568(pc,d0.w),d0
		jmp	off_19568(pc,d0.w)
; ===========================================================================
off_19568:	dc.w loc_19570-off_19568, loc_19572-off_19568
		dc.w loc_19570-off_19568, loc_19570-off_19568
; ===========================================================================

loc_19570:				; XREF: off_19568
		bra.s	loc_19574
; ===========================================================================

loc_19572:				; XREF: off_19568
		moveq	#6,d1

loc_19574:				; XREF: off_19546
		tst.b	$20(a1)
		bne.s	loc_1957E
		moveq	#5,d1
		rts
; ===========================================================================

loc_1957E:
		cmpi.b	#4,($FFFFD024).w
		bcs.s	locret_19588
		moveq	#4,d1

locret_19588:
		rts
; ===========================================================================

Obj75_FlameMain:			; XREF: Obj75_Index
		move.b	#7,$1C(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$A,$25(a1)
		bne.s	loc_195AA
		move.b	#$B,$1C(a0)
		tst.b	1(a0)
		bpl.s	Obj75_FlameDelete
		bra.s	loc_195B6
; ===========================================================================

loc_195AA:
		tst.w	$10(a1)
		beq.s	loc_195B6
		move.b	#8,$1C(a0)

loc_195B6:
		bra.s	loc_195BE
; ===========================================================================

Obj75_FlameDelete:
		jmp	DeleteObject
; ===========================================================================

loc_195BE:
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		movea.l	$34(a0),a1
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)

loc_195DA:
		move.b	$22(a1),$22(a0)
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================

Obj75_SpikeMain:			; XREF: Obj75_Index
		move.l	#Map_BossItems,4(a0)
		move.w	#$246C,2(a0)
		move.b	#5,$1A(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$A,$25(a1)
		bne.s	loc_1961C
		tst.b	1(a0)
		bpl.s	Obj75_SpikeDelete

loc_1961C:
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		move.w	$3C(a0),d0
		cmpi.b	#4,$25(a1)
		bne.s	loc_19652
		cmpi.b	#6,$28(a1)
		beq.s	loc_1964C
		tst.b	$28(a1)
		bne.s	loc_19658
		cmpi.w	#$94,d0
		bge.s	loc_19658
		addq.w	#7,d0
		bra.s	loc_19658
; ===========================================================================

loc_1964C:
		tst.w	$3C(a1)
		bpl.s	loc_19658

loc_19652:
		tst.w	d0
		ble.s	loc_19658
		subq.w	#5,d0

loc_19658:
		move.w	d0,$3C(a0)
		asr.w	#2,d0
		add.w	d0,$C(a0)
		move.b	#8,$19(a0)
		move.b	#$C,$16(a0)
		clr.b	$20(a0)
		movea.l	$34(a0),a1
		tst.b	$20(a1)
		beq.s	loc_19688
		tst.b	$29(a1)
		bne.s	loc_19688
		move.b	#$84,$20(a0)

loc_19688:
		bra.w	loc_195DA
; ===========================================================================

Obj75_SpikeDelete:
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 76 - blocks that Eggman picks up (SYZ)
; ---------------------------------------------------------------------------

Obj76:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj76_Index(pc,d0.w),d1
		jmp	Obj76_Index(pc,d1.w)
; ===========================================================================
Obj76_Index:	dc.w Obj76_Main-Obj76_Index
		dc.w Obj76_Action-Obj76_Index
		dc.w loc_19762-Obj76_Index
; ===========================================================================

Obj76_Main:				; XREF: Obj76_Index
		moveq	#0,d4
		move.w	#$2C10,d5
		moveq	#9,d6
		lea	(a0),a1
		bra.s	Obj76_MakeBlock
; ===========================================================================

Obj76_Loop:
		jsr	SingleObjLoad
		bne.s	Obj76_ExitLoop

Obj76_MakeBlock:			; XREF: Obj76_Main
		move.b	#$76,(a1)
		move.l	#Map_obj76,4(a1)
		move.w	#$4000,2(a1)
		move.b	#4,1(a1)
		move.b	#$10,$19(a1)
		move.b	#$10,$16(a1)
		move.b	#3,$18(a1)
		move.w	d5,8(a1)	; set x-position
		move.w	#$582,$C(a1)
		move.w	d4,$28(a1)
		addi.w	#$101,d4
		addi.w	#$20,d5		; add $20 to next x-position
		addq.b	#2,$24(a1)
		dbf	d6,Obj76_Loop	; repeat sequence 9 more times

Obj76_ExitLoop:
		rts
; ===========================================================================

Obj76_Action:				; XREF: Obj76_Index
		move.b	$29(a0),d0
		cmp.b	$28(a0),d0
		beq.s	Obj76_Solid
		tst.b	d0
		bmi.s	loc_19718

loc_19712:
		bsr.w	Obj76_Break
		bra.s	Obj76_Display
; ===========================================================================

loc_19718:
		movea.l	$34(a0),a1
		tst.b	$21(a1)
		beq.s	loc_19712
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		addi.w	#$2C,$C(a0)
		cmpa.w	a0,a1
		bcs.s	Obj76_Display
		move.w	$12(a1),d0
		ext.l	d0
		asr.l	#8,d0
		add.w	d0,$C(a0)
		bra.s	Obj76_Display
; ===========================================================================

Obj76_Solid:				; XREF: Obj76_Action
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	8(a0),d4
		jsr	SolidObject

Obj76_Display:				; XREF: Obj76_Action
		jmp	DisplaySprite
; ===========================================================================

loc_19762:				; XREF: Obj76_Index
		tst.b	1(a0)
		bpl.s	Obj76_Delete
		jsr	ObjectFall
		jmp	DisplaySprite
; ===========================================================================

Obj76_Delete:
		jmp	DeleteObject

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj76_Break:				; XREF: Obj76_Action
		lea	Obj76_FragSpeed(pc),a4
		lea	Obj76_FragPos(pc),a5
		moveq	#1,d4
		moveq	#3,d1
		moveq	#$38,d2
		addq.b	#2,$24(a0)
		move.b	#8,$19(a0)
		move.b	#8,$16(a0)
		lea	(a0),a1
		bra.s	Obj76_MakeFrag
; ===========================================================================

Obj76_LoopFrag:
		jsr	SingleObjLoad2
		bne.s	loc_197D4

Obj76_MakeFrag:
		lea	(a0),a2
		lea	(a1),a3
		moveq	#3,d3

loc_197AA:
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		dbf	d3,loc_197AA

		move.w	(a4)+,$10(a1)
		move.w	(a4)+,$12(a1)
		move.w	(a5)+,d3
		add.w	d3,8(a1)
		move.w	(a5)+,d3
		add.w	d3,$C(a1)
		move.b	d4,$1A(a1)
		addq.w	#1,d4
		dbf	d1,Obj76_LoopFrag ; repeat sequence 3 more times

loc_197D4:
		moveq	#sfx_Smash,d0
		jmp	(PlaySound_Special).l ;	play smashing sound
; End of function Obj76_Break

; ===========================================================================
Obj76_FragSpeed:dc.w $FE80, $FE00
		dc.w $180, $FE00
		dc.w $FF00, $FF00
		dc.w $100, $FF00
Obj76_FragPos:	dc.w $FFF8, $FFF8
		dc.w $10, 0
		dc.w 0,	$10
		dc.w $10, $10
; ---------------------------------------------------------------------------
; Sprite mappings - blocks that	Eggman picks up (SYZ)
; ---------------------------------------------------------------------------
Map_obj76:
	include "_maps\obj76.asm"

; ===========================================================================

loc_1982C:				; XREF: loc_19C62; loc_19C80
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 82 - Eggman (SBZ2)
; ---------------------------------------------------------------------------

Obj82:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj82_Index(pc,d0.w),d1
		jmp	Obj82_Index(pc,d1.w)
; ===========================================================================
Obj82_Index:	dc.w Obj82_Main-Obj82_Index
		dc.w Obj82_Eggman-Obj82_Index
		dc.w Obj82_Switch-Obj82_Index

Obj82_ObjData:	dc.b 2,	0, 3		; routine number, animation, priority
		dc.b 4,	0, 3
; ===========================================================================

Obj82_Main:				; XREF: Obj82_Index
		lea	Obj82_ObjData(pc),a2
		move.w	#$2160,8(a0)
		move.w	#$5A4,$C(a0)
		move.b	#$F,$20(a0)
		move.b	#$10,$21(a0)
		bclr	#0,$22(a0)
		clr.b	$25(a0)
		move.b	(a2)+,$24(a0)
		move.b	(a2)+,$1C(a0)
		move.b	(a2)+,$18(a0)
		move.l	#Map_obj82,4(a0)
		move.w	#$400,2(a0)
		move.b	#4,1(a0)
		bset	#7,1(a0)
		move.b	#$20,$19(a0)
		jsr	SingleObjLoad2
		bne.s	Obj82_Eggman
		move.l	a0,$34(a1)
		move.b	#$82,(a1)	; load switch object
		move.w	#$2130,8(a1)
		move.w	#$5BC,$C(a1)
		clr.b	$25(a0)
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,$1C(a1)
		move.b	(a2)+,$18(a1)
		move.l	#Map_obj32,4(a1)
		move.w	#$4A4,2(a1)
		move.b	#4,1(a1)
		bset	#7,1(a1)
		move.b	#$10,$19(a1)
		move.b	#0,$1A(a1)

Obj82_Eggman:				; XREF: Obj82_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj82_EggIndex(pc,d0.w),d1
		jsr	Obj82_EggIndex(pc,d1.w)
		lea	Ani_obj82(pc),a1
		jsr	AnimateSprite
		jmp	DisplaySprite
; ===========================================================================
Obj82_EggIndex:	dc.w Obj82_ChkSonic-Obj82_EggIndex
		dc.w Obj82_PreLeap-Obj82_EggIndex
		dc.w Obj82_Leap-Obj82_EggIndex
		dc.w loc_19934-Obj82_EggIndex
; ===========================================================================

Obj82_ChkSonic:				; XREF: Obj82_EggIndex
		move.w	8(a0),d0
		sub.w	($FFFFD008).w,d0
		cmpi.w	#128,d0		; is Sonic within 128 pixels of	Eggman?
		bcc.s	loc_19934	; if not, branch
		addq.b	#2,$25(a0)
		move.w	#180,$3C(a0)	; set delay to 3 seconds
		move.b	#1,$1C(a0)

loc_19934:				; XREF: Obj82_EggIndex
		jmp	SpeedToPos
; ===========================================================================

Obj82_PreLeap:				; XREF: Obj82_EggIndex
		subq.w	#1,$3C(a0)	; subtract 1 from time delay
		bne.s	loc_19954	; if time remains, branch
		addq.b	#2,$25(a0)
		move.b	#2,$1C(a0)
		addq.w	#4,$C(a0)
		move.w	#15,$3C(a0)

loc_19954:
		bra.s	loc_19934
; ===========================================================================

Obj82_Leap:				; XREF: Obj82_EggIndex
		subq.w	#1,$3C(a0)
		bgt.s	loc_199D0
		bne.s	loc_1996A
		move.w	#-$FC,$10(a0)	; make Eggman leap
		move.w	#-$3C0,$12(a0)

loc_1996A:
		cmpi.w	#$2132,8(a0)
		bgt.s	loc_19976
		clr.w	$10(a0)

loc_19976:
		addi.w	#$24,$12(a0)
		tst.w	$12(a0)
		bmi.s	Obj82_FindBlocks
		cmpi.w	#$595,$C(a0)
		bcs.s	Obj82_FindBlocks
		move.w	#$5357,$28(a0)
		cmpi.w	#$59B,$C(a0)
		bcs.s	Obj82_FindBlocks
		move.w	#$59B,$C(a0)
		clr.w	$12(a0)

Obj82_FindBlocks:
		move.w	$10(a0),d0
		or.w	$12(a0),d0
		bne.s	loc_199D0
		lea	($FFFFD000).w,a1 ; start at the	first object RAM
		moveq	#$3E,d0
		moveq	#$40,d1

Obj82_FindLoop:
		adda.w	d1,a1		; jump to next object RAM
		cmpi.b	#$83,(a1)	; is object a block? (object $83)
		dbeq	d0,Obj82_FindLoop ; if not, repeat (max	$3E times)

		bne.s	loc_199D0
		move.w	#$474F,$28(a1)	; set block to disintegrate
		addq.b	#2,$25(a0)
		move.b	#1,$1C(a0)

loc_199D0:
		bra.w	loc_19934
; ===========================================================================

Obj82_Switch:				; XREF: Obj82_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj82_SwIndex(pc,d0.w),d0
		jmp	Obj82_SwIndex(pc,d0.w)
; ===========================================================================
Obj82_SwIndex:	dc.w loc_199E6-Obj82_SwIndex
		dc.w Obj82_SwDisplay-Obj82_SwIndex
; ===========================================================================

loc_199E6:				; XREF: Obj82_SwIndex
		movea.l	$34(a0),a1
		cmpi.w	#$5357,$28(a1)
		bne.s	Obj82_SwDisplay
		move.b	#1,$1A(a0)
		addq.b	#2,$25(a0)

Obj82_SwDisplay:			; XREF: Obj82_SwIndex
		jmp	DisplaySprite
; ===========================================================================
Ani_obj82:
	include "_anim\obj82.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Eggman (SBZ2)
; ---------------------------------------------------------------------------
Map_obj82:
	include "_maps\obj82.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 83 - blocks that disintegrate Eggman	presses	a switch (SBZ2)
; ---------------------------------------------------------------------------

Obj83:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj83_Index(pc,d0.w),d1
		jmp	Obj83_Index(pc,d1.w)
; ===========================================================================
Obj83_Index:	dc.w Obj83_Main-Obj83_Index
		dc.w Obj83_ChkBreak-Obj83_Index
		dc.w loc_19C36-Obj83_Index
		dc.w loc_19C62-Obj83_Index
		dc.w loc_19C72-Obj83_Index
		dc.w loc_19C80-Obj83_Index
; ===========================================================================

Obj83_Main:				; XREF: Obj83_Index
		move.w	#$2080,8(a0)
		move.w	#$5D0,$C(a0)
		move.b	#$80,$19(a0)
		move.b	#$10,$16(a0)
		move.b	#4,1(a0)
		bset	#7,1(a0)
		moveq	#0,d4
		move.w	#$2010,d5
		moveq	#7,d6
		lea	$30(a0),a2

Obj83_MakeBlock:
		jsr	SingleObjLoad
		bne.s	Obj83_ExitMake
		move.w	a1,(a2)+
		move.b	#$83,(a1)	; load block object
		move.l	#Map_obj83,4(a1)
		move.w	#$4518,2(a1)
		move.b	#4,1(a1)
		move.b	#$10,$19(a1)
		move.b	#$10,$16(a1)
		move.b	#3,$18(a1)
		move.w	d5,8(a1)	; set X	position
		move.w	#$5D0,$C(a1)
		addi.w	#$20,d5		; add $20 for next X position
		move.b	#8,$24(a1)
		dbf	d6,Obj83_MakeBlock ; repeat sequence 7 more times

Obj83_ExitMake:
		addq.b	#2,$24(a0)
		rts
; ===========================================================================

Obj83_ChkBreak:				; XREF: Obj83_Index
		cmpi.w	#$474F,$28(a0)	; is object set	to disintegrate?
		bne.s	Obj83_Solid	; if not, branch
		clr.b	$1A(a0)
		addq.b	#2,$24(a0)	; next subroutine

Obj83_Solid:
		moveq	#0,d0
		move.b	$1A(a0),d0
		neg.b	d0
		ext.w	d0
		addq.w	#8,d0
		asl.w	#4,d0
		move.w	#$2100,d4
		sub.w	d0,d4
		move.b	d0,$19(a0)
		move.w	d4,8(a0)
		moveq	#$B,d1
		add.w	d0,d1
		moveq	#$10,d2
		moveq	#$11,d3
		jmp	SolidObject
; ===========================================================================

loc_19C36:				; XREF: Obj83_Index
		subi.b	#$E,$1E(a0)
		bcc.s	Obj83_Solid2
		moveq	#-1,d0
		move.b	$1A(a0),d0
		ext.w	d0
		add.w	d0,d0
		move.w	$30(a0,d0.w),d0
		movea.l	d0,a1
		move.w	#$474F,$28(a1)
		addq.b	#1,$1A(a0)
		cmpi.b	#8,$1A(a0)
		beq.s	loc_19C62

Obj83_Solid2:
		bra.s	Obj83_Solid
; ===========================================================================

loc_19C62:				; XREF: Obj83_Index
		bclr	#3,$22(a0)
		bclr	#3,($FFFFD022).w
		bra.w	loc_1982C
; ===========================================================================

loc_19C72:				; XREF: Obj83_Index
		cmpi.w	#$474F,$28(a0)	; is object set	to disintegrate?
		beq.s	Obj83_Break	; if yes, branch
		jmp	DisplaySprite
; ===========================================================================

loc_19C80:				; XREF: Obj83_Index
		tst.b	1(a0)
		bpl.w	loc_1982C
		jsr	ObjectFall
		jmp	DisplaySprite
; ===========================================================================

Obj83_Break:				; XREF: loc_19C72
		lea	Obj83_FragSpeed(pc),a4
		lea	Obj83_FragPos(pc),a5
		moveq	#1,d4
		moveq	#3,d1
		moveq	#$38,d2
		addq.b	#2,$24(a0)
		move.b	#8,$19(a0)
		move.b	#8,$16(a0)
		lea	(a0),a1
		bra.s	Obj83_MakeFrag
; ===========================================================================

Obj83_LoopFrag:
		jsr	SingleObjLoad2
		bne.s	Obj83_BreakSnd

Obj83_MakeFrag:				; XREF: Obj83_Break
		lea	(a0),a2
		lea	(a1),a3
		moveq	#3,d3

loc_19CC4:
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		dbf	d3,loc_19CC4

		move.w	(a4)+,$12(a1)
		move.w	(a5)+,d3
		add.w	d3,8(a1)
		move.w	(a5)+,d3
		add.w	d3,$C(a1)
		move.b	d4,$1A(a1)
		addq.w	#1,d4
		dbf	d1,Obj83_LoopFrag ; repeat sequence 3 more times

Obj83_BreakSnd:
		moveq	#sfx_Smash,d0
		jsr	(PlaySound_Special).l ;	play smashing sound
		jmp	DisplaySprite
; ===========================================================================
Obj83_FragSpeed:dc.w $80, 0
		dc.w $120, $C0
Obj83_FragPos:	dc.w $FFF8, $FFF8
		dc.w $10, 0
		dc.w 0,	$10
		dc.w $10, $10
; ---------------------------------------------------------------------------
; Sprite mappings - blocks that	disintegrate when Eggman presses a switch
; ---------------------------------------------------------------------------
Map_obj83:
	include "_maps\obj83.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 85 - Eggman (FZ)
; ---------------------------------------------------------------------------

Obj85_Delete:
		jmp	DeleteObject
; ===========================================================================

Obj85:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj85_Index(pc,d0.w),d0
		jmp	Obj85_Index(pc,d0.w)
; ===========================================================================
Obj85_Index:	dc.w Obj85_Main-Obj85_Index
		dc.w Obj85_Eggman-Obj85_Index
		dc.w loc_1A38E-Obj85_Index
		dc.w loc_1A346-Obj85_Index
		dc.w loc_1A2C6-Obj85_Index
		dc.w loc_1A3AC-Obj85_Index
		dc.w loc_1A264-Obj85_Index

Obj85_ObjData:	dc.w $100, $100, $470	; X pos, Y pos,	VRAM setting
		dc.l Map_obj82		; mappings pointer
		dc.w $25B0, $590, $300
		dc.l Map_obj84
		dc.w $26E0, $596, $3A0
		dc.l Map_FZBoss
		dc.w $26E0, $596, $470
		dc.l Map_obj82
		dc.w $26E0, $596, $400
		dc.l Map_Eggman
		dc.w $26E0, $596, $400
		dc.l Map_Eggman

Obj85_ObjData2:	dc.b 2,	0, 4, $20, $19	; routine num, animation, sprite priority, width, height
		dc.b 4,	0, 1, $12, 8
		dc.b 6,	0, 3, 0, 0
		dc.b 8,	0, 3, 0, 0
		dc.b $A, 0, 3, $20, $20
		dc.b $C, 0, 3, 0, 0
; ===========================================================================

Obj85_Main:				; XREF: Obj85_Index
		lea	Obj85_ObjData(pc),a2
		lea	Obj85_ObjData2(pc),a3
		movea.l	a0,a1
		moveq	#5,d1
		bra.s	Obj85_LoadBoss
; ===========================================================================

Obj85_Loop:
		jsr	SingleObjLoad2
		bne.s	loc_19E20

Obj85_LoadBoss:				; XREF: Obj85_Main
		move.b	#$85,(a1)
		move.w	(a2)+,8(a1)
		move.w	(a2)+,$C(a1)
		move.w	(a2)+,2(a1)
		move.l	(a2)+,4(a1)
		move.b	(a3)+,$24(a1)
		move.b	(a3)+,$1C(a1)
		move.b	(a3)+,$18(a1)
		move.b	(a3)+,$17(a1)
		move.b	(a3)+,$16(a1)
		move.b	#4,1(a1)
		bset	#7,1(a0)
		move.l	a0,$34(a1)
		dbf	d1,Obj85_Loop

loc_19E20:
		lea	$36(a0),a2
		jsr	SingleObjLoad
		bne.s	loc_19E5A
		move.b	#$86,(a1)	; load energy ball object
		move.w	a1,(a2)
		move.l	a0,$34(a1)
		lea	$38(a0),a2
		moveq	#0,d2
		moveq	#3,d1

loc_19E3E:
		jsr	SingleObjLoad2
		bne.s	loc_19E5A
		move.w	a1,(a2)+
		move.b	#$84,(a1)	; load crushing	cylinder object
		move.l	a0,$34(a1)
		move.b	d2,$28(a1)
		addq.w	#2,d2
		dbf	d1,loc_19E3E

loc_19E5A:
		move.w	#0,$34(a0)
		move.b	#8,$21(a0)	; set number of	hits to	8
		move.w	#-1,$30(a0)

Obj85_Eggman:				; XREF: Obj85_Index
		moveq	#0,d0
		move.b	$34(a0),d0
		move.w	off_19E80(pc,d0.w),d0
		jsr	off_19E80(pc,d0.w)
		jmp	DisplaySprite
; ===========================================================================
off_19E80:	dc.w loc_19E90-off_19E80, loc_19EA8-off_19E80
		dc.w loc_19FE6-off_19E80, loc_1A02A-off_19E80
		dc.w loc_1A074-off_19E80, loc_1A112-off_19E80
		dc.w loc_1A192-off_19E80, loc_1A1D4-off_19E80
; ===========================================================================

loc_19E90:				; XREF: off_19E80
		tst.l	($FFFFF680).w
		bne.s	loc_19EA2
		cmpi.w	#$2450,($FFFFF700).w
		bcs.s	loc_19EA2
		addq.b	#2,$34(a0)

loc_19EA2:
		addq.l	#1,($FFFFF636).w
		rts
; ===========================================================================

loc_19EA8:				; XREF: off_19E80
		tst.w	$30(a0)
		bpl.s	loc_19F10
		clr.w	$30(a0)
		jsr	(RandomNumber).l
		andi.w	#$C,d0
		move.w	d0,d1
		addq.w	#2,d1
		tst.l	d0
		bpl.s	loc_19EC6
		exg	d1,d0

loc_19EC6:
		lea	word_19FD6(pc),a1
		move.w	(a1,d0.w),d0
		move.w	(a1,d1.w),d1
		move.w	d0,$30(a0)
		moveq	#-1,d2
		move.w	$38(a0,d0.w),d2
		movea.l	d2,a1
		move.b	#-1,$29(a1)
		move.w	#-1,$30(a1)
		move.w	$38(a0,d1.w),d2
		movea.l	d2,a1
		move.b	#1,$29(a1)
		move.w	#0,$30(a1)
		move.w	#1,$32(a0)
		clr.b	$35(a0)
		moveq	#sfx_Rumble,d0
		jsr	(PlaySound_Special).l ;	play rumbling sound

loc_19F10:
		tst.w	$32(a0)
		bmi.w	loc_19FA6
		bclr	#0,$22(a0)
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bcs.s	loc_19F2E
		bset	#0,$22(a0)

loc_19F2E:
		move.w	#$2B,d1
		move.w	#$14,d2
		move.w	#$14,d3
		move.w	8(a0),d4
		jsr	SolidObject
		tst.w	d4
		bgt.s	loc_19F50

loc_19F48:
		tst.b	$35(a0)
		bne.s	loc_19F88
		bra.s	loc_19F96
; ===========================================================================

loc_19F50:
		addq.w	#7,($FFFFF636).w
		cmpi.b	#2,($FFFFD01C).w
		bne.s	loc_19F48
		move.w	#$300,d0
		btst	#0,$22(a0)
		bne.s	loc_19F6A
		neg.w	d0

loc_19F6A:
		move.w	d0,($FFFFD010).w
		tst.b	$35(a0)
		bne.s	loc_19F88
		subq.b	#1,$21(a0)
		move.b	#$64,$35(a0)
		moveq	#sfx_BossHit,d0
		jsr	(PlaySound_Special).l ;	play boss damage sound

loc_19F88:
		subq.b	#1,$35(a0)
		beq.s	loc_19F96
		move.b	#3,$1C(a0)
		bra.s	loc_19F9C
; ===========================================================================

loc_19F96:
		move.b	#1,$1C(a0)

loc_19F9C:
		lea	Ani_obj82(pc),a1
		jmp	AnimateSprite
; ===========================================================================

loc_19FA6:
		tst.b	$21(a0)
		beq.s	loc_19FBC
		addq.b	#2,$34(a0)
		move.w	#-1,$30(a0)
		clr.w	$32(a0)
		rts
; ===========================================================================

loc_19FBC:
		move.b	#6,$34(a0)
		move.w	#$25C0,8(a0)
		move.w	#$53C,$C(a0)
		move.b	#$14,$16(a0)
		rts
; ===========================================================================
word_19FD6:	dc.w 0,	2, 2, 4, 4, 6, 6, 0
; ===========================================================================

loc_19FE6:				; XREF: off_19E80
		moveq	#-1,d0
		move.w	$36(a0),d0
		movea.l	d0,a1
		tst.w	$30(a0)
		bpl.s	loc_1A000
		clr.w	$30(a0)
		move.b	#-1,$29(a1)
		bsr.s	loc_1A020

loc_1A000:
		moveq	#$F,d0
		and.w	($FFFFFE0E).w,d0
		bne.s	loc_1A00A
		bsr.s	loc_1A020

loc_1A00A:
		tst.w	$32(a0)
		beq.s	locret_1A01E
		subq.b	#2,$34(a0)
		move.w	#-1,$30(a0)
		clr.w	$32(a0)

locret_1A01E:
		rts
; ===========================================================================

loc_1A020:
		moveq	#sfx_Electricity,d0
		jmp	(PlaySound_Special).l ;	play electricity sound
; ===========================================================================

loc_1A02A:				; XREF: off_19E80
		move.b	#$30,$17(a0)
		bset	#0,$22(a0)
		jsr	SpeedToPos
		move.b	#6,$1A(a0)
		addi.w	#$10,$12(a0)
		cmpi.w	#$59C,$C(a0)
		bcs.s	loc_1A070
		move.w	#$59C,$C(a0)
		addq.b	#2,$34(a0)
		move.b	#$20,$17(a0)
		move.w	#$100,$10(a0)
		move.w	#-$100,$12(a0)
		addq.b	#2,($FFFFF742).w

loc_1A070:
		bra.w	loc_1A166
; ===========================================================================

loc_1A074:				; XREF: off_19E80
		bset	#0,$22(a0)
		move.b	#4,$1C(a0)
		jsr	SpeedToPos
		addi.w	#$10,$12(a0)
		cmpi.w	#$5A3,$C(a0)
		bcs.s	loc_1A09A
		move.w	#-$40,$12(a0)

loc_1A09A:
		move.w	#$400,$10(a0)
		move.w	8(a0),d0
		sub.w	($FFFFD008).w,d0
		bpl.s	loc_1A0B4
		move.w	#$500,$10(a0)
		bra.w	loc_1A0F2
; ===========================================================================

loc_1A0B4:
		subi.w	#$70,d0
		bcs.s	loc_1A0F2
		subi.w	#$100,$10(a0)
		subq.w	#8,d0
		bcs.s	loc_1A0F2
		subi.w	#$100,$10(a0)
		subq.w	#8,d0
		bcs.s	loc_1A0F2
		subi.w	#$80,$10(a0)
		subq.w	#8,d0
		bcs.s	loc_1A0F2
		subi.w	#$80,$10(a0)
		subq.w	#8,d0
		bcs.s	loc_1A0F2
		subi.w	#$80,$10(a0)
		subi.w	#$38,d0
		bcs.s	loc_1A0F2
		clr.w	$10(a0)

loc_1A0F2:
		cmpi.w	#$26A0,8(a0)
		bcs.s	loc_1A110
		move.w	#$26A0,8(a0)
		move.w	#$240,$10(a0)
		move.w	#-$4C0,$12(a0)
		addq.b	#2,$34(a0)

loc_1A110:
		bra.s	loc_1A15C
; ===========================================================================

loc_1A112:				; XREF: off_19E80
		jsr	SpeedToPos
		cmpi.w	#$26E0,8(a0)
		bcs.s	loc_1A124
		clr.w	$10(a0)

loc_1A124:
		addi.w	#$34,$12(a0)
		tst.w	$12(a0)
		bmi.s	loc_1A142
		cmpi.w	#$592,$C(a0)
		bcs.s	loc_1A142
		move.w	#$592,$C(a0)
		clr.w	$12(a0)

loc_1A142:
		move.w	$10(a0),d0
		or.w	$12(a0),d0
		bne.s	loc_1A15C
		addq.b	#2,$34(a0)
		move.w	#-$180,$12(a0)
		move.b	#1,$21(a0)

loc_1A15C:
		lea	Ani_obj82(pc),a1
		jsr	AnimateSprite

loc_1A166:
		cmpi.w	#$2700,($FFFFF72A).w
		bge.s	loc_1A172
		addq.w	#2,($FFFFF72A).w

loc_1A172:
		cmpi.b	#$C,$34(a0)
		bge.s	locret_1A190
		move.w	#$1B,d1
		move.w	#$70,d2
		move.w	#$71,d3
		move.w	8(a0),d4
		jmp	SolidObject
; ===========================================================================

locret_1A190:
		rts
; ===========================================================================

loc_1A192:				; XREF: off_19E80
		move.l	#Map_Eggman,4(a0)
		move.w	#$400,2(a0)
		move.b	#0,$1C(a0)
		bset	#0,$22(a0)
		jsr	SpeedToPos
		cmpi.w	#$544,$C(a0)
		bcc.s	loc_1A1D0
		move.w	#$180,$10(a0)
		move.w	#-$18,$12(a0)
		move.b	#$F,$20(a0)
		addq.b	#2,$34(a0)

loc_1A1D0:
		bra.w	loc_1A15C
; ===========================================================================

loc_1A1D4:				; XREF: off_19E80
		bset	#0,$22(a0)
		jsr	SpeedToPos
		tst.w	$30(a0)
		bne.s	loc_1A1FC
		tst.b	$20(a0)
		bne.s	loc_1A216
		move.w	#$1E,$30(a0)
		moveq	#sfx_BossHit,d0
		jsr	(PlaySound_Special).l ;	play boss damage sound

loc_1A1FC:
		subq.w	#1,$30(a0)
		bne.s	loc_1A216
		tst.b	$22(a0)
		bpl.s	loc_1A210
		move.w	#$60,$12(a0)
		bra.s	loc_1A216
; ===========================================================================

loc_1A210:
		move.b	#$F,$20(a0)

loc_1A216:
		cmpi.w	#$2790,($FFFFD008).w
		blt.s	loc_1A23A
		move.b	#1,($FFFFF7CC).w
		move.w	#0,($FFFFF602).w
		clr.w	($FFFFD014).w
		tst.w	$12(a0)
		bpl.s	loc_1A248
		move.w	#$100,($FFFFF602).w

loc_1A23A:
		cmpi.w	#$27E0,($FFFFD008).w
		blt.s	loc_1A248
		move.w	#$27E0,($FFFFD008).w

loc_1A248:
		cmpi.w	#$2900,8(a0)
		bcs.s	loc_1A260
		tst.b	1(a0)
		bmi.s	loc_1A260
		move.b	#$18,($FFFFF600).w
		bra.w	Obj85_Delete
; ===========================================================================

loc_1A260:
		bra.w	loc_1A15C
; ===========================================================================

loc_1A264:				; XREF: Obj85_Index
		movea.l	$34(a0),a1
		move.b	(a1),d0
		cmp.b	(a0),d0
		bne.w	Obj85_Delete
		move.b	#7,$1C(a0)
		cmpi.b	#$C,$34(a1)
		bge.s	loc_1A280
		bra.s	loc_1A2A6
; ===========================================================================

loc_1A280:
		tst.w	$10(a1)
		beq.s	loc_1A28C
		move.b	#$B,$1C(a0)

loc_1A28C:
		lea	Ani_Eggman(pc),a1
		jsr	AnimateSprite

loc_1A296:
		movea.l	$34(a0),a1
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)

loc_1A2A6:
		movea.l	$34(a0),a1
		move.b	$22(a1),$22(a0)
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#-4,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================

loc_1A2C6:				; XREF: Obj85_Index
		movea.l	$34(a0),a1
		move.b	(a1),d0
		cmp.b	(a0),d0
		bne.w	Obj85_Delete
		cmpi.l	#Map_Eggman,4(a1)
		beq.s	loc_1A2E4
		move.b	#$A,$1A(a0)
		bra.s	loc_1A2A6
; ===========================================================================

loc_1A2E4:
		move.b	#1,$1C(a0)
		tst.b	$21(a1)
		ble.s	loc_1A312
		move.b	#6,$1C(a0)
		move.l	#Map_Eggman,4(a0)
		move.w	#$400,2(a0)
		lea	Ani_Eggman(pc),a1
		jsr	AnimateSprite
		bra.w	loc_1A296
; ===========================================================================

loc_1A312:
		tst.b	1(a0)
		bpl.w	Obj85_Delete
		bsr.w	BossDefeated
		move.b	#2,$18(a0)
		move.b	#0,$1C(a0)
		move.l	#Map_Eggman2,4(a0)
		move.w	#$3A0,2(a0)
		lea	Ani_obj85(pc),a1
		jsr	AnimateSprite
		bra.w	loc_1A296
; ===========================================================================

loc_1A346:				; XREF: Obj85_Index
		bset	#0,$22(a0)
		movea.l	$34(a0),a1
		cmpi.l	#Map_Eggman,4(a1)
		beq.s	loc_1A35E
		bra.w	loc_1A2A6
; ===========================================================================

loc_1A35E:
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		tst.b	$1E(a0)
		bne.s	loc_1A376
		move.b	#$14,$1E(a0)

loc_1A376:
		subq.b	#1,$1E(a0)
		bgt.s	loc_1A38A
		addq.b	#1,$1A(a0)
		cmpi.b	#2,$1A(a0)
		bgt.w	Obj85_Delete

loc_1A38A:
		bra.w	loc_1A296
; ===========================================================================

loc_1A38E:				; XREF: Obj85_Index
		move.b	#$B,$1A(a0)
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bcs.s	loc_1A3A6
		tst.b	1(a0)
		bpl.w	Obj85_Delete

loc_1A3A6:
		jmp	DisplaySprite
; ===========================================================================

loc_1A3AC:				; XREF: Obj85_Index
		move.b	#0,$1A(a0)
		bset	#0,$22(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$C,$34(a1)
		bne.s	loc_1A3D0
		cmpi.l	#Map_Eggman,4(a1)
		beq.w	Obj85_Delete

loc_1A3D0:
		bra.w	loc_1A2A6
; ===========================================================================
Ani_obj85:
	include "_anim\obj85.asm"

Map_Eggman2:
	include "_maps\Eggman2.asm"

Map_FZBoss:
	include "_maps\FZ boss.asm"

; ===========================================================================

Obj84_Delete:
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 84 - cylinder Eggman	hides in (FZ)
; ---------------------------------------------------------------------------

Obj84:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj84_Index(pc,d0.w),d0
		jmp	Obj84_Index(pc,d0.w)
; ===========================================================================
Obj84_Index:	dc.w Obj84_Main-Obj84_Index
		dc.w loc_1A4CE-Obj84_Index
		dc.w loc_1A57E-Obj84_Index

Obj84_PosData:	dc.w $24D0, $620
		dc.w $2550, $620
		dc.w $2490, $4C0
		dc.w $2510, $4C0
; ===========================================================================

Obj84_Main:				; XREF: Obj84_Index
		lea	Obj84_PosData(pc),a1
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		adda.w	d0,a1
		move.b	#4,1(a0)
		bset	#7,1(a0)
		bset	#4,1(a0)
		move.w	#$300,2(a0)
		move.l	#Map_obj84,4(a0)
		move.w	(a1)+,8(a0)
		move.w	(a1),$C(a0)
		move.w	(a1)+,$38(a0)
		move.b	#$20,$16(a0)
		move.b	#$60,$17(a0)
		move.b	#$20,$19(a0)
		move.b	#$60,$16(a0)
		move.b	#3,$18(a0)
		addq.b	#2,$24(a0)

loc_1A4CE:				; XREF: Obj84_Index
		cmpi.b	#2,$28(a0)
		ble.s	loc_1A4DC
		bset	#1,1(a0)

loc_1A4DC:
		clr.l	$3C(a0)
		tst.b	$29(a0)
		beq.s	loc_1A4EA
		addq.b	#2,$24(a0)

loc_1A4EA:
		move.l	$3C(a0),d0
		move.l	$38(a0),d1
		add.l	d0,d1
		swap	d1
		move.w	d1,$C(a0)
		cmpi.b	#4,$24(a0)
		bne.s	loc_1A524
		tst.w	$30(a0)
		bpl.s	loc_1A524
		moveq	#-$A,d0
		cmpi.b	#2,$28(a0)
		ble.s	loc_1A514
		moveq	#$E,d0

loc_1A514:
		add.w	d0,d1
		movea.l	$34(a0),a1
		move.w	d1,$C(a1)
		move.w	8(a0),8(a1)

loc_1A524:
		move.w	#$2B,d1
		move.w	#$60,d2
		move.w	#$61,d3
		move.w	8(a0),d4
		jsr	SolidObject
		moveq	#0,d0
		move.w	$3C(a0),d1
		bpl.s	loc_1A550
		neg.w	d1
		subq.w	#8,d1
		bcs.s	loc_1A55C
		addq.b	#1,d0
		asr.w	#4,d1
		add.w	d1,d0
		bra.s	loc_1A55C
; ===========================================================================

loc_1A550:
		subi.w	#$27,d1
		bcs.s	loc_1A55C
		addq.b	#1,d0
		asr.w	#4,d1
		add.w	d1,d0

loc_1A55C:
		move.b	d0,$1A(a0)
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bmi.s	loc_1A578
		subi.w	#$140,d0
		bmi.s	loc_1A578
		tst.b	1(a0)
		bpl.w	Obj84_Delete

loc_1A578:
		jmp	DisplaySprite
; ===========================================================================

loc_1A57E:				; XREF: Obj84_Index
		moveq	#0,d0
		move.b	$28(a0),d0
		move.w	off_1A590(pc,d0.w),d0
		jsr	off_1A590(pc,d0.w)
		bra.w	loc_1A4EA
; ===========================================================================
off_1A590:	dc.w loc_1A598-off_1A590
		dc.w loc_1A598-off_1A590
		dc.w loc_1A604-off_1A590
		dc.w loc_1A604-off_1A590
; ===========================================================================

loc_1A598:				; XREF: off_1A590
		tst.b	$29(a0)
		bne.s	loc_1A5D4
		movea.l	$34(a0),a1
		tst.b	$21(a1)
		bne.s	loc_1A5B4
		bsr.w	BossDefeated
		subi.l	#$10000,$3C(a0)

loc_1A5B4:
		addi.l	#$20000,$3C(a0)
		bcc.s	locret_1A602
		clr.l	$3C(a0)
		movea.l	$34(a0),a1
		subq.w	#1,$32(a1)
		clr.w	$30(a1)
		subq.b	#2,$24(a0)
		rts
; ===========================================================================

loc_1A5D4:
		cmpi.w	#-$10,$3C(a0)
		bge.s	loc_1A5E4
		subi.l	#$28000,$3C(a0)

loc_1A5E4:
		subi.l	#$8000,$3C(a0)
		cmpi.w	#-$A0,$3C(a0)
		bgt.s	locret_1A602
		clr.w	$3E(a0)
		move.w	#-$A0,$3C(a0)
		clr.b	$29(a0)

locret_1A602:
		rts
; ===========================================================================

loc_1A604:				; XREF: off_1A590
		bset	#1,1(a0)
		tst.b	$29(a0)
		bne.s	loc_1A646
		movea.l	$34(a0),a1
		tst.b	$21(a1)
		bne.s	loc_1A626
		bsr.w	BossDefeated
		addi.l	#$10000,$3C(a0)

loc_1A626:
		subi.l	#$20000,$3C(a0)
		bcc.s	locret_1A674
		clr.l	$3C(a0)
		movea.l	$34(a0),a1
		subq.w	#1,$32(a1)
		clr.w	$30(a1)
		subq.b	#2,$24(a0)
		rts
; ===========================================================================

loc_1A646:
		cmpi.w	#$10,$3C(a0)
		blt.s	loc_1A656
		addi.l	#$28000,$3C(a0)

loc_1A656:
		addi.l	#$8000,$3C(a0)
		cmpi.w	#$A0,$3C(a0)
		blt.s	locret_1A674
		clr.w	$3E(a0)
		move.w	#$A0,$3C(a0)
		clr.b	$29(a0)

locret_1A674:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - cylinders Eggman hides in (FZ)
; ---------------------------------------------------------------------------
Map_obj84:
	include "_maps\obj84.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 86 - energy balls (FZ)
; ---------------------------------------------------------------------------

Obj86:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj86_Index(pc,d0.w),d0
		jmp	Obj86_Index(pc,d0.w)
; ===========================================================================
Obj86_Index:	dc.w Obj86_Main-Obj86_Index
		dc.w Obj86_Generator-Obj86_Index
		dc.w Obj86_MakeBalls-Obj86_Index
		dc.w loc_1A962-Obj86_Index
		dc.w loc_1A982-Obj86_Index
; ===========================================================================

Obj86_Main:				; XREF: Obj86_Index
		move.w	#$2588,8(a0)
		move.w	#$53C,$C(a0)
		move.w	#$300,2(a0)
		move.l	#Map_obj86,4(a0)
		move.b	#0,$1C(a0)
		move.b	#3,$18(a0)
		move.b	#8,$17(a0)
		move.b	#8,$16(a0)
		move.b	#4,1(a0)
		bset	#7,1(a0)
		addq.b	#2,$24(a0)

Obj86_Generator:			; XREF: Obj86_Index
		movea.l	$34(a0),a1
		cmpi.b	#6,$34(a1)
		bne.s	loc_1A850
		move.b	#$3F,(a0)
		move.b	#0,$24(a0)
		jmp	DisplaySprite
; ===========================================================================

loc_1A850:
		move.b	#0,$1C(a0)
		tst.b	$29(a0)
		beq.s	loc_1A86C
		addq.b	#2,$24(a0)
		move.b	#1,$1C(a0)
		move.b	#$3E,$28(a0)

loc_1A86C:
		move.w	#$13,d1
		move.w	#8,d2
		move.w	#$11,d3
		move.w	8(a0),d4
		jsr	SolidObject
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		bmi.s	loc_1A89A
		subi.w	#$140,d0
		bmi.s	loc_1A89A
		tst.b	1(a0)
		bpl.w	Obj84_Delete

loc_1A89A:
		lea	Ani_obj86(pc),a1
		jsr	AnimateSprite
		jmp	DisplaySprite
; ===========================================================================

Obj86_MakeBalls:			; XREF: Obj86_Index
		tst.b	$29(a0)
		beq.w	loc_1A954
		clr.b	$29(a0)
		add.w	$30(a0),d0
		andi.w	#$1E,d0
		adda.w	d0,a2
		addq.w	#4,$30(a0)
		clr.w	$32(a0)
		moveq	#3,d2

Obj86_Loop:
		jsr	SingleObjLoad2
		bne.w	loc_1A954
		move.b	#$86,(a1)
		move.w	8(a0),8(a1)
		move.w	#$53C,$C(a1)
		move.b	#8,$24(a1)
		move.w	#$2300,2(a1)
		move.l	#Map_obj86a,4(a1)
		move.b	#$C,$16(a1)
		move.b	#$C,$17(a1)
		move.b	#0,$20(a1)
		move.b	#3,$18(a1)
		move.w	#$3E,$28(a1)
		move.b	#4,1(a1)
		bset	#7,1(a1)
		move.l	a0,$34(a1)
		jsr	(RandomNumber).l
		move.w	$32(a0),d1
		muls.w	#-$4F,d1
		addi.w	#$2578,d1
		andi.w	#$1F,d0
		subi.w	#$10,d0
		add.w	d1,d0
		move.w	d0,$30(a1)
		addq.w	#1,$32(a0)
		move.w	$32(a0),$38(a0)
		dbf	d2,Obj86_Loop	; repeat sequence 3 more times

loc_1A954:
		tst.w	$32(a0)
		bne.s	loc_1A95E
		addq.b	#2,$24(a0)

loc_1A95E:
		bra.w	loc_1A86C
; ===========================================================================

loc_1A962:				; XREF: Obj86_Index
		move.b	#2,$1C(a0)
		tst.w	$38(a0)
		bne.s	loc_1A97E
		move.b	#2,$24(a0)
		movea.l	$34(a0),a1
		move.w	#-1,$32(a1)

loc_1A97E:
		bra.w	loc_1A86C
; ===========================================================================

loc_1A982:				; XREF: Obj86_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj86_Index2(pc,d0.w),d0
		jsr	Obj86_Index2(pc,d0.w)
		lea	Ani_obj86a(pc),a1
		jsr	AnimateSprite
		jmp	DisplaySprite
; ===========================================================================
Obj86_Index2:	dc.w loc_1A9A6-Obj86_Index2
		dc.w loc_1A9C0-Obj86_Index2
		dc.w loc_1AA1E-Obj86_Index2
; ===========================================================================

loc_1A9A6:				; XREF: Obj86_Index2
		move.w	$30(a0),d0
		sub.w	8(a0),d0
		asl.w	#4,d0
		move.w	d0,$10(a0)
		move.w	#$B4,$28(a0)
		addq.b	#2,$25(a0)
		rts
; ===========================================================================

loc_1A9C0:				; XREF: Obj86_Index2
		tst.w	$10(a0)
		beq.s	loc_1A9E6
		jsr	SpeedToPos
		move.w	8(a0),d0
		sub.w	$30(a0),d0
		bcc.s	loc_1A9E6
		clr.w	$10(a0)
		add.w	d0,8(a0)
		movea.l	$34(a0),a1
		subq.w	#1,$32(a1)

loc_1A9E6:
		move.b	#0,$1C(a0)
		subq.w	#1,$28(a0)
		bne.s	locret_1AA1C
		addq.b	#2,$25(a0)
		move.b	#1,$1C(a0)
		move.b	#$9A,$20(a0)
		move.w	#$B4,$28(a0)
		moveq	#0,d0
		move.w	($FFFFD008).w,d0
		sub.w	8(a0),d0
		move.w	d0,$10(a0)
		move.w	#$140,$12(a0)

locret_1AA1C:
		rts
; ===========================================================================

loc_1AA1E:				; XREF: Obj86_Index2
		jsr	SpeedToPos
		cmpi.w	#$5E0,$C(a0)
		bcc.s	loc_1AA34
		subq.w	#1,$28(a0)
		beq.s	loc_1AA34
		rts
; ===========================================================================

loc_1AA34:
		movea.l	$34(a0),a1
		subq.w	#1,$38(a1)
		bra.w	Obj84_Delete
; ===========================================================================
Ani_obj86:
	include "_anim\obj86.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - energy ball	launcher (FZ)
; ---------------------------------------------------------------------------
Map_obj86:
	include "_maps\obj86.asm"

Ani_obj86a:
	include "_anim\obj86a.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - energy balls (FZ)
; ---------------------------------------------------------------------------
Map_obj86a:
	include "_maps\obj86a.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3E - prison capsule
; ---------------------------------------------------------------------------

Obj3E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj3E_Index(pc,d0.w),d1
		jsr	Obj3E_Index(pc,d1.w)
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	($FFFFF700).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj3E_Delete
		jmp	DisplaySprite
; ===========================================================================

Obj3E_Delete:
		jmp	DeleteObject
; ===========================================================================
Obj3E_Index:	dc.w Obj3E_Main-Obj3E_Index
		dc.w Obj3E_BodyMain-Obj3E_Index
		dc.w Obj3E_Switched-Obj3E_Index
		dc.w Obj3E_Explosion-Obj3E_Index
		dc.w Obj3E_Explosion-Obj3E_Index
		dc.w Obj3E_Explosion-Obj3E_Index
		dc.w Obj3E_Animals-Obj3E_Index
		dc.w Obj3E_EndAct-Obj3E_Index

Obj3E_Var:	dc.b 2,	$20, 4,	0	; routine, width, priority, frame
		dc.b 4,	$C, 5, 1
		dc.b 6,	$10, 4,	3
		dc.b 8,	$10, 3,	5
; ===========================================================================

Obj3E_Main:				; XREF: Obj3E_Index
		move.l	#Map_obj3E,4(a0)
		move.w	#$49D,2(a0)
		move.b	#4,1(a0)
		move.w	$C(a0),$30(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		lsl.w	#2,d0
		lea	Obj3E_Var(pc,d0.w),a1
		move.b	(a1)+,$24(a0)
		move.b	(a1)+,$19(a0)
		move.b	(a1)+,$18(a0)
		move.b	(a1)+,$1A(a0)
		cmpi.w	#8,d0		; is object type number	02?
		bne.s	Obj3E_Not02	; if not, branch
		move.b	#6,$20(a0)
		move.b	#8,$21(a0)

Obj3E_Not02:
		rts
; ===========================================================================

Obj3E_BodyMain:				; XREF: Obj3E_Index
		cmpi.b	#2,($FFFFF7A7).w
		beq.s	Obj3E_ChkOpened
		move.w	#$2B,d1
		move.w	#$18,d2
		move.w	#$18,d3
		move.w	8(a0),d4
		jmp	SolidObject
; ===========================================================================

Obj3E_ChkOpened:
		tst.b	$25(a0)		; has the prison been opened?
		beq.s	Obj3E_DoOpen	; if yes, branch
		clr.b	$25(a0)
		bclr	#3,($FFFFD022).w
		bset	#1,($FFFFD022).w

Obj3E_DoOpen:
		move.b	#2,$1A(a0)	; use frame number 2 (destroyed	prison)
		rts
; ===========================================================================

Obj3E_Switched:				; XREF: Obj3E_Index
		move.w	#$17,d1
		move.w	#8,d2
		move.w	#8,d3
		move.w	8(a0),d4
		jsr	SolidObject
		lea	(Ani_obj3E).l,a1
		jsr	AnimateSprite
		move.w	$30(a0),$C(a0)
		tst.b	$25(a0)
		beq.s	locret_1AC60
		addq.w	#8,$C(a0)
		move.b	#$A,$24(a0)
		move.w	#$3C,$1E(a0)
		clr.b	($FFFFFE1E).w	; stop time counter
		clr.b	($FFFFF7AA).w	; lock screen position
		move.b	#1,($FFFFF7CC).w ; lock	controls
		move.w	#$800,($FFFFF602).w ; make Sonic run to	the right
		clr.b	$25(a0)
		bclr	#3,($FFFFD022).w
		bset	#1,($FFFFD022).w

locret_1AC60:
		rts
; ===========================================================================

Obj3E_Explosion:			; XREF: Obj3E_Index
		moveq	#7,d0
		and.b	($FFFFFE0F).w,d0
		bne.s	loc_1ACA0
		jsr	SingleObjLoad
		bne.s	loc_1ACA0
		move.b	#$3F,0(a1)	; load explosion object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		jsr	(RandomNumber).l
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,8(a1)
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,$C(a1)

loc_1ACA0:
		subq.w	#1,$1E(a0)
		beq.s	Obj3E_MakeAnimal
		rts
; ===========================================================================

Obj3E_MakeAnimal:
		move.b	#2,($FFFFF7A7).w
		move.b	#$C,$24(a0)	; replace explosions with animals
		move.b	#6,$1A(a0)
		move.w	#$96,$1E(a0)
		addi.w	#$20,$C(a0)
		moveq	#7,d6
		move.w	#$9A,d5
		moveq	#-$1C,d4

Obj3E_Loop:
		jsr	SingleObjLoad
		bne.s	locret_1ACF8
		move.b	#$28,0(a1)	; load animal object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		add.w	d4,8(a1)
		addq.w	#7,d4
		move.w	d5,$36(a1)
		subq.w	#8,d5
		dbf	d6,Obj3E_Loop	; repeat 7 more	times

locret_1ACF8:
		rts
; ===========================================================================

Obj3E_Animals:				; XREF: Obj3E_Index
		moveq	#7,d0
		and.b	($FFFFFE0F).w,d0
		bne.s	loc_1AD38
		jsr	SingleObjLoad
		bne.s	loc_1AD38
		move.b	#$28,0(a1)	; load animal object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		jsr	(RandomNumber).l
		andi.w	#$1F,d0
		subq.w	#6,d0
		tst.w	d1
		bpl.s	loc_1AD2E
		neg.w	d0

loc_1AD2E:
		add.w	d0,8(a1)
		move.w	#$C,$36(a1)

loc_1AD38:
		subq.w	#1,$1E(a0)
		bne.s	locret_1AD48
		addq.b	#2,$24(a0)
		move.w	#180,$1E(a0)

locret_1AD48:
		rts
; ===========================================================================

Obj3E_EndAct:				; XREF: Obj3E_Index
		moveq	#$3E,d0
		moveq	#$28,d1
		moveq	#$40,d2
		lea	($FFFFD040).w,a1 ; load	object RAM

Obj3E_FindObj28:
		cmp.b	(a1),d1		; is object $28	(animal) loaded?
		beq.s	Obj3E_Obj28Found ; if yes, branch
		adda.w	d2,a1		; next object RAM
		dbf	d0,Obj3E_FindObj28 ; repeat $3E	times

		jsr	GotThroughAct
		jmp	DeleteObject
; ===========================================================================

Obj3E_Obj28Found:
		rts
; ===========================================================================
Ani_obj3E:
	include "_anim\obj3E.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - prison capsule
; ---------------------------------------------------------------------------
Map_obj3E:
	include "_maps\obj3E.asm"

; ---------------------------------------------------------------------------
; Object touch response	subroutine - $20(a0) in	the object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


TouchResponse:				; XREF: Obj01
		nop
		move.w	8(a0),d2	; load Sonic's x-axis value
		move.w	$C(a0),d3	; load Sonic's y-axis value
		subq.w	#8,d2
		moveq	#0,d5
		move.b	$16(a0),d5	; load Sonic's height
		subq.b	#3,d5
		sub.w	d5,d3
		cmpi.b	#$39,$1A(a0)	; is Sonic ducking?
		bne.s	Touch_NoDuck	; if not, branch
		addi.w	#$C,d3
		moveq	#$A,d5

Touch_NoDuck:
		move.w	#$10,d4
		add.w	d5,d5
		lea	($FFFFD800).w,a1 ; begin checking the object RAM
		move.w	#$5F,d6

Touch_Loop:
		tst.b	1(a1)
		bpl.s	Touch_NextObj
		move.b	$20(a1),d0	; load touch response number
		bne.s	Touch_Height	; if touch response is not 0, branch

Touch_NextObj:
		lea	$40(a1),a1	; next object RAM
		dbf	d6,Touch_Loop	; repeat $5F more times

		moveq	#0,d0
		rts
; ===========================================================================
Touch_Sizes:	dc.b  $14, $14		; width, height
		dc.b   $C, $14
		dc.b  $14,  $C
		dc.b	4, $10
		dc.b   $C, $12
		dc.b  $10, $10
		dc.b	6,   6
		dc.b  $18,  $C
		dc.b   $C, $10
		dc.b  $10,  $C
		dc.b	8,   8
		dc.b  $14, $10
		dc.b  $14,   8
		dc.b   $E,  $E
		dc.b  $18, $18
		dc.b  $28, $10
		dc.b  $10, $18
		dc.b	8, $10
		dc.b  $20, $70
		dc.b  $40, $20
		dc.b  $80, $20
		dc.b  $20, $20
		dc.b	8,   8
		dc.b	4,   4
		dc.b  $20,   8
		dc.b   $C,  $C
		dc.b	8,   4
		dc.b  $18,   4
		dc.b  $28,   4
		dc.b	4,   8
		dc.b	4, $18
		dc.b	4, $28
		dc.b	4, $20
		dc.b  $18, $18
		dc.b   $C, $18
		dc.b  $48,   8
; ===========================================================================

Touch_Height:				; XREF: TouchResponse
		andi.w	#$3F,d0
		add.w	d0,d0
		lea	Touch_Sizes-2(pc,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	8(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	loc_1AE98
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	Touch_Width
		bra.w	Touch_NextObj
; ===========================================================================

loc_1AE98:
		cmp.w	d4,d0
		bhi.w	Touch_NextObj

Touch_Width:
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	$C(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	loc_1AEB6
		add.w	d1,d1
		add.w	d0,d1
		bcs.s	Touch_ChkValue
		bra.w	Touch_NextObj
; ===========================================================================

loc_1AEB6:
		cmp.w	d5,d0
		bhi.w	Touch_NextObj

Touch_ChkValue:
		move.b	$20(a1),d1	; load touch response number
		andi.b	#$C0,d1		; is touch response $40	or higher?
		beq.w	Touch_Enemy	; if not, branch
		cmpi.b	#$C0,d1		; is touch response $C0	or higher?
		beq.w	Touch_Special	; if yes, branch
		tst.b	d1		; is touch response $80-$BF ?
		bmi.w	Touch_ChkHurt	; if yes, branch

; touch	response is $40-$7F

		move.b	$20(a1),d0
		andi.b	#$3F,d0
		cmpi.b	#6,d0		; is touch response $46	?
		beq.s	Touch_Monitor	; if yes, branch
		cmpi.w	#$5A,$30(a0)
		bcc.w	locret_1AEF2
		addq.b	#2,$24(a1)	; advance the object's routine counter

locret_1AEF2:
		rts
; ===========================================================================

Touch_Monitor:
		tst.w	$12(a0)		; is Sonic moving upwards?
		bpl.s	loc_1AF1E	; if not, branch
		move.w	$C(a0),d0
		subi.w	#$10,d0
		cmp.w	$C(a1),d0
		bcs.s	locret_1AF2E
		neg.w	$12(a0)		; reverse Sonic's y-motion
		move.w	#-$180,$12(a1)
		tst.b	$25(a1)
		bne.s	locret_1AF2E
		addq.b	#4,$25(a1)	; advance the monitor's routine counter
		rts
; ===========================================================================

loc_1AF1E:
		cmpi.b	#2,$1C(a0)	; is Sonic rolling/jumping?
		bne.s	locret_1AF2E
		neg.w	$12(a0)		; reverse Sonic's y-motion
		addq.b	#2,$24(a1)	; advance the monitor's routine counter

locret_1AF2E:
		rts
; ===========================================================================

Touch_Enemy:				; XREF: Touch_ChkValue
		tst.b	($FFFFFE2D).w	; is Sonic invincible?
		bne.s	loc_1AF40	; if yes, branch
		cmpi.b	#2,$1C(a0)	; is Sonic rolling?
		bne.w	Touch_ChkHurt	; if not, branch

loc_1AF40:
		tst.b	$21(a1)
		beq.s	Touch_KillEnemy
		neg.w	$10(a0)
		neg.w	$12(a0)
		asr	$10(a0)
		asr	$12(a0)
		move.b	#0,$20(a1)
		subq.b	#1,$21(a1)
		bne.s	locret_1AF68
		bset	#7,$22(a1)

locret_1AF68:
		rts
; ===========================================================================

Touch_KillEnemy:
		bset	#7,$22(a1)
		moveq	#0,d0
		move.w	($FFFFF7D0).w,d0
		addq.w	#2,($FFFFF7D0).w ; add 2 to item bonus counter
		cmpi.w	#6,d0
		bcs.s	loc_1AF82
		moveq	#6,d0

loc_1AF82:
		move.w	d0,$3E(a1)
		move.w	Enemy_Points(pc,d0.w),d0
		cmpi.w	#$20,($FFFFF7D0).w ; have 16 enemies been destroyed?
		bcs.s	loc_1AF9C	; if not, branch
		move.w	#1000,d0	; fix bonus to 10000
		move.w	#$A,$3E(a1)

loc_1AF9C:
		bsr.w	AddPoints
		move.b	#$27,0(a1)	; change object	to points
		move.b	#0,$24(a1)
		tst.w	$12(a0)
		bmi.s	loc_1AFC2
		move.w	$C(a0),d0
		cmp.w	$C(a1),d0
		bcc.s	loc_1AFCA
		neg.w	$12(a0)
		rts
; ===========================================================================

loc_1AFC2:
		addi.w	#$100,$12(a0)
		rts
; ===========================================================================

loc_1AFCA:
		subi.w	#$100,$12(a0)
		rts
; ===========================================================================
Enemy_Points:	dc.w 10, 20, 50, 100
; ===========================================================================

loc_1AFDA:				; XREF: Touch_CatKiller
		bset	#7,$22(a1)

Touch_ChkHurt:				; XREF: Touch_ChkValue
		tst.b	($FFFFFE2D).w	; is Sonic invincible?
		beq.s	Touch_Hurt	; if not, branch

loc_1AFE6:				; XREF: Touch_Hurt
		moveq	#-1,d0
		rts
; ===========================================================================

Touch_Hurt:				; XREF: Touch_ChkHurt
		nop
		tst.w	$30(a0)
		bne.s	loc_1AFE6
		movea.l	a1,a2

; End of function TouchResponse
; continue straight to HurtSonic

; ---------------------------------------------------------------------------
; Hurting Sonic	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HurtSonic:
		tst.b	($FFFFFE2C).w	; does Sonic have a shield?
		bne.s	Hurt_Shield	; if yes, branch
		tst.w	($FFFFFE20).w	; does Sonic have any rings?
		beq.w	Hurt_NoRings	; if not, branch
		jsr	SingleObjLoad
		bne.s	Hurt_Shield
		move.b	#$37,0(a1)	; load bouncing	multi rings object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

Hurt_Shield:
		move.b	#0,($FFFFFE2C).w ; remove shield
		move.b	#4,$24(a0)
		bsr.w	Sonic_ResetOnFloor
		bset	#1,$22(a0)
		move.w	#-$400,$12(a0)	; make Sonic bounce away from the object
		move.w	#-$200,$10(a0)
		btst	#6,$22(a0)
		beq.s	Hurt_Reverse
		move.w	#-$200,$12(a0)
		move.w	#-$100,$10(a0)

Hurt_Reverse:
		move.w	8(a0),d0
		cmp.w	8(a2),d0
		bcs.s	Hurt_ChkSpikes	; if Sonic is left of the object, branch
		neg.w	$10(a0)		; if Sonic is right of the object, reverse

Hurt_ChkSpikes:
		move.w	#0,$14(a0)
		move.b	#$1A,$1C(a0)
		move.w	#$78,$30(a0)
		moveq	#sfx_Death,d0	; load normal damage sound
		cmpi.b	#$36,(a2)	; was damage caused by spikes?
		bne.s	Hurt_Sound	; if not, branch
		cmpi.b	#$16,(a2)	; was damage caused by LZ harpoon?
		bne.s	Hurt_Sound	; if not, branch
		moveq	#sfx_SpikeHit,d0; load spikes damage sound

Hurt_Sound:
		jsr	(PlaySound_Special).l
		moveq	#-1,d0
		rts
; ===========================================================================

Hurt_NoRings:
		tst.w	($FFFFFFFA).w	; is debug mode	cheat on?
		bne.w	Hurt_Shield	; if yes, branch
; End of function HurtSonic

; ---------------------------------------------------------------------------
; Subroutine to	kill Sonic
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


KillSonic:
		tst.w	($FFFFFE08).w	; is debug mode	active?
		bne.s	Kill_NoDeath	; if yes, branch
		move.b	#0,($FFFFFE2D).w ; remove invincibility
		move.b	#6,$24(a0)
		bsr.w	Sonic_ResetOnFloor
		bset	#1,$22(a0)
		move.w	#-$700,$12(a0)
		move.w	#0,$10(a0)
		move.w	#0,$14(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$18,$1C(a0)
		bset	#7,2(a0)
		moveq	#sfx_Death,d0	; play normal death sound
		cmpi.b	#$36,(a2)	; check	if you were killed by spikes
		bne.s	Kill_Sound
		moveq	#sfx_SpikeHit,d0; play spikes death sound

Kill_Sound:
		jsr	(PlaySound_Special).l

Kill_NoDeath:
		moveq	#-1,d0
		rts
; End of function KillSonic


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Touch_Special:				; XREF: Touch_ChkValue
		move.b	$20(a1),d1
		andi.b	#$3F,d1
		cmpi.b	#$B,d1		; is touch response $CB	?
		beq.s	Touch_CatKiller	; if yes, branch
		cmpi.b	#$C,d1		; is touch response $CC	?
		beq.s	Touch_Yadrin	; if yes, branch
		cmpi.b	#$17,d1		; is touch response $D7	?
		beq.s	Touch_D7orE1	; if yes, branch
		cmpi.b	#$21,d1		; is touch response $E1	?
		beq.s	Touch_D7orE1	; if yes, branch
		rts
; ===========================================================================

Touch_CatKiller:			; XREF: Touch_Special
		bra.w	loc_1AFDA
; ===========================================================================

Touch_Yadrin:				; XREF: Touch_Special
		sub.w	d0,d5
		cmpi.w	#8,d5
		bcc.s	loc_1B144
		move.w	8(a1),d0
		subq.w	#4,d0
		btst	#0,$22(a1)
		beq.s	loc_1B130
		subi.w	#$10,d0

loc_1B130:
		sub.w	d2,d0
		bcc.s	loc_1B13C
		addi.w	#$18,d0
		bcs.s	loc_1B140
		bra.s	loc_1B144
; ===========================================================================

loc_1B13C:
		cmp.w	d4,d0
		bhi.s	loc_1B144

loc_1B140:
		bra.w	Touch_ChkHurt
; ===========================================================================

loc_1B144:
		bra.w	Touch_Enemy
; ===========================================================================

Touch_D7orE1:				; XREF: Touch_Special
		addq.b	#1,$21(a1)
		rts
; End of function Touch_Special

; ---------------------------------------------------------------------------
; Subroutine to	show the special stage layout
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_ShowLayout:				; XREF: SpecialStage
		bsr.w	SS_AniWallsRings
		bsr.w	SS_AniItems
		move.w	d5,-(sp)
		lea	($FFFF8000).w,a1
		move.b	($FFFFF780).w,d0
		andi.b	#$FC,d0
		jsr	(CalcSine).l
		move.w	d0,d4
		move.w	d1,d5
		muls.w	#$18,d4
		muls.w	#$18,d5
		moveq	#0,d2
		move.w	($FFFFF700).w,d2
		divu.w	#$18,d2
		swap	d2
		neg.w	d2
		addi.w	#-$B4,d2
		moveq	#0,d3
		move.w	($FFFFF704).w,d3
		divu.w	#$18,d3
		swap	d3
		neg.w	d3
		addi.w	#-$B4,d3
		move.w	#$F,d7

loc_1B19E:
		movem.w	d0-d2,-(sp)
		movem.w	d0-d1,-(sp)
		neg.w	d0
		muls.w	d2,d1
		muls.w	d3,d0
		move.l	d0,d6
		add.l	d1,d6
		movem.w	(sp)+,d0-d1
		muls.w	d2,d0
		muls.w	d3,d1
		add.l	d0,d1
		move.l	d6,d2
		move.w	#$F,d6

loc_1B1C0:
		move.l	d2,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		move.l	d1,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		add.l	d5,d2
		add.l	d4,d1
		dbf	d6,loc_1B1C0

		movem.w	(sp)+,d0-d2
		addi.w	#$18,d3
		dbf	d7,loc_1B19E

		move.w	(sp)+,d5
		lea	($FF0000).l,a0
		moveq	#0,d0
		move.w	($FFFFF704).w,d0
		divu.w	#$18,d0
		mulu.w	#$80,d0
		adda.l	d0,a0
		moveq	#0,d0
		move.w	($FFFFF700).w,d0
		divu.w	#$18,d0
		adda.w	d0,a0
		lea	($FFFF8000).w,a4
		move.w	#$F,d7

loc_1B20C:
		move.w	#$F,d6

loc_1B210:
		moveq	#0,d0
		move.b	(a0)+,d0
		beq.s	loc_1B268
		cmpi.b	#$4E,d0
		bhi.s	loc_1B268
		move.w	(a4),d3
		addi.w	#$120,d3
		cmpi.w	#$70,d3
		bcs.s	loc_1B268
		cmpi.w	#$1D0,d3
		bcc.s	loc_1B268
		move.w	2(a4),d2
		addi.w	#$F0,d2
		cmpi.w	#$70,d2
		bcs.s	loc_1B268
		cmpi.w	#$170,d2
		bcc.s	loc_1B268
		lea	($FF4000).l,a5
		lsl.w	#3,d0
		lea	(a5,d0.w),a5
		movea.l	(a5)+,a1
		move.w	(a5)+,d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		movea.w	(a5)+,a3
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	loc_1B268
		jsr	sub_D762

loc_1B268:
		addq.w	#4,a4
		dbf	d6,loc_1B210

		lea	$70(a0),a0
		dbf	d7,loc_1B20C

		move.b	d5,($FFFFF62C).w
		cmpi.b	#$50,d5
		beq.s	loc_1B288
		move.l	#0,(a2)
		rts
; ===========================================================================

loc_1B288:
		move.b	#0,-5(a2)
		rts
; End of function SS_ShowLayout

; ---------------------------------------------------------------------------
; Subroutine to	animate	walls and rings	in the special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_AniWallsRings:			; XREF: SS_ShowLayout
		lea	($FF400C).l,a1
		moveq	#0,d0
		move.b	($FFFFF780).w,d0
		lsr.b	#2,d0
		andi.w	#$F,d0
		moveq	#$23,d1

loc_1B2A4:
		move.w	d0,(a1)
		addq.w	#8,a1
		dbf	d1,loc_1B2A4

		lea	($FF4005).l,a1
		subq.b	#1,($FFFFFEC2).w
		bpl.s	loc_1B2C8
		move.b	#7,($FFFFFEC2).w
		addq.b	#1,($FFFFFEC3).w
		andi.b	#3,($FFFFFEC3).w

loc_1B2C8:
		move.b	($FFFFFEC3).w,$1D0(a1)
		subq.b	#1,($FFFFFEC4).w
		bpl.s	loc_1B2E4
		move.b	#7,($FFFFFEC4).w
		addq.b	#1,($FFFFFEC5).w
		andi.b	#1,($FFFFFEC5).w

loc_1B2E4:
		move.b	($FFFFFEC5).w,d0
		move.b	d0,$138(a1)
		move.b	d0,$160(a1)
		move.b	d0,$148(a1)
		move.b	d0,$150(a1)
		move.b	d0,$1D8(a1)
		move.b	d0,$1E0(a1)
		move.b	d0,$1E8(a1)
		move.b	d0,$1F0(a1)
		move.b	d0,$1F8(a1)
		move.b	d0,$200(a1)
		subq.b	#1,($FFFFFEC6).w
		bpl.s	loc_1B326
		move.b	#4,($FFFFFEC6).w
		addq.b	#1,($FFFFFEC7).w
		andi.b	#3,($FFFFFEC7).w

loc_1B326:
		move.b	($FFFFFEC7).w,d0
		move.b	d0,$168(a1)
		move.b	d0,$170(a1)
		move.b	d0,$178(a1)
		move.b	d0,$180(a1)
		subq.b	#1,($FFFFFEC0).w
		bpl.s	loc_1B350
		move.b	#7,($FFFFFEC0).w
		subq.b	#1,($FFFFFEC1).w
		andi.b	#7,($FFFFFEC1).w

loc_1B350:
		lea	($FF4016).l,a1
		lea	(SS_WaRiVramSet).l,a0
		moveq	#0,d0
		move.b	($FFFFFEC1).w,d0
		add.w	d0,d0
		lea	(a0,d0.w),a0
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		rts
; End of function SS_AniWallsRings

; ===========================================================================
SS_WaRiVramSet:	dc.w $142, $6142, $142,	$142, $142, $142, $142,	$6142
		dc.w $142, $6142, $142,	$142, $142, $142, $142,	$6142
		dc.w $2142, $142, $2142, $2142,	$2142, $2142, $2142, $142
		dc.w $2142, $142, $2142, $2142,	$2142, $2142, $2142, $142
		dc.w $4142, $2142, $4142, $4142, $4142,	$4142, $4142, $2142
		dc.w $4142, $2142, $4142, $4142, $4142,	$4142, $4142, $2142
		dc.w $6142, $4142, $6142, $6142, $6142,	$6142, $6142, $4142
		dc.w $6142, $4142, $6142, $6142, $6142,	$6142, $6142, $4142
; ---------------------------------------------------------------------------
; Subroutine to	remove items when you collect them in the special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_RemoveCollectedItem:			; XREF: Obj09_ChkItems
		lea	($FF4400).l,a2
		move.w	#$1F,d0

loc_1B4C4:
		tst.b	(a2)
		beq.s	locret_1B4CE
		addq.w	#8,a2
		dbf	d0,loc_1B4C4

locret_1B4CE:
		rts
; End of function SS_RemoveCollectedItem

; ---------------------------------------------------------------------------
; Subroutine to	animate	special	stage items when you touch them
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_AniItems:				; XREF: SS_ShowLayout
		lea	($FF4400).l,a0
		move.w	#$1F,d7

loc_1B4DA:
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	loc_1B4E8
		lsl.w	#2,d0
		movea.l	SS_AniIndex-4(pc,d0.w),a1
		jsr	(a1)

loc_1B4E8:
		addq.w	#8,a0

loc_1B4EA:
		dbf	d7,loc_1B4DA

		rts
; End of function SS_AniItems

; ===========================================================================
SS_AniIndex:	dc.l SS_AniRingSparks
		dc.l SS_AniBumper
		dc.l SS_Ani1Up
		dc.l SS_AniReverse
		dc.l SS_AniEmeraldSparks
		dc.l SS_AniGlassBlock
; ===========================================================================

SS_AniRingSparks:			; XREF: SS_AniIndex
		subq.b	#1,2(a0)
		bpl.s	locret_1B530
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniRingData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B530
		clr.l	(a0)
		clr.l	4(a0)

locret_1B530:
		rts
; ===========================================================================
SS_AniRingData:	dc.b $42, $43, $44, $45, 0, 0
; ===========================================================================

SS_AniBumper:				; XREF: SS_AniIndex
		subq.b	#1,2(a0)
		bpl.s	locret_1B566
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniBumpData(pc,d0.w),d0
		bne.s	loc_1B564
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$25,(a1)
		rts
; ===========================================================================

loc_1B564:
		move.b	d0,(a1)

locret_1B566:
		rts
; ===========================================================================
SS_AniBumpData:	dc.b $32, $33, $32, $33, 0, 0
; ===========================================================================

SS_Ani1Up:				; XREF: SS_AniIndex
		subq.b	#1,2(a0)
		bpl.s	locret_1B596
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_Ani1UpData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B596
		clr.l	(a0)
		clr.l	4(a0)

locret_1B596:
		rts
; ===========================================================================
SS_Ani1UpData:	dc.b $46, $47, $48, $49, 0, 0
; ===========================================================================

SS_AniReverse:				; XREF: SS_AniIndex
		subq.b	#1,2(a0)
		bpl.s	locret_1B5CC
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniRevData(pc,d0.w),d0
		bne.s	loc_1B5CA
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$2B,(a1)
		rts
; ===========================================================================

loc_1B5CA:
		move.b	d0,(a1)

locret_1B5CC:
		rts
; ===========================================================================
SS_AniRevData:	dc.b $2B, $31, $2B, $31, 0, 0
; ===========================================================================

SS_AniEmeraldSparks:			; XREF: SS_AniIndex
		subq.b	#1,2(a0)
		bpl.s	locret_1B60C
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniEmerData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B60C
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#4,($FFFFD024).w
		moveq	#sfx_Goal,d0
		jsr	(PlaySound_Special).l ;	play special stage GOAL	sound

locret_1B60C:
		rts
; ===========================================================================
SS_AniEmerData:	dc.b $46, $47, $48, $49, 0, 0
; ===========================================================================

SS_AniGlassBlock:			; XREF: SS_AniIndex
		subq.b	#1,2(a0)
		bpl.s	locret_1B640
		move.b	#1,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniGlassData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B640
		move.b	4(a0),(a1)
		clr.l	(a0)
		clr.l	4(a0)

locret_1B640:
		rts
; ===========================================================================
SS_AniGlassData:dc.b $4B, $4C, $4D, $4E, $4B, $4C, $4D,	$4E, 0,	0
; ---------------------------------------------------------------------------
; Special stage	layout pointers
; ---------------------------------------------------------------------------
SS_LayoutIndex:
	include "_inc\Special stage layout pointers.asm"

; ---------------------------------------------------------------------------
; Special stage	start locations
; ---------------------------------------------------------------------------
SS_StartLoc:	incbin	misc\sloc_ss.bin
		even

; ---------------------------------------------------------------------------
; Subroutine to	load special stage layout
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_Load:				; XREF: SpecialStage
		moveq	#0,d0
		move.b	($FFFFFE16).w,d0 ; load	number of last special stage entered
		addq.b	#1,($FFFFFE16).w
		cmpi.b	#6,($FFFFFE16).w
		bcs.s	SS_ChkEmldNum
		move.b	#0,($FFFFFE16).w ; reset if higher than	6

SS_ChkEmldNum:
		cmpi.b	#6,($FFFFFE57).w ; do you have all emeralds?
		beq.s	SS_LoadData	; if yes, branch
		moveq	#0,d1
		move.b	($FFFFFE57).w,d1
		subq.b	#1,d1
		bcs.s	SS_LoadData
		lea	($FFFFFE58).w,a3 ; check which emeralds	you have

SS_ChkEmldLoop:
		cmp.b	(a3,d1.w),d0
		bne.s	SS_ChkEmldRepeat
		bra.s	SS_Load
; ===========================================================================

SS_ChkEmldRepeat:
		dbf	d1,SS_ChkEmldLoop

SS_LoadData:
		lsl.w	#2,d0
		lea	SS_StartLoc(pc,d0.w),a1
		move.w	(a1)+,($FFFFD008).w
		move.w	(a1)+,($FFFFD00C).w
		movea.l	SS_LayoutIndex(pc,d0.w),a0
		lea	($FF4000).l,a1
		move.w	#0,d0
		jsr	(EniDec).l
		lea	($FF0000).l,a1
		move.w	#$FFF,d0

SS_ClrRAM3:
		clr.l	(a1)+
		dbf	d0,SS_ClrRAM3

		lea	($FF1020).l,a1
		lea	($FF4000).l,a0
		moveq	#$3F,d1

loc_1B6F6:
		moveq	#$3F,d2

loc_1B6F8:
		move.b	(a0)+,(a1)+
		dbf	d2,loc_1B6F8

		lea	$40(a1),a1
		dbf	d1,loc_1B6F6

		lea	($FF4008).l,a1
		lea	(SS_MapIndex).l,a0
		moveq	#$4D,d1

loc_1B714:
		move.l	(a0)+,(a1)+
		move.w	#0,(a1)+
		move.b	-4(a0),-1(a1)
		move.w	(a0)+,(a1)+
		dbf	d1,loc_1B714

		lea	($FF4400).l,a1
		move.w	#$3F,d1

loc_1B730:

		clr.l	(a1)+
		dbf	d1,loc_1B730

		rts
; End of function SS_Load

; ===========================================================================
; ---------------------------------------------------------------------------
; Special stage	mappings and VRAM pointers
; ---------------------------------------------------------------------------
SS_MapIndex:
	include "_inc\Special stage mappings and VRAM pointers.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - special stage "R" block
; ---------------------------------------------------------------------------
Map_SS_R:
	include "_maps\SSRblock.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - special stage breakable glass blocks and red-white blocks
; ---------------------------------------------------------------------------
Map_SS_Glass:
	include "_maps\SSglassblock.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - special stage "UP" block
; ---------------------------------------------------------------------------
Map_SS_Up:
	include "_maps\SSUPblock.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - special stage "DOWN" block
; ---------------------------------------------------------------------------
Map_SS_Down:
	include "_maps\SSDOWNblock.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - special stage chaos	emeralds
; ---------------------------------------------------------------------------
Map_SS_Chaos1:	dc.w byte_1B96C-Map_SS_Chaos1
		dc.w byte_1B97E-Map_SS_Chaos1
Map_SS_Chaos2:	dc.w byte_1B972-Map_SS_Chaos2
		dc.w byte_1B97E-Map_SS_Chaos2
Map_SS_Chaos3:	dc.w byte_1B978-Map_SS_Chaos3
		dc.w byte_1B97E-Map_SS_Chaos3
byte_1B96C:	dc.b 1
		dc.b $F8, 5, 0,	0, $F8
byte_1B972:	dc.b 1
		dc.b $F8, 5, 0,	4, $F8
byte_1B978:	dc.b 1
		dc.b $F8, 5, 0,	8, $F8
byte_1B97E:	dc.b 1
		dc.b $F8, 5, 0,	$C, $F8
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 09 - Sonic (special stage)
; ---------------------------------------------------------------------------

Obj09:					; XREF: Obj_Index
		tst.w	($FFFFFE08).w	; is debug mode	being used?
		beq.s	Obj09_Normal	; if not, branch
		bsr.w	SS_FixCamera
		bra.w	DebugMode
; ===========================================================================

Obj09_Normal:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj09_Index(pc,d0.w),d1
		jmp	Obj09_Index(pc,d1.w)
; ===========================================================================
Obj09_Index:	dc.w Obj09_Main-Obj09_Index
		dc.w Obj09_ChkDebug-Obj09_Index
		dc.w Obj09_ExitStage-Obj09_Index
		dc.w Obj09_Exit2-Obj09_Index
; ===========================================================================

Obj09_Main:				; XREF: Obj09_Index
		addq.b	#2,$24(a0)
		move.b	#$E,$16(a0)
		move.b	#7,$17(a0)
		move.l	#Map_Sonic,4(a0)
		move.w	#$780,2(a0)
		move.b	#4,1(a0)
		move.b	#0,$18(a0)
		move.b	#2,$1C(a0)
		bset	#2,$22(a0)
		bset	#1,$22(a0)

Obj09_ChkDebug:				; XREF: Obj09_Index
		tst.w	($FFFFFFFA).w	; is debug mode	cheat enabled?
		beq.s	Obj09_NoDebug	; if not, branch
		btst	#4,($FFFFF605).w ; is button B pressed?
		beq.s	Obj09_NoDebug	; if not, branch
		move.w	#1,($FFFFFE08).w ; change Sonic	into a ring

Obj09_NoDebug:
		move.b	#0,$30(a0)
		moveq	#0,d0
		move.b	$22(a0),d0
		andi.w	#2,d0
		move.w	Obj09_Modes(pc,d0.w),d1
		jsr	Obj09_Modes(pc,d1.w)
		jsr	LoadSonicDynPLC
		jmp	DisplaySprite
; ===========================================================================
Obj09_Modes:	dc.w Obj09_OnWall-Obj09_Modes
		dc.w Obj09_InAir-Obj09_Modes
; ===========================================================================

Obj09_OnWall:				; XREF: Obj09_Modes
		bsr.w	Obj09_Jump
		bsr.w	Obj09_Move
		bsr.w	Obj09_Fall
		bra.s	Obj09_Display
; ===========================================================================

Obj09_InAir:				; XREF: Obj09_Modes
		bsr.w	nullsub_2
		bsr.w	Obj09_Move
		bsr.w	Obj09_Fall

Obj09_Display:				; XREF: Obj09_OnWall
		bsr.w	Obj09_ChkItems
		bsr.w	Obj09_ChkItems2
		jsr	SpeedToPos
		bsr.w	SS_FixCamera
		move.w	($FFFFF780).w,d0
		add.w	($FFFFF782).w,d0
		move.w	d0,($FFFFF780).w
		jsr	Sonic_Animate
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_Move:				; XREF: Obj09_OnWall; Obj09_InAir
		btst	#2,($FFFFF602).w ; is left being pressed?
		beq.s	Obj09_ChkRight	; if not, branch
		bsr.w	Obj09_MoveLeft

Obj09_ChkRight:
		btst	#3,($FFFFF602).w ; is right being pressed?
		beq.s	loc_1BA78	; if not, branch
		bsr.w	Obj09_MoveRight

loc_1BA78:
		move.b	($FFFFF602).w,d0
		andi.b	#$C,d0
		bne.s	loc_1BAA8
		move.w	$14(a0),d0
		beq.s	loc_1BAA8
		bmi.s	loc_1BA9A
		subi.w	#$C,d0
		bcc.s	loc_1BA94
		move.w	#0,d0

loc_1BA94:
		move.w	d0,$14(a0)
		bra.s	loc_1BAA8
; ===========================================================================

loc_1BA9A:
		addi.w	#$C,d0
		bcc.s	loc_1BAA4
		move.w	#0,d0

loc_1BAA4:
		move.w	d0,$14(a0)

loc_1BAA8:
		move.b	($FFFFF780).w,d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		neg.b	d0
		jsr	(CalcSine).l
		muls.w	$14(a0),d1
		add.l	d1,8(a0)
		muls.w	$14(a0),d0
		add.l	d0,$C(a0)
		movem.l	d0-d1,-(sp)
		move.l	$C(a0),d2
		move.l	8(a0),d3
		bsr.w	sub_1BCE8
		beq.s	loc_1BAF2
		movem.l	(sp)+,d0-d1
		sub.l	d1,8(a0)
		sub.l	d0,$C(a0)
		move.w	#0,$14(a0)
		rts
; ===========================================================================

loc_1BAF2:
		movem.l	(sp)+,d0-d1
		rts
; End of function Obj09_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_MoveLeft:				; XREF: Obj09_Move
		bset	#0,$22(a0)
		move.w	$14(a0),d0
		beq.s	loc_1BB06
		bpl.s	loc_1BB1A

loc_1BB06:
		subi.w	#$C,d0
		cmpi.w	#-$800,d0
		bgt.s	loc_1BB14
		move.w	#-$800,d0

loc_1BB14:
		move.w	d0,$14(a0)
		rts
; ===========================================================================

loc_1BB1A:
		subi.w	#$40,d0
		bcc.s	loc_1BB22
		nop

loc_1BB22:
		move.w	d0,$14(a0)
		rts
; End of function Obj09_MoveLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_MoveRight:			; XREF: Obj09_Move
		bclr	#0,$22(a0)
		move.w	$14(a0),d0
		bmi.s	loc_1BB48
		addi.w	#$C,d0
		cmpi.w	#$800,d0
		blt.s	loc_1BB42
		move.w	#$800,d0

loc_1BB42:
		move.w	d0,$14(a0)
		bra.s	locret_1BB54
; ===========================================================================

loc_1BB48:
		addi.w	#$40,d0
		bcc.s	loc_1BB50
		nop

loc_1BB50:
		move.w	d0,$14(a0)

locret_1BB54:
		rts
; End of function Obj09_MoveRight


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_Jump:				; XREF: Obj09_OnWall
		move.b	($FFFFF603).w,d0
		andi.b	#$70,d0		; is A,	B or C pressed?
		beq.s	Obj09_NoJump	; if not, branch
		move.b	($FFFFF780).w,d0
		andi.b	#$FC,d0
		neg.b	d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	#$680,d1
		asr.l	#8,d1
		move.w	d1,$10(a0)
		muls.w	#$680,d0
		asr.l	#8,d0
		move.w	d0,$12(a0)
		bset	#1,$22(a0)
		moveq	#sfx_Jump,d0
		jmp	PlaySound_Special ;	play jumping sound

Obj09_NoJump:
nullsub_2:				; XREF: Obj09_InAir
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; unused subroutine to limit Sonic's upward vertical speed
; ---------------------------------------------------------------------------
		move.w	#-$400,d1
		cmp.w	$12(a0),d1
		ble.s	locret_1BBB4
		move.b	($FFFFF602).w,d0
		andi.b	#$70,d0
		bne.s	locret_1BBB4
		move.w	d1,$12(a0)

locret_1BBB4:
		rts
; ---------------------------------------------------------------------------
; Subroutine to	fix the	camera on Sonic's position (special stage)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_FixCamera:				; XREF: Obj09
		move.w	$C(a0),d2
		move.w	8(a0),d3
		move.w	($FFFFF700).w,d0
		subi.w	#$A0,d3
		bcs.s	loc_1BBCE
		sub.w	d3,d0
		sub.w	d0,($FFFFF700).w

loc_1BBCE:
		move.w	($FFFFF704).w,d0
		subi.w	#$70,d2
		bcs.s	locret_1BBDE
		sub.w	d2,d0
		sub.w	d0,($FFFFF704).w

locret_1BBDE:
		rts
; End of function SS_FixCamera

; ===========================================================================

Obj09_ExitStage:			; XREF: Obj09_Index
		addi.w	#$40,($FFFFF782).w
		cmpi.w	#$1800,($FFFFF782).w
		bne.s	loc_1BBF4
		move.b	#$C,($FFFFF600).w

loc_1BBF4:
		cmpi.w	#$3000,($FFFFF782).w
		blt.s	loc_1BC12
		move.w	#0,($FFFFF782).w
		move.w	#$4000,($FFFFF780).w
		addq.b	#2,$24(a0)
		move.w	#$3C,$38(a0)

loc_1BC12:
		move.w	($FFFFF780).w,d0
		add.w	($FFFFF782).w,d0
		move.w	d0,($FFFFF780).w
		jsr	Sonic_Animate
		jsr	LoadSonicDynPLC
		bsr.w	SS_FixCamera
		jmp	DisplaySprite
; ===========================================================================

Obj09_Exit2:				; XREF: Obj09_Index
		subq.w	#1,$38(a0)
		bne.s	loc_1BC40
		move.b	#$C,($FFFFF600).w

loc_1BC40:
		jsr	Sonic_Animate
		jsr	LoadSonicDynPLC
		bsr.w	SS_FixCamera
		jmp	DisplaySprite

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_Fall:				; XREF: Obj09_OnWall; Obj09_InAir
		move.l	$C(a0),d2
		move.l	8(a0),d3
		move.b	($FFFFF780).w,d0
		andi.b	#$FC,d0
		jsr	(CalcSine).l
		move.w	$10(a0),d4
		ext.l	d4
		asl.l	#8,d4
		muls.w	#$2A,d0
		add.l	d4,d0
		move.w	$12(a0),d4
		ext.l	d4
		asl.l	#8,d4
		muls.w	#$2A,d1
		add.l	d4,d1
		add.l	d0,d3
		bsr.w	sub_1BCE8
		beq.s	loc_1BCB0
		sub.l	d0,d3
		moveq	#0,d0
		move.w	d0,$10(a0)
		bclr	#1,$22(a0)
		add.l	d1,d2
		bsr.w	sub_1BCE8
		beq.s	loc_1BCC6
		sub.l	d1,d2
		moveq	#0,d1
		move.w	d1,$12(a0)
		rts
; ===========================================================================

loc_1BCB0:
		add.l	d1,d2
		bsr.w	sub_1BCE8
		beq.s	loc_1BCD4
		sub.l	d1,d2
		moveq	#0,d1
		move.w	d1,$12(a0)
		bclr	#1,$22(a0)

loc_1BCC6:
		asr.l	#8,d0
		asr.l	#8,d1
		move.w	d0,$10(a0)
		move.w	d1,$12(a0)
		rts
; ===========================================================================

loc_1BCD4:
		asr.l	#8,d0
		asr.l	#8,d1
		move.w	d0,$10(a0)
		move.w	d1,$12(a0)
		bset	#1,$22(a0)
		rts
; End of function Obj09_Fall


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_1BCE8:				; XREF: Obj09_Move; Obj09_Fall
		lea	($FF0000).l,a1
		moveq	#0,d4
		swap	d2
		move.w	d2,d4
		swap	d2
		addi.w	#$44,d4
		divu.w	#$18,d4
		mulu.w	#$80,d4
		adda.l	d4,a1
		moveq	#0,d4
		swap	d3
		move.w	d3,d4
		swap	d3
		addi.w	#$14,d4
		divu.w	#$18,d4
		adda.w	d4,a1
		moveq	#0,d5
		move.b	(a1)+,d4
		bsr.s	sub_1BD30
		move.b	(a1)+,d4
		bsr.s	sub_1BD30
		adda.w	#$7E,a1
		move.b	(a1)+,d4
		bsr.s	sub_1BD30
		move.b	(a1)+,d4
		bsr.s	sub_1BD30
		tst.b	d5
		rts
; End of function sub_1BCE8


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_1BD30:				; XREF: sub_1BCE8
		beq.s	locret_1BD44
		cmpi.b	#$28,d4
		beq.s	locret_1BD44
		cmpi.b	#$3A,d4
		bcs.s	loc_1BD46
		cmpi.b	#$4B,d4
		bcc.s	loc_1BD46

locret_1BD44:
		rts
; ===========================================================================

loc_1BD46:
		move.b	d4,$30(a0)
		move.l	a1,$32(a0)
		moveq	#-1,d5
		rts
; End of function sub_1BD30


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_ChkItems:				; XREF: Obj09_Display
		lea	($FF0000).l,a1
		moveq	#0,d4
		move.w	$C(a0),d4
		addi.w	#$50,d4
		divu.w	#$18,d4
		mulu.w	#$80,d4
		adda.l	d4,a1
		moveq	#0,d4
		move.w	8(a0),d4
		addi.w	#$20,d4
		divu.w	#$18,d4
		adda.w	d4,a1
		move.b	(a1),d4
		bne.s	Obj09_ChkCont
		tst.b	$3A(a0)
		bne.w	Obj09_MakeGhostSolid
		moveq	#0,d4
		rts
; ===========================================================================

Obj09_ChkCont:
		cmpi.b	#$3A,d4		; is the item a	ring?
		bne.s	Obj09_Chk1Up
		bsr.w	SS_RemoveCollectedItem
		bne.s	Obj09_GetCont
		move.b	#1,(a2)
		move.l	a1,4(a2)

Obj09_GetCont:
		jsr	CollectRing
		cmpi.w	#50,($FFFFFE20).w ; check if you have 50 rings
		bcs.s	Obj09_NoCont
		bset	#0,($FFFFFE1B).w
		bne.s	Obj09_NoCont
		addq.b	#1,($FFFFFE18).w ; add 1 to number of continues
		moveq	#sfx_Continue,d0
		jsr	(PlaySound).l	; play extra continue sound

Obj09_NoCont:
		moveq	#0,d4
		rts
; ===========================================================================

Obj09_Chk1Up:
		cmpi.b	#$28,d4		; is the item an extra life?
		bne.s	Obj09_ChkEmer
		bsr.w	SS_RemoveCollectedItem
		bne.s	Obj09_Get1Up
		move.b	#3,(a2)
		move.l	a1,4(a2)

Obj09_Get1Up:
		addq.b	#1,($FFFFFE12).w ; add 1 to number of lives
		addq.b	#1,($FFFFFE1C).w ; add 1 to lives counter
		moveq	#mus_ExtraLife,d0
		jsr	(PlaySound).l	; play extra life music
		moveq	#0,d4
		rts
; ===========================================================================

Obj09_ChkEmer:
		cmpi.b	#$3B,d4		; is the item an emerald?
		bcs.s	Obj09_ChkGhost
		cmpi.b	#$40,d4
		bhi.s	Obj09_ChkGhost
		bsr.w	SS_RemoveCollectedItem
		bne.s	Obj09_GetEmer
		move.b	#5,(a2)
		move.l	a1,4(a2)

Obj09_GetEmer:
		cmpi.b	#6,($FFFFFE57).w ; do you have all the emeralds?
		beq.s	Obj09_NoEmer	; if yes, branch
		subi.b	#$3B,d4
		moveq	#0,d0
		move.b	($FFFFFE57).w,d0
		lea	($FFFFFE58).w,a2
		move.b	d4,(a2,d0.w)
		addq.b	#1,($FFFFFE57).w ; add 1 to number of emeralds

Obj09_NoEmer:
		moveq	#mus_Emerald,d0
		jsr	(PlaySound_Special).l ;	play emerald music
		moveq	#0,d4
		rts
; ===========================================================================

Obj09_ChkGhost:
		cmpi.b	#$41,d4		; is the item a	ghost block?
		bne.s	Obj09_ChkGhostTag
		move.b	#1,$3A(a0)	; mark the ghost block as "passed"

Obj09_ChkGhostTag:
		cmpi.b	#$4A,d4		; is the item a	switch for ghost blocks?
		bne.s	Obj09_NoGhost
		cmpi.b	#1,$3A(a0)	; have the ghost blocks	been passed?
		bne.s	Obj09_NoGhost	; if not, branch
		move.b	#2,$3A(a0)	; mark the ghost blocks	as "solid"

Obj09_NoGhost:
		moveq	#-1,d4
		rts
; ===========================================================================

Obj09_MakeGhostSolid:
		cmpi.b	#2,$3A(a0)	; is the ghost marked as "solid"?
		bne.s	Obj09_GhostNotSolid ; if not, branch
		lea	($FF1020).l,a1
		moveq	#$3F,d1

Obj09_GhostLoop2:
		moveq	#$3F,d2

Obj09_GhostLoop:
		cmpi.b	#$41,(a1)	; is the item a	ghost block?
		bne.s	Obj09_NoReplace	; if not, branch
		move.b	#$2C,(a1)	; replace ghost	block with a solid block

Obj09_NoReplace:
		addq.w	#1,a1
		dbf	d2,Obj09_GhostLoop
		lea	$40(a1),a1
		dbf	d1,Obj09_GhostLoop2

Obj09_GhostNotSolid:
		clr.b	$3A(a0)
		moveq	#0,d4
		rts
; End of function Obj09_ChkItems


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_ChkItems2:			; XREF: Obj09_Display
		move.b	$30(a0),d0
		bne.s	Obj09_ChkBumper
		subq.b	#1,$36(a0)
		bpl.s	loc_1BEA0
		move.b	#0,$36(a0)

loc_1BEA0:
		subq.b	#1,$37(a0)
		bpl.s	locret_1BEAC
		move.b	#0,$37(a0)

locret_1BEAC:
		rts
; ===========================================================================

Obj09_ChkBumper:
		cmpi.b	#$25,d0		; is the item a	bumper?
		bne.s	Obj09_GOAL
		move.l	$32(a0),d1
		subi.l	#$FF0001,d1
		move.w	d1,d2
		andi.w	#$7F,d1
		mulu.w	#$18,d1
		subi.w	#$14,d1
		lsr.w	#7,d2
		andi.w	#$7F,d2
		mulu.w	#$18,d2
		subi.w	#$44,d2
		sub.w	8(a0),d1
		sub.w	$C(a0),d2
		jsr	(CalcAngle).l
		jsr	(CalcSine).l
		muls.w	#-$700,d1
		asr.l	#8,d1
		move.w	d1,$10(a0)
		muls.w	#-$700,d0
		asr.l	#8,d0
		move.w	d0,$12(a0)
		bset	#1,$22(a0)
		bsr.w	SS_RemoveCollectedItem
		bne.s	Obj09_BumpSnd
		move.b	#2,(a2)
		move.l	$32(a0),d0
		subq.l	#1,d0
		move.l	d0,4(a2)

Obj09_BumpSnd:
		moveq	#sfx_Bumper,d0
		jmp	(PlaySound_Special).l ;	play bumper sound
; ===========================================================================

Obj09_GOAL:
		cmpi.b	#$27,d0		; is the item a	"GOAL"?
		bne.s	Obj09_UPblock
		addq.b	#2,$24(a0)	; run routine "Obj09_ExitStage"
		moveq	#sfx_Goal,d0		; change item
		jmp	PlaySound_Special ;	play "GOAL" sound
; ===========================================================================

Obj09_UPblock:
		cmpi.b	#$29,d0		; is the item an "UP" block?
		bne.s	Obj09_DOWNblock
		tst.b	$36(a0)
		bne.w	Obj09_NoGlass
		move.b	#$1E,$36(a0)
		btst	#6,($FFFFF783).w
		beq.s	Obj09_UPsnd
		asl	($FFFFF782).w	; increase stage rotation speed
		movea.l	$32(a0),a1
		subq.l	#1,a1
		move.b	#$2A,(a1)	; change item to a "DOWN" block

Obj09_UPsnd:
		moveq	#sfx_ActionBlock,d0
		jmp	(PlaySound_Special).l ;	play up/down sound
; ===========================================================================

Obj09_DOWNblock:
		cmpi.b	#$2A,d0		; is the item a	"DOWN" block?
		bne.s	Obj09_Rblock
		tst.b	$36(a0)
		bne.w	Obj09_NoGlass
		move.b	#$1E,$36(a0)
		btst	#6,($FFFFF783).w
		bne.s	Obj09_DOWNsnd
		asr	($FFFFF782).w	; reduce stage rotation	speed
		movea.l	$32(a0),a1
		subq.l	#1,a1
		move.b	#$29,(a1)	; change item to an "UP" block

Obj09_DOWNsnd:
		moveq	#sfx_ActionBlock,d0
		jmp	(PlaySound_Special).l ;	play up/down sound
; ===========================================================================

Obj09_Rblock:
		cmpi.b	#$2B,d0		; is the item an "R" block?
		bne.s	Obj09_ChkGlass
		tst.b	$37(a0)
		bne.w	Obj09_NoGlass
		move.b	#$1E,$37(a0)
		bsr.w	SS_RemoveCollectedItem
		bne.s	Obj09_RevStage
		move.b	#4,(a2)
		move.l	$32(a0),d0
		subq.l	#1,d0
		move.l	d0,4(a2)

Obj09_RevStage:
		neg.w	($FFFFF782).w	; reverse stage	rotation
		moveq	#sfx_ActionBlock,d0
		jmp	(PlaySound_Special).l ;	play sound
; ===========================================================================

Obj09_ChkGlass:
		cmpi.b	#$2D,d0		; is the item a	glass block?
		beq.s	Obj09_Glass	; if yes, branch
		cmpi.b	#$2E,d0
		beq.s	Obj09_Glass
		cmpi.b	#$2F,d0
		beq.s	Obj09_Glass
		cmpi.b	#$30,d0
		bne.s	Obj09_NoGlass	; if not, branch

Obj09_Glass:
		bsr.w	SS_RemoveCollectedItem
		bne.s	Obj09_GlassSnd
		move.b	#6,(a2)
		movea.l	$32(a0),a1
		subq.l	#1,a1
		move.l	a1,4(a2)
		move.b	(a1),d0
		addq.b	#1,d0		; change glass type when touched
		cmpi.b	#$30,d0
		bls.s	Obj09_GlassUpdate ; if glass is	still there, branch
		clr.b	d0		; remove the glass block when it's destroyed

Obj09_GlassUpdate:
		move.b	d0,4(a2)	; update the stage layout

Obj09_GlassSnd:
		moveq	#sfx_Diamonds,d0
		jmp	(PlaySound_Special).l ;	play glass block sound
; ===========================================================================

Obj09_NoGlass:

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 10 - blank
; ---------------------------------------------------------------------------

Obj10:					; XREF: Obj_Index
		rts
; ---------------------------------------------------------------------------
; Subroutine to	animate	level graphics
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AniArt_Load:				; XREF: Demo_Time; loc_F54
		tst.w	($FFFFF63A).w	; is the game paused?
		bne.s	AniArt_Pause	; if yes, branch
		lea	($C00000).l,a6
		bsr.w	AniArt_GiantRing
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		add.w	d0,d0
		move.w	AniArt_Index(pc,d0.w),d0
		jmp	AniArt_Index(pc,d0.w)
; ===========================================================================

AniArt_Pause:
		rts
; End of function AniArt_Load

; ===========================================================================
AniArt_Index:	dc.w AniArt_GHZ-AniArt_Index, AniArt_none-AniArt_Index
		dc.w AniArt_MZ-AniArt_Index, AniArt_none-AniArt_Index
		dc.w AniArt_none-AniArt_Index, AniArt_SBZ-AniArt_Index
		dc.w AniArt_Ending-AniArt_Index
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - Green Hill
; ---------------------------------------------------------------------------

AniArt_GHZ:				; XREF: AniArt_Index
		subq.b	#1,($FFFFF7B1).w
		bpl.s	loc_1C08A
		move.b	#5,($FFFFF7B1).w ; time	to display each	frame for
		lea	(Art_GhzWater).l,a1 ; load waterfall patterns
		move.b	($FFFFF7B0).w,d0
		addq.b	#1,($FFFFF7B0).w
		andi.w	#1,d0
		beq.s	loc_1C078
		lea	$100(a1),a1	; load next frame

loc_1C078:
		move.l	#$6F000001,($C00004).l ; VRAM address
		move.w	#7,d1		; number of 8x8	tiles
		bra.w	LoadTiles
; ===========================================================================

loc_1C08A:
		subq.b	#1,($FFFFF7B3).w
		bpl.s	loc_1C0C0
		move.b	#$F,($FFFFF7B3).w
		lea	(Art_GhzFlower1).l,a1 ;	load big flower	patterns
		move.b	($FFFFF7B2).w,d0
		addq.b	#1,($FFFFF7B2).w
		andi.w	#1,d0
		beq.s	loc_1C0AE
		lea	$200(a1),a1

loc_1C0AE:
		move.l	#$6B800001,($C00004).l
		move.w	#$F,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C0C0:
		subq.b	#1,($FFFFF7B5).w
		bpl.s	locret_1C10C
		move.b	#7,($FFFFF7B5).w
		move.b	($FFFFF7B4).w,d0
		addq.b	#1,($FFFFF7B4).w
		andi.w	#3,d0
		move.b	byte_1C10E(pc,d0.w),d0
		btst	#0,d0
		bne.s	loc_1C0E8
		move.b	#$7F,($FFFFF7B5).w

loc_1C0E8:
		lsl.w	#7,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.l	#$6D800001,($C00004).l
		lea	(Art_GhzFlower2).l,a1 ;	load small flower patterns
		lea	(a1,d0.w),a1
		move.w	#$B,d1
		bsr.w	LoadTiles

locret_1C10C:
		rts
; ===========================================================================
byte_1C10E:	dc.b 0,	1, 2, 1
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - Marble
; ---------------------------------------------------------------------------

AniArt_MZ:				; XREF: AniArt_Index
		subq.b	#1,($FFFFF7B1).w
		bpl.s	loc_1C150
		move.b	#$13,($FFFFF7B1).w
		lea	(Art_MzLava1).l,a1 ; load lava surface patterns
		moveq	#0,d0
		move.b	($FFFFF7B0).w,d0
		addq.b	#1,d0
		cmpi.b	#3,d0
		bne.s	loc_1C134
		moveq	#0,d0

loc_1C134:
		move.b	d0,($FFFFF7B0).w
		mulu.w	#$100,d0
		adda.w	d0,a1
		move.l	#$5C400001,($C00004).l
		move.w	#7,d1
		bsr.w	LoadTiles

loc_1C150:
		subq.b	#1,($FFFFF7B3).w
		bpl.s	loc_1C1AE
		move.b	#1,($FFFFF7B3).w
		moveq	#0,d0
		move.b	($FFFFF7B0).w,d0
		lea	(Art_MzLava2).l,a4 ; load lava patterns
		ror.w	#7,d0
		adda.w	d0,a4
		move.l	#$5A400001,($C00004).l
		moveq	#0,d3
		move.b	($FFFFF7B2).w,d3
		addq.b	#1,($FFFFF7B2).w
		move.b	($FFFFFE68).w,d3
		move.w	#3,d2

loc_1C188:
		move.w	d3,d0
		add.w	d0,d0
		andi.w	#$1E,d0
		lea	(AniArt_MZextra).l,a3
		move.w	(a3,d0.w),d0
		lea	(a3,d0.w),a3
		movea.l	a4,a1
		move.w	#$1F,d1
		jsr	(a3)
		addq.w	#4,d3
		dbf	d2,loc_1C188
		rts
; ===========================================================================

loc_1C1AE:
		subq.b	#1,($FFFFF7B5).w
		bpl.w	locret_1C1EA
		move.b	#7,($FFFFF7B5).w
		lea	(Art_MzTorch).l,a1 ; load torch	patterns
		moveq	#0,d0
		move.b	($FFFFF7B6).w,d0
		addq.b	#1,($FFFFF7B6).w
		andi.b	#3,($FFFFF7B6).w
		mulu.w	#$C0,d0
		adda.w	d0,a1
		move.l	#$5E400001,($C00004).l
		move.w	#5,d1
		bra.w	LoadTiles
; ===========================================================================

locret_1C1EA:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - Scrap Brain
; ---------------------------------------------------------------------------

AniArt_SBZ:				; XREF: AniArt_Index
		tst.b	($FFFFF7B4).w
		beq.s	loc_1C1F8
		subq.b	#1,($FFFFF7B4).w
		bra.s	loc_1C250
; ===========================================================================

loc_1C1F8:
		subq.b	#1,($FFFFF7B1).w
		bpl.s	loc_1C250
		move.b	#7,($FFFFF7B1).w
		lea	(Art_SbzSmoke).l,a1 ; load smoke patterns
		move.l	#$49000002,($C00004).l
		move.b	($FFFFF7B0).w,d0
		addq.b	#1,($FFFFF7B0).w
		andi.w	#7,d0
		beq.s	loc_1C234
		subq.w	#1,d0
		mulu.w	#$180,d0
		lea	(a1,d0.w),a1
		move.w	#$B,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C234:
		move.b	#$B4,($FFFFF7B4).w

loc_1C23A:
		move.w	#5,d1
		bsr.w	LoadTiles
		lea	(Art_SbzSmoke).l,a1
		move.w	#5,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C250:
		tst.b	($FFFFF7B5).w
		beq.s	loc_1C25C
		subq.b	#1,($FFFFF7B5).w
		bra.s	locret_1C2A0
; ===========================================================================

loc_1C25C:
		subq.b	#1,($FFFFF7B3).w
		bpl.s	locret_1C2A0
		move.b	#7,($FFFFF7B3).w
		lea	(Art_SbzSmoke).l,a1
		move.l	#$4A800002,($C00004).l
		move.b	($FFFFF7B2).w,d0
		addq.b	#1,($FFFFF7B2).w
		andi.w	#7,d0
		beq.s	loc_1C298
		subq.w	#1,d0
		mulu.w	#$180,d0
		lea	(a1,d0.w),a1
		move.w	#$B,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C298:
		move.b	#$78,($FFFFF7B5).w
		bra.s	loc_1C23A
; ===========================================================================

locret_1C2A0:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - ending sequence
; ---------------------------------------------------------------------------

AniArt_Ending:				; XREF: AniArt_Index
		subq.b	#1,($FFFFF7B3).w
		bpl.s	loc_1C2F4
		move.b	#7,($FFFFF7B3).w
		lea	(Art_GhzFlower1).l,a1 ;	load big flower	patterns
		lea	($FFFF9400).w,a2
		move.b	($FFFFF7B2).w,d0
		addq.b	#1,($FFFFF7B2).w
		andi.w	#1,d0
		beq.s	loc_1C2CE
		lea	$200(a1),a1
		lea	$200(a2),a2

loc_1C2CE:
		move.l	#$6B800001,($C00004).l
		move.w	#$F,d1
		bsr.w	LoadTiles
		movea.l	a2,a1
		move.l	#$72000001,($C00004).l
		move.w	#$F,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C2F4:
		subq.b	#1,($FFFFF7B5).w
		bpl.s	loc_1C33C
		move.b	#7,($FFFFF7B5).w
		move.b	($FFFFF7B4).w,d0
		addq.b	#1,($FFFFF7B4).w
		andi.w	#7,d0
		move.b	byte_1C334(pc,d0.w),d0
		lsl.w	#7,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.l	#$6D800001,($C00004).l
		lea	(Art_GhzFlower2).l,a1 ;	load small flower patterns
		lea	(a1,d0.w),a1
		move.w	#$B,d1
		bra.w	LoadTiles
; ===========================================================================
byte_1C334:	dc.b 0,	0, 0, 1, 2, 2, 2, 1
; ===========================================================================

loc_1C33C:
		subq.b	#1,($FFFFF7B9).w
		bpl.s	loc_1C37A
		move.b	#$E,($FFFFF7B9).w
		move.b	($FFFFF7B8).w,d0
		addq.b	#1,($FFFFF7B8).w
		andi.w	#3,d0
		move.b	byte_1C376(pc,d0.w),d0
		lsl.w	#8,d0
		add.w	d0,d0
		move.l	#$70000001,($C00004).l
		lea	($FFFF9800).w,a1 ; load	special	flower patterns	(from RAM)
		lea	(a1,d0.w),a1
		move.w	#$F,d1
		bra.w	LoadTiles
; ===========================================================================
byte_1C376:	dc.b 0,	1, 2, 1
; ===========================================================================

loc_1C37A:
		subq.b	#1,($FFFFF7BB).w
		bpl.s	locret_1C3B4
		move.b	#$B,($FFFFF7BB).w
		move.b	($FFFFF7BA).w,d0
		addq.b	#1,($FFFFF7BA).w
		andi.w	#3,d0
		move.b	byte_1C376(pc,d0.w),d0
		lsl.w	#8,d0
		add.w	d0,d0
		move.l	#$68000001,($C00004).l
		lea	($FFFF9E00).w,a1 ; load	special	flower patterns	(from RAM)
		lea	(a1,d0.w),a1
		move.w	#$F,d1
		bra.w	LoadTiles
; ===========================================================================

locret_1C3B4:
		rts
; ===========================================================================

AniArt_none:				; XREF: AniArt_Index
		rts

; ---------------------------------------------------------------------------
; Subroutine to	load (d1 - 1) 8x8 tiles
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTiles:
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		dbf	d1,LoadTiles
		rts
; End of function LoadTiles

; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - more Marble Zone
; ---------------------------------------------------------------------------
AniArt_MZextra:	dc.w loc_1C3EE-AniArt_MZextra, loc_1C3FA-AniArt_MZextra
		dc.w loc_1C410-AniArt_MZextra, loc_1C41E-AniArt_MZextra
		dc.w loc_1C434-AniArt_MZextra, loc_1C442-AniArt_MZextra
		dc.w loc_1C458-AniArt_MZextra, loc_1C466-AniArt_MZextra
		dc.w loc_1C47C-AniArt_MZextra, loc_1C48A-AniArt_MZextra
		dc.w loc_1C4A0-AniArt_MZextra, loc_1C4AE-AniArt_MZextra
		dc.w loc_1C4C4-AniArt_MZextra, loc_1C4D2-AniArt_MZextra
		dc.w loc_1C4E8-AniArt_MZextra, loc_1C4FA-AniArt_MZextra
; ===========================================================================

loc_1C3EE:				; XREF: AniArt_MZextra
		move.l	(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C3EE
		rts
; ===========================================================================

loc_1C3FA:				; XREF: AniArt_MZextra
		move.l	2(a1),d0
		move.b	1(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C3FA
		rts
; ===========================================================================

loc_1C410:				; XREF: AniArt_MZextra
		move.l	2(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C410
		rts
; ===========================================================================

loc_1C41E:				; XREF: AniArt_MZextra
		move.l	4(a1),d0
		move.b	3(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C41E
		rts
; ===========================================================================

loc_1C434:				; XREF: AniArt_MZextra
		move.l	4(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C434
		rts
; ===========================================================================

loc_1C442:				; XREF: AniArt_MZextra
		move.l	6(a1),d0
		move.b	5(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C442
		rts
; ===========================================================================

loc_1C458:				; XREF: AniArt_MZextra
		move.l	6(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C458
		rts
; ===========================================================================

loc_1C466:				; XREF: AniArt_MZextra
		move.l	8(a1),d0
		move.b	7(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C466
		rts
; ===========================================================================

loc_1C47C:				; XREF: AniArt_MZextra
		move.l	8(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C47C
		rts
; ===========================================================================

loc_1C48A:				; XREF: AniArt_MZextra
		move.l	$A(a1),d0
		move.b	9(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C48A
		rts
; ===========================================================================

loc_1C4A0:				; XREF: AniArt_MZextra
		move.l	$A(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4A0
		rts
; ===========================================================================

loc_1C4AE:				; XREF: AniArt_MZextra
		move.l	$C(a1),d0
		move.b	$B(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4AE
		rts
; ===========================================================================

loc_1C4C4:				; XREF: AniArt_MZextra
		move.l	$C(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4C4
		rts
; ===========================================================================

loc_1C4D2:				; XREF: AniArt_MZextra
		move.l	$C(a1),d0
		rol.l	#8,d0
		move.b	0(a1),d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4D2
		rts
; ===========================================================================

loc_1C4E8:				; XREF: AniArt_MZextra
		move.w	$E(a1),(a6)
		move.w	0(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4E8
		rts
; ===========================================================================

loc_1C4FA:				; XREF: AniArt_MZextra
		move.l	0(a1),d0
		move.b	$F(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4FA
		rts

; ---------------------------------------------------------------------------
; Animated pattern routine - giant ring
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AniArt_GiantRing:			; XREF: AniArt_Load
		tst.w	($FFFFF7BE).w
		bne.s	loc_1C518
		rts
; ===========================================================================

loc_1C518:
		subi.w	#$1C0,($FFFFF7BE).w
		lea	(Art_BigRing).l,a1 ; load giant	ring patterns
		moveq	#0,d0
		move.w	($FFFFF7BE).w,d0
		lea	(a1,d0.w),a1
		addi.w	#$8000,d0
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,4(a6)
		move.w	#$D,d1
		bra.w	LoadTiles
; End of function AniArt_GiantRing

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 21 - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------

Obj21:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj21_Index(pc,d0.w),d1
		jmp	Obj21_Index(pc,d1.w)
; ===========================================================================
Obj21_Index:	dc.w Obj21_Main-Obj21_Index
		dc.w Obj21_Flash-Obj21_Index
; ===========================================================================

Obj21_Main:				; XREF: Obj21_Main
		addq.b	#2,$24(a0)
		move.w	#$90,8(a0)
		move.w	#$108,$A(a0)
		move.l	#Map_obj21,4(a0)
		move.w	#$6CA,2(a0)
		move.b	#0,1(a0)
		move.b	#0,$18(a0)

Obj21_Flash:				; XREF: Obj21_Main
		tst.w	($FFFFFE20).w	; do you have any rings?
		beq.s	Obj21_Flash2	; if not, branch
		clr.b	$1A(a0)		; make all counters yellow
		jmp	DisplaySprite
; ===========================================================================

Obj21_Flash2:
		moveq	#0,d0
		btst	#3,($FFFFFE05).w
		bne.s	Obj21_Display
		addq.w	#1,d0		; make ring counter flash red
		cmpi.b	#9,($FFFFFE23).w ; have	9 minutes elapsed?
		bne.s	Obj21_Display	; if not, branch
		addq.w	#2,d0		; make time counter flash red

Obj21_Display:
		move.b	d0,$1A(a0)
		jmp	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------
Map_obj21:
	include "_maps\obj21.asm"

; ---------------------------------------------------------------------------
; Add points subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AddPoints:
		move.b	#1,($FFFFFE1F).w ; set score counter to	update
		lea	($FFFFFFC0).w,a2
		lea	($FFFFFE26).w,a3
		add.l	d0,(a3)		; add d0*10 to the score
		move.l	#999999,d1
		cmp.l	(a3),d1		; is #999999 higher than the score?
		bhi.w	loc_1C6AC	; if yes, branch
		move.l	d1,(a3)		; reset	score to #999999
		move.l	d1,(a2)

loc_1C6AC:
		move.l	(a3),d0
		cmp.l	(a2),d0
		bcs.w	locret_1C6B6
		move.l	d0,(a2)

locret_1C6B6:
		rts
; End of function AddPoints

; ---------------------------------------------------------------------------
; Subroutine to	update the HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudUpdate:
		tst.w	($FFFFFFFA).w	; is debug mode	on?
		bne.w	HudDebug	; if yes, branch
		tst.b	($FFFFFE1F).w	; does the score need updating?
		beq.s	Hud_ChkRings	; if not, branch
		clr.b	($FFFFFE1F).w
		move.l	#$5C800003,d0	; set VRAM address
		move.l	($FFFFFE26).w,d1 ; load	score
		bsr.w	Hud_Score

Hud_ChkRings:
		tst.b	($FFFFFE1D).w	; does the ring	counter	need updating?
		beq.s	Hud_ChkTime	; if not, branch
		bpl.s	loc_1C6E4
		bsr.w	Hud_LoadZero

loc_1C6E4:
		clr.b	($FFFFFE1D).w
		move.l	#$5F400003,d0	; set VRAM address
		moveq	#0,d1
		move.w	($FFFFFE20).w,d1 ; load	number of rings
		bsr.w	Hud_Rings

Hud_ChkTime:
		tst.b	($FFFFFE1E).w	; does the time	need updating?
		beq.s	Hud_ChkLives	; if not, branch
		tst.w	($FFFFF63A).w	; is the game paused?
		bne.s	Hud_ChkLives	; if yes, branch
		lea	($FFFFFE22).w,a1
		cmpi.l	#$93B3B,(a1)+	; is the time 9.59?
		beq.s	TimeOver	; if yes, branch
		addq.b	#1,-(a1)
		cmpi.b	#60,(a1)
		bcs.s	Hud_ChkLives
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmpi.b	#60,(a1)
		bcs.s	loc_1C734
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmpi.b	#9,(a1)
		bcs.s	loc_1C734
		move.b	#9,(a1)

loc_1C734:
		move.l	#$5E400003,d0
		moveq	#0,d1
		move.b	($FFFFFE23).w,d1 ; load	minutes
		bsr.w	Hud_Mins
		move.l	#$5EC00003,d0
		moveq	#0,d1
		move.b	($FFFFFE24).w,d1 ; load	seconds
		bsr.w	Hud_Secs

Hud_ChkLives:
		tst.b	($FFFFFE1C).w	; does the lives counter need updating?
		beq.s	Hud_ChkBonus	; if not, branch
		clr.b	($FFFFFE1C).w
		bsr.w	Hud_Lives

Hud_ChkBonus:
		tst.b	($FFFFF7D6).w	; do time/ring bonus counters need updating?
		beq.s	Hud_End		; if not, branch
		clr.b	($FFFFF7D6).w
		move.l	#$6E000002,($C00004).l
		moveq	#0,d1
		move.w	($FFFFF7D2).w,d1 ; load	time bonus
		bsr.w	Hud_TimeRingBonus
		moveq	#0,d1
		move.w	($FFFFF7D4).w,d1 ; load	ring bonus
		bsr.w	Hud_TimeRingBonus

Hud_End:
		rts
; ===========================================================================

TimeOver:				; XREF: Hud_ChkTime
		clr.b	($FFFFFE1E).w
		lea	($FFFFD000).w,a0
		movea.l	a0,a2
		bsr.w	KillSonic
		move.b	#1,($FFFFFE1A).w
		rts
; ===========================================================================

HudDebug:				; XREF: HudUpdate
		bsr.w	HudDb_XY
		tst.b	($FFFFFE1D).w	; does the ring	counter	need updating?
		beq.s	HudDb_ObjCount	; if not, branch
		bpl.s	HudDb_Rings
		bsr.w	Hud_LoadZero

HudDb_Rings:
		clr.b	($FFFFFE1D).w
		move.l	#$5F400003,d0	; set VRAM address
		moveq	#0,d1
		move.w	($FFFFFE20).w,d1 ; load	number of rings
		bsr.w	Hud_Rings

HudDb_ObjCount:
		move.l	#$5EC00003,d0	; set VRAM address
		moveq	#0,d1
		move.b	($FFFFF62C).w,d1 ; load	"number	of objects" counter
		bsr.w	Hud_Secs
		tst.b	($FFFFFE1C).w	; does the lives counter need updating?
		beq.s	HudDb_ChkBonus	; if not, branch
		clr.b	($FFFFFE1C).w
		bsr.w	Hud_Lives

HudDb_ChkBonus:
		tst.b	($FFFFF7D6).w	; does the ring/time bonus counter need	updating?
		beq.s	HudDb_End	; if not, branch
		clr.b	($FFFFF7D6).w
		move.l	#$6E000002,($C00004).l ; set VRAM address
		moveq	#0,d1
		move.w	($FFFFF7D2).w,d1 ; load	time bonus
		bsr.w	Hud_TimeRingBonus
		moveq	#0,d1
		move.w	($FFFFF7D4).w,d1 ; load	ring bonus
		bsr.w	Hud_TimeRingBonus

HudDb_End:
		rts
; End of function HudUpdate

; ---------------------------------------------------------------------------
; Subroutine to	load "0" on the	HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_LoadZero:				; XREF: HudUpdate
		move.l	#$5F400003,($C00004).l
		lea	Hud_TilesZero(pc),a2
		move.w	#2,d2
		bra.s	loc_1C83E
; End of function Hud_LoadZero

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed HUD patterns ("E", "0", colon)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Base:				; XREF: Level; SS_EndLoop; EndingSequence
		lea	($C00000).l,a6
		bsr.w	Hud_Lives
		move.l	#$5C400003,($C00004).l
		lea	Hud_TilesBase(pc),a2
		move.w	#$E,d2

loc_1C83E:				; XREF: Hud_LoadZero
		lea	Art_Hud(pc),a1

loc_1C842:
		move.w	#$F,d1
		move.b	(a2)+,d0
		bmi.s	loc_1C85E
		ext.w	d0
		lsl.w	#5,d0
		lea	(a1,d0.w),a3

loc_1C852:
		move.l	(a3)+,(a6)
		dbf	d1,loc_1C852

loc_1C858:
		dbf	d2,loc_1C842

		rts
; ===========================================================================

loc_1C85E:
		move.l	#0,(a6)
		dbf	d1,loc_1C85E

		bra.s	loc_1C858
; End of function Hud_Base

; ===========================================================================
Hud_TilesBase:	dc.b $16, $FF, $FF, $FF, $FF, $FF, $FF,	0, 0, $14, 0, 0
Hud_TilesZero:	dc.b $FF, $FF, 0, 0
; ---------------------------------------------------------------------------
; Subroutine to	load debug mode	numbers	patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudDb_XY:				; XREF: HudDebug
		move.l	#$5C400003,($C00004).l ; set VRAM address
		move.w	($FFFFF700).w,d1 ; load	camera x-position
		swap	d1
		move.w	($FFFFD008).w,d1 ; load	Sonic's x-position
		bsr.s	HudDb_XY2
		move.w	($FFFFF704).w,d1 ; load	camera y-position
		swap	d1
		move.w	($FFFFD00C).w,d1 ; load	Sonic's y-position
; End of function HudDb_XY


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudDb_XY2:
		moveq	#7,d6
		lea	(Art_Text).l,a1

HudDb_XYLoop:
		rol.w	#4,d1
		move.w	d1,d2
		andi.w	#$F,d2
		cmpi.w	#$A,d2
		bcs.s	loc_1C8B2
		addq.w	#7,d2

loc_1C8B2:
		lsl.w	#5,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		swap	d1
		dbf	d6,HudDb_XYLoop	; repeat 7 more	times

		rts
; End of function HudDb_XY2

; ---------------------------------------------------------------------------
; Subroutine to	load rings numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Rings:				; XREF: HudUpdate
		lea	(Hud_100).l,a2
		moveq	#2,d6
		bra.s	Hud_LoadArt
; End of function Hud_Rings

; ---------------------------------------------------------------------------
; Subroutine to	load score numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Score:				; XREF: HudUpdate
		lea	(Hud_100000).l,a2
		moveq	#5,d6

Hud_LoadArt:
		moveq	#0,d4
		lea	Art_Hud(pc),a1

Hud_ScoreLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C8EC:
		sub.l	d3,d1
		bcs.s	loc_1C8F4
		addq.w	#1,d2
		bra.s	loc_1C8EC
; ===========================================================================

loc_1C8F4:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1C8FE
		move.w	#1,d4

loc_1C8FE:
		tst.w	d4
		beq.s	loc_1C92C
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1C92C:
		addi.l	#$400000,d0
		dbf	d6,Hud_ScoreLoop

		rts
; End of function Hud_Score

; ---------------------------------------------------------------------------
; Subroutine to	load countdown numbers on the continue screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ContScrCounter:				; XREF: ContinueScreen
		move.l	#$5F800003,($C00004).l ; set VRAM address
		lea	($C00000).l,a6
		lea	(Hud_10).l,a2
		moveq	#1,d6
		moveq	#0,d4
		lea	Art_Hud(pc),a1 ; load numbers patterns

ContScr_Loop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C95A:
		sub.l	d3,d1
		bcs.s	loc_1C962
		addq.w	#1,d2
		bra.s	loc_1C95A
; ===========================================================================

loc_1C962:
		add.l	d3,d1
		lsl.w	#6,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		dbf	d6,ContScr_Loop	; repeat 1 more	time

		rts
; End of function ContScrCounter

; ===========================================================================
; ---------------------------------------------------------------------------
; HUD counter sizes
; ---------------------------------------------------------------------------
Hud_100000:	dc.l 100000		; XREF: Hud_Score
Hud_10000:	dc.l 10000
Hud_1000:	dc.l 1000		; XREF: Hud_TimeRingBonus
Hud_100:	dc.l 100		; XREF: Hud_Rings
Hud_10:		dc.l 10			; XREF: ContScrCounter; Hud_Secs; Hud_Lives
Hud_1:		dc.l 1			; XREF: Hud_Mins

; ---------------------------------------------------------------------------
; Subroutine to	load time numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Mins:				; XREF: Hud_ChkTime
		lea	(Hud_1).l,a2
		moveq	#0,d6
		bra.s	loc_1C9BA
; End of function Hud_Mins


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Secs:				; XREF: Hud_ChkTime
		lea	(Hud_10).l,a2
		moveq	#1,d6

loc_1C9BA:
		moveq	#0,d4
		lea	Art_Hud(pc),a1

Hud_TimeLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C9C4:
		sub.l	d3,d1
		bcs.s	loc_1C9CC
		addq.w	#1,d2
		bra.s	loc_1C9C4
; ===========================================================================

loc_1C9CC:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1C9D6
		move.w	#1,d4

loc_1C9D6:
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		addi.l	#$400000,d0
		dbf	d6,Hud_TimeLoop

		rts
; End of function Hud_Secs

; ---------------------------------------------------------------------------
; Subroutine to	load time/ring bonus numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_TimeRingBonus:			; XREF: Hud_ChkBonus
		lea	(Hud_1000).l,a2
		moveq	#3,d6
		moveq	#0,d4
		lea	Art_Hud(pc),a1

Hud_BonusLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1CA1E:
		sub.l	d3,d1
		bcs.s	loc_1CA26
		addq.w	#1,d2
		bra.s	loc_1CA1E
; ===========================================================================

loc_1CA26:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1CA30
		move.w	#1,d4

loc_1CA30:
		tst.w	d4
		beq.s	Hud_ClrBonus
		lsl.w	#6,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1CA5A:
		dbf	d6,Hud_BonusLoop ; repeat 3 more times

		rts
; ===========================================================================

Hud_ClrBonus:
		moveq	#$F,d5

Hud_ClrBonusLoop:
		move.l	#0,(a6)
		dbf	d5,Hud_ClrBonusLoop

		bra.s	loc_1CA5A
; End of function Hud_TimeRingBonus

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed lives	counter	patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Lives:				; XREF: Hud_ChkLives
		move.l	#$7BA00003,d0	; set VRAM address
		moveq	#0,d1
		move.b	($FFFFFE12).w,d1 ; load	number of lives
		lea	(Hud_10).l,a2
		moveq	#1,d6
		moveq	#0,d4
		lea	Art_LivesNums(pc),a1

Hud_LivesLoop:
		move.l	d0,4(a6)
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1CA90:
		sub.l	d3,d1
		bcs.s	loc_1CA98
		addq.w	#1,d2
		bra.s	loc_1CA90
; ===========================================================================

loc_1CA98:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1CAA2
		move.w	#1,d4

loc_1CAA2:
		tst.w	d4
		beq.s	Hud_ClrLives

loc_1CAA6:
		lsl.w	#5,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1CABC:
		addi.l	#$400000,d0
		dbf	d6,Hud_LivesLoop ; repeat 1 more time

		rts
; ===========================================================================

Hud_ClrLives:
		tst.w	d6
		beq.s	loc_1CAA6
		moveq	#7,d5

Hud_ClrLivesLoop:
		move.l	#0,(a6)
		dbf	d5,Hud_ClrLivesLoop
		bra.s	loc_1CABC
; End of function Hud_Lives

; ===========================================================================
Art_Hud:	incbin	artunc\HUD.bin		; 8x16 pixel numbers on HUD
		even
Art_LivesNums:	incbin	artunc\livescnt.bin	; 8x8 pixel numbers on lives counter
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; When debug mode is currently in use
; ---------------------------------------------------------------------------

DebugMode:				; XREF: Obj01; Obj09
		moveq	#0,d0
		move.b	($FFFFFE08).w,d0
		move.w	Debug_Index(pc,d0.w),d1
		jmp	Debug_Index(pc,d1.w)
; ===========================================================================
Debug_Index:	dc.w Debug_Main-Debug_Index
		dc.w Debug_Skip-Debug_Index
; ===========================================================================

Debug_Main:				; XREF: Debug_Index
		addq.b	#2,($FFFFFE08).w
		move.w	($FFFFF72C).w,($FFFFFEF0).w ; buffer level x-boundary
		move.w	($FFFFF726).w,($FFFFFEF2).w ; buffer level y-boundary
		move.w	#0,($FFFFF72C).w
		move.w	#$720,($FFFFF726).w
		andi.w	#$7FF,($FFFFD00C).w
		andi.w	#$7FF,($FFFFF704).w
		andi.w	#$3FF,($FFFFF70C).w
		move.b	#0,$1A(a0)
		move.b	#0,$1C(a0)
		cmpi.b	#$10,($FFFFF600).w ; is	game mode = $10	(special stage)?
		bne.s	Debug_Zone	; if not, branch
		move.w	#0,($FFFFF782).w ; stop	special	stage rotating
		move.w	#0,($FFFFF780).w ; make	special	stage "upright"
		moveq	#6,d0		; use 6th debug	item list
		bra.s	Debug_UseList
; ===========================================================================

Debug_Zone:
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0

Debug_UseList:
		lea	(DebugList).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d6
		cmp.b	($FFFFFE06).w,d6
		bhi.s	loc_1CF9E
		move.b	#0,($FFFFFE06).w

loc_1CF9E:
		bsr.w	Debug_ShowItem
		move.b	#$C,($FFFFFE0A).w
		move.b	#1,($FFFFFE0B).w

Debug_Skip:				; XREF: Debug_Index
		moveq	#6,d0
		cmpi.b	#$10,($FFFFF600).w
		beq.s	loc_1CFBE
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0

loc_1CFBE:
		lea	(DebugList).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d6
		bsr.w	Debug_Control
		jmp	DisplaySprite

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Debug_Control:
		moveq	#0,d4
		move.w	#1,d1
		move.b	($FFFFF605).w,d4
		andi.w	#$F,d4		; is up/down/left/right	pressed?
		bne.s	loc_1D018	; if yes, branch
		move.b	($FFFFF604).w,d0
		andi.w	#$F,d0
		bne.s	loc_1D000
		move.b	#$C,($FFFFFE0A).w
		move.b	#$F,($FFFFFE0B).w
		bra.w	Debug_BackItem
; ===========================================================================

loc_1D000:
		subq.b	#1,($FFFFFE0A).w
		bne.s	loc_1D01C
		move.b	#1,($FFFFFE0A).w
		addq.b	#1,($FFFFFE0B).w
		bne.s	loc_1D018
		move.b	#-1,($FFFFFE0B).w

loc_1D018:
		move.b	($FFFFF604).w,d4

loc_1D01C:
		moveq	#0,d1
		move.b	($FFFFFE0B).w,d1
		addq.w	#1,d1
		swap	d1
		asr.l	#4,d1
		move.l	$C(a0),d2
		move.l	8(a0),d3
		btst	#0,d4		; is up	being pressed?
		beq.s	loc_1D03C	; if not, branch
		sub.l	d1,d2
		bcc.s	loc_1D03C
		moveq	#0,d2

loc_1D03C:
		btst	#1,d4		; is down being	pressed?
		beq.s	loc_1D052	; if not, branch
		add.l	d1,d2
		cmpi.l	#$7FF0000,d2
		bcs.s	loc_1D052
		move.l	#$7FF0000,d2

loc_1D052:
		btst	#2,d4
		beq.s	loc_1D05E
		sub.l	d1,d3
		bcc.s	loc_1D05E
		moveq	#0,d3

loc_1D05E:
		btst	#3,d4
		beq.s	loc_1D066
		add.l	d1,d3

loc_1D066:
		move.l	d2,$C(a0)
		move.l	d3,8(a0)

Debug_BackItem:
		btst	#6,($FFFFF604).w ; is button A pressed?
		beq.s	Debug_MakeItem	; if not, branch
		btst	#5,($FFFFF605).w ; is button C pressed?
		beq.s	Debug_NextItem	; if not, branch
		subq.b	#1,($FFFFFE06).w ; go back 1 item
		bcc.s	Debug_NoLoop
		add.b	d6,($FFFFFE06).w
		bra.s	Debug_NoLoop
; ===========================================================================

Debug_NextItem:
		btst	#6,($FFFFF605).w ; is button A pressed?
		beq.s	Debug_MakeItem	; if not, branch
		addq.b	#1,($FFFFFE06).w ; go forwards 1 item
		cmp.b	($FFFFFE06).w,d6
		bhi.s	Debug_NoLoop
		move.b	#0,($FFFFFE06).w ; loop	back to	first item

Debug_NoLoop:
		bra.w	Debug_ShowItem
; ===========================================================================

Debug_MakeItem:
		btst	#5,($FFFFF605).w ; is button C pressed?
		beq.s	Debug_Exit	; if not, branch
		jsr	SingleObjLoad
		bne.s	Debug_Exit
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	4(a0),0(a1)	; create object
		move.b	1(a0),1(a1)
		move.b	1(a0),$22(a1)
		andi.b	#$7F,$22(a1)
		moveq	#0,d0
		move.b	($FFFFFE06).w,d0
		lsl.w	#3,d0
		move.b	4(a2,d0.w),$28(a1)
		rts
; ===========================================================================

Debug_Exit:
		btst	#4,($FFFFF605).w ; is button B pressed?
		beq.s	Debug_DoNothing	; if not, branch
		moveq	#0,d0
		move.w	d0,($FFFFFE08).w ; deactivate debug mode
		move.l	#Map_Sonic,($FFFFD004).w
		move.w	#$780,($FFFFD002).w
		move.b	d0,($FFFFD01C).w
		move.w	d0,$A(a0)
		move.w	d0,$E(a0)
		move.w	($FFFFFEF0).w,($FFFFF72C).w ; restore level boundaries
		move.w	($FFFFFEF2).w,($FFFFF726).w
		cmpi.b	#$10,($FFFFF600).w ; are you in	the special stage?
		bne.s	Debug_DoNothing	; if not, branch
		clr.w	($FFFFF780).w
		move.w	#$40,($FFFFF782).w ; set new level rotation speed
		move.l	#Map_Sonic,($FFFFD004).w
		move.w	#$780,($FFFFD002).w
		move.b	#2,($FFFFD01C).w
		bset	#2,($FFFFD022).w
		bset	#1,($FFFFD022).w

Debug_DoNothing:
		rts
; End of function Debug_Control


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Debug_ShowItem:				; XREF: Debug_Main
		moveq	#0,d0
		move.b	($FFFFFE06).w,d0
		lsl.w	#3,d0
		move.l	(a2,d0.w),4(a0)	; load mappings	for item
		move.w	6(a2,d0.w),2(a0) ; load	VRAM setting for item
		move.b	5(a2,d0.w),$1A(a0) ; load frame	number for item
		rts
; End of function Debug_ShowItem

; ===========================================================================
; ---------------------------------------------------------------------------
; Debug	list pointers
; ---------------------------------------------------------------------------
DebugList:
	include "_inc\Debug list pointers.asm"

; ---------------------------------------------------------------------------
; Debug	list - Green Hill
; ---------------------------------------------------------------------------
Debug_GHZ:
	include "_inc\Debug list - GHZ.asm"

; ---------------------------------------------------------------------------
; Debug	list - Labyrinth
; ---------------------------------------------------------------------------
Debug_LZ:
	include "_inc\Debug list - LZ.asm"

; ---------------------------------------------------------------------------
; Debug	list - Marble
; ---------------------------------------------------------------------------
Debug_MZ:
	include "_inc\Debug list - MZ.asm"

; ---------------------------------------------------------------------------
; Debug	list - Star Light
; ---------------------------------------------------------------------------
Debug_SLZ:
	include "_inc\Debug list - SLZ.asm"

; ---------------------------------------------------------------------------
; Debug	list - Spring Yard
; ---------------------------------------------------------------------------
Debug_SYZ:
	include "_inc\Debug list - SYZ.asm"

; ---------------------------------------------------------------------------
; Debug	list - Scrap Brain
; ---------------------------------------------------------------------------
Debug_SBZ:
	include "_inc\Debug list - SBZ.asm"

; ---------------------------------------------------------------------------
; Debug	list - ending sequence / special stage
; ---------------------------------------------------------------------------
Debug_Ending:
	include "_inc\Debug list - Ending and SS.asm"

; ---------------------------------------------------------------------------
; Main level load blocks
; ---------------------------------------------------------------------------
MainLoadBlocks:
	include "_inc\Main level load blocks.asm"

; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------
ArtLoadCues:
	include "_inc\Pattern load cues.asm"

		incbin	misc\padding.bin
		even
Nem_SegaLogo:	incbin	artnem\segalogo.bin	; large Sega logo
		even
Eni_SegaLogo:	incbin	mapeni\segalogo.bin	; large Sega logo (mappings)
		even
Eni_Title:	incbin	mapeni\titlescr.bin	; title screen foreground (mappings)
		even
Nem_TitleFg:	incbin	artnem\titlefor.bin	; title screen foreground
		even
Nem_TitleSonic:	incbin	artnem\titleson.bin	; Sonic on title screen
		even
Nem_TitleTM:	incbin	artnem\titletm.bin	; TM on title screen
		even
Eni_JapNames:	incbin	mapeni\japcreds.bin	; Japanese credits (mappings)
		even
Nem_JapNames:	incbin	artnem\japcreds.bin	; Japanese credits
		even
; ---------------------------------------------------------------------------
; Sprite mappings - Sonic
; ---------------------------------------------------------------------------
Map_Sonic:
	include "_maps\Sonic.asm"

; ---------------------------------------------------------------------------
; Uncompressed graphics	loading	array for Sonic
; ---------------------------------------------------------------------------
SonicDynPLC:
	include "_inc\Sonic dynamic pattern load cues.asm"

; ---------------------------------------------------------------------------
; Uncompressed graphics	- Sonic
; ---------------------------------------------------------------------------
Art_Sonic:	incbin	artunc\sonic.bin	; Sonic
		even
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
Nem_Smoke:	incbin	artnem\xxxsmoke.bin	; unused smoke
		even
Nem_SyzSparkle:	incbin	artnem\xxxstars.bin	; unused stars
		even
Nem_Shield:	incbin	artnem\shield.bin	; shield
		even
Nem_Stars:	incbin	artnem\invstars.bin	; invincibility stars
		even
Nem_LzSonic:	incbin	artnem\xxxlzson.bin	; unused LZ Sonic holding his breath
		even
Nem_UnkFire:	incbin	artnem\xxxfire.bin	; unused fireball
		even
Nem_Warp:	incbin	artnem\xxxflash.bin	; unused entry to special stage flash
		even
Nem_Goggle:	incbin	artnem\xxxgoggl.bin	; unused goggles
		even
; ---------------------------------------------------------------------------
; Sprite mappings - walls of the special stage
; ---------------------------------------------------------------------------
Map_SSWalls:
	include "_maps\SSwalls.asm"
; ---------------------------------------------------------------------------
; Compressed graphics - special stage
; ---------------------------------------------------------------------------
Nem_SSWalls:	incbin	artnem\sswalls.bin	; special stage walls
		even
Eni_SSBg1:	incbin	mapeni\ssbg1.bin	; special stage background (mappings)
		even
Nem_SSBgFish:	incbin	artnem\ssbg1.bin	; special stage birds and fish background
		even
Eni_SSBg2:	incbin	mapeni\ssbg2.bin	; special stage background (mappings)
		even
Nem_SSBgCloud:	incbin	artnem\ssbg2.bin	; special stage clouds background
		even
Nem_SSGOAL:	incbin	artnem\ssgoal.bin	; special stage GOAL block
		even
Nem_SSRBlock:	incbin	artnem\ssr.bin		; special stage R block
		even
Nem_SS1UpBlock:	incbin	artnem\ss1up.bin	; special stage 1UP block
		even
Nem_SSEmStars:	incbin	artnem\ssemstar.bin	; special stage stars from a collected emerald
		even
Nem_SSRedWhite:	incbin	artnem\ssredwhi.bin	; special stage red/white block
		even
Nem_SSZone1:	incbin	artnem\sszone1.bin	; special stage ZONE1 block
		even
Nem_SSZone2:	incbin	artnem\sszone2.bin	; ZONE2 block
		even
Nem_SSZone3:	incbin	artnem\sszone3.bin	; ZONE3 block
		even
Nem_SSZone4:	incbin	artnem\sszone4.bin	; ZONE4 block
		even
Nem_SSZone5:	incbin	artnem\sszone5.bin	; ZONE5 block
		even
Nem_SSZone6:	incbin	artnem\sszone6.bin	; ZONE6 block
		even
Nem_SSUpDown:	incbin	artnem\ssupdown.bin	; special stage UP/DOWN block
		even
Nem_SSEmerald:	incbin	artnem\ssemeral.bin	; special stage chaos emeralds
		even
Nem_SSGhost:	incbin	artnem\ssghost.bin	; special stage ghost block
		even
Nem_SSWBlock:	incbin	artnem\ssw.bin		; special stage W block
		even
Nem_SSGlass:	incbin	artnem\ssglass.bin	; special stage destroyable glass block
		even
Nem_ResultEm:	incbin	artnem\ssresems.bin	; chaos emeralds on special stage results screen
		even
; ---------------------------------------------------------------------------
; Compressed graphics - GHZ stuff
; ---------------------------------------------------------------------------
Nem_Stalk:	incbin	artnem\ghzstalk.bin	; GHZ flower stalk
		even
Nem_Swing:	incbin	artnem\ghzswing.bin	; GHZ swinging platform
		even
Nem_Bridge:	incbin	artnem\ghzbridg.bin	; GHZ bridge
		even
Nem_GhzUnkBlock:incbin	artnem\xxxghzbl.bin	; unused GHZ block
		even
Nem_Ball:	incbin	artnem\ghzball.bin	; GHZ giant ball
		even
Nem_Spikes:	incbin	artnem\spikes.bin	; spikes
		even
Nem_GhzLog:	incbin	artnem\xxxghzlo.bin	; unused GHZ log
		even
Nem_SpikePole:	incbin	artnem\ghzlog.bin	; GHZ spiked log
		even
Nem_PplRock:	incbin	artnem\ghzrock.bin	; GHZ purple rock
		even
Nem_GhzWall1:	incbin	artnem\ghzwall1.bin	; GHZ destroyable wall
		even
Nem_GhzWall2:	incbin	artnem\ghzwall2.bin	; GHZ normal wall
		even
; ---------------------------------------------------------------------------
; Compressed graphics - LZ stuff
; ---------------------------------------------------------------------------
Nem_Water:	incbin	artnem\lzwater.bin	; LZ water surface
		even
Nem_Splash:	incbin	artnem\lzsplash.bin	; LZ waterfalls and splashes
		even
Nem_LzSpikeBall:incbin	artnem\lzspball.bin	; LZ spiked ball on chain
		even
Nem_FlapDoor:	incbin	artnem\lzflapdo.bin	; LZ flapping door
		even
Nem_Bubbles:	incbin	artnem\lzbubble.bin	; LZ bubbles and countdown numbers
		even
Nem_LzBlock3:	incbin	artnem\lzblock3.bin	; LZ 32x16 block
		even
Nem_LzDoor1:	incbin	artnem\lzvdoor.bin	; LZ vertical door
		even
Nem_Harpoon:	incbin	artnem\lzharpoo.bin	; LZ harpoon
		even
Nem_LzPole:	incbin	artnem\lzpole.bin	; LZ pole that breaks
		even
Nem_LzDoor2:	incbin	artnem\lzhdoor.bin	; LZ large horizontal door
		even
Nem_LzWheel:	incbin	artnem\lzwheel.bin	; LZ wheel from corner of conveyor belt
		even
Nem_Gargoyle:	incbin	artnem\lzgargoy.bin	; LZ gargoyle head and spitting fire
		even
Nem_LzBlock2:	incbin	artnem\lzblock2.bin	; LZ blocks
		even
Nem_LzPlatfm:	incbin	artnem\lzptform.bin	; LZ rising platforms
		even
Nem_Cork:	incbin	artnem\lzcork.bin	; LZ cork block
		even
Nem_LzBlock1:	incbin	artnem\lzblock1.bin	; LZ 32x32 block
		even
; ---------------------------------------------------------------------------
; Compressed graphics - MZ stuff
; ---------------------------------------------------------------------------
Nem_MzMetal:	incbin	artnem\mzmetal.bin	; MZ metal blocks
		even
Nem_MzSwitch:	incbin	artnem\mzswitch.bin	; MZ switch
		even
Nem_MzGlass:	incbin	artnem\mzglassy.bin	; MZ green glassy block
		even
Nem_GhzGrass:	incbin	artnem\xxxgrass.bin	; unused grass (GHZ or MZ?)
		even
Nem_MzFire:	incbin	artnem\mzfire.bin	; MZ fireballs
		even
Nem_Lava:	incbin	artnem\mzlava.bin	; MZ lava
		even
Nem_MzBlock:	incbin	artnem\mzblock.bin	; MZ green pushable block
		even
Nem_MzUnkBlock:	incbin	artnem\xxxmzblo.bin	; MZ unused background block
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SLZ stuff
; ---------------------------------------------------------------------------
Nem_Seesaw:	incbin	artnem\slzseesa.bin	; SLZ seesaw
		even
Nem_SlzSpike:	incbin	artnem\slzspike.bin	; SLZ spikeball that sits on a seesaw
		even
Nem_Fan:	incbin	artnem\slzfan.bin	; SLZ fan
		even
Nem_SlzWall:	incbin	artnem\slzwall.bin	; SLZ smashable wall
		even
Nem_Pylon:	incbin	artnem\slzpylon.bin	; SLZ foreground pylon
		even
Nem_SlzSwing:	incbin	artnem\slzswing.bin	; SLZ swinging platform
		even
Nem_SlzBlock:	incbin	artnem\slzblock.bin	; SLZ 32x32 block
		even
Nem_SlzCannon:	incbin	artnem\slzcanno.bin	; SLZ fireball launcher cannon
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SYZ stuff
; ---------------------------------------------------------------------------
Nem_Bumper:	incbin	artnem\syzbumpe.bin	; SYZ bumper
		even
Nem_SyzSpike2:	incbin	artnem\syzsspik.bin	; SYZ small spikeball
		even
Nem_LzSwitch:	incbin	artnem\switch.bin	; LZ/SYZ/SBZ switch
		even
Nem_SyzSpike1:	incbin	artnem\syzlspik.bin	; SYZ/SBZ large spikeball
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SBZ stuff
; ---------------------------------------------------------------------------
Nem_SbzWheel1:	incbin	artnem\sbzwhee1.bin	; SBZ spot on rotating wheel that Sonic runs around
		even
Nem_SbzWheel2:	incbin	artnem\sbzwhee2.bin	; SBZ wheel that grabs Sonic
		even
Nem_Cutter:	incbin	artnem\sbzcutte.bin	; SBZ pizza cutter
		even
Nem_Stomper:	incbin	artnem\sbzstomp.bin	; SBZ stomper
		even
Nem_SpinPform:	incbin	artnem\sbzpform.bin	; SBZ spinning platform
		even
Nem_TrapDoor:	incbin	artnem\sbztrapd.bin	; SBZ trapdoor
		even
Nem_SbzFloor:	incbin	artnem\sbzfloor.bin	; SBZ collapsing floor
		even
Nem_Electric:	incbin	artnem\sbzshock.bin	; SBZ electric shock orb
		even
Nem_SbzBlock:	incbin	artnem\sbzvanis.bin	; SBZ vanishing block
		even
Nem_FlamePipe:	incbin	artnem\sbzflame.bin	; SBZ flaming pipe
		even
Nem_SbzDoor1:	incbin	artnem\sbzvdoor.bin	; SBZ small vertical door
		even
Nem_SlideFloor:	incbin	artnem\sbzslide.bin	; SBZ floor that slides away
		even
Nem_SbzDoor2:	incbin	artnem\sbzhdoor.bin	; SBZ large horizontal door
		even
Nem_Girder:	incbin	artnem\sbzgirde.bin	; SBZ crushing girder
		even
; ---------------------------------------------------------------------------
; Compressed graphics - enemies
; ---------------------------------------------------------------------------
Nem_BallHog:	incbin	artnem\ballhog.bin	; ball hog
		even
Nem_Crabmeat:	incbin	artnem\crabmeat.bin	; crabmeat
		even
Nem_Buzz:	incbin	artnem\buzzbomb.bin	; buzz bomber
		even
Nem_UnkExplode:	incbin	artnem\xxxexplo.bin	; unused explosion
		even
Nem_Burrobot:	incbin	artnem\burrobot.bin	; burrobot
		even
Nem_Chopper:	incbin	artnem\chopper.bin	; chopper
		even
Nem_Jaws:	incbin	artnem\jaws.bin		; jaws
		even
Nem_Roller:	incbin	artnem\roller.bin	; roller
		even
Nem_Motobug:	incbin	artnem\motobug.bin	; moto bug
		even
Nem_Newtron:	incbin	artnem\newtron.bin	; newtron
		even
Nem_Yadrin:	incbin	artnem\yadrin.bin	; yadrin
		even
Nem_Basaran:	incbin	artnem\basaran.bin	; basaran
		even
Nem_Splats:	incbin	artnem\splats.bin	; splats
		even
Nem_Bomb:	incbin	artnem\bomb.bin		; bomb
		even
Nem_Orbinaut:	incbin	artnem\orbinaut.bin	; orbinaut
		even
Nem_Cater:	incbin	artnem\caterkil.bin	; caterkiller
		even
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
Nem_TitleCard:	incbin	artnem\ttlcards.bin	; title cards
		even
Nem_Hud:	incbin	artnem\hud.bin		; HUD (rings, time, score)
		even
Nem_Lives:	incbin	artnem\lifeicon.bin	; life counter icon
		even
Nem_Ring:	incbin	artnem\rings.bin	; rings
		even
Nem_Monitors:	incbin	artnem\monitors.bin	; monitors
		even
Nem_Explode:	incbin	artnem\explosio.bin	; explosion
		even
Nem_Points:	incbin	artnem\points.bin	; points from destroyed enemy or object
		even
Nem_GameOver:	incbin	artnem\gameover.bin	; game over / time over
		even
Nem_HSpring:	incbin	artnem\springh.bin	; horizontal spring
		even
Nem_VSpring:	incbin	artnem\springv.bin	; vertical spring
		even
Nem_SignPost:	incbin	artnem\signpost.bin	; end of level signpost
		even
Nem_Lamp:	incbin	artnem\lamppost.bin	; lamppost
		even
Nem_BigFlash:	incbin	artnem\rngflash.bin	; flash from giant ring
		even
Nem_Bonus:	incbin	artnem\bonus.bin	; hidden bonuses at end of a level
		even
; ---------------------------------------------------------------------------
; Compressed graphics - continue screen
; ---------------------------------------------------------------------------
Nem_ContSonic:	incbin	artnem\cntsonic.bin	; Sonic on continue screen
		even
Nem_MiniSonic:	incbin	artnem\cntother.bin	; mini Sonic and text on continue screen
		even
; ---------------------------------------------------------------------------
; Compressed graphics - animals
; ---------------------------------------------------------------------------
Nem_Rabbit:	incbin	artnem\rabbit.bin	; rabbit
		even
Nem_Chicken:	incbin	artnem\chicken.bin	; chicken
		even
Nem_BlackBird:	incbin	artnem\blackbrd.bin	; blackbird
		even
Nem_Seal:	incbin	artnem\seal.bin		; seal
		even
Nem_Pig:	incbin	artnem\pig.bin		; pig
		even
Nem_Flicky:	incbin	artnem\flicky.bin	; flicky
		even
Nem_Squirrel:	incbin	artnem\squirrel.bin	; squirrel
		even
; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
Blk16_GHZ:	incbin	map16\ghz.bin
		even
Nem_GHZ_1st:	incbin	artnem\8x8ghz1.bin	; GHZ primary patterns
		even
Nem_GHZ_2nd:	incbin	artnem\8x8ghz2.bin	; GHZ secondary patterns
		even
Blk256_GHZ:	incbin	map256\ghz.bin
		even
Blk16_LZ:	incbin	map16\lz.bin
		even
Nem_LZ:		incbin	artnem\8x8lz.bin	; LZ primary patterns
		even
Blk256_LZ:	incbin	map256\lz.bin
		even
Blk16_MZ:	incbin	map16\mz.bin
		even
Nem_MZ:		incbin	artnem\8x8mz.bin	; MZ primary patterns
		even
Blk256_MZ:	incbin	map256\mz.bin
		even
Blk16_SLZ:	incbin	map16\slz.bin
		even
Nem_SLZ:	incbin	artnem\8x8slz.bin	; SLZ primary patterns
		even
Blk256_SLZ:	incbin	map256\slz.bin
		even
Blk16_SYZ:	incbin	map16\syz.bin
		even
Nem_SYZ:	incbin	artnem\8x8syz.bin	; SYZ primary patterns
		even
Blk256_SYZ:	incbin	map256\syz.bin
		even
Blk16_SBZ:	incbin	map16\sbz.bin
		even
Nem_SBZ:	incbin	artnem\8x8sbz.bin	; SBZ primary patterns
		even
Blk256_SBZ:	incbin	map256\sbz.bin
		even
; ---------------------------------------------------------------------------
; Compressed graphics - bosses and ending sequence
; ---------------------------------------------------------------------------
Nem_Eggman:	incbin	artnem\bossmain.bin	; boss main patterns
		even
Nem_Weapons:	incbin	artnem\bossxtra.bin	; boss add-ons and weapons
		even
Nem_Prison:	incbin	artnem\prison.bin	; prison capsule
		even
Nem_Sbz2Eggman:	incbin	artnem\sbz2boss.bin	; Eggman in SBZ2 and FZ
		even
Nem_FzBoss:	incbin	artnem\fzboss.bin	; FZ boss
		even
Nem_FzEggman:	incbin	artnem\fzboss2.bin	; Eggman after the FZ boss
		even
Nem_Exhaust:	incbin	artnem\bossflam.bin	; boss exhaust flame
		even
Nem_EndEm:	incbin	artnem\endemera.bin	; ending sequence chaos emeralds
		even
Nem_EndSonic:	incbin	artnem\endsonic.bin	; ending sequence Sonic
		even
Nem_TryAgain:	incbin	artnem\tryagain.bin	; ending "try again" screen
		even
Nem_EndEggman:	incbin	artnem\xxxend.bin	; unused boss sequence on ending
		even
Kos_EndFlowers:	incbin	artkos\flowers.bin	; ending sequence animated flowers
		even
Nem_EndFlower:	incbin	artnem\endflowe.bin	; ending sequence flowers
		even
Nem_CreditText:	incbin	artnem\credits.bin	; credits alphabet
		even
Nem_EndStH:	incbin	artnem\endtext.bin	; ending sequence "Sonic the Hedgehog" text
		even
		incbin	misc\padding2.bin
		even
; ---------------------------------------------------------------------------
; Collision data
; ---------------------------------------------------------------------------
AngleMap:	incbin	collide\anglemap.bin	; floor angle map
		even
CollArray1:	incbin	collide\carray_n.bin	; normal collision array
		even
CollArray2:	incbin	collide\carray_r.bin	; rotated collision array
		even
Col_GHZ:	incbin	collide\ghz.bin		; GHZ index
		even
Col_LZ:		incbin	collide\lz.bin		; LZ index
		even
Col_MZ:		incbin	collide\mz.bin		; MZ index
		even
Col_SLZ:	incbin	collide\slz.bin		; SLZ index
		even
Col_SYZ:	incbin	collide\syz.bin		; SYZ index
		even
Col_SBZ:	incbin	collide\sbz.bin		; SBZ index
		even
; ---------------------------------------------------------------------------
; Special layouts
; ---------------------------------------------------------------------------
SS_1:		incbin	sslayout\1.bin
		even
SS_2:		incbin	sslayout\2.bin
		even
SS_3:		incbin	sslayout\3.bin
		even
SS_4:		incbin	sslayout\4.bin
		even
SS_5:		incbin	sslayout\5.bin
		even
SS_6:		incbin	sslayout\6.bin
		even
; ---------------------------------------------------------------------------
; Animated uncompressed graphics
; ---------------------------------------------------------------------------
Art_GhzWater:	incbin	artunc\ghzwater.bin	; GHZ waterfall
		even
Art_GhzFlower1:	incbin	artunc\ghzflowl.bin	; GHZ large flower
		even
Art_GhzFlower2:	incbin	artunc\ghzflows.bin	; GHZ small flower
		even
Art_MzLava1:	incbin	artunc\mzlava1.bin	; MZ lava surface
		even
Art_MzLava2:	incbin	artunc\mzlava2.bin	; MZ lava
		even
Art_MzTorch:	incbin	artunc\mztorch.bin	; MZ torch in background
		even
Art_SbzSmoke:	incbin	artunc\sbzsmoke.bin	; SBZ smoke in background
		even

; ---------------------------------------------------------------------------
; Level	layout index
; ---------------------------------------------------------------------------
Level_Index:	dc.w Level_GHZ1-Level_Index, Level_GHZbg-Level_Index, byte_68D70-Level_Index
		dc.w Level_GHZ2-Level_Index, Level_GHZbg-Level_Index, byte_68E3C-Level_Index
		dc.w Level_GHZ3-Level_Index, Level_GHZbg-Level_Index, byte_68F84-Level_Index
		dc.w byte_68F88-Level_Index, byte_68F88-Level_Index, byte_68F88-Level_Index
		dc.w Level_LZ1-Level_Index, Level_LZbg-Level_Index, byte_69190-Level_Index
		dc.w Level_LZ2-Level_Index, Level_LZbg-Level_Index, byte_6922E-Level_Index
		dc.w Level_LZ3-Level_Index, Level_LZbg-Level_Index, byte_6934C-Level_Index
		dc.w Level_SBZ3-Level_Index, Level_LZbg-Level_Index, byte_6940A-Level_Index
		dc.w Level_MZ1-Level_Index, Level_MZ1bg-Level_Index, Level_MZ1-Level_Index
		dc.w Level_MZ2-Level_Index, Level_MZ2bg-Level_Index, byte_6965C-Level_Index
		dc.w Level_MZ3-Level_Index, Level_MZ3bg-Level_Index, byte_697E6-Level_Index
		dc.w byte_697EA-Level_Index, byte_697EA-Level_Index, byte_697EA-Level_Index
		dc.w Level_SLZ1-Level_Index, Level_SLZbg-Level_Index, byte_69B84-Level_Index
		dc.w Level_SLZ2-Level_Index, Level_SLZbg-Level_Index, byte_69B84-Level_Index
		dc.w Level_SLZ3-Level_Index, Level_SLZbg-Level_Index, byte_69B84-Level_Index
		dc.w byte_69B84-Level_Index, byte_69B84-Level_Index, byte_69B84-Level_Index
		dc.w Level_SYZ1-Level_Index, Level_SYZbg-Level_Index, byte_69C7E-Level_Index
		dc.w Level_SYZ2-Level_Index, Level_SYZbg-Level_Index, byte_69D86-Level_Index
		dc.w Level_SYZ3-Level_Index, Level_SYZbg-Level_Index, byte_69EE4-Level_Index
		dc.w byte_69EE8-Level_Index, byte_69EE8-Level_Index, byte_69EE8-Level_Index
		dc.w Level_SBZ1-Level_Index, Level_SBZ1bg-Level_Index, Level_SBZ1bg-Level_Index
		dc.w Level_SBZ2-Level_Index, Level_SBZ2bg-Level_Index, Level_SBZ2bg-Level_Index
		dc.w Level_SBZ2-Level_Index, Level_SBZ2bg-Level_Index, byte_6A2F8-Level_Index
		dc.w byte_6A2FC-Level_Index, byte_6A2FC-Level_Index, byte_6A2FC-Level_Index
		dc.w Level_End-Level_Index, Level_GHZbg-Level_Index, byte_6A320-Level_Index
		dc.w Level_End-Level_Index, Level_GHZbg-Level_Index, byte_6A320-Level_Index
		dc.w byte_6A320-Level_Index, byte_6A320-Level_Index, byte_6A320-Level_Index
		dc.w byte_6A320-Level_Index, byte_6A320-Level_Index, byte_6A320-Level_Index

Level_GHZ1:	incbin	levels\ghz1.bin
		even
byte_68D70:	dc.b 0,	0, 0, 0
Level_GHZ2:	incbin	levels\ghz2.bin
		even
byte_68E3C:	dc.b 0,	0, 0, 0
Level_GHZ3:	incbin	levels\ghz3.bin
		even
Level_GHZbg:	incbin	levels\ghzbg.bin
		even
byte_68F84:	dc.b 0,	0, 0, 0
byte_68F88:	dc.b 0,	0, 0, 0

Level_LZ1:	incbin	levels\lz1.bin
		even
Level_LZbg:	incbin	levels\lzbg.bin
		even
byte_69190:	dc.b 0,	0, 0, 0
Level_LZ2:	incbin	levels\lz2.bin
		even
byte_6922E:	dc.b 0,	0, 0, 0
Level_LZ3:	incbin	levels\lz3.bin
		even
byte_6934C:	dc.b 0,	0, 0, 0
Level_SBZ3:	incbin	levels\sbz3.bin
		even
byte_6940A:	dc.b 0,	0, 0, 0

Level_MZ1:	incbin	levels\mz1.bin
		even
Level_MZ1bg:	incbin	levels\mz1bg.bin
		even
Level_MZ2:	incbin	levels\mz2.bin
		even
Level_MZ2bg:	incbin	levels\mz2bg.bin
		even
byte_6965C:	dc.b 0,	0, 0, 0
Level_MZ3:	incbin	levels\mz3.bin
		even
Level_MZ3bg:	incbin	levels\mz3bg.bin
		even
byte_697E6:	dc.b 0,	0, 0, 0
byte_697EA:	dc.b 0,	0, 0, 0

Level_SLZ1:	incbin	levels\slz1.bin
		even
Level_SLZbg:	incbin	levels\slzbg.bin
		even
Level_SLZ2:	incbin	levels\slz2.bin
		even
Level_SLZ3:	incbin	levels\slz3.bin
		even
byte_69B84:	dc.b 0,	0, 0, 0

Level_SYZ1:	incbin	levels\syz1.bin
		even
Level_SYZbg:	incbin	levels\syzbg.bin
		even
byte_69C7E:	dc.b 0,	0, 0, 0
Level_SYZ2:	incbin	levels\syz2.bin
		even
byte_69D86:	dc.b 0,	0, 0, 0
Level_SYZ3:	incbin	levels\syz3.bin
		even
byte_69EE4:	dc.b 0,	0, 0, 0
byte_69EE8:	dc.b 0,	0, 0, 0

Level_SBZ1:	incbin	levels\sbz1.bin
		even
Level_SBZ1bg:	incbin	levels\sbz1bg.bin
		even
Level_SBZ2:	incbin	levels\sbz2.bin
		even
Level_SBZ2bg:	incbin	levels\sbz2bg.bin
		even
byte_6A2F8:	dc.b 0,	0, 0, 0
byte_6A2FC:	dc.b 0,	0, 0, 0
Level_End:	incbin	levels\ending.bin
		even
byte_6A320:	dc.b 0,	0, 0, 0

; ---------------------------------------------------------------------------
; Animated uncompressed giant ring graphics
; ---------------------------------------------------------------------------
Art_BigRing:	incbin	artunc\bigring.bin
		even

; ---------------------------------------------------------------------------
; Sprite locations index
; ---------------------------------------------------------------------------
ObjPos_Index:	dc.w ObjPos_GHZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_FZ-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ1pf1-ObjPos_Index, ObjPos_LZ1pf2-ObjPos_Index
		dc.w ObjPos_LZ2pf1-ObjPos_Index, ObjPos_LZ2pf2-ObjPos_Index
		dc.w ObjPos_LZ3pf1-ObjPos_Index, ObjPos_LZ3pf2-ObjPos_Index
		dc.w ObjPos_LZ1pf1-ObjPos_Index, ObjPos_LZ1pf2-ObjPos_Index
		dc.w ObjPos_SBZ1pf1-ObjPos_Index, ObjPos_SBZ1pf2-ObjPos_Index
		dc.w ObjPos_SBZ1pf3-ObjPos_Index, ObjPos_SBZ1pf4-ObjPos_Index
		dc.w ObjPos_SBZ1pf5-ObjPos_Index, ObjPos_SBZ1pf6-ObjPos_Index
		dc.w ObjPos_SBZ1pf1-ObjPos_Index, ObjPos_SBZ1pf2-ObjPos_Index
		dc.b $FF, $FF, 0, 0, 0,	0
ObjPos_GHZ1:	incbin	objpos\ghz1.bin
		even
ObjPos_GHZ2:	incbin	objpos\ghz2.bin
		even
ObjPos_GHZ3:	incbin	objpos\ghz3.bin
		even
ObjPos_LZ1:	incbin	objpos\lz1.bin
		even
ObjPos_LZ2:	incbin	objpos\lz2.bin
		even
ObjPos_LZ3:	incbin	objpos\lz3.bin
		even
ObjPos_SBZ3:	incbin	objpos\sbz3.bin
		even
ObjPos_LZ1pf1:	incbin	objpos\lz1pf1.bin
		even
ObjPos_LZ1pf2:	incbin	objpos\lz1pf2.bin
		even
ObjPos_LZ2pf1:	incbin	objpos\lz2pf1.bin
		even
ObjPos_LZ2pf2:	incbin	objpos\lz2pf2.bin
		even
ObjPos_LZ3pf1:	incbin	objpos\lz3pf1.bin
		even
ObjPos_LZ3pf2:	incbin	objpos\lz3pf2.bin
		even
ObjPos_MZ1:	incbin	objpos\mz1.bin
		even
ObjPos_MZ2:	incbin	objpos\mz2.bin
		even
ObjPos_MZ3:	incbin	objpos\mz3.bin
		even
ObjPos_SLZ1:	incbin	objpos\slz1.bin
		even
ObjPos_SLZ2:	incbin	objpos\slz2.bin
		even
ObjPos_SLZ3:	incbin	objpos\slz3.bin
		even
ObjPos_SYZ1:	incbin	objpos\syz1.bin
		even
ObjPos_SYZ2:	incbin	objpos\syz2.bin
		even
ObjPos_SYZ3:	incbin	objpos\syz3.bin
		even
ObjPos_SBZ1:	incbin	objpos\sbz1.bin
		even
ObjPos_SBZ2:	incbin	objpos\sbz2.bin
		even
ObjPos_FZ:	incbin	objpos\fz.bin
		even
ObjPos_SBZ1pf1:	incbin	objpos\sbz1pf1.bin
		even
ObjPos_SBZ1pf2:	incbin	objpos\sbz1pf2.bin
		even
ObjPos_SBZ1pf3:	incbin	objpos\sbz1pf3.bin
		even
ObjPos_SBZ1pf4:	incbin	objpos\sbz1pf4.bin
		even
ObjPos_SBZ1pf5:	incbin	objpos\sbz1pf5.bin
		even
ObjPos_SBZ1pf6:	incbin	objpos\sbz1pf6.bin
		even
ObjPos_End:	incbin	objpos\ending.bin
		even
ObjPos_Null:	dc.b $FF, $FF, 0, 0, 0,	0
; ===========================================================================

		include "driver/code/smps2asm.asm"
		include "driver/code/68k.asm"

DualPCM:
		PUSHS					; store section information for Main
Z80Code		SECTION	org(0), file("driver/.Z80")	; create a new section for Dual PCM
		z80prog 0				; init z80 program
		include "driver/code/z80.asm"		; code for Dual PCM
DualPCM_sz:	z80prog					; end z80 program
		POPS					; go back to Main section

		PUSHS					; store section information for Main
batcode		SECTION	file("driver/z80.bat"), org(0)	; create a new section for a batch file, that will insert compressed Dual PCM
dpcm equ	offset(DualPCM)

	dc.b "@echo off", $0A
	if zchkoffs
		dc.b "asm68k /p driver/fix.asm, driver/._z80", $0A				; fix the z80 code (since we can't use org, lets fire another assembler... Fuck)
	endif
	dc.b "_dlls\koscmp.exe driver/._z80 driver/.z80.kos", $0A				; compress Z80 driver
	dc.b "call :setsize ""driver/.z80.kos""", $0A						; get size of the compressed file
	dc.b "if %size% GTR \#Z80_Space (", $0A							; check if file will fit
	dc.b "echo Not enough space reserved for Z80 file! Please increase it to %size%!",$0A	; warn user about file size
	dc.b "pause", $0A, "exit", $0A, ")", $0A
	dc.b "echo 	incbin s1built.dat, 0, \#dpcm >driver/merge.asm",$0A			; include first part of s1built.md
	dc.b "echo 	incbin driver/.z80.kos >>driver/merge.asm",$0A				; include compressed driver
	dc.b "echo 	incbin s1built.dat, \#dpcm+\#Z80_Space >>driver/merge.asm",$0A		; include second part of s1built.md
	dc.b "asm68k /p driver/merge.asm, s1built.md", $0A					; finally, merge the files. Why do I keep doing things like this =(
	dc.b ":setsize", $0A
	dc.b "set size=%~z1 & goto :eof"							; grab the file size
		POPS					; go back to Main section

	if zchkoffs
		PUSHS					; store section information for Main
mergecode	SECTION	file("driver/fix.asm"), org(0)	; create a new section for a batch file, that will insert compressed Dual PCM
		dc.b "	org 0", $0A			; this makes sure the assembler works
		dc.b "	incbin ""driver/.z80""", $0A	; include the uncompressed z80 data here

		rept zfuturec
			popp zoff			; grab the location of the include
			popp zbyte			; grab the included byte

zderp = zoff
zherp = zbyte
			dc.b "	org \#zderp", $0A	; write the org statement
			dc.b "	dc.b \#zherp", $0A	; dc.b the fixed byte in
		endr

		dc.b "	END"				; end the assembly
		POPS					; go back to Main section
	endif

	ds.b Z80_Space					; reserve space for the Z80 driver
	even
	opt ae+
		include	"error/ErrorHandler.asm"
EndOfRom:	END
