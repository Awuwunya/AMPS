; ---------------------------------------------------------------------------
; Pattern load cues - index
; ---------------------------------------------------------------------------
	dc.w PLC_Main-ArtLoadCues, PLC_Main2-ArtLoadCues
	dc.w PLC_Explode-ArtLoadCues, PLC_GameOver-ArtLoadCues
	dc.w PLC_GHZ-ArtLoadCues, PLC_GHZ2-ArtLoadCues
	dc.w PLC_LZ-ArtLoadCues, PLC_LZ2-ArtLoadCues
	dc.w PLC_MZ-ArtLoadCues, PLC_MZ2-ArtLoadCues
	dc.w PLC_SLZ-ArtLoadCues, PLC_SLZ2-ArtLoadCues
	dc.w PLC_SYZ-ArtLoadCues, PLC_SYZ2-ArtLoadCues
	dc.w PLC_SBZ-ArtLoadCues, PLC_SBZ2-ArtLoadCues
	dc.w PLC_TitleCard-ArtLoadCues,	PLC_Boss-ArtLoadCues
	dc.w PLC_Signpost-ArtLoadCues, PLC_Warp-ArtLoadCues
	dc.w PLC_SpeStage-ArtLoadCues, PLC_GHZAnimals-ArtLoadCues
	dc.w PLC_LZAnimals-ArtLoadCues,	PLC_MZAnimals-ArtLoadCues
	dc.w PLC_SLZAnimals-ArtLoadCues, PLC_SYZAnimals-ArtLoadCues
	dc.w PLC_SBZAnimals-ArtLoadCues, PLC_SpeStResult-ArtLoadCues
	dc.w PLC_Ending-ArtLoadCues, PLC_TryAgain-ArtLoadCues
	dc.w PLC_EggmanSBZ2-ArtLoadCues, PLC_FZBoss-ArtLoadCues
; ---------------------------------------------------------------------------
; Pattern load cues - standard block 1
; ---------------------------------------------------------------------------
PLC_Main:	dc.w 4
		dc.l Nem_Lamp		; lamppost
		dc.w $F400
		dc.l Nem_Hud		; HUD
		dc.w $D940
		dc.l Nem_Lives		; lives	counter
		dc.w $FA80
		dc.l Nem_Ring		; rings
		dc.w $F640
		dc.l Nem_Points		; points from enemy
		dc.w $F2E0
; ---------------------------------------------------------------------------
; Pattern load cues - standard block 2
; ---------------------------------------------------------------------------
PLC_Main2:	dc.w 2
		dc.l Nem_Monitors	; monitors
		dc.w $D000
		dc.l Nem_Shield		; shield
		dc.w $A820
		dc.l Nem_Stars		; invincibility	stars
		dc.w $AB80
; ---------------------------------------------------------------------------
; Pattern load cues - explosion
; ---------------------------------------------------------------------------
PLC_Explode:	dc.w 0
		dc.l Nem_Explode	; explosion
		dc.w $B400
; ---------------------------------------------------------------------------
; Pattern load cues - game/time	over
; ---------------------------------------------------------------------------
PLC_GameOver:	dc.w 0
		dc.l Nem_GameOver	; game/time over
		dc.w $ABC0
; ---------------------------------------------------------------------------
; Pattern load cues - Green Hill
; ---------------------------------------------------------------------------
PLC_GHZ:	dc.w $B
		dc.l Nem_GHZ_1st	; GHZ main patterns
		dc.w 0
		dc.l Nem_GHZ_2nd	; GHZ secondary	patterns
		dc.w $39A0
		dc.l Nem_Stalk		; flower stalk
		dc.w $6B00
		dc.l Nem_PplRock	; purple rock
		dc.w $7A00
		dc.l Nem_Crabmeat	; crabmeat enemy
		dc.w $8000
		dc.l Nem_Buzz		; buzz bomber enemy
		dc.w $8880
		dc.l Nem_Chopper	; chopper enemy
		dc.w $8F60
		dc.l Nem_Newtron	; newtron enemy
		dc.w $9360
		dc.l Nem_Motobug	; motobug enemy
		dc.w $9E00
		dc.l Nem_Spikes		; spikes
		dc.w $A360
		dc.l Nem_HSpring	; horizontal spring
		dc.w $A460
		dc.l Nem_VSpring	; vertical spring
		dc.w $A660
