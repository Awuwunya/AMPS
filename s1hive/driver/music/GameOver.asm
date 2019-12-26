GameOver_Header:
	sHeaderInit
	sHeaderTempo	$02, $0D
	sHeaderCh	$05, $00
	sHeaderDAC	GameOver_DAC1
	sHeaderDAC	GameOver_DAC2
	sHeaderFM	GameOver_FM1, $E8, $0A
	sHeaderFM	GameOver_FM2, $F4, $0F
	sHeaderFM	GameOver_FM3, $F4, $0F
	sHeaderFM	GameOver_FM4, $F4, $0D
	sHeaderFM	GameOver_FM5, $DC, $16

	; Patch $00
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

	; Patch $01
	; $3C
	; $33, $30, $73, $70,	$94, $9F, $96, $9F
	; $12, $00, $14, $0F,	$04, $0A, $04, $0D
	; $2F, $0F, $4F, $2F,	$33, $80, $1A, $80
	spAlgorithm	$04
	spFeedback	$07
	spDetune	$03, $07, $03, $07
	spMultiple	$03, $03, $00, $00
	spRateScale	$02, $02, $02, $02
	spAttackRt	$14, $16, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$12, $14, $00, $0F
	spSustainLv	$02, $04, $00, $02
	spDecayRt	$04, $04, $0A, $0D
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$33, $1A, $00, $00

	; Patch $02
	; $3A
	; $01, $07, $01, $01,	$8E, $8E, $8D, $53
	; $0E, $0E, $0E, $03,	$00, $00, $00, $07
	; $1F, $FF, $1F, $0F,	$1C, $28, $27, $80
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
	spTotalLv	$1C, $27, $28, $00

	; Patch $03
	; $1F
	; $66, $31, $53, $22,	$1C, $98, $1F, $1F
	; $12, $0F, $0F, $0F,	$00, $00, $00, $00
	; $FF, $0F, $0F, $0F,	$8C, $8D, $8A, $8B
	spAlgorithm	$07
	spFeedback	$03
	spDetune	$06, $05, $03, $02
	spMultiple	$06, $03, $01, $02
	spRateScale	$00, $00, $02, $00
	spAttackRt	$1C, $1F, $18, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$12, $0F, $0F, $0F
	spSustainLv	$0F, $00, $00, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$0C, $0A, $0D, $0B

GameOver_FM1:
	dc.b nRst, $0C
	sVoice		$00
	ssMod68k	$20, $01, $04, $05
	dc.b nCs6, $12, nRst, $06, nCs6, nRst
	dc.b nD6, $12, nB5, $1E, nCs6, $06, nRst, nCs6
	dc.b nRst, nCs6, nRst, nA5, nRst, nG5, $12, nB5
	dc.b $0C, nRst, $12, nC6, $04, nRst, nC6, nB5
	dc.b $06, nRst, nBb5, nRst, nA5, nRst
	ssMod68k	$28, $01, $18, $05
	dc.b nAb5, $60
	sStop

GameOver_FM2:
	dc.b nRst, $01
	sVoice		$01
	dc.b nE7, $06, nRst, nE7, nRst, nCs7
	dc.b nRst, nCs7, nRst, nD7, $15, nD7, $1B, nE7
	dc.b $06, nRst, nE7, nRst, nCs7, nRst, nCs7, nRst
	dc.b nG7, $15, nG7, $1B
	sStop

GameOver_FM3:
	sVoice		$01
	dc.b nCs7, $0C, nCs7, nA6, nA6, nB6, $15, nB6
	dc.b $1B, nCs7, $0C, nCs7, nA6, nA6, nD7, $15
	dc.b nD7, $1B
	sStop

GameOver_FM4:
	sVoice		$02
	dc.b nA3, $06, nRst, nA3, nRst, nE3, nRst, nE3
	dc.b nRst, nG3, $15, nFs3, $0C, nG3, $03, nFs3
	dc.b $0C, nA3, $06, nRst, nA3, nRst, nE3, nRst
	dc.b nE3, nRst, nD4, $15, nCs4, $0C, nD4, $03
	dc.b nCs4, $0C, nA3, $04, nRst, nA3, nAb3, $06
	dc.b nRst, nG3, nRst, nFs3, nRst, nFs3, $60
	sStop

GameOver_FM5:
	dc.b nRst, $30
	sVoice		$03
	dc.b nD7, $12, nRst, $03, nD7, $1B
	dc.b nRst, $30, nG7, $12, nRst, $03, nG7, $1B

GameOver_DAC2:
	sStop

GameOver_DAC1:
	dc.b nRst, $18, dKick
	sLoop		$00, $04, GameOver_DAC1
	sStop
