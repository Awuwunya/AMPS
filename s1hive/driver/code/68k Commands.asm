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
		add.b	d1,d1			; quadruple command ID
		add.b	d1,d1			; since each entry is 4 bytes large

		btst	#cfbCond,(a1)		; check if condition state
		bne.w	.falsecomm		; branch if false
		jmp	.comm-$80(pc,d1.w)	; jump to appropriate handler
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
	bra.w	dcVoice		; E8 - Set Voice/sample to xx (INSTRUMENT - INS_C_FM / INS_C_DAC)
	bra.w	dcsTempoShoes	; E9 - Set music speed shoes tempo to xx (TEMPO - TEMPO_SET_SPEED)
	bra.w	dcsTempo	; EA - Set music tempo to xx (TEMPO - TEMPO_SET)
	bra.w	dcSampDAC	; EB - Use sample DAC mode (DAC_MODE - DACM_SAMP)
	bra.w	dcPitchDAC	; EC - Use pitch DAC mode (DAC_MODE - DACM_NOTE)
	bra.w	dcaVolume	; ED - Add xx to channel volume (VOLUME - VOL_CN_FM / VOL_CN_PSG / VOL_CN_DAC)
	bra.w	dcsVolume	; EE - Set channel volume to xx (VOLUME - VOL_CN_ABS)
	bra.w	dcsLFO		; EF - Set LFO (SET_LFO - LFO_AMSEN)
	bra.w	dcMod68K	; F0 - Modulation (MOD_SETUP)
	bra.w	dcPortamento	; F1 - Portamento enable/disable flag (PORTAMENTO)
	bra.w	dcVolEnv	; F2 - Set volume envelope to xx (INSTRUMENT - INS_C_PSG) (FM_VOLENV / DAC_VOLENV)
	bra.w	dcModEnv	; F3 - Set modulation envelope to xx (MOD_ENV - MENV_GEN)
	bra.w	dcCont		; F4 - Do a continuous SFX loop (CONT_SFX)
	bra.w	dcStop		; F5 - End of channel (TRK_END - TEND_STD)
	bra.w	dcJump		; F6 - Jump to xxxx (GOTO)
	bra.w	dcLoop		; F7 - Loop back to zzzz yy times, xx being the loop index (LOOP)
	bra.w	dcCall		; F8 - Call pattern at xxxx, saving return point (GOSUB)
	bra.w	dcReturn	; F9 - Return (RETURN)
	bra.w	dcsComm		; FA - Set communications byte yy to xx (SET_COMM - SPECIAL)
	bra.w	dcCond		; FB - Get comms byte y, and compare zz using condition x (COMM_CONDITION)
	bra.w	dcResetCond	; FC - Reset condition (COMM_RESET)
	bra.w	dcTimeout	; FD - Stop note after xx frames (NOTE_STOP - NSTOP_NORMAL)
	bra.w	dcYM		; FE - YM command (YMCMD)
				; FF - META
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine to execute tracker meta and false condition commands
; ---------------------------------------------------------------------------

.metacall
		move.b	(a2)+,d1		; get next command byte
		jmp	.meta(pc,d1.w)		; jump to appropriate meta handler

.falsecomm
		jmp	.false-$80(pc,d1.w)	; jump to appropriate handler (false command)
; ===========================================================================
; ---------------------------------------------------------------------------
; Command handlers for meta commands
; ---------------------------------------------------------------------------

.meta
	bra.w	dcModOn		; FF 00 - Turn on Modulation (MOD_SET - MODS_ON)
	bra.w	dcModOff	; FF 04 - Turn off Modulation (MOD_SET - MODS_OFF)
	bra.w	dcsFreq		; FF 08 - Set channel frequency to xxxx (CHFREQ_SET)
	bra.w	dcsFreqNote	; FF 0C - Set channel frequency to note xx (CHFREQ_SET - CHFREQ_NOTE)
	bra.w	dcSpRev		; FF 10 - Increment spindash rev counter (SPINDASH_REV - SDREV_INC)
	bra.w	dcSpReset	; FF 14 - Reset spindash rev counter (SPINDASH_REV - SDREV_RESET)
	bra.w	dcaTempoShoes	; FF 18 - Add xx to music speed tempo (TEMPO - TEMPO_ADD_SPEED)
	bra.w	dcaTempo	; FF 1C - Add xx to music tempo (TEMPO - TEMPO_ADD)
	bra.w	dcCondReg	; FF 20 - Get RAM table offset by y, and chk zz with cond x (COMM_CONDITION - COMM_SPEC)
	bra.w	dcSound		; FF 24 - Play another music/sfx (SND_CMD)
	bra.w	dcFreqOn	; FF 28 - Enable raw frequency mode (RAW_FREQ)
	bra.w	dcFreqOff	; FF 2C - Disable raw frequency mode (RAW_FREQ - RAW_FREQ_OFF)
	bra.w	dcSpecFM3	; FF 30 - Enable FM3 special mode (SPC_FM3)
	bra.w	dcFilter	; FF 34 - Set DAC filter bank. (DAC_FILTER)
	bra.w	dcBackup	; FF 38 - Load the last song from back-up (FADE_IN_SONG)
	bra.w	dcNoisePSG	; FF 3C - PSG4 mode to xx (PSG_NOISE - PNOIS_AMPS)

	if safe=1
		bra.w	dcFreeze	; FF 40 - Freeze CPU. Debug flag (DEBUG_STOP_CPU)
		bra.w	dcTracker	; FF 44 - Bring up tracker debugger at end of frame. Debug flag (DEBUG_PRINT_TRACKER)
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Command handlers for false condition execution
; ---------------------------------------------------------------------------

