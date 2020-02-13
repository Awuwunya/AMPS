; REGISTER USAGE:
;   a0 - Dual PCM cue
;   a1 - Current channel
;   a2 - Tracker
;   a3 - Special address (channels), target channel (playsnd), scratch
;   a4 - Music channel (dcStop), other various uses, scratch
;   a5-a6 - Scratch, use lower number when possible
;   d0 - Channel dbf counter, other dbf counters
;   d1 - Various things read from the tracker, scratch
;   d2 - Volume or pitch when calculating it
;   d3-d6 - Scatch, use lower number when possible
;   d7 - Never used for anything.
; ===========================================================================
; ---------------------------------------------------------------------------
; Various assembly flags
; ---------------------------------------------------------------------------
	opt ae+

FEATURE_SAFE_PSGFREQ =	1	; set to 1 to enable safety checks for PSG frequency. Some S3K SFX require this to be 0
FEATURE_SFX_MASTERVOL =	0	; set to 1 to make SFX use master volumes
FEATURE_MODULATION =	1	; set to 1 to enable software modulation effect
FEATURE_PORTAMENTO =	1	; set to 1 to enable portamento flag
FEATURE_MODENV =	1	; set to 1 to enable modulation envelopes
FEATURE_DACFMVOLENV =	1	; set to 1 to enable volume envelopes for FM & DAC channels.
FEATURE_UNDERWATER =	1	; set to 1 to enable underwater mode
FEATURE_BACKUP =	1	; set to 1 to enable back-up channels. Used for the 1-up SFX in Sonic 1, 2 and 3K...
FEATURE_BACKUPNOSFX =	1	; set to 1 to disable SFX while a song is backed up. Used for the 1-up SFX.
FEATURE_FM6 =		1	; set to 1 to enable FM6 to be used in music

; Select the tempo algorith.
; 0 = Overflow method.
; 1 = Counter method.

TEMPO_ALGORITHM =	0

; if safe mode is enabled (1), then the driver will attempt to find any issues.
; if Vladik's error debugger is installed, then the error will be displayed.
; else, the CPU is trapped.

safe =	1
; ===========================================================================
; ---------------------------------------------------------------------------
; Channel configuration
; ---------------------------------------------------------------------------

	rsset 0
cFlags		rs.b 1		; various channel flags, see below
cType		rs.b 1		; hardware type for the channel
cData		rs.l 1		; 68k tracker address for the channel
	if FEATURE_DACFMVOLENV=0
cEnvPos		rs.b 0		; volume envelope position. PSG only
	endif
cPanning	rs.b 1		; channel panning and LFO. FM and DAC only
cDetune		rs.b 1		; frequency detune (offset)
cPitch		rs.b 1		; pitch (transposition) offset
cVolume		rs.b 1		; channel volume
cTick		rs.b 1		; channel tick multiplier
	if FEATURE_DACFMVOLENV=0
cVolEnv		rs.b 0		; volume envelope ID. PSG only
	endif
cSample		rs.b 0		; channel sample ID, DAC only
cVoice		rs.b 1		; YM2612 voice ID. FM only
cDuration	rs.b 1		; current note duration
cLastDur	rs.b 1		; last note duration
cFreq		rs.w 1		; channel base frequency

	if FEATURE_MODULATION
cModDelay	rs.b 0		; delay before modulation starts
cMod		rs.l 1		; modulation data address
cModFreq	rs.w 1		; modulation frequency offset
cModSpeed	rs.b 1		; number of frames til next modulation step
cModStep	rs.b 1		; modulation frequency offset per step
cModCount	rs.b 1		; number of modulation steps until reversal
	endif

	if FEATURE_PORTAMENTO
cPortaSpeed	rs.b 1		; number of frames for each portamento to complete. 0 means it is disabled.
cPortaFreq	rs.w 1		; frequency offset for portamento.
cPortaDisp	rs.w 1		; frequency displacement per frame for portamento.
	endif

	if FEATURE_DACFMVOLENV
cVolEnv		rs.b 1		; volume envelope ID
cEnvPos		rs.b 1		; volume envelope position
	endif

	if FEATURE_MODENV
cModEnv		rs.b 1		; modulation envelope ID
cModEnvPos	rs.b 1		; modulation envelope position
cModEnvSens	rs.b 1		; sensitivity of modulation envelope
	endif

