StarLight_Header:
	sHeaderInit
	sHeaderTempo	$02, $28
	sHeaderCh	$05, $03
	sHeaderDAC	StarLight_DAC1
	sHeaderDAC	StarLight_DAC2
	sHeaderFM	StarLight_FM1, $E8, $00
	sHeaderFM	StarLight_FM2, $E8, $06
	sHeaderFM	StarLight_FM3, $DC, $1A
	sHeaderFM	StarLight_FM4, $DC, $1A
	sHeaderFM	StarLight_FM5, $F4, $20
	sHeaderPSG	StarLight_PSG1, $C4, $06, $00, v05
	sHeaderPSG	StarLight_PSG2, $C4, $06, $00, v05
	sHeaderPSG	StarLight_PSG3, $00, $04, $00, v04

	; Patch $00
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

	; Patch $01
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

	; Patch $02
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

	; Patch $03
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

	; Patch $04
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

	; Patch $05
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

StarLight_FM1:
	sVoice		$00
	dc.b nRst, $0C, nG5, nA5, nG6

StarLight_Jump1:
	sCall		StarLight_Call1
	dc.b nE6, $1E

StarLight_Loop1:
	dc.b nE7, $06, nC7, $3C, nRst, $1E
	sLoop		$00, $03, StarLight_Loop1
	dc.b nE7, $06, nC7, $18, nG5, $0C, nA5, nG6
	sJump		StarLight_Jump1

StarLight_Call1:
	sCall		StarLight_Call2
	dc.b nE6, $1E, nF6, $06, nE6, nD6, $12, nG5
	dc.b $0C, nA5, nG6
	sCall		StarLight_Call2
	sRet

StarLight_Call2:
	dc.b nE6, $2A, nE6, $03, nF6, nG6, $09, nA6
	dc.b nBb6, $06, nA6, $0C, nG6, nF6, $1E, nF6
	dc.b $06, nE6, nF6, $1E, nD6, $0C, nE6, nF6
	dc.b $2A, nD6, $03, nE6, nF6, $09, nG6, nAb6
	dc.b $06, nG6, $0C, nF6
	sRet

StarLight_FM2:
	sVoice		$01
	dc.b nRst, $30

StarLight_Jump2:
	sCall		StarLight_Call3
	dc.b nRst, $06, nB3, $02, nRst, $01, nB3, $02
	dc.b nRst, $01, nC4, $06, nRst, $03, nC4, nRst
	dc.b $06, nC4, $12, nRst, $06, nC4, $02, nRst
	dc.b $01, nC4, $02, nRst, $01, nD4, $06, nRst
	dc.b $03, nD4, nRst, $06, nG3, $12, nD4, $06
	dc.b nG3
	sCall		StarLight_Call3
	dc.b nRst, $06, nD4, $02, nRst, $01, nB3, $02
	dc.b nRst, $01
	sCall		StarLight_Call4
	dc.b nB3, $02, nRst, $01, nE4, $02, nRst, $01
	dc.b nF4, $06, nRst, $03, nF4, nRst, $06, nF4
	dc.b $12, nRst, $06, nG4, $02, nRst, $01, nF4
	dc.b $02, nRst, $01
	sCall		StarLight_Call4
	dc.b nE4, $02, nRst, $01, nF4, $02, nRst, $01
	dc.b nG4, $06, nRst, nG3, $24
	sJump		StarLight_Jump2

StarLight_Call3:
	dc.b nC4, $06, nRst, $03, nC4, nRst, $06, nC4
	dc.b $12, nRst, $06, nC4, $02, nRst, $01, nC4
	dc.b $02, nRst, $01, nBb3, $06, nRst, $03, nBb3
	dc.b $03, nRst, $06, nA3, $12, nRst, $06, nA3
	dc.b $02, nRst, $01, nA3, $02, nRst, $01

StarLight_Loop2:
	dc.b nD4, $06, nRst, $03, nD4, $06, nRst, $03
	dc.b nD4, $02, nRst, $01, nD4, $02, nRst, $01
	saTranspose	$FF
	sLoop		$00, $04, StarLight_Loop2
	saTranspose	$04
	dc.b nG3, $06, nRst, $03, nG3, nRst, $06, nG3
	dc.b $12, nRst, $06, nG3, $02, nRst, $01, nG3
	dc.b $02, nRst, $01, nB3, $06, nRst, $03, nB3
	dc.b nRst, $06, nB3, $12
	sRet

