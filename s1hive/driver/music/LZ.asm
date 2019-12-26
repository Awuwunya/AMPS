Labyrinth_Header:
	sHeaderInit
	sHeaderTempo	$02, $28
	sHeaderCh	$05, $03
	sHeaderDAC	Labyrinth_DAC1, $00, $00
	sHeaderDAC	Labyrinth_DAC2, $00, $00
	sHeaderFM	Labyrinth_FM1, $F4, $0C
	sHeaderFM	Labyrinth_FM2, $E8, $0D
	sHeaderFM	Labyrinth_FM3, $F4, $18
	sHeaderFM	Labyrinth_FM4, $F4, $18
	sHeaderFM	Labyrinth_FM5, $00, $12
	sHeaderPSG	Labyrinth_PSG1, $D0+$0C, $10, $00, v09
	sHeaderPSG	Labyrinth_PSG2, $D0+$0C, $10, $00, v09
	sHeaderPSG	Labyrinth_PSG3, $00, $10, $00, v04

	; Patch $00
	; $31
	; $34, $35, $30, $31,	$DF, $DF, $9F, $9F
	; $0C, $07, $0C, $09,	$07, $07, $07, $08
	; $2F, $1F, $1F, $2F,	$17, $32, $14, $80
	spAlgorithm	$01
	spFeedback	$06
	spDetune	$03, $03, $03, $03
	spMultiple	$04, $00, $05, $01
	spRateScale	$03, $02, $03, $02
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0C, $0C, $07, $09
	spSustainLv	$02, $01, $01, $02
	spDecayRt	$07, $07, $07, $08
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$17, $14, $32, $00

	; Patch $01
	; $18
	; $37, $30, $30, $31,	$9E, $DC, $1C, $9C
	; $0D, $06, $04, $01,	$08, $0A, $03, $05
	; $BF, $BF, $3F, $2F,	$2C, $22, $14, $80
	spAlgorithm	$00
	spFeedback	$03
	spDetune	$03, $03, $03, $03
	spMultiple	$07, $00, $00, $01
	spRateScale	$02, $00, $03, $02
	spAttackRt	$1E, $1C, $1C, $1C
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0D, $04, $06, $01
	spSustainLv	$0B, $03, $0B, $02
	spDecayRt	$08, $03, $0A, $05
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$2C, $14, $22, $00

	; Patch $02
	; $3A
	; $01, $07, $01, $01,	$8E, $8E, $8D, $53
	; $0E, $0E, $0E, $03,	$00, $00, $00, $00
	; $1F, $FF, $1F, $0F,	$18, $28, $27, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$00, $00, $00, $00
	spMultiple	$01, $01, $07, $01
	spRateScale	$02, $02, $02, $01
	spAttackRt	$0E, $0D, $0E, $13
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0E, $0E, $0E, $03
	spSustainLv	$01, $01, $0F, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$18, $27, $28, $00

	; Patch $03
	; $3D
	; $01, $02, $02, $02,	$14, $0E, $8C, $0E
	; $08, $05, $02, $05,	$00, $00, $00, $00
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
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1A, $27, $12, $00

	; Patch $04
	; $3C
	; $31, $52, $50, $30,	$52, $53, $52, $53
	; $08, $00, $08, $00,	$04, $00, $04, $00
	; $1F, $0F, $1F, $0F,	$1A, $80, $16, $80
	spAlgorithm	$04
	spFeedback	$07
	spDetune	$03, $05, $05, $03
	spMultiple	$01, $00, $02, $00
	spRateScale	$01, $01, $01, $01
	spAttackRt	$12, $12, $13, $13
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$08, $08, $00, $00
	spSustainLv	$01, $01, $00, $00
	spDecayRt	$04, $04, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1A, $16, $00, $00

Labyrinth_FM1:
	dc.b nRst, $30
	sVoice		$00

