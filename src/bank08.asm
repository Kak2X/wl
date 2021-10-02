;
; BANK $08 - Map Screen
;

; =============== Map_Mode_Overworld ===============
; Mode $02
Map_Mode_Overworld:
	call Map_OverworldDoWorldClear
	ld   a, [sMapWorldClear]
	and  a
	ret  nz
	
	call Map_Overworld_BridgeAutoMove
	call Map_Overworld_Do
	ret
	
; =============== Map_Overworld_BridgeAutoMove ===============
; Performs automatic movement actions for the Bridge, specifically when:
; - Exiting Mt.Teapot to the left (automatically move from Bridge to Sherbet Land; value 07)
; - Exiting Sherbet Land to the right (automatically move from Sherbet Land to Bridge; value 10)
; See Map_Submap_CheckPathEndType for how/why exactly those value are used.
;
Map_Overworld_BridgeAutoMove:
	ld   a, [sMapBridgeAutoMove]	; Did we exit through the left path of C8?
	and  a, $0F
	jr   z, .checkSlRight			; If not, jump
	
	ld   a, [sMapWorldId]
	; Only proceed when in the Mt.Teapot or Bridge positions.
	; We only get here when we're on the bridge so... I dunno
	cp   a, MAP_OWP_BRIDGE
	jr   z, .fromMtTeapot
	cp   a, MAP_OWP_MTTEAPOT ; We also never get here
	ret nz
.fromMtTeapot:
	ld   a, $20
	ldh  [hJoyNewKeys], a
; [BUG] The way automove is disabled is buggy -- 
;       and seems like a quick fix to account how it's only disabled when entering a submap.
;
;       This should have been done on Map_OnPathEnd instead, because by doing it here
;       it's done immediately before the path starts, so the player has a chance to break it 
;       by holding B when the game returns to the overworld.
;       This cancels the automatic movement, causing Wario to stay on the Bridge.
IF FIX_BUGS == 0
	xor  a
	ld   [sMapBridgeAutoMove], a
ENDC
	ret
	
.checkSlRight:
	ld   a, [sMapBridgeAutoMove]	; Did we exit though the right path of C14?
	and  a, $F0
	ret  z							; If not, return
.fromSherbetLand:
	ld   a, KEY_RIGHT
	ldh  [hJoyNewKeys], a
	ret
	
; =============== Map_OverworldDoWorldClear ===============
; Handles the World Clear scene in the overworld.
Map_OverworldDoWorldClear:
	ld   a, [sMapWorldClearTimer]	; Are we in the second phase waiting for the other timer?
	and  a
	jr   nz, .act1s					; if so, skip the first phase
	
	; Exit out if we aren't in world clear mode
	ld   a, [sMapWorldClear]
	and  a
	ret  z
	
	; ACT 0 - Wait until the world clear BGM finishes playing
.act0:
	call Map_Overworld_AnimTiles
	call Map_WriteWarioOBJLst
	call HomeCall_Map_MoveMtTeapotLid
	ld   a, [sMapTimer0]			; Wait $50 frames for that
	cp   a, $50
	ret  nz
	
	; ACT 1 - Play SFX and show all flags
.act1:
	ld   a, SFX1_08
	ld   [sSFX1Set], a
.act1s:
	call Map_Overworld_AnimTiles
	call Map_WriteWarioOBJLst
	call HomeCall_Map_MoveMtTeapotLid
	call HomeCall_Map_Overworld_AnimFlags
	ld   a, [sMapWorldClearTimer]	; Wait for $70 frames in this state
	inc  a
	ld   [sMapWorldClearTimer], a
	cp   a, $70
	ret  nz
	
.act2:
	; Determine the direction to automove to depending on which world was cleared
	xor  a
	ld   [sMapWorldClearTimer], a
	ld   a, [sMapWorldClear]
	bit  MAP_CLRB_RICEBEACH, a
	jr   nz, .riceBeach
	bit  MAP_CLRB_MTTEAPOT, a
	jr   nz, .mtTeapot
	bit  MAP_CLRB_STOVECANYON, a
	jr   nz, .stoveCanyon
	bit  MAP_CLRB_SSTEACUP, a				
	jr   nz, .unused_ssTeacup
	bit  MAP_CLRB_PARSLEYWOODS, a
	jr   nz, .parsleyWoods
	bit  MAP_CLRB_SHERBETLAND, a
	jr   nz, .sherbetLand
	; [TCRF] Fallback behaviour; we never get here
	xor  a
	ld   [sMapWorldClear], a
	ret
.autoMove:
	; Once we've decided the path to take, simulate a keypress towards it
	; to automatically travel it it
	ldh  [hJoyNewKeys], a
	xor  a
	ld   [sMapWorldClear], a
	ld   [sMapLevelClear], a
	ld   a, BGM_OVERWORLD
	ld   [sBGMSet], a
	jp   Map_Overworld_DoPathCtrl
.riceBeach:
	ld   a, [sMapRiceBeachCompletion]
	ld   [sMapRiceBeachCompletionLast], a
	ld   a, KEY_UP
	ld   [sMapAutoEnterOnPathEnd], a
	jr   .autoMove
.mtTeapot:
	ld   a, [sMapMtTeapotCompletion]
	ld   [sMapMtTeapotCompletionLast], a
	ld   [sMapAutoEnterOnPathEnd], a
	ld   a, KEY_RIGHT
	jr   .autoMove
.stoveCanyon:
	ld   a, [sMapStoveCanyonCompletion]
	ld   [sMapStoveCanyonCompletionLast], a
	ld   [sMapAutoEnterOnPathEnd], a
	ld   a, KEY_DOWN
	jp   .autoMove
.unused_ssTeacup: 
	; [TCRF] SS Teacup doesn't use the standard world clear scene, so this code is unreachable
	;        Interestingly this does not send any joypad command or set the auto-enter status
	ld   a, [sMapSSTeacupCompletion]
	ld   [sMapSSTeacupCompletionLast], a
	ld   a, KEY_NONE
	jp   .autoMove
.parsleyWoods:
	ld   a, [sMapParsleyWoodsCompletion]
	ld   [sMapParsleyWoodsCompletionLast], a
	ld   [sMapAutoEnterOnPathEnd], a
	ld   a, KEY_UP
	jp   .autoMove
.sherbetLand:
	ld   a, [sMapSherbetLandCompletion]
	ld   [sMapSherbetLandCompletionLast], a
	ld   a, KEY_DOWN
	jp   .autoMove
	
; =============== Map_Overworld_Do ===============
; Main code for processing the overworld.
;
Map_Overworld_Do:
	call HomeCall_Map_MoveMtTeapotLid
	call HomeCall_Map_Overworld_AnimFlags
	; free view enter / exit check
	
	ldh  a, [hJoyKeys]				; Holding B activates free view mode
	bit  KEYB_B, a
	jr   nz, .freeView
	ld   a, [sMapFreeViewReturn]	; If we've stopped holding B determine how to return
	and  a, MAP_FVR_ANY
	jr   nz, .freeViewCheckRet
	
.main:
	; Standard handlers
	call Map_Overworld_DoCtrl
	call Map_Overworld_AnimTiles
	call Map_WriteWarioOBJLst
	ret
	
;--
; MAP VIEW MODE
;--
.freeView:
	; Disallow freeview mode in a path.
	; ...though not sure it doesn't return to .main directly.
	ld   a, [sMapInPath]
	and  a
	jr   nz, .alreadySet
	;--
	; Play SFX only when entering freeview for the first time
	ld   a, [sMapFreeView]	
	and  a
	jr   nz, .alreadySet	
	ld   a, SFX1_0A			
	ld   [sSFX1Set], a
	ld   [sMapFreeView], a
.alreadySet:
	call HomeCall_Map_InitFreeViewArrows
	;--
	; If we attempted to enter freeview in a path, disable it immediately
	ld   a, [sMapInPath]
	and  a
	jr   nz, .freeViewSoftExit
	;--
	
	call Map_FreeViewCtrl
	call Map_Overworld_AnimTiles
	call HomeCall_Map_DrawFreeViewArrows
	ret
.freeViewCheckRet:
	xor  a
	ld   [sMapTimer0], a
	ld   a, [sMapFreeViewReturn]	; Is FreeViewRet & HardMask == 0?
	and  a, MAP_FVR_HARDM
	jr   z, .freeViewSoftExit		; If so, perform a soft return
.freeViewHardExit:
	; An hard return reloads the map
	ld   a, MAP_MODE_FADEOUT
	ld   [sMapId], a
	ld   a, MAP_MODE_INITOVERWORLD
	ld   [sMapNextId], a
	ld   a, SFX1_0A
	ld   [sSFX1Set], a
	ret
.freeViewSoftExit:
	; A soft return simply clears the freeview vars
	xor  a
	ld   [sMapFreeViewReturn], a
	ld   [sMapFreeView], a
	jr   .main

; =============== Map_Overworld_DoCtrl ===============
; This subroutine handles player movement in the overworld.
Map_Overworld_DoCtrl:
	; Special case if we're over Parsley Woods
	ld   a, [sMapWorldId]
	cp   a, MAP_OWP_PARSLEYWOODS
	jr   z, .parsleyWoods
.canMove:
	;--
	; Path handling
	; If the path segment is still active, continue processing it
	ld   a, [sMapStepsLeft]
	and  a
	jp   nz, Map_Overworld_DoPathSeg
	
	; If the segment is over and we're still in a path, check what to do
	ld   a, [sMapInPath]
	and  a
	jp   nz, Map_Overworld_EndPathSeg
	;--
	
	; A or START to enter the submap
	ldh  a, [hJoyNewKeys]
	and  a, KEY_A|KEY_START
	jr   nz, Map_Overworld_EnterSubmap
	call Map_Overworld_DoPathCtrl
	call Map_SetOpenPathArrows
	call HomeCall_Map_DrawOpenPathsArrows
	ret
.parsleyWoods:
	; Prevent movement if the lake isn't drained yet
	
	ld   a, [sMapParsleyWoodsCompletion]	; Is C32 completed yet?
	bit  1, a
	jr   nz, .canMove						; If so, we can move (and check for other keys)
	; Otherwise we only check for A/START and do nothing else.
	; This includes not drawing the open path arrows.
	; In practice a few more things could have been handled here but oh well.
	ldh  a, [hJoyNewKeys]					
	and  a, KEY_A|KEY_START
	jr   nz, Map_Overworld_EnterSubmap
	ret
	
; =============== Map_Overworld_EnterSubmap ===============
; This subroutines is called when a world is selected in the overworld.
;
; This starts a fade out to a specific Map mode with a specific level.
; This also sets the initial *level ID* for the submap (!),
; which may or may not be overridden later on (see Rice Beach).
;
; The mode/level depend on the current World ID.
Map_Overworld_EnterSubmap:
	; Play enter SFX
	ld   a, SFX1_23
	ld   [sSFX1Set], a
	; Fade out the song
	ld   a, BGMACT_FADEOUT
	ld   [sBGMActSet], a
	
	; Snapshot the frame counter
	ld   a, [sMapTimer_Low]
	ld   [sMapSubmapEnterTime], a
	xor  a
	ld   [sMapWarioAnimId], a
	ld   [sMapLevelStartTimer], a
	; Signal a submap is being entered
	ld   a, $01
	ld   [sMapSubmapEnter], a
	
	; Depending on the submap we're entering pick the starting level
	ld   a, [sMapWorldId]
	cp   a, MAP_OWP_RICEBEACH
	jr   z, .riceBeach
	cp   a, MAP_OWP_MTTEAPOT
	jr   z, .mtTeapot
	cp   a, MAP_OWP_STOVECANYON
	jr   z, .stoveCanyon
	cp   a, MAP_OWP_PARSLEYWOODS
	jr   z, .parsleyWoods
	cp   a, MAP_OWP_SSTEACUP
	jr   z, .ssTeacup
	cp   a, MAP_OWP_SHERBETLAND
	jr   z, .sherbetLand
	cp   a, MAP_OWP_SYRUPCASTLE
	jr   z, .syrupCastle
	cp   a, MAP_OWP_BRIDGE
	jr   z, .bridge
	ret
	
; =============== mSubmapEnter ===============
; Macro for defining the map to enter over a level spot
; IN
; - 1: MapId target after fade out
; - 2: First level ID
mSubmapEnter: MACRO
	ld   a, MAP_MODE_FADEOUT
	ld   [sMapId], a
	ld   a, \1
	ld   [sMapNextId], a
	ld   a, \2
	ld   [sMapLevelId], a
	ret
ENDM
	
;                           TARGET MODE                FIRST LEVEL
.riceBeach:    mSubmapEnter MAP_MODE_INITRICEBEACH,    LVL_C01A
.mtTeapot:     mSubmapEnter MAP_MODE_INITMTTEAPOT,     LVL_C07
.bridge:       mSubmapEnter MAP_MODE_INITMTTEAPOT,     LVL_C08
.stoveCanyon:  mSubmapEnter MAP_MODE_INITSTOVECANYON,  LVL_C20
.parsleyWoods: mSubmapEnter MAP_MODE_INITPARSLEYWOODS, LVL_C31A
.ssTeacup:     mSubmapEnter MAP_MODE_INITSSTEACUP,     LVL_C26
.sherbetLand:  mSubmapEnter MAP_MODE_INITSHERBETLAND,  LVL_C14
.syrupCastle:  mSubmapEnter MAP_MODE_INITSYRUPCASTLE,  LVL_C37

; =============== Map_Overworld_DoPathCtrl ===============
Map_Overworld_DoPathCtrl:
	call Map_Overworld_GetPathDirPtr ; HL = PathDir ptr
	call Map_Overworld_CheckForNewPath
	call Map_OnPathEnd
	ret
	
; =============== Map_Overworld_EndPathSeg ===============
; Prepares a call Map_Overworld_CheckForNextPathSeg in the overworld.
Map_Overworld_EndPathSeg:
	call Map_Overworld_GetPathDirPtr ; HL = PathDir Ptr
	call Map_Overworld_CheckForNextPathSeg
	; If the map timer happens to land on $0F, play the walking SFX
	ld   a, [sMapTimer_Low]
	and  a, $0F
	ret  nz
	ld   a, SFX4_08
	ld   [sSFX4Set], a
	ret
; =============== Map_Overworld_SetNextPathSeg ===============
; Sets up the next path segment for the overworld.
;
; IN
; - HL: Ptr to the *start* of path data
Map_Overworld_SetNextPathSeg:
	; If the offset to the path data is $00, assume something's wrong.
	; (when a path is first set, this value should be $03)
	ld   a, [sMapPathOffset]
	or   a, $00
	ret  z
	
	; Offset the current path segment
.indexLoop:
	; HL += MapPathCounter
	or   a, $00
	jr   z, .segFound
	inc  hl
	dec  a
	jr   .indexLoop
	
.segFound:
	; Handle the path command
	; If it's a stop command, handle it separately
	ldi  a, [hl]				
	cp   a, MAP_MPC_STOP		
	jr   z, .checkPathEndType	
	
	; Otherwise, it's a directional one
	ld   [sMapPathCtrl], a		
	call Map_SetPathCtrlArgs
	ret
.checkPathEndType:
	; Determine the action to perform when the path ends
	ld   a, [hl]
	cp   a, MAP_MPR_UNUSED_ALTID	; [TCRF] Use an alternate world ID value.
	jr   z, .unused_useAltId
	cp   a, MAP_MPR_ENTERBRIDGE		; Special case for the Sherbet Land to Bridge path.
	jr   z, .sherbetLandSet
	
	; Default behaviour: handle the return type as the current World ID.
	;
	
	ld   [sMapWorldId], a		; Set the overworld position
	ld   b, a
	ld   a, LVL_OVERWORLD		; And the respective "Level ID" ($30 + WorldId)
	add  b
	ld   [sLevelId], a
.endPath:
	; Set the scroll/player position for the new World ID.
	; This prevents any possible misalignments.
	call Map_OverworldSetStartPos
	; Misc reset
	ld   a, $B0
	ld   [sMapTimer0], a
	xor  a
	ld   [sMapCurArrow], a
	ld   [sMapVisibleArrows], a
	ld   [sMapStepsLeft], a
	ld   [sMapPathCtrl], a
	ld   [sMapInPath], a
	ld   [sMapPathOffset], a
	ld   [sMapPathDirSel], a
	ld   [sMapInPath], a
	; [TCRF] Curiously, the alternate world id mode is outright disabled in the overworld,
	;        even if it would be in the path data.
	;        This *isn't* the case in the equivalent code for a submap.
	;        Because of this, if the alternate mode were set it would influence only 
	;        the position in the overworld.
	ld   [sMap_Unused_UseLevelIdAlt], a 
	
;--
	; Handle automatic submap enter
	ld   a, [sMapAutoEnterOnPathEnd]	; Is the normal auto-enter enabled?
	and  a
	jr   z, .sherbetLandCheck	; If not, jump
	ld   a, KEY_A
	ldh  [hJoyNewKeys], a
	jp   Map_Overworld_EnterSubmap
	
	
;--
; Special handler for C14 right path auto-enter
.sherbetLandCheck:
	
	ld   a, [sMapBridgeAutoMove]	; Have we gone through .sherbetLandSet?
	and  a, $F0
	ret  z							; If not, return
	; Enter the submap
	ld   a, KEY_A					; Not necessary
	ldh  [hJoyNewKeys], a
	xor  a							; Clear automove flag
	ld   [sMapBridgeAutoMove], a
	ld   a, MAP_OWP_BRIDGE			; Set the world position
	ld   [sMapWorldId], a
	jp   Map_Overworld_EnterSubmap
.sherbetLandSet:
	; Handler for the automatic bridge entry, which simply sets sMapBridgeAutoMove for later.
	; A $10 value is used to tell .sherbetLandCheck to do its thing.
	ld   a, $10
	ld   [sMapBridgeAutoMove], a
	jr   .endPath
	
.unused_useAltId: 
	; [TCRF] Unused path return command.
	;
	; See the equivalent code Map_Submap_CheckPathEndType for more context, which is fairly similar.
	;
	; In theory this should act similarly, but... it's broken.
	; The sMap_Unused_LevelIdAlt should have been set rather than sLevelId, 
	; which would lead to glichy effects if it were used.
	;
	; This is all for naught anyway as sMap_Unused_UseLevelIdAlt gets disabled shortly after.
	
	inc  hl       			; Point to the target overworld position      
	ld   a, [hl]
	
	ld   [sMapWorldId], a 	; Set the overworld position
	ld   b, a            	; And the respective "Level ID" ($30 + WorldId)
	ld   a, LVL_OVERWORLD
	add  b
	ld   [sLevelId], a
	
	ld   hl, sMap_Unused_UseLevelIdAlt	; Mark the use of alternate values
	inc  [hl]
	jr   .endPath

; =============== Map_Overworld_CheckForNextPathSeg ===============
; This subroutine indexes the path direction table based on the previously set path direction.
; With the ptr to the path data, memory will be setup to use the next path segment from it.
;
; IN
; - HL: Current path dir data
Map_Overworld_CheckForNextPathSeg:
	;--
	; It's not necessary to fiter valid directions.
	; Since we're in the path, we are already going through it anyway!
	ld   a, [hl]
	ld   b, a
	;--
	
	; Determine the index to use for the direction
	ld   a, [sMapPathDirSel]	
	and  a, b
	bit  KEYB_RIGHT, a
	jr   nz, .right
	bit  KEYB_LEFT, a
	jr   nz, .left
	bit  KEYB_UP, a
	jr   nz, .up
	bit  KEYB_DOWN, a
	jr   nz, .down
	ret ; We never get here
.right:
	ld   a, $01
	jr   .end
.left:
	ld   a, $02
	jr   .end
.up:
	ld   a, $03
	jr   .end
.down:
	ld   a, $04
.end:
	call Map_Overworld_IndexPathDirData
	call Map_Overworld_SetNextPathSeg
	ret
	
; =============== Map_Overworld_GetPathDataPtr ===============
; Gets the a ptr to the path data by path ID.
;
; IN
; - HL: Ptr to path ID
; OUT
; - HL: Ptr to path data
Map_Overworld_GetPathDataPtr:
	ld   a, [hl]					; A = PathId
	ld   hl, PathPtrTable_Overworld
	call B8_IndexPtrTable
	ret

; =============== Map_Overworld_IndexPathDirData ===============
; Indexes a path direction table for the overworld.
;
; IN
; - HL: Ptr to path direction table
; -  A: PathDir struct index
; OUT
; - HL: Ptr to path data
Map_Overworld_IndexPathDirData:

	; Index $00 does not point to path IDs
	; In case we get it, avoid doing anything and return
	or   a, $00		
	ret  z			
	
.loop:
	or   a, $00		; HL += A (Index the path table by direction)
	jr   z, Map_Overworld_GetPathDataPtr
	inc  hl
	dec  a
	jr   .loop

; =============== Map_Overworld_GetPathDirPtr ===============
; Gets the path direction info for the current position in the overworld.
;
; OUT
; - HL: Ptr to path dir info
Map_Overworld_GetPathDirPtr:
	ld   hl, PathDirPtrTable_Overworld
	ld   a, [sMapWorldId]
	call B8_IndexPtrTable
	ret
	
; =============== Map_Overworld_CheckForNewPath ===============
; This subroutine checks if we want to start a path.
; If so, and the path is valid/open we can go there.
;
; IN
;  - HL: Ptr to the path information to use
Map_Overworld_CheckForNewPath:
	; Setup a call to the filtering function.
	; If validation fails, the mask will be set to $00, which cancels the request.
	ld   a, [hl]
	ld   b, a				 ; B = All valid paths
	ldh  a, [hJoyNewKeys]	 ; A = Newly pressed keys
	ld   [sMapPathDirSel], a
	call Map_ValidateNewPath
	and  a, b
	
	; We need to index the correct entry of the PathDir data.
	; Determine the index for the direction we've pressed.
	bit  KEYB_RIGHT, a
	jr   nz, .right
	bit  KEYB_LEFT, a
	jr   nz, .left
	bit  KEYB_UP, a
	jr   nz, .up
	bit  KEYB_DOWN, a
	jr   nz, .down
	ret

.right:
	ld   a, $01
	jr   .end
.left:
	ld   a, $02
	jr   .end
.up:
	ld   a, $03
	jr   .end
.down:
	ld   a, $04
.end:
	call Map_Overworld_IndexPathDirData
	ldi  a, [hl]			; Get first byte -- path ctrl; which is expected to be 3-byte
	ld   [sMapPathCtrl], a
	call Map_SetPathCtrlArgs ; process arguments
	ret
	
; =============== Map_Overworld_DoPathSeg ===============
; This subroutine processes the currently active path segment in the overworld.
; Essentially moves Wario in the overworld depending on the direction we're going.
Map_Overworld_DoPathSeg:
	ld   a, [sMapPathCtrl]
	cp   a, MAP_MPC_STOP	; We never encounter a stop command here
	jr   z, .stop
	cp   a, MAP_MPC_RIGHT
	jp   z, .right
	cp   a, MAP_MPC_LEFT
	jp   z, .left
	cp   a, MAP_MPC_UP
	jp   z, .up
	cp   a, MAP_MPC_DOWN
	jp   z, .down
.stop:
	ret ; We never get here
	
.right:
	ld   bc, sMapStepsLeft
	call .decSteps2
	call Map_Overworld_MoveWarioRight
	ret
.left:
	ld   bc, sMapStepsLeft
	call .decSteps
	call Map_Overworld_MoveWarioLeft
	ret
;--
; Decreases the amount of steps left for the segment by 1.
.decSteps:
	ld   a, [bc]
	dec  a
	ld   [bc], a
	ret
; [TCRF] Identical to the one above.
;        Maybe used to be different for whatever reason, but it's not anymore.
.decSteps2:
	ld   a, [bc]
	dec  a
	ld   [bc], a
	ret
;--
.up:
	ld   bc, sMapStepsLeft
	call .decSteps
	call Map_Overworld_MoveWarioUp
	ret
.down:
	ld   bc, sMapStepsLeft
	call .decSteps2
	call Map_Overworld_MoveWarioDown
	ret
	
; =============== PathDirPtrTable_Overworld ===============
; Defines pointers to path information.
; Each entry points to a 5 byte structure:
;
; - Joypad keys allowed (KEY_*)
; - Right path ID
; - Left path ID
; - Up path ID
; - Down path ID
;
; If there is no path for a direction, it is marked by $FF.
;
PathDirPtrTable_Overworld: 
	dw PathDir_RiceBeach
	dw PathDir_MtTeapot
	dw PathDir_StoveCanyon
	dw PathDir_ParsleyWoods
	dw PathDir_SSTeacup
	dw PathDir_SherbetLand
	dw PathDir_SyrupCastle
	dw PathDir_Bridge
;                        KEY   R   L   U   D
PathDir_RiceBeach:    db $40,$FF,$FF,$00,$FF
PathDir_MtTeapot:     db $D0,$02,$FF,$0B,$01
PathDir_StoveCanyon:  db $A0,$00,$03,$FF,$05 ; [POI] Right path points to Path_RiceBeachUp
PathDir_ParsleyWoods: db $C0,$FF,$FF,$09,$08
PathDir_SSTeacup:     db $60,$FF,$06,$07,$FF
PathDir_SherbetLand:  db $90,$0E,$FF,$FF,$0C
PathDir_SyrupCastle:  db $80,$FF,$FF,$FF,$0A
PathDir_Bridge:       db $20,$FF,$0D,$FF,$FF

; =============== PathPtrTable_Overworld ===============
; Table of ptrs to path definitions, indexed by path ID.
;
; Path format:
;
; A path defines how to move the player when moving from a level/world to another level/world.
; Each path itself is a table of multiple path segments, which basically are straight lines.
; Whenever Wario changes direction (or animation), it requires a new path segment.
;
; ---
; A path segment itself generally 3 bytes:
; - Path command
; - Segment length
; - Wario animation ID
;
; ...with the exception of the last one, which 2 bytes:
; - Path command (always $FF)
; - Return value
;
; Note the first path segment is always treated as the 3-byte format, so a valid
; path needs to define at least 2 path segments.
;
; ---
; Path command:
; Generally determines the direction to move (Up/Down/Left/Right).
; It's not possible to specify diagonal movement, which means paths like the bridge 
; use many small path segments to simulate it.
;
; The type of path command is used to tell how many bytes the path segment uses.
; All commands except for "Stop" use 2 other bytes.
;
; ---
; Segment length:
; How many frames to move in that direction.
; Once it gets to $00, the next path command in the table is used.
;
; ---
; Wario animation ID:
; Self explainatory
;
; ---
; Return value:
;
; Determines what to do when the path ends. 
; There are a few hardcoded values which are treated as "special commands". These are:
; - Entering the bridge
; - Exiting C14 to the right (triggers automove)
; - Exiting C08 from the left (triggers automove)
; - Exiting a submap normally
; - Enabling the alternate path target (not used)
;   With this command, the next byte determines the LevelId to use.
;
; If it's not a special command value, it defines where the path leads to. 
; - In the overworld, it's a WorldId value.
; - In a submap, it's a LevelId value.
;
; It's important to note that you have to make sure the path ends exactly where the target position is defined.
;
; Once the path ends, the game always snaps Wario to the position of this WorldId/LevelId, which is defined elsewhere in a PosPtrTable.
; For the overworld, this "elsewhere" is defined in Map_Overworld_PosPtrTable.
; If the path ends in a different place, the snapping will be noticeable, which will look very wrong.
;
PathPtrTable_Overworld:
	dw Path_RiceBeach_Up
	dw Path_MtTeapot_Down
	dw Path_MtTeapot_Right
	dw Path_StoveCanyon_Left
	dw Path_StoveCanyon_Down ; [TCRF] Unused duplicate of Stove Canyon's path. Is it related to the extraneous right path of PathDir_StoveCanyon?
	dw Path_StoveCanyon_Down
	dw Path_SSTeacup_Left
	dw Path_SSTeacup_Up
	dw Path_ParsleyWoods_Down
	dw Path_ParsleyWoods_Up
	dw Path_SyrupCastle_Down
	dw Path_MtTeapot_Up
	dw Path_SherbetLand_Down
	dw Path_Bridge_Left
	dw Path_SherbetLand_Right

Path_RiceBeach_Up: 
	db $E0,$10,$03
	db $E0,$26,$0E
	db $E0,$0E,$0D
	db $FF,$01
Path_MtTeapot_Down: 
	db $EE,$0E,$0C
	db $EE,$26,$0E
	db $EE,$10,$04
	db $FF,$00
Path_MtTeapot_Right: 
	db $F0,$14,$0C
	db $EE,$0E,$0C
	db $F0,$10,$01
	db $FF,$02
Path_StoveCanyon_Left: 
	db $FE,$10,$02
	db $E0,$0E,$0D
	db $FE,$14,$0D
	db $FF,$01
Path_StoveCanyon_Down: 
	db $EE,$10,$04
	db $EE,$32,$0E
	db $F0,$50,$0E
	db $F0,$08,$01
	db $FF,$04
Path_SSTeacup_Left:
	db $FE,$08,$02
	db $FE,$50,$0E
	db $E0,$36,$0E
	db $E0,$0C,$03
	db $FF,$02
Path_SSTeacup_Up:
	db $E0,$08,$03
	db $E0,$2C,$0E
	db $E0,$04,$03
	db $FF,$03
Path_ParsleyWoods_Down:
	db $EE,$04,$04
	db $EE,$2C,$0E
	db $EE,$08,$04
	db $FF,$04
Path_ParsleyWoods_Up:
	db $E0,$29,$03
	db $FE,$04,$02
	db $FE,$10,$0E
	db $E0,$26,$0E
	db $E0,$04,$03
	db $FF,$06
Path_SyrupCastle_Down:
	db $EE,$10,$02
	db $EE,$1A,$0E
	db $F0,$10,$0E
	db $F0,$04,$01
	db $EE,$2A,$04
	db $FF,$03
Path_MtTeapot_Up:
	db $E0,$26,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$03,$03
	db $FE,$04,$03
	db $FF,$05
Path_SherbetLand_Down:
	db $F0,$04,$04
	db $EE,$03,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $EE,$27,$04
	db $FF,$01
Path_Bridge_Left:
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $E0,$02,$03
	db $FE,$02,$03
	db $FF,$05
Path_SherbetLand_Right:
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $F0,$02,$04
	db $EE,$02,$04
	db $FF,$F8
; =============== Map_OverworldSetStartPos ===============
; Sets the initial coordinates for Wario's position in the overworld.
Map_OverworldSetStartPos:
	; [TCRF] A few places support using an alternate memory address for sMapWorldId / sLevelId. 
	;        However this is never enabled. Leftover debug code, perhaps?       
	ld   a, [sMap_Unused_UseLevelIdAlt]
	and  a
	jr   nz, .unused_useAltId
	ld   a, [sMapWorldId]				; A = Overworld position
.setPos:
	; Index the table by world position
	ld   hl, Map_Overworld_PosPtrTable
	call B8_IndexPtrTable
	; Copy over the data
	ldi  a, [hl]
	ld   [sMapOAMWriteY], a
	ld   [sMapWarioYRes], a
	ld   [sMapWarioY], a
	ldi  a, [hl]
	ld   [sMapOAMWriteX], a
	ld   [sMapWarioX], a
	ldi  a, [hl]
	ld   [sMapScrollY], a
	ld   a, [hl]
	ld   [sMapScrollX], a
	ret
.unused_useAltId:
	ld   a, [sMap_Unused_LevelIdAlt]	; A = Alternate overworld position
	jr   .setPos
	
; =============== Map_Overworld_PosPtrTable ===============
; Initial coordinates for each overworld position.
; Each entry in ptr table points to a 4 byte struct:
; - Wario Y
; - Wario X
; - Scroll Y
; - Scroll X
Map_Overworld_PosPtrTable:
	dw Map_Overworld_RiceBeachPos
	dw Map_Overworld_MtTeapotPos
	dw Map_Overworld_StoveCanyonPos
	dw Map_Overworld_ParsleyWoodsPos
	dw Map_Overworld_SSTeacupPos
	dw Map_Overworld_SherbetLandPos
	dw Map_Overworld_SyrupCastlePos
	dw Map_Overworld_BridgePos
;                               | WY  WX  SCY SCX
Map_Overworld_RiceBeachPos:    db $60,$48,$66,$00
Map_Overworld_MtTeapotPos:     db $60,$48,$22,$00
Map_Overworld_StoveCanyonPos:  db $60,$58,$30,$14
Map_Overworld_ParsleyWoodsPos: db $60,$64,$3A,$60
Map_Overworld_SSTeacupPos:     db $62,$64,$70,$60
Map_Overworld_SherbetLandPos:  db $46,$32,$00,$00
Map_Overworld_SyrupCastlePos:  db $46,$58,$00,$58
Map_Overworld_BridgePos:       db $60,$48,$00,$00

; =============== Map_Unused_Overworld_MoveTest ===============
; [TCRF] Unreferenced (test?) code to move Wario's sprite position in the overworld.
;
; This moves around Wario's sprite and scrolls the screen when needed.
; It works best when called during "free view" mode.
Map_Unused_OverworldMoveTest:
	call Map_Unused_Overworld_MoveWario
	call Map_WriteWarioOBJLst
	ret

; =============== Map_Overworld_AnimTiles ===============
; Updates the 1bpp animated tiles in the overworld to WRAM.
; These then must be copied to VRAM.
Map_Overworld_AnimTiles:
	; Animate tiles every 8th frame
	ld   a, [sMapTimer_Low]
	and  a, $07
	ret  nz
	call Map_Overworld_CopyAnimGFX0
	; [TCRF] These tiles are also animated, but aren't used or copied to VRAM
	call Map_Unused_Overworld_CopyAnimGFX1
	call Map_Unused_Overworld_CopyAnimGFX2
	call Map_Unused_Overworld_CopyAnimGFX3
	call Map_Unused_Overworld_CopyAnimGFX4
	call Map_Unused_Overworld_CopyAnimGFX5
	call Map_Unused_Overworld_CopyAnimGFX6
	call Map_Unused_Overworld_CopyAnimGFX7
	call Map_Unused_Overworld_CopyAnimGFX8
	call Map_Unused_Overworld_CopyAnimGFX9
	;--
	; Update frame id; capped at 8
	ld   hl, sMapAnimFrame
	inc  [hl]
	ld   a, [hl]
	cp   a, $08	; Has it reached 8?
	ret  nz
	xor  a		; If so, reset it to 0
	ld   [hl], a
	ret
Map_Overworld_CopyAnimGFX0:
	ld   hl, GFX_OverworldAnim0
	ld   bc, sMapAnimGFX0
	call Map_Overworld_CopyAnimGFX
	ret
Map_Unused_Overworld_CopyAnimGFX1:
	ld   hl, GFX_Unused_OverworldAnim1
	ld   bc, sMapAnimGFX1
	call Map_Overworld_CopyAnimGFX
	ret
Map_Unused_Overworld_CopyAnimGFX2:
	ld   hl, GFX_Unused_OverworldAnim2
	ld   bc, sMapAnimGFX2
	call Map_Overworld_CopyAnimGFX
	ret
Map_Unused_Overworld_CopyAnimGFX3:
	ld   hl, GFX_Unused_OverworldAnim3
	ld   bc, sMapAnimGFX3
	call Map_Overworld_CopyAnimGFX
	ret
Map_Unused_Overworld_CopyAnimGFX4:
	ld   hl, GFX_Unused_OverworldAnim4
	ld   bc, sMapAnimGFX4
	call Map_Overworld_CopyAnimGFX
	ret
Map_Unused_Overworld_CopyAnimGFX5:
	ld   hl, GFX_Unused_OverworldAnim5
	ld   bc, sMapAnimGFX5
	call Map_Overworld_CopyAnimGFX
	ret
Map_Unused_Overworld_CopyAnimGFX6:
	ld   hl, GFX_Unused_OverworldAnim6
	ld   bc, sMapAnimGFX6
	call Map_Overworld_CopyAnimGFX
	ret
Map_Unused_Overworld_CopyAnimGFX7:
	ld   hl, GFX_Unused_OverworldAnim7
	ld   bc, sMapAnimGFX7
	call Map_Overworld_CopyAnimGFX
	ret
Map_Unused_Overworld_CopyAnimGFX8:
	ld   hl, GFX_Unused_OverworldAnim8
	ld   bc, sMapAnimGFX8
	call Map_Overworld_CopyAnimGFX
	ret
Map_Unused_Overworld_CopyAnimGFX9:
	ld   hl, GFX_Unused_OverworldAnim9
	ld   bc, sMapAnimGFX9
	call Map_Overworld_CopyAnimGFX
	ret
; [TCRF] Completely unreferenced subroutines for animating an 11th and 12th animated tile.
Map_Unused_Overworld_CopyAnimGFXA:
	ld   hl, GFX_Unused_OverworldAnimA
	ld   bc, sMapAnimGFXA
	call Map_Overworld_CopyAnimGFX
	ret
Map_Unused_Overworld_CopyAnimGFXB:
	ld   hl, GFX_Unused_OverworldAnimB
	ld   bc, sMapAnimGFXB
	call Map_Overworld_CopyAnimGFX
	ret

; =============== Map_Overworld_CopyAnimGFX ===============
; Copies a single 1bpp animated frame GFX from ROM to an area in SRAM.
;
; An animated 1bpp tile in the overworld is made of 8 separate frame.
; As each frame is 1bpp, it takes $08 bytes, which is the amount of data to copy.
; The total size of an animated tile is $40 bytes as a result.
;
; The graphics data is stored in a somewhat weird way, kind of similar to Level_AnimTiles but not really.
; Given the 8 animated frames, the first byte of every frame is stored first, then the second, etc...
; It's why HL is increased 8 times during the copy -- it has to skip the data for other tiles.
;
; IN
; - HL: Ptr to GFX data in ROM
; - BC: Ptr to destination in SRAM
Map_Overworld_CopyAnimGFX:
	xor  a					; DE = Frame number
	ld   d, a
	ld   a, [sMapAnimFrame]
	ld   e, a
	add  hl, de				; Index the first byte of the frame
	
	ld   de, $0808			; D = Bytes to copy 
.loop:
	ld   a, [hl]			; Copy 1 byte over
	ld   [bc], a
	inc  hl					; HL += 8 to skip data for other tiles
	inc  hl
	inc  hl
	inc  hl
	inc  hl
	inc  hl
	inc  hl
	inc  hl
	inc  bc
	
	ld   a, d				
	dec  a					; D--;
	cp   a, $00				; Have we copied the 8 bytes?
	ret  z					; If so, return
	ld   d, a
	jr   .loop
	
GFX_Unused_OverworldAnimC:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim0C.bin"
	ret
