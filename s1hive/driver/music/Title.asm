TitleScreen_Header:
	sHeaderInit
	sHeaderTempo	$01, $33
	sHeaderCh	$05, $03
	sHeaderDAC	TitleScreen_DAC1
	sHeaderDAC	TitleScreen_DAC2
	sHeaderFM	TitleScreen_FM1, $F4, $0C
	sHeaderFM	TitleScreen_FM2, $F4, $09
	sHeaderFM	TitleScreen_FM3, $F4, $0D
	sHeaderFM	TitleScreen_FM4, $F4, $0C
	sHeaderFM	TitleScreen_FM5, $F4, $0E
	sHeaderPSG	TitleScreen_PSG1, $D0, $03, $00, v05
	sHeaderPSG	TitleScreen_PSG1, $DC, $06, $00, v05
	sHeaderPSG	TitleScreen_PSG3, $00, $04, $00, v04

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

TitleScreen_FM5:
	ssDetune	$03

TitleScreen_FM1:
	sVoice		$00
	dc.b nRst, $3C, nCs6, $15, nRst, $03, nCs6, $06
	dc.b nRst, nD6, $0F, nRst, $03, nB5, $18, nRst
	dc.b $06, nCs6, nRst, nCs6, nRst, nCs6, nRst, nA5
	dc.b nRst, nG5, $0F, nRst, $03, nB5, $0C, nRst
	dc.b $12, nA5, $06, nRst, nCs6, nRst, nA6, nRst
	dc.b nE6, $0C, nRst, $06, nAb6, $12, nA6, $06
	dc.b nRst, $72
	sStop

TitleScreen_FM2:
	sVoice		$01
	dc.b nRst, $30, nA3, $06, nRst, nA3, nRst, nE3
	dc.b nRst, nE3, nRst, nG3, $12, nFs3, $0C, nG3
	dc.b $06, nFs3, $0C, nA3, $06, nRst, nA3, nRst
	dc.b nE3, nRst, nE3, nRst, nD4, $12, nCs4, $0C
	dc.b nD4, $06, nCs4, $0C, nRst, nA2, nRst, nA2
	dc.b nRst, $06, nAb3, $12, nA3, $06, nRst, nA2
	dc.b $6C
	sStop

TitleScreen_FM3:
	sVoice		$02
	dc.b nRst, $30, nE6, $06, nRst, nE6, nRst, nCs6
	dc.b nRst, nCs6, nRst, nD6, $0F, nRst, $03, nD6
	dc.b $18, nRst, $06, nE6, nRst, nE6, nRst, nCs6
	dc.b nRst, nCs6, nRst, nG6, $0F, nRst, $03, nG6
	dc.b $18, nRst, $06, nE6, $0C, nRst, nE6, nRst
	dc.b nRst, $06, nEb6, $12, nE6, $0C
	saVol		$FC
	sVoice		$01
	ssDetune	$03
	dc.b nA2, $6C
	sStop

TitleScreen_FM4:
	sVoice		$02
	dc.b nRst, $30, nCs6, $06, nRst, nCs6, nRst, nA5
	dc.b nRst, nA5, nRst, nB5, $0F, nRst, $03, nB5
	dc.b $18, nRst, $06, nCs6, nRst, nCs6, nRst, nA5
	dc.b nRst, nA5, nRst, nD6, $0F, nRst, $03, nD6
	dc.b $18, nRst, $06, nCs6, $0C, nRst, nCs6, nRst
	dc.b nRst, $06, nC6, $12, nCs6, $0C
	saVol		$FD
	sVoice		$01
	ssMod68k	$00, $01, $06, $04
	dc.b nA2, $6C
	sStop

TitleScreen_PSG3:
	sNoisePSG	$E7
	dc.b nRst, $30

TitleScreen_Loop1:
	sNoteTimeOut	$03
	dc.b nA5, $0C
	sNoteTimeOut	$0C
	dc.b $0C
	sNoteTimeOut	$03
	dc.b $0C
	sNoteTimeOut	$0C
	dc.b $0C
	sLoop		$00, $05, TitleScreen_Loop1
	sNoteTimeOut	$03
	dc.b $06
	sNoteTimeOut	$0E
	dc.b $12
	sNoteTimeOut	$03
	dc.b $0C
	sNoteTimeOut	$0F
	dc.b $0C
	sStop

TitleScreen_DAC1:
	dc.b nRst, $0C, dSnare, dSnare, dSnare, dKick, dSnare, dKick
	dc.b dSnare, dKick, dSnare, dKick, dSnare, dKick, dSnare, dKick
	dc.b dSnare, dKick, dSnare, dKick, $06, nRst, $02, dSnare
	dc.b dSnare, dSnare, $09, dSnare, $03, dKick, $0C, dSnare
	dc.b dKick, dSnare, dKick, $06, dSnare, $12, dSnare, $0C
	dc.b dKick

TitleScreen_DAC2:
TitleScreen_PSG1:
	sStop
