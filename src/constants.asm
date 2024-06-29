; Keys as they are used in $FF80 and $FF81.
; These are not set up how they are in the hardware.

; Keys (as bit numbers)
DEF KEYB_A                                   EQU 0
DEF KEYB_B                                   EQU 1
DEF KEYB_SELECT                              EQU 2
DEF KEYB_START                               EQU 3
DEF KEYB_RIGHT                               EQU 4
DEF KEYB_LEFT                                EQU 5
DEF KEYB_UP                                  EQU 6
DEF KEYB_DOWN                                EQU 7
; Keys (values)                              
DEF KEY_NONE                                 EQU 0
DEF KEY_A                                    EQU 1 << KEYB_A
DEF KEY_B                                    EQU 1 << KEYB_B
DEF KEY_SELECT                               EQU 1 << KEYB_SELECT
DEF KEY_START                                EQU 1 << KEYB_START
DEF KEY_RIGHT                                EQU 1 << KEYB_RIGHT
DEF KEY_LEFT                                 EQU 1 << KEYB_LEFT
DEF KEY_UP                                   EQU 1 << KEYB_UP
DEF KEY_DOWN                                 EQU 1 << KEYB_DOWN
                                             
; ------------------------------------------------------------
                                             
; Screen update modes                        
DEF SCRUPD_SCROLL                            EQU $01                  ; Normal level scrolling
DEF SCRUPD_NORMHAT                           EQU $02                  ; Draw Normal hat
DEF SCRUPD_BULLHAT                           EQU $03
DEF SCRUPD_JETHAT                            EQU $04
DEF SCRUPD_DRAGHAT                           EQU $05
DEF SCRUPD_NORMHAT_SEC                       EQU $06               ; Draw the secondary tiles for the normal hat
DEF SCRUPD_BULLHAT_SEC                       EQU $07
DEF SCRUPD_JETHAT_SEC                        EQU $08
DEF SCRUPD_DRAGHAT_SEC                       EQU $09
DEF SCRUPD_CREDITSBOX                        EQU $0A               ; Draw the credits textbox area
DEF SCRUPD_CRDTEXT1                          EQU $0B                 ; Draw the first row of credits
DEF SCRUPD_CRDTEXT2                          EQU $0C                 ; Draw the second row of credits
DEF SCRUPD_SAVEPIPE                          EQU $0D                 ; Animate pipes in the save select screen
                                             
; sPlHatSwitchDrawMode options               
DEF PL_HSD_PRIMARY                           EQU $00      
DEF PL_HSD_SEC                               EQU $01
DEF PL_HSD_END                               EQU $02
                                             
; Special parallax effect modes              
DEF PRX_TRAINMOUNTR                          EQU $00
DEF PRX_TRAINMAINR                           EQU $01
DEF PRX_TRAINTRACKR                          EQU $02
DEF PRX_UNUSED1                              EQU $03
DEF PRX_UNUSED0                              EQU $04
DEF PRX_BOSS0                                EQU $05
DEF PRX_BOSS1                                EQU $06
DEF PRX_BOSS2                                EQU $07
DEF PRX_BOSS3                                EQU $08
DEF PRX_TRAINMOUNTL                          EQU $09
DEF PRX_TRAINMAINL                           EQU $0A
DEF PRX_TRAINTRACKL                          EQU $0B
DEF PRX_CREDMAIN                             EQU $0C
DEF PRX_CREDROW1                             EQU $0D
DEF PRX_CREDROW2                             EQU $0E
                                             
; Static Screen event modes                  
DEF SES_TITLE                                EQU $00
DEF SES_BONUS                                EQU $01
DEF SES_ENDING                               EQU $02
                                             
                                             
; BGM playback actions                       
DEF BGMACT_FADEOUT                           EQU 8                  ; Fade out gradually the song
                                             
; Special BGM Tables (used under BGM Chunks) 
DEF BGMTBLCMD_REDIR                          EQU $00F0 ; Next table ptr in the chunk is the offset to the new chunk -- used for looping      
DEF BGMTBLCMD_END                            EQU $0000 ; The BGM ends. No more ptrs in the chunk.
                                             
; BGM Playback sound commands                
DEF BGMCMD_SETOPTREG                         EQU $F1 ; Set other register values (the default only changes pitch/frequency)
DEF BGMCMD_SETLENGTHPTR                      EQU $F2 ; Set new BGM length table ptr
DEF BGMCMD_SETPITCH                          EQU $F3 ; Set new base pitch
DEF BGMCMD_SETLOOP                           EQU $F4 ; Set loop point
DEF BGMCMD_LOOP                              EQU $F5 ; Restore loop point
DEF BGMCMD_END                               EQU $00 ; Marks the end of a command table
DEF BGMCMD_STOPALL                           EQU $F6 ; Stops all currently playing BGM and SFX.
                                                     ; Command range: $F6-$FF
DEF BGMCMD_NOP                               EQU $F1 ; Immediately skips to the next command.
                                                     ; Command range: $F1-$F5
DEF BGMCMD_SETLENGTHID                       EQU $9F ; Command will be treated as an index to the current BGM length table
                                                     ; Command range: $9F-$F0

; BGM Playback raw data commands             
DEF BGMDATACMD_MUTECH                        EQU $01 ; Mute current sound channel.
DEF BGMDATACMD_HIGHENV                       EQU $03 ; High envelop option
DEF BGMDATACMD_LOWENV                        EQU $05 ; Low envelop option
                                             
; BGM post parse commands                    
; All of these set the pitch in different ways
DEF BGMPP_NONE                               EQU $00
DEF BGMPP_01                                 EQU $01
DEF BGMPP_02                                 EQU $02
DEF BGMPP_03                                 EQU $03
DEF BGMPP_04                                 EQU $04
DEF BGMPP_05                                 EQU $05
DEF BGMPP_06                                 EQU $06
DEF BGMPP_07                                 EQU $07
DEF BGMPP_08                                 EQU $08
DEF BGMPP_09                                 EQU $09
DEF BGMPP_0A                                 EQU $0A
                                             
; ------------------------------------------------------------
                                             
; Global sound pause playback commands       
; These will trigger special actions         
DEF SNDPAUSE_NONE                            EQU 0
DEF SNDPAUSE_PAUSE                           EQU 1                         ; Play pause sound and stop all playback
DEF SNDPAUSE_UNPAUSE                         EQU 2                         ; Play unpause sound and resume all playback
DEF SNDPAUSEB_NOPAUSESFX                     EQU 7    
DEF SNDPAUSE_NOPAUSESFX                      EQU 1 << SNDPAUSEB_NOPAUSESFX ; Extra flag. If set, the pause/unpause SFX won't be played.
                                             
; ------------------------------------------------------------
; BGM / SFX indexes. Remove $1 from these to get the actual BGM / SFX Id
                                             
; Game music indexes (remove 1 to get IDs)   
DEF BGM_NONE                                 EQU $FF
DEF BGM_TITLE                                EQU $01
DEF BGM_OVERWORLD                            EQU $02
DEF BGM_WATER                                EQU $03
DEF BGM_COURSE1                              EQU $04 ; main theme
DEF BGM_COINVAULT                            EQU $05
DEF BGM_INVINCIBILE                          EQU $06
DEF BGM_COINGAME                             EQU $07 ; end of boss raining coins
DEF BGM_LIFELOST                             EQU $08
DEF BGM_SHIP                                 EQU $09
DEF BGM_LAVA                                 EQU $0A
DEF BGM_TRAIN                                EQU $0B
DEF BGM_COINBONUS                            EQU $0C
DEF BGM_LEVELCLEAR                           EQU $0D
DEF BGM_BOSSLEVEL                            EQU $0E
DEF BGM_TREASURE                             EQU $0F
DEF BGM_LAVA2                                EQU $10
DEF BGM_BOSS                                 EQU $11
DEF BGM_BOSSCLEAR                            EQU $12 ; level clear for boss levels
DEF BGM_MTTEAPOT                             EQU $13
DEF BGM_SHERBETLAND                          EQU $14
DEF BGM_RICEBEACH                            EQU $15
DEF BGM_CAVE                                 EQU $16
DEF BGM_COURSE3                              EQU $17 ; level 3
DEF BGM_HEARTBONUS                           EQU $18
DEF BGM_FINALBOSSINTRO                       EQU $19
DEF BGM_WORLDCLEAR                           EQU $1A
DEF BGM_AMBIENT                              EQU $1B
DEF BGM_TREASUREGET                          EQU $1C ; and ending jingle
DEF BGM_SYRUPCASTLE                          EQU $1D
DEF BGM_FINALLEVEL                           EQU $1E
DEF BGM_PARSLEYWOODS                         EQU $1F
DEF BGM_INTRO                                EQU $20
DEF BGM_STOVECANYON                          EQU $21
DEF BGM_COURSE32                             EQU $22
DEF BGM_SSTEACUP                             EQU $23
DEF BGM_GAMEOVER                             EQU $24
DEF BGM_TIMEOVER                             EQU $25
DEF BGM_SAVESELECT                           EQU $26
DEF BGM_ICE                                  EQU $27
DEF BGM_FINALBOSS                            EQU $28
DEF BGM_CREDITS                              EQU $29
DEF BGM_SELECTBONUS                          EQU $2A ; bonus game choice in course clear screen
DEF BGM_LEVELENTER                           EQU $2B
DEF BGM_CUTSCENE                             EQU $2C
DEF BGM_ENDINGGENIE                          EQU $2D
DEF BGM_GAMEOVER2                            EQU $2E
DEF BGM_ENDINGSTATUE                         EQU $2F
DEF BGM_FINALBOSSOUTRO                       EQU $30 ; scene before the bomb
                                             
DEF SFX1_01                                  EQU $01 ; SFX1_BUMP          ; Bump enemy
DEF SFX1_02                                  EQU $02 ; SFX1_JUMPONENEMY   ; Jump on an enemy
DEF SFX1_03                                  EQU $03 ; SFX1_LEVELDOT      ; Level Dot revealed / Title screen -> save select transition
DEF SFX1_04                                  EQU $04 ; SFX1_HEART         ; Heart box
DEF SFX1_05                                  EQU $05 ; SFX1_JUMP          ; Wario jump
DEF SFX1_06                                  EQU $06 ; SFX1_POWERUP       
DEF SFX1_07                                  EQU $07 ; SFX1_SCROLL        ; Screen scrolling / save select pipe
DEF SFX1_08                                  EQU $08 ; SFX1_1UP           
DEF SFX1_09                                  EQU $09 ; SFX1_BOSSDEAD      
DEF SFX1_0A                                  EQU $0A ; SFX1_BUMPBIG       ; Bumping into a big non-enemy actor (skull door, big blocks, ...)
DEF SFX1_0B                                  EQU $0B ; SFX1_GRAB          ; Also various other things
DEF SFX1_0C                                  EQU $0C ; SFX1_0C            ; Throw
DEF SFX1_0D                                  EQU $0D ; SFX1_ITEMBLOCKHIT  
DEF SFX1_0E                                  EQU $0E ; SFX1_GRAB2         ; Copy of $0B for hitting item boxes
DEF SFX1_0F                                  EQU $0F ; SFX1_POUNDONENEMY  ; crush attack over enemy (bull hat)
DEF SFX1_10                                  EQU $10 ; SFX1_COIN          
DEF SFX1_11                                  EQU $11 ; SFX1_ENEMYWAKE     ; stun restore
DEF SFX1_12                                  EQU $12 ; SFX1_SWIM          
DEF SFX1_13                                  EQU $13 ; SFX1_MISSILEFIRED  ; fire missile launched
DEF SFX1_14                                  EQU $14 ; SFX1_ENEMYDEAD     
DEF SFX1_15                                  EQU $15 ; SFX1_BUMPBIG2      ; copy of $0A for act coli type $02
DEF SFX1_16                                  EQU $16 ; SFX1_ENEMYHIT      ; hit enemy with dash attack
DEF SFX1_17                                  EQU $17 ; SFX1_17            
DEF SFX1_18                                  EQU $18 ; SFX1_HEADTURNA     ; head turn (save select)
DEF SFX1_19                                  EQU $19 ; SFX1_HEADTURNB     ; head turn (save select)
DEF SFX1_1A                                  EQU $1A ; SFX1_SHIPNOTICE    ; for intro
DEF SFX1_1B                                  EQU $1B ; SFX1_SHIPSIREN     ; ""
DEF SFX1_1C                                  EQU $1C ; SFX1_WARIOROW      ; ""
DEF SFX1_1D                                  EQU $1D ; SFX1_1D            
DEF SFX1_1E                                  EQU $1E ; SFX1_1E            
DEF SFX1_1F                                  EQU $1F ; SFX1_1F            
DEF SFX1_20                                  EQU $20 ; SFX1_ACTDROP       ; Dropped actor
DEF SFX1_21                                  EQU $21 ; SFX1_JUMPLAND      ; landing after a jump
DEF SFX1_22                                  EQU $22 ; SFX1_PATHDOT       ; path dot revealed
DEF SFX1_23                                  EQU $23 ; SFX1_23            
DEF SFX1_24                                  EQU $24 ; SFX1_BIGCOIN       ; 100 coin
DEF SFX1_25                                  EQU $25 ; SFX1_POWERDOWN     
DEF SFX1_26                                  EQU $26 ; SFX1_10COIN        
DEF SFX1_27                                  EQU $27 ; SFX1_27            
DEF SFX1_28                                  EQU $28 ; SFX1_28            
DEF SFX1_29                                  EQU $29 ; SFX1_ENEMYFLY      ; Fly enemy, boss bomb thrown
DEF SFX1_2A                                  EQU $2A ; SFX1_2A            
DEF SFX1_2B                                  EQU $2B ; SFX1_2B            ; Checkpoint
DEF SFX1_2C                                  EQU $2C ; SFX1_BOSSHIT       
DEF SFX1_2D                                  EQU $2D ; SFX1_2D            ; Knife hits wall
DEF SFX1_2E                                  EQU $2E ; SFX1_BOUNCEBLOCK   
DEF SFX1_2F                                  EQU $2F ; SFX1_BOMBGRAB      
DEF SFX1_30                                  EQU $30 ; SFX1_TREASUREVALUE ; ending; when treasure sums up to the total money
DEF SFX1_31                                  EQU $31 ; SFX1_31            ; coin count ending?
DEF SFX1_32                                  EQU $32 ; SFX1_GENIETALK     ; 
DEF SFX1_33                                  EQU $33 ; SFX1_33            
                                             
DEF SFX2_01                                  EQU $01 ; SFX2_NOACCESS
DEF SFX2_02                                  EQU $02 ; SFX2_COIN             ; to go along with SFX1 coin
DEF SFX2_03                                  EQU $03 ; SFX2_TIMEUPA          ; few seconds remaining
DEF SFX2_04                                  EQU $04 ; SFX2_TIMEUPB          ; 1 second remaining
DEF SFX2_05                                  EQU $05 ; SFX2_HURRYUP
DEF SFX2_06                                  EQU $06 ; SFX2_TREASUREVALUE    ; goes along with SFX1_30
                                             
