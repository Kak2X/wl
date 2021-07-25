;
; BANK $12 - Intro / Title screen; Actor code
;
OBJLst_Intro_Wario_BoatRow0L: INCBIN "data/objlst/intro/wario_boatrow0_L.bin"
OBJLst_Intro_Wario_BoatRow1L: INCBIN "data/objlst/intro/wario_boatrow1_L.bin"
OBJLst_Intro_Wario_BoatRow2L: INCBIN "data/objlst/intro/wario_boatrow2_L.bin"
OBJLst_Intro_Wario_BoatDash:  INCBIN "data/objlst/intro/wario_boatdash.bin"
OBJLst_Intro_Wario_BoatStand: INCBIN "data/objlst/intro/wario_boatstand.bin"
OBJLst_Intro_Wario_Jump:      INCBIN "data/objlst/intro/wario_jump.bin"
OBJLst_Intro_Wario_Stand:     INCBIN "data/objlst/intro/wario_stand.bin"
OBJLst_Intro_Wario_Front:     INCBIN "data/objlst/intro/wario_front.bin"
OBJLst_Intro_Wario_ThumbsUp:  INCBIN "data/objlst/intro/wario_thumbsup.bin"
OBJLst_Intro_Wario_ThumbsUp2: INCBIN "data/objlst/intro/wario_thumbsup2.bin"
OBJLst_Intro_Wario_BoatRow0R: INCBIN "data/objlst/intro/wario_boatrow0_R.bin"
OBJLst_Intro_Wario_BoatRow1R: INCBIN "data/objlst/intro/wario_boatrow1_R.bin"
OBJLst_Intro_Wario_BoatRow2R: INCBIN "data/objlst/intro/wario_boatrow2_R.bin"
OBJLst_Intro_ShipDuckPanicR:  INCBIN "data/objlst/intro/ship_duckpanic_R.bin"
OBJLst_Intro_ShipFlagR0:      INCBIN "data/objlst/intro/ship_flag0_R.bin"
OBJLst_Intro_ShipDuckRBase:   INCBIN "data/objlst/intro/ship_duckbase_R.bin"
OBJLst_Intro_ShipFlagR1:      INCBIN "data/objlst/intro/ship_flag1_R.bin"
OBJLst_Intro_ShipDuckPanicL:  INCBIN "data/objlst/intro/ship_duckpanic_L.bin"
OBJLst_Intro_ShipDuckBackL:   INCBIN "data/objlst/intro/ship_duckback_L.bin"
OBJLst_Intro_ShipNoDuckR:     INCBIN "data/objlst/intro/ship_ducknone_R.bin"
OBJLst_Intro_ShipDuckR:       INCBIN "data/objlst/intro/ship_duck_R.bin"
OBJLst_Intro_ShipDuckBackR:   INCBIN "data/objlst/intro/ship_duckback_R.bin"
OBJLst_Intro_ShipDuckLook:    INCBIN "data/objlst/intro/ship_ducklook.bin"
OBJLst_Intro_ShipDuckNotice:  INCBIN "data/objlst/intro/ship_ducknotice.bin"
OBJLst_Intro_ShipBodyR:       INCBIN "data/objlst/intro/ship_body_R.bin"
OBJLst_Intro_ShipBodyL:       INCBIN "data/objlst/intro/ship_body_L.bin"
OBJLst_Intro_ShipHit:         INCBIN "data/objlst/intro/ship_hit.bin"
OBJLst_Intro_ShipReverse:     INCBIN "data/objlst/intro/ship_reverse.bin"
OBJLst_Intro_ShipDuckWater:   INCBIN "data/objlst/intro/ship_duckwater.bin"
OBJLst_Intro_ShipWater:       INCBIN "data/objlst/intro/ship_water.bin"
OBJLst_Intro_WaterSplash:     INCBIN "data/objlst/intro/watersplash.bin"

; =============== Intro_WriteOBJ ===============
; Writes all OBJLst for the intro to OAM.
Intro_WriteOBJ:
	; Reset free OBJ count
	xor  a
	ld   [wStaticOBJCount], a
	ld   b, a
	; Write the OBJ data
	call Intro_WriteWarioOBJLst
	call Intro_WriteShipOBJLst
	call Intro_WriteWaterSplashOBJLst
	; Clean free OAM slots
	jp   Static_FinalizeWorkOAM
	
; =============== Intro_WriteWarioOBJLst ===============
; Writes Wario's sprite mappings to OAM.
Intro_WriteWarioOBJLst:
	; Set X / Y parameters
	ld   a, [wIntroWarioX]
	ld   [sOAMWriteX], a
	ld   a, [wIntroWarioY]
	ld   [sOAMWriteY], a
	
	; The subroutine to write OBJLst used in the title screen does not support special flags!
	; So we pick different sprite mappings sets for the different orientations.
	ld   a, [wIntroWarioFlags]	; Is the horizontal flip bit set?
	bit  STATIC_OBJLSTB_XFLIP, a
	jr   nz, .rightPos			; If so, use alternate mappings
	ld   a, [wIntroWarioLstId]
	rst  $28
	dw Title_Ret
	dw Intro_WarioFrame_BoatRow0L
	dw Intro_WarioFrame_BoatRow1L
	dw Intro_WarioFrame_BoatRow2L
	dw Intro_WarioFrame_BoatDash
	dw Intro_WarioFrame_BoatStand
	dw Intro_WarioFrame_Jump
	dw Intro_WarioFrame_Stand
	dw Intro_WarioFrame_Front
	dw Intro_WarioFrame_ThumbsUp
	dw Intro_WarioFrame_ThumbsUp2

.rightPos:
	; Alternate mappings with Wario facing right
	ld   a, [wIntroWarioLstId]
	rst  $28
	dw Title_Ret
	dw Intro_WarioFrame_BoatRow0R
	dw Intro_WarioFrame_BoatRow1R
	dw Intro_WarioFrame_BoatRow2R
	
Intro_WarioFrame_BoatRow0L:
	ld   de, OBJLst_Intro_Wario_BoatRow0L
	jp   Static_WriteOBJLst
Intro_WarioFrame_BoatRow1L:
	ld   de, OBJLst_Intro_Wario_BoatRow1L
	jp   Static_WriteOBJLst
Intro_WarioFrame_BoatRow2L:
	ld   de, OBJLst_Intro_Wario_BoatRow2L
	jp   Static_WriteOBJLst
Intro_WarioFrame_BoatDash:
	ld   de, OBJLst_Intro_Wario_BoatDash
	jp   Static_WriteOBJLst
Intro_WarioFrame_BoatStand:
	ld   de, OBJLst_Intro_Wario_BoatStand
	jp   Static_WriteOBJLst
Intro_WarioFrame_Jump:
	ld   de, OBJLst_Intro_Wario_Jump
	jp   Static_WriteOBJLst
Intro_WarioFrame_Stand:
	ld   de, OBJLst_Intro_Wario_Stand
	jp   Static_WriteOBJLst
Intro_WarioFrame_Front:
	ld   de, OBJLst_Intro_Wario_Front
	jp   Static_WriteOBJLst
Intro_WarioFrame_ThumbsUp:
	ld   de, OBJLst_Intro_Wario_ThumbsUp
	jp   Static_WriteOBJLst
Intro_WarioFrame_ThumbsUp2:
	ld   de, OBJLst_Intro_Wario_ThumbsUp2
	jp   Static_WriteOBJLst
Intro_WarioFrame_BoatRow0R:
	ld   de, OBJLst_Intro_Wario_BoatRow0R
	jp   Static_WriteOBJLst
Intro_WarioFrame_BoatRow1R:
	ld   de, OBJLst_Intro_Wario_BoatRow1R
	jp   Static_WriteOBJLst
Intro_WarioFrame_BoatRow2R:
	ld   de, OBJLst_Intro_Wario_BoatRow2R
	jp   Static_WriteOBJLst
	
; =============== Intro_WriteShipOBJLst ===============
; Writes the ship's sprite mappings to OAM.
Intro_WriteShipOBJLst:
	ld   a, [wIntroShipX]
	ld   [sOAMWriteX], a
	ld   a, [wIntroShipY]
	ld   [sOAMWriteY], a
	; Pick the offet for the OBJLst
	ld   a, [wIntroShipLstId]
	rst  $28
	dw Title_Ret
	dw Intro_ShipFrame_Idle0
	dw Intro_ShipFrame_Idle1
	dw Intro_ShipFrame_DuckR
	dw Intro_ShipFrame_DuckBackR0
	dw Intro_ShipFrame_DuckLook
	dw Intro_ShipFrame_DuckNotice
	dw Intro_ShipFrame_DuckPanicR
	dw Intro_ShipFrame_DuckBackR1
	dw Intro_ShipFrame_DuckPanicL
	dw Intro_ShipFrame_DuckBackL
	dw Intro_ShipFrame_DuckHit
	dw Intro_ShipFrame_DuckReverse
	dw Intro_ShipFrame_Water
	dw Intro_ShipFrame_DuckWater

Intro_ShipFrame_Idle0:
	ld   de, OBJLst_Intro_ShipFlagR0
	call Static_WriteOBJLst
	ld   de, OBJLst_Intro_ShipNoDuckR
	jp   Intro_ShipFrame_BodyR
Intro_ShipFrame_Idle1:
	ld   de, OBJLst_Intro_ShipFlagR1
	call Static_WriteOBJLst
	ld   de, OBJLst_Intro_ShipNoDuckR
	jp   Intro_ShipFrame_BodyR
Intro_ShipFrame_DuckR:
	ld   de, OBJLst_Intro_ShipDuckRBase ; Left side of the duck, shared across frames
	call Static_WriteOBJLst
	ld   de, OBJLst_Intro_ShipDuckR
	jp   Intro_ShipFrame_BodyR
Intro_ShipFrame_DuckBackR0:
	ld   de, OBJLst_Intro_ShipFlagR1
	call Static_WriteOBJLst
	ld   de, OBJLst_Intro_ShipDuckBackR
	jp   Intro_ShipFrame_BodyR
Intro_ShipFrame_DuckLook:
	ld   de, OBJLst_Intro_ShipDuckRBase
	call Static_WriteOBJLst
	ld   de, OBJLst_Intro_ShipDuckLook
	jp   Intro_ShipFrame_BodyR
Intro_ShipFrame_DuckNotice:
	ld   de, OBJLst_Intro_ShipDuckRBase
	call Static_WriteOBJLst
	ld   de, OBJLst_Intro_ShipDuckNotice
	jp   Intro_ShipFrame_BodyR
Intro_ShipFrame_DuckPanicR:
	ld   de, OBJLst_Intro_ShipDuckPanicR
	jp   Intro_ShipFrame_BodyR
Intro_ShipFrame_DuckBackR1:
	ld   de, OBJLst_Intro_ShipFlagR0
	call Static_WriteOBJLst
	ld   de, OBJLst_Intro_ShipDuckBackR
	jp   Intro_ShipFrame_BodyR
Intro_ShipFrame_DuckPanicL:
	ld   de, OBJLst_Intro_ShipDuckPanicL
	jp   Intro_ShipFrame_BodyL
Intro_ShipFrame_DuckBackL:
	ld   de, OBJLst_Intro_ShipDuckBackL
	jp   Intro_ShipFrame_BodyL
Intro_ShipFrame_DuckHit:
	ld   de, OBJLst_Intro_ShipHit
	jp   Static_WriteOBJLst
Intro_ShipFrame_DuckReverse:
	ld   de, OBJLst_Intro_ShipReverse
	jp   Static_WriteOBJLst
Intro_ShipFrame_Water:
	ld   de, OBJLst_Intro_ShipWater
	jp   Static_WriteOBJLst
Intro_ShipFrame_DuckWater:
	ld   de, OBJLst_Intro_ShipDuckWater
	jp   Static_WriteOBJLst
; Common ship body, shared across frames
Intro_ShipFrame_BodyR:
	call Static_WriteOBJLst
	ld   de, OBJLst_Intro_ShipBodyR
	jp   Static_WriteOBJLst
Intro_ShipFrame_BodyL:
	call Static_WriteOBJLst
	ld   de, OBJLst_Intro_ShipBodyL
	jp   Static_WriteOBJLst
	
; =============== Intro_WriteWaterSplashOBJLst ===============
; Writes the water sprout's sprite mappings to OAM.
Intro_WriteWaterSplashOBJLst:
	ld   a, [wIntroShipX]
	ld   [sOAMWriteX], a
	ld   a, [wIntroWaterSplashY]
	ld   [sOAMWriteY], a
	ld   a, [wIntroWaterSplash]	; Is the water splash enabled?
	cp   a, $00
	ret  z						; If not, don't draw it
	ld   de, OBJLst_Intro_WaterSplash
	jp   Static_WriteOBJLst
	
; =============== Title_CheckMode ===============
; Main handler for title screen / intro cutscene.
Title_CheckMode:
	ld   a, $A0
	ld   [sWorkOAMPos], a
	; Which part of the intro screen?
	ld   a, [wTitleMode]
	rst  $28
	dw Title_Mode_Init
	dw Title_Mode_Main
	dw Title_Mode_Intro
	
; =============== Title_Mode_Init ===============
; Initializes the title screen.
Title_Mode_Init:
	call StopLCDOperation
	call ClearBGMapEx
	call ClearWorkOAM
	ld   hl, GFXRLE_Title
	call DecompressGFXStub
	ld   hl, BGRLE_Title
	ld   bc, BGMap_Begin + $0020
	call DecompressBG
	ld   hl, BGRLE_TitleClouds
	ld   bc, BGMap_Begin + $0220
	call DecompressBG
	ld   hl, BGRLE_TitleWater
	ld   bc, WINDOWMap_Begin
	call DecompressBG
	call Title_InitVars
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE|LCDC_WENABLE|LCDC_WTILEMAP|LCDC_ENABLE
	ldh  [rLCDC], a
Title_Ret:
	ret
; =============== Title_InitVars ===============
; Initializes all variables used for the title screen.
Title_InitVars:
	xor  a
	ld   [wIntroAct], a
	ld   [wIntroWaterOscillationTimer], a
	ld   [wIntroWarioAnimTimer], a
	ld   [wIntroActTimer], a
	ld   [wTitleActTimer], a
	ld   [wIntroWarioLstId], a
	ld   [wIntroShipLstId], a
	ld   [wIntroWaterSplash], a
	ld   [wIntroWarioFlags], a
	ld   a, $B8
	ld   [wIntroWarioX], a
	ld   a, $D0
	ld   [wIntroShipX], a
	
	ld   a, $03
	ldh  [rSCY], a
	ld   a, $07
	ldh  [rWX], a
	ld   a, $80
	ldh  [rWY], a
	
	ld   a, $E4
	ldh  [rBGP], a
	ldh  [rOBP1], a
	ldh  [rOBP0], a
	; Switch to next mode
	ld   a, TITLE_MODE_MAIN
	ld   [wTitleMode], a
	ret
; =============== Title_Mode_Main ===============
; This is when the Title Screen is first shown, before the intro cutscene starts.
Title_Mode_Main:
	; [TCRF] This sTitleRetVal value is not used to start the intro
	ld   a, [sTitleRetVal]
	cp   a, TITLE_NEXT_INTRO
	jr   z, Title_SwitchToIntro
	;--
	; Update the timer
	ld   a, [wTitleActTimer]
	inc  a
	ld   [wTitleActTimer], a
	
	; Handle the fade out to the intro cutscene.
	; This is based off a timer and uses hardcoded BGP / OBP vals.
	cp   a, $8C
	jp   z, Title_FadeOut0
	cp   a, $96
	jp   z, Title_FadeOut1
	cp   a, $A0
	jp   z, Title_FadeOut2
	cp   a, $AA				
	jr   z, Title_FadeOut3
	cp   a, $BE
	jr   z, Title_SwitchToIntro
	ret
; =============== Title_FadeOut3 ===============
; This... does nothing!
; Title_FadeOut2, which is executed before, already clears out rBGP.
Title_FadeOut3:
	xor  a
	ldh  [rBGP], a
	ret
	
; =============== Title_SwitchToIntro ===============
Title_SwitchToIntro:
	ld   a, $20
	ld   [sBGMSet], a
	xor  a
	ld   [wIntroActTimer1], a
	ld   a, $64
	ldh  [rSCY], a
	ld   a, $E4
	ldh  [rBGP], a
	ldh  [rOBP1], a
	ldh  [rOBP0], a
	ld   a, TITLE_MODE_INTRO
	ld   [wTitleMode], a
	ret
	
; =============== Title_Mode_Intro ===============
; Parent handler for the intro cutscene.
Title_Mode_Intro:
	call Intro_Do
	call Intro_OscillateWarioY
	call Intro_OscillateShipY
	jp   Intro_WriteOBJ
	
Intro_Do:
	ldh  a, [hJoyNewKeys]				; Have we pressed A or START?
	and  a, KEY_A|KEY_START
	jr   z, Intro_CheckCutsceneAct		; If not, handle the main intro
	; Otherwise, set transition to save select screen.
	ld   a, TITLE_NEXT_SAVE
	ld   [sTitleRetVal], a
	ret
	
; =============== Intro_CheckCutsceneAct ===============
; Performs the animation scripts for the intro cutscenes.
; Between frames, wIntroActTimer is expected to be reset to $00.
Intro_CheckCutsceneAct:
	ld   a, [wIntroAct]
	rst  $28
	dw Intro_CutsceneAct00
	dw Intro_CutsceneAct01
	dw Intro_CutsceneAct02
	dw Intro_CutsceneAct03
	dw Intro_CutsceneAct04
	dw Intro_CutsceneAct05
	dw Intro_CutsceneAct06
	dw Intro_CutsceneAct07
	dw Intro_CutsceneAct08
	dw Intro_CutsceneAct09
	dw Intro_CutsceneAct0A
	dw Intro_CutsceneAct0B
	dw Intro_CutsceneAct0C
	dw Intro_CutsceneAct0D
	dw Intro_CutsceneAct0E
	dw Intro_CutsceneAct0F
	dw Intro_CutsceneAct10
	dw Intro_CutsceneAct11
	dw Intro_CutsceneAct12
	dw Intro_CutsceneAct13
	
; =============== Intro_CutsceneAct00 ===============
; Moves the Ship to the right until it reaches X pos $30.
Intro_CutsceneAct00:
	ld   a, [wIntroActTimer]	; Ship anim timer
	inc  a
	ld   [wIntroActTimer], a
	
	;--
	; Switch between the sprite mappings for the ship every $12 frames
	; This is used to animate the ship's flag.
	cp   a, $12
	jr   z, .frame2
	cp   a, $24
	jr   z, .frame1				; and reset
	jr   .moveShip				; Otherwise, don't update the frame
.frame2:
	ld   a, INTRO_SOF_MAIN1
	ld   [wIntroShipLstId], a
	jr   .moveShip
.frame1:
	xor  a
	ld   [wIntroActTimer], a
	ld   a, INTRO_SOF_MAIN0
	ld   [wIntroShipLstId], a
	
.moveShip:
	;--
	; Every $04 frames, move the ship to the right
	ld   a, [wIntroActTimer1]	; Movement timer++
	inc  a
	ld   [wIntroActTimer1], a
	cp   a, $04					; Movement timer reached $04?
	ret  nz						; If not, return
	
	xor  a
	ld   [wIntroActTimer1], a	; Reset timer
	ld   a, [wIntroShipX]		; Move ship to the left
	inc  a
	;--
	
	ld   [wIntroShipX], a		; Has the ship reached X pos $30?
	cp   a, $30
	ret  nz						; If not, return
	xor  a						; Otherwise, switch to the next mode
	ld   [wIntroActTimer], a
	ld   a, $01
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct01 ===============
; Duck appears and turns around; when turning plays a SFX.
Intro_CutsceneAct01:
	ld   a, [wIntroActTimer]
	inc  a
	ld   [wIntroActTimer], a
	
	; Action chain which depends on anim timer
	cp   a, $1E
	jr   z, .playSFX
	cp   a, $4B
	jr   z, .turnDuckBack
	cp   a, $78
	jr   z, .turnDuckFront
	cp   a, $A5
	jr   z, .turnDuckBack
	cp   a, $D2
	jr   z, .turnDuckFront
	cp   a, $F5
	jr   z, .nextAct
	ret
.playSFX:
	ld   a, SFX1_17
	ld   [sSFX1Set], a
.showDuck:
	ld   a, INTRO_SOF_DUCKR1
	ld   [wIntroShipLstId], a
	ret
.turnDuckBack:
	ld   a, SFX1_19
	ld   [sSFX1Set], a
	ld   a, INTRO_SOF_DUCKRBACK1
	ld   [wIntroShipLstId], a
	ret
.turnDuckFront:
	ld   a, SFX1_18
	ld   [sSFX1Set], a
	jr   .showDuck
.nextAct:
	xor  a
	ld   [wIntroActTimer], a
	ld   a, INTRO_SOF_DUCKLOOK ; Set the look anim
	ld   [wIntroShipLstId], a
	ld   a, $02
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct02 ===============
; The duck notices Wario.
Intro_CutsceneAct02:
	; Update the timer 
	ld   a, [wIntroActTimer]
	inc  a
	ld   [wIntroActTimer], a
	
	; Don't do anything (keep INTRO_SOF_DUCKLOOK) until it reaches $50
	cp   a, $50
	ret  c
	;--
	jr   z, .setDuckNotice
	;--
	cp   a, $60					; For the jump effect
	jr   c, .moveShipUp
	cp   a, $70
	jr   c, .moveShipDown
	jr   z, .endJump			; Reset Y back to normal and show splash
	;--
	cp   a, $76					; Delay
	ret  c
	;--
	cp   a, $87
	jr   c, .moveWaterSplashDown
	cp   a, $8A
	jr   z, .nextAct			; Hide splash; start siren SFX
	ret
.setDuckNotice:
	ld   a, SFX1_1A
	ld   [sSFX1Set], a
	ld   a, INTRO_SOF_DUCKNOTICE
	ld   [wIntroShipLstId], a
	ret
;--
.moveShipUp:
	ld   a, [wIntroShipY]
	dec  a
	ld   [wIntroShipY], a
	ret
.moveShipDown:
	ld   a, [wIntroShipY]
	inc  a
	ld   [wIntroShipY], a
	ret
.endJump:
	; Show water splash
	ld   a, SFX4_0C
	ld   [sSFX4Set], a
	ld   a, $01
	ld   [wIntroWaterSplash], a
	ld   a, $6E
	ld   [wIntroWaterSplashY], a
	ret
;-
.moveWaterSplashDown:
	ld   a, [wIntroWaterSplashY]
	inc  a
	ld   [wIntroWaterSplashY], a
	ret
.nextAct:
	ld   a, SFX1_1B
	ld   [sSFX1Set], a
	xor  a
	ld   [wIntroActTimer], a
	ld   [wIntroWaterSplash], a
	ld   a, INTRO_SOF_DUCKPANICL
	ld   [wIntroShipLstId], a
	ld   a, $03
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct03 ===============
; Ship moves to the left.
Intro_CutsceneAct03:
	; Move the ship left until it goes off screen
	ld   a, [wIntroShipX]
	dec  a
	ld   [wIntroShipX], a
	cp   a, $D0				; Fully off-screen
	ret  nz
	
	ld   a, INTRO_WOF_BOATROW0		; Show Wario
	ld   [wIntroWarioLstId], a
	ld   a, $80					; Facing left
	ld   [wIntroWarioFlags], a
	ld   a, $04
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct04 ===============
; Move Wario to the left.
Intro_CutsceneAct04:
	call Intro_AnimWarioRow
	ld   b, $C8
	call Intro_MoveWarioLeft
	ld   a, [wIntroWarioX]	; Wait until Wario goes fully off-screen to the left
	cp   a, $C8
	ret  nz
	
	xor  a
	ld   [wIntroWarioAnimTimer], a
	ld   [wIntroWarioLstId], a		; Hide Wario to not show the movement done by Intro_MoveWarioRight
	ld   [wIntroWarioFlags], a		; since we start 8 px to the right of Act5's target pos
	ld   a, INTRO_SOF_DUCKPANICR
	ld   [wIntroShipLstId], a
	ld   a, $05
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct05 ===============
; The ship moves to the right, then stops around the center of the screen.
; Wario appears from the left and both go to the right.
Intro_CutsceneAct05:
	call Intro_AnimWarioRow
	ld   b, $C0
	call Intro_MoveWarioRight
	
	; Determine progression based off thw ship's X pos
	ld   a, [wIntroShipX]
	cp   a, $F8
	jr   z, .playSiren	
	cp   a, $40
	jr   z, .lookBack	; Stop the ship
	cp   a, $C0
	jr   z, .chkNextAct
	
	; By default, move the ship right
.moveShipRight:
	ld   a, [wIntroShipX]
	inc  a
	ld   [wIntroShipX], a
	ret
.playSiren:
	ld   a, SFX1_1B
	ld   [sSFX1Set], a
	jr   .moveShipRight
