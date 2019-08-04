	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $00, $03

.FM5	sVoice		$18
	dc.b nG1, $05, nRst, $05, nG1, $04, nRst, $04
	sStop
