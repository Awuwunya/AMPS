	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $F4, $00

.FM5	sVoice		$12
	dc.b nD2, $04, nRst, nG2, $06
	sStop

