	sHeaderInit
	sHeaderPrio	$81
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $0E, $00

.FM5	sVoice		$20
	ssMod68k	$01, $01, $33, $18
	dc.b nAb4, $1A
	sStop
