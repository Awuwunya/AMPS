********************************************************************************
*                                                                              *
*       File: INTRODUCTORY                                                     *
*       Date: 18.01.22                                                         *
*       Last: 19.04.07                                                         *
*                                                                              *
********************************************************************************

***** INTRO *****

;That's right, the intro has an intro! You have downloaded Natsumi's 68k sound
;driver; AMPS - Ample Music Playback System! This sound driver is an evolution
;of the SMPS 68k sound driver - specifically from Sonic 1. Natsumi sought to
;make a sound driver that is more optimized, easier to use, and more feature
;rich, while retiring the simplistic and frankly terrible Sonic 1 driver, with
;its bugs and all. The driver still uses many ideas from SMPS and even shares
;some code, but fundamentally its very different from it.

;In fact so different, multiple topics are covered by this documentation. By no
;means, is this documentation exhaustive, well written, or even accurate, so,
;for those seeking to get the detailed knowledge of the inner workings of the
;driver, please refer to the source code for assistance. This help topic is
;intended to get you on the right track for understanding the driver, not to be
;the end-all knowledge dump. This current page will contain topics that give you
;a few basic ideas behind the driver, and some miscellaneous topics not worth
;their own files.


***** DRIVER OVERVIEW *****

;AMPS and SMPS are tracker-based software layer on top of the Sega Mega Drive
;sound hardware. They act as a middle-man for the tracker data and the YM2612,
;and SN76489, interpreting commands and note data, and feeding appropriate data
;back to hardware. However, there is another software layer in front of YM2612:
;Dual PCM FlexEd. The driver talks directly to this driver, which in turn will
;process all DAC-related requests, and spit out samples, meanwhile forwarding
;FM-related data to YM2612. This means, the driver does not need to worry about
;waiting for YM2612 to be free to accept data, but it does mean that the sound
;driver does not have direct or timely access to the hardware itself.
;
;Dual PCM FlexEd allows the driver to play high quality PCM samples at varying
;volumes and frequencies, meanwhile preserving DAC quality during DMAs and
;offering 2 PCM channels for playback. The driver attempts to take full
;advantage of the features of Dual PCM FlexEd, even offering looping sample
;support.
;
;The tracker format itself is very simple, based upon headers, commands, notes
;and delays. These help build up all the music data used in games. The format is
;better explained in another text file.
;
;The driver also supports frequency modulation, and for PSG, amplitude
;modulation as well. Customized volume fades, multiple tempo algorithms, music
;pausing, speed shoes tempo, "underwater mode", LFO, SSG-EG, advanced condition
;modes, 50hz "fix", and spindash sound effects. There are of course other
;smaller and less notable features and optimizations too.


***** UNDERWATER MODE *****

;This is a special FM trick created by ValleyBell that makes music sound as if
;it was playing underwater. This effect works only for FM channels, but it can
;create a very convincing effect, if utilized well. It works simply by altering
;total level values depending on an algorithm. This feature can be enabled
;during normal gameplay at any point, so it can be used for actual water levels!


***** MODULATION *****

;The modulation algorithm is a fixed and optimized version from SMPS 68K Type 1.
;The only difference is that, when the step is reversed, the counter is
;immediately decremented, instead of waiting for 1 frame. This often will not
;affect the modulation a lot though, but it is good to keep in mind.
;
;Here's a quick rundown on the modulation algorithm. Modulation delay gets
;checked first, and if non-zero, it gets decremented, and the algorithm is
;exited. If it was zero, then modulation speed is decremented (exit if nonzero).
;Next, the modulation speed is reset, and counter is checked. If zero, the
;counter is reset and the step offset is negated. Then the modulation counter is
;decremented, and the step offset is loaded and extended to a word. Modulation
;frequency is added to it, and saved back. Then, the real frequency is added,
;and the frequency is updated on the hardware.
;
;This algorithm allows for basic pitch slides and a few more advanced slides,
;but it is way too simple for anything advanced.


***** DEBUGGING *****

;Since the driver can not spit out understandable error reports by default, I
;have instead constructed some basic error checking and debugging modules with
;the help of Vladikcomper's error debugger. While these error checkers are not
;gonna solve each case just like so, it should help you locate the issue in most
;cases.
;
;It is entirely possible however, that you do not figure out what is causing a
;specific issue, or that you found a driver bug. In these cases, please open up
;an issue on the project GitHub page (linked below). Provide as much information
;as you can, including but not limited to; Error screen (screenshot), music file
;causing the issue, a test ROM, and sound driver files in a zip format. If you
;fail to provide enough information, your issue may be closed without further
;consideration. Do not feel compelled to share your code publicly though, you
;can also message Natsumi directly through other means, and share to them
;more information.


***** GITHUB *****

;Here is a link to GitHub page for this project:
; -> https://github.com/TheRetroSnake/AMPS
