	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, $C0, .PSG3, $00, $00

.PSG3:
	sVoice		v00
	sNoisePSG	$E7
	dc.b nA5, $03, nRst, $03, nA5, $01, sHold

.Loop	dc.b $01
	saVol		$01
	dc.b sHold
	sLoop		$00, $15, .Loop
	sStop
