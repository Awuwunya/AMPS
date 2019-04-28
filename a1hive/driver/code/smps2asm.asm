; ===============================================
; Based on Flamewing's SMPS2ASM, and S1SMPS2ASM by Marc (AKA Cinossu)
; Reworked and improved by Natsumi
; ===============================================
; this macro is created to emulate enum in AS
enum	macro	num, lable
; copy initial number for referencing later
.num	= num

	rept narg-1
\lable		set .num
.num =	.num+1
	shift
	endr
    endm

; ---------------------------------------------------------------------------------------------
; Note Equates
	enum $80+0, nRst
	enum nRst+1,nC0,nCs0,nD0,nEb0,nE0,nF0,nFs0,nG0,nAb0,nA0,nBb0,nB0
	enum nB0+1, nC1,nCs1,nD1,nEb1,nE1,nF1,nFs1,nG1,nAb1,nA1,nBb1,nB1
	enum nB1+1, nC2,nCs2,nD2,nEb2,nE2,nF2,nFs2,nG2,nAb2,nA2,nBb2,nB2
	enum nB2+1, nC3,nCs3,nD3,nEb3,nE3,nF3,nFs3,nG3,nAb3,nA3,nBb3,nB3
	enum nB3+1, nC4,nCs4,nD4,nEb4,nE4,nF4,nFs4,nG4,nAb4,nA4,nBb4,nB4
	enum nB4+1, nC5,nCs5,nD5,nEb5,nE5,nF5,nFs5,nG5,nAb5,nA5,nBb5,nB5
	enum nB5+1, nC6,nCs6,nD6,nEb6,nE6,nF6,nFs6,nG6,nAb6,nA6,nBb6,nB6
	enum nB6+1, nC7,nCs7,nD7,nEb7,nE7,nF7,nFs7,nG7,nAb7,nA7,nBb7

; ---------------------------------------------------------------------------------------------
; PSG volume envelope equates
v00 =	$00

; ---------------------------------------------------------------------------------------------
; Header Macros
sHeaderInit	macro
sPointZero =	*
sPatNum =	0
    endm

; Header - Set up Channel Usage
sHeaderCh	macro fm,psg
	dc.b \fm-1

	if narg=2
		if \fm>5
			inform 2,"You sure there are \fm FM channels?"
		endif

		dc.b \psg-1
		if \psg>3
			inform 2,"You sure there are \psg PSG channels?"
		endif
	endif
    endm

; Header - Set up Tempo and Tick Multiplier
sHeaderTempo	macro tmul,tempo
	dc.b \tmul-1,\tempo
    endm

; Header - Set priority leve
sHeaderPrio	macro prio
	dc.b \prio
    endm

; Header - Set up DAC Channel
sHeaderDAC	macro loc,vol,samp
	dc.w \loc-sPointZero

	if narg>=2
		dc.b \vol
		if narg>=3
			dc.b \samp
		else
			dc.b $00
		endif
	else
		dc.w $00
	endif
    endm

; Header - Set up FM Channel
sHeaderFM	macro loc,pitch,vol
	dc.w \loc-sPointZero
	dc.b \pitch,\vol
    endm

; Header - Set up PSG Channel
sHeaderPSG	macro loc,pitch,vol,detune,volenv
	dc.w \loc-sPointZero
	dc.b \pitch,\vol,\detune,\volenv
    endm

; Header - Set up SFX Channel
sHeaderSFX	macro flags,type,loc,pitch,vol
	dc.b \flags,\type
	dc.w \loc-sPointZero
	dc.b \pitch,\vol
    endm

; ---------------------------------------------------------------------------------------------
; Command Flag Macros and Equates. Based on the original s1smps2asm, and Flamewing's smps2asm
spNone set $00
spRight set $40
spLeft set $80
spCentre set $C0
spCenter set $C0

; ---------------------------------------------------------------------------------------------
; Macros for FM instruments
; Patches - Feedback

; Patches - Algorithm
spAlgorithm macro val, name
	if (sPatNum<>0)&(safe=0)
		; align the patch
		dc.b (*^(sPatNum*spTL4))&$FF
		dc.b ((*>>8)+(spDe3*spDR3))&$FF
		dc.b ((*>>16)-(spTL1*spRR3))&$FF
	endif

	if narg>1
