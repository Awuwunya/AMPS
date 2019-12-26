ScrabBrain_Header:
	sHeaderInit
	sHeaderTempo	$02, $33
	sHeaderCh	$05, $03
	sHeaderDAC	ScrabBrain_DAC1
	sHeaderDAC	ScrabBrain_DAC2
	sHeaderFM	ScrabBrain_FM1, $F4, $0D
	sHeaderFM	ScrabBrain_FM2, $F4, $0D
	sHeaderFM	ScrabBrain_FM3, $F4, $13
	sHeaderFM	ScrabBrain_FM4, $F4, $17
	sHeaderFM	ScrabBrain_FM5, $F4, $17
	sHeaderPSG	ScrabBrain_PSG1, $D0+$0C, $18, $00, v00
	sHeaderPSG	ScrabBrain_PSG2, $D0+$0C, $18, $00, v00
	sHeaderPSG	ScrabBrain_PSG3, $00, $18, $00, v04

	; Patch $00
	; $08
	; $0A, $70, $30, $00,	$1F, $1F, $5F, $5F
	; $12, $0E, $0A, $0A,	$00, $04, $04, $03
	; $2F, $2F, $2F, $2F,	$24, $2D, $13, $80
	spAlgorithm	$00
	spFeedback	$01
	spDetune	$00, $03, $07, $00
	spMultiple	$0A, $00, $00, $00
	spRateScale	$00, $01, $00, $01
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$12, $0A, $0E, $0A
	spSustainLv	$02, $02, $02, $02
	spDecayRt	$00, $04, $04, $03
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$24, $13, $2D, $00

	; Patch $01
	; $2C
	; $74, $74, $34, $34,	$1F, $12, $1F, $1F
	; $00, $04, $00, $04,	$00, $09, $00, $09
	; $00, $08, $00, $08,	$16, $80, $17, $80
	spAlgorithm	$04
	spFeedback	$05
	spDetune	$07, $03, $07, $03
	spMultiple	$04, $04, $04, $04
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $12, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$00, $00, $04, $04
	spSustainLv	$00, $00, $00, $00
	spDecayRt	$00, $00, $09, $09
	spReleaseRt	$00, $00, $08, $08
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$16, $17, $00, $00

	; Patch $02
	; $3D
	; $01, $02, $02, $02,	$14, $0E, $8C, $0E
	; $08, $05, $02, $05,	$00, $08, $08, $08
	; $1F, $1F, $1F, $1F,	$1A, $92, $A7, $80
	spAlgorithm	$05
	spFeedback	$07
	spDetune	$00, $00, $00, $00
	spMultiple	$01, $02, $02, $02
	spRateScale	$00, $02, $00, $00
	spAttackRt	$14, $0C, $0E, $0E
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$08, $02, $05, $05
	spSustainLv	$01, $01, $01, $01
	spDecayRt	$00, $08, $08, $08
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1A, $27, $12, $00

	; Patch $03
	; $29
	; $36, $74, $71, $31,	$04, $04, $05, $1D
	; $12, $0E, $1F, $1F,	$04, $06, $03, $01
	; $5F, $6F, $0F, $0F,	$27, $27, $2E, $80
	spAlgorithm	$01
	spFeedback	$05
	spDetune	$03, $07, $07, $03
	spMultiple	$06, $01, $04, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$04, $05, $04, $1D
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$12, $1F, $0E, $1F
	spSustainLv	$05, $00, $06, $00
	spDecayRt	$04, $03, $06, $01
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$27, $2E, $27, $00

	; Patch $04
	; $3D
	; $01, $01, $01, $01,	$8E, $52, $14, $4C
	; $08, $08, $0E, $03,	$00, $00, $00, $00
	; $1F, $1F, $1F, $1F,	$1B, $80, $80, $9B
	spAlgorithm	$05
	spFeedback	$07
	spDetune	$00, $00, $00, $00
	spMultiple	$01, $01, $01, $01
	spRateScale	$02, $00, $01, $01
	spAttackRt	$0E, $14, $12, $0C
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$08, $0E, $08, $03
	spSustainLv	$01, $01, $01, $01
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1B, $00, $00, $1B

	; Patch $05
	; $30
	; $30, $30, $30, $30,	$9E, $D8, $DC, $DC
	; $0E, $0A, $04, $05,	$08, $08, $08, $08
	; $BF, $BF, $BF, $BF,	$14, $3C, $14, $80
	spAlgorithm	$00
	spFeedback	$06
	spDetune	$03, $03, $03, $03
	spMultiple	$00, $00, $00, $00
	spRateScale	$02, $03, $03, $03
	spAttackRt	$1E, $1C, $18, $1C
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0E, $04, $0A, $05
	spSustainLv	$0B, $0B, $0B, $0B
	spDecayRt	$08, $08, $08, $08
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$14, $14, $3C, $00

	; Patch $06
	; $3D
	; $01, $02, $00, $01,	$1F, $0E, $0E, $0E
	; $07, $1F, $1F, $1F,	$00, $00, $00, $00
	; $1F, $0F, $0F, $0F,	$17, $8D, $8C, $8C
	spAlgorithm	$05
	spFeedback	$07
	spDetune	$00, $00, $00, $00
	spMultiple	$01, $00, $02, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $0E, $0E, $0E
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$07, $1F, $1F, $1F
	spSustainLv	$01, $00, $00, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$17, $0C, $0D, $0C