DEF SFX4_01                                  EQU $01 ; SFX4_DASH         ; Dash
DEF SFX4_02                                  EQU $02 ; SFX4_GROUNDPOUND  ; Wario Ground pound, screen shakes, ...
DEF SFX4_03                                  EQU $03 ; SFX4_DASHWALL     
DEF SFX4_04                                  EQU $04 ; SFX4_DRAGONFLAME0 ; Dragon hat start / Syrup castle explosion
DEF SFX4_05                                  EQU $05 ; SFX4_DRAGONFLAME1 ; Dragon hat continue
DEF SFX4_06                                  EQU $06 ; SFX4_DRAGONFLAME2 ; copy of $05
DEF SFX4_07                                  EQU $07 ; SFX4_DRAGONFLAME3 ; copy of $04
DEF SFX4_08                                  EQU $08 ; SFX4_WALK         ; Walk SFX
DEF SFX4_09                                  EQU $09 ; SFX4_WALK_SMALL   ; Walk SFX (small Wario)
DEF SFX4_0A                                  EQU $0A ; SFX4_BLOCKHIT     ; Block cracked
DEF SFX4_0B                                  EQU $0B ; SFX4_BLOCKSMASH   ; Block destroyed
DEF SFX4_0C                                  EQU $0C ; SFX4_WATERENTER   ; Player enters water
DEF SFX4_0D                                  EQU $0D ; SFX4_WATEREXIT    ; Player exits water
DEF SFX4_0E                                  EQU $0E ; SFX4_CLING        ; Bull hat cling
DEF SFX4_0F                                  EQU $0F ; SFX4_JET          ; Jet hat fly
DEF SFX4_10                                  EQU $10 ; SFX4_10           ; Actor enters water
DEF SFX4_11                                  EQU $11 ; SFX4_11           ; Lava bubble jumps out of lava
DEF SFX4_12                                  EQU $12 ; SFX4_TITLEDROP    ; Title screen drop
DEF SFX4_13                                  EQU $13 ; SFX4_13           
DEF SFX4_14                                  EQU $14 ; SFX4_14           ; Bomb SFX
DEF SFX4_15                                  EQU $15 ; SFX4_DDREADY      ; D.D. ready to throw boomerang
DEF SFX4_16                                  EQU $16 ; SFX4_DDTHROW      ; D.D. boomerang throw
DEF SFX4_17                                  EQU $17 ; SFX4_TRAINTRACK   ; Train track
DEF SFX4_18                                  EQU $18 ; SFX4_SWITCHBLOCK  ; Small ! block
DEF SFX4_19                                  EQU $19 ; SFX4_19           ; Mt.Teapot boss run charge
DEF SFX4_UNUSED_1A                           EQU $1A ; SFX4_UNUSED_1A    
DEF SFX4_UNUSED_1B                           EQU $1B ; SFX4_UNUSED_1B    ; loud variant of fire?
                                             
DEF SFX_NONE                                 EQU $FF
                                             
                                             
; ------------------------------------------------------------
                                             
; Level list by ID                           
DEF LVL_C26                                  EQU $00
DEF LVL_C33                                  EQU $01
DEF LVL_C15                                  EQU $02
DEF LVL_C20                                  EQU $03
DEF LVL_C16                                  EQU $04
DEF LVL_C10                                  EQU $05
DEF LVL_C07                                  EQU $06
DEF LVL_C01A                                 EQU $07
DEF LVL_C17                                  EQU $08
DEF LVL_C12                                  EQU $09
DEF LVL_C13                                  EQU $0A
DEF LVL_C29                                  EQU $0B
DEF LVL_C04                                  EQU $0C
DEF LVL_C09                                  EQU $0D
DEF LVL_C03A                                 EQU $0E
DEF LVL_C02                                  EQU $0F
DEF LVL_C08                                  EQU $10
DEF LVL_C11                                  EQU $11
DEF LVL_C35                                  EQU $12
DEF LVL_C34                                  EQU $13
DEF LVL_C30                                  EQU $14
DEF LVL_C21                                  EQU $15
DEF LVL_C22                                  EQU $16
DEF LVL_C01B                                 EQU $17
DEF LVL_C19                                  EQU $18
DEF LVL_C05                                  EQU $19
DEF LVL_C36                                  EQU $1A
DEF LVL_C24                                  EQU $1B
DEF LVL_C25                                  EQU $1C
DEF LVL_C32                                  EQU $1D
DEF LVL_C27                                  EQU $1E
DEF LVL_C28                                  EQU $1F
DEF LVL_C18                                  EQU $20
DEF LVL_C14                                  EQU $21
DEF LVL_C38                                  EQU $22
DEF LVL_C39                                  EQU $23
DEF LVL_C03B                                 EQU $24
DEF LVL_C37                                  EQU $25
DEF LVL_C31A                                 EQU $26
DEF LVL_C23                                  EQU $27
DEF LVL_C40                                  EQU $28
DEF LVL_C06                                  EQU $29
DEF LVL_C31B                                 EQU $2A
DEF LVL_UNUSED_2B                            EQU $2B
DEF LVL_UNUSED_2C                            EQU $2C
DEF LVL_UNUSED_2D                            EQU $2D
DEF LVL_UNUSED_2E                            EQU $2E
DEF LVL_UNUSED_2F                            EQU $2F
DEF LVL_OVERWORLD                            EQU $30                ; Not a valid level slot -- used to check for the overworld in the map screen
DEF LVL_OVERWORLD_MTTEAPOT                   EQU $31         
DEF LVL_OVERWORLD_STOVECANYON                EQU $32
DEF LVL_OVERWORLD_PARSLEYWOODS               EQU $33
DEF LVL_OVERWORLD_SSTEACUP                   EQU $34
DEF LVL_OVERWORLD_SHERBETLAND                EQU $35
DEF LVL_OVERWORLD_SYRUPCASTLE                EQU $36
DEF LVL_OVERWORLD_BRIDGE                     EQU $37
                                             
DEF LVL_LASTVALID                            EQU $2A
                                             
; ============================================================
; Sprite flags for OBJ List (main)           
DEF OBJLSTB_OBP1                             EQU 4
DEF OBJLST_OBP1                              EQU $10
DEF OBJLSTB_XFLIP                            EQU 5 ; If set, player is facing right
DEF OBJLST_XFLIP                             EQU $20
DEF OBJLSTB_BGPRIORITY                       EQU 7 
DEF OBJLST_BGPRIORITY                        EQU $80
                                             
; Sprite flags for STATIC OBJ List, which for some reason (likely different module programmed by someone different) uses a different format
; Used with wStaticPlFlags and others.       
DEF STATIC_OBJLSTB_XFLIP                     EQU 7 ; If set, player is facing LEFT (coin bonus)
DEF STATIC_OBJLST_XFLIP                      EQU $80 ; If set, player is facing LEFT (coin bonus)
                                             
; ============================================================
; OBJ List (Main block)                      
DEF OBJ_WARIO_NONE                           EQU $00
DEF OBJ_WARIO_WALK0                          EQU $01
DEF OBJ_WARIO_WALK1                          EQU $02
DEF OBJ_WARIO_WALK2                          EQU $03
DEF OBJ_WARIO_WALK3                          EQU $04
DEF OBJ_HITBLOCK                             EQU $05
DEF OBJ_WARIO_THROW                          EQU $06
DEF OBJ_WARIO_JUMPTHROW                      EQU $07
DEF OBJ_WARIO_STAND                          EQU $08
DEF OBJ_WARIO_IDLE0                          EQU $09
DEF OBJ_WARIO_IDLE1                          EQU $0A
DEF OBJ_HAT                                  EQU $0B
DEF OBJ_UNUSED_WARIO_GROUNDPOUND             EQU $0C
DEF OBJ_JETHATFLAME0                         EQU $0D
DEF OBJ_JETHATFLAME1                         EQU $0E
DEF OBJ_JETHATFLAME2                         EQU $0F
DEF OBJ_WARIO_DUCK                           EQU $10
DEF OBJ_WARIO_DUCKWALK                       EQU $11
DEF OBJ_WARIO_CLIMB0                         EQU $12
DEF OBJ_WARIO_CLIMB1                         EQU $13
DEF OBJ_WARIO_BUMP                           EQU $14
DEF OBJ_DRAGONHATFLAME_A0                    EQU $15
DEF OBJ_DRAGONHATFLAME_A1                    EQU $16
DEF OBJ_DRAGONHATFLAME_A2                    EQU $17
DEF OBJ_WARIO_SWIM0                          EQU $18
DEF OBJ_WARIO_SWIM1                          EQU $19
DEF OBJ_WARIO_DEAD                           EQU $1A
DEF OBJ_DRAGONHATFLAME_B0                    EQU $1B
DEF OBJ_DRAGONHATFLAME_B1                    EQU $1C
DEF OBJ_DRAGONHATFLAME_B2                    EQU $1D
DEF OBJ_WARIO_SWIM2                          EQU $1E
DEF OBJ_WARIO_BUMPAIR                        EQU $1F
DEF OBJ_WARIO_JUMP                           EQU $20
DEF OBJ_WARIO_GROUNDPOUND                    EQU $21
DEF OBJ_WARIO_DASHJUMP                       EQU $22
DEF OBJ_WARIO_DASHENEMY                      EQU $23
DEF OBJ_WARIO_DASH0                          EQU $24
DEF OBJ_WARIO_DASH1                          EQU $25
DEF OBJ_WARIO_DASH2                          EQU $26
DEF OBJ_WARIO_DASH3                          EQU $27
DEF OBJ_WARIO_DASH4                          EQU $28
DEF OBJ_WARIO_DASH5                          EQU $29
DEF OBJ_WARIO_DASH6                          EQU $2A
DEF OBJ_DRAGONHATFLAME_C0                    EQU $2B
DEF OBJ_DRAGONHATFLAME_C1                    EQU $2C
DEF OBJ_DRAGONHATFLAME_C2                    EQU $2D
DEF OBJ_DRAGONHATFLAME_D0                    EQU $2E
DEF OBJ_DRAGONHATFLAME_D1                    EQU $2F
DEF OBJ_DRAGONHATFLAME_D2                    EQU $30
DEF OBJ_SMALLWARIO_WALK0                     EQU $31
DEF OBJ_SMALLWARIO_WALK1                     EQU $32
DEF OBJ_SMALLWARIO_WALK2                     EQU $33
DEF OBJ_WARIO_THUMBSUP0                      EQU $34
DEF OBJ_WARIO_THUMBSUP1                      EQU $35
DEF OBJ_BLANK_36                             EQU $36
DEF OBJ_TRROOM_ARROW                         EQU $37
DEF OBJ_SMALLWARIO_STAND                     EQU $38
DEF OBJ_SMALLWARIO_IDLE                      EQU $39
DEF OBJ_DRAGONHATFLAME_E0                    EQU $3A
DEF OBJ_DRAGONHATFLAME_E1                    EQU $3B
DEF OBJ_DRAGONHATFLAME_E2                    EQU $3C
DEF OBJ_DRAGONHATFLAME_F0                    EQU $3D
DEF OBJ_DRAGONHATFLAME_F1                    EQU $3E
DEF OBJ_DRAGONHATFLAME_F2                    EQU $3F
DEF OBJ_UNUSED_MAIN_40                       EQU $40
DEF OBJ_WARIO_GRAB                           EQU $41
DEF OBJ_SMALLWARIO_CLIMB0                    EQU $42
DEF OBJ_SMALLWARIO_CLIMB1                    EQU $43
DEF OBJ_WARIO_DUCKHOLD                       EQU $44
DEF OBJ_WARIO_DUCKWALKHOLD                   EQU $45
DEF OBJ_WARIO_DUCKTHROW                      EQU $46
DEF OBJ_SMALLWARIO_HOLD                      EQU $47
DEF OBJ_SMALLWARIO_SWIM0                     EQU $48
DEF OBJ_SMALLWARIO_SWIM1                     EQU $49
DEF OBJ_SMALLWARIO_HOLDWALK0                 EQU $4A
DEF OBJ_SMALLWARIO_HOLDWALK1                 EQU $4B
DEF OBJ_SMALLWARIO_HOLDWALK2                 EQU $4C
DEF OBJ_SMALLWARIO_HOLDJUMP                  EQU $4D
DEF OBJ_SMALLWARIO_SWIM2                     EQU $4E
DEF OBJ_WARIO_DASHFLY                        EQU $4F
DEF OBJ_SMALLWARIO_JUMP                      EQU $50
DEF OBJ_WARIO_HOLDWALK0                      EQU $51
DEF OBJ_WARIO_HOLDWALK1                      EQU $52
DEF OBJ_WARIO_HOLDWALK2                      EQU $53
DEF OBJ_WARIO_HOLDWALK3                      EQU $54
DEF OBJ_WATERSPLASH0                         EQU $55
DEF OBJ_WATERSPLASH1                         EQU $56
DEF OBJ_WATERSPLASH2                         EQU $57
DEF OBJ_WARIO_HOLD                           EQU $58
DEF OBJ_BLOCKSMASH0                          EQU $59
DEF OBJ_BLOCKSMASH1                          EQU $5A
DEF OBJ_BLOCKSMASH2                          EQU $5B
DEF OBJ_BLOCKSMASH3                          EQU $5C
DEF OBJ_BLOCKSMASH4                          EQU $5D
DEF OBJ_BLOCKSMASH5                          EQU $5E
DEF OBJ_BLOCKSMASH6                          EQU $5F
DEF OBJ_BLOCKSMASH7                          EQU $60
DEF OBJ_BLOCKSMASH8                          EQU $61
DEF OBJ_UNUSED_BLOCKSMASH9                   EQU $62
DEF OBJ_SAVESEL_HAT                          EQU $63
DEF OBJ_SMALLWARIO_LEVELCLEAR                EQU $64
DEF OBJ_SAVESEL_BOMBWARIO0                   EQU $65
DEF OBJ_SAVESEL_BOMBWARIO1                   EQU $66
DEF OBJ_SAVESEL_BOMBWARIO2                   EQU $67
DEF OBJ_SAVESEL_WARIO_DASH0                  EQU $68
DEF OBJ_SAVESEL_WARIO_DASH1                  EQU $69
DEF OBJ_SAVESEL_WARIO_DASH2                  EQU $6A
DEF OBJ_SAVESEL_WARIO_DASH3                  EQU $6B
DEF OBJ_SAVESEL_WARIO_DASH4                  EQU $6C
DEF OBJ_SAVESEL_WARIO_DASH5                  EQU $6D
DEF OBJ_SAVESEL_WARIO_DASH6                  EQU $6E
DEF OBJ_SAVESEL_WARIO_BUMP                   EQU $6F
DEF OBJ_WARIO_HOLDJUMP                       EQU $70
DEF OBJ_WARIO_HOLDGROUNDPOUND                EQU $71
DEF OBJ_SAVESEL_OLDHAT0                      EQU $72
DEF OBJ_SAVESEL_OLDHAT1                      EQU $73
DEF OBJ_SAVESEL_OLDHAT2                      EQU $74
DEF OBJ_SAVESEL_WARIO_JUMPNOHAT              EQU $75
DEF OBJ_UNUSED_SAVESEL_WARIO_STANDNOHAT      EQU $76
DEF OBJ_DRAGONHATWATER_A0                    EQU $77
DEF OBJ_DRAGONHATWATER_A1                    EQU $78
DEF OBJ_DRAGONHATWATER_A2                    EQU $79
DEF OBJ_DRAGONHATWATER_B0                    EQU $7A
DEF OBJ_DRAGONHATWATER_B1                    EQU $7B
DEF OBJ_DRAGONHATWATER_B2                    EQU $7C
DEF OBJ_DRAGONHATWATER_C0                    EQU $7D
DEF OBJ_DRAGONHATWATER_C1                    EQU $7E
DEF OBJ_DRAGONHATWATER_C2                    EQU $7F
DEF OBJ_DRAGONHATWATER_D0                    EQU $80
DEF OBJ_DRAGONHATWATER_D1                    EQU $81
DEF OBJ_DRAGONHATWATER_D2                    EQU $82
DEF OBJ_DRAGONHATWATER_E0                    EQU $83
DEF OBJ_DRAGONHATWATER_E1                    EQU $84
DEF OBJ_DRAGONHATWATER_E2                    EQU $85
DEF OBJ_DRAGONHATWATER_F0                    EQU $86
DEF OBJ_DRAGONHATWATER_F1                    EQU $87
DEF OBJ_DRAGONHATWATER_F2                    EQU $88
DEF OBJ_TRROOM_WARIO_SHRUG                   EQU $89
DEF OBJ_TRROOM_WARIO_GLOAT                   EQU $8A
DEF OBJ_TRROOM_WARIO_IDLE0                   EQU $8B
DEF OBJ_TRROOM_WARIO_IDLE1                   EQU $8C
DEF OBJ_SAVESEL_CROSS                        EQU $8D
DEF OBJ_TRROOM_TREASURE_C0                   EQU $8E
DEF OBJ_TRROOM_TREASURE_C1                   EQU $8F
DEF OBJ_TRROOM_TREASURE_I0                   EQU $90
DEF OBJ_TRROOM_TREASURE_I1                   EQU $91
DEF OBJ_TRROOM_TREASURE_F0                   EQU $92
DEF OBJ_TRROOM_TREASURE_F1                   EQU $93
DEF OBJ_TRROOM_TREASURE_O0                   EQU $94
DEF OBJ_TRROOM_TREASURE_O1                   EQU $95
DEF OBJ_TRROOM_TREASURE_A0                   EQU $96
DEF OBJ_TRROOM_TREASURE_A1                   EQU $97
DEF OBJ_TRROOM_TREASURE_N0                   EQU $98
DEF OBJ_TRROOM_TREASURE_N1                   EQU $99
DEF OBJ_TRROOM_TREASURE_H0                   EQU $9A
DEF OBJ_TRROOM_TREASURE_H1                   EQU $9B
DEF OBJ_TRROOM_TREASURE_M0                   EQU $9C
DEF OBJ_TRROOM_TREASURE_M1                   EQU $9D
DEF OBJ_TRROOM_TREASURE_L0                   EQU $9E
DEF OBJ_TRROOM_TREASURE_L1                   EQU $9F
DEF OBJ_TRROOM_TREASURE_K0                   EQU $A0
DEF OBJ_TRROOM_TREASURE_K1                   EQU $A1
DEF OBJ_TRROOM_TREASURE_B0                   EQU $A2
DEF OBJ_TRROOM_TREASURE_B1                   EQU $A3
DEF OBJ_TRROOM_TREASURE_D0                   EQU $A4
DEF OBJ_TRROOM_TREASURE_D1                   EQU $A5
DEF OBJ_TRROOM_TREASURE_G0                   EQU $A6
DEF OBJ_TRROOM_TREASURE_G1                   EQU $A7
DEF OBJ_TRROOM_TREASURE_J0                   EQU $A8
DEF OBJ_TRROOM_TREASURE_J1                   EQU $A9
DEF OBJ_TRROOM_TREASURE_E0                   EQU $AA
DEF OBJ_TRROOM_TREASURE_E1                   EQU $AB
DEF OBJ_TRROOM_STAR00                        EQU $AC
DEF OBJ_TRROOM_STAR01                        EQU $AD
DEF OBJ_TRROOM_STAR02                        EQU $AE
DEF OBJ_TRROOM_STAR03                        EQU $AF
DEF OBJ_TRROOM_STAR10                        EQU $B0
DEF OBJ_TRROOM_STAR11                        EQU $B1
DEF OBJ_TRROOM_STAR12                        EQU $B2
DEF OBJ_TRROOM_STAR13                        EQU $B3
DEF OBJ_TRROOM_STAR20                        EQU $B4
DEF OBJ_TRROOM_STAR21                        EQU $B5
DEF OBJ_TRROOM_STAR22                        EQU $B6
DEF OBJ_TRROOM_STAR23                        EQU $B7
DEF OBJ_TRROOM_STAR30                        EQU $B8
DEF OBJ_TRROOM_STAR31                        EQU $B9
DEF OBJ_TRROOM_STAR32                        EQU $BA
DEF OBJ_TRROOM_STAR33                        EQU $BB
DEF OBJ_COIN0                                EQU $BC
DEF OBJ_COIN1                                EQU $BD
DEF OBJ_COIN2                                EQU $BE
DEF OBJ_COIN3                                EQU $BF
DEF OBJ_1UP                                  EQU $C0
DEF OBJ_SAVESEL_SMOKE0                       EQU $C1
DEF OBJ_SAVESEL_SMOKE1                       EQU $C2
DEF OBJ_SAVESEL_SMOKE2                       EQU $C3
DEF OBJ_3UP                                  EQU $C4
DEF OBJ_TRROOM_MONEYBAGS1                    EQU $C5
DEF OBJ_TRROOM_MONEYBAGS2                    EQU $C6
DEF OBJ_TRROOM_MONEYBAGS3                    EQU $C7
DEF OBJ_TRROOM_MONEYBAGS4                    EQU $C8
DEF OBJ_TRROOM_MONEYBAGS5                    EQU $C9
DEF OBJ_TRROOM_MONEYBAGS6                    EQU $CA
DEF OBJ_TRROOM_MONEYBAG_FALL                 EQU $CB
DEF OBJ_SAVESEL_WARIO_STANDNOHAT             EQU $CC
DEF OBJ_SAVESEL_WARIO_LOOKBACK               EQU $CD
DEF OBJ_SAVESEL_WARIO_LOOKUP                 EQU $CE
                                             
