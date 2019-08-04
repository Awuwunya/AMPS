	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, $C0, .PSG3, $00, $00

.PSG3	ssMod68k	$01, $01, $F0, $08
	sNoisePSG	$E7
	dc.b nEb4, $08

.Loop	dc.b nB3, $02
	saVol		$01
	sLoop		$00, $03, .Loop
	sStop
