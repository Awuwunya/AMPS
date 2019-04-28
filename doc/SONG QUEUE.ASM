********************************************************************************
*                                                                              *
*       File: SONG QUEUE                                                       *
*       Date: 18.01.22                                                         *
*       Last: 19.04.14                                                         *
*                                                                              *
********************************************************************************

***** INTRO *****

;The song queue has 3 slots to play music with. The programmer is tasked to
;assign these slots in a reasonable way. Song IDs can go from $01 to $FF; $00
;is a special token to indicate an empty slot. Nonetheless, there should be
;plenty of slots for all music, SFX and commands. Those are the types of songs
;the driver supports. Commands go first, from $01 forwards. Then comes music and
;lastly SFX.


***** COMMANDS *****

;Each command is their own code block. Commands are generally used for misc
;stuff to help with controlling the music and SFX. The programmer may include
;more commands themselves, but the driver comes packaged with the following;
;
;$01 - Mus_Reset - Reset sound flags. This means, disabling underwater mode and
;       speed shoes tempo. It is completely safe to do this while music is
;       playing.
;$02 - Mus_FadeOut - Initiates the default fade out sequence.
;$03 - Mus_Stop - Stops all music and SFX playing, resets sound driver state
;       (except communications bytes!!!)
;$04 - Mus_ShoesOn - Sets speed shoes as active and changes to their tempo.
;$05 - Mus_ShoesOff - Sets speed shoes as inactive and resets to main tempo.
;$06 - Mus_ToWater - Sets underwater mode as active and issues volume updates.
;$07 - Mus_OutWater - Sets underwater mode as inactive and issues volume updates
;$08 - Mus_Pause - Pauses tracker playback on the driver.
;$09 - Mus_Unpause - Unpauses tracker playback on the driver.


***** MUSIC *****

;Playing music causes the driver and hardware state to be partially reset. This
;ensures that music will start playing correctly regardless of state, but also
;means that SFX will have a short pause too. Afterwards, the volume update is
;issued, stopping any fading in the process.
;
;You may refer to the music header in the tracker file for specific info, but
;here is explained how the code will play music. Tempo gets set first, and the
;driver makes sure to use tempo speed when tempo is active. Also, the tick
;multiplier is read and driver prepares for DAC process. DAC channels also set
;themselves up onto the sample or pitch modes. Next, FM and PSG channels are
;done, which are nearly standard SMPS anyway. The patch bank is set to the
;address right after the header data. Next, FM6 is silenced and panned centre.
;After this, all overridden music channels are set up properly, and FM gets
;keyed off and PSG muted.

***** SFX *****

;You may refer to SFX header in the tracker file for specific info, but here
;is explained how the code will play sfx. First, the driver checks for ring SFX
;speaker behavior, and plays a different SFX if necessary. Next, the SFX is
;checked for continous SFX mode. If the SFX is continous and was played last,
;its continous counter is set to channel count. Else, the SFX loop is
;initialized
;
;For each SFX channel, its type is converted into appropriate channel addresses
;(both SFX and music). SFX channel priority is checked against SFX channel. If
;the priority is lower, the SFX channel is skipped. If not, music will be
;overriden, and PSG will be muted immediately. SFX channel will also be
;cleared completely, and then intialized with the channel data.
;
;On FM and DAC channels, panning is reset to centre and written to YM. On FM,
;the release rates are also reset to max, and channel keyed off. Then, the loop
;is repeated.
