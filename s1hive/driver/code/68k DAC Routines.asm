; ===========================================================================
; ---------------------------------------------------------------------------
; Process music DAC channels
; ---------------------------------------------------------------------------

dAMPSdoDAC:
		lea	SampleList(pc),a6	; get SampleList to a6 for quick access
		lea	mDAC1-cSize.w,a5	; get DAC1 channel RAM address into a5
		moveq	#Mus_DAC-1,d7		; get total number of DAC channels to d7

dAMPSnextDAC:
		add.w	#cSize,a5		; go to the next channel (first time its mDAC1!)
		tst.b	(a5)			; check if channel is running a tracker
		bpl.w	.next			; if not, branch
		subq.b	#1,cDuration(a5)	; decrease note duration
		beq.w	.update			; if timed out, update channel
	dNoteToutDAC	 			; handle DAC-specific note timeout behavior

	dCalcFreq				; calculate channel base frequency
	dModPorta dAMPSdoFM, dAMPSnextDAC, 4	; run modulation + portamento code
		bsr.w	dUpdateFreqDAC		; if frequency needs changing, do it

	if FEATURE_DACFMVOLENV=0
		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.next			; if not, skip
	endif
		bsr.w	dUpdateVolDAC		; update DAC volume

.next
		dbf	d7,dAMPSnextDAC		; make sure to run all the channels
		jmp	dAMPSdoFM(pc)		; after that, process music FM channels

.update
		and.b	#$FF-(1<<cfbHold),(a5)	; clear hold flag
	dDoTracker				; process tracker
		moveq	#0,d6			; clear rest flag
		tst.b	d5			; check if note is being played
		bpl.s	.timer			; if not, it must be a timer. Branch

	dTrackNoteDAC				; calculate frequency or update sample
		move.b	(a4)+,d5		; check if next note is a timer
		bpl.s	.timer			; if yes, handle timer
		subq.w	#1,a4			; else, undo the increment
		bra.s	.pcnote			; do not calculate duration

.timer
		jsr	dCalcDuration(pc)	; calculate duration
.pcnote
	dProcNote 0, -1				; reset necessary channel memory
		tst.b	d6			; check if channel was resting
		bmi.s	.noplay			; if yes, we do not want to note on anymore
		bsr.s	dNoteOnDAC		; do hardware note-on behavior

.noplay
	if FEATURE_DACFMVOLENV=0
		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.next2			; if not, skip
	endif
		bsr.w	dUpdateVolDAC		; update DAC volume

.next2
		dbf	d7,dAMPSnextDAC		; make sure to run all the channels
		jmp	dAMPSdoFM(pc)		; after that, process FM channels
; ===========================================================================
; ---------------------------------------------------------------------------
; Write DAC sample information to Dual PCM
; ---------------------------------------------------------------------------

dNoteOnDAC2:
		btst	#cfbInt,(a5)		; is the channel interrupted by SFX?
		beq.s	dNoteOnDAC3		; if not, process note
		rts

dNoteOnDAC:
		btst	#cfbInt,(a5)		; is the channel interrupted by SFX?
		bne.s	locret_dNoteOnDAC4	; if so, do not note on or update frequency

		moveq	#0,d0			; make sure the upper byte is clear
		move.b	cSample(a5),d0		; get sample ID to d0
		eor.b	#$80,d0			; this allows us to have the full $100 range safely
		btst	#cfbHold,(a5)		; check if note is held
		bne.w	dUpdateFreqOffDAC2	; if so, only update frequency

dNoteOnDAC3:
		lsl.w	#4,d0			; multiply sample ID by $10 (size of each entry)
		lea	(a6,d0.w),a3		; get sample data to a3

		pea	dUpdateFreqOffDAC(pc)	; update frequency after loading sample
		btst	#ctbPt2,cType(a5)	; check if this channel is DAC1
		beq.s	dNoteWriteDAC1		; if is, branch
