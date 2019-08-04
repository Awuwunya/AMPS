; ===========================================================================
; ---------------------------------------------------------------------------
; Note timout handler macro
; ---------------------------------------------------------------------------

dNoteToutHandler	macro
		tst.b	cNoteTimeCur(a5)	; check if timer is 0
		beq.s	.endt			; if is, do not timeout
		subq.b	#1,cNoteTimeCur(a5)	; decrease delay by 1
		bne.s	.endt			; if still not 0, branch
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Note timout handler macro for DAC
; ---------------------------------------------------------------------------

dNoteToutDAC	macro
	dNoteToutHandler			; include timeout handler
		moveq	#0,d0			; play stop sample
		bra.w	dNoteOnDAC2		; ''
.endt
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Note timout handler macro for FM
; ---------------------------------------------------------------------------

dNoteToutFM	macro
	dNoteToutHandler			; include timeout handler
		bset	#cfbRest,(a5)		; set track to resting
		bsr.w	dKeyOffFM		; key off FM
		bra.\0	.next			; jump to next track
.endt
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Note timout handler macro for PSG
; ---------------------------------------------------------------------------

dNoteToutPSG	macro
	dNoteToutHandler			; include timeout handler
		bset	#cfbRest,(a5)		; set track to resting
		bsr.w	dMutePSGmus		; mute PSG channel
		bra.s	.next			; jump to next track
.endt
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for calculating the current frequency (without modulation) into d6.
; Used if user wants to add extra pitch effects such as pitch slides.
; ---------------------------------------------------------------------------

dCalcFreq	macro
		move.b	cDetune(a5),d6		; get detune value to d6
		ext.w	d6			; extend to word
		add.w	cFreq(a5),d6		; add channel base frequency to it
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for generating frequency modulation code
; ---------------------------------------------------------------------------

dModulate	macro jump,loop,type
		btst	#cfbMod,(a5)		; check if modulation is active
		beq.s	.noret			; if not, update volume and return
		tst.b	cModDelay(a5)		; check if there is delay left
		beq.s	.started		; if not, modulate!
		subq.b	#1,cModDelay(a5)	; decrease delay

.noret
	if narg>0
		if narg=3
			if type<2
				bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
				beq.s	.noupdatevol		; if not, skip
				jsr	dUpdateVolFM(pc)	; update FM volume
			.noupdatevol:
			endif
			if type>=4
				bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
				beq.s	.noupdatevol		; if not, skip
				jsr	dUpdateVolDAC(pc)	; update DAC volume
			.noupdatevol:
			endif
			if \type<>5
				dbf	d7,\loop		; loop for all channels
			endif
		endif
		bra.w	\jump			; jump to next routine
	else
		bra.s	.endm			; jump to the next .endm routine
	endif

.started
		subq.b	#1,cModSpeed(a5)	; decrease modulation speed counter
		bne.s	.noret			; if there's still delay left, update vol and return
		movea.l	cMod(a5),a1		; get modulation data offset to a1
		move.b	1(a1),cModSpeed(a5)	; reset modulation speed counter

		tst.b	cModCount(a5)		; check if this was the last step
		bne.s	.norev			; if was not, do not reverse
		move.b	3(a1),cModCount(a5)	; reset steps counter
		neg.b	cModStep(a5)		; negate step amount

.norev
		subq.b	#1,cModCount(a5)	; decrease step counter
		move.b	cModStep(a5),d5		; get step offset into d5
		ext.w	d5			; extend to word

		add.w	cModFreq(a5),d5		; add modulation frequency to it
		move.w	d5,cModFreq(a5)		; save as the modulation frequency
		add.w	d5,d6			; add to channel base frequency
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for processing the tracker
; ---------------------------------------------------------------------------

dDoTracker	macro
		movea.l	cData(a5),a4		; grab tracker address
	if safe=1
		AMPS_Debug_TrackUpd		; check if this address is valid
	endif

