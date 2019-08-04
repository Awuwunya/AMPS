; ---------------------------------------------------------------------------
; Sprite mappings - Sonic
; ---------------------------------------------------------------------------
		dc.w byte_21292-Map_Sonic, byte_21293-Map_Sonic
		dc.w byte_212A8-Map_Sonic, byte_212B8-Map_Sonic
		dc.w byte_212C8-Map_Sonic, byte_212D8-Map_Sonic
		dc.w byte_212E8-Map_Sonic, byte_212FD-Map_Sonic
		dc.w byte_21308-Map_Sonic, byte_21313-Map_Sonic
		dc.w byte_21328-Map_Sonic, byte_21333-Map_Sonic
		dc.w byte_21343-Map_Sonic, byte_2135D-Map_Sonic
		dc.w byte_2137C-Map_Sonic, byte_21391-Map_Sonic
		dc.w byte_213AB-Map_Sonic, byte_213C0-Map_Sonic
		dc.w byte_213DA-Map_Sonic, byte_213EF-Map_Sonic
		dc.w byte_213FA-Map_Sonic, byte_21405-Map_Sonic
		dc.w byte_2141A-Map_Sonic, byte_21425-Map_Sonic
		dc.w byte_21435-Map_Sonic, byte_21454-Map_Sonic
		dc.w byte_21473-Map_Sonic, byte_21488-Map_Sonic
		dc.w byte_214A2-Map_Sonic, byte_214B7-Map_Sonic
		dc.w byte_214D1-Map_Sonic, byte_214DC-Map_Sonic
		dc.w byte_214E7-Map_Sonic, byte_214F2-Map_Sonic
		dc.w byte_214FD-Map_Sonic, byte_21512-Map_Sonic
		dc.w byte_21522-Map_Sonic, byte_21537-Map_Sonic
		dc.w byte_21547-Map_Sonic, byte_21552-Map_Sonic
		dc.w byte_2155D-Map_Sonic, byte_21568-Map_Sonic
		dc.w byte_21573-Map_Sonic, byte_21588-Map_Sonic
		dc.w byte_21593-Map_Sonic, byte_215A8-Map_Sonic
		dc.w byte_215B3-Map_Sonic, byte_215B9-Map_Sonic
		dc.w byte_215BF-Map_Sonic, byte_215C5-Map_Sonic
		dc.w byte_215CB-Map_Sonic, byte_215D1-Map_Sonic
		dc.w byte_215DC-Map_Sonic, byte_215E2-Map_Sonic
		dc.w byte_215ED-Map_Sonic, byte_215F3-Map_Sonic
		dc.w byte_215FE-Map_Sonic, byte_21613-Map_Sonic
		dc.w byte_21628-Map_Sonic, byte_21638-Map_Sonic
		dc.w byte_21648-Map_Sonic, byte_21658-Map_Sonic
		dc.w byte_21663-Map_Sonic, byte_21673-Map_Sonic
		dc.w byte_21683-Map_Sonic, byte_21693-Map_Sonic
		dc.w byte_216A8-Map_Sonic, byte_216BD-Map_Sonic
		dc.w byte_216D7-Map_Sonic, byte_216F1-Map_Sonic
		dc.w byte_216FC-Map_Sonic, byte_2170C-Map_Sonic
		dc.w byte_21717-Map_Sonic, byte_21727-Map_Sonic
		dc.w byte_21732-Map_Sonic, byte_21742-Map_Sonic
		dc.w byte_21752-Map_Sonic, byte_2176C-Map_Sonic
		dc.w byte_21786-Map_Sonic, byte_21791-Map_Sonic
		dc.w byte_217A1-Map_Sonic, byte_217A7-Map_Sonic
		dc.w byte_217AD-Map_Sonic, byte_217B3-Map_Sonic
		dc.w byte_217C3-Map_Sonic, byte_217D3-Map_Sonic
		dc.w byte_217E3-Map_Sonic, byte_217F3-Map_Sonic