GFX_OverworldAnim0:         mIncludeMultiInt "data/gfx/maps/overworld_anim00.bin"
	ret
GFX_Unused_OverworldAnimD:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim0D.bin"
	ret
GFX_Unused_OverworldAnimE:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim0E.bin"
GFX_Unused_OverworldAnim1:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim01.bin"
	ret
GFX_Unused_OverworldAnim2:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim02.bin"
	ret
GFX_Unused_OverworldAnimF:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim0F.bin"
	ret
GFX_Unused_OverworldAnim3:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim03.bin"
	ret
GFX_Unused_OverworldAnim4:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim04.bin"
	ret
GFX_Unused_OverworldAnim5:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim05.bin"
	ret
GFX_Unused_OverworldAnim6:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim06.bin"
	ret
GFX_Unused_OverworldAnim10: mIncludeMultiInt "data/gfx/maps/overworld_unused_anim10.bin"
	ret
GFX_Unused_OverworldAnim7:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim07.bin"
	ret
GFX_Unused_OverworldAnim8:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim08.bin"
	ret
GFX_Unused_OverworldAnim11: mIncludeMultiInt "data/gfx/maps/overworld_unused_anim11.bin"
	ret
GFX_Unused_OverworldAnim12: mIncludeMultiInt "data/gfx/maps/overworld_unused_anim12.bin"
	ret
GFX_Unused_OverworldAnim9:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim09.bin"
	ret
GFX_Unused_OverworldAnim13: mIncludeMultiInt "data/gfx/maps/overworld_unused_anim13.bin"
	ret
GFX_Unused_OverworldAnimA:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim0A.bin"
	ret
GFX_Unused_OverworldAnimB:  mIncludeMultiInt "data/gfx/maps/overworld_unused_anim0B.bin"
	ret
	
; =============== Map_WriteWarioOBJLst ===============
; Updates Wario's sprite mappings, then writes it to OAM.
Map_WriteWarioOBJLst:
	; Prepare Y pos and set a ptr to the current sprite mapping id in HL
	call Map_WarioAnim
	ld   a, [hl]				; Set the mapping id
	ld   [sMapWarioLstId], a
; =============== Map_WriteWarioOBJLstCustom ===============
; Writes Wario's sprite mappings for the map screen.
; This will not perform animationa.
Map_WriteWarioOBJLstCustom:
	ld   hl, OBJLstPtrTable_MapWario
	ld   a, [sMapWarioYRes]		; Use the "visual position" to show the sprite moving up/down in place.
	ld   [sMapOAMWriteY], a
	ld   a, [sMapWarioX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapWarioLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapWarioFlags]
	ld   [sMapOAMWriteFlags], a
	call Map_WriteOBJLst
	ret
;--
	ret
	ret
	ret
	ret
; =============== Map_CheckMapId ===============
; Jumps to the handler for the current sMapId
Map_CheckMapId:
	ld   a, [sMapId]
	rst  $28
	dw Map_Mode_Init
	dw Map_Mode_OverworldInit	
	dw Map_Mode_Overworld
	dw Map_Mode_RiceBeachInit
	dw Map_Mode_RiceBeach
	dw Map_Mode_MtTeapotInit
	dw Map_Mode_MtTeapot
	dw Map_Mode_FadeIn
	dw Map_Mode_FadeOut
	dw Map_Mode_StoveCanyonInit
	dw Map_Mode_StoveCanyon
	dw Map_Mode_SyrupCastleInit
	dw Map_Mode_SyrupCastle
	dw Map_Mode_ParsleyWoodsInit
	dw Map_Mode_ParsleyWoods
	dw Map_Mode_SSTeacupInit
	dw Map_Mode_SSTeacup
	dw Map_Mode_SherbetLandInit
	dw Map_Mode_SherbetLand
	dw Map_Mode_C12ClearInit
	dw Map_Mode_C12Clear
	dw Map_Mode_CutsceneFadeOut
	dw Map_Mode_C30ClearInit
	dw Map_Mode_C30Clear
	dw Map_Mode_C32ClearInit
	dw Map_Mode_C32Clear
	dw Map_Mode_C38ClearInit
	dw Map_Mode_Dummy ; [TCRF] Placeholder map mode.
	dw Map_Mode_C39ClearInit
	dw Map_Mode_Dummy ; [TCRF] Placeholder map mode.
	dw Map_Mode_EndingInit
	dw Map_Mode_Ending
	dw Map_Mode_EndingFadeIn
	dw Map_Mode_C40ClearInit ; Technically not done when C40 is cleared, but whatever
	ret
; =============== Map_Mode_Init ===============
; Mode $00
; Initializes the Map Screen.
Map_Mode_Init:
	; Syncronize the completion status mirrors
	; This prevents playing any world clear / path completion anims
	ld   a, [sMapRiceBeachCompletion]
	ld   [sMapRiceBeachCompletionLast], a
	ld   a, [sMapMtTeapotCompletion]
	ld   [sMapMtTeapotCompletionLast], a
	ld   a, [sMapStoveCanyonCompletion]
	ld   [sMapStoveCanyonCompletionLast], a
	ld   a, [sMapSSTeacupCompletion]
	ld   [sMapSSTeacupCompletionLast], a
	ld   a, [sMapParsleyWoodsCompletion]
	ld   [sMapParsleyWoodsCompletionLast], a
	ld   a, [sMapSherbetLandCompletion]
	ld   [sMapSherbetLandCompletionLast], a
	ld   a, [sMapSyrupCastleCompletion]
	ld   [sMapSyrupCastleCompletionLast], a
	
	;--
	
	; This is a special case when starting a new save
	; If no levels are marked completed at Rice Beach, it should start on the overworld
	ld   a, [sMapRiceBeachCompletion]
	and  a
	jr   z, Map_SetStartPosNewSave
	
	; Direct copy of the level ID
	ld   a, [sLevelId]
	ld   [sMapLevelId], a
	ld   a, [sLevelId]
	
	; [TCRF] This check always fails, see Map_SetStartPosOverworld
	and  a, $F0							; Remove the overworld position detail
	cp   a, LVL_OVERWORLD				; Should we spawn in the overworld?
	jr   z, Map_SetStartPosOverworld	; If so, jump
	;--
	; Get the overworld position to use when exiting the submap.
	ld   hl, Map_SubmapExitTbl			
	call Map_IndexTblByLevelId
	ld   [sMapWorldId], a
	
; =============== Map_SetStartMode ===============
; Sets the initial submap to start the player at.
Map_SetStartMode:
	; Get current submap (init) mode from the LevelId -> MapId assoc table.
	ld   hl, Map_LevelSubmapTbl
	call Map_IndexTblByLevelId
	ld   [sMapId], a
	
	; Special case for C30 clear with the lake not drained.
	; This is required because the game would normally start you over over C30,
	; allowing you to be outside of Parsley Woods before draining the lake.
	;
	; To get around that, the C30 Clear cutscene is triggered instead, which will set our position to Parsley Woods.
	ld   a, [sLevelId]						; Was C30 the last course accessed?
	cp   a, LVL_C30
	ret  nz									; If not, return
	ld   a, [sMapParsleyWoodsCompletion]	; Are any levels in Parsley Woods completed?
	and  a
	ret  nz									; If so, return
	; If we got here, we have reset the game after triggering the cutscene, but before entering C31.
	; Unmark the completion bit to force play the cutscene again.
	ld   a, $0F								
	ld   [sMapSSTeacupCompletionLast], a
	
	ret
; =============== Map_IndexTblByLevelId ===============
; This subroutine indexes a table by LevelId and returns its value.
; 
; IN
; - HL: Ptr to the table to index.
;       The entries inside should be 1 byte large, which disqualifies Ptr Tables.
; OUT
; -  A: Value at HL[sLevelId]
Map_IndexTblByLevelId:
	xor  a
	ld   d, a			; DE = sLevelId
	ld   a, [sLevelId]
	ld   e, a
	add  hl, de			
	ld   a, [hl]		; A = Tbl[sLevelId]
	ret
	
; =============== Map_SetStartPosOverworld ===============
; [TCRF] This is meant to start you in the overworld based on the last LevelID.
; There is a special case for levels with ID >= $30 (which would point to invalid level IDs),
; that are interpreted as part of the overworld.
;
; However, this is only called with the hardcoded parameter of $30 when no stages are completed in Rice Beach
; (see Map_SetStartPosNewSave), used when starting a new save.
;
; This is because the game only saves the current LevelId to SRAM only when starting a level,
; which is obviously not possible in the overworld.
Map_SetStartPosOverworld:
	; For sLevelId to point to the overworld, it needs to be >= $30
	; WorldId = LevelId - $30
	ld   a, [sLevelId]		
	and  a, $0F				; Clear the upper nybble to get the WorldId
	ld   [sMapWorldId], a
	jr   Map_SetStartMode
; =============== Map_SetStartPosNewSave ===============
; Sets the starting position when starting a new save.
Map_SetStartPosNewSave:
	ld   a, LVL_OVERWORLD	; Rice Beach
	ld   [sLevelId], a
	jr   Map_SetStartPosOverworld
	
; =============== Map_LevelSubmapTbl ===============
; Maps the initial MapId (map mode) to spawn in for every level ID, which for normal levels points to a submap init mode.
; This is used to determine the submap to spawn in after initializing the map screen.
Map_LevelSubmapTbl: 
	db MAP_MODE_INITSSTEACUP     	; LVL_C26                    
	db MAP_MODE_INITPARSLEYWOODS 	; LVL_C33                    
	db MAP_MODE_INITSHERBETLAND  	; LVL_C15                    
	db MAP_MODE_INITSTOVECANYON  	; LVL_C20                    
	db MAP_MODE_INITSHERBETLAND  	; LVL_C16                    
	db MAP_MODE_INITMTTEAPOT     	; LVL_C10                    
	db MAP_MODE_INITMTTEAPOT     	; LVL_C07                    
	db MAP_MODE_INITRICEBEACH    	; LVL_C01A                   
	db MAP_MODE_INITSHERBETLAND  	; LVL_C17                    
	db MAP_MODE_INITMTTEAPOT     	; LVL_C12                    
	db MAP_MODE_INITMTTEAPOT     	; LVL_C13                    
	db MAP_MODE_INITSSTEACUP     	; LVL_C29                    
	db MAP_MODE_INITRICEBEACH    	; LVL_C04                    
	db MAP_MODE_INITMTTEAPOT     	; LVL_C09                    
	db MAP_MODE_INITRICEBEACH    	; LVL_C03A                   
	db MAP_MODE_INITRICEBEACH    	; LVL_C02                    
	db MAP_MODE_INITMTTEAPOT     	; LVL_C08                    
	db MAP_MODE_INITMTTEAPOT     	; LVL_C11                    
	db MAP_MODE_INITPARSLEYWOODS 	; LVL_C35                    
	db MAP_MODE_INITPARSLEYWOODS 	; LVL_C34                    
	db MAP_MODE_INITSSTEACUP     	; LVL_C30                    
	db MAP_MODE_INITSTOVECANYON  	; LVL_C21                    
	db MAP_MODE_INITSTOVECANYON  	; LVL_C22                    
	db MAP_MODE_INITRICEBEACH    	; LVL_C01B
	db MAP_MODE_INITSHERBETLAND  	; LVL_C19                    
	db MAP_MODE_INITRICEBEACH    	; LVL_C05                    
	db MAP_MODE_INITPARSLEYWOODS 	; LVL_C36                    
	db MAP_MODE_INITSTOVECANYON  	; LVL_C24                    
	db MAP_MODE_INITSTOVECANYON		; LVL_C25                    
	db MAP_MODE_INITPARSLEYWOODS	; LVL_C32                    
	db MAP_MODE_INITSSTEACUP		; LVL_C27                    
	db MAP_MODE_INITSSTEACUP		; LVL_C28                    
	db MAP_MODE_INITSHERBETLAND  	; LVL_C18                    
	db MAP_MODE_INITSHERBETLAND  	; LVL_C14                    
	db MAP_MODE_INITSYRUPCASTLE  	; LVL_C38                    
	db MAP_MODE_INITSYRUPCASTLE  	; LVL_C39                    
	db MAP_MODE_INITRICEBEACH    	; LVL_C03B                   
	db MAP_MODE_INITSYRUPCASTLE  	; LVL_C37                    
	db MAP_MODE_INITPARSLEYWOODS 	; LVL_C31A                   
	db MAP_MODE_INITSTOVECANYON  	; LVL_C23                    
	db MAP_MODE_INITSYRUPCASTLE  	; LVL_C40                    
	db MAP_MODE_INITRICEBEACH    	; LVL_C06                    
	db MAP_MODE_INITPARSLEYWOODS 	; LVL_C31B    
	; Dummy entries for nonexisting levels, which will softlock the game
	db MAP_MODE_INIT				; LVL_UNUSED_2B              	
	db MAP_MODE_INIT				; LVL_UNUSED_2C              
	db MAP_MODE_INIT				; LVL_UNUSED_2D              
	db MAP_MODE_INIT				; LVL_UNUSED_2E              
	db MAP_MODE_INIT				; LVL_UNUSED_2F  
	; Overworld positions
	db MAP_MODE_INITOVERWORLD		; LVL_OVERWORLD
	; [TCRF] See Map_SetStartPosOverworld
	db MAP_MODE_INITOVERWORLD		; LVL_OVERWORLD_MTTEAPOT       
	db MAP_MODE_INITOVERWORLD		; LVL_OVERWORLD_STOVECANYON  
	db MAP_MODE_INITOVERWORLD		; LVL_OVERWORLD_PARSLEYWOODS 
	db MAP_MODE_INITOVERWORLD		; LVL_OVERWORLD_SSTEACUP     
	db MAP_MODE_INITOVERWORLD		; LVL_OVERWORLD_SHERBETLAND  
	db MAP_MODE_INITOVERWORLD		; LVL_OVERWORLD_SYRUPCASTLE  
	db MAP_MODE_INITOVERWORLD		; LVL_OVERWORLD_BRIDGE       
	; Padding entries
	db MAP_MODE_INITOVERWORLD		; 
	db MAP_MODE_INITOVERWORLD		; 
	db MAP_MODE_INITOVERWORLD		; 
	db MAP_MODE_INITOVERWORLD		; 
	db MAP_MODE_INITOVERWORLD		; 
	db MAP_MODE_INITOVERWORLD		; 
	db MAP_MODE_INITOVERWORLD		; 
	db MAP_MODE_INITOVERWORLD		; 

; =============== Map_SubmapExitTbl ===============
; Maps for each Level ID the overworld position to use when exiting the submap.
Map_SubmapExitTbl:
	db MAP_OWP_SSTEACUP			; LVL_C26                    
	db MAP_OWP_PARSLEYWOODS     ; LVL_C33                    
	db MAP_OWP_SHERBETLAND      ; LVL_C15                    
	db MAP_OWP_STOVECANYON      ; LVL_C20                    
	db MAP_OWP_SHERBETLAND      ; LVL_C16                    
	db MAP_OWP_MTTEAPOT         ; LVL_C10                    
	db MAP_OWP_MTTEAPOT         ; LVL_C07                    
	db MAP_OWP_RICEBEACH        ; LVL_C01A                   
	db MAP_OWP_SHERBETLAND      ; LVL_C17                    
	db MAP_OWP_MTTEAPOT         ; LVL_C12                    
	db MAP_OWP_MTTEAPOT         ; LVL_C13                    
	db MAP_OWP_SSTEACUP         ; LVL_C29                    
	db MAP_OWP_RICEBEACH        ; LVL_C04                    
	db MAP_OWP_MTTEAPOT         ; LVL_C09                    
	db MAP_OWP_RICEBEACH        ; LVL_C03A                   
	db MAP_OWP_RICEBEACH        ; LVL_C02                    
	db MAP_OWP_MTTEAPOT         ; LVL_C08                    
	db MAP_OWP_MTTEAPOT         ; LVL_C11                    
	db MAP_OWP_PARSLEYWOODS     ; LVL_C35                    
	db MAP_OWP_PARSLEYWOODS     ; LVL_C34                    
	db MAP_OWP_SSTEACUP         ; LVL_C30                    
	db MAP_OWP_STOVECANYON      ; LVL_C21                    
	db MAP_OWP_STOVECANYON      ; LVL_C22                    
	db MAP_OWP_RICEBEACH        ; LVL_C01B                   
	db MAP_OWP_SHERBETLAND      ; LVL_C19                    
	db MAP_OWP_RICEBEACH        ; LVL_C05                    
	db MAP_OWP_PARSLEYWOODS     ; LVL_C36                    
	db MAP_OWP_STOVECANYON      ; LVL_C24                    
	db MAP_OWP_STOVECANYON      ; LVL_C25                    
	db MAP_OWP_PARSLEYWOODS     ; LVL_C32                    
	db MAP_OWP_SSTEACUP         ; LVL_C27                    
	db MAP_OWP_SSTEACUP         ; LVL_C28                    
	db MAP_OWP_SHERBETLAND      ; LVL_C18                    
	db MAP_OWP_SHERBETLAND      ; LVL_C14                    
	db MAP_OWP_SYRUPCASTLE      ; LVL_C38                    
	db MAP_OWP_SYRUPCASTLE      ; LVL_C39                    
	db MAP_OWP_RICEBEACH        ; LVL_C03B                   
	db MAP_OWP_SYRUPCASTLE      ; LVL_C37                    
	db MAP_OWP_PARSLEYWOODS     ; LVL_C31A                   
	db MAP_OWP_STOVECANYON      ; LVL_C23                    
	db MAP_OWP_SYRUPCASTLE      ; LVL_C40                    
	db MAP_OWP_RICEBEACH        ; LVL_C06                    
	db MAP_OWP_PARSLEYWOODS     ; LVL_C31B    
	; [TCRF] Includes the dummy entries for some reason
	db MAP_OWP_RICEBEACH        ; LVL_UNUSED_2B              
	db MAP_OWP_RICEBEACH        ; LVL_UNUSED_2C              
	db MAP_OWP_RICEBEACH        ; LVL_UNUSED_2D              
	db MAP_OWP_RICEBEACH        ; LVL_UNUSED_2E              
	db MAP_OWP_RICEBEACH        ; LVL_UNUSED_2F              
	ret   
; =============== Map_Mode_OverworldInit ===============
; Mode $01
Map_Mode_OverworldInit:
	call Map_LoadPalette
	call HomeCall_LoadGFX_Overworld
	call HomeCall_LoadBG_Overworld
	call Map_Overworld_CheckEv
	call Map_ClearRAM
	call Map_OverworldSetStartPos
	call HomeCall_Map_MtTeapotLidSetPos
	call HomeCall_Map_InitWorldClearFlags
	call HomeCall_Map_InitFreeViewArrows
	call Map_InitMisc
	ld   a, MAP_MODE_FADEIN
	ld   [sMapId], a
	ld   a, MAP_MODE_OVERWORLD
	ld   [sMapNextId], a
	ld   a, $00					; This immediately blanks out the palette (in preparation for the fade-in)
	ldh  [rBGP], a
	ld   a, BGM_OVERWORLD
	ld   [sBGMSet], a
	
	ld   a, [sMapWorldClear]	; Is a World Clear "cutscene" playing?
	and  a
	ret  z
	ld   a, BGM_WORLDCLEAR		; If so, play the appropriate BGM
	ld   [sBGMSet], a
	xor  a
	ld   [sMapTimer0], a
	ret
; =============== Map_FreeViewCtrl ===============
; Handles movement during free view mode (when B is held in the overworld)
Map_FreeViewCtrl:
	ldh  a, [hJoyKeys]
	cp   a, KEY_B|KEY_RIGHT|KEY_UP
	jr   z, .upRight
	cp   a, KEY_B|KEY_RIGHT|KEY_DOWN
	jr   z, .downRight
	cp   a, KEY_B|KEY_LEFT|KEY_UP
	jr   z, .upLeft
	cp   a, KEY_B|KEY_LEFT|KEY_DOWN
	jr   z, .downLeft
	bit  KEYB_UP, a
	jr   nz, .moveUp
	bit  KEYB_DOWN, a
	jr   nz, .moveDown
	bit  KEYB_LEFT, a
	jr   nz, .moveLeft
	bit  KEYB_RIGHT, a
	jr   nz, .moveRight
.noKey:
	; No keys were pressed in his frame
	ld   a, [sMapFreeViewReturn]	; Is the HARD return type already set?
	and  a, MAP_FVR_HARDM
	ret  nz							; If so, return
	ld   a, MAP_FVR_SOFT			; Otherwise, initialize it to the SOFT return
	ld   [sMapFreeViewReturn], a
	ret
.upRight:
	call .moveUp
	jr   .moveRight
.downRight:
	call .moveDown
	jr   .moveRight
.upLeft:
	call .moveUp
	jr   .moveLeft
.downLeft:
	call .moveDown
	jr   .moveLeft
	
; Handle movement for the free view
; As all sprites are disabled, it's a simple deal
.moveUp:
	; We've moved, so use the hard return type
	ld   a, MAP_FVR_HARD			
	ld   [sMapFreeViewReturn], a
	; Scroll the screen up if we haven't reached the topmost border
	ld   hl, sMapScrollY			
	ld   a, [hl]
	and  a
	ret  z
	call B8_DecHL
	ret
.moveDown:
	ld   a, MAP_FVR_HARD
	ld   [sMapFreeViewReturn], a
	ld   hl, sMapScrollY
	ld   a, [hl]
	cp   a, SCREEN_YMAX
	ret  z
	call B8_IncHL
	ret
.moveLeft:
	ld   a, MAP_FVR_HARD
	ld   [sMapFreeViewReturn], a
	ld   hl, sMapScrollX
	ld   a, [hl]
	and  a
	ret  z
	call B8_DecHL
	ret
.moveRight:
	ld   a, MAP_FVR_HARD
	ld   [sMapFreeViewReturn], a
	ld   hl, sMapScrollX
	ld   a, [hl]
	cp   a, SCREEN_XMAX
	ret  z
	call B8_IncHL
	ret
	
; =============== Map_Unused_Overworld_MoveWario ===============
; [TCRF] Unreferenced code called by Map_Unused_OverworldMoveTest.
; This subroutine moves Wario's sprite based off joypad input.
Map_Unused_Overworld_MoveWario:
	ldh  a, [hJoyKeys]
	bit  KEYB_UP, a
	jp   nz, Map_Overworld_MoveWarioUp
	bit  KEYB_DOWN, a
	jp   nz, Map_Overworld_MoveWarioDown
	bit  KEYB_LEFT, a
	jr   nz, Map_Overworld_MoveWarioLeft
	bit  KEYB_RIGHT, a
	jr   nz, Map_Overworld_MoveWarioRight
	ld   a, $07
	ld   [sMapWarioYOscillateMask], a
	ret

; =============== Map_Overworld_MoveWarioLeft ===============
; Overworld movement function.
;
; There are four different functions, each for moving to a different direction.
; Each follows a similar template:
;
; - set Y oscillation
; - [1] when playerPos == centerScreen:
;   - scroll screen to the specified direction
;   - if screen scroll reaches the border, move playerPos to the direction (switch to [3])
; - [2] when playerPos > centerScreen (easy):
;   - move playerPos to the direction.
;     will auto-switch to [1] once playerPos is centered
; - [3] when playerPos < centerScreen (hard):
;   - move the screen to the specified direction if it doesn't already reach the border
;   - otherwise, move playerPos to the direction
;
; Depending on the direction, conditions [2] and [3] may be switched
; based on if they increase or decrease the coordinate.
;
; There are also impossible off-screen checks can only be triggered with the unused movement test code.

MAP_WX_CENTER EQU $58 ; Center screen Wario X
MAP_WY_CENTER EQU $60 ; Center screen Wario Y

