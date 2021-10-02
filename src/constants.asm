; Keys as they are used in $FF80 and $FF81.
; These are not set up how they are in the hardware.

; Keys (as bit numbers)
KEYB_A           EQU 0
KEYB_B           EQU 1
KEYB_SELECT      EQU 2
KEYB_START       EQU 3
KEYB_RIGHT       EQU 4
KEYB_LEFT        EQU 5
KEYB_UP          EQU 6
KEYB_DOWN        EQU 7
; Keys (values)
KEY_NONE         EQU 0
KEY_A            EQU 1 << KEYB_A
KEY_B            EQU 1 << KEYB_B
KEY_SELECT       EQU 1 << KEYB_SELECT
KEY_START        EQU 1 << KEYB_START
KEY_RIGHT        EQU 1 << KEYB_RIGHT
KEY_LEFT         EQU 1 << KEYB_LEFT
KEY_UP           EQU 1 << KEYB_UP
KEY_DOWN         EQU 1 << KEYB_DOWN

; ------------------------------------------------------------

; Screen update modes
SCRUPD_SCROLL       EQU $01                  ; Normal level scrolling
SCRUPD_NORMHAT      EQU $02                  ; Draw Normal hat
SCRUPD_BULLHAT      EQU $03
SCRUPD_JETHAT       EQU $04
SCRUPD_DRAGHAT      EQU $05
SCRUPD_NORMHAT_SEC  EQU $06               ; Draw the secondary tiles for the normal hat
SCRUPD_BULLHAT_SEC  EQU $07
SCRUPD_JETHAT_SEC   EQU $08
SCRUPD_DRAGHAT_SEC  EQU $09
SCRUPD_CREDITSBOX   EQU $0A               ; Draw the credits textbox area
SCRUPD_CRDTEXT1     EQU $0B                 ; Draw the first row of credits
SCRUPD_CRDTEXT2     EQU $0C                 ; Draw the second row of credits
SCRUPD_SAVEPIPE     EQU $0D                 ; Animate pipes in the save select screen

; sPlHatSwitchDrawMode options
PL_HSD_PRIMARY EQU $00		
PL_HSD_SEC     EQU $01
PL_HSD_END     EQU $02

; Special parallax effect modes
PRX_TRAINMOUNTR  EQU $00
PRX_TRAINMAINR   EQU $01
PRX_TRAINTRACKR  EQU $02
PRX_UNUSED1      EQU $03
PRX_UNUSED0      EQU $04
PRX_BOSS0        EQU $05
PRX_BOSS1        EQU $06
PRX_BOSS2        EQU $07
PRX_BOSS3        EQU $08
PRX_TRAINMOUNTL  EQU $09
PRX_TRAINMAINL   EQU $0A
PRX_TRAINTRACKL  EQU $0B
PRX_CREDMAIN     EQU $0C
PRX_CREDROW1     EQU $0D
PRX_CREDROW2     EQU $0E

; Static Screen event modes
SES_TITLE  EQU $00
SES_BONUS  EQU $01
SES_ENDING EQU $02


; BGM playback actions
BGMACT_FADEOUT   equ 8                  ; Fade out gradually the song

; Special BGM Tables (used under BGM Chunks)
BGMTBLCMD_REDIR         EQU $00F0 ; Next table ptr in the chunk is the offset to the new chunk -- used for looping		
BGMTBLCMD_END           EQU $0000 ; The BGM ends. No more ptrs in the chunk.

; BGM Playback sound commands	
BGMCMD_SETOPTREG     EQU $F1 ; Set other register values (the default only changes pitch/frequency)
BGMCMD_SETLENGTHPTR  EQU $F2 ; Set new BGM length table ptr
BGMCMD_SETPITCH      EQU $F3 ; Set new base pitch
BGMCMD_SETLOOP       EQU $F4 ; Set loop point
BGMCMD_LOOP          EQU $F5 ; Restore loop point
BGMCMD_END           EQU $00 ; Marks the end of a command table
BGMCMD_STOPALL       EQU $F6 ; Stops all currently playing BGM and SFX.
                             ; Command range: $F6-$FF
BGMCMD_NOP			 EQU $F1 ; Immediately skips to the next command.
                             ; Command range: $F1-$F5
BGMCMD_SETLENGTHID   EQU $9F ; Command will be treated as an index to the current BGM length table
                             ; Command range: $9F-$F0
							 
; BGM Playback raw data commands
BGMDATACMD_MUTECH    EQU $01 ; Mute current sound channel.
BGMDATACMD_HIGHENV   EQU $03 ; High envelop option
BGMDATACMD_LOWENV    EQU $05 ; Low envelop option

; BGM post parse commands
; All of these set the pitch in different ways
BGMPP_NONE EQU $00
BGMPP_01 EQU $01
BGMPP_02 EQU $02
BGMPP_03 EQU $03
BGMPP_04 EQU $04
BGMPP_05 EQU $05
BGMPP_06 EQU $06
BGMPP_07 EQU $07
BGMPP_08 EQU $08
BGMPP_09 EQU $09
BGMPP_0A EQU $0A

; ------------------------------------------------------------

; Global sound pause playback commands
; These will trigger special actions
SNDPAUSE_NONE        equ 0
SNDPAUSE_PAUSE       equ 1                         ; Play pause sound and stop all playback
SNDPAUSE_UNPAUSE     equ 2                         ; Play unpause sound and resume all playback
SNDPAUSEB_NOPAUSESFX equ 7    
SNDPAUSE_NOPAUSESFX  equ 1 << SNDPAUSEB_NOPAUSESFX ; Extra flag. If set, the pause/unpause SFX won't be played.

; ------------------------------------------------------------
; BGM / SFX indexes. Remove $1 from these to get the actual BGM / SFX Id

; Game music indexes (remove 1 to get IDs)
BGM_NONE           EQU $FF
BGM_TITLE          EQU $01
BGM_OVERWORLD      EQU $02
BGM_WATER          EQU $03
BGM_COURSE1        EQU $04 ; main theme
BGM_COINVAULT      EQU $05
BGM_INVINCIBILE    EQU $06
BGM_COINGAME       EQU $07 ; end of boss raining coins
BGM_LIFELOST       EQU $08
BGM_SHIP           EQU $09
BGM_LAVA           EQU $0A
BGM_TRAIN          EQU $0B
BGM_COINBONUS      EQU $0C
BGM_LEVELCLEAR     EQU $0D
BGM_BOSSLEVEL      EQU $0E
BGM_TREASURE       EQU $0F
BGM_LAVA2          EQU $10
BGM_BOSS           EQU $11
BGM_BOSSCLEAR      EQU $12 ; level clear for boss levels
BGM_MTTEAPOT       EQU $13
BGM_SHERBETLAND    EQU $14
BGM_RICEBEACH      EQU $15
BGM_CAVE           EQU $16
BGM_COURSE3        EQU $17 ; level 3
BGM_HEARTBONUS     EQU $18
BGM_FINALBOSSINTRO EQU $19
BGM_WORLDCLEAR     EQU $1A
BGM_AMBIENT        EQU $1B
BGM_TREASUREGET    EQU $1C ; and ending jingle
BGM_SYRUPCASTLE    EQU $1D
BGM_FINALLEVEL     EQU $1E
BGM_PARSLEYWOODS   EQU $1F
BGM_INTRO          EQU $20
BGM_STOVECANYON    EQU $21
BGM_COURSE32       EQU $22
BGM_SSTEACUP       EQU $23
BGM_GAMEOVER       EQU $24
BGM_TIMEOVER       EQU $25
BGM_SAVESELECT     EQU $26
BGM_ICE            EQU $27
BGM_FINALBOSS      EQU $28
BGM_CREDITS        EQU $29
BGM_SELECTBONUS    EQU $2A ; bonus game choice in course clear screen
BGM_LEVELENTER     EQU $2B
BGM_CUTSCENE       EQU $2C
BGM_ENDINGGENIE    EQU $2D
BGM_GAMEOVER2      EQU $2E
BGM_ENDINGSTATUE   EQU $2F
BGM_FINALBOSSOUTRO EQU $30 ; scene before the bomb

SFX1_01	EQU $01 ; SFX1_BUMP          ; Bump enemy
SFX1_02 EQU $02 ; SFX1_JUMPONENEMY   ; Jump on an enemy
SFX1_03 EQU $03 ; SFX1_LEVELDOT      ; Level Dot revealed / Title screen -> save select transition
SFX1_04 EQU $04 ; SFX1_HEART         ; Heart box
SFX1_05 EQU $05 ; SFX1_JUMP          ; Wario jump
SFX1_06 EQU $06 ; SFX1_POWERUP       
SFX1_07 EQU $07 ; SFX1_SCROLL        ; Screen scrolling / save select pipe
SFX1_08 EQU $08 ; SFX1_1UP           
SFX1_09 EQU $09 ; SFX1_BOSSDEAD      
SFX1_0A EQU $0A ; SFX1_BUMPBIG       ; Bumping into a big non-enemy actor (skull door, big blocks, ...)
SFX1_0B EQU $0B ; SFX1_GRAB          ; Also various other things
SFX1_0C EQU $0C ; SFX1_0C            ; Throw
SFX1_0D EQU $0D ; SFX1_ITEMBLOCKHIT  
SFX1_0E EQU $0E ; SFX1_GRAB2         ; Copy of $0B for hitting item boxes
SFX1_0F EQU $0F ; SFX1_POUNDONENEMY  ; crush attack over enemy (bull hat)
SFX1_10 EQU $10 ; SFX1_COIN          
SFX1_11 EQU $11 ; SFX1_ENEMYWAKE     ; stun restore
SFX1_12 EQU $12 ; SFX1_SWIM          
SFX1_13 EQU $13 ; SFX1_MISSILEFIRED  ; fire missile launched
SFX1_14 EQU $14 ; SFX1_ENEMYDEAD     
SFX1_15 EQU $15 ; SFX1_BUMPBIG2      ; copy of $0A for act coli type $02
SFX1_16 EQU $16 ; SFX1_ENEMYHIT      ; hit enemy with dash attack
SFX1_17 EQU $17 ; SFX1_17            
SFX1_18 EQU $18 ; SFX1_HEADTURNA     ; head turn (save select)
SFX1_19 EQU $19 ; SFX1_HEADTURNB     ; head turn (save select)
SFX1_1A EQU $1A ; SFX1_SHIPNOTICE    ; for intro
SFX1_1B EQU $1B ; SFX1_SHIPSIREN     ; ""
SFX1_1C EQU $1C ; SFX1_WARIOROW      ; ""
SFX1_1D EQU $1D ; SFX1_1D            
SFX1_1E EQU $1E ; SFX1_1E            
SFX1_1F EQU $1F ; SFX1_1F            
SFX1_20 EQU $20 ; SFX1_ACTDROP       ; Dropped actor
SFX1_21 EQU $21 ; SFX1_JUMPLAND      ; landing after a jump
SFX1_22 EQU $22 ; SFX1_PATHDOT       ; path dot revealed
SFX1_23 EQU $23 ; SFX1_23            
SFX1_24 EQU $24 ; SFX1_BIGCOIN       ; 100 coin
SFX1_25 EQU $25 ; SFX1_POWERDOWN     
SFX1_26 EQU $26 ; SFX1_10COIN        
SFX1_27 EQU $27 ; SFX1_27            
SFX1_28 EQU $28 ; SFX1_28            
SFX1_29 EQU $29 ; SFX1_ENEMYFLY      ; Fly enemy, boss bomb thrown
SFX1_2A EQU $2A ; SFX1_2A            
SFX1_2B EQU $2B ; SFX1_2B            ; Checkpoint
SFX1_2C EQU $2C ; SFX1_BOSSHIT       
SFX1_2D EQU $2D ; SFX1_2D            ; Knife hits wall
SFX1_2E EQU $2E ; SFX1_BOUNCEBLOCK   
SFX1_2F EQU $2F ; SFX1_BOMBGRAB      
SFX1_30 EQU $30 ; SFX1_TREASUREVALUE ; ending; when treasure sums up to the total money
SFX1_31 EQU $31 ; SFX1_31            ; coin count ending?
SFX1_32 EQU $32 ; SFX1_GENIETALK     ; 
SFX1_33 EQU $33 ; SFX1_33            

