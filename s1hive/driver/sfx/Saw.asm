	sHeaderInit
	sHeaderPrio	$80
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $FB, $05

.FM5	sVoice		$0A
	dc.b nBb7, $7F

.Loop	dc.b nBb7, $02
	saVol		$01
	sLoop		$00, $1B, .Loop
	sStop
