;
; BANK $14 - Map Screen (GFX/BG Data, Cutscenes, OBJ Drawing)
;
; =============== LoadGFX_ParsleyWoods_SherbetLand ===============
LoadGFX_ParsleyWoods_SherbetLand:
	ld   hl, GFXRLE_ParsleyWoods_SherbetLand
	call DecompressGFX
	call HomeCall_LoadGFX_SubmapOBJ
	ret
; =============== LoadBG_ParsleyWoods ===============
LoadBG_ParsleyWoods:
	ld   hl, BGRLE_ParsleyWoods
	ld   bc, BGMap_Begin
; =============== DecompressBG_B14 ===============
; Bank $14 stub of DecompressBG.
DecompressBG_B14:
	call DecompressBG
	ret
; =============== LoadBG_SherbetLand ===============
LoadBG_SherbetLand:
	ld   hl, BGRLE_SherbetLand
	ld   bc, BGMap_Begin
	jr   DecompressBG_B14
; =============== LoadGFX_Overworld ===============
LoadGFX_Overworld:
	ld   hl, GFXRLE_Overworld
	call DecompressGFX
	jr   LoadGFX_OverworldOBJ
	ret
; =============== LoadGFX_OverworldOBJ ===============
; Copies the overworld sprites GFX to VRAM, similarly to LoadGFX_SubmapOBJ.
; The upper portion of the compressed overworld GFX is left empty to make space for these tiles.
LoadGFX_OverworldOBJ:
	ld   hl, GFX_OverworldOBJ	; HL = Ptr to uncompressed GFX
	ld   de, Tiles_Begin		; DE = VRAM Destination
	ld   bc, (GFX_OverworldOBJ.end - GFX_OverworldOBJ) ; BC = Bytes to copy
.loop:
	ldi  a, [hl]				; Perform the copy
	ld   [de], a
	inc  de
	dec  bc
	ld   a, b					; If we aren't done (BC != 0), copy the next
	or   a, c
	jr   nz, .loop
	ret
	
; =============== Map_DrawOpenPathsArrows ===============
; This handles the display of directional arrows in the overword.
;
; Arrows are displayed for any given path if the appropriate bit in MapVisibleArrows is set.
Map_DrawOpenPathsArrows:
	; Determine when to display the arrows
	ld   a, [sMapTimer0]		
	and  a, %01100000	; Hide on frames $00-1F, $80-$9F			
	ret  z
	
	; sMapVisibleArrows is a bitmask in the format: DULR----
	ld   a, [sMapVisibleArrows]
	call Map_DrawOpenPathArrowR ; Right arrow
	ld   a, [sMapVisibleArrows]
	call Map_DrawOpenPathArrowL ; ...
	ld   a, [sMapVisibleArrows]
	call Map_DrawOpenPathArrowU
	ld   a, [sMapVisibleArrows]
	call Map_DrawOpenPathArrowD
	ret
; =============== Map_DrawOpenPathArrow? ===============
; Set of subroutines to draw a specific arrow marking an open path.
; These all follow the same template, and all relative to Wario's position.
Map_DrawOpenPathArrowR:
	; If the arrow isn't marked as visible (path missing or not open), never draw the arrow
	bit  4, a
	ret  z
	; Draw the arrows relative to Wario's position
	ld   a, [sMapWarioY]	; Y = WY
	ld   [sMapExOBJ1Y], a
	ld   a, [sMapWarioX]	; X = WX + $12 (to account obj pos origin)
	add  $12
	ld   [sMapExOBJ1X], a
	; Invert palette every 8 frames by alternating between OBP0 and OBP1,
	; which are set up to make it appear like 
	ld   a, [sMapTimer_Low]
	and  a, $08
	jr   z, .usePal1
.usePal0:
	ld   a, $00
.writeLst:
	ld   [sMapExOBJ1Flags], a
	call Map_WriteExOBJ1Lst
	ret
.usePal1:
	ld   a, $10
	jr   .writeLst
; =============== Map_DrawOpenPathArrowL ===============
Map_DrawOpenPathArrowL:
	bit  5, a
	ret  z
	
	ld   a, [sMapWarioY]	; Y = WY
	ld   [sMapExOBJ0Y], a
	ld   a, [sMapWarioX]	; X = WX - $0B
	sub  a, $0B
	ld   [sMapExOBJ0X], a
	
	ld   a, [sMapTimer_Low]
	and  a, $08
	jr   z, .usePal1
	ld   a, $00
.writeLst:
	ld   [sMapExOBJ0Flags], a
	call Map_WriteExOBJ0Lst
	ret
.usePal1:
	ld   a, $10
	jr   .writeLst
; =============== Map_DrawOpenPathArrowU ===============
Map_DrawOpenPathArrowU:
	bit  6, a
	ret  z
	
	ld   a, [sMapWarioY]	; Y = WY - $13
	sub  a, $13
	ld   [sMapExOBJ2Y], a
	ld   a, [sMapWarioX]	; X = WX
	ld   [sMapExOBJ2X], a
	
	ld   a, [sMapTimer_Low]
	and  a, $08
	jr   z, .usePal1
	ld   a, $00
.writeLst:
	ld   [sMapExOBJ2Flags], a
	call Map_WriteExOBJ2Lst
	ret
.usePal1:
	ld   a, $10
	jr   .writeLst
; =============== Map_DrawOpenPathArrowD ===============
Map_DrawOpenPathArrowD:
	bit  7, a
	ret  z
	
	ld   a, [sMapWarioY]	; Y = WY + $09
	add  $09
	ld   [sMapExOBJ3Y], a
	ld   a, [sMapWarioX]	; X = WX
	ld   [sMapExOBJ3X], a
	
	ld   a, [sMapTimer_Low]
	and  a, $08
	jr   z, .usePal1
	ld   a, $00
.writeLst:
	ld   [sMapExOBJ3Flags], a
	call Map_WriteExOBJ3Lst
	ret
.usePal1:
	ld   a, $10
	ld   [sMapExOBJ0Flags], a
	jr   .writeLst
	
; =============== Map_DrawFreeViewArrows ===============
; Draws the 4 "Free View" directional arrows which appear when holding B in the overworld.
; This expects the arrow positions to be already initialized (see Map_InitFreeViewArrows)
Map_DrawFreeViewArrows:
	; Every $10 frames switch to the other palette line
	ld   a, [sMapTimer_Low]
	and  a, $10
	jr   nz, .usePal0
.usePal1:
	; Set OBP1
	ld   a, $10
	ld   [sMapExOBJ0Flags], a
	ld   [sMapExOBJ1Flags], a
	ld   [sMapExOBJ2Flags], a
	ld   [sMapExOBJ3Flags], a
	; Draw all the arrow OBJLst, one after the other
	ld   a, $00
	ld   [sMapExOBJ0LstId], a
	call Map_WriteExOBJ0Lst
	ld   a, $01
	ld   [sMapExOBJ1LstId], a
	call Map_WriteExOBJ1Lst
	ld   a, $02
	ld   [sMapExOBJ2LstId], a
	call Map_WriteExOBJ2Lst
	ld   a, $03
	ld   [sMapExOBJ3LstId], a
	call Map_WriteExOBJ3Lst
	ret
.usePal0:
	; Set OBP0
	ld   a, $00
	ld   [sMapExOBJ0Flags], a
	ld   [sMapExOBJ1Flags], a
	ld   [sMapExOBJ2Flags], a
	ld   [sMapExOBJ3Flags], a
	; Draw all the arrow OBJLst, one after the other
	ld   a, $00
	ld   [sMapExOBJ0LstId], a
	call Map_WriteExOBJ0Lst
	ld   a, $01
	ld   [sMapExOBJ1LstId], a
	call Map_WriteExOBJ1Lst
	ld   a, $02
	ld   [sMapExOBJ2LstId], a
	call Map_WriteExOBJ2Lst
	ld   a, $03
	ld   [sMapExOBJ3LstId], a
	call Map_WriteExOBJ3Lst
	ret
; =============== Map_InitFreeViewArrows ===============
; Sets up the ExOBJ info to point to the 4 directional arrows in Free View mode.
Map_InitFreeViewArrows:
	; Arrow coordinates at the edges of the screen
	ld   a, $60				; Left arrow
	ld   [sMapExOBJ0Y], a
	ld   a, $10
	ld   [sMapExOBJ0X], a
	
	ld   a, $60				; Right arrow
	ld   [sMapExOBJ1Y], a
	ld   a, $A8
	ld   [sMapExOBJ1X], a
	
	ld   a, $18				; Up arrow
	ld   [sMapExOBJ2Y], a
	ld   a, $58
	ld   [sMapExOBJ2X], a
	
	ld   a, $A0				; Down arrow
	ld   [sMapExOBJ3Y], a
	ld   a, $58
	ld   [sMapExOBJ3X], a
	ld   a, $00
	;--
	; Setup mapping used
	ld   [sMapExOBJ0LstId], a
	ld   a, $01
	ld   [sMapExOBJ1LstId], a
	ld   a, $02
	ld   [sMapExOBJ2LstId], a
	ld   a, $03
	ld   [sMapExOBJ3LstId], a
	; Start with OBP1 (inverted palette) by default
	ld   a, $10
	ld   [sMapExOBJ0Flags], a
	ld   [sMapExOBJ1Flags], a
	ld   [sMapExOBJ2Flags], a
	ld   [sMapExOBJ3Flags], a
	ret
	
; =============== Map_WriteExOBJ?Lst ===============
; Sets of functions to write OBJ mappings to OAM in the map screen.
;
; There are 4 generic slots (numbered 0 to 3) which can be used for anything.
; Each slot has its own subroutine to prepare the call to Map_WriteOBJLst.
; There is a separate function for each of the slots.
Map_WriteExOBJ0Lst:
	ld   hl, OBJLstPtrTable_MapMisc	; HL = Ptr to OBJList pointer tsble
	; Copy the ExOBJ info to the OAMWrite fields
	ld   a, [sMapExOBJ0Y]		; Y base coord
	ld   [sMapOAMWriteY], a
	ld   a, [sMapExOBJ0X]		; X base coord
	ld   [sMapOAMWriteX], a
	ld   a, [sMapExOBJ0LstId]	; Index to the OBJList ptr table
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapExOBJ0Flags]	; OBJ Flags
	ld   [sMapOAMWriteFlags], a
Map_WriteExOBJLst:
	call Map_WriteOBJLst
	ret
Map_WriteExOBJ1Lst:
	ld   hl, OBJLstPtrTable_MapMisc
	ld   a, [sMapExOBJ1Y]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapExOBJ1X]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapExOBJ1LstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapExOBJ1Flags]
	ld   [sMapOAMWriteFlags], a
	jr   Map_WriteExOBJLst
Map_WriteExOBJ2Lst:
	ld   hl, OBJLstPtrTable_MapMisc
	ld   a, [sMapExOBJ2Y]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapExOBJ2X]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapExOBJ2LstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapExOBJ2Flags]
	ld   [sMapOAMWriteFlags], a
	jr   Map_WriteExOBJLst
Map_WriteExOBJ3Lst:
	ld   hl, OBJLstPtrTable_MapMisc
	ld   a, [sMapExOBJ3Y]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapExOBJ3X]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapExOBJ3LstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapExOBJ3Flags]
	ld   [sMapOAMWriteFlags], a
	jr   Map_WriteExOBJLst
; =============== OBJLstPtrTable_MapMisc ===============
; Sprite mappings for miscellaneous map elements.
;
OBJLstPtrTable_MapMisc: 
	dw OBJLst_MapArrowLeft
	dw OBJLst_MapArrowRight
	dw OBJLst_MapArrowUp
	dw OBJLst_MapArrowDown
	dw OBJLst_MapBlinkDot
OBJLst_MapArrowUp:    INCBIN "data/objlst/map/arrow_up.bin"
OBJLst_MapArrowDown:  INCBIN "data/objlst/map/arrow_down.bin"
OBJLst_MapArrowLeft:  INCBIN "data/objlst/map/arrow_left.bin"
OBJLst_MapArrowRight: INCBIN "data/objlst/map/arrow_right.bin"
OBJLst_MapBlinkDot:   INCBIN "data/objlst/map/leveldot.bin"
	
; =============== Map_MoveMtTeapotLid ===============
; Writes and animates the mappings for the Mt.Teapot lid with the correct oscillation mode.
Map_MoveMtTeapotLid:
	; If C12 isn't yet completed, the lid can move
	ld   a, [sMapMtTeapotCompletionLast]
	bit  6, a
	jr   z, Map_NoMoveMtTeapotLid.canOscillate
	; Otherwise, fall back to the fixed position
	
; =============== Map_NoMoveMtTeapotLid ===============
; Writes and animates the mappings for Mt.Teapot, always in fixed position mode.
Map_NoMoveMtTeapotLid:
	call Map_MtTeapotLidSetPos ; Use the initial abs coordinates
	jr   Map_WriteMtTeapotLidOBJLst
;--
.addStep:
	add  $01
	jr   .updatePos
.canOscillate:
	; Get the movement mask used to determine the lid's speed.
	; This is based on the high byte of the timer, which allows the movement speed
	; to stay constant for a while.
	; The movement mask essentially changes between 1 and 3.
	ld   a, [sMapTimer_High]
	and  a, %11
	bit  0, a					; Is the resulting speed even?
	jr   z, .addStep			; If so, add 1 to it.
;--
.updatePos:
	; Allow movement only if (MapTimerLow & Mask) == 0
	ld   b, a					
	ld   a, [sMapTimer_Low]
	and  a, b							; Is the mask operation 0?
	jr   nz, .display
	ld   a, [sMapMtTeapotLidYTimer]		; Check the MSB of the lid's movement timer
	bit  7, a							; If it's set, it marks the lid as moving down
	jr   nz, .moveDown
	
.moveUp:
	ld   hl, sMapMtTeapotLidY
	dec  [hl]
	ld   hl, sMapMtTeapotLidYTimer
	inc  [hl]
	; As of .switchToUp, the timer for upwards movement starts at $00
	; When it reaches $0F, change the movement
	ld   a, [hl]						
	cp   a, $0F
	jr   z, .switchToDown
	
.display:
	call Map_MtTeapotLidUpdateCoords
	jr   Map_WriteMtTeapotLidOBJLst
	
.moveDown:
	ld   hl, sMapMtTeapotLidY
	inc  [hl]
	ld   hl, sMapMtTeapotLidYTimer
	inc  [hl]
	; As of .switchToDown, the timer for downwards movement starts at $80
	; When it reaches $8F, change the movement
	ld   a, [hl]
	and  a, $0F							
	cp   a, $0F
	jr   nz, .display
.switchToUp:
	; Clear the MSB to mark upwards movement (+ timer reset)
	xor  a
	ld   [sMapMtTeapotLidYTimer], a
	jr   Map_WriteMtTeapotLidOBJLst
.switchToDown:
	; Set the MSB to mark downwards movement (+ timer reset)
	xor  a
	add  $80
	ld   [sMapMtTeapotLidYTimer], a
	
; =============== Map_NoMoveMtTeapotLid ===============
; Writes the OBJLst for Mt.Teapot's lid in the overworld.
; This subroutine prepares a call to Map_OverworldWriteOBJLst.
Map_WriteMtTeapotLidOBJLst:
	ld   a, $00						; OBJLst 00 -> Mt.Teapot's lid
	ld   [sMapMtTeapotLidLstId], a
	ld   a, $10						; Set flags
	ld   [sMapMtTeapotLidFlags], a
	; Prepare call
	ld   hl, OBJLstPtrTable_Map_OverworldMtTeapot
	ld   a, [sMapMtTeapotLidY]		
	ld   [sMapOAMWriteY], a
	ld   a, [sMapMtTeapotLidX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapMtTeapotLidLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapMtTeapotLidFlags]
	ld   [sMapOAMWriteFlags], a
	ld   bc, sMapMtTeapotLidY
	ld   de, sMapMtTeapotLidX
	call Map_OverworldWriteOBJLst
	ret
	
