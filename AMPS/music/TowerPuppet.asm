TowerPuppet_Header:
	sHeaderInit
	sHeaderTempo	$02, $08
	sHeaderCh	$05, $03
	sHeaderDAC	TowerPuppet_DAC1, $08
	sHeaderDAC	TowerPuppet_DAC2, $08
	sHeaderFM	TowerPuppet_FM1, $00, $10
	sHeaderFM	TowerPuppet_FM2, $00, $0A
	sHeaderFM	TowerPuppet_FM3, $00, $10
	sHeaderFM	TowerPuppet_FM4, $00, $10
	sHeaderFM	TowerPuppet_FM5, $00, $1F
	sHeaderPSG	TowerPuppet_PSG1, $DC+$0C, $08, $00, v00
	sHeaderPSG	TowerPuppet_PSG2, $DC+$0C, $18, $00, v00
	sHeaderPSG	TowerPuppet_PSG3, $00, $08, $00, vDyHe03

	; Patch $00
	; $06
	; $01, $33, $71, $32,	$0A, $88, $4C, $52
	; $00, $05, $00, $09,	$01, $00, $01, $00
	; $03, $03, $24, $05,	$4D, $85, $80, $81
	spAlgorithm	$06
	spFeedback	$00
	spDetune	$00, $07, $03, $03
	spMultiple	$01, $01, $03, $02
	spRateScale	$00, $01, $02, $01
	spAttackRt	$0A, $0C, $08, $12
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$00, $00, $05, $09
	spSustainLv	$00, $02, $00, $00
	spDecayRt	$01, $01, $00, $00
	spReleaseRt	$03, $04, $03, $05
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$4D, $00, $05, $01

	; Patch $01
	; $3D
	; $01, $21, $51, $01,	$12, $14, $14, $0F
	; $0A, $05, $05, $05,	$00, $00, $00, $00
	; $26, $28, $28, $18,	$19, $80, $80, $80
	spAlgorithm	$05
	spFeedback	$07
	spDetune	$00, $05, $02, $00
	spMultiple	$01, $01, $01, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$12, $14, $14, $0F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0A, $05, $05, $05
	spSustainLv	$02, $02, $02, $01
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$06, $08, $08, $08
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$19, $00, $00, $00

	; Patch $02
	; $16
	; $7A, $74, $3C, $31,	$1F, $1F, $1F, $1F
	; $0A, $07, $0C, $06,	$07, $0A, $07, $05
	; $25, $A7, $A7, $55,	$14, $85, $8A, $80
	spAlgorithm	$06
	spFeedback	$02
	spDetune	$07, $03, $07, $03
	spMultiple	$0A, $0C, $04, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0A, $0C, $07, $06
	spSustainLv	$02, $0A, $0A, $05
	spDecayRt	$07, $07, $0A, $05
	spReleaseRt	$05, $07, $07, $05
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$14, $0A, $05, $00

	; Patch $03
	; $3B
	; $00, $00, $00, $01,	$99, $9F, $1F, $1F
	; $0F, $0F, $14, $0F,	$00, $00, $00, $00
	; $F8, $F8, $F8, $FA,	$28, $1E, $05, $80
	spAlgorithm	$03
	spFeedback	$07
	spDetune	$00, $00, $00, $00
	spMultiple	$00, $00, $00, $01
	spRateScale	$02, $00, $02, $00
	spAttackRt	$19, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0F, $14, $0F, $0F
	spSustainLv	$0F, $0F, $0F, $0F
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$08, $08, $08, $0A
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$28, $05, $1E, $00

	; Patch $04
	; $3A
	; $31, $02, $02, $72,	$8F, $8F, $4F, $4D
	; $09, $09, $00, $06,	$00, $00, $00, $00
	; $15, $F5, $05, $08,	$17, $1E, $16, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$03, $00, $00, $07
	spMultiple	$01, $02, $02, $02
	spRateScale	$02, $01, $02, $01
	spAttackRt	$0F, $0F, $0F, $0D
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$09, $00, $09, $06
	spSustainLv	$01, $00, $0F, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$05, $05, $05, $08
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$17, $16, $1E, $00

	; Patch $05
	; $30
	; $30, $3A, $30, $30,	$9E, $D8, $DC, $DC
	; $0E, $0A, $04, $05,	$08, $08, $08, $08
	; $B6, $B6, $B6, $B6,	$14, $2F, $14, $80
	spAlgorithm	$00
	spFeedback	$06
	spDetune	$03, $03, $03, $03
	spMultiple	$00, $00, $0A, $00
	spRateScale	$02, $03, $03, $03
	spAttackRt	$1E, $1C, $18, $1C
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0E, $04, $0A, $05
	spSustainLv	$0B, $0B, $0B, $0B
	spDecayRt	$08, $08, $08, $08
	spReleaseRt	$06, $06, $06, $06
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$14, $14, $2F, $00

	; Patch $06
	; $3B
	; $61, $02, $24, $05,	$5F, $5B, $5E, $4D
	; $04, $04, $08, $06,	$00, $00, $00, $04
	; $24, $23, $28, $26,	$1E, $20, $24, $80
	spAlgorithm	$03
	spFeedback	$07
	spDetune	$06, $02, $00, $00
	spMultiple	$01, $04, $02, $05
	spRateScale	$01, $01, $01, $01
	spAttackRt	$1F, $1E, $1B, $0D
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$04, $08, $04, $06
	spSustainLv	$02, $02, $02, $02
	spDecayRt	$00, $00, $00, $04
	spReleaseRt	$04, $08, $03, $06
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1E, $24, $20, $00

	; Patch $07
	; $00
	; $02, $07, $00, $01,	$DF, $DF, $1F, $1F
	; $12, $11, $14, $0E,	$0A, $00, $0A, $0D
	; $F3, $F6, $F3, $F8,	$22, $07, $20, $80
	spAlgorithm	$00
	spFeedback	$00
	spDetune	$00, $00, $00, $00
	spMultiple	$02, $00, $07, $01
	spRateScale	$03, $00, $03, $00
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$12, $14, $11, $0E
	spSustainLv	$0F, $0F, $0F, $0F
	spDecayRt	$0A, $0A, $00, $0D
	spReleaseRt	$03, $03, $06, $08
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$22, $20, $07, $00

	; Patch $08
	; $28
	; $2F, $68, $37, $32,	$1F, $1F, $1F, $1F
	; $15, $15, $15, $13,	$13, $0C, $0D, $10
	; $26, $26, $36, $29,	$00, $06, $1A, $80
	spAlgorithm	$00
	spFeedback	$05
	spDetune	$02, $03, $06, $03
	spMultiple	$0F, $07, $08, $02
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$15, $15, $15, $13
	spSustainLv	$02, $03, $02, $02
	spDecayRt	$13, $0D, $0C, $10
	spReleaseRt	$06, $06, $06, $09
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$00, $1A, $06, $00

	; Patch $09
	; $3A
	; $32, $56, $32, $42,	$8D, $4F, $15, $52
	; $06, $08, $07, $04,	$02, $00, $00, $00
	; $1F, $1F, $2F, $2F,	$19, $20, $2A, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$03, $03, $05, $04
	spMultiple	$02, $02, $06, $02
	spRateScale	$02, $00, $01, $01
	spAttackRt	$0D, $15, $0F, $12
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$06, $07, $08, $04
	spSustainLv	$01, $02, $01, $02
	spDecayRt	$02, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$19, $2A, $20, $00

	; Patch $0A
	; $3A
	; $31, $37, $31, $31,	$8D, $8D, $8E, $53
	; $0E, $0E, $0E, $03,	$06, $06, $06, $05
	; $1F, $FF, $1F, $0F,	$17, $25, $23, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$03, $03, $03, $03
	spMultiple	$01, $01, $07, $01
	spRateScale	$02, $02, $02, $01
	spAttackRt	$0D, $0E, $0D, $13
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0E, $0E, $0E, $03
	spSustainLv	$01, $01, $0F, $00
	spDecayRt	$06, $06, $06, $05
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$17, $23, $25, $00

	; Patch $0B
	; $3A
	; $41, $45, $31, $41,	$59, $59, $5C, $4E
	; $0A, $0B, $0D, $04,	$00, $00, $00, $00
	; $1F, $5F, $2F, $0F,	$1D, $0F, $30, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$04, $03, $04, $04
	spMultiple	$01, $01, $05, $01
	spRateScale	$01, $01, $01, $01
	spAttackRt	$19, $1C, $19, $0E
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0A, $0D, $0B, $04
	spSustainLv	$01, $02, $05, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1D, $30, $0F, $00

	; Patch $0C
	; $2A
	; $23, $3A, $32, $74,	$1E, $1F, $1F, $1F
	; $17, $1B, $02, $03,	$00, $08, $03, $0B
	; $3F, $3F, $0F, $6F,	$0C, $0C, $1C, $84
	spAlgorithm	$02
	spFeedback	$05
	spDetune	$02, $03, $03, $07
	spMultiple	$03, $02, $0A, $04
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1E, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$17, $02, $1B, $03
	spSustainLv	$03, $00, $03, $06
	spDecayRt	$00, $03, $08, $0B
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$0C, $1C, $0C, $04

	; Patch $0D
	; $3D
	; $01, $65, $14, $30,	$8E, $52, $17, $4C
	; $08, $08, $0E, $03,	$00, $00, $00, $00
	; $1D, $1A, $18, $1A,	$1A, $80, $80, $88
	spAlgorithm	$05
	spFeedback	$07
	spDetune	$00, $01, $06, $03
	spMultiple	$01, $04, $05, $00
	spRateScale	$02, $00, $01, $01
	spAttackRt	$0E, $17, $12, $0C
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$08, $0E, $08, $03
	spSustainLv	$01, $01, $01, $01
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0D, $08, $0A, $0A
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1A, $00, $00, $08

	; Patch $0E
	; $2C
	; $61, $04, $01, $33,	$5F, $94, $58, $94
	; $05, $05, $05, $07,	$02, $02, $02, $02
	; $1F, $68, $16, $A7,	$1E, $80, $15, $81
	spAlgorithm	$04
	spFeedback	$05
	spDetune	$06, $00, $00, $03
	spMultiple	$01, $01, $04, $03
	spRateScale	$01, $01, $02, $02
	spAttackRt	$1F, $18, $14, $14
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$05, $05, $05, $07
	spSustainLv	$01, $01, $06, $0A
	spDecayRt	$02, $02, $02, $02
	spReleaseRt	$0F, $06, $08, $07
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1E, $15, $00, $01

	; Patch $0F
	; $3A
	; $3C, $4F, $31, $23,	$1F, $DF, $1F, $9F
	; $0C, $02, $0C, $05,	$04, $04, $04, $07
	; $1F, $FF, $0F, $2F,	$20, $39, $1E, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$03, $03, $04, $02
	spMultiple	$0C, $01, $0F, $03
	spRateScale	$00, $00, $03, $02
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0C, $0C, $02, $05
	spSustainLv	$01, $00, $0F, $02
	spDecayRt	$04, $04, $04, $07
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$20, $1E, $39, $00

	; Patch $10
	; $38
	; $63, $31, $31, $31,	$10, $13, $1A, $1B
	; $0E, $00, $00, $00,	$00, $00, $00, $00
	; $3F, $0F, $0F, $0F,	$1A, $19, $1A, $80
	spAlgorithm	$00
	spFeedback	$07
	spDetune	$06, $03, $03, $03
	spMultiple	$03, $01, $01, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$10, $1A, $13, $1B
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0E, $00, $00, $00
	spSustainLv	$03, $00, $00, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1A, $1A, $19, $00

	; Patch $11
	; $3D
	; $65, $28, $04, $61,	$DF, $1F, $1F, $1F
	; $12, $04, $0F, $0F,	$00, $00, $00, $00
	; $2F, $09, $0F, $0F,	$26, $8A, $8B, $80
	spAlgorithm	$05
	spFeedback	$07
	spDetune	$06, $00, $02, $06
	spMultiple	$05, $04, $08, $01
	spRateScale	$03, $00, $00, $00
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$12, $0F, $04, $0F
	spSustainLv	$02, $00, $00, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $0F, $09, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$26, $0B, $0A, $00

	; Patch $12
	; $30
	; $75, $75, $71, $31,	$D8, $58, $96, $94
	; $01, $0B, $03, $08,	$01, $04, $01, $01
	; $F3, $23, $34, $35,	$34, $29, $10, $80
	spAlgorithm	$00
	spFeedback	$06
	spDetune	$07, $07, $07, $03
	spMultiple	$05, $01, $05, $01
	spRateScale	$03, $02, $01, $02
	spAttackRt	$18, $16, $18, $14
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$01, $03, $0B, $08
	spSustainLv	$0F, $03, $02, $03
	spDecayRt	$01, $01, $04, $01
	spReleaseRt	$03, $04, $03, $05
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$34, $10, $29, $00

	; Patch $13
	; $1C
	; $76, $74, $36, $34,	$94, $99, $94, $99
	; $08, $0A, $08, $0A,	$00, $05, $00, $05
	; $35, $47, $35, $47,	$1E, $80, $19, $80
	spAlgorithm	$04
	spFeedback	$03
	spDetune	$07, $03, $07, $03
	spMultiple	$06, $06, $04, $04
	spRateScale	$02, $02, $02, $02
	spAttackRt	$14, $14, $19, $19
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$08, $08, $0A, $0A
	spSustainLv	$03, $03, $04, $04
	spDecayRt	$00, $00, $05, $05
	spReleaseRt	$05, $05, $07, $07
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1E, $19, $00, $00

	; Patch $14
	; $3A
	; $42, $4A, $32, $42,	$5C, $53, $5C, $4F
	; $07, $0F, $0C, $0A,	$00, $00, $00, $00
	; $1F, $36, $18, $07,	$1B, $0C, $33, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$04, $03, $04, $04
	spMultiple	$02, $02, $0A, $02
	spRateScale	$01, $01, $01, $01
	spAttackRt	$1C, $1C, $13, $0F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$07, $0C, $0F, $0A
	spSustainLv	$01, $01, $03, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $08, $06, $07
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1B, $33, $0C, $00

	; Patch $15
	; $16
	; $7A, $74, $3C, $31,	$1F, $1F, $1F, $1F
	; $0A, $07, $0C, $06,	$07, $0A, $07, $05
	; $25, $A7, $A7, $55,	$14, $85, $8A, $80
	spAlgorithm	$06
	spFeedback	$02
	spDetune	$07, $03, $07, $03
	spMultiple	$0A, $0C, $04, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0A, $0C, $07, $06
	spSustainLv	$02, $0A, $0A, $05
	spDecayRt	$07, $07, $0A, $05
	spReleaseRt	$05, $07, $07, $05
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$14, $0A, $05, $00

	; Patch $16
	; $3D
	; $01, $21, $51, $01,	$12, $14, $14, $0F
	; $0A, $05, $05, $05,	$00, $00, $00, $00
	; $2B, $2B, $2B, $1B,	$19, $80, $80, $80
	spAlgorithm	$05
	spFeedback	$07
	spDetune	$00, $05, $02, $00
	spMultiple	$01, $01, $01, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$12, $14, $14, $0F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0A, $05, $05, $05
	spSustainLv	$02, $02, $02, $01
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0B, $0B, $0B, $0B
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$19, $00, $00, $00

	; Patch $17
	; $35
	; $31, $38, $30, $31,	$9E, $D8, $DF, $DC
	; $0E, $0A, $01, $05,	$08, $08, $08, $08
	; $B6, $B6, $B6, $B6,	$14, $87, $80, $80
	spAlgorithm	$05
	spFeedback	$06
	spDetune	$03, $03, $03, $03
	spMultiple	$01, $00, $08, $01
	spRateScale	$02, $03, $03, $03
	spAttackRt	$1E, $1F, $18, $1C
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0E, $01, $0A, $05
	spSustainLv	$0B, $0B, $0B, $0B
	spDecayRt	$08, $08, $08, $08
	spReleaseRt	$06, $06, $06, $06
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$14, $00, $07, $00

	; Patch $18
	; $18
	; $32, $30, $30, $30,	$9E, $DC, $1C, $9A
	; $0D, $06, $04, $01,	$08, $0A, $03, $05
	; $B6, $B6, $36, $26,	$2C, $22, $14, $80
	spAlgorithm	$00
	spFeedback	$03
	spDetune	$03, $03, $03, $03
	spMultiple	$02, $00, $00, $00
	spRateScale	$02, $00, $03, $02
	spAttackRt	$1E, $1C, $1C, $1A
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0D, $04, $06, $01
	spSustainLv	$0B, $03, $0B, $02
	spDecayRt	$08, $03, $0A, $05
	spReleaseRt	$06, $06, $06, $06
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$2C, $14, $22, $00

	; Patch $19
	; $38
	; $58, $33, $53, $31,	$5F, $5F, $1C, $5F
	; $09, $0A, $06, $02,	$00, $00, $00, $08
	; $F6, $F9, $F8, $08,	$27, $1D, $22, $81
	spAlgorithm	$00
	spFeedback	$07
	spDetune	$05, $05, $03, $03
	spMultiple	$08, $03, $03, $01
	spRateScale	$01, $00, $01, $01
	spAttackRt	$1F, $1C, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$09, $06, $0A, $02
	spSustainLv	$0F, $0F, $0F, $00
	spDecayRt	$00, $00, $00, $08
	spReleaseRt	$06, $08, $09, $08
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$27, $22, $1D, $01

	; Patch $1A
	; $24
	; $3E, $31, $16, $11,	$1F, $98, $1F, $9F
	; $0F, $01, $0E, $01,	$0E, $05, $08, $05
	; $50, $02, $60, $02,	$2A, $81, $20, $81
	spAlgorithm	$04
	spFeedback	$04
	spDetune	$03, $01, $03, $01
	spMultiple	$0E, $06, $01, $01
	spRateScale	$00, $00, $02, $02
	spAttackRt	$1F, $1F, $18, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0F, $0E, $01, $01
	spSustainLv	$05, $06, $00, $00
	spDecayRt	$0E, $08, $05, $05
	spReleaseRt	$00, $00, $02, $02
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$2A, $20, $01, $01

	; Patch $1B
	; $1C
	; $3F, $03, $31, $31,	$1F, $1B, $1E, $1E
	; $0F, $07, $06, $07,	$00, $0A, $00, $00
	; $8A, $86, $F6, $F7,	$26, $80, $17, $80
	spAlgorithm	$04
	spFeedback	$03
	spDetune	$03, $03, $00, $03
	spMultiple	$0F, $01, $03, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1E, $1B, $1E
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0F, $06, $07, $07
	spSustainLv	$08, $0F, $08, $0F
	spDecayRt	$00, $00, $0A, $00
	spReleaseRt	$0A, $06, $06, $07
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$26, $17, $00, $00

	; Patch $1C
	; $3A
	; $31, $37, $31, $31,	$8D, $8D, $8E, $53
	; $0E, $0E, $0E, $03,	$06, $06, $06, $04
	; $1F, $FF, $1F, $0F,	$18, $23, $1E, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$03, $03, $03, $03
	spMultiple	$01, $01, $07, $01
	spRateScale	$02, $02, $02, $01
	spAttackRt	$0D, $0E, $0D, $13
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0E, $0E, $0E, $03
	spSustainLv	$01, $01, $0F, $00
	spDecayRt	$06, $06, $06, $04
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$18, $1E, $23, $00

	; Patch $1D
	; $3C
	; $32, $32, $51, $02,	$1F, $0B, $1F, $0E
	; $07, $1F, $07, $1F,	$00, $00, $00, $00
	; $12, $05, $13, $07,	$1B, $81, $12, $80
	spAlgorithm	$04
	spFeedback	$07
	spDetune	$03, $05, $03, $00
	spMultiple	$02, $01, $02, $02
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $0B, $0E
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$07, $07, $1F, $1F
	spSustainLv	$01, $01, $00, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$02, $03, $05, $07
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1B, $12, $01, $00

	; Patch $1E
	; $3A
	; $11, $01, $01, $01,	$DF, $1F, $1F, $1A
	; $1F, $1F, $1F, $1F,	$09, $08, $07, $00
	; $04, $04, $04, $05,	$1D, $26, $18, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$01, $00, $00, $00
	spMultiple	$01, $01, $01, $01
	spRateScale	$03, $00, $00, $00
	spAttackRt	$1F, $1F, $1F, $1A
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$1F, $1F, $1F, $1F
	spSustainLv	$00, $00, $00, $00
	spDecayRt	$09, $07, $08, $00
	spReleaseRt	$04, $04, $04, $05
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1D, $18, $26, $00

	; Patch $1F
	; $38
	; $20, $62, $70, $32,	$14, $12, $0A, $0A
	; $0E, $0E, $09, $1F,	$00, $00, $00, $00
	; $5F, $5F, $AF, $0F,	$1C, $28, $14, $83
	spAlgorithm	$00
	spFeedback	$07
	spDetune	$02, $07, $06, $03
	spMultiple	$00, $00, $02, $02
	spRateScale	$00, $00, $00, $00
	spAttackRt	$14, $0A, $12, $0A
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0E, $09, $0E, $1F
	spSustainLv	$05, $0A, $05, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1C, $14, $28, $03

	; Patch $20
	; $3A
	; $11, $01, $01, $01,	$DF, $1F, $1F, $1A
	; $1F, $1F, $1F, $1F,	$09, $08, $07, $00
	; $04, $04, $04, $0A,	$1D, $26, $18, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$01, $00, $00, $00
	spMultiple	$01, $01, $01, $01
	spRateScale	$03, $00, $00, $00
	spAttackRt	$1F, $1F, $1F, $1A
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$1F, $1F, $1F, $1F
	spSustainLv	$00, $00, $00, $00
	spDecayRt	$09, $07, $08, $00
	spReleaseRt	$04, $04, $04, $0A
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1D, $18, $26, $00