cLoop		rs.b 3		; loop counter values
cSizeSFX	rs.w 0		; size of each SFX track (this also sneakily makes sure the memory is aligned to word always. Additional loop counter may be added if last byte is odd byte)
cPrio =		__rs-1		; sound effect channel priority. SFX only

	if FEATURE_DACFMVOLENV
cStatPSG4 =	cPanning	; PSG4 type value. PSG3 only
	else
cStatPSG4 =	__rs-2		; PSG4 type value. PSG3 only
	endif

cGateCur	rs.b 1		; frame counter to note off. Music only
cGateMain	rs.b 1		; copy of frame counter to note off. Music only
cStack		rs.b 1		; channel stack pointer. Music only
		rs.b 1		; unused. Music only
		rs.l 3		; channel stack data. Music only
cSize		rs.w 0		; size of each music track
; ===========================================================================
; ---------------------------------------------------------------------------
; Bits for cFlags
; ---------------------------------------------------------------------------

	rsset 0
cfbMode		rs.b 0		; set if in pitch mode, clear if in sample mode. DAC only
cfbRest		rs.b 1		; set if channel is resting. FM and PSG only
cfbInt		rs.b 1		; set if interrupted by SFX. Music only
cfbHold		rs.b 1		; set if playing notes does not trigger note-on's
cfbMod		rs.b 1		; set if modulation is enabled
cfbCond		rs.b 1		; set if ignoring most tracker commands
cfbVol		rs.b 1		; set if channel should update volume
cfbRun =	$07		; set if channel is running a tracker
; ===========================================================================
; ---------------------------------------------------------------------------
; Misc variables for channel modes
; ---------------------------------------------------------------------------

ctbPt2 =	$02		; bit part 2 - FM 4-6
ctFM1 =		$00		; FM 1
ctFM2 =		$01		; FM 2
ctFM3 =		$02		; FM 3	- Valid for SFX
ctFM4 =		$04		; FM 4	- Valid for SFX
ctFM5 =		$05		; FM 5	- Valid for SFX
	if FEATURE_FM6
ctFM6 =		$06		; FM 6
	endif

ctbDAC =	$04		; DAC bit
ctDAC1 =	(1<<ctbDAC)|$03	; DAC 1	- Valid for SFX
ctDAC2 =	(1<<ctbDAC)|$06	; DAC 2

ctPSG1 =	$80		; PSG 1	- Valid for SFX
ctPSG2 =	$A0		; PSG 2	- Valid for SFX
ctPSG3 =	$C0		; PSG 3	- Valid for SFX
ctPSG4 =	$E0		; PSG 4
; ===========================================================================
; ---------------------------------------------------------------------------
; Misc flags
; ---------------------------------------------------------------------------

Mus_DAC =	2		; number of DAC channels
Mus_FM =	5+((FEATURE_FM6<>0)&1); number of FM channels (5 or 6)
Mus_PSG =	3		; number of PSG channels
Mus_Ch =	Mus_DAC+Mus_FM+Mus_PSG; total number of music channels
SFX_DAC =	1		; number of DAC SFX channels
SFX_FM =	3		; number of FM SFX channels
SFX_PSG =	3		; number of PSG SFX channels
SFX_Ch =	SFX_DAC+SFX_FM+SFX_PSG; total number of SFX channels

VoiceRegs =	29		; total number of registers inside of a voice
VoiceTL =	VoiceRegs-4	; location of voice TL levels

MaxPitch =	$1000		; this is the maximum pitch Dual PCM is capable of processing
Z80E_Read =	$00018		; this is used by Dual PCM internally but we need this for macros

; NOTE: There is no magic trick to making Dual PCM play samples at higher rates.
; These values are only here to allow you to give lower pitch samples higher
; quality, and playing samples at higher rates than Dual PCM can process them
; may decrease the perceived quality by the end user. Use these equates only
; if you know what you are doing.

