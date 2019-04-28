********************************************************************************
*                                                                              *
*       File: AMPS COMMUNICATION BYTES                                         *
*       Date: 18.01.12                                                         *
*       Last: 19.04.14                                                         *
*                                                                              *
********************************************************************************

***** INTRO *****

;AMPS has support for up to 16 different communications bytes, used for
;interaction between the music, sfx files and the main program. It can be used
;to indicate which part the music is at, or can be used to selectively execute
;commands. This system is built into the sound driver, and is intended to be
;used to make the game and music interact with each other. For example, enemies
;could use this feature for attacks or movement; or the palette cycling code
;could use this to cycle the palette in a specific manner. You could also use
;this for art, such as an instrument that plays to the tune of the music itself.


***** PROGRAM SIDE *****

;Going to start with how the game program may interact with music first, as this
;is much simpler. The communications are referenced by the label 'mComm' by the
;program. These bytes can be modified or read any way the programmer finds best,
;as there is no special setup for them. For example, to read a byte from the
;fourth byte, you can do this:

	move.b	mComm+3.w,d0

;Simply, you can access this like any part of RAM. The driver program will
;manage the tracker side of this whole deal. It is to be noted, that when music
;is played, command flags are NOT reset. Therefore, if the music needs to use
;command flags, the programmer is required to ensure the command flags are reset
;to safe values, either in the game code or the tracker file.


***** TRACKER SIDE *****

;The tracker has multiple flags for interacting with communications bytes. They
;enable or disable a special 'mode' which selectively ignores some command flags
;in order to separate execution path or ignore certain actions. The flags for
;this mode are: sCond, sCondOff, sCondReg.
;
;While this mode is enabled, these command flags are ignored: sModOn, sModOff,
;ssMod68k, sModeSampDAC, sModePitchDAC, sCont, sStop, sJump, sLoop, sCall, sRet,
;sCmdYM
;
;You can also set communications bytes using the sComm flag. But, lets talk
;about how these flags work exactly. First of all, sCond!
;
;The sCond flag is used when you want to conditionally set the condition mode.
;The flag stores the number of the communications byte, from where we read the
;value. Then, the value is compared to the value stored with the flag, and one
;of 16 conditions (based on Motorola 68000 branching conditions) are used to
;either enable or disable condition mode.
;
;sCondReg works very similarly, except that the number of the communications
;byte is now used to refer to an offset into a table of RAM pointers. The byte
;from the RAM is then used for checking against the stored byte. Otherwise, this
;flag works exactly the same.
;
;sCondOff is used to reset the condition only. This would be equivalent to a
;sCond flag, where the condition is T. However, the flag does not do much
;processing and it is smaller, which makes it optimal.
;
;sComm sets the communications bytes themselves. Simply, they take the byte
;number and then stores the value. This actually supports up to 256 bytes, but
;since the other flags only support up to 16, it may not be as useful. You could
;still expand the communications RAM over 16 if you need more bytes.