; =============== Map_MtTeapotLidUpdateCoords ===============
; Updates the relative coordinates of Mt.Teapot's lid, similarly to
; how it's normally done at Map_UpdateOBJRelCoord.
;
; A pair of memory addresses is used to keep track of the previous scroll positions --
; the difference is added to the lid's coordinates.
Map_MtTeapotLidUpdateCoords:
	; Get the Y screen scroll amount compared to the last frame
	ld   hl, sMapScrollY
	ld   a, [sMapMtTeapotLidScrollYLast]	
	sub  a, [hl] ; a -= scrollY
	ld   b, a 								; B = LastScrollY - ScrollY
	; Add the scroll offset over the current relative Y pos
	ld   a, [sMapMtTeapotLidY]
	add  b
	ld   [sMapMtTeapotLidY], a
	
	;--
	; Do the same for the X coord
	; [BUG] The wrong address is being used, which only isn't a problem because this is drawn before the screen scrolls.
IF FIX_BUGS == 1
	ld   hl, sMapScrollX
ELSE
	ld   hl, rSCX
ENDC
	ld   a, [sMapMtTeapotLidScrollXLast]
	sub  a, [hl]
	ld   b, a
	ld   a, [sMapMtTeapotLidX]
	add  b
	ld   [sMapMtTeapotLidX], a
	
	;--
	; Sync the LastScroll values
	ld   a, [sMapScrollY]
	ld   [sMapMtTeapotLidScrollYLast], a
	ld   a, [sMapScrollX]
	ld   [sMapMtTeapotLidScrollXLast], a
	ret

; =============== Map_MtTeapotLidSetPosCutscene ===============
; Used to set the initial position of Mt.Teapot's lid when the Mt.Teapot cutscene starts.
; This is done as the lid starts higher than usual.
Map_MtTeapotLidSetPosCutscene:
	ld   a, $50						; Absolute Y Value
	jr   Map_MtTeapotLidSetPos2
; =============== Map_MtTeapotLidSetPos ===============
; Used to set the initial screen position for Mt.Teapot's lid.
; When it stops moving (after C12 clear), this fixed value will always be used.
Map_MtTeapotLidSetPos:
	ld   a, $56						; Absolute Y Value
; =============== Map_MtTeapotLidSetPos2 ===============
Map_MtTeapotLidSetPos2:
	; The absolute value for both coords needs to be converted to one relative to the screen,
	; which is what OBJ use.
	ld   hl, sMapScrollY			; HL = base Y scroll
	sub  a, [hl]					; RelLidY = AbsLidY - ScrollY
	ld   [sMapMtTeapotLidY], a		
	ld   a, [hl]					; Save the ScrollY to detect OBJ movement
	ld   [sMapMtTeapotLidScrollYLast], a
	; Do the same for the X pos
	ld   a, $55						; Absolute X Value
	ld   hl, rSCX
	sub  a, [hl]
	ld   [sMapMtTeapotLidX], a
	ld   a, [hl]
	ld   [sMapMtTeapotLidScrollXLast], a
	ret
	
; =============== Map_C12ClearCutscene_Do ===============
; Plays the cutscene where Mt.Teapots lid crashes down, 
; shown on first completion of Course 12.
Map_C12ClearCutscene_Do:
	call HomeCall_Map_Overworld_AnimTiles
	ld   a, [sMapOverworldCutsceneScript]
	and  a
	jr   z, .act0
	cp   a, $01
	jr   z, .act1
	cp   a, $02
	jr   z, .act2
	cp   a, $03
	jr   z, .act3
	cp   a, $04
	jr   z, .act4
	
.writeLid:
	call Map_MtTeapotLidUpdateCoords
	jp   Map_WriteMtTeapotLidOBJLst
.act0:
	ld   a, [sMapTimer_Low]			; Every 8 frames
	and  a, $07
	jr   nz, .writeLid
	
	ld   hl, sMapMtTeapotLidY		; The lid slowly rises up
	dec  [hl]
	
	ld   hl, sMapMtTeapotLidYTimer
	inc  [hl]
	ld   a, [hl]
	cp   a, $18						; Until it moves $18 pixels up
	jr   nz, .writeLid
.nextAct:
	; Reset the timer and switch to the next cutscene act
	xor  a
	ld   [sMapMtTeapotLidYTimer], a
	ld   hl, sMapOverworldCutsceneScript
	inc  [hl]
	ret
.act1:
	ld   a, [sMapTimer_Low]			; Every 4 frames
	and  a, $03
	jr   nz, .writeLid
	
	ld   a, SFX1_13		; Play "warning" SFX
	ld   [sSFX1Set], a
	
	ldh  a, [rOBP0]					; Flash the lid's palette
	xor  $1C
	ldh  [rOBP0], a
	
	ld   hl, sMapMtTeapotLidYTimer	; For $15 (* 4) frames
	inc  [hl]
	ld   a, [hl]
	cp   a, $15
	jr   nz, .writeLid
	
	ld   a, $1C						; After it's done, return the palette to normal
	ldh  [rOBP0], a
	jr   .nextAct
.act2:
	ld   hl, sMapMtTeapotLidY		; Lid falls down fast at 2px / frame
	inc  [hl]
	inc  [hl]
	
	ld   hl, sMapMtTeapotLidYTimer	; For 8 frames
	inc  [hl]
	ld   a, [hl]
	cp   a, $08
	jr   nz, .writeLid
	
	ld   a, $01						; After that, start screen shake effect
	ld   [sMapShake], a
	call Map_MtTeapotLidSetPos
	ld   a, SFX4_02		; And its SFX
	ld   [sSFX4Set], a
	jr   .nextAct
.act3:
	ld   a, [sMapShake]				; Perform the effect for $40 frames (used as makeshift timer)
	inc  a
	ld   [sMapShake], a
	cp   a, $40
	jr   nz, .writeLid
	
	xor  a							; Clear screen shake related memory
	ld   [sMapShake], a
	ld   [sMapScrollYShake], a
	ld   [sMapScrollY], a
	ld   [sMapCutsceneEndTimer], a
	jr   .nextAct
.act4:
	ld   hl, sMapCutsceneEndTimer	; Pause cutscene for $B0 frames
	inc  [hl]
	ld   a, [hl]
	cp   a, $B0
	jp   nz, .writeLid
	
	ld   a, MAP_MODE_CUTSCENEFADEOUT	; After that's done, start the fade out
	ld   [sMapId], a
	ld   a, MAP_MODE_INITMTTEAPOT
	ld   [sMapNextId], a
	ld   a, $01							; Request Course Clear screen after fade out ends
	ld   [sMapFadeOutRetVal], a		
	xor  a
	ld   [sMapCutsceneEndTimer], a
	ld   a, BGMACT_FADEOUT				; Fade out the song
	ld   [sBGMActSet], a
	ret

; =============== Map_Unused_WriteMtTeapotSproutOBJLst ===============
; [TCRF] Unreferenced sprite mapping setup code for the sprout coming out of Mt.Teapot.
;        The graphics for it exist in the overworld submap GFX are present alongside the sprite mapping
;
; - its position is 48px to the right of the lid, with same Y position. 
;   the same Y position suggests it would have been visible only after the lid stopped moving 
;   though it doesn't completely align
; - it uses otherwise unused memory addresses for its OAM data
; - it uses an otherwise unused mapping frame (which reference unused graphics) from the same table as the lid
;
; Considering only the initial mapping frame is shown, the code may be unfinished.
; Note that there is an also unused table just after this subroutine with the frame IDs 
; which would have been used for animating the sprite.

Map_Unused_WriteMtTeapotSproutOBJLst:
	; OBJ Settings
	ld   a, [sMapMtTeapotLidY] 					; Y = LidY
	ld   [sMap_Unused_MtTeapotSproutY], a
	ld   a, [sMapMtTeapotLidX] 					; X = LidX + $30
	add  $30
	ld   [sMap_Unused_MtTeapotSproutX], a
	ld   a, $01									; Use first mapping frame
	ld   [sMap_Unused_MtTeapotSproutLstId], a
	ld   a, $10
	ld   [sMap_Unused_MtTeapotSproutFlags], a
	; Prepare call
	ld   hl, OBJLstPtrTable_Map_OverworldMtTeapot
	ld   a, [sMap_Unused_MtTeapotSproutY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMap_Unused_MtTeapotSproutX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMap_Unused_MtTeapotSproutLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMap_Unused_MtTeapotSproutFlags]
	ld   [sMapOAMWriteFlags], a
	call Map_WriteOBJLst
	ret
; Unused sprout anim defn
OBJLstAnim_Unused_Map_MtTeapotSprout:
	db $01 
	db $02
	db $03
	db $04
	db $FF

; =============== OBJLstPtrTable_Map_OverworldMtTeapot ===============
OBJLstPtrTable_Map_OverworldMtTeapot: 
	dw OBJLst_Map_MtTeapotLid
	; [TCRF] Unused sprite mappings for Mt.Teapot's sprout
	dw OBJLst_Unused_Map_MtTeapotSprout0
	dw OBJLst_Unused_Map_MtTeapotSprout1
	dw OBJLst_Unused_Map_MtTeapotSprout2
	dw OBJLst_Unused_Map_MtTeapotSprout3
OBJLst_Map_MtTeapotLid: INCBIN "data/objlst/map/overworld_mtteapot_lid.bin"
OBJLst_Unused_Map_MtTeapotSprout0: INCBIN "data/objlst/map/overworld_unused_mtteapot_sprout0.bin"
OBJLst_Unused_Map_MtTeapotSprout1: INCBIN "data/objlst/map/overworld_unused_mtteapot_sprout1.bin"
OBJLst_Unused_Map_MtTeapotSprout2: INCBIN "data/objlst/map/overworld_unused_mtteapot_sprout2.bin"
OBJLst_Unused_Map_MtTeapotSprout3: INCBIN "data/objlst/map/overworld_unused_mtteapot_sprout3.bin"

; =============== Map_C32ClearCutscene_Init ===============
; Initializes the cutscene played in the overworld of Parsley Woods' lake being drained.
Map_C32ClearCutscene_Init:
	call HomeCall_Map_LoadPalette
	call HomeCall_LoadGFX_Overworld
	call HomeCall_LoadBG_Overworld
	call HomeCall_Map_Overworld_WriteEv
	call HomeCall_Map_ClearRAM
	
	; Set screen scroll
	ld   a, $3A
	ld   [sMapScrollY], a
	ld   a, $60
	ld   [sMapScrollX], a
	ld   a, $9C
	
	; Set the initial mapping options for the water sprout
	ld   [sMapLakeSproutY], a
	ld   [sMap_Unused_LakeSproutYCopy], a ; [TCRF] Only set here, never read back
	ld   a, $60
	ld   [sMapLakeSproutX], a
	ld   [sMap_Unused_LakeSproutXCopy], a
	ld   a, $00
	ld   [sMapLakeSproutLstId], a
	
	; And the sprite version of the lake
	ld   a, $66
	ld   [sMapLakeDrainY], a
	ld   [sMap_Unused_LakeDrainYCopy], a
	ld   a, $60
	ld   [sMapLakeDrainX], a
	ld   [sMap_Unused_LakeDrainXCopy], a
	
	ld   a, $04
	ld   [sMapLakeDrainLstId], a
	
	call HomeCall_Map_InitMisc
	ld   a, MAP_MODE_PARSLEYWOODSCUTSCENE
	ld   [sMapId], a
	ld   a, BGM_CUTSCENE
	ld   [sBGMSet], a
	ret
	
; =============== Map_WriteLakeDrainOBJLst ===============
Map_WriteLakeSproutOBJLst:
	ld   a, $10
	ld   [sMapLakeSproutFlags], a
	ld   hl, OBJLstPtrTable_C32ClearCutscene
	ld   a, [sMapLakeSproutY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapLakeSproutX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapLakeSproutLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapLakeSproutFlags]
	ld   [sMapOAMWriteFlags], a
	call Map_WriteOBJLst
	ret
; =============== Map_WriteLakeDrainOBJLst ===============
Map_WriteLakeDrainOBJLst:
	ld   a, $10
	ld   [sMapLakeDrainFlags], a
	ld   hl, OBJLstPtrTable_C32ClearCutscene
	ld   a, [sMapLakeDrainY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapLakeDrainX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapLakeDrainLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapLakeDrainFlags]
	ld   [sMapOAMWriteFlags], a
	call Map_WriteOBJLst
	ret
; =============== Map_C32ClearCutscene_Do ===============
; Handles the lake drain cutscene after clearing C32 for the first time.
Map_C32ClearCutscene_Do:
	call HomeCall_Map_Overworld_AnimTiles
	
	; Each act specifies a timer target.
	; When the timer reaches a target value, it switches to the next act.
	; The timer is reset betwee acts.
	
; Generates timer elapse code
; IN
; - 1: Jump target if the target isn't reached
mC32Wait: MACRO
	ld   a, [sMapC32CutsceneTimerTarget]	; B = Timer target
	ld   b, a
	ld   a, [sMapC32CutsceneTimer]			; A = Timer
	inc  a									; (timer++)
	ld   [sMapC32CutsceneTimer], a			
	cp   a, b								; Have we reached the target?
	jr   nz, \1								; If not, jump
ENDM
; Generates timer elapse code with fixed target value
; IN
; - 1: Target timer value
; - 2: Jump target if the target isn't reached
mC32WaitFix: MACRO
	ld   a, [sMapC32CutsceneTimer]
	inc  a
	ld   [sMapC32CutsceneTimer], a
	cp   a, \1
	jp   nz, \2
ENDM
	
	ld   a, [sMapOverworldCutsceneScript]
	and  a
	jr   z, .act0	; Init
	cp   a, $01
	jr   z, .act1	; Lake 4-5, Sprout
	cp   a, $02
	jp   z, .act2	; Lake 4-5 slow, Sprout
	cp   a, $03
	jp   z, .act3	; Lake 5-6 slow, Sprout slow
	cp   a, $04
	jp   z, .act4	; Lake 7, Sprout slow
	cp   a, $05
	jp   z, .act5	; No lake, Sprout slow
.act6:
	; Did the timer reach $FF yet?
	; (the timer is set to $00 at the start)
	; This is to delay the fade out until the game finishes playing the SFX.
	ld   a, [sMapTimer0]
	cp   a, $FF
	ret  nz
	
	ld   a, $01
	ld   [sMapParsleyWoodsCompletionLast], a ; Forcefully set the last completion flag just in case
	ld   [sMapC32ClearFlag], a
	; Cleanup and setup switch to next mode
	xor  a
	ld   [sMapLakeDrainLstIdTarget], a
	ld   a, MAP_MODE_FADEOUT
	ld   [sMapId], a
	ld   a, MAP_MODE_INITPARSLEYWOODS
	ld   [sMapNextId], a
	; First show the course clear screen though
	ld   a, $01
	ld   [sMapFadeOutRetVal], a
	ret
.act0:
	; Animate every 4 frames the water sprout and lake
	ld   a, $03
	ld   [sMapLakeSproutAnimTimer], a
	ld   a, $03
	ld   [sMapLakeDrainAnimTimer], a
	
	; Set anim act timer target.
	; This determines how long to display an anim act.
	;
	; There doesn't appear to be a reason why the value isn't hardcoded for all acts,
	; as in the end each act only uses a single target value.
	; In fact, an hardcoded value is actually used in later scripts instead of this.
	ld   a, $8F
	ld   [sMapC32CutsceneTimerTarget], a
	; Lake - Mapping ID target (+1)
	; Will make use of frames $04-$05
	ld   a, $06
	ld   [sMapLakeDrainLstIdTarget], a
	; Reset water sprout timer
	xor  a
	ld   [sMapTimer0], a
	ld   a, SFX4_13
	ld   [sSFX4Set], a
.nextAct:
	; Reset timer for current anim script
	xor  a
	ld   [sMapC32CutsceneTimer], a
	ld   hl, sMapOverworldCutsceneScript
	inc  [hl]
.animLakeDrain:
	ld   hl, sMapLakeDrainLstId
	ld   de, sMapLakeDrainAnimTimer
	call Map_SetLakeDrainOBJLst
.animSprout:;J
	ld   hl, sMapLakeSproutLstId
	ld   de, sMapLakeSproutAnimTimer
	call Map_SetLakeSproutOBJLst
	ret
