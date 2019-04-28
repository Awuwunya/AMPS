; ---------------------------------------------------------------------------
; Scrap Brain Zone 1 pallet cycling script
; ---------------------------------------------------------------------------
	dc.w 8			; number of entries - 1
	dc.b 7,	8		; duration in frames, number of	colours
	dc.w Pal_SBZCyc1	; pallet pointer
	dc.w $FB50		; RAM address
	dc.b $D, 8
	dc.w Pal_SBZCyc2
	dc.w $FB52
	dc.b $E, 8
	dc.w Pal_SBZCyc3
	dc.w $FB6E
	dc.b $B, 8
	dc.w Pal_SBZCyc5
	dc.w $FB70
	dc.b 7,	8
	dc.w Pal_SBZCyc6
	dc.w $FB72
	dc.b $1C, $10
	dc.w Pal_SBZCyc7
	dc.w $FB7E
	dc.b 3,	3
	dc.w Pal_SBZCyc8
	dc.w $FB78
	dc.b 3,	3
	dc.w Pal_SBZCyc8+2
	dc.w $FB7A
	dc.b 3,	3
	dc.w Pal_SBZCyc8+4
	dc.w $FB7C
	even