; ---------------------------------------------------------------------------
; Nemesis decompression	algorithm
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


NemDec:
		movem.l	d0-a1/a3-a5,-(sp)
		lea	(loc_1502).l,a3
		lea	($C00000).l,a4
		bra.s	loc_145C
; ===========================================================================
		movem.l	d0-a1/a3-a5,-(sp)
		lea	(loc_1518).l,a3

loc_145C:				; XREF: NemDec
		lea	($FFFFAA00).w,a1
		move.w	(a0)+,d2
		lsl.w	#1,d2
		bcc.s	loc_146A
		adda.w	#$A,a3

loc_146A:
		lsl.w	#2,d2
		movea.w	d2,a5
		moveq	#8,d3
		moveq	#0,d2
		moveq	#0,d4
		bsr.w	NemDec4
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		move.w	#$10,d6
		bsr.s	NemDec2
		movem.l	(sp)+,d0-a1/a3-a5
		rts
; End of function NemDec


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


NemDec2:				; XREF: NemDec
		move.w	d6,d7
		subq.w	#8,d7
		move.w	d5,d1
		lsr.w	d7,d1
		cmpi.b	#-4,d1
		bcc.s	loc_14D6
		andi.w	#$FF,d1
		add.w	d1,d1
		move.b	(a1,d1.w),d0
		ext.w	d0
		sub.w	d0,d6
		cmpi.w	#9,d6
		bcc.s	loc_14B2
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5

loc_14B2:
		move.b	1(a1,d1.w),d1
		move.w	d1,d0
		andi.w	#$F,d1
		andi.w	#$F0,d0

loc_14C0:				; XREF: NemDec3
		lsr.w	#4,d0

loc_14C2:				; XREF: NemDec3
		lsl.l	#4,d4
		or.b	d1,d4
		subq.w	#1,d3
		bne.s	loc_14D0
		jmp	(a3)
; End of function NemDec2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


NemDec3:				; XREF: loc_1502
		moveq	#0,d4
		moveq	#8,d3

loc_14D0:				; XREF: NemDec2
		dbf	d0,loc_14C2
		bra.s	NemDec2
; ===========================================================================

loc_14D6:				; XREF: NemDec2
		subq.w	#6,d6
		cmpi.w	#9,d6
		bcc.s	loc_14E4
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5

loc_14E4:				; XREF: NemDec3
		subq.w	#7,d6
		move.w	d5,d1
		lsr.w	d6,d1
		move.w	d1,d0
		andi.w	#$F,d1
		andi.w	#$70,d0
		cmpi.w	#9,d6
		bcc.s	loc_14C0
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5
		bra.s	loc_14C0
; End of function NemDec3

; ===========================================================================

loc_1502:				; XREF: NemDec
		move.l	d4,(a4)
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	NemDec3
		rts
; ===========================================================================
		eor.l	d4,d2
		move.l	d2,(a4)
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	NemDec3
		rts
; ===========================================================================

loc_1518:				; XREF: NemDec
		move.l	d4,(a4)+
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	NemDec3
		rts
; ===========================================================================
		eor.l	d4,d2
		move.l	d2,(a4)+
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	NemDec3
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


NemDec4:				; XREF: NemDec
		move.b	(a0)+,d0

loc_1530:
		cmpi.b	#-1,d0
		bne.s	loc_1538
		rts
; ===========================================================================

loc_1538:				; XREF: NemDec4
		move.w	d0,d7

loc_153A:
		move.b	(a0)+,d0
		cmpi.b	#$80,d0
		bcc.s	loc_1530
		move.b	d0,d1
		andi.w	#$F,d7
		andi.w	#$70,d1
		or.w	d1,d7
		andi.w	#$F,d0
		move.b	d0,d1
		lsl.w	#8,d1
		or.w	d1,d7
		moveq	#8,d1
		sub.w	d0,d1
		bne.s	loc_1568
		move.b	(a0)+,d0
		add.w	d0,d0
		move.w	d7,(a1,d0.w)
		bra.s	loc_153A
