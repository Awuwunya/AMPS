GotThrough_Header:
	sHeaderInit
	sHeaderTempo	$02, $55
	sHeaderCh	$05, $02
	sHeaderDAC	GotThrough_DAC1
	sHeaderDAC	GotThrough_DAC2
	sHeaderFM	GotThrough_FM1, $F4, $0A
	sHeaderFM	GotThrough_FM2, $DC, $0A
	sHeaderFM	GotThrough_FM3, $F4, $15
	sHeaderFM	GotThrough_FM4, $F4, $15
	sHeaderFM	GotThrough_FM5, $F4, $14
	sHeaderPSG	GotThrough_PSG1, $D0+$0C, $28, $00, v05
	sHeaderPSG	GotThrough_PSG2, $DC+$0C, $38, $00, v05

	; Patch $00
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

	; Patch $01
	; $3A
	; $61, $3C, $14, $31,	$9C, $DB, $9C, $DA
	; $04, $09, $04, $03,	$03, $01, $03, $00
	; $1F, $0F, $0F, $0F,	$21, $47, $31, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$06, $01, $03, $03
	spMultiple	$01, $04, $0C, $01
	spRateScale	$02, $02, $03, $03
	spAttackRt	$1C, $1C, $1B, $1A
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$04, $04, $09, $03
	spSustainLv	$01, $00, $00, $00
	spDecayRt	$03, $03, $01, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$21, $31, $47, $00

	; Patch $02
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

	; Patch $03
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

	; Patch $04
	; $3D
	; $01, $02, $02, $02,	$10, $50, $50, $50
	; $07, $08, $08, $08,	$01, $00, $00, $00
	; $2F, $1F, $1F, $1F,	$1C, $82, $82, $82
	spAlgorithm	$05
	spFeedback	$07
	spDetune	$00, $00, $00, $00
	spMultiple	$01, $02, $02, $02
	spRateScale	$00, $01, $01, $01
	spAttackRt	$10, $10, $10, $10
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$07, $08, $08, $08
	spSustainLv	$02, $01, $01, $01
	spDecayRt	$01, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1C, $02, $02, $02

GotThrough_FM1:
	sVoice		$00

GotThrough_PSG1:
	dc.b nRst, $06, nG4, nA4, nB4, nC5, nD5, nE5
	dc.b nF5, nG5, $0C, nB6, $02, sHold, nC7, $01
	dc.b nB6, $03, nG6
	ssMod68k	$0C, $01, $08, $04
	dc.b nA6, $33
	sStop

GotThrough_FM2:
	sVoice		$01
	sGate		$0B
	dc.b nG5, $03, nG5, nG4, $06, nG4, nG5, $03
	dc.b nG5, nG4, $06, nG4, nG5, $03, nG5, nRst
	dc.b $06, nRst, $0C, nG4, $09
	sGate		$00
	dc.b nA4, $33
	sStop

GotThrough_FM3:
	sPan		spLeft, $00
	sVoice		$02
	sGate		$06
	dc.b nC6, $03, nC6, nRst, $0C, nC6, $03, nC6
	dc.b nRst, $0C, nC6, $03, nC6, nRst, $12
	sGate		$00
	dc.b nC6, $09, nD6, $33
	sStop

GotThrough_FM4:
	sPan		spRight, $00
	sVoice		$02
	sGate		$06
	dc.b nA5, $03, nA5, nRst, $0C, nA5, $03, nA5
	dc.b nRst, $0C, nA5, $03, nA5, nRst, $12
	sGate		$00
	dc.b nA5, $09, nB5, $33
	sStop

GotThrough_FM5:
	sVoice		$03
	ssMod68k	$0D, $01, $02, $05

GotThrough_PSG2:
	dc.b nG5, $06, nC6, nB5, nG5, nC6, nB5, nG5
	dc.b nC6, nB5, $0C, nC6, $09, nB5, $33

GotThrough_DAC2:
	sStop

GotThrough_DAC1:
	dc.b dSnare, $03, dSnare, dKick, $06, dKick, dSnare, $03
	dc.b dSnare, dKick, $06, dKick, dSnare, $03, dSnare, dHiTimpani
	dc.b dHiTimpani, dFloorTimpani, dFloorTimpani, $03, dFloorTimpani, dFloorTimpani, dSnare, $09
	dc.b $33
	sStop
