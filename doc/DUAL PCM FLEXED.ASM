********************************************************************************
*                                                                              *
*       File: DUAL PCM                                                         *
*       Date: 18.03.28                                                         *
*       Last: 19.04.14                                                         *
*                                                                              *
********************************************************************************

***** INTRO *****

;Dual PCM FlexEd is a Z80-based two channel PCM playback driver, with pitch and
;volume control. It also supports looped samples, reversed samples, and sample
;filters. I will not go through a lot of technical information about the driver
;itself; you can find the documentation included in the download. Instead, I
;will be talking about how AMPS implements Dual PCM FlexEd support, and how you
;can effectively use its features in your tracker files.


***** SAMPLE FILTERS *****

;AMPS has a very naive implementation of sample filters. It does not attempt to
;correct them for SFX, or have contextual filter swapping (such as underwater).
;You can however choose a filter when playing music yourself with a command. You
;can also attempt to create a custom solution, but keep in mind that I am not
;going to tech support them.


***** PLAYING NOTES *****

;Playing notes is a special case for DAC, as there are 2 modes; Sample and Pitch
;modes. These allow you to choose whether notes represent samples or pitches.
;This provides you easy access to either set when necessary, and you can still
;access the other with commands (sVoice & ssFreq & ssFreqNote). These modes can
;be toggled with sModeSampDAC and sModePitchDAC.
;
;In sample mode, the sample is picked up from SampleList, much like when you use
;sVoice, but now you have access to $60 samples ($80 to $DF), and you may switch
;them on next note-on. You will have to change pitch by using ssFreq.
;
;In pitch mode, you have access to the dFreqDAC table, and the note you play
;will pick the appropriate frequency from that table, and will use the last
;sample used (played with sample mode or chosen with sVoice).


***** CHANNEL UPDATE *****

;Channel updates are much alike to FM, but there is no "note on" behavior in
;Dual PCM FlexEd, so any time we would note on or off, we just change what
;sample is playing. Note offs always default to the Stop sample, and therefore,
;we do not also need to note off before updating the sample.


***** UPDATE VOLUME *****

;AMPS uses $80 volume levels for Dual PCM FlexEd, and the volume is capped to
;silent if it's out of range. AMPS however does not attempt to fix the volume to
;maximum if it underflowed. The volume update only really edits 1 Z80
;instruction and saves the volume byte, so its not all that exciting. Dual PCM
;FlexEd will apply sample filters on top of the volume, so you may have to be
;careful about how you apply volume in such cases.


***** SAMPLE DEFINITIONS *****

;AMPS uses a fairly simplistic model for defining sample properties. It does not
;allow mixing of properties or changing them on the fly. The sample information
;is stored in a table which is referenced by various pieces of code. A table
;definition will first define frequency offset, then normal sample, and finally
;the loop sample. Alternatively, sample may define additional parameter to
;supply a custom name. Here is an example definition:

	sample $00C0, Tom, Stop, LowTom

;Here we see a sample with name 'Tom', and no loop sample, that is called
;'dLowTom'. Here is a rundown of the bytes the table actually holds:
;
;$00 - 1 byte - Normal forwards sample bank address low byte
;$01 - 1 byte - Normal forwards sample bank address high byte
;$02 - 1 byte - Normal forwards sample bank number
;$03 - 1 byte - Normal backwards sample bank address low byte
;$04 - 1 byte - Normal backwards sample bank address high byte
;$05 - 1 byte - Normal backwards sample bank number
;$06 - 1 byte - Loop forwards sample bank address low byte
;$07 - 1 byte - Loop forwards sample bank address high byte
;$08 - 1 byte - Loop forwards sample bank number
;$09 - 1 byte - Loop backwards sample bank address low byte
;$0A - 1 byte - Loop backwards sample bank address high byte
;$0B - 1 byte - Loop backwards sample bank number
;$0C - 1 word - Frequency offset word
;$0E - 1 word - Padding (unused)
