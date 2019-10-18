Credits_Header:
	sHeaderInit
	sHeaderTempo	$81, $05
	sHeaderCh	$05, $03
	sHeaderDAC	Credits_DAC1
	sHeaderDAC	Credits_DAC2
	sHeaderFM	Credits_FM1, $F4, $12
	sHeaderFM	Credits_FM2, $00, $0B
	sHeaderFM	Credits_FM3, $F4, $14
	sHeaderFM	Credits_FM4, $F4, $08
	sHeaderFM	Credits_FM5, $F4, $20
	sHeaderPSG	Credits_PSG1, $D0+$0C, $08, $00, v00
	sHeaderPSG	Credits_PSG2, $D0+$0C, $18, $00, v00
	sHeaderPSG	Credits_PSG3, $00+$0C, $18, $00, v04

	; Patch $00
	; $20
	; $36, $35, $30, $31,	$DF, $DF, $9F, $9F
	; $07, $06, $09, $06,	$07, $06, $06, $08
	; $20, $10, $10, $F8,	$19, $37, $13, $80
	spAlgorithm	$00
	spFeedback	$04
	spDetune	$03, $03, $03, $03
	spMultiple	$06, $00, $05, $01
	spRateScale	$03, $02, $03, $02
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$07, $09, $06, $06
	spSustainLv	$02, $01, $01, $0F
	spDecayRt	$07, $06, $06, $08
	spReleaseRt	$00, $00, $00, $08
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$19, $13, $37, $00

	; Patch $01
	; $2C
	; $72, $78, $34, $34,	$1F, $12, $1F, $12
	; $00, $0A, $00, $0A,	$00, $00, $00, $00
	; $0F, $1F, $0F, $1F,	$16, $80, $17, $80
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
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$16, $17, $00, $00

	; Patch $02
	; $2C
	; $74, $74, $34, $34,	$1F, $12, $1F, $1F
	; $00, $00, $00, $00,	$00, $01, $00, $01
	; $0F, $3F, $0F, $3F,	$16, $80, $17, $80
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
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$16, $17, $00, $00

	; Patch $03
	; $04
	; $72, $42, $32, $32,	$12, $12, $12, $12
	; $00, $08, $00, $08,	$00, $08, $00, $08
	; $0F, $1F, $0F, $1F,	$23, $80, $23, $80
	spAlgorithm	$04
	spFeedback	$00
	spDetune	$07, $03, $04, $03
	spMultiple	$02, $02, $02, $02
	spRateScale	$00, $00, $00, $00
	spAttackRt	$12, $12, $12, $12
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$00, $00, $08, $08
	spSustainLv	$00, $00, $01, $01
	spDecayRt	$00, $00, $08, $08
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$23, $23, $00, $00

	; Patch $04
	; $2C
	; $74, $74, $34, $34,	$1F, $12, $1F, $1F
	; $00, $07, $00, $07,	$00, $07, $00, $07
	; $00, $38, $00, $38,	$16, $80, $17, $80
	spAlgorithm	$04
	spFeedback	$05
	spDetune	$07, $03, $07, $03
	spMultiple	$04, $04, $04, $04
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $12, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$00, $00, $07, $07
	spSustainLv	$00, $00, $03, $03
	spDecayRt	$00, $00, $07, $07
	spReleaseRt	$00, $00, $08, $08
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$16, $17, $00, $00

	; Patch $05
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

	; Patch $06
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

	; Patch $07
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

	; Patch $08
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

	; Patch $09
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

	; Patch $0A
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

	; Patch $0B
	; $34
	; $33, $41, $7E, $74,	$5B, $9F, $5F, $1F
	; $04, $07, $07, $08,	$00, $00, $00, $00
	; $FF, $FF, $EF, $FF,	$23, $90, $29, $97
	spAlgorithm	$04
	spFeedback	$06
	spDetune	$03, $07, $04, $07
	spMultiple	$03, $0E, $01, $04
	spRateScale	$01, $01, $02, $00
	spAttackRt	$1B, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$04, $07, $07, $08
	spSustainLv	$0F, $0E, $0F, $0F
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$23, $29, $10, $17

	; Patch $0C
	; $04
	; $72, $42, $32, $32,	$1F, $1F, $1F, $1F
	; $00, $00, $00, $00,	$00, $00, $00, $00
	; $00, $07, $00, $07,	$23, $80, $23, $80
	spAlgorithm	$04
	spFeedback	$00
	spDetune	$07, $03, $04, $03
	spMultiple	$02, $02, $02, $02
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$00, $00, $00, $00
	spSustainLv	$00, $00, $00, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$00, $00, $07, $07
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$23, $23, $00, $00

	; Patch $0D
	; $3C
	; $38, $74, $76, $33,	$10, $10, $10, $10
	; $02, $07, $04, $07,	$03, $09, $03, $09
	; $2F, $2F, $2F, $2F,	$1E, $80, $1E, $80
	spAlgorithm	$04
	spFeedback	$07
	spDetune	$03, $07, $07, $03
	spMultiple	$08, $06, $04, $03
	spRateScale	$00, $00, $00, $00
	spAttackRt	$10, $10, $10, $10
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$02, $04, $07, $07
	spSustainLv	$02, $02, $02, $02
	spDecayRt	$03, $03, $09, $09
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1E, $1E, $00, $00

	; Patch $0E
	; $F4
	; $06, $04, $0F, $0E,	$1F, $1F, $1F, $1F
	; $00, $00, $0B, $0B,	$00, $00, $05, $08
	; $0F, $0F, $FF, $FF,	$15, $85, $02, $8A
	spAlgorithm	$04
	spFeedback	$06
	spDetune	$00, $00, $00, $00
	spMultiple	$06, $0F, $04, $0E
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$00, $0B, $00, $0B
	spSustainLv	$00, $0F, $00, $0F
	spDecayRt	$00, $05, $00, $08
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$15, $02, $05, $0A

	; Patch $0F
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

	; Patch $10
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

	; Patch $11
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

	; Patch $12
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

	; Patch $13
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

	; Patch $14
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

	; Patch $15
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

	; Patch $16
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

	; Patch $17
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

	; Patch $18
	; $3D
	; $01, $02, $02, $02,	$14, $0E, $8C, $0E
	; $08, $05, $02, $05,	$00, $00, $00, $00
	; $1F, $1F, $1F, $1F,	$1A, $80, $80, $80
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
	spTotalLv	$1A, $00, $00, $00

	; Patch $19
	; $20
	; $36, $35, $30, $31,	$DF, $DF, $9F, $9F
	; $07, $06, $09, $06,	$07, $06, $06, $08
	; $2F, $1F, $1F, $FF,	$19, $37, $13, $80
	spAlgorithm	$00
	spFeedback	$04
	spDetune	$03, $03, $03, $03
	spMultiple	$06, $00, $05, $01
	spRateScale	$03, $02, $03, $02
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$07, $09, $06, $06
	spSustainLv	$02, $01, $01, $0F
	spDecayRt	$07, $06, $06, $08
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$19, $13, $37, $00

	; Patch $1A
	; $3A
	; $51, $08, $51, $02,	$1E, $1E, $1E, $10
	; $1F, $1F, $1F, $0F,	$00, $00, $00, $02
	; $0F, $0F, $0F, $1F,	$18, $24, $22, $81
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$05, $05, $00, $00
	spMultiple	$01, $01, $08, $02
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1E, $1E, $1E, $10
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$1F, $1F, $1F, $0F
	spSustainLv	$00, $00, $00, $01
	spDecayRt	$00, $00, $00, $02
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$18, $22, $24, $01

	; Patch $1B
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

	; Patch $1C
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

	; Patch $1D
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

	; Patch $1E
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
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$18, $27, $28, $00

	; Patch $1F
	; $36
	; $0F, $01, $01, $01,	$1F, $1F, $1F, $1F
	; $12, $11, $0E, $00,	$00, $0A, $07, $09
	; $FF, $0F, $1F, $0F,	$18, $80, $80, $80
	spAlgorithm	$06
	spFeedback	$06
	spDetune	$00, $00, $00, $00
	spMultiple	$0F, $01, $01, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$12, $0E, $11, $00
	spSustainLv	$0F, $01, $00, $00
	spDecayRt	$00, $07, $0A, $09
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$18, $00, $00, $00

	; Patch $20
	; $3A
	; $03, $19, $01, $53,	$1F, $DF, $1F, $9F
	; $0C, $02, $0C, $05,	$04, $04, $04, $07
	; $1F, $FF, $0F, $2F,	$1D, $36, $1B, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$00, $00, $01, $05
	spMultiple	$03, $01, $09, $03
	spRateScale	$00, $00, $03, $02
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0C, $0C, $02, $05
	spSustainLv	$01, $00, $0F, $02
	spDecayRt	$04, $04, $04, $07
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1D, $1B, $36, $00