Map_Overworld_MoveWarioLeft:
	; Use fast Y oscillation since we're moving
	ld   a, $03
	ld   [sMapWarioYOscillateMask], a
	
	; Determine the general location of the screen we're on
	
	; If Wario's at the center of the screen (X position $58 here), scroll the screen left
	ld   a, [sMapWarioX]
	ld   b, MAP_WX_CENTER	; A = WX - $58
	sub  a, b			
	jr   z, .onCenterScreen ; if so, scroll left
	
	; Check if we are on the leftmost or rightmost side of the screen
	; Because of the sub operation we can simply check the MSB to determine it.
	bit  7, a						; sMapWarioX > $58?
	jr   z, .onRightSide 			; if so, jump (will move Wario's sprite left)
	
;--
; 	LEFTMOST SIDE
;--
.onLeftSide:
	
	; [TCRF] If somehow the screen isn't fully scrolled to the left, decrease that instead.
	ld   a, [sMapScrollX]		
	cp   a, SCREEN_XMIN					
	jr   nz, .unused_fixScrollLeft		
	;--
	
	; MIN(sMapWarioX-1, $0F)
	
	; Move the player left
	ld   hl, sMapWarioX
	dec  [hl]
	
	;--
	; [TCRF] Never go even partially off-screen
	ld   a, [hl]				
	cp   a, $0F						; Is the newly decreased X position is exactly $0F?
	jr   z, .unused_snapToBorder	; If so, force it back to $10
	ret
	
;--
; 	CENTER SCREEN
;--
.onCenterScreen:
	; If the scroll X position reaches 0, it should mark the end of this scroll mode
	ld   a, [sMapScrollX]
	cp   a, SCREEN_XMIN
	jr   z, .switchToLeftSide
	
	; Otherwise simply scroll the screen left like normal
	ld   hl, sMapScrollX
	call B8_DecHL
	ret
.switchToLeftSide:
	; Move Wario to the left, which will make the game use .maxScrollLeft
	ld   hl, sMapWarioX
	dec  [hl]
	jr   z, .unused_snapToBorder
	ret
;--
.unused_snapToBorder: 
	ld   a, $10				; [TCRF] Forces Wario to not go off screen
	ld   [sMapWarioX], a
	ret
	
;--
; 	RIGHTMOST SIDE
;--
.onRightSide:
	ld   hl, sMapWarioX
	dec  [hl]
	ret
;--
.unused_fixScrollLeft: 
	ld   hl, sMapScrollX	; [TCRF] Moves the screen if we should be on the leftmost border
	dec  [hl]				;        but the screen isn't fully scrolled to the left
	ret

; =============== Map_Overworld_MoveWarioRight ===============
Map_Overworld_MoveWarioRight:
	; Use fast Y oscillation since we're moving
	ld   a, $03
	ld   [sMapWarioYOscillateMask], a
	
	; If Wario's at the center of the screen, scroll the screen right
	ld   a, [sMapWarioX]
	ld   b, MAP_WX_CENTER			; X $58 = Middle of the screen
	sub  a, b
	jr   z, .onCenterScreen
	
	; Check if we are on the leftmost or rightmost border
	bit  7, a
	jr   z, .onRightSide
	
;--
; 	LEFTMOST SIDE
;--
.onLeftSide:
	; We're on the leftmost border of the screen
	
	ld   hl, sMapWarioX		; PlayerX++
	inc  [hl]
	
	;--
	; this is probably by mistake here. 
	; can't have WX < $58 and WX > $A1 at the same time, you know
	ld   a, [hl]			
	cp   a, $A1
	jr   z, .unused_snapToBorder
	;--
	ret
	
;--
; 	CENTER SCREEN
;--
.onCenterScreen:
	; If the scroll X position reaches $60, it should mark the end of this scroll mode
	ld   a, [sMapScrollX]
	cp   a, SCREEN_XMAX
	jr   z, .switchToRightSide
	
	; Otherwise scroll the screen right as usual
	ld   hl, sMapScrollX	
	call B8_IncHL
	ret
.switchToRightSide:
	ld   hl, sMapWarioX
	inc  [hl]
	ret
	
;--
; 	RIGHTMOST SIDE
;--
.onRightSide:
	; [TCRF] If somehow the screen isn't fully scrolled to the right, increase that instead.
	ld   a, [sMapScrollX]	
	cp   a, SCREEN_XMAX	
	jr   nz, .unused_fixScrollRight
	;--
	
	; Move the player right
	ld   hl, sMapWarioX		
	inc  [hl]
	
	;--
	; [TCRF] Check for off-screen
	ld   a, [hl]			
	cp   a, $A1
	jr   z, .unused_snapToBorder
	ret
.unused_fixScrollRight: 
	ld   hl, sMapScrollX
	inc  [hl]
	ret
.unused_snapToBorder: 
	ld   a, $A0
	ld   [sMapWarioX], a
	ret
	
; =============== Map_Overworld_MoveWarioUp ===============
Map_Overworld_MoveWarioUp:
	; Use fast Y oscillation since we're moving
	ld   a, $03
	ld   [sMapWarioYOscillateMask], a
	
	; If Wario's at the center of the screen, scroll the screen up
	ld   a, [sMapWarioY]
	ld   b, MAP_WY_CENTER		; Y Center = $60
	sub  a, b
	jr   z, .onCenterScreen
	
	; Check if we are on the topmost or bottommost border
	bit  7, a
	jr   z, .onBottomSide
	
;--
; 	TOPMOST SIDE
;--
.onTopSide:
	; [TCRF] If somehow the screen isn't fully scrolled to the top, decrease that instead.
	ld   a, [sMapScrollY]
	cp   a, SCREEN_YMIN
	jr   nz, .unused_fixScrollUp
	;--
	
	; Move up both real and virtual Y pos
	ld   hl, sMapWarioYRes
	dec  [hl]
	ld   hl, sMapWarioY
	dec  [hl]
	
	;--
	; [TCRF] Check for off-screen
	ld   a, [hl]
	cp   a, $1F
	jr   z, .unused_snapToBorder
	
	ret
.unused_fixScrollUp: 
	ld   hl, sMapScrollY
	dec  [hl]
	ret
.unused_snapToBorder: 
	ld   a, $20
	ld   [sMapWarioY], a
	ld   [sMapWarioYRes], a
	ret
	
;--
; 	CENTER SCREEN
;--
.onCenterScreen:
	; If the scroll X position reaches $60, it should mark the end of this scroll mode
	ld   a, [sMapScrollY]
	cp   a, SCREEN_YMIN
	jr   z, .switchToUpSide
	
	; Otherwise scroll the screen up as usual
	ld   hl, sMapScrollY
	call B8_DecHL
	ret
.switchToUpSide:
	ld   hl, sMapWarioYRes
	dec  [hl]
	ld   hl, sMapWarioY
	dec  [hl]
	jp   z, .unused_snapToBorder
	; There should be a 'ret' here.
	; The extra px of movement isn't noticeable though.
	
;--
; 	BOTTOMMOST SIDE
;--
.onBottomSide:
	; Move the player upwards
	ld   hl, sMapWarioYRes
	dec  [hl]
	ld   hl, sMapWarioY
	dec  [hl]
	ret
	
; =============== Map_Overworld_MoveWarioDown ===============	
Map_Overworld_MoveWarioDown:
	; Use fast Y oscillation since we're moving
	ld   a, $03
	ld   [sMapWarioYOscillateMask], a
	
	; If Wario's at the center of the screen, scroll the screen down
	ld   a, [sMapWarioY]
	ld   b, MAP_WY_CENTER
	sub  a, b
	jr   z, .onCenterScreen
	
	; Check if we are on the leftmost or rightmost border
	bit  7, a
	jr   z, .onBottomSide
	
;--
; 	TOPMOST SIDE
;--
.onTopSide:
	; Move the player downwards
	ld   hl, sMapWarioYRes
	inc  [hl]
	ld   hl, sMapWarioY
	inc  [hl]
	
	;--
	; this is also probably by mistake here. 
	; would work if WX < $60 and WX > $A1 at the same time
	ld   a, [hl]
	cp   a, $A1
	jr   z, .unused_snapToBorder
	;--
	ret
	
.unused_fixScrollDown: 
	ld   hl, sMapScrollY
	inc  [hl]
	ret
.unused_snapToBorder: 
	ld   a, $A0
	ld   [sMapWarioY], a
	ld   [sMapWarioYRes], a
	ret

;--
; 	CENTER SCREEN
;--
.onCenterScreen:
	; If the scroll X position reaches $70, it should mark the end of this scroll mode
	ld   a, [sMapScrollY]
	cp   a, SCREEN_YMAX
	jr   z, .switchToDownSide
	
	; Otherwise scroll the screen down as usual
	ld   hl, sMapScrollY
	call B8_IncHL
	ret
.switchToDownSide:
	ld   hl, sMapWarioYRes
	inc  [hl]
	ld   hl, sMapWarioY
	inc  [hl]
	ret
	
;--
; 	BOTTOMMOST SIDE
;--
.onBottomSide:
	; [TCRF] If somehow the screen isn't fully scrolled to the bottom, increase that instead.
	ld   a, [sMapScrollY]
	cp   a, SCREEN_YMAX
	jr   nz, .unused_fixScrollDown
	;--
	
	; Move down both real and virtual Y pos
	ld   hl, sMapWarioYRes
	inc  [hl]
	ld   hl, sMapWarioY
	inc  [hl]
	
	;--
	; [TCRF] Check for off-screen
	ld   a, [hl]
	cp   a, $A1
	jr   z, .unused_snapToBorder
	ret
	ret
	
; =============== B8_IncHL ===============
B8_IncHL:
	ld   a, [hl]
	inc  a
	ld   [hl], a
	ret
; =============== B8_DecHL ===============
B8_DecHL:
	ld   a, [hl]
	dec  a
	ld   [hl], a
	ret
	
; =============== Map_Overworld_Unused_ScrollTest ===============
; [TCRF] Unreferenced code.
;
; This will scroll the screen around the overworld along a square path.
; It stores its state in memory addresses normally used for path movement.
;
; When its done, it will reload the overworld without a fade in.
; 
Map_Overworld_Unused_ScrollTest:
	call Map_Overworld_Unused_ScrollTest_Do
	call Map_Overworld_AnimTiles
	ret  
Map_Overworld_Unused_ScrollTest_Do:
	; Wait for $3F frames befire starting the movement
	ld   a, [sMapPathTestCtrl]
	cp   a, $00					; Path Ctrl at the initial value?
	jr   z, .delayStart			; If so, jump
.checkEnd:
	ld   a, [sMapPathTestCtrl]
	cp   a, $05					; Have we reached the last direction?
	jr   nz, .main				; If not, jump
.end:
	; Wait for $FF frames before restarting the overworld 
	ld   a, [sMapTimer_Low]
	and  a, $FF
	ret  nz
	jp   Map_Mode_OverworldInit
.delayStart:
	ld   a, [sMapTimer_Low]
	and  a, $3F
	ret  nz
	jp   .checkEnd
	
.main:
	;--
	ld   a, [sMapTimer_Low]			; Does nothing
	and  a, $00						; but could be used to slow down movement
	ret  nz
	;--
	
	ld   a, $00						; .
	ld   d, a
	ld   a, [sMapStepsLeft]			
	cp   a, $00						; Are there any steps left in the direction?
	jr   z, .setNextDirection		; If not, jump
	
	; Pick the direction to move to
	ld   a, [sMapPathTestCtrl]
	cp   a, $00
	ret  z
	cp   a, $01
	jr   z, .scrollUp
	cp   a, $02
	jr   z, .scrollRight
	cp   a, $03
	jr   z, .scrollDown
	cp   a, $04
	jr   z, .scrollLeft
	ret  
.setNextDirection:
	; Index the amount of steps to move in the direction
	ld   hl, .stepsCountTbl
	ld   a, [sMapPathTestCtrl]
	ld   e, a
	add  hl, de
	; Set the steps counter
	ld   a, [hl]
	ld   [sMapStepsLeft], a
	
	; Next direction
	ld   a, [sMapPathTestCtrl]
	inc  a
	ld   [sMapPathTestCtrl], a
	
	; Reset the map timer if we're done moving (ctrl == $05)
	cp   a, $05
	ret  nz
	xor  a
	ld   [sMapTimer_Low], a
	ret  
	
; Subroutines to scroll the screen in a certain direction
; and decrement the step counter.
.incCoord:
	inc  [hl]
	ld   hl, sMapStepsLeft
	dec  [hl]
	ret  
.decCoord:
	ld   a, [hl]
	dec  a
	ld   [hl], a
	ld   hl, sMapStepsLeft
	dec  [hl]
	ret  
.scrollUp:
	ld   hl, sMapScrollY
	jr   .decCoord
.scrollRight:
	ld   hl, sMapScrollX
	jr   .incCoord
.scrollDown:
	ld   hl, sMapScrollY
	jr   .incCoord
.scrollLeft:
	ld   hl, sMapScrollX
	jr   .decCoord
	
; This table determines how many steps to move...
.stepsCountTbl:
	db $70 ; UP
	db $60 ; RIGHT
	db $70 ; DOWN
	db $60 ; LEFT
	ret 
	
; =============== Map_Unused_DrawWarioTest ===============
; [TCRF] Unreferenced code.
; This subroutine draws Wario on the bottom-left corner of the screen.
Map_Unused_DrawWarioTest:
	ld   a, $08
	ld   [sMapOAMWriteX], a
	ld   [sMapWarioX], a
	ld   a, $A8
	ld   [sMapOAMWriteY], a
	ld   [sMapWarioYRes], a
	ld   [sMapWarioY], a
	ld   a, MAP_MWA_UNUSED_V1
	ld   [sMapWarioAnimId], a
	call Map_WriteWarioOBJLst
	ret  
	
; =============== Map_Unused_CopyBytesUntilFF ===============
; [TCRF] Unreferenced byte copy routine.
; Copies bytes until until $FF is reached.
; IN
; - DE: Ptr to source
; - HL: Ptr to destination
Map_Unused_CopyBytesUntilFF:
.loop:
	ld   a, [de]
	cp   a, $FF
	ret  z
	ldi  [hl], a
	inc  de
	jr   .loop

; =============== Map_Mode_OverworldInit ===============
; Mode $20
Map_Mode_EndingFadeIn:
	call HomeCall_Map_Ending_DrawOBJ
	; Did we reach the end of the palette tables?
	ld   a, [sMapFadeTimer]
	cp   a, $05
	jr   z, .end
	
	; Wait $40 frames before changing the palette
	ld   a, [sMapTimer_Low]
	and  a, $3F
	ret  nz
	
	; Update palettes
	ld   hl, Map_FadeIn_BGPTable
	call Map_SetFadeBGP
	ld   hl, Map_EndingFadeIn_OBPTable
	call Map_SetFadeOBP
	ld   hl, sMapFadeTimer
	inc  [hl]
	ret
.end:
	xor  a
	ld   [sMapFadeTimer], a
	ld   a, $E1
	ldh  [rBGP], a
	ld   a, [sMapNextId]
	ld   [sMapId], a
	ld   a, $2F
	ld   [sBGMSet], a
	ret
	
Map_EndingFadeIn_OBPTable: 
	db $FC,$FC,$FC,$1C,$1C
	ret
	
; =============== Map_Mode_FadeIn ===============
; Mode $07
; Generic Fade In handler for map screens.
;
; This will fade in the screen, then switch to the specified map mode in MapNextMode.
Map_Mode_FadeIn:
	call Map_FadeIn_AnimTiles
	ld   a, [sMapFadeTimer]		; Did we reach the last table entry?
	cp   a, $05
	jr   z, Map_FadeIn_End
	ld   a, [sMapTimer_Low]		; Apply each palette for $10 frames
	and  a, $0F
	ret  nz
	ld   hl, Map_FadeIn_BGPTable
	call Map_SetFadeBGP
	ld   hl, sMapFadeTimer
	inc  [hl]
	ret
	
; =============== Map_SetFadeBGP ===============
; Sets the background palette from a palette table.
; The index for this table is MapCutsceneEndTimer.
;
; IN
; - HL: Ptr to table of palettes
Map_SetFadeBGP:;C
	xor  a
	ld   b, a
	ld   a, [sMapFadeTimer]
	ld   c, a
	add  hl, bc		; Palette = HL[sMapFadeTimer]
	ld   a, [hl]
	ldh  [rBGP], a
	ret
; =============== Map_FadeIn_End ===============
Map_FadeIn_End:
	xor  a							; Reset the fade timer
	ld   [sMapFadeTimer], a
	ld   a, $E1						; Just in case, set the normal BGP palette
	ldh  [rBGP], a
	ld   a, [sMapNextId]			; Switch to the requested mode.
	ld   [sMapId], a
	ld   a, $EC
	ld   [sMapTimer0], a
	ret
	
Map_FadeIn_BGPTable: 
	db $00,$40,$50,$A1,$E1
	ret
	
; =============== Map_FadeIn_AnimTiles ===============
; Performs tile animation during the fade-in.
Map_FadeIn_AnimTiles:
	ld   a, [sMapNextId]
	cp   a, MAP_MODE_OVERWORLD
	jr   z, .overworld
	cp   a, MAP_MODE_RICEBEACH
	jr   z, .riceBeach
	ret
.overworld:
	call Map_Overworld_AnimTiles
	ret
.riceBeach:
	call Map_RiceBeach_AnimTiles
	ret
	
; =============== Map_Mode_CutsceneFadeOut ===============
; Mode $15
; Does the fade out for the C12 clear cutscene.
; The same as a normal fade out, except:
;
; - The return value will be set after the fade out.
;   Because this is called from the game mode GM_LEVELCLEAR2 instead of GM_MAP, doing this
;   causes the player to transition to the Course Clear screen, and not the Course Intro.
; - Writes the mappings for Mt.Teapot's lid.
;   Curiously, this doesn't happen in the normal fade-out, where all sprites including the lid disappear.
Map_Mode_CutsceneFadeOut:
	call HomeCall_Map_NoMoveMtTeapotLid
	ld   a, $01
	ld   [sMapFadeOutRetVal], a
	
; =============== Map_Mode_FadeOut ===============
; Mode $08
; Sets the background *and object* palette from a palette table.
Map_Mode_FadeOut:
	; Did we reach the last table entry?
	ld   a, [sMapFadeTimer]		
	sub  a, $06					; > 6
	jr   nc, Map_FadeOut_End
	ld   a, [sMapFadeTimer]
	cp   a, $06					; == 6
	jr   z, Map_FadeOut_End
	;--
	ld   a, [sMapTimer_Low]
	and  a, $03
	ret  nz
	; Update the palettes
	ld   hl, Map_FadeOut_BGPTable
	call Map_SetFadeBGP
	ld   hl, Map_FadeOut_OBPTable
	call Map_SetFadeOBP
	ld   hl, sMapFadeTimer
	inc  [hl]
	ret
	
Map_FadeOut_OBPTable:
	db $FC,$08,$10,$40,$00,$00
	ret

; =============== Map_SetFadeOBP ===============
; Sets the object palette from a palette table.
;
; IN
; - HL: Ptr to table of palettes
Map_SetFadeOBP:;C
	xor  a
	ld   b, a
	ld   a, [sMapFadeTimer]
	ld   c, a
	add  hl, bc						; Palette = HL[sMapFadeTimer]
	ld   a, [hl]
	ldh  [rOBP0], a
	ret
	
Map_FadeOut_End:
	xor  a							; Reset the timer
	ld   [sMapFadeTimer], a
	ld   a, $00
	ldh  [rBGP], a					; Switch to next mode
	ld   a, [sMapNextId]
	ld   [sMapId], a
	
	; If we requested to switch to a different mode when the fadeout ends, do so
	ld   a, [sMapFadeOutRetVal]
	bit  0, a					; Requested?
	ret  z						; If not, return
	ld   hl, sMapRetVal			; Otherwise, signal out that we're done (ie: switch to Course Intro screen)
	inc  [hl]
	ld   a, [sMapFadeOutRetVal]
	and  a, $FE
	ld   [sMapFadeOutRetVal], a
	ret
Map_FadeOut_BGPTable:
	db $E1,$A1,$50,$40,$00,$00
	ret
	
; =============== Map_SetOpenPathArrows ===============
; Sets up the bitmask containing the currently visible arrows in the overworld.
Map_SetOpenPathArrows:
	ldh  a, [hJoyNewKeys]	; Are we requesting movement?
	and  a
	ret  nz					; If so, don't draw the arrows
.loop:
	; Process in order the four directional arrows.
	
	ld   a, [sMapCurArrow]	; Have we processed 4 arrows?
	cp   a, $04
	jr   z, .end			; If so, we're done
	
	; Go in order, R L U D
	ld   a, [sMapCurArrow]
	cp   a, $01
	jr   z, .left
	cp   a, $02
	jr   z, .up
	cp   a, $03
	jr   z, .down
.right:
	ld   a, KEY_RIGHT
.checkPath:
	; Prepare call for Map_ValidateNewPath
	;--
	ldh  [hJoyNewKeys], a				; Simulate keypress for this
	call Map_Overworld_GetPathDirPtr	; HL = Ptr to path information
	
	ld   a, [hl]			
	ld   b, a							; B = All valid paths
	
	ldh  a, [hJoyNewKeys]
	ld   [sMapPathDirSel], a 			; A = The direction we want to check
	
	call Map_ValidateNewPath
	;--
	; If the path is locked or missing, the result of this will be 0
	and  a, b
	
	; Add the result to the visibility bitmask
	ld   c, a
	ld   a, [sMapVisibleArrows]
	add  c
	ld   [sMapVisibleArrows], a
	; Process next arrow
	ld   a, [sMapCurArrow]
	inc  a
	ld   [sMapCurArrow], a
	jr   .loop
.left:
	ld   a, KEY_LEFT
	jr   .checkPath
.up:
	ld   a, KEY_UP
	jr   .checkPath
.down:
	ld   a, KEY_DOWN
	jr   .checkPath
.end:
	xor  a
	ldh  [hJoyNewKeys], a
	ld   [sMapPathDirSel], a
	ret
	
; =============== mMap_CopyOneGFX ===============
; Copies a single 2bpp tile to VRAM.
; IN:
; -  1: Start address of source 1bpp data
; - HL: Same as above
mMap_CopyOneGFX: MACRO
.loop:
	; Copy the gfx data over
	ldi  a, [hl]	
	ld   [bc], a
	inc  bc
	
	ld   a, c			
	cp   a, LOW(\1)+$10	; Have we copied all $10 bytes (1 tile) yet?
	jr   nz, .loop		; If not, loop
ENDM
	
; =============== Map_SSTeacup_ScreenEvent ===============
; Animates the water graphics in the SS Teacup map screen.
; This is a 2 frame "animation" (GFX are switched between 2 tiles), which happens every 16 frames.
Map_SSTeacup_ScreenEvent:
	; Update the animation frame every $10 frames
	ld   a, [sMapTimer_Low]
	and  a, $0F
	ret  nz
	; Copy the graphics over depending on the current animation frame
	ld   a, [sMapAnimFrame_Misc]
	and  a
	jr   nz, .frame1
.frame0:
	ld   hl, GFX_SSTeacupAnim0	; HL = Source 2bpp graphics
	ld   bc, vGFXMapSSTeacupAnim0	; BC = VRAM destination
	call Map_SSTeacup_CopyAnimGFX0
	ld   hl, GFX_SSTeacupAnim1
	ld   bc, vGFXMapSSTeacupAnim1
	jr   Map_SSTeacup_CopyAnimGFX1
.frame1:;R
	ld   hl, GFX_SSTeacupAnim1
	ld   bc, vGFXMapSSTeacupAnim0
	call Map_SSTeacup_CopyAnimGFX0
	ld   hl, GFX_SSTeacupAnim0
	ld   bc, vGFXMapSSTeacupAnim1
	jr   Map_SSTeacup_CopyAnimGFX1

; =============== Map_SSTeacup_CopyAnimGFX0 ===============
; Copies the 2bpp GFX data for the first animated tile in SS Teacup.
; IN:
; - HL: Source GFX
; - BC: Destination (always vGFXMapSSTeacupAnim0)
Map_SSTeacup_CopyAnimGFX0:
	mMap_CopyOneGFX vGFXMapSSTeacupAnim0
	ret
	
; =============== Map_SSTeacup_CopyAnimGFX1 ===============
; Functionally identical to the above.
Map_SSTeacup_CopyAnimGFX1:
	mMap_CopyOneGFX vGFXMapSSTeacupAnim1
	; Toggle the anim frame
	ld   a, [sMapAnimFrame_Misc]
	xor  $01
	ld   [sMapAnimFrame_Misc], a
	ret
GFX_SSTeacupAnim0: INCBIN "data/gfx/maps/ssteacup_anim.bin",00,16
GFX_SSTeacupAnim1: INCBIN "data/gfx/maps/ssteacup_anim.bin",16,16

; =============== Map_SSTeacup_CopyAnimGFX1 ===============
; Animates the lava graphics in the Stove Canyon map screen
; This is a 2 frame animation similar to the one for SS Teacup, except 4 tiles are animated.
Map_StoveCanyon_ScreenEvent:
	; Update the animation frame every $10 frames
	ld   a, [sMapTimer_Low]
	and  a, $0F
	ret  nz
	; Copy the graphics over depending on the current animation frame
	ld   a, [sMapAnimFrame_Misc]
	and  a
	jr   nz, .frame1
.frame0:
	ld   hl, GFX_StoveCanyonAnim1
	ld   bc, vGFXMapStoveCanyonAnim2
	call Map_StoveCanyon_CopyAnimGFX0
	ld   hl, GFX_StoveCanyonAnim3
	ld   bc, vGFXMapStoveCanyonAnim0
	call Map_StoveCanyon_CopyAnimGFX0
	ld   hl, GFX_StoveCanyonAnim2
	ld   bc, vGFXMapStoveCanyonAnim1
	call Map_StoveCanyon_CopyAnimGFX1
	ld   hl, GFX_StoveCanyonAnim0
	ld   bc, vGFXMapStoveCanyonAnim3
	jr   Map_StoveCanyon_CopyAnimGFX1_End
.frame1:
	ld   hl, GFX_StoveCanyonAnim0
	ld   bc, vGFXMapStoveCanyonAnim2
	call Map_StoveCanyon_CopyAnimGFX0
	ld   hl, GFX_StoveCanyonAnim2
	ld   bc, vGFXMapStoveCanyonAnim0
	call Map_StoveCanyon_CopyAnimGFX0
	ld   hl, GFX_StoveCanyonAnim3
	ld   bc, vGFXMapStoveCanyonAnim1
	call Map_StoveCanyon_CopyAnimGFX1
	ld   hl, GFX_StoveCanyonAnim1
	ld   bc, vGFXMapStoveCanyonAnim3
	jr   Map_StoveCanyon_CopyAnimGFX1_End
	
; =============== Map_StoveCanyon_CopyAnimGFX0 ===============
; Copies to VRAM the GFX data for the first column of animated tiles in Stove Canyon
; HL = Source GFX
; BC = Destination (must start on $**A0)
Map_StoveCanyon_CopyAnimGFX0:
	mMap_CopyOneGFX vGFXMapStoveCanyonAnim0
	ret
; =============== Map_StoveCanyon_CopyAnimGFX1_End ===============
; Identical to the below subroutine, except it updates the frame status.
Map_StoveCanyon_CopyAnimGFX1_End:
	mMap_CopyOneGFX vGFXMapStoveCanyonAnim1	
	; Toggle the anim frame
	ld   a, [sMapAnimFrame_Misc]
	xor  $01
	ld   [sMapAnimFrame_Misc], a
	ret
; =============== Map_StoveCanyon_CopyAnimGFX1 ===============
; Copies to VRAM the GFX data for the second column of animated tiles in Stove Canyon
Map_StoveCanyon_CopyAnimGFX1:
	mMap_CopyOneGFX vGFXMapStoveCanyonAnim1	
	ret

GFX_StoveCanyonAnim0: INCBIN "data/gfx/maps/stovecanyon_anim.bin",00,16
GFX_StoveCanyonAnim1: INCBIN "data/gfx/maps/stovecanyon_anim.bin",16,16
GFX_StoveCanyonAnim2: INCBIN "data/gfx/maps/stovecanyon_anim.bin",32,16
GFX_StoveCanyonAnim3: INCBIN "data/gfx/maps/stovecanyon_anim.bin",48,16

; =============== mMap_CopyOne1bppGFX ===============
; Wrapper to Map_Copy1bppGFX for copying and converting a single 1bpp tile to VRAM.
; IN:
; - 1: Start address of source 1bpp data
; - 2: VRAM Destination
mMap_CopyOne1bppGFX: MACRO
	ld   hl, \1			; HL = Ptr to 1bpp graphics
	ld   bc, \2			; BC = Ptr to VRAM gfx
	; NOTE: As each 2bpp tile takes $10 bytes, a 1bpp one logically takes $08
	ld   a, LOW(\1)+$08	; D = End the copy when L reaches this value
						; Destination+$08 ends up copying a single tile.
	ld   d, a
	call Map_Copy1bppGFX
	ret
ENDM

; =============== Map_RiceBeach_CopyMapAnimGFX? ===============
; Wrappers for MapCopyAnimTile used in Rice Beach.
; These copy a 1bpp tile GFX to VRAM, "converting" it to 2bpp.

;                                               SOURCE           DEST
Map_RiceBeach_CopyMapAnimGFX0:	mMap_CopyOne1bppGFX sMapAnimGFX0, vGFXMapRiceBeachAnim0
Map_RiceBeach_CopyMapAnimGFX1:	mMap_CopyOne1bppGFX sMapAnimGFX1, vGFXMapRiceBeachAnim1
Map_RiceBeach_CopyMapAnimGFX2:	mMap_CopyOne1bppGFX sMapAnimGFX2, vGFXMapRiceBeachAnim2
Map_RiceBeach_CopyMapAnimGFX3:	mMap_CopyOne1bppGFX sMapAnimGFX3, vGFXMapRiceBeachAnim3
Map_RiceBeach_CopyMapAnimGFX4:	mMap_CopyOne1bppGFX sMapAnimGFX4, vGFXMapRiceBeachAnim4
Map_RiceBeach_CopyMapAnimGFX5:	mMap_CopyOne1bppGFX sMapAnimGFX5, vGFXMapRiceBeachAnim5
Map_RiceBeach_CopyMapAnimGFX6:	mMap_CopyOne1bppGFX sMapAnimGFX6, vGFXMapRiceBeachAnim6
Map_RiceBeach_CopyMapAnimGFX7:	mMap_CopyOne1bppGFX sMapAnimGFX7, vGFXMapRiceBeachAnim7
Map_RiceBeach_CopyMapAnimGFX8:	mMap_CopyOne1bppGFX sMapAnimGFX8, vGFXMapRiceBeachAnim8
Map_RiceBeach_CopyMapAnimGFX9:	mMap_CopyOne1bppGFX sMapAnimGFX9, vGFXMapRiceBeachAnim9

; =============== Map_Unused_CopyLinkedTbl ===============
; [TCRF] Unknown unreferenced (GFX?) copy code.
; This subroutine copies $20 bytes of data from a table of bytes
; to the addresses specified in a linked table, similar to
; what's done for event data.
;
; However, everything is read from SRAM, in addresses used for different purposes.
Map_Unused_CopyLinkedTbl:
	; Only continue if the copy is enabled
	ld   a, [sMap_Unused_CopyLinkedTbl]
	and  a
	ret  z
	
	ld   hl, $A710	; HL = Offset source
	ld   bc, $A760	; BC = Byte source
.loop:
	ldi  a, [hl]	; DE = Destination ptr
	ld   d, a
	ldi  a, [hl]
	ld   e, a
	ld   a, [bc]	; A = Byte to write
	ld   [de], a	; Copy the byte to the address
	inc  bc
	;--
	ld   a, c
	cp   $80		; Have we reached $A780?
	jr   nz, .loop	; If not, copy the next tile.
	ret
	
; =============== Map_Copy1bppGFX ===============
; Copies 1bpp graphics to VRAM. 
; Generally set up to copy a single tile (so D = L + 8)
; IN:
; - HL: Start address of source 1bpp data
; - BC: VRAM Destination
; -  D: End copy when L reaches this value
Map_Copy1bppGFX:
.loop:
	ldi  a, [hl]	; Get the byte
	ld   [bc], a	; Copy it to VRAM
	inc  bc
	inc  bc			; Skip every other byte in VRAM as we're copying 1bpp gfx
	ld   a, l
	cp   a, d		; Is D == L?
	jr   nz, .loop	; If not, continue the copy
	ret
; =============== Map_Overworld_ScreenEvent ===============
; Animates the water gfx used in the overworld
;                                         SOURCE           DEST
Map_Overworld_ScreenEvent: mMap_CopyOne1bppGFX sMapAnimGFX0, vGFXMapOverworldAnim

; =============== Map_LoadPalette ===============
; Loads the standard palette used in the map screen.
Map_LoadPalette:
	call StopLCDOperation
	ld   a, $E1
	ldh  [rBGP], a
	ld   a, $1C
	ldh  [rOBP0], a
	ld   a, $E3
	ldh  [rOBP1], a
	ret
; =============== Map_ClearRAM ===============
; Clears memory ranges used by the map screen.
Map_ClearRAM:
	; Clear $A7D0-$A7FF
	ld   hl, $A7D0
	ld   b, $30
	xor  a
.loop:
	ldi  [hl], a
	dec  b
	jr   nz, .loop
	
	; Clear $B130-$B1EF
	ld   hl, $B130
	ld   b, $C0
	xor  a
.loop2:
	ldi  [hl], a
	dec  b
	jr   nz, .loop2
	ret
; =============== Map_InitMisc ===============
; Initializes miscellaneous registers for use in the map screen
Map_InitMisc:
	ld   a, $58			; Hide WINDOW off-screen
	ldh  [rWY], a
	ld   a, $88
	ldh  [rWX], a
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	ldh  [rLCDC], a
	ld   a, $07
	ld   [sMapWarioYOscillateMask], a
	ret
; =============== Animation defn ===============
OBJLstAnim_Map_WarioHide: 
	db $0E
	db $FF
OBJLstAnim_Map_WarioWaterBack: 
	db $0D
	db $FF
OBJLstAnim_Map_WarioWaterFront: 
	db $0C
	db $FF
OBJLstAnim_Unused_Map_WarioH1C: 
	db $00
	db $FF
OBJLstAnim_Unused_Map_WarioH2C: 
	db $01
	db $FF
OBJLstAnim_Unused_Map_WarioH3C: 
	db $02
	db $FF
OBJLstAnim_Unused_Map_WarioH2: 
	db $00
	db $FF
OBJLstAnim_Unused_Map_WarioH3: 
	db $01
	db $FF
OBJLstAnim_Unused_Map_WarioH1: 
	db $02
	db $FF
OBJLstAnim_Unused_Map_WarioV8:
	db $08
	db $FF
OBJLstAnim_Map_WarioLeft: 
	db $01
	db $02
	db $03
	db $FF
OBJLstAnim_Map_WarioRight: 
	db $01
	db $02
	db $03
	db $FF
OBJLstAnim_Map_WarioBack: 
	db $08
	db $09
	db $08
	db $0A
	db $FF
OBJLstAnim_Map_WarioFront: 
	db $04
	db $05
	db $04
	db $06
	db $FF
	
; =============== Map_WarioAnim ===============
; Handles Wario's animations in the map screen.
; This can update any part of Wario's OBJLst data.
;
; OUT
; - HL: Ptr to OBJLst Id
Map_WarioAnim:
	ld   a, [sMapWarioAnimId]
	rst  $28
	dw Map_WarioAnim_Front
	dw Map_WarioAnim_Right
	dw Map_WarioAnim_Left
	dw Map_WarioAnim_Back
	dw Map_WarioAnim_Front ; Duplicate of $00 for convenience, when $00 is handled as a special value
	; [TCRF] Unused placeholder animations made up of a single frame.
	; The number indicates which OBJLst ID uses.
	dw Map_Unused_WarioAnim_V8
	dw Map_Unused_WarioAnim_H3
	dw Map_Unused_WarioAnim_H1
	dw Map_Unused_WarioAnim_H2
	dw Map_Unused_WarioAnim_H1C
	dw Map_Unused_WarioAnim_H2C
	dw Map_Unused_WarioAnim_H3C
	dw Map_WarioAnim_WaterFront
	dw Map_WarioAnim_WaterBack
	dw Map_WarioAnim_Hide
	ret
Map_WarioAnim_Back:
	ld   a, $10
	ld   [sMapWarioFlags], a
	call Map_WarioOscillateYVert
	ld   hl, OBJLstAnim_Map_WarioBack
	call Map_WarioGetOBJLstId
	ret
Map_WarioAnim_Front:
	ld   a, $10
	ld   [sMapWarioFlags], a
	call Map_WarioOscillateYVert
	ld   hl, OBJLstAnim_Map_WarioFront
	call Map_WarioGetOBJLstId
	ret
Map_WarioAnim_Left:
	ld   a, $10
	ld   [sMapWarioFlags], a
	call Map_WarioOscillateYHorz
	ld   hl, OBJLstAnim_Map_WarioLeft
	call Map_WarioGetOBJLstId
	ret
Map_WarioAnim_Right:
	ld   a, $30
	ld   [sMapWarioFlags], a
	call Map_WarioOscillateYHorz
	ld   hl, OBJLstAnim_Map_WarioRight
	call Map_WarioGetOBJLstId
	ret
Map_Unused_WarioAnim_V8: 
	ld   a, $10
	ld   [sMapWarioFlags], a
	ld   hl, OBJLstAnim_Unused_Map_WarioV8
	call Map_WarioGetOBJLstId
	ret
Map_Unused_WarioAnim_H2: 	
	ld   a, $30
	ld   [sMapWarioFlags], a
	ld   hl, OBJLstAnim_Unused_Map_WarioH2
	call Map_WarioGetOBJLstId
	ret
Map_Unused_WarioAnim_H3: 
	ld   a, $30
	ld   [sMapWarioFlags], a
	ld   hl, OBJLstAnim_Unused_Map_WarioH3
	call Map_WarioGetOBJLstId
	ret
Map_Unused_WarioAnim_H1:
	ld   a, $30
	ld   [sMapWarioFlags], a
	ld   hl, OBJLstAnim_Unused_Map_WarioH1
	call Map_WarioGetOBJLstId
	ret
Map_Unused_WarioAnim_H1C: 
	ld   a, $10
	ld   [sMapWarioFlags], a
	ld   hl, OBJLstAnim_Unused_Map_WarioH1C
	call Map_WarioGetOBJLstId
	ret
Map_Unused_WarioAnim_H2C: 
	ld   a, $10
	ld   [sMapWarioFlags], a
	ld   hl, OBJLstAnim_Unused_Map_WarioH2C
	call Map_WarioGetOBJLstId
	ret
Map_Unused_WarioAnim_H3C: 
	ld   a, $10
	ld   [sMapWarioFlags], a
	ld   hl, OBJLstAnim_Unused_Map_WarioH3C
	call Map_WarioGetOBJLstId
	ret
Map_WarioAnim_WaterFront:
	ld   a, $10
	ld   [sMapWarioFlags], a
	ld   hl, OBJLstAnim_Map_WarioWaterFront
	call Map_WarioGetOBJLstId
	ret
Map_WarioAnim_WaterBack:
	ld   a, $10
	ld   [sMapWarioFlags], a
	ld   hl, OBJLstAnim_Map_WarioWaterBack
	call Map_WarioGetOBJLstId
	ret
Map_WarioAnim_Hide:
	ld   a, $10
	ld   [sMapWarioFlags], a
	ld   hl, OBJLstAnim_Map_WarioHide
	call Map_WarioGetOBJLstId
	ret
	
;
; HELPER SUBROUTINES FOR MAP WARIO ANIM
;

; =============== Map_WarioOscillateYVert ===============	
; Oscillate the visual Y position when standing or during vertical movement
Map_WarioOscillateYVert:

	; Use a bitmask to determine how often to perform the oscillation
	; This is set to 3 during walking, which speeds up the effect compared to the normal value of 7.
	ld   a, [sMapWarioYOscillateMask]
	ld   b, a
	ld   a, [sMapTimer_Low]				; Copy the timer value
	ld   [sMap_Unknown_TimerLowCopy], a
	and  a, b							; (MapTimer_Low & OscilMask) == 0 determines movement.
	ret  nz								; 
	
	ld   a, [sMapWarioAnimTimer]	 	; AnimTimer++
	inc  a
	
	; And perform the action as specified by the timer
	ld   [sMapWarioAnimTimer], a		
	cp   a, $04
	jr   z, .downReset
	cp   a, $05		; [TCRF] I can only assume this just in case the timer goes out of range.
	jr   z, .reset	;        Which never happens in-game.
	cp   a, $01
	jr   z, .up
	cp   a, $02
	jr   z, .down
	cp   a, $03
	jr   z, .up
	ret				; We never get here
	
; [TCRF] Downwards movement in .down and .downReset is a bit weird.
;        It starts similar to the upwards movement, where the virtual Wario position is decremented.
;		 ...which is all for nothing as the value gets replaced with the real Y position.
;        It has the same effect, but why is it done this way? Quick fix to a possible misalignment?
.down:
	; Move down by 1px...
	ld   hl, sMapWarioYRes	
	inc  [hl]
	
	ld   a, [sMapWarioY]	; ...only to reset it later with the real Y position!
	ld   [hl], a			; 
	ret
.up:
	; Move up by 1px
	ld   hl, sMapWarioYRes	
	dec  [hl]
	ld   a, [hl]
	ret
.downReset:
	ld   hl, sMapWarioYRes	; see .down
	inc  [hl]
	ld   a, [sMapWarioY]
	ld   [hl], a
.reset
	xor  a
	ld   [sMapWarioAnimTimer], a
	ret

; =============== Map_WarioOscillateYHorz ===============	
; Oscillate the visual Y position during horizontal movement
Map_WarioOscillateYHorz:
	; Handle the bitmask speed exactly like in Map_WarioOscillateYVert
	; However, the mask is always 3 when moving, causing faster speed.
	ld   a, [sMapWarioYOscillateMask]
	ld   b, a
	ld   a, [sMapTimer_Low]
	ld   [sMap_Unknown_TimerLowCopy], a
	and  a, b
	ret  nz
	
	ld   a, [sMapWarioAnimTimer]	; Timer++
	inc  a
	
	; And perform the action as specified by the timer
	ld   [sMapWarioAnimTimer], a
	
	cp   a, $03			
	jr   z, .reset
	cp   a, $04			; Copy/paste effect?
	jr   z, .reset
	cp   a, $05
	jr   z, .reset
	
	cp   a, $01
	jr   z, .up
	cp   a, $02
	jr   z, .down
	ret 				; We never get here
.up:
	; Move up
	ld   hl, sMapWarioYRes
	dec  [hl]
	ret
.down:
	; Move down by copying back the old value
	ld   hl, sMapWarioYRes
	ld   a, [sMapWarioY]
	ld   [hl], a
	ret
.reset:
	xor  a
	ld   [sMapWarioAnimTimer], a
	ret
	
; =============== Map_WarioGetOBJLstId ===============
; This subroutines searches through a table of sprite mapping IDs (OBJLstAnim)
; to find the correct one to use based off the anim timer.
;
; It also performs out of bounds checks.
;
; IN
; - HL = Ptr to OBJLstAnim
;
; OUT
; - HL = Ptr to correct entry at the OBJLstAnim
Map_WarioGetOBJLstId:
	; basically HL += MIN(sMapWarioAnimTimer, <table length> - 1)
	ld   a, [sMapWarioAnimTimer]	; Use the anim timer to determine the frame ID to use
	ld   b, a						; B = Indexes left
	cp   a, $00						; Is it $00 already?
	jr   z, .found					; If so, we're already on it.
.loop:
	inc  hl							; Ptr++
	ld   a, [hl]
	cp   a, $FF						; Have we reached table end separator?
	jr   z, .notFound				; If so, jump
	dec  b							; Left--;
	ld   a, b						
	cp   a, $00						; Have we reached the target index yet?
	jr   nz, .loop					; If not, loop
.found:
	ret
.notFound:
	; We didn't find an entry in the valid range
	; Use the last valid ID as a fallback.
	dec  hl
	ret
	
; =============== Map_SubmapSetStartPos ===============
; Sets the initial coordinates for Wario's position, both when
; - entering a submap through the overworld (uses hardcoded values)
; - appearing in a submap after exiting a level or selecting a save file (uses a table indexed by level ID)
;
; This is the submap equivalent to Map_OverworldSetStartPos, except
; as submaps don't scroll the screen, we only need to take care of Wario's position.
Map_SubmapSetStartPos:
	ld   a, [sMapSubmapEnter]	; Was the submap entered through the overworld?
	and  a
	jr   nz, .fromSubmapEnter	; If so, use specific starting positions (off screen, hardcoded and not pointing to any level)
	
	; [TCRF] Much like Map_OverworldSetStartPos, this supports the never-enabled alternate address.
	;        This time it takes the place of sLevelId. 
	ld   a, [sMap_Unused_UseLevelIdAlt]
	and  a
	jr   nz, .unused_useAltLevelId
	
	ld   a, [sMapLevelId]				; A = LevelId
.setPos:
	; Index the table by level id to get the player coords
	ld   hl, Map_Submap_PosPtrTable				
	call B8_IndexPtrTable
	; Set the coords
	ldi  a, [hl]
	ld   [sMapOAMWriteY], a
	ld   [sMapWarioY], a
	ld   [sMapWarioYRes], a
	ld   a, [hl]
	ld   [sMapOAMWriteX], a
	ld   [sMapWarioX], a
	ret
.unused_useAltLevelId: 
	ld  a, [sMap_Unused_LevelIdAlt]		; A = LevelId
	jr  .setPos
.fromSubmapEnter:
	; We have entered a submap
	; Choose the initial (off screen) coordinates based on the current map mode
	ld   a, [sMapId]
	cp   a, MAP_MODE_INITRICEBEACH
	jr   z, .riceBeach
	cp   a, MAP_MODE_INITMTTEAPOT
	jr   z, .mtTeapot
	cp   a, MAP_MODE_INITSTOVECANYON
	jr   z, .stoveCanyon
	cp   a, MAP_MODE_INITSYRUPCASTLE
	jr   z, .syrupCastle
	cp   a, MAP_MODE_INITPARSLEYWOODS
	jr   z, .parsleyWoods
	cp   a, MAP_MODE_INITSSTEACUP
	jr   z, .ssTeacup
	cp   a, MAP_MODE_INITSHERBETLAND
	jr   z, .sherbetLand
	ret 								; We never get here
	
; =============== mSetSubmapEntry ===============
; Defines the initial coordinates for a submap
;
; IN
; - 1: Y coordinate
; - 2: X coordinate
mSetSubmapEntry: MACRO
	mSetSubmapEntr2 \1, \2
	jr   .setEnterPos
ENDM
mSetSubmapEntr2: MACRO
	ld   a, \1
	ld   b, \2
ENDM

;                                Y    X
.sherbetLand:  mSetSubmapEntry $2C, $9C
.ssTeacup:     mSetSubmapEntry $2C, $36
.parsleyWoods: mSetSubmapEntry $98, $34
.syrupCastle:  mSetSubmapEntry $A0, $6C
.stoveCanyon:  mSetSubmapEntry $18, $2C
.mtTeapot:
	; There are multiple ways to enter Mt.Teapot
	; Determine if we're entering from Sherbet Land (through the bridge)
	ld   a, [sMapWorldId]
	cp   a, MAP_OWP_BRIDGE
	jr   z, .bridge
.mtTeapotMain: mSetSubmapEntry $A4, $54 ; Normal entry (up; to C07)
.bridge:       mSetSubmapEntry $8C, $18 ; Bridge entry (right; to C08)
.riceBeach:    mSetSubmapEntr2 $9C, $64

.setEnterPos:
	; Set the starting coordinates directly
	ld   [sMapOAMWriteY], a
	ld   [sMapWarioY], a
	ld   [sMapWarioYRes], a
	ld   a, b
	ld   [sMapOAMWriteX], a
	ld   [sMapWarioX], a
	ret
	
; =============== Map_Submap_PosPtrTable ===============
; This subroutine defines the starting positions by level ID.
;
; Each entry points to a set of coordinates, which define Wario's location in the screen.
; Wario will be snapped here when not moving in a path, which can be:
; - When Wario stops moving
; - When the map is first loaded after selecting a save
;
; The bytes for each entry are in order
; - Wario Y pos
; - Wario X pos
Map_Submap_PosPtrTable: 
	dw Map_C26Pos
	dw Map_C33Pos
	dw Map_C15Pos
	dw Map_C20Pos
	dw Map_C16Pos
	dw Map_C10Pos
	dw Map_C07Pos
	dw Map_C01APos
	dw Map_C17Pos
	dw Map_C12Pos
	dw Map_C13Pos
	dw Map_C29Pos
	dw Map_C04Pos
	dw Map_C09Pos
	dw Map_C03APos
	dw Map_C02Pos
	dw Map_C08Pos
	dw Map_C11Pos
	dw Map_C35Pos
	dw Map_C34Pos
	dw Map_C30Pos
	dw Map_C21Pos
	dw Map_C22Pos
	dw Map_C01BPos
	dw Map_C19Pos
	dw Map_C05Pos
	dw Map_C36Pos
	dw Map_C24Pos
	dw Map_C25Pos
	dw Map_C32Pos
	dw Map_C27Pos
	dw Map_C28Pos
	dw Map_C18Pos
	dw Map_C14Pos
	dw Map_C38Pos
	dw Map_C39Pos
	dw Map_C03BPos
	dw Map_C37Pos
	dw Map_C31APos
	dw Map_C23Pos
	dw Map_C40Pos
	dw Map_C06Pos
	dw Map_C31BPos
	dw Map_CDummyPos ; Placeholder block
	dw Map_CDummyPos
	dw Map_CDummyPos
	dw Map_CDummyPos
	dw Map_C12SpecialPos ; For the automatic path from C12 to C13
	ret
;                      WY   WX
Map_C26Pos:        db $2C, $3C
Map_C33Pos:        db $7C, $94
Map_C15Pos:        db $3C, $54
Map_C20Pos:        db $24, $2C
Map_C16Pos:        db $6C, $54
Map_C10Pos:        db $24, $54
Map_C07Pos:        db $8C, $54
Map_C01APos:       db $8C, $64
Map_C17Pos:        db $54, $3C
Map_C12Pos:        db $5C, $74
Map_C13Pos:        db $24, $54
Map_C29Pos:        db $74, $64
Map_C04Pos:        db $44, $2C
Map_C09Pos:        db $54, $3C
Map_C03APos:       db $64, $4C
Map_C02Pos:        db $64, $7C
Map_C08Pos:        db $8C, $3C
Map_C11Pos:        db $4C, $64
Map_C35Pos:        db $5C, $34
Map_C34Pos:        db $5C, $94
Map_C30Pos:        db $84, $8E
Map_C21Pos:        db $54, $2C
Map_C22Pos:        db $54, $74
Map_C01BPos:       db $8C, $64
Map_C19Pos:        db $6C, $3C
Map_C05Pos:        db $32, $54
Map_C36Pos:        db $28, $54
Map_C24Pos:        db $84, $24
Map_C25Pos:        db $64, $9E
Map_C32Pos:        db $7C, $54
Map_C27Pos:        db $4C, $3C
Map_C28Pos:        db $74, $3C
Map_C18Pos:        db $6C, $84
Map_C14Pos:        db $2C, $8C
Map_C38Pos:        db $74, $5C
Map_C39Pos:        db $5C, $5C
Map_C03BPos:       db $64, $4C
Map_C37Pos:        db $8C, $6C
Map_C31APos:       db $84, $34
Map_C23Pos:        db $84, $74
Map_C40Pos:        db $4A, $5C
Map_C06Pos:        db $44, $64
Map_C31BPos:       db $84, $34
Map_CDummyPos:     db $56, $56 ; [TCRF] Not used
Map_C12SpecialPos: db $5C, $74
	ret

; =============== PathDirPtrTable_Levels ===============
; Defines pointers to path information for every level.
; See PathDirPtrTable_Overworld for more info.
PathDirPtrTable_Levels:
	dw PathDir_C26
	dw PathDir_C33
	dw PathDir_C15
	dw PathDir_C20
	dw PathDir_C16
	dw PathDir_C10
	dw PathDir_C07
	dw PathDir_C01A
	dw PathDir_C17
	dw PathDir_C12
	dw PathDir_C10 ; C13 reuses C10 data
	dw PathDir_C29
	dw PathDir_C04
	dw PathDir_C09
	dw PathDir_C03A
	dw PathDir_C02
	dw PathDir_C08
	dw PathDir_C11
	dw PathDir_C35
	dw PathDir_C34
	dw PathDir_C30
	dw PathDir_C21
	dw PathDir_C22
	dw PathDir_C01B ; Curiously C01B does not reuse data
	dw PathDir_C19
	dw PathDir_C05
	dw PathDir_C36
	dw PathDir_C24
	dw PathDir_C25
	dw PathDir_C32
	dw PathDir_C27
	dw PathDir_C28
	dw PathDir_C18
	dw PathDir_C14
	dw PathDir_C38
	dw PathDir_C39
	dw PathDir_C03B ; Neither does C03B
	dw PathDir_C37
	dw PathDir_C31 ; C31A
	dw PathDir_C23
	dw PathDir_C40
	dw PathDir_C06
	dw PathDir_C31 ; C31B
	dw PathDir_CDummy ; Placeholder entries
	dw PathDir_CDummy
	dw PathDir_CDummy
	dw PathDir_CDummy
	dw PathDir_C12Special
	
;                KEY   R   L   U   D
PathDir_C01A: db $90,$00,$FF,$FF,$0A
PathDir_C02:  db $A0,$FF,$02,$FF,$01
PathDir_C03A: db $70,$03,$06,$04,$FF
PathDir_C04:  db $C0,$FF,$FF,$08,$07
PathDir_C05:  db $A0,$FF,$09,$FF,$09
PathDir_C01B: db $90,$00,$FF,$FF,$0A
PathDir_C03B: db $70,$03,$06,$04,$FF
PathDir_C06:  db $80,$FF,$FF,$FF,$05
PathDir_C07:  db $A0,$FF,$0B,$FF,$15
PathDir_C08:  db $70,$0C,$16,$0D,$FF
PathDir_C09:  db $C0,$FF,$FF,$0F,$0E
PathDir_C10:  db $30,$11,$10,$FF,$FF
PathDir_C11:  db $C0,$FF,$FF,$12,$13
PathDir_C12:  db $20,$FF,$14,$FF,$FF
PathDir_C20:  db $C0,$FF,$FF,$22,$19
PathDir_C21:  db $50,$1B,$FF,$18,$FF
PathDir_C22:  db $A0,$FF,$1A,$FF,$1D
PathDir_C23:  db $70,$1E,$20,$1C,$FF
PathDir_C24:  db $10,$21,$FF,$FF,$FF
PathDir_C25:  db $20,$FF,$1F,$FF,$FF
PathDir_C26:  db $A0,$FF,$2D,$FF,$26
PathDir_C27:  db $C0,$FF,$FF,$25,$28
PathDir_C28:  db $50,$2A,$FF,$27,$FF
PathDir_C29:  db $30,$2C,$29,$FF,$FF
PathDir_C30:  db $20,$FF,$2B,$FF,$FF
PathDir_C31:  db $90,$3F,$FF,$FF,$49
PathDir_C32:  db $30,$41,$40,$FF,$FF
PathDir_C33:  db $60,$FF,$42,$43,$FF
PathDir_C34:  db $A0,$FF,$45,$FF,$44
PathDir_C35:  db $50,$46,$FF,$47,$FF
PathDir_C36:  db $80,$FF,$FF,$FF,$48
PathDir_C14:  db $30,$3C,$31,$FF,$FF
PathDir_C15:  db $E0,$FF,$37,$30,$33
PathDir_C16:  db $70,$3A,$35,$32,$FF
PathDir_C17:  db $C0,$FF,$FF,$36,$39
PathDir_C19:  db $50,$34,$FF,$38,$FF
PathDir_C18:  db $20,$FF,$3B,$FF,$FF
PathDir_C37:  db $A0,$FF,$4C,$FF,$52
PathDir_C38:  db $C0,$FF,$FF,$4E,$4D
PathDir_C39:  db $C0,$FF,$FF,$50,$4F
PathDir_C40:  db $80,$FF,$FF,$FF,$51
PathDir_C12Special: db $20,$FF,$53,$FF,$FF
PathDir_CDummy:     db $00,$FF,$FF,$FF,$FF

; =============== PathPtrTable_Levels ===============
; Table of ptrs to path definitions, indexed by path ID.
; See PathPtrTable_Overworld for more info.
PathPtrTable_Levels:

	; Rice Beach
	dw Path_C01Right
	dw Path_C02Down
	dw Path_C02Left
	dw Path_C03Right
	dw Path_C03Up
	dw Path_C06Down
	dw Path_C03Left
	dw Path_C04Down
	dw Path_C04Up
	dw Path_C05Down
	dw Path_C01Down
	
	; Mt. Teapot
	dw Path_C07Left
	dw Path_C08Right
	dw Path_C08Up
	dw Path_C09Down
	dw Path_C09Up
	dw Path_C10Left
	dw Path_C10Right
	dw Path_C11Up
	dw Path_C11Down
	dw Path_C12Left
	dw Path_C07Down
	dw Path_C08Left
	dw Path_CDummy_17  ; [TCRF] One of the dummy paths filling up unused slots. All dummy paths have a single segment of length $00.
	
	; Stove Canyon
	dw Path_C21Up
	dw Path_C20Down
	dw Path_C22Left
	dw Path_C21Right
	dw Path_C23Up
	dw Path_C22Down
	dw Path_C23Right
	dw Path_C25Left
	dw Path_C23Left
	dw Path_C24Right
	dw Path_C20Up
	dw Path_Dummy_23
	dw Path_Dummy_23
	
	; SS Teacup
	dw Path_C27Up
	dw Path_C26Down
	dw Path_C28Up
	dw Path_C27Down
	dw Path_C29Left
	dw Path_C28Right
	dw Path_C30Left
	dw Path_C29Right
	dw Path_C26Left
	dw Path_Dummy_2E
	dw Path_Dummy_2E
	
	; Sherbet Land
	dw Path_C15Up
	dw Path_C14Left
	dw Path_C16Up
	dw Path_C15Down
	dw Path_C19Right
	dw Path_C16Left
	dw Path_C17Up
	dw Path_C15Left
	dw Path_C19Up
	dw Path_C17Down
	dw Path_C16Right
	dw Path_C18Left
	dw Path_C14Right
	dw Path_Dummy_3D
	dw Path_Dummy_3D
	
	; Parsley Woods
	dw Path_C31Right
	dw Path_C32Left
	dw Path_C32Right
	dw Path_C33Left
	dw Path_C33Up
	dw Path_C34Down
	dw Path_C34Left
	dw Path_C35Right
	dw Path_C35Up
	dw Path_C36Down
	dw Path_C31Down
	dw Path_Dummy_4A
	dw Path_Dummy_4A
	
	; Syrup Castle
	dw Path_C37Left
	dw Path_C38Down
	dw Path_C38Up
	dw Path_C39Down
	dw Path_C39Up
	dw Path_C40Down
	dw Path_C37Down
	dw Path_C12SpecialLeft

Path_C01Right:
	db $F0,$18,$01
	db $E0,$28,$03
	db $FF,$0F
Path_C02Down:
	db $EE,$28,$04
	db $FE,$18,$02
	db $FF,$07
Path_C02Left:
	db $FE,$30,$02
	db $FF,$0E
Path_C03Right:
	db $F0,$30,$01
	db $FF,$0F
Path_C03Up:
	db $E0,$10,$03
	db $F0,$18,$01
	db $E0,$10,$03
	db $FF,$29
Path_C06Down:
	db $EE,$10,$04
	db $FE,$18,$02
	db $EE,$10,$04
	db $FF,$0E
Path_C03Left:
	db $FE,$20,$02
	db $E0,$20,$03
	db $FF,$0C
Path_C04Down:
	db $EE,$20,$04
	db $F0,$20,$01
	db $FF,$0E
Path_C04Up:
	db $E0,$04,$03
	db $E0,$18,$0E
	db $F0,$10,$0E
	db $EE,$08,$0E
	db $EE,$08,$04
	db $F0,$18,$01
	db $E0,$06,$03
	db $FF,$19
Path_C05Down:
	db $EE,$06,$04
	db $FE,$18,$02
	db $E0,$08,$03
	db $E0,$08,$0E
	db $FE,$10,$0E
	db $EE,$18,$0E
	db $EE,$04,$04
	db $FF,$0C
Path_C01Down:
	db $EE,$30,$04
	db $FF,$FD
Path_C07Left:
	db $FE,$18,$02
	db $FF,$10
Path_C08Right:
	db $F0,$18,$01
	db $FF,$06
Path_C08Up:
	db $E0,$38,$03
	db $FF,$0D
Path_C09Down:
	db $EE,$38,$04
	db $FF,$10
Path_C09Up:
	db $E0,$30,$03
	db $F0,$18,$01
	db $FF,$05
Path_C10Left:
	db $FE,$18,$02
	db $EE,$30,$04
	db $FF,$0D
Path_C10Right:
	db $F0,$10,$01
	db $EE,$28,$04
	db $FF,$11
Path_C11Up:
	db $E0,$28,$03
	db $FE,$10,$02
	db $FF,$05
Path_C11Down:
	db $EE,$10,$04
	db $F0,$10,$01
	db $FF,$09
Path_C12Left:
	db $FE,$10,$02
	db $E0,$10,$03
	db $FF,$11
Path_C07Down:
	db $EE,$30,$04
	db $FF,$FD
Path_C08Left:
	db $FE,$30,$02
	db $FF,$FA
Path_CDummy_17:
	db $F0,$00,$00
	db $FF,$06
Path_C21Up:
	db $E0,$30,$03
	db $FF,$03
Path_C20Down:
	db $EE,$30,$04
	db $FF,$15
Path_C22Left:
	db $FE,$48,$02
	db $FF,$15
Path_C21Right:
	db $F0,$48,$01
	db $FF,$16
Path_C23Up:
	db $E0,$30,$03
	db $FF,$16
Path_C22Down:
	db $EE,$30,$04
	db $FF,$27
Path_C23Right:
	db $F0,$1A,$01
	db $E0,$20,$03
	db $F0,$10,$01
	db $FF,$1C
Path_C25Left:
	db $FE,$10,$02
	db $EE,$20,$04
	db $FE,$1A,$02
	db $FF,$27
Path_C23Left:
	db $FE,$1C,$02
	db $FE,$18,$0E
	db $FE,$1C,$02
	db $FF,$1B
Path_C24Right:
	db $F0,$1C,$01
	db $F0,$18,$0E
	db $F0,$1C,$01
	db $FF,$27
Path_C20Up:
	db $E0,$30,$03
	db $FF,$FD
Path_Dummy_23:
	db $F0,$00,$00
	db $FF,$00
Path_C27Up:
	db $E0,$20,$03
	db $FF,$00
Path_C26Down:
	db $EE,$20,$04
	db $FF,$1E
Path_C28Up:
	db $E0,$28,$03
	db $FF,$1E
Path_C27Down:
	db $EE,$28,$04
	db $FF,$1F
Path_C29Left:
	db $FE,$28,$02
	db $FF,$1F
Path_C28Right:
	db $F0,$28,$01
	db $FF,$0B
Path_C30Left:
	db $FE,$1A,$02
	db $E0,$10,$03
	db $FE,$10,$02
	db $FF,$0B
Path_C29Right:
	db $F0,$10,$01
	db $EE,$10,$04
	db $F0,$1A,$01
	db $FF,$14
Path_C26Left:
	db $FE,$08,$02
	db $FE,$20,$0E
	db $FF,$FD
Path_Dummy_2E:
	db $F0,$00,$00
	db $FF,$1B
Path_C15Up:
	db $E0,$10,$03
	db $F0,$38,$01
	db $FF,$21
Path_C14Left:
	db $FE,$38,$02
	db $EE,$10,$04
	db $FF,$02
Path_C16Up:
	db $E0,$10,$03
	db $E0,$18,$0E
	db $E0,$08,$03
	db $FF,$02
Path_C15Down:
	db $EE,$08,$04
	db $EE,$18,$0E
	db $EE,$10,$04
	db $FF,$04
Path_C19Right:
	db $F0,$18,$01
	db $FF,$04
Path_C16Left:
	db $FE,$18,$02
	db $FF,$18
Path_C17Up:
	db $E0,$02,$03
	db $E0,$12,$0E
	db $E0,$04,$03
	db $F0,$18,$01
	db $FF,$02
Path_C15Left:
	db $FE,$18,$02
	db $EE,$04,$04
	db $EE,$12,$0E
	db $EE,$02,$04
	db $FF,$08
Path_C19Up:
	db $E0,$18,$03
	db $FF,$08
Path_C17Down:
	db $EE,$18,$04
	db $FF,$18
Path_C16Right:
	db $F0,$30,$01
	db $FF,$20
Path_C18Left:
	db $FE,$30,$02
	db $FF,$04
Path_C14Right:
	db $F0,$30,$01
	db $FF,$F9
Path_Dummy_3D:
	db $F0,$00,$00
	db $FF,$1A
Path_C31Right:
	db $F0,$10,$01
	db $E0,$08,$03
	db $F0,$10,$01
	db $FF,$1D
Path_C32Left:
	db $FE,$10,$02
	db $EE,$08,$04
	db $FE,$10,$02
	db $FF,$26
Path_C32Right:
	db $F0,$40,$01
	db $FF,$01
Path_C33Left:
	db $FE,$40,$02
	db $FF,$1D
Path_C33Up:
	db $E0,$20,$03
	db $FF,$13
Path_C34Down:
	db $EE,$20,$04
	db $FF,$01
Path_C34Left:
	db $FE,$04,$02
	db $FE,$20,$0E
	db $FE,$3C,$02
	db $FF,$12
Path_C35Right:
	db $F0,$3C,$01
	db $F0,$20,$0E
	db $F0,$04,$01
	db $FF,$13
Path_C35Up:
	db $E0,$28,$03
	db $F0,$20,$01
	db $E0,$0C,$03
	db $FF,$1A
Path_C36Down:
	db $EE,$0C,$04
	db $FE,$20,$02
	db $EE,$28,$04
	db $FF,$12
Path_C31Down:
	db $EE,$08,$04
	db $EE,$08,$0C
	db $EE,$18,$0E
	db $FF,$FD
Path_Dummy_4A:
	db $F0,$00,$00
	db $FF,$14
Path_C37Left:
	db $FE,$10,$02
	db $E0,$18,$03
	db $FF,$22
Path_C38Down:
	db $EE,$18,$04
	db $F0,$10,$01
	db $FF,$25
Path_C38Up:
	db $E0,$18,$03
	db $FF,$23
Path_C39Down:
	db $EE,$18,$04
	db $FF,$22
Path_C39Up:
	db $E0,$12,$03
	db $FF,$28
Path_C40Down:
	db $EE,$12,$04
	db $FF,$23
Path_C37Down:
	db $EE,$30,$04
	db $FF,$FD
Path_C12SpecialLeft:
	db $FE,$10,$02
	db $E0,$10,$03
	db $E0,$28,$03
	db $FE,$10,$02
	db $FF,$0A
	
; =============== Map_RiceBeach_AnimTiles ===============
; Performs the initial part of Rice Beach tile animation.
; This will copy the needed 1bpp GFX from ROM to SRAM.
; During VBlank, this copy in SRAM will then be copied over to VRAM.
;
; This whole process is very close to what's done for the overworld, down to the GFX data format.
Map_RiceBeach_AnimTiles:
	; Update the anim every 16 frames
	ld   a, [sMapTimer_Low]
	and  a, $0F
	ret  nz
	
	; Copy a single anim frame for all tiles, based off the timer value
	call Map_RiceBeach_CopyAnimGFX0
	call Map_RiceBeach_CopyAnimGFX1
	call Map_RiceBeach_CopyAnimGFX2
	call Map_RiceBeach_CopyAnimGFX3
	call Map_RiceBeach_CopyAnimGFX4
	call Map_RiceBeach_CopyAnimGFX5
	call Map_RiceBeach_CopyAnimGFX6
	call Map_RiceBeach_CopyAnimGFX7
	call Map_RiceBeach_CopyAnimGFX8
	call Map_RiceBeach_CopyAnimGFX9
	
	; Once we're done, update the tile anim timer
	ld   hl, sMapAnimFrame
	inc  [hl]
	
	ld   a, [hl]	; Have we gone past thee last valid frame?
	cp   a, $06
	ret  nz			; If not, return
	
	xor  a			; Otherwise, reset the timer
	ld   [hl], a
	ret
	
Map_RiceBeach_CopyAnimGFX0:
	ld   hl, GFX_Map_RiceBeach_Anim0
	ld   bc, sMapAnimGFX0
	call Map_RiceBeach_CopyAnimGFX
	ret
Map_RiceBeach_CopyAnimGFX1:
	ld   hl, GFX_Map_RiceBeach_Anim1
	ld   bc, sMapAnimGFX1
	call Map_RiceBeach_CopyAnimGFX
	ret
Map_RiceBeach_CopyAnimGFX2:
	ld   hl, GFX_Map_RiceBeach_Anim2
	ld   bc, sMapAnimGFX2
	call Map_RiceBeach_CopyAnimGFX
	ret
Map_RiceBeach_CopyAnimGFX3:
	ld   hl, GFX_Map_RiceBeach_Anim3
	ld   bc, sMapAnimGFX3
	call Map_RiceBeach_CopyAnimGFX
	ret
Map_RiceBeach_CopyAnimGFX4:
	ld   hl, GFX_Map_RiceBeach_Anim4
	ld   bc, sMapAnimGFX4
	call Map_RiceBeach_CopyAnimGFX
	ret
Map_RiceBeach_CopyAnimGFX5:
	ld   hl, GFX_Map_RiceBeach_Anim5
	ld   bc, sMapAnimGFX5
	call Map_RiceBeach_CopyAnimGFX
	ret
Map_RiceBeach_CopyAnimGFX6:
	ld   hl, GFX_Map_RiceBeach_Anim6
	ld   bc, sMapAnimGFX6
	call Map_RiceBeach_CopyAnimGFX
	ret
Map_RiceBeach_CopyAnimGFX7:
	ld   hl, GFX_Map_RiceBeach_Anim7
	ld   bc, sMapAnimGFX7
	call Map_RiceBeach_CopyAnimGFX
	ret
Map_RiceBeach_CopyAnimGFX8:
	ld   hl, GFX_Map_RiceBeach_Anim8
	ld   bc, sMapAnimGFX8
	call Map_RiceBeach_CopyAnimGFX
	ret
Map_RiceBeach_CopyAnimGFX9:
	ld   hl, GFX_Map_RiceBeach_Anim9
	ld   bc, sMapAnimGFX9
	call Map_RiceBeach_CopyAnimGFX
	ret
	
; =============== Map_RiceBeach_CopyAnimGFX ===============
; Copies the animated 1bpp tile graphics from ROM to SRAM.
;
; Identical to Map_Overworld_CopyAnimGFX, except there are 6 frames.
;
; IN
; - HL: Ptr to 1bpp graphics table
; - BC: Destination in SRAM
Map_RiceBeach_CopyAnimGFX:
	xor  a					; DE = Frame number
	ld   d, a
	ld   a, [sMapAnimFrame]
	ld   e, a
	add  hl, de				; Index the first byte of the frame
	
	ld   de, $0808			; D = Bytes to copy 
.loop:
	ld   a, [hl]			; Copy 1 byte over
	ld   [bc], a
	inc  hl					; HL += 6 to skip data for other tiles
	inc  hl
	inc  hl
	inc  hl
	inc  hl
	inc  hl
	inc  bc
	ld   a, d				; BytesLeft--;
	dec  a
	cp   a, $00				; Have we copied all bytes?
	ret  z					; If so, return
	ld   d, a
	jr   .loop
	
GFX_Map_RiceBeach_Anim0: 
	mIncludeMultiInt6 "data/gfx/maps/ricebeach_anim0.bin"
	ret
GFX_Map_RiceBeach_Anim1: 
	mIncludeMultiInt6 "data/gfx/maps/ricebeach_anim1.bin"
	ret
GFX_Map_RiceBeach_Anim2: 
	mIncludeMultiInt6 "data/gfx/maps/ricebeach_anim2.bin"
	ret
GFX_Map_RiceBeach_Anim3: 
	mIncludeMultiInt6 "data/gfx/maps/ricebeach_anim3.bin"
	ret
GFX_Map_RiceBeach_Anim4: 
	mIncludeMultiInt6 "data/gfx/maps/ricebeach_anim4.bin"
	ret
GFX_Map_RiceBeach_Anim5: 
	mIncludeMultiInt6 "data/gfx/maps/ricebeach_anim5.bin"
	ret
GFX_Map_RiceBeach_Anim6: 
	mIncludeMultiInt6 "data/gfx/maps/ricebeach_anim6.bin"
	ret
GFX_Map_RiceBeach_Anim7: 
	mIncludeMultiInt6 "data/gfx/maps/ricebeach_anim7.bin"
	ret
GFX_Map_RiceBeach_Anim8:
	mIncludeMultiInt6 "data/gfx/maps/ricebeach_anim8.bin"
	ret
GFX_Map_RiceBeach_Anim9: 
	mIncludeMultiInt6 "data/gfx/maps/ricebeach_anim9.bin"
	ret
	
; =============== Map_Mode_RiceBeach ===============
Map_Mode_RiceBeach:
	call Map_RiceBeach_DoLevelClear
	ld   a, [sMapLevelClear]
	and  a
	ret  nz
	
	call Map_Submap_DoEnterAnim
	ld   a, [sMapSubmapEnter]
	and  a
	ret  nz
	call Map_RiceBeach_Do
	ld   hl, sMapRiceBeachBlink
	call HomeCall_Map_BlinkLevel_Do
	ret	
Map_RiceBeach_Do:
	call Map_RiceBeach_AnimTiles
	call Map_Submap_DoCtrl
	call Map_RiceBeach_DoLevelSwitch
	call Map_WriteWarioOBJLst
	ret
	
; =============== Map_Submap_DoCtrl ===============
; This subroutine handles player movement in a submap.
; See also: Map_Overworld_DoCtrl
Map_Submap_DoCtrl:
	; Was a level selected?
	ld   a, [sMapLevelStartTimer]
	and  a
	jr   nz, Map_Submap_WaitLevelStart
	
	;--
	; Current path handling
	; If the path segment is still active, continue processing it
	ld   a, [sMapStepsLeft]
	cp   a, $00
	jp   nz, Map_Submap_DoPathSeg
	
	; If the segment is over and we're still in a path, check what to do
	ld   a, [sMapInPath]
	and  a
	jp   nz, Map_Submap_EndPathSeg
	;--
	
	; A or START to enter the level
	ldh  a, [hJoyNewKeys]
	and  a, KEY_A|KEY_START
	jr   nz, Map_Submap_EnterLevel
	
	; Handle directional keys
	call Map_Submap_DoPathCtrl ; Map_Submap_DoPathCtrl?
	
	; We might have started a new path now, so check this again
	ld   a, [sMapInPath]
	and  a
	ret  nz
	
	; B or SELECT to exit the submap
	ldh  a, [hJoyNewKeys]
	and  a, KEY_B|KEY_SELECT
	jr   nz, Map_Submap_Exit
	ret
	
; =============== Map_Submap_EnterLevel ===============
; Setups a fade out to the overworld.
Map_Submap_Exit:
	ld   a, SFX1_0A
	ld   [sSFX1Set], a
	
	ld   a, MAP_MODE_FADEOUT
	ld   [sMapId], a
	ld   a, MAP_MODE_INITOVERWORLD
	ld   [sMapNextId], a
	
	; Update sLevelId based on the position we'll be spawning from
	ld   a, [sMapWorldId]
	ld   b, a
	ld   a, LVL_OVERWORLD
	add  b
	ld   [sLevelId], a
	
	xor  a
	ld   [sMapSubmapEnter], a
	ld   [sMapLevelClear], a
	ret
	
; =============== Map_Submap_EnterLevel ===============
; Starts the level enter sequence.
Map_Submap_EnterLevel:
	ld   a, BGM_LEVELENTER
	ld   [sBGMSet], a
	; Start the timer
	; This will make sure to call Map_Submap_WaitLevelStart from the next frame.
	ld   hl, sMapLevelStartTimer
	inc  [hl]
	ret
	
; =============== Map_Submap_WaitLevelStart ===============
Map_Submap_WaitLevelStart:
	xor  a
	ld   [sMapCutsceneEndTimer], a
	ld   [sMapSubmapEnter], a
	ld   [sMapStepsLeft], a
	ld   [sMapPathCtrl], a
	ld   [sMapWarioAnimId], a
	ld   [sMapInPath], a
	ld   [sMapPathOffset], a
	; Force slow anim speed (for some reason...)
	ld   a, $07
	ld   [sMapWarioYOscillateMask], a
	; Timer++;
	ld   a, [sMapLevelStartTimer]
	inc  a
	; Wait for $38 frames (minus one) to allow the level start BGM to fully play.
	ld   [sMapLevelStartTimer], a
	cp   a, $38
	ret  nz
	
.setFadeOut:
	xor  a
	ld   [sMapLevelStartTimer], a
	; Request to exit from the map screen code after the fade out ends
	ld   a, $01
	ld   [sMapFadeOutRetVal], a
	ld   a, [sMapLevelId]
	ld   [sMapLevelIdSel], a
	ld   a, BGMACT_FADEOUT
	ld   [sBGMActSet], a
	ld   a, [sMapWorldId]
	cp   a, MAP_OWP_MTTEAPOT
	jr   z, .mtTeapot
	cp   a, MAP_OWP_STOVECANYON
	jr   z, .stoveCanyon
	cp   a, MAP_OWP_PARSLEYWOODS
	jr   z, .parsleyWoods
	cp   a, MAP_OWP_SSTEACUP
	jr   z, .ssTeacup
	cp   a, MAP_OWP_SHERBETLAND
	jr   z, .sherbetLand
	cp   a, MAP_OWP_SYRUPCASTLE
	jr   z, .syrupCastle
	
; =============== mLevelEnter ===============
; Macro for defining the map id to transition to after entering a level.
; IN
; - 1: MapId target after fade out
mLevelEnter: MACRO
	ld   a, MAP_MODE_FADEOUT
	ld   [sMapId], a
	ld   a, \1
	ld   [sMapNextId], a
	ret
ENDM
	
.riceBeach:    mLevelEnter MAP_MODE_INITRICEBEACH
.mtTeapot:     mLevelEnter MAP_MODE_INITMTTEAPOT
.stoveCanyon:  mLevelEnter MAP_MODE_INITSTOVECANYON
.parsleyWoods: mLevelEnter MAP_MODE_INITPARSLEYWOODS
.ssTeacup:     mLevelEnter MAP_MODE_INITSSTEACUP
.sherbetLand:  mLevelEnter MAP_MODE_INITSHERBETLAND
.syrupCastle:  mLevelEnter MAP_MODE_INITSYRUPCASTLE

; =============== Map_Submap_DoPathCtrl ===============
Map_Submap_DoPathCtrl:
	call Map_Submap_GetPathDirPtr  ; HL = PathDir ptr
	call Map_Submap_CheckForNewPath

; =============== Map_OnPathEnd ===============
; Restores Wario's anim options when outside of a path.
;
Map_OnPathEnd:
	ld   a, [sMapInPath]
	ret  nz
	
	xor  a								; Use front frame
	ld   [sMapWarioAnimId], a
IF FIX_BUGS == 1
	ld   [sMapBridgeAutoMove], a
ENDC
	ld   a, $07							; Set slower anim speed
	ld   [sMapWarioYOscillateMask], a
	ret
	
; =============== Map_Submap_EndPathSeg ===============
; Prepares a call Map_Submap_CheckForNextPathSeg in a submap.
; See also: Map_Overworld_EndPathSeg
Map_Submap_EndPathSeg:
	call Map_Submap_GetPathDirPtr
	call Map_Submap_CheckForNextPathSeg
	; If the map timer happens to land on $0F, play the walking SFX
	ld   a, [sMapTimer_Low]
	and  a, $0F
	ret  nz
	ld   a, SFX4_08
	ld   [sSFX4Set], a
	ret
	
; =============== Map_Submap_SetNextPathSeg ===============
; Sets up the next path segment for a submap.
;
; IN
; - HL: Ptr to the *start* of path data
Map_Submap_SetNextPathSeg:

	; If the offset to the path data is $00, assume something's wrong.
	; (when a path is first set, this value should be $03)
	ld   a, [sMapPathOffset]
	or   a, $00
	ret  z
	
	; Offset the current path segment
.indexLoop:
	; HL += MapPathCounter
	or   a, $00
	jr   z, Map_Submap_HandlePathCmd
	inc  hl
	dec  a
	jr   .indexLoop
	
; =============== Map_Submap_HandlePathCmd ===============
; Handles the new path command for a submap.
; This determines how to handle the next bytes.
;
; IN
; - HL: Pointer to the first byte of a path table entry
Map_Submap_HandlePathCmd:
	ldi  a, [hl]			; Get the path command
	cp   a, MAP_MPC_STOP	; Is it a path stop instruction?
	jr   z, Map_Submap_CheckPathEndType			; If so, jump
	ld   [sMapPathCtrl], a	; Otherwise, set the next path segment data
	
; =============== Map_SetPathCtrlArgs ===============
; Sets up memory for the newly requested path segment, starting from the second byte.
; This is meant to be used when the PathCtrl command is a directional command, 
; as it expects the 3 byte struct.
;
; IN
; - HL: Pointer to the second byte of a path table entry
Map_SetPathCtrlArgs:
	; Set other args
	ldi  a, [hl]
	ld   [sMapStepsLeft], a
	ld   a, [hl]
	ld   [sMapWarioAnimId], a
	
	; Update the offset used to index the path data
	ld   a, [sMapPathOffset]
	add  $03 ; sizeof(PathSegment)
	ld   [sMapPathOffset], a
	
	; We're (still) in a path
	ld   a, $01				
	ld   [sMapInPath], a
	ret
	
; =============== Map_Submap_CheckPathEndType ===============
; Determines the action to perform when the path ends.
;
; IN
; - HL: Pointer to the second byte of a path table entry
Map_Submap_CheckPathEndType:
	ld   a, [hl]
	cp   a, MAP_MPR_UNUSED_ALTID
	jr   z, .unused_useAltId		; [TCRF] Use an alternate world ID value.
	cp   a, MAP_MPR_EXITSUBMAP
	jr   z, .exitSubmap				; Generic submap exit path
	cp   a, MAP_MPR_C08LEFT
	jr   z, .c08Left				; C08 submap exit; triggers automove on overworld
	cp   a, MAP_MPR_C14RIGHT
	jr   z, .c14Right				; C14 submap exit; triggers automove on overworld
	
	; If not a special command, treat the value as a level id
	ld   [sMapLevelId], a
	xor  a
	ld   [sMap_Unused_UseLevelIdAlt], a
.endPath:
	ld   [sMapTimer0], a
	ld   [sMapStepsLeft], a
	ld   [sMapPathCtrl], a
	ld   [sMapInPath], a
	ld   [sMapPathOffset], a
	ld   [sMapPathDirSel], a
	ld   [sMapInPath], a
	ld   [sMapPathDirSel_Copy], a
	ret
.unused_useAltId:          
	; [TCRF] Unused path return command.
	;
	; The next byte of the command is used as Level ID and is stored in the sMap_Unused_LevelIdAlt address.
	; (incidentally, this is the only time the return command is 3 bytes long)
	;
	; This also sets the the unused sMap_Unused_UseLevelIdAlt flag, which tells the game
	; to use the value from the sMap_Unused_LevelIdAlt address as level ID rather than the normal one.
	;
	; The resulting behaviour is basically identical to the normal one --
	; the only real difference is that the normal MapLevelId value remains unchanged.
	;
	; Purpose of this is unknown.
	inc  hl
	ld   a, [hl]
	ld   [sMap_Unused_LevelIdAlt], a
	ld   hl, sMap_Unused_UseLevelIdAlt
	inc  [hl]
	jr   .endPath
	
.exitSubmap:
	call .endPath
	jp   Map_Submap_Exit
	
.c08Left:
	; We currently have the world ID set to Mt. Teapot
	; It needs to be manually set to the bridge so we can spawn at the correct location
	call .endPath
	ld   a, MAP_OWP_BRIDGE
	ld   [sMapWorldId], a
	ld   [sMapBridgeAutoMove], a	; Set the auto movement to $7, see Map_SubmapExitAutoMove
	jp   Map_Submap_Exit
.c14Right:
	call .endPath
	ld   a, $10						; Set the auto movement to $10, see Map_SubmapExitAutoMove
	ld   [sMapBridgeAutoMove], a
	jp   Map_Submap_Exit
	
; =============== Map_Submap_CheckForNextPathSeg ===============
; This subroutine indexes the path direction table based on the previously set path direction.
; With the ptr to the path data, memory will be setup to use the next path segment from it.
;
; IN
; - HL: Current path dir data
Map_Submap_CheckForNextPathSeg:
	;--
	; It's not necessary to fiter valid directions.
	; Since we're in the path, we are already going through it anyway!
	ld   a, [hl]
	ld   b, a
	;--
	; Determine the index to use for the direction
	ld   a, [sMapPathDirSel]
	call Map_ValidateCurPath				; this is pointless
	and  a, b
	bit  KEYB_RIGHT, a
	jr   nz, .right
	bit  KEYB_LEFT, a
	jr   nz, .left
	bit  KEYB_UP, a
	jr   nz, .up
	bit  KEYB_DOWN, a
	jr   nz, .down
	; [TCRF] We never get here
	xor  a
	ld   [sMapPathDirSel_Copy], a
	ret
.right:
	ld   a, $01
	jr   .end
.left:
	ld   a, $02
	jr   .end
.up:
	ld   a, $03
	jr   .end
.down:
	ld   a, $04
.end:
	call Map_Submap_IndexPathDirData
	call Map_Submap_SetNextPathSeg
	ret
	
; =============== Map_ValidateCurPath ===============
; [POI] This makes no sense.
;
; Because of the way it's called, it's seemingly meant to validate the
; currently selected path for Map_Submap_CheckForNextPathSeg,
; much like how Map_ValidateNewPath does it for Map_Submap_CheckForNewPath,
;
; However... it's completely pointless.
; Validation occurs and only makes sense when a path is entered. We already are in the middle of the path.
;
; Moreover, it's probably incomplete as it doesn't actually validate anything and uses values from
; the "last" completion address, which should never be used for filtering.
;
; IN
; - HL: Ptr to path information
; -  A: The direction we want to check (either joypad input or simulated input)
; -  B: All valid paths
; OUT
; -  A: Selected path direction. If the path *doesn't exist*, it will be 0.
; -  B: Should remain unchanged. If the path is *locked*, it will be 0.
Map_ValidateCurPath:
	ld   a, [sMapId]
	cp   a, MAP_MODE_RICEBEACH
	jr   z, .riceBeach
	cp   a, MAP_MODE_MTTEAPOT
	jr   z, .mtTeapot
	cp   a, MAP_MODE_STOVECANYON
	jr   z, .stoveCanyon
	cp   a, MAP_MODE_SYRUPCASTLE
	jr   z, .syrupCastle
	cp   a, MAP_MODE_PARSLEYWOODS
	jr   z, .parsleyWoods
	cp   a, MAP_MODE_SSTEACUP
	jr   z, .ssTeacup
	cp   a, MAP_MODE_SHERBETLAND
	jr   z, .sherbetLand
	; We never get here
	ld   a, [sMapPathDirSel]
	ret
.riceBeach:
	ld   a, [sMapRiceBeachCompletionLast]
	cp   a, $0F
	jr   z, .isAllClear
	call .checkFilter
	ret
.mtTeapot:
	ld   a, [sMapMtTeapotCompletionLast]
	cp   a, $3F
	jr   z, .isAllClear
	call .checkFilter
	ret
.stoveCanyon:
	ld   a, [sMapStoveCanyonCompletionLast]
	cp   a, $0F
	jr   z, .isAllClear
	call .checkFilter
	ret
.syrupCastle:
	ld   a, [sMapSyrupCastleCompletionLast]
	cp   a, $1F
	jr   z, .isAllClear
	call .checkFilter
	ret
.parsleyWoods:
	ld   a, [sMapParsleyWoodsCompletionLast]
	cp   a, $0F
	jr   z, .isAllClear
	call .checkFilter
	ret
.ssTeacup:
	ld   a, [sMapSSTeacupCompletionLast]
	cp   a, $0F
	jr   z, .isAllClear
	call .checkFilter
	ret
.sherbetLand:
	ld   a, [sMapSherbetLandCompletionLast]
	cp   a, $1F
	jr   z, .isAllClear
	call .checkFilter
	ret
.checkFilter:
	; This would be the validator... but it does nothing.
	; sMapPathDirSel_Copy contains an exact copy of sMapPathDirSel.
	; This is never 0 when we get here, but even if it isn't, the filter on register B isn't updated anyway.
	ld   a, [sMapPathDirSel_Copy]
	and  a
	jr   nz, .useAltCopy
.isAllClear:
	ld   a, [sMapPathDirSel]	; A = Selected path
	ret
.useAltCopy:
	ld   a, [sMapPathDirSel_Copy]
	ld   b, a
	jp   .isAllClear
	
; =============== Map_Submap_GetPathDataPtr ===============
; Gets the a ptr to the path data by path ID.
;
; IN
; - HL: Ptr to path ID
; OUT
; - HL: Ptr to path data
Map_Submap_GetPathDataPtr:
	ld   a, [hl]
	ld   hl, PathPtrTable_Levels
	call B8_IndexPtrTable
	ret
	
; =============== Map_Submap_IndexPathDirData ===============
; Indexes a path direction table for a submap.
;
; IN
; - HL: Ptr to path direction table
; -  A: PathDir struct index
; OUT
; - HL: Ptr to path data
Map_Submap_IndexPathDirData:
	; Index $00 does not point to path IDs
	; In case we get it, avoid doing anything and return
	or   a, $00
	ret  z
.loop:
	or   a, $00	; HL += A (Index the path table by direction)
	jr   z, Map_Submap_GetPathDataPtr
	inc  hl
	dec  a
	jr   .loop
	
; =============== Map_Submap_GetPathDirPtr ===============
; Gets the path direction info for the current level in a submap.
;
; OUT
; - HL: Ptr to path dir info
Map_Submap_GetPathDirPtr:
	ld   hl, PathDirPtrTable_Levels
	ld   a, [sMapLevelId]
	
; =============== B8_IndexPtrTable ===============
; Indexes a pointer table and gets the resulting pointer.
;
; IN
; -  A: Index
; - HL: Ptr to ptr table
; OUT
; - HL: Table index result
B8_IndexPtrTable:
	; HL = HL[A*2]
	add  a			; Offset for pointer table access
	ld   e, a
	ld   d, $00
	add  hl, de		; Index it
	ldi  a, [hl]	; Get the resulting value using E as temp
	ld   e, a
	ld   h, [hl]
	ld   l, e
	ret
	
; =============== Map_Submap_CheckForNewPath ===============
; This subroutine checks if we want to start a path in a submap.
; If so, and the path is valid/open we can go there.
; See also: Map_Overworld_CheckForNewPath
;
; IN
;  - HL: Ptr to the path information to use
Map_Submap_CheckForNewPath:
	; Setup a call to the filtering function.
	; If validation fails, the mask will be set to $00, which cancels the request.
	ld   a, [hl]
	ld   b, a					; B = All valid paths
	ldh  a, [hJoyNewKeys]
	ld   [sMapPathDirSel], a	; A = Newly pressed keys
	call Map_ValidateNewPath
	and  a, b
	
	; We need to index the correct entry of the PathDir data.
	; Determine the index for the direction we've pressed.
	bit  KEYB_RIGHT, a
	jr   nz, .right
	bit  KEYB_LEFT, a
	jr   nz, .left
	bit  KEYB_UP, a
	jr   nz, .up
	bit  KEYB_DOWN, a
	jr   nz, .down
	
	; [POI] Clear the copy value... for some reason. (not done in the overworld)
	xor  a
	ld   [sMapPathDirSel_Copy], a
	ret
.right:
	ld   a, $01
	jr   .end
.left:
	ld   a, $02
	jr   .end
.up:
	ld   a, $03
	jr   .end
.down:
	ld   a, $04
.end:
	call Map_Submap_IndexPathDirData
	call Map_Submap_HandlePathCmd
	ret
	
; =============== Map_Submap_DoPathSeg ===============
; This subroutine processes the currently active path segment in a submap.
; Essentially moves Wario on the direction we're going.
Map_Submap_DoPathSeg:
	; Enable fast movement speed
	ld   a, $03
	ld   [sMapWarioYOscillateMask], a
	
	ld   a, [sMapPathCtrl]
	cp   a, MAP_MPC_STOP
	jr   z, .stop
	cp   a, MAP_MPC_RIGHT
	jp   z, .right
	cp   a, MAP_MPC_LEFT
	jp   z, .left
	cp   a, MAP_MPC_UP
	jp   z, .up
	cp   a, MAP_MPC_DOWN
	jp   z, .down
.stop:
	; [POI] We normally never get here.
	;       However, with glitches (see [BUG] at Map_GetPathCompletionBitPtr) it's possible reach this and softlock the game.
	ret
	
; The actual subroutines for moving Wario in a submap
; All of these perform path movement every other frame.
.right:
	ld   a, [sMapTimer0]
	and  a, $00
	ret  nz
	
	ld   hl, sMapWarioX
	ld   bc, sMapStepsLeft
	call .incCoord
	ret
	
.left:
	ld   a, [sMapTimer0]
	and  a, $00
	ret  nz
	
	ld   hl, sMapWarioX
	ld   bc, sMapStepsLeft
	call .decCoord
	ret
	
; Decreases the specified coordinate and updates the specified steps left counter.
;
; IN
; - HL: Ptr to coordinate
; - BC: Ptr to steps left
.decCoord:
	dec  [hl]				; Coord--
	ld   a, [bc]			; StepsLeft--
	dec  a
	ld   [bc], a
	
	xor  a
	ld   [sMapTimer0], a
	ret
	
; Increases the specified coordinate and updates the specified steps left counter.
;
; IN
; - HL: Ptr to coordinate
; - BC: Ptr to steps left
.incCoord:
	inc  [hl]				; Coord++
	ld   a, [bc] 			; StepsLeft--
	dec  a
	ld   [bc], a
	
	xor  a
	ld   [sMapTimer0], a
	ret
	
.up:
	ld   a, [sMapTimer0]
	and  a, $00
	ret  nz
	
	ld   hl, sMapWarioYRes
	ld   bc, sMapStepsLeft
	call .decCoord
	; Don't forget the actual Wario Y
	ld   hl, sMapWarioY
	dec  [hl]
	ret
	
.down:
	ld   a, [sMapTimer0]
	and  a, $00
	ret  nz
	
	ld   hl, sMapWarioYRes
	ld   bc, sMapStepsLeft
	call .incCoord
	; Don't forget the actual Wario Y
	ld   hl, sMapWarioY
	inc  [hl]
	ret
	
; =============== Map_Submap_DoEnterAnim ===============
; Handles the effect of Wario entering the submap.
Map_Submap_DoEnterAnim:
	; If we aren't in that mode, ignore this
	ld   a, [sMapSubmapEnter]
	and  a
	ret  z
	
	; We're always moving when entering a path, so use fast anim speed
	ld   a, $03
	ld   [sMapWarioYOscillateMask], a
	call Map_SubmapEnter_SetWarioAnimId
	call Map_WriteWarioOBJLst
	; Index the level coordinates table
	ld   a, [sMapLevelId]
	ld   hl, Map_Submap_PosPtrTable
	call B8_IndexPtrTable
	ldi  a, [hl]	
	ld   b, a		; B = Y pos
	ld   a, [hl]
	ld   c, a		; C = X pos
	
	; Determine the direction to move to based on the submap
	ld   a, [sMapId]
	cp   a, MAP_MODE_RICEBEACH
	jr   z, .up
	cp   a, MAP_MODE_MTTEAPOT
	jr   z, .mtTeapot
	cp   a, MAP_MODE_STOVECANYON
	jr   z, .down
	cp   a, MAP_MODE_SYRUPCASTLE
	jr   z, .up
	cp   a, MAP_MODE_PARSLEYWOODS
	jr   z, .up
	cp   a, MAP_MODE_SSTEACUP
	jr   z, .right
	cp   a, MAP_MODE_SHERBETLAND
	jr   z, .left
	ret ; We never get here
.mtTeapot:
	; Special case for Mt.Teapot, as it's possible to enter it in 2 ways
	ld   a, [sMapWorldId]
	cp   a, MAP_OWP_BRIDGE
	jr   z, .right
	
; Each of these sets up two calls to move (or not move) the player in a direction.
; They also set up a register to mark if there was any movement or not.
.up:
	call Map_Submap_MoveWarioUpTo
	call Map_Submap_NoMoveWarioHorz
	jr   .end
.down:
	call Map_Submap_MoveWarioDownTo
	call Map_Submap_NoMoveWarioHorz
	jr   .end
.right:
	call Map_Submap_MoveWarioRightTo
	call Map_Submap_NoMoveWarioVert
	jr   .end
.left:
	call Map_Submap_NoMoveWarioVert
	call Map_Submap_MoveWarioLeftTo
.end:
	; [TCRF] These are saved to memory, but are never read back.
	ld   a, d
	ld   [sMap_Unused_VMove], a	; ... if there was V movement
	ld   a, e
	ld   [sMap_Unused_HMove], a	; ... if there was H movement
	
	; This only works because you can't move two directions at once
	cp   a, d	; Did any movement happen (VMove != HMove)?
	ret  nz		; If so, return 
	
	; If movement stopped, we're out of the submap enter animation
	xor  a
	ld   [sMapSubmapEnter], a
	call Map_MtTeapot_SetRealMapId
	call Map_SubmapSetStartPos
	ret
; =============== Map_MtTeapot_SetRealMapId ===============
; Sets the real overworld position of Mt.Teapot.
; This only has an effect when entering from the Bridge.
Map_MtTeapot_SetRealMapId:
	ld   a, [sMapId]
	cp   a, MAP_MODE_MTTEAPOT
	ret  nz
	ld   a, MAP_OWP_MTTEAPOT
	ld   [sMapWorldId], a
	ret
	

; Sets of subroutines for moving the player sprite up to a certain position in a submap.
; As submaps don't scroll the screen, these are markedly simpler compared to the Map_Overworld_MoveWario set.
;
; Each of these moves the player 1px to a certain direction in a submap.
; Movement stops once the specified position is reached.

; =============== Map_Submap_MoveWarioUpTo ===============
; Moves Wario up in the map screen until the specified Y pos is reached.
;
; IN
; - B: Target Y pos
;
; OUT
; - D: If 0, the target is reached
Map_Submap_MoveWarioUpTo:
	ld   a, [sMapWarioY]	; D = Current Y pos
	ld   d, a
	ld   a, b				; A = Dest Y pos
	
	cp   a, d				; Have we reached the target?
	ld   a, $00				; (return value)
	ld   d, a
	ret  z					; If so, return
.notReached:
	ld   a, [sMapWarioY]	; Move the player sprite up
	dec  a
	ld   [sMapWarioY], a
	ld   a, [sMapWarioYRes]	; As well as the visual Y position
	dec  a
	ld   [sMapWarioYRes], a
	
	ld   a, $01				; Mark movement as not finished
	ld   d, a
	ret
	
; =============== Map_Submap_MoveWarioDownTo ===============
; Moves Wario down in the map screen until the specified Y pos is reached.
;
; IN
; - B: Target Y pos
;
; OUT
; - D: If 0, the target is reached
Map_Submap_MoveWarioDownTo:
	ld   a, [sMapWarioY]
	ld   d, a
	ld   a, b
	
	cp   a, d
	ld   a, $00
	ld   d, a
	ret  z
.notReached:
	ld   a, [sMapWarioY]
	inc  a
	ld   [sMapWarioY], a
	ld   a, [sMapWarioYRes]
	inc  a
	ld   [sMapWarioYRes], a
	
	ld   a, $01
	ld   d, a
	ret
	
; =============== Map_Submap_NoMoveWarioHorz ===============
; Marks no horizontal movement in the submap enter path.
;
; OUT
; - E: Target reached (0)
Map_Submap_NoMoveWarioHorz:
	ld   a, $00
	ld   e, a
	ret
	
; =============== Map_Submap_NoMoveWarioVert ===============
; Marks no vertical movement in the submap enter path.
;
; OUT
; - D: Target reached (0)
Map_Submap_NoMoveWarioVert:
	ld   a, $00
	ld   d, a
	ret
	
; =============== Map_Submap_MoveWarioLeftTo ===============
; Moves Wario left in the map screen until the specified X pos is reached.
;
; IN
; - C: Target X pos
;
; OUT
; - E: If 0, the target is reached
Map_Submap_MoveWarioLeftTo:
	ld   a, [sMapWarioX]
	ld   e, a
	ld   a, c
	
	cp   e
	ld   a, $00
	ld   e, a
	ret  z
.notReached:
	ld   a, [sMapWarioX]
	dec  a
	ld   [sMapWarioX], a
	
	ld   a, $01
	ld   e, a
	ret
	
; =============== Map_Submap_MoveWarioRightTo ===============
; Moves Wario right in the map screen until the specified X pos is reached.
;
; IN
; - C: Target X pos
;
; OUT
; - E: If 0, the target is reached
Map_Submap_MoveWarioRightTo:
	ld   a, [sMapWarioX]
	ld   e, a
	ld   a, c
	
	cp   e
	ld   a, $00
	ld   e, a
	ret  z
.notReached:
	ld   a, [sMapWarioX]
	inc  a
	ld   [sMapWarioX], a
	
	ld   a, $01
	ld   e, a
	ret
	
; =============== Map_SubmapEnter_SetWarioAnimId ===============
; Determines which animation to initially play when entering a submap.
;
; Surprisingly, this does *not* depend on the path direction or as something hardcoded.
; This instead depends on a pseudo-random value.
;
Map_SubmapEnter_SetWarioAnimId:
	; Only set a new one if it isn't set already
	; (this is also the only reaason why MAP_MWA_FRONT2 exists, as MAP_MWA_FRONT is anim $00)
	ld   a, [sMapWarioAnimId]
	and  a
	ret  nz
	
	; Roll the dice
	ld   a, [sMapSubmapEnterTime]
	and  a, $07
	cp   a, $04
	jr   z, .front
	cp   a, $03
	jr   z, .back
	cp   a, $02
	jr   z, .left
	cp   a, $01
	jr   z, .right
.front2:
	ld   a, MAP_MWA_FRONT2
.setAnim:
	ld   [sMapWarioAnimId], a
	ret
.right:
	ld   a, MAP_MWA_RIGHT
	jr   .setAnim
.left:
	ld   a, MAP_MWA_LEFT
	jr   .setAnim
.back:
	ld   a, MAP_MWA_BACK
	jr   .setAnim
.front:
	ld   a, MAP_MWA_FRONT2
	jr   .setAnim
	
; =============== Map_RiceBeach_DoLevelSwitch ===============
; Handles the Level ID changes when Rice Beach is flooded.
;
; This replaces the current level ID when it's pointing to C01A or C03A,
; but it can also work in reverse.
Map_RiceBeach_DoLevelSwitch:
	; Only if the boss level is completed
	ld   a, [sMapRiceBeachCompletion]
	bit  5, a
	ret  z
	
	; [TCRF] The code never jumps, as the flood flag is always set if the boss level is completed.
	;
	; Normally the game only replaces the unflooded C01 and C03 with the flooded counterparts,
	; but the unreachable code does it in reverse.
	; It's possible something could have changed the flag in the map screen, 
	; maybe to allow switching between levels quickly at least in development.
	ld   a, [sMapRiceBeachFlooded]
	and  a
	jr   z, .unused_noFlood

.flood:
	ld   a, [sMapLevelId]	; Are we over C01?
	cp   a, LVL_C01A
	jr   z, .toC01B			; If so, replace it with the flooded level
	ld   a, [sMapLevelId]	; Are we over C03?
	cp   a, LVL_C03A
	ret  nz					; If not, return
.toC03B:
	ld   a, LVL_C03B		; Otherwise, replace it with the flooded level
	ld   [sMapLevelId], a
	ret
.toC01B:
	ld   a, LVL_C01B
	ld   [sMapLevelId], a
	ret
	
.unused_noFlood: 
	ld   a, [sMapLevelId]	; Are we over C01?
	cp   a, LVL_C01B
	jr   z, .unused_toC01A	; If so, replace it with the normal level
	ld   a, [sMapLevelId]	; Are we over C03?
	cp   a, LVL_C03B
	ret  nz					; If not, return
.unused_toC03A:
	ld   a, LVL_C03A		; Otherwise, replace it with the normal level
	ld   [sMapLevelId], a
	ret
.unused_toC01A:
	ld   a, LVL_C01A
	ld   [sMapLevelId], a
	ret

; =============== LoadVRAM_RiceBeach ===============
; Loads the submap's art and the correct tilemap depending on whether C5 was cleared.
LoadVRAM_RiceBeach:
	call HomeCall_LoadGFX_MtTeapot_RiceBeach
	ld   a, [sMapRiceBeachCompletion]
	bit  5, a
	jr   nz, .flood
.normal:
	call HomeCall_LoadBG_RiceBeach
	xor  a
	ld   [sMapRiceBeachFlooded], a
	ret
.flood:
	call HomeCall_LoadBG_RiceBeachFlooded
	ld   a, $01
	ld   [sMapRiceBeachFlooded], a
	ret
; =============== Map_Mode_RiceBeachInit ===============
; Loads the RiceBeach submap.
; Other submap init modes follow this template.
Map_Mode_RiceBeachInit:
	call Map_LoadPalette
	call LoadVRAM_RiceBeach
	call Map_ClearRAM
	xor  a
	ld   [sMapScrollY], a
	ld   [sMapScrollX], a
	call Map_RiceBeach_LoadEv
	call Map_InitMisc
	; Starting coords
	ld   a, $7C
	ld   [sMapOAMWriteX], a
	ld   [sMapWarioX], a
	ld   a, $8C
	ld   [sMapOAMWriteY], a
	ld   [sMapWarioYRes], a
	ld   [sMapWarioY], a
	;--
	call Map_SubmapSetStartPos
	ld   a, MAP_MODE_FADEIN
	ld   [sMapId], a
	ld   a, MAP_MODE_RICEBEACH
	ld   [sMapNextId], a
	ld   a, $00
	ldh  [rBGP], a
	ld   a, BGM_RICEBEACH
	ld   [sBGMSet], a
	;--
	; Check if the world clear cutscene needs to be played.
	; It requires C5 to be the newly completed level.
	ld   a, [sMapRiceBeachCompletion]
	bit  5, a	; C5 set
	ret  z
	ld   a, [sMapRiceBeachCompletionLast]
	bit  5, a	; C5 last clear
	ret  nz
	; If both conditions are true, force set the current mode to the overworld
	; and enable world clear mode.
	ld   a, MAP_MODE_INITOVERWORLD
	ld   [sMapId], a
	ld   a, [sMapWorldClear]
	add  $01
	ld   [sMapWorldClear], a
	ret
	
; =============== Map_ValidateNewPath ===============
; Creates a filter for the selected path bitmask based on the current map mode
; and the existing/unlocked paths.
;
; IN
; - HL: Ptr to path information
; -  A: The direction we want to check (either joypad input or simulated input)
; -  B: All valid paths
; OUT
; -  A: Selected path direction. If the path *doesn't exist*, it will be 0.
; -  B: Should remain unchanged. If the path is *locked*, it will be 0.
Map_ValidateNewPath:
	; Make sure the direction we're going to has a valid path.
	; Easy to check since the paths value is a KEY_* bitmask, 
	; so we can directly mask out the joypad input.
	and  a, b
	ret  z
	
	; Save the values we'll be restoring by the end of the function
	ld   a, b					
	ld   [sMapValidPaths], a
	; As well the path ptr for Map_IsMapComplete (which then saves it to memory...)
	ld   d, h					
	ld   e, l
	
	; We need to check now if the path is open.
	; Depending on the map we're in, we need different values.
	ld   a, [sMapId]
	cp   a, MAP_MODE_RICEBEACH
	jr   z, Map_RiceBeach_ValidateNewPath
	cp   a, MAP_MODE_MTTEAPOT
	jr   z, Map_MtTeapot_ValidateNewPath
	cp   a, MAP_MODE_STOVECANYON
	jr   z, Map_StoveCanyon_ValidateNewPath
	cp   a, MAP_MODE_SYRUPCASTLE
	jp   z, Map_SyrupCastle_ValidateNewPath
	cp   a, MAP_MODE_PARSLEYWOODS
	jr   z, Map_ParsleyWoods_ValidateNewPath
	cp   a, MAP_MODE_SSTEACUP
	jr   z, Map_SSTeacup_ValidateNewPath
	cp   a, MAP_MODE_SHERBETLAND
	jr   z, Map_SherbetLand_ValidateNewPath
	cp   a, MAP_MODE_OVERWORLD
	jp   z, Map_Overworld_ValidateNewPath
	; [TCRF] If the map isn't accounted for, assume the path is open.
	ldh  a, [hJoyNewKeys]
	ld   [sMapPathDirSel], a
	ret
	
; Shorthand for validating if a path is open
; IN
; - 1: Target bitmask value for a fully completed submap
; - 2: Subroutine to call to check for path unlock status
; - 3: Map Completion bitmask
; - 4: Map Completion bitmask (high, unused)
;
mMapValidatePath: MACRO
	ld   a, [\3]		; BC = Current map completion
	ld   c, a
	ld   a, [\4]
	ld   b, a
	
	; If the map is fully cleared, avoid checking in detail
	; and assume all paths are open
	ld   l, LOW(\1)		; HL = Expected completion value for a fully complete map
	ld   h, HIGH(\1)
	call Map_IsMapComplete
	jr   z, Map_ValidateNewPath_IsAllClear
	
	; Otherwise, determine if the path is unlocked
	call \2
	ret
ENDM

Map_RiceBeach_ValidateNewPath:    mMapValidatePath $007F,Map_RiceBeach_IsPathOpen,sMapRiceBeachCompletion,sMap_Unused_RiceBeachCompletionHigh
Map_MtTeapot_ValidateNewPath:     mMapValidatePath $00FF,Map_MtTeapot_IsPathOpen,sMapMtTeapotCompletion,sMap_Unused_MtTeapotCompletionHigh
Map_StoveCanyon_ValidateNewPath:  mMapValidatePath $007F,Map_StoveCanyon_IsPathOpen,sMapStoveCanyonCompletion,sMap_Unused_StoveCanyonCompletionHigh
Map_SSTeacup_ValidateNewPath:     mMapValidatePath $001F,Map_SSTeacup_IsPathOpen,sMapSSTeacupCompletion,sMap_Unused_SSTeacupCompletionHigh
Map_ValidateNewPath_IsAllClear:
	; If the map is fully cleared, all paths are automatically open
	ld   a, [sMapPathDirSel]
	ret
Map_ParsleyWoods_ValidateNewPath: mMapValidatePath $003F,Map_ParsleyWoods_IsPathOpen,sMapParsleyWoodsCompletion,sMap_Unused_ParsleyWoodsCompletionHigh
Map_SherbetLand_ValidateNewPath:  mMapValidatePath $00FF,Map_SherbetLand_IsPathOpen,sMapSherbetLandCompletion,sMap_Unused_SherbetLandCompletionHigh
Map_SyrupCastle_ValidateNewPath:  mMapValidatePath $000F,Map_SyrupCastle_IsPathOpen,sMapSyrupCastleCompletion,sMap_Unused_SyrupCastleCompletionHigh

; =============== Map_IsMapComplete ===============	
; Checks if the map completion value matches exactly the provided completion value.
; In practice it's only useful for checking if a submap (or overworld) is fully completed.
;
; IN
; - BC: Current map completion
; - DE: Ptr to path information
; - HL: Target completion status (for a fully complete submap)
; OUT
; - HL: Ptr to path information
; -  B: All valid paths
; -  Z: If the completion value matches (ie: the map is fully complete)
Map_IsMapComplete:
	; Save a copy of this for later
	ld   a, d					
	ld   [sMapPathsPtr_High], a
	ld   a, e
	ld   [sMapPathsPtr_Low], a
	
	; All we need now is at least one check returning nz (to detect a non-fully complete map)
	
	; Does the completion status match for the low byte?
	ld   a, l
	sub  a, c
	jr   nz, .end
	; If so, also check the high byte
	ld   a, h
	sub  a, b
	
.end:
	; Restore the values we've modified before
	ld   a, [sMapPathsPtr_High]
	ld   h, a
	ld   a, [sMapPathsPtr_Low]
	ld   l, a
	ld   a, [sMapValidPaths]
	ld   b, a
	ret
; =============== Map_Overworld_ValidateNewPath ===============
Map_Overworld_ValidateNewPath:
	call Map_Overworld_SetCompletion
	ld   a, [sMapOverworldCompletion]
	ld   c, a
	ld   a, [sMap_Unused_SyrupCastleCompletionHigh]
	ld   b, a
	ld   l, $3F
	ld   h, $00
	call Map_IsMapComplete
	jr   z, Map_ValidateNewPath_IsAllClear
	call Map_Overworld_IsPathOpen
	ret
; =============== Map_Overworld_SetCompletion ===============
; Auto-generates the overworld completion bitmask by merging the bits of boss levels from each submap.
Map_Overworld_SetCompletion:
	
	; Each check follows a template.
.riceBeach:
	ld   a, [sMapRiceBeachCompletion]	; First check if the boss level is completed
	bit  5, a
	jr   z, .mtTeapot						; If not, skip
	ld   a, [sMapOverworldCompletion]	; If it is, the respective bit in the overworld completion should be set
	bit  MAP_CLRB_RICEBEACH, a
	jr   nz, .mtTeapot					; but only if it isn't set already
	add  $01							; (couldn't simply ld b + or b?)
	ld   [sMapOverworldCompletion], a
.mtTeapot:
	ld   a, [sMapMtTeapotCompletion]
	bit  7, a
	jr   z, .stoveCanyon
	ld   a, [sMapOverworldCompletion]
	bit  MAP_CLRB_MTTEAPOT, a
	jr   nz, .stoveCanyon
	add  $02
	ld   [sMapOverworldCompletion], a
.stoveCanyon:
	ld   a, [sMapStoveCanyonCompletion]
	bit  6, a
	jr   z, .ssTeacup
	ld   a, [sMapOverworldCompletion]
	bit  MAP_CLRB_STOVECANYON, a
	jr   nz, .ssTeacup
	add  $04
	ld   [sMapOverworldCompletion], a
.ssTeacup:
	ld   a, [sMapSSTeacupCompletion]
	bit  4, a
	jr   z, .parsleyWoods
	ld   a, [sMapOverworldCompletion]
	bit  MAP_CLRB_SSTEACUP, a
	jr   nz, .parsleyWoods
	add  $08
	ld   [sMapOverworldCompletion], a
.parsleyWoods:
	ld   a, [sMapParsleyWoodsCompletion]
	bit  5, a
	jr   z, .sherbetLand
	ld   a, [sMapOverworldCompletion]
	bit  MAP_CLRB_PARSLEYWOODS, a
	jr   nz, .sherbetLand
	add  $10
	ld   [sMapOverworldCompletion], a
.sherbetLand:
	ld   a, [sMapSherbetLandCompletion]
	bit  7, a
	jr   z, .syrupCastle
	ld   a, [sMapOverworldCompletion]
	bit  MAP_CLRB_SHERBETLAND, a
	jr   nz, .syrupCastle
	add  $20
	ld   [sMapOverworldCompletion], a
.syrupCastle:;R
	ld   a, [sMapSyrupCastleCompletion]
	bit  3, a
	ret  z
	; [TCRF] We never get here, Syrup Castle is never marked as completed
	ld   a, [sMapOverworldCompletion]
	bit  MAP_CLRB_SYRUPCASTLE, a
	ret  nz
	add  $40
	ld   [sMapOverworldCompletion], a
	ret
	
; =============== Map_Overworld_IsPathOpen ===============
Map_Overworld_IsPathOpen:
	ld   a, [sMapWorldId]
	ld   hl, PathUnlockPtrTable_Overworld
	call Map_GetPathCompletionBitPtr
	ld   a, [sMapOverworldCompletion]
	ld   c, a
	ld   a, [sMap_Unused_SyrupCastleCompletionHigh]
	ld   b, a
	call Map_IsPathOpen
	ret
	
; Shorthand wrapper for preparing a call to Map_IsPathOpen
; IN
; - 1: Map Completion bitmask
; - 2: Map Completion bitmask (high, unused)
;
mMapIsSubmapOpen: MACRO
	; Get the mask required to start the path
	call Map_Submap_GetPathCompletionBitPtr
	; BC = Map completion bitmask
	ld   a, [\1]
	ld   c, a
	ld   a, [\2]
	ld   b, a
	; Verify it
	call Map_IsPathOpen
	ret
ENDM

Map_SyrupCastle_IsPathOpen:  mMapIsSubmapOpen sMapSyrupCastleCompletion, sMap_Unused_SyrupCastleCompletionHigh
Map_SherbetLand_IsPathOpen:  mMapIsSubmapOpen sMapSherbetLandCompletion, sMap_Unused_SherbetLandCompletionHigh
Map_ParsleyWoods_IsPathOpen: mMapIsSubmapOpen sMapParsleyWoodsCompletion, sMap_Unused_ParsleyWoodsCompletionHigh
Map_SSTeacup_IsPathOpen:     mMapIsSubmapOpen sMapSSTeacupCompletion, sMap_Unused_SSTeacupCompletionHigh
Map_StoveCanyon_IsPathOpen:  mMapIsSubmapOpen sMapStoveCanyonCompletion, sMap_Unused_StoveCanyonCompletionHigh
Map_MtTeapot_IsPathOpen:     mMapIsSubmapOpen sMapMtTeapotCompletion, sMap_Unused_MtTeapotCompletionHigh
Map_RiceBeach_IsPathOpen:    mMapIsSubmapOpen sMapRiceBeachCompletion, sMap_Unused_RiceBeachCompletionHigh
	
; =============== Map_Submap_GetPathCompletionBitPtr ===============
; Gets the completion bitmask required to go through the specified path.
;
; OUT
; - H: Parh unlock bitmask 
; - L: Path unlock bitmask (high byte)
Map_Submap_GetPathCompletionBitPtr:
	ld   a, [sMapLevelId]
	ld   hl, PathUnlockPtrTable_Course
Map_GetPathCompletionBitPtr:
	; Index the path unlock data table
	call B8_IndexPtrTable
	
	; We now are pointing to another table for the unlock requirements
	; from the current location in the map.
	; Determine the index to use depending on the direction we want to go.
	
	; [BUG] These are not checked in the same order as other places.
	;       As none of the subroutines doesn't account for multiple keypresses, those can cause problems.
	;
	;		In practice this becomes a problem when holding DOWN-RIGHT in a spot where there's a path below, but not on the right.
	;       If a path is defined, the level can be skipped.
	;       If no path is defined for a direction, it will use the magic value $FF as a path ID.
	;       Then it becomes a game of chance if the broken Wario anim ID it pulls out causes a crash
	;       or if the broken path control value causes a softlock.
	
	ld   a, [sMapPathDirSel]
IF FIX_BUGS == 1
	bit  KEYB_RIGHT, a
	jr   nz, .right
ENDC
	bit  KEYB_LEFT, a
	jr   nz, .left
	bit  KEYB_UP, a
	jr   nz, .up
	bit  KEYB_DOWN, a
	jr   nz, .down
.right:
	ld   a, $00
	jr   .doIndex
.left:
	ld   a, $01
	jr   .doIndex
.up:
	ld   a, $02
	jr   .doIndex
.down:
	ld   a, $03
.doIndex:
	; Index the new table to point to the completion bits for the direction
	; it's not really a ptr table but whatever
	call B8_IndexPtrTable
	ret
	
; =============== Map_IsPathOpen return points ===============
; As a general reminder, to determine is the path is open,
; (A & B) != 0

Map_PathIsLocked:
	; Because of how code is setup, we should only get here when A == $00.
	
	; The path should be marked as locked.
	; To do this, we replace the value treated as "Valid paths" with $00.
	ld   b, a ; B = 0
	ld   [sMapPathDirSel_Copy], a
	; Restore path ptr
	ld   a, [sMapPathsPtr_High]
	ld   h, a
	ld   a, [sMapPathsPtr_Low]
	ld   l, a
	; And the selected path direction
	ld   a, [sMapPathDirSel]
	ret
Map_PathIsOpen:
	; Mark A and B as equal
	ld   a, [sMapPathDirSel]
	ld   b, a
	ld   [sMapPathDirSel_Copy], a
	; Restore path ptr
	ld   a, [sMapPathsPtr_High]
	ld   h, a
	ld   a, [sMapPathsPtr_Low]
	ld   l, a
	; And the selected path direction
	ld   a, [sMapPathDirSel]
	ret

; =============== Map_IsPathOpen ===============
; Checks if the path we're attempting to go to is unlocked.
; If so, it will set up memory to allow travelling to the path.
;
; IN
; -  H: Path unlock bitmask
; -  L: Path unlock bitmask (high value)
; - BC: Completion status bitmask
;
; NOTE: L an B are always 0 as the upper bitmask isn't used.
;
; Out:
; -  A: Selected path direction
; -  B: Will be 0 if the direction isn't valid / unlocked
; - HL: Ptr to path data (restored from mem backup)
Map_IsPathOpen:
	; Is the unlock bitmask $00? (ie: there's no path)
	ld   a, h
	or   a, l
	jr   z, Map_PathIsLocked
	
.checkSubmapExit:
	; Is any of the unlock masks set as exit command?
	; If so, those should always be open.
	ld   a, h
	cp   a, MAP_MPR_EXITSUBMAP
	jr   z, Map_PathIsOpen
	ld   a, l
	cp   a, MAP_MPR_EXITSUBMAP
	jr   z, Map_PathIsOpen
	
.checkCompletionBit:
	; If the requested bit is set, the path is open
	ld   a, c					
	and  a, h
	jr   nz, Map_PathIsOpen
	; [TCRF] Also check the upper byte, which is always $00
	ld   a, b 					
	and  a, l
	jr   z, Map_PathIsLocked
	jr   Map_PathIsOpen ; so we never get here

; =============== PATH UNLOCK TABLES ===============
; These tables determine the requirements (for the map completion status) to unlock a path.
; - The first table is for the overworld, and is indexed by World Id
; - The second table is for the submaps, and is indexed by Level Id
;
; PATH UNLOCK FORMAT:
; A single PathUnlock Table is 8 bytes large, which can be grouped in 4 pairs of 2 bytes:
;
; - Right path unlock bitmask (*big endian*)
; - Left path ... ""
; - Up path ... ""
; - Down path ... ""
;
; The reason these are pairs, is that it accounts for map screens having 16 exits (which require 16 bits),
; even though this is never used in-game.
; These aren't proper 16 bit values either, as they would we stored in big endian format.
;
; Two special values can be used:
; - $00 always prevents movement
; - $FD to mark paths always unlocked
;


PathUnlockPtrTable_Overworld: 
	dw PathUnlock_RiceBeach
	dw PathUnlock_MtTeapot
	dw PathUnlock_StoveCanyon
	dw PathUnlock_ParsleyWoods
	dw PathUnlock_SSTeacup
	dw PathUnlock_SherbetLand
	dw PathUnlock_SyrupCastle
	dw PathUnlock_Bridge
PathUnlockPtrTable_Course:
	dw PathUnlock_C26    
	dw PathUnlock_C33    
	dw PathUnlock_C15    
	dw PathUnlock_C20    
	dw PathUnlock_C16    
	dw PathUnlock_C10    
	dw PathUnlock_C07    
	dw PathUnlock_C01A   
	dw PathUnlock_C17    
	dw PathUnlock_C12    
	dw PathUnlock_C13    
	dw PathUnlock_C29    
	dw PathUnlock_C04    
	dw PathUnlock_C09    
	dw PathUnlock_C03A   
	dw PathUnlock_C02    
	dw PathUnlock_C08    
	dw PathUnlock_C11    
	dw PathUnlock_C35    
	dw PathUnlock_C34    
	dw PathUnlock_C30    
	dw PathUnlock_C21    
	dw PathUnlock_C22    
	dw PathUnlock_C01B   
	dw PathUnlock_C19    
	dw PathUnlock_C05    
	dw PathUnlock_C36    
	dw PathUnlock_C24    
	dw PathUnlock_C25    
	dw PathUnlock_C32    
	dw PathUnlock_C27    
	dw PathUnlock_C28    
	dw PathUnlock_C18    
	dw PathUnlock_C14    
	dw PathUnlock_C38    
	dw PathUnlock_C39    
	dw PathUnlock_C03B   
	dw PathUnlock_C37    
	dw PathUnlock_C31A   
	dw PathUnlock_C23    
	dw PathUnlock_C40    
	dw PathUnlock_C06    
	dw PathUnlock_C31B   
	dw PathUnlock_Dummy_2B ; Dummy entries; all $00
	dw PathUnlock_Dummy_2C
	dw PathUnlock_Dummy_2D
	dw PathUnlock_Dummy_2E
	; Special path for the automatic movement from C12 to C13
	; This took the place of a dummy "2F" path unlock info, which is now unreferenced.
	dw PathUnlock_C12Special 
	ret

PathUnlock_C26:
	db $00,$00
	db $00,$FD
	db $00,$00
	db $00,$01
PathUnlock_C33:
	db $00,$00
	db $00,$02
	db $00,$04
	db $00,$00
PathUnlock_C15:
	db $00,$00
	db $00,$04
	db $00,$01
	db $00,$02
PathUnlock_C20:
	db $00,$00
	db $00,$00
	db $00,$FD
	db $00,$01
PathUnlock_C16:
	db $00,$10
	db $00,$08
	db $00,$02
	db $00,$00
PathUnlock_C10:
	db $00,$10
	db $00,$08
	db $00,$00
	db $00,$00
PathUnlock_C07:
	db $00,$00
	db $00,$01
	db $00,$00
	db $00,$FD
PathUnlock_C01A:
	db $00,$01
	db $00,$00
	db $00,$00
	db $00,$FD
PathUnlock_C17:
	db $00,$00
	db $00,$00
	db $00,$04
	db $00,$20
PathUnlock_C12:
	db $00,$00
	db $00,$20
	db $00,$00
	db $00,$00
PathUnlock_C13:
	db $00,$10
	db $00,$08
	db $00,$00
	db $00,$00
PathUnlock_C29:
	db $00,$08
	db $00,$04
	db $00,$00
	db $00,$00
PathUnlock_C04:
	db $00,$00
	db $00,$00
	db $00,$10
	db $00,$04
PathUnlock_C09:
	db $00,$00
	db $00,$00
	db $00,$08
	db $00,$02
PathUnlock_C03A:
	db $00,$02
	db $00,$04
	db $00,$08
	db $00,$00
PathUnlock_C02:
	db $00,$00
	db $00,$02
	db $00,$00
	db $00,$01
PathUnlock_C08:
	db $00,$01
	db $00,$04
	db $00,$02
	db $00,$00
PathUnlock_C11:
	db $00,$00
	db $00,$00
	db $00,$10
	db $00,$20
PathUnlock_C35:
	db $00,$08
	db $00,$00
	db $00,$10
	db $00,$00
PathUnlock_C34:
	db $00,$00
	db $00,$08
	db $00,$00
	db $00,$04
PathUnlock_C30:
	db $00,$00
	db $00,$08
	db $00,$00
	db $00,$00
PathUnlock_C21:
	db $00,$02
	db $00,$00
	db $00,$01
	db $00,$00
PathUnlock_C22:
	db $00,$00
	db $00,$02
	db $00,$00
	db $00,$04
PathUnlock_C01B:
	db $00,$01
	db $00,$00
	db $00,$00
	db $00,$FD
PathUnlock_C19:
	db $00,$08
	db $00,$00
	db $00,$20
	db $00,$00
PathUnlock_C05:
	db $00,$00
	db $00,$10
	db $00,$00
	db $00,$10
PathUnlock_C36:
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$10
PathUnlock_C24:
	db $00,$10
	db $00,$00
	db $00,$00
	db $00,$00
PathUnlock_C25:
	db $00,$00
	db $00,$08
	db $00,$00
	db $00,$00
PathUnlock_C32:
	db $00,$02
	db $00,$01
	db $00,$00
	db $00,$00
PathUnlock_C27:
	db $00,$00
	db $00,$00
	db $00,$01
	db $00,$02
PathUnlock_C28:
	db $00,$04
	db $00,$00
	db $00,$02
	db $00,$00
PathUnlock_C18:
	db $00,$00
	db $00,$10
	db $00,$00
	db $00,$00
PathUnlock_C14:
	db $00,$FD
	db $00,$01
	db $00,$00
	db $00,$00
PathUnlock_C38:
	db $00,$00
	db $00,$00
	db $00,$02
	db $00,$01
PathUnlock_C39:
	db $00,$00
	db $00,$00
	db $00,$04
	db $00,$02
PathUnlock_C03B:
	db $00,$02
	db $00,$04
	db $00,$08
	db $00,$00
PathUnlock_C37:
	db $00,$00
	db $00,$01
	db $00,$00
	db $00,$FD
PathUnlock_C31A:
	db $00,$01
	db $00,$00
	db $00,$00
	db $00,$FD
PathUnlock_C23:
	db $00,$08
	db $00,$10
	db $00,$04
	db $00,$00
PathUnlock_C40:
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$04
PathUnlock_C06:
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$08
PathUnlock_C31B:
	db $00,$01
	db $00,$00
	db $00,$00
	db $00,$FD
PathUnlock_Dummy_2B:
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
PathUnlock_Dummy_2C:
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
PathUnlock_Dummy_2D:
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
PathUnlock_Dummy_2E:
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
PathUnlock_Dummy_2F:
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
PathUnlock_C12Special:
	db $00,$00
	db $00,$20
	db $00,$00
	db $00,$00
	ret
PathUnlock_RiceBeach:
	db $00,$00
	db $00,$00
	db $00,$01
	db $00,$00
PathUnlock_MtTeapot:
	db $00,$02
	db $00,$00
	db $00,$20
	db $00,$01
PathUnlock_StoveCanyon:
	db $00,$00
	db $00,$02
	db $00,$00
	db $00,$04
PathUnlock_ParsleyWoods:
	db $00,$00
	db $00,$00
	db $00,$10
	db $00,$08
PathUnlock_SSTeacup:
	db $00,$00
	db $00,$04
	db $00,$08
	db $00,$00
PathUnlock_SherbetLand:
	db $00,$FD
	db $00,$00
	db $00,$00
	db $00,$02
PathUnlock_SyrupCastle:
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$10
PathUnlock_Bridge:
	db $00,$00
	db $00,$FD
	db $00,$00
	db $00,$00

; =============== Map_Overworld_CheckEv ===============
; Sets of functions to apply patch tilemaps all at once during map init.
; The overworld and each submap has its own function.
;
; The overworld code is simpler since it doesn't need to handle
; the path reveal anim workaround (last completion values and all).
;
; EVENT DATA FORMAT
; The event data is split into 2 linked tables, both ending with a single $FF byte:
; - List of tile IDs
; - List of pointers to the tilemap for the above (where to write the tile ID)
;   This is stored in big endian format.
;
Map_Overworld_CheckEv:
	ld   a, [sMapParsleyWoodsCompletion]	; If C32 is cleared, draw the empty lake tilemap
	bit  1, a
	ret  z
Map_Overworld_WriteEv:
	ld   bc, Ev_Map_OverworldEmptyLake_Tiles
	ld   hl, Ev_Map_OverworldEmptyLake_Offsets
	call Map_WriteFullEv
	ret
Ev_Map_OverworldEmptyLake_Tiles:   INCBIN "data/event/overworld_emptylake.evt"
Ev_Map_OverworldEmptyLake_Offsets: INCBIN "data/event/overworld_emptylake.evp"

; =============== Map_RiceBeach_LoadEv ===============
; Applies instant event data when loading Rice Beach.
Map_RiceBeach_LoadEv:
	ld   a, [sMapRiceBeachFlooded]	; Use the flood tilemap?
	and  a
	jr   nz, .flood					; If so, jump
	ld   a, [sMapLevelClear]		; Are we in level clear mode?
	and  a
	jr   nz, .checkMapClear			; If so, jump
.useCurrent:
	; Apply patch tilemaps based on the completion status as usual
	call Map_RiceBeach_CheckEv
.end:
	xor  a
	ld   [sMapLevelClear], a
	ret
	
.flood:
	; This is a handled a bit differently because the flood tilemap only has one event.
	; So what would normally go into CheckEv is here:
	
	; If the path to C06 isn't open yet, skip further checks
	ld   a, [sMapRiceBeachCompletion]
	bit  3, a
	jr   z, .end
	; If C06 is open but isn't marked in the "last completion" bitmask, its path reveal animation should play.
	; So return immediately to avoid resetting sMapLevelClear.
	ld   a, [sMapRiceBeachCompletionLast]
	bit  3, a
	ret  z
	; Otherwise we can apply the event data, which is reused from the normal tilemap
	ld   a, $08
	ld   bc, Ev_Map_C03ClearAlt_Tiles
	ld   hl, Ev_Map_C03ClearAlt_Offsets
	call Map_WriteFullEv_OnL3Clear
	jr   .end
.checkMapClear:
	; Check if there's actually a path reveal in progress.
	; If there isn't, assume something's horribly wrong and fall back to the normal .useCurrent,
	; which will clear this badly set flag (and prevent the game from crashing).
	ld   de, sMapRiceBeachCompletionLast
	ld   bc, sMap_Unused_RiceBeachCompletionHighLast
	ld   a, [sMapRiceBeachCompletion]
	ld   l, a
	ld   a, [sMap_Unused_RiceBeachCompletionHigh]
	ld   h, a
	call Map_IsValidPathReveal		
	and  a						
	jr   z, .useCurrent				
	; If there is
	call Map_RiceBeach_CheckLastEv					; Otherwise continue play
	ret
	
; =============== Map_IsValidPathReveal ===============
; Checks if a path reveal anim can play, based off the submap completion bitmasks.
;
; IN
; - DE: Ptr to last completion status
; - BC: Ptr to last completion status (unused, high bitmask)
; - HL: Completion status (16 bits)
;
; OUT
; -  A: If 1, a path reveal is in progress
Map_IsValidPathReveal:
	; Check if the low bitmask matches the "last copy"
	ld   a, [de]			
	ld   d, a				; D = Last completion
	ld   a, l				; A = Current completion
	sub  a, d				; Is A != D?
	jr   nz, .inProgress	; If so, there's a path reveal anim to play
	; [TCRF] Do the same for the unused upper bitmask
	ld   a, [bc]			
	ld   d, a
	ld   a, h
	sub  a, d
	jr   nz, .inProgress
	xor  a
	ret
.inProgress:
	ld   a, $01
	ret
	
; =============== Map_MtTeapot_LoadEv ===============
; Applies instant event data when loading Mt. Teapot.
Map_MtTeapot_LoadEv:
	ld   a, [sMapLevelClear]
	and  a
	jr   nz, .checkMapClear
.useCurrent:
	call Map_MtTeapot_CheckEv
	xor  a
	ld   [sMapLevelClear], a
	ret
.checkMapClear:
	ld   de, sMapMtTeapotCompletionLast
	ld   bc, sMap_Unused_MtTeapotCompletionHighLast
	ld   a, [sMapMtTeapotCompletion]
	ld   l, a
	ld   a, [sMap_Unused_MtTeapotCompletionHigh]
	ld   h, a
	call Map_IsValidPathReveal
	and  a
	jr   z, .useCurrent
	call Map_MtTeapot_CheckLastEv
	ret
	
; =============== Map_StoveCanyon_LoadEv ===============
Map_StoveCanyon_LoadEv:
	ld   a, [sMapLevelClear]
	and  a
	jr   nz, .checkMapClear
.useCurrent:
	call Map_StoveCanyon_CheckEv
	xor  a
	ld   [sMapLevelClear], a
	ret
.checkMapClear:
	ld   de, sMapStoveCanyonCompletionLast
	ld   bc, sMap_Unused_StoveCanyonCompletionHighLast
	ld   a, [sMapStoveCanyonCompletion]
	ld   l, a
	ld   a, [sMap_Unused_StoveCanyonCompletionHigh]
	ld   h, a
	call Map_IsValidPathReveal
	and  a
	jr   z, .useCurrent
	call Map_StoveCanyon_CheckLastEv
	ret
	
; =============== Map_SSTeacup_LoadEv ===============
Map_SSTeacup_LoadEv:
	ld   a, [sMapLevelClear]
	and  a
	jr   nz, .checkMapClear
.useCurrent:
	call Map_SSTeacup_CheckEv
	xor  a
	ld   [sMapLevelClear], a
	ret
.checkMapClear:
	ld   de, sMapSSTeacupCompletionLast
	ld   bc, sMap_Unused_SSTeacupCompletionHighLast
	ld   a, [sMapSSTeacupCompletion]
	ld   l, a
	ld   a, [sMap_Unused_SSTeacupCompletionHigh]
	ld   h, a
	call Map_IsValidPathReveal
	and  a
	jr   z, .useCurrent
	call Map_SSTeacup_CheckLastEv
	ret
	
; =============== Map_ParsleyWoods_LoadEv ===============
Map_ParsleyWoods_LoadEv:
	ld   a, [sMapLevelClear]
	and  a
	jr   nz, .checkMapClear
.useCurrent:
	call Map_ParsleyWoods_CheckEv
	xor  a
	ld   [sMapLevelClear], a
	ret
.checkMapClear:
	ld   de, sMapParsleyWoodsCompletionLast
	ld   bc, sMap_Unused_ParsleyWoodsCompletionHighLast
	ld   a, [sMapParsleyWoodsCompletion]
	ld   l, a
	ld   a, [sMap_Unused_ParsleyWoodsCompletionHigh]
	ld   h, a
	call Map_IsValidPathReveal
	and  a
	jr   z, .useCurrent
	call Map_ParsleyWoods_CheckLastEv
	ret
	
; =============== Map_SherbetLand_LoadEv ===============
Map_SherbetLand_LoadEv:
	ld   a, [sMapLevelClear]
	and  a
	jr   nz, .checkMapClear
.useCurrent:
	call Map_SherbetLand_CheckEv
	xor  a
	ld   [sMapLevelClear], a
	ret
.checkMapClear:
	ld   de, sMapSherbetLandCompletionLast
	ld   bc, sMap_Unused_SherbetLandCompletionHighLast
	ld   a, [sMapSherbetLandCompletion]
	ld   l, a
	ld   a, [sMap_Unused_SherbetLandCompletionHigh]
	ld   h, a
	call Map_IsValidPathReveal
	and  a
	jr   z, .useCurrent
	call Map_SherbetLand_CheckLastEv
	ret
	
; =============== Map_SyrupCastle_LoadEv ===============
Map_SyrupCastle_LoadEv:
	ld   a, [sMapLevelClear]
	and  a
	jr   nz, .checkMapClear
.useCurrent:
	call Map_SyrupCastle_CheckEv
	
	ld   a, [sMapSyrupCastleCutscene]	; Did a cutscene play the last time the map loaded?
	and  a
	jr   nz, .disableCutscene			; If so, disable it as it's been already played.
	
	; Note that when a cutscene starts, the ID value isn't set by the time this function is called.
	; If it is set, it means the game is loading the map screen after a cutscene finished playing 
	; and the treasure room was exited.
	;
	; There's no real reason the cutscene flag is cleared here of all places
	; -- this could have been done when a cutscene finishes playing but oh well.
	
	xor  a
	ld   [sMapLevelClear], a
	ret
.disableCutscene:
	xor  a
	ld   [sMapSyrupCastleCutscene], a
	ret
.checkMapClear:
	ld   de, sMapSyrupCastleCompletionLast
	ld   bc, sMap_Unused_SyrupCastleCompletionHighLast
	ld   a, [sMapSyrupCastleCompletion]
	ld   l, a
	ld   a, [sMap_Unused_SyrupCastleCompletionHigh]
	ld   h, a
	call Map_IsValidPathReveal
	and  a
	jr   z, .useCurrent
	call Map_SyrupCastle_CheckLastEv
	ret
	
; =============== Map_WriteFullEv_OnL?Clear ===============
; These are a set of helper subroutines which apply the specified event data depending on the submap completion status.
; There's one subroutine to check for each bit, but basically work all the same.
;
; IN
; -  A: Completion status bitmask to check
; - BC: Ptr to table of tile IDs to use.
; - HL: Ptr to table VRAM ptrs to a tilemap (where to place the aforemented tile ID)
Map_WriteFullEv_OnL0Clear:
	bit  0, a								; Is the path at bit 0 open?
	jr   z, Map_WriteFullEv_OnLClearEnd		; If not, end
	call Map_WriteFullEv
Map_WriteFullEv_OnLClearEnd:
	; Write $00 to the upper byte of the VRAM Ptr
	; This will be used calls from placeholder bits which don't update the value.
	xor  a									
	ld   h, a
	ret
	
; IN
; - 1: The completion bit to check
mEvChkClr: MACRO
	bit  \1, a
	jr   z, Map_WriteFullEv_OnLClearEnd
	call Map_WriteFullEv
	jr   Map_WriteFullEv_OnLClearEnd
ENDM

Map_WriteFullEv_OnL1Clear: mEvChkClr(1)
Map_WriteFullEv_OnL2Clear: mEvChkClr(2)
Map_WriteFullEv_OnL3Clear: mEvChkClr(3)
Map_WriteFullEv_OnL4Clear: mEvChkClr(4)
Map_WriteFullEv_OnL5Clear: mEvChkClr(5)
Map_WriteFullEv_OnL6Clear: mEvChkClr(6)
Map_WriteFullEv_OnL7Clear: mEvChkClr(7)
	
; =============== Map_WriteFullEv ===============
; Writes to the tilemap the entirety of the specified map event data in one go.
;
; This is mostly used to instantly draw paths over the map, but they can also be used for other map changes (ie: Parsley Woods' lake).
; Remember this is distinct from the way paths are revealed.
;
; IN
; - BC: Ptr to table of tile IDs to use.
; - HL: Ptr to table VRAM ptrs to a tilemap (where to place the aforemented tile ID)
Map_WriteFullEv:
	; Check if we reached the end separator for the tables
	
	; [TCRF] Non-obvious sanity check related to placeholder entries.
	;
	; This catches calls to Map_WriteFullEv_OnL?Clear from dummy completion bit values (for submaps with less than 8 exits).
	; It works because any time a Map_WriteFullEv_OnL?Clear subroutine returns, it will set H to $00 (see Map_WriteFullEv_OnLClearEnd)
	; and the calls from dummy entries don't update the HL value.
	; 
	; Though this only matters if (somehow) the completion bit for the dummy level is set
	; This check is also absent in the BANK $14 copy of the subroutine... so there's that.
	ld   a, h
	and  a			
	ret  z
	
	ld   a, [bc]
	cp   a, $FF
	ret  z
	
	ldi  a, [hl]	; DE = VRAM offset
	ld   d, a
	ldi  a, [hl]
	ld   e, a
	ld   a, [bc]	; A = Tile ID
	ld   [de], a	; Copy the tile to the tilemap
	inc  bc			
	
	jr   Map_WriteFullEv
	
; =============== Map_RiceBeach_CheckEv ===============
; Sets of functions apply the patch tilemaps instantly if the respective levels are completed.
;
; Each submap has its own subroutine, but they all work the same essentially.
Map_RiceBeach_CheckEv:
	ld   a, [sMapRiceBeachCompletion]
	ld   bc, Ev_Map_C01Clear_Tiles
	ld   hl, Ev_Map_C01Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapRiceBeachCompletion]
	ld   bc, Ev_Map_C02Clear_Tiles
	ld   hl, Ev_Map_C02Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapRiceBeachCompletion]
	ld   bc, Ev_Map_C03Clear_Tiles
	ld   hl, Ev_Map_C03Clear_Offsets
	call Map_WriteFullEv_OnL2Clear
	ld   a, [sMapRiceBeachCompletion]
	ld   bc, Ev_Map_C03ClearAlt_Tiles
	ld   hl, Ev_Map_C03ClearAlt_Offsets
	call Map_WriteFullEv_OnL3Clear
	ld   a, [sMapRiceBeachCompletion]
	ld   bc, Ev_Map_C04Clear_Tiles
	ld   hl, Ev_Map_C04Clear_Offsets
	call Map_WriteFullEv_OnL4Clear
	; [TCRF] Because the tilemap is switched after clearing C05, this is never applied
	ld   a, [sMapRiceBeachCompletion]
	ld   bc, Ev_Unused_Map_C05Clear_Tiles
	ld   hl, Ev_Unused_Map_C05Clear_Offsets
	call Map_WriteFullEv_OnL5Clear
	ret
	; [TCRF] Dummy entries
	ld   a, [sMapRiceBeachCompletion]
	call Map_WriteFullEv_OnL6Clear
	ld   a, [sMapRiceBeachCompletion]
	call Map_WriteFullEv_OnL7Clear
	ret
	
; =============== Map_RiceBeach_CheckLastEv ===============
; Essentially identical to the above, 
; but used for drawing all the old open paths before the path reveal anim starta.
;
; The normal completion value can't be used as it would draw the path immediately,
; so a separate "Last Completion" value is used to remember the opened paths before the level was cleared.
; Of course, this address is synched with the real completion value once the animation ends.

Map_RiceBeach_CheckLastEv:
	ld   a, [sMapRiceBeachCompletionLast]
	ld   bc, Ev_Map_C01Clear_Tiles
	ld   hl, Ev_Map_C01Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapRiceBeachCompletionLast]
	ld   bc, Ev_Map_C02Clear_Tiles
	ld   hl, Ev_Map_C02Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapRiceBeachCompletionLast]
	ld   bc, Ev_Map_C03Clear_Tiles
	ld   hl, Ev_Map_C03Clear_Offsets
	call Map_WriteFullEv_OnL2Clear
	ld   a, [sMapRiceBeachCompletionLast]
	ld   bc, Ev_Map_C03ClearAlt_Tiles
	ld   hl, Ev_Map_C03ClearAlt_Offsets
	call Map_WriteFullEv_OnL3Clear
	ld   a, [sMapRiceBeachCompletionLast]
	ld   bc, Ev_Map_C04Clear_Tiles
	ld   hl, Ev_Map_C04Clear_Offsets
	call Map_WriteFullEv_OnL4Clear
	; [TCRF] Because the tilemap is switched after clearing C05, this is never applied
	ld   a, [sMapRiceBeachCompletionLast]
	ld   bc, Ev_Unused_Map_C05Clear_Tiles
	ld   hl, Ev_Unused_Map_C05Clear_Offsets
	call Map_WriteFullEv_OnL5Clear
	ret
	; [TCRF] Dummy entries
	ld   a, [sMapRiceBeachCompletionLast]
	call Map_WriteFullEv_OnL6Clear
	ld   a, [sMapRiceBeachCompletionLast]
	call Map_WriteFullEv_OnL7Clear
	ret