SFX2_01 EQU $01 ; SFX2_NOACCESS
SFX2_02 EQU $02 ; SFX2_COIN  			; to go along with SFX1 coin
SFX2_03 EQU $03 ; SFX2_TIMEUPA 			; few seconds remaining
SFX2_04 EQU $04 ; SFX2_TIMEUPB 			; 1 second remaining
SFX2_05 EQU $05 ; SFX2_HURRYUP
SFX2_06 EQU $06 ; SFX2_TREASUREVALUE 	; goes along with SFX1_30

SFX4_01 EQU $01 ; SFX4_DASH         ; Dash
SFX4_02 EQU $02 ; SFX4_GROUNDPOUND  ; Wario Ground pound, screen shakes, ...
SFX4_03 EQU $03 ; SFX4_DASHWALL     
SFX4_04 EQU $04 ; SFX4_DRAGONFLAME0 ; Dragon hat start / Syrup castle explosion
SFX4_05 EQU $05 ; SFX4_DRAGONFLAME1 ; Dragon hat continue
SFX4_06 EQU $06 ; SFX4_DRAGONFLAME2 ; copy of $05
SFX4_07 EQU $07 ; SFX4_DRAGONFLAME3 ; copy of $04
SFX4_08 EQU $08 ; SFX4_WALK         ; Walk SFX
SFX4_09 EQU $09 ; SFX4_WALK_SMALL   ; Walk SFX (small Wario)
SFX4_0A EQU $0A ; SFX4_BLOCKHIT     ; Block cracked
SFX4_0B EQU $0B ; SFX4_BLOCKSMASH   ; Block destroyed
SFX4_0C EQU $0C ; SFX4_WATERENTER   ; Player enters water
SFX4_0D EQU $0D ; SFX4_WATEREXIT    ; Player exits water
SFX4_0E EQU $0E ; SFX4_CLING        ; Bull hat cling
SFX4_0F EQU $0F ; SFX4_JET          ; Jet hat fly
SFX4_10 EQU $10 ; SFX4_10           ; Actor enters water
SFX4_11 EQU $11 ; SFX4_11           ; Lava bubble jumps out of lava
SFX4_12 EQU $12 ; SFX4_TITLEDROP    ; Title screen drop
SFX4_13 EQU $13 ; SFX4_13           
SFX4_14 EQU $14 ; SFX4_14           ; Bomb SFX
SFX4_15 EQU $15 ; SFX4_DDREADY      ; D.D. ready to throw boomerang
SFX4_16 EQU $16 ; SFX4_DDTHROW      ; D.D. boomerang throw
SFX4_17 EQU $17 ; SFX4_TRAINTRACK   ; Train track
SFX4_18 EQU $18 ; SFX4_SWITCHBLOCK  ; Small ! block
SFX4_19 EQU $19 ; SFX4_19           ; Mt.Teapot boss run charge
SFX4_UNUSED_1A EQU $1A ; SFX4_UNUSED_1A    
SFX4_UNUSED_1B EQU $1B ; SFX4_UNUSED_1B    ; loud variant of fire?

SFX_NONE           EQU $FF


; ------------------------------------------------------------

; Level list by ID
LVL_C26                    EQU $00
LVL_C33                    EQU $01
LVL_C15                    EQU $02
LVL_C20                    EQU $03
LVL_C16                    EQU $04
LVL_C10                    EQU $05
LVL_C07                    EQU $06
LVL_C01A                   EQU $07
LVL_C17                    EQU $08
LVL_C12                    EQU $09
LVL_C13                    EQU $0A
LVL_C29                    EQU $0B
LVL_C04                    EQU $0C
LVL_C09                    EQU $0D
LVL_C03A                   EQU $0E
LVL_C02                    EQU $0F
LVL_C08                    EQU $10
LVL_C11                    EQU $11
LVL_C35                    EQU $12
LVL_C34                    EQU $13
LVL_C30                    EQU $14
LVL_C21                    EQU $15
LVL_C22                    EQU $16
LVL_C01B                   EQU $17
LVL_C19                    EQU $18
LVL_C05                    EQU $19
LVL_C36                    EQU $1A
LVL_C24                    EQU $1B
LVL_C25                    EQU $1C
LVL_C32                    EQU $1D
LVL_C27                    EQU $1E
LVL_C28                    EQU $1F
LVL_C18                    EQU $20
LVL_C14                    EQU $21
LVL_C38                    EQU $22
LVL_C39                    EQU $23
LVL_C03B                   EQU $24
LVL_C37                    EQU $25
LVL_C31A                   EQU $26
LVL_C23                    EQU $27
LVL_C40                    EQU $28
LVL_C06                    EQU $29
LVL_C31B                   EQU $2A
LVL_UNUSED_2B              EQU $2B
LVL_UNUSED_2C              EQU $2C
LVL_UNUSED_2D              EQU $2D
LVL_UNUSED_2E              EQU $2E
LVL_UNUSED_2F              EQU $2F
LVL_OVERWORLD              EQU $30                ; Not a valid level slot -- used to check for the overworld in the map screen
LVL_OVERWORLD_MTTEAPOT     EQU $31         
LVL_OVERWORLD_STOVECANYON  EQU $32
LVL_OVERWORLD_PARSLEYWOODS EQU $33
LVL_OVERWORLD_SSTEACUP     EQU $34
LVL_OVERWORLD_SHERBETLAND  EQU $35
LVL_OVERWORLD_SYRUPCASTLE  EQU $36
LVL_OVERWORLD_BRIDGE       EQU $37

LVL_LASTVALID   EQU $2A

; ============================================================
; Sprite flags for OBJ List (main)
OBJLSTB_OBP1 EQU 4
OBJLST_OBP1 EQU $10
OBJLSTB_XFLIP EQU 5	; If set, player is facing right
OBJLST_XFLIP EQU $20
OBJLSTB_BGPRIORITY EQU 7 
OBJLST_BGPRIORITY EQU $80

; Sprite flags for STATIC OBJ List, which for some reason (likely different module programmed by someone different) uses a different format
; Used with wStaticPlFlags and others.
STATIC_OBJLSTB_XFLIP EQU 7 ; If set, player is facing LEFT (coin bonus)
STATIC_OBJLST_XFLIP EQU $80 ; If set, player is facing LEFT (coin bonus)