Credits_FM1:
	dc.b nRst, $60
	sVoice		$1C
	saVol		$F8
	sNoteTimeOut	$06
	sCall		Credits_Call1
	sPan		spCenter, $00
	sNoteTimeOut	$00
	sVoice		$03
	ssMod68k	$0D, $01, $07, $04
	dc.b nRst, $30
	sCall		Credits_Call3
	dc.b nE6, nD6, $18, nC6, $0C, nB5, $18, nC6
	dc.b $0C, nB5, $18, nG5, $54
	sCall		Credits_Call3
	dc.b $0C, nF5, $18, nA5, $0C, nG5, $18, nA5
	dc.b $0C, nG5, $18, nC5, $24, nRst, $60, nRst
	dc.b nRst, nRst
	sModOff
	ssTempo		$11
	sVoice		$05
	saVol		$02
	dc.b nRst, $06, nE5, nG5, nE5, nG5, $09, nA5
	dc.b nB5, $0C, nC6, $06, nB5, nA5, nG5, $09
	dc.b nA5, $06, nG5, $03, nE5, $06, nRst, $06
	dc.b nA5, nC6, nA5, nC6, $09, nD6, nE6, $0C
	dc.b nF6, $06, nE6, nD6, nC6, $0C, nA5, $0C
	dc.b nD6, $04, nC6, nD6, nC6, $24
	saTranspose	$F4
	saVol		$09
	sVoice		$08
	dc.b nRst, $18, nA5, $06, nB5, nC6, nE6
	sCall		Credits_Call4
	sVoice		$0B
	saVol		$EB
	dc.b nRst, $0C, nG5, nA5, nG6
	sCall		Credits_Call5
	dc.b nE6, $1E, nE7, $06, nC7, $18, nRst, $24
	ssTempo		$1A
	sVoice		$0F
	saTranspose	$0C
	saVol		$0B
	sCall		Credits_Call6
	ssTempo		$25
	dc.b nRst, $60
	ssTempo		$33
	dc.b nRst, $30
	sVoice		$17
	saVol		$0E
	dc.b nRst, $04, nF6, $08, nE6, $03, nRst, nD6
	dc.b nRst, nC6, nRst, nD6, nRst, nC6, $04, nA5
	dc.b nRst, $02, nBb5, nRst, $04, nBb5, $08, nC6
	dc.b $03, nRst, nBb5, nRst, nA5, $04, nBb5, nRst
	dc.b $02, nC6, $0E, nRst, $06, nE6, $02, nRst
	dc.b $04, nE6, $0C, nF6, nE6, $0A, nD6, $02
	ssTempo		$40
	saVol		$F5
	sVoice		$1A
	dc.b nRst, $60
	sCall		Credits_Call8
	saVol		$09
	ssDetune	$03
	sVoice		$18
	ssMod68k	$00, $01, $06, $04
	sCall		Credits_Call9
	saVol		$EF
	sVoice		$1B
	ssDetune	$02
	dc.b nA1, $6C, sHold, $60
	sStop

Credits_Call3:
	dc.b nC6, $0C, nA5, $18, nC6, $0C, nB5, $18
	dc.b nC6, $0C, nB5, $18, nG5, $48, nA5, $0C
	sRet

Credits_Call8:
	dc.b nRst, $0C, nCs6, $15, nRst, $03, nCs6, $06
	dc.b nRst, nD6, $0F, nRst, $03, nB5, $18, nRst
	dc.b $06, nCs6, $06, nRst, nCs6, nRst, nCs6, nRst
	dc.b nA5, nRst, nG5, $0F, nRst, $03, nB5, $18
	dc.b nRst, $06
	sLoop		$00, $02, Credits_Call8
	sRet

Credits_FM2:
	dc.b nRst, $60
	sVoice		$1D

Credits_Loop1:
	dc.b nD3, $0C, nD3, nB3, nB3, nG3, nG3, nA3
	dc.b nA3, nD3, nD3, nA3, nA3, nFs3, nFs3, nG3
	dc.b nG3, nC3, nC3, nG3, nG3, nFs3, nFs3, nG3
	dc.b nG3, nA2, nA2, nA2, nA2, nD3, nD3, nD3
	dc.b nE3
	sLoop		$00, $02, Credits_Loop1
	sVoice		$00

Credits_Loop2:
	sNoteTimeOut	$05
	dc.b nF3, $0C
	sCall		Credits_Call10
	sNoteTimeOut	$05
	dc.b nE3, $0C, $0C, $0C, $0C, $0C
	sNoteTimeOut	$00
	dc.b nC3, nD3, nE3
	sLoop		$00, $02, Credits_Loop2
	sNoteTimeOut	$05
	dc.b nF3
	sCall		Credits_Call10
	sNoteTimeOut	$05
	dc.b nE3
	sCall		Credits_Call10
	sNoteTimeOut	$05
	dc.b nD3
	sCall		Credits_Call10
	sNoteTimeOut	$05
	dc.b nC3, $0C, $0C, $0C, $0C, $0C
	sNoteTimeOut	$00
	dc.b nG2, nA2, nB2
	sNoteTimeOut	$05

Credits_Loop3:
	dc.b nC3
	sLoop		$00, $18, Credits_Loop3
	sNoteTimeOut	$00
	dc.b nC3, $06, nRst, nC3, $0C, nA2, $06, nRst
	dc.b nA2, $0C, nBb2, $06, nRst, nBb2, $0C, nB2
	dc.b $06, nRst, nB2, $0C
	sVoice		$06
	saTranspose	$E8
	saVol		$02

