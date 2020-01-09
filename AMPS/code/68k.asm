	opt oz+						; enable zero-offset optimization
	opt l.						; local lables are dots
	opt ae+						; enable automatic even's

	include "AMPS/code/68k Macro Routines.asm"	; include macro'd routines
	include "AMPS/code/68k Debug.asm"		; debug data blob
	include "AMPS/code/68k Initialize.asm"		; initialization code for Dual PCM
	include "AMPS/code/68k Main.asm"		; all the main & misc code. Flows directly to DAC Routines.asm
	include "AMPS/code/68k DAC Routines.asm"	; most DAC-related code
	include "AMPS/code/68k FM Routines.asm"		; most FM-related code
	include "AMPS/code/68k PSG Routines.asm"	; most PSG-related code
	include "AMPS/code/68k Envelopes.asm"		; code for processing various envelopes
	include "AMPS/code/68k PlaySnd.asm"		; routine for playing sounds
	include "AMPS/code/68k Commands.asm"		; routine for proecessing commands
	include "AMPS/.Data"				; all the data related to the driver
