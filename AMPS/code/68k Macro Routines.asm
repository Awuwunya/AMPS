; ===========================================================================
; ---------------------------------------------------------------------------
; Note timout handler macro
; ---------------------------------------------------------------------------

dNoteToutHandler	macro
		tst.b	cGateCur(a1)		; check if timer is 0
		beq.s	.endt			; if is, do not timeout
		subq.b	#1,cGateCur(a1)		; decrease delay by 1
		bne.s	.endt			; if still not 0, branch
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Note timout handler macro for DAC
; ---------------------------------------------------------------------------

dNoteToutDAC	macro
	dNoteToutHandler			; include timeout handler
		moveq	#0,d3			; play stop sample
		bra.w	dNoteOnDAC2		; ''
.endt
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Note timout handler macro for FM
; ---------------------------------------------------------------------------

dNoteToutFM	macro
	dNoteToutHandler			; include timeout handler
		bset	#cfbRest,(a1)		; set track to resting
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
		or.b	#(1<<cfbRest)|(1<<cfbVol),(a1); set channel to resting and request a volume update (update on next note-on)
		bsr.w	dMutePSGmus		; mute PSG channel
		bra.w	.next			; jump to next track
.endt
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for calculating the current frequency (without modulation) into d2.
; Used if user wants to add extra pitch effects such as pitch slides.
; ---------------------------------------------------------------------------

dCalcFreq	macro
		move.b	cDetune(a1),d2		; get detune value to d2
		ext.w	d2			; extend to word
		add.w	cFreq(a1),d2		; add channel base frequency to it
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
			tst.b	cPortaSpeed(a1)	; check if portamento is active
			bne.s	.doporta	; if not, branch

			if FEATURE_MODENV
				tst.b	cModEnv(a1); check if modulation envelope ID is not 0
				bne.s	.nowrap	; if so, update frequency nonetheless
			endif

			dGenLoops 1, \jump,\loop,\type
		endif

.doporta
		move.w	cPortaFreq(a1),d5	; load portamento frequency to d5
		beq.s	.nochk			; branch if 0 already
		bmi.s	.ppos			; branch if negative

		add.w	cPortaDisp(a1),d5	; add displacement to d5
		bpl.s	.noover			; branch if overflow did not occur
		bra.s	.pclr

.ppos
		add.w	cPortaDisp(a1),d5	; add displacement to d5
		bmi.s	.noover			; branch if overflow did not occur

.pclr
		moveq	#0,d5			; if it did, clear displacement

.noover
		move.w	d5,cPortaFreq(a1)	; save portamento frequency back

.nochk
		add.w	d5,d2			; add it to the current pitch

		if (type=0)|(type=1)
			move.w	d2,d5		; special FM code to skip over some frequencies, because it sounds bad
			move.w	#$800+$25D-$4C0,d4; prepare value into d4

			and.w	#$7FF,d5	; get only the frequency offset
			sub.w	#$25D,d5	; sub the lower bound
			cmp.w	#$4C0-$25D,d5	; check if out of range of safe frequencies
			bls.s	.nowrap		; branch if not
			bpl.s	.pos		; branch if negative

			sub.w	d4,d2		; add frequency offset to d4
			sub.w	d4,cPortaFreq(a1); fix portamento frequency also
			bpl.s	.nowrap		; branch if overflow did not occur
			bra.s	.wrap2

		.pos:
			add.w	d4,d2		; add frequency offset to d4
			add.w	d4,cPortaFreq(a1); fix portamento frequency also
			bmi.s	.nowrap		; branch if overflow did not occur

		.wrap2:
			move.w	cPortaFreq(a1),d4; get portamento to d4 again
			sub.w	d4,d2		; fix frequency, again
			clr.w	cPortaFreq(a1)	; reset portamento frequency
		endif

.nowrap
	endif
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for generating frequency modulation code
; ---------------------------------------------------------------------------

dModulate	macro jump,loop,type
	if FEATURE_MODULATION
		btst	#cfbMod,(a1)		; check if modulation is active
		beq.s	.noret			; if not, update volume and return
		tst.b	cModDelay(a1)		; check if there is delay left
		beq.s	.started		; if not, modulate!
		subq.b	#1,cModDelay(a1)	; decrease delay

.noret
		if FEATURE_PORTAMENTO
			tst.b	cPortaSpeed(a1)	; check if portamento is active
			bne.s	.porta		; if is, branch
		endif

		if FEATURE_MODENV
			tst.b	cModEnv(a1)	; check if modulation envelope ID is not 0
			bne.s	.porta		; if so, update frequency nonetheless
		endif
	dGenLoops 0, \jump,\loop,\type

