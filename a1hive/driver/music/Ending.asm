Ending_Header:
	sHeaderInit
	sHeaderTempo	$81, $33
	sHeaderCh	$05, $03
	sHeaderDAC	Ending_DAC1
	sHeaderDAC	Ending_DAC2
	sHeaderFM	Ending_FM1, $F4, $0E
	sHeaderFM	Ending_FM2, $F4, $09
	sHeaderFM	Ending_FM3, $F4, $0D
	sHeaderFM	Ending_FM4, $F4, $0D
	sHeaderFM	Ending_FM5, $F4, $17
	sHeaderPSG	Ending_PSG1, $D0, $05, $00, v05
	sHeaderPSG	Ending_PSG2, $DC, $05, $00, v05
	sHeaderPSG	Ending_PSG3, $00, $03, $00, v04

	; Patch $00
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

	; Patch $03
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

Ending_FM1:
	sVoice		$03
	dc.b nRst, $60
	sCall		Ending_Call1
	dc.b nRst, $60
	saVol		$FB
	dc.b nRst, $0C, nE6, $06, nRst, nB6, nE6, $06
	dc.b nRst, $0C, nE6, $06, nRst, nB6, nE6, $06
	dc.b nRst, $18
	saVol		$05
	dc.b nRst, $0C, nA3, nRst, nA3, nRst, $24
	ssDetune	$02
	saVol		$08
	dc.b nA2, $6C
	sStop

Ending_Call1:
	dc.b nRst, $0C, nCs6, $15, nRst, $03, nCs6, $06
	dc.b nRst, nD6, $0F, nRst, $03, nB5, $18, nRst
	dc.b $06, nCs6, nRst, nCs6, nRst, nCs6, nRst, nA5
	dc.b nRst, nG5, $0F, nRst, $03, nB5, $18, nRst
	dc.b $06
	sLoop		$00, $02, Ending_Call1
	sRet

Ending_FM2:
	sVoice		$01
	dc.b nRst, $60

Ending_Loop1:
	dc.b nA3, $06, nRst, nA3, nRst, nE3, nRst, nE3
	dc.b nRst, nG3, $12, nFs3, $0C, nG3, $06, nFs3
	dc.b $0C, nA3, $06, nRst, nA3, nRst, nE3, nRst
	dc.b nE3, nRst, nD4, $12, nCs4, $0C, nD4, $06
	dc.b nCs4, $0C
	sLoop		$00, $02, Ending_Loop1
	dc.b nG3, $06, nRst, nE3, nRst, nF3, nRst, nFs3
	dc.b nRst, nG3, nG3, nE3, nRst, nF3, nRst, nG3
	dc.b nRst, nE3, nRst, nE3, nRst, nAb3, nRst, nAb3
	dc.b nRst, nB3, nRst, nB3, nRst, nD4, nRst, nD4
	dc.b nRst, nRst, $0C, nA2, $12, nRst, $06, nA2
	dc.b $12, nAb3, nA3, $06, nRst
	saVol		$FD
	dc.b nA2, $6C
	sStop

Ending_FM3:
	sVoice		$02
	dc.b nRst, $60

Ending_Loop2:
	dc.b nE6, $06, nRst, nE6, nRst, nCs6, nRst, nCs6
	dc.b nRst, nD6, $12, nD6, $1E, nE6, $06, nRst
	dc.b nE6, nRst, nCs6, nRst, nCs6, nRst, nG6, $12
	dc.b nG6, $1E
	sLoop		$00, $02, Ending_Loop2
	dc.b nRst, $0C, nD6, $12, nRst, $06, nD6, nRst
	dc.b nCs6, $12, nD6, nCs6, $0C, nAb5, $18, nB5
	dc.b nD6, nAb6, nRst, $0C, nE6, nRst, nE6, $12
	dc.b nEb6, nE6, $06, nRst
	saVol		$F8
	sVoice		$01
	ssDetune	$03
	dc.b nA2, $6C
	sStop

Ending_FM4:
	sVoice		$02
	dc.b nRst, $60

Ending_Loop3:
	dc.b nCs6, $06, nRst, nCs6, nRst, nA5, nRst, nA5
	dc.b nRst, nB5, $12, nB5, $1E, nCs6, $06, nRst
	dc.b nCs6, nRst, nA5, nRst, nA5, nRst, nD6, $12
	dc.b nD6, $1E
	sLoop		$00, $02, Ending_Loop3
	ssDetune	$03
	saVol		$08
	sCall		Ending_Call2
	saVol		$F0
	sVoice		$01
	ssMod68k	$00, $01, $06, $04
	dc.b nA2, $6C
	sStop

Ending_Call2:
	sVoice		$00
	dc.b nRst, $0C, nG6, nB6, nD7, nFs7, $0C, nRst
	dc.b $06, nFs7, $0C, nG7, $06, nFs7, $0C, nAb7
	dc.b $60, nA7, $0C, nRst, nA7, nRst, nRst, $06
	dc.b nAb7, $12, nA7, $0C
	sRet

Ending_FM5:
	sVoice		$03
	ssDetune	$03
	saVol		$F7
	dc.b nRst, $60
	sCall		Ending_Call1
	saVol		$09
	ssMod68k	$00, $01, $06, $04
	sCall		Ending_Call2
	sStop

Ending_PSG1:
	dc.b nRst, $60, nRst, nRst, nRst, nRst, nRst, $0C
	dc.b nB5, $12, nRst, $06, nB5, nRst, nA5, $12
	dc.b nB5, nA5, $0C, nE5, $18, nAb5, nB5, nD6
	dc.b nRst, $0C, nCs6, nRst, nCs6, $12, nC6, nCs6
	dc.b $06
	sStop

Ending_PSG2:
	ssDetune	$01
	dc.b nRst, $60, nRst, nRst, nRst, nRst, nRst, nRst
	dc.b $0C, nE6, $06, nRst, nB6, nE6, nRst, $0C
	dc.b nE6, $06, nRst, nB6, nE6, nRst, $18
	sStop

Ending_PSG3:
	sNoisePSG	$E7

Ending_Loop4:
	sNoteTimeOut	$03
	dc.b nA5, $0C
	sNoteTimeOut	$0C
	dc.b $0C
	sNoteTimeOut	$03
	dc.b $0C
	sNoteTimeOut	$0C
	dc.b $0C
	sLoop		$00, $0F, Ending_Loop4
	sNoteTimeOut	$03
	dc.b nA5, $06
	sNoteTimeOut	$0E
	dc.b $12
	sNoteTimeOut	$03
	dc.b $0C
	sNoteTimeOut	$0F
	dc.b $0C
	sStop

Ending_DAC1:
	dc.b dKick, $0C, dSnare, dKick, dSnare, dKick, $0C, dSnare
	dc.b dKick, $06, nRst, $02, dSnare, dSnare, dSnare, $09
	dc.b dSnare, $03

Ending_Loop5:
	dc.b dKick, $0C, dSnare, dKick, dSnare, dKick, $0C, dSnare
	dc.b dKick, dSnare, dKick, $0C, dSnare, dKick, dSnare, dKick
	dc.b $0C, dSnare, dKick, $06, nRst, $02, dSnare, dSnare
	dc.b dSnare, $09, dSnare, $03
	sLoop		$00, $03, Ending_Loop5
	dc.b dKick, $0C, dSnare, dKick, dSnare, dKick, $06, dSnare
	dc.b $12, dSnare, $0C, dKick

Ending_DAC2:
	sStop