Credits_Loop4:
	dc.b nC4, $0F, nRst, $03, nE4, nRst, nG4, $09
	dc.b nRst, $03, nA4, $09, nRst, $03, nB4, $0F
	dc.b nRst, $03, nA4, nRst, nG4, $09, nRst, $03
	dc.b nE4, $09, nRst, $03
	saTranspose	$05
	sLoop		$00, $02, Credits_Loop4
	saTranspose	$F6
	dc.b nC4, $0F, nRst, $03, nE4, nRst, nG4, $09
	dc.b nRst, $03, nE4, $09, nRst, $03, nC4, $06
	dc.b nRst, $12, nE4, $18
	saVol		$01
	sVoice		$09

Credits_Loop5:
	dc.b nA3, $03, nRst, nA3, $06, nE4, $03, nRst
	dc.b nE4, $06, nD4, $03, nRst, nD4, $06, nE4
	dc.b $03, nRst, nE4, $06
	sLoop		$00, $02, Credits_Loop5

Credits_Loop6:
	dc.b nD4, $03, nRst, nD4, $06, nA4, $03, nRst
	dc.b nA4, $06, nF4, $03, nRst, nF4, $06, nA4
	dc.b $03, nRst, nA4, $06
	sLoop		$00, $02, Credits_Loop6
	dc.b nB3, $03, nRst, nB3, $06, nF4, $03, nRst
	dc.b nF4, $06, nD4, $03, nRst, nD4, $06, nF4
	dc.b $03, nRst, nF4, $06, nE4, $03, nRst, nE4
	dc.b $06, nB4, $03, nRst, nB4, $06, nAb4, $03
	dc.b nRst, nAb4, $06, nB4, $03, nRst, nB4, $06
	dc.b nA3, $03, nRst, nA3, $06, nE4, $03, nRst
	dc.b nE4, $06, nC4, $03, nRst, nC4, $06, nE4
	dc.b $03, nRst, nE4, $06, nA3, $03, nRst, $09
	dc.b nRst, $24
	saVol		$F8
	dc.b nC4, $06, nRst, $03, nC4, nRst, $06, nC4
	dc.b $12, nRst, $06, nC4, $02, nRst, $01, nC4
	dc.b $02, nRst, $01, nBb3, $06, nRst, $03, nBb3
	dc.b $03, nRst, $06, nA3, $12, nRst, $06, nA3
	dc.b $02, nRst, $01, nA3, $02, nRst, $01

Credits_Loop7:
	dc.b nD4, $06, nRst, $03, nD4, $06, nRst, $03
	dc.b nD4, $02, nRst, $01, nD4, $02, nRst, $01
	saTranspose	$FF
	sLoop		$00, $04, Credits_Loop7
	saTranspose	$04
	dc.b nG3, $06, nRst, $03, nG3, nRst, $06, nG3
	dc.b $12, nRst, $06, nG3, $02, nRst, $01, nG3
	dc.b $02, nRst, $01, nB3, $06, nRst, $03, nB3
	dc.b nRst, $06, nB3, $12, nRst, $06, nD4, $02
	dc.b nRst, $01, nB3, $02, nRst, $01, nC4, $06
	dc.b nRst, $03, nC4, nRst, $06, nC4, $12, nRst
	dc.b $06, nE4, $02, nRst, $01, nF4, $02, nRst
	dc.b $01, nG4, $06, nRst, nG3, $24
	sVoice		$10
	saTranspose	$0C
	saVol		$07
	sNoteTimeOut	$06

Credits_Loop8:
	sCall		Credits_Call11
	saTranspose	$06
	sCall		Credits_Call11
	saTranspose	$FF
	sCall		Credits_Call11
	saTranspose	$02
	sCall		Credits_Call11
	saTranspose	$F9
	sLoop		$02, $02, Credits_Loop8
	sNoteTimeOut	$00
	saTranspose	$F4
	saVol		$FC
	sVoice		$14
	dc.b nRst, $30, nRst, $30, nA4, $03, nRst, nA4
	dc.b nRst, nG4, nRst, nG4, nRst, nF4, nRst, nF4
	dc.b nRst, nE4, nRst, nE4, $02, nRst, nBb4
	saVol		$02
	dc.b nRst, $04, nBb4, $08, nC5, $03, nRst, nBb4
	dc.b nRst, nA4, $06, nRst, nBb4, $04, nA4, nRst
	dc.b $02, nG4, nRst, $04, nG4, $08, nA4, $03
	dc.b nRst, nG4, nRst, nF4, nRst, nF4, nRst, nG4
	dc.b $04, nF4, nRst, $02, nE4, nRst, $04, nE4
	dc.b $08, nE4, $03, nRst, nE4, nRst, nA4, $09
	dc.b nRst, $03, nA4, $0A, nD4, $02
	saTranspose	$0C
	saVol		$FE
	sVoice		$19
	dc.b nRst, $60

Credits_Loop9:
	dc.b nA3, $06, nRst, nA3, nRst, nE3, nRst, nE3
	dc.b nRst, nG3, $12, nFs3, $0C, nG3, $06, nFs3
	dc.b $0C, nA3, $06, nRst, nA3, nRst, nE3, nRst
	dc.b nE3, nRst, nD4, $12, nCs4, $0C, nD4, $06
	dc.b nCs4, $0C
	sLoop		$00, $02, Credits_Loop9
	dc.b nG3, $06, nRst, nE3, nRst, nF3, nRst, nFs3
	dc.b nRst, nG3, $06, nG3, $06, nE3, $06, nRst
	dc.b nF3, nRst, nG3, nRst, nE3, $06, nRst, nE3
	dc.b nRst, nAb3, nRst, nAb3, nRst, nB3, $06, nRst
	dc.b nB3, nRst, nD4, nRst, nD4, nRst, nRst, $0C
	dc.b nA3, $12, nRst, $06, nA3, $12, nAb3, $12
	dc.b nA3, $06, nRst
	saVol		$FD
	dc.b nA2, $6C, sHold, $60
	sStop
	dc.b $00, $01	; Unused

Credits_Call10:
	dc.b $0C, $0C, $0C, $0C, $0C, $0C
	sNoteTimeOut	$00
	dc.b $0C
	sRet

Credits_Call11:
	dc.b nC4, $03, nC4, nG3, nG3, nA3, nA3, nG3
	dc.b nG3
	sLoop		$00, $02, Credits_Call11
	sRet

Credits_FM3:
	dc.b nRst, $60
	sLoop		$00, $08, Credits_FM3
	sVoice		$1F
	saVol		$01
	sPan		spRight, $00
	dc.b nD6, $06, nE6, nFs6, nG6, nE6, nFs6, nG6
	dc.b nA6, nFs6, nG6, nA6, nB6, nA6, nB6, nC7
	dc.b nD7

