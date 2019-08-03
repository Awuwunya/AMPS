; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for pausing the sound driver
; ---------------------------------------------------------------------------

dPlaySnd_Pause:
		bset	#mfbPaused,mFlags.w	; pause music
		bne.w	locret_MuteDAC		; if was already paused, skip
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
; Routine for unpausing the sound driver
; ---------------------------------------------------------------------------

dPlaySnd_Unpause:
		bclr	#mfbPaused,mFlags.w	; unpause music
		beq.s	locret_MuteDAC		; if was already unpaused, skip
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
; ---------------------------------------------------------------------------
; To save few cycles, we don't directly substract the music offset from
; the ID, and instead offset the table position. In practice this will
; have the same effect, but saves us 8 cycles overall.
; ---------------------------------------------------------------------------

		lea	MusicIndex-(MusOff*4)(pc),a4; get music pointer table with an offset
		add.w	d7,d7			; quadruple music ID
		add.w	d7,d7			; since each entry is 4 bytes in size
		move.b	(a4,d7.w),d6		; load speed shoes tempo from the unused 8 bits
		movea.l	(a4,d7.w),a4		; get music header pointer from the table

	if safe=1
		move.l	a4,d0			; copy pointer to d0
		and.l	#$FFFFFF,d0		; clearing the upper 8 bits allows the debugger
		move.l	d0,a4			; to show the address correctly. Move ptr back to a4
		AMPS_Debug_PlayTrackMus		; check if this was valid music
	endif
; ---------------------------------------------------------------------------
; The following code will 'back-up' every song by copying its data to
; other memory location. There is another piece of code that will copy
; back once the other song ends. This will do proper restoration of the
; channels into hardware! The 6th bit of tick multiplier is used to
; determine whether to back-up or not...
; ---------------------------------------------------------------------------

	if FEATURE_BACKUP
		btst	#6,(a4)			; check if this song should cause the last one to be backed up
		beq.s	.clrback		; if not, skip
		bset	#mfbBacked,mFlags.w	; check if song was backed up (and if not, set the bit)
		bne.s	.noback			; if yes, preserved the backed up song

		move.l	mTempoMain.w,mBackTempoMain.w; backup tempo settings
		move.l	mVctMus.w,mBackVctMus.w	; backup voice table address

		lea	mDAC1.w,a2		; load source address to a0
		lea	mBackDAC1.w,a1		; load destination address to a1
		move.w	#(mSFXDAC1-mDAC1)/4-1,d0; load backup size to d0

.backup
		move.l	(a2)+,(a1)+		; back up data for every channel
		dbf	d0, .backup		; loop for each longword

		moveq	#$FF-(1<<cfbInt)-(1<<cfbVol),d0; each other bit except interrupted and volume update bits

.ch =		mBackDAC1			; start at backup DAC1
		rept Mus_Ch			; do for all music channels
			and.b	d0,.ch.w	; remove the interrupted by sfx bit
.ch =			.ch+cSize		; go to next channel
		endr
		bra.s	.noback

.clrback
		bclr	#mfbBacked,mFlags.w	; set as no song backed up

.noback
	endif
; ---------------------------------------------------------------------------
; EArlier we used to stop the channels immediately, but due to requiring
; the channel back-up feature, this was moved here instead. It still works
; out the exact same though...
; ---------------------------------------------------------------------------

		jsr	dStopMusic(pc)		; mute hardware and reset all driver memory
		jsr	dResetVolume(pc)	; reset volumes and end any fades

		move.b	d6,mTempoSpeed.w	; save loaded value into tempo speed setting
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
		or.b	#1<<mfbNoPAL,mFlags.w	; disable PAL fix

.noPAL
		moveq	#$FFFFFF00|(1<<cfbRun)|(1<<cfbVol),d2; prepare running tracker and volume flags into d2
		moveq	#$FFFFFFC0,d1		; prepare panning value of centre to d1

		and.w	#$3F,d4			; keep tick multiplier value in range
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

		move.w	#fLog>>$0F,d0		; use logarithmic filter
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

locret_PlaySnd:
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
	if FEATURE_BACKUP&FEATURE_BACKUPNOSFX
		btst	#mfbBacked,mFlags.w	; check if a song has been queued
		bne.s	locret_PlaySnd		; branch if so
	endif

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
		move.w	#sfx_RingLeft,d7	; switch to left panned sound effect instead
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
		moveq	#2,d2			; prepare duration of 1 frames to d5
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
		moveq	#1,d2			; prepare duration of 0 frames to d5
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
	if FEATURE_BACKUP
		bclr	#mfbBacked,mFlags.w	; reset backed up song bit
	endif

