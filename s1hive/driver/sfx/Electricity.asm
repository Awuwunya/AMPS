	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $FB, $02

.FM5	sVoice		$0B
	dc.b nD4, $05, nRst, $01, nD4, $09
	sStop
