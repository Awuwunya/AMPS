	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$02
	sHeaderSFX	$80, ctFM5, .FM5, $00, $00
	sHeaderSFX	$A1, ctPSG3, .PSG3, $00, $00

.FM5	sVoice		$06
	ssMod68k	$03, $01, $20, $04

.Loop2	dc.b nC0, $18
	saVol		$0A
	sLoop		$00, $06, .Loop2
	sStop

.PSG3	ssMod68k	$01, $01, $0F, $05
	sNoisePSG	$E7

.Loop1	dc.b nB3, $18, sHold
	saVol		$18
	sLoop		$00, $05, .Loop1
	sStop
