; ===========================================================================
; ---------------------------------------------------------------------------
; Flags section. None of this is required, but I added it here to
; make it easier to debug built ROMS! If you would like easier
; assistance from Natsumi, please keep this section intact!
; ---------------------------------------------------------------------------
	dc.b "AMPS-1.1  "		; ident str

	if FEATURE_MODULATION
		dc.b "MO"		; modulation enabled
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

; ===========================================================================
; ---------------------------------------------------------------------------
; Define music and SFX
; ---------------------------------------------------------------------------

	opt oz-				; disable zero-offset optimization
	if safe=0
		nolist			; if in safe mode, list data section.
	endif

__sfx =		SFXoff
__mus =		MusOff
SoundIndex:
	ptrSFX	0, RingRight, RingLeft

MusicIndex:
	ptrMusic Test, $00
	ptrMusic Pelimusa, $1A, MysticCave, $34, DIS, $1E, ZaxxRemix, $00
	ptrMusic ColumnDive, $3C, Pray, $0B, HydroCity, $1E, GameNo, $74
	ptrMusic TowerPuppet, $00, ChoosePath, $0E, Shop, $74, Beach, $32
	ptrMusic SmoothCriminal, $2A
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
	sample $0100, Clap, Stop		; 84 - Clap
	sample $0180, Tom, Stop, HiTom		; 85 - High Tom
	sample $0100, Tom, Stop			; 86 - Mid Tom
	sample $00C0, Tom, Stop, LowTom		; 87 - Low Tom
	sample $0080, Tom, Stop, FloorTom	; 88 - Floor Tom

	sample $0100, OrchHit, Stop		; 89 - Orchestra hit (Dynamite Headdy)
	sample $0100, ZaxxOOH, Stop		; 8A - OOH 0-4 (Zaxxon Motherbase 2000)
	sample $0080, ZaxxOOH, Stop, ZaxxLoOOH	; 8B - OOH Low 0-6 (Zaxxon Motherbase 2000)
	sample $0100, ZaxxGO, Stop		; 8C - GO 0-5 (Zaxxon Motherbase 2000)
	sample $0100, ZaxxDIS, Stop		; 8D - DIS 2-3 (Zaxxon Motherbase 2000)
	sample $0100, ZaxxIT, Stop		; 8E - IT 2-9 (Zaxxon Motherbase 2000)
	sample $0100, ZaxxEYO, Stop		; 8F - EYO 2-A (Zaxxon Motherbase 2000)

	sample $0100, KcTom, Stop		; 90 - Tom (Knuckles Chaotix)
	sample $00C0, KcTom, Stop, KcLowTom	; 91 - Low Tom (Knuckles Chaotix)
	sample $0080, KcTom, Stop, KcFloorTom	; 92 - Floor Tom (Knuckles Chaotix)
	sample $0100, kcCymbal, Stop		; 93 - Cymbal? (Knuckles Chaotix)
	sample $0100, KcSnare, Stop		; 94 - Snare (Knuckles Chaotix)
	sample $0100, KcTamb, Stop		; 95 - Tambourine? (Knuckles Chaotix)
	sample $0100, Kc87, Stop		; 96 - Not really sure? (Knuckles Chaotix)
	sample $0100, KcCrash, Stop		; 97 - Crash Cymbal (Knuckles Chaotix)

	sample $0100, Meow, Stop	; AVG	; 98 - Meow (Meow Mix - Cyriak)
	sample $0100, Wooh, WoohLoop	; AVG	; 99 - Wooh (The Amazing Atheist)
	sample $0100, Lazer, Stop	; AVG	; 9A - Lazer (R2D2 bird)

	sample $0100, Kaiku1, Stop		; 9B - Kaiku (Wings - Pelimusa)
	sample $0100, Kaiku2, Stop		; 9C - Kaiku (Wings - Pelimusa)
	sample $0100, Kaiku3, Stop		; 9D - Kaiku (Wings - Pelimusa)
	sample $0100, Kaiku4, Stop		; 9E - Kaiku (Wings - Pelimusa)
	sample $0100, Kaiku5, Stop		; 9F - Kaiku (Wings - Pelimusa)
	sample $0100, KaikuL1, KaikuL2, KaikuL2	; A0 - Kaiku (Wings - Pelimusa)
	sample $0100, KaikuL1, KaikuL3, KaikuL3	; A1 - Kaiku (Wings - Pelimusa)
	sample $0100, Sarobasso, Stop		; A2 - Sarobasso (Wings - Pelimusa)
