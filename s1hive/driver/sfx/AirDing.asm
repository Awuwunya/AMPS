	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $0C, $08

.FM5	sVoice		$17
	dc.b nA4, $08, nA4, $25
	sStop
