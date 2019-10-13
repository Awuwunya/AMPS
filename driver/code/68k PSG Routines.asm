; ===========================================================================
; ---------------------------------------------------------------------------
; Process SFX PSG channels
; ---------------------------------------------------------------------------

dAMPSdoPSGSFX:
		moveq	#SFX_PSG-1,d7		; get total number of SFX PSG channels to d7
		lea	dFreqPSG(pc),a6		; load PSG frequency table for quick access to a6

dAMPSnextPSGSFX:
		add.w	#cSizeSFX,a5		; go to the next channel
		tst.b	(a5)			; check if channel is running a tracker
		bpl.w	.next			; if not, branch
		subq.b	#1,cDuration(a5)	; decrease note duration
		beq.w	.update			; if timed out, update channel

	dCalcFreq				; calculate channel base frequency
	dModPorta .endm, -1, -1			; run modulation + portamento code
		bsr.w	dUpdateFreqPSG3		; if frequency needs changing, do it

.endm
		bsr.w	dEnvelopePSG_SFX	; run envelope program
.next
		dbf	d7,dAMPSnextPSGSFX	; make sure to run all the channels
		jmp	dCheckTracker(pc)	; after that, check tracker and end loop

.update
		and.b	#$FF-(1<<cfbHold)-(1<<cfbRest),(a5); clear hold and rest flags
	dDoTracker				; process tracker
		tst.b	d5			; check if note is being played
		bpl.s	.timer			; if not, it must be a timer. Branch

	dGetFreqPSG				; get PSG frequency
		move.b	(a4)+,d5		; check if next note is a timer
		bpl.s	.timer			; if yes, handle timer
		subq.w	#1,a4			; else, undo the increment
		bra.s	.pcnote			; do not calculate duration

.timer
		jsr	dCalcDuration(pc)	; calculate duration
.pcnote
	dProcNote 1, 1				; reset necessary channel memory
		bsr.w	dUpdateFreqPSG		; update hardware frequency
		bsr.w	dEnvelopePSG_SFX	; run envelope program
		dbf	d7,dAMPSnextPSGSFX	; make sure to run all the channels
	; continue to check tracker and end loop
; ===========================================================================
; ---------------------------------------------------------------------------
; End channel loop and check if tracker debugger should be opened
; ---------------------------------------------------------------------------

dCheckTracker:
	if safe=1
		tst.b	msChktracker.w		; check if tracker debugger flag was set
		beq.s	.rts			; if not, skip
		clr.b	msChktracker.w		; clear that flag
		AMPS_Debug_ChkTracker		; run debugger
	endif
.rts
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Music PSG channel loop
; ---------------------------------------------------------------------------

dAMPSdoPSG:
		moveq	#Mus_PSG-1,d7		; get total number of music PSG channels to d7
		lea	dFreqPSG(pc),a6		; load PSG frequency table for quick access to a6

dAMPSnextPSG:
		add.w	#cSize,a5		; go to the next channe
		tst.b	(a5)			; check if channel is running a tracker
		bpl.w	.next			; if not, branch
		subq.b	#1,cDuration(a5)	; decrease note duration
		beq.w	.update			; if timed out, update channel

	dNoteToutPSG				; handle PSG-specific note timeout behavior
	dCalcFreq				; calculate channel base frequency
	dModPorta .endm, -1, -1			; run modulation + portamento code
		bsr.w	dUpdateFreqPSG2		; if frequency needs changing, do it

.endm
		bsr.w	dEnvelopePSG		; run envelope program
.next
		dbf	d7,dAMPSnextPSG		; make sure to run all the channels
		jmp	dAMPSdoDACSFX(pc)	; after that, process SFX DAC channels

.update
		and.b	#$FF-(1<<cfbHold)-(1<<cfbRest),(a5); clear hold and rest flags
	dDoTracker				; process tracker
		tst.b	d5			; check if note is being played
		bpl.s	.timer			; if not, it must be a timer. branch

	dGetFreqPSG				; get PSG frequency
		move.b	(a4)+,d5		; check if next note is a timer
		bpl.s	.timer			; if yes, handle timer
		subq.w	#1,a4			; else, undo the increment
		bra.s	.pcnote			; do not calculate duration

