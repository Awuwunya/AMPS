; ===========================================================================
; ---------------------------------------------------------------------------
; Process music DAC channels
; ---------------------------------------------------------------------------

dAMPSdoDAC:
		lea	SampleList(pc),a3	; get SampleList to a3 for quick access
		lea	mDAC1-cSize.w,a1	; get DAC1 channel RAM address into a1
		moveq	#Mus_DAC-1,d0		; get total number of DAC channels to d0

dAMPSnextDAC:
		add.w	#cSize,a1		; go to the next channel (first time its mDAC1!)
		tst.b	(a1)			; check if channel is running a tracker
		bpl.w	.next			; if not, branch
		subq.b	#1,cDuration(a1)	; decrease note duration
		beq.w	.update			; if timed out, update channel

	dGateDAC	 			; handle DAC-specific gate behavior
	dCalcFreq				; calculate channel base frequency
	dModPortaWait	dAMPSdoFM, dAMPSnextDAC, 4; run modulation + portamento code
		bsr.w	dUpdateFreqDAC		; if frequency needs changing, do it

	if FEATURE_DACFMVOLENV=0
		bclr	#cfbVol,(a1)		; check if volume update is needed and clear bit
		beq.s	.next			; if not, skip
	endif
		bsr.w	dUpdateVolDAC		; update DAC volume

.next
		dbf	d0,dAMPSnextDAC		; make sure to run all the DAC channels
		jmp	dAMPSdoFM(pc)		; after that, process music FM channels
; ---------------------------------------------------------------------------

.update
		and.b	#$FF-(1<<cfbHold),(a1)	; clear hold flag
	dDoTracker				; process tracker
		moveq	#0,d4			; clear rest flag
		tst.b	d1			; check if note is being played
		bpl.s	.timer			; if not, it must be a timer. Branch

	dTrackNoteDAC				; calculate frequency or update sample
		move.b	(a2)+,d1		; check if next byte is a timer
		bpl.s	.timer			; if yes, handle it
		subq.w	#1,a2			; else, undo the increment
		bra.s	.pcnote			; do not calculate duration

.timer
		jsr	dCalcDuration(pc)	; calculate duration

.pcnote
	dProcNote 0, -1				; reset necessary channel memory
		tst.b	d4			; check if channel was resting
		bmi.s	.rest			; if yes, we do not want to note on anymore
		bsr.s	dNoteOnDAC		; do hardware note-on behavior
		bra.s	.ckvol
; ---------------------------------------------------------------------------

.rest
		moveq	#0,d3			; play stop sample
		bsr.s	dNoteOnDAC2		; ''

.ckvol
	if FEATURE_DACFMVOLENV=0
		bclr	#cfbVol,(a1)		; check if volume update is needed and clear bit
		beq.s	.next2			; if not, skip
	endif
		bsr.w	dUpdateVolDAC		; update DAC volume

.next2
		dbf	d0,dAMPSnextDAC		; make sure to run all the DAC channels
		jmp	dAMPSdoFM(pc)		; after that, process FM channels
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for hardware muting a DAC channel
;
; input:
;   a1 - Channel to operate on
;   a3 - Sample table to use
; thrash:
;   a2 - Used to select the data to send
;   a4 - Destination address for sample write
;   a5 - Address to tell Z80 sample is updated
; ---------------------------------------------------------------------------

dMuteDACmus:
		btst	#cfbInt,(a1)		; is the channel interrupted by SFX?
		bne.s	locret_dNoteOnDAC2	; if yes, do not update

dMuteDACsfx:
		move.l	a3,a2			; copy sample table to a2
		bra.s	dNoteOnDAC5		; continue to play mute sample
; ===========================================================================
; ---------------------------------------------------------------------------
; Write DAC sample information to Dual PCM
;
; input:
;   a1 - Channel address
; thrash:
;   a2 - Sample data address
;   a4 - Destination address for sample write
;   a5 - Address to tell Z80 sample is updated
;   d2 - Sample pitch
;   d3 - Used for sample address calculation
; ---------------------------------------------------------------------------

dNoteOnDAC2:
		btst	#cfbInt,(a1)		; is the channel interrupted by SFX?
		beq.s	dNoteOnDAC3		; if not, process note

locret_dNoteOnDAC2:
		rts
; ---------------------------------------------------------------------------

dNoteOnDAC:
		btst	#cfbInt,(a1)		; is the channel interrupted by SFX?
		bne.s	locret_dNoteOnDAC2	; if so, do not note on or update frequency

		moveq	#0,d3			; make sure the upper byte is clear
		move.b	cSample(a1),d3		; get sample ID to d3
		eor.b	#$80,d3			; this allows us to have the full $100 range safely

		btst	#cfbHold,(a1)		; check if note is held
		bne.w	dUpdateFreqOffDAC2	; if so, only update frequency