ScrabBrain_FM1:
	dc.b nRst, $24
	sVoice		$02
	saVol		$08
	dc.b nE6, $03, nD6, nC6, nB5, nF6
	dc.b nE6, nD6, nC6, nG6, nF6, nE6, nD6, nA6
	dc.b nG6, nF6, nE6, nB6, nA6, nG6, nF6
	saVol		$F8
	sVoice		$03
	ssMod68k	$0D, $01, $08, $05
	sCall		ScrabBrain_Call1
	sVoice		$05
	ssDetune	$FE
	sPan		spRight, $00
	saVol		$03
	saTranspose	$F4
	sCall		ScrabBrain_Call2
	saTranspose	$0C
	saVol		$FD
	sPan		spCenter, $00
	saVol		$FE
	ssDetune	$00
	sVoice		$03

ScrabBrain_Loop1:
	sCall		ScrabBrain_Call4
	sLoop		$00, $02, ScrabBrain_Loop1
	saVol		$02
	sJump		ScrabBrain_FM1

ScrabBrain_FM2:
	sVoice		$00
	saVol		$FD
	sGate		$06
	dc.b nA3, $03, nB3, nRst, nC4, nRst, nD4, nE4
	sGate		$00
	dc.b nG4, $09

ScrabBrain_Loop2:
	dc.b nG3, $06, nG4
	sLoop		$00, $05, ScrabBrain_Loop2
	dc.b nG3
	saVol		$03
	sGate		$06

ScrabBrain_Loop5:
	sCall		ScrabBrain_Call5

ScrabBrain_Loop3:
	dc.b nG4, nG4, nD4, nD4, nF4, nF4, nD4, nD4
	sLoop		$00, $04, ScrabBrain_Loop3

ScrabBrain_Loop4:
	dc.b nF4, nF4, nC4, nC4, nEb4, nEb4, nC4, nC4
	sLoop		$00, $04, ScrabBrain_Loop4
	sCall		ScrabBrain_Call5
	sLoop		$01, $02, ScrabBrain_Loop5
	sPan		spLeft, $00
	sCall		ScrabBrain_Call2
	sPan		spCenter, $00

ScrabBrain_Loop6:
	dc.b nC4, $03, nC4, nG3, nG3, nA3, nA3, nG3
	dc.b nG3
	sLoop		$00, $02, ScrabBrain_Loop6

ScrabBrain_Loop7:
	dc.b nFs4, nFs4, nCs4, nCs4, nEb4, nEb4, nCs4, nCs4
	sLoop		$00, $02, ScrabBrain_Loop7

ScrabBrain_Loop8:
	dc.b nF4, nF4, nC4, nC4, nD4, nD4, nC4, nC4
	sLoop		$00, $02, ScrabBrain_Loop8

ScrabBrain_Loop9:
	dc.b nG4, nG4, nD4, nD4, nE4, nE4, nD4, nD4
	sLoop		$00, $02, ScrabBrain_Loop9
	sLoop		$01, $04, ScrabBrain_Loop6
	sGate		$00
	sJump		ScrabBrain_FM2