byte_21292:	dc.b 0
byte_21293:	dc.b 4			; standing
		dc.b $EC, 8, 0,	0, $F0
		dc.b $F4, $D, 0, 3, $F0
		dc.b 4,	8, 0, $B, $F0
		dc.b $C, 8, 0, $E, $F8
byte_212A8:	dc.b 3			; waiting 1
		dc.b $EC, 9, 0,	0, $F0
		dc.b $FC, 9, 0,	6, $F0
		dc.b $C, 8, 0, $C, $F8
byte_212B8:	dc.b 3			; waiting 2
		dc.b $EC, 9, 0,	0, $F0
		dc.b $FC, 9, 0,	6, $F0
		dc.b $C, 8, 0, $C, $F8
byte_212C8:	dc.b 3			; waiting 3
		dc.b $EC, 9, 0,	0, $F0
		dc.b $FC, 9, 0,	6, $F0
		dc.b $C, 8, 0, $C, $F8
byte_212D8:	dc.b 3			; looking up
		dc.b $EC, $A, 0, 0, $F0
		dc.b 4,	8, 0, 9, $F0
		dc.b $C, 8, 0, $C, $F8
byte_212E8:	dc.b 4			; walking 1-1
		dc.b $EB, $D, 0, 0, $EC
		dc.b $FB, 9, 0,	8, $EC
		dc.b $FB, 6, 0,	$E, 4
		dc.b $B, 4, 0, $14, $EC
byte_212FD:	dc.b 2			; walking 1-2
		dc.b $EC, $D, 0, 0, $ED
		dc.b $FC, $E, 0, 8, $F5
byte_21308:	dc.b 2			; walking 1-3
		dc.b $ED, 9, 0,	0, $F3
		dc.b $FD, $A, 0, 6, $F3
byte_21313:	dc.b 4			; walking 1-4
		dc.b $EB, 9, 0,	0, $F4
		dc.b $FB, 9, 0,	6, $EC
		dc.b $FB, 6, 0,	$C, 4
		dc.b $B, 4, 0, $12, $EC
byte_21328:	dc.b 2			; walking 1-5
		dc.b $EC, 9, 0,	0, $F3
		dc.b $FC, $E, 0, 6, $EB
byte_21333:	dc.b 3			; walking 1-6
		dc.b $ED, $D, 0, 0, $EC
		dc.b $FD, $C, 0, 8, $F4
		dc.b 5,	9, 0, $C, $F4
byte_21343:	dc.b 5			; walking 2-1
		dc.b $EB, 9, 0,	0, $EB
		dc.b $EB, 6, 0,	6, 3
		dc.b $FB, 8, 0,	$C, $EB
		dc.b 3,	9, 0, $F, $F3
		dc.b $13, 0, 0,	$15, $FB
byte_2135D:	dc.b 6			; walking 2-2
		dc.b $EC, 9, 0,	0, $EC
		dc.b $EC, 1, 0,	6, 4
		dc.b $FC, $C, 0, 8, $EC
		dc.b 4,	9, 0, $C, $F4
		dc.b $FC, 5, 0,	$12, $C
		dc.b $F4, 0, 0,	$16, $14
byte_2137C:	dc.b 4			; walking 2-3
		dc.b $ED, 9, 0,	0, $ED
		dc.b $ED, 1, 0,	6, 5
		dc.b $FD, $D, 0, 8, $F5
		dc.b $D, 8, 0, $10, $FD
byte_21391:	dc.b 5			; walking 2-4
		dc.b $EB, 9, 0,	0, $EB
		dc.b $EB, 5, 0,	6, 3
		dc.b $FB, $D, 0, $A, $F3
		dc.b $B, 8, 0, $12, $F3
		dc.b $13, 4, 0,	$15, $FB
