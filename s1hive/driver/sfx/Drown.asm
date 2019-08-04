	sHeaderInit
	sHeaderPrio	$81
	sHeaderCh	$02
	sHeaderSFX	$80, ctFM4, .FM4, $0C, $04
	sHeaderSFX	$80, ctFM5, .FM5, $0E, $02

.FM5	sVoice		$0C
	ssMod68k	$01, $01, $83, $0C

.Loop2	dc.b nA0, $05, $05
	saVol		$03
	sLoop		$00, $0A, .Loop2
	sStop

.FM4	dc.b nRst, $06
	sVoice		$0C
	ssMod68k	$01, $01, $6F, $0E

.Loop1	dc.b nC1, $04, $05
	saVol		$03
	sLoop		$00, $0A, .Loop1
	sStop
