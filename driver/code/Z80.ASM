; ===========================================================================
; ---------------------------------------------------------------------------
; DUAL-PCM - by MarkeyJester
; ---------------------------------------------------------------------------

M_Read		macro
		ldi					; 16	; copy from window to buffer, and increment register
		zadd	a,b	 			; 04	; add dividend
		adc	hl,sp				; 15	; add quotient
		endm					; Total: 35

; ---------------------------------------------------------------------------

M_CapPCM	macro
		jp	po, .ov\@			; 10	; if the sample hasn't overflown the 7F/80 boundary, branch
		sbc	a,a				; 04	; erase sample, and subtract the carry to get either FF or 00, depending on overflow direction
		xor	07Fh				; 07	; reverse FF/00 (xor 80 below helps)
.ov\@		xor	080h				; 07	; convert to unsigned
		endm					; Total: 17/28

; ---------------------------------------------------------------------------

M_Flush01	macro
		ld	e,(hl)				; 07	; load byte from OUT buffer 1 to volume pointer
		ld	a,(de)				; 07	; copy to a
		zset	001h,h				; 08	; move forwards to OUT buffer 2
		inc	d				; 04	; move forwards to volume pointer 2
		ld	e,(hl)				; 07	; load byte from OUT buffer 2 to volume pointer
		ex	de,hl				; 04	; swap for hl powers
		zadd	a,(hl)				; 07	; add volume 2 to volume 1
		ex	de,hl				; 04	; swap back
		M_CapPCM					; cap the sample overflow
		ld	(bc),a				; 07	; save to the YM2612
		inc	l				; 04	; advance OUT buffers
		endm					; Total: 59

; ---------------------------------------------------------------------------

M_Flush02	macro
		ld	e,(hl)				; 07	; load byte from OUT buffer 2 to volume pointer
		ld	a,(de)				; 07	; copy to a
		res	001h,h				; 08	; move back to OUT buffer 1
		dec	d				; 04	; move back to volume pointer 1
		ld	e,(hl)				; 07	; load byte from OUT buffer 1 to volume pointer
		ex	de,hl				; 04	; swap for hl powers
		zadd	a,(hl)				; 07	; add volume 1 to volume 2
		ex	de,hl				; 04	; swap back
		M_CapPCM					; cap the sample overflow
		ld	(bc),a				; 07	; save to the YM2612
		inc	l				; 04	; advance OUT buffers
		endm					; Total: 59

; ---------------------------------------------------------------------------

M_Revert01	macro
		res	001h,h				; 08	; move back to OUT buffer 1
		dec	d				; 04	; move back to volume pointer 1
		dec	l				; 04	; move OUT buffers back
		endm

; ---------------------------------------------------------------------------

M_Revert02	macro
		zset	001h,h				; 08	; move forwards to OUT buffer 2
		inc	d				; 04	; move forwards to volume pointer 2
		dec	l				; 04	; move OUT buffers back
		endm

; ---------------------------------------------------------------------------

M_Wrap		macro
		dec	l				; 04	; check l...
		inc	l				; 04	; ''
		M_WrapCondition
		endm

; ---------------------------------------------------------------------------

M_WrapCondition	macro
		jp	nz, .c\@			; 10	; if it's not 0, branch
		inc	h				; 04	; advance OUT buffers
		bit	004h,h				; 08	; have the OUT buffer addresses reached 1000 (end of buffer) yet?
		jp	z, .c\@				; 10	; if not, branch
		ld	hl,PCM_Buffer2			; 10	; reset OUT buffers
.c\@
		endm

; ===========================================================================
; ---------------------------------------------------------------------------
; Start of Z80 ROM
; ---------------------------------------------------------------------------