Credits_Loop10:
	sPan		spLeft, $00
	dc.b nE7
	sPan		spRight, $00
	dc.b nC7
	saVol		$02
	sLoop		$00, $0D, Credits_Loop10
	sPan		spCenter, $00
	sVoice		$02
	saVol		$E5
	saTranspose	$E8
	dc.b nG6, $06, nA6, nC7, $0C, nA6, nRst, $4E
	dc.b nRst, nG6, $06, nA6, nC7, $0C, nE7, nRst
	dc.b $4E, nRst, nG6, $06, nA6, nC7, $0C, nA6
	dc.b nRst, $36, nRst, nC7, $06, nRst, $12, nA6
	dc.b $18, nG6, $06, nRst, nA6, nRst, nC7, nRst
	sModOff
	sVoice		$04
	saVol		$FE

Credits_Loop11:
	dc.b nC6, $01, sHold, nB5, $1B, nRst, $08, nBb5
	dc.b $01, sHold, nA5, $1B, nRst, $08
	sLoop		$00, $02, Credits_Loop11
	dc.b nC6, $01, sHold, nB5, $0B, nRst, $0C, nBb5
	dc.b $01, sHold, nA5, $0B, nRst, $0C, nCs6, $01
	dc.b sHold, nC6, $1B, nRst, $08, nC6, $01, sHold
	dc.b nB5, $24, sHold, $18, sHold, $5A, nRst, $06
	saTranspose	$18
	dc.b nRst, $60, nRst, nRst, $30
	saTranspose	$E8
	sVoice		$08
	saTranspose	$0C
	saVol		$03
	ssDetune	$02
	dc.b nRst, $18, nA5, $06, nB5, nC6, nE6
	sCall		Credits_Call4
	sVoice		$0D
	saTranspose	$0C
	saVol		$0B
	dc.b nRst, $0C, nG5, nA5, nG6
	sCall		Credits_Call5
	sVoice		$0A
	saVol		$EC
	dc.b nRst, $06
	ssDetune	$14
	dc.b nG5, $01, sHold
	ssDetune	$00
	dc.b $02, nA5, $03
	sNoteTimeOut	$05
	dc.b nC6, $03, nC6, $06, nA5, $03, nC6
	sNoteTimeOut	$00
	dc.b nC6
	saVol		$FC
	saTranspose	$33
	sVoice		$0E
	dc.b nEb4, $03
	saVol		$07
	dc.b nEb4
	saVol		$07
	dc.b nEb4
	saVol		$07
	dc.b nEb4
	sVoice		$0A
	saVol		$EF
	saTranspose	$CD
	dc.b nE6, $03, nF6, nG6, nRst, $09
	ssDetune	$EC
	dc.b nC7, $01, sHold
	ssDetune	$00
	ssMod68k	$2C, $01, $04, $04
	dc.b nC7, $23
	sModOff
	sVoice		$0F
	saVol		$FF
	ssDetune	$03
	sCall		Credits_Call6
	ssDetune	$00
	sVoice		$15
	saVol		$09
	dc.b nRst, $30, nRst, $30, nRst, $2E, nF5, $02
	dc.b nRst, $04, nF5, $08, nF5, $03, nRst, nF5
	dc.b nRst, nE5, $03, nRst, $13, nD5, $02, nRst
	dc.b $04, nD5, $08, nD5, $03, nRst, nD5, nRst
	dc.b nC5, $03, nRst, $15, nRst, $04, nA6, $08
	dc.b nG6, $03, nRst, nG6, nRst, nF6, nRst, nF6
	dc.b nRst, nE6, $04, nF6, $02, nE6, $04, nD6
	dc.b $02
	sVoice		$0A
	saVol		$F9
	dc.b nRst, $60

Credits_Loop12:
	dc.b nE6, $06, nRst, nE6, nRst, nCs6, nRst, nCs6
	dc.b nRst, nD6, $12, nD6, $1E, nE6, $06, nRst
	dc.b nE6, nRst, nCs6, nRst, nCs6, nRst, nG6, $12
	dc.b nG6, $1E
	sLoop		$00, $02, Credits_Loop12
	dc.b nRst, $0C, nD6, $12, nRst, $06, nD6, nRst
	dc.b nCs6, $12, nD6, nCs6, $0C, nAb5, $18, nB5
	dc.b nD6, nAb6, nRst, $0C, nE6, nRst, nE6, $12
	dc.b nEb6, nE6, $06, nRst
	sVoice		$19
	saVol		$F8
	ssDetune	$03
	dc.b nA2, $6C, sHold, $60
	sStop

Credits_Call25:
	dc.b nD6, $06, nE6, nFs6, nG6, nE6, nFs6, nG6
	dc.b nA6, nFs6, nG6, nA6, nB6, nA6, nB6, nC7
	dc.b nD7
	sRet

Credits_FM4:
	sVoice		$20
	dc.b nRst, $60
	saVol		$08
	sCall		Credits_Call12
	dc.b nFs5, $0C, nFs5, nRst, nRst, nA5, nA5, nRst
	dc.b nRst
	sCall		Credits_Call12
	dc.b nA5, $24, $24, $18
	sPan		spLeft, $00
	sCall		Credits_Call13
	saVol		$F2

Credits_Loop14:
	dc.b nAb5, $01, sHold, nG5, $1B, nRst, $08, nFs5
	dc.b $01, sHold, nF5, $1B, nRst, $08
	sLoop		$00, $02, Credits_Loop14
	dc.b nAb5, $01, sHold, nG5, $0B, nRst, $0C, nFs5
	dc.b $01, sHold, nF5, $0B, nRst, $0C, nBb5, $01
	dc.b sHold, nA5, $1B, nRst, $08, nAb5, $01, sHold
	dc.b nG5, $24, sHold, $18, sHold, $5A, nRst, $06
	saTranspose	$18
	dc.b nRst, $60, nRst, nRst, $5A
	sPan		spCenter, $00
	sVoice		$0A
	saTranspose	$F4
	saVol		$05

Credits_Loop15:
	dc.b nB6, $09, nRst, $03, nB6, nRst, nC7, $06
	dc.b nRst, nB6, $0C, nRst, $06
	sLoop		$00, $02, Credits_Loop15
	dc.b nRst, $12, nC7, $03, nRst, $0F, nC7, $03
	dc.b nRst, $1B, nC7, $03, nRst, $0F, nC7, $03
	dc.b nRst, $09, nF6, $09, nRst, $03, nF6, nRst
	dc.b nA6, $06, nRst, nF6, $0C, nRst, $06, nAb6
	dc.b $09, nRst, $03, nAb6, nRst, nB6, $06, nRst
	dc.b nAb6, $0C, nRst, $06, nRst, nRst, $0C, nC7
	dc.b $03, nRst, $0F, nC7, $03, nRst, $0F, nC7
	dc.b $03, nRst, $2D
	saTranspose	$F4
	saVol		$03
	sVoice		$0C
	sPan		spLeft, $00
	sCall		Credits_Call15
	sVoice		$11
	saVol		$F6
	saTranspose	$18
	sCall		Credits_Call16
	dc.b nRst, $0C
	ssDetune	$EC
	dc.b nA5, $02
	ssDetune	$00
	dc.b sHold, $0A, nRst, $03, nA5, nRst, nRst, nA5
	dc.b nRst, $09
	sCall		Credits_Call16
	ssDetune	$EC
	dc.b nA5, $02
	ssDetune	$00
	dc.b $0A, nRst, $06
	ssMod68k	$18, $01, $07, $04
	ssDetune	$E2
	dc.b nA5, $02, sHold
	ssDetune	$00
	dc.b $1C
	ssDetune	$00
	ssDetune	$03
	sCall		Credits_Call17
	ssDetune	$00
	sPan		spCenter, $00
	sVoice		$0A
	saVol		$F5
	dc.b nRst, $60