sr17 =		$0140		; 5 Quarter sample rate	17500 Hz
sr15 =		$0120		; 9 Eights sample rate	15750 Hz
sr14 =		$0100		; Default sample rate	14000 Hz
sr12 =		$00E0		; 7 Eights sample rate	12250 Hz
sr10 =		$00C0		; 3 Quarter sample rate	10500 Hz
sr8 =		$00A0		; 5 Eights sample rate	8750 Hz
sr7 =		$0080		; Half sample rate	7000 HZ
sr5 =		$0060		; 3 Eights sample rate	5250 Hz
sr3 =		$0040		; 1 Quarter sample rate	3500 Hz
; ===========================================================================
; ---------------------------------------------------------------------------
; Sound driver RAM configuration
; ---------------------------------------------------------------------------

dZ80 =		$A00000		; quick reference to Z80 RAM
dPSG =		$C00011		; quick reference to PSG port

	rsset $FFFFF000		; Insert your RAM definition here!
mFlags		rs.b 1		; various driver flags, see below
mCtrPal		rs.b 1		; frame counter fo 50hz fix
mComm		rs.b 8		; communications bytes
mMasterVolFM	rs.b 0		; master volume for FM channels
mFadeAddr	rs.l 1		; fading program address
mTempoMain	rs.b 1		; music normal tempo
mTempoSpeed	rs.b 1		; music speed shoes tempo
mTempo		rs.b 1		; current tempo we are using right now
mTempoCur	rs.b 1		; tempo counter/accumulator
mQueue		rs.b 3		; sound queue
mMasterVolPSG	rs.b 1		; master volume for PSG channels
mVctMus		rs.l 1		; address of voice table for music
mMasterVolDAC	rs.b 1		; master volume for DAC channels
mSpindash	rs.b 1		; spindash rev counter
mContCtr	rs.b 1		; continous sfx loop counter
mContLast	rs.b 1		; last continous sfx played
mLastCue	rs.b 1		; last YM Cue the sound driver was accessing
		rs.w 0		; align channel data

mBackUpArea	rs.b 0		; this is where backup stuff starts
mDAC1		rs.b cSize	; DAC 1 data
mDAC2		rs.b cSize	; DAC 2 data
mFM1		rs.b cSize	; FM 1 data
mFM2		rs.b cSize	; FM 2 data
mFM3		rs.b cSize	; FM 3 data
mFM4		rs.b cSize	; FM 4 data
mFM5		rs.b cSize	; FM 5 data
	if FEATURE_FM6
mFM6		rs.b cSize	; FM 6 data
	endif
mPSG1		rs.b cSize	; PSG 1 data
mPSG2		rs.b cSize	; PSG 2 data
mPSG3		rs.b cSize	; PSG 3 data
mSFXDAC1	rs.b cSizeSFX	; SFX DAC 1 data
mSFXFM3		rs.b cSizeSFX	; SFX FM 3 data
mSFXFM4		rs.b cSizeSFX	; SFX FM 4 data
mSFXFM5		rs.b cSizeSFX	; SFX FM 5 data
mSFXPSG1	rs.b cSizeSFX	; SFX PSG 1 data
mSFXPSG2	rs.b cSizeSFX	; SFX PSG 2 data
mSFXPSG3	rs.b cSizeSFX	; SFX PSG 3 data
mChannelEnd	rs.w 0		; used to determine where channel RAM ends

	if FEATURE_BACKUP
mBackUpLoc	rs.b 0		; this is where backup stuff is loaded
mBackDAC1	rs.b cSize	; back-up DAC 1 data
mBackDAC2	rs.b cSize	; back-up DAC 2 data
mBackFM1	rs.b cSize	; back-up FM 1 data
mBackFM2	rs.b cSize	; back-up FM 2 data
mBackFM3	rs.b cSize	; back-up FM 3 data
mBackFM4	rs.b cSize	; back-up FM 4 data
mBackFM5	rs.b cSize	; back-up FM 5 data
	if FEATURE_FM6
mBackFM6	rs.b cSize	; back-up FM 6 data
	endif
mBackPSG1	rs.b cSize	; back-up PSG 1 data
mBackPSG2	rs.b cSize	; back-up PSG 2 data
mBackPSG3	rs.b cSize	; back-up PSG 3 data

mBackTempoMain	rs.b 1		; back-up music normal tempo
mBackTempoSpeed	rs.b 1		; back-up music speed shoes tempo
mBackTempo	rs.b 1		; back-up current tempo we are using right now
mBackTempoCur	rs.b 1		; back-up tempo counter/accumulator
mBackVctMus	rs.l 1		; back-up address of voice table for music
	endif

	if safe=1