PLC_GHZ2:	dc.w 5
		dc.l Nem_Swing		; swinging platform
		dc.w $7000
		dc.l Nem_Bridge		; bridge
		dc.w $71C0
		dc.l Nem_SpikePole	; spiked pole
		dc.w $7300
		dc.l Nem_Ball		; giant	ball
		dc.w $7540
		dc.l Nem_GhzWall1	; breakable wall
		dc.w $A1E0
		dc.l Nem_GhzWall2	; normal wall
		dc.w $6980
; ---------------------------------------------------------------------------
; Pattern load cues - Labyrinth
; ---------------------------------------------------------------------------
PLC_LZ:		dc.w $B
		dc.l Nem_LZ		; LZ main patterns
		dc.w 0
		dc.l Nem_LzBlock1	; block
		dc.w $3C00
		dc.l Nem_LzBlock2	; blocks
		dc.w $3E00
		dc.l Nem_Splash		; waterfalls and splash
		dc.w $4B20
		dc.l Nem_Water		; water	surface
		dc.w $6000
		dc.l Nem_LzSpikeBall	; spiked ball
		dc.w $6200
		dc.l Nem_FlapDoor	; flapping door
		dc.w $6500
		dc.l Nem_Bubbles	; bubbles and numbers
		dc.w $6900
		dc.l Nem_LzBlock3	; block
		dc.w $7780
		dc.l Nem_LzDoor1	; vertical door
		dc.w $7880
		dc.l Nem_Harpoon	; harpoon
		dc.w $7980
		dc.l Nem_Burrobot	; burrobot enemy
		dc.w $94C0
PLC_LZ2:	dc.w $C
		dc.l Nem_LzPole		; pole that breaks
		dc.w $7BC0
		dc.l Nem_LzDoor2	; large	horizontal door
		dc.w $7CC0
		dc.l Nem_LzWheel	; wheel
		dc.w $7EC0
		dc.l Nem_Gargoyle	; gargoyle head
		dc.w $5D20
		dc.l Nem_LzSonic	; Sonic	holding	his breath
		dc.w $8800
		dc.l Nem_LzPlatfm	; rising platform
		dc.w $89E0
		dc.l Nem_Orbinaut	; orbinaut enemy
		dc.w $8CE0
		dc.l Nem_Jaws		; jaws enemy
		dc.w $90C0
		dc.l Nem_LzSwitch	; switch
		dc.w $A1E0
		dc.l Nem_Cork		; cork block
		dc.w $A000
		dc.l Nem_Spikes		; spikes
		dc.w $A360
		dc.l Nem_HSpring	; horizontal spring
		dc.w $A460
		dc.l Nem_VSpring	; vertical spring
		dc.w $A660
; ---------------------------------------------------------------------------
; Pattern load cues - Marble
; ---------------------------------------------------------------------------
PLC_MZ:		dc.w 9
		dc.l Nem_MZ		; MZ main patterns
		dc.w 0
		dc.l Nem_MzMetal	; metal	blocks
		dc.w $6000
		dc.l Nem_MzFire		; fireballs
		dc.w $68A0
		dc.l Nem_Swing		; swinging platform
		dc.w $7000
		dc.l Nem_MzGlass	; green	glassy block
		dc.w $71C0
		dc.l Nem_Lava		; lava
		dc.w $7500
		dc.l Nem_Buzz		; buzz bomber enemy
		dc.w $8880
		dc.l Nem_Yadrin		; yadrin enemy
		dc.w $8F60
		dc.l Nem_Basaran	; basaran enemy
		dc.w $9700
		dc.l Nem_Cater		; caterkiller enemy
		dc.w $9FE0
PLC_MZ2:	dc.w 4
		dc.l Nem_MzSwitch	; switch
		dc.w $A260
		dc.l Nem_Spikes		; spikes
		dc.w $A360
		dc.l Nem_HSpring	; horizontal spring
		dc.w $A460
		dc.l Nem_VSpring	; vertical spring
		dc.w $A660
		dc.l Nem_MzBlock	; green	stone block
		dc.w $5700
