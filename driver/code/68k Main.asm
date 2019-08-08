; ===========================================================================
; ---------------------------------------------------------------------------
; Normal fade out data
; ---------------------------------------------------------------------------

dFadeOutDataLog:
	dc.b $01, $02, $01,  $02, $02, $02,  $02, $02, $02,  $03, $02, $03
	dc.b $04, $05, $04,  $04, $05, $04,  $05, $05, $05,  $06, $05, $06
	dc.b $07, $09, $07,  $09, $09, $09,  $0A, $09, $0A,  $0C, $09, $0C
	dc.b $0E, $11, $0E,  $10, $11, $10,  $11, $11, $11,  $14, $11, $14
	dc.b $16, $1B, $16,  $1A, $1B, $1A,  $1C, $1B, $1C,  $20, $1B, $20
	dc.b $22, $28, $22,  $26, $28, $26,  $2C, $28, $2C,  $30, $28, $30
	dc.b $34, $3E, $34,  $3C, $3E, $3C,  $40, $3E, $40,  $46, $3E, $46
	dc.b $4C, $58, $4C,  $54, $58, $54,  $5C, $58, $5C,  $60, $58, $60
	dc.b $6C, $7F, $6C,  $74, $7F, $74,  $7F, $7F, $7F,  fReset

	if FEATURE_BACKUP		; this data is only needed when backup feature is enabled also.
dFadeInDataLog:				; you may enable this regardless for personal uses
	dc.b $7F, $7F, $7F,  $74, $7F, $74,  $6C, $7F, $6C,  $60, $7F, $60
	dc.b $5C, $50, $5C,  $54, $50, $54,  $4C, $50, $4C,  $46, $50, $46
	dc.b $40, $38, $40,  $3C, $38, $3C,  $34, $38, $34,  $30, $38, $30
	dc.b $2C, $24, $2C,  $26, $24, $26,  $22, $24, $22,  $20, $24, $20
	dc.b $1C, $18, $1C,  $1A, $18, $1A,  $16, $18, $16,  $14, $18, $14
	dc.b $11, $0F, $11,  $10, $0F, $10,  $0E, $0F, $0E,  $0C, $0F, $0C
	dc.b $0A, $08, $0A,  $09, $08, $09,  $07, $08, $07,  $06, $08, $06
	dc.b $05, $05, $05,  $04, $05, $04,  $04, $05, $04,  $03, $05, $03
	dc.b $02, $02, $02,  $02, $02, $02,  $01, $02, $01,  $00, $00, $00
	dc.b fEnd
	endif

;dFadeOutDataLinear:
;	dc.b $01, $00, $00,  $02, $01, $00,  $02, $01, $01,  $03, $02, $01
;	dc.b $04, $02, $01,  $04, $03, $02,  $05, $03, $02,  $06, $04, $02
;	dc.b $07, $05, $03,  $09, $06, $03,  $0A, $08, $03,  $0C, $0A, $03
;	dc.b $0E, $0D, $04,  $10, $0F, $04,  $11, $10, $04,  $14, $13, $05
;	dc.b $16, $16, $05,  $1A, $1A, $05,  $1C, $1E, $06,  $20, $22, $06
;	dc.b $22, $27, $07,  $26, $2A, $07,  $2C, $2E, $08,  $30, $34, $08
;	dc.b $34, $39, $09,  $3C, $3E, $0A,  $40, $3F, $0A,  $46, $40, $0B
;	dc.b $4C, $40, $0C,  $54, $40, $0D,  $5C, $40, $0D,  $60, $40, $0E
;	dc.b $6C, $40, $0E,  $74, $40, $0F,  $7F, $40, $0F,  fReset
	even
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine for initializing a fade effect.
; Since the driver allows for such an extensive and customizable
; fading code, we may hit a snag if we use fades too fast. It is
; possible, for example, to fade out, then in the middle of that,
; start fading in. This would normally cause a quick jump in the
; volume level from maybe half to completely mute. This routine
; aims to combat this by actually searching for the closest FM
; volume level in the fade program, and to start the new fade from
; where that byte appears. This can alter how long a volume fade
; lasts however, and if PSG and DAC volume are not correct faded,
; it may still cause a jump in their volume (especially if only,
; say, DAC fades volume). In the future, there might be a fix for
; that.
; ---------------------------------------------------------------------------

dPlaySnd_FadeOut:
		lea	dFadeOutDataLog(pc),a1	; prepare stock fade out program to a1

dLoadFade:
		move.b	mMasterVolFM.w,d0	; load FM master volume to d0
		tst.b	mFadeAddr+1.w		; check if a fade program is already executing
		beq.s	.nofade			; if not, load fade as is

		move.l	a1,a2			; copy fade program address to a2
		moveq	#-1,d2			; prepare max byter difference

