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
		or.b	#(1<<cfbRest)|(1<<cfbVol),(a5); set channel to resting and request a volume update (update on next note-on)
		bsr.w	dMutePSGmus		; mute PSG channel
		bra.w	.next			; jump to next track
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
; Macro for generating portamento + modulation code
; ---------------------------------------------------------------------------

dModPorta	macro jump,loop,type
	if FEATURE_MODENV
		jsr	dModEnvProg(pc)
	endif

	dPortamento	\jump,\loop,\type
	dModulate	\jump,\loop,\type
    endm

; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for generating portamento code
; ---------------------------------------------------------------------------

dPortamento	macro jump,loop,type
	if FEATURE_PORTAMENTO
		if FEATURE_MODULATION=0
			tst.b	cPortaSpeed(a5)		; check if portamento is active
			bne.s	.doporta		; if not, branch

			if FEATURE_MODENV
				tst.b	cModEnv(a5)	; check if modulation envelope ID is not 0
				bne.s	.nowrap		; if so, update frequency nonetheless
			endif

			dGenLoops 1, \jump,\loop,\type
		endif

.doporta
		move.w	cPortaFreq(a5),d5	; load portamento frequency to d5
		beq.s	.nochk			; branch if 0 already
		bmi.s	.ppos			; branch if negative

		add.w	cPortaDisp(a5),d5	; add displacement to d5
		bpl.s	.noover			; branch if overflow did not occur
		bra.s	.pclr

.ppos
		add.w	cPortaDisp(a5),d5	; add displacement to d5
		bmi.s	.noover			; branch if overflow did not occur
.pclr		moveq	#0,d5			; if it did, clear displacement

.noover		move.w	d5,cPortaFreq(a5)	; save portamento frequency back
.nochk		add.w	d5,d6			; add it to the current pitch

		if (type=0)|(type=1)
			move.w	d6,d5		; special FM code to skip over some frequencies, because it sounds bad
			move.w	#$800+$25D-$4C0,d4; prepare value into d4

			and.w	#$7FF,d5	; get only the frequency offset
			sub.w	#$25D,d5	; sub the lower bound
			cmp.w	#$4C0-$25D,d5	; check if out of range of safe frequencies
			bls.s	.nowrap		; branch if not

			bpl.s	.pos		; branch if negative
			sub.w	d4,d6		; add frequency offset to d4
			sub.w	d4,cPortaFreq(a5); fix portamento frequency also
			bpl.s	.nowrap		; branch if overflow did not occur
			bra.s	.wrap2

		.pos:
			add.w	d4,d6		; add frequency offset to d4
			add.w	d4,cPortaFreq(a5); fix portamento frequency also
			bmi.s	.nowrap		; branch if overflow did not occur

		.wrap2:
			move.w	cPortaFreq(a5),d4; get portamento to d4 again
			sub.w	d4,d6		; fix frequency, again
			clr.w	cPortaFreq(a5)	; reset portamento frequency
		endif

	.nowrap:
	endif
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for generating frequency modulation code
; ---------------------------------------------------------------------------

dModulate	macro jump,loop,type
	if FEATURE_MODULATION
		btst	#cfbMod,(a5)		; check if modulation is active
		beq.s	.noret			; if not, update volume and return
		tst.b	cModDelay(a5)		; check if there is delay left
		beq.s	.started		; if not, modulate!
		subq.b	#1,cModDelay(a5)	; decrease delay

.noret
		if FEATURE_PORTAMENTO
			tst.b	cPortaSpeed(a5)	; check if portamento is active
			bne.s	.porta		; if is, branch
		endif

		if FEATURE_MODENV
			tst.b	cModEnv(a5)	; check if modulation envelope ID is not 0
			bne.s	.porta		; if so, update frequency nonetheless
		endif
	dGenLoops 0, \jump,\loop,\type

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

.porta
	endif
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for generating fast looping code for modulation and portamento
; ---------------------------------------------------------------------------

dGenLoops macro	mode,jump,loop,type
	if \type>=0
		if FEATURE_DACFMVOLENV=0
			bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
			beq.s	.noupdatevol		; if not, skip
		endif

		if \type<2
			jsr	dUpdateVolFM(pc)	; update FM volume
		endif

		if \type>=4
			jsr	dUpdateVolDAC(pc)	; update DAC volume
		endif

		.noupdatevol:
		if \type<>5
			dbf	d7,\loop		; loop for all channels
		endif
	endif
	bra.w	\jump			; jump to next routine
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for processing the tracker
; ---------------------------------------------------------------------------

dDoTracker	macro
		move.l	cData(a5),a4		; grab tracker address
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
	if FEATURE_PORTAMENTO
		move.w	cFreq(a5),-(sp)		; we need to know the last frequency in portamento mode, so store it in stack
	endif
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for playing a note, and setting up for it (software updates only)
; ---------------------------------------------------------------------------

