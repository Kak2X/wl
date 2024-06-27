;
; BANK $06 - GFX / BG Data
;

; =============== LoadGFX_TreasureRoom ===============
LoadVRAM_TreasureRoom:
	call LoadGFX_TreasureRoom
	call HomeCall_LoadGFX_WarioPowerHat
	ld   hl, BGRLE_TreasureRoom
	ld   bc, BGMap_Begin
	call DecompressBG
	call TrRoom_PlInit
	ret
; =============== LoadVRAM_Treasure_TreasureRoom ===============
LoadVRAM_Treasure_TreasureRoom:
	call LoadGFX_TreasureRoom
	call HomeCall_LoadGFX_WarioPowerHat
	ld   hl, BGRLE_TreasureRoom
	ld   bc, BGMap_Begin
	call DecompressBG
	call Treasure_TrRoom_PlInit
	ret
	
; =============== LoadVRAM_Ending_TreasureRoom ===============
LoadVRAM_Ending_TreasureRoom:
	call LoadGFX_TreasureRoom
	call HomeCall_LoadGFX_WarioPowerHat
	ld   hl, BGRLE_TreasureRoom
	ld   bc, BGMap_Begin
	call DecompressBG
	call Ending_TrRoom_PlInit
	ret
	
; =============== LoadGFX_TreasureRoom ===============
LoadGFX_TreasureRoom:
	ld   hl, GFXRLE_TreasureRoom
	call DecompressGFX
	ret
	
; =============== TrRoom_PlInit ===============
; Stub to NonGame_PlInit specifically used when loading the treasure room.
TrRoom_PlInit:
	call NonGame_PlInit
	ret
	
; =============== Ending_TrRoom_PlInit ===============
; Stub to NonGame_PlInit specifically used when loading the treasure room in the ending.
Ending_TrRoom_PlInit:
	call NonGame_PlInit
	ret
	
; =============== NonGame_PlInit ===============
; Sets the player sprite for nonstatic screens that spawn the player from the left:
; This includes:
; - Course Clear screen
; - Treasure room (level clear & ending)
; NOTE: The default player position this subroutine sets is 8px above the
;       bottom border of the screen (right above the status bar).
;		This is valid for the Treasure Room, but other modes like the Course Clear
;       screen are expected to adjust this position.
NonGame_PlInit:
	ld   a, $98				; Right above status bar
	ld   [sPlYRel], a
	ld   a, -$10			; Off-screen left
	ld   [sPlXRel], a
	ld   a, OBJ_WARIO_WALK0
	ld   [sPlLstId], a
	ld   a, OBJLST_XFLIP	; Face right
	ld   [sPlFlags], a
	xor  a					; Reset timer
	ld   [sPlTimer], a
	ret
	
; =============== Treasure_TrRoom_PlInit ===============
; Prepares the player and the treasure he's holding.
Treasure_TrRoom_PlInit:
	call NonGame_PlInitHold
	call ExActS_SpawnTreasureGet
	ret
	
; =============== NonGame_PlInitHold ===============
; Variant of NonGame_PlInit where the player is holding something while walking.
NonGame_PlInitHold:
	ld   a, $98				; Right above status bar
	ld   [sPlYRel], a
	ld   a, -$10			; Off-screen left
	ld   [sPlXRel], a
	ld   a, OBJ_WARIO_HOLDWALK0
	ld   [sPlLstId], a
	ld   a, OBJLST_XFLIP	; Face right
	ld   [sPlFlags], a
	xor  a					; Reset timer
	ld   [sPlTimer], a
	ret
	
; =============== ExActS_SpawnTreasureGet ===============
; Spawns the treasure in the Treasure Room which is initially held by the player.
ExActS_SpawnTreasureGet:
	ld   hl, sExActSet
	ld   a, EXACT_TREASUREGET	; Actor ID
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	; Determine the initial animation frame for the treasure.
	; Frames for the treasures are ordered by ID, so sTreasureId can be used.
	; Each treasure has 2 frames of animation one after the other, so we multiply by 2.
	; FrameId = $8C + sTreasureId*2
	ld   a, [sTreasureId]
	add  a
	add  OBJ_TRROOM_TREASURE_C0 - $02
	ldi  [hl], a
	
	ld   a, $10			; Flags
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	; Position treasure so it looks like Wario is holding it
	ld   a, $78			; Y position
	ldi  [hl], a
	ld   a, $F8			; X position
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	call ExActS_Spawn
	ret
	
; =============== LoadVRAM_SaveSelect ===============
LoadVRAM_SaveSelect:
	call LoadGFX_SaveSelect
	ld   hl, BGRLE_SaveSelect
	ld   bc, BGMap_Begin
	call DecompressBG
	ret
LoadGFX_SaveSelect:
	ld   hl, GFXRLE_SaveSelect
	call DecompressGFX
	ret
	
; =============== SaveSel_InitOBJ ===============
; Initializes the OBJ and ExAct used in the save select screen.
;
; Because OAM is completely empty when this is called, the subroutines
; which set OBJ do so by directly writing data to OAM, instead of going through OBJLst.
; They use hardcoded slot numbers which other code depends on.
SaveSel_InitOBJ:
	call SaveSel_InitLevelTextOBJ
	call SaveSel_WriteBrickOBJ
	call ExActS_SpawnSaveSel_WarioHat
	call SaveSel_InitWarioOBJLst
	ret
	
