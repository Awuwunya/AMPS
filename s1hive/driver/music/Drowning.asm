Drowning_Header:
	sHeaderInit
	sHeaderTempo	$81, $80		; that $8X means that the 50hz "fix" is not applied to this song.
	sHeaderCh	$05, $00
	sHeaderDAC	Drowning_DAC1
	sHeaderDAC	Drowning_DAC2
	sHeaderFM	Drowning_FM1, $0C, $08
	sHeaderFM	Drowning_FM2, $E8, $0E
	sHeaderFM	Drowning_FM3, $F4, $3E
	sHeaderFM	Drowning_FM4, $06, $11
	sHeaderFM	Drowning_FM5, $0C, $19

	; Patch $00
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
	; $2C
	; $52, $58, $34, $34,	$1F, $12, $1F, $12
	; $00, $0A, $00, $0A,	$00, $00, $00, $00
	; $0F, $1F, $0F, $1F,	$15, $82, $14, $82
	spAlgorithm	$04
	spFeedback	$05
	spDetune	$05, $03, $05, $03
	spMultiple	$02, $04, $08, $04
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $12, $12
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$00, $00, $0A, $0A
	spSustainLv	$00, $00, $01, $01
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$15, $14, $02, $02

	; Patch $03
	; $07
	; $34, $31, $54, $51,	$14, $14, $14, $14
	; $00, $00, $00, $00,	$00, $00, $00, $00
	; $0F, $0F, $0F, $0F,	$91, $91, $91, $91
	spAlgorithm	$07
	spFeedback	$00
	spDetune	$03, $05, $03, $05
	spMultiple	$04, $04, $01, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$14, $14, $14, $14
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$00, $00, $00, $00
	spSustainLv	$00, $00, $00, $00
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$11, $11, $11, $11

Drowning_FM1:
	sVoice		$00
	sGate		$05
	sCall		Drowning_Call1
	ssTempo		$55
	ssTempoShoes	$55
	sCall		Drowning_Call1
	ssTempo		$40
	ssTempoShoes	$40
	sCall		Drowning_Call1
	ssTempo		$2A
	ssTempoShoes	$2A
	sCall		Drowning_Call1
	ssTempo		$19
	ssTempoShoes	$19
	sCall		Drowning_Call1
	dc.b nC5, $06
	sStop

Drowning_FM2:
	sVoice		$01

Drowning_Loop1:
	saVol		$FF
	sCall		Drowning_Call2
	sLoop		$00, $0A, Drowning_Loop1
	dc.b nC5, $06
	sStop

Drowning_FM3:
	sVoice		$02
	sJump		Drowning_Fix	; We can not start the tune with sHold, so we gotta fix this

Drowning_Loop2:
	saVol		$FE
	dc.b sHold

Drowning_Fix:
	dc.b nC6, $02, sHold, nCs6, sHold, nC6, sHold
	dc.b nCs6, sHold, nC6, sHold, nCs6, sHold, nC6, sHold
	dc.b nCs6
	sLoop		$00, $1E, Drowning_Loop2
	dc.b nC6, $06
	sStop

Drowning_FM4:
	dc.b nRst, $03
	sVoice		$03
	sGate		$05

Drowning_Loop3:
	sPan		spRight, $00
	dc.b nC4, $06, nC5
	sPan		spCenter, $00
	dc.b nC4, nC5
	sPan		spLeft, $00
	dc.b nCs4, nCs5
	sPan		spCenter, $00
	dc.b nCs4, nCs5
	sLoop		$00, $0A, Drowning_Loop3
	sStop

Drowning_FM5:
	dc.b nRst, $04
	sVoice		$00
	sGate		$05

Drowning_Loop4:
	sPan		spLeft, $00
	dc.b nC4, $06, nC5
	sPan		spLeft, $00
	dc.b nC4, nC5
	sPan		spRight, $00
	dc.b nCs4, nCs5
	sPan		spRight, $00
	dc.b nCs4, nCs5
	sLoop		$00, $0A, Drowning_Loop4
	sStop

Drowning_DAC2:
	sStop

Drowning_DAC1:
	dc.b dSnare, $0C, dSnare, dSnare, dSnare
	sLoop		$00, $0A, Drowning_DAC1
	dc.b dSnare, $06
	sStop

Drowning_Call1:
	dc.b nC4, $06, nC5, nC4, nC5, nCs4, nCs5, nCs4
	dc.b nCs5

Drowning_Call2:
	dc.b nC4, $06, nC5, nC4, nC5, nCs4, nCs5, nCs4
	dc.b nCs5
	sRet
