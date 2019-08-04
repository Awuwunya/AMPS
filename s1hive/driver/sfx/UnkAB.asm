	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$A1, ctPSG2, .PSG3, $00, $00

.PSG3:
	sVolEnv		v00
	sNoisePSG	$E7
	dc.b nA5, $03, nRst, $03, nA5, $01, sHold

.Loop	dc.b $01
	saVol		$08
	dc.b sHold
	sLoop		$00, $15, .Loop
	sStop
