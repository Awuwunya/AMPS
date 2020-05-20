Dis_Header:
	sHeaderInit						; Z80 offset is $8000
	sHeaderTempo	$01, $25
	sHeaderCh	$05, $03
	sHeaderDAC	Dis_DAC1
	sHeaderDAC	Dis_DAC2
	sHeaderFM	Dis_FM1, $00, $09
	sHeaderFM	Dis_FM2, $0C, $10
	sHeaderFM	Dis_FM3, $0C, $10
	sHeaderFM	Dis_FM4, $00, $10
	sHeaderFM	Dis_FM5, $00, $10
	sHeaderPSG	Dis_PSG1, $F4, $00, $00, vKc08
	sHeaderPSG	Dis_PSG2, $F4, $18, $00, vKc08
	sHeaderPSG	Dis_PSG3, $00, $08, $00, vKc02

	; Patch $00
	; $3A
	; $01, $05, $32, $71,	$CF, $95, $1F, $1F
	; $0E, $0F, $05, $0C,	$17, $06, $06, $07
	; $8F, $4F, $4F, $4F,	$21, $13, $24, $80
	spAlgorithm	$02
	spFeedback	$07
	spDetune	$00, $03, $00, $07
	spMultiple	$01, $02, $05, $01
	spRateScale	$03, $00, $02, $00
	spAttackRt	$0F, $1F, $15, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0E, $05, $0F, $0C
	spSustainLv	$08, $04, $04, $04
	spDecayRt	$17, $06, $06, $07
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$21, $24, $13, $00

	; Patch $01
	; $1C
	; $32, $02, $04, $34,	$5F, $FF, $5F, $FF
	; $05, $05, $05, $07,	$15, $10, $21, $13
	; $9F, $3F, $5F, $AF,	$30, $80, $02, $84
	spAlgorithm	$04
	spFeedback	$03
	spDetune	$03, $00, $00, $03
	spMultiple	$02, $04, $02, $04
	spRateScale	$01, $01, $03, $03
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$05, $05, $05, $07
	spSustainLv	$09, $05, $03, $0A
	spDecayRt	$15, $21, $10, $13
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$30, $02, $00, $04

	; Patch $02
	; $2D
	; $06, $05, $04, $10,	$1F, $5F, $5F, $5F
	; $05, $07, $0C, $0C,	$17, $17, $12, $18
	; $9F, $9C, $9C, $9C,	$2D, $80, $80, $80
	spAlgorithm	$05
	spFeedback	$05
	spDetune	$00, $00, $00, $01
	spMultiple	$06, $04, $05, $00
	spRateScale	$00, $01, $01, $01
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$05, $0C, $07, $0C
	spSustainLv	$09, $09, $09, $09
	spDecayRt	$17, $12, $17, $18
	spReleaseRt	$0F, $0C, $0C, $0C
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$2D, $00, $00, $00

	; Patch $03
	; $3D
	; $01, $01, $01, $01,	$94, $19, $19, $19
	; $0F, $0D, $0D, $0D,	$07, $04, $04, $04
	; $25, $1A, $1A, $1A,	$15, $80, $80, $80
	spAlgorithm	$05
	spFeedback	$07
	spDetune	$00, $00, $00, $00
	spMultiple	$01, $01, $01, $01
	spRateScale	$02, $00, $00, $00
	spAttackRt	$14, $19, $19, $19
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$0F, $0D, $0D, $0D
	spSustainLv	$02, $01, $01, $01
	spDecayRt	$07, $04, $04, $04
	spReleaseRt	$05, $0A, $0A, $0A
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$15, $00, $00, $00

	; Patch $04
	; $3C
	; $07, $01, $08, $04,	$5F, $9F, $9F, $5F
	; $16, $1F, $16, $1F,	$09, $0F, $16, $11
	; $6F, $0F, $AF, $0F,	$16, $80, $11, $80
	spAlgorithm	$04
	spFeedback	$07
	spDetune	$00, $00, $00, $00
	spMultiple	$07, $08, $01, $04
	spRateScale	$01, $02, $02, $01
	spAttackRt	$1F, $1F, $1F, $1F
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$16, $16, $1F, $1F
	spSustainLv	$06, $0A, $00, $00
	spDecayRt	$09, $16, $0F, $11
	spReleaseRt	$0F, $0F, $0F, $0F
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$16, $11, $00, $00

Dis_FM1:
	sVoice		$00

Dis_Loop1:
	sCall		Dis_Call1
	sLoop		$00, $03, Dis_Loop1
	dc.b nF1, $12, nF2, $06, nRst, $12, nF1, $06
	dc.b nRst, $30

