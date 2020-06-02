; ===========================================================================
; ---------------------------------------------------------------------------
; Sound Test Screen
; ---------------------------------------------------------------------------

	if FEATURE_SOUNDTEST=0
		inform 3,"FEATURE_SOUNDTEST must be 1 in order for this sound test to work"
	endif

SoundTest:
	; --- Setup/clearing ---

		move	#$2700,sr				; disable interrupts
		move.l	#NullBlank,(HBlankRout).w		; set H-blank routine
		move.l	#VB_SoundTest_NoHB,(VBlankRout).w	; set V-blank routine
		lea	($C00000).l,a5				; load VDP data port
		lea	$04(a5),a6				; load VDP control port
		move.w	#$8000|%00000100,(a6)			; 00LH 01CD - Leftover SMS bar (0N|1Y) | H-Interrupt (0N|1Y) | H,V Counter (0N|1Y) | Disable video signal (0N|1Y)
		move.w	#$8100|%01110100,(a6)			; SDVM P100 - SMS mode (0N|1Y) | Display (0N|1Y) | V-Interrupt (0N|1Y) | DMA (0N|1Y) | V-resolution (0-1C|1-1E)
		move.w	#$8200|((($C000)>>$0A)&$FF),(a6)	; 00FE DCBA - Scroll Plane A Map Table VRam address
		move.w	#$8300|((($F000)>>$0A)&$FF),(a6)	; 00FE DCB0 / 00FE DC00 (20 H-resol) - Window Plane A Map Table VRam address
		move.w	#$8400|((($E000)>>$0D)&$FF),(a6)	; 0000 0FED - Scroll Plane B Map Table VRam address
		move.w	#$8500|((($F800)>>$09)&$FF),(a6)	; 0FED CBA9 / 0FED CBA0 (20 H-resol) - Sprite Plane Map Table VRam address
		move.w	#$8600|%00000000,(a6)			; 0000 0000 - Unknown/Unused Register
		move.w	#$8700|$20,(a6)				; 00PP CCCC - Backdrop Colour: Palette Line | Colour ID
		move.w	#$8800|%00000000,(a6)			; 0000 0000 - Unknown/Unused Register
		move.w	#$8900|%00000000,(a6)			; 0000 0000 - Unknown/Unused Register
		move.w	#$8A00|$DF,(a6)				; 7654 3210 - H-Interrupt Register
		move.w	#$8B00|%00000011,(a6)			; 0000 EVHH - External Interrupt (0N|1Y) | V-Scroll (0-Full|1-2Celled) | H-Scroll: (00-Full|10-Celled|11-Sliced)
		move.w	#$8C00|%10000001,(a6)			; APHE SNNB - H-resol (0N|1Y) | Pixel int (0N|1Y) | H-sync (0N|1Y) | Extern-pix (0N|1Y) | S/H (0N|1Y) | Interlace (00N|01Y|11-Split) | H-resol (0-20|1-28)
		move.w	#$8D00|((($FC00)>>$0A)&$FF),(a6)	; 00FE DCBA - Horizontal Scroll Table VRam address
		move.w	#$8E00|%00000000,(a6)			; 0000 0000 - Unknown/Unused Register
		move.w	#$8F00|$02,(a6)				; 7654 3210 - Auto Increament
		move.w	#$9000|%00010001,(a6)			; 00VV 00HH - Plane Y Size (00-20|01-40|11-80) | Plane X size (00-20|01-40|11-80)
		move.w	#$9100|$00,(a6)				; 7654 3210 - Window Horizontal Position
		move.w	#$9200|$00,(a6)				; 7654 3210 - Window Vertical Position

	; --- 68k Memory ---

		moveq	#$00,d0					; clear d0
		lea	($FFFF0000).l,a1			; main RAM
		move.w	#$FFE0/$20-1,d1				; set size of RAM

ST_ClearMain:
	rept 8
		move.l	d0,(a1)+				; clear RAM
	endr
		dbf	d1,ST_ClearMain				; repeat til main RAM is clear

	; --- Loading data ---

		lea	(Pal_Sound).l,a0			; load palette data
		lea	($FFFFFB00).w,a1			; load palette RAM
		moveq	#(((Pal_Sound_End-Pal_Sound)/4)/2)-1,d1	; set size of palette to laod

ST_LoadPal:
		move.l	(a0)+,(a1)+				; load palette
		move.l	(a0)+,(a1)+				; ''
		dbf	d1,ST_LoadPal				; repeat until entire palette is loaded

	DMA	(Map_Piano-Art_Piano), Art_Piano, $40000000
	DMA	(Art_End-Art_Extras), Art_Extras, $6C000002
	DMA	(Art_Font-Art_Keys), Art_Keys, $50000002
	DMA	(Map_Font-Art_Font), Art_Font, $58000002

		lea	Map_Piano,a0				; load plane A map address
		lea	($FFFF6000).l,a1			; load map dumping area to a1
		move.w	#(Art_Keys-Map_Piano)/$10-1,d0		; clear map add value

ST_CopyMap:
	rept 4
		move.l	(a0)+,(a1)+				; copy $10 bytes at once
	endr
		dbf	d0,ST_CopyMap				; loop until done

		lea	($FFFF6000).l,a1			; load mappings
		move.l	#$60000003,d0				; set VRAM address
		moveq	#$28-1,d1				; set width
		moveq	#$1C-1,d2				; set height
		jsr	MapScreen				; load mappings to plane in VRAM

		lea	($FFFF7220).l,a1			; load mappings of brighter bottom font bar area
		moveq	#$28-1,d1				; set width
		moveq	#$0F-1,d2				; set height
		jsr	MapScreen				; load mappings to plane in VRAM

	; --- Final subroutines ---

		lea	($FFFF6050).l,a0			; load piano mappings
		lea	($FFFF8000).w,a1			; load plane buffer
		moveq	#$16-1,d2				; set number of rows to copy

ST_LoadMapRow:
		lea	(a1),a2					; load address to a2
		lea	$80(a1),a1				; advance to next row for next pass

	rept $28/2
		move.l	(a0)+,(a2)+				; copy mappings to buffer
	endr
		dbf	d2,ST_LoadMapRow			; repeat for all rows
		bset.b	#$00,($FFFFA000).w			; set to redraw the plane
		bsr.w	ST_SetupKeyColours			; setup the colour fades/variations for the keys

	; --- Final variables ---

		moveq	#$FFFFFFFF,d0				; set "previous" X and Y menu positions to something null
		move.l	d0,($FFFFA020+4).w			; ''
		move.l	d0,($FFFFA030+4).w			; ''
		move.w	#$0118,($FFFFA026).w			; set X position of text scroll
		move.b	#$80,($FFFF9000+$0B).w			; set PCM1 and2 as already rendered (this'll force FM6 to render if no music is playing)
		move.w	#$00,($FFFFA020).w			; set ID of initial song

		; reloading a5/a6 just in case...

		lea	($C00000).l,a5				; load VDP data port
		lea	$04(a5),a6				; load VDP control port
		move.w	#$8000|%00010100,(a6)			; 00LH 01CD - Leftover SMS bar (0N|1Y) | H-Interrupt (0N|1Y) | H,V Counter (0N|1Y) | Disable video signal (0N|1Y)
		move.w	#$8100|%01110100,(a6)			; SDVM P100 - SMS mode (0N|1Y) | Display (0N|1Y) | V-Interrupt (0N|1Y) | DMA (0N|1Y) | V-resolution (0-1C|1-1E)
		move.l	#VB_SoundTest,(VBlankRout).w		; set V-blank routine
		move.b	#mus_Stop,mQueue.w			; set sound ID to "Stop music"
		or.b	#1<<mfbNoPAL,mFlags.w			; disable PAL fix
		jsr	SB_SoundTest				; rub subroutines

; ---------------------------------------------------------------------------
; Main Loop - Sound Test
; ---------------------------------------------------------------------------

ML_SoundTest:
		st.b	($FFFFF62A).w				; set 68k as ready
	vsync							; wait for V-blank
		bsr.s	SB_SoundTest				; run subroutines
	bra.s	ML_SoundTest
		tst.b	($FFFFF605).w				; has start been pressed?
		bpl.s	ML_SoundTest				; if not, branch
		move.l	#NullBlank,(HBlankRout).w		; set H-blank routine
		move.l	#NullBlank,(VBlankRout).w		; set V-blank routine
		move.b	#$04,($FFFFF600).w			; set game mode to 04 (Title Screen)
		rts						; return

; ---------------------------------------------------------------------------
; Subroutines - Sound Test
; ---------------------------------------------------------------------------

SB_SoundTest:
		bsr.w	ST_DrawFont				; draw the font (doing this BEFORE the control so scroll remains in sync)
		bsr.w	ST_Control				; read controls and perform options
		bsr.s	ST_DrawBars				; draw the transparent bars correctly
		bsr.w	ST_DrawPaino				; draw the piano background boards correctly
		bsr.w	ST_DrawKeys				; draw the keys on the piano

; ---------------------------------------------------------------------------
; Subroutine to scroll the text font of the music/sound being played
; ---------------------------------------------------------------------------

