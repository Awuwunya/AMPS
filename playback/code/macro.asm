	opt ae+		; automatic even's
	opt l+		; . is local lable symbol
	opt w-		; don't print warnings
	opt oz+		; optimize zero displacements

; ===========================================================================
align macro
	if narg>=2
		cnop \2,\1
	else
		cnop 0,\1
	endif
	endm

; ===========================================================================
vdpComm		macro ins,addr,type,rwd,end,end2
	if narg=5
		\ins #(((\type&\rwd)&3)<<30)|((\addr&$3FFF)<<16)|(((\type&\rwd)&$FC)<<2)|((\addr&$C000)>>14), \end

	elseif narg=6
		\ins #(((((\type&\rwd)&3)<<30)|((\addr&$3FFF)<<16)|(((\type&\rwd)&$FC)<<2)|((\addr&$C000)>>14))\end, \end2

	else
		\ins (((\type&\rwd)&3)<<30)|((\addr&$3FFF)<<16)|(((\type&\rwd)&$FC)<<2)|((\addr&$C000)>>14)
	endif
    endm

vdpCoord	macro x,y,rwd
	vdpComm move.l,($C000+(\x*2)+(\y*$80)),VRAM,\rwd,(a6)
    endm

; ===========================================================================
; values for the type argument
VRAM =  %100001
CRAM =  %101011
VSRAM = %100101

; values for the rwd argument
READ =  %001100
WRITE = %000111
DMA =   %100111

; ===========================================================================
; tells the VDP to copy a region of 68k memory to VRAM or CRAM or VSRAM
dma68kToVDP macro source,dest,length,type
		move.l	#(($9400|((((length)>>1)&$FF00)>>8))<<16)|($9300|(((length)>>1)&$FF)),(a6)
		move.l	#(($9600|((((source)>>1)&$FF00)>>8))<<16)|($9500|(((source)>>1)&$FF)),(a6)
		move.w	#$9700|(((((source)>>1)&$FF0000)>>16)&$7F),(a6)
	vdpComm	move.l,\dest,\type,DMA,(a6)
    endm

; ===========================================================================
; tells the VDP to fill a region of VRAM with a certain byte
dmaFillVRAM macro byte,addr,length,wait
	move.w	#$8F01,(a6) ; VRAM pointer increment: $0001
	move.l	#(($9400|((((length)-1)&$FF00)>>8))<<16)|($9300|(((length)-1)&$FF)),(a6) ; DMA length ...
	move.w	#$9780,(a6) ; VRAM fill
	move.l	#$40000080|(((addr)&$3FFF)<<16)|(((addr)&$C000)>>14),(a6) ; Start at ...
	move.w	#(byte)<<8,(a5) ; Fill with byte

	if narg<4
.loop\@		move.w	(a5),d1
		btst	#1,d1
		bne.s	.loop\@	; busy loop until the VDP is finished filling...
		move.w	#$8F02,(a5) ; VRAM pointer increment: $0002
	endif
    endm

; ===========================================================================
; allows you to declare string to be converted to character map or mappings
asc2	macro	or, str
	dc.W strlen(\str)-1
	asc	\or, \str
    endm

asc	macro	or, str
.lc = 0
	rept strlen(\str)
