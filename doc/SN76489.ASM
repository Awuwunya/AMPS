********************************************************************************
*                                                                              *
*       File: AMPS SN76489                                                     *
*       Date: 18.01.21                                                         *
*       Last: 18.01.21                                                         *
*                                                                              *
********************************************************************************

***** INTRO *****

;SN76489 is the second sound chip on the Mega Drive, provided for backwards
;compatibility for the Master System. However, this sound chip provides useful
;for music, as it can be used to create hi-hats or additional tones. I am not
;going to go deep into how SN works, because there are plenty of resources for
;you to check out. Instead, I am going to be telling you about how the driver
;handles PSG channels.


***** CHANNEL UPDATE *****

;Whenever the tracker is not read, modulation and envelopes are processed.
;Unlike FM or DAC, the frequency and volume are always updated each time. This
;makes the code simpler and more resistant to bugs, but it also makes the driver
;somewhat slower. Nevertheless, updating PSG channels is fairly quick, so this
;is not an issue. When the tracker is read, then frequency and volume are also
;updated and nothing special happens. Because PSG does not have any "note on"
;state, holds only prevent modulation and envelopes from resetting.


***** ABOUT FREQUENCY *****

;While this is not that special, it is good to note something. Unlike in Sonic 1
;for example, the driver does NOT make sure the upper byte of the frequnecy is
;capped! This means, if you play frequency over $3FF, this will write incorrect
;data into PSG. This may not be desired, as it can break its state (for example
;write commands on behalf of previous channels). This however, is a quirk used
;in Sonic 3 to create the instashield sound. The source has a commented out
;instruction that will properly cap the frequency. If you do not wish to use
;this quirk (and therefore not support the instashield sfx too), then uncomment
;that line and you do not have to worry about breaking other channels!


***** PSG ENVELOPES *****

;PSG envelopes are used to control the volume of the PSG note. They allow for
;light control of how the note sounds like. They are very simple and naïve.
;Effectively, each frame the envelope processor is ran, next byte is read. This
;can either be volume or command. Volumes are added to actual volume of the
;channel and master volume, and are then put into PSG. There are also few
;commands which help to direct envelope flow. Here are them listed:
;
;$80 - eReset - Resets index (start from beginning)
;$82 - eHold - Remove 1 from the index (Hold volume)
;$84xx - eLoop - xx defines the position in the envelope to jump to.
;$86 - eStop - Silences the note and stops processing.
;
;This makes the envelopes very simple addition to get extra functionality out of
;PSG. It does not make PSG sound amazing or anything, but certainly helps it be
;more useful.
