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
	ld   a, [wStaticPlX]
	ld   [sOAMWriteX], a
	ld   a, [wStaticPlY]
	ld   [sOAMWriteY], a
	
	; The subroutine to write OBJLst used in the title screen does not support special flags!
	; So we pick different sprite mappings sets for the different orientations.
	ld   a, [wStaticPlFlags]	; Is the horizontal flip bit set?
	bit  STATIC_OBJLSTB_XFLIP, a
	jr   nz, .rightPos			; If so, use alternate mappings
	ld   a, [wStaticPlLstId]
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
	ld   a, [wStaticPlLstId]
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
	ld   [wStaticPlAnimTimer], a
	ld   [wIntroActTimer], a
	ld   [wTitleActTimer], a
	ld   [wStaticPlLstId], a
	ld   [wIntroShipLstId], a
	ld   [wIntroWaterSplash], a
	ld   [wStaticPlFlags], a
	ld   a, $B8
	ld   [wStaticPlX], a
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
	ld   [wStaticPlLstId], a
	ld   a, $80					; Facing left
	ld   [wStaticPlFlags], a
	ld   a, $04
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct04 ===============
; Move Wario to the left.
Intro_CutsceneAct04:
	call Intro_AnimWarioRow
	ld   b, $C8
	call Intro_MoveWarioLeft
	ld   a, [wStaticPlX]	; Wait until Wario goes fully off-screen to the left
	cp   a, $C8
	ret  nz
	
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   [wStaticPlLstId], a		; Hide Wario to not show the movement done by Intro_MoveWarioRight
	ld   [wStaticPlFlags], a		; since we start 8 px to the right of Act5's target pos
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
	ld   [wStaticPlLstId], a	
	ld   a, $C8					; Set back the correct pos (since we've moved while hidden)
	ld   [wStaticPlX], a
	ld   a, INTRO_SOF_DUCKPANICR
	ld   [wIntroShipLstId], a
	jr   .moveShipRight			; Move the ship to proceed
.chkNextAct:
	; Wait for Wario to go off-screen right
	ld   a, [wStaticPlX]
	cp   a, $C0
	ret  nz
	; Set next act
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   [wStaticPlLstId], a
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
	ld   [wStaticPlLstId], a
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
	ld   a, [wStaticPlX]
	inc  a
	inc  a
	ld   [wStaticPlX], a
	;--
	cp   a, $2E			; When Wario hits the ship
	jr   z, .nextAct
	; Do standard rowing anim until X pos $10
	cp   a, $10
	jr   nc, .useDash			; Then always use dash frame
	jp   Intro_AnimWarioRow	
.useDash:
	ld   a, INTRO_WOF_BOATDASH
	ld   [wStaticPlLstId], a
	ret
.nextAct:
	ld   a, SFX1_1E
	ld   [sSFX1Set], a
	xor  a
	ld   [wStaticPlAnimTimer], a
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
	ld   [wStaticPlLstId], a
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
	ld   [wStaticPlLstId], a
	ld   a, $10
	ld   [wIntroAct], a
	ret
	
; =============== Intro_CutsceneAct10 ===============
; Makes Wario jump on the ship.
Intro_CutsceneAct10:
	
	; wStaticPlAnimTimer reused as table index
	ld   a, [wStaticPlAnimTimer]	; Gone past the end of the table?
	cp   a, (Intro_WarioJumpYTbl_End - Intro_WarioJumpYTbl)
	jr   z, .nextAct				; If so, switch to next act
	;--
	
	; The jump is handled through:
	; - A table of Y coords for Wario's Y pos
	; - Incrementing Wario'x X pos by 1 every frame
	
	ld   c, a						; BC = wStaticPlAnimTimer
	inc  a
	ld   [wStaticPlAnimTimer], a
	ld   hl, Intro_WarioJumpYTbl	; HL = Table of Y coords
	ld   b, $00
	add  hl, bc						; Index the table
	ld   a, [hl]
	ld   [wStaticPlY], a
	ld   a, [wStaticPlX]
	inc  a
	ld   [wStaticPlX], a
	ret
.nextAct:
	ld   a, SFX1_01				; Not using the normal land SFX for some reason
	ld   [sSFX1Set], a
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   a, INTRO_WOF_STAND
	ld   [wStaticPlLstId], a
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
	ld   a, [wStaticPlAnimTimer]
	inc  a
	ld   [wStaticPlAnimTimer], a
	
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
	ld   [wStaticPlAnimTimer], a
.frontFrame:
	ld   a, INTRO_WOF_FRONT
	ld   [wStaticPlLstId], a
	ret
.thumbsUpFrame:
	ld   a, INTRO_WOF_THUMBSUP
	ld   [wStaticPlLstId], a
	ret
.thumbsUpFrame2:
	ld   a, INTRO_WOF_THUMBSUP2
	ld   [wStaticPlLstId], a
	ld   a, [wIntroWarioAnimCycleLeft]	; CyclesLeft--;
	dec  a								
	ld   [wIntroWarioAnimCycleLeft], a	; Are there any anim cycles left? 
	ret  nz								; If so, return
.nextAct:
	xor  a								
	ld   [wStaticPlAnimTimer], a
	ld   a, $12
	ld   [wIntroAct], a
	ret
; =============== Intro_CutsceneAct12 ===============
; Delays for $B9 frames before starting the fade out to demo mode.
Intro_CutsceneAct12:
	ld   a, [wStaticPlAnimTimer]
	cp   a, $B9
	jr   z, .nextAct
	inc  a
	ld   [wStaticPlAnimTimer], a
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
	ld   a, [wStaticPlLstId]
	cp   a, INTRO_WOF_NONE
	ret  z
	
	; Switch frames depending on the anim timer
	ld   a, [wStaticPlAnimTimer]
	inc  a
	ld   [wStaticPlAnimTimer], a
	cp   a, $04
	jr   z, .frame3
	cp   a, $0A
	jr   z, .frame2
	cp   a, $14
	jr   z, .frame1
	ret
.frame3:
	ld   a, INTRO_WOF_BOATROW2
	ld   [wStaticPlLstId], a
	ret
.frame2:
	ld   a, SFX1_1C
	ld   [sSFX1Set], a
	ld   a, INTRO_WOF_BOATROW1
	ld   [wStaticPlLstId], a
	ret
.frame1:
	xor  a
	ld   [wStaticPlAnimTimer], a
	ld   a, INTRO_WOF_BOATROW0
	ld   [wStaticPlLstId], a
	ret
	
; =============== Intro_MoveWarioRight ===============
; Moves Wario 1.5px to the right until the target value is reached.
; IN
; - B: Target X pos
Intro_MoveWarioRight:
	; Determine how many times to move Wario
	; alternate between 1 and 2 times every other frame
	ld   a, [wStaticPlAnimTimer]
	bit  0, a
	jr   nz, .tim2
.tim1:
	ld   c, $01
	jr   .moveWario
.tim2:
	ld   c, $02
	
.moveWario:
	; Move Wario to the left the specified amount of times
	ld   a, [wStaticPlX]	; Reached the target pos?
	cp   a, b
	ret  z					; If so, return
	inc  a					; Move right
	ld   [wStaticPlX], a
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
	ld   a, [wStaticPlAnimTimer]
	bit  0, a
	jr   nz, .tim2
.tim1:
	ld   c, $01			; C = Amount fo times
	jr   .moveWario
.tim2:
	ld   c, $02
	
.moveWario:
	; Move Wario to the left the specified amount of times
	ld   a, [wStaticPlX]	; Have we reached the target pos?
	cp   a, b
	ret  z					; If so, return
	dec  a					; Move left
	ld   [wStaticPlX], a
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
	ld   a, [wStaticPlLstId]
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
	ld   a, [wStaticPlLstId]
	cp   a, $07					; Is it >= INTRO_WOF_STAND?
	jr   nc, .highPosShip		; If so, jump
.highPosBoat:
	ld   a, $78
	ld   [wStaticPlY], a
	ret
.highPosShip:
	ld   a, $6A
	ld   [wStaticPlY], a
	ret
	
.lowPos:
	; Same here
	ld   a, [wStaticPlLstId]
	cp   a, $07
	jr   nc, .lowPosShip
.lowPosBoat:
	ld   a, $77
	ld   [wStaticPlY], a
	ret
.lowPosShip:
	ld   a, $68
	ld   [wStaticPlY], a
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
	mIncJunk "L12675B"
BGRLE_Title: INCBIN "data/bg/title.rls"
BGRLE_TitleClouds: INCBIN "data/bg/title_clouds.rls"
BGRLE_TitleWater: INCBIN "data/bg/title_water.rls"
	mIncJunk "L126856"
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
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_Bat_MoveR)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	ld   bc, +$01
	call ActS_MoveRight
	ret
; =============== Act_Bat_MoveLeft ===============
; Moves the actor left 1px.
Act_Bat_MoveLeft:;C
	ld   a, LOW(OBJLstPtrTable_Act_Bat_MoveL)
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_Bat_MoveL)
	ld   [sActSetOBJLstPtrTablePtr+1], a
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
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_BigFruitL)
	ld   [sActSetOBJLstPtrTablePtr+1], a
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
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_BigFruitR)
	ld   [sActSetOBJLstPtrTablePtr+1], a
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
IF FIX_BUGS == 0
	; [BUG] Where does this come from? Aligning to the Y boundary is enough.
	ld   bc, -$05				
	call ActS_MoveDown
ENDC
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
	mIncJunk "L1276D5"