ST_ScrollFont:
		moveq	#$00,d0					; clear d0
		move.w	($FFFFA026).w,d0			; load text position
		swap	d0					; send to FG word
		lea	($FFFFCEF4).w,a1			; load scroll buffer area where text is
		move.l	d0,(a1)+				; set scroll position of text
		move.l	d0,(a1)+				; ''
		move.l	d0,(a1)+				; ''
		move.l	d0,(a1)+				; ''
		move.l	d0,(a1)+				; ''
		move.l	d0,(a1)+				; ''
		move.l	d0,(a1)+				; ''
		move.l	d0,(a1)+				; ''
		move.l	d0,(a1)+				; ''
		move.l	d0,(a1)+				; ''
		move.l	d0,(a1)+				; ''
		move.l	d0,(a1)+				; ''
		move.l	d0,(a1)+				; ''
		move.l	d0,(a1)+				; ''
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Drawing the transparent font bars
; ---------------------------------------------------------------------------

ST_DrawBars:
		move.l	#$002D0000,d0				; clear all registers
		move.l	d0,d1					; ''
		move.l	d0,d2					; ''
		move.l	d0,d3					; ''
		move.l	d0,d4					; ''
		move.l	d0,d5					; ''
		move.l	d0,d6					; ''
		move.l	d0,d7					; ''
		lea	($FFFF5E00+($28*4)).l,a1		; load bar VSRAM buffer
		movem.l	d0-d7,-(a1)				; clear buffer
		movem.l	d0-d7,-(a1)				; ''
		movem.l	d0-d7,-(a1)				; ''
		movem.l	d0-d7,-(a1)				; ''
		movem.l	d0-d7,-(a1)				; ''
		lea	($FFFFA010).l,a0			; load bar to display
		lea	(STDB_Dark).l,a2			; load brightness to use
		bsr.s	STDB_Draw				; draw the bar
		lea	($FFFFA014).l,a0			; load bar to display
		lea	(STDB_LightIn).l,a2			; load brightness to use
		bsr.s	STDB_Draw				; draw the bar
		lea	($FFFFA018).l,a0			; load bar to display
		lea	(STDB_Dark).l,a2			; load brightness to use
		bsr.s	STDB_Draw				; draw the bar
		lea	($FFFFA01C).l,a0			; load bar to display
		lea	(STDB_LightIn).l,a2			; load brightness to use

STDB_Draw:
		moveq	#$00,d6					; clear d6
		move.b	$02(a0),d6				; load size
		subq.w	#$01,d6					; minus 1 for dbf
		bmi.s	STDB_NoDraw				; if there is no size, branch
		moveq	#$00,d0					; clear d0
		move.b	(a0),d0					; load bar position
		cmpi.b	#$28,d0					; is it too far down?
		bhs.s	STDB_NoDraw				; if so, branch
		add.w	d0,d0					; multiply by long-word
		add.w	d0,d0					; ''
		lea	($FFFF5E00).l,a1			; load buffer
		adda.w	d0,a1					; advance to correct starting point
		cmpi.b	#$28+$02,d6				; is the size too large?
		bls.s	STDB_NoMaxSize				; if not, branch
		moveq	#$28+$02,d6				; set to maximum size

STDB_NoMaxSize:
		move.l	$04(a2),(a1)+				; draw edge
		dbf	d6,STDB_NoSingle			; if not finished, branch
		rts						; return

STDB_NoSingle:
		subq.w	#$02,d6					; minus size of minimum without middle
		bmi.s	STDB_End				; if there's no middle, branch

STDB_NoEnd:
		move.l	(a2),(a1)+				; draw ligh section
		dbf	d6,STDB_NoEnd				; repeat until all done

STDB_End:
		addq.w	#$01,d6					; adjust counter
		bmi.s	STDB_NoEdge				; if it was 0001 originaly, branch
		move.l	$04(a2),(a1)+				; draw egde again

STDB_NoEdge:
		move.l	$08(a2),(a1)+				; draw black line

STDB_NoDraw:
		rts						; return

	; --- Bright bar colours ---

STDB_Light:	dc.l	$00050050				; middle
		dc.l	$002D0028				; edges
		dc.l	$00550078				; black line

	; --- Dark bar colours ---

STDB_Dark:	dc.l	$002D0028				; middle
		dc.l	$002D0028				; edges
		dc.l	$00550078				; black line

	; --- Bright bar colours (WITHOUT THE EDGE) ---
	; For being displayed INSIDE a dark bar ONLY

STDB_LightIn:	dc.l	$00050050				; middle
		dc.l	$00050050				; edges
		dc.l	$00050050				; black line

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to draw the font onto the bars correctly
; ---------------------------------------------------------------------------

ST_DrawFont:

	; --- The song name ---

		move.w	($FFFFA020).w,d0			; load top menu X position
		move.w	($FFFFA022).w,d1			; is a change in progress?
		bne.s	STDF_Name				; if so, branch
		cmp.w	($FFFFA024).w,d0			; has it changed?
		beq.s	STDF_NoName				; if not, branch
		move.w	d0,($FFFFA024).w			; update change

STDF_Name:
		add.w	d0,d0					; multiply by size of long-word
		add.w	d0,d0					; ''
		lea	dSoundNames,a0				; load font list
		movea.l	(a0,d0.w),a0				; load correct string
		adda.w	d1,a0					; advance to correct character
		add.w	d1,d1					; multiply by size of word for VRAM
		addq.w	#$02,($FFFFA022).w			; advance to next character for next frame
		subi.w	#$0010,($FFFFA026).w			; decrease position
		move.b	(a0)+,d3				; load character
		bne.s	STDF_NoNameFinish			; if valid, branch
		clr.w	($FFFFA022).w				; clear change position

STDF_NoNameFinish:

		move.l	#$00034C04,d0				; prepare VRAM address
		add.w	d1,d0
		swap	d0
		move	#$2700,sr				; disable interrupts
		move.w	#$8F80,(a6)				; set to increment a single line
		bsr.w	ST_DrawChar				; render the character
		move.b	(a0)+,d3				; load character
		bne.s	STDF_NoNameFinish2			; if valid, branch
		clr.w	($FFFFA022).w				; clear change position
		moveq	#' ',d3

STDF_NoNameFinish2:
		bsr.w	ST_DrawChar				; render the character
		moveq	#' ',d3					; set to load the space character
		bsr.w	ST_DrawChar				; ''
		move.w	#$8F02,(a6)				; revert increment mode
		move	#$2300,sr				; re-enable interrupts

STDF_NoName:

	; --- The options ---

		move.w	($FFFFA030).w,d0			; load top menu X position
		cmp.w	($FFFFA034).w,d0			; has it changed?
		beq.s	STDF_NoOption				; if not, branch
		move.w	d0,($FFFFA034).w			; update change
		lsl.w	#$03,d0					; multiply by size of 2 long-words
		lea	(STC_Opt).l,a0				; load font list
		movea.l	(a0,d0.w),a0				; load correct string


		move.l	#$4D020003,d0
		move	#$2700,sr				; disable interrupts
		move.w	#$8F80,(a6)				; set to increment a single line
		bsr.s	ST_DrawText
		move.w	#$8F02,(a6)				; revert increment mode
		move	#$2300,sr				; re-enable interrupts

STDF_NoOption:
		rts						; return

; ---------------------------------------------------------------------------
; Drawing text correctly to VRAM
; ---------------------------------------------------------------------------

ST_DrawText:
		move.l	d0,d1					; get dark VRAM address
		addi.l	#(($05*$80)<<$10),d1			; ''
		move.l	#$00020000,d2				; set advance amount
		lea	(Map_Font).l,a2				; load mappings address
		move.b	(a0)+,d3				; load character

STDT_NextChar:
		bsr.s	STDT_RenderChar				; draw character
		move.b	(a0)+,d3				; load next character
		bne.s	STDT_NextChar				; if not finished, branch
		rts						; return

; ---------------------------------------------------------------------------
; Subroutine to render a single character
; ---------------------------------------------------------------------------

ST_DrawChar:
		move.l	d0,d1					; get dark VRAM address
		addi.l	#(($05*$80)<<$10),d1			; ''
		move.l	#$00020000,d2				; set advance amount
		lea	(Map_Font).l,a2				; load mappings address

STDT_RenderChar:
		moveq	#$00,d4					; set size as single tile
		lea	(a2),a1					; reload font mappings
		cmpi.b	#' ',d3					; is it a space?
		beq.w	STDT_Space				; if so, branch
		addq.w	#$04,a1					; skip to next special character
		cmpi.b	#'<',d3					; is it a *insert symbol here*?
		beq.w	STDT_Space				; if so, branch
		addq.w	#$04,a1					; skip to next special character
		cmpi.b	#'>',d3					; is it a *insert symbol here*?
		beq.w	STDT_Space				; if so, branch
		cmpi.b	#'#',d3					; is it a variable?
		bne.s	STDT_NoVar				; if not, branch
		moveq	#$00,d3					; clear d3
		move.b	(a0)+,d3				; load variable number
		subi.b	#'0',d3					; ''
		add.w	d3,d3					; multiply by word
		moveq	#$FFFFFFFF,d4				; load RAM address of variable
		move.w	STDT_VarList(pc,d3.w),d4		; ''
		move.l	d4,a1					; ''
		move.b	(a1),d3					; load variable
		move.b	d3,d4					; get first nybble
		lsr.b	#$04,d4					; ''
		andi.w	#$000F,d4				; ''
		addq.b	#$03,d4					; adjust it
		add.w	d4,d4					; multiply by long-word
		add.w	d4,d4					; ''
		lea	(a2,d4.w),a1				; load correct font mappings
		move.l	d1,(a6)					; set VRAM for dark
		move.l	$2E*4(a1),(a5)				; write character
		move.l	d0,(a6)					; set VRAM address
		move.l	(a1)+,(a5)				; write character
		add.l	d2,d0					; advance addresses
		add.l	d2,d1					; ''
		moveq	#$00,d4					; clear nybble size
		andi.w	#$000F,d3				; get second nybble
		addq.b	#$03,d3					; adjust it
		lea	(a2),a1					; load font mappings address
		bra.s	STDT_Special				; continue normally

