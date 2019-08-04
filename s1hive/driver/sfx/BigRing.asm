	sHeaderInit
	sHeaderPrio	$82
	sHeaderCh	$02
	sHeaderSFX	$80, ctFM4, .FM4, $0C, $00
	sHeaderSFX	$80, ctFM5, .FM5, $00, $13

.FM4	sVoice		$1B
	dc.b nRst, $01, nA2, $08
	sVoice		$1A
	dc.b sHold, nAb3, $26
	sStop

.FM5	sVoice		$1C
	ssMod68k	$06, $01, $03, $FF
	dc.b nRst, $0A

.Loop	dc.b nFs5, $06
	sLoop		$00, $05, .Loop
	dc.b nFs5, $17
	sStop
