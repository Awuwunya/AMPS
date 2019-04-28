; ---------------------------------------------------------------------------
; KOSINSKI DECOMPRESSION PROCEDURE
; (sometimes called KOZINSKI decompression)
;
; ARGUMENTS:
; a0 = source address
; a1 = destination address
;
; For format explanation see http://info.sonicretro.org/Kosinski_compression
; New faster version by written by vladikcomper, with additional improvements by
; MarkeyJester and Flamewing
; ---------------------------------------------------------------------------
_Kos_UseLUT = 1
_Kos_LoopUnroll = 3
_Kos_ExtremeUnrolling = 1

_Kos_RunBitStream macro
	dbra	d2,.skip\@
	moveq	#7,d2					; Set repeat count to 8.
	move.b	d1,d0					; Use the remaining 8 bits.
	not.w	d3					; Have all 16 bits been used up?
	bne.s	.skip\@					; Branch if not.
	move.b	(a0)+,d0				; Get desc field low-byte.
	move.b	(a0)+,d1				; Get desc field hi-byte.

	if _Kos_UseLUT=1
		move.b	(a4,d0.w),d0			; Invert bit order...
		move.b	(a4,d1.w),d1			; ... for both bytes.
	endif
.skip\@
	endm

_Kos_ReadBit macro
	if _Kos_UseLUT=1
		add.b	d0,d0				; Get a bit from the bitstream.
	else
		lsr.b	#1,d0				; Get a bit from the bitstream.
	endif
	endm
; ===========================================================================
; KozDec_193A:
KosDec:
	moveq	#(1<<_Kos_LoopUnroll)-1,d7
	if _Kos_UseLUT=1
		moveq	#0,d0
		moveq	#0,d1
		lea	KosDec_ByteMap(pc),a4		; Load LUT pointer.
	endif

	move.b	(a0)+,d0				; Get desc field low-byte.
	move.b	(a0)+,d1				; Get desc field hi-byte.

	if _Kos_UseLUT=1
		move.b	(a4,d0.w),d0			; Invert bit order...
		move.b	(a4,d1.w),d1			; ... for both bytes.
	endif

	moveq	#7,d2					; Set repeat count to 8.
	moveq	#0,d3					; d3 will be desc field switcher.
	bra.s	.FetchNewCode
; ---------------------------------------------------------------------------
.FetchCodeLoop:
	; Code 1 (Uncompressed byte).
	_Kos_RunBitStream
	move.b	(a0)+,(a1)+

.FetchNewCode:
	_Kos_ReadBit
	bcs.s	.FetchCodeLoop			; If code = 1, branch.

	; Codes 00 and 01.
	moveq	#-1,d5
	lea	(a1),a5
	_Kos_RunBitStream

	if _Kos_ExtremeUnrolling=1
	_Kos_ReadBit
	bcs.w	.Code_01

	; Code 00 (Dictionary ref. short).
	_Kos_RunBitStream
	_Kos_ReadBit
	bcs.s	.Copy45
	_Kos_RunBitStream
	_Kos_ReadBit
	bcs.s	.Copy3
	_Kos_RunBitStream
	move.b	(a0)+,d5				; d5 = displacement.
	adda.w	d5,a5
	move.b	(a5)+,(a1)+
	move.b	(a5)+,(a1)+
	bra.s	.FetchNewCode
; ---------------------------------------------------------------------------
.Copy3:
	_Kos_RunBitStream
	move.b	(a0)+,d5				; d5 = displacement.
	adda.w	d5,a5
	move.b	(a5)+,(a1)+
	move.b	(a5)+,(a1)+
	move.b	(a5)+,(a1)+
	bra.w	.FetchNewCode
; ---------------------------------------------------------------------------
.Copy45:
	_Kos_RunBitStream
	_Kos_ReadBit
	bcs.s	.Copy5
	_Kos_RunBitStream
	move.b	(a0)+,d5				; d5 = displacement.
	adda.w	d5,a5
	move.b	(a5)+,(a1)+
	move.b	(a5)+,(a1)+
	move.b	(a5)+,(a1)+
	move.b	(a5)+,(a1)+
	bra.w	.FetchNewCode
