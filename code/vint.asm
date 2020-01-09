VInt:
		bsr.w	ReadControllers		; read controller input

		btst	#2,Ctrl1Press.w		; check if pressing left
		beq.s	.nol			; if no, branch
		subq.b	#1,MusSel.w		; decrease selection

.nol		btst	#3,Ctrl1Press.w		; check if pressing right
		beq.s	.nor			; if no, branch
		addq.b	#1,MusSel.w		; icnrease selection

.nor		btst	#0,Ctrl1Hold.w		; check if pressing up
		beq.s	.nou			; if no, branch
		subq.b	#1,mMasterVolDAC.w	; increase volume
		bpl.s	.copyvol		; if positive, copy vol
		clr.b	mMasterVolDAC.w		; reset to 0
		bra.s	.copyvol

.nou		btst	#1,Ctrl1Hold.w		; check if pressing down
		beq.s	.nod			; if no, branch
		addq.b	#1,mMasterVolDAC.w	; increase volume
		bpl.s	.copyvol		; if positive, copy vol
		move.b	#$7F,mMasterVolDAC.w	; reset to 0

.copyvol	move.b	mMasterVolDAC.w,d0	; get vol to d0
		move.b	d0,mMasterVolFM.w	; copy to FM
		move.b	d0,mMasterVolPSG.w	; copy to PSG
		jsr	dUpdateVolumeAll	; update all volume

.nod		btst	#6,Ctrl1Press.w		; check if pressing A
		beq.s	.noA			; if no, branch
		addq.w	#2,DMAlen.w		; icnrease DMA len

		cmp.w	#$C,DMAlen.w		; check if max
		blt.s	.noA			; if no, branch
		clr.w	DMAlen.w		; clear dma len

.noA		btst	#4,Ctrl1Press.w		; check if pressing B
		beq.s	.noB			; if no, branch
		move.b	#Mus_FadeOut,mQueue.w	; fade out music
		move.b	mQueue.w,MusPlay.w	;

.noB		tst.b	Ctrl1Press.w		; check if pressed
		bpl.s	.noprs			; if not, branch
		move.b	MusSel.w,mQueue.w	; copy music to queue
		move.b	MusSel.w,MusPlay.w	; update music played

.noprs		addq.w	#1,Frame.w		; advance frame timer
		tst.w	DMAlen.w		; check if dmalen = 0
		beq.s	.skip			; if so, do not even stop z80

		move.w	DMAlen.w,d0		; get DMA length setting
		move.w	.offs-2(pc,d0.w),d1	; get offset to the routine
		jsr	.offs(pc,d1.w)		; jump to it

.skip		cmp.b	#4,4(a6)		; check v-counter
		blt.s	.skip			; if not positive, wait

		move.w	#$9193,(a6)		; enable window
		jsr	UpdateAMPS		; update driver crap
		lea	VDP_control_port,a6
		lea	-4(a6),a5

		move.w	#$9100,(a6)		; disable window
		jsr	DrawScene.w		; draw all text n shit
		rte

.offs	dc.w dma_0x80-.offs
	dc.w dma_0x680-.offs
	dc.w dma_0x900-.offs
	dc.w dma_0x1000-.offs
	dc.w dma_0x2000-.offs
; ===========================================================================

ReadControllers:
		lea	Ctrl1Hold.w,a0		; get held buttons array
		lea	HW_Port_1_Data,a1
		bsr.s	.readone		; poll first controller
		addq.w	#2,a1			; poll second controller

.readone	move.b	#0,(a1)			; Poll controller data port
		or.l	d0,d0
		move.b	(a1),d0			; Get controller port data (start/A)
		lsl.b	#2,d0
		andi.b	#$C0,d0
		move.b	#$40,(a1)		; Poll controller data port again
		or.l	d0,d0
		move.b	(a1),d1			; Get controller port data (B/C/Dpad)
		andi.b	#$3F,d1
		or.b	d1,d0			; Fuse together into one controller bit array
		not.b	d0
		move.b	(a0),d1			; Get press button data
		eor.b	d0,d1			; Toggle off buttons that are being held
		move.b	d0,(a0)+		; Put raw controller input (for held buttons) in F604/F606
		and.b	d0,d1
		move.b	d1,(a0)+		; Put pressed controller input in RAM
		rts
; ===========================================================================

dma_0x2000:	dma68kToVDP 0,$400*32,$1000,VRAM
dma_0x1000:	dma68kToVDP 0,$400*32,$700,VRAM
dma_0x900:	dma68kToVDP 0,$400*32,$280,VRAM
dma_0x680:	dma68kToVDP 0,$400*32,$600,VRAM
dma_0x80:	dma68kToVDP Palette,0,$80,CRAM		; DMA palette to CRAM
		rts