.find
		move.b	(a2),d1			; load the next FM volume from fade program
		bpl.s	.search			; branch if this is not a command

.nofade
		move.l	a1,mFadeAddr.w		; save new fade program address to memory
		move.b	d0,mMasterVolFM.w	; put vol back
		rts

.search
		addq.l	#3,a2			; skip over the current volume group
		sub.b	d0,d1			; sub current FM volume from read volume
		bpl.s	.abs			; if positive, do not negate
		neg.b	d1			; negative to positive

.abs
		cmp.b	d2,d1			; check if volume difference was smaller than before
		bhs.s	.find			; if not, read next group

		move.b	d1,d2			; else save the new difference
		move.l	a2,a1			; also save the fade program address where we found it
		bra.s	.find			; loop through each group in the program
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for loading a volume filter into Dual PCM ROM.
; This routine will actually write the bank number the volume filter
; is in. This requires volume filters are aligned to Z80 banks, and
; just because we can, we write 9 bits (yeah its not necessary, but
; what the hell, you have to have fun sometimes!)
; ---------------------------------------------------------------------------

dSetFilter:
		lea	dZ80+SV_VolumeBank,a1	; load volume bank instructions address to a1
		moveq	#$74,d1			; prepare the "ld  (hl),h" instruction to d1
		moveq	#9-1,d2			; prepare number of instructions to write to d2
	StopZ80					; wait for Z80 to stop
; ---------------------------------------------------------------------------
; addx in Motorola 68000 is much like adc in Z80. It allows us to add
; a register AND the carry to another register. What this means, is if
; we push 1 into carry (so, carry set), we will be loading $75 instead
; of $74 into the carry, making us able to switch between the Z80
; instructions  "ld  (hl),h" and "ld  (hl),l", which in turn allows
; Dual PCM to bank switch into the appropriate bank.
; ---------------------------------------------------------------------------

.loop
		moveq	#0,d3			; prepare 0 into d3 (because of addx)
		lsr.w	#1,d0			; shift lsb into carry
		addx.b	d1,d3			; add instruction and carry into d3

		move.b	d3,(a1)+		; save instruction into Z80 memory
		dbf	d2,.loop		; repeat for each bit/instruction
	StartZ80				; enable Z80 execution

locret_SetFilter:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine to multiply duration by tick rate
; We actually use a dbf loop instead of mulu, because 2 rounds
; around the loop will be faster than a single mulu instruction
; ---------------------------------------------------------------------------

dCalcDuration:
		moveq	#0,d0			; clear duration
		moveq	#0,d1			; clear upper bytes (for dbf)
		move.b	cTick(a5),d1		; get tick multiplier to d1

.multiply
		add.b	d5,d0			; add duration value to d0
		dbf	d1,.multiply		; multiply by tick rate

		move.b	d0,cLastDur(a5)		; save as the new duration
		rts				; get copied to duration by later code
; ===========================================================================
; ---------------------------------------------------------------------------
; Handle Dual PCM YM Cue correctly
; ---------------------------------------------------------------------------

UpdateAMPS:
	StopZ80					; wait for Z80 to stop
		move.b	dZ80+YM_Buffer,d0	; load current cue buffer in use
	StartZ80				; enable Z80 execution

		move.l	#dZ80+YM_Buffer1,a0	; set the cue address to buffer 1
		tst.b	d0			; check buffer to use
		bne.s	.gotbuffer		; if Z80 is reading buffer 2, branch
		add.w	#YM_Buffer2-YM_Buffer1,a0; set the cue address to buffer 2

.gotbuffer
		bsr.s	dUpdateAllAMPS		; process the driver
	if safe=1				; this must always happen at the end
		AMPS_Debug_CuePtr 3		; check if the cue is still valid
	endif

	StopZ80					; wait for Z80 to stop
		st	(a0)			; make sure cue is marked as completed
	StartZ80				; enable Z80 execution

dPaused:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Main routine for updating the AMPS driver
; ---------------------------------------------------------------------------

dUpdateAllAMPS:
		jsr	dPlaySnd(pc)		; check if any music needs playing
		tst.b	mFlags.w		; is music paused?
		bmi.s	dPaused			; if yes, branch
; ---------------------------------------------------------------------------
; This is the new fading feature I created, to make custom fading
; types easier to program. You can define series of 3 bytes, each
; representing FM, PSG and DAC volumes. Each group of 3 is executed
; once per frame. If the first value in a frame is a command flag,
; instead its code is executed. Additionally, no fade program may
; appear before ROM offset $10000, or else it will never be executed.
; ---------------------------------------------------------------------------