Dis_Loop2:
	sCall		Dis_Call2
	sLoop		$00, $07, Dis_Loop2
	dc.b nC2, $12, nC3, $06, nRst, $12, nC2, $06
	dc.b nRst, $30
	sCall		Dis_Call3
	dc.b nA2, $24, nG1, nC2, $18
	sCall		Dis_Call3
	dc.b nA1, $18, nA2, $06, nRst, nA1, $18, $0C
	dc.b nG1, $06, nG2, nRst, nG2
	sCall		Dis_Call3
	dc.b nA2, $24, nG1, nC2, $18
	sCall		Dis_Call3
	dc.b nD2, $24, nE2, $18, nE3, $06, nRst, nA1
	dc.b $0C, nA2, $06, nRst

Dis_Loop3:
	sCall		Dis_Call1
	sLoop		$00, $03, Dis_Loop3
	dc.b nF1, $12, nF2, $06, nRst, $12, nF1, $06
	dc.b nRst, nF1, $06, $0C, $0C, nG2, nA1, $12
	dc.b nA2, $06, nRst, $12, nA1, $06, nRst, nA1
	dc.b $06, $0C, $0C, nA2, $06, nRst, nAb1, $12
	dc.b nAb2, $06, nRst, $12, nAb1, $06, nRst, nAb1
	dc.b $06, $0C, $18, nG1, $12, nG2, $06, nRst
	dc.b $12, nG1, $06, nRst, nG1, $06, $0C, $0C
	dc.b nE1, nFs1, $12, nFs2, $06, nRst, $12, nD2
	dc.b $06, nRst, nD2, $06, $0C, $0C, nD3, $06
	dc.b nRst
	sLoop		$01, $02, Dis_Loop3

Dis_Loop4:
	sCall		Dis_Call1
	sLoop		$00, $03, Dis_Loop4
	dc.b nF1, $12, nF2, $06, nRst, $0C, $06, nF1
	dc.b $06, nRst, $30
	sJump		Dis_Loop2

Dis_FM2:	; Fuse FM2 and FM6
	dc.b nRst, $0C			; FM6
	sVoice		$01
	dc.b nE3-7-$0C, $06		; FM6
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F
	sVoice		$02
	dc.b nG5			; FM2
	sVoice		$01
	dc.b nE3-7-$0C			; FM6
	saVol		$0F
	dc.b $06, nRst			; FM6
	saVol		-$0F
	dc.b nE3-7-$0C, $0C		; FM6
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F
	dc.b nE3-7-$0C, $0C		; FM6
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F
	dc.b nE3-7-$0C			; FM2
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F

	dc.b nRst, $0C, nE3-9-$0C, $06	; FM6
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F
	sVoice		$02
	dc.b nG5			; FM2
	sVoice		$01
	dc.b nE3-9-$0C			; FM6
	saVol		$0F
	dc.b $06, nRst			; FM6
	saVol		-$0F
	dc.b nE3-9-$0C, $0C		; FM6
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F
	dc.b nE3-9-$0C, $0C		; FM6
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F
	dc.b nE3-9-$0C			; FM2
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F

	dc.b nRst, $0C, nE3-7-$0C, $06	; FM6
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F
	sVoice		$02
	dc.b nG5			; FM2
	sVoice		$01
	dc.b nE3-7-$0C			; FM6
	saVol		$0F
	dc.b $06, nRst			; FM6
	saVol		-$0F
	dc.b nE3-7-$0C, $0C		; FM6
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F
	dc.b nE3-7-$0C, $0C		; FM6
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F
	dc.b nE3-7-$0C			; FM2
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F

	dc.b nRst, $0C, nE3-9-$0C, $06	; FM6
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F
	sVoice		$02
	dc.b nG5			; FM2
	sVoice		$01
	dc.b nE3-9-$0C			; FM6
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F
	dc.b nE3-9-$0C			; FM6
	saVol		$0F
	dc.b $06			; FM6
	saVol		-$0F
	dc.b nRst, $12
	sVoice		$02
	dc.b nG5, $18			; FM2

Dis_Jump1:
	saTranspose	-$0C
	sVoice		$01

Dis_Loop13:
	dc.b nRst, $0C, nG2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nG2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nG2, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nG2, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nG2, $0C, nRst, $0C, nF2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nF2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nF2, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nF2, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nG2, $0C
	sLoop		$00, $03, Dis_Loop13
	dc.b nRst, $0C, nG2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nG2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nG2, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nG2, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nG2, $0C, nRst, $0C, nF2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nF2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nG2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, $2A			; FM6 above

;	sVoice		$01
	dc.b nRst, $0C, nA2, $0C
	saVol		$0F
	dc.b $06
	saVol		-$0F
	dc.b nA2, $0C, nAb2, $06
	saVol		$0F
	dc.b $06
	saVol		-$0F		; more FM6 above
	saTranspose	$0C

	sVoice		$03
	sPan		spRight, $00
	dc.b nRst, $06, nG4, $0C
	saVol		$0A
	dc.b $06, nRst
	saVol		-$01
	dc.b nG4, $0C
