; ---------------------------------------------------------------------------
; Sprite mappings - signpost
; ---------------------------------------------------------------------------
		dc.w byte_ED42-Map_obj0D, byte_ED52-Map_obj0D
		dc.w byte_ED5D-Map_obj0D, byte_ED68-Map_obj0D
		dc.w byte_ED73-Map_obj0D
byte_ED42:	dc.b 3
		dc.b $F0, $B, 0, 0, $E8
		dc.b $F0, $B, 8, 0, 0
		dc.b $10, 1, 0,	$38, $FC
byte_ED52:	dc.b 2
		dc.b $F0, $F, 0, $C, $F0
		dc.b $10, 1, 0,	$38, $FC
byte_ED5D:	dc.b 2
		dc.b $F0, 3, 0,	$1C, $FC
		dc.b $10, 1, 8,	$38, $FC
byte_ED68:	dc.b 2
		dc.b $F0, $F, 8, $C, $F0
		dc.b $10, 1, 8,	$38, $FC
byte_ED73:	dc.b 3
		dc.b $F0, $B, 0, $20, $E8
		dc.b $F0, $B, 0, $2C, 0
		dc.b $10, 1, 0,	$38, $FC
		even