Ev_Map_C01Clear_Tiles:		INCBIN "data/event/ricebeach_c01.evt"
Ev_Map_C01Clear_Offsets:	INCBIN "data/event/ricebeach_c01.evp"
Ev_Map_C02Clear_Tiles:		INCBIN "data/event/ricebeach_c02.evt"
Ev_Map_C02Clear_Offsets:	INCBIN "data/event/ricebeach_c02.evp"
Ev_Map_C03Clear_Tiles:		INCBIN "data/event/ricebeach_c03.evt"
Ev_Map_C03Clear_Offsets:	INCBIN "data/event/ricebeach_c03.evp"
Ev_Map_C03ClearAlt_Tiles:	INCBIN "data/event/ricebeach_c03_alt.evt"
Ev_Map_C03ClearAlt_Offsets:	INCBIN "data/event/ricebeach_c03_alt.evp"
Ev_Map_C04Clear_Tiles:		INCBIN "data/event/ricebeach_c04.evt"
Ev_Map_C04Clear_Offsets:	INCBIN "data/event/ricebeach_c04.evp"
Ev_Unused_Map_C05Clear_Tiles:	INCBIN "data/event/ricebeach_unused_c05.evt"
Ev_Unused_Map_C05Clear_Offsets:	INCBIN "data/event/ricebeach_unused_c05.evp"
; =============== Map_MtTeapot_CheckEv ===============
Map_MtTeapot_CheckEv:
	ld   a, [sMapMtTeapotCompletion]
	ld   bc, Ev_Map_C07Clear_Tiles
	ld   hl, Ev_Map_C07Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapMtTeapotCompletion]
	ld   bc, Ev_Map_C08Clear_Tiles
	ld   hl, Ev_Map_C08Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapMtTeapotCompletion]
	ld   bc, Ev_Map_C08ClearAlt_Tiles
	ld   hl, Ev_Map_C08ClearAlt_Offsets
	call Map_WriteFullEv_OnL2Clear
	ld   a, [sMapMtTeapotCompletion]
	ld   bc, Ev_Map_C09Clear_Tiles
	ld   hl, Ev_Map_C09Clear_Offsets
	call Map_WriteFullEv_OnL3Clear
	ld   a, [sMapMtTeapotCompletion]
	ld   bc, Ev_Map_C10Clear_Tiles
	ld   hl, Ev_Map_C10Clear_Offsets
	call Map_WriteFullEv_OnL4Clear
	ld   a, [sMapMtTeapotCompletion]
	ld   bc, Ev_Map_C11Clear_Tiles
	ld   hl, Ev_Map_C11Clear_Offsets
	call Map_WriteFullEv_OnL5Clear
	ld   a, [sMapMtTeapotCompletion]
	ld   bc, Ev_Map_C12Clear_Tiles
	ld   hl, Ev_Map_C12Clear_Offsets
	call Map_WriteFullEv_OnL6Clear
	ld   a, [sMapMtTeapotCompletion]
	ld   bc, Ev_Map_C13Clear_Tiles
	ld   hl, Ev_Map_C13Clear_Offsets
	call Map_WriteFullEv_OnL7Clear
	ret