Credits_Loop16:
	dc.b nCs6, $06, nRst, nCs6, nRst, nA5, nRst, nA5
	dc.b nRst, nB5, $12, nB5, $1E, nCs6, $06, nRst
	dc.b nCs6, nRst, nA5, nRst, nA5, nRst, nD6, $12
	dc.b nD6, $1E
	sLoop		$00, $02, Credits_Loop16
	sVoice		$18
	ssDetune	$03
	saVol		$08
	sCall		Credits_Call9
	sVoice		$19
	saVol		$F0
	ssMod68k	$00, $01, $06, $04
	dc.b nA2, $6C, sHold, $60
	sStop

Credits_Call12:
	dc.b nB5, $24, $24, $18, nA5, $24, $24, $18
	dc.b nG5, $24, $24, $18
	sRet

Credits_Call13:
	sVoice		$02
	saTranspose	$E8
	saVol		$0D

Credits_Loop13:
	sCall		Credits_Call14
	dc.b nD5, nD5
	sLoop		$00, $02, Credits_Loop13
	sCall		Credits_Call14
	dc.b nE4, nE4, nC5, nC5, nA4, nA4, nF4, nF4
	dc.b nD4, nD4, nB4, nB4
	saVol		$03
	saTranspose	$0C
	sVoice		$01
	dc.b nG6, $18, nA6, nB6
	saTranspose	$F4
	sVoice		$04
	sRet

Credits_Call14:
	dc.b nE5, $0C, nE5, nC5, nC5, nA4, nA4, nF4
	dc.b nF4, nD5, nD5, nB4, nB4, nG4, nG4
	sRet

Credits_Call16:
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
	sRet

Credits_Call17:
	saVol		$08
	sVoice		$16
	dc.b nRst, $30, nRst, $30
	ssTickMulCh	$01
	sCall		Credits_Call18
	ssTickMulCh	$02
	sVoice		$12
	ssMod68k	$01, $01, $01, $04
	dc.b nD6, $02, nRst, $04, nD6, $08, nD6, $03
	dc.b nRst, nD6, nRst, nC6, nRst, nA6, nRst, nF6
	dc.b nRst, $07, nBb5, $02, nRst, $04, nBb5, $08
	dc.b nBb5, $03, nRst, nBb5, nRst, nA5, $03, nRst
	dc.b $13, nA5, $0E, nCs6, $0C, nE6, nCs7, $0A
	dc.b nD7, $02
	sRet

Credits_Call18:
	dc.b nBb3, $01, sHold, nA3, $04, nRst, $07, nBb3
	dc.b $01, sHold, nA3, $04, nRst, $07, nC4, $01
	dc.b sHold, nB3, $04, nRst, $07, nC4, $01, sHold
	dc.b nB3, $04, nRst, $07

Credits_Call18y:
	dc.b nCs4, $01, sHold, nC4
	dc.b $04, nRst, $07, nCs4, $01, sHold, nC4, $04
	dc.b nRst, $07, nD4, $01, sHold, nCs4, $04, nRst
	dc.b $07, nD4, $01, sHold, nCs4, $04, nRst, $03
	sRet

; fuck yeah, nice crap here
Credits_Call18x:
	ssDetune	$44	; damn borked notes >_>
	dc.b nC4, $01, sHold
	ssDetune	$00	; damn borked notes >_>
	dc.b nG6, $04, nRst, $07
	ssDetune	$44	; damn borked notes >_>
	dc.b nC4, $01, sHold
	ssDetune	$00	; damn borked notes >_>
	dc.b nG6, $04, nRst, $07
	dc.b nC4, $01, sHold, nAb4, $04, nRst, $07
	dc.b nC4, $01, sHold, nAb4, $04, nRst, $07
	sJump		Credits_Call18y

Credits_Call9:
	dc.b nRst, $0C, nG6, nB6, nD7, nFs7, nRst, $06
	dc.b nFs7, $0C, nG7, $06, nFs7, $0C, nAb7, $54
	dc.b nRst, $0C, nA7, nRst, nA7, nRst, $12, nAb7
	dc.b nA7, $0C
	sRet

Credits_FM5:
	sVoice		$20
	dc.b nRst, $60
	saVol		$F0
	sCall		Credits_Call19
	dc.b nD5, $0C, $0C, nRst, $18, nFs5, $0C, $0C
	dc.b nRst, $18
	sCall		Credits_Call19
	dc.b nFs5, $24, $24, $18
	sPan		spRight, $00
	sCall		Credits_Call13
	saVol		$F2

Credits_Loop17:
	dc.b nF5, $01, sHold, nE5, $1B, nRst, $08, nEb5
	dc.b $01, sHold, nD5, $1B, nRst, $08
	sLoop		$00, $02, Credits_Loop17
	dc.b nF5, $01, sHold, nE5, $0B, nRst, $0C, nEb5
	dc.b $01, sHold, nD5, $0B, nRst, $0C, nFs5, $01
	dc.b sHold, nF5, $1B, nRst, $08, nF5, $01, sHold
	dc.b nE5, $24, sHold, $18, sHold, $5A, nRst, $06
	saTranspose	$18
	sPan		spCenter, $00
	saVol		$03
	saTranspose	$0C
	sVoice		$07
	dc.b nRst, $4E, nG4, $03, nA4, nC5, nRst, nA4
	dc.b nRst, $51, nA5, $03, nF5, nC5, nRst, nF5
	dc.b nRst, $5D
	sVoice		$0A
	saTranspose	$E8
	saVol		$02

Credits_Loop18:
	dc.b nG6, $09, nRst, $03, nG6, nRst, nA6, $06
	dc.b nRst, nG6, $0C, nRst, $06
	sLoop		$00, $02, Credits_Loop18
	dc.b nRst, $12, nA6, $03, nRst, $0F, nA6, $03
	dc.b nRst, $1B, nA6, $03, nRst, $0F, nA6, $03
	dc.b nRst, $09, nD6, $09, nRst, $03, nD6, nRst
	dc.b nF6, $06, nRst, nD6, $0C, nRst, $06, nE6
	dc.b $09, nRst, $03, nE6, nRst, nAb6, $06, nRst
	dc.b nE6, $0C, nRst, $18, nA6, $03, nRst, $0F
	dc.b nA6, $03, nRst, $0F, nA6, $03, nRst, $2D
	sVoice		$0C
	sPan		spRight, $00
	saTranspose	$F4
	saVol		$03
	sCall		Credits_Call20
	sVoice		$12
	saTranspose	$24
	saVol		$F4
	sCall		Credits_Call22
	dc.b nE6, nF6, nG6
	sCall		Credits_Call22
	dc.b nG6, nF6, nE6
	saTranspose	$F4
	sCall		Credits_Call17
	sPan		spCenter, $00
	sVoice		$1A
	ssDetune	$03
	saVol		$F8
	dc.b nRst, $60
	sCall		Credits_Call8
	saVol		$00
	sVoice		$1A
	dc.b nRst, $60, nRst, $0C, nE6, $06, nRst, nB6
	dc.b nE6, $06, nRst, $0C, nE6, $06, nRst, nB6
	dc.b nE6, $06, nRst, $18
	saVol		$05
	dc.b nRst, $0C, nA3, nRst, nA3
	sStop

