; ===========================================================================
; ---------------------------------------------------------------------------
; AMPS - SMPS2ASM macro & equate file
; ---------------------------------------------------------------------------

; this macro is created to emulate enum in AS
enum		macro lable
	rept narg
\lable =	_num
_num =		_num+1
	shift
	endr
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Note equates
; ---------------------------------------------------------------------------

_num =		$80
	enum nRst
	enum nC0,nCs0,nD0,nEb0,nE0,nF0,nFs0,nG0,nAb0,nA0,nBb0,nB0
	enum nC1,nCs1,nD1,nEb1,nE1,nF1,nFs1,nG1,nAb1,nA1,nBb1,nB1
	enum nC2,nCs2,nD2,nEb2,nE2,nF2,nFs2,nG2,nAb2,nA2,nBb2,nB2
	enum nC3,nCs3,nD3,nEb3,nE3,nF3,nFs3,nG3,nAb3,nA3,nBb3,nB3
	enum nC4,nCs4,nD4,nEb4,nE4,nF4,nFs4,nG4,nAb4,nA4,nBb4,nB4
	enum nC5,nCs5,nD5,nEb5,nE5,nF5,nFs5,nG5,nAb5,nA5,nBb5,nB5
	enum nC6,nCs6,nD6,nEb6,nE6,nF6,nFs6,nG6,nAb6,nA6,nBb6,nB6
	enum nC7,nCs7,nD7,nEb7,nE7,nF7,nFs7,nG7,nAb7,nA7,nBb7
nHiHat =	nBb6
; ===========================================================================
; ---------------------------------------------------------------------------
; Header macros
; ---------------------------------------------------------------------------

; Header - Initialize a music file
sHeaderInit	macro
sPatNum =	0
    endm

; Header - Initialize a sound effect file
sHeaderInitSFX	macro

    endm

; Header - Set up channel usage
sHeaderCh	macro fm,psg
	if narg>1
		dc.b \psg-1, \fm-1
		if \fm>(5+((FEATURE_FM6<>0)&1))
			inform 1,"You sure there are \fm FM channels?"
		endif

		if \psg>3
			inform 1,"You sure there are \psg PSG channels?"
		endif
	else
		dc.b \fm-1
	endif
    endm

; Header - Set up tempo and tick multiplier
sHeaderTempo	macro tmul,tempo
	dc.b \tempo,\tmul-1
    endm

; Header - Set priority level
sHeaderPrio	macro prio
	dc.b \prio
    endm

; Header - Set up a DAC channel
sHeaderDAC	macro loc,vol,samp
	dc.w \loc-*

	if narg>1
		dc.b (\vol)&$FF
		if narg>2
			dc.b \samp
		else
			dc.b $00
		endif
	else
		dc.w $00
	endif
    endm

; Header - Set up an FM channel
sHeaderFM	macro loc,pitch,vol
	dc.w \loc-*
	dc.b (\pitch)&$FF,(\vol)&$FF
    endm

; Header - Set up a PSG channel
sHeaderPSG	macro loc,pitch,vol,detune,volenv
	dc.w \loc-*
	dc.b (\pitch)&$FF,(\vol)&$FF,(\detune)&$FF,\volenv
    endm

; Header - Set up an SFX channel
sHeaderSFX	macro flags,type,loc,pitch,vol
	dc.b \flags,\type
	dc.w \loc-*
	dc.b (\pitch)&$FF,(\vol)&$FF
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macros for FM instruments
; ---------------------------------------------------------------------------

; Patches - Algorithm and patch name
spAlgorithm	macro val, name
	if (sPatNum<>0)&(safe=0)
		; align the patch
		dc.b ((*)^(sPatNum*spTL4))&$FF
		dc.b (((*)>>8)+(spDe3*spDR3))&$FF
		dc.b (((*)>>16)-(spTL1*spRR3))&$FF
	endif

	if narg>1
p\name =		sPatNum
	endif

sPatNum =	sPatNum+1
spAl =		\val
    endm

; Patches - Feedback
spFeedback	macro val
spFe =		\val
    endm

; Patches - Detune
spDetune	macro op1,op2,op3,op4
spDe1 =		\op1
spDe2 =		\op2
spDe3 =		\op3
spDe4 =		\op4
    endm

; Patches - Multiple
spMultiple	macro op1,op2,op3,op4
spMu1 =		\op1
spMu2 =		\op2
spMu3 =		\op3
spMu4 =		\op4
    endm

; Patches - Rate Scale
spRateScale	macro op1,op2,op3,op4
spRS1 =		\op1
spRS2 =		\op2
spRS3 =		\op3
spRS4 =		\op4
    endm