.lookBack:
	; Stop the ship with the look back frame for $3C frames
	ld   a, INTRO_SOF_DUCKRBACK2
	ld   [wIntroShipLstId], a
	ld   a, [wIntroActTimer]
	inc  a
	ld   [wIntroActTimer], a
	cp   a, $3C
	ret  nz
	;--
	; After that, play the siren again and show Wario
	ld   a, SFX1_1B
	ld   [sSFX1Set], a
	xor  a
	ld   [wIntroActTimer], a
	ld   a, INTRO_WOF_BOATROW0		; Show Wario
	ld   [wIntroWarioLstId], a	
	ld   a, $C8					; Set back the correct pos (since we've moved while hidden)
	ld   [wIntroWarioX], a
	ld   a, INTRO_SOF_DUCKPANICR
	ld   [wIntroShipLstId], a
	jr   .moveShipRight			; Move the ship to proceed
.chkNextAct:
	; Wait for Wario to go off-screen right
	ld   a, [wIntroWarioX]
	cp   a, $C0
	ret  nz
	; Set next act
	xor  a
	ld   [wIntroWarioAnimTimer], a
	ld   [wIntroWarioLstId], a
	ld   a, INTRO_SOF_DUCKPANICL
	ld   [wIntroShipLstId], a
	ld   a, $06
	ld   [wIntroAct], a
	ret

; =============== Intro_CutsceneAct06 ===============
; Ship moves to the right, then and looks back.
Intro_CutsceneAct06:
	; Determine action based off Ship X
	ld   a, [wIntroShipX]
	cp   a, $98
	jr   z, Intro_CutsceneAct06_PlaySiren
	cp   a, $5A				; Target pos
	jr   z, Intro_CutsceneAct06_ChkNextAct
	
; =============== Intro_MoveShipLeft ===============
Intro_MoveShipLeft:
	ld   a, [wIntroShipX]
	dec  a
	ld   [wIntroShipX], a
	ret
	
; =============== Intro_CutsceneAct06 ===============	
Intro_CutsceneAct06_PlaySiren:
	ld   a, SFX1_1B
	ld   [sSFX1Set], a
	jr   Intro_MoveShipLeft
Intro_CutsceneAct06_ChkNextAct:
	; Stop ship movement
	; Wait $32 frames with the look back frame
	ld   a, INTRO_SOF_DUCKLBACK
	ld   [wIntroShipLstId], a
	ld   a, [wIntroActTimer]
	inc  a
	ld   [wIntroActTimer], a
	cp   a, $32
	ret  nz
	; Show Wario for next act
	ld   a, SFX1_1D
	ld   [sSFX1Set], a
	xor  a
	ld   [wIntroActTimer], a
	ld   a, INTRO_WOF_BOATROW0
	ld   [wIntroWarioLstId], a
	ld   a, $07
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct07 ===============	
; Wario moves to the right and hits the ship.
Intro_CutsceneAct07:
	; Move the ship 1px/2frames to the left
	ld   a, [wIntroActTimer]
	inc  a
	ld   [wIntroActTimer], a
	bit  0, a
	call z, Intro_MoveShipLeft
	; Move Wario 2px/frame to the right (loop back from right border to left)
	ld   a, [wIntroWarioX]
	inc  a
	inc  a
	ld   [wIntroWarioX], a
	;--
	cp   a, $2E			; When Wario hits the ship
	jr   z, .nextAct
	; Do standard rowing anim until X pos $10
	cp   a, $10
	jr   nc, .useDash			; Then always use dash frame
	jp   Intro_AnimWarioRow	
.useDash:
	ld   a, INTRO_WOF_BOATDASH
	ld   [wIntroWarioLstId], a
	ret
.nextAct:
	ld   a, SFX1_1E
	ld   [sSFX1Set], a
	xor  a
	ld   [wIntroWarioAnimTimer], a
	ld   [wIntroActTimer], a
	ld   a, INTRO_SOF_DUCKHIT
	ld   [wIntroShipLstId], a
	ld   a, $08
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct08 ===============	
; Move ship 3px to the right and 1px upwards
; until it reaches X pos $8A (the right border)
Intro_CutsceneAct08:
	ld   a, [wIntroShipX]
	
	; Move right 3 times
	ld   b, $03				; B = Amount of times to move right
.moveShipRight:
	cp   a, $8A				; Reached the target X pos?
	jr   z, .nextAct		; If so, jump
	inc  a					; Move ship right
	ld   [wIntroShipX], a
	dec  b					; TimesLeft--
	jr   nz, .moveShipRight
	; And upwards once
	ld   a, [wIntroShipY]	
	dec  a
	ld   [wIntroShipY], a
	ret
.nextAct:
	ld   a, INTRO_SOF_DUCKREVERSE
	ld   [wIntroShipLstId], a
	ld   a, $09
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct09 ===============	
; Move ship 3px upwards and 1px to the left
; until it goes off screen
Intro_CutsceneAct09:
	ld   a, [wIntroShipY]
	
	ld   b, $03				; B = Amount of times to move up
.moveShipUp:
	cp   a, $A0				; Reached the target Y pos?
	jr   z, .nextAct			; If so, jump
	dec  a
	ld   [wIntroShipY], a
	dec  b					; TimesLeft--
	jr   nz, .moveShipUp
	; And to the left once
	ld   a, [wIntroShipX]
	dec  a
	ld   [wIntroShipX], a
	ret
.nextAct:
	ld   a, $0A
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct0A ===============
; Moves the ship downwards 4px/frame until it reaches the waterline.
Intro_CutsceneAct0A:
	ld   a, [wIntroShipY]
	; Move ship down
	ld   b, $04
.moveShipDown:
	cp   a, $90				; Reached the target Y pos?
	jr   z, .nextAct
	inc  a
	ld   [wIntroShipY], a
	dec  b
	jr   nz, .moveShipDown
	ret
.nextAct:
	ld   a, SFX4_13
	ld   [sSFX4Set], a
	
	ld   a, INTRO_SOF_WATER			; Use reverse cut off frame
	ld   [wIntroShipLstId], a
	ld   a, $01						; Enable water splash
	ld   [wIntroWaterSplash], a
	ld   a, $68
	ld   [wIntroWaterSplashY], a
	ld   a, $0B
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct0B ===============
; Moves the ship upward by 8px.
Intro_CutsceneAct0B:
	ld   a, [wIntroActTimer]
	inc  a
	ld   [wIntroActTimer], a
	
	cp   a, $08					; Do nothing for the first $08 frames
	ret  c
	cp   a, $0A
	jr   z, .moveShipUp
	cp   a, $19
	jr   z, .nextAct
	ld   a, [wIntroWaterSplashY]
	inc  a
	ld   [wIntroWaterSplashY], a
	ret
.moveShipUp:
	; Move the ship up $08px, as it's in water
	ld   a, $88
	ld   [wIntroShipY], a
	ret
.nextAct:
	xor  a
	ld   [wIntroActTimer], a
	ld   [wIntroWaterSplash], a
	ld   a, $0C
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct0C ===============
; Delays the intro for $14 frames, then starts a SFX.
Intro_CutsceneAct0C:
	ld   a, [wIntroActTimer1]
	inc  a
	ld   [wIntroActTimer1], a
	cp   a, $14
	jr   z, .nextAct
	ret
.nextAct:
	ld   a, SFX4_12
	ld   [sSFX4Set], a
	xor  a
	ld   [wIntroActTimer1], a
	ld   a, $0D
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct0D ===============
; Scrolls the BGMap down for the title drop effect.
Intro_CutsceneAct0D:
	ldh  a, [rSCY]
	cp   a, $04			; Have we reached ScrollY <= $04?
	jr   c, .nextAct	; If so, jump
	sub  a, $04			; Otherwise, decrement it by 4px
	ldh  [rSCY], a
	ret
.nextAct:
	ld   a, $0E
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct0E ===============
; Performs the vertical screen shake effect for the title.
Intro_CutsceneAct0E:
	; Use wIntroActTimer1 as table index for the ScrollY table
	
	ld   a, [wIntroActTimer1]		; Did we go past the last table entry?
	cp   a, (Intro_TitleYShakeTbl_End - Intro_TitleYShakeTbl)
	jr   z, .nextAct				; If so, jump
	;--
	; Index the scroll table
	ld   c, a
	inc  a							; i++ for next time
	ld   [wIntroActTimer1], a	
	ld   hl, Intro_TitleYShakeTbl	; HL = Table to index
	ld   b, $00						; BC = wIntroActTimer1
	add  hl, bc						; Index the table
	ld   a, [hl]
	ldh  [rSCY], a					; Set the scroll value from the table
	ret
.nextAct:
	xor  a
	ld   [wIntroActTimer1], a
	ld   a, INTRO_WOF_BOATSTAND
	ld   [wIntroWarioLstId], a
	ld   a, $0F
	ld   [wIntroAct], a
	ret
	
; =============== Intro_TitleYShakeTbl ===============
; Determines the rSCY value for the title shake effect.
Intro_TitleYShakeTbl:
	db $03,$03,$03,$03,$03,$08,$08,$08,$08,$FE,$FE,$FE,$FE,$08,$08,$08
	db $08,$FE,$FE,$FE,$FE,$07,$07,$07,$07,$FF,$FF,$FF,$FF,$05,$05,$05
	db $01,$01,$01,$03
Intro_TitleYShakeTbl_End:

; =============== Intro_CutsceneAct0F ===============
; Delays the intro, then starts the BGM.
Intro_CutsceneAct0F:
	ld   a, [wIntroActTimer1]
	inc  a
	ld   [wIntroActTimer1], a
	;--
	cp   a, $8C
	jr   z, .playBGM
	cp   a, $C8
	jr   z, .nextAct
	ret
.playBGM:
	ld   a, BGM_TITLE
	ld   [sBGMSet], a
	ld   a, INTRO_SOF_DUCKWATER
	ld   [wIntroShipLstId], a
	ret
.nextAct:
	xor  a
	ld   [wIntroActTimer1], a
	ld   a, INTRO_WOF_JUMP
	ld   [wIntroWarioLstId], a
	ld   a, $10
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct10 ===============
; Makes Wario jump on the ship.
Intro_CutsceneAct10:
	
	; wIntroWarioAnimTimer reused as table index
	ld   a, [wIntroWarioAnimTimer]	; Gone past the end of the table?
	cp   a, (Intro_WarioJumpYTbl_End - Intro_WarioJumpYTbl)
	jr   z, .nextAct				; If so, switch to next act
	;--
	
	; The jump is handled through:
	; - A table of Y coords for Wario's Y pos
	; - Incrementing Wario'x X pos by 1 every frame
	
	ld   c, a						; BC = wIntroWarioAnimTimer
	inc  a
	ld   [wIntroWarioAnimTimer], a
	ld   hl, Intro_WarioJumpYTbl	; HL = Table of Y coords
	ld   b, $00
	add  hl, bc						; Index the table
	ld   a, [hl]
	ld   [wIntroWarioY], a
	ld   a, [wIntroWarioX]
	inc  a
	ld   [wIntroWarioX], a
	ret
.nextAct:
	ld   a, SFX1_01				; Not using the normal land SFX for some reason
	ld   [sSFX1Set], a
	xor  a
	ld   [wIntroWarioAnimTimer], a
	ld   a, INTRO_WOF_STAND
	ld   [wIntroWarioLstId], a
	ld   a, $03							; Deterines how many times to do a full cycle of the thumbs up anim
	ld   [wIntroWarioAnimCycleLeft], a	
	ld   a, $11
	ld   [wIntroAct], a
	ret
; =============== Intro_WarioJumpYTbl ===============
; Determines Y coords for Wario's jump.
; The equivalent X pos starts at $2E and always increases by 1 for each next entry.
Intro_WarioJumpYTbl:
	db $76,$74,$72,$70,$6E,$6C,$6A,$68,$66,$64,$62,$60,$5F,$5E,$5D,$5C
	db $5B,$5B,$5A,$5A,$5A,$5B,$5B,$5C,$5C,$5D,$5E,$5F,$60,$61,$63,$65
	db $67,$69
Intro_WarioJumpYTbl_End:

; =============== Intro_CutsceneAct11 ===============
; Performs the thumbs up animation the amount of times specified by wIntroWarioAnimCycleLeft.
Intro_CutsceneAct11:
	; Cycle frame between $00-$E1
	ld   a, [wIntroWarioAnimTimer]
	inc  a
	ld   [wIntroWarioAnimTimer], a
	
	; Main Wario thumbs up anim timing loop
	cp   a, $5A
	jr   z, .frontFrame
	cp   a, $82
	jr   z, .thumbsUpFrame
	cp   a, $A0
	jr   z, .thumbsUpFrame2
	
	cp   a, $E1
	ret  nz
.resetTimer:
	xor  a
	ld   [wIntroWarioAnimTimer], a
.frontFrame:
	ld   a, INTRO_WOF_FRONT
	ld   [wIntroWarioLstId], a
	ret
.thumbsUpFrame:
	ld   a, INTRO_WOF_THUMBSUP
	ld   [wIntroWarioLstId], a
	ret
.thumbsUpFrame2:
	ld   a, INTRO_WOF_THUMBSUP2
	ld   [wIntroWarioLstId], a
	ld   a, [wIntroWarioAnimCycleLeft]	; CyclesLeft--;
	dec  a								
	ld   [wIntroWarioAnimCycleLeft], a	; Are there any anim cycles left? 
	ret  nz								; If so, return
.nextAct:
	xor  a								
	ld   [wIntroWarioAnimTimer], a
	ld   a, $12
	ld   [wIntroAct], a
	ret
; =============== Intro_CutsceneAct12 ===============
; Delays for $B9 frames before starting the fade out to demo mode.
Intro_CutsceneAct12:
	ld   a, [wIntroWarioAnimTimer]
	cp   a, $B9
	jr   z, .nextAct
	inc  a
	ld   [wIntroWarioAnimTimer], a
	ret
.nextAct:
	ld   a, $13
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct13 ===============
; Fades out to demo mode.
Intro_CutsceneAct13:
	ld   a, [wIntroActTimer1]
	inc  a
	ld   [wIntroActTimer1], a
	
	cp   a, $0A
	jr   z, Title_FadeOut0
	cp   a, $1C
	jr   z, Title_FadeOut1
	cp   a, $2E
	jr   z, Title_FadeOut2
	cp   a, $40
	jr   z, Title_SwitchToDemo
	ret
	
; =============== Title_FadeOut? ===============
; Common fade-out phases for the title screen.
Title_FadeOut0:
	ld   a, BGMACT_FADEOUT
	ld   [sBGMActSet], a
	ld   a, $90
	jr   Title_FadeOut_SetPal
Title_FadeOut1:
	ld   a, $40
	jr   Title_FadeOut_SetPal
Title_FadeOut2:
	xor  a
Title_FadeOut_SetPal:
	ldh  [rBGP], a
	ldh  [rOBP0], a
	ret
; =============== Title_SwitchToDemo ===============
; Sets the switch to Demo mode from the title screen.
Title_SwitchToDemo:
	ld   a, TITLE_NEXT_DEMO
	ld   [sTitleRetVal], a
	xor  a
	ld   [wTitleMode], a
	ret
	
; =============== Intro_AnimWarioRow ===============
; Performs Wario's rowing anim in the intro.
Intro_AnimWarioRow:
	; Ignore if Wario isn't visible
	ld   a, [wIntroWarioLstId]
	cp   a, INTRO_WOF_NONE
	ret  z
	
	; Switch frames depending on the anim timer
	ld   a, [wIntroWarioAnimTimer]
	inc  a
	ld   [wIntroWarioAnimTimer], a
	cp   a, $04
	jr   z, .frame3
	cp   a, $0A
	jr   z, .frame2
	cp   a, $14
	jr   z, .frame1
	ret
.frame3:
	ld   a, INTRO_WOF_BOATROW2
	ld   [wIntroWarioLstId], a
	ret
.frame2:
	ld   a, SFX1_1C
	ld   [sSFX1Set], a
	ld   a, INTRO_WOF_BOATROW1
	ld   [wIntroWarioLstId], a
	ret
.frame1:
	xor  a
	ld   [wIntroWarioAnimTimer], a
	ld   a, INTRO_WOF_BOATROW0
	ld   [wIntroWarioLstId], a
	ret
	
; =============== Intro_MoveWarioRight ===============
; Moves Wario 1.5px to the right until the target value is reached.
; IN
; - B: Target X pos
Intro_MoveWarioRight:
	; Determine how many times to move Wario
	; alternate between 1 and 2 times every other frame
	ld   a, [wIntroWarioAnimTimer]
	bit  0, a
	jr   nz, .tim2
.tim1:
	ld   c, $01
	jr   .moveWario
.tim2:
	ld   c, $02
	
.moveWario:
	; Move Wario to the left the specified amount of times
	ld   a, [wIntroWarioX]	; Reached the target pos?
	cp   a, b
	ret  z					; If so, return
	inc  a					; Move right
	ld   [wIntroWarioX], a
	dec  c					; Completed movement?
	jr   nz, .moveWario		; If not, loop
	ret
	
; =============== Intro_MoveWarioLeft ===============
; Moves Wario 1.5px to the left until the target value is reached.
; IN
; - B: Target X pos
Intro_MoveWarioLeft:
	; Determine how many times to move Wario
	; alternate between 1 and 2 times every other frame
	ld   a, [wIntroWarioAnimTimer]
	bit  0, a
	jr   nz, .tim2
.tim1:
	ld   c, $01			; C = Amount fo times
	jr   .moveWario
.tim2:
	ld   c, $02
	
.moveWario:
	; Move Wario to the left the specified amount of times
	ld   a, [wIntroWarioX]	; Have we reached the target pos?
	cp   a, b
	ret  z					; If so, return
	dec  a					; Move left
	ld   [wIntroWarioX], a
	dec  c					; Moved completely?
	jr   nz, .moveWario		; If not, loop
	ret
; =============== Title_AnimWaterGFX ===============
; Update the waterline graphics during the title screen.
; Every $14 frames, a different set of water graphics is copied to the location in VRAM.
;
Title_AnimWaterGFX:
	ld   a, [wTitleTileAnimTimer]
	inc  a
	ld   [wTitleTileAnimTimer], a
	cp   a, $14		; Reached the $14 frame?
	jr   z, .frame0	; If so, use the other graphics
	cp   a, $28		; Reached the $28 frame?
	jr   z, .frame1	; If so, switch the graphics and reset the timer
	ret
	
; The source graphics are already in VRAM.
; So the source data just points to the decompressed GFX.
.frame0:
	ld   hl, vGFXTitleWaterAnimGFX0
	jr   .vramCopy
.frame1:
	xor  a
	ld   [wTitleTileAnimTimer], a
	ld   hl, vGFXTitleWaterAnimGFX1
.vramCopy:
	ld   de, vGFXTitleWaterAnim	; DE = Destination
	ld   b, $20					; Copy 2 tiles
.loop:
	ldi  a, [hl]				; Copy over the tile
	ld   [de], a
	inc  de						
	dec  b						; Copied all the tiles?
	jr   nz, .loop				; If not, loop
	ret
	
; =============== Intro_OscillateWarioY ===============
; Oscillates Wario's Y coord for the waterline effect when not jumping.
Intro_OscillateWarioY:
	; Don't perform the effect for the jumping frame
	ld   a, [wIntroWarioLstId]
	cp   a, INTRO_WOF_JUMP
	ret  z
	;--
	; Every $14 frames alternate between 2 Y positions
	ld   a, [wIntroWaterOscillationTimer]
	cp   a, $00
	jr   z, .lowPos
	cp   a, $14
	ret  nz
.highPos:
	; The Y positions change depending on the current Wario frame.
	; - If Frame < INTRO_WOF_STAND, Wario's on his boat.
	; - Otherwise, he's on the top of the ship.
	; The boat oscillates less than the ship, which is why there's a difference.
	ld   a, [wIntroWarioLstId]
	cp   a, $07					; Is it >= INTRO_WOF_STAND?
	jr   nc, .highPosShip		; If so, jump
.highPosBoat:
	ld   a, $78
	ld   [wIntroWarioY], a
	ret
.highPosShip:
	ld   a, $6A
	ld   [wIntroWarioY], a
	ret
	
.lowPos:
	; Same here
	ld   a, [wIntroWarioLstId]
	cp   a, $07
	jr   nc, .lowPosShip
.lowPosBoat:
	ld   a, $77
	ld   [wIntroWarioY], a
	ret
.lowPosShip:
	ld   a, $68
	ld   [wIntroWarioY], a
	ret
	
; =============== Intro_OscillateShipY ===============
; Oscillates the ship's Y coord for the waterline effect when not in the air.
; See also: Intro_OscillateWarioY
Intro_OscillateShipY:
	ld   a, [wIntroShipLstId]
	; If the ship is not on water, don't do the effect
	cp   a, INTRO_SOF_DUCKNOTICE
	ret  z
	cp   a, INTRO_SOF_DUCKHIT
	ret  z
	cp   a, INTRO_SOF_DUCKREVERSE
	ret  z
	;--
	; Every $14 frames alternate between 2 Y positions
	ld   a, [wIntroWaterOscillationTimer]
	cp   a, $00
	jr   z, .lowPos
	cp   a, $14
	jr   z, .highPos
	ret
.highPos:
	; The Y positions are different depending on the frame used
	ld   a, [wIntroShipLstId]
	cp   a, INTRO_SOF_WATER		; Is the ship upside down?
	jr   nc, .highPosShipR		; If so, use the alternate Y pos
.highPosShip:
	ld   a, $76					
	ld   [wIntroShipY], a
	ret
.highPosShipR:
	ld   a, $86					; The oscillation amount should be the same as when Wario steps on the ship
	ld   [wIntroShipY], a
	ret
.lowPos:
	ld   a, [wIntroShipLstId]
	cp   a, INTRO_SOF_WATER
	jr   nc, .lowPosShipR
.lowPosShip:
	ld   a, $74
	ld   [wIntroShipY], a
	ret
.lowPosShipR:
	ld   a, $84
	ld   [wIntroShipY], a
	ret
	
; =============== Static_WriteWarioOBJLst ===============
; Writes Wario's sprite mappings to OAM for the static screens.
Static_WriteWarioOBJLst:
	ld   a, [wStaticPlX]	; Set X pos
	ld   [sOAMWriteX], a
	ld   a, [wStaticPlY]	; Set Y pos
	ld   [sOAMWriteY], a
	
	; The subroutine to write OBJLst used does not support special flags!
	; So we pick different sprite mappings sets for the different orientations.
	;
	; Note that the frames used for facing left are much less than those for facing right.
	ld   a, [wStaticPlFlags]
	bit  STATIC_OBJLSTB_XFLIP, a	; Facing left?
	jr   z, .framesR				; If not, jump
.framesL:
	ld   a, [wStaticPlLstId]
	rst  $28
	dw Static_WarioFrame_None;X
	dw Static_WarioFrame_WalkL0
	dw Static_WarioFrame_WalkL1
	dw Static_WarioFrame_WalkL2
	dw Static_WarioFrame_WalkL3
	dw Static_WarioFrame_Unused_IdleL;X ; [TCRF] Standing frame facing left doesn't have a chance to be used here.
	dw Static_WarioFrame_Front
	dw Static_WarioFrame_FrontWon0
	dw Static_WarioFrame_FrontWon1
	dw Static_WarioFrame_FrontLost
	dw Static_WarioFrame_IdleDiagL
	dw Ending_WarioFrame_JumpDiagL ; For ending
.framesR:
	ld   a, [wStaticPlLstId]
	rst  $28
	dw Static_WarioFrame_None
	dw Static_WarioFrame_WalkR0
	dw Static_WarioFrame_WalkR1
	dw Static_WarioFrame_WalkR2
	dw Static_WarioFrame_WalkR3
	dw Static_WarioFrame_IdleR
	dw Static_WarioFrame_Front
	dw Static_WarioFrame_FrontWon0
	dw Static_WarioFrame_FrontWon1
	dw Static_WarioFrame_FrontLost
	dw Static_WarioFrame_IdleDiagR
	dw Ending_WarioFrame_JumpDiagR
	; Heart bonus only
	dw HeartBonus_WarioFrame_Back
	dw HeartBonus_WarioFrame_BackGrabBomb  
	dw HeartBonus_WarioFrame_BackHoldBomb0
	dw HeartBonus_WarioFrame_BackHoldBomb1
	dw HeartBonus_WarioFrame_BackThrowBomb ; $10
	dw HeartBonus_WarioFrame_BackGrabBombExpl0
	dw HeartBonus_WarioFrame_BackGrabBombExpl1
	dw HeartBonus_WarioFrame_BackGrabBombExpl2
	dw HeartBonus_WarioFrame_BackHoldBombExpl0
	dw HeartBonus_WarioFrame_BackHoldBombExpl1
	dw HeartBonus_WarioFrame_BackHoldBombExpl2
	dw HeartBonus_WarioFrame_BackBombExpl3
	dw HeartBonus_WarioFrame_BackBombExpl4
	; Coin bonus only
	dw CoinBonus_WarioFrame_IdleDiagHeadBack
	dw CoinBonus_WarioFrame_Pull0
	dw CoinBonus_WarioFrame_Pull1
	dw CoinBonus_WarioFrame_Crushed
	; Ending only
	dw Ending_WarioFrame_WalkHoldR0
	dw Ending_WarioFrame_WalkHoldR1
	dw Ending_WarioFrame_WalkHoldR2
	dw Ending_WarioFrame_WalkHoldR3 ; $20
	dw Ending_WarioFrame_IdleHoldR
	dw Ending_WarioFrame_IdleThrowR
	dw Ending_WarioFrame_DuckRub0
	dw Ending_WarioFrame_DuckRub1
	dw Ending_WarioFrame_DuckRub2
	dw Ending_WarioFrame_DuckDiagR
	dw Ending_WarioFrame_BumpR0 ; with hat above
	dw Ending_WarioFrame_BumpR1 ; norm
	dw Ending_WarioFrame_WishClose
	dw Ending_WarioFrame_WishOpen

; =======================================================	
; =============== WARIO FRAME DEFINITIONS ===============
; ==========================================(static ver)=
;
; Several of these sprite mappings are reused for multiple frames.
; This is done by starting at the middle of a sprite mapping, which
; requires the shared OBJ to come after the unique OBJ.
;
; For example, OBJLst_Static_Wario_WalkR3 is the full frame, part of Wario's walking animation.
; OBJLst_Static_Wario_WalkR3_Body is a label that points right in the middle of OBJLst_Static_Wario_WalkR3,
; to exclude a few OBJ from the right side of the sprite (near the hand on the right).
; This OBJLst_Static_Wario_WalkR3_Body is reused for Ending_WarioFrame_WalkHoldR3
; to draw the main body, while OBJLst_Ending_Wario_WalkHoldR1_Hand hand draws the unique OBJ.
;
; Because of data files being split, it means the shared part of OBJLst_Static_Wario_WalkR3 is split in a different file,
; though it's easy to detect a partial frame (it lacks an end separator required by Static_WriteOBJLst)
;

Static_WarioFrame_None:
	ret
Static_WarioFrame_WalkL0:
	ld   de, OBJLst_Static_Wario_WalkL0
	jp   Static_WriteOBJLst
Static_WarioFrame_WalkL1:
	ld   de, OBJLst_Static_Wario_WalkL1
	jp   Static_WriteOBJLst
Static_WarioFrame_WalkL2:
	ld   de, OBJLst_Static_Wario_WalkL2
	jp   Static_WriteOBJLst
Static_WarioFrame_WalkL3:
	ld   de, OBJLst_Static_Wario_WalkL3
	jp   Static_WriteOBJLst
; [TCRF] Does not get used.
Static_WarioFrame_Unused_IdleL: 
	ld   de, OBJLst_Static_Wario_Unused_IdleL
	jp   Static_WriteOBJLst
Static_WarioFrame_Front:
	ld   de, OBJLst_Static_Wario_Front
	jp   Static_WriteOBJLst
Static_WarioFrame_FrontWon0:
	ld   de, OBJLst_Static_Wario_FrontWon0
	jp   Static_WriteOBJLst
Static_WarioFrame_FrontWon1:
	ld   de, OBJLst_Static_Wario_FrontWon1_Eyes
	call Static_WriteOBJLst
	ld   de, OBJLst_Static_Wario_FrontWon0_Body
	jp   Static_WriteOBJLst
Static_WarioFrame_FrontLost:
	ld   de, OBJLst_Static_Wario_FrontLost
	jp   Static_WriteOBJLst
Static_WarioFrame_IdleDiagL:
	ld   de, OBJLst_Static_Wario_IdleDiagL
	jp   Static_WriteOBJLst
Ending_WarioFrame_JumpDiagL:
	ld   de, OBJLst_Ending_Wario_JumpDiagL
	jp   Static_WriteOBJLst
Static_WarioFrame_WalkR0:
	ld   de, OBJLst_Static_Wario_WalkR0
	jp   Static_WriteOBJLst
Static_WarioFrame_WalkR1:
	ld   de, OBJLst_Static_Wario_WalkR1
	jp   Static_WriteOBJLst
Static_WarioFrame_WalkR2:
	ld   de, OBJLst_Static_Wario_WalkR2
	jp   Static_WriteOBJLst
Static_WarioFrame_WalkR3:
	ld   de, OBJLst_Static_Wario_WalkR3
	jp   Static_WriteOBJLst
Static_WarioFrame_IdleR:
	ld   de, OBJLst_Static_Wario_IdleR
	jp   Static_WriteOBJLst
Static_WarioFrame_IdleDiagR:
	ld   de, OBJLst_Static_Wario_IdleDiagR
	jp   Static_WriteOBJLst
Ending_WarioFrame_JumpDiagR:
	ld   de, OBJLst_Ending_Wario_JumpDiagR
	jp   Static_WriteOBJLst
HeartBonus_WarioFrame_Back:
	ld   de, OBJLst_HeartBonus_Wario_Back
	jp   Static_WriteOBJLst
HeartBonus_WarioFrame_BackGrabBomb:
	ld   de, OBJLst_HeartBonus_Wario_BackGrabBomb
	jp   Static_WriteOBJLst
HeartBonus_WarioFrame_BackHoldBomb0:
	ld   de, OBJLst_HeartBonus_Wario_BackHoldBomb0
	jp   Static_WriteOBJLst
HeartBonus_WarioFrame_BackHoldBomb1:
	ld   de, OBJLst_HeartBonus_Wario_BackHoldBomb1
	jp   Static_WriteOBJLst
HeartBonus_WarioFrame_BackThrowBomb:
	ld   de, OBJLst_HeartBonus_Wario_BackThrowBomb
	jp   Static_WriteOBJLst
HeartBonus_WarioFrame_BackGrabBombExpl0:
	ld   de, OBJLst_HeartBonus_Wario_BackGrabBombExpl0
	jp   Static_WriteOBJLst
HeartBonus_WarioFrame_BackGrabBombExpl1:
	ld   de, OBJLst_HeartBonus_Wario_BackGrabBombExpl1
	jp   Static_WriteOBJLst
HeartBonus_WarioFrame_BackGrabBombExpl2:
	ld   de, OBJLst_HeartBonus_Wario_BackBombExpl2_Smoke
	call Static_WriteOBJLst
	ld   de, OBJLst_HeartBonus_Wario_BackGrabBombExpl2_Body
	jp   Static_WriteOBJLst
HeartBonus_WarioFrame_BackHoldBombExpl0:
	ld   de, OBJLst_HeartBonus_Wario_BackHoldBombExpl0
	jp   Static_WriteOBJLst
HeartBonus_WarioFrame_BackHoldBombExpl1:
	ld   de, OBJLst_HeartBonus_Wario_BackHoldBombExpl1
	jp   Static_WriteOBJLst
HeartBonus_WarioFrame_BackHoldBombExpl2:
	ld   de, OBJLst_HeartBonus_Wario_BackBombExpl2_Smoke
	call Static_WriteOBJLst
	ld   de, OBJLst_HeartBonus_Wario_BackHoldBombExpl2_Body
	jp   Static_WriteOBJLst
HeartBonus_WarioFrame_BackBombExpl3:
	ld   de, OBJLst_HeartBonus_Wario_BackBombExpl3
	call Static_WriteOBJLst
	ld   de, OBJLst_HeartBonus_Wario_BackBombExpl2_Smoke
	jp   Static_WriteOBJLst
HeartBonus_WarioFrame_BackBombExpl4:
	ld   de, OBJLst_HeartBonus_Wario_BackBombExpl4
	jp   Static_WriteOBJLst
CoinBonus_WarioFrame_IdleDiagHeadBack:
	ld   de, OBJLst_CoinBonus_Wario_IdleDiagHeadBack
	jp   Static_WriteOBJLst
CoinBonus_WarioFrame_Pull0:
	ld   de, OBJLst_CoinBonus_Wario_Pull0_Hand
	call Static_WriteOBJLst
	ld   de, OBJLst_CoinBonus_Wario_Pull0_Body
	jp   Static_WriteOBJLst
CoinBonus_WarioFrame_Pull1:
	ld   de, OBJLst_CoinBonus_Wario_Pull1
	jp   Static_WriteOBJLst
CoinBonus_WarioFrame_Crushed:
	ld   de, OBJLst_CoinBonus_Wario_Crushed
	jp   Static_WriteOBJLst
Ending_WarioFrame_WalkHoldR0:
	ld   de, OBJLst_Ending_Wario_WalkHoldR0_Hand
	call Static_WriteOBJLst
	ld   de, OBJLst_Static_Wario_WalkR0_Body
	jp   Static_WriteOBJLst
Ending_WarioFrame_WalkHoldR1:
	ld   de, OBJLst_Ending_Wario_WalkHoldR1_Hand
	call Static_WriteOBJLst
	ld   de, OBJLst_Ending_Wario_WalkR1_Body
	jp   Static_WriteOBJLst
Ending_WarioFrame_WalkHoldR2:
	ld   de, OBJLst_Ending_Wario_WalkHoldR1_Hand
	call Static_WriteOBJLst
	ld   de, OBJLst_Ending_Wario_WalkR2_Body
	jp   Static_WriteOBJLst
Ending_WarioFrame_WalkHoldR3:
	ld   de, OBJLst_Ending_Wario_WalkHoldR1_Hand
	call Static_WriteOBJLst
	ld   de, OBJLst_Ending_Wario_WalkR3_Body
	jp   Static_WriteOBJLst
Ending_WarioFrame_IdleHoldR:
	ld   de, OBJLst_Ending_Wario_IdleHoldR_Hand
	call Static_WriteOBJLst
	ld   de, OBJLst_Ending_Wario_IdleHoldR_Body
	jp   Static_WriteOBJLst
Ending_WarioFrame_IdleThrowR:
	ld   de, OBJLst_Ending_Wario_IdleThrowR_Hand
	call Static_WriteOBJLst
	ld   de, OBJLst_Ending_Wario_IdleHoldR_Body
	jp   Static_WriteOBJLst
Ending_WarioFrame_DuckRub0:
	ld   de, OBJLst_Ending_Wario_DuckRub0
	jp   Static_WriteOBJLst
Ending_WarioFrame_DuckRub1:
	ld   de, OBJLst_Ending_Wario_DuckRub1_Hand
	call Static_WriteOBJLst
	ld   de, OBJLst_Ending_Wario_DuckRub1_Body
	jp   Static_WriteOBJLst
Ending_WarioFrame_DuckRub2:
	ld   de, OBJLst_Ending_Wario_DuckRub2
	jp   Static_WriteOBJLst
Ending_WarioFrame_DuckDiagR:
	ld   de, OBJLst_Ending_Wario_DuckDiagR
	jp   Static_WriteOBJLst
Ending_WarioFrame_BumpR0:
	ld   de, OBJLst_Ending_Wario_HardBumpR0
	jp   Static_WriteOBJLst
Ending_WarioFrame_BumpR1:
	ld   de, OBJLst_Ending_Wario_HardBumpR1_Hat
	call Static_WriteOBJLst
	ld   de, OBJLst_Ending_Wario_HardBumpR1_Body
	jp   Static_WriteOBJLst
Ending_WarioFrame_WishClose:
	ld   de, OBJLst_Ending_Wario_WishClose
	jp   Static_WriteOBJLst
Ending_WarioFrame_WishOpen:
	ld   de, OBJLst_Ending_Wario_WishOpen_Eyes
	call Static_WriteOBJLst
	ld   de, OBJLst_Ending_Wario_WishOpen_Body
	jp   Static_WriteOBJLst
OBJLst_Static_Wario_WalkL0: INCBIN "data/objlst/static/wario_walkl0.bin"
OBJLst_Static_Wario_WalkL1: INCBIN "data/objlst/static/wario_walkl1.bin"
OBJLst_Static_Wario_WalkL2: INCBIN "data/objlst/static/wario_walkl2.bin"
OBJLst_Static_Wario_WalkL3: INCBIN "data/objlst/static/wario_walkl3.bin"
OBJLst_Static_Wario_Unused_IdleL: INCBIN "data/objlst/static/wario_unused_idlel.bin"
OBJLst_Static_Wario_Front: INCBIN "data/objlst/static/wario_front.bin"
OBJLst_Static_Wario_FrontWon0: INCBIN "data/objlst/static/wario_frontwon0.bin"
OBJLst_Static_Wario_FrontWon0_Body: INCBIN "data/objlst/static/wario_frontwon0_body.bin"
OBJLst_Static_Wario_FrontWon1_Eyes: INCBIN "data/objlst/static/wario_frontwon1_eyes.bin"
OBJLst_Static_Wario_FrontLost: INCBIN "data/objlst/static/wario_frontlost.bin"
OBJLst_Static_Wario_IdleDiagL: INCBIN "data/objlst/static/wario_idlediagl.bin"
OBJLst_Ending_Wario_JumpDiagL: INCBIN "data/objlst/ending/wario_jumpdiagl.bin"
OBJLst_Static_Wario_WalkR0: INCBIN "data/objlst/static/wario_walkr0.bin"
OBJLst_Static_Wario_WalkR0_Body: INCBIN "data/objlst/static/wario_walkr0_body.bin"
OBJLst_Static_Wario_WalkR1: INCBIN "data/objlst/static/wario_walkr1.bin"
OBJLst_Ending_Wario_WalkR1_Body: INCBIN "data/objlst/ending/wario_walkr1_body.bin"
OBJLst_Static_Wario_WalkR2: INCBIN "data/objlst/static/wario_walkr2.bin"
OBJLst_Ending_Wario_WalkR2_Body: INCBIN "data/objlst/ending/wario_walkr2_body.bin"
OBJLst_Static_Wario_WalkR3: INCBIN "data/objlst/static/wario_walkr3.bin"
OBJLst_Ending_Wario_WalkR3_Body: INCBIN "data/objlst/ending/wario_walkr3_body.bin"
OBJLst_Static_Wario_IdleR: INCBIN "data/objlst/static/wario_idler.bin"
OBJLst_Ending_Wario_IdleHoldR_Body: INCBIN "data/objlst/ending/wario_idleholdr_body.bin"
OBJLst_Static_Wario_IdleDiagR: INCBIN "data/objlst/static/wario_idlediagr.bin"
OBJLst_CoinBonus_Wario_Pull0_Body: INCBIN "data/objlst/coinbonus/wario_pull0_body.bin"
OBJLst_Ending_Wario_JumpDiagR: INCBIN "data/objlst/ending/wario_jumpdiagr.bin"
OBJLst_HeartBonus_Wario_Back: INCBIN "data/objlst/heartbonus/wario_back.bin"
OBJLst_HeartBonus_Wario_BackGrabBomb: INCBIN "data/objlst/heartbonus/wario_backgrabbomb.bin"
OBJLst_HeartBonus_Wario_BackGrabBombExpl0: INCBIN "data/objlst/heartbonus/wario_backgrabbombexpl0.bin"
OBJLst_HeartBonus_Wario_BackGrabBombExpl1: INCBIN "data/objlst/heartbonus/wario_backgrabbombexpl1.bin"
OBJLst_HeartBonus_Wario_BackGrabBombExpl2_Body: INCBIN "data/objlst/heartbonus/wario_backgrabbombexpl2_body.bin"
OBJLst_HeartBonus_Wario_BackHoldBomb0: INCBIN "data/objlst/heartbonus/wario_backholdbomb0.bin"
OBJLst_HeartBonus_Wario_BackHoldBombExpl0: INCBIN "data/objlst/heartbonus/wario_backholdbombexpl0.bin"
OBJLst_HeartBonus_Wario_BackHoldBombExpl1: INCBIN "data/objlst/heartbonus/wario_backholdbombexpl1.bin"
OBJLst_HeartBonus_Wario_BackHoldBombExpl2_Body: INCBIN "data/objlst/heartbonus/wario_backholdbombexpl2_body.bin"
OBJLst_HeartBonus_Wario_BackHoldBomb1: INCBIN "data/objlst/heartbonus/wario_backholdbomb1.bin"
OBJLst_HeartBonus_Wario_BackThrowBomb: INCBIN "data/objlst/heartbonus/wario_backthrowbomb.bin"
OBJLst_HeartBonus_Wario_BackBombExpl2_Smoke: INCBIN "data/objlst/heartbonus/wario_backbombexpl2_smoke.bin"
OBJLst_HeartBonus_Wario_BackBombExpl4: INCBIN "data/objlst/heartbonus/wario_backbombexpl4.bin"
OBJLst_HeartBonus_Wario_BackBombExpl3: INCBIN "data/objlst/heartbonus/wario_backbombexpl3.bin"
OBJLst_CoinBonus_Wario_IdleDiagHeadBack: INCBIN "data/objlst/coinbonus/wario_idlediagheadback.bin"
OBJLst_CoinBonus_Wario_Pull0_Hand: INCBIN "data/objlst/coinbonus/wario_pull0_hand.bin"
OBJLst_CoinBonus_Wario_Pull1: INCBIN "data/objlst/coinbonus/wario_pull1.bin"
OBJLst_CoinBonus_Wario_Crushed: INCBIN "data/objlst/coinbonus/wario_crushed.bin"
OBJLst_Ending_Wario_WalkHoldR0_Hand: INCBIN "data/objlst/ending/wario_walkholdr0_hand.bin"
OBJLst_Ending_Wario_IdleHoldR_Hand: INCBIN "data/objlst/ending/wario_idleholdr_hand.bin"
OBJLst_Ending_Wario_WalkHoldR1_Hand: INCBIN "data/objlst/ending/wario_walkholdr1_hand.bin"
OBJLst_Ending_Wario_IdleThrowR_Hand: INCBIN "data/objlst/ending/wario_idlethrowr_hand.bin"
OBJLst_Ending_Wario_DuckRub0: INCBIN "data/objlst/ending/wario_duckrub0.bin"
OBJLst_Ending_Wario_DuckRub1_Body: INCBIN "data/objlst/ending/wario_duckrub1_body.bin"
OBJLst_Ending_Wario_DuckRub2: INCBIN "data/objlst/ending/wario_duckrub2.bin"
OBJLst_Ending_Wario_DuckRub1_Hand: INCBIN "data/objlst/ending/wario_duckrub1_hand.bin"
OBJLst_Ending_Wario_DuckDiagR: INCBIN "data/objlst/ending/wario_duckdiagr.bin"
OBJLst_Ending_Wario_HardBumpR0: INCBIN "data/objlst/ending/wario_hardbumpr0.bin"
OBJLst_Ending_Wario_HardBumpR1_Body: INCBIN "data/objlst/ending/wario_hardbumpr1_body.bin"
OBJLst_Ending_Wario_HardBumpR1_Hat: INCBIN "data/objlst/ending/wario_hardbumpr1_hat.bin"
OBJLst_Ending_Wario_WishClose: INCBIN "data/objlst/ending/wario_wishclose.bin"
OBJLst_Ending_Wario_WishOpen_Body: INCBIN "data/objlst/ending/wario_wishopen_body.bin"
OBJLst_Ending_Wario_WishOpen_Eyes: INCBIN "data/objlst/ending/wario_wishopen_eyes.bin"
;-----------
GFXRLE_Title: INCBIN "data/gfx/title.rlc"
;-----------
	db $02;X
	db $00;X
	db $00;X
	db $00;X
	db $00;X
	db $00;X
	db $00;X
	db $00;X
;-----------
BGRLE_Title: INCBIN "data/bg/title.rls"
BGRLE_TitleClouds: INCBIN "data/bg/title_clouds.rls"
BGRLE_TitleWater: INCBIN "data/bg/title_water.rls"

; =============== START OF ALIGN JUNK ===============
L126856: db $40;X
L126857: db $00;X
L126858: db $00;X
L126859: db $00;X
L12685A: db $00;X
L12685B: db $00;X
L12685C: db $00;X
L12685D: db $00;X
L12685E: db $00;X
L12685F: db $00;X
L126860: db $00;X
L126861: db $00;X
L126862: db $10;X
L126863: db $00;X
L126864: db $10;X
L126865: db $00;X
L126866: db $00;X
L126867: db $00;X
L126868: db $00;X
L126869: db $00;X
L12686A: db $00;X
L12686B: db $00;X
L12686C: db $00;X
L12686D: db $00;X
L12686E: db $00;X
L12686F: db $00;X
L126870: db $00;X
L126871: db $00;X
L126872: db $00;X
L126873: db $00;X
L126874: db $40;X
L126875: db $00;X
L126876: db $00;X
L126877: db $00;X
L126878: db $00;X
L126879: db $00;X
L12687A: db $20;X
L12687B: db $00;X
L12687C: db $00;X
L12687D: db $00;X
L12687E: db $00;X
L12687F: db $00;X
L126880: db $F9;X
L126881: db $FF;X
L126882: db $DF;X
L126883: db $BD;X
L126884: db $FF;X
L126885: db $FF;X
L126886: db $F7;X
L126887: db $FF;X
L126888: db $FF;X
L126889: db $FF;X
L12688A: db $7F;X
L12688B: db $FD;X
L12688C: db $FB;X
L12688D: db $DE;X
L12688E: db $FF;X
L12688F: db $FF;X
L126890: db $FF;X
L126891: db $7F;X
L126892: db $FF;X
L126893: db $FF;X
L126894: db $FF;X
L126895: db $E7;X
L126896: db $FB;X
L126897: db $FE;X
L126898: db $FF;X
L126899: db $FD;X
L12689A: db $EF;X
L12689B: db $FE;X
L12689C: db $FF;X
L12689D: db $F3;X
L12689E: db $BE;X
L12689F: db $FA;X
L1268A0: db $EB;X
L1268A1: db $FF;X
L1268A2: db $FB;X
L1268A3: db $BE;X
L1268A4: db $F7;X
L1268A5: db $F3;X
L1268A6: db $DB;X
L1268A7: db $FF;X
L1268A8: db $FF;X
L1268A9: db $FE;X
L1268AA: db $FF;X
L1268AB: db $FF;X
L1268AC: db $EF;X
L1268AD: db $9F;X
L1268AE: db $FB;X
L1268AF: db $FE;X
L1268B0: db $7D;X
L1268B1: db $FF;X
L1268B2: db $A7;X
L1268B3: db $FF;X
L1268B4: db $FF;X
L1268B5: db $FF;X
L1268B6: db $BF;X
L1268B7: db $BE;X
L1268B8: db $BF;X
L1268B9: db $FF;X
L1268BA: db $7E;X
L1268BB: db $FE;X
L1268BC: db $7F;X
L1268BD: db $FB;X
L1268BE: db $EF;X
L1268BF: db $FF;X
L1268C0: db $7F;X
L1268C1: db $3F;X
L1268C2: db $FF;X
L1268C3: db $7F;X
L1268C4: db $FF;X
L1268C5: db $FF;X
L1268C6: db $7F;X
L1268C7: db $EF;X
L1268C8: db $EE;X
L1268C9: db $FF;X
L1268CA: db $FF;X
L1268CB: db $DF;X
L1268CC: db $F3;X
L1268CD: db $FD;X
L1268CE: db $FF;X
L1268CF: db $7E;X
L1268D0: db $FF;X
L1268D1: db $FF;X
L1268D2: db $EF;X
L1268D3: db $FF;X
L1268D4: db $FF;X
L1268D5: db $FD;X
L1268D6: db $F6;X
L1268D7: db $6F;X
L1268D8: db $BB;X
L1268D9: db $EF;X
L1268DA: db $FB;X
L1268DB: db $FE;X
L1268DC: db $FF;X
L1268DD: db $FE;X
L1268DE: db $77;X
L1268DF: db $FB;X
L1268E0: db $CF;X
L1268E1: db $FF;X
L1268E2: db $EF;X
L1268E3: db $BF;X
L1268E4: db $E7;X
L1268E5: db $7F;X
L1268E6: db $FF;X
L1268E7: db $FD;X
L1268E8: db $F7;X
L1268E9: db $FF;X
L1268EA: db $ED;X
L1268EB: db $FF;X
L1268EC: db $FD;X
L1268ED: db $FB;X
L1268EE: db $ED;X
L1268EF: db $7F;X
L1268F0: db $FF;X
L1268F1: db $DF;X
L1268F2: db $FF;X
L1268F3: db $FE;X
L1268F4: db $FE;X
L1268F5: db $FA;X
L1268F6: db $72;X
L1268F7: db $D6;X
L1268F8: db $DE;X
L1268F9: db $7F;X
L1268FA: db $FB;X
L1268FB: db $FF;X
L1268FC: db $DF;X
L1268FD: db $FF;X
L1268FE: db $FF;X
L1268FF: db $7F;X
L126900: db $00;X
L126901: db $00;X
L126902: db $00;X
L126903: db $00;X
L126904: db $00;X
L126905: db $00;X
L126906: db $40;X
L126907: db $00;X
L126908: db $00;X
L126909: db $00;X
L12690A: db $00;X
L12690B: db $03;X
L12690C: db $00;X
L12690D: db $00;X
L12690E: db $00;X
L12690F: db $00;X
L126910: db $00;X
L126911: db $00;X
L126912: db $80;X
L126913: db $00;X
L126914: db $00;X
L126915: db $00;X
L126916: db $00;X
L126917: db $00;X
L126918: db $00;X
L126919: db $00;X
L12691A: db $00;X
L12691B: db $00;X
L12691C: db $40;X
L12691D: db $20;X
L12691E: db $00;X
L12691F: db $00;X
L126920: db $00;X
L126921: db $00;X
L126922: db $00;X
L126923: db $00;X
L126924: db $81;X
L126925: db $00;X
L126926: db $84;X
L126927: db $00;X
L126928: db $00;X
L126929: db $00;X
L12692A: db $00;X
L12692B: db $01;X
L12692C: db $00;X
L12692D: db $30;X
L12692E: db $00;X
L12692F: db $00;X
L126930: db $02;X
L126931: db $20;X
L126932: db $00;X
L126933: db $10;X
L126934: db $00;X
L126935: db $00;X
L126936: db $00;X
L126937: db $00;X
L126938: db $00;X
L126939: db $00;X
L12693A: db $00;X
L12693B: db $00;X
L12693C: db $00;X
L12693D: db $00;X
L12693E: db $08;X
L12693F: db $00;X
L126940: db $00;X
L126941: db $00;X
L126942: db $00;X
L126943: db $00;X
L126944: db $00;X
L126945: db $00;X
L126946: db $00;X
L126947: db $00;X
L126948: db $00;X
L126949: db $00;X
L12694A: db $00;X
L12694B: db $00;X
L12694C: db $00;X
L12694D: db $00;X
L12694E: db $00;X
L12694F: db $10;X
L126950: db $00;X
L126951: db $00;X
L126952: db $00;X
L126953: db $00;X
L126954: db $00;X
L126955: db $00;X
L126956: db $00;X
L126957: db $00;X
L126958: db $00;X
L126959: db $00;X
L12695A: db $00;X
L12695B: db $00;X
L12695C: db $00;X
L12695D: db $00;X
L12695E: db $00;X
L12695F: db $00;X
L126960: db $00;X
L126961: db $00;X
L126962: db $06;X
L126963: db $00;X
L126964: db $00;X
L126965: db $00;X
L126966: db $00;X
L126967: db $00;X
L126968: db $00;X
L126969: db $08;X
L12696A: db $00;X
L12696B: db $00;X
L12696C: db $00;X
L12696D: db $00;X
L12696E: db $00;X
L12696F: db $00;X
L126970: db $00;X
L126971: db $00;X
L126972: db $00;X
L126973: db $80;X
L126974: db $02;X
L126975: db $00;X
L126976: db $00;X
L126977: db $00;X
L126978: db $00;X
L126979: db $00;X
L12697A: db $00;X
L12697B: db $00;X
L12697C: db $00;X
L12697D: db $00;X
L12697E: db $01;X
L12697F: db $04;X
L126980: db $FF;X
L126981: db $BF;X
L126982: db $FF;X
L126983: db $EE;X
L126984: db $FF;X
L126985: db $FD;X
L126986: db $7F;X
L126987: db $DA;X
L126988: db $EF;X
L126989: db $FF;X
L12698A: db $FB;X
L12698B: db $F6;X
L12698C: db $FB;X
L12698D: db $7F;X
L12698E: db $FE;X
L12698F: db $FF;X
L126990: db $FF;X
L126991: db $7F;X
L126992: db $FE;X
L126993: db $FD;X
L126994: db $FF;X
L126995: db $FF;X
L126996: db $7F;X
L126997: db $FF;X
L126998: db $FF;X
L126999: db $FD;X
L12699A: db $FF;X
L12699B: db $EB;X
L12699C: db $FF;X
L12699D: db $FB;X
L12699E: db $FF;X
L12699F: db $FF;X
L1269A0: db $FF;X
L1269A1: db $FF;X
L1269A2: db $FF;X
L1269A3: db $FB;X
L1269A4: db $7F;X
L1269A5: db $BF;X
L1269A6: db $EF;X
L1269A7: db $FF;X
L1269A8: db $FF;X
L1269A9: db $FF;X
L1269AA: db $FE;X
L1269AB: db $77;X
L1269AC: db $FB;X
L1269AD: db $FF;X
L1269AE: db $FF;X
L1269AF: db $FF;X
L1269B0: db $EF;X
L1269B1: db $FF;X
L1269B2: db $EF;X
L1269B3: db $FF;X
L1269B4: db $FE;X
L1269B5: db $FF;X
L1269B6: db $FF;X
L1269B7: db $ED;X
L1269B8: db $73;X
L1269B9: db $FF;X
L1269BA: db $FF;X
L1269BB: db $7E;X
L1269BC: db $FF;X
L1269BD: db $D7;X
L1269BE: db $EE;X
L1269BF: db $F6;X
L1269C0: db $C7;X
L1269C1: db $EF;X
L1269C2: db $FF;X
L1269C3: db $FF;X
L1269C4: db $EB;X
L1269C5: db $FD;X
L1269C6: db $EF;X
L1269C7: db $D7;X
L1269C8: db $FA;X
L1269C9: db $FF;X
L1269CA: db $F7;X
L1269CB: db $FF;X
L1269CC: db $9B;X
L1269CD: db $FD;X
L1269CE: db $EF;X
L1269CF: db $FF;X
L1269D0: db $FF;X
L1269D1: db $6F;X
L1269D2: db $FF;X
L1269D3: db $FE;X
L1269D4: db $FF;X
L1269D5: db $E9;X
L1269D6: db $FF;X
L1269D7: db $FD;X
L1269D8: db $FF;X
L1269D9: db $FE;X
L1269DA: db $FD;X
L1269DB: db $FF;X
L1269DC: db $FD;X
L1269DD: db $AF;X
L1269DE: db $B7;X
L1269DF: db $FF;X
L1269E0: db $FF;X
L1269E1: db $FE;X
L1269E2: db $FF;X
L1269E3: db $DF;X
L1269E4: db $7D;X
L1269E5: db $FF;X
L1269E6: db $FF;X
L1269E7: db $FE;X
L1269E8: db $7F;X
L1269E9: db $BE;X
L1269EA: db $CF;X
L1269EB: db $FF;X
L1269EC: db $FF;X
L1269ED: db $F7;X
L1269EE: db $F7;X
L1269EF: db $FF;X
L1269F0: db $FF;X
L1269F1: db $F7;X
L1269F2: db $EF;X
L1269F3: db $FF;X
L1269F4: db $FE;X
L1269F5: db $FF;X
L1269F6: db $FF;X
L1269F7: db $FF;X
L1269F8: db $FF;X
L1269F9: db $FF;X
L1269FA: db $DD;X
L1269FB: db $EF;X
L1269FC: db $FB;X
L1269FD: db $BF;X
L1269FE: db $FF;X
L1269FF: db $FE;X
L126A00: db $00;X
L126A01: db $00;X
L126A02: db $00;X
L126A03: db $00;X
L126A04: db $00;X
L126A05: db $00;X
L126A06: db $05;X
L126A07: db $00;X
L126A08: db $00;X
L126A09: db $00;X
L126A0A: db $00;X
L126A0B: db $90;X
L126A0C: db $00;X
L126A0D: db $00;X
L126A0E: db $40;X
L126A0F: db $00;X
L126A10: db $00;X
L126A11: db $00;X
L126A12: db $00;X
L126A13: db $00;X
L126A14: db $90;X
L126A15: db $00;X
L126A16: db $00;X
L126A17: db $00;X
L126A18: db $80;X
L126A19: db $00;X
L126A1A: db $00;X
L126A1B: db $00;X
L126A1C: db $00;X
L126A1D: db $00;X
L126A1E: db $00;X
L126A1F: db $00;X
L126A20: db $00;X
L126A21: db $80;X
L126A22: db $00;X
L126A23: db $00;X
L126A24: db $A0;X
L126A25: db $10;X
L126A26: db $00;X
L126A27: db $00;X
L126A28: db $00;X
L126A29: db $00;X
L126A2A: db $00;X
L126A2B: db $00;X
L126A2C: db $00;X
L126A2D: db $00;X
L126A2E: db $00;X
L126A2F: db $20;X
L126A30: db $20;X
L126A31: db $00;X
L126A32: db $00;X
L126A33: db $00;X
L126A34: db $00;X
L126A35: db $02;X
L126A36: db $00;X
L126A37: db $84;X
L126A38: db $00;X
L126A39: db $00;X
L126A3A: db $01;X
L126A3B: db $00;X
L126A3C: db $00;X
L126A3D: db $00;X
L126A3E: db $02;X
L126A3F: db $00;X
L126A40: db $10;X
L126A41: db $00;X
L126A42: db $00;X
L126A43: db $00;X
L126A44: db $0A;X
L126A45: db $00;X
L126A46: db $00;X
L126A47: db $10;X
L126A48: db $00;X
L126A49: db $00;X
L126A4A: db $00;X
L126A4B: db $00;X
L126A4C: db $40;X
L126A4D: db $00;X
L126A4E: db $10;X
L126A4F: db $00;X
L126A50: db $40;X
L126A51: db $00;X
L126A52: db $00;X
L126A53: db $21;X
L126A54: db $00;X
L126A55: db $10;X
L126A56: db $00;X
L126A57: db $00;X
L126A58: db $00;X
L126A59: db $00;X
L126A5A: db $00;X
L126A5B: db $00;X
L126A5C: db $00;X
L126A5D: db $00;X
L126A5E: db $00;X
L126A5F: db $80;X
L126A60: db $00;X
L126A61: db $00;X
L126A62: db $00;X
L126A63: db $00;X
L126A64: db $20;X
L126A65: db $00;X
L126A66: db $40;X
L126A67: db $00;X
L126A68: db $00;X
L126A69: db $00;X
L126A6A: db $00;X
L126A6B: db $00;X
L126A6C: db $00;X
L126A6D: db $00;X
L126A6E: db $00;X
L126A6F: db $00;X
L126A70: db $00;X
L126A71: db $00;X
L126A72: db $00;X
L126A73: db $00;X
L126A74: db $00;X
L126A75: db $00;X
L126A76: db $00;X
L126A77: db $00;X
L126A78: db $00;X
L126A79: db $00;X
L126A7A: db $00;X
L126A7B: db $00;X
L126A7C: db $00;X
L126A7D: db $10;X
L126A7E: db $00;X
L126A7F: db $40;X
L126A80: db $FF;X
L126A81: db $A7;X
L126A82: db $FF;X
L126A83: db $FB;X
L126A84: db $FF;X
L126A85: db $DB;X
L126A86: db $FF;X
L126A87: db $FF;X
L126A88: db $FF;X
L126A89: db $FF;X
L126A8A: db $FE;X
L126A8B: db $FF;X
L126A8C: db $FF;X
L126A8D: db $F7;X
L126A8E: db $FF;X
L126A8F: db $FF;X
L126A90: db $BC;X
L126A91: db $FF;X
L126A92: db $FF;X
L126A93: db $FB;X
L126A94: db $7F;X
L126A95: db $FF;X
L126A96: db $F7;X
L126A97: db $BF;X
L126A98: db $FB;X
L126A99: db $FE;X
L126A9A: db $FB;X
L126A9B: db $DD;X
L126A9C: db $F7;X
L126A9D: db $EF;X
L126A9E: db $7F;X
L126A9F: db $FB;X
L126AA0: db $FF;X
L126AA1: db $FF;X
L126AA2: db $DF;X
L126AA3: db $67;X
L126AA4: db $FF;X
L126AA5: db $F5;X
L126AA6: db $F7;X
L126AA7: db $FD;X
L126AA8: db $DD;X
L126AA9: db $FF;X
L126AAA: db $F7;X
L126AAB: db $F7;X
L126AAC: db $FF;X
L126AAD: db $FF;X
L126AAE: db $FF;X
L126AAF: db $FF;X
L126AB0: db $FD;X
L126AB1: db $F7;X
L126AB2: db $BF;X
L126AB3: db $FF;X
L126AB4: db $F7;X
L126AB5: db $EE;X
L126AB6: db $BD;X
L126AB7: db $F6;X
L126AB8: db $FE;X
L126AB9: db $7F;X
L126ABA: db $FF;X
L126ABB: db $EF;X
L126ABC: db $8F;X
L126ABD: db $FF;X
L126ABE: db $FF;X
L126ABF: db $6F;X
L126AC0: db $DD;X
L126AC1: db $FB;X
L126AC2: db $F7;X
L126AC3: db $F3;X
L126AC4: db $EF;X
L126AC5: db $7D;X
L126AC6: db $FF;X
L126AC7: db $EF;X
L126AC8: db $FF;X
L126AC9: db $FF;X
L126ACA: db $FD;X
L126ACB: db $BD;X
L126ACC: db $F7;X
L126ACD: db $BD;X
L126ACE: db $FF;X
L126ACF: db $3F;X
L126AD0: db $BD;X
L126AD1: db $FB;X
L126AD2: db $DF;X
L126AD3: db $BF;X
L126AD4: db $FE;X
L126AD5: db $F7;X
L126AD6: db $FF;X
L126AD7: db $FF;X
L126AD8: db $DF;X
L126AD9: db $F7;X
L126ADA: db $FF;X
L126ADB: db $FF;X
L126adc: db $B7;X
L126add: db $FE;X
L126ADE: db $FD;X
L126ADF: db $FF;X
L126AE0: db $FF;X
L126AE1: db $FF;X
L126AE2: db $FD;X
L126AE3: db $FD;X
L126AE4: db $FF;X
L126AE5: db $FF;X
L126AE6: db $DF;X
L126AE7: db $DD;X
L126AE8: db $FF;X
L126AE9: db $EB;X
L126AEA: db $F7;X
L126AEB: db $FC;X
L126AEC: db $FF;X
L126AED: db $FD;X
L126AEE: db $FF;X
L126AEF: db $FF;X
L126AF0: db $EE;X
L126AF1: db $FF;X
L126AF2: db $FF;X
L126AF3: db $FF;X
L126AF4: db $EF;X
L126AF5: db $BE;X
L126AF6: db $FF;X
L126AF7: db $BF;X
L126AF8: db $FF;X
L126AF9: db $F9;X
L126AFA: db $73;X
L126AFB: db $FE;X
L126AFC: db $EE;X
L126AFD: db $FB;X
L126AFE: db $F7;X
L126AFF: db $FF;X
L126B00: db $00;X
L126B01: db $04;X
L126B02: db $00;X
L126B03: db $90;X
L126B04: db $01;X
L126B05: db $04;X
L126B06: db $00;X
L126B07: db $01;X
L126B08: db $00;X
L126B09: db $00;X
L126B0A: db $00;X
L126B0B: db $00;X
L126B0C: db $00;X
L126B0D: db $00;X
L126B0E: db $00;X
L126B0F: db $00;X
L126B10: db $80;X
L126B11: db $00;X
L126B12: db $00;X
L126B13: db $00;X
L126B14: db $01;X
L126B15: db $01;X
L126B16: db $00;X
L126B17: db $00;X
L126B18: db $00;X
L126B19: db $00;X
L126B1A: db $01;X
L126B1B: db $00;X
L126B1C: db $00;X
L126B1D: db $00;X
L126B1E: db $00;X
L126B1F: db $00;X
L126B20: db $20;X
L126B21: db $00;X
L126B22: db $00;X
L126B23: db $84;X
L126B24: db $00;X
L126B25: db $00;X
L126B26: db $00;X
L126B27: db $00;X
L126B28: db $00;X
L126B29: db $00;X
L126B2A: db $80;X
L126B2B: db $00;X
L126B2C: db $00;X
L126B2D: db $40;X
L126B2E: db $00;X
L126B2F: db $24;X
L126B30: db $08;X
L126B31: db $08;X
L126B32: db $00;X
L126B33: db $00;X
L126B34: db $00;X
L126B35: db $00;X
L126B36: db $00;X
L126B37: db $00;X
L126B38: db $00;X
L126B39: db $20;X
L126B3A: db $40;X
L126B3B: db $10;X
L126B3C: db $00;X
L126B3D: db $00;X
L126B3E: db $00;X
L126B3F: db $00;X
L126B40: db $02;X
L126B41: db $10;X
L126B42: db $00;X
L126B43: db $00;X
L126B44: db $00;X
L126B45: db $00;X
L126B46: db $00;X
L126B47: db $00;X
L126B48: db $00;X
L126B49: db $00;X
L126B4A: db $00;X
L126B4B: db $00;X
L126B4C: db $00;X
L126B4D: db $00;X
L126B4E: db $00;X
L126B4F: db $00;X
L126B50: db $00;X
L126B51: db $00;X
L126B52: db $00;X
L126B53: db $10;X
L126B54: db $00;X
L126B55: db $14;X
L126B56: db $08;X
L126B57: db $00;X
L126B58: db $00;X
L126B59: db $00;X
L126B5A: db $00;X
L126B5B: db $20;X
L126B5C: db $00;X
L126B5D: db $00;X
L126B5E: db $00;X
L126B5F: db $00;X
L126B60: db $00;X
L126B61: db $00;X
L126B62: db $00;X
L126B63: db $00;X
L126B64: db $00;X
L126B65: db $00;X
L126B66: db $00;X
L126B67: db $10;X
L126B68: db $00;X
L126B69: db $00;X
L126B6A: db $00;X
L126B6B: db $00;X
L126B6C: db $00;X
L126B6D: db $00;X
L126B6E: db $00;X
L126B6F: db $00;X
L126B70: db $00;X
L126B71: db $00;X
L126B72: db $01;X
L126B73: db $00;X
L126B74: db $00;X
L126B75: db $00;X
L126B76: db $00;X
L126B77: db $80;X
L126B78: db $00;X
L126B79: db $00;X
L126B7A: db $00;X
L126B7B: db $00;X
L126B7C: db $00;X
L126B7D: db $04;X
L126B7E: db $00;X
L126B7F: db $00;X
L126B80: db $FF;X
L126B81: db $FE;X
L126B82: db $BF;X
L126B83: db $FE;X
L126B84: db $F3;X
L126B85: db $E7;X
L126B86: db $FF;X
L126B87: db $FF;X
L126B88: db $CE;X
L126B89: db $FE;X
L126B8A: db $FF;X
L126B8B: db $FF;X
L126B8C: db $E7;X
L126B8D: db $F2;X
L126B8E: db $F7;X
L126B8F: db $F7;X
L126B90: db $FE;X
L126B91: db $EF;X
L126B92: db $FD;X
L126B93: db $FE;X
L126B94: db $FA;X
L126B95: db $FD;X
L126B96: db $FF;X
L126B97: db $77;X
L126B98: db $FF;X
L126B99: db $7E;X
L126B9A: db $FF;X
L126B9B: db $EF;X
L126B9C: db $F9;X
L126B9D: db $DE;X
L126B9E: db $FD;X
L126B9F: db $BD;X
L126BA0: db $F7;X
L126BA1: db $FF;X
L126BA2: db $EF;X
L126BA3: db $EF;X
L126BA4: db $FF;X
L126BA5: db $EE;X
L126BA6: db $FF;X
L126BA7: db $F7;X
L126BA8: db $DB;X
L126BA9: db $B7;X
L126BAA: db $FB;X
L126BAB: db $FD;X
L126BAC: db $EC;X
L126BAD: db $FF;X
L126BAE: db $FF;X
L126BAF: db $FF;X
L126BB0: db $FF;X
L126BB1: db $FF;X
L126BB2: db $FF;X
L126BB3: db $6F;X
L126BB4: db $FF;X
L126BB5: db $F8;X
L126BB6: db $FF;X
L126BB7: db $DF;X
L126BB8: db $6B;X
L126BB9: db $FF;X
L126BBA: db $FF;X
L126BBB: db $FF;X
L126BBC: db $ED;X
L126BBD: db $FF;X
L126BBE: db $FF;X
L126BBF: db $FF;X
L126BC0: db $F3;X
L126BC1: db $FB;X
L126BC2: db $ED;X
L126BC3: db $FB;X
L126BC4: db $F5;X
L126BC5: db $BB;X
L126BC6: db $FF;X
L126BC7: db $74;X
L126BC8: db $DF;X
L126BC9: db $FD;X
L126BCA: db $EF;X
L126BCB: db $DF;X
L126BCC: db $FF;X
L126BCD: db $FB;X
L126BCE: db $7F;X
L126BCF: db $FE;X
L126BD0: db $FD;X
L126BD1: db $FF;X
L126BD2: db $F7;X
L126BD3: db $FE;X
L126BD4: db $DF;X
L126BD5: db $BF;X
L126BD6: db $FD;X
L126BD7: db $F7;X
L126BD8: db $FF;X
L126BD9: db $FE;X
L126BDA: db $FF;X
L126BDB: db $EF;X
L126BDC: db $CB;X
L126BDD: db $FF;X
L126BDE: db $FF;X
L126BDF: db $FF;X
L126BE0: db $FF;X
L126BE1: db $FB;X
L126BE2: db $FB;X
L126BE3: db $D7;X
L126BE4: db $FF;X
L126BE5: db $EB;X
L126BE6: db $FD;X
L126BE7: db $EF;X
L126BE8: db $FB;X
L126BE9: db $FF;X
L126BEA: db $FF;X
L126BEB: db $FF;X
L126BEC: db $F7;X
L126BED: db $FF;X
L126BEE: db $FF;X
L126BEF: db $FF;X
L126BF0: db $FF;X
L126BF1: db $FF;X
L126BF2: db $FF;X
L126BF3: db $F5;X
L126BF4: db $FA;X
L126BF5: db $FF;X
L126BF6: db $FD;X
L126BF7: db $CF;X
L126BF8: db $F7;X
L126BF9: db $FF;X
L126BFA: db $7B;X
L126BFB: db $7F;X
L126BFC: db $FB;X
L126BFD: db $FF;X
L126BFE: db $FD;X
L126BFF: db $FF;X
L126C00: db $00;X
L126C01: db $00;X
L126C02: db $00;X
L126C03: db $00;X
L126C04: db $40;X
L126C05: db $20;X
L126C06: db $40;X
L126C07: db $08;X
L126C08: db $00;X
L126C09: db $00;X
L126C0A: db $00;X
L126C0B: db $00;X
L126C0C: db $00;X
L126C0D: db $00;X
L126C0E: db $00;X
L126C0F: db $00;X
L126C10: db $00;X
L126C11: db $00;X
L126C12: db $00;X
L126C13: db $00;X
L126C14: db $00;X
L126C15: db $00;X
L126C16: db $00;X
L126C17: db $00;X
L126C18: db $00;X
L126C19: db $00;X
L126C1A: db $00;X
L126C1B: db $00;X
L126C1C: db $00;X
L126C1D: db $00;X
L126C1E: db $10;X
L126C1F: db $00;X
L126C20: db $00;X
L126C21: db $00;X
L126C22: db $00;X
L126C23: db $00;X
L126C24: db $00;X
L126C25: db $00;X
L126C26: db $00;X
L126C27: db $10;X
L126C28: db $00;X
L126C29: db $28;X
L126C2A: db $00;X
L126C2B: db $00;X
L126C2C: db $00;X
L126C2D: db $00;X
L126C2E: db $00;X
L126C2F: db $00;X
L126C30: db $04;X
L126C31: db $00;X
L126C32: db $00;X
L126C33: db $00;X
L126C34: db $00;X
L126C35: db $05;X
L126C36: db $08;X
L126C37: db $00;X
L126C38: db $00;X
L126C39: db $A0;X
L126C3A: db $0C;X
L126C3B: db $80;X
L126C3C: db $00;X
L126C3D: db $82;X
L126C3E: db $01;X
L126C3F: db $02;X
L126C40: db $00;X
L126C41: db $00;X
L126C42: db $00;X
L126C43: db $00;X
L126C44: db $00;X
L126C45: db $00;X
L126C46: db $80;X
L126C47: db $00;X
L126C48: db $00;X
L126C49: db $00;X
L126C4A: db $00;X
L126C4B: db $00;X
L126C4C: db $00;X
L126C4D: db $00;X
L126C4E: db $00;X
L126C4F: db $00;X
L126C50: db $00;X
L126C51: db $00;X
L126C52: db $00;X
L126C53: db $00;X
L126C54: db $00;X
L126C55: db $08;X
L126C56: db $08;X
L126C57: db $08;X
L126C58: db $00;X
L126C59: db $00;X
L126C5A: db $00;X
L126C5B: db $00;X
L126C5C: db $02;X
L126C5D: db $02;X
L126C5E: db $00;X
L126C5F: db $00;X
L126C60: db $00;X
L126C61: db $00;X
L126C62: db $00;X
L126C63: db $00;X
L126C64: db $40;X
L126C65: db $00;X
L126C66: db $01;X
L126C67: db $00;X
L126C68: db $00;X
L126C69: db $00;X
L126C6A: db $60;X
L126C6B: db $00;X
L126C6C: db $00;X
L126C6D: db $00;X
L126C6E: db $01;X
L126C6F: db $00;X
L126C70: db $00;X
L126C71: db $00;X
L126C72: db $04;X
L126C73: db $00;X
L126C74: db $00;X
L126C75: db $00;X
L126C76: db $08;X
L126C77: db $00;X
L126C78: db $08;X
L126C79: db $00;X
L126C7A: db $00;X
L126C7B: db $00;X
L126C7C: db $00;X
L126C7D: db $00;X
L126C7E: db $00;X
L126C7F: db $00;X
L126C80: db $BF;X
L126C81: db $FF;X
L126C82: db $FF;X
L126C83: db $FF;X
L126C84: db $FF;X
L126C85: db $FF;X
L126C86: db $FB;X
L126C87: db $EF;X
L126C88: db $DF;X
L126C89: db $FD;X
L126C8A: db $FF;X
L126C8B: db $FF;X
L126C8C: db $FF;X
L126C8D: db $AF;X
L126C8E: db $7F;X
L126C8F: db $FF;X
L126C90: db $FF;X
L126C91: db $FA;X
L126C92: db $D7;X
L126C93: db $FF;X
L126C94: db $FF;X
L126C95: db $FF;X
L126C96: db $FE;X
L126C97: db $FF;X
L126C98: db $FF;X
L126C99: db $FF;X
L126C9A: db $EF;X
L126C9B: db $FF;X
L126C9C: db $FF;X
L126C9D: db $FF;X
L126C9E: db $FF;X
L126C9F: db $FF;X
L126CA0: db $FF;X
L126CA1: db $FF;X
L126CA2: db $FF;X
L126CA3: db $FF;X
L126CA4: db $FF;X
L126CA5: db $FE;X
L126CA6: db $FF;X
L126CA7: db $7F;X
L126CA8: db $FF;X
L126CA9: db $FF;X
L126CAA: db $6F;X
L126CAB: db $FF;X
L126CAC: db $FF;X
L126CAD: db $FF;X
L126CAE: db $FF;X
L126CAF: db $FF;X
L126CB0: db $FB;X
L126CB1: db $FF;X
L126CB2: db $FF;X
L126CB3: db $FF;X
L126CB4: db $FF;X
L126CB5: db $EF;X
L126CB6: db $FF;X
L126CB7: db $DD;X
L126CB8: db $BF;X
L126CB9: db $EF;X
L126CBA: db $FE;X
L126CBB: db $FF;X
L126CBC: db $BF;X
L126CBD: db $FF;X
L126CBE: db $FF;X
L126CBF: db $EF;X
L126CC0: db $FF;X
L126CC1: db $7F;X
L126CC2: db $FF;X
L126CC3: db $FF;X
L126CC4: db $FF;X
L126CC5: db $EF;X
L126CC6: db $7F;X
L126CC7: db $FF;X
L126CC8: db $F7;X
L126CC9: db $FF;X
L126CCA: db $FF;X
L126CCB: db $FF;X
L126CCC: db $FF;X
L126CCD: db $FF;X
L126CCE: db $FD;X
L126CCF: db $FF;X
L126CD0: db $FF;X
L126CD1: db $FF;X
L126CD2: db $FF;X
L126CD3: db $FF;X
L126CD4: db $FF;X
L126CD5: db $FF;X
L126CD6: db $FF;X
L126CD7: db $FF;X
L126CD8: db $FF;X
L126CD9: db $FF;X
L126CDA: db $FF;X
L126CDB: db $7F;X
L126CDC: db $FF;X
L126CDD: db $F7;X
L126CDE: db $BF;X
L126CDF: db $FF;X
L126CE0: db $FF;X
L126CE1: db $7F;X
L126CE2: db $FF;X
L126CE3: db $DF;X
L126CE4: db $FF;X
L126CE5: db $FF;X
L126CE6: db $FF;X
L126CE7: db $FF;X
L126CE8: db $FF;X
L126CE9: db $BF;X
L126CEA: db $FD;X
L126CEB: db $7E;X
L126CEC: db $FF;X
L126CED: db $CB;X
L126CEE: db $FF;X
L126CEF: db $F7;X
L126CF0: db $FF;X
L126CF1: db $FF;X
L126CF2: db $FF;X
L126CF3: db $FF;X
L126CF4: db $EF;X
L126CF5: db $FB;X
L126CF6: db $FF;X
L126CF7: db $FF;X
L126CF8: db $FF;X
L126CF9: db $FF;X
L126CFA: db $FB;X
L126CFB: db $FF;X
L126CFC: db $FD;X
L126CFD: db $FF;X
L126CFE: db $FF;X
L126CFF: db $FF;X
L126D00: db $00;X
L126D01: db $00;X
L126D02: db $01;X
L126D03: db $00;X
L126D04: db $00;X
L126D05: db $00;X
L126D06: db $00;X
L126D07: db $00;X
L126D08: db $00;X
L126D09: db $00;X
L126D0A: db $01;X
L126D0B: db $01;X
L126D0C: db $00;X
L126D0D: db $00;X
L126D0E: db $00;X
L126D0F: db $80;X
L126D10: db $00;X
L126D11: db $00;X
L126D12: db $18;X
L126D13: db $00;X
L126D14: db $00;X
L126D15: db $00;X
L126D16: db $20;X
L126D17: db $04;X
L126D18: db $00;X
L126D19: db $01;X
L126D1A: db $00;X
L126D1B: db $01;X
L126D1C: db $00;X
L126D1D: db $08;X
L126D1E: db $00;X
L126D1F: db $00;X
L126D20: db $00;X
L126D21: db $01;X
L126D22: db $00;X
L126D23: db $00;X
L126D24: db $00;X
L126D25: db $00;X
L126D26: db $03;X
L126D27: db $00;X
L126D28: db $00;X
L126D29: db $00;X
L126D2A: db $00;X
L126D2B: db $00;X
L126D2C: db $08;X
L126D2D: db $02;X
L126D2E: db $00;X
L126D2F: db $00;X
L126D30: db $00;X
L126D31: db $00;X
L126D32: db $04;X
L126D33: db $00;X
L126D34: db $00;X
L126D35: db $01;X
L126D36: db $01;X
L126D37: db $00;X
L126D38: db $00;X
L126D39: db $00;X
L126D3A: db $01;X
L126D3B: db $00;X
L126D3C: db $00;X
L126D3D: db $00;X
L126D3E: db $00;X
L126D3F: db $01;X
L126D40: db $00;X
L126D41: db $00;X
L126D42: db $00;X
L126D43: db $00;X
L126D44: db $00;X
L126D45: db $00;X
L126D46: db $00;X
L126D47: db $00;X
L126D48: db $00;X
L126D49: db $00;X
L126D4A: db $00;X
L126D4B: db $00;X
L126D4C: db $04;X
L126D4D: db $00;X
L126D4E: db $00;X
L126D4F: db $00;X
L126D50: db $00;X
L126D51: db $00;X
L126D52: db $00;X
L126D53: db $01;X
L126D54: db $01;X
L126D55: db $00;X
L126D56: db $00;X
L126D57: db $00;X
L126D58: db $00;X
L126D59: db $00;X
L126D5A: db $04;X
L126D5B: db $00;X
L126D5C: db $00;X
L126D5D: db $00;X
L126D5E: db $00;X
L126D5F: db $00;X
L126D60: db $00;X
L126D61: db $00;X
L126D62: db $04;X
L126D63: db $00;X
L126D64: db $00;X
L126D65: db $00;X
L126D66: db $00;X
L126D67: db $40;X
L126D68: db $00;X
L126D69: db $20;X
L126D6A: db $00;X
L126D6B: db $00;X
L126D6C: db $00;X
L126D6D: db $00;X
L126D6E: db $02;X
L126D6F: db $20;X
L126D70: db $02;X
L126D71: db $00;X
L126D72: db $00;X
L126D73: db $00;X
L126D74: db $00;X
L126D75: db $10;X
L126D76: db $04;X
L126D77: db $00;X
L126D78: db $02;X
L126D79: db $00;X
L126D7A: db $08;X
L126D7B: db $40;X
L126D7C: db $11;X
L126D7D: db $80;X
L126D7E: db $40;X
L126D7F: db $00;X
L126D80: db $FF;X
L126D81: db $FF;X
L126D82: db $FF;X
L126D83: db $FF;X
L126D84: db $EF;X
L126D85: db $FF;X
L126D86: db $FF;X
L126D87: db $FF;X
L126D88: db $FF;X
L126D89: db $FF;X
L126D8A: db $FF;X
L126D8B: db $BF;X
L126D8C: db $FF;X
L126D8D: db $BF;X
L126D8E: db $FF;X
L126D8F: db $FF;X
L126D90: db $FF;X
L126D91: db $FF;X
L126D92: db $FF;X
L126D93: db $FB;X
L126D94: db $7F;X
L126D95: db $FF;X
L126D96: db $FF;X
L126D97: db $FF;X
L126D98: db $FF;X
L126D99: db $BF;X
L126D9A: db $FF;X
L126D9B: db $EF;X
L126D9C: db $FF;X
L126D9D: db $7F;X
L126D9E: db $FF;X
L126D9F: db $EF;X
L126DA0: db $F7;X
L126DA1: db $7F;X
L126DA2: db $FF;X
L126DA3: db $7F;X
L126DA4: db $FF;X
L126DA5: db $FF;X
L126DA6: db $FD;X
L126DA7: db $DF;X
L126DA8: db $DF;X
L126DA9: db $FD;X
L126DAA: db $F7;X
L126DAB: db $67;X
L126DAC: db $FB;X
L126DAD: db $FD;X
L126DAE: db $FF;X
L126DAF: db $FF;X
L126DB0: db $FF;X
L126DB1: db $FF;X
L126DB2: db $FF;X
L126DB3: db $FF;X
L126DB4: db $FF;X
L126DB5: db $EF;X
L126DB6: db $EB;X
L126DB7: db $EF;X
L126DB8: db $FF;X
L126DB9: db $FF;X
L126DBA: db $FF;X
L126DBB: db $FF;X
L126DBC: db $FF;X
L126DBD: db $FF;X
L126DBE: db $FF;X
L126DBF: db $FF;X
L126DC0: db $FF;X
L126DC1: db $FB;X
L126DC2: db $FE;X
L126DC3: db $FF;X
L126DC4: db $FF;X
L126DC5: db $FD;X
L126DC6: db $FF;X
L126DC7: db $FF;X
L126DC8: db $FF;X
L126DC9: db $FF;X
L126DCA: db $FF;X
L126DCB: db $BF;X
L126DCC: db $FF;X
L126DCD: db $FF;X
L126DCE: db $FF;X
L126DCF: db $EF;X
L126DD0: db $FF;X
L126DD1: db $FB;X
L126DD2: db $FF;X
L126DD3: db $7E;X
L126DD4: db $FF;X
L126DD5: db $FF;X
L126DD6: db $FF;X
L126DD7: db $FF;X
L126DD8: db $FF;X
L126DD9: db $FF;X
L126DDA: db $FF;X
L126DDB: db $FF;X
L126DDC: db $FF;X
L126DDD: db $FB;X
L126DDE: db $FF;X
L126DDF: db $FF;X
L126DE0: db $FF;X
L126DE1: db $FE;X
L126DE2: db $FF;X
L126DE3: db $EF;X
L126DE4: db $DB;X
L126DE5: db $7F;X
L126DE6: db $FF;X
L126DE7: db $DF;X
L126DE8: db $FF;X
L126DE9: db $AF;X
L126DEA: db $FF;X
L126DEB: db $FF;X
L126dec: db $FF;X
L126DED: db $FF;X
L126DEE: db $FF;X
L126DEF: db $FD;X
L126DF0: db $FF;X
L126DF1: db $FD;X
L126DF2: db $FF;X
L126DF3: db $7F;X
L126DF4: db $FF;X
L126DF5: db $EF;X
L126DF6: db $FF;X
L126DF7: db $FF;X
L126DF8: db $EF;X
L126DF9: db $FF;X
L126DFA: db $FF;X
L126DFB: db $FF;X
L126DFC: db $EF;X
L126DFD: db $DF;X
L126DFE: db $EF;X
L126DFF: db $FD;X
L126E00: db $A8;X
L126E01: db $48;X
L126E02: db $20;X
L126E03: db $20;X
L126E04: db $20;X
L126E05: db $40;X
L126E06: db $00;X
L126E07: db $01;X
L126E08: db $49;X
L126E09: db $00;X
L126E0A: db $80;X
L126E0B: db $00;X
L126E0C: db $02;X
L126E0D: db $52;X
L126E0E: db $00;X
L126E0F: db $48;X
L126E10: db $22;X
L126E11: db $49;X
L126E12: db $70;X
L126E13: db $40;X
L126E14: db $44;X
L126E15: db $01;X
L126E16: db $12;X
L126E17: db $02;X
L126E18: db $00;X
L126E19: db $0B;X
L126E1A: db $40;X
L126E1B: db $81;X
L126E1C: db $60;X
L126E1D: db $00;X
L126E1E: db $00;X
L126E1F: db $68;X
L126E20: db $82;X
L126E21: db $20;X
L126E22: db $80;X
L126E23: db $05;X
L126E24: db $10;X
L126E25: db $00;X
L126E26: db $00;X
L126E27: db $94;X
L126E28: db $02;X
L126E29: db $0B;X
L126E2A: db $00;X
L126E2B: db $80;X
L126E2C: db $80;X
L126E2D: db $02;X
L126E2E: db $00;X
L126E2F: db $10;X
L126E30: db $40;X
L126E31: db $80;X
L126E32: db $10;X
L126E33: db $08;X
L126E34: db $04;X
L126E35: db $48;X
L126E36: db $74;X
L126E37: db $02;X
L126E38: db $92;X
L126E39: db $10;X
L126E3A: db $30;X
L126E3B: db $02;X
L126E3C: db $04;X
L126E3D: db $02;X
L126E3E: db $B4;X
L126E3F: db $80;X
L126E40: db $88;X
L126E41: db $00;X
L126E42: db $00;X
L126E43: db $36;X
L126E44: db $01;X
L126E45: db $19;X
L126E46: db $9C;X
L126E47: db $07;X
L126E48: db $01;X
L126E49: db $00;X
L126E4A: db $21;X
L126E4B: db $42;X
L126E4C: db $00;X
L126E4D: db $80;X
L126E4E: db $11;X
L126E4F: db $44;X
L126E50: db $04;X
L126E51: db $40;X
L126E52: db $07;X
L126E53: db $00;X
L126E54: db $00;X
L126E55: db $10;X
L126E56: db $08;X
L126E57: db $20;X
L126E58: db $11;X
L126E59: db $18;X
L126E5A: db $00;X
L126E5B: db $42;X
L126E5C: db $4C;X
L126E5D: db $00;X
L126E5E: db $01;X
L126E5F: db $01;X
L126E60: db $00;X
L126E61: db $00;X
L126E62: db $00;X
L126E63: db $1C;X
L126E64: db $01;X
L126E65: db $42;X
L126E66: db $00;X
L126E67: db $00;X
L126E68: db $C0;X
L126E69: db $0F;X
L126E6A: db $20;X
L126E6B: db $29;X
L126E6C: db $80;X
L126E6D: db $40;X
L126E6E: db $8D;X
L126E6F: db $02;X
L126E70: db $20;X
L126E71: db $11;X
L126E72: db $00;X
L126E73: db $00;X
L126E74: db $11;X
L126E75: db $04;X
L126E76: db $00;X
L126E77: db $40;X
L126E78: db $02;X
L126E79: db $00;X
L126E7A: db $02;X
L126E7B: db $22;X
L126E7C: db $60;X
L126E7D: db $24;X
L126E7E: db $41;X
L126E7F: db $A8;X
L126E80: db $FF;X
L126E81: db $FF;X
L126E82: db $FF;X
L126E83: db $FF;X
L126E84: db $DF;X
L126E85: db $EB;X
L126E86: db $FF;X
L126E87: db $EF;X
L126E88: db $FF;X
L126E89: db $FF;X
L126E8A: db $FF;X
L126E8B: db $FF;X
L126E8C: db $FF;X
L126E8D: db $FF;X
L126E8E: db $FF;X
L126E8F: db $FF;X
L126E90: db $FF;X
L126E91: db $FF;X
L126E92: db $FF;X
L126E93: db $FB;X
L126E94: db $FF;X
L126E95: db $FF;X
L126E96: db $FF;X
L126E97: db $FF;X
L126E98: db $FF;X
L126E99: db $FF;X
L126E9A: db $FF;X
L126E9B: db $FF;X
L126E9C: db $FF;X
L126E9D: db $FB;X
L126E9E: db $FF;X
L126E9F: db $FF;X
L126EA0: db $FF;X
L126EA1: db $FF;X
L126EA2: db $FF;X
L126EA3: db $FF;X
L126EA4: db $FF;X
L126EA5: db $BF;X
L126EA6: db $FF;X
L126EA7: db $FF;X
L126EA8: db $FF;X
L126EA9: db $FF;X
L126EAA: db $FF;X
L126EAB: db $FB;X
L126EAC: db $FF;X
L126EAD: db $FF;X
L126EAE: db $FF;X
L126EAF: db $FF;X
L126EB0: db $FF;X
L126EB1: db $FF;X
L126EB2: db $DF;X
L126EB3: db $FF;X
L126EB4: db $FF;X
L126EB5: db $FF;X
L126EB6: db $FF;X
L126EB7: db $FF;X
L126EB8: db $FF;X
L126EB9: db $FF;X
L126EBA: db $FF;X
L126EBB: db $FF;X
L126EBC: db $FF;X
L126EBD: db $FF;X
L126EBE: db $FF;X
L126EBF: db $FF;X
L126EC0: db $FF;X
L126EC1: db $FE;X
L126EC2: db $FF;X
L126EC3: db $FD;X
L126EC4: db $FF;X
L126EC5: db $FF;X
L126EC6: db $FF;X
L126EC7: db $FF;X
L126EC8: db $FF;X
L126EC9: db $7F;X
L126ECA: db $FF;X
L126ECB: db $FF;X
L126ECC: db $FF;X
L126ECD: db $FF;X
L126ECE: db $FF;X
L126ECF: db $FF;X
L126ED0: db $FF;X
L126ED1: db $FF;X
L126ED2: db $BF;X
L126ED3: db $FF;X
L126ED4: db $FF;X
L126ED5: db $DF;X
L126ED6: db $E7;X
L126ED7: db $FF;X
L126ED8: db $FF;X
L126ED9: db $FF;X
L126EDA: db $FF;X
L126EDB: db $FF;X
L126EDC: db $DF;X
L126EDD: db $FF;X
L126EDE: db $EF;X
L126EDF: db $FF;X
L126EE0: db $FF;X
L126EE1: db $FF;X
L126EE2: db $FF;X
L126EE3: db $FF;X
L126EE4: db $FF;X
L126EE5: db $7F;X
L126EE6: db $FF;X
L126EE7: db $FF;X
L126EE8: db $FF;X
L126EE9: db $BF;X
L126EEA: db $F7;X
L126EEB: db $DF;X
L126EEC: db $FF;X
L126EED: db $FF;X
L126EEE: db $FF;X
L126EEF: db $FF;X
L126EF0: db $FF;X
L126EF1: db $FF;X
L126EF2: db $FF;X
L126EF3: db $FF;X
L126EF4: db $FF;X
L126EF5: db $FF;X
L126EF6: db $FF;X
L126EF7: db $FF;X
L126EF8: db $FF;X
L126EF9: db $FF;X
L126EFA: db $FF;X
L126EFB: db $FF;X
L126EFC: db $FF;X
L126EFD: db $FF;X
L126EFE: db $FF;X
L126EFF: db $FF;X
L126F00: db $10;X
L126F01: db $20;X
L126F02: db $23;X
L126F03: db $8E;X
L126F04: db $88;X
L126F05: db $80;X
L126F06: db $01;X
L126F07: db $00;X
L126F08: db $01;X
L126F09: db $04;X
L126F0A: db $00;X
L126F0B: db $01;X
L126F0C: db $01;X
L126F0D: db $04;X
L126F0E: db $80;X
L126F0F: db $11;X
L126F10: db $21;X
L126F11: db $00;X
L126F12: db $80;X
L126F13: db $40;X
L126F14: db $09;X
L126F15: db $27;X
L126F16: db $01;X
L126F17: db $60;X
L126F18: db $81;X
L126F19: db $01;X
L126F1A: db $82;X
L126F1B: db $05;X
L126F1C: db $81;X
L126F1D: db $8C;X
L126F1E: db $08;X
L126F1F: db $41;X
L126F20: db $0A;X
L126F21: db $21;X
L126F22: db $80;X
L126F23: db $00;X
L126F24: db $00;X
L126F25: db $02;X
L126F26: db $01;X
L126F27: db $01;X
L126F28: db $28;X
L126F29: db $01;X
L126F2A: db $82;X
L126F2B: db $4C;X
L126F2C: db $0E;X
L126F2D: db $01;X
L126F2E: db $02;X
L126F2F: db $8C;X
L126F30: db $08;X
L126F31: db $00;X
L126F32: db $C0;X
L126F33: db $05;X
L126F34: db $11;X
L126F35: db $10;X
L126F36: db $00;X
L126F37: db $08;X
L126F38: db $01;X
L126F39: db $00;X
L126F3A: db $20;X
L126F3B: db $20;X
L126F3C: db $02;X
L126F3D: db $07;X
L126F3E: db $01;X
L126F3F: db $21;X
L126F40: db $C0;X
L126F41: db $00;X
L126F42: db $0B;X
L126F43: db $00;X
L126F44: db $01;X
L126F45: db $24;X
L126F46: db $01;X
L126F47: db $00;X
L126F48: db $00;X
L126F49: db $08;X
L126F4A: db $00;X
L126F4B: db $A3;X
L126F4C: db $09;X
L126F4D: db $20;X
L126F4E: db $0A;X
L126F4F: db $08;X
L126F50: db $00;X
L126F51: db $04;X
L126F52: db $88;X
L126F53: db $44;X
L126F54: db $09;X
L126F55: db $00;X
L126F56: db $22;X
L126F57: db $00;X
L126F58: db $00;X
L126F59: db $01;X
L126F5A: db $80;X
L126F5B: db $81;X
L126F5C: db $40;X
L126F5D: db $99;X
L126F5E: db $02;X
L126F5F: db $20;X
L126F60: db $01;X
L126F61: db $00;X
L126F62: db $00;X
L126F63: db $01;X
L126F64: db $20;X
L126F65: db $20;X
L126F66: db $00;X
L126F67: db $00;X
L126F68: db $00;X
L126F69: db $04;X
L126F6A: db $40;X
L126F6B: db $01;X
L126F6C: db $00;X
L126F6D: db $18;X
L126F6E: db $01;X
L126F6F: db $83;X
L126F70: db $41;X
L126F71: db $03;X
L126F72: db $81;X
L126F73: db $80;X
L126F74: db $01;X
L126F75: db $05;X
L126F76: db $00;X
L126F77: db $40;X
L126F78: db $A5;X
L126F79: db $00;X
L126F7A: db $28;X
L126F7B: db $00;X
L126F7C: db $02;X
L126F7D: db $0B;X
L126F7E: db $29;X
L126F7F: db $AC;X
L126F80: db $FF;X
L126F81: db $FF;X
L126F82: db $FF;X
L126F83: db $FF;X
L126F84: db $FF;X
L126F85: db $FF;X
L126F86: db $BF;X
L126F87: db $FF;X
L126F88: db $FF;X
L126F89: db $FD;X
L126F8A: db $EF;X
L126F8B: db $FF;X
L126F8C: db $EF;X
L126F8D: db $FF;X
L126F8E: db $FF;X
L126F8F: db $FF;X
L126F90: db $FF;X
L126F91: db $3F;X
L126F92: db $FF;X
L126F93: db $EF;X
L126F94: db $FF;X
L126F95: db $FF;X
L126F96: db $FF;X
L126F97: db $FF;X
L126F98: db $FF;X
L126F99: db $FF;X
L126F9A: db $FF;X
L126F9B: db $FF;X
L126F9C: db $FF;X
L126F9D: db $EF;X
L126F9E: db $FF;X
L126F9F: db $FF;X
L126FA0: db $FF;X
L126FA1: db $FF;X
L126FA2: db $FF;X
L126FA3: db $EF;X
L126FA4: db $FF;X
L126FA5: db $FF;X
L126FA6: db $FF;X
L126FA7: db $FF;X
L126FA8: db $FF;X
L126FA9: db $FF;X
L126FAA: db $FF;X
L126FAB: db $FF;X
L126FAC: db $EF;X
L126FAD: db $FF;X
L126FAE: db $FF;X
L126FAF: db $FF;X
L126FB0: db $FF;X
L126FB1: db $FF;X
L126FB2: db $EF;X
L126FB3: db $EF;X
L126FB4: db $FF;X
L126FB5: db $FF;X
L126FB6: db $FF;X
L126FB7: db $FF;X
L126FB8: db $FF;X
L126FB9: db $FF;X
L126FBA: db $FF;X
L126FBB: db $FF;X
L126FBC: db $FF;X
L126FBD: db $EF;X
L126FBE: db $FF;X
L126FBF: db $FF;X
L126FC0: db $FF;X
L126FC1: db $FF;X
L126FC2: db $FF;X
L126FC3: db $FF;X
L126FC4: db $FF;X
L126FC5: db $FF;X
L126FC6: db $3F;X
L126FC7: db $FF;X
L126FC8: db $FF;X
L126FC9: db $FF;X
L126FCA: db $FF;X
L126FCB: db $FF;X
L126FCC: db $FF;X
L126FCD: db $FF;X
L126FCE: db $FF;X
L126FCF: db $FF;X
L126FD0: db $FF;X
L126FD1: db $FF;X
L126FD2: db $FF;X
L126FD3: db $FF;X
L126FD4: db $FF;X
L126FD5: db $FF;X
L126FD6: db $FF;X
L126FD7: db $EF;X
L126FD8: db $FF;X
L126FD9: db $EF;X
L126FDA: db $FF;X
L126FDB: db $FF;X
L126FDC: db $FF;X
L126FDD: db $EF;X
L126FDE: db $FF;X
L126FDF: db $FD;X
L126FE0: db $FF;X
L126FE1: db $F7;X
L126FE2: db $DF;X
L126FE3: db $FF;X
L126FE4: db $FF;X
L126FE5: db $FF;X
L126FE6: db $FF;X
L126FE7: db $FF;X
L126FE8: db $FF;X
L126FE9: db $FF;X
L126FEA: db $FF;X
L126FEB: db $FF;X
L126FEC: db $FF;X
L126FED: db $EF;X
L126FEE: db $FF;X
L126FEF: db $EF;X
L126FF0: db $FF;X
L126FF1: db $FF;X
L126FF2: db $7F;X
L126FF3: db $EF;X
L126FF4: db $FF;X
L126FF5: db $7F;X
L126FF6: db $FF;X
L126FF7: db $DF;X
L126FF8: db $FF;X
L126FF9: db $FF;X
L126FFA: db $FF;X
L126FFB: db $FF;X
L126FFC: db $FF;X
L126FFD: db $FF;X
L126FFE: db $FF;X
L126FFF: db $FF;X
; =============== END OF ALIGN JUNK ===============

; =============== ActInit_Bat ===============
; Pretty much like Act_Watch except for graphics and very minor differences.
;
; See also: ActInit_Watch
ActInit_Bat:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$0F
	ld   [sActSetColiBoxU], a
	ld   a, -$02
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Bat
	call ActS_SetCodePtr
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Bat
	call ActS_SetOBJLstSharedTablePtr
	
	; Set initial collision box (damaging side doesn't matter here)
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer6], a
	ld   [sActSetTimer7], a
	ld   [sActSetTimer], a
	ld   [sActSetTimer2], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	; Depending on the direction the actor's facing, pick a different animation
	push bc
	ld   bc, OBJLstPtrTable_Act_Bat_MoveL	; Set initial OBJLst (left facing)
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, [sActSetDir]
	bit  DIRB_L, a			; Facing left?
	ret  nz					; If so, return
	push bc
	ld   bc, OBJLstPtrTable_Act_Bat_MoveR	; Set initial OBJLst (right facing)
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_Bat ===============
Act_Bat:
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Bat_Main
	dw Act_Bat_Main;X
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartStarKill
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartDashKill
	dw Act_Bat_Main;X
	dw Act_Bat_Main
	dw SubCall_ActS_StartJumpDead
; =============== Act_Bat_Main ===============
Act_Bat_Main:
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_Bat_Idle
	dw Act_Bat_Attack
; =============== Act_Bat_Unused_SwitchToIdle ===============
; [TCRF] Unreferenced code to make the bat return to the idle animation,
;        presumably after attacking.
;        This never happens -- once the bat attacks, it will never stop moving,
;        and equivalent code doesn't exist at all in Act_Watch.
Act_Bat_Unused_SwitchToIdle: 
	xor  a
	ld   [sActBatRoutineId], a
	ld   [sActSetTimer2], a		; Not even used in this actor
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_Bat_MoveL		; Set the one when facing left first
	ld   a, [sActSetDir]
	bit  DIRB_L, a				; Facing left?
	ret  nz						; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_Bat_MoveR		; Set the one when facing right
	ret
; =============== Act_Bat_Idle ===============
Act_Bat_Idle:
	; If the player is within $48 pixels near the actor, start attacking
	ld   a, [sActSetX_Low]		; HL = Actor X
	ld   l, a
	ld   a, [sActSetX_High]
	ld   h, a
	ld   a, [sPlX_Low]			; BC = Player X
	ld   c, a
	ld   a, [sPlX_High]
	ld   b, a
	call ActS_GetPlDistance		; HL = Diff
	ld   a, l					
	cp   a, $48					; Diff >= $48?
	jr   c, .startAttack		; If so, start attacking.
	; Otherwise, animate as normal
	call ActS_IncOBJLstIdEvery8
	ret
	
.startAttack:
	ld   a, SFX1_29
	ld   [sSFX1Set], a
	ld   a, BAT_RTN_ATK
	ld   [sActLocalRoutineId], a
	mActSetYSpeed $03
	
	xor  a
	ld   [sActSetTimer], a
	
	; Set attack anim depending on the direction faced
	mActOBJLstPtrTable OBJLstPtrTable_Act_Bat_MoveL		; Set the one when facing left first
	ld   a, [sActSetDir]
	bit  DIRB_L, a				; Facing left?
	ret  nz						; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_Bat_MoveR		; Set the one when facing right
	ret
; =============== Act_Bat_Attack ===============
Act_Bat_Attack:
	call ActS_IncOBJLstIdEvery8
	
	; Handle vertical & horizontal movement
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_Bat_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_Bat_MoveLeft
	call Act_Bat_MoveVert
	ret
	
; =============== Act_Bat_MoveVert ===============
Act_Bat_MoveVert:
	; Move every other frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
.move:
	ld   a, [sActSetYSpeed_Low]	; BC = sActSetYSpeed 
	ld   c, a						
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown				; Move down by that
.decSpeed:
	; Every $10 frames decrease the drop speed
	ld   a, [sActSetTimer]
	and  a, $0F
	ret  nz
	ld   a, [sActSetYSpeed_Low]	; sActSetYSpeed--
	sub  a, $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	sbc  a, $00
	ld   [sActSetYSpeed_High], a
	ret
	
; =============== Act_Bat_MoveRight ===============
; Moves the actor right 1px.
Act_Bat_MoveRight:
	ld   a, LOW(OBJLstPtrTable_Act_Bat_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Bat_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ld   bc, +$01
	call ActS_MoveRight
	ret
; =============== Act_Bat_MoveLeft ===============
; Moves the actor left 1px.
Act_Bat_MoveLeft:;C
	ld   a, LOW(OBJLstPtrTable_Act_Bat_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Bat_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
OBJLstPtrTable_Act_Bat_MoveL:
	dw OBJLst_Act_Bat_MoveL0
	dw OBJLst_Act_Bat_MoveL1
	dw $0000
OBJLstPtrTable_Act_Bat_MoveR:
	dw OBJLst_Act_Bat_MoveR0
	dw OBJLst_Act_Bat_MoveR1
	dw $0000
; [TCRF] Two frames of animation, but same mapping frame
OBJLstPtrTable_Act_Bat_StunL:
	dw OBJLst_Act_Bat_StunL
	dw OBJLst_Act_Bat_StunL
	dw $0000
OBJLstPtrTable_Act_Bat_StunR:
	dw OBJLst_Act_Bat_StunR
	dw OBJLst_Act_Bat_StunR
	dw $0000

OBJLstSharedPtrTable_Act_Bat:
	dw OBJLstPtrTable_Act_Bat_StunL;X
	dw OBJLstPtrTable_Act_Bat_StunR;X
	dw OBJLstPtrTable_Act_Bat_StunL;X
	dw OBJLstPtrTable_Act_Bat_StunR;X
	dw OBJLstPtrTable_Act_Bat_StunL
	dw OBJLstPtrTable_Act_Bat_StunR
	dw OBJLstPtrTable_Act_Bat_StunL;X
	dw OBJLstPtrTable_Act_Bat_StunR;X
	
OBJLst_Act_Bat_MoveL0: INCBIN "data/objlst/actor/bat_movel0.bin"
OBJLst_Act_Bat_MoveL1: INCBIN "data/objlst/actor/bat_movel1.bin"
OBJLst_Act_Bat_StunL: INCBIN "data/objlst/actor/bat_stunl.bin"
OBJLst_Act_Bat_MoveR0: INCBIN "data/objlst/actor/bat_mover0.bin"
OBJLst_Act_Bat_MoveR1: INCBIN "data/objlst/actor/bat_mover1.bin"
OBJLst_Act_Bat_StunR: INCBIN "data/objlst/actor/bat_stunr.bin"
GFX_Act_Bat: INCBIN "data/gfx/actor/bat.bin"

; =============== ActInit_BigFruit ===============
ActInit_BigFruit:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$20
	ld   [sActSetColiBoxU], a
	ld   a, -$0A
	ld   [sActSetColiBoxD], a
	ld   a, -$0A
	ld   [sActSetColiBoxL], a
	ld   a, +$0A
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_BigFruit
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_BigFruit
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_BigFruit
	call ActS_SetOBJLstSharedTablePtr
	
	; Set collision type
	ld   a, ACTCOLI_BIGBLOCK
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	; Reset vars
	xor  a
	ld   [sActBigFruitMoveDelay], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActBigFruitDropTimer], a
	ld   [sActBigFruitLandTimer], a
	
	; Depending on the direction, set a different OBJLstPtrTable.
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, ActInit_BigFruit_SetOBJLstPtrTableR
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, ActInit_BigFruit_SetOBJLstPtrTableL
	xor  a
	ld   [sActSetOBJLstId], a
	ret
; =============== OBJLstPtrTable_ActInit_BigFruit ===============
OBJLstPtrTable_ActInit_BigFruit:
	dw OBJLst_Act_BigFruit0
	dw $0000
; =============== Act_BigFruit ===============
Act_BigFruit:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_BigFruit_Main
	dw Act_BigFruit_Main;X
	dw Act_BigFruit_Main;X
	dw SubCall_ActS_StartStarKill;X
	dw SubCall_ActS_OnPlColiBelow
	dw Act_BigFruit_Main;X
	dw Act_BigFruit_OnPlStand
	dw Act_BigFruit_Main
	; The collision type used (ACTCOLI_BIGBLOCK) is explicitly excluded from the thrown actor-to-actor collision
	; So this can't ever be called.
	dw Act_BigFruit_Unused_StartNoMove;X 
	
; =============== Act_BigFruit_Unused_StartNoMove ===============
; [TCRF] There's a completely unused block of code for a non-rolling fruit.
;		 This would have been used when the fruit reaches a solid wall, but
;		 the only fruit in the game ends its path on a bed of spikes.
;
;        This would have been also called when throwing something at the fruit, but see above for that.
Act_BigFruit_Unused_StartNoMove:
	; Set new code ptr
	ld   bc, SubCall_Act_BigFruit_Unused_NoMove
	call ActS_SetCodePtr
	
	; Reset OBJLst to non-rolling one
	push bc
	ld   bc, OBJLstPtrTable_ActInit_BigFruit
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Basically like the normal one, except this doesn't hard bump on the sides
	ld   a, ACTCOLI_TOPSOLIDHIT
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	ret
; =============== Act_BigFruit_Unused_NoMove ===============
; [TCRF] Loop code for a non-rolling fruit which can still be picked up.
Act_BigFruit_Unused_NoMove:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_BigFruit_Unused_NoMove_Main;X
	dw SubCall_ActS_StartHeld;X
	dw Act_BigFruit_Unused_NoMove_Main;X
	dw SubCall_ActS_StartStarKill;X
	dw Act_BigFruit_Unused_NoMove_Main;X
	dw SubCall_ActS_StartDashKill;X
	dw Act_BigFruit_Unused_NoMove_Main;X
	dw Act_BigFruit_Unused_NoMove_Main;X
	dw Act_BigFruit_Unused_NoMove_Main;X
; =============== Act_BigFruit_Unused_NoMove_Main ===============
Act_BigFruit_Unused_NoMove_Main: 
	; [POI] Poor way of resetting the anim frame.
	;		To avoid having the fruit rotate in place.
	push bc
	ld   bc, OBJLstPtrTable_ActInit_BigFruit
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	jp   Act_BigFruit_CheckDrop
;--

; =============== Act_BigFruit_OnPlStand ===============
Act_BigFruit_OnPlStand:
	; If we're standing on the fruit, make sure we move alongside it horizontally.
	;
	; Since this piggybacks off the autoscroll code, it's important this executes
	; only when the fruit is actually moving horizontally.
	ld   a, [sActSetYSpeed_Low]
	or   a									; Is the actor falling?
	jr   nz, Act_BigFruit_Main				; If so, ignore this (it can't move diagonally)
	ld   a, [sActSetDir]
	bit  DIRB_R, a							; Is it facing right?
	call nz, SubCall_ActS_PlStand_MoveRight	; If so, move the player right as well
	ld   a, [sActSetDir]
	bit  DIRB_L, a							; Is it facing left?
	call nz, SubCall_ActS_PlStand_MoveLeft	; If so, move the player left as well
; =============== Act_BigFruit_Main ===============
Act_BigFruit_Main:
	; If the actor is over a spike block, instakill it
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSpikeBlock
	or   a
	jp   nz, SubCall_ActS_StartStarKill
	
	ld   a, [sActSetTimer]				; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; When the actor spawns, it first waits for $23 frames.
	; After that, it automatically drops down with a screen shake effect.
	ld   a, [sActBigFruitDropTimer]
	cp   a, $23							; Is the delay over yet?
	jr   nc, .chkTimer2					; If so, jump
	inc  a								; DropTimer++
	ld   [sActBigFruitDropTimer], a
	ret
.chkTimer2:
	; If the secondary timer is set, wait for that too before continuing
	ld   a, [sActBigFruitMoveDelay]
	or   a								; Is the delay over yet?
	jr   z, .move						; If so, jump
	dec  a								; DropTimer2--
	ld   [sActBigFruitMoveDelay], a
	ret
.move:
	; The actor should not animate until it lands for the first time.
	; After that, it will do the rolling anim even in the air.
	; Horizontal movement, however, should only happen on solid ground.
	
	call Act_BigFruit_CheckDrop
	ld   a, [sActBigFruitLandTimer]
	or   a								; Has the actor landed once yet?
	ret  z								; If not, return
	
	call ActS_IncOBJLstIdEvery8			; Animate the fruit when rolling on the ground
	
	ld   a, [sActSetYSpeed_Low]
	or   a								; Is the actor in the air?
	ret  nz								; If so, don't move horizontally
	
	ld   a, [sActSetDir]
	bit  DIRB_R, a						; Is the fruit facing right?
	call nz, Act_BigFruit_MoveRight		; If so, move right
	
	ld   a, [sActSetDir]
	bit  DIRB_L, a						; Is the fruit facing left?
	call nz, Act_BigFruit_MoveLeft		; If so, move left
	
	ret
	
; =============== Act_BigFruit_MoveLeft ===============
; Moves the BigFruit actor to the left.
Act_BigFruit_MoveLeft:
	; [TCRF] If there's a solid block on the left, stop movement
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolid
	or   a
	jr   nz, Act_BigFruit_Unused_EndPath
	; Otherwise move left at 1px/frame
	ld   bc, -$01
	call ActS_MoveRight
	
; =============== ActInit_BigFruit_SetOBJLstPtrTableL ===============
; Sets the initial OBJLstPtrTable when the actor is facing left.
ActInit_BigFruit_SetOBJLstPtrTableL:
	ld   a, LOW(OBJLstPtrTable_Act_BigFruitL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_BigFruitL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
; =============== Act_BigFruit_MoveRight ===============
Act_BigFruit_MoveRight:
	; [TCRF] If there's a solid block on the right, stop movement
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a
	jr   nz, Act_BigFruit_Unused_EndPath
	; Otherwise move right at 1px/frame
	ld   bc, +$01
	call ActS_MoveRight
	
; =============== ActInit_BigFruit_SetOBJLstPtrTableR ===============
; Sets the initial OBJLstPtrTable when the actor is facing right.
ActInit_BigFruit_SetOBJLstPtrTableR:
	ld   a, LOW(OBJLstPtrTable_Act_BigFruitR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_BigFruitR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
; =============== Act_BigFruit_Unused_EndPath ===============
; [TCRF] This subroutine handles what happens when the big fruit reaches a solid wall.
;        The only fruit in the game isn't placed in an area which allows this to happen.
Act_BigFruit_Unused_EndPath:
	jp   Act_BigFruit_Unused_StartNoMove

; =============== Act_BigFruit_CheckDrop ===============
; Handles the vertical drop of the actor when it isn't standing on solid ground.
Act_BigFruit_CheckDrop:
	;--
	;
	; Detect if the actor is standing on a solid block.
	; Because this actor has a big collision box, we need to check two targets at ground level (low-left and low-right corners)
	;
	
	; This subroutine nets us:
	; -  B: Block ID on the left
	; -  C: Block ID on the right
	; If any of these two blocks is solid, the actor is treated as standing on a solid block.
	call ActColi_GetBlockId_GroundHorz		
	
	; D = Left block is solid
	ld   a, b							; A = Block ID on the left
	push bc
	mSubCall ActBGColi_IsSolidOnTop		; The block id
	pop  bc
	ld   d, a
	
	; A = Right block is solid
	ld   a, c							; A = Block ID on the right
	push de
	mSubCall ActBGColi_IsSolidOnTop
	pop  de
	
	or   a, d							; Was any of these blocks marked as solid?
	jr   nz, .landed					; If so, jump
	;--
	
	; Otherwise, we're in the air and should fall down.
	
	;--
	; If the actor is underwater, drop at a fixed 1px/frame speed
	; [TCRF] Big fruits are never near water.
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a
	jr   z, .unused_water
	;--
.ground:	
	;--
	; Perform the standard drop.
	
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed_Low
	ld   c, a
	ld   b, $00
	call ActS_MoveDown					; Move down by that
	; Every 4 frames, increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, [sActSetYSpeed_Low]
	inc  a
	ld   [sActSetYSpeed_Low], a
	;--
	ret
.unused_water: 
	ld   a, $01
	ld   [sActSetYSpeed_Low], a		; sActSetYSpeed_Low = 1
	ld   bc, +$01
	call ActS_MoveDown					; Move down by that
	ret
.landed:
	; [POI] This uses of a timer (instead of a flag) for some reason
	ld   a, [sActBigFruitLandTimer]
	inc  a
	ld   [sActBigFruitLandTimer], a
	
	; If the actor was on the ground or its drop speed was < 5px/frame, don't shake the screen.
	ld   a, [sActSetYSpeed_Low]
	or   a								; Was the actor on the ground?
	jr   z, .noShake						; If so, jump
	cp   a, $05							; Is it slower than 5px/frame 
	jr   c, .noShake						; If so, jump
	
.shake:
	mSetScreenShakeFor8
	
	; If we're holding something other than a key, make us drop it.
	ld   a, [sActHeldKey]
	or   a						; Holding a key?
	jr   nz, .setSFX			; If so, skip
	ld   a, [sPlAction]
	cp   a, PL_ACT_JUMP			; Are we jumping?
	jr   z, .setSFX				; If so, skip
	xor  a						; Drop what we're holding
	ld   [sActHeld], a
.setSFX:
	ld   a, SFX4_02	; Set SFX
	ld   [sSFX4Set], a
	ld   a, $10					; Delay movement for $10 frames
	ld   [sActBigFruitMoveDelay], a
	ld   a, [sActSetY_Low]		; Align actor to block Y boundary
	and  a, $F0
	ld   [sActSetY_Low], a
	; [BUG] Where does this come from? Aligning to the Y boundary is enough.
	ld   bc, -$05				
	call ActS_MoveDown
.noShake:
	; Reset the drop speed
	xor  a
	ld   [sActSetYSpeed_Low], a
	ret
	
OBJLstPtrTable_Act_BigFruitL:
	dw OBJLst_Act_BigFruit0
	dw OBJLst_Act_BigFruit1
	dw OBJLst_Act_BigFruit2
	dw OBJLst_Act_BigFruit3
	dw $0000
	
OBJLstPtrTable_Act_BigFruitR:
	dw OBJLst_Act_BigFruit3
	dw OBJLst_Act_BigFruit2
	dw OBJLst_Act_BigFruit1
	dw OBJLst_Act_BigFruit0
	dw $0000

OBJLstSharedPtrTable_Act_BigFruit:
	dw OBJLstPtrTable_ActInit_BigFruit;X
	dw OBJLstPtrTable_ActInit_BigFruit;X
	dw OBJLstPtrTable_ActInit_BigFruit;X
	dw OBJLstPtrTable_ActInit_BigFruit;X
	dw OBJLstPtrTable_ActInit_BigFruit
	dw OBJLstPtrTable_ActInit_BigFruit
	dw OBJLstPtrTable_ActInit_BigFruit;X
	dw OBJLstPtrTable_ActInit_BigFruit;X

OBJLst_Act_BigFruit0: INCBIN "data/objlst/actor/bigfruit0.bin"
OBJLst_Act_BigFruit1: INCBIN "data/objlst/actor/bigfruit1.bin"
OBJLst_Act_BigFruit2: INCBIN "data/objlst/actor/bigfruit2.bin"
OBJLst_Act_BigFruit3: INCBIN "data/objlst/actor/bigfruit3.bin"
GFX_Act_BigFruit: INCBIN "data/gfx/actor/bigfruit.bin"

; =============== END OF BANK ===============
L1276D5: db $00;X
L1276D6: db $00;X
L1276D7: db $00;X
L1276D8: db $00;X
L1276D9: db $00;X
L1276DA: db $00;X
L1276DB: db $00;X
L1276DC: db $04;X
L1276DD: db $00;X
L1276DE: db $00;X
L1276DF: db $00;X
L1276E0: db $00;X
L1276E1: db $00;X
L1276E2: db $00;X
L1276E3: db $10;X
L1276E4: db $00;X
L1276E5: db $00;X
L1276E6: db $00;X
L1276E7: db $10;X
L1276E8: db $01;X
L1276E9: db $00;X
L1276EA: db $00;X
L1276EB: db $00;X
L1276EC: db $00;X
L1276ED: db $00;X
L1276EE: db $00;X
L1276EF: db $00;X
L1276F0: db $10;X
L1276F1: db $00;X
L1276F2: db $08;X
L1276F3: db $00;X
L1276F4: db $00;X
L1276F5: db $00;X
L1276F6: db $00;X
L1276F7: db $00;X
L1276F8: db $00;X
L1276F9: db $80;X
L1276FA: db $00;X
L1276FB: db $00;X
L1276FC: db $00;X
L1276FD: db $00;X
L1276FE: db $02;X
L1276FF: db $00;X
L127700: db $FF;X
L127701: db $FF;X
L127702: db $FF;X
L127703: db $FF;X
L127704: db $FF;X
L127705: db $F7;X
L127706: db $FF;X
L127707: db $FE;X
L127708: db $EB;X
L127709: db $FF;X
L12770A: db $FF;X
L12770B: db $DF;X
L12770C: db $FF;X
L12770D: db $EF;X
L12770E: db $F7;X
L12770F: db $DF;X
L127710: db $FF;X
L127711: db $FF;X
L127712: db $FF;X
L127713: db $FF;X
L127714: db $FF;X
L127715: db $DF;X
L127716: db $FF;X
L127717: db $FF;X
L127718: db $FF;X
L127719: db $EF;X
L12771A: db $FF;X
L12771B: db $7F;X
L12771C: db $FF;X
L12771D: db $FF;X
L12771E: db $FD;X
L12771F: db $FD;X
L127720: db $FF;X
L127721: db $FF;X
L127722: db $FF;X
L127723: db $FF;X
L127724: db $FF;X
L127725: db $FF;X
L127726: db $FF;X
L127727: db $FF;X
L127728: db $DF;X
L127729: db $FF;X
L12772A: db $FF;X
L12772B: db $FF;X
L12772C: db $FF;X
L12772D: db $BF;X
L12772E: db $EE;X
L12772F: db $FF;X
L127730: db $FF;X
L127731: db $FF;X
L127732: db $FF;X
L127733: db $FF;X
L127734: db $FF;X
L127735: db $FF;X
L127736: db $F7;X
L127737: db $FF;X
L127738: db $FF;X
L127739: db $FB;X
L12773A: db $F7;X
L12773B: db $FF;X
L12773C: db $DF;X
L12773D: db $EF;X
L12773E: db $FF;X
L12773F: db $FF;X
L127740: db $F7;X
L127741: db $FF;X
L127742: db $FF;X
L127743: db $FF;X
L127744: db $FE;X
L127745: db $F7;X
L127746: db $FF;X
L127747: db $DF;X
L127748: db $FF;X
L127749: db $FF;X
L12774A: db $FF;X
L12774B: db $BD;X
L12774C: db $FF;X
L12774D: db $FF;X
L12774E: db $BF;X
L12774F: db $FF;X
L127750: db $FF;X
L127751: db $DF;X
L127752: db $FF;X
L127753: db $FF;X
L127754: db $FF;X
L127755: db $FF;X
L127756: db $FF;X
L127757: db $FF;X
L127758: db $FF;X
L127759: db $FF;X
L12775A: db $FF;X
L12775B: db $FF;X
L12775C: db $FF;X
L12775D: db $FF;X
L12775E: db $FF;X
L12775F: db $3F;X
L127760: db $FF;X
L127761: db $6F;X
L127762: db $FF;X
L127763: db $FF;X
L127764: db $FF;X
L127765: db $FF;X
L127766: db $FF;X
L127767: db $FF;X
L127768: db $FF;X
L127769: db $FF;X
L12776A: db $7F;X
L12776B: db $FF;X
L12776C: db $DF;X
L12776D: db $FF;X
L12776E: db $FF;X
L12776F: db $FB;X
L127770: db $FF;X
L127771: db $EF;X
L127772: db $FB;X
L127773: db $FF;X
L127774: db $FF;X
L127775: db $9F;X
L127776: db $F7;X
L127777: db $7F;X
L127778: db $FF;X
L127779: db $DF;X
L12777A: db $FF;X
L12777B: db $FF;X
L12777C: db $FF;X
L12777D: db $FF;X
L12777E: db $FF;X
L12777F: db $FF;X
L127780: db $00;X
L127781: db $00;X
L127782: db $00;X
L127783: db $08;X
L127784: db $00;X
L127785: db $00;X
L127786: db $00;X
L127787: db $00;X
L127788: db $00;X
L127789: db $00;X
L12778A: db $02;X
L12778B: db $00;X
L12778C: db $00;X
L12778D: db $00;X
L12778E: db $08;X
L12778F: db $00;X
L127790: db $00;X
L127791: db $00;X
L127792: db $80;X
L127793: db $00;X
L127794: db $04;X
L127795: db $00;X
L127796: db $00;X
L127797: db $02;X
L127798: db $00;X
L127799: db $00;X
L12779A: db $00;X
L12779B: db $00;X
L12779C: db $00;X
L12779D: db $00;X
L12779E: db $00;X
L12779F: db $01;X
L1277A0: db $00;X
L1277A1: db $05;X
L1277A2: db $00;X
L1277A3: db $C0;X
L1277A4: db $08;X
L1277A5: db $00;X
L1277A6: db $00;X
L1277A7: db $00;X
L1277A8: db $10;X
L1277A9: db $00;X
L1277AA: db $80;X
L1277AB: db $02;X
L1277AC: db $00;X
L1277AD: db $01;X
L1277AE: db $00;X
L1277AF: db $00;X
L1277B0: db $48;X
L1277B1: db $00;X
L1277B2: db $00;X
L1277B3: db $20;X
L1277B4: db $00;X
L1277B5: db $00;X
L1277B6: db $18;X
L1277B7: db $00;X
L1277B8: db $00;X
L1277B9: db $00;X
L1277BA: db $20;X
L1277BB: db $00;X
L1277BC: db $40;X
L1277BD: db $00;X
L1277BE: db $00;X
L1277BF: db $01;X
L1277C0: db $00;X
L1277C1: db $00;X
L1277C2: db $00;X
L1277C3: db $11;X
L1277C4: db $20;X
L1277C5: db $20;X
L1277C6: db $04;X
L1277C7: db $00;X
L1277C8: db $00;X
L1277C9: db $40;X
L1277CA: db $00;X
L1277CB: db $10;X
L1277CC: db $41;X
L1277CD: db $01;X
L1277CE: db $08;X
L1277CF: db $00;X
L1277D0: db $0A;X
L1277D1: db $00;X
L1277D2: db $00;X
L1277D3: db $00;X
L1277D4: db $00;X
L1277D5: db $00;X
L1277D6: db $00;X
L1277D7: db $08;X
L1277D8: db $00;X
L1277D9: db $00;X
L1277DA: db $00;X
L1277DB: db $00;X
L1277DC: db $00;X
L1277DD: db $00;X
L1277DE: db $00;X
L1277DF: db $02;X
L1277E0: db $00;X
L1277E1: db $00;X
L1277E2: db $00;X
L1277E3: db $20;X
L1277E4: db $00;X
L1277E5: db $08;X
L1277E6: db $10;X
L1277E7: db $00;X
L1277E8: db $10;X
L1277E9: db $00;X
L1277EA: db $00;X
L1277EB: db $80;X
L1277EC: db $00;X
L1277ED: db $10;X
L1277EE: db $02;X
L1277EF: db $00;X
L1277F0: db $01;X
L1277F1: db $40;X
L1277F2: db $00;X
L1277F3: db $00;X
L1277F4: db $00;X
L1277F5: db $00;X
L1277F6: db $00;X
L1277F7: db $00;X
L1277F8: db $10;X
L1277F9: db $00;X
L1277FA: db $00;X
L1277FB: db $1C;X
L1277FC: db $00;X
L1277FD: db $00;X
L1277FE: db $00;X
L1277FF: db $00;X
L127800: db $BF;X
L127801: db $FF;X
L127802: db $E7;X
L127803: db $77;X
L127804: db $FF;X
L127805: db $FF;X
L127806: db $FD;X
L127807: db $67;X
L127808: db $FD;X
L127809: db $FF;X
L12780A: db $FE;X
L12780B: db $7F;X
L12780C: db $FF;X
L12780D: db $FF;X
L12780E: db $FF;X
L12780F: db $F7;X
L127810: db $FF;X
L127811: db $FB;X
L127812: db $EF;X
L127813: db $7F;X
L127814: db $FA;X
L127815: db $FB;X
L127816: db $FF;X
L127817: db $FF;X
L127818: db $FF;X
L127819: db $FD;X
L12781A: db $E9;X
L12781B: db $7D;X
L12781C: db $FF;X
L12781D: db $FE;X
L12781E: db $FF;X
L12781F: db $FE;X
L127820: db $FF;X
L127821: db $FF;X
L127822: db $77;X
L127823: db $F7;X
L127824: db $FE;X
L127825: db $FF;X
L127826: db $FF;X
L127827: db $FF;X
L127828: db $F6;X
L127829: db $FD;X
L12782A: db $FF;X
L12782B: db $FF;X
L12782C: db $FE;X
L12782D: db $F7;X
L12782E: db $FF;X
L12782F: db $FD;X
L127830: db $FD;X
L127831: db $FF;X
L127832: db $FF;X
L127833: db $FE;X
L127834: db $F7;X
L127835: db $FF;X
L127836: db $72;X
L127837: db $7D;X
L127838: db $FF;X
L127839: db $FB;X
L12783A: db $F6;X
L12783B: db $FF;X
L12783C: db $FD;X
L12783D: db $F9;X
L12783E: db $F7;X
L12783F: db $FF;X
L127840: db $DE;X
L127841: db $FB;X
L127842: db $F6;X
L127843: db $FF;X
L127844: db $FF;X
L127845: db $FF;X
L127846: db $FF;X
L127847: db $DB;X
L127848: db $FF;X
L127849: db $FF;X
L12784A: db $F7;X
L12784B: db $FF;X
L12784C: db $FF;X
L12784D: db $FF;X
L12784E: db $FE;X
L12784F: db $FD;X
L127850: db $FF;X
L127851: db $DF;X
L127852: db $FD;X
L127853: db $FA;X
L127854: db $FC;X
L127855: db $FF;X
L127856: db $FF;X
L127857: db $FF;X
L127858: db $DF;X
L127859: db $FF;X
L12785A: db $FF;X
L12785B: db $FF;X
L12785C: db $DF;X
L12785D: db $FF;X
L12785E: db $FF;X
L12785F: db $EF;X
L127860: db $FF;X
L127861: db $BF;X
L127862: db $FF;X
L127863: db $77;X
L127864: db $FF;X
L127865: db $FF;X
L127866: db $FF;X
L127867: db $7F;X
L127868: db $DF;X
L127869: db $FB;X
L12786A: db $FB;X
L12786B: db $FA;X
L12786C: db $FB;X
L12786D: db $F7;X
L12786E: db $DF;X
L12786F: db $FF;X
L127870: db $FF;X
L127871: db $FB;X
L127872: db $EF;X
L127873: db $FF;X
L127874: db $FF;X
L127875: db $FF;X
L127876: db $FF;X
L127877: db $BF;X
L127878: db $FF;X
L127879: db $FF;X
L12787A: db $FF;X
L12787B: db $FF;X
L12787C: db $FB;X
L12787D: db $EF;X
L12787E: db $33;X
L12787F: db $FF;X
L127880: db $00;X
L127881: db $00;X
L127882: db $00;X
L127883: db $00;X
L127884: db $00;X
L127885: db $00;X
L127886: db $00;X
L127887: db $00;X
L127888: db $00;X
L127889: db $00;X
L12788A: db $00;X
L12788B: db $08;X
L12788C: db $00;X
L12788D: db $00;X
L12788E: db $00;X
L12788F: db $00;X
L127890: db $00;X
L127891: db $00;X
L127892: db $00;X
L127893: db $00;X
L127894: db $00;X
L127895: db $00;X
L127896: db $00;X
L127897: db $00;X
L127898: db $00;X
L127899: db $00;X
L12789A: db $00;X
L12789B: db $00;X
L12789C: db $00;X
L12789D: db $00;X
L12789E: db $00;X
L12789F: db $00;X
L1278A0: db $00;X
L1278A1: db $00;X
L1278A2: db $00;X
L1278A3: db $00;X
L1278A4: db $00;X
L1278A5: db $00;X
L1278A6: db $00;X
L1278A7: db $00;X
L1278A8: db $01;X
L1278A9: db $00;X
L1278AA: db $40;X
L1278AB: db $04;X
L1278AC: db $00;X
L1278AD: db $00;X
L1278AE: db $00;X
L1278AF: db $00;X
L1278B0: db $00;X
L1278B1: db $00;X
L1278B2: db $00;X
L1278B3: db $10;X
L1278B4: db $00;X
L1278B5: db $80;X
L1278B6: db $00;X
L1278B7: db $00;X
L1278B8: db $00;X
L1278B9: db $00;X
L1278BA: db $00;X
L1278BB: db $00;X
L1278BC: db $00;X
L1278BD: db $00;X
L1278BE: db $00;X
L1278BF: db $00;X
L1278C0: db $00;X
L1278C1: db $00;X
L1278C2: db $00;X
L1278C3: db $00;X
L1278C4: db $00;X
L1278C5: db $00;X
L1278C6: db $00;X
L1278C7: db $00;X
L1278C8: db $00;X
L1278C9: db $00;X
L1278CA: db $00;X
L1278CB: db $80;X
L1278CC: db $00;X
L1278CD: db $00;X
L1278CE: db $00;X
L1278CF: db $00;X
L1278D0: db $00;X
L1278D1: db $00;X
L1278D2: db $02;X
L1278D3: db $02;X
L1278D4: db $00;X
L1278D5: db $00;X
L1278D6: db $00;X
L1278D7: db $20;X
L1278D8: db $00;X
L1278D9: db $10;X
L1278DA: db $00;X
L1278DB: db $40;X
L1278DC: db $00;X
L1278DD: db $00;X
L1278DE: db $00;X
L1278DF: db $08;X
L1278E0: db $00;X
L1278E1: db $00;X
L1278E2: db $00;X
L1278E3: db $20;X
L1278E4: db $08;X
L1278E5: db $01;X
L1278E6: db $02;X
L1278E7: db $00;X
L1278E8: db $08;X
L1278E9: db $00;X
L1278EA: db $00;X
L1278EB: db $80;X
L1278EC: db $00;X
L1278ED: db $00;X
L1278EE: db $8C;X
L1278EF: db $00;X
L1278F0: db $01;X
L1278F1: db $00;X
L1278F2: db $00;X
L1278F3: db $00;X
L1278F4: db $00;X
L1278F5: db $00;X
L1278F6: db $02;X
L1278F7: db $00;X
L1278F8: db $00;X
L1278F9: db $00;X
L1278FA: db $00;X
L1278FB: db $00;X
L1278FC: db $00;X
L1278FD: db $00;X
L1278FE: db $00;X
L1278FF: db $00;X
L127900: db $FF;X
L127901: db $FF;X
L127902: db $FF;X
L127903: db $FF;X
L127904: db $BF;X
L127905: db $FF;X
L127906: db $E5;X
L127907: db $EF;X
L127908: db $BE;X
L127909: db $EF;X
L12790A: db $F7;X
L12790B: db $FF;X
L12790C: db $FF;X
L12790D: db $FF;X
L12790E: db $FD;X
L12790F: db $7F;X
L127910: db $BE;X
L127911: db $FE;X
L127912: db $BF;X
L127913: db $FF;X
L127914: db $FF;X
L127915: db $FF;X
L127916: db $FF;X
L127917: db $FF;X
L127918: db $EE;X
L127919: db $FF;X
L12791A: db $FF;X
L12791B: db $7F;X
L12791C: db $FB;X
L12791D: db $FF;X
L12791E: db $FF;X
L12791F: db $FF;X
L127920: db $FF;X
L127921: db $F7;X
L127922: db $7F;X
L127923: db $BF;X
L127924: db $FF;X
L127925: db $F9;X
L127926: db $DF;X
L127927: db $FE;X
L127928: db $F6;X
L127929: db $F7;X
L12792A: db $EF;X
L12792B: db $FF;X
L12792C: db $FF;X
L12792D: db $FF;X
L12792E: db $EF;X
L12792F: db $BF;X
L127930: db $FF;X
L127931: db $FF;X
L127932: db $F3;X
L127933: db $FF;X
L127934: db $EB;X
L127935: db $FE;X
L127936: db $FE;X
L127937: db $7B;X
L127938: db $F7;X
L127939: db $FF;X
L12793A: db $BF;X
L12793B: db $FF;X
L12793C: db $BF;X
L12793D: db $F7;X
L12793E: db $FF;X
L12793F: db $FD;X
L127940: db $7F;X
L127941: db $FD;X
L127942: db $F5;X
L127943: db $7F;X
L127944: db $FF;X
L127945: db $D5;X
L127946: db $BF;X
L127947: db $6D;X
L127948: db $FF;X
L127949: db $DF;X
L12794A: db $FF;X
L12794B: db $1C;X
L12794C: db $F7;X
L12794D: db $FD;X
L12794E: db $FF;X
L12794F: db $FF;X
L127950: db $FD;X
L127951: db $FF;X
L127952: db $FF;X
L127953: db $FA;X
L127954: db $FB;X
L127955: db $7F;X
L127956: db $BF;X
L127957: db $FF;X
L127958: db $7F;X
L127959: db $FF;X
L12795A: db $FB;X
L12795B: db $FF;X
L12795C: db $FF;X
L12795D: db $FF;X
L12795E: db $FF;X
L12795F: db $FF;X
L127960: db $FB;X
L127961: db $FB;X
L127962: db $EB;X
L127963: db $FB;X
L127964: db $7E;X
L127965: db $FB;X
L127966: db $7B;X
L127967: db $6B;X
L127968: db $FF;X
L127969: db $FF;X
L12796A: db $DF;X
L12796B: db $FF;X
L12796C: db $F9;X
L12796D: db $BF;X
L12796E: db $E7;X
L12796F: db $FA;X
L127970: db $BF;X
L127971: db $F7;X
L127972: db $FF;X
L127973: db $FB;X
L127974: db $FF;X
L127975: db $D7;X
L127976: db $7D;X
L127977: db $AF;X
L127978: db $FE;X
L127979: db $FF;X
L12797A: db $FE;X
L12797B: db $FE;X
L12797C: db $FB;X
L12797D: db $7B;X
L12797E: db $FF;X
L12797F: db $FF;X
L127980: db $00;X
L127981: db $00;X
L127982: db $00;X
L127983: db $00;X
L127984: db $00;X
L127985: db $00;X
L127986: db $80;X
L127987: db $00;X
L127988: db $00;X
L127989: db $00;X
L12798A: db $10;X
L12798B: db $00;X
L12798C: db $00;X
L12798D: db $00;X
L12798E: db $00;X
L12798F: db $01;X
L127990: db $01;X
L127991: db $41;X
L127992: db $40;X
L127993: db $00;X
L127994: db $00;X
L127995: db $00;X
L127996: db $00;X
L127997: db $00;X
L127998: db $01;X
L127999: db $00;X
L12799A: db $00;X
L12799B: db $00;X
L12799C: db $00;X
L12799D: db $00;X
L12799E: db $10;X
L12799F: db $02;X
L1279A0: db $00;X
L1279A1: db $00;X
L1279A2: db $00;X
L1279A3: db $00;X
L1279A4: db $00;X
L1279A5: db $00;X
L1279A6: db $00;X
L1279A7: db $30;X
L1279A8: db $00;X
L1279A9: db $00;X
L1279AA: db $40;X
L1279AB: db $00;X
L1279AC: db $00;X
L1279AD: db $00;X
L1279AE: db $00;X
L1279AF: db $00;X
L1279B0: db $10;X
L1279B1: db $00;X
L1279B2: db $80;X
L1279B3: db $00;X
L1279B4: db $00;X
L1279B5: db $05;X
L1279B6: db $00;X
L1279B7: db $00;X
L1279B8: db $00;X
L1279B9: db $00;X
L1279BA: db $00;X
L1279BB: db $00;X
L1279BC: db $00;X
L1279BD: db $00;X
L1279BE: db $00;X
L1279BF: db $00;X
L1279C0: db $00;X
L1279C1: db $00;X
L1279C2: db $04;X
L1279C3: db $01;X
L1279C4: db $00;X
L1279C5: db $00;X
L1279C6: db $00;X
L1279C7: db $08;X
L1279C8: db $00;X
L1279C9: db $00;X
L1279CA: db $00;X
L1279CB: db $04;X
L1279CC: db $00;X
L1279CD: db $00;X
L1279CE: db $00;X
L1279CF: db $00;X
L1279D0: db $00;X
L1279D1: db $00;X
L1279D2: db $00;X
L1279D3: db $00;X
L1279D4: db $00;X
L1279D5: db $02;X
L1279D6: db $00;X
L1279D7: db $00;X
L1279D8: db $82;X
L1279D9: db $00;X
L1279DA: db $00;X
L1279DB: db $00;X
L1279DC: db $44;X
L1279DD: db $00;X
L1279DE: db $00;X
L1279DF: db $00;X
L1279E0: db $00;X
L1279E1: db $00;X
L1279E2: db $00;X
L1279E3: db $00;X
L1279E4: db $00;X
L1279E5: db $00;X
L1279E6: db $00;X
L1279E7: db $08;X
L1279E8: db $20;X
L1279E9: db $00;X
L1279EA: db $00;X
L1279EB: db $00;X
L1279EC: db $00;X
L1279ED: db $40;X
L1279EE: db $00;X
L1279EF: db $40;X
L1279F0: db $00;X
L1279F1: db $02;X
L1279F2: db $00;X
L1279F3: db $00;X
L1279F4: db $00;X
L1279F5: db $00;X
L1279F6: db $00;X
L1279F7: db $00;X
L1279F8: db $00;X
L1279F9: db $00;X
L1279FA: db $00;X
L1279FB: db $00;X
L1279FC: db $00;X
L1279FD: db $00;X
L1279FE: db $00;X
L1279FF: db $40;X
L127A00: db $FF;X
L127A01: db $7D;X
L127A02: db $E9;X
L127A03: db $FF;X
L127A04: db $EF;X
L127A05: db $FF;X
L127A06: db $FD;X
L127A07: db $FF;X
L127A08: db $FF;X
L127A09: db $FD;X
L127A0A: db $FF;X
L127A0B: db $FF;X
L127A0C: db $FE;X
L127A0D: db $FB;X
L127A0E: db $FE;X
L127A0F: db $DF;X
L127A10: db $FF;X
L127A11: db $7F;X
L127A12: db $FF;X
L127A13: db $F7;X
L127A14: db $FF;X
L127A15: db $FF;X
L127A16: db $FF;X
L127A17: db $BF;X
L127A18: db $FF;X
L127A19: db $FF;X
L127A1A: db $FF;X
L127A1B: db $FB;X
L127A1C: db $FF;X
L127A1D: db $F7;X
L127A1E: db $FF;X
L127A1F: db $FE;X
L127A20: db $7B;X
L127A21: db $FD;X
L127A22: db $FB;X
L127A23: db $FF;X
L127A24: db $EE;X
L127A25: db $F7;X
L127A26: db $FF;X
L127A27: db $FF;X
L127A28: db $DF;X
L127A29: db $BD;X
L127A2A: db $FB;X
L127A2B: db $FE;X
L127A2C: db $7F;X
L127A2D: db $FE;X
L127A2E: db $FD;X
L127A2F: db $FF;X
L127A30: db $FD;X
L127A31: db $BF;X
L127A32: db $F7;X
L127A33: db $FD;X
L127A34: db $FF;X
L127A35: db $FF;X
L127A36: db $FD;X
L127A37: db $FB;X
L127A38: db $FD;X
L127A39: db $FE;X
L127A3A: db $FF;X
L127A3B: db $FF;X
L127A3C: db $F5;X
L127A3D: db $FF;X
L127A3E: db $FF;X
L127A3F: db $FB;X
L127A40: db $DF;X
L127A41: db $7F;X
L127A42: db $7B;X
L127A43: db $FF;X
L127A44: db $AF;X
L127A45: db $FF;X
L127A46: db $BF;X
L127A47: db $FF;X
L127A48: db $FD;X
L127A49: db $FE;X
L127A4A: db $DF;X
L127A4B: db $BE;X
L127A4C: db $FF;X
L127A4D: db $FF;X
L127A4E: db $FF;X
L127A4F: db $FF;X
L127A50: db $F7;X
L127A51: db $FF;X
L127A52: db $EF;X
L127A53: db $FD;X
L127A54: db $DE;X
L127A55: db $FD;X
L127A56: db $FF;X
L127A57: db $69;X
L127A58: db $FE;X
L127A59: db $FF;X
L127A5A: db $EF;X
L127A5B: db $FF;X
L127A5C: db $FC;X
L127A5D: db $CF;X
L127A5E: db $FF;X
L127A5F: db $BF;X
L127A60: db $FE;X
L127A61: db $FF;X
L127A62: db $FE;X
L127A63: db $BF;X
L127A64: db $F7;X
L127A65: db $FF;X
L127A66: db $FF;X
L127A67: db $DF;X
L127A68: db $7D;X
L127A69: db $C7;X
L127A6A: db $FF;X
L127A6B: db $FF;X
L127A6C: db $FE;X
L127A6D: db $DD;X
L127A6E: db $FB;X
L127A6F: db $BF;X
L127A70: db $FE;X
L127A71: db $F7;X
L127A72: db $F9;X
L127A73: db $DF;X
L127A74: db $DF;X
L127A75: db $7B;X
L127A76: db $FF;X
L127A77: db $FF;X
L127A78: db $EF;X
L127A79: db $BB;X
L127A7A: db $9E;X
L127A7B: db $FF;X
L127A7C: db $9D;X
L127A7D: db $FF;X
L127A7E: db $FF;X
L127A7F: db $DF;X
L127A80: db $00;X
L127A81: db $00;X
L127A82: db $00;X
L127A83: db $00;X
L127A84: db $00;X
L127A85: db $00;X
L127A86: db $00;X
L127A87: db $00;X
L127A88: db $00;X
L127A89: db $0A;X
L127A8A: db $00;X
L127A8B: db $00;X
L127A8C: db $40;X
L127A8D: db $00;X
L127A8E: db $80;X
L127A8F: db $04;X
L127A90: db $08;X
L127A91: db $00;X
L127A92: db $00;X
L127A93: db $00;X
L127A94: db $00;X
L127A95: db $00;X
L127A96: db $00;X
L127A97: db $00;X
L127A98: db $00;X
L127A99: db $00;X
L127A9A: db $00;X
L127A9B: db $00;X
L127A9C: db $02;X
L127A9D: db $50;X
L127A9E: db $00;X
L127A9F: db $00;X
L127AA0: db $00;X
L127AA1: db $02;X
L127AA2: db $41;X
L127AA3: db $00;X
L127AA4: db $00;X
L127AA5: db $00;X
L127AA6: db $00;X
L127AA7: db $00;X
L127AA8: db $00;X
L127AA9: db $00;X
L127AAA: db $80;X
L127AAB: db $00;X
L127AAC: db $20;X
L127AAD: db $00;X
L127AAE: db $00;X
L127AAF: db $08;X
L127AB0: db $80;X
L127AB1: db $00;X
L127AB2: db $00;X
L127AB3: db $00;X
L127AB4: db $00;X
L127AB5: db $00;X
L127AB6: db $00;X
L127AB7: db $00;X
L127AB8: db $00;X
L127AB9: db $00;X
L127ABA: db $00;X
L127ABB: db $00;X
L127ABC: db $00;X
L127ABD: db $00;X
L127ABE: db $04;X
L127ABF: db $00;X
L127AC0: db $00;X
L127AC1: db $00;X
L127AC2: db $00;X
L127AC3: db $00;X
L127AC4: db $00;X
L127AC5: db $00;X
L127AC6: db $00;X
L127AC7: db $00;X
L127AC8: db $00;X
L127AC9: db $00;X
L127ACA: db $00;X
L127ACB: db $00;X
L127ACC: db $40;X
L127ACD: db $00;X
L127ACE: db $00;X
L127ACF: db $00;X
L127AD0: db $10;X
L127AD1: db $10;X
L127AD2: db $C0;X
L127AD3: db $00;X
L127AD4: db $00;X
L127AD5: db $00;X
L127AD6: db $00;X
L127AD7: db $00;X
L127AD8: db $00;X
L127AD9: db $21;X
L127ADA: db $00;X
L127ADB: db $00;X
L127adc: db $00;X
L127add: db $04;X
L127ADE: db $00;X
L127ADF: db $00;X
L127AE0: db $00;X
L127AE1: db $00;X
L127AE2: db $04;X
L127AE3: db $00;X
L127AE4: db $00;X
L127AE5: db $00;X
L127AE6: db $00;X
L127AE7: db $00;X
L127AE8: db $00;X
L127AE9: db $00;X
L127AEA: db $00;X
L127AEB: db $00;X
L127AEC: db $00;X
L127AED: db $00;X
L127AEE: db $00;X
L127AEF: db $00;X
L127AF0: db $00;X
L127AF1: db $00;X
L127AF2: db $10;X
L127AF3: db $04;X
L127AF4: db $00;X
L127AF5: db $00;X
L127AF6: db $40;X
L127AF7: db $00;X
L127AF8: db $00;X
L127AF9: db $00;X
L127AFA: db $00;X
L127AFB: db $20;X
L127AFC: db $00;X
L127AFD: db $00;X
L127AFE: db $00;X
L127AFF: db $00;X
L127B00: db $FE;X
L127B01: db $FF;X
L127B02: db $FE;X
L127B03: db $FF;X
L127B04: db $7F;X
L127B05: db $FD;X
L127B06: db $FE;X
L127B07: db $F7;X
L127B08: db $FF;X
L127B09: db $CF;X
L127B0A: db $EE;X
L127B0B: db $EF;X
L127B0C: db $F7;X
L127B0D: db $EB;X
L127B0E: db $EC;X
L127B0F: db $FB;X
L127B10: db $FF;X
L127B11: db $BB;X
L127B12: db $FF;X
L127B13: db $FD;X
L127B14: db $63;X
L127B15: db $FF;X
L127B16: db $FD;X
L127B17: db $BF;X
L127B18: db $FF;X
L127B19: db $BE;X
L127B1A: db $FB;X
L127B1B: db $FF;X
L127B1C: db $EA;X
L127B1D: db $F7;X
L127B1E: db $FF;X
L127B1F: db $FB;X
L127B20: db $FF;X
L127B21: db $FE;X
L127B22: db $BD;X
L127B23: db $EF;X
L127B24: db $FF;X
L127B25: db $FF;X
L127B26: db $D5;X
L127B27: db $F5;X
L127B28: db $FF;X
L127B29: db $FD;X
L127B2A: db $FF;X
L127B2B: db $FF;X
L127B2C: db $DF;X
L127B2D: db $BF;X
L127B2E: db $FD;X
L127B2F: db $F7;X
L127B30: db $F7;X
L127B31: db $FF;X
L127B32: db $EF;X
L127B33: db $BF;X
L127B34: db $FF;X
L127B35: db $FF;X
L127B36: db $FF;X
L127B37: db $DF;X
L127B38: db $BF;X
L127B39: db $DF;X
L127B3A: db $BF;X
L127B3B: db $7F;X
L127B3C: db $FF;X
L127B3D: db $FF;X
L127B3E: db $5F;X
L127B3F: db $FF;X
L127B40: db $F5;X
L127B41: db $7F;X
L127B42: db $DE;X
L127B43: db $DF;X
L127B44: db $FE;X
L127B45: db $DF;X
L127B46: db $FF;X
L127B47: db $FF;X
L127B48: db $FF;X
L127B49: db $FF;X
L127B4A: db $DF;X
L127B4B: db $7F;X
L127B4C: db $FF;X
L127B4D: db $E6;X
L127B4E: db $FE;X
L127B4F: db $F3;X
L127B50: db $FB;X
L127B51: db $EA;X
L127B52: db $F7;X
L127B53: db $FF;X
L127B54: db $FD;X
L127B55: db $EE;X
L127B56: db $F9;X
L127B57: db $FF;X
L127B58: db $F6;X
L127B59: db $DB;X
L127B5A: db $FF;X
L127B5B: db $6F;X
L127B5C: db $EF;X
L127B5D: db $FD;X
L127B5E: db $FE;X
L127B5F: db $7B;X
L127B60: db $FF;X
L127B61: db $FF;X
L127B62: db $F9;X
L127B63: db $7F;X
L127B64: db $FF;X
L127B65: db $FF;X
L127B66: db $EF;X
L127B67: db $FF;X
L127B68: db $ED;X
L127B69: db $FD;X
L127B6A: db $FD;X
L127B6B: db $B7;X
L127B6C: db $FE;X
L127B6D: db $7F;X
L127B6E: db $FF;X
L127B6F: db $FE;X
L127B70: db $EF;X
L127B71: db $FC;X
L127B72: db $7F;X
L127B73: db $FE;X
L127B74: db $FE;X
L127B75: db $FF;X
L127B76: db $CF;X
L127B77: db $FE;X
L127B78: db $FF;X
L127B79: db $FE;X
L127B7A: db $FF;X
L127B7B: db $DE;X
L127B7C: db $5F;X
L127B7D: db $7B;X
L127B7E: db $FF;X
L127B7F: db $FF;X
L127B80: db $00;X
L127B81: db $80;X
L127B82: db $10;X
L127B83: db $00;X
L127B84: db $00;X
L127B85: db $00;X
L127B86: db $00;X
L127B87: db $02;X
L127B88: db $10;X
L127B89: db $00;X
L127B8A: db $C0;X
L127B8B: db $00;X
L127B8C: db $00;X
L127B8D: db $00;X
L127B8E: db $00;X
L127B8F: db $10;X
L127B90: db $00;X
L127B91: db $08;X
L127B92: db $08;X
L127B93: db $00;X
L127B94: db $00;X
L127B95: db $00;X
L127B96: db $00;X
L127B97: db $00;X
L127B98: db $00;X
L127B99: db $00;X
L127B9A: db $01;X
L127B9B: db $00;X
L127B9C: db $00;X
L127B9D: db $40;X
L127B9E: db $00;X
L127B9F: db $00;X
L127BA0: db $08;X
L127BA1: db $00;X
L127BA2: db $00;X
L127BA3: db $00;X
L127BA4: db $00;X
L127BA5: db $10;X
L127BA6: db $00;X
L127BA7: db $00;X
L127BA8: db $00;X
L127BA9: db $00;X
L127BAA: db $00;X
L127BAB: db $00;X
L127BAC: db $00;X
L127BAD: db $00;X
L127BAE: db $00;X
L127BAF: db $02;X
L127BB0: db $00;X
L127BB1: db $00;X
L127BB2: db $00;X
L127BB3: db $00;X
L127BB4: db $00;X
L127BB5: db $00;X
L127BB6: db $00;X
L127BB7: db $00;X
L127BB8: db $04;X
L127BB9: db $00;X
L127BBA: db $10;X
L127BBB: db $01;X
L127BBC: db $00;X
L127BBD: db $00;X
L127BBE: db $00;X
L127BBF: db $00;X
L127BC0: db $00;X
L127BC1: db $00;X
L127BC2: db $00;X
L127BC3: db $00;X
L127BC4: db $00;X
L127BC5: db $00;X
L127BC6: db $00;X
L127BC7: db $00;X
L127BC8: db $00;X
L127BC9: db $00;X
L127BCA: db $08;X
L127BCB: db $00;X
L127BCC: db $00;X
L127BCD: db $00;X
L127BCE: db $00;X
L127BCF: db $10;X
L127BD0: db $00;X
L127BD1: db $00;X
L127BD2: db $00;X
L127BD3: db $00;X
L127BD4: db $00;X
L127BD5: db $00;X
L127BD6: db $00;X
L127BD7: db $80;X
L127BD8: db $00;X
L127BD9: db $00;X
L127BDA: db $00;X
L127BDB: db $00;X
L127BDC: db $00;X
L127BDD: db $00;X
L127BDE: db $00;X
L127BDF: db $00;X
L127BE0: db $00;X
L127BE1: db $00;X
L127BE2: db $00;X
L127BE3: db $00;X
L127BE4: db $00;X
L127BE5: db $00;X
L127BE6: db $40;X
L127BE7: db $00;X
L127BE8: db $00;X
L127BE9: db $00;X
L127BEA: db $00;X
L127BEB: db $00;X
L127BEC: db $00;X
L127BED: db $00;X
L127BEE: db $00;X
L127BEF: db $00;X
L127BF0: db $00;X
L127BF1: db $02;X
L127BF2: db $00;X
L127BF3: db $00;X
L127BF4: db $80;X
L127BF5: db $00;X
L127BF6: db $00;X
L127BF7: db $00;X
L127BF8: db $00;X
L127BF9: db $00;X
L127BFA: db $00;X
L127BFB: db $00;X
L127BFC: db $00;X
L127BFD: db $80;X
L127BFE: db $02;X
L127BFF: db $00;X
L127C00: db $FF;X
L127C01: db $FC;X
L127C02: db $DF;X
L127C03: db $FF;X
L127C04: db $FF;X
L127C05: db $FF;X
L127C06: db $FB;X
L127C07: db $FF;X
L127C08: db $7F;X
L127C09: db $FF;X
L127C0A: db $FF;X
L127C0B: db $FF;X
L127C0C: db $FE;X
L127C0D: db $FF;X
L127C0E: db $FF;X
L127C0F: db $FF;X
L127C10: db $FF;X
L127C11: db $FF;X
L127C12: db $FF;X
L127C13: db $FF;X
L127C14: db $E7;X
L127C15: db $BF;X
L127C16: db $FF;X
L127C17: db $FF;X
L127C18: db $FF;X
L127C19: db $FF;X
L127C1A: db $FF;X
L127C1B: db $FF;X
L127C1C: db $FF;X
L127C1D: db $EF;X
L127C1E: db $FF;X
L127C1F: db $FF;X
L127C20: db $FF;X
L127C21: db $FF;X
L127C22: db $FF;X
L127C23: db $F6;X
L127C24: db $FF;X
L127C25: db $7F;X
L127C26: db $FF;X
L127C27: db $FF;X
L127C28: db $FF;X
L127C29: db $F7;X
L127C2A: db $FF;X
L127C2B: db $FF;X
L127C2C: db $FF;X
L127C2D: db $EF;X
L127C2E: db $FF;X
L127C2F: db $FF;X
L127C30: db $FF;X
L127C31: db $DF;X
L127C32: db $DF;X
L127C33: db $BF;X
L127C34: db $FF;X
L127C35: db $FF;X
L127C36: db $7E;X
L127C37: db $FF;X
L127C38: db $FF;X
L127C39: db $FF;X
L127C3A: db $FF;X
L127C3B: db $EF;X
L127C3C: db $FF;X
L127C3D: db $FF;X
L127C3E: db $FF;X
L127C3F: db $FF;X
L127C40: db $EF;X
L127C41: db $FF;X
L127C42: db $FD;X
L127C43: db $FD;X
L127C44: db $FF;X
L127C45: db $FF;X
L127C46: db $FF;X
L127C47: db $7F;X
L127C48: db $BF;X
L127C49: db $FD;X
L127C4A: db $FF;X
L127C4B: db $FF;X
L127C4C: db $FF;X
L127C4D: db $FF;X
L127C4E: db $FF;X
L127C4F: db $FD;X
L127C50: db $FF;X
L127C51: db $FF;X
L127C52: db $FF;X
L127C53: db $FF;X
L127C54: db $FF;X
L127C55: db $FF;X
L127C56: db $FF;X
L127C57: db $FF;X
L127C58: db $FE;X
L127C59: db $FF;X
L127C5A: db $FF;X
L127C5B: db $FF;X
L127C5C: db $FF;X
L127C5D: db $FF;X
L127C5E: db $FF;X
L127C5F: db $FF;X
L127C60: db $FF;X
L127C61: db $FF;X
L127C62: db $FF;X
L127C63: db $FF;X
L127C64: db $FF;X
L127C65: db $FF;X
L127C66: db $FF;X
L127C67: db $FF;X
L127C68: db $FF;X
L127C69: db $FF;X
L127C6A: db $FF;X
L127C6B: db $FF;X
L127C6C: db $FF;X
L127C6D: db $FD;X
L127C6E: db $FF;X
L127C6F: db $FF;X
L127C70: db $EF;X
L127C71: db $FF;X
L127C72: db $FF;X
L127C73: db $FF;X
L127C74: db $FF;X
L127C75: db $FF;X
L127C76: db $FF;X
L127C77: db $EB;X
L127C78: db $FF;X
L127C79: db $DF;X
L127C7A: db $FF;X
L127C7B: db $FF;X
L127C7C: db $BF;X
L127C7D: db $FF;X
L127C7E: db $FF;X
L127C7F: db $FF;X
L127C80: db $00;X
L127C81: db $00;X
L127C82: db $00;X
L127C83: db $80;X
L127C84: db $00;X
L127C85: db $00;X
L127C86: db $00;X
L127C87: db $08;X
L127C88: db $00;X
L127C89: db $00;X
L127C8A: db $00;X
L127C8B: db $08;X
L127C8C: db $00;X
L127C8D: db $40;X
L127C8E: db $00;X
L127C8F: db $00;X
L127C90: db $00;X
L127C91: db $01;X
L127C92: db $00;X
L127C93: db $40;X
L127C94: db $00;X
L127C95: db $00;X
L127C96: db $00;X
L127C97: db $00;X
L127C98: db $00;X
L127C99: db $00;X
L127C9A: db $00;X
L127C9B: db $00;X
L127C9C: db $00;X
L127C9D: db $00;X
L127C9E: db $00;X
L127C9F: db $00;X
L127CA0: db $00;X
L127CA1: db $00;X
L127CA2: db $00;X
L127CA3: db $00;X
L127CA4: db $00;X
L127CA5: db $20;X
L127CA6: db $00;X
L127CA7: db $00;X
L127CA8: db $00;X
L127CA9: db $04;X
L127CAA: db $00;X
L127CAB: db $04;X
L127CAC: db $00;X
L127CAD: db $00;X
L127CAE: db $00;X
L127CAF: db $00;X
L127CB0: db $00;X
L127CB1: db $00;X
L127CB2: db $00;X
L127CB3: db $00;X
L127CB4: db $00;X
L127CB5: db $40;X
L127CB6: db $00;X
L127CB7: db $00;X
L127CB8: db $00;X
L127CB9: db $04;X
L127CBA: db $00;X
L127CBB: db $00;X
L127CBC: db $00;X
L127CBD: db $00;X
L127CBE: db $00;X
L127CBF: db $08;X
L127CC0: db $00;X
L127CC1: db $00;X
L127CC2: db $02;X
L127CC3: db $00;X
L127CC4: db $00;X
L127CC5: db $00;X
L127CC6: db $00;X
L127CC7: db $00;X
L127CC8: db $00;X
L127CC9: db $00;X
L127CCA: db $00;X
L127CCB: db $00;X
L127CCC: db $00;X
L127CCD: db $00;X
L127CCE: db $00;X
L127CCF: db $00;X
L127CD0: db $00;X
L127CD1: db $00;X
L127CD2: db $00;X
L127CD3: db $00;X
L127CD4: db $00;X
L127CD5: db $10;X
L127CD6: db $00;X
L127CD7: db $48;X
L127CD8: db $00;X
L127CD9: db $00;X
L127CDA: db $00;X
L127CDB: db $00;X
L127CDC: db $00;X
L127CDD: db $00;X
L127CDE: db $00;X
L127CDF: db $00;X
L127CE0: db $00;X
L127CE1: db $00;X
L127CE2: db $00;X
L127CE3: db $04;X
L127CE4: db $00;X
L127CE5: db $80;X
L127CE6: db $00;X
L127CE7: db $04;X
L127CE8: db $02;X
L127CE9: db $00;X
L127CEA: db $00;X
L127CEB: db $20;X
L127CEC: db $00;X
L127CED: db $00;X
L127CEE: db $00;X
L127CEF: db $00;X
L127CF0: db $00;X
L127CF1: db $04;X
L127CF2: db $00;X
L127CF3: db $00;X
L127CF4: db $00;X
L127CF5: db $00;X
L127CF6: db $00;X
L127CF7: db $00;X
L127CF8: db $00;X
L127CF9: db $00;X
L127CFA: db $00;X
L127CFB: db $00;X
L127CFC: db $00;X
L127CFD: db $00;X
L127CFE: db $00;X
L127CFF: db $00;X
L127D00: db $FF;X
L127D01: db $FF;X
L127D02: db $FF;X
L127D03: db $FF;X
L127D04: db $FF;X
L127D05: db $FF;X
L127D06: db $FF;X
L127D07: db $E7;X
L127D08: db $FF;X
L127D09: db $FF;X
L127D0A: db $FF;X
L127D0B: db $EF;X
L127D0C: db $EF;X
L127D0D: db $FF;X
L127D0E: db $FF;X
L127D0F: db $FF;X
L127D10: db $FF;X
L127D11: db $FF;X
L127D12: db $FF;X
L127D13: db $ED;X
L127D14: db $7F;X
L127D15: db $FF;X
L127D16: db $FF;X
L127D17: db $FF;X
L127D18: db $BF;X
L127D19: db $FF;X
L127D1A: db $FA;X
L127D1B: db $FF;X
L127D1C: db $FF;X
L127D1D: db $FF;X
L127D1E: db $FF;X
L127D1F: db $FF;X
L127D20: db $FD;X
L127D21: db $FF;X
L127D22: db $FF;X
L127D23: db $DF;X
L127D24: db $FF;X
L127D25: db $FF;X
L127D26: db $BF;X
L127D27: db $FD;X
L127D28: db $FF;X
L127D29: db $FF;X
L127D2A: db $FF;X
L127D2B: db $FF;X
L127D2C: db $FF;X
L127D2D: db $CF;X
L127D2E: db $FF;X
L127D2F: db $FF;X
L127D30: db $FF;X
L127D31: db $FF;X
L127D32: db $FF;X
L127D33: db $FF;X
L127D34: db $FF;X
L127D35: db $F7;X
L127D36: db $FF;X
L127D37: db $FF;X
L127D38: db $FB;X
L127D39: db $FF;X
L127D3A: db $FF;X
L127D3B: db $DF;X
L127D3C: db $FD;X
L127D3D: db $3F;X
L127D3E: db $FB;X
L127D3F: db $FF;X
L127D40: db $F7;X
L127D41: db $FF;X
L127D42: db $FF;X
L127D43: db $DF;X
L127D44: db $FF;X
L127D45: db $F5;X
L127D46: db $FF;X
L127D47: db $FF;X
L127D48: db $FF;X
L127D49: db $FF;X
L127D4A: db $FF;X
L127D4B: db $FF;X
L127D4C: db $FF;X
L127D4D: db $FF;X
L127D4E: db $7F;X
L127D4F: db $FF;X
L127D50: db $FF;X
L127D51: db $DF;X
L127D52: db $FF;X
L127D53: db $FF;X
L127D54: db $FF;X
L127D55: db $FF;X
L127D56: db $FF;X
L127D57: db $FF;X
L127D58: db $FF;X
L127D59: db $FF;X
L127D5A: db $FF;X
L127D5B: db $FF;X
L127D5C: db $FE;X
L127D5D: db $FD;X
L127D5E: db $BF;X
L127D5F: db $9F;X
L127D60: db $FF;X
L127D61: db $FF;X
L127D62: db $FF;X
L127D63: db $F7;X
L127D64: db $FF;X
L127D65: db $FF;X
L127D66: db $7D;X
L127D67: db $DF;X
L127D68: db $7F;X
L127D69: db $FF;X
L127D6A: db $FF;X
L127D6B: db $BF;X
L127D6C: db $FB;X
L127D6D: db $FF;X
L127D6E: db $FF;X
L127D6F: db $FB;X
L127D70: db $FF;X
L127D71: db $F6;X
L127D72: db $FF;X
L127D73: db $FF;X
L127D74: db $FF;X
L127D75: db $FF;X
L127D76: db $FE;X
L127D77: db $FF;X
L127D78: db $FF;X
L127D79: db $FF;X
L127D7A: db $FF;X
L127D7B: db $FF;X
L127D7C: db $FF;X
L127D7D: db $FF;X
L127D7E: db $FF;X
L127D7F: db $FF;X
L127D80: db $00;X
L127D81: db $00;X
L127D82: db $00;X
L127D83: db $00;X
L127D84: db $00;X
L127D85: db $00;X
L127D86: db $04;X
L127D87: db $00;X
L127D88: db $80;X
L127D89: db $08;X
L127D8A: db $10;X
L127D8B: db $00;X
L127D8C: db $04;X
L127D8D: db $00;X
L127D8E: db $00;X
L127D8F: db $00;X
L127D90: db $00;X
L127D91: db $10;X
L127D92: db $00;X
L127D93: db $40;X
L127D94: db $00;X
L127D95: db $00;X
L127D96: db $00;X
L127D97: db $10;X
L127D98: db $10;X
L127D99: db $00;X
L127D9A: db $01;X
L127D9B: db $00;X
L127D9C: db $00;X
L127D9D: db $04;X
L127D9E: db $01;X
L127D9F: db $00;X
L127DA0: db $00;X
L127DA1: db $00;X
L127DA2: db $01;X
L127DA3: db $20;X
L127DA4: db $00;X
L127DA5: db $00;X
L127DA6: db $00;X
L127DA7: db $02;X
L127DA8: db $40;X
L127DA9: db $00;X
L127DAA: db $00;X
L127DAB: db $00;X
L127DAC: db $00;X
L127DAD: db $00;X
L127DAE: db $02;X
L127DAF: db $C0;X
L127DB0: db $00;X
L127DB1: db $01;X
L127DB2: db $00;X
L127DB3: db $00;X
L127DB4: db $80;X
L127DB5: db $08;X
L127DB6: db $01;X
L127DB7: db $12;X
L127DB8: db $00;X
L127DB9: db $00;X
L127DBA: db $00;X
L127DBB: db $00;X
L127DBC: db $00;X
L127DBD: db $00;X
L127DBE: db $10;X
L127DBF: db $00;X
L127DC0: db $00;X
L127DC1: db $00;X
L127DC2: db $80;X
L127DC3: db $00;X
L127DC4: db $00;X
L127DC5: db $00;X
L127DC6: db $00;X
L127DC7: db $00;X
L127DC8: db $00;X
L127DC9: db $00;X
L127DCA: db $00;X
L127DCB: db $00;X
L127DCC: db $00;X
L127DCD: db $00;X
L127DCE: db $00;X
L127DCF: db $04;X
L127DD0: db $00;X
L127DD1: db $00;X
L127DD2: db $00;X
L127DD3: db $00;X
L127DD4: db $01;X
L127DD5: db $00;X
L127DD6: db $81;X
L127DD7: db $00;X
L127DD8: db $01;X
L127DD9: db $00;X
L127DDA: db $00;X
L127DDB: db $00;X
L127DDC: db $00;X
L127DDD: db $10;X
L127DDE: db $70;X
L127DDF: db $00;X
L127DE0: db $08;X
L127DE1: db $80;X
L127DE2: db $02;X
L127DE3: db $00;X
L127DE4: db $20;X
L127DE5: db $00;X
L127DE6: db $00;X
L127DE7: db $00;X
L127DE8: db $00;X
L127DE9: db $00;X
L127DEA: db $00;X
L127DEB: db $00;X
L127dec: db $00;X
L127DED: db $10;X
L127DEE: db $00;X
L127DEF: db $00;X
L127DF0: db $00;X
L127DF1: db $00;X
L127DF2: db $00;X
L127DF3: db $01;X
L127DF4: db $00;X
L127DF5: db $00;X
L127DF6: db $00;X
L127DF7: db $05;X
L127DF8: db $00;X
L127DF9: db $00;X
L127DFA: db $00;X
L127DFB: db $00;X
L127DFC: db $00;X
L127DFD: db $00;X
L127DFE: db $00;X
L127DFF: db $00;X
L127E00: db $FF;X
L127E01: db $FF;X
L127E02: db $FF;X
L127E03: db $EF;X
L127E04: db $FF;X
L127E05: db $FF;X
L127E06: db $FF;X
L127E07: db $FF;X
L127E08: db $FF;X
L127E09: db $FF;X
L127E0A: db $7F;X
L127E0B: db $FF;X
L127E0C: db $F7;X
L127E0D: db $FF;X
L127E0E: db $FD;X
L127E0F: db $FF;X
L127E10: db $FF;X
L127E11: db $FF;X
L127E12: db $BF;X
L127E13: db $FF;X
L127E14: db $FF;X
L127E15: db $FF;X
L127E16: db $FF;X
L127E17: db $FF;X
L127E18: db $FF;X
L127E19: db $FF;X
L127E1A: db $FF;X
L127E1B: db $DF;X
L127E1C: db $FF;X
L127E1D: db $FF;X
L127E1E: db $EF;X
L127E1F: db $FF;X
L127E20: db $FF;X
L127E21: db $FF;X
L127E22: db $FF;X
L127E23: db $FF;X
L127E24: db $FF;X
L127E25: db $FF;X
L127E26: db $FF;X
L127E27: db $FF;X
L127E28: db $FF;X
L127E29: db $FF;X
L127E2A: db $FF;X
L127E2B: db $FF;X
L127E2C: db $FF;X
L127E2D: db $FF;X
L127E2E: db $FF;X
L127E2F: db $FF;X
L127E30: db $FF;X
L127E31: db $FF;X
L127E32: db $FF;X
L127E33: db $FF;X
L127E34: db $FF;X
L127E35: db $FF;X
L127E36: db $F7;X
L127E37: db $FF;X
L127E38: db $FF;X
L127E39: db $FF;X
L127E3A: db $FF;X
L127E3B: db $FF;X
L127E3C: db $FF;X
L127E3D: db $BF;X
L127E3E: db $FF;X
L127E3F: db $FF;X
L127E40: db $7F;X
L127E41: db $FF;X
L127E42: db $BF;X
L127E43: db $FF;X
L127E44: db $FF;X
L127E45: db $FF;X
L127E46: db $FF;X
L127E47: db $FF;X
L127E48: db $FF;X
L127E49: db $FF;X
L127E4A: db $FF;X
L127E4B: db $FF;X
L127E4C: db $FF;X
L127E4D: db $FF;X
L127E4E: db $FF;X
L127E4F: db $FF;X
L127E50: db $FF;X
L127E51: db $FF;X
L127E52: db $FF;X
L127E53: db $FF;X
L127E54: db $FF;X
L127E55: db $FF;X
L127E56: db $BF;X
L127E57: db $FF;X
L127E58: db $FF;X
L127E59: db $FB;X
L127E5A: db $BF;X
L127E5B: db $FF;X
L127E5C: db $FF;X
L127E5D: db $FF;X
L127E5E: db $FE;X
L127E5F: db $FF;X
L127E60: db $BF;X
L127E61: db $FF;X
L127E62: db $FE;X
L127E63: db $FF;X
L127E64: db $FF;X
L127E65: db $FF;X
L127E66: db $F7;X
L127E67: db $FF;X
L127E68: db $FF;X
L127E69: db $FF;X
L127E6A: db $FF;X
L127E6B: db $FF;X
L127E6C: db $FF;X
L127E6D: db $BF;X
L127E6E: db $FF;X
L127E6F: db $FF;X
L127E70: db $FE;X
L127E71: db $FD;X
L127E72: db $FE;X
L127E73: db $FF;X
L127E74: db $FF;X
L127E75: db $FF;X
L127E76: db $FD;X
L127E77: db $FF;X
L127E78: db $FF;X
L127E79: db $FF;X
L127E7A: db $FF;X
L127E7B: db $FF;X
L127E7C: db $FF;X
L127E7D: db $FF;X
L127E7E: db $FF;X
L127E7F: db $FD;X
L127E80: db $0E;X
L127E81: db $20;X
L127E82: db $00;X
L127E83: db $01;X
L127E84: db $04;X
L127E85: db $10;X
L127E86: db $00;X
L127E87: db $04;X
L127E88: db $00;X
L127E89: db $04;X
L127E8A: db $C0;X
L127E8B: db $42;X
L127E8C: db $09;X
L127E8D: db $00;X
L127E8E: db $54;X
L127E8F: db $24;X
L127E90: db $80;X
L127E91: db $00;X
L127E92: db $01;X
L127E93: db $10;X
L127E94: db $03;X
L127E95: db $80;X
L127E96: db $14;X
L127E97: db $00;X
L127E98: db $40;X
L127E99: db $20;X
L127E9A: db $14;X
L127E9B: db $15;X
L127E9C: db $03;X
L127E9D: db $21;X
L127E9E: db $01;X
L127E9F: db $29;X
L127EA0: db $02;X
L127EA1: db $02;X
L127EA2: db $40;X
L127EA3: db $00;X
L127EA4: db $26;X
L127EA5: db $0A;X
L127EA6: db $05;X
L127EA7: db $4E;X
L127EA8: db $02;X
L127EA9: db $61;X
L127EAA: db $00;X
L127EAB: db $08;X
L127EAC: db $40;X
L127EAD: db $10;X
L127EAE: db $10;X
L127EAF: db $0C;X
L127EB0: db $00;X
L127EB1: db $00;X
L127EB2: db $01;X
L127EB3: db $04;X
L127EB4: db $02;X
L127EB5: db $40;X
L127EB6: db $00;X
L127EB7: db $0A;X
L127EB8: db $06;X
L127EB9: db $00;X
L127EBA: db $80;X
L127EBB: db $10;X
L127EBC: db $31;X
L127EBD: db $10;X
L127EBE: db $00;X
L127EBF: db $02;X
L127EC0: db $04;X
L127EC1: db $11;X
L127EC2: db $01;X
L127EC3: db $40;X
L127EC4: db $08;X
L127EC5: db $01;X
L127EC6: db $01;X
L127EC7: db $00;X
L127EC8: db $08;X
L127EC9: db $14;X
L127ECA: db $82;X
L127ECB: db $04;X
L127ECC: db $28;X
L127ECD: db $01;X
L127ECE: db $08;X
L127ECF: db $C8;X
L127ED0: db $89;X
L127ED1: db $00;X
L127ED2: db $01;X
L127ED3: db $00;X
L127ED4: db $00;X
L127ED5: db $30;X
L127ED6: db $00;X
L127ED7: db $41;X
L127ED8: db $00;X
L127ED9: db $22;X
L127EDA: db $02;X
L127EDB: db $02;X
L127EDC: db $01;X
L127EDD: db $00;X
L127EDE: db $10;X
L127EDF: db $C0;X
L127EE0: db $00;X
L127EE1: db $10;X
L127EE2: db $00;X
L127EE3: db $40;X
L127EE4: db $11;X
L127EE5: db $50;X
L127EE6: db $00;X
L127EE7: db $54;X
L127EE8: db $52;X
L127EE9: db $20;X
L127EEA: db $26;X
L127EEB: db $1C;X
L127EEC: db $80;X
L127EED: db $02;X
L127EEE: db $09;X
L127EEF: db $02;X
L127EF0: db $83;X
L127EF1: db $40;X
L127EF2: db $10;X
L127EF3: db $08;X
L127EF4: db $00;X
L127EF5: db $00;X
L127EF6: db $04;X
L127EF7: db $11;X
L127EF8: db $00;X
L127EF9: db $04;X
L127EFA: db $09;X
L127EFB: db $00;X
L127EFC: db $01;X
L127EFD: db $02;X
L127EFE: db $00;X
L127EFF: db $42;X
L127F00: db $FF;X
L127F01: db $FF;X
L127F02: db $FF;X
L127F03: db $DF;X
L127F04: db $FF;X
L127F05: db $EF;X
L127F06: db $FF;X
L127F07: db $FF;X
L127F08: db $FF;X
L127F09: db $FF;X
L127F0A: db $EF;X
L127F0B: db $FF;X
L127F0C: db $FF;X
L127F0D: db $FF;X
L127F0E: db $FF;X
L127F0F: db $FF;X
L127F10: db $FF;X
L127F11: db $FF;X
L127F12: db $FF;X
L127F13: db $FF;X
L127F14: db $FF;X
L127F15: db $FF;X
L127F16: db $FF;X
L127F17: db $FF;X
L127F18: db $FF;X
L127F19: db $FF;X
L127F1A: db $FF;X
L127F1B: db $FF;X
L127F1C: db $FF;X
L127F1D: db $FF;X
L127F1E: db $FF;X
L127F1F: db $FF;X
L127F20: db $FD;X
L127F21: db $FF;X
L127F22: db $FF;X
L127F23: db $FF;X
L127F24: db $FF;X
L127F25: db $7F;X
L127F26: db $FF;X
L127F27: db $FF;X
L127F28: db $FF;X
L127F29: db $F7;X
L127F2A: db $FB;X
L127F2B: db $F7;X
L127F2C: db $FF;X
L127F2D: db $FF;X
L127F2E: db $FF;X
L127F2F: db $7F;X
L127F30: db $FF;X
L127F31: db $EF;X
L127F32: db $EF;X
L127F33: db $FB;X
L127F34: db $FF;X
L127F35: db $F7;X
L127F36: db $FF;X
L127F37: db $FF;X
L127F38: db $7B;X
L127F39: db $EF;X
L127F3A: db $FF;X
L127F3B: db $FF;X
L127F3C: db $F7;X
L127F3D: db $FF;X
L127F3E: db $EF;X
L127F3F: db $FF;X
L127F40: db $EF;X
L127F41: db $FF;X
L127F42: db $FF;X
L127F43: db $FF;X
L127F44: db $FF;X
L127F45: db $FF;X
L127F46: db $FF;X
L127F47: db $FF;X
L127F48: db $EF;X
L127F49: db $DF;X
L127F4A: db $FF;X
L127F4B: db $FF;X
L127F4C: db $FF;X
L127F4D: db $DF;X
L127F4E: db $FF;X
L127F4F: db $FF;X
L127F50: db $FF;X
L127F51: db $FF;X
L127F52: db $FF;X
L127F53: db $FF;X
L127F54: db $FF;X
L127F55: db $FF;X
L127F56: db $FF;X
L127F57: db $FF;X
L127F58: db $F7;X
L127F59: db $FF;X
L127F5A: db $7F;X
L127F5B: db $FF;X
L127F5C: db $7F;X
L127F5D: db $FF;X
L127F5E: db $FF;X
L127F5F: db $7F;X
L127F60: db $FF;X
L127F61: db $FF;X
L127F62: db $BF;X
L127F63: db $7F;X
L127F64: db $FF;X
L127F65: db $FF;X
L127F66: db $FF;X
L127F67: db $FF;X
L127F68: db $FF;X
L127F69: db $F7;X
L127F6A: db $EF;X
L127F6B: db $FF;X
L127F6C: db $FF;X
L127F6D: db $FD;X
L127F6E: db $BF;X
L127F6F: db $FF;X
L127F70: db $FF;X
L127F71: db $FF;X
L127F72: db $FF;X
L127F73: db $FF;X
L127F74: db $FF;X
L127F75: db $FF;X
L127F76: db $FF;X
L127F77: db $DF;X
L127F78: db $EF;X
L127F79: db $7F;X
L127F7A: db $FF;X
L127F7B: db $FF;X
L127F7C: db $FF;X
L127F7D: db $FF;X
L127F7E: db $FF;X
L127F7F: db $FF;X
L127F80: db $05;X
L127F81: db $01;X
L127F82: db $00;X
L127F83: db $11;X
L127F84: db $01;X
L127F85: db $03;X
L127F86: db $90;X
L127F87: db $08;X
L127F88: db $44;X
L127F89: db $05;X
L127F8A: db $00;X
L127F8B: db $00;X
L127F8C: db $40;X
L127F8D: db $02;X
L127F8E: db $02;X
L127F8F: db $28;X
L127F90: db $01;X
L127F91: db $64;X
L127F92: db $80;X
L127F93: db $80;X
L127F94: db $01;X
L127F95: db $02;X
L127F96: db $0C;X
L127F97: db $01;X
L127F98: db $80;X
L127F99: db $01;X
L127F9A: db $00;X
L127F9B: db $00;X
L127F9C: db $20;X
L127F9D: db $01;X
L127F9E: db $09;X
L127F9F: db $01;X
L127FA0: db $06;X
L127FA1: db $09;X
L127FA2: db $01;X
L127FA3: db $00;X
L127FA4: db $08;X
L127FA5: db $84;X
L127FA6: db $01;X
L127FA7: db $02;X
L127FA8: db $01;X
L127FA9: db $01;X
L127FAA: db $A0;X
L127FAB: db $00;X
L127FAC: db $00;X
L127FAD: db $02;X
L127FAE: db $80;X
L127FAF: db $40;X
L127FB0: db $00;X
L127FB1: db $06;X
L127FB2: db $01;X
L127FB3: db $03;X
L127FB4: db $18;X
L127FB5: db $80;X
L127FB6: db $00;X
L127FB7: db $A1;X
L127FB8: db $80;X
L127FB9: db $21;X
L127FBA: db $00;X
L127FBB: db $08;X
L127FBC: db $08;X
L127FBD: db $41;X
L127FBE: db $10;X
L127FBF: db $00;X
L127FC0: db $00;X
L127FC1: db $00;X
L127FC2: db $00;X
L127FC3: db $45;X
L127FC4: db $21;X
L127FC5: db $48;X
L127FC6: db $44;X
L127FC7: db $00;X
L127FC8: db $00;X
L127FC9: db $01;X
L127FCA: db $00;X
L127FCB: db $22;X
L127FCC: db $01;X
L127FCD: db $04;X
L127FCE: db $41;X
L127FCF: db $80;X
L127FD0: db $28;X
L127FD1: db $09;X
L127FD2: db $00;X
L127FD3: db $04;X
L127FD4: db $09;X
L127FD5: db $A1;X
L127FD6: db $0C;X
L127FD7: db $A3;X
L127FD8: db $19;X
L127FD9: db $01;X
L127FDA: db $00;X
L127FDB: db $20;X
L127FDC: db $01;X
L127FDD: db $00;X
L127FDE: db $05;X
L127FDF: db $81;X
L127FE0: db $28;X
L127FE1: db $80;X
L127FE2: db $01;X
L127FE3: db $41;X
L127FE4: db $01;X
L127FE5: db $00;X
L127FE6: db $00;X
L127FE7: db $12;X
L127FE8: db $25;X
L127FE9: db $01;X
L127FEA: db $88;X
L127FEB: db $80;X
L127FEC: db $28;X
L127FED: db $10;X
L127FEE: db $09;X
L127FEF: db $09;X
L127FF0: db $01;X
L127FF1: db $03;X
L127FF2: db $00;X
L127FF3: db $18;X
L127FF4: db $80;X
L127FF5: db $40;X
L127FF6: db $90;X
L127FF7: db $E8;X
L127FF8: db $00;X
L127FF9: db $01;X
L127FFA: db $00;X
L127FFB: db $05;X
L127FFC: db $88;X
L127FFD: db $81;X
L127FFE: db $09;X
L127FFF: db $28;X