TowerPuppet_FM5:
	dc.b nRst, $0C

TowerPuppet_FM1:
	saVol		$02
	sVoice		$1B
	ssLFO		$F9, $0B|spCentre
	ssMod68k	$14, $02, $05, $02
	dc.b nC5, $02, nD5, $0C, nRst, $04, nC5, $18
	dc.b nRst, $06, nA4, $01, nB4, $0C, nRst, $05
	dc.b nC5, $18, nRst, $06, nD5, $0C, nRst, $06
	dc.b nC5, $18, nRst, $06
	saVol		$FE
	ssMod68k	$14, $02, $02, $06
	saVol		$FB
	sVoice		$06
	saVol		$FF
	dc.b nC5, $02, nRst, $04
	saVol		$01
	saVol		$01
	dc.b nCs5, $02, nRst, $04
	saVol		$FF
	saVol		$FF
	dc.b nC5, $02, nRst, $04
	saVol		$01
	saVol		$01
	dc.b nD5, $02, nRst, $04
	saVol		$FF
	saVol		$FF
	dc.b nC5, $02, nRst, $04
	saVol		$01
	saVol		$01
	dc.b nEb5, $02, nRst, $04
	saVol		$FF
	saVol		$FF
	dc.b nC5, $02, nRst, $04
	saVol		$01
	saVol		$01
	dc.b nE5, $02, nRst, $04
	saVol		$FF
	saVol		$05
	ssMod68k	$14, $02, $05, $02
	saVol		$02
	sVoice		$1B
	dc.b nC5, $01, nD5, $0C, nRst, $05, nC5, $18
	dc.b nRst, $06, nB4, $0C, nRst, $06, nC5, $18
	dc.b nRst, $06, nC5, $01, nD5, $0C, nRst, $05
	dc.b nC5, $18, nRst, $06
	saVol		$FE
	ssMod68k	$14, $02, $02, $06
	sPan		spRight, $00
	sVoice		$1D
	dc.b nG5, $02, nRst, $07, nFs5, $02, nRst, $07
	dc.b nF5, $02, nRst, $07, nE5, $02, nRst, $07
	dc.b nEb5, $02, nRst, $04, nD5, $02, nRst, $04
	sPan		spCenter, $00
	dc.b nRst, $0C
	sVoice		$01
	saVol		$F0
	sPan		spLeft, $00
	dc.b nG4, $01, nFs4, nF4, nE4, nEb4, nD4, nCs4
	saVol		$10
	saVol		$FB
	sPan		spCenter, $00
	dc.b nC4, nB3
	saVol		$05
	saVol		$F7
	sPan		spRight, $00
	dc.b nBb3
	saVol		$01
	dc.b nA3
	saVol		$02
	dc.b nAb3
	sPan		spCenter, $00
	saVol		$06
	saVol		$02
	sVoice		$0E