; Patches - Attack Rate
spAttackRt	macro op1,op2,op3,op4
spAR1 =		\op1
spAR2 =		\op2
spAR3 =		\op3
spAR4 =		\op4
    endm

; Patches - Amplitude Modulation
spAmpMod	macro op1,op2,op3,op4
spAM1 =		\op1
spAM2 =		\op2
spAM3 =		\op3
spAM4 =		\op4
    endm

; Patches - Sustain Rate
spSustainRt	macro op1,op2,op3,op4
spSR1 =		\op1		; Also known as decay 1 rate
spSR2 =		\op2
spSR3 =		\op3
spSR4 =		\op4
    endm

; Patches - Sustain Level
spSustainLv	macro op1,op2,op3,op4
spSL1 =		\op1		; also known as decay 1 level
spSL2 =		\op2
spSL3 =		\op3
spSL4 =		\op4
    endm

; Patches - Decay Rate
spDecayRt	macro op1,op2,op3,op4
spDR1 =		\op1		; Also known as decay 2 rate
spDR2 =		\op2
spDR3 =		\op3
spDR4 =		\op4
    endm

; Patches - Release Rate
spReleaseRt	macro op1,op2,op3,op4
spRR1 =		\op1
spRR2 =		\op2
spRR3 =		\op3
spRR4 =		\op4
    endm

; Patches - SSG-EG
spSSGEG		macro op1,op2,op3,op4
spSS1 =		\op1
spSS2 =		\op2
spSS3 =		\op3
spSS4 =		\op4
    endm

; Patches - Total Level
spTotalLv	macro op1,op2,op3,op4
spTL1 =		\op1
spTL2 =		\op2
spTL3 =		\op3
spTL4 =		\op4

; Construct the patch finally.
	dc.b (spFe<<3)+spAl

;   0     1     2     3     4     5     6     7
;%1000,%1000,%1000,%1000,%1010,%1110,%1110,%1111

spTLMask4 =	$80
spTLMask2 =	((spAl>=5)<<7)
spTLMask3 =	((spAl>=4)<<7)
spTLMask1 =	((spAl=7)<<7)

	dc.b (spDe1<<4)+spMu1, (spDe3<<4)+spMu3, (spDe2<<4)+spMu2, (spDe4<<4)+spMu4
	dc.b (spRS1<<6)+spAR1, (spRS3<<6)+spAR3, (spRS2<<6)+spAR2, (spRS4<<6)+spAR4
	dc.b (spAM1<<7)+spSR1, (spAM3<<7)+spsR3, (spAM2<<7)+spSR2, (spAM4<<7)+spSR4
	dc.b spDR1,            spDR3,            spDR2,            spDR4
	dc.b (spSL1<<4)+spRR1, (spSL3<<4)+spRR3, (spSL2<<4)+spRR2, (spSL4<<4)+spRR4
	dc.b spSS1,            spSS3,            spSS2,            spSS4
	dc.b spTL1|spTLMask1,  spTL3|spTLMask3,  spTL2|spTLMask2,  spTL4|spTLMask4

	if safe=1
		dc.b "NAT"	; align the patch
	endif
    endm

; Patches - Total Level (for broken total level masks)
spTotalLv2	macro op1,op2,op3,op4
spTL1 =		\op1
spTL2 =		\op2
spTL3 =		\op3
spTL4 =		\op4

	dc.b (spFe<<3)+spAl
	dc.b (spDe1<<4)+spMu1, (spDe3<<4)+spMu3, (spDe2<<4)+spMu2, (spDe4<<4)+spMu4
	dc.b (spRS1<<6)+spAR1, (spRS3<<6)+spAR3, (spRS2<<6)+spAR2, (spRS4<<6)+spAR4
	dc.b (spAM1<<7)+spSR1, (spAM3<<7)+spsR3, (spAM2<<7)+spSR2, (spAM4<<7)+spSR4
	dc.b spDR1,            spDR3,            spDR2,            spDR4
	dc.b (spSL1<<4)+spRR1, (spSL3<<4)+spRR3, (spSL2<<4)+spRR2, (spSL4<<4)+spRR4
	dc.b spSS1,            spSS3,            spSS2,            spSS4
	dc.b spTL1,	       spTL3,		 spTL2,		   spTL4

	if safe=1
		dc.b "NAT"	; align the patch
	endif
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Equates for sPan
; ---------------------------------------------------------------------------

spNone equ	$00
spRight equ	$40
spLeft equ	$80
spCentre equ	$C0
spCenter equ	$C0
; ===========================================================================
; ---------------------------------------------------------------------------
; Tracker commands
; ---------------------------------------------------------------------------

