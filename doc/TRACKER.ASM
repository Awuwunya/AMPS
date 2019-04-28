********************************************************************************
*                                                                              *
*       File: AMPS TRACKER DOCUMENTATION                                       *
*       Date: 18.01.12                                                         *
*       Last: 19.04.14                                                         *
*                                                                              *
********************************************************************************

***** INTRO *****

;AMPS uses a modified tracker format originally derived from SMPS 68K. The
;format is space and time optimized to get the most performant solution.
;However, this means that the format is stricter.


***** FORMAT SPECIFICATION *****

;The music format is based on header+data structure. The header specifies how
;the data will be interpreted. Specifically, channels point to tracker data, and
;header fields will define various things about the tracker, such as channel
;count. In addition, there are 2 types: SFX and Music. They have both their own
;header type. The header does not specify the type; the ID will be a determining
;factor.
;
;The tracker data itself, is split into 3; commands, notes and delays. Commands
;start from $E0 and stop at $FF and they define behavior of the tracker. See
;more about commands below. Delays go from $01-$7F. They define how long the
;tracker will wait to play the next note. Note that, this is not in frames;
;instead, it is represented in ticks. The tick multiplier will be used to
;calculate total delay. Since delay can be at most $100 frames, any value
;greater than it will overflow. Technically, byte $00 will be treated as a
;delay, and it will always result in a delay of $100 frames, however this is not
;recommended practice!
;
;Notes go from $80 to $DF. The notes come in groups of 12. These 12 notes
;represent the notes used in piano. Specifically, as per S1SMPS2ASM example,
;they are listed as: C, C#, D, Eb, E, F, F#, G, Ab, A, Bb, B. But, there are
;actually total of 95 notes. Every step of 12 notes is 1 step in octave. This
;means, that the last octave has only 11 notes, but there are 8 octaves in
;total.
;
;PSG, however, does not have that many notes. This is kind of a special case,
;because of PSG having less possible pitches. Oddly, PSG's note scale stops at
;A5, which is also often the note used for PSG hi-hats (more on that in the SN
;doc). The rest of the notes are invalid and will lead into 'random'
;frequencies being played. It is also important to remember that pitch will
;directly affect the note being played.
;
;Note $80 is also special case, as it is hardcoded to be a rest note. What this
;means is, that no note is played, the channel is silenced.
;
;The tracker is processed each time the channel timer ticks down. Initially, FM
;and DAC channels get set to 1 (update same frame) and PSG to 2, because of a
;delay when DAC and FM gets updated (Caused by Dual PCM FlexEd). Then, these
;channels are in sync. In any other case, the delay set will be used to tick
;down. Since the channel is already updating, the delay takes place only on the
;next frame, and therefore, a delay of $01 is actually 1 frame.


***** MUSIC HEADER *****

;The music header is fairly straightforward. I am just gonna list all the bytes.
;
;$00 - 1 byte - Tickrate. Defines cTick for all the channels on this music file.
;       This value is always 1 less than in SMPS standard, but the macro takes
;       care of this.
;$01 - 1 byte - Tempo. This defines the main tempo for the music. Speed-up tempo
;       is defined in the pointer's upper 8 bits!
;$02 - 1 byte - Number of FM channels to be loaded. This value is 1 lower than
;       in SMPS standard, but the macro takes care of this.
;$03 - 1 byte - Number of PSG channels to be loaded. This value is 1 lower than
;       in SMPS standard, but the macro takes care of this.
;$04 - 1 word - Offset to DAC 1 tracker data from the start of the header.
;$06 - 1 byte - Volume for this channel.
;$07 - 1 byte - DAC sample to use for this channel. If 0, this channel is set in
;       sample mode. If non-zero, it is set to pitch mode.
;$08 - 1 word - Offset to DAC 2 tracker data from the start of the header.
;$0A - 1 byte - Volume for this channel.
;$0B - 1 byte - DAC sample to use for this channel. If 0, this channel is set in
;       sample mode. If non-zero, it is set to pitch mode.
;
;NOTE: From here on, the values are relative to the current channel. Since
;channel numbers are nondeterministic, there is no way to list the actual
;offsets in header!
;
;$00 - 1 word - Offset to FM tracker data from the start of the header.
;$02 - 1 byte - Pitch of the channel.
;$03 - 1 byte - Volume of the channel.
;
;$00 - 1 word - Offset to PSG tracker data from the start of the header.
;$02 - 1 byte - Pitch of the channel.
;$03 - 1 byte - Volume of the channel.
;$04 - 1 byte - Detune of the channel.
;$05 - 1 byte - Volume Envelope ID.
;
;The patch table will follow immediately after