Credits_Call19:
	dc.b nG5, $24, $24, $18, nFs5, $24, $24, $18
	dc.b nE5, $24, $24, $18
	sRet

Credits_PSG1:
	dc.b nRst, $60
	sVolEnv		v08
	saVol		$18
	sNoteTimeOut	$06
	sCall		Credits_Call1
	sVolEnv		v01
	sNoteTimeOut	$00
	saVol		-$18

Credits_Loop20:
	dc.b nRst, $18, nC6, $06, nRst, $1E, nC6, $0C
	dc.b nRst, $18, nRst, $18, nB5, $06, nRst, $1E
	dc.b nB5, $0C, nRst, $18
	sLoop		$00, $03, Credits_Loop20
	dc.b nRst, $18, nA5, $06, nRst, $1E, nA5, $0C
	dc.b nRst, $18, nRst, $18, nG5, $06, nRst, $1E
	dc.b nG5, $0C, nRst, $18
	sVolEnv		v05
	ssMod68k	$0E, $01, $01, $03
	sNoteTimeOut	$10
	dc.b nE5, $24, nD5, nE5, nD5, nE5, $0C, nRst
	dc.b nD5, nRst, nF5, $24
	sNoteTimeOut	$00
	dc.b nE5, $60, sHold, $3C
	sModOff
	sVolEnv		v09
	saVol		$08

Credits_Loop21:
	dc.b nRst, $06, nE6, $0C, nE6, nE6, nE6, $06
	dc.b nRst, nE6, $0C, nE6, nE6, $03, $09, $06
	saTranspose	$05
	sLoop		$00, $02, Credits_Loop21
	saTranspose	$F6
	dc.b nRst, $06, nE6, $0C, nE6, nE6, nE6, $06
	dc.b nRst, $30
	sVolEnv		v08
	saVol		$08
	sCall		Credits_Call23
	dc.b nRst, $02, nRst, $30
	saVol		$18
	saTranspose	$F4
	sVolEnv		v05
	sCall		Credits_Call15
	saTranspose	$0C
	saVol		-$20
	sVolEnv		v00
	sCall		Credits_Call24
	dc.b nRst, $0C, nF5, nRst, $03, nF5, nRst, nRst
	dc.b nF5, nRst, $09
	sCall		Credits_Call24
	dc.b nF5, $0C, nRst, $06, nF5, $1E
	sVolEnv		v06
	saVol		$20
	dc.b nRst, $30, nRst, $30
	ssTickMulCh	$01
	sCall		Credits_Call18x
	ssTickMulCh	$02
	dc.b nD6, $02, nRst, $04, nD6, $08, nD6, $03
	dc.b nRst, nD6, nRst, nC6, nRst, nA6, nRst, nF6
	dc.b nRst, $07, nBb5, $02, nRst, $04, nBb5, $08
	dc.b nBb5, $03, nRst, nBb5, nRst, nA5, $03, nRst
	dc.b $13, nA5, $0E, nCs6, $0C, nE6, nCs7, $0A
	dc.b nD7, $02, nRst, $60, nRst, nRst, nRst, nRst
	saVol		-$08
	dc.b nRst, $0C, nB5, $12, nRst, $06, nB5, nRst
	dc.b nA5, $12, nB5, nA5, $0C, nE5, $18, nAb5
	dc.b nB5, nD6, nRst, $0C, nCs6, nRst, nCs6, $12
	dc.b nC6, nCs6, $06
	sStop

Credits_Call24:
	dc.b nRst, $0C, nE5, $07, nRst, $02, nE5, $03
	dc.b nRst, $18, nRst, $0C, nBb5, $07, nRst, $02
	dc.b nBb5, $03, nRst, $18, nRst, $0C, nA5, $07
	dc.b nRst, $02, nA5, $03, nRst, $18
	sRet

Credits_PSG2:
	dc.b nRst, $60
	sLoop		$00, $08, Credits_PSG2
	dc.b nRst, $02
	sCall		Credits_Call25
	saVol		-$10
	sVolEnv		v01
	dc.b nRst, $16, nE6, $06, nRst, $1E, nE6, $0C
	dc.b nRst, $18, nRst, $18, nD6, $06, nRst, $1E
	dc.b nD6, $0C, nRst, $18

Credits_Loop22:
	dc.b nRst, $18, nE6, $06, nRst, $1E, nE6, $0C
	dc.b nRst, $18, nRst, $18, nD6, $06, nRst, $1E
	dc.b nD6, $0C, nRst, $18
	sLoop		$00, $02, Credits_Loop22
	dc.b nRst, $18, nC6, $06, nRst, $1E, nC6, $0C
	dc.b nRst, $18, nRst, $18, nB5, $06, nRst, $1E
	dc.b nB5, $0C, nRst, $18
	sNoteTimeOut	$06
	sVolEnv		v06

Credits_Loop23:
	dc.b nC7, $0C, nB6, nA6, nG6
	sLoop		$00, $08, Credits_Loop23
	sNoteTimeOut	$00
	sVolEnv		v09
	saVol		$09

Credits_Loop24:
	dc.b nRst, $06, nG6, $0C, nG6, nG6, nG6, $06
	dc.b nRst, nG6, $0C, nG6, nG6, $03, $09, $06
	saTranspose	$05
	sLoop		$00, $02, Credits_Loop24
	saTranspose	$F6
	dc.b nRst, $06, nG6, $0C, nG6, nG6, nG6, $06
	dc.b nRst, $30, nRst, $02
	ssDetune	$01
	saVol		$18
	sCall		Credits_Call23
	ssDetune	$00
	dc.b nRst, $30
	saVol		$08
	saTranspose	$F4
	sVolEnv		v05
	sCall		Credits_Call20
	saTranspose	$0C
	saVol		-$18
	sNoteTimeOut	$03

Credits_Loop25:
	dc.b nC7, $03, nC7, nG7, nC7, nF7, nC7, nE7
	dc.b nC7
	sLoop		$00, $02, Credits_Loop25

Credits_Loop26:
	dc.b nBb6, nBb6, nF7, nBb6, nEb7, nBb6, nCs7, nBb6
	sLoop		$00, $02, Credits_Loop26

Credits_Loop27:
	dc.b nA6, nA6, nE7, nA6, nD7, nA6, nC7, nA6
	sLoop		$00, $04, Credits_Loop27
	sLoop		$01, $02, Credits_Loop25
	dc.b nRst, $60, nRst, nRst, nRst, nRst, nRst, nRst
	dc.b nRst, nRst
	saVol		$60
	ssDetune	$02
	saVol		$10
	dc.b nRst, $0C, nE6, $06, nRst, nB6, nE6, $06
	dc.b nRst, $0C, nE6, $06, nRst, nB6, nE6
	sStop

