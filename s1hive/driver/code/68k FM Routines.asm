; ===========================================================================
; ---------------------------------------------------------------------------
; Mute all FM channels
; ---------------------------------------------------------------------------

dMuteFM:
		moveq	#$28,d0			; YM address: Key on/off
		moveq	#%00000010,d3		; turn keys off, and start from YM channel 3
	stopZ80
	CheckCue				; check that cue is valid

.noteoff
		move.b	d3,d1			; copy value into d1
	WriteYM1	d0, d1			; write part 1 to YM
		addq.b	#4,d1			; set this to part 2 channel
	WriteYM1	d0, d1			; write part 2 to YM
		dbf	d3,.noteoff		; loop for all 3 channel groups
; ---------------------------------------------------------------------------
; The following code will set release rate to maximum. This is to
; make sure all channels stop decaying the note and go to maximum
; attentuation immediately. It should prevent the previous song from
; making any noise after its played. The following code will also set
; all Total Level operators to maximum (mute)
; ---------------------------------------------------------------------------

.muteFM
		moveq	#$10-1,d5		; prepare the value for going to next channel to d5
		moveq	#$40,d0			; YM command: Total Level Operator 1
		moveq	#$7F,d1			; set total level to $7F (silent)
		moveq	#$FFFFFF80,d2		; YM address: Release Rate Operator 1
		moveq	#$F,d6			; release rate value
		moveq	#3-1,d4			; prepare 3 groups of channels to d4

.chloop
		moveq	#4-1,d3			; prepare 4 operator writes per channel to d3

.oploop
	WriteYM1	d0, d1			; write part 1 to YM
	WriteYM2	d0, d1			; write part 2 to YM
		addq.w	#4,d0			; go to next Total Level operator (1 2 3 4)

	WriteYM1	d2, d6			; write part 1 to YM
	WriteYM2	d2, d6			; write part 2 to YM
		addq.w	#4,d2			; go to next Release Rate operator (1 2 3 4)
		dbf	d3,.oploop		; repeat for each operator

		sub.b	d5,d0			; go to next FM channel
		sub.b	d5,d2			; go to next FM channel
		dbf	d4,.chloop		; repeat for each channel
	;	st	(a0)			; write end marker
	startZ80

locret_MuteFM:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine for updating Total Levels for FM channel
; ---------------------------------------------------------------------------

dUpdateVolFM_SFX:
	if FEATURE_SFX_MASTERVOL=0
		if FEATURE_DACFMVOLENV
			btst	#cfbRest,(a5)	; check if channel is resting
			bne.s	locret_MuteFM	; if is, do not update anything
		endif

		move.b	cVolume(a5),d5		; load FM channel volume to d3
		bra.s	dUpdateVolFM3		; do NOT add the master volume!
	endif

dUpdateVolFM:
	if FEATURE_DACFMVOLENV
		btst	#cfbRest,(a5)		; check if channel is resting
		bne.s	locret_MuteFM		; if is, do not update anything
	endif

		move.b	cVolume(a5),d5		; load FM channel volume to d3
		add.b	mMasterVolFM.w,d5	; add master FM volume to d3
		bpl.s	dUpdateVolFM3		; if volume did not overflow, skio
		moveq	#$7F,d5			; force FM volume to silence

dUpdateVolFM3:
	if FEATURE_DACFMVOLENV
		moveq	#0,d4
		move.b	cVolEnv(a5),d4		; load volume envelope ID to d4
		beq.s	.ckflag			; if 0, check if volume update was needed

		jsr	dVolEnvProg(pc)		; run the envelope program
		bne.s	dUpdateVolFM2		; if it was necessary to update volume, do so

.ckflag
		btst	#cfbVol,(a5)		; test volume update flag
		beq.s	locret_MuteFM		; branch if no volume update was requested
	endif

dUpdateVolFM2:
	if FEATURE_DACFMVOLENV
		bclr	#cfbVol,(a5)		; clear volume update flag
	endif
		btst	#cfbInt,(a5)		; is the channel interrupted by SFX?
		bne.s	locret_MuteFM		; if yes, do not update

		moveq	#0,d0
		move.b	cVoice(a5),d0		; load FM voice ID of the channel to d0
		move.l	a6,a1			; copy music voice table address to a1
	dCALC_VOICE				; get address of the specific voice to a1

	if FEATURE_UNDERWATER
		moveq	#0,d4			; clear d0 (so no underwater by default)

		btst	#mfbWater,mFlags.w	; check if underwater mode is enabled
		beq.s	.uwdone			; if not, skip
		move.b	(a1),d4			; load algorithm and feedback to d0
		and.w	#7,d4			; mask out everything but the algorithm

		lea	dUnderwaterTbl(pc),a2	; get underwater table to a2
		move.b	(a2,d4.w),d6		; get the value from table
		move.b	d6,d4			; copy to d0
		and.w	#7,d6			; mask out extra stuff

		add.b	d6,d5			; add algorithm to Total Level carrier offset
		bpl.s	.uwdone			; if volume did not overflow, skip
		moveq	#$7F,d5			; force FM volume to silence