.started
		subq.b	#1,cModSpeed(a1)	; decrease modulation speed counter
		bne.s	.noret			; if there's still delay left, update vol and return
		movea.l	cMod(a1),a4		; get modulation data offset to a1
		move.b	(a4)+,cModSpeed(a1)	; reset modulation speed counter

		tst.b	cModCount(a1)		; check if this was the last step
		bne.s	.norev			; if was not, do not reverse
		move.b	(a4)+,cModCount(a1)	; reset steps counter
		neg.b	cModStep(a1)		; negate step amount

.norev
		subq.b	#1,cModCount(a1)	; decrease step counter
		move.b	cModStep(a1),d5		; get step offset into d5
		ext.w	d5			; extend to word

		add.w	cModFreq(a1),d5		; add modulation frequency to it
		move.w	d5,cModFreq(a1)		; save as the modulation frequency
		add.w	d5,d2			; add to channel base frequency

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
			bclr	#cfbVol,(a1)	; check if volume update is needed and clear bit
			beq.s	.noupdatevol	; if not, skip
		endif

		if \type<2
			jsr	dUpdateVolFM(pc); update FM volume
		endif

		if \type>=4
			jsr	dUpdateVolDAC(pc); update DAC volume
		endif

		.noupdatevol:
		if \type<>5
			dbf	d0,\loop	; loop for all channels
		endif
	endif
	bra.w	\jump				; jump to next routine
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for processing the tracker
; ---------------------------------------------------------------------------

dDoTracker	macro
		move.l	cData(a1),a2		; grab tracker address
	if safe=1
		AMPS_Debug_TrackUpd		; check if this address is valid
	endif

.data
		moveq	#0,d1
		move.b	(a2)+,d1		; get a byte from tracker
		cmpi.b	#$E0,d1			; is this a command?
		blo.s	.notcomm		; if not, continue
		jsr	dCommands(pc)		; run the condition flag
		bra.s	.data			; for most commands, use this branch to loop
		bra.s	.next			; however, for example sStop will make us return here.

.notcomm
	if FEATURE_PORTAMENTO
		move.w	cFreq(a1),-(sp)		; we need to know the last frequency in portamento mode, so store it in stack
	endif
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for playing a note, and setting up for it (software updates only)
; ---------------------------------------------------------------------------

dProcNote	macro sfx, chan
		move.l	a2,cData(a1)		; save tracker address
		move.b	cLastDur(a1),cDuration(a1); copy stored duration

	if FEATURE_PORTAMENTO
		move.w	(sp)+,d1		; load the last frequency to d2
		if \chan<=0
			beq.s	.noporta	; if it was not 0, branch
		else
			bmi.s	.noporta	; if it was not negative, branch
		endif

		tst.b	cPortaSpeed(a1)		; check if portamento is enabled
		beq.s	.noporta		; branch if not

	; check if portamento needs to be reset
		move.w	cFreq(a1),d2		; load current frequency to d2
		if \chan<=0
			bne.s	.pno0		; if it was not 0, branch
		else
			bpl.s	.pno0		; if it was not negative, branch
		endif

		clr.w	cPortaFreq(a1)		; clear portamento frequency
		clr.w	cPortaDisp(a1)		; clear portamento displacement
		bra.s	.noporta

.pno0	; process the portamento itself
		add.w	cPortaFreq(a1),d1	; make sure pitch makes no jumps
		sub.w	d1,d2			; get the frequency difference to d2

		neg.w	d2			; store displacement as a negative value
		move.w	d2,cPortaFreq(a1)	; save as new frequency displacement
		neg.w	d2			; turn positive again for calculations

		if \chan=0
		; for FM, process frequency difference differently
			move.w	#$800+$25D-$4C0,d3; get frequency addition to d3
			move.w	d2,d1		; copy the difference to d2
			bpl.s	.pposf		; branch if positive
			neg.w	d1		; else, negate it
			neg.w	d3		; also negate addition to become substraction

.pposf
			and.w	#$F800,d1	; get only the octave difference
			beq.s	.skipfd		; if 0, branch

.pgetf
			sub.w	d3,d2		; account for skipping part of the frequency stuff
			sub.w	#$800,d1	; check if octave difference is 0 now
			bne.s	.pgetf		; if not, loop