;	saVol		$0A
;	dc.b $06
	saVol		-$09		; FM2 above, clip 1 note out

	saTranspose	-$0C
	sVoice		$01
	sPan		spCentre, $00
	dc.b nG2, $1E
	saVol		$0F
	dc.b $06
	saVol		-$0F
	dc.b nG2, $1E
	saVol		$0F
	dc.b $06
	saVol		-$0F
	dc.b nG2, $18			; FM6 above

;	dc.b nRst, $5A
;	saVol		-$09

	dc.b nRst, $0C, nA2, $0C
	saVol		$0F
	dc.b $06
	saVol		-$0F
	dc.b nA2, $0C, nAb2, $06
	saVol		$0F
	dc.b $06
	saVol		-$0F		; FM6 above
	saTranspose	$0C

	sVoice		$03
	sPan		spRight, $00
	dc.b nRst, $06, nD5, $0C
	saVol		$0A
	dc.b $06, nRst
	saVol		-$01
	dc.b nD5, $0C
;	saVol		$0A
;	dc.b $06
	saVol		-$09		; FM2 above, clip 1 note out

	saTranspose	-$0C
	sVoice		$01
	sPan		spCentre, $00
	dc.b nG2, $1E
	saVol		$0F
	dc.b $06
	saVol		-$0F
	dc.b nG2, $12
	saVol		$0F
	dc.b $06
	saVol		-$0F
;	dc.b nG2, $0C
;	saVol		$0F
;	dc.b $06
;	saVol		$F1
;	dc.b nG2, $0C, $06		; FM6 above, removed several notes
	saTranspose	$0C

	sVoice		$03
	sPan		spRight, $00
	dc.b nG4, $06, nA4, nE4, nD4, $0C
	dc.b nC4, $06
	saVol		$0A
	dc.b $06
	saVol		-$0A		; FM2 above

	saTranspose	-$0C
	sVoice		$01
	sPan		spCentre, $00
	dc.b nRst, $06, nA2, $0C
	saVol		$0F
	dc.b $06
	saVol		-$0F
	dc.b nA2, $0C, nAb2, $06
	saVol		$0F
	dc.b $06, nRst
	saVol		-$0F		; FM6 above
	saTranspose	$0C

	sVoice		$03
	sPan		spRight, $00
	dc.b nG4, $0C
	saVol		$0A
	dc.b $06, nRst
	saVol		-$01
	dc.b nG4, $0C
;	saVol		$0A
;	dc.b $06
	saVol		-$09		; FM2 above, clip 1 note out

	saTranspose	-$0C
	sVoice		$01
	sPan		spCentre, $00
	dc.b nG2, $1E
	saVol		$0F
	dc.b $06
	saVol		-$0F
	dc.b nG2, $1E
	saVol		$0F
	dc.b $06
	saVol		-$0F
	dc.b nG2, $18			; FM6 above

	dc.b nRst, $0C, nA2, $0C
	saVol		$0F
	dc.b $06
	saVol		-$0F
	dc.b nA2, $0C, nAb2, $06
	saVol		$0F
	dc.b $06, nRst
	saVol		-$0F		; FM6 above
	saTranspose	$0C

	sVoice		$03
	sPan		spRight, $00
	dc.b nD5, $0C
	saVol		$0A
	dc.b $06, nRst
	saVol		-$01
	dc.b nD5, $0C
	saVol		-$07
	dc.b nC4, $24
	saVol		-$02
	dc.b nD4
	dc.b nE4, $18			; FM2 above

Dis_Loop6:
	sVoice		$02
	sPan		spCenter, $00
	dc.b nRst, $18, nG5
	sVoice		$03
	sPan		spRight, $00
	dc.b nRst, $06, nG3, nA3
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nC4, $0C, nA3, $06
	saVol		$0A
	dc.b $06
	saVol		$F6
	sVoice		$02
	sPan		spCenter, $00
	dc.b nRst, $18, nG5
	sVoice		$03
	sPan		spRight, $00
	dc.b nRst, $06, nG3, nA3
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nC4, nD4
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nE4
	sVoice		$02
	sPan		spCenter, $00
	dc.b nA4, $18, nB4, nC5, nD5, nG4, nG5, nF5
	dc.b nE5
	sVoice		$03
	sPan		spRight, $00
	dc.b nE4, $12
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nD4, $12
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nC4, $12, nB3, nBb3, $06
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nAb3, $0C, nG3, nAb3, nA3, nBb3, nB3, $06
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nE4, $0C, nD4, $06
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nRst, $0C, nG3, nA3, nC4, $06, nG4, $36
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nRst, $12, nE4, $3C, nD4, $0C
	sLoop		$00, $02, Dis_Loop6
	sVoice		$02
	sPan		spCenter, $00
	sCall		Dis_Call4
	sJump		Dis_Jump1