TowerPuppet_Loop1:
	dc.b nA5, $02, nRst, $10, nAb5, $03, nRst, nRst
	dc.b $12, nBb5, $1E, nRst, $06, nF5, $02, nRst
	dc.b $04, nF5, $06, nBb5, $02, nRst, $04, nA5
	dc.b $03, nRst, $0F, nAb5, $04, nRst, $02, nRst
	dc.b $12, nBb5, $0F, nRst, $03, nBb5, $09, nRst
	dc.b $03, nF5, $02, nRst, $04, nBb5, $0C, nRst
	dc.b $06
	sLoop		$00, $02, TowerPuppet_Loop1
	saVol		$FE
	saVol		$FF
	sVoice		$0D
	dc.b nC6, $02, nRst, $01, nC5, $02, nRst, $01
	dc.b nF5, $02, nRst, $04, nC6, $02, nRst, $04
	dc.b nBb5, $09, nC5, $02, nRst, $01, nF5, $02
	dc.b nRst, $04, nBb5, $02, nRst, $04, nA5, $06
	dc.b sHold, nA5, $03, nC5, $02, nRst, $01, nF5
	dc.b $02, nRst, $04, nA5, $02, nRst, $04, nG5
	dc.b $0C, nF5, $02, nRst, $04, nE5, $02, nRst
	dc.b $04, nF5, $06, sHold, nF5, $06, nC5, $02
	dc.b nRst, $04, nF5, $02, nRst, $04, nC6, $0C
	dc.b nC5, $02, nRst, $04, nC5, $02, nRst, $04
	dc.b nF5, $06, sHold, nF5, nE5, $02, nRst, $04
	dc.b nF5, $02, nRst, $04, nC5, $06, sHold, nC5
	dc.b $04, nRst, $02, nBb4, $04, nRst, $02, nRst
	dc.b $0C, nC6, $02, nRst, $01, nC5, $02, nRst
	dc.b $01, nF5, $02, nRst, $04, nC6, $02, nRst
	dc.b $04, nBb5, $09, nC5, $02, nRst, $01, nF5
	dc.b $02, nRst, $04, nBb5, $02, nRst, $04, nA5
	dc.b $06, sHold, nA5, $03, nC5, $02, nRst, $01
	dc.b nF5, $02, nRst, $04, nA5, $02, nRst, $04
	dc.b nG5, $0C, nF5, $02, nRst, $04, nE5, $02
	dc.b nRst, $04, nF5, $06, sHold, nF5, nC6, $0C
	dc.b nF6, nC6, $02, nRst, $04, nC6, $02, nRst
	dc.b $04, nEb6, $06, sHold, nEb6, nD6, $02, nRst
	dc.b $04, nBb5, $02, nRst, $04, nF5, $06, sHold
	dc.b nF5, $04, nRst, $02, nG5, $04, nRst, $02
	dc.b nRst, $0C
	saVol		$01
	saVol		$FC
	sVoice		$1A
	dc.b nA5, $02, nRst, $04, nB5, $02, nRst, $04
	dc.b nCs6, $02, nRst, $04, nE6, $06, nRst, nD6
	dc.b $02, nRst, $04, nCs6, $02, nRst, $04, nCs6
	dc.b $0C, nRst, $06, nD6, $03, nRst, nG5, $06
	dc.b sHold, nG5, $12, nRst, $06, nFs5, $02, nRst
	dc.b $04, nG5, $02, nRst, $04, nA5, $03, nRst
	dc.b nCs6, $06, nRst, nB5, $03, nRst, nFs5, $02
	dc.b nRst, $04, nA5, $09, nRst, $03, nG5, $02
	dc.b nRst, $04, nFs5, $02, nRst, $04, nG5, $06
	dc.b sHold, nG5, $12, nRst, $06, nAb5, $12, nFs5
	dc.b nE5, $0C, nRst, $06, nE6, $0F, nRst, $03
	dc.b nEb6, $06, nRst, nB5, nRst, nCs6, $02, nRst
	dc.b $04, nE5, $02, nRst, $04, nE5, $18, nRst
	dc.b $06, nE5, $02, nRst, $01, nFs5, $03, nAb5
	dc.b $06, nCs5, $02, nRst, $04, nAb5, $03, nRst
	dc.b nFs5, $06, sHold, nFs5, nAb5, $02, nRst, $04
	dc.b nA5, $0C, nB5, $24, nE5, $0C, nB5, $12
	dc.b nA5, nD6, $0C, nE6, $60
	saVol		$04
	sJump		TowerPuppet_FM1

