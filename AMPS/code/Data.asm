; ===========================================================================
; ---------------------------------------------------------------------------
; Flags section. None of this is required, but I added it here to
; make it easier to debug built ROMs! If you would like easier
; assistance from Aurora, please keep this section intact!
; ---------------------------------------------------------------------------
	dc.b "AMPS-v2.1"		; ident str

	if safe
		dc.b "s"		; safe mode enabled

	else
		dc.b " "		; safe mode disabled
	endif

	if FEATURE_FM6
		dc.b "F6"		; FM6 enabled
	endif

	if FEATURE_SFX_MASTERVOL
		dc.b "SM"		; sfx ignore master volume
	endif

	if FEATURE_UNDERWATER
		dc.b "UW"		; underwater mode enabled
	endif

	if FEATURE_MODULATION
		dc.b "MO"		; modulation enabled
	endif

	if FEATURE_DACFMVOLENV
		dc.b "VE"		; FM & DAC volume envelope enabled
	endif

	if FEATURE_MODENV
		dc.b "ME"		; modulation envelope enabled
	endif

	if FEATURE_PORTAMENTO
		dc.b "PM"		; portamento enabled
	endif

	if FEATURE_BACKUP
		dc.b "BA"		; backup enabled
	endif

	if FEATURE_SOUNDTEST
		dc.b "ST"		; soundtest enabled
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Define music and SFX
; ---------------------------------------------------------------------------

	opt oz-				; disable zero-offset optimization
	if safe=0
		nolist			; if in safe mode, list data section.
	endif

__mus =		MusOff

MusicIndex:
	ptrMusic Test, $00
	ptrMusic Pelimusa, $20, MysticCave, $20, DIS, $20, ZaxxRemix, $20
	ptrMusic ColumnDive, $20, Pray, $20, HydroCity, $20, GameNo, $20
	ptrMusic TowerPuppet, $20, ChoosePath, $20, Shop, $20, Beach, $20
	ptrMusic SmoothCriminal, $20, S82, $20

MusCount =	__mus-MusOff		; number of installed music tracks
SFXoff =	__mus			; first SFX ID
__sfx =		SFXoff
; ---------------------------------------------------------------------------

SoundIndex:
	ptrSFX	$01, RingRight
	ptrSFX	0, RingLeft

SFXcount =	__sfx-SFXoff		; number of intalled sound effects
SFXlast =	__sfx
; ===========================================================================
; ---------------------------------------------------------------------------
; Define samples
; ---------------------------------------------------------------------------

__samp =	$80
SampleList:
	sample $0000, Stop, Stop		; 80 - Stop sample (DO NOT EDIT)
	sample $0100, Kick, Stop		; 81 - Kick
	sample $0100, LowKick, Stop		; 82 - Low Kick
	sample $0100, Snare, Stop		; 83 - Snare
	sample $00E0, Snare, Stop, LowSnare	; 84 - Low Snare
	sample $0100, Clap, Stop		; 85 - Clap
	sample $0180, Tom, Stop, HiTom		; 86 - High Tom
	sample $0100, Tom, Stop			; 87 - Mid Tom
	sample $00C0, Tom, Stop, LowTom		; 88 - Low Tom
	sample $0080, Tom, Stop, FloorTom	; 89 - Floor Tom

	sample $0100, OrchHit, Stop		; 8A - Orchestra hit (Dynamite Headdy)
	sample $0100, ZaxxOOH, Stop		; 8B - OOH 0-4 (Zaxxon Motherbase 2000)
	sample $0080, ZaxxOOH, Stop, ZaxxLoOOH	; 8C - OOH Low 0-6 (Zaxxon Motherbase 2000)
	sample $0100, ZaxxGO, Stop		; 8D - GO 0-5 (Zaxxon Motherbase 2000)
	sample $0100, ZaxxDIS, Stop		; 8E - DIS 2-3 (Zaxxon Motherbase 2000)
	sample $0100, ZaxxIT, Stop		; 8F - IT 2-9 (Zaxxon Motherbase 2000)
	sample $0100, ZaxxEYO, Stop		; 90 - EYO 2-A (Zaxxon Motherbase 2000)

	sample $0100, KcTom, Stop		; 91 - Tom (Knuckles Chaotix)
	sample $00C0, KcTom, Stop, KcLowTom	; 92 - Low Tom (Knuckles Chaotix)
	sample $0080, KcTom, Stop, KcFloorTom	; 93 - Floor Tom (Knuckles Chaotix)
	sample $0100, kcCymbal, Stop		; 94 - Cymbal? (Knuckles Chaotix)
	sample $0100, KcSnare, Stop		; 95 - Snare (Knuckles Chaotix)
	sample $0100, KcTamb, Stop		; 96 - Tambourine? (Knuckles Chaotix)
	sample $0100, Kc87, Stop		; 97 - Not really sure? (Knuckles Chaotix)
	sample $0100, KcCrash, Stop		; 98 - Crash Cymbal (Knuckles Chaotix)

	sample $0100, Meow, Stop		; 99 - Meow (Meow Mix - Cyriak)
	sample $0100, Wooh, WoohLoop		; 9A - Wooh (The Amazing Atheist)
	sample $0100, Lazer, Stop		; 9B - Lazer (R2D2 bird)

	sample $0100, Kaiku1, Stop		; 9C - Kaiku (Wings - Pelimusa)
	sample $0100, Kaiku2, Stop		; 9D - Kaiku (Wings - Pelimusa)
	sample $0100, Kaiku3, Stop		; 9E - Kaiku (Wings - Pelimusa)
	sample $0100, Kaiku4, Stop		; 9F - Kaiku (Wings - Pelimusa)
	sample $0100, Kaiku5, Stop		; A0 - Kaiku (Wings - Pelimusa)
	sample $0100, KaikuL1, KaikuL2, KaikuL2	; A1 - Kaiku (Wings - Pelimusa)
	sample $0100, KaikuL1, KaikuL3, KaikuL3	; A2 - Kaiku (Wings - Pelimusa)
	sample $0100, Sarobasso, Stop		; A3 - Sarobasso (Wings - Pelimusa)