.timer
		jsr	dCalcDuration(pc)	; calculate duration
.pcnote
	dProcNote 0, 1				; reset necessary channel memory

		bsr.s	dUpdateFreqPSG		; update hardware frequency
		bsr.w	dEnvelopePSG		; run envelope program
		dbf	d7,dAMPSnextPSG		; make sure to run all the channels
		jmp	dAMPSdoDACSFX(pc)	; after that, process SFX DAC channels
; ===========================================================================
; ---------------------------------------------------------------------------
; Write PSG frequency to hardware
; ---------------------------------------------------------------------------

dUpdateFreqPSG:
		move.w	cFreq(a5),d6		; get channel base frequency to d6
		bpl.s	.detune			; if it was not rest frequency, branch
		bset	#cfbRest,(a5)		; set channel resting flag
		rts

.detune
		move.b	cDetune(a5),d0		; load detune value to d0
		ext.w	d0			; extend to word
		add.w	d0,d6			; add to channel base frequency to d6

	if FEATURE_PORTAMENTO
		jsr	dModEnvProg(pc)		; process modulation envelope
	endif

	if FEATURE_PORTAMENTO
		add.w	cPortaFreq(a5),d6	; add portamento speed to frequency
	endif

	if FEATURE_MODULATION
		btst	#cfbMod,(a5)		; check if channel is modulating
		beq.s	dUpdateFreqPSG2		; if not, branch
		add.w	cModFreq(a5),d6		; add modulation frequency offset to d6
	endif

dUpdateFreqPSG2:
		btst	#cfbInt,(a5)		; is channel interrupted by sfx?
		bne.s	locret_UpdateFreqPSG	; if so, skip

dUpdateFreqPSG3:
		btst	#cfbRest,(a5)		; is this channel resting
		bne.s	locret_UpdateFreqPSG	; if so, skip

		move.b	cType(a5),d0		; load channel type value to d0
		cmpi.b	#ctPSG4,d0		; check if this channel is in PSG4 mode
		bne.s	.notPSG4		; if not, branch
		moveq	#$FFFFFF00|ctPSG3,d0	; load PSG3 type value instead

.notPSG4
		move.w	d6,d1			; copy frequency to d1
		andi.b	#$F,d1			; get the low nibble of it
		or.b	d1,d0			; combine with channel type
; ---------------------------------------------------------------------------
; Note about the and instruction below: If this instruction is
; not commented out, the instashield SFX will not sound correct.
; This instruction was removed in Sonic 3K because of this, but
; this can cause issues when values overflow the valid range of
; PSG frequency. This may cause erroneous behavior if not anded,
; but will also make the instashield SFX not sound correctly.
; Comment out the instruction with caution, if you are planning
; to port said sound effect to this driver. This has not caused
; any issues for me, and if you are careful you can avoid any
; such case, but beware of this issue!
; ---------------------------------------------------------------------------

		lsr.w	#4,d6			; get the 2 higher nibbles of frequency
		andi.b	#$3F,d6			; clear any extra bits that aren't valid
		move.b	d0,dPSG			; write frequency low nibble and latch channel
		move.b	d6,dPSG			; write frequency high nibbles to PSG

locret_UpdateFreqPSG:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for running envelope programs
; ---------------------------------------------------------------------------

dEnvelopePSG_SFX:
	if FEATURE_SFX_MASTERVOL=0
		btst	#cfbRest,(a5)		; check if channel is resting
		bne.s	locret_UpdateFreqPSG	; if is, do not update anything

		move.b	cVolume(a5),d5		; load channel volume to d5
		bra.s	dEnvelopePSG2		; do not add master volume
	endif

dEnvelopePSG:
		btst	#cfbRest,(a5)		; check if channel is resting
		bne.s	locret_UpdateFreqPSG	; if is, do not update anything

		move.b	mMasterVolPSG.w,d5	; load PSG master volume to d5
		add.b	cVolume(a5),d5		; add channel volume to d5
		bpl.s	dEnvelopePSG2		; branch if volume did not overflow
		moveq	#$7F,d5			; set to maximum volume

