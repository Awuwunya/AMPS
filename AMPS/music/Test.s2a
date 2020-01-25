	sHeaderInit
	sHeaderTempo	$41, $00
	sHeaderCh	$01, $00
	sHeaderDAC	Test_DAC1
	sHeaderDAC	Test_DAC2
	sHeaderFM	Test_FM1, $00, $0C

	spAlgorithm	$04, Jousi
	spFeedback	$05
	spDetune	$07, $00, $07, $00
	spMultiple	$02, $04, $05, $04
	spRateScale	$00, $00, $00, $00
	spAttackRt	$1F, $1F, $12, $12
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$00, $00, $0A, $0A
	spSustainLv	$00, $00, $01, $01
	spDecayRt	$00, $00, $00, $00
	spReleaseRt	$00, $00, $06, $06
	spSSGEG		$00, $00, $00, $00
	spTotalLv	$16, $17, $00, $00
; ===========================================================================
; ---------------------------------------------------------------------------
; FM5 data
; ---------------------------------------------------------------------------

Test_FM1:
	sVoice		pJousi
	sVolEnv		vS2_0B
	sModEnv		mTest

.loop
	ssLFO		$E8, $f2
;	ssPortamento	$2A
	dc.b nC2, $30, sHold
;	ssPortamento	$0C
;	dc.b nC3, nC4
;	ssPortamento	$2A
;	dc.b nF2, $24
;	ssPortamento	$27
;	dc.b nF3, nF4
;	ssPortamento	$12
;	dc.b nB2, $16
;	ssPortamento	$04
;	dc.b nB3, nB4
	sJump		.loop

; ===========================================================================
; ---------------------------------------------------------------------------
; DAC2 data
; ---------------------------------------------------------------------------

Test_DAC1:
	sVoice		dMeow
	sModePitchDAC
	dc.b $B1, $60

.loop
	dc.b sHold, $60
	sJump	.loop

Test_DAC2:
	sStop