StarLight_Call4:
	dc.b nC4, $06, nRst, $03, nC4, nRst, $06, nC4
	dc.b $12, nRst, $06, nG3, $02, nRst, $01, nC4
	dc.b $02, nRst, $01, nD4, $06, nRst, $03, nD4
	dc.b nRst, $06, nD4, $12, nRst, $06, nA3, $02
	dc.b nRst, $01, nD4, $02, nRst, $01, nE4, $06
	dc.b nRst, $03, nE4, nRst, $06, nE4, $12, nRst
	dc.b $06
	sRet

StarLight_FM3:
	sVoice		$02
	sPan		spLeft, $00

StarLight_PSG1:
	dc.b nRst, $30

StarLight_Jump3:
	sCall		StarLight_Call5
	dc.b nG6, $06, nRst, $03, nG6, nRst, $06, nG6
	dc.b $12, nRst, $06, nB6, $09, nRst, $03, nB6
	dc.b nRst, nA6, $09, nRst, $03, nG6, nRst, nF6
	dc.b $0C, nRst, $06
	sCall		StarLight_Call5
	sCall		StarLight_Call6
	sNoteTimeOut	$08
	dc.b nRst, $06, nE7, $09, $09, $09, nD7, $09
	dc.b nC7, $06
	sCall		StarLight_Call6
	sNoteTimeOut	$00
	dc.b nRst, $0C, nA6, $24
	sJump		StarLight_Jump3

StarLight_Call5:
	dc.b nG6, $06, nRst, $03, nG6, nRst, $06, nG6
	dc.b $18, nRst, $06, nF6, nRst, $03, nF6, nRst
	dc.b $06, nE6, $18, nRst, $06, nA6, nRst, $03
	dc.b nG6, $06, nRst, $03, nF6, nRst, nA6, $06
	dc.b nRst, $03, nG6, $06, nRst, $03, nF6, nRst
	dc.b nA6, $06, nRst, $03, nG6, $06, nRst, $03
	dc.b nF6, $18, nRst, $06, nF6, nRst, $03, nF6
	dc.b nRst, $06, nF6, $18, nRst, $06, nAb6, nRst
	dc.b $03, nAb6, nRst, $06, nAb6, $18, nRst, $06
	sRet

StarLight_Call6:
	sNoteTimeOut	$08
	dc.b nRst, $06, nB6, $09, $09, $09, $09
	sNoteTimeOut	$05
	dc.b $03, $03
	sNoteTimeOut	$08
	dc.b nRst, $06, nC7, $09, $09, $09, $09
	sNoteTimeOut	$05
	dc.b $03, $03
	sNoteTimeOut	$08
	dc.b nRst, $06, nD7, $09, $09, $09, $09
	sNoteTimeOut	$05
	dc.b $03, $03
	sRet

StarLight_FM4:
	sVoice		$02
	sPan		spRight, $00

StarLight_PSG2:
	dc.b nRst, $30

StarLight_Jump4:
	sCall		StarLight_Call7
	dc.b nE6, $06, nRst, $03, nE6, nRst, $06, nE6
	dc.b $12, nRst, $06, nG6, $09, nRst, $03, nG6
	dc.b nRst, nF6, $09, nRst, $03, nE6, nRst, nD6
	dc.b $0C, nRst, $06
	sCall		StarLight_Call7
	sCall		StarLight_Call8
	sNoteTimeOut	$08
	dc.b nRst, $06, nC7, $09, $09, $09, nB6, $09
	dc.b nA6, $06
	sNoteTimeOut	$08
	sCall		StarLight_Call8
	sNoteTimeOut	$00
	dc.b nRst, $0C, nF6, $24
	sJump		StarLight_Jump4

