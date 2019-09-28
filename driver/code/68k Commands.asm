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
		move.b	(a4)+,d5		; get next command byte
		jmp	.meta(pc,d5.w)		; jump to appropriate meta handler

.falsecomm
		jmp	.false-$80(pc,d5.w)	; jump to appropriate handler (false command)
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
	addq.w	#1,a4
	rts			; E5 - Set channel tick multiplier to xx (TICK_MULT - TMULT_CUR)
	addq.w	#1,a4
	rts			; E6 - Set global tick multiplier to xx (TICK_MULT - TMULT_ALL)
	bra.w	dcHold		; E7 - Do not allow note on/off for next note (HOLD)
	addq.w	#1,a4
	rts			; E8 - Add xx to music tempo (TEMPO - TEMPO_ADD)
	addq.w	#1,a4
	rts			; E9 - Set music tempo to xx (TEMPO - TEMPO_SET)
	addq.w	#1,a4
	rts			; EA - Set Voice/voice/sample to xx (INSTRUMENT - INS_C_FM / INS_C_PSG / INS_C_DAC)
	rts
	rts			; EB - Use sample DAC mode (DAC_MODE - DACM_SAMP)
	rts
	rts			; EC - Use pitch DAC mode (DAC_MODE - DACM_NOTE)
	addq.w	#1,a4
	rts			; ED - Add xx to channel volume (VOLUME - VOL_CN_FM / VOL_CN_PSG / VOL_CN_DAC)
	addq.w	#1,a4
	rts			; EE - Set channel volume to xx (VOLUME - VOL_CN_ABS)
	addq.w	#1,a4
	rts			; EF - Set LFO (SET_LFO - LFO_AMSEN)
	addq.w	#4,a4
	rts			; F0 - Modulation (MOD_SETUP)
	addq.w	#1,a4
	rts			; F1 - Portamento enable/disable flag (PORTAMENTO)
	addq.w	#1,a4
	rts			; F2 - Set volume envelope to xx (INSTRUMENT - INS_C_PSG) (FM_VOLENV / DAC_VOLENV)
	addq.w	#1,a4
	rts			; F3 - Set modulation envelope to xx (MOD_ENV - MENV_GEN)
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
; Tracker command for initializing portamento
; ---------------------------------------------------------------------------

dcPortamento:
	if FEATURE_PORTAMENTO
		move.b	(a4)+,cPortaSpeed(a5)	; load the portamento speed value
		bne.s	.rts			; if non-zero, branch
		clr.w	cPortaFreq(a5)		; clear portamento frequency
.rts		rts
	else
		AMPS_Debug_dcPortamento		; display an error if disabled
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for initializing modulation
; ---------------------------------------------------------------------------

dcMod68K:
	if FEATURE_MODULATION
		move.l	a4,cMod(a5)		; set modulation data address
		move.b	(a4)+,cModDelay(a5)	; load modulation delay from tracker to channel
		move.b	(a4)+,cModSpeed(a5)	; load modulation speed from tracker to channel
		move.b	(a4)+,cModStep(a5)	; load modulation step offset from tracker to channel

		move.b	(a4)+,d0		; load modulation step count from tracker to d0
		lsr.b	#1,d0			; halve it
		move.b	d0,cModCount(a5)	; save as modulation step count to channel
		clr.w	cModFreq(a5)		; reset modulation frequency offset to 0
	; continue to enabling modulation

	else
		AMPS_Debug_dcModulate		; display an error if disabled
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for enabling and disabling modulation
; ---------------------------------------------------------------------------

dcModOn:
	if FEATURE_MODULATION
		bset	#cfbMod,(a5)		; enable modulation
		rts
	else
		AMPS_Debug_dcModulate		; display an error if disabled
	endif

dcModOff:
	if FEATURE_MODULATION
		bclr	#cfbMod,(a5)		; disable modulation
		rts
	else
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
; Tracker command for setting volume envelope ID
; ---------------------------------------------------------------------------

dcVolEnv:
	if FEATURE_DACFMVOLENV=0
	if safe=1
		AMPS_Debug_dcVolEnv		; display an error if an invalid channel attempts to load a volume envelope
	endif
	endif

		move.b	(a4)+,cVolEnv(a5)	; load the volume envelope ID
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting modulation envelope ID
; ---------------------------------------------------------------------------

dcModEnv:
	if FEATURE_MODENV
		move.b	(a4)+,cModEnv(a5)	; load the modulation envelope ID
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

		lea	dFadeInDataLog(pc),a1	; prepare stock fade in program to a1
		jsr	dLoadFade(pc)		; initiate fade in

		move.l	mBackTempoMain.w,mTempoMain.w; restore tempo settings
		move.l	mBackVctMus.w,mVctMus.w	; restore voice table address

		lea	mDAC1.w,a2		; load source address to a0
		lea	mBackDAC1.w,a1		; load destination address to a1
		move.w	#(mSFXDAC1-mDAC1)/4-1,d0; load backup size to d0

