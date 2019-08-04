	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$03
	sHeaderSFX	$80, ctFM5, .FM5, $00, $00
	sHeaderSFX	$80, ctFM4, .FM4, $00, $00
	sHeaderSFX	$80, ctFM3, .FM3, $00, $02

.FM5	sVoice		$0D
	sJump		.Jump

.FM4	sVoice		$00
	saDetune	$07
	dc.b nRst, $01

.Jump	dc.b nA4, $20
	sStop

.FM3	sVoice		$0E
	dc.b nCs2, $03
	sStop