msChktracker	rs.b 1		; safe mode only: If set, bring up debugger
	endif
mSize		rs.w 0		; end of the driver RAM
; ===========================================================================
; ---------------------------------------------------------------------------
; Bits for mFlags
; ---------------------------------------------------------------------------

	rsset 0
mfbSwap		rs.b 1		; if set, swap the sfx
mfbSpeed	rs.b 1		; if set, speed shoes are active
mfbWater	rs.b 1		; if set, underwater mode is active
mfbNoPAL	rs.b 1		; if set, play songs slowly in PAL region
mfbBacked	rs.b 1		; if set, a song has been backed up already
mfbExec		rs.b 1		; if set, AMPS is currently running
mfbPaused =	$07		; if set, sound driver is paused
; ===========================================================================
; ---------------------------------------------------------------------------
; Sound ID equates
; ---------------------------------------------------------------------------

	rsset 1
Mus_Reset	rs.b 1		; reset underwater and speed shoes flags, update volume
Mus_FadeOut	rs.b 1		; initialize a music fade out
Mus_Stop	rs.b 1		; stop all music
Mus_ShoesOn	rs.b 1		; enable speed shoes mode
Mus_ShoesOff	rs.b 1		; disable speed shoes mode
Mus_ToWater	rs.b 1		; enable underwater mode
Mus_OutWater	rs.b 1		; disable underwater mode
Mus_Pause	rs.b 1		; pause the music
Mus_Unpause	rs.b 1		; unpause the music
Mus_StopSFX	rs.b 1		; stop all sfx
MusOff		rs.b 0		; first music ID
; ===========================================================================
; ---------------------------------------------------------------------------
; Condition modes
; ---------------------------------------------------------------------------

	rsset 0
dcoT		rs.b 1		; condition T	; True
dcoF		rs.b 1		; condition F	; False
dcoHI		rs.b 1		; condition HI	; HIgher (unsigned)
dcoLS		rs.b 1		; condition LS	; Less or Same (unsigned)
dcoHS		rs.b 0		; condition HS	; Higher or Sane (unsigned)
dcoCC		rs.b 1		; condition CC	; Carry Clear (unsigned)
dcoLO		rs.b 0		; condition LO	; LOwer (unsigned)
dcoCS		rs.b 1		; condition CS	; Carry Set (unsigned)
dcoNE		rs.b 1		; condition NE	; Not Equal
dcoEQ		rs.b 1		; condition EQ	; EQual
dcoVC		rs.b 1		; condition VC	; oVerflow Clear (signed)
dcoVS		rs.b 1		; condition VS	; oVerflow Set (signed)
dcoPL		rs.b 1		; condition PL	; Positive (PLus)
dcoMI		rs.b 1		; condition MI	; Negamite (MInus)
dcoGE		rs.b 1		; condition GE	; Greater or Equal (signed)
dcoLT		rs.b 1		; condition LT	; Less Than (signed)
dcoGT		rs.b 1		; condition GT	; GreaTer (signed)
dcoLE		rs.b 1		; condition LE	; Less or Equal (signed)
; ===========================================================================
; ---------------------------------------------------------------------------
; Envelope commands equates
; ---------------------------------------------------------------------------

	rsset $80
eReset		rs.w 1		; 80 - Restart from position 0
eHold		rs.w 1		; 82 - Hold volume at current level
eLoop		rs.w 1		; 84 - Jump back/forwards according to next byte
eStop		rs.w 1		; 86 - Stop current note and envelope

; these next ones are only valid for modulation envelopes. These are ignored for volume envelopes.
esSens		rs.w 1		; 88 - Set the sensitivity of the modulation envelope
eaSens		rs.w 1		; 8A - Add to the sensitivity of the modulation envelope
eLast		rs.w 0		; safe mode equate
; ===========================================================================
; ---------------------------------------------------------------------------
; Fade out end commands
; ---------------------------------------------------------------------------

	rsset $80
