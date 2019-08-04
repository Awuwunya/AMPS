	sHeaderInit
	sHeaderPrio	$80
	sHeaderCh	$03
	sHeaderSFX	$80, ctFM3, .FM3, $F4, $06
	sHeaderSFX	$80, ctFM4, .FM4, $F4, $06
	sHeaderSFX	$80, ctFM5, .FM5, $F4, $06

.FM3	sVoice		$17
	dc.b nC6, $07, nE6, nG6, nD6, nF6, nA6, nE6
	dc.b nG6, nB6, nF6, nA6, nC7

.Loop3	dc.b nG6, $07, nB6, nD7
	saVol		$05
	sLoop		$00, $08, .Loop3
	sStop

.FM4	sVoice		$17
	saDetune	$01
	dc.b nRst, $07, nE6, $15, nF6, nG6, nA6

.Loop2	dc.b nB6, $15
	saVol		$05
	sLoop		$00, $08, .Loop2
	sStop

.FM5	sVoice		$17
	saDetune	$01
	dc.b nC6, $15, nD6, nE6, nF6

.Loop1	dc.b nG6, $15
	saVol		$05
	sLoop		$00, $08, .Loop1
	sStop
