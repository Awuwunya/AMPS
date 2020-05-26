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
		bra.w	dcPan			; E0 - Panning, AMS, FMS (PANAFMS - PAFMS_PAN)
		bra.w	dcsDetune		; E1 - Set channel frequency displacement to xx (DETUNE_SET)
		bra.w	dcaDetune		; E2 - Add xx to channel frequency displacement (DETUNE)
		bra.w	dcsTransp		; E3 - Set channel pitch to xx (TRANSPOSE - TRNSP_SET)
		bra.w	dcaTransp		; E4 - Add xx to channel pitch (TRANSPOSE - TRNSP_ADD)
		bra.w	dcsTmulCh		; E5 - Set channel tick multiplier to xx (TICK_MULT - TMULT_CUR)
		bra.w	dcsTmul			; E6 - Set global tick multiplier to xx (TICK_MULT - TMULT_ALL)
		bra.w	dcHold			; E7 - Do not allow note on/off for next note (HOLD)
		bra.w	dcVoice			; E8 - Set Voice/sample to xx (INSTRUMENT - INS_C_FM / INS_C_DAC)
		bra.w	dcsTempoShoes		; E9 - Set music speed shoes tempo to xx (TEMPO - TEMPO_SET_SPEED)
		bra.w	dcsTempo		; EA - Set music tempo to xx (TEMPO - TEMPO_SET)
		bra.w	dcSampDAC		; EB - Use sample DAC mode (DAC_MODE - DACM_SAMP)
		bra.w	dcPitchDAC		; EC - Use pitch DAC mode (DAC_MODE - DACM_NOTE)
		bra.w	dcaVolume		; ED - Add xx to channel volume (VOLUME - VOL_CN_FM / VOL_CN_PSG / VOL_CN_DAC)
		bra.w	dcsVolume		; EE - Set channel volume to xx (VOLUME - VOL_CN_ABS)
		bra.w	dcsLFO			; EF - Set LFO (SET_LFO - LFO_AMSEN)
		bra.w	dcMod68K		; F0 - Modulation (MOD_SETUP)
		bra.w	dcPortamento		; F1 - Portamento enable/disable flag (PORTAMENTO)
		bra.w	dcVolEnv		; F2 - Set volume envelope to xx (INSTRUMENT - INS_C_PSG) (FM_VOLENV / DAC_VOLENV)
		bra.w	dcModEnv		; F3 - Set modulation envelope to xx (MOD_ENV - MENV_GEN)
		bra.w	dcCont			; F4 - Do a continuous SFX loop (CONT_SFX)
		bra.w	dcStop			; F5 - End of channel (TRK_END - TEND_STD)
		bra.w	dcJump			; F6 - Jump to xxxx (GOTO)
		bra.w	dcLoop			; F7 - Loop back to zzzz yy times, xx being the loop index (LOOP)
		bra.w	dcCall			; F8 - Call pattern at xxxx, saving return point (GOSUB)
		bra.w	dcReturn		; F9 - Return (RETURN)
		bra.w	dcsComm			; FA - Set communications byte yy to xx (SET_COMM - SPECIAL)
		bra.w	dcCond			; FB - Get comms byte y, and compare zz using condition x (COMM_CONDITION)
		bra.w	dcResetCond		; FC - Reset condition (COMM_RESET)
		bra.w	dcGate			; FD - Stop note after xx frames (NOTE_STOP - NSTOP_NORMAL)
		bra.w	dcYM			; FE - YM command (YMCMD)
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
		bra.w	dcModOn			; FF 00 - Turn on Modulation (MOD_SET - MODS_ON)
		bra.w	dcModOff		; FF 04 - Turn off Modulation (MOD_SET - MODS_OFF)
		bra.w	dcsFreq			; FF 08 - Set channel frequency to xxxx (CHFREQ_SET)
		bra.w	dcsFreqNote		; FF 0C - Set channel frequency to note xx (CHFREQ_SET - CHFREQ_NOTE)
		bra.w	dcSpRev			; FF 10 - Increment spindash rev counter (SPINDASH_REV - SDREV_INC)
		bra.w	dcSpReset		; FF 14 - Reset spindash rev counter (SPINDASH_REV - SDREV_RESET)
		bra.w	dcaTempoShoes		; FF 18 - Add xx to music speed tempo (TEMPO - TEMPO_ADD_SPEED)
		bra.w	dcaTempo		; FF 1C - Add xx to music tempo (TEMPO - TEMPO_ADD)
		bra.w	dcCondReg		; FF 20 - Get RAM table offset by y, and chk zz with cond x (COMM_CONDITION - COMM_SPEC)
		bra.w	dcSound			; FF 24 - Play another music/sfx (SND_CMD)
		bra.w	dcsModFreq		; FF 28 - Set modulation frequency to xxxx (MOD_SET - MODS_FREQ)
		bra.w	dcModReset		; FF 2C - Reset modulation data (MOD_SET - MODS_RESET)
		bra.w	dcSpecFM3		; FF 30 - Enable FM3 special mode (SPC_FM3)
		bra.w	dcFilter		; FF 34 - Set DAC filter bank. (DAC_FILTER)
		bra.w	dcBackup		; FF 38 - Load the last song from back-up (FADE_IN_SONG)
		bra.w	dcNoisePSG		; FF 3C - PSG4 mode to xx (PSG_NOISE - PNOIS_AMPS)

	if safe=1
		bra.w	dcFreeze		; FF 40 - Freeze CPU. Debug flag (DEBUG_STOP_CPU)
		bra.w	dcTracker		; FF 44 - Bring up tracker debugger at end of frame. Debug flag (DEBUG_PRINT_TRACKER)
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Command handlers for false condition execution
; ---------------------------------------------------------------------------