***** SFX HEADER *****

;The SFX header is slightly more complicated, since channels can be defined in
;any order. Valid SFX channels are: FM3, FM4, FM5, DAC1, PSG1, PSG2 and PSG3.
;Also, since the patch table is not stored inside channel RAM anymore, SFX use
;a single hardcoded table. This saves space and makes reusing patches easier,
;but you also have to be more careful about managing them. See Patches section
;for tips! And now, the header follows:
;
;$00 - 1 byte - SFX priority level. Higher priority overrides lower. This is
;       channel-specific, so while a single channel may be unable to play, the
;       other channels still could continue.
;$01 - 1 byte - Number of SFX channels used.
;
;Now follows channel-relative data.
;
;$00 - 1 byte - Put directly into cFlags. It is recommended to set running bit.
;$01 - 1 byte - Put directly into cType. Also used to override music channels.
;       It is very important to use known safe values. A list of channel type
;       masks is avaiable in the macro.asm source file.
;$02 - 1 word - Offset to SFX tracker data from start of the header.
;$04 - 1 byte - Pitch of the channel.
;$05 - 1 byte - Volume of the channel.


***** COMMANDS *****

;$E0xx - sPan - Pan the sound channel. This applies only to FM and DAC. Use
;       built-in variables to select panning mode. xx is the panning mode.
;$E1xx - ssDetune (FDT) - Set channels frequency displacement to xx.
;$E2xx - saDetune - Add xx to channels frequency displacement.
;$E3xx - ssTranspose - Set channels pitch value to xx.
;$E4xx - saTranspose (CMBIAS) - Add xx to channels pitch value.
;$E5xx - ssTickMulCh (CMBASE) - Set tick multiplier value to xx for this channel
;$E6xx - ssTickMul (SNG_BASE) - Set tick multiplier value to xx for all channels
;$E7 - sHold (CMTAB) - Activate soft key mode. Does not attack when note is
;       played (this means, that a note, sample or modulation is not interrupted
;       when a note or delay is being played).
;$E8xx - ssTempoShoes - Set music speed shoes tempo to xx.
;$E9xx - ssTempo (TEMPO_CHG) - Set music tempo to xx.
;$EAxx - sVoice (EV) - Set Volume Envelope, sample or FM patch ID for channel.
;$EB - sModOn (VRON) - Enable software modulation.
;$EC - sModOff (VROF) - Disable software modulation.
;$EDxx - saVol (PVADD) - Add xx to channel volume.
;$EExx - ssVol - Set channel volume to xx.
;$EFxxyy - ssLFO - Enable LFO mode. TODO
;$F0wwxxyyzz - ssMod68k (FVR) - Set modulation params and enable.
;       ww: wait time
;       xx: modulation speed
;       yy: change per step
;       zz: number of steps
;$F1 - sModeSampDAC - Set DAC channel to sample mode.
;$F2 - sModePitchDAC - Set DAC channel to pitch mode.
;$F3xx - sNoisePSG (CMNOIS) - Set PSG4 noise mode for PSG3 or SFX PSG3.
;$F4xxxx - sCont - Loop until the continous SFX counter runs out. xxxx is the
;       jump back offset.
;$F5 - sStop (CMEND) - Ends current tracker execution.
;$F6xxxx - sJump (CMJUMP) - Offset tracker by xxxx.
;$F7xxyyzzzz - sLoop (CMREPT) - Offset tracker by zzzz, for yy times. xx defines
;       the loop index to use. You may not reuse the same loop index for nested
;       loop commands.
;$F8xxxx - sCall (CMCALL) - Store current tracker position, and then offset
;        tracker by xxxx. The tracker position stack is 3 calls deep.
;$F9 - sRet (CMRET) - Load the last tracker position from the stack and continue
;        execution from there.
;$FAxxyy - sComm (SET_TFLG) - Set communications byte xx to value yy.
;$FBxyzz - sCond - Get communications byte y, and compare its value to zz, using
;        condition type x. Set conditional mode based on the result. See
;        condition variables for specifics.
;$FC - sCondOff - Reset the conditional mode.
;$FDxx - sNoteTimeOut (CMGATE) - Set note-off timeout to xx frames. 0 means no
;        time out.
;$FExxyy - sCmdYM - Send value yy to YM register xx. Channel-specific.
;$FF00xx - sPlaySamp1 - Play sample on DAC1. Not a good idea if a tracker is
;        playing on DAC1 or SFX DAC 1.
;$FF01xx - sPlaySamp2 - Play sample on DAC2. Not a good idea if a tracker is
;        playing on DAC2.
;$FF02xxxx - ssFreq - Set channel frequency to xxxx. (DAC only)
;$FF03xx - ssFreqNote - Set channel frequency to note xx. (DAC only)
;$FF04 - sSpinRev - Increment spindash rev counter. Capped at 12 revs.
;$FF05 - sSpinReset - Reset spindash rev counter.
;$FF06xx - saTempoSpeed - Add xx to music speed tempo.
;$FF07xx - saTempo - Add xx to music tempo.
;$FF08xyzz - sCondReg - This works like sCond, but y refers to a RAM pointer
;       in a table, and then a byte is read from this RAM address, to be used
;       instead of communications byte.
;$FF09xx - sPlayMus (KEYSET) - Add music xx to sound queue.
;$FF0A - sRawFreqOn - Enable raw frequency mode. (FUTURE RESERVE ONLY)
;$FF0B - sRawFreqOff - Disable raw frequency mode. (FUTURE RESERVE ONLY)
;$FF0C - sSpecFM3 - Enable FM3 special mode. (FUTURE RESERVE ONLY)
;$FF0Dxx - ssFilter - Set DAC filter bank address to xx.
;$FF0E - sFreeze - Freeze 68k. (SAFE MODE ONLY)
;$FF0F - sCheck - Bring up tracker debugger at end of frame. (SAFE MODE ONLY)


