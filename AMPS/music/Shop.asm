Shop_Header:
	sHeaderInit						; Z80 offset is $8921
	sHeaderTempo	$01, $80
	sHeaderCh	$05, $03
	sHeaderDAC	Shop_DAC1, $12
	sHeaderDAC	Shop_DAC2, $12
	sHeaderFM	Shop_FM1, $0C, $0C
	sHeaderFM	Shop_FM2, $00, $0B
	sHeaderFM	Shop_FM3, $0C, $10
	sHeaderFM	Shop_FM4, $0C, $0F
	sHeaderFM	Shop_FM5, $0C, $0F
	sHeaderPSG	Shop_PSG1, $F4+$0C, $18, $00, vPhan3_05
	sHeaderPSG	Shop_PSG2, $00+$0C, $30, $00, vPhan3_0A
	sHeaderPSG	Shop_PSG2, $F4+$0C, $20, $00, vPhan3_05

	; Patch $00
	; $24
	; $51, $51, $31, $21,	$1F, $1C, $1F, $1F
	; $0C, $0F, $06, $0D,	$08, $09, $07, $0C
	; $06, $36, $06, $36,	$12, $80, $15, $80
	spAlgorithm	$04
	spFeedback	$04
	spDetune	$05, $03, $05, $02
	spMultiple	$01, $01, $01, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $1C, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0C, $06, $0F, $0D
	spSustainLv	$00, $00, $03, $03
	spDecayRt	$08, $07, $09, $0C
	spReleaseRt	$06, $06, $06, $06
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$12, $15, $00, $00

	; Patch $01
	; $2C
	; $51, $51, $31, $21,	$1F, $1C, $1F, $1F
	; $0C, $0F, $06, $0D,	$08, $09, $07, $0C
	; $06, $36, $06, $36,	$12, $80, $15, $80
	spAlgorithm	$04
	spFeedback	$05
	spDetune	$05, $03, $05, $02
	spMultiple	$01, $01, $01, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $1C, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0C, $06, $0F, $0D
	spSustainLv	$00, $00, $03, $03
	spDecayRt	$08, $07, $09, $0C
	spReleaseRt	$06, $06, $06, $06
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$12, $15, $00, $00

	; Patch $02
	; $0C
	; $03, $53, $01, $01,	$3F, $1F, $1F, $9F
	; $8A, $89, $8A, $91,	$06, $06, $06, $04
	; $1A, $1A, $19, $18,	$12, $92, $12, $80
	spAlgorithm	$04
	spFeedback	$01
	spDetune	$00, $00, $05, $00
	spMultiple	$03, $01, $03, $01
	spRateScale	$00, $00, $00, $02
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$01, $01, $01, $01
	spSustainRt	$0A, $0A, $09, $11
	spSustainLv	$01, $01, $01, $01
	spDecayRt	$06, $06, $06, $04
	spReleaseRt	$0A, $09, $0A, $08
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$12, $12, $12, $00

	; Patch $03
	; $01
	; $21, $21, $23, $22,	$1F, $1F, $1F, $1F
	; $03, $03, $1B, $08,	$03, $03, $04, $03
	; $35, $38, $36, $37,	$12, $00, $15, $80
	spAlgorithm	$01
	spFeedback	$00
	spDetune	$02, $02, $02, $02
	spMultiple	$01, $03, $01, $02
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$03, $1B, $03, $08
	spSustainLv	$03, $03, $03, $03
	spDecayRt	$03, $04, $03, $03
	spReleaseRt	$05, $06, $08, $07
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$12, $15, $00, $00

	; Patch $04
	; $04
	; $21, $21, $23, $22,	$1F, $1F, $1F, $1F
	; $03, $03, $1B, $08,	$03, $03, $04, $03
	; $35, $38, $36, $37,	$12, $80, $15, $80
	spAlgorithm	$04
	spFeedback	$00
	spDetune	$02, $02, $02, $02
	spMultiple	$01, $03, $01, $02
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$03, $1B, $03, $08
	spSustainLv	$03, $03, $03, $03
	spDecayRt	$03, $04, $03, $03
	spReleaseRt	$05, $06, $08, $07
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$12, $15, $00, $00

Shop_FM1:
	sVoice		$02