byte_213AB:	dc.b 4			; walking 2-5
		dc.b $EC, 9, 0,	0, $EC
		dc.b $EC, 1, 0,	6, 4
		dc.b $FC, $D, 0, 8, $F4
		dc.b $C, 8, 0, $10, $FC
byte_213C0:	dc.b 5			; walking 2-6
		dc.b $ED, 9, 0,	0, $ED
		dc.b $ED, 1, 0,	6, 5
		dc.b $FD, 0, 0,	8, $ED
		dc.b $FD, $D, 0, 9, $F5
		dc.b $D, 8, 0, $11, $FD
byte_213DA:	dc.b 4			; walking 3-1
		dc.b $F4, 7, 0,	0, $EB
		dc.b $EC, 9, 0,	8, $FB
		dc.b $FC, 4, 0,	$E, $FB
		dc.b 4,	9, 0, $10, $FB
byte_213EF:	dc.b 2			; walking 3-2
		dc.b $F4, 7, 0,	0, $EC
		dc.b $EC, $B, 0, 8, $FC
byte_213FA:	dc.b 2			; walking 3-3
		dc.b $F4, 6, 0,	0, $ED
		dc.b $F4, $A, 0, 6, $FD
byte_21405:	dc.b 4			; walking 3-4
		dc.b $F4, 6, 0,	0, $EB
		dc.b $EC, 9, 0,	6, $FB
		dc.b $FC, 4, 0,	$C, $FB
		dc.b 4,	9, 0, $E, $FB
byte_2141A:	dc.b 2			; walking 3-5
		dc.b $F4, 6, 0,	0, $EC
		dc.b $F4, $B, 0, 6, $FC
byte_21425:	dc.b 3			; walking 3-6
		dc.b $F4, 7, 0,	0, $ED
		dc.b $EC, 0, 0,	8, $FD
		dc.b $F4, $A, 0, 9, $FD
byte_21435:	dc.b 6			; walking 4-1
		dc.b $FD, 6, 0,	0, $EB
		dc.b $ED, 4, 0,	6, $F3
		dc.b $F5, 4, 0,	8, $EB
		dc.b $F5, $A, 0, $A, $FB
		dc.b $D, 0, 0, $13, $FB
		dc.b $FD, 0, 0,	$14, $13
byte_21454:	dc.b 6			; walking 4-2
		dc.b $FC, 6, 0,	0, $EC
		dc.b $E4, 8, 0,	6, $F4
		dc.b $EC, 4, 0,	9, $FC
		dc.b $F4, 4, 0,	$B, $EC
		dc.b $F4, $A, 0, $D, $FC
		dc.b $C, 0, 0, $16, $FC
byte_21473:	dc.b 4			; walking 4-3
		dc.b $FB, 6, 0,	0, $ED
		dc.b $F3, 4, 0,	6, $ED
		dc.b $EB, $A, 0, 8, $FD
		dc.b 3,	4, 0, $11, $FD
byte_21488:	dc.b 5			; walking 4-4
		dc.b $FD, 6, 0,	0, $EB
		dc.b $ED, 8, 0,	6, $F3
		dc.b $F5, 4, 0,	9, $EB
		dc.b $F5, $D, 0, $B, $FB
		dc.b 5,	8, 0, $13, $FB
byte_214A2:	dc.b 4			; walking 4-5
		dc.b $FC, 6, 0,	0, $EC
		dc.b $F4, 4, 0,	6, $EC
		dc.b $EC, $A, 0, 8, $FC
		dc.b 4,	4, 0, $11, $FC
byte_214B7:	dc.b 5			; walking 4-6
		dc.b $FB, 6, 0,	0, $ED
		dc.b $EB, $A, 0, 6, $FD
		dc.b $F3, 4, 0,	$F, $ED
		dc.b 3,	4, 0, $11, $FD
		dc.b $B, 0, 0, $13, $FD