***** PATCH FORMAT *****

;The FM patch format is actually a lot larger than SMPS default. This however,
;avoids a major issue: having to count up to the patch, whether by looping or
;multiplying. This is very CPU-intensive, and therefore not a great idea. AMPS
;uses a larger format of 32 bytes per patch. This makes it so, we can use a
;single shift instruction for the multiplication. With the addition of SSG-EG
;in the patch data, we now only have 3 unused bytes anyway.
;
;TIP: You can create named patches. Just pass a value into the second argument
;of the spAlgorithm macro, to generate variable pSTR. Here is an example:

	spAlgorithm	$02, Rings

;This will create pRings, and you can then use this in music or SFX. This
;does NOT mean you can mix patches from other songs however, only from the
;current song.
;
;Here is the patch format. Remember, the operator order is 1, 3, 2, 4.
;
;$00 - 1 byte - Algorithm and Feedback.
;$01 - 4 byte - Detune and Multiple.
;$05 - 4 byte - Rate Scale and Attack Rate
;$09 - 4 byte - Decay Rate and Amplitude Modulation.
;$0D - 4 byte - Sustain Rate.
;$11 - 4 byte - Sustain Level and Release Rate.
;$15 - 4 byte - SSG-EG.
;$19 - 4 byte - Total Level.
;$1D - 3 byte - Padding (except for the last patch!)