; ---------------------------------------------------------------------------
; This code is for updating the note to Dual PCM. We have tracker commands
; for also playing notes on DAC channels, which is why the code seems a
; little weird.
; ---------------------------------------------------------------------------

dNoteWriteDAC2:
		lea	dZ80+PCM2_Sample,a1	; load addresses for PCM 1
		lea	dZ80+PCM2_NewRET,a2	; ''
		bra.s	dNoteOnDAC4

dNoteWriteDAC1:

		lea	dZ80+PCM1_Sample,a1	; load addresses for PCM 2
		lea	dZ80+PCM1_NewRET,a2	; ''

dNoteOnDAC4:
	StopZ80					; wait for Z80 to stop
	rept 12
		move.b	(a3)+,(a1)+		; send sample data to Dual PCM
	endr

		move.b	#$DA,(a2)		; activate sample switch (change instruction)
	StartZ80				; enable Z80 execution

locret_dNoteOnDAC4:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Write DAC frequency to Dual PCM
; ---------------------------------------------------------------------------

dUpdateFreqOffDAC2:
		lsl.w	#4,d0			; multiply sample ID by $10 (size of each entry)
		lea	$0C(a6,d0.w),a3		; get sample pitch to a3

dUpdateFreqOffDAC:
		move.w	cFreq(a5),d6		; get channel base frequency to d6
		add.w	(a3)+,d6		; add sample frequency offset to d6

		move.b	cDetune(a5),d0		; get detune value
		ext.w	d0			; extend to word
		add.w	d0,d6			; add it to d6

	if FEATURE_PORTAMENTO
		jsr	dModEnvProg(pc)		; process modulation envelope
	endif

	if FEATURE_PORTAMENTO
		add.w	cPortaFreq(a5),d6	; add portamento speed to frequency
	endif

	if FEATURE_MODULATION
		btst	#cfbMod,(a5)		; check if channel is modulating
		beq.s	dUpdateFreqDAC3		; if not, branch
		add.w	cModFreq(a5),d6		; add modulation frequency offset to d6
	endif
		bra.s	dUpdateFreqDAC3

dUpdateFreqDAC:
		btst	#cfbInt,(a5)		; is the channel interrupted by SFX?
		bne.s	locret_UpdFreqDAC	; if so, branch

dUpdateFreqDAC2:
		moveq	#0,d0			; make sure the upper byte is clear
		move.b	cSample(a5),d0		; get sample ID to d0
		eor.b	#$80,d0			; this allows us to have the full $100 range safely
		lsl.w	#4,d0			; multiply ID by $10 (size of each entry)
		add.w	$0C(a6,d0.w),d6		; add sample frequency offset to d6

dUpdateFreqDAC3:
	if safe=1
		AMPS_Debug_FreqDAC		; check if DAC frequency is in bounds
	endif

		move.b	d6,d0			; copy the frequency to d0
		lsr.w	#8,d6			; get the upper byte to the lower byte
		btst	#ctbPt2,cType(a5)	; check if DAC1
		beq.s	dFreqDAC1		; if is, branch

	StopZ80					; wait for Z80 to stop
		move.b	d6,dZ80+PCM2_PitchHigh+1
		move.b	d0,dZ80+PCM2_PitchLow+1
		move.b	#$D2,dZ80+PCM2_ChangePitch; change "JP C" to "JP NC"
	StartZ80				; enable Z80 execution

locret_UpdFreqDAC;
		rts

dFreqDAC1:
	StopZ80					; wait for Z80 to stop
		move.b	d6,dZ80+PCM1_PitchHigh+1
		move.b	d0,dZ80+PCM1_PitchLow+1
		move.b	#$D2,dZ80+PCM1_ChangePitch; change "JP C" to "JP NC"
	StartZ80				; enable Z80 execution
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Process SFX DAC channels
; ---------------------------------------------------------------------------