TowerPuppet_FM2:
	saVol		$04
	sVoice		$11
	dc.b nF3, $06, nA3, nB3, nC4, nB3, nC4, nA3
	dc.b nD4, nF3, nA3, nB3, nC4, nB3, nC4, nA3
	dc.b nD4, nF3, nA3, nB3, nC4, nB3, nC4, nA3
	dc.b nD4, nC3, nEb3, nC3, nE3, nC3, nF3, nC3
	dc.b nFs3, nF3, nA3, nB3, nC4, nB3, nC4, nA3
	dc.b nD4, nF3, nA3, nB3, nC4, nB3, nC4, nA3
	dc.b nD4, nF3, nA3, nB3, nC4, nB3, nC4, nA3
	dc.b nD4, nCs3, $09, nC3, nB2, nBb2, nA2, $06
	dc.b nAb2
	saVol		$FC
	dc.b nRst, $18
	sVoice		$17
	dc.b nF2, $06, nF3, nE3, nF3, nA2, nF3, nBb2
	dc.b nF3, nC3, nF3, nE3, nF3, nBb2, nF3, nC3
	dc.b nF3, nF2, nF3, nE3, nF3, nA2, nF3, nBb2
	dc.b nF3, nC3, nF3, nE3, nF3, nBb2, nF3, nC3
	dc.b nF3, nF2, nF3, nE3, nF3, nA2, nF3, nBb2
	dc.b nF3, nC3, nF3, nE3, nF3, nBb2, nF3, nC3
	dc.b nF3, nF2, nF3, nE3, nF3, nA2, nF3, nBb2
	dc.b nF3, nC3, nF3, nE3, nF3, nBb2, nF3, nC3
	dc.b nF3, nF2, $06, nF2, $02, nRst, $04, nF2
	dc.b $02, nRst, $04, nF2, $03, nRst, nF2, $02
	dc.b nRst, $04, nF2, $02, nRst, $04, nF2, $02
	dc.b nRst, $04, nF2, $02, nRst, $04, nF2, $02
	dc.b nRst, $04, nF2, $02, nRst, $04, nF2, $02
	dc.b nRst, $04, nBb2, $0C, nBb2, $02, nRst, $04
	dc.b nBb2, $0C, nA2, $02, nRst, $04, nA2, $02
	dc.b nRst, $04, nA2, $02, nRst, $04, nAb2, $0C
	dc.b nAb2, $02, nRst, $04, nAb2, $02, nRst, $04
	dc.b nG2, $06, sHold, nG2, $06, nG2, $02, nRst
	dc.b $04, nG2, $02, nRst, $04, nC2, $06, sHold
	dc.b nC2, nD2, nE2, $0C, nF2, $02, nRst, $04
	dc.b nF2, $02, nRst, $04, nF2, $02, nRst, $04
	dc.b nF2, $03, nRst, nF2, $02, nRst, $04, nF2
	dc.b $02, nRst, $04, nF2, $02, nRst, $04, nF2
	dc.b $02, nRst, $04, nF2, $02, nRst, $04, nF2
	dc.b $02, nRst, $04, nF2, $02, nRst, $04, nBb2
	dc.b $0C, nBb2, $02, nRst, $04, nBb2, $0C, nA2
	dc.b $02, nRst, $04, nA2, $02, nRst, $04, nA2
	dc.b $03, nRst, nAb2, $0C, nAb2, $02, nRst, $04
	dc.b nAb2, $03, nRst, nG2, $09, nRst, $03, nG2
	dc.b $02, nRst, $04, nG2, $06, nC3, sHold, nC3
	dc.b nD3, nE3, $09, nRst, $03, nD3, $02, nRst
	dc.b $04, nD3, $02, nRst, $04, nD3, $02, nRst
	dc.b $04, nD3, $02, nRst, $04, nD3, $02, nRst
	dc.b $04, nD3, $02, nRst, $04, nD3, $06, nG2
	dc.b $02, nRst, $04, nG2, $02, nRst, $04, nG2
	dc.b $02, nRst, $04, nG2, $03, nRst, nA2, $02
	dc.b nRst, $04, nA2, $02, nRst, $04, nA2, $02
	dc.b nRst, $04, nA2, $06, nB2, $02, nRst, $04
	dc.b nB2, $02, nRst, $04, nB2, $02, nRst, $04
	dc.b nB2, $02, nRst, $04, nB2, $02, nRst, $04
	dc.b nB2, $02, nRst, $04, nB2, $02, nRst, $04
	dc.b nB2, $06, nC3, $03, nRst, nC3, $02, nRst
	dc.b $04, nC3, $02, nRst, $04, nC3, $03, nRst
	dc.b nD3, $02, nRst, $04, nD3, $02, nRst, $04
	dc.b nD3, $02, nRst, $04, nC3, $02, nRst, $04
	dc.b nC3, $02, nRst, $04, nB2, $02, nRst, $04
	dc.b nB2, $02, nRst, $04, nB2, $02, nRst, $04
	dc.b nB2, $02, nRst, $04, nB2, $02, nRst, $04
	dc.b nB2, $02, nRst, $04, nB2, $06, nBb2, $02
	dc.b nRst, $04, nBb2, $02, nRst, $04, nBb2, $02
	dc.b nRst, $04, nBb2, $02, nRst, $04, nBb2, $02
	dc.b nRst, $04, nBb2, $02, nRst, $04, nBb2, $02
	dc.b nRst, $04, nBb2, $03, nRst, nA2, nRst, nA2
	dc.b $02, nRst, $04, nA2, $02, nRst, $04, nA2
	dc.b $02, nRst, $04, nA2, $02, nRst, $04, nA2
	dc.b $02, nRst, $04, nA2, $02, nRst, $04, nA2
	dc.b $06, nB2, $02, nRst, $04, nB2, $02, nRst
	dc.b $04, nB2, $02, nRst, $04, nB2, $02, nRst
	dc.b $04, nB2, $02, nRst, $04, nB2, $02, nRst
	dc.b $04, nB2, $02, nRst, $04, nB2, $06, nC3
	dc.b $03, nRst, nC3, $02, nRst, $04, nC3, $02
	dc.b nRst, $04, nC3, $02, nRst, $04, nC3, $02
	dc.b nRst, $04, nC3, $02, nRst, $04, nC3, $02
	dc.b nRst, $04, nC3, $06, nD3, $02, nRst, $04
	dc.b nD3, $02, nRst, $04, nD3, $02, nRst, $04
	dc.b nD3, $02, nRst, $04, nD3, $02, nRst, $04
	dc.b nD3, $03, nRst, nD2, $02, nRst, $04, nD2
	dc.b $06, nD3, nE2, $02, nRst, $04, nE2, $02
	dc.b nRst, $04, nE3, $06, nE2, nD3, nE2, $02
	dc.b nRst, $04, nE2, $03, nRst, nC3, $06, nE2
	dc.b $02, nRst, $04, nE2, $06, nB2, nE2, $03
	dc.b nRst, nAb2, $06, nA2, nB2, nE3
	sJump		TowerPuppet_FM2

TowerPuppet_FM3:
	saVol		$02
	ssLFO		$08, $0C|spCentre
	ssMod68k	$16, $02, $03, $04
	sVoice		$1A
	dc.b nBb4, $0C, nRst, $06, nA4, $18, nRst, $06
	dc.b nAb4, $0C, nRst, $06, nA4, $18, nRst, $06
	dc.b nBb4, $0C, nRst, $06, nA4, $18, nRst, $06
	dc.b nRst, $30, nBb4, $0C, nRst, $06, nA4, $18
	dc.b nRst, $06, nAb4, $0C, nRst, $06, nA4, $18
	dc.b nRst, $06, nBb4, $0C, nRst, $06, nA4, $18
	dc.b nRst, $06
	saVol		$FE
	saTranspose	$F4
	sPan		spLeft, $00
	sVoice		$1D
	dc.b nG4, $02, nRst, $07, nFs4, $02, nRst, $07
	dc.b nF4, $02, nRst, $07, nE4, $02, nRst, $07
	dc.b nEb4, $02, nRst, $04, nD4, $02, nRst, $04
	sPan		spCenter, $00
	saTranspose	$0C
	dc.b nRst, $18
	saVol		$F8
	ssMod68k	$11, $01, $04, $05
	sPan		spRight, $00
	sVoice		$0A

TowerPuppet_Loop2:
	dc.b nC6, $02, nRst, $04
	saVol		$14
	dc.b nC6, $02, nRst, $04
	saVol		$0A
	dc.b nC6, $02, nRst, $04
	saVol		$E2
	dc.b nC6, $03, nRst, $04
	saVol		$14
	dc.b nC6, $02, nRst, $04
	saVol		$0A
	dc.b nC6, $02, nRst, $09
	saVol		$E2
	dc.b nC6, $1E, nRst, $06, nBb5, $02, nRst, $04
	dc.b nBb5, $06, nC6, $03, nRst, nC6, nRst, $04
	saVol		$14
	dc.b nC6, $02, nRst, $04
	saVol		$0A
	dc.b nC6, $02, nRst, $03
	saVol		$E2
	dc.b nC6, $04, nRst, $04
	saVol		$14
	dc.b nC6, $02, nRst, $04
	saVol		$0A
	dc.b nC6, $02, nRst, $08
	saVol		$E2
	dc.b nEb6, $0F, nRst, $03, nD6, $09, nRst, $03
	dc.b nBb5, $02, nRst, $04, nD6, $0C, nRst, $06
	sLoop		$00, $02, TowerPuppet_Loop2
	saVol		$08
	saVol		$F6
	sVoice		$1E