.skipfd
		endif

		ext.l	d2			; extend to long word (for divs)
		moveq	#0,d1
		move.b	cPortaSpeed(a1),d1	; load portamento speed to d1
		divs	d1,d2			; divide offset by speed count

	; make sure that the frequency displacement is never 0
		tst.w	d2			; check if resulting displacement is 0
		bne.s	.portanz		; branch if not
		moveq	#1,d2			; prepare 1; forwards portamento

		tst.w	cPortaFreq(a1)		; check if we need to go forwards
		bpl.s	.portanz		; if so, branch
		moveq	#-1,d2			; portamento backwards

.portanz
		move.w	d2,cPortaDisp(a1)	; save portamento displacement value

.noporta
	endif

	if FEATURE_MODULATION|(\sfx=0)|(\chan=1)
		btst	#cfbHold,(a1)		; check if we are holding
		bne.s	.endpn			; if we are, branch
	endif

	if \sfx=0
		move.b	cGateMain(a1),cGateCur(a1); copy note timeout value
	endif

	if FEATURE_DACFMVOLENV|(\chan=1)
		clr.b	cEnvPos(a1)		; clear envelope position if PSG channel
	endif

	if FEATURE_MODENV
		clr.b	cModEnvPos(a1)		; clear modulation envelope position
		clr.b	cModEnvSens(a1)		; clear modulation envelope sensitivity (set to 1x)
	endif

	if FEATURE_MODULATION
		btst	#cfbMod,(a1)		; check if modulation is enabled
		beq.s	.endpn			; if not, branch

		move.l	cMod(a1),a4		; get modulation data address
		clr.w	cModFreq(a1)		; clear frequency offset
		move.b	(a4)+,cModSpeed(a1)	; copy speed

		move.b	(a4)+,d1		; get number of steps
		lsr.b	#1,d1			; halve it
		move.b	d1,cModCount(a1)	; save as the current number of steps

		move.b	(a4)+,cModDelay(a1)	; copy delay
		move.b	(a4)+,cModStep(a1)	; copy step offset
	endif
.endpn
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for processing a note in DAC channel
; ---------------------------------------------------------------------------

dTrackNoteDAC   macro
        	btst     #cfbMode,(a1)        	; check if we are on pitch mode
        	bne.s    .pitch            	; if so, load pitch
        	move.b   d1,cSample(a1)        	; else, save as a sample
        	bra.s    .cont

.pitch
        	subi.b   #$80,d1            	; sub $80 from the note (notes start at $80)
        	bne.s    .noprest        	; branch if note wasnt $80 (rest)
        	moveq    #-$80,d4        	; tell the code we are resting
        	bra.s    .cont

.noprest
        	add.b   cPitch(a1),d1        	; add pitch offset to note
        	add.w   d1,d1             	; double offset (each entry is a word)
        	lea     dFreqDAC(pc),a4        	; load DAC frequency table to a1
        	move.w  (a4,d1.w),cFreq(a1)    	; load and save the requested frequency

.cont
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for doing keying-on FM channel
; ---------------------------------------------------------------------------

dKeyOnFM	macro
	if narg=0
		btst	#cfbInt,(a1)		; check if overridden by sfx
		bne.s	.k			; if so, do not note on
	endif
		btst	#cfbHold,(a1)		; check if note is held
		bne.s	.k			; if so, do not note on
		btst	#cfbRest,(a1)		; check if channel is resting
		bne.s	.k			; if so, do not note on

		move.b	cType(a1),d3		; get channel type bits
		ori.b	#$F0,d3			; turn all FM operators on
	CheckCue				; check that cue is valid
	stopZ80
	WriteYM1	#$28, d3		; Key on: turn all FM operators on
	;	st	(a0)			; write end marker
	startZ80

.k
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for processing a note in PSG channel
; ---------------------------------------------------------------------------

dGetFreqPSG	macro
		subi.b	#$81,d1			; sub $81 from the note (notes start at $80)
		bhs.s	.norest			; branch if note wasnt $80 (rest)
		or.b	#(1<<cfbRest)|(1<<cfbVol),(a1); set channel to resting and request a volume update (update on next note-on)
		move.w	#-1,cFreq(a1)		; set invalid PSG frequency
		jsr	dMutePSGmus(pc)		; mute this PSG channel
		bra.s	.freqgot

.norest
		add.b	cPitch(a1),d1		; add pitch offset to note
		andi.w	#$7F,d1			; keep within $80 notes
		add.w	d1,d1			; double offset (each entry is a word)
		move.w	(a3,d1.w),cFreq(a1)	; load and save the requested frequency

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
		tst.b	cType(a1)		; check if this was a PSG channel
		bmi.s	.mutePSG		; if yes, mute it

		btst	#ctbDAC,cType(a1)	; check if this was a DAC channel
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