Dis_FM3:
	sVoice		$02
	sCall		Dis_Call5

Dis_Jump2:
	sVoice		$04
	saTranspose	$F4
	dc.b nRst, $0C, nG3, $06, $06
	sCall		Dis_Call6
	sCall		Dis_Call6
	sCall		Dis_Call6
	saTranspose	$02
	sCall		Dis_Call6
	sCall		Dis_Call6
	sCall		Dis_Call6
	saTranspose	$FE
	sCall		Dis_Call6

Dis_Loop7:
	sCall		Dis_Call6
	sLoop		$00, $04, Dis_Loop7
	saTranspose	$02
	sCall		Dis_Call6
	sCall		Dis_Call6
	sCall		Dis_Call6
	saTranspose	$FE
	sCall		Dis_Call6
	sLoop		$01, $02, Dis_Loop7
	sCall		Dis_Call6
	sCall		Dis_Call6
	sCall		Dis_Call6
	sCall		Dis_Call6
	saTranspose	$02
	sCall		Dis_Call6
	saTranspose	$FE
	saVol		$0A
	sPan		spLeft, $00
	dc.b $06
	saVol		$F6
	sPan		spCenter, $00
	dc.b nRst, nA3, nG3
	saVol		$0A
	sPan		spLeft, $00
	dc.b $06
	saVol		$F6
	sPan		spCenter, $00
	dc.b nRst, $2A
	saTranspose	$0C
	sVoice		$03
	sPan		spLeft, $00
	dc.b nRst, $3C, nD4, $0C
	saVol		$0A
	dc.b $06, nRst
	saVol		$F6
	saVol		$09
	dc.b nD4, $0C
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nRst, $5A
	saVol		$F7
	dc.b nRst, $3C, nG4, $0C
	saVol		$0A
	dc.b $06, nRst
	saVol		$F6
	saVol		$09
	dc.b nG4, $0C
	saVol		$0A
	dc.b $06
	saVol		$ED
	dc.b nRst, $36, nB3, $06, nC4, nC4, nA3, $0C
	dc.b nA3, $06
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nRst, $36, nD4, $0C
	saVol		$0A
	dc.b $06, nRst
	saVol		$F6
	saVol		$09
	dc.b nD4, $0C
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nRst, $5A
	saVol		$F7
	dc.b nRst, $3C, nG4, $0C
	saVol		$0A
	dc.b $06, nRst
	saVol		$F6
	saVol		$09
	dc.b nG4, $0C
	saVol		$F7
	saVol		$02
	dc.b nG3, $24
	saVol		$FE
	dc.b nA3
	saVol		$FE
	dc.b nBb3, $18
	saVol		$02

Dis_Loop8:
	sVoice		$02
	saVol		$05
	sModAMPS	$01, $01, $04, $04
	dc.b nRst, $1E, nG5, $12
	sVoice		$03
	saVol		$FB
	sModOff
	dc.b nRst, $06, nC3, nD3
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nF3, $0C, nC3, $06
	saVol		$0A
	dc.b $06
	saVol		$F6
	sVoice		$02
	saVol		$05
	sModAMPS	$01, $01, $04, $04
	dc.b nRst, $1E, nG5, $12
	sVoice		$03
	saVol		$FB
	sModOff
	dc.b nRst, $06, nD3, nE3
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nG3, nA3
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nB3
	sVoice		$02
	saVol		$05
	sModAMPS	$01, $01, $04, $04
	dc.b nRst, $06, nA4, $18, nB4, nC5, nD5, nG4
	dc.b nG5, nF5, nE5, $12
	sVoice		$03
	saVol		$FB
	sModOff
	dc.b nA3, $12
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nG3, $12
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nF3, $12, nE3, nEb3, $06
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nD3, $0C, nC3, nD3, nEb3, nE3, nF3, $06
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nC4, $0C, nAb3, $06
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nRst, $0C, nC3, nD3, nG3, $06, nC4, $36
	saVol		$0A
	dc.b $06
	saVol		$F6
	dc.b nRst, $12, nC4, $3C, $0C
	sLoop		$00, $02, Dis_Loop8
	sVoice		$02
	sCall		Dis_Call5
	sJump		Dis_Jump2

Dis_FM4:
	sVoice		$01
	sCall		Dis_Call7
	saTranspose	$FE
	sCall		Dis_Call7
	saTranspose	$02
	sCall		Dis_Call7
	saTranspose	$FE
	sCall		Dis_Call8
	saTranspose	$02

