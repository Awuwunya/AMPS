	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, $C0, .PSG3, $00, $00

.PSG3	ssMod68k	$01, $01, $F0, $08
	sNoisePSG	$E7
	dc.b nEb5, $04, nEb5, $04	; second one was nCs6. WTF Sonic Team?

.Loop	dc.b nEb5, $01
	saVol		$01
	sLoop		$00, $06, .Loop
	sStop