; ---------------------------------------------------------------------------
.Copy5:
	_Kos_RunBitStream
	move.b	(a0)+,d5				; d5 = displacement.
	adda.w	d5,a5
	move.b	(a5)+,(a1)+
	move.b	(a5)+,(a1)+
	move.b	(a5)+,(a1)+
	move.b	(a5)+,(a1)+
	move.b	(a5)+,(a1)+
	bra.w	.FetchNewCode
; ---------------------------------------------------------------------------
	else
	moveq	#0,d4					; d4 will contain copy count.
	_Kos_ReadBit
	bcs.s	.Code_01

	; Code 00 (Dictionary ref. short).
	_Kos_RunBitStream
	_Kos_ReadBit
	addx.w	d4,d4
	_Kos_RunBitStream
	_Kos_ReadBit
	addx.w	d4,d4
	_Kos_RunBitStream
	move.b	(a0)+,d5				; d5 = displacement.

.StreamCopy:
	adda.w	d5,a5
	move.b	(a5)+,(a1)+				; Do 1 extra copy (to compensate +1 to copy counter).

.copy:
	move.b	(a5)+,(a1)+
	dbra	d4,.copy
	bra.w	.FetchNewCode
	endif
; ---------------------------------------------------------------------------
.Code_01:
	moveq	#0,d4					; d4 will contain copy count.
	; Code 01 (Dictionary ref. long / special).
	_Kos_RunBitStream
	move.b	(a0)+,d6				; d6 = %LLLLLLLL.
	move.b	(a0)+,d4				; d4 = %HHHHHCCC.
	move.b	d4,d5					; d5 = %11111111 HHHHHCCC.
	lsl.w	#5,d5					; d5 = %111HHHHH CCC00000.
	move.b	d6,d5					; d5 = %111HHHHH LLLLLLLL.

	if _Kos_LoopUnroll=3
		and.w	d7,d4				; d4 = %00000CCC.
	else
		andi.w	#7,d4
	endif

	bne.s	.StreamCopy				; if CCC=0, branch.

	; special mode (extended counter)
	move.b	(a0)+,d4				; Read cnt
	beq.s	.Quit					; If cnt=0, quit decompression.
	subq.b	#1,d4
	beq.w	.FetchNewCode			; If cnt=1, fetch a new code.

	adda.w	d5,a5
	move.b	(a5)+,(a1)+				; Do 1 extra copy (to compensate +1 to copy counter).
	move.w	d4,d6
	not.w	d6
	and.w	d7,d6
	add.w	d6,d6
	lsr.w	#_Kos_LoopUnroll,d4
	jmp	.largecopy(pc,d6.w)
; ---------------------------------------------------------------------------
.largecopy:
	rept (1<<_Kos_LoopUnroll)
		move.b	(a5)+,(a1)+
	endr

	dbra	d4,.largecopy
	bra.w	.FetchNewCode
; ---------------------------------------------------------------------------
	if _Kos_ExtremeUnrolling=1
.StreamCopy:
	adda.w	d5,a5
	move.b	(a5)+,(a1)+				; Do 1 extra copy (to compensate +1 to copy counter).

	if _Kos_LoopUnroll=3
		eor.w	d7,d4
	else
		eori.w	#7,d4
	endif

	add.w	d4,d4
	jmp	.mediumcopy(pc,d4.w)
; ---------------------------------------------------------------------------
.mediumcopy:
	rept 8
		move.b	(a5)+,(a1)+
	endr

	bra.w	.FetchNewCode
	endif
; ---------------------------------------------------------------------------
.Quit:
	rts						; End of function KosDec.

; ===========================================================================
	if _Kos_UseLUT=1
KosDec_ByteMap:
	dc.b $00,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0
	dc.b $08,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8
	dc.b $04,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4
	dc.b $0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
	dc.b $02,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2
	dc.b $0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
	dc.b $06,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6
	dc.b $0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
	dc.b $01,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1
	dc.b $09,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9
	dc.b $05,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5
	dc.b $0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
	dc.b $03,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3
	dc.b $0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
	dc.b $07,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7
	dc.b $0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF
	endif
; ===========================================================================