ScrabBrain_Call5:
	dc.b nA4, $03, nA4, nE4, nE4, nG4, nG4, nE4
	dc.b nE4
	sLoop		$00, $04, ScrabBrain_Call5
	sRet

ScrabBrain_FM3:
	sVoice		$01
	sGate		$06
	dc.b nA4, $03, nB4, nRst, nC5, nRst, nD5, nE5
	sGate		$00
	dc.b nG5, $4B
	sVoice		$03
	ssDetune	$03
	saVol		$FA
	sCall		ScrabBrain_Call1
	sVoice		$00
	sPan		spRight, $00
	sGate		$06
	sCall		ScrabBrain_Call2
	sPan		spCenter, $00
	sVoice		$03
	sGate		$00
	saVol		$FE

ScrabBrain_Loop10:
	sCall		ScrabBrain_Call4
	sLoop		$00, $02, ScrabBrain_Loop10
	saVol		$08
	sJump		ScrabBrain_FM3

ScrabBrain_FM4:
	sVoice		$04
	sPan		spLeft, $00
	ssMod68k	$5C, $01, $05, $04
	sGate		$06
	sCall		ScrabBrain_Call6
	ssDetune	$04
	sCall		ScrabBrain_Call7
	saVol		$06
	sVoice		$05
	ssDetune	$02
	saVol		$ED
	saTranspose	$F4
	sCall		ScrabBrain_Call2
	saVol		$13
	saTranspose	$0C
	saVol		$F3
	sVoice		$04
	sModOff
	saVol		$FA

ScrabBrain_Loop12:
	sModOff
	sCall		ScrabBrain_Call8
	dc.b nRst, $0C, nA5, $02
	ssDetune	$00
	dc.b sHold, $0A, nRst, $03, nA5, nRst, nRst, nA5
	dc.b nRst, $09
	sCall		ScrabBrain_Call8
	dc.b nA5, $02
	ssDetune	$00
	dc.b $0A, nRst, $06
	ssMod68k	$18, $01, $07, $04
	ssDetune	$E2
	dc.b nA5, $02, sHold
	ssDetune	$00
	dc.b $1C
	sLoop		$00, $02, ScrabBrain_Loop12
	saVol		$06
	saVol		$01
	sJump		ScrabBrain_FM4

ScrabBrain_Call6:
	dc.b nE5, $03, nE5, nRst, nE5, nRst, nE5, nE5
	sGate		$00
	dc.b nD5, $4B
	sRet

ScrabBrain_Call7:
	sVoice		$02
	saVol		$06
	ssMod68k	$08, $01, $08, $04

ScrabBrain_Loop11:
	dc.b nRst, $60, nRst, nRst, nE6, $18, nFs6, nG6
	dc.b nAb6
	sLoop		$00, $02, ScrabBrain_Loop11
	sRet

ScrabBrain_Call8:
	dc.b nRst, $0C
	ssDetune	$EC
	dc.b nG5, $02
	ssDetune	$00
	dc.b sHold, $06, nRst, $01, nG5, $03, nRst, $18
	dc.b nRst, $0C
	ssDetune	$EC
	dc.b nCs6, $02
	ssDetune	$00
	dc.b sHold, $06, nRst, $01, nCs6, $03, nRst, $18
	dc.b nRst, $0C
	ssDetune	$EC
	dc.b nC6, $02
	ssDetune	$00
	dc.b sHold, $06, nRst, $01, nC6, $03, nRst, $18
	ssDetune	$EC
	sRet

ScrabBrain_FM5:
	sVoice		$04
	sPan		spRight, $00
	ssMod68k	$5C, $01, $05, $04
	sGate		$06
	dc.b nC5, $03, nC5, nRst, nC5, nRst, nC5, nC5
	sGate		$00
	dc.b nB4, $4B
	sCall		ScrabBrain_Call7
	saVol		$06

ScrabBrain_Loop13:
	dc.b nRst, $60
	sLoop		$00, $01, ScrabBrain_Loop13
	sVoice		$06
	saVol		$EB
	saTranspose	$0C
	sModOff

