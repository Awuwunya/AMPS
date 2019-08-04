Final_Header:
	sHeaderInit
	sHeaderTempo	$02, $28
	sHeaderCh	$05, $00
	sHeaderDAC	Final_DAC1
	sHeaderDAC	Final_DAC2
	sHeaderFM	Final_FM1, $00, $12
	sHeaderFM	Final_FM2, $F4, $0D
	sHeaderFM	Final_FM3, $F4, $0A
	sHeaderFM	Final_FM4, $F4, $0F
	sHeaderFM	Final_FM5, $00, $12
;	sHeaderPSG	Final_PSG1, $D0, $03, $00, v05
;	sHeaderPSG	Final_PSG1, $DC, $06, $00, v05
;	sHeaderPSG	Final_PSG1, $DC, $00, $00, v04

	; Patch $00
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
	; $42, $43, $14, $71,	$1F, $12, $1F, $1F
	; $04, $02, $04, $0A,	$01, $01, $02, $02
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
	spDecayRt	$01, $02, $01, $02
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$1A, $19, $16, $00

Final_FM5:
	ssDetune	$03
	sJump		Final_Jump4

Final_FM1:
	ssMod68k	$1A, $01, $06, $04

Final_Jump4:
	sVoice		$00
	dc.b nB6, $03, nRst, nAb6, nRst, nAb6, nRst, nB6
	dc.b nB6, nRst, $18

Final_Jump1:
	dc.b nRst, $0C, nA5, nB5, nC6, nD6, nC6, nB5
	dc.b nC6, nE6, $60, nRst, $0C, nA5, nB5, nC6
	dc.b nD6, nC6, nB5, nC6, nF6, $30, nG6, $18
	dc.b nAb6, nA5, $0C, nA5, nA5, nA5, nB5, nB5
	dc.b nB5, nB5
	sJump		Final_Jump1

Final_FM2:
	sVoice		$01
	dc.b nE4, $03, nRst, nE3, nRst, nE3, nRst, nE4
	dc.b nE4, nRst, $12, nC4, $03, nB3

Final_Jump2:
	sCall		Final_Call1
	dc.b nC4, $03, nB3
	sCall		Final_Call1
	dc.b nAb3, $06, nF3, $0C, nF3, $09, nF3, $03
	dc.b nF3, $06, nF3, $0C, nC3, $06, nG3, nG3
	dc.b $0C, nG3, $06, nE3, nE3, $0C, nC4, $03
	dc.b nB3
	sJump		Final_Jump2

Final_Call1:
	dc.b nA3, $0C, nA3, $09, nA3, $03, nA3, $06
	dc.b nA3, $0C, nE3, $06, nA3, $03, nE3, nA3
	dc.b $0C, nE3, $06, nA3, $0C, nG3, nF3, nF3
	dc.b $09, nF3, $03, nF3, $06, nF3, $0C, nC3
	dc.b $06, nG3, nG3, $0C, nG3, $06, nAb3, nAb3
	dc.b $0C
	sRet

Final_FM3:
	sVoice		$02
	dc.b nE7, $03, nRst, nE6, nRst, nE6, nRst, nE7
	dc.b nE7, $03, nRst, $18

Final_Jump3:
	sCall		Final_Call2
	dc.b nD7, $06, nRst, nC7, $03, nRst, nB6, nRst
	dc.b nAb6, $12
	sCall		Final_Call2
	dc.b nD7, $06, nRst, nC7, $03, nRst, nB6, nRst
	dc.b nAb6, $12, nA5, $18, nB5, $0C, nC6, nB5
	dc.b $18, nC6, $0C, nD6
	sJump		Final_Jump3

Final_Call2:
	dc.b nRst, $1E, nA4, $03, nRst, nC5, nRst, nE5
	dc.b nRst, nA5, $03, nG5, nA5, $30, nC7, $06
	dc.b nRst, nA6, $03, nRst, nF6, nRst, nD6, $18
	sRet

Final_FM4:
	sVoice		$02
	saVol		$FC
	ssDetune	$03
	dc.b nE7, $03, nRst, nE6, nRst, nE6, nRst, nE7
	dc.b nE7, $03, nRst, $18
	saVol		$04
	sVoice		$03

Final_Loop1:
	dc.b nA4, $06, nE4, nB4, nE4, nC5, nE4, nB4
	dc.b nE4, nA4, nE4, nB4, nE4, nC5, nE4, nB4
	dc.b nE4, nA4, nE4, nB4, nE4, nC5, nE4, nA4
	dc.b nE4, nB4, nE4, nD5, nE4, nC5, nE4, nB4
	dc.b nE4
	sLoop		$00, $02, Final_Loop1

Final_Loop2:
	dc.b nC7, $03, nB6, nBb6, nA6
	sLoop		$00, $04, Final_Loop2

Final_Loop3:
	dc.b nD7, nCs7, nC7, nB6
	sLoop		$00, $04, Final_Loop3
	sJump		Final_Loop1

Final_PSG1:
Final_DAC2:
	sStop

Final_DAC1:
	dc.b dHiTimpani, $06, dLowTimpani, dLowTimpani, dHiTimpani, $03, dHiTimpani, $09
	dc.b dSnare, $03, dSnare, $03, dSnare, $03, dSnare, $03
	dc.b dLowTimpani, dLowTimpani

Final_Loop4:
	dc.b dSnare, $0C, $09, $03, $06, $06, dHiTimpani, dLowTimpani
	dc.b dSnare, dSnare, $0C, $06, $0C, $0C, $0C, $09
	dc.b $03, $06, $06, dHiTimpani, $03, dHiTimpani, dLowTimpani, $06
	dc.b dSnare, $06, $0C, $06, $06, $0C, $06
	sLoop		$00, $02, Final_Loop4
	dc.b $0C, $09, $03, $06, $0C, $06, dHiTimpani, $06
	dc.b dLowTimpani, dHiTimpani, dLowTimpani, dHiTimpani, dLowTimpani, dHiTimpani, dLowTimpani
	sJump		Final_Loop4