.act1:
	mC32Wait .animLakeDrain
	ld   a, $8F
	ld   [sMapC32CutsceneTimerTarget], a
	; Slow down lake anim speed
	ld   a, $07
	ld   [sMapLakeDrainAnimTimer], a
	jr   .nextAct
.act2:
	mC32Wait .animLakeDrain
	; Reset to first frame in new range
	ld   a, $05
	ld   [sMapLakeDrainLstId], a
	ld   a, $6F
	ld   [sMapC32CutsceneTimerTarget], a
	
	; Update lake frame target.
	; This will make the lake use mapping frames $05-$06.
	ld   a, $07
	ld   [sMapLakeDrainLstIdTarget], a
	; Slow down the anim speed of both spries
	ld   a, $07
	ld   [sMapLakeDrainAnimTimer], a
	ld   [sMapLakeSproutAnimTimer], a
	jr   .nextAct
.act3:
	mC32Wait .animLakeDrain
	ld   a, $00
	ld   [sMapLakeSproutLstId], a
	jp   .nextAct
.act4:
	; Set the current mapping for the lake to $7
	; This is for the "almost drained" lake, which is not animated.
	ld   a, $07
	ld   [sMapLakeDrainLstId], a
	call Map_WriteLakeDrainOBJLst
	; Wait for timer to reach $77 before switching
	mC32WaitFix $77, .animSprout
	xor  a
	ld   [sMapC32CutsceneTimer], a
	ld   hl, sMapOverworldCutsceneScript
	inc  [hl]
	ret
.act5:
	mC32WaitFix $50, .animSprout
	ld   hl, sMapOverworldCutsceneScript
	inc  [hl]
	
	xor  a									
	ld   [sMapTimer0], a					
	ld   a, BGM_WORLDCLEAR
	ld   [sBGMSet], a
	ret
	
; =============== Map_SetLakeSproutOBJLst ===============
; Animates the water sprout in the Parsley Woods C32 cutscene.
;
; IN
; - HL: Ptr to OBJLst ID for the water sprout
; - DE: [NOT USED] Ptr to animation bitmask.
;       This would be a bitmask which is AND'ed to a timer to determine when to
;       switch mapping frame, but the address is hardcoded to the subroutine.
;       This is generally a value with bits always grouped at the beginning, to guarantee a constant animation speed.
;       Because the frame ID changes when Timer & Bitmask == 0, the less bits a bitmask has, faster the animation plays.

Map_SetLakeSproutOBJLst:
	ld   a, [sMapLakeSproutAnimTimer]
	ld   b, a
	ld   a, [sMapTimer0]
	and  a, b					; Is AnimMask & Timer != 0?
	jr   nz, .write				; If not, don't update the frame
	;--
	; Loop between $00-$03
	inc  [hl]					; Otherwise, switch to the next frame
	ld   a, [hl]
	cp   a, $04					; The water sprout mapping id should be in range $00-$03
	jr   nz, .write
	
	ld   a, $00					; Otherwise reset it back to $00
	ld   [hl], a
	ld   a, SFX4_06	; And use this opportunity to play the SFX so it won't cut off too much
	ld   [sSFX4Set], a
	;--
.write:
	call Map_WriteLakeSproutOBJLst
	ret
	
; =============== Map_SetLakeDrainOBJLst ===============
; Animates the lake in the Parsley Woods C32 cutscene.
; This cycles through the needed mapping frames for the sprite version of the lake.
;
; Uses mapping frames $04-$06, but only in groups of 2 to allow the effect of draining the lake.
; Mapping frame $07 also exists but doesn't get animated and as such is done elsewhere.
;
; IN
; - HL: Ptr to OBJLst ID
; - DE: [NOT USED] Ptr to animation timer
Map_SetLakeDrainOBJLst:
	; Wait for the timer to switch frame
	ld   a, [sMapLakeDrainAnimTimer]
	ld   b, a
	ld   a, [sMapTimer_Low]
	and  a, b
	jr   nz, .write
	
	;--
	inc  [hl]							
	; The target mapping ID (+1) for the lake can change
	; (to progress gradually through the levels of drainage)
	; so it isn't hardcoded like the water sprout
	ld   a, [sMapLakeDrainLstIdTarget]
	ld   b, a							; B = Target
	ld   a, [hl]						; A = Current
	cp   a, b							; Have we reached the target?
	
	jr   nz, .write						; If not, write
	ld   a, [sMapLakeDrainLstIdTarget]	; Otherwise, decrement it by 2
	sub  a, $02
	ld   [hl], a
	;--
.write:
	call Map_WriteLakeDrainOBJLst
	ret
	
; =============== OBJLstPtrTable_C32ClearCutscene ===============
OBJLstPtrTable_C32ClearCutscene:
	dw OBJLst_Map_Overworld_LakeSprout0
	dw OBJLst_Map_Overworld_LakeSprout1
	dw OBJLst_Map_Overworld_LakeSprout2
	dw OBJLst_Map_Overworld_LakeSprout3
	dw OBJLst_Map_Overworld_LakeDrain0
	dw OBJLst_Map_Overworld_LakeDrain1
	dw OBJLst_Map_Overworld_LakeDrain2
	dw OBJLst_Map_Overworld_LakeDrain3
OBJLst_Map_Overworld_LakeSprout0: INCBIN "data/objlst/map/overworld_lakesprout0.bin"
OBJLst_Map_Overworld_LakeSprout1: INCBIN "data/objlst/map/overworld_lakesprout1.bin"
OBJLst_Map_Overworld_LakeSprout2: INCBIN "data/objlst/map/overworld_lakesprout2.bin"
OBJLst_Map_Overworld_LakeSprout3: INCBIN "data/objlst/map/overworld_lakesprout3.bin"
OBJLst_Map_Overworld_LakeDrain0: INCBIN "data/objlst/map/overworld_lakedrain0.bin"
OBJLst_Map_Overworld_LakeDrain1: INCBIN "data/objlst/map/overworld_lakedrain1.bin"
OBJLst_Map_Overworld_LakeDrain2: INCBIN "data/objlst/map/overworld_lakedrain2.bin"
OBJLst_Map_Overworld_LakeDrain3: INCBIN "data/objlst/map/overworld_lakedrain3.bin"

; =============== Map_Ending_Do ===============
; Processes the second part of the ending sequence.
; All of these acts/"scripts" are set to execute every 4 frames,
; with the exception of writing the helicopter mappings as they always have to be drawn every frame.
;
; As a result, all delays are multiplied by 4, which is marked by a "(x4)" in some comments.
;
; This part of the ending also reuses other memory addresses normally used for different purposes in other maps.
; Most of these involve the animation timers and other local timers specific to the act.
Map_Ending_Do:

;--
; Common code snippets used across all acts
; The 4 frame delay
mMapEnding_Timing: MACRO
	ld   a, [sMapTimer_Low]
	and  a, $03
	ret  nz
ENDM

; Animates Mario's helicopter by alternating between two frames
; Do not use for the small helicopter OBJ
mMapEnding_AnimHeli: MACRO
	ld   a, [sMapEndingHeliLstId]
	xor  $01
	ld   [sMapEndingHeliLstId], a
ENDM
;--

	call Map_Ending_DrawOBJ
	ld   a, [sMapSyrupCastleCutsceneAct]
	and  a
	jr   z, .act0	; $42-$00   | Wario jumps
	cp   a, $01
	jp   z, .act1	; $01-$00   | Helicopter appears and moves to the left from off-screen
	cp   a, $02
	jr   z, .act2	; $01-$81   | Mario greets Wario
	cp   a, $03
	jr   z, .act3	; $82-$F8   | Heli moves up and left
	cp   a, $04
	jr   z, .act4	; $F9-$20   | Heli moves down and clings to statue
	cp   a, $05
	jr   z, .act5	; $21-$0124 | Heli moves up
	cp   a, $06
	jr   z, .act6	; $25-$64   | Wait
	cp   a, $07
	jr   z, .act7	; $65-$90   | Heli moves left, goes off-screen
	cp   a, $08
	jr   z, .act8	; $91-$10   | Wait for SFX
	cp   a, $09
	jr   z, .act9	; $11-$017C | Small heli moves right across the entire screen
	cp   a, $0A
	jr   z, .actA	; $7D-$01BC | Delay and Wario turns
.actB:
	ld   a, [sMapSyrupCastleCutsceneTimer]
	inc  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	cp   a, $70
	ret  nz
	
	xor  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   [sMapSyrupCastleCutsceneAct], a
	ld   [sMapSyrupCastleCutscene], a
	ld   a, MAP_MODE_FADEOUT
	ld   [sMapId], a
	ld   a, MAP_MODE_INITSYRUPCASTLE
	ld   [sMapNextId], a
	; Request ending game mode on fade out
	ld   a, $01
	ld   [sMapFadeOutRetVal], a
	ld   a, BGMACT_FADEOUT
	ld   [sBGMActSet], a
	ret
.act0:
	;--
	ld   a, [sMapTimer_Low]
	and  a, $10				; Every $10 frames...
	swap a
	and  a
	jr   z, .warioJump		; ...alternate between the jumping frame and the back frame
	ld   a, MAP_MWEA_JUMP
.warioJump:
	ld   [sMapWarioLstId], a
	;--
	; Wait for $C0 ($30*04) frames before switching to next script
	mMapEnding_Timing
	ld   a, [sMapSyrupCastleCutsceneTimer]
	inc  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	cp   a, $30
	ret  nz
	;--
	; Cleanup and next script
	xor  a
	ld   [sMapWarioLstId], a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	ret
.act1:	jp   Map_Ending_DoAct1
.act2:	jp   Map_Ending_DoAct2
.act3:	jp   Map_Ending_DoAct3
.act4:	jp   Map_Ending_DoAct4
.act5:	jp   Map_Ending_DoAct5
.act6:	jp   Map_Ending_DoAct6
.act7:	jp   Map_Ending_DoAct7
.act9:	jr   Map_Ending_DoAct9
.actA:	jr   Map_Ending_DoActA
.act8:
	; Wait for $80 frames before continuing
	ld   a, [sMapSyrupCastleCutsceneTimer]
	inc  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	cp   a, $80
	ret  nz
	
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	xor  a
	ld   [sMapEndingHeliX], a
	ret
	
; =============== Map_Ending_DoActA ===============
Map_Ending_DoActA:
	mMapEnding_Timing
	; Change mapping frame based on timer
	ld   a, [sMapSyrupCastleCutsceneTimer]
	inc  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	cp   a, $40
	jr   z, .setFront
	cp   a, $50
	jr   z, .setShrugNextAct
	ret
.setFront:
	ld   a, MAP_MWEA_FRONT
	ld   [sMapWarioLstId], a
	ld   a, SFX1_19
	ld   [sSFX1Set], a
	ret
.setShrugNextAct:
	ld   a, MAP_MWEA_SHRUG
	ld   [sMapWarioLstId], a
	xor  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	ld   a, SFX1_1A
	ld   [sSFX1Set], a
	ret
	
; =============== Map_Ending_DoAct9 ===============
Map_Ending_DoAct9:
	ld   hl, OBJLstPtrTable_Map_Ending_Heli
	call Map_Ending_WriteOBJLst
	
	; Wait for $FF frames
	ld   a, [sMapSyrupCastleCutsceneTimer]
	cp   a, $FF
	jr   nz, .delayMove
	mMapEnding_Timing
	
	; Heli animation (far away)
	ld   a, [sMapEndingHeliLstId]
	bit  0, a
	jr   nz, .planeAltFrame
	ld   a, $03
	ld   [sMapEndingHeliLstId], a
	;--
	; Move the helicopter to the right by $8 px
	ld   a, [sMapEndingHeliX]
	add  $08
	ld   [sMapEndingHeliX], a
	
	cp   a, $F0			; Is the helicopter off-screen in the target pos?
	jr   z, .nextAct	; If so, switch to the next act	
	cp   a, $30			; Change mapping frame as appropriate
	jr   z, .warioFront
	cp   a, $80
	jr   z, .warioBack
	ret
.planeAltFrame:
	ld   a, $02
	ld   [sMapEndingHeliLstId], a
	ret
.nextAct:
	xor  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	ret
.warioFront:
	xor  a ; MAP_MWEA_FRONT
	ld   [sMapWarioLstId], a
	ret
.warioBack:
	ld   a, MAP_MWEA_BACKRIGHT
	ld   [sMapWarioLstId], a
	ret
.delayMove:
	ld   hl, sMapSyrupCastleCutsceneTimer
	inc  [hl]
	ret
	
; =============== Map_Ending_DoAct7 ===============
; NOTE: Map_Timer does not get reset to 0 before
Map_Ending_DoAct7:
	ld   hl, OBJLstPtrTable_Map_Ending_Heli
	call Map_Ending_WriteOBJLst
	
	;--
	; [TCRF] Global timer never reaches $00 in this act
	ld   a, [sMapTimer_Low]
	and  a, $FF
	jr   nz, .main
	ld   hl, sMapEndingHeliSpeed
	inc  [hl]
.main:
	mMapEnding_Timing
	mMapEnding_AnimHeli
	
	;--
	; Calculate the movement speed to the left.
	; Speed gradually increases each iteration:
	; - It's based on a global timer.
	;   It expects the source base speed (sMapEndingHeliSpeed) to be 2.
	; - The new base speed is added to the previous speed value.
	;   As a result the speed will increase very quickly.
	;
	; To continue to the next act, the helicopter has to reach a specific X position.
	; Due to the reliance on a global timer, any timing change to a previous phase will potentially break this.
	
	; BaseSpeed = SpeedTimer & $FC.
	; However, that means if SpeedTimer < 4, BaseSpeed will be 0.
	; We don't want that, so set BaseSpeed to 1 in that case.
	
	; NOTE: sMapEndingHeliSpeed points to the same address as sMapEndingSparkleTblIdx.
	;       We're piggy-backing off it since it already gets incresed every (x4) frames.
	ld   a, [sMapEndingHeliSpeed]
	and  a, $FC
	jr   z, .fixSpeed
	ld   a, [sMapEndingHeliSpeed]
.moveHeliLeft:
	ld   b, a							; B = Base speed
	ld   a, [sMapSyrupCastleCutsceneTimer]	; A = Previous speed
	; Add the current speed to the previous
	add  b
	ld   [sMapSyrupCastleCutsceneTimer], a	
	
	; When the X position reaches $D5, switch to the next
	
	; with $58 being the initial X position of the helicopter:
	; ($D5 = $58 - ($01 + $02 + $03 + $04 + $08 + $0C + $11 + $16 + $1C + $22))
	;                 1     1     1     1     4     4     5     5     6     6
	ld   c, a
	ld   a, [sMapEndingHeliX]
	cp   a, $D5
	jr   z, .nextAct
	
	; Move both the helicopter and the attached statue to the left
	sub  a, c
	ld   [sMapEndingHeliX], a
	ld   a, [sMapEndingStatueHighX]
	sub  a, c
	ld   [sMapEndingStatueHighX], a
	ld   a, [sMapEndingStatueLowX]
	sub  a, c
	ld   [sMapEndingStatueLowX], a
	
	; When heli X = $3A, make Wario turn left
	ld   a, [sMapEndingHeliX]
	cp   a, $3A
	ret  nz
	ld   a, MAP_MWEA_BACKLEFT
	ld   [sMapWarioLstId], a
	ld   a, SFX1_33
	ld   [sSFX1Set], a
	ret
.fixSpeed:
	ld   a, $01
	jr   .moveHeliLeft
.nextAct:
	xor  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	ld   a, $44					; Set heli Y pos
	ld   [sMapEndingHeliY], a
	ld   a, $03					; Small helicopter
	ld   [sMapEndingHeliLstId], a
	ret
	
; =============== Map_Ending_DoAct6 ===============
Map_Ending_DoAct6:
	ld   hl, OBJLstPtrTable_Map_Ending_Heli
	call Map_Ending_WriteOBJLst
	mMapEnding_Timing
	;--
	mMapEnding_AnimHeli
	
	; Wait for $10(x4) frames
	ld   a, [sMapSyrupCastleCutsceneTimer]
	inc  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	cp   a, $10
	ret  nz