Dis_Loop9:
	dc.b nRst, $0C, nE3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nE3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nD3, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nD3, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nD3, $0C, nRst, $0C, nC3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nC3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nC3, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nC3, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nD3, $0C
	sLoop		$00, $03, Dis_Loop9
	dc.b nRst, $0C, nE3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nE3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nD3, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nD3, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nD3, $0C, nRst, $0C, nC3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nC3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nD3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, $2A
	sCall		Dis_Call9
	dc.b nE3, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nD3, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nE3, $18
	sCall		Dis_Call9
	dc.b nE3, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nE3, $12
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nE3, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nD3, $0C, $06
	sCall		Dis_Call9
	dc.b nE3, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nD3, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nE3, $18
	sCall		Dis_Call9
	dc.b nC3, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nD3, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nE3, $12
	saVol		$0F
	dc.b $06
	saVol		$F1

Dis_Loop10:
	sCall		Dis_Call7
	saTranspose	$FE
	sCall		Dis_Call7
	saTranspose	$02
	sCall		Dis_Call7
	saTranspose	$FE
	sCall		Dis_Call7
	saTranspose	$02
	sCall		Dis_Call7
	saTranspose	$FE
	sCall		Dis_Call7
	saTranspose	$02
	sCall		Dis_Call7
	sCall		Dis_Call7
	sLoop		$00, $02, Dis_Loop10
	sCall		Dis_Call7
	saTranspose	$FE
	sCall		Dis_Call7
	saTranspose	$02
	sCall		Dis_Call7
	saTranspose	$FE
	sCall		Dis_Call8
	saTranspose	$02
	sJump		Dis_Loop9

Dis_FM5:
	sVoice		$01
	saTranspose	$FC
	sCall		Dis_Call7
	saTranspose	$FF
	sCall		Dis_Call7
	saTranspose	$01
	sCall		Dis_Call7
	saTranspose	$FF
	sCall		Dis_Call8
	saTranspose	$05

Dis_Loop11:
	dc.b nRst, $0C, nC3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nC3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nB2, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nB2, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nB2, $0C, nRst, $0C, nA2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nA2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nA2, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nA2, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nB2, $0C
	sLoop		$00, $03, Dis_Loop11
	dc.b nRst, $0C, nC3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nC3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nB2, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nB2, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nB2, $0C, nRst, $0C, nA2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nA2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nB2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, $2A
	sCall		Dis_Call10
	dc.b nC3, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nBb2, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nBb2, $18
	sCall		Dis_Call10
	dc.b nC3, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nC3, $12
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nC3, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nB2, $0C, $06
	sCall		Dis_Call10
	dc.b nC3, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nBb2, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nBb2, $18
	sCall		Dis_Call10
	dc.b nA2, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nB2, $1E
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nBb2, $12
	saVol		$0F
	dc.b $06
	saVol		$F1

Dis_Loop12:
	saTranspose	$FC
	sCall		Dis_Call7
	saTranspose	$FF
	sCall		Dis_Call7
	saTranspose	$01
	sCall		Dis_Call7
	saTranspose	$FF
	sCall		Dis_Call7
	saTranspose	$01
	sCall		Dis_Call7
	sCall		Dis_Call7
	sCall		Dis_Call7
	sCall		Dis_Call7
	saTranspose	$04
	sLoop		$00, $02, Dis_Loop12
	saTranspose	$FC
	sCall		Dis_Call7
	saTranspose	$FF
	sCall		Dis_Call7
	saTranspose	$01
	sCall		Dis_Call7
	saTranspose	$FF
	sCall		Dis_Call8
	saTranspose	$05
	sJump		Dis_Loop11

Dis_Call1:
	dc.b nF1, $12, nF2, $06, nRst, $12, nF1, $06
	dc.b nRst, nF1, $06, $0C, $0C, nF2, $06, nRst
	sRet

Dis_Call2:
	dc.b nC2, $12, nC3, $06, nRst, $12, nC2, $06
	dc.b nRst, nC2, $06, $0C, nBb1, nB1
	sRet

Dis_Call3:
	dc.b nRst, $0C, nF1, nRst, $06, nF1, $0C, nE1
	dc.b $06, nRst, $30
	sRet

Dis_Call4:
	dc.b nRst, $18, nG5, nRst, $30
	sLoop		$00, $03, Dis_Call4
	dc.b nRst, $18, nG5, nRst, nG5
	sRet

Dis_Call5:
	sPan		spLeft, $00
	saVol		$05
	sModAMPS	$01, $01, $04, $04
	dc.b nRst, $06, nRst, $18, nG5, nRst, $30, nRst
	dc.b $18, nG5, nRst, $30, nRst, $18, nG5, nRst
	dc.b $30, nRst, $18, nG5, nRst, nG5, $12
	sPan		spCenter, $00
	saVol		$FB
	sModOff
	sRet

