	sHeaderInit
	sHeaderPrio	$78
	sHeaderCh	$01
	sHeaderSFX	$A1, ctPSG2, .PSG2, $00, $00

.PSG2	ssMod68k	$01, $01, $E6, $35
	dc.b nCs1, $06
	sStop