.nextAct:
	xor  a
	ld   [sMapEndingHeliLstId], a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	ret
	
; =============== Map_Ending_DoAct5 ===============
Map_Ending_DoAct5:
	ld   hl, OBJLstPtrTable_Map_Ending_Heli
	call Map_Ending_WriteOBJLst
	; Wait for $10(x4) frames with the standard heli anim before continuing
	ld   a, [sMapAnimFrame_Misc]
	cp   a, $10
	jr   nz, .wait
	mMapEnding_Timing
	
	; Heli anim (hello frames) while rising up
	ld   a, [sMapEndingHeliLstId]
	bit  0, a
	jr   nz, .heliAltHelloFrame
	ld   a, $05
	ld   [sMapEndingHeliLstId], a
	
	; Every other(x4) frame, move the helicopter up $10 times
	ld   a, [sMapSyrupCastleCutsceneTimer]
	cp   a, $10
	jr   z, .moveHeliUp
	inc  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ret
.heliAltHelloFrame:
	ld   a, $04
	ld   [sMapEndingHeliLstId], a
	ret
.moveHeliUp:
	ld   a, [sMapEndingHeliY]
	cp   a, $20					; Moving up $10 times should make it reach this position
	jr   z, .nextAct
	; Move heli and attached statue up by 1px
	dec  a
	ld   [sMapEndingHeliY], a
	ld   hl, sMapEndingStatueHighY
	dec  [hl]
	ld   hl, sMapEndingStatueLowY
	dec  [hl]
	ret
.nextAct:
	xor  a
	ld   [sMapEndingHeliLstId], a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	ret
.wait:
	mMapEnding_Timing
	
	ld   hl, sMapAnimFrame_Misc
	inc  [hl]
	mMapEnding_AnimHeli
	ret
	
; =============== Map_Ending_DoAct4 ===============
Map_Ending_DoAct4:
	ld   hl, OBJLstPtrTable_Map_Ending_Heli
	call Map_Ending_WriteOBJLst
	mMapEnding_Timing
	
	mMapEnding_AnimHeli
	
	; Move it down until it reaches Y pos $2A
	ld   a, [sMapEndingHeliY]
	cp   a, $2A
	jr   z, .nextAct
	inc  a
	inc  a
	ld   [sMapEndingHeliY], a
	ret
.nextAct:
	ld   a, SFX4_0E
	ld   [sSFX4Set], a
	; Move it down one last time
	ld   a, $28
	ld   [sMapEndingHeliY], a
	xor  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   [sMapEndingHeliLstId], a
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	ret

; =============== Map_Ending_DoAct3 ===============
Map_Ending_DoAct3:
	ld   hl, OBJLstPtrTable_Map_Ending_Heli
	call Map_Ending_WriteOBJLst
	mMapEnding_Timing
	
	; Helicopter animation, default frames
	ld   a, [sMapEndingHeliLstId]
	bit  0, a
	jr   nz, .planeAltFrame
	ld   a, $01
.chkMoveUp:
	ld   [sMapEndingHeliLstId], a
	; Move heli upwards until it reaches Y $18
	; When it reaches that position, move it to the left
	ld   a, [sMapEndingHeliY]
	cp   a, $18
	jr   z, .movePlaneLeft
	dec  a
	dec  a
	ld   [sMapEndingHeliY], a
	ret
.planeAltFrame:
	ld   a, $00
	jr   .chkMoveUp
.movePlaneLeft:
	; Move it left until it reaches the middle of the screen
	ld   a, [sMapEndingHeliX]
	cp   a, $58
	jr   z, .nextAct
	dec  a
	dec  a
	ld   [sMapEndingHeliX], a
	ret
.nextAct:
	xor  a
	ld   [sMapEndingHeliLstId], a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	ret
	
; =============== Map_Ending_DoAct2 ===============
Map_Ending_DoAct2:
	ld   hl, OBJLstPtrTable_Map_Ending_Heli
	call Map_Ending_WriteOBJLst
	
	; Script is active for $20(x4) frames before switching
	ld   a, [sMapSyrupCastleCutsceneTimer]
	cp   a, $20
	jr   z, .nextAct
	mMapEnding_Timing
	
	ld   hl, sMapSyrupCastleCutsceneTimer	 ; Timer++
	inc  [hl]
	
	; After $10 frames, switch to the frames where Mario greets the player
	ld   a, [sMapAnimFrame_Misc]
	cp   a, $10
	jr   z, .useHelloFrames
.useDefaultFrames:
	inc  a
	ld   [sMapAnimFrame_Misc], a
	
	; Alternate every other (x4) frame the helicopter anim ($00-$01)
	ld   a, [sMapEndingHeliLstId]
	bit  0, a
	jr   nz, .heliAltFrame
	ld   a, $01
	ld   [sMapEndingHeliLstId], a
	ret
.heliAltFrame:
	xor  a
	ld   [sMapEndingHeliLstId], a
	ret
.useHelloFrames:
	; Alternate every other (x4) frame the helicopter anim ($04-$05)
	ld   a, [sMapEndingHeliLstId]
	bit  0, a
	jr   nz, .heliAltHelloFrame
	ld   a, $05
	ld   [sMapEndingHeliLstId], a
	ret
.heliAltHelloFrame:
	ld   a, $04
	ld   [sMapEndingHeliLstId], a
	ret
.nextAct:
	ld   a, $04
	ld   [sMapEndingHeliLstId], a
	xor  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   [sMapAnimFrame_Misc], a
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	ret
	
; =============== Map_Ending_DoAct1 ===============
Map_Ending_DoAct1:
	ld   hl, OBJLstPtrTable_Map_Ending_Heli
	call Map_Ending_WriteOBJLst
	; Force proper palette
	ld   a, $10
	ld   [sMapEndingHeliFlags], a
	mMapEnding_Timing
	
	; Delay the helicopter's on-screen appearance by $20(x4) frames
	; (while still playing its SFX)
	ld   a, [sMapSyrupCastleCutsceneTimer]
	cp   a, $20
	jr   nz, .offscreen
	; Move the helicopter to the left by 2px
	ld   a, [sMapEndingHeliX]
	dec  a
	dec  a
	ld   [sMapEndingHeliX], a	
	cp   a, $B0					; Has the heli reached this position?
	jr   z, .warioRight			; If so, the helicopter is now on-screen. Make Wario turn to the right.
	cp   a, $7A				 	; Have we reached the target position (close to the middle of the screen)?
	jr   nz, .switchPlaneFrame	; If not, play the heli animation
.heliCenter:
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	; Reset Wario's animation to the back one,
	; as the heli is now close to the center of the screen.
	xor  a
	ld   [sMapTimer_Low], a
	ld   [sMapSyrupCastleCutsceneTimer], a
.setWarioLstId:
	ld   [sMapWarioLstId], a
.switchPlaneFrame:
	mMapEnding_AnimHeli
	ret
.warioRight:
	ld   a, MAP_MWEA_BACKRIGHT
	jr   .setWarioLstId
.offscreen:
	ld   hl, sMapSyrupCastleCutsceneTimer
	inc  [hl]
	
	xor  a
	ld   [sMapAnimFrame_Misc], a
	ld   [sMapWarioLstId], a
	ret
	
; =============== Map_Ending_DrawOBJ ===============
; Draws the sprite mappings in the second part of the ending.
;
; This also handles the SFX for Mario's helicopter.
Map_Ending_DrawOBJ:
	call Map_Ending_WriteStatueHighOBJLst
	call Map_Ending_WriteStatueLowOBJLst
	ldh  a, [rBGP]	; Has the fade in finished?
	cp   a, $E1
	ret  nz			; If not, don't draw any other sprites
	call Map_Ending_DrawSparkle
	ld   hl, OBJLstPtrTable_Map_Ending_Wario
	call Map_Ending_WriteWarioCustomOBJLst
	
	; Play the SFX for Mario's helicopter
	ld   a, [sMapSyrupCastleCutsceneAct]
	and  a
	ret  z			; These are some of the acts where Mario isn't visible
	cp   a, $08
	ret  z
	cp   a, $0A
	ret  z
	cp   a, $0B
	ret  z
.playSFX:
	ld   a, [sMapTimer_Low]
	and  a, $07
	ret  nz
	ld   a, SFX1_21
	ld   [sSFX1Set], a
	ret
	
; =============== Map_Ending_DrawSparkle ===============
; Prepares the sprite mappings for the sparkle effect around the statue:
; - Cycles through mapping IDs, which simply determine the tile ID to use here
; - Cycles through the different positions (all relative to the statue)
;
; It will then write the sprite mappings for it.
Map_Ending_DrawSparkle:
	ld   a, [sMapEndingSparkleTblIdx]			
	ld   c, a						; C = Index
	
	; Get the Y pos...
	ld   hl, Map_Ending_SparkleYTbl
	call Map_Ending_IndexSparklePos
	ld   a, [sMapEndingStatueHighY] ; ... relative to the statue Y pos
	add  b	
	ld   [sMapEndingSparkleY], a
	
	; Do the same with the Sparkle X pos
	ld   hl, Map_Ending_SparkleXTbl	
	call Map_Ending_IndexSparklePos
	ld   a, [sMapEndingStatueHighX]
	add  b
	ld   [sMapEndingSparkleX], a
	
	; Every $10 frames, use the other mapping frame
	ld   a, [sMapTimer0]	
	and  a, $10
	jr   nz, .frame1
.frame0:
	xor  a
.writeOBJ:
	; Every 8 frames, increase the sparkle pos index
	ld   [sMapEndingSparkleLstId], a
	ld   a, [sMapTimer_Low]	
	and  a, $07
	jr   nz, Map_Ending_WriteSparkleOBJLst
.nextCoords:
	ld   hl, sMapEndingSparkleTblIdx
	inc  [hl]
	ld   a, [sMapEndingSparkleTblIdx]
	
	ld   c, a
	cp   a, $0B				; Have we reached the end of the pos tables?
	jr   z, .reset			; If so, reset the index
	jr   Map_Ending_WriteSparkleOBJLst
.frame1:
	ld   a, $01
	jr   .writeOBJ
	