; ===========================================================================

loc_1568:				; XREF: NemDec4
		move.b	(a0)+,d0
		lsl.w	d1,d0
		add.w	d0,d0
		moveq	#1,d5
		lsl.w	d1,d5
		subq.w	#1,d5

loc_1574:
		move.w	d7,(a1,d0.w)
		addq.w	#2,d0
		dbf	d5,loc_1574
		bra.s	loc_153A

; ---------------------------------------------------------------------------
; Enigma decompression algorithm
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


EniDec:
		movem.l	d0-d7/a1-a5,-(sp)
		movea.w	d0,a3
		move.b	(a0)+,d0
		ext.w	d0
		movea.w	d0,a5
		move.b	(a0)+,d4
		lsl.b	#3,d4
		movea.w	(a0)+,a2
		adda.w	a3,a2
		movea.w	(a0)+,a4
		adda.w	a3,a4
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6

loc_173E:				; XREF: loc_1768
		moveq	#7,d0
		move.w	d6,d7
		sub.w	d0,d7
		move.w	d5,d1
		lsr.w	d7,d1
		andi.w	#$7F,d1
		move.w	d1,d2
		cmpi.w	#$40,d1
		bcc.s	loc_1758
		moveq	#6,d0
		lsr.w	#1,d2

loc_1758:
		bsr.w	sub_188C
		andi.w	#$F,d2
		lsr.w	#4,d1
		add.w	d1,d1
		jmp	loc_17B4(pc,d1.w)
; End of function EniDec

; ===========================================================================

loc_1768:				; XREF: loc_17B4
		move.w	a2,(a1)+
		addq.w	#1,a2
		dbf	d2,loc_1768
		bra.s	loc_173E
; ===========================================================================

loc_1772:				; XREF: loc_17B4
		move.w	a4,(a1)+
		dbf	d2,loc_1772
		bra.s	loc_173E
; ===========================================================================

loc_177A:				; XREF: loc_17B4
		bsr.w	loc_17DC

loc_177E:
		move.w	d1,(a1)+
		dbf	d2,loc_177E
		bra.s	loc_173E
; ===========================================================================

loc_1786:				; XREF: loc_17B4
		bsr.w	loc_17DC

loc_178A:
		move.w	d1,(a1)+
		addq.w	#1,d1
		dbf	d2,loc_178A
		bra.s	loc_173E
; ===========================================================================

loc_1794:				; XREF: loc_17B4
		bsr.w	loc_17DC

loc_1798:
		move.w	d1,(a1)+
		subq.w	#1,d1
		dbf	d2,loc_1798
		bra.s	loc_173E
; ===========================================================================

loc_17A2:				; XREF: loc_17B4
		cmpi.w	#$F,d2
		beq.s	loc_17C4

loc_17A8:
		bsr.w	loc_17DC
		move.w	d1,(a1)+
		dbf	d2,loc_17A8
		bra.s	loc_173E
; ===========================================================================

loc_17B4:				; XREF: EniDec
		bra.s	loc_1768
; ===========================================================================
		bra.s	loc_1768
; ===========================================================================
		bra.s	loc_1772
; ===========================================================================
		bra.s	loc_1772
; ===========================================================================
		bra.s	loc_177A
; ===========================================================================
		bra.s	loc_1786
; ===========================================================================
		bra.s	loc_1794
; ===========================================================================
		bra.s	loc_17A2
; ===========================================================================

loc_17C4:				; XREF: loc_17A2
		subq.w	#1,a0
		cmpi.w	#$10,d6
		bne.s	loc_17CE
		subq.w	#1,a0

loc_17CE:
		move.w	a0,d0
		lsr.w	#1,d0
		bcc.s	loc_17D6
		addq.w	#1,a0

loc_17D6:
		movem.l	(sp)+,d0-d7/a1-a5
		rts
