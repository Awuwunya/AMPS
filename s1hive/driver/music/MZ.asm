Marble_Header:
	sHeaderInit
	sHeaderTempo	$02, $1C
	sHeaderCh	$05, $03
	sHeaderDAC	Marble_DAC1, $00, $00
	sHeaderDAC	Marble_DAC2, $00, $00
	sHeaderFM	Marble_FM1, $E8, $15
	sHeaderFM	Marble_FM2, $E8, $0E
	sHeaderFM	Marble_FM3, $E8, $15
	sHeaderFM	Marble_FM4, $E8, $17
	sHeaderFM	Marble_FM5, $E8, $17
	sHeaderPSG	Marble_PSG1, $D0+$0C, $18, $00, v08
	sHeaderPSG	Marble_PSG2, $D0+$0C, $28, $00, v08
	sHeaderPSG	Marble_PSG3, $00+$0C, $18, $00, v09

	; Patch $00
	; $22
	; $0A, $13, $05, $11,	$03, $12, $12, $11
	; $00, $13, $13, $00,	$03, $02, $02, $01
	; $1F, $1F, $0F, $0F,	$1E, $18, $26, $81
	spAlgorithm	$02
	spFeedback	$04
	spDetune	$00, $00, $01, $01
	spMultiple	$0A, $05, $03, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$03, $12, $12, $11
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$00, $13, $13, $00
	spSustainLv	$01, $00, $01, $00
	spDecayRt	$03, $02, $02, $01
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1E, $26, $18, $01

	; Patch $01
	; $3A
	; $61, $3C, $14, $31,	$9C, $DB, $9C, $DA
	; $04, $09, $04, $03,	$03, $01, $03, $00
	; $1F, $0F, $0F, $AF,	$21, $47, $31, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$06, $01, $03, $03
	spMultiple	$01, $04, $0C, $01
	spRateScale	$02, $02, $03, $03
	spAttackRt	$1C, $1C, $1B, $1A
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$04, $04, $09, $03
	spSustainLv	$01, $00, $00, $0A
	spDecayRt	$03, $03, $01, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$21, $31, $47, $00

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
	; $23
	; $7C, $32, $00, $00,	$5F, $58, $DC, $DF
	; $04, $0B, $04, $04,	$06, $0C, $08, $08
	; $1F, $1F, $BF, $BF,	$24, $26, $16, $80
	spAlgorithm	$03
	spFeedback	$04
	spDetune	$07, $00, $03, $00
	spMultiple	$0C, $00, $02, $00
	spRateScale	$01, $03, $01, $03
	spAttackRt	$1F, $1C, $18, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$04, $04, $0B, $04
	spSustainLv	$01, $0B, $01, $0B
	spDecayRt	$06, $08, $0C, $08
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$24, $16, $26, $00

	; Patch $04
	; $02
	; $3C, $32, $55, $51,	$1F, $98, $1F, $9F
	; $0F, $11, $0E, $11,	$0E, $05, $08, $05
	; $5F, $0F, $6F, $0F,	$2D, $2D, $2F, $80
	spAlgorithm	$02
	spFeedback	$00
	spDetune	$03, $05, $03, $05
	spMultiple	$0C, $05, $02, $01
	spRateScale	$00, $00, $02, $02
	spAttackRt	$1F, $1F, $18, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0F, $0E, $11, $11
	spSustainLv	$05, $06, $00, $00
	spDecayRt	$0E, $08, $05, $05
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$2D, $2F, $2D, $00

Marble_FM3:
	ssDetune	$02

Marble_FM1:
	sVoice		$00
	dc.b nRst, $24

Marble_Jump1:
	sCall		Marble_Call1
	dc.b nA6, $09, nRst, $03, nA6, $06, nG6, nA6
	dc.b $09, nRst, $03, nA6, $06, nG6, nA6, $09
	dc.b nRst, $03, nA6, $06, nG6, nA6, $0C, nB6
	dc.b nF6, $12, nE6, $35, nRst, $01
	sCall		Marble_Call1
	dc.b nA6, $24, nB6, $0C, nAb6, $24, nB6, $09
	dc.b nRst, $03, nB6, $12, nA6, $4D, nRst, $61
	dc.b nRst, $48
	sJump		Marble_Jump1

Marble_Call1:
	dc.b nA5, $06, nB5, nC6, nE6, nB6, $09, nRst
	dc.b $03, nB6, $06, nA6, nB6, $09, nRst, $03
	dc.b nB6, $06, nA6, nB6, $09, nRst, $03, nB6
	dc.b $06, nA6, nB6, nA6, nE6, nC6, nG6, $0C
	dc.b nA6, $06, sHold, nF6, $4D, nRst, $01
	sRet

Marble_FM4:
	sVoice		$03
	saVol		$F7
	dc.b nRst, $06, nE5, $03, $03, $06, nRst, nE4
	dc.b $1E
	sVoice		$02
	saVol		$09
	dc.b nB6, $06