; Resets the index to the pos. table.
; This also returns without writing the mappings for the sparkle,
; which will remove the OBJ for a single frame.
; (it's not noticeable anyway)
.reset:
	xor  a
	ld   [sMapEndingSparkleTblIdx], a
	ret
	
; =============== Map_Ending_IndexSparklePos ===============
; Indexes the position of a sparkle from the specified table.
;
; IN
; -  C: Index
; - HL: Ptr to position table
;
; OUT
; - B: Indexed value
Map_Ending_IndexSparklePos:
	xor  a
	ld   b, a		; BC = Index
	add  hl, bc
	ld   a, [hl]	; B = PosTable[i]
	ld   b, a
	ret
	
; =============== Sparkle obj base coords ===============
; Tables of Y and X positions for the sparkles.
; These positions are relative to the current coordinates of the statue.
Map_Ending_SparkleYTbl: db $E5,$F8,$F8,$00,$0F,$0C,$09,$1C,$F1,$00,$EB
Map_Ending_SparkleXTbl: db $FA,$F2,$07,$FE,$F5,$07,$FF,$F9,$F3,$11,$0C

; =============== Map_Ending_WriteSparkleOBJLst ===============
Map_Ending_WriteSparkleOBJLst:
	ld   hl, OBJLstPtrTable_Map_Ending_Sparkle
	ld   a, [sMapEndingSparkleY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapEndingSparkleX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapEndingSparkleLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapEndingSparkleFlags]
	ld   [sMapOAMWriteFlags], a
	call Map_WriteOBJLst
	ret
	
; =============== Map_SyrupCastle_DoCutscenes ===============
; Handles all Syrup Castle cutscenes.
Map_SyrupCastle_DoCutscenes:
	; The start of the ending cutscene is handled differently
	ld   a, [sMapSyrupCastleCutscene]
	cp   a, MAP_SCC_ENDING
	jp   z, Map_SyrupCastle_DoEnding
	;--
	; C38 and C39 cutscenes are very similar, and can reuse logic
	ld   a, [sMapSyrupCastleCutsceneAct]
	and  a
	jr   z, .act0	; 1 - Waiting for the explosion effect
	cp   a, $01
	jr   z, .act1	; 2 - Explosion effect with mapsect update
	cp   a, $02
	jr   z, .act2	; 3 - Fade out
	ret ; We never get here
.act0:
	; Setup the wave effect like normal
	ld   a, $01
	ld   [sMapSyrupCastleWaveShift], a
	ld   a, $35
	ld   [sMapSyrupCastleWaveLines], a
	ld   hl, Map_SyrupCastle_WaveTbl
	ld   a, h
	ld   [sMapSyrupCastleWaveTablePtr_High], a
	ld   a, l
	ld   [sMapSyrupCastleWaveTablePtr_Low], a
	call Map_SyrupCastle_DoWaveEffect
	call Map_SyrupCastle_DoPaletteEffect
	; Wait $50 frames before change
	ld   a, [sMapSyrupCastleCutsceneTimer]
	inc  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	cp   a, $50
	ret  nz
	xor  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	ret
;--
.act1:
	; Set screen shake effect
	ld   a, $01
	ld   [sMapShake], a
	; Set the initial coordinates for the explosions. This will mostly stay unchanged during processing.
	; These are not only used for the sprite mappings in slot #0,
	; but also as base coordinates for other explosion mappings.
	;
	; An arbitrary value is often added to these coordinates for slots #1-3.
	ld   a, $68
	ld   [sMapExplOBJ0Y], a
	ld   a, $58
	ld   [sMapExplOBJ0X], a
	call Map_SyrupCastle_DoExplosion
	; Check the patch tilemap to apply to this cutscene
	ld   a, [sMapSyrupCastleCutscene]
	cp   a, MAP_SCC_C39CLEAR
	jr   z, .c39
.c38:
	ld   bc, Ev_Map_C38ClearNoPath_Tiles
	ld   hl, Ev_Map_C38ClearNoPath_Offsets
	jr   .writeEv
.c39:
	ld   bc, Ev_Map_C39ClearNoPath_Tiles
	ld   hl, Ev_Map_C39ClearNoPath_Offsets
	jr   .writeEv
;--
.act2:
	; Set the new "last" completion status from the cutscene we just cleared
	ld   a, [sMapSyrupCastleCutscene]
	cp   a, MAP_SCC_C39CLEAR
	jr   z, .c39Fade
.c38Fade:
	ld   a, $03
.end:
	ld   [sMapSyrupCastleCompletionLast], a
	ld   a, MAP_MODE_FADEOUT
	ld   [sMapId], a
	ld   a, MAP_MODE_INITSYRUPCASTLE
	ld   [sMapNextId], a
	; Show the course clear screen
	ld   a, $01
	ld   [sMapFadeOutRetVal], a
	ret
.c39Fade:
	ld   a, $07
	jr   .end
;--

; IN
; - BC: Ptr to event Tile ID table
; - HL: Ptr to event VRAM offset table
.writeEv:
	; Write a new tile every $10 frames
	ld   a, [sMapTimer_Low]
	and  a, $0F
	ret  nz
	
	; Save the offset table ptr
	ld   a, h
	ld   [sMapEvOffsetTablePtr_High], a
	ld   a, l
	ld   [sMapEvOffsetTablePtr_Low], a
	
	; Index the tile ID table
	ld   de, sMapEvTileId
	xor  a					; HL = sMapEvIndex
	ld   h, a
	ld   a, [sMapEvIndex]	
	ld   l, a
	add  hl, bc				; Index the tile id table
	
	ld   a, [hl]			; Check for the end separator
	cp   a, $FF
	jr   z, .endEvent
	ld   [de], a			; Write the tile
	;--
	; Index the VRAM offsets table
	ld   a, [sMapEvOffsetTablePtr_High]	; HL = VRAM Offsets table ptr
	ld   h, a
	ld   a, [sMapEvOffsetTablePtr_Low]
	ld   l, a
	ld   de, sMapEvBGPtr				; DE = VRAM Ptr
	xor  a
	
	ld   b, a							; BC = EvIndex *2
	ld   a, [sMapEvIndex]
	add  a								
	ld   c, a
	
	add  hl, bc							; Index the VRAM offset table
	ldi  a, [hl]						; Set the high byte of the VRAM ptr
	ld   [de], a
	ld   a, [hl]						; Set the low byte
	inc  de
	ld   [de], a
	
	ld   hl, sMapEvIndex				; index++
	inc  [hl]
	ret
.endEvent:;R
	xor  a
	ld   [sMapEvIndex], a
	ld   [sMapShake], a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	ret
; =============== Map_SyrupCastle_RemovePath ===============
; Workaround for how the Syrup Castle patch tilemaps are setup.
;
; For example, the C38 clear tilemap contains already both the paths and the new castle walls.
; This wouldn't allow the path reveal animation to be seen.
;
; This checks if a cutscene has been played before,
; and if so, it removes the specified paths by applying a specifically crafted event
; containing a partial copy of the old tilemap.

Map_SyrupCastle_RemovePath:
	; Check the current cutscene
	ld   a, [sMapSyrupCastleCutscene]
	and  a								; No cutscene
	ret  z
	cp   a, MAP_SCC_ENDING				; Don't do this in the ending
	ret  z
	cp   a, MAP_SCC_C39CLEAR			; Course 39 Cleared
	jr   z, .c39Clear
.c38Clear:
	ld   bc, Ev_Map_C38ClearOldPath_Tiles
	ld   hl, Ev_Map_C38ClearOldPath_Offsets
	call Map_WriteFullEv_B14
	ld   a, $01								; The map is linear so we can do this
	ld   [sMapSyrupCastleCompletionLast], a
	ld   [sMapLevelClear], a
	ret
.c39Clear:
	ld   bc, Ev_Map_C39ClearOldPath_Tiles
	ld   hl, Ev_Map_C39ClearOldPath_Offsets
	call Map_WriteFullEv_B14
	ld   a, $03
	ld   [sMapSyrupCastleCompletionLast], a
	ld   a, $01
	ld   [sMapLevelClear], a
	ret
; =============== Map_WriteFullEv_B14 ===============
; Writes to the tilemap the entirety of the specified map event data in one go.
; Local copy of Map_WriteFullEv from BANK $08.
;
; IN
; - BC: Ptr to table of tile IDs to use.
; - HL: Ptr to table VRAM ptrs to a tilemap (where to place the aforemented tile ID)
Map_WriteFullEv_B14:
	ld   a, [bc]		; Check for $FF separator
	cp   a, $FF
	ret  z
	ldi  a, [hl]		; DE = VRAM offset
	ld   d, a
	ldi  a, [hl]
	ld   e, a
	ld   a, [bc]		; A = Tile ID
	ld   [de], a		; Copy the tile to the tilemap
	inc  bc
	jr   Map_WriteFullEv_B14
	
; The event data is organized in this specific order
; The "No path" event has no end separator, so it falls back to the "Old path" event.
; When the "No path" is applied in the cutscenes, it will look as if the walls are updated but not the path dots.
; The "old path" is also used separately for the path reveal animation.
Ev_Map_C38ClearNoPath_Tiles:    INCBIN "data/event/syrupcastle_c38_nopath.evt"
Ev_Map_C38ClearOldPath_Tiles:   INCBIN "data/event/syrupcastle_c38_oldpath.evt"
Ev_Map_C38ClearNoPath_Offsets:  INCBIN "data/event/syrupcastle_c38_nopath.evp"
Ev_Map_C38ClearOldPath_Offsets: INCBIN "data/event/syrupcastle_c38_oldpath.evp"
Ev_Map_C39ClearNoPath_Tiles:    INCBIN "data/event/syrupcastle_c39_nopath.evt"
Ev_Map_C39ClearOldPath_Tiles:   INCBIN "data/event/syrupcastle_c39_oldpath.evt"
Ev_Map_C39ClearNoPath_Offsets:  INCBIN "data/event/syrupcastle_c39_nopath.evp"
Ev_Map_C39ClearOldPath_Offsets: INCBIN "data/event/syrupcastle_c39_oldpath.evp"
; =============== Map_Ending_WriteStatueOBJLst ===============
Map_Ending_WriteStatueHighOBJLst:
	ld   a, $10
	ld   [sMapEndingStatueHighFlags], a
	ld   hl, OBJLstPtrTable_Map_Ending_Statue
	ld   a, [sMapEndingStatueHighY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapEndingStatueHighX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapEndingStatueHighLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapEndingStatueHighFlags]
	ld   [sMapOAMWriteFlags], a
Map_Ending_WriteStatueOBJLst:
	call Map_WriteOBJLst
	ret
Map_Ending_WriteStatueLowOBJLst:
	ld   a, $10
	ld   [sMapEndingStatueLowFlags], a
	ld   hl, OBJLstPtrTable_Map_Ending_Statue
	ld   a, [sMapEndingStatueLowY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapEndingStatueLowX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapEndingStatueLowLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapEndingStatueLowFlags]
	ld   [sMapOAMWriteFlags], a
	jr   Map_Ending_WriteStatueOBJLst
	
; =============== Map_SyrupCastle_DoEffects ===============
; Performs the special effects for the Syrup Castle submap.
Map_SyrupCastle_DoEffects:
	; [TCRF] Not possible to trigger here
	ld   a, [sMapSyrupCastleCutscene]
	cp   a, MAP_SCC_ENDING
	jr   z, Map_SyrupCastle_DoEnding
	;--
	ld   hl, Map_SyrupCastle_WaveTbl
	ld   a, h
	ld   [sMapSyrupCastleWaveTablePtr_High], a
	ld   a, l
	ld   [sMapSyrupCastleWaveTablePtr_Low], a
	call Map_SyrupCastle_DoWaveEffect
	;--
	call Map_SyrupCastle_DoPaletteEffect
	ret
	
; =============== Map_SyrupCastle_DoEnding ===============
; Handles the initial part of the ending which takes place in the normal Syrup Castle tilemap.
;
; This is before the screen fades out once from the explosion effect.
Map_SyrupCastle_DoEnding:
	; Base explosion coords setup
	ld   a, $40
	ld   [sMapExplOBJ0Y], a
	ld   a, $58
	ld   [sMapExplOBJ0X], a
	call Map_SyrupCastle_DoExplosion
	
	ld   a, [sMapSyrupCastleCutsceneAct]
	and  a
	jr   z, .act0	; Start screen shake
	cp   a, $01
	jr   z, .act1	; Move Wario down
	cp   a, $02
	jr   z, .act2	; Move Wario right
	cp   a, $03
	jp   z, .act3	; Trigger jump
.act4:
	; Cleanup
	xor  a
	ld   [sMapShake], a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   [sMapSyrupCastleCutsceneAct], a
	; Switch to the other Syrup Castle map mode for the second part of the ending
	ld   a, MAP_MODE_FADEOUT
	ld   [sMapId], a
	ld   a, MAP_MODE_INITENDING2
	ld   [sMapNextId], a
	ret
.act0:
	; Act 0: Perform earthquake effect without drawing Wario
	ld   a, $01
	ld   [sMapShake], a
	ld   a, [sMapSyrupCastleCutsceneTimer]
	inc  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	cp   a, $10
	ret  nz
	ld   a, $42					; Initial Wario pos
	ld   [sMapWarioYRes], a
.nextAct:
	xor  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	ld   hl, sMapSyrupCastleCutsceneAct
	inc  [hl]
	ret
.act1:
	; Act 1: Move Wario downwards for $E frames (until Y $50 is reached)
	call Map_Ending_WriteLampOBJLst
	call HomeCall_Map_WriteWarioOBJLst
	ld   a, [sMapWarioYRes]		; Reached the target?
	cp   a, $50
	jr   z, .nextAct			; If so, jump
	inc  a
	ld   [sMapWarioYRes], a
	ld   [sMapWarioY], a
	ret
.act2:
	; Act 2: Trigger the right move anim
	ld   a, MAP_MWA_RIGHT
	ld   [sMapWarioLstId], a
	ld   a, $30
	ld   [sMapWarioFlags], a
	jr   .nextAct
.act3:
	; Act 3: Move Wario right and jump for $10 frames
	call Map_SyrupCastle_Ending_DoJump
	ld   a, [sMapSyrupCastleCutsceneTimer]
	cp   a, $10
	ret  nz
	
	ld   a, MAP_MWA_FRONT
	ld   [sMapWarioLstId], a
	ld   a, $30
	ld   [sMapWarioFlags], a
	jr   .nextAct
	
; =============== Map_SyrupCastle_Ending_DoJump ===============
; Handles Wario's jump in the first part of the ending cutscene.
Map_SyrupCastle_Ending_DoJump:
	; Update position every 4 frames.
	; This looks very choppy near the end of the jump, but whatever.
	ld   a, [sMapTimer_Low]
	and  a, $03
	jr   nz, .writeOBJ
	; Update Wario's coords
	ld   hl, Map_SyrupCastle_Ending_WarioYOffsetTbl
	ld   de, sMapWarioYRes
	call Map_SyrupCastle_Ending_SetWarioPos
	ld   hl, Map_SyrupCastle_Ending_WarioXOffsetTbl
	ld   de, sMapWarioX
	call Map_SyrupCastle_Ending_SetWarioPos
	; Timer++
	ld   a, [sMapSyrupCastleCutsceneTimer]
	inc  a
	ld   [sMapSyrupCastleCutsceneTimer], a
	; Play the jump SFX?
	cp   a, $02
	jr   z, .playSFX
.writeOBJ:
	call Map_Ending_WriteWarioOBJLst
	call Map_Ending_WriteLampOBJLst
	ret
.playSFX:
	ld   a, SFX1_29
	ld   [sSFX1Set], a
	jr   .writeOBJ
	
; =============== Map_SyrupCastle_Ending_SetWarioPos ===============
; Updates one of Wario's coordinates in the ending based on the timer.
; given a table of positions and an address pointing to a coordinate.
;
; IN
; - HL: Ptr to position offset table.
;       This table contains values which will be added to the address DE points to.
; - DE: Ptr to Wario's coordinate
Map_SyrupCastle_Ending_SetWarioPos:
	; Index the table with the cutscene timer
	xor  a
	ld   b, a
	ld   a, [sMapSyrupCastleCutsceneTimer]
	ld   c, a
	add  hl, bc
	
	ld   a, [hl]	; B = Pos offset
	ld   b, a
	ld   a, [de]	; A = Wario's pos
	add  b			; Set the offset
	ld   [de], a	; Write it back
	ret
	
; =============== Map_SyrupCastle_Ending_Wario?OffsetTbl ===============
; These tables specify the offsets for Wario's coordinates
; during the jump animation in the first part of the ending.
;
; These values are added to the current (X or Y) coordinate.
;
; The table is indexed using an incremental timer, so the order of the entries is important.
Map_SyrupCastle_Ending_WarioYOffsetTbl: 
	db -$06,-$04,-$03,-$03,-$02,-$01,-$01,+$00,+$01,+$02,+$03,+$06,+$0C,+$14,+$0F,+$0F
Map_SyrupCastle_Ending_WarioXOffsetTbl: 
	db +$02,+$02,+$02,+$02,+$02,+$02,+$01,+$01,+$01,+$01,+$02,+$02,+$02,+$02,+$02,+$03

; =============== Map_Ending_WriteLampOBJLst ===============
Map_Ending_WriteLampOBJLst:
	; Generate the Y offset for the lamp...
	; ...for some reason however, it depends off a timer which is essentially random.
	; I have no idea about why it's done like this.
	ld   a, [sMapTimer_Low]
	and  a, $20
	swap a					; The offset is also between $00-$02 px
	ld   b, a				; Which makes it impossible to notice basically
	
	; Add the offset back
	ld   a, [sMapWarioYRes]	
	add  b
	ld   [sMapEndingLampY], a
	
	; Use the same X coordinates as Wario
	ld   a, [sMapWarioX]
	ld   [sMapEndingLampX], a
	jr   .writeOBJ
.writeOBJ:
	ld   a, $10
	ld   [sMapEndingLampFlags], a
	ld   hl, OBJLstPtrTable_Map_Ending_Lamp
	ld   a, [sMapEndingLampY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapEndingLampX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapEndingLampLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapEndingLampFlags]
	ld   [sMapOAMWriteFlags], a
Map_Ending_WriteOBJLst2:
	call Map_WriteOBJLst
	ret
; =============== Map_Ending_WriteWarioOBJLst ===============
; Writes Wario's sprite mappings in the ending.
; The first set reuses the normal mappings, while the second set
; is expected to point to the extra mappings specific to the ending.
Map_Ending_WriteWarioOBJLst:
	ld   hl, OBJLstPtrTable_MapWario
Map_Ending_WriteWarioCustomOBJLst:
	ld   a, [sMapWarioYRes]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapWarioX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapWarioLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapWarioFlags]
	ld   [sMapOAMWriteFlags], a
	jr   Map_Ending_WriteOBJLst2
	
; =============== Map_SyrupCastle_WaveTbl ===============
; Base rSCX offset table for the wave effect in Syrup Castle.
; $10 consecutive values can be used at once,
; given a starting index with range 0-$F.
;
; An optional multiplier can be applied to these values,
; though it's always set to 1 (therefore rendering this feature not used).
Map_SyrupCastle_WaveTbl: 
	db $00,$00,$01,$01,$01,$01,$01,$01,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF
	db $00,$00,$01,$01,$01,$01,$01,$01,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF

; [TCRF] Unused wave table, with more pronounced effects.
; This being unused renders the multiple wave table functionality mostly useless.
Map_Unused_SyrupCastle_WaveTbl:
	db $00,$05,$08,$09,$09,$09,$08,$05,$00,$FB,$F8,$F7,$F7,$F7,$F8,$FB
	db $00,$05,$08,$09,$09,$09,$08,$05,$00,$FB,$F8,$F7,$F7,$F7,$F8,$FB

; =============== Map_SyrupCastle_DoWaveEffect ===============
; Performs the wave effect on Syrup Castle.
; Because it needs to wait for rLY, this will take a significant amount of processing time.
;
; [BUG] This expects to be called when rLY = 0, but the sound engine can cause delays.
;
; The game does not account for this and it will still process the same amount of lines,
; which will apply the effect to unintended areas.
; This can be seen with the part of the map near the waterline occasionally shifting.
;
; To fix this bug, rLY should be subtracted from the number of lines at the beginning of the function.

Map_SyrupCastle_DoWaveEffect:

IF FIX_BUGS == 1
	ldh  a, [rLY]						; C = LY elapsed
	cp   a, $80							; < 0?
	jr   nc, Map_SyrupCastle_DoWaveEffect	; If so, wait since we're still in VBlank
	ld   c, a
	ld   a, [sMapSyrupCastleWaveLines]	; B = Number of lines to perform the effect
	sub  c								; LineCount -= LY
ELSE
	ld   a, [sMapSyrupCastleWaveLines]	; B = Number of lines to perform the effect
ENDC
	ld   b, a