fEnd		rs.l 1		; 80 - Do nothing
fStop		rs.l 1		; 84 - Stop all music
fResVol		rs.l 1		; 88 - Reset volume and update
fReset		rs.l 1		; 8C - Stop music playing and reset volume
fLast		rs.l 0		; safe mode equate
; ===========================================================================
; ---------------------------------------------------------------------------
; Enable multiple flags in target ea mode
; ---------------------------------------------------------------------------

mvbit		macro bits
	local res			; local variable to hold result in
res =	0

	rept narg-1			; repeat for all bits
res =		res|(1<<\bits)		; or the value of the bit
	shift
	endr

	if ("\0"<>"q")&("\0"<>"Q")	; check for moveq
		move.\0	#res,\bits	; save instruction
	else
		if res>$80		; fix for moveq bug
res =			res|$FFFFFF00	; must be negative value
		endif

		moveq	#res,\bits	; moveq version
	endif
    endm

mvnbt		macro bits
	local res			; local variable to hold result in
res =	0

	rept narg-1			; repeat for all bits
res =		res|(1<<\bits)		; or the value of the bit
	shift
	endr

	if ("\0"<>"q")&("\0"<>"Q")	; check for moveq
		move.\0	#~res,\bits	; save instruction
	else
res =		(~res)&$FF		; not result but keep it in 8bits

		if res>$80		; fix for moveq bug
res =			res|$FFFFFF00	; must be negative value
		endif

		moveq	#res,\bits	; moveq version
	endif
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Quickly clear some memory in certain block sizes
;
; input:
;   a4 - Destination address
;   len - Length of clear
;   block - Size of clear block
;
; thrashes:
;   d6 - Set to $0000FFFF
;   a4 - Destination address
; ---------------------------------------------------------------------------

dCLEAR_MEM	macro len, block
		move.w	#((\len)/(\block))-1,d6; load repeat count to d6
.c\@
	rept (\block)/4
		clr.l	(a4)+		; clear driver and music channel memory
	endr
		dbf	d6, .c\@	; loop for each longword to clear it...

	rept ((\len)%(\block))/4
		clr.l	(a4)+		; clear extra longs of memory
	endr

	if (\len)&2
		clr.w	(a4)+		; if there is an extra word, clear it too
	endif
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Quickly read a word from odd address. 28 cycles
; ---------------------------------------------------------------------------

dREAD_WORD	macro areg, dreg
	move.b	(\areg)+,(sp)		; read the next byte into stack
	move.w	(sp),\dreg		; get word back from stack (shift byte by 8 bits)
	move.b	(\areg)+,\dreg		; get the next byte into register
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; used to calculate the address of the right FM voice
;
; input:
;   d4 - Voice ID
;   a4 - Voice table address
; ---------------------------------------------------------------------------

dCALC_VOICE	macro off
	lsl.w	#5,d4			; multiply voice ID by $20
	if narg>0
		add.w	#\off,d4	; if have had extra argument, add it to offset
	endif

	add.w	d4,a4			; add offset to voice table address
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Used to calculate the address of the right FM voice bank
;
; input:
;   a1 - Channel address
; output:
;   a4 - Voice table address
; ---------------------------------------------------------------------------

dCALC_BANK	macro off
	lea	VoiceBank+off(pc),a4	; load sound effects voice table into a6
	cmp.w	#mSFXDAC1,a1		; check if this is a SFX channel
	bhs.s	.bank			; if so, branch
	move.l	mVctMus.w,a4		; load music voice table into a1

	if \off<>0
		add.w	#off,a4		; add offset into a1
	endif
.bank
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Tells the Z80 to stop, and waits for it to finish stopping (acquire bus)
; ---------------------------------------------------------------------------

stopZ80 	macro
	move.w	#$100,$A11100		; stop the Z80
.loop\@
	btst	#0,$A11100
	bne.s	.loop\@			; loop until it says it's stopped
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Tells the Z80 to start again
; ---------------------------------------------------------------------------

startZ80 	macro
	move.w	#0,$A11100		; start the Z80
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Initializes YM writes
;
; output:
;  d6 - part number
;  d5 - channel type
; ---------------------------------------------------------------------------

InitChYM	macro
	move.b	cType(a1),d6		; get channel type to d6
	move.b	d6,d5			; copy to d5
	and.b	#3,d5			; get only the important part
	lsr.b	#1,d6			; halve part value
	and.b	#2,d6			; clear extra bits away
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Write data to channel-specific YM part
;
; input:
;   d6 - part number
;   d5 - channel type
;   reg - YM register to write
;   value - value to write
;
; thrashes:
;   d4 - used for register calculation
; ---------------------------------------------------------------------------

