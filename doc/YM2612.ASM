********************************************************************************
*                                                                              *
*       File: AMPS YM2612                                                      *
*       Date: 18.01.21                                                         *
*       Last: 19.04.14                                                         *
*                                                                              *
********************************************************************************

***** INTRO *****

;YM2612 is the main sound chip on the Mega Drive. While it is not a chip with
;amazing sound capabilities, its complexity allows you to produce a wide variety
;of sounds, allowing for very rich music. With total of 6 sound channels you
;have many options for making great sounding music. That being said, AMPS uses
;uFM6 for Dual PCM FlexEd and does not support it as an FM channel. This
;document will tell you about how the sound driver handles FM. There are a lot
;of resources about how YM2612 works, which will go more in-depth about it.


***** CHANNEL UPDATE *****

;Whenever the channel tracker is not read, modulation is performed, and if
;volume update is queued, this is done as well. Since updating volume and
;frequency is much slower (and because we need to stop Dual PCM FlexEd for
;this), they are updated only when necessary. This can lead into issues if
;frequency is updated outside of playing notes or modulation. However, the
;driver does not allow this under normal conditions.
;
;Tracker reading is a little more involved. First, the normal tracker update
;process takes place. After, unless note is held, note-off is sent to YM. The
;note and delay are processed, and then FM frequency gets updated, and unless
;note is held or rest was played, note is turned on again, and finally if
;needed, volume is updated. There is short time between note-off and note-on,
;which might cause the music to sound slightly different depending on this
;delay. Because the driver is custom, this delay will not match SMPS 68K drivers
;necessarily.


***** UPDATE VOLUME *****

;FM volume updating is a process to update the TL registers accordingly. Since
;the underwater mode edits nons-lot registers, it is important to update all of
;them at once. The underwater mode uses the algorithm and feedback to change TL
;levels. For slot TL operators, only algorithm is used, but for nons-lots, both
;are used. Those are added to base TL level, and in slot operators, channel
;volume and master volume are also added. Then, the slot operator is also capped
;to $7F (silence), and it is updated to YM. This same process happens with voice
;updates too, but in a more optimized form.


***** UPDATE VOICE *****

;FM channels voice is updated only when the voice ID is changed through a
;command, or an interrupting SFX channel stopped playing. This ensures that
;voices are updated only when necessary. The update process is fairly
;complicated, so I am going to give a brief version.
;
;To optimize the update process (after all, it is one of the slowest things in
;the entire driver!), there are no calls to routines for handling YM commands.
;Instead, there is enough space reserved in stack for all the data. This
;however, means that you can not get away with reserving a small space for the
;stack in your game. So, most of the registers just get immediately copied
;to stack, this is a very simple process. Then, TL operators get processed. This
;should work exactly like when updating volume, so refer to that. Afterwards,
;panning is put on stack.
;
;The next piece of code then writes this to YM. First though, it gets the right
;YM 'part', and resolves channel. Z80 is stopped and a fast loop is entered.
;This loop writes the part and data. Then it gets the register, adds channel
;offset, and writes it out, looping for all bytes entered. Finally, FF is
;written, signifying Dual PCM the end of cue. Z80 is returned and stack is
;fixed. This is a relatively time consuming process, but it allows for faster
;execution compared to SMPS.


**** WRITE YM REGISTERS *****

;Because of Dual PCM FlexEd, writing YM register data directly will be
;dangerous. The driver uses fast optimized code to do high-quality PCM output.
;This will not like us playing ball with the YM2612 directly. So instead, we
;must write to this 'cue', just a list of registers and data (and part), that
;Dual PCM FlexEd will, on its own time, write to YM. This is a good thing
;however, because it actually makes our 68k code faster, since we do not have to
;wait for YM2612 to not be busy. We would have to stop Z80 anyway to access YM,
;so why not?!
;
;So quite simply, we directly write into Z80 RAM, where Dual PCM FlexEd expects
;it. It uses 2 buffers which switch each frame, so not to overwrite each other
;accidentally.