.loop:
	
	mWaitForHBlank
	
	; Calculate the *scanline-based* table index for this specific row.
	; DE = rLY % $F
	;      TIMER  TableSize
	;
	; Because this is tied to rLY, it will increase by one when it processes a new line.
	; As the values in the table are in a specific pattern, this will cause a wave-like scrolling effect.
	;
	; The indexes also loop every 16 values.
	ldh  a, [rLY]
	and  a, $0F
	ld   e, a
	ld   d, $00
	; HL = Base offset for the wave effect table.
	;      It can be set to different values, but only Map_SyrupCastle_WaveTbl is used.
	ld   a, [sMapSyrupCastleWaveTablePtr_High]
	ld   h, a
	ld   a, [sMapSyrupCastleWaveTablePtr_Low]
	ld   l, a
	add  hl, de ; Index the wave table
	
	; C = Shift amount (offset multiplier)
	ld   a, [sMapSyrupCastleWaveShift]
	ld   c, a
	
	; Calculate the *timer-based* index.
	; DE = Timer >> 2
	;
	; It's used to pick the initial index to the wave table.
	; Because this depends on the timer (albeit >> 2'd to use a slower speed),
	; this will result in the waves appearing to move upwards.
	;
	; With this and the current index above, the current wave entry to use can be calculated as:
	; Offset = WaveTable[((Timer & $3C) >> 2) + rowVal]
	;
	; With "rowVal" changing on each scanline, and the Timer changing outside this subroutine.
	ld   a, [sMapTimer_Low]
	and  a, $3C
	srl  a
	srl  a
	ld   e, a
	ld   d, $00		; DE = (Timer & $3C) >> 2
	add  hl, de
	ld   a, [hl]	; Get the base offset
	
	; [TCRF] Unused offset multiplier feature.
	;      	 A = Offset << (Multiplier - 1)
	;        However the multiplier is always set to 1.
.shiftLoop:
	dec  c			
	jr   z, .shiftDone
	sla  a					
	jr   .shiftLoop
;--

.shiftDone:
	; Set the offset to the X Scroll register
	ldh  [rSCX], a
	dec  b					; Have we processed all the lines?
	jr   nz, .loop			; If not, loop
	
	; Wait for HBlank one last time, to reset the scroll offset back to normal
	mWaitForHBlank
	
	xor  a				; Reset X Scroll
	ldh  [rSCX], a
	ret
	
; =============== Map_SyrupCastle_DoExplosion ===============
; Handles the sprite mappings for explosions in the Syrup Castle cutscenes.
;
; This processes 4 possible sprite mappings.
Map_SyrupCastle_DoExplosion:
	call Map_SyrupCastle_DrawExplosion0
	call Map_SyrupCastle_DrawExplosion1
	call Map_SyrupCastle_DrawExplosion2
	; Play SFX every 8 frames
	ld   a, [sMapTimer_Low]
	and  a, $07
	ret  nz
	ld   a, SFX4_04
	ld   [sSFX4Set], a
	ret
; =============== Map_SyrupCastle_DrawExplosion1 ===============
; Picks different sprite mapping ID and coordinates for the
; explosions depending on the timer.
;
; This can update the mapping slots #1, #2 and #3.
Map_SyrupCastle_DrawExplosion1:
	; Same timer randomization code as Map_WriteExplosionMappings0,
	; except the main timer is offset by $10.
	ld   a, [sMapTimer0]
	add  $10				
	and  a, $38
	
	; Because of this, the "do nothing" condition is also offset.
	; If it weren't the case, the mappings defs specified here would have always overridden the first one.
	bit  5, a
	ret  nz
	
	; Determine the mapping combination to write
	cp   a, $18
	jr   z, .writeSet0b
	sla  a
	swap a
	
	ld   [sMap_Unused_ExplTimer], a ; [TCRF] This value is only written to. Here it stores the calculated set ID.
	
	cp   a, $01
	jr   z, .writeSet1
	cp   a, $02
	jr   z, .writeSet2
	
.writeSet0:
	ld   [sMapExplOBJ3LstId], a
	ld   a, [sMapExplOBJ0Y]
	add  $08
	ld   [sMapExplOBJ3Y], a
	ld   a, [sMapExplOBJ0X]
	add  $28
	ld   [sMapExplOBJ3X], a
	ld   a, $10
	ld   [sMapExplOBJ3Flags], a
	call Map_WriteExplOBJLst3
	ret
.writeSet0b:
	xor  a
	jr   .writeSet0
	
.writeSet1:
	ld   a, [sMapExplOBJ0Y]
	add  $1C
	ld   [sMapExplOBJ1Y], a
	ld   a, [sMapExplOBJ0X]
	sub  a, $20
	ld   [sMapExplOBJ1X], a
	ld   a, $04
	ld   [sMapExplOBJ1LstId], a
	ld   a, $10
	ld   [sMapExplOBJ1Flags], a
	call Map_WriteExplOBJLst1
	ld   a, [sMapExplOBJ0Y]
	sub  a, $3C
	ld   [sMapExplOBJ2Y], a
	ld   a, [sMapExplOBJ0X]
	sub  a, $1C
	ld   [sMapExplOBJ2X], a
	ld   a, $04
	ld   [sMapExplOBJ2LstId], a
	ld   a, $50
	ld   [sMapExplOBJ2Flags], a
	call Map_WriteExplOBJLst2
	ld   a, $01
	jr   .writeSet0
	
.writeSet2:
	ld   a, [sMapExplOBJ0Y]
	sub  a, $30
	ld   [sMapExplOBJ1Y], a
	ld   a, [sMapExplOBJ0X]
	add  $1C
	ld   [sMapExplOBJ1X], a
	ld   a, $04
	ld   [sMapExplOBJ1LstId], a
	ld   a, $70
	ld   [sMapExplOBJ1Flags], a
	call Map_WriteExplOBJLst1
	ld   a, [sMapExplOBJ0Y]
	add  $14
	ld   [sMapExplOBJ2Y], a
	ld   a, [sMapExplOBJ0X]
	add  $18
	ld   [sMapExplOBJ2X], a
	ld   a, $04
	ld   [sMapExplOBJ2LstId], a
	ld   a, $30
	ld   [sMapExplOBJ2Flags], a
	jp   Map_WriteExplOBJLst2
	
; =============== Map_SyrupCastle_DrawExplosion0 ===============
; Picks different sprite mapping ID and coordinates for the
; explosions depending on the timer.
;
; This can update the mapping slots #0, #1 and #2.
Map_SyrupCastle_DrawExplosion0:
	; Randomize the mapping combination
	ld   a, [sMapTimer0]
	and  a, $38				; Filter possible values in range ($0,$7) << 3
	bit  5, a				; Skip entirely when the highest bit is set (on alternating $10 frames(+$10))
	ret  nz
	
	; This leaves possible values $0, $8, $10, $18
	cp   a, $18
	jr   z, .writeSet0b		; The highest value will use #0
	
	; Result >> 3, essentially giving possible values 0, 1 and 2
	sla  a					
	swap a
	
	cp   a, $01
	jr   z, .writeSet1
	cp   a, $02
	jr   z, .writeSet2
.writeSet0:
	ld   [sMapExplOBJ0LstId], a
	ld   a, $10
	ld   [sMapExplOBJ0Flags], a
	call Map_WriteExplOBJLst0
	ret
.writeSet0b:
	xor  a
	jr   .writeSet0
	
.writeSet1:
	ld   a, [sMapExplOBJ0Y]
	sub  a, $38
	ld   [sMapExplOBJ1Y], a
	ld   a, [sMapExplOBJ0X]
	ld   [sMapExplOBJ1X], a
	ld   [sMapExplOBJ2X], a
	ld   a, $03
	ld   [sMapExplOBJ1LstId], a
	ld   [sMapExplOBJ2LstId], a
	ld   a, $50
	ld   [sMapExplOBJ1Flags], a
	call Map_WriteExplOBJLst1
	ld   a, [sMapExplOBJ0Y]
	add  $20
	ld   [sMapExplOBJ2Y], a
	ld   a, $10
	ld   [sMapExplOBJ2Flags], a
	call Map_WriteExplOBJLst2
	ld   a, $01
	jr   .writeSet0
	
.writeSet2:
	ld   a, [sMapExplOBJ0Y]
	ld   [sMapExplOBJ1Y], a
	ld   [sMapExplOBJ2Y], a
	ld   a, [sMapExplOBJ0X]
	sub  a, $20
	ld   [sMapExplOBJ1X], a
	ld   a, $02
	ld   [sMapExplOBJ1LstId], a
	ld   [sMapExplOBJ2LstId], a
	ld   a, $10
	ld   [sMapExplOBJ1Flags], a
	call Map_WriteExplOBJLst1
	ld   a, [sMapExplOBJ0X]
	add  $28
	ld   [sMapExplOBJ2X], a
	ld   a, $30
	ld   [sMapExplOBJ2Flags], a
	jp   Map_WriteExplOBJLst2
	
; =============== Map_SyrupCastle_DrawExplosion2 ===============
; This will add extra / replace existing sprite mappings to add variation
; to the explosion effect in Set #0.1
Map_SyrupCastle_DrawExplosion2:
	;--
	; This covers the case when the offset bit 5 is non-zero,
	; which is only the case in Map_SyrupCastle_DrawExplosion0 ...
	ld   a, [sMapTimer0]
	add  $10
	and  a, $38
	bit  5, a
	ret  z
	; Only enable this mappings shift effect for set #1
	; which is when bit 4 is non-zero
	bit  4, a
	ret  z
	;--
.ok:
	ld   a, [sMapTimer0]
	ld   [sMap_Unused_ExplTimer], a
	
	; [TCRF] This would alternate between mapping IDs every 8 frames
	and  a, $08
	srl  a
	srl  a
	srl  a
	and  a, $01
	; ...but .useAlt sets the same mapping IDs as .useNormal!
	jr   nz, .useAlt
.useNormal:
	ld   [sMapExplOBJ3LstId], a
	ld   [sMapExplOBJ2LstId], a
	xor  $01
	ld   [sMapExplOBJ1LstId], a
	ld   [sMapExplOBJ0LstId], a
.write:
	ld   a, [sMapExplOBJ0Y]
	add  $08
	ld   [sMapExplOBJ1Y], a
	ld   a, [sMapExplOBJ0Y]
	add  $14
	ld   [sMapExplOBJ2Y], a
	ld   a, [sMapExplOBJ0Y]
	sub  a, $0A
	ld   [sMapExplOBJ3Y], a
	ld   a, [sMapExplOBJ0Y]
	add  $12
	ld   [sMapExplOBJ0Y], a
	ld   a, [sMapExplOBJ0X]
	add  $10
	ld   [sMapExplOBJ1X], a
	ld   a, [sMapExplOBJ0X]
	sub  a, $08
	ld   [sMapExplOBJ2X], a
	ld   a, [sMapExplOBJ0X]
	add  $0C
	ld   [sMapExplOBJ3X], a
	ld   a, [sMapExplOBJ0X]
	add  $20
	ld   [sMapExplOBJ0X], a
	ld   a, $10
	ld   [sMapExplOBJ0Flags], a
	ld   [sMapExplOBJ1Flags], a
	ld   [sMapExplOBJ2Flags], a
	ld   [sMapExplOBJ3Flags], a
	call Map_WriteExplOBJLst0
	call Map_WriteExplOBJLst1
	call Map_WriteExplOBJLst2
	jp   Map_WriteExplOBJLst3
.useAlt:
	ld   [sMapExplOBJ2LstId], a
	ld   [sMapExplOBJ3LstId], a
	xor  $01
	ld   [sMapExplOBJ0LstId], a
	ld   [sMapExplOBJ1LstId], a
	jr   .write
	
	
; =============== Map_WriteExplOBJLst? ===============	
; Writes the OBJ list for the explosions seen in Syrup Castle cutscenes.
Map_WriteExplOBJLst0:
	ld   hl, OBJLstPtrTable_Map_SyrupCastle_Expl
Map_Ending_WriteOBJLst:
	ld   a, [sMapExplOBJ0Y]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapExplOBJ0X]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapExplOBJ0LstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapExplOBJ0Flags]
	ld   [sMapOAMWriteFlags], a
Map_WriteExplOBJLst:
	call Map_WriteOBJLst
	ret
Map_WriteExplOBJLst1:
	ld   hl, OBJLstPtrTable_Map_SyrupCastle_Expl
	ld   a, [sMapExplOBJ1Y]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapExplOBJ1X]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapExplOBJ1LstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapExplOBJ1Flags]
	ld   [sMapOAMWriteFlags], a
	jr   Map_WriteExplOBJLst
Map_WriteExplOBJLst2:
	ld   hl, OBJLstPtrTable_Map_SyrupCastle_Expl
	ld   a, [sMapExplOBJ2Y]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapExplOBJ2X]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapExplOBJ2LstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapExplOBJ2Flags]
	ld   [sMapOAMWriteFlags], a
	jr   Map_WriteExplOBJLst
Map_WriteExplOBJLst3:
	ld   hl, OBJLstPtrTable_Map_SyrupCastle_Expl
	ld   a, [sMapExplOBJ3Y]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapExplOBJ3X]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapExplOBJ3LstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapExplOBJ3Flags]
	ld   [sMapOAMWriteFlags], a
	jr   Map_WriteExplOBJLst
	
; =============== Map_SyrupCastle_DoPaletteEffect ===============	
; Performs the palette inversion effect in Syrup Castle.
Map_SyrupCastle_DoPaletteEffect:
	; In level clear mode set the palette back to normal
	ld   a, [sMapEvIndex]
	and  a
	jr   nz, .normal
	ld   a, [sMapLevelClear]
	and  a
	jr   nz, .normal
	
	; When following a path or for alternating 512 frames(+512)
	; set the palette back to normal with a slight delay
	ld   a, [sMapInPath]
	and  a
	jr   nz, .normalDelay
	ld   a, [sMapTimer_High]
	and  a, $02
	jr   nz, .normalDelay
	
	; If the low byte of the timer is between 224 and 255
	; or for alternating 7 frames(+0) don't do anything.
	; The first one is responsible for occasionally causing the palette
	; effect to stick around longer.
	ld   a, [sMapTimer_Low]
	and  a, $F0
	sub  a, $E0
	ret  c
	ld   a, [sMapTimer_Low]
	and  a, $07
	ret  nz
	
	; If we got here, reverse the palette effect
	ld   a, [sMapSyrupCastleInvertPal]
	xor  $01			; Is the inverted palette enabled?
	jr   z, .normal		; If so, disable it
	
.inverted:
	ld   a, $1E
	ldh  [rBGP], a
	ld   a, $E3
	ldh  [rOBP0], a
	ld   a, $01
	ld   [sMapSyrupCastleInvertPal], a
	ret
.normalDelay:
	; Very slight delay at best before setting the palette back to normal
	ld   a, [sMapTimer_Low]
	and  a, $03
	ret  nz
.normal:
	ld   a, $E1
	ldh  [rBGP], a
	ld   a, $1C
	ldh  [rOBP0], a
	xor  a
	ld   [sMapSyrupCastleInvertPal], a
	ret
	
; =============== OBJLstPtrTable_Map_SyrupCastle_Expl ===============
OBJLstPtrTable_Map_SyrupCastle_Expl:
	dw OBJLst_Map_SyrupCastle_Expl0
	dw OBJLst_Map_SyrupCastle_Expl1
	dw OBJLst_Map_SyrupCastle_Expl2
	dw OBJLst_Map_SyrupCastle_Expl3
	dw OBJLst_Map_SyrupCastle_Expl4

OBJLst_Map_SyrupCastle_Expl0: INCBIN "data/objlst/map/syrupcastle_expl0.bin"
OBJLst_Map_SyrupCastle_Expl1: INCBIN "data/objlst/map/syrupcastle_expl1.bin"
OBJLst_Map_SyrupCastle_Expl2: INCBIN "data/objlst/map/syrupcastle_expl2.bin"
OBJLst_Map_SyrupCastle_Expl3: INCBIN "data/objlst/map/syrupcastle_expl3.bin"
OBJLst_Map_SyrupCastle_Expl4: INCBIN "data/objlst/map/syrupcastle_expl4.bin"

; =============== OBJLstPtrTable_Map_Ending_Statue ===============
; Sprite mappings for the Peach statue shown in the ending.
; Inexplicably split in two different halves
OBJLstPtrTable_Map_Ending_Statue:
	dw OBJLst_Map_Ending_Statue0
	dw OBJLst_Map_Ending_Statue1

OBJLst_Map_Ending_Statue0: INCBIN "data/objlst/map/ending_statue0.bin"
OBJLst_Map_Ending_Statue1: INCBIN "data/objlst/map/ending_statue1.bin"

; =============== OBJLstPtrTable_Map_Ending_Lamp ===============
OBJLstPtrTable_Map_Ending_Lamp:
	dw OBJLst_Map_Ending_Lamp
	
OBJLst_Map_Ending_Lamp: INCBIN "data/objlst/map/ending_lamp.bin"

; =============== OBJLstPtrTable_Map_Ending_Sparkle ===============
OBJLstPtrTable_Map_Ending_Sparkle:
	dw OBJLst_Map_Ending_Sparkle0
	dw OBJLst_Map_Ending_Sparkle1

OBJLst_Map_Ending_Sparkle0: INCBIN "data/objlst/map/ending_sparkle0.bin"
OBJLst_Map_Ending_Sparkle1: INCBIN "data/objlst/map/ending_sparkle1.bin"

