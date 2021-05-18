;
; BANK $1F - Ending and Credits Cutscenes
;
OBJLst_Ending_Lamp: INCBIN "data/objlst/ending/lamp.bin"
OBJLst_Ending_LampInv: INCBIN "data/objlst/ending/lampinv.bin"
OBJLst_Ending_CloudA0: INCBIN "data/objlst/ending/clouda0.bin"
OBJLst_Ending_CloudA1: INCBIN "data/objlst/ending/clouda1.bin"
OBJLst_Ending_CloudB0: INCBIN "data/objlst/ending/cloudb0.bin"
OBJLst_Ending_CloudB1: INCBIN "data/objlst/ending/cloudb1.bin"
OBJLst_Ending_CloudC0: INCBIN "data/objlst/ending/cloudc0.bin"
OBJLst_Ending_CloudC1: INCBIN "data/objlst/ending/cloudc1.bin"
OBJLst_Ending_MoneyBag1_Top: INCBIN "data/objlst/ending/moneybag1_top.bin"
OBJLst_Ending_MoneyBag2_Top: INCBIN "data/objlst/ending/moneybag2_top.bin"
OBJLst_Ending_MoneyBag3_Top: INCBIN "data/objlst/ending/moneybag3_top.bin"
OBJLst_Ending_MoneyBag4_Top: INCBIN "data/objlst/ending/moneybag4_top.bin"
OBJLst_Ending_MoneyBag5_Top: INCBIN "data/objlst/ending/moneybag5_top.bin"
OBJLst_Ending_MoneyBag6: INCBIN "data/objlst/ending/moneybag6.bin"
OBJLst_Ending_MoneyBag5_Body: INCBIN "data/objlst/ending/moneybag5_body.bin"
OBJLst_Ending_MoneyBag4_Body: INCBIN "data/objlst/ending/moneybag4_body.bin"
OBJLst_Ending_MoneyBag3_Body: INCBIN "data/objlst/ending/moneybag3_body.bin"
OBJLst_Ending_MoneyBag2_Body: INCBIN "data/objlst/ending/moneybag2_body.bin"
OBJLst_Ending_MoneyBag1_Body: INCBIN "data/objlst/ending/moneybag1_body.bin"
OBJLst_Ending_WLogo: INCBIN "data/objlst/ending/wlogo.bin"
OBJLst_Ending_WLogoInv: INCBIN "data/objlst/ending/wlogoinv.bin"
OBJLst_Ending_GenieFace_Look: INCBIN "data/objlst/ending/genieface_look.bin"
OBJLst_Ending_GenieFace_LookMouth: INCBIN "data/objlst/ending/genieface_lookmouth.bin"
OBJLst_Ending_GenieFace_Blink: INCBIN "data/objlst/ending/genieface_blink.bin"
OBJLst_Ending_GenieFace_Unused_BlinkMouth: INCBIN "data/objlst/ending/genieface_unused_blinkmouth.bin"
OBJLst_Ending_Balloon_PlThink: INCBIN "data/objlst/ending/balloon_plthink.bin"
OBJLst_Ending_Balloon_PlSpeak: INCBIN "data/objlst/ending/balloon_plspeak.bin"
OBJLst_Ending_Balloon_GenieSpeak: INCBIN "data/objlst/ending/balloon_geniespeak.bin"

; =============== Ending_WriteOBJ ===============
Ending_WriteOBJ:
	xor  a						; Reset written OBJ count (4 bytes)
	ld   [wStaticOBJCount], a
	ld   b, a
	call HomeCall_Static_WriteWarioOBJLst
	call Ending_WriteHeldOBJ
	call Ending_WriteCloud0OBJ
	call Ending_WriteCloud1OBJ
	call Ending_WriteGenieFaceOBJ
	call Ending_WriteBalloonOBJ
	jp   Static_FinalizeWorkOAM
	
; =============== Ending_WriteHeldOBJ ===============
; Writes the object Wario can hold (either the lamp sprite or moneybags). 
Ending_WriteHeldOBJ:
	ld   a, [wEndHeldX]
	ld   [sOAMWriteX], a
	ld   a, [wEndHeldY]
	ld   [sOAMWriteY], a
	ld   a, [wEndHeldLstId]
	rst  $28
	dw End_NoFrame
	dw .lamp
	dw .lampInv
	dw .moneybag1
	dw .moneybag2
	dw .moneybag3
	dw .moneybag4
	dw .moneybag5
	dw .moneybag6
.lamp:
	ld   de, OBJLst_Ending_Lamp
	jp   Static_WriteOBJLst
.lampInv:
	ld   de, OBJLst_Ending_LampInv
	jp   Static_WriteOBJLst
.moneybag1:
	; Sprite mappings split in two to reuse data from OBJLst_Ending_MoneyBag6
	ld   de, OBJLst_Ending_MoneyBag1_Top
	call Static_WriteOBJLst
	ld   de, OBJLst_Ending_MoneyBag1_Body
	jp   Static_WriteOBJLst
.moneybag2:
	ld   de, OBJLst_Ending_MoneyBag2_Top
	call Static_WriteOBJLst
	ld   de, OBJLst_Ending_MoneyBag2_Body
	jp   Static_WriteOBJLst
.moneybag3:
	ld   de, OBJLst_Ending_MoneyBag3_Top
	call Static_WriteOBJLst
	ld   de, OBJLst_Ending_MoneyBag3_Body
	jp   Static_WriteOBJLst
.moneybag4:
	ld   de, OBJLst_Ending_MoneyBag4_Top
	call Static_WriteOBJLst
	ld   de, OBJLst_Ending_MoneyBag4_Body
	jp   Static_WriteOBJLst
.moneybag5:
	ld   de, OBJLst_Ending_MoneyBag5_Top
	call Static_WriteOBJLst
	ld   de, OBJLst_Ending_MoneyBag5_Body
	jp   Static_WriteOBJLst
.moneybag6:
	ld   de, OBJLst_Ending_MoneyBag6
	jp   Static_WriteOBJLst
	
; =============== Ending_WriteCloud0OBJ ===============
; Writes the sprite mappings for the first cloud coming out of the lamp.
; Also reused for the "W Mark" (circle with "W") moving down over the castle.
Ending_WriteCloud0OBJ:;C
	ld   a, [wEndCloud0X]
	ld   [sOAMWriteX], a
	ld   a, [wEndCloud0Y]
	ld   [sOAMWriteY], a
	jr   Ending_WriteCloudOBJ
; =============== Ending_WriteCloud1OBJ ===============
; Writes the sprite mappings for the second cloud coming out of the lamp.
Ending_WriteCloud1OBJ:
	ld   a, [wEndCloud1X]
	ld   [sOAMWriteX], a
	ld   a, [wEndCloud1Y]
	ld   [sOAMWriteY], a
	; If the second cloud is hidden, don't draw it
	ld   a, [wEndCloud1Show]
	cp   a, $00
	ret  z
	
; =============== Ending_WriteCloudOBJ ===============
Ending_WriteCloudOBJ:
	ld   a, [wEndCloudLstId]
	rst  $28
	dw End_NoFrame
	dw .cloudA0
	dw .cloudA1
	dw .cloudB0
	dw .cloudB1
	dw .cloudC0
	dw .cloudC1
	dw .wLogo
	dw .wLogoInv
.cloudA0:
	ld   de, OBJLst_Ending_CloudA0
	jp   Static_WriteOBJLst
.cloudA1:
	ld   de, OBJLst_Ending_CloudA1
	jp   Static_WriteOBJLst
.cloudB0:
	ld   de, OBJLst_Ending_CloudB0
	jp   Static_WriteOBJLst
.cloudB1:
	ld   de, OBJLst_Ending_CloudB1
	jp   Static_WriteOBJLst
.cloudC0:
	ld   de, OBJLst_Ending_CloudC0
	jp   Static_WriteOBJLst
.cloudC1:
	ld   de, OBJLst_Ending_CloudC1
	jp   Static_WriteOBJLst
.wLogo:
	ld   de, OBJLst_Ending_WLogo
	jp   Static_WriteOBJLst
.wLogoInv:
	ld   de, OBJLst_Ending_WLogoInv
	jp   Static_WriteOBJLst
	
; =============== Ending_WriteGenieFaceOBJ ===============
; Writes the sprite mappings for the Genie's face.
Ending_WriteGenieFaceOBJ:
	; Fixed coordinates
	ld   a, $68
	ld   [sOAMWriteX], a
	ld   a, $1C
	ld   [sOAMWriteY], a
	ld   a, [wEndGenieFaceLstId]
	rst  $28
	dw End_NoFrame
	dw .look				; Eyes open, mouth closed
	dw .lookMouth			; Eyes open, mouth open
	dw .blink				; Eyes closed, mouth closed
	dw .unused_blinkMouth	; Eyes closed, mouth open
.look:
	ld   de, OBJLst_Ending_GenieFace_Look
	jp   Static_WriteOBJLst
.lookMouth:
	ld   de, OBJLst_Ending_GenieFace_LookMouth
	jp   Static_WriteOBJLst
.blink:
	ld   de, OBJLst_Ending_GenieFace_Blink
	jp   Static_WriteOBJLst
; [TCRF] This combination isn't used.
.unused_blinkMouth: 
	ld   de, OBJLst_Ending_GenieFace_Unused_BlinkMouth
	jp   Static_WriteOBJLst
	
; =============== Ending_WriteBalloonOBJ ===============
; Writes the sprite mappings for the arrow of the think / speak baloon.
; Used to mark who is thinking or speaking.
Ending_WriteBalloonOBJ:
	; Different sets of coordinates for each
	ld   a, [wEndBalloonLstId]
	rst  $28
	dw End_NoFrame
	dw .plThink
	dw .plSpeak
	dw .genieSpeak
.plThink:
	ld   a, $24				; Bubble "arrow" pointing to player
	ld   [sOAMWriteX], a
	ld   a, $4B
	ld   [sOAMWriteY], a
	ld   de, OBJLst_Ending_Balloon_PlThink
	jp   Static_WriteOBJLst
.plSpeak:
	ld   a, $24				; Arrow pointing to player
	ld   [sOAMWriteX], a
	ld   a, $4B
	ld   [sOAMWriteY], a
	ld   de, OBJLst_Ending_Balloon_PlSpeak
	jp   Static_WriteOBJLst
.genieSpeak:
	ld   a, $34				; Arrow pointing to genie
	ld   [sOAMWriteX], a
	ld   a, $3B
	ld   [sOAMWriteY], a
	ld   de, OBJLst_Ending_Balloon_GenieSpeak
	jp   Static_WriteOBJLst
	
; =============== End_ScreenEvent_Do ===============
; Handles tile animation for the ending and credits sequence.
End_ScreenEvent_Do:
	call End_Genie_SetHandLAnim
	call End_Genie_SetHandRAnim
	call End_SetBalloon
	jp   Credits_AnimCastleFlags
	
; =============== End_Genie_SetHandLAnim ===============
; Changes the tilemap for the Genie's arm on the left in the ending cutscene.
; Tilemap replacement in a 5x4 area.
End_Genie_SetHandLAnim:

	; Determine the partial tilemap to use
	ld   a, [wEndGenieHandLFrameSet]
	rst  $28
	dw End_NoFrame
	dw .closed
	dw .point
	dw .palm
.closed:
	ld   de, BG_End_Genie_HandLClosed
	jr   .copyBG
.point:
	ld   de, BG_End_Genie_HandLPoint
	jr   .copyBG
.palm:
	ld   de, BG_End_Genie_HandLPalm
	
GENIE_HANDL_WIDTH  EQU $05
GENIE_HANDL_HEIGHT EQU $04

.copyBG:
	ld   hl, vBGEndGenieHandL	; HL = Base offset in tilemap
	ld   b, GENIE_HANDL_HEIGHT
	ld   c, GENIE_HANDL_WIDTH
	jr   .nextX
.nextY:
	; Set HL to first tile of next row
	push bc
	ld   b, $00
	ld   c, $20-GENIE_HANDL_WIDTH
	add  hl, bc ; HL += FullRow-BlockWidth
	pop  bc
	ld   c, GENIE_HANDL_WIDTH
.nextX:
	ld   a, [de]
	ldi  [hl], a
	inc  de
	dec  c
	jr   nz, .nextX
	dec  b
	jr   nz, .nextY
End_NoFrame:
	ret

BG_End_Genie_HandLClosed: INCBIN "data/bg/ending/genie_handl_closed.bin"
BG_End_Genie_HandLPoint: INCBIN "data/bg/ending/genie_handl_point.bin"
BG_End_Genie_HandLPalm: INCBIN "data/bg/ending/genie_handl_palm.bin"

; =============== End_Genie_SetHandRAnim ===============
; Changes the tilemap for the Genie's arm on the right in the ending cutscene.
; Tilemap replacement in a 5x3 area.
End_Genie_SetHandRAnim:

	; Determine the tilemap to apply
	ld   a, [wEndGenieHandRFrameSet]
	rst  $28
	dw End_NoFrame
	dw .closed
	dw .point
	dw .open
.closed:
	ld   de, BG_End_Genie_HandRClosed
	jr   .copyBG
.point:
	ld   de, BG_End_Genie_HandRPoint
	jr   .copyBG
.open:
	ld   de, BG_End_Genie_HandROpen
	
	
GENIE_HANDR_WIDTH  EQU $05
GENIE_HANDR_HEIGHT EQU $03
.copyBG:
	ld   hl, vBGEndGenieHandR		; HL = Base offset in tilemap
	ld   b, GENIE_HANDR_HEIGHT		; Height: 3 tiles
	ld   c, GENIE_HANDR_WIDTH		; Width: 5 tiles
	jr   .nextX
.nextY:
	; Set HL to the first tile of the next row
	push bc
	ld   b, $00
	ld   c, $20-GENIE_HANDR_WIDTH
	add  hl, bc
	pop  bc
	ld   c, GENIE_HANDR_WIDTH
.nextX:
	ld   a, [de]
	ldi  [hl], a
	inc  de
	dec  c
	jr   nz, .nextX
	dec  b
	jr   nz, .nextY
	ret
	
BG_End_Genie_HandRClosed: INCBIN "data/bg/ending/genie_handr_closed.bin"
BG_End_Genie_HandRPoint: INCBIN "data/bg/ending/genie_handr_point.bin"
BG_End_Genie_HandROpen: INCBIN "data/bg/ending/genie_handr_open.bin"

; =============== End_SetBalloon ===============
; Update the tilemap to show or hide the speech balloon in the ending cutscene.
; Note this does not set the sprites related to it.
End_SetBalloon:
	; Determine the tilemap to use, if one is specified
	ld   a, [wEndBalloonFrameSet]
	rst  $28
	dw End_NoFrame
	dw .emptyBox
	dw .castleBox
	dw .nothing
.emptyBox:
	ld   de, BG_End_Balloon_Empty
	jr   .copyBG
.castleBox:
	ld   de, BG_End_Balloon_Castle
	jr   .copyBG
.nothing:
	ld   de, BG_End_Balloon_Null
	
BALLOON_WIDTH  EQU $05
BALLOON_HEIGHT EQU $05
.copyBG:
	ld   hl, vBGEndBalloon	; HL = Tilemap location
	ld   b, BALLOON_HEIGHT	; Height: 5 tiles
	ld   c, BALLOON_WIDTH	; Width: 5 tiles
	jr   .nextX
.nextY:
	push bc
	ld   b, $00
	ld   c, $20-BALLOON_WIDTH
	add  hl, bc
	pop  bc
	ld   c, BALLOON_WIDTH
.nextX:
	ld   a, [de]
	ldi  [hl], a
	inc  de
	dec  c
	jr   nz, .nextX
	dec  b
	jr   nz, .nextY
	ret
BG_End_Balloon_Empty: INCBIN "data/bg/ending/balloon_empty.bin"
BG_End_Balloon_Castle: INCBIN "data/bg/ending/balloon_castle.bin"
BG_End_Balloon_Null: INCBIN "data/bg/ending/balloon_null.bin"

; =============== Credits_AnimCastleFlags ===============
; Animate the flags shown in the credits.
; This is a VRAM to VRAM GFX copy.
;
; The credits scene can use one of the two graphics sets, depeding on the ending received.
; These have differently sized flag GFX stored in a different points in the tilemap.
Credits_AnimCastleFlags:
	; Determine the correct anim mode (it depends on the GFX loaded)
	ld   a, [wEndFlagAnimType]
	rst  $28
	dw End_NoFrame
	dw .smallFlag
	dw .largeFlag
.smallFlag:
	; Update the anim timer
	ld   a, [wEndFlagAnimTimer]
	inc  a
	ld   [wEndFlagAnimTimer], a
	; Pick the source data offset based on the timer
	cp   a, $1E
	jr   z, .frame1S ; Use the second frame
	cp   a, $3C
	jr   z, .frame0S ; Use the first frame and reset the timer
	ret
.frame1S:
	ld   hl, vGFXCreditsFlagsSAnimGFX1
	jr   .copyGFXS
.frame0S:;R
	xor  a
	ld   [wEndFlagAnimTimer], a
	ld   hl, vGFXCreditsFlagsSAnimGFX0
.copyGFXS:
	ld   de, vGFXCreditsFlagsSAnim	; DE = Destination
	ld   b, $10						; Copy 1 tile
.loop:
	ldi  a, [hl]	; Generic GFX copy loop
	ld   [de], a
	inc  de
	dec  b
	jr   nz, .loop
	ret
.largeFlag:
	; Update the anim timer
	ld   a, [wEndFlagAnimTimer]
	inc  a
	ld   [wEndFlagAnimTimer], a
	; Pick the source data offset based on the timer
	cp   a, $1E
	jr   z, .frame0L ; Use the first frame
	cp   a, $3C
	jr   z, .frame1L ; Use the second frame and reset the timer
	ret
.frame0L:
	ld   hl, vGFXCreditsFlagsLAnimGFX0
	jr   .copyGFXL
.frame1L:
	xor  a							; Reset the anim timer
	ld   [wEndFlagAnimTimer], a
	ld   hl, vGFXCreditsFlagsLAnimGFX1
.copyGFXL:
	ld   de, vGFXCreditsFlagsLAnim	; DE = Destination
	ld   b, $20						; Copy 2 tiles
	jr   .loop
; =============== Ending_Do ===============
; See also: CoinBonus_Do
Ending_Do:
	ld   a, $A0						; Static_WriteOBJLst uses another variable for this purpose
	ld   [sWorkOAMPos], a
	xor  a							; Reset anim requests at the start
	ld   [wEndGenieHandLFrameSet], a
	ld   [wEndGenieHandRFrameSet], a
	ld   [wEndBalloonFrameSet], a
	call .main
	jp   Ending_WriteOBJ
.main:
	ld   a, [wEndingMode]
	rst  $28
	dw Ending_InitPreTr
	dw Ending_PreTr
	dw Ending_InitPostTr
	dw Ending_PostTr
	dw Ending_InitPreCred
	dw Ending_PreCred
	dw Ending_Credits
	dw Ending_PreCredPlanet
	
; =============== Ending_InitPreTr ===============
; Initializes the ending scene.
Ending_InitPreTr:
	call StopLCDOperation
	call ClearBGMapEx
	call ClearWorkOAM
	ld   hl, GFXRLE_EndingA
	call DecompressGFXStub
	ld   hl, BGRLE_Ending_CutsceneNoGenie
	call DecompressBG_ToWINDOWMap
	ld   hl, BGRLE_Ending_CutsceneGenie
	call DecompressBG_ToBGMap
	call Ending_InitVars
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	ldh  [rLCDC], a
	ld   a, BGM_ENDINGGENIE
	ld   [sBGMSet], a
	; Set initial position of the sprite held by the player.
	; It's a lamp here, which starts off-screen on the left like the player does.
	ld   a, $E1
	ld   [wEndHeldX], a
	ld   a, $54
	ld   [wEndHeldY], a
	ld   a, END_OBJ_HELD_LAMP
	ld   [wEndHeldLstId], a
	ld   [wEndingMode], a		; END_RTN_PRETR -- next mode
	ret
; =============== Ending_InitVars ===============
Ending_InitVars:
	xor  a
	ld   [wEndAct], a
	ld   [wEndLoopsLeft], a
	ld   [wStaticPlAnimTimer], a
	ld   [wEndPlMoveLDelay], a
	ld   [wEndGenieTimer], a
	ld   [wEndCloudAnimTimer], a
	ld   [wEndLampThrowTimer], a
	ld   [wStaticPlLstId], a
	ld   [wEndGenieFaceLstId], a
	ld   [wEndHeldLstId], a
	ld   [wEndCloudLstId], a
	ld   [wEndCloud1Show], a
	ld   [wEndBalloonLstId], a
	ld   [wEndFlagAnimType], a
	ld   [wStaticPlFlags], a
	; Reset vert and horz scroll
	ldh  [rSCX], a			
	ldh  [rSCY], a
	
	; The tilemaps here are set up so that showing the genie needs to only be done by hiding the WINDOW.
	; Now we should hide the genie, so place the WINDOW over the screen.
	ldh  [rWY], a
	ld   a, $07
	ldh  [rWX], a
	
	; Start off-screen on the left
	ld   a, $D8
	ld   [wStaticPlX], a
	ld   a, $62
	ld   [wStaticPlY], a
	
	; Set OBJ and BG palette
	ld   a, $1D
	ldh  [rOBP0], a
	ld   a, $E1
	ldh  [rBGP], a
	ldh  [rOBP1], a
	ret
	
; =============== Ending_PreTr ===============
; First part of the cutscene, before the treasure room.
Ending_PreTr:
	ld   a, [wEndAct]
	rst  $28
	dw Ending_PreTr_WalkRight
	dw Ending_PreTr_ThrowLamp
	dw Ending_PreTr_RubLamp
	dw Ending_PreTr_LampFlash
	dw Ending_PreTr_DoClouds
	dw Ending_PreTr_FlashBG
	dw Ending_PreTr_PlBump
	dw Ending_PreTr_GenieTalk
	dw Ending_PreTr_ThinkWish
	dw Ending_DoPlJump
	dw Ending_PreTr_GenieMoney
	dw Ending_AnimPlNod
	dw Ending_PreTr_WalkLeft
	
; =============== Ending_PreTr_WalkRight ===============
; Moves the player right while holding the lamp, starting off-screen,
; until around the middle of the screen.
Ending_PreTr_WalkRight:
	;
	; Move player right until reaching the target position
	;
	ld   a, [wEndHeldX]		; Move held lamp
	inc  a
	ld   [wEndHeldX], a
	ld   a, [wStaticPlX]	; Move player
	inc  a
	ld   [wStaticPlX], a
	cp   a, $3A						; Target reached?
	jr   nz, Ending_Pl_WalkHoldAnim	; If not, continue walking
.nextMode:
	; Otherwise, stop walking and reach to the next mode.
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   a, OBJ_ENDING_WARIO_IDLEHOLD	; Set idle frame
	ld   [wStaticPlLstId], a
	ld   a, END1_RTN_THROWLAMP			; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_Pl_WalkHoldAnim ===============
; Handles the timing for Wario's walking animation when holding something.
; It also makes the object we're holding bob up and down.
;
; This is specifically made for the ending, since it has hardcoded Y positions
; for the object we're holding.
Ending_Pl_WalkHoldAnim:
	ld   a, [wStaticPlAnimTimer]
	inc  a
	ld   [wStaticPlAnimTimer], a
	; Only move the the held object 1px below the usual position
	; when setting frame OBJ_ENDING_WARIO_WALKHOLD0.
	; Everything else forces the standard position.
	cp   a, $01
	jr   z, .setFrame0_heldMoveDown
	cp   a, $04
	jr   z, .setFrame1
	cp   a, $08
	jr   z, .setFrame3
	cp   a, $0C
	jr   z, .playWalkSFX
	cp   a, $10
	jr   z, .setFrame2
	cp   a, $14
	jr   z, .setFrame3
	cp   a, $18
	ret  nz
	xor  a
	ld   [wStaticPlAnimTimer], a
.playWalkSFX:
	ld   a, SFX4_08
	ld   [sSFX4Set], a
.setFrame0_heldMoveDown:
	ld   a, OBJ_ENDING_WARIO_WALKHOLD0
	ld   [wStaticPlLstId], a
	ld   a, $53+$01
	ld   [wEndHeldY], a
	ret
.setFrame1:
	ld   a, OBJ_ENDING_WARIO_WALKHOLD1
	ld   [wStaticPlLstId], a
	jr   .heldMoveDown
