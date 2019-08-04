; ---------------------------------------------------------------------------
; Sprite mappings - walking bomb enemy (SLZ, SBZ)
; ---------------------------------------------------------------------------
		dc.w byte_11C40-Map_obj5F, byte_11C50-Map_obj5F
		dc.w byte_11C60-Map_obj5F, byte_11C70-Map_obj5F
		dc.w byte_11C80-Map_obj5F, byte_11C90-Map_obj5F
		dc.w byte_11CA0-Map_obj5F, byte_11CAB-Map_obj5F
		dc.w byte_11CB6-Map_obj5F, byte_11CBC-Map_obj5F
		dc.w byte_11CC2-Map_obj5F, byte_11CC8-Map_obj5F
byte_11C40:	dc.b 3
		dc.b $F1, $A, 0, 0, $F4
		dc.b 9,	8, 0, $12, $F4
		dc.b $E7, 1, 0,	$21, $FC
byte_11C50:	dc.b 3
		dc.b $F1, $A, 0, 9, $F4
		dc.b 9,	8, 0, $12, $F4
		dc.b $E7, 1, 0,	$21, $FC
byte_11C60:	dc.b 3
		dc.b $F0, $A, 0, 0, $F4
		dc.b 8,	8, 0, $15, $F4
		dc.b $E6, 1, 0,	$21, $FC
byte_11C70:	dc.b 3
		dc.b $F1, $A, 0, 9, $F4
		dc.b 9,	8, 0, $18, $F4
		dc.b $E7, 1, 0,	$21, $FC
byte_11C80:	dc.b 3
		dc.b $F0, $A, 0, 0, $F4
		dc.b 8,	8, 0, $1B, $F4
		dc.b $E6, 1, 0,	$21, $FC
byte_11C90:	dc.b 3
		dc.b $F1, $A, 0, 9, $F4
		dc.b 9,	8, 0, $1E, $F4
		dc.b $E7, 1, 0,	$21, $FC
byte_11CA0:	dc.b 2
		dc.b $F1, $A, 0, 0, $F4
		dc.b 9,	8, 0, $12, $F4
byte_11CAB:	dc.b 2
		dc.b $F1, $A, 0, 9, $F4
		dc.b 9,	8, 0, $12, $F4
byte_11CB6:	dc.b 1			; fuse	(just before it	explodes)
		dc.b $E7, 1, 0,	$23, $FC
byte_11CBC:	dc.b 1			; fuse
		dc.b $E7, 1, 0,	$25, $FC
byte_11CC2:	dc.b 1			; fireball (after it exploded)
		dc.b $FC, 0, 0,	$27, $FC
byte_11CC8:	dc.b 1			; fireball
		dc.b $FC, 0, 0,	$28, $FC
		even