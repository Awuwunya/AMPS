SpecialStage_Header:
	sHeaderInit
	sHeaderTempo	$02, $20
	sHeaderCh	$06, $02
	sHeaderDAC	SpecialStage_DAC1
	sHeaderDAC	SpecialStage_DAC2
	sHeaderFM	SpecialStage_FM1, $DC, $18
	sHeaderFM	SpecialStage_FM2, $DC, $0C
	sHeaderFM	SpecialStage_FM3, $E8, $18
	sHeaderFM	SpecialStage_FM4, $E8, $18
	sHeaderFM	SpecialStage_FM5, $E8, $18
	sHeaderFM	SpecialStage_FM6, $E8, $14
	sHeaderPSG	SpecialStage_PSG1, $DC+$0C, $18, $00, v04
	sHeaderPSG	SpecialStage_PSG2, $FD+$0C, $08, $00, v08

	; Patch $00
	; $2C
	; $74, $74, $34, $34,	$1F, $12, $1F, $1F
	; $00, $00, $00, $00,	$00, $01, $00, $01
	; $00, $36, $00, $36,	$16, $80, $17, $80
	spAlgorithm	$04
	spFeedback	$05
	spDetune	$07, $03, $07, $03
	spMultiple	$04, $04, $04, $04
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $12, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$00, $00, $00, $00
	spSustainLv	$00, $00, $03, $03
	spDecayRt	$00, $00, $01, $01
	spReleaseRt	$00, $00, $06, $06
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$16, $17, $00, $00

	; Patch $01
	; $2C
	; $72, $78, $34, $34,	$1F, $12, $1F, $12
	; $00, $0A, $00, $0A,	$00, $00, $00, $00
	; $00, $16, $00, $16,	$16, $80, $17, $80
	spAlgorithm	$04
	spFeedback	$05
	spDetune	$07, $03, $07, $03
	spMultiple	$02, $04, $08, $04
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $12, $12
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$00, $00, $0A, $0A
	spSustainLv	$00, $00, $01, $01
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$00, $00, $06, $06
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$16, $17, $00, $00

	; Patch $02
	; $30
	; $30, $30, $30, $30,	$9E, $D8, $DC, $DC
	; $0E, $0A, $04, $05,	$08, $08, $08, $08
	; $B0, $B0, $B0, $B5,	$14, $3C, $14, $80
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
	spReleaseRt	$00, $00, $00, $05
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$14, $14, $3C, $00

	; Patch $03
	; $3D
	; $01, $02, $00, $01,	$1F, $10, $10, $10
	; $07, $1F, $1F, $1F,	$00, $00, $00, $00
	; $10, $07, $07, $07,	$17, $80, $80, $80
	spAlgorithm	$05
	spFeedback	$07
	spDetune	$00, $00, $00, $00
	spMultiple	$01, $00, $02, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $10, $10, $10
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$07, $1F, $1F, $1F
	spSustainLv	$01, $00, $00, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$00, $07, $07, $07
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$17, $00, $00, $00

SpecialStage_FM1:
	sVoice		$00

SpecialStage_Loop1:
	dc.b nE5, $18, nF5, $0C, nG5, $18, nE5, $0C
	dc.b $18, nC5, $0C, nE5, $18, nC5, $0C, nE5
	dc.b $18, nF5, $0C, nG5, $18, nE5, $0C, nC5
	dc.b $18, nD5, $0C, nC5, $24
	sLoop		$00, $02, SpecialStage_Loop1
	dc.b sHold, $03, nRst, $09, nD5, $0C, nE5, nF5
	dc.b nE5, nF5, nG5, $18, nE5, $0C, nC5, $24
	dc.b nRst, $0C, nD5, nE5, nF5, nE5, nF5, nG5
	dc.b $18, nA5, $0C, nG5, $21, nRst, $03
	sJump		SpecialStage_Loop1

SpecialStage_FM2:
	sVoice		$02

SpecialStage_Loop2:
	dc.b nF5, $0C, nRst, $18, nE5, $0C, nRst, $18
	dc.b nD5, $0C, nRst, $18, nC5, $0C, nD5, nE5
	dc.b nF5, $0C, nRst, $18, nE5, $0C, nRst, $18
	dc.b nD5, $12, nE5, $06, nD5, $0C, nC5, $24
	sLoop		$00, $02, SpecialStage_Loop2
	dc.b nBb4, $0C, nRst, $18, nBb4, $0C, nRst, $18
	dc.b nC5, $0C, nRst, $18, nC5, $0C, nRst, $18
	dc.b nBb4, $0C, nRst, $18, nBb4, $0C, nRst, $18
	dc.b nD5, $0C, nRst, $18, nG5, $24
	sJump		SpecialStage_Loop2

SpecialStage_FM3:
	sVoice		$03
	ssMod68k	$1A, $01, $04, $06
	sPan		spCenter, $00

SpecialStage_Loop3:
	sCall		SpecialStage_Call1
	dc.b nRst, nC7, $03, nRst, $09, nC7, $0C, nB6
	dc.b nC7, nD7
	sCall		SpecialStage_Call1
	dc.b nC7, $12, nD7, $06, nC7, $0C, nB6, $24
	sLoop		$00, $02, SpecialStage_Loop3
	sCall		SpecialStage_Call2
	dc.b nRst, nB6, $03, nRst, $09, nB6, $0C, nRst
	dc.b nB6, $03, nRst, $09, nB6, $0C
	sCall		SpecialStage_Call2
	dc.b nRst, nC7, $03, nRst, $09, nC7, $0C, $24
	sJump		SpecialStage_Loop3

