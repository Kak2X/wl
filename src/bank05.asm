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
;       (bugfix for this is elsewhere)
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
	ld   a, [sPlY_Low]		; A = WarioY
	add  OBJ_OFFSET_Y		; Account for the hardware offset
	sub  a, b				; Result = WarioY + $10 - ScrollY
	ld   [sOAMWriteY], a
	ld   [sPlYRel], a
	; Calculate the relative X pos
	ld   a, [sScrollX]
	ld   b, a				; B = ScrollX
	ld   a, [sPlX_Low]		; A = WarioX
	add  OBJ_OFFSET_X		; ""
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
	add  OBJ_OFFSET_Y		; Account for the hardware offset
	sub  a, b				; Result = ExActY + $10 - ScrollY
	ld   [sOAMWriteY], a
	ld   [sExActOBJYRel], a
	; Calculate the relative X pos
	ld   a, [sScrollX]		
	ld   b, a				; B = ScrollX
	ld   a, [sExActOBJX_Low]; A = ExActX
	add  OBJ_OFFSET_X		; ""
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
	mIncJunk "L057A87"