; =============== Map_MtTeapot_CheckLastEv ===============
Map_MtTeapot_CheckLastEv:
	ld   a, [sMapMtTeapotCompletionLast]
	ld   bc, Ev_Map_C07Clear_Tiles
	ld   hl, Ev_Map_C07Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapMtTeapotCompletionLast]
	ld   bc, Ev_Map_C08Clear_Tiles
	ld   hl, Ev_Map_C08Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapMtTeapotCompletionLast]
	ld   bc, Ev_Map_C08ClearAlt_Tiles
	ld   hl, Ev_Map_C08ClearAlt_Offsets
	call Map_WriteFullEv_OnL2Clear
	ld   a, [sMapMtTeapotCompletionLast]
	ld   bc, Ev_Map_C09Clear_Tiles
	ld   hl, Ev_Map_C09Clear_Offsets
	call Map_WriteFullEv_OnL3Clear
	ld   a, [sMapMtTeapotCompletionLast]
	ld   bc, Ev_Map_C10Clear_Tiles
	ld   hl, Ev_Map_C10Clear_Offsets
	call Map_WriteFullEv_OnL4Clear
	ld   a, [sMapMtTeapotCompletionLast]
	ld   bc, Ev_Map_C11Clear_Tiles
	ld   hl, Ev_Map_C11Clear_Offsets
	call Map_WriteFullEv_OnL5Clear
	ld   a, [sMapMtTeapotCompletionLast]
	call Map_WriteFullEv_OnL6Clear
	ld   a, [sMapMtTeapotCompletionLast]
	call Map_WriteFullEv_OnL7Clear
	ret
	