.cc		substr .lc+1,.lc+1,\str

		if '\.cc'=' '
			dc.\0 0|or			; whitespace

		elseif ('\.cc'>='0')&('\.cc'<='9')
			dc.\0 ('\.cc'-'0'+1)|or		; 0-9

		elseif ('\.cc'>='a')&('\.cc'<='z')
			dc.\0 ('\.cc'-'a'+$2B)|or	; a-z

		elseif ('\.cc'>='A')&('\.cc'<='Z')
			dc.\0 ('\.cc'-'A'+$B)|or	; A-Z

		elseif '\.cc'='!'
			dc.\0 $25|or	; !

		elseif '\.cc'='?'
			dc.\0 $26|or	; ?

		elseif '\.cc'='.'
			dc.\0 $27|or	; .

		elseif '\.cc'=','
			dc.\0 $28|or	; ,

		elseif '\.cc'=':'
			dc.\0 $29|or	; :

		elseif '\.cc'=';'
			dc.\0 $2A|or	; ;

		elseif '\.cc'='^'
			dc.\0 $45|or	; ^

		elseif '\.cc'='/'
			dc.\0 $46|or	; /

		elseif '\.cc'='\\'
			dc.\0 $47|or	; \

		elseif '\.cc'='*'
			dc.\0 $48|or	; *

		elseif '\.cc'='-'
			dc.\0 $49|or	; -

		elseif '\.cc'='|'
			dc.\0 $4A|or	; _ (wider)

		elseif '\.cc'='$'
			dc.\0 $4B|or	; $

		elseif '\.cc'='%'
			dc.\0 $4C|or	; %

		elseif '\.cc'='#'
			dc.\0 $4D|or	; #

		elseif '\.cc'='+'
			dc.\0 $4E|or	; +

		elseif '\.cc'='}'
			dc.\0 $4F|or	; ->

		elseif '\.cc'='{'
			dc.\0 $50|or	; <-

		elseif '\.cc'='@'
			dc.\0 $51|or	; @

		elseif '\.cc'='_'
			dc.\0 $52|or	; _

		elseif '\.cc'='('
			dc.\0 $53|or	; (

		elseif '\.cc'=')'
			dc.\0 $54|or	; )

		elseif '\.cc'='['
			dc.\0 $55|or	; [

		elseif '\.cc'=']'
			dc.\0 $56|or	; ]

		elseif '\.cc'='>'
			dc.\0 $57|or	; >

		elseif '\.cc'='<'
			dc.\0 $58|or	; <

		elseif '\.cc'='&'
			dc.\0 $59|or	; &

		elseif '\.cc'='~'
			dc.\0 $5A|or	; ~

		elseif '\.cc'="'"
			dc.\0 $5B|or	; '

		elseif '\.cc'='"'
			dc.\0 $5C|or	; "

		elseif '\.cc'='='
			dc.\0 $5D|or	; =

		elseif '\.cc'='`'
			dc.\0 $5E|or	; `

		else
			inform 2,"ASCII value failure: \.cc %d", .cc
		endif

.lc =		.lc+1
	endr
    endm

; ===========================================================================
; Z80 addresses
Z80_RAM =			$A00000 ; start of Z80 RAM
Z80_RAM_end =			$A02000 ; end of non-reserved Z80 RAM
Z80_bus_request =		$A11100
Z80_reset =			$A11200

SRAM_access =			$A130F1
Security_addr =			$A14000
; ===========================================================================
; I/O Area
HW_Version =			$A10001
HW_Port_1_Data =		$A10003
HW_Port_2_Data =		$A10005
HW_Expansion_Data =		$A10007
HW_Port_1_Control =		$A10009
HW_Port_2_Control =		$A1000B
HW_Expansion_Control =		$A1000D
HW_Port_1_TxData =		$A1000F
HW_Port_1_RxData =		$A10011
HW_Port_1_SCtrl =		$A10013
HW_Port_2_TxData =		$A10015
HW_Port_2_RxData =		$A10017
HW_Port_2_SCtrl =		$A10019
HW_Expansion_TxData =		$A1001B
HW_Expansion_RxData =		$A1001D
HW_Expansion_SCtrl =		$A1001F

; ===========================================================================
; VDP addresses
VDP_data_port =			$C00000
VDP_control_port =		$C00004
PSG_input =			$C00011

; ===========================================================================
; Mega-EverDrive
MED_USB_IO =	$A130E2
MED_USB_STAT =	$A130E4
MED_MAP_CTRL =	$A130F0

; ===========================================================================
	rsset $FFFF0000
Buffer		rs.b $8100	; general purpose buffers
Drvmem		rs.b $700	; sound driver memroy
		rs.b $100	; stack data
Stack		rs.w 0		; stack start
Palette		rs.w $40	; palette
DMAlen		rs.w 1		; dma length
Frame		rs.w 1		; current frame
Ctrl1Hold	rs.b 1		; controller 1 held buttons
Ctrl1Press	rs.b 1		; controller 1 pressed buttons
Ctrl2Hold	rs.b 1		; controller 2 held buttons
Ctrl2Press	rs.b 1		; controller 2 pressed buttons
MusSel		rs.b 1		; selected music
MusPlay		rs.b 1		; music currently playing
ConsoleRegion	rs.b 1		; system region
; ===========================================================================