dProcNote	macro sfx, chan
		move.l	a4,cData(a5)		; save tracker address
		move.b	cLastDur(a5),cDuration(a5); copy stored duration

	if FEATURE_PORTAMENTO
		move.w	(sp)+,d1		; load the last frequency to d1
		if \chan<=0
			beq.s	.noporta	; if it was not 0, branch
		else
			bmi.s	.noporta	; if it was not negative, branch
		endif

		tst.b	cPortaSpeed(a5)		; check if portamento is enabled
		beq.s	.noporta		; branch if not

	; check if portamento needs to be reset
		move.w	cFreq(a5),d0		; load current frequency to d0
		if \chan<=0
			bne.s	.pno0		; if it was not 0, branch
		else
			bpl.s	.pno0		; if it was not negative, branch
		endif

		clr.w	cPortaFreq(a5)		; clear portamento frequency
		clr.w	cPortaDisp(a5)		; clear portamento displacement
		bra.s	.noporta

.pno0	; process the portamento itself
		add.w	cPortaFreq(a5),d1	; make sure pitch makes no jumps
		sub.w	d1,d0			; get the frequency difference to d0

		neg.w	d0			; store displacement as a negative value
		move.w	d0,cPortaFreq(a5)	; save as new frequency displacement
		neg.w	d0			; turn positive again for calculations

		if \chan=0
		; for FM, process frequency difference differently
			move.w	#$800+$25D-$4C0,d2; get frequency addition to d2
			move.w	d0,d1		; copy the difference to d0
			bpl.s	.pposf		; branch if positive
			neg.w	d1		; else, negate it
			neg.w	d2		; also negate addition to become substraction

.pposf
			and.w	#$F800,d1	; get only the octave difference
			beq.s	.skipfd		; if 0, branch

.pgetf
			sub.w	d2,d0		; account for skipping part of the frequency stuff
			sub.w	#$800,d1	; check if octave difference is 0 now
			bne.s	.pgetf		; if not, loop

.skipfd
		endif

		ext.l	d0			; extend to long word (for divs)
		moveq	#0,d1
		move.b	cPortaSpeed(a5),d1	; load portamento speed to d1
		divs	d1,d0			; divide offset by speed count

	; make sure that the frequency displacement is never 0
		tst.w	d0			; check if resulting displacement is 0
		bne.s	.portanz		; branch if not
		moveq	#1,d0			; prepare 1; forwards portamento

		tst.w	cPortaFreq(a5)		; check if we need to go forwards
		bpl.s	.portanz		; if so, branch
		moveq	#-1,d0			; portamento backwards

.portanz
		move.w	d0,cPortaDisp(a5)	; save portamento displacement value

.noporta
	endif

	if FEATURE_MODULATION|(\sfx=0)|(\chan=1)
		btst	#cfbHold,(a5)		; check if we are holding
		bne.s	.endpn			; if we are, branch
	endif

	if \sfx=0
		move.b	cNoteTimeMain(a5),cNoteTimeCur(a5); copy note timeout value
	endif

	if FEATURE_DACFMVOLENV|(\chan=1)
		clr.b	cEnvPos(a5)		; clear envelope position if PSG channel
	endif

	if FEATURE_MODENV
		clr.b	cModEnvPos(a5)		; clear modulation envelope position
		clr.b	cModEnvSens(a5)		; clear modulation envelope sensitivity (set to 1x)
	endif

	if FEATURE_MODULATION
		btst	#cfbMod,(a5)		; check if modulation is enabled
		beq.s	.endpn			; if not, branch

		move.l	cMod(a5),a1		; get modulation data address
		move.b	(a1)+,cModDelay(a5)	; copy delay
		move.b	(a1)+,cModSpeed(a5)	; copy speed
		move.b	(a1)+,cModStep(a5)	; copy step offset

		move.b	(a1),d0			; get number of steps
		lsr.b	#1,d0			; halve it
		move.b	d0,cModCount(a5)	; save as the current number of steps
		clr.w	cModFreq(a5)		; clear frequency offset
	endif
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
		or.b	#(1<<cfbRest)|(1<<cfbVol),(a5); set channel to resting and request a volume update (update on next note-on)
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
; ---------------------------------------------------------------------------
; Macro for stopping channel based on its type
; ---------------------------------------------------------------------------

dStopChannel	macro	stop
		tst.b	cType(a5)		; check if this was a PSG channel
		bmi.s	.mutePSG		; if yes, mute it

		btst	#ctbDAC,cType(a5)	; check if this was a DAC channel
		bne.s	.cont			; if we are, skip

	if stop=0
		jsr	dKeyOffFM(pc)		; send key-off command to YM
		bra.s	.cont
	else
		jmp	dKeyOffFM(pc)		; send key-off command to YM
	endif
; ---------------------------------------------------------------------------

.mutePSG
	if stop=0
		jsr	dMutePSGmus(pc)		; mute PSG channel
	else
		jmp	dMutePSGmus(pc)		; mute PSG channel
	endif

.cont
	if stop<>0
		rts
	endif
    endm
; ===========================================================================
