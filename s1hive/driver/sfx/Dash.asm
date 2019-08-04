	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$02
	sHeaderSFX	$80, ctFM5, .FM5, $90, $00
	sHeaderSFX	$A1, ctPSG3, .PSG3, $00, $00

.FM5	sVoice		$13
	ssMod68k	$01, $01, $C5, $1A
	dc.b nE6, $07
	sStop

.PSG3	sVolEnv		v07
	dc.b nRst, $07
	ssMod68k	$01, $02, $05, $FF
	sNoisePSG	$E7
	dc.b nBb4, $4F
	sStop