Ev_Map_C07Clear_Tiles:       INCBIN "data/event/mtteapot_c07.evt" 
Ev_Map_C07Clear_Offsets:     INCBIN "data/event/mtteapot_c07.evp" 
Ev_Map_C08Clear_Tiles:       INCBIN "data/event/mtteapot_c08.evt" 
Ev_Map_C08Clear_Offsets:     INCBIN "data/event/mtteapot_c08.evp" 
Ev_Map_C08ClearAlt_Tiles:    INCBIN "data/event/mtteapot_c08_alt.evt"
Ev_Map_C08ClearAlt_Offsets:  INCBIN "data/event/mtteapot_c08_alt.evp"
Ev_Map_C09Clear_Tiles:       INCBIN "data/event/mtteapot_c09.evt" 
Ev_Map_C09Clear_Offsets:     INCBIN "data/event/mtteapot_c09.evp" 
Ev_Map_C10Clear_Tiles:       INCBIN "data/event/mtteapot_c10.evt" 
Ev_Map_C10Clear_Offsets:     INCBIN "data/event/mtteapot_c10.evp" 
Ev_Map_C11Clear_Tiles:       INCBIN "data/event/mtteapot_c11.evt" 
Ev_Map_C11Clear_Offsets:     INCBIN "data/event/mtteapot_c11.evp" 
Ev_Map_C12Clear_Tiles:       INCBIN "data/event/mtteapot_c12.evt" 
Ev_Map_C12Clear_Offsets:     INCBIN "data/event/mtteapot_c12.evp" 
Ev_Map_C13Clear_Tiles:       INCBIN "data/event/mtteapot_c13.evt" 
Ev_Map_C13Clear_Offsets:     INCBIN "data/event/mtteapot_c13.evp" 

; =============== Map_StoveCanyon_CheckEv ===============
Map_StoveCanyon_CheckEv:
	ld   a, [sMapStoveCanyonCompletion]
	ld   bc, Ev_Map_C20Clear_Tiles
	ld   hl, Ev_Map_C20Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapStoveCanyonCompletion]
	ld   bc, Ev_Map_C21Clear_Tiles
	ld   hl, Ev_Map_C21Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapStoveCanyonCompletion]
	ld   bc, Ev_Map_C22Clear_Tiles
	ld   hl, Ev_Map_C22Clear_Offsets
	call Map_WriteFullEv_OnL2Clear
	ld   a, [sMapStoveCanyonCompletion]
	ld   bc, Ev_Map_C23Clear_Tiles
	ld   hl, Ev_Map_C23Clear_Offsets
	call Map_WriteFullEv_OnL3Clear
	ld   a, [sMapStoveCanyonCompletion]
	ld   bc, Ev_Map_C23ClearAlt_Tiles
	ld   hl, Ev_Map_C23ClearAlt_Offsets
	call Map_WriteFullEv_OnL4Clear
	ld   a, [sMapStoveCanyonCompletion]
	call Map_WriteFullEv_OnL5Clear
	ld   a, [sMapStoveCanyonCompletion]
	ld   bc, Ev_Map_C24Clear_Tiles
	ld   hl, Ev_Map_C24Clear_Offsets
	call Map_WriteFullEv_OnL6Clear
	ld   a, [sMapStoveCanyonCompletion]
	call Map_WriteFullEv_OnL7Clear
	ret
; =============== Map_StoveCanyon_CheckLastEv ===============
Map_StoveCanyon_CheckLastEv:
	ld   a, [sMapStoveCanyonCompletionLast]
	ld   bc, Ev_Map_C20Clear_Tiles
	ld   hl, Ev_Map_C20Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapStoveCanyonCompletionLast]
	ld   bc, Ev_Map_C21Clear_Tiles
	ld   hl, Ev_Map_C21Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapStoveCanyonCompletionLast]
	ld   bc, Ev_Map_C22Clear_Tiles
	ld   hl, Ev_Map_C22Clear_Offsets
	call Map_WriteFullEv_OnL2Clear
	ld   a, [sMapStoveCanyonCompletionLast]
	ld   bc, Ev_Map_C23Clear_Tiles
	ld   hl, Ev_Map_C23Clear_Offsets
	call Map_WriteFullEv_OnL3Clear
	ld   a, [sMapStoveCanyonCompletionLast]
	ld   bc, Ev_Map_C23ClearAlt_Tiles
	ld   hl, Ev_Map_C23ClearAlt_Offsets
	call Map_WriteFullEv_OnL4Clear
	ret
	; [TCRF] Dummy level entries
	ld   a, [sMapStoveCanyonCompletionLast]
	call Map_WriteFullEv_OnL5Clear
	ld   a, [sMapStoveCanyonCompletionLast]
	call Map_WriteFullEv_OnL6Clear
	ld   a, [sMapStoveCanyonCompletionLast]
	call Map_WriteFullEv_OnL7Clear
	ret
Ev_Map_C20Clear_Tiles:      INCBIN "data/event/stovecanyon_c20.evt" 
Ev_Map_C20Clear_Offsets:    INCBIN "data/event/stovecanyon_c20.evp" 
Ev_Map_C21Clear_Tiles:      INCBIN "data/event/stovecanyon_c21.evt" 
Ev_Map_C21Clear_Offsets:    INCBIN "data/event/stovecanyon_c21.evp" 
Ev_Map_C22Clear_Tiles:      INCBIN "data/event/stovecanyon_c22.evt" 
Ev_Map_C22Clear_Offsets:    INCBIN "data/event/stovecanyon_c22.evp" 
Ev_Map_C23Clear_Tiles:      INCBIN "data/event/stovecanyon_c23.evt" 
Ev_Map_C23Clear_Offsets:    INCBIN "data/event/stovecanyon_c23.evp" 
Ev_Map_C23ClearAlt_Tiles:   INCBIN "data/event/stovecanyon_c23_alt.evt" 
Ev_Map_C23ClearAlt_Offsets: INCBIN "data/event/stovecanyon_c23_alt.evp" 
Ev_Map_C24Clear_Tiles:      INCBIN "data/event/stovecanyon_c24.evt" 
Ev_Map_C24Clear_Offsets:    INCBIN "data/event/stovecanyon_c24.evp" 
; =============== Map_SSTeacup_CheckEv ===============
Map_SSTeacup_CheckEv:
	ld   a, [sMapSSTeacupCompletion]
	ld   bc, Ev_Map_C26Clear_Tiles
	ld   hl, Ev_Map_C26Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapSSTeacupCompletion]
	ld   bc, Ev_Map_C27Clear_Tiles
	ld   hl, Ev_Map_C27Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapSSTeacupCompletion]
	ld   bc, Ev_Map_C28Clear_Tiles
	ld   hl, Ev_Map_C28Clear_Offsets
	call Map_WriteFullEv_OnL2Clear
	ld   a, [sMapSSTeacupCompletion]
	ld   bc, Ev_Map_C29Clear_Tiles
	ld   hl, Ev_Map_C29Clear_Offsets
	call Map_WriteFullEv_OnL3Clear
	ld   a, [sMapSSTeacupCompletion]
	ld   bc, Ev_Map_C30Clear_Tiles
	ld   hl, Ev_Map_C30Clear_Offsets
	call Map_WriteFullEv_OnL4Clear
	ld   a, [sMapSSTeacupCompletion]
	call Map_WriteFullEv_OnL5Clear
	ld   a, [sMapSSTeacupCompletion]
	call Map_WriteFullEv_OnL6Clear
	ld   a, [sMapSSTeacupCompletion]
	call Map_WriteFullEv_OnL7Clear
	ret
; =============== Map_SSTeacup_CheckLastEv ===============
Map_SSTeacup_CheckLastEv:
	ld   a, [sMapSSTeacupCompletionLast]
	ld   bc, Ev_Map_C26Clear_Tiles
	ld   hl, Ev_Map_C26Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapSSTeacupCompletionLast]
	ld   bc, Ev_Map_C27Clear_Tiles
	ld   hl, Ev_Map_C27Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapSSTeacupCompletionLast]
	ld   bc, Ev_Map_C28Clear_Tiles
	ld   hl, Ev_Map_C28Clear_Offsets
	call Map_WriteFullEv_OnL2Clear
	ld   a, [sMapSSTeacupCompletionLast]
	ld   bc, Ev_Map_C29Clear_Tiles
	ld   hl, Ev_Map_C29Clear_Offsets
	call Map_WriteFullEv_OnL3Clear
	ld   a, [sMapSSTeacupCompletionLast]
	call Map_WriteFullEv_OnL4Clear
	ld   a, [sMapSSTeacupCompletionLast]
	call Map_WriteFullEv_OnL5Clear
	ld   a, [sMapSSTeacupCompletionLast]
	call Map_WriteFullEv_OnL6Clear
	ld   a, [sMapSSTeacupCompletionLast]
	call Map_WriteFullEv_OnL7Clear
	ret
Ev_Map_C26Clear_Tiles:   INCBIN "data/event/ssteacup_c26.evt"
Ev_Map_C26Clear_Offsets: INCBIN "data/event/ssteacup_c26.evp"
Ev_Map_C27Clear_Tiles:   INCBIN "data/event/ssteacup_c27.evt"
Ev_Map_C27Clear_Offsets: INCBIN "data/event/ssteacup_c27.evp"
Ev_Map_C28Clear_Tiles:   INCBIN "data/event/ssteacup_c28.evt"
Ev_Map_C28Clear_Offsets: INCBIN "data/event/ssteacup_c28.evp"
Ev_Map_C29Clear_Tiles:   INCBIN "data/event/ssteacup_c29.evt"
Ev_Map_C29Clear_Offsets: INCBIN "data/event/ssteacup_c29.evp"
Ev_Map_C30Clear_Tiles:   INCBIN "data/event/ssteacup_c30.evt"
Ev_Map_C30Clear_Offsets: INCBIN "data/event/ssteacup_c30.evp"
; =============== Map_ParsleyWoods_CheckEv ===============
Map_ParsleyWoods_CheckEv:
	ld   a, [sMapParsleyWoodsCompletion]
	ld   bc, Ev_Map_C31Clear_Tiles
	ld   hl, Ev_Map_C31Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapParsleyWoodsCompletion]
	ld   bc, Ev_Map_C32Clear_Tiles
	ld   hl, Ev_Map_C32Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapParsleyWoodsCompletion]
	ld   bc, Ev_Map_C33Clear_Tiles
	ld   hl, Ev_Map_C33Clear_Offsets
	call Map_WriteFullEv_OnL2Clear
	ld   a, [sMapParsleyWoodsCompletion]
	ld   bc, Ev_Map_C34Clear_Tiles
	ld   hl, Ev_Map_C34Clear_Offsets
	call Map_WriteFullEv_OnL3Clear
	ld   a, [sMapParsleyWoodsCompletion]
	ld   bc, Ev_Map_C35Clear_Tiles
	ld   hl, Ev_Map_C35Clear_Offsets
	call Map_WriteFullEv_OnL4Clear
	ld   a, [sMapParsleyWoodsCompletion]
	ld   bc, Ev_Map_C36Clear_Tiles
	ld   hl, Ev_Map_C36Clear_Offsets
	call Map_WriteFullEv_OnL5Clear
	ld   a, [sMapParsleyWoodsCompletion]
	call Map_WriteFullEv_OnL6Clear
	ld   a, [sMapParsleyWoodsCompletion]
	call Map_WriteFullEv_OnL7Clear
	; This is here, after the end of all normal paths.
	; Interestingly, the drained C31 is the last level by ID, indicating it may have been a later addition.
	ld   a, [sMapParsleyWoodsCompletion]
	ld   bc, Ev_Map_ParsleyWoodsDrainedLake_Tiles
	ld   hl, Ev_Map_ParsleyWoodsDrainedLake_Offsets
	call Map_WriteFullEv_OnL1Clear
	ret
; =============== Map_ParsleyWoods_CheckLastEv ===============
Map_ParsleyWoods_CheckLastEv:
	ld   a, [sMapParsleyWoodsCompletionLast]
	ld   bc, Ev_Map_C31Clear_Tiles
	ld   hl, Ev_Map_C31Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapParsleyWoodsCompletionLast]
	ld   bc, Ev_Map_C32Clear_Tiles
	ld   hl, Ev_Map_C32Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapParsleyWoodsCompletionLast]
	ld   bc, Ev_Map_C33Clear_Tiles
	ld   hl, Ev_Map_C33Clear_Offsets
	call Map_WriteFullEv_OnL2Clear
	ld   a, [sMapParsleyWoodsCompletionLast]
	ld   bc, Ev_Map_C34Clear_Tiles
	ld   hl, Ev_Map_C34Clear_Offsets
	call Map_WriteFullEv_OnL3Clear
	ld   a, [sMapParsleyWoodsCompletionLast]
	ld   bc, Ev_Map_C35Clear_Tiles
	ld   hl, Ev_Map_C35Clear_Offsets
	call Map_WriteFullEv_OnL4Clear
	ld   a, [sMapParsleyWoodsCompletionLast]
	call Map_WriteFullEv_OnL5Clear
	ld   a, [sMapParsleyWoodsCompletionLast]
	call Map_WriteFullEv_OnL6Clear
	ld   a, [sMapParsleyWoodsCompletionLast]
	call Map_WriteFullEv_OnL7Clear
	ld   a, [sMapParsleyWoodsCompletion]
	ld   bc, Ev_Map_ParsleyWoodsDrainedLake_Tiles
	ld   hl, Ev_Map_ParsleyWoodsDrainedLake_Offsets
	call Map_WriteFullEv_OnL1Clear
	ret
Ev_Map_C31Clear_Tiles:                   INCBIN "data/event/parsleywoods_c31.evt" 
Ev_Map_C31Clear_Offsets:                 INCBIN "data/event/parsleywoods_c31.evp" 
Ev_Map_C32Clear_Tiles:                   INCBIN "data/event/parsleywoods_c32.evt" 
Ev_Map_C32Clear_Offsets:                 INCBIN "data/event/parsleywoods_c32.evp" 
Ev_Map_C33Clear_Tiles:                   INCBIN "data/event/parsleywoods_c33.evt" 
Ev_Map_C33Clear_Offsets:                 INCBIN "data/event/parsleywoods_c33.evp" 
Ev_Map_C34Clear_Tiles:                   INCBIN "data/event/parsleywoods_c34.evt" 
Ev_Map_C34Clear_Offsets:                 INCBIN "data/event/parsleywoods_c34.evp" 
Ev_Map_C35Clear_Tiles:                   INCBIN "data/event/parsleywoods_c35.evt" 
Ev_Map_C35Clear_Offsets:                 INCBIN "data/event/parsleywoods_c35.evp" 
Ev_Map_C36Clear_Tiles:                   INCBIN "data/event/parsleywoods_c36.evt" 
Ev_Map_C36Clear_Offsets:                 INCBIN "data/event/parsleywoods_c36.evp" 
Ev_Map_ParsleyWoodsDrainedLake_Tiles:    INCBIN "data/event/parsleywoods_drainedlake.evt"
Ev_Map_ParsleyWoodsDrainedLake_Offsets:  INCBIN "data/event/parsleywoods_drainedlake.evp"
; =============== Map_SherbetLand_CheckEv ===============
Map_SherbetLand_CheckEv:
	ld   a, [sMapSherbetLandCompletion]
	ld   bc, Ev_Map_C14Clear_Tiles
	ld   hl, Ev_Map_C14Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapSherbetLandCompletion]
	ld   bc, Ev_Map_C15Clear_Tiles
	ld   hl, Ev_Map_C15Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapSherbetLandCompletion]
	ld   bc, Ev_Map_C15ClearAlt_Tiles
	ld   hl, Ev_Map_C15ClearAlt_Offsets
	call Map_WriteFullEv_OnL2Clear
	ld   a, [sMapSherbetLandCompletion]
	ld   bc, Ev_Map_C16Clear_Tiles
	ld   hl, Ev_Map_C16Clear_Offsets
	call Map_WriteFullEv_OnL3Clear
	ld   a, [sMapSherbetLandCompletion]
	ld   bc, Ev_Map_C16ClearAlt_Tiles
	ld   hl, Ev_Map_C16ClearAlt_Offsets
	call Map_WriteFullEv_OnL4Clear
	ld   a, [sMapSherbetLandCompletion]
	ld   bc, Ev_Map_C17Clear_Tiles
	ld   hl, Ev_Map_C17Clear_Offsets
	call Map_WriteFullEv_OnL5Clear
	ld   a, [sMapSherbetLandCompletion]
	call Map_WriteFullEv_OnL6Clear
	ld   a, [sMapSherbetLandCompletion]
	call Map_WriteFullEv_OnL7Clear
	ret