STDT_VarList:	dc.w mTempo					; #0 - Pitch
		dc.w mSpeed					; #1 - Tempo
		dc.w $F016					; #2 - Volume
		dc.w $0000					; #3 - Unused...
								; #4
								; #5 ...etc up to #9...

STDT_NoVar:
		cmpi.b	#'-',d3					; is it a dash symbol?
		bne.s	STDT_NoDash				; if not, branch
		lea	$27*4(a2),a1
		bra.s	STDT_Space

STDT_NoDash:
		cmpi.b	#'Z',d3					; is it a regular letter or number?
		bls.s	STDT_Letter				; if so, branch
		subi.b	#'a',d3					; subtract "a" for rendering button graphics
		add.w	d3,d3					; multiply by 2 (since the tiles are twice the size
		lea	$28*4(a2),a1				; advance to button graphics
		moveq	#$01,d4					; set size as double tile
		bra.s	STDT_Special				; render the buttons

STDT_Letter:
		cmpi.b	#'9',d3					; is it a number?
		bls.s	STDT_Number				; if so, branch
		subq.b	#'A'-('9'+1),d3				; adjust to letters

STDT_Number:
		subi.b	#'0'-1,d3				; adjust character

STDT_Special:
		ext.w	d3					; clear upper byte
		add.w	d3,d3					; multiply by long-word
		add.w	d3,d3					; ''
		adda.w	d3,a1					; advance to correct character

STDT_Space:
		move.l	d1,(a6)					; set VRAM for dark
		move.l	$2E*4(a1),(a5)				; write character
		move.l	d0,(a6)					; set VRAM address
		move.l	(a1)+,(a5)				; write character
		add.l	d2,d0					; advance addresses
		add.l	d2,d1					; ''
		dbf	d4,STDT_Space				; repeat for size
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to control the menu correctly
; ---------------------------------------------------------------------------

ST_Control:
		move.l	($FFFFA004).w,d0			; load routine
		bne.s	STC_ValidRoutine			; if the routine is valid, branch
		move.l	#STC_Intro,d0				; set starting routine
		move.l	d0,($FFFFA004).w			; ''

STC_ValidRoutine:
		movea.l	d0,a0					; set address
		jmp	(a0)					; run address

; ===========================================================================
; ---------------------------------------------------------------------------
; The intro
; ---------------------------------------------------------------------------

STC_Intro:
		move.l	#$0C000000,($FFFFA010).w		; set starting position/size of bars
		move.l	#$0C000000,($FFFFA014).w		; ''
		move.l	#$1C000000,($FFFFA018).w		; ''
		move.l	#$1C000000,($FFFFA01C).w		; ''
		move.l	#STC_Intro_BarsIn,($FFFFA004).w		; set next routine
		rts						; return

	; --- Top bar in ---

STC_Intro_BarsIn:
		lea	($FFFFA010).w,a1			; load bar
		move.b	(a1),d0					; load position
		addq.b	#$02,$02(a1)				; increase size
		subq.b	#$01,d0					; decrease position
		cmpi.b	#$05,d0					; has it reached 5?
		bhi.s	STC_IBI_NoFinish			; if so, branch
		move.l	#STC_IBI_NextBar,($FFFFA004).w		; set next routine

STC_IBI_NoFinish:
		move.b	d0,(a1)					; set position
		rts						; return

	; --- Bottom bar in ---

STC_IBI_NextBar:
		lea	($FFFFA018).w,a1			; load bar
		move.b	(a1),d0					; load position
		addq.b	#$02,$02(a1)				; increase size
		subq.b	#$01,d0					; decrease position
		cmpi.b	#$15,d0					; has it reached 15?
		bhi.s	STC_IBI_NoFinishNext			; if so, branch
		move.l	#STC_IBI_Highlight,($FFFFA004).w	; set next routine

STC_IBI_NoFinishNext:
		move.b	d0,(a1)					; set position
		rts						; return

	; --- Highlighter ---

STC_IBI_Highlight:
		lea	($FFFFA014).w,a1			; load bar
		move.w	(a1),d0					; load position
		addq.b	#$01,$02(a1)				; increase size
		subi.w	#$0080,d0				; decrease position
		cmpi.w	#$0600,d0				; has it reached 5?
		bhi.s	STC_IBI_NoFinishHigh			; if so, branch
		move.l	#STC_TopBar,($FFFFA004).w		; set next routine
		subq.b	#$01,$02(a1)				; decrease size once

STC_IBI_NoFinishHigh:
		move.w	d0,(a1)					; set position
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Controls for top bar
; ---------------------------------------------------------------------------

STC_TopBar:
		bsr.w	STC_MoveHighlight			; move the highlight bar correctly
		move.b	($FFFFF605).w,d5			; load pressed buttons
		btst.l	#$01,d5					; was down pressed?
		beq.s	STC_TB_NoDown				; if not, branch
		andi.w	#%1111110011111100,($FFFFF604).w	; clear up/down buttons
		move.l	#STC_BottomBar,($FFFFA004).w		; set next routine
		jmp	STC_BottomBar				; run the routine

STC_TB_NoDown:
		andi.b	#%00001100,d5				; get only left/right
		beq.s	STC_TB_NoPress				; if neither were pressed, branch
		clr.w	($FFFFA022).w				; reset draw position
		move.w	#$0118,($FFFFA026).w			; set X position of text scroll
		move.b	#$40,($FFFFA00F).w			; reset held timer
		bra.s	STC_TB_NoHeld				; continue

STC_TB_Release:
		move.b	#$40,($FFFFA00F).w			; reset held timer
		bra.s	STC_TB_NoRight				; continue

STC_TB_NoPress:
		move.b	($FFFFF604).w,d5			; load held buttons
		andi.b	#%00001100,d5				; get only left/right
		beq.s	STC_TB_Release				; if neither were pressed, branch
		subq.b	#$01,($FFFFA00F).w			; decrease hold timer
		bcc.s	STC_TB_NoRight				; if still running, branch
		clr.w	($FFFFA022).w				; reset draw position
		move.w	#$0118,($FFFFA026).w			; set X position of text scroll
		move.b	#$06,($FFFFA00F).w			; reset hold timer

STC_TB_NoHeld:
		lsr.b	#$03,d5					; shift left into carry
		bcc.s	STC_TB_NoLeft				; if left was not pressed, branch
		moveq	#$01,d0					; load the amount to move
		bsr.w	STC_SkipLeft				; run code

STC_TB_NoLeft:
		lsr.b	#$01,d5					; shift right into carry
		bcc.s	STC_TB_NoRight				; if right was not pressed, branch
		moveq	#$01,d0					; load the amount to move
		bsr.w	STC_SkipRight				; run code

STC_TB_NoRight:
		bra.w	STC_BB_NoRight

STC_TB_Play:
		addq.b	#2,($FFFF900F).w			; force FM6/PCM1 toggle to update
		move.w	#$FFFF,($FFFFA034).w			; invalidate the "options" text area (so it renders the changing numbers)
		move.w	($FFFFA020).w,d0			; load list position
;		add.w	d0,d0					; multiply by size of long-word
;		add.w	d0,d0					; ''
;		move.b	STC_List(pc,d0.w),d0			; load correct ID

STC_TB_PlaySFX:
;		cmpi.b	#$A0,d0					; is it a music track from 80 to 9F?
;		bhs.s	STC_TB_NoDelay				; if not, branch
	;	move.b	#$03,($FFFFA001).w			; set the "postpone" draw timer

STC_TB_NoDelay:
		add.b	#MusOff,d0				; add music offset
		move.b	d0,mQueue.w				; play the sound

STC_TB_NoPlay:
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Controls for bottom bar
; ---------------------------------------------------------------------------

STC_BottomBar:
		bsr.w	STC_MoveHighlight			; move the highlight bar
		move.b	($FFFFF605).w,d5			; load pressed buttons
		btst.l	#$00,d5					; was up pressed?
		beq.s	STC_BB_NoUp				; if not, branch
		andi.w	#%1111110011111100,($FFFFF604).w	; clear up/down buttons
		move.l	#STC_TopBar,($FFFFA004).w		; set next routine
		jmp	STC_TopBar				; run the routine

STC_BB_NoUp:
		andi.b	#%00001100,d5				; get only left/right
		beq.s	STC_BB_NoRight				; if neither were pressed, branch
		lsr.b	#$03,d5					; shift left into carry
		bcc.s	STC_BB_NoLeft				; if left was not pressed, branch
		subq.w	#$01,($FFFFA030).w			; decrease bottom menu X position
		bcc.s	STC_BB_NoLeft				; if it hasn't gone below the bottom, branch
		move.w	#((STC_Opt_End-STC_Opt)/$08)-1,($FFFFA030).w ; set to end of list

STC_BB_NoLeft:
		lsr.b	#$01,d5					; shift right into carry
		bcc.s	STC_BB_NoRight				; if right was not pressed, branch
		addq.w	#$01,($FFFFA030).w			; increase bottom menu X position
		cmpi.w	#((STC_Opt_End-STC_Opt)/$08),($FFFFA030).w ; has it reached the end of the list?
		blo.s	STC_BB_NoRight				; if not, branch
		clr.w	($FFFFA030).w				; set to beginning of list

STC_BB_NoRight:
		move.b	($FFFFF605).w,d5			; reload pressed buttons
		bmi.w	STC_TB_Play				; if start was pressed, branch

		andi.b	#%01100000,d5				; get A or C
		beq.s	STC_BB_NoPress				; if nothing was pressed, branch
		move.b	#$20,($FFFFA100).w			; reset hold timer
		bra.s	STC_BB_YesPlay				; continue into playing routine

STC_BB_NoPress:
		move.b	($FFFFF604).w,d5			; reload pressed buttons
		andi.b	#%01100000,d5				; get A or C
		beq.s	STC_BB_NoPlay				; if nothing was pressed, branch
		subq.b	#$01,($FFFFA100).w			; decrease timer
		bpl.s	STC_BB_NoPlay				; if timer is still running, branch
		sf.b	($FFFFA100).w				; keep timer at 00

		subq.b	#$01,($FFFFA101).w			; decrease speed
		bpl.s	STC_BB_NoPlay				; if still delay timer is still running, branch
		move.b	#$01,($FFFFA101).w			; reset delay timer

STC_BB_YesPlay:
		move.w	#$FFFF,($FFFFA034).w			; invalidate the "options" text area (so it renders the changing numbers)
		move.w	($FFFFA030).w,d0			; load list position
		lsl.w	#$03,d0					; multiply by size of 2 long-words
		movea.l	STC_Opt+$04(pc,d0.w),a0			; load correct address
		jmp	(a0)					; run address

STC_BB_NoPlay:
		rts						; return

; ---------------------------------------------------------------------------
; Sound Test - options
; ---------------------------------------------------------------------------

STC_Opt:	dc.l	STC_ST_Fade,	STC_Fade
		dc.l	STC_ST_Tempo,	STC_Tempo
		dc.l	STC_ST_Volume,	STC_Volume
	if FEATURE_UNDERWATER
		dc.l	STC_ST_UWater,	STC_UWater
	endif
		dc.l	STC_ST_Speed,	STC_Speed
		dc.l	STC_ST_Shoes,	STC_Shoes
		dc.l	STC_ST_Skip,	STC_Skip
	;	dc.l	STC_ST_FM1,	STC_FM1
	;	dc.l	STC_ST_FM2,	STC_FM2
	;	dc.l	STC_ST_FM3,	STC_FM3
	;	dc.l	STC_ST_FM4,	STC_FM4
	;	dc.l	STC_ST_FM5,	STC_FM5
	;	dc.l	STC_ST_FM6,	STC_FM6
	;	dc.l	STC_ST_PCM1,	STC_PCM1
	;	dc.l	STC_ST_PCM2,	STC_PCM2
	;	dc.l	STC_ST_PSG1,	STC_PSG1
	;	dc.l	STC_ST_PSG2,	STC_PSG2
	;	dc.l	STC_ST_PSG3,	STC_PSG3
STC_Opt_End:

	if FEATURE_UNDERWATER
STC_ST_UWater:	dc.b	" a ON      < UNDERWATER >     OFF c ",$00
	endif

STC_ST_Skip:	dc.b	" a LEFT    < SKIP SONGS >   RIGHT c ",$00
STC_ST_Tempo:	dc.b	" a DOWN    <  TEMPO  #0 >      UP c ",$00
STC_ST_Shoes:	dc.b	" a DOWN    <  SHOES  #1 >      UP c ",$00
STC_ST_Volume:	dc.b	" a LOUD    <  VOLUME #2 >   QUIET c ",$00
STC_ST_Speed:	dc.b	" a ON      < SPEEDSHOES >     OFF c ",$00
STC_ST_Fade:	dc.b	" a OR c   <  FADE OUT  >   a OR c ",$00
STC_ST_FM1:	dc.b	" a OR c   < FM  1 MUTE >   a OR c ",$00
STC_ST_FM2:	dc.b	" a OR c   < FM  2 MUTE >   a OR c ",$00
STC_ST_FM3:	dc.b	" a OR c   < FM  3 MUTE >   a OR c ",$00
STC_ST_FM4:	dc.b	" a OR c   < FM  4 MUTE >   a OR c ",$00
STC_ST_FM5:	dc.b	" a OR c   < FM  5 MUTE >   a OR c ",$00
STC_ST_FM6:	dc.b	" a OR c   < FM  6 MUTE >   a OR c ",$00
STC_ST_PCM1:	dc.b	" a OR c   < PCM 1 MUTE >   a OR c ",$00
STC_ST_PCM2:	dc.b	" a OR c   < PCM 2 MUTE >   a OR c ",$00
STC_ST_PSG1:	dc.b	" a OR c   < PSG 1 MUTE >   a OR c ",$00
STC_ST_PSG2:	dc.b	" a OR c   < PSG 2 MUTE >   a OR c ",$00
STC_ST_PSG3:	dc.b	" a OR c   < PSG 3 MUTE >   a OR c ",$00
		even

	; --- Skip songs ---

STC_Skip:
		clr.w	($FFFFA022).w				; reset draw position
		move.w	#$0118,($FFFFA026).w			; set X position of text scroll

		moveq	#$10,d0					; load number of songs to skip
		add.b	d5,d5					; shift button A to MSB
		bpl.s	STC_SkipRight				; if it was not A, branch for B

STC_SkipLeft:
		sub.w	d0,($FFFFA020).w			; decrease top menu X position
		bcc.s	STC_SkipDone				; if it hasn't gone below the bottom, branch
		move.w	#SFXlast-MusOff-1,($FFFFA020).w		; set to end of list

STC_SkipDone:
		rts

STC_SkipRight:
		add.w	d0,($FFFFA020).w			; increase top menu X position
		cmpi.w	#SFXlast-MusOff,($FFFFA020).w		; has it reached the end of the list?
		blo.s	STC_SkipDone				; if not, branch
		clr.w	($FFFFA020).w				; set to beginning of list
		rts

	if FEATURE_UNDERWATER
	; --- Underwater mode ---

STC_UWater:
		add.b	d5,d5					; shift button A to MSB
		bpl.s	.b					; if it was not A, branch for B
		move.b	#Mus_ToWater,mQueue+1.w			; play underwater effect
		rts

.b
		move.b	#Mus_OutWater,mQueue+1.w		; remove underwater effect
		rts
	endif

	; --- Speed shoes ---

STC_Speed:
		add.b	d5,d5					; shift button A to MSB
		bpl.s	.b					; if it was not A, branch for B
		move.b	#Mus_ShoesOn,mQueue+1.w			; play speed shoes effect
		rts

.b
		move.b	#Mus_ShoesOff,mQueue+1.w		; remove speed shoes effect
		rts

	; --- Tempo control ---

STC_Tempo:
		add.b	d5,d5					; shift button A to MSB
		bpl.s	STC_T_NoA				; if it was not A, branch for B
		subq.b	#$02,mTempo.w				; decrease the music tempo

STC_T_NoA:
		addq.b	#$01,mTempo.w				; increase the music tempo
		rts						; return

	; --- Speed tempo control ---

STC_Shoes:
		add.b	d5,d5					; shift button A to MSB
		bpl.s	STC_S_NoA				; if it was not A, branch for B
		subq.b	#$02,mSpeed.w				; decrease the music tempo

STC_S_NoA:
		addq.b	#$01,mSpeed.w				; increase the music tempo
		rts						; return

	; --- Volume control ---

STC_Volume:
		add.b	d5,d5					; shift button A to MSB
		bpl.s	STC_V_NoA				; if it was not A, branch for B
		subq.b	#$01,($FFFFF016).w			; decrease the music volume
		bpl.s	STC_UpdateVolume			; if still valid, branch
		sf.b	($FFFFF016).w				; keep volume at 00

STC_UpdateVolume:
		move.b	$FFFFF016.w,d0				; load volume to d0
		move.b	d0,mMasterVolFM.w			; save FM master volume
		move.b	d0,mMasterVolPSG.w			; save PSG master volume
		move.b	d0,mMasterVolDAC.w			; save DAC master volume
		jmp	dUpdateVolumeAll			; request volume update for every channel

STC_V_NoA:
		addq.b	#$01,($FFFFF016).w			; increase the music volume
		cmpi.b	#$7F,($FFFFF016).w			; is it at maximum volume?
		bls.s	STC_UpdateVolume			; if not, branch
		move.b	#$7F,($FFFFF016).w			; force to maximum volume
		bra.s	STC_UpdateVolume			; continue and trigger volume to update

	; --- Fade out ---

STC_Fade:
		move.b	#mus_Fadeout,mQueue.w
		rts

	; --- Channel control ---

STC_FM1:
		not.b	($FFFFF0A0+$21).w
		rts

STC_FM2:
		not.b	($FFFFF0D0+$21).w
		rts

STC_FM3:
		not.b	($FFFFF100+$21).w
		rts

STC_FM4:
		not.b	($FFFFF130+$21).w
		rts

STC_FM5:
		not.b	($FFFFF160+$21).w
		rts

STC_FM6:
		not.b	($FFFFF190+$21).w
		rts

STC_PCM1:
		not.b	($FFFFF040+$21).w
		rts

STC_PCM2:
		not.b	($FFFFF070+$21).w
		rts

STC_PSG1:
		not.b	($FFFFF1C0+$21).w
		rts

STC_PSG2:
		not.b	($FFFFF1F0+$21).w
		rts

STC_PSG3:
		not.b	($FFFFF220+$21).w
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to move the highlighter to the correct position
; ---------------------------------------------------------------------------

STC_MoveHighlight:
		lea	($FFFFA014).w,a1			; load highlighters
		cmpi.l	#STC_TopBar,($FFFFA004).w		; is the routine set to bottom bar?
		bne.s	STC_MH_MoveDown				; if not, branch
		tst.b	$0A(a1)					; has the top bar's size been reduced to 0?
		beq.s	STC_MH_Finish				; if so, branch
		subq.b	#$01,$0A(a1)				; decrease size
		addi.w	#$0080,$08(a1)				; increase position
		addq.b	#$01,$02(a1)				; increase size
		subi.w	#$0080,(a1)				; decrease position

STC_MH_Finish:
		rts						; return

STC_MH_MoveDown:
		tst.b	$02(a1)					; has the top bar's size been reduced to 0?
		beq.s	STC_MH_Finish				; if so, branch
		subq.b	#$01,$02(a1)				; decrease size
		addi.w	#$0080,(a1)				; increase position
		addq.b	#$01,$0A(a1)				; increase size
		subi.w	#$0080,$08(a1)				; decrease position
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to create all possible colour fading values for all channels and types
; ---------------------------------------------------------------------------

ST_SetupKeyColours:
		lea	(ST_ColourList).l,a0			; load colours list
		lea	($FFFF5800).l,a3			; load palette RAM data

		moveq	#$06-1,d7				; number of key colours (2 FM, 2 PCM, 2 PSG (one for BGM, one for SFX))

STSKC_NextKey:
		move.l	d7,-(sp)				; store counter
		moveq	#$02-1,d6				; set to do twice (once for white, once for black)
		lea	(ST_ColourBlank).l,a1			; load blank colours list to fade to

STSKC_NextBlack:
		move.l	d6,-(sp)				; store counter

		; normal
		lea	(a3),a2					; load first colour address
		bsr.s	STSKC_CreateColour			; create white variations
		addq.w	#$02,a3					; advance for next colour
		lea	(a3),a2					; load second colour address
		bsr.s	STSKC_CreateColour			; create white variations
		lea	$1E(a3),a3				; advance for next colour

		; attack
		subq.w	#$04,a1					; go back and redo colours but for attack keys
		lea	(a3),a2					; load first colour address
		bsr.s	STSKC_CreateColour			; create white variations
		addq.w	#$02,a3					; advance for next colour
		lea	(a3),a2					; load second colour address
		bsr.s	STSKC_CreateColour			; create white variations
		lea	$1E(a3),a3				; advance for next colour

		subq.w	#$08,a0					; go back and redo colour but for black keys

		move.l	(sp)+,d6				; reload counter
		dbf	d6,STSKC_NextBlack			; repeat for black keys
		addq.w	#$08,a0					; continue to next colours

		move.l	(sp)+,d7				; restore counter
		dbf	d7,STSKC_NextKey			; repeat for all keys
		rts						; return

STSKC_CreateColour:
		clr.w	(a2)					; clear multiplication area
		move.w	(a0)+,d0				; load colour source
		move.w	(a1)+,d1				; load colour destination

	; --- Blue fraction ---

		move.w	d0,d2					; load blue
		sf.b	d2					; ''
		move.w	d1,d3					; load destination
		sf.b	d3					; ''
		sub.w	d2,d3					; get distance
		ext.l	d3					; extend to long-word
		divs.w	#$07,d3					; divide by 7 colours

	; --- Green fraction ---

		move.b	d0,d2					; load green
		andi.l	#$000000E0,d2				; ''
		move.b	d2,(a2)					; multiply by 100
		move.w	(a2),d2					; ''
		move.b	d1,d4					; load distance
		andi.l	#$000000E0,d4				; ''
		move.b	d4,(a2)					; multiply by 100
		move.w	(a2),d4					; ''
		sub.l	d2,d4					; get distance
		divs.w	#$07,d4					; divide by 7 colours
		ext.l	d4					; clear remainder
		asl.l	#$08,d4					; align into position

	; --- Red fraction ---

		move.b	d0,d2					; load red
		andi.l	#$0000000E,d2				; ''
		move.b	d2,(a2)					; multiply by 100
		move.w	(a2),d2					; ''
		move.b	d1,d5					; load distance
		andi.l	#$0000000E,d5				; ''
		move.b	d5,(a2)					; multiply by 100
		move.w	(a2),d5					; ''
		sub.l	d2,d5					; get distance
		divs.w	#$07,d5					; divide by 7 colours
		ext.l	d5					; clear remainder
		asl.l	#$08,d5					; align into position

	; --- creating starting colours ---

		move.w	d0,d2					; get red
		andi.l	#$0000000E,d2				; ''
		swap	d2					; align to quotient
		move.w	d0,d1					; get green
		andi.l	#$000000E0,d1				; ''
		swap	d1					; align to quotient
		andi.w	#$0E00,d0				; get blue

		moveq	#$08-1,d7				; set number of colours to do
		bra.s	STSKC_StartColour			; branch into loop

STSKC_NextColour:
		add.w	d3,d0					; advance blue
		add.l	d4,d1					; advance green
		add.l	d5,d2					; advance red

STSKC_StartColour:
		swap	d1					; get quotients
		swap	d2					; ''
		move.w	d0,d6					; get blue
		andi.w	#$0F00,d6				; ''
		or.b	d1,d6					; get green
		andi.w	#$0FF0,d6				; ''
		or.b	d2,d6					; get red
		andi.w	#$0FFF,d6				; ''
		move.w	d6,(a2)					; save colour
		andi.w	#$0111,d6				; get half fractions
		add.w	(a2),d6					; add to colour
		andi.w	#$0EEE,d6				; get only the colour
		move.w	d6,(a2)+				; save to palette correctly
		addq.w	#$02,a2					; skip slot
		swap	d1					; restore quotients
		swap	d2					; ''
		dbf	d7,STSKC_NextColour			; repeat for all 8 colours

		rts						; return

		;	Light, Dark

ST_ColourBlank:	dc.w	$0EEA,$0886				; white keys
		dc.w	$0EEA,$0000				; black keys

		;	  Normal	Attack

ST_ColourList:	dc.w	$000E,$0008, $00AE,$0068		; FM BGM
		dc.w	$080C,$0206, $0C8E,$0628		; FM SFX
		dc.w	$0E00,$0800, $0E0C,$0806		; PCM BGM
		dc.w	$0000,$0000, $0000,$0000		; PCM SFX
		dc.w	$00A0,$0060, $08C0,$0680		; PSG BGM
		dc.w	$008E,$0048, $00CC,$008C		; PSG SFX

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to draw the key sprites on the piano
; ---------------------------------------------------------------------------

ST_DrawKeys:
		lea	(ST_BGMRAM).l,a4			; load channel RAM list
		lea	($FFFFF800).w,a1			; load sprite RAM
		moveq	#$00,d7					; clear key counter
		tst.b	($FFFFA001).w				; is render being delayed?
		bne.w	STDK_FinishKeys				; if so, branch
		moveq	#$00,d5					; reset keyboard ID
		moveq	#$00,d6					; reset sprite count

STDK_NextKey:
		moveq	#$00,d4					; set to use BGM colours
		movea.w	(a4),a2					; load channel

		cmp.b	#ctDAC1,cType(a2)			; check for DAC1
		bne.s	STDK_NoDAC1				; if not, branch
		tst.b	($FFFF900F).w				; special: check if FM6 is enabled
		beq.w	STDK_NoChannel				; if yes, skip

STDK_NoDAC1:
		btst	#cfbInt,(a2)				; is the channel being interrupted by SFX?
		bne.s	STDK_CheckSPE				; if so, branch
		bra.s	STDK_NoSPE				; if not, branch

	tst.b	$21(a2)					; is the channel muted?
	beq.s	STDK_NoSPE				; if not, branch
	tst.b	(a2)
	bpl.s	STDK_NoSPE
	move.w	d5,d1					; adjust Y position
	lsl.w	#$04,d1					; ''
	addi.w	#$0088,d1				; ''
	move.w	d1,(a1)+				; Y position
	move.b	#$09,(a1)+				; shape
	addq.b	#$01,d6					; sprite link
	move.b	d6,(a1)+				; ''
	move.w	#($AC00/$20),(a1)+			; VRAM
	move.w	#$0088,(a1)+				; X pos
		bra.w	STDK_NoChannel				; continue

STDK_CheckSPE:
		addi.w	#$0080,d4				; advance to SFX colours

STDK_CheckSFX:
		move.w	ST_SFXRAM-ST_BGMRAM(a4),d0		; load SFX channel
		beq.s	STDK_NoChannel				; if there is no SFX channel, branch
		movea.w	d0,a2					; set address

STDK_NoSPE:

	; --- Reading channel ---

		move.b	(a2),d0					; load channel status
		bpl.s	STDK_NoChannel				; if the channel is not running, branch
		btst	#ctbDAC,cType(a2)			; check if this a DAC channel
		bne.s	STDK_SkipRest				; if so, do not check resting
		btst	#cfbRest,d0				; is the channel resting?
		bne.s	STDK_NoChannel				; if so, branch

STDK_SkipRest:
		btst	#cfbHold,d0				; is soft key on?
		bne.s	STDK_NoHitKey				; if so, branch
		move.b	cLastDur(a2),d0				; load main timer
		sub.b	cDuration(a2),d0			; minus current timer
		cmpi.b	#$03,d0					; has the key been hit recently?
		bgt.s	STDK_NoHitKey				; if not, branch
		addi.w	#$0020,d4				; advance to key hit colours

STDK_NoHitKey:
		move.w	d7,d0					; load channel counter
		lsl.w	#$03,d0					; multiply by size of two long-words
		lea	(STDK_ChanRouts).l,a0			; load routine/palette list
		adda.w	d0,a0					; load correct routine list
		move.l	(a0)+,a3				; load palette RAM to edit
		move.l	(a0)+,a0				; load routine
		jsr	(a0)					; run routine
		beq.s	STDK_NoChannel				; if there's no frequency to read, branch
		cmpi.b	#$5F-$0C,d2				; has the note gone outside of the keyboard?
		bhi.s	STDK_NoChannel				; if so, branch and ignore

	; This is to allow SFX to display the highest octave (by moving the note down an octave)

;	bls.s	STDK_InRange				; if not, branch
;	bmi.s	STDK_NoChannel				; if negative, branch (outside of keyboard to the left)
;	tst.b	d4					; is this an SFX?
;	bpl.s	STDK_NoChannel				; if not, branch and don't display keys
;	subi.b	#$0C,d2					; move the note down an octave
;	cmpi.b	#$5F-$0C,d2				; has the note gone outside of the keyboard?
;	bhi.s	STDK_NoChannel				; if not, branch

STDK_InRange:
		bsr.w	STDK_GetPos				; load the correct X and VRAM positions
		addi.w	#$00A0,d0				; adjust X position
		move.w	d5,d1					; adjust Y position
		lsl.w	#$04,d1					; ''
		addi.w	#$0088,d1				; ''
		move.w	d7,d3					; adjust VRAM
		add.w	d3,d3					; ''
		add.w	STDK_NoteVRAM(pc,d3.w),d2		; ''

		move.w	d1,(a1)+				; Y position
		move.b	#$01,(a1)+				; shape
		addq.b	#$01,d6					; sprite link
		move.b	d6,(a1)+				; ''
		move.w	d2,(a1)+				; VRAM
		move.w	d0,(a1)+				; X pos

STDK_NoChannel:
		addq.w	#$02,a4					; advance to next channel
		addq.b	#$01,d7					; increase key counter
		addq.b	#$01,d5					; increase keyboard ID
		cmpi.b	#10,d7					; have all 10 keys been accounted for?
		blo.w	STDK_NextKey				; if not, branch
		cmpi.b	#11,d7					; has FM6 been checked for?
		bhs.s	STDK_FinishKeys				; if so, branch

		moveq	#$05,d5					; set to use PCM 1's keyboard (for FM6)
		tst.b	($FFFF900F).w				; check if PCM is streaming
		beq.w	STDK_NextKey				; if not, do another check for FM 6

STDK_FinishKeys:
		moveq	#$00,d0					; set end of sprite list
		move.l	d0,(a1)+				; ''
		rts						; return

; ---------------------------------------------------------------------------
;
; ---------------------------------------------------------------------------

STDK_NoteVRAM:	dc.w	$2480		; FM 1
		dc.w	$2488		; FM 2
		dc.w	$2490		; FM 3
		dc.w	$2498		; FM 4
		dc.w	$24A0		; FM 5
		dc.w	$4480		; PCM 1
		dc.w	$4488		; PCM 2
		dc.w	$4490		; PSG 1
		dc.w	$4498		; PSG 2
		dc.w	$44A0		; PSG 3/4
		dc.w	$24A8		; FM 6

; ---------------------------------------------------------------------------
; Channel specific controls
; ---------------------------------------------------------------------------

STDK_ChanRouts:	dc.l	$FFFFFB22, STDK_ChanFM
		dc.l	$FFFFFB26, STDK_ChanFM
		dc.l	$FFFFFB2A, STDK_ChanFM
		dc.l	$FFFFFB2E, STDK_ChanFM
		dc.l	$FFFFFB32, STDK_ChanFM
		dc.l	$FFFFFB42, STDK_ChanPCM
		dc.l	$FFFFFB46, STDK_ChanPCM
		dc.l	$FFFFFB4A, STDK_ChanPSG
		dc.l	$FFFFFB4E, STDK_ChanPSG
		dc.l	$FFFFFB52, STDK_ChanPSG
		dc.l	$FFFFFB36, STDK_ChanFM

	; --- FM ---

STDK_ChanFM:
		moveq	#-$0C,d0				; prepare volume offset to d0
		add.b	cChipVol(a2),d0				; add chip volume to d0
		bpl.s	STDK_VolFM_Max				; branch if positive
		cmp.b	#-$10,d0				; check if we underflowed
		slt	d0					; if yes, clear d0, else set it to $FF

STDK_VolFM_Max:
		andi.b	#$7C,d0					; get volume range 7C
		cmpi.b	#$40,d0					; is the volume below 40?
		blo.s	STDK_VolFM_Min				; if not, branch
		moveq	#$3C,d0					; set to maximum 3C

STDK_VolFM_Min:
		add.b	d0,d4					; add to key palette
		lea	dFreqFM,a0				; load FM frequency table
		tst.w	cFreq(a2)				; check note frequency
		beq.s	STDK_InvalidFM				; if it's 0000, branch

		move.w	cChipFreq(a2),d0			; load chip frequency
		bsr.w	STDK_GetNoteFM				; load the correct note
		lea	($FFFF5800).l,a0			; load FM colours for keys
		andi.b	#%11011,ccr				; clear the Z flag (so it's non-zero)

STDK_InvalidFM:
		rts						; return

	; --- PCM ---

STDK_ChanPCM:
		move.b	cChipVol(a2),d0				; load chip volume to d0
		bpl.s	STDK_VolPCM_Max				; if positive, branch
		moveq	#$7F,d0					; set to maximum volume

STDK_VolPCM_Max:
		andi.b	#$7C,d0					; get volume range 7C
		cmpi.b	#$40,d0					; is the volume below 40?
		blo.s	STDK_VolPCM_Min				; if not, branch
		moveq	#$3C,d0					; set to maximum 3C

STDK_VolPCM_Min:
;	lsr.b	#$02,d0
;	andi.b	#%00011100,d0
		add.b	d0,d4					; add to key palette

		lea	dFreqDAC,a0				; load PCM frequency table
		move.w	cChipFreq(a2),d0			; load chip frequency
		tst.w	d0					; check frequency
		bpl.s	STDK_VolPCM_Frq				; branch if result is positive
		neg.w	d0					; negate frequency

STDK_VolPCM_Frq:
		bsr.w	STDK_GetNote				; load the correct note
		lea	($FFFF5900).l,a0			; load PCM colours for keys
		andi.b	#%11011,ccr				; clear the Z flag (so it's non-zero)
		rts						; return

	; --- PSG ---

STDK_ChanPSG:
		move.b	cChipVol(a2),d0				; load chip volume to d0
		lsr.b	#2,d0					; quarter volume output
		andi.b	#$3C,d0					; get volume range 3C
		cmpi.b	#$40,d0					; is the volume below 40?
		blo.s	STDK_VolPSG_Min				; if not, branch
		moveq	#$7C,d0					; set to maximum 7C

STDK_VolPSG_Min:
		add.b	d0,d4					; add to key palette
		lea	dFreqPSG-2,a0				; load PSG frequency table
		tst.w	cFreq(a2)				; check frequency
		bmi.s	STDK_InvalidPSG				; if it's not FFFF, branch

		move.w	cChipFreq(a2),d0			; load chip frequency
		bsr.w	STDK_GetNoteRev				; load the correct note
		lea	($FFFF5A00).l,a0			; load PSG colours for keys
		andi.b	#%11011,ccr				; clear the Z flag (so it's non-zero)
		rts						; return

STDK_InvalidPSG:
		ori.b	#%00100,ccr				; set the Z flag (so it's zero)
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Getting the right X and Y keyboard positions as well as correct frame
; ---------------------------------------------------------------------------

STDK_GetPos:
		divu.w	#$000C,d2				; ''
		lsl.w	#$03,d2					; multiply by 28 (size of octave piece on keyboard)
		move.w	d2,d0					; ''
		add.w	d2,d2					; ''
		add.w	d2,d2					; ''
		add.w	d2,d0					; ''
		swap	d2					; get key position
		add.b	STDK_KeyCol(pc,d2.w),d4			; add the black key's palette address
		move.l	(a0,d4.w),(a3)				; save colours to palete buffer
		add.w	d2,d2					; multiply by size of long-word
		add.w	d2,d2					; ''
		lea	STDK_KeyPos(pc,d2.w),a0			; load key positions
		add.w	(a0)+,d0				; add X position to octave position
		move.w	(a0)+,d2				; load VRAM art piece
		rts						; return

STDK_KeyCol:	dc.b	$00,$40,$00,$40,$00,$00,$40,$00,$40,$00,$40,$00


		;	 XXXX  VRAM
STDK_KeyPos:	dc.w	$FFFF,$0000
		dc.w	$0002,$0002
		dc.w	$0005,$0004
		dc.w	$0008,$0002
		dc.w	$000A,$0006
		dc.w	$0010,$0000
		dc.w	$0013,$0002
		dc.w	$0016,$0004
		dc.w	$0019,$0002
		dc.w	$001C,$0004
		dc.w	$001F,$0002
		dc.w	$0021,$0006

; ===========================================================================
; ---------------------------------------------------------------------------
; Working out the right note based on frequency (also accounts for detune/LFO)
; ---------------------------------------------------------------------------

	; --- Special octave version for FM ---

STDK_GetNoteFM:
		move.w	d0,d2					; load frequency
		andi.w	#$07FF,d2				; clear octave
		cmpi.w	#$025E-$25,d2	; 25E to 284		; is it down an octave?
		bhi.s	STDKGNFM_NoDown				; if not, branch
		subi.w	#$05E2-$40,d0	; 5E2 TO 5C4		; move frequency down a single octave
		bra.s	STDK_GetNote				; continue

STDKGNFM_NoDown:
		cmpi.w	#$047C+$40,d2	; 47C to 4C0		; is it up an octave?
		blo.s	STDK_GetNote				; if not, branch
		addi.w	#$05E2-$40,d0	; 5E2 TO 5C4		; move frequency up a single octave

	; --- Normal get note (just happens that only PCM is normal, how ironic) ---

STDK_GetNote:
		move.l	d4,-(sp)				; store d4
		moveq	#$60,d2					; set number of notes to check
		move.w	(a0)+,d3				; load first frequency

STDKGN_Next:
		move.w	d3,d4					; store last note
		move.w	(a0)+,d3				; load next note
		move.w	d3,d1					; get distance between them
		sub.w	d4,d1					; ''
		lsr.w	#$01,d1					; get the exact middle
		add.w	d4,d1					; ''
		cmp.w	d1,d0					; has the frequency passed this point?
		dble	d2,STDKGN_Next				; if not, branch
		neg.w	d2					; reverse
		addi.w	#$005F,d2				; ''
		move.l	(sp)+,d4				; restore d4
		rts						; return

	; --- Reverse version for PSG ---

STDK_GetNoteRev:
		move.l	d4,-(sp)				; store d4
		moveq	#$60,d2					; set number of notes to check
		move.w	(a0)+,d3				; load first frequency

STDKGNR_Next:
		move.w	d3,d4					; store last note
		move.w	(a0)+,d3				; load next note
		move.w	d4,d1					; get distance between them
		sub.w	d3,d1					; ''
		lsr.w	#$01,d1					; get the exact middle
		add.w	d3,d1					; ''
		cmp.w	d1,d0					; has the frequency passed this point?
		dbge	d2,STDKGNR_Next				; if not, branch
		neg.w	d2					; reverse
		addi.w	#$005F,d2				; ''
		move.l	(sp)+,d4				; restore d4
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to draw the paino mappings properly
; ---------------------------------------------------------------------------

ST_DrawPaino:
		lea	($FFFF9000).w,a3			; load status

		lea	(ST_BGMRAM).l,a4			; load channel RAM list
		lea	($FFFF6052).l,a0			; load piano mappings
		lea	($FFFF8002).w,a1			; load plane buffer

		move.w	#$0870,d5				; load ON mappings address advancement
		moveq	#$02-1,d6				; set number of rows to render per piano
		moveq	#$0A-1,d7				; do all channels
		bsr.w	ST_DrawChannels				; ''

	; --- PSG 4 ---

		tst.b	(a2)					; was PSG 3 running?
		bmi.s	ST_CheckPSG4				; if so, branch

ST_NoPSG4:
		bclr.b	#$07,(a3)+				; clear PSG 4 flag
		beq.w	ST_CheckFM6				; if it was already cleared, branch

		moveq	#$02-1,d1				; set number of rows to draw
		lea	($FFFF6692).l,a0			; load piano mappings
		lea	($FFFF8A02).w,a1			; load plane buffer
		bsr.w	ST_DrawPiano

		bset.b	#$00,($FFFFA000).w			; set plane redraw flag
		bra.w	ST_CheckFM6				; continue

ST_CheckPSG4:
		move.b	cStatPSG4(a2),d4			; load PSG 3's PSG 4 mode flags
		beq.s	ST_NoPSG4				; if PSG 4 mode is off, branch
		andi.b	#$07,d4					; get only the mode bits
		ori.b	#$80,d4					; enable the PSG 4 on bit
		cmp.b	(a3),d4					; has the mode changed?
		beq.w	ST_FinishPSG4				; if not, branch
		move.b	d4,(a3)					; update mode
		bset.b	#$00,($FFFFA000).w			; set plane redraw flag

		; "PSG 4"

		lea	($FFFF6692).l,a0			; load piano mappings
		lea	($FFFF8A02).w,a1			; load plane buffer
		moveq	#$03-1,d2				; set width of piece
		bsr.w	ST_DrawPiece_On				; draw "PSG 4" on

		; "WHITE/PERIODIC"

		addq.w	#$02,a0					; advance to noise type
		addq.w	#$02,a1					; ''
		moveq	#$08-1,d2				; set width of piece
		btst	#$02,d4					; is white noise set?
		bne.s	ST_WhiteNoise				; if so, branch
		bsr.w	ST_DrawPiece				; "WHITE"
		bsr.w	ST_DrawPiece_On				; "PERIODIC"
		bra.s	ST_PeriodicNoise			; continue

ST_WhiteNoise:
		bsr.w	ST_DrawPiece_On				; "WHITE"
		bsr.w	ST_DrawPiece				; "PERIODIC"

ST_PeriodicNoise:
		addq.w	#$02,a0					; advance to noise type
		addq.w	#$02,a1					; ''
		moveq	#$04-1,d2				; set width of piece
		andi.w	#$0003,d4				; get only the frequency type
		lsl.b	#$04,d4					; multiply by 10
		jsr	ST_FrequList(pc,d4.w)			; run correct display list
		bra.s	ST_FinishPSG4				; continue

ST_FrequList:
		bsr.w	ST_DrawPiece				; "LOW"
		bsr.w	ST_DrawPiece				; "MID"
		bsr.w	ST_DrawPiece_On				; "HIGH"
		bra.w	ST_DrawPiece				; "PSG3"

		bsr.w	ST_DrawPiece				; "LOW"
		bsr.w	ST_DrawPiece_On				; "MID"
		bsr.w	ST_DrawPiece				; "HIGH"
		bra.w	ST_DrawPiece				; "PSG3"

		bsr.w	ST_DrawPiece_On				; "LOW"
		bsr.w	ST_DrawPiece				; "MID"
		bsr.w	ST_DrawPiece				; "HIGH"
		bra.w	ST_DrawPiece				; "PSG3"

		bsr.w	ST_DrawPiece				; "LOW"
		bsr.w	ST_DrawPiece				; "MID"
		bsr.w	ST_DrawPiece				; "HIGH"
		bra.w	ST_DrawPiece_On				; "PSG3"

ST_FinishPSG4:
		addq.w	#$01,a3					; skip passed PSG 4 flag

ST_CheckFM6:

	; --- FM 6 ---

		tst.b	mFM6.w					; check if FM 6 is enabled
		spl	d0					; if disabled, set d0, else clear it
		bpl.s	ST_HandleState				; if not enabled, branch

		move.b	mDAC2.w,d1				; check if DAC 2 is enabled
		or.b	mDAC1.w,d1				; or DAC 1
		or.b	mSFXDAC1.w,d1				; or SFX DAC 1
		bpl.s	ST_HandleState				; branch if not

	stopZ80
		move.b	dZ80+StatusDAC,d0			; load DAC status to d0
	startZ80
		tst.b	d0					; check if both are off
		sne	d0					; either 00 or FF

ST_HandleState:
		cmp.b	($FFFF900F).w,d0			; check if the last value was the same
		beq.s	ST_SkipRedraw				; branch if so
		move.b	d0,($FFFF900F).w

		bset.b	#$00,($FFFFA000).w			; set plane redraw flag
		move.l	a3,a1					; copy current address to a1
		tst.b	d0					; check if we need to redraw DAC 1
		beq.s	ST_DoRedraw				; do it nao
		lea	($FFFF9005).w,a1			; redraw DAC 1 instead

ST_DoRedraw:
		addq.b	#1,(a1)					; force channel to reload

ST_SkipRedraw:
		tst.b	d0					; just check whether to draw FM6
		bne.s	ST_NoRedraw				; if not, then skip

		lea	(ST_BGMFM6).l,a4			; load channel RAM list
		lea	($FFFF6FA2).l,a0			; load piano mappings
		lea	($FFFF8502).w,a1			; load plane buffer

		move.w	#$0140,d5				; load ON mappings address advancement
		moveq	#$02-1,d6				; set number of rows to render per piano
		moveq	#$01-1,d7				; do only 1 channel
		bsr.s	ST_DrawChannels				; ''
		rts						; return

ST_NoRedraw:
		addq.b	#$01,(a3)				; keep low bit set so it registers as "changed" when stopped
		rts						; return

; ---------------------------------------------------------------------------
; Checking normal channels
; ---------------------------------------------------------------------------

ST_DrawChannels:
		movea.w	(a4),a2					; load channel
		btst	#cfbInt,(a2)				; is the channel being interrupted by SFX?
		bne.s	ST_CheckSFX				; if so, branch
;	move.b	$21(a2),d0			; is the channel muted?
;	not.b	d0
;	tst.b	d0
;	bpl.s	ST_Mute				; if so, branch
		bra.s	ST_NoSPE

ST_CheckSFX:
		move.w	ST_SFXRAM-ST_BGMRAM(a4),d0		; load SFX channel
		beq.s	ST_NoChannel				; if there is no SFX channel, branch
		movea.w	d0,a2					; set address

ST_NoSPE:
		move.b	(a2),d0					; load channel status

ST_Mute:
		andi.b	#1<<cfbRun,d0				; get only running flag
		cmp.b	(a3),d0					; has the channel's status changed?
		beq.s	ST_NoChannel				; no change...
		bset.b	#$00,($FFFFA000).w			; set plane redraw flag

		cmp.b	#ctDAC1,cType(a2)			; check for DAC1
		bne.s	ST_NoOverride				; if not, branch
		addq.b	#2,($FFFF900F).w			; force FM6/PCM1 toggle to update

ST_NoOverride:
		movem.l	a0-a1,-(sp)				; store registers
		move.w	d6,d1					; set number of rows to do
		move.b	d0,(a3)					; update status
		bpl.s	ST_PianoOff				; if turned off, branch
		adda.w	d5,a0					; load ON mappings

ST_PianoOff:
		bsr.s	ST_DrawPiano				; draw piano
		movem.l	(sp)+,a0-a1				; restore registers

ST_NoChannel:
		lea	$50*2(a0),a0				; advance to next source mappings
		lea	$80*2(a1),a1				; advance to next destination plane
		addq.w	#$01,a3					; advance to next status storage
		addq.w	#$02,a4					; advance to next channel
		dbf	d7,ST_DrawChannels			; repeat for all channels
		rts						; return

ST_DrawPiano:
		move.l	(a0)+,(a1)+				; copy mappings
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		move.l	(a0)+,(a1)+				; ''
		addq.w	#$04,a0					; advance to next source mappings
		lea	$80-($26*2)(a1),a1			; advance to next plane row
		dbf	d1,ST_DrawPiano				; repeat for both rows
		rts						; return

; ---------------------------------------------------------------------------
; Subroutine to draw a PSG 4 piece
; ---------------------------------------------------------------------------

ST_DrawPiece_On:
		movem.l	a0-a1,-(sp)				; store registers
		adda.w	#$1B*$50,a0				; advance to "ON" graphics
		bra.s	STDP_Start				; continue

ST_DrawPiece:
		movem.l	a0-a1,-(sp)				; store registers

STDP_Start:
		moveq	#$01,d0					; set height

STDP_NextColumn:
		movem.l	a0-a1,-(sp)				; store registers
		move.w	d2,d1					; load width

STDP_NextRow:
		move.w	(a0)+,(a1)+
		dbf	d1,STDP_NextRow				; repeat for width
		movem.l	(sp)+,a0-a1				; restore registers
		lea	$50(a0),a0				; advance to next source mappings
		lea	$80(a1),a1				; advance to next destination plane
		dbf	d0,STDP_NextColumn			; repeat for height
		movem.l	(sp)+,a0-a1				; restore registers
		move.w	d2,d1					; advance mapping address to end
		addq.w	#$01,d1					; increase by 1 (due to dbf)
		add.w	d1,d1					; ''
		adda.w	d1,a0					; ''
		adda.w	d1,a1					; ''
		rts						; return

; ---------------------------------------------------------------------------
; Channel RAM list
; ---------------------------------------------------------------------------

ST_BGMRAM:	dc.w mFM1, mFM2, mFM3, mFM4, mFM5		; FM
		dc.w mDAC1, mDAC2				; DAC
		dc.w mPSG1, mPSG2, mPSG3			; PSG

ST_BGMFM6:
	if FEATURE_FM6
		dc.w mFM6					; FM 6
	else
		dc.w $0000					; FM 6
	endif

ST_SFXRAM:	dc.w $0000, $0000, mSFXFM3, mSFXFM4, mSFXFM5	; SFX FM
		dc.w mSFXDAC1, $0000				; SFX DAC
		dc.w mSFXPSG1, mSFXPSG2, mSFXPSG3		; SFX PSG
		dc.w $0000					; FM 6

; ===========================================================================
; ---------------------------------------------------------------------------
; V-blank - Sound Test (Text bar at bottom)
; ---------------------------------------------------------------------------

HB_SoundTest:
		move.w	#$8A00|$00,($C00004).l			; set new interrupt line occurance amount
		move.l	#$FFFF5D00,(HBlankRout).w		; set H-blank routine
		move.b	#$28-1,($FFFF5FFF).l			; set counter
		rte						; return

	; --- Copied to RAM 5C00

HBST_FontBar:
		move.l	#$40000010,($C00004).l			; set VDP to VSRAM write mode
HBST_FontPos:	move.l	($FFFF5E00).l,($C00000).l		; change V-scroll position
		addq.w	#$04,((HBST_FontPos-HBST_FontBar)+$FFFF5D00)+$04
		subq.b	#$01,($FFFF5FFF).l			; decrease counter
		bpl.s	HBST_NoFinish				; if not finished, branch
		move.w	#$8A00|$DF,($C00004).l			; revert align amount
		move.l	#NullBlank,(HBlankRout).w		; set H-blank routine

NullBlank:
HBST_NoFinish:
		rte						; return
HBST_FontBar_End:

; ===========================================================================
; ---------------------------------------------------------------------------
; V-blank - Sound Test (Normal)
; ---------------------------------------------------------------------------

VB_SoundTest:
		movem.l	d7/a0-a1,-(sp)				; store registers
		lea	(HBST_FontBar).l,a0
		lea	($FFFF5D00).l,a1

		rept	(HBST_FontBar_End-HBST_FontBar)/$04
		move.l	(a0)+,(a1)+
		endr

		movem.l	(sp)+,d7/a0-a1				; restore registers
		move.w	#$8A00|($B7/$02),($C00004).l		; set interrupt line address
		move.l	#HB_SoundTest,(HBlankRout).w		; set H-blank routine

VB_SoundTest_NoHB:
		movem.l	d0-a6,-(sp)				; store register data
		tst.b	($FFFFF62A).w				; was the 68k late?
		beq.w	VBST_68kLate				; if so, branch
		lea	($C00000).l,a5				; load VDP data port
		lea	$04(a5),a6				; load VDP control port
		subq.b	#$01,($FFFFA001).w			; decrease postpone draw timer
		bpl.s	VBST_NoDrawPlane			; if it's still running, branch
		sf.b	($FFFFA001).w				; keep at 0
		bclr.b	#$00,($FFFFA000).w			; clear plane drawn flag
		beq.s	VBST_NoDrawPlane			; if it was already clear, branch (no drawing required)
		DMA	$0B00, $FFFF8000, $60800003		; background plane

VBST_NoDrawPlane:
		DMA	$0080, $FFFFFB00, $C0000000		; palette
		DMA	$0280, $FFFFF800, $78000003		; sprites
		DMA	$0380, $FFFFCC00, $7C000003		; h-scroll
		move.l	#$40000010,(a6)				; v-scroll
		move.l	($FFFFF616).w,(a5)			; ''
		jsr	ReadJoypads				; read the controller pads

VBST_68kLate:
		sf.b	($FFFFF62A).w				; clear V-blank flag
		move.w	#$2300,sr				; enable interrupts
		jsr	UpdateAMPS				; run sound driver
		movem.l	(sp)+,d0-a6				; restore register data
		rtr						; return and restore ccr (does not affect sr)

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to clear a section of VDP memory using DMA fill
; ---------------------------------------------------------------------------
;		move.l	#$40000080,d0				; VDP mode/address
;		move.w	#$0400,d1				; size to clear
;		jsr	(ClearVDP).w				; clear VDP memory section
; ---------------------------------------------------------------------------

ClearVDP:
		move.w	#$8F01,(a6)				; set increment mode to 1
		move.l	#$97809300,d2				; prepare size register data
		subq.w	#$01,d1					; decrease size by 1
		move.b	d1,d2					; get low byte
		move.l	d2,(a6)					; set DMA source & DMA size low byte
		lsr.w	#$08,d1					; get high byte
		ori.w	#$9400,d1				; load size register
		move.w	d1,(a6)					; set DMA size high byte
		move.l	d0,(a6)					; set DMA destination
		move.w	#$0000,(a5)				; fill location with 0000
		nop						; delay

CVD_Wait:
		move.w	(a6),ccr				; load status (this resets the 2nd write flag too)
		bvs.s	CVD_Wait				; if the VDP DMA busy flag was set (bit 1), branch to wait til finished...
		move.w	#$8F02,(a6)				; set increment mode to normal
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to write mapping tiles correctly to a plane
; --- Inputs ----------------------------------------------------------------
; d3.l = Line advance value
; d0.l = VRAM address of plane to write to
; d1.w = X size
; d2.w = Y size
; ---------------------------------------------------------------------------

MapScreen:
		move.l	#$00800000,d3				; prepare line advance amount

MapRow:
		move.l	d0,(a6)					; set VDP to VRAM write mode
		add.l	d3,d0					; advance to next line
		move.w	d1,d4					; load X size

MapColumn:
		move.w	(a1)+,(a5)				; copy tile mappings over
		dbf	d4,MapColumn				; repeat until all done
		dbf	d2,MapRow				; repeat for all rows
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Data includes
; ---------------------------------------------------------------------------

Pal_Sound:	incbin	"Data\Pal Piano.bin"
		dc.w	$0000,$000E,$0008,$000E,$0008,$000E,$0008,$000E
		dc.w	$0008,$000E,$0008,$000E,$0008,$0E84,$0800,$0000
		dc.w	$0000,$0E00,$0800,$0E00,$0800,$00E0,$0080,$00E0
		dc.w	$0080,$00E0,$0080,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
Pal_Sound_End:	even

Art_Piano:	incbin	"Data\Art Piano.unc"
		even
Map_Piano:	incbin	"Data\Map Piano.unc"
		even

Art_Keys:	incbin	"Data\Art Keys.unc"
		even

Art_Font:	incbin	"Data\Art Font.unc"
		even
Map_Font:	incbin	"Data\Map Font.bin"
		even

Art_Extras:	incbin	"Data\Art Extras.unc"
		even

Art_End:
; ===========================================================================