.uwdone
	endif

		moveq	#4-1,d3			; prepare 4 operators to d3
		move.l	sp,a2			; copy stack pointer to a2
		subq.l	#4,sp			; reserve some space in the stack
		add.w	#VoiceTL,a1		; go to the Total Level offset of the voice

.tlloop
		move.b	(a1)+,d1		; get Total Level value from voice to d1
		bpl.s	.noslot			; if slot operator bit was not set, branch

		add.b	d5,d1			; add carrier offset to loaded value
		bmi.s	.slot			; if we did not overflow, branch
		moveq	#-1,d1			; cap to silent volume
	if FEATURE_UNDERWATER
		bra.s	.slot
	endif

.noslot
	if FEATURE_UNDERWATER
		add.b	d4,d1			; add modulator offset to loaded value
	endif

.slot
		move.b	d1,-(a2)		; write total level to stack
		dbf	d3,.tlloop		; repeat for each Total Level operator

	CheckCue				; check that YM cue is valid
	InitChYM				; prepare to write to channel
	stopZ80
	WriteChYM	#$4C, (a2)+		; Total Level: Load operator 4 from stack
	WriteChYM	#$44, (a2)+		; Total Level: Load operator 2 from stack
	WriteChYM	#$48, (a2)+		; Total Level: Load operator 3 from stack
	WriteChYM	#$40, (a2)+		; Total Level: Load operator 1 from stack
	;	st	(a0)			; write end marker
	startZ80
		move.l	a2,sp			; restore stack pointer

	if safe=1
		AMPS_Debug_UpdVolFM		; check if the voice was valid
	endif

locret_VolFM:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; values for underwater mode update
; ---------------------------------------------------------------------------

	if FEATURE_UNDERWATER
dUnderwaterTbl:	dc.b $08, $08, $08, $08, $0A, $0E, $0E, $0F
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; YM2612 register update list
; ---------------------------------------------------------------------------

dAMSEn_Ops:	dc.b $60, $68, $64, $6C		; Decay 1 Rate
dOpTLFM:	dc.b $40, $48, $44, $4C		; Total Level
; ===========================================================================
; ---------------------------------------------------------------------------
; Process SFX FM channels
; ---------------------------------------------------------------------------

dAMPSdoFMSFX:
		lea	VoiceBank(pc),a6	; load sound effects voice table into a6
		moveq	#SFX_FM-1,d7		; get total number of SFX FM channels to d7

dAMPSnextFMSFX:
		add.w	#cSizeSFX,a5		; go to the next channel
		tst.b	(a5)			; check if channel is running a tracker
		bpl.w	.next			; if not, branch
		subq.b	#1,cDuration(a5)	; decrease note duration
		beq.w	.update			; if timed out, update channel

	dCalcFreq				; calculate channel base frequency
	dModPorta dAMPSdoPSGSFX, dAMPSnextFMSFX, 1; run modulation + portamento code
		bsr.w	dUpdateFreqFM3		; send FM frequency to hardware

	if FEATURE_DACFMVOLENV=0
		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.next			; if not, skip
	endif
		jsr	dUpdateVolFM_SFX(pc)	; update FM volume

.next
		dbf	d7,dAMPSnextFMSFX	; make sure to run all the channels
		jmp	dAMPSdoPSGSFX(pc)	; after that, process SFX PSG channels

.update
		and.b	#$FF-(1<<cfbHold)-(1<<cfbRest),(a5); clear hold and rest flags
	dDoTracker				; process tracker
		jsr	dKeyOffFM2(pc)		; send key-off command to YM
		tst.b	d5			; check if note is being played
		bpl.s	.timer			; if not, it must be a timer. branch

		bsr.w	dGetFreqFM		; get frequency
		move.b	(a4)+,d5		; check next byte
		bpl.s	.timer			; if positive, process a tiemr too
		subq.w	#1,a4			; if not, then return back
		bra.s	.pcnote			; do some extra clearing