ScrabBrain_Loop14:
	sCall		ScrabBrain_Call9
	dc.b nE6, nF6, nG6
	sCall		ScrabBrain_Call9
	dc.b nG6, nF6, nE6
	sLoop		$00, $02, ScrabBrain_Loop14
	saVol		$09
	saTranspose	$F4
	sJump		ScrabBrain_FM5

ScrabBrain_Call9:
	dc.b nRst, $03, nE6, nC6, $06, $06, nG5, nC6
	dc.b $09, nE6, $09, nRst, $06, nRst, $03, nF6
	dc.b nCs6, $06, $06, nBb5, nCs6, $09, nF6, $09
	dc.b nRst, $06, nRst, $03, nE6, nC6, $06, $06
	dc.b nA5, nC6, $09, nE6, $0F, nD6, $0C
	sRet

ScrabBrain_PSG1:
	saVol		$08
	sVolEnv		v00
	sCall		ScrabBrain_Call6
	sVolEnv		v06
	saVol		-$08
	sCall		ScrabBrain_Loop11
	dc.b nRst, $60
	sVolEnv		v00
	saVol		-$08

ScrabBrain_Loop15:
	sCall		ScrabBrain_Call10
	dc.b nRst, $0C, nF5, nRst, $03, nF5, nRst, nRst
	dc.b nF5, nRst, $09
	sCall		ScrabBrain_Call10
	dc.b nF5, $0C, nRst, $06, nF5, $1E
	sLoop		$00, $02, ScrabBrain_Loop15
	saVol		$08
	sJump		ScrabBrain_PSG1

ScrabBrain_Call10:
	dc.b nRst, $0C, nE5, $07, nRst, $02, nE5, $03
	dc.b nRst, $18, nRst, $0C, nBb5, $07, nRst, $02
	dc.b nBb5, $03, nRst, $18, nRst, $0C, nA5, $07
	dc.b nRst, $02, nA5, $03, nRst, $18
	sRet

ScrabBrain_PSG2:
	sVolEnv		v00
	saVol		$08
	dc.b nC5, $03, nC5, nRst, nC5, nRst, nC5, nC5
	sGate		$00
	dc.b nB4, $4B
	saVol		-$08

ScrabBrain_Loop18:
	sVolEnv		v05
	sGate		$03
	sCall		ScrabBrain_Call11

ScrabBrain_Loop16:
	dc.b nG6, nG6, nD7, nG6, nC7, nG6, nB6, nG6
	sLoop		$00, $04, ScrabBrain_Loop16

ScrabBrain_Loop17:
	dc.b nA6, nA6, nEb7, nA6, nD7, nA6, nC7, nA6
	sLoop		$00, $04, ScrabBrain_Loop17
	sCall		ScrabBrain_Call11
	sLoop		$01, $02, ScrabBrain_Loop18
	dc.b nRst, $60
	saVol		$08

ScrabBrain_Loop19:
	dc.b nC7, $03, nC7, nG7, nC7, nF7, nC7, nE7
	dc.b nC7
	sLoop		$00, $02, ScrabBrain_Loop19

ScrabBrain_Loop20:
	dc.b nBb6, nBb6, nF7, nBb6, nEb7, nBb6, nCs7, nBb6
	sLoop		$00, $02, ScrabBrain_Loop20

ScrabBrain_Loop21:
	dc.b nA6, nA6, nE7, nA6, nD7, nA6, nC7, nA6
	sLoop		$00, $04, ScrabBrain_Loop21
	sLoop		$01, $04, ScrabBrain_Loop19
	saVol		-$08
	sJump		ScrabBrain_PSG2

ScrabBrain_Call11:
	dc.b nA6, $03, nA6, nE7, nA6, nD7, nA6, nC7
	dc.b nA6
	sLoop		$00, $04, ScrabBrain_Call11
	sRet

ScrabBrain_PSG3:
	sNoisePSG	$E7
	sGate		$03
	dc.b nHiHat, $03, $06, nRst, nHiHat, $06, $0F, $0C
	dc.b $0C, $0C, $18

ScrabBrain_Loop22:
	dc.b nHiHat, $03, $03
	saVol		$10
	sVolEnv		v08
	sGate		$08
	dc.b $06
	sVolEnv		v04
	sGate		$03
	saVol		-$10
	sLoop		$00, $88, ScrabBrain_Loop22
	sJump		ScrabBrain_PSG3