dNoteOnDAC3:
		lsl.w	#4,d3			; multiply sample ID by $10 (size of each entry)
		lea	(a3,d3.w),a2		; get sample data to a2
		pea	dUpdateFreqOffDAC(pc)	; update frequency after loading sample
; ---------------------------------------------------------------------------

dNoteOnDAC5:
		btst	#ctbPt2,cType(a1)	; check if this channel is DAC1
		beq.s	dNoteWriteDAC1		; if is, branch

		lea	dZ80+PCM2_Sample,a5	; load addresses for PCM 1
		lea	dZ80+PCM2_NewRET,a4	; ''
		bra.s	dNoteOnDAC4
; ---------------------------------------------------------------------------

dNoteWriteDAC1:

		lea	dZ80+PCM1_Sample,a5	; load addresses for PCM 2
		lea	dZ80+PCM1_NewRET,a4	; ''

dNoteOnDAC4:
	stopZ80					; wait for Z80 to stop
	rept 12
		move.b	(a2)+,(a5)+		; send sample data to Dual PCM
	endr

		move.b	#$DA,(a4)		; activate sample switch (change instruction)
	startZ80				; enable Z80 execution
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Write DAC frequency to Dual PCM
;
; input:
;   d3 - Sample ID
;   a1 - Channel address
; thrash:
;   a2 - Sample data address
;   d2 - Sample pitch
;   d3 - Temporary values
; ---------------------------------------------------------------------------

dUpdateFreqOffDAC2:
		lsl.w	#4,d3			; multiply sample ID by $10 (size of each entry)
		lea	$0C(a3,d3.w),a2		; get sample pitch to a2
; ---------------------------------------------------------------------------

dUpdateFreqOffDAC:
		move.w	cFreq(a1),d2		; get channel base frequency to d2
		add.w	(a2)+,d2		; add sample frequency offset to d2

		move.b	cDetune(a1),d3		; get detune value
		ext.w	d3			; extend to word
		add.w	d3,d2			; add it to d2
	dModPortaTrk	4			; run modulation and portamento code
		bra.s	dUpdateFreqDAC3
; ---------------------------------------------------------------------------

dUpdateFreqDAC:
		btst	#cfbInt,(a1)		; is the channel interrupted by SFX?
		bne.s	locret_UpdFreqDAC	; if so, branch

dUpdateFreqDAC2:
		moveq	#0,d3			; make sure the upper byte is clear
		move.b	cSample(a1),d3		; get sample ID to d3
		eor.b	#$80,d3			; this allows us to have the full $100 range safely
		lsl.w	#4,d3			; multiply ID by $10 (size of each entry)
		add.w	$0C(a3,d3.w),d2		; add sample frequency offset to d2
; ---------------------------------------------------------------------------

dUpdateFreqDAC3:
	if safe=1
		AMPS_Debug_FreqDAC		; check if DAC frequency is in bounds
	endif

	if FEATURE_SOUNDTEST
		move.w	d2,cChipFreq(a1)	; save frequency to chip
	endif

		move.b	d2,d3			; copy the frequency to d3
		lsr.w	#8,d2			; get the upper byte to the lower byte
		btst	#ctbPt2,cType(a1)	; check if DAC1
		beq.s	dFreqDAC1		; if is, branch

	stopZ80					; wait for Z80 to stop
		move.b	d2,dZ80+PCM2_PitchHigh+1
		move.b	d3,dZ80+PCM2_PitchLow+1
		move.b	#$D2,dZ80+PCM2_ChangePitch; change "JP C" to "JP NC"
	startZ80				; enable Z80 execution

locret_UpdFreqDAC;
		rts
; ---------------------------------------------------------------------------

dFreqDAC1:
	stopZ80					; wait for Z80 to stop
		move.b	d2,dZ80+PCM1_PitchHigh+1
		move.b	d3,dZ80+PCM1_PitchLow+1
		move.b	#$D2,dZ80+PCM1_ChangePitch; change "JP C" to "JP NC"
	startZ80				; enable Z80 execution
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Process SFX DAC channels
; ---------------------------------------------------------------------------

dAMPSdoSFX:
dAMPSdoDACSFX:
		lea	mSFXDAC1.w,a1		; get SFX DAC1 channel RAM address into a1
		tst.b	(a1)			; check if channel is running a tracker
		bpl.w	.next			; if not, branch

		lea	SampleList(pc),a3	; get SampleList to a3 for quick access
		subq.b	#1,cDuration(a1)	; decrease note duration
		beq.w	.update			; if timed out, update channel

	dCalcFreq				; calculate channel base frequency
	dModPortaWait	dAMPSdoFMSFX, dAMPSdoFMSFX, 5; run modulation + portamento code
		bsr.w	dUpdateFreqDAC2		; if frequency needs changing, do it

	if FEATURE_DACFMVOLENV=0
		bclr	#cfbVol,(a1)		; check if volume update is needed and clear bit
		beq.s	.next			; if not, skip
	endif
		bsr.w	dUpdateVolDAC_SFX	; update DAC volume

