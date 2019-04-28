	opt oz+					; enable zero-offset optimization
	opt l.					; local lables are dots
	opt ae+					; enable automatic even's

	include "driver/code/routines.asm"	; include macro'd routines
	include "driver/code/debug.asm"		; debug data blob
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for loading the Dual PCM driver into Z80 RAM
; ---------------------------------------------------------------------------

LoadDualPCM:
		move	#$2700,sr		; disable interrupts
		move.w	#$0100,$A11100		; request Z80 stop
		move.w	#$0100,$A11200		; Z80 reset off

		lea	DualPCM,a0		; load Dual PCM address into a0
		lea	dZ80,a1			; load Z80 RAM address into a1
		move.w	#DualPCM_sz-1,d1	; get lenght counter for dbf into d1

.z80
		btst	#$00,$A11100		; check if Z80 has stopped
		bne.s	.z80			; if not, wait more

.load
		move.b	(a0)+,(a1)+		; copy the Dual PCM driver into Z80 RAM
		dbf	d1,.load		; write every single byte

		lea	SampleList(pc),a0	; load address for the stop sample data into a0
		lea	dZ80+MuteSample,a1	; load address in Dual PCM to write into a1

	rept 6
		move.b	(a0)+,(a1)+		; copy all required data
	endr

		moveq	#2,d0			; set flush timer for 60hz systems
		btst	#6,Region.w		; is this a PAL Mega Drive?
		beq.s	.ntsc			; if not, branch
		moveq	#3,d0			; set flush timer for 50hz systems
.ntsc
		move.b	d0,dZ80+YM_FlushTimer+2	; save flush timer

		move.w	#$0000,$A11200		; request Z80 reset
		moveq	#$7F,d1			; wait for a little bit
		dbf	d1,*			; we can't check for reset, so we need to delay

		move.w	#$0000,$A11100		; enable Z80
		move.w	#$0100,$A11200		; Z80 reset off
		move	#$2300,sr		; enable interrupts
		rts
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
		lea	dFadeCommands-$80(pc),a2; load fade commands pointer table to a2
		jsr	(a2,d0.w)		; run the fade command code
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

.chkregion	btst	#6,Region.w		; is this PAL system?
		beq.s	.driver			; if not, branch
		subq.b	#1,mCtrPal.w		; decrease PAL frame counter
		bgt.s	.driver			; if hasn't become 0 (or lower!), branch

		btst	#mfbNoPAL,mFlags.w	; check if we have disabled the PAL fix
		bne.s	.nofix			; if yes, run music and SFX
		bsr.s	.nosfx			; run the sound driver

.nofix
		move.b	#6-1,mCtrPal.w		; reset counter
.driver
		bsr.w	dAMPSdoSFX		; run SFX this time

.nosfx		; continue to run sound driver again
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
		bcc.s	dAMPSdoAll		; if carry clear, branch

	else		; Counter method
		subq.b	#1,mTempoCur.w		; sub 1 from counter
		bne.s	dAMPSdoAll		; if nonzero, branch
		move.b	mTempo.w,mTempoCur.w	; copy tempo again
	endif

.ch =	mDAC1+cDuration				; start at DAC1 duration
	rept Mus_Ch				; loop through all music channels
		addq.b	#1,.ch.w		; add 1 to duration
.ch =		.ch+cSize			; go to next channel
	endr
; ===========================================================================
; ---------------------------------------------------------------------------
; Process music DAC channels
; ---------------------------------------------------------------------------

dAMPSdoAll:
		lea	SampleList(pc),a6	; get SampleList to a6 for quick access
		lea	mDAC1-cSize.w,a5	; get DAC1 channel RAM address into a5
		moveq	#Mus_DAC-1,d7		; get total number of DAC channels to d7

dAMPSdoDAC:
		add.w	#cSize,a5		; go to the next channel (first time its mDAC1!)
		tst.b	(a5)			; check if channel is running a tracker
		bpl.w	.next			; if not, branch
		subq.b	#1,cDuration(a5)	; decrease note duration
		beq.w	.update			; if timed out, update channel
	dNoteToutDAC	 			; handle DAC-specific note timeout behavior

	dCalcFreq				; calculate channel base frequency
	dModulate dAMPSdoFM, dAMPSdoDAC, 4	; run modulation code
		bsr.w	dUpdateFreqDAC		; if frequency needs changing, do it

		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.next			; if not, skip
		bsr.w	dUpdateVolDAC		; update DAC volume

.next
		dbf	d7,dAMPSdoDAC		; make sure to run all the channels
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
	dProcNote 0, 0				; reset necessary channel memory

		tst.b	d6			; check if channel was resting
		bmi.s	.noplay			; if yes, we do not want to note on anymore
		bsr.s	dNoteOnDAC		; do hardware note-on behavior

.noplay		dbf	d7,dAMPSdoDAC		; make sure to run all the channels
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

		btst	#cfbMod,(a5)		; check if channel is modulating
		beq.s	dUpdateFreqDAC3		; if not, branch
		add.w	cModFreq(a5),d6		; add modulation frequency offset to d6
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
; Routine to multiply duration by tick rate
; We actually use a dbf loop instead of mulu, because 2 rounds
; around the loop will be faster than a single mulu instruction
; ---------------------------------------------------------------------------

dCalcDuration:
		moveq	#0,d0			; clear duration
		moveq	#0,d1			; clear upper bytes (for dbf)
		move.b	cTick(a5),d1		; get tick multiplier to d1

.multiply	add.b	d5,d0			; add duration value to d0
		dbf	d1,.multiply		; multiply by tick rate

		move.b	d0,cLastDur(a5)		; save as the new duration
		rts				; get copied to duration by later code
; ===========================================================================
; ---------------------------------------------------------------------------
; Process SFX DAC channels
; ---------------------------------------------------------------------------

dAMPSdoSFX:
		lea	mSFXDAC1-cSizeSFX.w,a5	; get SFX DAC1 channel RAM address into a5

dAMPSdoDACSFX:
		add.w	#cSizeSFX,a5		; go to the next channel
		tst.b	(a5)			; check if channel is running a tracker
		bpl.s	.next			; if not, branch

		lea	SampleList(pc),a6	; get SampleList to a6 for quick access
		subq.b	#1,cDuration(a5)	; decrease note duration
		beq.w	.update			; if timed out, update channel

	dCalcFreq				; calculate channel base frequency
	dModulate dAMPSdoFMSFX, dAMPSdoDAC, 5	; run modulation code
		bsr.w	dUpdateFreqDAC2		; if frequency needs changing, do it

		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.next			; if not, skip
		bsr.w	dUpdateVolDAC2		; update DAC volume

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
	dProcNote 1, 0				; reset necessary channel memory
		tst.b	d6			; check if channel was resting
		bmi.s	.noplay			; if yes, we do not want to note on anymore
		bsr.w	dNoteOnDAC		; do hardware note-on behavior

.noplay
		jmp	dAMPSdoFMSFX(pc)	; after that, process SFX FM channels
; ===========================================================================
; ---------------------------------------------------------------------------
; Write DAC volume to Dual PCM
; ---------------------------------------------------------------------------

dUpdateVolDAC:
		btst	#cfbInt,(a5)		; is the channel interrupted by SFX?
		bne.s	locret_VolDAC		; if yes, do not update

dUpdateVolDAC2:
		move.b	cVolume(a5),d3		; get channel volume to d3
		add.b	mMasterVolDAC.w,d3	; add master volume to it
		bpl.s	.gotvol			; if positive (in range), branch
		moveq	#$FFFFFF80,d3		; force volume to mute ($80 is the last valid volume)

.gotvol
	StopZ80					; wait for Z80 to stop
		move.b	#$D2,dZ80+PCM_ChangeVolume; set volume change flag

		btst	#ctbPt2,cType(a5)	; check if this channel is DAC1
		beq.s	.dac1			; if is, branch
		move.b	d3,dZ80+PCM2_Volume+1	; save volume for PCM 1
	StartZ80				; enable Z80 execution
		rts

.dac1
		move.b	d3,dZ80+PCM1_Volume+1	; save volume for PCM 2
	StartZ80				; enable Z80 execution

locret_VolDAC:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for unpausing the sound driver
; ---------------------------------------------------------------------------

dPlaySnd_Unpause:
		bclr	#mfbPaused,mFlags.w	; unpause music
		beq.s	locret_VolDAC		; if was already unpaused, skip
; ---------------------------------------------------------------------------
; The following code will reset the panning values for each running
; channel. It also makes sure that the channel is not interrupted
; by sound effects, and that each running sound effect channel gets
; updated. We do not handle key on's, since that could potentially
; cause issues if notes are half-done. The next time tracker plays
; notes, they start being audible again.
; ---------------------------------------------------------------------------

		lea	mFM1.w,a5		; start from FM1 channel
		moveq	#Mus_FM-1,d4		; load the number of music FM channels to d4
		moveq	#cSize,d3		; get the size of each music channel to d3

.musloop
		tst.b	(a5)			; check if the channel is running a tracker
		bpl.s	.skipmus		; if not, do not update
		btst	#cfbInt,(a5)		; is the channel interrupted by SFX?
		bne.s	.skipmus		; if is, do not update

		moveq	#$FFFFFFB4,d0		; YM address: Panning and LFO
		move.b	cPanning(a5),d1		; read panning and LFO value from channel
		jsr	WriteChYM(pc)		; write to appropriate YM register

.skipmus
		adda.w	d3,a5			; go to next channel
		dbf	d4,.musloop		; repeat for all music FM channels

		lea	mSFXFM3.w,a5		; start from SFX FM1 channel
		moveq	#SFX_FM-1,d4		; load the number of SFX FM channels to d4
		moveq	#cSizeSFX,d3		; get the size of each SFX channel to d3

.sfxloop
		tst.b	(a5)			; check if the channel is running a tracker
		bpl.s	.skipsfx		; if not, do not update

		moveq	#$FFFFFFB4,d0		; YM address: Panning and LFO
		move.b	cPanning(a5),d1		; read panning and LFO value from channel
		jsr	WriteChYM(pc)		; write to appropriate YM register

.skipsfx
		adda.w  d3,a5			; go to next channel
		dbf     d4,.sfxloop		; repeat for all SFX FM channels
; ---------------------------------------------------------------------------
; Since the DAC channels have or based panning behavior, we need this
; piece of code to update its panning
; ---------------------------------------------------------------------------

		move.b	mDAC1+cPanning.w,d1	; read panning value from music DAC1
		btst	#cfbInt,mDAC1+cFlags.w	; check if music DAC1 is interrupted by SFX
		beq.s	.nodacsfx		; if not, use music DAC1 panning
		move.b	mSFXDAC1+cPanning.w,d1	; read panning value from SFX DAC1

.nodacsfx
		or.b	mDAC2+cPanning.w,d1	; or the panning value from music DAC2
		moveq	#$FFFFFFB4+2,d0		; YM address: Panning and LFO (FM3/6)
		jmp	WriteYM_Pt2(pc)		; write to part 2 channel
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for pausing the sound driver
; ---------------------------------------------------------------------------

dPlaySnd_Pause:
		bset	#mfbPaused,mFlags.w	; pause music
		bne.s	locret_VolDAC		; if was already paused, skip
; ---------------------------------------------------------------------------
; The following code will set channel panning to none for all FM channels.
; This will ensure they are muted while we are pausing.
; ---------------------------------------------------------------------------

		moveq	#3-1,d3			; 3 channels per YM2616 "part"
		moveq	#$FFFFFFB4,d0		; YM address: Panning and LFO
		moveq	#0,d1			; pan to neither speaker and remove LFO

.muteFM
		jsr	WriteYM_Pt1(pc)		; write to part 1 channel
		jsr	WriteYM_Pt2(pc)		; write to part 2 channel
		addq.b	#1,d0			; go to next FM channel
		dbf	d3,.muteFM		; write each 3 channels per part
; ---------------------------------------------------------------------------
; The following code will key off all FM channels. There is a special
; behavior in that, we must write all channels into part 1, and we
; control the channel we are writing in the data portion.
; 4 bits are reserved for which operators are active (in this case,
; none), and 3 bits are reserved for the channel we want to affect.
; ---------------------------------------------------------------------------

		moveq	#$28,d0			; YM address: Key on/off
		moveq	#%00000010,d3		; turn keys off, and start from YM channel 3

.note
		move.b	d3,d1			; copy value into d1
		jsr	WriteYM_Pt1(pc)		; write to part 1 channel
		addq.b	#4,d1			; set this to part 2 channel
		jsr	WriteYM_Pt1(pc)		; write to part 2 channel
		dbf	d3,.note		; loop for all 3 channel groups

		jsr	dMutePSG(pc)		; mute all PSG channels
	; continue to mute all DAC channels
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for muting all DAC channels
; ---------------------------------------------------------------------------