.false
	addq.w	#1,a2
	rts			; E0 - Panning, AMS, FMS (PANAFMS - PAFMS_PAN)
	addq.w	#1,a2
	rts			; E1 - Add xx to channel frequency displacement (DETUNE)
	addq.w	#1,a2
	rts			; E2 - Add xx to channel frequency displacement (DETUNE)
	addq.w	#1,a2
	rts			; E3 - Set channel pitch to xx (TRANSPOSE - TRNSP_SET)
	addq.w	#1,a2
	rts			; E4 - Add xx to channel pitch (TRANSPOSE - TRNSP_ADD)
	addq.w	#1,a2
	rts			; E5 - Set channel tick multiplier to xx (TICK_MULT - TMULT_CUR)
	addq.w	#1,a2
	rts			; E6 - Set global tick multiplier to xx (TICK_MULT - TMULT_ALL)
	bra.w	dcHold		; E7 - Do not allow note on/off for next note (HOLD)
	addq.w	#1,a2
	rts			; E8 - Add xx to music tempo (TEMPO - TEMPO_ADD)
	addq.w	#1,a2
	rts			; E9 - Set music tempo to xx (TEMPO - TEMPO_SET)
	addq.w	#1,a2
	rts			; EA - Set Voice/voice/sample to xx (INSTRUMENT - INS_C_FM / INS_C_PSG / INS_C_DAC)
	rts
	rts			; EB - Use sample DAC mode (DAC_MODE - DACM_SAMP)
	rts
	rts			; EC - Use pitch DAC mode (DAC_MODE - DACM_NOTE)
	addq.w	#1,a2
	rts			; ED - Add xx to channel volume (VOLUME - VOL_CN_FM / VOL_CN_PSG / VOL_CN_DAC)
	addq.w	#1,a2
	rts			; EE - Set channel volume to xx (VOLUME - VOL_CN_ABS)
	addq.w	#1,a2
	rts			; EF - Set LFO (SET_LFO - LFO_AMSEN)
	addq.w	#4,a2
	rts			; F0 - Modulation (MOD_SETUP)
	addq.w	#1,a2
	rts			; F1 - Portamento enable/disable flag (PORTAMENTO)
	addq.w	#1,a2
	rts			; F2 - Set volume envelope to xx (INSTRUMENT - INS_C_PSG) (FM_VOLENV / DAC_VOLENV)
	addq.w	#1,a2
	rts			; F3 - Set modulation envelope to xx (MOD_ENV - MENV_GEN)
	addq.w	#2,a2
	rts			; F4 - Do a continuous SFX loop (CONT_SFX)
	rts
	rts			; F5 - End of channel (TRK_END - TEND_STD)
	addq.w	#2,a2
	rts			; F6 - Jump to xxxx (GOTO)
	addq.w	#4,a2
	rts			; F7 - Loop back to zzzz yy times, xx being the loop index (LOOP)
	addq.w	#2,a2
	rts			; F8 - Call pattern at xxxx, saving return point (GOSUB)
	rts
	rts			; F9 - Return (RETURN)
	bra.w	dcsComm		; FA - Set communications byte yy to xx (SET_COMM - SPECIAL)
	bra.w	dcCond		; FB - Get comms byte y, and compare zz using condition x (COMM_CONDITION)
	bra.w	dcResetCond	; FC - Reset condition (COND_RESET)
	addq.w	#1,a2
	rts			; FD - Stop note after xx frames (NOTE_STOP - NSTOP_NORMAL
	addq.w	#1,a2
	rts			; FE - YM command (YMCMD)
	bra.w	.metacall	; FF - META
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for handling spindash revving.
; The way spindash revving works, is it actually just
; increments a counter each time, and this counter is
; added into the channel pitch offset.
; ---------------------------------------------------------------------------

dcSpRev:
		move.b	mSpindash.w,d3		; load spindash rev counter to d0
		addq.b	#1,mSpindash.w		; increment spindash rev counter
		add.b	d3,cPitch(a2)		; add d0 to channel pitch offset

		cmp.b	#$C-1,d3		; check if this is the max pitch offset
		blo.s	.rts			; if not, skip
		subq.b	#1,mSpindash.w		; cap at pitch offset $C

.rts
		rts

dcSpReset:
		clr.b	mSpindash.w		; reset spindash rev counter

Return_dcSpReset:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for changing channel panning
; ---------------------------------------------------------------------------

dcPan:
	if safe=1
		AMPS_Debug_dcPan		; check if this channel can pan
	endif

	; WARNING: FM6 is not properly implemented, so panning for FM6 WILL
	; break DAC channels and SFX DAC channels. Please be careful!

		moveq	#$37,d3			; prepare bits to keep
		and.b	cPanning(a1),d3		; and with channel LFO settings
		or.b	(a2)+,d3		; or panning value
		move.b	d3,cPanning(a1)		; save as channel panning

		btst	#ctbDAC,cType(a1)	; check if this is a DAC channel
		bne.s	.dac			; if yes, branch
		btst	#cfbInt,(a1)		; check if interrupted by SFX
		bne.s	.rts			; if yes, do not update

	CheckCue				; check that YM cue is valid
	InitChYM				; prepare to write to channel-specific YM channel
	stopZ80
	WriteChYM	#$B4, d3		; Panning & LFO
	;	st	(a0)			; write end marker
	startZ80

.rts
		rts
; ---------------------------------------------------------------------------
; Since the DAC channels have or based panning behavior, we need this
; piece of code to update its panning
; ---------------------------------------------------------------------------

.dac
		move.b	mDAC1+cPanning.w,d3	; read panning value from music DAC1
		btst	#cfbInt,mDAC1+cFlags.w	; check if music DAC1 is interrupted by SFX
		beq.s	.nodacsfx		; if not, use music DAC1 panning
		move.b	mSFXDAC1+cPanning.w,d3	; read panning value from SFX DAC1

.nodacsfx
		or.b	mDAC2+cPanning.w,d3	; or the panning value from music DAC2
	CheckCue				; check that YM cue is valid
	stopZ80
	WriteYM2	#$B6, d3		; Panning & LFO
	;	st	(a0)			; write end marker
	startZ80
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for changing detune offset
; ---------------------------------------------------------------------------

dcaDetune:
		move.b	(a2)+,d3		; load detune offset from tracker
		add.b	d3,cDetune(a1)		; Add to channel detune offset
		rts

dcsDetune:
		move.b	(a2)+,cDetune(a1)	; load detune offset from tracker to channel
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for changing channel volume
; ---------------------------------------------------------------------------

dcsVolume:
		move.b	(a2)+,cVolume(a1)	; load volume from tracker to channel
		bset	#cfbVol,(a1)		; set volume update flag
		rts

dcaVolume:
		move.b	(a2)+,d3		; load volume from tracker
		add.b	d3,cVolume(a1)		; add to channel volume
		bset	#cfbVol,(a1)		; set volume update flag
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting DAC to sample mode and resetting frequency
; ---------------------------------------------------------------------------

dcSampDAC:
		move.w	#$100,cFreq(a1)		; reset to defualt base frequency
		bclr	#cfbMode,(a1)		; enable sample mode
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting DAC to pitch mode
; ---------------------------------------------------------------------------

dcPitchDAC:
		bset	#cfbMode,(a1)		; enable pitch mode
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for changing channel tick multiplier
; ---------------------------------------------------------------------------

dcsTmulCh:
		move.b	(a2)+,cTick(a1)		; load tick multiplier from tracker to channel
		rts

dcsTmul:
		move.b	(a2)+,d3		; load tick multiplier from tracker to d0
.x =	mDAC1					; start at DAC1
	rept Mus_Ch				; do for all music channels
		move.b	d3,cTick+.x.w		; set channel tick multiplier
.x =		.x+cSize			; go to next channel
	endr
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for enabling or disabling the hold flag
; ---------------------------------------------------------------------------

dcHold:
		bchg	#cfbHold,(a1)		; flip the channel hold flag
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for enabling or disabling note timeout
; ---------------------------------------------------------------------------

dcTimeout:
	if safe=1
		AMPS_Debug_dcTimeout		; check if this channel has timeout support
	endif

		move.b	(a2),cNoteTimeMain(a1)	; load note timeout from tracker to channel
		move.b	(a2)+,cNoteTimeCur(a1)	; ''
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for changing channel pitch
; ---------------------------------------------------------------------------

dcaTransp:
		move.b	(a2)+,d3		; load pitch offset from tracker
		add.b	d3,cPitch(a1)		; add to channel pitch offset
		rts

dcsTransp:
		move.b	(a2)+,cPitch(a2)	; load pitch offset from tracker to channel
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for tempo control
; ---------------------------------------------------------------------------

dcsTempoShoes:
		move.b	(a2)+,d3		; load tempo value from tracker
		move.b	d3,mTempoSpeed.w	; save as the speed shoes tempo
		btst	#mfbSpeed,mFlags.w	; check if speed shoes mode is active
		bne.s	dcsTempoCur		; if is, load as current tempo too
		rts

dcsTempo:
		move.b	(a2)+,d3		; load tempo value from tracker
		move.b	d3,mTempoMain.w		; save as the main tempo
		btst	#mfbSpeed,mFlags.w	; check if speed shoes mode is active
		bne.s	locret_Tempo		; if not, load as current tempo too

dcsTempoCur:
		move.b	d3,mTempo.w		; save as current tempo

locret_Tempo:
		rts

dcaTempoShoes:
		move.b	(a2)+,d3		; load tempo value from tracker
		add.b	d3,mTempoSpeed.w	; add to the speed shoes tempo
		btst	#mfbSpeed,mFlags.w	; check if speed shoes mode is active
		bne.s	dcaTempoCur		; if is, add to current tempo too
		rts

dcaTempo:
		move.b	(a2)+,d3		; load tempo value from tracker
		add.b	d3,mTempoMain.w		; add to the main tempo
		btst	#mfbSpeed,mFlags.w	; check if speed shoes mode is active
		bne.s	locret_Tempo		; if not, add to current tempo too

dcaTempoCur:
		add.b	d3,mTempo.w		; add to current tempo
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for enabling or disabling PSG4 noise mode
; ---------------------------------------------------------------------------

dcNoisePSG:
		move.b	(a2),cStatPSG4(a1)	; load PSG4 status command from tracker to channel
		beq.s	.psg3			; if disabling PSG4 mode, branch
		move.b	#ctPSG4,cType(a1)	; make PSG3 act on behalf of PSG4
		move.b	(a2)+,dPSG		; send command to PSG port
		rts

.psg3
		move.b	#ctPSG3,cType(a1)	; make PSG3 not act on behalf of PSG4
		move.b	#ctPSG4|$1F,dPSG	; send PSG4 mute command to PSG
		addq.w	#1,a2			; skip param
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for playing another music or SFX
; ---------------------------------------------------------------------------

dcSound:
		move.b	(a2)+,mQueue+2.w	; load sound ID from tracker to sound queue

Return_dcSound:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting DAC filter bank
; ---------------------------------------------------------------------------

dcFilter:
		move.b	(a2)+,d4		; load filter bank number from tracker
		jmp	dSetFilter(pc)		; load filter bank instructions to Z80 RAM
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for writing a YM command to YMCue
; ---------------------------------------------------------------------------

dcYM:
		move.b	(a2)+,d3		; load YM address from tracker to d3
		move.b	(a2)+,d1		; get command value from tracker to d0
		btst	#cfbInt,(a1)		; is this channel overridden by SFX?
		bne.s	Return_dcSound		; if so, skip

		cmp.b	#$30,d3			; is this register 00-2F?
		blo.s	.pt1			; if so, write to part 1 always

		move.b	d3,d4			; copy address to d4
		sub.b	#$A8,d4			; align $A8 with 0
		cmp.b	#$08,d4 		; is this register A8-AF?
		blo.s	.pt1			; if so, write to part 1 always

	CheckCue				; check that cue is valid
	InitChYM				; prepare to write to YM channel
	stopZ80
	WriteChYM	d3, d1			; write to the channel
	;	st	(a0)			; write end marker
	startZ80
		rts

.pt1
	CheckCue				; check that cue is valid
	stopZ80
	WriteYM1	d3, d1			; write register to YM1
	;	st	(a0)			; write end marker
	startZ80
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting channel base frequency
; ---------------------------------------------------------------------------

dcsFreq:
		move.b	(a2)+,cFreq(a1)		; load base frequency from tracker to channel
		move.b	(a2)+,cFreq+1(a1)	; ''

	if safe=1		; NOTE: You can remove this check, but its unsafe to do so!
		btst	#ctbDAC,cType(a1)	; check if this is a DAC channel
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
		moveq	#0,d4
		move.b	(a2)+,d4		; load note from tracker to d4
		add.b	cPitch(a1),d4		; add pitch offset to note
		add.w	d4,d4			; double offset (each entry is a word)

		lea	dFreqDAC(pc),a4		; load DAC frequency table to a4
		move.w	(a4,d4.w),cFreq(a1)	; load and save the requested frequency

	if safe=1		; NOTE: You can remove this check, but its unsafe to do so!
		btst	#ctbDAC,cType(a1)	; check if this is a DAC channel
		bne.s	.rts			; if so, branch
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
		addq.w	#2,a2			; skip over jump offset
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for calling a tracker subroutine
; ---------------------------------------------------------------------------

dcCall:
	if safe=1
		AMPS_Debug_dcCall1		; check if this channel supports the stack
	endif

		moveq	#0,d4
		move.b	cStack(a1),d4		; get channel stack pointer
		subq.b	#4,d4			; allocate space for another routine

	if safe=1
		AMPS_Debug_dcCall2		; check if we overflowed the space
	endif
		move.l	a2,(a1,d4.w)		; save current address in stack
		move.b	d4,cStack(a1)		; save stack pointer
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for jumping to another tracker location
; ---------------------------------------------------------------------------

dcJump:
	dREAD_WORD a2, d4			; read a word from tracker to d4
		adda.w	d4,a2			; offset tracker address by d4
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for handling loops
; ---------------------------------------------------------------------------

dcLoop:
		moveq	#0,d4
		move.b	(a2)+,d4		; load loop index from tracker to d4
	if safe=1
		AMPS_Debug_dcLoop		; check if loop index is valid
	endif

		tst.b	cLoop(a1,d4.w)		; check the loop counter
		bne.s	.loopok			; if nonzero, branch
		move.b	2(a2),cLoop(a1,d4.w)	; reload loop counter

.loopok
		subq.b	#1,cLoop(a1,d4.w)	; decrease loop counter
		bne.s	dcJump			; if not 0, jump to routine
		addq.w	#3,a2			; skip over jump offset
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for initializing portamento
; ---------------------------------------------------------------------------

dcPortamento:
	if FEATURE_PORTAMENTO
		move.b	(a2)+,cPortaSpeed(a1)	; load the portamento speed value
		bne.s	.rts			; if non-zero, branch
		clr.w	cPortaFreq(a1)		; clear portamento frequency
.rts		rts

	elseif safe=1
		AMPS_Debug_dcPortamento		; display an error if disabled
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for initializing modulation
; ---------------------------------------------------------------------------

dcMod68K:
	if FEATURE_MODULATION
		move.l	a2,cMod(a1)		; set modulation data address
		clr.w	cModFreq(a1)		; reset modulation frequency offset to 0
		move.b	(a2)+,cModSpeed(a1)	; load modulation speed from tracker to channel

		move.b	(a2)+,d3		; load modulation step count from tracker to d3
		lsr.b	#1,d3			; halve it
		move.b	d3,cModCount(a1)	; save as modulation step count to channel

		move.b	(a2)+,cModDelay(a1)	; load modulation delay from tracker to channel
		move.b	(a2)+,cModStep(a1)	; load modulation step offset from tracker to channel
	; continue to enabling modulation

	elseif safe=1
		AMPS_Debug_dcModulate		; display an error if disabled
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for enabling and disabling modulation
; ---------------------------------------------------------------------------

dcModOn:
	if FEATURE_MODULATION
		bset	#cfbMod,(a1)		; enable modulation
		rts

	elseif safe=1
		AMPS_Debug_dcModulate		; display an error if disabled
	endif

dcModOff:
	if FEATURE_MODULATION
		bclr	#cfbMod,(a1)		; disable modulation
		rts

	elseif safe=1
		AMPS_Debug_dcModulate		; display an error if disabled
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for returning from tracker subroutine
; ---------------------------------------------------------------------------

dcReturn:
	if safe=1
		AMPS_Debug_dcReturn1		; check if this channel supports the stack
	endif
		moveq	#0,d3
		move.b	cStack(a1),d3		; get channel stack pointer
		movea.l	(a1,d3.w),a2		; load the address to return to

		addq.w	#2,a2			; skip the call address parameter
		addq.b	#4,d3			; deallocate stack space
		move.b	d3,cStack(a1)		; save stack pointer

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
; Tracker command for setting volume envelope ID
; ---------------------------------------------------------------------------

dcVolEnv:
	if FEATURE_DACFMVOLENV=0
	if safe=1
		AMPS_Debug_dcVolEnv		; display an error if an invalid channel attempts to load a volume envelope
	endif
	endif

		move.b	(a2)+,cVolEnv(a1)	; load the volume envelope ID
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting modulation envelope ID
; ---------------------------------------------------------------------------

dcModEnv:
	if FEATURE_MODENV
		move.b	(a2)+,cModEnv(a1)	; load the modulation envelope ID
		rts

	elseif safe=1
		AMPS_Debug_dcModEnv		; display an error if disabled
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for loading a backed up track
; ---------------------------------------------------------------------------

dcBackup:
	if FEATURE_BACKUP
		addq.l	#4,sp			; stop the other channels from playing
		btst	#mfbBacked,mFlags.w	; check if there is a backed up track
		beq.w	dPlaySnd_Stop		; if not, just stop all music instead....
		jsr	dPlaySnd_Stop(pc)	; gotta do it anyway tho but continue below
; ---------------------------------------------------------------------------
; The reason we do fade in right here instead of later, is so we can update
; the FM voices with correct volume, no need to update volume later...
; ---------------------------------------------------------------------------

		lea	dFadeInDataLog(pc),a4	; prepare stock fade in program to a4
		jsr	dLoadFade(pc)		; initiate fade in

		move.l	mBackTempoMain.w,mTempoMain.w; restore tempo settings
		move.l	mBackVctMus.w,mVctMus.w	; restore voice table address

		lea	mBackUpLoc.w,a4		; load source address to a4
		lea	mBackUpArea.w,a3	; load destination address to a3
		move.w	#(mSFXDAC1-mDAC1)/4-1,d4; load backup size to d4

.backup
		move.l	(a4),(a3)+		; restore data for each channel
		clr.l	(a4)+			; clear back-up RAM
		dbf	d4,.backup		; loop for each longword

	if (mSFXDAC1-mDAC1)&2
		move.w	(a4),(a3)+		; restore data for each channel
		clr.w	(a4)+			; clear back-up RAM
	endif
; ---------------------------------------------------------------------------
; We clear the PCM 1 & 2 volume tables to 0 to prevent any sound being
; accidentally generated. This costs a bit of CPU time but ensures that
; the volume is forced to minimum and there is no chance any wrong noise
; plays before fade in starts
; ---------------------------------------------------------------------------

		lea	dZ80+PCM_Volume1,a4	; get Z80 volume table to a4
		moveq	#($200/16)-1,d3		; get repeat count to d3 (clear both tables!)
		moveq	#0,d4			; prepare 0
	stopZ80

.volloop
	rept 16					; clear 1 byte at a time
		move.b	d4,(a4)+		; but! Clear 16 bytes per loop!
	endr					; this actually saves some cycles
		dbf	d3,.volloop		; loop for all bytes

		moveq	#$7F,d3			; prepare max volume to d2
		move.b	d3,dZ80+PCM1_VolumeCur+1; set PCM1 volume as mute
		move.b	d3,dZ80+PCM2_VolumeCur+1; set PCM2 volume as mute
	startZ80
; ---------------------------------------------------------------------------
; The FM instruments need to be updated! Since this process includes volume
; updates, they do not need to be done later...
; ---------------------------------------------------------------------------

		lea	mFM1.w,a1		; start at music FM1
		moveq	#Mus_FM-1,d0		; load FM channel count to d0

.fmloop
		tst.b	(a1)			; check if channel is running
		bpl.s	.nofm			; if not, skip it

		moveq	#0,d4
		move.b	cVoice(a1),d4		; load FM voice ID of the channel to d4
		bsr.s	dUpdateVoiceFM		; update FM voice for each channel

.nofm
		add.w	#cSize,a1		; advance to next channel
		dbf	d0,.fmloop		; loop for all FM channels
; ---------------------------------------------------------------------------
; Special logic to handle PSG4
; ---------------------------------------------------------------------------

		move.b	#$FF,dPSG		; mute PSG4
		cmp.b	#ctPSG4,mPSG3+cType.w	; check if PSG3 channel is in PSG4 mode
		bne.s	locret_Backup		; if not, skip
		move.b	mPSG3+cStatPSG4.w,dPSG	; update PSG4 status to PSG port

	elseif safe=1
		AMPS_Debug_dcBackup
	endif

locret_Backup:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for changing voice, volume envelope or sample
; ---------------------------------------------------------------------------

dcVoice:
		moveq	#0,d4
		move.b	(a2)+,d4		; load voice/sample/volume envelope from tracker to d4
		move.b	d4,cVoice(a1)		; save to channel

	if FEATURE_DACFMVOLENV
		if safe=1
			AMPS_Debug_dcVoiceEnv	; warn user if DAC & FM volume envelopes are enabled. This behaviour can be removed
		endif				; for better integration of FM/DAC tracker code with PSG channels.
	else
		tst.b	cType(a1)		; check if this is a PSG channel
		bmi.s	locret_Backup		; if is, skip
	endif

		btst	#ctbDAC,cType(a1)	; check if this is a DAC channel
		bne.s	locret_Backup		; if is, skip

		btst	#cfbInt,(a1)		; check if channel is interrupted by SFX
		bne.s	locret_Backup		; if is, skip

	; continue to send FM voice
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine for sending the FM voice to YM2612
; This routine is speed optimized in a way that allows Dual PCM
; to only be stopped for as long as it must be. This will waste
; some cycles for 68000, but it will help improve DAC quality.
; ---------------------------------------------------------------------------	;

; input:
;   a1 - Channel to operate on
;   d4 - Voice ID to use
; thrash:
;   a2 - TL register table
;   a4 - Used for voice data address
;   a5 - Used to write data to stack so we can write it to Z80 later
;   d1 - Used for dbf counters
;   d2 - Used to store the channel type
;   d3 - Used to calculate registers
;   d4 - Used to store feedback&algorithm
;   d5 - Used for TL calculations
;   d6 - Used for modulator offset
; ---------------------------------------------------------------------------

WriteReg    macro    offset, reg
.offs =    \offset

    rept narg-1
        move.b    (a4)+,(a5)+        ; write value to buffer
        if \reg<$80
            moveq    #\reg,d3    ; load register to d3
        else
            moveq    #$FFFFFF00|\reg,d3; load register to d3
        endif

        if .offs>1
            addq.w    #.offs-1,a4    ; offset a4 by specific amount
        endif
        or.b    d2,d3            ; add channel offset to register
        move.b    d3,(a5)+        ; write register to buffer
    shift
    endr
    endm

dUpdateVoiceFM:
			move.l	a2,-(sp)		; save the tracker address to stack
	dCALC_BANK	0			; get the voice table address to a4
	dCALC_VOICE				; get address of the specific voice to a4
		sub.w	#(VoiceRegs+1)*2,sp	; prepapre space in the stack
		move.l	sp,a5			; copy pointer to the free space to a5

		move.b	cType(a1),d2		; load channel type to d2
		and.b	#3,d2			; keep in range

		move.b	(a4)+,d4		; load feedback and algorithm to d4
		move.b	d4,(a5)+		; save it to free space
		moveq	#$FFFFFFB0,d3		; YM command: Algorithm & FeedBack
		or.b	d2,d3			; add channel offset to register
		move.b	d3,(a5)+		; write register to buffer

	WriteReg	0, $30, $38, $34, $3C	; Detune, Multiple
	WriteReg	0, $50, $58, $54, $5C	; Rate Scale, Attack Rate
	WriteReg	0, $60, $68, $64, $6C	; Decay 1 Rate
	WriteReg	0, $70, $78, $74, $7C	; Decay 2 Rate
	WriteReg	0, $80, $88, $84, $8C	; Decay 1 level, Release Rate
	WriteReg	0, $90, $98, $94, $9C	; SSG-EG

		moveq	#4-1,d1			; prepare 4 operators to d1
		move.b	cVolume(a1),d3		; load FM channel volume to d3

	if FEATURE_SFX_MASTERVOL=0
		cmpa.w	#mSFXDAC1,a1		; is this a SFX channel
		bhs.s	.noover			; if so, do not add master volume!
	endif

		add.b	mMasterVolFM.w,d3	; add master FM volume to d3
		bpl.s	.noover			; if volume did not overflow, skip
		moveq	#$7F,d3			; force FM volume to silence

.noover
	if FEATURE_UNDERWATER
		btst	#mfbWater,mFlags.w	; check if underwater mode is enabled
		beq.s	.nouw			; if not, skip
		lea	dUnderwaterTbl(pc),a2	; get underwater table to a2

		and.w	#7,d4			; mask out everything but the algorithm
		move.b	(a2,d4.w),d4		; get the value from table
		move.b	d4,d6			; copy to d6
		and.w	#7,d4			; mask out extra stuff

		add.b	d4,d3			; add algorithm to Total Level carrier offset
		bpl.s	.uwdone			; if volume did not overflow, skip
		moveq	#$7F,d3			; force FM volume to silence
		bra.s	.uwdone

.nouw
		moveq	#0,d6			; no underwater 4 u

.uwdone
	endif

		lea	dOpTLFM(pc),a2		; load TL registers to a2

.tlloop
		move.b	(a4)+,d5		; get Total Level value from voice to d5
		bpl.s	.noslot			; if slot operator bit was not set, branch

		add.b	d3,d5			; add carrier offset to loaded value
		bmi.s	.slot			; if we did not overflow, branch
		moveq	#-1,d5			; cap to silent volume
	if FEATURE_UNDERWATER
		bra.s	.slot
	endif

.noslot
	if FEATURE_UNDERWATER
		add.b	d6,d5			; add modulator offset to loaded value
	endif

.slot
		move.b	d5,(a5)+		; save the Total Level value
		move.b	(a2)+,d4		; load register to d4
		or.b	d2,d4			; add channel offset to register
		move.b	d4,(a5)+		; write register to buffer
		dbf	d1,.tlloop		; repeat for each Total Level operator

	if safe=1
		AMPS_Debug_UpdVoiceFM		; check if the voice was valid
	endif

		move.b	cPanning(a1),(a5)+	; copy panning value to free space
		moveq	#$FFFFFFB4,d3		; YM command: Panning & LFO
		or.b	d2,d3			; add channel offset to register
		move.b	d3,(a5)+		; write register to buffer

		move.b	cType(a1),d2		; load FM channel type to d2
		lsr.b	#1,d2			; halve part value
		and.b	#2,d2			; clear extra bits away

.ptok
		move.l	sp,a5			; copy free space pointer to a5 again
	if safe=1
		AMPS_Debug_CuePtr 0		; make sure cue is valid
	endif
	StopZ80					; wait for Z80 to stop

.write
	rept VoiceRegs+1
		move.b	d2,(a0)+		; select YM port to access (4000 or 4002)
		move.b	(a5)+,(a0)+		; write values
		move.b	(a5)+,(a0)+		; write registers
	endr

	;	st	(a0)			; mark as end of the cue
	StartZ80				; enable Z80 execution
		move.l	a5,sp			; fix stack pointer
		bclr	#cfbVol,(a1)		; reset volume update request flag
		move.l	(sp)+,a2		; load the tracker address from stack
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for stopping the current channel
; ---------------------------------------------------------------------------

dcStop:
		and.b	#$FF-(1<<cfbHold)-(1<<cfbRun),(a1); clear hold and running tracker flags
	dStopChannel	0			; stop channel operation

		cmpa.w	#mSFXFM3,a1		; check if this is a SFX channel
		blo.s	.exit			; if not, skip all this mess
		clr.b	cPrio(a1)		; clear channel priority

		lea	dSFXoverList(pc),a4	; load quick reference to the SFX override list to a4
		moveq	#0,d3
		move.b	cType(a1),d3		; load channel type to d3
		bmi.s	.psg			; if this is a PSG channel, branch
		move.w	a1,-(sp)		; push channel pointer

		and.w	#$07,d3			; get only the necessary bits to d3
		subq.w	#2,d3			; since FM 1 and 2 are not used, skip over them
		add.w	d3,d3			; double offset (each entry is 1 word in size)
		move.w	(a4,d3.w),a1		; get the SFX channel we were overriding

		tst.b	(a1)			; check if that channel is running a tracker
		bpl.s	.fixch			; if not, branch

		bset	#cfbVol,(a1)		; set update volume flag (cleared by dUpdateVoiceFM)
		bclr	#cfbInt,(a1)		; reset sfx override flag
		btst	#ctbDAC,cType(a1)	; check if the channel is a DAC channel
		bne.s	.fixch			; if yes, skip

		bset	#cfbRest,(a1)		; Set channel resting flag
		moveq	#0,d4
		move.b	cVoice(a1),d4		; load FM voice ID of the channel to d4
		jsr	dUpdateVoiceFM(pc)	; send FM voice for this channel

.fixch
		move.w	(sp)+,a1		; pop the current channel
.exit
		addq.l	#2,(sp)			; go to next channel immediately
		rts
; ---------------------------------------------------------------------------
; There is nothing that would break even if the channel is not
; running a tracker, so we do not bother checking
; ---------------------------------------------------------------------------

.psg
		lsr.b	#4,d3			; make it easier to reference the right offset in the table
		movea.w	(a4,d3.w),a4		; get the SFX channel we were overriding
		tst.b	(a4)			; check if that channel is running a tracker
		bpl.s	.exit			; if not, branch

		bclr	#cfbInt,(a4)		; channel is not interrupted anymore
		bset	#cfbRest,(a4)		; reset sfx override flag

		cmp.b	#ctPSG4,cType(a4)	; check if this channel is in PSG4 mode
		bne.s	.exit			; if not, skip
		move.b	cStatPSG4(a4),dPSG.l	; update PSG4 status to PSG port
		bra.s	.exit
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for enabling LFO
;
; input:
;   a1 - Channel to operate on
; thrash:
;   a2 - Used for envelope data address
;   d1 - Used ato store YM address
;   d2 - Used as dbf counter
;   d3 - Used to detect enabled operators
;   d4 - Various uses
;   d5 - Used for channel calculation
;   d6 - Used for channel calculation
; ---------------------------------------------------------------------------

dcsLFO:
		moveq	#0,d4
		move.b	cVoice(a1),d4		; load FM voice ID of the channel to d4
	dCALC_BANK 9				; get the voice table address to a4
	dCALC_VOICE					; get address of the specific voice to a4

		move.b	(a2),d3			; load LFO enable operators to d3
		lea	dAMSEn_Ops(pc),a5	; load Decay 1 Rate address table to a5
		moveq	#4-1,d2			; prepare 4 operators to d2
	CheckCue				; check that cue is valid

	InitChYM				; prepare to write Channel-specific YM registers
	stopZ80
		btst	#cfbInt,(a1)		; check if channel is interrupted
		bne.s	.skipLFO		; if so, skip loading LFO

.decayloop
		move.b	(a4)+,d4		; get Decay 1 Level value from voice to d4
		move.b	(a5)+,d1		; load YM address to write to d1

		add.b	d3,d3			; check if LFO is enabled for this channel
		bcc.s	.noLFO			; if not, skip
		or.b	#$80,d4			; set enable LFO bit
	WriteChYM	d1, d4			; Decay 1 level: Decay 1 + AMS enable bit

.noLFO
		dbf	d2,.decayloop		; repeat for each Decay 1 Level operator

.skipLFO
	WriteYM1	#$22, (a2)+		; LFO: LFO frequency and enable
		move.b	(a2)+,d3		; load AMS, FMS & Panning from tracker
		move.b	d3,cPanning(a1)		; save to channel panning

		btst	#cfbInt,(a1)		; check if channel is interrupted
		bne.s	.skipPan		; if so, skip panning
	WriteChYM	#$B4, d3		; Panning & LFO: AMS + FMS + Panning

.skipPan
	;	st	(a0)			; write end marker
	startZ80
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for resetting condition
; ---------------------------------------------------------------------------

dcResetCond:
		bclr	#cfbCond,(a1)		; reset condition flag
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for writing to communications flags
; ---------------------------------------------------------------------------

dcsComm:
		lea	mComm.w,a4		; get communications array to a4
		moveq	#0,d3
		move.b	(a2)+,d3		; load byte number to write from tracker
		move.b	(a2)+,(a4,d3.w)		; load vaue from tracker to communications byte
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; RAM addresses for special condition code
; ---------------------------------------------------------------------------

dcCondRegTable:
	dc.w ConsoleRegion, mFlags	; 0
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
		move.b	(a2)+,d3		; get value from tracker
		move.b	d3,d4			; copy to d4

		and.w	#$F,d3			; get RAM table offset to d3
		add.w	d3,d3			; double it (each entry is 1 word)
		move.w	dcCondRegTable(pc,d3.w),d3; get data to read from
		bmi.s	.gotit			; branch if if was a RAM address
		add.w	a1,d3			; else it was a channel offset

.gotit
		move.w	d3,a4			; get the desired address from d3 to a4
		move.b	(a4),d3			; read byte from it
		bra.s	dcCondCom
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for checking communications bytes
; ---------------------------------------------------------------------------

dcCondJump	macro x
	\x	.false
	rts
     endm

dcCond:
		lea	mComm.w,a4		; get communications array to a4
		move.b	(a2)+,d3		; load condition and offset from tracker to d3
		move.b	d3,d4			; copy to d4
		and.w	#$F,d3			; get offset only
		move.b	(a4,d3.w),d3		; load value from communcations byte to d3

dcCondCom:
		bclr	#cfbCond,(a1)		; set condition to true
		and.w	#$F0,d4			; get condition value only
		lsr.w	#2,d4			; shift 2 bits down (each entry is 4 bytes large)
		cmp.b	(a2)+,d3		; check value against tracker byte
		jmp	.cond(pc,d4.w)		; handle conditional code
; ===========================================================================
; ---------------------------------------------------------------------------
; Code for setting the condition flag
; ---------------------------------------------------------------------------

.false
		bset	#cfbCond,(a1)		; set condition to false

.cond	rts			; T
	rts
	dcCondJump bra.s	; F
	dcCondJump bls.s	; HI
	dcCondJump bhi.s	; LS
	dcCondJump blo.s	; HS/CC
	dcCondJump bhs.s	; LO/CS
	dcCondJump beq.s	; NE
	dcCondJump bne.s	; EQ
	dcCondJump bvs.s	; VC
	dcCondJump bvc.s	; VS
	dcCondJump bmi.s	; PL
	dcCondJump bpl.s	; MI
	dcCondJump blt.s	; GE
	dcCondJump bge.s	; LT
	dcCondJump ble.s	; GT
	dcCondJump bgt.s	; LE
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
