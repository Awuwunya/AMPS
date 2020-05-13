; ===========================================================================
; ---------------------------------------------------------------------------
; Routine for loading the Dual PCM driver into Z80 RAM
; ---------------------------------------------------------------------------

LoadDualPCM:
		move	#$2700,sr		; disable interrupts
		move.w	#$0100,$A11100		; request Z80 stop
		move.w	#$0100,$A11200		; Z80 reset off

		lea	DualPCM,a0		; load Dual PCM address into a0
		lea	dZ80,a1			; load Z80 RAM address into a1

.z80
		btst	#$00,$A11100		; check if Z80 has stopped
		bne.s	.z80			; if not, wait more
		jsr	KosDec			; decompress into z80 RAM

		moveq	#2,d0			; set flush timer for 60hz systems
		btst	#6,ConsoleRegion.w	; is this a PAL Mega Drive?
		beq.s	.ntsc			; if not, branch
		moveq	#3,d0			; set flush timer for 50hz systems
.ntsc
		move.b	d0,dZ80+YM_FlushTimer+2	; save flush timer

		move.w	#$0000,$A11200		; request Z80 reset
		moveq	#$7F,d1			; wait for a little bit
		dbf	d1,*			; we can't check for reset, so we need to delay

		move.w	#$0000,$A11100		; enable Z80
		move.w	#$0100,$A11200		; Z80 reset off
		move	#$2300,sr		; enable interrupts
		rts