; ===========================================================================
; ---------------------------------------------------------------------------
; Define volume envelopes and their data
; ---------------------------------------------------------------------------

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
vdS2_01:	dc.b $00, $00, $00, $01, $01, $01, $02, $02
		dc.b $02, $03, $03, $03, $04, $04, $04, $05
		dc.b $05, $05, $06, $06, $06, $07, eHold

; Sonic 2 0B
vdS2_0B:	dc.b $04, $04, $04, $03, $03, $03, $02, $02
		dc.b $02, $01, $01, $01, $01, $01, $01, $01
		dc.b $02, $02, $02, $02, $02, $03, $03, $03
		dc.b $03, $03, $04, eHold

; Michael Jackson's Moonwalker 04
vdMoonWalker04:	dc.b $00, $00, $02, $03, $04, $04, $05, $05
		dc.b $05, $06, eHold

; Knuckles Chaotix 08
vdKc08:		dc.b $02, $01, $00, $00, $01, $01, $02, eHold

; Zaxxon Motherbase 04
vdZaxx04:	dc.b $02, $01, $00, $00, $01, $02, $02, $02
		dc.b $02, $02, $02, $02, $02, $02, $02, $02
		dc.b $02, $03, $03, $03, $04, $04, $04, $05, eHold

; World of Illusion 0C
vdWOI_0C:	dc.b $06, $05, $04, $03, $01, $01, $00, $00
		dc.b $00, $00, $00, $00, $00, $00, $01, $01
		dc.b $02, $02, $03, $03, $04, $04, eHold

; World of Illusion 0D
vdWOI_0D:	dc.b $04, $03, $02, $01, $00, $01, $01, $02
		dc.b $02, $03, $03, $04, $04, $05, $05, $06
		dc.b $06, $07, $07, eHold

; Phantasy Star III & Knuckles Chaotix 05
vdKc05:
vdPhan3_05:	dc.b $03, $00, $01, $01, $01, $02, $03, $04
		dc.b $04, $05, eHold

; Phantasy Star III 0A
vdPhan3_0A:	dc.b $01, $00, $00, $00, $00, $01, $01, $01
		dc.b $02, $02, $02, $03, $03, $03, $03, $04
		dc.b $04, $04, $05, $05, eHold

; Game no Kanzume Otokuyou 01
vdGameNo01:	dc.b $00, $01, $01, $01, $01, $01, $01, $01
		dc.b $01, $02, $02, $02, $02, $02, $02, $02
		dc.b $02, $03, $03, $03, $03, $03, $03, $03
		dc.b $03, $04, $04, $04, $04, $04, $04, $04
		dc.b $04, $05, $05, $05, $05, $05, $05, $05
		dc.b $05, $06, eHold

; Ristar 07
vdRistar07:	dc.b $03, $02, $01, $00, $00, $01, $01, $02, eHold

; Knuckles Chaotix 02
vdKc02:		dc.b $00, $00		; continue to volenv below

; Ristar & S2 & S3K & Columns III 02
vdS2_02:
vdCol3_02:
vdS3K_02:
vdRistar02:	dc.b $00, $02, $04, $06, $08, $10, eStop

; Ristar 1D
vdRistar1D:	dc.b $00, $00, $00, $00, $01, $01, $01, $01
		dc.b $01, $02, $02, $03, $03, $04, $04, $04
		dc.b $04, $03, $03, $02, $02, $01, eHold

; Ristar 10 & S3K 08
vdS3K_08:
vdRistar10:	dc.b $00, $00, $00, $02, $03, $03, $04, $05
		dc.b $06, $07, $08, $09, $0A, $0B, $0E, $0F, eStop

; Ristar 18
vdRistar18:	dc.b $00, $03, $06, $09, eStop

; S3K 01
vdS3K_01:	dc.b $02, eStop

; S3K 0A
vdS3K_0A:	dc.b $01, $00, $00, $00, $00, $01, $01, $01
		dc.b $02, $02, $02, $03, $03, $03, $03, $04
		dc.b $04, $04, $05, $05, eHold