.timer
		jsr	dCalcDuration(pc)	; calculate duration
.pcnote
	dProcNote 1, 0				; reset necessary channel memory
		bsr.w	dUpdateFreqFM		; send FM frequency to hardware
	dKeyOnFM 1				; send key-on command to YM

	if FEATURE_DACFMVOLENV=0
		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.noupdate		; if not, branch
	endif
		jsr	dUpdateVolFM_SFX(pc)	; update FM volume

.noupdate
		dbf	d7,dAMPSnextFMSFX	; make sure to run all the channels
		jmp	dAMPSdoPSGSFX(pc)	; after that, process SFX PSG channels
; ===========================================================================
; ---------------------------------------------------------------------------
; Process music FM channels
; ---------------------------------------------------------------------------

dAMPSdoFM:
		move.l	mVctMus.w,a6		; load music voice table into a6
		moveq	#Mus_FM-1,d7		; get total number of music FM channels to d7

dAMPSnextFM:
		add.w	#cSize,a5		; go to the next channel
		tst.b	(a5)			; check if channel is running a tracker
		bpl.w	.next			; if not, branch
		subq.b	#1,cDuration(a5)	; decrease note duration
		beq.w	.update			; if timed out, update channel

	dNoteToutFM.w				; handle FM-specific note timeout behavior
	dCalcFreq				; calculate channel base frequency
	dModPorta dAMPSdoPSG, dAMPSnextFM, 0	; run modulation + portamento code
		bsr.w	dUpdateFreqFM2		; send FM frequency to hardware

	if FEATURE_DACFMVOLENV=0
		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.next			; if not, skip
	endif
		jsr	dUpdateVolFM(pc)	; update FM volume

.next
		dbf	d7,dAMPSnextFM		; make sure to run all the channels
		jmp	dAMPSdoPSG(pc)		; after that, process music PSG channels

.update
		and.b	#$FF-(1<<cfbHold)-(1<<cfbRest),(a5); clear hold and rest flags
	dDoTracker				; process tracker
		jsr	dKeyOffFM(pc)		; send key-off command to YM
		tst.b	d5			; check if note is being played
		bpl.s	.timer			; if not, it must be a timer. branch

		bsr.w	dGetFreqFM		; get frequency
		move.b	(a4)+,d5		; check next byte
		bpl.s	.timer			; if positive, process a tiemr too
		subq.w	#1,a4			; if not, then return back
		bra.s	.pcnote			; do some extra clearing

.timer
		jsr	dCalcDuration(pc)	; calculate duration

.pcnote
	dProcNote 0, 0				; reset necessary channel memory
		bsr.s	dUpdateFreqFM		; send FM frequency to hardware
	dKeyOnFM				; send key-on command to YM

	if FEATURE_DACFMVOLENV=0
		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.noupdate		; if not, branch
	endif
		jsr	dUpdateVolFM(pc)	; update FM volume

.noupdate
		dbf	d7,dAMPSnextFM		; make sure to run all the channels
		jmp	dAMPSdoPSG(pc)		; after that, process music PSG channels
; ===========================================================================
; ---------------------------------------------------------------------------
; Write FM frequency to Dual PCM YMCue
; ---------------------------------------------------------------------------

dUpdateFreqFM:
		move.w	cFreq(a5),d6		; load channel base frequency to d6
		bne.s	.norest			; if 0, this channel should be resting
		bset	#cfbRest,(a5)		; set channel resting flag
		rts

.norest
		move.b	cDetune(a5),d0		; load detune value to d0
		ext.w	d0			; extend to word
		add.w	d0,d6			; add to channel base frequency to d6

	if FEATURE_MODENV
		jsr	dModEnvProg(pc)		; process modulation envelope
	endif

	if FEATURE_PORTAMENTO
		add.w	cPortaFreq(a5),d6	; add portamento speed to frequency
	endif

	if FEATURE_MODULATION
		btst	#cfbMod,(a5)		; check if channel is modulating
		beq.s	dUpdateFreqFM2		; if not, branch
		add.w	cModFreq(a5),d6		; add channel modulation frequency offset to d6
	endif

dUpdateFreqFM2:
		btst	#cfbInt,(a5)		; is the channel interrupted by SFX?
		bne.s	locret_UpdFreqFM	; if is, do not update frequency anyway

