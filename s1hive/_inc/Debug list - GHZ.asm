; ---------------------------------------------------------------------------
; Debug	list - Green Hill
; ---------------------------------------------------------------------------
	dc.w $10			; number of items in list
	dc.l Map_obj25+$25000000	; mappings pointer, object type * 10^6
	dc.b 0,	0, $27,	$B2		; subtype, frame, VRAM setting (2 bytes)
	dc.l Map_obj26+$26000000
	dc.b 0,	0, 6, $80
	dc.l Map_obj1F+$1F000000
	dc.b 0,	0, 4, 0
	dc.l Map_obj22+$22000000
	dc.b 0,	0, 4, $44
	dc.l Map_obj2B+$2B000000
	dc.b 0,	0, 4, $7B
	dc.l Map_obj36+$36000000
	dc.b 0,	0, 5, $1B
	dc.l Map_obj18+$18000000
	dc.b 0,	0, $40,	0
	dc.l Map_obj3B+$3B000000
	dc.b 0,	0, $63,	$D0
	dc.l Map_obj40+$40000000
	dc.b 0,	0, 4, $F0
	dc.l Map_obj41+$41000000
	dc.b 0,	0, 5, $23
	dc.l Map_obj42+$42000000
	dc.b 0,	0, $24,	$9B
	dc.l Map_obj44+$44000000
	dc.b 0,	0, $43,	$4C
	dc.l Map_obj48+$19000000
	dc.b 0,	0, $43,	$AA
	dc.l Map_obj79+$79000000
	dc.b 1,	0, 7, $A0
	dc.l Map_obj4B+$4B000000
	dc.b 0,	0, $24,	0
	dc.l Map_obj7D+$7D000000
	dc.b 1,	1, $84,	$B6
	even