Marble_Jump3:
	sCall		Marble_Call3
	dc.b nA6, $09, nRst, $03, nA6, nRst, nB6, $06
	dc.b nRst, nA6, $0C, nRst, $06, nA6, $09, nRst
	dc.b $03, nA6, nRst, nB6, $06, nRst, nA6, $0C
	dc.b nRst, $18, nG6, $03, nRst, $0F, nG6, $03
	dc.b nRst, $39, nB6, $06
	sCall		Marble_Call3
	dc.b nF6, $09, nRst, $03, nF6, nRst, nA6, $06
	dc.b nRst, nF6, $0C, nRst, $06, nAb6, $09, nRst
	dc.b $03, nAb6, nRst, nB6, $06, nRst, nAb6, $0C
	dc.b nRst, $18, nC7, $03, nRst, $0F, nC7, $03
	dc.b nRst, $09, nE7, $09, nRst, $03, nE7, nRst
	dc.b nD7, $06, nRst, nC7, $03, nRst, nB6, $12
	sCall		Marble_Call4
	sJump		Marble_Jump3

Marble_Call3:
	dc.b sHold, $03, nRst, nB6, nRst, nC7, $06, nRst
	dc.b nB6, $0C, nRst, $06, nB6, $09, nRst, $03
	dc.b nB6, nRst, nC7, $06, nRst, nB6, $0C, nRst
	dc.b $18, nC7, $03, nRst, $0F, nC7, $03, nRst
	dc.b $1B, nC7, $03, nRst, $0F, nC7, $03, nRst
	dc.b $09
	sRet

Marble_FM5:
	sVoice		$04
	saVol		$FC
	saTranspose	$24
	dc.b nRst, $06, nE4, $03, $03, $06, nRst, nE3
	dc.b $1E
	sVoice		$02
	saTranspose	$DC
	saVol		$04
	dc.b nG6, $06

Marble_Jump4:
	sCall		Marble_Call5
	dc.b nF6, $09, nRst, $03, nF6, nRst, nG6, $06
	dc.b nRst, nF6, $0C, nRst, $06, nF6, $09, nRst
	dc.b $03, nF6, nRst, nG6, $06, nRst, nF6, $0C
	dc.b nRst, $18, nE6, $03, nRst, $0F, nE6, $03
	dc.b nRst, $39, nG6, $06
	sCall		Marble_Call5
	dc.b nD6, $09, nRst, $03, nD6, nRst, nF6, $06
	dc.b nRst, nD6, $0C, nRst, $06, nE6, $09, nRst
	dc.b $03, nE6, nRst, nAb6, $06, nRst, nE6, $0C
	dc.b nRst, $18, nA6, $03, nRst, $0F, nA6, $03
	dc.b nRst, $09, nC7, $09, nRst, $03, nC7, nRst
	dc.b nB6, $06, nRst, nA6, $03, nRst, nAb6, $12
	ssDetune	$03
	sCall		Marble_Call4
	ssDetune	$00
	sJump		Marble_Jump4

Marble_Call5:
	dc.b sHold, $03, nRst, nG6, nRst, nA6, $06, nRst
	dc.b nG6, $0C, nRst, $06, nG6, $09, nRst, $03
	dc.b nG6, nRst, nA6, $06, nRst, nG6, $0C, nRst
	dc.b $18, nA6, $03, nRst, $0F, nA6, $03, nRst
	dc.b $1B, nA6, $03, nRst, $0F, nA6, $03, nRst
	dc.b $09
	sRet

Marble_FM2:
	sVoice		$01
	dc.b nRst, $06, nE4, $03, nE4
	dc.b nE4, $06, nRst, nE3, $24

Marble_Jump2:
	sCall		Marble_Call2

Marble_Loop2:
	dc.b nG3, $03, nRst, nG3, $06, nD4, $03, nRst
	dc.b nD4, $06, nB3, $03, nRst, nB3, $06, nD4
	dc.b $03, nRst, nD4, $06
	sLoop		$01, $02, Marble_Loop2
	dc.b nC4, $03, nRst, nC4, $06, nG4, $03, nRst
	dc.b nG4, $06, nE4, $03, nRst, nE4, $06, nG4
	dc.b $03, nRst, nG4, $06, nB3, $03, nRst, nB3
	dc.b $06, nF4, $03, nRst, nF4, $06, nE4, $03
	dc.b nRst, nE4, $06, nB3, $03, nRst, nB3, $06
	sCall		Marble_Call2
	dc.b nB3, $03, nRst, nB3, $06, nF4, $03, nRst
	dc.b nF4, $06, nD4, $03, nRst, nD4, $06, nF4
	dc.b $03, nRst, nF4, $06, nE4, $03, nRst, nE4
	dc.b $06, nB4, $03, nRst, nB4, $06, nAb4, $03
	dc.b nRst, nAb4, $06, nB4, $03, nRst, nB4, $06
	dc.b nA3, $03, nRst, nA3, $06, nE4, $03, nRst
	dc.b nE4, $06, nC4, $03, nRst, nC4, $06, nE4
	dc.b $03, nRst, nE4, $06, nA3, $03, nRst, nA3
	dc.b $06, nE4, $03, nRst, nE4, $06, nD4, $03
	dc.b nRst, nD4, $06, nE4, $03, nRst, nE4, $06