dUpdateFreqFM3:
		btst	#cfbRest,(a5)		; is this channel resting
		bne.s	locret_UpdFreqFM	; if is, skip

		move.w	d6,d0			; copy frequency to d1
		lsr.w	#8,d0			; shift upper byte into lower byte
	CheckCue				; check that YM cue is valid
	InitChYM				; prepare to write to channel
	stopZ80
	WriteChYM	#$A4, d0		; Frequency MSB & Octave
	WriteChYM	#$A0, d6		; Frequency LSB
	;	st	(a0)			; write end marker
	startZ80

locret_UpdFreqFM:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Process a note in FM channel (enable resting or get frequency)
; ---------------------------------------------------------------------------

dGetFreqFM:
		subi.b	#$80,d5			; sub $80 from the note (notes start at $80)
		bne.s	.norest			; branch if note wasnt $80 (rest)
		bset	#cfbRest,(a5)		; set channel resting flag
		clr.w	cFreq(a5)		; set base frequency to 0
		rts

.norest
		add.b	cPitch(a5),d5		; add pitch offset to note
		andi.w	#$7F,d5			; keep within $80 notes
		add.w	d5,d5			; double offset (each entry is a word)

		lea	dFreqFM(pc),a1		; load FM frequency table to a1
		move.w	(a1,d5.w),cFreq(a5)	; load and save the requested frequency

	if safe=1
		AMPS_Debug_NoteFM		; check if the note was valid
	endif
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine for doing keying-off FM channel
; ---------------------------------------------------------------------------

dKeyOffFM:
		btst	#cfbInt,(a5)		; check if overridden by sfx
		bne.s	locret_UpdFreqFM	; if so, do not note off

dKeyOffFM2:
		btst	#cfbHold,(a5)		; check if note is held
		bne.s	locret_UpdFreqFM	; if so, do not note off

		move.b	cType(a5),d0		; load channel type value to d0
		moveq	#$28,d1			; load key on/off to d1
	stopZ80
	CheckCue				; check that cue is valid
	WriteYM1	d1, d0			; key on: turn all operators off for channel
	WriteYM1	d1, d0			; the reason we do this, is to work around some YM2612 bug or quirk
	WriteYM1	d1, d0			; if you key off and key on too quickly, the sound is somewhat wrong
	WriteYM1	d1, d0			; this was noticeable on few SFX, particularly the death sfx
	;	st	(a0)			; I am not sure why it works, but I am gonna be honest, I don't care enough to find out
	startZ80
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Note to FM frequency conversion table
; ---------------------------------------------------------------------------
;	dc.w   C     C#    D     Eb    E     F     F#    G     G#    A     Bb    B
dFreqFM:dc.w								       $025E; Octave-1 - (80)
	dc.w $0284,$02AB,$02D3,$02FE,$032D,$035C,$038F,$03C5,$03FF,$043C,$047C,$0A5E; Octave 0 - (81 - 8C)
	dc.w $0A84,$0AAB,$0AD3,$0AFE,$0B2D,$0B5C,$0B8F,$0BC5,$0BFF,$0C3C,$0C7C,$125E; Octave 1 - (8D - 98)
	dc.w $1284,$12AB,$12D3,$12FE,$132D,$135C,$138F,$13C5,$13FF,$143C,$147C,$1A5E; Octave 2 - (99 - A4)
	dc.w $1A84,$1AAB,$1AD3,$1AFE,$1B2D,$1B5C,$1B8F,$1BC5,$1BFF,$1C3C,$1C7C,$225E; Octave 3 - (A5 - B0)
	dc.w $2284,$22AB,$22D3,$22FE,$232D,$235C,$238F,$23C5,$23FF,$243C,$247C,$2A5E; Octave 4 - (B1 - BC)
	dc.w $2A84,$2AAB,$2AD3,$2AFE,$2B2D,$2B5C,$2B8F,$2BC5,$2BFF,$2C3C,$2C7C,$325E; Octave 5 - (BD - C8)
	dc.w $3284,$32AB,$32D3,$32FE,$332D,$335C,$338F,$33C5,$33FF,$343C,$347C,$3A5E; Octave 6 - (C9 - D4)
	dc.w $3A84,$3AAB,$3AD3,$3AFE,$3B2D,$3B5C,$3B8F,$3BC5,$3BFF,$3C3C,$3C7C	    ; Octave 7 - (D5 - DF)
dFreqFM_:
	if safe=1				; in safe mode, we have extra debug data
.x = $100|((dFreqFM_-dFreqFM)/2)		; to check if we played an invalid note
		rept $80-((dFreqFM_-dFreqFM)/2)	; and if so, tell us which note it was
			dc.w .x
.x =			.x+$101
		endr
	endif