.next
		jmp	dAMPSdoFMSFX(pc)	; after that, process SFX FM channels
; ---------------------------------------------------------------------------

.update
		and.b	#$FF-(1<<cfbHold),(a1)	; clear hold flag
	dDoTracker				; process tracker
		moveq	#0,d4			; clear rest flag
		tst.b	d1			; check if note is being played
		bpl.s	.timer			; if not, it must be a timer. Branch

	dTrackNoteDAC				; calculate frequency or update sample
		move.b	(a2)+,d1		; check if next byte is a timer
		bpl.s	.timer			; if yes, handle it
		subq.w	#1,a2			; else, undo the increment
		bra.s	.pcnote			; do not calculate duration

.timer
		jsr	dCalcDuration(pc)	; calculate duration

.pcnote
	dProcNote 1, -1				; reset necessary channel memory
		tst.b	d4			; check if channel was resting
		bmi.s	.rest			; if yes, we do not want to note on anymore
		bsr.w	dNoteOnDAC		; do hardware note-on behavior
		bra.s	.ckvol
; ---------------------------------------------------------------------------

.rest
		moveq	#0,d3			; play stop sample
		bsr.w	dNoteOnDAC2		; ''

.ckvol
	if FEATURE_DACFMVOLENV=0
		bclr	#cfbVol,(a1)		; check if volume update is needed and clear bit
		beq.s	.next2			; if not, skip
	endif
		bsr.s	dUpdateVolDAC_SFX	; update DAC volume

.next2
		jmp	dAMPSdoFMSFX(pc)	; after that, process SFX FM channels
; ===========================================================================
; ---------------------------------------------------------------------------
; Write DAC volume to Dual PCM
;
; input:
;   a1 - Channel address
; thrash:
;   a2 - Used for envelope data address
;   d1 - Used for volume calculations
;   d4 - Used (maybe) for envelope calculations
; ---------------------------------------------------------------------------

dUpdateVolDAC_SFX:
	if FEATURE_SFX_MASTERVOL=0
		move.b	cVolume(a1),d1		; get channel volume to d1
		ext.w	d1			; extend to a word
		bra.s	dUpdateVolDAC3		; do not add master volume
	endif
; ---------------------------------------------------------------------------

dUpdateVolDAC:
		move.b	mMasterVolDAC.w,d1	; load DAC master volume to d1
		ext.w	d1			; extend to word

		move.b	cVolume(a1),d4		; load channel volume to d4
		ext.w	d4			; extend to word
		add.w	d4,d1			; add channel volume to d1

dUpdateVolDAC3:
	if FEATURE_DACFMVOLENV
		moveq	#0,d4
		move.b	cVolEnv(a1),d4		; load volume envelope ID to d4
		beq.s	.ckflag			; if 0, check if volume update was needed

		jsr	dVolEnvProg(pc)		; run the envelope program
		bne.s	dUpdateVolDAC2		; if it was necessary to update volume, do so

.ckflag
		btst	#cfbVol,(a1)		; test volume update flag
		beq.s	locret_VolDAC		; branch if no volume update was requested
	endif
; ---------------------------------------------------------------------------

dUpdateVolDAC2:
	if FEATURE_DACFMVOLENV
		bclr	#cfbVol,(a1)		; clear volume update flag
	endif
		btst	#cfbInt,(a1)		; is the channel interrupted by SFX?
		bne.s	locret_VolDAC		; if yes, do not update

		cmp.w	#$80,d1			; check if volume is out of range
		bls.s	.nocap			; if not, branch
		spl	d1			; if positive (above $7F), set to $FF. Otherwise, set to $00
		and.b	#$80,d1			; change volume of $FF to $80 (this mutes DAC)

.nocap
	if FEATURE_SOUNDTEST
		move.b	d1,cChipVol(a1)		; save volume to chip
	endif

	stopZ80					; wait for Z80 to stop
		move.b	#$D2,dZ80+PCM_ChangeVolume; set volume change flag

		btst	#ctbPt2,cType(a1)	; check if this channel is DAC1
		beq.s	.dac1			; if is, branch
		move.b	d1,dZ80+PCM2_Volume+1	; save volume for PCM 2
	startZ80				; enable Z80 execution
		rts
; ---------------------------------------------------------------------------

.dac1
		move.b	d1,dZ80+PCM1_Volume+1	; save volume for PCM 1
	startZ80				; enable Z80 execution

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
; ---------------------------------------------------------------------------
