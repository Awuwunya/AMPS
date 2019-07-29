dlen:	dc.w 0, $80, $680, $900, $1000, $2000

DrawScene:
	vdpCoord 8,1,WRITE
		moveq	#4-1,d6			; digit ct
		move.w	Frame.w,d3		; get frame num
		jsr	PutHex.w		; write it onscreen

	vdpCoord 6,25,WRITE
		moveq	#4-1,d6			; digit ct
		move.w	DMAlen.w,d3		; get dma len
		move.w	dlen(pc,d3.w),d3	; translate to actual num
		jsr	PutHex.w		; write it onscreen

	vdpCoord 6,26,WRITE
		moveq 	#0,d7
		moveq	#8-1,d2			; set repeat count
		lea	mComm.w,a0		; get comm bytes

.comm		moveq	#2-1,d6			; digit ct
		move.b	(a0)+,d3		; get next num
		jsr	PutHex.w		; write it onscreen
		move.w	d7,(a5)			; write 1 space
		dbf	d2,.comm		; loop

		lea	.list(pc),a0		; get data list to a0

	vdpCoord 6,24,WRITE
		moveq	#2-1,d2			; set rept count
		bsr.w	.writeb			; write music selection

	vdpCoord 8,2,WRITE
		moveq	#4-1,d2			; set rept count
		bsr.w	.writeb			; write tempo data

	vdpCoord 8,3,WRITE
		moveq	#3-1,d2			; set rept count
		bsr.w	.writeb			; write volume data

.p =	5
	rept Mus_Ch
		vdpCoord 6,.p,WRITE
		moveq	#9-1+FEATURE_PORTAMENTO,d2; set rept count
		bsr.w	.writeb			; write data
.p =		.p+1
	endr
		rts

.writeb		move.w	(a0)+,a1		; get addr
		move.w	a1,d3			; check addr
		bmi.s	.norm			; if negative, branch
		jsr	.rt(pc,d3.w)		; jump to appropriate routine
		bra.s	.write

.norm		moveq	#2-1,d6			; digit ct
		move.b	(a1),d3			; get byte
.write		jsr	PutHex.w		; write it onscreen
		move.w	d7,(a5)			; write 1 space
		dbf	d2,.writeb		; loopdeloop
		rts

.rt		moveq	#4-1,d6			; digit ct
		move.w	(a0)+,a1		; get actual addr
		move.w	(a1)+,d3		; get value as a word
		rts

.modf		moveq	#4-1,d6			; digit ct
		move.w	(a0)+,a1		; get actual addr
		move.b	cDetune(a1),d3		; get detune
		ext.w	d3			; extend to word
		add.w	cFreq(a1),d3		; add frequency

	if FEATURE_MODULATION
		add.w	cModFreq(a1),d3		; add modulation frequency
	endif

	if FEATURE_PORTAMENTO
		add.w	cPortaFreq(a1),d3	; add portamento frequency offset
	endif
		rts

.list	dc.w MusSel, MusPlay
	dc.w mTempo, mTempoMain, mTempoSpeed, mTempoCur
	dc.w mMasterVolFM, mMasterVolPSG, mMasterVolDAC

.ch =	mDAC1
	rept Mus_Ch
		if FEATURE_PORTAMENTO
			dc.w .ch+cPortaSpeed
		endif

		dc.w .ch, .ch+cPanning, .ch+cPitch, .ch+cVolume
		dc.w .ch+cVoice, .ch+cLastDur, .ch+cDuration
		dc.w 0, .ch+cFreq, .modf-.rt, .ch
.ch =		.ch+cSize
	endr