.setFrame3:
	ld   a, OBJ_ENDING_WARIO_WALKHOLD3
	ld   [wStaticPlLstId], a
	jr   .heldMoveDown
.setFrame2:
	ld   a, OBJ_ENDING_WARIO_WALKHOLD2
	ld   [wStaticPlLstId], a
.heldMoveDown:
	ld   a, $53
	ld   [wEndHeldY], a
	ret
	
; =============== Ending_PreTr_ThrowLamp ===============
; The player throws the lamp to the ground.
Ending_PreTr_ThrowLamp:
	; Wait for $3C frames before continuing
	ld   a, [wStaticPlAnimTimer]
	cp   a, $3C						; Timer == $3C?
	jr   z, .throwLamp				; If so, jump
	inc  a							; Otherwise, timer++
	ld   [wStaticPlAnimTimer], a
	ret
.throwLamp:

	;
	; Throw the lamp for $0D frames, which means moving it:
	; - 1px/frame right
	; - 2px/frame down
	;
	; This value of $0D is picked to stop moving when reaching the ground
	; in the ending cutscene.
	;
	ld   a, OBJ_ENDING_WARIO_IDLETHROW	; Set throw frame while this happens
	ld   [wStaticPlLstId], a
	ld   a, [wEndLampThrowTimer]
	cp   a, $0D							; Thrown for $0D frames?
	jr   z, .nextMode					; If so, jump
	inc  a								; Otherwise, continue moving the lamp
	ld   [wEndLampThrowTimer], a
.moveLamp:
	ld   a, [wEndHeldX]					; LampX++
	inc  a
	ld   [wEndHeldX], a
	ld   a, [wEndHeldY]					; LampY += 2
	inc  a
	inc  a
	ld   [wEndHeldY], a
	ret
.nextMode:
	ld   a, SFX1_21
	ld   [sSFX1Set], a
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   [wEndLampThrowTimer], a
	ld   a, $6E							; Fix correct Y position
	ld   [wEndHeldY], a
	ld   a, $04							; Loop rub anim 4 times
	ld   [wEndLoopsLeft], a
	ld   a, END1_RTN_RUBLAMP			; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_PreTr_RubLamp ===============
; The player rubs the lamp (frames 0 & 1).
Ending_PreTr_RubLamp:
	ld   a, [wStaticPlAnimTimer]	; Timer++
	inc  a
	ld   [wStaticPlAnimTimer], a
	
	; Alternate between OBJ_ENDING_WARIO_DUCKRUB0 and OBJ_ENDING_WARIO_DUCKRUB1 up to 4 times,
	; until wEndLoopsLeft elapses.
	;
	; In this animation, both frames will alternate every 8 frames, since:
	;  -> $2E-$26 = $08 (OBJ_ENDING_WARIO_DUCKRUB0)
	;  -> $26-$1E = $08 (OBJ_ENDING_WARIO_DUCKRUB1)
	;
	; As a result of this, we also wait $26 frames before switching from the "throw" animation set previously.
	cp   a, $26
	jr   z, .setFrame0
	cp   a, $26+$08
	jr   z, .setFrame1
	ret
.setFrame0:
	ld   a, OBJ_ENDING_WARIO_DUCKRUB0
	ld   [wStaticPlLstId], a
	ret
.setFrame1:
	ld   a, SFX1_11					; Play initial lamp rub SFX
	ld   [sSFX1Set], a
	
	; Switch to OBJ_ENDING_WARIO_DUCKRUB1 for 8 frames
	ld   a, $26-$08					
	ld   [wStaticPlAnimTimer], a
	ld   a, OBJ_ENDING_WARIO_DUCKRUB1
	ld   [wStaticPlLstId], a
	
	; If the loop counter elapsed, switch to the next mode
	ld   a, [wEndLoopsLeft]
	dec  a
	ld   [wEndLoopsLeft], a
	ret  nz
.nextMode:
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   a, OBJ_ENDING_WARIO_DUCKRUB2	; Set third frame while it flashes
	ld   [wStaticPlLstId], a
	ld   a, $04						; Same loop counter
	ld   [wEndLoopsLeft], a
	ld   a, END1_RTN_LAMPFLASH		; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_PreTr_LampFlash ===============
; The lamp flashes every $0A frames, for 4 times.
; Very similar to Ending_PreTr_RubLamp.
Ending_PreTr_LampFlash:
	ld   a, [wStaticPlAnimTimer]	; AnimTimer++
	inc  a
	ld   [wStaticPlAnimTimer], a
	cp   a, $0A
	jr   z, .setFlash
	cp   a, $0A+$0A
	jr   z, .setNorm_chkEnd
	ret
.setFlash:
	ld   a, SFX1_05					; Play flash SFX
	ld   [sSFX1Set], a
	ld   a, END_OBJ_HELD_LAMPINV	; Black lamp
	ld   [wEndHeldLstId], a
	ret
.setNorm_chkEnd:
	xor  a							; Reset anim timer
	ld   [wStaticPlAnimTimer], a
	ld   a, END_OBJ_HELD_LAMP		; Normal lamp
	ld   [wEndHeldLstId], a
	
	; If the anim loop counter elapsed, switch to the next mode
	ld   a, [wEndLoopsLeft]
	dec  a
	ld   [wEndLoopsLeft], a
	ret  nz
	
	; Loop initial cloud anim 6 times, enough to for the other cloud
	; to show up in the first anim loop (END_OBJ_CLOUDA0 / END_OBJ_CLOUDA1).
	ld   a, $06						
	ld   [wEndLoopsLeft], a
	ld   a, END1_RTN_CLOUDS
	ld   [wEndAct], a
	ret
	
; =============== Ending_PreTr_DoClouds ===============
; Handles the small cloud movement and animation.
Ending_PreTr_DoClouds:
	ld   a, [wStaticPlAnimTimer]	
	
	; Wait for $15 frames before showing the small clouds coming from the lamp.
	; On the frame before that, set up the cloud initial positions.
	cp   a, $14						; Timer == $14?
	jr   z, .setCloudPos			; If so, jump
	
	cp   a, $15						; Timer == $15?
	jr   z, .chkMoveClouds					; If so, jump
	inc  a
	ld   [wStaticPlAnimTimer], a
	ret
.setCloudPos:
	ld   a, $15						; Next time jump to .chkMoveClouds
	ld   [wStaticPlAnimTimer], a
	
	;
	; Both clouds share the same animation frame and initial position (near the lamp),
	; but they use different sets of coordinates.
	; Keep in mind that until wEndCloud1Show is set, only the first cloud is visible,
	; and we'll be updating the coords separately.
	;
	
	ld   a, SFX1_01					
	ld   [sSFX1Set], a				; Play cloud "spawn" anim
	ld   [wEndCloudLstId], a		; END_OBJ_CLOUD0
	ld   a, $60						; Initial X pos
	ld   [wEndCloud0X], a
	ld   [wEndCloud1X], a
	ld   a, $64						; Initial Y pos
	ld   [wEndCloud0Y], a
	ld   [wEndCloud1Y], a
	ret
	
.chkMoveClouds:
	;
	; Move the clouds at 0.25px/frame
	;
	
	; Every 4 frames...
	ld   a, [wEndCloudAnimTimer]
	and  a, $03
	cp   a, $00
	jr   nz, .anim
	
.chkMove0R:
	; Move right the first cloud until it reaches the target pos
	ld   a, [wEndCloud0X]
	cp   a, $68				; Cloud0X == $68?
	jr   z, .chkMove0U		; If so, skip
	inc  a					; Move right 1px
	ld   [wEndCloud0X], a
	
.chkMove0U:
	; Move up the first cloud until it reaches the target pos
	ld   a, [wEndCloud0Y]
	cp   a, $38					; CloudOY == $38?
	jr   z, .chkMove1			; If so, target reached
	dec  a						; Move up 1px
	ld   [wEndCloud0Y], a
	; When it reaches Y $50, make the second cloud visible
	cp   a, $50					; Cloud0Y == $50?
	jr   nz, .chkMove1			; If not, skip
.showCloud1:
	ld   a, SFX1_01				; Play "spawn" SFX
	ld   [sSFX1Set], a
	ld   [wEndCloud1Show], a	; Show second cloud
.chkMove1:

	; If the second cloud isn't visible yet, skip this
	ld   a, [wEndCloud1Show]
	cp   a, $00						
	jr   z, .anim					
	
.chkMove1R:
	; Move right the second cloud until it reaches the target pos
	ld   a, [wEndCloud1X]
	cp   a, $70					; Cloud1X == $70?
	jr   z, .chkMove1U			; If so, skip
	inc  a						; Move right 1px
	ld   [wEndCloud1X], a
.chkMove1U:
	; Move up the second cloud until it reaches the target pos
	ld   a, [wEndCloud1Y]
	cp   a, $38					; Cloud1Y == $38?
	jr   z, .anim				; If so, skip
	dec  a						; Move up 1px
	ld   [wEndCloud1Y], a
	
.anim:
	;
	; Depending on the timer, set different animation frames to both clouds.
	; The timer gets reset to certain values to loop the animation a certain
	; number of times, like Ending_PreTr_RubLamp does.
	;
	ld   a, [wEndCloudAnimTimer]
	inc  a
	ld   [wEndCloudAnimTimer], a
	
	; Set 1: END_OBJ_CLOUDA0 / END_OBJ_CLOUDA1
	;        Looped 6 times, alternate every 10 frames.
	cp   a, $0A
	jr   z, .frameA1
	cp   a, $0A+$0A
	jr   z, .frameA0
		
	; Set 2: END_OBJ_CLOUDB0 / END_OBJ_CLOUDB1
	;        Looped 4 times, alternate every 10 frames.
	cp   a, $28
	jr   z, .frameB1
	cp   a, $28+$0A
	jr   z, .frameB0
	
	; Set 2: END_OBJ_CLOUDC0 / END_OBJ_CLOUDC1
	;        Looped 6 times, alternate every 10 frames.
	cp   a, $46
	jr   z, .frameC1
	cp   a, $46+$0A
	jr   z, .frameC0
	ret
	
; =============== Set A ===============
.frameA1:
	ld   a, END_OBJ_CLOUDA1				; Set second frame
	ld   [wEndCloudLstId], a
	ret
.frameA0:
	xor  a
	ld   [wEndCloudAnimTimer], a
	ld   a, OBJ_ENDING_WARIO_DUCKDIAG	; Set duck look-up player frame too
	ld   [wStaticPlLstId], a
	ld   a, END_OBJ_CLOUDA0				; Set first frame
	ld   [wEndCloudLstId], a
	
	; Handle animation loops left
	ld   a, [wEndLoopsLeft]
	dec  a								; LoopCount--
	ld   [wEndLoopsLeft], a				; LoopCount != 0?
	ret  nz								; If so, return
	ld   a, $04							; Otherwise, loop next set 4 times
	ld   [wEndLoopsLeft], a
	jr   .frameB0
	
; =============== Set B ===============
.frameB1:
	ld   a, END_OBJ_CLOUDB1
	ld   [wEndCloudLstId], a
	ret
.frameB0:
	ld   a, $28-$0A						; Show for $0A frames
	ld   [wEndCloudAnimTimer], a
	ld   a, END_OBJ_CLOUDB0
	ld   [wEndCloudLstId], a
	ld   a, [wEndLoopsLeft]
	dec  a
	ld   [wEndLoopsLeft], a
	ret  nz
	ld   a, $06
	ld   [wEndLoopsLeft], a
	jr   z, .frameC0
	
; =============== Set C ===============
.frameC1:
	ld   a, OBJ_STATIC_WARIO_IDLEDIAG	; Loop up normally
	ld   [wStaticPlLstId], a
	ld   a, END_OBJ_CLOUDC1
	ld   [wEndCloudLstId], a
	ret
.frameC0:
	ld   a, $46-$0A
	ld   [wEndCloudAnimTimer], a
	ld   a, END_OBJ_CLOUDC0
	ld   [wEndCloudLstId], a
	ld   a, [wEndLoopsLeft]
	dec  a
	ld   [wEndLoopsLeft], a
	ret  nz
	
.nextMode:
	; Once the final animation looped 6 times...
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   [wEndCloudAnimTimer], a
	ld   [wEndCloudLstId], a		; Hide all clouds
	ld   [wEndCloud1Show], a		; ""
	ld   a, $0A						; Flash $0A times 
	ld   [wEndLoopsLeft], a
	ld   a, END1_RTN_FLASHBG		; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_PreTr_FlashBG ===============
; Makes the background flash, then performs the wave effect
Ending_PreTr_FlashBG:
	; Execute the wave effect when the timer reaches $1E
	ld   a, [wEndBGFlashTimer]
	cp   a, $1E
	jr   z, Ending_DoWaveEffect
	inc  a
	ld   [wEndBGFlashTimer], a
	
	; Time the palette inversion seuquence
	cp   a, $0A
	jr   z, Ending_FlashBG_UseInvPal
	cp   a, $14
	jr   z, Ending_PreTr_FlashBG_UseNormPal
	ret
; =============== Ending_FlashBG_UseInvPal ===============
Ending_FlashBG_UseInvPal:
	ld   a, SFX4_04
	ld   [sSFX4Set], a
	ld   a, $1B				; Use inverted palette
	ldh  [rBGP], a
	ret
; =============== Ending_PreTr_FlashBG_UseNormPal ===============
Ending_PreTr_FlashBG_UseNormPal:
	xor  a
	ld   [wEndBGFlashTimer], a
	ld   a, $E1				; Use normal palette, matches one set before
	ldh  [rBGP], a
	
	; If we're done with flashing the palette, prepare the wave effect
	ld   a, [wEndLoopsLeft]
	dec  a
	ld   [wEndLoopsLeft], a
	cp   a, $00
	ret  nz
	
.showGenie:
	xor  a
	ld   [wEndHeldLstId], a		; Hide lamp sprite since it's part of the BG tilemap
	ld   [wEndCloudLstId], a	; Not necessary
	ld   a, $1E					; Timer++
	ld   [wEndBGFlashTimer], a
	ld   a,  LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_WTILEMAP|LCDC_ENABLE	; Hide WINDOW, which will make the BG (and the genie) visible
	ldh  [rLCDC], a
	ret
	
; =============== Ending_DoWaveEffect ===============
; Performs the wave parallax effect for the part of the screen where the genie is.
; This takes exclusive effect until it's done, where it switches to the next mode.
;
; See also: Act_SyrupCastleBoss_DoWaveEffectSoft
Ending_DoWaveEffect:
	; BC = Amount of times execution should loop to .loop.
	;      When it's $00, the effect stops.
	;
	;      This doesn't accurately map to any frame or scanline count.
	ld   bc, $E000
	
.loop:
	; [BUG] There's no HBlank check anywhere here, which causes the wave effect to be imprecise,
	;       since LY may change in the middle of the loop.
	
	
	;
	; If the current scanline value is >= $50, we're below the genie.
	; Skip performing the parallax effect for the remainder of the frame.
	;
	ldh  a, [rLY]
	cp   a, $50			; LY >= $50?
	jr   nc, .noWave	; If so, jump
	
	
	;--
	
	; Calculate the *scanline-based* table index for this specific row.
	; DE = rLY % $10
	;      TIMER TableSize/2
	;
	; This value will be added over to another value (that also has a cap of $10).
	; This makes the max reachable value $1F
	;
	; Because this is tied to rLY, it will increase by one when it processes a new line.
	; As the values in the table are in a specific pattern, this will cause a wave-like scrolling effect.
	;
	and  a, $0F	
	ld   d, $00			
	ld   e, a
	
	;
	; Determine the table to use for the wave effect.
	; When the effect first starts, it uses a table with more pronounced waves.
	; Around the halfway point (LoopsLeft < $6000), it switches to smaller waves.
	;
	; Save to HL the pointer to the start of the picked table.
	;
	ld   a, b
	cp   a, $60				; BC >= $6000?
	jr   nc, .useHardWaves	; If so, use large waves
						
.useSoftWaves:
	; HL = Base offset for wave effect table
	ld   hl, Ending_WaveSoftTbl	
	jr   .getScrollX
.useHardWaves:;R
	; HL = Base offset for wave effect table
	ld   hl, Ending_WaveHardTbl
.getScrollX:

	; Calculate the effective index, by adding a *frame-based* index to the scanline one.
	;
	; The frame-based index increases by 1 every time the frame ends, which makes it look
	; like the waves are moving up (since it reads one pattern after the normal value, and so on)
	; Like the scanline index, this one is also capped to $0F, which prevents from 
	; reading past the end of the table.
	;
	; The effective index is calculated like this:
	; DE = (wEndBGWaveOffset % $10) + (rLY % $10)
	;      FrameIndex               + ScanlineIndex (previously set to E)
	;
	ld   a, [wEndBGWaveOffset]	; A
	and  a, $0F
	add  e
	ld   e, a
	; With that done, save the new X scroll value
	add  hl, de					; Offset the table by DE
	ld   a, [hl]				; Index the rSCX value
	ldh  [rSCX], a				; And write it out
	jr   .chkEffectEnd
	
.noWave:
	xor  a						; Reset scroll to normal
	ldh  [rSCX], a
.chkEffectEnd:

	; If we've reached the end of the frame, wait in that subroutine.
	ldh  a, [rLY]
	cp   a, LY_VBLANK+$06
	call z, Ending_DoWaveEffect_WaitEndFrame
	
	; If we've gone through all $E000 iterations, end the effect.
	dec  bc			; LoopsLeft--
	ld   a, b
	or   a, c		; LoopsLeft == 0?
	jr   nz, .loop	; If not, loop
	
	xor  a			
	ld   [wEndBGFlashTimer], a	; End flash
	ldh  [rSCX], a				; Reset scroll offset
	ld   a, [wEndAct]			; Next mode
	inc  a
	ld   [wEndAct], a
	ret
	
; =============== Act_SyrupCastleBoss_WaveSoftTbl ===============
Ending_WaveSoftTbl: 
	db +$04,+$07,+$09,+$0A,+$0A,+$09,+$07,+$04
	db -$04,-$07,-$09,-$0A,-$0A,-$09,-$07,-$04
	db +$04,+$07,+$09,+$0A,+$0A,+$09,+$07,+$04
	db -$04,-$07,-$09,-$0A,-$0A,-$09,-$07
	db -$04 ; [POI] Cut off, not used

; =============== Act_SyrupCastleBoss_WaveSoftTbl ===============
Ending_WaveHardTbl:
	db +$08,+$0E,+$12,+$14,+$14,+$12,+$0E,+$08
	db -$08,-$0E,-$12,-$14,-$14,-$12,-$0E,-$08
	db +$08,+$0E,+$12,+$14,+$14,+$12,+$0E,+$08
	db -$08,-$0E,-$12,-$14,-$14,-$12,-$0E
	db -$08 ; [POI] Cut off, not used

; =============== Ending_DoWaveEffect_WaitEndFrame ===============
; Handles the end of the frame. for the wave effect.
Ending_DoWaveEffect_WaitEndFrame:

	;--
	; This is similar to the broken code in Act_SyrupCastleBoss_DoWaveEffect_WaitEndFrame,
	; except with a different target.
	;
	; This time it doesn't really matter since the correct check is made before
	; calling the subroutine anyway. However, this subroutine is always called when
	; LY reaches LY_VBLANK+$06, so this waiting loop makes it wait one more frame.
.wait:
	ldh  a, [rLY]
	cp   a, LY_VBLANK+$06
	jr   z, .wait
	;--
	ld   a, [wEndBGWaveOffset]	; Increase frame index
	inc  a
	ld   [wEndBGWaveOffset], a
	
	push bc
	call HomeCall_Sound_DoStub	; Execute the sound code
	pop  bc
	ret
	
; =============== Ending_PreTr_PlBump ===============
; Handles the player bump effect after the genie appears.
Ending_PreTr_PlBump:
	; NOTE: wStaticPlAnimTimer is reused as index for the path table in .movePl.
	;       Since it's first called when the timer reaches $03, its first three
	;		bytes go unused (and are dummy bytes anyway).
	ld   a, [wStaticPlAnimTimer]
	inc  a
	ld   [wStaticPlAnimTimer], a
	
	; When the player is in the air, the hat is separated from the player (while
	; still being in the same anim. frame).
	; A few frames after the player reaches the ground, return things to normal,
	; but still in the bump anim.
	cp   a, $03				; Timer < $03?
	jr   c, .useFrame0		; If so, use bump frame (with the hat separated)
	cp   a, $28				; Timer >= $03 && Timer < $28?
	jr   c, .movePl			; If so, move the player for the bump effect
	cp   a, $37				; Timer == $37?
	jr   z, .useFrame1		; If so, use bump frame (normal)
	cp   a, $46
	jr   z, .nextMode
	ret
.useFrame0:
	ld   a, SFX1_1A
	ld   [sSFX1Set], a
	ld   a, OBJ_ENDING_WARIO_BUMP0
	ld   [wStaticPlLstId], a
	ret
.useFrame1:
	ld   a, OBJ_ENDING_WARIO_BUMP1
	ld   [wStaticPlLstId], a
	ret
.nextMode:
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   a, $0A
	ld   [wEndLoopsLeft], a			; Next OBJ anim sequence loops 10 times
	ld   [wStaticPlLstId], a		; OBJ_STATIC_WARIO_IDLEDIAG
	ld   a, END1_RTN_GENIETALK		; Next mode
	ld   [wEndAct], a
	ret
.movePl:
	;
	; Move player right 1px/frame
	;
	ld   a, [wStaticPlX]			; Move player right
	dec  a
	ld   [wStaticPlX], a
	
	;
	; Move player vertically based on the path table.
	;
	ld   hl, Ending_PlBumpYPath		; HL = Ptr to YPath	table	
	ld   a, [wStaticPlAnimTimer]	; BC = wStaticPlAnimTimer
	ld   b, $00
	ld   c, a
	add  hl, bc						; Offset it by BC
	
	ld   a, [wStaticPlY]			; PlY -= Ending_PlBumpYPath[wStaticPlAnimTimer]
	sub  a, [hl]
	ld   [wStaticPlY], a
	ret
	
; =============== Ending_PlBumpYPath ===============
; Vertical offsets to wStaticPlY, for the path Wario takes in the bump animation.
; As seen above, each entry is *subtracted* to the player's Y position.
; Most paths work by having each entry added to the player's Y position, but not this one.
;
; [POI] Dummy bytes are marked as ;X, which aren't used since the index never
;       reaches the value when calling .movePl.
Ending_PlBumpYPath: 
	db +$00;X
	db +$00;X
	db +$00;X
	db +$01,+$01,+$01,+$01,+$01					; $08
	db +$01,+$01,+$01,+$01,+$01,+$01,+$00,+$01	; $10
	db +$00,+$01,+$00,+$01,+$00,+$00,+$00,-$01	; $18
	db -$00,-$01,-$00,-$01,-$00,-$01,-$01,-$01	; $20
	db -$01,-$01,-$01,-$01,-$01,-$01,-$01,-$01	; $28
	db $00;X
	db $00;X
	db $00;X
	db $00;X
	
; =============== Ending_PreTr_GenieTalk ===============
; Handles the timing sequence when the Genie first talks.
Ending_PreTr_GenieTalk:
	ld   a, [wEndGenieTimer]
	inc  a
	ld   [wEndGenieTimer], a
	;
	; This sequence involves having the genie do different hand gestures.
	; While that happens, we regularly update the genie's face, to have the
	; mouth open and close every $0F frames.
	; 
	; The timer loops $0A times from $5A back to $3C, where at the end
	; of each loop a new hand gesture may be picked.
	;
	cp   a, $3C
	jr   z, .openMouth
	cp   a, $3C+$0F
	jr   z, .closeMouth
	cp   a, $3C+$0F+$0F
	jr   z, .closeMouth_chkLoop
	cp   a, $96
	jr   z, .nextMode
	ret
.openMouth:
	ld   a, SFX1_32
	ld   [sSFX1Set], a
	ld   a, END_OBJ_GENIEFACE_LOOKMOUTH
	ld   [wEndGenieFaceLstId], a
	ret
.closeMouth:
	ld   a, END_OBJ_GENIEFACE_LOOK
	ld   [wEndGenieFaceLstId], a
	ret