; ===========================================================================

loc_17DC:				; XREF: loc_17A2
		move.w	a3,d3
		move.b	d4,d1
		add.b	d1,d1
		bcc.s	loc_17EE
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_17EE
		ori.w	#-$8000,d3

loc_17EE:
		add.b	d1,d1
		bcc.s	loc_17FC
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_17FC
		addi.w	#$4000,d3

loc_17FC:
		add.b	d1,d1
		bcc.s	loc_180A
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_180A
		addi.w	#$2000,d3

loc_180A:
		add.b	d1,d1
		bcc.s	loc_1818
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_1818
		ori.w	#$1000,d3

loc_1818:
		add.b	d1,d1
		bcc.s	loc_1826
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_1826
		ori.w	#$800,d3

loc_1826:
		move.w	d5,d1
		move.w	d6,d7
		sub.w	a5,d7
		bcc.s	loc_1856
		move.w	d7,d6
		addi.w	#$10,d6
		neg.w	d7
		lsl.w	d7,d1
		move.b	(a0),d5
		rol.b	d7,d5
		add.w	d7,d7
		and.w	word_186C-2(pc,d7.w),d5
		add.w	d5,d1

loc_1844:				; XREF: loc_1868
		move.w	a5,d0
		add.w	d0,d0
		and.w	word_186C-2(pc,d0.w),d1
		add.w	d3,d1
		move.b	(a0)+,d5
		lsl.w	#8,d5
		move.b	(a0)+,d5
		rts
; ===========================================================================

loc_1856:				; XREF: loc_1826
		beq.s	loc_1868
		lsr.w	d7,d1
		move.w	a5,d0
		add.w	d0,d0
		and.w	word_186C-2(pc,d0.w),d1
		add.w	d3,d1
		move.w	a5,d0
		bra.s	sub_188C
; ===========================================================================

loc_1868:				; XREF: loc_1856
		moveq	#$10,d6

loc_186A:
		bra.s	loc_1844
; ===========================================================================
word_186C:	dc.w 1,	3, 7, $F, $1F, $3F, $7F, $FF, $1FF, $3FF, $7FF
		dc.w $FFF, $1FFF, $3FFF, $7FFF,	$FFFF	; XREF: loc_1856

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_188C:				; XREF: EniDec
		sub.w	d0,d6
		cmpi.w	#9,d6
		bcc.s	locret_189A
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5

locret_189A:
		rts

; ---------------------------------------------------------------------------
; Kosinski decompression algorithm
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

KosDec:

var_2		= -2
var_1		= -1

		subq.l	#2,sp
		move.b	(a0)+,2+var_1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4

loc_18A8:
		lsr.w	#1,d5
		move	sr,d6
		dbf	d4,loc_18BA
		move.b	(a0)+,2+var_1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4

loc_18BA:
		move	d6,ccr
		bcc.s	loc_18C2
		move.b	(a0)+,(a1)+
		bra.s	loc_18A8
; ===========================================================================

loc_18C2:				; XREF: KosDec
		moveq	#0,d3
		lsr.w	#1,d5
		move	sr,d6
		dbf	d4,loc_18D6
		move.b	(a0)+,2+var_1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4

loc_18D6:
		move	d6,ccr
		bcs.s	loc_1906
		lsr.w	#1,d5
		dbf	d4,loc_18EA
		move.b	(a0)+,2+var_1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4

loc_18EA:
		roxl.w	#1,d3
		lsr.w	#1,d5
		dbf	d4,loc_18FC
		move.b	(a0)+,2+var_1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4

loc_18FC:
		roxl.w	#1,d3
		addq.w	#1,d3
		moveq	#-1,d2
		move.b	(a0)+,d2
		bra.s	loc_191C
; ===========================================================================