; ---------------------------------------------------------------------------
; Pattern load cues - Star Light
; ---------------------------------------------------------------------------
PLC_SLZ:	dc.w 8
		dc.l Nem_SLZ		; SLZ main patterns
		dc.w 0
		dc.l Nem_Bomb		; bomb enemy
		dc.w $8000
		dc.l Nem_Orbinaut	; orbinaut enemy
		dc.w $8520
		dc.l Nem_MzFire		; fireballs
		dc.w $9000
		dc.l Nem_SlzBlock	; block
		dc.w $9C00
		dc.l Nem_SlzWall	; breakable wall
		dc.w $A260
		dc.l Nem_Spikes		; spikes
		dc.w $A360
		dc.l Nem_HSpring	; horizontal spring
		dc.w $A460
		dc.l Nem_VSpring	; vertical spring
		dc.w $A660
PLC_SLZ2:	dc.w 5
		dc.l Nem_Seesaw		; seesaw
		dc.w $6E80
		dc.l Nem_Fan		; fan
		dc.w $7400
		dc.l Nem_Pylon		; foreground pylon
		dc.w $7980
		dc.l Nem_SlzSwing	; swinging platform
		dc.w $7B80
		dc.l Nem_SlzCannon	; fireball launcher
		dc.w $9B00
		dc.l Nem_SlzSpike	; spikeball
		dc.w $9E00
; ---------------------------------------------------------------------------
; Pattern load cues - Spring Yard
; ---------------------------------------------------------------------------
PLC_SYZ:	dc.w 4
		dc.l Nem_SYZ		; SYZ main patterns
		dc.w 0
		dc.l Nem_Crabmeat	; crabmeat enemy
		dc.w $8000
		dc.l Nem_Buzz		; buzz bomber enemy
		dc.w $8880
		dc.l Nem_Yadrin		; yadrin enemy
		dc.w $8F60
		dc.l Nem_Roller		; roller enemy
		dc.w $9700
PLC_SYZ2:	dc.w 7
		dc.l Nem_Bumper		; bumper
		dc.w $7000
		dc.l Nem_SyzSpike1	; large	spikeball
		dc.w $72C0
		dc.l Nem_SyzSpike2	; small	spikeball
		dc.w $7740
		dc.l Nem_Cater		; caterkiller enemy
		dc.w $9FE0
		dc.l Nem_LzSwitch	; switch
		dc.w $A1E0
		dc.l Nem_Spikes		; spikes
		dc.w $A360
		dc.l Nem_HSpring	; horizontal spring
		dc.w $A460
		dc.l Nem_VSpring	; vertical spring
		dc.w $A660
; ---------------------------------------------------------------------------
; Pattern load cues - Scrap Brain
; ---------------------------------------------------------------------------
PLC_SBZ:	dc.w $B
		dc.l Nem_SBZ		; SBZ main patterns
		dc.w 0
		dc.l Nem_Stomper	; moving platform and stomper
		dc.w $5800
		dc.l Nem_SbzDoor1	; door
		dc.w $5D00
		dc.l Nem_Girder		; girder
		dc.w $5E00
		dc.l Nem_BallHog	; ball hog enemy
		dc.w $6040
		dc.l Nem_SbzWheel1	; spot on large	wheel
		dc.w $6880
		dc.l Nem_SbzWheel2	; wheel	that grabs Sonic
		dc.w $6900
		dc.l Nem_SyzSpike1	; large	spikeball
		dc.w $7220
		dc.l Nem_Cutter		; pizza	cutter
		dc.w $76A0
		dc.l Nem_FlamePipe	; flaming pipe
		dc.w $7B20
		dc.l Nem_SbzFloor	; collapsing floor
		dc.w $7EA0
		dc.l Nem_SbzBlock	; vanishing block
		dc.w $9860
PLC_SBZ2:	dc.w $C
		dc.l Nem_Cater		; caterkiller enemy
		dc.w $5600
		dc.l Nem_Bomb		; bomb enemy
		dc.w $8000
		dc.l Nem_Orbinaut	; orbinaut enemy
		dc.w $8520
		dc.l Nem_SlideFloor	; floor	that slides away
		dc.w $8C00
		dc.l Nem_SbzDoor2	; horizontal door
		dc.w $8DE0
		dc.l Nem_Electric	; electric orb
		dc.w $8FC0
		dc.l Nem_TrapDoor	; trapdoor
		dc.w $9240
		dc.l Nem_SbzFloor	; collapsing floor
		dc.w $7F20
		dc.l Nem_SpinPform	; small	spinning platform
		dc.w $9BE0
		dc.l Nem_LzSwitch	; switch
		dc.w $A1E0
		dc.l Nem_Spikes		; spikes
		dc.w $A360
		dc.l Nem_HSpring	; horizontal spring
		dc.w $A460
		dc.l Nem_VSpring	; vertical spring
		dc.w $A660