Credits_PSG3:
	sNoisePSG	$E7
	sNoteTimeOut	$04

Credits_Loop28:
	dc.b nA5, $0C
	sLoop		$00, $48, Credits_Loop28
	sNoteTimeOut	$06

Credits_Loop29:
	dc.b $0C
	sLoop		$00, $60, Credits_Loop29
	saVol		-$08
	sCall		Credits_Call26
	sNoteTimeOut	$0E
	dc.b $0C
	sNoteTimeOut	$03
	dc.b $06, $06, $03, $03, $06, $03, $03, $06

Credits_Loop30:
	sCall		Credits_Call26
	sLoop		$00, $04, Credits_Loop30
	sVolEnv		v09
	saVol		$08
	saTranspose	$0B

Credits_Loop31:
	dc.b nA3, $06, nA3, nE4, nE4, nD4, nD4, nE4
	dc.b nE4
	sLoop		$00, $02, Credits_Loop31

Credits_Loop32:
	dc.b nD4, nD4, nA4, nA4, nF4, nF4, nA4, nA4
	sLoop		$00, $02, Credits_Loop32
	dc.b nB3, nB3, nF4, nF4, nD4, nD4, nF4, nF4
	dc.b nE4, nE4, nG3, nG3, nAb4, nAb4, nG3, nG3
	dc.b nA3, nA3, nE4, nE4, nC4, nC4, nE4, nE4
	dc.b nA3, $06, nRst, $1E
	sNoteTimeOut	$02
	saTranspose	$F5

Credits_Loop33:
	sVolEnv		v04
	dc.b nA5, $03, $03
	saVol		$10
	sVolEnv		v08
	sNoteTimeOut	$08
	dc.b $06
	sNoteTimeOut	$03
	saVol		-$10
	sLoop		$00, $1E, Credits_Loop33
	dc.b nRst, $24

Credits_Loop34:
	sVolEnv		v04
	dc.b $03, $03
	saVol		$10
	sVolEnv		v08
	sNoteTimeOut	$08
	dc.b $06
	sNoteTimeOut	$03
	saVol		-$10
	sLoop		$00, $20, Credits_Loop34
	dc.b nRst, $30
	sNoteTimeOut	$01
	sVolEnv		v04
	saVol		$18

Credits_Loop35:
	dc.b nA5, $02, nRst, nA5
	sLoop		$00, $08, Credits_Loop35

Credits_Loop36:
	dc.b nRst, $04, nA5, $02
	sLoop		$00, $08, Credits_Loop36
	saVol		-$08

Credits_Loop37:
	dc.b nA5, $02, nRst, nA5
	sLoop		$00, $18, Credits_Loop37
	saVol		-$10

Credits_Loop38:
	dc.b nA5, $04, nRst, nA5
	sLoop		$00, $08, Credits_Loop38

Credits_Loop39:
	sNoteTimeOut	$03
	dc.b $0C
	sNoteTimeOut	$0C
	dc.b $0C
	sNoteTimeOut	$03
	dc.b $0C
	sNoteTimeOut	$0C
	dc.b $0C
	sLoop		$00, $0D, Credits_Loop39
	sNoteTimeOut	$03
	dc.b $06
	sNoteTimeOut	$0E
	dc.b $12
	sNoteTimeOut	$03
	dc.b $0C
	sNoteTimeOut	$0F
	dc.b $0C
	sStop

Credits_DAC1:
	dc.b dSnare, $06, dSnare, dSnare, dSnare, dSnare, $0C, $06
	dc.b $0C, $06, $0C, $0C, $0C
	sCall		Credits_Call27
	dc.b dKick, $18, dSnare, $0C, dSnare, dKick, $18, dSnare
	dc.b $0C, dSnare
	sCall		Credits_Call27
	dc.b dKick, $0C, dSnare, dSnare, dSnare, dSnare, dSnare, dSnare
	dc.b dSnare

Credits_Loop40:
	dc.b dKick, $18, dSnare, $0C, dKick, $18, $0C, dSnare
	dc.b $18
	sLoop		$00, $07, Credits_Loop40
	dc.b dKick, $18, dSnare, $0C, dKick, $18, dSnare, $0C
	dc.b $0C, $0C

Credits_Loop41:
	dc.b dKick, $18, dSnare, $0C, dKick, $18, $0C, dSnare
	dc.b $18
	sLoop		$00, $03, Credits_Loop41
	dc.b dKick, $18, dSnare, $0C, dKick, $18, dSnare, $0C
	dc.b dSnare, dSnare
	ssTickMul	$02

Credits_Loop42:
	dc.b dKick, $12, dKick, $06, dKick, $0C, dSnare
	sLoop		$00, $05, Credits_Loop42
	dc.b dKick, $12, dKick, $06, dKick, $06, dSnare, dSnare
	dc.b dSnare

Credits_Loop43:
	dc.b dKick, $0C
	sLoop		$00, $18, Credits_Loop43
	dc.b dKick, $0C, dKick, dKick, dKick, $06, dKick, $02
	dc.b dKick, dSnare, dSnare, $0C, nRst, $24

Credits_Loop44:
	dc.b dKick, $0C, dKick, dKick, dKick
	sLoop		$00, $07, Credits_Loop44
	dc.b dKick, $0C, dKick, dSnare, $03, dSnare, dSnare, dSnare
	dc.b dSnare, dSnare, dSnare, dSnare
	sCall		Credits_Call28
	dc.b dHiTimpani, $02, dKick, $01, dMidTimpani, $05, dSnare, $01
	dc.b dHiTimpani, $05, dMidTimpani, $06
	sCall		Credits_Call28
	dc.b dMidTimpani, $02, dSnare, $01, dHiTimpani, $05, dSnare, $01
	dc.b dMidTimpani, $05, dSnare, $01, dHiTimpani, $02, dSnare, $03
	dc.b dSnare, $03, dSnare, dKick, dKick, dSnare, dSnare, dKick
	dc.b dKick, dKick, dSnare, $09, dSnare, $06, $03, $03
	dc.b dKick, $09, $03, dSnare, $09, dKick, $06, $06
	dc.b $03, dSnare, $06, $03, $03, dSnare, $06, dSnare
	dc.b dSnare, dSnare, dSnare, dSnare, dSnare, $04, $02, $04
	dc.b dKick, $02

Credits_Loop45:
	dc.b nRst, $04, dKick, $08, dSnare, $06, dKick, dKick
	dc.b $0C, dSnare, $0A, dKick, $02
	sLoop		$00, $03, Credits_Loop45
	ssTickMul	$01
	dc.b nRst, $18, dSnare, $14, dKick, $04, dSnare, $0C
	dc.b dSnare, dSnare, $0C, $08, dKick, $04

