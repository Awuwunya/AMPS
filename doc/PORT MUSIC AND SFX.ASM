********************************************************************************
*                                                                              *
*       File: PORTING MUSIC AND SFX                                            *
*       Date: 19.04.08                                                         *
*       Last: 19.04.18                                                         *
*                                                                              *
********************************************************************************

***** INTRO *****

;This short tutorial will give you some basic information related to porting
;music and sound effects from SMPS games into AMPS. As the sound format is very
;different, I felt obligated to help people out in the form of a tutorial. This
;tutorial will not explain the specifics of how to implement new music, but will
;give an overview of the recommended way of converting and modifying music to
;work with the format, and give a few examples. Music porting is never so simple
;and will take some work to get right.


***** CONVERTING MUSIC TO AMPS FORMAT *****

;To allow for updating the driver in the future without breaking anything music-
;related, AMPS only supports Natsumi's smps2asm music format, meaning that if
;you have music converted with a different tool, such as S1SMPS2ASM or
;Flamwing's SMPS2ASM, you must either assemble it and reconvert, or edit the
;file by hand. I am not willing to provide a solution for this problem.
;
;I will walk you through the steps of converting Sonic 1 music to the ASM
;format, as I believe most binary music will be in this format already. This
;should apply to most other games as well, but you may need adjustments to these
;steps to make it work perfectly.
;
;Step 1: Download and extract MDMusicPlayer. The download link can be found in
;the following threads:
;SSRG link:           http://sonicresearch.org/community/index.php?threads/4354/
;Sonic Retro link:    https://forums.sonicretro.org/index.php?showtopic=35272
;
;Step 2: Put the binary file in the music folder of MDMusicPlayer source.
;
;Step 3: Determine what sound driver the file originated from. Most likely it
;will be Sonic 1, which goes by "MegaPCM" in the MDMusicPlayer source. If you
;find a suitable game in the SMPS folder of MDMusicPlayer, skip to step 6.
;
;Step 4: If the scripts do not exist or you are not sure if they are sufficient,
;please download ValleyBell's SMPS research pack (link below). Then locate the
;game in question from the "Rips" folder. For this tutorial, I will use
;"Crayon Shin-Chan" as an example.
;
;SMPS Research Pack download:
;http://forums.sonicretro.org/index.php?showtopic=32473&st=80
;
;Step 5: Open up DefCFlag.txt and examine it. Some of the folders in
;MDMusicPlayer may be based on games that closely match with the one you want to
;convert. Sometimes it's not obvious which names correlate to which SMPS2ASM
;commands, hence why I've marked them down in the "smps2asm (ASM68K)" files. If
;you can not find an exact match, you can create a new folder for your specific
;game, and edit the "smps2asm.smpss" file to suit your needs. If you do not know
;a name for a specific command, you can check if any other game has it, and if
;not, just make up your own. You will most likely have to remove them anyway, so
;it does not matter. Be sure to check the endianness of the game; Z80-based
;drivers are little endian (usually), while 68K-based drivers are big endian.
;
;Step 6: Make sure that all the DAC and PSG instruments are listed within the
;script. If some are missing, you can add them by hand yourself, which should be
;relatively easy. Often, custom SMPS files are based on the Nineko drum set,
;which adds two extra samples: a clap ($84), and a cymbal ($85). There is some
;knowledge required to get this step right, though you can later manually edit
;the files if adjustments are needed.
;
;Step 7: Go through everything twice just to make sure nothing is out of place.
;It's always easier to fix something before conversion rather than after.
;
;Step 8: Next, it's time to actually disassemble the file. Open up SMPS2ASM.EXE
;from the bin folder, and fill in your details as instructed by the program UI.
;The UI will notify you if something goes wrong. As an extra step for Z80-based
;drivers, you have to figure out the base address. SMPS player will show this if
;you play the song using it. Otherwise, in *most* cases, it's the ROM
;address & $7FFF | $8000. But for games such as Sonic 2 and Megaman Wily Wars,
;it will be a hardcoded Z80 address. You have to be very careful with this.
;
;Step 9: Once you've successfully converted a file, you need to edit it to
;work with the driver; as the driver uses a modified format, there is some
;manual labour required. I will show how to convert the header first. Open the
;converted file and follow along. In this example, the header looks like this:

ShinChan_Header:
	sHeaderInit
	sHeaderPatch	ShinChan_Patches
	sHeaderCh	$06, $03
	sHeaderTempo	$02, $05
	sHeaderDAC	ShinChan_DAC
	sHeaderFM	ShinChan_FM1, $03, $12
	sHeaderFM	ShinChan_FM2, $03, $14
	sHeaderFM	ShinChan_FM3, $F7, $09
	sHeaderFM	ShinChan_FM4, $03, $14
	sHeaderFM	ShinChan_FM5, $03, $14
	sHeaderPSG	ShinChan_PSG1, $D3, $04, $00, v04
	sHeaderPSG	ShinChan_PSG2, $D3, $04, $00, v04
	sHeaderPSG	ShinChan_PSG3, $D3, $04, $00, v04

;Of course, your header may differ. Firstly, remove the line containing
;sHeaderPatch, as it's not needed. Next, check what the tempo algorithm is in
;the source driver, and what setting is enabled in AMPS. Here, the song uses the
;counter algorithm, and we want to change it to the overflow algorithm. To
;To convert between algorithms, you can use my tool linked here:
;http://natsumi.eu/dl/TempConvS1toS3K.exe
;
;Next, switch the lines containing sHeaderTempo and sHeaderCh around, as this
;was done to optimize the driver further. Finally, the driver expects 2 DAC for
;all music. Rename the ShinChan_DAC label into ShinChan_DAC2. Duplicated the
;line starting with sHeaderDAC in the header, and rename the label from
;ShinChan_DAC to ShinChan_DAC1 and ShinChan_DAC2 respectively. Now, the header
;should look something ĺike this:

ShinChan_Header:
	sHeaderInit
	sHeaderTempo	$02, $33
	sHeaderCh	$06, $03
	sHeaderDAC	ShinChan_DAC1	; <- this one will not be used for music
	sHeaderDAC	ShinChan_DAC2
	sHeaderFM	ShinChan_FM1, $03, $12
	sHeaderFM	ShinChan_FM2, $03, $14
	sHeaderFM	ShinChan_FM3, $F7, $09
	sHeaderFM	ShinChan_FM4, $03, $14
	sHeaderFM	ShinChan_FM5, $03, $14
	sHeaderPSG	ShinChan_PSG1, $D3, $04, $00, v04
	sHeaderPSG	ShinChan_PSG2, $D3, $04, $00, v04
	sHeaderPSG	ShinChan_PSG3, $D3, $04, $00, v04

;Step 10: Next, we need to fix a few things we broke. Right below the header,
;insert the following lines:

ShinChan_DAC1:
	sStop

;These lines ensure, that while DAC1 now exists, it ends immediately. If the
;original song had 2 DAC channels already, this step won't be necessary. Next,
;we need to move the patches right below the header, if not there already. Find
;the ShinChan_Patches label (likely at the bottom of the asm file), and select
;everything until another label or end of file. Move the code right below the
;last sHeaderPSG line. Here is how the example looks like now:

ShinChan_Header:
	sHeaderInit
	sHeaderPatch	ShinChan_Patches
	sHeaderCh	$06, $03
	sHeaderTempo	$02, $05
	sHeaderDAC	ShinChan_DAC
	sHeaderFM	ShinChan_FM1, $03, $12
	sHeaderFM	ShinChan_FM2, $03, $14
	sHeaderFM	ShinChan_FM3, $F7, $09
	sHeaderFM	ShinChan_FM4, $03, $14
	sHeaderFM	ShinChan_FM5, $03, $14
	sHeaderPSG	ShinChan_PSG1, $D3, $04, $00, v04
	sHeaderPSG	ShinChan_PSG2, $D3, $04, $00, v04
	sHeaderPSG	ShinChan_PSG3, $D3, $04, $00, v04

	; Patch $00
	; $2D
	; $01, $62, $03, $21,	$30, $1F, $13, $26
	; $08, $08, $08, $03,	$05, $00, $03, $00
	; $1F, $1B, $1B, $1B,	$1A, $80, $80, $80
	spAlgorithm	$05
	spFeedback	$05
	spDetune	$00, $00, $06, $02
	spMultiple	$01, $03, $02, $01
	spRateScale	$00, $00, $00, $00
	spAttackRt	$10, $13, $1F, $06
	spAmpMod	$00, $00, $00, $00
	spSustainRt	$08, $08, $08, $03
	spSustainLv	$01, $01, $01, $01
	spDecayRt	$05, $03, $00, $00
	spReleaseRt	$0F, $0B, $0B, $0B
	spTotalLv	$1A, $00, $00, $00

	; etc . . .

