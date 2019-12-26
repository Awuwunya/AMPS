SpringYard_Header:
	sHeaderInit
	sHeaderTempo	$02, $55
	sHeaderCh	$05, $03
	sHeaderDAC	SpringYard_DAC1
	sHeaderDAC	SpringYard_DAC2
	sHeaderFM	SpringYard_FM1, $F4, $11
	sHeaderFM	SpringYard_FM2, $E8, $0B
	sHeaderFM	SpringYard_FM3, $F4, $14
	sHeaderFM	SpringYard_FM4, $F4, $18
	sHeaderFM	SpringYard_FM5, $F4, $18
	sHeaderPSG	SpringYard_PSG1, $D0+$0C, $30, $00, v06
	sHeaderPSG	SpringYard_PSG2, $E8+$0C, $38, $00, v00
	sHeaderPSG	SpringYard_PSG3, $00, $28, $00, v04

	; Patch $00
	; $3C
	; $31, $52, $50, $30,	$52, $53, $52, $53
	; $08, $00, $08, $00,	$04, $00, $04, $00
	; $10, $07, $10, $07,	$1A, $80, $16, $80
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
	spReleaseRt	$00, $00, $07, $07
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1A, $16, $00, $00

	; Patch $01
	; $18
	; $37, $30, $30, $31,	$9E, $DC, $1C, $9C
	; $0D, $06, $04, $01,	$08, $0A, $03, $05
	; $BF, $BF, $3F, $2F,	$32, $22, $14, $80
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
	spTotalLv	$32, $14, $22, $00

	; Patch $02
	; $3D
	; $01, $02, $02, $02,	$1F, $10, $10, $10
	; $07, $1F, $1F, $1F,	$00, $00, $00, $00
	; $1F, $0F, $0F, $0F,	$17, $8D, $8C, $8C
	spAlgorithm	$05
	spFeedback	$07
	spDetune	$00, $00, $00, $00
	spMultiple	$01, $02, $02, $02
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $10, $10, $10
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$07, $1F, $1F, $1F
	spSustainLv	$01, $00, $00, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$17, $0C, $0D, $0C

	; Patch $03
	; $2C
	; $74, $74, $34, $34,	$1F, $1F, $1F, $1F
	; $00, $00, $00, $00,	$00, $01, $00, $01
	; $0F, $3F, $0F, $3F,	$16, $80, $17, $80
	spAlgorithm	$04
	spFeedback	$05
	spDetune	$07, $03, $07, $03
	spMultiple	$04, $04, $04, $04
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$00, $00, $00, $00
	spSustainLv	$00, $00, $03, $03
	spDecayRt	$00, $00, $01, $01
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$16, $17, $00, $00

	; Patch $04
	; $04
	; $37, $72, $77, $49,	$1F, $1F, $1F, $1F
	; $07, $0A, $07, $0D,	$00, $00, $00, $00
	; $10, $07, $10, $07,	$23, $80, $23, $80
	spAlgorithm	$04
	spFeedback	$00
	spDetune	$03, $07, $07, $04
	spMultiple	$07, $07, $02, $09
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$07, $07, $0A, $0D
	spSustainLv	$01, $01, $00, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$00, $00, $07, $07
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$23, $23, $00, $00

	; Patch $05
	; $3A
	; $01, $01, $01, $02,	$8D, $07, $07, $52
	; $09, $00, $00, $03,	$01, $02, $02, $00
	; $5F, $0F, $0F, $2F,	$18, $22, $18, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$00, $00, $00, $00
	spMultiple	$01, $01, $01, $02
	spRateScale	$02, $00, $00, $01
	spAttackRt	$0D, $07, $07, $12
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$09, $00, $00, $03
	spSustainLv	$05, $00, $00, $02
	spDecayRt	$01, $02, $02, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$18, $18, $22, $00

SpringYard_FM1:
	dc.b nRst, $2A