dMuteDAC:
	StopZ80					; wait for Z80 to stop
		lea	SampleList(pc),a2	; load address for the stop sample data into a2
		lea	dZ80+PCM1_Sample,a1	; load addresses for PCM 1 sample to a1

	rept 12
		move.b	(a2)+,(a1)+		; send sample data to Dual PCM
	endr

		move.b	#$CA,dZ80+PCM1_NewRET	; activate sample switch (change instruction)

		lea	SampleList(pc),a2	; load address for the stop sample data into a2
		lea	dZ80+PCM2_Sample,a1	; load addresses for PCM 2 sample to a1

	rept 12
		move.b	(a2)+,(a1)+		; send sample data to Dual PCM
	endr

		move.b	#$CA,dZ80+PCM2_NewRET	; activate sample switch (change instruction)
	StartZ80				; enable Z80 execution

locret_MuteDAC:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to play any queued music tracks, sound effects or commands
; ---------------------------------------------------------------------------

dPlaySnd:
		lea	mQueue.w,a6		; get address to the sound queue
		moveq	#0,d7
		move.b	(a6)+,d7		; get sound ID for this slot
		bne.s	.found			; if nonzero, a sound is queued
		move.b	(a6)+,d7		; get sound ID for this slot
		bne.s	.found			; if nonzero, a sound is queued
		move.b	(a6)+,d7		; get sound ID for this slot
		beq.s	locret_MuteDAC		; if 0, no sounds were queued, return

.found
		clr.b	-1(a6)			; clear the slot we are processing
		cmpi.b	#SFXoff,d7		; check if this sound was a sound effect
		bhs.w	dPlaySnd_SFX		; if so, handle it
		cmpi.b	#MusOff,d7		; check if this sound was a command
		blo.w	dPlaySnd_Comm		; if so, handle it
	; it was music, handle it below
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to play a queued music track
; ---------------------------------------------------------------------------

dPlaySnd_Music:
		jsr	dStopMusic(pc)		; mute hardware and reset all driver memory
		jsr	dResetVolume(pc)	; reset volumes and end any fades
; ---------------------------------------------------------------------------
; To save few cycles, we don't directly substract the music offset from
; the ID, and instead offset the table position. In practice this will
; have the same effect, but saves us 8 cycles overall.
; ---------------------------------------------------------------------------

		lea	MusicIndex-(MusOff*4)(pc),a4; get music pointer table with an offset
		add.w	d7,d7			; quadruple music ID
		add.w	d7,d7			; since each entry is 4 bytes in size
		move.b	(a4,d7.w),mTempoSpeed.w	; load speed shoes tempo from the unused 8 bits
		movea.l	(a4,d7.w),a4		; get music header pointer from the table

	if safe=1
		move.l	a4,d0			; copy pointer to d0
		and.l	#$FFFFFF,d0		; clearing the upper 8 bits allows the debugger
		move.l	d0,a4			; to show the address correctly. Move ptr back to a4
		AMPS_Debug_PlayTrackMus		; check if this was valid music
	endif

		move.l	a4,a3			; copy pointer to a3
		addq.w	#4,a4			; go to DAC1 data section

		moveq	#0,d0
		move.b	1(a3),d0		; load song tempo to d0
		move.b	d0,mTempoMain.w		; save as regular tempo
		btst	#mfbSpeed,mFlags.w	; check if speed shoes flag was set
		beq.s	.tempogot		; if not, use main tempo
		move.b	mTempoSpeed.w,d0	; load speed shoes tempo to d0 instead

.tempogot
		move.b	d0,mTempo.w		; save as the current tempo
		move.b	d0,mTempoCur.w		; copy into the accumulator/counter
		and.b	#$FF-(1<<mfbNoPAL),mFlags.w; enable PAL fix
; ---------------------------------------------------------------------------
; If the 7th bit (msb) of tick multiplier is set, PAL fix gets
; disabled. I know, very weird place to put it, but we dont have
; much free room in the song header
; ---------------------------------------------------------------------------

		move.b	(a3),d4			; load the tick multiplier to d4
		bpl.s	.noPAL			; branch if the loaded value was positive
		and.w	#$7F,d4			; keep value in range
		or.b	#1<<mfbNoPAL,mFlags.w	; disable PAL fix

.noPAL
		moveq	#$FFFFFF00|(1<<cfbRun)|(1<<cfbVol),d2; prepare running tracker and volume flags into d2
		moveq	#$FFFFFFC0,d1		; prepare panning value of centre to d1
		moveq	#cSize,d6		; prepare channel size to d6
		moveq	#1,d5			; prepare duration of 0 frames to d5

		lea	mDAC1.w,a1		; start from DAC1 channel
		lea	dDACtypeVals(pc),a2	; prepare DAC (and FM) type value list into a2
		moveq	#2-1,d7			; always run for 2 DAC channels
		move.w	#$100,d3		; prepare default DAC frequency

.loopDAC
		move.b	d2,(a1)			; save channel flags
		move.b	(a2)+,cType(a1)		; load channel type from list
		move.b	d4,cTick(a1)		; set channel tick multiplier
		move.b	d6,cStack(a1)		; reset channel stack pointer
		move.b	d1,cPanning(a1)		; reset panning to centre
		move.b	d5,cDuration(a1)	; reset channel duration
		move.w	d3,cFreq(a1)		; reset channel base frequency

		moveq	#0,d0
		move.w	(a4)+,d0		; load tracker offset to d0
		add.l	a3,d0			; add music header offset to d0
		move.l	d0,cData(a1)		; save as the tracker address of the channel
	if safe=1
		AMPS_Debug_PlayTrackMus2 DAC	; make sure the tracker address is valid
	endif

		move.b	(a4)+,cVolume(a1)	; load channel volume
		move.b	(a4)+,cSample(a1)	; load channel sample ID
		beq.s	.sampmode		; if 0, we are in sample mode
		bset	#cfbMode,(a1)		; if not 0, enable pitch mode

.sampmode
		add.w	d6,a1			; go to the next channel
		dbf	d7,.loopDAC		; repeat for all DAC channels

		moveq	#0,d7
		moveq	#$FFFFFF00|(1<<cfbRun)|(1<<cfbRest),d2; prepare running tracker and channel rest flags
		move.b	2(a3),d7		; load the FM channel count to d7
		bmi.s	.doPSG			; if no FM channels are loaded, branch

.loopFM
		move.b	d2,(a1)			; save channel flags
		move.b	(a2)+,cType(a1)		; load channel type from list
		move.b	d4,cTick(a1)		; set channel tick multiplier
		move.b	d6,cStack(a1)		; reset channel stack pointer
		move.b	d1,cPanning(a1)		; reset panning to centre
		move.b	d5,cDuration(a1)	; reset channel duration

		moveq	#0,d0
		move.w	(a4)+,d0		; load tracker offset to d0
		add.l	a3,d0			; add music header offset to d0
		move.l	d0,cData(a1)		; save as the tracker address of the channel
	if safe=1
		AMPS_Debug_PlayTrackMus2 FM	; make sure the tracker address is valid
	endif

		move.w	(a4)+,cPitch(a1)	; load pitch offset and channel volume
		adda.w	d6,a1			; go to the next channel
		dbf	d7,.loopFM		; repeat for all FM channels

.doPSG
		moveq	#0,d7
		move.b	3(a3),d7		; load the FM channel count to d7
	if safe=1
		bmi.w	.intSFX			; if no PSG channels are loaded, branch
	else
		bmi.s	.intSFX			; if no PSG channels are loaded, branch
	endif
; ---------------------------------------------------------------------------
; The reason why we delay PSG by 1 extra frame, is because of Dual PCM.
; It adds a delay of 1 frame to DAC and FM due to the YMCue, and PCM
; buffering to avoid quality loss from DMA's. This means that, since PSG
; is controlled by the 68000, we would be off by a single frame without
; this fix.
; ---------------------------------------------------------------------------

		moveq	#2,d5			; prepare duration of 1 frames to d5
		lea	dPSGtypeVals(pc),a2	; prepare PSG type value list into a2
		lea	mPSG1.w,a1		; start from PSG1 channel

.loopPSG
		move.b	d2,(a1)			; save channel flags
		move.b	(a2)+,cType(a1)		; load channel type from list
		move.b	d4,cTick(a1)		; set channel tick multiplier
		move.b	d6,cStack(a1)		; reset channel stack pointer
		move.b	d5,cDuration(a1)	; reset channel duration

		moveq	#0,d0
		move.w	(a4)+,d0		; load tracker offset to d0
		add.l	a3,d0			; add music header offset to d0
		move.l	d0,cData(a1)		; save as the tracker address of the channel
	if safe=1
		AMPS_Debug_PlayTrackMus2 PSG	; make sure the tracker address is valid
	endif

		move.w	(a4)+,cPitch(a1)	; load pitch offset and channel volume
		move.b	(a4)+,cDetune(a1)	; load detune offset
		move.b	(a4)+,cVolEnv(a1)	; load volume envelope ID
		adda.w	d6,a1			; go to the next channel
		dbf	d7,.loopPSG		; repeat for all FM channels
; ---------------------------------------------------------------------------
; Unlike SMPS, AMPS does not have pointer to the voice table of
; a song. This may be limiting for some songs, but this allows AMPS
; to save 2 bytes for each music and sound effect file. This line
; of code sets the music voice table address at the end of the header.
; ---------------------------------------------------------------------------

.intSFX
		move.l	a4,mVctMus.w		; set voice table address to a4
; ---------------------------------------------------------------------------
; Now follows initializing FM6 to be ready for PCM streaming,
; and resetting the PCM filter for Dual PCM. Simply, this just
; clears some YM registers.
; ---------------------------------------------------------------------------

		moveq	#$28,d0			; YM address: Key on/off
		moveq	#6,d1			; FM6, all operators off
		jsr	WriteYM_Pt1(pc)		; write to part 2 channel

		moveq	#$7F,d1			; set total level to $7F (silent)
		moveq	#$42,d0			; YM address: Total Level Operator 1 (FM3/6)
		jsr	WriteYM_Pt2(pc)		; write to part 2 channel
		moveq	#$4A,d0			; YM address: Total Level Operator 2 (FM3/6)
		jsr	WriteYM_Pt2(pc)		; write to part 2 channel
		moveq	#$46,d0			; YM address: Total Level Operator 3 (FM3/6)
		jsr	WriteYM_Pt2(pc)		; write to part 2 channel
		moveq	#$4E,d0			; YM address: Total Level Operator 4 (FM3/6)
		jsr	WriteYM_Pt2(pc)		; write to part 2 channel

		moveq	#$FFFFFFC0,d1		; set panning to centre
		moveq	#$FFFFFFB4+2,d0		; YM address: Panning and LFO (FM3/6)
		jsr	WriteYM_Pt2(pc)		; write to part 2 channel

		move.w	#fLog>>$0F,d0		; use linear filter
		jsr	dSetFilter(pc)		; set filter
; ---------------------------------------------------------------------------
; This piece of code here handles SFX overriding our newly loaded
; music channels. Since we did not do this at the initialization
; step, we will handle it here instead.
; ---------------------------------------------------------------------------

		lea	dSFXoverList(pc),a2	; load quick reference to the SFX override list
		lea	mSFXDAC1.w,a1		; start from SFX DAC1 channel
		moveq	#SFX_Ch-1,d7		; prepare total number of SFX channels into d7
		moveq	#cSizeSFX,d6		; prepare SFX channel size to d6

.loopSFX
		tst.b	(a1)			; check if SFX channel is running a tracker
		bpl.s	.nextSFX		; if not, skip this channel

		moveq	#0,d0
		move.b	cType(a1),d0		; load SFX channel type to d0
		bmi.s	.SFXPSG			; if negative, it is a PSG channel

		and.w	#$07,d0			; get only the necessary bits to d3
		subq.w	#2,d0			; since FM 1 and 2 are not used, skip over them
		add.w	d0,d0			; double offset (each entry is 1 word in size)
		bra.s	.override
; ---------------------------------------------------------------------------

.SFXPSG
		lsr.b	#4,d0			; make it easier to reference the right offset in the table
.override
		move.w	(a2,d0.w),a3		; get music channel RAM address to a3
		bset	#cfbInt,(a3)		; set as interrupted

.nextSFX
		adda.w	d6,a1			; go to the next channel
		dbf	d7,.loopSFX		; repeat for all SFX channels
; ---------------------------------------------------------------------------
; Here we mute all non-interrupted FM and PSG channels
; ---------------------------------------------------------------------------

		lea	mFM1.w,a5		; start from FM1 channel
		moveq	#Mus_FM-1,d4		; prepare total number of FM channels into d7
.stopFM
		jsr	dKeyOffFM(pc)		; send key off even if not interrupted
		adda.w	d6,a5			; go to the next channel
		dbf	d4,.stopFM		; repeat for all FM channels

		moveq	#Mus_PSG-1,d4		; start from PSG1 channel
