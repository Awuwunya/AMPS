	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $F4, $00

.FM5	sVoice		$01
	dc.b nB3, $07, sHold, nAb3

.loop	dc.b $01
	saVol		$01
	sLoop		$00, $2F, .loop
	sStop