SpringYard_Jump1:
	sVoice		$00
	ssMod68k	$08, $01, $06, $04
	sCall		SpringYard_Call1
	dc.b nD6, $0A, nF6, $2C
	sCall		SpringYard_Call1
	dc.b nD6, nF6, $02, nRst, $04, nF6, $02, nRst
	dc.b $04, nG6, $04, nF6, $02, nG6, $04, nRst
	dc.b $02, nA6, $06
;	sMuteFM1
	sCmdYM		$88, $0F
	sCmdYM		$8C, $0F
	dc.b nRst, $12
	sVoice		$04
	sModOff
	saVol		$08
	sCall		SpringYard_Call2
	sCall		SpringYard_Call3
	dc.b nA5, $08, nC6, $0C, nG6, $0A, nA6, $02
	dc.b nRst, $04, nA6, $02, nG6, $03, nRst, nF6
	dc.b $0C
	sCall		SpringYard_Call2
	dc.b nRst, $06, nE6, $02, nRst, $04, nE6, $0C
	dc.b nF6, nE6, $0A, nD6, $02, nRst, $2A
	saVol		$F8
	sJump		SpringYard_Jump1

SpringYard_Call1:
	dc.b nRst, $04, nE6, $02, nRst, $04, nE6, $08
	dc.b nC6, $02, nRst, $04, nA5, $02, nRst, $04
	dc.b nE6, $0A, nC6, $02, nRst, $0C, nRst, $2E
	dc.b nFs6, $02, nRst, $04, nFs6, $08, nD6, $02
	dc.b nRst, $04, nB5, $02, nRst, $04, nFs6, $0C
	sRet

SpringYard_Call2:
	sCall		SpringYard_Call3
	dc.b nA5, nRst, $02, nBb5, nRst, $04, nBb5, $08
	dc.b nC6, $03, nRst, nBb5, nRst, nA5, $04, nBb5
	dc.b nRst, $02, nC6, $0E
	sRet

SpringYard_Call3:
	dc.b nRst, $04, nF6, $08, nE6, $03, nRst, nD6
	dc.b nRst, nC6, nRst, nD6, nRst, nC6, $04
	sRet

SpringYard_FM2:
	sVoice		$01
	saVol		$FE
	dc.b nA4, $03, nRst, nA4, nRst, nG4, nRst, nG4
	dc.b nRst, nF4, nRst, nF4, nRst, nE4, nRst, nE4
	dc.b $02, nRst, nD4
	saVol		$02

SpringYard_Jump2:
	sCall		SpringYard_Call4
	dc.b nBb4, nRst, $02, nA4, nRst, $04, nA4, $08
	dc.b nG4, $03, nRst, nG4, nRst, nF4, nRst, nF4
	dc.b nRst, nE4, $0A, nD4, $02
	sCall		SpringYard_Call4
	dc.b nBb4, $08, nA4, $03, nRst, nA4, nRst, nA4
	dc.b nRst, nA4, nRst, nA4, nRst, $13, nBb4, $02

SpringYard_Loop1:
	sCall		SpringYard_Call5
	dc.b nBb4
	sLoop		$00, $02, SpringYard_Loop1
	sCall		SpringYard_Call5
	dc.b nE4, nRst, $04, nE4, $08, nE4, $03, nRst
	dc.b nE4, nRst, nA4, $09, nRst, $03, nA4, $0A
	dc.b nD4, $02, nRst, $2E, nD4, $02
	sJump		SpringYard_Jump2

SpringYard_Call4:
	dc.b nRst, $04, nD4, $08, nE4, $03, nRst, nD4
	dc.b nRst, nE4, nRst, nD4, nRst, nF4, $04, nA4
	dc.b nRst, $02, nA4, nRst, $04, nE5, $08, nC5
	dc.b $03, nRst, nC5, nRst, nA4, nRst, nA4, nRst
	dc.b nF4, $0A, nE4, $02, nRst, $04, nE4, $08
	dc.b nFs4, $03, nRst, nE4, nRst, nFs4, nRst, nE4
	dc.b nRst, nG4, $04
	sRet