; For static modes outside of the title screen (Bonus games and ending)
DEF OBJ_STATIC_WARIO_NONE                    EQU $00
DEF OBJ_STATIC_WARIO_WALK0                   EQU $01 ; Must be shared with OBJ_WARIO_WALK*
DEF OBJ_STATIC_WARIO_WALK1                   EQU $02 ; Must be shared ""
DEF OBJ_STATIC_WARIO_WALK2                   EQU $03 ; Must be shared ""
DEF OBJ_STATIC_WARIO_WALK3                   EQU $04 ; Must be shared ""
DEF OBJ_STATIC_WARIO_IDLE                    EQU $05
DEF OBJ_STATIC_WARIO_FRONT                   EQU $06 
DEF OBJ_STATIC_WARIO_WON0                    EQU $07 
DEF OBJ_STATIC_WARIO_WON1                    EQU $08 
DEF OBJ_STATIC_WARIO_LOST                    EQU $09 
DEF OBJ_STATIC_WARIO_IDLEDIAG                EQU $0A
DEF OBJ_ENDING_WARIO_JUMPDIAG                EQU $0B
; The rest of STATIC_OBJ_WARIO only works without XFLIP
DEF OBJ_HEARTBONUS_WARIO_BACK                EQU $0C
DEF OBJ_HEARTBONUS_WARIO_BACKGRABBOMB        EQU $0D
DEF OBJ_HEARTBONUS_WARIO_BACKHOLDBOMB0       EQU $0E
DEF OBJ_HEARTBONUS_WARIO_BACKHOLDBOMB1       EQU $0F
DEF OBJ_HEARTBONUS_WARIO_BACKTHROWBOMB       EQU $10
DEF OBJ_HEARTBONUS_WARIO_BACKGRABBOMBEXPL0   EQU $11
DEF OBJ_HEARTBONUS_WARIO_BACKGRABBOMBEXPL1   EQU $12
DEF OBJ_HEARTBONUS_WARIO_BACKGRABBOMBEXPL2   EQU $13
DEF OBJ_HEARTBONUS_WARIO_BACKHOLDBOMBEXPL0   EQU $14
DEF OBJ_HEARTBONUS_WARIO_BACKHOLDBOMBEXPL1   EQU $15
DEF OBJ_HEARTBONUS_WARIO_BACKHOLDBOMBEXPL2   EQU $16
DEF OBJ_HEARTBONUS_WARIO_BACKBOMBEXPL3       EQU $17
DEF OBJ_HEARTBONUS_WARIO_BACKBOMBEXPL4       EQU $18
DEF OBJ_COINBONUS_WARIO_IDLEDIAGBACK         EQU $19
DEF OBJ_COINBONUS_WARIO_PULL0                EQU $1A
DEF OBJ_COINBONUS_WARIO_PULL1                EQU $1B
DEF OBJ_COINBONUS_WARIO_CRUSHED              EQU $1C
DEF OBJ_ENDING_WARIO_WALKHOLD0               EQU $1D
DEF OBJ_ENDING_WARIO_WALKHOLD1               EQU $1E
DEF OBJ_ENDING_WARIO_WALKHOLD2               EQU $1F
DEF OBJ_ENDING_WARIO_WALKHOLD3               EQU $20
DEF OBJ_ENDING_WARIO_IDLEHOLD                EQU $21
DEF OBJ_ENDING_WARIO_IDLETHROW               EQU $22
DEF OBJ_ENDING_WARIO_DUCKRUB0                EQU $23
DEF OBJ_ENDING_WARIO_DUCKRUB1                EQU $24
DEF OBJ_ENDING_WARIO_DUCKRUB2                EQU $25
DEF OBJ_ENDING_WARIO_DUCKDIAG                EQU $26
DEF OBJ_ENDING_WARIO_BUMP0                   EQU $27
DEF OBJ_ENDING_WARIO_BUMP1                   EQU $28
DEF OBJ_ENDING_WARIO_WISHCLOSE               EQU $29
DEF OBJ_ENDING_WARIO_WISHOPEN                EQU $2A
                                             
                                             
; ============================================================
; Treasure IDs                               
DEF TREASURE_C                               EQU $01
DEF TREASURE_I                               EQU $02
DEF TREASURE_F                               EQU $03
DEF TREASURE_O                               EQU $04
DEF TREASURE_A                               EQU $05
DEF TREASURE_N                               EQU $06
DEF TREASURE_H                               EQU $07
DEF TREASURE_M                               EQU $08
DEF TREASURE_L                               EQU $09
DEF TREASURE_K                               EQU $0A
DEF TREASURE_B                               EQU $0B
DEF TREASURE_D                               EQU $0C
DEF TREASURE_G                               EQU $0D
DEF TREASURE_J                               EQU $0E
DEF TREASURE_E                               EQU $0F
                                             
DEF TREASUREB_C                              EQU $01
DEF TREASUREB_I                              EQU $02
DEF TREASUREB_F                              EQU $03
DEF TREASUREB_O                              EQU $04
DEF TREASUREB_A                              EQU $05
DEF TREASUREB_N                              EQU $06
DEF TREASUREB_H                              EQU $07
DEF TREASUREB_M                              EQU $00
DEF TREASUREB_L                              EQU $01
DEF TREASUREB_K                              EQU $02
DEF TREASUREB_B                              EQU $03
DEF TREASUREB_D                              EQU $04
DEF TREASUREB_G                              EQU $05
DEF TREASUREB_J                              EQU $06
DEF TREASUREB_E                              EQU $07
                                             
                                             
DEF BIGITEM_COIN                             EQU $00
DEF BIGITEM_HEART                            EQU $01
                                             
; ============================================================
; Actor ID list (default for gameplay)       
                                             
DEF ACT_DEFAULT_BASE                         EQU $07
DEF ACT_GARLICPOT                            EQU $07
DEF ACT_JETPOT                               EQU $08
DEF ACT_DRAGONPOT                            EQU $09
DEF ACT_KEY                                  EQU $0A
DEF ACT_HEART                                EQU $0B
DEF ACT_STAR                                 EQU $0C
DEF ACT_COIN                                 EQU $0D
DEF ACT_10COIN                               EQU $0E 
DEF ACT_BULLPOT                              EQU $0F
DEF ACT_NORESPAWN                            EQU $80 ; Special MSB flag in the actor ID -- if set the actor isn't written back to the actor layout (aka: respawn table)
DEF ACTB_NORESPAWN                           EQU 7
                                             
DEF ACTFLAGB_UNUSED_NOBUMPKILL               EQU 0 ; Prevents the actor from being instakilled by ActS_Unused_StunBumpKill when landing.
DEF ACTFLAGB_UNUSED_FREEOFFSCREEN            EQU 3 ; As soon as the actor goes off-screen, it gets permanently despawned. For some reason, this is done actor-specific instead of using this flag.
DEF ACTFLAGB_NORECOVER                       EQU 5 ; Once stunned, the actor stays stunned until it goes off screen
DEF ACTFLAGB_NODESPAWNOFFSCREEN              EQU 6 ; Actor does not despawn when going off-screen (will remain in mode $01)
DEF ACTFLAGB_HEAVY                           EQU 7 ; Actor marked as "heavy"
                                             
DEF ACTFLAG_UNUSED_NOBUMPKILL                EQU 1 << ACTFLAGB_UNUSED_NOBUMPKILL
DEF ACTFLAG_UNUSED_FREEOFFSCREEN             EQU 1 << ACTFLAGB_UNUSED_FREEOFFSCREEN
DEF ACTFLAG_NORECOVER                        EQU 1 << ACTFLAGB_NORECOVER
DEF ACTFLAG_NODESPAWNOFFSCREEN               EQU 1 << ACTFLAGB_NODESPAWNOFFSCREEN
DEF ACTFLAG_HEAVY                            EQU 1 << ACTFLAGB_HEAVY
                                             
