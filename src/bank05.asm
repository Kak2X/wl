;
; BANK 05 - Screen Event code / OBJLst definitions
;

; =============== ScreenEvent_Do ===============
; Default handler for all screen update code during VBlank.
;
ScreenEvent_Do:
	; Update specific events
	call ScreenEvent_CheckMode
	
	; General events
	ld   a, [sGameMode]
	cp   a, GM_LEVEL
	call z, StatusBar_Event_DrawTime
	
	ld   a, [sGameMode]
	cp   a, GM_LEVELCLEAR
	call z, TrRoom_DrawLevelCoins
	
	ld   a, [sPaused]
	and  a
	call nz, StatusBar_Event_DrawTotalCoins
	ret
	
; =============== ScreenEvent_CheckMode ===============
; Performs the actual screen update for unique events.
; ie: only one of these can be active at a time.
;
ScreenEvent_CheckMode:
	ld   a, [sScreenUpdateMode]
	rst  $28
	dw ScreenEvent_Mode_None
	dw ScreenEvent_Mode_LevelScroll
	dw ScreenEvent_Mode_NormalPot
	dw ScreenEvent_Mode_BullPot
	dw ScreenEvent_Mode_JetPot
	dw ScreenEvent_Mode_DragonPot
	dw ScreenEvent_Mode_NormalPotSec
	dw ScreenEvent_Mode_BullPotSec
	dw ScreenEvent_Mode_JetPotSec
	dw ScreenEvent_Mode_DragonPotSec
	dw ScreenEvent_Mode_CreditsBar
	dw ScreenEvent_Mode_CreditsText1
	dw ScreenEvent_Mode_CreditsText2
	dw ScreenEvent_Mode_SavePipe

