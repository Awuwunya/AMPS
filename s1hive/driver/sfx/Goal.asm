	sHeaderInit
	sHeaderPrio	$70
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM5, .FM5, $F2, $04

.FM5	sVoice		$03
	dc.b nCs3

.Loop	dc.b $02, sHold, nB2, $01, sHold
	saTranspose	$02
	sLoop		$00, $25, .Loop
	dc.b $02, sHold, nBb2, $01	; <- would be invalid note ffs
	sStop