ScrabBrain_DAC1:
	dc.b dSnare, $03, $06, $06, $03, $03, $0F, dKick
	dc.b $0C, nRst, $0C, dKick, dKick, $06, dSnare, dSnare
	dc.b dSnare, $03, $03

ScrabBrain_Loop23:
	dc.b dKick, $0C, dSnare, dKick, dSnare, dKick, dSnare, $01
	dc.b dMidTimpani, $05, dHiTimpani, $06, dKick, $01, dMidTimpani, $05
	dc.b dHiTimpani, $06, dSnare, $01, dMidTimpani, $05, dHiTimpani, $06
	sLoop		$00, $02, ScrabBrain_Loop23
	dc.b dKick, $0C, dSnare, dKick, dSnare, dKick, dSnare, dKick
	dc.b dSnare, $06, dHiTimpani, $03, dHiTimpani, dKick, $0C, dSnare
	dc.b dKick, dSnare, dKick, $06, dHiTimpani, dSnare, $01, dMidTimpani
	dc.b $05, dHiTimpani, $06, dKick, $01, dMidTimpani, $05, dSnare
	dc.b $01, dHiTimpani, $05, dSnare, $01, dMidTimpani, $05, dSnare
	dc.b $03, $03
	sLoop		$01, $02, ScrabBrain_Loop23

ScrabBrain_Loop24:
	dc.b dSnare, $03, dSnare, dKick, dKick, dKick, dKick, dSnare
	dc.b dSnare, dKick, dKick, dKick, dKick, dSnare, dSnare, dSnare
	dc.b dSnare
	sLoop		$00, $02, ScrabBrain_Loop24

ScrabBrain_Loop25:
	sCall		ScrabBrain_Call12
	dc.b dHiTimpani, $02, dKick, $01, dMidTimpani, $05, dSnare, $01
	dc.b dHiTimpani, $05, dMidTimpani, $06
	sCall		ScrabBrain_Call12
	dc.b dMidTimpani, $02, dSnare, $01, dHiTimpani, $05, dSnare, $01
	dc.b dMidTimpani, $05, dSnare, $01, dHiTimpani, $02, dSnare, $03
	sLoop		$01, $02, ScrabBrain_Loop25
	sJump		ScrabBrain_DAC1

ScrabBrain_Call12:
	dc.b dKick, $0C, dSnare, $09, dKick, $06, $03, dKick
	dc.b $01, dHiTimpani, $02, dMidTimpani, $03, dSnare, $01, dHiTimpani
	dc.b $0B
	sLoop		$00, $03, ScrabBrain_Call12
	dc.b dKick, $0C, dSnare, $09, dKick, $06, dSnare, $01
	sRet

ScrabBrain_Call1:
	dc.b nA6, $1E, nG6, $06, nF6, nG6, nE6, $30
	dc.b nG6, $1E, nF6, $06, nE6, nF6, nD6, $30
	dc.b nF6, $1E, nEb6, $06, nD6, nEb6, nC6, $18
	dc.b nD6, nE6, $03, nF6, nE6, $5A
	sLoop		$00, $02, ScrabBrain_Call1
	sRet

ScrabBrain_Call4:
	dc.b nG6, $1E, nE6, $06, nC6, nC7, nBb6, $0C
	dc.b nC7, $06, nBb6, $0C, nG6, $06, nBb6, nA6
	dc.b $24, nE6, $06, nF6, nG6, $12, nA6, $06
	dc.b nG6, $12, nE6, $0C, nG6, $1E, nE6, $06
	dc.b nC6, nC7, nBb6, $0C, nC7, $06, nBb6, $0C
	dc.b nG6, $06, nBb6, nA6, $24, nE6, $06, nF6
	dc.b nG6, $30, nRst, $06
	sRet

ScrabBrain_Call2:
	sCall		ScrabBrain_Call3
	dc.b nG4, nG4, $09
	sCall		ScrabBrain_Call3
	dc.b nRst, $0C
	sRet

ScrabBrain_Call3:
	dc.b nA4, $03, nA4, nAb4, nAb4, nG4, nG4, nA4
	dc.b nA4, nAb4, nAb4, nG4, nG4
	sRet

ScrabBrain_DAC2:
	sStop
