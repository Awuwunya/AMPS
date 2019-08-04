	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM4, .FM4, $00, $05

.FM4	sPan	spLeft

SFX_Ring1:
	sVoice	$0F
	dc.b nE5, $04, nG5, $05, nC6, $1B
	sStop