.mutePSG
		jsr	dMutePSGmus(pc)		; mute PSG channel if not interrupted
		adda.w	d6,a5			; go to the next channel
		dbf	d4,.mutePSG		; repeat for all FM channels
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Type values for different channels. Used for playing music
; ---------------------------------------------------------------------------
dDACtypeVals:	dc.b ctDAC1, ctDAC2
dFMtypeVals:	dc.b ctFM1, ctFM2, ctFM3, ctFM4, ctFM5
dPSGtypeVals:	dc.b ctPSG1, ctPSG2, ctPSG3
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to play a queued sound effect
; ---------------------------------------------------------------------------

dPlaySnd_SFX:
; ---------------------------------------------------------------------------
; This is a little special case with Sonic 1 - 3K, where the ring
; sound effect would change panning each time it is played. AMPS
; emulates this behavior like the original drivers did, by
; playing a different sound effect ID.
; ---------------------------------------------------------------------------

		cmpi.b	#sfx_RingRight,d7	; check if the sound effect was the ring sound effect
		bne.s	.noring			; if not, skip
		bchg	#mfbRing,mFlags.w	; swap flag and check if it was set
		beq.s	.noring			; if was not, do not change sound effect
		moveq	#sfx_RingLeft,d7	; switch to left panned sound effect instead
; ---------------------------------------------------------------------------
; To save few cycles, we don't directly substract the SFX offset from
; the ID, and instead offset the table position. In practice this will
; have the same effect, but saves us 8 cycles overall.
; ---------------------------------------------------------------------------

.noring
		lea	SoundIndex-(SFXoff*4)(pc),a1; get sfx pointer table with an offset to a4
		move.b	d7,d1			; copy sfx ID to d1 (used later)
		add.w	d7,d7			; quadruple sfx ID
		add.w	d7,d7			; since each entry is 4 bytes in size
		movea.l	(a1,d7.w),a4		; get SFX header pointer from the table

	if safe=1
		move.l	a4,d0			; copy pointer to d0
		and.l	#$FFFFFF,d0		; clearing the upper 8 bits allows the debugger
		move.l	d0,a4			; to show the address correctly. Move ptr back to a4
		AMPS_Debug_PlayTrackSFX		; check if this was valid sound effect
	endif
; ---------------------------------------------------------------------------
; Continous SFX is a very special type of sound effect. Unlike other
; sound effects, when a continous SFX is played, it will run a loop
; again, until it is no longer queued. This is very useful for sound
; effects that need to be queued very often, but that really do not
; sound good when restarted (plus, it requires more CPU time, anyway).
; Even the Marble Zone block pushing sound effect had similar behavior,
; but the code was not quite as matured as this here. Only one continous
; SFX may be running at once, when other type is loaded, the earlier one
; is stopped and replaced.
; ---------------------------------------------------------------------------

		tst.b	(a1,d7.w)		; check if this sound effect is continously looping
		bpl.s	.nocont			; if not, skip
		move.b	1(a4),mContCtr.w	; copy the number of channels as the new continous loop counter
		cmp.b	mContLast.w,d1		; check if the last continous SFX had the same ID
		bne.s	.setcont		; if not, play as a new sound effect anyway
		rts

.setcont
		move.b	d1,mContLast.w		; save new continous SFX ID
.nocont
		movea.l	a4,a1			; copy tracker header pointer to a1

		moveq	#0,d7
		lea	dSFXoverList(pc),a3	; load quick reference to the SFX override list to a3
		lea	dSFXoffList(pc),a2	; load quick reference to the SFX channel list to a2
		move.b	(a1)+,d5		; load sound effect priority to d5
		move.b	(a1)+,d7		; load number of SFX channels to d7
		moveq	#cSizeSFX,d6		; prepare SFX channel size to d6
; ---------------------------------------------------------------------------
; The reason why we delay PSG by 1 extra frame, is because of Dual PCM.
; It adds a delay of 1 frame to DAC and FM due to the YMCue, and PCM
; buffering to avoid quality loss from DMA's. This means that, since PSG
; is controlled by the 68000, we would be off by a single frame without
; this fix.
; ---------------------------------------------------------------------------

.loopSFX
		moveq	#0,d3
		moveq	#2,d2			; prepare duration of 1 frames to d2
		move.b	1(a1),d3		; load sound effect channel type to d3
		move.b	d3,d4			; copy type to d4
		bmi.s	.chPSG			; if channel is a PSG channel, branch

		and.w	#$07,d3			; get only the necessary bits to d3
		subq.w	#2,d3			; since FM 1 and 2 are not used, skip over them
		add.w	d3,d3			; double offset (each entry is 1 word in size)

		move.w	(a2,d3.w),a5		; get the SFX channel we are trying to load to
		cmp.b	cPrio(a5),d5		; check if this sound effect has higher priority
		blo.s	.skip			; if not, we can not override it

		move.w	(a3,d3.w),a6		; get the music channel we should override
		bset	#cfbInt,(a6)		; override music channel with sound effect
		moveq	#1,d2			; prepare duration of 0 frames to d2
		bra.s	.clearCh
; ---------------------------------------------------------------------------

.skip
		addq.l	#6,a1			; skip this sound effect channel
		dbf	d7,.loopSFX		; repeat for each requested channel
		rts
; ---------------------------------------------------------------------------

.chPSG
		lsr.w	#4,d3			; make it easier to reference the right offset in the table
		move.w	(a2,d3.w),a5		; get the SFX channel we are trying to load to
		cmp.b	cPrio(a5),d5		; check if this sound effect has higher priority
		blo.s	.skip			; if not, we can not override it

		move.w	(a3,d3.w),a6		; get the music channel we should override
		bset	#cfbInt,(a6)		; override music channel with sound effect
		ori.b	#$1F,d4			; add volume update and max volume to channel type
		move.b	d4,dPSG			; send volume mute command to PSG

		cmpi.b	#ctPSG3|$1F,d4		; check if we sent command about PSG3
		bne.s	.clearCh		; if not, skip
		move.b	#ctPSG4|$1F,dPSG	; send volume mute command for PSG4 to PSG

.clearCh
		move.w	a5,a6			; copy sound effect channel RAM pointer to a6
		moveq	#cSizeSFX/4-1,d0	; prepare SFX channel size / 4 to d0
.clear
		clr.l	(a6)+			; clear 4 bytes of channel data
		dbf	d0,.clear		; clear the entire channel

	if cSizeSFX&2
		clr.w	(a6)			; if channel size can not be divided by 4, clear extra word
	endif

		move.w	(a1)+,(a5)		; load channel flags and type
		move.b	d5,cPrio(a5)		; set channel priority
		move.b	d2,cDuration(a5)	; reset channel duration

		moveq	#0,d0
		move.w	(a1)+,d0		; load tracker offset to d0
		add.l	a4,d0			; add music header offset to d0
		move.l	d0,cData(a5)		; save as the tracker address of the channel
	if safe=1
		AMPS_Debug_PlayTrackSFX2	; make sure the tracker address is valid
	endif

		move.w	(a1)+,cPitch(a5)	; load pitch offset and channel volume
		tst.b	d4			; check if this channel is a PSG channel
		bmi.s	.loop			; if is, skip over this

		moveq	#$FFFFFFC0,d1		; set panning to centre
		move.b	d1,cPanning(a5)		; save to channel memory too
		moveq	#$FFFFFFB4,d0		; YM address: Panning and LFO
		jsr	WriteChYM(pc)		; write to part 2 channel

		cmp.w	#mSFXDAC1,a5		; check if this channel is a DAC channel
		bne.s	.fm			; if not, branch
		move.w	#$100,cFreq(a5)		; DAC default frequency is $100, NOT $000

.loop
		dbf	d7,.loopSFX		; repeat for each requested channel
		rts
; ---------------------------------------------------------------------------
; The instant release for FM channels behavior was not in the Sonic 1
; SMPS driver by default, but it has been added since it fixes an
; issue with YM2612, where sometimes subsequent sound effect activations
; would sound different over time. This fix will help to mitigate that.
; ---------------------------------------------------------------------------

.fm
		moveq	#$F,d1			; set to release note instantly
		moveq	#$FFFFFF80,d0		; YM address: Release Rate Operator 1
		jsr	WriteChYM(pc)		; write to YM according to channel
		moveq	#$FFFFFF88,d0		; YM address: Release Rate Operator 3
		jsr	WriteChYM(pc)		; write to YM according to channel
		moveq	#$FFFFFF84,d0		; YM address: Release Rate Operator 2
		jsr	WriteChYM(pc)		; write to YM according to channel
		moveq	#$FFFFFF8C,d0		; YM address: Release Rate Operator 4
		jsr	WriteChYM(pc)		; write to YM according to channel

		moveq	#$28,d0			; YM address: Key on/off
		move.b	cType(a5),d1		; FM channel, all operators off
		bsr.w	WriteYM_Pt1		; write to part 1 or 2 channel

		dbf	d7,.loopSFX		; repeat for each requested channel
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; pointers for music channels SFX can override and addresses of SFX channels
; ---------------------------------------------------------------------------

dSFXoffList:	dc.w mSFXFM3			; FM3
		dc.w mSFXDAC1			; DAC1
		dc.w mSFXFM4			; FM4
		dc.w mSFXFM5			; FM5
		dc.w mSFXPSG1			; PSG1
		dc.w mSFXPSG2			; PSG2
		dc.w mSFXPSG3			; PSG3
		dc.w mSFXPSG3			; PSG4

dSFXoverList:	dc.w mFM3			; SFX FM3
		dc.w mDAC1			; SFX DAC1
		dc.w mFM4			; SFX FM4
		dc.w mFM5			; SFX FM5
		dc.w mPSG1			; SFX PSG1
		dc.w mPSG2			; SFX PSG2
		dc.w mPSG3			; SFX PSG3
		dc.w mPSG3			; SFX PSG4
; ===========================================================================
; ---------------------------------------------------------------------------
; Play queued command
; ---------------------------------------------------------------------------

dPlaySnd_Comm:
	if safe=1
		AMPS_Debug_PlayCmd		; check if the command is valid
	endif

		add.w	d7,d7			; quadruple ID
		add.w	d7,d7			; because each entry is 1 long word
		jmp	dSoundCommands-4(pc,d7.w); jump to appropriate command handler

; ---------------------------------------------------------------------------
dSoundCommands:
		bra.w	dPlaySnd_Reset		; 01 - Reset underwater and speed shoes flags, update volume
		bra.w	dPlaySnd_FadeOut	; 02 - Initialize a music fade out
		bra.w	dPlaySnd_Stop		; 03 - Stop all music
		bra.w	dPlaySnd_ShoesOn	; 04 - Enable speed shoes mode
		bra.w	dPlaySnd_ShoesOff	; 05 - Disable speed shoes mode
		bra.w	dPlaySnd_ToWater	; 06 - Enable underwater mode
		bra.w	dPlaySnd_OutWater	; 07 - Disable underwater mode
		bra.w	dPlaySnd_Pause		; 08 - Pause the sound driver
		bra.w	dPlaySnd_Unpause	; 09 - Unpause the sound driver
dSoundCommands_End:
; ===========================================================================
; ---------------------------------------------------------------------------
; Commands for what to do after a volume fade
; ---------------------------------------------------------------------------

dFadeCommands:
		rts				; 80 - Do nothing
		rts
.stop		bra.s	dPlaySnd_Stop		; 84 - Stop all music
		rts
.resv		bra.w	dResetVolume		; 88 - Reset volume and update
		bsr.s	.resv			; 8C - Stop music playing and reset volume
		bra.s	.stop
; ===========================================================================
; ---------------------------------------------------------------------------
; Stop music and SFX from playing (This code clears SFX RAM also)
; ---------------------------------------------------------------------------

dPlaySnd_Stop:
; Not needed,	moveq	#$2B,d0			; YM command: DAC Enable
; Dual PCM does	moveq	#$FFFFFF80,d1		; FM6 acts as DAC
; this for us	jsr	WriteYM_Pt1(pc)		; write to YM global register

		moveq	#$27,d0			; YM command: Channel 3 Mode & Timer Control
		moveq	#0,d1			; disable timers and channel 3 special mode
		jsr	WriteYM_Pt1(pc)		; write to YM global register

		lea	mSFXDAC1.w,a1		; prepare SFX DAC 1 to start clearing fromn

	rept (mSize-mSFXDAC1)/4
		clr.l	(a1)+			; clear entire SFX RAM (others done below)
	endr

	if (mSize-mSFXDAC1)&2
		clr.w	(a1)			; if there is an extra word, clear it too
	endif
	; continue straight to stopping music
; ===========================================================================
; ---------------------------------------------------------------------------
; Stop music from playing, reset driver memory and mute hardware
; ---------------------------------------------------------------------------