p\name =	sPatNum
	endif

sPatNum =	sPatNum+1
spAl	= val
    endm

spFeedback macro val
spFe	= val
    endm

; Patches - Detune
spDetune macro op1,op2,op3,op4
spDe1	= op1
spDe2	= op2
spDe3	= op3
spDe4	= op4
    endm

; Patches - Multiple
spMultiple macro op1,op2,op3,op4
spMu1	= op1
spMu2	= op2
spMu3	= op3
spMu4	= op4
    endm

; Patches - Rate Scale
spRateScale macro op1,op2,op3,op4
spRS1	= op1
spRS2	= op2
spRS3	= op3
spRS4	= op4
    endm

; Patches - Attack Rate
spAttackRt macro op1,op2,op3,op4
spAR1	= op1
spAR2	= op2
spAR3	= op3
spAR4	= op4
    endm

; Patches - Amplitude Modulation
spAmpMod macro op1,op2,op3,op4
spAM1	= op1
spAM2	= op2
spAM3	= op3
spAM4	= op4
    endm

; Patches - Sustain Rate
spSustainRt macro op1,op2,op3,op4
spSR1	= op1		; Also known as decay 1 rate
spSR2	= op2
spSR3	= op3
spSR4	= op4
    endm

; Patches - Sustain Level
spSustainLv macro op1,op2,op3,op4
spSL1	= op1		; also known as decay 1 level
spSL2	= op2
spSL3	= op3
spSL4	= op4
    endm

; Patches - Decay Rate
spDecayRt macro op1,op2,op3,op4
spDR1	= op1		; Also known as decay 2 rate
spDR2	= op2
spDR3	= op3
spDR4	= op4
    endm

; Patches - Release Rate
spReleaseRt macro op1,op2,op3,op4
spRR1	= op1
spRR2	= op2
spRR3	= op3
spRR4	= op4
    endm

; Patches - SSG-EG
spSSGEG macro op1,op2,op3,op4
spSS1	= op1
spSS2	= op2
spSS3	= op3
spSS4	= op4
    endm

; Patches - Total Level
spTotalLv macro op1,op2,op3,op4
spTL1	= op1
spTL2	= op2
spTL3	= op3
spTL4	= op4

; Construct the patch finally.
	dc.b	(spFe<<3)+spAl
;   0     1     2     3     4     5     6     7
;%1000,%1000,%1000,%1000,%1010,%1110,%1110,%1111
spTLMask4 set $80
spTLMask2 set ((spAl>=5)<<7)
spTLMask3 set ((spAl>=4)<<7)
spTLMask1 set ((spAl=7)<<7)

	dc.b (spDe1<<4)+spMu1, (spDe3<<4)+spMu3, (spDe2<<4)+spMu2, (spDe4<<4)+spMu4
	dc.b (spRS1<<6)+spAR1, (spRS3<<6)+spAR3, (spRS2<<6)+spAR2, (spRS4<<6)+spAR4
	dc.b (spAM1<<7)+spSR1, (spAM3<<7)+spsR3, (spAM2<<7)+spSR2, (spAM4<<7)+spSR4
	dc.b spDR1,            spDR3,            spDR2,            spDR4
	dc.b (spSL1<<4)+spRR1, (spSL3<<4)+spRR3, (spSL2<<4)+spRR2, (spSL4<<4)+spRR4
	dc.b spSS1,            spSS3,            spSS2,            spSS4
	dc.b spTL1|spTLMask1,  spTL3|spTLMask3,  spTL2|spTLMask2,  spTL4|spTLMask4

	if safe=1
		dc.b 'NAT'	; align the patch
	endif
    endm