Labyrinth_Loop1:
	dc.b nRst, $06, nE5, nG5, nE5, nG5, $09, nA5
	dc.b nB5, $0C, nC6, $06, nB5, nA5, nG5, $09
	dc.b nA5, $06, nG5, $03, nE5, $06
	sLoop		$00, $02, Labyrinth_Loop1
	sCall		Labyrinth_Call1
	dc.b nC6, $09, nD6, $06, nC6, $03, nA5, $06
	sCall		Labyrinth_Call1
	dc.b nC6, $0C, nA5, nD6, $04, nC6, nD6, nC6
	dc.b $24, nRst, $30
	sCall		Labyrinth_Call2
	dc.b nC6, $0C, nC6, $06, nC6, nD6, $09, nC6
	dc.b nE6, $36
	sCall		Labyrinth_Call2
	dc.b nF6, $06, nE6, nD6, nC6, nBb5, nA5, nG5
	dc.b nF5, nE5, nC6, $12, nRst, $18
	sJump		Labyrinth_Loop1

Labyrinth_Call1:
	dc.b nRst, nA5, nC6, nA5, nC6, $09, nD6, nE6
	dc.b $0C, nF6, $06, nE6, nD6
	sRet

Labyrinth_Call2:
	dc.b nC6, $0C, nC6, $06, nC6, nD6, $09, nC6
	dc.b nF6, $0C, nE6, $06, nD6, nC6, nD6, $09
	dc.b nE6, $0F
	sRet

Labyrinth_FM2:
	dc.b nRst, $12
	sVoice		$01
	dc.b nD4, $0C, nG4, $03, nRst, nG4
	dc.b nRst, $09

Labyrinth_Loop2:
	dc.b nC4, $0F, nRst, $03, nE4, nRst, nG4, $09
	dc.b nRst, $03, nA4, $09, nRst, $03, nB4, $0F
	dc.b nRst, $03, nA4, nRst, nG4, $09, nRst, $03
	dc.b nE4, $09, nRst, $03
	sLoop		$00, $02, Labyrinth_Loop2

Labyrinth_Loop3:
	dc.b nF4, $0F, nRst, $03, nA4, nRst, nC5, $09
	dc.b nRst, $03, nD5, $09, nRst, $03, nE5, $0F
	dc.b nRst, $03, nD5, nRst, nC5, $09, nRst, $03
	dc.b nA4, $09, nRst, $03
	sLoop		$00, $02, Labyrinth_Loop3
	dc.b nC4, $0F, nRst, $03, nE4, nRst, nG4, $09
	dc.b nRst, $03, nE4, $09, nRst, $03, nC5, nRst
	dc.b nC5, $06, nG4, nC5, nFs4, $18
	sCall		Labyrinth_Call3
	dc.b nE4, nRst, nRst, nE4, nA4, nRst, nRst, nA4
	dc.b nA4, $18
	sCall		Labyrinth_Call3
	dc.b nBb4, nRst, nRst, nBb4, nC5, nRst, nRst, nC5
	dc.b nG4, $0C, nG4
	sJump		Labyrinth_Loop2

Labyrinth_Call3:
	dc.b nF4, $06, nRst, nRst, nF4, nE4, nRst, nRst
	dc.b nE4, nD4, nRst, nRst, nD4, nC4, nD4, nE4
	dc.b $0C, nF4, $06, nRst, nRst, nF4
	sRet

Labyrinth_FM3:
	sPan		spLeft, $00
	sCall		Labyrinth_Call4
	ssMod68k	$01, $01, $01, $04

Labyrinth_Jump1:
	dc.b nRst, $60, nRst, nRst, nRst, nRst, nE6, $48
	dc.b nF6, $0C, nG6, nC6, $30, nRst, nE6, $48
	dc.b nF6, $0C, nG6, nC6, $18, nD6, nE6, nG6
	sJump		Labyrinth_Jump1

Labyrinth_Call4:
	sVoice		$03
	sGate		$08
	dc.b nA6, $06, nF6, nD6
	sGate		$00
	dc.b nG6, $0A, nRst, $02, nG6, $03, nRst, nG6
	dc.b nRst, $09
	sRet

