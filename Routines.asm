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
