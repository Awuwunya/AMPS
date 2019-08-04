	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $00, $00

.FM5	sVoice		$02
	dc.b nRst, $01, nBb0, $0A, nRst, $02
	sStop
