ExtraLife_Header:
	sHeaderInit
	sHeaderTempo	$42, $33
	sHeaderCh	$05, $01
	sHeaderDAC	ExtraLife_DAC1
	sHeaderDAC	ExtraLife_DAC2
	sHeaderFM	ExtraLife_FM1, $E8, $10
	sHeaderFM	ExtraLife_FM2, $E8, $10
	sHeaderFM	ExtraLife_FM3, $E8, $10
	sHeaderFM	ExtraLife_FM4, $E8, $10
	sHeaderFM	ExtraLife_FM5, $E8, $10
	sHeaderPSG	ExtraLife_PSG1, $D0, $30, $00, v05

	; Patch $00
	; $3A
	; $01, $07, $01, $01,	$8E, $8E, $8D, $53
	; $0E, $0E, $0E, $03,	$00, $00, $00, $00
	; $1F, $FF, $1F, $0F,	$18, $4E, $16, $80
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
	spTotalLv	$18, $16, $4E, $00

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
	spTotalLv	$18, $27, $28, $00

	; Patch $02
	; $3A
	; $01, $07, $01, $01,	$8E, $8E, $8D, $53
	; $0E, $0E, $0E, $03,	$00, $00, $00, $07
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
	spDecayRt	$00, $00, $00, $07
	spReleaseRt	$0F, $0F, $0F, $0F
	spTotalLv	$18, $27, $28, $00

ExtraLife_FM4:
	ssDetune	$03
	sPan		spRight
	sJump		ExtraLife_Jump1

ExtraLife_FM1:
	sPan		spLeft

ExtraLife_Jump1:
	sVoice		$00
	sGate		$06
	dc.b nE7, $06, $03, $03, $06, $06
	sGate		$00
	dc.b nFs7, $09, nD7, nCs7, $06, nE7, $18
	sStop

ExtraLife_FM2:
	sVoice		$01
	sGate		$06
	sComm		0, $01
	dc.b nCs7, $06, $03, $03, $06, $06
	sGate		$00
	dc.b nD7, $09, nB6, nA6, $06, nCs7, $18
	sComm		0, $00
	sStop

ExtraLife_FM5:
	ssDetune	$03
	sPan		spRight
	sJump		ExtraLife_Jump2

ExtraLife_FM3:
	sPan		spLeft

ExtraLife_Jump2:
	sVoice		$02
	dc.b nA4, $0C, nRst, $06, nA4, nG4, nRst, $03
	dc.b nG4, $06, nRst, $03, nG4, $06, nA4, $18
	sStop

ExtraLife_PSG1:
	sGate		$06
	dc.b nCs7, $06, $03, $03, $06, $06
	sGate		$00
	dc.b nD7, $09, nB6, nA6, $06, nCs7, $18

ExtraLife_DAC1:
	sStop

ExtraLife_DAC2:
	dc.b dHiTimpani, $12, $06, dFloorTimpani, $09, $09, $06, dHiTimpani
	dc.b $06, dLowTimpani, dHiTimpani, dLowTimpani, dHiTimpani, $0C
	sBackup
