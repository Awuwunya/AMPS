	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $00, $01

.FM5	sVoice		$00
	dc.b nC5, $06, nA4, $16
	sStop