; =============== StatusBar_Event_DrawTotalCoins ===============
; Draw the total number of coins when the game is paused.
; See StatusBar_WriteNybbles for more info.
; [POI] This is redrawn every frame... for some reason.
;       (There's nothing that changes the total coins during a level)
;
StatusBar_Event_DrawTotalCoins:
	ld   hl, vBGTotalCoins		; HL = Tilemap area for the total coin counter (in the WINDOW)
	;--
	; Digit 5 (sTotalCoins_High)
	ld   a, [sTotalCoins_High]	; Upper nybble is unused so why bother
	add  TILEID_DIGITS		; Add the base tile ID for digits
	ldi  [hl], a
	;--
	ld   a, [sTotalCoins_Mid]
	ld   b, a
	; Digit 4 (sTotalCoins_Mid >> $0F)
	swap a
	and  a, $0F
	add  TILEID_DIGITS
	ldi  [hl], a
	; Digit 3 (sTotalCoins_Mid & $0F)
	ld   a, b
	and  a, $0F
	add  TILEID_DIGITS
	ldi  [hl], a
	;--
	ld   a, [sTotalCoins_Low]
	ld   b, a
	; Digit 2 (sTotalCoins_Low >> $0F)
	swap a
	and  a, $0F
	add  TILEID_DIGITS
	ldi  [hl], a
	; Digit 1 (sTotalCoins_Low & $0F)
	ld   a, b
	and  a, $0F
	add  TILEID_DIGITS
	ld   [hl], a
	ret
; =============== StatusBar_Event_DrawTime ===============
; Draws the time in the status bar.
;
; Essentially identical to StatusBar_DrawTime, except without subroutine calls;
; and since we're in VBlank we don't need to wait for a new HBlank period.
StatusBar_Event_DrawTime:
	ld   hl, vBGLevelTime		; HL = Tilemap area for the time (in the WINDOW)
	;--
	; Digit 1: Hundreds (sLevelTime_High)
	ld   a, [sLevelTime_High]	
	add  TILEID_DIGITS		
	ldi  [hl], a
	;--
	ld   a, [sLevelTime_Low]
	ld   b, a	
	; Digit 2: Tens (sLevelTime_Low >> 4)	
	swap a
	and  a, $0F
	add  TILEID_DIGITS					
	ldi  [hl], a
	; Digit 3 (sLevelTime_Low & $0F)
	ld   a, b					
	and  a, $0F
	add  TILEID_DIGITS					
	ld   [hl], a
	ret
; =============== TrRoom_DrawLevelCoins ===============
; Draw the level coin counter in the treasure room.
; The same as the above subroutine, except with different parameters.
;
; This expects the game mode to be GM_LEVELCLEAR.
TrRoom_DrawLevelCoins:
	; If we aren't in the treasure room yet, don't update the coin count
	ld   a, [sSubMode]
	cp   a, GM_LEVELCLEAR_TRWAIT
	ret  c
	
	ld   hl, vBGTrRoomLevelCoins ; HL = Position of the coin count in the BG tilemap
	;--
	; Digit 1: Hundreds (sLevelCoins_High)
	ld   a, [sLevelCoins_High]
	add  TILEID_TRROOM_DIGITS
	ldi  [hl], a
	;--
	ld   a, [sLevelCoins_Low]
	ld   b, a
	; Digit 2: Tens (sLevelCoins_Low >> 4)	
	swap a
	and  a, $0F
	add  TILEID_TRROOM_DIGITS
	ldi  [hl], a
	; Digit 3 (sLevelCoins_Low & $0F)
	ld   a, b
	and  a, $0F
	add  TILEID_TRROOM_DIGITS
	ld   [hl], a
	ret
; =============== ScreenEvent_Mode_None ===============
; A blank screen event.
ScreenEvent_Mode_None:
	ret
; =============== ScreenEvent_Mode_LevelScroll ===============
; This subroutine writes the new tiles to the tilemap during level scrolling.
; 
; The source data it uses is made of 2 tables meant to be used together.
; What the table ptrs point to is this:
; DE -> Pointer to VRAM of the block's top left tile. ($2 bytes)
; BC -> Tile IDs of the block to write. ($4 bytes)
; These have to be kept syncronized when a block is fully written.
;
; The tile ID order used (and the VRAM offset compared to previous) is:
; - Upper Left   (+$00)
; - Upper Right  (+$01)
; - Bottom Left  (+$1F)
; - Bottom Right (+$01)
;
; The end separator is a single $FF byte at the end of the VRAM Ptr table.
;
ScreenEvent_Mode_LevelScroll:	
	ld   de, sLvlScrollBGPtrWriteTable ; DE = Tilemap pointer of the block to update
	ld   bc, sLvlScrollTileIdWriteTable ; BC = Tile IDs to use (in groups of 4 8x8 tiles)
	; Read initial high byte here (side effect of how the loop is done)
	ld   a, [de]
.nextBlock:
	; Read from ptr table at DE the address of the block in the tilemap
	; This is basically the 8x8 tile offset of the block's top left corner
	ld   h, a			; Store it to HL
	inc  e
	ld   a, [de]
	ld   l, a			
	inc  e				; Make DE point to the next entry, for later			
	
	; Update the top left tile
	ld   a, [bc]		; Read the tile ID
	ldi  [hl], a		; Write it to the tilemap; and set ptr 1 tile to the right
	inc  c				; Next tile
	
	; Update the top right tile
	ld   a, [bc]		
	ld   [hl], a
	; Set VRAM ptr 1 row below and 1 tile left
	; NOTE: $20 is the amount of tiles in each tilemap row
	ld   a, l
	add  ($20-$01)	
	ld   l, a
	inc  c				; Next tile
	
	; Update the bottom left tile
	ld   a, [bc]		
	ldi  [hl], a
	inc  c				; Next tile
	
	; Update the bottom right tile
	ld   a, [bc]		
	ld   [hl], a
	inc  c				; Next tile
	
	ld   a, [de]		; Read the upper byte of the next VRAM ptr
	cp   a, $FF		 	; Is it the $FF separator?
	jr   nz, .nextBlock	; If not, loop
	ret
	
; =============== Hat Switch ===============
; These functions are called during the hat switch sequence, called when getting a powerup.
; Each subroutine writes the GFX for a hat to the area of VRAM used during gameplay.
;
; As for why there are two sets of subroutines (primary and secondary), it's because to perform
; the effect, the hat GFX gets overwritten back and forth.
; There is no time to copy over all of the hat tiles, so only the primary set is
; switched during the animation.
; What the sets contain:
; - Primary -> main hat tiles
; - Secondary -> extra graphics used when climbing a ladder.
;
; [BUG]	The secondary set is only ever called at the end of the hat switch animation, 
; 		which is why the effect doesn't work properly when getting a powerup on a ladder.
; 		It could have been made to only switch between the two secondary sets in that case, but oh well...
ScreenEvent_Mode_NormalPot:
	ld   hl, GFX_NormalHat		; HL = GFX data
	ld   de, vGFXHatPrimary		; DE = Destination in VRAM
	ld   b, $40					; Copy 4 tiles
	call CopyBytes
	ret
ScreenEvent_Mode_BullPot:
	ld   hl, GFX_BullHat
	ld   de, vGFXHatPrimary
	ld   b, $40
	call CopyBytes
	ret
ScreenEvent_Mode_JetPot:
	ld   hl, GFX_JetHat
	ld   de, vGFXHatPrimary
	ld   b, $40
	call CopyBytes
	ret
ScreenEvent_Mode_DragonPot:
	ld   hl, GFX_DragonHat
	ld   de, vGFXHatPrimary
	ld   b, $40
	call CopyBytes
	ret
ScreenEvent_Mode_NormalPotSec:
	ld   hl, GFX_NormalHatSec
	ld   de, vGFXHatSecondary
	ld   b, $40
	call CopyBytes
	ret
ScreenEvent_Mode_BullPotSec:
	ld   hl, GFX_BullHatSec
	ld   de, vGFXHatSecondary
	ld   b, $40
	call CopyBytes
	ret
ScreenEvent_Mode_JetPotSec:
	ld   hl, GFX_JetHatSec
	ld   de, vGFXHatSecondary
	ld   b, $40
	call CopyBytes
	ret
ScreenEvent_Mode_DragonPotSec:
	ld   hl, GFX_DragonHatSec
	ld   de, vGFXHatSecondary
	ld   b, $40
	call CopyBytes
	ret
; =============== ScreenEvent_Mode_CreditsBar===============
; Draws the black textbox where the credits text appears.
; This is used to draw or clear the textbox area.
;
; One iteration draws one row.
ScreenEvent_Mode_CreditsBar:
	; HL = Where to start drawing the bars in the tilemap
	ld   a, [sBGTmpPtr]
	ld   h, a
	ld   a, [sBGTmpPtr+1]
	ld   l, a
	
	ld   b, $20		; 1 row
	ld   a, $5A 	; Black tile id in credits GFX
.loop:
	ldi  [hl], a	; Copy it over
	dec  b
	jr   nz, .loop
	ret
	
; =============== ScreenEvent_Mode_CreditsText1 ===============
; Write to the first line of the credits text.
;
; As it scrolls from the right, each iteration it writes the next letter of
; the top credits line.
;
; Due to the scrolling used, the whole text can't be copied in one go.
ScreenEvent_Mode_CreditsText1:;I
	ld   hl, sEndingText	; HL = Ending text for current line
	
	;--
	; Generate the index to the char array.
	; This is related to the screen scrolling, so when it fires off
	; it's incremented by 8px.
	;
	; As a result, we can determine the text index by doing Timer / 8.
	ld   a, [sCreditsTextTimer]	; 
	srl  a						; / 8
	srl  a
	srl  a
	ld   e, a
	ld   d, $00					
	add  hl, de					; Index the current letter
	;--
	ld   a, [sBGTmpPtr]			; DE = Where to write the tile
	ld   d, a
	ld   a, [sBGTmpPtr+1]
	ld   e, a
	;--
	ld   a, [hl]				; Read the tile to write
	cp   a, $FF					; Is the current character a terminator?
	jr   z, .eol				; If so, jump
	ld   [de], a				; Write the char to the tilemap
	ret
.eol:
	ld   a, $80
	ld   [sBGTmpPtr+1], a
	ret
	
; =============== ScreenEvent_Mode_CreditsText2 ===============
; Write the second row of credits text.
;
; Because of how the line is scrolled, the entire line can be copied in one iteration.
ScreenEvent_Mode_CreditsText2:
	ld   hl, sEndingText
	ld   de, vBGCreditsRow2		; DE = Location of second line in the tilemap
.loop:
	ldi  a, [hl]				; Get the next letter
	cp   a, $FF 				; Have we reached the $FF terminator?
	ret  z      				; If so, stop copying
	ld   [de], a				; Otherwise copy the char over
	inc  de
	jr   .loop
	
; =============== ScreenEvent_Mode_SavePipe ===============
; Copy the screen update data for the pipes in the save screen.
; This is used to animate the pipes when they are marked as a completed save.
;
; This assumes the tilemap has this sequence of tiles at vBGSavePipe, which
; coresponds to the pipe top:
;
; ###_###_###
;
; # = Where to copy tile
; _ = Tile to skip
;
ScreenEvent_Mode_SavePipe:
	ld   h, HIGH(sSavePipeAnimTiles)
	ld   l, LOW(sSavePipeAnimTiles)
	ld   de, vBGSavePipe	; DE = Location in the tilemap for the first pipe top

; Pipe 1 & 2
	ldi  a, [hl]			; Tile 1
	ld   [de], a
	inc  e
	ldi  a, [hl]			; Tile 2
	ld   [de], a
	inc  e
	ldi  a, [hl]			; Tile 3
	ld   [de], a
	inc  e 					
	
	inc  e					; There is a "separator" tile between the pipes. Skip it.
	
	; Pipe 2
	ldi  a, [hl]			; Tile 1
	ld   [de], a
	inc  e
	ldi  a, [hl]			; Tile 2
	ld   [de], a
	inc  e
	ldi  a, [hl]			; Tile 3
	ld   [de], a
	inc  e
	
	inc  e					; There is a "separator" tile between the pipes. Skip it.
	
	; Pipe 3
	ldi  a, [hl]			; Tile 1
	ld   [de], a
	inc  e
	ldi  a, [hl]			; Tile 2
	ld   [de], a
	inc  e
	ld   a, [hl]			; Tile 3
	ld   [de], a
	
	ret
; =============== LoadVRAM_TimeOver ===============
; Prepares the GFX and BG for displaying the Time Over screen.
LoadVRAM_TimeOver:
	call LoadGFX_CourseAlpha
	ld   hl, BGRLE_TimeUpHand
	ld   bc, BGMap_Begin
	call DecompressBG
	ld   hl, BGRLE_TimeUpWario
	ld   bc, WINDOWMap_Begin
	call DecompressBG
	ret
; =============== LoadVRAM_GameOver ===============
LoadVRAM_GameOver:
	call LoadGFX_CourseAlpha
	ld   hl, BGRLE_GameOver
	ld   bc, BGMap_Begin
	call DecompressBG
	ret
; =============== LoadGFX_CourseAlpha ===============
; Decompresses the art used for these purposes:
; - Course intro screen
; - Time over
; - Game over
;
; This also contains the default alphanumeric font used in various other GB games.
; [POI] Interestingly, this seems based off the font of an earlier version of SML2, at it contains Mario's head.
LoadGFX_CourseAlpha:
	ld   hl, GFXRLE_CourseAlpha
	call DecompressGFX
	ret
	
; =============== LoadGFX_WarioPowerHat ===============
; Writes the full hat graphics for the current Wario hat to VRAM.
; This copies both the main and secondary set of graphics.
;
; This is meant to only be used when getting a new powerup, as
; there's no handler for the default hat (which is also the hat loaded when Small Wario).
LoadGFX_WarioPowerHat:
	ld   a, [sPlPower]
	cp   a, PL_POW_BULL
	jr   z, .bull
	cp   a, PL_POW_JET
	jr   z, .jet
	cp   a, PL_POW_DRAGON
	jr   z, .dragon
	ret
.bull:
	ld   hl, GFX_BullHat	; HL = Source GFX
	jr   .writeGFX
.jet:
	ld   hl, GFX_JetHat		; HL = Source GFX
	jr   .writeGFX
.dragon:
	ld   hl, GFX_DragonHat	; HL = Source GFX
.writeGFX:
	; Copy main GFX set
	ld   de, $8000			; DE = Destination
	ld   b, $40
	call CopyBytes
	; Copy secondary GFX set (stored right after)
	ld   de, $83B0
	ld   b, $40
	call CopyBytes
	ret

; =============== WriteWarioOBJLst ===============
; Writes the sprite mappings for Wario during gameplay.
WriteWarioOBJLst:
	ld   hl, OBJLstPtrTable_Main
	; Calculate the relative Y pos.
	; NOTE: This is the value used for actor collision.
	ldh  a, [hScrollY]
	ld   b, a				; B = ScrollY
	ld   a, [sPlY_Low]	; A = WarioY
	add  ACT_Y_OFFSET	; Account for the origin used by sprite mappings.
	sub  a, b				; Result = WarioY + $10 - ScrollY
	ld   [sOAMWriteY], a
	ld   [sPlYRel], a
	; Calculate the relative X pos
	ld   a, [sScrollX]
	ld   b, a				; B = ScrollX
	ld   a, [sPlX_Low]	; A = WarioX
	add  ACT_X_OFFSET	; ""
	sub  a, b				; Result = WarioX + $08 - ScrollX
	ld   [sOAMWriteX], a
	ld   [sPlXRel], a
	
	ld   a, [sPlLstId]
	ld   [sOAMWriteLstId], a
	ld   a, [sPlFlags]
	ld   [sOAMWriteFlags], a
	call WriteOBJLst
	ret
	
; =============== NonGame_WriteWarioOBJLst ===============
; Writes the standard sprite mappings for Wario outside of gameplay.
; Used for unscrollable screens that aren't considered "static".
NonGame_WriteWarioOBJLst:
	ld   hl, OBJLstPtrTable_Main
	ld   a, [sPlYRel]
	ld   [sOAMWriteY], a
	ld   a, [sPlXRel]
	ld   [sOAMWriteX], a
	ld   a, [sPlLstId]
	ld   [sOAMWriteLstId], a
	ld   a, [sPlFlags]
	ld   [sOAMWriteFlags], a
	call WriteOBJLst
	ret
	
; =============== NonGame_WriteExActOBJLst ===============
; Writes the sprite mappings for extra actors outside of gameplay.
; Used for unscrollable screens that aren't considered "static".
NonGame_WriteExActOBJLst:
	; Make sure the actor wasn't despawned
	ld   a, [sExActSet]
	and  a
	ret  z
	
	ld   hl, OBJLstPtrTable_Main
	ld   a, [sExActOBJFixY]
	ld   [sOAMWriteY], a
	ld   [sExActOBJYRel], a
	ld   a, [sExActOBJFixX]
	ld   [sOAMWriteX], a
	ld   [sExActOBJXRel], a
	ld   a, [sExActOBJLstId]
	ld   [sOAMWriteLstId], a
	ld   a, [sExActOBJFlags]
	ld   [sOAMWriteFlags], a
	call WriteOBJLst
	ret

; =============== WriteExActOBJLst ===============
; Writes the sprite mappings for extra actors (during gameplay).
WriteExActOBJLst:
	; Make sure the actor wasn't despawned
	ld   a, [sExActSet]
	and  a
	ret  z
	
	ld   hl, OBJLstPtrTable_Main
	; Calculate the relative Y pos.
	; NOTE: This is the value used for actor collision.
	ldh  a, [hScrollY]		
	ld   b, a				; B = ScrollY
	ld   a, [sExActOBJY_Low]; A = ExActY
	add  ACT_Y_OFFSET	; Account for the origin used by sprite mappings.
	sub  a, b				; Result = ExActY + $10 - ScrollY
	ld   [sOAMWriteY], a
	ld   [sExActOBJYRel], a
	; Calculate the relative X pos
	ld   a, [sScrollX]		
	ld   b, a				; B = ScrollX
	ld   a, [sExActOBJX_Low]; A = ExActX
	add  ACT_X_OFFSET	; ""
	sub  a, b				; Result = ExActX + $08 - ScrollX
	ld   [sOAMWriteX], a
	ld   [sExActOBJXRel], a
	
	ld   a, [sExActOBJLstId]
	ld   [sOAMWriteLstId], a
	ld   a, [sExActOBJFlags]
	ld   [sOAMWriteFlags], a
	call WriteOBJLst
	ret
	
	
; =============== WriteOBJLst ===============
; Writes an entire OBJ list (sprite mappings).
;
; This is the main subroutine for drawing OBJLst, used for:
; - Drawing Wario across multiple game modes
; - OBJ set up by ExAct
;
; The OBJ lists, as the name implies, are stored as a list of OAM OBJ (sprites).
;
; As a result an OBJLst is made of several entries one after the other, with each entry having:
; - Y Coord (relative to the origin)
; - X Coord (relative to the origin)
; - Tile ID
; - Flags
;
; It's also possible to specify special flags for this subroutine, which
; can be used to X/Y flip the entire OBJLst (both the OBJ flip and the mapping position).
; 
; The end of the list is marked by a single $80 entry.
;
;
; IN
; - HL: Ptr to table of OBJLst
WriteOBJLst:
	; Index the sprite mappings table
	ld   a, [sOAMWriteLstId]
	ld   d, $00					; DE = A * 2
	ld   e, a
	sla  e						; do *2 from here, in case A would have overflowed for high mapping IDs
	rl   d						; and preserve the carry
	add  hl, de
	
	ldi  a, [hl]				; DE = Ptr to sprite mapping
	ld   e, a
	ld   a, [hl]
	ld   d, a
	ld   h, HIGH(sWorkOAM)		; HL = Current OAM mirror position
	ld   a, [sWorkOAMPos]
	ld   l, a
	
	ld   a, [sOAMWriteY]		; B = Base Y position
	ld   b, a
	ld   a, [sOAMWriteX]		; C = Base X position
	ld   c, a
.loop:
	ld   a, l
	cp   a, $A0					; Have we gone past the end of the OAM mirror? (HL >= $AFA0)
	ret  nc						; If so, return. We don't want glitchy sprites.
	
	ld   a, [de]
	cp   a, $80					; Have we reached the end separator? (first byte of entry $80)
	ret  z						; If so, return
	
.doYCoord:
	; [TCRF] The vertical flip flag is never set for calls to this subroutine.
	ld   a, [sOAMWriteFlags]
	bit  6, a
	jr   z, .noYFlip
	ld   a, [de]				; A = Relative Y position
	cpl							; Invert the Y position
	sub  a, $07					; And fix the alignment since the Y origin should be on the top
	jr   .writeY
.noYFlip:
	ld   a, [de]				; A = Relative Y position
.writeY:
	add  b						; Add the base Y position
	ldi  [hl], a				; Write it the OAM copy
	inc  de						; OAMLstPtr++
	
	; Do the same for the X coord
.doXCoord:
	ld   a, [sOAMWriteFlags]	; Check for X flip
	bit  5, a
	jr   z, .noXFlip
	ld   a, [de]				; A = Relative X position
	cpl							; Invert the X position
	sub  a, $07					; And fix the alignment since the X origin should be on the left
	jr   .writeX
.noXFlip:
	ld   a, [de]				; A = Relative X position
.writeX:
	add  c					; Add the base X offset
	ldi  [hl], a				; Write it the OAM copy
	inc  de						; OAMLstPtr++
	
.writeTileId:
	ld   a, [de]				; Set the tile ID to use
	ldi  [hl], a
	inc  de
	
.writeFlags:
	push hl
	ld   hl, sOAMWriteFlags
	; A = DefaultFlags v CustomFlags
	ld   a, [de]
	xor  a, [hl]				; Reverse the requested OAM flag bits
	pop  hl
	ldi  [hl], a				; Save the flags
	
	ld   a, l					; Update the cursor	
	ld   [sWorkOAMPos], a
	inc  de
	jr   .loop
	
; ========================================
; Common OBJ GFX (Wario, ...)	
GFX_Level_SharedOBJ: INCBIN "data/gfx/level/shared_obj.bin"

; ========================================
; Powerup GFX
; The "secondary" graphics must be stored after the normal ones.

GFX_NormalHat: 		INCBIN "data/gfx/hats/normal.bin"
GFX_NormalHatSec: 	INCBIN "data/gfx/hats/normal_secondary.bin"
GFX_BullHat: 		INCBIN "data/gfx/hats/bull.bin"
GFX_BullHatSec:		INCBIN "data/gfx/hats/bull_secondary.bin"
GFX_JetHat: 		INCBIN "data/gfx/hats/jet.bin"
GFX_JetHatSec: 		INCBIN "data/gfx/hats/jet_secondary.bin"
GFX_DragonHat: 		INCBIN "data/gfx/hats/dragon.bin"
GFX_DragonHatSec:	INCBIN "data/gfx/hats/dragon_secondary.bin"

; ========================================
GFXRLE_CourseAlpha:	INCBIN "data/gfx/alpha_gameover_timeup.rlc"
BGRLE_TimeUpHand:	INCBIN "data/bg/timeup_hand.rls";
BGRLE_TimeUpWario:	INCBIN "data/bg/timeup_wario.rls";
BGRLE_GameOver:		INCBIN "data/bg/gameover.rls";
; ========================================
GFX_Level_StoneCastle: INCBIN "data/gfx/level/level_stonecastle.bin"

; =============== OBJLstPtrTable_Main ===============
; Main OBJLst table.
OBJLstPtrTable_Main: 
	dw OBJLst_Wario_None
	dw OBJLst_Wario_Walk0
	dw OBJLst_Wario_Walk1
	dw OBJLst_Wario_Walk2
	dw OBJLst_Wario_Walk3
	dw OBJLst_HitBlock
	dw OBJLst_Wario_Throw
	dw OBJLst_Wario_JumpThrow
	dw OBJLst_Wario_Stand
	dw OBJLst_Wario_Idle0
	dw OBJLst_Wario_Idle1
	dw OBJLst_Hat
	dw OBJLst_Unused_Wario_GroundPound ; [TCRF] Old version of ground pound frame?; broken graphics
	dw OBJLst_JetHatFlame0
	dw OBJLst_JetHatFlame1
	dw OBJLst_JetHatFlame2
	dw OBJLst_Wario_Duck ; $10
	dw OBJLst_Wario_DuckWalk
	dw OBJLst_Wario_Climb0
	dw OBJLst_Wario_Climb1
	dw OBJLst_Wario_Bump
	dw OBJLst_DragonHatFlameA0
	dw OBJLst_DragonHatFlameA1
	dw OBJLst_DragonHatFlameA2
	dw OBJLst_Wario_Swim0
	dw OBJLst_Wario_Swim1
	dw OBJLst_Wario_Dead
	dw OBJLst_DragonHatFlameB0
	dw OBJLst_DragonHatFlameB1
	dw OBJLst_DragonHatFlameB2
	dw OBJLst_Wario_Swim2
	dw OBJLst_Wario_BumpAir
	dw OBJLst_Wario_Jump ; $20
	dw OBJLst_Wario_GroundPound
	dw OBJLst_Wario_DashJump
	dw OBJLst_Wario_DashEnemy
	dw OBJLst_Wario_Dash0	; Some used for part of afterimage effect
	dw OBJLst_Wario_Dash1
	dw OBJLst_Wario_Dash2
	dw OBJLst_Wario_Dash3
	dw OBJLst_Wario_Dash4
	dw OBJLst_Wario_Dash5
	dw OBJLst_Wario_Dash6
	dw OBJLst_DragonHatFlameC0
	dw OBJLst_DragonHatFlameC1
	dw OBJLst_DragonHatFlameC2
	dw OBJLst_DragonHatFlameD0
	dw OBJLst_DragonHatFlameD1
	dw OBJLst_DragonHatFlameD2 ; $30
	dw OBJLst_SmallWario_Walk0
	dw OBJLst_SmallWario_Walk1
	dw OBJLst_SmallWario_Walk2
	dw OBJLst_Wario_LevelClear0
	dw OBJLst_Wario_LevelClear1
	dw OBJLst_Wario_None
	dw OBJLst_TrRoom_Arrow ; 37
	dw OBJLst_SmallWario_Stand
	dw OBJLst_SmallWario_Idle
	dw OBJLst_DragonHatFlameE0
	dw OBJLst_DragonHatFlameE1
	dw OBJLst_DragonHatFlameE2
	dw OBJLst_DragonHatFlameF0
	dw OBJLst_DragonHatFlameF1
	dw OBJLst_DragonHatFlameF2
	dw OBJLst_Unused_Main_40 ; $40 [TCRF] Broken graphics (same broken tiles for OBJLst_Unused_Wario_GroundPound)
	dw OBJLst_Wario_Grab
	dw OBJLst_SmallWario_Climb0
	dw OBJLst_SmallWario_Climb1
	dw OBJLst_Wario_DuckHold
	dw OBJLst_Wario_DuckWalkHold
	dw OBJLst_Wario_DuckThrow
	dw OBJLst_SmallWario_Hold
	dw OBJLst_SmallWario_Swim0
	dw OBJLst_SmallWario_Swim1
	dw OBJLst_SmallWario_HoldWalk0
	dw OBJLst_SmallWario_HoldWalk1
	dw OBJLst_SmallWario_HoldWalk2
	dw OBJLst_SmallWario_HoldJump
	dw OBJLst_SmallWario_Swim2
	dw OBJLst_Wario_DashFly
	dw OBJLst_SmallWario_Jump ; $50
	dw OBJLst_Wario_HoldWalk0
	dw OBJLst_Wario_HoldWalk1
	dw OBJLst_Wario_HoldWalk2
	dw OBJLst_Wario_HoldWalk3
	dw OBJLst_WaterSplash0
	dw OBJLst_WaterSplash1
	dw OBJLst_WaterSplash2
	dw OBJLst_Wario_Hold
	dw OBJLst_BlockSmash0
	dw OBJLst_BlockSmash1
	dw OBJLst_BlockSmash2
	dw OBJLst_BlockSmash3
	dw OBJLst_BlockSmash4
	dw OBJLst_BlockSmash5
	dw OBJLst_BlockSmash6
	dw OBJLst_BlockSmash7 ; $60
	dw OBJLst_BlockSmash8
	dw OBJLst_Unused_BlockSmash9 ;[TCRF] Extra frame for block debris; not used
	dw OBJLst_SaveSel_Hat
	dw OBJLst_SmallWario_LevelClear
	dw OBJLst_SaveSel_BombWario0
	dw OBJLst_SaveSel_BombWario1
	dw OBJLst_SaveSel_BombWario2
	dw OBJLst_SaveSel_Wario_Dash0
	dw OBJLst_SaveSel_Wario_Dash1
	dw OBJLst_SaveSel_Wario_Dash2
	dw OBJLst_SaveSel_Wario_Dash3
	dw OBJLst_SaveSel_Wario_Dash4
	dw OBJLst_SaveSel_Wario_Dash5
	dw OBJLst_SaveSel_Wario_Dash6
	dw OBJLst_SaveSel_Wario_Bump
	dw OBJLst_Wario_HoldJump ; $70
	dw OBJLst_Wario_HoldGroundPound
	dw OBJLst_SaveSel_OldHat0
	dw OBJLst_SaveSel_OldHat1
	dw OBJLst_SaveSel_OldHat2
	dw OBJLst_SaveSel_Wario_JumpNoHat
	dw OBJLst_SaveSel_Wario_StandNoHat ; [TCRF] Duplicate entry; not used
	dw OBJLst_DragonHatWaterA0
	dw OBJLst_DragonHatWaterA1
	dw OBJLst_DragonHatWaterA2
	dw OBJLst_DragonHatWaterB0
	dw OBJLst_DragonHatWaterB1
	dw OBJLst_DragonHatWaterB2
	dw OBJLst_DragonHatWaterC0
	dw OBJLst_DragonHatWaterC1
	dw OBJLst_DragonHatWaterC2
	dw OBJLst_DragonHatWaterD0 ; $80
	dw OBJLst_DragonHatWaterD1
	dw OBJLst_DragonHatWaterD2
	dw OBJLst_DragonHatWaterE0
	dw OBJLst_DragonHatWaterE1
	dw OBJLst_DragonHatWaterE2
	dw OBJLst_DragonHatWaterF0
	dw OBJLst_DragonHatWaterF1
	dw OBJLst_DragonHatWaterF2
	dw OBJLst_TrRoom_Wario_Shrug
	dw OBJLst_TrRoom_Wario_Gloat 
	dw OBJLst_TrRoom_Wario_Idle0 
	dw OBJLst_TrRoom_Wario_Idle1 
	dw OBJLst_SaveSel_Cross
	dw OBJLst_TrRoom_TreasureC0
	dw OBJLst_TrRoom_TreasureC1 
	dw OBJLst_TrRoom_TreasureI0 ; $90
	dw OBJLst_TrRoom_TreasureI1
	dw OBJLst_TrRoom_TreasureF0
	dw OBJLst_TrRoom_TreasureF1
	dw OBJLst_TrRoom_TreasureO0
	dw OBJLst_TrRoom_TreasureO1
	dw OBJLst_TrRoom_TreasureA0
	dw OBJLst_TrRoom_TreasureA1
	dw OBJLst_TrRoom_TreasureN0
	dw OBJLst_TrRoom_TreasureN1
	dw OBJLst_TrRoom_TreasureH0
	dw OBJLst_TrRoom_TreasureH1
	dw OBJLst_TrRoom_TreasureM0
	dw OBJLst_TrRoom_TreasureM1
	dw OBJLst_TrRoom_TreasureL0
	dw OBJLst_TrRoom_TreasureL1
	dw OBJLst_TrRoom_TreasureK0 ; $A0
	dw OBJLst_TrRoom_TreasureK1
	dw OBJLst_TrRoom_TreasureB0
	dw OBJLst_TrRoom_TreasureB1
	dw OBJLst_TrRoom_TreasureD0
	dw OBJLst_TrRoom_TreasureD1
	dw OBJLst_TrRoom_TreasureG0
	dw OBJLst_TrRoom_TreasureG1
	dw OBJLst_TrRoom_TreasureJ0
	dw OBJLst_TrRoom_TreasureJ1
	dw OBJLst_TrRoom_TreasureE0
	dw OBJLst_TrRoom_TreasureE1
	dw OBJLst_TrRoom_Star00 
	dw OBJLst_TrRoom_Star01 
	dw OBJLst_TrRoom_Star02 
	dw OBJLst_TrRoom_Star03 
	dw OBJLst_TrRoom_Star04 ; $B0
	dw OBJLst_TrRoom_Star05 
	dw OBJLst_TrRoom_Star06 
	dw OBJLst_TrRoom_Star07
	dw OBJLst_TrRoom_Star08
	dw OBJLst_Wario_None
	dw OBJLst_TrRoom_Star09
	dw OBJLst_Wario_None
	dw OBJLst_TrRoom_Star0A
	dw OBJLst_TrRoom_Star0B
	dw OBJLst_TrRoom_Star0B
	dw OBJLst_TrRoom_Star0A
	dw OBJLst_Coin0
	dw OBJLst_Coin1
	dw OBJLst_Coin2
	dw OBJLst_Coin1
	dw OBJLst_1UP ; $C0
	dw OBJLst_SaveSel_Smoke0
	dw OBJLst_SaveSel_Smoke1
	dw OBJLst_SaveSel_Smoke2
	dw OBJLst_3UP 
	dw OBJLst_TrRoom_MoneyBags1
	dw OBJLst_TrRoom_MoneyBags2
	dw OBJLst_TrRoom_MoneyBags3
	dw OBJLst_TrRoom_MoneyBags4
	dw OBJLst_TrRoom_MoneyBags5
	dw OBJLst_TrRoom_MoneyBags6
	dw OBJLst_TrRoom_MoneyBagFall
	dw OBJLst_SaveSel_Wario_StandNoHat
	dw OBJLst_SaveSel_Wario_LookBack
	dw OBJLst_SaveSel_Wario_LookUp

;----------------------------
OBJLst_Wario_None: INCBIN "data/objlst/wario/wario_none.bin"
OBJLst_Wario_Walk0: INCBIN "data/objlst/wario/wario_walk0.bin"
OBJLst_Wario_Walk1: INCBIN "data/objlst/wario/wario_walk1.bin"
OBJLst_Wario_Walk2: INCBIN "data/objlst/wario/wario_walk2.bin"
OBJLst_Wario_Walk3: INCBIN "data/objlst/wario/wario_walk3.bin"
OBJLst_HitBlock: INCBIN "data/objlst/level/hitblock.bin"
OBJLst_Wario_Throw: INCBIN "data/objlst/wario/wario_throw.bin"
OBJLst_Wario_JumpThrow: INCBIN "data/objlst/wario/wario_jumpthrow.bin"
OBJLst_Wario_Stand: INCBIN "data/objlst/wario/wario_stand.bin"
OBJLst_Wario_Idle0: INCBIN "data/objlst/wario/wario_idle0.bin"
OBJLst_Wario_Idle1: INCBIN "data/objlst/wario/wario_idle1.bin"
OBJLst_Hat: INCBIN "data/objlst/wario/hat.bin"
OBJLst_Unused_Wario_GroundPound: INCBIN "data/objlst/wario/unused_wario_groundpound.bin"
OBJLst_JetHatFlame0: INCBIN "data/objlst/wario/jethatflame0.bin"
OBJLst_JetHatFlame1: INCBIN "data/objlst/wario/jethatflame1.bin"
OBJLst_JetHatFlame2: INCBIN "data/objlst/wario/jethatflame2.bin"
OBJLst_Wario_Duck: INCBIN "data/objlst/wario/wario_duck.bin"
OBJLst_Wario_DuckWalk: INCBIN "data/objlst/wario/wario_duckwalk.bin"
OBJLst_Wario_Climb0: INCBIN "data/objlst/wario/wario_climb0.bin"
OBJLst_Wario_Climb1: INCBIN "data/objlst/wario/wario_climb1.bin"
OBJLst_Wario_Bump: INCBIN "data/objlst/wario/wario_bump.bin"
OBJLst_DragonHatFlameA0: INCBIN "data/objlst/wario/dragonhatflamea0.bin"
OBJLst_DragonHatFlameA1: INCBIN "data/objlst/wario/dragonhatflamea1.bin"
OBJLst_DragonHatFlameA2: INCBIN "data/objlst/wario/dragonhatflamea2.bin"
OBJLst_Wario_Swim0: INCBIN "data/objlst/wario/wario_swim0.bin"
OBJLst_Wario_Swim1: INCBIN "data/objlst/wario/wario_swim1.bin"
OBJLst_Wario_Swim2: INCBIN "data/objlst/wario/wario_swim2.bin"
OBJLst_Wario_Dead: INCBIN "data/objlst/wario/wario_dead.bin"
OBJLst_DragonHatFlameB0: INCBIN "data/objlst/wario/dragonhatflameb0.bin"
OBJLst_DragonHatFlameB1: INCBIN "data/objlst/wario/dragonhatflameb1.bin"
OBJLst_DragonHatFlameB2: INCBIN "data/objlst/wario/dragonhatflameb2.bin"
OBJLst_Wario_BumpAir: INCBIN "data/objlst/wario/wario_bumpair.bin"
OBJLst_Wario_Jump: INCBIN "data/objlst/wario/wario_jump.bin"
OBJLst_Wario_GroundPound: INCBIN "data/objlst/wario/wario_groundpound.bin"
OBJLst_Wario_DashJump: INCBIN "data/objlst/wario/wario_dashjump.bin"
OBJLst_Wario_DashEnemy: INCBIN "data/objlst/wario/wario_dashenemy.bin"
OBJLst_Wario_Dash0: INCBIN "data/objlst/wario/wario_dash0.bin"
OBJLst_Wario_Dash1: INCBIN "data/objlst/wario/wario_dash1.bin"
OBJLst_Wario_Dash2: INCBIN "data/objlst/wario/wario_dash2.bin"
OBJLst_Wario_Dash3: INCBIN "data/objlst/wario/wario_dash3.bin"
OBJLst_Wario_Dash4: INCBIN "data/objlst/wario/wario_dash4.bin"
OBJLst_Wario_Dash5: INCBIN "data/objlst/wario/wario_dash5.bin"
OBJLst_Wario_Dash6: INCBIN "data/objlst/wario/wario_dash6.bin"
OBJLst_DragonHatFlameC0: INCBIN "data/objlst/wario/dragonhatflamec0.bin"
OBJLst_DragonHatFlameC1: INCBIN "data/objlst/wario/dragonhatflamec1.bin"
OBJLst_DragonHatFlameC2: INCBIN "data/objlst/wario/dragonhatflamec2.bin"
OBJLst_DragonHatFlameD0: INCBIN "data/objlst/wario/dragonhatflamed0.bin"
OBJLst_DragonHatFlameD1: INCBIN "data/objlst/wario/dragonhatflamed1.bin"
OBJLst_DragonHatFlameD2: INCBIN "data/objlst/wario/dragonhatflamed2.bin"
OBJLst_SmallWario_Walk0: INCBIN "data/objlst/wario/smallwario_walk0.bin"
OBJLst_SmallWario_Walk1: INCBIN "data/objlst/wario/smallwario_walk1.bin"
OBJLst_SmallWario_Walk2: INCBIN "data/objlst/wario/smallwario_walk2.bin"
OBJLst_Wario_LevelClear0: INCBIN "data/objlst/wario/wario_levelclear0.bin"
OBJLst_Wario_LevelClear1: INCBIN "data/objlst/wario/wario_levelclear1.bin"
OBJLst_TrRoom_Arrow: INCBIN "data/objlst/trroom/arrow.bin"
OBJLst_SmallWario_Stand: INCBIN "data/objlst/wario/smallwario_stand.bin"
OBJLst_SmallWario_Idle: INCBIN "data/objlst/wario/smallwario_idle.bin"
OBJLst_DragonHatFlameE0: INCBIN "data/objlst/wario/dragonhatflamee0.bin"
OBJLst_DragonHatFlameE1: INCBIN "data/objlst/wario/dragonhatflamee1.bin"
OBJLst_DragonHatFlameE2: INCBIN "data/objlst/wario/dragonhatflamee2.bin"
OBJLst_DragonHatFlameF0: INCBIN "data/objlst/wario/dragonhatflamef0.bin"
OBJLst_DragonHatFlameF1: INCBIN "data/objlst/wario/dragonhatflamef1.bin"
OBJLst_DragonHatFlameF2: INCBIN "data/objlst/wario/dragonhatflamef2.bin"
OBJLst_Unused_Main_40: INCBIN "data/objlst/wario/unused_main_40.bin"
OBJLst_Wario_Grab: INCBIN "data/objlst/wario/wario_grab.bin"
OBJLst_SmallWario_Climb0: INCBIN "data/objlst/wario/smallwario_climb0.bin"
OBJLst_SmallWario_Climb1: INCBIN "data/objlst/wario/smallwario_climb1.bin"
OBJLst_Wario_DuckHold: INCBIN "data/objlst/wario/wario_duckhold.bin"
OBJLst_Wario_DuckWalkHold: INCBIN "data/objlst/wario/wario_duckwalkhold.bin"
OBJLst_Wario_DuckThrow: INCBIN "data/objlst/wario/wario_duckthrow.bin"
OBJLst_SmallWario_Hold: INCBIN "data/objlst/wario/smallwario_hold.bin"
OBJLst_SmallWario_Swim0: INCBIN "data/objlst/wario/smallwario_swim0.bin"
OBJLst_SmallWario_Swim1: INCBIN "data/objlst/wario/smallwario_swim1.bin"
OBJLst_SmallWario_HoldWalk0: INCBIN "data/objlst/wario/smallwario_holdwalk0.bin"
OBJLst_SmallWario_HoldWalk1: INCBIN "data/objlst/wario/smallwario_holdwalk1.bin"
OBJLst_SmallWario_HoldWalk2: INCBIN "data/objlst/wario/smallwario_holdwalk2.bin"
OBJLst_SmallWario_HoldJump: INCBIN "data/objlst/wario/smallwario_holdjump.bin"
OBJLst_SmallWario_Swim2: INCBIN "data/objlst/wario/smallwario_swim2.bin"
OBJLst_Wario_DashFly: INCBIN "data/objlst/wario/wario_dashfly.bin"
OBJLst_SmallWario_Jump: INCBIN "data/objlst/wario/smallwario_jump.bin"
OBJLst_Wario_HoldWalk0: INCBIN "data/objlst/wario/wario_holdwalk0.bin"
OBJLst_Wario_HoldWalk1: INCBIN "data/objlst/wario/wario_holdwalk1.bin"
OBJLst_Wario_HoldWalk2: INCBIN "data/objlst/wario/wario_holdwalk2.bin"
OBJLst_Wario_HoldWalk3: INCBIN "data/objlst/wario/wario_holdwalk3.bin"
OBJLst_WaterSplash0: INCBIN "data/objlst/wario/watersplash0.bin"
OBJLst_WaterSplash1: INCBIN "data/objlst/wario/watersplash1.bin"
OBJLst_WaterSplash2: INCBIN "data/objlst/wario/watersplash2.bin"
OBJLst_Wario_Hold: INCBIN "data/objlst/wario/wario_hold.bin"
OBJLst_BlockSmash0: INCBIN "data/objlst/level/blocksmash0.bin"
OBJLst_BlockSmash1: INCBIN "data/objlst/level/blocksmash1.bin"
OBJLst_BlockSmash2: INCBIN "data/objlst/level/blocksmash2.bin"
OBJLst_BlockSmash3: INCBIN "data/objlst/level/blocksmash3.bin"
OBJLst_BlockSmash4: INCBIN "data/objlst/level/blocksmash4.bin"
OBJLst_BlockSmash5: INCBIN "data/objlst/level/blocksmash5.bin"
OBJLst_BlockSmash6: INCBIN "data/objlst/level/blocksmash6.bin"
OBJLst_BlockSmash7: INCBIN "data/objlst/level/blocksmash7.bin"
OBJLst_BlockSmash8: INCBIN "data/objlst/level/blocksmash8.bin"
OBJLst_Unused_BlockSmash9: INCBIN "data/objlst/level/unused_blocksmash9.bin"
OBJLst_SaveSel_Hat: INCBIN "data/objlst/saveselect/hat.bin"
OBJLst_SmallWario_LevelClear: INCBIN "data/objlst/wario/smallwario_levelclear.bin"
OBJLst_SaveSel_BombWario0: INCBIN "data/objlst/saveselect/bombwario0.bin"
OBJLst_SaveSel_BombWario1: INCBIN "data/objlst/saveselect/bombwario1.bin"
OBJLst_SaveSel_BombWario2: INCBIN "data/objlst/saveselect/bombwario2.bin"
OBJLst_SaveSel_Wario_Dash0: INCBIN "data/objlst/saveselect/wario_dash0.bin"
OBJLst_SaveSel_Wario_Dash1: INCBIN "data/objlst/saveselect/wario_dash1.bin"
OBJLst_SaveSel_Wario_Dash2: INCBIN "data/objlst/saveselect/wario_dash2.bin"
OBJLst_SaveSel_Wario_Dash3: INCBIN "data/objlst/saveselect/wario_dash3.bin"
OBJLst_SaveSel_Wario_Dash4: INCBIN "data/objlst/saveselect/wario_dash4.bin"
OBJLst_SaveSel_Wario_Dash5: INCBIN "data/objlst/saveselect/wario_dash5.bin"
OBJLst_SaveSel_Wario_Dash6: INCBIN "data/objlst/saveselect/wario_dash6.bin"
OBJLst_SaveSel_Wario_Bump: INCBIN "data/objlst/saveselect/wario_bump.bin"
OBJLst_Wario_HoldJump: INCBIN "data/objlst/wario/wario_holdjump.bin"
OBJLst_Wario_HoldGroundPound: INCBIN "data/objlst/wario/wario_holdgroundpound.bin"
OBJLst_SaveSel_OldHat0: INCBIN "data/objlst/saveselect/oldhat0.bin"
OBJLst_SaveSel_OldHat1: INCBIN "data/objlst/saveselect/oldhat1.bin"
OBJLst_SaveSel_OldHat2: INCBIN "data/objlst/saveselect/oldhat2.bin"
OBJLst_SaveSel_Wario_JumpNoHat: INCBIN "data/objlst/saveselect/wario_jumpnohat.bin"
OBJLst_SaveSel_Wario_StandNoHat: INCBIN "data/objlst/saveselect/wario_standnohat.bin"
OBJLst_DragonHatWaterA0: INCBIN "data/objlst/wario/dragonhatwatera0.bin"
OBJLst_DragonHatWaterA1: INCBIN "data/objlst/wario/dragonhatwatera1.bin"
OBJLst_DragonHatWaterA2: INCBIN "data/objlst/wario/dragonhatwatera2.bin"
OBJLst_DragonHatWaterB0: INCBIN "data/objlst/wario/dragonhatwaterb0.bin"
OBJLst_DragonHatWaterB1: INCBIN "data/objlst/wario/dragonhatwaterb1.bin"
OBJLst_DragonHatWaterB2: INCBIN "data/objlst/wario/dragonhatwaterb2.bin"
OBJLst_DragonHatWaterC0: INCBIN "data/objlst/wario/dragonhatwaterc0.bin"
OBJLst_DragonHatWaterC1: INCBIN "data/objlst/wario/dragonhatwaterc1.bin"
OBJLst_DragonHatWaterC2: INCBIN "data/objlst/wario/dragonhatwaterc2.bin"
OBJLst_DragonHatWaterD0: INCBIN "data/objlst/wario/dragonhatwaterd0.bin"
OBJLst_DragonHatWaterD1: INCBIN "data/objlst/wario/dragonhatwaterd1.bin"
OBJLst_DragonHatWaterD2: INCBIN "data/objlst/wario/dragonhatwaterd2.bin"
OBJLst_DragonHatWaterE0: INCBIN "data/objlst/wario/dragonhatwatere0.bin"
OBJLst_DragonHatWaterE1: INCBIN "data/objlst/wario/dragonhatwatere1.bin"
OBJLst_DragonHatWaterE2: INCBIN "data/objlst/wario/dragonhatwatere2.bin"
OBJLst_DragonHatWaterF0: INCBIN "data/objlst/wario/dragonhatwaterf0.bin"
OBJLst_DragonHatWaterF1: INCBIN "data/objlst/wario/dragonhatwaterf1.bin"
OBJLst_DragonHatWaterF2: INCBIN "data/objlst/wario/dragonhatwaterf2.bin"
OBJLst_TrRoom_Wario_Shrug: INCBIN "data/objlst/trroom/wario_shrug.bin"
OBJLst_TrRoom_Wario_Gloat: INCBIN "data/objlst/trroom/wario_gloat.bin"
OBJLst_TrRoom_Wario_Idle0: INCBIN "data/objlst/trroom/wario_idle0.bin"
OBJLst_TrRoom_Wario_Idle1: INCBIN "data/objlst/trroom/wario_idle1.bin"
OBJLst_SaveSel_Cross: INCBIN "data/objlst/saveselect/cross.bin"
OBJLst_TrRoom_TreasureC0: INCBIN "data/objlst/trroom/treasure_c0.bin"
OBJLst_TrRoom_TreasureC1: INCBIN "data/objlst/trroom/treasure_c1.bin"
OBJLst_TrRoom_TreasureI0: INCBIN "data/objlst/trroom/treasure_i0.bin"
OBJLst_TrRoom_TreasureI1: INCBIN "data/objlst/trroom/treasure_i1.bin"
OBJLst_TrRoom_TreasureF0: INCBIN "data/objlst/trroom/treasure_f0.bin"
OBJLst_TrRoom_TreasureF1: INCBIN "data/objlst/trroom/treasure_f1.bin"
OBJLst_TrRoom_TreasureO0: INCBIN "data/objlst/trroom/treasure_o0.bin"
OBJLst_TrRoom_TreasureO1: INCBIN "data/objlst/trroom/treasure_o1.bin"
OBJLst_TrRoom_TreasureA0: INCBIN "data/objlst/trroom/treasure_a0.bin"
OBJLst_TrRoom_TreasureA1: INCBIN "data/objlst/trroom/treasure_a1.bin"
OBJLst_TrRoom_TreasureN0: INCBIN "data/objlst/trroom/treasure_n0.bin"
OBJLst_TrRoom_TreasureN1: INCBIN "data/objlst/trroom/treasure_n1.bin"
OBJLst_TrRoom_TreasureH0: INCBIN "data/objlst/trroom/treasure_h0.bin"
OBJLst_TrRoom_TreasureH1: INCBIN "data/objlst/trroom/treasure_h1.bin"
OBJLst_TrRoom_TreasureM0: INCBIN "data/objlst/trroom/treasure_m0.bin"
OBJLst_TrRoom_TreasureM1: INCBIN "data/objlst/trroom/treasure_m1.bin"
OBJLst_TrRoom_TreasureL0: INCBIN "data/objlst/trroom/treasure_l0.bin"
OBJLst_TrRoom_TreasureL1: INCBIN "data/objlst/trroom/treasure_l1.bin"
OBJLst_TrRoom_TreasureK0: INCBIN "data/objlst/trroom/treasure_k0.bin"
OBJLst_TrRoom_TreasureK1: INCBIN "data/objlst/trroom/treasure_k1.bin"
OBJLst_TrRoom_TreasureB0: INCBIN "data/objlst/trroom/treasure_b0.bin"
OBJLst_TrRoom_TreasureB1: INCBIN "data/objlst/trroom/treasure_b1.bin"
OBJLst_TrRoom_TreasureD0: INCBIN "data/objlst/trroom/treasure_d0.bin"
OBJLst_TrRoom_TreasureD1: INCBIN "data/objlst/trroom/treasure_d1.bin"
OBJLst_TrRoom_TreasureG0: INCBIN "data/objlst/trroom/treasure_g0.bin"
OBJLst_TrRoom_TreasureG1: INCBIN "data/objlst/trroom/treasure_g1.bin"
OBJLst_TrRoom_TreasureJ0: INCBIN "data/objlst/trroom/treasure_j0.bin"
OBJLst_TrRoom_TreasureJ1: INCBIN "data/objlst/trroom/treasure_j1.bin"
OBJLst_TrRoom_TreasureE0: INCBIN "data/objlst/trroom/treasure_e0.bin"
OBJLst_TrRoom_TreasureE1: INCBIN "data/objlst/trroom/treasure_e1.bin"
OBJLst_TrRoom_Star00: INCBIN "data/objlst/trroom/star00.bin"
OBJLst_TrRoom_Star01: INCBIN "data/objlst/trroom/star01.bin"
OBJLst_TrRoom_Star02: INCBIN "data/objlst/trroom/star02.bin"
OBJLst_TrRoom_Star03: INCBIN "data/objlst/trroom/star03.bin"
OBJLst_TrRoom_Star04: INCBIN "data/objlst/trroom/star04.bin"
OBJLst_TrRoom_Star05: INCBIN "data/objlst/trroom/star05.bin"
OBJLst_TrRoom_Star06: INCBIN "data/objlst/trroom/star06.bin"
OBJLst_TrRoom_Star07: INCBIN "data/objlst/trroom/star07.bin"
OBJLst_TrRoom_Star08: INCBIN "data/objlst/trroom/star08.bin"
OBJLst_TrRoom_Star09: INCBIN "data/objlst/trroom/star09.bin"
OBJLst_TrRoom_Star0A: INCBIN "data/objlst/trroom/star0a.bin"
OBJLst_TrRoom_Star0B: INCBIN "data/objlst/trroom/star0b.bin"
OBJLst_Coin0: INCBIN "data/objlst/level/coin0.bin"
OBJLst_Coin1: INCBIN "data/objlst/level/coin1.bin"
OBJLst_Coin2: INCBIN "data/objlst/level/coin2.bin"
OBJLst_1UP: INCBIN "data/objlst/level/1up.bin"
OBJLst_SaveSel_Smoke0: INCBIN "data/objlst/saveselect/smoke0.bin"
OBJLst_SaveSel_Smoke1: INCBIN "data/objlst/saveselect/smoke1.bin"
OBJLst_SaveSel_Smoke2: INCBIN "data/objlst/saveselect/smoke2.bin"
OBJLst_3UP: INCBIN "data/objlst/level/3up.bin"
OBJLst_TrRoom_MoneyBags1: INCBIN "data/objlst/trroom/moneybags1.bin"
OBJLst_TrRoom_MoneyBags2: INCBIN "data/objlst/trroom/moneybags2.bin"
OBJLst_TrRoom_MoneyBags3: INCBIN "data/objlst/trroom/moneybags3.bin"
OBJLst_TrRoom_MoneyBags4: INCBIN "data/objlst/trroom/moneybags4.bin"
OBJLst_TrRoom_MoneyBags5: INCBIN "data/objlst/trroom/moneybags5.bin"
OBJLst_TrRoom_MoneyBags6: INCBIN "data/objlst/trroom/moneybags6.bin"
OBJLst_TrRoom_MoneyBagFall: INCBIN "data/objlst/trroom/moneybag_fall.bin"
OBJLst_SaveSel_Wario_LookBack: INCBIN "data/objlst/saveselect/wario_lookback.bin"
OBJLst_SaveSel_Wario_LookUp: INCBIN "data/objlst/saveselect/wario_lookup.bin"

; =============== END OF BANK ===============
L057A87: db $AB;X
L057A88: db $EA;X
L057A89: db $AA;X
L057A8A: db $EA;X
L057A8B: db $BF;X
L057A8C: db $BA;X
L057A8D: db $AA;X
L057A8E: db $AA;X
L057A8F: db $BA;X
L057A90: db $AA;X
L057A91: db $AB;X
L057A92: db $AB;X
L057A93: db $AB;X
L057A94: db $BB;X
L057A95: db $BA;X
L057A96: db $EB;X
L057A97: db $EA;X
L057A98: db $AF;X
L057A99: db $AE;X
L057A9A: db $AB;X
L057A9B: db $AE;X
L057A9C: db $AE;X
L057A9D: db $AA;X
L057A9E: db $AA;X
L057A9F: db $AA;X
L057AA0: db $AE;X
L057AA1: db $AA;X
L057AA2: db $AE;X
L057AA3: db $AA;X
L057AA4: db $BA;X
L057AA5: db $AA;X
L057AA6: db $FA;X
L057AA7: db $AE;X
L057AA8: db $BA;X
L057AA9: db $BA;X
L057AAA: db $FB;X
L057AAB: db $BA;X
L057AAC: db $AA;X
L057AAD: db $BE;X
L057AAE: db $BA;X
L057AAF: db $BA;X
L057AB0: db $EA;X
L057AB1: db $EE;X
L057AB2: db $EF;X
L057AB3: db $BA;X
L057AB4: db $BA;X
L057AB5: db $AA;X
L057AB6: db $BB;X
L057AB7: db $EE;X
L057AB8: db $EA;X
L057AB9: db $FE;X
L057ABA: db $AA;X
L057ABB: db $AB;X
L057ABC: db $AA;X
L057ABD: db $BA;X
L057ABE: db $BA;X
L057ABF: db $AB;X
L057AC0: db $AA;X
L057AC1: db $BF;X
L057AC2: db $AA;X
L057AC3: db $BE;X
L057AC4: db $BA;X
L057AC5: db $AE;X
L057AC6: db $AE;X
L057AC7: db $AB;X
L057AC8: db $EE;X
L057AC9: db $EB;X
L057ACA: db $AA;X
L057ACB: db $AE;X
L057ACC: db $AB;X
L057ACD: db $EA;X
L057ACE: db $AA;X
L057ACF: db $AA;X
L057AD0: db $AA;X
L057AD1: db $BA;X
L057AD2: db $EA;X
L057AD3: db $FE;X
L057AD4: db $BA;X
L057AD5: db $AE;X
L057AD6: db $BA;X
L057AD7: db $AB;X
L057AD8: db $EE;X
L057AD9: db $AA;X
L057ADA: db $AA;X
L057ADB: db $EA;X
L057adc: db $AF;X
L057add: db $BA;X
L057ADE: db $AE;X
L057ADF: db $AB;X
L057AE0: db $EA;X
L057AE1: db $AA;X
L057AE2: db $AA;X
L057AE3: db $BA;X
L057AE4: db $AE;X
L057AE5: db $AF;X
L057AE6: db $EB;X
L057AE7: db $AA;X
L057AE8: db $EA;X
L057AE9: db $EA;X
L057AEA: db $EB;X
L057AEB: db $AA;X
L057AEC: db $EB;X
L057AED: db $EF;X
L057AEE: db $AA;X
L057AEF: db $AE;X
L057AF0: db $AF;X
L057AF1: db $AA;X
L057AF2: db $AA;X
L057AF3: db $BB;X
L057AF4: db $EE;X
L057AF5: db $BB;X
L057AF6: db $AA;X
L057AF7: db $BA;X
L057AF8: db $EA;X
L057AF9: db $AA;X
L057AFA: db $AA;X
L057AFB: db $AE;X
L057AFC: db $FB;X
L057AFD: db $AB;X
L057AFE: db $EE;X
L057AFF: db $AA;X
L057B00: db $22;X
L057B01: db $22;X
L057B02: db $AA;X
L057B03: db $0A;X
L057B04: db $AA;X
L057B05: db $AA;X
L057B06: db $AA;X
L057B07: db $AA;X
L057B08: db $22;X
L057B09: db $20;X
L057B0A: db $AA;X
L057B0B: db $20;X
L057B0C: db $AA;X
L057B0D: db $A2;X
L057B0E: db $AA;X
L057B0F: db $AA;X
L057B10: db $AA;X
L057B11: db $A0;X
L057B12: db $A2;X
L057B13: db $2A;X
L057B14: db $AA;X
L057B15: db $28;X
L057B16: db $82;X
L057B17: db $AA;X
L057B18: db $A8;X
L057B19: db $A8;X
L057B1A: db $A8;X
L057B1B: db $AA;X
L057B1C: db $A8;X
L057B1D: db $02;X
L057B1E: db $A8;X
L057B1F: db $08;X
L057B20: db $8A;X
L057B21: db $A8;X
L057B22: db $28;X
L057B23: db $0A;X
L057B24: db $28;X
L057B25: db $A8;X
L057B26: db $AA;X
L057B27: db $A0;X
L057B28: db $A2;X
L057B29: db $A2;X
L057B2A: db $2A;X
L057B2B: db $08;X
L057B2C: db $AA;X
L057B2D: db $AA;X
L057B2E: db $AA;X
L057B2F: db $AA;X
L057B30: db $A8;X
L057B31: db $A8;X
L057B32: db $2A;X
L057B33: db $A0;X
L057B34: db $28;X
L057B35: db $AA;X
L057B36: db $AA;X
L057B37: db $8A;X
L057B38: db $A8;X
L057B39: db $A2;X
L057B3A: db $AA;X
L057B3B: db $2A;X
L057B3C: db $2A;X
L057B3D: db $0A;X
L057B3E: db $AA;X
L057B3F: db $2A;X
L057B40: db $28;X
L057B41: db $A0;X
L057B42: db $AA;X
L057B43: db $0A;X
L057B44: db $A2;X
L057B45: db $8A;X
L057B46: db $A2;X
L057B47: db $88;X
L057B48: db $82;X
L057B49: db $88;X
L057B4A: db $AA;X
L057B4B: db $AA;X
L057B4C: db $2A;X
L057B4D: db $88;X
L057B4E: db $8A;X
L057B4F: db $22;X
L057B50: db $AA;X
L057B51: db $A2;X
L057B52: db $08;X
L057B53: db $8A;X
L057B54: db $A2;X
L057B55: db $82;X
L057B56: db $AA;X
L057B57: db $22;X
L057B58: db $8A;X
L057B59: db $A8;X
L057B5A: db $0A;X
L057B5B: db $8A;X
L057B5C: db $AA;X
L057B5D: db $AA;X
L057B5E: db $2A;X
L057B5F: db $0A;X
L057B60: db $00;X
L057B61: db $2A;X
L057B62: db $2A;X
L057B63: db $8A;X
L057B64: db $2A;X
L057B65: db $AA;X
L057B66: db $88;X
L057B67: db $8A;X
L057B68: db $AA;X
L057B69: db $8A;X
L057B6A: db $A8;X
L057B6B: db $8A;X
L057B6C: db $AA;X
L057B6D: db $A0;X
L057B6E: db $A2;X
L057B6F: db $AA;X
L057B70: db $A2;X
L057B71: db $8A;X
L057B72: db $A2;X
L057B73: db $A2;X
L057B74: db $0A;X
L057B75: db $2A;X
L057B76: db $8A;X
L057B77: db $28;X
L057B78: db $28;X
L057B79: db $AA;X
L057B7A: db $88;X
L057B7B: db $8A;X
L057B7C: db $AA;X
L057B7D: db $8A;X
L057B7E: db $88;X
L057B7F: db $88;X
L057B80: db $AB;X
L057B81: db $EA;X
L057B82: db $FB;X
L057B83: db $EA;X
L057B84: db $AA;X
L057B85: db $EA;X
L057B86: db $BE;X
L057B87: db $BA;X
L057B88: db $BA;X
L057B89: db $EF;X
L057B8A: db $FE;X
L057B8B: db $AA;X
L057B8C: db $AA;X
L057B8D: db $AF;X
L057B8E: db $BE;X
L057B8F: db $AA;X
L057B90: db $AA;X
L057B91: db $AA;X
L057B92: db $EA;X
L057B93: db $EA;X
L057B94: db $FA;X
L057B95: db $AF;X
L057B96: db $AF;X
L057B97: db $AA;X
L057B98: db $EA;X
L057B99: db $AB;X
L057B9A: db $AA;X
L057B9B: db $BA;X
L057B9C: db $AB;X
L057B9D: db $BB;X
L057B9E: db $AE;X
L057B9F: db $EB;X
L057BA0: db $BF;X
L057BA1: db $AA;X
L057BA2: db $AF;X
L057BA3: db $AF;X
L057BA4: db $BA;X
L057BA5: db $AB;X
L057BA6: db $EE;X
L057BA7: db $BA;X
L057BA8: db $BE;X
L057BA9: db $EB;X
L057BAA: db $AA;X
L057BAB: db $EB;X
L057BAC: db $AB;X
L057BAD: db $BA;X
L057BAE: db $EE;X
L057BAF: db $EB;X
L057BB0: db $AE;X
L057BB1: db $BA;X
L057BB2: db $AB;X
L057BB3: db $AE;X
L057BB4: db $AA;X
L057BB5: db $EF;X
L057BB6: db $EE;X
L057BB7: db $EE;X
L057BB8: db $EE;X
L057BB9: db $FF;X
L057BBA: db $BA;X
L057BBB: db $FB;X
L057BBC: db $FF;X
L057BBD: db $AE;X
L057BBE: db $EB;X
L057BBF: db $BB;X
L057BC0: db $AA;X
L057BC1: db $AE;X
L057BC2: db $EB;X
L057BC3: db $AF;X
L057BC4: db $AF;X
L057BC5: db $BA;X
L057BC6: db $AE;X
L057BC7: db $BF;X
L057BC8: db $AA;X
L057BC9: db $AA;X
L057BCA: db $FA;X
L057BCB: db $AE;X
L057BCC: db $AF;X
L057BCD: db $BA;X
L057BCE: db $AA;X
L057BCF: db $AE;X
L057BD0: db $AA;X
L057BD1: db $AA;X
L057BD2: db $EA;X
L057BD3: db $AA;X
L057BD4: db $AB;X
L057BD5: db $AA;X
L057BD6: db $AA;X
L057BD7: db $AE;X
L057BD8: db $AA;X
L057BD9: db $AA;X
L057BDA: db $BA;X
L057BDB: db $AE;X
L057BDC: db $EA;X
L057BDD: db $BA;X
L057BDE: db $AA;X
L057BDF: db $BE;X
L057BE0: db $FA;X
L057BE1: db $AA;X
L057BE2: db $AB;X
L057BE3: db $AA;X
L057BE4: db $AE;X
L057BE5: db $EF;X
L057BE6: db $FA;X
L057BE7: db $AA;X
L057BE8: db $EA;X
L057BE9: db $FA;X
L057BEA: db $BE;X
L057BEB: db $AF;X
L057BEC: db $AA;X
L057BED: db $BA;X
L057BEE: db $AE;X
L057BEF: db $AA;X
L057BF0: db $AF;X
L057BF1: db $AA;X
L057BF2: db $BA;X
L057BF3: db $AB;X
L057BF4: db $AE;X
L057BF5: db $AF;X
L057BF6: db $AF;X
L057BF7: db $AA;X
L057BF8: db $AE;X
L057BF9: db $BA;X
L057BFA: db $AA;X
L057BFB: db $EB;X
L057BFC: db $AA;X
L057BFD: db $EE;X
L057BFE: db $BE;X
L057BFF: db $AB;X
L057C00: db $AA;X
L057C01: db $A8;X
L057C02: db $22;X
L057C03: db $82;X
L057C04: db $2A;X
L057C05: db $2A;X
L057C06: db $A2;X
L057C07: db $AA;X
L057C08: db $AA;X
L057C09: db $2A;X
L057C0A: db $22;X
L057C0B: db $A2;X
L057C0C: db $AA;X
L057C0D: db $AA;X
L057C0E: db $A8;X
L057C0F: db $88;X
L057C10: db $AA;X
L057C11: db $AA;X
L057C12: db $A8;X
L057C13: db $A2;X
L057C14: db $88;X
L057C15: db $A2;X
L057C16: db $88;X
L057C17: db $A0;X
L057C18: db $A8;X
L057C19: db $AA;X
L057C1A: db $AA;X
L057C1B: db $82;X
L057C1C: db $A8;X
L057C1D: db $AA;X
L057C1E: db $AA;X
L057C1F: db $AA;X
L057C20: db $02;X
L057C21: db $AA;X
L057C22: db $A2;X
L057C23: db $AA;X
L057C24: db $22;X
L057C25: db $0A;X
L057C26: db $A0;X
L057C27: db $AA;X
L057C28: db $A8;X
L057C29: db $A8;X
L057C2A: db $A2;X
L057C2B: db $AA;X
L057C2C: db $AA;X
L057C2D: db $A0;X
L057C2E: db $AA;X
L057C2F: db $0A;X
L057C30: db $AA;X
L057C31: db $22;X
L057C32: db $20;X
L057C33: db $A8;X
L057C34: db $A8;X
L057C35: db $A8;X
L057C36: db $AA;X
L057C37: db $22;X
L057C38: db $A2;X
L057C39: db $AA;X
L057C3A: db $A8;X
L057C3B: db $88;X
L057C3C: db $A2;X
L057C3D: db $AA;X
L057C3E: db $8A;X
L057C3F: db $28;X
L057C40: db $20;X
L057C41: db $AA;X
L057C42: db $AA;X
L057C43: db $AA;X
L057C44: db $0A;X
L057C45: db $AA;X
L057C46: db $AA;X
L057C47: db $A2;X
L057C48: db $2A;X
L057C49: db $AA;X
L057C4A: db $A8;X
L057C4B: db $A2;X
L057C4C: db $AA;X
L057C4D: db $AA;X
L057C4E: db $0A;X
L057C4F: db $2A;X
L057C50: db $A2;X
L057C51: db $AA;X
L057C52: db $02;X
L057C53: db $AA;X
L057C54: db $8A;X
L057C55: db $88;X
L057C56: db $A2;X
L057C57: db $22;X
L057C58: db $2A;X
L057C59: db $22;X
L057C5A: db $28;X
L057C5B: db $88;X
L057C5C: db $AA;X
L057C5D: db $AA;X
L057C5E: db $A2;X
L057C5F: db $82;X
L057C60: db $28;X
L057C61: db $AA;X
L057C62: db $AA;X
L057C63: db $22;X
L057C64: db $08;X
L057C65: db $2A;X
L057C66: db $2A;X
L057C67: db $AA;X
L057C68: db $A2;X
L057C69: db $2A;X
L057C6A: db $28;X
L057C6B: db $A2;X
L057C6C: db $AA;X
L057C6D: db $AA;X
L057C6E: db $8A;X
L057C6F: db $A8;X
L057C70: db $A0;X
L057C71: db $8A;X
L057C72: db $2A;X
L057C73: db $2A;X
L057C74: db $2A;X
L057C75: db $20;X
L057C76: db $88;X
L057C77: db $AA;X
L057C78: db $A8;X
L057C79: db $A0;X
L057C7A: db $82;X
L057C7B: db $A8;X
L057C7C: db $A2;X
L057C7D: db $A2;X
L057C7E: db $A2;X
L057C7F: db $A2;X
L057C80: db $AA;X
L057C81: db $EA;X
L057C82: db $EE;X
L057C83: db $AE;X
L057C84: db $EA;X
L057C85: db $AE;X
L057C86: db $AA;X
L057C87: db $EA;X
L057C88: db $AE;X
L057C89: db $AA;X
L057C8A: db $AA;X
L057C8B: db $AA;X
L057C8C: db $AA;X
L057C8D: db $AE;X
L057C8E: db $AA;X
L057C8F: db $EE;X
L057C90: db $AB;X
L057C91: db $EA;X
L057C92: db $AA;X
L057C93: db $BE;X
L057C94: db $EA;X
L057C95: db $AA;X
L057C96: db $AE;X
L057C97: db $AE;X
L057C98: db $EB;X
L057C99: db $AE;X
L057C9A: db $AE;X
L057C9B: db $AA;X
L057C9C: db $AA;X
L057C9D: db $AF;X
L057C9E: db $AE;X
L057C9F: db $AA;X
L057CA0: db $BE;X
L057CA1: db $AA;X
L057CA2: db $AA;X
L057CA3: db $AA;X
L057CA4: db $AA;X
L057CA5: db $AA;X
L057CA6: db $EA;X
L057CA7: db $EA;X
L057CA8: db $AE;X
L057CA9: db $AA;X
L057CAA: db $AA;X
L057CAB: db $AE;X
L057CAC: db $FA;X
L057CAD: db $AA;X
L057CAE: db $AA;X
L057CAF: db $AA;X
L057CB0: db $EE;X
L057CB1: db $AA;X
L057CB2: db $AE;X
L057CB3: db $AA;X
L057CB4: db $AA;X
L057CB5: db $AA;X
L057CB6: db $AA;X
L057CB7: db $AA;X
L057CB8: db $AA;X
L057CB9: db $AA;X
L057CBA: db $AA;X
L057CBB: db $AA;X
L057CBC: db $AE;X
L057CBD: db $AE;X
L057CBE: db $AE;X
L057CBF: db $AE;X
L057CC0: db $AE;X
L057CC1: db $BE;X
L057CC2: db $AA;X
L057CC3: db $EA;X
L057CC4: db $AA;X
L057CC5: db $EB;X
L057CC6: db $AA;X
L057CC7: db $EA;X
L057CC8: db $AE;X
L057CC9: db $AE;X
L057CCA: db $AE;X
L057CCB: db $AA;X
L057CCC: db $AA;X
L057CCD: db $EA;X
L057CCE: db $AA;X
L057CCF: db $AA;X
L057CD0: db $EF;X
L057CD1: db $AA;X
L057CD2: db $EE;X
L057CD3: db $EA;X
L057CD4: db $AE;X
L057CD5: db $EA;X
L057CD6: db $EB;X
L057CD7: db $BA;X
L057CD8: db $EA;X
L057CD9: db $AA;X
L057CDA: db $AA;X
L057CDB: db $AE;X
L057CDC: db $AE;X
L057CDD: db $AE;X
L057CDE: db $AA;X
L057CDF: db $BA;X
L057CE0: db $AE;X
L057CE1: db $AA;X
L057CE2: db $AA;X
L057CE3: db $AA;X
L057CE4: db $EA;X
L057CE5: db $FA;X
L057CE6: db $AE;X
L057CE7: db $BA;X
L057CE8: db $AF;X
L057CE9: db $AA;X
L057CEA: db $AE;X
L057CEB: db $AA;X
L057CEC: db $AE;X
L057CED: db $AA;X
L057CEE: db $EE;X
L057CEF: db $FE;X
L057CF0: db $AA;X
L057CF1: db $EE;X
L057CF2: db $BA;X
L057CF3: db $EA;X
L057CF4: db $EA;X
L057CF5: db $AA;X
L057CF6: db $AA;X
L057CF7: db $AB;X
L057CF8: db $AA;X
L057CF9: db $AB;X
L057CFA: db $AE;X
L057CFB: db $AA;X
L057CFC: db $AA;X
L057CFD: db $AE;X
L057CFE: db $AA;X
L057CFF: db $AB;X
L057D00: db $28;X
L057D01: db $A8;X
L057D02: db $AA;X
L057D03: db $A8;X
L057D04: db $AA;X
L057D05: db $A2;X
L057D06: db $A0;X
L057D07: db $AA;X
L057D08: db $AA;X
L057D09: db $88;X
L057D0A: db $A2;X
L057D0B: db $20;X
L057D0C: db $2A;X
L057D0D: db $AA;X
L057D0E: db $A8;X
L057D0F: db $2A;X
L057D10: db $8A;X
L057D11: db $A8;X
L057D12: db $AA;X
L057D13: db $2A;X
L057D14: db $AA;X
L057D15: db $00;X
L057D16: db $02;X
L057D17: db $AA;X
L057D18: db $2A;X
L057D19: db $AA;X
L057D1A: db $A2;X
L057D1B: db $AA;X
L057D1C: db $AA;X
L057D1D: db $AA;X
L057D1E: db $A8;X
L057D1F: db $28;X
L057D20: db $A2;X
L057D21: db $0A;X
L057D22: db $02;X
L057D23: db $80;X
L057D24: db $82;X
L057D25: db $AA;X
L057D26: db $AA;X
L057D27: db $AA;X
L057D28: db $AA;X
L057D29: db $A8;X
L057D2A: db $AA;X
L057D2B: db $A0;X
L057D2C: db $2A;X
L057D2D: db $0A;X
L057D2E: db $A2;X
L057D2F: db $AA;X
L057D30: db $82;X
L057D31: db $AA;X
L057D32: db $AA;X
L057D33: db $AA;X
L057D34: db $88;X
L057D35: db $0A;X
L057D36: db $AA;X
L057D37: db $8A;X
L057D38: db $AA;X
L057D39: db $8A;X
L057D3A: db $AA;X
L057D3B: db $AA;X
L057D3C: db $AA;X
L057D3D: db $8A;X
L057D3E: db $08;X
L057D3F: db $A0;X
L057D40: db $AA;X
L057D41: db $2A;X
L057D42: db $88;X
L057D43: db $AA;X
L057D44: db $AA;X
L057D45: db $82;X
L057D46: db $AA;X
L057D47: db $2A;X
L057D48: db $AA;X
L057D49: db $2A;X
L057D4A: db $A2;X
L057D4B: db $2A;X
L057D4C: db $AA;X
L057D4D: db $AA;X
L057D4E: db $A8;X
L057D4F: db $A0;X
L057D50: db $2A;X
L057D51: db $8A;X
L057D52: db $AA;X
L057D53: db $A8;X
L057D54: db $8A;X
L057D55: db $0A;X
L057D56: db $AA;X
L057D57: db $2A;X
L057D58: db $0A;X
L057D59: db $AA;X
L057D5A: db $A2;X
L057D5B: db $88;X
L057D5C: db $AA;X
L057D5D: db $A8;X
L057D5E: db $2A;X
L057D5F: db $82;X
L057D60: db $AA;X
L057D61: db $AA;X
L057D62: db $A8;X
L057D63: db $AA;X
L057D64: db $AA;X
L057D65: db $A2;X
L057D66: db $2A;X
L057D67: db $82;X
L057D68: db $AA;X
L057D69: db $2A;X
L057D6A: db $28;X
L057D6B: db $28;X
L057D6C: db $AA;X
L057D6D: db $82;X
L057D6E: db $A2;X
L057D6F: db $22;X
L057D70: db $AA;X
L057D71: db $2A;X
L057D72: db $AA;X
L057D73: db $8A;X
L057D74: db $0A;X
L057D75: db $2A;X
L057D76: db $02;X
L057D77: db $20;X
L057D78: db $82;X
L057D79: db $A8;X
L057D7A: db $A8;X
L057D7B: db $AA;X
L057D7C: db $A2;X
L057D7D: db $02;X
L057D7E: db $0A;X
L057D7F: db $AA;X
L057D80: db $AA;X
L057D81: db $AE;X
L057D82: db $EE;X
L057D83: db $AA;X
L057D84: db $EE;X
L057D85: db $AA;X
L057D86: db $AE;X
L057D87: db $EA;X
L057D88: db $AA;X
L057D89: db $AA;X
L057D8A: db $AE;X
L057D8B: db $EA;X
L057D8C: db $AE;X
L057D8D: db $AE;X
L057D8E: db $AF;X
L057D8F: db $AA;X
L057D90: db $FA;X
L057D91: db $EF;X
L057D92: db $AB;X
L057D93: db $AA;X
L057D94: db $AA;X
L057D95: db $AA;X
L057D96: db $BA;X
L057D97: db $EA;X
L057D98: db $AA;X
L057D99: db $AE;X
L057D9A: db $BA;X
L057D9B: db $AA;X
L057D9C: db $FE;X
L057D9D: db $AA;X
L057D9E: db $AE;X
L057D9F: db $AA;X
L057DA0: db $AA;X
L057DA1: db $AE;X
L057DA2: db $BA;X
L057DA3: db $AA;X
L057DA4: db $AB;X
L057DA5: db $AA;X
L057DA6: db $EA;X
L057DA7: db $BB;X
L057DA8: db $EA;X
L057DA9: db $BA;X
L057DAA: db $AA;X
L057DAB: db $AE;X
L057DAC: db $AE;X
L057DAD: db $EA;X
L057DAE: db $EA;X
L057DAF: db $AA;X
L057DB0: db $EE;X
L057DB1: db $EE;X
L057DB2: db $BA;X
L057DB3: db $AA;X
L057DB4: db $AA;X
L057DB5: db $AA;X
L057DB6: db $EA;X
L057DB7: db $EA;X
L057DB8: db $AA;X
L057DB9: db $AA;X
L057DBA: db $AA;X
L057DBB: db $EB;X
L057DBC: db $AE;X
L057DBD: db $AA;X
L057DBE: db $EA;X
L057DBF: db $AE;X
L057DC0: db $AF;X
L057DC1: db $EA;X
L057DC2: db $EA;X
L057DC3: db $BA;X
L057DC4: db $AA;X
L057DC5: db $EA;X
L057DC6: db $BE;X
L057DC7: db $AA;X
L057DC8: db $AA;X
L057DC9: db $AA;X
L057DCA: db $BA;X
L057DCB: db $EA;X
L057DCC: db $AA;X
L057DCD: db $AE;X
L057DCE: db $AB;X
L057DCF: db $AA;X
L057DD0: db $EA;X
L057DD1: db $AE;X
L057DD2: db $AA;X
L057DD3: db $AE;X
L057DD4: db $AA;X
L057DD5: db $AA;X
L057DD6: db $AA;X
L057DD7: db $EE;X
L057DD8: db $AA;X
L057DD9: db $EA;X
L057DDA: db $EE;X
L057DDB: db $BA;X
L057DDC: db $EA;X
L057DDD: db $AE;X
L057DDE: db $AA;X
L057DDF: db $BE;X
L057DE0: db $AB;X
L057DE1: db $EA;X
L057DE2: db $AE;X
L057DE3: db $EA;X
L057DE4: db $AF;X
L057DE5: db $AB;X
L057DE6: db $AA;X
L057DE7: db $AB;X
L057DE8: db $AA;X
L057DE9: db $AA;X
L057DEA: db $AA;X
L057DEB: db $AA;X
L057dec: db $AA;X
L057DED: db $AA;X
L057DEE: db $AA;X
L057DEF: db $EE;X
L057DF0: db $AA;X
L057DF1: db $AA;X
L057DF2: db $AE;X
L057DF3: db $EB;X
L057DF4: db $AE;X
L057DF5: db $EA;X
L057DF6: db $BB;X
L057DF7: db $FE;X
L057DF8: db $AA;X
L057DF9: db $AE;X
L057DFA: db $AA;X
L057DFB: db $AA;X
L057DFC: db $EE;X
L057DFD: db $EA;X
L057DFE: db $AB;X
L057DFF: db $AA;X
L057E00: db $A0;X
L057E01: db $2A;X
L057E02: db $AA;X
L057E03: db $8A;X
L057E04: db $8A;X
L057E05: db $8A;X
L057E06: db $AA;X
L057E07: db $A8;X
L057E08: db $AA;X
L057E09: db $8A;X
L057E0A: db $AA;X
L057E0B: db $02;X
L057E0C: db $80;X
L057E0D: db $A0;X
L057E0E: db $8A;X
L057E0F: db $A8;X
L057E10: db $80;X
L057E11: db $AA;X
L057E12: db $A2;X
L057E13: db $22;X
L057E14: db $2A;X
L057E15: db $AA;X
L057E16: db $AA;X
L057E17: db $A2;X
L057E18: db $AA;X
L057E19: db $A8;X
L057E1A: db $AA;X
L057E1B: db $20;X
L057E1C: db $AA;X
L057E1D: db $2A;X
L057E1E: db $AA;X
L057E1F: db $AA;X
L057E20: db $8A;X
L057E21: db $AA;X
L057E22: db $0A;X
L057E23: db $8A;X
L057E24: db $AA;X
L057E25: db $AA;X
L057E26: db $02;X
L057E27: db $AA;X
L057E28: db $AA;X
L057E29: db $AA;X
L057E2A: db $A8;X
L057E2B: db $08;X
L057E2C: db $08;X
L057E2D: db $AA;X
L057E2E: db $AA;X
L057E2F: db $A0;X
L057E30: db $AA;X
L057E31: db $0A;X
L057E32: db $AA;X
L057E33: db $AA;X
L057E34: db $20;X
L057E35: db $0A;X
L057E36: db $A2;X
L057E37: db $88;X
L057E38: db $A0;X
L057E39: db $AA;X
L057E3A: db $AA;X
L057E3B: db $AA;X
L057E3C: db $A2;X
L057E3D: db $A8;X
L057E3E: db $A8;X
L057E3F: db $0A;X
L057E40: db $AA;X
L057E41: db $AA;X
L057E42: db $A2;X
L057E43: db $8A;X
L057E44: db $AA;X
L057E45: db $AA;X
L057E46: db $2A;X
L057E47: db $82;X
L057E48: db $AA;X
L057E49: db $28;X
L057E4A: db $20;X
L057E4B: db $A0;X
L057E4C: db $2A;X
L057E4D: db $2A;X
L057E4E: db $AA;X
L057E4F: db $A2;X
L057E50: db $2A;X
L057E51: db $8A;X
L057E52: db $A2;X
L057E53: db $A8;X
L057E54: db $AA;X
L057E55: db $82;X
L057E56: db $AA;X
L057E57: db $0A;X
L057E58: db $A2;X
L057E59: db $AA;X
L057E5A: db $A8;X
L057E5B: db $8A;X
L057E5C: db $A8;X
L057E5D: db $2A;X
L057E5E: db $AA;X
L057E5F: db $08;X
L057E60: db $AA;X
L057E61: db $28;X
L057E62: db $8A;X
L057E63: db $AA;X
L057E64: db $A8;X
L057E65: db $AA;X
L057E66: db $22;X
L057E67: db $8A;X
L057E68: db $8A;X
L057E69: db $0A;X
L057E6A: db $A2;X
L057E6B: db $8A;X
L057E6C: db $A8;X
L057E6D: db $22;X
L057E6E: db $AA;X
L057E6F: db $A2;X
L057E70: db $AA;X
L057E71: db $8A;X
L057E72: db $8A;X
L057E73: db $82;X
L057E74: db $AA;X
L057E75: db $AA;X
L057E76: db $28;X
L057E77: db $A2;X
L057E78: db $AA;X
L057E79: db $8A;X
L057E7A: db $2A;X
L057E7B: db $22;X
L057E7C: db $A8;X
L057E7D: db $88;X
L057E7E: db $80;X
L057E7F: db $AA;X
L057E80: db $AA;X
L057E81: db $EF;X
L057E82: db $AE;X
L057E83: db $EA;X
L057E84: db $EA;X
L057E85: db $AE;X
L057E86: db $AE;X
L057E87: db $EA;X
L057E88: db $EE;X
L057E89: db $EA;X
L057E8A: db $AA;X
L057E8B: db $AE;X
L057E8C: db $BA;X
L057E8D: db $AA;X
L057E8E: db $BA;X
L057E8F: db $AA;X
L057E90: db $AE;X
L057E91: db $BA;X
L057E92: db $AA;X
L057E93: db $EA;X
L057E94: db $AA;X
L057E95: db $BA;X
L057E96: db $AE;X
L057E97: db $AA;X
L057E98: db $AA;X
L057E99: db $AA;X
L057E9A: db $EA;X
L057E9B: db $AA;X
L057E9C: db $FE;X
L057E9D: db $AA;X
L057E9E: db $EB;X
L057E9F: db $AB;X
L057EA0: db $BA;X
L057EA1: db $AE;X
L057EA2: db $AA;X
L057EA3: db $AA;X
L057EA4: db $EE;X
L057EA5: db $AE;X
L057EA6: db $AA;X
L057EA7: db $AE;X
L057EA8: db $AE;X
L057EA9: db $AE;X
L057EAA: db $AE;X
L057EAB: db $AA;X
L057EAC: db $AA;X
L057EAD: db $EA;X
L057EAE: db $AF;X
L057EAF: db $AE;X
L057EB0: db $AF;X
L057EB1: db $EE;X
L057EB2: db $AA;X
L057EB3: db $AA;X
L057EB4: db $AA;X
L057EB5: db $AA;X
L057EB6: db $BB;X
L057EB7: db $AA;X
L057EB8: db $AA;X
L057EB9: db $AA;X
L057EBA: db $AA;X
L057EBB: db $AA;X
L057EBC: db $AA;X
L057EBD: db $EA;X
L057EBE: db $AA;X
L057EBF: db $AE;X
L057EC0: db $EA;X
L057EC1: db $EA;X
L057EC2: db $EA;X
L057EC3: db $AB;X
L057EC4: db $AE;X
L057EC5: db $AA;X
L057EC6: db $AA;X
L057EC7: db $AB;X
L057EC8: db $AE;X
L057EC9: db $AA;X
L057ECA: db $AA;X
L057ECB: db $AB;X
L057ECC: db $EA;X
L057ECD: db $AA;X
L057ECE: db $AA;X
L057ECF: db $AE;X
L057ED0: db $AA;X
L057ED1: db $AA;X
L057ED2: db $EE;X
L057ED3: db $AE;X
L057ED4: db $AE;X
L057ED5: db $EA;X
L057ED6: db $AA;X
L057ED7: db $EA;X
L057ED8: db $AF;X
L057ED9: db $AB;X
L057EDA: db $AA;X
L057EDB: db $EA;X
L057EDC: db $AA;X
L057EDD: db $EA;X
L057EDE: db $AA;X
L057EDF: db $EE;X
L057EE0: db $AA;X
L057EE1: db $AA;X
L057EE2: db $AA;X
L057EE3: db $AA;X
L057EE4: db $AE;X
L057EE5: db $AE;X
L057EE6: db $AE;X
L057EE7: db $EA;X
L057EE8: db $EB;X
L057EE9: db $AA;X
L057EEA: db $AA;X
L057EEB: db $AE;X
L057EEC: db $AA;X
L057EED: db $AE;X
L057EEE: db $AE;X
L057EEF: db $AA;X
L057EF0: db $AA;X
L057EF1: db $AE;X
L057EF2: db $FF;X
L057EF3: db $AA;X
L057EF4: db $AF;X
L057EF5: db $AA;X
L057EF6: db $EE;X
L057EF7: db $AB;X
L057EF8: db $AA;X
L057EF9: db $AA;X
L057EFA: db $AE;X
L057EFB: db $AA;X
L057EFC: db $AA;X
L057EFD: db $AA;X
L057EFE: db $BA;X
L057EFF: db $AE;X
L057F00: db $0A;X
L057F01: db $AA;X
L057F02: db $8A;X
L057F03: db $AA;X
L057F04: db $A8;X
L057F05: db $8A;X
L057F06: db $A8;X
L057F07: db $A2;X
L057F08: db $28;X
L057F09: db $8A;X
L057F0A: db $A2;X
L057F0B: db $AA;X
L057F0C: db $88;X
L057F0D: db $A2;X
L057F0E: db $0A;X
L057F0F: db $2A;X
L057F10: db $8A;X
L057F11: db $AA;X
L057F12: db $AA;X
L057F13: db $A2;X
L057F14: db $AA;X
L057F15: db $A2;X
L057F16: db $AA;X
L057F17: db $88;X
L057F18: db $AA;X
L057F19: db $80;X
L057F1A: db $8A;X
L057F1B: db $8A;X
L057F1C: db $A2;X
L057F1D: db $88;X
L057F1E: db $82;X
L057F1F: db $88;X
L057F20: db $AA;X
L057F21: db $82;X
L057F22: db $2A;X
L057F23: db $A2;X
L057F24: db $A2;X
L057F25: db $8A;X
L057F26: db $2A;X
L057F27: db $A8;X
L057F28: db $A8;X
L057F29: db $8A;X
L057F2A: db $8A;X
L057F2B: db $A2;X
L057F2C: db $A8;X
L057F2D: db $A0;X
L057F2E: db $AA;X
L057F2F: db $A2;X
L057F30: db $AA;X
L057F31: db $AA;X
L057F32: db $AA;X
L057F33: db $A8;X
L057F34: db $AA;X
L057F35: db $A8;X
L057F36: db $AA;X
L057F37: db $AA;X
L057F38: db $2A;X
L057F39: db $A2;X
L057F3A: db $AA;X
L057F3B: db $AA;X
L057F3C: db $A2;X
L057F3D: db $88;X
L057F3E: db $22;X
L057F3F: db $A2;X
L057F40: db $A2;X
L057F41: db $2A;X
L057F42: db $A2;X
L057F43: db $22;X
L057F44: db $8A;X
L057F45: db $2A;X
L057F46: db $A8;X
L057F47: db $AA;X
L057F48: db $0A;X
L057F49: db $A0;X
L057F4A: db $A2;X
L057F4B: db $AA;X
L057F4C: db $2A;X
L057F4D: db $AA;X
L057F4E: db $0A;X
L057F4F: db $88;X
L057F50: db $AA;X
L057F51: db $AA;X
L057F52: db $2A;X
L057F53: db $AA;X
L057F54: db $8A;X
L057F55: db $AA;X
L057F56: db $8A;X
L057F57: db $08;X
L057F58: db $A2;X
L057F59: db $AA;X
L057F5A: db $22;X
L057F5B: db $A0;X
L057F5C: db $22;X
L057F5D: db $AA;X
L057F5E: db $AA;X
L057F5F: db $AA;X
L057F60: db $02;X
L057F61: db $AA;X
L057F62: db $AA;X
L057F63: db $28;X
L057F64: db $AA;X
L057F65: db $02;X
L057F66: db $88;X
L057F67: db $A2;X
L057F68: db $0A;X
L057F69: db $AA;X
L057F6A: db $AA;X
L057F6B: db $88;X
L057F6C: db $8A;X
L057F6D: db $A8;X
L057F6E: db $28;X
L057F6F: db $28;X
L057F70: db $28;X
L057F71: db $0A;X
L057F72: db $A2;X
L057F73: db $AA;X
L057F74: db $8A;X
L057F75: db $AA;X
L057F76: db $A2;X
L057F77: db $0A;X
L057F78: db $8A;X
L057F79: db $A8;X
L057F7A: db $A2;X
L057F7B: db $A8;X
L057F7C: db $AA;X
L057F7D: db $AA;X
L057F7E: db $A2;X
L057F7F: db $88;X
L057F80: db $AE;X
L057F81: db $EA;X
L057F82: db $EA;X
L057F83: db $AA;X
L057F84: db $AA;X
L057F85: db $AA;X
L057F86: db $EE;X
L057F87: db $AA;X
L057F88: db $AA;X
L057F89: db $EA;X
L057F8A: db $BE;X
L057F8B: db $EA;X
L057F8C: db $AA;X
L057F8D: db $FA;X
L057F8E: db $AA;X
L057F8F: db $EB;X
L057F90: db $AB;X
L057F91: db $AB;X
L057F92: db $AE;X
L057F93: db $EE;X
L057F94: db $AA;X
L057F95: db $EA;X
L057F96: db $AE;X
L057F97: db $EA;X
L057F98: db $AE;X
L057F99: db $AE;X
L057F9A: db $EA;X
L057F9B: db $EA;X
L057F9C: db $BA;X
L057F9D: db $BE;X
L057F9E: db $AA;X
L057F9F: db $AE;X
L057FA0: db $AA;X
L057FA1: db $AA;X
L057FA2: db $AA;X
L057FA3: db $AA;X
L057FA4: db $EA;X
L057FA5: db $AE;X
L057FA6: db $AA;X
L057FA7: db $BE;X
L057FA8: db $AA;X
L057FA9: db $EA;X
L057FAA: db $AF;X
L057FAB: db $AE;X
L057FAC: db $BF;X
L057FAD: db $AA;X
L057FAE: db $EA;X
L057FAF: db $AA;X
L057FB0: db $AA;X
L057FB1: db $FA;X
L057FB2: db $EA;X
L057FB3: db $AA;X
L057FB4: db $BF;X
L057FB5: db $BA;X
L057FB6: db $AA;X
L057FB7: db $EA;X
L057FB8: db $AE;X
L057FB9: db $AA;X
L057FBA: db $EB;X
L057FBB: db $BA;X
L057FBC: db $AE;X
L057FBD: db $EB;X
L057FBE: db $AE;X
L057FBF: db $EA;X
L057FC0: db $FA;X
L057FC1: db $AA;X
L057FC2: db $AA;X
L057FC3: db $AA;X
L057FC4: db $EE;X
L057FC5: db $EE;X
L057FC6: db $AE;X
L057FC7: db $AA;X
L057FC8: db $AE;X
L057FC9: db $AE;X
L057FCA: db $BE;X
L057FCB: db $BA;X
L057FCC: db $AA;X
L057FCD: db $AA;X
L057FCE: db $AE;X
L057FCF: db $EA;X
L057FD0: db $EE;X
L057FD1: db $AA;X
L057FD2: db $AE;X
L057FD3: db $AB;X
L057FD4: db $AB;X
L057FD5: db $AA;X
L057FD6: db $AA;X
L057FD7: db $EE;X
L057FD8: db $AA;X
L057FD9: db $AA;X
L057FDA: db $AF;X
L057FDB: db $AA;X
L057FDC: db $AA;X
L057FDD: db $AE;X
L057FDE: db $AE;X
L057FDF: db $AA;X
L057FE0: db $AA;X
L057FE1: db $EF;X
L057FE2: db $AA;X
L057FE3: db $AA;X
L057FE4: db $AA;X
L057FE5: db $AA;X
L057FE6: db $AA;X
L057FE7: db $EA;X
L057FE8: db $AE;X
L057FE9: db $BA;X
L057FEA: db $EA;X
L057FEB: db $AA;X
L057FEC: db $AA;X
L057FED: db $FE;X
L057FEE: db $EE;X
L057FEF: db $AE;X
L057FF0: db $EA;X
L057FF1: db $AA;X
L057FF2: db $AA;X
L057FF3: db $AA;X
L057FF4: db $EA;X
L057FF5: db $EA;X
L057FF6: db $AA;X
L057FF7: db $EF;X
L057FF8: db $AA;X
L057FF9: db $BA;X
L057FFA: db $AA;X
L057FFB: db $AE;X
L057FFC: db $AA;X
L057FFD: db $AA;X
L057FFE: db $AA;X
L057FFF: db $BA;X