SpringYard_Call5:
	dc.b nRst, $04, nBb4, $08, nC5, $03, nRst, nBb4
	dc.b nRst, nA4, $06, nRst, nBb4, $04, nA4, nRst
	dc.b $02, nG4, nRst, $04, nG4, $08, nA4, $03
	dc.b nRst, nG4, nRst, nF4, nRst, nF4, nRst, nG4
	dc.b $04, nA4, nRst, $02
	sRet

SpringYard_FM3:
	dc.b nRst, $30
	sVoice		$05
	sCall		SpringYard_Call6
	dc.b nRst, $06, nA6, $02, nRst, $0A, nG6, $02
	dc.b nRst, $0A, nF6, $02, nRst, $04, nE6, $02
	dc.b nRst, nF6, nE6, nRst, $04
	sCall		SpringYard_Call6
	dc.b nA5, $02, nRst, nA5, nCs6, nRst, nCs6, nE6
	dc.b nRst, nE6, nG6, nRst, nG6, nA6, nRst, $10
	dc.b nRst, $04, nF5, $02
	sCall		SpringYard_Call7
	dc.b nRst, $13, nF5, $02
	sCall		SpringYard_Call7
	dc.b nRst, nC5, nRst, nD5, $04, nE5, nRst, $02
	dc.b nF5
	sCall		SpringYard_Call7
	dc.b nRst, $15, nRst, $04, nA6, $08, nG6, $03
	dc.b nRst, nG6, nRst, nF6, nRst, nF6, nRst, nE6
	dc.b $04, nF6, $02, nE6, $04, nD6, $02
	sJump		SpringYard_FM3

SpringYard_Call6:
	dc.b nRst, $36, nA5, $04, nC6, $02, nD6, $04
	dc.b nF6, $02, nRst, $06, nA5, $04, nC6, $02
	dc.b nD6, $04, nF6, $02, nRst, $3C
	sRet

SpringYard_Call7:
	dc.b nRst, $04, nF5, $08, nF5, $03, nRst, nF5
	dc.b nRst, nE5, nRst, $13, nD5, $02, nRst, $04
	dc.b nD5, $08, nD5, $03, nRst, nD5, nRst, nC5
	sRet

SpringYard_FM4:
	sPan		spLeft, $00
	ssDetune	$03
	sCall		SpringYard_Call8
	ssDetune	$00

SpringYard_Jump3:
	ssMod68k	$01, $01, $01, $04
	sVoice		$02
	sCall		SpringYard_Call10
	saVol		$FC
	dc.b nD6, $02
	sCall		SpringYard_Call12
	saVol		$04
	sJump		SpringYard_Jump3

SpringYard_Call10:
	sCall		SpringYard_Call11
	dc.b nA6, $30
	sCall		SpringYard_Call11
	dc.b nCs7, $03, nRst, nCs7, nRst, nCs7, nRst, nCs7
	dc.b nRst, nCs7, $03, nRst, $13
	sRet

SpringYard_Call11:
	dc.b nE6, $24, nF6, $06, nG6, nE6, $24, nC6
	dc.b $06, nD6, nE6, $24, nF6, $06, nG6
	sRet

SpringYard_Call12:
	sCall		SpringYard_Call13
	dc.b nRst, $13, nD6, $02
	sCall		SpringYard_Call13
	dc.b nRst, nA5, nRst, nBb5, $04, nC6, nRst, $02
	dc.b nD6
	sCall		SpringYard_Call13
	dc.b nRst, $13, nA5, $0E, nCs6, $0C, nE6, nCs7
	dc.b $0A, nD7, $02, nRst, $30
	sRet

