	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM4, .FM4, $00, $06

.FM4	sVoice		$04
.loop	dc.b nD1, $07, nRst, $02, nD1, $06, nRst, $10
	sCont		.loop
	sStop