; Actor Slot Status                          
DEF ATV_INACTIVE                             EQU $00 ; Actor isn't active, slot is free to be reused
DEF ATV_OFFSCREEN                            EQU $01 ; Active, but off-screen (not drawn)
DEF ATV_ONSCREEN                             EQU $02 ; Active, on-screen
DEF ATV_ONSCREENONCE                         EQU $03 ; Active for one frame to let the actor being drawn when freeroaming (which otherwise disables actors) 
                                             
; Actor routines (lower nybble-only)         
; Upper nybble is reused for the bump direction.
DEF ACTRTN_MAIN                              EQU $00 ; Normal routine -- the rest are "special"
DEF ACTRTN_01                                EQU $01 ; Horizontal bump/stun
DEF ACTRTN_02                                EQU $02 ; Stun from above
DEF ACTRTN_03                                EQU $03 ; Groundpound on it (crush)
DEF ACTRTN_04                                EQU $04 ; Stun from below
DEF ACTRTN_05                                EQU $05 ; Dash attacked
DEF ACTRTN_06                                EQU $06 ; Standing on top
DEF ACTRTN_07                                EQU $07 ; Hard bumped (including after dealing damage)
DEF ACTRTN_SPEC_08                           EQU $08 ; Marked as hit after being thrown something
DEF ACTRTN_SPEC_09                           EQU $09 ; Grabbed (Treasure-only)
                                             
; Standard OBJLst parent table offsets       
; In pairs since different data is used for actors facing left/right.
DEF ACTOLP_UNUSED_BUMPL                      EQU $00*2 ; $00 ; [TCRF] Was used in earlier builds when bumping against actors.
DEF ACTOLP_UNUSED_BUMPR                      EQU $01*2 ; $02 ; 
DEF ACTOLP_RECOVERL                          EQU $02*2 ; $04 ; Actor recovering from stun
DEF ACTOLP_RECOVERR                          EQU $03*2 ; $06 ;
DEF ACTOLP_STUNL                             EQU $04*2 ; $08 ; Actor stunned / killed
DEF ACTOLP_STUNR                             EQU $05*2 ; $0A
                                             
; Actor-specific constants                   
DEF SSBOSS_RTN_WIND                          EQU $00
DEF SSBOSS_RTN_YARC                          EQU $01
DEF SSBOSS_RTN_HIT                           EQU $02
DEF SSBOSS_RTN_DEAD                          EQU $03
DEF SSBOSS_RTN_COINGAME                      EQU $04
DEF SSBOSS_RTN_INTRO                         EQU $05
                                             
DEF PCFW_DIR_D                               EQU $01
DEF PCFW_DIR_R                               EQU $02
DEF PCFW_DIR_U                               EQU $03
DEF PCFW_DIR_R2                              EQU $04
                                             
DEF PUFF_RTN_IDLE                            EQU $00
DEF PUFF_RTN_IDLEANIM                        EQU $01
DEF PUFF_RTN_INFLATE                         EQU $02
DEF PUFF_RTN_DEFLATE                         EQU $03
                                             
DEF WOLF_RTN_WALK                            EQU $00
DEF WOLF_RTN_ALERT                           EQU $02
DEF WOLF_RTN_THROWKNIFE                      EQU $03
DEF WOLF_RTN_POSTKNIFE                       EQU $04
                                             
DEF PENG_RTN_WALK                            EQU $00
DEF PENG_RTN_ALERT                           EQU $02
DEF PENG_RTN_KICK                            EQU $03
DEF PENG_RTN_POSTKICK                        EQU $04
                                             
DEF DD_RTN_WALK                              EQU $00
DEF DD_RTN_ALERT                             EQU $02
DEF DD_RTN_THROW                             EQU $03
DEF DD_RTN_POSTTHROW                         EQU $04
                                             
DEF BIRD_RTN_IDLE                            EQU $00
DEF BIRD_RTN_ATK                             EQU $01
                                             
DEF CDUCK_RTN_FLYUP                          EQU $00
DEF CDUCK_RTN_MV14                           EQU $01
DEF CDUCK_RTN_MV78                           EQU $02
DEF CDUCK_RTN_AIRWAIT                        EQU $03
DEF CDUCK_RTN_FLYDOWN                        EQU $04
DEF CDUCK_RTN_SLEEP                          EQU $05
DEF CDUCK_RTN_WAKEUP                         EQU $06
DEF CDUCK_RTN_GIVECOINS                      EQU $07
DEF CDUCK_RTN_FLYOUT                         EQU $08
                                             
DEF MTBOSS_RTN_INTRODROP                     EQU $00 ; IntroFall
DEF MTBOSS_RTN_INTRO1                        EQU $01 ; Intro1
DEF MTBOSS_RTN_INTRO2                        EQU $02 ; Intro2
DEF MTBOSS_RTN_JUMP                          EQU $03 ; Jump
DEF MTBOSS_RTN_CHARGE                        EQU $04 ; Charge
DEF MTBOSS_RTN_STUN                          EQU $05 ; Stun
DEF MTBOSS_RTN_HELD                          EQU $06 ; Held
DEF MTBOSS_RTN_THROWN                        EQU $07 ; Thrown
DEF MTBOSS_RTN_DEAD                          EQU $08 ; Dead
DEF MTBOSS_RTN_HOLDPL                        EQU $09 ; Holding player
DEF MTBOSS_RTN_THROWPL                       EQU $0A ; Throwing player
                                             
; Player's relative position when held by the boss, relative to the actor's position
DEF MTBOSS_PLHOLD_XREL                       EQU $14
DEF MTBOSS_PLHOLD_YREL                       EQU $23
                                             
DEF SLBOSS_RTN_INTROJUMP                     EQU $00 ; Intro jump
DEF SLBOSS_RTN_INTROPAUSE                    EQU $01 ; Intro pause
DEF SLBOSS_RTN_PAUSE                         EQU $02 ; Pause
DEF SLBOSS_RTN_MOVE                          EQU $03 ; Move
DEF SLBOSS_RTN_ATTACK                        EQU $04 ; Attack
DEF SLBOSS_RTN_HIT                           EQU $05 ; Hit
DEF SLBOSS_RTN_HITPAUSE                      EQU $06 ; Pause after hit
DEF SLBOSS_RTN_JUMPDOWN                      EQU $07 ; Jump into water
DEF SLBOSS_RTN_JUMPUP                        EQU $08 ; Jump with hat
DEF SLBOSS_RTN_DEAD                          EQU $09 ; Dead / heart game
DEF SLBOSS_RTN_TURN                          EQU $0A ; Turn
                                             
DEF SLBOSSHAT_NO                             EQU $00
DEF SLBOSSHAT_YES                            EQU $01
DEF SLBOSSHAT_DROP                           EQU $02
                                             
DEF RBBOSS_RTN_INTRO                         EQU $00 ; Intro
DEF RBBOSS_RTN_RISEUP                        EQU $01 ; Rise from ground
DEF RBBOSS_RTN_JUMP                          EQU $02 ; Jump
DEF RBBOSS_RTN_IDLE                          EQU $03 ; Idle
DEF RBBOSS_RTN_SPINMOVE                      EQU $04 ; Attack - movement
DEF RBBOSS_RTN_SPINMOVEAIR                   EQU $05 ; Attack - inverted
DEF RBBOSS_RTN_RISEDOWN                      EQU $06 ; Move down into underground
DEF RBBOSS_RTN_SPINUNDERGROUND               EQU $07 ; Move horz in ground
DEF RBBOSS_RTN_STUNAIR                       EQU $08 ; Stun jump
DEF RBBOSS_RTN_DEAD                          EQU $09 ; Dead + Coin Game
DEF RBBOSS_RTN_SPINIDLE                      EQU $0A ; Attack - pause before moving
DEF RBBOSS_RTN_STUNGROUND                    EQU $0B ; Ground stun (only after dash attack)
                                             
DEF PWBOSS_RTN_INTRO                         EQU $00 ; Intro
DEF PWBOSS_RTN_TARGET0                       EQU $01 ; MoveCR (Identical to 00)
DEF PWBOSS_RTN_ARC0                          EQU $02 ; Circle-like movement (before throw)
DEF PWBOSS_RTN_TARGET1                       EQU $03 ; Move left w/ spawn
DEF PWBOSS_RTN_ARC1                          EQU $04 ; Half-Circle-like movement
DEF PWBOSS_RTN_TARGET2                       EQU $05 ; Move right w/ spawn
DEF PWBOSS_RTN_ARC2                          EQU $06 ; Y Arc motion
DEF PWBOSS_RTN_TARGET3                       EQU $07 ; Move left w/o spawn
DEF PWBOSS_RTN_SPAWN3                        EQU $08 ; Spawn 3 ghosts
DEF PWBOSS_RTN_DEAD                          EQU $09 ; Dead
DEF PWBOSS_RTN_HIT                           EQU $0A ; Hit
                                             
DEF BGHOST_RTN_INTRO                         EQU $00
DEF BGHOST_RTN_MOVE                          EQU $01
DEF BGHOST_RTN_STUN                          EQU $02
                                             
DEF SCBOSS_RTN_INTRO                         EQU $00 ; Intro
DEF SCBOSS_RTN_MAIN                          EQU $01 ; Main movement
DEF SCBOSS_RTN_TONGUE                        EQU $02 ; Tongue
DEF SCBOSS_RTN_DEAD                          EQU $03 ; Dead
DEF SCBOSS_RTN_COINGAME                      EQU $04 ; Coin Game
                                             
DEF SCBOSSTNG_RTN_DISABLED                   EQU $00
DEF SCBOSSTNG_RTN_ENABLE                     EQU $01
DEF SCBOSSTNG_RTN_ENABLED                    EQU $02
                                             
DEF SCBOSSBALL_RTN_FIRE                      EQU $00 ; Fireball
DEF SCBOSSBALL_RTN_SAFE                      EQU $01 ; Jump
DEF SCBOSSBALL_RTN_SPLASH                    EQU $02 ; Lava splash
                                             
DEF FLO_RTN_IDLE                             EQU $00 ; Idle
DEF FLO_RTN_WAITMOVE                         EQU $01 ; Wait for move
DEF FLO_RTN_MOVE                             EQU $02 ; Move
DEF FLO_RTN_WAITIDLE                         EQU $03 ; Wait for idle
                                             
DEF BRIDGE_RTN_IDLE                          EQU $00 ; Might as well be unused
DEF BRIDGE_RTN_ALERT                         EQU $01 ; Alert
DEF BRIDGE_RTN_FALL                          EQU $02 ; Fall
DEF BRIDGE_RTN_FAIL                          EQU $03 ; Infinite loop
                                             
DEF SNOW_RTN_MOVE                            EQU $00 ; Move
DEF SNOW_RTN_SHOOT                           EQU $03 ; Shoot
DEF SNOW_RTN_POSTSHOOT                       EQU $04 ; Wait
                                             
DEF BIGSW_RTN_WAIT                           EQU $00
DEF BIGSW_RTN_HIT                            EQU $01
DEF BIGSW_RTN_POSTHIT                        EQU $02
                                             
DEF GHOST_RTN_MOVE                           EQU $00 ; Move
DEF GHOST_RTN_STUN                           EQU $01 ; Stun
                                             
DEF SEAH_RTN_MOVEUP                          EQU $00 ; Up move
DEF SEAH_RTN_MOVEDOWN                        EQU $01 ; Down move
DEF SEAH_RTN_ALERT                           EQU $02 ; AttackWarn
DEF SEAH_RTN_ATTACK                          EQU $03 ; Attack
                                             
DEF BBOX_RTN_IDLE                            EQU $00
DEF BBOX_RTN_HIT                             EQU $01
DEF BBOX_RTN_USED                            EQU $02
                                             
DEF BOMB_RTN_IDLE                            EQU $00       ; Idle
DEF BOMB_RTN_THROW                           EQU $01      ; Thrown / activating
DEF BOMB_RTN_EXPLODE                         EQU $02    ; Exploding
DEF BOMB_RTN_HELD                            EQU $03       ; Held override / activating
                                             
DEF CPTS_RTN_INTRO_00                        EQU $00
DEF CPTS_RTN_INTRO_01                        EQU $01
DEF CPTS_RTN_INTRO_02                        EQU $02
DEF CPTS_RTN_INTRO_03                        EQU $03
DEF CPTS_RTN_INTRO_04                        EQU $04 ; Copy of CPTS_RTN_01
DEF CPTS_RTN_INTRO_05                        EQU $05
DEF CPTS_RTN_INTRO_06                        EQU $06
DEF CPTS_RTN_INTRO_07                        EQU $07
DEF CPTS_RTN_INTRO_08                        EQU $08
DEF CPTS_RTN_INTRO_09                        EQU $09
DEF CPTS_RTN_INTRO_0A                        EQU $0A
DEF CPTS_RTN_INTRO_0B                        EQU $0B
DEF CPTS_RTN_INTRO_0C                        EQU $0C
DEF CPTS_RTN_INTRO_0D                        EQU $0D
DEF CPTS_RTN_PLAY                            EQU $0E ; Main
DEF CPTS_RTN_DEAD                            EQU $0F ; Dead
; Ending specific                            
DEF CPTS_RTN_ENDING_10                       EQU $10
DEF CPTS_RTN_ENDING_11                       EQU $11
DEF CPTS_RTN_ENDING_12                       EQU $12
DEF CPTS_RTN_ENDING_13                       EQU $13
DEF CPTS_RTN_ENDING_14                       EQU $14
DEF CPTS_RTN_ENDING_15                       EQU $15 
DEF CPTS_RTN_WAITRELOAD                      EQU $16 ; Wait clear (after $0F)
; For mode $0E                               
DEF CPTS_SUBRTN_MOVE                         EQU $00
DEF CPTS_SUBRTN_WAITFIRE                     EQU $01
DEF CPTS_SUBRTN_FIRE                         EQU $02
DEF CPTS_SUBRTN_HIT                          EQU $03
                                             
DEF CPTS_BG_YTARGET                          EQU $06 ; 6px/frame happens to be off-screen when reached
DEF CPTS_ACT_YTARGET                         EQU $8F ; Position visually on the ground
                                             
DEF CPTSBALL_RTN_AIR                         EQU $00    ; Jump arc in the air
DEF CPTSBALL_RTN_GROUND                      EQU $01 ; Sliding on the ground
                                             
DEF LAMP_RTN_INTROIDLE                       EQU $00 ; Idle, intangible
DEF LAMP_RTN_INITFLASH                       EQU $01 ; Flash anim setup
DEF LAMP_RTN_FLASH                           EQU $02 ; Flash 
DEF LAMP_RTN_FALL                            EQU $03 ; Drop down (thrown?)
DEF LAMP_RTN_MAIN                            EQU $04 ; Main idle
DEF LAMP_RTN_HOLD                            EQU $05 ; Holding the lamp
DEF LAMP_RTN_THROW                           EQU $06 ; Throwing it
DEF LAMP_RTN_HELDNOTHROW                     EQU $07 ; Ending reload
IF FIX_BUGS == 1                         
DEF LAMP_RTN_INITMAIN                        EQU $08 ; Custom - switch to $04
ENDC                                     
                                             