; Patches - Total Level (for broken total level masks)
spTotalLv2 macro op1,op2,op3,op4
spTL1	= op1
spTL2	= op2
spTL3	= op3
spTL4	= op4

	dc.b (spFe<<3)+spAl
	dc.b (spDe1<<4)+spMu1, (spDe3<<4)+spMu3, (spDe2<<4)+spMu2, (spDe4<<4)+spMu4
	dc.b (spRS1<<6)+spAR1, (spRS3<<6)+spAR3, (spRS2<<6)+spAR2, (spRS4<<6)+spAR4
	dc.b (spAM1<<7)+spSR1, (spAM3<<7)+spsR3, (spAM2<<7)+spSR2, (spAM4<<7)+spSR4
	dc.b spDR1,            spDR3,            spDR2,            spDR4
	dc.b (spSL1<<4)+spRR1, (spSL3<<4)+spRR3, (spSL2<<4)+spRR2, (spSL4<<4)+spRR4
	dc.b spSS1,            spSS3,            spSS2,            spSS4
	dc.b spTL1,	       spTL3,		 spTL2,		   spTL4

	if safe=1
		dc.b 'NAT'	; align the patch
	endif
    endm
; ---------------------------------------------------------------------------------------------
; SMPS commands

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
ssDetune	macro val
	dc.b $E1, \val
    endm

; E2xx - Add xx to channel frequency displacement (DETUNE)
saDetune	macro val
	dc.b $E2, \val
    endm

; E3xx - Set channel pitch to xx (TRANSPOSE - TRNSP_SET)
ssTranspose	macro val
	dc.b $E3, \val
    endm

; E4xx - Add xx to channel pitch (TRANSPOSE - TRNSP_ADD)
saTranspose	macro val
	dc.b $E4, \val
    endm

; E5xx - Set channel tick multiplier to xx (TICK_MULT - TMULT_CUR)
ssTickMulCh	macro val
	dc.b $E5, \val-1
    endm

; E6xx - Set global tick multiplier to xx (TICK_MULT - TMULT_ALL)
ssTickMul	macro val
	dc.b $E6, \val-1
    endm

; E7 - Do not attack of next note (HOLD)
sHold =		$E7

; E8xx - Set patch/voice/sample to xx (INSTRUMENT - INS_C_FM / INS_C_PSG / INS_C_DAC)
sVoice		macro val
	dc.b $E8, \val
    endm

; E9xx - Set music speed shoes tempo to xx (TEMPO - TEMPO_SET_SPEED)
ssTempoShoes	macro val
	dc.b $E9, \val
    endm

; EAxx - Set music tempo to xx (TEMPO - TEMPO_SET)
ssTempo		macro val
	dc.b $EA, \val
    endm

; EB - Turn on Modulation (MOD_SET - MODS_ON)
sModOn		macro
	dc.b $EB
    endm

; EC - Turn off Modulation (MOD_SET - MODS_OFF)
sModOff		macro
	dc.b $EC
    endm

; EDxx - Add xx to channel volume (VOLUME - VOL_CN_FM / VOL_CN_PSG / VOL_CN_DAC)
saVol		macro vol
	dc.b $ED, \vol
    endm

; EExx - Set channel volume to xx (VOLUME - VOL_CN_ABS)
ssVol		macro vol
	dc.b $EE, \vol
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

; F0wwxxyyzz - Modulation
;  ww: wait time
;  xx: modulation speed
;  yy: change per step
;  zz: number of steps
; (MOD_SETUP)
ssMod68k	macro wait, speed, step, count
	dc.b $F0, \wait,\speed,\step,\count
    endm

; F1 - Use sample DAC mode (DAC_MODE - DACM_SAMP)
sModeSampDAC	macro
	dc.b $F1
    endm

; F2 - Use pitch DAC mode (DAC_MODE - DACM_NOTE)
sModePitchDAC	macro
	dc.b $F2
    endm

; F3xx - PSG4 noise mode xx (PSG_NOISE - PNOIS_AMPS)
sNoisePSG	macro val
	dc.b $F3, \val
    endm

; F4xxxx - Keep looping back to xxxx each time the SFX is being played (CONT_SFX)
sCont		macro loc
	dc.b $F4
	dc.w \loc-*-1
    endm

; F5 - End of channel (TRK_END - TEND_STD)
sStop		macro
	dc.b $F5
    endm

; F6xxxx - Jump to xxxx (GOTO)
sJump		macro loc
	dc.b $F6
	dc.w \loc-*-1
    endm

; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing (LOOP)
sLoop		macro index,loops,loc
	dc.b $F7, \index
	dc.w \loc-*-1
	dc.b \loops
    endm

; F8xxxx - Call pattern at xxxx, saving return point (GOSUB)
sCall		macro loc
	dc.b $F8
	dc.w \loc-*-1
    endm

; F9 - Return (RETURN)
sRet		macro
	dc.b $F9
    endm

; FAyyxx - Set communications byte yy to xx (SET_COMM - SPECIAL)
sComm		macro num, val
	dc.b $FA, \num,\val
    endm

; FBxyzz - Get communications byte y, and compare zz with it using condition x (COMM_CONDITION)
sCond		macro num, cond, val
	dc.b $FB, \num|(\cond<<4),\val
    endm

; FC - Reset condition (COMM_RESET)
sCondOff	macro
	dc.b $FC
    endm

; FDxx - Stop note after xx frames (NOTE_STOP - NSTOP_NORMAL)
sNoteTimeOut	macro val
	dc.b $FD, \val
    endm

; FExxyy - YM command yy on register xx (YMCMD)
sCmdYM		macro reg, val
	dc.b $FE, \reg,\val
    endm

; FF00xx - Play sample xx on DAC1 (PLAY_DAC - PLAY_DAC1)
sPlaySamp1	macro id
	dc.b $FF,$00, \id
    endm

; FF01xx - Play sample xx on DAC1 (PLAY_DAC - PLAY_DAC2)
sPlaySamp2	macro id
	dc.b $FF,$01, \id
    endm

; FF02xxxx - Set channel frequency to xxxx (CHFREQ_SET)
ssFreq		macro freq
	dc.b $FF,$02
	dc.w \freq
    endm

; FF03xx - Set channel frequency to note xx (CHFREQ_SET - CHFREQ_NOTE)
ssFreqNote	macro note
	dc.b $FF,$03, \note^$80
    endm

; FF04 - Increment spindash rev counter (SPINDASH_REV - SDREV_INC)
sSpinRev	macro
	dc.b $FF,$04
    endm

; FF05 - Reset spindash rev counter (SPINDASH_REV - SDREV_RESET)
sSpinReset	macro
	dc.b $FF,$05
    endm

; FF06xx - Add xx to music speed tempo (TEMPO - TEMPO_ADD_SPEED)
saTempoSpeed	macro tempo
	dc.b $FF,$06, \tempo
    endm

; FF07xx - Add xx to music tempo (TEMPO - TEMPO_ADD)
saTempo		macro tempo
	dc.b $FF,$07, \tempo
    endm

; FF08xyzz - Get RAM address pointer offset by y, compare zz with it using condition x (COMM_CONDITION - COMM_SPEC)
sCondReg	macro off, cond, val
	dc.b $FF,$08, \off|(\cond<<4),\val
    endm

; FF09xx - Play another music/sfx (SND_CMD)
sPlayMus	macro id
	dc.b $FF,$09, \id
    endm

; FF0A - Enable raw frequency mode (RAW_FREQ)
sFreqOn		macro freq
	dc.b $FF,$0A
	inform 3,"Flag is currently not implemented! Please remove."
    endm

; FF0B - Disable raw frequency mode (RAW_FREQ - RAW_FREQ_OFF)
sFreqOff	macro freq
	dc.b $FF,$0B
	inform 3,"Flag is currently not implemented! Please remove."
    endm

; FF0C - Enable FM3 special mode (SPC_FM3)
sSpecFM3	macro freq
	dc.b $FF,$0C
	inform 3,"Flag is currently not implemented! Please remove."
    endm

; FF0Dxx - Set DAC filter bank address (DAC_FILTER)
ssFilter	macro bank
	dc.b $FF,$0D, \bank
    endm

; FF0E - Freeze 68k. Debug flag (DEBUG_STOP_CPU)
sFreeze		macro
	if safe=1
		dc.b $FF,$0E
	endif
    endm

; FF0F - Bring up tracker debugger at end of frame. Debug flag (DEBUG_PRINT_TRACKER)
sCheck		macro
	if safe=1
		dc.b $FF,$0F
	endif
    endm