.closeMouth_chkLoop:
	ld   a, $3C							; Loop back to .openMouth
	ld   [wEndGenieTimer], a
	ld   a, END_OBJ_GENIEFACE_LOOKMOUTH
	ld   [wEndGenieFaceLstId], a
	
	; Depending on how many loops are left, choose a different hand frame.
	; This acts as a timing sequence.
	ld   a, [wEndLoopsLeft]
	dec  a
	ld   [wEndLoopsLeft], a
	cp   a, $08
	jr   z, .setHandPalmFrame
	cp   a, $06
	jr   z, .setHandClosedFrame
	cp   a, $04						
	jr   z, .setHandPointFrame
	cp   a, $00
	ret  nz
.noLoopsLeft:
	; If there are no loops left, increase the genie talk timer, which
	; unlocks
	ld   a, SFX_NONE
	ld   [sSFX1Set], a
	ld   a, $64
	ld   [wEndGenieTimer], a
	ld   a, $01
	ld   [wEndGenieFaceLstId], a
	ld   [wEndGenieHandLFrameSet], a
	ret
.setHandPalmFrame:
	ld   a, END_GENIE_PALM
	ld   [wEndGenieHandLFrameSet], a
	ret
.setHandClosedFrame:
	ld   a, END_GENIE_CLOSED
	ld   [wEndGenieHandLFrameSet], a
	ret
.setHandPointFrame:
	ld   a, END_GENIE_POINT
	ld   [wEndGenieHandLFrameSet], a
	ret
.nextMode:
	xor  a
	ld   [wEndGenieTimer], a
	ld   a, $05						; Animate think bubble for 5 loops next mode
	ld   [wEndLoopsLeft], a
	ld   a, END1_RTN_THINKWISH		; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_PreTr_ThinkWish ===============
; Wario thinks of a wish, with a think bubble.
Ending_PreTr_ThinkWish:
	call Ending_DoGenieBlinkAnim
	ld   a, [wStaticPlAnimTimer]
	inc  a
	ld   [wStaticPlAnimTimer], a
	cp   a, $32
	jr   z, .plWish
	;--
	; This section animating the cloud inside the balloon loops $05 times
	cp   a, $50
	jr   z, .animThinkCloud0
	cp   a, $64
	jr   z, .animThinkCloud1
	cp   a, $78
	jr   z, .animThinkCloud0_chkLoop
	;--
	cp   a, $AA
	jr   z, .thinkCastle
	cp   a, $DC
	jr   z, .setJump_nextMode
	ret
.plWish:
	ld   a, OBJ_ENDING_WARIO_WISHCLOSE
	ld   [wStaticPlLstId], a
	ld   a, $01
	ld   [wEndBalloonLstId], a		; Draw arrow for END_OBJ_BALLOONTHINK
	ld   [wEndBalloonFrameSet], a	; Request BG write for balloon border
	ld   [sSFX1Set], a 				; Play think SFX1_01
	ret
.animThinkCloud0:
	ld   a, END_OBJ_CLOUDC0
	ld   [wEndCloudLstId], a
	; Position cloud inside the balloon
	ld   a, $1C						
	ld   [wEndCloud0X], a
	ld   a, $34
	ld   [wEndCloud0Y], a
	ret
.animThinkCloud1:
	ld   a, END_OBJ_CLOUDC1
	ld   [wEndCloudLstId], a
	ret
.animThinkCloud0_chkLoop:
	ld   a, SFX1_19
	ld   [sSFX1Set], a
	ld   a, $50						; Loop back to .animThinkCloud0...
	ld   [wStaticPlAnimTimer], a
	ld   a, END_OBJ_CLOUDC0
	ld   [wEndCloudLstId], a
	
	; If we don't have any loops left though
	ld   a, [wEndLoopsLeft]
	dec  a
	ld   [wEndLoopsLeft], a
	ret  nz
.endThinkCloud:
	; Restore the original timer value, which allows the timing sequence to continue
	ld   a, $78
	ld   [wStaticPlAnimTimer], a
	xor  a								; Hide cloud
	ld   [wEndCloudLstId], a
	ld   a, OBJ_ENDING_WARIO_WISHOPEN	; Open player eyes
	ld   [wStaticPlLstId], a
	ret
.thinkCastle:;R
	ld   a, SFX1_08
	ld   [sSFX1Set], a
	ld   a, $02							; Req. draw castle inside balloon
	ld   [wEndBalloonFrameSet], a
	ret
.setJump_nextMode:
	; Setup the next mode
	ld   a, SFX1_05
	ld   [sSFX1Set], a					; Play jump SFX
	xor  a
	ld   [wStaticPlAnimTimer], a		; Reset
	ld   [wEndGenieTimer], a		; ""
	ld   a, OBJ_ENDING_WARIO_JUMPDIAG	; Jump frame
	ld   [wStaticPlLstId], a
	ld   a, END_OBJ_GENIEFACE_LOOK		; Reset genie face
	ld   [wEndGenieFaceLstId], a
	ld   a, END_OBJ_BALLOONSPEAK		; Change think balloon to speak balloon
	ld   [wEndBalloonLstId], a
	ld   [wEndLoopsLeft], a				; Make player jump twice
	ld   a, END1_RTN_PLJUMP				; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_DoGenieBlinkAnim ===============
; Handles the animation to make the genie blink every $10 frames.
Ending_DoGenieBlinkAnim:
	ld   a, [wEndGenieTimer]	; AnimTimer++
	inc  a
	ld   [wEndGenieTimer], a
	cp   a, $10
	jr   z, .closeEyes
	cp   a, $20
	jr   z, .openEyes_reset
	ret
.closeEyes:
	ld   a, END_OBJ_GENIEFACE_BLINK
	ld   [wEndGenieFaceLstId], a
	ret
.openEyes_reset:
	xor  a							; Reset AnimTimer to $00
	ld   [wEndGenieTimer], a
	ld   a, END_OBJ_GENIEFACE_LOOK
	ld   [wEndGenieFaceLstId], a
	ret
	
; =============== Ending_DoPlJump ===============
; Handles Wario's jump animation in the ending scene.
; When the jump is repeated the specified amount of times (wEndLoopsLeft),
; it switches to the next submode.
Ending_DoPlJump:

	;
	; Handle the vertical movement during the jump, through a path table
	; of *absolute* vertical positions, indexed by wStaticPlAnimTimer.
	;
	ld   a, [wStaticPlAnimTimer]	; C = Index
	ld   c, a
	
	; If the index is out of range, stop this jump and check if we're done.
	cp   a, (Ending_PlJumpYPath.end-Ending_PlJumpYPath)	; Index >= $34?
	jr   nc, .chkEnd				; If so, jump
	
	inc  a							; Index++
	ld   [wStaticPlAnimTimer], a
	; Set the player's position based off the path table
	ld   hl, Ending_PlJumpYPath		; HL = Path table
	ld   b, $00						; BC = Index
	add  hl, bc						; Offset it
	ld   a, [hl]					; A = New player Y position
	ld   [wStaticPlY], a			; Set that
	ret
	
.chkEnd:
	inc  a						
	ld   [wStaticPlAnimTimer], a
	
	;--
	; [POI] The index never gets this high. What's this here for?
	cp   a, $3C
	jr   z, .newJump
	;--
	
	ld   a, OBJ_STATIC_WARIO_IDLEDIAG	; Set idle anim in case we're done jumping
	ld   [wStaticPlLstId], a
	
	; If there are no more jumps left, switch to the next mode
	ld   a, [wEndLoopsLeft]				; JumpsLeft--
	dec  a
	ld   [wEndLoopsLeft], a				; JumpsLeft == 0?
	jr   z, .nextMode					; If so, jump
	
	; Otherwise prepare a new jump sequence
.newJump:
	ld   a, SFX4_08						; [POI] Play walk SFX. Is this intentional?
	ld   [sSFX4Set], a
	xor  a								; Reset path table index
	ld   [wStaticPlAnimTimer], a
	ld   a, OBJ_ENDING_WARIO_JUMPDIAG	; Set back jump frame
	ld   [wStaticPlLstId], a
	ret
	
.nextMode:
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   a, [wEndAct]
	inc  a
	ld   [wEndAct], a
	ret
	
; =============== Ending_PlJumpYPath ===============
; Path containing the player's position when jumping in the ending screen.
;
; Because this uses *absolute* offsets and it gets reused in both the genie
; and credits scenes, the tilemaps need to accomodate for this on where the ground is.
Ending_PlJumpYPath:
	db $60,$5E,$5C,$5A,$59,$58,$57,$56,$55,$54,$53,$53,$52,$52,$51,$51 ; $10
	db $50,$50,$50,$51,$51,$52,$52,$53,$53,$54,$55,$56,$57,$58,$59,$5A ; $20
	db $5C,$5E,$60,$62 ; $24
.end:

; =============== Ending_PreTr_GenieMoney ===============
; The genie speaks about wanting money for the wish.
Ending_PreTr_GenieMoney:
	
	; Primary timing sequence for the talking animation
	ld   a, [wEndGenieTimer]
	inc  a
	ld   [wEndGenieTimer], a
	cp   a, $32
	jr   z, .init
	;--
	; This will loop 9 times
	cp   a, $41
	jr   z, .openMouth
	cp   a, $50
	jr   z, .closeMouth_chkEnd
	;--
	ret
.init:
	xor  a							; Hide balloon pointer
	ld   [wEndBalloonLstId], a
	ld   a, $03						; Req. delete word balloon from tilemap
	ld   [wEndBalloonFrameSet], a
	ld   a, $09						; Initialize loop count
	ld   [wEndLoopsLeft], a
	ret
.openMouth:
	ld   a, END_OBJ_GENIEFACE_LOOKMOUTH
	ld   [wEndGenieFaceLstId], a
	
	;--
	; If this is the last loop, play a SFX
	ld   a, [wEndLoopsLeft]
	cp   a, $09
	ret  nz
	ld   a, SFX1_32					
	ld   [sSFX1Set], a
	ret
.closeMouth_chkEnd:
	; Reset timer to $32
	; This is the earliest possible value to skip .init.
	ld   a, $32						
	ld   [wEndGenieTimer], a
	
	ld   a, END_OBJ_GENIEFACE_LOOK	; Set mouth closed
	ld   [wEndGenieFaceLstId], a
	
	; Handle the secondary timing sequence with the genie's hands/word balloon
	ld   a, [wEndLoopsLeft]			; LoopsLeft--
	dec  a
	ld   [wEndLoopsLeft], a
	cp   a, $07
	jr   z, .setHandPalm
	cp   a, $06
	jr   z, .speakMoneybag
	cp   a, $00
	ret  nz
.nextMode:
	ld   a, SFX_NONE					; Cut off SFX1_32
	ld   [sSFX1Set], a
	xor  a
	ld   [wEndGenieTimer], a
	ld   a, $02							; Set loop count for Wario "nod" anim.
	ld   [wEndLoopsLeft], a
	ld   a, END1_RTN_PLNOD				; Next mode
	ld   [wEndAct], a
	ret
.setHandPalm:
	ld   a, END_GENIE_PALM				; Open hand on the left
	ld   [wEndGenieHandLFrameSet], a
	ret
.speakMoneybag:
	ld   a, END_OBJ_HELD_MONEYBAG1
	ld   [wEndHeldLstId], a				; Draw moneybag sprite
	ld   [wEndBalloonLstId], a			; END_OBJ_BALLOONGENIE
	ld   a, $01							; Request tilemap update
	ld   [wEndBalloonFrameSet], a
	; Place moneybag inside word balloon
	ld   a, $1C
	ld   [wEndHeldX], a
	ld   a, $34
	ld   [wEndHeldY], a
	ret
	
; =============== Ending_AnimPlNod ===============
; Handles Wario's nod animation in the ending scene.
; When this is repeated the specified amount of times (wEndLoopsLeft),
; it switches to the next submode.
Ending_AnimPlNod:
	ld   a, [wStaticPlAnimTimer]
	inc  a
	ld   [wStaticPlAnimTimer], a
	;--
	; Loops 2 times
	cp   a, $1E
	jr   z, .setIdleFrame
	cp   a, $32
	jr   z, .setDiagFrame_chkLoop
	;--
	; After waiting $50-$32 frames when the loop ends...
	cp   a, $50
	jr   z, .nextMode
	ret
.setIdleFrame:
	ld   a, SFX1_19
	ld   [sSFX1Set], a
	ld   a, OBJ_STATIC_WARIO_IDLE
	ld   [wStaticPlLstId], a
	ret
.setDiagFrame_chkLoop:
	xor  a								; Reset timer for loop initially
	ld   [wStaticPlAnimTimer], a
	ld   a, OBJ_STATIC_WARIO_IDLEDIAG
	ld   [wStaticPlLstId], a
	
	; If there are no loops left, restore the timer value
	ld   a, [wEndLoopsLeft]				; LoopCount--
	dec  a
	ld   [wEndLoopsLeft], a				; LoopCount != 0?
	ret  nz								; If so, return
	ld   a, $32							; Otherwise, end the loop
	ld   [wStaticPlAnimTimer], a
	ret
.nextMode:
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   a, [wEndAct]
	inc  a
	ld   [wEndAct], a
	ret
	
; =============== Ending_PreTr_WalkLeft ===============
; Makes the player walk left, until reaching off-screen.
Ending_PreTr_WalkLeft:

	;
	; Wait $33 frames before starting to walk left.
	;
	ld   a, [wEndPlMoveLDelay]
	cp   a, $33					; Timer == $33?
	jr   z, .moveL				; If so, jump
	inc  a						; Otherwise, timer++
	ld   [wEndPlMoveLDelay], a
	
.waitPrep:
	;
	; Wait for $28 frames before doing removing the speak bubble.
	; 4 frames later setup the walk animation to the left.
	;
	cp   a, $32						; Timer == $32?
	jr   z, .initWalk				; If so, jump
	cp   a, $28						; Timer == $28?
	ret  nz							; If not, return
.clrBalloon:
	xor  a
	ld   [wEndHeldLstId], a				; Remove speak balloon content
	ld   [wEndBalloonLstId], a			; Remove speak balloon arrow
	ld   a, $01							; Close genie hand
	ld   [wEndGenieHandLFrameSet], a
	ld   a, $03							; Remove speak balloon BG tilemap
	ld   [wEndBalloonFrameSet], a
	ret
.initWalk:
	ld   a, BGMACT_FADEOUT			; Fade out current song
	ld   [sBGMActSet], a
	ld   a, STATIC_OBJLST_XFLIP		; Face left
	ld   [wStaticPlFlags], a
	ret
	
.moveL:
	; Move player left until reaching the target position (off-screen left)
	ld   a, [wStaticPlX]			; PlX--
	dec  a
	ld   [wStaticPlX], a
	cp   a, $E0						; Player offscreen?
	jp   nz, Static_Pl_WalkAnim		; If not, animate walk 
	
	; Otherwise, signal out that this part of the cutscene is done playing.
	; This will cause Mode_Ending_GenieCutscene to switch to the treasure room.
	ld   a, $01					
	ld   [sEndingRetVal], a
	
	; Set the new submode for the next time we get to Ending_Do,
	; after the exiting the treasure room.
	ld   a, $02					
	ld   [wEndingMode], a
	ret
	
; =============== Ending_InitPostTr ===============
; Initializes the second part of ending scene, after returning from the treasure room.
Ending_InitPostTr:
	call StopLCDOperation
	call ClearBGMapEx
	call ClearWorkOAM
	; Load GFX and tilemaps
	ld   hl, GFXRLE_EndingA
	call DecompressGFXStub
	ld   hl, BGRLE_Ending_CutsceneGenie
	call DecompressBG_ToBGMap
	call Ending_InitVars
	
	; Keep WINDOW disabled
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	ldh  [rLCDC], a
	
	; Set the sprite mapping id for the amount of moneybags we're holding.
	; This uses ids $02-$08 of the "held object" sprite mapping list, 
	; which are already ordered, so...
	ld   a, [sTrRoomMoneybagCount]		; SpriteId = MoneyBagCount + $02
	add  $02
	ld   [wEndHeldLstId], a
	; Set initial position of the moneybags (off-screen left near player)
	ld   a, $E5
	ld   [wEndHeldX], a
	ld   a, $54
	ld   [wEndHeldY], a
	
	ld   a, END_OBJ_GENIEFACE_LOOK	; Look at player
	ld   [wEndGenieFaceLstId], a
	ld   a, BGM_COURSE3				; Play C03 BGM
	ld   [sBGMSet], a
	ld   a, END_RTN_POSTTR			; Next mode
	ld   [wEndingMode], a
	ret
	
; =============== Ending_PostTr ===============
Ending_PostTr:
	ld   a, [wEndAct]
	rst  $28
	dw Ending_PostTr_WalkInR
	dw Ending_PostTr_WantMoney
	dw Ending_PostTr_ThrowMoneybags
	dw Ending_PostTr_FlyMoneybags
	dw Ending_PostTr_FlashBG
	dw Ending_PostTr_PointSpeak
	dw Ending_PostTr_PlNod
	dw Ending_PostTr_MoveOutR
	
; =============== Ending_PostTr_WalkInR ===============
; Moves the player right while holding the moneybags, starting off-screen,
; until around the left of the genie.
Ending_PostTr_WalkInR:
	;
	; Move player and moneybags right, until reaching X pos $15
	;
	ld   a, [wEndHeldX]		; Move held moneybags
	inc  a
	ld   [wEndHeldX], a
	ld   a, [wStaticPlX]	; Move player
	inc  a
	ld   [wStaticPlX], a
	cp   a, $15				; Target reached?
	jp   nz, Ending_Pl_WalkHoldAnim	; If not, continue walking
	
.nextMode:
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   a, OBJ_ENDING_WARIO_IDLEHOLD	; Stop moving
	ld   [wStaticPlLstId], a
	ld   a, $53					; Fix Y position of held moneybags
	ld   [wEndHeldY], a
	ld   a, $04					; Loop genie talk anim 5 times
	ld   [wEndLoopsLeft], a
	ld   a, END2_RTN_WANTMONEY	; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_PostTr_WantMoney ===============
; The genie requests money from Wario.
; Note that the genie just talks for most of this mode, and opens the
; palm only when switching to the next mode.
Ending_PostTr_WantMoney:
	; Handle the timing loop for talking
	ld   a, [wEndGenieTimer]
	inc  a
	ld   [wEndGenieTimer], a
	cp   a, $28
	jr   z, .closeMouth
	;--
	; Loops $3C-$5A 4 times
	; This alternates between mappings every $0F frames.
	cp   a, $4B
	jr   z, .openMouth
	cp   a, $4B+$0F; $5A
	jr   z, .closeMouth_checkEnd
	;--
	ret
.closeMouth:
	ld   a, END_OBJ_GENIEFACE_LOOK
	ld   [wEndGenieFaceLstId], a
	ret
.openMouth:
	ld   a, END_OBJ_GENIEFACE_LOOKMOUTH
	ld   [wEndGenieFaceLstId], a
	; Play a SFX the first time we get here
	ld   a, [wEndLoopsLeft]
	cp   a, $04
	ret  nz
	ld   a, SFX1_32
	ld   [sSFX1Set], a
	ret
	
.closeMouth_checkEnd:
	ld   a, $4B-$0F ;$3C			; Reset timer				
	ld   [wEndGenieTimer], a
	ld   a, END_OBJ_GENIEFACE_LOOK
	ld   [wEndGenieFaceLstId], a
	
	; If there are no loops left, switch to the next mode
	ld   a, [wEndLoopsLeft]
	dec  a
	ld   [wEndLoopsLeft], a
	ret  nz
.nextMode:
	ld   a, SFX_NONE					; Cut off any SFX
	ld   [sSFX1Set], a
	xor  a
	ld   [wEndGenieTimer], a
	ld   a, END_GENIE_PALM				; Open palm (where the moneybags land)
	ld   [wEndGenieHandLFrameSet], a
	ld   a, END2_RTN_THROWMONEYBAGS		; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_PostTr_ThrowMoneybags ===============
; Wario waits for a bit, then gives the moneybags to the genie.
Ending_PostTr_ThrowMoneybags:
	;
	; Wait until the timer reaches $29 before throwing them.
	; (which takes $28 frames)
	;
	ld   a, [wEndThrowDelay]
	cp   a, $29					; Timer == $29?
	jr   z, .moveMoneybags		; If so, jump
	inc  a						; Otherwise, Timer++
	ld   [wEndThrowDelay], a
	; If we're about to reach $29, init things
	cp   a, $28
	ret  nz
	
	ld   a, SFX1_0C				; Play throw SFX
	ld   [sSFX1Set], a
	ld   a, $29					; Skips ahead by one
	ld   [wEndThrowDelay], a
	ld   a, OBJ_ENDING_WARIO_IDLETHROW	; Set throw anim
	ld   [wStaticPlLstId], a
	ret
.moveMoneybags:
	
	;
	; VERTICAL MOVEMENT
	;

	;
	; wStaticPlAnimTimer is reused as index to a path table.
	; Like other path tables in the ending, it specifies fixed Y
	; positions that overwrite the current one.
	;
	
	; If we're out of range, we're done
	ld   a, [wStaticPlAnimTimer]
	cp   a, $1A
	jr   z, .nextMode
	
	ld   c, a						; BC = Index
	inc  a							; Index++
	ld   [wStaticPlAnimTimer], a
	ld   hl, Ending_MoneybagThrowYPath	; HL = Ptr to path tablr
	ld   b, $00
	add  hl, bc						; Offset the table
	ld   a, [hl]					; A = New Y value for the moneybags
	ld   [wEndHeldY], a				; Set it
	
	;
	; Always move right the moneybags at 1px/frame
	;
	ld   a, [wEndHeldX]
	inc  a
	ld   [wEndHeldX], a
	ret
.nextMode:
	xor  a							; Reset vars
	ld   [wStaticPlAnimTimer], a
	ld   [wEndThrowDelay], a
	ld   a, OBJ_STATIC_WARIO_IDLEDIAG	; Set normal idle look-up frame
	ld   [wStaticPlLstId], a
	ld   a, $03						; Loop genie hand anim 3 times next
	ld   [wEndLoopsLeft], a
	ld   [wEndAct], a				; Next mode -- END2_RTN_FLYMONEYBAGS
	ret
	
; =============== Ending_MoneybagThrowYPath ===============
Ending_MoneybagThrowYPath: 
	db $50,$48,$40,$3A,$34,$30,$2C,$2A,$28,$26,$24,$22,$20,$1F,$1E,$1D ; $10
	db $1C,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$25 ; $1A
	
; =============== Ending_PostTr_FlyMoneybags ===============
; The moneybags fly away and the genie moves his hands.
Ending_PostTr_FlyMoneybags:

	; Handle the timing sequence.
	
	; First, move up the moneybags when the timer reaches $33
	call Ending_MoveMoneybagsUp
	
	ld   a, [wEndGenieTimer]	; Timer++
	inc  a
	ld   [wEndGenieTimer], a
	
	; After enough time so the moneybags can get off-screen,
	; move the genie's hands 3 times.
	cp   a, $8C
	jr   z, .lookDown_openHands
	;--
	; Looping $8C-$B4 3 times.
	; (altermating every $14 frames)
	cp   a, $A0
	jr   z, .closeHands
	cp   a, $A0+$14 ;$B4
	jr   z, .openHands_checkEnd
	;--
	ret
