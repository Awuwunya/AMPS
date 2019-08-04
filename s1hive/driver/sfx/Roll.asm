	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM4, .FM4, $0C, $05

.FM4	sVoice		$16
	dc.b nRst, $01
	ssMod68k	$03, $01, $09, $FF
	dc.b nCs6, $25
	sModOff

.Loop1	saVol		$01
	dc.b sHold, nG6, $02
	sLoop		$00, $2A, .Loop1
	sStop
