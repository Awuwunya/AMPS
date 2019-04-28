********************************************************************************
*                                                                              *
*       File: AMPS VOLUME CONTROL                                              *
*       Date: 18.01.12                                                         *
*       Last: 19.04.20                                                         *
*                                                                              *
********************************************************************************

***** INTRO *****

;AMPS uses a system for creating custom fades. The fades are completely
;user-defined, in a way that allows you to change the volume each frame. This
;allows the programmer to create fade in, out, partial fade, or even just fade
;FM channels only for example. Therefore, this allows for much larger control
;over how it sounds like. AMPS by default comes up with the basic fade type, but
;you can easily create your own. Fades can be programmed to play when a sound ID
;gets played, or by directly calling the code. Fades are done in such way that
;it is safe to be called from anywhere. Fades can also use different actions
;when they are completed.

***** FADING DATA *****

;Fading data is fairly straightforward. Each frame will use 3 bytes to define
;volume for the current frame. First byte is the FM volume, second is DAC
;volume, and third is PSG volume. Volume updates are not an issue if the base
;volume does not change, which can save some time. For instance, Dual PCM lags
;slightly, causing audio issues when the volume level is changed, so it is a
;good idea to avoid changing its volume each frame. One thing to consider is
;that, if the volume fade data is below ROM address $10000, the fade does not
;occur. This can be an issue if your work is small, and you will have to
;introduce extra checks to make sure the low word is also not 0. Since the upper
;8 bits of the address are used for FM volume, it is not sufficient to check the
;entire longword.


***** FADING PROGRAM *****

;When a fade is loaded, and if a fade was already in process, the FM volume is
;used to find the closest matching volume (and, the first one is always picked),
;and the fading address is advanced to this position. This ensures, that while
;multiple fades may be played in succession, this does not disrupt the fading
;process, nor cause sudden jumps in volume. This however, does mean that fades
;sometimes end prematurely, and therefore should not be used to influence the
;game program without meticulous care to ensure this can cause no issues. When
;the fade is playing, it is updated each frame. The program first checks if an
;end token is met, and if so, the specified end function is executed. Else, FM
;volume is processed. If this master volume does not match the previous one,
;volume update flag is set on the channel. Then after, DAC and PSG are
;processed. While PSG channels do ignore volume the update flags, they are set
;nonetheless. This is for the programmer's convenience, incase they wish to add
;special functionality to PSG. The end functions are as follows:
;
;$80 - fEnd - Does nothing.
;$84 - fStop - This will stop the music from playing.
;$88 - fSilence - Resets master volume and issues volume updates.
;$8C - fReset - This has the function of fStop and fSilence in one.