Shop_PSG1:
	sCall		Shop_Call1
	dc.b nRst, $08, nBb2, $0C, nC3, $04, nD3, $08
	dc.b nC3, $0C, nBb2, $04, nA2, $18, nRst, $08
	dc.b nA2, $04, nBb2, $08, nA2, $34
	sCall		Shop_Call1
	dc.b nRst, $08, nBb2, $04, nA2, $08, nBb2, $04
	dc.b nB2, $08, nBb2, $04, nB2, $08, nCs3, $04
	dc.b nD3, $24, nCs3, $06, nD3, $06, nRst, $30
	sCall		Shop_Call2
	dc.b nRst, $08, nA2, $0C, nB2, $04, nCs3, $08
	dc.b nB2, $04, nCs3, $08, nD3, $04, nE3, $24
	dc.b nFs3, $06, $36
	sCall		Shop_Call2
	dc.b nRst, $08, nA2, $04, nAb2, $08, nA2, $04
	dc.b nB2, $08, nBb2, $04, nB2, $08, nCs3, $04
	dc.b nD3, $24, nCs3, $06, nD3, nRst, $06, nA2
	dc.b $12, nB2, $0C, nCs3
	sJump		Shop_PSG1

Shop_Call1:
	dc.b nA2, $08, nB2, $04, nCs3, $08, nD3, $04
	dc.b nA2, $08, nB2, $04, nCs3, $08, nD3, $10
	dc.b nCs3, $06, nD3, $0C, nE3, nG3, $06, nFs3
	dc.b $0C, nE3, $06, $12, nEb3, $06, nE3, $1E
	dc.b nRst, $06, nD3, $12, nCs3, $0C, nBb2, $06
	dc.b $1E
	sRet

Shop_Call2:
	dc.b nB2, $08, nCs3, $04, nD3, $08, nE3, $04
	dc.b nB2, $08, nCs3, $04, nD3, $08, nE3, $04
	dc.b nD3, $08, nE3, $04, nFs3, $08, nG3, $04
	dc.b nD3, $08, nE3, $04, nFs3, $08, nG3, $04
	dc.b nFs3, $0C, nE3, $06, $12, nEb3, $06, nE3
	dc.b $1E, nRst, $06, nD3, $12, nCs3, $0C, nA2
	dc.b $06, $1E
	sRet

Shop_FM2:
	sVoice		$00
	dc.b nD2, $18, nA1, nD2, nA1, nD2, nAb1, nD2
	dc.b nAb1, nD2, nBb1, nD2, nBb1, nD2, nA1, nD2
	dc.b nA1
	sLoop		$00, $02, Shop_FM2
	sCall		Shop_Call3
	dc.b nD2, $18, $0C, nCs2, $0C
	sCall		Shop_Call3
	dc.b nD2, $06, nA1, $12, nB1, $0C, nCs2
	sJump		Shop_FM2

Shop_Call3:
	dc.b nB1, $18, nFs1, nB1, nB1, $0C, nEb2, nE2
	dc.b $18, nB1, nE2, nE2, $0C, nD2, nCs2, $18
	dc.b nA1, nCs2, $18, nB1, $0C, nCs2, nD2, $18
	dc.b nA1
	sRet

Shop_FM3:
	sVoice		$01

Shop_Loop1:
	dc.b nRst, $0C, nD3, nRst, nD3
	sLoop		$00, $10, Shop_Loop1
	sCall		Shop_Call4
	dc.b nRst, $0C, nD3, nRst, nD3
	sCall		Shop_Call4
	dc.b nRst, $06, nA2, $12, nB2, $0C, nCs3
	sJump		Shop_Loop1

Shop_Call4:
	dc.b nRst, $0C, nD3, nRst, nD3, nRst, nD3, nRst
	dc.b nEb3, nRst, $0C, nE3, nRst, nE3, nRst, nE3
	dc.b nRst, nE3, nRst, nE3, nRst, nE3, nRst, nE3
	dc.b nRst, nE3, nRst, nD3, nRst, nD3
	sRet

Shop_FM4:
	dc.b nRst, $0C
	sVoice		$01
	dc.b nA2, nRst, nA2, nRst, nA2, nRst
	dc.b nA2, nRst, nB2, nRst, nB2, nRst, nB2, nRst
	dc.b nB2, nRst, nBb2, nRst, nBb2, nRst, nBb2, nRst
	dc.b nBb2, nRst, nA2, nRst, nA2, nRst, nA2, nRst
	dc.b nA2
	sLoop		$00, $02, Shop_FM4
	sCall		Shop_Call5
	dc.b nRst, nA2, nRst, nA2
	sCall		Shop_Call5
	dc.b nRst, $06, nA2, $12, nAb2, $0C, nG2
	sJump		Shop_FM4

