; ---------------------------------------------------------------------------
; Sprite mappings - extra boss items (e.g. swinging ball on a chain in GHZ)
; ---------------------------------------------------------------------------
		dc.w byte_17DE4-Map_BossItems, byte_17DEA-Map_BossItems
		dc.w byte_17DF6-Map_BossItems, byte_17DFC-Map_BossItems
		dc.w byte_17E02-Map_BossItems, byte_17E08-Map_BossItems
		dc.w byte_17E1E-Map_BossItems, byte_17E2A-Map_BossItems
byte_17DE4:	dc.b 1
		dc.b $F8, 5, 0,	0, $F8
byte_17DEA:	dc.b 2
		dc.b $FC, 4, 0,	4, $F8
		dc.b $F8, 5, 0,	0, $F8
		dc.b 0
byte_17DF6:	dc.b 1
		dc.b $FC, 0, 0,	6, $FC
byte_17DFC:	dc.b 1
		dc.b $14, 9, 0,	7, $F4
byte_17E02:	dc.b 1
		dc.b $14, 5, 0,	$D, $F8
byte_17E08:	dc.b 4
		dc.b $F0, 4, 0,	$11, $F8
		dc.b $F8, 1, 0,	$13, $F8
		dc.b $F8, 1, 8,	$13, 0
		dc.b 8,	4, 0, $15, $F8
		dc.b 0
byte_17E1E:	dc.b 2
		dc.b 0,	5, 0, $17, 0
		dc.b 0,	0, 0, $1B, $10
		dc.b 0
byte_17E2A:	dc.b 2
		dc.b $18, 4, 0,	$1C, 0
		dc.b 0,	$B, 0, $1E, $10
		even