Labyrinth_FM4:
	sPan		spRight, $00
	ssDetune	$02
	sCall		Labyrinth_Call4
	ssMod68k	$02, $01, $02, $04
	sJump		Labyrinth_Jump1

Labyrinth_FM5:
	sVoice		$02
	sGate		$08
	dc.b nC5, $06, nA4, nF4
	sGate		$00
	dc.b nC5, $09, nRst, $03, nC5, nRst, nC5, nRst
	dc.b $09
	saVol		$03

Labyrinth_Jump2:
	sVoice		$04
	dc.b nRst, $4E, nG4, $03, nA4, nC5, nRst, nA4
	dc.b nRst, $51, nE5, $03, nC5, nA4, nRst, nC5
	dc.b nRst, $51, nC5, $03, nD5, nF5, nRst, nD5
	dc.b nRst, $51, nA5, $03, nF5, nC5, nRst, nF5
	dc.b nRst, $39, nG4, $06, nRst, nA4, nRst, nBb4
	dc.b $03, nRst, nBb4, nRst, nCs5, nRst
	sGate		$0A
	sCall		Labyrinth_Call5
	dc.b nRst, $06, nA4, nRst, nB4, nRst, nCs5, nCs5
	dc.b nE5
	sCall		Labyrinth_Call5
	sGate		$05
	dc.b nRst, $06, nG4, $03, nA4

Labyrinth_Loop4:
	dc.b nC5, nC5, nA4, nG4
	sLoop		$00, $03, Labyrinth_Loop4
	sGate		$00
	sJump		Labyrinth_Jump2

Labyrinth_Call5:
	dc.b nE5, $12, $06, nD5, $12, $06, nC5, $12
	dc.b $06, nB4, nC5
	sGate		$14
	dc.b nD5, $0C
	sGate		$0A
	dc.b nE5, $12, $06, nD5, $12, $06
	sRet

Labyrinth_PSG1:
	dc.b nA6, $03, nA6, nF6, nF6, nD6, nD6, $21

Labyrinth_Loop5:
	sCall		Labyrinth_Call6
	saTranspose	$05
	sLoop		$00, $02, Labyrinth_Loop5
	saTranspose	$F6
	dc.b nRst, $06, nE6, $0C, $0C, $0C, $06, nRst
	dc.b $06, nE6, $03, $09, $0C, nBb6, nBb6, $06
	sCall		Labyrinth_Call7
	dc.b nG6, $03, $09, $06, nRst, $06, nB6, $0C
	dc.b $0C, $03, $09, $06
	sCall		Labyrinth_Call7
	dc.b nBb6, $03, $09, $06, nRst, $06, nE6, $0C
	dc.b $06, nD6, nF6, nA6, $0C
	sJump		Labyrinth_Loop5

Labyrinth_Call6:
	dc.b nRst, $06, nE6, $0C, $0C, $0C, $06, nRst
	dc.b nE6, $0C, $0C, $03, $09, $06, nRst, nE6
	dc.b $0C, $0C, $0C, $06, nRst, nE6, $0C, $0C
	dc.b $03, $09, $06
	sRet

Labyrinth_Call7:
	dc.b nRst, $06, nA6, $0C, nA6, nG6, $03, $09
	dc.b $06, nRst, nF6, $0C, $0C, nE6, $03, $09
	dc.b $06, nRst, nA6, $0C, $0C
	sRet

Labyrinth_PSG2:
	dc.b nC7, $03, nC7, nA6, nA6, nF6, nF6, $21

Labyrinth_Jump3:
	saTranspose	$03

