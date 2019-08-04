	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $F2, $00

.FM5	sVoice		$03
	ssMod68k	$01, $01, $10, $FF
	dc.b nFs6, $05, nD7, $25
	sStop