TowerPuppet_Loop3:
	sPan		spLeft, $00
	dc.b nE5, $03, nF5, nC6
	sPan		spRight, $00
	dc.b nE5, nF5, nC6
	sPan		spLeft, $00
	dc.b nE5, nF5, nC6
	sPan		spRight, $00
	dc.b nE5, nF5, nC6, nRst, $0C
	sLoop		$00, $08, TowerPuppet_Loop3
	saVol		$0A
	sPan		spRight, $00
	saVol		$F4
	sVoice		$0C

TowerPuppet_Loop4:
	dc.b nD3, $02, nRst
	saVol		$0C
	dc.b nD3, $01
	saVol		$F4
	dc.b nRst
	sLoop		$00, $07, TowerPuppet_Loop4

TowerPuppet_Loop5:
	dc.b nG3, $02, nRst
	saVol		$0C
	dc.b nG3, $01
	saVol		$F4
	dc.b nRst
	sLoop		$00, $04, TowerPuppet_Loop5

TowerPuppet_Loop6:
	dc.b nA3, $02, nRst
	saVol		$0C
	dc.b nA3, $01
	saVol		$F4
	dc.b nRst
	sLoop		$00, $04, TowerPuppet_Loop6

TowerPuppet_Loop7:
	dc.b nB3, $02, nRst
	saVol		$0C
	dc.b nB3, $01
	saVol		$F4
	dc.b nRst
	sLoop		$00, $07, TowerPuppet_Loop7
	ssMod68k	$05, $01, $04, $05
	dc.b nB3, $06
	ssMod68k	$0A, $01, $04, $05

TowerPuppet_Loop8:
	dc.b nC4, $02, nRst
	saVol		$0C
	dc.b nC4, $01
	saVol		$F4
	dc.b nRst
	sLoop		$00, $04, TowerPuppet_Loop8

TowerPuppet_Loop9:
	dc.b nD4, $02, nRst
	saVol		$0C
	dc.b nD4, $01
	saVol		$F4
	dc.b nRst
	sLoop		$00, $03, TowerPuppet_Loop9
	dc.b nC4, $02, nRst
	saVol		$0C
	dc.b nC4, $01
	saVol		$F4
	dc.b nRst, nC4, $02, nRst
	saVol		$0C
	dc.b nC4, $01
	saVol		$F4
	dc.b nRst

TowerPuppet_Loop10:
	dc.b nB3, $02, nRst
	saVol		$0C
	dc.b nB3, $01
	saVol		$F4
	dc.b nRst
	sLoop		$00, $06, TowerPuppet_Loop10
	ssMod68k	$05, $01, $04, $05
	dc.b nB3, $06
	ssMod68k	$0A, $01, $04, $05

TowerPuppet_Loop11:
	dc.b nBb3, $02, nRst
	saVol		$0C
	dc.b nBb3, $01
	saVol		$F4
	dc.b nRst, nBb3, $02, nRst
	saVol		$0C
	dc.b nBb3, $01
	saVol		$F4
	dc.b nRst, nBb3, $02
	saVol		$0C
	dc.b nBb3, $01
	saVol		$F4
	sLoop		$00, $02, TowerPuppet_Loop11
	dc.b nRst, $06

TowerPuppet_Loop12:
	dc.b nBb3, $02, nRst
	saVol		$0C
	dc.b nBb3, $01
	saVol		$F4
	dc.b nRst
	sLoop		$00, $03, TowerPuppet_Loop12

TowerPuppet_Loop13:
	dc.b nA3, $02
	saVol		$0B
	dc.b nA3, $01
	saVol		$F5
	dc.b nA3, $02
	saVol		$0B
	dc.b nA3, $01
	saVol		$F5
	dc.b nAb4, $02
	saVol		$0B
	dc.b nAb4, $01
	saVol		$F5
	dc.b nAb4, $02
	saVol		$0B
	dc.b nAb4, $01
	saVol		$F5
	sLoop		$00, $04, TowerPuppet_Loop13

TowerPuppet_Loop14:
	dc.b nB3, $02
	saVol		$0B
	dc.b nB3, $01
	saVol		$F5
	dc.b nB3, $02
	saVol		$0B
	dc.b nB3, $01
	saVol		$F5
	dc.b nAb4, $02
	saVol		$0B
	dc.b nAb4, $01
	saVol		$F5
	dc.b nAb4, $02
	saVol		$0B
	dc.b nAb4, $01
	saVol		$F5
	sLoop		$00, $04, TowerPuppet_Loop14
	saVol		$0C
	saVol		$F4
	sPan		spRight, $00
	sVoice		$0C
	dc.b nC4, $02
	saVol		$0B
	dc.b nC4, $01
	saVol		$F5
	dc.b nC4, $02
	saVol		$0B
	dc.b nC4, $01
	saVol		$F5
	sPan		spLeft, $00
	saVol		$03
	sVoice		$02
	dc.b nC5, $02
	saVol		$0B
	dc.b nC5, $01
	saVol		$F5
	dc.b nC5, $02
	saVol		$0B
	dc.b nC5, $01
	saVol		$F5
	dc.b nB4, $02
	saVol		$0B
	dc.b nB4, $01
	saVol		$F5
	dc.b nB4, $02
	saVol		$0B
	dc.b nB4, $01
	saVol		$F5
	saVol		$FD
	sPan		spRight, $00
	sVoice		$0C
	dc.b nC4, $02
	saVol		$0B
	dc.b nC4, $01
	saVol		$F5
	dc.b nC4, $02
	saVol		$0B
	dc.b nC4, $01
	saVol		$F5
	sPan		spLeft, $00
	saVol		$03
	sVoice		$02
	dc.b nC5, $02
	saVol		$0B
	dc.b nC5, $01
	saVol		$F5
	dc.b nC5, $02
	saVol		$0B
	dc.b nC5, $01
	saVol		$F5
	saVol		$FD
	sPan		spRight, $00
	sVoice		$0C
	dc.b nC4, $02
	saVol		$0B
	dc.b nC4, $01
	saVol		$F5
	sPan		spLeft, $00
	saVol		$03
	sVoice		$02
	dc.b nB4, $02
	saVol		$0B
	dc.b nB4, $01
	saVol		$F5
	dc.b nB4, $02
	saVol		$0B
	dc.b nB4, $01
	saVol		$F5
	saVol		$FD
	sPan		spRight, $00
	sVoice		$0C
	dc.b nC4, $02
	saVol		$0B
	dc.b nC4, $01
	saVol		$F5
	dc.b nC4, $02
	saVol		$0B
	dc.b nC4, $01
	saVol		$F5
	sPan		spLeft, $00
	saVol		$03
	sVoice		$02
	dc.b nC5, $02
	saVol		$0B
	dc.b nC5, $01
	saVol		$F5
	saVol		$FD
	sPan		spRight, $00
	sVoice		$0C
	dc.b nD4, $02
	saVol		$0B
	dc.b nD4, $01
	saVol		$F5
	dc.b nD4, $02
	saVol		$0B
	dc.b nD4, $01
	saVol		$F5
	sPan		spLeft, $00
	saVol		$03
	sVoice		$02
	dc.b nD5, $02
	saVol		$0B
	dc.b nD5, $01
	saVol		$F5
	dc.b nD5, $02
	saVol		$0B
	dc.b nD5, $01
	saVol		$F5
	dc.b nC5, $02
	saVol		$0B
	dc.b nC5, $01
	saVol		$F5
	dc.b nC5, $02
	saVol		$0B
	dc.b nC5, $01
	saVol		$F5
	saVol		$FD
	sPan		spRight, $00
	sVoice		$0C
	dc.b nD4, $02
	saVol		$0B
	dc.b nD4, $01
	saVol		$F5
	dc.b nD4, $02
	saVol		$0B
	dc.b nD4, $01
	saVol		$F5
	sPan		spLeft, $00
	saVol		$03
	sVoice		$02
	dc.b nD5, $02
	saVol		$0B
	dc.b nD5, $01
	saVol		$F5
	dc.b nD5, $02
	saVol		$0B
	dc.b nD5, $01
	saVol		$F5
	saVol		$FD
	sPan		spRight, $00
	sVoice		$0C
	dc.b nD4, $02
	saVol		$0B
	dc.b nD4, $01
	saVol		$F5
	sPan		spLeft, $00
	saVol		$03
	sVoice		$02
	dc.b nC5, $02
	saVol		$0B
	dc.b nC5, $01
	saVol		$F5
	dc.b nC5, $02
	saVol		$0B
	dc.b nC5, $01
	saVol		$F5
	saVol		$FD
	sPan		spRight, $00
	sVoice		$0C
	dc.b nD4, $02
	saVol		$0B
	dc.b nD4, $01
	saVol		$F5
	dc.b nD4, $02
	saVol		$0B
	dc.b nD4, $01
	saVol		$F5
	sPan		spLeft, $00
	saVol		$03
	sVoice		$02
	dc.b nD5, $02
	saVol		$0B
	dc.b nD5, $01
	saVol		$F5
	saVol		$FD