dAMPSdoSFX:
		lea	mSFXDAC1-cSize.w,a5	; get SFX DAC1 channel RAM address into a5

dAMPSdoDACSFX:
		add.w	#cSize,a5		; go to the next channel
		tst.b	(a5)			; check if channel is running a tracker
		bpl.w	.next			; if not, branch

		lea	SampleList(pc),a6	; get SampleList to a6 for quick access
		subq.b	#1,cDuration(a5)	; decrease note duration
		beq.w	.update			; if timed out, update channel

	dCalcFreq				; calculate channel base frequency
	dModPorta dAMPSdoFMSFX, dAMPSdoFMSFX, 5	; run modulation + portamento code
		bsr.w	dUpdateFreqDAC2		; if frequency needs changing, do it

	if FEATURE_DACFMVOLENV=0
		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.next			; if not, skip
	endif
		bsr.w	dUpdateVolDAC		; update DAC volume

.next
		jmp	dAMPSdoFMSFX(pc)	; after that, process SFX FM channels

.update
		and.b	#$FF-(1<<cfbHold),(a5)	; clear hold flag
	dDoTracker				; process tracker
		moveq	#0,d6			; clear rest flag
		tst.b	d5			; check if note is being played
		bpl.s	.timer			; if not, it must be a timer. Branch

	dTrackNoteDAC				; calculate frequency or update sample
		move.b	(a4)+,d5		; check if next note is a timer
		bpl.s	.timer			; if yes, handle timer
		subq.w	#1,a4			; else, undo the increment
		bra.s	.pcnote			; do not calculate duration

.timer
		jsr	dCalcDuration(pc)	; calculate duration
.pcnote
	dProcNote 1, -1				; reset necessary channel memory
		tst.b	d6			; check if channel was resting
		bmi.s	.noplay			; if yes, we do not want to note on anymore
		bsr.w	dNoteOnDAC		; do hardware note-on behavior

.noplay
	if FEATURE_DACFMVOLENV=0
		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.next2			; if not, skip
	endif
		bsr.w	dUpdateVolDAC		; update DAC volume

.next2
		jmp	dAMPSdoFMSFX(pc)	; after that, process SFX FM channels
; ===========================================================================
; ---------------------------------------------------------------------------
; Write DAC volume to Dual PCM
; ---------------------------------------------------------------------------

dUpdateVolDAC:
		move.b	cVolume(a5),d5		; get channel volume to d3
		add.b	mMasterVolDAC.w,d5	; add master volume to it
		bpl.s	.gotvol			; if positive (in range), branch
		moveq	#$FFFFFF80,d5		; force volume to mute ($80 is the last valid volume)

.gotvol
	if FEATURE_DACFMVOLENV
		moveq	#0,d4
		move.b	cVolEnv(a5),d4		; load volume envelope ID to d4
		beq.s	.ckflag			; if 0, check if volume update was needed

		jsr	dVolEnvProg(pc)		; run the envelope program
		bne.s	dUpdateVolDAC2		; if it was necessary to update volume, do so

.ckflag
		btst	#cfbVol,(a5)		; test volume update flag
		beq.s	locret_VolDAC		; branch if no volume update was requested
	endif

dUpdateVolDAC2:
	if FEATURE_DACFMVOLENV
		bclr	#cfbVol,(a5)		; clear volume update flag
	endif
		btst	#cfbInt,(a5)		; is the channel interrupted by SFX?
		bne.s	locret_VolDAC		; if yes, do not update

	StopZ80					; wait for Z80 to stop
		move.b	#$D2,dZ80+PCM_ChangeVolume; set volume change flag

		btst	#ctbPt2,cType(a5)	; check if this channel is DAC1
		beq.s	.dac1			; if is, branch
		move.b	d5,dZ80+PCM2_Volume+1	; save volume for PCM 1
	StartZ80				; enable Z80 execution
		rts