Dis_Call6:
	saVol		$0A
	sPan		spLeft, $00
	dc.b $06
	saVol		$F6
	sPan		spCenter, $00
	dc.b nRst, nG3, $06, $06
	sRet

Dis_Call7:
	dc.b nRst, $0C, nE3, $06
	saVol		$0F
	dc.b $06, nRst
	saVol		$F1
	dc.b nE3, $06
	saVol		$0F
	dc.b $06, nRst
	saVol		$F1
	dc.b nE3, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nE3, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nE3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	sRet

Dis_Call8:
	dc.b nRst, $0C, nE3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, nE3
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nE3
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, $2A
	sRet

Dis_Call9:
	dc.b nRst, $0C, nE3, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nE3, $0C, nD3, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, $2A
	sRet

Dis_Call10:
	dc.b nRst, $0C, nC3, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nC3, $0C, nB2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, $2A
	sRet

Dis_Call11:
	dc.b nRst, $0C, nA2, $0C
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nA2, $0C, nAb2, $06
	saVol		$0F
	dc.b $06
	saVol		$F1
	dc.b nRst, $2A
	sRet

Dis_PSG2:
	sModAMPS	$05, $01, $02, $04
	dc.b nRst, $0C

Dis_PSG1:
Dis_Jump4:
	dc.b nRst, $60, nRst, nRst, nRst, $4E, nG3, $06
	dc.b nA3, nB3

Dis_Jump3:
	sCall		Dis_Call12
	dc.b nF4, $0C, nE4, nD4, nC4, $06, nD4, $0C
	dc.b nRst, $06, nE4, $12, nRst, $06, nG3, $0C
	sCall		Dis_Call12
	dc.b nG4, $0C, nA4, nB4, nC5, $18, nE4, $06
	dc.b nRst, nD4, nG3, nA3, nB3
	sCall		Dis_Call12
	dc.b nF4, $0C, nE4, nD4, nC4, $06, nD4, $0C
	dc.b nRst, $06, nE4, $12, nRst, $06, nG3, $0C
	sCall		Dis_Call12
	dc.b nF4, $0C, nE4, nD4, nC4, $06, nD4, nRst
	dc.b $1E, nA3, $06, nC4, nD4, nEb4, $03, sHold
	dc.b nE4, $27, nG4, $1E, nF4, $0C, nE4, nD4
	dc.b $12, nE4, nC4, $24, nRst, $06, nA3, nC4
	dc.b nD4, nEb4, $03, sHold, nE4, $27, nAb4, $12
	dc.b nE4, $0C, nD4, nC4, nD4, $12, nC4, nG4
	dc.b $24, nRst, $06, nA3, nC4, nD4, nEb4, $05
	dc.b sHold, nE4, $25, nG4, $1E, nF4, $0C, nE4
	dc.b nD4, $12, nE4, nC4, $18, nA3, $0C, nB3
	dc.b nC4, nD4, $12, nE4, $4E, nRst, $0C, nG3
	dc.b nAb3, nA3, nC4, nA3, nG4, nF4
	sCall		Dis_Call13
	dc.b nRst, $0C, nG3, nAb3, nA3, nC4, nA3, nG4
	dc.b nF4
	sCall		Dis_Call13
	dc.b nRst, $18, nE4, $3C, nD4, $0C, nC4, $60
	dc.b nRst, $60, nRst, nRst, $4E, nG3, $06, nA3
	dc.b nB3
	sJump		Dis_Jump3

Dis_Call12:
	dc.b nC4, $0C, nG4, $06, nC4, nRst, nC4, nRst
	dc.b nC4
	sLoop		$00, $02, Dis_Call12
	sRet

Dis_Call13:
	dc.b nEb4, $05, sHold, nE4, $1F, nD4, $18, nA3
	dc.b $06, nRst, nG4, $0C, nF4, $06, nRst, nEb4
	dc.b $02, sHold, nE4, $22, nD4, $3C, nRst, $0C
	dc.b nC4, $18, nG4, $06, nRst, nF4, $12, nE4
	dc.b $06, nRst, $0C, nD4, sHold, $06, nRst, nE4
	dc.b nRst, nD4, nE4, nRst, nA3, $12, nG3, $0C
	dc.b nRst, nG3, sHold, $0C, nA3, $06, nRst, nA3
	dc.b $24, nB3, $06, nRst, nRst, nC4, nRst, nD4
	dc.b sHold, $0C, nC4, nD4, nG4, $18, nC4, $06
	dc.b nRst, nD4, $0C, nE4, sHold, $60
	sRet