byte_214D1:	dc.b 2			; running 1-1
		dc.b $EE, 9, 0,	0, $F4
		dc.b $FE, $E, 0, 6, $EC
byte_214DC:	dc.b 2			; running 1-2
		dc.b $EE, 9, 0,	0, $F4
		dc.b $FE, $E, 0, 6, $EC
byte_214E7:	dc.b 2			; running 1-3
		dc.b $EE, 9, 0,	0, $F4
		dc.b $FE, $E, 0, 6, $EC
byte_214F2:	dc.b 2			; running 1-4
		dc.b $EE, 9, 0,	0, $F4
		dc.b $FE, $E, 0, 6, $EC
byte_214FD:	dc.b 4			; running 2-1
		dc.b $EE, 9, 0,	0, $EE
		dc.b $EE, 1, 0,	6, 6
		dc.b $FE, $E, 0, 8, $F6
		dc.b $FE, 0, 0,	$14, $EE
byte_21512:	dc.b 3			; running 2-2
		dc.b $EE, 9, 0,	0, $EE
		dc.b $EE, 1, 0,	6, 6
		dc.b $FE, $E, 0, 8, $F6
byte_21522:	dc.b 4			; running 2-3
		dc.b $EE, 9, 0,	0, $EE
		dc.b $EE, 1, 0,	6, 6
		dc.b $FE, $E, 0, 8, $F6
		dc.b $FE, 0, 0,	$14, $EE
byte_21537:	dc.b 3			; running 2-4
		dc.b $EE, 9, 0,	0, $EE
		dc.b $EE, 1, 0,	6, 6
		dc.b $FE, $E, 0, 8, $F6
byte_21547:	dc.b 2			; running 3-1
		dc.b $F4, 6, 0,	0, $EE
		dc.b $F4, $B, 0, 6, $FE
byte_21552:	dc.b 2			; running 3-2
		dc.b $F4, 6, 0,	0, $EE
		dc.b $F4, $B, 0, 6, $FE
byte_2155D:	dc.b 2			; running 3-3
		dc.b $F4, 6, 0,	0, $EE
		dc.b $F4, $B, 0, 6, $FE
byte_21568:	dc.b 2			; running 3-4
		dc.b $F4, 6, 0,	0, $EE
		dc.b $F4, $B, 0, 6, $FE
byte_21573:	dc.b 4			; running 4-1
		dc.b $FA, 6, 0,	0, $EE
		dc.b $F2, 4, 0,	6, $EE
		dc.b $EA, $B, 0, 8, $FE
		dc.b $A, 0, 0, $14, $FE
byte_21588:	dc.b 2			; running 4-2
		dc.b $F2, 7, 0,	0, $EE
		dc.b $EA, $B, 0, 8, $FE
byte_21593:	dc.b 4			; running 4-3
		dc.b $FA, 6, 0,	0, $EE
		dc.b $F2, 4, 0,	6, $EE
		dc.b $EA, $B, 0, 8, $FE
		dc.b $A, 0, 0, $14, $FE
byte_215A8:	dc.b 2			; running 4-4
		dc.b $F2, 7, 0,	0, $EE
		dc.b $EA, $B, 0, 8, $FE
byte_215B3:	dc.b 1			; rolling 1
		dc.b $F0, $F, 0, 0, $F0
byte_215B9:	dc.b 1			; rolling 2
		dc.b $F0, $F, 0, 0, $F0
byte_215BF:	dc.b 1			; rolling 3
		dc.b $F0, $F, 0, 0, $F0
byte_215C5:	dc.b 1			; rolling 4
		dc.b $F0, $F, 0, 0, $F0
byte_215CB:	dc.b 1			; rolling 5
		dc.b $F0, $F, 0, 0, $F0
byte_215D1:	dc.b 2			; warped 1 (unused)
		dc.b $F4, $E, 0, 0, $EC
		dc.b $F4, 2, 0,	$C, $C