.dac1
		move.b	d5,dZ80+PCM1_Volume+1	; save volume for PCM 2
	StartZ80				; enable Z80 execution

locret_VolDAC:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Note to Dual PCM frequency conversion table
; ---------------------------------------------------------------------------
;	dc.w   C     C#    D     Eb    E     F     F#    G     G#    A     Bb    B
dFreqDAC:dc.w $0000								    ; Octave NOPE - (80)
	dc.w $0010,$0011,$0012,$0013,$0014,$0015,$0017,$0018,$0019,$001B,$001D,$001E; Octave 0 - (81 - 8C)
	dc.w $0020,$0022,$0024,$0026,$0028,$002B,$002D,$0030,$0033,$0036,$0039,$003C; Octave 1 - (8D - 98)
	dc.w $0040,$0044,$0048,$004C,$0051,$0055,$005B,$0060,$0066,$006C,$0072,$0079; Octave 2 - (99 - A4)
	dc.w $0080,$0088,$0090,$0098,$00A1,$00AB,$00B5,$00C0,$00CB,$00D7,$00E4,$00F2; Octave 3 - (A5 - B0)
	dc.w $0100,$010F,$011F,$0130,$0143,$0156,$016A,$0180,$0196,$01AF,$01C8,$01E3; Octave 4 - (B1 - BC)
	dc.w $0200,$021E,$023F,$0261,$0285,$02AB,$02D4,$02FF,$032D,$035D,$0390,$03C7; Octave 5 - (BD - C8)
	dc.w $0400,$043D,$047D,$04C2,$050A,$0557,$05A8,$05FE,$0659,$06BA,$0721,$078D; Octave 6 - (C9 - D4)
	dc.w $0800,$087A,$08FB,$0983,$0A14,$0AAE,$0B50,$0BFD,$0CB3,$0D74,$0E41,$0F1A; Octave 7 - (D5 - E0)
	dc.w $0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF; Octave 8 - (E1 - EC)
	dc.w $0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF; Octave 9 - (ED - F8)
	dc.w $0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF				    ; Octave 10 -(F9 - FF)

	dc.w			     -$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF; Octave -10 -(00 - 07)
	dc.w -$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF; Octave -9 - (08 - 13)
	dc.w -$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF,-$FFF; Octave -8 - (14 - 1F)
	dc.w -$F1A,-$E41,-$D74,-$CB3,-$BFD,-$B50,-$AAE,-$A14,-$983,-$8FB,-$87A,-$800; Octave -7 - (20 - 2B)
	dc.w -$78D,-$721,-$6BA,-$659,-$5FE,-$5A8,-$557,-$50A,-$4C2,-$47D,-$43D,-$400; Octave -6 - (2C - 37)
	dc.w -$3C7,-$390,-$35D,-$32D,-$2FF,-$2D4,-$2AB,-$285,-$261,-$23F,-$21E,-$200; Octave -5 - (38 - 43)
	dc.w -$1E3,-$1C8,-$1AF,-$196,-$180,-$16A,-$156,-$143,-$130,-$11F,-$10F,-$100; Octave -4 - (44 - 4F)
	dc.w -$0F2,-$0E4,-$0D7,-$0CB,-$0C0,-$0B5,-$0AB,-$0A1,-$098,-$090,-$088,-$080; Octave -3 - (50 - 5B)
	dc.w -$079,-$072,-$06C,-$066,-$060,-$05B,-$055,-$051,-$04C,-$048,-$044,-$040; Octave -2 - (5C - 67)
	dc.w -$03C,-$039,-$036,-$033,-$030,-$02D,-$02B,-$028,-$026,-$024,-$022,-$020; Octave -1 - (68 - 73)
	dc.w -$01E,-$01D,-$01B,-$019,-$018,-$017,-$015,-$014,-$013,-$012,-$011,-$010; Octave -0 - (74 - 7F)