.notempo	tst.b	mFadeAddr+1.w		; check if a fade program is already executing
	if safe=1
		beq.w	.chkregion		; branch if not
	else
		beq.s	.chkregion		; branch if not
	endif

		move.l	mFadeAddr.w,a1		; get the fade porogram address to a1
		addq.l	#3,mFadeAddr.w		; set the fade address to next group

		moveq	#(1<<cfbVol),d1		; prepare volume update to d1
		moveq	#0,d0
		move.b	(a1)+,d0		; get FM/command byte from fade data
		bpl.s	.nofadeend		; branch if this is not a command

	if safe=1
		AMPS_Debug_FadeCmd		; check if this command is valid
	endif
		lea	dFadeCommands(pc),a2	; load fade commands pointer table to a2
		jsr	-$80(a2,d0.w)		; run the fade command code
		clr.b	mFadeAddr+1.w		; mark the fade program as completed
		bra.s	.chkregion		; go check the region

.nofadeend
		cmp.b	mMasterVolFM.w,d0	; check if volume did not change
		beq.s	.fadedac		; if did not, branch
		move.b	d0,mMasterVolFM.w	; save the new volume
		jsr	dReqVolUpFM(pc)		; go request volume update for FM

.fadedac
		move.b	(a1)+,d0		; get DAC volume byte from fade data
		cmp.b	mMasterVolDAC.w,d0	; check if volume did not change
		beq.s	.fadepsg		; if did not, branch
		move.b	d0,mMasterVolDAC.w	; save new volume

.ch =	mDAC1					; start at DAC1
	rept Mus_DAC				; do for all music DAC channels
		or.b	d1,.ch.w		; tell the channel to update its volume
.ch =		.ch+cSize			; go to next channel
	endr
		or.b	d1,mSFXDAC1.w		; tell SFX DAC1 to update its volume

.fadepsg
		move.b	(a1)+,d0		; get PSG volume byte from fade data
		cmp.b	mMasterVolPSG.w,d0	; check if volume did not change
		beq.s	.chkregion		; if did not, branch
		move.b	d0,mMasterVolPSG.w	; save new volume

.ch =	mPSG1					; start at PSG1
	rept Mus_PSG				; do for all music PSG channels
		or.b	d1,.ch.w		; tell the channel to update its volume
.ch =		.ch+cSize			; go to next channel
	endr

.ch =	mSFXPSG1				; start at SFX PSG1
	rept SFX_PSG				; do for all SFX PSG channels
		or.b	d1,.ch.w		; tell the channel to update its volume
.ch =		.ch+cSizeSFX			; go to next channel
	endr
; ---------------------------------------------------------------------------
; Since PAL Mega Drive's run slower than NTSC, if we want the music to
; sound consistent, we need to run the sound driver 1.2 times as fast
; on PAL systems. This will cause issues with some songs that rely on
; game engine to seem "in sync". Because of that, I added a flag to
; disable the PAL fix (much like in Sonic 2's driver). Unlike the fix
; in SMPS drivers (and Sonic 3 and above), this fix will make the music
; play at the exact right speed, instead of slightly too slow.
; ---------------------------------------------------------------------------

.chkregion	btst	#6,ConsoleRegion.w	; is this PAL system?
		beq.s	.driver			; if not, branch
		subq.b	#1,mCtrPal.w		; decrease PAL frame counter
		bgt.s	.driver			; if hasn't become 0 (or lower!), branch

		btst	#mfbNoPAL,mFlags.w	; check if we have disabled the PAL fix
		bne.s	.nofix			; if yes, run music and SFX
		bsr.s	.driver			; run the sound driver

.nofix
		move.b	#6-1,mCtrPal.w		; reset counter
.driver
	; continue to run sound driver again
; ---------------------------------------------------------------------------
; There are 2 methods of handling tempo adjustments in SMPS,
; overflow (where a value is added to the accumulator, and when it
; range overflows, tick of delay is added), and counter (where a
; counter is copied to the tempo, which is then decreased each frame,
; until it becomes 0, after which a tick of delay is added). AMPS
; supports these both too, because there is no single right answer,
; and users may prefer one over the other. The overflow method is
; really good for low values, as it provides very fine control over
; the tempo, but at high ranges it gets worse. Meanwhile the counter
; method isn't as good for small values, but for large value it works
; better. You may choose this setting in the macro.asm file,
; ---------------------------------------------------------------------------

	if tempo=0	; Overflow method
		move.b	mTempo.w,d0		; get tempo to d0
		add.b	d0,mTempoCur.w		; add to accumulator
		bcc.s	dAMPSdoDAC		; if carry clear, branch

	else		; Counter method
		subq.b	#1,mTempoCur.w		; sub 1 from counter
		bne.s	dAMPSdoDAC		; if nonzero, branch
		move.b	mTempo.w,mTempoCur.w	; copy tempo again
	endif

.ch =	mDAC1+cDuration				; start at DAC1 duration
	rept Mus_Ch				; loop through all music channels
		addq.b	#1,.ch.w		; add 1 to duration
.ch =		.ch+cSize			; go to next channel
	endr
