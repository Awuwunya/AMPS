; ---------------------------------------------------------------------------
; Sprite mappings - prison capsule
; ---------------------------------------------------------------------------
		dc.w byte_1AD82-Map_obj3E, byte_1ADA6-Map_obj3E
		dc.w byte_1ADAC-Map_obj3E, byte_1ADCB-Map_obj3E
		dc.w byte_1ADD1-Map_obj3E, byte_1ADDC-Map_obj3E
		dc.w byte_1ADE2-Map_obj3E
byte_1AD82:	dc.b 7
		dc.b $E0, $C, $20, 0, $F0
		dc.b $E8, $D, $20, 4, $E0
		dc.b $E8, $D, $20, $C, 0
		dc.b $F8, $E, $20, $14,	$E0
		dc.b $F8, $E, $20, $20,	0
		dc.b $10, $D, $20, $2C,	$E0
		dc.b $10, $D, $20, $34,	0
byte_1ADA6:	dc.b 1
		dc.b $F8, 9, 0,	$3C, $F4
byte_1ADAC:	dc.b 6
		dc.b 0,	8, $20,	$42, $E0
		dc.b 8,	$C, $20, $45, $E0
		dc.b 0,	4, $20,	$49, $10
		dc.b 8,	$C, $20, $4B, 0
		dc.b $10, $D, $20, $2C,	$E0
		dc.b $10, $D, $20, $34,	0
byte_1ADCB:	dc.b 1
		dc.b $F8, 9, 0,	$4F, $F4
byte_1ADD1:	dc.b 2
		dc.b $E8, $E, $20, $55,	$F0
		dc.b 0,	$E, $20, $61, $F0
byte_1ADDC:	dc.b 1
		dc.b $F0, 7, $20, $6D, $F8
byte_1ADE2:	dc.b 0
		even