; ==============================================================================
; ------------------------------------------------------------------------------
; Nemesis decompression routine
; ------------------------------------------------------------------------------
; Optimized by vladikcomper
; ------------------------------------------------------------------------------

NemDec_RAM:
	lea	NemDec_WriteRowToRAM(pc),a3

NemDec_Main:
	lea	Buffer+$3000,a1		; load Nemesis decompression buffer
	move.w	(a0)+,d2		; get number of patterns
	bpl.s	.0			; are we in Mode 0?
	lea	$A(a3),a3		; if not, use Mode 1
.0	lsl.w	#3,d2
	movea.w	d2,a5
	moveq	#7,d3
	moveq	#0,d2
	moveq	#0,d4
	bsr.w	NemDec4
	move.b	(a0)+,d5		; get first byte of compressed data
	asl.w	#8,d5			; shift up by a byte
	move.b	(a0)+,d5		; get second byte of compressed data
	move.w	#$10,d6			; set initial shift value
	bsr.s	NemDec2
	rts

; ---------------------------------------------------------------------------
; Part of the Nemesis decompressor, processes the actual compressed data
; ---------------------------------------------------------------------------

NemDec2:
	move.w	d6,d7
	subq.w	#8,d7			; get shift value
	move.w	d5,d1
	lsr.w	d7,d1			; shift so that high bit of the code is in bit position 7
	cmpi.b	#%11111100,d1		; are the high 6 bits set?
	bcc.s	NemDec_InlineData	; if they are, it signifies inline data
	andi.w	#$FF,d1
	add.w	d1,d1
	sub.b	(a1,d1.w),d6		; ~~ subtract from shift value so that the next code is read next time around
	cmpi.w	#9,d6			; does a new byte need to be read?
	bcc.s	.0			; if not, branch
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5		; read next byte
.0	move.b	1(a1,d1.w),d1
	move.w	d1,d0
	andi.w	#$F,d1			; get palette index for pixel
	andi.w	#$F0,d0

NemDec_GetRepeatCount:
	lsr.w	#4,d0			; get repeat count

NemDec_WritePixel:
	lsl.l	#4,d4			; shift up by a nybble
	or.b	d1,d4			; write pixel
	dbf	d3,NemDec_WritePixelLoop; ~~
	jmp	(a3)			; otherwise, write the row to its destination
; ---------------------------------------------------------------------------

NemDec3:
	moveq	#0,d4			; reset row
	moveq	#7,d3			; reset nybble counter

NemDec_WritePixelLoop:
	dbf	d0,NemDec_WritePixel
	bra.s	NemDec2
; ---------------------------------------------------------------------------

NemDec_InlineData:
	subq.w	#6,d6			; 6 bits needed to signal inline data
	cmpi.w	#9,d6
	bcc.s	.0
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5
.0	subq.w	#7,d6			; and 7 bits needed for the inline data itself
	move.w	d5,d1
	lsr.w	d6,d1			; shift so that low bit of the code is in bit position 0
	move.w	d1,d0
	andi.w	#$F,d1			; get palette index for pixel
	andi.w	#$70,d0			; high nybble is repeat count for pixel
	cmpi.w	#9,d6
	bcc.s	NemDec_GetRepeatCount
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5
	bra.s	NemDec_GetRepeatCount

; ---------------------------------------------------------------------------
; Subroutines to output decompressed entry
; Selected depending on current decompression mode
; ---------------------------------------------------------------------------

NemDec_WriteRowToVDP:
loc_1502:
	move.l	d4,(a4)			; write 8-pixel row
	subq.w	#1,a5
	move.w	a5,d4			; have all the 8-pixel rows been written?
	bne.s	NemDec3			; if not, branch
	rts
; ---------------------------------------------------------------------------

NemDec_WriteRowToVDP_XOR:
	eor.l	d4,d2			; XOR the previous row by the current row
	move.l	d2,(a4)			; and write the result
	subq.w	#1,a5
	move.w	a5,d4
	bne.s	NemDec3
	rts
; ---------------------------------------------------------------------------

