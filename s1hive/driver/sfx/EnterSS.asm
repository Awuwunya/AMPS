	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $00, $02

.FM5	sVoice		$21
	ssMod68k	$01, $01, $5B, $02
	dc.b nEb6, $65
	sStop