dStopMusic:
		lea	mFlags.w,a1		; load driver RAM start to a1
		move.w	(a1),d3			; load driver flags and PAL counter to d3
		move.b	mMasterVolDAC.w,d4	; load DAC master volume to d4
		move.l	mQueue.w,d5		; load sound queue and PSG master volume to d5
		movem.l	mComm.w,d0-d2		; load communications bytes, FM master volume and fade address to d0-d2

	rept (mSFXDAC1-mFlags)/4
		clr.l	(a1)+			; clear driver and music channel memory
	endr

	if (mSFXDAC1-mFlags)&2
		clr.w	(a1)			; if there is an extra word, clear it too
	endif

		move.w	d3,mFlags.w		; save driver flags and PAL counter
		move.b	d4,mMasterVolDAC.w	; save DAC master volume
		move.l	d5,mQueue.w		; save sound queue and PSG master volume
		movem.l	d0-d2,mComm.w		; save communications bytes, FM master volume and fade address

		bsr.s	dMutePSG		; hardware mute PSG
		jsr	dMuteDAC(pc)		; hardware mute DAC
	; continue straight to hardware muting FM
; ===========================================================================
; ---------------------------------------------------------------------------
; Mute all FM channels
; ---------------------------------------------------------------------------

dMuteFM:
		moveq	#$28,d0			; YM address: Key on/off
		moveq	#%00000010,d3		; turn keys off, and start from YM channel 3

.noteoff
		move.b	d3,d1			; copy value into d1
		jsr	WriteYM_Pt1(pc)		; write to part 1 channel
		addq.b	#4,d1			; set this to part 2 channel
		jsr	WriteYM_Pt1(pc)		; write to part 2 channel
		dbf	d3,.noteoff		; loop for all 3 channel groups

		moveq	#$40,d0			; YM command: Total Level Operator 1
		moveq	#$7F,d1			; set total level to $7F (silent)
		moveq	#3-1,d4			; prepare 3 groups of channels to d4

.chloop
		moveq	#4-1,d3			; prepare 4 operator writes per channel to d3
		moveq	#$10-1,d5		; prepare the value for going to next channel to d5

.oploop
		jsr	WriteYM_Pt1(pc)		; write to part 1 channel
		jsr	WriteYM_Pt2(pc)		; write to part 2 channel
		addq.w	#4,d0			; go to next operator (1 2 3 4)
		dbf	d3,.oploop		; repeat for each operator

		sub.b	d5,d0			; go to next FM channel
		dbf	d4,.chloop		; repeat for each channel
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for muting all PSG channels
; ---------------------------------------------------------------------------

dMutePSG:
		lea	dPSG,a1			; load PSG data port address to a1
		move.b	#ctPSG1|$1F,(a1)	; send volume mute command for PSG1 to PSG
		move.b	#ctPSG2|$1F,(a1)	; send volume mute command for PSG2 to PSG
		move.b	#ctPSG3|$1F,(a1)	; send volume mute command for PSG3 to PSG
		move.b	#ctPSG4|$1F,(a1)	; send volume mute command for PSG4 to PSG
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Normal fade out data
; ---------------------------------------------------------------------------

dFadeOutDataLog:
	dc.b $01, $01, $00,  $02, $02, $00,  $02, $04, $01,  $03, $05, $01
	dc.b $04, $05, $01,  $04, $06, $02,  $05, $07, $02,  $06, $08, $02
	dc.b $07, $09, $03,  $09, $0B, $03,  $0A, $0C, $03,  $0C, $0E, $03
	dc.b $0E, $10, $04,  $10, $11, $04,  $11, $13, $04,  $14, $15, $05
	dc.b $16, $18, $05,  $1A, $1C, $05,  $1C, $1F, $06,  $20, $24, $06
	dc.b $22, $28, $07,  $26, $2E, $07,  $2C, $34, $08,  $30, $39, $08
	dc.b $34, $3E, $09,  $3C, $44, $0A,  $40, $4C, $0A,  $46, $54, $0B
	dc.b $4C, $5A, $0C,  $54, $62, $0D,  $5C, $6B, $0D,  $60, $76, $0E
	dc.b $6C, $7C, $0E,  $74, $7F, $0F,  $7F, $7F, $0F,  fReset

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
		move.b	d0,mMasterVolFM.w	; save new FM master volume
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
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for resetting master volumes, filters and disabling fading
; ---------------------------------------------------------------------------

dResetVolume:
		clr.l	mFadeAddr.w		; stop fading program and reset FM master volume
		clr.b	mMasterVolPSG.w		; reset PSG master volume
		clr.b	mMasterVolDAC.w		; reset DAC master volume
		move.w	#fLog>>$0F,d0		; load value for linear filter
		bsr.s	dSetFilter		; load filter instructions

dUpdateVolumeAll:
		bsr.s	dReqVolUpFM		; request FM volume update
		or.b	d0,mSFXDAC1.w		; request update for SFX DAC1 channel

.ch =	mDAC1					; start at DAC1
	rept Mus_DAC				; loop through all music DAC channels
		or.b	d0,.ch.w		; request channel volume update
.ch =		.ch+cSize			; go to next channel
	endr

.ch =	mPSG1					; start at PSG1
	rept Mus_PSG				; loop through all music PSG channels
		or.b	d0,.ch.w		; request channel volume update
.ch =		.ch+cSize			; go to next channel
	endr

.ch =	mSFXPSG1				; start at SFX PSG1
	rept SFX_PSG				; loop through all SFX PSG channels
		or.b	d0,.ch.w		; request channel volume update
.ch =		.ch+cSizeSFX			; go to next channel
	endr
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Enable speed shoes mode
; ---------------------------------------------------------------------------

dPlaySnd_ShoesOn:
		move.b	mTempoSpeed.w,mTempoCur.w; set tempo accumulator/counter to speed shoes one
		move.b	mTempoSpeed.w,mTempo.w	; set main tempor to speed shoes one
		bset	#mfbSpeed,mFlags.w	; enable speed shoes flag
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Reset music flags (underwater mode and tempo mode)
; ---------------------------------------------------------------------------

dPlaySnd_Reset:
		bsr.s	dPlaySnd_OutWater	; gp reset underwater flag and request volume update
; ===========================================================================
; ---------------------------------------------------------------------------
; Disable speed shoes mode
; ---------------------------------------------------------------------------

dPlaySnd_ShoesOff:
		move.b	mTempoMain.w,mTempoCur.w; set tempo accumulator/counter to normal one
		move.b	mTempoMain.w,mTempo.w	; set main tempor to normal one
		bclr	#mfbSpeed,mFlags.w	; disable speed shoes flag
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Enable Underwater mode
; ---------------------------------------------------------------------------

dPlaySnd_ToWater:
		bset	#mfbWater,mFlags.w	; enable underwater mode
		bra.s	dReqVolUpFM		; request FM volume update
; ===========================================================================
; ---------------------------------------------------------------------------
; Disable Underwater mode
; ---------------------------------------------------------------------------

dPlaySnd_OutWater:
		bclr	#mfbWater,mFlags.w	; disable underwater mode
; ===========================================================================
; ---------------------------------------------------------------------------
; force volume update on all FM channels
; ---------------------------------------------------------------------------

dReqVolUpFM;
		moveq	#1<<cfbVol,d0		; prepare volume update flag to d0
.ch =	mFM1					; start at FM1
	rept Mus_FM				; loop through all music FM channels
		or.b	d0,.ch.w		; request channel volume update
.ch =		.ch+cSize			; go to next channel
	endr

.ch =	mSFXFM3					; start at SFX FM3
	rept SFX_FM				; loop through all SFX FM channels
		or.b	d0,.ch.w		; request channel volume update
.ch =		.ch+cSizeSFX			; go to next channel
	endr
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine for updating Total Levels for FM channel
; ---------------------------------------------------------------------------

dUpdateVolFM:
		btst	#cfbInt,(a5)		; is the channel interrupted by SFX?
		bne.s	locret_VolFM		; if yes, do not update

		move.b	cVolume(a5),d3		; load FM channel volume to d3
		add.b	mMasterVolFM.w,d3	; add master FM volume to d3
		bpl.s	.noover			; if volume did not overflow, skio
		moveq	#$7F,d3			; force FM volume to silence

.noover
		moveq	#0,d0
		move.b	cVoice(a5),d0		; load FM voice ID of the channel to d0
		move.l	a6,a1			; copy music voice table address to a1

	dCALC_VOICE				; get address of the specific voice to a1
		move.b	(a1),d0			; load algorithm and feedback to d0
		moveq	#0,d6			; reset the modulator offset

		btst	#mfbWater,mFlags.w	; check if underwater mode is enabled
		beq.s	.uwdone			; if not, skip
		move.b	d0,d6			; copy algorithm and feedback to d6
		and.w	#7,d6			; mask out everything but the algorithm
		add.b	d6,d3			; add algorithm to Total Level carrier offset
		move.b	d0,d6			; set algorithm and feedback to modulator offset

.uwdone
		moveq	#4-1,d5			; prepare 4 operators to d5
		add.w	#VoiceTL,a1		; go to the Total Level offset of the voice
		lea	dOpTLFM(pc),a2		; load Total Level address table to a3

.tlloop
		move.b	(a2)+,d0		; load YM address to write to
		move.b	(a1)+,d1		; get Total Level value from voice to d1
		bpl.s	.noslot			; if slot operator bit was not set, branch

		add.b	d3,d1			; add carrier offset to loaded value
		bmi.s	.slot			; if we did not overflow, branch
		moveq	#$7F,d1			; cap to silent volume
		bra.s	.slot

.noslot
		add.b	d6,d1			; add modulator offset to loaded value
.slot
		jsr	WriteChYM(pc)		; write Total Level to YM according to channel
.ignore
		dbf	d5,.tlloop		; repeat for each Total Level operator

	if safe=1
		AMPS_Debug_UpdVolFM		; check if the voice was valid
	endif

locret_VolFM:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; YM2612 register update list
; ---------------------------------------------------------------------------

dOpListYM:	dc.b $30, $38, $34, $3C		; Detune, Multiple
		dc.b $50, $58, $54, $5C		; Rate Scale, Attack Rate
dAMSEn_Ops:	dc.b $60, $68, $64, $6C		; Decay 1 Rate
		dc.b $70, $78, $74, $7C		; Decay 2 Rate
		dc.b $80, $88, $84, $8C		; Decay 1 level, Release Rate
		dc.b $90, $98, $94, $9C		; SSG-EG
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
	dModulate dAMPSdoPSGSFX, dAMPSnextFMSFX, 1; run modulation code
		bsr.w	dUpdateFreqFM3		; send FM frequency to hardware

		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.next			; if not, skip
		jsr	dUpdateVolFM(pc)	; update FM volume

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

		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.noupdate		; if not, branch
		jsr	dUpdateVolFM(pc)	; update FM volume

.noupdate	dbf	d7,dAMPSnextFMSFX	; make sure to run all the channels
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
	dModulate dAMPSdoPSG, dAMPSnextFM, 0	; run modulation code
		bsr.w	dUpdateFreqFM2		; send FM frequency to hardware

		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.next			; if not, skip
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

		bclr	#cfbVol,(a5)		; check if volume update is needed and clear bit
		beq.s	.noupdate		; if not, branch
		jsr	dUpdateVolFM(pc)	; update FM volume

.noupdate
		dbf	d7,dAMPSnextFM		; make sure to run all the channels
		jmp	dAMPSdoPSG(pc)		; after that, process music PSG channels
; ===========================================================================
; ---------------------------------------------------------------------------
; Write FM frequency to Dual PCM YMCue
; ---------------------------------------------------------------------------

dUpdateFreqFM:
		btst	#cfbRest,(a5)		; is this channel resting
		bne.s	locret_UpdFreqFM	; if is, skip
		move.w	cFreq(a5),d6		; load channel base frequency to d6
		beq.s	dUpdFreqFMrest		; if 0, this channel should be resting

		move.b	cDetune(a5),d0		; load detune value to d0
		ext.w	d0			; extend to word
		add.w	d0,d6			; add to channel base frequency to d6

		btst	#cfbMod,(a5)		; check if channel is modulating
		beq.s	dUpdateFreqFM2		; if not, branch
		add.w	cModFreq(a5),d6		; add channel modulation frequency offset to d6

dUpdateFreqFM2:
		btst	#cfbInt,(a5)		; is the channel interrupted by SFX?
		bne.s	locret_UpdFreqFM	; if is, do not update frequency anyway

dUpdateFreqFM3:
		move.w	d6,d1			; copy frequency to d1
		lsr.w	#8,d1			; shift upper byte into lower byte
		moveq	#$FFFFFFA4,d0		; YM command: Frequency MSB & Octave
		jsr	WriteChYM(pc)		; write to YM according to channel

		move.b	d6,d1			; copy lower byte of frequency into d1 (value)
		move.b	#$FFFFFFA0,d0		; YM command: Frequency LSB
		jmp	WriteChYM(pc)		; write to YM according to channel