; =============== Map_SherbetLand_CheckLastEv ===============
Map_SherbetLand_CheckLastEv:
	ld   a, [sMapSherbetLandCompletionLast]
	ld   bc, Ev_Map_C14Clear_Tiles
	ld   hl, Ev_Map_C14Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapSherbetLandCompletionLast]
	ld   bc, Ev_Map_C15Clear_Tiles
	ld   hl, Ev_Map_C15Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapSherbetLandCompletionLast]
	ld   bc, Ev_Map_C15ClearAlt_Tiles
	ld   hl, Ev_Map_C15ClearAlt_Offsets
	call Map_WriteFullEv_OnL2Clear
	ld   a, [sMapSherbetLandCompletionLast]
	ld   bc, Ev_Map_C16Clear_Tiles
	ld   hl, Ev_Map_C16Clear_Offsets
	call Map_WriteFullEv_OnL3Clear
	ld   a, [sMapSherbetLandCompletionLast]
	ld   bc, Ev_Map_C16ClearAlt_Tiles
	ld   hl, Ev_Map_C16ClearAlt_Offsets
	call Map_WriteFullEv_OnL4Clear
	ld   a, [sMapSherbetLandCompletionLast]
	ld   bc, Ev_Map_C17Clear_Tiles
	ld   hl, Ev_Map_C17Clear_Offsets
	call Map_WriteFullEv_OnL5Clear
	ld   a, [sMapSherbetLandCompletionLast]
	call Map_WriteFullEv_OnL6Clear
	ld   a, [sMapSherbetLandCompletionLast]
	call Map_WriteFullEv_OnL7Clear
	ret
Ev_Map_C14Clear_Tiles:      INCBIN "data/event/sherbetland_c14.evt" 
Ev_Map_C14Clear_Offsets:    INCBIN "data/event/sherbetland_c14.evp" 
Ev_Map_C15Clear_Tiles:      INCBIN "data/event/sherbetland_c15.evt" 
Ev_Map_C15Clear_Offsets:    INCBIN "data/event/sherbetland_c15.evp" 
Ev_Map_C15ClearAlt_Tiles:   INCBIN "data/event/sherbetland_c15_alt.evt"
Ev_Map_C15ClearAlt_Offsets: INCBIN "data/event/sherbetland_c15_alt.evp"
Ev_Map_C16Clear_Tiles:      INCBIN "data/event/sherbetland_c16.evt" 
Ev_Map_C16Clear_Offsets:    INCBIN "data/event/sherbetland_c16.evp" 
Ev_Map_C16ClearAlt_Tiles:   INCBIN "data/event/sherbetland_c16_alt.evt"
Ev_Map_C16ClearAlt_Offsets: INCBIN "data/event/sherbetland_c16_alt.evp"
Ev_Map_C17Clear_Tiles:      INCBIN "data/event/sherbetland_c17.evt" 
Ev_Map_C17Clear_Offsets:    INCBIN "data/event/sherbetland_c17.evp" 

; =============== Map_SyrupCastle_CheckEv ===============
Map_SyrupCastle_CheckEv:
	ld   a, [sMapSyrupCastleCompletion]
	ld   bc, Ev_Map_C37Clear_Tiles
	ld   hl, Ev_Map_C37Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapSyrupCastleCompletion]
	ld   bc, Ev_Map_C38Clear_Tiles
	ld   hl, Ev_Map_C38Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapSyrupCastleCompletion]
	ld   bc, Ev_Map_C39Clear_Tiles
	ld   hl, Ev_Map_C39Clear_Offsets
	call Map_WriteFullEv_OnL2Clear
	call HomeCall_Map_SyrupCastle_RemovePath
	ret
; =============== Map_SyrupCastle_CheckLastEv ===============
Map_SyrupCastle_CheckLastEv:
	ld   a, [sMapSyrupCastleCompletionLast]
	ld   bc, Ev_Map_C37Clear_Tiles
	ld   hl, Ev_Map_C37Clear_Offsets
	call Map_WriteFullEv_OnL0Clear
	ld   a, [sMapSyrupCastleCompletionLast]
	ld   bc, Ev_Map_C38Clear_Tiles
	ld   hl, Ev_Map_C38Clear_Offsets
	call Map_WriteFullEv_OnL1Clear
	ld   a, [sMapSyrupCastleCompletionLast]
	ld   bc, Ev_Map_C39Clear_Tiles
	ld   hl, Ev_Map_C39Clear_Offsets
	call Map_WriteFullEv_OnL2Clear
	ld   a, [sMapSyrupCastleCompletionLast]
	call Map_WriteFullEv_OnL3Clear
	ld   a, [sMapSyrupCastleCompletionLast]
	call Map_WriteFullEv_OnL4Clear
	ld   a, [sMapSyrupCastleCompletionLast]
	call Map_WriteFullEv_OnL5Clear
	ld   a, [sMapSyrupCastleCompletionLast]
	call Map_WriteFullEv_OnL6Clear
	ld   a, [sMapSyrupCastleCompletionLast]
	call Map_WriteFullEv_OnL7Clear
	ret
Ev_Map_C37Clear_Tiles:           INCBIN "data/event/syrupcastle_c37.evt"
Ev_Map_C37Clear_Offsets:         INCBIN "data/event/syrupcastle_c37.evp"
Ev_Map_C38Clear_Tiles:           INCBIN "data/event/syrupcastle_c38.evt"
Ev_Map_C38ClearPathOnly_Tiles:   INCBIN "data/event/syrupcastle_c38_path.evt"
Ev_Map_C38Clear_Offsets:         INCBIN "data/event/syrupcastle_c38.evp"
Ev_Map_C38ClearPathOnly_Offsets: INCBIN "data/event/syrupcastle_c38_path.evp"
Ev_Map_C39Clear_Tiles:           INCBIN "data/event/syrupcastle_c39.evt"
Ev_Map_C39ClearPathOnly_Tiles:   INCBIN "data/event/syrupcastle_c39_path.evt"
Ev_Map_C39Clear_Offsets:         INCBIN "data/event/syrupcastle_c39.evp"
Ev_Map_C39ClearPathOnly_Offsets: INCBIN "data/event/syrupcastle_c39_path.evp"
; =============== Map_RiceBeach_DoLevelClear ===============
; Handles the path reveal animation for Rice Beach.
Map_RiceBeach_DoLevelClear:
	; Requires level clear mode to be set, obviously
	ld   a, [sMapLevelClear]
	and  a
	ret  z
	;--
	; Always perform tile/sprite anims, even when waiting for tiles
	call Map_RiceBeach_AnimTiles
	call Map_WriteWarioOBJLst
	
	; Process a new tile every $10 frames
	ld   a, [sMapTimer_Low]
	and  a, $0F
	ret  nz
	;--
	; For every new tile to place
	
	ld   a, SFX1_22
	ld   [sSFX1Set], a
	call .getEvPtrs			
	call .setEvTile
	call Map_SetEvOffset
	ld   hl, sMapEvIndex
	inc  [hl]
.end:
	ret
; =============== .endPathReveal ===============
; Ends the path reveal anim for Rice Beach.
.endPathReveal:
	; Reset the index
	ld   hl, sMapEvIndex
	xor  a
	ld   [hl], a
	ld   [sMapLevelClear], a
	; Sync the completion statuses
	ld   de, sMapRiceBeachCompletionLast
	ld   bc, sMap_Unused_RiceBeachCompletionHighLast
	ld   a, [sMapRiceBeachCompletion]
	ld   l, a
	ld   a, [sMap_Unused_RiceBeachCompletionHigh]
	ld   h, a
	call Map_SyncCompletionStatus
	; Determine where to move for the revealed path
	ld   hl, Map_RiceBeach_AutoMoveTbl
	call Map_SetAutoMove
	ld   a, SFX1_03
	ld   [sSFX1Set], a
	jr   .end
; =============== .getEvPtrs ===============
; Prepares a call to Map_PathReveal_GetEvPtrs with the data of Rice Beach.
.getEvPtrs:
	ld   a, [sMapRiceBeachCompletionLast]
	ld   b, a
	ld   a, [sMapRiceBeachCompletion]
	ld   c, a
	ld   a, [sMap_Unused_RiceBeachCompletionHighLast]
	ld   d, a
	ld   a, [sMap_Unused_RiceBeachCompletionHigh]
	ld   e, a
	ld   hl, EvDef_Map_RiceBeach
	call Map_PathReveal_GetEvPtrs
	; If it points to a null entry, automatically end the path reveal anim.
	jr   z, .endPathReveal 
	ret
; =============== .setEvTile ===============
; Indexes the event Tiles table and sets the current Tile ID for the event.
; If we go past the last entry, it ends the path reveal anim.
.setEvTile:
	call Map_IndexEvTile
	jr   z, .endPathReveal
	ld   [de], a	; sMapEvTileId = TileId
	ret
; =============== Map_SetEvOffset ===============
; Indexes the event Offsets table and sets the current VRAM Offset for the event.
Map_SetEvOffset:
	; HL = Ptr to offset table base
	ld   a, [sMapEvOffsetTablePtr_High]	
	ld   h, a
	ld   a, [sMapEvOffsetTablePtr_Low]
	ld   l, a
	
	; BC = Ptr to VRAM Target
	ld   bc, sMapEvBGPtr				
	
	; Index the VRAM offset from the table
	xor  a
	ld   d, a
	ld   a, [sMapEvIndex]
	add  a
	ld   e, a	; DE = MapSectIndex * 2			
	add  hl, de
	
	; Copy the offset we've got to sMapEvBGPtr
	ldi  a, [hl]	
	ld   [bc], a
	ld   a, [hl]
	inc  bc
	ld   [bc], a
	ret
	
; =============== mFindBitNum ===============
; Gets the number of the first bit set.
; IN
; - C: Bitmask
; - 1: Where to jump once the bit is found
; OUT
; - E: Bit number
mFindBitNum: MACRO
	xor  a
	ld   d, a	; DE = $00
	ld   e, a	
	ld   b, a	; B  = $00
\1_loop:
	bit  0, c			; Is this bit set?
	jr   nz, \1			; If so, we're done
	srl  c				; Check next Bit
	inc  e				; E++;
	jr   \1_loop
ENDM
; =============== Map_SetAutoMove ===============
; Automatically moves the player to the newly created path.
; IN
; - HL: Ptr to AutoMove table with joypad keys to auto press
; -  B: Won level bitmask (high, unused)
; -  C: Won level bitmask (low)
Map_SetAutoMove:
	; The low bitmask is $00, use 
	ld   a, c
	and  a, c
	jr   z, .unused_useHigh

	; Get the level number from the bitmask
.useLow:
	mFindBitNum .lowFound
	
.lowFound:
	; The table setup is a bit weird.
	; The first 8 entries are for the unused high bitmask.
	; After that there are the entries for the normal levels
	ld   a, $08
	ld   c, a
	add  hl, bc
.highFound:
	; Index the AutoMove table
	add  hl, de
	ld   a, [hl]		; JoypadKeys = KeyTable[BitNumber]
	; If a key is specified update the key status
	and  a
	ret  z
	ldh  [hJoyNewKeys], a
	ret
.unused_useHigh: 
	ld   a, b            ; Set to C the high byte of the completion status
	ld   c, a            ; Which means the code and loop below can be identical to the one for the low byte
	mFindBitNum .highFound

; =============== AUTO MOVE TABLES ===============
; These tables define the joypad keys to press when a level exit is cleared.
;
; Each table has 16 entries, since it supports submaps with 16-exits, an unused feature.
; The first 8 entries point to levels 8-15.
; The last 8 entries point to levels 0-7.
Map_RiceBeach_AutoMoveTbl: 
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db KEY_RIGHT	; C1
	db KEY_LEFT		; C2
	db KEY_LEFT		; C3
	db KEY_UP		; C3 - Secondary
	db KEY_UP		; C4
	db $00			
	db $00			
	db $00

Map_MtTeapot_AutoMoveTbl:
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db KEY_LEFT		; C7
	db KEY_UP		; C8
	db KEY_LEFT		; C8 - Secondary
	db KEY_UP		; C9
	db KEY_RIGHT	; C10
	db KEY_DOWN		; C11
	db KEY_LEFT		; C12
	db $00

Map_StoveCanyon_AutoMoveTbl:
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db KEY_DOWN		; C20
	db KEY_RIGHT	; C21
	db KEY_DOWN		; C22
	db KEY_RIGHT	; C23
	db KEY_LEFT		; C23 - Secondary
	db $00
	db $00
	db $00

Map_SSTeacup_AutoMoveTbl:
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db KEY_DOWN		; C26
	db KEY_DOWN		; C27
	db KEY_RIGHT	; C28
	db KEY_RIGHT	; C29
	db $00
	db $00
	db $00
	db $00

Map_ParsleyWoods_AutoMoveTbl:
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db KEY_RIGHT	; C31
	db KEY_RIGHT	; C32
	db KEY_UP		; C33
	db KEY_LEFT		; C34
	db KEY_UP		; C35
	db $00
	db $00
	db $00

Map_SherbetLand_AutoMoveTbl:
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db KEY_LEFT		; C14
	db KEY_DOWN		; C15
	db KEY_LEFT		; C15 - Secondary
	db KEY_LEFT		; C16
	db KEY_RIGHT	; C16 - Secondary
	db KEY_DOWN		; C17
	db $00
	db $00

Map_SyrupCastle_AutoMoveTbl:
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db KEY_LEFT		; C37
	db KEY_UP		; C38
	db KEY_UP		; C39
	db $00
	db $00
	db $00
	db $00
	db $00

; =============== Map_IndexEvTile ===============
; Indexes the Ev Tiles table to get the current tile id to place.
;
; IN
; - BC: Ptr to Ev*_Tiles table
; OUT
; -  A: Tile ID
; - DE: Ptr to sMapEvTileId
; -  Z: If we went past the last table entry
Map_IndexEvTile:
	ld   de, sMapEvTileId
	;--
	xor  a					; HL = sMapEvIndex
	ld   h, a
	ld   a, [sMapEvIndex]
	ld   l, a
	add  hl, bc				; Index the Tiles table
	ld   a, [hl]			; Get the Tile ID
	cp   a, $FF				; Flag if it's the table end separator
	ret
; =============== Map_PathReveal_GetEvPtrs ===============
; This subroutine indexes an Ev map table based on the currently cleared level,
; and gets its pointers to the Tiles and Offsets table.
;
; IN
; -  B: Last submap completion status
; -  C: Submap completion status
; -  D: Last submap completion status (unused, high byte)
; -  E: Submap completion status (unused, high byte)
; - HL: Ptr to EvDef table (ie: EvDef_Map_RiceBeach)
; OUT
; - BC: Ptr to start of Ev Tiles table
; - sMapEvOffsetTablePtr: Ptr to start of Ev Offsets table
; -  Z: If set, the Ev points to a null entry
Map_PathReveal_GetEvPtrs:
	call Map_GetWonLevelNum	; A = EvDef Index
	call B8_IndexPtrTable	; Index it
	; Get the _Tiles ptr
	ldi  a, [hl]
	ld   c, a
	ldi  a, [hl]
	ld   b, a
	; Get the _Offsets ptr
	ldi  a, [hl]
	ld   [sMapEvOffsetTablePtr_Low], a
	ld   a, [hl]
	; Determine if this points to the dummy $FFFF Ev entry, which should be ignored
	cp   a, $FF 
	ld   [sMapEvOffsetTablePtr_High], a
	ret
	
; =============== Map_Unused_GetWonLevelNumHigh ===============
; [TCRF] This gets the index to use for an EvDef table when the level number > 8.
; IN
; - B: Last submap completion status
; - C: Submap completion status
; - D: Last submap completion status (unused, high byte)
; - E: Submap completion status (unused, high byte)
Map_Unused_GetWonLevelNumHigh: 
	; Replace the normal args with the respective "high byte" args
	ld   a, e            
	ld   c, a
	ld   a, d
	ld   b, a
	call Map_GetWonLevelNum
	; Offset by 8 as this is in the upper byte of the bitmask
	add  8            
	ret

; =============== Map_GetWonLevelNum ===============
; This subroutine gets the index to use for an EvDef table.
;
; This index is basically the won level number, as it has to match the bit number
; for the level in its submap completion bitmask.
;
; This is meant to be only called during the path reveal anim -- if
; there is no won level it will softlock.
;
; IN
; - B: Last submap completion status
; - C: Submap completion status
; - D: Last submap completion status (unused, high byte)
; - E: Submap completion status (unused, high byte)
; OUT
; - A: The won level number / EvDef table index
Map_GetWonLevelNum:
	; Get only the different bits between the two.
	; If there are none, check in the unused upper byte.
	ld   a, c	; Completion - CompletionLast
	sub  a, b
	jr   z, Map_Unused_GetWonLevelNumHigh
	
	; Convert the bit number to a normal number.
	bit  0, a
	jr   nz, .num0
	bit  1, a
	jr   nz, .num1
	bit  2, a
	jr   nz, .num2
	bit  3, a
	jr   nz, .num3
	bit  4, a
	jr   nz, .num4
	bit  5, a
	jr   nz, .num5
	bit  6, a
	jr   nz, .num6
	; [TCRF] We never get here -- the world clear cutscene gets in the way
	bit  7, a
	jr   nz, .unused_num7
	xor  a
	ret
.num0:
	ld   a, $00
	ret
.num1:
	ld   a, $01
	ret
.num2:
	ld   a, $02
	ret
.num3:
	ld   a, $03
	ret
.num4:
	ld   a, $04
	ret
.num5:
	ld   a, $05
	ret
.num6:
	ld   a, $06
	ret
.unused_num7:
	ld   a, $07
	ret
; =============== Map_SyncCompletionStatus ===============
; Syncronizes the last completion status with the main completion status.
;
; There are also other unused code paths when:
; - the upper bitmask needs to by synced (no submaps have > 8 levels)
; - no new levels are won (as this is only called when levels are beaten)
;
; IN
; - DE: Ptr to last completion status
; - BC: Ptr to last map completion status (high byte, unused)
; -  L: Map completion status
; -  H: Map completion status (high byte, unused)
; OUT
; - B: Won level bitmask (high, unused)
; - C: Won level bitmask
Map_SyncCompletionStatus:
	;--
	ld   a, d			; Save D... for some reason
	ld   [sTempA791], a
	;--
.checkLow:
	ld   a, [de]		
	ld   d, a			; D = Last completion status
	ld   a, l			; A = completion status
	sub  a, d			; Are they identical (no levels won)?
	jr   nz, .sync		; If not, jump

.unused_checkHigh:
	ld   a, [bc]
	ld   d, a			; D = last completion status (high)
	ld   a, h			; A = completion status (high)
	sub  d				; Are they identical (no levels won)?
	jr   z, .unused_noSync		; If not, jump
.unused_syncHigh:
	ld   d, a			; D = level number won
	; Syncronize the high completion
	ld   a, h			; A = H
	ld   [bc], a		; LastMapCompletion = H
	
	ld   a, d			; B = level number won
	ld   b, a			
	
	xor  a				; low = 00
	ld   c, a
	ret
	
.sync:
	ld   c, a			; C = level number won
	;--
	ld   a, [sTempA791]	; Restore D... for some reason
	ld   d, a
	;--
	; Syncronize the map completion status
	ld   a, l			
	ld   [de], a
	
	xor  a				; high = 00
	ld   b, a
	ret
	
.unused_noSync:
	; No new levels won
	xor  a		
	ld   c, a
	ld   b, a
	ret

; =============== Map_SetNextEvTile ===============
; Sets the currently specified tile for the path reveal animation.
; Usually it's to place path dots, but it can be used to place anything.
;
; Note this only applies for the path reveal animations.
; When entering a map, the event data is also applied, but it's done in one go through Map_WriteFullEv.
Map_SetNextEvTile:
	ld   bc, sMapEvTileId
	ld   hl, sMapEvBGPtr
	; Set DE to point to the VRAM offset of the current tile
	ldi  a, [hl]	
	cp   a, $00		; Is the first (high) byte $00 (separator)?
	ret  z			; If so, return
	ld   d, a		
	ld   a, [hl]
	ld   e, a
	
	ld   a, [bc]	; Get the tile ID
	ld   [de], a	; Set it to the VRAM address
	ret
	
; =============== Map_MtTeapot_DoLevelClear ===============
; Handles the path reveal animation for Mt. Teapot.
Map_MtTeapot_DoLevelClear:
	; Check for workaround fix post C12 clear
	ld   a, [sMapMtTeapotAutoMove]
	and  a, $F0
	jr   nz, Map_MtTeapot_DoLevelClear_C12Clear
	;--
	; Requires level clear mode to be set, obviously
	ld   a, [sMapLevelClear]
	and  a
	ret  z
	
	call Map_WriteWarioOBJLst
	
	; Process a new tile every $10 frames
	ld   a, [sMapTimer_Low]
	and  a, $0F
	ret  nz
	
	ld   a, SFX1_22
	ld   [sSFX1Set], a
	call Map_MtTeapot_GetEvPtrs
	call Map_MtTeapot_SetEvTile
	call Map_SetEvOffset
	ld   hl, sMapEvIndex
	inc  [hl]
Map_MtTeapot_DoLevelClear_End:
	ret
Map_MtTeapot_DoLevelClear_C12Clear:
	; Because we messed with the completion bit to show the updated event data all at once,
	; we now need to restore the original value. This makes normal automatic movement take place.
	;
	; It's especially important here because of how the path from C12 to C13 is set up.
	; Entering the level directly without moving to C13 will crash the game.
	ld   a, [sMapMtTeapotCompletionLast]
	and  a, $0F
	add  $30
	ld   [sMapMtTeapotCompletionLast], a
	
; =============== .Map_MtTeapot_EndPathReveal ===============
; Ends the path reveal anim.
Map_MtTeapot_EndPathReveal:
	; Reset the index
	ld   hl, sMapEvIndex
	xor  a
	ld   [hl], a
	
	ld   [sMapLevelClear], a
	ld   [sMapMtTeapotAutoMove], a
	
	; Sync the completion statuses
	ld   de, sMapMtTeapotCompletionLast
	ld   bc, sMap_Unused_MtTeapotCompletionHighLast
	ld   a, [sMapMtTeapotCompletion]
	ld   l, a
	ld   a, [sMap_Unused_MtTeapotCompletionHigh]
	ld   h, a
	call Map_SyncCompletionStatus
	; Determine where to move for the revealed path
	ld   hl, Map_MtTeapot_AutoMoveTbl
	call Map_SetAutoMove
	ld   a, SFX1_03
	ld   [sSFX1Set], a
	jr   Map_MtTeapot_DoLevelClear_End
; =============== Map_MtTeapot_GetEvPtrs ===============
; Sets up the pointers to the event tables.
Map_MtTeapot_GetEvPtrs:
	ld   a, [sMapMtTeapotCompletionLast]
	ld   b, a
	ld   a, [sMapMtTeapotCompletion]
	ld   c, a
	ld   a, [sMap_Unused_MtTeapotCompletionHighLast]
	ld   d, a
	ld   a, [sMap_Unused_MtTeapotCompletionHigh]
	ld   e, a
	ld   hl, EvDef_Map_MtTeapot
	call Map_PathReveal_GetEvPtrs
	jr   z, Map_MtTeapot_EndPathReveal ; Does it point to the null entry?
	ret
; =============== Map_MtTeapot_SetEvTile ===============
; Indexes the event Tiles table and sets the current Tile ID for the event.
; If we go past the last entry, it ends the path reveal anim.
Map_MtTeapot_SetEvTile:
	call Map_IndexEvTile
	jr   z, Map_MtTeapot_EndPathReveal
	ld   [de], a
	ret
	
; =============== Map_StoveCanyon_DoLevelClear ===============
; Handles the path reveal animation for Stove Canyon.
Map_StoveCanyon_DoLevelClear:
	; This requires the level clear flag to be set
	ld   a, [sMapLevelClear]
	and  a
	ret  z
	
	call Map_WriteWarioOBJLst
	
	; Process a new tile every $10 frames
	ld   a, [sMapTimer_Low]
	and  a, $0F
	ret  nz
	
.processTile:
	ld   a, SFX1_22
	ld   [sSFX1Set], a
	call .getEvPtrs
	call .setEvTile
	call Map_SetEvOffset
	ld   hl, sMapEvIndex
	inc  [hl]
.end:
	ret
	
; =============== .endPathReveal ===============
; Ends the path reveal anim for this submap.
.endPathReveal:
	; Reset the index
	ld   hl, sMapEvIndex
	xor  a
	ld   [hl], a
	
	ld   [sMapLevelClear], a
	; Sync the completion statuses
	ld   de, sMapStoveCanyonCompletionLast
	ld   bc, sMap_Unused_StoveCanyonCompletionHighLast
	ld   a, [sMapStoveCanyonCompletion]
	ld   l, a
	ld   a, [sMap_Unused_StoveCanyonCompletionHigh]
	ld   h, a
	call Map_SyncCompletionStatus
	
	; Determine where to move for the revealed path
	ld   hl, Map_StoveCanyon_AutoMoveTbl
	call Map_SetAutoMove
	
	ld   a, SFX1_03
	ld   [sSFX1Set], a
	jr   .end
	
; =============== .getEvPtrs ===============
; Sets up the pointers to the event tables.
.getEvPtrs:
	ld   a, [sMapStoveCanyonCompletionLast]
	ld   b, a
	ld   a, [sMapStoveCanyonCompletion]
	ld   c, a
	ld   a, [sMap_Unused_StoveCanyonCompletionHighLast]
	ld   d, a
	ld   a, [sMap_Unused_StoveCanyonCompletionHigh]
	ld   e, a
	ld   hl, EvDef_Map_StoveCanyon
	call Map_PathReveal_GetEvPtrs
	jr   z, .endPathReveal ; Does it point to the null entry?
	ret
	
; =============== .setEvTile ===============
; Indexes the event Tiles table and sets the current Tile ID for the event.
; If we go past the last entry, it ends the path reveal anim.
.setEvTile:
	call Map_IndexEvTile
	jr   z, .endPathReveal
	ld   [de], a
	ret
	
; =============== Map_SSTeacup_DoLevelClear ===============
; Handles the path reveal animation for SS Teacup.
Map_SSTeacup_DoLevelClear:
	; This requires the level clear flag to be set
	ld   a, [sMapLevelClear]
	and  a
	ret  z
	
	call Map_WriteWarioOBJLst
	
	; Process a new tile every $10 frames
	ld   a, [sMapTimer_Low]
	and  a, $0F
	ret  nz
.processTile:
	ld   a, SFX1_22
	ld   [sSFX1Set], a
	call .getEvPtrs
	call .setEvTile
	call Map_SetEvOffset
	ld   hl, sMapEvIndex
	inc  [hl]
.end:
	ret
	
; =============== .endPathReveal ===============
; Ends the path reveal anim for this submap.
.endPathReveal:
	; Reset the index
	ld   hl, sMapEvIndex
	xor  a
	ld   [hl], a
	
	ld   [sMapLevelClear], a
	; Sync the completion statuses
	ld   de, sMapSSTeacupCompletionLast
	ld   bc, sMap_Unused_SSTeacupCompletionHighLast
	ld   a, [sMapSSTeacupCompletion]
	ld   l, a
	ld   a, [sMap_Unused_SSTeacupCompletionHigh]
	ld   h, a
	call Map_SyncCompletionStatus
	
	; Determine where to move for the revealed path
	ld   hl, Map_SSTeacup_AutoMoveTbl
	call Map_SetAutoMove
	
	ld   a, SFX1_03
	ld   [sSFX1Set], a
	jr   .end
	
; =============== .getEvPtrs ===============
; Sets up the pointers to the event tables.
.getEvPtrs:
	ld   a, [sMapSSTeacupCompletionLast]
	ld   b, a
	ld   a, [sMapSSTeacupCompletion]
	ld   c, a
	ld   a, [sMap_Unused_SSTeacupCompletionHighLast]
	ld   d, a
	ld   a, [sMap_Unused_SSTeacupCompletionHigh]
	ld   e, a
	ld   hl, EvDef_Map_SSTeacup
	call Map_PathReveal_GetEvPtrs
	jr   z, .endPathReveal ; Does it point to the null entry?
	ret
	
; =============== .setEvTile ===============
; Indexes the event Tiles table and sets the current Tile ID for the event.
; If we go past the last entry, it ends the path reveal anim.
.setEvTile:
	call Map_IndexEvTile
	jr   z, .endPathReveal
	ld   [de], a
	ret
	
; =============== Map_ParsleyWoods_DoLevelClear ===============
; Handles the path reveal animation for Parsley Woods.
Map_ParsleyWoods_DoLevelClear:
	; This requires the level clear flag to be set
	ld   a, [sMapLevelClear]
	and  a
	ret  z
	
	call Map_WriteWarioOBJLst
	
	; Process a new tile every $10 frames
	ld   a, [sMapTimer_Low]
	and  a, $0F
	ret  nz
	
.processTile:
	ld   a, SFX1_22
	ld   [sSFX1Set], a
	call .getEvPtrs
	call .setEvTile
	call Map_SetEvOffset
	ld   hl, sMapEvIndex
	inc  [hl]
.end:
	ret

; =============== .endPathReveal ===============
; Ends the path reveal anim for this submap.
.endPathReveal:
	; Reset the index
	ld   hl, sMapEvIndex
	xor  a
	ld   [hl], a
	
	ld   [sMapLevelClear], a
	; Sync the completion statuses
	ld   de, sMapParsleyWoodsCompletionLast
	ld   bc, sMap_Unused_ParsleyWoodsCompletionHighLast
	ld   a, [sMapParsleyWoodsCompletion]
	ld   l, a
	ld   a, [sMap_Unused_ParsleyWoodsCompletionHigh]
	ld   h, a
	call Map_SyncCompletionStatus
	
	; Determine where to move for the revealed path
	ld   hl, Map_ParsleyWoods_AutoMoveTbl
	call Map_SetAutoMove
	
	ld   a, SFX1_03
	ld   [sSFX1Set], a
	jr   .end
	
; =============== .getEvPtrs ===============
; Sets up the pointers to the event tables.
.getEvPtrs:
	ld   a, [sMapParsleyWoodsCompletionLast]
	ld   b, a
	ld   a, [sMapParsleyWoodsCompletion]
	ld   c, a
	ld   a, [sMap_Unused_ParsleyWoodsCompletionHighLast]
	ld   d, a
	ld   a, [sMap_Unused_ParsleyWoodsCompletionHigh]
	ld   e, a
	ld   hl, EvDef_Map_ParsleyWoods
	call Map_PathReveal_GetEvPtrs
	jr   z, .endPathReveal ; Does it point to the null entry?
	ret
	
; =============== .setEvTile ===============
; Indexes the event Tiles table and sets the current Tile ID for the event.
; If we go past the last entry, it ends the path reveal anim.
.setEvTile:
	call Map_IndexEvTile
	jr   z, .endPathReveal
	ld   [de], a
	ret
	
; =============== Map_SherbetLand_DoLevelClear ===============
; Handles the path reveal animation for Sherbet Land.
Map_SherbetLand_DoLevelClear:
	; This requires the level clear flag to be set
	ld   a, [sMapLevelClear]
	and  a
	ret  z
	
	call Map_WriteWarioOBJLst
	
	; Process a new tile every $10 frames
	ld   a, [sMapTimer_Low]
	and  a, $0F
	ret  nz

.processTile:
	ld   a, SFX1_22
	ld   [sSFX1Set], a
	call .getEvPtrs
	call .setEvTile
	call Map_SetEvOffset
	ld   hl, sMapEvIndex
	inc  [hl]
.end:
	ret
	
; =============== .endPathReveal ===============
; Ends the path reveal anim for this submap.
.endPathReveal:
	; Reset the index
	ld   hl, sMapEvIndex
	xor  a
	ld   [hl], a
	
	ld   [sMapLevelClear], a
	; Sync the completion statuses
	ld   de, sMapSherbetLandCompletionLast
	ld   bc, sMap_Unused_SherbetLandCompletionHighLast
	ld   a, [sMapSherbetLandCompletion]
	ld   l, a
	ld   a, [sMap_Unused_SherbetLandCompletionHigh]
	ld   h, a
	
	; Determine where to move for the revealed path
	call Map_SyncCompletionStatus
	ld   hl, Map_SherbetLand_AutoMoveTbl
	
	call Map_SetAutoMove
	ld   a, SFX1_03
	ld   [sSFX1Set], a
	jr   .end
	
; =============== .getEvPtrs ===============
; Sets up the pointers to the event tables.
.getEvPtrs:
	ld   a, [sMapSherbetLandCompletionLast]
	ld   b, a
	ld   a, [sMapSherbetLandCompletion]
	ld   c, a
	ld   a, [sMap_Unused_SherbetLandCompletionHighLast]
	ld   d, a
	ld   a, [sMap_Unused_SherbetLandCompletionHigh]
	ld   e, a
	ld   hl, EvDef_Map_SherbetLand
	call Map_PathReveal_GetEvPtrs
	jr   z, .endPathReveal ; Does it point to the null entry?
	ret
	
; =============== .setEvTile ===============
; Indexes the event Tiles table and sets the current Tile ID for the event.
; If we go past the last entry, it ends the path reveal anim.
.setEvTile:
	call Map_IndexEvTile
	jr   z, .endPathReveal
	ld   [de], a
	ret
	
; =============== Map_SyrupCastle_DoLevelClear ===============
; Handles the path reveal animation for Syrup Castle
Map_SyrupCastle_DoLevelClear:
	; This requires the level clear flag to be set
	ld   a, [sMapLevelClear]
	and  a
	ret  z
	
	call Map_WriteWarioOBJLst
	
	; Process a new tile every $10 frames
	ld   a, [sMapTimer_Low]
	and  a, $0F
	ret  nz
	
.processTile:
	ld   a, SFX1_22
	ld   [sSFX1Set], a
	call .getEvPtrs
	call .setEvTile
	call Map_SetEvOffset
	ld   hl, sMapEvIndex
	inc  [hl]
.end:
	ret
	
; =============== .endPathReveal ===============
; Ends the path reveal anim for this submap.
.endPathReveal:
	; Reset the index
	xor  a
	ld   [sMapEvIndex], a
	ld   [sMapLevelClear], a
	
	; Sync the completion statuses
	ld   de, sMapSyrupCastleCompletionLast
	ld   bc, sMap_Unused_SyrupCastleCompletionHighLast
	ld   a, [sMapSyrupCastleCompletion]
	ld   l, a
	ld   a, [sMap_Unused_SyrupCastleCompletionHigh]
	ld   h, a
	call Map_SyncCompletionStatus
	
	; Determine where to move for the revealed path
	ld   hl, Map_SyrupCastle_AutoMoveTbl
	call Map_SetAutoMove
	
	ld   a, SFX1_03
	ld   [sSFX1Set], a
	jr   .end
	
; =============== .getEvPtrs ===============
; Sets up the pointers to the event tables.
.getEvPtrs:
	ld   a, [sMapSyrupCastleCompletionLast]
	ld   b, a
	ld   a, [sMapSyrupCastleCompletion]
	ld   c, a
	ld   a, [sMap_Unused_SyrupCastleCompletionHighLast]
	ld   d, a
	ld   a, [sMap_Unused_SyrupCastleCompletionHigh]
	ld   e, a
	ld   hl, EvDef_Map_SyrupCastle
	call Map_PathReveal_GetEvPtrs
	jr   z, .endPathReveal ; Does it point to the null entry?
	ret
	
; =============== .setEvTile ===============
; Indexes the event Tiles table and sets the current Tile ID for the event.
; If we go past the last entry, it ends the path reveal anim.
.setEvTile:
	call Map_IndexEvTile
	jr   z, .endPathReveal
	ld   [de], a
	ret
	
; =============== Event Definition Tables ===============
; These tables map level numbers to a pair of pointers to event data.
;
; Level numbers depend on the bit order in the completion bitmask.

mDefEv: MACRO
\1: dw \1_Tiles, \1_Offsets
ENDM
mDefEvNull: MACRO
\1: dw Ev_Null,Ev_Null
ENDM

EvDef_Map_RiceBeach: 
	dw Ev_Map_C01Clear
	dw Ev_Map_C02Clear
	dw Ev_Map_C03Clear
	dw Ev_Map_C03ClearAlt
	dw Ev_Map_C04Clear
	dw Ev_RiceBeach_Null;X
	dw Ev_RiceBeach_Null
	dw Ev_RiceBeach_Null;X
	dw Ev_RiceBeach_Null;X
	dw Ev_RiceBeach_Null;X
	dw Ev_RiceBeach_Null;X
	dw Ev_RiceBeach_Null;X
	dw Ev_RiceBeach_Null;X
	dw Ev_RiceBeach_Null;X
	dw Ev_RiceBeach_Null;X
	dw Ev_RiceBeach_Null;X

	mDefEv Ev_Map_C01Clear 
	mDefEv Ev_Map_C02Clear 
	mDefEv Ev_Map_C03Clear 
	mDefEv Ev_Map_C03ClearAlt
	mDefEv Ev_Map_C04Clear 
	mDefEvNull Ev_RiceBeach_Null

EvDef_Map_MtTeapot:
	dw Ev_Map_C07Clear
	dw Ev_Map_C08Clear
	dw Ev_Map_C08ClearAlt
	dw Ev_Map_C09Clear
	dw Ev_Map_C10Clear
	dw Ev_Map_C11Clear
	dw Ev_MtTeapot_Null;X
	dw Ev_MtTeapot_Null;X
	dw Ev_MtTeapot_Null;X
	dw Ev_MtTeapot_Null;X
	dw Ev_MtTeapot_Null;X
	dw Ev_MtTeapot_Null;X
	dw Ev_MtTeapot_Null;X
	dw Ev_MtTeapot_Null;X
	dw Ev_MtTeapot_Null;X
	dw Ev_MtTeapot_Null;X

	mDefEv Ev_Map_C07Clear 
	mDefEv Ev_Map_C08Clear 
	mDefEv Ev_Map_C08ClearAlt
	mDefEv Ev_Map_C09Clear 
	mDefEv Ev_Map_C10Clear 
	mDefEv Ev_Map_C11Clear 
	mDefEvNull Ev_MtTeapot_Null

EvDef_Map_StoveCanyon:
	dw Ev_Map_C20Clear
	dw Ev_Map_C21Clear
	dw Ev_Map_C22Clear
	dw Ev_Map_C23Clear
	dw Ev_Map_C23ClearAlt
	dw Ev_StoveCanyon_Null
	dw Ev_StoveCanyon_Null;X
	dw Ev_StoveCanyon_Null;X
	dw Ev_StoveCanyon_Null;X
	dw Ev_StoveCanyon_Null;X
	dw Ev_StoveCanyon_Null;X
	dw Ev_StoveCanyon_Null;X
	dw Ev_StoveCanyon_Null;X
	dw Ev_StoveCanyon_Null;X
	dw Ev_StoveCanyon_Null;X
	dw Ev_StoveCanyon_Null;X

	mDefEv Ev_Map_C20Clear 
	mDefEv Ev_Map_C21Clear 
	mDefEv Ev_Map_C22Clear 
	mDefEv Ev_Map_C23Clear 
	mDefEv Ev_Map_C23ClearAlt
	mDefEvNull Ev_StoveCanyon_Null