; ============================================================
; OBJ List (Main block)
OBJ_WARIO_NONE               EQU $00
OBJ_WARIO_WALK0              EQU $01
OBJ_WARIO_WALK1              EQU $02
OBJ_WARIO_WALK2              EQU $03
OBJ_WARIO_WALK3              EQU $04
OBJ_HITBLOCK                 EQU $05
OBJ_WARIO_THROW              EQU $06
OBJ_WARIO_JUMPTHROW          EQU $07
OBJ_WARIO_STAND              EQU $08
OBJ_WARIO_IDLE0              EQU $09
OBJ_WARIO_IDLE1              EQU $0A
OBJ_HAT                      EQU $0B
OBJ_UNUSED_WARIO_GROUNDPOUND EQU $0C
OBJ_JETHATFLAME0             EQU $0D
OBJ_JETHATFLAME1             EQU $0E
OBJ_JETHATFLAME2             EQU $0F
OBJ_WARIO_DUCK               EQU $10
OBJ_WARIO_DUCKWALK           EQU $11
OBJ_WARIO_CLIMB0             EQU $12
OBJ_WARIO_CLIMB1             EQU $13
OBJ_WARIO_BUMP               EQU $14
OBJ_DRAGONHATFLAME_A0        EQU $15
OBJ_DRAGONHATFLAME_A1        EQU $16
OBJ_DRAGONHATFLAME_A2        EQU $17
OBJ_WARIO_SWIM0              EQU $18
OBJ_WARIO_SWIM1              EQU $19
OBJ_WARIO_DEAD               EQU $1A
OBJ_DRAGONHATFLAME_B0        EQU $1B
OBJ_DRAGONHATFLAME_B1        EQU $1C
OBJ_DRAGONHATFLAME_B2        EQU $1D
OBJ_WARIO_SWIM2              EQU $1E
OBJ_WARIO_BUMPAIR            EQU $1F
OBJ_WARIO_JUMP               EQU $20
OBJ_WARIO_GROUNDPOUND        EQU $21
OBJ_WARIO_DASHJUMP           EQU $22
OBJ_WARIO_DASHENEMY          EQU $23
OBJ_WARIO_DASH0              EQU $24
OBJ_WARIO_DASH1              EQU $25
OBJ_WARIO_DASH2              EQU $26
OBJ_WARIO_DASH3              EQU $27
OBJ_WARIO_DASH4              EQU $28
OBJ_WARIO_DASH5              EQU $29
OBJ_WARIO_DASH6              EQU $2A
OBJ_DRAGONHATFLAME_C0        EQU $2B
OBJ_DRAGONHATFLAME_C1        EQU $2C
OBJ_DRAGONHATFLAME_C2        EQU $2D
OBJ_DRAGONHATFLAME_D0        EQU $2E
OBJ_DRAGONHATFLAME_D1        EQU $2F
OBJ_DRAGONHATFLAME_D2        EQU $30
OBJ_SMALLWARIO_WALK0         EQU $31
OBJ_SMALLWARIO_WALK1         EQU $32
OBJ_SMALLWARIO_WALK2         EQU $33
OBJ_WARIO_THUMBSUP0          EQU $34
OBJ_WARIO_THUMBSUP1          EQU $35
OBJ_BLANK_36                 EQU $36
OBJ_TRROOM_ARROW             EQU $37
OBJ_SMALLWARIO_STAND         EQU $38
OBJ_SMALLWARIO_IDLE          EQU $39
OBJ_DRAGONHATFLAME_E0        EQU $3A
OBJ_DRAGONHATFLAME_E1        EQU $3B
OBJ_DRAGONHATFLAME_E2        EQU $3C
OBJ_DRAGONHATFLAME_F0        EQU $3D
OBJ_DRAGONHATFLAME_F1        EQU $3E
OBJ_DRAGONHATFLAME_F2        EQU $3F
OBJ_UNUSED_MAIN_40           EQU $40
OBJ_WARIO_GRAB               EQU $41
OBJ_SMALLWARIO_CLIMB0        EQU $42
OBJ_SMALLWARIO_CLIMB1        EQU $43
OBJ_WARIO_DUCKHOLD           EQU $44
OBJ_WARIO_DUCKWALKHOLD       EQU $45
OBJ_WARIO_DUCKTHROW          EQU $46
OBJ_SMALLWARIO_HOLD          EQU $47
OBJ_SMALLWARIO_SWIM0         EQU $48
OBJ_SMALLWARIO_SWIM1         EQU $49
OBJ_SMALLWARIO_HOLDWALK0     EQU $4A
OBJ_SMALLWARIO_HOLDWALK1     EQU $4B
OBJ_SMALLWARIO_HOLDWALK2     EQU $4C
OBJ_SMALLWARIO_HOLDJUMP      EQU $4D
OBJ_SMALLWARIO_SWIM2         EQU $4E
OBJ_WARIO_DASHFLY            EQU $4F
OBJ_SMALLWARIO_JUMP          EQU $50
OBJ_WARIO_HOLDWALK0          EQU $51
OBJ_WARIO_HOLDWALK1          EQU $52
OBJ_WARIO_HOLDWALK2          EQU $53
OBJ_WARIO_HOLDWALK3          EQU $54
OBJ_WATERSPLASH0             EQU $55
OBJ_WATERSPLASH1             EQU $56
OBJ_WATERSPLASH2             EQU $57
OBJ_WARIO_HOLD               EQU $58
OBJ_BLOCKSMASH0              EQU $59
OBJ_BLOCKSMASH1              EQU $5A
OBJ_BLOCKSMASH2              EQU $5B
OBJ_BLOCKSMASH3              EQU $5C
OBJ_BLOCKSMASH4              EQU $5D
OBJ_BLOCKSMASH5              EQU $5E
OBJ_BLOCKSMASH6              EQU $5F
OBJ_BLOCKSMASH7              EQU $60
OBJ_BLOCKSMASH8              EQU $61
OBJ_UNUSED_BLOCKSMASH9       EQU $62
OBJ_SAVESEL_HAT              EQU $63
OBJ_SMALLWARIO_LEVELCLEAR    EQU $64
OBJ_SAVESEL_BOMBWARIO0       EQU $65
OBJ_SAVESEL_BOMBWARIO1       EQU $66
OBJ_SAVESEL_BOMBWARIO2       EQU $67
OBJ_SAVESEL_WARIO_DASH0      EQU $68
OBJ_SAVESEL_WARIO_DASH1      EQU $69
OBJ_SAVESEL_WARIO_DASH2      EQU $6A
OBJ_SAVESEL_WARIO_DASH3      EQU $6B
OBJ_SAVESEL_WARIO_DASH4      EQU $6C
OBJ_SAVESEL_WARIO_DASH5      EQU $6D
OBJ_SAVESEL_WARIO_DASH6      EQU $6E
OBJ_SAVESEL_WARIO_BUMP       EQU $6F
OBJ_WARIO_HOLDJUMP           EQU $70
OBJ_WARIO_HOLDGROUNDPOUND    EQU $71
OBJ_SAVESEL_OLDHAT0          EQU $72
OBJ_SAVESEL_OLDHAT1          EQU $73
OBJ_SAVESEL_OLDHAT2          EQU $74
OBJ_SAVESEL_WARIO_JUMPNOHAT  EQU $75
OBJ_UNUSED_SAVESEL_WARIO_STANDNOHAT EQU $76
OBJ_DRAGONHATWATER_A0        EQU $77
OBJ_DRAGONHATWATER_A1        EQU $78
OBJ_DRAGONHATWATER_A2        EQU $79
OBJ_DRAGONHATWATER_B0        EQU $7A
OBJ_DRAGONHATWATER_B1        EQU $7B
OBJ_DRAGONHATWATER_B2        EQU $7C
OBJ_DRAGONHATWATER_C0        EQU $7D
OBJ_DRAGONHATWATER_C1        EQU $7E
OBJ_DRAGONHATWATER_C2        EQU $7F
OBJ_DRAGONHATWATER_D0        EQU $80
OBJ_DRAGONHATWATER_D1        EQU $81
OBJ_DRAGONHATWATER_D2        EQU $82
OBJ_DRAGONHATWATER_E0        EQU $83
OBJ_DRAGONHATWATER_E1        EQU $84
OBJ_DRAGONHATWATER_E2        EQU $85
OBJ_DRAGONHATWATER_F0        EQU $86
OBJ_DRAGONHATWATER_F1        EQU $87
OBJ_DRAGONHATWATER_F2        EQU $88
OBJ_TRROOM_WARIO_SHRUG       EQU $89
OBJ_TRROOM_WARIO_GLOAT       EQU $8A
OBJ_TRROOM_WARIO_IDLE0       EQU $8B
OBJ_TRROOM_WARIO_IDLE1       EQU $8C
OBJ_SAVESEL_CROSS            EQU $8D
OBJ_TRROOM_TREASURE_C0       EQU $8E
OBJ_TRROOM_TREASURE_C1       EQU $8F
OBJ_TRROOM_TREASURE_I0       EQU $90
OBJ_TRROOM_TREASURE_I1       EQU $91
OBJ_TRROOM_TREASURE_F0       EQU $92
OBJ_TRROOM_TREASURE_F1       EQU $93
OBJ_TRROOM_TREASURE_O0       EQU $94
OBJ_TRROOM_TREASURE_O1       EQU $95
OBJ_TRROOM_TREASURE_A0       EQU $96
OBJ_TRROOM_TREASURE_A1       EQU $97
OBJ_TRROOM_TREASURE_N0       EQU $98
OBJ_TRROOM_TREASURE_N1       EQU $99
OBJ_TRROOM_TREASURE_H0       EQU $9A
OBJ_TRROOM_TREASURE_H1       EQU $9B
OBJ_TRROOM_TREASURE_M0       EQU $9C
OBJ_TRROOM_TREASURE_M1       EQU $9D
OBJ_TRROOM_TREASURE_L0       EQU $9E
OBJ_TRROOM_TREASURE_L1       EQU $9F
OBJ_TRROOM_TREASURE_K0       EQU $A0
OBJ_TRROOM_TREASURE_K1       EQU $A1
OBJ_TRROOM_TREASURE_B0       EQU $A2
OBJ_TRROOM_TREASURE_B1       EQU $A3
OBJ_TRROOM_TREASURE_D0       EQU $A4
OBJ_TRROOM_TREASURE_D1       EQU $A5
OBJ_TRROOM_TREASURE_G0       EQU $A6
OBJ_TRROOM_TREASURE_G1       EQU $A7
OBJ_TRROOM_TREASURE_J0       EQU $A8
OBJ_TRROOM_TREASURE_J1       EQU $A9
OBJ_TRROOM_TREASURE_E0       EQU $AA
OBJ_TRROOM_TREASURE_E1       EQU $AB
OBJ_TRROOM_STAR00            EQU $AC
OBJ_TRROOM_STAR01            EQU $AD
OBJ_TRROOM_STAR02            EQU $AE
OBJ_TRROOM_STAR03            EQU $AF
OBJ_TRROOM_STAR10            EQU $B0
OBJ_TRROOM_STAR11            EQU $B1
OBJ_TRROOM_STAR12            EQU $B2
OBJ_TRROOM_STAR13            EQU $B3
OBJ_TRROOM_STAR20            EQU $B4
OBJ_TRROOM_STAR21            EQU $B5
OBJ_TRROOM_STAR22            EQU $B6
OBJ_TRROOM_STAR23            EQU $B7
OBJ_TRROOM_STAR30            EQU $B8
OBJ_TRROOM_STAR31            EQU $B9
OBJ_TRROOM_STAR32            EQU $BA
OBJ_TRROOM_STAR33            EQU $BB
OBJ_COIN0                    EQU $BC
OBJ_COIN1                    EQU $BD
OBJ_COIN2                    EQU $BE
OBJ_COIN3                    EQU $BF
OBJ_1UP                      EQU $C0
OBJ_SAVESEL_SMOKE0           EQU $C1
OBJ_SAVESEL_SMOKE1           EQU $C2
OBJ_SAVESEL_SMOKE2           EQU $C3
OBJ_3UP                      EQU $C4
OBJ_TRROOM_MONEYBAGS1        EQU $C5
OBJ_TRROOM_MONEYBAGS2        EQU $C6
OBJ_TRROOM_MONEYBAGS3        EQU $C7
OBJ_TRROOM_MONEYBAGS4        EQU $C8
OBJ_TRROOM_MONEYBAGS5        EQU $C9
OBJ_TRROOM_MONEYBAGS6        EQU $CA
OBJ_TRROOM_MONEYBAG_FALL     EQU $CB
OBJ_SAVESEL_WARIO_STANDNOHAT EQU $CC
OBJ_SAVESEL_WARIO_LOOKBACK   EQU $CD
OBJ_SAVESEL_WARIO_LOOKUP     EQU $CE

; For static modes outside of the title screen (Bonus games and ending)
OBJ_STATIC_WARIO_NONE                  EQU $00
OBJ_STATIC_WARIO_WALK0                 EQU $01 ; Must be shared with OBJ_WARIO_WALK*
OBJ_STATIC_WARIO_WALK1                 EQU $02 ; Must be shared ""
OBJ_STATIC_WARIO_WALK2                 EQU $03 ; Must be shared ""
OBJ_STATIC_WARIO_WALK3                 EQU $04 ; Must be shared ""
OBJ_STATIC_WARIO_IDLE                  EQU $05
OBJ_STATIC_WARIO_FRONT                 EQU $06 
OBJ_STATIC_WARIO_WON0                  EQU $07 
OBJ_STATIC_WARIO_WON1                  EQU $08 
OBJ_STATIC_WARIO_LOST                  EQU $09 
OBJ_STATIC_WARIO_IDLEDIAG              EQU $0A
OBJ_ENDING_WARIO_JUMPDIAG              EQU $0B
; The rest of STATIC_OBJ_WARIO only works without XFLIP
OBJ_HEARTBONUS_WARIO_BACK              EQU $0C
OBJ_HEARTBONUS_WARIO_BACKGRABBOMB      EQU $0D
OBJ_HEARTBONUS_WARIO_BACKHOLDBOMB0     EQU $0E
OBJ_HEARTBONUS_WARIO_BACKHOLDBOMB1     EQU $0F
OBJ_HEARTBONUS_WARIO_BACKTHROWBOMB     EQU $10
OBJ_HEARTBONUS_WARIO_BACKGRABBOMBEXPL0 EQU $11
OBJ_HEARTBONUS_WARIO_BACKGRABBOMBEXPL1 EQU $12
OBJ_HEARTBONUS_WARIO_BACKGRABBOMBEXPL2 EQU $13
OBJ_HEARTBONUS_WARIO_BACKHOLDBOMBEXPL0 EQU $14
OBJ_HEARTBONUS_WARIO_BACKHOLDBOMBEXPL1 EQU $15
OBJ_HEARTBONUS_WARIO_BACKHOLDBOMBEXPL2 EQU $16
OBJ_HEARTBONUS_WARIO_BACKBOMBEXPL3     EQU $17
OBJ_HEARTBONUS_WARIO_BACKBOMBEXPL4     EQU $18
OBJ_COINBONUS_WARIO_IDLEDIAGBACK       EQU $19
OBJ_COINBONUS_WARIO_PULL0              EQU $1A
OBJ_COINBONUS_WARIO_PULL1              EQU $1B
OBJ_COINBONUS_WARIO_CRUSHED            EQU $1C
OBJ_ENDING_WARIO_WALKHOLD0             EQU $1D
OBJ_ENDING_WARIO_WALKHOLD1             EQU $1E
OBJ_ENDING_WARIO_WALKHOLD2             EQU $1F
OBJ_ENDING_WARIO_WALKHOLD3             EQU $20
OBJ_ENDING_WARIO_IDLEHOLD              EQU $21
OBJ_ENDING_WARIO_IDLETHROW             EQU $22
OBJ_ENDING_WARIO_DUCKRUB0              EQU $23
OBJ_ENDING_WARIO_DUCKRUB1              EQU $24
OBJ_ENDING_WARIO_DUCKRUB2              EQU $25
OBJ_ENDING_WARIO_DUCKDIAG              EQU $26
OBJ_ENDING_WARIO_BUMP0                 EQU $27
OBJ_ENDING_WARIO_BUMP1                 EQU $28
OBJ_ENDING_WARIO_WISHCLOSE             EQU $29
OBJ_ENDING_WARIO_WISHOPEN              EQU $2A


; ============================================================
; Treasure IDs
TREASURE_C       EQU $01
TREASURE_I       EQU $02
TREASURE_F       EQU $03
TREASURE_O       EQU $04
TREASURE_A       EQU $05
TREASURE_N       EQU $06
TREASURE_H       EQU $07
TREASURE_M       EQU $08
TREASURE_L       EQU $09
TREASURE_K       EQU $0A
TREASURE_B       EQU $0B
TREASURE_D       EQU $0C
TREASURE_G       EQU $0D
TREASURE_J       EQU $0E
TREASURE_E       EQU $0F

TREASUREB_C       EQU $01
TREASUREB_I       EQU $02
TREASUREB_F       EQU $03
TREASUREB_O       EQU $04
TREASUREB_A       EQU $05
TREASUREB_N       EQU $06
TREASUREB_H       EQU $07
TREASUREB_M       EQU $00
TREASUREB_L       EQU $01
TREASUREB_K       EQU $02
TREASUREB_B       EQU $03
TREASUREB_D       EQU $04
TREASUREB_G       EQU $05
TREASUREB_J       EQU $06
TREASUREB_E       EQU $07


BIGITEM_COIN  EQU $00
BIGITEM_HEART EQU $01

; ============================================================
; Actor ID list (default for gameplay)

ACT_DEFAULT_BASE     EQU $07
ACT_GARLICPOT        EQU $07
ACT_JETPOT           EQU $08
ACT_DRAGONPOT        EQU $09
ACT_KEY              EQU $0A
ACT_HEART            EQU $0B
ACT_STAR             EQU $0C
ACT_COIN             EQU $0D
ACT_10COIN           EQU $0E 
ACT_BULLPOT          EQU $0F
ACT_NORESPAWN        EQU $80 ; Special MSB flag in the actor ID -- if set the actor isn't written back to the actor layout (aka: respawn table)
ACTB_NORESPAWN       EQU 7