; ===========================================================================
; ---------------------------------------------------------------------------
; Define volume envelopes and their data
; ---------------------------------------------------------------------------

vNone =		$00
__venv =	$01

VolEnvs:
	volenv Ristar02, Ristar07, Ristar10, Ristar18, Ristar1D, GameNo01
	volenv S3K_02, S3K_01, S3K_08, S3K_0A, Phan3_05, Phan3_0A, Zaxx04
	volenv DyHe03, DyHe05, DyHe0A, Col3_02, Col3_03, Col3_05
	volenv WOI_0C, WOI_0D, Kc02, Kc05, Kc08, MoonWalker04
	volenv S2_02, S2_01, S2_0B
VolEnvs_End:
; ---------------------------------------------------------------------------

; Sonic 2 01
vdS2_01:	dc.b $00, $00, $00, $08, $08, $08, $10, $10
		dc.b $10, $18, $18, $18, $20, $20, $20, $28
		dc.b $28, $28, $30, $30, $30, $38, eHold

; Sonic 2 0B
vdS2_0B:	dc.b $20, $20, $20, $18, $18, $18, $10, $10
		dc.b $10, $08, $08, $08, $08, $08, $08, $08
		dc.b $10, $10, $10, $10, $10, $18, $18, $18
		dc.b $18, $18, $20, eHold

; Michael Jackson's Moonwalker 04
vdMoonWalker04:	dc.b $00, $00, $10, $18, $20, $20, $28, $28
		dc.b $28, $30, eHold

; Knuckles Chaotix 08
vdKc08:		dc.b $10, $08, $00, $00, $08, $08, $10, eHold

; Zaxxon Motherbase 04
vdZaxx04:	dc.b $10, $08, $00, $00, $08, $10, $10, $10
		dc.b $10, $10, $10, $10, $10, $10, $10, $10
		dc.b $10, $18, $18, $18, $20, $20, $20, $28, eHold

; World of Illusion 0C
vdWOI_0C:	dc.b $30, $28, $20, $18, $08, $08, $00, $00
		dc.b $00, $00, $00, $00, $00, $00, $08, $08
		dc.b $10, $10, $18, $18, $20, $20, eHold

; World of Illusion 0D
vdWOI_0D:	dc.b $20, $18, $10, $08, $00, $08, $08, $10
		dc.b $10, $18, $18, $20, $20, $28, $28, $30
		dc.b $30, $38, $38, eHold

; Phantasy Star III & Knuckles Chaotix 05
vdKc05:
vdPhan3_05:	dc.b $18, $00, $08, $08, $08, $10, $18, $20
		dc.b $20, $28, eHold

; Phantasy Star III 0A
vdPhan3_0A:	dc.b $08, $00, $00, $00, $00, $08, $08, $08
		dc.b $10, $10, $10, $18, $18, $18, $18, $20
		dc.b $20, $20, $28, $28, eHold

; Game no Kanzume Otokuyou 01
vdGameNo01:	dc.b $00, $08, $08, $08, $08, $08, $08, $08
		dc.b $08, $10, $10, $10, $10, $10, $10, $10
		dc.b $10, $18, $18, $18, $18, $18, $18, $18
		dc.b $18, $20, $20, $20, $20, $20, $20, $20
		dc.b $20, $28, $28, $28, $28, $28, $28, $28
		dc.b $28, $30, eHold

; Ristar 07
vdRistar07:	dc.b $18, $10, $08, $00, $00, $08, $08, $10, eHold

; Knuckles Chaotix 02
vdKc02:		dc.b $00, $00		; continue to volenv below

; Ristar & S2 & S3K & Columns III 02
vdS2_02:
vdCol3_02:
vdS3K_02:
vdRistar02:	dc.b $00, $10, $20, $30, $40, $7F, eStop

; Ristar 1D
vdRistar1D:	dc.b $00, $00, $00, $00, $08, $08, $08, $08
		dc.b $08, $10, $10, $18, $18, $20, $20, $20
		dc.b $20, $18, $18, $10, $10, $08, eHold