; =============== OBJLstPtrTable_Map_Ending_Wario ===============
OBJLstPtrTable_Map_Ending_Wario:
	dw OBJLst_Map_Ending_Wario_Back
	dw OBJLst_Map_Ending_Wario_Left
	dw OBJLst_Map_Ending_Wario_Right
	dw OBJLst_Map_Ending_Wario_Jump
	dw OBJLst_Map_Ending_Wario_Shrug
	dw OBJLst_Map_Ending_Wario_Front

OBJLst_Map_Ending_Wario_Back: INCBIN "data/objlst/map/ending_wario_back.bin"
OBJLst_Map_Ending_Wario_Left: INCBIN "data/objlst/map/ending_wario_left.bin"
OBJLst_Map_Ending_Wario_Right: INCBIN "data/objlst/map/ending_wario_right.bin"
OBJLst_Map_Ending_Wario_Jump: INCBIN "data/objlst/map/ending_wario_jump.bin"
OBJLst_Map_Ending_Wario_Shrug: INCBIN "data/objlst/map/ending_wario_shrug.bin"
OBJLst_Map_Ending_Wario_Front: INCBIN "data/objlst/map/ending_wario_front.bin"

; =============== OBJLstPtrTable_Map_Ending_Heli ===============
OBJLstPtrTable_Map_Ending_Heli: 
	dw OBJLst_Map_Ending_Heli0
	dw OBJLst_Map_Ending_Heli1
	dw OBJLst_Map_Ending_HeliSmall0
	dw OBJLst_Map_Ending_HeliSmall1
	dw OBJLst_Map_Ending_HeliHello0
	dw OBJLst_Map_Ending_HeliHello1
OBJLst_Map_Ending_Heli0:      INCBIN "data/objlst/map/ending_heli0.bin"
OBJLst_Map_Ending_Heli1:      INCBIN "data/objlst/map/ending_heli1.bin"
OBJLst_Map_Ending_HeliSmall0: INCBIN "data/objlst/map/ending_helismall0.bin"
OBJLst_Map_Ending_HeliSmall1: INCBIN "data/objlst/map/ending_helismall1.bin"
OBJLst_Map_Ending_HeliHello0: INCBIN "data/objlst/map/ending_helihello0.bin"
OBJLst_Map_Ending_HeliHello1: INCBIN "data/objlst/map/ending_helihello1.bin"

; =============== Map_Unused_ReplaceBGMap ===============
; [TCRF] Weird unreferenced code.
;
; This copies data which fills the entire BGMap from SRAM/WRAM.
; It expects a weird source data organization, where for every $100 bytes between $B000 and $D000,
; the first $20 bytes (aka 1 row of tiles) is tilemap data.
Map_Unused_ReplaceBGMap:
	ld   hl, $B000			; HL = Ptr to source
	ld   bc, BGMap_Begin	; BC = Ptr to destination
	ld   de, $2020			; D = tiles to copy (1 row) on each iteration
	
.loop:
	; Copy the bytes $00-$20 from HL to the tilemap row.
	;--
	ldi  a, [hl]			; Copy the byte
	ld   [bc], a			
	inc  bc
	dec  d
	jr   nz, .loop
	
	; Setup the next bytes $00-$20
	ld   a, $20				; Copy next $20
	ld   d, a
	xor  a					; HL += $E0
	ld   l, a
	inc  h					
	ld   a, h
	cp   $D0				; Have we reached $D000 yet?
	jr   nz, .loop			; If not, loop
	ret
	
; =============== OBJLstAnim_OverworldFlags ===============
; Determines the sequence of OBJLst IDs to use to animate a "world clear" flag. 
OBJLstAnim_OverworldFlags: 
	db $00
	db $01
	db $02
OBJLstAnim_OverworldFlags_End:
	db $FF
; =============== Map_Overworld_AnimFlags ===============
; Animates all "world clear" flags in the overworld.
Map_Overworld_AnimFlags:
	; Each submap gets its own subroutine.
	; All of these follow the same template.
	call .riceBeach
	call .mtTeapot
	call .stoveCanyon
	call .ssTeacup
	call .parsleyWoods
	call .sherbetLand
	call .syrupCastle
	ret
	
.riceBeach:
	ld   a, [sMapRiceBeachCompletion]	
	bit  5, a							; Is the world marked as completed?
	ret  z								; If not, return
	
	call Map_RiceBeach_UpdateFlagCoords
	ld   hl, OBJLstAnim_OverworldFlags
	ld   de, sMapRiceBeachFlagTimer
	ld   bc, sMapRiceBeachFlagLstId
	call Map_SetFlagOBJLstId
	call Map_RiceBeach_WriteFlagOBJLst
	ret
.mtTeapot:
	ld   a, [sMapMtTeapotCompletion]
	bit  7, a
	ret  z
	call Map_MtTeapot_UpdateFlagCoords
	ld   de, sMapMtTeapotFlagTimer
	ld   hl, OBJLstAnim_OverworldFlags
	ld   bc, sMapMtTeapotFlagLstId
	call Map_SetFlagOBJLstId
	call Map_MtTeapot_WriteFlagOBJLst
	ret
.stoveCanyon:
	ld   a, [sMapStoveCanyonCompletion]
	bit  6, a
	ret  z
	call Map_StoveCanyon_UpdateFlagCoords
	ld   de, sMapStoveCanyonFlagTimer
	ld   hl, OBJLstAnim_OverworldFlags
	ld   bc, sMapStoveCanyonFlagLstId
	call Map_SetFlagOBJLstId
	call Map_StoveCanyon_WriteFlagOBJLst
	ret
.ssTeacup:
	ld   a, [sMapSSTeacupCompletion]
	bit  4, a
	ret  z
	call Map_SSTeacup_UpdateFlagCoords
	ld   de, sMapSSTeacupFlagTimer
	ld   hl, OBJLstAnim_OverworldFlags
	ld   bc, sMapSSTeacupFlagLstId
	call Map_SetFlagOBJLstId
	call Map_SSTeacup_WriteFlagOBJLst
	ret
.parsleyWoods:
	ld   a, [sMapParsleyWoodsCompletion]
	bit  5, a
	ret  z
	call Map_ParsleyWoods_UpdateFlagCoords
	ld   de, sMapParsleyWoodsFlagTimer
	ld   hl, OBJLstAnim_OverworldFlags
	ld   bc, sMapParsleyWoodsFlagLstId
	call Map_SetFlagOBJLstId
	call Map_ParsleyWoods_WriteFlagOBJLst
	ret
.sherbetLand:
	ld   a, [sMapSherbetLandCompletion]
	bit  7, a
	ret  z
	call Map_SherbetLand_UpdateFlagCoords
	ld   de, sMapSherbetLandFlagTimer
	ld   hl, OBJLstAnim_OverworldFlags
	ld   bc, sMapSherbetLandFlagLstId
	call Map_SetFlagOBJLstId
	call Map_SherbetLand_WriteFlagOBJLst
	ret
.syrupCastle:
	; [TCRF] This bit is never set, so the rest and all associated subroutines are never called
	ld   a, [sMapSyrupCastleCompletion]
	bit  3, a
	ret  z
	
	call Map_Unused_SyrupCastle_UpdateFlagCoords
	ld   de, sMap_Unused_SyrupCastleFlagTimer
	ld   hl, OBJLstAnim_OverworldFlags
	ld   bc, sMap_Unused_SyrupCastleFlagLstId
	call Map_SetFlagOBJLstId
	call Map_Unused_SyrupCastle_WriteFlagOBJLst
	ret
	
; =============== Map_RiceBeach_UpdateFlagCoords ===============
; Sets of subroutines to update the relative coordinates of a specific flag.
;
; Each subroutine follows the same template, as seen in the next macro.
; IN:
; - 1: Starting pointer to flag coord data
;
mMap_UpdateFlagCoords: MACRO
	; Flag coord data is always made of 4 consecutive values.
	; sMap?FlagY
	; sMap?FlagScrollYLast                   
	; sMap?FlagScrollXLast                      
	; sMap?FlagX  

	; Update Y
	ld   hl, sMapScrollY							; HL = Current Map Scroll coordinate
	ld   bc, \1+1 ;sMapRiceBeachFlagScrollYLast		; BC = Previous Map Scroll coordinate (local copy for flag)
	ld   de, \1   ;sMapRiceBeachFlagY				; DE = Flag coordinate (to update)
	call Map_UpdateOBJRelCoord
	; Update X
	ld   hl, sMapScrollX
	ld   bc, \1+2 ;sMapRiceBeachFlagScrollXLast
	ld   de, \1+3 ;sMapRiceBeachFlagX
	call Map_UpdateOBJRelCoord
	; Update the previous scroll coordinate to match
	ld   a, [sMapScrollY]
	ld   [\1+1], a ; sMapRiceBeachFlagScrollYLast
	ld   a, [sMapScrollX]
	ld   [\1+2], a ; sMapRiceBeachFlagScrollXLast
	ret
ENDM


Map_RiceBeach_UpdateFlagCoords: mMap_UpdateFlagCoords sMapRiceBeachFlagY
Map_MtTeapot_UpdateFlagCoords: mMap_UpdateFlagCoords sMapMtTeapotFlagY
Map_StoveCanyon_UpdateFlagCoords: mMap_UpdateFlagCoords sMapStoveCanyonFlagY
Map_SSTeacup_UpdateFlagCoords: mMap_UpdateFlagCoords sMapSSTeacupFlagY
Map_ParsleyWoods_UpdateFlagCoords: mMap_UpdateFlagCoords sMapParsleyWoodsFlagY
Map_SherbetLand_UpdateFlagCoords: mMap_UpdateFlagCoords sMapSherbetLandFlagY
; [TCRF] Syrup Castle never has a flag, so this goes unused
Map_Unused_SyrupCastle_UpdateFlagCoords: mMap_UpdateFlagCoords sMap_Unused_SyrupCastleFlagY

; =============== Map_InitWorldClearFlags ===============
; Initializes the coordinates and OBJLst for all "world clear flags" in the overworld.
Map_InitWorldClearFlags:
	; Rice Beach
	ld   a, $E0
	ld   hl, sMapScrollY
	sub  a, [hl]
	ld   [sMapRiceBeachFlagY], a
	ld   a, [hl]
	ld   [sMapRiceBeachFlagScrollYLast], a
	ld   a, $46
	ld   hl, sMapScrollX
	sub  a, [hl]
	ld   [sMapRiceBeachFlagX], a
	ld   a, [hl]
	ld   [sMapRiceBeachFlagScrollXLast], a
	ld   a, $00
	ld   [sMapRiceBeachFlagLstId], a
	
	; Mt. Teapot
	ld   a, $01
	ld   [sMapMtTeapotFlagTimer], a
	ld   a, $70
	ld   hl, sMapScrollY
	sub  a, [hl]
	ld   [sMapMtTeapotFlagY], a
	ld   a, [hl]
	ld   [sMapMtTeapotFlagScrollYLast], a
	ld   a, $38
	ld   hl, sMapScrollX
	sub  a, [hl]
	ld   [sMapMtTeapotFlagX], a
	ld   a, [hl]
	ld   [sMapMtTeapotFlagScrollXLast], a
	ld   a, $01
	ld   [sMapMtTeapotFlagLstId], a
	
	; Stove Canyon
	ld   a, $AC
	ld   hl, sMapScrollY
	sub  a, [hl]
	ld   [sMapStoveCanyonFlagY], a
	ld   a, [hl]
	ld   [sMapStoveCanyonFlagScrollYLast], a
	ld   a, $82
	ld   hl, sMapScrollX
	sub  a, [hl]
	ld   [sMapStoveCanyonFlagX], a
	ld   a, [hl]
	ld   [sMapStoveCanyonFlagScrollXLast], a
	ld   a, $00
	ld   [sMapStoveCanyonFlagLstId], a
	
	; SS Teacup
	ld   a, $02
	ld   [sMapSSTeacupFlagTimer], a
	ld   a, $FC
	ld   hl, sMapScrollY
	sub  a, [hl]
	ld   [sMapSSTeacupFlagY], a
	ld   a, [hl]
	ld   [sMapSSTeacupFlagScrollYLast], a
	ld   a, $AC
	ld   hl, sMapScrollX
	sub  a, [hl]
	ld   [sMapSSTeacupFlagX], a
	ld   a, [hl]
	ld   [sMapSSTeacupFlagScrollXLast], a
	ld   a, $02
	ld   [sMapSSTeacupFlagLstId], a
	
	; Parsley Woods
	ld   a, $01
	ld   [sMapParsleyWoodsFlagTimer], a
	ld   a, $92
	ld   hl, sMapScrollY
	sub  a, [hl]
	ld   [sMapParsleyWoodsFlagY], a
	ld   a, [hl]
	ld   [sMapParsleyWoodsFlagScrollYLast], a
	ld   a, $EA
	ld   hl, sMapScrollX
	sub  a, [hl]
	ld   [sMapParsleyWoodsFlagX], a
	ld   a, [hl]
	ld   [sMapParsleyWoodsFlagScrollXLast], a
	ld   a, $00
	ld   [sMapParsleyWoodsFlagLstId], a
	
	; Sherbet Land
	ld   a, $02
	ld   [sMapSherbetLandFlagTimer], a
	ld   a, $30
	ld   hl, sMapScrollY
	sub  a, [hl]
	ld   [sMapSherbetLandFlagY], a
	ld   a, [hl]
	ld   [sMapSherbetLandFlagScrollYLast], a
	ld   a, $26
	ld   hl, sMapScrollX
	sub  a, [hl]
	ld   [sMapSherbetLandFlagX], a
	ld   a, [hl]
	ld   [sMapSherbetLandFlagScrollXLast], a
	ld   a, $00
	ld   [sMapSherbetLandFlagLstId], a
	
	; [TCRF] Syrup Castle (unseen normally)
	ld   a, $20
	ld   hl, sMapScrollY
	sub  a, [hl]
	ld   [sMap_Unused_SyrupCastleFlagY], a
	ld   a, [hl]
	ld   [sMap_Unused_SyrupCastleFlagScrollYLast], a
	ld   a, $C8
	ld   hl, sMapScrollX
	sub  a, [hl]
	ld   [sMap_Unused_SyrupCastleFlagX], a
	ld   a, [hl]
	ld   [sMap_Unused_SyrupCastleFlagScrollXLast], a
	ld   a, $00
	ld   [sMap_Unused_SyrupCastleFlagLstId], a
	ret
	