; ---------------------------------------------------------------------------
; Pattern load cues - title card
; ---------------------------------------------------------------------------
PLC_TitleCard:	dc.w 0
		dc.l Nem_TitleCard
		dc.w $B000
; ---------------------------------------------------------------------------
; Pattern load cues - act 3 boss
; ---------------------------------------------------------------------------
PLC_Boss:	dc.w 5
		dc.l Nem_Eggman		; Eggman main patterns
		dc.w $8000
		dc.l Nem_Weapons	; Eggman's weapons
		dc.w $8D80
		dc.l Nem_Prison		; prison capsule
		dc.w $93A0
		dc.l Nem_Bomb		; bomb enemy (gets overwritten)
		dc.w $A300
		dc.l Nem_SlzSpike	; spikeball (SLZ boss)
		dc.w $A300
		dc.l Nem_Exhaust	; exhaust flame
		dc.w $A540
; ---------------------------------------------------------------------------
; Pattern load cues - act 1/2 signpost
; ---------------------------------------------------------------------------
PLC_Signpost:	dc.w 2
		dc.l Nem_SignPost	; signpost
		dc.w $D000
		dc.l Nem_Bonus		; hidden bonus points
		dc.w $96C0
		dc.l Nem_BigFlash	; giant	ring flash effect
		dc.w $8C40
; ---------------------------------------------------------------------------
; Pattern load cues - beta special stage warp effect
; ---------------------------------------------------------------------------
PLC_Warp:	dc.w 0
		dc.l Nem_Warp
		dc.w $A820
; ---------------------------------------------------------------------------
; Pattern load cues - special stage
; ---------------------------------------------------------------------------
PLC_SpeStage:	dc.w $10
		dc.l Nem_SSBgCloud	; bubble and cloud background
		dc.w 0
		dc.l Nem_SSBgFish	; bird and fish	background
		dc.w $A20
		dc.l Nem_SSWalls	; walls
		dc.w $2840
		dc.l Nem_Bumper		; bumper
		dc.w $4760
		dc.l Nem_SSGOAL		; GOAL block
		dc.w $4A20
		dc.l Nem_SSUpDown	; UP and DOWN blocks
		dc.w $4C60
		dc.l Nem_SSRBlock	; R block
		dc.w $5E00
		dc.l Nem_SS1UpBlock	; 1UP block
		dc.w $6E00
		dc.l Nem_SSEmStars	; emerald collection stars
		dc.w $7E00
		dc.l Nem_SSRedWhite	; red and white	block
		dc.w $8E00
		dc.l Nem_SSGhost	; ghost	block
		dc.w $9E00
		dc.l Nem_SSWBlock	; W block
		dc.w $AE00
		dc.l Nem_SSGlass	; glass	block
		dc.w $BE00
		dc.l Nem_SSEmerald	; emeralds
		dc.w $EE00
		dc.l Nem_SSZone1	; ZONE 1 block
		dc.w $F2E0
		dc.l Nem_SSZone2	; ZONE 2 block
		dc.w $F400
		dc.l Nem_SSZone3	; ZONE 3 block
		dc.w $F520
		dc.l Nem_SSZone4	; ZONE 4 block
		dc.w $F2E0
		dc.l Nem_SSZone5	; ZONE 5 block
		dc.w $F400
		dc.l Nem_SSZone6	; ZONE 6 block
		dc.w $F520
; ---------------------------------------------------------------------------
; Pattern load cues - GHZ animals
; ---------------------------------------------------------------------------
PLC_GHZAnimals:	dc.w 1
		dc.l Nem_Rabbit		; rabbit
		dc.w $B000
		dc.l Nem_Flicky		; flicky
		dc.w $B240
; ---------------------------------------------------------------------------
; Pattern load cues - LZ animals
; ---------------------------------------------------------------------------
PLC_LZAnimals:	dc.w 1
		dc.l Nem_BlackBird	; blackbird
		dc.w $B000
		dc.l Nem_Seal		; seal
		dc.w $B240
