soundCC_Header:
	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM4, .FM4, $00, $02

.FM4	sVoice		$22
	dc.b nRst, $01
	ssMod68k	$03, $01, $5D, $0F
	dc.b nB3, $0C
	sModOff

.Loop	dc.b sHold
	saVol		$02
	dc.b nC5, $02
	sLoop		$00, $19, .Loop
	sStop
