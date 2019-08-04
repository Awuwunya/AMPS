	opt oz+						; enable zero-offset optimization
	opt l.						; local lables are dots
	opt ae+						; enable automatic even's

	include "driver/code/68k Macro Routines.asm"	; include macro'd routines
	include "driver/code/68k Debug.asm"		; debug data blob
	include "driver/code/68k Initialize.asm"	; initialization code for Dual PCM
	include "driver/code/68k Main.asm"		; all the main & misc code. Flows directly to DAC Routines.asm
	include "driver/code/68k DAC Routines.asm"	; most DAC-related code
	include "driver/code/68k FM Routines.asm"	; most FM-related code
	include "driver/code/68k PSG Routines.asm"	; most PSG-related code
	include "driver/code/68k Envelopes.asm"		; code for processing various envelopes
	include "driver/code/68k PlaySnd.asm"		; routine for playing sounds
	include "driver/code/68k Commands.asm"		; routine for proecessing commands
	include "driver/code/Data.asm"			; all the data related to the driver