dUpdFreqFMrest:
		bset	#cfbRest,(a5)		; set channel resting flag

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

		moveq	#$28,d0			; YM command: Key on
		move.b	cType(a5),d1		; get channel type bits (and turn all operators off)
		bra.s	WriteYM_Pt1		; write to part 1 channel
; ===========================================================================
; ---------------------------------------------------------------------------
; Write to YMCue according to channel and check if interrupted by sfx
; ---------------------------------------------------------------------------

dWriteYMchnInt:
		btst	#cfbInt,(a5)		; check if interrupted by sfx
		bne.s	WriteYM_Pt1_rts		; if was, do not note on
; ===========================================================================
; ---------------------------------------------------------------------------
; Write to YMCue according to channel
; ---------------------------------------------------------------------------

WriteChYM:
		btst	#ctbPt2,cType(a5)	; check if this is a YM part 1 or 2 channel
		bne.s	WriteChYM2		; if part 2, branch
		add.b	cType(a5),d0		; add channel type to address
; ===========================================================================
; ---------------------------------------------------------------------------
; Write to YMCue using part 1
; ---------------------------------------------------------------------------

WriteYM_Pt1:
	if safe=1
		AMPS_Debug_CuePtr 1		; check if cue pointer is valid
	endif
	StopZ80					; wait for Z80 to stop
		sf	(a0)+			; set YM port address as 0
		move.b	d1,(a0)+		; write data value to cue
		move.b	d0,(a0)+		; write address to cue
	;	st	(a0)			; mark as the end of the cue data
	StartZ80				; enable Z80 execution

WriteYM_Pt1_rts:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Write to YMCue according to channel in part 2
; ---------------------------------------------------------------------------

WriteChYM2:
		move.b	cType(a5),d2		; get channel type to d2
		bclr	#ctbPt2,d2		; remove part 2 marker from it
		add.b	d2,d0			; add to YM address
; ===========================================================================
; ---------------------------------------------------------------------------
; Write to YMCue using part 2
; ---------------------------------------------------------------------------

WriteYM_Pt2:
	if safe=1
		AMPS_Debug_CuePtr 2		; check if cue pointer is valid
	endif
	StopZ80					; wait for Z80 to stop
		move.b	#$02,(a0)+		; set YM port address as 2
		move.b	d1,(a0)+		; write data value to cue
		move.b	d0,(a0)+		; write address to cue
	;	st	(a0)			; mark as the end of the cue data
	StartZ80				; enable Z80 execution
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
	dc.w $3284,$32AB,$32D3,$32FE,$332D,$335C,$338F,$33C5,$33FF,$343C,$347C,$3A5E; Octave 6 - (c9 - D4)
	dc.w $3A84,$3AAB,$3AD3,$3AFE,$3B2D,$3B5C,$3B8F,$3BC5,$3BFF,$3C3C,$3C7C	    ; Octave 7 - (D5 - DF)
dFreqFM_:
	if safe=1				; in safe mode, we have extra debug data
.x = $100|((dFreqFM_-dFreqFM)/2)		; to check if we played an invalid note
		rept $80-((dFreqFM_-dFreqFM)/2)	; and if so, tell us which note it was
			dc.w .x
.x =			.x+$101
		endr
	endif
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
		bpl.s	.next			; if not, branch
		subq.b	#1,cDuration(a5)	; decrease note duration
		beq.w	.update			; if timed out, update channel

	dCalcFreq				; calculate channel base frequency
	dModulate				; run modulation code
		bsr.w	dUpdateFreqPSG3		; if frequency needs changing, do it

.endm
		bsr.w	dEnvelopePSG		; run envelope program
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
		bsr.w	dEnvProgPSG		; run envelope program
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
	dModulate				; run modulation code
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
		bsr.w	dEnvProgPSG		; run envelope program
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

		btst	#cfbMod,(a5)		; check if channel is modulating
		beq.s	dUpdateFreqPSG2		; if not, branch
		add.w	cModFreq(a5),d6		; add modulation frequency offset to d6

dUpdateFreqPSG2:
		btst	#cfbInt,(a5)		; is channel interrupted by sfx?
		bne.s	locret_dUpdateFreqPSG	; if so, skip

dUpdateFreqPSG3:
		btst	#cfbRest,(a5)		; is this channel resting
		bne.s	locret_dUpdateFreqPSG	; if so, skip

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
; but will also make the instashield SFX not sound correct.
; Comment out the instruction with caution, if you are planning
; to port said sound effect to this driver. This has not caused
; any issues for me, and if you are careful you can avoid any
; such case, but beware of this issue!
; ---------------------------------------------------------------------------

		lsr.w	#4,d6			; get the 2 higher nibbles of frequency
		andi.b	#$3F,d6			; clear any extra bits that aren't valid
		move.b	d0,dPSG			; write frequency low nibble and latch channel
		move.b	d6,dPSG			; write frequency high nibbles to PSG

locret_dUpdateFreqPSG:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for running envelope programs
; ---------------------------------------------------------------------------

dEnvProgPSG:
		move.b	cVolume(a5),d5		; load channel volume to d5
		add.b	mMasterVolPSG.w,d5	; add PSG master volume to d5

		moveq	#0,d4
		move.b	cVolEnv(a5),d4		; load volume envelope ID to d4
		beq.s	dUpdateVolPSG2		; if 0, update volume only
		bra.s	dEnvProgPSG2		; continue to run code below

dEnvelopePSG:
		moveq	#0,d4
		move.b	cVolEnv(a5),d4		; load volume envelope ID to d4
		beq.s	locret_UpdVolPSG	; if 0, return

		move.b	cVolume(a5),d5		; load channel volume to d5
		add.b	mMasterVolPSG.w,d5	; add PSG master volume to d5

dEnvProgPSG2:
	if safe=1
		AMPS_Debug_VolEnvID		; check if volume envelope ID is valid
	endif

		lea	VolEnvs-4(pc),a1	; load volume envelope data array
		add.w	d4,d4			; quadruple volume envelope ID
		add.w	d4,d4			; (each entry is 4 bytes in size)
		move.l	(a1,d4.w),a1		; get pointer to volume envelope data

		moveq	#0,d1
		moveq	#0,d0

dEnvProgPSG3:
		move.b	cEnvPos(a5),d1		; get envelope position to d1
		move.b	(a1,d1.w),d0		; get the date in that position
		bmi.s	dEnvCommand		; if it is a command, handle it

		addq.b	#1,cEnvPos(a5)		; increment envelope position
		add.b	d0,d5			; add envelope volume to d5
	; continue to update PSG volume
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for updating PSG volume to hardware
; ---------------------------------------------------------------------------

dUpdateVolPSG2:
		cmpi.b	#$F,d5			; check if volume is out of range
		bls.s	dUpdateVolPSG		; if not, branch
		moveq	#$F,d5			; cap volume to silent

dUpdateVolPSG:
		btst	#cfbRest,(a5)		; is this channel resting
		bne.s	locret_UpdVolPSG	; if is, do not update
		btst	#cfbInt,(a5)		; is channel interrupted by sfx?
		bne.s	locret_UpdVolPSG	; if is, do not update

		btst	#cfbHold,(a5)		; check if note is held
		beq.s	dUpdVolPSGset		; if not, update volume
		cmp.w	#mSFXDAC1,a5		; check if this is a SFX channel
		bhs.s	dUpdVolPSGset		; if so, update volume

		tst.b	cNoteTimeMain(a5)	; check if note timeout is active
		beq.s	dUpdVolPSGset		; if not, update volume
		tst.b	cNoteTimeCur(a5)	; is note stopped already?
		beq.s	locret_UpdVolPSG	; if is, do not update

dUpdVolPSGset:
		or.b	cType(a5),d5		; combine channel type value with volume
		addi.b	#$10,d5			; set volume update bit
		move.b	d5,dPSG			; write volume command to PSG port

locret_UpdVolPSG:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine for handling volume envelope commands
; ---------------------------------------------------------------------------

dEnvCommand:
	if safe=1
		AMPS_Debug_VolEnvCmd		; check if command is valid
	endif

		jmp	.comm-$80(pc,d0.w)	; jump to command handler

.comm
		bra.s	.reset			; 80 - Loop back to beginning
		bra.s	.hold			; 82 - Hold the envelope at current level
		bra.s	.loop			; 84 - Go to position defined by the next byte
	;	bra.s	.stop			; 86 - Stop current note and envelope
; ---------------------------------------------------------------------------

.stop
		bset	#cfbRest,(a5)		; set channel resting bit
		bra.s	dMutePSGmus		; nute the channel
; ---------------------------------------------------------------------------

.hold
		subq.b	#1,cEnvPos(a5)		; decrease envelope position
		jmp	dEnvProgPSG3(pc)	; run the program again (make sure volume fades work)
; ---------------------------------------------------------------------------

.reset
		clr.b	cEnvPos(a5)		; set envelope position to 0
		jmp	dEnvProgPSG3(pc)	; run the program again
; ---------------------------------------------------------------------------

.loop
		move.b	1(a1,d1.w),cEnvPos(a5)	; set envelope position to the next byte
		jmp	dEnvProgPSG3(pc)	; run the program again
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

	dc.b "AMPS 1.0"				; not required, just here to make my life easier
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine to execute tracker commands
;
; The reason we use add.b instead of add.w, is to get rid of some bits that
; would make this kind of arbitary jumping way more complex than it needs to be.
; What do we win by doing this? Why, 8 cycles per command! Thats... Not a lot,
; but it may be helpful with speed anyway.
; ---------------------------------------------------------------------------

dCommands:
		add.b	d5,d5			; quadruple command ID
		add.b	d5,d5			; since each entry is 4 bytes large

		btst	#cfbCond,(a5)		; check if condition state
		bne.w	.falsecomm		; branch if false
		jmp	.comm-$80(pc,d5.w)	; jump to appropriate handler
; ===========================================================================
; ---------------------------------------------------------------------------
; Command handlers for normal execution
; ---------------------------------------------------------------------------