Dis_PSG3:
	sNoisePSG	snWhitePSG3
	sCall		Dis_Call14
	sCall		Dis_Call15

Dis_Loop15:
	sCall		Dis_Call14
	sLoop		$00, $03, Dis_Loop15
	sCall		Dis_Call15
	sVolEnv		vKc02
	dc.b nHiHat, $0C, nRst, nRst, $06
	sVolEnv		vKc05
	dc.b nHiHat, $0C, $06, sHold, $06, nRst
	sVolEnv		vKc02
	dc.b nHiHat, $06, $06, nRst, nHiHat, $06, $0C, nRst
	dc.b $06, nHiHat, nHiHat, nRst, nRst, $0C, nHiHat, $06
	dc.b $06, nRst
	sVolEnv		vKc05
	dc.b nHiHat, $06
	sVolEnv		vKc02
	dc.b $06, nRst, nHiHat, $0C, $06, $06, nRst, $0C
	sVolEnv		vKc05
	dc.b nHiHat, nRst, $06, nHiHat, $0C, $0C, nRst, $06
	sVolEnv		vKc02
	dc.b nHiHat, $06, $06, nRst, nHiHat, nHiHat, $0C, nRst
	dc.b $06, nHiHat, nHiHat, nRst, nRst, nHiHat, nHiHat
	sVolEnv		vKc05
	dc.b nHiHat
	sVolEnv		vKc02
	dc.b nHiHat, nHiHat, $0C, $06, nRst, $18, nRst, $0C
	sVolEnv		vKc05
	dc.b nHiHat, nRst, $06, nHiHat, $0C, $0C, nRst, $06
	sVolEnv		vKc02
	dc.b nHiHat, $06, $06, nRst, nHiHat, nHiHat, nHiHat, nRst
	dc.b nHiHat, nHiHat, nRst, nRst, nHiHat, nHiHat, nRst, nHiHat
	sVolEnv		vKc05
	dc.b nHiHat
	sVolEnv		vKc02
	dc.b nHiHat, nRst, nHiHat, $0C, $06, $06, nRst, $0C
	sVolEnv		vKc05
	dc.b nHiHat, $0C, nRst, $06, nHiHat, $0C, nHiHat, nRst
	dc.b $2A, nRst, $60
	saVol		$08

Dis_Loop16:
	dc.b nAb6, $0C, $0C, $0C, $0C, $0C, $0C, $0C
	dc.b $0C
	sLoop		$00, $10, Dis_Loop16

Dis_Loop17:
	dc.b nAb6, $0C, $0C, $0C, $0C, $0C, $0C, $0C
	dc.b $0C
	sLoop		$00, $03, Dis_Loop17
	dc.b nAb6, $0C, $0C, $0C, $0C, nRst, $30
	saVol		-$08
	sJump		Dis_Loop15

Dis_Call14:
	sVolEnv		vKc02
	dc.b nHiHat, $0C, $0C, $0C, $0C, $0C
	sVolEnv		vKc05
	dc.b $0C
	sVolEnv		vKc02
	dc.b $0C, $0C, $0C, $0C, $0C, $06, $06, $0C
	sVolEnv		vKc05
	dc.b $0C
	sVolEnv		vKc02
	dc.b $0C
	sVolEnv		vKc05
	dc.b $0C
	sRet

Dis_Call15:
	sVolEnv		vKc02
	dc.b nHiHat, $0C, $0C, $0C, $0C, $0C
	sVolEnv		vKc05
	dc.b $0C
	sVolEnv		vKc02
	dc.b $0C, $0C, $0C, $0C, $0C, $06, $06, nRst
	dc.b $30
	sRet

p81 =	dLowKick
p82 =	dKcSnare
p83 =	dKcTamb
p84 =	dKcCymbal
p85 =	dKcTom
p86 =	dKcLowTom
p87 =	dKcFloorTom
p88 =	dKc87
p89 =	dKcCrash
p96 =	nRst

Dis_DAC1:
	dc.b p81, $18, nRst, $12, p81, $06, nRst, p81	; PWM1		; $180
	dc.b p81, nRst, nRst, $0C, p81, p81, $18, nRst
	dc.b $12, p81, $06, nRst, p81, p81, nRst, nRst
	dc.b $18, p81, $18, nRst, $12, p81, $06, nRst
	dc.b p81, p81, nRst, nRst, $0C, p81
	dc.b p81, $18, nRst, $06, p81, nRst, p81, nRst	; PWM1
	dc.b $18, p81

.loop	sCall		Dis_PWM12_1			; PWM1 and 2	; $120
	dc.b p81, $18, p82, $12, p81, $06, nRst, p81	; PWM1 and 2	; $60
	dc.b p81, nRst, p82, $06, p82, p86, $0C

	sCall		Dis_PWM12_1			; PWM1 and 2	; $120
	dc.b p81, $18, p82, $06, p81, nRst, p81		; PWM1 and 2
	dc.b nRst, $0C, p82, p82, $06, p82, p86, $0C	; PWM2		; $60