NemDec_WriteRowToRAM:
	move.l	d4,(a4)+		; write 8-pixel row
	subq.w	#1,a5
	move.w	a5,d4			; have all the 8-pixel rows been written?
	bne.s	NemDec3			; if not, branch
	rts
; ---------------------------------------------------------------------------

NemDec_WriteRowToRAM_XOR:
	eor.l	d4,d2			; XOR the previous row by the current row
	move.l	d2,(a4)+		; and write the result
	subq.w	#1,a5
	move.w	a5,d4
	bne.s	NemDec3
	rts

; ---------------------------------------------------------------------------
; Part of the Nemesis decompressor, builds the code table (in RAM)
; ---------------------------------------------------------------------------

NemDec4:
	move.b	(a0)+,d0		; read first byte

.ChkEnd:
	cmpi.b	#$FF,d0			; has the end of the code table description been reached?
	bne.s	.NewPalIndex		; if not, branch
	rts
; ---------------------------------------------------------------------------

.NewPalIndex:
	move.w	d0,d7

.ItemLoop:
	move.b	(a0)+,d0		; read next byte
	bmi.s	.ChkEnd			; ~~
	move.b	d0,d1
	andi.w	#$F,d7			; get palette index
	andi.w	#$70,d1			; get repeat count for palette index
	or.w	d1,d7			; combine the two
	andi.w	#$F,d0			; get the length of the code in bits
	move.b	d0,d1
	lsl.w	#8,d1
	or.w	d1,d7			; combine with palette index and repeat count to form code table entry
	moveq	#8,d1
	sub.w	d0,d1			; is the code 8 bits long?
	bne.s	.ItemShortCode		; if not, a bit of extra processing is needed
	move.b	(a0)+,d0		; get code
	add.w	d0,d0			; each code gets a word-sized entry in the table
	move.w	d7,(a1,d0.w)		; store the entry for the code
	bra.s	.ItemLoop		; repeat
; ---------------------------------------------------------------------------

.ItemShortCode:
	move.b	(a0)+,d0		; get code
	lsl.w	d1,d0			; shift so that high bit is in bit position 7
	add.w	d0,d0			; get index into code table
	moveq	#1,d5
	lsl.w	d1,d5
	subq.w	#1,d5			; d5 = 2^d1 - 1
	lea	(a1,d0.w),a6		; ~~

.ItemShortCodeLoop:
	move.w	d7,(a6)+		; ~~ store entry
	dbf	d5,.ItemShortCodeLoop	; repeat for required number of entries
	bra.s	.ItemLoop

; ===============================================================
; ---------------------------------------------------------------
; COMPER Decompressor
; ---------------------------------------------------------------
; INPUT:
;	a0	- Source Offset
;	a1	- Destination Offset
; ---------------------------------------------------------------

CompDec:
.newblock
	move.w	(a0)+,d0		; fetch description field
	moveq	#15,d3			; set bits counter to 16

.mainloop
	add.w	d0,d0			; roll description field
	bcs.s	.flag			; if a flag issued, branch
	move.w	(a0)+,(a1)+		; otherwise, do uncompressed data
	dbf	d3,.mainloop		; if bits counter remains, parse the next word
	bra.s	.newblock		; start a new block

; ---------------------------------------------------------------
.flag	moveq	#-1,d1			; init displacement
	move.b	(a0)+,d1		; load displacement
	add.w	d1,d1
	moveq	#0,d2			; init copy count
	move.b	(a0)+,d2		; load copy length
	beq.s	.end			; if zero, branch
	lea	(a1,d1),a2		; load start copy address

.loop	move.w	(a2)+,(a1)+		; copy given sequence
	dbf	d2,.loop		; repeat
	dbf	d3,.mainloop		; if bits counter remains, parse the next word
	bra.s	.newblock		; start a new block

.end	rts

; ---------------------------------------------------------------------------
; Enigma decompression algorithm
; input:
;	d0 = starting art tile (added to each 8x8 before writing to destination)
;	a0 = source address
;	a1 = destination address
; usage:
;	lea	(source).l,a0
;	lea	(destination).l,a1
;	move.w	#arttile,d0
;	bsr.w	EniDec
; See http://www.segaretro.org/Enigma_compression for format description
; ---------------------------------------------------------------------------