; E0xx - Panning, AMS, FMS (PANAFMS - PAFMS_PAN)
sPan		macro pan, ams, fms
	if narg=1
		dc.b $E0, \pan

	elseif narg=2
		dc.b $E0, \pan|\ams

	else
		dc.b $E0, \pan|(\ams<<4)|\fms
	endif
    endm

; E1xx - Set channel frequency displacement to xx (DETUNE_SET)
ssDetune	macro detune
	dc.b $E1, \detune
    endm

; E2xx - Add xx to channel frequency displacement (DETUNE)
saDetune	macro detune
	dc.b $E2, \detune
    endm

; E3xx - Set channel pitch to xx (TRANSPOSE - TRNSP_SET)
ssTranspose	macro transp
	dc.b $E3, \transp
    endm

; E4xx - Add xx to channel pitch (TRANSPOSE - TRNSP_ADD)
saTranspose	macro transp
	dc.b $E4, \transp
    endm

; E5xx - Set channel tick multiplier to xx (TICK_MULT - TMULT_CUR)
ssTickMulCh	macro tick
	dc.b $E5, \tick-1
    endm

; E6xx - Set global tick multiplier to xx (TICK_MULT - TMULT_ALL)
ssTickMul	macro tick
	dc.b $E6, \tick-1
    endm

; E7 - Do not attack of next note (HOLD)
sHold equ		$E7

; E8xx - Set patch/voice/sample to xx (INSTRUMENT - INS_C_FM / INS_C_PSG / INS_C_DAC)
sVoice		macro voice
	dc.b $E8, \voice
    endm

; F2xx - Set volume envelope to xx (INSTRUMENT - INS_C_PSG) (FM_VOLENV / DAC_VOLENV)
sVolEnv		macro env
	dc.b $F2, \env
    endm

; F3xx - Set modulation envelope to xx (MOD_ENV - MENV_GEN)
sModEnv		macro env
	dc.b $F3, \env
    endm

; E9xx - Set music speed shoes tempo to xx (TEMPO - TEMPO_SET_SPEED)
ssTempoShoes	macro tempo
	dc.b $E9, \tempo
    endm

; EAxx - Set music tempo to xx (TEMPO - TEMPO_SET)
ssTempo		macro tempo
	dc.b $EA, \tempo
    endm

; FF18xx - Add xx to music speed tempo (TEMPO - TEMPO_ADD_SPEED)
saTempoSpeed	macro tempo
	dc.b $FF,$18, \tempo
    endm

; FF1Cxx - Add xx to music tempo (TEMPO - TEMPO_ADD)
saTempo		macro tempo
	dc.b $FF,$1C, \tempo
    endm

; EB - Use sample DAC mode, where each note is a different sample (DAC_MODE - DACM_SAMP)
sModeSampDAC	macro
	dc.b $EB
    endm

; EC - Use pitch DAC mode, where each note is a different pitch (DAC_MODE - DACM_NOTE)
sModePitchDAC	macro
	dc.b $EC
    endm

; EDxx - Add xx to channel volume (VOLUME - VOL_CN_FM / VOL_CN_PSG / VOL_CN_DAC)
saVol		macro volume
	dc.b $ED, \volume
    endm

; EExx - Set channel volume to xx (VOLUME - VOL_CN_ABS)
ssVol		macro volume
	dc.b $EE, \volume
    endm

; EFxxyy - Enable/Disable LFO (SET_LFO - LFO_AMSEN)
ssLFO		macro reg, ams, fms, pan
	if narg=2
		dc.b $EF, \reg,\ams

	elseif narg=3
		dc.b $EF, \reg,(\ams<<4)|\fms

	else
		dc.b $EF, \reg,(\ams<<4)|\fms|\pan
	endif
    endm

; F0xxzzwwyy - Modulation (AMPS algorithm)
;  ww: wait time
;  xx: modulation speed
;  yy: change per step
;  zz: number of steps
; (MOD_SETUP)
sModAMPS	macro wait, speed, step, count
	dc.b $F0
	sModData \wait, \speed, \step, \count
    endm

sModData	macro wait, speed, step, count
	dc.b \speed, \count, \step, \wait
    endm

; FF00 - Turn on Modulation (MOD_SET - MODS_ON)
sModOn		macro
	dc.b $FF,$00
    endm

; FF04 - Turn off Modulation (MOD_SET - MODS_OFF)
sModOff		macro
	dc.b $FF,$04
    endm