Marble_Loop3:
	dc.b nA3, $12, nA3, $06, nG3, $12, nG3, $06
	dc.b nF3, $12, nF3, $06, nG3, $12, nG3, $06
	sLoop		$01, $02, Marble_Loop3
	sJump		Marble_Jump2

Marble_Call2:
	dc.b nA3, $03, nRst, nA3, $06, nE4, $03, nRst
	dc.b nE4, $06, nD4, $03, nRst, nD4, $06, nE4
	dc.b $03, nRst, nE4, $06
	sLoop		$00, $02, Marble_Call2

Marble_Loop1:
	dc.b nD4, $03, nRst, nD4, $06, nA4, $03, nRst
	dc.b nA4, $06, nF4, $03, nRst, nF4, $06, nA4
	dc.b $03, nRst, nA4, $06
	sLoop		$00, $02, Marble_Loop1
	sRet

Marble_PSG2:
	dc.b nRst, $02
	ssDetune	$01

Marble_PSG1:
	dc.b nRst, $3C

Marble_Jump5:
	dc.b nRst, $60
	sCall		Marble_Call6
	dc.b nRst, $2A, nF7, $0C, nF7, $06, nD7, $0C
	dc.b nB6, $06, nAb6, $2A, nRst, $48
	sCall		Marble_Call6
	dc.b nRst, $60

Marble_Loop5:
	dc.b nA6, $06, nC7, $03, nA6, nC7, $06, nA6
	dc.b nB6, nG6, nD6, nB6, nF6, nA6, $03, nF6
	dc.b nA6, $06, nF6, nG6, nA6, nB6, nG6
	sLoop		$00, $02, Marble_Loop5
	sJump		Marble_Jump5

Marble_Call6:
	dc.b nRst, $30, nF7, $03, nD7, nA6, nF6, nD7
	dc.b nA6, nF6, nD6, nA6, nF6, nD6, nA5, nF6
	dc.b nD6, nA5, nF5, $27, nRst, $3C
	sRet

Marble_PSG3:
	sNoisePSG	$E7
	saVol		-$08
	dc.b nRst, $06, nA5, $03, $03, $06, nRst, nEb5
	dc.b $24
	saVol		$08

Marble_Jump6:
	sCall		Marble_Call7
	dc.b nFs4, nFs4, nCs5, nCs5, nBb4, nBb4, nCs5, nCs5
	dc.b nFs4, nFs4, nCs5, nCs5, nBb4, nBb4, nCs5, nCs5
	dc.b nB4, nB4, nFs5, nFs5, nEb5, nEb5, nFs5, nFs5
	dc.b nBb4, nBb4, nE5, nE5, nEb5, nEb5, nBb4, nBb4
	sCall		Marble_Call7
	dc.b nBb4, nBb4, nE5, nE5, nCs5, nCs5, nE5, nE5
	dc.b nEb5, nEb5, nB4, nB4, nAb4, nAb4, nB4, nB4
	dc.b nAb4, nAb4, nEb5, nEb5, nB4, nB4, nEb5, nEb5
	dc.b nAb4, nAb4, nEb5, nEb5, nCs5, nCs5, nEb5, nEb5
	saVol		-$08

Marble_Loop6:
	dc.b nAb5, $12, nAb5, $06, nFs5, $12, nFs5, $06
	dc.b nE5, $12, nE5, $06, nFs5, $12, nFs5, $06
	sLoop		$00, $02, Marble_Loop6
	saVol		$08
	sJump		Marble_Jump6

Marble_Call7:
	dc.b nAb4, $06, nAb4, nEb5, nEb5, nCs5, nCs5, nEb5
	dc.b nEb5, nAb4, nAb4, nEb5, nEb5, nCs5, nCs5, nEb5
	dc.b nEb5, nCs5, nCs5, nAb5, nAb5, nE5, nE5, nAb5
	dc.b nAb5, nCs5, nCs5, nAb5, nAb5, nE5, nE5, nAb5
	dc.b nAb5
	sRet

Marble_DAC1:
	dc.b nRst, $06, dSnare, $03, $03, $0C, dKick, $0C
	dc.b $0C, $0C

Marble_Jump7:
	dc.b dKick, $0C
	sJump		Marble_Jump7

Marble_Call4:
	sNoteTimeOut	$06

Marble_Loop4:
	dc.b nRst, $06, nE7, nC7, nA6, $0C, nD7, $06
	dc.b nB6, nG6, nRst, nC7, nA6, nF6, $0C, nD7
	dc.b $06, nB6, nG6
	sLoop		$00, $02, Marble_Loop4
	sNoteTimeOut	$00
	sRet

Marble_DAC2:
	sStop