; Not needed,	moveq	#$2B,d0			; YM command: DAC Enable
; Dual PCM does	moveq	#$FFFFFF80,d1		; FM6 acts as DAC
; this for us	jsr	WriteYM_Pt1(pc)		; write to YM global register

		moveq	#$27,d0			; YM command: Channel 3 Mode & Timer Control
		moveq	#0,d1			; disable timers and channel 3 special mode
		jsr	WriteYM_Pt1(pc)		; write to YM global register

		lea	mSFXDAC1.w,a1		; prepare SFX DAC 1 to start clearing from
	dCLEAR_MEM	mChannelEnd-mSFXDAC1, 16; clear this block of memory with 16 byts per loop

	; continue straight to stopping music
; ===========================================================================
; ---------------------------------------------------------------------------
; Stop music from playing, reset driver memory and mute hardware
; ---------------------------------------------------------------------------

dStopMusic:
		lea	mVctMus.w,a1		; load driver RAM start to a1
		move.b	mMasterVolDAC.w,d0	; load DAC master volume to d4
	dCLEAR_MEM	mSFXDAC1-mVctMus, 32	; clear this block of memory with 32 byts per loop

	if safe=1
		clr.b	msChktracker.w		; if in safe mode, also clear the check tracker variable!
	endif

		move.b	d0,mMasterVolDAC.w	; save DAC master volume
		jsr	dMuteFM(pc)		; hardware mute FM
		jsr	dMuteDAC(pc)		; hardware mute DAC
	; continue straight to hardware muting PSG
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
; Routine for resetting master volumes, filters and disabling fading
; ---------------------------------------------------------------------------

dResetVolume:
		clr.l	mFadeAddr.w		; stop fading program and reset FM master volume
		clr.b	mMasterVolPSG.w		; reset PSG master volume
		clr.b	mMasterVolDAC.w		; reset DAC master volume
		move.w	#fLog>>$0F,d0		; load value for linear filter
		jsr	dSetFilter(pc)		; load filter instructions

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
		bset	#mfbSpeed,mFlags.w	; enable speed shoes flag
		move.b	mTempoSpeed.w,mTempoCur.w; set tempo accumulator/counter to speed shoes one
		move.b	mTempoSpeed.w,mTempo.w	; set main tempor to speed shoes one

	if FEATURE_BACKUP
		move.b	mBackTempoSpeed.w,mBackTempoCur.w; do the same for backup tempos
		move.b	mBackTempoSpeed.w,mBackTempo.w
	endif
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Reset music flags (underwater mode and tempo mode)
; ---------------------------------------------------------------------------

dPlaySnd_Reset:
	if FEATURE_BACKUP
		bclr	#mfbBacked,mFlags.w	; reset backed up song bit
	endif

	if FEATURE_UNDERWATER
		bsr.s	dPlaySnd_OutWater	; gp reset underwater flag and request volume update
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Disable speed shoes mode
; ---------------------------------------------------------------------------

dPlaySnd_ShoesOff:
		bclr	#mfbSpeed,mFlags.w	; disable speed shoes flag
		move.b	mTempoMain.w,mTempoCur.w; set tempo accumulator/counter to normal one
		move.b	mTempoMain.w,mTempo.w	; set main tempor to normal one

	if FEATURE_BACKUP
		move.b	mBackTempoMain.w,mBackTempoCur.w; do the same for backup tempos
		move.b	mBackTempoMain.w,mBackTempo.w
	endif
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Enable Underwater mode
; ---------------------------------------------------------------------------

dPlaySnd_ToWater:
	if FEATURE_UNDERWATER
		bset	#mfbWater,mFlags.w	; enable underwater mode
		bra.s	dReqVolUpFM		; request FM volume update
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Disable Underwater mode
; ---------------------------------------------------------------------------

dPlaySnd_OutWater:
	if FEATURE_UNDERWATER
		bclr	#mfbWater,mFlags.w	; disable underwater mode
	else
		rts
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; force volume update on all FM channels
; ---------------------------------------------------------------------------

dReqVolUpFM:
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

locret_ReqVolUp:
		rts