Z80_Start:
		di					; 04	; disable interrupts
		im	1				;	; If this line does not exist, some early Mega Drives will shit their bricks
		xor	a				; 04	; clear refresh register and interrupt index (since I can't use "im  2" on certain emulators).
		ld	r,a				; 08	; ''
		ld	i,a				; 08	; ''
		jp	Z80_Init			; 10	; jump to the rest of the init routine

		align	MaxPitch/$100

	; The space from "Start" until the maximum pitch amount, is the space
	; where data could potentially be pushed into, thanks to the sp.

	; The sp will likely be from roughly FFEF - 000F for the quotient of
	; the pitch.  Now, FFEF - FFFF will be fine, since that points to the
	; 68k window, which will be pointing to 68k ROM, so nothing will happen.
	; But the address from 0000 - 000F points to the beginning of ROM, so
	; this place must be free from use outside of V-blank.

Z80_Stack:

; ===========================================================================
; ---------------------------------------------------------------------------
; PCM 1 Resetting
; ---------------------------------------------------------------------------
		align	010h
; ---------------------------------------------------------------------------

BreakLate:
		dec	iyh				; 08	; set "restore mode"
		ld	sp,Z80_Stack			; 10	; load valid stack address
		push	af				; 11	; store a and flags
		jp	BVB_Check			; 10	; jump to V-blank routine

; ===========================================================================
; ---------------------------------------------------------------------------
; PCM 1 Resetting
; ---------------------------------------------------------------------------
		align	028h
; ---------------------------------------------------------------------------

PCM1_ResetJmp:
		jp	PCM1_Reset			; 10	; jump to actual routine

; ===========================================================================
; ---------------------------------------------------------------------------
; PCM 2 Resetting
; ---------------------------------------------------------------------------
		align	030h
; ---------------------------------------------------------------------------

PCM2_ResetJmp:
		jp	PCM2_Reset			; 10	; jump to actual routine

; ===========================================================================
; ---------------------------------------------------------------------------
; Breaking out for V-blank
; ---------------------------------------------------------------------------
		align	038h
; ---------------------------------------------------------------------------

BreakVBlank:
		push	af				; 11	; store a and flags
		ld	a,(YM_Buffer)			; 13	; load buffer to write to
		cpl					; 04	; change buffer
		ld	(YM_Buffer),a			; 13	; update...

BVB_Check:
		ld	a,iyl				; 08	; load iyl
		zor	a				; 04	; check read status (FF = Bank | 00 = Non-Read | 01 = Window)
		jp	nz,BreakDMA			; 10	; if the interrupt is happening during bank or window reading, branch

; ---------------------------------------------------------------------------
; Breaking out for V-blank, during non-read
; ---------------------------------------------------------------------------

BreakPrep:
		ld	a,011000111b|BreakLate		; 07	; prepare "rst" instruction
		ld	(Int1_nop),a			; 13	; change instructions
		ld	(Int2_nop),a			; 13	; ''
		ld	(Int1_lda),a			; 13	; ''
		ld	(Int2_lda),a			; 13	; ''
		ld	(Int1_jp),a			; 13	; ''
		ld	(Int2_jp),a			; 13	; ''
		ld	(Int1_ldhl),a			; 13	; ''
		ld	(Int2_ldhl),a			; 13	; ''
		ld	(PCM1_ResQuo),a			; 13	; ''
		ld	(PCM2_ResQuo),a			; 13	; ''
		pop	af				; 10	; restore a register and flags
	;	ei					; 04	; enable interrupts
		reti					; 14	; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Breaking out for V-blank, during read of window or bank register
; ---------------------------------------------------------------------------

BreakDMA:
		jp	m,BreakBank			; 10	; if it's setting up a bank, branch

	; --- Finding out which registers we're dealing with ---

		ld	a,h				; 04	; load "h" to check which set of instructions we're dealing with
		zor	a				; 04	; is the hl pointer negative?
		jp	m,BDMA_ReadSet			; 10	; if so, then it's pointing to the window, and is the read set
			cp	PCM_Buffer1>>008h		; 07	; is the buffer address exchanged with de? (i.e. is hl at volume instead of buffer)
			jp	p,BDMA_NoExchange		; 10	; if not, branch
			ex	de,hl				; 04	; swap de/hl back to normal
			jp	BDMA_NoFixVolume		; 10	; jump to increment "l" and just finish (that's all it needs to do)
BDMA_NoExchange:	rra					; 04	; get buffer we're currently reading from
			xor	l				; 04	; xor with lower bit of address
			zand	001h				; 07	; get only the bit
			jr	nz,BDMA_NoFixFlush		; 12 07	; the lower bit of address will be in sync with the OUT buffer we're reading, they don't match, we're fine~
			ld	a,d				; 04	; load volume buffer upper address
			xor	l				; 04	; xor with lower bit of address
			zand	001h				; 07	; get only the bit
			jr	z,BDMA_NoFixVolume		; 12 07	; if the volume buffer is in sync, branch
			xor	d				; 04	; reverse the bit (change the buffer)
			ld	d,a				; 04	; ''
BDMA_NoFixVolume:	inc	l				; 04	; sync the address up
BDMA_NoFixFlush:	exx					; 04	; swap to the "read" set of exx registers
BDMA_ReadSet:

; ---------------------------------------------------------------------------
; Flush remaining data
; ---------------------------------------------------------------------------

BreakBank:
			exx					; 04	; switch registers
			ld	a,l				; 04	; get buffer position
			exx					; 04	; switch registers
		zneg	a				; 08	; reverse position
		zand	00Fh				; 07	; get remaining flushes to do...
		jp	nz,BDMA_NoMax			; 10	; if flushing has started, branch
		ld	a,010h				; 07	; set to maximum

BDMA_NoMax:
		inc	a				; 04	; increase by 1 (when dividing by 2, the bit is set for djnz)
		sra	a				; 08	; shift odd/even bit into carry
		ld	d,a				; 04	; copy to d (won't affect carry)
		jp	nc,BDMA_Flush01			; 10	; if carry was set originally, branch (is not carry only because of "inc a")
		jp	BDMA_Flush02

BDMA_FlushLoop:
Z80_VBlank2:	ld	b,00Ch				; 07	; delay...
		djnz	*				; 13 08	; '' (106)

BDMA_Flush02:
			exx					; 04	; switch registers
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
Z80_VBlank1:	ld	b,00Ch				; 07	; delay...
		djnz	*				; 13 08	; '' (106)

BDMA_Flush01:
			exx					; 04	; switch registers
			M_Flush01				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
		dec	d				; 04	; decrease counter
		jp	nz,BDMA_FlushLoop		; 10	; if we're not finished, branch

; ---------------------------------------------------------------------------
; Wrapping OUT buffers
; ---------------------------------------------------------------------------

			exx					; 04	; switch registers
			M_Wrap
			exx					; 04	; switch back

; ---------------------------------------------------------------------------
; Restore interrupt instructions
; ---------------------------------------------------------------------------

		ld	a,iyh				; 08	; load restore mode
		zor	a				; 04	; has it been set?
		jp	z,BDMA_NoRestore		; 10	; if not, branch
		xor	a				; 04	; prepare "nop" instruction
		ld	iyh,a				; 08	; clear restore mode
		ld	(Int1_nop),a			; 13	; change instructions
		ld	(Int2_nop),a			; 13	; ''
		ld	a,07Eh				; 07	; prepare "ld  a,(hl)" instruction
		ld	(Int1_lda),a			; 13	; change instructions
		ld	(Int2_lda),a			; 13	; ''
		ld	a,0C3h				; 07	; prepare "jp" instruction
		ld	(Int1_jp),a			; 13	; change instructions
		ld	(Int2_jp),a			; 13	; ''
		ld	a,077h				; 07	; prepare "ld  (hl),a" instruction
		ld	(Int1_ldhl),a			; 13	; change instrucitons
		ld	(Int2_ldhl),a			; 13	; ''
		ld	a,031h				; 07	; prepare "ld  sp,0????h" instruction
		ld	(PCM1_ResQuo),a			; 13	; change instrucitons
		ld	(PCM2_ResQuo),a			; 13	; ''

BDMA_NoRestore:

; ---------------------------------------------------------------------------
; YM2612 flushing
; ---------------------------------------------------------------------------

YM_FlushTimer:	ld	ixh,002h

		ld	sp,YM_Buffer1			; 16	; load buffer 1 address
		ld	a,(YM_Buffer)			; 13	; load buffer we're writing to
		zor	a				; 04	; are we writing to buffer 1?
		jr	z,YMF_Buff1			; 12 07	; if so, branch
		ld	sp,YM_Buffer2			; 16	; load buffer 2 address

YMF_Buff1:
	pop	de
	ld	a,e
	zor	a
	jp	m,PCM_Flush_exx
	push	de
		ld	h,040h				; 07	; prepare YM2612 address
			exx					; 04	; switch registers back

YM_Flush:
			ld	ixl,010h/002h			; 11	; set ix low byte to number of bytes to flush

YMF_NextByte:
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
		dec	sp				; 06	; move back (to get YM address)
		pop	af				; 10	; get YM address
		zor	a				; 04	; is this the end of the list?
		jp	m,YMF_Finish02			; 10	; if so, branch
		ld	l,a				; 04	; ''
		pop	de				; 10	; load address/data
		ld	(hl),d				; 07	; set address
		inc	l				; 04	; advance to data port
		ld	(hl),e				; 07	; set data
Z80_DelayYM1:	ld	b,007h				; 07	; delay a little longer...
		djnz	*				; 13 08	; ''
		ld	l,b				; 04	; move address to 4000
		ld	(hl),02Ah			; 10	; reset YM2612 to DAC port address
			exx					; 04	; switch registers
			M_Flush01				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
		dec	sp				; 06	; move back (to get YM address)
		pop	af				; 10	; get YM address
		zor	a				; 04	; is this the end of the list?
		jp	m,YMF_Finish01			; 10	; if so, branch
		ld	l,a				; 04	; ''
		pop	de				; 10	; load address/data
		ld	(hl),d				; 07	; set address
		inc	l				; 04	; advance to data port
		ld	(hl),e				; 07	; set data
Z80_DelayYM2:	ld	b,006h				; 07	; delay a little longer...
		djnz	*				; 13 08	; ''
		ld	l,b				; 04	; move address to 4000
		ld	(hl),02Ah			; 10	; reset YM2612 to DAC port address
			exx					; 04	; switch registers
			dec	ixl				; 08	; decrease ix low byte counter
			jp	nz,YMF_NextByte			; 10	; if it hasn't finished, branch

	; --- Advance/Wrap OUT buffers ---

			M_Wrap
			dec	ixh				; 08	; decrease ix high byte counter
			jp	YM_Flush			; 10	; loop back...

YMF_Finish02:
		ld	a,02Ah
		ld	(04000h),a
Z80_DelayYM3:	ld	b,007h
		jr	YMF_Enter02

YMF_Finish01:
		ld	a,02Ah
		ld	(04000h),a
Z80_DelayYM4:	ld	b,007h
		jr	YMF_Enter01

; ---------------------------------------------------------------------------
; Waiting for v-blank to finish
; ---------------------------------------------------------------------------

PCM_Flush_exx:
			exx

PCM_Flush:
			ld	ixl,010h/002h			; 11	; set ix low byte to number of bytes to flush

PCM_NextByte:
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
Z80_DelayEnd1:	ld	b,00Ch				; 07	; delay a little longer...
YMF_Enter02:	djnz	*				; 13 08	; ''


			exx					; 04	; switch registers
			M_Flush01				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers

Z80_DelayEnd2:	ld	b,00Ch				; 07	; delay a little longer...
YMF_Enter01:	djnz	*				; 13 08	; ''

			exx					; 04	; switch registers
			dec	ixl				; 08	; decrease ix low byte counter
			jp	nz,PCM_NextByte			; 10	; if it hasn't finished, branch

	; --- Advance/Wrap OUT buffers ---

			M_Wrap

			dec	ixh				; 08	; decrease ix high byte counter
			jp	p,PCM_Flush			; 10	; if we're not ready to go back to main loop, branch
		exx					; 04	; switch registers down again...

		ld	hl,YM_Buffer1			; 16	; load buffer 1 address
		ld	a,(YM_Buffer)			; 13	; load buffer we're writing to
		zor	a				; 04	; are we writing to buffer 1?
		jr	z,YMF_SetBuff1			; 12 07	; if so, branch
		ld	hl,YM_Buffer2			; 16	; load buffer 2 address

YMF_SetBuff1:
		ld	(hl),0FFh			; 10	; set end marker at beginning of list

		ld	a,(PCM1_VolTimer+001h)		; 13	; load timer
		dec	a				; 07	; decrease timer
		jp	m,VB_PCM1_VolOK			; 10	; if it was at 0, branch
		ld	(PCM1_VolTimer+001h),a		; 13	; update timer

VB_PCM1_VolOK:
		ld	a,(PCM2_VolTimer+001h)		; 13	; load timer
		dec	a				; 07	; decrease timer
		jp	m,VB_PCM2_VolOK			; 10	; if it was at 0, branch
		ld	(PCM2_VolTimer+001h),a		; 13	; update timer

VB_PCM2_VolOK:

		scf					; 04	; set carry flag

PCM_VolChangeDel:jp	c,PCM_VolChangeNo
		ld	a,011011010b			; 07	; clear request flag
		ld	(PCM_VolChangeDel),a		; 13	; ''
		ld	(PCM_VolumeAlter),a		; 13	; ''
PCM1_VolumeNext:ld	a,000h
		ld	(PCM1_VolumeNew+001h),a
PCM2_VolumeNext:ld	a,000h
		ld	(PCM2_VolumeNew+001h),a

PCM_VolChangeNo:


		ld	sp,Z80_Stack			; 10	; set valid stack address
		ld	iy,00000h			; 14	; reset interrupt status
Z80_Int1:	ei					; 04	; enabled interrupts
		jp	CatchUp				; 10	; continue to main flush routine

; ===========================================================================
; ---------------------------------------------------------------------------
; Setup/Init
; ---------------------------------------------------------------------------

Z80_Init:
			ld	sp,Z80_Stack			; 10	; set stack addre

	; --- Final register setup ---

			ld	bc,04000h			; 10	; prepare YM2612 port address
			ld	a,02Ah				; 07
			ld	(bc),a				; 07
			inc	c				; 04
			ld	d,(PCM_Volume2>>008h)&0FFh	; 07	; prepare volume list address (upper byte only)
			ld	hl,PCM_Buffer2			; 10	; prepare OUT buffer 2

			ld	iy,00000h			; 14	; reset interrupt status
			ei					; 04	; enable VDP interruption

			exx					; 04	; switch registers

; ===========================================================================
; ---------------------------------------------------------------------------
; The catch up loop
; ---------------------------------------------------------------------------

CatchUp:
			exx					; 04	; switch registers

CatchUp_Exx:
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers

Z80_Int2:	;ei
		znop					; 04

; ---------------------------------------------------------------------------
; PCM 1
; ---------------------------------------------------------------------------

PCM1_MuteRet:
		ld	hl,06001h			; 10	; load bank switch register port
		dec	iyl				; 08	; set bank interrupt
Int1_nop:	znop					; 04	; CANNOT CHANGE "ld  (hl),h" since it's altered by Z80 elsewhere
PCM1_Switch:	db	74h|((SWF_Stop>>0Fh)&1)		; 07	; 0000 0000 1  32KB -  64KB (  8000 -   10000)
		db	74h|((SWF_Stop>>10h)&1)		; 07	; 0000 0001 0  64KB - 128KB ( 10000 -   20000)
		db	74h|((SWF_Stop>>11h)&1)		; 07	; 0000 0010 0 128KB - 256KB ( 20000 -   40000)
		db	74h|((SWF_Stop>>12h)&1)		; 07	; 0000 0100 0 256KB - 512KB ( 40000 -   80000)
		db	74h|((SWF_Stop>>13h)&1)		; 07	; 0000 1000 0 512KB -   1MB ( 80000 -  100000)
		db	74h|((SWF_Stop>>14h)&1)		; 07	; 0001 0000 0   1MB -   2MB (100000 -  200000)
		db	74h|((SWF_Stop>>15h)&1)		; 07	; 0010 0000 0   2MB -   4MB (200000 -  400000)
		db	74h|((SWF_Stop>>16h)&1)		; 07	; 0100 0000 0   4MB -   8MB (400000 -  800000)
		ld	(hl),h				; 07	; 1000 0000 0   8MB -  16MB (800000 - 1000000)
		inc	iyl				; 08	; set non-read interrupt
PCM1_OverflwCur:ld	bc,Z80E_Read			; 10	; prepare amount to get to end of window
		ld	hl,(PCM1_SampCur+001h)		; 16	; load sample current address
		ld	a,(PCM1_PitchCur+001h)		; 13	; ''
PCM1_OverflwDiv:zadd	a,000h				; 07	; add fraction overflow
		adc	hl,bc				; 15	; advance address
		jp	p,PCM1_PrepReset		; 10	; if the address has gone outside the window, branch
			exx					; 04	; switch registers
			M_Flush01				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
		inc	iyl				; 08	; set window interrupt
Int1_lda:	ld	a,(hl)				; 07	; load PCM byte at the next ending address
		zor	a				; 04	; is it an end marker? (00)
		jp	z,PCM1_Mute			; 10	; if so, branch to mute...

PCM1_PrepRet:

PCM1_SampCur:	ld	hl,08000h|(SWF_Stop&7FFFh)	; 10	; load PCM sample address
PCM1_Buffer:	ld	de,PCM_Buffer1			; 10	; load IN buffer address
PCM1_PitchQuo:	ld	sp,00000h			; 10	; load pitch quotient
PCM1_PitchDiv:	ld	bc,000FFh			; 10	; load pitch dividend (and counter for ldi)
PCM1_PitchCur:	ld	a,000h				; 07	; load current pitch dividend

PCM1_PreInst01:	M_Read
PCM1_PreInst02:	M_Read
PCM1_PreInst03:	ldi					; 16	; copy from window to buffer, and increment register
			exx					; 04	; switch registers
			ex	af,af				; 04	; store dividend
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
			ex	af,af				; 04	; restore dividend
		zadd	a,b				; 04	; add dividend
		adc	hl,sp				; 15	; add quotient
PCM1_PreInst04:	M_Read
PCM1_PreInst05:	M_Read
PCM1_PreInst06:	M_Read
PCM1_PreInst07:	M_Read
			exx					; 04	; switch registers
			ex	af,af				; 04	; store dividend
			M_Flush01				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
			ex	af,af				; 04	; restore dividend
PCM1_PreInst08:	M_Read
PCM1_PreInst09:	M_Read
PCM1_PreInst0A:	M_Read
PCM1_PreInst0B:	M_Read
PCM1_PreInst0C:	ldi					; 16	; copy from window to buffer, and increment register
			exx					; 04	; switch registers
			ex	af,af				; 04	; store dividend
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
			ex	af,af				; 04	; restore dividend
		zadd	a,b				; 04	; add dividend
		adc	hl,sp				; 15	; add quotient
PCM1_PreInst0D:	M_Read
PCM1_PreInst0E:	M_Read
PCM1_PreInst0F:	M_Read
PCM1_PreInst10:	M_Read
			exx					; 04	; switch registers
			ex	af,af				; 04	; store dividend
			M_Flush01				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
			ex	af,af				; 04	; restore dividend
PCM1_PreInst11:	M_Read
PCM1_PreInst12:	M_Read
PCM1_PreInst13:	M_Read
PCM1_PreInst14:	M_Read
PCM1_PreInst15:	ldi					; 16	; copy from window to buffer, and increment register
			exx					; 04	; switch registers
			ex	af,af				; 04	; store dividend
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
			ex	af,af				; 04	; restore dividend
		zadd	a,b				; 04	; add dividend
		adc	hl,sp				; 15	; add quotient
PCM1_PreInst16:	M_Read
PCM1_PreInst17:	M_Read
PCM1_PreInst18:	M_Read
		ld	sp,Z80_Stack			; 10	; set valid stack
		dec	iyl				; 08	; set non-read interrupt
		ld	(UPD1_Buffer+001h),de		; 20	; update IN buffer address
			exx					; 04	; switch registers
			ex	af,af				; 04	; store dividend
			M_Flush01				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
			ex	af,af				; 04	; restore dividend
		ld	(UPD1_SampCur+001h),hl		; 16	; update sample address
		ld	(UPD1_PitchCur+001h),a		; 13	; update pitch fraction

; ---------------------------------------------------------------------------
; PCM 2
; ---------------------------------------------------------------------------

PCM2_MuteRet:
		ld	hl,06001h			; 10	; load bank switch register port
		dec	iyl				; 08	; set bank interrupt
Int2_nop:	znop					; 04	; CANNOT CHANGE "ld  (hl),h" since it's altered by Z80 elsewhere
PCM2_Switch:	db	74h|((SWF_Stop>>0Fh)&1)		; 07	; 0000 0000 1  32KB -  64KB (  8000 -   10000)
		db	74h|((SWF_Stop>>10h)&1)		; 07	; 0000 0001 0  64KB - 128KB ( 10000 -   20000)
		db	74h|((SWF_Stop>>11h)&1)		; 07	; 0000 0010 0 128KB - 256KB ( 20000 -   40000)
		db	74h|((SWF_Stop>>12h)&1)		; 07	; 0000 0100 0 256KB - 512KB ( 40000 -   80000)
		db	74h|((SWF_Stop>>13h)&1)		; 07	; 0000 1000 0 512KB -   1MB ( 80000 -  100000)
		db	74h|((SWF_Stop>>14h)&1)		; 07	; 0001 0000 0   1MB -   2MB (100000 -  200000)
		db	74h|((SWF_Stop>>15h)&1)		; 07	; 0010 0000 0   2MB -   4MB (200000 -  400000)
		db	74h|((SWF_Stop>>16h)&1)		; 07	; 0100 0000 0   4MB -   8MB (400000 -  800000)
		ld	(hl),h				; 07	; 1000 0000 0   8MB -  16MB (800000 - 1000000)
		inc	iyl				; 08	; set non-read interrupt
PCM2_OverflwCur:ld	bc,Z80E_Read			; 10	; prepare amount to get to end of window
		ld	hl,(PCM2_SampCur+001h)		; 16	; load sample current address
			exx					; 04	; switch registers
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
		ld	a,(PCM2_PitchCur+001h)		; 13	; ''
PCM2_OverflwDiv:zadd	a,000h				; 07	; add fraction overflow
		adc	hl,bc				; 15	; advance address
		jp	p,PCM2_PrepReset		; 10	; if the address has gone outside the window, branch
		inc	iyl				; 08	; set window interrupt
Int2_lda:	ld	a,(hl)				; 07	; load PCM byte at the next ending address
		zor	a				; 04	; is it an end marker? (00)
		jp	z,PCM2_Mute			; 10	; if so, branch to mute...

PCM2_PrepRet:

PCM2_SampCur:	ld	hl,08000h|(SWF_Stop&7FFFh)	; 10	; load PCM sample address
PCM2_Buffer:	ld	de,PCM_Buffer2			; 10	; load IN buffer address
PCM2_PitchQuo:	ld	sp,00000h			; 10	; load pitch quotient
PCM2_PitchDiv:	ld	bc,000FFh			; 10	; load pitch dividend (and counter for ldi)
PCM2_PitchCur:	ld	a,000h				; 07	; load current pitch dividend

PCM2_PreInst01:	M_Read
			exx					; 04	; switch registers
			ex	af,af				; 04	; store dividend
			M_Flush01				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
			ex	af,af				; 04	; restore dividend
PCM2_PreInst02:	M_Read
PCM2_PreInst03:	M_Read
PCM2_PreInst04:	M_Read
PCM2_PreInst05:	M_Read
PCM2_PreInst06:	ldi					; 16	; copy from window to buffer, and increment register
			exx					; 04	; switch registers
			ex	af,af				; 04	; store dividend
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
			ex	af,af				; 04	; restore dividend
		zadd	a,b				; 04	; add dividend
		adc	hl,sp				; 15	; add quotient
PCM2_PreInst07:	M_Read
PCM2_PreInst08:	M_Read
PCM2_PreInst09:	M_Read
PCM2_PreInst0A:	M_Read
			exx					; 04	; switch registers
			ex	af,af				; 04	; store dividend
			M_Flush01				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
			ex	af,af				; 04	; restore dividend
PCM2_PreInst0B:	M_Read
PCM2_PreInst0C:	M_Read
PCM2_PreInst0D:	M_Read
PCM2_PreInst0E:	M_Read
PCM2_PreInst0F:	ldi					; 16	; copy from window to buffer, and increment register
			exx					; 04	; switch registers
			ex	af,af				; 04	; store dividend
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
			ex	af,af				; 04	; restore dividend
		zadd	a,b				; 04	; add dividend
		adc	hl,sp				; 15	; add quotient
PCM2_PreInst10:	M_Read
PCM2_PreInst11:	M_Read
PCM2_PreInst12:	M_Read
PCM2_PreInst13:	M_Read
			exx					; 04	; switch registers
			ex	af,af				; 04	; store dividend
			M_Flush01				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
			ex	af,af				; 04	; restore dividend
PCM2_PreInst14:	M_Read
PCM2_PreInst15:	M_Read
PCM2_PreInst16:	M_Read
PCM2_PreInst17:	M_Read
PCM2_PreInst18:	ldi					; 16	; copy from window to buffer, and increment register
			exx					; 04	; switch registers
			ex	af,af				; 04	; store dividend
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
			ex	af,af				; 04	; restore dividend
		zadd	a,b				; 04	; add dividend
		adc	hl,sp				; 15	; add quotient
		ld	sp,Z80_Stack			; 10	; set valid stack
		dec	iyl				; 08	; set non-read interrupt
		ld	(PCM2_Buffer+001h),de		; 20	; update IN buffer address
		ld	(PCM2_SampCur+001h),hl		; 16	; update sample address
		ld	(PCM2_PitchCur+001h),a		; 13	; update pitch fraction

UPD1_Buffer:	ld	hl,PCM_Buffer1			; 10	; update IN buffer address
		ld	(PCM1_Buffer+001h),hl		; 16	; ''
UPD1_SampCur:	ld	hl,08000h			; 10	; update sample address
		ld	(PCM1_SampCur+001h),hl		; 16	; ''
UPD1_PitchCur:	ld	a,000h				; 07	; update pitch fraction
		ld	(PCM1_PitchCur+001h),a		; 13	; ''

; ---------------------------------------------------------------------------
; Wrapping OUT buffers
; ---------------------------------------------------------------------------

			exx					; 04	; switch registers
			M_Flush01				; 59	; flush a byte to the YM2612
			M_WrapCondition
			exx					; 04	; switch back

; ---------------------------------------------------------------------------
; Wrap IN buffers
; ---------------------------------------------------------------------------

		bit	001h,d				; 08	; have the IN buffer addresses reached the end yet?
		jp	nz,PCM_BuffNoReset		; 10	; if not, branch
		ld	hl,PCM_Buffer1			; 10	; reset IN buffer
		ld	(PCM1_Buffer+001h),hl		; 16	; ''
		ld	de,PCM_Buffer2			; 10	; reset IN buffer
		ld	(PCM2_Buffer+001h),de		; 20	; ''

PCM_BuffNoReset:

; ---------------------------------------------------------------------------
; Rebank...
; ---------------------------------------------------------------------------

		scf					; 04	; set carry flag
PCM1_ChangeBank:jp	c,PCM1_IgnoreBank		; 10	; if the bank list doesn't need changing, branch
		ld	a,011011010b			; 07	; clear request flag
		ld	(PCM1_ChangeBank),a		; 13	; ''
		push	de				; 10	; store de
		ld	hl,PCM1_BankCur			; 10	; address of bank ID
		ld	de,PCM1_Switch			; 10	; load PCM switch list to edit
		ld	a,(PCM1_PitchQuo+001h)		; 13	; load pitch quotient
		call	SwitchBank			; 17	; change the bank address
		pop	de				; 11	; restore de
		scf					; 04	; set carry flag

PCM1_IgnoreBank:
PCM2_ChangeBank:jp	c,PCM2_IgnoreBank		; 10	; if the bank list doesn't need changing, branch
		ld	a,011011010b			; 07	; clear request flag
		ld	(PCM2_ChangeBank),a		; 13	; ''
		push	de				; 10	; store de
		ld	hl,PCM2_BankCur			; 10	; address of bank ID
		ld	de,PCM2_Switch			; 10	; load PCM switch list to edit
		ld	a,(PCM2_PitchQuo+001h)		; 13	; load pitch quotient
		call	SwitchBank			; 17	; change the bank address
		pop	de				; 11	; restore de
		scf					; 04	; set carry flag

PCM2_IgnoreBank:

; ---------------------------------------------------------------------------
; Pitch control
; ---------------------------------------------------------------------------

PCM1_ChangePitch:jp	c,PCM1_IgnorePitch		; 10	; if the 68k hasn't requested pitch change, branch
		ld	a,011011010b			; 07	; clear request flag
		ld	(PCM1_ChangePitch),a		; 13	; ''

		ld	h,(PCM_OverflwCalc>>008h)&0FFh	; 07	; load overflow multiplication table
PCM1_PitchHigh:	ld	a,001h				; 07	; load upper byte pitch
		dec	a				; 04	; convert for "ldi" on read set (ldi auto increments hl by 1)
		ld	c,a				; 04	; save lower byte
		zadd	a,a				; 04	; sign extend to word
		sbc	a,a				; 04	; ''
		ld	b,a				; 04	; save extended byte
		ld	(PCM1_PitchQuo+001h),bc		; 20	; save pitch quotient
PCM1_PitchLow:	ld	a,000h				; 07	; load lower byte pitch
		ld	(PCM1_PitchDiv+002h),a		; 13	; save pitch fraction
		inc	bc				; 06	; convert back to normal pitch again
		ld	l,a				; 04	; multiply fraction by read amount
		ld	a,(hl)				; 07	; ''
		ld	(PCM1_OverflwDiv+001h),a	; 13	; save overflow fraction
		inc	h				; 04	; advance to carry values
		ld	a,(hl)				; 07	; load read fraction carry
		dec	h				; 04	; go back to multiply values
		ld	l,c				; 04	; multiply lower byte and add with carry values
		zadd	a,(hl)				; 07	; ''
		ld	(PCM1_OverflwCur+001h),a	; 13	; save overflow quotient (low byte)
		inc	h				; 04	; advance to carry values
		ld	a,(hl)				; 07	; load read quotient carry
		dec	h				; 04	; go back to multiply values
		ld	l,b				; 04	; multiply upper byte and add with carry values
		adc	a,(hl)				; 07	; ''
		ld	(PCM1_OverflwCur+002h),a	; 13	; save overflow quotient (high byte)
		scf					; 04	; set carry flag

PCM1_IgnorePitch:

PCM2_ChangePitch:jp	c,PCM2_IgnorePitch		; 10	; if the 68k hasn't requested pitch change, branch
		ld	a,011011010b			; 07	; clear request flag
		ld	(PCM2_ChangePitch),a		; 13	; ''

		ld	h,(PCM_OverflwCalc>>008h)&0FFh	; 07	; load overflow multiplication table
PCM2_PitchHigh:	ld	a,001h				; 07	; load upper byte pitch
		dec	a				; 04	; convert for "ldi" on read set (ldi auto increments hl by 1)
		ld	c,a				; 04	; save lower byte
		zadd	a,a				; 04	; sign extend to word
		sbc	a,a				; 04	; ''
		ld	b,a				; 04	; save extended byte
		ld	(PCM2_PitchQuo+001h),bc		; 20	; save pitch quotient
PCM2_PitchLow:	ld	a,000h				; 07	; load lower byte pitch
		ld	(PCM2_PitchDiv+002h),a		; 13	; save pitch fraction
		inc	bc				; 06	; convert back to normal pitch again
		ld	l,a				; 04	; multiply fraction by read amount
		ld	a,(hl)				; 07	; ''
		ld	(PCM2_OverflwDiv+001h),a	; 13	; save overflow fraction
		inc	h				; 04	; advance to carry values
		ld	a,(hl)				; 07	; load read fraction carry
		dec	h				; 04	; go back to multiply values
		ld	l,c				; 04	; multiply lower byte and add with carry values
		zadd	a,(hl)				; 07	; ''
		ld	(PCM2_OverflwCur+001h),a	; 13	; save overflow quotient (low byte)
		inc	h				; 04	; advance to carry values
		ld	a,(hl)				; 07	; load read quotient carry
		dec	h				; 04	; go back to multiply values
		ld	l,b				; 04	; multiply upper byte and add with carry values
		adc	a,(hl)				; 07	; ''
		ld	(PCM2_OverflwCur+002h),a	; 13	; save overflow quotient (high byte)
		scf					; 04	; set carry flag

PCM2_IgnorePitch:

; ---------------------------------------------------------------------------
; Updating Volume
; ---------------------------------------------------------------------------

PCM_ChangeVolume:jp	c,PCM_VolumeAlter
		ld	a,011011010b			; 07	; clear request flag
		ld	(PCM_ChangeVolume),a		; 13	; ''
		ld	a,011010010b
		ld	(PCM_VolChangeDel),a
PCM1_Volume:	ld	a,000h
		ld	(PCM1_VolumeNext+001h),a
PCM2_Volume:	ld	a,000h
		ld	(PCM2_VolumeNext+001h),a
	;	scf					; 04	; don't think it's necessary here...

PCM_VolumeAlter:jp	nc,PCM_VolumeControl		; 10	; if the 68k hasn't requested volume change, branch
PCM_VolumeRet:


; ---------------------------------------------------------------------------
; New samples...
; ---------------------------------------------------------------------------

PCM1_NewRET:	jp	nc,PCM1_NewSample		; 10	; can be changed to "jp  c" by the 68k
PCM2_NewRET:	jp	nc,PCM2_NewSample		; 10	; can be changed to "jp  c" by the 68k

; ---------------------------------------------------------------------------
; Checking for "Flush" mode
; ---------------------------------------------------------------------------

PCM_NoUpdate:
		exx					; 04	; switch registers
			ld	a,h				; 04	; load upper address
			rra					; 04	; get upper bit only into carry
			ld	a,l				; 04	; load lower address
			rra					; 04	; shift address down with carry
		exx					; 04	; switch registers
		srl	d				; 08	; get upper bit only into carry
		rr	e				; 08	; shift address down with carry
		zsub	e				; 04	; get distance between in and out buffers
		jp	c,CU_ValidDist			; 10	; if the OUT buffer hasn't caught up with the IN buffer, branch
		zadd	a,((00200h-00020h)>>001h)&0FFh	; 07	; check distance
		jp	c,CatchUp			; 10	; if the OUT buffer hasn't caught up with the IN buffer, branch
		jp	CU_Flush			; 10	; continue to flush routine

CU_ValidDist:
		zadd	a,(-00020h>>001h)&0FFh		; 07	; check distance
		jp	c,CatchUp			; 10	; if the OUT buffer hasn't caught up with the IN buffer, branch

; ---------------------------------------------------------------------------
; New sample playback
; ---------------------------------------------------------------------------

CU_Flush:

; ---------------------------------------------------------------------------
; Main "Flush" loop
; ---------------------------------------------------------------------------

			exx					; 04	; switch registers back
			ld	ixl,010h/002h			; 11	; set ix low byte to number of bytes to flush

FL_NextByte:
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
Z80_Flush1:	ld	b,00Ch
		djnz	*
		inc	bc
			exx					; 04	; switch registers
			M_Flush01				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
Z80_Flush2:	ld	b,00Ch
		djnz	*
			exx					; 04	; switch registers

			dec	ixl				; 08	; decrease ix low byte counter
			jp	nz,FL_NextByte			; 10	; if it hasn't finished, branch

	; --- Advance/Wrap OUT buffers ---

			M_Wrap
			jp	CatchUp_Exx			; 10	; jump back to the catch up loop

; ===========================================================================
; ---------------------------------------------------------------------------
; When PCM sample 1 address has reached the end of a window, just to play the last bit
; ---------------------------------------------------------------------------

PCM1_PrepReset:
		ld	hl,(PCM1_SampCur+001h)		; 16	; reload sample current position
		ld	bc,(PCM1_PitchDiv+001h)		; 20	; load pitch fraction (sets C to FF too..)
		ld	a,(PCM1_PitchCur+001h)		; 13	; load pitch current
		ld	de,(PCM1_PitchQuo+001h)		; 20	; load pitch quotient
		inc	de				; 06	; increase by 1 (no LDI to increment HL by 1)

PCM1_PrepCount:
		inc	c				; 04	; increase byte read counter
		zadd	a,b				; 04	; add fraction
		adc	hl,de				; 15	; add quotient
		jp	m,PCM1_PrepCount		; 10	; if we're still in the window space, branch
		ld	a,c				; 04	; copy counter to a
		zadd	a,a				; 04	; multiply by 2
		zadd	a,PCM1_PrepTable&0FFh		; 07	; advance to beginning of table
		ld	(PCM1_PrepLoc+001h),a		; 13	; save to table pointer
PCM1_PrepLoc:	ld	hl,(PCM1_PrepTable)		; 10	; load correct LDI instruction to change
		ld	(PCM1_ResInst+001h),hl		; 16	; store instruction address for later
		ld	(PCM1_ResJump+001h),hl		; 16	; ''
		ld	(hl),011000111b|PCM1_ResetJmp	; 10	; change LDI to "rst 28h"
			exx					; 04	; switch registers
			M_Flush01				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
		ld	h,080h				; 07	; set h to negative address (for V-blank)
		inc	iyl				; 08	; set window interrupt
Int1_jp:	jp	PCM1_PrepRet			; 10	; return

; ===========================================================================
; ---------------------------------------------------------------------------
; When PCM sample 1 address has gone outside the window, and needs to reset
; ---------------------------------------------------------------------------

PCM1_Reset:
		inc	sp				; 06	; restore sp back to the pitch it was at
		inc	sp				; 06	; ''
		ld	(PCM1_ResQuo+001h),sp		; 20	; store the stack (before changing it to +1 for the "ldi")
		ld	(PCM1_ResBuff+001h),de		; 20	; store de so we can use it
		ld	ix,08001h			; 14	; increase sp by 1 for "ldi" instruction and 8000 inside de...
		zadd	ix,sp				; 15	; ...so that "hl" and "sp" remains valid for interrupts...
		ld	(PCM1_ValueAdd+001),ix		; 20	; store the amount
PCM1_ValueAdd:	ld	de,00000h			; 10	; load to de
		zadd	a,b				; 04	; add dividend
		adc	hl,de				; 15	; add quotient (spill it over out of window)

		ld	(PCM1_ResSamp+001h),hl		; 16	; store registers
		ld	(PCM1_ResDiv+001h),bc		; 20	; ''
		ld	(PCM1_ResPitCur+001h),a		; 13	; ''

		ld	sp,Z80_Stack			; 10	; set valid stack

		dec	iyl				; 08	; set non-read interrupt

		ld	a,011010010b			; 07	; set bank change request flag
		ld	(PCM1_ChangeBank),a		; 13	; ''

		ld	hl,PCM1_BankCur			; 10	; address of bank ID
		ld	a,(PCM1_PitchQuo+001h)		; 13	; load pitch quotient
		inc	a				; 04	; increase pitch quotient by 1 (because FF00 is "stopped")
		zadd	a,a				; 04	; shift MSB into carry
		sbc	a,a				; 04	; convert to FF (if it was below FF00), else make it 00
		sbc	a,0FFh				; 07	; convert to FF (if it was below FF00), else make it 01
		zadd	a,(hl)				; 07	; increment/decrement the bank address

		ld	hl,06001h			; 10	; load bank switch register port
		dec	iyl				; 08	; set bank interrupt
Int1_ldhl:	ld	(hl),a				; 07	; 0000 0000 1  32KB -  64KB (  8000 -   10000)
		rrca					; 04
		ld	(hl),a				; 07	; 0000 0001 0  64KB - 128KB ( 10000 -   20000)
		rrca					; 04
		ld	(hl),a				; 07	; 0000 0010 0 128KB - 256KB ( 20000 -   40000)
		rrca					; 04
		ld	(hl),a				; 07	; 0000 0100 0 256KB - 512KB ( 40000 -   80000)
		rrca					; 04
		ld	(hl),a				; 07	; 0000 1000 0 512KB -   1MB ( 80000 -  100000)
		rrca					; 04
		ld	(hl),a				; 07	; 0001 0000 0   1MB -   2MB (100000 -  200000)
		rrca					; 04
		ld	(hl),a				; 07	; 0010 0000 0   2MB -   4MB (200000 -  400000)
		rrca					; 04
		ld	(hl),a				; 07	; 0100 0000 0   4MB -   8MB (400000 -  800000)
		ld	(hl),h	; clear			; 07	; 1000 0000 0   8MB -  16MB (800000 - 1000000)

		inc	iyl				; 08	; set non-read interrupt

PCM1_ResInst:	ld	hl,00000h			; 10	; load instruction address to change back to "LDI"
		ld	(hl),0EDh			; 10	; change to LDI again

PCM1_ResSamp:	ld	hl,00000h			; 10	; restore registers
PCM1_ResBuff:	ld	de,00000h			; 10	; ''
PCM1_ResDiv:	ld	bc,00000h			; 10	; ''
PCM1_ResPitCur:	ld	a,000h				; 07	; ''
		inc	iyl				; 08	; set window interrupt
PCM1_ResQuo:	ld	sp,00000h			; 10	; restore stack AFTER iy setting

PCM1_ResJump:	jp	00000h				; 10	; jump back to correct LDI instruction

; ===========================================================================
; ---------------------------------------------------------------------------
; When PCM sample 2 address has reached the end of a window, just to play the last bit
; ---------------------------------------------------------------------------

PCM2_PrepReset:
		ld	hl,(PCM2_SampCur+001h)		; 16	; reload sample current position
		ld	bc,(PCM2_PitchDiv+001h)		; 20	; load pitch fraction (sets C to FF too..)
		ld	a,(PCM2_PitchCur+001h)		; 13	; load pitch current
		ld	de,(PCM2_PitchQuo+001h)		; 20	; load pitch quotient
		inc	de				; 06	; increase by 1 (no LDI to increment HL by 1)

PCM2_PrepCount:
		inc	c				; 04	; increase byte read counter
		zadd	a,b				; 04	; add fraction
		adc	hl,de				; 15	; add quotient
		jp	m,PCM2_PrepCount		; 10	; if we're still in the window space, branch
		ld	a,c				; 04	; copy counter to a
		zadd	a,a				; 04	; multiply by 2
		zadd	a,PCM2_PrepTable&0FFh		; 07	; advance to beginning of table
		ld	(PCM2_PrepLoc+001h),a		; 13	; save to table pointer
PCM2_PrepLoc:	ld	hl,(PCM2_PrepTable)		; 10	; load correct LDI instruction to change
		ld	(PCM2_ResInst+001h),hl		; 16	; store instruction address for later
		ld	(PCM2_ResJump+001h),hl		; 16	; ''
		ld	(hl),011000111b|PCM2_ResetJmp	; 10	; change LDI to "rst 30h"
		ld	h,080h				; 07	; set h to negative address (for V-blank)
		inc	iyl				; 08	; set window interrupt
Int2_jp:	jp	PCM2_PrepRet			; 10	; return

; ===========================================================================
; ---------------------------------------------------------------------------
; When PCM sample 2 address has gone outside the window, and needs to reset
; ---------------------------------------------------------------------------

PCM2_Reset:
		inc	sp				; 06	; restore sp back to the pitch it was at
		inc	sp				; 06	; ''
		ld	(PCM2_ResQuo+001h),sp		; 20	; store the stack (before changing it to +1 for the "ldi")
		ld	(PCM2_ResBuff+001h),de		; 20	; store de so we can use it
		ld	ix,08001h			; 14	; increase sp by 1 for "ldi" instruction and 8000 inside de...
		zadd	ix,sp				; 15	; ...so that "hl" and "sp" remains valid for interrupts...
		ld	(PCM2_ValueAdd+001),ix		; 20	; store the amount
PCM2_ValueAdd:	ld	de,00000h			; 10	; load to de
		zadd	a,b				; 04	; add dividend
		adc	hl,de				; 15	; add quotient (spill it over out of window)

		ld	(PCM2_ResSamp+001h),hl		; 16	; store registers
		ld	(PCM2_ResDiv+001h),bc		; 20	; ''
		ld	(PCM2_ResPitCur+001h),a		; 13	; ''

		ld	sp,Z80_Stack			; 10	; set valid stack

		dec	iyl				; 08	; set non-read interrupt

		ld	a,011010010b			; 07	; set bank change request flag
		ld	(PCM2_ChangeBank),a		; 13	; ''

		ld	hl,PCM2_BankCur			; 10	; address of bank ID
		ld	a,(PCM2_PitchQuo+001h)		; 13	; load pitch quotient
		inc	a				; 04	; increase pitch quotient by 1 (because FF00 is "stopped")
		zadd	a,a				; 04	; shift MSB into carry
		sbc	a,a				; 04	; convert to FF (if it was below FF00), else make it 00
		sbc	a,0FFh				; 07	; convert to FF (if it was below FF00), else make it 01
		zadd	a,(hl)				; 07	; increment/decrement the bank address

		ld	hl,06001h			; 10	; load bank switch register port
		dec	iyl				; 08	; set bank interrupt
Int2_ldhl:	ld	(hl),a				; 07	; 0000 0000 1  32KB -  64KB (  8000 -   10000)
		rrca					; 04
		ld	(hl),a				; 07	; 0000 0001 0  64KB - 128KB ( 10000 -   20000)
		rrca					; 04
		ld	(hl),a				; 07	; 0000 0010 0 128KB - 256KB ( 20000 -   40000)
		rrca					; 04
		ld	(hl),a				; 07	; 0000 0100 0 256KB - 512KB ( 40000 -   80000)
		rrca					; 04
		ld	(hl),a				; 07	; 0000 1000 0 512KB -   1MB ( 80000 -  100000)
		rrca					; 04
		ld	(hl),a				; 07	; 0001 0000 0   1MB -   2MB (100000 -  200000)
		rrca					; 04
		ld	(hl),a				; 07	; 0010 0000 0   2MB -   4MB (200000 -  400000)
		rrca					; 04
		ld	(hl),a				; 07	; 0100 0000 0   4MB -   8MB (400000 -  800000)
		ld	(hl),h	; clear			; 07	; 1000 0000 0   8MB -  16MB (800000 - 1000000)

		inc	iyl				; 08	; set non-read interrupt

PCM2_ResInst:	ld	hl,00000h			; 10	; load instruction address to change back to "LDI"
		ld	(hl),0EDh			; 10	; change to LDI again

PCM2_ResSamp:	ld	hl,00000h			; 10	; restore registers
PCM2_ResBuff:	ld	de,00000h			; 10	; ''
PCM2_ResDiv:	ld	bc,00000h			; 10	; ''
PCM2_ResPitCur:	ld	a,000h				; 07	; ''
		inc	iyl				; 08	; set window interrupt
PCM2_ResQuo:	ld	sp,00000h			; 10	; restore stack AFTER iy setting

PCM2_ResJump:	jp	00000h				; 10	; jump back to correct LDI instruction

; ===========================================================================
; ---------------------------------------------------------------------------
; PCM volume Lists
; ---------------------------------------------------------------------------
		align	00200h
; ---------------------------------------------------------------------------

PCM_Volume1:	db	000h,081h,082h,083h,084h,085h,086h,087h,088h,089h,08Ah,08Bh,08Ch,08Dh,08Eh,08Fh
		db	090h,091h,092h,093h,094h,095h,096h,097h,098h,099h,09Ah,09Bh,09Ch,09Dh,09Eh,09Fh
		db	0A0h,0A1h,0A2h,0A3h,0A4h,0A5h,0A6h,0A7h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh
		db	0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh
		db	0C0h,0C1h,0C2h,0C3h,0C4h,0C5h,0C6h,0C7h,0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0CFh
		db	0D0h,0D1h,0D2h,0D3h,0D4h,0D5h,0D6h,0D7h,0D8h,0D9h,0DAh,0DBh,0DCh,0DDh,0DEh,0DFh
		db	0E0h,0E1h,0E2h,0E3h,0E4h,0E5h,0E6h,0E7h,0E8h,0E9h,0EAh,0EBh,0ECh,0EDh,0EEh,0EFh
		db	0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h,0F8h,0F9h,0FAh,0FBh,0FCh,0FDh,0FEh,0FFh
		db	000h,001h,002h,003h,004h,005h,006h,007h,008h,009h,00Ah,00Bh,00Ch,00Dh,00Eh,00Fh
		db	010h,011h,012h,013h,014h,015h,016h,017h,018h,019h,01Ah,01Bh,01Ch,01Dh,01Eh,01Fh
		db	020h,021h,022h,023h,024h,025h,026h,027h,028h,029h,02Ah,02Bh,02Ch,02Dh,02Eh,02Fh
		db	030h,031h,032h,033h,034h,035h,036h,037h,038h,039h,03Ah,03Bh,03Ch,03Dh,03Eh,03Fh
		db	040h,041h,042h,043h,044h,045h,046h,047h,048h,049h,04Ah,04Bh,04Ch,04Dh,04Eh,04Fh
		db	050h,051h,052h,053h,054h,055h,056h,057h,058h,059h,05Ah,05Bh,05Ch,05Dh,05Eh,05Fh
		db	060h,061h,062h,063h,064h,065h,066h,067h,068h,069h,06Ah,06Bh,06Ch,06Dh,06Eh,06Fh
		db	070h,071h,072h,073h,074h,075h,076h,077h,078h,079h,07Ah,07Bh,07Ch,07Dh,07Eh,07Fh

PCM_Volume2:	db	000h,081h,082h,083h,084h,085h,086h,087h,088h,089h,08Ah,08Bh,08Ch,08Dh,08Eh,08Fh
		db	090h,091h,092h,093h,094h,095h,096h,097h,098h,099h,09Ah,09Bh,09Ch,09Dh,09Eh,09Fh
		db	0A0h,0A1h,0A2h,0A3h,0A4h,0A5h,0A6h,0A7h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh
		db	0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh
		db	0C0h,0C1h,0C2h,0C3h,0C4h,0C5h,0C6h,0C7h,0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0CFh
		db	0D0h,0D1h,0D2h,0D3h,0D4h,0D5h,0D6h,0D7h,0D8h,0D9h,0DAh,0DBh,0DCh,0DDh,0DEh,0DFh
		db	0E0h,0E1h,0E2h,0E3h,0E4h,0E5h,0E6h,0E7h,0E8h,0E9h,0EAh,0EBh,0ECh,0EDh,0EEh,0EFh
		db	0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h,0F8h,0F9h,0FAh,0FBh,0FCh,0FDh,0FEh,0FFh
		db	000h,001h,002h,003h,004h,005h,006h,007h,008h,009h,00Ah,00Bh,00Ch,00Dh,00Eh,00Fh
		db	010h,011h,012h,013h,014h,015h,016h,017h,018h,019h,01Ah,01Bh,01Ch,01Dh,01Eh,01Fh
		db	020h,021h,022h,023h,024h,025h,026h,027h,028h,029h,02Ah,02Bh,02Ch,02Dh,02Eh,02Fh
		db	030h,031h,032h,033h,034h,035h,036h,037h,038h,039h,03Ah,03Bh,03Ch,03Dh,03Eh,03Fh
		db	040h,041h,042h,043h,044h,045h,046h,047h,048h,049h,04Ah,04Bh,04Ch,04Dh,04Eh,04Fh
		db	050h,051h,052h,053h,054h,055h,056h,057h,058h,059h,05Ah,05Bh,05Ch,05Dh,05Eh,05Fh
		db	060h,061h,062h,063h,064h,065h,066h,067h,068h,069h,06Ah,06Bh,06Ch,06Dh,06Eh,06Fh
		db	070h,071h,072h,073h,074h,075h,076h,077h,078h,079h,07Ah,07Bh,07Ch,07Dh,07Eh,07Fh

; ===========================================================================
; ---------------------------------------------------------------------------
; 68K SET - routine to load a new sample 1
; ---------------------------------------------------------------------------

PCM1_NewSample:
		push	de				; 11	; store IN buffer
		ld	a,(PCM1_PitchQuo+001h)		; 13	; load quotient
		inc	a				; 04	; increase by 1 (because FF00 is stopped), is it playing normally?
		jp	p,PCM1_NewNormal		; 10	; if so, branch
		ld	hl,(PCM1_Sample_Rev)		; 16	; load next sample address
		ld	a,(PCM1_Bank_Rev)		; 13	; load next bank address
		ld	de,08000h|(SWFR_Stop&7FFFh)	; 10	; set address to blank/mute sample
		ld	c,(SWFR_Stop>>0Fh)&0FFh		; 07	; change bank address to mute sample
		jp	PCM1_NewReverse			; 10	; continue and apply sample

PCM1_NewNormal:
		ld	hl,(PCM1_Sample)		; 16	; load next sample address
		ld	a,(PCM1_Bank)			; 13	; load next bank address
		ld	de,08000h|(SWF_Stop&7FFFh) 	; 10	; set address to blank/mute sample
		ld	c,(SWF_Stop>>0Fh)&0FFh		; 07	; change bank address to mute sample

PCM1_NewReverse:
		call	PCM1_GetSample			; 17	; load correct sample (and control DAC status)
		ld	de,PCM1_Switch			; 10	; load PCM switch list to edit
		call	SetBank				; 17	; set bank address
		xor	a				; 04	; clear the pitch current position
		ld	(PCM1_PitchCur+001h),a		; 13	; ''
		pop	de				; 10	; restore IN buffer
		ld	hl,PCM1_NewRET			; 10	; load return address
		ld	(hl),011010010b			; 10	; change instruction back to "JP NC"
		scf					; 04	; set C flag (for "JP NC" instruction)
		jp	(hl)				; 04	; return to address

; ===========================================================================
; ---------------------------------------------------------------------------
; 68K SET - routine to load a new sample 2
; ---------------------------------------------------------------------------

PCM2_NewSample:
		push	de				; 11	; store IN buffer
		ld	a,(PCM2_PitchQuo+001h)		; 13	; load quotient
		inc	a				; 04	; increase by 1 (because FF00 is stopped), is it playing normally?
		jp	p,PCM2_NewNormal		; 10	; if so, branch
		ld	hl,(PCM2_Sample_Rev)		; 16	; load next sample address
		ld	a,(PCM2_Bank_Rev)		; 13	; load next bank address
		ld	de,08000h|(SWFR_Stop&7FFFh)	; 10	; set address to blank/mute sample
		ld	c,(SWFR_Stop>>0Fh)&0FFh		; 07	; change bank address to mute sample
		jp	PCM2_NewReverse			; 10	; continue and apply sample

PCM2_NewNormal:
		ld	hl,(PCM2_Sample)		; 16	; load next sample address
		ld	a,(PCM2_Bank)			; 13	; load next bank address
		ld	de,08000h|(SWF_Stop&7FFFh)	; 10	; set address to blank/mute sample
		ld	c,(SWF_Stop>>0Fh)&0FFh		; 07	; change bank address to mute sample

PCM2_NewReverse:
		call	PCM2_GetSample			; 17	; load correct sample (and control DAC status)
		ld	de,PCM2_Switch			; 10	; load PCM switch list to edit
		call	SetBank				; 17	; set bank address
		xor	a				; 04	; clear the pitch current position
		ld	(PCM2_PitchCur+001h),a		; 13	; ''
		pop	de				; 10	; restore IN buffer
		ld	hl,PCM2_NewRET			; 10	; load return address
		ld	(hl),011010010b			; 10	; change instruction back to "JP NC"
		scf					; 04	; set C flag (for "JP NC" instruction)
		jp	(hl)				; 04	; return to address

; ===========================================================================
; ---------------------------------------------------------------------------
; When PCM sample 1 has reached an end marker & needs to loop back
; ---------------------------------------------------------------------------

PCM1_Mute:
		dec	iyl				; 08	; set non-read interrupt
		ld	a,(PCM1_PitchQuo+001h)		; 13	; load quotient
		inc	a				; 04	; increase by 1 (because FF00 is stopped), is it playing normally?
		jp	p,PCM1_Normal			; 10	; if so, branch
		ld	hl,(PCM1_SampleNext_Rev)	; 16	; load next sample address
		ld	a,(PCM1_BankNext_Rev)		; 13	; load next bank address
		ld	de,08000h|(SWFR_Stop&7FFFh)	; 10	; set address to blank/mute sample
		ld	c,(SWFR_Stop>>0Fh)&0FFh		; 07	; change bank address to mute sample
		jp	PCM1_Reverse			; 10	; continue and apply sample

PCM1_Normal:
		ld	hl,(PCM1_SampleNext)		; 16	; load next sample address
		ld	a,(PCM1_BankNext)		; 13	; load next bank address
		ld	de,08000h|(SWF_Stop&7FFFh)	; 10	; set address to blank/mute sample
		ld	c,(SWF_Stop>>0Fh)&0FFh		; 07	; change bank address to mute sample

PCM1_Reverse:
		call	PCM1_GetSample			; 17	; load correct sample (and control DAC status)

		ld	de,PCM1_Switch			; 10	; load PCM switch list to edit
		call	SetBank				; 17	; set bank address
		xor	a				; 04	; clear the pitch current position
		ld	(PCM1_PitchCur+001h),a		; 13	; ''
			exx					; 04	; switch registers
			M_Revert01				; 59	; move pointer back
			exx					; 04	; switch registers
		jp	PCM1_MuteRet			; 10	; return

; ===========================================================================
; ---------------------------------------------------------------------------
; When PCM sample 2 has reached an end marker & needs to loop back
; ---------------------------------------------------------------------------

PCM2_Mute:
		dec	iyl				; 08	; set non-read interrupt
		ld	a,(PCM2_PitchQuo+001h)		; 13	; load quotient
		inc	a				; 04	; increase by 1 (because FF00 is stopped), is it playing normally?
		jp	p,PCM2_Normal			; 10	; if so, branch
		ld	hl,(PCM2_SampleNext_Rev)	; 16	; load next sample address
		ld	a,(PCM2_BankNext_Rev)		; 13	; load next bank address
		ld	de,08000h|(SWFR_Stop&7FFFh)	; 10	; set address to blank/mute sample
		ld	c,(SWFR_Stop>>0Fh)&0FFh		; 07	; change bank address to mute sample
		jp	PCM2_Reverse			; 10	; continue and apply sample

PCM2_Normal:
		ld	hl,(PCM2_SampleNext)		; 16	; load next sample address
		ld	a,(PCM2_BankNext)		; 13	; load next bank address
		ld	de,08000h|(SWF_Stop&7FFFh)	; 10	; set address to blank/mute sample
		ld	c,(SWF_Stop>>0Fh)&0FFh		; 07	; change bank address to mute sample

PCM2_Reverse:
		call	PCM2_GetSample			; 17	; load correct sample (and control DAC status)
		ld	de,PCM2_Switch			; 10	; load PCM switch list to edit
		call	SetBank				; 17	; set bank address
		xor	a				; 04	; clear the pitch current position
		ld	(PCM2_PitchCur+001h),a		; 13	; ''
			exx					; 04	; switch registers
			M_Revert02				; 59	; move pointer back
			exx					; 04	; switch registers
		jp	PCM2_MuteRet			; 10	; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load the sample (and if blank, load mute and disable DAC)
; ---------------------------------------------------------------------------

	; --- PCM 1 ---

PCM1_GetSample:
		ld	(PCM1_BankCur),a		; 13	; set bank address
		ld	b,000000010b			; 07	; prepare to enable DAC for PCM 1
		ld	a,h				; 04	; is the address blank?
		zor	l				; 04	; ''
		jr	nz,PCM1_NoMute			; 12/07	; if not, branch
		ex	de,hl				; 04	; set mute sample address
		ld	a,c				; 04	; ''
		ld	(PCM1_BankCur),a		; 13	; ''
		ld	b,011111101b			; 07	; prepare to disable DAC for PCM 1

PCM1_NoMute:
		call	PCM_SetDAC			; 17	; enable/disable DAC port correctly
		ld	(PCM1_SampCur+001h),hl		; 16	; set sample address
		ld	a,(PCM1_BankCur)		; 13	; reload bank address
		ret					; 10	; return

	; --- PCM 2 ---

PCM2_GetSample:
		ld	(PCM2_BankCur),a		; 13	; set bank address
		ld	b,000000001b			; 07	; prepare to enable DAC for PCM 2
		ld	a,h				; 04	; is the address blank?
		zor	l				; 04	; ''
		jr	nz,PCM2_NoMute			; 12/07	; if not, branch
		ex	de,hl				; 04	; set mute sample address
		ld	a,c				; 04	; ''
		ld	(PCM2_BankCur),a		; 13	; ''
		ld	b,011111110b			; 07	; prepare to disable DAC for PCM 2

PCM2_NoMute:
		call	PCM_SetDAC			; 17	; enable/disable DAC port correctly
		ld	(PCM2_SampCur+001h),hl		; 16	; set sample address
		ld	a,(PCM2_BankCur)		; 13	; reload bank address
		ret					; 10	; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to enable/disable the DAC correctly
; ---------------------------------------------------------------------------

PCM_SetDAC:
		ld	a,b				; 04	; load set/clear value
		zor	a				; 04	; are we meant to be enabling DAC?
		jp	m,PCM_DisableDAC		; 10	; if negative, this is meant to be an AND instruction

	; --- Enabling DAC ---

		ld	a,(StatusDAC)			; 13	; load current DAC status
		zor	a				; 04	; is DAC already enabled?
		jr	nz,PCM_IgnoreEnable		; 12/07	; if so, branch
		ex	de,hl				; 04	; store hl
		ld	hl,04000h			; 10	; load YM2612 address port
		ld	(hl),02Bh			; 10	; set YM2612 address
		inc	l				; 04	; advance to data port
	znop					; 04	; delay (MIGHT NOT NEED IT!)
		ld	(hl),080h			; 10	; enable DAC (disable FM6)
		dec	l				; 04	; revert back to address port
	znop					; 04	; delay (MIGHT NOT NEED IT!)
		ld	(hl),02Ah			; 10	; restore YM address back to DAC
		ex	de,hl				; 04	; restore hl

PCM_IgnoreEnable:
		zor	b				; 04	; enable current PCM channels' bit
		ld	(StatusDAC),a			; 13	; update status
		ret					; 10	; return

	; --- Disabling DAC ---

PCM_DisableDAC:
		ld	a,(StatusDAC)			; 13	; load DAC status
		zor	a				; 04	; is the DAC disabled already?
		jr	z,PCM_SetDAC_Finish		; 12/07	; if so, branch
		zand	b				; 04	; clear the PCM channel's status
		ld	(StatusDAC),a			; 13	; update
		jr	nz,PCM_SetDAC_Finish		; 12/07	; if the other PCM channel is still running, branch
		ex	de,hl				; 04	; store hl
		ld	hl,04000h			; 10	; load YM2612 address port
		ld	(hl),02Bh			; 10	; set YM2612 address
		inc	l				; 04	; advance to data port
	znop					; 04	; delay (MIGHT NOT NEED IT!)
		ld	(hl),000h			; 10	; disable DAC (enable FM6)
		dec	l				; 04	; revert back to address port
	znop					; 04	; delay (MIGHT NOT NEED IT!)
		ld	(hl),02Ah			; 10	; restore YM address back to DAC
		ex	de,hl				; 04	; restore hl

PCM_SetDAC_Finish:
		ret					; 10	; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to change a channel's volume table
; ---------------------------------------------------------------------------

PCM_VolumeControl:
		ld	a,011010010b			; 07	; clear request flag
		ld	(PCM_VolumeAlter),a		; 13	; ''
		push	de				; 10	; store IN buffer

PCM1_VolumeNew:	ld	a,000h				; 07	; load current volume
PCM1_VolumeCur:	cp	000h				; 07	; has it changed?
		jp	z,PCM1_NoVolume			; 10	; if not, branch
		ld	(PCM1_VolumeCur+001h),a		; 13	; update volume
		ld	de,PCM_Volume1			; 10	; load volume table to edit
PCM1_VolTimer:	ld	b,000h				; 07	; load volume timer
		call	SwitchVolume			; 17	; switch the volume
		ld	(PCM1_VolTimer+001h),a		; 13	; update volume timer

PCM1_NoVolume:

PCM2_VolumeNew:	ld	a,000h				; 07	; load current volume
PCM2_VolumeCur:	cp	000h				; 07	; has it changed?
		jp	z,PCM2_NoVolume			; 10	; if not, branch
		ld	(PCM2_VolumeCur+001h),a		; 13	; update volume
		ld	de,PCM_Volume2			; 10	; load volume table to edit
PCM2_VolTimer:	ld	b,000h				; 07	; load volume timer
		call	SwitchVolume			; 17	; switch the volume
		ld	(PCM2_VolTimer+001h),a		; 13	; update volume timer

PCM2_NoVolume:
		pop	de				; 11	; restore IN buffer
		scf					; 04	; set carry flag
		jp	PCM_VolumeRet			; 10	; return to main loop

; ---------------------------------------------------------------------------
; The volume changing itself
; ---------------------------------------------------------------------------

SwitchVolume:

; ---------------------------------------------------------------------------
; Software version of volume table (This is slower to process but will save
; 8000 bytes of ROM space).  It'll also cause chopping in the sample playback
; ---------------------------------------------------------------------------

;		ld	b,a				; 04	; store volume
;		zneg					; 08	; convert volume to 00 - 80 (mute - loud)
;		zadd	a,080h				; 07	; ''
;		zadd	a,a				; 04	; shift MSB into carry
;		ld	(SV_Fraction+001h),a		; 13	; store fraction
;		sbc	a,a				; 04	; get only the carry (for quotient)
;		zneg					; 08	; ''
;		ld	c,a				; 04	; store quotient in c
;		ld	hl,00000h			; 10	; reset current fraction/dividend
;		ld	a,b				; 04	; reload volume
;		zadd	a,080h				; 07	; rotate starting volume
;SV_Fraction:	ld	b,000h				; 07	; set fraction/dividend
;
;SV_SetNormal:
;		ld	(de),a				; 07	; save to table
;		zadd	hl,bc 				; 11	; add fraction/dividend
;		adc	a,c				; 04	; add carry to quotient
;		inc	e				; 04	; advance table
;		jp	nz,SV_SetNormal			; 10	; repeat until the table is finished (should reach 100)
;
;SV_Return:	jp	00000h				; 10	; return

; ---------------------------------------------------------------------------

		ld	hl,06001h			; 10	; load bank switch register address
SV_VolumeBank:	db	74h|((fLog>>0Fh)&1)		; 07	; "ld (hl),h" Volume table address in 68k ROM
		db	74h|((fLog>>10h)&1)		; 07	; "ld (hl),h"
		db	74h|((fLog>>11h)&1)		; 07	; "ld (hl),h"
		db	74h|((fLog>>12h)&1)		; 07	; "ld (hl),h"
		db	74h|((fLog>>13h)&1)		; 07	; "ld (hl),h"
		db	74h|((fLog>>14h)&1)		; 07	; "ld (hl),h"
		db	74h|((fLog>>15h)&1)		; 07	; "ld (hl),h"
		db	74h|((fLog>>16h)&1)		; 07	; "ld (hl),h"
		db	74h|((fLog>>17h)&1)		; 07	; "ld (hl),h"
		dec	b				; 04	; check the volume timer
		inc	b				; 04	; ''
		jp	z,SV_Flush			; 10	; if the channel can flush while volume changing, branch

	; --- Non-flush version ---

		push	bc				; 10	; store timer
		zadd	a,080h				; 07	; rotate to 8000 bank address
		jp	nz,SV_NoMute			; 10	; if it's not mute, branch
		ex	de,hl				; 04	; make e = 1, and l = 0 (quicker than incrementing later)
		ld	d,h				; 04	; get upper volume table address back to d
		ld	(hl),a				; 07	; clear first byte
		ld	bc,020FFh			; 10	; prepare counter
		jp	SV_LoadVolume+002h		; 10	; jump into loop starting at section ldi

SV_NoMute:
		ld	h,a				; 04	; set address
		dec	l				; 04	; clear l (fastest way)
		ld	bc,02100h			; 10	; prepare counter (using 11 since ldi will decrement the b the first time)

SV_LoadVolume:
		rept	008h
		ldi					; 16	; copy volume bytes over
		endr
		djnz	SV_LoadVolume			; 13 08	; repeat until table is done
		pop	af				; 11	; reload timer (so that return routine doesn't change the timer by mistake)
		ret					; 10	; return

	; --- Flush version ---

SV_Flush:
		zadd	a,080h				; 07	; rotate to 8000 bank address
		jp	nz,SVF_NoMute			; 10	; if it's not mute, branch
		ex	de,hl				; 04	; make e = 1, and l = 0 (quicker than incrementing later)
		ld	d,h				; 04	; get upper volume table address back to d
		ld	(hl),a				; 07	; clear first byte
		ld	bc,008FFh			; 10	; prepare counter
			exx					; 04	; switch registers
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
		jp	SVF_StartVolume+002h		; 10	; jump into loop starting at section ldi

SVF_NoMute:
		ld	h,a				; 04	; set address
		dec	l				; 04	; clear l (fastest way)
		ld	bc,00900h			; 10	; prepare counter (using 11 since ldi will decrement the b the first time)

SVF_LoadVolume:
			exx					; 04	; switch registers
			M_Flush02				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers

SVF_StartVolume:
		rept	008h
		ldi					; 16	; copy volume bytes over
		endr
			exx					; 04	; switch registers
			M_Flush01				; 59	; flush a byte to the YM2612
			exx					; 04	; switch registers
		rept	008h
		ldi					; 16	; copy volume bytes over
		endr
		djnz	SVF_LoadVolume			; 13 08	; repeat until table is done
			exx					; 04	; switch registers
			M_Wrap
			exx					; 04	; switch registers
		ld	b,08h				; 07	; reset counter
		dec	e				; 04	; check volume table counter
		inc	e				; 04	; ''
		jp	nz,SVF_LoadVolume		; 10	; if not finished, branch
		ld	a,000h				; 07	; set timer for PCM volume changing
		ret					; 10	; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Switching a channel's bank address
; ---------------------------------------------------------------------------
;		ld	hl,PCM1_BankCur			; 10	; address of bank ID
;		ld	de,PCM1_Switch			; 10	; load PCM switch list to edit
;		ld	a,(PCM1_PitchQuo+001h)		; 13	; load pitch quotient
;		call	SwitchBank			; 17	; change the bank address
; ---------------------------------------------------------------------------
;		ld	a,(PCM1_BankCur)		; 13	; load bank ID
;		ld	de,PCM1_Switch			; 10	; load PCM switch list to edit
;		call	SetBank				; 17	; set bank address
; ---------------------------------------------------------------------------

SwitchBank:
		inc	a				; 04	; increase pitch quotient by 1 (because FF00 is "stopped")
		zadd	a,a				; 04	; shift MSB into carry
		sbc	a,a				; 04	; convert to FF (if it was below FF00), else make it 00
		sbc	a,0FFh				; 07	; convert to FF (if it was below FF00), else make it 01
		zadd	a,(hl)				; 07	; increment/decrement the bank address
		ld	(hl),a				; 07	; update bank address

SetBank:
		ld	l,a				; 04	; load bank
		ld	h,001110100b			; 07	; prepare instruction ("ld  (hl),r")
	rept	008h
		xor	a				; 04	; clear a
		rrc	l				; 08	; shift bit into carry
		adc	a,h				; 04	; set instruction bits (with carry register bit)
		ld	(de),a				; 07	; write instruction
		inc	e	; WARNING (see comment)	; 04	; advance to next instruction (ONLY WORKS IF THE INSTRUCTIONS DON'T CROSS A 100 BYTE BOUNDARY, please align)
	endr
		ret					; 10	; return

; ===========================================================================
; ---------------------------------------------------------------------------
; PCM buffer 1 (Make sure buffer ends at 00E00h)
; ---------------------------------------------------------------------------

		align	(01000h-00200h)-00150h
PCM_Buffer1:	rept	00150h
		db	080h
		endr

; ===========================================================================
; ---------------------------------------------------------------------------
; Bank interrupt preparation list
; ---------------------------------------------------------------------------
		align	00080h
; ---------------------------------------------------------------------------

PCM1_PrepTable:	dw	PCM1_PreInst01
		dw	PCM1_PreInst02
		dw	PCM1_PreInst03
		dw	PCM1_PreInst04
		dw	PCM1_PreInst05
		dw	PCM1_PreInst06
		dw	PCM1_PreInst07
		dw	PCM1_PreInst08
		dw	PCM1_PreInst09
		dw	PCM1_PreInst0A
		dw	PCM1_PreInst0B
		dw	PCM1_PreInst0C
		dw	PCM1_PreInst0D
		dw	PCM1_PreInst0E
		dw	PCM1_PreInst0F
		dw	PCM1_PreInst10
		dw	PCM1_PreInst11
		dw	PCM1_PreInst12
		dw	PCM1_PreInst13
		dw	PCM1_PreInst14
		dw	PCM1_PreInst15
		dw	PCM1_PreInst16
		dw	PCM1_PreInst17
		dw	PCM1_PreInst18
PCM2_PrepTable:	dw	PCM2_PreInst01
		dw	PCM2_PreInst02
		dw	PCM2_PreInst03
		dw	PCM2_PreInst04
		dw	PCM2_PreInst05
		dw	PCM2_PreInst06
		dw	PCM2_PreInst07
		dw	PCM2_PreInst08
		dw	PCM2_PreInst09
		dw	PCM2_PreInst0A
		dw	PCM2_PreInst0B
		dw	PCM2_PreInst0C
		dw	PCM2_PreInst0D
		dw	PCM2_PreInst0E
		dw	PCM2_PreInst0F
		dw	PCM2_PreInst10
		dw	PCM2_PreInst11
		dw	PCM2_PreInst12
		dw	PCM2_PreInst13
		dw	PCM2_PreInst14
		dw	PCM2_PreInst15
		dw	PCM2_PreInst16
		dw	PCM2_PreInst17
		dw	PCM2_PreInst18

; ===========================================================================
; ---------------------------------------------------------------------------
; Specific variable data...
; ---------------------------------------------------------------------------

	; --- Current bank address for PCM channels ---

PCM1_BankCur:	db	(SWF_Stop>>0Fh)&0FFh			; The current bank address of PCM 1
PCM2_BankCur:	db	(SWF_Stop>>0Fh)&0FFh			; The current bank address of PCM 2

	; --- YM2612 Pointers ---

YM_Buffer:	db	000h					; 00 = Z80 Buffer 1 | 68k Buffer 2 ... FF = Z80 Buffer 2 | 68k Buffer 1
StatusDAC:	db	000000000b				; DAC status (000000AB, A = 0 PCM 1 mute | B = 0 PCM 2 mute)

; ===========================================================================
; ---------------------------------------------------------------------------
; Sample requested by 68k
; ---------------------------------------------------------------------------

	; --- PCM 1 start sample ---

PCM1_Sample:		dw	00000h					; PCM 1 requested sample
PCM1_Bank:		db	000h					; PCM 1 requested bank
PCM1_Sample_Rev:	dw	00000h					; PCM 1 requested sample (reverse position)
PCM1_Bank_Rev:		db	000h					; PCM 1 requested bank (reverse position)

	; --- PCM 1 next sample ---

PCM1_SampleNext:	dw	00000h					; PCM 1 requested sample
PCM1_BankNext:		db	000h					; PCM 1 requested bank
PCM1_SampleNext_Rev:	dw	00000h					; PCM 1 requested sample (reverse position)
PCM1_BankNext_Rev:	db	000h					; PCM 1 requested bank (reverse position)

	; --- PCM 2 start sample ---

PCM2_Sample:		dw	00000h					; PCM 2 requested sample
PCM2_Bank:		db	000h					; PCM 2 requested bank
PCM2_Sample_Rev:	dw	00000h					; PCM 2 requested sample (reverse position)
PCM2_Bank_Rev:		db	000h					; PCM 2 requested bank (reverse position)

	; --- PCM 2 next sample ---

PCM2_SampleNext:	dw	00000h					; PCM 2 requested sample
PCM2_BankNext:		db	000h					; PCM 2 requested bank
PCM2_SampleNext_Rev:	dw	00000h					; PCM 2 requested sample (reverse position)
PCM2_BankNext_Rev:	db	000h					; PCM 2 requested bank (reverse position)

; ===========================================================================
; ---------------------------------------------------------------------------
; PCM buffer 2 (Make sure buffer ends at 01000h)
; ---------------------------------------------------------------------------

		align	01000h-00150h
PCM_Buffer2:	rept	00150h
		db	080h
		endr

; ===========================================================================
; ---------------------------------------------------------------------------
; Overflow calculation multiplication tables
; ---------------------------------------------------------------------------

PCM_OverflwCalc:

		; --- Lower byte ---

		db	000h,018h,030h,048h,060h,078h,090h,0A8h,0C0h,0D8h,0F0h,008h,020h,038h,050h,068h
		db	080h,098h,0B0h,0C8h,0E0h,0F8h,010h,028h,040h,058h,070h,088h,0A0h,0B8h,0D0h,0E8h
		db	000h,018h,030h,048h,060h,078h,090h,0A8h,0C0h,0D8h,0F0h,008h,020h,038h,050h,068h
		db	080h,098h,0B0h,0C8h,0E0h,0F8h,010h,028h,040h,058h,070h,088h,0A0h,0B8h,0D0h,0E8h
		db	000h,018h,030h,048h,060h,078h,090h,0A8h,0C0h,0D8h,0F0h,008h,020h,038h,050h,068h
		db	080h,098h,0B0h,0C8h,0E0h,0F8h,010h,028h,040h,058h,070h,088h,0A0h,0B8h,0D0h,0E8h
		db	000h,018h,030h,048h,060h,078h,090h,0A8h,0C0h,0D8h,0F0h,008h,020h,038h,050h,068h
		db	080h,098h,0B0h,0C8h,0E0h,0F8h,010h,028h,040h,058h,070h,088h,0A0h,0B8h,0D0h,0E8h
		db	000h,018h,030h,048h,060h,078h,090h,0A8h,0C0h,0D8h,0F0h,008h,020h,038h,050h,068h
		db	080h,098h,0B0h,0C8h,0E0h,0F8h,010h,028h,040h,058h,070h,088h,0A0h,0B8h,0D0h,0E8h
		db	000h,018h,030h,048h,060h,078h,090h,0A8h,0C0h,0D8h,0F0h,008h,020h,038h,050h,068h
		db	080h,098h,0B0h,0C8h,0E0h,0F8h,010h,028h,040h,058h,070h,088h,0A0h,0B8h,0D0h,0E8h
		db	000h,018h,030h,048h,060h,078h,090h,0A8h,0C0h,0D8h,0F0h,008h,020h,038h,050h,068h
		db	080h,098h,0B0h,0C8h,0E0h,0F8h,010h,028h,040h,058h,070h,088h,0A0h,0B8h,0D0h,0E8h
		db	000h,018h,030h,048h,060h,078h,090h,0A8h,0C0h,0D8h,0F0h,008h,020h,038h,050h,068h
		db	080h,098h,0B0h,0C8h,0E0h,0F8h,010h,028h,040h,058h,070h,088h,0A0h,0B8h,0D0h,0E8h

		; --- Upper byte ---

		db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,001h,001h,001h,001h
		db	001h,001h,001h,001h,001h,001h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h
		db	003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,004h,004h,004h,004h,004h
		db	004h,004h,004h,004h,004h,004h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h
		db	006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,007h,007h,007h,007h,007h
		db	007h,007h,007h,007h,007h,007h,008h,008h,008h,008h,008h,008h,008h,008h,008h,008h
		db	009h,009h,009h,009h,009h,009h,009h,009h,009h,009h,009h,00Ah,00Ah,00Ah,00Ah,00Ah
		db	00Ah,00Ah,00Ah,00Ah,00Ah,00Ah,00Bh,00Bh,00Bh,00Bh,00Bh,00Bh,00Bh,00Bh,00Bh,00Bh
		db	00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Dh,00Dh,00Dh,00Dh,00Dh
		db	00Dh,00Dh,00Dh,00Dh,00Dh,00Dh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh
		db	00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,010h,010h,010h,010h,010h
		db	010h,010h,010h,010h,010h,010h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h
		db	012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,013h,013h,013h,013h,013h
		db	013h,013h,013h,013h,013h,013h,014h,014h,014h,014h,014h,014h,014h,014h,014h,014h
		db	015h,015h,015h,015h,015h,015h,015h,015h,015h,015h,015h,016h,016h,016h,016h,016h
		db	016h,016h,016h,016h,016h,016h,017h,017h,017h,017h,017h,017h,017h,017h,017h,017h

; ===========================================================================
; ---------------------------------------------------------------------------
; The YM2612 operator writing lists (68k writes here, z80 must flush off)
; This SHOULD be at offset 1200 (Flood this space with FF's on 68k side...)
; ---------------------------------------------------------------------------

YM_Buffer1 =		offset(*)
YM_Buffer2 =		offset(*)+((02000h-offset(*))/2)
YM_BufferEnd =		02000h

; ===========================================================================
; ---------------------------------------------------------------------------
; Warning stuff
; ---------------------------------------------------------------------------

	if (offset(PCM1_Switch)&0FFh)>0F8h
		inform 0," "
		inform 0,"   Warning!  PCM1_Switch's instructions have crossed a boundary."
		inform 0," "
		inform 3," "
	endif

	if (offset(PCM2_Switch)&0FFh)>0F8h
		inform 0," "
		inform 0,"   Warning!  PCM2_Switch's instructions have crossed a boundary."
		inform 0," "
		inform 3," "
	endif
