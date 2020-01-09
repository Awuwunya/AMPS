; ===========================================================================
; This function writes a hexadecimal number into screen at specific coordinates.
; input:
;  d3 - number to write. Is destroyed
; ===========================================================================
PutHex:
		move.w	d6,d5			; copy length
.loop		move.b	d3,d4			; get next nibble
		andi.w	#%1111,d4		; keep the nibble only
		addq.b	#1,d4			; increment 1 (to skip null)
		move.w	d4,-(sp)		; then store the number on plane
		ror.l	#4,d3			; rotate right four times, to get the next nibble.
						; Also returns d3 to original value
		dbf	d6,.loop		; loop until full number is done

.write		move.w	(sp)+,(a5)		; copy number to VRAM
		dbf	d5,.write		; write for so many bytes as we need
		rts