StarLight_Call7:
	dc.b nE6, $06, nRst, $03, nE6, nRst, $06, nE6
	dc.b $18, nRst, $06, nD6, nRst, $03, nD6, nRst
	dc.b $06, nCs6, $18, nRst, $06, nF6, nRst, $03
	dc.b nE6, $06, nRst, $03, nD6, nRst, nF6, $06
	dc.b nRst, $03, nE6, $06, nRst, $03, nD6, nRst
	dc.b nF6, $06, nRst, $03, nE6, $06, nRst, $03
	dc.b nD6, $18, nRst, $06, nD6, nRst, $03, nD6
	dc.b nRst, $06, nD6, $18, nRst, $06, nF6, nRst
	dc.b $03, nF6, nRst, $06, nF6, $18, nRst, $06
	sRet

StarLight_Call8:
	sNoteTimeOut	$08
	dc.b nRst, $06, nG6, $09, $09, $09, $09
	sNoteTimeOut	$05
	dc.b $03, $03
	sNoteTimeOut	$08
	dc.b nRst, $06, nA6, $09, $09, $09, $09
	sNoteTimeOut	$05
	dc.b $03, $03
	sNoteTimeOut	$08
	dc.b nRst, $06, nB6, $09, $09, $09, $09
	sNoteTimeOut	$05
	dc.b $03, $03
	sRet

StarLight_FM5:
	sVoice		$04
	dc.b nRst, $0C, nG5, nA5, nG6

StarLight_Jump5:
	sVoice		$04
	sCall		StarLight_Call1
	dc.b nE6, $06
	sVoice		$03
	saVol		$EC
	sCall		StarLight_Call9
	ssDetune	$14
	dc.b nA5, $01, sHold
	ssDetune	$00
	dc.b nA5, $05
	sCall		StarLight_Call11
	dc.b nEb4
	saVol		$07
	dc.b nEb4
	sVoice		$03
	saVol		$E8
	saTranspose	$CD
	dc.b nRst, $06
	ssDetune	$14
	dc.b nE6, $01, sHold
	ssDetune	$00
	dc.b nE6, $05, nF6, $06, nE6, nF6, nG6, nRst
	dc.b nC6, nRst, $06
	sCall		StarLight_Call9
	sNoteTimeOut	$05
	dc.b nA5, $03, $03
	sNoteTimeOut	$00
	sCall		StarLight_Call11
	sVoice		$03
	saVol		$EF
	saTranspose	$CD
	dc.b nE6, $03, nF6, nG6, $03, nRst, $09
	ssDetune	$EC
	dc.b nC7, $01, sHold
	ssDetune	$00
	ssMod68k	$2C, $01, $04, $04
	dc.b nC7, $23
	sModOff
	saVol		$14
	sJump		StarLight_Jump5

StarLight_Call9:
	sCall		StarLight_Call10
	dc.b nEb4
	saVol		$07
	dc.b nEb4
	sVoice		$03
	saVol		$E8
	saTranspose	$CD
	dc.b nRst, $06
	ssDetune	$14
	dc.b nE6, $01, sHold
	ssDetune	$00
	dc.b $05, nRst, $06
	ssDetune	$14
	dc.b nC6, $01, sHold
	ssDetune	$00
	dc.b $05, nRst, $06
	sRet

StarLight_Call11:
	dc.b nC6, $06, nA5, nRst, $06

StarLight_Call10:
	ssDetune	$14
	dc.b nG5, $01, sHold
	ssDetune	$00
	dc.b $02, nA5, $03
	sNoteTimeOut	$05
	dc.b nC6, $03, nC6, $06, nA5, $03, nC6, $03
	sNoteTimeOut	$00
	dc.b nC6, nRst
	saVol		$FC
	saTranspose	$33
	sVoice		$05
	dc.b nEb4, $03
	saVol		$07
	dc.b nEb4
	saVol		$07
	dc.b nEb4
	saVol		$07
	sRet
	dc.b $F6, $FF, $FE, $F6, $FF, $FE	; Unused

StarLight_PSG3:
	sNoisePSG	$E7
	sNoteTimeOut	$02
	dc.b nRst, $24

StarLight_Jump6:
	dc.b nA5, $03, $03
	saVol		$02
	sVoice		v08
	sNoteTimeOut	$08
	dc.b $06
	sVoice		v04
	sNoteTimeOut	$03
	saVol		$FE
	sJump		StarLight_Jump6

StarLight_DAC1:
	dc.b nRst, $30

StarLight_Jump7:
	dc.b dKick, $0C
	sJump		StarLight_Jump7

StarLight_DAC2:
	sStop