.data
		moveq	#0,d5
		move.b	(a4)+,d5		; get a byte from tracker
		cmpi.b	#$E0,d5			; is this a command?
		blo.s	.notcomm		; if not, continue
		jsr	dCommands(pc)		; run the condition flag
		bra.s	.data			; for most commands, use this branch to loop
		bra.s	.next			; however, for example sStop will make us return here.
.notcomm
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for playing a note, and setting up for it (software updates only)
; ---------------------------------------------------------------------------

dProcNote	macro sfx, psg
		move.l	a4,cData(a5)		; save tracker address
		move.b	cLastDur(a5),cDuration(a5); copy stored duration
		btst	#cfbHold,(a5)		; check if we are holding
		bne.s	.endpn			; if we are, branch

	if sfx=0
		move.b	cNoteTimeMain(a5),cNoteTimeCur(a5); copy note timeout value
	endif

	if psg<>0
		clr.b	cEnvPos(a5)		; clear envelope position if PSG channel
	endif

		btst	#cfbMod,(a5)		; check if modulation is enabled
		beq.s	.endpn			; if not, branch

		movea.l	cMod(a5),a1		; get modulation data address
		move.b	(a1)+,cModDelay(a5)	; copy delay
		move.b	(a1)+,cModSpeed(a5)	; copy speed
		move.b	(a1)+,cModStep(a5)	; copy step offset

		move.b	(a1),d0			; get number of steps
		lsr.b	#1,d0			; halve it
		move.b	d0,cModCount(a5)	; save as the current number of steps
		clr.w	cModFreq(a5)		; clear frequency offset
.endpn
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for processing a note in DAC channel
; ---------------------------------------------------------------------------

dTrackNoteDAC	macro
		btst	#cfbMode,(a5)		; check if we are on pitch mode
		bne.s	.pitch			; if so, load pitch
		move.b	d5,cSample(a5)		; else, save as a sample
		bra.s	.cont

.pitch
		subi.b	#$80,d5			; sub $80 from the note (notes start at $80)
		bne.s	.noprest		; branch if note wasnt $80 (rest)
		moveq	#0,d0			; play stop sample
		bsr.w	dNoteOnDAC2		; ''
		moveq	#-$80,d6		; tell the code we are resting
		bra.s	.cont

.noprest
		add.b	cPitch(a5),d5		; add pitch offset to note
		add.w	d5,d5			; double offset (each entry is a word)
		lea	dFreqDAC(pc),a1		; load DAC frequency table to a1
		move.w	(a1,d5.w),cFreq(a5)	; load and save the requested frequency

.cont
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for doing keying-on FM channel
; ---------------------------------------------------------------------------

dKeyOnFM	macro
		btst	#cfbHold,(a5)		; check if note is held
		bne.s	.k			; if so, do not note on
		btst	#cfbRest,(a5)		; check if channel is resting
		bne.s	.k			; if so, do not note on
	if narg=0
		btst	#cfbInt,(a5)		; check if overridden by sfx
		bne.s	.k			; if so, do not note on
	endif

		moveq	#$28,d0			; YM command: Key on
		move.b	cType(a5),d1		; get channel type bits
		ori.b	#$F0,d1			; turn all FM operators on
		bsr.w	WriteYM_Pt1		; send note-on event
.k
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for processing a note in PSG channel
; ---------------------------------------------------------------------------

dGetFreqPSG	macro
		subi.b	#$81,d5			; sub $81 from the note (notes start at $80)
		bhs.s	.norest			; branch if note wasnt $80 (rest)
		bset	#cfbRest,(a5)		; set channel to resting
		move.w	#-1,cFreq(a5)		; set invalid PSG frequency
		jsr	dMutePSGmus(pc)		; mute this PSG channel
		bra.s	.freqgot

.norest
		add.b	cPitch(a5),d5		; add pitch offset to note
		andi.w	#$7F,d5			; keep within $80 notes
		add.w	d5,d5			; double offset (each entry is a word)
		move.w	(a6,d5.w),cFreq(a5)	; load and save the requested frequency

	if safe=1
		AMPS_Debug_NotePSG		; check if the note was valid
	endif
.freqgot
    endm
; ===========================================================================
