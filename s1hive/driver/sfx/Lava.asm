	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$A1, ctPSG3, .PSG3, $00, $00

.PSG3:	sVolEnv		v00
	sNoisePSG	$E7
	dc.b nD3, $25
	sStop
