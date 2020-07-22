# Ample Music Playback System - Test Program

AMPS is a sound driver software package aimed at making Mega Drive audio development easier and more comfortable for musicians and programmers. The driver is a Motorola 68000 & Zilog Z80 based software, that is responsible for managing the audio hardware on the Sega Mega Drive. It can be controlled via 68000 software and does not need a lot to set up. Currently, there are variations available for the ASM68K and AS Macro Assembler, with great portability of tracker files across both assemblers as well. AMPS aims to be faster, more reliable, feature richer, and easier to use than previous sound drivers. It is based on Sound-Source which was commonly used by Japanese game developers at the time. Unlike Sound-Source, AMPS has a single standardized version that allows porting music from other formats to best of its ability without sacrifising the features the driver supports. AMPS also aims to build a repository of tools to eventually make native music development for AMPS easy for everyone. See the Releases tab for stable versions, or the source code for unstable development versions.

# More info
[Sonic Stuff Research Group](http://sonicresearch.org/community/index.php?threads/amps-ample-music-playback-system.5634) - [Sonic Retro](https://forums.sonicretro.org/index.php?threads/amps-ample-music-playback-system.38583)

# Example implmentations
* [AMPS test program](https://github.com/NatsumiFox/AMPS)
* [Sonic 1 2005 implementation](https://github.com/NatsumiFox/AMPS-Sonic-1-2005)
* [Sonic 1 Git implementation](https://github.com/NatsumiFox/AMPS-Sonic-1-Git)
* [Sonic 2 Git implementation](https://github.com/NatsumiFox/AMPS-Sonic-2)

# Features
* Highly optimized code, that will ensure that no unnecessary time is wasted in processing the 68k side code.
* Lower RAM usage. The driver optimizes the RAM usage, so that it is easier to add into any program. There are various features you can enable/disable to control this.
* Documented source code for easier modification.
* Comprehensive sound driver documentation.
* Full support for Dual PCM FlexEd.
	* 2-channel PCM playback.
	* Volume and pitch control.
	* Reverse sample playback.
	* Looping sample support.
	* DMA quality loss prevention.
	* Simplistic sample filtering.
* PCM sound effect channel and 2 music PCM channels.
* PCM channels can choose between 2 modes; Sample mode where each note is the sample to be played, and pitch mode where each note changes the pitch instead.
* Support for most common volume envelope and modulation envelope end commands. This makes porting envelopes easier.
* Full SMPS2ASM integration. This makes it possible to easily port music and allows for future expansion.
* Universal sound bank for sound effects.
* SSG-EG and LFO support.
* Speed shoes tempo adjustment, and 2 tempo algorithms; overflow-based and tempo-based.
* Toggleable 50hz "fix" for music.
* Spindash sound effect support.
* Special underwater mode. This allows for a cool underwater-esque effect for music and sound effects (as seen in Sonic 2 Recreation).
* Customizable fading support. The driver supports multiple different types of fades, and they are user-defined, allowing for a huge variety of different ways to fade or manipulate channel volumes globally.
* Better commands for using communications bytes for 2-way conversation between tracker files and the game code, and conditionally executing tracker code.
* Continuous sound effects support. These are sound effects in Sonic 3 & Knuckles that instead of restarting, continue to play sound when the sound ID is played.
* Song back-up support. This is used in Sonic games for the 1-up sound, where the previous music fades in gradually.
* Sound driver debugging support. This feature allows the sound driver to alert the programmer when various errors or possible mistakes happen when playing tracker files. Very useful for finding out when something goes wrong with the sound driver.

