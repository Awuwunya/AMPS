********************************************************************************
*                                                                              *
*       File: INSTALLING AMPS (v1.0)                                           *
*       Date: 19.04.11                                                         *
*       Last: 19.04.13                                                         *
*                                                                              *
********************************************************************************

***** INTRO *****

;Installing AMPS into a project is not necessarily a very easy task, especially
;if you have less experience with sound drivers. AMPS is a complicated sound
;driver with many moving parts, so I felt like a tutorial detailing the steps
;you must take is required. Please note, that currently AMPS has only a asm68k
;versíon. Since the sound driver is so large and complicated, it would take very
;long to port to other assemblers, and therefore no other assembler is supported
;at the moment. This may change in the future. The disassembly folder "s1hive"
;is provided as an example implementation of AMPS, and can be used for basing
;your hack around. It can also be used to compare your custom implementation, in
;debugging what might be going wrong.


***** PREPARATIONS *****

;First of all, we need to prepare a few things to be sure we can easily put the
;new driver in. First of all, make sure you are using the latest version of the
;driver, to be sure that all the new additions and fixes are available. Also be
;sure to follow the correct tutorial for your version!
;
;For this example, we will be installing AMPS on the 2005 HiveBrain disassembly,
;targetting asm68k. This tutorial can be adapted for other disassemblies,
;provided they use a compatible assembler.
;
;Step 1: Copy the driver folder from either the root download folder, or the
;s1hive folder. For hacks, using the s1hive version is recommended. Copy this
;whole folder into the root directory of your hack.
;
;Step 2: Find every music file and sound effect file in your disassembly, and
;convert them into the AMPS format. See "PORT MUSIC AND SFX.ASM" file for
;further instructions on how to do this part. Make sure the driver/music folder
;contains all the necessary music files for your hack, and driver/sfx folder
;contains all the sfx for your hack.
;
;Step 3: Find every DAC sample in your disassembly, and convert them to .wav
;format. You can use external tools, such as Audacity, to load 8-bit PCM files
;into them, and save as .wav. To convert DPMC files into PCM, you can use a tool
;called DPCM2PCM, found in ValleyBell's SMPS Research Pack:
;> http://forums.sonicretro.org/index.php?showtopic=32473&st=80
;
;Save the converted .wav files in the driver/dac folder, and drag them once into
;the ConvPCM.exe program. This will convert the DAC files into the proper format
;for DualPCM FlexEd to use.
;
;Step 4: Open driver/code/68k.asm, and find the label SWFR_Stop. Below this, you
;will see incSWF statements. Please fill in the file names of the DAC samples
;you have in driver/dac folder. Scroll up to find the SampleList label, and
;below it are multiple different lines with information about samples. Each line
;represents a single sample setting the game has. Sometimes single samples have
;multiple settings. Update this list to contain all the samples required for
;your hack. The format of each line is described at the bottom of the
;"DUAL PCM FLEXED.ASM" document file.
;
;Step 5: In driver/code/68k.asm, locate the label VolEnvs. This table
;represents all the installed volume envelopes of the sound driver. This may be
;called by a different name in the disassembly you are using. You need to look
;at all the volume envelopes installed in your hack, and update the VolEnvs
;table accordingly. Each entry just represents a name for the volume envelope.
;These names will translate into vName for the equate to use in your music, and
;vdName for use to define the volume envelope data, below the table. You need to
;then translate the volume envelope data from the hack's sound driver into the
;space below. You need to pay special attention to make sure what the correct
;flag is at the end; Usually any value >= $80 will be a special flag, and the
;hack's sound driver may interpret this differently. This is why you have to use
;the equates in AMPS to ensure correct functionality.
;
;Step 6: In driver/code/68k.asm, locate label dPlaySnd_SFX. Make sure that the
;equates for sfx_RingRight and sfx_RingLeft match the ring sound effect names
;in your hack. In case the ring speaker switching behaviour is not desirable, or
;your hack does not have the ring sound effect, comment the 5 lines to do with
;this behaviour.
;
;Step 7: Next, you must go through your disassembly, and change the numeric or
;equated song ID's into AMPS equates. All music has the mus_ prefix, and all sfx
;have the sfx_ prefix, to denote the equates for your new music. They will use
;the file name you provided in driver/code/68k.asm. Additionally, the sound
;commands must be changed into the AMPS equates, provided in
;driver/code/macro.asm.


***** PREVIOUS SOUND DRIVER *****