WriteChYM	macro reg, value
	move.b	d6,(a0)+		; write part
	move.b	\value,(a0)+		; write register value to cue
	move.b	d5,d4			; get the channel offset into d4
	or.b	\reg,d4			; or the actual register value
	move.b	d4,(a0)+		; write register to cue
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Write data to YM part 1
; ---------------------------------------------------------------------------

WriteYM1	macro reg, value
	clr.b	(a0)+			; write to part 1
	move.b	\value,(a0)+		; write value to cue
	move.b	\reg,(a0)+		; write register to cue
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Write data to YM part 2
; ---------------------------------------------------------------------------

WriteYM2	macro reg, value
	move.b	#2,(a0)+		; write to part 2
	move.b	\value,(a0)+		; write value to cue
	move.b	\reg,(a0)+		; write register to cue
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro to check cue address
; ---------------------------------------------------------------------------

CheckCue	macro
	if safe=1
		AMPS_Debug_CuePtr Gen	; check if cue pointer is valid
	endif
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for pausing music
; ---------------------------------------------------------------------------

AMPS_MUSPAUSE	macro	; enable request pause and paused flags
	move.b	#Mus_Pause,mQueue+2.w
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for unpausing music
; ---------------------------------------------------------------------------

AMPS_MUSUNPAUSE	macro	; enable request unpause flag
	move.b	#Mus_Unpause,mQueue+2.w
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Create volume envelope table, and SMPS2ASM equates
; ---------------------------------------------------------------------------

volenv		macro name
	rept narg			; repeate for all arguments
v\name =	__venv			; create SMPS2ASM equate
		dc.l vd\name		; create pointer
__venv =	__venv+1		; increase ID
	shift				; shift next argument into view
	endr
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Create modulation envelope table, and SMPS2ASM equates
; ---------------------------------------------------------------------------

modenv		macro name
	rept narg			; repeate for all arguments
m\name =	__menv			; create SMPS2ASM equate

	if FEATURE_MODENV
		dc.l md\name		; create pointer
	endif

__menv =	__menv+1		; increase ID
	shift				; shift next argument into view
	endr
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Include PCM data
; ---------------------------------------------------------------------------

incSWF		macro file
	rept narg			; repeat for all arguments
SWF_\file	incbin	"AMPS/DAC/incswf/\file\.swf"; include PCM data
SWFR_\file 	dcb.b Z80E_Read*(MaxPitch/$100),$00; add end markers (for Dual PCM)
	shift				; shift next argument into view
	endr
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Create data for a sample
; ---------------------------------------------------------------------------

sample		macro freq, start, loop, name
	if narg=4			; if we have 4 arguments, we'd like a custom name
d\name =	__samp			; use the extra argument to create SMPS2ASM equate
	else
d\start =	__samp			; else, use the first one!
	endif

__samp =	__samp+1		; increase sample ID
; create offsets for the sample normal, reverse, loop normal, loop reverse.
	if strcmp("\start","Stop")|strcmp("\start","STOP")|strcmp("\start","stop")
		dcb.b 6, 0
	else
		dc.b SWF_\start&$FF,((SWF_\start>>$08)&$7F)|$80,(SWF_\start>>$0F)&$FF
		dc.b (SWFR_\start-1)&$FF,(((SWFR_\start-1)>>$08)&$7F)|$80,((SWFR_\start-1)>>$0F)&$FF
	endif

	if strcmp("\loop","Stop")|strcmp("\loop","STOP")|strcmp("\loop","stop")
		dcb.b 6, 0
	else
		dc.b SWF_\loop&$FF,((SWF_\loop>>$08)&$7F)|$80, (SWF_\loop>>$0F)&$FF
		dc.b (SWFR_\loop-1)&$FF,(((SWFR_\loop-1)>>$08)&$7F)|$80,((SWFR_\loop-1)>>$0F)&$FF
	endif

	dc.w \freq-$100			; sample frequency (actually offset, so we remove $100)
	dc.w 0				; unused!
    endm
; ===========================================================================
	opt ae-