TowerPuppet_Loop15:
	sPan		spRight, $00
	sVoice		$0C
	dc.b nE4, $02
	saVol		$0B
	dc.b nE4, $01
	saVol		$F5
	dc.b nE4, $02
	saVol		$0B
	dc.b nE4, $01
	saVol		$F5
	sPan		spLeft, $00
	saVol		$03
	sVoice		$02
	dc.b nE5, $02
	saVol		$0B
	dc.b nE5, $01
	saVol		$F5
	dc.b nE5, $02
	saVol		$0B
	dc.b nE5, $01
	saVol		$F5
	dc.b nD5, $02
	saVol		$0B
	dc.b nD5, $01
	saVol		$F5
	dc.b nD5, $02
	saVol		$0B
	dc.b nD5, $01
	saVol		$F5
	saVol		$FD
	sPan		spRight, $00
	sVoice		$0C
	dc.b nE4, $02
	saVol		$0B
	dc.b nE4, $01
	saVol		$F5
	dc.b nE4, $02
	saVol		$0B
	dc.b nE4, $01
	saVol		$F5
	sPan		spLeft, $00
	saVol		$03
	sVoice		$02
	dc.b nE5, $02
	saVol		$0B
	dc.b nE5, $01
	saVol		$F5
	dc.b nE5, $02
	saVol		$0B
	dc.b nE5, $01
	saVol		$F5
	saVol		$FD
	sPan		spRight, $00
	sVoice		$0C
	dc.b nE4, $02
	saVol		$0B
	dc.b nE4, $01
	saVol		$F5
	sPan		spLeft, $00
	saVol		$03
	sVoice		$02
	dc.b nD5, $02
	saVol		$0B
	dc.b nD5, $01
	saVol		$F5
	dc.b nD5, $02
	saVol		$0B
	dc.b nD5, $01
	saVol		$F5
	saVol		$FD
	sPan		spRight, $00
	sVoice		$0C
	dc.b nE4, $02
	saVol		$0B
	dc.b nE4, $01
	saVol		$F5
	dc.b nE4, $02
	saVol		$0B
	dc.b nE4, $01
	saVol		$F5
	sPan		spLeft, $00
	saVol		$03
	sVoice		$02
	dc.b nE5, $02
	saVol		$0B
	dc.b nE5, $01
	saVol		$F5
	saVol		$FD
	sLoop		$00, $02, TowerPuppet_Loop15
	saVol		$0C
	sPan		spCenter, $00
	sJump		TowerPuppet_FM3

TowerPuppet_FM4:
	dc.b nRst, $0C
	sPan		spLeft, $00
	saVol		$F0
	sVoice		$07
	ssMod68k	$0C, $01, $A1, $CA
	dc.b nF3, nRst, nF3
	sModOff
	saVol		$10
	sPan		spCenter, $00
	saVol		$F4
	sVoice		$08
	dc.b nC6, $03, nC6, nC6, nC6
	saVol		$0C
	sPan		spLeft, $00
	saVol		$F0
	sVoice		$07
	ssMod68k	$0C, $01, $A1, $CA
	dc.b nF3, $06
	sModOff
	saVol		$10
	sPan		spCenter, $00
	saVol		$F4
	sVoice		$08
	dc.b nC6, $03, nC6, nC6, nC6, nC6, $06
	saVol		$0C
	sPan		spLeft, $00
	saVol		$F0
	sVoice		$07
	ssMod68k	$0C, $01, $A1, $CA
	dc.b nF3, $06
	sModOff
	saVol		$10
	sPan		spCenter, $00
	saVol		$F4
	sVoice		$08
	dc.b nC6, $03, nC6
	saVol		$0C
	sLoop		$00, $04, TowerPuppet_FM4
	dc.b nRst, $18
	saVol		$F9
	ssMod68k	$10, $01, $04, $05
	sVoice		$1C
	sPan		spLeft, $00

TowerPuppet_Loop16:
	dc.b nF5, $02, nRst, $04
	saVol		$14
	dc.b nF5, $02, nRst, $04
	saVol		$0A
	dc.b nF5, $02, nRst, $04
	saVol		$E2
	dc.b nEb5, $03, nRst, $04
	saVol		$14
	dc.b nEb5, $02, nRst, $04
	saVol		$0A
	dc.b nEb5, $02, nRst, $09
	saVol		$E2
	dc.b nD5, $1E, nRst, $06, nD5, $02, nRst, $04
	dc.b nD5, $06, nE5, $03, nRst, nF5, nRst, $04
	saVol		$14
	dc.b nF5, $02, nRst, $04
	saVol		$0A
	dc.b nF5, $02, nRst, $03
	saVol		$E2
	dc.b nEb5, $04, nRst, $04
	saVol		$14
	dc.b nEb5, $02, nRst, $04
	saVol		$0A
	dc.b nEb5, $02, nRst, $08
	saVol		$E2
	dc.b nG5, $0F, nRst, $03, nF5, $09, nRst, $03
	dc.b nD5, $02, nRst, $04, nF5, $0C, nRst, $06
	sLoop		$00, $02, TowerPuppet_Loop16
	saVol		$07
	sModOff
	dc.b nRst, $18, nRst, $30, nRst, nRst, nRst, nRst
	dc.b nRst, nRst, nRst, $18
	saVol		$05
	saTranspose	$F4
	ssLFO		$0C, $0C|spCentre
	sVoice		$00
	ssMod68k	$11, $02, $04, $04
	dc.b nD5, $18, sHold, nD5, $1E, nCs5, $06, nD5
	dc.b nG5, sHold, nG5, nFs5, $0C, nE5, $18, nCs5
	dc.b $12, nD5, $0C, nA5, $18, sHold, nA5, $06
	dc.b nG5, $06, nFs5, nG5
	sModOff
	saTranspose	$0C
	saVol		$FB
	saVol		$F7
	sVoice		$1E
	dc.b nB4, $02
	saVol		$0B
	dc.b nB4, $01
	saVol		$F5
	dc.b nE5, $02
	saVol		$0B
	dc.b nE5, $01
	saVol		$F5
	dc.b nAb5, $02
	saVol		$0B
	dc.b nAb5, $01
	saVol		$F5
	dc.b nB4, $02
	saVol		$0B
	dc.b nB4, $01
	saVol		$F5
	dc.b nE5, $02
	saVol		$0B
	dc.b nE5, $01
	saVol		$F5
	dc.b nAb5, $02
	saVol		$0B
	dc.b nAb5, $01
	saVol		$F5
	dc.b nB4, $02
	saVol		$0B
	dc.b nB4, $01
	saVol		$F5
	dc.b nE5, $02
	saVol		$0B
	dc.b nE5, $01
	saVol		$F5
	dc.b nAb5, $02
	saVol		$0B
	dc.b nAb5, $01
	saVol		$F5
	dc.b nB4, $02
	saVol		$0B
	dc.b nB4, $01
	saVol		$F5
	dc.b nE5, $02
	saVol		$0B
	dc.b nE5, $01
	saVol		$F5
	dc.b nAb5, $02
	saVol		$0B
	dc.b nAb5, $01
	saVol		$F5
	dc.b nRst, $0C, nBb4, $02
	saVol		$0B
	dc.b nBb4, $01
	saVol		$F5
	dc.b nCs5, $02
	saVol		$0B
	dc.b nCs5, $01
	saVol		$F5
	dc.b nFs5, $02
	saVol		$0B
	dc.b nFs5, $01
	saVol		$F5
	dc.b nBb4, $02
	saVol		$0B
	dc.b nBb4, $01
	saVol		$F5
	dc.b nCs5, $02
	saVol		$0B
	dc.b nCs5, $01
	saVol		$F5
	dc.b nFs5, $02
	saVol		$0B
	dc.b nFs5, $01
	saVol		$F5
	dc.b nBb4, $02
	saVol		$0B
	dc.b nBb4, $01
	saVol		$F5
	dc.b nCs5, $02
	saVol		$0B
	dc.b nCs5, $01
	saVol		$F5
	dc.b nFs4, $02
	saVol		$0B
	dc.b nFs5, $01
	saVol		$F5
	dc.b nBb4, $02
	saVol		$0B
	dc.b nBb4, $01
	saVol		$F5
	dc.b nCs5, $02
	saVol		$0B
	dc.b nCs5, $01
	saVol		$F5
	dc.b nFs5, $02
	saVol		$0B
	dc.b nFs5, $01
	saVol		$F5
	dc.b nRst, $0C, nA4, $02
	saVol		$0B
	dc.b nA4, $01
	saVol		$F5
	dc.b nCs5, $02
	saVol		$0B
	dc.b nCs5, $01
	saVol		$F5
	dc.b nE5, $02
	saVol		$0B
	dc.b nE5, $01
	saVol		$F5
	dc.b nA4, $02
	saVol		$0B
	dc.b nA4, $01
	saVol		$F5
	dc.b nCs5, $02
	saVol		$0B
	dc.b nCs5, $01
	saVol		$F5
	dc.b nE5, $02
	saVol		$0B
	dc.b nE5, $01
	saVol		$F5
	dc.b nA4, $02
	saVol		$0B
	dc.b nA4, $01
	saVol		$F5
	dc.b nCs5, $02
	saVol		$0B
	dc.b nCs5, $01
	saVol		$F5
	dc.b nE5, $02
	saVol		$0B
	dc.b nE5, $01
	saVol		$F5
	dc.b nA4, $02
	saVol		$0B
	dc.b nA4, $01
	saVol		$F5
	dc.b nCs5, $02
	saVol		$0B
	dc.b nCs5, $01
	saVol		$F5
	dc.b nE5, $02
	saVol		$0B
	dc.b nE5, $01
	saVol		$F5
	dc.b nRst, $0C
	saVol		$FE
	dc.b nCs5, $06, nA4, nCs5, nB4, nRst, nCs5
	sVoice		$20
	dc.b nEb5, sHold, nD5, $01, sHold, nCs5, sHold, nC5
	dc.b sHold, nB4, sHold, nBb4, sHold, nA4, sHold, nAb4
	dc.b sHold, nG4, sHold, nFs4, sHold, nF4, sHold, nE4
	dc.b sHold, nEb4, nRst, $12
	saVol		$02
	saVol		$09
	sPan		spCenter, $00
	ssMod68k	$0C, $01, $A1, $CA
	saVol		$01
	sVoice		$05
	saTranspose	$18
	dc.b nRst, $30, nRst, $18, nE2, $02, nRst, $04
	dc.b nE2, $02, nRst, $04, nE3, $06, nE2, nD3
	dc.b nE2, $02, nRst, $04, nE2, $03, nRst, nC3
	dc.b $06, nE2, $02, nRst, $04, nE2, $06, nB2
	dc.b nE2, $03, nRst, nAb2, $06, nA2, nB2, nE3
	sModOff
	ssLFO		$00, $00|spCentre
	saVol		$FF
	saTranspose	$E8
	sJump		TowerPuppet_FM4