EvDef_Map_SSTeacup:
	dw Ev_Map_C26Clear
	dw Ev_Map_C27Clear
	dw Ev_Map_C28Clear
	dw Ev_Map_C29Clear
	dw Ev_SSTeacup_Null;X
	dw Ev_SSTeacup_Null;X
	dw Ev_SSTeacup_Null;X
	dw Ev_SSTeacup_Null;X
	dw Ev_SSTeacup_Null;X
	dw Ev_SSTeacup_Null;X
	dw Ev_SSTeacup_Null;X
	dw Ev_SSTeacup_Null;X
	dw Ev_SSTeacup_Null;X
	dw Ev_SSTeacup_Null;X
	dw Ev_SSTeacup_Null;X
	dw Ev_SSTeacup_Null;X

	mDefEv Ev_Map_C26Clear 
	mDefEv Ev_Map_C27Clear 
	mDefEv Ev_Map_C28Clear 
	mDefEv Ev_Map_C29Clear 
	mDefEvNull Ev_SSTeacup_Null

EvDef_Map_SherbetLand:
	dw Ev_Map_C14Clear
	dw Ev_Map_C15Clear
	dw Ev_Map_C15ClearAlt
	dw Ev_Map_C16Clear
	dw Ev_Map_C16ClearAlt
	dw Ev_Map_C17Clear
	dw Ev_SherbetLand_Null
	dw Ev_SherbetLand_Null;X
	dw Ev_SherbetLand_Null;X
	dw Ev_SherbetLand_Null;X
	dw Ev_SherbetLand_Null;X
	dw Ev_SherbetLand_Null;X
	dw Ev_SherbetLand_Null;X
	dw Ev_SherbetLand_Null;X
	dw Ev_SherbetLand_Null;X
	dw Ev_SherbetLand_Null;X

	mDefEv Ev_Map_C14Clear 
	mDefEv Ev_Map_C15Clear 
	mDefEv Ev_Map_C15ClearAlt
	mDefEv Ev_Map_C16Clear 
	mDefEv Ev_Map_C16ClearAlt
	mDefEv Ev_Map_C17Clear 
	mDefEvNull Ev_SherbetLand_Null

EvDef_Map_ParsleyWoods:
	dw Ev_Map_C31Clear
	dw Ev_Map_C32Clear
	dw Ev_Map_C33Clear
	dw Ev_Map_C34Clear
	dw Ev_Map_C35Clear
	dw Ev_ParsleyWoods_Null;X
	dw Ev_ParsleyWoods_Null;X
	dw Ev_ParsleyWoods_Null;X
	dw Ev_ParsleyWoods_Null;X
	dw Ev_ParsleyWoods_Null;X
	dw Ev_ParsleyWoods_Null;X
	dw Ev_ParsleyWoods_Null;X
	dw Ev_ParsleyWoods_Null;X
	dw Ev_ParsleyWoods_Null;X
	dw Ev_ParsleyWoods_Null;X
	dw Ev_ParsleyWoods_Null;X

	mDefEv Ev_Map_C31Clear 
	mDefEv Ev_Map_C32Clear 
	mDefEv Ev_Map_C33Clear 
	mDefEv Ev_Map_C34Clear 
	mDefEv Ev_Map_C35Clear 
	mDefEvNull Ev_ParsleyWoods_Null


EvDef_Map_SyrupCastle:
	dw Ev_Map_C37Clear
	dw Ev_Map_C38ClearPathOnly
	dw Ev_Map_C39ClearPathOnly
	dw Ev_SyrupCastle_Null;X
	dw Ev_SyrupCastle_Null;X
	dw Ev_SyrupCastle_Null;X
	dw Ev_SyrupCastle_Null;X
	dw Ev_SyrupCastle_Null;X
	dw Ev_SyrupCastle_Null;X
	dw Ev_SyrupCastle_Null;X
	dw Ev_SyrupCastle_Null;X
	dw Ev_SyrupCastle_Null;X
	dw Ev_SyrupCastle_Null;X
	dw Ev_SyrupCastle_Null;X
	dw Ev_SyrupCastle_Null;X
	dw Ev_SyrupCastle_Null;X

	mDefEv Ev_Map_C37Clear 
	mDefEv Ev_Map_C38ClearPathOnly
	mDefEv Ev_Map_C39ClearPathOnly
	mDefEvNull Ev_SyrupCastle_Null
	mDefEvNull Ev_SyrupCastle_Null2

Ev_Null: dw $FFFF

; =============== Map_Mode_MtTeapotInit ===============
; Mode $05
Map_Mode_MtTeapotInit:
	; If we've just finished C12, set the automatic movement
	ld   a, [sMapMtTeapotCompletionLast]
	bit  6, a
	jr   nz, .main
	ld   a, [sMapMtTeapotCompletion]
	bit  6, a
	jr   nz, .setAutoMove
	
.main:
	call Map_LoadPalette
	call HomeCall_LoadGFX_MtTeapot_RiceBeach
	call HomeCall_LoadBG_MtTeapot
	call Map_ClearRAM
	xor  a
	ld   [sMapScrollY], a
	ld   [sMapScrollX], a
	call Map_MtTeapot_LoadEv
	call Map_InitMisc
	call Map_SubmapSetStartPos
	ld   a, MAP_MODE_FADEIN
	ld   [sMapId], a
	ld   a, MAP_MODE_MTTEAPOT
	ld   [sMapNextId], a
	ld   a, $00
	ldh  [rBGP], a
	ld   a, BGM_MTTEAPOT
	ld   [sBGMSet], a
	;--
	; Check for world clear (C13 just completed)
	ld   a, [sMapMtTeapotCompletion]
	bit  7, a
	ret  z
	ld   a, [sMapMtTeapotCompletionLast]
	bit  7, a
	ret  nz
	
	ld   a, MAP_MODE_INITOVERWORLD
	ld   [sMapId], a
	ld   a, [sMapWorldClear]
	add  $02
	ld   [sMapWorldClear], a
	ret
.setAutoMove:
	; This handles the path from C12 to C13.
	;
	; This is done is done by replacing the silently replacing the Level ID
	; with the one where the special path is assigned to.
	; This special path is unique, but it's just made to look like the combination of C12-C11-C10 paths.
	
	; Set the current level ID to $2F, is normally an invalid level.
	ld   a, LVL_UNUSED_2F
	ld   [sMapLevelId], a
	
	; The last completion bit is set to make sure the
	; patch tilemap for this level (the teapod lid) is applied immediately.
	; This meddling with the completion bit should be fixed later on (see Map_MtTeapot_DoLevelClear_C12Clear)
	; to allow the normal world clear anim to take place.
	;
	; Also note about this patch tilemap:
	; - It isn't referenced in the table used for the path reveal animation.
	; - It already contains the dots baked in.
	;
	; There are unused tiles in the tileset without dots which hint
	; this could have worked similar to Parsley Woods,
	; where the tilemap for the empty lake and the path proper are different.
	; This would allow to play a path reveal animation for this course,
	; but there's no equivalent code for handling this in Mt.Teapot.
	; Maybe it wasn't viable with the path going over existing map dots?
	
	ld   a, [sMapMtTeapotCompletionLast]
	add  $40
	ld   [sMapMtTeapotCompletionLast], a
	ld   [sMapMtTeapotAutoMove], a
	ret
	
; =============== Map_Mode_MtTeapot ===============
; Mode $06
Map_Mode_MtTeapot:
	call Map_MtTeapot_DoLevelClear
	ld   a, [sMapLevelClear]
	and  a
	ret  nz
	call Map_Submap_DoEnterAnim
	ld   a, [sMapSubmapEnter]
	and  a
	ret  nz
	call Map_MtTeapot_Do
	ld   hl, sMapMtTeapotBlink
	call HomeCall_Map_BlinkLevel_Do
	ret
Map_MtTeapot_Do:
	call Map_Submap_DoCtrl
	call Map_MtTeapot_DoLevelSwitch
	call Map_WriteWarioOBJLst
	ret
; =============== Map_MtTeapot_DoLevelSwitch ===============
; Handles the Level ID changes after the lid crashes down.
Map_MtTeapot_DoLevelSwitch:
	ld   a, [sMapLevelId]				; Are we over C10?
	cp   a, LVL_C10
	ret  nz								; If not, return
	ld   a, [sMapMtTeapotCompletion]	; Is C12 cleared?
	bit  6, a
	ret  z								; If not, return
	ld   a, LVL_C13						; Replace it with C13
	ld   [sMapLevelId], a
	ret
	
; =============== Map_Mode_C12ClearInit ===============
; Mode $13
Map_Mode_C12ClearInit:
	ld   a, [sMapMtTeapotCompletion]	; Is C12 already completed?
	bit  6, a
	jr   z, .playCutscene				; If not, play the cutscene
	; Otherwise trigger force exit from the map screen.
	; Because this map mode is expected to be called from GM_LEVELCLEAR2, it
	; will switch to the course clear screen.
	ld   a, MAP_MODE_INITMTTEAPOT
	ld   [sMapId], a
	ld   hl, sMapRetVal
	inc  [hl]
	ret
.playCutscene:
	call Map_LoadPalette
	call HomeCall_LoadGFX_Overworld
	call HomeCall_LoadBG_Overworld
	call Map_ClearRAM
	xor  a
	ld   [sMapScrollY], a
	ld   [sMapScrollX], a
	call HomeCall_Map_MtTeapotLidSetPosCutscene
	call Map_InitMisc
	ld   a, MAP_MODE_FADEIN
	ld   [sMapId], a
	ld   a, MAP_MODE_MTTEAPOTCUTSCENE
	ld   [sMapNextId], a
	ld   a, $00
	ldh  [rBGP], a
	ld   a, BGM_CUTSCENE
	ld   [sBGMSet], a
	ret
; =============== Map_Mode_C12Clear ===============	
; Mode $14
Map_Mode_C12Clear:
	call HomeCall_Map_C12ClearCutscene_Do
	ret
	
; =============== Map_Mode_StoveCanyonInit ===============
; Mode $09
Map_Mode_StoveCanyonInit:
	call Map_LoadPalette
	call HomeCall_LoadGFX_StoveCanyon_SSTeacup
	call HomeCall_LoadBG_StoveCanyon
	call Map_ClearRAM
	xor  a
	ld   [sMapScrollY], a
	ld   [sMapScrollX], a
	call Map_StoveCanyon_LoadEv
	call Map_InitMisc
	call Map_SubmapSetStartPos
	ld   a, MAP_MODE_FADEIN
	ld   [sMapId], a
	ld   a, MAP_MODE_STOVECANYON
	ld   [sMapNextId], a
	ld   a, $00
	ldh  [rBGP], a
	ld   a, BGM_STOVECANYON
	ld   [sBGMSet], a
	
	;--
	; Check for world clear
	ld   a, [sMapStoveCanyonCompletion]
	bit  6, a
	ret  z
	ld   a, [sMapStoveCanyonCompletionLast]
	bit  6, a
	ret  nz
	ld   a, MAP_MODE_INITOVERWORLD
	ld   [sMapId], a
	ld   a, [sMapWorldClear]
	add  $04
	ld   [sMapWorldClear], a
	ret
	
; =============== Map_Mode_StoveCanyon ===============
; Mode $0A
Map_Mode_StoveCanyon:
	call Map_StoveCanyon_DoLevelClear
	ld   a, [sMapLevelClear]
	and  a
	ret  nz
	call Map_Submap_DoEnterAnim
	ld   a, [sMapSubmapEnter]
	and  a
	ret  nz
	call Map_StoveCanyon_Do
	ld   hl, sMapStoveCanyonBlink
	call HomeCall_Map_BlinkLevel_Do
	ret
Map_StoveCanyon_Do:
	call Map_Submap_DoCtrl
	call Map_WriteWarioOBJLst
	ret
	
; =============== Map_Mode_C40ClearInit ===============
; Mode $1E
; Initializes the first part of the ending.
Map_Mode_C40ClearInit:
	call Map_Mode_SyrupCastleInit_Do
	ld   a, MAP_MODE_FADEIN
	ld   [sMapId], a
	ld   a, MAP_MODE_SYRUPCASTLE
	ld   [sMapNextId], a
	ld   a, $00
	ldh  [rBGP], a
	ld   a, MAP_SCC_ENDING
	ld   [sMapSyrupCastleCutscene], a
	ld   a, BGM_NONE
	ld   [sBGMSet], a
	ld   a, $30
	ld   a, [sMapWarioYRes]
	ld   a, [sMapWarioX]
	ld   a, $06
	ld   a, [sMapWarioLstId]
	ld   a, $10
	ld   a, [sMapWarioFlags]
	ret
	
; =============== Map_Mode_C40ClearInit ===============
; Mode $21
; Initializes the second part of the ending cutscene.
; This prepares for the fade-in.
Map_Mode_EndingInit:
	call Map_LoadPalette
	call HomeCall_LoadGFX_SyrupCastle
	call HomeCall_LoadBG_SyrupCastleEnding
	call Map_ClearRAM
	xor  a
	ld   [sMapScrollY], a
	ld   [sMapScrollX], a
	call Map_InitMisc
	ld   a, MAP_MODE_ENDING2FADEIN
	ld   [sMapId], a
	ld   a, MAP_MODE_ENDING2
	ld   [sMapNextId], a
	ld   a, $00
	ldh  [rBGP], a
	ldh  [rOBP0], a
	xor  a
	ld   [sMapTimer_Low], a
	ld   a, BGM_NONE
	ld   [sBGMSet], a
	
	; Set base mappings
	ld   a, $48	
	ld   [sMapEndingStatueHighY], a
	ld   a, $58
	ld   [sMapEndingStatueHighX], a
	
	ld   a, $70
	ld   [sMapEndingStatueLowY], a
	ld   a, $58
	ld   [sMapEndingStatueLowX], a
	ld   a, $01
	ld   [sMapEndingStatueLowLstId], a
	
	ld   a, $2D
	ld   [sMapEndingSparkleY], a
	ld   a, $52
	ld   [sMapEndingSparkleX], a
	ld   a, $10
	ld   [sMapEndingSparkleFlags], a
	
	ld   a, $A0
	ld   [sMapWarioYRes], a
	ld   a, $70
	ld   [sMapWarioX], a
	xor  a
	ld   [sMapWarioLstId], a
	ld   [sMapEndingHeliLstId], a
	ld   a, $10
	ld   [sMapWarioFlags], a
	ld   [sMapEndingHeliFlags], a
	ld   a, $30
	ld   [sMapEndingHeliY], a
	ld   a, $C0
	ld   [sMapEndingHeliX], a
	ret
	
; =============== Map_Mode_Ending ===============
; Mode $1F
Map_Mode_Ending:
	call HomeCall_Map_Ending_Do
	ret
	
; =============== Map_Mode_SyrupCastleInit_Do ===============
; Loads the Syrup Castle map screen.
; It has to be done this way since other map modes reuse the map.
Map_Mode_SyrupCastleInit_Do:
	call Map_LoadPalette
	call HomeCall_LoadGFX_SyrupCastle
	call HomeCall_LoadBG_SyrupCastle
	call Map_ClearRAM
	xor  a
	ld   [sMapScrollY], a
	ld   [sMapScrollX], a
	call Map_SyrupCastle_LoadEv
	call Map_InitMisc
	call Map_SubmapSetStartPos
	; Setup wave effect
	ld   a, $01 						; No multiplier
	ld   [sMapSyrupCastleWaveShift], a
	ld   a, $35							; 35 lines
	ld   [sMapSyrupCastleWaveLines], a
	
	; [TCRF] Silence the music for the unused ending trigger in Map_Mode_SyrupCastleInit.
	ld   a, [sMapSyrupCastleCompletion]
	bit  3, a
	jr   nz, .unused_noMusic
	ld   a, BGM_SYRUPCASTLE
	ld   [sBGMSet], a
	ret
.unused_noMusic:
	ld   a, BGM_NONE
	ld   [sBGMSet], a
	ret
; =============== Map_Mode_SyrupCastleInit ===============
; Mode $0B
Map_Mode_SyrupCastleInit:
	call Map_Mode_SyrupCastleInit_Do
	ld   a, $07
	ld   [sMapId], a
	ld   a, $0C
	ld   [sMapNextId], a
	ld   a, $00
	ldh  [rBGP], a
	
	; [TCRF] Normally it's impossible to mark C40 as completed, so this check always fails.
	;
	; This checks if the boss level was just completed in a similar way to other maps.
	; When it is, it plays the ending cutscene.
	;
	; With glitches it's possible to trigger this behaviour -- however because the "last" value is never updated,
	; this causes the ending cutscene to always play when loading this submap,
	; at least until reloading the save, which updates all last completion values during map init.
	;
	; This isn't a problem with other boss levels as they have a World Clear cutscene which handles this.
	ld   a, [sMapSyrupCastleCompletion]
	bit  3, a
	ret  z
	ld   a, [sMapSyrupCastleCompletionLast] ; Was C40 just completed?
	bit  3, a
	ret  nz
	ld   a, MAP_SCC_ENDING   				; If so, play the ending cutscene.
	ld   [sMapSyrupCastleCutscene], a
	ret
	
; =============== Map_Mode_SyrupCastle ===============
; Mode $0C
Map_Mode_SyrupCastle:
	ld   a, [sMapSyrupCastleCutscene]
	and  a
	jr   nz, .inCutscene
	call HomeCall_Map_SyrupCastle_DoEffects
	call Map_SyrupCastle_DoLevelClear
	ld   a, [sMapLevelClear]
	and  a
	ret  nz
	call Map_Submap_DoEnterAnim
	ld   a, [sMapSubmapEnter]
	and  a
	ret  nz
	call Map_Submap_DoCtrl
	call Map_WriteWarioOBJLst
	ld   hl, sMapSyrupCastleBlink
	call HomeCall_Map_BlinkLevel_Do
	ret
.inCutscene:
	call HomeCall_Map_SyrupCastle_DoCutscenes
	ret
	
; =============== Map_Mode_C38ClearInit ===============
; Mode $1A
Map_Mode_C38ClearInit:
	ld   a, [sMapSyrupCastleCompletion]		; Is C38 marked as completed?
	bit  1, a
	jr   z, Map_SyrupCastle_InitC38Cutscene	; If not, play the cutscene
	
Map_SyrupCastle_SkipCutscene:
	ld   a, MAP_MODE_INITSYRUPCASTLE
	ld   [sMapId], a
	ld   hl, sMapRetVal
	inc  [hl]
	ret
	
Map_SyrupCastle_InitC38Cutscene:
	call Map_Mode_SyrupCastleInit_Do
	ld   a, MAP_SCC_C38CLEAR
	ld   [sMapSyrupCastleCutscene], a
	
Map_SyrupCastle_InitCutscene:
	ld   a, MAP_MODE_FADEIN
	ld   [sMapId], a
	ld   a, MAP_MODE_SYRUPCASTLE
	ld   [sMapNextId], a
	ld   a, $00
	ldh  [rBGP], a
	ld   a, BGM_NONE
	ld   [sBGMSet], a
	ret
	
; =============== Map_Mode_Dummy ===============	
Map_Mode_Dummy: ret

; =============== Map_Mode_C39ClearInit ===============
; Mode $1C
Map_Mode_C39ClearInit:
	ld   a, [sMapSyrupCastleCompletion]	; Is C39 marked as completed?
	bit  2, a
	jr   nz, Map_SyrupCastle_SkipCutscene
	call Map_Mode_SyrupCastleInit_Do
	ld   a, MAP_SCC_C39CLEAR
	ld   [sMapSyrupCastleCutscene], a
	jr   Map_SyrupCastle_InitCutscene
; =============== Map_Mode_ParsleyWoodsInit ===============
; Mode $0D
Map_Mode_ParsleyWoodsInit:
	ld   a, [sMapC32ClearFlag]	; Was the C32 clear cutscene played?
	and  a
	jr   nz, .c32Clear			; If so, branch
.main:
	call Map_LoadPalette
	call HomeCall_LoadGFX_ParsleyWoods_SherbetLand
	call HomeCall_LoadBG_ParsleyWoods
	call Map_ClearRAM
	xor  a
	ld   [sMapScrollY], a
	ld   [sMapScrollX], a
	call Map_ParsleyWoods_LoadEv
	call Map_InitMisc
	call Map_SubmapSetStartPos
	ld   a, MAP_MODE_FADEIN
	ld   [sMapId], a
	ld   a, MAP_MODE_PARSLEYWOODS
	ld   [sMapNextId], a
	ld   a, $00
	ldh  [rBGP], a
	ld   a, BGM_PARSLEYWOODS
	ld   [sBGMSet], a
	; Check for world clear
	ld   a, [sMapParsleyWoodsCompletion]
	bit  5, a
	ret  z
	ld   a, [sMapParsleyWoodsCompletionLast]
	bit  5, a
	ret  nz
	ld   a, MAP_MODE_INITOVERWORLD
	ld   [sMapId], a
	ld   a, [sMapWorldClear]
	add  $10
	ld   [sMapWorldClear], a
	ret
.c32Clear:
	; This makes sure C32 counts as just completed after the C32 clear cutscene.
	; ...but it doesn't affect anything at all normally, as the correct completion flags are already set.
	ld   a, [sMapParsleyWoodsCompletionLast]
	and  a, $FD
	ld   [sMapParsleyWoodsCompletionLast], a
	jr   .main
; =============== Map_Mode_ParsleyWoods ===============
; Mode $0E
Map_Mode_ParsleyWoods:
	call Map_ParsleyWoods_DoLevelClear
	ld   a, [sMapLevelClear]
	and  a
	ret  nz
	
	call Map_Submap_DoEnterAnim
	ld   a, [sMapSubmapEnter]
	and  a
	ret  nz
	call Map_ParsleyWoods_Do
	ld   hl, sMapParsleyWoodsBlink
	call HomeCall_Map_BlinkLevel_Do
	ret
Map_ParsleyWoods_Do:
	call Map_Submap_DoCtrl
	call Map_ParsleyWoods_DoLevelSwitch
	call Map_WriteWarioOBJLst
	ret
; =============== Map_ParsleyWoods_DoLevelSwitch ===============
; Handles the Level ID replacements when the Parsley Woods' lake is drained.
Map_ParsleyWoods_DoLevelSwitch:
	ld   a, [sMapLevelId]					; Are we over the slot for C31A?
	cp   a, LVL_C31A
	ret  nz									; If not, return
	ld   a, [sMapParsleyWoodsCompletion]	; Did we complete C32?
	bit  1, a
	ret  z									; If not, return
	ld   a, LVL_C31B						; Replace with C31B
	ld   [sMapLevelId], a
	ret
	
; =============== Map_Mode_C32ClearInit ===============
; Mode $18
Map_Mode_C32ClearInit:
	ld   a, [sMapParsleyWoodsCompletion]	; Is C32 marked as completed?
	bit  1, a
	jr   z, .startCutscene					; If not, play the cutscene
	ld   a, $0D
	ld   [sMapId], a
	ld   hl, sMapRetVal
	inc  [hl]
	ret
.startCutscene:
	call HomeCall_Map_C32ClearCutscene_Init
	ret
; =============== Map_Mode_C32Clear ===============
; Mode $19
Map_Mode_C32Clear:
	call HomeCall_Map_C32ClearCutscene_Do
	ret
	
; =============== Map_Mode_SSTeacupInit ===============
; Mode $0F
Map_Mode_SSTeacupInit:
	call Map_LoadPalette
	call HomeCall_LoadGFX_StoveCanyon_SSTeacup
	call HomeCall_LoadBG_SSTeacup
	call Map_ClearRAM
	xor  a
	ld   [sMapScrollY], a
	ld   [sMapScrollX], a
	call Map_SSTeacup_LoadEv
	call Map_InitMisc
	call Map_SubmapSetStartPos
	ld   a, MAP_MODE_FADEIN
	ld   [sMapId], a
	ld   a, MAP_MODE_SSTEACUP
	ld   [sMapNextId], a
	ld   a, $00
	ldh  [rBGP], a
	ld   a, BGM_SSTEACUP
	ld   [sBGMSet], a
	
	; Check for world clear
	ld   a, [sMapSSTeacupCompletion]
	bit  4, a
	ret  z
	ld   a, [sMapSSTeacupCompletionLast]
	bit  4, a
	ret  nz
	ld   a, MAP_MODE_INITSSTEACUPCUTSCENE
	ld   [sMapId], a
	ret
; =============== Map_Mode_SSTeacup ===============
; Mode $10
Map_Mode_SSTeacup:
	call Map_SSTeacup_DoLevelClear
	ld   a, [sMapLevelClear]
	and  a
	ret  nz
	call Map_Submap_DoEnterAnim
	ld   a, [sMapSubmapEnter]
	and  a
	ret  nz
	call Map_SSTeacup_Do
	ld   hl, sMapSSTeacupBlink
	call HomeCall_Map_BlinkLevel_Do
	ret
Map_SSTeacup_Do:
	call Map_Submap_DoCtrl
	call Map_WriteWarioOBJLst
	ret
	
; =============== Map_Mode_C30ClearInit ===============
; Mode $16
; Initialize SS Teacup -> Parsley Woods cutscene
Map_Mode_C30ClearInit:
	call Map_LoadPalette
	call HomeCall_LoadGFX_Overworld
	call HomeCall_LoadBG_Overworld
	call Map_ClearRAM
	ld   a, $70
	ld   [sMapScrollY], a
	ld   a, $60
	ld   [sMapScrollX], a
	call Map_InitMisc
	ld   a, $80
	ld   [sMapOAMWriteY], a
	ld   [sMapWarioYRes], a
	ld   a, $64
	ld   [sMapOAMWriteX], a
	ld   [sMapWarioX], a
	ld   a, $04
	ld   [sMapWarioLstId], a
	ld   [sMapOAMWriteLstId], a
	ld   a, $10
	ld   [sMapWarioFlags], a
	ld   [sMapOAMWriteFlags], a
	ld   a, MAP_MODE_FADEIN
	ld   [sMapId], a
	ld   a, MAP_MODE_SSTEACUPCUTSCENE
	ld   [sMapNextId], a
	ld   a, $00
	ldh  [rBGP], a
	ld   a, BGM_CUTSCENE
	ld   [sBGMSet], a
	ret
; =============== Map_Mode_C30Clear ===============
; Mode $17
Map_Mode_C30Clear:
	call Map_Overworld_AnimTiles
	ld   a, [sMapOverworldCutsceneScript]
	cp   a, $01
	jr   z, .act1		; Init screen shake
	cp   a, $02
	jr   z, .act2		; Screen shake
	cp   a, $03
	jr   z, .act3		; Launch up
	cp   a, $04
	jr   z, .waitNext	; Delay
	cp   a, $05
	jr   z, .act5		; Drop down
	cp   a, $06
	jp   z, .act6		; End
.waitNext:
	ld   a, [sMapTimer0]
	bit  7, a
	ret  z
	ld   hl, sMapOverworldCutsceneScript
	inc  [hl]
	ret
.act1:
	ld   a, SFX4_0B
	ld   [sSFX4Set], a
	ld   hl, sMapOverworldCutsceneScript
	inc  [hl]
	; Init screen shake and timer
	ld   a, $01
	ld   [sMapShake], a
	ld   a, [sMapScrollY]
	ld   [sMapScrollYShake], a
	xor  a
	ld   [sMapTimer0], a
	ret
.act2:
	; Wait $08 frames with the screen shake effect
	ld   a, [sMapShake]
	inc  a
	ld   [sMapShake], a
	cp   a, $08
	ret  nz
	; Stop effect
	xor  a
	ld   [sMapShake], a
	ld   a, $70
	ld   [sMapScrollYShake], a
	ld   hl, sMapOverworldCutsceneScript
	inc  [hl]
	ret
.act3:
	; Every other frame
	ld   a, [sMapTimer_Low]
	and  a, $01
	jr   nz, .drawWario
	
	; Move Wario upwards by 2px
	ld   a, [sMapWarioYRes]
	dec  a
	dec  a
	
	; If the Y pos reaches $70, play the SFX
	ld   [sMapWarioYRes], a	
	cp   a, $70
	jr   z, .playLaunchSFX
	
	and  a					; Has Wario reached the off-screen position?
	jr   nz, .drawWario		; If not, draw the sprite
	
	; Otherwise, switch to the next mode
	xor  a
	ld   [sMapTimer0], a
	ld   [sMapWarioYRes], a
	ld   hl, sMapOverworldCutsceneScript
	inc  [hl]
	ld   a, $50
	ld   [sMapWarioFlags], a
.drawWario:
	call Map_WriteWarioOBJLstCustom
	ret
.playLaunchSFX:
	ld   a, SFX1_31
	ld   [sSFX1Set], a
	jr   .drawWario
.playDropSFX:
	ld   a, SFX1_29
	ld   [sSFX1Set], a
	jr   .drawWario
.act5:
	; Every other frame
	ld   a, [sMapTimer_Low]
	and  a, $01
	jr   nz, .drawWario
	
	; Move Wario down by 3px
	ld   a, [sMapWarioYRes]
	inc  a
	inc  a
	inc  a
	
	ld   [sMapWarioYRes], a	; In the first loop, also play the SFX
	cp   a, $03
	jr   z, .playDropSFX
	
	cp   a, $1E				; Did we reach the target position?
	jr   nz, .drawWario		; If not, draw the sprite
	
	; Otherwise, switch to the next mode
	xor  a
	ld   [sMapWarioYRes], a				; Hide Wario
	ld   hl, sMapOverworldCutsceneScript
	inc  [hl]
	ld   a, $01
	ld   [sMapShake], a
	ld   a, [sMapScrollY]
	ld   [sMapScrollYShake], a
	ld   a, SFX4_18
	ld   [sSFX4Set], a
	ret
.act6:
	; Shake screen for $10 frames
	ld   a, [sMapShake]
	inc  a
	ld   [sMapShake], a
	cp   a, $10
	ret  nz
	; Cleanup
	xor  a
	ld   [sMapShake], a
	ld   a, $70
	ld   [sMapScrollYShake], a
	ld   a, MAP_MODE_FADEOUT
	ld   [sMapId], a
	ld   a, MAP_MODE_INITOVERWORLD
	ld   [sMapNextId], a
	ld   hl, sMapOverworldCutsceneScript
	inc  [hl]
	
	ld   a, MAP_OWP_PARSLEYWOODS			; This has no effect due to the special case
	ld   [sMapWorldId], a
	ld   a, LVL_OVERWORLD_PARSLEYWOODS
	ld   [sLevelId], a
	xor  a
	ld   [sMapSubmapEnter], a
	ld   [sMapLevelClear], a
	ld   a, [sMapSSTeacupCompletion]
	ld   [sMapSSTeacupCompletionLast], a
	ret
	
; =============== Map_Mode_SherbetLandInit ===============
; Mode $11
Map_Mode_SherbetLandInit:
	call Map_LoadPalette
	call HomeCall_LoadGFX_ParsleyWoods_SherbetLand
	call HomeCall_LoadBG_SherbetLand
	call Map_ClearRAM
	xor  a
	ld   [sMapScrollY], a
	ld   [sMapScrollX], a
	call Map_SherbetLand_LoadEv
	call Map_InitMisc
	call Map_SubmapSetStartPos
	ld   a, MAP_MODE_FADEIN
	ld   [sMapId], a
	ld   a, MAP_MODE_SHERBETLAND
	ld   [sMapNextId], a
	ld   a, $00
	ldh  [rBGP], a
	ld   a, BGM_SHERBETLAND
	ld   [sBGMSet], a
	; Check for world clear
	ld   a, [sMapSherbetLandCompletion]
	bit  7, a
	ret  z
	ld   a, [sMapSherbetLandCompletionLast]
	bit  7, a
	ret  nz
	ld   a, MAP_MODE_INITOVERWORLD
	ld   [sMapId], a
	ld   a, [sMapWorldClear]
	add  $20
	ld   [sMapWorldClear], a
	ret
	
; =============== Map_Mode_SherbetLand ===============
; Mode $12
Map_Mode_SherbetLand:
	call Map_SherbetLand_DoLevelClear
	ld   a, [sMapLevelClear]
	and  a
	ret  nz
	call Map_Submap_DoEnterAnim
	ld   a, [sMapSubmapEnter]
	and  a
	ret  nz
	call Map_SherbetLand_Do
	ld   hl, sMapSherbetLandBlink
	call HomeCall_Map_BlinkLevel_Do
	ret
Map_SherbetLand_Do:
	call Map_Submap_DoCtrl
	call Map_WriteWarioOBJLst
	ret

; =============== Map_ScreenEvent ===============
; Handler for the map screen update code during VBlank.
; This will perform tile updates and screen scrolling.
;
Map_ScreenEvent:
	; Update all the timers
	ld   hl, sMapTimer0			; sMapTimer0++
	inc  [hl]
	ld   hl, sMapTimer_Low		; sMapTimer++;
	inc  [hl]
	jr   nz, .noTimerOverflow	; If we didn't overflow, hump
	ld   hl, sMapTimer_High
	inc  [hl]
	
.noTimerOverflow:
	; Update scroll registers
	ld   a, [sMapScrollX]			
	ldh  [rSCX], a
	ld   a, [sMapScrollY]
	ldh  [rSCY], a
	
;--
	; Handle the screen shake (earthquake) effect.
	; When active, a different ScrollY memory address is used.
	; An offset of $04 pixels will be applied to that value.
	;
	ld   a, [sMapShake]				; Is the screen shake effect active?
	and  a
	jr   z, .chkRiceBeachNext	; If not, skip
	
	ld   a, [sMapScrollYShake]		; Is the base Y scroll override set?
	and  a							
	jr   z, .shakeNoYOverride		; If not, use a simpler way to do the effect
	
.shakeWithYPos:
	; Screen shake 
	ld   a, [sMapScrollYShake]		; Override the Y scroll base
	ldh  [rSCY], a
	
	; rSCY = sMapScrollYShake + (Timer & %100)
	; As a result of the way the timer is used, 
	; every $4 frames it will alternate between offsets of $00 and $04.
	ld   a, [sMapTimer0]			
	and  a, $04						; Coerce to 0 or 4
	jr   z, .chkRiceBeachNext		; Skip in the first four frames...
	ld   b, a						; B = 4
	ldh  a, [rSCY]					; Add it to the current ScrollY					
	add  b
	ldh  [rSCY], a
	jr   .chkRiceBeachNext
	
.shakeNoYOverride:
	; When the screen Y position is at the top, the scroll Y
	; can just be set directly to $00 or $04.
	xor  a							; Y base is expected 0
	ld   [sMapScrollY], a
	; Calculate the offset for the current timer pos
	ld   a, [sMapTimer_Low]			
	and  a, $04						; Coerce to 0 or 4	
	jr   z, .chkRiceBeach			; If still $00, don't write back the updated value
	ld   [sMapScrollY], a
;--

;--
;	TILE ANIMATION HANDLER
;--
	
; Rice Beach gets special treatment, as its animated tiles
; are also processed during the fade in, unlike all other maps.
;
; This was done likely because the map uses a lot of animated tiles,
; and not animating them during the fade in would be very noticeable.
; (unlike say, Stove Canyon's alternating 2 animated tiles)
.chkRiceBeachNext:
	ld   a, [sMapNextId]			
	cp   a, MAP_MODE_RICEBEACH
	jr   z, .riceBeach
.chkRiceBeach:
	ld   a, [sMapId]
	cp   a, MAP_MODE_RICEBEACH
	jp   nz, .checkMode3
	
.riceBeach:
	; Copy over all of the 1bpp animated tiles for Rice Beach from CRAM to VRAM.
	; Because of issues with VRAM inaccessibility, this is looped 6 times.
	call Map_RiceBeach_CopyMapAnimGFX0
	call Map_RiceBeach_CopyMapAnimGFX1
	call Map_RiceBeach_CopyMapAnimGFX2
	call Map_RiceBeach_CopyMapAnimGFX3
	call Map_RiceBeach_CopyMapAnimGFX4
	call Map_RiceBeach_CopyMapAnimGFX5
	call Map_RiceBeach_CopyMapAnimGFX6
	call Map_RiceBeach_CopyMapAnimGFX7
	call Map_RiceBeach_CopyMapAnimGFX8
	call Map_RiceBeach_CopyMapAnimGFX9
	; Check how many times we've looped the copy
	ld   hl, sMapTileCopyCounter	
	inc  [hl]
	ld   a, [hl]
	cp   a, $06						; Looped 6 times?
	jr   nz, .riceBeach				; If not, loop again
	xor  a							; Reset the counter
	ld   [hl], a
	
	; Rice Beach also handles its Map Event code here, likely to save time
	; This is identical to .doEv
	ld   a, [sMapLevelClear]
	and  a							; Are we playing the path reveal anim?
	ret  z							; If not, return
	call Map_SetNextEvTile			; Otherwise, update a single tile as specified
	ret
	
.checkMode3:
	; Detect overworld cutscenes (which still do the overworld tile anim)
	ld   a, [sMapId]
	cp   a, MAP_MODE_MTTEAPOTCUTSCENE
	jr   z, .overworld
	cp   a, MAP_MODE_SSTEACUPCUTSCENE
	jr   z, .overworld
	ld   a, [sMapId]
	cp   a, MAP_MODE_PARSLEYWOODSCUTSCENE
	jr   z, .overworld
	;--
	; Detect maps with their own animated tiles
	cp   a, MAP_MODE_SSTEACUP
	jr   z, .modeSSTeacup
	cp   a, MAP_MODE_STOVECANYON
	jr   z, .modeStoveCanyon
	;--
	cp   a, MAP_MODE_OVERWORLD
	jr   nz, .checkEv
.overworld:
	call Map_Overworld_ScreenEvent
	
;--
;	MAP EVENT (PATH REVEAL VER) / TILE UPDATE HANDLER
;--
.checkEv:
	; The cutscenes in syrup castle use the same event system to perform their tilemap updates.
	; So we check for those too.
	ld   a, [sMapSyrupCastleCutscene]
	cp   a, MAP_SCC_C38CLEAR
	jr   z, .doEv
	cp   a, MAP_SCC_C39CLEAR
	jr   z, .doEv
	; Otherwise, map events should only be processed incrementally when
	; the path reveal animation is active
	ld   a, [sMapLevelClear]
	and  a
	ret  z
.doEv:
	call Map_SetNextEvTile
	ret
.modeSSTeacup:
	call Map_SSTeacup_ScreenEvent
	jr   .checkEv
.modeStoveCanyon:
	call Map_StoveCanyon_ScreenEvent
	jr   .checkEv
	ret
	
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L087EB6.asm"
ENDC