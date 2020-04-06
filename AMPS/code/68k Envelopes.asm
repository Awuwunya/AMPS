; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for running modulation envelope programs
;
; input:
;   d2 - Input frequency
;   d4 - Envelope ID
;   a1 - Channel to use
; output:
;   d2 - Output frequency
; thrash:
;   d4 - Envelope position
;   d5 - Byte read from envelope data & envelope sensitivity
;   a2 - Used for envelope data address
; ---------------------------------------------------------------------------

dModEnvProg:
	if FEATURE_MODENV
		moveq	#0,d4
		move.b	cModEnv(a1),d4		; load modulation envelope ID to d4
		beq.s	locret_ModEnvProg	; if 0, return

	if safe=1
		AMPS_Debug_ModEnvID		; check if modulation envelope ID is valid
	endif

		lea	ModEnvs-4(pc),a2	; load modulation envelope data array
		add.w	d4,d4			; quadruple modulation envelope ID
		add.w	d4,d4			; (each entry is 4 bytes in size)
		move.l	(a2,d4.w),a2		; get pointer to modulation envelope data

		moveq	#0,d4
		moveq	#0,d5
; ---------------------------------------------------------------------------

dModEnvProg2:
		move.b	cModEnvPos(a1),d5	; get envelope position to d5
		move.b	(a2,d5.w),d4		; get the data in that position
		bpl.s	.value			; if positive, its a normal value

		cmp.b	#eLast-2,d4		; check if this is a command
		ble.s	dModEnvCommand		; if it is handle it

.value
		move.b	cModEnvSens(a1),d5	; load sensitivity to d5 (unsigned value - effective range is ~ -$7000 to $8000)
		addq.w	#1,d5			; increment sensitivity by 1 (range of 1 to $100)
		ext.w	d4			; extend to displacement to a word
		muls	d5,d4			; signed multiply loaded value with sensitivity

		addq.b	#1,cModEnvPos(a1)	; increment envelope position
		add.w	d4,d2			; add the frequency to channel frequency

locret_ModEnvProg:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine for handling modulation envelope commands
; ---------------------------------------------------------------------------

dModEnvCommand:
	if safe=1
		AMPS_Debug_VolEnvCmd		; check if command is valid
	endif

		jmp	.comm-$80(pc,d4.w)	; jump to command handler

.comm
		bra.s	.reset			; 80 - Loop back to beginning
		bra.s	.hold			; 82 - Hold the envelope at current level
		bra.s	.loop			; 84 - Go to position defined by the next byte
		bra.s	.stop			; 86 - Stop current note and envelope
		bra.s	.seset			; 88 - Set the sensitivity of the modulation envelope
		bra.s	.seadd			; 8A - Add to the sensitivity of the modulation envelope
; ---------------------------------------------------------------------------

.hold
		subq.b	#1,cModEnvPos(a1)	; decrease envelope position
		jmp	dModEnvProg2(pc)	; run the program again (make modulation and portamento work)
; ---------------------------------------------------------------------------

.reset
		clr.b	cModEnvPos(a1)		; set envelope position to 0
		jmp	dModEnvProg2(pc)	; run the program again
; ---------------------------------------------------------------------------

.loop
		move.b	1(a2,d5.w),cModEnvPos(a1); set envelope position to the next byte
		jmp	dModEnvProg2(pc)	; run the program again
; ---------------------------------------------------------------------------

.seset
		move.b	1(a2,d5.w),cModEnvSens(a1); set modulation envelope sensitivity
		bra.s	.ignore
; ---------------------------------------------------------------------------

.seadd
		move.b	1(a2,d5.w),d4		; load sensitivity to d4
		add.b	d4,cModEnvSens(a1)	; add to modulation envelope sensitivity
; ---------------------------------------------------------------------------

.ignore
		addq.b	#2,cModEnvPos(a1)	; skip the command and the next byte
		jmp	dModEnvProg2(pc)	; run the program again
; ---------------------------------------------------------------------------

.stop
		bset	#cfbRest,(a1)		; set channel resting bit
	dStopChannel	1			; stop channel operation
; ---------------------------------------------------------------------------
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for running volume envelope programs
;
; input:
;   d1 - Input volume
;   d4 - Envelope ID
;   a1 - Channel to use
; output:
;   d1 - Output volume
; thrash:
;   d4 - Byte read from envelope data
;   a2 - Used for envelope data address
; ---------------------------------------------------------------------------

dVolEnvProg:
	if safe=1
		AMPS_Debug_VolEnvID		; check if volume envelope ID is valid
	endif

		lea	VolEnvs-4(pc),a2	; load volume envelope data array
		add.w	d4,d4			; quadruple volume envelope ID
		add.w	d4,d4			; (each entry is 4 bytes in size)

		move.l	(a2,d4.w),a2		; get pointer to volume envelope data
		moveq	#0,d4
; ---------------------------------------------------------------------------

dVolEnvProg2:
		move.b	cEnvPos(a1),d4		; get envelope position to d4
		move.b	(a2,d4.w),d4		; get the data in that position
		bpl.s	.value			; if positive, its a normal value

		cmp.b	#eLast-2,d4		; check if this is a command
		ble.s	dEnvCommand		; if it is handle it

.value
		addq.b	#1,cEnvPos(a1)		; increment envelope position
		ext.w	d4			; extend volume to a word
		add.w	d4,d1			; add envelope volume to d1
		moveq	#1,d4			; set Z flag to 0

locret_VolEnvProg:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine for handling volume envelope commands
; ---------------------------------------------------------------------------

dEnvCommand:
	if safe=1
		AMPS_Debug_VolEnvCmd		; check if command is valid
	endif

		jmp	.comm-$80(pc,d4.w)	; jump to command handler

.comm
		bra.s	.reset			; 80 - Loop back to beginning
		bra.s	.hold			; 82 - Hold the envelope at current level
		bra.s	.loop			; 84 - Go to position defined by the next byte
		bra.s	.stop			; 86 - Stop current note and envelope
		bra.s	.ignore			; 88 - ignore
		bra.s	.ignore			; 8A - ignore
; ---------------------------------------------------------------------------

.hold
		moveq	#0,d4			; set Z flag to 1
		rts
; ---------------------------------------------------------------------------

.reset
		clr.b	cEnvPos(a1)		; set envelope position to 0
		jmp	dVolEnvProg2(pc)	; run the program again
; ---------------------------------------------------------------------------

.loop
		move.b	cEnvPos(a1),d4		; get envelope position to d4
		move.b	1(a2,d4.w),cEnvPos(a1)	; set envelope position to the next byte
		jmp	dVolEnvProg2(pc)	; run the program again
; ---------------------------------------------------------------------------

.ignore
		addq.b	#2,cEnvPos(a1)		; skip the command and the next byte
		jmp	dVolEnvProg2(pc)	; run the program again
; ---------------------------------------------------------------------------

.stop
		bset	#cfbRest,(a1)		; set channel resting bit
	dStopChannel	0			; stop channel operation
		moveq	#0,d4			; set Z flag to 1
		rts
; ---------------------------------------------------------------------------
