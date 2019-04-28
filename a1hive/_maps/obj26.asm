; ---------------------------------------------------------------------------
; Sprite mappings - monitors
; ---------------------------------------------------------------------------
		dc.w byte_A5A2-Map_obj26, byte_A5A8-Map_obj26
		dc.w byte_A5B3-Map_obj26, byte_A5BE-Map_obj26
		dc.w byte_A5C9-Map_obj26, byte_A5D4-Map_obj26
		dc.w byte_A5DF-Map_obj26, byte_A5EA-Map_obj26
		dc.w byte_A5F5-Map_obj26, byte_A600-Map_obj26
		dc.w byte_A60B-Map_obj26, byte_A616-Map_obj26
byte_A5A2:	dc.b 1			; static monitor
		dc.b $EF, $F, 0, 0, $F0
byte_A5A8:	dc.b 2			; static monitor
		dc.b $F5, 5, 0,	$10, $F8
		dc.b $EF, $F, 0, 0, $F0
byte_A5B3:	dc.b 2			; static monitor
		dc.b $F5, 5, 0,	$14, $F8
		dc.b $EF, $F, 0, 0, $F0
byte_A5BE:	dc.b 2			; Eggman monitor
		dc.b $F5, 5, 0,	$18, $F8
		dc.b $EF, $F, 0, 0, $F0
byte_A5C9:	dc.b 2			; Sonic	monitor
		dc.b $F5, 5, 0,	$1C, $F8
		dc.b $EF, $F, 0, 0, $F0
byte_A5D4:	dc.b 2			; speed	shoes monitor
		dc.b $F5, 5, 0,	$24, $F8
		dc.b $EF, $F, 0, 0, $F0
byte_A5DF:	dc.b 2			; shield monitor
		dc.b $F5, 5, 0,	$28, $F8
		dc.b $EF, $F, 0, 0, $F0
byte_A5EA:	dc.b 2			; invincibility	monitor
		dc.b $F5, 5, 0,	$2C, $F8
		dc.b $EF, $F, 0, 0, $F0
byte_A5F5:	dc.b 2			; 10 rings monitor
		dc.b $F5, 5, 0,	$30, $F8
		dc.b $EF, $F, 0, 0, $F0
byte_A600:	dc.b 2			; 'S' monitor
byte_A601:	dc.b $F5, 5, 0,	$34, $F8
		dc.b $EF, $F, 0, 0, $F0
byte_A60B:	dc.b 2			; goggles monitor
		dc.b $F5, 5, 0,	$20, $F8
		dc.b $EF, $F, 0, 0, $F0
byte_A616:	dc.b 1			; broken monitor
		dc.b $FF, $D, 0, $38, $F0
		even