; Dynamite Headdy 03
vdDyHe03:	dc.b $00, $00, $01, $01, $03, $03, $04, $05, eStop

; Dynamite Headdy 05
vdDyHe05:	dc.b $04, $04, $04, $04, $03, $03, $03, $03
		dc.b $02, $02, $02, $02, $01, $01, $01, $01
		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $01, $01, $01, $01, $01, $01
		dc.b $01, $01, $01, $01, $01, $01, $01, $01
		dc.b $02, $02, $02, $02, $02, $02, $02, $02
		dc.b $03, $03, $03, $03, $03, $03, $03, $03
		dc.b $04, eStop

; Dynamite Headdy 0A
vdDyHe0A:	dc.b $07, $06, $06, $06, $05, $05, $05, $04
		dc.b $04, $03, $03, $03, $03, $03, $02, $02
		dc.b $02, $01, $01, $01, $00, $00, $00, $00
		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $01, $01, $01, $01, $01, $01
		dc.b $01, $01, $01, $01, $01, $01, $01, $01
		dc.b $01, $01, $01, $01, $01, $01, $02, $02
		dc.b $02, $02, $02, $02, $03, $03, $03, $03
		dc.b $04, $04, $04, $04, $04, $05, $05, $05
		dc.b $05, $05, $06, $06, $06, $06, $06, $07
		dc.b $07, $07, $07, $07, $08, $08, $08, $08
		dc.b $08, $09, $09, $09, $09, $09, eHold

; Columns III 03
vdCol3_03:	dc.b $02, $01, $00, $00, $01, $02, $02, $02
		dc.b $02, $02, $02, $02, $02, $02, $02, $02
		dc.b $02, $03, $03, $03, $04, $04, $04, $05, eHold

; Columns III 05
vdCol3_05:	dc.b $02, $01, $00, $00, $01, $02, $02, $02
		dc.b $02, $02, $02, $02, $02, $02, $02, $02
		dc.b $02, $03, $03, $03, $04, $04, $04, $05, eStop
; ===========================================================================
; ---------------------------------------------------------------------------
; Define volume envelopes and their data
; ---------------------------------------------------------------------------

		even
__menv =	$01

ModEnvs:
	ModEnv Test
ModEnvs_End:
; ---------------------------------------------------------------------------

	if FEATURE_MODENV
; just testin'
mdTest:		dc.b $08, eaSens, $01, eLoop, $00
	endif

; ===========================================================================
; ---------------------------------------------------------------------------
; Include music, sound effects and voice table
; ---------------------------------------------------------------------------

	include "driver/Voices.asm"	; include universal Voice bank
	opt ae-				; disable automatic evens

sfxaddr	incSFX				; include all sfx
musaddr	incMus				; include all music
musend
; ===========================================================================
; ---------------------------------------------------------------------------
; Include samples and filters
; ---------------------------------------------------------------------------

		align	$8000		; must be aligned to bank... By the way, these are also set in Z80.asm... Be sure to check it out also.
fLog:		incbin "driver/filters/Logarithmic.dat"	; logarithmic filter (no filter)
;fLinear:	incbin "driver/filters/Linear.dat"	; linear filter (no filter)

dacaddr		dcb.b	Z80E_Read*(MaxPitch/$100),$00
SWF_Stop:	dcb.b	$8000-(2*Z80E_Read*(MaxPitch/$100)),$80
SWFR_Stop:	dcb.b	Z80E_Read*(MaxPitch/$100),$00

	incSWF	Kick, LowKick, Snare, Clap, Tom, Wooh, WoohLoop
	incSWF	OrchHit, ZaxxOOH, ZaxxDIS, ZaxxEYO, ZaxxIT, ZaxxGO
	incSWF	KcTom, KcSnare, KcTamb, Kc87, KcCrash, KcCymbal
	incSWF	KaikuL1, KaikuL2, KaikuL3, Kaiku1, Kaiku2, Kaiku3, Kaiku4, Kaiku5
	incSWF	Meow, Lazer, Sarobasso
	opt ae+				; enable automatic evens
	list				; continue source listing
; ===========================================================================