;Step 11: Next up, lets fix all the command flags. This process will depend on
;the game itself, but I here's a rough idea on how to do it. For each of these
;flags, replace the left side with the right side:

	sPatFM ->	sVoice
	sVolEnvPSG ->	sVoice
	saVolFM ->	saVol
	saVolFPSG ->	saVol
	ssModZ80 ->	ssMod68k

;If the game uses the Z80 modulation method (ssModZ80), you may have to modify
;the values for that command flag. Usually it depends on the case and will
;require experimentation to get a handle on it. In most cases, it does not
;matter all that much.
;
;Step 12: Linking the song to AMPS is very useful for testing. We can do this
;very easily; first, move the file into the driver/music folder. Name it
;something descriptive. IMPORTANT: ONLY USE LETTERS A-Z, UNDERSCORES, AND
;NUMBERS IN THE NAME!!! This is very important, because the driver will generate
;an equate name for the song. Because of limitations with asm68k, you may only
;use those characters in equate names. Next up, open driver/code/68k.asm, and
;navigate to MusicIndex, and add your song as the last entry. You must put in
;the name of the file, and the speed-up tempo value. It's not necessary to have
;a different value for the speed-up tempo, but if the music can be sped up, it
;should be adjusted for the best effect.
;
;Step 13; Fix the PSG instruments. This is trial-and-error, and varies between
;games. SMPS research pack contains the PSG instrument data in its driver rips,
;and you can check there if the music uses custom ones. You can try to match
;them to ones installed in AMPS, or create custom ones to accomodate the game.
;Usually, it's enough to use one closely resembling the originals, but sometimes
;you may find it doesn't work. Then go around, and fix any references to the
;original instrument (prefixed with v) with the new ones used in AMPS.
;
;Step 14: Similar thing happens with DAC. This time, the prefix is d. You can
;try to port the DAC from the original game, or use similar ones pre-installed
;or added after the fact.
;
;Step 15: If the song requires specific timing (for example, the drowning music)
;you may disable the 50hz "fix", that makes all music in PAL region play at
;normal speed. To do this, simple add $80 to the first value in sHeaderTempo
;line. Here is an example of it:

	sHeaderTempo	$82, $05


***** CONVERTING SFX TO AMPS FORMAT *****

;Porting sound effects is very similar to music. SMPS2ASM has a feature to
;disassemble SFX when you append ".SFX" after the sound driver name. For
;example, "MegaPCM.SFX". This, along with a SFX file you can find in a game, you
;can port SFX over! Follow the music porting tutorial, but do not edit the
;header or the patches. After that, follow these steps:
;
;Step 1: The sound effect header is different to music, so here is an example:

	sHeaderInit
	sHeaderPrio	$80
	sHeaderCh	$01
	sHeaderSFX	$80, ctFM4, .FM4, $00, $05

;As you may notice, sHeaderPatch is gone again, as is sHeaderTick. If the latter
;is not 1, you may have to add a ssTickMul into one of the channels to fix that.
;You have an additional sHeaderPrio field. This works similarly to the priority
;values in SMPS, but is stored in the header. Unlike SMPS, it's channel-specific
;and will not reset itself. If a channel has a higher priority, it will always
;override another channel. If not, it will never do. It is very important to
;carefully decide what value to put here. ctFM4 is just alias for the FM4
;channel, it's not required to change it from raw values into these equates.
;
;Step 2: AMPS has only a single bank for SFX patches, so the individual patches
;in the SFX files have to be moved. Locate the patches inside of the SFX file
;and move them to driver/Voices.asm, which contains all the FM patches used in
;the sound driver. You can create equates for each patch to make management
;easier. Here is an example:

	spAlgorithm	$04, Rings

;As you see, the extra argument "Rings" will be used to create an equate. pRings
;can now be used in place of a value for the sVoice flag. Here is an example:

	sVoice	pRings

;This allows for adding multiple patches without having to worry about conflicts
;or broken values.
;
;Step 3: Now you can add your new SFX into the driver. Put it in the driver/sfx
;folder, and again give it an unique name with only A-Z letters, numbers and
;underscores. You need to add it to SoundIndex in the driver/code/68k.asm file,
;as the last SFX. Note: the first value in the ptrSFX macro declares special
;flags for the music. Currently, value of $80 means the SFX is continuous,
;meaning it can use the special Sonic 3 feature, where playing SFX over and over
;just extends it, instead of restarting it. Make sure to use the right value for
;your new SFX.
