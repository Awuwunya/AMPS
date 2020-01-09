EntryPoint:
		tst.l	HW_Port_1_Control-1	; test port A control
		bne.s	PortA_Ok
		tst.w	HW_Expansion_Control-1	; test port C control

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
		move.b	d0,(HW_Port_1_Control).l
		move.b	d0,(HW_Port_2_Control).l
		move.b	d0,(HW_Expansion_Control).l
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
		ld	hl,YM_Buffer1			; we need to clear from YM_Buffer1
		ld	de,(YM_BufferEnd-YM_Buffer1)/8	; to end of Z80 RAM, setting it to 0FFh

	.loop:
		rept 8
			dec	(hl)			; set address to 0FFh
			inc	hl			; go to next address
		endr

		dec	de				; decrease loop counter
		ld	a,d				; load d to a
		zor	e				; check if both d and e are 0
		jr	nz, .loop			; if no, clear more memoty
		jr	*				; trap CPU execution
	z80prog
		even
endinit
		dc.w $8174			; value	for VDP	display	mode
		dc.w $8F02			; value	for VDP	increment
		dc.l $C0000000			; value	for CRAM write mode
		dc.l $40000010

		dc.b $9F, $BF, $DF, $FF	; values for PSG channel volumes
; ===========================================================================

Textinit:
	asc.w 0,"TIMER"
	asc.w 0,"TEMPO"
	asc.w 0,"VOLUME"
	asc.w 0,"DAC1"
	asc.w 0,"DAC2"
	asc.w 0," FM1"
	asc.w 0," FM2"
	asc.w 0," FM3"
	asc.w 0," FM4"
	asc.w 0," FM5"

	if FEATURE_FM6
		asc.w 0," FM6"
	endif

	asc.w 0,"PSG1"
	asc.w 0,"PSG2"
	asc.w 0,"PSG3"
	asc.w 0,"MUS"
	asc.w 0,"DMA"
	asc.w 0,"COMM"
; ===========================================================================

GameProgram:
		move.w	SetupValues+2(pc),d0	; get length
		moveq	#0,d1			; fill with 0
		move.w	d1,a0			; reset RAM pos

.loop		move.l	d1,-(a0)		; clear next word of RAM
		dbf	d0,.loop		; clear entire RAM
		move.w	#Stack,sp		; reset stack ptr

	; load palette
		lea	SystemPalette(pc),a0	; get system palette
		lea	Palette.w,a1		; get the palette file
		moveq	#3-1,d1			; get length

.load2		move.w	(a0)+,(a1)+		; copy 1 entry
		dbf	d1,.load2		; loop until done

	; fill entire VRAM with 0
		lea	VDP_control_port,a6
		lea	-4(a6),a5		; get ports
		dmaFillVRAM 0,$10000,0,0

	; load system font
		lea	SystemFont,a0		; get system font
		lea	Buffer,a1		; get start of RAM
		jsr	KosDec			; decompress the art

	; init RAM
		move.b	HW_Version,d0		; get System version bits
		andi.b	#$C0,d0
		move.b	d0,ConsoleRegion.w	; save into RAM

		move.w	#2,DMAlen.w		; reset len
		move.b	#MusOff,MusSel.w	; set selected music

	; wait for vram fill to finish
		lea	VDP_control_port,a6
		lea	-4(a6),a5		; get ports

.waitFillDone	move.w	(a6),d1
		btst	#1,d1
		bne.s	.waitFillDone
		move.w	#$8F02,(a6) 		; VRAM pointer increment: $0002

	dma68kToVDP $FF0000,$20,$BE0,VRAM	; DMA font art

	; clear VSRAM
;	vdpComm	move.l,0,VSRAM,WRITE,(a6)
;		move.l	d0,(a5)

	; set WINDOW
		move.w	#$8F80,(a6)
	vdpComm	move.l,$F04E,VRAM,WRITE,(a6)
		move.l	#$005F005F,d0
	rept 28/2
		move.l	d0,(a5)
	endr
		move.w	#$8F02,(a6)

	; write some maps
		lea	Textinit(pc),a0		; get text data to a0

	vdpCoord 1,1,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)
		move.w	(a0)+,(a5)

	vdpCoord 1,2,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)
		move.w	(a0)+,(a5)

	vdpCoord 1,3,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)

	vdpCoord 1,5,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)

	vdpCoord 1,6,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)

	vdpCoord 1,7,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)

	vdpCoord 1,8,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)

	vdpCoord 1,9,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)

	vdpCoord 1,10,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)

	vdpCoord 1,11,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)

	vdpCoord 1,12,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)

	vdpCoord 1,13,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)

	vdpCoord 1,14,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)

	if FEATURE_FM6
		vdpCoord 1,15,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)
	endif

	vdpCoord 1,24,WRITE
		move.l	(a0)+,(a5)
		move.w	(a0)+,(a5)

	vdpCoord 1,25,WRITE
		move.l	(a0)+,(a5)
		move.w	(a0)+,(a5)

	vdpCoord 1,26,WRITE
		move.l	(a0)+,(a5)
		move.l	(a0)+,(a5)

		jsr	LoadDualPCM	; load dual pcm
@mainloop	stop	#$2300		; enable ints and stop CPU
		bra.s	@mainloop	; loop
; ===========================================================================
