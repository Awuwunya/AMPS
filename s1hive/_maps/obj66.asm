; ---------------------------------------------------------------------------
; Sprite mappings - rotating disc that grabs Sonic (SBZ)
; ---------------------------------------------------------------------------
		dc.w byte_152B4-Map_obj66, byte_152D3-Map_obj66
		dc.w byte_152F2-Map_obj66, byte_15311-Map_obj66
		dc.w byte_15330-Map_obj66, byte_1534F-Map_obj66
		dc.w byte_1536E-Map_obj66, byte_1538D-Map_obj66
		dc.w byte_153AC-Map_obj66, byte_153CB-Map_obj66
		dc.w byte_153EA-Map_obj66, byte_15409-Map_obj66
		dc.w byte_15428-Map_obj66, byte_15447-Map_obj66
		dc.w byte_15466-Map_obj66, byte_15485-Map_obj66
		dc.w byte_154A4-Map_obj66
byte_152B4:	dc.b 6
		dc.b $E8, 5, 0,	$22, $D0
		dc.b 8,	5, $10,	$22, $D0
		dc.b $E8, $A, 0, 0, $C8
		dc.b $E8, $A, 8, 0, $E0
		dc.b 0,	$A, $10, 0, $C8
		dc.b 0,	$A, $18, 0, $E0
byte_152D3:	dc.b 6
		dc.b $F8, 3, 0,	$26, $D0
		dc.b $18, 5, 0,	$2A, $D8
		dc.b $F6, $A, 0, 0, $CA
		dc.b $F6, $A, 8, 0, $E2
		dc.b $E, $A, $10, 0, $CA
		dc.b $E, $A, $18, 0, $E2
byte_152F2:	dc.b 6
		dc.b 0,	6, 0, $2E, $D0
		dc.b $20, 9, 0,	$34, $E8
		dc.b 0,	$A, 0, 0, $D0
		dc.b 0,	$A, 8, 0, $E8
		dc.b $18, $A, $10, 0, $D0
		dc.b $18, $A, $18, 0, $E8
byte_15311:	dc.b 6
		dc.b 8,	7, 0, $3A, $D8
		dc.b $28, 8, 0,	$42, $F0
		dc.b 6,	$A, 0, 0, $DA
		dc.b 6,	$A, 8, 0, $F2
		dc.b $1E, $A, $10, 0, $DA
		dc.b $1E, $A, $18, 0, $F2
byte_15330:	dc.b 6
		dc.b $20, 5, 0,	$45, $E8
		dc.b $20, 5, 8,	$45, 8
		dc.b 8,	$A, 0, 0, $E8
		dc.b 8,	$A, 8, 0, 0
		dc.b $20, $A, $10, 0, $E8
		dc.b $20, $A, $18, 0, 0
byte_1534F:	dc.b 6
		dc.b $28, 8, 8,	$42, $F8
		dc.b 8,	7, 8, $3A, $18
		dc.b 6,	$A, 0, 0, $F6
		dc.b 6,	$A, 8, 0, $E
		dc.b $1E, $A, $10, 0, $F6
		dc.b $1E, $A, $18, 0, $E
byte_1536E:	dc.b 6
		dc.b $20, 9, 8,	$34, 0
		dc.b 0,	6, 8, $2E, $20
		dc.b 0,	$A, 0, 0, 0
		dc.b 0,	$A, 8, 0, $18
		dc.b $18, $A, $10, 0, 0
		dc.b $18, $A, $18, 0, $18
byte_1538D:	dc.b 6
		dc.b $18, 5, 8,	$2A, $18
		dc.b $F8, 3, 8,	$26, $28
		dc.b $F6, $A, 0, 0, 6
		dc.b $F6, $A, 8, 0, $1E
		dc.b $E, $A, $10, 0, 6
		dc.b $E, $A, $18, 0, $1E
byte_153AC:	dc.b 6
		dc.b $E8, 5, 8,	$22, $20
		dc.b 8,	5, $18,	$22, $20
		dc.b $E8, $A, 0, 0, 8
		dc.b $E8, $A, 8, 0, $20
		dc.b 0,	$A, $10, 0, 8
		dc.b 0,	$A, $18, 0, $20
byte_153CB:	dc.b 6
		dc.b $D8, 5, $18, $2A, $18
		dc.b $E8, 3, $18, $26, $28
		dc.b $DA, $A, 0, 0, 6
		dc.b $DA, $A, 8, 0, $1E
		dc.b $F2, $A, $10, 0, 6
		dc.b $F2, $A, $18, 0, $1E
byte_153EA:	dc.b 6
		dc.b $D0, 9, $18, $34, 0
		dc.b $E8, 6, $18, $2E, $20
		dc.b $D0, $A, 0, 0, 0
		dc.b $D0, $A, 8, 0, $18
		dc.b $E8, $A, $10, 0, 0
		dc.b $E8, $A, $18, 0, $18
byte_15409:	dc.b 6
		dc.b $D0, 8, $18, $42, $F8
		dc.b $D8, 7, $18, $3A, $18
		dc.b $CA, $A, 0, 0, $F6
		dc.b $CA, $A, 8, 0, $E
		dc.b $E2, $A, $10, 0, $F6
		dc.b $E2, $A, $18, 0, $E
byte_15428:	dc.b 6
		dc.b $D0, 5, $10, $45, $E8
		dc.b $D0, 5, $18, $45, 8
		dc.b $C8, $A, 0, 0, $E8
		dc.b $C8, $A, 8, 0, 0
		dc.b $E0, $A, $10, 0, $E8
		dc.b $E0, $A, $18, 0, 0
byte_15447:	dc.b 6
		dc.b $D8, 7, $10, $3A, $D8
		dc.b $D0, 8, $10, $42, $F0
		dc.b $CA, $A, 0, 0, $DA
		dc.b $CA, $A, 8, 0, $F2
		dc.b $E2, $A, $10, 0, $DA
		dc.b $E2, $A, $18, 0, $F2
byte_15466:	dc.b 6
		dc.b $E8, 6, $10, $2E, $D0
		dc.b $D0, 9, $10, $34, $E8
		dc.b $D0, $A, 0, 0, $D0
		dc.b $D0, $A, 8, 0, $E8
		dc.b $E8, $A, $10, 0, $D0
		dc.b $E8, $A, $18, 0, $E8
byte_15485:	dc.b 6
		dc.b $E8, 3, $10, $26, $D0
		dc.b $D8, 5, $10, $2A, $D8
		dc.b $DA, $A, 0, 0, $CA
		dc.b $DA, $A, 8, 0, $E2
		dc.b $F2, $A, $10, 0, $CA
		dc.b $F2, $A, $18, 0, $E2
byte_154A4:	dc.b $C
		dc.b $C8, $D, 0, 9, $E0
		dc.b $D0, $A, 0, $11, $D0
		dc.b $E0, 7, 0,	$1A, $C8
		dc.b $C8, $D, 8, 9, 0
		dc.b $D0, $A, 8, $11, $18
		dc.b $E0, 7, 8,	$1A, $28
		dc.b 0,	7, $10,	$1A, $C8
		dc.b $18, $A, $10, $11,	$D0
		dc.b $28, $D, $10, 9, $E0
		dc.b $28, $D, $18, 9, 0
		dc.b $18, $A, $18, $11,	$18
		dc.b 0,	7, $18,	$1A, $28
		even