; ---------------------------------------------------------------------------
; Pattern load cues - MZ animals
; ---------------------------------------------------------------------------
PLC_MZAnimals:	dc.w 1
		dc.l Nem_Squirrel	; squirrel
		dc.w $B000
		dc.l Nem_Seal		; seal
		dc.w $B240
; ---------------------------------------------------------------------------
; Pattern load cues - SLZ animals
; ---------------------------------------------------------------------------
PLC_SLZAnimals:	dc.w 1
		dc.l Nem_Pig		; pig
		dc.w $B000
		dc.l Nem_Flicky		; flicky
		dc.w $B240
; ---------------------------------------------------------------------------
; Pattern load cues - SYZ animals
; ---------------------------------------------------------------------------
PLC_SYZAnimals:	dc.w 1
		dc.l Nem_Pig		; pig
		dc.w $B000
		dc.l Nem_Chicken	; chicken
		dc.w $B240
; ---------------------------------------------------------------------------
; Pattern load cues - SBZ animals
; ---------------------------------------------------------------------------
PLC_SBZAnimals:	dc.w 1
		dc.l Nem_Rabbit		; rabbit
		dc.w $B000
		dc.l Nem_Chicken	; chicken
		dc.w $B240
; ---------------------------------------------------------------------------
; Pattern load cues - special stage results screen
; ---------------------------------------------------------------------------
PLC_SpeStResult:dc.w 1
		dc.l Nem_ResultEm	; emeralds
		dc.w $A820
		dc.l Nem_MiniSonic	; mini Sonic
		dc.w $AA20
; ---------------------------------------------------------------------------
; Pattern load cues - ending sequence
; ---------------------------------------------------------------------------
PLC_Ending:	dc.w $E
		dc.l Nem_GHZ_1st	; GHZ main patterns
		dc.w 0
		dc.l Nem_GHZ_2nd	; GHZ secondary	patterns
		dc.w $39A0
		dc.l Nem_Stalk		; flower stalk
		dc.w $6B00
		dc.l Nem_EndFlower	; flowers
		dc.w $7400
		dc.l Nem_EndEm		; emeralds
		dc.w $78A0
		dc.l Nem_EndSonic	; Sonic
		dc.w $7C20
		dc.l Nem_EndEggman	; Eggman's death (unused)
		dc.w $A480
		dc.l Nem_Rabbit		; rabbit
		dc.w $AA60
		dc.l Nem_Chicken	; chicken
		dc.w $ACA0
		dc.l Nem_BlackBird	; blackbird
		dc.w $AE60
		dc.l Nem_Seal		; seal
		dc.w $B0A0
		dc.l Nem_Pig		; pig
		dc.w $B260
		dc.l Nem_Flicky		; flicky
		dc.w $B4A0
		dc.l Nem_Squirrel	; squirrel
		dc.w $B660
		dc.l Nem_EndStH		; "SONIC THE HEDGEHOG"
		dc.w $B8A0
; ---------------------------------------------------------------------------
; Pattern load cues - "TRY AGAIN" and "END" screens
; ---------------------------------------------------------------------------
PLC_TryAgain:	dc.w 2
		dc.l Nem_EndEm		; emeralds
		dc.w $78A0
		dc.l Nem_TryAgain	; Eggman
		dc.w $7C20
		dc.l Nem_CreditText	; credits alphabet
		dc.w $B400
; ---------------------------------------------------------------------------
; Pattern load cues - Eggman on SBZ 2
; ---------------------------------------------------------------------------
PLC_EggmanSBZ2:	dc.w 2
		dc.l Nem_SbzBlock	; block
		dc.w $A300
		dc.l Nem_Sbz2Eggman	; Eggman
		dc.w $8000
		dc.l Nem_LzSwitch	; switch
		dc.w $9400
; ---------------------------------------------------------------------------
; Pattern load cues - final boss
; ---------------------------------------------------------------------------
PLC_FZBoss:	dc.w 4
		dc.l Nem_FzEggman	; Eggman after boss
		dc.w $7400
		dc.l Nem_FzBoss		; FZ boss
		dc.w $6000
		dc.l Nem_Eggman		; Eggman main patterns
		dc.w $8000
		dc.l Nem_Sbz2Eggman	; Eggman without ship
		dc.w $8E00
		dc.l Nem_Exhaust	; exhaust flame
		dc.w $A540
		even