byte_215DC:	dc.b 1			; warped 2 (unused)
		dc.b $F0, $F, 0, 0, $F0
byte_215E2:	dc.b 2			; warped 3 (unused)
		dc.b $EC, $B, 0, 0, $F4
		dc.b $C, 8, 0, $C, $F4
byte_215ED:	dc.b 1			; warped 4 (unused)
		dc.b $F0, $F, 0, 0, $F0
byte_215F3:	dc.b 2			; stopping 1
		dc.b $ED, 9, 0,	0, $F0
		dc.b $FD, $E, 0, 6, $F0
byte_215FE:	dc.b 4			; stopping 2
		dc.b $ED, 9, 0,	0, $F0
		dc.b $FD, $D, 0, 6, $F0
		dc.b $D, 4, 0, $E, 0
		dc.b 5,	0, 0, $10, $E8
byte_21613:	dc.b 4			; ducking
		dc.b $F4, 4, 0,	0, $FC
		dc.b $FC, $D, 0, 2, $F4
		dc.b $C, 8, 0, $A, $F4
		dc.b 4,	0, 0, $D, $EC
byte_21628:	dc.b 3			; balancing 1
		dc.b $EC, 8, 8,	0, $E8
		dc.b $F4, 2, 8,	3, 0
		dc.b $F4, $F, 8, 6, $E0
byte_21638:	dc.b 3			; balancing 2
		dc.b $EC, $E, 8, 0, $E8
		dc.b 4,	$D, 8, $C, $E0
		dc.b $C, 0, $18, $14, 0
byte_21648:	dc.b 3			; spinning 1 (LZ)
		dc.b $F4, $D, 0, 0, $FC
		dc.b $FC, 5, 0,	8, $EC
		dc.b 4,	8, 0, $C, $FC
byte_21658:	dc.b 2			; spinning 2 (LZ)
		dc.b $F4, $A, 0, 0, $E8
		dc.b $F4, $A, 8, 0, 0
byte_21663:	dc.b 3			; spinning 3 (LZ)
		dc.b $F4, $D, 0, 0, $E4
		dc.b $FC, 0, 0,	8, 4
		dc.b 4,	$C, 0, 9, $EC
byte_21673:	dc.b 3			; spinning 4 (LZ)
		dc.b $F4, $D, 0, 0, $FC
		dc.b $FC, 5, 0,	8, $EC
		dc.b 4,	8, 0, $C, $FC
byte_21683:	dc.b 3			; bouncing
		dc.b $E8, $B, 0, 0, $F0
		dc.b 8,	4, 0, $C, $F8
		dc.b $10, 0, 0,	$E, $F8
byte_21693:	dc.b 4			; hanging 1 (LZ)
		dc.b $F8, $E, 0, 0, $E8
		dc.b 0,	5, 0, $C, 8
		dc.b $F8, 0, 0,	$10, 8
		dc.b $F0, 0, 0,	$11, $F8
byte_216A8:	dc.b 4			; hanging 2 (LZ)
		dc.b $F8, $E, 0, 0, $E8
		dc.b 0,	5, 0, $C, 8
		dc.b $F8, 0, 0,	$10, 8
		dc.b $F0, 0, 0,	$11, $F8
byte_216BD:	dc.b 5			; celebration leap 1 (unused)
		dc.b $E8, $A, 0, 0, $F4
		dc.b $F0, 1, 0,	9, $C
		dc.b 0,	9, 0, $B, $F4
		dc.b $10, 4, 0,	$11, $F4
		dc.b 0,	0, 0, $13, $EC
byte_216D7:	dc.b 5			; celebration leap 2 (unused)
		dc.b $E8, $A, 0, 0, $F4
		dc.b $E8, 1, 0,	9, $C
		dc.b 0,	9, 0, $B, $F4
		dc.b $10, 4, 0,	$11, $F4
		dc.b 0,	0, 0, $13, $EC
