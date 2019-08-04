; ---------------------------------------------------------------------------
; Animation script - Crabmeat enemy
; ---------------------------------------------------------------------------
		dc.w byte_972A-Ani_obj1F, byte_972E-Ani_obj1F, byte_9732-Ani_obj1F
		dc.w byte_9736-Ani_obj1F, byte_973C-Ani_obj1F, byte_9742-Ani_obj1F
		dc.w byte_9748-Ani_obj1F, byte_974C-Ani_obj1F
byte_972A:	dc.b $F, 0, $FF, 0
byte_972E:	dc.b $F, 2, $FF, 0
byte_9732:	dc.b $F, $22, $FF, 0
byte_9736:	dc.b $F, 1, $21, 0, $FF, 0
byte_973C:	dc.b $F, $21, 3, 2, $FF, 0
byte_9742:	dc.b $F, 1, $23, $22, $FF, 0
byte_9748:	dc.b $F, 4, $FF, 0
byte_974C:	dc.b 1,	5, 6, $FF
		even