	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, $C0, .PSG3, $00, $00

.PSG3:	sVoice		v00
	sNoisePSG	$E7
	dc.b nD3, $25
	sStop