byte_216F1:	dc.b 2			; pushing 1
		dc.b $ED, $A, 0, 0, $F3
		dc.b 5,	$D, 0, 9, $EB
byte_216FC:	dc.b 3			; pushing 2
		dc.b $EC, $A, 0, 0, $F3
		dc.b 4,	8, 0, 9, $F3
		dc.b $C, 4, 0, $C, $F3
byte_2170C:	dc.b 2			; pushing 3
		dc.b $ED, $A, 0, 0, $F3
		dc.b 5,	$D, 0, 9, $EB
byte_21717:	dc.b 3			; pushing 4
		dc.b $EC, $A, 0, 0, $F3
		dc.b 4,	8, 0, 9, $F3
		dc.b $C, 4, 0, $C, $F3
byte_21727:	dc.b 2			; surfing or sliding (unused)
		dc.b $EC, 9, 0,	0, $F0
		dc.b $FC, $E, 0, 6, $F0
byte_21732:	dc.b 3			; collecting bubble (unused)
		dc.b $EC, $A, 0, 0, $F0
		dc.b 4,	5, 0, 9, $F8
		dc.b $E4, 0, 0,	$D, $F8
byte_21742:	dc.b 3			; death	1
		dc.b $E8, $D, 0, 0, $EC
		dc.b $E8, 1, 0,	8, $C
		dc.b $F8, $B, 0, $A, $F4
byte_21752:	dc.b 5			; drowning
		dc.b $E8, $D, 0, 0, $EC
		dc.b $E8, 1, 0,	8, $C
		dc.b $F8, 9, 0,	$A, $F4
		dc.b 8,	$C, 0, $10, $F4
		dc.b $10, 0, 0,	$14, $F4
byte_2176C:	dc.b 5			; death	2
		dc.b $E8, $D, 0, 0, $EC
		dc.b $E8, 1, 0,	8, $C
		dc.b $F8, 9, 0,	$A, $F4
		dc.b 8,	$C, 0, $10, $F4
		dc.b $10, 0, 0,	$14, $F4
byte_21786:	dc.b 2			; shrinking 1 (unused)
		dc.b $EC, 8, 0,	0, $F0
		dc.b $F4, $F, 0, 3, $F0
byte_21791:	dc.b 3			; shrinking 2 (unused)
		dc.b $EC, 8, 0,	0, $F0
		dc.b $F4, $E, 0, 3, $F0
		dc.b $C, 8, 0, $F, $F8
byte_217A1:	dc.b 1			; shrinking 3 (unused)
		dc.b $F0, $B, 0, 0, $F4
byte_217A7:	dc.b 1			; shrinking 4 (unused)
		dc.b $F4, 6, 0,	0, $F8
byte_217AD:	dc.b 1			; shrinking 5 (unused)
		dc.b $F8, 1, 0,	0, $FC
byte_217B3:	dc.b 3			; injury
		dc.b $F4, $D, 8, 0, $E4
		dc.b $FC, 5, 8,	8, 4
		dc.b 4,	8, 8, $C, $EC
byte_217C3:	dc.b 3			; spinning 5 (LZ)
		dc.b $F4, $D, 8, 0, $FC
		dc.b $FC, 0, 8,	8, $F4
		dc.b 4,	$C, 8, 9, $F4
byte_217D3:	dc.b 3			; spinning 6 (LZ)
		dc.b $F0, $E, 0, 0, $EC
		dc.b $F8, 1, 0,	$C, $C
		dc.b 8,	$C, 0, $E, $F4
byte_217E3:	dc.b 3			; collecting bubble (LZ)
		dc.b $EB, 9, 0,	0, $F4
		dc.b $FB, $E, 0, 6, $EC
		dc.b 3,	1, 0, $12, $C
byte_217F3:	dc.b 2			; water	slide (LZ)
		dc.b $F0, $F, 0, 0, $EC
		dc.b $F8, 2, 0,	$10, $C
		even