.lookDown_openHands:;R
	ld   a, SFX1_18	
	ld   [sSFX1Set], a
	xor  a							; Look down (hide sprite, using what's baked in the tilemap)
	ld   [wEndGenieFaceLstId], a
	ld   a, END_GENIE_PALM			; Set open both hands
	jr   .setHands
.closeHands:
	ld   a, END_GENIE_CLOSED		; Close both hands
.setHands:
	ld   [wEndGenieHandLFrameSet], a
	ld   [wEndGenieHandRFrameSet], a
	ret
	
.openHands_checkEnd:
	ld   a, SFX1_18					; Play hand move SFX
	ld   [sSFX1Set], a
	ld   a, $A0-$14 ;$8C			; $14 frames before .closeHands
	ld   [wEndGenieTimer], a
	ld   a, END_GENIE_PALM			; Set open both hands
	ld   [wEndGenieHandLFrameSet], a
	ld   [wEndGenieHandRFrameSet], a
	
	; If we've looped all 3 times, switch to the next mode
	ld   a, [wEndLoopsLeft]			; LoopsLeft--
	dec  a
	ld   [wEndLoopsLeft], a			; LoopsLeft != 0?
	ret  nz							; If so, return
	
.nextMode:
	xor  a							; Reset timer for next sequence
	ld   [wEndGenieTimer], a
	ld   a, $08						; Flash screen 8 times next
	ld   [wEndLoopsLeft], a
	ld   a, END2_RTN_FLASHBG		; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_MoveMoneybagsUp ===============
; Makes the moneybags move up after they have been given to the genie.
Ending_MoveMoneybagsUp:
	;
	; Don't make the moneybags move up until the timer reaches $33.
	; One frame before that, play a SFX.
	;
	ld   a, [wEndGenieTimer]
	cp   a, $32				; Timer == $32?
	jr   z, .playSFX		; If so, jump
	ret  c					; Timer < $32? If so, return
	
.moveUp:
	; Move up the moneybags at 2px/frame, until we're off-screen
	; [BUG] But it doesn't matter.
	;       $AF appears to be a typo of $CF, since it doesn't make sense
	;       to move hidden moneybags.
	ld   a, [wEndHeldY]
	cp   a, $AF				; YPos == $AF?
	ret  z					; If so, stop moving
	
	dec  a					; YPos -= 2
	dec  a
	ld   [wEndHeldY], a
	
	; When the moneybags are off-screen, hide them
	cp   a, $CF				; YPos != $CF?
	ret  nz					; If so, return
	xor  a					; Otherwise, blank their sprite
	ld   [wEndHeldLstId], a
	ret
.playSFX:
	ld   a, SFX1_1E
	ld   [sSFX1Set], a
	ret
	
; =============== Ending_PostTr_FlashBG ===============
; Makes the background flash, then performs the wave effect.
Ending_PostTr_FlashBG:

	; Execute the wave effect when the timer reaches $1E.
	; When it's done, it will switch to the next mode.
	ld   a, [wEndGenieTimer]
	cp   a, $1E
	jp   z, Ending_DoWaveEffect
	inc  a
	ld   [wEndGenieTimer], a
	
	; Time the palette inversion sequence
	;--
	; Loops 8 times before allowing to reach $1E
	cp   a, $0A
	jp   z, Ending_FlashBG_UseInvPal
	cp   a, $14
	jr   z, .useNormPal
	;--
	ret
.useNormPal:
	xor  a
	ld   [wEndGenieTimer], a
	ld   a, $E1						; Use normal palette, matches one set before
	ldh  [rBGP], a
	
	; If we're done with flashing the palette, set the timer to run the wave effect
	ld   a, [wEndLoopsLeft]
	dec  a
	ld   [wEndLoopsLeft], a
	cp   a, $00
	ret  nz
.setToWave:
	ld   a, $1E
	ld   [wEndGenieTimer], a
	ret
	
; =============== Ending_PostTr_PointSpeak ===============
; Genie points to the wish and speaks one last time.
Ending_PostTr_PointSpeak:

	ld   a, [wEndGenieTimer]
	inc  a
	ld   [wEndGenieTimer], a
	cp   a, $01
	jr   z, .closeHands
	cp   a, $28
	jr   z, .lookLeft
	cp   a, $64
	jr   z, .pointRight_initLoop
	;--
	; Loop 4 times
	; Alternating every $0F frames.
	cp   a, $73
	jr   z, .openMouth
	cp   a, $73+$0F
	jr   z, .closeMouth_chkEnd
	ret
.closeHands:
	ld   a, END_GENIE_CLOSED			; Close both hands
	ld   [wEndGenieHandLFrameSet], a
	ld   [wEndGenieHandRFrameSet], a
	ret
.lookLeft:
	ld   a, END_OBJ_GENIEFACE_LOOK
	ld   [wEndGenieFaceLstId], a
	ret
.pointRight_initLoop:
	ld   a, END_GENIE_POINT
	ld   [wEndGenieHandRFrameSet], a
	ld   a, $04							; Talk anim loop count
	ld   [wEndLoopsLeft], a
	ret
.openMouth:
	ld   a, END_OBJ_GENIEFACE_LOOKMOUTH	; Open mouth
	ld   [wEndGenieFaceLstId], a
	;--
	; The first time we get here, play a SFX
	ld   a, [wEndLoopsLeft]
	cp   a, $04
	ret  nz
	ld   a, SFX1_32
	ld   [sSFX1Set], a
	;--
	ret
.closeMouth_chkEnd:
	ld   a, $73-$0F ;$64				; Reset timer $0F before .openMouth
	ld   [wEndGenieTimer], a
	ld   a, END_OBJ_GENIEFACE_LOOK		; Close mouth
	ld   [wEndGenieFaceLstId], a
	
	; If we're done looping, switch to the next mode
	ld   a, [wEndLoopsLeft]
	dec  a
	ld   [wEndLoopsLeft], a
	ret  nz
.nextMode:
	ld   a, SFX_NONE			; Cut off any playing SFX
	ld   [sSFX1Set], a
	xor  a
	ld   [wEndGenieTimer], a
	ld   a, $02					; Nod twice next mode
	ld   [wEndLoopsLeft], a
	ld   a, END2_RTN_PLNOD		; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_PostTr_PlNod ===============
; Wario nods twice.
Ending_PostTr_PlNod:
	call Ending_AnimPlNod
	ret
	
; =============== Ending_PostTr_MoveOutR ===============
; Wario moves right until going off-screen.
; During this, the genie blinks.
Ending_PostTr_MoveOutR:

	;
	; Move player right and handle its walk animation
	;
	call Static_Pl_WalkAnim
	ld   a, [wStaticPlX]
	inc  a
	ld   [wStaticPlX], a
	
	;
	; Depending on the player's position
	;
	cp   a, $60
	jr   z, .lookDown_closeHands
	cp   a, $90
	jr   z, .fadeoutBGM
	cp   a, $B0
	jr   z, .nextMode
	
	;
	; Make the genie blink.
	; Until the player reaches the middle of the screen, Ending_DoGenieBlinkAnim can
	; be reused since the genie is looking on the left.
	;
	; When it gets to $60 though, we want the genie to look down. If we were to continue using 
	; Ending_DoGenieBlinkAnim, it would make the eyes look left again.
	; So we have to handle it ourselves in .genieBlink.
	;
	cp   a, $60						; PlayerX >= $60?	
	jr   nc, .genieBlink			; If so, jump
	jp   Ending_DoGenieBlinkAnim
	
.lookDown_closeHands:
	xor  a
	ld   [wEndGenieTimer], a			; Reset genie timer
	ld   [wEndGenieFaceLstId], a
	ld   a, END_GENIE_CLOSED			; Left hand was already closed		
	ld   [wEndGenieHandRFrameSet], a
	ret
.fadeoutBGM:
	ld   a, BGMACT_FADEOUT
	ld   [sBGMActSet], a
	jr   .genieBlink
.nextMode:
	ld   a, $04							; Next mode
	ld   [wEndingMode], a
	ret
	
.genieBlink:
	;
	; Make the genie blink every $10 frames
	;
	ld   a, [wEndGenieTimer]
	inc  a
	ld   [wEndGenieTimer], a
	cp   a, $10
	jr   z, .blink
	cp   a, $20
	jr   z, .lookDown_reset
	ret
.blink:
	ld   a, END_OBJ_GENIEFACE_BLINK		; 
	ld   [wEndGenieFaceLstId], a
	ret
.lookDown_reset:
	xor  a								
	ld   [wEndGenieTimer], a			; Reset timer
	ld   [wEndGenieFaceLstId], a		; None
	ret
	
; =============== Ending_InitPreCred ===============
; Initializes the credits scene with the castle.
Ending_InitPreCred:
	call StopLCDOperation
	call ClearBGMapEx
	call ClearWorkOAM
	
	; Copy the block of shared credits GFX
	ld   hl, GFXRLE_EndingA
	call DecompressGFXStub
	call LoadGFX_Ending_CreditsText
	call Ending_InitVars
	
	;
	; GFXRLE_EndingA contains the graphics for these endings:
	; - Birdhouse (1 moneybag)
	; - Tree trunk (2 moneybags)
	; - House (3 moneybags)
	; - Big castle (5 moneybags)
	;
	ld   a, [sTrRoomMoneybagCount]
	
	; With 6 moneybags, there's a completely different code path to handle the planet ending,
	; since the screen scrolls up to reveal the planet.
	cp   a, $06								; 6 moneybags?
	jp   z, Ending_InitPreCred_Planet		; If so, do things for the planet ending
	
	; With 4 moneybags, just decompress the correct castle graphics
	cp   a, $04								; 4 moneybags?
	call z, LoadGFX_Ending_Castle_Pagoda	; If so, decompress
	
	call Credits_InitAnim_SmallFlag
	call LoadBG_Ending_Castle
	
	; Draw ground common between all endings (except the planet)
	ld   hl, BGRLE_Ending_Ground
	ld   bc, vBGCreditsGround
	call DecompressBG
	
	; Disable the window
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	ldh  [rLCDC], a
	
	ld   a, BGM_TREASUREGET			; Play fanfare BGM
	ld   [sBGMSet], a
	ld   a, $05						; Next mode
	ld   [wEndingMode], a
	ret
	
; =============== LoadGFX_Ending_CreditsText ===============
LoadGFX_Ending_CreditsText:
	ld   hl, GFX_Ending_CreditsText	; HL = Ptr to uncompressed GFX
	ld   de, vGFXCreditsText				
	ld   b, $1C						; Tiles to copy (sizeof(GFX_Ending_CreditsText) / $10)
	
; =============== Ending_CopyGFX ===============
; Copies uncompressed graphics to VRAM.
; IN
; - HL: Ptr to uncompressed graphics
; - DE: Ptr to destination in VRAM
; - B: Number of tiles to copy
Ending_CopyGFX:
	ld   c, TILESIZE			; C = Tile size
.loopTile:
	ldi  a, [hl]				; Read the byte
	ld   [de], a				; Copy it over
	inc  de						; VramPtr++
	dec  c						; Copied all bytes in the tile?
	jr   nz, .loopTile			; If not, loop
	dec  b						; Copied all tiles?
	jr   nz, Ending_CopyGFX		; If not, loop
	ret
	
; =============== LoadGFX_Ending_Castle_Pagoda ===============
LoadGFX_Ending_Castle_Pagoda:
	ld   hl, GFX_Ending_Castle_Pagoda
	ld   de, vGFXCreditsPagoda
	ld   b, $23	; sizeof(GFX_Ending_Castle_Pagoda) / $10
	jr   Ending_CopyGFX
	
; =============== LoadBG_Ending_Castle ===============
; Writes the tilemaps for the castle in the ending.
LoadBG_Ending_Castle:

	; Depending on how many moneybags we have, decompress a different tilemap.
	; Planet (6 moneybags) isn't accounted for here, since it does the things by itself.
	ld   a, [sTrRoomMoneybagCount]
	cp   a, $01
	jr   z, .birdHouse
	cp   a, $02
	jr   z, .treeTrunk
	cp   a, $03
	jr   z, .house
	cp   a, $04
	jr   z, .pagoda
.castle:
	ld   hl, BGRLE_Ending_Castle_Big
	jp   DecompressBG_ToBGMap
.pagoda:
	ld   hl, BGRLE_Ending_Castle_Pagoda
	jp   DecompressBG_ToBGMap
.house:
	ld   hl, BGRLE_Ending_Castle_House
	jp   DecompressBG_ToBGMap
.treeTrunk:
	ld   a, $50					; Adjust position of W mark
	ld   [wEndWLogoX], a
	ld   hl, BGRLE_Ending_Castle_TreeTrunk
	jp   DecompressBG_ToBGMap
.birdHouse:
	ld   hl, BGRLE_Ending_Castle_BirdHouse
	jp   DecompressBG_ToBGMap
	
; =============== Credits_InitAnim_SmallFlag ===============
; Sets up the animatable sprites/tile modes for the credits scene.
Credits_InitAnim_SmallFlag:
	; Set round "W" mark
	ld   a, END_OBJ_WLOGO					
	ld   [wEndWLogoLstId], a
	ld   a, $4C					; Horz. centered
	ld   [wEndWLogoX], a
	ld   a, $E0					; Off-screen above (will move down)
	ld   [wEndWLogoY], a
	ld   a, $01					; Use small castle flag BG anim 
	ld   [wEndFlagAnimType], a
	ret
	
; =============== Ending_PreCred ===============
; Ending scene.
Ending_PreCred:
	ld   a, [wEndAct]
	rst  $28
	dw Ending_PreCred_MoveInRight
	dw Ending_PreCred_MoveWLogo
	dw Ending_PreCred_JumpR
	dw Ending_PreCred_JumpL
	dw Ending_DoPlThumbsUp
	dw Ending_PreCred_Fail
	dw Ending_PreCred_JumpV
	
; =============== Ending_PreCred_MoveInRight ===============
; Wario moves right, from off-screen.
Ending_PreCred_MoveInRight:
	;
	; Walk right until reaching the target position.
	;
	ld   a, [wStaticPlX]
	cp   a, $34					; PlX == $34?
	jr   z, Ending_WaitIdleDiag	; If so, jump
	inc  a						; Otherwise, PlX++
	ld   [wStaticPlX], a
	jp   Static_Pl_WalkAnim
	
; =============== Ending_PreCred_MoveInRight ===============
; Makes the player wait for the specified amount of frames in the "looking up" anim.
; After it's done, it will switch to the next submode.
Ending_WaitIdleDiag:
	;
	; Then wait $50 frames looking up
	;
	ld   a, OBJ_STATIC_WARIO_IDLEDIAG
	ld   [wStaticPlLstId], a
	ld   a, [wEndPlMoveLDelay]
	inc  a
	ld   [wEndPlMoveLDelay], a
	cp   a, $50
	ret  nz
.nextMode:
	xor  a							; Reset timers
	ld   [wStaticPlAnimTimer], a
	ld   [wEndPlMoveLDelay], a		
	ld   a, END3_RTN_MARKDOWN		; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_PreCred_MoveWLogo ===============
; Moves down the W mark, from off-screen above.
Ending_PreCred_MoveWLogo:
	;
	; Depending on the castle type, use a different Y target position.
	; Until the target is reached, make it move down and flash its palette.
	;
	; When the target position is reached, what happens then depends on the castle.
	; - Tree house and bird house are marked as bad ending
	; - The rest is marked as good ending
	;
	ld   a, [sTrRoomMoneybagCount]
	cp   a, END_CASTLE_BIRDHOUSE			
	jr   z, .birdHouse
	cp   a, END_CASTLE_TREEHOUSE
	jr   z, .treeHouse
	cp   a, END_CASTLE_HOUSE
	jr   z, .house
	; Pagoda ($04) and Big Castle ($05) use same Y coord
.main:
	ld   a, [wEndWLogoY]
	cp   a, $39							; Y == Target?
	jr   z, Ending_WLogoLand_GoodCastle	; If so, jump
	jr   .anim							; Otherwise, continue animating and moving down
.house:
	ld   a, [wEndWLogoY]
	cp   a, $4C
	jr   z, Ending_WLogoLand_GoodCastle
	jr   .anim
.treeHouse:
	ld   a, [wEndWLogoY]
	cp   a, $51
	jr   z, Ending_WLogoLand_BadCastle
	jr   .anim
.birdHouse:
	ld   a, [wEndWLogoY]
	cp   a, $57
	jr   z, Ending_WLogoLand_BadCastle
.anim:
	;
	; Flash the "W" every $0A frames while moving down.
	; This is shared for all castle types.
	;
	ld   a, [wEndWLogoTimer]
	inc  a
	ld   [wEndWLogoTimer], a
	;--
	; Loop infinitely $00-($0A*2)
	cp   a, $0A						; Timer == $0A?
	jr   z, .useInvPal				; If so, invert the "W" palette
	cp   a, $0A+$0A					; Timer == $0A*2=ì?
	jr   z, .useMainPal_playSFX	; If so, use the normal palette
	;--
	; Move "W" down at 0.5px/frame.
	bit  0, a				; Timer % 2 == 0?
	ret  z					; If so, return
	ld   a, [wEndWLogoY]
	inc  a
	ld   [wEndWLogoY], a
	ret
.useInvPal:
	ld   a, END_OBJ_WLOGOINV	; Inverted "W" mark
	ld   [wEndCloudLstId], a
	ret
.useMainPal_playSFX:
	ld   a, SFX1_1F				; SFX for "okay enough" castle
	ld   [sSFX1Set], a
	
; =============== Ending_SetWMarkNormPal_ResetTimer ===============
; Resets the "W" mark palette flash animation.
Ending_SetWMarkNormPal_ResetTimer:
	xor  a						; Reset timer
	ld   [wEndWLogoTimer], a
	ld   a, END_OBJ_WLOGO		; Normal "W" mark
	ld   [wEndCloudLstId], a
	ret
	
; =============== Ending_WLogoLand_GoodCastle ===============
; Called from when the "W Mark" reaches the target position on a "good" castle.
Ending_WLogoLand_GoodCastle:
	; Handle timing sequence
	ld   a, [wEndPlMoveLDelay]	; Timer++
	inc  a
	ld   [wEndPlMoveLDelay], a
	
	; When the W Mark first stops moving, play a SFX.
	; This happens the first time we get here.
	cp   a, $01
	jr   z, Ending_WLogoLand_PlaySFX
	
	;
	; Wait for $50 frames next before switching.
	;
	cp   a, $50
	ret  nz
	
.nextMode:
	ld   a, BGM_LEVELCLEAR				; Play success BGM
	ld   [sBGMSet], a
	xor  a
	ld   [wEndPlMoveLDelay], a
	ld   a, OBJ_ENDING_WARIO_JUMPDIAG	; Prepare jump frame.
	ld   [wStaticPlLstId], a
	
	;
	; Switch to the next mode.
	; The 3 moneybags ending is handled differently by having the player jump
	; without moving horizontally.
	;
	ld   a, [sTrRoomMoneybagCount]
	cp   a, END_CASTLE_HOUSE		; 3 moneybags?					
	jr   z, .switchToJumpV			; If so, jump
	
.switchToJumpR:
	ld   a, $02						; Jump twice right
	ld   [wEndLoopsLeft], a
	ld   [wEndAct], a				; Next mode - END3_RTN_JUMPR
	ret
.switchToJumpV:
	ld   a, $04						; Jump 4 times in-place
	ld   [wEndLoopsLeft], a
	ld   a, END3_RTN_JUMPV			; New mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_WLogoLand_PlaySFX ===============
; Plays a SFX, meant to be called when the "W Mark" lands on the castle.
Ending_WLogoLand_PlaySFX:
	ld   a, SFX1_08					
	ld   [sSFX1Set], a
	jr   Ending_SetWMarkNormPal_ResetTimer
	
; =============== Ending_WLogoLand_BadCastle ===============
; Called from when the "W Mark" reaches the target position on a "bad" castle.
Ending_WLogoLand_BadCastle:
	; Handle timing sequence
	ld   a, [wEndPlMoveLDelay]	; Timer++
	inc  a
	ld   [wEndPlMoveLDelay], a
	
	; When the W Mark first stops moving, play a SFX.
	; This happens the first time we get here.
	cp   a, $01
	jr   z, Ending_WLogoLand_PlaySFX
	
	;
	; Wait for $50 frames next before switching.
	;
	cp   a, $50
	ret  nz
	xor  a
	ld   [wEndPlMoveLDelay], a
	ld   a, END3_RTN_FAIL
	ld   [wEndAct], a
	ret
	
; =============== Ending_PreCred_JumpR ===============
; Wario jumps right (good ending).
Ending_PreCred_JumpR:
	; Move player right
	ld   a, [wStaticPlX]
	inc  a
	ld   [wStaticPlX], a
	
	; Handle the jump animation + next mode on finish
	call Ending_DoPlJump
	
	; If we finished, setup the next mode options
	ld   a, [wEndLoopsLeft]
	cp   a, $00
	ret  nz
.nextModeOpt:
	ld   a, OBJ_ENDING_WARIO_JUMPDIAG	; Set jump frame
	ld   [wStaticPlLstId], a
	ld   a, STATIC_OBJLST_XFLIP			; Face left
	ld   [wStaticPlFlags], a
	ld   a, $02							; Jump twice left
	ld   [wEndLoopsLeft], a
	ret
; =============== Ending_PreCred_JumpR ===============
; Wario jumps left (good ending).
Ending_PreCred_JumpL:
	; Move player left
	ld   a, [wStaticPlX]
	dec  a
	ld   [wStaticPlX], a
	
	; Handle the jump animation + next mode on finish
	jp   Ending_DoPlJump
	
; =============== Ending_DoPlThumbsUp ===============
; Wario does the thumbs up animation.
; This is also called during the credits.
Ending_DoPlThumbsUp:
	; Handle the timing sequence for this
	ld   a, [wStaticPlAnimTimer]
	inc  a
	ld   [wStaticPlAnimTimer], a
	cp   a, $05
	jr   z, Ending_DoPlThumbsUp_SetFrontFrame
	; Make Wario do the thumbs up
	cp   a, $23
	jr   z, .setFrameWon0
	cp   a, $41
	jr   z, .setFrameWon1
	cp   a, $78
	jr   z, Ending_DoPlThumbsUp_Turn			; Credits mode only
	cp   a, $B4
	jr   z, Ending_DoPlThumbsUp_SetCreditsMode	; Ending mode only
	ret
.setFrameWon0:
	ld   a, OBJ_STATIC_WARIO_WON0	; Thumbs up 1/2
	ld   [wStaticPlLstId], a
	ret
.setFrameWon1:
	ld   a, OBJ_STATIC_WARIO_WON1	; Thumbs up 2/2
	ld   [wStaticPlLstId], a
	ret
; =============== Ending_DoPlSad ===============
; Wario does sad animation after the W Mark falls off.
Ending_DoPlSad:
	; Handle timing for sequence
	ld   a, [wStaticPlAnimTimer]
	inc  a
	ld   [wStaticPlAnimTimer], a
	cp   a, $0A
	jr   z, Ending_DoPlThumbsUp_SetFrontFrame
	cp   a, $32
	jr   z, Ending_DoPlThumbsUp_SetLostFrame
	cp   a, $96
	jr   z, Ending_DoPlThumbsUp_Turn
	cp   a, $C8
	jr   z, Ending_DoPlThumbsUp_SetCreditsMode
	ret
; =============== Ending_DoPlThumbsUp_SetFrontFrame ===============
Ending_DoPlThumbsUp_SetFrontFrame:
	ld   a, OBJ_STATIC_WARIO_FRONT
	ld   [wStaticPlLstId], a
	ret
; =============== Ending_DoPlThumbsUp_SetLostFrame ===============
Ending_DoPlThumbsUp_SetLostFrame:
	ld   a, SFX1_1D					; Set sad SFX (like in the bonus games)
	ld   [sSFX1Set], a
	ld   a, OBJ_STATIC_WARIO_LOST
	ld   [wStaticPlLstId], a
	ret
	
; =============== Ending_DoPlThumbsUp_Turn ===============
; Makes the player turn after doing the thumbs up animation.
Ending_DoPlThumbsUp_Turn:
	; The very first time we get here (not during the credits), we should just
	; continue walking in the same direction.
	;
	; Also, what this subroutine does is only applicable during the credits anyway.
	ld   a, [wEndingMode]
	cp   a, END_RTN_CREDITS
	ret  nz
	
	; Reset the animation timer and switch to the walk routine.
	; This prevents Ending_DoPlThumbsUp_SetCreditsMode from being called again.
	xor  a							; Reset anim timer
	ld   [wStaticPlAnimTimer], a
	ld   a, CRED_RTN_WALK			; Switch to walk routine
	ld   [wEndAct], a
	
	; Invert the player's position.
	; Could have been xor'd $80 but oh well.
	ld   a, [wStaticPlFlags]
	bit  STATIC_OBJLSTB_XFLIP, a	; Player facing left?
	jr   z, .turnLeft				; If not, jump
.turnRight:
	xor  a							; Otherwise, face right
	ld   [wStaticPlFlags], a
	ret
.turnLeft:
	ld   a, STATIC_OBJLST_XFLIP		; Face left
	ld   [wStaticPlFlags], a
	ret
	
; =============== Ending_DoPlThumbsUp_SetCreditsMode ===============
; Switches the to the credits mode and initializes the walk loop.
; Meant to be called only in the ending mode, not during the credits.
Ending_DoPlThumbsUp_SetCreditsMode:
	ld   a, BGM_CREDITS				; Set credits track (if something else is playing)
	ld   [sBGMSet], a
	xor  a
	ld   [wStaticPlAnimTimer], a	; Reset thumbs up anim timer
	ld   [wStaticPlFlags], a		; Face right
	ld   a, $02						; Signal out to start the credits (perform cleanup in bank $01)
	ld   [sEndingRetVal], a
	ld   a, CRED_RTN_WALK			; Switch to the walk routine
	ld   [wEndAct], a
	ld   a, END_RTN_CREDITS			; New mode
	ld   [wEndingMode], a
	ret
	
; =============== Ending_PreCred_Fail ===============
; Waits for $3C frames, then makes the W Mark fall off the "castle".
Ending_PreCred_Fail:
	; Wait $3C frames before doing it
	ld   a, [wEndCloudAnimTimer]
	cp   a, $3C
	jr   z, .main
	inc  a
	ld   [wEndCloudAnimTimer], a
	
	; The frame before we're moving down the W Mark, play the bad ending jingle.
	cp   a, $3C
	ret  nz
	ld   a, BGM_GAMEOVER2
	ld   [sBGMSet], a
	ret
.main:
	
	;
	; Make the W Mark move down at 2px/frame.
	; When it's offscreen, play the "sad Wario" animation before switching to the credits.
	;                                               (done automatically by Ending_DoPlSad)
	;
	ld   a, [wEndWLogoY]
	cp   a, $A1				; WMarkY == $A1?
	jr   z, .doPlSad		; If so, jump (it's off-screen)
	
.moveDown:
	inc  a					; WMarkY += 2
	inc  a
	ld   [wEndWLogoY], a
	
	; When the "W Mark" goes near Wario's vertical position, switch from
	; the looking up anim to the idle anim.
	; This is done so as the "W Mark" moves down, Wario will keep looking at it.
	cp   a, $71						; WMarkY != $71?
	ret  nz							; If so, jump
	ld   a, OBJ_STATIC_WARIO_IDLE
	ld   [wStaticPlLstId], a
	ret
.doPlSad:
	xor  a
	ld   [wEndWLogoLstId], a		; Delete WMark sprite
	jp   Ending_DoPlSad
	
; =============== Ending_PreCred_JumpV ===============
; Wario jumps in-place 4 times.
; This is specific to the 3 moneybags ending (END_CASTLE_HOUSE).
Ending_PreCred_JumpV:
	; Handle the jumps until there are no more left
	call Ending_DoPlJump
	ld   a, [wEndLoopsLeft]
	cp   a, $00
	ret  nz
.nextMode:
	ld   a, OBJ_STATIC_WARIO_IDLEDIAG	; Set player frame
	ld   [wStaticPlLstId], a			
	ld   a, END3_RTN_THUMBSUP			; New submode
	ld   [wEndAct], a
	ret
	
; =============== Ending_Credits ===============
Ending_Credits:
	ld   a, [wEndAct]
	rst  $28
	dw Ending_DoPlThumbsUp
	dw Ending_DoPlCreditsWalk
	
; =============== Ending_DoPlCreditsWalk ===============
; Makes the player walk across the screen during the credits.
Ending_DoPlCreditsWalk:
	;
	; HORIZONTAL MOVEMENT
	;
	ld   a, [wStaticPlFlags]
	bit  STATIC_OBJLSTB_XFLIP, a	; Facing left?
	jr   nz, .moveL					; If so, move left
.moveR:								; Otherwise, move right
	ld   a, [wStaticPlX]			; PlX++
	inc  a
	ld   [wStaticPlX], a
	cp   a, $80						; Reached the rightmost position?
	jr   nz, .animWalkCycle			; If not, animate the walk cycle
	jr   .switchToThumbsUp			; Otherwise, do thumbs up (then turn)
.moveL:
	ld   a, [wStaticPlX]			; PlX--
	dec  a
	ld   [wStaticPlX], a
	cp   a, $18						; Reached the leftmost position?
	jr   nz, .animWalkCycle			; If not, animate the walk cycle
.switchToThumbsUp:					; Otherwise, do thumbs up (then turn)
	xor  a
	ld   [wStaticPlAnimTimer], a	; Reset timer for thumbs up anim
	ld   [wEndAct], a				; Set CRED_RTN_THUMBSUP
	ret
	
.animWalkCycle:
	; Handle the timing sequence for the walk cycle
	ld   a, [wStaticPlAnimTimer]
	inc  a
	ld   [wStaticPlAnimTimer], a
	cp   a, $01
	jr   z, .setFrame0
	cp   a, $04
	jr   z, .setFrame1
	cp   a, $08
	jr   z, .setFrame3
	cp   a, $0C
	jr   z, .setFrame0
	cp   a, $10
	jr   z, .setFrame2
	cp   a, $14
	jr   z, .setFrame3
	; On frame $18, reset the timer
.chkReset:
	cp   a, $18
	ret  nz
	xor  a
	ld   [wStaticPlAnimTimer], a
.setFrame0:
	ld   a, OBJ_STATIC_WARIO_WALK0
	ld   [wStaticPlLstId], a
	ret
.setFrame1:
	ld   a, OBJ_STATIC_WARIO_WALK1
	ld   [wStaticPlLstId], a
	ret
.setFrame3:
	ld   a, OBJ_STATIC_WARIO_WALK3
	ld   [wStaticPlLstId], a
	ret
.setFrame2:
	ld   a, OBJ_STATIC_WARIO_WALK2
	ld   [wStaticPlLstId], a
	ret
	
; =============== Ending_InitPreCred_Planet ===============
; Initializes the planet-specific ending stuff.
Ending_InitPreCred_Planet:
	call LoadGFX_Ending_Castle_Planet
	
	; The WINDOW contains the ground with nothing on it (same as the initial part of the ending).
	ld   hl, BGRLE_Ending_CutsceneNoGenie
	call DecompressBG_ToWINDOWMap
	; The BG layer contains the fade out to black, and the planet itself.
	ld   hl, BGRLE_Ending_Castle_Planet
	call DecompressBG_ToBGMap
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	ldh  [rLCDC], a
	ld   a, BGM_NONE
	ld   [sBGMSet], a
	
	; Enable star animation.
	; This uses the same type as the "big flags" for the Big Castle and Pagoda endings,
	; meaning they have to share the same VRAM tile offsets.
	ld   a, $02						
	ld   [wEndFlagAnimType], a
	
	ld   a, END_RTN_PLANET			; New mode
	ld   [wEndingMode], a
	ret
	
; =============== LoadGFX_Ending_Castle_Planet ===============
LoadGFX_Ending_Castle_Planet:
	ld   hl, GFX_Ending_Castle_Planet
	ld   de, vGFXCreditsPlanet
	ld   b, $44				; sizeof(GFX_Ending_Castle_Planet) / $10
	ld   c, TILESIZE		; Not necessary
	jp   Ending_CopyGFX
	
; =============== Ending_PreCredPlanet ===============
; Sequence specific to the planet sequence.
; See also: Ending_PreCredPlanet, where some of the called subroutines are shared.
Ending_PreCredPlanet:
	ld   a, [wEndAct]
	rst  $28
	dw Ending_PreCredPlanet_MoveInRight
	dw Ending_PreCredPlanet_ScrollUp
	dw Ending_PreCredPlanet_PlJumpUp
	dw Ending_PreCredPlanet_PlThumbsUp
	dw Ending_PreCredPlanet_PlJumpDown
	dw Ending_PreCredPlanet_WaitToCredits
	
; =============== Ending_PreCredPlanet_MoveInRight ===============
; Wario moves right, from off-screen.
Ending_PreCredPlanet_MoveInRight:
	;
	; Walk right until reaching the target position.
	;
	ld   a, [wStaticPlX]
	cp   a, $1C					; PlX == $14?
	jp   z, Ending_WaitIdleDiag	; If so, jump
	inc  a						; Otherwise, PlX++
	ld   [wStaticPlX], a
	jp   Static_Pl_WalkAnim
	
; =============== Ending_PreCredPlanet_ScrollUp ===============
; Makes the player move up in the sky, by scrolling the screen up.
Ending_PreCredPlanet_ScrollUp:
	;--
	; Wait $32 frames before scrolling the screen.
	; Until that's done, don't continue with the timing sequence.
	ld   a, [wStaticPlAnimTimer]
	cp   a, $32
	jr   z, .scrollUp
	inc  a
	ld   [wStaticPlAnimTimer], a
	;--
	cp   a, $5A
	jr   z, .setIdleFrame
	cp   a, $AA
	jr   z, .setLookUpFrame
	cp   a, $C8
	jr   z, .nextMode
	ret
.scrollUp:
	; Variable reused to slow down the screen scrolling (0.5px/frame)
	ld   a, [wEndPlMoveLDelay]
	inc  a
	ld   [wEndPlMoveLDelay], a
	bit  0, a
	ret  nz
	
	;
	; To avoid writing blocks when the screen scrolls up, both layers are used here.
	; These are aligned so that:
	; - The BG layer is initially scrolled so that the planet woul be visible.
	; - The WINDOW with the ground tilemap covers it
	; 
	; Then the BG is scrolled up and the WINDOW is scrolled down.
	; When the WINDOW stops scrolling (and we hide it), the BG layer will be perfectly aligned to the bottom
	; border of the viewport, so we just have to keep scrolling until the planet is visible.
	;
	
	; Scroll up screen.
	; The initial value is $00, so it prevents the following check from instantly triggering.
	ldh  a, [rSCY]		; ScrollY--
	dec  a
	ldh  [rSCY], a
	
	; If we've finished scrolling the screen (and the planet is visible, at rSCY $00),
	; stop scrolling and unlock the timing sequence.
	jr   z, .endScroll
	
	; If the WINDOW's position is off-screen, don't move it
	ldh  a, [rWY]
	cp   a, $8F
	ret  z
	
	inc  a				; WindowY++
	ldh  [rWY], a
	
	; If it went off-screen, hide it
	cp   a, $8F
	ret  nz
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_WTILEMAP|LCDC_ENABLE	; Hide it
	ldh  [rLCDC], a
	ret
	
.endScroll:
	ld   a, $33
	ld   [wStaticPlAnimTimer], a
	ret
.setIdleFrame:
	ld   a, OBJ_STATIC_WARIO_IDLE
	ld   [wStaticPlLstId], a
	ret
.setLookUpFrame:
	ld   a, OBJ_STATIC_WARIO_IDLEDIAG
	ld   [wStaticPlLstId], a
	ret
.nextMode:
	; Setup the jump on the planet
	ld   a, SFX4_08						; Play jump SFX
	ld   [sSFX4Set], a
	ld   a, BGM_BOSSCLEAR				; Perfect
	ld   [sBGMSet], a
	xor  a								; Reset vars
	ld   [wStaticPlAnimTimer], a
	ld   [wEndPlMoveLDelay], a
	ldh  [rWX], a						; It's hidden anyway
	ldh  [rWY], a						; It's hidden anyway
	ld   a, OBJ_ENDING_WARIO_JUMPDIAG	; Set jump frame
	ld   [wStaticPlLstId], a
	ld   a, END4_RTN_PLJUMPUP			; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_PreCredPlanet_PlJumpUp ===============
; Wario jumps on top of the planet.
Ending_PreCredPlanet_PlJumpUp:

	;
	; When the index goes out of range, stop jumping.
	;
	ld   a, [wStaticPlAnimTimer]
	ld   c, a
	cp   a, (Ending_PlanetPlJumpYPathTbl.end-Ending_PlanetPlJumpYPathTbl)
	jr   nc, .wait
	inc  a								; Index++
	ld   [wStaticPlAnimTimer], a
	
	;
	; VERTICAL MOVEMENT
	;
	; Handles through a table of absolute Y positions. 
	ld   hl, Ending_PlanetPlJumpYPathTbl; HL = Y Path table
	ld   b, $00							; BC = Index (wStaticPlAnimTimer)
	add  hl, bc							
	ld   a, [hl]						; A = New Y pos
	ld   [wStaticPlY], a				; Update Y pos
	
	;
	; HORIZONTAL MOVEMENT
	;
	ld   a, [wStaticPlX]	; PlX++
	inc  a
	ld   [wStaticPlX], a
	ret
.wait:
	;
	; Wait $16 frames after landing before switching
	; to the next mode.
	;
	inc  a
	ld   [wStaticPlAnimTimer], a
	cp   a, $46							; Timer == $46?
	jr   z, .nextMode					; If so, jump
	ld   a, OBJ_COINBONUS_WARIO_PULL0
	ld   [wStaticPlLstId], a
	ret
.nextMode:
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   a, $02							; Thumbs up twice
	ld   [wEndLoopsLeft], a
	ld   a, END4_RTN_PLTHUMBSUP
	ld   [wEndAct], a
	ret
Ending_PlanetPlJumpYPathTbl: 
	db $62,$5C,$58,$54,$50,$4C,$48,$44,$40,$3D,$3A,$37,$34,$32,$30,$2E ; $10
	db $2C,$2A,$28,$26,$24,$22,$21,$20,$1F,$1E,$1D,$1C,$1B,$1A,$19,$19 ; $20
	db $18,$18,$17,$17,$17,$18,$18,$19,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20 ; $30
.end:

; =============== Ending_PreCredPlanet_PlThumbsUp ===============
; Wario thumbs up twice.
Ending_PreCredPlanet_PlThumbsUp:
	; Handle timing sequence
	ld   a, [wStaticPlAnimTimer]
	inc  a
	ld   [wStaticPlAnimTimer], a
	;--
	; Loops 2 times ($00-$AA)
	cp   a, $14
	jr   z, .setPlFront
	cp   a, $32
	jr   z, .setPlWon0
	cp   a, $50
	jr   z, .setPlWon1
	cp   a, $AA
	jr   z, .setPlFront_chkReset
	;--
	cp   a, $BE
	jr   z, .setPlLookUpLeft
	cp   a, $CD
	jr   z, .nextMode
	ret
.setPlFront_chkReset:
	;
	; Reset the animation timer if not all loops are done
	;
	xor  a							; Timer = $00
	ld   [wStaticPlAnimTimer], a
	ld   a, [wEndLoopsLeft]			; LoopsLeft--
	dec  a
	ld   [wEndLoopsLeft], a			; LoopsLeft != 0?
	jr   nz, .setPlFront			; If so, jump
	
	ld   a, $AB						; Otherwise, unlock timer
	ld   [wStaticPlAnimTimer], a
.setPlFront:
	ld   a, OBJ_STATIC_WARIO_FRONT
	ld   [wStaticPlLstId], a
	ret
.setPlWon0:
	ld   a, OBJ_STATIC_WARIO_WON0
	ld   [wStaticPlLstId], a
	ret
.setPlWon1:
	ld   a, OBJ_STATIC_WARIO_WON1
	ld   [wStaticPlLstId], a
	ret
.setPlLookUpLeft:
	ld   a, OBJ_STATIC_WARIO_IDLEDIAG
	ld   [wStaticPlLstId], a
	ld   a, STATIC_OBJLST_XFLIP
	ld   [wStaticPlFlags], a
	ret
.nextMode:
	; Prepare jump down
	ld   a, (Ending_PlanetPlJumpYPathTbl.end-Ending_PlanetPlJumpYPathTbl-1)
	ld   [wStaticPlAnimTimer], a
	ld   a, OBJ_ENDING_WARIO_JUMPDIAG
	ld   [wStaticPlLstId], a
	ld   a, END4_RTN_PLJUMPDOWN	; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_PreCredPlanet_PlJumpDown ===============
; Wario jumps down from the top of the planet.
Ending_PreCredPlanet_PlJumpDown:

	; This uses the same Y offset table as Ending_PreCredPlanet_PlJumpUp,
	; except the values are read backwards.

	;
	; When the index would become negative, stop jumping.
	;
	ld   a, [wStaticPlAnimTimer]
	cp   a, $00						; Index == $00?
	jr   z, .nextMode				; If so, jump
	dec  a							; Index--
	ld   [wStaticPlAnimTimer], a
	
	;
	; VERTICAL MOVEMENT
	;
	; Handles through a table of absolute Y positions. 
	ld   c, a
	ld   hl, Ending_PlanetPlJumpYPathTbl; HL = Y Path table
	ld   b, $00							; BC = Index (wStaticPlAnimTimer)
	add  hl, bc							
	ld   a, [hl]						; A = New Y pos
	ld   [wStaticPlY], a				; Update Y pos
	
	;
	; HORIZONTAL MOVEMENT
	;
	ld   a, [wStaticPlX]	; PlX--
	dec  a
	ld   [wStaticPlX], a
	ret
	
.nextMode:
	ld   a, BGM_CREDITS					; Play credits BGM
	ld   [sBGMSet], a
	ld   a, OBJ_STATIC_WARIO_IDLEDIAG	; Set idle frame
	ld   [wStaticPlLstId], a
	ld   a, END4_RTN_WAITTOCREDITS		; Next mode
	ld   [wEndAct], a
	ret
	
; =============== Ending_PreCredPlanet_WaitToCredits ===============
; Waits for a bit before switching to the credits scene.
Ending_PreCredPlanet_WaitToCredits:
	; Wait $14 frames before continuing
	ld   a, [wEndPlMoveLDelay]		; MoveLDelay++
	inc  a
	ld   [wEndPlMoveLDelay], a
	cp   a, $14						; MoveLDelay == $14?
	ret  nz							; If not, return
.switchToCredits:
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   [wEndPlMoveLDelay], a
	ld   [wEndAct], a				; Reset mode
	ld   a, $02						; Signal out that we're done
	ld   [sEndingRetVal], a
	ld   a, END_RTN_CREDITS			; Credits mode
	ld   [wEndingMode], a
	ret
	
; =============== GFX / TILEMAPS ===============
GFXRLE_EndingA: INCBIN "data/gfx/ending/main_a.rlc"
L1F68FE: db $00;X
L1F68FF: db $00;X
L1F6900: db $00;X
GFX_Ending_CreditsText: INCBIN "data/gfx/ending/creditstext.bin"
GFX_Ending_Castle_Planet: INCBIN "data/gfx/ending/castle_planet.bin"
GFX_Ending_Castle_Pagoda: INCBIN "data/gfx/ending/castle_pagoda.bin"
BGRLE_Ending_CutsceneNoGenie: INCBIN "data/bg/ending/cutscene_nogenie.rls"
L1F71A3: db $00;X
L1F71A4: db $00;X
L1F71A5: db $00;X
L1F71A6: db $00;X
L1F71A7: db $00;X
L1F71A8: db $00;X
L1F71A9: db $00;X
BGRLE_Ending_CutsceneGenie: INCBIN "data/bg/ending/cutscene_genie.rls"
L1F7277: db $00;X
L1F7278: db $00;X
L1F7279: db $00;X
L1F727A: db $00;X
BGRLE_Ending_Castle_Planet: INCBIN "data/bg/ending/castle_planet.rls"
BGRLE_Ending_Castle_Big: INCBIN "data/bg/ending/castle_big.rls"
BGRLE_Ending_Castle_House: INCBIN "data/bg/ending/castle_house.rls"
L1F7548: db $00;X
L1F7549: db $00;X
L1F754A: db $00;X
L1F754B: db $00;X
L1F754C: db $00;X
BGRLE_Ending_Castle_BirdHouse: INCBIN "data/bg/ending/castle_birdhouse.rls"
L1F75A5: db $00;X
BGRLE_Ending_Castle_TreeTrunk: INCBIN "data/bg/ending/castle_treetrunk.rls"
L1F7622: db $00;X
L1F7623: db $00;X
L1F7624: db $00;X
L1F7625: db $00;X
L1F7626: db $00;X
BGRLE_Ending_Castle_Pagoda: INCBIN "data/bg/ending/castle_pagoda.rls"
BGRLE_Ending_Ground: INCBIN "data/bg/ending/ground.rls"
; =============== END OF BANK ===============
L1F76D4: db $24;X
L1F76D5: db $02;X
L1F76D6: db $00;X
L1F76D7: db $00;X
L1F76D8: db $00;X
L1F76D9: db $00;X
L1F76DA: db $00;X
L1F76DB: db $00;X
L1F76DC: db $40;X
L1F76DD: db $00;X
L1F76DE: db $01;X
L1F76DF: db $00;X
L1F76E0: db $80;X
L1F76E1: db $00;X
L1F76E2: db $00;X
L1F76E3: db $00;X
L1F76E4: db $00;X
L1F76E5: db $22;X
L1F76E6: db $00;X
L1F76E7: db $00;X
L1F76E8: db $00;X
L1F76E9: db $00;X
L1F76EA: db $00;X
L1F76EB: db $C0;X
L1F76EC: db $00;X
L1F76ED: db $00;X
L1F76EE: db $00;X
L1F76EF: db $00;X
L1F76F0: db $00;X
L1F76F1: db $00;X
L1F76F2: db $40;X
L1F76F3: db $40;X
L1F76F4: db $00;X
L1F76F5: db $08;X
L1F76F6: db $00;X
L1F76F7: db $00;X
L1F76F8: db $00;X
L1F76F9: db $08;X
L1F76FA: db $00;X
L1F76FB: db $80;X
L1F76FC: db $40;X
L1F76FD: db $20;X
L1F76FE: db $40;X
L1F76FF: db $00;X
L1F7700: db $FF;X
L1F7701: db $FB;X
L1F7702: db $FF;X
L1F7703: db $BB;X
L1F7704: db $FF;X
L1F7705: db $E7;X
L1F7706: db $FF;X
L1F7707: db $FF;X
L1F7708: db $FF;X
L1F7709: db $FF;X
L1F770A: db $FF;X
L1F770B: db $FF;X
L1F770C: db $F7;X
L1F770D: db $FF;X
L1F770E: db $FF;X
L1F770F: db $FF;X
L1F7710: db $FE;X
L1F7711: db $FF;X
L1F7712: db $DF;X
L1F7713: db $FF;X
L1F7714: db $FF;X
L1F7715: db $FF;X
L1F7716: db $FF;X
L1F7717: db $9D;X
L1F7718: db $FF;X
L1F7719: db $FB;X
L1F771A: db $FF;X
L1F771B: db $FD;X
L1F771C: db $FF;X
L1F771D: db $FF;X
L1F771E: db $FF;X
L1F771F: db $FF;X
L1F7720: db $FF;X
L1F7721: db $FF;X
L1F7722: db $FF;X
L1F7723: db $FF;X
L1F7724: db $FF;X
L1F7725: db $FF;X
L1F7726: db $FF;X
L1F7727: db $7F;X
L1F7728: db $FF;X
L1F7729: db $7F;X
L1F772A: db $FF;X
L1F772B: db $FF;X
L1F772C: db $FF;X
L1F772D: db $DF;X
L1F772E: db $FF;X
L1F772F: db $FF;X
L1F7730: db $EF;X
L1F7731: db $FF;X
L1F7732: db $FF;X
L1F7733: db $FF;X
L1F7734: db $FF;X
L1F7735: db $FF;X
L1F7736: db $FF;X
L1F7737: db $FB;X
L1F7738: db $FF;X
L1F7739: db $FE;X
L1F773A: db $FF;X
L1F773B: db $FF;X
L1F773C: db $FF;X
L1F773D: db $EF;X
L1F773E: db $FD;X
L1F773F: db $FF;X
L1F7740: db $FF;X
L1F7741: db $FF;X
L1F7742: db $FF;X
L1F7743: db $FF;X
L1F7744: db $FE;X
L1F7745: db $FF;X
L1F7746: db $FF;X
L1F7747: db $DF;X
L1F7748: db $FF;X
L1F7749: db $FF;X
L1F774A: db $FF;X
L1F774B: db $FF;X
L1F774C: db $FF;X
L1F774D: db $FF;X
L1F774E: db $FF;X
L1F774F: db $FF;X
L1F7750: db $FE;X
L1F7751: db $FF;X
L1F7752: db $FF;X
L1F7753: db $FF;X
L1F7754: db $FD;X
L1F7755: db $FF;X
L1F7756: db $FD;X
L1F7757: db $FF;X
L1F7758: db $FF;X
L1F7759: db $FF;X
L1F775A: db $FF;X
L1F775B: db $FE;X
L1F775C: db $FF;X
L1F775D: db $FF;X
L1F775E: db $FF;X
L1F775F: db $FF;X
L1F7760: db $FF;X
L1F7761: db $FF;X
L1F7762: db $FF;X
L1F7763: db $FF;X
L1F7764: db $BF;X
L1F7765: db $FF;X
L1F7766: db $FF;X
L1F7767: db $FF;X
L1F7768: db $FF;X
L1F7769: db $FF;X
L1F776A: db $FF;X
L1F776B: db $FF;X
L1F776C: db $FF;X
L1F776D: db $FF;X
L1F776E: db $FB;X
L1F776F: db $BF;X
L1F7770: db $FF;X
L1F7771: db $FF;X
L1F7772: db $FF;X
L1F7773: db $FF;X
L1F7774: db $FF;X
L1F7775: db $FF;X
L1F7776: db $DE;X
L1F7777: db $FF;X
L1F7778: db $FF;X
L1F7779: db $F7;X
L1F777A: db $FF;X
L1F777B: db $FF;X
L1F777C: db $BF;X
L1F777D: db $FD;X
L1F777E: db $FF;X
L1F777F: db $FB;X
L1F7780: db $00;X
L1F7781: db $00;X
L1F7782: db $02;X
L1F7783: db $00;X
L1F7784: db $00;X
L1F7785: db $01;X
L1F7786: db $80;X
L1F7787: db $00;X
L1F7788: db $00;X
L1F7789: db $00;X
L1F778A: db $70;X
L1F778B: db $00;X
L1F778C: db $01;X
L1F778D: db $00;X
L1F778E: db $02;X
L1F778F: db $00;X
L1F7790: db $04;X
L1F7791: db $00;X
L1F7792: db $00;X
L1F7793: db $00;X
L1F7794: db $10;X
L1F7795: db $00;X
L1F7796: db $00;X
L1F7797: db $00;X
L1F7798: db $00;X
L1F7799: db $00;X
L1F779A: db $00;X
L1F779B: db $40;X
L1F779C: db $00;X
L1F779D: db $40;X
L1F779E: db $00;X
L1F779F: db $04;X
L1F77A0: db $20;X
L1F77A1: db $00;X
L1F77A2: db $00;X
L1F77A3: db $00;X
L1F77A4: db $00;X
L1F77A5: db $90;X
L1F77A6: db $00;X
L1F77A7: db $10;X
L1F77A8: db $00;X
L1F77A9: db $00;X
L1F77AA: db $00;X
L1F77AB: db $00;X
L1F77AC: db $00;X
L1F77AD: db $00;X
L1F77AE: db $00;X
L1F77AF: db $00;X
L1F77B0: db $08;X
L1F77B1: db $00;X
L1F77B2: db $00;X
L1F77B3: db $00;X
L1F77B4: db $40;X
L1F77B5: db $00;X
L1F77B6: db $00;X
L1F77B7: db $00;X
L1F77B8: db $00;X
L1F77B9: db $20;X
L1F77BA: db $00;X
L1F77BB: db $00;X
L1F77BC: db $10;X
L1F77BD: db $80;X
L1F77BE: db $00;X
L1F77BF: db $00;X
L1F77C0: db $00;X
L1F77C1: db $08;X
L1F77C2: db $00;X
L1F77C3: db $00;X
L1F77C4: db $04;X
L1F77C5: db $40;X
L1F77C6: db $80;X
L1F77C7: db $01;X
L1F77C8: db $00;X
L1F77C9: db $90;X
L1F77CA: db $10;X
L1F77CB: db $08;X
L1F77CC: db $00;X
L1F77CD: db $00;X
L1F77CE: db $00;X
L1F77CF: db $40;X
L1F77D0: db $10;X
L1F77D1: db $00;X
L1F77D2: db $00;X
L1F77D3: db $00;X
L1F77D4: db $00;X
L1F77D5: db $00;X
L1F77D6: db $00;X
L1F77D7: db $00;X
L1F77D8: db $00;X
L1F77D9: db $00;X
L1F77DA: db $40;X
L1F77DB: db $00;X
L1F77DC: db $80;X
L1F77DD: db $41;X
L1F77DE: db $00;X
L1F77DF: db $00;X
L1F77E0: db $01;X
L1F77E1: db $00;X
L1F77E2: db $40;X
L1F77E3: db $00;X
L1F77E4: db $00;X
L1F77E5: db $00;X
L1F77E6: db $00;X
L1F77E7: db $00;X
L1F77E8: db $00;X
L1F77E9: db $00;X
L1F77EA: db $00;X
L1F77EB: db $00;X
L1F77EC: db $00;X
L1F77ED: db $00;X
L1F77EE: db $00;X
L1F77EF: db $00;X
L1F77F0: db $00;X
L1F77F1: db $04;X
L1F77F2: db $00;X
L1F77F3: db $01;X
L1F77F4: db $00;X
L1F77F5: db $00;X
L1F77F6: db $00;X
L1F77F7: db $00;X
L1F77F8: db $00;X
L1F77F9: db $00;X
L1F77FA: db $80;X
L1F77FB: db $00;X
L1F77FC: db $00;X
L1F77FD: db $00;X
L1F77FE: db $00;X
L1F77FF: db $00;X
L1F7800: db $FF;X
L1F7801: db $FF;X
L1F7802: db $FF;X
L1F7803: db $FF;X
L1F7804: db $EF;X
L1F7805: db $FF;X
L1F7806: db $FF;X
L1F7807: db $F7;X
L1F7808: db $FF;X
L1F7809: db $FF;X
L1F780A: db $FF;X
L1F780B: db $FF;X
L1F780C: db $FF;X
L1F780D: db $FF;X
L1F780E: db $EF;X
L1F780F: db $FF;X
L1F7810: db $FD;X
L1F7811: db $FF;X
L1F7812: db $FF;X
L1F7813: db $FF;X
L1F7814: db $FF;X
L1F7815: db $FF;X
L1F7816: db $FF;X
L1F7817: db $FF;X
L1F7818: db $FF;X
L1F7819: db $FF;X
L1F781A: db $F7;X
L1F781B: db $FF;X
L1F781C: db $FF;X
L1F781D: db $FF;X
L1F781E: db $FE;X
L1F781F: db $FF;X
L1F7820: db $FF;X
L1F7821: db $FF;X
L1F7822: db $FF;X
L1F7823: db $FF;X
L1F7824: db $FF;X
L1F7825: db $FF;X
L1F7826: db $FF;X
L1F7827: db $FF;X
L1F7828: db $FF;X
L1F7829: db $FF;X
L1F782A: db $FF;X
L1F782B: db $FF;X
L1F782C: db $FF;X
L1F782D: db $FF;X
L1F782E: db $FF;X
L1F782F: db $FD;X
L1F7830: db $FF;X
L1F7831: db $7F;X
L1F7832: db $FF;X
L1F7833: db $FF;X
L1F7834: db $FF;X
L1F7835: db $FF;X
L1F7836: db $FF;X
L1F7837: db $FF;X
L1F7838: db $FF;X
L1F7839: db $FF;X
L1F783A: db $FF;X
L1F783B: db $FF;X
L1F783C: db $FF;X
L1F783D: db $FF;X
L1F783E: db $FF;X
L1F783F: db $FF;X
L1F7840: db $FF;X
L1F7841: db $FF;X
L1F7842: db $BF;X
L1F7843: db $FF;X
L1F7844: db $FF;X
L1F7845: db $FF;X
L1F7846: db $FF;X
L1F7847: db $FF;X
L1F7848: db $DF;X
L1F7849: db $FF;X
L1F784A: db $FF;X
L1F784B: db $BF;X
L1F784C: db $FF;X
L1F784D: db $FF;X
L1F784E: db $FF;X
L1F784F: db $BF;X
L1F7850: db $FD;X
L1F7851: db $F7;X
L1F7852: db $FF;X
L1F7853: db $FF;X
L1F7854: db $F3;X
L1F7855: db $FF;X
L1F7856: db $FF;X
L1F7857: db $FF;X
L1F7858: db $FF;X
L1F7859: db $FF;X
L1F785A: db $FF;X
L1F785B: db $FF;X
L1F785C: db $5F;X
L1F785D: db $7F;X
L1F785E: db $FF;X
L1F785F: db $FF;X
L1F7860: db $FF;X
L1F7861: db $FF;X
L1F7862: db $EF;X
L1F7863: db $FF;X
L1F7864: db $FF;X
L1F7865: db $7F;X
L1F7866: db $FD;X
L1F7867: db $FF;X
L1F7868: db $CF;X
L1F7869: db $FF;X
L1F786A: db $FF;X
L1F786B: db $F7;X
L1F786C: db $FF;X
L1F786D: db $FF;X
L1F786E: db $FF;X
L1F786F: db $FE;X
L1F7870: db $BF;X
L1F7871: db $FF;X
L1F7872: db $FF;X
L1F7873: db $DF;X
L1F7874: db $FF;X
L1F7875: db $FF;X
L1F7876: db $FF;X
L1F7877: db $FD;X
L1F7878: db $FF;X
L1F7879: db $FF;X
L1F787A: db $7F;X
L1F787B: db $BF;X
L1F787C: db $FF;X
L1F787D: db $FF;X
L1F787E: db $FF;X
L1F787F: db $FF;X
L1F7880: db $01;X
L1F7881: db $00;X
L1F7882: db $00;X
L1F7883: db $10;X
L1F7884: db $00;X
L1F7885: db $00;X
L1F7886: db $80;X
L1F7887: db $10;X
L1F7888: db $00;X
L1F7889: db $00;X
L1F788A: db $00;X
L1F788B: db $00;X
L1F788C: db $00;X
L1F788D: db $80;X
L1F788E: db $00;X
L1F788F: db $00;X
L1F7890: db $C0;X
L1F7891: db $04;X
L1F7892: db $00;X
L1F7893: db $00;X
L1F7894: db $00;X
L1F7895: db $00;X
L1F7896: db $01;X
L1F7897: db $00;X
L1F7898: db $00;X
L1F7899: db $00;X
L1F789A: db $00;X
L1F789B: db $00;X
L1F789C: db $01;X
L1F789D: db $00;X
L1F789E: db $02;X
L1F789F: db $00;X
L1F78A0: db $00;X
L1F78A1: db $00;X
L1F78A2: db $01;X
L1F78A3: db $02;X
L1F78A4: db $00;X
L1F78A5: db $04;X
L1F78A6: db $04;X
L1F78A7: db $00;X
L1F78A8: db $00;X
L1F78A9: db $02;X
L1F78AA: db $00;X
L1F78AB: db $00;X
L1F78AC: db $04;X
L1F78AD: db $00;X
L1F78AE: db $00;X
L1F78AF: db $00;X
L1F78B0: db $00;X
L1F78B1: db $00;X
L1F78B2: db $00;X
L1F78B3: db $04;X
L1F78B4: db $04;X
L1F78B5: db $40;X
L1F78B6: db $04;X
L1F78B7: db $00;X
L1F78B8: db $00;X
L1F78B9: db $00;X
L1F78BA: db $00;X
L1F78BB: db $00;X
L1F78BC: db $00;X
L1F78BD: db $00;X
L1F78BE: db $00;X
L1F78BF: db $00;X
L1F78C0: db $00;X
L1F78C1: db $00;X
L1F78C2: db $02;X
L1F78C3: db $00;X
L1F78C4: db $20;X
L1F78C5: db $01;X
L1F78C6: db $00;X
L1F78C7: db $00;X
L1F78C8: db $00;X
L1F78C9: db $00;X
L1F78CA: db $10;X
L1F78CB: db $00;X
L1F78CC: db $08;X
L1F78CD: db $00;X
L1F78CE: db $00;X
L1F78CF: db $00;X
L1F78D0: db $00;X
L1F78D1: db $00;X
L1F78D2: db $10;X
L1F78D3: db $00;X
L1F78D4: db $18;X
L1F78D5: db $00;X
L1F78D6: db $00;X
L1F78D7: db $04;X
L1F78D8: db $00;X
L1F78D9: db $20;X
L1F78DA: db $00;X
L1F78DB: db $00;X
L1F78DC: db $00;X
L1F78DD: db $00;X
L1F78DE: db $00;X
L1F78DF: db $01;X
L1F78E0: db $00;X
L1F78E1: db $00;X
L1F78E2: db $01;X
L1F78E3: db $00;X
L1F78E4: db $A1;X
L1F78E5: db $00;X
L1F78E6: db $00;X
L1F78E7: db $00;X
L1F78E8: db $00;X
L1F78E9: db $00;X
L1F78EA: db $00;X
L1F78EB: db $00;X
L1F78EC: db $00;X
L1F78ED: db $80;X
L1F78EE: db $00;X
L1F78EF: db $04;X
L1F78F0: db $00;X
L1F78F1: db $02;X
L1F78F2: db $01;X
L1F78F3: db $00;X
L1F78F4: db $00;X
L1F78F5: db $80;X
L1F78F6: db $00;X
L1F78F7: db $04;X
L1F78F8: db $00;X
L1F78F9: db $00;X
L1F78FA: db $00;X
L1F78FB: db $00;X
L1F78FC: db $00;X
L1F78FD: db $00;X
L1F78FE: db $00;X
L1F78FF: db $00;X
L1F7900: db $FE;X
L1F7901: db $D7;X
L1F7902: db $FF;X
L1F7903: db $FE;X
L1F7904: db $FF;X
L1F7905: db $FF;X
L1F7906: db $FF;X
L1F7907: db $FF;X
L1F7908: db $FF;X
L1F7909: db $FF;X
L1F790A: db $F3;X
L1F790B: db $FF;X
L1F790C: db $FF;X
L1F790D: db $FF;X
L1F790E: db $FF;X
L1F790F: db $FF;X
L1F7910: db $F9;X
L1F7911: db $FF;X
L1F7912: db $FF;X
L1F7913: db $FF;X
L1F7914: db $FF;X
L1F7915: db $FF;X
L1F7916: db $FF;X
L1F7917: db $FF;X
L1F7918: db $FF;X
L1F7919: db $FF;X
L1F791A: db $FF;X
L1F791B: db $FF;X
L1F791C: db $FF;X
L1F791D: db $FF;X
L1F791E: db $FF;X
L1F791F: db $FF;X
L1F7920: db $EF;X
L1F7921: db $FF;X
L1F7922: db $FF;X
L1F7923: db $FF;X
L1F7924: db $FF;X
L1F7925: db $FF;X
L1F7926: db $FB;X
L1F7927: db $FF;X
L1F7928: db $FF;X
L1F7929: db $FF;X
L1F792A: db $FF;X
L1F792B: db $FF;X
L1F792C: db $FD;X
L1F792D: db $DF;X
L1F792E: db $FF;X
L1F792F: db $FF;X
L1F7930: db $EF;X
L1F7931: db $FF;X
L1F7932: db $FF;X
L1F7933: db $FF;X
L1F7934: db $BF;X
L1F7935: db $FD;X
L1F7936: db $FF;X
L1F7937: db $FF;X
L1F7938: db $FF;X
L1F7939: db $FF;X
L1F793A: db $FF;X
L1F793B: db $FF;X
L1F793C: db $FF;X
L1F793D: db $FF;X
L1F793E: db $FF;X
L1F793F: db $FF;X
L1F7940: db $FF;X
L1F7941: db $FF;X
L1F7942: db $FF;X
L1F7943: db $FF;X
L1F7944: db $FF;X
L1F7945: db $FF;X
L1F7946: db $FF;X
L1F7947: db $7F;X
L1F7948: db $FF;X
L1F7949: db $7F;X
L1F794A: db $FF;X
L1F794B: db $F7;X
L1F794C: db $FF;X
L1F794D: db $FF;X
L1F794E: db $FF;X
L1F794F: db $FF;X
L1F7950: db $FF;X
L1F7951: db $7F;X
L1F7952: db $FF;X
L1F7953: db $FF;X
L1F7954: db $FF;X
L1F7955: db $BF;X
L1F7956: db $FF;X
L1F7957: db $FB;X
L1F7958: db $FF;X
L1F7959: db $FF;X
L1F795A: db $FF;X
L1F795B: db $FF;X
L1F795C: db $FF;X
L1F795D: db $FF;X
L1F795E: db $FF;X
L1F795F: db $FF;X
L1F7960: db $FF;X
L1F7961: db $FF;X
L1F7962: db $FF;X
L1F7963: db $FF;X
L1F7964: db $FF;X
L1F7965: db $FF;X
L1F7966: db $FF;X
L1F7967: db $FF;X
L1F7968: db $FF;X
L1F7969: db $FF;X
L1F796A: db $DF;X
L1F796B: db $FB;X
L1F796C: db $FF;X
L1F796D: db $FF;X
L1F796E: db $FF;X
L1F796F: db $FF;X
L1F7970: db $BF;X
L1F7971: db $EF;X
L1F7972: db $FF;X
L1F7973: db $FF;X
L1F7974: db $FF;X
L1F7975: db $FF;X
L1F7976: db $FF;X
L1F7977: db $FF;X
L1F7978: db $FF;X
L1F7979: db $FE;X
L1F797A: db $7D;X
L1F797B: db $FF;X
L1F797C: db $EF;X
L1F797D: db $F6;X
L1F797E: db $BF;X
L1F797F: db $FF;X
L1F7980: db $00;X
L1F7981: db $00;X
L1F7982: db $00;X
L1F7983: db $00;X
L1F7984: db $00;X
L1F7985: db $00;X
L1F7986: db $08;X
L1F7987: db $00;X
L1F7988: db $00;X
L1F7989: db $00;X
L1F798A: db $00;X
L1F798B: db $00;X
L1F798C: db $00;X
L1F798D: db $00;X
L1F798E: db $00;X
L1F798F: db $00;X
L1F7990: db $02;X
L1F7991: db $00;X
L1F7992: db $00;X
L1F7993: db $00;X
L1F7994: db $00;X
L1F7995: db $00;X
L1F7996: db $00;X
L1F7997: db $00;X
L1F7998: db $04;X
L1F7999: db $00;X
L1F799A: db $00;X
L1F799B: db $04;X
L1F799C: db $00;X
L1F799D: db $00;X
L1F799E: db $10;X
L1F799F: db $00;X
L1F79A0: db $00;X
L1F79A1: db $00;X
L1F79A2: db $00;X
L1F79A3: db $02;X
L1F79A4: db $00;X
L1F79A5: db $00;X
L1F79A6: db $00;X
L1F79A7: db $00;X
L1F79A8: db $00;X
L1F79A9: db $00;X
L1F79AA: db $00;X
L1F79AB: db $00;X
L1F79AC: db $00;X
L1F79AD: db $00;X
L1F79AE: db $00;X
L1F79AF: db $00;X
L1F79B0: db $00;X
L1F79B1: db $00;X
L1F79B2: db $00;X
L1F79B3: db $02;X
L1F79B4: db $00;X
L1F79B5: db $00;X
L1F79B6: db $20;X
L1F79B7: db $02;X
L1F79B8: db $00;X
L1F79B9: db $00;X
L1F79BA: db $04;X
L1F79BB: db $08;X
L1F79BC: db $00;X
L1F79BD: db $00;X
L1F79BE: db $00;X
L1F79BF: db $00;X
L1F79C0: db $00;X
L1F79C1: db $00;X
L1F79C2: db $00;X
L1F79C3: db $00;X
L1F79C4: db $00;X
L1F79C5: db $04;X
L1F79C6: db $00;X
L1F79C7: db $08;X
L1F79C8: db $00;X
L1F79C9: db $00;X
L1F79CA: db $00;X
L1F79CB: db $00;X
L1F79CC: db $12;X
L1F79CD: db $00;X
L1F79CE: db $00;X
L1F79CF: db $00;X
L1F79D0: db $10;X
L1F79D1: db $00;X
L1F79D2: db $21;X
L1F79D3: db $00;X
L1F79D4: db $20;X
L1F79D5: db $00;X
L1F79D6: db $10;X
L1F79D7: db $00;X
L1F79D8: db $00;X
L1F79D9: db $01;X
L1F79DA: db $04;X
L1F79DB: db $01;X
L1F79DC: db $00;X
L1F79DD: db $00;X
L1F79DE: db $08;X
L1F79DF: db $00;X
L1F79E0: db $00;X
L1F79E1: db $10;X
L1F79E2: db $80;X
L1F79E3: db $00;X
L1F79E4: db $00;X
L1F79E5: db $00;X
L1F79E6: db $00;X
L1F79E7: db $00;X
L1F79E8: db $80;X
L1F79E9: db $00;X
L1F79EA: db $00;X
L1F79EB: db $00;X
L1F79EC: db $00;X
L1F79ED: db $00;X
L1F79EE: db $00;X
L1F79EF: db $00;X
L1F79F0: db $00;X
L1F79F1: db $00;X
L1F79F2: db $40;X
L1F79F3: db $00;X
L1F79F4: db $00;X
L1F79F5: db $00;X
L1F79F6: db $00;X
L1F79F7: db $00;X
L1F79F8: db $00;X
L1F79F9: db $00;X
L1F79FA: db $00;X
L1F79FB: db $00;X
L1F79FC: db $20;X
L1F79FD: db $80;X
L1F79FE: db $00;X
L1F79FF: db $00;X
L1F7A00: db $FF;X
L1F7A01: db $FF;X
L1F7A02: db $7F;X
L1F7A03: db $FF;X
L1F7A04: db $F7;X
L1F7A05: db $FF;X
L1F7A06: db $BF;X
L1F7A07: db $FF;X
L1F7A08: db $FE;X
L1F7A09: db $EF;X
L1F7A0A: db $FF;X
L1F7A0B: db $FF;X
L1F7A0C: db $FF;X
L1F7A0D: db $FF;X
L1F7A0E: db $FF;X
L1F7A0F: db $DF;X
L1F7A10: db $FF;X
L1F7A11: db $FF;X
L1F7A12: db $FF;X
L1F7A13: db $FF;X
L1F7A14: db $FF;X
L1F7A15: db $FF;X
L1F7A16: db $FF;X
L1F7A17: db $FF;X
L1F7A18: db $FF;X
L1F7A19: db $FB;X
L1F7A1A: db $FF;X
L1F7A1B: db $FF;X
L1F7A1C: db $DF;X
L1F7A1D: db $FF;X
L1F7A1E: db $FF;X
L1F7A1F: db $FF;X
L1F7A20: db $FF;X
L1F7A21: db $FD;X
L1F7A22: db $FF;X
L1F7A23: db $FF;X
L1F7A24: db $FF;X
L1F7A25: db $7F;X
L1F7A26: db $FF;X
L1F7A27: db $FB;X
L1F7A28: db $BB;X
L1F7A29: db $FF;X
L1F7A2A: db $FF;X
L1F7A2B: db $7F;X
L1F7A2C: db $FF;X
L1F7A2D: db $FF;X
L1F7A2E: db $FF;X
L1F7A2F: db $FF;X
L1F7A30: db $FF;X
L1F7A31: db $FF;X
L1F7A32: db $FF;X
L1F7A33: db $FF;X
L1F7A34: db $FF;X
L1F7A35: db $FF;X
L1F7A36: db $FF;X
L1F7A37: db $FF;X
L1F7A38: db $EF;X
L1F7A39: db $FF;X
L1F7A3A: db $FF;X
L1F7A3B: db $7E;X
L1F7A3C: db $FF;X
L1F7A3D: db $FF;X
L1F7A3E: db $DF;X
L1F7A3F: db $FF;X
L1F7A40: db $FF;X
L1F7A41: db $FB;X
L1F7A42: db $FF;X
L1F7A43: db $FF;X
L1F7A44: db $FF;X
L1F7A45: db $FF;X
L1F7A46: db $FF;X
L1F7A47: db $FF;X
L1F7A48: db $FF;X
L1F7A49: db $FF;X
L1F7A4A: db $FF;X
L1F7A4B: db $FF;X
L1F7A4C: db $FF;X
L1F7A4D: db $FF;X
L1F7A4E: db $FF;X
L1F7A4F: db $FF;X
L1F7A50: db $FF;X
L1F7A51: db $BF;X
L1F7A52: db $FF;X
L1F7A53: db $FF;X
L1F7A54: db $FF;X
L1F7A55: db $FF;X
L1F7A56: db $FD;X
L1F7A57: db $FF;X
L1F7A58: db $FF;X
L1F7A59: db $FF;X
L1F7A5A: db $7B;X
L1F7A5B: db $FF;X
L1F7A5C: db $FF;X
L1F7A5D: db $FF;X
L1F7A5E: db $FF;X
L1F7A5F: db $FF;X
L1F7A60: db $FF;X
L1F7A61: db $FF;X
L1F7A62: db $FF;X
L1F7A63: db $FF;X
L1F7A64: db $FF;X
L1F7A65: db $FF;X
L1F7A66: db $FF;X
L1F7A67: db $FF;X
L1F7A68: db $7F;X
L1F7A69: db $FF;X
L1F7A6A: db $FF;X
L1F7A6B: db $FF;X
L1F7A6C: db $FF;X
L1F7A6D: db $FF;X
L1F7A6E: db $FF;X
L1F7A6F: db $FF;X
L1F7A70: db $FF;X
L1F7A71: db $FF;X
L1F7A72: db $FF;X
L1F7A73: db $FF;X
L1F7A74: db $EF;X
L1F7A75: db $FF;X
L1F7A76: db $FE;X
L1F7A77: db $FF;X
L1F7A78: db $FF;X
L1F7A79: db $FF;X
L1F7A7A: db $FF;X
L1F7A7B: db $FF;X
L1F7A7C: db $FF;X
L1F7A7D: db $FF;X
L1F7A7E: db $FF;X
L1F7A7F: db $FF;X
L1F7A80: db $00;X
L1F7A81: db $00;X
L1F7A82: db $00;X
L1F7A83: db $10;X
L1F7A84: db $00;X
L1F7A85: db $00;X
L1F7A86: db $04;X
L1F7A87: db $08;X
L1F7A88: db $00;X
L1F7A89: db $00;X
L1F7A8A: db $00;X
L1F7A8B: db $00;X
L1F7A8C: db $00;X
L1F7A8D: db $00;X
L1F7A8E: db $02;X
L1F7A8F: db $00;X
L1F7A90: db $00;X
L1F7A91: db $00;X
L1F7A92: db $C0;X
L1F7A93: db $00;X
L1F7A94: db $00;X
L1F7A95: db $00;X
L1F7A96: db $80;X
L1F7A97: db $00;X
L1F7A98: db $01;X
L1F7A99: db $00;X
L1F7A9A: db $00;X
L1F7A9B: db $00;X
L1F7A9C: db $00;X
L1F7A9D: db $00;X
L1F7A9E: db $41;X
L1F7A9F: db $00;X
L1F7AA0: db $00;X
L1F7AA1: db $03;X
L1F7AA2: db $00;X
L1F7AA3: db $00;X
L1F7AA4: db $00;X
L1F7AA5: db $00;X
L1F7AA6: db $00;X
L1F7AA7: db $00;X
L1F7AA8: db $00;X
L1F7AA9: db $10;X
L1F7AAA: db $00;X
L1F7AAB: db $04;X
L1F7AAC: db $01;X
L1F7AAD: db $00;X
L1F7AAE: db $00;X
L1F7AAF: db $28;X
L1F7AB0: db $00;X
L1F7AB1: db $00;X
L1F7AB2: db $00;X
L1F7AB3: db $00;X
L1F7AB4: db $02;X
L1F7AB5: db $00;X
L1F7AB6: db $00;X
L1F7AB7: db $00;X
L1F7AB8: db $00;X
L1F7AB9: db $00;X
L1F7ABA: db $00;X
L1F7ABB: db $02;X
L1F7ABC: db $00;X
L1F7ABD: db $00;X
L1F7ABE: db $00;X
L1F7ABF: db $00;X
L1F7AC0: db $00;X
L1F7AC1: db $00;X
L1F7AC2: db $00;X
L1F7AC3: db $00;X
L1F7AC4: db $00;X
L1F7AC5: db $00;X
L1F7AC6: db $00;X
L1F7AC7: db $00;X
L1F7AC8: db $00;X
L1F7AC9: db $00;X
L1F7ACA: db $00;X
L1F7ACB: db $00;X
L1F7ACC: db $00;X
L1F7ACD: db $00;X
L1F7ACE: db $00;X
L1F7ACF: db $00;X
L1F7AD0: db $00;X
L1F7AD1: db $00;X
L1F7AD2: db $01;X
L1F7AD3: db $00;X
L1F7AD4: db $10;X
L1F7AD5: db $00;X
L1F7AD6: db $00;X
L1F7AD7: db $00;X
L1F7AD8: db $00;X
L1F7AD9: db $40;X
L1F7ADA: db $20;X
L1F7ADB: db $00;X
L1F7adc: db $00;X
L1F7add: db $10;X
L1F7ADE: db $00;X
L1F7ADF: db $00;X
L1F7AE0: db $01;X
L1F7AE1: db $00;X
L1F7AE2: db $08;X
L1F7AE3: db $00;X
L1F7AE4: db $00;X
L1F7AE5: db $00;X
L1F7AE6: db $08;X
L1F7AE7: db $40;X
L1F7AE8: db $00;X
L1F7AE9: db $00;X
L1F7AEA: db $00;X
L1F7AEB: db $00;X
L1F7AEC: db $00;X
L1F7AED: db $41;X
L1F7AEE: db $00;X
L1F7AEF: db $00;X
L1F7AF0: db $00;X
L1F7AF1: db $00;X
L1F7AF2: db $00;X
L1F7AF3: db $00;X
L1F7AF4: db $00;X
L1F7AF5: db $00;X
L1F7AF6: db $00;X
L1F7AF7: db $00;X
L1F7AF8: db $20;X
L1F7AF9: db $00;X
L1F7AFA: db $00;X
L1F7AFB: db $00;X
L1F7AFC: db $00;X
L1F7AFD: db $00;X
L1F7AFE: db $00;X
L1F7AFF: db $00;X
L1F7B00: db $FF;X
L1F7B01: db $FF;X
L1F7B02: db $FF;X
L1F7B03: db $DF;X
L1F7B04: db $FF;X
L1F7B05: db $FF;X
L1F7B06: db $FF;X
L1F7B07: db $FF;X
L1F7B08: db $FF;X
L1F7B09: db $FF;X
L1F7B0A: db $FF;X
L1F7B0B: db $FF;X
L1F7B0C: db $FF;X
L1F7B0D: db $FF;X
L1F7B0E: db $FF;X
L1F7B0F: db $FB;X
L1F7B10: db $FF;X
L1F7B11: db $FF;X
L1F7B12: db $BF;X
L1F7B13: db $FF;X
L1F7B14: db $FB;X
L1F7B15: db $FF;X
L1F7B16: db $FF;X
L1F7B17: db $FF;X
L1F7B18: db $FF;X
L1F7B19: db $FF;X
L1F7B1A: db $FF;X
L1F7B1B: db $FF;X
L1F7B1C: db $FF;X
L1F7B1D: db $FF;X
L1F7B1E: db $FF;X
L1F7B1F: db $FF;X
L1F7B20: db $FF;X
L1F7B21: db $FF;X
L1F7B22: db $FF;X
L1F7B23: db $FF;X
L1F7B24: db $FF;X
L1F7B25: db $FF;X
L1F7B26: db $FF;X
L1F7B27: db $FF;X
L1F7B28: db $FF;X
L1F7B29: db $FF;X
L1F7B2A: db $FF;X
L1F7B2B: db $FC;X
L1F7B2C: db $DF;X
L1F7B2D: db $FF;X
L1F7B2E: db $FF;X
L1F7B2F: db $FF;X
L1F7B30: db $FF;X
L1F7B31: db $FF;X
L1F7B32: db $FF;X
L1F7B33: db $FF;X
L1F7B34: db $FF;X
L1F7B35: db $FF;X
L1F7B36: db $FF;X
L1F7B37: db $FF;X
L1F7B38: db $FF;X
L1F7B39: db $FF;X
L1F7B3A: db $FF;X
L1F7B3B: db $FF;X
L1F7B3C: db $FF;X
L1F7B3D: db $FF;X
L1F7B3E: db $FB;X
L1F7B3F: db $FF;X
L1F7B40: db $FF;X
L1F7B41: db $FF;X
L1F7B42: db $FF;X
L1F7B43: db $FF;X
L1F7B44: db $FF;X
L1F7B45: db $7F;X
L1F7B46: db $FF;X
L1F7B47: db $FF;X
L1F7B48: db $FF;X
L1F7B49: db $FD;X
L1F7B4A: db $FF;X
L1F7B4B: db $FF;X
L1F7B4C: db $FF;X
L1F7B4D: db $FF;X
L1F7B4E: db $FF;X
L1F7B4F: db $FF;X
L1F7B50: db $FF;X
L1F7B51: db $FF;X
L1F7B52: db $FF;X
L1F7B53: db $FF;X
L1F7B54: db $FD;X
L1F7B55: db $FF;X
L1F7B56: db $FF;X
L1F7B57: db $FF;X
L1F7B58: db $FF;X
L1F7B59: db $FF;X
L1F7B5A: db $7F;X
L1F7B5B: db $FF;X
L1F7B5C: db $FF;X
L1F7B5D: db $BF;X
L1F7B5E: db $FF;X
L1F7B5F: db $EF;X
L1F7B60: db $FF;X
L1F7B61: db $FF;X
L1F7B62: db $FF;X
L1F7B63: db $FF;X
L1F7B64: db $DF;X
L1F7B65: db $FE;X
L1F7B66: db $FF;X
L1F7B67: db $FF;X
L1F7B68: db $FF;X
L1F7B69: db $FF;X
L1F7B6A: db $FF;X
L1F7B6B: db $FF;X
L1F7B6C: db $FC;X
L1F7B6D: db $FF;X
L1F7B6E: db $FF;X
L1F7B6F: db $EF;X
L1F7B70: db $FF;X
L1F7B71: db $FF;X
L1F7B72: db $FF;X
L1F7B73: db $FF;X
L1F7B74: db $FF;X
L1F7B75: db $FF;X
L1F7B76: db $FF;X
L1F7B77: db $FF;X
L1F7B78: db $FF;X
L1F7B79: db $FF;X
L1F7B7A: db $FF;X
L1F7B7B: db $FF;X
L1F7B7C: db $FF;X
L1F7B7D: db $FF;X
L1F7B7E: db $FF;X
L1F7B7F: db $FF;X
L1F7B80: db $00;X
L1F7B81: db $00;X
L1F7B82: db $00;X
L1F7B83: db $00;X
L1F7B84: db $00;X
L1F7B85: db $00;X
L1F7B86: db $00;X
L1F7B87: db $00;X
L1F7B88: db $00;X
L1F7B89: db $00;X
L1F7B8A: db $01;X
L1F7B8B: db $00;X
L1F7B8C: db $00;X
L1F7B8D: db $00;X
L1F7B8E: db $00;X
L1F7B8F: db $00;X
L1F7B90: db $00;X
L1F7B91: db $00;X
L1F7B92: db $40;X
L1F7B93: db $00;X
L1F7B94: db $00;X
L1F7B95: db $00;X
L1F7B96: db $00;X
L1F7B97: db $00;X
L1F7B98: db $00;X
L1F7B99: db $00;X
L1F7B9A: db $04;X
L1F7B9B: db $00;X
L1F7B9C: db $00;X
L1F7B9D: db $00;X
L1F7B9E: db $00;X
L1F7B9F: db $20;X
L1F7BA0: db $40;X
L1F7BA1: db $00;X
L1F7BA2: db $60;X
L1F7BA3: db $00;X
L1F7BA4: db $08;X
L1F7BA5: db $00;X
L1F7BA6: db $04;X
L1F7BA7: db $20;X
L1F7BA8: db $00;X
L1F7BA9: db $00;X
L1F7BAA: db $10;X
L1F7BAB: db $00;X
L1F7BAC: db $00;X
L1F7BAD: db $00;X
L1F7BAE: db $00;X
L1F7BAF: db $00;X
L1F7BB0: db $00;X
L1F7BB1: db $00;X
L1F7BB2: db $80;X
L1F7BB3: db $00;X
L1F7BB4: db $00;X
L1F7BB5: db $01;X
L1F7BB6: db $00;X
L1F7BB7: db $01;X
L1F7BB8: db $01;X
L1F7BB9: db $00;X
L1F7BBA: db $00;X
L1F7BBB: db $00;X
L1F7BBC: db $40;X
L1F7BBD: db $00;X
L1F7BBE: db $00;X
L1F7BBF: db $00;X
L1F7BC0: db $00;X
L1F7BC1: db $02;X
L1F7BC2: db $00;X
L1F7BC3: db $20;X
L1F7BC4: db $00;X
L1F7BC5: db $04;X
L1F7BC6: db $80;X
L1F7BC7: db $00;X
L1F7BC8: db $02;X
L1F7BC9: db $00;X
L1F7BCA: db $00;X
L1F7BCB: db $02;X
L1F7BCC: db $80;X
L1F7BCD: db $00;X
L1F7BCE: db $80;X
L1F7BCF: db $00;X
L1F7BD0: db $00;X
L1F7BD1: db $00;X
L1F7BD2: db $04;X
L1F7BD3: db $00;X
L1F7BD4: db $00;X
L1F7BD5: db $01;X
L1F7BD6: db $10;X
L1F7BD7: db $00;X
L1F7BD8: db $08;X
L1F7BD9: db $02;X
L1F7BDA: db $00;X
L1F7BDB: db $00;X
L1F7BDC: db $24;X
L1F7BDD: db $00;X
L1F7BDE: db $00;X
L1F7BDF: db $00;X
L1F7BE0: db $80;X
L1F7BE1: db $00;X
L1F7BE2: db $02;X
L1F7BE3: db $02;X
L1F7BE4: db $00;X
L1F7BE5: db $00;X
L1F7BE6: db $00;X
L1F7BE7: db $00;X
L1F7BE8: db $02;X
L1F7BE9: db $00;X
L1F7BEA: db $00;X
L1F7BEB: db $00;X
L1F7BEC: db $40;X
L1F7BED: db $00;X
L1F7BEE: db $80;X
L1F7BEF: db $00;X
L1F7BF0: db $08;X
L1F7BF1: db $00;X
L1F7BF2: db $00;X
L1F7BF3: db $00;X
L1F7BF4: db $00;X
L1F7BF5: db $00;X
L1F7BF6: db $00;X
L1F7BF7: db $00;X
L1F7BF8: db $10;X
L1F7BF9: db $00;X
L1F7BFA: db $00;X
L1F7BFB: db $00;X
L1F7BFC: db $00;X
L1F7BFD: db $00;X
L1F7BFE: db $00;X
L1F7BFF: db $00;X
L1F7C00: db $FF;X
L1F7C01: db $BF;X
L1F7C02: db $FB;X
L1F7C03: db $FF;X
L1F7C04: db $FF;X
L1F7C05: db $FF;X
L1F7C06: db $7F;X
L1F7C07: db $FF;X
L1F7C08: db $EF;X
L1F7C09: db $FF;X
L1F7C0A: db $FF;X
L1F7C0B: db $FF;X
L1F7C0C: db $EF;X
L1F7C0D: db $FF;X
L1F7C0E: db $FF;X
L1F7C0F: db $FF;X
L1F7C10: db $DF;X
L1F7C11: db $FF;X
L1F7C12: db $FF;X
L1F7C13: db $F7;X
L1F7C14: db $DF;X
L1F7C15: db $FF;X
L1F7C16: db $FF;X
L1F7C17: db $FF;X
L1F7C18: db $FF;X
L1F7C19: db $FF;X
L1F7C1A: db $FF;X
L1F7C1B: db $FF;X
L1F7C1C: db $FF;X
L1F7C1D: db $FF;X
L1F7C1E: db $F3;X
L1F7C1F: db $FF;X
L1F7C20: db $FF;X
L1F7C21: db $FF;X
L1F7C22: db $FF;X
L1F7C23: db $FF;X
L1F7C24: db $FF;X
L1F7C25: db $FF;X
L1F7C26: db $DF;X
L1F7C27: db $FB;X
L1F7C28: db $FF;X
L1F7C29: db $FF;X
L1F7C2A: db $FF;X
L1F7C2B: db $FF;X
L1F7C2C: db $FF;X
L1F7C2D: db $FF;X
L1F7C2E: db $FF;X
L1F7C2F: db $FF;X
L1F7C30: db $FF;X
L1F7C31: db $FF;X
L1F7C32: db $FF;X
L1F7C33: db $FF;X
L1F7C34: db $FF;X
L1F7C35: db $FF;X
L1F7C36: db $FF;X
L1F7C37: db $FF;X
L1F7C38: db $FF;X
L1F7C39: db $FF;X
L1F7C3A: db $FF;X
L1F7C3B: db $FF;X
L1F7C3C: db $FF;X
L1F7C3D: db $FF;X
L1F7C3E: db $FF;X
L1F7C3F: db $FF;X
L1F7C40: db $FF;X
L1F7C41: db $7E;X
L1F7C42: db $FF;X
L1F7C43: db $FF;X
L1F7C44: db $FF;X
L1F7C45: db $FF;X
L1F7C46: db $F7;X
L1F7C47: db $FF;X
L1F7C48: db $FF;X
L1F7C49: db $FF;X
L1F7C4A: db $FF;X
L1F7C4B: db $FF;X
L1F7C4C: db $FF;X
L1F7C4D: db $FF;X
L1F7C4E: db $FF;X
L1F7C4F: db $FF;X
L1F7C50: db $FF;X
L1F7C51: db $FF;X
L1F7C52: db $FF;X
L1F7C53: db $FF;X
L1F7C54: db $FF;X
L1F7C55: db $FF;X
L1F7C56: db $FF;X
L1F7C57: db $FF;X
L1F7C58: db $FF;X
L1F7C59: db $FF;X
L1F7C5A: db $FF;X
L1F7C5B: db $FF;X
L1F7C5C: db $FF;X
L1F7C5D: db $FF;X
L1F7C5E: db $FF;X
L1F7C5F: db $FF;X
L1F7C60: db $FF;X
L1F7C61: db $FD;X
L1F7C62: db $FF;X
L1F7C63: db $7F;X
L1F7C64: db $FF;X
L1F7C65: db $FF;X
L1F7C66: db $FF;X
L1F7C67: db $FF;X
L1F7C68: db $FF;X
L1F7C69: db $FF;X
L1F7C6A: db $FF;X
L1F7C6B: db $FF;X
L1F7C6C: db $FF;X
L1F7C6D: db $FF;X
L1F7C6E: db $FF;X
L1F7C6F: db $FF;X
L1F7C70: db $FF;X
L1F7C71: db $FF;X
L1F7C72: db $EF;X
L1F7C73: db $FD;X
L1F7C74: db $FF;X
L1F7C75: db $FF;X
L1F7C76: db $FF;X
L1F7C77: db $FF;X
L1F7C78: db $FF;X
L1F7C79: db $FF;X
L1F7C7A: db $FF;X
L1F7C7B: db $FF;X
L1F7C7C: db $FF;X
L1F7C7D: db $FF;X
L1F7C7E: db $FF;X
L1F7C7F: db $FF;X
L1F7C80: db $20;X
L1F7C81: db $00;X
L1F7C82: db $00;X
L1F7C83: db $00;X
L1F7C84: db $10;X
L1F7C85: db $10;X
L1F7C86: db $00;X
L1F7C87: db $00;X
L1F7C88: db $00;X
L1F7C89: db $02;X
L1F7C8A: db $10;X
L1F7C8B: db $00;X
L1F7C8C: db $00;X
L1F7C8D: db $00;X
L1F7C8E: db $00;X
L1F7C8F: db $00;X
L1F7C90: db $00;X
L1F7C91: db $04;X
L1F7C92: db $00;X
L1F7C93: db $00;X
L1F7C94: db $00;X
L1F7C95: db $00;X
L1F7C96: db $00;X
L1F7C97: db $00;X
L1F7C98: db $08;X
L1F7C99: db $00;X
L1F7C9A: db $00;X
L1F7C9B: db $00;X
L1F7C9C: db $00;X
L1F7C9D: db $00;X
L1F7C9E: db $00;X
L1F7C9F: db $00;X
L1F7CA0: db $00;X
L1F7CA1: db $00;X
L1F7CA2: db $00;X
L1F7CA3: db $00;X
L1F7CA4: db $02;X
L1F7CA5: db $00;X
L1F7CA6: db $00;X
L1F7CA7: db $00;X
L1F7CA8: db $90;X
L1F7CA9: db $00;X
L1F7CAA: db $00;X
L1F7CAB: db $00;X
L1F7CAC: db $00;X
L1F7CAD: db $00;X
L1F7CAE: db $01;X
L1F7CAF: db $00;X
L1F7CB0: db $01;X
L1F7CB1: db $00;X
L1F7CB2: db $02;X
L1F7CB3: db $00;X
L1F7CB4: db $00;X
L1F7CB5: db $00;X
L1F7CB6: db $00;X
L1F7CB7: db $00;X
L1F7CB8: db $10;X
L1F7CB9: db $00;X
L1F7CBA: db $00;X
L1F7CBB: db $00;X
L1F7CBC: db $00;X
L1F7CBD: db $40;X
L1F7CBE: db $00;X
L1F7CBF: db $00;X
L1F7CC0: db $00;X
L1F7CC1: db $00;X
L1F7CC2: db $00;X
L1F7CC3: db $80;X
L1F7CC4: db $00;X
L1F7CC5: db $00;X
L1F7CC6: db $00;X
L1F7CC7: db $00;X
L1F7CC8: db $42;X
L1F7CC9: db $00;X
L1F7CCA: db $10;X
L1F7CCB: db $00;X
L1F7CCC: db $00;X
L1F7CCD: db $0C;X
L1F7CCE: db $00;X
L1F7CCF: db $00;X
L1F7CD0: db $A0;X
L1F7CD1: db $00;X
L1F7CD2: db $00;X
L1F7CD3: db $00;X
L1F7CD4: db $00;X
L1F7CD5: db $00;X
L1F7CD6: db $02;X
L1F7CD7: db $00;X
L1F7CD8: db $00;X
L1F7CD9: db $00;X
L1F7CDA: db $00;X
L1F7CDB: db $00;X
L1F7CDC: db $01;X
L1F7CDD: db $00;X
L1F7CDE: db $00;X
L1F7CDF: db $20;X
L1F7CE0: db $00;X
L1F7CE1: db $00;X
L1F7CE2: db $00;X
L1F7CE3: db $00;X
L1F7CE4: db $00;X
L1F7CE5: db $00;X
L1F7CE6: db $81;X
L1F7CE7: db $10;X
L1F7CE8: db $00;X
L1F7CE9: db $04;X
L1F7CEA: db $00;X
L1F7CEB: db $00;X
L1F7CEC: db $04;X
L1F7CED: db $00;X
L1F7CEE: db $00;X
L1F7CEF: db $00;X
L1F7CF0: db $00;X
L1F7CF1: db $00;X
L1F7CF2: db $40;X
L1F7CF3: db $00;X
L1F7CF4: db $00;X
L1F7CF5: db $00;X
L1F7CF6: db $90;X
L1F7CF7: db $00;X
L1F7CF8: db $00;X
L1F7CF9: db $00;X
L1F7CFA: db $00;X
L1F7CFB: db $00;X
L1F7CFC: db $00;X
L1F7CFD: db $02;X
L1F7CFE: db $00;X
L1F7CFF: db $00;X
L1F7D00: db $FF;X
L1F7D01: db $FF;X
L1F7D02: db $FF;X
L1F7D03: db $DF;X
L1F7D04: db $FF;X
L1F7D05: db $FF;X
L1F7D06: db $FF;X
L1F7D07: db $FF;X
L1F7D08: db $FF;X
L1F7D09: db $FF;X
L1F7D0A: db $FF;X
L1F7D0B: db $FF;X
L1F7D0C: db $FF;X
L1F7D0D: db $FF;X
L1F7D0E: db $FF;X
L1F7D0F: db $FF;X
L1F7D10: db $FF;X
L1F7D11: db $BF;X
L1F7D12: db $FF;X
L1F7D13: db $FF;X
L1F7D14: db $FF;X
L1F7D15: db $FF;X
L1F7D16: db $F7;X
L1F7D17: db $FF;X
L1F7D18: db $F7;X
L1F7D19: db $FF;X
L1F7D1A: db $FF;X
L1F7D1B: db $FF;X
L1F7D1C: db $FF;X
L1F7D1D: db $FF;X
L1F7D1E: db $FF;X
L1F7D1F: db $FF;X
L1F7D20: db $FF;X
L1F7D21: db $FF;X
L1F7D22: db $FF;X
L1F7D23: db $FF;X
L1F7D24: db $FF;X
L1F7D25: db $FF;X
L1F7D26: db $FF;X
L1F7D27: db $FE;X
L1F7D28: db $FF;X
L1F7D29: db $FE;X
L1F7D2A: db $FF;X
L1F7D2B: db $FF;X
L1F7D2C: db $FF;X
L1F7D2D: db $F7;X
L1F7D2E: db $FF;X
L1F7D2F: db $FF;X
L1F7D30: db $FF;X
L1F7D31: db $FF;X
L1F7D32: db $FF;X
L1F7D33: db $FF;X
L1F7D34: db $FF;X
L1F7D35: db $FF;X
L1F7D36: db $FF;X
L1F7D37: db $FF;X
L1F7D38: db $FF;X
L1F7D39: db $FF;X
L1F7D3A: db $FF;X
L1F7D3B: db $FE;X
L1F7D3C: db $FF;X
L1F7D3D: db $7F;X
L1F7D3E: db $FF;X
L1F7D3F: db $FF;X
L1F7D40: db $FF;X
L1F7D41: db $FF;X
L1F7D42: db $BF;X
L1F7D43: db $FF;X
L1F7D44: db $BF;X
L1F7D45: db $FF;X
L1F7D46: db $FF;X
L1F7D47: db $FF;X
L1F7D48: db $FF;X
L1F7D49: db $FF;X
L1F7D4A: db $DF;X
L1F7D4B: db $F7;X
L1F7D4C: db $FB;X
L1F7D4D: db $FF;X
L1F7D4E: db $FF;X
L1F7D4F: db $FF;X
L1F7D50: db $F7;X
L1F7D51: db $FF;X
L1F7D52: db $FF;X
L1F7D53: db $BF;X
L1F7D54: db $FF;X
L1F7D55: db $FF;X
L1F7D56: db $7F;X
L1F7D57: db $FF;X
L1F7D58: db $FF;X
L1F7D59: db $FF;X
L1F7D5A: db $BE;X
L1F7D5B: db $D7;X
L1F7D5C: db $F7;X
L1F7D5D: db $FF;X
L1F7D5E: db $BF;X
L1F7D5F: db $FF;X
L1F7D60: db $FF;X
L1F7D61: db $FF;X
L1F7D62: db $FF;X
L1F7D63: db $FF;X
L1F7D64: db $FF;X
L1F7D65: db $FF;X
L1F7D66: db $7E;X
L1F7D67: db $FF;X
L1F7D68: db $FF;X
L1F7D69: db $F7;X
L1F7D6A: db $FF;X
L1F7D6B: db $FF;X
L1F7D6C: db $FF;X
L1F7D6D: db $BF;X
L1F7D6E: db $FF;X
L1F7D6F: db $FF;X
L1F7D70: db $FF;X
L1F7D71: db $FF;X
L1F7D72: db $FF;X
L1F7D73: db $FF;X
L1F7D74: db $FF;X
L1F7D75: db $FF;X
L1F7D76: db $FF;X
L1F7D77: db $FF;X
L1F7D78: db $FF;X
L1F7D79: db $FB;X
L1F7D7A: db $FF;X
L1F7D7B: db $DF;X
L1F7D7C: db $FF;X
L1F7D7D: db $FF;X
L1F7D7E: db $FF;X
L1F7D7F: db $FF;X
L1F7D80: db $04;X
L1F7D81: db $00;X
L1F7D82: db $00;X
L1F7D83: db $00;X
L1F7D84: db $08;X
L1F7D85: db $00;X
L1F7D86: db $80;X
L1F7D87: db $00;X
L1F7D88: db $00;X
L1F7D89: db $00;X
L1F7D8A: db $00;X
L1F7D8B: db $00;X
L1F7D8C: db $00;X
L1F7D8D: db $00;X
L1F7D8E: db $08;X
L1F7D8F: db $00;X
L1F7D90: db $00;X
L1F7D91: db $40;X
L1F7D92: db $00;X
L1F7D93: db $00;X
L1F7D94: db $08;X
L1F7D95: db $00;X
L1F7D96: db $00;X
L1F7D97: db $00;X
L1F7D98: db $08;X
L1F7D99: db $00;X
L1F7D9A: db $00;X
L1F7D9B: db $00;X
L1F7D9C: db $00;X
L1F7D9D: db $C0;X
L1F7D9E: db $00;X
L1F7D9F: db $54;X
L1F7DA0: db $00;X
L1F7DA1: db $00;X
L1F7DA2: db $01;X
L1F7DA3: db $00;X
L1F7DA4: db $00;X
L1F7DA5: db $00;X
L1F7DA6: db $40;X
L1F7DA7: db $00;X
L1F7DA8: db $00;X
L1F7DA9: db $80;X
L1F7DAA: db $02;X
L1F7DAB: db $00;X
L1F7DAC: db $00;X
L1F7DAD: db $00;X
L1F7DAE: db $00;X
L1F7DAF: db $00;X
L1F7DB0: db $00;X
L1F7DB1: db $00;X
L1F7DB2: db $00;X
L1F7DB3: db $20;X
L1F7DB4: db $00;X
L1F7DB5: db $00;X
L1F7DB6: db $00;X
L1F7DB7: db $00;X
L1F7DB8: db $00;X
L1F7DB9: db $00;X
L1F7DBA: db $00;X
L1F7DBB: db $10;X
L1F7DBC: db $00;X
L1F7DBD: db $00;X
L1F7DBE: db $00;X
L1F7DBF: db $40;X
L1F7DC0: db $80;X
L1F7DC1: db $00;X
L1F7DC2: db $40;X
L1F7DC3: db $00;X
L1F7DC4: db $00;X
L1F7DC5: db $00;X
L1F7DC6: db $00;X
L1F7DC7: db $00;X
L1F7DC8: db $00;X
L1F7DC9: db $00;X
L1F7DCA: db $00;X
L1F7DCB: db $10;X
L1F7DCC: db $00;X
L1F7DCD: db $00;X
L1F7DCE: db $00;X
L1F7DCF: db $00;X
L1F7DD0: db $04;X
L1F7DD1: db $00;X
L1F7DD2: db $04;X
L1F7DD3: db $00;X
L1F7DD4: db $00;X
L1F7DD5: db $00;X
L1F7DD6: db $20;X
L1F7DD7: db $00;X
L1F7DD8: db $00;X
L1F7DD9: db $00;X
L1F7DDA: db $00;X
L1F7DDB: db $00;X
L1F7DDC: db $00;X
L1F7DDD: db $00;X
L1F7DDE: db $00;X
L1F7DDF: db $00;X
L1F7DE0: db $00;X
L1F7DE1: db $00;X
L1F7DE2: db $20;X
L1F7DE3: db $04;X
L1F7DE4: db $00;X
L1F7DE5: db $00;X
L1F7DE6: db $00;X
L1F7DE7: db $00;X
L1F7DE8: db $00;X
L1F7DE9: db $00;X
L1F7DEA: db $00;X
L1F7DEB: db $00;X
L1F7dec: db $10;X
L1F7DED: db $00;X
L1F7DEE: db $00;X
L1F7DEF: db $00;X
L1F7DF0: db $00;X
L1F7DF1: db $40;X
L1F7DF2: db $00;X
L1F7DF3: db $40;X
L1F7DF4: db $00;X
L1F7DF5: db $00;X
L1F7DF6: db $00;X
L1F7DF7: db $80;X
L1F7DF8: db $00;X
L1F7DF9: db $04;X
L1F7DFA: db $00;X
L1F7DFB: db $00;X
L1F7DFC: db $00;X
L1F7DFD: db $00;X
L1F7DFE: db $80;X
L1F7DFF: db $00;X
L1F7E00: db $FF;X
L1F7E01: db $FF;X
L1F7E02: db $FF;X
L1F7E03: db $FF;X
L1F7E04: db $FF;X
L1F7E05: db $FF;X
L1F7E06: db $FF;X
L1F7E07: db $FF;X
L1F7E08: db $FF;X
L1F7E09: db $FF;X
L1F7E0A: db $FF;X
L1F7E0B: db $FF;X
L1F7E0C: db $FF;X
L1F7E0D: db $FF;X
L1F7E0E: db $FF;X
L1F7E0F: db $FF;X
L1F7E10: db $FF;X
L1F7E11: db $FF;X
L1F7E12: db $FF;X
L1F7E13: db $FF;X
L1F7E14: db $FF;X
L1F7E15: db $FF;X
L1F7E16: db $FF;X
L1F7E17: db $FF;X
L1F7E18: db $FF;X
L1F7E19: db $FE;X
L1F7E1A: db $FF;X
L1F7E1B: db $FF;X
L1F7E1C: db $FF;X
L1F7E1D: db $FF;X
L1F7E1E: db $FF;X
L1F7E1F: db $FE;X
L1F7E20: db $FF;X
L1F7E21: db $FF;X
L1F7E22: db $FF;X
L1F7E23: db $FB;X
L1F7E24: db $FF;X
L1F7E25: db $FF;X
L1F7E26: db $FF;X
L1F7E27: db $FF;X
L1F7E28: db $FF;X
L1F7E29: db $FF;X
L1F7E2A: db $FF;X
L1F7E2B: db $FF;X
L1F7E2C: db $FF;X
L1F7E2D: db $FF;X
L1F7E2E: db $FF;X
L1F7E2F: db $FF;X
L1F7E30: db $FF;X
L1F7E31: db $FF;X
L1F7E32: db $FF;X
L1F7E33: db $FF;X
L1F7E34: db $FF;X
L1F7E35: db $FF;X
L1F7E36: db $FF;X
L1F7E37: db $FF;X
L1F7E38: db $FF;X
L1F7E39: db $FF;X
L1F7E3A: db $FF;X
L1F7E3B: db $FF;X
L1F7E3C: db $FF;X
L1F7E3D: db $FF;X
L1F7E3E: db $FF;X
L1F7E3F: db $FF;X
L1F7E40: db $FF;X
L1F7E41: db $FF;X
L1F7E42: db $FF;X
L1F7E43: db $FF;X
L1F7E44: db $FF;X
L1F7E45: db $FF;X
L1F7E46: db $FF;X
L1F7E47: db $FF;X
L1F7E48: db $FF;X
L1F7E49: db $FF;X
L1F7E4A: db $FF;X
L1F7E4B: db $FF;X
L1F7E4C: db $FF;X
L1F7E4D: db $FF;X
L1F7E4E: db $FF;X
L1F7E4F: db $FF;X
L1F7E50: db $FF;X
L1F7E51: db $FF;X
L1F7E52: db $FF;X
L1F7E53: db $FF;X
L1F7E54: db $FF;X
L1F7E55: db $FF;X
L1F7E56: db $FF;X
L1F7E57: db $FF;X
L1F7E58: db $FF;X
L1F7E59: db $FF;X
L1F7E5A: db $FF;X
L1F7E5B: db $FF;X
L1F7E5C: db $FF;X
L1F7E5D: db $FF;X
L1F7E5E: db $FF;X
L1F7E5F: db $FF;X
L1F7E60: db $FF;X
L1F7E61: db $FF;X
L1F7E62: db $FF;X
L1F7E63: db $FF;X
L1F7E64: db $FF;X
L1F7E65: db $FF;X
L1F7E66: db $FF;X
L1F7E67: db $FF;X
L1F7E68: db $FF;X
L1F7E69: db $EF;X
L1F7E6A: db $FF;X
L1F7E6B: db $FF;X
L1F7E6C: db $FF;X
L1F7E6D: db $FF;X
L1F7E6E: db $FF;X
L1F7E6F: db $FF;X
L1F7E70: db $FF;X
L1F7E71: db $FF;X
L1F7E72: db $FF;X
L1F7E73: db $FF;X
L1F7E74: db $FF;X
L1F7E75: db $FF;X
L1F7E76: db $FF;X
L1F7E77: db $FF;X
L1F7E78: db $FF;X
L1F7E79: db $FF;X
L1F7E7A: db $FF;X
L1F7E7B: db $FF;X
L1F7E7C: db $FF;X
L1F7E7D: db $FF;X
L1F7E7E: db $FF;X
L1F7E7F: db $FF;X
L1F7E80: db $40;X
L1F7E81: db $20;X
L1F7E82: db $00;X
L1F7E83: db $00;X
L1F7E84: db $08;X
L1F7E85: db $04;X
L1F7E86: db $00;X
L1F7E87: db $00;X
L1F7E88: db $8A;X
L1F7E89: db $00;X
L1F7E8A: db $11;X
L1F7E8B: db $10;X
L1F7E8C: db $00;X
L1F7E8D: db $60;X
L1F7E8E: db $80;X
L1F7E8F: db $0C;X
L1F7E90: db $04;X
L1F7E91: db $00;X
L1F7E92: db $00;X
L1F7E93: db $00;X
L1F7E94: db $00;X
L1F7E95: db $00;X
L1F7E96: db $00;X
L1F7E97: db $06;X
L1F7E98: db $00;X
L1F7E99: db $08;X
L1F7E9A: db $00;X
L1F7E9B: db $40;X
L1F7E9C: db $08;X
L1F7E9D: db $40;X
L1F7E9E: db $24;X
L1F7E9F: db $40;X
L1F7EA0: db $00;X
L1F7EA1: db $00;X
L1F7EA2: db $08;X
L1F7EA3: db $40;X
L1F7EA4: db $80;X
L1F7EA5: db $02;X
L1F7EA6: db $00;X
L1F7EA7: db $82;X
L1F7EA8: db $00;X
L1F7EA9: db $00;X
L1F7EAA: db $00;X
L1F7EAB: db $00;X
L1F7EAC: db $00;X
L1F7EAD: db $10;X
L1F7EAE: db $00;X
L1F7EAF: db $00;X
L1F7EB0: db $00;X
L1F7EB1: db $00;X
L1F7EB2: db $02;X
L1F7EB3: db $00;X
L1F7EB4: db $00;X
L1F7EB5: db $40;X
L1F7EB6: db $80;X
L1F7EB7: db $00;X
L1F7EB8: db $00;X
L1F7EB9: db $0C;X
L1F7EBA: db $00;X
L1F7EBB: db $02;X
L1F7EBC: db $81;X
L1F7EBD: db $88;X
L1F7EBE: db $00;X
L1F7EBF: db $00;X
L1F7EC0: db $00;X
L1F7EC1: db $00;X
L1F7EC2: db $00;X
L1F7EC3: db $88;X
L1F7EC4: db $40;X
L1F7EC5: db $00;X
L1F7EC6: db $00;X
L1F7EC7: db $01;X
L1F7EC8: db $09;X
L1F7EC9: db $00;X
L1F7ECA: db $00;X
L1F7ECB: db $00;X
L1F7ECC: db $04;X
L1F7ECD: db $11;X
L1F7ECE: db $00;X
L1F7ECF: db $00;X
L1F7ED0: db $00;X
L1F7ED1: db $01;X
L1F7ED2: db $00;X
L1F7ED3: db $10;X
L1F7ED4: db $00;X
L1F7ED5: db $00;X
L1F7ED6: db $04;X
L1F7ED7: db $00;X
L1F7ED8: db $00;X
L1F7ED9: db $00;X
L1F7EDA: db $00;X
L1F7EDB: db $00;X
L1F7EDC: db $00;X
L1F7EDD: db $00;X
L1F7EDE: db $00;X
L1F7EDF: db $80;X
L1F7EE0: db $00;X
L1F7EE1: db $22;X
L1F7EE2: db $00;X
L1F7EE3: db $80;X
L1F7EE4: db $00;X
L1F7EE5: db $00;X
L1F7EE6: db $00;X
L1F7EE7: db $00;X
L1F7EE8: db $00;X
L1F7EE9: db $04;X
L1F7EEA: db $40;X
L1F7EEB: db $00;X
L1F7EEC: db $04;X
L1F7EED: db $00;X
L1F7EEE: db $40;X
L1F7EEF: db $02;X
L1F7EF0: db $10;X
L1F7EF1: db $00;X
L1F7EF2: db $00;X
L1F7EF3: db $04;X
L1F7EF4: db $00;X
L1F7EF5: db $40;X
L1F7EF6: db $05;X
L1F7EF7: db $00;X
L1F7EF8: db $00;X
L1F7EF9: db $00;X
L1F7EFA: db $40;X
L1F7EFB: db $80;X
L1F7EFC: db $00;X
L1F7EFD: db $00;X
L1F7EFE: db $00;X
L1F7EFF: db $08;X
L1F7F00: db $FF;X
L1F7F01: db $FF;X
L1F7F02: db $FF;X
L1F7F03: db $FF;X
L1F7F04: db $ED;X
L1F7F05: db $FF;X
L1F7F06: db $FF;X
L1F7F07: db $FF;X
L1F7F08: db $FF;X
L1F7F09: db $FF;X
L1F7F0A: db $FF;X
L1F7F0B: db $FF;X
L1F7F0C: db $FF;X
L1F7F0D: db $FF;X
L1F7F0E: db $FF;X
L1F7F0F: db $FF;X
L1F7F10: db $FF;X
L1F7F11: db $FF;X
L1F7F12: db $FF;X
L1F7F13: db $FF;X
L1F7F14: db $FF;X
L1F7F15: db $FF;X
L1F7F16: db $FF;X
L1F7F17: db $FF;X
L1F7F18: db $FF;X
L1F7F19: db $FF;X
L1F7F1A: db $FF;X
L1F7F1B: db $FF;X
L1F7F1C: db $FF;X
L1F7F1D: db $FF;X
L1F7F1E: db $FF;X
L1F7F1F: db $FF;X
L1F7F20: db $EF;X
L1F7F21: db $FF;X
L1F7F22: db $FF;X
L1F7F23: db $FF;X
L1F7F24: db $FF;X
L1F7F25: db $FF;X
L1F7F26: db $FF;X
L1F7F27: db $FD;X
L1F7F28: db $FF;X
L1F7F29: db $FF;X
L1F7F2A: db $FF;X
L1F7F2B: db $FE;X
L1F7F2C: db $FF;X
L1F7F2D: db $FB;X
L1F7F2E: db $FF;X
L1F7F2F: db $FF;X
L1F7F30: db $FF;X
L1F7F31: db $FF;X
L1F7F32: db $BF;X
L1F7F33: db $FF;X
L1F7F34: db $FF;X
L1F7F35: db $FF;X
L1F7F36: db $FF;X
L1F7F37: db $FF;X
L1F7F38: db $FF;X
L1F7F39: db $FF;X
L1F7F3A: db $FF;X
L1F7F3B: db $FF;X
L1F7F3C: db $FF;X
L1F7F3D: db $FF;X
L1F7F3E: db $FF;X
L1F7F3F: db $FF;X
L1F7F40: db $FF;X
L1F7F41: db $FF;X
L1F7F42: db $FF;X
L1F7F43: db $FF;X
L1F7F44: db $FF;X
L1F7F45: db $FF;X
L1F7F46: db $FF;X
L1F7F47: db $FF;X
L1F7F48: db $FF;X
L1F7F49: db $FF;X
L1F7F4A: db $FF;X
L1F7F4B: db $FF;X
L1F7F4C: db $FF;X
L1F7F4D: db $FF;X
L1F7F4E: db $FF;X
L1F7F4F: db $FF;X
L1F7F50: db $FF;X
L1F7F51: db $FF;X
L1F7F52: db $FF;X
L1F7F53: db $FF;X
L1F7F54: db $FF;X
L1F7F55: db $FF;X
L1F7F56: db $FE;X
L1F7F57: db $FB;X
L1F7F58: db $FF;X
L1F7F59: db $FF;X
L1F7F5A: db $DF;X
L1F7F5B: db $FF;X
L1F7F5C: db $FF;X
L1F7F5D: db $FF;X
L1F7F5E: db $FF;X
L1F7F5F: db $FF;X
L1F7F60: db $FF;X
L1F7F61: db $FF;X
L1F7F62: db $FF;X
L1F7F63: db $FF;X
L1F7F64: db $FF;X
L1F7F65: db $FF;X
L1F7F66: db $FF;X
L1F7F67: db $FF;X
L1F7F68: db $EF;X
L1F7F69: db $FF;X
L1F7F6A: db $FF;X
L1F7F6B: db $FF;X
L1F7F6C: db $DF;X
L1F7F6D: db $FF;X
L1F7F6E: db $FF;X
L1F7F6F: db $FF;X
L1F7F70: db $FF;X
L1F7F71: db $FF;X
L1F7F72: db $DF;X
L1F7F73: db $FF;X
L1F7F74: db $FF;X
L1F7F75: db $FF;X
L1F7F76: db $FF;X
L1F7F77: db $FF;X
L1F7F78: db $FF;X
L1F7F79: db $FF;X
L1F7F7A: db $FF;X
L1F7F7B: db $FF;X
L1F7F7C: db $FF;X
L1F7F7D: db $FF;X
L1F7F7E: db $FF;X
L1F7F7F: db $FF;X
L1F7F80: db $00;X
L1F7F81: db $00;X
L1F7F82: db $40;X
L1F7F83: db $20;X
L1F7F84: db $80;X
L1F7F85: db $20;X
L1F7F86: db $40;X
L1F7F87: db $21;X
L1F7F88: db $00;X
L1F7F89: db $40;X
L1F7F8A: db $01;X
L1F7F8B: db $00;X
L1F7F8C: db $00;X
L1F7F8D: db $C5;X
L1F7F8E: db $40;X
L1F7F8F: db $85;X
L1F7F90: db $40;X
L1F7F91: db $00;X
L1F7F92: db $04;X
L1F7F93: db $04;X
L1F7F94: db $80;X
L1F7F95: db $01;X
L1F7F96: db $40;X
L1F7F97: db $01;X
L1F7F98: db $04;X
L1F7F99: db $01;X
L1F7F9A: db $02;X
L1F7F9B: db $20;X
L1F7F9C: db $00;X
L1F7F9D: db $00;X
L1F7F9E: db $00;X
L1F7F9F: db $00;X
L1F7FA0: db $08;X
L1F7FA1: db $00;X
L1F7FA2: db $00;X
L1F7FA3: db $00;X
L1F7FA4: db $00;X
L1F7FA5: db $08;X
L1F7FA6: db $04;X
L1F7FA7: db $00;X
L1F7FA8: db $00;X
L1F7FA9: db $00;X
L1F7FAA: db $28;X
L1F7FAB: db $01;X
L1F7FAC: db $00;X
L1F7FAD: db $00;X
L1F7FAE: db $04;X
L1F7FAF: db $60;X
L1F7FB0: db $00;X
L1F7FB1: db $00;X
L1F7FB2: db $00;X
L1F7FB3: db $10;X
L1F7FB4: db $00;X
L1F7FB5: db $00;X
L1F7FB6: db $00;X
L1F7FB7: db $05;X
L1F7FB8: db $00;X
L1F7FB9: db $00;X
L1F7FBA: db $00;X
L1F7FBB: db $08;X
L1F7FBC: db $00;X
L1F7FBD: db $08;X
L1F7FBE: db $42;X
L1F7FBF: db $C0;X
L1F7FC0: db $00;X
L1F7FC1: db $40;X
L1F7FC2: db $00;X
L1F7FC3: db $00;X
L1F7FC4: db $00;X
L1F7FC5: db $00;X
L1F7FC6: db $08;X
L1F7FC7: db $01;X
L1F7FC8: db $00;X
L1F7FC9: db $00;X
L1F7FCA: db $00;X
L1F7FCB: db $01;X
L1F7FCC: db $00;X
L1F7FCD: db $00;X
L1F7FCE: db $80;X
L1F7FCF: db $00;X
L1F7FD0: db $03;X
L1F7FD1: db $00;X
L1F7FD2: db $00;X
L1F7FD3: db $00;X
L1F7FD4: db $01;X
L1F7FD5: db $04;X
L1F7FD6: db $00;X
L1F7FD7: db $00;X
L1F7FD8: db $00;X
L1F7FD9: db $00;X
L1F7FDA: db $00;X
L1F7FDB: db $10;X
L1F7FDC: db $01;X
L1F7FDD: db $04;X
L1F7FDE: db $28;X
L1F7FDF: db $40;X
L1F7FE0: db $01;X
L1F7FE1: db $00;X
L1F7FE2: db $19;X
L1F7FE3: db $00;X
L1F7FE4: db $41;X
L1F7FE5: db $08;X
L1F7FE6: db $00;X
L1F7FE7: db $00;X
L1F7FE8: db $01;X
L1F7FE9: db $00;X
L1F7FEA: db $04;X
L1F7FEB: db $08;X
L1F7FEC: db $11;X
L1F7FED: db $02;X
L1F7FEE: db $00;X
L1F7FEF: db $00;X
L1F7FF0: db $01;X
L1F7FF1: db $03;X
L1F7FF2: db $08;X
L1F7FF3: db $81;X
L1F7FF4: db $00;X
L1F7FF5: db $01;X
L1F7FF6: db $01;X
L1F7FF7: db $20;X
L1F7FF8: db $80;X
L1F7FF9: db $00;X
L1F7FFA: db $21;X
L1F7FFB: db $01;X
L1F7FFC: db $02;X
L1F7FFD: db $41;X
L1F7FFE: db $20;X
L1F7FFF: db $01;X