dcskip	macro amount
	if \amount=0
		rts				; save a few cycles by immediately returning
	else
		addq.w	#\amount,a2		; skip this amount of bytes
	endif
	rts
   endm

.false
		dcskip	1			; E0 - Panning, AMS, FMS (PANAFMS - PAFMS_PAN)
		dcskip	1			; E1 - Set channel frequency displacement to xx (DETUNE_SET)
		dcskip	1			; E2 - Add xx to channel frequency displacement (DETUNE)
		dcskip	1			; E3 - Set channel pitch to xx (TRANSPOSE - TRNSP_SET)
		dcskip	1			; E4 - Add xx to channel pitch (TRANSPOSE - TRNSP_ADD)
		dcskip	1			; E5 - Set channel tick multiplier to xx (TICK_MULT - TMULT_CUR)
		dcskip	1			; E6 - Set global tick multiplier to xx (TICK_MULT - TMULT_ALL)
		bra.w	dcHold			; E7 - Do not allow note on/off for next note (HOLD)
		dcskip	1			; E8 - Set Voice/sample to xx (INSTRUMENT - INS_C_FM / INS_C_DAC)
		dcskip	1			; E9 - Set music speed shoes tempo to xx (TEMPO - TEMPO_SET_SPEED)
		dcskip	1			; EA - Set music tempo to xx (TEMPO - TEMPO_SET)
		dcskip	0			; EB - Use sample DAC mode (DAC_MODE - DACM_SAMP)
		dcskip	0			; EC - Use pitch DAC mode (DAC_MODE - DACM_NOTE)
		dcskip	1			; ED - Add xx to channel volume (VOLUME - VOL_CN_FM / VOL_CN_PSG / VOL_CN_DAC)
		dcskip	1			; EE - Set channel volume to xx (VOLUME - VOL_CN_ABS)
		dcskip	1			; EF - Set LFO (SET_LFO - LFO_AMSEN)
		dcskip	4			; F0 - Modulation (MOD_SETUP)
		dcskip	1			; F1 - Portamento enable/disable flag (PORTAMENTO)
		dcskip	1			; F2 - Set volume envelope to xx (INSTRUMENT - INS_C_PSG) (FM_VOLENV / DAC_VOLENV)
		dcskip	1			; F3 - Set modulation envelope to xx (MOD_ENV - MENV_GEN)
		dcskip	0			; F4 - Do a continuous SFX loop (CONT_SFX)
		dcskip	0			; F5 - End of channel (TRK_END - TEND_STD)
		dcskip	2			; F6 - Jump to xxxx (GOTO)
		dcskip	4			; F7 - Loop back to zzzz yy times, xx being the loop index (LOOP)
		dcskip	2			; F8 - Call pattern at xxxx, saving return point (GOSUB)
		dcskip	0			; F9 - Return (RETURN)
		bra.w	dcsComm			; FA - Set communications byte yy to xx (SET_COMM - SPECIAL)
		bra.w	dcCond			; FB - Get comms byte y, and compare zz using condition x (COMM_CONDITION)
		bra.w	dcResetCond		; FC - Reset condition (COND_RESET)
		dcskip	1			; FD - Stop note after xx frames (NOTE_STOP - NSTOP_NORMAL
		dcskip	1			; FE - YM command (YMCMD)
		bra.w	.metacall		; FF - META
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for handling spindash revving
; The way spindash revving works, is it actually just increments a counter
; each time, and this counter is added into the channel pitch offset.
; ---------------------------------------------------------------------------

dcSpRev:
		move.b	mSpindash.w,d3		; load spindash rev counter to d3
		add.b	d3,cPitch(a1)		; add d3 to channel pitch offset

		cmp.b	#$C-1,d3		; check if this is the max pitch offset
		bhs.s	.rts			; if yes, skip
		addq.b	#1,mSpindash.w		; increment spindash rev counter

.rts
		rts
; ---------------------------------------------------------------------------

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

	; WARNING: FM6 is not properly implemented, so panning for FM6 WILL
	; break DAC channels and SFX DAC channels. Please be careful!

		moveq	#$37,d3			; prepare bits to keep
		and.b	cPanning(a1),d3		; and with channel LFO settings
		or.b	(a2)+,d3		; OR panning value
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
; Since the DAC channels have OR based panning behavior, we need this
; piece of code to update its panning
; ---------------------------------------------------------------------------

.dac
		move.b	mDAC1+cPanning.w,d3	; read panning value from music DAC1
		btst	#cfbInt,mDAC1+cFlags.w	; check if music DAC1 is interrupted by SFX
		beq.s	.nodacsfx		; if not, use music DAC1 panning
		move.b	mSFXDAC1+cPanning.w,d3	; read panning value from SFX DAC1

.nodacsfx
		or.b	mDAC2+cPanning.w,d3	; OR the panning value from music DAC2
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
		add.b	d3,cDetune(a1)		; Add to channel detune
		rts
; ---------------------------------------------------------------------------

dcsDetune:
		move.b	(a2)+,cDetune(a1)	; load detune offset from tracker to channel
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for changing channel volume
; ---------------------------------------------------------------------------

dcaVolume:
		move.b	(a2)+,d3		; load volume from tracker
		add.b	d3,cVolume(a1)		; add to channel volume
		bset	#cfbVol,(a1)		; set volume update flag
		rts
; ---------------------------------------------------------------------------

dcsVolume:
		move.b	(a2)+,cVolume(a1)	; load volume from tracker to channel
		bset	#cfbVol,(a1)		; set volume update flag
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting DAC to sample mode and resetting frequency
; ---------------------------------------------------------------------------

dcSampDAC:
		move.w	#$100,cFreq(a1)		; reset to default base frequency
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
; ---------------------------------------------------------------------------

dcsTmul:
		move.b	(a2)+,d3		; load tick multiplier from tracker to d3
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
; Tracker command for enabling or disabling note gate
; ---------------------------------------------------------------------------

dcGate:
	if safe=1
		AMPS_Debug_dcGate		; check if this channel has gate support
	endif

		move.b	(a2),cGateMain(a1)	; load note gate from tracker to channel
		move.b	(a2)+,cGateCur(a1)	; ''
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for changing channel pitch
; ---------------------------------------------------------------------------

dcaTransp:
		move.b	(a2)+,d3		; load pitch offset from tracker
		add.b	d3,cPitch(a1)		; add to channel pitch
		rts
; ---------------------------------------------------------------------------

dcsTransp:
		move.b	(a2)+,cPitch(a1)	; load pitch offset from tracker to channel
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for tempo control
; ---------------------------------------------------------------------------

dcsTempoShoes:
		move.b	(a2)+,d3		; load tempo value from tracker
		move.b	d3,mSpeed.w		; save as the speed shoes tempo
		move.b	d3,mSpeedAcc.w		; copy to speed shoes tempo accumulator
		rts
; ---------------------------------------------------------------------------

dcsTempo:
		move.b	(a2)+,d3		; load tempo value from tracker
		move.b	d3,mTempo.w		; save as the main tempo
		move.b	d3,mTempoAcc.w		; copy to current tempo
		rts
; ---------------------------------------------------------------------------

dcaTempoShoes:
		move.b	(a2)+,d3		; load tempo value from tracker
		add.b	d3,mSpeed.w		; add to the speed shoes tempo
		rts
; ---------------------------------------------------------------------------

dcaTempo:
		move.b	(a2)+,d3		; load tempo value from tracker
		add.b	d3,mTempo.w		; add to the main tempo
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for enabling or disabling PSG4 noise mode
; ---------------------------------------------------------------------------

dcNoisePSG:
		move.b	(a2)+,d3		; load PSG4 status to d3
	if safe=1
		AMPS_Debug_dcNoisePSG		; check if this is a PSG3 channel
	endif

		move.b	d3,cStatPSG4(a1)	; save status
		beq.s	.psg3			; if disabling PSG4 mode, branch
		move.b	#ctPSG4,cType(a1)	; make PSG3 act on behalf of PSG4
		move.b	d3,dPSG			; send command to PSG port
		rts
; ---------------------------------------------------------------------------

.psg3
		move.b	#ctPSG3,cType(a1)	; make PSG3 not act on behalf of PSG4
		move.b	#ctPSG4|$1F,dPSG	; send PSG4 mute command to PSG
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for playing another sound
; ---------------------------------------------------------------------------

dcSound:
		move.b	(a2)+,mQueue.w		; load sound ID from tracker to sound queue

Return_dcSound:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting DAC filter bank
; ---------------------------------------------------------------------------

dcFilter:
		move.b	(a2)+,d4		; load filter bank number from tracker
		jmp	dSetFilter(pc)		; update filter bank instructions to Z80 RAM
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for writing a YM command to YMCue
; ---------------------------------------------------------------------------

dcYM:
		move.b	(a2)+,d3		; load YM address from tracker to d3
		move.b	(a2)+,d1		; get command value from tracker to d1
		btst	#cfbInt,(a1)		; is this channel overridden by SFX?
		bne.s	Return_dcSound		; if so, skip

	CheckCue				; check that cue is valid
		cmp.b	#$30,d3			; is this register 00-2F?
		blo.s	.pt1			; if so, write to part 1 always

		move.b	d3,d4			; copy address to d4
		sub.b	#$A8,d4			; align $A8 with 0
		cmp.b	#$08,d4 		; is this register A8-AF?
		blo.s	.pt1			; if so, write to part 1 always

	InitChYM				; prepare to write to YM channel
	stopZ80
	WriteChYM	d3, d1			; write register to the channel
	;	st	(a0)			; write end marker
	startZ80
		rts
; ---------------------------------------------------------------------------

.pt1
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

	if safe=1
		btst	#ctbDAC,cType(a1)	; check if this is a DAC channel
		bne.s	.rts			; if so, branch
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

	if safe=1
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
		subq.b	#1,mContCtr.w		; decrease continous loop counter
		bpl.s	dcJump			; if positive, jump to routine
		clr.b	mContLast.w		; clear continous SFX ID
		addq.w	#2,a2			; skip over jump offset
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for calling a tracker routine
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
; Tracker command for jumping to another tracker routine
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
		bra.s	dcJump			; jump to routine
; ---------------------------------------------------------------------------

.loopok
		subq.b	#1,cLoop(a1,d4.w)	; decrease loop counter
		bne.s	dcJump			; if not 0, jump to routine
		addq.w	#3,a2			; skip over jump offset
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for returning from tracker routine
; ---------------------------------------------------------------------------

dcReturn:
	if safe=1
		AMPS_Debug_dcReturn1		; check if this channel supports the stack
	endif

		moveq	#4,d3			; deallocate stack space
		add.b	cStack(a1),d3		; add the channel stack pointer to d3
		move.b	d3,cStack(a1)		; save stack pointer

		movea.l	-4(a1,d3.w),a2		; load the address to return to
		addq.w	#2,a2			; skip the call address parameter

	if safe=1
		AMPS_Debug_dcReturn2		; check if we underflowed the space
	endif
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

.rts
		rts

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
		addq.w	#2,a2			; skip all the modulation data
		move.b	(a2)+,cModStep(a1)	; copy step offset
		move.b	(a2)+,cModDelay(a1)	; copy delay
	; continue to enabling modulation
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands for enabling and disabling modulation
; ---------------------------------------------------------------------------

dcModOn:
	if FEATURE_MODULATION
		bset	#cfbMod,(a1)		; enable modulation
		rts
	endif
; ---------------------------------------------------------------------------

dcModOff:
	if FEATURE_MODULATION
		bclr	#cfbMod,(a1)		; disable modulation
		rts
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting modulation frequency
; ---------------------------------------------------------------------------

dcsModFreq:
	if FEATURE_MODULATION
		move.b	(a2)+,cModFreq(a1)	; load modulating frequency from tracker to channel
		move.b	(a2)+,cModFreq+1(a1)	; ''
		rts
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for resetting modulation
; ---------------------------------------------------------------------------

dcModReset:
	if FEATURE_MODULATION
		move.l	cMod(a1),a4		; get modulation data address
		clr.w	cModFreq(a1)		; clear frequency offset
		move.b	(a4)+,cModSpeed(a1)	; copy speed

		move.b	(a4)+,d4		; get number of steps
		beq.s	.set			; branch if 0 specifically (otherwise this would cause a problem)
		lsr.b	#1,d4			; halve it
		bne.s	.set			; if result is not 0, branch
		moveq	#1,d4			; use 1 is the initial count, not 0!

.set
		move.b	d4,cModCount(a1)	; save as the current number of steps
		move.b	(a4)+,cModStep(a1)	; copy step offset
		move.b	(a4)+,cModDelay(a1)	; copy delay
		rts

	elseif safe=1
		AMPS_Debug_dcModulate		; display an error if disabled
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for initializing special FM3 mode
; ---------------------------------------------------------------------------

dcSpecFM3:
	if safe=1
		AMPS_Debug_dcInvalid		; this is an invalid command
	endif
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for setting volume envelope ID
; ---------------------------------------------------------------------------

dcVolEnv:
	if (FEATURE_DACFMVOLENV=0)&(safe=1)
		AMPS_Debug_dcVolEnv		; display an error if an invalid channel attempts to load a volume envelope
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
		beq.w	dPlaySnd_Stop		; if not, just stop all music instead
		jsr	dPlaySnd_Stop(pc)	; gotta do it anyway tho but continue below
; ---------------------------------------------------------------------------
; The reason we do fade in right here instead of later, is so we can update
; the FM voices with correct volume, no need to update volume later
; ---------------------------------------------------------------------------

		lea	dFadeInDataLog(pc),a4	; prepare stock fade in program to a4
		jsr	dLoadFade(pc)		; initiate fade in

		move.l	mBackSpeed.w,mSpeed.w	; restore tempo settings
		move.l	mBackVctMus.w,mVctMus.w	; restore voice table address

		lea	mBackUpLoc.w,a4		; load source address to a4
		lea	mBackUpArea.w,a3	; load destination address to a3
		move.w	#(mSFXDAC1-mBackUpArea)/4-1,d4; load backup size to d4

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

		moveq	#$7F,d3			; prepare max volume to d3
		move.b	d3,dZ80+PCM1_VolumeCur+1; set PCM1 volume as mute
		move.b	d3,dZ80+PCM2_VolumeCur+1; set PCM2 volume as mute
	startZ80
; ---------------------------------------------------------------------------
; The FM instruments need to be updated! Since this process includes volume
; updates, they do not need to be done later
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
; some cycles for 68000, but it will help improve DAC quality
; ---------------------------------------------------------------------------
;
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

dVoiceReg	macro	offset, reg
.offs =	\offset

	rept narg-1
		move.b	(a4)+,(a5)+		; write value to buffer

		if \reg<$80
			moveq	#\reg,d3	; load register to d3
		else
			moveq	#$FFFFFF00|\reg,d3; load register to d3
		endif

		or.b	d2,d3			; add channel offset to register
		move.b	d3,(a5)+		; write register to buffer

		if .offs>1
			addq.w	#.offs-1,a4	; offset a4 by specific amount
		endif
	shift
	endr
    endm
; ---------------------------------------------------------------------------

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

	dVoiceReg	0, $30, $38, $34, $3C	; Detune, Multiple
	dVoiceReg	0, $50, $58, $54, $5C	; Rate Scale, Attack Rate
	dVoiceReg	0, $60, $68, $64, $6C	; Decay 1 Rate
	dVoiceReg	0, $70, $78, $74, $7C	; Decay 2 Rate
	dVoiceReg	0, $80, $88, $84, $8C	; Decay 1 level, Release Rate
	dVoiceReg	0, $90, $98, $94, $9C	; SSG-EG
; ---------------------------------------------------------------------------

		moveq	#4-1,d1			; prepare 4 operators to d1
		move.b	cVolume(a1),d3		; load FM channel volume to d3
		ext.w	d3			; extend to word

	if FEATURE_SFX_MASTERVOL=0
		cmpa.w	#mSFXDAC1,a1		; is this a SFX channel
		bhs.s	.noover			; if so, do not add master volume!
	endif

		move.b	mMasterVolFM.w,d6	; load master FM volume to d6
		ext.w	d6			; extend to word
		add.w	d6,d3			; add to volume

.noover
	if FEATURE_UNDERWATER
		clr.w	d6			; no underwater 4 u

		btst	#mfbWater,mFlags.w	; check if underwater mode is enabled
		beq.s	.uwdone			; if not, skip
		lea	dUnderwaterTbl(pc),a2	; get underwater table to a2

		and.w	#7,d4			; mask out everything but the algorithm
		move.b	(a2,d4.w),d4		; get the value from table
		move.b	d4,d6			; copy to d6
		and.w	#7,d4			; mask out extra stuff
		add.w	d4,d3			; add algorithm to Total Level carrier offset

.uwdone
	endif

	if FEATURE_SOUNDTEST
		move.w	d3,d5			; copy to d5
		cmp.w	#$7F,d5			; check if volume is out of range
		bls.s	.nocapx			; if not, branch
		spl	d5			; if positive (above $7F), set to $FF. Otherwise, set to $00
		and.b	#$7F,d5			; keep in range for the sound test

.nocapx
		move.b	d5,cChipVol(a1)		; save volume to chip
	endif
; ---------------------------------------------------------------------------

		lea	dOpTLFM(pc),a2		; load TL registers to a2

.tlloop
		move.b	(a4)+,d5		; get Total Level value from voice to d5
		ext.w	d5			; extend to word
		bpl.s	.noslot			; if slot operator bit was not set, branch

		and.w	#$7F,d5			; get rid of sign bit (ugh)
		add.w	d3,d5			; add carrier offset to loaded value
	if FEATURE_UNDERWATER
		bra.s	.slot
	endif

.noslot
	if FEATURE_UNDERWATER
		add.w	d6,d5			; add modulator offset to loaded value
	endif

.slot
		cmp.w	#$7F,d5			; check if volume is out of range
		bls.s	.nocap			; if not, branch
		spl	d5			; if positive (above $7F), set to $FF. Otherwise, set to $00

.nocap
		move.b	d5,(a5)+		; save the Total Level value
		move.b	(a2)+,d4		; load register to d4
		or.b	d2,d4			; add channel offset to register
		move.b	d4,(a5)+		; write register to buffer
		dbf	d1,.tlloop		; repeat for each Total Level operator

	if safe=1
		AMPS_Debug_UpdVoiceFM		; check if the voice was valid
	endif
; ---------------------------------------------------------------------------

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
	stopZ80					; wait for Z80 to stop

.write
	rept VoiceRegs+1
		move.b	d2,(a0)+		; select YM port to access (4000 or 4002)
		move.b	(a5)+,(a0)+		; write values
		move.b	(a5)+,(a0)+		; write registers
	endr

	;	st	(a0)			; mark as end of the cue
	startZ80				; enable Z80 execution
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
		bhs.s	.sfx			; if yes, run SFX code

		btst	#ctbDAC,cType(a1)	; check if the channel is a DAC channel
		beq.s	.nodac			; if not, skip
		clr.b	cPanning(a1)		; clear panning (required for DAC to work right)

.nodac
		addq.l	#2,(sp)			; go to next channel immediately (this skips a bra.s instruction)
		rts
; ---------------------------------------------------------------------------

.sfx
		clr.b	cPrio(a1)		; clear channel priority

		lea	dSFXoverList(pc),a4	; load quick reference to the SFX override list to a4
		moveq	#0,d3
		move.b	cType(a1),d3		; load channel type to d3
		bmi.s	.psg			; if this is a PSG channel, branch
		move.w	a1,-(sp)		; push channel pointer

		and.w	#$07,d3			; get only the necessary bits to d3
		add.w	d3,d3			; double offset (each entry is 1 word in size)
		move.w	-4(a4,d3.w),a1		; get the SFX channel we were overriding

		tst.b	(a1)			; check if that channel is running a tracker
		bpl.s	.fixch			; if not, branch
; ---------------------------------------------------------------------------

		bset	#cfbVol,(a1)		; set update volume flag (cleared by dUpdateVoiceFM)
		bclr	#cfbInt,(a1)		; reset sfx override flag
		btst	#ctbDAC,cType(a1)	; check if the channel is a DAC channel
		bne.s	.fixch			; if yes, skip

		bset	#cfbRest,(a1)		; set channel resting flag
		moveq	#0,d4
		move.b	cVoice(a1),d4		; load FM voice ID of the channel to d4
		jsr	dUpdateVoiceFM(pc)	; send FM voice for this channel

.fixch
		move.w	(sp)+,a1		; pop the current channel

.exit
		addq.l	#2,(sp)			; go to next channel immediately (this skips a bra.s instruction)
		rts
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
		move.b	cStatPSG4(a4),dPSG	; update PSG4 status to PSG port
		bra.s	.exit
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker command for enabling LFO
;
; input:
;   a1 - Channel to operate on
; thrash:
;   a2 - Used for envelope data address
;   a5 - Used to temporarily use stack for saving LFO values
;   d1 - Used to store YM address
;   d2 - Used as dbf counter
;   d3 - Used to detect enabled operators
;   d4 - Various uses
;   d5 - Used for channel calculation
;   d6 - Used for channel calculation
; ---------------------------------------------------------------------------

dcsLFO:
		moveq	#0,d4
		move.b	cVoice(a1),d4		; load FM voice ID of the channel to d4
	dCALC_BANK	9			; get the voice table address to a4
	dCALC_VOICE				; get address of the specific voice to a4

		move.b	(a2),d3			; load LFO enable operators to d3
	CheckCue				; check that cue is valid
		btst	#cfbInt,(a1)		; check if channel is interrupted
		bne.w	.skipLFO		; if so, skip loading LFO

		move.l	sp,a5			; copy stack pointer to a5
		subq.l	#4,sp			; reserve some space in the stack

	rept 4
		moveq	#0,d5			; prepare d5 as clear (for roxr)
		add.b	d3,d3			; check if AMS is enabled for this channel
		roxr.b	#$01,d5			; if yes, rotate carry bit into bit7 (value of $80)

		move.b	(a4)+,d4		; get Decay 1 Level value from voice to d4
		or.b	d5,d4			; or the AMS enable value
		move.b	d4,-(a5)		; save in stack
	endr

	InitChYM				; prepare to write Channel-specific YM registers
	stopZ80
	WriteChYM	#$6C, (a5)+		; Decay 4 level: Decay 4 + AMS enable bit for operator 4
	WriteChYM	#$64, (a5)+		; Decay 2 level: Decay 2 + AMS enable bit for operator 2
	WriteChYM	#$68, (a5)+		; Decay 3 level: Decay 3 + AMS enable bit for operator 3
	WriteChYM	#$60, (a5)+		; Decay 1 level: Decay 1 + AMS enable bit for operator 1
		bra.s	.cont
; ---------------------------------------------------------------------------

.skipLFO
	InitChYM				; prepare to write Channel-specific YM registers
	stopZ80

.cont
	WriteYM1	#$22, (a2)+		; LFO: LFO frequency and enable
		move.b	(a2)+,d3		; load AMS, FMS & Panning from tracker
		move.b	d3,cPanning(a1)		; save to channel panning

		btst	#cfbInt,(a1)		; check if channel is interrupted
		bne.s	.skipPan		; if so, skip panning
	WriteChYM	#$B4, d3		; Panning & LFO: AMS + FMS + Panning

.skipPan
	;	st	(a0)			; write end marker
	startZ80
		move.l	a5,sp			; restore stack pointer
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
	dc.w mTempo, mSpeed		; 2
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
; ---------------------------------------------------------------------------

.cond
	rts			; T
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
; Tracker debug command for freezing the CPU
; ---------------------------------------------------------------------------

	if safe=1
dcFreeze:
		bra.w	*			; trap CPU here
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker debug command for debugging tracker data
; ---------------------------------------------------------------------------

dcTracker:
		st	msChktracker.w		; set debug flag
		rts
	endif
; ---------------------------------------------------------------------------
