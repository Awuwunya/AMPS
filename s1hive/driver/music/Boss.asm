Boss_Header:
	sHeaderInit
	sHeaderTempo	$02, $40
	sHeaderCh	$05, $03
	sHeaderDAC	Boss_DAC1
	sHeaderDAC	Boss_DAC2
	sHeaderFM	Boss_FM1, $F4, $12
	sHeaderFM	Boss_FM2, $E8, $08
	sHeaderFM	Boss_FM3, $F4, $0F
	sHeaderFM	Boss_FM4, $F4, $12
	sHeaderFM	Boss_FM5, $E8, $0F
	sHeaderPSG	Boss_PSG1, $D0, $18, $00, v05
	sHeaderPSG	Boss_PSG2, $D0, $18, $00, v05
	sHeaderPSG	Boss_PSG3, $DC, $08, $00, v08

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

	; Patch $02
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

	; Patch $03
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

	; Patch $04
	; $39
	; $01, $51, $00, $00,	$1F, $5F, $5F, $5F
	; $10, $11, $09, $09,	$07, $00, $00, $00
	; $2F, $2F, $2F, $1F,	$20, $22, $20, $80
	spAlgorithm	$01
	spFeedback	$07
	spDetune	$00, $00, $05, $00
	spMultiple	$01, $00, $01, $00
	spRateScale	$00, $01, $01, $01
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$10, $09, $11, $09
	spSustainLv	$02, $02, $02, $01
	spDecayRt	$07, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$20, $20, $22, $00

	; Patch $05
	; $3A
	; $42, $43, $14, $71,	$1F, $12, $1F, $1F
	; $04, $02, $04, $0A,	$01, $01, $02, $0B
	; $1F, $1F, $1F, $1F,	$1A, $16, $19, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$04, $01, $04, $07
	spMultiple	$02, $04, $03, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $12, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$04, $04, $02, $0A
	spSustainLv	$01, $01, $01, $01
	spDecayRt	$01, $02, $01, $0B
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1A, $19, $16, $00

Boss_FM5:
	sVoice		$05

Boss_Jump4:
	dc.b nFs7, $0C, nFs7, nFs7, nFs7
	saVol		$02
	sCall		Boss_Call4
	dc.b nA6, nFs6, nG6, nFs6, nE6, nFs6, nA6, nFs6
	dc.b nG6, nFs6, nCs7, nFs6, nE6, nFs6
	sCall		Boss_Call4
	dc.b nB6, nFs6, nA6, nFs6, nG6, nFs6, nA6, nFs6
	dc.b nB6, nFs6, nCs7, nB6, nF7, nCs7
	saVol		$FE

Boss_Loop1:
	dc.b nFs7, $03, nD7, $03, nFs7, $03, nD7, $03
	sLoop		$00, $04, Boss_Loop1
	sJump		Boss_Jump4

Boss_Call4:
	dc.b nB6, $06, nFs6, nD7, nFs6, nB6, nFs6, nE6
	dc.b nFs6, nB6, nFs6, nD7, nFs6, nB6, nFs6, nA6
	dc.b nFs6, nG6, nFs6
	sRet

Boss_FM2:
	sVoice		$00

Boss_Jump2:
	dc.b nFs4, $06, nFs5, nFs4, nFs5, nFs4, nFs5, nFs4
	dc.b nFs5
	sCall		Boss_Call2
	dc.b nB3, $06, nE4, nE4, $0C, nB3, $06
	sCall		Boss_Call2
	dc.b nE4, $06, nD4, nD4, $0C, nD4, $06, nCs4
	dc.b $30
	sJump		Boss_Jump2

Boss_Call2:
	dc.b nB3, $06, nB3, nD4, nD4, nCs4, nCs4, nC4
	dc.b nC4, nB3, $12, nFs4, $06, nB4, $0C, nA4
	dc.b nG4, $06, nG4, $0C, nD4, $06, nG4, nG4
	dc.b $0C, nFs4, $06, nE4, nE4, $0C
	sRet

Boss_PSG2:
	ssDetune	$02
	sJump		Boss_Jump3

Boss_FM3:
	sVoice		$01
	sPan		spLeft, $00

Boss_Jump3:
	dc.b nRst, $30
	sCall		Boss_Call3
	dc.b nE5, $12, nRst, nD6, $03, nRst, nCs6, nRst
	dc.b nA5, $12
	sCall		Boss_Call3
	dc.b nE5, $0C, nB5, $03, nRst, nE6, nRst, nE6
	dc.b $0C, nE6, $03, nRst, nF6, nRst, nF6, $0C
	dc.b nF6, $03, nRst, nFs6, $30
	sJump		Boss_Jump3

Boss_Call3:
	dc.b nRst, $1E, nFs5, $03, nRst, nB5, nRst, nCs6
	dc.b nRst, nD6, $30, nRst, $12, nB5, $03, nRst
	dc.b nG5, nRst
	sRet

Boss_FM1:
	ssDetune	$03
	sJump		Boss_Jump1

Boss_FM4:
	sPan		spRight, $00

Boss_Jump1:
	sVoice		$02
	ssMod68k	$0C, $01, $04, $06

Boss_PSG1:
	dc.b nRst, $30
	sCall		Boss_Call1
	dc.b nE7
	sCall		Boss_Call1
	dc.b nE7, $18, nF7, nFs7, $30
	sJump		Boss_PSG1

Boss_Call1:
	dc.b nB6, $04, nA6, nC7, nB6, $24, nRst, $0C
	dc.b nFs6, nB6, nCs7, nD7, $30
	sRet

Boss_PSG3:
Boss_DAC2:
	sStop

Boss_DAC1:
	dc.b dHiTimpani, $06, dLowTimpani, dHiTimpani, dLowTimpani, dHiTimpani, dLowTimpani, dHiTimpani
	dc.b dLowTimpani

Boss_Loop2:
	dc.b dSnare, $0C, dSnare, $04, dSnare, dSnare, dSnare, $06
	dc.b dSnare, $0C, dSnare, $06, dSnare, $12, dSnare, $06
	dc.b dSnare, $0C, dSnare, $0C
	sLoop		$00, $03, Boss_Loop2
	dc.b dSnare, $0C, dSnare, $04, dSnare, dSnare, dSnare, $06
	dc.b dSnare, $0C, dSnare, $06, dSnare, $06, dSnare, $0C
	dc.b dSnare, $06, dSnare, $06, dSnare, $0C, dSnare, $06
	dc.b dSnare, $01, dHiTimpani, $05, dLowTimpani, $06, dHiTimpani, dLowTimpani
	dc.b dHiTimpani, dLowTimpani, dHiTimpani, dLowTimpani
	sJump		Boss_DAC1