DEF LAMPSMOKE_RTN_HIDE                       EQU $00 ;
DEF LAMPSMOKE_RTN_INITMOVE                   EQU $01 ; Show up
DEF LAMPSMOKE_RTN_MOVE                       EQU $02 ; Move up
DEF LAMPSMOKE_RTN_HIDE2                      EQU $03 ; Move up
                                             
DEF CPTSMINI_RTN_RISE                        EQU $00
DEF CPTSMINI_RTN_BLINK                       EQU $01
DEF CPTSMINI_RTN_FALLDOWN                    EQU $02
DEF CPTSMINI_RTN_MAIN                        EQU $03
                                             
DEF CCRB_RTN_HIDDEN                          EQU $00
DEF CCRB_RTN_EXITSAND                        EQU $01
DEF CCRB_RTN_STAND                           EQU $02
DEF CCRB_RTN_RUN                             EQU $03
DEF CCRB_RTN_UNUSED_ENTERSAND                EQU $04
                                             
DEF MOLE_RTN_WALK                            EQU $00
DEF MOLE_RTN_THROWKNIFE                      EQU $03
DEF MOLE_RTN_POSTKNIFE                       EQU $04
DEF MOS_MODE_SPAWN                           EQU $00
DEF MOS_MODE_HOLD                            EQU $01
DEF MOS_MODE_THROW                           EQU $02
DEF MOS_MODE_DESPAWN                         EQU $03
                                             
DEF SEAL_RTN_IDLE                            EQU $00
DEF SEAL_RTN_TRACK                           EQU $01
DEF SEAL_RTN_SHOOT                           EQU $02
DEF SEAL_RTN_RETREAT                         EQU $03
                                             
DEF MOLEC_RTN_IDLE                           EQU $00
DEF MOLEC_RTN_TURNR                          EQU $01 ; Turn right
DEF MOLEC_RTN_SPAWNCOIN                      EQU $02 ; Throw coin
DEF MOLEC_RTN_THROWANIM                      EQU $03 ; Throw anim
DEF MOLEC_RTN_WAITWALK                       EQU $04 ; Wait walk, remove hand
DEF MOLEC_RTN_WALK                           EQU $05 ; Walk right
DEF MOLEC_RTN_TURNMULTI                      EQU $06 ; Turn multi
                                             
DEF FRM_RTN_WARN                             EQU $00
DEF FRM_RTN_MOVE                             EQU $01
DEF FRM_RTN_SOLIDHIT0                        EQU $02
DEF FRM_RTN_SOLIDHIT1                        EQU $03
DEF FRM_RTN_MOVEBACK                         EQU $04
DEF FRM_RTN_WAIT                             EQU $05
                                             
DEF BOMS_RTN_IDLE                            EQU $00
DEF BOMS_RTN_MOVE                            EQU $01
DEF BOMS_RTN_STICK                           EQU $02
DEF BOMS_RTN_EXPLODE                         EQU $03
                                             
DEF KNI_RTN_WALK                             EQU $00
DEF KNI_RTN_HIT                              EQU $01
DEF KNI_RTN_CHARGE                           EQU $02
DEF KNI_RTN_DEAD                             EQU $03
                                             
DEF FLY_RTN_IDLE                             EQU $00
DEF FLY_RTN_FLY                              EQU $01
DEF FLY_RTN_DEAD                             EQU $02
                                             
DEF BAT_RTN_IDLE                             EQU $00
DEF BAT_RTN_ATK                              EQU $01
                                             
; ============================================================
; Extra Actor ID list                        
                                             
DEF EXACT_NONE                               EQU $00
DEF EXACT_DEADHAT                            EQU $01
DEF EXACT_ITEMBOXHIT                         EQU $02
DEF EXACT_JETHATFLAME                        EQU $03
DEF EXACT_DRAGONHATFLAME                     EQU $04
DEF EXACT_BLOCKSMASH                         EQU $05
DEF EXACT_WATERSPLASH                        EQU $06
DEF EXACT_WATERBUBBLE                        EQU $07
DEF EXACT_SAVESEL_NEWHAT                     EQU $08
DEF EXACT_SAVESEL_OLDHAT                     EQU $09
DEF EXACT_TRROOM_ARROW                       EQU $0A
DEF EXACT_SAVESEL_CROSS                      EQU $0B
DEF EXACT_TREASUREGET                        EQU $0C
DEF EXACT_TRROOM_SPARKLE                     EQU $0D
DEF EXACT_SWITCH0TYPE0HIT                    EQU $0E
DEF EXACT_SWITCH0TYPE1HIT                    EQU $0F
DEF EXACT_UNUSED_SWITCH1TYPE0HIT             EQU $10
DEF EXACT_BOUNCEBLOCKHIT                     EQU $11
DEF EXACT_DEADCOINC                          EQU $12
DEF EXACT_DEADCOINL                          EQU $13
DEF EXACT_DEADCOINR                          EQU $14
DEF EXACT_1UPMARKER                          EQU $15
DEF EXACT_TREASUREENDING                     EQU $16
DEF EXACT_MONEYBAG                           EQU $17
DEF EXACT_MONEYBAGSTACK                      EQU $18
DEF EXACT_SAVESEL_SMOKE                      EQU $19
DEF EXACT_TREASURELOST                       EQU $1A
                                             
; commands for ExAct_MoneybagStack (sExActMoneybagStackMode)
DEF MONEYBAGSTACK_ADDITEM                    EQU $01 ; Add 1 moneybag
DEF MONEYBAGSTACK_SYNCPOS                    EQU $02 ; Sync with player's position
                                             
; ============================================================
; GAME MODES                                 
; ============================================================
                                             
DEF GM_TITLE                                 EQU $00 ; Title screen
DEF GM_MAP                                   EQU $01 ; Map screen
DEF GM_LEVELINIT                             EQU $02 ; Level loading & fade-in
DEF GM_LEVEL                                 EQU $03 ; Main gameplay
DEF GM_LEVELCLEAR                            EQU $04 ; Main gameplay - Entering the exit door (with wario anim)
DEF GM_LEVELDEADFADEOUT                      EQU $05
DEF GM_LEVELCLEAR2                           EQU $06 ; Main gameplay - Special exit
DEF GM_TIMEUP                                EQU $07
DEF GM_GAMEOVER                              EQU $08
DEF GM_ENDING                                EQU $09 ; Ending (Everything except the map screen part)
DEF GM_LEVELDOOR                             EQU $0A ; Main gameplay - Entering a normal door
DEF GM_TREASURE                              EQU $0B ; Treasure get
DEF GM_LEVELENTRANCE                         EQU $0C ; Main gameplay - Entering the level entrance door
DEF GM_UNUSED_HEARTBONUS                     EQU $0D ; Mode itself not used; but the code it points to is
; ------------------------------------------------------------
                                             
DEF GM_TITLE_MAIN                            EQU $00
DEF GM_TITLE_SAVESELSWITCH                   EQU $01
DEF GM_TITLE_INITSAVESEL                     EQU $02
DEF GM_TITLE_SAVESELINTRO0                   EQU $03
DEF GM_TITLE_SAVESELINTRO1                   EQU $04
DEF GM_TITLE_SAVESEL                         EQU $05
DEF GM_TITLE_SAVEERROR                       EQU $06
                                             
; ------------------------------------------------------------
DEF GM_MAP_MAIN                              EQU $00
DEF GM_MAP_COURSESCR                         EQU $01
                                             
; Map modes available. They do not necessarily correspond to actual maps (ie. fade in mode)
DEF MAP_MODE_INIT                            EQU $00
DEF MAP_MODE_INITOVERWORLD                   EQU $01
DEF MAP_MODE_OVERWORLD                       EQU $02
DEF MAP_MODE_INITRICEBEACH                   EQU $03
DEF MAP_MODE_RICEBEACH                       EQU $04
DEF MAP_MODE_INITMTTEAPOT                    EQU $05
DEF MAP_MODE_MTTEAPOT                        EQU $06
DEF MAP_MODE_FADEIN                          EQU $07
DEF MAP_MODE_FADEOUT                         EQU $08
DEF MAP_MODE_INITSTOVECANYON                 EQU $09
DEF MAP_MODE_STOVECANYON                     EQU $0A
DEF MAP_MODE_INITSYRUPCASTLE                 EQU $0B
DEF MAP_MODE_SYRUPCASTLE                     EQU $0C
DEF MAP_MODE_INITPARSLEYWOODS                EQU $0D
DEF MAP_MODE_PARSLEYWOODS                    EQU $0E
DEF MAP_MODE_INITSSTEACUP                    EQU $0F
DEF MAP_MODE_SSTEACUP                        EQU $10
DEF MAP_MODE_INITSHERBETLAND                 EQU $11
DEF MAP_MODE_SHERBETLAND                     EQU $12
DEF MAP_MODE_INITMTTEAPOTCUTSCENE            EQU $13
DEF MAP_MODE_MTTEAPOTCUTSCENE                EQU $14
DEF MAP_MODE_CUTSCENEFADEOUT                 EQU $15
DEF MAP_MODE_INITSSTEACUPCUTSCENE            EQU $16
DEF MAP_MODE_SSTEACUPCUTSCENE                EQU $17
DEF MAP_MODE_INITPARSLEYWOODSCUTSCENE        EQU $18
DEF MAP_MODE_PARSLEYWOODSCUTSCENE            EQU $19
DEF MAP_MODE_INITSYRUPCASTLEC38CUTSCENE      EQU $1A
DEF MAP_MODE_DUMMY_1B                        EQU $1B
DEF MAP_MODE_INITSYRUPCASTLEC39CUTSCENE      EQU $1C
DEF MAP_MODE_DUMMY_1D                        EQU $1D
DEF MAP_MODE_INITENDING2                     EQU $1E
DEF MAP_MODE_ENDING2                         EQU $1F
DEF MAP_MODE_ENDING2FADEIN                   EQU $20
DEF MAP_MODE_INITENDING1                     EQU $21
                                             
; ------------------------------------------------------------
DEF GM_LEVELINIT_LOAD                        EQU $00
DEF GM_LEVELINIT_FADEBG                      EQU $01
DEF GM_LEVELINIT_FADEOBJ                     EQU $02
DEF GM_LEVELINIT_STARTLEVEL                  EQU $03
; ------------------------------------------------------------
DEF GM_LEVEL_MAIN                            EQU $00
; ------------------------------------------------------------
                                             
DEF GM_LEVELCLEAR_FANFARE                    EQU $00 
DEF GM_LEVELCLEAR_OBJFADE                    EQU $01 ; Fade to black for objects
DEF GM_LEVELCLEAR_LEVELFADE                  EQU $02 ; Objects disappear, fade to white for BG
DEF GM_LEVELCLEAR_CLEARINIT                  EQU $03 ; Initialize Course Clear screen
DEF GM_LEVELCLEAR_CLEAR                      EQU $04 ; Course clear screen
DEF GM_LEVELCLEAR_TRINIT                     EQU $05 ; 
                                             
DEF GM_LEVELCLEAR_TRWAIT                     EQU $06 ; Initial part
DEF GM_LEVELCLEAR_TRCOINCOUNT                EQU $07 ; Coin countdown
DEF GM_LEVELCLEAR_TRIDLE                     EQU $08 ; Waiting for input
DEF GM_LEVELCLEAR_TREXIT                     EQU $09 ; Left walk
                                             
; GM_LEVELCLEAR_CLEAR submodes               
DEF COURSECLR_RTN_INTROMOVER0                EQU $00 ; Moving right (from off-screen left)
DEF COURSECLR_RTN_INTROMOVEL0                EQU $01
DEF COURSECLR_RTN_INTROMOVER1                EQU $02
DEF COURSECLR_RTN_COINBONUSPOS               EQU $03 ; Standing on the coin bonus door
DEF COURSECLR_RTN_UNUSED_COINBONUS_FADEOUT0  EQU $04
DEF COURSECLR_RTN_UNUSED_COINBONUS_FADEOUT1  EQU $05
DEF COURSECLR_RTN_COINBONUS                  EQU $06
DEF COURSECLR_RTN_TOHEARTBONUS               EQU $07
DEF COURSECLR_RTN_HEARTBONUSPOS              EQU $08
DEF COURSECLR_RTN_UNUSED_HEARTBONUS_FADEOUT0 EQU $09
DEF COURSECLR_RTN_UNUSED_HEARTBONUS_FADEOUT1 EQU $0A
DEF COURSECLR_RTN_HEARTBONUS                 EQU $0B
DEF COURSECLR_RTN_TOTRROOM                   EQU $0C
DEF COURSECLR_RTN_TOCOINBONUS                EQU $0D
                                             
; Coin bonus game modes                      
DEF COINBONUS_MODE_INIT                      EQU $00
DEF COINBONUS_MODE_MAIN                      EQU $01
DEF COINBONUS_MODE_EXIT                      EQU $02
                                             
; COINBONUS_MODE_MAIN submodes               
DEF COINBONUS_RTN_MOVER                      EQU $00 ; Walk right
DEF COINBONUS_RTN_IDLE                       EQU $01 
DEF COINBONUS_RTN_MOVEL                      EQU $02
DEF COINBONUS_RTN_ACTION                     EQU $03
DEF COINBONUS_RTN_PULL                       EQU $04
DEF COINBONUS_RTN_DROPITEM                   EQU $05
DEF COINBONUS_RTN_BOUNCE                     EQU $06
DEF COINBONUS_RTN_MOVEC                      EQU $07
DEF COINBONUS_RTN_RESULT                     EQU $08
                                             
; Heart bonus game modes                     
DEF HEARTBONUS_MODE_INIT                     EQU $00
DEF HEARTBONUS_MODE_SELECT                   EQU $01
DEF HEARTBONUS_MODE_INITGAME                 EQU $02
DEF HEARTBONUS_MODE_GAME                     EQU $03
DEF HEARTBONUS_MODE_INITRESULTS              EQU $04
DEF HEARTBONUS_MODE_RESULTS                  EQU $05
DEF HEARTBONUS_MODE_EXIT                     EQU $06
                                             
; MODE_SELECT submodes                       
DEF HEARTBONUS_RTN_MOVER                     EQU $00
DEF HEARTBONUS_RTN_SELECT                    EQU $01
DEF HEARTBONUS_RTN_BOMBSET                   EQU $02
                                             