.comm
	bra.w	dcPan		; E0 - Panning, AMS, FMS (PANAFMS - PAFMS_PAN)
	bra.w	dcsDetune	; E1 - Set channel frequency displacement to xx (DETUNE_SET)
	bra.w	dcaDetune	; E2 - Add xx to channel frequency displacement (DETUNE)
	bra.w	dcsTransp	; E3 - Set channel pitch to xx (TRANSPOSE - TRNSP_SET)
	bra.w	dcaTransp	; E4 - Add xx to channel pitch (TRANSPOSE - TRNSP_ADD)
	bra.w	dcsTmulCh	; E5 - Set channel tick multiplier to xx (TICK_MULT - TMULT_CUR)
	bra.w	dcsTmul		; E6 - Set global tick multiplier to xx (TICK_MULT - TMULT_ALL)
	bra.w	dcHold		; E7 - Do not allow note on/off for next note (HOLD)
	bra.w	dcVoice		; E8 - Set Voice/voice/sample to xx (INSTRUMENT - INS_C_FM / INS_C_PSG / INS_C_DAC)
	bra.w	dcsTempoShoes	; E9 - Set music speed shoes tempo to xx (TEMPO - TEMPO_SET_SPEED)
	bra.w	dcsTempo	; EA - Set music tempo to xx (TEMPO - TEMPO_SET)
	bra.w	dcModOn		; EB - Turn on Modulation (MOD_SET - MODS_ON)
	bra.w	dcModOff	; EC - Turn off Modulation (MOD_SET - MODS_OFF)
	bra.w	dcaVolume	; ED - Add xx to channel volume (VOLUME - VOL_CN_FM / VOL_CN_PSG / VOL_CN_DAC)
	bra.w	dcsVolume	; EE - Set channel volume to xx (VOLUME - VOL_CN_ABS)
	bra.w	dcsLFO		; EF - Set LFO (SET_LFO - LFO_AMSEN)
	bra.w	dcMod68K	; F0 - Modulation (MOD_SETUP)
	bra.w	dcSampDAC	; F1 - Use sample DAC mode (DAC_MODE - DACM_SAMP)
	bra.w	dcPitchDAC	; F2 - Use pitch DAC mode (DAC_MODE - DACM_NOTE)
	bra.w	dcNoisePSG	; F3 - PSG4 mode to xx (PSG_NOISE - PNOIS_AMPS)
	bra.w	dcCont		; F4 - Do a continuous SFX loop (CONT_SFX)
	bra.w	dcStop		; F5 - End of channel (TRK_END - TEND_STD)
	bra.w	dcJump		; F6 - Jump to xxxx (GOTO)
	bra.w	dcLoop		; F7 - Loop back to zzzz yy times, xx being the loop index (LOOP)
	bra.w	dcCall		; F8 - Call pattern at xxxx, saving return point (GOSUB)
	bra.w	dcReturn	; F9 - Return (RETURN)
	bra.w	dcsComm		; FA - Set communications byte yy to xx (SET_COMM - SPECIAL)
	bra.w	dcCond		; FB - Get comms byte y, and compare zz using condition x (COMM_CONDITION)
	bra.w	dcResetCond	; FC - Reset condition (COMM_RESET)
	bra.w	dcTimeout	; FD - Stop note after xx frames (NOTE_STOP - NSTOP_NORMAL
	bra.w	dcYM		; FE - YM command (YMCMD)
				; FF - META
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine to execute tracker meta and false condition commands
; ---------------------------------------------------------------------------

.metacall
		move.b	(a4)+,d5		; get next command byte
		add.w	d5,d5			; quadruple ID
		add.w	d5,d5			; since each entry is again 4 bytes large
		jmp	.meta(pc,d5.w)		; jump to appropriate meta handler

.falsecomm
		jmp	.false-$80(pc,d5.w)	; jump to appropriate handler (false command)
; ===========================================================================
; ---------------------------------------------------------------------------
; Command handlers for meta commands
; ---------------------------------------------------------------------------

.meta
	bra.w	dcWriteDAC1	; FF 00 - Play sample xx on DAC1 (PLAY_DAC - PLAY_DAC1)
	bra.w	dcWriteDAC2	; FF 01 - Play sample xx on DAC2 (PLAY_DAC - PLAY_DAC2)
	bra.w	dcsFreq		; FF 02 - Set channel frequency to xxxx (CHFREQ_SET)
	bra.w	dcsFreqNote	; FF 03 - Set channel frequency to note xx (CHFREQ_SET - CHFREQ_NOTE)
	bra.w	dcSpRev		; FF 04 - Increment spindash rev counter (SPINDASH_REV - SDREV_INC)
	bra.w	dcSpReset	; FF 05 - Reset spindash rev counter (SPINDASH_REV - SDREV_RESET)
	bra.w	dcaTempoShoes	; FF 06 - Add xx to music speed tempo (TEMPO - TEMPO_ADD_SPEED)
	bra.w	dcaTempo	; FF 07 - Add xx to music tempo (TEMPO - TEMPO_ADD)
	bra.w	dcCondReg	; FF 08 - Get RAM table offset by y, and chk zz with cond x (COMM_CONDITION - COMM_SPEC)
	bra.w	dcSound		; FF 09 - Play another music/sfx (SND_CMD)
	bra.w	dcFreqOn	; FF 0A - Enable raw frequency mode (RAW_FREQ)
	bra.w	dcFreqOff	; FF 0B - Disable raw frequency mode (RAW_FREQ - RAW_FREQ_OFF)
	bra.w	dcSpecFM3	; FF 0C - Enable FM3 special mode (SPC_FM3)
	bra.w	dcFilter	; FF 0D - Set DAC filter bank. (DAC_FILTER)

	if safe=1
		bra.w	dcFreeze	; FF 0E - Freeze CPU. Debug flag (DEBUG_STOP_CPU)
		bra.w	dcTracker	; FF 0F - Bring up tracker debugger at end of frame. Debug flag (DEBUG_PRINT_TRACKER)
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Command handlers for false condition execution
; ---------------------------------------------------------------------------

.false
	addq.w	#1,a4
	rts			; E0 - Panning, AMS, FMS (PANAFMS - PAFMS_PAN)
	addq.w	#1,a4
	rts			; E1 - Add xx to channel frequency displacement (DETUNE)
	addq.w	#1,a4
	rts			; E2 - Add xx to channel frequency displacement (DETUNE)
	addq.w	#1,a4
	rts			; E3 - Set channel pitch to xx (TRANSPOSE - TRNSP_SET)
	addq.w	#1,a4
	rts			; E4 - Add xx to channel pitch (TRANSPOSE - TRNSP_ADD)
	bra.w	dcsTmulCh	; E5 - Set channel tick multiplier to xx (TICK_MULT - TMULT_CUR)
	bra.w	dcsTmul		; E6 - Set global tick multiplier to xx (TICK_MULT - TMULT_ALL)
	bra.w	dcHold		; E7 - Do not allow note on/off for next note (HOLD)
	addq.w	#1,a4
	rts			; E8 - Add xx to music tempo (TEMPO - TEMPO_ADD)
	addq.w	#1,a4
	rts			; E9 - Set music tempo to xx (TEMPO - TEMPO_SET)
	addq.w	#1,a4
	rts			; EA - Set Voice/voice/sample to xx (INSTRUMENT - INS_C_FM / INS_C_PSG / INS_C_DAC)
	rts
	rts			; EB - Turn on Modulation (MOD_SET - MODS_ON)
	rts
	rts			; EC - Turn off Modulation (MOD_SET - MODS_OFF)
	addq.w	#1,a4
	rts			; ED - Add xx to channel volume (VOLUME - VOL_CN_FM / VOL_CN_PSG / VOL_CN_DAC)
	addq.w	#1,a4
	rts			; EE - Set channel volume to xx (VOLUME - VOL_CN_ABS)
	addq.w	#1,a4
	rts			; EF - Set LFO (SET_LFO - LFO_AMSEN)
	addq.w	#4,a4
	rts			; F0 - Modulation (MOD_SETUP)
	rts
	rts			; F1 - Use sample DAC mode (DAC_MODE - DACM_SAMP)
	rts
	rts			; F2 - Use pitch DAC mode (DAC_MODE - DACM_NOTE)
	addq.w	#1,a4
	rts			; F3 - PSG4 mode to xx (PSG_NOISE - PNOIS_SET)
	addq.w	#2,a4
	rts			; F4 - Do a continuous SFX loop (CONT_SFX)
	rts
	rts			; F5 - End of channel (TRK_END - TEND_STD)
	addq.w	#2,a4
	rts			; F6 - Jump to xxxx (GOTO)
	addq.w	#4,a4
	rts			; F7 - Loop back to zzzz yy times, xx being the loop index (LOOP)
	addq.w	#2,a4
	rts			; F8 - Call pattern at xxxx, saving return point (GOSUB)
	rts
	rts			; F9 - Return (RETURN)
	bra.w	dcsComm		; FA - Set communications byte yy to xx (SET_COMM - SPECIAL)
	bra.w	dcCond		; FB - Get comms byte y, and compare zz using condition x (COMM_CONDITION)
	bra.w	dcResetCond	; FC - Reset condition (COND_RESET)
	addq.w	#1,a4
	rts			; FD - Stop note after xx frames (NOTE_STOP - NSTOP_NORMAL
	addq.w	#1,a4
	rts			; FE - YM command (YMCMD)
	bra.w	.metacall	; FF - META
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for writing direct DAC samples to Dual PCM.
; Note that this will override any DAC already being played,
; and in turn trackers may override these DAC samples at any
; time. Use with caution!
; ---------------------------------------------------------------------------

dcWriteDAC1:
		moveq	#0,d0
		move.b	(a4)+,d0		; get note to write
		jmp	dNoteWriteDAC1(pc)	; note-on

dcWriteDAC2:
		moveq	#0,d0
		move.b	(a4)+,d0		; get note to write
		jmp	dNoteWriteDAC2(pc)	; note-on
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for handling spindash revving.
; The way spindash revving works, is it actually just
; increments a counter each time, and this counter is
; added into the channel pitch offset.
; ---------------------------------------------------------------------------

dcSpRev:
		move.b	mSpindash.w,d0		; load spindash rev counter to d0
		addq.b	#1,mSpindash.w		; increment spindash rev counter
		add.b	d0,cPitch(a5)		; add d0 to channel pitch offset

		cmp.b	#$C-1,d0		; check if this is the max pitch offset
		blo.s	.rts			; if not, skip
		subq.b	#1,mSpindash.w		; cap at pitch offset $C

.rts
		rts

dcSpReset:
		clr.b	mSpindash.w		; reset spindash rev counter
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for changing channel panning
; ---------------------------------------------------------------------------

dcPan:
	if safe=1
		AMPS_Debug_dcPan		; check if this channel can pan
	endif

		moveq	#$37,d1			; prepare bits to keep
		and.b	cPanning(a5),d1		; and with channel LFO settings
		or.b	(a4)+,d1		; or panning value
		move.b	d1,cPanning(a5)		; save as channel panning

		moveq	#$FFFFFFB4,d0		; YM command: Panning & LFO
		btst	#ctbDAC,cType(a5)	; check if this is a DAC channel
		beq.w	dWriteYMchnInt		; if not, write channel-specific YM command
; ---------------------------------------------------------------------------
; Since the DAC channels have or based panning behavior, we need this
; piece of code to update its panning
; ---------------------------------------------------------------------------

		move.b	mDAC1+cPanning.w,d1	; read panning value from music DAC1
		btst	#cfbInt,mDAC1+cFlags.w	; check if music DAC1 is interrupted by SFX
		beq.s	.nodacsfx		; if not, use music DAC1 panning
		move.b	mSFXDAC1+cPanning.w,d1	; read panning value from SFX DAC1

.nodacsfx
		or.b	mDAC2+cPanning.w,d1	; or the panning value from music DAC2
		moveq	#$FFFFFFB4+2,d0		; YM address: Panning and LFO (FM3/6)
		jmp	WriteYM_Pt2(pc)		; write to part 2 channel
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for changing detune offset
; ---------------------------------------------------------------------------

dcaDetune:
		move.b	(a4)+,d0		; load detune offset from tracker
		add.b	d0,cDetune(a5)		; Add to channel detune offset
		rts

dcsDetune:
		move.b	(a4)+,cDetune(a5)	; load detune offset from tracker to channel
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for changing channel volume
; ---------------------------------------------------------------------------

dcsVolume:
		move.b	(a4)+,cVolume(a5)	; load volume from tracker to channel
		bset	#cfbVol,(a5)		; set volume update flag
		rts

dcaVolume:
		move.b	(a4)+,d0		; load volume from tracker
		add.b	d0,cVolume(a5)		; add to channel volume
		bset	#cfbVol,(a5)		; set volume update flag
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting DAC to sample mode and resetting frequency
; ---------------------------------------------------------------------------

dcSampDAC:
		move.w	#$100,cFreq(a5)		; reset to defualt base frequency
		bclr	#cfbMode,(a5)		; enable sample mode
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting DAC to pitch mode
; ---------------------------------------------------------------------------

dcPitchDAC:
		bset	#cfbMode,(a5)		; enable pitch mode
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for changing channel tick multiplier
; ---------------------------------------------------------------------------

dcsTmulCh:
		move.b	(a4)+,cTick(a5)		; load tick multiplier from tracker to channel
		rts

dcsTmul:
		move.b	(a4)+,d0		; load tick multiplier from tracker to d0
.x =	mDAC1					; start at DAC1
	rept Mus_Ch				; do for all music channels
		move.b	d0,cTick+.x.w		; set channel tick multiplier
.x =		.x+cSize			; go to next channel
	endr
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for enabling or disabling the hold flag
; ---------------------------------------------------------------------------

dcHold:
		bchg	#cfbHold,(a5)		; flip the channel hold flag
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for enabling or disabling note timeout
; ---------------------------------------------------------------------------

dcTimeout:
	if safe=1
		AMPS_Debug_dcTimeout		; check if this channel has timeout support
	endif

		move.b	(a4),cNoteTimeMain(a5)	; load note timeout from tracker to channel
		move.b	(a4)+,cNoteTimeCur(a5)	; ''
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for changing channel pitch
; ---------------------------------------------------------------------------

dcaTransp:
		move.b	(a4)+,d0		; load pitch offset from tracker
		add.b	d0,cPitch(a5)		; add to channel pitch offset
		rts

dcsTransp:
		move.b	(a4)+,cPitch(a5)	; load pitch offset from tracker to channel
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for tempo control
; ---------------------------------------------------------------------------

dcsTempoShoes:
		move.b	(a4)+,d0		; load tempo value from tracker
		move.b	d0,mTempoSpeed.w	; save as the speed shoes tempo
		btst	#mfbSpeed,mFlags.w	; check if speed shoes mode is active
		bne.s	dcsTempoCur		; if is, load as current tempo too
		rts

dcsTempo:
		move.b	(a4)+,d0		; load tempo value from tracker
		move.b	d0,mTempoMain.w		; save as the main tempo
		btst	#mfbSpeed,mFlags.w	; check if speed shoes mode is active
		bne.s	locret_Tempo		; if not, load as current tempo too

dcsTempoCur:
		move.b	d0,mTempo.w		; save as current tempo

locret_Tempo:
		rts

dcaTempoShoes:
		move.b	(a4)+,d0		; load tempo value from tracker
		add.b	d0,mTempoSpeed.w	; add to the speed shoes tempo
		btst	#mfbSpeed,mFlags.w	; check if speed shoes mode is active
		bne.s	dcaTempoCur		; if is, add to current tempo too
		rts

dcaTempo:
		move.b	(a4)+,d0		; load tempo value from tracker
		add.b	d0,mTempoMain.w		; add to the main tempo
		btst	#mfbSpeed,mFlags.w	; check if speed shoes mode is active
		bne.s	locret_Tempo		; if not, add to current tempo too

dcaTempoCur:
		add.b	d0,mTempo.w		; add to current tempo
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for enabling or disabling PSG4 noise mode
; ---------------------------------------------------------------------------

dcNoisePSG:
		move.b	(a4),cStatPSG4(a5)	; load PSG4 status command from tracker to channel
		beq.s	.psg3			; if disabling PSG4 mode, branch
		move.b	#ctPSG4,cType(a5)	; make PSG3 act on behalf of PSG4
		move.b	(a4)+,dPSG		; send command to PSG port
		rts

.psg3
		move.b	#ctPSG3,cType(a5)	; make PSG3 not act on behalf of PSG4
		move.b	#ctPSG4|$1F,dPSG	; send PSG4 mute command to PSG
		addq.w	#1,a4			; skip param
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for playing another music or SFX
; ---------------------------------------------------------------------------

dcSound:
		move.b	(a4)+,mQueue+2.w	; load sound ID from tracker to sound queue

Return_dcSound:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting DAC filter bank
; ---------------------------------------------------------------------------

dcFilter:
		moveq	#0,d0
		move.b	(a4)+,d0		; load filter bank number from tracker
		jmp	dSetFilter(pc)		; load filter bank instructions to Z80 RAM
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for writing a YM command to YMCue
; ---------------------------------------------------------------------------

dcYM:
		move.b	(a4)+,d0		; load YM address from tracker to d0
		move.b	(a4)+,d1		; get command value from tracker to d1
		btst	#cfbInt,(a5)		; is this channel overridden by SFX?
		bne.s	Return_dcSound		; if so, skip

		cmp.b	#$30,d0			; is this register 00-2F?
		blo.w	WriteYM_Pt1		; if so, write to part 1 always

		move.b	d0,d2			; copy address to d2
		sub.b	#$A8,d2			; align $A8 with 0
		cmp.b	#$08,d2			; is this egister A8-AF?
		blo.w	WriteYM_Pt1		; if so, write to part 1 always
		jmp	WriteChYM(pc)		; write to YM according to channel
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting channel base frequency
; ---------------------------------------------------------------------------

dcsFreq:
		move.b	(a4)+,cFreq(a5)		; load base frequency from tracker to channel
		move.b	(a4)+,cFreq+1(a5)	; ''

	if safe=1		; NOTE: You can remove this check, but its unsafe to do so!
		btst	#ctbDAC,cType(a5)	; check if this is a DAC channel
		bne.s	.rts			; if so, bránch
		AMPS_Debug_dcInvalid		; this command should be only used with DAC channels
	endif
.rts
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting channel base frequency from the note table
; ---------------------------------------------------------------------------

dcsFreqNote:
		moveq	#0,d0
		move.b	(a4)+,d0		; load note from tracker to d0
		add.b	cPitch(a5),d0		; add pitch offset to note
		add.w	d0,d0			; double offset (each entry is a word)

		lea	dFreqDAC(pc),a1		; load DAC frequency table to a1
		move.w	(a1,d0.w),cFreq(a5)	; load and save the requested frequency

	if safe=1		; NOTE: You can remove this check, but its unsafe to do so!
		btst	#ctbDAC,cType(a5)	; check if this is a DAC channel
		bne.s	.rts			; if so, bránch
		AMPS_Debug_dcInvalid		; this command should be only used with DAC channels
	endif
.rts
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for doing a continous SFX loop
; ---------------------------------------------------------------------------

dcCont:
		subq.b	#1,mContCtr.w		; decrease continous sfx counter
		bpl.s	dcJump			; if positive, jump to routine
		clr.b	mContLast.w		; clear continous SFX ID
		addq.w	#2,a4			; skip over jump offset
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for calling a tracker subroutine
; ---------------------------------------------------------------------------

dcCall:
	if safe=1
		AMPS_Debug_dcCall1		; check if this channel supports the stack
	endif

		moveq	#0,d0
		move.b	cStack(a5),d0		; get channel stack pointer
		subq.b	#4,d0			; allocate space for another routine

	if safe=1
		AMPS_Debug_dcCall2		; check if we overflowed the space
	endif
		move.l	a4,(a5,d0.w)		; save current address in stack
		move.b	d0,cStack(a5)		; save stack pointer
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for jumping to another tracker location
; ---------------------------------------------------------------------------

dcJump:
	dREAD_WORD a4, d0			; read a word from tracker to d0
		adda.w	d0,a4			; offset tracker address by d0
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for handling loops
; ---------------------------------------------------------------------------

dcLoop:
		moveq	#0,d0
		move.b	(a4)+,d0		; load loop index from tracker to d0
	if safe=1
		AMPS_Debug_dcLoop		; check if loop index is valid
	endif

		tst.b	cLoop(a5,d0.w)		; check the loop counter
		bne.s	.loopok			; if nonzero, branch
		move.b	2(a4),cLoop(a5,d0.w)	; reload loop counter

.loopok
		subq.b	#1,cLoop(a5,d0.w)	; decrease loop counter
		bne.s	dcJump			; if not 0, jump to routine
		addq.w	#3,a4			; skip over jump offset
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for initializing modulation
; ---------------------------------------------------------------------------

dcMod68K:
		move.l	a4,cMod(a5)		; set modulation data address
		move.b	(a4)+,cModDelay(a5)	; load modulation delay from tracker to channel
		move.b	(a4)+,cModSpeed(a5)	; load modulation speed from tracker to channel
		move.b	(a4)+,cModStep(a5)	; load modulation step offset from tracker to channel

		move.b	(a4)+,d0		; load modulation step count from tracker to d0
		lsr.b	#1,d0			; halve it
		move.b	d0,cModCount(a5)	; save as modulation step count to channel
		clr.w	cModFreq(a5)		; reset modulation frequency offset to 0
	; continue to enabling modulation
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for enabling and disabling modulation
; ---------------------------------------------------------------------------

dcModOn:
		bset	#cfbMod,(a5)		; enable modulation
		rts

dcModOff:
		bclr	#cfbMod,(a5)		; disable modulation
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for returning from tracker subroutine
; ---------------------------------------------------------------------------

dcReturn:
	if safe=1
		AMPS_Debug_dcReturn1		; check if this channel supports the stack
	endif
		moveq	#0,d0
		move.b	cStack(a5),d0		; get channel stack pointer
		movea.l	(a5,d0.w),a4		; load the address to return to

		addq.w	#2,a4			; skip the call address parameter
		addq.b	#4,d0			; deallocate stack space
		move.b	d0,cStack(a5)		; save stack pointer

	if safe=1
		AMPS_Debug_dcReturn2		; check if we underflowed the space
	endif
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for initializing special FM3 mode
; ---------------------------------------------------------------------------

dcSpecFM3:
	if safe=1		; NOTE: You can remove this check, but its unsafe to do so!
		AMPS_Debug_dcInvalid		; this is an invalid command
	endif
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for enabling raw frequency mode
; ---------------------------------------------------------------------------

dcFreqOn:
	if safe=1		; NOTE: You can remove this check, but its unsafe to do so!
		AMPS_Debug_dcInvalid		; this is an invalid command
	endif
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for disabling raw frequency mode
; ---------------------------------------------------------------------------

dcFreqOff:
	if safe=1		; NOTE: You can remove this check, but its unsafe to do so!
		AMPS_Debug_dcInvalid		; this is an invalid command
	endif

locret_FreqOff:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for changing voice, volume envelope or sample
; ---------------------------------------------------------------------------

dcVoice:
		moveq	#0,d0
		move.b	(a4)+,d0		; load voice/sample/volume envelope from tracker to d0
		move.b	d0,cVoice(a5)		; save to channel

		tst.b	cType(a5)		; check if this is a PSG channel
		bmi.s	locret_FreqOff		; if is, skip
		btst	#ctbDAC,cType(a5)	; check if this is a DAC channel
		bne.s	locret_FreqOff		; if is, skip

		btst	#cfbInt,(a5)		; check if channel is interrupted by SFX
		bne.s	locret_FreqOff		; if is, skip
		move.l	a6,a1			; load voice table to a1
	; continue to send FM voice
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine for sending the FM voice to YM2612
; This routine is speed optimized in a way that allows Dual PCM
; to only be stopped for as long as it must be. This will waste
; some cycles for 68000, but it will help improve DAC quality.
; ---------------------------------------------------------------------------

dUpdateVoiceFM:
	dCALC_VOICE				; get address of the specific voice to a1
		sub.w	#(VoiceRegs+1)*2,sp	; prepapre space in the stack
		move.l	sp,a3			; copy pointer to the free space to a3

		move.b	(a1)+,d4		; load feedback and algorithm to d4
		move.b	d4,(a3)+		; save it to free space
		move.b	#$B0,(a3)+		; YM command: Algorithm & FeedBack

		lea	dOpListYM(pc),a2	; load YM2612 operator list into a2
	rept VoiceRegs-5
		move.b	(a1)+,(a3)+		; copy each value (except Total Level)
		move.b	(a2)+,(a3)+		; copy each command
	endr

		moveq	#0,d6			; reset the modulator offset
		move.b	cVolume(a5),d3		; load FM channel volume to d3
		add.b	mMasterVolFM.w,d3	; add master FM volume to d3
		bpl.s	.noover			; if volume did not overflow, skio
		moveq	#$7F,d3			; force FM volume to silence

.noover
		btst	#mfbWater,mFlags.w	; check if underwater mode is enabled
		beq.s	.uwdone			; if not, skip
		move.b	d4,d6			; copy algorithm and feedback to d6
		and.w	#7,d6			; mask out everything but the algorithm
		add.b	d6,d3			; add algorithm to Total Level carrier offset
		move.b	d4,d6			; set algorithm and feedback to modulator offset

.uwdone
		moveq	#4-1,d5			; prepare 4 operators to d5

.tlloop
		move.b	(a1)+,d1		; get Total Level value from voice to d1
		bpl.s	.noslot			; if slot operator bit was not set, branch

		add.b	d3,d1			; add carrier offset to loaded value
		bmi.s	.slot			; if we did not overflow, branch
		moveq	#$7F,d1			; cap to silent volume
		bra.s	.slot

.noslot
		add.b	d6,d1			; add modulator offset to loaded value
.slot
		move.b	d1,(a3)+		; save the Total Level value
		move.b	(a2)+,(a3)+		; copy total level command
		dbf	d5,.tlloop		; repeat for each Total Level operator

	if safe=1
		AMPS_Debug_UpdVoiceFM		; check if the voice was valid
	endif

		bclr	#cfbVol,(a5)		; reset volume update request flag
		move.b	cPanning(a5),(a3)+	; copy panning value to free space
		move.b	#$B4,(a3)+		; YM command: Panning & LFO

		moveq	#0,d2			; prepare part 1 value
		move.b	cType(a5),d3		; load FM channel type to d3
		btst	#ctbPt2,d3		; check if its part 1
		beq.s	.ptok			; if so, branch
		and.b	#3,d3			; get channel offset only
		moveq	#2,d2			; prepare part 2 value

.ptok
		move.l	sp,a3			; copy free space pointer to a3 again
		moveq	#VoiceRegs,d1		; prepare loop point
	if safe=1
		AMPS_Debug_CuePtr 0		; make sure cue is valid
	endif
	StopZ80					; wait for Z80 to stop

.write
		move.b	d2,(a0)+		; select YM port to access (4000 or 4002)
		move.b	(a3)+,(a0)+		; write command values

		move.b	(a3)+,d0		; load YM command
		or.b	d3,d0			; add the channel offset to command
		move.b	d0,(a0)+		; save to Z80 cue
		dbf	d1,.write		; write all registers
		st	(a0)			; mark as end of the cue

	StartZ80				; enable Z80 execution
		add.w	#(VoiceRegs+1)*2,sp	; reset stack pointer
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for stopping the current channel
; ---------------------------------------------------------------------------

dcStop:
		and.b	#$FF-(1<<cfbHold)-(1<<cfbRun),(a5); clear hold and running tracker flags
		tst.b	cType(a5)		; check if this was a PSG channel
		bmi.s	.mutePSG		; if yes, mute it

		btst	#ctbDAC,cType(a5)	; check if this was a DAC channel
		bne.s	.cont			; if we are, skip
		jsr	dKeyOffFM(pc)		; send key-off command to YM
		bra.s	.cont
; ---------------------------------------------------------------------------

.mutePSG
		jsr	dMutePSGmus(pc)		; mute PSG channel

.cont
		cmpa.w	#mSFXFM3,a5		; check if this is a SFX channel
		blo.s	.exit			; if not, skip all this mess
		clr.b	cPrio(a5)		; clear channel priority

		lea	dSFXoverList(pc),a1	; load quick reference to the SFX override list to a1
		moveq	#0,d3
		move.b	cType(a5),d3		; load channel type to d3
		bmi.s	.psg			; if this is a PSG channel, branch
		move.w	a5,-(sp)		; push channel pointer

		and.w	#$07,d3			; get only the necessary bits to d3
		subq.w	#2,d3			; since FM 1 and 2 are not used, skip over them
		add.w	d3,d3			; double offset (each entry is 1 word in size)
		move.w	(a1,d3.w),a5		; get the SFX channel we were overriding

.dacdone
		tst.b	(a5)			; check if that channel is running a tracker
		bpl.s	.fixch			; if not, branch

		bset	#cfbVol,(a5)		; set update volume flag (cleared by dUpdateVoiceFM)
		bclr	#cfbInt,(a5)		; reset sfx override flag
		btst	#ctbDAC,cType(a5)	; check if the channel is a DAC channel
		bne.s	.fixch			; if yes, skip

		bset	#cfbRest,(a5)		; Set channel resting flag
		move.l	mVctMus.w,a1		; load music voice table to a1
		move.b	cVoice(a5),d0		; load FM voice ID of the channel to d0
		jsr	dUpdateVoiceFM(pc)	; send FM voice for this channel

.fixch
		move.w	(sp)+,a5		; pop the current channel
.exit
		addq.l	#2,(sp)			; go to next channel immediately
		rts
; ---------------------------------------------------------------------------
; There is nothing that would break even if the channel is not
; running a tracker, so we do not bother checking
; ---------------------------------------------------------------------------

.psg
		lsr.b	#4,d3			; make it easier to reference the right offset in the table
		movea.w	(a1,d3.w),a1		; get the SFX channel we were overriding
		bclr	#cfbInt,(a1)		; channel is not interrupted anymore
		bset	#cfbRest,(a1)		; reset sfx override flag

		cmp.b	#ctPSG4,cType(a1)	; check if this channel is in PSG4 mode
		bne.s	.exit			; if not, skip
		move.b	cStatPSG4(a1),dPSG	; update PSG4 status to PSG port
		bra.s	.exit
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for enabling LFO
; ---------------------------------------------------------------------------

dcsLFO:
		moveq	#0,d0
		move.b	cVoice(a5),d0		; load FM voice ID of the channel to d0
		move.l	a6,a1			; load voice table to a1

	dCALC_VOICE 9				; get address of the specific voice to a1
		move.b	(a4),d3			; load LFO enable operators to d3
		lea	dAMSEn_Ops(pc),a2	; load Decay 1 Rate address table to a2
		moveq	#4-1,d6			; prepare 4 operators to d5

.decayloop
		move.b	(a1)+,d1		; get Decay 1 Level value from voice to d1
		move.b	(a2)+,d0		; load YM address to write to d0

		add.b	d3,d3			; check if LFO is enabled for this channeö
		bcc.s	.noLFO			; if not, skip
		or.b	#$80,d1			; set enable LFO bit
		jsr	WriteChYM(pc)		; write to YM according to channel

.noLFO
		dbf	d6,.decayloop		; repeat for each Decay 1 Level operator

		move.b	(a4)+,d1		; load LFO frequency value from tracker
		moveq	#$22,d0			; YM command: LFO
		jsr	WriteYM_Pt1(pc)		; write to part 1 channel

		move.b	(a4)+,d1		; load AMS, FMS & Panning from tracker
		move.b	d1,cPanning(a5)		; save to channel panning

		moveq	#$FFFFFFB4,d0		; YM command: Panning & LFO
		jmp	dWriteYMchnInt(pc)	; write to YM according to channel
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for resetting condition
; ---------------------------------------------------------------------------

dcResetCond:
		bclr	#cfbCond,(a5)		; reset condition flag
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for writing to communications flags
; ---------------------------------------------------------------------------

dcsComm:
		lea	mComm.w,a1		; get communications array to a1
		moveq	#0,d0
		move.b	(a4)+,d0		; load byte number to write from tracker
		move.b	(a4)+,(a1,d0.w)		; load vaue from tracker to communications byte
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; RAM addresses for special condition code
; ---------------------------------------------------------------------------

dcCondRegTable:
	dc.w Region, mFlags		; 0
	dc.w mTempoMain, mTempoSpeed	; 2
	dc.w 0, 0			; 4
	dc.w 0, 0			; 6
	dc.w 0, 0			; 8
	dc.w 0, 0			; $A
	dc.w 0, 0			; $C
	dc.w 0, cType			; $E
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for checking special RAM addresses
; ---------------------------------------------------------------------------

dcCondReg:
		move.b	(a4)+,d0		; get value from tracker
		move.b	d0,d1			; copy to d1

		and.w	#$F,d0			; get RAM table offset to d0
		add.w	d0,d0			; double it (each entry is 1 word)
		move.w	dcCondRegTable(pc,d0.w),d0; get data to read from
		bmi.s	.gotit			; branch if if was a RAM address
		add.w	a5,d0			; else it was a channel offset

.gotit
		move.w	d0,a1			; get the desired address from d0 to a1
		move.b	(a1),d0			; read byte from it
		bra.s	dcCondCom
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for checking communications bytes
; ---------------------------------------------------------------------------

dcCond:
		lea	mComm.w,a1		; get communications array to a1
		move.b	(a4)+,d0		; load condition and offset from tracker to d0
		move.b	d0,d1			; copy to d1
		and.w	#$F,d0			; get offset only
		move.b	(a1,d0.w),d0		; load value from communcations byte to d0

dcCondCom:
		bclr	#cfbCond,(a5)		; set condition to true
		and.w	#$F0,d1			; get condition value only
		lsr.w	#2,d1			; shift 2 bits down (each entry is 4 bytes large)
		cmp.b	(a4)+,d0		; check value against tracker byte
		jmp	.cond(pc,d1.w)		; handle conditional code
; ===========================================================================
; ---------------------------------------------------------------------------
; Code for setting the condition flag
; ---------------------------------------------------------------------------

.c	macro x
	\x	.false
	rts
     endm

.false
		bset	#cfbCond,(a5)		; set condition to false

.cond	rts		; T
	rts
	.c bra.s	; F
	.c bls.s	; HI
	.c bhi.s	; LS
	.c blo.s	; HS/CC
	.c bhs.s	; LO/CS
	.c beq.s	; NE
	.c bne.s	; EQ
	.c bvs.s	; VC
	.c bvc.s	; VS
	.c bmi.s	; PL
	.c bpl.s	; MI
	.c blt.s	; GE
	.c bge.s	; LT
	.c ble.s	; GT
	.c bgt.s	; LE
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for freezing the CPU. DEBUG FLAG
; ---------------------------------------------------------------------------

	if safe=1
dcFreeze:
		bra.w	*		; Freeze CPU here
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for debugging tracker data. DEBUG FLAG
; ---------------------------------------------------------------------------

dcTracker:
		st	msChktracker.w	; set debug flag
		rts
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Define music and SFX
; ---------------------------------------------------------------------------

	opt oz-				; disable zero-offset optimization
	if safe=0
		nolist			; if in safe mode, list data section.
	endif

__sfx =		SFXoff
__mus =		MusOff
SoundIndex:
	ptrSFX	0, RingRight, RingLeft, RingLoss, Splash, Break
	ptrSFX	0, Jump, Roll, Skid, Bubble, Drown, SpikeHit, Death
	ptrSFX	0, AirDing, Register, Bonus, Shield, Dash, Signpost
	ptrSFX	0, Lamppost, BossHit, Bumper, Spring
	ptrSFX	0, Collapse, BigRing, Smash, Switch, Explode
	ptrSFX	0, BuzzExplode, Basaran, Electricity, Flame, LavaBall
	ptrSFX	0, SpikeMove, Rumble, Door, Stomp, Chain, Saw, Lava

	ptrSFX	0, EnterSS, Goal, ActionBlock, Diamonds, Continue

; SFX with special features
	ptrSFX	$80, PushBlock

; unused SFX
	ptrSFX	0, UnkA2, UnkAB, UnkB8

MusicIndex:
	ptrMusic GHZ, $25, LZ, $02, MZ, $02, SLZ, $07, SYZ, $0C, SBZ, $20, FZ, $10
	ptrMusic Boss, $2E, SS, $00, Invincibility, $01, Drowning, $80
	ptrMusic Title, $00, GotThroughAct, $00, Emerald, $00
	ptrMusic GameOver, $00, Continue, $00, Ending, $00, Credits, $00, SEGA, $00
; ===========================================================================
; ---------------------------------------------------------------------------
; Define samples
; ---------------------------------------------------------------------------

__samp =	$80
SampleList:
	sample $0000, Stop, Stop		; 80 - Stop sample (DO NOT EDIT)
	sample $0100, Kick, Stop		; 81 - Kick
	sample $0100, Snare, Stop		; 82 - Snare
	sample $0100, Timpani, Stop, HiTimpani	; 83 - Hi Timpani
	sample $00E6, Timpani, Stop, MidTimpani	; 84 - Timpani
	sample $00C2, Timpani, Stop, LowTimpani	; 85 - Low Timpani
	sample $00B6, Timpani, Stop, FloorTimpani; 86 - Floor Timpani
	sample $0100, Sega, Stop		; 87 - SEGA screen
; ===========================================================================
; ---------------------------------------------------------------------------
; Define volume envelopes and their data
; ---------------------------------------------------------------------------

__venv =	$01
VolEnvs:
	volenv 01, 02, 03, 04, 05, 06, 07, 08
	volenv 09
VolEnvs_End:
	opt ae-

vd01:		dc.b $00, $00, $00, $01, $01, $01, $02, $02
		dc.b $02, $03, $03, $03, $04, $04, $04, $05
		dc.b $05, $05, $06, $06, $06, $07, eHold

vd02:		dc.b $00, $02, $04, $06, $08, $10, eHold

vd03:		dc.b $00, $00, $01, $01, $02, $02, $03, $03
		dc.b $04, $04, $05, $05, $06, $06, $07, $07
		dc.b eHold

vd04:		dc.b $00, $00, $02, $03, $04, $04, $05, $05
		dc.b $05, $06, eHold

vd05:		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $01, $01, $01, $01, $01, $01
		dc.b $01, $01, $01, $01, $01, $01, $01, $01
		dc.b $02, $02, $02, $02, $02, $02, $02, $02
		dc.b $03, $03, $03, $03, $03, $03, $03, $03
		dc.b $04, eHold

vd06:		dc.b $03, $03, $03, $02, $02, $02, $02, $01
		dc.b $01, $01, $00, $00, $00, $00, eHold

vd07:		dc.b $00, $00, $00, $00, $00, $00, $01, $01
		dc.b $01, $01, $01, $02, $02, $02, $02, $02
		dc.b $03, $03, $03, $04, $04, $04, $05, $05
		dc.b $05, $06, $07, eHold

vd08:		dc.b $00, $00, $00, $00, $00, $01, $01, $01
		dc.b $01, $01, $02, $02, $02, $02, $02, $02
		dc.b $03, $03, $03, $03, $03, $04, $04, $04
		dc.b $04, $04, $05, $05, $05, $05, $05, $06
		dc.b $06, $06, $06, $06, $07, $07, $07, eHold

vd09:		dc.b $00, $01, $02, $03, $04, $05, $06, $07
		dc.b $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
		dc.b eHold
; ===========================================================================
; ---------------------------------------------------------------------------
; Include music, sound effects and voice table
; ---------------------------------------------------------------------------

	include "driver/Patches.asm"	; include universal patch bank
	opt ae-				; disable automatic evens
sfxaddr	incSFX				; include all sfx
musaddr	incMus				; include all music
musend
; ===========================================================================
; ---------------------------------------------------------------------------
; Include samples and filters
; ---------------------------------------------------------------------------

		align	$8000		; must be aligned to bank...
fLog:		incbin "driver/filters/Logarithmic.dat"	; loagirthmic filter (no filter)
;fLinear:	incbin "driver/filters/Linear.dat"	; linear filter (no filter)

dacaddr		dcb.b	Z80E_Read*(MaxPitch/$100),$00
SWF_Stop:	dcb.b	$8000-(2*Z80E_Read*(MaxPitch/$100)),$80
SWFR_Stop:	dcb.b	Z80E_Read*(MaxPitch/$100),$00

	incSWF	Kick, Timpani, Snare, Sega
	opt ae+				; enable automatic evens
	list				; continue source listing
; ===========================================================================
