;
; BANK 1 - Mode/Submode Jump & Gameplay + Course Clear + Treasure Room
;
; =============== CheckMode ===============
; This subroutine handles the jump to the current mode.
; All game modes are listed here in this table below.
CheckMode:
	ld   a, [sGameMode]
	rst  $28
	dw Mode_Title
	dw Mode_Map
	dw Mode_LevelInit
	dw Mode_Level
	dw Mode_LevelClear
	dw Mode_LevelDeadFadeout
	dw Mode_LevelClearSpec
	dw Mode_TimeUp
	dw Mode_GameOver
	dw Mode_Ending
	dw Mode_LevelDoor
	dw Mode_Treasure
	dw Mode_LevelEntrance
	dw CourseClr_HeartBonus ;X
	dw Mode_Null ;X (dummy mode)
	
; =============== Mode_Title ===============
Mode_Title:
	ld   a, [sSubMode]
	rst  $28
	dw Mode_Title_Intro
	dw Mode_Title_SwitchToSaveSelectInit ; [TCRF] Not used directly as submode
	dw Mode_Title_SaveSelectInit
	dw Mode_Title_SaveSelectIntroA
	dw Mode_Title_SaveSelectIntroB
	dw Mode_Title_SaveSelect
	dw Mode_Title_SaveSelectError ; [POI] SAVE DATA ERROR

; =============== Mode_Title_Intro ===============
Mode_Title_Intro:
	; Should we transition from the title screen to another mode?
	ld   a, [sTitleRetVal]
	dec  a					; $01 - Demo mode
	jr   z, .toDemoMode
	dec  a					; $02 - Save select
	jr   z, Mode_Title_SwitchToSaveSelectInit
	ld   a, $01
	ld   [sStaticScreenMode], a
	call HomeCall_Title_CheckMode
	ret
.toDemoMode:
	; Initialize demo mode
	xor  a						
	ld   [sTitleRetVal], a
	ld   [sStaticScreenMode], a
	ld   a, DEMOMODE_WAITPLAYBACK
	ld   [sDemoMode], a
	ld   a, PL_POW_GARLIC
	ld   [sPlPower], a
	ld   a, $01
	ld   [sDemoFlag], a
	ld   a, BGMACT_FADEOUT
	ld   [sBGMActSet], a
	
	; Which level should the demo start on?
	ld   a, [sDemoId]
	cp   a, $06			; Out of range?
	jr   c, .pickDemo		
	xor  a
	ld   [sDemoId], a
.pickDemo:
	dec  a
	jr   z, .c04 ; $01
	dec  a
	jr   z, .c09 ; $02
	dec  a
	jr   z, .c10 ; $03
	dec  a
	jr   z, .c22 ; $04
	dec  a
	jr   z, .c18 ; $05
.c01:
	ld   a, LVL_C01A
	jr   .startLevel
.c04: 
	ld   a, LVL_C04
	jr   .startLevel
.c09:
	ld   a, LVL_C09
	jr   .startLevel
.c10:
	ld   a, LVL_C10
	jr   .startLevel
.c22:
	ld   a, LVL_C22
	jr   .startLevel
.c18:
	ld   a, LVL_C18
.startLevel:
	ld   [sLevelId], a
	jp   CourseScr_LevelInit
	
; =============== Mode_Title_SwitchToSaveSelectInit ===============
Mode_Title_SwitchToSaveSelectInit:
	xor  a
	ld   [sTitleRetVal], a
	ld   [sStaticScreenMode], a
	ld   [sMapRetVal], a
	ld   a, GM_TITLE_INITSAVESEL
	ld   [sSubMode], a
	call HomeCall_Sound_StopAllStub
	ld   a, SFX1_03
	ld   [sSFX1Set], a
	ret
	
; =============== Mode_Map ===============
Mode_Map:
	ld   a, [sSubMode]
	rst  $28
	dw Map_Do
	dw CourseScr_Do
; =============== Map_Do ===============
; Nearly all of the map screen code uses this submode.
Map_Do:
	; Mark the VBlank mode used
	ld   a, $01
	ld   [sMapVBlankMode], a
	; Was the course screen reqested?
	ld   a, [sMapRetVal]		
	and  a
	jr   nz, .initCourseScreen
	call HomeCall_Map_CheckMapId
	ret
.initCourseScreen:
	; Set fixed screen mode
	xor  a
	ld   [sMapVBlankMode], a
	call StopLCDOperation
	; Clear memory
	ld   hl, sLvlScrollY_High
	xor  a
	ld   bc, $0600
	call ClearRAMRange
	; Prepare the VRAM
	call HomeCall_LoadGFX_CourseAlpha
	call ClearBGMap2F	
	; Reset scroll coords (not actually necessary -- submaps never scroll)
	xor  a
	ldh  [rSCY], a
	ldh  [hScrollY], a
	ldh  [rSCX], a
	ld   [sScrollX], a
	; Write "COURSE" in the tilemap
	ld   hl, vBGCourseText0
	ld   a, $0C		; C
	ldi  [hl], a
	ld   a, $18		; O
	ldi  [hl], a
	ld   a, $1E		; U
	ldi  [hl], a
	ld   a, $1B		; R
	ldi  [hl], a
	ld   a, $1C		; S
	ldi  [hl], a
	ld   a, $0E		; E
	ld   [hl], a
	; Write "No." in the tilemap (uses 2 tiles)
	ld   hl, vBGCourseText1
	ld   a, $2B
	ldi  [hl], a
	ld   a, $2C
	ld   [hl], a
	; Determine the course number to print on-screen.
	ld   a, [sMapLevelIdSel]
	ld   [sLevelId], a		; and set the current level id as well
	call GetCourseNum		
	ld   [sCourseNum], a
	
	; Write the digit to the tilemap
	; As the number is in BCD format, we can simply get each nybble directly.
	ld   b, a			; First digit
	swap a				
	and  a, $0F
	ld   [vBGCourseNum0], a
	ld   a, b			; Second digit
	and  a, $0F
	ld   [vBGCourseNum1], a
	
	ld   a, GM_MAP_COURSESCR	; Switch to course screen submode
	ld   [sSubMode], a
	ld   a, $E1
	ldh  [rBGP], a
	ld   a, $83
	ldh  [rLCDC], a
	ld   a, $80					; Show the Course Screen for $80 frames
	ld   [sCourseScrTimer], a
	ret
; =============== CourseScr_Do ===============
; Displays the static course screen.
CourseScr_Do:
	; [TCRF] If debug mode is enabled, handle the level select instead
	ld   a, [sDebugMode]
	and  a
	jr   nz, LevelSelect_Do
	;--
	ldh  a, [hJoyNewKeys]		; Press A or START to skip the delay
	and  a, KEY_A|KEY_START
	jr   nz, CourseScr_LevelInit
	ld   a, [sCourseScrTimer]	; wait the $80 frames
	dec  a
	ld   [sCourseScrTimer], a
	ret  nz						; return if not elapsed yet
CourseScr_LevelInit:
	xor  a						; Switch to level loading mode
	ld   [sSubMode], a
	ld   [sCourseScrTimer], a
	ld   a, GM_LEVELINIT
	ld   [sGameMode], a
	ret
; =============== LevelSelect_Do ===============
; [TCRF] Level Select screen.
; This takes the place of the normal Course Intro screen if debug mode is active.
;
; Unlike the normal course intro screen, to start a level you have to explicitly select it.
; The auto start timer is ignored here.
LevelSelect_Do:
	ld   hl, sLevelId		
	ldh  a, [hJoyNewKeys]
	; Determine action to perform based on input
	bit  KEYB_SELECT, a
	jr   nz, LevelSelect_ChkToggleDebug
	bit  KEYB_UP, a
	jr   nz, .incLevel
	bit  KEYB_DOWN, a
	jr   nz, .decLevel
	and  a, KEY_A|KEY_START
	jr   nz, CourseScr_LevelInit
	
.writeLevelNum:
	; Set to BC the course number as usual
	ld   a, [sCourseNum]	; Write both LevelID and LevelNum to the tilemap
	ld   d, a
	swap a					; Write high digit
	and  a, $0F
	ld   b, a				; Write low digit
	ld   a, d
	and  a, $0F				
	ld   c, a
	
	; Set to HL the level id (hex format)
	ld   a, [sLevelId]		
	ld   d, a				; Write high digit
	swap a
	and  a, $0F
	ld   h, a
	ld   a, d				; Write low digit
	and  a, $0F
	ld   l, a
	
	; [TCRF]
	; This is meant to blank the level ID when debug mode gets disabled.
	; However, execution never reaches here in that case.
	; Presumably, LevelSelect_ChkToggleDebug should have jumped to .writeLevelNum rather than returning.
	;
	ld   a, [sDebugMode]	; Did Debug Mode (somehow get disabled?
	and  a
	jr   nz, .waitHBlankEnd
	ld   hl, $2F2F			; If so, mark vBGCourseLvlId to use blank tiles
	
.waitHBlankEnd: mWaitForNewHBlank
	
	; Write the values to the tilemap
	ld   a, b
	ld   [vBGCourseNum0], a
	ld   a, c
	ld   [vBGCourseNum1], a
	ld   a, h
	ld   [vBGCourseLvlId0], a
	ld   a, l
	ld   [vBGCourseLvlId1], a
	ret  

.incLevel:
	ld   a, [sDebugMode]	; See [TCRF] note above
	and  a
	jr   z, .writeLevelNum
	;--
	ld   a, [hl]			; 
IF TEST == 0
	cp   a, LVL_LASTVALID	; Are we on the last valid level id?
	ret  z					; if so, don't increase it more
ENDC
	inc  a
	ld   [hl], a
	call GetCourseNum
	ld   [sCourseNum], a
	jr   .writeLevelNum
	
.decLevel:
	ld   a, [sDebugMode]	; See [TCRF] note above
	and  a
	jr   z, .writeLevelNum
	;--
	ld   a, [hl]
IF TEST == 0
	and  a					; Are we on the level Id $00?
	ret  z					; If so, don't decrement it further
ENDC
	dec  a
	ld   [hl], a
	call GetCourseNum
	ld   [sCourseNum], a
	jr   .writeLevelNum
	
; =============== LevelSelect_ChkToggleDebug ===============
; Adds to the toggle counter. Once it reaches $0A, it toggles debug mode.
;
; [TCRF] This is only called when debug mode is active, not when it's disabled.
;        This suggests debug mode could have been enabled in-game at one point.
;        Possibly, the code to check for the SELECT button may have been part of CourseScr_Do instead of LevelSelect_Do.
LevelSelect_ChkToggleDebug:
	ld   a, [sDebugToggleCount]		; Update count
	inc  a
	ld   [sDebugToggleCount], a	
	cp   a, $0A						; Has it reached $0A?
	ret  nz							; If not, return
	xor  a							; Otherwise toggle debug and reset the count
	ld   [sDebugToggleCount], a
	ld   a, [sDebugMode]
	xor  a, $01
	ld   [sDebugMode], a
	ret
	
; =============== Mode_LevelInit ===============
Mode_LevelInit:
	ld   a, [sSubMode]
	rst  $28
	dw Mode_LevelInit_LoadLevel
	dw Level_FadeInBG
	dw Level_FadeInOBJ
	dw Mode_LevelInit_StartLevel
	
; =============== Mode_LevelInit_LoadLevel ===============
; Loads all of the level data and prepares the screen.
Mode_LevelInit_LoadLevel:
	call StopLCDOperation
	call Save_CopyAllToSave
	xor  a
	ld   [sActHeld], a
	call Level_LoadData
	call Level_DrawFullScreen
	call StatusBar_LoadBG
	call HomeCall_Level_LoadScrollLocks
	; Assign 400 secods of time
	ld   a, $04
	ld   [sLevelTime_High], a
	ld   a, $00
	ld   [sLevelTime_Low], a
	
	xor  a
	ld   [sScreenUpdateMode], a
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	ldh  [rLCDC], a
	call StatusBar_DrawHearts
	call StatusBar_DrawLives
	; Blank the palettes in preparation for the fade in
	xor  a
	ldh  [rBGP], a
	ld   a, $FF
	ldh  [rOBP0], a
	ld   a, GM_LEVELINIT_FADEBG
	ld   [sSubMode], a
	ret
; =============== Mode_LevelInit_StartLevel ===============
; Switches to the main gameplay mode, optionally setting up parallax.
Mode_LevelInit_StartLevel:
	call HomeCall_WriteWarioOBJLst
	; If we've flagged the demo mode...
	ld   a, [sDemoMode]
	cp   a, DEMOMODE_WAITPLAYBACK	; Are we waiting for demo playback?
	jr   nz, .startLevel			; If not, skip
	ld   a, DEMOMODE_PLAYBACK		; Otherwise set demo playback proper
	ld   [sDemoMode], a
.startLevel:
	; Switch to the main level
	ld   a, GM_LEVEL
	ld   [sGameMode], a
	xor  a
	ld   [sSubMode], a
	; Reset timer
	xor  a
	ld   [sTimer], a
	ld   [sActTimer], a
	; Disable STAT
	ld   hl, rIE
	res  IB_STAT, [hl]
	
	; Set up parallax if a level starts you in an auto-scrolling room.
	; [TCRF] No level does this, so we always return on the first check.
	;        Code is almost identical to parallax setup code in Mode_LevelDoor_LoadRoom though,
	;        except here it lacks the boss room check (for obv. reasons).
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_AUTOR		; Is this an auto-scrolling mode?
	ret  c						; If not (< $30), return
	;--
	cp   a, LVLSCROLL_AUTOR2	; Is this a non-parallax autoscroll mode?
	ret  nc						; If so (>= $40), return
	
	cp   a, LVLSCROLL_AUTOL		; Autoscrolling to the left?
	jr   nz, .autoRight		; If not, jump
.autoLeft:
	ld   a, PRX_TRAINMOUNTL
	ld   [sParallaxMode], a
.autoRight:	; defaults to PRX_TRAINMOUNTR ($00)

	; Enable LCDC parallax trigger
	xor  a
	ldh  [rIF], a
	ldh  [rLYC], a	; Trigger at scanline 0
	
	ld   hl, rIE	; Enable STAT
	set  IB_STAT, [hl]
	ld   a, $40		; Enable LYC trigger
	ldh  [rSTAT], a
	
	ldh  a, [rSCX]	; Keep current parameters for first trigger
	ld   [sParallaxX0], a
	ld   [sParallaxX1], a
	ret  

IF FIX_BUGS == 1
; =============== Game_CalcPlRelPos ===============
; Calculates the player's relative Y position, used for actor collision.
; This "fixes" a chicken/egg problem related to PlActColi_LoopSearch using outdated values.
Game_CalcPlRelPos:
	; Calculate the relative Y pos.
	; NOTE: This is the value used for actor collision.
	ldh  a, [hScrollY]
	ld   b, a			; B = ScrollY
	ld   a, [sPlY_Low]	; A = WarioY
	add  OBJ_OFFSET_Y	; Account for the origin used by sprite mappings.
	sub  a, b			; Result = WarioY + $10 - ScrollY
	ld   [sPlYRel], a
	; Calculate the relative X pos
	ld   a, [sScrollX]
	ld   b, a			; B = ScrollX
	ld   a, [sPlX_Low]	; A = WarioX
	add  OBJ_OFFSET_X	; ""
	sub  a, b			; Result = WarioX + $08 - ScrollX
	ld   [sPlXRel], a
	ret
ENDC
; =============== Mode_Level ===============
Mode_Level:
	call Game_CheckTogglePause
	ld   a, [sPaused]
	and  a
	jr   nz, Game_PauseDo
	
	; Every $40 frames, decrement the level timer
	ld   a, [sTimer]
	and  a, $3F
	call z, Game_DecLevelTime
	
	; Ignore input if the hat switch effect is active
	ld   a, [sPlHatSwitchTimer]
	and  a
	jr   nz, .skipInput
	
	; [TCRF] Debug feature
	;        Press SELECT during gameplay to switch hats
	ldh  a, [hJoyNewKeys]
	bit  KEYB_SELECT, a
	call nz, Game_DebugHatSwitch
	
	; Handle player, block collision & misc effects
	call HomeCall_Game_Do
	
	; With that done, save this for the next frame
	ld   a, [sActHeld]
	ld   [sActHeldLast], a

	; If we're invicincible, flash the palette and handle the timer
	; along what happens when it elapses
	ld   a, [sPlInvincibleTimer]
	and  a
	call nz, Pl_DoInvicibilityTimer
	
.skipInput:
	; If there's an hat switch effect active, handle it
	ld   a, [sPlHatSwitchTimer]
	and  a
	call nz, Game_DoHatSwitchAnim
	
	; [BUG] This is using outdated sLvlScroll* values, which makes the sprites desync when scrolling the screen.
	;       It should only be done after Level_Screen_ScrollHorz and Level_Screen_ScrollVert are called.
	
IF FIX_BUGS == 1

	ld   a, [sPlHatSwitchTimer]
	and  a
	jr   nz, .noWorkaround
	
	; Workaround caused by the new screen update order.
	; Since the player/screen is scrolled earlier but actors aren't processed until the end,
	; they use old relative position values which can break the actor top-solid handling.
	; Calculate the old version of sPlYRel/sPlXRel, and use those to determine collision detection.
	ld   a, [sPlYRel]
	ld   b, a
	ld   a, [sPlXRel]
	ld   c, a
	push bc
		call Game_CalcPlRelPos
		call HomeCall_PlActColi_Do 
	pop  bc
	ld   a, b
	ld   [sPlYRel], a
	ld   a, c
	ld   [sPlXRel], a
	
.noWorkaround:
	;
	; Now calculate the new versions of sPlYRel/sPlXRel
	;

	; HomeCall_Game_Do sets the variables needed by these
	call Level_Screen_ScrollHorz
	call Level_Screen_ScrollVert
ENDC
	; Update the scroll registers, making sure to account for the offset
	ld   a, [sLvlScrollY_Low] ; hScrollY = sLvlScrollY_Low - LVLSCROLL_YOFFSET
	sub  a, LVLSCROLL_YOFFSET	
	ldh  [hScrollY], a
	ld   a, [sLvlScrollX_Low] ; sScrollX = sLvlScrollX_Low - LVLSCROLL_XOFFSET
	sub  a, LVLSCROLL_XOFFSET
	ld   [sScrollX], a
	ld   a, [sLvlScrollX_High]
	sbc  a, $00					; account for underflow
	ld   [sScrollX_High], a

	
	call HomeCall_WriteWarioOBJLst	; Draw player
	call HomeCall_ExActS_ExecuteAllAndWriteOBJLst	; Draw and execute ExAct
	ld   a, [sPlHatSwitchTimer]
	and  a
	jr   nz, Game_UpdateScreen

IF FIX_BUGS == 0
	call HomeCall_PlActColi_Do 	
	call Level_Screen_ScrollHorz
	call Level_Screen_ScrollVert
ENDC
	call Level_Scroll_SetAutoScroll
Game_UpdateScreen:
	call Level_Scroll_SetScreenUpdate
	call HomeCall_ActS_Do
	ret
	
; =============== Game_PauseDo ===============
; Handles the game's pause mode.
Game_PauseDo:
	; Normally the pause functionality only allows to unpause the game.
	; However, this also handles the debug functions.
	
	ld   a, [sStatusEditToggleCount]
	and  a								; Did we press SELECT at least once?
	jp   z, .mainPause					; If not, jump
	;--
	; Status bar editor activation check
	
	ldh  a, [hJoyNewKeys]
	bit  KEYB_SELECT, a					; Pressing SELECT?
	jr   z, .checkDebug					; If not, jump
	
	
	xor  a								; Increase the editor toggle count
	ld   [sStatusEdit], a
	ld   a, [sStatusEditToggleCount]
	inc  a
	ld   [sStatusEditToggleCount], a
	
	cp   a, $10							; Have we pressed SELECT $10 times?
	jr   nz, .noStatusEdit				; If not, jump
.setStatusEdit:
	ld   a, $01							; Enable status bar editor
	ld   [sStatusEdit], a
	ld   a, $90							; Initial Y coordinate (determines nothing)
	ld   [sStatusEditY], a
	ld   a, $28							; Initial X coordinate (determines selected value)
	ld   [sStatusEditX], a				; This selects the rightmost digit of the lives counter
	;--
.checkDebug:
	; Debug mode type check
	
	;--
	; If the status bar editor flag is set, handle that
	ld   a, [sStatusEdit]
	and  a								; Are we editing the status bar?
	jr   z, .noStatusEdit				; If not, skip ahead
.statusEdit:
	call Game_StatusBarEdit				; Otherwise, run the status bar editor
	jp   .end
	;--
.noStatusEdit:
	; [TCRF] Otherwise, handle freeroaming mode.
	; Only if the actual debug mode is enabled
	ld   a, [sDebugMode]
	and  a
	jp   z, .end
	
DEF DEBUG_FREEROAM_SPEED EQU $03
	; Where do you want to go?
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jr   nz, .moveRight
	bit  KEYB_LEFT, a
	jr   nz, .moveLeft
	bit  KEYB_UP, a
	jr   nz, .moveUp
	bit  KEYB_DOWN, a
	jr   nz, .moveDown
	jp   .end
.moveRight:
	ld   b, DEBUG_FREEROAM_SPEED
	call Pl_MoveRight
	call Level_ScreenLock_DoRight
	
	ld   a, [sLvlScrollLockCur]
	bit  DIRB_R, a				; Is there a right screen lock?
	jp   nz, .end				; If so, jump
	; Otherwise scroll the screen right 3px
	ld   a, DEBUG_FREEROAM_SPEED
	ld   [sLvlScrollHAmount], a
	call Level_Screen_ScrollHorz
	jp   .end
.moveLeft:                  
	ld   b, DEBUG_FREEROAM_SPEED
	call Pl_MoveLeft
	call Level_ScreenLock_DoLeft
	
	ld   a, [sLvlScrollLockCur]
	bit  DIRB_L, a				; Is there a left screen lock?
	jr   nz, .end				; If so, jump
	; Otherwise scroll the screen left 3px
	ld   a, -DEBUG_FREEROAM_SPEED
	ld   [sLvlScrollHAmount], a
	call Level_Screen_ScrollHorz
	jr   .end
.moveUp:                  
	ld   b, DEBUG_FREEROAM_SPEED
	call Pl_MoveUp
	; Don't scroll the screen unless we're in freescroll mode
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_FREE
	jr   c, .end
	cp   a, LVLSCROLL_CHKAUTO
	jr   nc, .end
	
	ld   a, -DEBUG_FREEROAM_SPEED
	ld   [sLvlScrollVAmount], a
	call Level_Screen_ScrollVert
	jr   .end
.moveDown:                  
	ld   b, DEBUG_FREEROAM_SPEED
	call Pl_MoveDown
	; Don't scroll the screen unless we're in freescroll mode
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_FREE
	jr   c, .end
	cp   a, LVLSCROLL_CHKAUTO
	jr   nc, .end
	ld   a, DEBUG_FREEROAM_SPEED
	
	ld   [sLvlScrollVAmount], a
	call Level_Screen_ScrollVert
	jr   .end
;-- End of debug code --
.mainPause:
	; Increase the debug toggle count on SELECT
	ldh  a, [hJoyNewKeys]
	bit  KEYB_SELECT, a					
	jr   z, .noSelect						
	ld   a, $01
	ld   [sStatusEditToggleCount], a
.noSelect:
	bit  4, a					; ?
.end:
	; Update hardware scrolling registers
	ld   a, [sLvlScrollY_Low]	; hScrollY = sLvlScrollY_Low - $48
	sub  a, LVLSCROLL_YOFFSET
	ldh  [hScrollY], a
	ld   a, [sLvlScrollX_Low]	; hScrollX = sLvlScrollX_Low - $50
	sub  a, LVLSCROLL_XOFFSET
	ld   [sScrollX], a
	ld   a, [sLvlScrollX_High]	; account for carry
	sbc  a, $00
	ld   [sScrollX_High], a
	call HomeCall_WriteWarioOBJLst
	jp   Game_UpdateScreen
; =============== Game_CheckTogglePause ===============
; This subroutine handles the pausing/unpausing of the game.
Game_CheckTogglePause:
	; Only if we're toggling the pause status
	ldh  a, [hJoyNewKeys]
	bit  KEYB_START, a
	ret  z
	;--
	; Toggle pause statua
	ld   a, [sPaused]
	xor  $01
	ld   [sPaused], a
	
	; Are we pausing or unpausing?
	jr   z, .unpause
.pause:
	; Pause actors too
	ld   a, $01
	ld   [sPauseActors], a
	; Move status bar upwards by 8px
	ldh  a, [rWY]
	sub  a, $08
	ldh  [rWY], a
	; Set pause sound
	ld   a, $01
	ld   [sSndPauseActSet], a
	ret
.unpause:
	xor  a
	ld   [sPauseActors], a
	ld   [sStatusEditToggleCount], a
	ld   [sStatusEdit], a
	ld   [sUnused_AC83], a ; [TCRF] Not used anywhere but here.
	; Move status bar downwards by 8px
	ldh  a, [rWY]
	add  $08
	ldh  [rWY], a
	; Set unpause sound
	ld   a, $02
	ld   [sSndPauseActSet], a
	;--
	; [TCRF] Check for ending warp key combination
	ld   a, [sDebugMode]
	and  a					; Are we in debug mode?
	ret  z
	ldh  a, [hJoyKeys]		; Are we holding down B+DOWN?
	and  a, KEY_B|KEY_DOWN
	cp   a, KEY_B|KEY_DOWN
	jr   z, .jumpToEnding	; If so, set the ending mode
	ret
.jumpToEnding:
	ld   a, GM_ENDING
	ld   [sGameMode], a
	ld   a, GM_ENDING_GENIECUTSCENE-$01	; Set mode before
	ld   [sSubMode], a
	jp   Mode_Ending_InitGenieCutscene
	;--
; =============== Game_StartEnding ===============
; This subroutine switches to the first part of the ending mode.
Game_StartEnding:
	ld   a, GM_ENDING
	ld   [sGameMode], a
	xor  a
	ld   [sSubMode], a
	ld   [sHurryUp], a
	; Also mark the save as completed
	ld   a, $01
	ld   [sGameCompleted], a
	call Save_CopyAllToSave
	ret
; =============== Game_DebugHatSwitch ===============
; Handles the powerup increment debug feature.
; There are two possible ways to trigger this:
; - Pressing SELECT during gameplay. Requires sDebugMode to be set.
; - Hovering over Wario's icon in the status bar. Only if sDebugMode isn't set.
Game_DebugHatSwitch:
	ld   a, [sDebugMode]
	and  a
	ret  z
StatusBar_HatSwitch:
	; Don't interfere with the vertical scrolling in SEGSCRL mode.
	ld   a, [sLvlScrollTimer]
	and  a
	ret  nz
	
	ld   a, [sPlPower]	; sPlPower++
	inc  a
	ld   [sPlPowerSet], a
	cp   a, $05				; Did we went past the last valid powerup?
	jp   nz, Game_InitHatSwitch		; If not, jump
	xor  a					; Otherwise wrap back to small Wario
	ld   [sPlPowerSet], a
	jp   Game_InitHatSwitch
; =============== Game_DecLevelTime ===============
; This subroutine decrements the level timer, handling any of the
; effects when certain digits are reached (ie: warning SFX, killing the player on time over)
Game_DecLevelTime:
	; Timer should stay frozen if the player's already dead
	ld   a, [sPlAction]
	cp   a, PL_ACT_DEAD
	ret  z
	
	; Play SFX if there are less than 5 seconds left on the timer
	ld   a, [sLevelTime_Low]
	cp   a, $05
	call c, .nearTimeOver
	
	; Decrement lower digit (adjusted to decimal)
	ld   a, [sLevelTime_Low]
	sub  a, $01
	daa
	ld   [sLevelTime_Low], a
	
	jr   nc, .noUnderflow	
	; If it underflowed, decrement the high digit
	ld   a, [sLevelTime_High]
	sub  a, $01
	ld   [sLevelTime_High], a
	jr   nc, .noUnderflow
	
	; If the high digit underflowed too, the time is up
	; Start the death sequence.
	xor  a
	ld   [sLevelTime_High], a
	ld   [sLevelTime_Low], a
	ld   a, $01
	ld   [sTimeUp], a
	ld   a, BGM_NONE
	ld   [sSFX2Set], a
	ld   [sBGMSet], a
	call Pl_StartDeathAnim
	xor  a
	ld   [sHurryUp], a
	ret
.nearTimeOver:
	; Ignore if the hundreds digit isn't 0
	ld   a, [sLevelTime_High]
	and  a
	ret  nz
	
	; If there's one second left, play a higher pitched SFX
	ld   a, [sLevelTime_Low]
	cp   a, $02					; >= 2 (&& < 5) secs left?
	jr   nc, .sfx1				; If so, jump
	ld   a, SFX2_04
	ld   [sSFX2Set], a
	ret
.sfx1:
	ld   a, $01					; this is silly
	ld   [sNoReset], a
	ld   a, SFX2_03					
	ld   [sSFX2Set], a
	ret
.noUnderflow:
	; Handle the hurry up
	
	; If we have exactly 100 seconds left, play the hurry up warning SFX
	ld   a, [sLevelTime_Low]
	and  a						; Is the low digit 0?
	jr   nz, .chkHurryUp		; If not, jump
	ld   a, [sLevelTime_High]
	dec  a						; Is the high digit 1?
	jr   nz, .chkHurryUp		; If not, jump
.hurryUp1:
	ld   a, $01					; Set phase 1 for later
	ld   [sHurryUp], a
	ld   a, SFX1_2A
	ld   [sSFX1Set], a
	ret
.chkHurryUp:
	; If we aren't in phase 1, don't fully initialize the hurry up state
	; This will only happen on the timer tick after 
	ld   a, [sHurryUp]
	dec  a
	ret  nz
.hurryUp2:
	ld   a, [sSFX1]
	cp   a, SFX1_2A
	ret  z
	
	; Mark full init
	ld   a, $02
	ld   [sHurryUp], a
	
	;--
	; BGM Handling
	
	; Never interrupt the invincibility BGM (which also doesn't have a faster tempo)
	ld   a, [sBGM]
	cp   a, BGM_INVINCIBILE
	ret  z
	
	; Clear the currently playing BGM to force restart whatever is played
	ld   a, BGM_NONE
	ld   [sBGM], a
	
	; Certain rooms request an alternate BGM to play when triggering the hurry up,
	; done since the default behaviour restarts the default level music.
	ld   a, [sHurryUpBGM]
	and  a
	jr   nz, .altBGM
	call HomeCall_Level_SetBGM
	ret
.altBGM:
	ld   [sBGMSet], a
	; This gets unset (for some reason) after being used once, so it won't
	; work properly after exiting hurry-up through debug.
	xor  a
	ld   [sHurryUpBGM], a
	ret
	
; =============== Mode_LevelClear ===============
Mode_LevelClear:
	; The "Level Clear" go from "pseudo-gameplay", to the Course Clear screen and the Treasure Room.
	ld   a, [sSubMode]
	rst  $28
	; The initial three modes are "pseudo-gameplay", as they take place in a level,
	; but the standard gameplay code doesn't run.
	; Because of that, these modes need to manually call certain subroutines, like
	; the ones for drawing Wario or processing actors.
	dw Mode_LevelClear_Fanfare
	dw Level_FadeOutOBJ0ToBlack
	dw Level_FadeOutBGToWhite
	; Course clear screen
	dw Mode_LevelClear_InitCourseClr
	dw Mode_LevelClear_CourseClr
	; Treasure room
	dw Mode_LevelClear_InitTrRoom;X ; [TCRF] This mode isn't executed directly -- Mode_LevelClear_CourseClr jumps to it instead. 
	dw Mode_LevelClear_TrRoomWait
	dw Mode_LevelClear_TrRoomCoinCount
	dw Mode_LevelClear_TrRoomIdle
	dw Mode_LevelClear_TrRoomExit
	
; =============== Mode_LevelClear_Fanfare ===============
; Triggers the fanfare after clearing a level.
Mode_LevelClear_Fanfare:
	
	;
	; Always draw and process actors + player
	;
	call HomeCall_WriteWarioOBJLst	; Draw Wario
	xor  a							; Drop whatever we're holding
	ld   [sActHeld], a
	call HomeCall_ActS_Do			; Run the actor code
	
	;
	; Do the manual timing sequence for animating the "wink" animation.
	; Of note is Small Wario having only a single frame for it.
	;
	
	ld   a, [sLevelClearTimer]
	; When the timer reaches $C0, the fanfare is over
	cp   a, $C0						; Timer == $C0?
	jr   z, .chkEndPowerup				; If so, jump
	inc  a							; Timer++
	ld   [sLevelClearTimer], a
	; Do the wink anim
	cp   a, $38						; Timer == $38?
	jr   z, .setFrame0				; If so, set OBJ_WARIO_THUMBSUP0
	cp   a, $48						; Timer == $48?
	jr   z, .setFrame1				; If so, set OBJ_WARIO_THUMBSUP1
	cp   a, $60						; Timer == $60?
	jr   z, .setFrame0				; If so, set OBJ_WARIO_THUMBSUP0
	ret
	
.setFrame0:
	; From the 38th frame, stop all actors.
	; This is enough time for any held actor to fall to the ground,
	; otherwise they'd get stuck in the air.
	ld   a, $01						
	ld   [sPauseActors], a
	
	; Set the correct anim frame depending on small/big player status
	ld   a, OBJ_WARIO_THUMBSUP0	; Set standard frame
	ld   [sPlLstId], a
	ld   a, [sSmallWario]
	and  a						; Are we small?
	ret  z						; If not, return
	ld   a, [sPlLstId]			; Add $30 for the Small Wario frame
	add  OBJ_SMALLWARIO_LEVELCLEAR-OBJ_WARIO_THUMBSUP0
	ld   [sPlLstId], a
	ret
.setFrame1:
	; Small Wario has no second frame for this animation
	ld   a, [sSmallWario]
	and  a						; Are we Small Wario?
	ret  nz						; If so, return
	ld   a, OBJ_WARIO_THUMBSUP1
	ld   [sPlLstId], a
	ret
	
.chkEndPowerup:
	;
	; Finishing a level as Small Wario turns you to Normal Wario.
	; If we were already big, we skip this and directly switch to the next submode.
	;
	ld   a, [sSmallWario]
	and  a							; Are we small Wario
	jr   z, .nextSubmode			; If not, skip ahead
	
	;
	; This hat switch is done manually and does not reuse the code from gameplay.
	; It could have been reused though, like the way it works in the ending.
	;
	ld   a, [sPlHatSwitchTimer]
	and  a							; Are we in the middle of the powerup switch?
	jr   nz, .contHatSwitch			; If so, jump
.startHatSwitch:
	ld   a, SFX1_06					; Play powerup SFX
	ld   [sSFX1Set], a
	ld   a, $10						; Perform anim for $10(*4) frames
	ld   [sPlHatSwitchTimer], a
	ret
.contHatSwitch:
	; Every 4 frames...
	ld   a, [sTimer]
	and  a, $03
	ret  nz
	; Handle the switch timer
	ld   a, [sPlHatSwitchTimer]		; Timer--
	dec  a
	ld   [sPlHatSwitchTimer], a
	; If the timer elapsed, we're done.
	jr   z, .endHatSwitch			; Timer == 0? If so, jump
	; Otherwise, alternate between the two frames.
	bit  0, a						; Even frame?
	jr   z, .hatSwitch_setSmFrame	; If so, jump
.hatSwitch_setBigFrame:
	ld   a, OBJ_WARIO_STAND
	ld   [sPlLstId], a
	ret
.hatSwitch_setSmFrame:
	ld   a, OBJ_SMALLWARIO_STAND
	ld   [sPlLstId], a
	ret
.endHatSwitch:
	ld   a, OBJ_WARIO_STAND			; Confirm "Big Wario" frame
	ld   [sPlLstId], a
	xor  a							; Switch to Big Wario
	ld   [sSmallWario], a
	ld   a, PL_POW_GARLIC			; ""
	ld   [sPlPower], a
.nextSubmode:
	xor  a
	ld   [sLevelClearTimer], a
	ld   a, GM_LEVELCLEAR_OBJFADE	; Submode++
	ld   [sSubMode], a
	ret
	
; =============== Mode_LevelClear_InitCourseClr ===============
; This subroutine initializes the "Course Clear" screen shown after finishing a level.
Mode_LevelClear_InitCourseClr:
	call StopLCDOperation
	call ClearWorkOAM
	call ExActS_ClearRAM
	call HomeCall_LoadVRAM_CourseClr
	call Level_CopyStatusBar00GFX
	call LoadGFX_WarioWithPowerHat
	
	; Set screen coords
	; [BUG] Fails to reset sScrollYOffset, so exiting a level when a screen shake is active
	;       can reveal the broken part of the tilemap below (and misalign Wario).
	xor  a
	ld   [sScrollX], a		; X Scroll = $00
	ldh  [rSCX], a			; 
	IF FIX_BUGS == 1
		ld   [sScrollYOffset], a
	ENDC
	ld   a, $08				; Y Scroll = $08
	ldh  [hScrollY], a
	ldh  [rSCY], a
	
	; CourseClr_PlInit set us just above the status bar.
	; Move up another 8px for the final position we're using.
	ld   a, [sPlYRel]		; sPlYRel -= $08
	sub  a, $08
	ld   [sPlYRel], a
	
	; Force status bar to be in its unpaused state (just in case)
	ld   a, $88
	ldh  [rWY], a
	ld   a, $07
	ldh  [rWX], a
	
	ld   hl, rIE					; Disable parallax
	res  IB_STAT, [hl]
	
	ld   a, $E4						; Set new palette
	ldh  [rBGP], a
	ld   a, $1C						; ""
	ldh  [rOBP0], a
	
	ld   a, GM_LEVELCLEAR_CLEAR		; Next submode
	ld   [sSubMode], a
	xor  a							; Initial mode
	ld   [sCourseClrMode], a
	ld   a, LCDC_ENABLE|LCDC_WTILEMAP|LCDC_WENABLE|LCDC_OBJENABLE|LCDC_PRIORITY
	ldh  [rLCDC], a
	ld   a, BGM_SELECTBONUS			; Play clear BGM
	ld   [sBGMSet], a
	ret
	
; =============== Mode_LevelClear_CourseClr ===============
Mode_LevelClear_CourseClr:
	call .main
	call HomeCall_NonGame_WriteWarioOBJLst
	ret
.main:
	;
	; Handle the walking sequence and player movement in this mode
	;
	
	ld   a, [sCourseClrMode]
	rst  $28
	dw CourseClr_IntroMoveR0
	dw CourseClr_IntroMoveL0
	dw CourseClr_IntroMoveR1
	dw CourseClr_CoinBonusPos
	; [TCRF] Unused "fade out" functionality.
	;        It appears that entering the door to the bonus games was meant to cause a fade out,
	;        but it appears to be unfinished -- these fade out subroutines are only meant to be called 
	;        under pseudo-gameplay, so it causes problems and ends up switching to the Treasure Room instead.
	dw Level_FadeOutOBJ0ToBlack;X
	dw Level_FadeOutBGToWhite;X
	dw CourseClr_CoinBonus
	dw CourseClr_MoveToHeartBonus
	dw CourseClr_HeartBonusPos
	; [TCRF] And here as well
	dw Level_FadeOutOBJ0ToBlack;X
	dw Level_FadeOutBGToWhite;X
	dw CourseClr_HeartBonus
	dw CourseClr_MoveToTrRoom
	dw CourseClr_MoveToCoinBonus
	
; =============== CourseClr_IntroMoveR0 ===============
; Mode $00: Player moves right.
CourseClr_IntroMoveR0:
	call NonGame_Wario_AnimWalkFast
	
	;
	; Move player horizontally
	;
	call CourseClr_GetPlWalkSpeed	; B = Walk speed
	ld   a, [sPlXRel]				; Move right by that
	add  b
	ld   [sPlXRel], a
	
	; When reaching X pos $88, switch to the next mode.
	; Because we start off-screen to the left, our coordinate is already
	; past $88, so we've got to deal with that.
	cp   a, $E0						; X >= $E0?
	ret  nc							; If so, we're still partially off-screen to the left
	cp   a, COURSECLR_XPOS_SIDER	; X < $88?
	ret  c							; If so, we haven't got there yet
	
.nextMode:
	; Otherewise, prepare for the next mode, when walking behind the doors.
	ld   a, [sPlYRel]				; Move up for perspective effect
	sub  a, $08
	ld   [sPlYRel], a
	ld   a, [sCourseClrMode]		; Next mode
	inc  a
	ld   [sCourseClrMode], a
	ld   a, OBJLST_BGPRIORITY		; Flip OBJ, draw player behind BG
	ld   [sPlFlags], a
	ret
	
; =============== CourseClr_IntroMoveL0 ===============
; Mode $01: Player moves left, behind the BG.
CourseClr_IntroMoveL0:
	call NonGame_Wario_AnimWalkFast
	
	;
	; Move player horizontally
	;
	call CourseClr_GetPlWalkSpeed	; B = Walk speed
	ld   a, [sPlXRel]				; Move left by that
	sub  b
	ld   [sPlXRel], a
	
	;
	; Move up to X pos $28
	;
	cp   a, COURSECLR_XPOS_SIDEL	; X >= $28?
	ret  nc							; If so, we haven't got there yet 
	
.nextMode:
	; Otherewise, prepare for the next mode, when walking in front of the doors again.
	ld   a, [sPlYRel]				; Move down for perspective effect
	add  $08
	ld   [sPlYRel], a
	ld   a, [sCourseClrMode]		; Next mode
	inc  a
	ld   [sCourseClrMode], a
	ld   a, OBJLST_XFLIP			; Flip OBJ, draw in front of BG
	ld   [sPlFlags], a
	ret
; =============== CourseClr_GetPlWalkSpeed ===============
; This subroutine determines the player's walk speed in the Course Clear screen.
; More levels are cleared, the faster the player moves.
; OUT
; - B: Walk speed
CourseClr_GetPlWalkSpeed:
	ld   b, $01					; B = 1px/frame
	ld   a, [sLevelsCleared]	
	cp   a, $06					; Cleared less than 6 levels?
	ret  c						; If so, move at 1px/framr
	inc  b
	cp   a, $11					; Cleared < $11?
	ret  c						; If so, 2px/frame
	inc  b
	cp   a, $16					; Cleared < $16?
	ret  c						; If so, 3px/frame
	inc  b
	cp   a, $21					; Cleared < $21?
	ret  c						; If so, 4px/frame
	inc  b						; Otherwise, 5px/frame
	ret
	
; =============== CourseClr_IntroMoveR1 ===============
; Mode $02: Player moves right, until the first door.
CourseClr_IntroMoveR1:
	call NonGame_Wario_AnimWalkFast
	
	;
	; Move player horizontally
	;
	call CourseClr_GetPlWalkSpeed	; B = Walk speed
	ld   a, [sPlXRel]				; Move right by that
	add  b
	ld   [sPlXRel], a
	
	;
	; Move up to X pos $40
	;					
	cp   a, COURSECLR_XPOS_COIN		; X < $40?
	ret  c							; If so, we aren't over the first door yet
.nextMode:
	ld   a, [sCourseClrMode]		; Next mode
	inc  a
	ld   [sCourseClrMode], a
	; The nice part of forcing the player to be "Big Wario" when finishing a level
	; is that we don't have to deal with checking for Small Wario's separate frames.
	ld   a, OBJ_WARIO_IDLE0			; Set standing frame
	ld   [sPlLstId], a
	ret
	
; =============== CourseClr_CoinBonusPos ===============
; Mode $03: When standing over the Coin Bonus door.
CourseClr_CoinBonusPos:
	;
	; Determine if we have enough or too many coins to enter the door.
	;
	
	; If we have 0 coins, walk continuously to the right without stopping
	; since we can't enter any of the bonus games.
	ld   a, [sLevelCoins_Low]	; BC = Coin count
	ld   b, a
	ld   a, [sLevelCoins_High]
	or   a, b					; CoinCount == 0?
	jr   z, .walkRight			; If so, continue walking right
	
	;--
	; [TCRF] If we have 999 coins, autoskip this door.
	;        There's no way to trigger this legitimately, other than
	;        using the status bar editor.
	ld   a, [sLevelCoins_High]
	cp   a, $09					; High byte != 9?
	jr   nz, .doCtrl			; If so, it can't be 999 
	ld   a, b
	cp   a, $99					; Low byte == 99?
	jr   z, .walkRight			; If so, continue walking right
	;--
.doCtrl:
	;
	; Player controls
	;
	ldh  a, [hJoyNewKeys]
	bit  KEYB_RIGHT, a			; Pressing RIGHT?
	jr   nz, .walkRight			; If so, walk right
	bit  KEYB_UP, a				; Pressing UP?
	jr   nz, .enterDoor			; If so, try to enter the door
	ret
.enterDoor:
	;
	; Prepare for the coin bonus mode
	;
	ld   a, COURSECLR_RTN_COINBONUS
	ld   [sCourseClrMode], a
	xor  a
	ld   [sCourseClrBonusEnd], a	
	ld   [wCoinBonusMode], a		; COINBONUS_MODE_INIT
	ld   a, SES_BONUS				; Set VBLANK mode
	ld   [wStaticAnimMode], a
	ld   a, SFX1_07					; Play entry SFX
	ld   [sSFX1Set], a
	ret
.walkRight:
	; Walk right to the other door
	ld   a, COURSECLR_RTN_TOHEARTBONUS
	ld   [sCourseClrMode], a
	xor  a
	ld   [sPlAnimTimer], a
	ld   a, OBJ_WARIO_WALK0		; Set walk frame
	ld   [sPlLstId], a
	ld   a, OBJLST_XFLIP		; Face right
	ld   [sPlFlags], a
	ret
	
; =============== CourseClr_CoinBonus ===============
; Mode $06: The Coin Bonus code runs under this.
CourseClr_CoinBonus:
	; If the bonus has ended, switch to the treasure room
	ld   a, [sCourseClrBonusEnd]
	and  a							
	jp   nz, CourseClr_InitTrRoom
	
	; The VBlank code for doing tilemap updates in bonus games
	; requires "static screen mode" (where the screen can't scroll)
	
	ld   a, $01						; Set static screen mode for VBlank
	ld   [sStaticScreenMode], a
	call HomeCall_CoinBonus_Do		; Run coin bonus mode
	xor  a							; Force reset Y scroll
	ldh  [hScrollY], a
	ldh  [rSCY], a
	ret
	
; =============== CourseClr_MoveToHeartBonus ===============
; Mode $07: Player moves right, to the Heart Bonus door.
CourseClr_MoveToHeartBonus:
	call NonGame_Wario_AnimWalkFast
	
	;
	; Move player horizontally
	;
	call CourseClr_GetPlWalkSpeed	; B = Walk speed
	ld   a, [sPlXRel]				; Move right by that
	add  b
	ld   [sPlXRel], a
	
	cp   a, COURSECLR_XPOS_HEART	; X < $70?
	ret  c							; If so, we aren't there yet
	
.nextMode:
	ld   a, [sCourseClrMode]		; Next mode
	inc  a
	ld   [sCourseClrMode], a
	ld   a, OBJ_WARIO_IDLE0			; Set standing frame
	ld   [sPlLstId], a
	ret
	
; =============== CourseClr_HeartBonusPos ===============
; Mode $08: When standing over the Coin Bonus door.
CourseClr_HeartBonusPos:
	;
	; Determine if we have not enough coins to enter the door.
	;
	
	; With 0 coins, we continue walking directly right
	ld   a, [sLevelCoins_Low]	; BC = Coin count
	ld   b, a
	ld   a, [sLevelCoins_High]
	or   a, b					; CoinCount == 0?
	jr   z, .walkRight			; If so, walk to the right
	
.doCtrl:

	;
	; Player controls
	;
	ldh  a, [hJoyNewKeys]
	bit  KEYB_RIGHT, a			; Pressing RIGHT?
	jr   nz, .walkRight			; If so, walk right (to exit)
	bit  KEYB_LEFT, a			; Pressing LEFT?
	jr   nz, .tryWalkLeft		; If so, walk left (to coin bonus)
	bit  KEYB_UP, a				; Pressing UP?
	jr   nz, .tryEnterDoor		; If so, try to enter the door
	ret
	
.tryEnterDoor:
	; If we don't have enough coins to enter the door, play an error SFX
	; The min required amount is 20 coins.
	ld   a, [sLevelCoins_High]	
	and  a						; CoinCount > 100?
	jr   nz, .chkLives			; If so, we're fine
	ld   a, [sLevelCoins_Low]
	cp   a, $20					; CoinCount > 20?
	jr   nc, .chkLives			; If so, we're fine
	ld   a, SFX2_01				; Play no access SFX
	ld   [sSFX2Set], a
	ret
.chkLives:
	; If we're maxed out already, also don't allow entering the door
	ld   a, [sLives]
	cp   a, $99					; Lives != 99?
	jr   nz, .enterHeartBonus	; If so, we're fine
	ld   a, [sHearts]
	cp   a, $99					; Hearts != 99?
	jr   nz, .enterHeartBonus	; If so, we're fine
	; Otherwise, we have 99 lives and 99 hearts. Can't enter.
	ld   a, SFX2_01
	ld   [sSFX2Set], a
	ret
.enterHeartBonus:
	ld   a, COURSECLR_RTN_HEARTBONUS		; Set heart bonus
	ld   [sCourseClrMode], a
	xor  a									
	ld   [sCourseClrBonusEnd], a
	ld   [wHeartBonusMode], a				; Init mode
	ld   a, SES_BONUS						; Set VBLANK tile update mode
	ld   [wStaticAnimMode], a
	ld   a, SFX1_07							; Play entry SFX
	ld   [sSFX1Set], a
	ret
.walkRight:
	ld   a, COURSECLR_RTN_TOTRROOM			; Walk to the off-screen right
	ld   [sCourseClrMode], a
	xor  a
	ld   [sPlAnimTimer], a
	ld   a, OBJ_WARIO_WALK0
	ld   [sPlLstId], a
	ret
.tryWalkLeft:
	;--
	; [TCRF] If we have 999 coins, prevent moving to the coin door.
	;        There's no way to trigger this legitimately, other than
	;        using the status bar editor.
	ld   a, [sLevelCoins_High]
	cp   a, $09					; High byte != 9?
	jr   nz, .walkLeft			; If so, it can't be 999 
	ld   a, b
	cp   a, $99					; Low byte != 99?
	jr   nz, .walkLeft			; If so, continue walking right
	ld   a, SFX2_01
	ld   [sSFX2Set], a
	;--
	ret
.walkLeft:
	ld   a, COURSECLR_RTN_TOCOINBONUS
	ld   [sCourseClrMode], a
	xor  a
	ld   [sPlAnimTimer], a
	ld   a, OBJ_WARIO_WALK0		; Set walk frame
	ld   [sPlLstId], a
	ld   a, $00					; Face left
	ld   [sPlFlags], a
	ret
; =============== CourseClr_MoveToCoinBonus ===============
; Mode $0D: Player moves to the left, to the Coin Bonus door.
CourseClr_MoveToCoinBonus:
	call NonGame_Wario_AnimWalkFast
	
	;
	; Move player horizontally
	;
	call CourseClr_GetPlWalkSpeed	; B = Walk speed
	ld   a, [sPlXRel]				; Move left by that
	sub  b
	ld   [sPlXRel], a
	
	cp   a, COURSECLR_XPOS_COIN+1	; X >= $41?					
	ret  nc							; If so, we aren't done
.nextMode:
	ld   a, COURSECLR_RTN_COINBONUSPOS
	ld   [sCourseClrMode], a
	ld   a, OBJ_WARIO_IDLE0
	ld   [sPlLstId], a
	ret
	
; =============== CourseClr_HeartBonus ===============
; Mode $0B: The heart bonus game code runs under this.
CourseClr_HeartBonus:
	; If the bonus has ended, switch to the treasure room
	ld   a, [sCourseClrBonusEnd]
	and  a
	jr   nz, CourseClr_InitTrRoom
	ld   a, $01						; Set static screen mode for VBlank
	ld   [sStaticScreenMode], a
	call HomeCall_HeartBonus_Do		; Run heart bonus code
	ret
	
; =============== CourseClr_MoveToTrRoom ===============
; Mode $0C: Moves the player right, to off-screen.
;           After that, execution falls to the subroutine for loading the treasure room.
CourseClr_MoveToTrRoom:
	call NonGame_Wario_AnimWalkFast
	;
	; Walk horizontally
	;
	call CourseClr_GetPlWalkSpeed	; B = Walking speed
	ld   a, [sPlXRel]				; Move right by that
	add  b
	ld   [sPlXRel], a
	cp   a, COURSECLR_XPOS_EXIT		; X < $C0?
	ret  c							; If so, we're not off-screen yet
	
; =============== CourseClr_InitTrRoom ===============
; Execution jumps here after returning to the bonus room, to
; instantly switch to the treasure room (while still performing cleanup).
CourseClr_InitTrRoom:
	xor  a
	ld   [sCourseClrMode], a
	ld   [sCourseClrBonusEnd], a
	ld   [sStaticScreenMode], a
	
; =============== Mode_LevelClear_InitTrRoom ===============
; Initializes the treasure room.
Mode_LevelClear_InitTrRoom:
	call StopLCDOperation
	call ExActS_ClearRAM
	call HomeCall_LoadVRAM_TreasureRoom
	; Setup the 16x16 coin digit / block update functionality
	call TrRoom_CopyBlockData
	call TrRoom_InitDigitVRAMPtrs
	call TrRoom_DrawTreasures
	call TrRoom_ReqDrawTotalCoins
	
	;--
	; It's not needed to do this again. 
	; We already did this during init of the course clear screen.
	xor  a
	ldh  [hScrollY], a			; Reset the scroll coords, just in case
	ld   [sScrollX], a
	ldh  [rSCY], a
	ldh  [rSCX], a
	ld   hl, rIE				; Disable parallax, just in case
	res  IB_STAT, [hl]
	;--
	
	ld   a, $E1					; Set BG palette
	ldh  [rBGP], a
	ld   a, $1C					; Set OBJ palette
	ldh  [rOBP0], a
	ld   a, GM_LEVELCLEAR_TRWAIT	; Next mode
	ld   [sSubMode], a
	ld   a, LCDC_ENABLE|LCDC_OBJENABLE|LCDC_PRIORITY
	ldh  [rLCDC], a
	ret
	
; =============== Mode_LevelClear_TrRoomWait ===============
; Wario walks right from off-screen.
Mode_LevelClear_TrRoomWait:
	call .main
	call HomeCall_NonGame_WriteWarioOBJLst
	ret
.main:
	;
	; Walk right until we reach X pos $28.
	; This is to the left of the box with treasures.
	;
	call NonGame_Wario_AnimWalkFast			; Animate walk cycle
	ld   a, [sPlXRel]					; PlX++;
	inc  a
	ld   [sPlXRel], a
	cp   a, $28							; PlX != $28?
	ret  nz								; If so, we didn't get there yet
	
	; Otherwise, switch to the next mode and spawn extra actors.
.nextMode:
	ld   a, OBJ_WARIO_IDLE0
	ld   [sPlLstId], a
	xor  a
	ld   [sPlAnimTimer], a
	ld   a, GM_LEVELCLEAR_TRCOINCOUNT	; Next mode
	ld   [sSubMode], a
	ld   a, BGM_COINVAULT				; Play BGM
	ld   [sBGMSet], a
	
	; If we came here with no coins, use an alternate player frame
	; and skip the coin count.
	ld   a, [sLevelCoins_Low]
	ld   b, a
	ld   a, [sLevelCoins_High]
	or   a, b
	jr   z, Mode_LevelClear_TrRoomWait_NoMoney
	
	; Wait $A0-$02 frames before starting to count down the coins
	ld   a, $A0
	ld   [sTrRoomCoinDecDelay], a
	
; =============== ExActS_SpawnTrRoomArrow ===============
ExActS_SpawnTrRoomArrow:
	xor  a
	ld   [sExActTrRoomArrowDespawn], a
	ld   hl, sExActSet
	ld   a, EXACT_TRROOM_ARROW
	ldi  [hl], a			; ID
	xor  a
	ldi  [hl], a			; Y (not used)
	ldi  [hl], a
	ldi  [hl], a			; X (not used)
	ldi  [hl], a
	ld   a, OBJ_BLANK_36 	; Blank frame
	ldi  [hl], a
	xor  a
	ldi  [hl], a			; Flags
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ld   a, $38				; Y coord (rel)
	ldi  [hl], a
	ld   a, $68				; X coord (rel)
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	call ExActS_Spawn
	ret
	
; =============== Mode_LevelClear_TrRoomWait_NoMoney ===============
; Switches to the next mode with the player in the shrug frame.
Mode_LevelClear_TrRoomWait_NoMoney:
	ld   a, OBJ_TRROOM_WARIO_SHRUG
	ld   [sPlLstId], a
	jp   LevelClear_SwitchToTrRoomIdle2
	
; =============== TrRoom_CopyBlockData ===============
; This subroutine copies the 16x16 block data for the treasure room to RAM.
;
; This data includes the mappings for:
; - 16x16 large digits for the coin counter
; - Spinning coin frames
; - Treasures
;
; All of this does use the same the same block16 format of level blocks,
; so it also reuses the same subroutines for doing block updates.
; Those subroutines require the block16 data to be copied to sLevelBlocks,
; so we're doing just that now.
TrRoom_CopyBlockData:
	; Instead of filling the entire $0200 area reserved for level blocks,
	; here we have a proper separator.
	
	ld   hl, LevelBlock_TrRoom	; HL = Source
	ld   de, sLevelBlocks		; DE = Destination.
.loop:
	ldi  a, [hl]		; Read byte from source
	cp   a, $FF			; Is it the end separator?
	ret  z				; If so, return
	ld   [de], a		; Otherwise, copy it over
	inc  de
	jr   .loop
LevelBlock_TrRoom: INCBIN "data/block16/spec_trroom.bin"

; =============== TrRoom_InitDigitVRAMPtrs ===============
; Sets up the tilemap pointers to the top-left 8x8 tile of each
; digit in the total coin counter.
;
; These are copied directly to the area of SRAM containing a
; table of VRAM ptrs marking where the block IDs should be written
; by the block16 update subroutine.
;
; These addresses as a result are in big-endian format and have a $FF terminator.
;
; These pointers are meant to be 
TrRoom_InitDigitVRAMPtrs:
	ld   hl, TrRoom_Digit16VRAMPtrs		; HL = Source
	ld   de, sLvlScrollBGPtrWriteTable	; DE = Destination
	ld   b, (TrRoom_Digit16VRAMPtrs.end-TrRoom_Digit16VRAMPtrs) ; B = Bytes to copy
	call CopyBytes
	ret
TrRoom_Digit16VRAMPtrs:
	dwb vBGTrRoomTotalCoinsDigit0
	dwb vBGTrRoomTotalCoinsDigit1
	dwb vBGTrRoomTotalCoinsDigit2
	dwb vBGTrRoomTotalCoinsDigit3
	dwb vBGTrRoomTotalCoinsDigit4
	db $FF
.end:

; =============== Mode_LevelClear_TrRoomCoinCount ===============
; Gradually moves coins from the current level count to total count.
Mode_LevelClear_TrRoomCoinCount:
	call TrRoom_AnimCoin
	call HomeCall_ExActS_ExecuteAll
	call HomeCall_NonGame_WriteWarioOBJLst
	
	;
	; Wait for until the timer ticks down to $02 before counting down the coins.
	; This is also checked for in ExAct_TrRoom_Arrow.
	;
	; It's also used to have it count down coins every 2 frames, but this
	; doesn't affect ExAct_TrRoom_Arrow.
	;
	ld   a, [sTrRoomCoinDecDelay]	; Delay--
	dec  a
	ld   [sTrRoomCoinDecDelay], a	; Delay != 0?
	ret  nz							; If do, return
	ld   a, $02						; Wait $02 frames for next decrease
	ld   [sTrRoomCoinDecDelay], a
	
	;
	; Remove a coin from the level coin count, and add it to the total coin count.
	;
	ld   a, [sLevelCoins_Low]		; sLevelCoins--
	sub  a, $01
	daa
	ld   [sLevelCoins_Low], a
	ld   a, [sLevelCoins_High]
	sbc  a, $00
	daa
	ld   [sLevelCoins_High], a
	
	; If we had 0 coins and we underflowed, it means we have finished.
	jr   c, LevelClear_SwitchToTrRoomIdle					; sLevelCoins < 0? If so, jump
	
	; Otherwise, add that coin to the total coin count
	ld   a, [sTotalCoins_Low]		; sTotalCoins++
	add  $01
	daa
	ld   [sTotalCoins_Low], a
	ld   a, [sTotalCoins_Mid]
	adc  a, $00						; for carry
	daa
	ld   [sTotalCoins_Mid], a
	ld   a, [sTotalCoins_High]
	adc  a, $00						; for carry
	ld   [sTotalCoins_High], a
	
	;--
	; If we went past 99999 total coins, force it back
	cp   a, $0A				; CoinCount_High == 10?
	jr   nz, .playCoinSFX	; If not, skip
	; Otherwise, force it back
	ld   a, $99
	ld   [sTotalCoins_Low], a
	ld   [sTotalCoins_Mid], a
	ld   a, $09
	ld   [sTotalCoins_High], a
	;--
.playCoinSFX:
	ld   a, SFX2_02
	ld   [sSFX2Set], a
	
; =============== TrRoom_ReqDrawTotalCoins ===============
; Sets up a request to draw the total coin counter at next VBLANK, 
; through the standard (Level_Scroll_*) block16 update routines.
TrRoom_ReqDrawTotalCoins:

	;
	; We need to write block IDs for each of the 5 digits in the coin counter.
	; Thankfully, the block IDs $00-$09 are exactly for the 16x16 numbers
	; which simplifies things.
	;
	
	ld   hl, sLvlScrollBlockTable	; HL  = Start of block ID table
	
	; Write digit 0 (low nybble, high byte)
	ld   a, [sTotalCoins_High]		; Digit = sTotalCoins_High & $0F
	and  a, $0F
	ldi  [hl], a
	
	; Write digit 1 (high nybble, mid byte)
	ld   a, [sTotalCoins_Mid]		; Digit = sTotalCoins_Mid >> 4
	ld   b, a						; Save for later
	swap a
	and  a, $0F
	ldi  [hl], a
	
	; Write digit 2 (low nybble, mid byte)
	ld   a, b						; Digit = sTotalCoins_Mid & $0F
	and  a, $0F
	ldi  [hl], a
	
	; Write digit 3 (high nybble, low byte)
	ld   a, [sTotalCoins_Low]		; Digit = sTotalCoins_Low >> 4
	ld   b, a						; Save for later
	swap a
	and  a, $0F
	ldi  [hl], a
	
	; Write digit 4 (low nybble, low byte)
	ld   a, b						; Digit = sTotalCoins_Low & $0F
	and  a, $0F
	ldi  [hl], a
	
	; Add end separator
	ld   [hl], $FF
	
	; Generate the tile ID list for all the blocks we just set.
	call Level_Scroll_CreateTileIdList
	ret
	
; =============== LevelClear_SwitchToTrRoomIdle ===============
; Switches to the next mode after finishing to count down coins.
LevelClear_SwitchToTrRoomIdle:
	xor  a							; Reset coin count
	ld   [sLevelCoins_Low], a
	ld   [sLevelCoins_High], a
	ld   a, OBJ_TRROOM_WARIO_IDLE0	; Set standing frame
	ld   [sPlLstId], a
	ld   a, $01						; Signal out to despawn the flashing arrow
	ld   [sExActTrRoomArrowDespawn], a
	
; =============== LevelClear_SwitchToTrRoomIdle2 ===============
; Entrypoint when the player has no coins.
LevelClear_SwitchToTrRoomIdle2:
	ld   a, $80						; Display shrug anim for $80 frames
	ld   [sTrRoomCoinDecDelay], a
	ld   a, GM_LEVELCLEAR_TRIDLE
	ld   [sSubMode], a
	ret
	
; =============== TrRoom_AnimCoin ===============
; Animates the large 16x16 coin in the Treasure Room.
TrRoom_AnimCoin:
	; The block ID for the large coin as $0A + CoinFrameId.

	;
	; Animate coin every 8 frames...
	;
	ld   a, [sTimer]
	and  a, $07
	jr   nz, .noInc
	
	;
	; Increase the CoinFrameId offset.
	; If CoinFrameId goes past the limit, force it back to $00.
	;
	ld   b, $0A						; B = Base frame id
	ld   a, [sTrRoomCoinFrameId]	; A = CoinFrameId + 1
	inc  a
	cp   a, $04						; Reached the limit? (CoinFrameId == 4?)
	jr   nz, .setBlockId			; If not, skip
	xor  a							; Otherwise, reset
.setBlockId:
	ld   [sTrRoomCoinFrameId], a	; BlockID = $0A + sTrRoomCoinFrameId
	add  b
	ld   hl, vBGTrRoomTotalCoinIcon
	call Level_WriteBlockToBG
	ret
.noInc:
	ld   b, $0A
	ld   a, [sTrRoomCoinFrameId]
	jr   .setBlockId
	
; =============== Mode_LevelClear_TrRoomIdle ===============
; When the player is idle in the treasure room.
Mode_LevelClear_TrRoomIdle:
	call TrRoom_AnimCoin
	
	; If we press one of these keys, walk to the left and exit the treasure room
	ldh  a, [hJoyNewKeys]
	and  a, KEY_A|KEY_START|KEY_LEFT
	jr   nz, .nextMode
	
	;--
	; Handle the player animation.
	;
	; Until sPlDelayTimer elapses, we'll be in the gloat animation (unless we came in with no money).
	; After that, we switch to the main idle animation:
	; - Jump to .initIdleAnim the first time to setup the initial frame.
	;   This is required to make sure TrRoom_WarioBlink_OBJLstAnimOff is applied in the correct frame.
	; - Jump to .idleAnim from the next frame. This prevents the Gloat anim from occurring again.
	;
	
	; Check we
	ld   a, [sPlDelayTimer]
	and  a						; Timer == 0?
	jr   z, .idleAnim			; If so, we already ended it
	dec  a						; Timer--
	ld   [sPlDelayTimer], a			; Timer == 0?
	jr   z, .initIdleAnim		; If so, set the new idle anim
	
.gloatAnim:
	; Animate and write the player
	call TrRoom_AnimWarioGloat
	call HomeCall_NonGame_WriteWarioOBJLst
	ret
	
.initIdleAnim:
	ld   a, OBJ_TRROOM_WARIO_IDLE0			; Set base frame for TrRoom_WarioBlink_OBJLstAnimOff
	ld   [sPlLstId], a
	xor  a									; Clear
	ld   [sPlAnimTimer], a
	call HomeCall_NonGame_WriteWarioOBJLst
	ret
.idleAnim:
	call TrRoom_AnimWarioBlink				; Do idle animation
	call HomeCall_NonGame_WriteWarioOBJLst
	call TrRoom_ChkSpawnSparkle				; Animate sparkles as well
	call HomeCall_ExActS_ExecuteAll
	ret
	
.nextMode:
	; Mark the cleared level (if any) and update the savefile
	call Map_SetLevelCleared
	call Save_CopyAllToSave					
	
	ld   a, GM_LEVELCLEAR_TREXIT
	ld   [sSubMode], a
	ld   a, OBJ_WARIO_WALK0			; Prepare for walking-to-left anim
	ld   [sPlLstId], a
	xor  a
	ld   [sPlAnimTimer], a
	ld   [sPlFlags], a
	ld   a, BGMACT_FADEOUT
	ld   [sBGMActSet], a
	ret
	
; =============== Mode_LevelClear_TrRoomExit ===============
; Handles the player exiting the Treasure Room.
Mode_LevelClear_TrRoomExit:
	call TrRoom_AnimCoin
	call TrRoom_WalkToExit
	call HomeCall_NonGame_WriteWarioOBJLst
	ret
	
; =============== TrRoom_WalkToExit ===============
; Makes the player walk to the left, to off-screen.
TrRoom_WalkToExit:
	call NonGame_Wario_AnimWalkFast
	; Walk left until we're off-screen
	ld   a, [sPlXRel]	; PlX--
	dec  a
	ld   [sPlXRel], a
	cp   a, $08			; PlX == $08?
	ret  nz				; If not, return
.endMode:
	; In case the map screen code was executed before (ie: map cutscene), make sure to clear the return value
	xor  a						
	ld   [sMapRetVal], a
	; Switch to the level clear mode (which will take effect if we actually cleared a new level)
	ld   a, $01
	ld   [sMapLevelClear], a
	jp   Map_SwitchToMap
	
; =============== TrRoom_AnimWarioGloat ===============
; Handles Wario's "gloat" animation in the treasure room.
; (the animation between OBJ_TRROOM_WARIO_IDLE0 and OBJ_TRROOM_WARIO_IDLE1 is done elsewhere)
TrRoom_AnimWarioGloat:
	; Every 8 frames...
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	
	; If we're still shrugging (no level coins), continue staying in that frame
	ld   a, [sPlLstId]
	cp   a, OBJ_TRROOM_WARIO_SHRUG
	ret  z
	
	; Alternate between the previous and current animation.
	; This is *only* used to switch between OBJ_TRROOM_WARIO_GLOAT and OBJ_TRROOM_WARIO_IDLE0
	xor  $01
	ld   [sPlLstId], a
	ret
	
; =============== TrRoom_AnimWarioBlink ===============
; Handles Wario's blinking animation in the treasure room.
TrRoom_AnimWarioBlink:
	; [POI] It's not possible to reach this in the shrug animation.
	;       We always hit Mode_LevelClear_TrRoomIdle.initIdleAnim before getting here,
	;       which sets the correct animation for this subroutine.
	ld   a, [sPlLstId]
	cp   a, OBJ_TRROOM_WARIO_SHRUG	; Are we shrugging?
	ret  z							; If so, return (never)
	
	; Every 8 frames...
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	
	; 
	; Update the player's frame id.
	; This is specified in an animation table, where each
	; entry is an offset to the current animation frame.
	;
	ld   hl, TrRoom_WarioBlink_OBJLstAnimOff
	ld   a, [sPlAnimTimer]		; Index++
	inc  a
	cp   a, TrRoom_WarioBlink_OBJLstAnimOff.end-TrRoom_WarioBlink_OBJLstAnimOff	; Out of range?
	jr   nz, .getOff		; If not, jump
	xor  a					; Otherwise, reset index
.getOff:
	ld   [sPlAnimTimer], a		; Save updated index
	ld   e, a
	ld   d, $00				; DE = Index
	add  hl, de				; Offset it
	ld   a, [sPlLstId]		; sPlLstId += AnimTbl[DE]
	add  [hl]
	ld   [sPlLstId], a
	ret
	
TrRoom_WarioBlink_OBJLstAnimOff: 
	db +$00,+$00,+$00,+$00,+$00,+$00,+$00,+$00	; $00
	db +$00,+$00,+$00,+$00,+$00,+$00,+$00,+$00	; $08
	db +$01,-$01,+$01,-$01						; $10
.end:

; =============== Map_SetLevelCleared ===============
; Marks the current level exit as cleared in the map completion status.
Map_SetLevelCleared:
	; Indes the table by the level ID we're over.
	ld   hl, Map_LevelIdCompletionAssocTbl	; HL = Table of bit definitions
	ld   a, [sLevelId]	; DE = LevelId
	ld   e, a
	ld   d, $00
	add  hl, de			; Offset it
	ld   a, [hl]		; A = Map_LevelIdCompletionAssocTbl[sLevelId]
	
	cp   a, $FF			; A == $FF?
	ret  z				; If so, don't do anything
	
	ld   b, a			; Save for later
	
	; The high nybble marks the map we're setting its completion bit.
	and  a, $F0				; High nybble == 0?
	jr   z, .riceBeach		; If so, it's rice beach
	cp   a, $10				; ...
	jr   z, .mtTeapot
	cp   a, $20
	jr   z, .stoveCanyon
	cp   a, $30
	jr   z, .ssTeacup
	cp   a, $40
	jr   z, .parsleyWoods
	cp   a, $50
	jr   z, .sherbetLand
	cp   a, $60
	jr   z, .syrupCastle
	ret ; [POI] We never get here
.riceBeach:
	ld   hl, sMapRiceBeachCompletion
	call Map_SetLevelCompletionBitToMask
	ret
.mtTeapot:
	ld   hl, sMapMtTeapotCompletion
	call Map_SetLevelCompletionBitToMask
	ret
.stoveCanyon:
	ld   hl, sMapStoveCanyonCompletion
	call Map_SetLevelCompletionBitToMask
	ret
.ssTeacup:
	ld   hl, sMapSSTeacupCompletion
	call Map_SetLevelCompletionBitToMask
	ret
.parsleyWoods:
	ld   hl, sMapParsleyWoodsCompletion
	call Map_SetLevelCompletionBitToMask
	ret
.sherbetLand:
	ld   hl, sMapSherbetLandCompletion
	call Map_SetLevelCompletionBitToMask
	ret
.syrupCastle:
	ld   hl, sMapSyrupCastleCompletion
	call Map_SetLevelCompletionBitToMask
	ret
; =============== Map_SetLevelCompletionBitToMask ===============
; Marks as cleared the specified bit number in the specified map completion mask.
; This also increases the amount of levels cleared, if needed.
; IN
; - HL: Ptr to map completion status
; - B:  Base bit number to mark as completed.
Map_SetLevelCompletionBitToMask:
	; Depending on the bit we're set to mark...
	; [POI] The way the alternate exit is handled requires the bit for the alternate exit to come
	;       right after the bit for the normal level exit.
	;       Since the completion bit is indexed by level id, this is the easier way to do it.
	
	ld   a, [sAltLevelClear]
	add  b						; A = BitNum + sAltLevelClear
	and  a, $0F
	jr   z, .bit0
	dec  a
	jr   z, .bit1
	dec  a
	jr   z, .bit2
	dec  a
	jr   z, .bit3
	dec  a
	jr   z, .bit4
	dec  a
	jr   z, .bit5
	dec  a
	jr   z, .bit6
	dec  a
	jr   z, .bit7
	ret ; [POI] We never get here
.bit0:
	; All of these follow the same template
	bit  0, [hl]			; Is the level marked as cleared already?
	ret  nz					; If so, don't do anything
	set  0, [hl]			; Otherwise, mark as cleared
	jr   .incLvlClearCount	; And update the number of cleared levels
.bit1:;R
	bit  1, [hl]
	ret  nz
	set  1, [hl]
	jr   .incLvlClearCount
.bit2:;R
	bit  2, [hl]
	ret  nz
	set  2, [hl]
	jr   .incLvlClearCount
.bit3:;R
	bit  3, [hl]
	ret  nz
	set  3, [hl]
	jr   .incLvlClearCount
.bit4:;R
	bit  4, [hl]
	ret  nz
	set  4, [hl]
	jr   .incLvlClearCount
.bit5:;R
	bit  5, [hl]
	ret  nz
	set  5, [hl]
	jr   .incLvlClearCount
.bit6:;R
	bit  6, [hl]
	ret  nz
	set  6, [hl]
	jr   .incLvlClearCount
.bit7:;R
	bit  7, [hl]
	ret  nz
	set  7, [hl]
.incLvlClearCount:
	; Mark a level as cleared if we finished its primary exit
	ld   a, [sAltLevelClear]
	and  a						; Did we clear the alternate exit?
	ret  nz						; If so, return
	ld   a, [sLevelsCleared]	; Otherwise, sLevelsCleared++
	add  $01
	daa
	ld   [sLevelsCleared], a
	ret
	
; =============== SaveSel_CopyAllFromSave ===============
; This subroutine copies all data from the entered save file
; to other locations in memory.
SaveSel_CopyAllFromSave:
	call SaveSel_GetSaveDataPtr
	; Skip 4 byte signature
	inc  hl
	inc  hl
	inc  hl
	inc  hl
	; Copy the rest
	ldi  a, [hl]
	ld   [sLevelId], a
	ldi  a, [hl]
	ld   [sTotalCoins_High], a
	ldi  a, [hl]
	ld   [sTotalCoins_Mid], a
	ldi  a, [hl]
	ld   [sTotalCoins_Low], a
	ldi  a, [hl]
	ld   [sHearts], a
	ldi  a, [hl]
	ld   [sLives], a
	ldi  a, [hl]
	ld   [sPlPower], a
	ldi  a, [hl]
	ld   [sMapRiceBeachCompletion], a
	ldi  a, [hl]
	ld   [sMapMtTeapotCompletion], a
	ldi  a, [hl]
	ld   [sLevelsCleared], a
	ldi  a, [hl]
	ld   [sTreasures], a
	ldi  a, [hl]
	ld   [sTreasures+1], a
	ldi  a, [hl]
	ld   [sMapStoveCanyonCompletion], a
	ldi  a, [hl]
	ld   [sMapSSTeacupCompletion], a
	ldi  a, [hl]
	ld   [sMapParsleyWoodsCompletion], a
	ldi  a, [hl]
	ld   [sMapSherbetLandCompletion], a
	ldi  a, [hl]
	ld   [sMapSyrupCastleCompletion], a
	ldi  a, [hl]
	ld   [sCheckpoint], a
	ldi  a, [hl]
	ld   [sCheckpointLevelId], a
	ldi  a, [hl]
	ld   [sGameCompleted], a
	ret
	
; =============== SaveSel_UpdateChecksum ===============
; This subroutine generates a new checksum for the current save file,
; then replaces the old one.
;
; Use after updating the save file.
;
; IN
; - HL: Ptr to SaveFile
SaveSel_UpdateChecksum:
	call SaveSel_CreateChecksum	; B = Checksum
	; Which save are we updating?
	ld   a, [sLastSave]
	ld   e, a				; DE = sLastSave
	ld   d, $00
	ld   hl, sSave1Checksum	; HL = First checksum value
	add  hl, de				; Point to the correct checksum value
	ld   [hl], b			; THe set it
	ret
	
; =============== Mode_LevelDeadFadeout ===============
Mode_LevelDeadFadeout:
	ld   a, [sSubMode]
	rst  $28
	dw Level_FadeOutBGToWhite
	dw Mode_LevelDeadFadeout_InitNext
	
; =============== Level_FadeOutBGToWhite ===============
; Fades to white all sprites on-screen.
; See also: Level_FadeOutOBJ0ToBlack
Level_FadeOutBGToWhite:
	; Every 8 frames...
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	
	ld   b, $04			; B = Colors pairs left to update
	ldh  a, [rBGP]		; A = OBJ Palette
.loop:
	; Decrease the color entry down to COL_WHITE
	ld   d, a			; Save palette
	and  a, $03			; Filter out current color
	jr   z, .noLighten	; Is it white? If so, don't lighten it
	dec  a				; Lighten this color
.noLighten:
	ld   e, a			; E = New color pair
	ld   a, d			; Restore palette
	;--
	
	; Replace the last color entry
	and  a, $FC			; Remove old bits 0 & 1
	add  e			; Set new bits 0 & 1
	; Rotate >> 2 to the next color entry
	rrca
	rrca
	dec  b				; Have we updated all colors yet?
	jr   nz, .loop		; If not, loop
	
	ldh  [rBGP], a		; Save new palette
	ldh  [rOBP1], a		
	and  a				; Are all colors white?
	ret  nz				; If not, we aren't done yet
.nextSubmode:
	ld   a, [sSubMode]	; Otherwise, switch to the next submode
	inc  a
	ld   [sSubMode], a
	ret
	
; =============== Mode_LevelDeadFadeout_InitNext ===============
Mode_LevelDeadFadeout_InitNext:
	ld   hl, rIE			; Disable parallax
	res  IB_STAT, [hl]
	
	ld   a, [sTimer]		; Frame rule for some reason
	and  a, $1F
	ret  nz
	
	ld   [sSmallWario], a	; Force the player back to Big Wario
	ld   a, PL_POW_GARLIC
	ld   [sPlPower], a
	
	ld   a, [sTimeUp]
	and  a					; Did we die by time over?
	jr   nz, Mode_LevelDeadFadeout_InitTimeUp	; If so, show the Time Up screen
	ld   a, [sGameOver]
	and  a					; Did we game over?
	jr   nz, Mode_LevelDeadFadeout_InitGameOver	; If so, show that screen
	
	; Otherwise, just save the game
	call Save_CopyAllToSave
	; And return to the map screen
	
; =============== Map_SwitchToMap ===============
; Performs first initialization of the map screen.
Map_SwitchToMap:
	; Switch tomap screen
	xor  a
	ld   [sSubMode], a
	ld   a, GM_MAP
	ld   [sGameMode], a
	; Clear the return value so we actually stay in the map mode
	xor  a
	ld   [sMapRetVal], a
	
	ld   hl, rIE
	res  1, [hl]
	call Map_ClearRAMInit
	; If the game completed at least once, show the blinking dots over the
	; levels with uncollected treasures
	ld   a, [sGameCompleted]
	and  a
	ret  z
	call Map_BlinkLevel_Init
	ret
; =============== Mode_LevelDeadFadeout_InitTimeUp ===============
Mode_LevelDeadFadeout_InitTimeUp:
	call Save_CopyAllToSave
	xor  a
	ld   [sSubMode], a
	ld   a, GM_TIMEUP
	ld   [sGameMode], a
	ret
	
; =============== Mode_LevelDeadFadeout_InitGameOver ===============
Mode_LevelDeadFadeout_InitGameOver:
	; Will autosave after the game over ends
	xor  a
	ld   [sSubMode], a
	ld   a, GM_GAMEOVER
	ld   [sGameMode], a
	ret
	
; =============== Mode_LevelClearSpec ===============
; Special level exit.
; These are the kinds of exits that cause a special map cutscene to trigger.
Mode_LevelClearSpec:
	ld   a, [sSubMode]
	rst  $28
	dw Mode_LevelClear_Fanfare
	dw Level_FadeOutOBJ0ToBlack
	dw Level_FadeOutBGToWhite
	dw Mode_LevelClearSpec_Map
	
; =============== Mode_LevelClearSpec_Map ===============
; Displays the map screen cutscene.
Mode_LevelClearSpec_Map:
	ld   a, $01						; Run VBLANK code for the map screen
	ld   [sMapVBlankMode], a
	; NOTE: If the level is already cleared, it will return immediately after executing for 1 frame.
	ld   a, [sMapRetVal]
	and  a							; Is the cutscene over?
	jr   nz, .toCourseClr			; If so, jump
	call HomeCall_Map_CheckMapId	; Otherwise, execute the map screen code
	ret
.toCourseClr:
	; Switch to the course clear screen
	xor  a
	ld   [sMapVBlankMode], a
	ld   [sPlDragonHatActive], a
	ld   [sCheckpoint], a
	ld   [sHurryUp], a
	ld   [sExActCount], a
	ld   a, GM_LEVELCLEAR_CLEARINIT		; Course clear init code
	ld   [sSubMode], a
	ld   a, GM_LEVELCLEAR				; back to standard level clear mode
	ld   [sGameMode], a
	ret
	
; =============== Mode_TimeUp ===============
Mode_TimeUp:
	ld   a, [sSubMode]
	rst  $28
	dw Mode_TimeUp_Init
	dw Mode_TimeUp_MoveHandDown
	dw Mode_TimeUp_MoveHandUp
	dw Mode_TimeUp_Wait
	dw Level_FadeOutBGToWhite
	dw Mode_TimeUp_Exit
	
; =============== Mode_TimeUp_Init ===============
Mode_TimeUp_Init:
	call StopLCDOperation
	call ClearWorkOAM
	call HomeCall_LoadVRAM_TimeOver
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_ENABLE	; Disable WINDOW
	ldh  [rLCDC], a
	xor  a
	ldh  [hScrollY], a		; Reset scroll coord
	ld   [sScrollX], a
	
	ld   hl, rIE			; Disable parallax
	res  IB_STAT, [hl]
	ld   a, $E1				; Set BG palette
	ldh  [rBGP], a
	ld   a, BGM_TIMEOVER
	ld   [sBGMSet], a
	ld   a, GM_TIMEUP_MOVEDOWN	; Next mode
	ld   [sSubMode], a
	ret
	
; =============== Mode_TimeUp_MoveHandDown ===============
; Moves the hand down until its finger goes off-screen.
Mode_TimeUp_MoveHandDown:

	; The way the screen is setup is like this:
	; - Hand with the TIME UP text on the main layer
	; - Wario in the WINDOW layer
	;
	; Moving the main viewport up makes the hand move down.
	
	
	ldh  a, [hScrollY]	; Move down 1px
	dec  a
	ldh  [hScrollY], a
	cp   a, $C8			; Y == $C8? (enough to make the index go off-screen)
	ret  nz				; If not, return
	
.nextMode:

	; Once we get here, enable the WINDOW layer, which makes Wario show up.
	; This would look off if it were done on-screen, which is why we've moved the hand down.
	ld   a, $A0			; Start off-screen
	ldh  [rWY], a
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	ldh  [rLCDC], a
	ld   a, [sSubMode]	; Next mode
	inc  a
	ld   [sSubMode], a
	
	;
	; Update the tilemap to make it look like the hand holds Wario.
	; This would also look off it weren't done off-screen.
	;
	
	; This is done as an inline block update request
	; Define the tilemap ptrs for the blocks top-left corner...
	ld   hl, sLvlScrollBGPtrWriteTable
	ld   a, HIGH(vBGTimeUpHandFingerBlock0)	; Block 1
	ldi  [hl], a
	ld   a, LOW(vBGTimeUpHandFingerBlock0)
	ldi  [hl], a
	ld   a, HIGH(vBGTimeUpHandFingerBlock1)	; Block 2
	ldi  [hl], a
	ld   a, LOW(vBGTimeUpHandFingerBlock1)
	ldi  [hl], a
	ld   a, $FF			; Separator
	ld   [hl], a
	; And the tile IDs associated with the blocks
	ld   hl, sLvlScrollTileIdWriteTable
	; Block 1
	ld   a, $EC		; UL
	ldi  [hl], a
	ld   a, $ED		; UR
	ldi  [hl], a
	ld   a, $FC		; DL
	ldi  [hl], a
	ld   a, $FD		; DR
	ldi  [hl], a
	; Block 2
	ld   a, $EE		; UL
	ldi  [hl], a
	ld   a, $EF		; UR
	ldi  [hl], a
	ld   a, $FE		; DL
	ldi  [hl], a
	ld   a, $FF		; DR
	ld   [hl], a
	
	; Force VBlank handler to update the blocks
	ld   a, SCRUPD_SCROLL
	ld   [sScreenUpdateMode], a
	ret
	
; =============== Mode_TimeUp_MoveHandUp ===============
; Moves the hand up with Wario hanging until it returns to the target position.
Mode_TimeUp_MoveHandUp:
	; Move viewport down for both Hand and Wario
	ldh  a, [rWY]		; Move Wario up
	dec  a
	ldh  [rWY], a
	ldh  a, [hScrollY]	; Move hand up
	inc  a
	ldh  [hScrollY], a
	cp   a, $20			; HandY == $20?
	ret  nz				; If not, we didn't reach the target yet
.nextMode:
	ld   a, [sSubMode]	; Next mode
	inc  a
	ld   [sSubMode], a
	ld   a, $80			; Wait $80 frames before ending
	ld   [sTimeUpWaitTimer], a
	ret
	
; =============== Mode_TimeUp_Wait ===============
; Waits for $80 frames before fading out.
Mode_TimeUp_Wait:
	ld   a, [sTimeUpWaitTimer]			; Timer--
	dec  a
	ld   [sTimeUpWaitTimer], a
	; After $20 frames, update Wario's expression
	cp   a, $60							; Timer == $60?		
	jr   z, TimeUp_UpdateWarioTilemap	; If so, jump
	and  a								; Timer == $00?
	ret  nz								; If not, return
.nextMode:								; Otherwise, we're done
	ld   a, [sSubMode]
	inc  a
	ld   [sSubMode], a
	ret
	
; =============== Mode_TimeUp_Exit ===============
Mode_TimeUp_Exit:
	; If we also game overed, show that screen next
	ld   a, [sGameOver]
	and  a
	jp   nz, Mode_LevelDeadFadeout_InitGameOver
	; Otherwise go back to the map screen
	jp   Map_SwitchToMap
	
; =============== TimeUp_UpdateWarioTilemap ===============
; Performs an inline tilemap update request to change Wario's expression.
TimeUp_UpdateWarioTilemap:
	; Set tilemap block pointers
	ld   hl, sLvlScrollBGPtrWriteTable
	ld   a, HIGH(vBGTimeUpWarioBlock0)	; Block 0
	ldi  [hl], a
	ld   a, LOW(vBGTimeUpWarioBlock0)
	ldi  [hl], a
	ld   a, HIGH(vBGTimeUpWarioBlock1)	; Block 1
	ldi  [hl], a
	ld   a, LOW(vBGTimeUpWarioBlock1)
	ldi  [hl], a
	ld   a, $FF								; Separator
	ld   [hl], a
	; And their tile IDs
	ld   hl, sLvlScrollTileIdWriteTable
	; Block 0
	ld   a, $96		; UL
	ldi  [hl], a
	ld   a, $97		; UR
	ldi  [hl], a
	ld   a, $A6		; DL
	ldi  [hl], a
	ld   a, $A7		; DR
	ldi  [hl], a
	; Block 1
	ld   a, $98		; UL
	ldi  [hl], a
	ld   a, $B6		; UR
	ldi  [hl], a
	ld   a, $A8		; DL
	ldi  [hl], a
	ld   a, $C6		; DR
	ld   [hl], a
	
	; Force VBlank handler to update the blocks
	ld   a, SCRUPD_SCROLL
	ld   [sScreenUpdateMode], a
	ret
	
; =============== Mode_GameOver ===============
Mode_GameOver:
	ld   a, [sSubMode]
	rst  $28
	dw Mode_GameOver_Init
	dw Mode_GameOver_Main
	dw Mode_GameOver_InitTrRoom
	dw Mode_GameOver_TrRoom
	
; =============== Mode_GameOver_Init ===============
Mode_GameOver_Init:
	call StopLCDOperation
	call ClearWorkOAM
	call ExActS_ClearRAM
	call HomeCall_LoadVRAM_GameOver
	ld   hl, rIE				; Disable parallax
	res  IB_STAT, [hl]
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_ENABLE	; Disable WINDOW
	ldh  [rLCDC], a
	ld   a, GM_GAMEOVER_MAIN	; Next mode
	ld   [sSubMode], a
	xor  a
	ld   [sHurryUp], a			; No hurry up music
	ldh  [hScrollY], a			; Reset scroll
	ld   [sScrollX], a
	ld   a, $E1					; Set BG palette
	ldh  [rBGP], a
	ld   a, $C0					; Wait $C0 frames before going to the treasure room
	ld   [sGameOverWaitTimer], a
	ld   a, BGM_GAMEOVER		; Play BGM
	ld   [sBGMSet], a
	ret
	
; =============== Mode_GameOver_Main ===============
; See also: Mode_TimeUp_Wait
Mode_GameOver_Main:
	ld   a, [sGameOverWaitTimer]	; Timer--
	dec  a
	ld   [sGameOverWaitTimer], a
	; Wait for ($C0-$80) frames before updating Wario's tilemap
	cp   a, $80								; Timer == $80?
	jr   z, GameOver_UpdateWarioTilemap		; If so, jump
	and  a									; Timer == 0?
	ret  nz									; If not, return
.nextMode:
	ld   a, [sSubMode]
	inc  a
	ld   [sSubMode], a
	ret
	
; =============== GameOver_UpdateWarioTilemap ===============
; Performs an inline tilemap update request to change Wario's frame.
GameOver_UpdateWarioTilemap:
	; Set tilemap block pointers
	ld   hl, sLvlScrollBGPtrWriteTable
	ld   a, HIGH(vBGGameOverWarioBlock0)	; Block 0
	ldi  [hl], a
	ld   a, LOW(vBGGameOverWarioBlock0)
	ldi  [hl], a
	ld   a, HIGH(vBGGameOverWarioBlock1)	; Block 1
	ldi  [hl], a
	ld   a, LOW(vBGGameOverWarioBlock1)
	ldi  [hl], a
	ld   a, $FF								; Separator
	ld   [hl], a
	; And their tile IDs
	ld   hl, sLvlScrollTileIdWriteTable
	; Block 0
	ld   a, $55		; UL
	ldi  [hl], a
	ld   a, $56		; UR
	ldi  [hl], a
	ld   a, $65		; DL
	ldi  [hl], a
	ld   a, $66		; DR
	ldi  [hl], a
	; Block 1
	ld   a, $57		; UL
	ldi  [hl], a
	ld   a, $58		; UR
	ldi  [hl], a
	ld   a, $67		; DL
	ldi  [hl], a
	ld   a, $68		; DR
	ld   [hl], a
	
	; Force VBlank handler to update the blocks
	ld   a, SCRUPD_SCROLL
	ld   [sScreenUpdateMode], a
	ret
	
; =============== Mode_GameOver_InitTrRoom ===============
; Loads the treasure room screen where treasures/coins are taken away.
Mode_GameOver_InitTrRoom:
	call StopLCDOperation
	call ClearWorkOAM
	call HomeCall_LoadVRAM_TreasureRoom
	call TrRoom_CopyBlockData
	call TrRoom_InitDigitVRAMPtrs
	call TrRoom_DrawTreasures
	call TrRoom_ReqDrawTotalCoins
	xor  a					; Clear scroll coords
	ldh  [hScrollY], a
	ld   [sScrollX], a
	ldh  [rSCY], a
	ldh  [rSCX], a
	ld   hl, rIE			; Disable parallax
	res  IB_STAT, [hl]
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_ENABLE
	ldh  [rLCDC], a
	ld   a, $E1				; Set BG palette
	ldh  [rBGP], a
	ldh  [rOBP1], a
	ld   a, $1C				; Set OBJ palette
	ldh  [rOBP0], a
	ld   a, [sSubMode]		; Next mode
	inc  a
	ld   [sSubMode], a
	xor  a					; Set initial submode
	ld   [sGameOverTrRoomMode], a
	ret
	
; =============== Mode_GameOver_TrRoom ===============
Mode_GameOver_TrRoom:
	call .main
	call HomeCall_NonGame_WriteWarioOBJLst
	call HomeCall_ExActS_ExecuteAll
	ret
.main:
	ld   a, [sGameOverTrRoomMode]
	rst  $28
	dw Mode_GameOver_TrRoomWait
	dw Mode_GameOver_TrRoomLoseTreasure
	dw Mode_GameOver_TrRoomWaitTreasure
	dw Mode_GameOver_TrRoomLoseMoney
	dw Mode_GameOver_TrRoomExit
	
; =============== Mode_GameOver_TrRoomWait ===============
; Wario walks right from off-screen.
; See also: Mode_LevelClear_TrRoomWait.
Mode_GameOver_TrRoomWait:

	;
	; Walk right until we reach X pos $28.
	; This is to the left of the box with treasures.
	;
	call NonGame_Wario_AnimWalk		; Animate walk cycle
	ld   a, [sPlXRel]				; PlX++;
	inc  a
	ld   [sPlXRel], a
	cp   a, $28						; PlX != $28?
	ret  nz							; If so, we didn't get there yet
	
	; Otherwise, once we got there, switch to the next mode and decide what to take away.
.nextMode:
	ld   a, OBJ_TRROOM_WARIO_SHRUG
	ld   [sPlLstId], a
	xor  a
	ld   [sPlAnimTimer], a
	ld   a, BGM_GAMEOVER2			; Set
	ld   [sBGMSet], a
	
	ld   a, [sGameOverTrRoomMode]	; Next submode (GOTR_RTN_LOSETREASURE)
	inc  a
	ld   [sGameOverTrRoomMode], a
	
	ld   a, $30						; Set wait for GOTR_RTN_LOSETREASURE
	ld   [sGameOverWaitTimer], a
	
	;
	; If we have any treasures, take away one of it.
	; Otherwise, take away half of the total money instead.
	;
	; There's also a detail about the delay before treasures/money are taken out.
	; When taking away treasures, there's an animation of them flying away that takes time.
	; Likely to avoid having the screen stay for too much time, the delay before starting
	; this animation is set to $30.
	; Meanwhile, taking away half of the coins is instant, and plays after $80 frames.
	; This is long enough to not play over BGM_GAMEOVER2 (which is the case when the timer is set to $30).
	;
	ld   a, [sTreasures]
	ld   b, a
	ld   a, [sTreasures+1]
	or   a, b				; sTreasures == 0?
	jr   z, .loseMoney		; If so, take away money instead
.loseTreasure:
	xor  a					; Init for later
	ld   [sTreasureId], a
	ret
.loseMoney:
	ld   a, GOTR_RTN_LOSEMONEY		; Different submode
	ld   [sGameOverTrRoomMode], a
	ld   a, $80						; Wait $80 frames for GOTR_RTN_LOSEMONEY
	ld   [sGameOverWaitTimer], a
	ret
	
; =============== Mode_GameOver_TrRoomLoseTreasure ===============
; A treasure is removed from the player.
Mode_GameOver_TrRoomLoseTreasure:
	; Wait $30 frames before continuing
	ld   a, [sGameOverWaitTimer]
	dec  a
	ld   [sGameOverWaitTimer], a
	ret  nz
	
	; Remove the first treasure by ID that is marked as collected.
	; The one with ID $01 is TREASURE_C, for reference.
.loop:
	ld   a, [sTreasureId]					; Treasure++
	inc  a
	ld   [sTreasureId], a					
	call Map_IsTreasureCollected			; Is that collected?
	jr   z, .loop							; If not, loop
	
.trFound:
	; Make the treasure fly away
	call Treasure_MarkAsUncollected
	ld   b, EXACT_TREASURELOST
	call ExActS_SpawnTreasure
	ld   a, SFX1_25							; Play SFX
	ld   [sSFX1Set], a
	ld   a, SFX2_02
	ld   [sSFX2Set], a
	ld   a, [sGameOverTrRoomMode]			; Next mode
	inc  a
	ld   [sGameOverTrRoomMode], a
	
	xor  a									; Init var
	ld   [sExActTrRoomTreasureDespawn], a
	ret
	
; =============== Mode_GameOver_TrRoomWaitTreasure ===============
; Waits for the treasure to fully fly up before continuing.
Mode_GameOver_TrRoomWaitTreasure:
	; Waiting for the actor to signal us it's despawned before exiting the treasure room
	ld   a, [sExActTrRoomTreasureDespawn]
	and  a							; Despawned yet? (A == 0?)
	ret  z							; If not, return
.nextMode:
	xor  a
	ld   [sExActTrRoomTreasureDespawn], a
	ld   a, $80						; Wait another $80 frames
	ld   [sGameOverWaitTimer], a
	ld   a, GOTR_RTN_EXIT
	ld   [sGameOverTrRoomMode], a
	ret
	
; =============== Mode_GameOver_TrRoomLoseMoney ===============
; Half of the coins are removed from the player count.
Mode_GameOver_TrRoomLoseMoney:
	; Wait $80 frames
	ld   a, [sGameOverWaitTimer]
	dec  a
	ld   [sGameOverWaitTimer], a
	ret  nz
	
.delCoins:
	;
	; Set half of the coin count, rounding down the value.
	; sTotalCoins = sTotalCoins / 2
	;
	
	;
	; First of all, split the five digits of the BCD number in separate memory addresses.
	; This simplifies handling the division.
	;
	;####
	
	; Digit0 = sTotalCoins_High, (low nybble)
	ld   a, [sTotalCoins_High]		
	ld   [sGameOverCoinDigit0], a	
	
	; Digit1 = sTotalCoins_Mid, high nybble
	ld   a, [sTotalCoins_Mid]
	ld   c, a						
	swap a
	and  a, $0F
	ld   [sGameOverCoinDigit1], a
	; Digit2 = sTotalCoins_Mid, low nybble
	ld   a, c
	and  a, $0F
	ld   [sGameOverCoinDigit2], a
	
	; Digit3 = sTotalCoins_Low, high nybble
	ld   a, [sTotalCoins_Low]
	ld   c, a
	swap a
	and  a, $0F
	ld   [sGameOverCoinDigit3], a
	; Digit4 = sTotalCoins_Low, low nybble
	ld   a, c
	and  a, $0F
	ld   [sGameOverCoinDigit4], a
	
	;
	; Divide all five digits by 2, adding the remainder to the lower digits.
	;
	
	; Digit0 = Digit0 / 2
.div0:
	ld   a, [sGameOverCoinDigit0]	; B = Digit0 / 2
	ld   b, a
	srl  b
	; If we have a remainder, add 10 to the "tens" digit.
	; This won't be a problem when re-merging the digits, since the highest
	; value it can possibly get to is 19, which divided by 2 doesn't fill the upper nybble.
	jr   nc, .save0					; Is there a remainder? If not, skip this.
	ld   a, [sGameOverCoinDigit1]	; Digit1 += 10
	add  $0A
	ld   [sGameOverCoinDigit1], a
.save0:
	ld   a, b						; Save updated low nybble
	ld   [sTotalCoins_High], a
	
	; Digit1 = Digit1 / 2
.div1:
	ld   a, [sGameOverCoinDigit1]	; B = Digit1 / 2
	ld   b, a
	srl  b
	jr   nc, .save1
	ld   a, [sGameOverCoinDigit2]
	add  $0A
	ld   [sGameOverCoinDigit2], a
.save1:
	; Save high nybble
	ld   a, b						; sTotalCoins_Mid = B << 4
	swap a
	ld   [sTotalCoins_Mid], a		
	
	; Digit2 = Digit2 / 2
.div2:
	ld   a, [sGameOverCoinDigit2]	; B = Digit2 / 2
	ld   b, a
	srl  b
	jr   nc, .save2
	ld   a, [sGameOverCoinDigit3]
	add  $0A
	ld   [sGameOverCoinDigit3], a
.save2:
	; Add low nybble to previously set high nybble
	ld   a, [sTotalCoins_Mid]		; sTotalCoins_Mid |= B
	add  b
	ld   [sTotalCoins_Mid], a
	
	; Digit3 = Digit3 / 2
.div3:
	ld   a, [sGameOverCoinDigit3]
	ld   b, a
	srl  b
	jr   nc, .save3
	ld   a, [sGameOverCoinDigit4]
	add  $0A
	ld   [sGameOverCoinDigit4], a
.save3:
	ld   a, b
	swap a
	ld   [sTotalCoins_Low], a
	
	; Digit4 = Digit4 / 2
.div4:
	ld   a, [sGameOverCoinDigit4]	
	ld   b, a
	srl  b
	ld   a, [sTotalCoins_Low]
	add  b
	ld   [sTotalCoins_Low], a
	
.nextMode:
	call TrRoom_ReqDrawTotalCoins	; Update total coin counter next VBLANK
	ld   a, $80						; Wait $80 frames in Mode_GameOver_TrRoomExit
	ld   [sGameOverWaitTimer], a
	ld   a, SFX1_25
	ld   [sSFX1Set], a
	ld   a, SFX2_02
	ld   [sSFX2Set], a
	ld   a, GOTR_RTN_EXIT			; Next submode
	ld   [sGameOverTrRoomMode], a
	ret
	
; =============== Mode_GameOver_TrRoomExit ===============
Mode_GameOver_TrRoomExit:
	; Wait $80 frames before walking back
	ld   a, [sGameOverWaitTimer]
	and  a							; Timer == 0?
	jr   z, .walkToExit				; If so, walk left
	dec  a							; Timer--
	ld   [sGameOverWaitTimer], a	; Timer == 0?
	ret  nz							; If not, return
.startWalk:
	; Otherwise, prepare the walk anim
	xor  a
	ld   [sPlAnimTimer], a
	ld   [sPlFlags], a
	ld   a, OBJ_WARIO_WALK0
	ld   [sPlLstId], a
	ld   a, $02						; [POI] What's the point
	ld   [sExActTrRoomTreasureDespawn], a
	ret
	
.walkToExit:
	; Walk left until we're off-screen
	call NonGame_Wario_AnimWalkFast
	ld   a, [sPlXRel]		; PlX--
	dec  a
	ld   [sPlXRel], a
	cp   a, $08				; Off-screen left? (PlX == $08?)
	ret  nz					; If not, return
.reset:
	ld   a, $05				; Reset the default number of lives
	ld   [sLives], a
	call Save_CopyAllToSave	; Save game data
	jp   GameInit			; Reset
	
; =============== Mode_Ending ===============
; Handles the entire ending scene, both in the level and the map screen.
Mode_Ending:
	ld   a, [sSubMode]
	rst  $28
	dw Mode_Ending_MovePlDown
	dw Mode_Ending_HatSwitch
	dw Mode_Ending_WalkToLamp
	dw Mode_Ending_WalkToReload
	dw Mode_Ending_WaitReload
	dw Level_FadeOutOBJ0ToBlack_NoOBJDraw
	dw Level_FadeOutBGToWhite
	dw Mode_LevelDoor_LoadRoom
	dw Level_FadeInBG
	dw Level_FadeInOBJ
	dw Mode_Ending_LevelCutscene
	dw Mode_Ending_MapCutscene
	dw Mode_Ending_GenieCutscene
	dw Mode_Ending_InitTrRoom;X ; [TCRF] Mode not used directly
	dw Mode_Ending_TrRoom
	dw Mode_Ending_GenieCutscene2
	
; =============== Mode_Ending_MovePlDown ===============
; The player jumps down to the ground and triggers the hat switch.
Mode_Ending_MovePlDown:

	; Draw Wario & process/draw actors
	call HomeCall_NonGame_WriteWarioOBJLst
	call HomeCall_ActS_Do
	
	;--
	; When we first get here, the player has defeated the boss
	; and may possibly be in the air.
	;
	; Before attempting to move the player horizontally to grab the lamp,
	; make sure we're on solid ground.
	
	
	; Move player down until it reaches the solid ground.
	ld   a, [sPlYRel]
	cp   a, $90			; PlayerY >= $90?
	jr   nc, .nextMode	; If so, jump
.fallDown:
	; Otherwise, move down 2px/frame
	add  $02			
	ld   [sPlYRel], a
	ld   b, $02
	call Pl_MoveDown
	ret
.nextMode:
	ld   a, SFX1_06					; Play transform SFX
	ld   [sSFX1Set], a
	xor  a
	ld   [sPlHatSwitchDrawMode], a
	ld   [sPlAnimTimer], a	
	
	;
	; Switch to the standing frame as soon as we hit the ground.
	;
	; If we're triggering the hat switch (see below) this will take effect for a single frame,
	; but it's the same frame used as part of the hat switch, it won't matter.
	
	ld   a, OBJ_WARIO_IDLE0			; Set initial frame
	ld   [sPlLstId], a
	ld   a, [sSubMode]				; Next submode
	inc  a
	ld   [sSubMode], a
	
	; If we have anything but the Normal Hat, do a hat switch to that.
	ld   a, [sPlPower]
	cp   a, PL_POW_GARLIC			; Are we Normal Wario already?
	jr   z, Ending_Give300Coins		; If so, skip
	
	ld   a, $10						; Switch for $10 frames
	ld   [sPlHatSwitchTimer], a
	ld   a, PL_POW_GARLIC			; Set target powerup
	ld   [sPlPowerSet], a
	; Set the two powerup statues to alternate during the animation
	ld   a, [sPlPowerSet]			; B = Target powerup
	ld   b, a
	ld   a, [sPlPower]				; A = Current powerup
	ld   [sPlPower_Unused_Copy], a
	swap a							; Current/Old powerup in high nybble
	add  b							; New powerup in low nybble
	ld   [sPlPower], a				; Save it
	ret
	
; =============== Mode_Ending_HatSwitch ===============
; Waits for the hat switch to finish, before increasing the coin count.
Mode_Ending_HatSwitch:
	; Draw player & actors
	call HomeCall_NonGame_WriteWarioOBJLst
	call HomeCall_ActS_Do
	
	; Wait until the hat switch anim is over
	call Game_DoHatSwitchAnim
	ld   a, [sPlHatSwitchTimer]
	and  a
	ret  nz
	
	; [BUG] The hat switch leaves us in the wrong animation frame.
	;       It should be set to OBJ_WARIO_IDLE0 now.
	IF FIX_BUGS == 1
		ld   a, OBJ_WARIO_IDLE0
		ld   [sPlLstId], a
	ENDC
	
; =============== Ending_Give300Coins ===============
; Gives out a bonus of 300 coins for defeating the final boss.
Ending_Give300Coins:
	ld   a, GM_ENDING_WALKTOLAMP	; Next submode
	ld   [sSubMode], a
	ld   a, $60						; Wait $60 frames before walking
	ld   [sEndingWaitTimer], a
	
	; sLevelCoins += 300
	ld   a, [sLevelCoins_High]		; sLevelCoins_High += 3
	add  $03
	ld   [sLevelCoins_High], a
	
	; If that made our coin count go > 999, fix it back to 999
	; [TCRF] There isn't a legitimate way of getting > 999 coins other than
	;        using the status bar editor.
	cp   a, $0A						; sLevelCoins_High < 10?
	jr   c, .writeStatusBar			; If so, jump
.capCoins:
	ld   a, $99						; Otherwise, cap it at 999
	ld   [sLevelCoins_Low], a
	ld   a, $09
	ld   [sLevelCoins_High], a
.writeStatusBar:
	call StatusBar_DrawLevelCoins	; Update status bar
	ld   a, SFX1_24					; Play 100-coin SFX
	ld   [sSFX1Set], a
	ret
	
; =============== Ending_Give300Coins ===============
; Makes the player walk towards the lamp.
Mode_Ending_WalkToLamp:
	; Draw player & actors
	call HomeCall_NonGame_WriteWarioOBJLst
	call HomeCall_ActS_Do
	
	; Wait ($60) frames before walking
	ld   a, [sEndingWaitTimer]
	and  a						; Timer == 0?
	jr   z, .walkLeft			; If so, jump
	dec  a						; Timer--
	ld   [sEndingWaitTimer], a
	ret  nz						; Timer == 0 after decreasing it?
.startWalk:						; If so, setup the walk anim
	xor  a
	ld   [sPlAnimTimer], a
	ld   a, OBJ_WARIO_WALK0		; Set 		
	ld   [sPlLstId], a
	ret
.walkLeft:
	call NonGame_Wario_AnimWalkFast
	
	; If we're holding the lamp already from before, we're already good to go
	ld   a, [sActHeld]
	cp   a, PL_HLD_SPEC_NOTHROW	; Holding the lamp? (which sets this specific 
	jr   z, .nextMode
	
	;
	; Track the lamp's X position and move towards it.
	; Since outside of gameplay player-to-actor collisions aren't processed 
	; (so the check above only works if we were already holding it during the gameplay mode),
	; we mark the lamp as held when both player and lamp have the same X position.
	;
	
	ld   a, [sActLampRelXCopy]	; A = LampX
	ld   b, a
	ld   a, [sPlXRel]			; B = PlayerX
	cp   a, b					; Lamp is to the right of the player? (PlayerX < LampX?)
	jr   c, .moveRight			; If so, move right
	jr   z, .nextMode			; Same X position? If so, we're done
.moveLeft:
	; Otherwise, it's on the left of the player, 
	; so move left by 1px
	dec  a						; Dec. Relative 1-byte coord
	ld   [sPlXRel], a
	ld   b, $01					; Dec. Absolute 2-byte coord
	call Pl_MoveLeft
	ld   hl, sPlFlags			; Face left
	res  OBJLSTB_XFLIP, [hl]
	ret
.moveRight:
	; Move right by 1px
	inc  a						; Inc. Relative 1-byte coord
	ld   [sPlXRel], a
	ld   b, $01					; Inc. Absolute 2-byte coord
	call Pl_MoveRight
	ld   hl, sPlFlags			; Face right
	set  OBJLSTB_XFLIP, [hl]
	ret
	
.nextMode:
	; Prepare for the left walking sequence
	ld   a, PL_HLD_SPEC_NOTHROW	; Force lamp as held
	ld   [sActHeld], a
	ld   a, OBJ_WARIO_HOLDWALK0	; Set holding frame
	ld   [sPlLstId], a
	xor  a						; Reset walk timer
	ld   [sPlAnimTimer], a
	ld   a, [sSubMode]			; Next submode
	inc  a
	ld   [sSubMode], a
	ret
	
; =============== Mode_Ending_WalkToReload ===============
; Makes the player walk left while holding the lamp.
; Once the player gets in the correct position, it fades out and the room reloads.
Mode_Ending_WalkToReload:
	; Draw player & actors
	call HomeCall_NonGame_WriteWarioOBJLst
	call HomeCall_ActS_Do
	
	;
	; Walk towards the X position $20.
	; When we get there, trigger a fade out (next mode) to reload the room.
	;
	call NonGame_Wario_AnimWalkFast		; Animate
	
	ld   b, $20				; B = Target
	ld   a, [sPlXRel]		; A = PlayerX
	cp   a, b				; PlayerX < $20?
	jr   c, .moveRight		; If so, move right
	jr   z, .nextMode		; PlayerX == $20? If so, we're done
	
.moveLeft:
	; Otherwise move left (PlayerX > $20)
	dec  a					
	ld   [sPlXRel], a
	ld   b, $01				
	call Pl_MoveLeft
	ld   hl, sPlFlags			; Face left
	res  OBJLSTB_XFLIP, [hl]
	ret
.moveRight:
	; Move right by 1px
	inc  a
	ld   [sPlXRel], a
	ld   b, $01
	call Pl_MoveRight
	ld   hl, sPlFlags			; Face right
	set  OBJLSTB_XFLIP, [hl]
	ret
.nextMode:
	; Set standing frame -- this is visible initially for a single frame before the room reloads.
	; In practice it will be visible from the next fade in.
	; [POI] See Level_FadeOutOBJ0ToBlack_NoOBJDraw for more info.
	ld   a, OBJ_WARIO_HOLD		
	ld   [sPlLstId], a
	
	xor  a						
	ld   [sPlAnimTimer], a
	ld   a, [sSubMode]			; Next mode (fade out)
	inc  a
	ld   [sSubMode], a
	ret
	
; =============== Mode_Ending_WaitReload ===============
; Sets up the fade-out.
Mode_Ending_WaitReload:
	call HomeCall_NonGame_WriteWarioOBJLst
IF OPTIMIZE == 0
	call Game_SetFinalBossDoorPtr
ENDC
	ld   a, [sSubMode]	; Next mode
	inc  a
	ld   [sSubMode], a
	ret
	
; =============== Mode_Ending_LevelCutscene ===============
; Handles the entirety of the in-level cutscene after reloading the room.
Mode_Ending_LevelCutscene:
	;
	; The cutscene itself is all handled by Act_SyrupCastleBoss like how it did
	; when the normal gameplay code ran.
	; This will run through its routines CPTS_RTN_ENDING_10 to CPTS_RTN_WAITRELOAD.
	; In the final routine, it will signal out that the cutscene is over by setting
	; sLvlSpecClear to LVLCLEAR_FINALEXITTOMAP.
	;
	
	; If the cutscene is marked as finished, switch to the map screen part of the cutscene
	ld   a, [sLvlSpecClear]
	cp   a, LVLCLEAR_FINALEXITTOMAP			; Is it finished?
	jr   z, .startMap						; If so, jump

	call HomeCall_NonGame_WriteWarioOBJLst	; Draw Wario
	call HomeCall_ActS_Do					; Run cutscene code
	ret
.startMap:
	ld   a, MAP_MODE_INITENDING1			; Init map ending mode
	ld   [sMapId], a
	xor  a									
	ld   [sLvlSpecClear], a					; Reset
	ld   [sMapRetVal], a					; Clear map return value
	ld   a, [sSubMode]						; Next submode
	inc  a
	ld   [sSubMode], a
	ret
	
; =============== Mode_Ending_MapCutscene ===============
; Handles the entirety of the in-level cutscene after reloading the room.
Mode_Ending_MapCutscene:
	;
	; The cutscene itself is all handled by the map mode we set earlier.
	; When it's done, it will set its return value to something other than 0,
	; like all other map modes do.
	;
	
	ld   a, $01						; Run VBLANK code for map screen
	ld   [sMapVBlankMode], a
	
	; If the map screen code is done, init the genie cutscene
	ld   a, [sMapRetVal]
	and  a							; Return value != 0?
	jr   nz, .initEnding			; If so, jump
	call HomeCall_Map_CheckMapId	; Otherwise continue with the map cutscene
	ret
.initEnding:
	xor  a							; Stop VBLANK map code
	ld   [sMapVBlankMode], a
	
; =============== Mode_Ending_InitGenieCutscene ===============
; Initializes the Genie cutscene.
Mode_Ending_InitGenieCutscene:
	xor  a
	ld   [sEndingRetVal], a
	ld   [wEndingMode], a 
	ld   a, SES_ENDING				; Set tile animation for ending
	ld   [wStaticAnimMode], a
	ld   a, [sSubMode]				; Next mode
	inc  a
	ld   [sSubMode], a
	ret
	
; =============== Mode_Ending_GenieCutscene ===============
; Handles the first part of the Genie cutscene after the map unloads.
Mode_Ending_GenieCutscene:
	ld   a, $01						; Use special VBLANK mode
	ld   [sStaticScreenMode], a
	
	; If the ending code signaled us it's finished, switch to the next mode
	ld   a, [sEndingRetVal]
	and  a
	jr   nz, .nextMode
	call HomeCall_Ending_Do
	ret
.nextMode:
	xor  a							
	ld   [sEndingRetVal], a
	ld   [sStaticScreenMode], a
	ld   a, [sSubMode]				; Next mode
	inc  a
	ld   [sSubMode], a
	
; =============== Mode_Ending_InitTrRoom ===============
Mode_Ending_InitTrRoom:
	call StopLCDOperation
	call ClearWorkOAM
	call HomeCall_LoadVRAM_Ending_TreasureRoom
	call TrRoom_CopyBlockData
	call TrRoom_InitDigitVRAMPtrs
	call TrRoom_DrawTreasures
	call TrRoom_ReqDrawTotalCoins
	xor  a					; Reset screen scroll
	ldh  [hScrollY], a
	ld   [sScrollX], a
	ldh  [rSCY], a
	ldh  [rSCX], a
	ld   hl, rIE			; Disable parallax
	res  IB_STAT, [hl]
	ld   a, $E1				; Set BG palette
	ldh  [rBGP], a
	ldh  [rOBP1], a
	ld   a, $1C				; Set OBJ palette
	ldh  [rOBP0], a
	ld   a, [sSubMode]		; Next mode
	inc  a
	ld   [sSubMode], a
	xor  a
	ld   [sEndingTrRoomMode], a
	; Enable LCDC again
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_ENABLE
	ldh  [rLCDC], a
	; Draw coin counter
	; Must be done here since it expects the display/hblank interrupt enabled
	call Ending_TrRoom_WriteLevelCoins3DigitBG
	ret
	
; =============== Mode_Ending_TrRoom ===============
Mode_Ending_TrRoom:
	call .main
	call HomeCall_NonGame_WriteWarioOBJLst
	call HomeCall_ExActS_ExecuteAll
	ret
.main:
	ld   a, [sEndingTrRoomMode]
	rst  $28
	dw Ending_TrRoom_WalkInR
	dw Ending_TrRoom_CoinCount
	dw Ending_TrRoom_WaitRemove
	dw Ending_TrRoom_WaitNear
	dw Ending_TrRoom_GrabTreasure
	dw Ending_TrRoom_GetTreasure
	dw Ending_TrRoom_TreasureCoinCount
	dw Ending_TrRoom_TotalCoinCount
	dw Ending_TrRoom_AwardExtra
	dw Ending_TrRoom_WalkOutL
	
; =============== Ending_TrRoom_WalkInR ===============
; Wario walk right until moving to the standard position.
Ending_TrRoom_WalkInR:

	;
	; Walk right until reaching the target position
	;
	call NonGame_Wario_AnimWalk
	ld   a, [sPlXRel]	; PlX++
	inc  a
	ld   [sPlXRel], a
	cp   a, $28			; PlX != $28?
	ret  nz				; If so, return
	
.nextMode:
	;--
	ld   a, OBJ_WARIO_IDLE0			; [TCRF] Replaced by OBJ_TRROOM_WARIO_IDLE1 immediately
	ld   [sPlLstId], a
	;--
	xor  a
	ld   [sPlAnimTimer], a
	ld   [sExActTrRoomArrowDespawn], a
	ld   a, BGM_SHERBETLAND			; Play treasure room -- ending BGM
	ld   [sBGMSet], a
	ld   a, $80						; Wait $80 frames before decrementing the level coins
	ld   [sTrRoomCoinDecDelay], a
	call ExActS_SpawnTrRoomArrow	; Spawn flashing arrow
	ld   a, [sEndingTrRoomMode]		; Next mode
	inc  a
	ld   [sEndingTrRoomMode], a
	ld   a, OBJ_TRROOM_WARIO_IDLE0	; Set actual idle frame
	ld   [sPlLstId], a
	ret
	
; =============== Ending_TrRoom_CoinCount ===============
; Gradually moves coins from the current level count to total count.
; This is used to count down the *actual* level coins, which can be no
; more than 999 (the treasure countdown is done separately).
;
; See also: Mode_LevelClear_TrRoomCoinCount
Ending_TrRoom_CoinCount:
	call TrRoom_AnimCoin
	call TrRoom_AnimWarioGloat
	
	;
	; Wait for until the timer ticks down to $02 before counting down the coins.
	; This is also checked for in ExAct_TrRoom_Arrow.
	;
	; It's also used to have it count down coins every 2 frames, but this
	; doesn't affect ExAct_TrRoom_Arrow.
	;
	ld   a, [sTrRoomCoinDecDelay]	; Delay--
	dec  a
	ld   [sTrRoomCoinDecDelay], a	; Delay != 0?
	ret  nz							; If do, return
	ld   a, $02						; Wait $02 frames for next decrease
	ld   [sTrRoomCoinDecDelay], a
	
	;
	; Remove a coin from the level coin count, and add it to the total coin count.
	;
	ld   a, [sLevelCoins_Low]		; sLevelCoins--
	sub  a, $01
	daa
	ld   [sLevelCoins_Low], a
	ld   a, [sLevelCoins_High]
	sbc  a, $00
	daa
	ld   [sLevelCoins_High], a
	
	; If we had 0 coins and we underflowed, it means we have finished.
	jr   c, Ending_TrRoom_SwitchToIdle	; sLevelCoins < 0? If so, jump
	
	; Otherwise, add that coin to the total coin count
	ld   a, [sTotalCoins_Low]		; sTotalCoins++
	add  $01
	daa
	ld   [sTotalCoins_Low], a
	ld   a, [sTotalCoins_Mid]
	adc  a, $00						; for carry
	daa
	ld   [sTotalCoins_Mid], a
	ld   a, [sTotalCoins_High]
	adc  a, $00						; for carry
	ld   [sTotalCoins_High], a
	
	;--
	; If we went past 99999 total coins, force it back
	cp   a, $0A				; CoinCount_High == 10?
	jr   nz, .playCoinSFX	; If not, skip
	; Otherwise, force it back
	ld   a, $99
	ld   [sTotalCoins_Low], a
	ld   [sTotalCoins_Mid], a
	ld   a, $09
	ld   [sTotalCoins_High], a
	;--
.playCoinSFX:
	ld   a, SFX2_02
	ld   [sSFX2Set], a
	; Update the coin count tilemap
	call Ending_TrRoom_WriteLevelCoins3DigitBG
	; Request to update the total coin count on VBLANK
	jp   TrRoom_ReqDrawTotalCoins
	
; =============== Ending_TrRoom_SwitchToIdle ===============
; Switches to the next mode after finishing to count down coins.	
Ending_TrRoom_SwitchToIdle:
	xor  a							; Reset coin count
	ld   [sLevelCoins_Low], a
	ld   [sLevelCoins_High], a
	ld   a, $01						; Signal out to despawn the flashing arrow
	ld   [sExActTrRoomArrowDespawn], a
	ld   a, $80						; Wait for $80 frames in the next mode
	ld   [sPlDelayTimer], a
	ld   a, $02						; Next mode
	ld   [sEndingTrRoomMode], a
	ld   a, ENDT_RTN_COINCOUNT		; Start taking out the first treasure by ID next
	ld   [sTreasureId], a
	ret
	
; =============== Ending_TrRoom_WaitRemove ===============
; Waits before removing a treasure.
Ending_TrRoom_WaitRemove:
	call TrRoom_AnimCoin
	;
	; Wait $80 frames before removing the current treasure
	;
	ld   a, [sPlDelayTimer]	
	and  a					; Delay == $00?
	jr   z, .chkRemove		; If so, jump
	dec  a					; Delay--
	
	; The frame before, set the idle animation (from the Gloat one)
	ld   [sPlDelayTimer], a		; Delay != $00?
	ret  nz					; If so, return
	
	ld   a, OBJ_WARIO_IDLE0
	ld   [sPlLstId], a
	xor  a
	ld   [sPlAnimTimer], a
	ret
	
.chkRemove:
	; This iterates over sTreasureId

	;
	; If we didn't collect the treasure, skip a couple of modes ahead
	;
	call Map_IsTreasureCollected
	jp   z, Ending_TrRoom_SetNextTreasure
	
.nextMode:
	;
	; Otherwise, switch to the next mode and spawn the treasure exiting out of the box.
	;
	; Because the treasure is part of the tilemap, we have to replace its 16x16 block
	; with the one for a blank space (otherwise it'd look like it duplicated).
	; We're doing that in the next mode though.
	;
	ld   b, EXACT_TREASUREENDING
	call ExActS_SpawnTreasure
	ld   a, [sEndingTrRoomMode]			; Next mode
	inc  a
	ld   [sEndingTrRoomMode], a
	xor  a								; Init		
	ld   [sExActTrRoomTreasureNear], a
	ret
	
; =============== Ending_TrRoom_WaitNear ===============
; The player waits until the treasure gets near, then sets up
; the action to grab it.
Ending_TrRoom_WaitNear:
	call TrRoom_AnimCoin				; Animate 16x16 coin
	
	;
	; Wait for the treasure to get near first.
	; The treasure actor will be moving right, and when it gets near enough,
	; it will notify us by setting sExActTrRoomTreasureNear.
	;
	ld   a, [sExActTrRoomTreasureNear]
	and  a
	ret  z
	xor  a
	ld   [sExActTrRoomTreasureNear], a
	
	;
	; The player now has to grab the treasure. He can either:
	; - Jump (treasure in rows 1 or 2 -- two possible heights, decided later)
	; - Duck (treasure in row 3)
	;
	; [BUG] Standing frame seems odd for this. Shouldn't it be OBJ_WARIO_HOLDJUMP?
	IF FIX_BUGS == 1
		ld   a, OBJ_WARIO_HOLDJUMP
	ELSE
		ld   a, OBJ_WARIO_HOLD			; Set norm. frame initially
	ENDC
	ld   [sPlLstId], a
	ld   a, [sExActTreasureRow]
	cp   a, $02						; Is this treasure in the third row?
	jr   nz, .nextMode				; If not, skip
	; Otherwise, make the player duck
	ld   a, $01
	ld   [sPlDuck], a
	ld   a, OBJ_WARIO_DUCKHOLD
	ld   [sPlLstId], a
.nextMode:
	xor  a
	ld   [sPlAnimTimer], a
	ld   a, [sEndingTrRoomMode]
	inc  a
	ld   [sEndingTrRoomMode], a
	ret
	
; =============== Ending_TrRoom_GrabTreasure ===============
; Wario jumps (or ducks) to grab the treasure.
Ending_TrRoom_GrabTreasure:
	call TrRoom_AnimCoin
	
	;
	; Do a different action depending on the row the treasure came from.
	;
	ld   a, [sExActTreasureRow]
	dec  a			; Row == $01? (row 2)
	jr   z, .row2	; If so, jump
	dec  a			; Row == $02? (row 3)
	jr   z, .row3	; If so, jump
.row1:				; Otherwise, it's the first row
	;
	; First row - Jump up to Y position $7E
	;
	ld   a, [sPlYRel]		; Move up 2px/frame
	sub  a, $02
	ld   [sPlYRel], a
	cp   a, $7E				; Reached target?
	ret  nz					; If not, return
	
	ld   a, OBJ_WARIO_JUMP	; Set jump frame without holding
	ld   [sPlLstId], a
	ld   a, [sEndingTrRoomMode]	; Next mode
	inc  a
	ld   [sEndingTrRoomMode], a
	ld   a, $08				; Wait 8 frames before falling down
	ld   [sPlDelayTimer], a
	ret
.row2:
	;
	; Second row - Jump up to Y position $8E
	;
	ld   a, [sPlYRel]		; Move up 2px/frame
	sub  a, $02
	ld   [sPlYRel], a
	cp   a, $8E				; Reached target?
	ret  nz					; If not, return
	
	ld   a, OBJ_WARIO_JUMP	; Set jump frame without holding
	ld   [sPlLstId], a
	ld   a, [sEndingTrRoomMode]	; Next mode
	inc  a
	ld   [sEndingTrRoomMode], a
	ld   a, $08				; Wait 8 frames before falling down
	ld   [sPlDelayTimer], a
	ret
.row3:
	;
	; Third row - Just duck
	;
	ld   a, [sEndingTrRoomMode]	; Next mode
	inc  a
	ld   [sEndingTrRoomMode], a
	ld   a, $10
	ld   [sPlDelayTimer], a
	ret
	
; =============== Ending_TrRoom_GetTreasure ===============
; Makes the player land from the jump, then collects the treasure.
Ending_TrRoom_GetTreasure:
	call TrRoom_AnimCoin
	
	;
	; Wait the specified number of frames before continuing.
	; When we get here in the jump frame, this is used to give the "delay"
	; before down, like how it appears during gameplay.
	;
	ld   a, [sPlDelayTimer]
	and  a
	jr   z, .chkMoveDown
	dec  a
	ld   [sPlDelayTimer], a
	ret
.chkMoveDown:
	
	;
	; If we aren't on the ground, move down before continuing.
	;
	ld   a, [sPlYRel]
	cp   a, $98			; YPos == $98?
	jr   z, .landed		; If so, we're on the ground
	add  $02			; Otherwise, move down 2px/frame
	ld   [sPlYRel], a
	ret
.landed:
	;
	; Collect the treasure, and display its value on the level coin counter.
	;
	ld   a, OBJ_TRROOM_WARIO_IDLE0	; Stand
	ld   [sPlLstId], a
	xor  a							; Stop ducking, if set
	ld   [sPlDuck], a
	ld   a, [sEndingTrRoomMode]		; Next mode
	inc  a
	ld   [sEndingTrRoomMode], a
	ld   a, SFX1_30					; Play "treasure collected" SFX
	ld   [sSFX1Set], a
	ld   a, $80						; Wait for $80 frames before decrementing the coin count
	ld   [sTrRoomCoinDecDelay], a
	
	; Set the amount of money the treasure's worth
	call Ending_TrRoom_GetTreasureMoney				
	ld   a, h						
	ld   [sLevelCoins_High], a
	ld   a, l
	ld   [sLevelCoins_Low], a
	ret
	
; =============== Ending_TrRoom_GetTreasureMoney ===============
; Gets how much money the current sTreasureId is worth.
; IN
; - sTreasureId: Treasure ID
; OUT
; - BC: Amount of money
Ending_TrRoom_GetTreasureMoney:
	ld   a, [sTreasureId]
	dec  a
	rst  $28
	dw .m2000 ; TREASURE_C
	dw .m7000 ; TREASURE_I
	dw .m9000 ; TREASURE_F
	dw .m6000 ; TREASURE_O
	dw .m9000 ; TREASURE_A
	dw .m7000 ; TREASURE_N
	dw .m8000 ; TREASURE_H
	dw .m4000 ; TREASURE_M
	dw .m8000 ; TREASURE_L
	dw .m4000 ; TREASURE_K
	dw .m6000 ; TREASURE_B
	dw .m7000 ; TREASURE_D
	dw .m5000 ; TREASURE_G
	dw .m3000 ; TREASURE_J
	dw .m5000 ; TREASURE_E
.m2000:
	ld   hl, $2000
	ret
.m3000:
	ld   hl, $3000
	ret
.m4000:
	ld   hl, $4000
	ret
.m5000:
	ld   hl, $5000
	ret
.m6000:
	ld   hl, $6000
	ret
.m7000:
	ld   hl, $7000
	ret
.m8000:
	ld   hl, $8000
	ret
.m9000:
	ld   hl, $9000
	ret
	
; =============== Ending_TrRoom_TreasureCoinCount ===============
; Gradually moves coins from the current level count (treasure worth) to total count.
; See also: Ending_TrRoom_CoinCount
Ending_TrRoom_TreasureCoinCount:
	call TrRoom_AnimCoin
	call Ending_TrRoom_WriteLevelCoins4DigitBG
	call TrRoom_AnimWarioGloat
	
	;
	; Wait for until the timer ticks down to $02 before counting down the coins.
	; This is also checked for in ExAct_TrRoom_Arrow.
	;
	; It's also used to have it count down coins every 2 frames, but this
	; doesn't affect ExAct_TrRoom_Arrow.
	;
	ld   a, [sTrRoomCoinDecDelay]	; Delay--
	dec  a
	ld   [sTrRoomCoinDecDelay], a	; Delay != 0?
	ret  nz							; If do, return
	ld   a, $02						; Wait $02 frames for next decrease
	ld   [sTrRoomCoinDecDelay], a
	
	;
	; Determine the amount to decrement and set it to B.
	; To speed things up, if there are still hundreds or thousands left,
	; decrement 63 coins at once.
	;
	; If less than 100 are left, then decrement the usual 1 coin.
	; (this simplifies handling by not having to deal with underflowed values)
	;
	ld   b, $01
	ld   a, [sLevelCoins_High]
	and  a						; sLevelCoins < 100?
	jr   z, .decCoins			; If so, jump
	ld   b, $63
.decCoins:

	;
	; Remove the specified amount of coins from the level coin count,
	; and add it to the total coin count.
	;
	ld   a, [sLevelCoins_Low]		; sLevelCoins -= B
	sub  a, b
	daa
	ld   [sLevelCoins_Low], a
	ld   a, [sLevelCoins_High]
	sbc  a, $00
	daa
	ld   [sLevelCoins_High], a
	
	; If we had 0 coins and we underflowed, it means we have finished.
	jr   c, .nextMode					; sLevelCoins < 0? If so, jump
	
	; Otherwise, add those coins to the total coin count
	ld   a, [sTotalCoins_Low]		; sTotalCoins += B
	add  b
	daa
	ld   [sTotalCoins_Low], a
	ld   a, [sTotalCoins_Mid]
	adc  a, $00						; for carry
	daa
	ld   [sTotalCoins_Mid], a
	ld   a, [sTotalCoins_High]
	adc  a, $00						; for carry
	ld   [sTotalCoins_High], a
	
	;--
	; If we went past 99999 total coins, force it back
	cp   a, $0A				; CoinCount_High == 10?
	jr   nz, .playCoinSFX	; If not, skip
	; Otherwise, force it back
	ld   a, $99
	ld   [sTotalCoins_Low], a
	ld   [sTotalCoins_Mid], a
	ld   a, $09
	ld   [sTotalCoins_High], a
	;--
.playCoinSFX:
	ld   a, SFX2_02					
	ld   [sSFX2Set], a
	jp   TrRoom_ReqDrawTotalCoins
.nextMode:
	xor  a
	ld   [sLevelCoins_Low], a
	ld   [sLevelCoins_High], a
	
; =============== Ending_TrRoom_SetNextTreasure ===============
Ending_TrRoom_SetNextTreasure:
	; If we finished obtaining all treasures, get out the moneybags
	ld   a, [sTreasureId]
	cp   a, $0F					; TreasureId == $0F?
	jr   z, .nextMode				; If so, jump (that's the last one)
.nextTreasure:
	inc  a						; Otherwise, see next treasure
	ld   [sTreasureId], a
	xor  a						; Reset timer
	ld   [sPlAnimTimer], a
	ld   a, OBJ_WARIO_IDLE0		
	ld   [sPlLstId], a
	ld   a, ENDT_RTN_WAITREMOVE	; New mode
	ld   [sEndingTrRoomMode], a
	ret
.nextMode:
	ld   a, ENDT_RTN_TOTALCOINCOUNT	; Next mode
	ld   [sEndingTrRoomMode], a
	ld   a, $80					; Wait $80 frames before decrementing the total coins
	ld   [sTrRoomCoinDecDelay], a
	xor  a
	ld   [sExActMoneybagStackMode], a
	ld   [sTrRoomMoneybagCount], a
	ret
	
; =============== Ending_TrRoom_TotalCoinCount ===============
; Gradually reduces the total coin count, awarding moneybags when
; certain amounts are reached.
Ending_TrRoom_TotalCoinCount:
	call TrRoom_AnimCoin
	
	;
	; Wait for until the timer ticks down to $02 before counting down the coins.
	; It's also used to have it count down coins every 2 frames.
	;
	ld   a, [sTrRoomCoinDecDelay]
	dec  a
	ld   [sTrRoomCoinDecDelay], a
	ret  nz
	ld   a, $02
	ld   [sTrRoomCoinDecDelay], a
	
	;
	; Determine the amount to decrement and set it to B.
	; To speed things up, if there >= 100 left decrement 63 coins at once.
	;
	; If less than 100 are left, then decrement the usual 1 coin.
	; (this simplifies handling by not having to deal with underflowed values)
	;
	ld   b, $01
	ld   a, [sTotalCoins_High]	
	ld   c, a
	ld   a, [sTotalCoins_Mid]
	or   a, c			; sTotalCoins_High == 0 && sTotalCoins_Mid == 0?
	jr   z, .decCoins		; If so, jump
	ld   b, $63
.decCoins:

	;
	; Remove the specified amount of coins from the total coin counter,
	; and add it to a separate counter which is checked when awarding moneybags.
	;
	; sTotalCoins -= B
	ld   a, [sTotalCoins_Low]	; sTotalCoins_Low -= B
	sub  a, b
	daa
	ld   [sTotalCoins_Low], a
	ld   a, [sTotalCoins_Mid]	; sTotalCoins_Mid -= (carry)
	sbc  a, $00
	daa
	ld   [sTotalCoins_Mid], a
	ld   a, [sTotalCoins_High]	; sTotalCoins_High -= (carry)
	sbc  a, $00
	daa
	ld   [sTotalCoins_High], a
	
	; If we had 0 coins and we underflowed, it means we have finished.
	jr   c, .nextMode
.playSFX:
	ld   a, SFX2_02
	ld   [sSFX2Set], a
	
	; Add the coin back to a separate total coin counter.
	; Then award moneybags when this other counter reaches certain values.
	;
	; sEndTotalCoins += B
	ld   a, [sEndTotalCoins_Low]	
	add  b
	daa
	ld   [sEndTotalCoins_Low], a
	ld   a, [sEndTotalCoins_Mid]
	adc  a, $00
	daa
	ld   [sEndTotalCoins_Mid], a
	
	; Because the milestones for the moneybags are multiples of 10000,
	; we can skip checking for a new moneybag we aren't incrementing sEndTotalCoins_High.
	jr   nc, .drawCoins
	ld   a, [sEndTotalCoins_High]
	adc  a, $00
	ld   [sEndTotalCoins_High], a
	
	;
	; Award at most 4 moneybags when counting down coins.
	; The 5th one is awarded after they have finished counting.
	; The extra 6th one is awarded even later on, if we have all treasures.
	;
	cp   a, $01							; 10000 coins - opt. moneybag 1
	jr   z, .awardMoneybag_drawCoins
	cp   a, $04							; 40000 coins - opt. moneybag 2
	jr   z, .awardMoneybag_drawCoins
	cp   a, $07							; 70000 coins - opt. moneybag 3
	jr   z, .awardMoneybag_drawCoins
	cp   a, $09							; 90000 coins - opt. moneybag 4
	jr   z, .awardMoneybag_drawCoins
.drawCoins:
	jp   TrRoom_ReqDrawTotalCoins
.awardMoneybag_drawCoins:
	call ExActS_SpawnMoneybag
	jp   TrRoom_ReqDrawTotalCoins
.nextMode:
	; Always award another moneybag containing the remainder of the coins.
	; This makes sure at least one moneybag is awarded.
	call ExActS_SpawnMoneybag
	
	
	ld   a, $80					; Wait $80 frames before possibly awarding the 6th moneybag
	ld   [sTrRoomWaitTimer], a
	ld   a, [sEndingTrRoomMode]	; Next mode
	inc  a
	ld   [sEndingTrRoomMode], a
	ret
; =============== ExActS_SpawnMoneybag ===============
; Spawns a falling moneybag, aligned to the pile of moneybags Wario is holding.
ExActS_SpawnMoneybag:
	ld   hl, sExActSet
	ld   a, EXACT_MONEYBAG	; Actor ID
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ld   a, OBJ_TRROOM_MONEYBAG_FALL	; Initial frame
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	; Align to the pile of moneybags Wario is holding.
	ld   a, $48		; Y pos
	ldi  [hl], a
	ld   a, $38		; X pos
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	call ExActS_Spawn
	
	ld   a, SFX1_08			; Play jingle when spawning
	ld   [sSFX1Set], a
	; Put the player in the "holding" frame when the moneybag appears.
	; (already in this frame if we were already holding one moneybag)
	ld   a, OBJ_WARIO_HOLD			
	ld   [sPlLstId], a
	ret
	
; =============== Ending_TrRoom_AwardExtra ===============
; Waits, then tries to award the 6th moneybag.
Ending_TrRoom_AwardExtra:
	call TrRoom_AnimCoin
	
	;--
	; Wait $80 frames before continuing
	ld   a, [sTrRoomWaitTimer]
	and  a
	jr   z, .chkAwardExtra
	dec  a
	ld   [sTrRoomWaitTimer], a
	ret
.chkAwardExtra:
	;--
	;
	; If we survive the gauntlet, we can have the 6th moneybag.
	; This requires:
	; - All treasures
	; - (9)9999 coins
	;
	
	; If we don't have all treasures, don't award it
	ld   a, [sTreasures]
	cp   a, $FE
	jr   nz, .noAward
	ld   a, [sTreasures+1]
	cp   a, $FF
	jr   nz, .noAward
	
	; If we don't have 99999 coins, don't award it
	; Note that we don't need to check for sEndTotalCoins_High being $09,
	; since if we have all treasures, that will automatically be the case.
	; And we can only get here with all treasures.
	ld   a, [sEndTotalCoins_Mid]
	cp   a, $99
	jr   nz, .noAward
	ld   a, [sEndTotalCoins_Low]
	cp   a, $99
	jr   nz, .noAward
	
	call ExActS_SpawnMoneybag
.noAward:
	ld   a, $80						; Wait $80 frames before walking back
	ld   [sTrRoomWaitTimer], a
	ld   a, BGM_TREASUREGET			; Play treasure get BGM
	ld   [sBGMSet], a
	ld   a, [sEndingTrRoomMode]		; Next mode
	inc  a
	ld   [sEndingTrRoomMode], a
	ret
	
; =============== Ending_TrRoom_WalkOutL ===============
; Wario walk off-screen to the left, holding the moneybags.
Ending_TrRoom_WalkOutL:
	call TrRoom_AnimCoin
	
	; Wait $80 frames before continuing
	ld   a, [sTrRoomWaitTimer]
	and  a
	jr   z, .walkLeft
	dec  a
	ld   [sTrRoomWaitTimer], a
	ret  nz
.startWalk:
	xor  a						
	ld   [sPlAnimTimer], a			; Init timer for walk anim
	ld   [sPlFlags], a			; Face left
	ld   a, OBJ_WARIO_WALK0		; Set initial frame
	ld   [sPlLstId], a
	ld   a, MONEYBAGSTACK_SYNCPOS		; Stary syncing moneybag position with player
	ld   [sExActMoneybagStackMode], a
	ret
	
.walkLeft:
	;
	; Walk left until we get off-screen.
	;
	call NonGame_Wario_AnimWalkFast
	ld   a, [sPlXRel]	; PlX--
	dec  a
	ld   [sPlXRel], a
	cp   a, $08			; PlX != $08?
	ret  nz				; If so, return
.nextMode:
	xor  a
	ld   [sEndingTrRoomMode], a
	ld   [sEndingWaitTimer], a			; Wait 256 frames in Credits_Mode_Init
	ld   [sEndingRetVal], a
	ld   a, SES_ENDING					; Tile animation for ending
	ld   [wStaticAnimMode], a
	ld   a, GM_ENDING_GENIECUTSCENE2	; Switch to Mode_Ending_GenieCutscene2 next time
	ld   [sSubMode], a
	ret
	
; =============== Mode_Ending_GenieCutscene2 ===============
; Handles the second part of the genie cutscene, after returning from the treasure room.
Mode_Ending_GenieCutscene2:
	ld   a, $01
	ld   [sStaticScreenMode], a
	call HomeCall_Ending_Do
	call .creditsMain
	ret
.creditsMain:
	; This will effectively execute only after HomeCall_Ending_Do is marked as "returned".
	; When that happens, HomeCall_Ending_Do will continue to handle the player's walking animation,
	; but the actual parallax/text scrolling is done here.
	ld   a, [sCreditsMode]
	rst  $28
	
	dw Credits_Mode_Init
	dw Credits_Mode_BlankBox
	dw Credits_Mode_InitWriteRow1
	dw Credits_Mode_WriteRow1
	dw Credits_Mode_InitWriteRow2
	dw Credits_Mode_ScrollRow2
	dw Credits_Mode_ChkEnd
	dw Credits_Mode_ScrollOutRow2
	dw Credits_Mode_BlankBoxRow2
	dw Credits_Mode_ScrollOutBothRows
	dw Credits_Mode_WaitBeforeLastMessage
	dw Credits_Mode_Halt
	
; =============== Credits_Mode_Init ===============
Credits_Mode_Init:
	; Don't execute unless the cutscene has returned
	ld   a, [sEndingRetVal]
	and  a
	ret  z
	
	; Wait 256 frames before continuing
	ld   a, [sEndingWaitTimer]
	dec  a
	ld   [sEndingWaitTimer], a
	ret  nz
	
	;
	; Move both screen and sprites up by 8px
	;
	
	; Scroll screen up (move viewport down)
	ldh  a, [rSCY]
	add  $08
	ldh  [rSCY], a
	ldh  [hScrollY], a
	
	; Move "W" mark up 10px
	ld   a, [wEndWLogoY]
	sub  a, $08
	ld   [wEndWLogoY], a
	
	; Move player up 10px (and not just 8px) to compensate for the player's origin
	; being on the ground.
	; These 2 extra pixels makes sure the player sprite doesn't overlap with
	; the black box with the credits text.
	ld   a, [wStaticPlY]
	sub  a, $0A
	ld   [wStaticPlY], a
	
	; Initialize line index for the tables
	xor  a
	ld   [sCreditsRow1LineId], a
	ld   [sCreditsRow2LineId], a
	
; =============== Credits_SwitchToBlankBox ===============
; Initializes the mode to blank the box in the credits.
Credits_SwitchToBlankBox:
	ld   a, GM_CREDITS_BLANKBOX	; Next mode
	ld   [sCreditsMode], a
	
	; Set the initial row position of what we're blanking through ScreenEvent_Mode_CreditsBar.
	; We'll be iterating on more rows below in the next mode.
	
	ld   a, HIGH(vBGCreditsBox)	; Initial row ptr
	ld   [sBGTmpPtr], a
	ld   a, LOW(vBGCreditsBox)
	ld   [sBGTmpPtr+1], a
	ld   a, SCRUPD_CREDITSBOX	; Request ScreenEvent_Mode_CreditsBar
	ld   [sScreenUpdateMode], a
	ret
	
; =============== Credits_Mode_BlankBox ===============
; Blanks the box in the credits on multiple frames, with every frame
; overwriting the row below.
Credits_Mode_BlankBox:

	;
	; Update tilemap ptr to point to the next line to blank. 
	; sBGTmpPtr += BG_TILECOUNT_H
	;
	ld   a, [sBGTmpPtr]		; HL = sBGTmpPtr + $20
	ld   h, a
	ld   a, [sBGTmpPtr+1]
	ld   l, a
	ld   de, BG_TILECOUNT_H
	add  hl, de
	
	; If we went past the last line of the credits box, we're done
	ld   a, h						
	cp   a, HIGH(vBGCreditsBox_End)	; HL > $9C00?
	jr   z, .nextMode				; If so, jump
	
	; Otherwise, save back the updated line
	ld   [sBGTmpPtr], a
	ld   a, l
	ld   [sBGTmpPtr+1], a
	ld   a, SCRUPD_CREDITSBOX	; Request ScreenEvent_Mode_CreditsBar
	ld   [sScreenUpdateMode], a
	ret
.nextMode:
	ld   a, [sCreditsMode]
	inc  a
	ld   [sCreditsMode], a
	ret
	
; =============== Credits_Mode_InitWriteRow1 ===============
Credits_Mode_InitWriteRow1:
	; Write the line to write to the source buffer
	call HomeCall_Credits_WriteLineForRow1ToBuffer
	
	; Write the ptr to the destination in the tilemap
	ld   a, HIGH(vBGCreditsRow1)
	ld   [sBGTmpPtr], a
	ld   a, LOW(vBGCreditsRow1)
	ld   [sBGTmpPtr+1], a
	
	; Init mode
	xor  a
	ld   [sCreditsTextTimer], a		; Reset vars
	ld   [sPlXRel], a				; Reset vars
	ld   a, SCRUPD_CRDTEXT1			
	ld   [sScreenUpdateMode], a
	ld   a, PRX_CREDMAIN		
	ld   [sParallaxMode], a
	
	; Init/enable LYC for parallax text effects
	xor  a
	ldh  [rIF], a
	ldh  [rLYC], a
	ld   a, STAT_LYC
	ldh  [rSTAT], a
	ldh  a, [rSCX]			; Init section X pos
	ld   [sScrollX], a
	ld   [sParallaxX0], a
	ld   [sParallaxX1], a
	ldh  a, [rSCY]			; Init section Y pos
	ldh  [hScrollY], a
	ld   [sParallaxY0], a
	ld   [sParallaxY1], a
	ld   a, [sCreditsMode]	; Next mode
	inc  a
	ld   [sCreditsMode], a
	ld   a, SFX4_01
	ld   [sSFX4Set], a
	ld   [sPlGroundDashTimer], a
	ld   hl, rIE			; Enable parallax
	set  IB_STAT, [hl]
	ret
	
; =============== Credits_Mode_WriteRow1 ===============
; Handles the parallax scrolling for the text in the first row.
Credits_Mode_WriteRow1:
	; Scroll the text at 0.25px/frame
	ld   a, [sTimer]
	and  a, $03
	ret  z
	
	;
	; Increase the text timer.
	; Whenever this timer becomes a multiple of 8, a new tile will be written
	; off-screen to the right.
	; NOTE: This is synched to the sParallaxX0 parallax movement, as every
	;       this timer is increased, the parallax is moved right once.
	;
	ld   a, [sCreditsTextTimer]	; TextTimer++
	inc  a
	ld   [sCreditsTextTimer], a
	
	;
	; Increase the "effect" timer.
	; After being increased, the timer can have 4 possible values, where:
	; - 1: Move text left 1px
	; - 2: Move text left 1px
	; - 3: Move text right 24px
	; - 4: Move text left 24+2px, then reset "effect" timer and
	;      check if sCreditsTextTimer is a multiple of 8.
	;
	; Meaning that for every 4 timer increses, the text moves left 4px overall.
	; (and every 8 increases it's 8px overall, which is important for sCreditsTextTimer)
	;
	ld   a, [sCreditsRowEffectTimer]; EfxTimer++
	inc  a
	ld   [sCreditsRowEffectTimer], a
	cp   a, $03						; EfxTimer == $03?
	jr   z, .multiRight				; If so, jump
	cp   a, $04						; EfxTimer == $04?
	jr   z, .multiLeft				; If so, jump
.moveLeft:
	; Otherwise, scroll the text left by 1px (move viewport right)
	ld   a, [sParallaxX0]		; Row1Parallax++
	add  $01
	ld   [sParallaxX0], a
	
	; When the text reaches the leftmost position (rightmost scroll viewport), switch to the next mode
	cp   a, $98						; XPos < $98?
	ret  c							; If so, return
.nextMode:
	xor  a
	ld   [sPlGroundDashTimer], a
	ld   a, [sCreditsMode]			; Next mode
	inc  a
	ld   [sCreditsMode], a
	ret
.multiRight:
	ld   a, [sParallaxX0]			; Move text right $24px
	sub  a, $24
	ld   [sParallaxX0], a
	ret
.multiLeft:
	xor  a
	ld   [sCreditsRowEffectTimer], a
	
	ld   a, [sParallaxX0]			; Move text left $26px
	add  $24+$02
	ld   [sParallaxX0], a
	
	;
	; Every 8 execution frames (text moved 8px left), determine
	; if we have to write a tile to the location.
	;
	ld   a, [sCreditsTextTimer]
	and  a, $07						; Timer % 8 != 0?
	ret  nz							; If so, return
	
	;
	; Request to write a tile to the closest off-screen location on the right.
	; This location is stored on sBGTmpPtr.
	;
	; The intended range for writing to the row is:
	;  $99E0 - $99FF
	;
	; Because we should never write to another row, if we go past $99FF we have
	; to loop back to $99E0 (which is fine, since the tilemap loops).
	;
	; Since we have to write to an off-screen tile (to avoid pop-in), the initial
	; location for writing the text *isn't* $99E0, but $14 tiles to the right ($99F4).
	; This is because the screen is fully scrolled to the left initially, and the
	; first $14 tiles are visible.
	;
	
	;--
	; [POI] $9A80 is impossible to reach.
	ld   a, [sBGTmpPtr+1]
	cp   a, $80						; sBGTmpPtr_Low == $80?
	ret  z							; If so, return
	;--
	
	; Move to next tile in the row.
	inc  a							
	ld   [sBGTmpPtr+1], a			
	; If we crossed into the next row, loop back to the beginning of the row
	jr   nz, .writeTile		; If not crossed, skip
	ld   a, LOW($99E0)		; Otherwise, reset to $99E0
	ld   [sBGTmpPtr+1], a
	
.writeTile:
	ld   a, SCRUPD_CRDTEXT1
	ld   [sScreenUpdateMode], a
	ret
	
; =============== Credits_Mode_InitWriteRow2 ===============
; Requests to write the text for the second row.
Credits_Mode_InitWriteRow2:
	;--
	; [TCRF] When we're over line $2C, set $A95E to $01.
	;        This address is never used again.
	ld   a, [sCreditsRow2LineId]
	cp   a, $2C				; LineId == $2C?
	jr   nz, .writeRow2		; If not, skip
	ld   a, $01
	ld   [sCredits_Unused_ReachedLine2C], a		
.writeRow2:
	;--
	
	; Because of the vertical scrolling, the second row can be requested to draw immediately.
	call HomeCall_Credits_WriteLineForRow2ToBuffer		
	ld   a, SCRUPD_CRDTEXT2								
	ld   [sScreenUpdateMode], a
	ld   a, [sCreditsMode]		; Next mode
	inc  a
	ld   [sCreditsMode], a
	ret
; =============== Credits_Mode_ScrollRow2 ===============
; Scrolls the second row of text vertically, through parallax updating.
Credits_Mode_ScrollRow2:
	;
	; Move the viewport down $20px, at 1px/frame.
	; This will move the text upwards.
	;
	; $20px (4 tiles) since the text for the second line is written on the second
	; row off-screen below, and we have to move it to the second-to-last visible row.
	;

	ld   a, [sParallaxY1]	; ParY++
	add  $01
	ld   [sParallaxY1], a
	cp   a, $20				; ParY < $20?
	ret  c					; If so, return
.nextMode:
	ld   a, [sCreditsMode]	; Next mode
	inc  a
	ld   [sCreditsMode], a
	ld   a, $D0				; Display text for $D0 frames
	ld   [sEndingWaitTimer], a
	ret
	
; =============== Credits_Mode_ChkEnd ===============
; Waits for a bit while the text is visible, then decides what to do.
Credits_Mode_ChkEnd:
	;--
	; Wait for $D0 frames before continuing
	ld   a, [sEndingWaitTimer]
	dec  a
	ld   [sEndingWaitTimer], a
	ret  nz
	;--
	
	;
	; At the end of every line in the second row, the last byte is a type of end-separator.
	; When first copying the line to the buffer, depending on what kind of 
	; separator we hit, a different value will be set to sCreditsNextRow1Mode.
	;
	; All of the separators types cause the second row to be scrolled off --
	; the difference is what happens with the first row.
	;
	
	;
	; If no special command was specified, it means we don't change the first line.
	;
	ld   a, [sCreditsNextRow1Mode]
	and  a							; Cmd != 0?
	jr   nz, .nextRowBoth			; If so, jump
.onlyNextRow2:
	ld   a, [sCreditsMode]			; Next mode (scroll second only)
	inc  a
	ld   [sCreditsMode], a
	ret
.nextRowBoth:
	;
	; Otherwise, we're also clearing off the first line.
	; There are two special ways to do it for the...
	;
	cp   a, CTN_LASTLINE		; About to draw the last line?
	jr   z, .prepLastLine		; If so, jump
	cp   a, CTN_HALT			; Reached the last line? (no more rows left)
	jr   z, .noMoreText			; If so, jump
	;
	; ...as well as a standard way (sCreditsNextRow1Mode == $01), which is the
	; standard separator to scroll both rows away.
	;
	xor  a
	ld   [sCreditsNextRow1Mode], a
	ld   a, GM_CREDITS_SCROLLOUTBOTHROWS
	ld   [sCreditsMode], a
	ret
.prepLastLine:
	xor  a
	ld   [sCreditsNextRow1Mode], a
	ld   [sEndingWaitTimer], a		; Wait 256 frames (*4)
	ld   a, GM_CREDITS_PRELASTMSG
	ld   [sCreditsMode], a
	ret
.noMoreText:
	xor  a
	ld   [sCreditsNextRow1Mode], a
	ld   [sEndingWaitTimer], a
	ld   a, GM_CREDITS_HALT
	ld   [sCreditsMode], a
	ret
	
; =============== Credits_Mode_ScrollOutRow2 ===============
; Scrolls off only the second row of text.
Credits_Mode_ScrollOutRow2:
	;
	; By further scrolling the viewport down, the text moves up and gets
	; progressively "cut off" until it disappears.
	; 
	ld   a, [sParallaxY1]	; sParallaxY1++
	add  $01
	ld   [sParallaxY1], a
	cp   a, $38				; sParallaxY1 < $38?
	ret  c					; If so, jump
	
.nextMode:
	;
	; After it's scrolled out of view, request to redraw part of the
	; blank textbox area, deleting the text of the second row from the tilemap.
	;
	ldh  a, [hScrollY]		; Reset source scrolling
	ld   [sParallaxY1], a
	ld   a, [sCreditsMode]	; Next mode
	inc  a
	ld   [sCreditsMode], a
	; Prepare overwrite
	ld   a, HIGH(vBGCreditsBoxBlankRow2)
	ld   [sBGTmpPtr], a
	ld   a, LOW(vBGCreditsBoxBlankRow2)
	ld   [sBGTmpPtr+1], a
	ld   a, SCRUPD_CREDITSBOX
	ld   [sScreenUpdateMode], a
	ret
	
; =============== Credits_Mode_BlankBoxRow2 ===============
; Blanks the second row of text in the credits in multiple frames.
; This blanks out range $9A00-$9AFF in the tilemap.
Credits_Mode_BlankBoxRow2:
	;
	; Update tilemap ptr to point to the next line to blank. 
	; sBGTmpPtr += BG_TILECOUNT_H
	;
	ld   a, [sBGTmpPtr]		; HL = sBGTmpPtr + $20
	ld   h, a
	ld   a, [sBGTmpPtr+1]
	ld   l, a
	ld   de, BG_TILECOUNT_H
	add  hl, de
	
	; If we went past the end of the area to blank ($9AFF), stop
	ld   a, h
	cp   a, HIGH(vBGCreditsBoxBlankRow2_End)
	jr   z, .endMode
.blankNext:
	; Otherwise, save the updated row pointer
	ld   [sBGTmpPtr], a
	ld   a, l
	ld   [sBGTmpPtr+1], a
	; And blank that line out
	ld   a, SCRUPD_CREDITSBOX
	ld   [sScreenUpdateMode], a
	ret
.endMode:
	; Prepare to write new text (switch to Credits_Mode_InitWriteRow2 next)
	ld   a, GM_CREDITS_INITWRITEROW2
	ld   [sCreditsMode], a
	ret
	
; =============== Credits_Mode_ScrollOutBothRows ===============
; Scrolls off both rows of text with a vertical effect.
Credits_Mode_ScrollOutBothRows:

	;
	; By further scrolling the viewport down, the text moves up and gets
	; progressively "cut off" until it disappears.
	; 
	ld   a, [sParallaxY0]		; sParallaxY0++
	add  $01
	ld   [sParallaxY0], a
	ld   a, [sParallaxY1]		; sParallaxY1++
	add  $01
	ld   [sParallaxY1], a
	cp   a, $38					; sParallaxY1 < $38?
	ret  c						; If so, jump
.nextMode:
	;
	; After it's scrolled out of view, request to redraw the entire
	; textbox area, which deletes all lines of text.
	;
	ldh  a, [hScrollY]			; Reset scrolling for new effect
	ldh  [rSCY], a
	ld   a, [sScrollX]			
	ldh  [rSCX], a
	jp   Credits_SwitchToBlankBox	; New mode
	
; =============== Credits_Mode_WaitBeforeLastMessage ===============
; Waits 1024 frames before scrolling out both rows.
; Then it sets up the last lines to display, depending on the ending
; (the last lines can be either "PERFECT GAME!" or "PLEASE RETRY!").
;
; Meant to be used before scrolling to the last message.
Credits_Mode_WaitBeforeLastMessage:
	;--
	;
	; Wait 1024 frames in total while displaying the text.
	;
	
	; Every 4 frames...
	ld   a, [sTimer]
	and  a, $03
	ret  nz
	; Wait $FF frames before continuing
	ld   a, [sEndingWaitTimer]
	inc  a
	ld   [sEndingWaitTimer], a
	ret  nz
	;--
.nextMode:
	xor  a									; Reset timer
	ld   [sEndingWaitTimer], a
	ld   a, GM_CREDITS_SCROLLOUTBOTHROWS	; New mode
	ld   [sCreditsMode], a
	
	;
	; Depending on the ending type, pick a different line.
	;
	ld   a, [sTrRoomMoneybagCount]
	cp   a, $06						; Do we have 6 moneybags? (perfect ending)
	ret  nz							; If not, return
	; Otherwise, skip the line definition of "PLEASE RETRY!" and
	; use "PERFECT GAME" instead.
	ld   a, [sCreditsRow1LineId]	; Use "PERFECT"
	inc  a
	ld   [sCreditsRow1LineId], a
	ld   a, [sCreditsRow2LineId]	; Use "GAME!"
	inc  a
	ld   [sCreditsRow2LineId], a
	
	ret
	
; =============== Credits_Mode_Halt ===============
; Halts the game indefinitely on the last line of text.
Credits_Mode_Halt:
	; [POI] After a ridiculously long amount of time, restart the credits music.
	;       You have to wait $4000 frames (around 273 sec).
	ld   a, [sTimer]
	and  a, $3F
	ret  nz
	ld   a, [sEndingWaitTimer]
	inc  a
	ld   [sEndingWaitTimer], a
	ret  nz
	;--
.restartBGM:
	xor  a
	ld   [sEndingWaitTimer], a
	ld   a, BGM_CREDITS
	ld   [sBGMSet], a
	ret
	
; =============== Ending_TrRoom_WriteLevelCoins4DigitBG ===============
; Updates the *3* digits of the level coin counter in the tilemap.
; This overwrites the "X" tile, and is specifically used when writing the value
; of a treasure (and counting down the coins), since there's normally only
; space for 3 digits, but treasures are worth up to 9000.
Ending_TrRoom_WriteLevelCoins4DigitBG:
	mWaitForNewHBlank
	
	ld   hl, vBGTrRoomLevelCoinsSep
	
	; Digit 4 -- thousands
	ld   a, [sLevelCoins_High]	; A = sLevelCoins_High >> 4
	ld   b, a
	swap a
	and  a, $0F
	add  TRROOM_TILEID_DIGITS
	ldi  [hl], a
	
	; Digit 3 -- hundreds ...
	ld   a, b
	
; =============== Ending_TrRoom_WriteLevelCoinsDigitBG ===============
; IN
; - B: Must be sLevelCoins_High
; - HL: Ptr to first digit of coin count.
Ending_TrRoom_WriteLevelCoinsDigitBG:
	; Separate each nybble of the level/treasure coin counter.
	; The digits in the 8x8 coin counter start at tile ID $D0, so
	; the single digit can be added to that.
	
	; Digit 3 -- hundreds
	and  a, $0F		; A = sLevelCoins_High & $0F
	add  TRROOM_TILEID_DIGITS
	ldi  [hl], a
	
	; Digit 2 -- tens
	ld   a, [sLevelCoins_Low]	; A = sLevelCoins_Low >> 4
	ld   b, a
	swap a
	and  a, $0F
	add  TRROOM_TILEID_DIGITS
	ldi  [hl], a
	
	; Digit 1
	ld   a, b					; A = sLevelCoins_Low >> 4
	and  a, $0F
	add  TRROOM_TILEID_DIGITS
	ld   [hl], a
	ret
	
; =============== Ending_TrRoom_WriteLevelCoins3DigitBG ===============
; Updates the 3 digits of the level coin counter in the tilemap.
Ending_TrRoom_WriteLevelCoins3DigitBG:
	mWaitForNewHBlank
	; Set initial addresses for Ending_TrRoom_WriteLevelCoinsDigitBG
	ld   hl, vBGTrRoomLevelCoins
	ld   a, [sLevelCoins_High]
	jr   Ending_TrRoom_WriteLevelCoinsDigitBG
	
; =============== Map_BlinkLevel_Init ===============
; Initializes the blink status for the save file.
Map_BlinkLevel_Init:
	xor  a
	; For each treasure ID, fill in the array with the blink staus
	ld   [sTreasureId], a
.loop:
	ld   a, [sTreasureId]	; Id++ (offset by 1)
	inc  a
	; Did we go past the last valid ID?
	; If so, we're done
	cp   a, (Map_BlinkLevel_Set.ptrEnd - Map_BlinkLevel_Set.ptrStart + 2) / 2
	ret  z
	;--
	ld   [sTreasureId], a
	call Map_IsTreasureCollected	; Is the treasure the blink refers to collected?
	call z, Map_BlinkLevel_Set		; If not, set it to the display list
	;--
	jr   .loop
	
; =============== Map_BlinkLevel_Set ===============
; Enables/Writes the blink status for the currently processed treasure id.
; This is only done for levels with uncollected treasure.
;
; The Level ID set for every entry must be present in Map_BlinkLevel_AssocTbl (BANK $14).
Map_BlinkLevel_Set:
	ld   a, [sTreasureId]
	dec  a							; Indexes start on $01
	rst  $28
	.ptrStart:
	dw .treasureC ; - c11
	dw .treasureI ; - c26
	dw .treasureF ; - c18
	dw .treasureO ; - c39
	dw .treasureA ; - c03
	dw .treasureN ; - c37
	dw .treasureH ; - c24
	dw .treasureM ; - c34
	dw .treasureL ; - c31
	dw .treasureK ; - c30
	dw .treasureB ; - c09
	dw .treasureD ; - c16
	dw .treasureG ; - c20
	dw .treasureJ ; - c29
	dw .treasureE ; - c17
	.ptrEnd:
.treasureC:
	ld   hl, sMapMtTeapotBlink
	ld   b, LVL_C11
	jr   .findFreeSlot
.treasureI:
	ld   hl, sMapSSTeacupBlink
	ld   b, LVL_C26
	jr   .findFreeSlot
.treasureF:
	ld   hl, sMapSherbetLandBlink
	ld   b, LVL_C18
	jr   .findFreeSlot
.treasureO:
	ld   hl, sMapSyrupCastleBlink
	ld   b, LVL_C39
	jr   .findFreeSlot
.treasureA:
	ld   hl, sMapRiceBeachBlink
	ld   b, LVL_C03B
	jr   .findFreeSlot
.treasureN:
	ld   hl, sMapSyrupCastleBlink
	ld   b, LVL_C37
	jr   .findFreeSlot
.treasureH:
	ld   hl, sMapStoveCanyonBlink
	ld   b, LVL_C24
	jr   .findFreeSlot
.treasureM:
	ld   hl, sMapParsleyWoodsBlink
	ld   b, LVL_C34
	jr   .findFreeSlot
.treasureL:
	ld   hl, sMapParsleyWoodsBlink
	ld   b, LVL_C31B
	jr   .findFreeSlot
.treasureK:
	ld   hl, sMapSSTeacupBlink
	ld   b, LVL_C30
	jr   .findFreeSlot
.treasureB:
	ld   hl, sMapMtTeapotBlink
	ld   b, LVL_C09
	jr   .findFreeSlot
.treasureD:
	ld   hl, sMapSherbetLandBlink
	ld   b, LVL_C16
	jr   .findFreeSlot
.treasureG:
	ld   hl, sMapStoveCanyonBlink
	ld   b, LVL_C20
	jr   .findFreeSlot
.treasureJ:
	ld   hl, sMapSSTeacupBlink
	ld   b, LVL_C29
	jr   .findFreeSlot
.treasureE:
	ld   hl, sMapSherbetLandBlink
	ld   b, LVL_C17
	
	; Find the first free slot in the blink array (one with value $FF)
	; Once found, replace it with the LevelId specified in B.
.findFreeSlot:
	ld   a, [hl]
	cp   a, $FF
	jr   z, .end
	inc  l
	jr   .findFreeSlot
.end:
	ld   [hl], b
	ret
	
; =============== Map_IsTreasureCollected ===============
; This subroutine checks if the currently set Treasure ID is marked as
; collected.
; 
; In the map screen, this is used to determine if any blinking dot
; should be visible.
; 
; OUT:
; - Z: If set, the treasure isn't collected
Map_IsTreasureCollected:
	; NOTE: sTreasureId is offset by 1
	ld   hl, sTreasures
	ld   a, [sTreasureId]
	dec  a			; C11
	jr   z, .chk1
	dec  a			; C26
	jp   z, .chk2
	dec  a			; C18
	jp   z, .chk3
	dec  a			; C39
	jr   z, .chk4
	dec  a			; C03
	jr   z, .chk5
	dec  a			; C37
	jr   z, .chk6
	dec  a			; C24
	jr   z, .chk7
	
	ld   hl, sTreasures+1
	dec  a			; C34
	jr   z, .chk0
	dec  a			; C31
	jr   z, .chk1
	dec  a			; C30
	jr   z, .chk2
	dec  a			; C09
	jr   z, .chk3
	dec  a			; C16
	jr   z, .chk4
	dec  a			; C20
	jr   z, .chk5
	dec  a			; C29
	jr   z, .chk6
	dec  a			; C17
	jr   z, .chk7
	; We never get here
	ret
.chk1:
	bit  1, [hl]
	ret
.chk2:
	bit  2, [hl]
	ret
.chk3:
	bit  3, [hl]
	ret
.chk4:
	bit  4, [hl]
	ret
.chk5:
	bit  5, [hl]
	ret
.chk6:
	bit  6, [hl]
	ret
.chk7:
	bit  7, [hl]
	ret
.chk0:
	bit  0, [hl]
	ret
	
; =============== Treasure_MarkAsUncollected ===============
; Marks the specified Treasure ID as uncollected.
Treasure_MarkAsUncollected:
	; Check which bit of which bitmask we're dealing with
	ld   hl, sTreasures
	ld   a, [sTreasureId]
	dec  a
	jr   z, .clr1
	dec  a
	jp   z, .clr2
	dec  a
	jp   z, .clr3
	dec  a
	jr   z, .clr4
	dec  a
	jr   z, .clr5
	dec  a
	jr   z, .clr6
	dec  a
	jr   z, .clr7
	
	; Check in the second bitmask
	ld   hl, sTreasures+1
	dec  a
	jr   z, .clr0
	dec  a
	jr   z, .clr1
	dec  a
	jr   z, .clr2
	dec  a
	jr   z, .clr3
	dec  a
	jr   z, .clr4
	dec  a
	jr   z, .clr5
	dec  a
	jr   z, .clr6
	dec  a
	jr   z, .clr7
	ret  
.clr1:
	res  1, [hl]
	ret  
.clr2:	
	res  2, [hl]
	ret  
.clr3:
	res  3, [hl]
	ret 
.clr4:
	res  4, [hl]
	ret 
.clr5:
	res  5, [hl]
	ret 
.clr6:                
	res  6, [hl]
	ret  
.clr7:                 
	res  7, [hl]
	ret 
.clr0: 	
	res  0, [hl]
	ret
	
; =============== ExActS_SpawnTreasure ===============
; Spawns the treasure actor with different options (frame, coords) depending
; on the currently set treasure ID.
;
; IN
; - B: ExActor ID spawned, which mostly tells the path it takes. It can be either:
;      - EXACT_TREASUREENDING for the treasure moving left to the player
;      - EXACT_TREASURELOST for the treasure flying out in the Game Over screen.
;      Note that the remaining treasure type, EXACT_TREASUREGET is spawned by a different subroutine.
ExActS_SpawnTreasure:
	ld   a, [sTreasureId]
	dec  a					; Index it
	rst  $28
	dw .treasureC
	dw .treasureI
	dw .treasureF
	dw .treasureO
	dw .treasureA
	dw .treasureN
	dw .treasureH
	dw .treasureM
	dw .treasureL
	dw .treasureK
	dw .treasureB
	dw .treasureD
	dw .treasureG
	dw .treasureJ
	dw .treasureE
	
	; All of these follow this template
.treasureA:
	ld   a, b						; Actor ID
	ld   [sExActSet], a
	ld   a, $68						; Initial Y pos (should be consistent with tilemap coord)	
	ld   [sExActOBJFixY], a
	ld   a, $50						; Initial X pos (should be consistent with tilemap coord)	
	ld   [sExActOBJFixX], a
	xor  a							; Row number of the treasure
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_A0	; Frame ID
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureA		; Treasure block location in tilemap (to make .spawn replace it with an empty space)
	jr   .spawn
.treasureB:
	ld   a, b
	ld   [sExActSet], a
	ld   a, $68
	ld   [sExActOBJFixY], a
	ld   a, $60
	ld   [sExActOBJFixX], a
	xor  a
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_B0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureB
	jr   .spawn
.treasureC:
	ld   a, b
	ld   [sExActSet], a
	ld   a, $68
	ld   [sExActOBJFixY], a
	ld   a, $70
	ld   [sExActOBJFixX], a
	xor  a
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_C0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureC
	jr   .spawn
.treasureD:
	ld   a, b
	ld   [sExActSet], a
	ld   a, $68
	ld   [sExActOBJFixY], a
	ld   a, $80
	ld   [sExActOBJFixX], a
	xor  a
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_D0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureD
	jr   .spawn
.treasureE:
	ld   a, b
	ld   [sExActSet], a
	ld   a, $68
	ld   [sExActOBJFixY], a
	ld   a, $90
	ld   [sExActOBJFixX], a
	xor  a
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_E0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureE
.spawn:
	; With the value of HL specifying which block to replace...
	ld   a, TRROOM_BLOCKID_TREASURE_EMPTY	; Replace treasure block with empty space
	call Level_WriteBlockToBG
	
	ld   hl, sExActOBJY_High	; Seek to byte 1
	xor  a
	ldi  [hl], a				; Y coord (high) -- not used
	ldi  [hl], a                ; Y coord (low) -- not used
	ldi  [hl], a                ; X coord (high) -- not used
	ldi  [hl], a                ; X coord (low) -- not used
	inc  l						; We've set sExActOBJLstId already
	ld   a, $10					; Flags
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	inc  l						; Skip Rel.Y
	inc  l						; Skip Rel.X
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	call ExActS_Spawn
	ret
.treasureF:;I
	ld   a, b
	ld   [sExActSet], a
	ld   a, $78
	ld   [sExActOBJFixY], a
	ld   a, $50
	ld   [sExActOBJFixX], a
	ld   a, $01
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_F0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureF
	jr   .spawn
.treasureG:;I
	ld   a, b
	ld   [sExActSet], a
	ld   a, $78
	ld   [sExActOBJFixY], a
	ld   a, $60
	ld   [sExActOBJFixX], a
	ld   a, $01
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_G0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureG
	jr   .spawn
.treasureH:;I
	ld   a, b
	ld   [sExActSet], a
	ld   a, $78
	ld   [sExActOBJFixY], a
	ld   a, $70
	ld   [sExActOBJFixX], a
	ld   a, $01
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_H0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureH
	jr   .spawn
.treasureI:;I
	ld   a, b
	ld   [sExActSet], a
	ld   a, $78
	ld   [sExActOBJFixY], a
	ld   a, $80
	ld   [sExActOBJFixX], a
	ld   a, $01
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_I0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureI
	jp   .spawn
.treasureJ:;I
	ld   a, b
	ld   [sExActSet], a
	ld   a, $78
	ld   [sExActOBJFixY], a
	ld   a, $90
	ld   [sExActOBJFixX], a
	ld   a, $01
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_J0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureJ
	jp   .spawn
.treasureK:;I
	ld   a, b
	ld   [sExActSet], a
	ld   a, $88
	ld   [sExActOBJFixY], a
	ld   a, $50
	ld   [sExActOBJFixX], a
	ld   a, $02
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_K0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureK
	jp   .spawn
.treasureL:;I
	ld   a, b
	ld   [sExActSet], a
	ld   a, $88
	ld   [sExActOBJFixY], a
	ld   a, $60
	ld   [sExActOBJFixX], a
	ld   a, $02
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_L0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureL
	jp   .spawn
.treasureM:;I
	ld   a, b
	ld   [sExActSet], a
	ld   a, $88
	ld   [sExActOBJFixY], a
	ld   a, $70
	ld   [sExActOBJFixX], a
	ld   a, $02
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_M0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureM
	jp   .spawn
.treasureN:;I
	ld   a, b
	ld   [sExActSet], a
	ld   a, $88
	ld   [sExActOBJFixY], a
	ld   a, $80
	ld   [sExActOBJFixX], a
	ld   a, $02
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_N0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureN
	jp   .spawn
.treasureO:;I
	ld   a, b
	ld   [sExActSet], a
	ld   a, $88
	ld   [sExActOBJFixY], a
	ld   a, $90
	ld   [sExActOBJFixX], a
	ld   a, $02
	ld   [sExActTreasureRow], a
	ld   a, OBJ_TRROOM_TREASURE_O0
	ld   [sExActOBJLstId], a
	ld   hl, vBGTrRoomTreasureO
	jp   .spawn
	
; =============== Mode_Treasure ===============
Mode_Treasure:
	ld   a, [sSubMode]
	rst  $28
	dw Mode_Treasure_Init
	dw Level_FadeOutOBJ0ToBlack
	dw Level_FadeOutBGToWhite
	dw Mode_Treasure_InitTrRoom
	dw Mode_Treasure_TrRoom
; =============== Mode_Treasure_Init ===============
; Prepares the fade out to the treasure room.
Mode_Treasure_Init:
	call HomeCall_WriteWarioOBJLst
	ld   a, $01						; Like in room transitions, pause the actors
	ld   [sPauseActors], a
	call HomeCall_ActS_Do			; Draw them
	ld   a, GM_TREASURE_FADEOUTOBJ	; Next mode
	ld   [sSubMode], a
	ret
	
; =============== Mode_Treasure_InitTrRoom ===============
; Initializes the treasure room.
; See also: Mode_LevelClear_InitTrRoom
Mode_Treasure_InitTrRoom:
	call StopLCDOperation
	call ClearWorkOAM
	call ExActS_ClearRAM
	call HomeCall_LoadVRAM_Treasure_TreasureRoom
	; Setup the 16x16 block update functionality
	; Unlike in Mode_LevelClear_InitTrRoom, we don't draw *any* coin digits here (neither 8x8 nor 16x16).
	; We use this exclusively to write the treasure block.
	call TrRoom_CopyBlockData
	call TrRoom_DrawTreasures
	
	xor  a					; Reset the scroll coords
	ldh  [hScrollY], a
	ld   [sScrollX], a
	ldh  [rSCY], a
	ldh  [rSCX], a
	ld   hl, rIE			; Disable parallax
	res  IB_STAT, [hl]
	
	ld   a, LCDC_ENABLE|LCDC_OBJENABLE|LCDC_PRIORITY
	ldh  [rLCDC], a
	ld   a, $E1				; Set BG palette
	ldh  [rBGP], a
	ldh  [rOBP1], a
	ld   a, $1C				; Set OBJ palette
	ldh  [rOBP0], a
	ld   a, GM_TREASURE_TRROOM	; Next mode
	ld   [sSubMode], a
	xor  a
	ld   [sTreasureTrRoomMode], a
	ret
	
	
; =============== HELPERS FOR TrRoom_DrawTreasures ===============
	
	
; =============== mTrRoom_DrawTreasure ===============
; Generates code to check for a specific treasure.
; IN
; - 1: Letter of the treasure.
; - 2: Label to bitmask containing this treasure
MACRO mTrRoom_ChkDrawTreasure
	ld   a, [\2]
	bit  TREASUREB_\1, a
	call nz, TrRoom_DrawTreasure\1
ENDM

; =============== mTrRoom_DrawTreasure ===============
; Generates code to draw a specific treasure in the treasure room.
; IN
; - 1: Block ID of the treasure (relative to LevelBlock_TrRoom)
; - 2: Ptr to table with 4 VRAM Pointers (one for each 8x8 tile in the standard order)
MACRO mTrRoom_DrawTreasure
	ld   a, \1							; Set block ID
	call Level_Scroll_SetOnlyBlockID	
	call Level_Scroll_CreateTileIdList	; Get the 4 tiles from that
	ld   hl, \2							; HL = VRAM ptrs for each of the 4 tiles
	call Level_Scroll_Write4Tiles		; Write the 4 tiles to the tilemap
	ret
ENDM

; =============== dvbgblock ===============
; Defines the VRAM tilemap pointers for a 16x16 block (block16).
; IN
; - 1: Tilemap address for the top-left 8x8 tile.
MACRO dvbgblock
	dwb \1+$00 ; TOP-LEFT
	dwb \1+$01 ; TOP-RIGHT
	dwb \1+BG_TILECOUNT_H+$00 ; BOTTOM-LEFT
	dwb \1+BG_TILECOUNT_H+$01 ; BOTTOM-RIGHT
ENDM
	
; =============== TrRoom_DrawTreasures ===============
; Draws all of the collected treasures over the letters.
TrRoom_DrawTreasures:
	; Write to the tilemap each treasure individually and immediately
	mTrRoom_ChkDrawTreasure C, sTreasures
	mTrRoom_ChkDrawTreasure I, sTreasures
	mTrRoom_ChkDrawTreasure F, sTreasures
	mTrRoom_ChkDrawTreasure O, sTreasures
	mTrRoom_ChkDrawTreasure A, sTreasures
	mTrRoom_ChkDrawTreasure N, sTreasures
	mTrRoom_ChkDrawTreasure H, sTreasures
	mTrRoom_ChkDrawTreasure M, sTreasures+1
	mTrRoom_ChkDrawTreasure L, sTreasures+1
	mTrRoom_ChkDrawTreasure K, sTreasures+1
	mTrRoom_ChkDrawTreasure B, sTreasures+1
	mTrRoom_ChkDrawTreasure D, sTreasures+1
	mTrRoom_ChkDrawTreasure G, sTreasures+1
	mTrRoom_ChkDrawTreasure J, sTreasures+1
	mTrRoom_ChkDrawTreasure E, sTreasures+1
	
	xor  a							; We're done updating the screen
	ld   [sScreenUpdateMode], a
	ldh  a, [rDIV]					; Randomize the next index
	ld   [sTrRoomSparkleIndex], a
	ret

TrRoom_DrawTreasureC: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_C, TrRoom_TreasureC_BGPtrTbl
TrRoom_DrawTreasureI: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_I, TrRoom_TreasureI_BGPtrTbl
TrRoom_DrawTreasureF: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_F, TrRoom_TreasureF_BGPtrTbl
TrRoom_DrawTreasureO: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_O, TrRoom_TreasureO_BGPtrTbl
TrRoom_DrawTreasureA: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_A, TrRoom_TreasureA_BGPtrTbl
TrRoom_DrawTreasureN: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_N, TrRoom_TreasureN_BGPtrTbl
TrRoom_DrawTreasureH: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_H, TrRoom_TreasureH_BGPtrTbl
TrRoom_DrawTreasureM: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_M, TrRoom_TreasureM_BGPtrTbl
TrRoom_DrawTreasureL: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_L, TrRoom_TreasureL_BGPtrTbl
TrRoom_DrawTreasureK: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_K, TrRoom_TreasureK_BGPtrTbl
TrRoom_DrawTreasureB: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_B, TrRoom_TreasureB_BGPtrTbl
TrRoom_DrawTreasureD: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_D, TrRoom_TreasureD_BGPtrTbl
TrRoom_DrawTreasureG: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_G, TrRoom_TreasureG_BGPtrTbl
TrRoom_DrawTreasureJ: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_J, TrRoom_TreasureJ_BGPtrTbl
TrRoom_DrawTreasureE: mTrRoom_DrawTreasure TRROOM_BLOCKID_TREASURE_E, TrRoom_TreasureE_BGPtrTbl

TrRoom_TreasureA_BGPtrTbl: dvbgblock vBGTrRoomTreasureA
TrRoom_TreasureB_BGPtrTbl: dvbgblock vBGTrRoomTreasureB
TrRoom_TreasureC_BGPtrTbl: dvbgblock vBGTrRoomTreasureC
TrRoom_TreasureD_BGPtrTbl: dvbgblock vBGTrRoomTreasureD
TrRoom_TreasureE_BGPtrTbl: dvbgblock vBGTrRoomTreasureE
TrRoom_TreasureF_BGPtrTbl: dvbgblock vBGTrRoomTreasureF
TrRoom_TreasureG_BGPtrTbl: dvbgblock vBGTrRoomTreasureG
TrRoom_TreasureH_BGPtrTbl: dvbgblock vBGTrRoomTreasureH
TrRoom_TreasureI_BGPtrTbl: dvbgblock vBGTrRoomTreasureI
TrRoom_TreasureJ_BGPtrTbl: dvbgblock vBGTrRoomTreasureJ
TrRoom_TreasureK_BGPtrTbl: dvbgblock vBGTrRoomTreasureK
TrRoom_TreasureL_BGPtrTbl: dvbgblock vBGTrRoomTreasureL
TrRoom_TreasureM_BGPtrTbl: dvbgblock vBGTrRoomTreasureM
TrRoom_TreasureN_BGPtrTbl: dvbgblock vBGTrRoomTreasureN
TrRoom_TreasureO_BGPtrTbl: dvbgblock vBGTrRoomTreasureO

; =============== Level_Scroll_SetOnlyBlockID ===============
; This subroutine sets a single block ID to the block ID write list.
;
; Calling this replaces the entire list with the specified block ID
; plus an end separator.
;
; Specifically used only to draw Treasures in the Treasure Room, which
; are drawn one by one so it isn't a problem replacing the entire list.
;
; IN
; - A: Block ID to write
Level_Scroll_SetOnlyBlockID:
	ld   hl, sLvlScrollBlockTable	; HL = Start of blockid table
	ldi  [hl], a					; Write block id
	; Note that the subroutine which writes the tiles, Level_Scroll_Write4Tiles,
	; does not need an end separator. This line can be removed.
	ld   [hl], $FF					; Write terminator
	ret

; =============== Level_Scroll_Write4Tiles ===============
; This subroutine writes a block to the tilemap, using similar rules as ScreenEvent_Mode_LevelScroll.
;
; The same tables used by ScreenEvent_Mode_LevelScroll are also used here for similar purposes, however:
; - The table containing tilemap pointers is expected to have four addresses,
;   one for each tile, unlike ScreenEvent_Mode_LevelScroll where only the address
;   for the block's top-left tile is used (and the other 3 are calculated automatically from it).
; - We actually pass said table as parameter to this subroutine.
;   In ScreenEvent_Mode_LevelScroll, they are expected at the fixed location sLvlScrollBGPtrWriteTable.
; - Because the number of written tiles is hardcoded, none of the tables passed
;   through HL contain the end separator $FF.
;
; IN
; - HL: Table of VRAM pointers for each of the 4 tiles in the block (must be $08 bytes long)
Level_Scroll_Write4Tiles:
	ld   de, sLvlScrollTileIdWriteTable	; DE = Tile IDs to use (in groups of 4 8x8 tiles)
	
	;
	; TOP-LEFT TILE
	;
	; Read from ptr table at HL the address of the block in the tilemap
	; This is basically the 8x8 tile offset of the block's top left corner
	; (Note that these pointers are in big-endian format)
	ldi  a, [hl]	; BC = VRAM Ptr
	ld   b, a
	ldi  a, [hl]
	ld   c, a
	
	ld   a, [de]	; Read the tile ID
	ld   [bc], a	; Write it to the tilemap
	inc  de			; Next tile
	
	;
	; TOP-RIGHT TILE
	;
	ldi  a, [hl]	; BC = Next VRAM Ptr
	ld   b, a
	ldi  a, [hl]
	ld   c, a
	
	ld   a, [de]	; Read the tile ID
	ld   [bc], a	; Write it to the tilemap
	inc  de			; Next tile
	
	;
	; BOTTOM-LEFT TILE
	;
	ldi  a, [hl]	; BC = Next VRAM Ptr
	ld   b, a
	ldi  a, [hl]
	ld   c, a
	ld   a, [de]	; Read the tile ID
	ld   [bc], a	; Write it to the tilemap
	inc  de			; Next tile
	
	;
	; BOTTOM-RIGHT TILE
	;
	ldi  a, [hl]	; BC = Next VRAM Ptr
	ld   b, a
	ldi  a, [hl]
	ld   c, a
	ld   a, [de]	; Read the tile ID
	ld   [bc], a	; Write it to the tilemap
	
	ret
	
; =============== Mode_Treasure_TrRoom ===============
Mode_Treasure_TrRoom:
	call .main
	call HomeCall_NonGame_WriteWarioOBJLst
	call HomeCall_ExActS_ExecuteAll
	ret
.main:
	ld   a, [sTreasureTrRoomMode]
	rst  $28
	dw Mode_Treasure_TrRoom_WalkInR
	dw Mode_Treasure_TrRoom_PlAction
	dw Mode_Treasure_TrRoom_MoveDownAndCollect
	dw Mode_Treasure_TrRoom_WaitTreasure
	dw Mode_Treasure_TrRoom_WalkOutL
	
; =============== Mode_Treasure_TrRoom_WalkInR ===============
; Wario walks right from off-screen.
Mode_Treasure_TrRoom_WalkInR:
	;
	; Walk right until we reach X pos $28.
	; This is to the left of the box with treasures.
	;
	call NonGame_Wario_AnimWalk			; Animate walk cycle
	ld   a, [sPlXRel]					; PlX++;
	inc  a
	ld   [sPlXRel], a
	cp   a, $28							; PlX != $28?
	ret  nz								; If so, we didn't get there yet

	; After we finish moving...
	;
	; Determine the player frame to use when inserting the treasure.
	; If it's on the third row we have to duck, otherwise we can stand normally.
	;
	ld   a, OBJ_WARIO_HOLD				; Set stand frame
	ld   [sPlLstId], a
	call TrRoom_GetTreasureRowNum		; Set row num to sExActTreasureRow
	ld   a, [sExActTreasureRow]
	cp   a, $02							; Is the treasure on the third row?
	jr   nz, .nextMode					; If not, jump
.setDuckFrame:
	ld   a, $01							; Set duck mode
	ld   [sPlDuck], a
	ld   a, OBJ_WARIO_DUCKHOLD			; Set duck frame
	ld   [sPlLstId], a
.nextMode:
	xor  a
	ld   [sPlAnimTimer], a
	ld   a, [sTreasureTrRoomMode]		; Next mode
	inc  a
	ld   [sTreasureTrRoomMode], a
	ld   a, BGM_WORLDCLEAR				; Play Treasure Get BGM
	ld   [sBGMSet], a
	ld   a, $40							; Allow jump/duck anim to last $40 frames
	ld   [sPlDelayTimer], a
	ret
	
; =============== TrRoom_GetTreasureRowNum ===============
; Gets a 0-indexed row number for the current treasure.
; This updates the value of sExActTreasureRow.
TrRoom_GetTreasureRowNum:
	ld   a, [sTreasureId]
	dec  a
	rst  $28
	dw .row1 ; TREASURE_C
	dw .row2 ; TREASURE_I
	dw .row2 ; TREASURE_F
	dw .row3 ; TREASURE_O
	dw .row1 ; TREASURE_A
	dw .row3 ; TREASURE_N
	dw .row2 ; TREASURE_H
	dw .row3 ; TREASURE_M
	dw .row3 ; TREASURE_L
	dw .row3 ; TREASURE_K
	dw .row1 ; TREASURE_B
	dw .row1 ; TREASURE_D
	dw .row2 ; TREASURE_G
	dw .row2 ; TREASURE_J
	dw .row1 ; TREASURE_E
.row1:
	xor  a
	ld   [sExActTreasureRow], a
	ret
.row2:
	ld   a, $01
	ld   [sExActTreasureRow], a
	ret
.row3:
	ld   a, $02
	ld   [sExActTreasureRow], a
	ret
; =============== NonGame_Wario_AnimWalk ===============
; Animates Wario's walk cycle at a normal speed for non-static modes outside of gameplay.
; See also: NonGame_Wario_AnimWalkFast.
NonGame_Wario_AnimWalk:
	call Wario_PlayWalkSFX_Norm
	
	; Perform every four frames
	ld   a, [sTimer]
	and  a, $03
	ret  nz
	
	; Use the anim timer as the index to the offset table
	ld   hl, OBJLstAnimOff_Wario_Walk
	ld   a, [sPlAnimTimer]				; Index++
	inc  a
	; If we reached the end of the table, reset the index
	cp   a, (OBJLstAnimOff_Wario_Walk.end - OBJLstAnimOff_Wario_Walk)
	jr   nz, .setFrame
	xor  a
.setFrame:
	; Index the table
	ld   [sPlAnimTimer], a
	ld   e, a				; DE = Index
	ld   d, $00
	add  hl, de
	; Add the offset to the current frame id
	ld   a, [sPlLstId]
	add  [hl]			; LstId += Offset
	ld   [sPlLstId], a
	ret
; =============== Unused_OBJLstAnimOff_Wario_WalkFast ===============
; [TCRF] Unused animation script.
;        Considering this is right after NonGame_Wario_AnimWalk, it must
;        have been intended for the fast walking animation... but that
;        reuses OBJLstAnimOff_Wario_Walk, leaving this unreferenced.
;        It's also identical to NonGame_Wario_AnimWalk anyway.
Unused_OBJLstAnimOff_Wario_WalkFast: 
	db -$02,+$01,+$01,-$02,+$03,-$01
.end:
	
; =============== Mode_Treasure_TrRoom_PlAction ===============
Mode_Treasure_TrRoom_PlAction:
	;
	; After $40 frames, end this animation
	;
	ld   a, [sPlDelayTimer]		; Timer2--
	dec  a
	ld   [sPlDelayTimer], a		; Timer2 == $00?
	jr   z, .nextMode		; If so, jump
	
	; During those frames...
.animPl:
	;
	; Do a different action depending on the row the treasure should move to.
	;
	
	ld   a, [sExActTreasureRow]
	dec  a					; Row == $01? (2nd row)
	jr   z, .row2			; If so, jump
	dec  a					; Row == $02? (3rd row)
	jr   z, .row3			; If so, jump
.row1:						; Otherwise, Row == $00 (1st row)
	;
	; First row - Wait $40-$0D frames.
	;             Then jump up at 2px/frame for $0D frames.
	;
	ld   a, [sPlDelayTimer]		
	cp   a, $0D				; Timer2 >= $0D?
	ret  nc					; If so, don't move yet
	ld   a, [sPlYRel]		; Move up 2px/frame
	sub  a, $02
	ld   [sPlYRel], a
	ld   a, OBJ_WARIO_HOLDJUMP
	ld   [sPlLstId], a
	ret
.row2:
	;
	; Second row - Wait $40-$05 frames.
	;              Then jump up at 2px/frame for $0D frames.
	;
	ld   a, [sPlDelayTimer]
	cp   a, $05				; Timer2 >= $05?
	ret  nc					; If so, don't move yet
	ld   a, [sPlYRel]		; Move up 2px/frame
	sub  a, $02
	ld   [sPlYRel], a
	ld   a, OBJ_WARIO_HOLDJUMP
	ld   [sPlLstId], a
	ret
.row3:
	ret						; Don't move
.nextMode:
	ld   a, [sTreasureTrRoomMode]	; Next mode
	inc  a
	ld   [sTreasureTrRoomMode], a
	ld   a, $04						; Wait 4 frames before falling down
	ld   [sTrRoomWaitTimer], a
	
	; Set correct throw frame
	ld   a, OBJ_WARIO_JUMPTHROW
	ld   [sPlLstId], a
	ld   a, [sExActTreasureRow]
	cp   a, $02						; Are we ducking?
	ret  nz							; If not, return
	ld   a, OBJ_WARIO_DUCKTHROW
	ld   [sPlLstId], a
	ret
	
	
; =============== Mode_Treasure_TrRoom_MoveDownAndCollect ===============
; Makes the player land from the jump, then the player collects the treasure.
Mode_Treasure_TrRoom_MoveDownAndCollect:

	;
	; Wait the specified number of frames before continuing.
	; When we get here in the jump frame, this is used to give the "delay"
	; before down, like how it appears during gameplay.
	;
	ld   a, [sTrRoomWaitTimer]
	and  a
	jr   z, .chkMoveDown
	dec  a
	ld   [sTrRoomWaitTimer], a
	ret

.chkMoveDown:

	;
	; If we aren't on the ground, move down before continuing.
	;
	ld   a, [sPlYRel]
	cp   a, $98			; YPos == $98?
	jr   z, .landed		; If so, we're on the ground
	add  $02			; Otherwise, move down 2px/frame
	ld   [sPlYRel], a
	ret
.landed:

	ld   a, OBJ_TRROOM_WARIO_IDLE0	; Stand
	ld   [sPlLstId], a
	xor  a							; Stop ducking, if set
	ld   [sPlDuck], a
	ld   a, [sTreasureTrRoomMode]	; Next mode
	inc  a
	ld   [sTreasureTrRoomMode], a
	; Wait enough time for the treasure to move itself to position
	; while the next mode goes on.
	ld   a, $C0						
	ld   [sTrRoomWaitTimer], a
	; Mark the treasure as collected
	call Treasure_MarkAsCollected
	ret
	
; =============== Mode_Treasure_TrRoom_WaitTreasure ===============
; Waits for the treasure to move before saving the game.
Mode_Treasure_TrRoom_WaitTreasure:

	;
	; Wait $C0 frames while the treasure moves itself
	; and Wario continues animating itself.
	;
	ld   a, [sTrRoomWaitTimer]
	and  a						; Timer == 0?
	jr   z, .nextMode			; If so, jump
	dec  a						; Timer--
	ld   [sTrRoomWaitTimer], a	; Timer == 0?
	jr   z, .preWalk			; If so, jump
.idle:
	call TrRoom_AnimWarioGloat	; Continue animating Wario
	ret
.preWalk:
	ld   a, OBJ_TRROOM_WARIO_IDLE0	; Visible for one frame only!
	ld   [sPlLstId], a
	xor  a
	ld   [sPlAnimTimer], a
	ret
	
.nextMode:
	xor  a						; Not visible anyway here
	ld   [sTrRoomSparkleActive], a
	call Save_CopyAllToSave		; Save the game
	ld   a, [sTreasureTrRoomMode]	; Next mode
	inc  a
	ld   [sTreasureTrRoomMode], a
	ld   a, OBJ_WARIO_WALK0		; Init walk anim
	ld   [sPlLstId], a
	xor  a
	ld   [sPlAnimTimer], a			; Init walk anim timer
	ld   [sPlFlags], a			; Face left
	ret
	
; =============== Mode_Treasure_TrRoom_WalkOutL ===============
; Wario walk off-screen to the left.
Mode_Treasure_TrRoom_WalkOutL:

	;
	; Walk left until we get off-screen.
	;
	call NonGame_Wario_AnimWalkFast
	ld   a, [sPlXRel]	; PlX--
	dec  a
	ld   [sPlXRel], a
	cp   a, $08			; PlX != $08?
	ret  nz				; If so, return
.nextMode:
	;
	; Return to the main level.
	;
	
	; Set the room header for returning from the treasure room.
	; This always spawns the player over the chest.
	call Level_GetTreasureDoorPtr
	
	; Switch to the middle of the "door transition" mode, to
	; load in the room proper.
	ld   a, GM_LEVELDOOR
	ld   [sGameMode], a
	ld   a, GM_LEVELDOOR_ROOMLOAD
	ld   [sSubMode], a
	xor  a					; Stand
	ld   [sPlAction], a
	ret
	
; =============== Treasure_MarkAsCollected ===============
; Marks the specified Treasure ID as collected.
Treasure_MarkAsCollected:
	; Check which bit of which bitmask we're dealing with
	ld   hl, sTreasures
	ld   a, [sTreasureId]
	dec  a
	jr   z, .set1
	dec  a
	jp   z, .set2
	dec  a
	jp   z, .set3
	dec  a
	jr   z, .set4
	dec  a
	jr   z, .set5
	dec  a
	jr   z, .set6
	dec  a
	jr   z, .set7
	
	; Check in the second bitmask
	ld   hl, sTreasures+1
	dec  a
	jr   z, .set0
	dec  a
	jr   z, .set1
	dec  a
	jr   z, .set2
	dec  a
	jr   z, .set3
	dec  a
	jr   z, .set4
	dec  a
	jr   z, .set5
	dec  a
	jr   z, .set6
	dec  a
	jr   z, .set7
	ret  
.set1:
	set  1, [hl]
	ret  
.set2:	
	set  2, [hl]
	ret  
.set3:
	set  3, [hl]
	ret 
.set4:
	set  4, [hl]
	ret 
.set5:
	set  5, [hl]
	ret 
.set6:                
	set  6, [hl]
	ret  
.set7:                 
	set  7, [hl]
	ret 
.set0: 	
	set  0, [hl]
	ret
	
	
; =============== TrRoom_ChkSpawnSparkle ===============
; Attempts to spawn the sparkle over the collected treasures.
TrRoom_ChkSpawnSparkle:

	; If we don't have any treasures, don't spawn any sparkle
	ld   a, [sTreasures]		
	ld   b, a
	ld   a, [sTreasures+1]
	or   a, b
	ret  z
	
	; If there's already a sparkle visible, don't spawn another one
	ld   a, [sTrRoomSparkleActive]
	and  a
	ret  nz
	
	; Increase the ID of the position to spawn to.
	; Each treasure gets its own ID.
	;
	; Since there are exactly 15 treasures, these fit the values of a single nybble,
	; so we only need to filter away the high nybble.
	; The non-existing 16th treasure is accounted for by... returning immediately.
	; The very next frame the index will increase again, so this isn't noticeable.
	ld   a, [sTrRoomSparkleIndex]		; Index++
	inc  a
	ld   [sTrRoomSparkleIndex], a
	and  a, $0F							; Remove high nybble + Is the position id $00?
	ret  z								; If so, return
	
	; Make sure the index gets increased as much as specified in sTrRoomSparkleIndexAdd.
	; Every time we get here, the index will be increased by 1.
	;
	; Off-hand, not sure why it was done this way. Maybe to set an ever-so-slight delay
	; between sparkles?
	ld   a, [sTrRoomSparkleIndexAdd]
	and  a								; ToAdd == 0?
	jr   z, .spawn						; If so, we can spawn it
	dec  a								; ToAdd--
	ld   [sTrRoomSparkleIndexAdd], a
	ret
.spawn:
	call TrRoom_GetSparklePos			; Get sparkle coords for later to BC	
	ld   a, $01
	ld   [sTrRoomSparkleActive], a
	ld   hl, sExActSet
	ld   a, EXACT_TRROOM_SPARKLE		; ID
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	
	; There are four different animations the sparkles, each taking up 4 frames.
	; The frame IDs are sequential, so randomize the initial frame with: 
	; FrameId = OBJ_TRROOM_STAR00 + ((rDiv % 4) * 4)
	;
	; This means the initial frame can be any of these:
	; - OBJ_TRROOM_STAR00
	; - OBJ_TRROOM_STAR10
	; - OBJ_TRROOM_STAR20
	; - OBJ_TRROOM_STAR30
	ldh  a, [rDIV]
	and  a, $03
	add  a
	add  a
	add  OBJ_TRROOM_STAR00
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	; Set the previously obtained coords
	ld   a, b		; Y coord
	ldi  [hl], a
	ld   a, c		; X coord
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	call ExActS_Spawn
	ld   a, SFX1_13			; Sparkle SFX
	ld   [sSFX1Set], a
	ret
	
; =============== TrRoom_GetSparklePos ===============
; Gets the coordinates for the sparkle with the current position index,
; taking the treasure completion status into consideration.
; OUT
; - B: X position of the sparkle
; - C: Y position of the sparkle
TrRoom_GetSparklePos:
	; Generate the index to this jump table
	; ID = (sTrRoomSparkleIndex % $0F)-1
	ld   a, [sTrRoomSparkleIndex]
	and  a, $0F		; Filter away high byte
	dec  a			; No 16th treasure
	
	; Note that all of the subroutines in the jump table check if we have the treasure
	; before actually setting the sparkle coords.
	; If we don't have a specific treasure, it has a fallback where it jumps to another position id.
	; Because we never get here with no treasures, there's no way to softlock.
	rst  $28
	dw TrRoom_GetSparklePos_C
	dw TrRoom_GetSparklePos_I
	dw TrRoom_GetSparklePos_F
	dw TrRoom_GetSparklePos_O
	dw TrRoom_GetSparklePos_A
	dw TrRoom_GetSparklePos_N
	dw TrRoom_GetSparklePos_H
	dw TrRoom_GetSparklePos_M
	dw TrRoom_GetSparklePos_L
	dw TrRoom_GetSparklePos_K
	dw TrRoom_GetSparklePos_B
	dw TrRoom_GetSparklePos_D
	dw TrRoom_GetSparklePos_G
	dw TrRoom_GetSparklePos_J
	dw TrRoom_GetSparklePos_E
	
;; =============== mGetSparklePos ===============
;; Generates code to set the coordinates of the sparkle.
;; IN
;; - 1: Position ID
;; - 2: Letter of the treasure to collect
;; - 3: X Coord of the treasure
;; - 4: Y Coord of the treasure
;; - 5: Fallback letter to check if we didn't collect treasure \1
;; - 6: Where to check for the treasure completion status
;MACRO mGetSparklePos
;	; If we do not have this treasure, check the fallback instead
;	ld   a, [\6]					
;	bit  TREASUREB_\2, a			; Do we have it?
;	jr   z, TrRoom_GetSparklePos_\5	; If not, jump
;	
;	ld   bc, (\3 * $100)|\4			; Set coords (low byte: Y, high byte: X)
;	; Set the *actual* index, just in case we were set as a fallback option.
;	ld   a, \1						
;	ld   [sTrRoomSparkleIndex], a
;	ret
;ENDM
	
TrRoom_GetSparklePos_A:
	ld   a, [sTreasures]
	bit  TREASUREB_A, a				; Do we have it?
	jr   z, TrRoom_GetSparklePos_F	; If not, jump
	ld   bc, $6850					; Set coords (low byte: Y, high byte: X)
	ld   a, $05						; Set the *actual* index, just in case we were set as a fallback option.
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_B:;
	ld   a, [sTreasures+1]
	bit  TREASUREB_B, a
	jp   z, TrRoom_GetSparklePos_O
	ld   bc, $6860
	ld   a, $0B
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_C:
	ld   a, [sTreasures]
	bit  TREASUREB_C, a
	jr   z, TrRoom_GetSparklePos_I
	ld   bc, $6870
	ld   a, $01
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_D:
	ld   a, [sTreasures+1]
	bit  TREASUREB_D, a
	jp   z, TrRoom_GetSparklePos_N
	ld   bc, $6880
	ld   a, $0C
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_E:
	ld   a, [sTreasures+1]
	bit  TREASUREB_E, a
	jr   z, TrRoom_GetSparklePos_H
	ld   bc, $6890
	ld   a, $0F
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_F:
	ld   a, [sTreasures]
	bit  TREASUREB_F, a
	jr   z, TrRoom_GetSparklePos_M
	ld   bc, $7850
	ld   a, $03
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_G:
	ld   a, [sTreasures+1]
	bit  TREASUREB_G, a
	jr   z, TrRoom_GetSparklePos_L
	ld   bc, $7860
	ld   a, $0D
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_H:
	ld   a, [sTreasures]
	bit  TREASUREB_H, a
	jr   z, TrRoom_GetSparklePos_K
	ld   bc, $7870
	ld   a, $07
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_I:
	ld   a, [sTreasures]
	bit  TREASUREB_I, a
	jr   z, TrRoom_GetSparklePos_B
	ld   bc, $7880
	ld   a, $02
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_J:
	ld   a, [sTreasures+1]
	bit  TREASUREB_J, a
	jr   z, TrRoom_GetSparklePos_D
	ld   bc, $7890
	ld   a, $0E
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_K:
	ld   a, [sTreasures+1]
	bit  TREASUREB_K, a
	jr   z, TrRoom_GetSparklePos_G
	ld   bc, $8850
	ld   a, $0A
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_L:
	ld   a, [sTreasures+1]
	bit  TREASUREB_L, a
	jr   z, TrRoom_GetSparklePos_J
	ld   bc, $8860
	ld   a, $09
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_M:
	ld   a, [sTreasures+1]
	bit  TREASUREB_M, a
	jp   z, TrRoom_GetSparklePos_E
	ld   bc, $8870
	ld   a, $08
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_N:
	ld   a, [sTreasures]
	bit  TREASUREB_N, a
	jp   z, TrRoom_GetSparklePos_C
	ld   bc, $8880
	ld   a, $06
	ld   [sTrRoomSparkleIndex], a
	ret
TrRoom_GetSparklePos_O:
	ld   a, [sTreasures]
	bit  TREASUREB_O, a
	jp   z, TrRoom_GetSparklePos_A
	ld   bc, $8890
	ld   a, $04
	ld   [sTrRoomSparkleIndex], a
	ret
	
; =============== Mode_Unused_TrRoomExit ===============
; [TCRF] Appears to be an unused mode, and it's structured very similarly to Mode_LevelClear_TrRoomExit.
;        The peculiarity here is that:
;        - It doesn't call TrRoom_AnimCoin (so the 16x16 coin won't animate)
;        - This subroutine is stored after the ones for the treasure room when collecting a treasure
;        The only time the 16x16 coin isn't animated is when collecting a treasure, so this
;        may have been part of Mode_Treasure_TrRoom_*.
Mode_Unused_TrRoomExit:
	call TrRoom_WalkToExit
	call HomeCall_NonGame_WriteWarioOBJLst
	ret  
	
; =============== TrRoom_Unused_WalkToExit ===============
; [TCRF] Unreferenced subroutine. Identical to TrRoom_WalkToExit.
TrRoom_Unused_WalkToExit:
	call NonGame_Wario_AnimWalkFast
	; Walk left until we're off-screen
	ld   a, [sPlXRel]	; PlX--
	dec  a
	ld   [sPlXRel], a
	cp   a, $08			; PlX == $08?
	ret  nz				; If not, return
.endMode:
	; In case the map screen code was executed before (ie: map cutscene), make sure to clear the return value
	xor  a						
	ld   [sMapRetVal], a
	; Switch to the level clear mode (which will take effect if we actually cleared a new level)
	ld   a, $01
	ld   [sMapLevelClear], a
	jp   Map_SwitchToMap

; =============== Mode_LevelEntrance ===============
; When the player goes through the level entrance door (returning to the map screen).
Mode_LevelEntrance:
	ld   a, [sSubMode]
	rst  $28
	dw Level_FadeOutOBJ0ToBlack
	dw Level_FadeOutBGToWhite
	dw Mode_LevelEntrance_SaveAndSwitchToMap
	
; =============== Mode_LevelEntrance_SaveAndSwitchToMap ===============
Mode_LevelEntrance_SaveAndSwitchToMap:
	call Save_CopyAllToSave
	jp   Map_SwitchToMap
; =============== Pl_DoInvicibilityTimer ===============
; Handles and times the invincibility state for the player.
Pl_DoInvicibilityTimer:
	; Flash player palette
	; Pl_FlashPal does the same timer check -- could have been moved below
	call Pl_FlashPal
	
	; Every 8 frames decrement the invincibility timer
	ld   a, [sTimer]
	and  a, $07
	ret  nz	
	ld   hl, sPlInvincibleTimer
	dec  [hl]					; Timer--
	ret  nz						; Did it elapse?
	
	; When the timer elapses (which is enough to signal the end of invincibility everywhere else)...
	ld   hl, sPlFlags			; ...force back to the normal palette (in case we ended on the inverted one)
	res  4, [hl]
	call HomeCall_Level_SetBGM		; ...restart original level BGM
	ret
; =============== Game_StatusBarEdit ===============
; [POI] Debug feature.
; Handles the controls for the status bar editor.
Game_StatusBarEdit:

	; Holding B is required to move the cursor
	ldh  a, [hJoyKeys]
	bit  KEYB_B, a
	jr   z, .noAction
	
	; If we're over the Wario icon, disallow movement
	ld   a, [sStatusEditX]
	cp   a, $08*$02
	jr   z, .noAction
	
	; Handle the directional controls
	ldh  a, [hJoyNewKeys]
	bit  KEYB_RIGHT, a		; Cursor movement
	jr   nz, .moveRight
	bit  KEYB_LEFT, a
	jr   nz, .moveLeft
	bit  KEYB_UP, a			; Value change
	jp   nz, .moveUp
	bit  KEYB_DOWN, a
	jp   nz, .moveDown
.noAction:
	; Every $08 frames alternate between displaying and hiding the cursor
	ld   a, [sTimer]
	and  a, $0F
	cp   a, $08			; Timer & $0F >= $08?
	ret  nc				; If so, hide
	; Otherwise draw the cursor
	
	ld   a, [sWorkOAMPos]	; Point to the current OAM offset
	ld   l, a
	ld   h, HIGH(sWorkOAM)
	ld   a, [sStatusEditY]	; Y
	ldi  [hl], a
	ld   a, [sStatusEditX]	; X
	ldi  [hl], a
	ld   a, $C6				; Tile ID
	ldi  [hl], a
	xor  a					; Flags
	ldi  [hl], a
	ld   a, l				; Save updated offset
	ld   [sWorkOAMPos], a
	ret
.moveRight:
	ld   a, [sStatusEditX]	; Are on the rightmost entry?
	cp   a, $08*$14
	ret  z					; If so, don't move
	add  $08				
	ld   [sStatusEditX], a
	ret
.moveLeft:;R
	; Are we on the leftmost normal entry? (the one before Wario's icon)
	ld   a, [sStatusEditX]
	cp   a, $08*$04
	jr   z, .moveLeftSpec
	; If not, move the cursor left as normal
	sub  a, $08
	ld   [sStatusEditX], a
	ret
.moveLeftSpec:
	; Require holding A+B to move on the Wario's icon
	ldh  a, [hJoyKeys]
	bit  KEYB_A, a
	ret  z
	; If we're over it, mark the icon
	ld   a, $08*$02
	ld   [sStatusEditX], a
	
	; [TCRF] Depending if debug mode is set or not, pick a different action
	;        In debug mode, Wario's icon clears the stage.
	;        Otherwise, it switches to the next powerup.
	ld   a, [sDebugMode]
	and  a							; Debug mode on?
	jp   z, StatusBar_HatSwitch		; If not, switch hats
	ld   a, LVLCLEAR_BOSS			; Otherwise, clear the level
	ld   [sLvlSpecClear], a
	ret
	;--
.decLivesHigh:
	ld   a, [sLives]	; Don't decrement if high nybble is 0
	and  a, $F0
	ret  z
	ld   a, [sLives]	; sLives -= 10 (BCD)
	sub  a, $0A
	daa
	ld   [sLives], a
	call StatusBar_DrawLives
	ret
.decLivesLow:
	ld   a, [sLives]	; Don't decrement if low nybble is 0
	and  a, $0F
	ret  z
	ld   a, [sLives]
	sub  a, $01			; sLives -= 1 (BCD)
	daa
	ld   [sLives], a
	call StatusBar_DrawLives
	ret
.decCoinsHigh:
	ld   a, [sLevelCoins_High]
	and  a
	ret  z
	ld   a, [sLevelCoins_High]
	sub  a, $01
	daa
	ld   [sLevelCoins_High], a
	call StatusBar_DrawLevelCoins
	ret
.moveDown:
	; Decrement the following based on the cursor pos
	ld   a, [sStatusEditX]
	cp   a, $08*$04
	jr   z, .decLivesHigh
	cp   a, $08*$05
	jr   z, .decLivesLow
	cp   a, $08*$09
	jr   z, .decCoinsHigh
	cp   a, $08*$0A
	jr   z, .decCoinsMid
	cp   a, $08*$0B
	jr   z, .decCoinsLow
	cp   a, $08*$0E
	jr   z, .decHeartsHigh
	cp   a, $08*$0F
	jr   z, .decHeartsLow
	cp   a, $08*$12
	jr   z, .decTimeHigh
	cp   a, $08*$13
	jr   z, .decTimeMid
	cp   a, $08*$14
	jr   z, .decTimeLow
	ret
.decCoinsMid:
	ld   a, [sLevelCoins_Low]
	and  a, $F0
	ret  z
	ld   a, [sLevelCoins_Low]
	sub  a, $0A
	daa
	ld   [sLevelCoins_Low], a
	call StatusBar_DrawLevelCoins
	ret
.decCoinsLow:
	ld   a, [sLevelCoins_Low]
	and  a, $0F
	ret  z
	ld   a, [sLevelCoins_Low]
	sub  a, $01
	daa
	ld   [sLevelCoins_Low], a
	call StatusBar_DrawLevelCoins
	ret
.decHeartsHigh:
	ld   a, [sHearts]
	and  a, $F0
	ret  z
	ld   a, [sHearts]
	sub  a, $0A
	daa
	ld   [sHearts], a
	call StatusBar_DrawHearts
	ret
.decHeartsLow:
	ld   a, [sHearts]
	and  a, $0F
	ret  z
	ld   a, [sHearts]
	sub  a, $01
	daa
	ld   [sHearts], a
	call StatusBar_DrawHearts
	ret
.decTimeHigh:
	ld   a, [sLevelTime_High]
	and  a
	ret  z
	ld   a, [sLevelTime_High]
	sub  a, $01
	daa
	;--
	; If he hundreds have been set to $00, toggle the hurry up
	ld   [sLevelTime_High], a
	and  a
	jr   nz, .noToggle
	ld   a, $02
	ld   [sHurryUp], a
.noToggle:
	call StatusBar_DrawTime
	ret
.decTimeMid:
	ld   a, [sLevelTime_Low]
	and  a, $F0
	ret  z
	ld   a, [sLevelTime_Low]
	sub  a, $0A
	daa
	ld   [sLevelTime_Low], a
	call StatusBar_DrawTime
	ret
.decTimeLow:
	ld   a, [sLevelTime_Low]
	and  a, $0F
	ret  z
	ld   a, [sLevelTime_Low]
	sub  a, $01
	daa
	ld   [sLevelTime_Low], a
	call StatusBar_DrawTime
	ret
;--
.incLivesHigh:
	ld   a, [sLives]		; If the high nybble is exactly $9, don't increment it further
	and  a, $F0
	cp   a, $90
	ret  z
	ld   a, [sLives]		; sLives += 10 (BCD)
	add  $0A
	daa
	ld   [sLives], a
	call StatusBar_DrawLives
	ret
.incLivesLow:
	ld   a, [sLives]
	and  a, $0F
	cp   a, $09
	ret  z
	ld   a, [sLives]
	add  $01
	daa
	ld   [sLives], a
	call StatusBar_DrawLives
	ret
.incCoinsHigh:
	ld   a, [sLevelCoins_High]
	cp   a, $09
	ret  z
	ld   a, [sLevelCoins_High]
	add  $01
	daa
	ld   [sLevelCoins_High], a
	call StatusBar_DrawLevelCoins
	ret
.incCoinsMid:
	ld   a, [sLevelCoins_Low]
	and  a, $F0
	cp   a, $90
	ret  z
	ld   a, [sLevelCoins_Low]
	add  $0A
	daa
	ld   [sLevelCoins_Low], a
	call StatusBar_DrawLevelCoins
	ret
.moveUp:
	ld   a, [sStatusEditX]
	cp   a, $08*$04
	jr   z, .incLivesHigh    
	cp   a, $08*$05
	jr   z, .incLivesLow     
	cp   a, $08*$09
	jr   z, .incCoinsHigh    
	cp   a, $08*$0A
	jr   z, .incCoinsMid
	cp   a, $08*$0B
	jr   z, .incCoinsLow     
	cp   a, $08*$0E
	jr   z, .incHeartsHigh   
	cp   a, $08*$0F
	jr   z, .incHeartsLow    
	cp   a, $08*$12
	jr   z, .incTimeHigh     
	cp   a, $08*$13
	jr   z, .incTimeMid      
	cp   a, $08*$14
	jr   z, .incTimeLow      
	ret                      
.incCoinsLow:
	ld   a, [sLevelCoins_Low]
	and  a, $0F
	cp   a, $09
	ret  z
	ld   a, [sLevelCoins_Low]
	add  $01
	daa
	ld   [sLevelCoins_Low], a
	call StatusBar_DrawLevelCoins
	ret
.incHeartsHigh:
	ld   a, [sHearts]
	and  a, $F0
	cp   a, $90
	ret  z
	ld   a, [sHearts]
	add  $0A
	daa
	ld   [sHearts], a
	call StatusBar_DrawHearts
	ret
.incHeartsLow:
	ld   a, [sHearts]
	and  a, $0F
	cp   a, $09
	ret  z
	ld   a, [sHearts]
	add  $01
	daa
	ld   [sHearts], a
	call StatusBar_DrawHearts
	ret
.incTimeHigh:
	ld   a, [sLevelTime_High]
	cp   a, $09
	ret  z
	ld   a, [sLevelTime_High]
	add  $01
	daa
	; If the hundreds digit is not 0, remove the hurry up mode
	ld   [sLevelTime_High], a
	cp   a, $01
	jr   nz, .noToggle2
	xor  a
	ld   [sHurryUp], a
.noToggle2:
	call StatusBar_DrawTime
	ret
.incTimeMid:
	ld   a, [sLevelTime_Low]
	and  a, $F0
	cp   a, $90
	ret  z
	ld   a, [sLevelTime_Low]
	add  $0A
	daa
	ld   [sLevelTime_Low], a
	call StatusBar_DrawTime
	ret
.incTimeLow:
	ld   a, [sLevelTime_Low]
	and  a, $0F
	cp   a, $09
	ret  z
	ld   a, [sLevelTime_Low]
	add  $01
	daa
	ld   [sLevelTime_Low], a
	call StatusBar_DrawTime
	ret
; =============== Level_Scroll_SetScreenUpdate ===============
; Sets the screen update data for level scrolling.
; Only a single queue slot for a single direction will be handled at a time.
Level_Scroll_SetScreenUpdate:
	; Only if we moved in a direction
	ld   a, [sLvlScrollDir]
	and  a
	ret  z
	;--
	
	; There is a chain of checks if we moved in a specific direction.
	; If there's no scroll torwards a certain direction, we check the next one in the list.
	; D -> L -> U -> R -> (loop)
	
	; Depending on the timer pick the initial direction to check for.
	ld   b, a				; B = Movement bitmask
	ld   a, [sTimer]
	and  a, $03
	jp   z, .checkRight		; 0?
	dec  a
	jp   z, .checkUp		; 1?
	dec  a
	jp   z, .checkLeft		; 2?
.checkDown:
	; If we aren't scrolling down, switch to the next
	bit  DIRB_D, b
	jp   z, .checkLeft
	;--
	; Create the pointer to the level layout data for the top left coordinate
	; of the row to draw.
	; Since the pointer we're basing it from is the *level scroll* 
	; we need to also take the LVLSCROLL offset into consideration.
	
	; With that counted for, relative to the screen's top left block,
	; the block row's top left coord is:
	; - 10 blocks below
	; - 1  block to the left
	
	ld   hl, sLvlScrollUpdD0Y_High
	call Level_GetYBlockOffset
	ld   a, HIGH(wLevelLayout)-LVLSCROLL_YBLOCKOFFSET+$0A	; +$0A block Y
	add  h
	
	ld   [sBlockTopLeftPtr_High], a
	ld   hl, sLvlScrollUpdD0X_High
	call Level_GetXBlockOffset
	
	ld   a, -LVLSCROLL_XBLOCKOFFSET-$01 ; -$01 block X
	add  l
	
	; If we're trying to draw on the last two row of the level (we never get that far),
	; draw the first row instead.
	; Not sure what the point of this is, since it seems to cause discrepancies
	; with the horizontal movement code.
	cp   a, $FE							
	jr   c, .writeDataDown
	xor  a ; We never get here
.writeDataDown:
	
	; Get the tilemap ptr from the level layout offset
	ld   l, a
	ld   [sBlockTopLeftPtr_Low], a
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	push hl
	call GetBGMapOffsetFromBlock
	
	; Write the actual row of screen update data
	call Level_Scroll_AddBGPtrRow	; VRAM pointers
	pop  hl
	
	call Level_Scroll_AddRowTileId	; Tile IDs
	
	;--
	; Is there something in the second slot of the queue?
	ld   a, [sLvlScrollUpdD1Y_High]
	ld   d, a
	ld   a, [sLvlScrollUpdD1Y_Low]
	ld   e, a
	ld   a, [sLvlScrollUpdD1X_High]
	ld   b, a
	ld   a, [sLvlScrollUpdD1X_Low]
	ld   c, a
	or   a, b
	or   a, d
	or   a, e
	jr   nz, .dequeueDown ; If so, shift it from slot 1 to slot 0.
	
	; Otherwise just blank slot 0
	xor  a
	ld   [sLvlScrollUpdD0Y_High], a
	ld   [sLvlScrollUpdD0Y_Low], a
	ld   [sLvlScrollUpdD0X_High], a
	ld   [sLvlScrollUpdD0X_Low], a
	ld   hl, sLvlScrollDir
	; Unmark the direction from the process list
	res  DIRB_D, [hl]
	ret
.dequeueDown:
	; Move the contents of slot 1 to slot 0
	ld   a, d
	ld   [sLvlScrollUpdD0Y_High], a
	ld   a, e
	ld   [sLvlScrollUpdD0Y_Low], a
	ld   a, b
	ld   [sLvlScrollUpdD0X_High], a
	ld   a, c
	ld   [sLvlScrollUpdD0X_Low], a
	
	; And blank the remains of slot 1
	xor  a
	ld   [sLvlScrollUpdD1Y_High], a
	ld   [sLvlScrollUpdD1Y_Low], a
	ld   [sLvlScrollUpdD1X_High], a
	ld   [sLvlScrollUpdD1X_Low], a
	ret
	
.checkUp:
	bit  DIRB_U, b
	jr   z, .checkRight
	
	; Create the level layout ptr
	; Row Offset:
	; - 2 blocks above
	; - 1 block to the left
	ld   hl, sLvlScrollUpdU0Y_High
	call Level_GetYBlockOffset
	ld   a, HIGH(wLevelLayout)-LVLSCROLL_YBLOCKOFFSET-$02
	add  h
	
	ld   [sBlockTopLeftPtr_High], a
	ld   hl, sLvlScrollUpdU0X_High
	call Level_GetXBlockOffset
	ld   a,  -LVLSCROLL_XBLOCKOFFSET-$01
	add  l
	
	; If we're trying to draw on the last two row of the level (we never get that far),
	; draw the first row instead.
	; Not sure what the point of this is, since it seems to cause discrepancies
	; with the horizontal movement code.
	cp   a, $FE
	jr   c, .writeDataUp
	xor  a ; We never get here
.writeDataUp:
	; Get the tilemap ptr from the level layout offset
	ld   l, a
	ld   [sBlockTopLeftPtr_Low], a
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	push hl
	call GetBGMapOffsetFromBlock
	
	; Write the actual row of screen update data
	call Level_Scroll_AddBGPtrRow
	pop  hl
	call Level_Scroll_AddRowTileId
	
	;--
	; Is there something in the second slot of the queue?
	ld   a, [sLvlScrollUpdU1Y_High]
	ld   d, a
	ld   a, [sLvlScrollUpdU1Y_Low]
	ld   e, a
	ld   a, [sLvlScrollUpdU1X_High]
	ld   b, a
	ld   a, [sLvlScrollUpdU1X_Low]
	ld   c, a
	or   a, b
	or   a, d
	or   a, e
	jr   nz, .dequeueUp	; If so, jump
	
	; Otherwise just blank slot 0
	xor  a
	ld   [sLvlScrollUpdU0Y_High], a
	ld   [sLvlScrollUpdU0Y_Low], a
	ld   [sLvlScrollUpdU0X_High], a
	ld   [sLvlScrollUpdU0X_Low], a
	ld   hl, sLvlScrollDir
	res  DIRB_U, [hl]
	ret
.dequeueUp:
	; Move the contents of slot 1 to slot 0
	ld   a, d
	ld   [sLvlScrollUpdU0Y_High], a
	ld   a, e
	ld   [sLvlScrollUpdU0Y_Low], a
	ld   a, b
	ld   [sLvlScrollUpdU0X_High], a
	ld   a, c
	ld   [sLvlScrollUpdU0X_Low], a
	; And blank the remains of slot 1
	xor  a
	ld   [sLvlScrollUpdU1Y_High], a
	ld   [sLvlScrollUpdU1Y_Low], a
	ld   [sLvlScrollUpdU1X_High], a
	ld   [sLvlScrollUpdU1X_Low], a
	ret
	
.checkRight:
	bit  DIRB_R, b
	jp   z, .checkDown
	
	; The autoscroll with parallax does its own thing
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_AUTOR
	jr   z, .autoScrollRight
	
	; Create the level layout ptr
	; Col Offset:
	; - 2  blocks above
	; - 12 block to the right
	ld   hl, sLvlScrollUpdR0Y_High
	call Level_GetYBlockOffset
	ld   a, HIGH(wLevelLayout)-LVLSCROLL_YBLOCKOFFSET-$02
	add  h
	ld   [sBlockTopLeftPtr_High], a
	ld   hl, sLvlScrollUpdR0X_High
	call Level_GetXBlockOffset
	ld   a, -LVLSCROLL_XBLOCKOFFSET+$0B
	add  l
	
	; Get the tilemap ptr from the level layout offset
	ld   l, a
	ld   [sBlockTopLeftPtr_Low], a
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	push hl
	call GetBGMapOffsetFromBlock
	
	; Write the actual column of screen update data
	call Level_Scroll_AddBGPtrCol
	pop  hl
	call Level_Scroll_AddColumnTileId
	
	;--
	; Is there something in the second slot of the queue?
	ld   a, [sLvlScrollUpdR1Y_High]
	ld   d, a
	ld   a, [sLvlScrollUpdR1Y_Low]
	ld   e, a
	ld   a, [sLvlScrollUpdR1X_High]
	ld   b, a
	ld   a, [sLvlScrollUpdR1X_Low]
	ld   c, a
	or   a, b
	or   a, d
	or   a, e
	jr   nz, .dequeueRight	; If so, jump
	
	; Otherwise just blank slot 0
	xor  a
	ld   [sLvlScrollUpdR0Y_High], a
	ld   [sLvlScrollUpdR0Y_Low], a
	ld   [sLvlScrollUpdR0X_High], a
	ld   [sLvlScrollUpdR0X_Low], a
	ld   hl, sLvlScrollDir
	
	res  DIRB_R, [hl]
	ret
.dequeueRight:
	; Move the contents of slot 1 to slot 0
	ld   a, d
	ld   [sLvlScrollUpdR0Y_High], a
	ld   a, e
	ld   [sLvlScrollUpdR0Y_Low], a
	ld   a, b
	ld   [sLvlScrollUpdR0X_High], a
	ld   a, c
	ld   [sLvlScrollUpdR0X_Low], a
	; And blank the remains of slot 1
	xor  a
	ld   [sLvlScrollUpdR1Y_High], a
	ld   [sLvlScrollUpdR1Y_Low], a
	ld   [sLvlScrollUpdR1X_High], a
	ld   [sLvlScrollUpdR1X_Low], a
	ret
.autoScrollRight:
	; Handles the train autoscroll mode with parallax.
	
	; Col offset:
	; - 3  blocks below (skip the mountain backdrop)
	; - 12 block to the right
	call Level_Scroll_GetYBlockOffset
	ld   a, HIGH(wLevelLayout)-LVLSCROLL_YBLOCKOFFSET+$03
	add  h
	ld   [sBlockTopLeftPtr_High], a
	call Level_Scroll_GetXBlockOffset
	ld   a, -LVLSCROLL_XBLOCKOFFSET+$0B
	add  l
	
	; Get the tilemap ptr from the level layout offset
	ld   l, a
	ld   [sBlockTopLeftPtr_Low], a
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	push hl
	call GetBGMapOffsetFromBlock
	
	; Write the actual column of screen update data
	; It's 5 blocks high in total; after that there's the train track (also under parallax effect)
	ld   b, $05
	call Level_Scroll_AddBGPtrCol2
	pop  hl
	ld   b, $05
	call Level_Scroll_AddColumnTileIdCustom
	
	; Always clear the entire queue
	xor  a
	ld   [sLvlScrollUpdR0Y_High], a
	ld   [sLvlScrollUpdR0Y_Low], a
	ld   [sLvlScrollUpdR0X_High], a
	ld   [sLvlScrollUpdR0X_Low], a
	ld   [sLvlScrollUpdR1Y_High], a
	ld   [sLvlScrollUpdR1Y_Low], a
	ld   [sLvlScrollUpdR1X_High], a
	ld   [sLvlScrollUpdR1X_Low], a
	ld   hl, sLvlScrollDir
	res  DIRB_R, [hl]
	ret
.checkLeft:
	bit  DIRB_L, b
	jp   z, .checkUp
	
	; The autoscroll with parallax does its own thing
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_AUTOL
	jr   z, .autoScrollLeft
	
	; Create the level layout ptr
	; Col Offset:
	; - 2 blocks above
	; - 1 block to the left
	ld   hl, sLvlScrollUpdL0Y_High
	call Level_GetYBlockOffset
	ld   a, HIGH(wLevelLayout)-LVLSCROLL_YBLOCKOFFSET-$02
	add  h
	ld   [sBlockTopLeftPtr_High], a
	ld   hl, sLvlScrollUpdL0X_High
	call Level_GetXBlockOffset
	ld   a, -LVLSCROLL_XBLOCKOFFSET-$01
	add  l
	
	; Get the tilemap ptr from the level layout offset
	ld   l, a
	ld   [sBlockTopLeftPtr_Low], a
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	push hl
	call GetBGMapOffsetFromBlock
	
	; Write the actual column of screen update data
	call Level_Scroll_AddBGPtrCol
	pop  hl
	call Level_Scroll_AddColumnTileId
	
	;--
	; Is there something in the second slot of the queue?
	ld   a, [sLvlScrollUpdL1Y_High]
	ld   d, a
	ld   a, [sLvlScrollUpdL1Y_Low]
	ld   e, a
	ld   a, [sLvlScrollUpdL1X_High]
	ld   b, a
	ld   a, [sLvlScrollUpdL1X_Low]
	ld   c, a
	or   a, b
	or   a, d
	or   a, e
	jr   nz, .dequeueLeft ; If so, jump
	
	; Otherwise just blank slot 0
	xor  a
	ld   [sLvlScrollUpdL0Y_High], a
	ld   [sLvlScrollUpdL0Y_Low], a
	ld   [sLvlScrollUpdL0X_High], a
	ld   [sLvlScrollUpdL0X_Low], a
	ld   hl, sLvlScrollDir
	
	res  DIRB_L, [hl]
	ret
.dequeueLeft:
	; Move the contents of slot 1 to slot 0
	ld   a, d
	ld   [sLvlScrollUpdL0Y_High], a
	ld   a, e
	ld   [sLvlScrollUpdL0Y_Low], a
	ld   a, b
	ld   [sLvlScrollUpdL0X_High], a
	ld   a, c
	ld   [sLvlScrollUpdL0X_Low], a
	; And blank the remains of slot 1
	xor  a
	ld   [sLvlScrollUpdL1Y_High], a
	ld   [sLvlScrollUpdL1Y_Low], a
	ld   [sLvlScrollUpdL1X_High], a
	ld   [sLvlScrollUpdL1X_Low], a
	ret
.autoScrollLeft:
	; Handles the train autoscroll mode with parallax.
	
	; Col offset:
	; - 3 blocks below (skip the mountain backdrop)
	; - 1 block to the left
	call Level_Scroll_GetYBlockOffset
	ld   a, HIGH(wLevelLayout)-LVLSCROLL_YBLOCKOFFSET+$03
	add  h
	ld   [sBlockTopLeftPtr_High], a
	call Level_Scroll_GetXBlockOffset
	ld   a, -LVLSCROLL_XBLOCKOFFSET-$01
	add  l
	
	; Get the tilemap ptr from the level layout offset
	ld   l, a
	ld   [sBlockTopLeftPtr_Low], a
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	push hl
	call GetBGMapOffsetFromBlock
	
	; Write the actual column of screen update data
	; It's 5 blocks high in total; after that there's the train track (also under parallax effect)
	ld   b, $05
	call Level_Scroll_AddBGPtrCol2
	pop  hl
	ld   b, $05
	call Level_Scroll_AddColumnTileIdCustom
	
	; Always clear the entire queue
	xor  a
	ld   [sLvlScrollUpdL0Y_High], a
	ld   [sLvlScrollUpdL0Y_Low], a
	ld   [sLvlScrollUpdL0X_High], a
	ld   [sLvlScrollUpdL0X_Low], a
	ld   [sLvlScrollUpdL1Y_High], a
	ld   [sLvlScrollUpdL1Y_Low], a
	ld   [sLvlScrollUpdL1X_High], a
	ld   [sLvlScrollUpdL1X_Low], a
	ld   hl, sLvlScrollDir
	res  DIRB_L, [hl]
	ret
; =============== Level_Screen_ScrollHorz ===============
; Handles the horizontal scrolling of the screen during gameplay.
Level_Screen_ScrollHorz:
	; Did we move horizontally?
	ld   a, [sLvlScrollHAmount]
	and  a
	jr   z, .noMove			
	
	; Which direction did we move?
	bit  7, a
	jr   nz, .moveLeft
	
	;
	; RIGHT DIRECTION
	;
.moveRight:
	; We need to verify if we can scroll the screen to the right.
	; This can happen if the player's relative pos reaches a certain X coordinate.
	
	; The target coord depends on the scrolling mode.
	; (All other subroutines work similarly)
	ld   b, a
	ld   c, $40					; C = Target X coordinate (normal)
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_FREE		; Are we in segscrl mode? (< $10)
	jr   c, .chkScrollR			; If so, jump
	cp   a, LVLSCROLL_CHKAUTO	; Are we in an autoscroll mode? (>=$20)
	jr   nc, .scrollR			; If so, jump
.centerScreenR:
	ld   c, $58					; C = Target X coord (freescroll)
.chkScrollR:
	; Determine the movement speed from the player's X loc
	
	; If we didn't reach the target coord, don't scroll the screen
	ld   a, [sPlXRel]		
	cp   a, c					
	jr   c, .endR				
	; If it's exactly the target coord, scroll it as normal
	jr   z, .scrollR				
	
	; Otherwise, we're on the right side, past the target
	; Make sure the scroll speed is at least 2px/frame to try keeping up
	ld   a, b					
	cp   a, $02
	jr   nc, .scrollR
	inc  b
	
.scrollR:
	call Level_Screen_MoveRight
	ld   hl, sLvlScrollDir
	set  DIRB_R, [hl]
	ld   hl, sLvlScrollDirAct
	set  DIRB_R, [hl]
	call Level_Scroll_AddToRightQueue
.endR:
	xor  a
	ld   [sLvlScrollHAmount], a
	ret
	
	;
	; LEFT DIRECTION
	;
.moveLeft:
	cpl				; ABS(A)
	inc  a			
	
	; Which target rel. X for triggering scroll?
	ld   b, a
	ld   c, $70						; C = Target X
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_FREE			; Are we in segscrl mode? (< $10)
	jr   c, .chkScrollL             ; If so, jump
	cp   a, LVLSCROLL_CHKAUTO       ; Are we in an autoscroll mode? (>=$20)
	jr   nc, .scrollL               ; If so, jump
	ld   c, $58						; C = Target X (freescroll)
.chkScrollL:
	; Are we exactly on the target pos?
	ld   a, [sPlXRel]
	cp   a, c
	jr   z, .scrollL				; If so, scroll normally left
	
	; Are we on the right of the target pos?
	jr   nc, .endL					; If so, don't scroll
	
	; Otherwise, we're on the left side, past the target
	; Make sure the scroll speed is at least 2px/frame to try keeping up
	ld   a, b
	cp   a, $02
	jr   nc, .scrollL
	inc  b
.scrollL:
	call Level_Screen_MoveLeft
	ld   hl, sLvlScrollDir
	set  DIRB_L, [hl]
	ld   hl, sLvlScrollDirAct
	set  DIRB_L, [hl]
	call Level_Scroll_AddToLeftQueue
.endL:
	xor  a
	ld   [sLvlScrollHAmount], a
	ret
	
	;
	; NO DIRECTION
	;
.noMove:
	; Try to make the camera keep up if the player isn't moving horizontally.
	
	; If there are any active horz screen locks, don't do anything
	ld   a, [sLvlScrollLockCur]
	and  a, DIR_R|DIR_L
	ret  nz
	
	ld   a, [sPlActSolid]
	and  a
	ret  nz
	
	; The camera will only try to keep up if the player stands still on the ground.
	; This was most likely done to avoid scrolling the screen when rebounding from a wall after a dash.
	; [BUG] However the way it's done is stupid can be abused for wrong warping.
	;       This should really have only blacklisted the "rebound from wall" action ($0C)
	;		instead of whitelisting only the standing action.
	ld   a, [sPlAction]
	IF FIX_BUGS == 1
		cp   a, PL_ACT_DASHREBOUND	; Are we rebounding off a wall?
		ret  z						; If so, return (don't scroll)
		cp   a, PL_ACT_DEAD			; Are we dead?
		ret  z						; If so, return (don't scroll)
	ELSE
		and  a						; Are we standing on the ground? (PL_ACT_STAND)
		ret  nz						; If not, return (don't scroll)
	ENDC
	
	; How the screen syncs back depends on scrolling mode
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_FREE		; Are we in segscrl mode? (< $10)
	jr   c, .chkSyncSegScroll   ; If so, jump
	cp   a, LVLSCROLL_CHKAUTO   ; Are we in an autoscroll mode? (>=$20)
	ret  nc                     ; If so, return since we don't have control over the screen.
.chkSyncFreeScroll:
	ld   b, $01					; B = Camera speed when fixing itself
	
	; If the player's at the middle of the screen, don't do anything
	ld   a, [sPlXRel]		; Is the player on the "middle" of the screen?
	cp   a, $58
	ret  z						; If so, don't do anything
	; Otherwise scroll it left/right if we're respectively on the left or right side of the middle
	jr   c, .scrollL			
	jr   .scrollR				
.chkSyncSegScroll:
	ld   b, $01					; B = Camera speed when fixing itself
	
	; Similar to the above, but there's an X range $40-$70 which won't
	; cause the camera to move.
	ld   a, [sPlXRel]
	cp   a, $40				; If < $40, scroll it left
	jr   c, .scrollL
	cp   a, $70				; If < $70, don't scroll
	ret  c
	ret  z					; Otherwise scroll right
IF FIX_BUGS == 1
	jp   .scrollR
ELSE
	jr   .scrollR
ENDC
; =============== Level_Screen_ScrollVert ===============
; Handles the vertical scrolling of the screen during gameplay.
Level_Screen_ScrollVert:
	; There's no vertical screen fix for this.
	; If we aren't moving vertically, don't do anything.
	ld   a, [sLvlScrollVAmount]
	and  a
	ret  z
	
	; Which direction?
	bit  7, a
	jr   nz, .moveUp
	
	;
	; DOWN DIRECTION
	;
.moveDown:
	ld   b, a
	; If downwards movement is requested outside of freescroll mode,
	; assume that's always correct since it's been checked for before.
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_FREE		; segscroll mode?
	jr   c, .scrollD
	cp   a, LVLSCROLL_CHKAUTO	; autoscroll mode?
	jr   nc, .scrollD
.chkScrollD:
	; In freescroll mode we need to check where we are on the screen
	
	; If we're on the top don't scroll the screen
	ld   a, [sPlYRel]
	cp   a, $58				; WY < $58?
	jr   c, .endD
	; On the exact center move it normally
	jr   z, .scrollD
	; Otherwise enforce the min 2px/frame scroll speed
	ld   a, b
	cp   a, $02
	jr   nc, .scrollD
	inc  b
.scrollD:
	call Level_Screen_MoveDown
	ld   hl, sLvlScrollDir
	set  DIRB_D, [hl]
	ld   hl, sLvlScrollDirAct
	set  DIRB_D, [hl]
	call Level_Scroll_AddToDownQueue
.endD:
	xor  a
	ld   [sLvlScrollVAmount], a
	ret
	
	;
	; UP DIRECTION
	;
.moveUp:
	cpl			; ABS(A)
	inc  a
	
	; Like for the downwards scroll, assume upwards scrolling in segscrl/autoscroll
	; to be always correct
	ld   b, a
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_FREE
	jr   c, .scrollU
	cp   a, LVLSCROLL_CHKAUTO
	jr   nc, .scrollU
.chkScrollU:
	; In freescroll mode we need to check where we are on the screen
	
	; If we're exactly in the middle scroll the screen as usual
	ld   a, [sPlYRel]
	cp   a, $58
	jr   z, .scrollU
	; If we're below (> $58) don't scroll
	jr   nc, .endU
	; Otherwise we're above, so enforce the min 2px/frame camera speed
	ld   a, b
	cp   a, $02
	jr   nc, .scrollU
	inc  b
.scrollU:
	call Level_Screen_MoveUp
	ld   hl, sLvlScrollDir
	set  DIRB_U, [hl]
	ld   hl, sLvlScrollDirAct
	set  DIRB_U, [hl]
	call Level_Scroll_AddToUpQueue
.endU:
	xor  a
	ld   [sLvlScrollVAmount], a
	ret
	
; =============== Level_Scroll_AddTo*Queue ===============
; This is a set of subroutines to queue a screen update request for a specific direction.
; Note that the request may not be always processed on the same frame.
;
; The queue contains two slots, though most of the time only the first one is used.
; Each slot can contain a copy of the sLvlScroll value rounded to a block boundary.
; The value itself will be used on Level_Scroll_SetScreenUpdate, which offsets it as needed.
;
Level_Scroll_AddToRightQueue:

	; Every subroutine follows this general path.
	; 1) Try to queue on slot 0
	; 2) Try to queue on slot 1
	; 3) Panic!
	
	; Is the first queue slot is empty?
	ld   a, [sLvlScrollUpdR0Y_High]
	ld   d, a
	ld   a, [sLvlScrollUpdR0Y_Low]
	ld   e, a
	ld   a, [sLvlScrollUpdR0X_High]
	ld   b, a
	ld   a, [sLvlScrollUpdR0X_Low]
	ld   c, a
	or   a, b
	or   a, d
	or   a, e
	jr   z, .writeSet0	; If so, write the scroll coord there
	
	; If it, isn't verify that the new request isn't a duplicate.
	
	; The scroll pointer that's set here is aligned on a *block* boundary.
	; So we can ignore requests that point to the same block's X coord. 
	ld   a, [sLvlScrollX_Low]	; Get the scroll offset pointer
	and  a, $F0					; A = FLOOR(sLvlScrollX, $10) (where $10 -> block width)
	cp   a, c					; Is it the same coord as the existing request? (which was also FLOOR'd)
	ret  z						; If so, we can ignore this request
	
	
	; If it's unique, try to use the second queue slot
	ld   a, [sLvlScrollUpdR1Y_High]
	ld   d, a
	ld   a, [sLvlScrollUpdR1Y_Low]
	ld   e, a
	ld   a, [sLvlScrollUpdR1X_High]
	ld   b, a
	ld   a, [sLvlScrollUpdR1X_Low]
	ld   c, a
	or   a, b
	or   a, d
	or   a, e
	jr   z, .writeSet1
	
	; Check for the duplicate request the same way
	ld   a, [sLvlScrollX_Low]
	and  a, $F0
	cp   a, c
	ret  z
	
	; [TCRF] Too many requests in a short time!
	;        This should never happen, so instead of ignoring the request and causing noticeable visual glitches,
	;        we infinite loop with interrupts disabled.
	jr   .unused_fail
.writeSet0:
	; Write the scroll coord (X aligned to a block) to the first slot 
	ld   a, [sLvlScrollY_High]
	ld   [sLvlScrollUpdR0Y_High], a
	ld   a, [sLvlScrollY_Low]
	ld   [sLvlScrollUpdR0Y_Low], a
	ld   a, [sLvlScrollX_High]
	ld   [sLvlScrollUpdR0X_High], a
	ld   a, [sLvlScrollX_Low]
	and  a, $F0
	ld   [sLvlScrollUpdR0X_Low], a
	ret
.writeSet1:
	; Write the scroll coord (X aligned to a block) to the second slot 
	ld   a, [sLvlScrollY_High]
	ld   [sLvlScrollUpdR1Y_High], a
	ld   a, [sLvlScrollY_Low]
	ld   [sLvlScrollUpdR1Y_Low], a
	ld   a, [sLvlScrollX_High]
	ld   [sLvlScrollUpdR1X_High], a
	ld   a, [sLvlScrollX_Low]
	and  a, $F0
	ld   [sLvlScrollUpdR1X_Low], a
	ret
.unused_fail:
	xor  a
	ldh  [rIE], a
	jr .unused_fail
	
; =============== Level_Scroll_AddToLeftQueue ===============
Level_Scroll_AddToLeftQueue:
	; Enqueue on slot 0 if not empty
	ld   a, [sLvlScrollUpdL0Y_High]
	ld   d, a
	ld   a, [sLvlScrollUpdL0Y_Low]
	ld   e, a
	ld   a, [sLvlScrollUpdL0X_High]
	ld   b, a
	ld   a, [sLvlScrollUpdL0X_Low]
	ld   c, a
	or   a, b
	or   a, d
	or   a, e
	jr   z, .writeSet0
	
	; Duplicate request on slot 0?
	ld   a, [sLvlScrollX_Low]
	add  $04		
	and  a, $F0		; Filter out sub-block component
	cp   a, c		; Is it the same?
	ret  z			; If so, jump
	
	
	; Enqueue on slot 1 if not empty
	ld   a, [sLvlScrollUpdL1Y_High]
	ld   d, a
	ld   a, [sLvlScrollUpdL1Y_Low]
	ld   e, a
	ld   a, [sLvlScrollUpdL1X_High]
	ld   b, a
	ld   a, [sLvlScrollUpdL1X_Low]
	ld   c, a
	or   a, b
	or   a, d
	or   a, e
	jr   z, .writeSet1
	
	; Duplicate request on slot 1?
	ld   a, [sLvlScrollX_Low]
	add  $04
	and  a, $F0
	cp   a, c
	ret  z
	
	; [TCRF] If not, fail
	jr   .unused_fail
.writeSet0:
	ld   a, [sLvlScrollY_High]
	ld   [sLvlScrollUpdL0Y_High], a
	ld   a, [sLvlScrollY_Low]
	ld   [sLvlScrollUpdL0Y_Low], a
	ld   a, [sLvlScrollX_Low]
	add  $04
	ld   a, [sLvlScrollX_High]
	adc  a, $00
	ld   [sLvlScrollUpdL0X_High], a
	ld   a, [sLvlScrollX_Low]
	add  $04
	and  a, $F0
	ld   [sLvlScrollUpdL0X_Low], a
	ret
.writeSet1:
	ld   a, [sLvlScrollY_High]
	ld   [sLvlScrollUpdL1Y_High], a
	ld   a, [sLvlScrollY_Low]
	ld   [sLvlScrollUpdL1Y_Low], a
	ld   a, [sLvlScrollX_Low]
	add  $04
	ld   a, [sLvlScrollX_High]
	adc  a, $00
	ld   [sLvlScrollUpdL1X_High], a
	ld   a, [sLvlScrollX_Low]
	add  $04
	and  a, $F0
	ld   [sLvlScrollUpdL1X_Low], a
	ret
.unused_fail:
	xor  a
	ldh  [rIE], a
	jr .unused_fail
	
; =============== Level_Scroll_AddToUpQueue ===============
Level_Scroll_AddToUpQueue:
	; Enqueue on slot 0 if not empty
	ld   a, [sLvlScrollUpdU0Y_High]
	ld   d, a
	ld   a, [sLvlScrollUpdU0Y_Low]
	ld   e, a
	ld   a, [sLvlScrollUpdU0X_High]
	ld   b, a
	ld   a, [sLvlScrollUpdU0X_Low]
	ld   c, a
	or   a, b
	or   a, d
	or   a, e
	jr   z, .writeSet0
	
	; Duplicate request on slot 0?
	ld   a, [sLvlScrollY_Low]
	add  $04
	and  a, $F0
	cp   e
	ret  z
	
	; Enqueue on slot 1 if not empty
	ld   a, [sLvlScrollUpdU1Y_High]
	ld   d, a
	ld   a, [sLvlScrollUpdU1Y_Low]
	ld   e, a
	ld   a, [sLvlScrollUpdU1X_High]
	ld   b, a
	ld   a, [sLvlScrollUpdU1X_Low]
	ld   c, a
	or   a, b
	or   a, d
	or   a, e
	jr   z, .writeSet1
	
	; Duplicate request on slot 1?
	ld   a, [sLvlScrollY_Low]
	add  $04
	and  a, $F0
	cp   e
	ret  z
	
	; [TCRF] Otherwise, fail
	jr   .unused_fail
.writeSet0:
	ld   a, [sLvlScrollY_Low]
	add  $04
	ld   a, [sLvlScrollY_High]
	adc  a, $00
	ld   [sLvlScrollUpdU0Y_High], a
	ld   a, [sLvlScrollY_Low]
	add  $04
	and  a, $F0
	ld   [sLvlScrollUpdU0Y_Low], a
	ld   a, [sLvlScrollX_High]
	ld   [sLvlScrollUpdU0X_High], a
	ld   a, [sLvlScrollX_Low]
	ld   [sLvlScrollUpdU0X_Low], a
	ret
.writeSet1:
	ld   a, [sLvlScrollY_Low]
	add  $04
	ld   a, [sLvlScrollY_High]
	adc  a, $00
	ld   [sLvlScrollUpdU1Y_High], a
	ld   a, [sLvlScrollY_Low]
	add  $04
	and  a, $F0
	ld   [sLvlScrollUpdU1Y_Low], a
	ld   a, [sLvlScrollX_High]
	ld   [sLvlScrollUpdU1X_High], a
	ld   a, [sLvlScrollX_Low]
	ld   [sLvlScrollUpdU1X_Low], a
	ret
.unused_fail:
	xor  a
	ldh  [rIE], a
	jr .unused_fail
	
; =============== Level_Scroll_AddToDownQueue ===============
Level_Scroll_AddToDownQueue:
	; Enqueue on slot 0 if not empty
	ld   a, [sLvlScrollUpdD0Y_High]
	ld   d, a
	ld   a, [sLvlScrollUpdD0Y_Low]
	ld   e, a
	ld   a, [sLvlScrollUpdD0X_High]
	ld   b, a
	ld   a, [sLvlScrollUpdD0X_Low]
	ld   c, a
	or   a, b
	or   a, d
	or   a, e
	jr   z, .writeSet0
	
	; Duplicate request on slot 0?
	ld   a, [sLvlScrollY_Low]
	and  a, $F0
	cp   e
	ret  z
	
	; Enqueue on slot 1 if not empty
	ld   a, [sLvlScrollUpdD1Y_High]
	ld   d, a
	ld   a, [sLvlScrollUpdD1Y_Low]
	ld   e, a
	ld   a, [sLvlScrollUpdD1X_High]
	ld   b, a
	ld   a, [sLvlScrollUpdD1X_Low]
	ld   c, a
	or   a, b
	or   a, d
	or   a, e
	jr   z, .writeSet1
	
	; Duplicate request on slot 1?
	ld   a, [sLvlScrollY_Low]
	and  a, $F0
	cp   e
	ret  z
	
	; [TCRF] Otherwise, fail
	jr   .unused_fail
.writeSet0:
	ld   a, [sLvlScrollY_High]
	ld   [sLvlScrollUpdD0Y_High], a
	ld   a, [sLvlScrollY_Low]
	and  a, $F0
	ld   [sLvlScrollUpdD0Y_Low], a
	ld   a, [sLvlScrollX_High]
	ld   [sLvlScrollUpdD0X_High], a
	ld   a, [sLvlScrollX_Low]
	ld   [sLvlScrollUpdD0X_Low], a
	ret
.writeSet1:
	ld   a, [sLvlScrollY_High]
	ld   [sLvlScrollUpdD1Y_High], a
	ld   a, [sLvlScrollY_Low]
	and  a, $F0
	ld   [sLvlScrollUpdD1Y_Low], a
	ld   a, [sLvlScrollX_High]
	ld   [sLvlScrollUpdD1X_High], a
	ld   a, [sLvlScrollX_Low]
	ld   [sLvlScrollUpdD1X_Low], a
	ret
.unused_fail:
	xor  a
	ldh  [rIE], a
	jr .unused_fail
	
; =============== Level_Scroll_DoAutoScroll ===============
; Performs the automatic screen/player movement during autoscrolling / conveyor belts / water currents.
; This also performs BG collision checks, to do things
; like instakill the player if crushed by a block on the screen border.
; IN
; - B: Scroll speed mask (do movement if Timer & B == 0)
;      In practice it's always set to 1, leading to a flat 0.5px/frame speed.
; - A: Scroll direction
Level_Scroll_DoAutoScroll:
	; Which direction are we set to move to?
	
	; The first thing each direction does is handling the speed mask
	; (the same way, so it could have been done here...)
	ld   a, [sLvlAutoScrollDir]
	bit  DIRB_R, a
	jr   nz, Level_Scroll_DoAutoScrollRight
	bit  DIRB_L, a
	jr   nz, Level_Scroll_DoAutoScrollLeft
	bit  DIRB_U, a
	jr   nz, .up
	
.down:
	ld   a, [sTimer]
	and  a, b
	ret  nz
	;--
	; Move down player
	ld   b, $01
	call Pl_MoveDown
	ret
	
.up:
	ld   a, [sTimer]
	and  a, b
	ret  nz
	;--
	; Move player upwards if there isn't a solid block above
	call PlBGColi_DoTopStub	; Handle top collision
	dec  a	; COLI_SOLID 	; Is there a solid block above?
	ret  z					; If so, return
	ld   b, $01				; Otherwise, move player up
	call Pl_MoveUp
	ret
	
Level_Scroll_DoAutoScrollLeft:
	ld   a, [sTimer]
	and  a, b
	ret  nz
	;--
	call Level_ScreenLock_DoLeft	; Update screen lock

	; If we aren't in an autoscrolling mode, stop movement when there's a
	; solid block on the left.
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_AUTOL		; Are we in the left autoscroll mode?		
	jr   z, .tryScrollScreen	; If so, always move the screen
	; Otherwise, we're bring transported to the left by a conveyor belt/water current.
	call PlBGColi_DoLeftStub	; Handle collision on the left (since it's where we're moving to)
	dec  a						; Is there a solid block on the left?
	ret  z						; If so, stop further movement
	
.tryScrollScreen:
	; Scroll the screen left if there isn't a screen lock
	ld   b, $01						; B = Movement speed
	ld   a, [sLvlScrollLockCur]
	and  a, DIR_L|DIR_R				; Is there a screen lock?
	jr   nz, .chkScroll				; If so, jump
	
	ld   a, [sLvlScrollHAmount]		; Otherwise scroll the screen
	sub  a, b
	ld   [sLvlScrollHAmount], a
.chkScroll:
	; More differences between auto-scroll and conveyor-belt-type scroll.
	; The former always causes the player to move left; the latter only if we're close to the screen border.

	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_AUTOL			; Are we in an autoscrolling mode?
	jr   z, .autoLeft				; If so, perform boundary checking
.moveLeft:
	call Pl_MoveLeft				
	ret
.autoLeft:
	ld   a, [sPlXRel]			
	cp   a, SCREEN_H				; Is the player near the right screen border? (-OBJ_OFFSET_X)
	ret  c							; If not, return
	
	call PlBGColi_DoLeftStub		; If so, handle collision on the left
	dec  a							; Is there a solid block on the left?
	jp   z, Pl_StartDeathAnim		; If so, trigger the instadeath since the block would push us offscreen
	ld   b, $01						; Otherwise, move the player left to keep him on-screen
	jr   .moveLeft
	
Level_Scroll_DoAutoScrollRight:
	ld   a, [sTimer]
	and  a, b
	ret  nz
	;--
	; If we aren't in an autoscrolling mode, stop movement when there's a
	; solid block on the right.
	call Level_ScreenLock_DoRight	; Update screen lock
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_CHKAUTO		; Are we in an autoscrolling mode?			
	jr   nc, .tryScrollScreen				; If so, always move the screen
	call PlBGColi_DoRightStub		; Handle collision on the right 
	dec  a							; Is there a solid block on the right?
	ret  z							; If so, stop further movement
.tryScrollScreen:
	; Scroll the screen right if there isn't a screen lock
	ld   b, $01						; B = Movement speed
	ld   a, [sLvlScrollLockCur]
	and  a, DIR_L|DIR_R				; Is there a screen lock?
	jr   nz, .chkScroll				; If so, jump
	
	ld   a, [sLvlScrollHAmount]		; Otherwise scroll the screen
	add  b
	ld   [sLvlScrollHAmount], a
.chkScroll:
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_CHKAUTO		; Are we in an autoscrolling mode?
	jr   nc, .autoRight				; If so, perform boundary checking
.moveRight:
	call Pl_MoveRight
	ret
.autoRight:
	ld   a, [sPlXRel]
	cp   a, OBJ_OFFSET_X			; Is the player near the left screen border?
	ret  nc							; If not, return
	
	call PlBGColi_DoRightStub		; If so, handle collision on the right
	dec  a							; Is there a solid block on the right?
	jp   z, Pl_StartDeathAnim		; If so, trigger the instadeath since the block would push us offscreen
	ld   b, $01						; Otherwise, move the player right to keep him on-screen
	jr   .moveRight
	
; =============== PlBGColi_CheckGroundSolidOrMove ===============
; Checks for fall collision while in the read-only mode, used for secondary checking by a few blocks.
; If there isn't a solid block below, the player is moved downwards.
; Uses:
;  - After stepping on a collapsing bridge, since you can trigger the bridge 
;    by touching the block's edge while standing in a solid block.
;    If there isn't, it moves the player down to firmly stand on the bridge actor.
PlBGColi_CheckGroundSolidOrMove:
	ld   a, [sPlActSolid]		; Save actor collision flag
	ld   [sPlActSolid_Bak], a
	;--
	xor  a						; Ignore actor collision
	ld   [sPlActSolid], a
	ld   a, $01					; Don't trigger certain blocks (like breakable ones), we're just checking...
	ld   [sPlBGColiSolidReadOnly], a
	;--
	push bc
	call PlBGColi_DoGround
	pop  bc
	;--
	dec  a						; Is the collison type reported as solid? ($01)
	jr   z, .noMove				; If so, don't move the player downwards
	call Pl_MoveDown
.noMove:
	xor  a
	ld   [sPlBGColiSolidReadOnly], a
	;--
	ld   a, [sPlActSolid_Bak]
	ld   [sPlActSolid], a
	ret
	
; =============== PlBGColi_DoTopAndMove ===============
; Moves the player up, while also handling collision detection as if the player was jumping.
;
; This is used when being moved upwards by an actor -- if Pl_MoveUp was called directly
; we could be moved through blocks without registering any collision.
;
; IN
; - B: Pixels of movement
PlBGColi_DoTopAndMove:
	push bc
	call PlBGColi_DoTopStub
	pop  bc
	call Pl_MoveUp
	ret
; =============== Level_Scroll_SetAutoScroll ===============
; This subroutine defines the forced autoscroll speed for autoscrolling levels.
Level_Scroll_SetAutoScroll:
	; Depending on the current scroll mode, force (or not) an autoscroll speed.
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_NONE		; Boss mode?
	jr   z, .noForce
	cp   a, LVLSCROLL_CHKAUTO	; No autoscroll? (< $20)
	jr   c, .noForce			; If so, jump
	cp   a, LVLSCROLL_AUTOL		; Left autoscroll?
	jr   z, .forceLeft			; If so, jump
.forceRight:
	; Right autoscroll speed: 0.5px/frame
	ld   a, DIR_R
	ld   [sLvlAutoScrollDir], a
	ld   a, $01					; Move 1px every other frame
	ld   [sLvlAutoScrollSpeed], a
.noForce:
	; If jumping directly here, no autoscroll speed is forced.
	; In the normal scroll modes in particular, this allows conveyor belts
	; and water currents to work properly (since they use sLvlAutoScrollSpeed too)
	
	; If we're trying to scroll somewhere, move the screen
	ld   a, [sLvlAutoScrollSpeed]
	ld   b, a						; B = ScrollSpeed
	ld   a, [sLvlAutoScrollDir]		; A = ScrollDir
	and  a							; Are we scrolling anywhere?
	call nz, Level_Scroll_DoAutoScroll				; If so, jump
	ret
.forceLeft:
	; Left autoscroll speed: 0.5px/frame
	ld   a, DIR_L
	ld   [sLvlAutoScrollDir], a
	ld   a, $01					; Move 1px every other frame
	ld   [sLvlAutoScrollSpeed], a
	jr   .noForce
	
; =============== Level_Scroll_AddColumnTileIdUpCustom ===============
; [TCRF] Unreferenced code.
; Adds a column of blocks to the tile update list, starting from
; the lowest block and moving up.
; IN
; - HL: Ptr to the lowest block of the column from the level layout
; -  B: Number of blocks in the column
Level_Scroll_AddColumnTileIdUpCustom: 	
	call Level_Scroll_Unused_AddBlockIDsColUp
	call Level_Scroll_CreateTileIdList
	ret  
	
; =============== Level_Scroll_AddColumnTileIdCustom ===============
; Adds a column of blocks to the tile update list.
; IN
; - HL: Ptr to the topmost block of the column from the level layout
; -  B: Number of blocks in the column
Level_Scroll_AddColumnTileIdCustom:
	call Level_Scroll_AddBlockIDsCol2
	call Level_Scroll_CreateTileIdList
	ret
; =============== Level_Scroll_AddRowTileId ===============
; Adds a row of $0B blocks to the tile update list.
; IN
; - HL: Ptr to the topmost block of the row from the level layout
; -  B: Number of blocks in the row
Level_Scroll_AddRowTileId:
	call Level_Scroll_AddBlockIDsRow
	call Level_Scroll_CreateTileIdList
	ret
	
; =============== Level_Scroll_Unused_AddBlockIDsColReverse ===============
; [TCRF] Unused code only used by unreferenced code.
;
; Pratically identical to Level_Scroll_AddBlockIDsCol, except it moves
; up one block instead of moving down.
;
; IN
; - HL: Ptr to the level layout
; -  B: Blocks to copy
Level_Scroll_Unused_AddBlockIDsColUp: 
	ld   de, sLvlScrollBlockTable
.loop:
	ld   a, [hl]	; Copy block ID over (without actor flag)
	and  a, $7F
	ld   [de], a
	inc  e			; Next table entry
	dec  h			; Move 1 block up in the level layout ($100 bytes)
	
	dec  b			; Are we done yet?
	jr   nz, .loop	; If not, loop
	ld   a, $FF		; Add the end terminator
	ld   [de], a
	ret

; =============== Level_Scroll_AddBlockIDsRow ===============
; This subroutine adds a row of $0D block IDs to the block ID write list.
; Meant to be used for level scrolling.
;
; See also: Level_Scroll_AddBlockIDsCol
;
; IN
; - HL: Ptr to the level layout
Level_Scroll_AddBlockIDsRow:
	ld   b, $0D		; B = Blocks to copy
	ld   de, sLvlScrollBlockTable	; DE = Destination
.loop:
	ldi  a, [hl]	; Copy block ID over (without actor flag); also move 1 block right
	and  a, $7F
	ld   [de], a					
	inc  e			; Next table entry
	
	dec  b			; Are we done yet?
	jr   nz, .loop	; If not, loop
	
	ld   a, $FF		; Add the end terminator
	ld   [de], a
	ret
	
; =============== Level_Scroll_Unused_ReplaceBlockBGPtr ===============
; [TCRF] Unreferenced subroutine.
;        Replaces a tilemap pointer in the table for level scrolling
;        at the specified offset with the specified value.
;        Essentially does this: sLvlScrollBGPtrWriteTable[B] = HL;
; IN
; - HL: Updated tilemap pointer for the block
; -  B: Offset to the table. 
;       Because it's an *offset* and not an index, it must be an even value.
Level_Scroll_Unused_ReplaceBlockBGPtr:
	; Save for later the new tilemap pointer
	ld   d, h	; DE = HL
	ld   e, l
	
	; Offset the tilemap pointers table
	ld   hl, sLvlScrollBGPtrWriteTable	; HL = BGPtrTable 
	ld   a, l							; HL += B
	add  b
	ld   l, a
	
	; Write the new tilemap pointer to the table.
	ld   a, d		; Write high byte
	ldi  [hl], a
	ld   a, e		; Write low byte
	ldi  [hl], a
	ret  
	
; =============== Level_Scroll_Unused_ReplaceBlockID ===============
; [TCRF] Unreferenced subroutine.
;        Replaces a block ID in the table for level scrolling
;        at the specified index with the specified value.
;        Essentially does this: sLvlScrollBlockTable[C] = A;
; IN
; - A: Updated block ID
; - C: Index to block ID table
Level_Scroll_Unused_ReplaceBlockID:

	;--
	ld   [sTmp_Unused_A979], a		; Save A
	ld   de, sLvlScrollBlockTable	; DE = BlockIDTable
	ld   a, e						; Index it
	add  c
	ld   e, a
	ld   a, [sTmp_Unused_A979]		; Restore A
	;--
	ld   [de], a					; Write the new block ID
	ret
	
; =============== Level_Scroll_Unused_MakeBlockBGPtrTable ===============
; [TCRF] Unreferenced subroutine.
; Generates a table of pointers to the tilemap in 16x16 table for level scrolling. Purpose unknown.
;
; Interestingly, every time it writes to an entry in the table, the value
; that's written will be decreased to move up by a block.
;
; IN
; - HL: Initial tilemap pointer for the block.
; -  B: Slots to write.
Level_Scroll_Unused_MakeBlockBGPtrTable:
	ld   d, h							; DE = Initial block BG pointer
	ld   e, l
	ld   hl, sLvlScrollBGPtrWriteTable	; HL = Start of block BG ptr table
.loop:
	; Write the tilemap pointer to the current table entry.
	; This is meant to point to the upper-left 8x8 tile of the 16x16 block, as usual.
	ld   a, d			
	ldi  [hl], a
	ld   a, e
	ldi  [hl], a
	
	;--
	; Update the tilemap pointer.
	; Make it point a block above, which means decrease the value to write by $40.
	;
	; DE -= 40
	sub  a, BG_TILECOUNT_H*BG_BLOCK_HEIGHT	; E -= $40
	ld   e, a
	jr   nc, .nextWrite	; Underflowed? If not, skip
	dec  d				; D -= 1
	ld   a, d			
	;--
	
	; If we went above the start of the tilemap area (right into the tiles GFX).
	; loop to the bottom of the tilemap.
	cp   a, HIGH(BGMap_Begin-1)	; DE == $97**?
	jr   nz, .nextWrite			; If not, skip
	ld   d, HIGH(BGMap_End-1)	; Otherwise, loop back to the bottom
.nextWrite:
	dec  b						; Are we done?
	jr   nz, .loop				; If not, loop
	; Add a separator.
	ld   [hl], $FF
	ret

; =============== Level_Scroll_AddBGPtrRow ===============
; This subroutine adds BG pointers for a row of $0D blocks.
; Meant to be used for level scrolling downwards or updwards.
; IN
; - HL: Ptr to tilemap (VRAM address)
Level_Scroll_AddBGPtrRow:
	ld   d, h		; DE = Initial address
	ld   e, l
	ld   b, $0D		; B = Blocks in a row
	ld   hl, sLvlScrollBGPtrWriteTable	; HL = Destination
.nextBlock:
	; Copy directly the pointer
	ld   a, d
	ldi  [hl], a
	ld   a, e
	ldi  [hl], a
	
	;--
	; DE += $02
	; Add 2 tiles to move right by 1 block
	add  $02
	ld   e, a
	
	; Did we reach the end of the tilemap?
	; (this works since it will be in range $02-$20)
	and  a, BG_TILECOUNT_H-1	
	jr   nz, .checkNext
	; If so, wrap back to the beginning of the row
	ld   a, e
	sub  a, BG_TILECOUNT_H
	ld   e, a
	
.checkNext:
	; Did we write all VRAM ptrs?
	dec  b
	jr   nz, .nextBlock
	; If so, write the end separator
	ld   [hl], $FF
	ret
; =============== Mode_Null ===============
; [TCRF] Dummy game mode which does nothing at all.
;        This is also the last valid game mode.
Mode_Null: 
	ret
; =============== StatusBar_LoadBG ===============
; Sets up the tilemap for the status bar to the WINDOW area.
StatusBar_LoadBG:
	; Copy the two rows of the tilemap
	ld   hl, BG_StatusBar
	ld   de, vBGStatusBarRow0
	ld   b, (BG_StatusBar.end - BG_StatusBar) / 2
	call CopyBytes
	ld   de, vBGStatusBarRow1
	ld   b, (BG_StatusBar.end - BG_StatusBar) / 2
	call CopyBytes
	
	; Set the course number
	ld   hl, vBGStatusBarCourseNum
	
	ld   a, [sCourseNum]	; 1st digit
	swap a
	and  a, $0F				; high nybble + digit base
	add  TILEID_DIGITS
	ldi  [hl], a
	
	ld   a, [sCourseNum]	; 2nd digit
	and  a, $0F				; low nybble + digit base
	add  TILEID_DIGITS
	ld   [hl], a
	
	; Init level stat
	xor  a
	ld   [sLevelCoins_Low], a
	ld   [sLevelCoins_High], a
	; Set status bar position
	ld   a, $88
	ldh  [rWY], a
	ld   a, $07
	ldh  [rWX], a
	ret
BG_StatusBar: INCBIN "data/bg/statusbar.bin"
.end:

; ==============================================================================
; =============== Various helper macros for Game_DoHatSwitchAnim ===============
; ==============================================================================

; =============== mHatSwitch_Timing ===============
; Every 4 frames decrements the hat switch timer.
MACRO mHatSwitch_Timing
	ld   a, [sTimer]
	and  a, $03
	ret  nz
	ld   a, [sPlHatSwitchTimer]
	dec  a
	ld   [sPlHatSwitchTimer], a
ENDM

; =============== mHatSwitch_BigToSmall ===============
; Template macro for switching to Small Wario.
; IN
; - 1: Label to subroutine for setting OBJLst (even timer ticks)
; - 2: Label to subroutine for setting OBJLst (odd timer ticks)
MACRO mHatSwitch_BigToSmall
	mHatSwitch_BigToSmallEx \1,\2,jp,jp,jp
ENDM

; =============== mHatSwitch_BigToSmallEx ===============
; Template macro for switching to Small Wario.
; IN
; - 1: Label to subroutine for setting OBJLst (even timer ticks)
; - 2: Label to subroutine for setting OBJLst (odd timer ticks)
; - 3: Jump type for Game_HatSwitchAnim_End
; - 4: Jump type for \1
; - 5: Jump type for \2
MACRO mHatSwitch_BigToSmallEx
	mHatSwitch_Timing
	
	; If it elapsed, reload the final graphics and then cleanup
	; (which takes up multiple frames)
	\3   z, Game_HatSwitchAnim_End
	
	; Otherwise, alternate between the small and big Wario frames,
	; depending on the timer being odd/even.
	bit  0, a		; Is it even?
	\4   z, \1		; If so, jump
	\5   \2
ENDM

; =============== mHatSwitch_BigToSmall2 ===============
; Template macro for switching to Small Wario from a non-garlic powerup.
; IN
; - 1: Label to subroutine for setting OBJLst (even timer ticks)
; - 2: Label to subroutine for setting OBJLst (odd timer ticks)
MACRO mHatSwitch_BigToSmall2
	mHatSwitch_BigToSmall2Ex \1,\2,jp,jp,jp,jp,jp
ENDM

; =============== mHatSwitch_BigToSmall2Ex ===============
; Template macro for switching to Small Wario from a non-garlic powerup.
; IN
; - 1: Label to subroutine for setting OBJLst (even timer ticks)
; - 2: Label to subroutine for setting OBJLst (odd timer ticks)
; - 3: Jump type for Game_HatSwitchAnim_End
; - 4: Jump type for Game_HatSwitchAnim_SetHatSecToEnd
; - 5: Jump type for Game_HatSwitchAnim_EndSwitchLoopNormHat
; - 6: Jump type for \1
; - 7: Jump type for \2
MACRO mHatSwitch_BigToSmall2Ex
	; If we've already copied both sets, do the main anim effect
	ld   a, [sPlHatSwitchDrawMode]
	cp   a, PL_HSD_END							; Anim frame? (+timer decrement)
	\3   z, Game_HatSwitchAnim_End				; If so, jump
	;--
	; If we've copied the primary sey already, copy the secondary one
	cp   a, PL_HSD_SEC							; Secondary GFX set?
	\4   z, Game_HatSwitchAnim_SetHatSecToEnd	; If so, jump
	
	
	mHatSwitch_Timing
	; If it elapsed, reload the final graphics and then cleanup
	; (which takes up multiple frames)
	\5   z, Game_HatSwitchAnim_EndSwitchLoopNormHat
	
	; Otherwise, alternate between the small and big Wario frames,
	; depending on the timer being odd/even.
	bit  0, a		; Is it even?
	\6   z, \1		; If so, jump
	\7   \2
ENDM

; =============== mHatSwitch_SmallToBig ===============
; Template macro for switching from Small Wario to another powerup state.
; IN
; - 1: ScreenUpdate mode for writing the primary GFX set.
MACRO mHatSwitch_SmallToBig
	; Since Small Wario doesn't have an hat, we don't need to switch the hat GFX
	; over and over unlike in other templates.
	;
	; So the very first thing we do is copying over both the primary and secondary sets of the new hat GFX.
	; This will take 2 frames since it's handled by two different screen events.
	; Only after that is done, we can start switching between anim frames (in .decTimer)
	
	; If we've already copied both sets, do the main anim effect
	ld   a, [sPlHatSwitchDrawMode]
	cp   a, PL_HSD_END							; Anim frame? (+timer decrement)
	jr   z, .decTimer							; If so, jump
	;--
	; If we've copied the primary sey already, copy the secondary one
	cp   a, PL_HSD_SEC							; Secondary GFX set?
	jp   z, Game_HatSwitchAnim_SetHatSecToEnd	; If so, jump
	
	; Otherwise, set the primary GFX set
	ld   a, \1					
	ld   [sScreenUpdateMode], a
	ld   a, PL_HSD_SEC							; Copy the sec set next time
	ld   [sPlHatSwitchDrawMode], a
	ret
ENDM

; =============== mHatSwitch_BigToBig ===============
; Template macro for switching hats.
; This is the standard template for performing hat to hat switches, which is the common case.
; IN
; - 1: Label to subroutine for setting the hat mode (even timer ticks)
; - 2: Label to subroutine for setting the hat mode (odd timer ticks)
MACRO mHatSwitch_BigToBig
	mHatSwitch_BigToBigEx \1,\2, jp,jp,jp,jp,jp
ENDM

; =============== mHatSwitch_BigToBigEx ===============
; Template macro for switching hats.
; This is the standard template for performing hat to hat switches, which is the common case.
; IN
; - 1: Label to subroutine for setting the hat mode (even timer ticks)
; - 2: Label to subroutine for setting the hat mode (odd timer ticks)
; - 3: Jump type for Game_HatSwitchAnim_End
; - 4: Jump type for Game_HatSwitchAnim_SetHatSecToEnd
; - 5: Jump type for Game_HatSwitchAnim_EndSwitchLoop
; - 6: Jump type for \1
; - 7: Jump type for \2
MACRO mHatSwitch_BigToBigEx
	; The first thing we're doing is switching between old and new primary hat GFX
	; every 4 frames, as timed by the standard mHatSwitch_Timing. 
	; 
	; Only when the timer elapses, the secondary hat GFX are requested, which
	; also sets sPlHatSwitchDrawMode to PL_HSD_SEC.
	; After that it performs cleanup.
	;--
	
	; If we've already done the hat switch loop
	ld   a, [sPlHatSwitchDrawMode]
	cp   a, PL_HSD_END							; In cleanup mode?
	\3   z, Game_HatSwitchAnim_End				; If so, jump
	cp   a, PL_HSD_SEC							; Waiting to draw the secondary set?
	\4   z, Game_HatSwitchAnim_SetHatSecToEnd	; If so, jump
	;--
	
	mHatSwitch_Timing							; Timer--
	
	; If it elapsed, start the DrawMode chain
	\5   z, Game_HatSwitchAnim_EndSwitchLoop
	
	; Otherwise, alternate between the two hats on odd/even frames.
	bit  0, a		; Is it even?
	\6   z, \1		; If so, jump
	\7   \2
ENDM

; =============== Game_DoHatSwitchAnim ===============
; This subroutine performs the animation when updating the powerup status (hat switch animation).
; In common between all subroutines is that any or both of these effects can happen:
; - Switching back and forth between the primary set of the old and new hat GFX.
;   After the animation is over, the secondary set is copied.
; - Switching back and forth between the *standing* frame of Normal and Small Wario.
Game_DoHatSwitchAnim:
	; During this anim, the powerup status is set in a slightly different way than normal.
	; We need to know the old powerup status to switch the GFX back to it, so what the game does
	; is split the nybbles of sPlPower, which works since the player status has a $0-$4 range:
	;
	; High nybble -> Old Powerup
	; Low  nybble -> New Powerup
	;
	; NOTE: Regardless of the back and forth effect, this value remains the same for the
	;       entire duration of the effect.
	; Obviously once the effect is over, the old powerup status should be removed since it would make it an invalid powerup.
	
	; Start by checking which is the old powerup, so we check the high nybble.
	ld   a, [sPlPower]
	cp   a, PL_POW_DRAGON << 4				; >= $40?
	jp   nc, Game_HatSwitchAnim_FromDragon	; If so, jump
	cp   a, PL_POW_JET << 4					; ...
	jp   nc, Game_HatSwitchAnim_FromJet
	cp   a, PL_POW_BULL << 4
	jp   nc, Game_HatSwitchAnim_FromBull
	cp   a, PL_POW_GARLIC << 4
	jr   nc, Game_HatSwitchAnim_FromGarlic
; =============== Game_HatSwitchAnim_FromSmall ===============
Game_HatSwitchAnim_FromSmall:
	cp   a, PL_POW_DRAGON
	jr   z, .toDragon
	cp   a, PL_POW_JET
	jr   z, .toJet
	cp   a, PL_POW_BULL
	jr   z, .toBull
.toGarlic: ; PL_POW_GARLIC
	; Internally, Small Wario has the same hat GFX as the Garlic Powerup.
	; the game simply doesn't display it since the Small Wario OBJLst does not use those tiles.
	; As a result, we don't need to update the hat GFX when going from Small to Garlic.
	
.decTimer: 	mHatSwitch_BigToSmall Game_HatSwitch_SetSmallLstId, Game_HatSwitch_SetNormLstId
.toBull: 	mHatSwitch_SmallToBig SCRUPD_BULLHAT
.toJet: 	mHatSwitch_SmallToBig SCRUPD_JETHAT
.toDragon: 	mHatSwitch_SmallToBig SCRUPD_DRAGHAT
; =============== Game_HatSwitchAnim_FromGarlic ===============
Game_HatSwitchAnim_FromGarlic:
	and  a, $0F					; Filter old powerup status
	cp   a, PL_POW_DRAGON
	jr   z, .toDragon
	cp   a, PL_POW_JET
	jr   z, .toJet
	cp   a, PL_POW_BULL
	jr   z, .toBull
.toSmall:	mHatSwitch_BigToSmall	Game_HatSwitch_SetNormLstId,	Game_HatSwitch_SetSmallLstId
.toBull:	mHatSwitch_BigToBig 	Game_HatSwitch_SetNormHatMode, 	Game_HatSwitch_SetBullHatMode
.toJet:		mHatSwitch_BigToBig 	Game_HatSwitch_SetNormHatMode, 	Game_HatSwitch_SetJetHatMode
.toDragon:	mHatSwitch_BigToBig 	Game_HatSwitch_SetNormHatMode, 	Game_HatSwitch_SetDragHatMode
; =============== Game_HatSwitchAnim_FromBull ===============
Game_HatSwitchAnim_FromBull:
	and  a, $0F
	cp   a, PL_POW_DRAGON
	jr   z, Game_HatSwitchAnim_EndSwitchLoopNormHat.toDragon
	cp   a, PL_POW_JET
	jr   z, Game_HatSwitchAnim_EndSwitchLoopNormHat.toJet
	cp   a, PL_POW_GARLIC
	jr   z, Game_HatSwitchAnim_EndSwitchLoopNormHat.toGarlic
.toSmall: 	mHatSwitch_BigToSmall2Ex Game_HatSwitch_SetNormLstId, 	Game_HatSwitch_SetSmallLstId, jp,jp,jr,jp,jp
Game_HatSwitchAnim_EndSwitchLoopNormHat:
	; Sets the correct hat GFX when switching to Small Wario from a non-garlic powerup.
	ld   a, SCRUPD_NORMHAT
	ld   [sScreenUpdateMode], a
	jp   Game_HatSwitchAnim_EndSwitchLoop
.toGarlic: 	mHatSwitch_BigToBig 	Game_HatSwitch_SetBullHatMode, 	Game_HatSwitch_SetNormHatMode ; Ending-only
.toJet: 	mHatSwitch_BigToBig 	Game_HatSwitch_SetBullHatMode, 	Game_HatSwitch_SetJetHatMode
.toDragon: 	mHatSwitch_BigToBig 	Game_HatSwitch_SetBullHatMode, 	Game_HatSwitch_SetDragHatMode
; =============== Game_HatSwitchAnim_FromJet ===============
Game_HatSwitchAnim_FromJet:
	and  a, $0F
	cp   a, PL_POW_DRAGON
	jr   z, .toDragon
	cp   a, PL_POW_BULL
	jr   z, .toBull
	cp   a, PL_POW_GARLIC
	jr   z, .toGarlic
.toSmall:	mHatSwitch_BigToSmall2 	Game_HatSwitch_SetNormLstId, 	Game_HatSwitch_SetSmallLstId
.toGarlic:	mHatSwitch_BigToBigEx 	Game_HatSwitch_SetJetHatMode, 	Game_HatSwitch_SetNormHatMode,  jr,jp,jp,jp,jp ; Ending-only
.toBull: 	mHatSwitch_BigToBigEx 	Game_HatSwitch_SetJetHatMode, 	Game_HatSwitch_SetBullHatMode,  jr,jp,jp,jp,jp 
.toDragon:	mHatSwitch_BigToBigEx 	Game_HatSwitch_SetJetHatMode, 	Game_HatSwitch_SetDragHatMode,  jr,jp,jp,jp,jp 

; =============== Game_HatSwitchAnim_End ===============
; Performs cleanup for hat switch animations.
;
; This subroutine first draws the final hat GFX (both primary and secondary sets),
; to account for hat switch animations which don't update the hat GFX themselves.
; Then it performs the final cleanup before ending the powerup switch animation.
;
; This is done in multiple frames -- the reason for this is due to the hat switch requests.
; Those are only handled during VBlank as screen event modes, and only one can be active at a time.
; Since the primary and secondary GFX copy modes are split for speed considerations, this results in:
; - Frame 0 to copy the primary set
; - Frame 1 to copy the secondary set
; - Frame 2 to perform the final cleanup
;
; When the Frame 2 ends, the hat switch animation is properly finished.
Game_HatSwitchAnim_End:

	; Which frame are we on now?
	ld   a, [sPlHatSwitchEndMode]
	dec  a							; == $01?
	jr   z, .frameDrawSec			; If so, draw the secondary set
	dec  a							; == $02?
	jr   z, .frameCleanup			; If so, perform final cleanup
.frameDrawPrimary:
	; In mode $00, we draw the permanent primary set GFX

	; The first two modes restore one tick to the elapsed hat switch timer.
	; This is because the main gameplay loop doesn't call the hat switch subroutine if
	; its timer is zero, which would be bad right now (bad sPlPower values and all).
	
	ld   a, $01
	ld   [sPlHatSwitchTimer], a
	ld   [sPlHatSwitchEndMode], a					; Switch to mode $01
	;--
	; Set the correct primary hat GFX mode for the current powerup status.
	; The primary mode IDs have the same values as the powerup IDs, except offset by 1.
	; (since the first mode went to SCRUPD_SCROLL, the level scroll mode). 
	ld   a, [sPlPower]			
	and  a, $0F						; Filter old powerup status (high nybble)
	inc  a							; Offset for SCRUPD_SCROLL
	ld   [sScreenUpdateMode], a
	
	; If the target powerup ID is $00 (ie: got hit and became Small Wario), we land in the unrelated scroll mode $01.
	; In case that happens, add 1 to silently correct that to SCRUPD_NORMHAT.
	cp   a, SCRUPD_SCROLL			
	ret  nz
	inc  a
	ld   [sScreenUpdateMode], a
	ret
	;--
.frameDrawSec:
	ld   a, $01						; Fixup timer
	ld   [sPlHatSwitchTimer], a
	inc  a							; Switch to mode $02
	ld   [sPlHatSwitchEndMode], a
	;--
	
	; Same note as Game_HatSwitchAnim_SetHatSecToEnd applies here.
	; For any given screen update mode for copying the primary hat GFX,
	; the correct one for copying the secondary GFX is 4 modes after.
	ld   a, [sScreenUpdateMode]
	add  $04
	ld   [sScreenUpdateMode], a
	ret
.frameCleanup:
	; Reset vars
	xor  a
	ld   [sPlHatSwitchEndMode], a					
	ld   [sPlHatSwitchDrawMode], a
	ld   [sPlHatSwitchTimer], a
	ld   [sPauseActors], a
	ld   [sScreenUpdateMode], a
	ld   [sPlSuperJump], a
	
	; Get rid of the old powerup status in the high nybble
	ld   a, [sPlPower]
	and  a, $0F
	ld   [sPlPower], a
	
	;--
	; Determine the correct combinations of anim frame / action flags
	
	; Set the Small Wario option only if we're in powerup state $00.
	; sSmallWario = (sPlPower == $00)
	jr   z, .isSmall
.notSmall:
	xor  a
	ld   [sSmallWario], a
	jr   .chkBump
.isSmall:
	ld   a, $01
	ld   [sSmallWario], a
.chkBump:

IF FIX_BUGS == 1
	; If we're underwater, mark that we were performing an action (to avoid spawning a water splash)
	ld   a, [sPlAction]
	cp   a, PL_ACT_SWIM			; Are we swimming?
	jr   z, .inWater			; If so, jump
	ld   a, [sPlSwimGround]
	and  a						; Are we walking on ground underwater?
	jr   z, .noWater			; If *not*, skip
.inWater:
	; ld   a, $01				; (not necessary, it'll be != 0 when we get here)
	ld   [sPlWaterAction], a    ; Mark an underwater action
.noWater:

ENDC

	; Reset the player action to fix possible Anim2Frame errors.
	call HomeCall_Pl_HatSwitchAnim_SetNextAction
	
	; If we took damage, sPlHurtType will be set to specific values.
	; For those values init the post-hit invincibility timer.
	; [POI] Curiously, there's no hard bump form being hit by a block,
	;       though being able to "double jump" partially makes up for it.
	
	ld   a, [sPlHurtType]
	cp   a, PL_HT_BGHURT		; Hit by a spike block?
	jr   z, .setPostHit			; If so, set the invincibility
	cp   a, PL_HT_ACTHURT		; Hit by an actor?
	jr   z, .setHardBump		; If so, do the same and also set the knockback
	
	; [POI] Determine if there's is enough space to uncrouch.
	; It isn't particularly clear why this is checked here, since it's done automatically.
	; Is it in case of going from Small to Big Wario in a 1-block high gap?
	; Is it to mask the 1-frame visual glitches caused by Pl_HatSwitchAnim_SetNextAction?
	; 
	; Whatever its intended purpose is, this does mean the player automatically
	; uncrouches if switching powerups while crouching and there's enough space on top.
	xor  a					; Temp unduck to verify what's on top
	ld   [sPlDuck], a
	ld   a, [sPlAction]	; Can't duck while swimming over the ground
	cp   a, PL_ACT_SWIM
	ret  z
	call PlBGColi_DoTopStub	; Handle collision for block on top.
	and  a	; COLI_EMPTY	; Is there an empty block on top?				
	ret  z					; If so, keep unducking
	ld   a, $01				; Otherwise duck since there isn't enough space
	ld   [sPlDuck], a
	ret
.setHardBump:
	call Pl_SwitchToHardBump
.setPostHit:
	ld   a, $40
	ld   [sPlPostHitInvulnTimer], a
	ret
	
; =============== Game_HatSwitch_Set*LstId ===============
; Sets of subroutines for updating the player sprite, when the powerup switch
; involves Small Wario somewhere.

IF FIX_BUGS == 1
	; Account for collecting a powerup while climbing.
Game_HatSwitch_SetNormLstId:
	ld   a, [sPlAction]
	cp   a, PL_ACT_CLIMB				; Are we climbing?
	ld   a, OBJ_WARIO_CLIMB0			; A = Sprite ID (special)
	jr   z, .end						; If so, skip
	ld   a, OBJ_WARIO_STAND				; A = Sprite ID (normal)
.end:
	ld   [sPlLstId], a
	ret
Game_HatSwitch_SetSmallLstId:
	ld   a, [sPlAction]
	cp   a, PL_ACT_CLIMB				; Are we climbing?		
	ld   a, OBJ_SMALLWARIO_CLIMB0		; A = Sprite ID (special)
	jr   z, .end						; If so, skip
	ld   a, OBJ_SMALLWARIO_STAND		; A = Sprite ID (normal)
.end:
	ld   [sPlLstId], a
	ret
ELSE
Game_HatSwitch_SetNormLstId:
	ld   a, OBJ_WARIO_STAND
	ld   [sPlLstId], a
	ret
Game_HatSwitch_SetSmallLstId:
	ld   a, OBJ_SMALLWARIO_STAND
	ld   [sPlLstId], a
	ret
ENDC

	
; =============== Game_HatSwitchAnim_EndSwitchLoop ===============
; This sets the HatSwitchDrawMode which requests the screen update mode 
; for the secondary hat GFX.
;
; Because of the way sPlHatSwitchDrawMode is checked, this will end
; the primary hat switching loop as seen in mHatSwitch_BigToBig.
Game_HatSwitchAnim_EndSwitchLoop:
	ld   a, PL_HSD_SEC				; A = $01
	ld   [sPlHatSwitchDrawMode], a
	
	; The timer is $00 when we get here.
	; The main gameplay loop won't call the hat switch routine if we don't 
	; update it to something else, which would be bad.
	ld   [sPlHatSwitchTimer], a		
	ret

; =============== Game_HatSwitch_Set*HatMode ===============
; Sets of subroutines for updating to the respective screen update mode,
; for setting the primary set of hat GFX.


IF FIX_BUGS == 1

; =============== mSetMainHatMode*HatMode ===============
; Generates code for versions of Game_HatSwitch_Set*HatMode that account for collecting a powerup while climbing.
; IN
; - \1: Hat ID
MACRO mSetMainHatMode
	; When facing back, set the secondary mode instead
	ld   a, [sPlAction]
	cp   a, PL_ACT_CLIMB				; Are we climbing?
	ld   a, \1							;   (A = Hat ID)
	jr   z, Game_HatSwitch_SetSecFirst	; If so, jump
	ld   [sScreenUpdateMode], a
	ret
ENDM

Game_HatSwitch_SetNormHatMode: mSetMainHatMode SCRUPD_NORMHAT
Game_HatSwitch_SetBullHatMode: mSetMainHatMode SCRUPD_BULLHAT
Game_HatSwitch_SetJetHatMode:  mSetMainHatMode SCRUPD_JETHAT
Game_HatSwitch_SetDragHatMode: mSetMainHatMode SCRUPD_DRAGHAT
Game_HatSwitch_SetSecFirst:
	add  a, $04						; SCRUPD_NORMHAT_SEC - SCRUPD_NORMHAT, ...
	ld   [sScreenUpdateMode], a
	ret

ELSE
Game_HatSwitch_SetNormHatMode:
	ld   a, SCRUPD_NORMHAT
	ld   [sScreenUpdateMode], a
	ret
Game_HatSwitch_SetBullHatMode:
	ld   a, SCRUPD_BULLHAT
	ld   [sScreenUpdateMode], a
	ret
Game_HatSwitch_SetJetHatMode:
	ld   a, SCRUPD_JETHAT
	ld   [sScreenUpdateMode], a
	ret
Game_HatSwitch_SetDragHatMode:
	ld   a, SCRUPD_DRAGHAT
	ld   [sScreenUpdateMode], a
	ret			
ENDC

	
; =============== Game_HatSwitchAnim_SetHatSecToEnd ===============
; Sets up the screen update mode for copying the secondary hat GFX.
; This is usually one of the last things done before cleanup, but not always.
Game_HatSwitchAnim_SetHatSecToEnd:
	; For any given screen update mode for copying the primary hat GFX,
	; the correct one for copying the secondary GFX is 4 modes after.
	
	; [POI] This is not necessary to do.
	;       Game_HatSwitchAnim_End already redraws both primary and secondary sets for us later on.
IF FIX_BUGS == 0
	ld   a, [sScreenUpdateMode]
	add  $04 ; SCRUPD_NORMHAT_SEC - SCRUPD_NORMHAT, ...
	ld   [sScreenUpdateMode], a
ENDC
	
.end:
	; Increase the frame count (different purpose depending on where it's called)
	; Note how this is expected to be called when sPlHatSwitchDrawMode == PL_HSD_SEC.
	ld   a, PL_HSD_END
	ld   [sPlHatSwitchDrawMode], a
	ret
	

; =============== Game_HatSwitchAnim_FromDragon ===============
Game_HatSwitchAnim_FromDragon:
	and  a, $0F
	cp   a, PL_POW_JET
	jr   z, .toJet
	cp   a, PL_POW_BULL
	jr   z, .toBull
	cp   a, PL_POW_GARLIC
	jr   z, .toGarlic
IF FIX_BUGS == 1
	; with the fixes above, some jr's go out of range...
.toSmall: 	mHatSwitch_BigToSmall2Ex 	Game_HatSwitch_SetNormLstId, 	Game_HatSwitch_SetSmallLstId,   jp,jr,jp,jp,jp
.toGarlic: 	mHatSwitch_BigToBigEx 		Game_HatSwitch_SetDragHatMode, 	Game_HatSwitch_SetNormHatMode,  jp,jr,jp,jp,jp ; Ending-only
ELSE
.toSmall: 	mHatSwitch_BigToSmall2Ex 	Game_HatSwitch_SetNormLstId, 	Game_HatSwitch_SetSmallLstId,   jp,jr,jp,jr,jr
.toGarlic: 	mHatSwitch_BigToBigEx 		Game_HatSwitch_SetDragHatMode, 	Game_HatSwitch_SetNormHatMode,  jp,jr,jr,jr,jr ; Ending-only
ENDC
.toBull:	mHatSwitch_BigToBigEx 		Game_HatSwitch_SetDragHatMode, 	Game_HatSwitch_SetBullHatMode,  jp,jr,jp,jp,jp 
.toJet:		mHatSwitch_BigToBig 		Game_HatSwitch_SetDragHatMode, 	Game_HatSwitch_SetJetHatMode



; =============== Mode_LevelDoor ===============
; Handles door transitions.
Mode_LevelDoor:
	ld   a, [sSubMode]
	rst  $28
	dw Level_FadeOutOBJ0ToBlack
	dw Level_FadeOutBGToWhite
	dw Mode_LevelDoor_LoadRoom
	dw Level_FadeInBG
	dw Mode_LevelDoor_ChkBreakBlock
	dw Level_FadeInOBJ
	dw Mode_LevelDoor_SwitchToLevel
	
; =============== Level_FadeOutOBJ0ToBlack ===============
; Fades to black all sprites on-screen.
Level_FadeOutOBJ0ToBlack:
	;
	; Always draw and process actors + player
	;
	call HomeCall_WriteWarioOBJLst	; Draw Wario
	ld   a, $01						; Pause all actors
	ld   [sPauseActors], a
	call HomeCall_ActS_Do			; Draw the actors
	
; =============== Level_FadeOutOBJ0ToBlack_NoOBJDraw ===============
; [TCRF] This is specifically used in the ending... to avoid drawing actors while they fade out.
;        Which makes the fade out pointless in that case.
;        The only way this makes sense is if it only skipped processing actors, while still
;        drawing the player. Was it patched out by moving above "call HomeCall_WriteWarioOBJLst"?
Level_FadeOutOBJ0ToBlack_NoOBJDraw:
	; Every 8 frames...
	ld   a, [sTimer]
	and  a, $07			; Timer % 8 == 0?
	ret  nz				; If so, return
	
	; Unlike the map screen or the OBJ fade in, which uses hardcoded faded palettes,
	; this subroutine is called in multiple places that expect different palette fade out,
	; so we have to do it the proper way, by manually shifting the color bits.
	;
	; The GB palette has 4 colors, where each color is two bits long.
	; This gives a palette layout of: AABBCCDD.
	;
	; Each palette pair can have 4 possible values, which are ordered from light to black
	; with 0b00 being COL_WHITE, and 0b11 being COL_BLACK.
	;
	; All we need to do here is:
	; - Every 8 frames increase each of these pairs up by one
	; - When a pair reaches 0b11, stop increasing it
	; - When all 4 pairs are 0b11 (all palettes black, aka palette $FF), we're done
	;
	; To process every color pair, we >>r 2 the palette.
	; Once all four palettes are processed, the color order will fix itself.
	;
	
	ld   b, $04			; B = Colors pairs left to update
	ldh  a, [rOBP0]		; A = OBJ Palette
.loop:
	
	;--
	; Increase the color pair value up to COL_BLACK
	; E = MAX(A % 0b11 + 1, 3)
	ld   d, a			; Save palette
	and  a, $03			; Filter out the current color entry
	cp   a, $03			; Is this color already black?
	jr   z, .noDarken	; If so, don't darken it
	inc  a				; Darken this color
.noDarken:
	ld   e, a			; E = New color pair
	ld   a, d			; Restore palette
	;--
	
	; Replace the last color entry
	and  a, $FC			; Remove old bits 0 & 1
	add  e			; Set new bits 0 & 1
	; Rotate >> 2 to the next color entry
	rrca
	rrca
	
	dec  b				; Have we updated all colors yet?
	jr   nz, .loop		; If not, loop
	ldh  [rOBP0], a		; Write back the updated palette
	cp   a, $FF			; Are all colors black?
	ret  nz				; If not, we aren't done yet
.nextSubmode:
	ld   a, [sSubMode]	; Otherwise, switch to the next submode
	inc  a
	ld   [sSubMode], a
	ret
	
; =============== Mode_LevelDoor_LoadRoom ===============
; Loads in the new room in the current level.
Mode_LevelDoor_LoadRoom:
	call StopLCDOperation	; Pause display since we'll be copying a block of graphics
	xor  a
	ld   [sHurryUpBGM], a
	ld   hl, rIE			; Disable parallax
	res  IB_STAT, [hl]
	call ClearBGMap
	call ExActS_ClearRAM
	call Level_LoadRoomData	; Reload room GFX and other stuff
	
	call LevelDoor_ResetVars
	
	; If we just came back from the treasure room, reload the gameplay OBJ GFX block.
	; This is because the treasure room loads other graphics in their place, while
	; they get almost* never overwritten between rooms.
	; (* the exception being in boss rooms, where part of the shared OBJ graphics
	;    are overwritten to give more tiles to the boss, but there's no way to enter
	;    another room inside the boss room, so we don't check for it)
	ld   a, [sTreasureId]
	and  a
	call nz, LoadGFX_WarioWithPowerHat
	xor  a
	ld   [sTreasureId], a
	
	ld   a, [sSubMode]			; Next submode
	inc  a
	ld   [sSubMode], a
	; Reset mode for level
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	ldh  [rLCDC], a
	
	;
	; Initialize the proper scroll mode
	;
	ld   a, [sLvlScrollMode]
	
	; If we're entering a boss room, set its special flag
	cp   a, $F0					; ScrollMode >= $FO? (LVLSCROLL_NONE)
	jr   nc, .bossRoom			; If so, jump
	
	; Set up parallax if a level starts you in an auto-scrolling room.
	cp   a, LVLSCROLL_AUTOR		; Is this an auto-scrolling mode?
	ret  c						; If not (< $30), return
	;--
	cp   a, LVLSCROLL_AUTOR2	; Is this a non-parallax autoscroll mode?
	ret  nc						; If so (>= $40), return
	
	cp   a, LVLSCROLL_AUTOL		; Autoscrolling to the left?
	jr   nz, .autoRight		; If not, jump
.autoLeft:
	ld   a, PRX_TRAINMOUNTL
	ld   [sParallaxMode], a
.autoRight:	; defaults to PRX_TRAINMOUNTR ($00)

	; Enable LCDC parallax trigger
	xor  a
	ldh  [rIF], a
	ldh  [rLYC], a	; Trigger at scanline 0
	
	ld   hl, rIE	; Enable STAT
	set  IB_STAT, [hl]
	ld   a, $40		; Enable LYC trigger
	ldh  [rSTAT], a
	
	ldh  a, [rSCX]	; Keep current parameters for first trigger
	ld   [sParallaxX0], a
	ld   [sParallaxX1], a
	ret  
	
.bossRoom:
	ld   a, $01
	ld   [sBossRoom], a
	ret
; =============== Level_FadeInBG ===============
; Handles the fade in for the background tilemap.
Level_FadeInBG:
	; Switch palette every $08 frames
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	; Perform the fade from white.
	; Palette progression:
	; $00 -> $40 -> $90 -> (real palette)
	ldh  a, [rBGP]
	cp   a, $40
	jr   z, .set90
	cp   a, $90
	jr   z, .end
.set40:
	ld   a, $40
	ldh  [rBGP], a
	ret
.set90:
	ld   a, $90
	ldh  [rBGP], a
	ret
.end:
	; Set the real palette
	ld   a, [sBGP]
	ldh  [rBGP], a
	; Fade the OBP next
	ld   a, [sSubMode]
	inc  a
	ld   [sSubMode], a
	ret
	
; =============== Mode_LevelDoor_ChkBreakBlock ===============
; Checks if the door exit isn't obstructed by a breakable block.
Mode_LevelDoor_ChkBreakBlock:
	; [POI] If there's a breakable-to-door block where the door exit should be,
	;       re-enter the door instead of spawning inside the breakable blocks (ie: in C07).
	;       This is unusual to trigger, but it's possible.
	call PlBGColi_GetBlockIdLow			; A = Block ID overlapping with player (lower section)
	cp   a, BLOCKID_BREAKTODOOR			; Is it a breakable block (with door behind)?
	jr   z, .goBack						; If so, jump
	cp   a, BLOCKID_WATERBREAKTODOOR	; Is it a breakable block (with underwater door behind)?
	jr   nz, .ok						; If not, we're fine
	
.goBack:
	; Transition back to where we came from
	call Level_EnterDoor
	ld   a, GM_LEVELDOOR_LEVELFADEOUT	; Next mode
	ld   [sSubMode], a
	ret
.ok:
	call Level_SetScrollLevel
	ld   a, GM_LEVELDOOR_OBJFADEIN	; Next mode
	ld   [sSubMode], a
	ret
	
; =============== Level_FadeInOBJ ===============
; Handles the fade in for the OBJ.
Level_FadeInOBJ:
	call HomeCall_WriteWarioOBJLst
	; Every $08 frames update palette
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	; Perform the fade from black.
	; Palette progression:
	; $FF -> $BE -> $6D -> $1C
	ldh  a, [rOBP0]
	cp   a, $BE
	jr   z, .set6D
	cp   a, $6D
	jr   z, .set1C
	cp   a, $1C
	jr   z, .end
.setBE:
	ld   a, $BE
	ldh  [rOBP0], a
	ret
.set6D:
	ld   a, $6D
	ldh  [rOBP0], a
	ret
.set1C:
	ld   a, $1C
	ldh  [rOBP0], a
	ret
.end:
	ld   a, [sSubMode]
	inc  a
	ld   [sSubMode], a
	ret
	
; =============== Mode_LevelDoor_SwitchToLevel ===============
; The door transition is over and it switches to the main gameplay mode.
Mode_LevelDoor_SwitchToLevel:
	call HomeCall_WriteWarioOBJLst
	ld   a, GM_LEVEL				; Switch to gameplay
	ld   [sGameMode], a
	xor  a
	ld   [sSubMode], a
	ld   [sPauseActors], a			; Actors are frozen during the fade-in... unfreeze them
	ld   [sLvlBlockSwitchReq], a
	ret
	
; =============== Level_Scroll_Unused_DownScreenUpdateTest ===============
; [TCRF] Unreferenced subroutine.
; IN
; - HL: Level scroll position
Level_Scroll_Unused_DownScreenUpdateTest:
	; This is essentially identical to part of the code in Level_Scroll_SetScreenUpdate.checkDown.
	; The differences are:
	; - It uses the shorthand Level_Scroll_Get*BlockOffset
	; - It uses a different "end of row" check.
	;   Considering *where* this subroutine is located, it may have been used for debugging purposes.
	
	call Level_Scroll_GetYBlockOffset
	ld   a, HIGH(wLevelLayout)-LVLSCROLL_YBLOCKOFFSET+$0A	; +$0A block Y
	add  h
	
	ld   [sBlockTopLeftPtr_High], a
	call Level_Scroll_GetXBlockOffset
	
	ld   a, -LVLSCROLL_XBLOCKOFFSET-$01 ; -$01 block X
	add  l
	
	; If we're trying to draw on the last row of the level (we never get that far),
	; draw the first row instead.
	; Not sure what the point of this is, since it seems to cause discrepancies
	; with the horizontal movement code.
	cp   a, $FF							
	jr   nz, .writeDataDown
	xor  a ; We never get here
.writeDataDown:
	
	; Get the tilemap ptr from the level layout offset
	ld   l, a
	ld   [sBlockTopLeftPtr_Low], a
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	push hl
	call GetBGMapOffsetFromBlock
	
	; Write the actual row of screen update data
	call Level_Scroll_AddBGPtrRow	; VRAM pointers
	pop  hl
	
	call Level_Scroll_AddRowTileId	; Tile IDs
	ret
	
; =============== Level_Scroll_Unused_LeftScreenUpdateTest ===============
; [TCRF] Unreferenced subroutine.
Level_Scroll_Unused_LeftScreenUpdateTest:

	; This is essentially identical to part of the code in Level_Scroll_SetScreenUpdate.checkLeft.
	; The differences are:
	; - It uses the shorthand Level_Scroll_Get*BlockOffset
	; - The blocks aren't written in a column on the left side (& off-screen) of the screen,
	;   but as a visinle row of blocks from left to right.
	;   This detail suggests it was used for debugging (assuming it wasn't a mistake in copy/paste)
	
	; Create the level layout ptr
	; Col Offset:
	; - 2 blocks above
	; - 1 block to the left
	call Level_Scroll_GetYBlockOffset
	ld   a, HIGH(wLevelLayout)-LVLSCROLL_YBLOCKOFFSET-$02
	add  h
	ld   [sBlockTopLeftPtr_High], a
	
	call Level_Scroll_GetXBlockOffset
	ld   a, -LVLSCROLL_XBLOCKOFFSET-$01
	add  l
	
	; Get the tilemap ptr from the level layout offset
	ld   l, a
	ld   [sBlockTopLeftPtr_Low], a
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	push hl
	call GetBGMapOffsetFromBlock
	
	; Write what would be the actual column of screen update data...
	; but as a row instead!
	call Level_Scroll_AddBGPtrRow
	pop  hl
	call Level_Scroll_AddRowTileId
	ret

; =============== LevelDoor_ResetVars ===============
; Reset all variables when loading a new room.
LevelDoor_ResetVars:
	xor  a
	; Cancel any pending scroll requests
	ld   [sLvlScrollDir], a
	ld   [sLvlScrollVAmount], a
	ld   [sLvlScrollHAmount], a
	ld   [sLvlScrollUpdR0Y_High], a
	ld   [sLvlScrollUpdR0Y_Low], a
	ld   [sLvlScrollUpdR0X_High], a
	ld   [sLvlScrollUpdR0X_Low], a
	ld   [sLvlScrollUpdR1Y_High], a
	ld   [sLvlScrollUpdR1Y_Low], a
	ld   [sLvlScrollUpdR1X_High], a
	ld   [sLvlScrollUpdR1X_Low], a
	ld   [sLvlScrollUpdL0Y_High], a
	ld   [sLvlScrollUpdL0Y_Low], a
	ld   [sLvlScrollUpdL0X_High], a
	ld   [sLvlScrollUpdL0X_Low], a
	ld   [sLvlScrollUpdL1Y_High], a
	ld   [sLvlScrollUpdL1Y_Low], a
	ld   [sLvlScrollUpdL1X_High], a
	ld   [sLvlScrollUpdL1X_Low], a
	ld   [sLvlScrollUpdU0Y_High], a
	ld   [sLvlScrollUpdU0Y_Low], a
	ld   [sLvlScrollUpdU0X_High], a
	ld   [sLvlScrollUpdU0X_Low], a
	ld   [sLvlScrollUpdU1Y_High], a
	ld   [sLvlScrollUpdU1Y_Low], a
	ld   [sLvlScrollUpdU1X_High], a
	ld   [sLvlScrollUpdU1X_Low], a
	ld   [sLvlScrollUpdD0Y_High], a
	ld   [sLvlScrollUpdD0Y_Low], a
	ld   [sLvlScrollUpdD0X_High], a
	ld   [sLvlScrollUpdD0X_Low], a
	ld   [sLvlScrollUpdD1Y_High], a
	ld   [sLvlScrollUpdD1Y_Low], a
	ld   [sLvlScrollUpdD1X_High], a
	ld   [sLvlScrollUpdD1X_Low], a
	ld   [sTrainShakeTimer], a			; Stop the train shake effect
	ld   [sPlInvincibleTimer], a		; If we entered a door while invincible, end invincibility early
	ld   [sExActCount], a				; All ExAct are cleared anyway
	ret
	
; =============== Mode_Title_SaveSelectInit ===============
; Initializes the Save Select screen.
Mode_Title_SaveSelectInit:
	call StopLCDOperation
	call SaveSel_ValidateSaveFiles
	call HomeCall_LoadVRAM_SaveSelect
	; Reset coords
	xor  a
	ldh  [rSCY], a
	ldh  [hScrollY], a
	ldh  [rSCX], a
	ld   [sScrollX], a
	; Set palette
	ld   a, $D0
	ldh  [rBGP], a
	ld   a, $1C
	ldh  [rOBP0], a
	xor  a
	ldh  [rOBP1], a
	ld   a, $83
	ldh  [rLCDC], a
	ld   a, BGM_SAVESELECT
	ld   [sBGMSet], a
	; [POI] Checksum check
	ld   a, [sSaveFileError]
	and  a						; Are any saves marked as bad?
	jr   z, .allSaveOk			; If not, jump
	cp   a, %101				; Are multiple saves marked as bad?
	jr   nc, .skipErrorScreen	; If so, skip the error screen
	cp   a, %11
	jr   z, .skipErrorScreen	; See above
	
	; Otherwise, a single save has failed
	; Show the error screen 
	ld   a, GM_TITLE_SAVEERROR
	ld   [sSubMode], a
	call ExActS_SpawnSaveSel_Cross
	ret
.skipErrorScreen:
	xor  a
	ld   [sLastSave], a
.allSaveOk:
	call HomeCall_SaveSel_InitOBJ
	call SaveSel_SetAllClearPipes
	ld   a, $60						; Amount of frames before Wario appears
	ld   [sSaveWarioTimer], a
	ld   a, GM_TITLE_SAVESELINTRO0
	ld   [sSubMode], a
	ret
	
; =============== SaveSel_SetAllClearPipes ===============
; Initializes the ScreenEvent area of memory.
;
; This needs to be done even if no save files are marked as fully cleared,
; since sSavePipeAnimTiles is copied over to the tilemap every frame.
;
; This also generates a bitmask to determine the save files cleared.
SaveSel_SetAllClearPipes:
	; Copy the default ScreenEvent data
	ld   hl, BG_SaveSel_DefaultPipes
	ld   de, sSavePipeAnimTiles
	ld   b, (BG_SaveSel_DefaultPipes_End - BG_SaveSel_DefaultPipes)
	call CopyBytes
	
	; Generate the bitmask with the all cleared saves
	; This is a combination of the sSave?AllClear of each save.
	
	ld   hl, sSaveAllClear		; Initialize it to $00
	ld   [hl], $00
.checkSave1:
	ld   a, [sSave1+iSaveAllClear]
	and  a						; Is Save 1 marked as all clear?
	jr   z, .checkSave2			; If not, skip
	set  0, [hl]				; Otherwise, mark its bit
.checkSave2:
	ld   a, [sSave2+iSaveAllClear]
	and  a
	jr   z, .checkSave3
	set  1, [hl]
.checkSave3:
	ld   a, [sSave3+iSaveAllClear]
	and  a
	ret  z
	set  2, [hl]
	ret

BG_SaveSel_DefaultPipes: INCBIN "data/bg/saveselect_screenevent.bin"
BG_SaveSel_DefaultPipes_End:
; =============== ExActS_SpawnSaveSel_Cross ===============
; Sets up the actor for the wooden cross marking bad save files.
ExActS_SpawnSaveSel_Cross:          
	; Setup wooden cross actor
	ld   hl, sExActSet
	ld   a, EXACT_SAVESEL_CROSS
	ldi  [hl], a
	xor  a
	ldi  [hl], a	
	ldi  [hl], a	
	ldi  [hl], a	
	ldi  [hl], a	
	ld   a, OBJ_SAVESEL_CROSS	; Lst ID
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	;--
	; Coordinates
	ld   a, $89					; Fixed Y Position
	ldi  [hl], a
	
	; Determine the Fixed X position
	; It should go over the save file marked as bad
	ld   b, $24					; SAVE 1
	ld   a, [sSaveFileError]
	bit  0, a
	jr   nz, .end
	ld   b, $44					; SAVE 2
	bit  1, a
	jr   nz, .end
	ld   b, $64					; SAVE 3
.end:                   
	ld   a, b
	ldi  [hl], a
	;--
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	call ExActS_Spawn
	ret  

; =============== Mode_Title_SaveSelectIntroA ===============
; Parent handler for the first part of the Save Select intro,
; where Wario dashes on the ground.
Mode_Title_SaveSelectIntroA:
	ld   a, $0C*$04			; See end of SaveSel_WriteBrickOBJ
	ld   [sWorkOAMPos], a
	call SaveSel_DoBreakEffect
	call HomeCall_ExActS_ExecuteAll
	call SaveSel_DoIntroA
	call HomeCall_NonGame_WriteWarioOBJLst
	call HomeCall_SaveSel_AnimPipes
	ret
	
; =============== Mode_Title_SaveSelectIntroB ===============
; Parent handler for the second part of the Save Select intro.
Mode_Title_SaveSelectIntroB:
	ld   a, $06*$04			; The 6 brick OBJ are gone
	ld   [sWorkOAMPos], a
	call SaveSel_DoIntroB
	call HomeCall_NonGame_WriteWarioOBJLst
	call HomeCall_ExActS_ExecuteAll
	call HomeCall_SaveSel_AnimPipes
	ret
	
; =============== Mode_Title_SaveSelect ===============
; Parent handler for the Save Select screen (with player control).
Mode_Title_SaveSelect:
	ld   a, $06*$04
	ld   [sWorkOAMPos], a
	call SaveSel_Do
	call HomeCall_NonGame_WriteWarioOBJLst
	call HomeCall_ExActS_ExecuteAll
	call HomeCall_SaveSel_AnimPipes
	ret
	
; =============== Mode_Title_SaveSelectError ===============
; Handles the error message for bad save files.
Mode_Title_SaveSelectError:
	call HomeCall_ExActS_ExecuteAll
	; This basically applies event data.
	
	; Index the event tiles table
	ld   hl, Ev_SaveSel_BadSaveError_Tiles
	ld   a, [sSaveFileErrorCharId]
	ld   e, a
	ld   d, $00			; DE = CharId (index)
	add  hl, de	
	ld   a, [hl]		; Get the tile ID to write
	cp   a, $FE			; Is this a special command? (>= $FE)
	jr   nc, .specCmd	; If so, jump
	ld   b, a			; B = TileId
.getOffset:
	; Write a new tile every $08 frames
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	; Index the VRAM offsets table
	ld   hl, Ev_SaveSel_BadSaveError_Offsets
	ld   a, e		; DE = CharId * 2
	add  a
	ld   e, a
	add  hl, de		; Offset the table
	ldi  a, [hl]	; HL = Tilemap offset
	ld   l, [hl]
	ld   h, a
;--
.waitForTransfer:
	ldh  a, [rSTAT]
	and  a, ST_TRANSFER			
	jr   z, .waitForTransfer	; Wait for transfer
.waitTransfer:
	ldh  a, [rSTAT]
	and  a, ST_TRANSFER			
	jr   nz, .waitTransfer		; Wait for it to finish
;--
.writeTile:
	ld   [hl], b					; Write the tile ID
	ld   a, SFX4_0E					; Play cling SFX when it happens
	ld   [sSFX4Set], a
	ld   hl, sSaveFileErrorCharId	; Index++
	inc  [hl]
	ret  
.specCmd:
	cp   a, $FF						; Is this the end separator?
	jr   z, .checkKeys				; If so, don't write further tiles and check for input
	
	; Otherwise it's command $FE, which tells to write
	; the value of sSaveFileError.
	ld   b, $80						; B = TileId for "1"
	ld   a, [sSaveFileError]
	bit  0, a						; Is file 1 marked as bad?
	jr   nz, .getOffset				; If so, jump
	inc  b							; same for file 2	
	bit  1, a
	jr   nz, .getOffset
	inc  b							; otherwise it's file 3
	jr   .getOffset
.checkKeys:
	ldh  a, [hJoyNewKeys]		
	and  a, KEY_A|KEY_START		; Did we press A or START?
	ret  z						; If not, return
	
	; Otherwise, return to the proper save select mode
	xor  a
	ld   [sSaveFileErrorCharId], a
	call StopLCDOperation
	call SaveSel_ValidateSaveFiles
	call HomeCall_LoadVRAM_SaveSelect
	ld   a, LCDC_ENABLE|LCDC_OBJENABLE|LCDC_PRIORITY
	ldh  [rLCDC], a
	jp   Mode_Title_SaveSelectInit.allSaveOk

Ev_SaveSel_BadSaveError_Offsets: INCBIN "data/event/savesel_errortext.evp"
Ev_SaveSel_BadSaveError_Tiles:   INCBIN "data/event/savesel_errortext.evt"


; =============== SaveSel_Do ===============
; Handles the player control for the save select screen.
SaveSel_Do:
	call SaveSel_BombWario_Anim
	
	; Is there any active player action?
	ld   a, [sSavePlAct]
	dec  a	; $01
	jr   z, SaveSel_MoveRight
	dec  a	; $02
	jr   z, SaveSel_MoveLeft
	dec  a	; $03
	jp   z, SaveSel_JumpToBomb
	dec  a	; $04
	jp   z, SaveSel_JumpFromBomb
	dec  a	; $05
	jp   z, SaveSel_EnterPipe
	dec  a	; $06
	jp   z, SaveSel_ExitPipe
	dec  a	; $07
	jp   z, SaveSel_ExitPipeJump
	
	; Check for new player actions
	ldh  a, [hJoyNewKeys]
	bit  KEYB_A, a
	jp   nz, SaveSel_JumpToBombStart
	bit  KEYB_START, a
	jp   nz, SaveSel_EnterSaveStart
	bit  KEYB_DOWN, a
	jp   nz, SaveSel_EnterPipeStart
	
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jr   nz, SaveSel_MoveRightStart
	bit  KEYB_LEFT, a
	jr   nz, SaveSel_MoveLeftStart
	
	; If idle (and not Bomb Wario), reset the anim frame
	ld   a, [sSaveBombWario]
	and  a
	ret  nz
	ld   a, OBJ_WARIO_IDLE0
	ld   [sPlLstId], a
	ret
	
; =============== SaveSel_MoveRight ===============
; Moves the player to the right until the target position is reached.
SaveSel_MoveRight:
	call NonGame_Wario_AnimWalkFast
	ld   a, [sSaveTargetX]
	ld   b, a				; B = X Target
	ld   a, [sPlXRel]
	add  $02				; WX += $02
	ld   [sPlXRel], a
	cp   a, b				; Reached the target?
	ret  nz					; If not, return
	xor  a
	ld   [sSavePlAct], a	; Otherwise, end the walk
	ret
	
; =============== SaveSel_MoveLeft ===============
; Moves the player to the left until the target position is reached.
SaveSel_MoveLeft:
	call NonGame_Wario_AnimWalkFast
	ld   a, [sSaveTargetX]
	ld   b, a				; B = X Target
	ld   a, [sPlXRel]
	sub  a, $02				; WX -= $02
	ld   [sPlXRel], a
	cp   a, b				; Reached the target?
	ret  nz					; If not, return
	xor  a
	ld   [sSavePlAct], a	; Otherwise, end the walk
	ret
	
; =============== SaveSel_MoveRightStart ===============
; Starts movement to the right.
SaveSel_MoveRightStart:
	; Prevent going right if we're over Pipe 3 (including bomb pipe)
	ld   a, [sPlXRel]
	cp   a, SAVE_PIPE3_X
	ret  nc
	
	; Set target position X + $20
	ld   a, [sPlXRel]		
	add  SAVE_PIPE_XOFFSET
	ld   [sSaveTargetX], a
	ld   a, SAVE_PL_ACT_MOVERIGHT
	ld   [sSavePlAct], a
	ld   a, $20
	ld   [sPlFlags], a
	
	; If we aren't Bomb Wario, set the walking frame
	ld   a, [sSaveBombWario]
	and  a
	ret  nz
	xor  a
	ld   [sPlAnimTimer], a
	ld   a, OBJ_WARIO_WALK0
	ld   [sPlLstId], a
	ret
	
; =============== SaveSel_MoveLeftStart ===============
; Starts movement to the left.
SaveSel_MoveLeftStart:
	; Prevent going left if we're over Pipe 1
	ld   a, [sPlXRel]
	cp   a, SAVE_PIPE1_X
	ret  z
	
	; If we're on the bomb pipe, trigger different action
	cp   a, SAVE_PIPEBOMB_X
	jr   z, SaveSel_JumpFromBombStart
	
	; Set target position X - $20
	ld   a, [sPlXRel]
	sub  a, SAVE_PIPE_XOFFSET
	ld   [sSaveTargetX], a
	ld   a, SAVE_PL_ACT_MOVELEFT
	ld   [sSavePlAct], a
	xor  a
	ld   [sPlFlags], a
	
	; If we aren't Bomb Wario, set the walking frame
	ld   a, [sSaveBombWario]
	and  a
	ret  nz
	xor  a
	ld   [sPlAnimTimer], a
	ld   a, OBJ_WARIO_WALK0
	ld   [sPlLstId], a
	ret
	
; =============== SaveSel_JumpFromBombStart ===============
; Starts the jump off the bomb pipe.
SaveSel_JumpFromBombStart:
	ld   a, SFX1_05
	ld   [sSFX1Set], a
	ld   a, SAVE_PL_ACT_JUMPFROMBOMB
	ld   [sSavePlAct], a
	xor  a
	ld   [sSaveWarioYTblIndex], a
	ld   [sPlFlags], a
	
	; If we aren't Bomb Wario, set the jumping frame
	ld   a, [sSaveBombWario]
	and  a
	ret  nz
	ld   a, OBJ_WARIO_JUMP
	ld   [sPlLstId], a
	xor  a
	ld   [sPlAnimTimer], a
	ret
	
; =============== SaveSel_JumpToBombStart ===============
; Starts the jump to the bomb pipe.
SaveSel_JumpToBombStart:
	; Only if we're on the the last pipe
	ld   a, [sPlXRel]
	cp   a, SAVE_PIPE3_X
	ret  nz
	
	ld   a, SFX1_05
	ld   [sSFX1Set], a
	ld   a, SAVE_PL_ACT_JUMPTOBOMB
	ld   [sSavePlAct], a
	xor  a
	ld   [sSaveWarioYTblIndex], a
	ld   a, $20
	ld   [sPlFlags], a
	
	; If we aren't Bomb Wario, set the jumping frame
	ld   a, [sSaveBombWario]
	and  a
	ret  nz
	ld   a, OBJ_WARIO_JUMP
	ld   [sPlLstId], a
	xor  a
	ld   [sPlAnimTimer], a
	ret
	
; =============== SaveSel_JumpToBomb ===============
; Continues the jump to the bomb pipe.
SaveSel_JumpToBomb:
	; Apply Y offset for jump
	
	; To determine the Y offset we go off a table
	; Index it
	ld   hl, .jumpYTbl
	ld   a, [sSaveWarioYTblIndex]
	ld   e, a				; DE = Index
	ld   d, $00
	add  hl, de
	
	ld   a, [hl]			; Get the current Y offset
	cp   a, $80				; Have we reached the end separator?			
	jr   z, .end			; If so, jump
	ld   b, a				; WY += offset
	ld   a, [sPlYRel]
	add  b
	ld   [sPlYRel], a
	
	; Apply X offset for jump
	ld   a, [sPlXRel]
	add  $02				; Move 2px to the right
	ld   [sPlXRel], a
	
	ld   a, [sSaveWarioYTblIndex]	; Index++
	inc  a
	ld   [sSaveWarioYTblIndex], a
	ret
.end:
	xor  a
	ld   [sSavePlAct], a
	ld   a, SFX1_21
	ld   [sSFX1Set], a
	ret
.jumpYTbl: 
	db $FC,$FC,$FC,$FC,$FD,$FD,$FE,$FE,$FF,$FF,$00,$00,$00,$00,$01,$01
	db $02,$02,$03,$03,$80
	
; =============== SaveSel_JumpFromBomb ===============
; Continues the jump from the bomb pipe.
; Handled like SaveSel_JumpToBomb.
SaveSel_JumpFromBomb:
	; Index the Y offset table
	ld   hl, .jumpYTbl
	ld   a, [sSaveWarioYTblIndex]
	ld   e, a
	ld   d, $00
	add  hl, de
	; Check for table end
	ld   a, [hl]
	cp   a, $80
	jr   z, .end
	
	; Apply Y offset
	ld   b, a
	ld   a, [sPlYRel]
	add  b
	ld   [sPlYRel], a
	; Apply X offset
	ld   a, [sPlXRel]
	sub  a, $02
	ld   [sPlXRel], a
	
	; Index++
	ld   a, [sSaveWarioYTblIndex]
	inc  a
	ld   [sSaveWarioYTblIndex], a
	ret
.end:
	xor  a
	ld   [sSavePlAct], a
	ld   a, SFX1_21
	ld   [sSFX1Set], a
	ret
.jumpYTbl: 
	db $FD,$FD,$FE,$FE,$FF,$FF,$00,$00,$00,$00,$01,$01,$02,$02,$03,$03
	db $04,$04,$04,$04,$80
	
; =============== SaveSel_EnterSaveStart ===============
; Starts the entry to a pipe by pressing ENTER.
; Same as SaveSel_EnterPipeStart but with restrictions.
SaveSel_EnterSaveStart:
	ld   a, [sSaveBombWario]	; Not under Bomb Wario
	and  a
	ret  nz
	ld   a, [sPlXRel]		; Not over the bomb pipe
	cp   a, SAVE_PIPEBOMB_X
	ret  z
; =============== SaveSel_EnterPipeStart ===============
; Starts the entry to a pipe by pressing DOWN.
SaveSel_EnterPipeStart:
	ld   hl, sPlFlags
	set  7, [hl]					; Set BG priority bit
	ld   a, SAVE_PL_ACT_ENTERPIPE	; Play SFX
	ld   [sSavePlAct], a
	xor  a
	ld   [sSaveWarioYTblIndex], a	; Reset the index
	ld   a, SFX1_07
	ld   [sSFX1Set], a
	ret
	
; =============== SaveSel_EnterPipe ===============
; Continues the entry to a pipe.
SaveSel_EnterPipe:
	; Move Wario down by 1px
	ld   a, [sPlYRel]
	inc  a
	ld   [sPlYRel], a
	ld   a, [sSaveWarioYTblIndex]	; Keep track of px moved
	inc  a
	ld   [sSaveWarioYTblIndex], a
	cp   a, $20						; Moved down by 20px?
	ret  nz							; If not, wait
	
	;--
	; Once we're here, determine the action to take
	xor  a
	ld   [sSaveWarioYTblIndex], a
	
	ld   a, [sPlXRel]
	cp   a, SAVE_PIPEBOMB_X			; Are we on the bomb pipe?
	jr   nz, .filePipe				; If not, jump
.bombPipe:
	ld   a, SAVE_PL_ACT_EXITPIPE
	ld   [sSavePlAct], a
	xor  a
	ld   [sPlAnimTimer], a
	; Force left orientation
	ld   hl, sPlFlags
	res  5, [hl]
	; Invert Bomb Wario status
	ld   a, [sSaveBombWario]
	xor  $01
	; Pick the frame depending on
	ld   [sSaveBombWario], a
	and  a
	jr   z, .normFrame
.bombFrame:
	ld   a, OBJ_SAVESEL_BOMBWARIO0
	ld   [sPlLstId], a
	ret
.normFrame:
	ld   a, OBJ_SAVESEL_WARIO_LOOKUP
	ld   [sPlLstId], a
	ret
.filePipe:
	; We're over a savefile pipe
	;--
	; Update the last selected save value
	; Which one we're over?
	ld   b, $00				; Pipe 1?
	ld   a, [sPlXRel]
	cp   a, SAVE_PIPE1_X	
	jr   z, .pipeFound
	inc  b					; Pipe 2?
	cp   a, SAVE_PIPE2_X
	jr   z, .pipeFound
	inc  b					; Pipe 3!
.pipeFound:
	ld   a, b
	ld   [sLastSave], a
	;--
	; If we're Bomb Wario, delete the save file
	ld   a, [sSaveBombWario]
	and  a
	jr   nz, .clearSave
.enterLevel:
	call SaveSel_CopyAllFromSave
	; [BUG?] The fade out isn't heard properly
	; since it switches game modes and the music gets cut off
IF FIX_BUGS == 0
	ld   a, BGMACT_FADEOUT
	ld   [sBGMActSet], a
ENDC
	jp   Map_SwitchToMap
.clearSave:
	; Setup anim
	ld   a, SAVE_PL_ACT_EXITPIPE
	ld   [sSavePlAct], a
	ld   a, OBJ_SAVESEL_WARIO_LOOKUP
	ld   [sPlLstId], a
	; Clear bomb wario opt
	xor  a
	ld   [sPlAnimTimer], a
	ld   [sSaveBombWario], a
	ld   a, $01
	ld   [sNoReset], a
	ld   a, SFX1_0B
	ld   [sSFX4Set], a
	
	; Which save we're clearing?
	ld   a, [sLastSave]
	dec  a
	jr   z, .clearSave2
	dec  a
	jr   z, .clearSave3
	
.clearSave1:
	; Replace save data & checksum with old save
	ld   hl, SaveSel_EmptySave
	ld   de, sSave1
	ld   b, $20
	call CopyBytes
	ld   a, [hl]
	ld   [sSave1Checksum], a
	
	; Set completed levels count to 0
	ld   a, $A0
	ld   [sSaveDigit0+OAM_TILE], a
	ld   [sSaveDigit1+OAM_TILE], a
	
	; Remove all clear flag to stop that anim
	ld   hl, sSaveAllClear
	res  0, [hl]
	
	; Restore default pipe top
	ld   hl, BG_SaveSel_DefaultPipes
	ld   de, sSavePipeAnimTiles
	ld   b, $03
	call CopyBytes
	
	; We're done
	xor  a
	ld   [sNoReset], a
	ld   b, SAVE_PIPE1_X	; Where to spawn the smoke actor
	jr   .spawnSmoke
.clearSave2:
	ld   hl, SaveSel_EmptySave
	ld   de, sSave2
	ld   b, $20
	call CopyBytes
	ld   a, [hl]
	ld   [sSave2Checksum], a
	
	ld   a, $A0
	ld   [sSaveDigit2+OAM_TILE], a
	ld   [sSaveDigit3+OAM_TILE], a
	
	ld   hl, sSaveAllClear
	res  1, [hl]
	
	ld   hl, BG_SaveSel_DefaultPipes
	ld   de, sSavePipeAnimTiles + $03
	ld   b, $03
	call CopyBytes
	
	xor  a
	ld   [sNoReset], a
	ld   b, SAVE_PIPE2_X
	jr   .spawnSmoke
.clearSave3:
	ld   hl, SaveSel_EmptySave
	ld   de, sSave3
	ld   b, $20
	call CopyBytes
	ld   a, [hl]
	ld   [sSave3Checksum], a
	
	ld   a, $A0
	ld   [sSaveDigit4+OAM_TILE], a
	ld   [sSaveDigit5+OAM_TILE], a
	
	ld   hl, sSaveAllClear
	res  2, [hl]
	
	ld   hl, BG_SaveSel_DefaultPipes
	ld   de, sSavePipeAnimTiles + $06
	ld   b, $03
	call CopyBytes
	
	xor  a
	ld   [sNoReset], a
	ld   b, SAVE_PIPE3_X
.spawnSmoke:
	; Spawns the smoke coming out of a save file
	; after one is cleared
	ld   hl, sExActSet
	ld   a, EXACT_SAVESEL_SMOKE
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ld   a, OBJ_SAVESEL_SMOKE0
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ld   a, $78		; Y pos
	ldi  [hl], a
	ld   a, b		; X pos (over the save file)
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	call ExActS_Spawn
	ret
	
; =============== SaveSel_ExitPipe ===============
; Continues the exit from a pipe.
SaveSel_ExitPipe:
	; [TCRF] There was seemingly meant to be a delay before starting the pipe exit.
	;        But this timer is always $00 when we get here.
	ld   a, [sSaveWarioTimer]
	and  a
	jr   z, .main
	;--
	dec  a
	ld   [sSaveWarioTimer], a
	ret
	;--
.main:
	; Move Wario upwards by 1px
	ld   a, [sPlYRel]
	dec  a
	ld   [sPlYRel], a
	ld   a, [sSaveWarioYTblIndex]	; Keep track of movement
	inc  a
	ld   [sSaveWarioYTblIndex], a
	cp   a, $20						; Have we moved $20 px upwards? (like when entering a pipe)
	ret  nz							; If not, return
.end:
	; We're out of the pipe now
	xor  a
	ld   [sSaveWarioYTblIndex], a
	ld   a, SAVE_PL_ACT_EXITPIPEJUMP
	ld   [sSavePlAct], a
	ld   a, SFX1_05
	ld   [sSFX1Set], a
	; Remove BG priority flag
	ld   hl, sPlFlags
	res  7, [hl]
	; If we aren't Bomb Wario, use correct frame
	ld   a, [sSaveBombWario]
	and  a
	ret  nz
	ld   a, OBJ_SAVESEL_WARIO_LOOKUP
	ld   [sPlLstId], a
	ret
; =============== SaveSel_ExitPipe ===============
; Performs the small jump after the exit from a pipe.
SaveSel_ExitPipeJump:
	; Determine the Y offset to apply from the table
	ld   hl, .jumpYTbl
	ld   a, [sSaveWarioYTblIndex]
	ld   e, a
	ld   d, $00
	add  hl, de
	
	ld   a, [hl]					; Get the Y offset
	cp   a, $80						; Reached the end separator?
	jr   z, .end					; If so, we're done
	
	ld   b, a			
	ld   a, [sPlYRel]
	add  b							; WY += $02
	ld   [sPlYRel], a
	
	ld   a, [sSaveWarioYTblIndex]	; Index++
	inc  a
	ld   [sSaveWarioYTblIndex], a
	ret
.end:
	xor  a
	ld   [sSaveWarioYTblIndex], a
	ld   [sSavePlAct], a
	ld   a, SFX1_21
	ld   [sSFX1Set], a
	ret
.jumpYTbl:
	db $FD,$FE,$FE,$FF,$FF,$FF,$00,$00,$00,$00,$01,$01,$01,$02,$02,$03
	db $80
	
; =============== SaveSel_DoIntroB ===============
; Handles the second part of the intro animation.
SaveSel_DoIntroB:
	ld   a, [sSaveAnimAct]
	rst  $28
	dw SaveSel_IntroB_Act0
	dw SaveSel_IntroB_Act1
	dw SaveSel_IntroB_Act2
	dw SaveSel_IntroB_Act3
	dw SaveSel_IntroB_Act4

; =============== ACT 0 ===============
; Wario bumps from the wall.
SaveSel_IntroB_Act0:
	;--
	; Set the player position
	
	; Update X pos
	ld   a, [sPlXRel]
	dec  a					; always move left
	ld   [sPlXRel], a
	
	; Update Y pos
	ld   hl, .warioBumpYTbl
	ld   d, $00
	ld   a, [sPlBumpYPathIndex]
	ld   e, a
	add  hl, de
	
	; For some reason, there are no negative numbers in the table
	; so there are explicit add/subtract code paths.
	ld   b, [hl]
	cp   a, $10				; Indexes after $10 should move down
	jr   nc, .moveDown
.moveUp:
	ld   a, [sPlYRel]		; YRel -= Offset
	sub  a, b
	ld   [sPlYRel], a
	ld   a, [sPlBumpYPathIndex]
	inc  a
	ld   [sPlBumpYPathIndex], a
	ret
.moveDown:
	ld   a, [sPlYRel]		; YRel += Offset
	add  b
	ld   [sPlYRel], a
	ld   a, [sPlBumpYPathIndex]
	inc  a						; Have we reached the end of the table?
	cp   a, $20
	jr   z, .nextAct
	ld   [sPlBumpYPathIndex], a
	ret
.nextAct:
	xor  a
	ld   [sPlBumpYPathIndex], a
	ld   a, [sSaveAnimAct]
	inc  a
	ld   [sSaveAnimAct], a
	ld   a, $60					; Wait for $60 frames
	ld   [sSaveWarioTimer], a
	xor  a
	ld   [sTimer], a
	ret
	
; Y Offsets for bump anim
.warioBumpYTbl:
	db $03,$02,$02,$02,$01,$02,$01,$01,$00,$01,$00,$01,$00,$00,$00,$00 ; Added
	db $00,$00,$00,$00,$01,$00,$01,$00,$01,$01,$02,$01,$02,$02,$02,$03 ; Subtracted
	
; =============== ACT 1 ===============
; Delay in the "ground pound" frame, then look around and jumps.
SaveSel_IntroB_Act1:
	; Wait for the timer to expire before starting the jump
	ld   a, [sSaveWarioTimer]
	and  a
	jr   z, .jump
	dec  a						; Timer--
	ld   [sSaveWarioTimer], a
	
	jr   z, .startJump			; If it's now $00, start the jump
	cp   a, $40					
	jr   nz, .headTurn			; If != $40, jump
	
	; If it's $40, switch to the standing frame
	ld   a, OBJ_SAVESEL_WARIO_STANDNOHAT
	ld   [sPlLstId], a
	ret
.headTurn:
	ret  nc						; Do nothing until it's < $40
	
	; Every $10 frames
	ld   a, [sTimer]
	and  a, $0F
	ret  nz
	
	; Switch between HEADTURNA an HEADTURNB (also playing the appropriate SFX)
	ld   a, [sPlLstId]
	xor  $01
	ld   [sPlLstId], a
	bit  0, a
	jr   nz, .playSFXA
.playSFXB:
	ld   a, SFX1_19
	ld   [sSFX1Set], a
	ret
.playSFXA:
	ld   a, SFX1_18
	ld   [sSFX1Set], a
	ret
	
.startJump:
	; Starts the jump sequence
	xor  a
	ld   [sPlFlags], a
	ld   a, OBJ_SAVESEL_WARIO_JUMPNOHAT
	ld   [sPlLstId], a
	ld   a, SFX1_05
	ld   [sSFX1Set], a
	ret
.jump:
	; Jump movement
	
	; Y offset is read off a table
	ld   hl, .warioJumpYTbl
	ld   d, $00
	ld   a, [sSaveWarioYTblIndex]			; DE = Index
	ld   e, a
	add  hl, de				; Offset the table
	ld   a, [hl]			; Read the Y offset
	cp   a, $80				; Is it the end separator?
	jr   z, .nextAct		; If so, switch to the next act
	ld   b, a
	ld   a, [sPlYRel]	; Y += Offset
	add  b
	ld   [sPlYRel], a
	
	; X is always decremented by 2
	ld   a, [sPlXRel]
	sub  a, $02
	ld   [sPlXRel], a
	
	ld   a, [sSaveWarioYTblIndex]
	inc  a
	ld   [sSaveWarioYTblIndex], a
	ret
.nextAct:
	xor  a
	ld   [sSaveWarioYTblIndex], a
	ld   a, [sSaveAnimAct]			; Next act
	inc  a
	ld   [sSaveAnimAct], a
	ld   a, OBJ_WARIO_JUMP			;
	ld   [sPlLstId], a
	ld   a, $1B						; Start at the index used when falling
	ld   [sPlJumpYPathIndex], a
	ret
	
.warioJumpYTbl: 
	db $FB,$FB,$FC,$FB,$FC,$FC,$FD,$FC,$FD,$FD,$FE,$FD,$FE,$FE,$FE,$FF
	db $FF,$FE,$FF,$FF,$00,$00,$00,$00,$01,$01,$02,$01,$02,$02,$03,$80
	
; =============== ACT 2 ===============
; Wario lands from the jump.
SaveSel_IntroB_Act2:

	; Land from the jump using the same table from normal gameplay
	; We start from index $1B so the entries are for downwards movement.
	
	; Index the jump inc/dec table
	ld   hl, Pl_JumpYPath		; HL = Jump offset table
	ld   a, [sPlJumpYPathIndex]
	ld   e, a						; DE = Index to use
	ld   d, $00
	add  hl, de
	ld   b, [hl]					; Get the Y offset
	ld   a, [sPlYRel]
	add  b							; Move player down by that amount
	ld   [sPlYRel], a
	
	cp   a, $78						; Have we reached the target Y position?
	jr   nc, .nextAct				; If so, switch to the next act
	
	ld   a, [sPlJumpYPathIndex]		; Otherwise increase the table index
	inc  a
	cp   a, $48						; Did we reach the end of the table?
	ret  z							; If so, keep the last index
	ld   [sPlJumpYPathIndex], a
	ret
.nextAct:
	ld   a, $78						; .
	ld   [sPlYRel], a
	xor  a
	ld   [sPlJumpYPathIndex], a
	ld   a, [sSaveAnimAct]
	inc  a
	ld   [sSaveAnimAct], a
	ld   a, OBJ_WARIO_IDLE0
	ld   [sPlLstId], a
	ld   a, $20					; Idle delay before moving
	ld   [sSaveWarioTimer], a
	ld   a, SFX1_21
	ld   [sSFX1Set], a
	ret
	
; =============== ACT 3 ===============
; Wario moves to the right, up to the last entered pipe.
SaveSel_IntroB_Act3:
	; Don't move until the timer elapses
	ld   a, [sSaveWarioTimer]
	and  a
	jr   z, .moveRight
	
	dec  a						; Timer--
	ld   [sSaveWarioTimer], a	; Is it elapsed now?
	ret  nz						; If not, return
	
.startMoveRight:
	ld   a, $20					
	ld   [sPlFlags], a
	ld   a, OBJ_WARIO_WALK0
	ld   [sPlLstId], a
	xor  a
	ld   [sPlAnimTimer], a
	ret
.moveRight:
	call NonGame_Wario_AnimWalkFast
	
	; Which X pos is our target?
	ld   b, $24			; SAVE 1
	ld   a, [sLastSave]
	and  a				
	jr   z, .chkNextAct
	ld   b, $44			; SAVE 2
	dec  a
	jr   z, .chkNextAct
	ld   b, $64			; SAVE 3
	dec  a
	jr   z, .chkNextAct
	; [TCRF] If sLastSave is not in range, reset it back to 0 (SAVE 1)
	ld   b, $24
	xor  a
	ld   [sLastSave], a
.chkNextAct:
	ld   a, [sPlXRel]	; Move player right
	inc  a
	ld   [sPlXRel], a
	cp   a, b				; Have we reached the target?
	ret  nz					; If not, return
.nextAct:
	xor  a
	ld   [sPlAnimTimer], a
	ld   a, OBJ_WARIO_THUMBSUP0
	ld   [sPlLstId], a
	ld   a, [sSaveAnimAct]
	inc  a
	ld   [sSaveAnimAct], a
	ld   a, $30					; Wait $30 frames
	ld   [sSaveWarioTimer], a
	ret
	
; =============== ACT 4 ===============
; Delay before the player gets control.
SaveSel_IntroB_Act4:
	ld   a, [sSaveWarioTimer]
	dec  a
	ld   [sSaveWarioTimer], a
	ret  nz
	xor  a
	ld   [sSaveAnimAct], a
	ld   a, GM_TITLE_SAVESEL
	ld   [sSubMode], a
	ld   a, OBJ_WARIO_IDLE0
	ld   [sPlLstId], a
	ret
	
; =============== NonGame_Wario_AnimWalkFast ===============
; Animates Wario's walk cycle at a fast speed (similar speed when walking with a Jet Hat)
; for non-static modes outside of gameplay:
;        - Save select
;        - Course clear screen
;        - Treasure room
NonGame_Wario_AnimWalkFast:
	; For normal Wario only
	ld   a, [sSaveBombWario]
	and  a
	ret  nz
	
	call Wario_PlayWalkSFX_Fast
	
	; Perform every other frame
	ld   a, [sTimer]
	and  a, $01
	ret  nz
	
	; Use the anim timer as the index to the offset table
	ld   hl, OBJLstAnimOff_Wario_Walk
	ld   a, [sPlAnimTimer]				; Index++
	inc  a
	; If we reached the end of the table, reset the index
	cp   a, (OBJLstAnimOff_Wario_Walk.end - OBJLstAnimOff_Wario_Walk)
	jr   nz, .setFrame
	xor  a
.setFrame:
	; Index the table
	ld   [sPlAnimTimer], a
	ld   e, a				; DE = Index
	ld   d, $00
	add  hl, de
	; Add the offset to the current frame id
	ld   a, [sPlLstId]
	add  [hl]			; LstId += Offset
	ld   [sPlLstId], a
	ret
; =============== OBJLstAnimOff_Wario_Walk ===============
; Table of offsets to the current LstId to cycle frames for the walk cycle.
OBJLstAnimOff_Wario_Walk:
	db -$02,+$01,+$01,-$02,+$03,-$01
	.end:
	
; =============== SaveSel_BombWario_Anim ===============
; Animates Wario in the bomb form.
SaveSel_BombWario_Anim:
	; Bomb Wario required
	ld   a, [sSaveBombWario]
	and  a
	ret  z
	
	; Animate every $08 frame
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	
	ld   a, SFX4_14
	ld   [sSFX4Set], a
	
	; Use the anim timer as the index to the offset table
	ld   hl, OBJLstAnimOff_BombWario
	ld   a, [sPlAnimTimer]
	inc  a
	; If we reached the end of the table, reset the index
	cp   a, (OBJLstAnimOff_BombWario.end - OBJLstAnimOff_BombWario)
	jr   nz, .setFrame
	xor  a
.setFrame:
	; Index the table
	ld   [sPlAnimTimer], a
	ld   e, a				; DE = Index
	ld   d, $00
	add  hl, de
	; Add the offset to the current frame id
	ld   a, [sPlLstId]
	add  [hl]			; LstId += Offset
	ld   [sPlLstId], a
	ret
	
; =============== OBJLstAnimOff_Wario_Walk ===============
OBJLstAnimOff_BombWario:
	db -$02,+$01,-$01,+$02
	.end:


; =============== mSaveSetBrickPos ===============
; Updates the position of the destroyed bricks in the save screen.
; This effect expects the brick OBJs to be in specific OAM slots.
; IN
; - 1: Ptr to coordinate table
; - 2: Ptr to WorkOAM Slot
; - 3: Tile ID used
MACRO mSaveSetBrickPos
	; The brick coordinates are stored in a table of Y/X coords.
	; Index this table.
	ld   hl, \1
	ld   a, [sSaveBrickPosIndex]
	add  a				; DE = Index * 2
	ld   e, a
	ld   d, $00
	add  hl, de			; Offset the table
	
	ldi  a, [hl]
	ld   b, a			; B = Y Offset
	ld   c, [hl]		; C = X offset
	
	ld   a, [\2]		; Add the offset to the Y pos
	add  b
	ld   [\2], a
	
	ld   a, [\2+$01]	; Add the offset to the X pos
	add  c
	ld   [\2+$01], a
	
	ld   a, \3			; Force set the tile ID
	ld   [\2+$02], a
ENDM

; =============== SaveSel_DoBreakEffect ===============
; Handles the effect of blocks breaking when Wario first comes on screen.
SaveSel_DoBreakEffect:
	; Don't begin the effect if Wario isn't on screen
	ld   a, [sSaveWarioTimer]
	and  a						; Is the spawn delay over?
	ret  nz						; If not, return

	; Is the effect already done?
	ld   a, [sSaveBlockBreakDone]	
	and  a
	jp   nz, .effectDone
	;--
	
	; Update the effect every other frame
	ld   a, [sTimer]
	and  a, $01
	ret  nz
	
	; Set the updated brick coords
	;                COORDS   OBJ          TileID
	mSaveSetBrickPos SaveSel_Brick0PosTable, sSaveBrick0, $9F
	mSaveSetBrickPos SaveSel_Brick1PosTable, sSaveBrick1, $9E
	mSaveSetBrickPos SaveSel_Brick2PosTable, sSaveBrick2, $9E
	mSaveSetBrickPos SaveSel_Brick3PosTable, sSaveBrick3, $9F
	mSaveSetBrickPos SaveSel_Brick4PosTable, sSaveBrick4, $9E
	mSaveSetBrickPos SaveSel_Brick5PosTable, sSaveBrick5, $9F
	
	ld   a, [sSaveBrickPosIndex] 	; TableIndex++	
	inc  a
	ld   [sSaveBrickPosIndex], a
	cp   a, $10						; Have we reached the end of the table?
	ret  nz							; If not, return
	
	xor  a							; Otherwise, mark the effect as completed
	ld   [sSaveBrickPosIndex], a	
	ld   a, $01
	ld   [sSaveBlockBreakDone], a
.effectDone:
	ld   a, $18
	ld   [sWorkOAMPos], a
	ret
	
; =============== SaveSel_Brick0PosTable ===============
; Y/X coordinates for the destroyed bricks.
SaveSel_Brick0PosTable: 
	db $F0,$06
	db $F4,$08
	db $F8,$06
	db $FC,$08
	db $00,$06
	db $04,$08
	db $08,$06
	db $0C,$08
	db $10,$06
	db $10,$08
	db $10,$06
	db $10,$08
	db $10,$06
	db $10,$08
	db $10,$06
	db $10,$08
SaveSel_Brick4PosTable: 
	db $F2,$06
	db $F6,$07
	db $FA,$06
	db $FE,$07
	db $00,$06
	db $02,$07
	db $06,$06
	db $0A,$07
	db $0E,$06
	db $0E,$07
	db $0E,$06
	db $0E,$07
	db $0E,$06
	db $0E,$07
	db $0E,$06
	db $0E,$07
SaveSel_Brick1PosTable:
	db $F8,$06
	db $F8,$06
	db $FC,$06
	db $00,$06
	db $04,$06
	db $08,$06
	db $0C,$06
	db $0C,$06
	db $0C,$06
	db $0C,$06
	db $0C,$06
	db $0C,$06
	db $0C,$06
	db $0C,$06
	db $0C,$06
	db $0C,$06
SaveSel_Brick5PosTable: 
	db $F8,$05
	db $FA,$06
	db $FE,$05
	db $00,$06
	db $06,$05
	db $08,$06
	db $0A,$05
	db $0A,$06
	db $0A,$05
	db $0A,$06
	db $0A,$05
	db $0A,$06
	db $0A,$05
	db $0A,$06
	db $0A,$05
	db $0A,$06
SaveSel_Brick2PosTable: 
	db $F8,$04
	db $FC,$06
	db $00,$04
	db $04,$06
	db $08,$04
	db $08,$06
	db $08,$04
	db $08,$06
	db $08,$04
	db $08,$06
	db $08,$04
	db $08,$06
	db $08,$04
	db $08,$06
	db $08,$04
	db $08,$06
SaveSel_Brick3PosTable: 
	db $FA,$04
	db $FC,$04
	db $FE,$04
	db $00,$04
	db $02,$04
	db $04,$04
	db $06,$04
	db $06,$04
	db $06,$04
	db $06,$04
	db $06,$04
	db $06,$04
	db $06,$04
	db $06,$04
	db $06,$04
	db $06,$04
	
; =============== SaveSel_DoIntroA ===============
; Handles Wario's initial dash in the save select screen.
; When the wall is hit and Wario loses the hat, it switches to the next submode.
SaveSel_DoIntroA:
	; If the timer isn't 0, don't do anything except decrement the timer.
	ld   a, [sSaveWarioTimer]
	and  a						
	jr   z, .chkMove				
	dec  a
	ld   [sSaveWarioTimer], a	
	ret  nz
	;--
	; On the first processing loop
	ld   a, SFX4_01					; Play dash SFX
	ld   [sSFX4Set], a
	ld   a, $01
	ld   [sPlGroundDashTimer], a
.chkMove:
	ld   a, [sPlXRel]
	cp   a, $78				; Has Wario reached the side of the pipe?
	jr   z, .nextSubMode	; If so, switch to the next submode
	
	; Otherwise, move Wario to the left and perform the dash anim.
	add  $02
	ld   [sPlXRel], a
	call Wario_DoDashAfterimages
	ret
.nextSubMode:
	ld   a, OBJ_SAVESEL_WARIO_BUMP
	ld   [sPlLstId], a
	ld   a, GM_TITLE_SAVESELINTRO1
	ld   [sSubMode], a
	xor  a
	ld   [sPlGroundDashTimer], a
	ld   a, SFX4_03
	ld   [sSFX4Set], a
	; Spawn the old hat flying off
	ld   hl, sExActSet
	ld   a, EXACT_SAVESEL_OLDHAT ; ID
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ld   a, OBJ_SAVESEL_OLDHAT0
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ld   a, $5C		; Y
	ldi  [hl], a
	ld   a, $80		; X
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	call ExActS_Spawn
	ret
	
	
; =============== SaveSel_ValidateSaveFiles ===============
; Validates all three save games.
;
; There are 3 save games, and each is saved twice.
; For any given save, these steps are performed:
; - Check the save signature
; - Validate the checksum
;
; When validation fails for a save, the backup copy is checked the same way.
; If the backup copy is valid, its data will be copied over the main save.
;
; If validation of both saves fails, the savedata will be marked as bad and re-initialized.
; The result depends on how the backup copy verification failed:
; - If the signature is missing from both saves, the savedata ia assumed to not exist.
; - If the signature exists but the checksum is bad, the save gets marked as bad.
;   
; The "SAVE DATA ERROR" message is only shown if exactly one save is bad.
;
SaveSel_ValidateSaveFiles:
	xor  a
	ld   [sSaveFileError], a
	ld   a, $01
	ld   [sNoReset], a
	
;--
; SAVE DATA 1
;--
.verifySave1:
	; Verify saved data signature
	; The first four bytes must be $16643957.
	; If the bytes are missing, assume there's no save data.
	ld   hl, sSave1
	ldi  a, [hl]
	cp   a, $19
	jr   nz, .verifySave1Bak
	ldi  a, [hl]
	cp   a, $64
	jr   nz, .verifySave1Bak
	ldi  a, [hl]
	cp   a, $39
	jr   nz, .verifySave1Bak
	ldi  a, [hl]
	cp   a, $57
	jr   nz, .verifySave1Bak
	; If the signature is present, verify the checksum
	ld   hl, sSave1
	call SaveSel_CreateChecksum		; Calculate checksum for save 1
	ld   a, [sSave1Checksum]	; Get the saved checksum 
	cp   a, b						; Do they match?
	jr   z, .verifySave2			; If so, check save 2
.verifySave1Bak:
	; If the main save is missing, perform the same verification on the backup copy 
	ld   hl, sSave1Bak
	ldi  a, [hl]
	cp   a, $19
	jr   nz, .badSave1
	ldi  a, [hl]
	cp   a, $64
	jr   nz, .badSave1
	ldi  a, [hl]
	cp   a, $39
	jr   nz, .badSave1
	ldi  a, [hl]
	cp   a, $57
	jr   nz, .badSave1
	; Validate checksum
	ld   hl, sSave1Bak
	call SaveSel_CreateChecksum
	ld   a, [sSave1Checksum]
	cp   b
	jr   nz, .badSave1
	; If the backup save is valid, copy its data over to the main save
	ld   hl, sSave1Bak
	ld   de, sSave1
	ld   b, $20
	call CopyBytes
	jr   .verifySave2
.badSave1:
	; Copy over the empty save
	ld   hl, SaveSel_EmptySave
	ld   de, sSave1
	ld   b, $20
	call CopyBytes
	; Copy the default checksum
	ld   a, [hl]
	ld   [sSave1Checksum], a
	; Mark the save file as bad
	ld   hl, sSaveFileError
	set  0, [hl]
	
;--
; SAVE DATA 2
;--
.verifySave2:
	; Verify signature
	ld   hl, sSave2
	ldi  a, [hl]
	cp   a, $19
	jr   nz, .verifySave2Bak
	ldi  a, [hl]
	cp   a, $64
	jr   nz, .verifySave2Bak
	ldi  a, [hl]
	cp   a, $39
	jr   nz, .verifySave2Bak
	ldi  a, [hl]
	cp   a, $57
	jr   nz, .verifySave2Bak
	; Validate checksum
	ld   hl, sSave2
	call SaveSel_CreateChecksum
	ld   a, [sSave2Checksum]
	cp   a, b				; Does it match?
	jr   z, .verifySave3	; If so, validate save 3
.verifySave2Bak:
	; Do the same for the backup save
	ld   hl, sSave2Bak
	ldi  a, [hl]
	cp   a, $19
	jr   nz, .badSave2
	ldi  a, [hl]
	cp   a, $64
	jr   nz, .badSave2
	ldi  a, [hl]
	cp   a, $39
	jr   nz, .badSave2
	ldi  a, [hl]
	cp   a, $57
	jr   nz, .badSave2
	; Validate checksum
	ld   hl, sSave2Bak
	call SaveSel_CreateChecksum
	ld   a, [sSave2Checksum]
	cp   b
	jr   nz, .badSave2
	; If the backup save is valid, copy its data over to the main save
	ld   hl, sSave2Bak
	ld   de, sSave2
	ld   b, $20
	call CopyBytes
	jr   .verifySave3
.badSave2:
	; Copy over the empty save
	ld   hl, SaveSel_EmptySave
	ld   de, sSave2
	ld   b, $20
	call CopyBytes
	; Copy the default checksum
	ld   a, [hl]
	ld   [sSave2Checksum], a
	; Mark the save as bad
	ld   hl, sSaveFileError
	set  1, [hl]
	
;--
; SAVE DATA 3
;--
.verifySave3:
	; Verify signature
	ld   hl, sSave3
	ldi  a, [hl]
	cp   a, $19
	jr   nz, .verifySave3Bak
	ldi  a, [hl]
	cp   a, $64
	jr   nz, .verifySave3Bak
	ldi  a, [hl]
	cp   a, $39
	jr   nz, .verifySave3Bak
	ldi  a, [hl]
	cp   a, $57
	jr   nz, .verifySave3Bak
	; Validate checksum
	ld   hl, sSave3
	call SaveSel_CreateChecksum
	ld   a, [sSave3Checksum]
	cp   a, b			; Does it match?
	jr   z, .end		; If so, we're done
.verifySave3Bak:
	; Do the same for the backup save
	ld   hl, sSave3Bak
	ldi  a, [hl]
	cp   a, $19
	jr   nz, .badSave3
	ldi  a, [hl]
	cp   a, $64
	jr   nz, .badSave3
	ldi  a, [hl]
	cp   a, $39
	jr   nz, .badSave3
	ldi  a, [hl]
	cp   a, $57
	jr   nz, .badSave3
	; Validate checksum
	ld   hl, sSave3Bak
	call SaveSel_CreateChecksum
	ld   a, [sSave3Checksum]
	cp   b
	jr   nz, .badSave3
	; If the backup save is valid, copy its data over to the main save
	ld   hl, sSave3Bak
	ld   de, sSave3
	ld   b, $20
	call CopyBytes
.end:
	xor  a
	ld   [sNoReset], a
	ret
.badSave3:
	; Copy over the empty save
	ld   hl, SaveSel_EmptySave
	ld   de, sSave3
	ld   b, $20
	call CopyBytes
	; Copy the default checksum
	ld   a, [hl]
	ld   [sSave3Checksum], a
	ld   hl, sSaveFileError
	; Mark the save as bad
	set  2, [hl]
	jr   .end
	
; =============== Empty Save Data ===============
SaveSel_EmptySave:
	db $19,$64,$39,$57,$00,$00,$00,$00,$00,$05,$01,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
SaveSel_EmptySaveChecksum:
	db $13
	
; =============== SaveSel_CreateChecksum ===============
; Calculates the checksum for a save file.
; IN
; - HL: Ptr to SaveFile
; OUT
; -  B: Checksum value
SaveSel_CreateChecksum:
	ld   bc, $0020		; C = Size of save file
	; The checksum is the sum of every byte in the SaveFile
.loop:
	ldi  a, [hl]		; Get the byte
	add  b				; Sum the previous total value
	ld   b, a			; Set it back
	dec  c
	jr   nz, .loop
	ret
	
; =============== SaveSel_GetSaveDataPtr ===============
; Gets the ptr to the save file data, based on the last selected save.
; OUT
; - HL: Ptr to selected SaveFile
SaveSel_GetSaveDataPtr:
	ld   hl, sSave1			; HL = Default sSave1 value
	ld   a, [sLastSave]		; If it's save 1, the ptr matches already
	and  a
	ret  z
	
	; [TCRF] Out of range validation
	cp   a, $03
	jr   c, .valid
	
	; If it isn't valid (sLastSave >= 3), we reset it back to $00
	; and default to Save1.
	xor  a
	ld   [sLastSave], a
	ret
	
.valid:
	; HL = sSave1 + (sLastSave * $40)
	ld   b, a		; B = Copy count
	ld   de, $0040	; Skip Save 1 and its backup copy
	add  hl, de		
	dec  b			; Are we done yet?
	ret  z			; If so, we selected save 2
.save3:
	add  hl, de		; skip save2+bak
	ret
	
; =============== Demo_Unused_WriteInput ===============
; [TCRF] Unreferenced code.
;
; This subroutine records demo inputs, writing them to an otherwise unused buffer at sDemoWriterBuffer.
; The written data is $80 bytes long (like demo inputs) can be used as-is as a "demo.bin" file.
; 
; The way this subroutine works (it clears demo mode and plays a SFX when done) suggests a couple of things:
; - Levels being hardwired to start in demo mode
; - A commented out check during gameplay to call this subroutine if demo mode is active
; - There used to be two additional demo modes for demo recording, following the pattern for demo playback.
;
Demo_Unused_WriteInput:
	ld   hl, sDemoWriterBuffer	; HL = Buffer
	
	; Demo inputs are expected to be exactly $80 bytes long, with each entry of the table
	; being two bytes long. Entries having byte 0 as keypress and byte 1 as keypress length.
	; When we reach that size, stop recording and notify the user.
	;
	; Note that at the start of Demo_Unused_WriteInput, the input offset always points to the
	; start of the entry *after* the one we're currently on.
	; As a result, to seek to the frame length of the current keypress we have to
	; *decrease* the ptr by 1, and not increase it.
	ld   a, [sDemoInputOffset]
	cp   a, $80					; Did we reach the end of the demo input table?
	jr   z, .endRecord			; If not, return
	
	; Seek to the byte to write
	add  l						; Buffer += Offset
	ld   l, a
	
	; Determine if we're pressing the same keys as the last frame.
	; If we are, increase the length of the key.
	ld   a, [sDemoLastKey]		; B = LastKeys
	ld   b, a
	ldh  a, [hJoyKeys]			; A = CurrentKeys
	cp   b						; LastKeys == CurrentKeys?
	jr   z, .incKeyLength		; If so, jump
	
	; Otherwise, write in the key we've written and 
	; initialize the frame count for the next frame.
	ld   [sDemoLastKey], a			
.incOffset:
	ldi  [hl], a				; Write keypress value (won't be changed)
	
	ld   a, $01					; Write initial keypress length (may be updated)
	ld   [hl], a
	ld   a, [sDemoInputOffset]	; sDemoInputOffset += 2
	add  $02
	ld   [sDemoInputOffset], a
	ret  
.onMaxKeyLength:
	ld   a, [sDemoLastKey]
	inc  l						; Seek back to new entry
	jr   .incOffset
.incKeyLength:
	; Seek to frame length of the current frame (see comment above).
	dec  l						; Seek to that
	ld   a, [hl]		
	cp   a, $FF					; Did we reach the max length?
	jr   z, .onMaxKeyLength		; If so, jump
	
	inc  a						; Otherwise, KeyLength++
	ld   [hl], a
	ret 
.endRecord:
	xor  a						; End demo mode
	ld   [sDemoMode], a
	ld   a, SFX2_01				; Notify player with SFX
	ld   [sSFX2Set], a
	ret
	
; =============== END OF BANK ===============
	mIncJunk "L017BF7"