; MODE_GAME submodes                         
DEF HEARTBONUS_RTN_READYTEXT                 EQU $00
DEF HEARTBONUS_RTN_MOVECTRL                  EQU $01
DEF HEARTBONUS_RTN_THROW                     EQU $02
DEF HEARTBONUS_RTN_BOMBMOVE                  EQU $03
DEF HEARTBONUS_RTN_BOMBEXPLODE               EQU $04
DEF HEARTBONUS_RTN_TIMEOUT                   EQU $05
DEF HEARTBONUS_RTN_RESULT                    EQU $06
                                             
; ------------------------------------------------------------
                                             
; Giant ! block level exit                   
DEF GM_LEVELCLEAR2_FANFARE                   EQU $00 ;
DEF GM_LEVELCLEAR2_OBJFADE                   EQU $01 ; Fade to black for objects
DEF GM_LEVELCLEAR2_LEVELFADE                 EQU $02 ; Objects disappear, fade to white for BG
DEF GM_LEVELCLEAR2_MAPCUTSCENE               EQU $03
                                             
; ------------------------------------------------------------
                                             
DEF GM_TIMEUP_INIT                           EQU $00
DEF GM_TIMEUP_MOVEDOWN                       EQU $01
DEF GM_TIMEUP_MOVEUP                         EQU $02
DEF GM_TIMEUP_WAIT                           EQU $03
DEF GM_TIMEUP_FADEOUT                        EQU $04
DEF GM_TIMEUP_EXIT                           EQU $05
; ------------------------------------------------------------
                                             
DEF GM_GAMEOVER_INIT                         EQU $00
DEF GM_GAMEOVER_MAIN                         EQU $01
DEF GM_GAMEOVER_INITTRROOM                   EQU $02
DEF GM_GAMEOVER_TRROOM                       EQU $03
                                             
; Gameover - treasure room submodes          
DEF GOTR_RTN_MOVER                           EQU $00
DEF GOTR_RTN_LOSETREASURE                    EQU $01
DEF GOTR_RTN_WAITTREASURE                    EQU $02
DEF GOTR_RTN_LOSEMONEY                       EQU $03
DEF GOTR_RTN_EXIT                            EQU $04
                                             
; ------------------------------------------------------------
                                             
DEF GM_ENDING_MOVEPLDOWN                     EQU $00    ; Moving down
DEF GM_ENDING_HATSWITCH                      EQU $01     ; To normal hat
DEF GM_ENDING_WALKTOLAMP                     EQU $02    ; Move towards the lamp
DEF GM_ENDING_WALKTORELOAD                   EQU $03      ; Move to target for room reload (usually left)
DEF GM_ENDING_WAITRELOAD                     EQU $04
DEF GM_ENDING_FADEOUTOBJ                     EQU $05
DEF GM_ENDING_FADEOUTBG                      EQU $06
DEF GM_ENDING_RELOAD                         EQU $07
DEF GM_ENDING_FADEINBG                       EQU $08
DEF GM_ENDING_FADEINOBJ                      EQU $09
DEF GM_ENDING_LVLCUTSCENE                    EQU $0A
DEF GM_ENDING_MAPCUTSCENE                    EQU $0B
DEF GM_ENDING_GENIECUTSCENE                  EQU $0C
DEF GM_ENDING_INITTRROOM                     EQU $0D
DEF GM_ENDING_TRROOM                         EQU $0E ; + credits
DEF GM_ENDING_GENIECUTSCENE2                 EQU $0F ; + credits
                                             
; ENDING MODES (wEndingMode)                 
DEF END_RTN_INITPRETR                        EQU $00   ; Pre-treasure room genie cutscene
DEF END_RTN_PRETR                            EQU $01
DEF END_RTN_INITPOSTTR                       EQU $02  ; Post-treasure room genie cutscene
DEF END_RTN_POSTTR                           EQU $03
DEF END_RTN_INITCASTLE                       EQU $04  ; Castle scene (where the credits take place)
DEF END_RTN_CASTLE                           EQU $05
DEF END_RTN_CREDITS                          EQU $06
DEF END_RTN_PLANET                           EQU $07
                                             
; pre treasure room                          
DEF END1_RTN_MOVERIGHT                       EQU $00
DEF END1_RTN_THROWLAMP                       EQU $01
DEF END1_RTN_RUBLAMP                         EQU $02
DEF END1_RTN_LAMPFLASH                       EQU $03
DEF END1_RTN_CLOUDS                          EQU $04
DEF END1_RTN_FLASHBG                         EQU $05
DEF END1_RTN_PLBUMP                          EQU $06
DEF END1_RTN_GENIETALK                       EQU $07
DEF END1_RTN_THINKWISH                       EQU $08
DEF END1_RTN_PLJUMP                          EQU $09
DEF END1_RTN_GENIEMONEY                      EQU $0A
DEF END1_RTN_PLNOD                           EQU $0B
DEF END1_RTN_MOVELEFT                        EQU $0C
                                             
; treasure room                              
DEF ENDT_RTN_WALKINR                         EQU $00
DEF ENDT_RTN_COINCOUNT                       EQU $01
DEF ENDT_RTN_WAITREMOVE                      EQU $02
DEF ENDT_RTN_WAITNEAR                        EQU $03
DEF ENDT_RTN_GRABTREASURE                    EQU $04
DEF ENDT_RTN_GETTREASURE                     EQU $05
DEF ENDT_RTN_TREASURECOINCOUNT               EQU $06
DEF ENDT_RTN_TOTALCOINCOUNT                  EQU $07
DEF ENDT_RTN_AWARDEXTRA                      EQU $08
DEF ENDT_RTN_WALKOUTL                        EQU $09
                                             
; post treasure room                         
DEF END2_RTN_MOVEINR                         EQU $00
DEF END2_RTN_WANTMONEY                       EQU $01
DEF END2_RTN_THROWMONEYBAGS                  EQU $02
DEF END2_RTN_FLYMONEYBAGS                    EQU $03
DEF END2_RTN_FLASHBG                         EQU $04
DEF END2_RTN_POINTSPEAK                      EQU $05
DEF END2_RTN_PLNOD                           EQU $06
DEF END2_RTN_MOVEOUTR                        EQU $07
                                             
; endings                                    
DEF END3_RTN_MOVEINR                         EQU $00
DEF END3_RTN_MARKDOWN                        EQU $01
DEF END3_RTN_JUMPR                           EQU $02 ; Good ending - 4-5 moneybags 
DEF END3_RTN_JUMPL                           EQU $03
DEF END3_RTN_THUMBSUP                        EQU $04 ; Walk during credits (good or bad endings)
DEF END3_RTN_FAIL                            EQU $05 ; Bad ending - 1-2 moneybags
DEF END3_RTN_JUMPV                           EQU $06 ; Good ending - 3 moneybags
                                             
; perfect ending                             
DEF END4_RTN_MOVEINR                         EQU $00
DEF END4_RTN_SCROLL                          EQU $01
DEF END4_RTN_PLJUMPUP                        EQU $02
DEF END4_RTN_PLTHUMBSUP                      EQU $03
DEF END4_RTN_PLJUMPDOWN                      EQU $04
DEF END4_RTN_WAITTOCREDITS                   EQU $05
                                             
; credits routines -- bank $1F               
DEF CRED_RTN_THUMBSUP                        EQU $00
DEF CRED_RTN_WALK                            EQU $01
                                             
; credits routines -- bank $01               
DEF GM_CREDITS_INIT                          EQU $00 ; Initialize credits
DEF GM_CREDITS_BLANKBOX                      EQU $01 ; Create black area for text
DEF GM_CREDITS_INITWRITEROW1                 EQU $02 ; Setup first row write
DEF GM_CREDITS_WRITEROW1                     EQU $03 ; Write and scroll first row
DEF GM_CREDITS_INITWRITEROW2                 EQU $04 ; Setup second row write
DEF GM_CREDITS_SCROLLROW2                    EQU $05 ; Scroll second row
DEF GM_CREDITS_CHKLINEEND                    EQU $06 ; Displays text, then does something depending on the line terminator type
DEF GM_CREDITS_SCROLLOUTROW2                 EQU $07 ; Terminator Type 00 - Scroll out row 2
DEF GM_CREDITS_BLANKBOXROW2                  EQU $08 ; Clear text
DEF GM_CREDITS_SCROLLOUTBOTHROWS             EQU $09 ; Terminator Type 01 - Scroll out both rows
DEF GM_CREDITS_PRELASTMSG                    EQU $0A ; Terminator type 02 - Wait longer, then determine last message
DEF GM_CREDITS_HALT                          EQU $0B ; Terminator type 03 - wait indefinitely
                                             
; ------------------------------------------------------------
                                             
DEF GM_LEVELDOOR_OBJFADEOUT                  EQU $00
DEF GM_LEVELDOOR_LEVELFADEOUT                EQU $01
DEF GM_LEVELDOOR_ROOMLOAD                    EQU $02
DEF GM_LEVELDOOR_LEVELFADEIN                 EQU $03
DEF GM_LEVELDOOR_CHKBREAKBLOCK               EQU $04
DEF GM_LEVELDOOR_OBJFADEIN                   EQU $05
DEF GM_LEVELDOOR_END                         EQU $06
                                             
; ------------------------------------------------------------
                                             
DEF GM_TREASURE_INIT                         EQU $00
DEF GM_TREASURE_FADEOUTOBJ                   EQU $01
DEF GM_TREASURE_FADEOUTBG                    EQU $02
DEF GM_TREASURE_INITTRROOM                   EQU $03
DEF GM_TREASURE_TRROOM                       EQU $04
                                             
DEF GM_TREASURE_TRROOM_WALKINR               EQU $00
DEF GM_TREASURE_TRROOM_PLACT                 EQU $01
DEF GM_TREASURE_TRROOM_MOVEDOWN              EQU $02
DEF GM_TREASURE_TRROOM_WAITTREASURE          EQU $03
DEF GM_TREASURE_TRROOM_WALKOUTR              EQU $04
; ------------------------------------------------------------
                                             
DEF GM_LEVELENTRANCE_FADEOUTOBJ              EQU $00
DEF GM_LEVELENTRANCE_FADEOUTBG               EQU $01
DEF GM_LEVELENTRANCE_EXITTOMAP               EQU $02
                                             
; ------------------------------------------------------------
                                             
; ============================================================
;     Mode specific enums                    
; ============================================================
; TITLE SCREEN                               
                                             
                                             
DEF TITLE_MODE_INIT                          EQU $00
DEF TITLE_MODE_MAIN                          EQU $01
DEF TITLE_MODE_INTRO                         EQU $02
                                             
; Return values for the title screen code..  
; Specifies the action id for switching modes from the title screen
DEF TITLE_NEXT_NONE                          EQU $00
DEF TITLE_NEXT_DEMO                          EQU $01
DEF TITLE_NEXT_SAVE                          EQU $02
DEF TITLE_NEXT_INTRO                         EQU $03
                                             
; ------------------------------------------------------------
                                             
; Sprite mappings for the ship               
; Ship OBJ Frame                             
DEF INTRO_SOF_NONE                           EQU $00
DEF INTRO_SOF_MAIN0                          EQU $01
DEF INTRO_SOF_MAIN1                          EQU $02
DEF INTRO_SOF_DUCKR1                         EQU $03
DEF INTRO_SOF_DUCKRBACK1                     EQU $04
DEF INTRO_SOF_DUCKLOOK                       EQU $05
DEF INTRO_SOF_DUCKNOTICE                     EQU $06
DEF INTRO_SOF_DUCKPANICR                     EQU $07
DEF INTRO_SOF_DUCKRBACK2                     EQU $08
DEF INTRO_SOF_DUCKPANICL                     EQU $09
DEF INTRO_SOF_DUCKLBACK                      EQU $0A
DEF INTRO_SOF_DUCKHIT                        EQU $0B
DEF INTRO_SOF_DUCKREVERSE                    EQU $0C
DEF INTRO_SOF_WATER                          EQU $0D
DEF INTRO_SOF_DUCKWATER                      EQU $0E
; ------------------------------------------------------------
; Wario OBJ Frame                            
DEF INTRO_WOF_NONE                           EQU $00
DEF INTRO_WOF_BOATROW0                       EQU $01
DEF INTRO_WOF_BOATROW1                       EQU $02
DEF INTRO_WOF_BOATROW2                       EQU $03
DEF INTRO_WOF_BOATDASH                       EQU $04
DEF INTRO_WOF_BOATSTAND                      EQU $05
DEF INTRO_WOF_JUMP                           EQU $06
DEF INTRO_WOF_STAND                          EQU $07
DEF INTRO_WOF_FRONT                          EQU $08
DEF INTRO_WOF_THUMBSUP                       EQU $09
DEF INTRO_WOF_THUMBSUP2                      EQU $0A
                                             
; ============================================================
; SAVE SELECT                                
                                             
; X Coords for the pipe                      
DEF SAVE_PIPE1_X                             EQU $24
DEF SAVE_PIPE2_X                             EQU $44
DEF SAVE_PIPE3_X                             EQU $64
DEF SAVE_PIPEBOMB_X                          EQU $8C
DEF SAVE_PIPE_XOFFSET                        EQU $20
                                             
; Player action in the save select screen    
DEF SAVE_PL_ACT_NONE                         EQU $00
DEF SAVE_PL_ACT_MOVERIGHT                    EQU $01
DEF SAVE_PL_ACT_MOVELEFT                     EQU $02
DEF SAVE_PL_ACT_JUMPTOBOMB                   EQU $03
DEF SAVE_PL_ACT_JUMPFROMBOMB                 EQU $04
DEF SAVE_PL_ACT_ENTERPIPE                    EQU $05
DEF SAVE_PL_ACT_EXITPIPE                     EQU $06
DEF SAVE_PL_ACT_EXITPIPEJUMP                 EQU $07
                                             
; ============================================================
; MAP SCREEN                                 
                                             
; ------------------------------------------------------------
                                             
; Overworld positions ( MapId / WorldId )    
DEF MAP_OWP_RICEBEACH                        EQU $00
DEF MAP_OWP_MTTEAPOT                         EQU $01
DEF MAP_OWP_STOVECANYON                      EQU $02
DEF MAP_OWP_PARSLEYWOODS                     EQU $03
DEF MAP_OWP_SSTEACUP                         EQU $04
DEF MAP_OWP_SHERBETLAND                      EQU $05
DEF MAP_OWP_SYRUPCASTLE                      EQU $06
DEF MAP_OWP_BRIDGE                           EQU $07
                                             
; ------------------------------------------------------------
                                             
; Bit numbers for the overworld completion status bitmask
DEF MAP_CLRB_RICEBEACH                       EQU 0
DEF MAP_CLRB_MTTEAPOT                        EQU 1
DEF MAP_CLRB_STOVECANYON                     EQU 2
DEF MAP_CLRB_SSTEACUP                        EQU 3
DEF MAP_CLRB_PARSLEYWOODS                    EQU 4
DEF MAP_CLRB_SHERBETLAND                     EQU 5
DEF MAP_CLRB_SYRUPCASTLE                     EQU 6
                                             