ACTFLAGB_UNUSED_NOBUMPKILL EQU 0 ; Prevents the actor from being instakilled by ActS_Unused_StunBumpKill when landing.
ACTFLAGB_UNUSED_FREEOFFSCREEN EQU 3 ; As soon as the actor goes off-screen, it gets permanently despawned. For some reason, this is done actor-specific instead of using this flag.
ACTFLAGB_NORECOVER EQU 5 ; Once stunned, the actor stays stunned until it goes off screen
ACTFLAGB_ALWAYSHELD EQU 6 ; Actor forces itself as being held (for held 10coins)
ACTFLAGB_HEAVY EQU 7 ; Actor marked as "heavy"

ACTFLAG_UNUSED_NOBUMPKILL EQU 1 << ACTFLAGB_UNUSED_NOBUMPKILL
ACTFLAG_UNUSED_FREEOFFSCREEN EQU 1 << ACTFLAGB_UNUSED_FREEOFFSCREEN
ACTFLAG_NORECOVER EQU 1 << ACTFLAGB_NORECOVER
ACTFLAG_ALWAYSHELD EQU 1 << ACTFLAGB_ALWAYSHELD
ACTFLAG_HEAVY EQU 1 << ACTFLAGB_HEAVY

; Actor routines (lower nybble-only)
; Upper nybble is reused for the bump direction.
ACTRTN_MAIN EQU $00	; Normal routine -- the rest are "special"
ACTRTN_01   EQU $01 ; Horizontal bump/stun
ACTRTN_02   EQU $02 ; Stun from above
ACTRTN_03   EQU $03 ; Groundpound on it (crush)
ACTRTN_04   EQU $04 ; Stun from below
ACTRTN_05   EQU $05 ; Dash attacked
ACTRTN_06   EQU $06 ; Standing on top
ACTRTN_07   EQU $07 ; Hard bumped (including after dealing damage)
ACTRTN_SPEC_08 EQU $08 ; Marked as hit after being thrown something
ACTRTN_SPEC_09 EQU $09 ; Grabbed (Treasure-only)

; Standard OBJLst parent table offsets
; In pairs since different data is used for actors facing left/right.
ACTOLP_UNUSED0L EQU $00*2 ; $00 ; Unused stun frame
ACTOLP_UNUSED0R EQU $01*2 ; $02 ; 
ACTOLP_RECOVERL EQU $02*2 ; $04 ; Actor recovering from stun
ACTOLP_RECOVERR EQU $03*2 ; $06 ;
ACTOLP_STUNL EQU $04*2 ; $08 ; Actor stunned / killed
ACTOLP_STUNR EQU $05*2 ; $0A

; Actor-specific constants
SSBOSS_RTN_WIND EQU $00
SSBOSS_RTN_YARC EQU $01
SSBOSS_RTN_HIT EQU $02
SSBOSS_RTN_DEAD EQU $03
SSBOSS_RTN_COINGAME EQU $04
SSBOSS_RTN_INTRO EQU $05

PCFW_DIR_D EQU $01
PCFW_DIR_R EQU $02
PCFW_DIR_U EQU $03
PCFW_DIR_R2 EQU $04

PUFF_RTN_IDLE EQU $00
PUFF_RTN_IDLEANIM EQU $01
PUFF_RTN_INFLATE EQU $02
PUFF_RTN_DEFLATE EQU $03

WOLF_RTN_WALK EQU $00
WOLF_RTN_ALERT EQU $02
WOLF_RTN_THROWKNIFE EQU $03
WOLF_RTN_POSTKNIFE EQU $04

PENG_RTN_WALK EQU $00
PENG_RTN_ALERT EQU $02
PENG_RTN_KICK EQU $03
PENG_RTN_POSTKICK EQU $04

DD_RTN_WALK EQU $00
DD_RTN_ALERT EQU $02
DD_RTN_THROW EQU $03
DD_RTN_POSTTHROW EQU $04

BIRD_RTN_IDLE EQU $00
BIRD_RTN_ATK EQU $01

CDUCK_RTN_FLYUP EQU $00
CDUCK_RTN_MV14 EQU $01
CDUCK_RTN_MV78 EQU $02
CDUCK_RTN_AIRWAIT EQU $03
CDUCK_RTN_FLYDOWN EQU $04
CDUCK_RTN_SLEEP EQU $05
CDUCK_RTN_WAKEUP EQU $06
CDUCK_RTN_GIVECOINS EQU $07
CDUCK_RTN_FLYOUT EQU $08

MTBOSS_RTN_INTRODROP EQU $00 ; IntroFall
MTBOSS_RTN_INTRO1 EQU $01 ; Intro1
MTBOSS_RTN_INTRO2 EQU $02 ; Intro2
MTBOSS_RTN_JUMP EQU $03 ; Jump
MTBOSS_RTN_CHARGE EQU $04 ; Charge
MTBOSS_RTN_STUN EQU $05 ; Stun
MTBOSS_RTN_HELD EQU $06 ; Held
MTBOSS_RTN_THROWN EQU $07 ; Thrown
MTBOSS_RTN_DEAD EQU $08 ; Dead
MTBOSS_RTN_HOLDPL EQU $09 ; Holding player
MTBOSS_RTN_THROWPL EQU $0A ; Throwing player

; Player's relative position when held by the boss, relative to the actor's position
MTBOSS_PLHOLD_XREL EQU $14
MTBOSS_PLHOLD_YREL EQU $23

SLBOSS_RTN_INTROJUMP EQU $00 ; Intro jump
SLBOSS_RTN_INTROPAUSE EQU $01 ; Intro pause
SLBOSS_RTN_PAUSE EQU $02 ; Pause
SLBOSS_RTN_MOVE EQU $03 ; Move
SLBOSS_RTN_ATTACK EQU $04 ; Attack
SLBOSS_RTN_HIT EQU $05 ; Hit
SLBOSS_RTN_HITPAUSE EQU $06 ; Pause after hit
SLBOSS_RTN_JUMPDOWN EQU $07 ; Jump into water
SLBOSS_RTN_JUMPUP EQU $08 ; Jump with hat
SLBOSS_RTN_DEAD EQU $09 ; Dead / heart game
SLBOSS_RTN_TURN EQU $0A ; Turn

SLBOSSHAT_NO EQU $00
SLBOSSHAT_YES EQU $01
SLBOSSHAT_DROP EQU $02

RBBOSS_RTN_INTRO EQU $00 ; Intro
RBBOSS_RTN_RISEUP EQU $01 ; Rise from ground
RBBOSS_RTN_JUMP EQU $02 ; Jump
RBBOSS_RTN_IDLE EQU $03 ; Idle
RBBOSS_RTN_SPINMOVE EQU $04 ; Attack - movement
RBBOSS_RTN_SPINMOVEAIR EQU $05 ; Attack - inverted
RBBOSS_RTN_RISEDOWN EQU $06 ; Move down into underground
RBBOSS_RTN_SPINUNDERGROUND EQU $07 ; Move horz in ground
RBBOSS_RTN_STUNAIR EQU $08 ; Stun jump
RBBOSS_RTN_DEAD EQU $09 ; Dead + Coin Game
RBBOSS_RTN_SPINIDLE EQU $0A ; Attack - pause before moving
RBBOSS_RTN_STUNGROUND EQU $0B ; Ground stun (only after dash attack)

PWBOSS_RTN_INTRO EQU $00 ; Intro
PWBOSS_RTN_TARGET0 EQU $01 ; MoveCR (Identical to 00)
PWBOSS_RTN_ARC0 EQU $02 ; Circle-like movement (before throw)
PWBOSS_RTN_TARGET1 EQU $03 ; Move left w/ spawn
PWBOSS_RTN_ARC1 EQU $04 ; Half-Circle-like movement
PWBOSS_RTN_TARGET2 EQU $05 ; Move right w/ spawn
PWBOSS_RTN_ARC2 EQU $06 ; Y Arc motion
PWBOSS_RTN_TARGET3 EQU $07 ; Move left w/o spawn
PWBOSS_RTN_SPAWN3 EQU $08 ; Spawn 3 ghosts
PWBOSS_RTN_DEAD EQU $09 ; Dead
PWBOSS_RTN_HIT EQU $0A ; Hit

BGHOST_RTN_INTRO EQU $00
BGHOST_RTN_MOVE EQU $01
BGHOST_RTN_STUN EQU $02

SCBOSS_RTN_INTRO EQU $00 ; Intro
SCBOSS_RTN_MAIN EQU $01 ; Main movement
SCBOSS_RTN_TONGUE EQU $02 ; Tongue
SCBOSS_RTN_DEAD EQU $03 ; Dead
SCBOSS_RTN_COINGAME EQU $04 ; Coin Game

SCBOSSTNG_RTN_DISABLED EQU $00
SCBOSSTNG_RTN_ENABLE EQU $01
SCBOSSTNG_RTN_ENABLED EQU $02

SCBOSSBALL_RTN_FIRE EQU $00 ; Fireball
SCBOSSBALL_RTN_SAFE EQU $01 ; Jump
SCBOSSBALL_RTN_SPLASH EQU $02 ; Lava splash

FLO_RTN_IDLE EQU $00 ; Idle
FLO_RTN_WAITMOVE EQU $01 ; Wait for move
FLO_RTN_MOVE EQU $02 ; Move
FLO_RTN_WAITIDLE EQU $03 ; Wait for idle

BRIDGE_RTN_IDLE EQU $00 ; Might as well be unused
BRIDGE_RTN_ALERT EQU $01 ; Alert
BRIDGE_RTN_FALL EQU $02 ; Fall
BRIDGE_RTN_FAIL EQU $03 ; Infinite loop

SNOW_RTN_MOVE EQU $00 ; Move
SNOW_RTN_SHOOT EQU $03 ; Shoot
SNOW_RTN_POSTSHOOT EQU $04 ; Wait

BIGSW_RTN_WAIT EQU $00
BIGSW_RTN_HIT EQU $01
BIGSW_RTN_POSTHIT EQU $02

GHOST_RTN_MOVE EQU $00 ; Move
GHOST_RTN_STUN EQU $01 ; Stun

SEAH_RTN_MOVEUP EQU $00 ; Up move
SEAH_RTN_MOVEDOWN EQU $01 ; Down move
SEAH_RTN_ALERT EQU $02 ; AttackWarn
SEAH_RTN_ATTACK EQU $03 ; Attack

BBOX_RTN_IDLE EQU $00
BBOX_RTN_HIT EQU $01
BBOX_RTN_USED EQU $02

BOMB_RTN_IDLE EQU $00		; Idle
BOMB_RTN_THROW EQU $01		; Thrown / activating
BOMB_RTN_EXPLODE EQU $02	; Exploding
BOMB_RTN_HELD EQU $03		; Held override / activating

CPTS_RTN_INTRO_00 EQU $00
CPTS_RTN_INTRO_01 EQU $01
CPTS_RTN_INTRO_02 EQU $02
CPTS_RTN_INTRO_03 EQU $03
CPTS_RTN_INTRO_04 EQU $04 ; Copy of CPTS_RTN_01
CPTS_RTN_INTRO_05 EQU $05
CPTS_RTN_INTRO_06 EQU $06
CPTS_RTN_INTRO_07 EQU $07
CPTS_RTN_INTRO_08 EQU $08
CPTS_RTN_INTRO_09 EQU $09
CPTS_RTN_INTRO_0A EQU $0A
CPTS_RTN_INTRO_0B EQU $0B
CPTS_RTN_INTRO_0C EQU $0C
CPTS_RTN_INTRO_0D EQU $0D
CPTS_RTN_PLAY EQU $0E ; Main
CPTS_RTN_DEAD EQU $0F ; Dead
; Ending specific
CPTS_RTN_ENDING_10 EQU $10
CPTS_RTN_ENDING_11 EQU $11
CPTS_RTN_ENDING_12 EQU $12
CPTS_RTN_ENDING_13 EQU $13
CPTS_RTN_ENDING_14 EQU $14
CPTS_RTN_ENDING_15 EQU $15 
CPTS_RTN_WAITRELOAD EQU $16 ; Wait clear (after $0F)
; For mode $0E
CPTS_SUBRTN_MOVE EQU $00
CPTS_SUBRTN_WAITFIRE EQU $01
CPTS_SUBRTN_FIRE EQU $02
CPTS_SUBRTN_HIT EQU $03