SpecialStage_Call1:
	dc.b nRst, $0C, nE7, $03, nRst, $09, nE7, $0C
	dc.b nRst, nD7, $03, nRst, $09, nD7, $0C
	sRet

SpecialStage_Call2:
	dc.b nRst, $0C, nA6, $03, nRst, $09, nA6, $0C
	dc.b nRst, nA6, $03, nRst, $09, nA6, $0C
	sRet

SpecialStage_FM4:
	sVoice		$03
	ssMod68k	$1A, $01, $04, $06
	sPan		spRight, $00

SpecialStage_Loop4:
	sCall		SpecialStage_Call3
	dc.b nRst, nA6, $03, nRst, $09, nA6, $0C, nG6
	dc.b nA6, nB6
	sCall		SpecialStage_Call3
	dc.b nA6, $12, nB6, $06, nA6, $0C, nG6, $24
	sLoop		$00, $02, SpecialStage_Loop4
	sCall		SpecialStage_Call4
	dc.b nRst, nG6, $03, nRst, $09, nG6, $0C, nRst
	dc.b nG6, $03, nRst, $09, nG6, $0C
	sCall		SpecialStage_Call4
	dc.b nRst, nA6, $03, nRst, $09, nA6, $0C, $24
	sJump		SpecialStage_Loop4

SpecialStage_Call3:
	dc.b nRst, $0C, nC7, $03, nRst, $09, nC7, $0C
	dc.b nRst, nB6, $03, nRst, $09, nB6, $0C
	sRet

SpecialStage_Call4:
	dc.b nRst, $0C, nF6, $03, nRst, $09, nF6, $0C
	dc.b nRst, nF6, $03, nRst, $09, nF6, $0C
	sRet

SpecialStage_FM5:
	sVoice		$03
	ssMod68k	$1A, $01, $04, $06
	sPan		spLeft, $00

SpecialStage_Loop5:
	sCall		SpecialStage_Call5
	dc.b nRst, nF6, $03, nRst, $09, nF6, $0C, nE6
	dc.b nF6, nG6
	sCall		SpecialStage_Call5
	dc.b nF6, $12, nG6, $06, nF6, $0C, nE6, $24
	sLoop		$00, $02, SpecialStage_Loop5
	sCall		SpecialStage_Call6
	dc.b nRst, nE6, $03, nRst, $09, nE6, $0C, nRst
	dc.b nE6, $03, nRst, $09, nE6, $0C
	sCall		SpecialStage_Call6
	dc.b nRst, nF6, $03, nRst, $09, nF6, $0C, $24
	sJump		SpecialStage_Loop5

SpecialStage_Call5:
	dc.b nRst, $0C, nA6, $03, nRst, $09, nA6, $0C
	dc.b nRst, nG6, $03, nRst, $09, nG6, $0C
	sRet

SpecialStage_Call6:
	dc.b nRst, $0C, nD6, $03, nRst, $09, nD6, $0C
	dc.b nRst, nD6, $03, nRst, $09, nD6, $0C
	sRet

SpecialStage_PSG1:
	sGate		$06

SpecialStage_Loop7:
	sCall		SpecialStage_Call7
	dc.b nC6, $06, $06, nA5, $03, nRst, $09, nF5
	dc.b $03, nRst, $09, nB5, $03, nRst, $21
	sCall		SpecialStage_Call7
	dc.b nC6, $03, nRst, $15, nD6, $03, nRst, $09
	dc.b nC6, $03, nRst, $21
	sLoop		$00, $02, SpecialStage_Loop7
	sCall		SpecialStage_Call8
	dc.b nB6, $06, $06, nG6, nG6, nE6, nE6, nB6
	dc.b nB6, nG6, nG6, nE6, $03, nRst, $09
	sCall		SpecialStage_Call8
	dc.b nC7, $06, $06, nA6, nA6, nF6, nF6, nG6
	dc.b $09, nRst, $1B
	sJump		SpecialStage_Loop7

SpecialStage_Call7:
	dc.b nE6, $06, $06, nC6, $03, nRst, $09, nA5
	dc.b $03, nRst, $09, nD6, $06, $06, nB5, $03
	dc.b nRst, $09, nG5, $03, nRst, $09
	sRet

SpecialStage_Call8:
	dc.b nA6, $06, $06, nF6, nF6, nD6, nD6, nA6
	dc.b nA6, nF6, nF6, nD6, $03, nRst, $09
	sRet

SpecialStage_PSG2:
	dc.b nRst, $0C, nC5, nC5, nRst, nC5, nC5, nRst
	dc.b nC5, nC5, nRst, nC5, $06, $06, $0C, nRst
	dc.b nC5, nC5, nRst, nC5, nC5, nRst, nC5, nC5
	dc.b nC5, $24
	sJump		SpecialStage_PSG2

SpecialStage_DAC1:
SpecialStage_DAC2:
	sStop

SpecialStage_FM6:
	sVoice		$01

SpecialStage_Loop6:
	dc.b nE7, $18, nF7, $0C, nG7, $18, nE7, $0C
	dc.b $18, nC7, $0C, nE7, $18, nC7, $0C, nE7
	dc.b $18, nF7, $0C, nG7, $18, nE7, $0C, nC7
	dc.b $18, nD7, $0C, nC7, $24
	sLoop		$00, $02, SpecialStage_Loop6
	dc.b nRst, $0C, nD7, nE7, nF7, nE7, nF7, nG7
	dc.b $18, nE7, $0C, nC7, $24, nRst, $0C, nD7
	dc.b nE7, nF7, nE7, nF7, nG7, $18, nA7, $0C
	dc.b nG7, $21, nRst, $03
	sJump		SpecialStage_Loop6

