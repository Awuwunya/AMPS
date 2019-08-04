; ---------------------------------------------------------------------------
; Main level load blocks
;
; ===FORMAT===
; level	patterns + (1st	PLC num	* 10^6)
; 16x16	mappings + (2nd	PLC num	* 10^6)
; 256x256 mappings
; blank, music (unused), pal index (unused), pal index
; ---------------------------------------------------------------------------
	dc.l Nem_GHZ_2nd+$4000000
	dc.l Blk16_GHZ+$5000000
	dc.l Blk256_GHZ
	dc.b 0,	$81, 4,	4
	dc.l Nem_LZ+$6000000
	dc.l Blk16_LZ+$7000000
	dc.l Blk256_LZ
	dc.b 0,	$82, 5,	5
	dc.l Nem_MZ+$8000000
	dc.l Blk16_MZ+$9000000
	dc.l Blk256_MZ
	dc.b 0,	$83, 6,	6
	dc.l Nem_SLZ+$A000000
	dc.l Blk16_SLZ+$B000000
	dc.l Blk256_SLZ
	dc.b 0,	$84, 7,	7
	dc.l Nem_SYZ+$C000000
	dc.l Blk16_SYZ+$D000000
	dc.l Blk256_SYZ
	dc.b 0,	$85, 8,	8
	dc.l Nem_SBZ+$E000000
	dc.l Blk16_SBZ+$F000000
	dc.l Blk256_SBZ
	dc.b 0,	$86, 9,	9
	dc.l Nem_GHZ_2nd	; main load block for ending
	dc.l Blk16_GHZ
	dc.l Blk256_GHZ
	dc.b 0,	$86, $13, $13
	even