EniDec:
		movea.w	d0,a3		; store starting art tile
		move.b	(a0)+,d0
		ext.w	d0
		movea.w	d0,a5		; store number of bits in inline copy value
		move.b	(a0)+,d4
		lsl.b	#3,d4		; store PCCVH flags bitfield
		movea.w	(a0)+,a2
		adda.w	a3,a2		; store incremental copy word
		movea.w	(a0)+,a4
		adda.w	a3,a4		; store literal copy word
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5	; get first word in format list
		moveq	#16,d6		; initial shift value
; loc_173E:
Eni_Loop:
		moveq	#7,d0		; assume a format list entry is 7 bits
		move.w	d6,d7
		sub.w	d0,d7
		move.w	d5,d1
		lsr.w	d7,d1
		andi.w	#$7F,d1		; get format list entry
		move.w	d1,d2		; and copy it
		cmpi.w	#$40,d1		; is the high bit of the entry set?
		bhs.s	.sevenbitentry
		moveq	#6,d0		; if it isn't, the entry is actually 6 bits
		lsr.w	#1,d2
; loc_1758:
.sevenbitentry:
		bsr.w	EniDec_FetchByte
		andi.w	#$F,d2		; get repeat count
		lsr.w	#4,d1
		add.w	d1,d1
		jmp	EniDec_Index(pc,d1.w)
; End of function EniDec

; ===========================================================================
; loc_1768:
EniDec_00:
.loop:		move.w	a2,(a1)+	; copy incremental copy word
		addq.w	#1,a2		; increment it
		dbf	d2,.loop	; repeat
		bra.s	Eni_Loop
; ===========================================================================
; loc_1772:
EniDec_01:
.loop:		move.w	a4,(a1)+	; copy literal copy word
		dbf	d2,.loop	; repeat
		bra.s	Eni_Loop
; ===========================================================================
; loc_177A:
EniDec_100:
		bsr.w	EniDec_FetchInlineValue
; loc_177E:
.loop:		move.w	d1,(a1)+	; copy inline value
		dbf	d2,.loop	; repeat

		bra.s	Eni_Loop
; ===========================================================================
; loc_1786:
EniDec_101:
		bsr.w	EniDec_FetchInlineValue
; loc_178A:
.loop:		move.w	d1,(a1)+	; copy inline value
		addq.w	#1,d1		; increment
		dbf	d2,.loop	; repeat

		bra.s	Eni_Loop
; ===========================================================================
; loc_1794:
EniDec_110:
		bsr.w	EniDec_FetchInlineValue
; loc_1798:
.loop:		move.w	d1,(a1)+	; copy inline value
		subq.w	#1,d1		; decrement
		dbf	d2,.loop	; repeat

		bra.s	Eni_Loop
; ===========================================================================
; loc_17A2:
EniDec_111:
		cmpi.w	#$F,d2
		beq.s	EniDec_Done
; loc_17A8:
.loop:		bsr.w	EniDec_FetchInlineValue	; fetch new inline value
		move.w	d1,(a1)+	; copy it
		dbf	d2,.loop	; and repeat

		bra.s	Eni_Loop
; ===========================================================================
; loc_17B4:
EniDec_Index:
		bra.s	EniDec_00
		bra.s	EniDec_00
		bra.s	EniDec_01
		bra.s	EniDec_01
		bra.s	EniDec_100
		bra.s	EniDec_101
		bra.s	EniDec_110
		bra.s	EniDec_111
; ===========================================================================
; loc_17C4:
EniDec_Done:
		subq.w	#1,a0		; go back by one byte
		cmpi.w	#16,d6		; were we going to start on a completely new byte?
		bne.s	.notnewbyte	; if not, branch
		subq.w	#1,a0		; and another one if needed
; loc_17CE:
.notnewbyte:
		move.w	a0,d0
		lsr.w	#1,d0		; are we on an odd byte?
		bcc.s	.evenbyte	; if not, branch
		addq.w	#1,a0		; ensure we're on an even byte
; loc_17D6:
.evenbyte:
		rts

