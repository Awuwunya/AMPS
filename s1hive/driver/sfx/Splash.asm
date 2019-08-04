	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$02
	sHeaderSFX	$80, $C0, .PSG3, $00, $00
	sHeaderSFX	$80, $05, .FM5, $00, $03

.PSG3	sVoice		v00
	sNoisePSG	$E7
	dc.b nF5, $05, nA5, $05, sHold

.Loop1	dc.b $07
	saVol		$01
	dc.b sHold
	sLoop		$00, $0F, .Loop1
	sStop

.FM5	sVoice		$05
	dc.b nCs3, $14
	sStop