;In order to install AMPS, we have to thoroughly clean up the old sound driver.
;Specifically, we need to remove any data it was using. This process can be
;different depending on the game, and even the disassembly used. I will provide
;a quick reference for the Hivebrain 2005 disassembly, but this should be
;heavily adapted for any other disassembly.
;
;Open up sonic1.asm, and locate SoundDriverLoad. Delete from there until before
;PauseGame. Go to Go_SoundTypes, and delete everything from there, until before
;EndOfRom. Go to GameClrRAM, and below that label, delete this line:

		bsr.w	SoundDriverLoad

;That should be it.


***** FINALIZING AMPS INSTALL *****

;We're almost done! Now we need to just add a few lines of code here and there
;to finish AMPS install.
;
;Step 1: Open sonic1.asm, and at the very top, add these lines:

		include "driver/lang.asm"
		include "driver/code/macro.asm"

;Step 2: Before StartOfRom, add this line:

		org 0

;Step 3: Go to label GameClrRAM. After the following line:

		bsr.w	VDPSetupGame

;Add this line:

		jsr	LoadDualPCM		; Initialize DualPCM FlexEd

;Step 4: We need to fix the game pausing behaviour. Go to PauseGame, and below, you should see:

		move.b	#1,($FFFFF003).w ; pause music

;replace this with the following:

	AMPS_MUSPAUSE			; pause music

;and replace this in the 2 places it appears:

		move.b	#$80,($FFFFF003).w

;with this:

	AMPS_MUSUNPAUSE			; unpause music

;Step 5: Before EndOfRom, add these lines:

		include "driver/code/smps2asm.asm"
		include "driver/code/68k.asm"
DualPCM:	z80prog 0
		include "driver/code/z80.asm"
DualPCM_sz:	z80prog

	opt ae+

;Step 5: This only applies to you if you have Vladikcomper's error debugger
;installed. Make sure the error debugger include is the last line before
;EndOfRom. The driver is designed to be able to handle this. Additionally, copy
;ErrorDebugger/Debugger.asm into your disassembly, replacing Debugger.asm
;(wherever it is located). Because of Natsumi's Z80 assembly macros, the word
;dec is needed to represent the Z80 instruction. Therefore, any code that relies
;on the dec variable must be changed to use decm to accomodate AMPS.
;
;Step 6: We need to remove all of the Z80 stops from DMA transfers, similarly to
;the MegaPCM installation guide. First, we need to remove each block similar to
;this one:

		move.w	#$100,($A11100).l

loc_BC8:
		btst	#0,($A11100).l
		bne.s	loc_BC8

;below these specific labels: loc_BBA, loc_C6E, loc_DA6, loc_E72, loc_FA6, and
;sub_106E
;Similarly, we need to also remove the following line:

		move.w	#0,($A11100).l

;below these labels: loc_C22, loc_D50, loc_DA6, loc_F54, loc_FA6, and loc_10D4
;This is done because Dual PCM FlexEd avoids reading from the window during
;DMA's and does not need to be stopped, or told that a DMA is starting.
;
;Step 7: We need to add new routines for playing sounds. Above PauseGame, add
;these following lines:

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	play a music track
; ---------------------------------------------------------------------------

PlaySound:
		move.b	d0,mQueue.w
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	play a sound effect
; ---------------------------------------------------------------------------

PlaySound_Special:
		move.b	d0,mQueue+1.w
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	play a sound effect or a command
; ---------------------------------------------------------------------------

PlaySound_Special2:
		move.b	d0,mQueue+2.w
		rts

;Step 8: We need to fix the call for the sound driver in V-Blank. Find loc_B5E,
;and change the following:

		jsr	sub_71B4C

;into:

		jsr	UpdateAMPS		; Update all music-related things

;
;And you're done (hopefully)! Enjoy your new sound driver. If you have any
;problems, please read the FREQUENT ERRORS section. As an additional step, you
;should also change the sound test in your hack to show music from 00 to FF.
;If you want to be fancy, these are few of the equates you can use in your code:
;	00 - ID of the first installed sound command.
;	MusOff - ID of the first installed music file.
;	SFXoff - ID of the first installed sound effect file.
;	(SFXoff+SFXcount) - ID of the first invalid sound.


***** FREQUENT ERRORS *****

;Uh oh?! Game does not work? Assembler pukes at you? Here are a few fixes that
;may solve your problems. If none of these fixes solve your problem, please
;contact Natsumi via Github, SSRG forums, Sonic Retro forums or Discord.
;
;Problem 1: ...\DRIVER\CODE\MACRO.ASM(167) : Error : Expression must evaluate
;This problem is cause because, for some reason, the safe equate could not be
;solved at assembly time. The s1hive example uses a modified assembly script to
;set this variable ahead of time. You can copy the build.bat and
;build optimized.bat files into your disassembly, or use this easy fix: Open
;driver/code/macro.asm and change this line:

;safe =	1	; Actually, this gets set by the build script, but you can disable that.

;into:

safe =	1