; FF28xxxx - Set modulation frequency to xxxx (MOD_SET - MODS_FREQ)
ssModFreq	macro freq
	dc.b $FF,$28
	dc.w \freq
    endm

; FF2C - Reset modulation data (MOD_SET - MODS_RESET)
sModReset	macro
	dc.b $FF,$2C
    endm

; F1xx - Set portamento speed to xx frames. 0 means portamento is disabled (PORTAMENTO)
ssPortamento	macro frames
	dc.b $F1, \frames
    endm

; F4xxxx - Keep looping back to xxxx each time the SFX is being played (CONT_SFX)
sCont		macro loc
	dc.b $F4
	dc.w \loc-*-2
    endm

; F5 - End of channel (TRK_END - TEND_STD)
sStop		macro
	dc.b $F5
    endm

; F6xxxx - Jump to xxxx (GOTO)
sJump		macro loc
	dc.b $F6
	dc.w \loc-*-2
    endm

; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing (LOOP)
sLoop		macro index,loops,loc
	dc.b $F7, \index
	dc.w \loc-*-2
	dc.b \loops-1

	if \loops<2
		inform 3,"Invalid number of loops! Must be 2 or more!"
	endif
    endm

; F8xxxx - Call pattern at xxxx, saving return point (GOSUB)
sCall		macro loc
	dc.b $F8
	dc.w \loc-*-2
    endm

; F9 - Return (RETURN)
sRet		macro
	dc.b $F9
    endm

; FAyyxx - Set communications byte yy to xx (SET_COMM - SPECIAL)
sComm		macro index, val
	dc.b $FA, \index,\val
    endm

; FBxyzz - Get communications byte y, and compare zz with it using condition x (COMM_CONDITION)
sCond		macro index, cond, val
	dc.b $FB, \index|(\cond<<4),\val
    endm

; FC - Reset condition (COMM_RESET)
sCondOff	macro
	dc.b $FC
    endm

; FDxx - Stop note after xx frames (NOTE_STOP - NSTOP_NORMAL)
sGate		macro frames
	dc.b $FD, \frames
    endm

; FExxyy - YM command yy on register xx (YMCMD)
sCmdYM		macro reg, val
	dc.b $FE, \reg,\val
    endm

; FF08xxxx - Set channel frequency to xxxx (CHFREQ_SET)
ssFreq		macro freq
	dc.b $FF,$08
	dc.w \freq
    endm

; FF0Cxx - Set channel frequency to note xx (CHFREQ_SET - CHFREQ_NOTE)
ssFreqNote	macro note
	dc.b $FF,$0C, \note^$80
    endm

; FF10 - Increment spindash rev counter (SPINDASH_REV - SDREV_INC)
sSpinRev	macro
	dc.b $FF,$10
    endm

; FF14 - Reset spindash rev counter (SPINDASH_REV - SDREV_RESET)
sSpinReset	macro
	dc.b $FF,$14
    endm

; FF20xyzz - Get RAM address pointer offset by y, compare zz with it using condition x (COMM_CONDITION - COMM_SPEC)
sCondReg	macro index, cond, val
	dc.b $FF,$20, \index|(\cond<<4),\val
    endm

; FF24xx - Play another music/sfx (SND_CMD)
sPlayMus	macro id
	dc.b $FF,$24, \id
    endm

; FF30 - Enable FM3 special mode (SPC_FM3)
sSpecFM3	macro
	dc.b $FF,$30
	inform 3,"Flag is currently not implemented! Please remove."
    endm

; FF34xx - Set DAC filter bank address (DAC_FILTER)
ssFilter	macro bank
	dc.b $FF,$34, \bank
    endm

; FF38 - Load the last song from back-up (FADE_IN_SONG)
sBackup		macro
	dc.b $FF,$38
    endm

; FF3Cxx - PSG4 noise mode xx (PSG_NOISE - PNOIS_AMPS)
sNoisePSG	macro mode
	dc.b $FF,$3C, \mode
    endm

; FF40 - Freeze 68k. Debug flag (DEBUG_STOP_CPU)
sFreeze		macro
	if safe=1
		dc.b $FF,$40
	endif
    endm

; FF44 - Bring up tracker debugger at end of frame. Debug flag (DEBUG_PRINT_TRACKER)
sCheck		macro
	if safe=1
		dc.b $FF,$44
	endif
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Equates for sNoisePSG
; ---------------------------------------------------------------------------

snOff =		$00			; disables PSG3 noise mode.
_num =		$E0
	enum snPeri10, snPeri20, snPeri40, snPeriPSG3
	enum snWhite10,snWhite20,snWhite40,snWhitePSG3
; ---------------------------------------------------------------------------
