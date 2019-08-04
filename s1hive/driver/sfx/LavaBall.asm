	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$02
	sHeaderSFX	$80, ctFM5, .FM5, $00, $00
	sHeaderSFX	$A1, ctPSG3, .PSG3, $00, $00

.FM5	sVoice		$08
	dc.b nRst, $01
	ssMod68k	$01, $01, $40, $48
	dc.b nD0, $06, nE0, $02
	sStop

.PSG3	sVolEnv		v00
	dc.b nRst, $0B
	sNoisePSG	$E7
	dc.b nA5, $01, sHold

.Loop	dc.b $02
	saVol		$08
	dc.b sHold
	sLoop		$00, $10, .Loop
	sStop