; =============== Map_OverworldWriteOBJLst ===============
; Writes the specified OBJLst data in the overworld.
; (this includes: Mt.Teapot's lid, the world clear flags, ...).
; Since the overworld is the only map screen that can scroll, 
; this also performs an off-screen check, to avoid rendering off-screen sprites.
;
; IN
; - HL: Ptr to OBJLst table
; - BC: Ptr to Y position
; - DE: Ptr to X position
Map_OverworldWriteOBJLst:
	; As the coordinates are relative to the screen, we can easily
	; perform an off-screen check
	ld   a, [bc]		; Is the Y position > $B0?
	ld   b, a
	ld   a, $B0			; ($B0 - YPos < 0?)
	sub  a, b
	ret  c				; If so, return
	ld   a, [de]		; Is the X position > $B0
	ld   b, a
	ld   a, $B0
	sub  a, b
	ret  c				; If so, return
	call Map_WriteOBJLst
	ret
; =============== Map_RiceBeach_WriteFlagOBJLst ===============
; Prepares the call to Map_WriteOBJLst for writing the flag OBJLst to OAM.
; One exists for every overworld location.
;
Map_RiceBeach_WriteFlagOBJLst:
	ld   a, $10
	ld   [sMapOverworldFlagFlags], a
	ld   hl, OBJLstPtrTable_Map_Overworld_Flag
	ld   a, [sMapRiceBeachFlagY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapRiceBeachFlagX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapRiceBeachFlagLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapOverworldFlagFlags]
	ld   [sMapOAMWriteFlags], a
	ld   bc, sMapRiceBeachFlagY
	ld   de, sMapRiceBeachFlagX
Map_WriteFlagOBJLst:
	jr   Map_OverworldWriteOBJLst
Map_MtTeapot_WriteFlagOBJLst:
	ld   a, $10
	ld   [sMapOverworldFlagFlags], a
	ld   hl, OBJLstPtrTable_Map_Overworld_Flag
	ld   a, [sMapMtTeapotFlagY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapMtTeapotFlagX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapMtTeapotFlagLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapOverworldFlagFlags]
	ld   [sMapOAMWriteFlags], a
	ld   bc, sMapMtTeapotFlagY
	ld   de, sMapMtTeapotFlagX
	jr   Map_WriteFlagOBJLst
Map_StoveCanyon_WriteFlagOBJLst:
	ld   a, $10
	ld   [sMapOverworldFlagFlags], a
	ld   hl, OBJLstPtrTable_Map_Overworld_Flag
	ld   a, [sMapStoveCanyonFlagY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapStoveCanyonFlagX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapStoveCanyonFlagLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapOverworldFlagFlags]
	ld   [sMapOAMWriteFlags], a
	ld   bc, sMapStoveCanyonFlagY
	ld   de, sMapStoveCanyonFlagX
	jr   Map_WriteFlagOBJLst
Map_SSTeacup_WriteFlagOBJLst:
	ld   a, $10
	ld   [sMapOverworldFlagFlags], a
	ld   hl, OBJLstPtrTable_Map_Overworld_Flag
	ld   a, [sMapSSTeacupFlagY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapSSTeacupFlagX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapSSTeacupFlagLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapOverworldFlagFlags]
	ld   [sMapOAMWriteFlags], a
	ld   bc, sMapSSTeacupFlagY
	ld   de, sMapSSTeacupFlagX
	jr   Map_WriteFlagOBJLst
Map_ParsleyWoods_WriteFlagOBJLst:
	ld   a, $10
	ld   [sMapOverworldFlagFlags], a
	ld   hl, OBJLstPtrTable_Map_Overworld_Flag
	ld   a, [sMapParsleyWoodsFlagY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapParsleyWoodsFlagX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapParsleyWoodsFlagLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapOverworldFlagFlags]
	ld   [sMapOAMWriteFlags], a
	ld   bc, sMapParsleyWoodsFlagY
	ld   de, sMapParsleyWoodsFlagX
	jp   Map_WriteFlagOBJLst
Map_SherbetLand_WriteFlagOBJLst:
	ld   a, $10
	ld   [sMapOverworldFlagFlags], a
	ld   hl, OBJLstPtrTable_Map_Overworld_Flag
	ld   a, [sMapSherbetLandFlagY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMapSherbetLandFlagX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMapSherbetLandFlagLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapOverworldFlagFlags]
	ld   [sMapOAMWriteFlags], a
	ld   bc, sMapSherbetLandFlagY
	ld   de, sMapSherbetLandFlagX
	jp   Map_WriteFlagOBJLst
; [TCRF] For the unused Syrup Castle flag
Map_Unused_SyrupCastle_WriteFlagOBJLst:
	ld   a, $10
	ld   [sMapOverworldFlagFlags], a
	ld   hl, OBJLstPtrTable_Map_Overworld_Flag
	ld   a, [sMap_Unused_SyrupCastleFlagY]
	ld   [sMapOAMWriteY], a
	ld   a, [sMap_Unused_SyrupCastleFlagX]
	ld   [sMapOAMWriteX], a
	ld   a, [sMap_Unused_SyrupCastleFlagLstId]
	ld   [sMapOAMWriteLstId], a
	ld   a, [sMapOverworldFlagFlags]
	ld   [sMapOAMWriteFlags], a
	ld   bc, sMap_Unused_SyrupCastleFlagY
	ld   de, sMap_Unused_SyrupCastleFlagX
	jp   Map_WriteFlagOBJLst
; =============== Map_SetFlagOBJLstId ===============
; Sets the mapping frame and updates the timer for the specified flag sprite mapping.
; Every 8 frames the next mapping frame from the specified table is set.
;
; Essentially, FlagOBJLstId = OBJLstAnim[FlagTimer]
;
; IN
; - HL: Ptr to a table of sprite mapping IDs (OBJLstAnim source table)
;       This is always OBJLstAnim_OverworldFlags
; - BC: Ptr to flag OBJLst ID (where to save the ID)
; - DE: Ptr to flag timer (index to the source table)
Map_SetFlagOBJLstId:
	; Animate every 8 frames
	ld   a, [sMapTimer_Low]
	and  a, $07
	ret  nz
	
	;--
	
	ld   a, b						; Save BC
	ld   [sMapFlagLstIdPtr_High], a
	ld   a, c
	ld   [sMapFlagLstIdPtr_Low], a
	; Determine the sprite mapping ID to use, from the table at HL
	; The flag animation timer determines the index to this table
	xor  a							; BC = flag timer
	ld   b, a
	ld   a, [de]
	ld   c, a
	add  hl, bc						; and use it to index the mapping frame table
	
	ld   a, [sMapFlagLstIdPtr_High]	; Restore BC
	ld   b, a
	ld   a, [sMapFlagLstIdPtr_Low]
	ld   c, a
	;--
	; Update the mapping frame ID
	ld   a, [hl]					
	ld   [bc], a
	
	; Update the flag timer
	ld   a, [de]					
	inc  a
	ld   [de], a
	
	cp   a, (OBJLstAnim_OverworldFlags_End - OBJLstAnim_OverworldFlags)						
	ret  nz			; is the timer value going over the size of the table?
	xor  a			; if so, reset it
	ld   [de], a
	ret
	
; =============== OBJLstPtrTable_Map_Overworld_Flag ===============
OBJLstPtrTable_Map_Overworld_Flag:
	dw OBJLst_Map_Overworld_Flag0
	dw OBJLst_Map_Overworld_Flag1
	dw OBJLst_Map_Overworld_Flag2

OBJLst_Map_Overworld_Flag0: INCBIN "data/objlst/map/overworld_flag0.bin"
OBJLst_Map_Overworld_Flag1: INCBIN "data/objlst/map/overworld_flag1.bin"
OBJLst_Map_Overworld_Flag2: INCBIN "data/objlst/map/overworld_flag2.bin"

; =============== Map_BlinkLevel_Do ===============
; Handles the blinking level dots in a submap, if any are requested.
; These mark levels not 100% completed and are only visible after finishing the game once.
;
; IN
; - HL: Ptr to table of Level IDs to apply the effect to, ending with $FF.
;       This table should be in SRAM.
Map_BlinkLevel_Do:
	; Show dots depending on timer
	ld   a, [sMapTimer_Low]				
	and  a, $0C
	ret  nz
	; Save the ptr to memory
	ld   a, h							
	ld   [sMapBlinkLevelPtr_High], a
	ld   a, l
	ld   [sMapBlinkLevelPtr_Low], a
	; OBJ setup
	ld   a, $10							
	ld   [sMapExOBJ0Flags], a
	ld   [sMapExOBJ1Flags], a
	ld   [sMapExOBJ2Flags], a
	ld   a, $04	; Mapping ID for black level dot
	ld   [sMapExOBJ0LstId], a
	ld   [sMapExOBJ1LstId], a
	ld   [sMapExOBJ2LstId], a
	call Map_BlinkLevel_SetOBJInfo
	call Map_BlinkLevel_WriteOBJLst
	ret
	
; =============== Map_BlinkLevel_SetOBJInfo ===============
; Sets up ExOBJ info for the current blink dot sprites in a submap.
;
; A maximum of 3 dots can be visible at the same time.
Map_BlinkLevel_SetOBJInfo:

	; Get the course ID we're applying the effect to
	ld   a, [sMapBlinkLevelPtr_High]	; HL = Ptr to blink course table in SRAM
	ld   h, a
	ld   a, [sMapBlinkLevelPtr_Low]
	ld   l, a
	ld   a, [sMapBlinkId]				; A = Index
	ld   c, a
	call .indexTbl
	cp   a, $FF							; Have we reached the end separator?
	jr   z, .end						; If so, jump
	
	; Get the blink ID mapped to the level ID we've got
	ld   c, a							; C = Index
	ld   hl, Map_BlinkLevel_AssocTbl
	call .indexTbl						
	cp   a, $FF							; Did we get $FF (no blink id)?
	jr   z, .end						; If so, jump

	; Get the ptr to the current blink coords
	ld   hl, Map_BlinkLevel_PosPtrTbl
	call Map_BlinkLevel_IndexPosPtrTbl				
	ld   a, [hl]						; D = Y coord
	ld   d, a
	inc  hl
	ld   a, [hl]						; E = X coord
	ld   e, a
	;--
	
	; Which OBJ slot we're updating?
	ld   a, [sMapBlinkId]				
	cp   a, $01
	jr   z, .setBlink1
	cp   a, $02
	jr   z, .setBlink2
	
.setBlink0:
	ld   a, d						; Store the sprite's coordinates
	ld   [sMapExOBJ0Y], a
	ld   a, e
	ld   [sMapExOBJ0X], a
	ld   a, $01						; Flag the dot as visible.
	ld   [sMapBlinkDoneFlags], a	
	ld   hl, sMapBlinkId			; Process the next blink id.
	inc  [hl]
	jr   Map_BlinkLevel_SetOBJInfo
.setBlink1:
	ld   a, d
	ld   [sMapExOBJ1Y], a
	ld   a, e
	ld   [sMapExOBJ1X], a
	ld   a, [sMapBlinkDoneFlags]
	add  $02
	ld   [sMapBlinkDoneFlags], a
	ld   hl, sMapBlinkId
	inc  [hl]
	jr   Map_BlinkLevel_SetOBJInfo
.setBlink2:
	ld   a, d
	ld   [sMapExOBJ2Y], a
	ld   a, e
	ld   [sMapExOBJ2X], a
	ld   a, [sMapBlinkDoneFlags]
	add  $04
	ld   [sMapBlinkDoneFlags], a
.end:
	xor  a
	ld   [sMapBlinkId], a
	ret
	
; =============== .indexTbl ===============
; Indexes a blink table.
;
; IN
; - HL: Ptr to start of the blink table
; -  C: Index
;
; OUT
; -  A: Indexed value
.indexTbl:
	xor  a
	ld   b, a		; A = HL[C]
	add  hl, bc
	ld   a, [hl]
	ret
	
; =============== Map_BlinkLevel_IndexPosPtrTbl ===============
; Indexes the blink position table pointer table.
;
; IN
; - HL: Ptr to position table (always Map_BlinkLevel_PosPtrTbl)
; -  C: Blink ID (table index)
;
; OUT
; - HL: Ptr to table entry
Map_BlinkLevel_IndexPosPtrTbl:
	add  a			; Table entries are 2 bytes
	ld   c, a
	ld   b, $00
	add  hl, bc		; Offset the pos table
	ldi  a, [hl]	
	ld   e, a
	ld   h, [hl]	
	ld   l, e
	ret
	
; =============== Map_BlinkLevel_WriteOBJLst ===============
; Writes the blink dots sprite mappings for all three blinking dots.
Map_BlinkLevel_WriteOBJLst:
	ld   a, [sMapBlinkDoneFlags]
	call .write0
	ld   a, [sMapBlinkDoneFlags]
	call .write1
	ld   a, [sMapBlinkDoneFlags]
	call .write2
	xor  a
	ld   [sMapBlinkDoneFlags], a
	ret
.write0:
	bit  0, a					; Was the blink sprite setup?
	ret  z						; If not, return
	call Map_WriteExOBJ0Lst
	ret
.write1:
	bit  1, a
	ret  z
	call Map_WriteExOBJ1Lst
	ret
.write2:
	bit  2, a
	ret  z
	call Map_WriteExOBJ2Lst
	ret
	
; =============== Map_BlinkLevel_AssocTbl ===============
; This table maps Level IDs to Blink/Treasure IDs.
; Levels without a treasure assigned have a dummy entry of $FF.
Map_BlinkLevel_AssocTbl: 
	db TREASURE_C-1 ; LVL_C26 
	db $FF ; LVL_C33 
	db $FF ; LVL_C15 
	db TREASURE_I-1 ; LVL_C20 
	db TREASURE_F-1 ; LVL_C16 
	db $FF ; LVL_C10 
	db $FF ; LVL_C07 
	db $FF ; LVL_C01A
	db TREASURE_O-1 ; LVL_C17 
	db $FF ; LVL_C12 
	db $FF ; LVL_C13 
	db TREASURE_A-1 ; LVL_C29 
	db $FF ; LVL_C04 
	db TREASURE_N-1 ; LVL_C09 
	db TREASURE_G-1 ; LVL_C03A	; [TCRF] Not possible to see normally
	db $FF ; LVL_C02 
	db $FF ; LVL_C08 
	db TREASURE_H-1 ; LVL_C11 
	db $FF ; LVL_C35 
	db TREASURE_M-1 ; LVL_C34 
	db TREASURE_L-1 ; LVL_C30 
	db $FF ; LVL_C21 
	db $FF ; LVL_C22 
	db $FF ; LVL_C01B
	db $FF ; LVL_C19 
	db $FF ; LVL_C05 
	db $FF ; LVL_C36 
	db TREASURE_K-1 ; LVL_C24 
	db $FF ; LVL_C25 
	db $FF ; LVL_C32 
	db $FF ; LVL_C27 
	db $FF ; LVL_C28 
	db TREASURE_B-1 ; LVL_C18 
	db $FF ; LVL_C14 
	db $FF ; LVL_C38 
	db TREASURE_D-1 ; LVL_C39 
	db TREASURE_G-1 ; LVL_C03B
	db TREASURE_J-1 ; LVL_C37 
	db TREASURE_E-1 ; LVL_C31A	; [TCRF] Not possible to see normally
	db $FF ; LVL_C23 
	db $FF ; LVL_C40 
	db $FF ; LVL_C06 
	db TREASURE_E-1 ; LVL_C31B 
	
; =============== Map_BlinkLevel_PosPtrTbl ===============
; This table contains ptrs the coordinates for the blinking dots in a submap.
; Each entry is 2 bytes long:
; - Y pos
; - X pos
Map_BlinkLevel_PosPtrTbl: 
	dw Map_BlinkLevel_PosC26
	dw Map_BlinkLevel_PosC20
	dw Map_BlinkLevel_PosC16
	dw Map_BlinkLevel_PosC17
	dw Map_BlinkLevel_PosC29
	dw Map_BlinkLevel_PosC09
	dw Map_BlinkLevel_PosC11
	dw Map_BlinkLevel_PosC34
	dw Map_BlinkLevel_PosC30
	dw Map_BlinkLevel_PosC24
	dw Map_BlinkLevel_PosC18
	dw Map_BlinkLevel_PosC39
	dw Map_BlinkLevel_PosC03
	dw Map_BlinkLevel_PosC37
	dw Map_BlinkLevel_PosC31
	ret

;                           Y   X
Map_BlinkLevel_PosC26: db $30,$40
Map_BlinkLevel_PosC20: db $27,$30
Map_BlinkLevel_PosC16: db $70,$58
Map_BlinkLevel_PosC17: db $58,$40
Map_BlinkLevel_PosC29: db $78,$69
Map_BlinkLevel_PosC09: db $58,$40
Map_BlinkLevel_PosC11: db $50,$68
Map_BlinkLevel_PosC34: db $60,$98
Map_BlinkLevel_PosC30: db $84,$8C
Map_BlinkLevel_PosC24: db $88,$28
Map_BlinkLevel_PosC18: db $70,$88
Map_BlinkLevel_PosC39: db $60,$60
Map_BlinkLevel_PosC03: db $68,$50
Map_BlinkLevel_PosC37: db $90,$70
Map_BlinkLevel_PosC31: db $88,$38

GFXRLE_Overworld: INCBIN "data/gfx/maps/overworld.rlc"
GFXRLE_ParsleyWoods_SherbetLand: INCBIN "data/gfx/maps/parsleywoods_sherbetland.rlc"
BGRLE_SherbetLand: INCBIN "data/bg/maps/sherbetland.rls"
BGRLE_ParsleyWoods: INCBIN "data/bg/maps/parsleywoods.rls"
GFX_OverworldOBJ: INCBIN "data/gfx/maps/overworld_obj.bin"
.end:
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L147F17.asm"
ENDC