TowerPuppet_PSG1:
	dc.b nRst, $30, nRst, nRst
	sVolEnv		vDyHe0A
	saVol		$08
	dc.b nC6, $04, nRst, $02, nCs6, $04, nRst, $02
	dc.b nC6, $04, nRst, $02, nD6, $04, nRst, $02
	dc.b nC6, $04, nRst, $02, nEb6, $04, nRst, $02
	dc.b nC6, $04, nRst, $02, nE6, $04, nRst, $02
	saVol		-$08
	dc.b nRst, $30, nRst, nRst, nRst, nRst, $18
	sVolEnv		v00
	saVol		$08
	saTranspose	$F4
	ssMod68k	$13, $02, $02, $02

TowerPuppet_Loop17:
	dc.b nA5, $02, nRst, $10, nAb5, $03, nRst, nRst
	dc.b $12, nBb5, $1E, nRst, $06, nF5, $02, nRst
	dc.b $04, nF5, $06, nBb5, $02, nRst, $04, nA5
	dc.b $03, nRst, $0F, nAb5, $04, nRst, $02, nRst
	dc.b $12, nBb5, $0F, nRst, $03, nBb5, $09, nRst
	dc.b $03, nF5, $02, nRst, $04, nBb5, $0C, nRst
	dc.b $06
	sLoop		$00, $02, TowerPuppet_Loop17
	saTranspose	$0C
	sModOff
	dc.b nC6, $02, nRst, $01, nC5, $02, nRst, $01
	dc.b nF5, $02, nRst, $04, nC6, $02, nRst, $04
	dc.b nBb5, $09, nC5, $02, nRst, $01, nF5, $02
	dc.b nRst, $04, nBb5, $02, nRst, $04, nA5, $06
	dc.b sHold, nA5, $03, nC5, $02, nRst, $01, nF5
	dc.b $02, nRst, $04, nA5, $02, nRst, $04, nG5
	dc.b $0C, nF5, $02, nRst, $04, nE5, $02, nRst
	dc.b $04, nF5, $06, sHold, nF5, $06, nC5, $02
	dc.b nRst, $04, nF5, $02, nRst, $04, nC6, $0C
	dc.b nC5, $02, nRst, $04, nC5, $02, nRst, $04
	dc.b nF5, $06, sHold, nF5, nE5, $02, nRst, $04
	dc.b nF5, $02, nRst, $04, nC5, $06, sHold, nC5
	dc.b $04, nRst, $02, nBb4, $04, nRst, $02, nRst
	dc.b $0C, nC6, $02, nRst, $01, nC5, $02, nRst
	dc.b $01, nF5, $02, nRst, $04, nC6, $02, nRst
	dc.b $04, nBb5, $09, nC5, $02, nRst, $01, nF5
	dc.b $02, nRst, $04, nBb5, $02, nRst, $04, nA5
	dc.b $06, sHold, nA5, $03, nC5, $02, nRst, $01
	dc.b nF5, $02, nRst, $04, nA5, $02, nRst, $04
	dc.b nG5, $0C, nF5, $02, nRst, $04, nE5, $02
	dc.b nRst, $04, nF5, $06, sHold, nF5, nC6, $0C
	dc.b nF6, nC6, $02, nRst, $04, nC6, $02, nRst
	dc.b $04, nEb6, $06, sHold, nEb6, nD6, $02, nRst
	dc.b $04, nBb5, $02, nRst, $04, nF5, $06, sHold
	dc.b nF5, $04, nRst, $02, nG5, $04, nRst, $02
	dc.b nRst, $0C
	sVolEnv		v00
	ssMod68k	$14, $02, $02, $02
	dc.b nD5, $18, sHold, nD5, $1E, nCs5, $06, nD5
	dc.b nG5, sHold, nG5, nFs5, $0C, nE5, $16, nRst
	dc.b $02, nCs5, $12, nD5, $0B, nRst, $01, nA5
	dc.b $18, sHold, nA5, $05, nRst, $01, nG5, $06
	dc.b nFs5, nG5
	saVol		$08
	dc.b nAb5, $11, nRst, $01, nFs5, $12, nE5, $0D
	dc.b nRst, $05, nE6, $12, nEb6, $0C, nB5, $09
	dc.b nRst, $03, nCs6, $06, nE5, $04, nRst, $02
	dc.b nE5, $18, nRst, $06, nE5, $02, nRst, $01
	dc.b nFs5, $02, nRst, $01, nCs5, $06, nA4, $03
	dc.b nRst, nCs5, $06, nB4, sHold, nB4, nCs5, nEb5
	dc.b $0C
	saVol		-$10
	dc.b nE5, $12, nA5, $03, nE6, sHold, nE6, $0C
	dc.b nE5, $09, nRst, $03, nE5, $12, nA5, $03
	dc.b nE6, sHold, nE6, $0C, nE5, $09, nRst, $03
	ssMod68k	$04, $01, $02, $08
	dc.b nE5, nA5, nE6, nE5, nA5, nE6, nE5, nA5
	dc.b nE6, nE5, nA5, nE6, nE5, nA5, nE6, nE5
	dc.b nA5, nB5, nD6, nA5, nAb5, nA5, nD6, nFs5
	dc.b nAb5, nB5, nFs5, nA5, nAb5, nD5, nE5, nD6
	sModOff
	sJump		TowerPuppet_PSG1

TowerPuppet_PSG2:
	dc.b nRst, $30, nRst, nRst, nRst, nRst, nRst, nRst
	dc.b nRst, nRst, $18
	saVol		$10
	ssMod68k	$14, $02, $02, $02

TowerPuppet_Loop18:
	dc.b nF5, $02, nRst, $04
	saVol		$10
	dc.b nF5, $02, nRst, $04
	saVol		$08
	dc.b nF5, $02, nRst, $04
	saVol		-$18
	dc.b nEb5, $03, nRst, $04
	saVol		$10
	dc.b nEb5, $02, nRst, $04
	saVol		$08
	dc.b nEb5, $02, nRst, $09
	saVol		-$18
	dc.b nD5, $1E, nRst, $06, nD5, $02, nRst, $04
	dc.b nD5, $06, nE5, $03, nRst, nF5, nRst, $04
	saVol		$10
	dc.b nF5, $02, nRst, $04
	saVol		$08
	dc.b nF5, $02, nRst, $03
	saVol		-$18
	dc.b nEb5, $04, nRst, $04
	saVol		$10
	dc.b nEb5, $02, nRst, $04
	saVol		$08
	dc.b nEb5, $02, nRst, $08
	saVol		-$18
	dc.b nG5, $0F, nRst, $03, nF5, $09, nRst, $03
	dc.b nD5, $02, nRst, $04, nF5, $0C, nRst, $06
	sLoop		$00, $02, TowerPuppet_Loop18
	sModOff
	saTranspose	$F4

TowerPuppet_Loop19:
	dc.b nE5, $03, nF5, nC6, nE5, nF5, nC6, nE5
	dc.b nF5, nC6, nE5, nF5, nC6, nRst, $0C
	sLoop		$00, $08, TowerPuppet_Loop19
	saTranspose	$0C
	ssMod68k	$16, $02, $02, $02
	dc.b nA5, $04, nRst, $02, nB5, $04, nRst, $02
	dc.b nCs6, $04, nRst, $02, nE6, $0C, nD6, $04
	dc.b nRst, $02, nCs6, $04, nRst, $02, nCs6, $0C
	dc.b nRst, $06, nD6, $03, nRst, nG5, $06, sHold
	dc.b nG5, $12, nRst, $06, nFs5, $04, nRst, $02
	dc.b nG5, $04, nRst, $02, nA5, $04, nRst, $02
	dc.b nCs6, $0C, nB5, $04, nRst, $02, nFs5, $04
	dc.b nRst, $02, nA5, $09, nRst, $03, nG5, $04
	dc.b nRst, $02, nFs5, $04, nRst, $02, nG5, $06
	dc.b sHold, nG5, $12, nRst, $06
	saVol		-$08
	saTranspose	$F4
	dc.b nB4, $03, nE5, nAb5, nB4, nE5, nAb5, nB4
	dc.b nE5, nAb5, nB4, nE5, nAb5, nRst, $0C, nBb4
	dc.b $03, nCs5, nFs5, nBb4, nCs5, nFs5, nBb4, nCs5
	dc.b nFs5, nBb4, nCs5, nFs5, nRst, $0C, nA4, $03
	dc.b nCs5, nE5, nA4, nCs5, nE5, nA4, nCs5, nE5
	dc.b nA4, nCs5, nE5, nRst, $0C, nCs5, $06, nA4
	dc.b nCs5, nB4, nRst, nCs5, nEb5, nRst
	saTranspose	$0C
	ssMod68k	$14, $02, $02, $02
	dc.b nB5, $24, nE5, $0C, nB5, $12, nA5, nD6
	dc.b $0C, nE6, $60
	saVol		-$08
	sJump		TowerPuppet_PSG2