.backup
		move.l	(a1),(a2)+		; restore data for each channel
		clr.l	(a1)+			; clear back-up RAM
		dbf	d0, .backup		; loop for each longword

	if (mSFXDAC1-mDAC1)&2
		move.w	(a1),(a2)+		; restore data for each channel
		clr.w	(a1)+			; clear back-up RAM
	endif
; ---------------------------------------------------------------------------
; We clear the PCM 1 & 2 volume tables to 0 to prevent any sound being
; accidentally generated. This costs a bit of CPU time but ensures that
; the volume is forced to minimum and there is no chance any wrong noise
; plays before fade in starts
; ---------------------------------------------------------------------------

		lea	dZ80+PCM_Volume1,a1	; get Z80 volume table to a1
		moveq	#$7F,d2			; prepare max volume to d1
		moveq	#($200/16)-1,d0		; get repeat count to d1 (clear both tables!)
		moveq	#0,d1			; prepare 0
	stopZ80

.volloop
	rept 16					; clear 1 byte at a time
		move.b	d1,(a1)+		; but! Clear 16 bytes per loop!
	endr					; this actually saves some cycles
		dbf	d0,.volloop		; loop for all bytes

		move.b	d2,dZ80+PCM1_VolumeCur+1; set PCM1 volume as mute
		move.b	d2,dZ80+PCM2_VolumeCur+1; set PCM2 volume as mute
	startZ80
; ---------------------------------------------------------------------------
; The FM instruments need to be updated! Since this process includes volume
; updates, they do not need to be done later...
; ---------------------------------------------------------------------------

		lea	mFM1.w,a5		; start at music FM1
		moveq	#Mus_FM-1,d7		; load FM channel count to d7

.fmloop
		tst.b	(a5)			; check if channel is running
		bpl.s	.nofm			; if not, skip it

		moveq	#0,d0
		move.b	cVoice(a5),d0		; load FM voice ID of the channel to d0
		move.l	mVctMus.w,a1		; load music voice table to a1
		bsr.s	dUpdateVoiceFM		; update FM voice for each channel

.nofm
		add.w	#cSize,a5		; advance to next channel
		dbf	d7,.fmloop		; loop for all FM channels
; ---------------------------------------------------------------------------
; Special logic to handle PSG4
; ---------------------------------------------------------------------------

		move.b	#$FF,dPSG		; mute PSG4
		cmp.b	#ctPSG4,mPSG3+cType.w	; check if PSG3 channel is in PSG4 mode
		bne.s	locret_Backup		; if not, skip
		move.b	mPSG3+cStatPSG4.w,dPSG	; update PSG4 status to PSG port
	else
		AMPS_Debug_dcBackup
	endif

locret_Backup:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for changing voice, volume envelope or sample
; ---------------------------------------------------------------------------

dcVoice:
		moveq	#0,d0
		move.b	(a4)+,d0		; load voice/sample/volume envelope from tracker to d0
		move.b	d0,cVoice(a5)		; save to channel

	if FEATURE_DACFMVOLENV
		if safe=1
			AMPS_Debug_dcVoiceEnv	; warn user if DAC & FM volume envelopes are enabled. This behaviour can be removed
		endif				; for better integration of FM/DAC tracker code with PSG channels.
	else
		tst.b	cType(a5)		; check if this is a PSG channel
		bmi.s	locret_Backup		; if is, skip
	endif

		btst	#ctbDAC,cType(a5)	; check if this is a DAC channel
		bne.s	locret_Backup		; if is, skip

		btst	#cfbInt,(a5)		; check if channel is interrupted by SFX
		bne.s	locret_Backup		; if is, skip
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

		moveq	#4-1,d5			; prepare 4 operators to d5
		moveq	#0,d6			; reset the modulator offset

		move.b	cVolume(a5),d3		; load FM channel volume to d3
		add.b	mMasterVolFM.w,d3	; add master FM volume to d3
		bpl.s	.noover			; if volume did not overflow, skip
		moveq	#$7F,d3			; force FM volume to silence

.noover
	if FEATURE_UNDERWATER
		btst	#mfbWater,mFlags.w	; check if underwater mode is enabled
		beq.s	.tlloop			; if not, skip
		move.b	d4,d6			; copy algorithm and feedback to d6
		and.w	#7,d6			; mask out everything but the algorithm
		add.b	d6,d3			; add algorithm to Total Level carrier offset
		bpl.s	.noover2		; if volume did not overflow, skip
		moveq	#$7F,d3			; force FM volume to silence

.noover2
		move.b	d4,d6			; set algorithm and feedback to modulator offset
	endif

.tlloop
		move.b	(a1)+,d1		; get Total Level value from voice to d1
		bpl.s	.noslot			; if slot operator bit was not set, branch

		add.b	d3,d1			; add carrier offset to loaded value
		bmi.s	.slot			; if we did not overflow, branch
		moveq	#-1,d1			; cap to silent volume
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

		move.b	(a3)+,d4		; load YM command
		or.b	d3,d4			; add the channel offset to command
		move.b	d4,(a0)+		; save to Z80 cue
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
	dStopChannel	0			; stop channel operation
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