CPTS_BG_YTARGET EQU $06 ; 6px/frame happens to be off-screen when reached
CPTS_ACT_YTARGET EQU $8F ; Position visually on the ground

CPTSBALL_RTN_AIR EQU $00	; Jump arc in the air
CPTSBALL_RTN_GROUND EQU $01 ; Sliding on the ground

LAMP_RTN_INTROIDLE EQU $00 ; Idle, intangible
LAMP_RTN_INITFLASH EQU $01 ; Flash anim setup
LAMP_RTN_FLASH EQU $02 ; Flash 
LAMP_RTN_FALL EQU $03 ; Drop down (thrown?)
LAMP_RTN_MAIN EQU $04 ; Main idle
LAMP_RTN_HOLD EQU $05 ; Holding the lamp
LAMP_RTN_THROW EQU $06 ; Throwing it
LAMP_RTN_HELDNOTHROW EQU $07 ; Ending reload
IF FIX_BUGS == 1
LAMP_RTN_INITMAIN EQU $08 ; Custom - switch to $04
ENDC

LAMPSMOKE_RTN_HIDE EQU $00 ;
LAMPSMOKE_RTN_INITMOVE EQU $01 ; Show up
LAMPSMOKE_RTN_MOVE EQU $02 ; Move up
LAMPSMOKE_RTN_HIDE2 EQU $03 ; Move up

CPTSMINI_RTN_RISE EQU $00
CPTSMINI_RTN_BLINK EQU $01
CPTSMINI_RTN_FALLDOWN EQU $02
CPTSMINI_RTN_MAIN EQU $03

CCRB_RTN_HIDDEN EQU $00
CCRB_RTN_EXITSAND EQU $01
CCRB_RTN_STAND EQU $02
CCRB_RTN_RUN EQU $03
CCRB_RTN_UNUSED_ENTERSAND EQU $04

MOLE_RTN_WALK EQU $00
MOLE_RTN_THROWKNIFE EQU $03
MOLE_RTN_POSTKNIFE EQU $04
MOS_MODE_SPAWN EQU $00
MOS_MODE_HOLD EQU $01
MOS_MODE_THROW EQU $02
MOS_MODE_DESPAWN EQU $03

SEAL_RTN_IDLE EQU $00
SEAL_RTN_TRACK EQU $01
SEAL_RTN_SHOOT EQU $02
SEAL_RTN_RETREAT EQU $03

MOLEC_RTN_IDLE EQU $00
MOLEC_RTN_TURNR EQU $01 ; Turn right
MOLEC_RTN_SPAWNCOIN EQU $02 ; Throw coin
MOLEC_RTN_THROWANIM EQU $03 ; Throw anim
MOLEC_RTN_WAITWALK EQU $04 ; Wait walk, remove hand
MOLEC_RTN_WALK EQU $05 ; Walk right
MOLEC_RTN_TURNMULTI EQU $06 ; Turn multi

FRM_RTN_WARN EQU $00
FRM_RTN_MOVE EQU $01
FRM_RTN_SOLIDHIT0 EQU $02
FRM_RTN_SOLIDHIT1 EQU $03
FRM_RTN_MOVEBACK EQU $04
FRM_RTN_WAIT EQU $05

BOMS_RTN_IDLE EQU $00
BOMS_RTN_MOVE EQU $01
BOMS_RTN_STICK EQU $02
BOMS_RTN_EXPLODE EQU $03

KNI_RTN_WALK EQU $00
KNI_RTN_HIT EQU $01
KNI_RTN_CHARGE EQU $02
KNI_RTN_DEAD EQU $03

FLY_RTN_IDLE EQU $00
FLY_RTN_FLY EQU $01
FLY_RTN_DEAD EQU $02

BAT_RTN_IDLE EQU $00
BAT_RTN_ATK EQU $01

; ============================================================
; Extra Actor ID list

EXACT_NONE            EQU $00
EXACT_DEADHAT         EQU $01
EXACT_ITEMBOXHIT      EQU $02
EXACT_JETHATFLAME     EQU $03
EXACT_DRAGONHATFLAME  EQU $04
EXACT_BLOCKSMASH      EQU $05
EXACT_WATERSPLASH     EQU $06
EXACT_WATERBUBBLE     EQU $07
EXACT_SAVESEL_NEWHAT  EQU $08
EXACT_SAVESEL_OLDHAT  EQU $09
EXACT_TRROOM_ARROW    EQU $0A
EXACT_SAVESEL_CROSS   EQU $0B
EXACT_TREASUREGET     EQU $0C
EXACT_TRROOM_SPARKLE  EQU $0D
EXACT_SWITCH0TYPE0HIT EQU $0E
EXACT_SWITCH0TYPE1HIT EQU $0F
EXACT_UNUSED_SWITCH1TYPE0HIT EQU $10
EXACT_BOUNCEBLOCKHIT  EQU $11
EXACT_DEADCOINC       EQU $12
EXACT_DEADCOINL       EQU $13
EXACT_DEADCOINR       EQU $14
EXACT_1UPMARKER       EQU $15
EXACT_TREASUREENDING  EQU $16
EXACT_MONEYBAG        EQU $17
EXACT_MONEYBAGSTACK   EQU $18
EXACT_SAVESEL_SMOKE   EQU $19
EXACT_TREASURELOST    EQU $1A

; commands for ExAct_MoneybagStack (sExActMoneybagStackMode)
MONEYBAGSTACK_ADDITEM EQU $01 ; Add 1 moneybag
MONEYBAGSTACK_SYNCPOS EQU $02 ; Sync with player's position

; ============================================================
; GAME MODES 
; ============================================================

GM_TITLE             EQU $00 ; Title screen
GM_MAP               EQU $01 ; Map screen
GM_LEVELINIT         EQU $02 ; Level loading & fade-in
GM_LEVEL             EQU $03 ; Main gameplay
GM_LEVELCLEAR        EQU $04 ; Main gameplay - Entering the exit door (with wario anim)
GM_LEVELDEADFADEOUT  EQU $05
GM_LEVELCLEAR2       EQU $06 ; Main gameplay - Special exit
GM_TIMEUP            EQU $07
GM_GAMEOVER          EQU $08
GM_ENDING            EQU $09 ; Ending (Everything except the map screen part)
GM_LEVELDOOR         EQU $0A ; Main gameplay - Entering a normal door
GM_TREASURE          EQU $0B ; Treasure get
GM_LEVELENTRANCE     EQU $0C ; Main gameplay - Entering the level entrance door
GM_UNUSED_HEARTBONUS EQU $0D ; Mode itself not used; but the code it points to is
; ------------------------------------------------------------

GM_TITLE_MAIN          EQU $00
GM_TITLE_SAVESELSWITCH EQU $01
GM_TITLE_INITSAVESEL   EQU $02
GM_TITLE_SAVESELINTRO0 EQU $03
GM_TITLE_SAVESELINTRO1 EQU $04
GM_TITLE_SAVESEL       EQU $05
GM_TITLE_SAVEERROR     EQU $06

; ------------------------------------------------------------
GM_MAP_MAIN       EQU $00
GM_MAP_COURSESCR  EQU $01

; Map modes available. They do not necessarily correspond to actual maps (ie. fade in mode)
MAP_MODE_INIT                       EQU $00
MAP_MODE_INITOVERWORLD              EQU $01
MAP_MODE_OVERWORLD                  EQU $02
MAP_MODE_INITRICEBEACH              EQU $03
MAP_MODE_RICEBEACH                  EQU $04
MAP_MODE_INITMTTEAPOT               EQU $05
MAP_MODE_MTTEAPOT                   EQU $06
MAP_MODE_FADEIN                     EQU $07
MAP_MODE_FADEOUT                    EQU $08
MAP_MODE_INITSTOVECANYON            EQU $09
MAP_MODE_STOVECANYON                EQU $0A
MAP_MODE_INITSYRUPCASTLE            EQU $0B
MAP_MODE_SYRUPCASTLE                EQU $0C
MAP_MODE_INITPARSLEYWOODS           EQU $0D
MAP_MODE_PARSLEYWOODS               EQU $0E
MAP_MODE_INITSSTEACUP               EQU $0F
MAP_MODE_SSTEACUP                   EQU $10
MAP_MODE_INITSHERBETLAND            EQU $11
MAP_MODE_SHERBETLAND                EQU $12
MAP_MODE_INITMTTEAPOTCUTSCENE       EQU $13
MAP_MODE_MTTEAPOTCUTSCENE           EQU $14
MAP_MODE_CUTSCENEFADEOUT            EQU $15
MAP_MODE_INITSSTEACUPCUTSCENE       EQU $16
MAP_MODE_SSTEACUPCUTSCENE           EQU $17
MAP_MODE_INITPARSLEYWOODSCUTSCENE   EQU $18
MAP_MODE_PARSLEYWOODSCUTSCENE       EQU $19
MAP_MODE_INITSYRUPCASTLEC38CUTSCENE EQU $1A
MAP_MODE_DUMMY_1B                   EQU $1B
MAP_MODE_INITSYRUPCASTLEC39CUTSCENE EQU $1C
MAP_MODE_DUMMY_1D                   EQU $1D
MAP_MODE_INITENDING2                EQU $1E
MAP_MODE_ENDING2                    EQU $1F
MAP_MODE_ENDING2FADEIN              EQU $20
MAP_MODE_INITENDING1                EQU $21

; ------------------------------------------------------------
GM_LEVELINIT_LOAD       EQU $00
GM_LEVELINIT_FADEBG     EQU $01
GM_LEVELINIT_FADEOBJ    EQU $02
GM_LEVELINIT_STARTLEVEL EQU $03
; ------------------------------------------------------------
GM_LEVEL_MAIN EQU $00
; ------------------------------------------------------------

GM_LEVELCLEAR_FANFARE      EQU $00 
GM_LEVELCLEAR_OBJFADE      EQU $01 ; Fade to black for objects
GM_LEVELCLEAR_LEVELFADE    EQU $02 ; Objects disappear, fade to white for BG
GM_LEVELCLEAR_CLEARINIT    EQU $03 ; Initialize Course Clear screen
GM_LEVELCLEAR_CLEAR        EQU $04 ; Course clear screen
GM_LEVELCLEAR_TRINIT       EQU $05 ; 

GM_LEVELCLEAR_TRWAIT         EQU $06 ; Initial part
GM_LEVELCLEAR_TRCOINCOUNT    EQU $07 ; Coin countdown
GM_LEVELCLEAR_TRIDLE         EQU $08 ; Waiting for input
GM_LEVELCLEAR_TREXIT         EQU $09 ; Left walk

; GM_LEVELCLEAR_CLEAR submodes
COURSECLR_RTN_INTROMOVER0 EQU $00 ; Moving right (from off-screen left)
COURSECLR_RTN_INTROMOVEL0 EQU $01
COURSECLR_RTN_INTROMOVER1 EQU $02
COURSECLR_RTN_COINBONUSPOS EQU $03 ; Standing on the coin bonus door
COURSECLR_RTN_UNUSED_COINBONUS_FADEOUT0 EQU $04
COURSECLR_RTN_UNUSED_COINBONUS_FADEOUT1 EQU $05
COURSECLR_RTN_COINBONUS EQU $06
COURSECLR_RTN_TOHEARTBONUS EQU $07
COURSECLR_RTN_HEARTBONUSPOS EQU $08
COURSECLR_RTN_UNUSED_HEARTBONUS_FADEOUT0 EQU $09
COURSECLR_RTN_UNUSED_HEARTBONUS_FADEOUT1 EQU $0A
COURSECLR_RTN_HEARTBONUS EQU $0B
COURSECLR_RTN_TOTRROOM EQU $0C
COURSECLR_RTN_TOCOINBONUS EQU $0D

; Coin bonus game modes
COINBONUS_MODE_INIT EQU $00
COINBONUS_MODE_MAIN EQU $01
COINBONUS_MODE_EXIT EQU $02

