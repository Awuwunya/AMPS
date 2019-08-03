; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for running modulation envelope programs
; ---------------------------------------------------------------------------

dModEnvProg:
	if FEATURE_MODENV
		moveq	#0,d4
		move.b	cModEnv(a5),d4		; load modulation envelope ID to d4
		beq.s	locret_SetFilter	; if 0, return

	if safe=1
		AMPS_Debug_ModEnvID		; check if modulation envelope ID is valid
	endif

		lea	ModEnvs-4(pc),a1	; load modulation envelope data array
		add.w	d4,d4			; quadruple modulation envelope ID
		add.w	d4,d4			; (each entry is 4 bytes in size)
		move.l	(a1,d4.w),a1		; get pointer to modulation envelope data

		moveq	#0,d1
		moveq	#0,d0

dModEnvProg2:
		move.b	cModEnvPos(a5),d1	; get envelope position to d1
		move.b	(a1,d1.w),d0		; get the data in that position
		bpl.s	.value			; if positive, its a normal value

		cmp.b	#eLast-2,d0		; check if this is a command
		ble.s	dModEnvCommand		; if it is handle it

.value
		move.b	cModEnvSens(a5),d1	; load sensitivity to d1 (unsigned value - effective range is ~ -$7000 to $8000)
		addq.w	#1,d1			; increment sensitivity by 1 (range of 1 to $100)
		muls	d1,d0			; signed multiply loaded value with sensitivity

		addq.b	#1,cModEnvPos(a5)	; increment envelope position
		add.w	d0,d6			; add the frequency to channel frequency
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine for handling modulation envelope commands
; ---------------------------------------------------------------------------

dModEnvCommand:
	if safe=1
		AMPS_Debug_VolEnvCmd		; check if command is valid
	endif

		jmp	.comm-$80(pc,d0.w)	; jump to command handler

.comm
		bra.s	.reset			; 80 - Loop back to beginning
		bra.s	.hold			; 82 - Hold the envelope at current level
		bra.s	.loop			; 84 - Go to position defined by the next byte
		bra.s	.stop			; 86 - Stop current note and envelope
		bra.s	.seset			; 88 - Set the sensitivity of the modulation envelope
		bra.s	.seadd			; 8A - Add to the sensitivity of the modulation envelope
; ---------------------------------------------------------------------------

.hold
		subq.b	#1,cModEnvPos(a5)	; decrease envelope position
		jmp	dModEnvProg2(pc)	; run the program again (make sure volume fades work)
; ---------------------------------------------------------------------------

.reset
		clr.b	cModEnvPos(a5)		; set envelope position to 0
		jmp	dModEnvProg2(pc)	; run the program again
; ---------------------------------------------------------------------------

.loop
		move.b	1(a1,d1.w),cModEnvPos(a5); set envelope position to the next byte
		jmp	dModEnvProg2(pc)	; run the program again
; ---------------------------------------------------------------------------

.seset
		move.b	1(a1,d1.w),cModEnvSens(a5); set modulation envelope sensitivity
		bra.s	.ignore
; ---------------------------------------------------------------------------

.seadd
		move.b	1(a1,d1.w),d0		; load sensitivity to d0
		add.b	d0,cModEnvSens(a5)	; add to modulation envelope sensitivity
; ---------------------------------------------------------------------------

.ignore		addq.b	#2,cModEnvPos(a5)	; skip the command and the next byte
		jmp	dModEnvProg2(pc)	; run the program again
; ---------------------------------------------------------------------------

.stop
		bset	#cfbRest,(a5)		; set channel resting bit
	dStopChannel	1			; stop channel operation
; ---------------------------------------------------------------------------
	endif
