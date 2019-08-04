	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$02
	sHeaderSFX	$80, ctFM5, .FM5, $10, $0A
	sHeaderSFX	$80, ctFM4, .FM4, $00, $00

.FM5	sVoice		$14
	ssMod68k	$01, $01, $60, $01
	dc.b nD3, $08
	sStop

.FM4	dc.b nRst, $08
	sVoice		$15
	dc.b nEb0, $22
	sStop