SpringYard_Call13:
	dc.b nRst, $04, nD6, $08, nD6, $03, nRst, nD6
	dc.b nRst, nC6, nRst, nA6, nRst, nF6, nRst, $07
	dc.b nBb5, $02, nRst, $04, nBb5, $08, nBb5, $03
	dc.b nRst, nBb5, nRst, nA5
	sRet

SpringYard_Call8:
	sVoice		$03
	saVol		$FE
	sCall		SpringYard_Call9
	saVol		$06
	sRet

SpringYard_Call9:
	ssTickMulCh	$01
	dc.b nBb3, $01, sHold, nA3, $04, nRst, $07, nBb3
	dc.b $01, sHold, nA3, $04, nRst, $07, nC4, $01
	dc.b sHold, nB3, $04, nRst, $07, nC4, $01, sHold
	dc.b nB3, $04, nRst, $07, nCs4, $01, sHold, nC4
	dc.b $04, nRst, $07, nCs4, $01, sHold, nC4, $04
	dc.b nRst, $07, nD4, $01, sHold, nCs4, $04, nRst
	dc.b $07, nD4, $01, sHold, nCs4, $04, nRst, $07
	ssTickMulCh	$02
	sRet

SpringYard_FM5:
	sPan		spRight, $00
	sCall		SpringYard_Call8
	ssMod68k	$02, $01, $02, $04
	ssDetune	$02
	sJump		SpringYard_Jump3

SpringYard_PSG1:
	ssTickMulCh	$01
	sCall		Credits_Call18x	; fuck it (oh btw this will break if you remove credits fuck you)
	dc.b $04			; needs moar delay
	ssTickMulCh	$02

SpringYard_Jump4:
	sCall		SpringYard_Call10
	dc.b nD6, $02
	sCall		SpringYard_Call12
	sJump		SpringYard_Jump4

SpringYard_PSG3:
	sNoisePSG	$E7
	sGate		$01
	saVol		$08

SpringYard_Loop2:
	dc.b nRst, $04, nHiHat, $02
	sLoop		$00, $08, SpringYard_Loop2
	saVol		-$08

SpringYard_Jump5:
	dc.b $02, nRst, nHiHat
	sJump		SpringYard_Jump5

SpringYard_DAC1:
	dc.b dSnare, $06, $06, $06, $06, $06, $06, $04
	dc.b $02, $04, dKick, $02

SpringYard_Loop3:
	sCall		SpringYard_Call14
	sLoop		$00, $03, SpringYard_Loop3
	dc.b nRst, $04, dKick, $08, dSnare, $06, dKick, dKick
	dc.b $06, dSnare, dSnare, dSnare, $04, dKick, $02

SpringYard_Loop4:
	sCall		SpringYard_Call14
	sLoop		$00, $02, SpringYard_Loop4
	dc.b nRst, $04, dKick, $08, dSnare, $06, dKick, dKick
	dc.b $0C, dSnare, dSnare, $06, $06, $06, $06, $10
	dc.b $02, $04, dKick, $02

SpringYard_Loop5:
	sCall		SpringYard_Call14
	sLoop		$00, $03, SpringYard_Loop5
	dc.b nRst, $04, dKick, $08, dSnare, $06, dKick, dKick
	dc.b $06, dSnare, dSnare, dSnare, $04, dKick, $02

SpringYard_Loop6:
	sCall		SpringYard_Call14
	sLoop		$00, $03, SpringYard_Loop6
	dc.b nRst, $0C, dSnare, $0A, dKick, $02, dSnare, $06
	dc.b dSnare, dSnare, $06, $04, dKick, $02
	sJump		SpringYard_Loop3

SpringYard_Call14:
	dc.b nRst, $04, dKick, $08, dSnare, $06, dKick, dKick
	dc.b $0C, dSnare, $0A, dKick, $02
	sRet

SpringYard_PSG2:
SpringYard_DAC2:
	sStop