; ------------------------------------------------------------
                                             
; Cutscene ID for Syrup Castle               
; This is because there is no separate mode for the cutscene in the Map Mode list and the normal Syrup Castle mode is used instead.
; The modes which would have been used ($1B and $1D) are dummy.
                                             
DEF MAP_SCC_NONE                             EQU 0
DEF MAP_SCC_01                               EQU 1
DEF MAP_SCC_C38CLEAR                         EQU 2
DEF MAP_SCC_C39CLEAR                         EQU 3
DEF MAP_SCC_ENDING                           EQU 4
                                             
; ------------------------------------------------------------
                                             
; Wario animation IDs in the map screen      
; enum MWA                                   
DEF MAP_MWA_FRONT                            EQU $00
DEF MAP_MWA_RIGHT                            EQU $01
DEF MAP_MWA_LEFT                             EQU $02
DEF MAP_MWA_BACK                             EQU $03
DEF MAP_MWA_FRONT2                           EQU $04                  ; Points to the same data as MWA_FRONT. Workaround for how Map_GetWarioInitialAnim works.
DEF MAP_MWA_UNUSED_V1                        EQU $05
DEF MAP_MWA_UNUSED_H3                        EQU $06
DEF MAP_MWA_UNUSED_H1                        EQU $07
DEF MAP_MWA_UNUSED_H2                        EQU $08
DEF MAP_MWA_UNUSED_H1C                       EQU $09                  ; C stands for "Copy", as it's identical to H1
DEF MAP_MWA_UNUSED_H2C                       EQU $0A
DEF MAP_MWA_UNUSED_H3C                       EQU $0B
DEF MAP_MWA_WATERFRONT                       EQU $0C
DEF MAP_MWA_WATERBACK                        EQU $0D
DEF MAP_MWA_HIDE                             EQU $0E
                                             
; ------------------------------------------------------------
                                             
; Wario animation IDs in the second part of the ending (which takes place in the map screen).
; Unlike the first part of the ending (which reuses the normal mapping frames) and has
; the lamp as a separate mapping, the mapping defs for these contain the lamp directly.
DEF MAP_MWEA_BACK                            EQU 0
DEF MAP_MWEA_BACKLEFT                        EQU 1
DEF MAP_MWEA_BACKRIGHT                       EQU 2
DEF MAP_MWEA_JUMP                            EQU 3
DEF MAP_MWEA_SHRUG                           EQU 4
DEF MAP_MWEA_FRONT                           EQU 5
                                             
; ------------------------------------------------------------
                                             
; Map Path Control values                    
; Special values to control movement at the start of a path segment.
DEF MAP_MPC_UP                               EQU $E0
DEF MAP_MPC_DOWN                             EQU $EE
DEF MAP_MPC_RIGHT                            EQU $F0
DEF MAP_MPC_LEFT                             EQU $FE
DEF MAP_MPC_STOP                             EQU $FF
                                             
; ------------------------------------------------------------
                                             
; Map Path Return Control values             
; Special values to specify the action to perform when a MPC_STOP command is reached.
DEF MAP_MPR_ENTERBRIDGE                      EQU $F8
DEF MAP_MPR_C14RIGHT                         EQU $F9
DEF MAP_MPR_C08LEFT                          EQU $FA
DEF MAP_MPR_EXITSUBMAP                       EQU $FD
DEF MAP_MPR_UNUSED_ALTID                     EQU $FF
                                             
; ------------------------------------------------------------
                                             
; Free View Return type.                     
; Can be                                     
;  - "Soft", if the mode is simply disabled (when no movement happened)
;  - "Hard", if a fade out will be performed 
DEF MAP_FVR_SOFT                             EQU $0F
DEF MAP_FVR_HARD                             EQU $FF
DEF MAP_FVR_ANY                              EQU $0F
DEF MAP_FVR_HARDM                            EQU $F0
                                             
; ============================================================
; GAMEPLAY                                   
                                             
; Current powerup state                      
DEF PL_POW_NONE                              EQU $00
DEF PL_POW_GARLIC                            EQU $01
DEF PL_POW_BULL                              EQU $02
DEF PL_POW_JET                               EQU $03
DEF PL_POW_DRAGON                            EQU $04
                                             
; Player action (sPlAction values)           
DEF PL_ACT_STAND                             EQU $00
DEF PL_ACT_WALK                              EQU $01
DEF PL_ACT_DUCK                              EQU $02 ; also duck walk
DEF PL_ACT_CLIMB                             EQU $03
DEF PL_ACT_SWIM                              EQU $04
DEF PL_ACT_JUMP                              EQU $05
DEF PL_ACT_ACTMAIN                           EQU $06
DEF PL_ACT_HARDBUMP                          EQU $07
DEF PL_ACT_JUMPONACT                         EQU $08
DEF PL_ACT_DEAD                              EQU $09
DEF PL_ACT_CLING                             EQU $0A
DEF PL_ACT_DASH                              EQU $0B
DEF PL_ACT_DASHREBOUND                       EQU $0C
DEF PL_ACT_DASHJUMP                          EQU $0D
DEF PL_ACT_DASHJET                           EQU $0E
DEF PL_ACT_ACTGRAB2                          EQU $0F
DEF PL_ACT_THROW                             EQU $10
DEF PL_ACT_SAND                              EQU $11
DEF PL_ACT_TREASUREGET                       EQU $12
                                             
; Swimming ground movement                   
DEF PL_SGM_NONE                              EQU $00
DEF PL_SGM_STAND                             EQU $01
DEF PL_SGM_DUCK                              EQU $02
DEF PL_SGM_WALK                              EQU $03
                                             
; Hurt type / overlaps a bit with the hard bump effect
DEF PL_HT_BGHURT                             EQU $01 ; Damaging block
DEF PL_HT_BUMP                               EQU $02 ; Special value marking the middle of a bump, or one against a solid actor
DEF PL_HT_ACTHURT                            EQU $03 ; Damaging actor
                                             
; Held mode (sActHeld)                       
DEF PL_HLD_NONE                              EQU $00
DEF PL_HLD_WAITHOLD                          EQU $01
DEF PL_HLD_HOLDING                           EQU $02
DEF PL_HLD_SPEC_NOTHROW                      EQU $03 ; Special value used by Act_Lamp. Acts like $02 otherwise.
                                             
DEF LOCK_CLOSED                              EQU $00
DEF LOCK_OPENING                             EQU $01
DEF LOCK_OPEN                                EQU $02
DEF CHECKPOINT_NONE                          EQU $00
DEF CHECKPOINT_ACTIVATING                    EQU $01
DEF CHECKPOINT_ACTIVE                        EQU $02
                                             
; Special level clear modes (sLvlSpecClear)  
DEF LVLCLEAR_NONE                            EQU $00
DEF LVLCLEAR_BOSS                            EQU $01 ; Boss clear / debug level clear
DEF LVLCLEAR_BIGSWITCH                       EQU $02 ; Big switch hit
DEF LVLCLEAR_FINALDEAD                       EQU $03 ; Final boss defeated (transform + walk to lamp)
DEF LVLCLEAR_FINALEXITTOMAP                  EQU $04 ; Fades out to the map screen
                                             
;                                            
DEF BG_BLOCK_WIDTH                           EQU $02 ; Tiles for a block
DEF BG_BLOCK_HEIGHT                          EQU $02
DEF BG_BLOCK_LENGTH                          EQU BG_BLOCK_WIDTH*BG_BLOCK_HEIGHT
DEF BG_BLOCKCOUNT_H                          EQU BG_TILECOUNT_H / 2
DEF BG_BLOCKCOUNT_V                          EQU BG_TILECOUNT_V / 2
                                             
; Tile IDs expected at fixed locations       
DEF TILE_SWITCH                              EQU $04
                                             
                                             
DEF TILEID_SWITCHBLOCKACTIVE                 EQU $04
DEF TILEID_SWITCHBLOCK                       EQU $1C
DEF TILEID_GENIE_SOLID_UL                    EQU $0B
DEF TILEID_GENIE_SOLID_UR                    EQU $0C
DEF TILEID_GENIE_SOLID_DL                    EQU $1B
DEF TILEID_GENIE_SOLID_DR                    EQU $1C
DEF TILEID_DIGITS                            EQU $B0 ; Tile ID base for digits in main gameplay
DEF TILEID_TRROOM_DIGITS                     EQU $D0 ; Time ID base for digits in treasure room
                                             
; Level size                                 
DEF LEVEL_WIDTH                              EQU $1000
DEF LEVEL_HEIGHT                             EQU $0200
DEF BLOCK_WIDTH                              EQU $10
DEF BLOCK_HEIGHT                             EQU $10
                                             
DEF LEVEL_BLOCK_HCOUNT                       EQU (LEVEL_WIDTH / BLOCK_WIDTH)
DEF LEVEL_BLOCK_VCOUNT                       EQU (LEVEL_HEIGHT / BLOCK_HEIGHT)
DEF LEVEL_LAYOUT_LENGTH                      EQU (LEVEL_BLOCK_HCOUNT*LEVEL_BLOCK_VCOUNT) ; $2000
DEF LEVEL_BLOCK_HMIN                         EQU $00
DEF LEVEL_BLOCK_HMAX                         EQU LEVEL_BLOCK_HCOUNT - 1
DEF LEVEL_BLOCK_VMIN                         EQU $00
DEF LEVEL_BLOCK_VMAX                         EQU LEVEL_BLOCK_VCOUNT - 1
                                             
; hScroll* = sLvlScroll_* - LVLSCROLL_*OFFSET
; They picked the center of the screen for this, which gives enough room to avoid underflow during calculations.
DEF LVLSCROLL_XOFFSET                        EQU SCREEN_H/2
DEF LVLSCROLL_YOFFSET                        EQU SCREEN_V/2
                                             
DEF LVLSCROLL_XBLOCKOFFSET                   EQU LVLSCROLL_XOFFSET/BLOCK_WIDTH
DEF LVLSCROLL_YBLOCKOFFSET                   EQU LVLSCROLL_YOFFSET/BLOCK_HEIGHT
                                             
; Level scroll mode                          
DEF LVLSCROLL_SEGSCRL                        EQU $00
DEF LVLSCROLL_TRAIN                          EQU $01
DEF LVLSCROLL_FREE                           EQU $10
DEF LVLSCROLL_AUTOR                          EQU $30
DEF LVLSCROLL_AUTOL                          EQU $31
DEF LVLSCROLL_AUTOR2                         EQU $40
DEF LVLSCROLL_NONE                           EQU $FF ; Boss mode as well
DEF LVLSCROLL_CHKAUTO                        EQU $20
                                             
; Generic direction indicators               
DEF DIRB_R                                   EQU 0
DEF DIRB_L                                   EQU 1
DEF DIRB_U                                   EQU 2
DEF DIRB_D                                   EQU 3
DEF DIR_R                                    EQU 1 << DIRB_R
DEF DIR_L                                    EQU 1 << DIRB_L
DEF DIR_U                                    EQU 1 << DIRB_U
DEF DIR_D                                    EQU 1 << DIRB_D
DEF DIR_NONE                                 EQU 0
; Actor interaction direction                
DEF ACTINTB_R                                EQU DIRB_R + 4
DEF ACTINTB_L                                EQU DIRB_L + 4
DEF ACTINTB_U                                EQU DIRB_U + 4
DEF ACTINTB_D                                EQU DIRB_D + 4
DEF ACTINT_R                                 EQU 1 << ACTINTB_R
DEF ACTINT_L                                 EQU 1 << ACTINTB_L
DEF ACTINT_U                                 EQU 1 << ACTINTB_U
DEF ACTINT_D                                 EQU 1 << ACTINTB_D
                                             
; Collision type (Actor - Standard)          
; May be different for each side, depending on collision bitmask
;ACTCOLI_NONE                                EQU $00
DEF ACTCOLI_NORM                             EQU $01
DEF ACTCOLI_BUMP                             EQU $02
DEF ACTCOLI_DAMAGE                           EQU $03
                                             
; Masks to filter standard collision types for a direction
DEF ACTCOLIM_D                               EQU %11000000
DEF ACTCOLIM_U                               EQU %00110000
DEF ACTCOLIM_L                               EQU %00001100
DEF ACTCOLIM_R                               EQU %00000011
                                             
DEF ACTCOLIMB_D                              EQU 6
DEF ACTCOLIMB_U                              EQU 4
DEF ACTCOLIMB_L                              EQU 2
DEF ACTCOLIMB_R                              EQU 0
                                             
                                             
; For marking the collision dealt to the player in sActTmpColiDir
; DirBit                                     
DEF ACTCOLIDB_NONE                           EQU 4
DEF ACTCOLIDB_NORM                           EQU 5
DEF ACTCOLIDB_BUMP                           EQU 6
DEF ACTCOLIDB_DAMAGE                         EQU 7
                                             
; Collision type (Actor - Special), for PlActColiId_CheckType
                                             
DEF ACTCOLI_NONE                             EQU $00
DEF ACTCOLI_TREASURE_START                   EQU $01
DEF ACTCOLI_TREASURE_END                     EQU $10
DEF ACTCOLI_TOPSOLID_START                   EQU $10
DEF ACTCOLI_TOPSOLID                         EQU $10
DEF ACTCOLI_UNUSED_TYPE11                    EQU $11
DEF ACTCOLI_TOPSOLIDHIT                      EQU $12
DEF ACTCOLI_BIGBLOCK                         EQU $13
DEF ACTCOLI_LOCK                             EQU $14
DEF ACTCOLI_TOPSOLID_END                     EQU $20
DEF ACTCOLI_ITEM_START                       EQU $20
DEF ACTCOLI_KEY                              EQU $20
DEF ACTCOLI_10HEART                          EQU $21
DEF ACTCOLI_STAR                             EQU $22
DEF ACTCOLI_COIN                             EQU $23
DEF ACTCOLI_10COIN                           EQU $24
DEF ACTCOLI_BIGCOIN                          EQU $25
DEF ACTCOLI_BIGHEART                         EQU $26
DEF ACTCOLI_ITEM_END                         EQU $30
DEF ACTCOLI_POW_START                        EQU $30
DEF ACTCOLI_POW                              EQU $30
DEF ACTCOLI_POW_GARLIC                       EQU ACTCOLI_POW + PL_POW_GARLIC - 1 ; $30
DEF ACTCOLI_POW_BULL                         EQU ACTCOLI_POW + PL_POW_BULL   - 1 ; $31
DEF ACTCOLI_POW_JET                          EQU ACTCOLI_POW + PL_POW_JET    - 1 ; $32
DEF ACTCOLI_POW_DRAGON                       EQU ACTCOLI_POW + PL_POW_DRAGON - 1 ; $33
                                             