; COINBONUS_MODE_MAIN submodes
COINBONUS_RTN_MOVER EQU $00 ; Walk right
COINBONUS_RTN_IDLE EQU $01 
COINBONUS_RTN_MOVEL EQU $02
COINBONUS_RTN_ACTION EQU $03
COINBONUS_RTN_PULL EQU $04
COINBONUS_RTN_DROPITEM EQU $05
COINBONUS_RTN_BOUNCE EQU $06
COINBONUS_RTN_MOVEC EQU $07
COINBONUS_RTN_RESULT EQU $08

; Heart bonus game modes
HEARTBONUS_MODE_INIT EQU $00
HEARTBONUS_MODE_SELECT EQU $01
HEARTBONUS_MODE_INITGAME EQU $02
HEARTBONUS_MODE_GAME EQU $03
HEARTBONUS_MODE_INITRESULTS EQU $04
HEARTBONUS_MODE_RESULTS EQU $05
HEARTBONUS_MODE_EXIT EQU $06

; MODE_SELECT submodes
HEARTBONUS_RTN_MOVER EQU $00
HEARTBONUS_RTN_SELECT EQU $01
HEARTBONUS_RTN_BOMBSET EQU $02

; MODE_GAME submodes
HEARTBONUS_RTN_READYTEXT EQU $00
HEARTBONUS_RTN_MOVECTRL EQU $01
HEARTBONUS_RTN_THROW EQU $02
HEARTBONUS_RTN_BOMBMOVE EQU $03
HEARTBONUS_RTN_BOMBEXPLODE EQU $04
HEARTBONUS_RTN_TIMEOUT EQU $05
HEARTBONUS_RTN_RESULT EQU $06

; ------------------------------------------------------------

; Giant ! block level exit
GM_LEVELCLEAR2_FANFARE      EQU $00 ;
GM_LEVELCLEAR2_OBJFADE      EQU $01 ; Fade to black for objects
GM_LEVELCLEAR2_LEVELFADE    EQU $02 ; Objects disappear, fade to white for BG
GM_LEVELCLEAR2_MAPCUTSCENE  EQU $03

; ------------------------------------------------------------

GM_TIMEUP_INIT EQU $00
GM_TIMEUP_MOVEDOWN EQU $01
GM_TIMEUP_MOVEUP EQU $02
GM_TIMEUP_WAIT EQU $03
GM_TIMEUP_FADEOUT EQU $04
GM_TIMEUP_EXIT EQU $05
; ------------------------------------------------------------

GM_GAMEOVER_INIT EQU $00
GM_GAMEOVER_MAIN EQU $01
GM_GAMEOVER_INITTRROOM EQU $02
GM_GAMEOVER_TRROOM EQU $03

; Gameover - treasure room submodes
GOTR_RTN_MOVER EQU $00
GOTR_RTN_LOSETREASURE EQU $01
GOTR_RTN_WAITTREASURE EQU $02
GOTR_RTN_LOSEMONEY EQU $03
GOTR_RTN_EXIT EQU $04

; ------------------------------------------------------------

GM_ENDING_MOVEPLDOWN EQU $00	; Moving down
GM_ENDING_HATSWITCH EQU $01		; To normal hat
GM_ENDING_WALKTOLAMP EQU $02	; Move towards the lamp
GM_ENDING_WALKTORELOAD EQU $03		; Move to target for room reload (usually left)
GM_ENDING_WAITRELOAD EQU $04
GM_ENDING_FADEOUTOBJ EQU $05
GM_ENDING_FADEOUTBG EQU $06
GM_ENDING_RELOAD EQU $07
GM_ENDING_FADEINBG EQU $08
GM_ENDING_FADEINOBJ EQU $09
GM_ENDING_LVLCUTSCENE EQU $0A
GM_ENDING_MAPCUTSCENE EQU $0B
GM_ENDING_GENIECUTSCENE EQU $0C
GM_ENDING_INITTRROOM EQU $0D
GM_ENDING_TRROOM EQU $0E ; + credits
GM_ENDING_GENIECUTSCENE2 EQU $0F ; + credits

; ENDING MODES (wEndingMode)
END_RTN_INITPRETR EQU $00	; Pre-treasure room genie cutscene
END_RTN_PRETR EQU $01
END_RTN_INITPOSTTR EQU $02	; Post-treasure room genie cutscene
END_RTN_POSTTR EQU $03
END_RTN_INITCASTLE EQU $04	; Castle scene (where the credits take place)
END_RTN_CASTLE EQU $05
END_RTN_CREDITS EQU $06
END_RTN_PLANET EQU $07

; pre treasure room
END1_RTN_MOVERIGHT EQU $00
END1_RTN_THROWLAMP EQU $01
END1_RTN_RUBLAMP EQU $02
END1_RTN_LAMPFLASH EQU $03
END1_RTN_CLOUDS EQU $04
END1_RTN_FLASHBG EQU $05
END1_RTN_PLBUMP EQU $06
END1_RTN_GENIETALK EQU $07
END1_RTN_THINKWISH EQU $08
END1_RTN_PLJUMP EQU $09
END1_RTN_GENIEMONEY EQU $0A
END1_RTN_PLNOD EQU $0B
END1_RTN_MOVELEFT EQU $0C

; treasure room
ENDT_RTN_WALKINR EQU $00
ENDT_RTN_COINCOUNT EQU $01
ENDT_RTN_WAITREMOVE EQU $02
ENDT_RTN_WAITNEAR EQU $03
ENDT_RTN_GRABTREASURE EQU $04
ENDT_RTN_GETTREASURE EQU $05
ENDT_RTN_TREASURECOINCOUNT EQU $06
ENDT_RTN_TOTALCOINCOUNT EQU $07
ENDT_RTN_AWARDEXTRA EQU $08
ENDT_RTN_WALKOUTL EQU $09

; post treasure room
END2_RTN_MOVEINR EQU $00
END2_RTN_WANTMONEY EQU $01
END2_RTN_THROWMONEYBAGS EQU $02
END2_RTN_FLYMONEYBAGS EQU $03
END2_RTN_FLASHBG EQU $04
END2_RTN_POINTSPEAK EQU $05
END2_RTN_PLNOD EQU $06
END2_RTN_MOVEOUTR EQU $07

; endings
END3_RTN_MOVEINR EQU $00
END3_RTN_MARKDOWN EQU $01
END3_RTN_JUMPR EQU $02 ; Good ending - 4-5 moneybags 
END3_RTN_JUMPL EQU $03
END3_RTN_THUMBSUP EQU $04 ; Walk during credits (good or bad endings)
END3_RTN_FAIL EQU $05 ; Bad ending - 1-2 moneybags
END3_RTN_JUMPV EQU $06 ; Good ending - 3 moneybags

; perfect ending
END4_RTN_MOVEINR EQU $00
END4_RTN_SCROLL EQU $01
END4_RTN_PLJUMPUP EQU $02
END4_RTN_PLTHUMBSUP EQU $03
END4_RTN_PLJUMPDOWN EQU $04
END4_RTN_WAITTOCREDITS EQU $05

; credits routines -- bank $1F
CRED_RTN_THUMBSUP EQU $00
CRED_RTN_WALK EQU $01

; credits routines -- bank $01
GM_CREDITS_INIT EQU $00 ; Initialize credits
GM_CREDITS_BLANKBOX EQU $01 ; Create black area for text
GM_CREDITS_INITWRITEROW1 EQU $02 ; Setup first row write
GM_CREDITS_WRITEROW1 EQU $03 ; Write and scroll first row
GM_CREDITS_INITWRITEROW2 EQU $04 ; Setup second row write
GM_CREDITS_SCROLLROW2 EQU $05 ; Scroll second row
GM_CREDITS_CHKLINEEND EQU $06 ; Displays text, then does something depending on the line terminator type
GM_CREDITS_SCROLLOUTROW2 EQU $07 ; Terminator Type 00 - Scroll out row 2
GM_CREDITS_BLANKBOXROW2 EQU $08 ; Clear text
GM_CREDITS_SCROLLOUTBOTHROWS EQU $09 ; Terminator Type 01 - Scroll out both rows
GM_CREDITS_PRELASTMSG EQU $0A ; Terminator type 02 - Wait longer, then determine last message
GM_CREDITS_HALT EQU $0B ; Terminator type 03 - wait indefinitely

; ------------------------------------------------------------

GM_LEVELDOOR_OBJFADEOUT EQU $00
GM_LEVELDOOR_LEVELFADEOUT EQU $01
GM_LEVELDOOR_ROOMLOAD EQU $02
GM_LEVELDOOR_LEVELFADEIN EQU $03
GM_LEVELDOOR_CHKBREAKBLOCK EQU $04
GM_LEVELDOOR_OBJFADEIN EQU $05
GM_LEVELDOOR_END EQU $06

; ------------------------------------------------------------

GM_TREASURE_INIT EQU $00
GM_TREASURE_FADEOUTOBJ EQU $01
GM_TREASURE_FADEOUTBG EQU $02
GM_TREASURE_INITTRROOM EQU $03
GM_TREASURE_TRROOM EQU $04

GM_TREASURE_TRROOM_WALKINR EQU $00
GM_TREASURE_TRROOM_PLACT EQU $01
GM_TREASURE_TRROOM_MOVEDOWN EQU $02
GM_TREASURE_TRROOM_WAITTREASURE EQU $03
GM_TREASURE_TRROOM_WALKOUTR EQU $04
; ------------------------------------------------------------

GM_LEVELENTRANCE_FADEOUTOBJ EQU $00
GM_LEVELENTRANCE_FADEOUTBG EQU $01
GM_LEVELENTRANCE_EXITTOMAP EQU $02

; ------------------------------------------------------------

; ============================================================
;     Mode specific enums
; ============================================================
; TITLE SCREEN


TITLE_MODE_INIT   EQU $00
TITLE_MODE_MAIN   EQU $01
TITLE_MODE_INTRO  EQU $02

; Return values for the title screen code..
; Specifies the action id for switching modes from the title screen
TITLE_NEXT_NONE    EQU $00
TITLE_NEXT_DEMO    EQU $01
TITLE_NEXT_SAVE    EQU $02
TITLE_NEXT_INTRO   EQU $03

; ------------------------------------------------------------

; Sprite mappings for the ship
; Ship OBJ Frame
INTRO_SOF_NONE         EQU $00
INTRO_SOF_MAIN0        EQU $01
INTRO_SOF_MAIN1        EQU $02
INTRO_SOF_DUCKR1       EQU $03
INTRO_SOF_DUCKRBACK1   EQU $04
INTRO_SOF_DUCKLOOK     EQU $05
INTRO_SOF_DUCKNOTICE   EQU $06
INTRO_SOF_DUCKPANICR   EQU $07
INTRO_SOF_DUCKRBACK2   EQU $08
INTRO_SOF_DUCKPANICL   EQU $09
INTRO_SOF_DUCKLBACK    EQU $0A
INTRO_SOF_DUCKHIT      EQU $0B
INTRO_SOF_DUCKREVERSE  EQU $0C
INTRO_SOF_WATER        EQU $0D
INTRO_SOF_DUCKWATER    EQU $0E
; ------------------------------------------------------------
; Wario OBJ Frame
INTRO_WOF_NONE         EQU $00
INTRO_WOF_BOATROW0     EQU $01
INTRO_WOF_BOATROW1     EQU $02
INTRO_WOF_BOATROW2     EQU $03
INTRO_WOF_BOATDASH     EQU $04
INTRO_WOF_BOATSTAND    EQU $05
INTRO_WOF_JUMP         EQU $06
INTRO_WOF_STAND        EQU $07
INTRO_WOF_FRONT        EQU $08
INTRO_WOF_THUMBSUP     EQU $09
INTRO_WOF_THUMBSUP2    EQU $0A

; ============================================================
; SAVE SELECT

; X Coords for the pipe
SAVE_PIPE1_X EQU $24
SAVE_PIPE2_X EQU $44
SAVE_PIPE3_X EQU $64
SAVE_PIPEBOMB_X EQU $8C
SAVE_PIPE_XOFFSET EQU $20

; Player action in the save select screen
SAVE_PL_ACT_NONE         EQU $00
SAVE_PL_ACT_MOVERIGHT    EQU $01
SAVE_PL_ACT_MOVELEFT     EQU $02
SAVE_PL_ACT_JUMPTOBOMB   EQU $03
SAVE_PL_ACT_JUMPFROMBOMB EQU $04
SAVE_PL_ACT_ENTERPIPE    EQU $05
SAVE_PL_ACT_EXITPIPE     EQU $06
SAVE_PL_ACT_EXITPIPEJUMP EQU $07