TowerPuppet_PSG3:
	sNoisePSG	$E7

TowerPuppet_Loop20:
	sGate		$01
	sVolEnv		vDyHe03
	dc.b nHiHat, $03, nHiHat
	sGate		$03
	sVolEnv		vDyHe05
	dc.b nHiHat
	sGate		$01
	sVolEnv		vDyHe03
	dc.b nHiHat, nHiHat, nHiHat
	sGate		$03
	sVolEnv		vDyHe05
	dc.b nHiHat
	sGate		$01
	sVolEnv		vDyHe03
	dc.b nHiHat, nHiHat, nHiHat
	sGate		$03
	sVolEnv		vDyHe05
	dc.b nHiHat
	sGate		$01
	sVolEnv		vDyHe03
	dc.b nHiHat, nHiHat
	sGate		$03
	sVolEnv		vDyHe05
	dc.b nHiHat
	sGate		$04
	sVolEnv		vDyHe05
	dc.b nHiHat
	sGate		$01
	sVolEnv		vDyHe03
	dc.b nHiHat
	sGate		$05
	sVolEnv		vDyHe03
	dc.b nHiHat, $0C, nHiHat, nHiHat, nHiHat
	sLoop		$00, $12, TowerPuppet_Loop20
	sGate		$01
	sVolEnv		vDyHe03
	dc.b nHiHat, $03, nHiHat
	sGate		$03
	sVolEnv		vDyHe05
	dc.b nHiHat
	sGate		$01
	sVolEnv		vDyHe03
	dc.b nHiHat, nHiHat, nHiHat
	sGate		$03
	sVolEnv		vDyHe05
	dc.b nHiHat
	sGate		$01
	sVolEnv		vDyHe03
	dc.b nHiHat
	sJump		TowerPuppet_PSG3

TowerPuppet_DAC1:
	sPan		spNone		; Allow DAC2 to control panning
	sStop

d81 =	dKick
d82 =	dSnare
d84 =	dSnare
d87 =	dSnare
d88 =	dHiTom
d89 =	dTom
d8A =	dLowKick
d8C =	dClap
dA2 =	dClap
dA3 =	dClap

TowerPuppet_DAC2:
	dc.b d8C, $0C, d89, $06, d81, $06, d81, $0C
	dc.b d89
	sPan		spLeft, $00
	dc.b d87, $03, d87
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87, $03
	sPan		spCenter, $00
	dc.b d89, $06
	sPan		spLeft, $00
	dc.b d87, $03, d87
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87, d84, $06
	sPan		spCenter, $00
	dc.b d89, d81, $03, d84, d81, $0C, d89, $06
	dc.b d81, d81, $0C, d89, $06, d81
	sPan		spLeft, $00
	dc.b d87, $03
	sPan		spCenter, $00
	dc.b d81, d81
	sPan		spLeft, $00
	dc.b d87, $03
	sPan		spCenter, $00
	dc.b d89, $06, d81, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81, $03
	sPan		spLeft, $00
	dc.b d87, d84, $06
	sPan		spCenter, $00
	dc.b d89, $06, d81, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	sPan		spRight, $00
	dc.b d8C, $0C
	sPan		spCenter, $00
	dc.b d89, $06, d81, d81, $0C, d89, $0C
	sPan		spLeft, $00
	dc.b d87, $03, d87
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87, $03
	sPan		spCenter, $00
	dc.b d89, $06
	sPan		spLeft, $00
	dc.b d87, $03, d87
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87, d84, $06
	sPan		spCenter, $00
	dc.b d89, $06, d81, $03, d84, d81, $0C, d89
	dc.b $06, d81, $06, d81, $0C, d89, $06, d81

	ssVol		$00
	sModePitchDAC
	sVoice		dOrchHit
	dc.b nFs4, $09, nF4, nE4, nEb4, nD4, $06, nCs4
	sModeSampDAC
	ssVol		$08

	dc.b d88, $03, d88, d8C, $0C, d81, $02, d81
	dc.b d81, d81, $0C, d82, $06, d81, d81, $0C
	dc.b d82, d81, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b nRst, d81, d82, $06, d81, $03
	sPan		spLeft, $00
	dc.b d87, nRst, d87, d87, nRst
	sPan		spCenter, $00
	dc.b d82, $06, d81, $03, d84, d81, $0C, d82
	dc.b $06, d81, d81, nRst, d82, d81
	sPan		spLeft, $00
	dc.b d87, $03
	sPan		spCenter, $00
	dc.b d81, $06, d81, $03, d82, $06
	sPan		spLeft, $00
	dc.b d87, $03, d87
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87, d87, $06
	sPan		spCenter, $00
	dc.b d82, $03, d82
	sPan		spLeft, $00
	dc.b dA2, $06
	sPan		spCenter, $00
	dc.b dA3, $0C, d82, $06, d81, d81, $03, d89
	dc.b d8A, $06, d82, d81
	sPan		spLeft, $00
	dc.b d87, $03
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81, d82, $06, d81, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87, d87, $06
	sPan		spCenter, $00
	dc.b d82, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b dA2, $03
	sPan		spCenter, $00
	dc.b dA3, $0C, d82, $06, d81, d81, $0C, d82
	dc.b $06, d81
	sPan		spLeft, $00
	dc.b d87, $03
	sPan		spCenter, $00
	dc.b d89, d8A
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d82, $06, d81, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87, d87, $06
	sPan		spCenter, $00
	dc.b d82, $03, d88, d89, d82
	sPan		spRight, $00
	dc.b d8C, $0C
	sPan		spCenter, $00
	dc.b d82, $06, d81, d81, $0C, d82, d81, $03
	sPan		spLeft, $00
	dc.b d87, $06
	sPan		spCenter, $00
	dc.b d81, $03, d82, $06, d81, $03
	sPan		spLeft, $00
	dc.b d87, nRst, d87, d87, $06
	sPan		spCenter, $00
	dc.b d82, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81, d84, d81, $0C, d82, $06, d81, d81
	dc.b $0C, d82, $06, d81, $09, d81, $03, d81
	dc.b $06, d82, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81, nRst
	sPan		spLeft, $00
	dc.b d87, d87
	sPan		spCenter, $00
	dc.b d82
	sPan		spLeft, $00
	dc.b d87, d87
	sPan		spCenter, $00
	dc.b d82
	sPan		spLeft, $00
	dc.b d8C, $0C
	sPan		spCenter, $00
	dc.b d82, $06, d81, d81, $0C, d82, $06, d81
	sPan		spLeft, $00
	dc.b d87, $03
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81, d82, $06, d81, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81, d89, d8A, $06, d82, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81, d82, d81, $0C, d82, $06, d81, d81
	dc.b $0C, d82, $06, d81
	sPan		spLeft, $00
	dc.b d87, $03
	sPan		spCenter, $00
	dc.b d81, d81
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d82, $06, d81, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81, d88, d82, d88
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d89, d8A, d84
	sPan		spLeft, $00
	dc.b d8C, $0C
	sPan		spCenter, $00
	dc.b d82, $06, d81, d81, $0C, d82, d81, $03
	sPan		spLeft, $00
	dc.b d87, $06
	sPan		spCenter, $00
	dc.b d81, $03, d82, $06, d81, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b nRst, d89, d8A, $06, d82, $03, d82, d81
	dc.b d82
	sPan		spLeft, $00
	dc.b d8C, $0C
	sPan		spCenter, $00
	dc.b d82, $06, d81, d81, $0C, d82, $06, d81
	dc.b $09, d81, $03, d81, $06, d82, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81, $06
	sPan		spLeft, $00
	dc.b d87, $03, d87
	sPan		spCenter, $00
	dc.b d82, d89, d8A, d82
	sPan		spLeft, $00
	dc.b d8C, $0C
	sPan		spCenter, $00
	dc.b d82, $06, d81, d81, $0C, d82, $06, d81
	sPan		spLeft, $00
	dc.b d87, $03
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81, d82, $06, d81, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87, d87, $06
	sPan		spCenter, $00
	dc.b d82, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81, d84
	sPan		spLeft, $00
	dc.b d8C, $0C
	sPan		spCenter, $00
	dc.b d82, $06, d81, d81, $0C, d82, $06, d81
	sPan		spLeft, $00
	dc.b d87, $03
	sPan		spCenter, $00
	dc.b d81, d81
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d82, $06, d81, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81
	sPan		spLeft, $00
	dc.b d87, d87, $06
	sPan		spCenter, $00
	dc.b d82, $03, d89, d8A, d84
	sPan		spLeft, $00
	dc.b d8C, $0C
	sPan		spCenter, $00
	dc.b d82, $06, d81, d81, $0C, d82, d81, $03
	sPan		spLeft, $00
	dc.b d87, $06
	sPan		spCenter, $00
	dc.b d81, $03, d82, $06, d81, $03
	sPan		spLeft, $00
	dc.b d87, nRst, d87, d87, $06
	sPan		spCenter, $00
	dc.b d82, $03
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d81, d84
	sPan		spLeft, $00
	dc.b d8C, $0C
	sPan		spCenter, $00
	dc.b d82, $06, d81, d81, $0C, d82, $06, d81
	dc.b $09, d88, $03, d81, d88, d88
	sPan		spLeft, $00
	dc.b d87
	sPan		spCenter, $00
	dc.b d88, d89, d82, d89, d82, d89, d82, d89
	dc.b d8A, d82
	sJump		TowerPuppet_DAC2