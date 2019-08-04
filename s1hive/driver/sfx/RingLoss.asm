	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$02
	sHeaderSFX	$80, ctFM4, .FM4, $00, $05
	sHeaderSFX	$80, ctFM5, .FM5, $00, $08

.FM4	sVoice		$0F
	dc.b nA5, $02, $05, $05, $05, $05, $05, $05
	dc.b $3A
	sStop

.FM5	sVoice		$0F
	dc.b nRst, $02, nG5, $02, $05, $15, $02, $05
	dc.b $32
	sStop