dEnvelopePSG2:
		moveq	#0,d4
		move.b	cVolEnv(a5),d4		; load volume envelope ID to d4
		beq.s	.ckflag			; if 0, check if volume update was needed

		jsr	dVolEnvProg(pc)		; run the envelope program
		bne.s	dUpdateVolPSG		; if it was necessary to update volume, do so

.ckflag
		btst	#cfbVol,(a5)		; test volume update flag
		beq.s	locret_UpdVolPSG	; branch if no volume update was requested
	; continue to update PSG volume
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for updating PSG volume to hardware
; ---------------------------------------------------------------------------

dUpdateVolPSG:
		bclr	#cfbVol,(a5)		; clear volume update flag
		btst	#cfbRest,(a5)		; is this channel resting
		bne.s	locret_UpdVolPSG	; if is, do not update
		btst	#cfbInt,(a5)		; is channel interrupted by sfx?
		bne.s	locret_UpdVolPSG	; if is, do not update

		btst	#cfbHold,(a5)		; check if note is held
		beq.s	.send			; if not, update volume
		cmp.w	#mSFXDAC1,a5		; check if this is a SFX channel
		bhs.s	.send			; if so, update volume

		tst.b	cNoteTimeMain(a5)	; check if note timeout is active
		beq.s	.send			; if not, update volume
		tst.b	cNoteTimeCur(a5)	; is note stopped already?
		beq.s	locret_UpdVolPSG	; if is, do not update

.send
		cmpi.b	#$7F,d5			; check if volume is out of range
		bls.s	.nocap			; if not, branch
		moveq	#$7F,d5			; cap volume to silent

.nocap
		lsr.b	#3,d5			; divide volume by 8
		or.b	cType(a5),d5		; combine channel type value with volume
		or.b	#$10,d5			; set volume update bit
		move.b	d5,dPSG			; write volume command to PSG port

locret_UpdVolPSG:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for hardware muting a PSG channel
; ---------------------------------------------------------------------------

dMutePSGmus:
		btst	#cfbInt,(a5)		; check if this is a SFX channel
		bne.s	locret_MutePSG		; if yes, do not update

dMutePSGsfx:
		moveq	#$1F,d0			; prepare volume update to mute value to d0
		or.b	cType(a5),d0		; combine channel type value with d0
		move.b	d0,dPSG			; write volume command to PSG port

locret_MutePSG:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Note to PSG frequency conversion table
; ---------------------------------------------------------------------------
;	dc.w	C     C#    D     Eb    E     F     F#    G     G#    A     Bb    B
dFreqPSG:dc.w $0356,$0326,$02F9,$02CE,$02A5,$0280,$025C,$023A,$021A,$01FB,$01DF,$01C4; Octave 3 - (81 - 8C)
	dc.w  $01AB,$0193,$017D,$0167,$0153,$0140,$012E,$011D,$010D,$00FE,$00EF,$00E2; Octave 4 - (8D - 98)
	dc.w  $00D6,$00C9,$00BE,$00B4,$00A9,$00A0,$0097,$008F,$0087,$007F,$0078,$0071; Octave 5 - (99 - A4)
	dc.w  $006B,$0065,$005F,$005A,$0055,$0050,$004B,$0047,$0043,$0040,$003C,$0039; Octave 6 - (A5 - B0)
	dc.w  $0036,$0033,$0030,$002D,$002B,$0028,$0026,$0024,$0022,$0020,$001F,$001D; Octave 7 - (B1 - BC)
	dc.w  $001B,$001A,$0018,$0017,$0016,$0015,$0013,$0012,$0011		     ; Notes (BD - C5)
	dc.w  $0000								     ; Note (C6)
dFreqPSG_:
	if safe=1				; in safe mode, we have extra debug data
.x = $100|((dFreqPSG_-dFreqPSG)/2)		; to check if we played an invalid note
		rept $80-((dFreqPSG_-dFreqPSG)/2); and if so, tell us which note it was
			dc.w .x
.x =			.x+$101
		endr
	endif
