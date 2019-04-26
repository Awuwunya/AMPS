# Ample Music Playback System

AMPS is a 68k-based SMPS-like sound driver, designed to be used with ROM hacks and Sega Mega Drive software. Although similar to SMPS, AMPS is fundamentally different in many aspects. It is also very customized, RAM efficient and cycle efficient. AMPS is additionally powered by Dual PCM FlexEd, meaning that you can use 2 DAC sample channels with pitch and volume control. AMPS was designed to be well documented driver with a lot of capabilities so that the music created for the sound driver can sound better, and the music and game program can interact with each other. To ensure this, AMPS has a very robust codebase built to allow future expansion and customized programming for game-specific circumstances.

# More info
Sonic Stuff Research Group - Sonic Retro

# Features
* Highly optimized code, that will ensure that no time is wasted in processing the 68k side code.
* Lower RAM usage. The driver optimizes the RAM usage, so that it is easier to add into any program. This release of the sound driver uses only $29A bytes of RAM.
* Documented source code for easier modification.
* Full support for Dual PCM FlexEd.
	* 2-channel PCM playback.
	* Volume and pitch control.
	* Reverse sample playback.
	* Looping sample support.
	* DMA quality loss prevention.
	* Simplistic sample filtering.
* PCM sound effect channel and 2 music PCM channels.
* PCM channels can choose between 2 modes; Sample mode where each note is the sample to be played, and pitch mode where each note changes the pitch instead.
* Support for most common volume envelope end commands. This makes porting volume envelopes easier.
* SMPS2ASM integration. This makes it possible to easily port music and allows for future expansion.
* Universal sound bank for sound effects.
* SSG-EG and LFO support.
* Speed shoes tempo adjustment, and 2 tempo algorithms; overflow-based and tempo-based.
* Toggleable 50hz "fix" for music.
* Spindash sound effect support.
* Special underwater mode. This allows for a cool underwater-esque effect for music and sound effects (as seen in Sonic 2 Recreation).
* Customizable fading support. The driver supports multiple different types of fades, and they are user-defined, allowing for a huge variety of different ways to fade or manipulate channel volumes globally.
* Better commands for using communications bytes for 2-way conversation between tracker files and the game code, and conditionally executing tracker code.
* Continuous sound effects support. These are sound effects in Sonic 3 & Knuckles that instead of restarting, continue to play sound when the sound ID is played.
* Sound driver debugging support. This feature allows the sound driver to alert the programmer when various errors or possible mistakes happen when playing tracker files. Very useful for finding out when something goes wrong with the sound driver.
