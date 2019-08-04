; ---------------------------------------------------------------------------
; Animation script - Bomb enemy
; ---------------------------------------------------------------------------
		dc.w byte_11C12-Ani_obj5F
		dc.w byte_11C16-Ani_obj5F
		dc.w byte_11C1C-Ani_obj5F
		dc.w byte_11C20-Ani_obj5F
		dc.w byte_11C24-Ani_obj5F
byte_11C12:	dc.b $13, 1, 0,	$FF
byte_11C16:	dc.b $13, 5, 4,	3, 2, $FF
byte_11C1C:	dc.b $13, 7, 6,	$FF
byte_11C20:	dc.b 3,	8, 9, $FF
byte_11C24:	dc.b 3,	$A, $B,	$FF
		even