Labyrinth_Loop6:
	sCall		Labyrinth_Call6
	saTranspose	$05
	sLoop		$00, $02, Labyrinth_Loop6
	saTranspose	$F3
	dc.b nRst, $06, nG6, $0C, $0C, $0C, $06, nRst
	dc.b $06, nG6, $03, $09, $0C, nCs7, $0C, $06
	sCall		Labyrinth_Call8
	dc.b nB6, $03, $09, $06, nRst, $06, nD7, $0C
	dc.b $0C, nCs7, $03, $09, $06
	sCall		Labyrinth_Call8
	dc.b nD7, $03, $09, $06, nRst, $06, nG6, $0C
	dc.b $06, nF6, $06, nA6, nC7, $0C
	sJump		Labyrinth_Jump3

Labyrinth_Call8:
	dc.b nRst, $06, nC7, $0C, $0C, nB6, $03, $09
	dc.b $06, nRst, nA6, $0C, $0C, nG6, $03, $09
	dc.b $06, nRst, nC7, $0C, $0C
	sRet

Labyrinth_PSG3:
	sNoisePSG	$E7
	dc.b nRst, $12
	sGate		$0E
	dc.b nHiHat, $0C
	sGate		$03
	dc.b $06, $0C

Labyrinth_Jump4:
	sCall		Labyrinth_Call9
	sCall		Labyrinth_Call10
	sCall		Labyrinth_Call9
	sGate		$0E
	dc.b $0C
	sGate		$03
	dc.b $06, $06, $03, $03, $06, $03, $03, $06
	sCall		Labyrinth_Call9
	sCall		Labyrinth_Call10
	sCall		Labyrinth_Call9
	sCall		Labyrinth_Call9
	sCall		Labyrinth_Call9
	sCall		Labyrinth_Call9
	sCall		Labyrinth_Call11
	dc.b $03, $03
	sGate		$0E
	dc.b $06
	sGate		$03
	dc.b $03, $03
	sGate		$0E
	dc.b $06
	sCall		Labyrinth_Call11
	saVol		-$08
	sGate		$0E
	dc.b $0C, $0C
	saVol		$08
	sJump		Labyrinth_Jump4

Labyrinth_Call9:
	sGate		$0E
	dc.b $0C
	sGate		$03
	dc.b $06, $06, $06, $06, $06, $06
	sRet

Labyrinth_Call10:
	sGate		$0E
	dc.b $0C
	sGate		$03
	dc.b $06, $06, $06, $06, $06, $03, $03
	sRet

Labyrinth_Call11:
	dc.b nRst, $03
	sGate		$03
	dc.b nHiHat, $06, $06, $03
	sGate		$0E
	dc.b $06
	sGate		$03
	dc.b $06, $06, $06, $06, $06, $06, $06, $06
	sGate		$03
	dc.b $06, $06, $06
	sGate		$0E
	dc.b $06
	sGate		$03
	dc.b $06, $06, $06, $06, $06, $06, $06, $06
	dc.b $06, $06, $06, $06
	sRet

Labyrinth_DAC1:
	dc.b dSnare, $06, dSnare, dSnare, dKick, $0C, dSnare, $06
	dc.b $0C

Labyrinth_Loop7:
	dc.b dKick, $12, dKick, $06, dKick, $0C, dSnare
	sLoop		$00, $09, Labyrinth_Loop7
	dc.b dKick, $12, dKick, $06, dKick, dSnare, dSnare, dSnare
	sCall		Labyrinth_Call12
	dc.b dKick, $0C, dSnare, $06, dKick, dKick, $06, dSnare
	dc.b dSnare, $0C
	sCall		Labyrinth_Call12
	dc.b dKick, $0C, dSnare, $06, dKick, dKick, dSnare, dSnare
	dc.b dSnare
	sJump		Labyrinth_Loop7

Labyrinth_Call12:
	dc.b dKick, $0C, dSnare, $06, dKick, dKick, $0C, dSnare
	dc.b dKick, $0C, dSnare, $06, dKick, dKick, $0C, dSnare
	dc.b dKick, $0C, dSnare, $06, dKick, dKick, $0C, dSnare
	sRet

Labyrinth_DAC2:
	sStop