; ---------------------------------------------------------------------------
; Part of the Enigma decompressor
; Fetches an inline copy value and stores it in d1
; ---------------------------------------------------------------------------

; loc_17DC:
EniDec_FetchInlineValue:
		move.w	a3,d3		; copy starting art tile
		move.b	d4,d1		; copy PCCVH bitfield
		add.b	d1,d1		; is the priority bit set?
		bcc.s	.skippriority	; if not, branch
		subq.w	#1,d6
		btst	d6,d5		; is the priority bit set in the inline render flags?
		beq.s	.skippriority	; if not, branch
		ori.w	#$8000,d3	; otherwise set priority bit in art tile
; loc_17EE:
.skippriority:
		add.b	d1,d1		; is the high palette line bit set?
		bcc.s	.skiphighpal	; if not, branch
		subq.w	#1,d6
		btst	d6,d5
		beq.s	.skiphighpal
		addi.w	#$4000,d3	; set second palette line bit
; loc_17FC:
.skiphighpal:
		add.b	d1,d1		; is the low palette line bit set?
		bcc.s	.skiplowpal	; if not, branch
		subq.w	#1,d6
		btst	d6,d5
		beq.s	.skiplowpal
		addi.w	#$2000,d3	; set first palette line bit
; loc_180A:
.skiplowpal:
		add.b	d1,d1		; is the vertical flip flag set?
		bcc.s	.skipyflip	; if not, branch
		subq.w	#1,d6
		btst	d6,d5
		beq.s	.skipyflip
		ori.w	#$1000,d3	; set Y-flip bit
; loc_1818:
.skipyflip:
		add.b	d1,d1		; is the horizontal flip flag set?
		bcc.s	.skipxflip	; if not, branch
		subq.w	#1,d6
		btst	d6,d5
		beq.s	.skipxflip
		ori.w	#$800,d3	; set X-flip bit
; loc_1826:
.skipxflip:
		move.w	d5,d1
		move.w	d6,d7
		sub.w	a5,d7		; subtract length in bits of inline copy value
		bcc.s	.enoughbits	; branch if a new word doesn't need to be read
		move.w	d7,d6
		addi.w	#16,d6
		neg.w	d7		; calculate bit deficit
		lsl.w	d7,d1		; and make space for that many bits
		move.b	(a0),d5		; get next byte
		rol.b	d7,d5		; and rotate the required bits into the lowest positions
		add.w	d7,d7
		and.w	EniDec_Masks-2(pc,d7.w),d5
		add.w	d5,d1		; combine upper bits with lower bits
; loc_1844:
.maskvalue:
		move.w	a5,d0		; get length in bits of inline copy value
		add.w	d0,d0
		and.w	EniDec_Masks-2(pc,d0.w),d1	; mask value appropriately
		add.w	d3,d1		; add starting art tile
		move.b	(a0)+,d5
		lsl.w	#8,d5
		move.b	(a0)+,d5	; get next word
		rts
; ===========================================================================
; loc_1856:
.enoughbits:
		beq.s	.justenough	; if the word has been exactly exhausted, branch
		lsr.w	d7,d1	; get inline copy value
		move.w	a5,d0
		add.w	d0,d0
		and.w	EniDec_Masks-2(pc,d0.w),d1	; and mask it appropriately
		add.w	d3,d1	; add starting art tile
		move.w	a5,d0
		bra.s	EniDec_FetchByte
; ===========================================================================
; loc_1868:
.justenough:
		moveq	#16,d6	; reset shift value
		bra.s	.maskvalue
; ===========================================================================
; word_186C:
EniDec_Masks:
		dc.w	 1,    3,    7,   $F
		dc.w   $1F,  $3F,  $7F,  $FF
		dc.w  $1FF, $3FF, $7FF, $FFF
		dc.w $1FFF,$3FFF,$7FFF,$FFFF
; ===========================================================================

; sub_188C:
EniDec_FetchByte:
		sub.w	d0,d6	; subtract length of current entry from shift value so that next entry is read next time around
		cmpi.w	#9,d6	; does a new byte need to be read?
		bhs.s	.locret	; if not, branch
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5
.locret:
		rts
; End of function EniDec_FetchByte
; ===========================================================================