; =============== mSetLevelText ===============
; This macro generates code to write the two digits of the completed levels text
; to WorkOAM.
; IN
; - HL: Ptr to WorkOAM
; -  1: Ptr to level cleared count (BCD)
; -  2: Y coord of text
; -  3: X coord of text
mSetLevelText: MACRO
	; Upper digit
	ld   a, \2		; Y Coord
	ldi  [hl], a
	ld   a, \3		; X Coord
	ldi  [hl], a	
	; Get the amount of levels cleared from the save file, which is in BCD format
	; The currently loaded tileset has the number tiles at A0-A9.
	ld   a, [\1]	; Tile ID
	ld   b, a		
	swap a			; Get high nybble
	and  a, $0F		; 
	add  $A0		; Add to it the base tile offset and we've got the tile ID
	ldi  [hl], a	
	ld   a, $00		; Flags (use normal pal)
	ldi  [hl], a
	
	; Do similar for the lower digit
	ld   a, \2		; Y coord
	ldi  [hl], a
	ld   a, \3+$08	; X coord
	ldi  [hl], a
	ld   a, b		; Tile ID
	and  a, $0F		; Use low nybble
	add  $A0
	ldi  [hl], a	
	ld   a, $00		; Flags (use normal pal)
	ldi  [hl], a
ENDM	

; =============== SaveSel_InitLevelTextOBJ ===============
; Writes to OAM the text for the amount of levels completed.
SaveSel_InitLevelTextOBJ:
	; Expected OAM size: $00
	ld   hl, sWorkOAM
	
	; For all files, write the level text
	
	;                             VAR    Y    X
	mSetLevelText sSave1LevelsCleared, $90, $1C
	mSetLevelText sSave2LevelsCleared, $90, $3C
	mSetLevelText sSave3LevelsCleared, $90, $5C
	
	; We wrote 6 digits ($18 bytes)
	ld   a, ($00+$06)*$04
	ld   [sWorkOAMPos], a
	ret
	
; =============== SaveSel_WriteBrickOBJ ===============
; Writes to OAM the breakable bricks at the left of the screen.
SaveSel_WriteBrickOBJ:
	; Expected OAM size: $18
	ld   hl, sWorkOAM + ($06*$04)
	
	; Write the 4 bricks in a column, one 8px below the other
I = 0
REPT 4
	ld   a, $58+I	; Y
	ldi  [hl], a
	ld   a, $08		; X
	ldi  [hl], a
	ld   a, $B0		; Tile ID
	ldi  [hl], a
	ld   a, $00		; Flags
	ldi  [hl], a
I = I + $08			
ENDR
	
	;----------
	; Two extra bricks are here, but they aren't seen since they
	; overlap existing bricks.
	; They are used for the break effect.
	
	; 4
	ld   a, $58
	ldi  [hl], a
	ld   a, $08
	ldi  [hl], a
	ld   a, $B0
	ldi  [hl], a
	ld   a, $00
	ldi  [hl], a
	
	; 5
	ld   a, $60
	ldi  [hl], a
	ld   a, $08
	ldi  [hl], a
	ld   a, $B0
	ldi  [hl], a
	ld   a, $10
	ldi  [hl], a
	
	; We wrote 6 bricks ($18 bytes)
	ld   a, ($06+$06)*$04
	ld   [sWorkOAMPos], a
	ret
	
; =============== ExActS_SpawnSaveSel_WarioHat ===============
; Sets up the ExOBJ for the Wario's (new) hat in the save select screen.
ExActS_SpawnSaveSel_WarioHat:
	ld   hl, sExActSet
	ld   a, $08
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ld   a, $63
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ld   a, $40		; Y
	ldi  [hl], a
	ld   a, $18		; X
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	call ExActS_Spawn
	ret
	
; =============== SaveSel_InitWarioOBJLst ===============
; Sets Wario's starting position / OBJLst settings.
SaveSel_InitWarioOBJLst:
	ld   a, $78
	ld   [sPlYRel], a
	ld   a, $F0
	ld   [sPlXRel], a
	ld   a, $68
	ld   [sPlLstId], a
	ld   a, $20
	ld   [sPlFlags], a
	xor  a
	ld   [sPlTimer], a
	ret
; =============== LoadVRAM_CourseClr ===============
LoadVRAM_CourseClr:
	call LoadGFX_CourseClr
	call LoadBG_CourseClr
	call NonGame_PlInit
	ret
; =============== LoadGFX_CourseClr ===============
LoadGFX_CourseClr:
	ld   hl, GFXRLE_CourseClr
	call DecompressGFX
	ret
; =============== LoadBG_CourseClr ===============
LoadBG_CourseClr:
	ld   hl, BGRLE_CourseClr
	ld   bc, BGMap_Begin
	call DecompressBG
	ret
	
GFXRLE_TreasureRoom: INCBIN "data/gfx/trroom.rlc"
;--
L0655B9: db $00;X
L0655BA: db $00;X
L0655BB: db $00;X
;--
BGRLE_TreasureRoom: INCBIN "data/bg/trroom.rls"
GFXRLE_SaveSelect: INCBIN "data/gfx/saveselect.rlc"
BGRLE_SaveSelect: INCBIN "data/bg/saveselect.rls"
GFX_Level_Ice: INCBIN "data/gfx/level/level_ice.bin"
GFX_Level_StoneCave: INCBIN "data/gfx/level/level_stonecave.bin"
GFXRLE_CourseClr: INCBIN "data/gfx/courseclear.rlc"
BGRLE_CourseClr: INCBIN "data/bg/courseclear.rls"
; =============== END OF BANK ===============
	mIncJunk "L0679C6"
