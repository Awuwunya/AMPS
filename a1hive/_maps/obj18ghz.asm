; ---------------------------------------------------------------------------
; Sprite mappings - GHZ	platforms
; ---------------------------------------------------------------------------
		dc.w byte_8140-Map_obj18
		dc.w byte_8155-Map_obj18
byte_8140:	dc.b 4
		dc.b $F4, $B, 0, $3B, $E0 ; small platform
		dc.b $F4, 7, 0,	$3F, $F8
		dc.b $F4, 7, 0,	$3F, 8
		dc.b $F4, 3, 0,	$47, $18
byte_8155:	dc.b $A
		dc.b $F4, $F, 0, $C5, $E0 ; large column platform
		dc.b 4,	$F, 0, $D5, $E0
		dc.b $24, $F, 0, $D5, $E0
		dc.b $44, $F, 0, $D5, $E0
		dc.b $64, $F, 0, $D5, $E0
		dc.b $F4, $F, 8, $C5, 0
		dc.b 4,	$F, 8, $D5, 0
		dc.b $24, $F, 8, $D5, 0
		dc.b $44, $F, 8, $D5, 0
		dc.b $64, $F, 8, $D5, 0
		even