Credits_Loop46:
	dc.b dKick, $0C, dSnare, dKick, dSnare
	sLoop		$01, $03, Credits_Loop46
	dc.b dKick, $0C, dSnare, dKick, $06, nRst, $02, dSnare
	dc.b dSnare, dSnare, $09, dSnare, $03
	sLoop		$00, $03, Credits_Loop46
	dc.b dKick, $0C, dSnare, dKick, dSnare, dKick, $06, dSnare
	dc.b $12, dSnare, $0C, dKick
	sStop

Credits_Call27:
	dc.b dKick, $18, dSnare, $0C, dKick, $18, dKick, $0C
	dc.b dSnare, dKick
	sLoop		$00, $03, Credits_Call27
	sRet

Credits_Call28:
	dc.b dKick, $0C, dSnare, $09, dKick, $06, $03, dKick
	dc.b $01, dHiTimpani, $02, dMidTimpani, $03, dSnare, $01, dHiTimpani
	dc.b $0B, dKick, $0C, dSnare, $09, dKick, $06, $03
	dc.b dKick, $01, dHiTimpani, $02, dMidTimpani, $03, dSnare, $01
	dc.b dHiTimpani, $0B, dKick, $0C, dSnare, $09, dKick, $06
	dc.b $03, dKick, $01, dHiTimpani, $02, dMidTimpani, $03, dSnare
	dc.b $01, dHiTimpani, $0B, dKick, $0C, dSnare, $09, dKick
	dc.b $06, dSnare, $01
	sRet

Credits_Call1:
	sCall		Credits_Call2
	dc.b nFs5, nD5, nE5, nFs5, nD5
	sCall		Credits_Call2
	dc.b nB5, nA5, nB5, nC6, nD6
	sRet

Credits_Call2:
	dc.b nB5, $0C, nG5, nB5, nD6, nC6, nB5, nA5
	dc.b nB5, nA5, nFs5, nA5, nC6, nB5, nA5, nG5
	dc.b nA5, nG5, nE5, nG5, nB5, nA5, nG5, nFs5
	dc.b nG5, nFs5, nG5, nA5
	sRet
	dc.b $80, $0C, $D0, $D4, $D7, $DB, $0C, $80	; Unused
	dc.b $06, $DB, $0C, $DC, $06, $DB, $0C, $D9	; Unused
	dc.b $60, $80, $0C, $D0, $D4, $D7, $DB, $0C	; Unused
	dc.b $80, $06, $DB, $0C, $DC, $06, $DB, $0C	; Unused
	dc.b $DD, $5D, $80, $03, $DE, $12, $80, $06	; Unused
	dc.b $DE, $12, $80, $06, $80, $06, $DD, $12	; Unused
	dc.b $DE, $06, $80, $12, $E3	; Unused

Credits_Call26:
	sNoteTimeOut	$0E
	dc.b $0C
	sNoteTimeOut	$03
	dc.b $06, $06, $06, $06, $06, $06
	sRet

Credits_Call4:
	dc.b nB6, $09, nRst, $03, nB6, $06, nA6
	sLoop		$00, $03, Credits_Call4
	dc.b nB6, nA6, nE6, nC6, nG6, $0C, nA6, $06
	dc.b sHold, nF6, $4D, nRst, $01, nA6, $24, nB6
	dc.b $0C, nAb6, $24, nB6, $09, nRst, $03, nB6
	dc.b $12, nA6, $1E
	sRet

Credits_Call23:
	dc.b nRst, $30, nRst, nRst, nF7, $03, nD7, nA6
	dc.b nF6, nD7, nA6, nF6, nD6, nA6, nF6, nD6
	dc.b nA5, nF6, nD6, nA5, nF5, $33, nRst, $5E
	sRet

Credits_Call5:
	dc.b nE6, $2A, nE6, $03, nF6, nG6, $09, nA6
	dc.b nBb6, $06, nA6, $0C, nG6, nF6, $1E, nF6
	dc.b $06, nE6, nF6, $1E, nD6, $0C, nE6, nF6
	dc.b $2A, nD6, $03, nE6, nF6, $09, nG6, nAb6
	dc.b $06, nG6, $0C, nF6
	sRet

Credits_Call20:
	sCall		Credits_Call21
	dc.b nD6, $06, nRst, $03, nD6, nRst, $06, nCs6
	dc.b $18, nRst, $06

Credits_Loop19:
	dc.b nF6, $06, nRst, $03, nE6, $06, nRst, $03
	dc.b nD6, nRst
	sLoop		$00, $02, Credits_Loop19
	dc.b nF6, $06, nRst, $03, nE6, $06, nRst, $03
	dc.b nD6, $18, nRst, $06
	saTranspose	$FE
	sCall		Credits_Call21
	saTranspose	$03
	sCall		Credits_Call21
	saTranspose	$FF
	dc.b nRst, $06
	sNoteTimeOut	$08
	dc.b nG6, $09, $09, $09, $09
	sNoteTimeOut	$05
	dc.b $03, $03
	sNoteTimeOut	$00
	dc.b nRst, $0C, nF6, $24
	sRet

Credits_Call21:
	dc.b nE6, $06, nRst, $03, nE6, nRst, $06, nE6
	dc.b $18, nRst, $06
	sRet

Credits_Call15:
	dc.b nG6, $06, nRst, $03, nG6, nRst, $06, nG6
	dc.b $18, nRst, $06, nF6, $06, nRst, $03, nF6
	dc.b nRst, $06, nE6, $18, nRst, $06, nA6, $06
	dc.b nRst, $03, nG6, $06, nRst, $03, nF6, nRst
	dc.b nA6, $06, nRst, $03, nG6, $06, nRst, $03
	dc.b nF6, nRst, nA6, $06, nRst, $03, nG6, $06
	dc.b nRst, $03, nF6, $18, nRst, $06, nF6, $06
	dc.b nRst, $03, nF6, nRst, $06, nF6, $18, nRst
	dc.b $06, nAb6, $06, nRst, $03, nAb6, nRst, $06
	dc.b nAb6, $18, nRst, $06, nRst, $06
	sNoteTimeOut	$08
	dc.b nB6, $09, $09, $09, $09
	sNoteTimeOut	$05
	dc.b $03, $03
	sNoteTimeOut	$00
	dc.b nRst, $0C, nA6, $24
	sRet

Credits_Call6:
	sCall		Credits_Call7
	dc.b nG6, $12, nA6, $06, nG6, $12, nE6, $0C
	sCall		Credits_Call7
	dc.b nG6, $30, nRst, $06
	sRet

Credits_Call7:
	dc.b nG6, $1E, nE6, $06, nC6, nC7, nBb6, $0C
	dc.b nC7, $06, nBb6, $0C, nG6, $06, nBb6, nA6
	dc.b $24, nE6, $06, nF6
	sRet

Credits_Call22:
	dc.b nRst, $03, nE6, nC6, $06, $06, nG5, nC6
	dc.b $09, nE6, $09, nRst, $06, nRst, $03, nF6
	dc.b nCs6, $06, $06, nBb5, nCs6, $09, nF6, $09
	dc.b nRst, $06, nRst, $03, nE6, nC6, $06, $06
	dc.b nA5, nC6, $09, nE6, $0F, nD6, $0C
	sRet

Credits_DAC2:
	sStop
