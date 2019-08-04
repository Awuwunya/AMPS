	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, $80, .PSG1, $F4, $00

.PSG1	sVoice		v00
	dc.b nF2, $05
	ssMod68k	$02, $01, $F8, $65
	dc.b nBb2, $15
	sStop