; Collision type (Ladder special)            
DEF COLILD_SOLID                             EQU %0000
DEF COLILD_LADDER                            EQU %0001
DEF COLILD_LADDERTOP                         EQU %0010
DEF COLILDB_LADDER                           EQU 0
DEF COLILDB_LADDERTOP                        EQU 1
DEF COLILDB_LADDERANY2                       EQU 2
DEF COLILD_LADDER2                           EQU %0101
DEF COLILD_LADDERTOP2                        EQU %0110
                                             
; Base block collision type                  
DEF COLI_EMPTY                               EQU $00
DEF COLI_SOLID                               EQU $01
DEF COLI_WATER                               EQU $02
                                             
; Block type                                 
DEF BLOCKID_SOLID_START                      EQU $00
DEF BLOCKID_SOLID_END                        EQU $28
DEF BLOCKID_ITEMBOX                          EQU $28
DEF BLOCKID_BREAKHARD7F                      EQU $29
DEF BLOCKID_BREAK7F                          EQU $2A
DEF BLOCKID_BREAKHARD7E                      EQU $2B
DEF BLOCKID_BREAK7E                          EQU $2C
DEF BLOCKID_BREAKTODOORTOP                   EQU $2D
DEF BLOCKID_BREAKTODOOR                      EQU $2E
DEF BLOCKID_BOUNCE                           EQU $2F
DEF BLOCKID_AUTOLEFT                         EQU $30
DEF BLOCKID_AUTORIGHT                        EQU $31
DEF BLOCKID_SWITCH0T1                        EQU $32
DEF BLOCKID_BRIDGE                           EQU $33
DEF BLOCKID_ICE0                             EQU $34
DEF BLOCKID_ICE1                             EQU $35
DEF BLOCKID_ICE2                             EQU $36
DEF BLOCKID_UNUSED_ITEMBOXHIDE1              EQU $37 ; [TCRF] Unused duplicate of the Item box. Every block16 data defines it with blank tiles.
DEF BLOCKID_UNUSED_SWITCH1T1                 EQU $38 ; [TCRF] The unused third type of switch block.
DEF BLOCKID_SWITCH0T0                        EQU $39
DEF BLOCKID_TIMED0                           EQU $3A
DEF BLOCKID_TIMED1                           EQU $3B
DEF BLOCKID_ITEMUSED                         EQU $3C
DEF BLOCKID_UNUSED_ACTEMPTY                  EQU $3D ; [TCRF] Treated as solid by the player, as empty by actors.
DEF BLOCKID_SAND                             EQU $3E
DEF BLOCKID_SANDSPIKE                        EQU $3F
DEF BLOCKID_MISCSOLID_END                    EQU $40
                                             
DEF BLOCKID_TOPSOLID                         EQU $40
DEF BLOCKID_TOPSOLID0                        EQU $40
DEF BLOCKID_TOPSOLID1                        EQU $41
DEF BLOCKID_TOPSOLID2                        EQU $42
DEF BLOCKID_TOPSOLID3                        EQU $43
DEF BLOCKID_TOPSOLID_END                     EQU $44
DEF BLOCKID_LADDER                           EQU $44
DEF BLOCKID_LADDERTOP                        EQU $45
DEF BLOCKID_COIN7F                           EQU $46
DEF BLOCKID_COIN7E                           EQU $47
DEF BLOCKID_DOOR                             EQU $48
DEF BLOCKID_ITEMBOXHIDE                      EQU $49
                                             
DEF BLOCKID_WATER_START                      EQU $4A
DEF BLOCKID_WATERITEMBOXHIDE                 EQU $4A
DEF BLOCKID_WATERDOOR                        EQU $4B
DEF BLOCKID_WATERCUR                         EQU $4C
DEF BLOCKID_WATERCURU                        EQU $4C
DEF BLOCKID_WATERCURD                        EQU $4D
DEF BLOCKID_WATERCURL                        EQU $4E
DEF BLOCKID_WATERCURR                        EQU $4F
DEF BLOCKID_WATERBREAKHARD58                 EQU $50
DEF BLOCKID_WATERBREAK58                     EQU $51
DEF BLOCKID_WATERBREAKTODOORTOP              EQU $52
DEF BLOCKID_WATERCOIN                        EQU $53
DEF BLOCKID_WATERBREAKTODOOR                 EQU $54
DEF BLOCKID_WATER1                           EQU $55 ; With decoration
DEF BLOCKID_WATER2                           EQU $56 ; With decoration (top part of bottomless pit)
DEF BLOCKID_WATER3                           EQU $57 ; With decoration (bottom part of bottomless pit)
DEF BLOCKID_WATER                            EQU $58 ; Standard water block
DEF BLOCKID_WATERSPIKE                       EQU $59
DEF BLOCKID_UNUSED_WATERSPIKE2               EQU $5A ; [TCRF] Another underwater spike block
DEF BLOCKID_WATERDOORTOP                     EQU $5B
DEF BLOCKID_WATER_END                        EQU $5C
                                             
DEF BLOCKID_INSTAKILL                        EQU $5C
DEF BLOCKID_SPIKE                            EQU $5D
DEF BLOCKID_SPIKE2                           EQU $5E
DEF BLOCKID_SPIKEHIDE                        EQU $5F
DEF BLOCKID_EMPTY_START                      EQU $60
                                             
DEF BLOCKID_EMPTY_7E                         EQU $7E
DEF BLOCKID_EMPTY_7F                         EQU $7F
DEF BLOCKID_EMPTY_END                        EQU $7F
DEF BLOCKID_MASK                             EQU $7F
                                             
; Special door transition types              
DEF DOORSPEC_ENTRANCE                        EQU $20
DEF DOORSPEC_LVLCLEAR                        EQU $21
DEF DOORSPEC_LVLCLEARALT                     EQU $22
DEF DOORSPEC_INVALID                         EQU $23
DEF DOORSPEC_NONE                            EQU $FF
                                             
; Demo mode status                           
DEF DEMOMODE_NONE                            EQU $00
; [POI] Suspicious lack of modes $01 and $02, likely DEMOMODE_WAITRECORD and DEMOMODE_RECORD respectively.
DEF DEMOMODE_WAITPLAYBACK                    EQU $03
DEF DEMOMODE_PLAYBACK                        EQU $04
                                             
; ============================================================
; COURSE CLEAR SCREEN                        
                                             
; X positions                                
DEF COURSECLR_XPOS_SIDER                     EQU $88    ; Right of second door, for intro
DEF COURSECLR_XPOS_SIDEL                     EQU $28    ; Left of first door, for intro
DEF COURSECLR_XPOS_COIN                      EQU $40     ; Coin bonus door
DEF COURSECLR_XPOS_HEART                     EQU $70    ; Heart bonus door
DEF COURSECLR_XPOS_EXIT                      EQU $C0     ; Off-screen right
                                             
; ============================================================
; BONUS GAME                                 
                                             
; Player position in the coin bonus game     
DEF COINBONUS_PLPOS_EXIT                     EQU $00
DEF COINBONUS_PLPOS_LEFT                     EQU $01
DEF COINBONUS_PLPOS_MID                      EQU $02
DEF COINBONUS_PLPOS_RIGHT                    EQU $03
                                             
; Item types                                 
DEF COINBONUS_ITEM_10TON                     EQU $00
DEF COINBONUS_ITEM_MONEYBAG                  EQU $01
                                             
; Player X position hotspots in the coin bonus game
DEF COINBONUS_PLXPOS_EXIT                    EQU $0C
DEF COINBONUS_PLXPOS_LEFT                    EQU $2F
DEF COINBONUS_PLXPOS_MID                     EQU $4C
DEF COINBONUS_PLXPOS_RIGHT                   EQU $67
                                             
; Item *OBJ frames*                          
DEF COINBONUS_OBJ_ITEM_NONE                  EQU $00
DEF COINBONUS_OBJ_ITEM_10TON                 EQU COINBONUS_ITEM_10TON+1
DEF COINBONUS_OBJ_ITEM_MONEYBAG              EQU COINBONUS_ITEM_MONEYBAG+1
                                             
                                             
; Specifies what tile definitions to use in the coin bonus game
DEF COINBONUS_BUCKET_NOCHANGE                EQU $00
DEF COINBONUS_BUCKET_PULL                    EQU $01
DEF COINBONUS_BUCKET_NORMAL                  EQU $02
                                             
; ------------------------------------------------------------
                                             
                                             
DEF HEARTBONUS_SEL_HARD                      EQU $00
DEF HEARTBONUS_SEL_MED                       EQU $01
DEF HEARTBONUS_SEL_EASY                      EQU $02
DEF HEARTBONUS_SEL_EXIT                      EQU $03
                                             
DEF HEARTBONUS_TEXT_NONE                     EQU $00
DEF HEARTBONUS_TEXT_READY                    EQU $01
DEF HEARTBONUS_TEXT_GO                       EQU $02
                                             
DEF HEARTBONUS_PLMODE_MOVE                   EQU $00
DEF HEARTBONUS_PLMODE_LOCK                   EQU $01
DEF HEARTBONUS_PLMODE_THROW                  EQU $02
                                             
                                             
DEF HEARTBONUS_OBJ_ENEMYWALK0                EQU $01
DEF HEARTBONUS_OBJ_ENEMYWALK1                EQU $02
DEF HEARTBONUS_OBJ_ENEMYWALK2                EQU $03
DEF HEARTBONUS_OBJ_ENEMYSTUN                 EQU $04
                                             
DEF HEARTBONUS_OBJ_BOMB0                     EQU $01
DEF HEARTBONUS_OBJ_BOMB1                     EQU $02
DEF HEARTBONUS_OBJ_UNUSED_BOMBEXPL0          EQU $03
DEF HEARTBONUS_OBJ_BOMBEXPL1                 EQU $04
DEF HEARTBONUS_OBJ_BOMBEXPL2                 EQU $05
DEF HEARTBONUS_OBJ_BOMBEXPL3                 EQU $06
                                             
                                             
                                             
DEF HEARTBONUS_OBJ_BOMBLIGHT0                EQU $01
DEF HEARTBONUS_OBJ_BOMBLIGHT1                EQU $02
                                             
DEF HEARTBONUS_OBJ_BOMBICON_BOMB             EQU $01
DEF HEARTBONUS_OBJ_BOMBICON_HIT              EQU $02
DEF HEARTBONUS_OBJ_BOMBICON_MISS             EQU $03
                                             
                                             
DEF HEARTBONUS_BOMBPATH_BAD0                 EQU $00
DEF HEARTBONUS_BOMBPATH_BAD1                 EQU $01
DEF HEARTBONUS_BOMBPATH_BAD2                 EQU $02
DEF HEARTBONUS_BOMBPATH_BAD3                 EQU $03
DEF HEARTBONUS_BOMBPATH_GOOD0                EQU $04
DEF HEARTBONUS_BOMBPATH_GOOD1                EQU $05
DEF HEARTBONUS_BOMBPATH_GOOD2                EQU $06
DEF HEARTBONUS_BOMBPATH_GOOD3                EQU $07
                                             
; ============================================================
; TREASURE ROOM                              
                                             
; Relative to LevelBlock_TrRoom              
DEF TRROOM_TILEID_DIGITS                     EQU $D0
                                             
DEF TRROOM_BLOCKID_TREASURE_C                EQU $0E
DEF TRROOM_BLOCKID_TREASURE_I                EQU $0F
DEF TRROOM_BLOCKID_TREASURE_F                EQU $10
DEF TRROOM_BLOCKID_TREASURE_O                EQU $11
DEF TRROOM_BLOCKID_TREASURE_A                EQU $12
DEF TRROOM_BLOCKID_TREASURE_N                EQU $13
DEF TRROOM_BLOCKID_TREASURE_H                EQU $14
DEF TRROOM_BLOCKID_TREASURE_M                EQU $15
DEF TRROOM_BLOCKID_TREASURE_L                EQU $16
DEF TRROOM_BLOCKID_TREASURE_K                EQU $17
DEF TRROOM_BLOCKID_TREASURE_B                EQU $18
DEF TRROOM_BLOCKID_TREASURE_D                EQU $19
DEF TRROOM_BLOCKID_TREASURE_G                EQU $1A
DEF TRROOM_BLOCKID_TREASURE_J                EQU $1B
DEF TRROOM_BLOCKID_TREASURE_E                EQU $1C
DEF TRROOM_BLOCKID_TREASURE_EMPTY            EQU $1D
; ============================================================
                                             
DEF END_OBJ_HELD_LAMP                        EQU $01
DEF END_OBJ_HELD_LAMPINV                     EQU $02
DEF END_OBJ_HELD_MONEYBAG1                   EQU $03
DEF END_OBJ_HELD_MONEYBAG2                   EQU $04
DEF END_OBJ_HELD_MONEYBAG3                   EQU $05
DEF END_OBJ_HELD_MONEYBAG4                   EQU $06
DEF END_OBJ_HELD_MONEYBAG5                   EQU $07
DEF END_OBJ_HELD_MONEYBAG6                   EQU $08
                                             
DEF END_CASTLE_BIRDHOUSE                     EQU $01
DEF END_CASTLE_TREEHOUSE                     EQU $02
DEF END_CASTLE_HOUSE                         EQU $03
DEF END_CASTLE_PAGODA                        EQU $04
DEF END_CASTLE_BIG                           EQU $05
DEF END_CASTLE_PLANET                        EQU $06
                                             
                                             
DEF END_OBJ_CLOUDA0                          EQU $01
DEF END_OBJ_CLOUDA1                          EQU $02
DEF END_OBJ_CLOUDB0                          EQU $03
DEF END_OBJ_CLOUDB1                          EQU $04
DEF END_OBJ_CLOUDC0                          EQU $05
DEF END_OBJ_CLOUDC1                          EQU $06
DEF END_OBJ_WLOGO                            EQU $07
DEF END_OBJ_WLOGOINV                         EQU $08
                                             
DEF END_OBJ_BALLOONTHINK                     EQU $01
DEF END_OBJ_BALLOONSPEAK                     EQU $02
DEF END_OBJ_BALLOONGENIE                     EQU $03
                                             
                                             
DEF END_OBJ_GENIEFACE_LOOK                   EQU $01      ; Eyes open, mouth closed
DEF END_OBJ_GENIEFACE_LOOKMOUTH              EQU $02 ; Eyes open, mouth open
DEF END_OBJ_GENIEFACE_BLINK                  EQU $03     ; Eyes closed, mouth closed
DEF END_OBJ_GENIEFACE_UNUSED_BLINKMOUTH      EQU $04; Eyes closed, mouth open
                                             
DEF END_GENIE_CLOSED                         EQU $01
DEF END_GENIE_POINT                          EQU $02
DEF END_GENIE_PALM                           EQU $03
                                             
; Credits text next (line) mode              
DEF CTN_CLEARLINE2                           EQU $00
DEF CTN_CLEARBOTH                            EQU $01
DEF CTN_LASTLINE                             EQU $02
DEF CTN_HALT                                 EQU $03
