********************************************************************************
*                                                                              *
*       File: AMPS RAM MAP DOCUMENTATION                                       *
*       Date: 18.01.09                                                         *
*       Last: 19.04.14                                                         *
*                                                                              *
********************************************************************************

***** INTRO *****

;AMPS RAM map is based on SMPS 68k type 1 but with space optimizations and
;useful features implemented. This document will explain the main RAM, channel
;RAM and SFX RAM, and includes equivalent flags from the EasySound source code.


***** MAIN RAM *****

;$00 - 1 byte - mFlags - Various bits for storing driver state. Includes ring
;       speaker bit, speed shoes bit, underwater mode bit, and currently paused
;       flag.
;$01 - 1 byte - mCtrPal - Counter for PAL mode fix. This fix is made to ease
;       making PAL systems music play back at NTSC speeds.
;$02 - 1 long - mPatMus - Patch address for currently playing music.
;$06 - 8 byte - mComm (t_flg) - Originally EasySound had a single communications
;       byte, but AMPS has 8. This is in order to allow for more customization.
;       The communications bytes are used for song flow control and expressing
;       song state to the program.
;$0E - 1 byte - mMasterVolFM - FM master volume. Used generally by volume fades.
;$0E - 1 long - mFadeAddr - Address of the volume fade data. First byte is not
;       written to (as the longword is used as a pointer).
;$12 - 1 byte - mTempoMain - Normal tempo for music. This tempo is used when the
;       player does not have speed shoes.
;$13 - 1 byte - mTempoSpeed - Normal tempo for music. This tempo is used when
;       the player has speed shoes.
;$14 - 1 byte - mTempo (cuntst) - Current tempo for music. This tempo isa  copy
;       of the tempo we use currently.
;$15 - 1 byte - mTempoTime (rcunt) - Accumulator for tempo. Once this counter
;       overflows, delay is added to music channels.
;$16 - 3 byte - mQueue (keyflag) - Queue of sound commands for the sound driver
;       to process next time. Allows to play music, sfx, and issue commands.
;$19 - 1 byte - mMasterVolPSG - PSG master volume. Used generally by volume
;       fades.
;$1A - 1 byte - mMasterVolDAC - DAC master volume. Used generally by volume
;       fades.
;$1B - 1 byte - mSpindash - Spindash rev counter. Makes Spindash sound effect
;       get higher in pitch each time it is played.
;$1C - 1 byte - mContCtr - Continuous SFX loop counter. This byte controls
;       playing of continuous SFX loops, and is reset when such sfx is played.
;$1D - 1 byte - mContLast - ID of last Continuous SFX played. Makes sure
;       continuous SFX loops are correctly played, and if 2 of them overlap,
;       they correctly override each other.
;$1E - music - DAC1 - DAC 1 music data.
;$4A - music - DAC2 - DAC 2 music data.
;$76 - music - FM1 - FM 1 music data.
;$A2 - music - FM2 - FM 2 music data.
;$CE - music - FM3 - FM 3 music data.
;$FA - music - FM4 - FM 4 music data.
;$126 - music - FM5 - FM 5 music data.
;$152 - music - PSG1 - PSG 1 music data.
;$17E - music - PSG2 - PSG 2 music data.
;$1AA - music - PSG3 - PSG 3 music data.
;$1D6 - sfx - DAC1 - DAC 1 SFX data.
;$1F2 - sfx - FM3 - FM 3 SFX data.
;$20E - sfx - FM4 - FM 4 SFX data.
;$22A - sfx - FM5 - FM 5 SFX data.
;$246 - sfx - PSG1 - PSG 1 SFX data.
;$262 - sfx - PSG2 - PSG 2 SFX data.
;$27E - sfx - PSG3 - PSG 3 SFX data.
;$29A - Entire size of the sound driver RAM
;
;In safe mode, byte $29A is a debug flag, and size of driver RAM is $29C


***** CHANNEL RAM *****

;$00 - 1 byte - cFlags (flag) - Various flags for this channel:
;       0 - cfbMode - DAC only: If set, DAC is pitch based (note = pitch). If
;           clear, ID based (note = DAC ID).
;       0 - cfbRest (_nl) - FM and PSG: Channel resting flag. Activated if nRst
;           is played or channel timed out.
;       1 - cfbInt (_wr) - Set if channel is overridden by SFX. Music only.
;       2 - cfbHold (_tie) - Set if channel note is held. Used for changing
;           pitch of note without resetting note, or for extending delay or
;           running commands.
;       3 - cfbMod (_fvr) - If set, enables pitch modulation on the channel.
;       4 - cfbCond - If enabled, condition mode is enabled (see doc)
;       5 - cfbVol - If enabled, channel volume will be updated. Ignored for PSG
;           channels
;       7 - cfbRun (_en) - If set, channel is running a music or sfx track.
;$01 - 1 byte - cType (chan) - Channel type bits. See doc for info.
;$02 - 1 long - cData (tbpon) - Data offset of music or SFX track
;$06 - 1 byte - cPanning - FM and PSG panning flag. Controls YM panning.
;$06 - 1 byte - cEnvPos (ecount) - Envelope position for PSG channels.
;$07 - 1 byte - cDetune (fdt_freq) - Frequency offset (sign-extend to word).
;$08 - 1 byte - cPitch (bias) - Note table offset.
;$09 - 1 byte - cVolume (volm) - Channel volume. Added to respective master
;       volume, and with PSG envelope or TL to get final volume level.
;$0A - 1 byte - cTick (cbase) - Channel tick multiplier.
;$0B - 1 byte - cSample - PCM sample ID. Used with DAC pitch mode.
;$0B - 1 byte - cPatch - FM Patch ID and PSG Volume Envelope ID.
;$0C - 1 byte - cDuration (lcont) - Calculated duration. Decremented each frame.
;$0D - 1 byte - cLastDur (ecstr) - Copy of cDuration, to be used if no duration
;       is supplied.
;$0E - 2 byte - cFreq (freqb) - Note base frequency. Used for calculating real
;       frequency when playing notes.
;$10 - 1 byte - cModDelay (v_delay) - Initial delay for modulation.
;$10 - 1 long - cMod (fvr_str) - Address of modulation data. First byte is not
;       written to (as the longword is used as a pointer).
;$14 - 1 word - Modulation frequency offset. Added to base frequency and detune
;       to get actual frequency.
;$16 - 1 byte - cModSpeed (v_cont) - Number of frames until next mod step.
;$17 - 1 byte - cModStep (v_add) - This is sign-extended and added to frequency
;       offset.
;$18 - 1 byte - cModCount (v_limit) - Number of steps to do before negation.
;$19 - 3 byte - cLoop (reptr) - Loop counter. 3 different levels. See docs.
;$1A - 1 byte - cPrio - SFX priority level. Any SFX with lower priority are not
;       played.
;$1B - 1 byte - cStatPSG4 (ntype) - PSG3 SFX and Music specific flag for storing
;       PSG4 mode command.
;$1C - 1 byte - cNoteTimeCur (gate) - Note timeout counter. Counts down how many
;       frames to play a note before stopping it. Music only.
;$1D - 1 byte - cNoteTimeMain (gate_str) -  Note timeout copy. Stores the last
;       note timeout counter when playing notes. Music only.
;$1E - 1 byte - cStack (stac) - Call chain stack pointer. Used by sCall.
;       Music only.
;$1F - 1 byte - not used.
;$20 - 12 byte - Call chain offsets.