; ============================================================
; MAP SCREEN

; ------------------------------------------------------------

; Overworld positions ( MapId / WorldId )
MAP_OWP_RICEBEACH    EQU $00
MAP_OWP_MTTEAPOT     EQU $01
MAP_OWP_STOVECANYON  EQU $02
MAP_OWP_PARSLEYWOODS EQU $03
MAP_OWP_SSTEACUP     EQU $04
MAP_OWP_SHERBETLAND  EQU $05
MAP_OWP_SYRUPCASTLE  EQU $06
MAP_OWP_BRIDGE       EQU $07

; ------------------------------------------------------------

; Bit numbers for the overworld completion status bitmask
MAP_CLRB_RICEBEACH    EQU 0
MAP_CLRB_MTTEAPOT     EQU 1
MAP_CLRB_STOVECANYON  EQU 2
MAP_CLRB_SSTEACUP     EQU 3
MAP_CLRB_PARSLEYWOODS EQU 4
MAP_CLRB_SHERBETLAND  EQU 5
MAP_CLRB_SYRUPCASTLE  EQU 6

; ------------------------------------------------------------

; Cutscene ID for Syrup Castle
; This is because there is no separate mode for the cutscene in the Map Mode list and the normal Syrup Castle mode is used instead.
; The modes which would have been used ($1B and $1D) are dummy.

MAP_SCC_NONE         equ 0
MAP_SCC_01           equ 1
MAP_SCC_C38CLEAR     equ 2
MAP_SCC_C39CLEAR     equ 3
MAP_SCC_ENDING       equ 4

; ------------------------------------------------------------

; Wario animation IDs in the map screen
; enum MWA
MAP_MWA_FRONT        equ 0
MAP_MWA_RIGHT        equ 1
MAP_MWA_LEFT         equ 2
MAP_MWA_BACK         equ 3
MAP_MWA_FRONT2       equ 4                  ; Points to the same data as MWA_FRONT. Workaround for how Map_GetWarioInitialAnim works.
MAP_MWA_UNUSED_V1    equ 5
MAP_MWA_UNUSED_H3    equ 6
MAP_MWA_UNUSED_H1    equ 7
MAP_MWA_UNUSED_H2    equ 8
MAP_MWA_UNUSED_H1C   equ 9                  ; C stands for "Copy", as it's identical to H1
MAP_MWA_UNUSED_H2C   equ $A
MAP_MWA_UNUSED_H3C   equ $B
MAP_MWA_WATERFRONT   equ $C
MAP_MWA_WATERBACK    equ $D
MAP_MWA_HIDE         equ $E

; ------------------------------------------------------------

; Wario animation IDs in the second part of the ending (which takes place in the map screen).
; Unlike the first part of the ending (which reuses the normal mapping frames) and has
; the lamp as a separate mapping, the mapping defs for these contain the lamp directly.
MAP_MWEA_BACK        equ 0
MAP_MWEA_BACKLEFT    equ 1
MAP_MWEA_BACKRIGHT   equ 2
MAP_MWEA_JUMP        equ 3
MAP_MWEA_SHRUG       equ 4
MAP_MWEA_FRONT       equ 5

; ------------------------------------------------------------

; Map Path Control values
; Special values to control movement at the start of a path segment.
MAP_MPC_UP           equ $E0
MAP_MPC_DOWN         equ $EE
MAP_MPC_RIGHT        equ $F0
MAP_MPC_LEFT         equ $FE
MAP_MPC_STOP         equ $FF

; ------------------------------------------------------------

; Map Path Return Control values
; Special values to specify the action to perform when a MPC_STOP command is reached.
MAP_MPR_ENTERBRIDGE  equ $F8
MAP_MPR_C14RIGHT     equ $F9
MAP_MPR_C08LEFT      equ $FA
MAP_MPR_EXITSUBMAP   equ $FD
MAP_MPR_UNUSED_ALTID  equ $FF

; ------------------------------------------------------------

; Free View Return type.
; Can be 
;  - "Soft", if the mode is simply disabled (when no movement happened)
;  - "Hard", if a fade out will be performed
MAP_FVR_SOFT         equ $0F
MAP_FVR_HARD         equ $FF
MAP_FVR_ANY          equ $0F
MAP_FVR_HARDM        equ $F0

; ============================================================
; GAMEPLAY

; Current powerup state
PL_POW_NONE       EQU $00
PL_POW_GARLIC     EQU $01
PL_POW_BULL       EQU $02
PL_POW_JET        EQU $03
PL_POW_DRAGON     EQU $04

; Player action (sPlAction values)
PL_ACT_STAND		EQU $00
PL_ACT_WALK			EQU $01
PL_ACT_DUCK			EQU $02 ; also duck walk
PL_ACT_CLIMB		EQU $03
PL_ACT_SWIM			EQU $04
PL_ACT_JUMP			EQU $05
PL_ACT_ACTMAIN		EQU $06
PL_ACT_HARDBUMP		EQU $07
PL_ACT_JUMPONACT	EQU $08
PL_ACT_DEAD			EQU $09
PL_ACT_CLING		EQU $0A
PL_ACT_DASH			EQU $0B
PL_ACT_DASHREBOUND	EQU $0C
PL_ACT_DASHJUMP		EQU $0D
PL_ACT_DASHJET		EQU $0E
PL_ACT_ACTGRAB2		EQU $0F
PL_ACT_THROW		EQU $10
PL_ACT_SAND			EQU $11
PL_ACT_TREASUREGET	EQU $12

; Swimming ground movement
PL_SGM_NONE         EQU $00
PL_SGM_STAND        EQU $01
PL_SGM_DUCK         EQU $02
PL_SGM_WALK         EQU $03

; Hurt type / overlaps a bit with the hard bump effect
PL_HT_BGHURT  EQU $01 ; Damaging block
PL_HT_BUMP    EQU $02 ; Special value marking the middle of a bump, or one against a solid actor
PL_HT_ACTHURT EQU $03 ; Damaging actor

; Held mode (sActHeld)
PL_HLD_NONE EQU $00
PL_HLD_WAITHOLD EQU $01
PL_HLD_HOLDING EQU $02
PL_HLD_SPEC_NOTHROW EQU $03 ; Special value used by Act_Lamp. Acts like $02 otherwise.

LOCK_CLOSED EQU $00
LOCK_OPENING EQU $01
LOCK_OPEN EQU $02
CHECKPOINT_NONE EQU $00
CHECKPOINT_ACTIVATING EQU $01
CHECKPOINT_ACTIVE EQU $02

; Special level clear modes (sLvlSpecClear)
LVLCLEAR_NONE EQU $00
LVLCLEAR_BOSS EQU $01 ; Boss clear / debug level clear
LVLCLEAR_BIGSWITCH EQU $02 ; Big switch hit
LVLCLEAR_FINALDEAD EQU $03 ; Final boss defeated (transform + walk to lamp)
LVLCLEAR_FINALEXITTOMAP EQU $04 ; Fades out to the map screen

;
BG_BLOCK_WIDTH EQU $02 ; Tiles for a block
BG_BLOCK_HEIGHT EQU $02
BG_BLOCKCOUNT_H EQU BG_TILECOUNT_H / 2
BG_BLOCKCOUNT_V EQU BG_TILECOUNT_V / 2

; Tile IDs expected at fixed locations
TILE_SWITCH     EQU $04


TILEID_SWITCHBLOCKACTIVE EQU $04
TILEID_SWITCHBLOCK EQU $1C
TILEID_GENIE_SOLID_UL EQU $0B
TILEID_GENIE_SOLID_UR EQU $0C
TILEID_GENIE_SOLID_DL EQU $1B
TILEID_GENIE_SOLID_DR EQU $1C
TILEID_DIGITS EQU $B0 ; Tile ID base for digits in main gameplay
TILEID_TRROOM_DIGITS EQU $D0 ; Time ID base for digits in treasure room


; Difference between the level scroll value
; and the actual hardware scroll register.
; HScroll is subtracted by this amount.
LVLSCROLL_YOFFSET EQU $48
LVLSCROLL_XOFFSET EQU $50

; Level size
LEVEL_WIDTH 	EQU $1000
LEVEL_HEIGHT 	EQU $0200
BLOCK_WIDTH     EQU $10
BLOCK_HEIGHT    EQU $10

LEVEL_BLOCK_HCOUNT EQU (LEVEL_WIDTH / BLOCK_WIDTH)
LEVEL_BLOCK_VCOUNT EQU (LEVEL_HEIGHT / BLOCK_HEIGHT)
LEVEL_BLOCK_HMIN EQU $00
LEVEL_BLOCK_HMAX EQU LEVEL_BLOCK_HCOUNT - 1
LEVEL_BLOCK_VMIN EQU $00
LEVEL_BLOCK_VMAX EQU LEVEL_BLOCK_VCOUNT - 1

LVLSCROLL_YBLOCKOFFSET EQU LVLSCROLL_YOFFSET/BLOCK_HEIGHT
LVLSCROLL_XBLOCKOFFSET EQU LVLSCROLL_XOFFSET/BLOCK_WIDTH

; Offset for calculating relative player/actor position
; This places the origin at the bottom-center of the actor
ACT_Y_OFFSET EQU $10 ; 2 tiles
ACT_X_OFFSET EQU $08 ; 1 tile

; Level scroll mode
LVLSCROLL_SEGSCRL EQU $00
LVLSCROLL_TRAIN   EQU $01
LVLSCROLL_FREE    EQU $10
LVLSCROLL_AUTOR   EQU $30
LVLSCROLL_AUTOL   EQU $31
LVLSCROLL_AUTOR2  EQU $40
LVLSCROLL_NONE    EQU $FF ; Boss mode as well
LVLSCROLL_CHKAUTO EQU $20


AUTOSCROLL_RIGHT EQU $01


; Generic direction indicators
DIRB_R EQU 0
DIRB_L EQU 1
DIRB_U EQU 2
DIRB_D EQU 3
DIR_R EQU 1 << DIRB_R
DIR_L EQU 1 << DIRB_L
DIR_U EQU 1 << DIRB_U
DIR_D EQU 1 << DIRB_D
DIR_NONE EQU 0
; Scroll lock indicators
SCRLOCKB_R EQU DIRB_R
SCRLOCKB_L EQU DIRB_L
SCRLOCKB_U EQU DIRB_U
SCRLOCKB_D EQU DIRB_D
SCRLOCK_L  EQU 1 << SCRLOCKB_L
SCRLOCK_R  EQU 1 << SCRLOCKB_R
SCRLOCK_U  EQU 1 << SCRLOCKB_U
SCRLOCK_D  EQU 1 << SCRLOCKB_D
; Actor interaction direction
ACTINTB_R EQU DIRB_R + 4
ACTINTB_L EQU DIRB_L + 4
ACTINTB_U EQU DIRB_U + 4
ACTINTB_D EQU DIRB_D + 4
ACTINT_R  EQU 1 << ACTINTB_R
ACTINT_L  EQU 1 << ACTINTB_L
ACTINT_U  EQU 1 << ACTINTB_U
ACTINT_D  EQU 1 << ACTINTB_D

; Collision type (Actor - Standard)
; May be different for each side, depending on collision bitmask
;ACTCOLI_NONE   EQU $00
ACTCOLI_NORM   EQU $01
ACTCOLI_BUMP   EQU $02
ACTCOLI_DAMAGE EQU $03

; Masks to filter standard collision types for a direction
ACTCOLIM_D EQU %11000000
ACTCOLIM_U EQU %00110000
ACTCOLIM_L EQU %00001100
ACTCOLIM_R EQU %00000011

ACTCOLIMB_D EQU 6
ACTCOLIMB_U EQU 4
ACTCOLIMB_L EQU 2
ACTCOLIMB_R EQU 0


; For marking the collision dealt to the player in sActTmpColiDir
; DirBit
ACTCOLIDB_NONE   EQU 4
ACTCOLIDB_NORM   EQU 5
ACTCOLIDB_BUMP   EQU 6
ACTCOLIDB_DAMAGE EQU 7

; Collision type (Actor - Special), for PlActColiId_CheckType

