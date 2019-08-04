	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $0C, $00

.FM5	sVoice		$09
	dc.b nRst, $01, nBb2, $05, sHold, nB2, $26
	sStop