.loop1	dc.b nRst, $0C, p81, nRst, $06, p81, nRst, p81	; PWM1		; $C0 * 3 = $240
	dc.b nRst, $30, p81, $18, nRst, $0C, p81, nRst
	dc.b p81, nRst, $06, p81, nRst, p81
	sLoop		$00, $03, .loop1

	dc.b nRst, $0C, p81, nRst, $06, p81, nRst, p81	; PWM1 and 3	; $C0
	dc.b nRst, $18, p87, $0C, p87, p81, $12
	dc.b p83, $06, nRst, $0C, p81, nRst, $06, p83
	dc.b p81, $0C, p81, $18

.loop2	sCall		Dis_PWM12_1			; PWM1 and 2	; $120
	dc.b p81, $18, p82, $12, p81, $06, nRst, p81	; PWM1 and 2	; $60
	dc.b p81, nRst, p82, $06, p82, p86, $0C
	sLoop		$00, $04, .loop2		; $180 * 4 = $600

	dc.b p81, $18, p82, $12, p81, $06, nRst, p81	; PWM1 and 2	; $180
	dc.b p81, nRst, p82, $0C, p81, p81, $18, p82
	dc.b $12, p81, $06, nRst, p81, p81, nRst, p82
	dc.b $18, p81, $18, p82, $12, p81, $06, nRst
	dc.b p81, p81, nRst, p82, $0C, p81
	dc.b p81, $18, p82, $06, p81, nRst, p81, nRst
	dc.b $18, p81
	sJump		.loop				; TOTAL $D80

Dis_DAC2:
	dc.b p96, $18					; PWM 2, 3, and 4?; $180
	dc.b p82, nRst, p82, p96, p82, nRst		; PWM 2 and 4 occasionally
	dc.b p82, p96, p82, nRst, p82, p96, p82, nRst
	dc.b p82

.loop	dc.b p89, $0C					; PWM3
	saVol		$0A
	dc.b p88					; PWM4
	sCall		Dis_PWM4_1			; PWM4		; $C0
	sCall		Dis_PWM4_2			; PWM4		; $C0
	sCall		Dis_PWM4_2			; PWM4		; $C0

.loop1	dc.b nRst, $0C, p88				; PWM4
	sLoop		$00, $05, .loop1

	dc.b nRst, p88, $06, $06, nRst, $30		; PWM4		; $C0
	saVol		-$0A
; $300
	dc.b p96, $0C, p89, $3C				; PWM2, 3 and 4	; $C0
	dc.b p82, $18, p96, p82, nRst, p82
	dc.b p96, $48, p82, $18, p96, p82, nRst		; PWM2 and 4	; $C0
	dc.b p82, $06, p85, p86, p87
	dc.b p96, $48, p82, $18, p96, $0C, p82		; PWM2 and 4	; $C0
	dc.b p82, $18, nRst, p82
	dc.b p96, $3C, p87, $04, p87, p87		; PWM2 and 4	; $C0
	dc.b p82, $0C, p82
	dc.b p96, $48, p82, $06, p82, p82, p82
; now at $600

.loop2	sCall		Dis_PWM4_3			; PWM3 and 4
	dc.b $06, $0C, $06, $06, $06, $06		; $180 * 4 = $600
	sLoop		$00, $04, .loop2

	sCall		Dis_PWM4_3			; PWM4		; $180
	dc.b sHold, nRst, $30-6
	sJump		.loop				; TOTAL $D80

Dis_PWM12_1:
	dc.b p81, $18, p82, $12, p81, $06, nRst, p81
	dc.b p81, nRst, p82, $0C, p81, p81, $18, p82
	dc.b $12, p81, $06, nRst, p81, p81, nRst, p82
	dc.b $18, p81, $18, p82, $12, p81, $06, nRst
	dc.b p81, p81, nRst, p82, $0C, p81
	sRet

Dis_PWM4_2:
	dc.b nRst, $0C, p88

Dis_PWM4_1:
	dc.b nRst, p88
	sLoop		$00, $06, Dis_PWM4_1
	dc.b sHold, $0C, p88, $06, $06
	sRet

Dis_PWM4_3:
	dc.b p89, $12, p84, $0C, $06, $0C, $0C, $0C
	dc.b $0C, $0C, $0C, $06, $0C, $06, $0C, $0C
	dc.b $0C, $0C, $06, $0C, $0C, $06, $0C, $06
	dc.b $0C, $06, $0C, $06, $0C, $0C, $0C, $06
	dc.b $0C, $06, $0C
	sRet