Shop_Call5:
	dc.b nRst, $0C, nB2, nRst, nB2, nRst, nB2, nRst
	dc.b nB2, nRst, nB2, nRst, nB2, nRst, nB2, nRst
	dc.b nB2, nRst, nCs3, nRst, nCs3, nRst, nCs3, nRst
	dc.b nCs3, nRst, nA2, nRst, nA2
	sRet

Shop_FM5:
	dc.b nRst, $0C
	sVoice		$01
	dc.b nFs2, nRst, nFs2, nRst, nFs2, nRst
	dc.b nFs2, nRst, nAb2, nRst, nAb2, nRst, nAb2, nRst
	dc.b nAb2, nRst, nG2, nRst, nG2, nRst, nG2, nRst
	dc.b nG2, nRst, nFs2, nRst, nFs2, nRst, nFs2, nRst
	dc.b nFs2
	sLoop		$00, $02, Shop_FM5
	sCall		Shop_Call6
	dc.b nRst, nFs2, nRst, nFs2
	sCall		Shop_Call6
	dc.b nRst, $06, nFs2, $12, nAb2, $0C, nA2
	sJump		Shop_FM5

Shop_Call6:
	dc.b nRst, $0C, nFs2, nRst, nFs2, nRst, nFs2, nRst
	dc.b nFs2, nRst, nG2, nRst, nG2, nRst, nG2, nRst
	dc.b nG2, nRst, nA2, nRst, nA2, nRst, nA2, nRst
	dc.b nA2, nRst, nFs2, nRst, nFs2
	sRet

Shop_PSG2:
	sCall		Shop_Call7
	dc.b nRst, $08, nG2, $0C, nA2, $04, nBb2, $08
	dc.b nA2, $0C, nG2, $04, nFs2, $18, nRst, $08
	dc.b nFs2, $04, nG2, $08, nFs2, $34
	sCall		Shop_Call7
	dc.b nRst, $08, nG2, $0C, $04, $08, $0C, $04
	dc.b nFs2, $24, nG2, $06, nFs2, $06, nRst, $30
	sCall		Shop_Call8
	dc.b nA2, $08, nB2, $04, nCs3, $08, nD3, $04
	dc.b nA2, $08, nB2, $04, nCs3, $08, nD3, $04
	dc.b nD3, $0C, $08, $04, $0C, $08, $04, nD3
	dc.b $08, nE3, $04, nFs3, $08, nG3, $04, nD3
	dc.b $08, nE3, $04, nFs3, $08, nG3, $04
	sCall		Shop_Call8
	dc.b nRst, $08, nFs2, $04, nF2, $08, nFs2, $04
	dc.b nAb2, $08, nFs2, $04, nG2, $08, nA2, $04
	dc.b nFs2, $24, nF2, $06, nFs2, nRst, $06, nA2
	dc.b $12, nB2, $0C, nCs3, $0C
	sJump		Shop_PSG2

Shop_Call7:
	dc.b nFs2, $08, nG2, $04, nA2, $08, nA2, $04
	dc.b nFs2, $08, nG2, $04, nA2, $08, nA2, $10
	dc.b nA2, $06, $0C, $0C, $06, nB2, $0C, $06
	dc.b $12, nBb2, $06, nB2, $1E, nRst, $06, nB2
	dc.b $12, nBb2, $0C, nG2, $06, $1E
	sRet

Shop_Call8:
	dc.b nB2, $0C, $08, $04, $0C, $08, $04, nB2
	dc.b $08, nCs3, $04, nD3, $08, nE3, $04, nB2
	dc.b $08, nCs3, $04, nD3, $08, nE3, $04, nE3
	dc.b $0C, $08, $04, $0C, $08, $04, nE3, $08
	dc.b nFs3, $04, nG3, $08, nA3, $04, nE3, $08
	dc.b nFs3, $04, nG3, $08, nA3, $04, nA2, $0C
	dc.b $08, $04, $0C, $08, $04
	sRet

Shop_DAC1:
	sStop

Shop_DAC2:
	dc.b dSnare, $0C, dSnare, $08, dSnare, $04
	sJump		Shop_DAC2
