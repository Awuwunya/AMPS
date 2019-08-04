	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $00, $00

.FM5	sVoice		$06
	ssMod68k	$01, $01, $0C, $01

.Loop	dc.b nC0, $0A
	saVol		$10
	sLoop		$00, $04, .Loop
	sStop