loc_1906:				; XREF: loc_18C2
		move.b	(a0)+,d0
		move.b	(a0)+,d1
		moveq	#-1,d2
		move.b	d1,d2
		lsl.w	#5,d2
		move.b	d0,d2
		andi.w	#7,d1
		beq.s	loc_1928
		move.b	d1,d3
		addq.w	#1,d3

loc_191C:
		move.b	(a1,d2.w),d0
		move.b	d0,(a1)+
		dbf	d3,loc_191C
		bra.s	loc_18A8
; ===========================================================================

loc_1928:				; XREF: loc_1906
		move.b	(a0)+,d1
		beq.s	loc_1938
		cmpi.b	#1,d1
		beq.w	loc_18A8
		move.b	d1,d3
		bra.s	loc_191C
; ===========================================================================

loc_1938:				; XREF: loc_1928
		addq.l	#2,sp
		rts

; ---------------------------------------------------------------------------
; Subroutine to	read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ReadJoypads:
		lea	($FFFFF604).w,a0 ; address where joypad	states are written
		lea	($A10003).l,a1	; first	joypad port
		bsr.s	Joypad_Read	; do the first joypad
		addq.w	#2,a1		; do the second	joypad

Joypad_Read:
		move.b	#0,(a1)
		nop
		nop
		move.b	(a1),d0
		lsl.b	#2,d0
		andi.b	#$C0,d0
		move.b	#$40,(a1)
		nop
		nop
		move.b	(a1),d1
		andi.b	#$3F,d1
		or.b	d1,d0
		not.b	d0
		move.b	(a0),d1
		eor.b	d0,d1
		move.b	d0,(a0)+
		and.b	d0,d1
		move.b	d1,(a0)+
		rts
; ---------------------------------------------------------------------------
; Subroutine to	fade out and fade in
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeTo:
		move.w	#$3F,($FFFFF626).w

Pal_FadeTo2:
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		moveq	#0,d1
		move.b	($FFFFF627).w,d0

Pal_ToBlack:
		move.w	d1,(a0)+
		dbf	d0,Pal_ToBlack	; fill pallet with $000	(black)

		move.w	#$15,d4

loc_1DCE:
		stop	#$2300
		bsr.s	Pal_FadeIn
		dbf	d4,loc_1DCE
		rts

; ---------------------------------------------------------------------------
; Pallet fade-in subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeIn:				; XREF: Pal_FadeTo
		moveq	#0,d0
		lea	($FFFFFB00).w,a0
		lea	($FFFFFB80).w,a1
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	($FFFFF627).w,d0

loc_1DFA:
		bsr.s	Pal_AddColor
		dbf	d0,loc_1DFA
		cmpi.b	#1,($FFFFFE10).w
		bne.s	locret_1E24
		moveq	#0,d0
		lea	($FFFFFA80).w,a0
		lea	($FFFFFA00).w,a1
		move.b	($FFFFF626).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	($FFFFF627).w,d0

loc_1E1E:
		bsr.s	Pal_AddColor
		dbf	d0,loc_1E1E

locret_1E24:
		rts
; End of function Pal_FadeIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_AddColor:				; XREF: Pal_FadeIn
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	loc_1E4E
		move.w	d3,d1
		addi.w	#$200,d1	; increase blue	value
		cmp.w	d2,d1		; has blue reached threshold level?
		bhi.s	Pal_AddGreen	; if yes, branch
		move.w	d1,(a0)+	; update pallet
		rts
; ===========================================================================

Pal_AddGreen:				; XREF: Pal_AddColor
		move.w	d3,d1
		addi.w	#$20,d1		; increase green value
		cmp.w	d2,d1
		bhi.s	Pal_AddRed
		move.w	d1,(a0)+	; update pallet
		rts
; ===========================================================================

Pal_AddRed:				; XREF: Pal_AddGreen
		addq.w	#2,(a0)+	; increase red value
		rts
; ===========================================================================

loc_1E4E:				; XREF: Pal_AddColor
		addq.w	#2,a0
		rts