; Ristar 10 & S3K 08
vdS3K_08:
vdRistar10:	dc.b $00, $00, $00, $10, $18, $18, $20, $28
		dc.b $30, $38, $40, $48, $50, $48, $60, $68, eStop

; Ristar 18
vdRistar18:	dc.b $00, $18, $30, $48, eStop

; S3K 01
vdS3K_01:	dc.b $10, eStop

; S3K 0A
vdS3K_0A:	dc.b $08, $00, $00, $00, $00, $08, $08, $08
		dc.b $10, $10, $10, $18, $18, $18, $18, $20
		dc.b $20, $20, $28, $28, eHold

; Dynamite Headdy 03
vdDyHe03:	dc.b $00, $00, $08, $08, $18, $18, $20, $28, eStop

; Dynamite Headdy 05
vdDyHe05:	dc.b $20, $20, $20, $20, $18, $18, $18, $18
		dc.b $10, $10, $10, $10, $08, $08, $08, $08
		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $08, $08, $08, $08, $08, $08
		dc.b $08, $08, $08, $08, $08, $08, $08, $08
		dc.b $10, $10, $10, $10, $10, $10, $10, $10
		dc.b $18, $18, $18, $18, $18, $18, $18, $18
		dc.b $20, eStop

; Dynamite Headdy 0A
vdDyHe0A:	dc.b $38, $30, $30, $30, $28, $28, $28, $20
		dc.b $20, $18, $18, $18, $18, $18, $10, $10
		dc.b $10, $08, $08, $08, $00, $00, $00, $00
		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $08, $08, $08, $08, $08, $08
		dc.b $08, $08, $08, $08, $08, $08, $08, $08
		dc.b $08, $08, $08, $08, $08, $08, $10, $10
		dc.b $10, $10, $10, $10, $18, $18, $18, $18
		dc.b $20, $20, $20, $20, $20, $28, $28, $28
		dc.b $28, $28, $30, $30, $30, $30, $30, $38
		dc.b $38, $38, $38, $38, $40, $40, $40, $40
		dc.b $40, $48, $48, $48, $48, $48, eHold

; Columns III 03
vdCol3_03:	dc.b $10, $08, $00, $00, $08, $10, $10, $10
		dc.b $10, $10, $10, $10, $10, $10, $10, $10
		dc.b $10, $18, $18, $18, $20, $20, $20, $28, eHold

; Columns III 05
vdCol3_05:	dc.b $10, $08, $00, $00, $08, $10, $10, $10
		dc.b $10, $10, $10, $10, $10, $10, $10, $10
		dc.b $10, $18, $18, $18, $20, $20, $20, $28, eStop
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Define modulation envelopes and their data
; ---------------------------------------------------------------------------

mNone =		$00
__menv =	$01

ModEnvs:
	modenv Test, PeliBell, PeliBell2
ModEnvs_End:
; ---------------------------------------------------------------------------

	if FEATURE_MODENV
; just testin'
mdTest:		dc.b  $08, eaSens, $01, eLoop, $00

; bell for Pelimusa
mdPeliBell:	dc.b  $00, $00, $02, $02, $02, $02
		dc.b  $00,-$02,-$02,-$02, $00, $00, eHold

mdPeliBell2:	dc.b  $00, $00, $00, $01, $01, $00
		dc.b  $00,-$01,-$01,-$00, $00, $00, eReset
		even
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Include music, sound effects and voice bank
; ---------------------------------------------------------------------------

	include "AMPS/Voices.s2a"	; include universal voice bank
	opt ae-				; disable automatic evens

sfxaddr	incSFX				; include all sfx
musaddr	incMus				; include all music
musend
	even

dSoundNames:
	allnames			; include all sound names in an array
; ===========================================================================
; ---------------------------------------------------------------------------
; Include samples and filters
; ---------------------------------------------------------------------------

		align	$8000		; must be aligned to bank. By the way, these are also used in Z80.asm. Be sure to check it out
fLog:		incbin "AMPS/filters/Logarithmic.dat"	; logarithmic filter (no filter)
;fLinear:	incbin "AMPS/filters/Linear.dat"	; linear filter (no filter)

dacaddr		dcb.b Z80E_Read*(MaxPitch/$100),$00
SWF_Stop:	dcb.b $8000-(2*Z80E_Read*(MaxPitch/$100)),$80
SWFR_Stop:	dcb.b Z80E_Read*(MaxPitch/$100),$00
; ---------------------------------------------------------------------------

	incSWF	Kick, LowKick, Snare, Clap, Tom, Wooh, WoohLoop
	incSWF	OrchHit, ZaxxOOH, ZaxxDIS, ZaxxEYO, ZaxxIT, ZaxxGO
	incSWF	KcTom, KcSnare, KcTamb, Kc87, KcCrash, KcCymbal
	incSWF	KaikuL1, KaikuL2, KaikuL3, Kaiku1, Kaiku2, Kaiku3, Kaiku4, Kaiku5
	incSWF	Meow, Lazer, Sarobasso
	even
	opt ae+				; enable automatic evens
	list				; continue source listing
; ===========================================================================