ACTCOLI_NONE 			EQU $00
ACTCOLI_TREASURE_START	EQU $01
ACTCOLI_TREASURE_END	EQU $10
ACTCOLI_TOPSOLID_START	EQU $10
ACTCOLI_TOPSOLID		EQU $10
ACTCOLI_UNUSED_TYPE11   EQU $11
ACTCOLI_TOPSOLIDHIT     EQU $12
ACTCOLI_BIGBLOCK        EQU $13
ACTCOLI_LOCK            EQU $14
ACTCOLI_TOPSOLID_END	EQU $20
ACTCOLI_ITEM_START		EQU $20
ACTCOLI_KEY             EQU $20
ACTCOLI_10HEART         EQU $21
ACTCOLI_STAR            EQU $22
ACTCOLI_COIN            EQU $23
ACTCOLI_10COIN          EQU $24
ACTCOLI_BIGCOIN         EQU $25
ACTCOLI_BIGHEART        EQU $26
ACTCOLI_ITEM_END		EQU $30
ACTCOLI_POW_START	EQU $30
ACTCOLI_POW 		EQU $30
ACTCOLI_POW_GARLIC 	EQU ACTCOLI_POW + PL_POW_GARLIC - 1 ; $30
ACTCOLI_POW_BULL 	EQU ACTCOLI_POW + PL_POW_BULL 	- 1 ; $31
ACTCOLI_POW_JET		EQU ACTCOLI_POW + PL_POW_JET 	- 1 ; $32
ACTCOLI_POW_DRAGON	EQU ACTCOLI_POW + PL_POW_DRAGON - 1 ; $33

; Collision type (Ladder special)
COLILD_SOLID      EQU %0000
COLILD_LADDER     EQU %0001
COLILD_LADDERTOP  EQU %0010
COLILDB_LADDER    EQU 0
COLILDB_LADDERTOP EQU 1
COLILDB_LADDERANY2 EQU 2
COLILD_LADDER2    EQU %0101
COLILD_LADDERTOP2 EQU %0110
; Collision type (General)
COLI_EMPTY EQU $00
COLI_SOLID EQU $01
COLI_WATER EQU $02

;
BLOCKID_SOLID     EQU $00
BLOCKID_SOLID_END EQU $28
BLOCKID_ITEMBOX   EQU $28
BLOCKID_BREAKTODOOR EQU $2E
BLOCKID_BOUNCE    EQU $2F
BLOCKID_SWITCH0T1 EQU $32
BLOCKID_UNUSED_SWITCH1T1 EQU $38
BLOCKID_SWITCH0T0 EQU $39
BLOCKID_TIMED0    EQU $3A
BLOCKID_TIMED1    EQU $3B
BLOCKID_ITEMUSED  EQU $3C
BLOCKID_UNUSED_ACTEMPTY EQU $3D
BLOCKID_SAND      EQU $3E
BLOCKID_SANDSPIKE EQU $3F
BLOCKID_MISCSOLID_END EQU $40
BLOCKID_LADDER    EQU $44
BLOCKID_LADDERTOP EQU $45
BLOCKID_COIN      EQU $46
BLOCKID_COIN2     EQU $47
BLOCKID_DOOR      EQU $48
BLOCKID_WATER     EQU $4A
BLOCKID_WATERDOOR EQU $4B
BLOCKID_WATERCUR  EQU $4C
BLOCKID_WATERCURU EQU $4C
BLOCKID_WATERCURD EQU $4D
BLOCKID_WATERCURL EQU $4E
BLOCKID_WATERCURR EQU $4F


BLOCKID_WATERHARDBREAK		EQU $50
BLOCKID_WATERBREAK			EQU $51
BLOCKID_WATERBREAK2			EQU $52
BLOCKID_WATERCOIN			EQU $53
BLOCKID_WATERBREAKTODOOR	EQU $54
BLOCKID_WATER2              EQU $55 ; With decoration
BLOCKID_WATER3              EQU $56 ; With decoration (top part of bottomless pit)
BLOCKID_WATER4              EQU $57 ; With decoration (bottom part of bottomless pit)
BLOCKID_WATER5              EQU $58 ; 
BLOCKID_WATERSPIKE			EQU $59
BLOCKID_UNUSED_WATERSPIKE2	EQU $5A
BLOCKID_WATERDOORTOP		EQU $5B
BLOCKID_WATER_END EQU $5C
BLOCKID_INSTAKILL EQU $5C
BLOCKID_SPIKE     EQU $5D
BLOCKID_SPIKE2    EQU $5E
BLOCKID_SPIKEHIDE EQU $5F
BLOCKID_EMPTY     EQU $60

; Special door transition types
DOORSPEC_ENTRANCE EQU $20
DOORSPEC_LVLCLEAR EQU $21
DOORSPEC_LVLCLEARALT EQU $22
DOORSPEC_INVALID EQU $23
DOORSPEC_NONE EQU $FF

; Demo mode status
DEMOMODE_NONE  EQU $00
DEMOMODE_INIT  EQU $03
DEMOMODE_LEVEL EQU $04

; ============================================================
; COURSE CLEAR SCREEN

; X positions
COURSECLR_XPOS_SIDER EQU $88 	; Right of second door, for intro
COURSECLR_XPOS_SIDEL EQU $28 	; Left of first door, for intro
COURSECLR_XPOS_COIN EQU $40 	; Coin bonus door
COURSECLR_XPOS_HEART EQU $70 	; Heart bonus door
COURSECLR_XPOS_EXIT EQU $C0 	; Off-screen right

; ============================================================
; BONUS GAME

; Player position in the coin bonus game
COINBONUS_PLPOS_EXIT   EQU $00
COINBONUS_PLPOS_LEFT   EQU $01
COINBONUS_PLPOS_MID    EQU $02
COINBONUS_PLPOS_RIGHT  EQU $03

; Item types
COINBONUS_ITEM_10TON EQU $00
COINBONUS_ITEM_MONEYBAG EQU $01

; Player X position hotspots in the coin bonus game
COINBONUS_PLXPOS_EXIT  EQU $0C
COINBONUS_PLXPOS_LEFT  EQU $2F
COINBONUS_PLXPOS_MID   EQU $4C
COINBONUS_PLXPOS_RIGHT EQU $67

; Item *OBJ frames*
COINBONUS_OBJ_ITEM_NONE EQU $00
COINBONUS_OBJ_ITEM_10TON EQU COINBONUS_ITEM_10TON+1
COINBONUS_OBJ_ITEM_MONEYBAG EQU COINBONUS_ITEM_MONEYBAG+1


; Specifies what tile definitions to use in the coin bonus game
COINBONUS_BUCKET_NOCHANGE  EQU $00
COINBONUS_BUCKET_PULL      EQU $01
COINBONUS_BUCKET_NORMAL    EQU $02

; ------------------------------------------------------------


HEARTBONUS_SEL_HARD EQU $00
HEARTBONUS_SEL_MED  EQU $01
HEARTBONUS_SEL_EASY EQU $02
HEARTBONUS_SEL_EXIT EQU $03

HEARTBONUS_TEXT_NONE EQU $00
HEARTBONUS_TEXT_READY EQU $01
HEARTBONUS_TEXT_GO EQU $02

HEARTBONUS_PLMODE_MOVE EQU $00
HEARTBONUS_PLMODE_LOCK EQU $01
HEARTBONUS_PLMODE_THROW EQU $02


HEARTBONUS_OBJ_ENEMYWALK0 EQU $01
HEARTBONUS_OBJ_ENEMYWALK1 EQU $02
HEARTBONUS_OBJ_ENEMYWALK2 EQU $03
HEARTBONUS_OBJ_ENEMYSTUN EQU $04

HEARTBONUS_OBJ_BOMB0 EQU $01
HEARTBONUS_OBJ_BOMB1 EQU $02
HEARTBONUS_OBJ_UNUSED_BOMBEXPL0 EQU $03
HEARTBONUS_OBJ_BOMBEXPL1 EQU $04
HEARTBONUS_OBJ_BOMBEXPL2 EQU $05
HEARTBONUS_OBJ_BOMBEXPL3 EQU $06



HEARTBONUS_OBJ_BOMBLIGHT0 EQU $01
HEARTBONUS_OBJ_BOMBLIGHT1 EQU $02

HEARTBONUS_OBJ_BOMBICON_BOMB EQU $01
HEARTBONUS_OBJ_BOMBICON_HIT EQU $02
HEARTBONUS_OBJ_BOMBICON_MISS EQU $03


HEARTBONUS_BOMBPATH_BAD0 EQU $00
HEARTBONUS_BOMBPATH_BAD1 EQU $01
HEARTBONUS_BOMBPATH_BAD2 EQU $02
HEARTBONUS_BOMBPATH_BAD3 EQU $03
HEARTBONUS_BOMBPATH_GOOD0 EQU $04
HEARTBONUS_BOMBPATH_GOOD1 EQU $05
HEARTBONUS_BOMBPATH_GOOD2 EQU $06
HEARTBONUS_BOMBPATH_GOOD3 EQU $07

; ============================================================
; TREASURE ROOM

; Relative to LevelBlock_TrRoom
TRROOM_TILEID_DIGITS EQU $D0

TRROOM_BLOCKID_TREASURE_C      EQU $0E
TRROOM_BLOCKID_TREASURE_I      EQU $0F
TRROOM_BLOCKID_TREASURE_F      EQU $10
TRROOM_BLOCKID_TREASURE_O      EQU $11
TRROOM_BLOCKID_TREASURE_A      EQU $12
TRROOM_BLOCKID_TREASURE_N      EQU $13
TRROOM_BLOCKID_TREASURE_H      EQU $14
TRROOM_BLOCKID_TREASURE_M      EQU $15
TRROOM_BLOCKID_TREASURE_L      EQU $16
TRROOM_BLOCKID_TREASURE_K      EQU $17
TRROOM_BLOCKID_TREASURE_B      EQU $18
TRROOM_BLOCKID_TREASURE_D      EQU $19
TRROOM_BLOCKID_TREASURE_G      EQU $1A
TRROOM_BLOCKID_TREASURE_J      EQU $1B
TRROOM_BLOCKID_TREASURE_E      EQU $1C
TRROOM_BLOCKID_TREASURE_EMPTY  EQU $1D
; ============================================================

END_OBJ_HELD_LAMP EQU $01
END_OBJ_HELD_LAMPINV EQU $02
END_OBJ_HELD_MONEYBAG1 EQU $03
END_OBJ_HELD_MONEYBAG2 EQU $04
END_OBJ_HELD_MONEYBAG3 EQU $05
END_OBJ_HELD_MONEYBAG4 EQU $06
END_OBJ_HELD_MONEYBAG5 EQU $07
END_OBJ_HELD_MONEYBAG6 EQU $08

END_CASTLE_BIRDHOUSE EQU $01
END_CASTLE_TREEHOUSE EQU $02
END_CASTLE_HOUSE EQU $03
END_CASTLE_PAGODA EQU $04
END_CASTLE_BIG EQU $05
END_CASTLE_PLANET EQU $06


END_OBJ_CLOUDA0 EQU $01
END_OBJ_CLOUDA1 EQU $02
END_OBJ_CLOUDB0 EQU $03
END_OBJ_CLOUDB1 EQU $04
END_OBJ_CLOUDC0 EQU $05
END_OBJ_CLOUDC1 EQU $06
END_OBJ_WLOGO EQU $07
END_OBJ_WLOGOINV EQU $08

END_OBJ_BALLOONTHINK EQU $01
END_OBJ_BALLOONSPEAK EQU $02
END_OBJ_BALLOONGENIE EQU $03


END_OBJ_GENIEFACE_LOOK EQU $01		; Eyes open, mouth closed
END_OBJ_GENIEFACE_LOOKMOUTH EQU $02	; Eyes open, mouth open
END_OBJ_GENIEFACE_BLINK EQU $03		; Eyes closed, mouth closed
END_OBJ_GENIEFACE_UNUSED_BLINKMOUTH EQU $04; Eyes closed, mouth open

END_GENIE_CLOSED EQU $01
END_GENIE_POINT EQU $02
END_GENIE_PALM EQU $03

; Credits text next (line) mode
CTN_CLEARLINE2 EQU $00
CTN_CLEARBOTH EQU $01
CTN_LASTLINE EQU $02
CTN_HALT EQU $03
