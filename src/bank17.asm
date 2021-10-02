;
; BANK $17 - Actor code
;
; =============== ActInit_ChickenDuck ===============
ActInit_ChickenDuck:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$0C
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$04
	ld   [sActSetColiBoxL], a
	ld   a, +$04
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_ChickenDuck
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_ChickenDuck
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_ChickenDuck
	call ActS_SetOBJLstSharedTablePtr
	
	; Set as safe to touch
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	; Use different animation depending on direction
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActChickenDuckModeTimer], a
	
	; Set initial OBJLst
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_ChickenDuck_FlyL, OBJLstPtrTable_Act_ChickenDuck_FlyR
	
	ret
	
OBJLstPtrTable_ActInit_ChickenDuck:
	dw OBJLst_Act_ChickenDuck_WakeL0;X
	dw $0000;X

; =============== Act_ChickenDuck ===============
Act_ChickenDuck:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_ChickenDuck_Main
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartStarKill
	dw Act_ChickenDuck_Main
	dw SubCall_ActS_StartDashKill
	dw Act_ChickenDuck_Main;X
	dw Act_ChickenDuck_Main;X
	dw Act_ChickenDuck_CheckOtherThrown
; =============== Act_ChickenDuck_Main ===============
Act_ChickenDuck_Main:
	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_ChickenDuck_FlyUp
	dw Act_ChickenDuck_Move14
	dw Act_ChickenDuck_Move78
	dw Act_ChickenDuck_AirWait
	dw Act_ChickenDuck_FlyDown
	dw Act_ChickenDuck_Sleep
	dw Act_ChickenDuck_WakeUp
	dw Act_ChickenDuck_GiveCoins
	dw Act_ChickenDuck_FlyOut
	
; =============== Act_ChickenDuck_SwitchToFlyUp ===============
; Allows to properly execute FlyUp, meant to be called at the end of WakeUp.
Act_ChickenDuck_SwitchToFlyUp:
	xor  a								; Reset to initial
	ld   [sActLocalRoutineId], a
	mActSetYSpeed -$04					; 4px up speed
	xor  a								
	ld   [sActChickenDuckModeTimer], a
	
	; Set animation depending on direction faced
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_ChickenDuck_FlyL, OBJLstPtrTable_Act_ChickenDuck_FlyR
	ret
	
; =============== Act_ChickenDuck_FlyUp ===============
; Makes the actor move up after having previously landed on the ground.
; When the actor is about to move down, it switches to the next mode, leading to the modes $00-$06 looping.
;
; However this is called twice:
; - When the actor is first executed, but it ends up immediately switching to Move14.
; - After WakeUp ends, it switches to this mode.
Act_ChickenDuck_FlyUp:
	call ActS_IncOBJLstIdEvery8
	
	; Handle horizontal movement
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_ChickenDuck_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_ChickenDuck_MoveLeft
	
	; Handle vertical movement
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed / 4
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	push bc
REPT 2
	sra  b
	rr   c
ENDR
	call ActS_MoveDown					; Move down by that
	pop  bc
	
	; Switch to the next mode when the actor is about to start moving downwards.
	;
	; This has the nice(?) side-effect that when the actor is first spawned, it has the drop speed set to $00,
	; which causes an immediate switch to the next mode.
	; But why couldn't the routine ID be set immediately to $01?
	ld   a, b												
	or   a, c							; Do we have any drop speed?
	jr   z, .endMode					; If not, switch to the next mode
	
	; Every $20 frames increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $1F
	ret  nz
	inc  bc
	ld   a, c
	ld   [sActSetYSpeed_Low], a
	ld   a, b
	ld   [sActSetYSpeed_High], a
	ret
.endMode:
	ld   a, CDUCK_RTN_MV14
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActChickenDuckModeTimer], a
	; Fall through Act_ChickenDuck_Move14
	
; =============== Act_ChickenDuck_Move14 ===============
; Performs horizontal movement for $14 frames.
Act_ChickenDuck_Move14:
	;--
	; Execute for $14 frames.
	ld   a, [sActChickenDuckModeTimer] 	; Timer++
	inc  a
	ld   [sActChickenDuckModeTimer], a
	cp   a, $14							; Timer >= $14?
	jr   nc, .endMode					; If so, switch to the next mode
	;--
	
	call ActS_IncOBJLstIdEvery8
	; Handle horizontal movement
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_ChickenDuck_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_ChickenDuck_MoveLeft
	ret
.endMode:
	ld   a, CDUCK_RTN_MV78
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActChickenDuckModeTimer], a
	; Fall through Act_ChickenDuck_Move78
	
; =============== Act_ChickenDuck_Move78 ===============
; Performs horizontal movement for $78 frames.
; Why wasn't this part of Act_ChickenDuck_Move14?
Act_ChickenDuck_Move78:
	;--
	; Execute for $78 frames.
	ld   a, [sActChickenDuckModeTimer] 	; Timer++
	inc  a
	ld   [sActChickenDuckModeTimer], a
	cp   a, $78							; Timer >= $78?
	jp   nc, Act_ChickenDuck_SetAirWait	; If so, switch to the next mode
	;--
	call ActS_IncOBJLstIdEvery8
	; Handle horizontal movement
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_ChickenDuck_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_ChickenDuck_MoveLeft
	ret
; =============== Act_ChickenDuck_MoveRight ===============
Act_ChickenDuck_MoveRight:
	; Move right 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	ld   a, LOW(OBJLstPtrTable_Act_ChickenDuck_FlyR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_ChickenDuck_FlyR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	ld   bc, +$01
	call ActS_MoveRight
	
	; If there's a solid block on the right, turn left
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	call nz, Act_ChickenDuck_Turn
	ret
; =============== Act_ChickenDuck_MoveLeft ===============
Act_ChickenDuck_MoveLeft:
	; Move left 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	ld   a, LOW(OBJLstPtrTable_Act_ChickenDuck_FlyL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_ChickenDuck_FlyL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	ld   bc, -$01
	call ActS_MoveRight
	
	; If there's a solid block on the left, turn right
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	call nz, Act_ChickenDuck_Turn
	ret
	
; =============== Act_ChickenDuck_Turn ===============
Act_ChickenDuck_Turn:
	ld   a, [sActLocalRoutineId]
	cp   a, CDUCK_RTN_FLYOUT	; Are we trying to despawn off-screen?
	ret  z					; If so, ignore any blocks in the way
	
	ld   a, [sActSetDir]	; Switch direction
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ret
	
; =============== Act_ChickenDuck_SetAirWait ===============
Act_ChickenDuck_SetAirWait:
	ld   a, CDUCK_RTN_AIRWAIT
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActChickenDuckModeTimer], a
	; Fall through Act_ChickenDuck_AirWait
	
; =============== Act_ChickenDuck_SetAirWait ===============	
; Waits in the air for $3C frames.
Act_ChickenDuck_AirWait:
	;--
	; Execute for $3C frames.
	ld   a, [sActChickenDuckModeTimer] 	; Timer++
	inc  a
	ld   [sActChickenDuckModeTimer], a
	cp   a, $3C							; Timer >= $3C?
	jr   nc, .endMode					; If so, switch to the next mode
	;--
	; Only animate the flight anim
	call ActS_IncOBJLstIdEvery8
	ret
.endMode:
	ld   a, CDUCK_RTN_FLYDOWN
	ld   [sActLocalRoutineId], a
	; Fall through Act_ChickenDuck_FlyDown
	
; =============== Act_ChickenDuck_FlyDown ===============	
; Moves down until landing on solid ground.
Act_ChickenDuck_FlyDown:
	call ActS_IncOBJLstIdEvery8
	
	; Move down 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	; If there's a solid block below the actor, switch to the next mode
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, .endMode
	; Otherwise continue moving down
	ld   bc, +$01
	call ActS_MoveDown
	ret
.endMode:
	ld   a, CDUCK_RTN_SLEEP
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActChickenDuckModeTimer], a
	
	; Set ground anim depending on direction faced
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_ChickenDuck_SleepL, OBJLstPtrTable_Act_ChickenDuck_SleepR
	ret
	
; =============== Act_ChickenDuck_Sleep ===============	
; Sleeps for $C8 frames.
Act_ChickenDuck_Sleep:
	;--
	; Execute for $C8 frames.
	ld   a, [sActChickenDuckModeTimer] 	; Timer++
	inc  a
	ld   [sActChickenDuckModeTimer], a
	cp   a, $C8							; Timer >= $C8?
	jr   nc, .endMode					; If so, switch to the next mode
	;--
	
	; Every $10 frames increase the anim counter
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .tryPlaySFX
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.tryPlaySFX:
	ld   a, [sActChickenDuckModeTimer]	; not sTimer like above but doesn't really matter
	and  a, $0F							; Try every $10 execution frames
	ret  nz								
	ld   a, [sActSetOBJLstId]
	or   a								; Only it lands on the first frame
	ret  nz								
	ld   a, SFX1_29
	ld   [sSFX1Set], a
	ret
.endMode:
	ld   a, CDUCK_RTN_WAKEUP
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActChickenDuckModeTimer], a	
	; Set wake up anim
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_ChickenDuck_WakeL, OBJLstPtrTable_Act_ChickenDuck_WakeR
	ret
	
; =============== Act_ChickenDuck_WakeUp ===============	
; Makes the actor wake up.
Act_ChickenDuck_WakeUp:
	;--
	; Execute for $32 frames.
	ld   a, [sActChickenDuckModeTimer] 		; Timer++
	inc  a
	ld   [sActChickenDuckModeTimer], a
	cp   a, $32								; Timer >= $32?
	jp   nc, Act_ChickenDuck_SwitchToFlyUp	; If so, fly up and repeat the cycle again
	;--
	call ActS_IncOBJLstIdEvery8
	ret
	
; =============== Act_ChickenDuck_CheckOtherThrown ===============	
; Handles what happens when another actor is thrown at it.
Act_ChickenDuck_CheckOtherThrown:

	; This actor generates 10-coins when something is thrown *on top* of it.
	
	;--
	; That "something" can't be everything through.
	; Keys and other 10-coins should kill the actor as normal.
	mActCheckThrownId ACT_DEFAULT_BASE	; Were we thrown a default actor? ( >= $07)
	jp   nc, SubCall_ActS_StartJumpDead	; If so, kill the current actor
	;--
	
	; Check if the thing was thrown on top of the actor.
	; If thrown from below... by mercy this ignores the collision here.
	; (the other actor does get killed as normal though)
	ld   hl, sAct+(sActSetRelY-sActSet)	; HL = Rel.Y of first slot						
	add  hl, de							; Offset the thrown slot (we got DE in mActCheckThrownId)
	
	ld   a, [hl]						; C = Rel. Y of thrown actor
	ld   c, a
	ld   a, [sActSetRelY]				; A = Rel. Y of current actor						
	cp   a, c							; RelYCur < RelYThrown?
	ret  c								; If so, it was thrown from below, so ignore
	;--
	
	; When we get here, the thrown actor can be deleted.
	
	ld   hl, sAct
	add  hl, de							; Index the slot for the thrown actor
	xor  a								; Free slot
	ld   [hl], a						
	ld   a, CDUCK_RTN_GIVECOINS			; Set new routine
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActChickenDuckModeTimer], a
	ld   a, SFX1_2F				; Mark success
	ld   [sSFX1Set], a
	
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_ChickenDuck_EjectL, OBJLstPtrTable_Act_ChickenDuck_EjectR
	ret
	
; =============== Act_ChickenDuck_GiveCoins ===============	
; Handles what happens when another actor is thrown at it.
Act_ChickenDuck_GiveCoins:
	;--
	; Execute for $C8 frames.
	ld   a, [sActChickenDuckModeTimer] 	; Timer++
	inc  a
	ld   [sActChickenDuckModeTimer], a
	cp   a, $C8							; Timer >= $C8?
	jp   nc, .endMode					; If so, switch to the next mode
	;--
	
	call ActS_IncOBJLstIdEvery8
	
	; Every $40 frames spawn a coin
	ld   a, [sActChickenDuckModeTimer]
	and  a, $3F
	call z, .spawnCoin
	
	; Move the actor up at 0.25px/frame, until it reaches Y position $20
	; (to make sure it's always possible to see where the coins come from)
	ld   a, [sActSetRelY]
	cp   a, $20				; RelY < $20?
	ret  c					; If so, return
	ld   a, [sActSetTimer]	; Every 4 frames
	and  a, $03				
	ret  nz
	ld   bc, -$01			; Move up
	call ActS_MoveDown
	ret
	
.spawnCoin:

	;--
	; [POI] Copy the current direction to the interaction direction... which does nothing here.
	; B = sActSetDir << 4
	ld   a, [sActSetDir]
	and  a, $0F						
	swap a
	ld   b, a	
	; Copy over as int. direction 
	ld   a, [sActSetRoutineId]		; A = sActSetRoutineId
	and  a, $0F
	or   a, b						
	xor  ACTINT_R|ACTINT_L			; since the int.dir. value is reversed		
	ld   [sActSetRoutineId], a
	;--
	
	; Make the coin move the opposite direction the actor's facing.
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L				; So cheat the subroutine
	ld   [sActSetDir], a
	call SubCall_ActS_Spawn10Coin
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	
	ld   bc, -$04					; Move up 4px immediately upon spawning the coin
	call ActS_MoveDown
	ret
	
.endMode:
	ld   a, CDUCK_RTN_FLYOUT
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActChickenDuckModeTimer], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_ChickenDuck_FlyL, OBJLstPtrTable_Act_ChickenDuck_FlyR
	ret
	
; =============== Act_ChickenDuck_FlyOut ===============	
; Makes the actor fly out, into the off-screen.
Act_ChickenDuck_FlyOut:
	call ActS_IncOBJLstIdEvery8
	
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown					; Move down by that
	
	; Handle horizontal movement
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_ChickenDuck_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_ChickenDuck_MoveLeft
	
	; Every $10 frames increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $0F
	ret  nz
	ld   a, [sActSetYSpeed_Low]
	sub  a, $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	sbc  a, $00
	ld   [sActSetYSpeed_High], a
	ret
	
OBJLstPtrTable_Act_ChickenDuck_FlyL:
	dw OBJLst_Act_ChickenDuck_FlyL0
	dw OBJLst_Act_ChickenDuck_FlyL1
	dw OBJLst_Act_ChickenDuck_FlyL2
	dw $0000
OBJLstPtrTable_Act_ChickenDuck_FlyR:
	dw OBJLst_Act_ChickenDuck_FlyR0
	dw OBJLst_Act_ChickenDuck_FlyR1
	dw OBJLst_Act_ChickenDuck_FlyR2
	dw $0000
OBJLstPtrTable_Act_ChickenDuck_SleepL:
	dw OBJLst_Act_ChickenDuck_SleepL0
	dw OBJLst_Act_ChickenDuck_SleepL1
	dw $0000
OBJLstPtrTable_Act_ChickenDuck_SleepR:
	dw OBJLst_Act_ChickenDuck_SleepR0
	dw OBJLst_Act_ChickenDuck_SleepR1
	dw $0000
OBJLstPtrTable_Act_ChickenDuck_StunL:
	dw OBJLst_Act_ChickenDuck_StunL
	dw $0000
OBJLstPtrTable_Act_ChickenDuck_StunR:
	dw OBJLst_Act_ChickenDuck_StunR
	dw $0000
OBJLstPtrTable_Act_ChickenDuck_WakeL:
	dw OBJLst_Act_ChickenDuck_WakeL0
	dw OBJLst_Act_ChickenDuck_WakeL1
	dw $0000
OBJLstPtrTable_Act_ChickenDuck_WakeR:
	dw OBJLst_Act_ChickenDuck_WakeR0
	dw OBJLst_Act_ChickenDuck_WakeR1
	dw $0000
OBJLstPtrTable_Act_ChickenDuck_EjectL:
	dw OBJLst_Act_ChickenDuck_WakeL0
	dw OBJLst_Act_ChickenDuck_WakeL2
	dw $0000
OBJLstPtrTable_Act_ChickenDuck_EjectR:
	dw OBJLst_Act_ChickenDuck_WakeR0
	dw OBJLst_Act_ChickenDuck_WakeR2
	dw $0000

OBJLstSharedPtrTable_Act_ChickenDuck:
	dw OBJLstPtrTable_Act_ChickenDuck_StunL;X
	dw OBJLstPtrTable_Act_ChickenDuck_StunR;X
	dw OBJLstPtrTable_Act_ChickenDuck_StunL;X
	dw OBJLstPtrTable_Act_ChickenDuck_StunR;X
	dw OBJLstPtrTable_Act_ChickenDuck_StunL
	dw OBJLstPtrTable_Act_ChickenDuck_StunR
	dw OBJLstPtrTable_Act_ChickenDuck_StunL;X
	dw OBJLstPtrTable_Act_ChickenDuck_StunR;X
	
OBJLst_Act_ChickenDuck_WakeL0: INCBIN "data/objlst/actor/chickenduck_wakel0.bin"
OBJLst_Act_ChickenDuck_FlyL0: INCBIN "data/objlst/actor/chickenduck_flyl0.bin"
OBJLst_Act_ChickenDuck_FlyL1: INCBIN "data/objlst/actor/chickenduck_flyl1.bin"
OBJLst_Act_ChickenDuck_FlyL2: INCBIN "data/objlst/actor/chickenduck_flyl2.bin"
OBJLst_Act_ChickenDuck_WakeL1: INCBIN "data/objlst/actor/chickenduck_wakel1.bin"
OBJLst_Act_ChickenDuck_SleepL0: INCBIN "data/objlst/actor/chickenduck_sleepl0.bin"
OBJLst_Act_ChickenDuck_SleepL1: INCBIN "data/objlst/actor/chickenduck_sleepl1.bin"
OBJLst_Act_ChickenDuck_WakeL2: INCBIN "data/objlst/actor/chickenduck_wakel2.bin"
OBJLst_Act_ChickenDuck_StunL: INCBIN "data/objlst/actor/chickenduck_stunl.bin"
OBJLst_Act_ChickenDuck_WakeR0: INCBIN "data/objlst/actor/chickenduck_waker0.bin"
OBJLst_Act_ChickenDuck_FlyR0: INCBIN "data/objlst/actor/chickenduck_flyr0.bin"
OBJLst_Act_ChickenDuck_FlyR1: INCBIN "data/objlst/actor/chickenduck_flyr1.bin"
OBJLst_Act_ChickenDuck_FlyR2: INCBIN "data/objlst/actor/chickenduck_flyr2.bin"
OBJLst_Act_ChickenDuck_WakeR1: INCBIN "data/objlst/actor/chickenduck_waker1.bin"
OBJLst_Act_ChickenDuck_SleepR0: INCBIN "data/objlst/actor/chickenduck_sleepr0.bin"
OBJLst_Act_ChickenDuck_SleepR1: INCBIN "data/objlst/actor/chickenduck_sleepr1.bin"
OBJLst_Act_ChickenDuck_WakeR2: INCBIN "data/objlst/actor/chickenduck_waker2.bin"
OBJLst_Act_ChickenDuck_StunR: INCBIN "data/objlst/actor/chickenduck_stunr.bin"
GFX_Act_ChickenDuck: INCBIN "data/gfx/actor/chickenduck.bin"

; =============== ActInit_MtTeapotBoss ===============
ActInit_MtTeapotBoss:
	; Setup collision box
	ld   a, -$1C
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_MtTeapotBoss
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_MtTeapotBoss
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_MtTeapotBoss
	call ActS_SetOBJLstSharedTablePtr
	
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer], a
	
	; Damage on top
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	ld   a, $5A
	ld   [sPlFreezeTimer], a
	ret
	
; =============== Act_MtTeapotBoss ===============
Act_MtTeapotBoss:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	;--
	; [POI] Press A 5 times to escape from the boss when held.
	; [BUG] Though the "being held" status is detected using sPlFreezeTimer,
	;       which is also used in the intro to freeze the player...
	ld   a, [sPlFreezeTimer]
	or   a						; Is the player being held?
	jr   z, .chkRoutine			; If not, skip
	ldh  a, [hJoyNewKeys]
	and  a, KEY_A				; Did the player press A?
	jr   z, .chkRoutine			; If not, skip
	ld   a, [sActMtTeapotBossEscapeKeyCount]	; KeyPress++
	inc  a						
	ld   [sActMtTeapotBossEscapeKeyCount], a
	cp   a, $05									; Did we press A 5 times?
	jr   c, .chkRoutine							; If not, skip
	; Otherwise, escape from the boss and accept the jump
	xor  a
	ld   [sActMtTeapotBossEscapeKeyCount], a
	ld   [sPlFreezeTimer], a
	mSubCall Pl_StartJump ; BANK $0D
	;--
.chkRoutine:
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_MtTeapotBoss_IntroFall
	dw Act_MtTeapotBoss_Intro1
	dw Act_MtTeapotBoss_Intro2
	dw Act_MtTeapotBoss_Jump
	dw Act_MtTeapotBoss_Charge
	dw Act_MtTeapotBoss_Stun
	dw Act_MtTeapotBoss_Held
	dw Act_MtTeapotBoss_Thrown
	dw Act_MtTeapotBoss_Dead
	dw Act_MtTeapotBoss_HoldPl
	dw Act_MtTeapotBoss_ThrowPl
	
; =============== Act_MtTeapotBoss_IntroFall ===============
; Intro -- moving down.
Act_MtTeapotBoss_IntroFall:
	; When the actor touches the ground, switch to the next mode
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, .endMode
	
	call ActS_FallDownMax4Speed
	ret
.endMode:
	ld   a, MTBOSS_RTN_INTRO1
	ld   [sActLocalRoutineId], a
	
	mSetScreenShakeFor8
	
	ld   a, SFX4_02
	ld   [sSFX4Set], a
	
	push bc
	ld   bc, OBJLstPtrTable_Act_MtTeapotBoss_IntroA
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, $3C					; Stay in next mode for $3C frames
	ld   [sActMtTeapotBossModeTimer], a
	ld   a, [sActSetY_Low]		; Align to Y block
	and  a, $F0
	ld   [sActSetY_Low], a
	ret
	
; =============== Act_MtTeapotBoss_Intro1 ===============
; Intro -- pause.
Act_MtTeapotBoss_Intro1:
	; Handle mode timer
	ld   a, [sActMtTeapotBossModeTimer]
	dec  a
	ld   [sActMtTeapotBossModeTimer], a
	or   a
	jr   z, .endMode
	;--
	call ActS_IncOBJLstIdEvery8
	ret
.endMode:
	ld   a, MTBOSS_RTN_INTRO2
	ld   [sActLocalRoutineId], a
	push bc
	ld   bc, OBJLstPtrTable_Act_MtTeapotBoss_IntroB
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, $28
	ld   [sActMtTeapotBossModeTimer], a
	ret
; =============== Act_MtTeapotBoss_Intro2 ===============
; Intro -- pause (anim 2).
Act_MtTeapotBoss_Intro2:
	ld   a, [sActMtTeapotBossModeTimer]
	dec  a
	ld   [sActMtTeapotBossModeTimer], a
	or   a
	jr   z, Act_MtTeapotBoss_SwitchToJump
	;--
	call ActS_IncOBJLstIdEvery8
	ret
	
; =============== Act_MtTeapotBoss_SwitchToJump ===============
; Makes the boss start jumping.
Act_MtTeapotBoss_SwitchToJump:
	ld   a, MTBOSS_RTN_JUMP
	ld   [sActLocalRoutineId], a
	
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	mActSetYSpeed -$04
	
	; Since this is the mode set after regaining control... (after being thrown)
	xor  a
	ld   [sPlFreezeTimer], a
	ld   [sActMtTeapotBossEscapeKeyCount], a
	
	;--
	; Make the actor face the center of the screen. (ie: on the right side face left)
	; Depending on the which side of the screen he is, set a different direction and anim.
	
	; Set the left direction first
	push bc
	ld   bc, OBJLstPtrTable_Act_MtTeapotBoss_JumpL			
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, DIR_L				; Make actor face left
	ld   [sActSetDir], a
	
	ld   a, [sActSetRelX]
	cp   a, $50					; Is the actor on the right side of the screen? (XRel >= $50)
	ret  nc						; If so, return
	
	; If on the left side, make him face right instead
	push bc
	ld   bc, OBJLstPtrTable_Act_MtTeapotBoss_JumpR			
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, DIR_R
	ld   [sActSetDir], a
	ret
	
; =============== Act_MtTeapotBoss_Jump ===============
; When the actor is in the middle of a jump.
; Mode ends after landing.
Act_MtTeapotBoss_Jump:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_MtTeapotBoss_Jump_Main
	dw Act_MtTeapotBoss_Jump_Main
	dw Act_MtTeapotBoss_Jump_Main;X
	dw Act_MtTeapotBoss_SwitchToStun
	dw Act_MtTeapotBoss_SwitchToStun
	dw Act_MtTeapotBoss_SwitchToStun
	dw Act_MtTeapotBoss_Jump_Main;X
	dw Act_MtTeapotBoss_Jump_Main
	dw Act_MtTeapotBoss_SwitchToStun;X
	
; =============== Act_MtTeapotBoss_Jump_Main ===============
Act_MtTeapotBoss_Jump_Main:
	; Do horizontal movement
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, .moveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, .moveLeft
	
.moveVert:
	; Handle fall speed.
	;--
	; Shortcut: to save time, ignore ground collision if 4 blocks from the top of the screen.
	; When we're up there, we're definitely not touching a block on the ground,
	; so we can skip a collision check.
	ld   a, [sActSetRelY]
	cp   a, $40					; Y <= $40?
	jr   c, .moveDown			; If so, skip
	;--
	ld   a, [sActSetYSpeed_High]
	bit  7, a					; Is the player moving up? (high byte $FF)
	jr   nz, .moveDown			; If so, skip
	
	; If the actor lands on the ground, end the jump
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, .endMode
.moveDown:
	; Increase the drop speed.
	call ActS_FallDownMax4Speed
	ret
	
; =============== .moveRight ===============
; Moves the actor right at 0.5px/frame.
.moveRight:
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveRight
	ret
; =============== .moveLeft ===============
; Moves the actor left at 0.5px/frame.
.moveLeft:
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveRight
	ret
; =============== .endMode ===============
; Ends the jump, and switches to the charge mode.
.endMode:
	ld   a, [sActSetY_Low]		; Align to Y block
	and  a, $F0
	ld   [sActSetY_Low], a
	ld   a, MTBOSS_RTN_CHARGE		; Set mode
	ld   [sActLocalRoutineId], a
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_MtTeapotBoss_ChargeL, OBJLstPtrTable_Act_MtTeapotBoss_ChargeR
	ret
	
; =============== Act_MtTeapotBoss_Charge ===============
; After landing, the actor charges forward.
Act_MtTeapotBoss_Charge:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_MtTeapotBoss_Charge_Main
	dw Act_MtTeapotBoss_SwitchToHoldPl
	dw Act_MtTeapotBoss_Charge_Main;X
	dw Act_MtTeapotBoss_SwitchToStun
	dw Act_MtTeapotBoss_Charge_Main
	dw Act_MtTeapotBoss_SwitchToStun
	dw Act_MtTeapotBoss_Charge_Main;X
	dw Act_MtTeapotBoss_Charge_Main
	dw Act_MtTeapotBoss_SwitchToStun
	
; =============== Act_MtTeapotBoss_Charge_PlayChargeSFX ===============
; Plays the SFX when charging at the player every 8 frames.
Act_MtTeapotBoss_Charge_PlayChargeSFX:;C
	ld   a, [sActSetTimer]
	and  a, $07
	ret  nz
	ld   a, SFX4_19
	ld   [sSFX4Set], a
	ret
	
; =============== Act_MtTeapotBoss_Charge_Main ===============
Act_MtTeapotBoss_Charge_Main:
	call Act_MtTeapotBoss_Charge_PlayChargeSFX
	
	; Every 4 frames increase the anim counter
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkMoveH
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	
.chkMoveH:
	; Handle horizontal movement
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, .moveRight
	bit  DIRB_L, a
	jr   nz, .moveLeft
	ret ; We never get here, since it's always charging forward
	
; =============== .moveRight ===============
; Moves the actor 2px/frame to the right, until there's no solid ground.
.moveRight:
	call ActColi_GetBlockId_BottomR
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there solid ground on the right?
	jr   z, .turn						; If not, jump
	ld   bc, +$02
	call ActS_MoveRight
	ret
	
; =============== .moveLeft ===============
; Moves the actor 2px/frame to the left, until there's no solid ground.
.moveLeft:;R
	call ActColi_GetBlockId_BottomL
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there solid ground on the left?
	jr   z, .turn						; If not, jump
	ld   bc, -$02
	call ActS_MoveRight
	ret
	
; =============== .turn ===============
; Makes the player turn direction, and in turn, setup a new jump.
.turn:
	ld   a, [sActSetDir]		; Switch direction
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	jp   Act_MtTeapotBoss_SwitchToJump	; Start jump
	
; =============== Act_MtTeapotBoss_ChkRestun ===============
; Handles a secondary stun after groundpounding or dashing against an already stunned boss.
Act_MtTeapotBoss_ChkRestun:
	; If dashing against the stunned actor, start holding it
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_05
	jp   z, Act_MtTeapotBoss_SwitchToHeld
	; Otherwise, if groundpounding on it, restart the stun again
	
; =============== Act_MtTeapotBoss_SwitchToStun ===============
Act_MtTeapotBoss_SwitchToStun:
	ld   a, MTBOSS_RTN_STUN
	ld   [sActLocalRoutineId], a
	
	; Make safe to touch
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	xor  a
	ld   [sActMtTeapotBossModeTimer], a
	ld   a, SFX1_2C
	ld   [sSFX1Set], a
	call SubCall_ActS_SpawnStunStar
	
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_MtTeapotBoss_StunL, OBJLstPtrTable_Act_MtTeapotBoss_StunR
	ret
; =============== Act_MtTeapotBoss_Stun ===============
; Actor stunned.
Act_MtTeapotBoss_Stun:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_MtTeapotBoss_Stun_Main
	dw Act_MtTeapotBoss_Stun_Main
	dw Act_MtTeapotBoss_Stun_Main
	dw Act_MtTeapotBoss_ChkRestun
	dw Act_MtTeapotBoss_Stun_Main
	dw Act_MtTeapotBoss_ChkRestun
	dw Act_MtTeapotBoss_Stun_Main;X
	dw Act_MtTeapotBoss_Stun_Main;X
	dw Act_MtTeapotBoss_Stun_Main
; =============== Act_MtTeapotBoss_Stun_Main ===============
Act_MtTeapotBoss_Stun_Main:
	call ActS_IncOBJLstIdEvery8
	
	; If the stunned actor is thrown into lava, the boss is defeated
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSpikeBlock
	or   a
	jp   nz, Act_MtTeapotBoss_SetDead
	
	call Act_MtTeapotBoss_Stun_MoveVert
	
	; You have $4B frames to throw him into lava, after that he jumps out of stun mode
	ld   a, [sActMtTeapotBossModeTimer]
	inc  a
	ld   [sActMtTeapotBossModeTimer], a
	cp   a, $4B
	jp   nc, Act_MtTeapotBoss_SwitchToJump
	
	; For the first 4 frames, move closer to the player
	cp   a, $04								; Timer < $04?
	call c, Act_MtTeapotBoss_Stun_MoveToPl	; If so, call
	
	; Between frames $32-$41 the actor can be picked up.
	; Outside this window, the player will be in the bump anim, but fail to pick it up.
	; For frames , switch to next mode if bumped again
	cp   a, $32								; Timer < $32?
	ret  c									; If so, return
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_01						; Did the player bump into the actor again?
	jr   z, Act_MtTeapotBoss_SwitchToHeld	; If so, start holding the boss
	ret
	
; =============== Act_MtTeapotBoss_Stun_MoveVert ===============
Act_MtTeapotBoss_Stun_MoveVert:
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is the actor on solid ground?
	jr   z, .fallDown					; If not, jump
	
	xor  a								; Otherwise, reset drop speed
	ld   [sActSetYSpeed_Low], a	
	ld   [sActSetYSpeed_High], a
	ret
.fallDown:
	call ActS_FallDownMax4Speed
	ret
	
; =============== Act_MtTeapotBoss_Stun_MoveToPl ===============
; Moves the actor closer to the player.
Act_MtTeapotBoss_Stun_MoveToPl:
	ld   a, [sActSetRelX]	; B = Actor X pos
	ld   b, a
	ld   a, [sPlXRel]		; A = Player X pos
	cp   a, b				; Is the player to the right of the actor? (ActX < PlX)
	jr   nc, .moveL 		; If so, move actor left
.moveR:
	ld   bc, +$01
	call ActS_MoveRight
	ret
.moveL:
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
; =============== Act_MtTeapotBoss_SwitchToHeld ===============
; Special subroutine for starting to hold the boss.
Act_MtTeapotBoss_SwitchToHeld:

	; Abort if we're already holding something (like a coin)
	ld   a, [sActHeld]
	or   a					
	ret  nz
	
	ld   a, MTBOSS_RTN_HELD
	ld   [sActLocalRoutineId], a
	ld   a, $00 						; oops
	ld   a, $3C							; escape after $3C frames
	ld   [sActMtTeapotBossModeTimer], a
	ld   [sActSetColiType], a
	ld   a, $01							; mark as held
	ld   [sActHeld], a
	
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_MtTeapotBoss_StunL, OBJLstPtrTable_Act_MtTeapotBoss_StunR
	ret
	
; =============== Act_MtTeapotBoss_Held ===============
; When the boss is held.
Act_MtTeapotBoss_Held:
	call ActS_SyncHeldPos
	call ActS_IncOBJLstIdEvery8
	
	; Decrease the timer left before the boss escapes...
	ld   a, [sActMtTeapotBossModeTimer]	; TimerLeft--;
	dec  a
	ld   [sActMtTeapotBossModeTimer], a
	
	; [POI] ...but by holding B, we can prevent that to happen.
	ldh  a, [hJoyKeys]
	bit  KEYB_B, a		; Did we stop holding B at least once?
	call z, .allowThrow	; If so, enable throwing
	ldh  a, [hJoyKeys]
	bit  KEYB_B, a		; Did we press/hold B?
	jr   nz, .tryThrow	; If so, try throwing
	
	; Otherwise, if we aren't holding B, check if the timer elapsed.
	; If so, jump out of the stun routine.
	ld   a, [sActMtTeapotBossModeTimer]
	or   a
	ret  nz
	xor  a
	ld   [sActHeld], a
	jp   Act_MtTeapotBoss_SwitchToJump
	
.allowThrow:
	; The reason this exists is to prevent automatically throwing the actor when picking it up while holding B.
	; If we pick up the actor while holding B, sActHeld won't be set to $02,
	; which is then checked by .tryThrow before starting the throw sequence.
	;
	; ...though this is a bit of a weird way to check for it. 
	;    Couldn't hJoyNewKeys have been used?
	ld   a, $02			
	ld   [sActHeld], a
	ret
	
.tryThrow:
	ld   a, SFX1_0C
	ld   [sSFX1Set], a
	
	; Prevent auto-throw
	ld   a, [sActHeld]
	cp   a, $02
	ret  nz
	
	mActSetYSpeed -$02
	
	xor  a
	ld   [sActHeld], a
	ld   a, MTBOSS_RTN_THROWN
	ld   [sActLocalRoutineId], a
	
	; Set same direction as the player
	ld   a, DIR_R
	ld   [sActSetDir], a
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a	; Is the player facing right?
	ret  nz					; If so, return
	ld   a, DIR_L			; Otherwise, make actor face left
	ld   [sActSetDir], a
	ret
	
; =============== Act_MtTeapotBoss_Thrown ===============
; When the boss is thrown.
Act_MtTeapotBoss_Thrown:
	; Do horizontal movement
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, .moveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, .moveLeft
	
	call ActS_FallDownMax4Speed
	
	
	ld   a, [sActSetYSpeed_High]
	bit  7, a							; Is the actor is moving up? (YSpeed < 0)
	ret  nz								; If so, skip any ground collision checks
	
	;--
	; If the actor is inside lava, the boss is defeated 
	; [POI] Not necessary -- the ground check always activates earlier.
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSpikeBlock
	or   a
	jp   nz, Act_MtTeapotBoss_SetDead
	;--
	; If the actor is over lava, the boss is defeated
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSpikeBlock
	or   a
	jp   nz, Act_MtTeapotBoss_SetDead
	
	; If the actor lands on solid ground, stun it again
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jp   nz, Act_MtTeapotBoss_SwitchToStun
	
	ret
	
; =============== .moveRight ===============
; Moves the actor right 1px.
.moveRight:
	; If there's a solid block on the right, stop moving
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	ret  nz
	
	ld   bc, +$01
	call ActS_MoveRight
	ret
	
; =============== .moveLeft ===============
; Moves the actor left 1px.
.moveLeft:
	; If there's a solid block on the left, stop moving
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	ret  nz
	
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
; =============== Act_MtTeapotBoss_SetDead ===============
; Switches to the "Boss Defeated" routine, after the boss collides with a lava block.
Act_MtTeapotBoss_SetDead:
	mActSetYSpeed -$04 					; Jump effect
	ld   a, MTBOSS_RTN_DEAD
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActMtTeapotBossCoinGameStarted], a
	
	ld   a, SFX1_09
	ld   [sSFX1Set], a
	ld   a, BGM_NONE
	ld   [sBGMSet], a
	
IF OPTIMIZE == 0
	call ActS_DespawnAllNormExceptCur_Broken
ENDC
	
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_MtTeapotBoss_DeadL, OBJLstPtrTable_Act_MtTeapotBoss_DeadR
	ret
	
; =============== Act_MtTeapotBoss_Dead ===============
; Jump death routine and coin game.
Act_MtTeapotBoss_Dead:
	call ActS_IncOBJLstIdEvery8
	
	ld   a, [sActMtTeapotBossCoinGameStarted]
	or   a									; Did we start the coin game?
	call z, ActS_FallDownEvery8				; If not, continue moving down
	
	; When the boss goes fully off-screen (more or less), start the coin game.
	; In practice the coin game starts when the current speed is $07.
	ld   a, [sActSetYSpeed_High]
	or   a								; Are we still moving up? (sActSetYSpeed < 0)?
	ret  nz								; If so, return
	ld   a, [sActSetYSpeed_Low]
	cp   a, $07							; Are we moving slower than 7px/frame?
	ret  c								; If so, return
	ld   a, [sActMtTeapotBossCoinGameStarted]
	or   a								; Have we started the coin game already?
	call z, .startCoinGame				; If not, start it
	call SubCall_ActS_CoinGame			; Then execute it
	ret
.startCoinGame:
	ld   a, $01
	ld   [sActMtTeapotBossCoinGameStarted], a
	ld   a, BGM_COINGAME
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	ret
	
; =============== Act_MtTeapotBoss_SwitchToHoldPl ===============
; When the boss starts holding the player.
Act_MtTeapotBoss_SwitchToHoldPl:
	ld   a, MTBOSS_RTN_HOLDPL
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActMtTeapotBossModeTimer], a
	
	ld   a, $FF						; Freeze the player controls
	ld   [sPlFreezeTimer], a		; It should be long enough for the duration of the grab
	
	; Update the player's position, so that it goes on the boss' hand
	
	;
	; Y POSITION
	;
	ld   a, [sActSetY_Low]			; PlX = ActY - $23
	sub  a, MTBOSS_PLHOLD_YREL
	ld   [sPlY_Low], a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ld   [sPlY_High], a
	
	;
	; X POSITION + ACTOR OBJLST
	;
	; The X position is different depending on the direction the boss is facing
	; The X offset is the same because in practice the animation is flipped.
	ld   a, [sActSetDir]
	bit  DIRB_R, a					; Is the actor facing right?	
	jr   nz, .setR					; If so, jump
.setL:
	; Facing left (arm is on the left)
	push bc
	ld   bc, OBJLstPtrTable_Act_MtTeapotBoss_HoldL
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, [sActSetX_Low]			; PlX = ActX - $14 
	sub  a, MTBOSS_PLHOLD_XREL
	ld   [sPlX_Low], a
	ld   a, [sActSetX_High]
	sbc  a, $00
	ld   [sPlX_High], a
	ret
.setR:
	; Facing right (arm is on the right)
	push bc
	ld   bc, OBJLstPtrTable_Act_MtTeapotBoss_HoldR
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, [sActSetX_Low]			; PlX = ActX + $14
	add  MTBOSS_PLHOLD_XREL
	ld   [sPlX_Low], a
	ld   a, [sActSetX_High]
	adc  a, $00
	ld   [sPlX_High], a
	ret
	
; =============== Act_MtTeapotBoss_HoldPl ===============
; Boss moves while holding the player until reaching the end of the solid platform.
Act_MtTeapotBoss_HoldPl:
	; If the player was thrown, start a jump
	ld   a, [sPlFreezeTimer]
	or   a						
	jp   z, Act_MtTeapotBoss_SwitchToJump
	
	call ActS_IncOBJLstIdEvery8
	
.moveV:
	;--
	; Make player bob up and down by 1px as the boss is walking.
	; This is accomplished by generating a value alternating between $00 and $01 every 8 frames.
	;
	; This is then added to a base Y offset (same as the one in Act_MtTeapotBoss_SwitchToHoldPl),
	; leading to the final offset being:
	; C = $23 + (sActSetTimer / 8) % 2
	
	ld   c, MTBOSS_PLHOLD_YREL	; Base offset
	; Generate the 1px alternating value
	ld   a, [sActSetTimer]
	and  a, $08					; Filter bit 3
	rrca						; Shift it down to bit 0
	rrca
	rrca
	add  c					; Add it over
	ld   c, a
	
	; With that done, update the player's position to be relative to the actor (still in the hand).
	ld   a, [sActSetY_Low]		; PlY = ActY - C
	sub  a, c
	ld   [sPlY_Low], a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ld   [sPlY_High], a
	;--
	
	; Make the actor start moving forwards after $18 frames
	ld   a, [sActMtTeapotBossModeTimer]
	cp   a, $18							; Timer >= $18?
	jr   nc, .moveH						; If so, move
	inc  a								; Otherwise, continue
	ld   [sActMtTeapotBossModeTimer], a
	ret
.moveH:
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, .moveRight
	bit  DIRB_L, a
	jr   nz, .moveLeft
	ret ; We never get here
	
; =============== .moveRight ===============
; Makes the boss walk right until reaching the end of the solid platform.
.moveRight:
	ld   a, LOW(OBJLstPtrTable_Act_MtTeapotBoss_HoldWalkR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_MtTeapotBoss_HoldWalkR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Check if we've reached the end of the platform.
	;
	; To save time, and probably since it would require a specific subroutine (he stops slightly earlier than the end of the platform),
	; this is done by checking the actor's rel. position instead of doing an actual collision check.
	ld   a, [sActSetRelX]
	cp   a, $6A					; ActX >= $6A?
	jr   nc, .endMode			; If so, stop
	; Otherwise continue moving right
	ld   bc, +$01				
	call ActS_MoveRight			; Move actor
	
	ld   a, [sActSetX_Low]		; Move held player
	add  MTBOSS_PLHOLD_XREL					
	ld   [sPlX_Low], a
	ld   a, [sActSetX_High]
	adc  a, $00
	ld   [sPlX_High], a
	ret
	
; =============== .moveLeft ===============
; Makes the boss walk left until reaching the end of the solid platform.
.moveLeft:
	ld   a, LOW(OBJLstPtrTable_Act_MtTeapotBoss_HoldWalkL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_MtTeapotBoss_HoldWalkL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	ld   a, [sActSetRelX]
	cp   a, $48					; ActX <= $48?
	jr   c, .endMode
	
	ld   bc, -$01				; Move actor
	call ActS_MoveRight
	ld   a, [sActSetX_Low]		; Move held player
	sub  a, MTBOSS_PLHOLD_XREL
	ld   [sPlX_Low], a
	ld   a, [sActSetX_High]
	sbc  a, $00
	ld   [sPlX_High], a
	ret
	
; =============== .endMode ===============
.endMode:
	ld   a, $80
	ld   [sPlFreezeTimer], a
	ld   a, MTBOSS_RTN_THROWPL
	ld   [sActLocalRoutineId], a
	ld   a, $00
	ld   [sActSetTimer7], a
	xor  a
	ld   [sActSetTimer], a
	ld   [sActMtTeapotBossModeTimer], a
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_MtTeapotBoss_ThrowL, OBJLstPtrTable_Act_MtTeapotBoss_ThrowR
	ret
	
; =============== Act_MtTeapotBoss_ThrowPl ===============
; Player is thrown.
Act_MtTeapotBoss_ThrowPl:
	; When the player regains control, return to the main mode loop
	ld   a, [sPlFreezeTimer]
	or   a
	jp   z, Act_MtTeapotBoss_SwitchToJump
	
	call ActS_IncOBJLstIdEvery8
	
	; Move player horizontally in a diagonal arc
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, .moveRight
	bit  DIRB_L, a
	jr   nz, .moveLeft
	ret ; We never get here
; =============== .moveLeft ===============
; Moves the actor down-left, until touching the edge of the screen.
.moveLeft:
	ld   a, [sPlXRel]
	cp   a, $14					; Did the player reach the left border of the screen?
	jp   c, Act_MtTeapotBoss_SwitchToJump	; If so, switch to main
	
	ld   a, [sPlX_Low]			; sPlX -= $03
	sub  a, $03
	ld   [sPlX_Low], a
	ld   a, [sPlX_High]
	sbc  a, $00
	ld   [sPlX_High], a
	ld   a, [sPlY_Low]			; sPLY += $02
	add  $02
	ld   [sPlY_Low], a
	ld   a, [sPlY_High]
	adc  a, $00
	ld   [sPlY_High], a
	ret
; =============== .moveRight ===============
; Moves the actor down-right, until touching the edge of the screen.
.moveRight:
	ld   a, [sPlXRel]
	cp   a, $9E					; Did the player reach the right border of the screen?
	jp   nc, Act_MtTeapotBoss_SwitchToJump	; If so, switch to main
	
	ld   a, [sPlX_Low]			; sPlX += $03
	add  $03					
	ld   [sPlX_Low], a
	ld   a, [sPlX_High]
	adc  a, $00
	ld   [sPlX_High], a
	ld   a, [sPlY_Low]			; sPLY += $02
	add  $02
	ld   [sPlY_Low], a
	ld   a, [sPlY_High]
	adc  a, $00
	ld   [sPlY_High], a
	ret
	
OBJLstSharedPtrTable_Act_MtTeapotBoss:
	dw OBJLstPtrTable_Act_MtTeapotBoss_DeadL;X
	dw OBJLstPtrTable_Act_MtTeapotBoss_DeadR;X
	dw OBJLstPtrTable_Act_MtTeapotBoss_DeadL;X
	dw OBJLstPtrTable_Act_MtTeapotBoss_DeadR;X
	dw OBJLstPtrTable_Act_MtTeapotBoss_DeadL;X
	dw OBJLstPtrTable_Act_MtTeapotBoss_DeadR;X
	dw OBJLstPtrTable_Act_MtTeapotBoss_DeadL;X
	dw OBJLstPtrTable_Act_MtTeapotBoss_DeadR;X

; [TCRF] Some of the right-facing variations are unused.
OBJLstPtrTable_ActInit_MtTeapotBoss:
	dw OBJLst_Act_MtTeapotBoss_IntroL0
	dw $0000;X
OBJLstPtrTable_ActInit_MtTeapotBoss_Unused_R:
	dw OBJLst_Act_MtTeapotBoss_Unused_IntroR0;X
	dw $0000;X
OBJLstPtrTable_Act_MtTeapotBoss_IntroA:
	dw OBJLst_Act_MtTeapotBoss_IntroL0
	dw OBJLst_Act_MtTeapotBoss_IntroL1
	dw $0000
OBJLstPtrTable_Act_MtTeapotBoss_IntroA_Unused_R:
	dw OBJLst_Act_MtTeapotBoss_Unused_IntroR0;X
	dw OBJLst_Act_MtTeapotBoss_Unused_IntroR1;X
	dw $0000;X
OBJLstPtrTable_Act_MtTeapotBoss_IntroB:
	dw OBJLst_Act_MtTeapotBoss_IntroL0
	dw OBJLst_Act_MtTeapotBoss_IntroL2
	dw OBJLst_Act_MtTeapotBoss_IntroL0
	dw OBJLst_Act_MtTeapotBoss_IntroL3
	dw $0000
OBJLstPtrTable_Act_MtTeapotBoss_IntroB_Unused_R:
	dw OBJLst_Act_MtTeapotBoss_Unused_IntroR0;X
	dw OBJLst_Act_MtTeapotBoss_Unused_IntroR2;X
	dw OBJLst_Act_MtTeapotBoss_Unused_IntroR0;X
	dw OBJLst_Act_MtTeapotBoss_Unused_IntroR3;X
	dw $0000;X
; [TCRF] Placeholder anims? These use a single-frame from the walk cycle.
OBJLstPtrTable_Act_MtTeapotBoss_Unused_ChargeL:
	dw OBJLst_Act_MtTeapotBoss_ChargeL0;X
	dw $0000;X
OBJLstPtrTable_Act_MtTeapotBoss_Unused_ChargeR:
	dw OBJLst_Act_MtTeapotBoss_ChargeR0;X
	dw $0000;X
OBJLstPtrTable_Act_MtTeapotBoss_JumpL:
	dw OBJLst_Act_MtTeapotBoss_JumpL
	dw $0000;X
OBJLstPtrTable_Act_MtTeapotBoss_JumpR:
	dw OBJLst_Act_MtTeapotBoss_JumpR
	dw $0000;X
OBJLstPtrTable_Act_MtTeapotBoss_ChargeL:
	dw OBJLst_Act_MtTeapotBoss_ChargeL0
	dw OBJLst_Act_MtTeapotBoss_ChargeL1
	dw OBJLst_Act_MtTeapotBoss_ChargeL0
	dw OBJLst_Act_MtTeapotBoss_ChargeL2
	dw $0000
OBJLstPtrTable_Act_MtTeapotBoss_ChargeR:
	dw OBJLst_Act_MtTeapotBoss_ChargeR0
	dw OBJLst_Act_MtTeapotBoss_ChargeR1
	dw OBJLst_Act_MtTeapotBoss_ChargeR0
	dw OBJLst_Act_MtTeapotBoss_ChargeR2
	dw $0000
OBJLstPtrTable_Act_MtTeapotBoss_HoldL:
	dw OBJLst_Act_MtTeapotBoss_HoldL
	dw OBJLst_Act_MtTeapotBoss_HoldWalkL0
	dw OBJLst_Act_MtTeapotBoss_HoldWalkL0
	dw OBJLst_Act_MtTeapotBoss_HoldWalkL0
	dw $0000;X
OBJLstPtrTable_Act_MtTeapotBoss_HoldR:
	dw OBJLst_Act_MtTeapotBoss_HoldR
	dw OBJLst_Act_MtTeapotBoss_HoldWalkR0
	dw OBJLst_Act_MtTeapotBoss_HoldWalkR0
	dw OBJLst_Act_MtTeapotBoss_HoldWalkR0
	dw $0000;X
OBJLstPtrTable_Act_MtTeapotBoss_HoldWalkL:
	dw OBJLst_Act_MtTeapotBoss_HoldWalkL0
	dw OBJLst_Act_MtTeapotBoss_HoldWalkL1
	dw OBJLst_Act_MtTeapotBoss_HoldWalkL0
	dw OBJLst_Act_MtTeapotBoss_HoldWalkL2
	dw $0000
OBJLstPtrTable_Act_MtTeapotBoss_HoldWalkR:
	dw OBJLst_Act_MtTeapotBoss_HoldWalkR0
	dw OBJLst_Act_MtTeapotBoss_HoldWalkR1
	dw OBJLst_Act_MtTeapotBoss_HoldWalkR0
	dw OBJLst_Act_MtTeapotBoss_HoldWalkR2
	dw $0000
; [TCRF] Last frame doesn't get played, but it's more of the same
OBJLstPtrTable_Act_MtTeapotBoss_ThrowL:
	dw OBJLst_Act_MtTeapotBoss_HoldWalkL0
	dw OBJLst_Act_MtTeapotBoss_HoldL
	dw OBJLst_Act_MtTeapotBoss_HoldL
	dw OBJLst_Act_MtTeapotBoss_HoldL;X
	dw $0000;X
OBJLstPtrTable_Act_MtTeapotBoss_ThrowR:
	dw OBJLst_Act_MtTeapotBoss_HoldWalkR0
	dw OBJLst_Act_MtTeapotBoss_HoldR
	dw OBJLst_Act_MtTeapotBoss_HoldR
	dw OBJLst_Act_MtTeapotBoss_HoldR;X
	dw $0000;X
; [TCRF] Placeholder anims? These use a single-frame from the stun anim.
OBJLstPtrTable_Act_MtTeapotBoss_Unused_StunL:
	dw OBJLst_Act_MtTeapotBoss_StunL0;X
	dw $0000;X
OBJLstPtrTable_Act_MtTeapotBoss_Unused_StunR:
	dw OBJLst_Act_MtTeapotBoss_StunR0;X
	dw $0000;X
OBJLstPtrTable_Act_MtTeapotBoss_StunL:
	dw OBJLst_Act_MtTeapotBoss_StunL0
	dw OBJLst_Act_MtTeapotBoss_StunL1
	dw $0000
OBJLstPtrTable_Act_MtTeapotBoss_StunR:
	dw OBJLst_Act_MtTeapotBoss_StunR0
	dw OBJLst_Act_MtTeapotBoss_StunR1
	dw $0000
OBJLstPtrTable_Act_MtTeapotBoss_DeadL:
	dw OBJLst_Act_MtTeapotBoss_DeadL0
	dw OBJLst_Act_MtTeapotBoss_DeadL1
	dw $0000
OBJLstPtrTable_Act_MtTeapotBoss_DeadR:
	dw OBJLst_Act_MtTeapotBoss_DeadR0
	dw OBJLst_Act_MtTeapotBoss_DeadR1
	dw $0000

OBJLst_Act_MtTeapotBoss_IntroL0: INCBIN "data/objlst/actor/mtteapotboss_introl0.bin"
OBJLst_Act_MtTeapotBoss_IntroL1: INCBIN "data/objlst/actor/mtteapotboss_introl1.bin"
OBJLst_Act_MtTeapotBoss_IntroL2: INCBIN "data/objlst/actor/mtteapotboss_introl2.bin"
OBJLst_Act_MtTeapotBoss_IntroL3: INCBIN "data/objlst/actor/mtteapotboss_introl3.bin"
; [TCRF] Unused sprite mappings pointing to unused graphics.
;        It looks like steam was going to come out of the nose, given this boss is a bull and all.
;        Being a separate sprite mapping, it would have required its own actor.
OBJLst_Act_MtTeapotBoss_Unused_SteamL0: INCBIN "data/objlst/actor/mtteapotboss_unused_steaml0.bin"
OBJLst_Act_MtTeapotBoss_Unused_SteamL1: INCBIN "data/objlst/actor/mtteapotboss_unused_steaml1.bin"
OBJLst_Act_MtTeapotBoss_Unused_SteamL2: INCBIN "data/objlst/actor/mtteapotboss_unused_steaml2.bin"
OBJLst_Act_MtTeapotBoss_ChargeL0: INCBIN "data/objlst/actor/mtteapotboss_chargel0.bin"
OBJLst_Act_MtTeapotBoss_JumpL: INCBIN "data/objlst/actor/mtteapotboss_jumpl.bin"
OBJLst_Act_MtTeapotBoss_ChargeL1: INCBIN "data/objlst/actor/mtteapotboss_chargel1.bin"
OBJLst_Act_MtTeapotBoss_ChargeL2: INCBIN "data/objlst/actor/mtteapotboss_chargel2.bin"
OBJLst_Act_MtTeapotBoss_HoldWalkL0: INCBIN "data/objlst/actor/mtteapotboss_holdwalkl0.bin"
OBJLst_Act_MtTeapotBoss_HoldWalkL1: INCBIN "data/objlst/actor/mtteapotboss_holdwalkl1.bin"
OBJLst_Act_MtTeapotBoss_HoldWalkL2: INCBIN "data/objlst/actor/mtteapotboss_holdwalkl2.bin"
OBJLst_Act_MtTeapotBoss_HoldL: INCBIN "data/objlst/actor/mtteapotboss_holdl.bin"
OBJLst_Act_MtTeapotBoss_DeadL0: INCBIN "data/objlst/actor/mtteapotboss_deadl0.bin"
OBJLst_Act_MtTeapotBoss_StunL0: INCBIN "data/objlst/actor/mtteapotboss_stunl0.bin"
OBJLst_Act_MtTeapotBoss_StunL1: INCBIN "data/objlst/actor/mtteapotboss_stunl1.bin"
OBJLst_Act_MtTeapotBoss_DeadL1: INCBIN "data/objlst/actor/mtteapotboss_deadl1.bin"
OBJLst_Act_MtTeapotBoss_Unused_IntroR0: INCBIN "data/objlst/actor/mtteapotboss_unused_intror0.bin"
OBJLst_Act_MtTeapotBoss_Unused_IntroR1: INCBIN "data/objlst/actor/mtteapotboss_unused_intror1.bin"
OBJLst_Act_MtTeapotBoss_Unused_IntroR2: INCBIN "data/objlst/actor/mtteapotboss_unused_intror2.bin"
OBJLst_Act_MtTeapotBoss_Unused_IntroR3: INCBIN "data/objlst/actor/mtteapotboss_unused_intror3.bin"
; [TCRF] Right facing nose steam
OBJLst_Act_MtTeapotBoss_Unused_SteamR0: INCBIN "data/objlst/actor/mtteapotboss_unused_steamr0.bin"
OBJLst_Act_MtTeapotBoss_Unused_SteamR1: INCBIN "data/objlst/actor/mtteapotboss_unused_steamr1.bin"
OBJLst_Act_MtTeapotBoss_Unused_SteamR2: INCBIN "data/objlst/actor/mtteapotboss_unused_steamr2.bin"
OBJLst_Act_MtTeapotBoss_ChargeR0: INCBIN "data/objlst/actor/mtteapotboss_charger0.bin"
OBJLst_Act_MtTeapotBoss_JumpR: INCBIN "data/objlst/actor/mtteapotboss_jumpr.bin"
OBJLst_Act_MtTeapotBoss_ChargeR1: INCBIN "data/objlst/actor/mtteapotboss_charger1.bin"
OBJLst_Act_MtTeapotBoss_ChargeR2: INCBIN "data/objlst/actor/mtteapotboss_charger2.bin"
OBJLst_Act_MtTeapotBoss_HoldWalkR0: INCBIN "data/objlst/actor/mtteapotboss_holdwalkr0.bin"
OBJLst_Act_MtTeapotBoss_HoldWalkR1: INCBIN "data/objlst/actor/mtteapotboss_holdwalkr1.bin"
OBJLst_Act_MtTeapotBoss_HoldWalkR2: INCBIN "data/objlst/actor/mtteapotboss_holdwalkr2.bin"
OBJLst_Act_MtTeapotBoss_HoldR: INCBIN "data/objlst/actor/mtteapotboss_holdr.bin"
OBJLst_Act_MtTeapotBoss_DeadR0: INCBIN "data/objlst/actor/mtteapotboss_deadr0.bin"
OBJLst_Act_MtTeapotBoss_StunR0: INCBIN "data/objlst/actor/mtteapotboss_stunr0.bin"
OBJLst_Act_MtTeapotBoss_StunR1: INCBIN "data/objlst/actor/mtteapotboss_stunr1.bin"
OBJLst_Act_MtTeapotBoss_DeadR1: INCBIN "data/objlst/actor/mtteapotboss_deadr1.bin"
GFX_Act_MtTeapotBoss: INCBIN "data/gfx/actor/mtteapotboss.bin"

; =============== ActInit_SherbetLandBoss ===============
ActInit_SherbetLandBoss:
	; Setup collision box
	ld   a, -$18
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_SherbetLandBoss
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_SherbetLandBoss_WalkL
	call ActS_SetOBJLstPtr
	
	; Set OBJLst shared table
	pop  bc
	ld   bc, OBJLstSharedPtrTable_Act_SherbetLandBoss
	call ActS_SetOBJLstSharedTablePtr
	
	xor  a
	ld   [sActSetTimer], a
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSetColiType], a
	call Act_SherbetLandBoss_SetIntro
	xor  a
	ld   [sActSherbetLandBossHatStatus], a
	ld   a, $B4					; Freeze player during boss intro
	ld   [sPlFreezeTimer], a
	ret
	
; =============== Act_SherbetLandBoss ===============
Act_SherbetLandBoss:
	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	; Copy over coords & direction for the hat, to make sure it is kept in sync
	ld   a, [sActSetX_Low]
	ld   [sActSherbetLandBossX_Low], a
	ld   a, [sActSetX_High]
	ld   [sActSherbetLandBossX_High], a
	ld   a, [sActSetY_Low]
	ld   [sActSherbetLandBossY_Low], a
	ld   a, [sActSetY_High]
	ld   [sActSherbetLandBossY_High], a
	ld   a, [sActSetDir]
	ld   [sActSherbetLandBossDir], a
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_SherbetLandBoss_Main
	dw Act_SherbetLandBoss_Main
	dw Act_SherbetLandBoss_OnStunAbove
	dw Act_SherbetLandBoss_Main
	dw Act_SherbetLandBoss_Main
	dw .onHit
	dw Act_SherbetLandBoss_Main;X
	dw Act_SherbetLandBoss_Main
	dw .onHit
; =============== .onHit ===============
; Handler for bumping into the boss which doesn't damage him, but gets rid of the spike hat.
.onHit:
	ld   a, [sActSherbetLandBossHatStatus]
	or   a								; Is the spike hat already removed?
	jr   z, Act_SherbetLandBoss_Main	; If so, skip
	ld   a, SLBOSSHAT_DROP				; Otherwise, make it drop
	ld   [sActSherbetLandBossHatStatus], a
	
; =============== Act_SherbetLandBoss_Main ===============
Act_SherbetLandBoss_Main:
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_SherbetLandBoss_IntroJump
	dw Act_SherbetLandBoss_IntroPause
	dw Act_SherbetLandBoss_Pause
	dw Act_SherbetLandBoss_Move
	dw Act_SherbetLandBoss_Attack
	dw Act_SherbetLandBoss_Hit
	dw Act_SherbetLandBoss_HitPause
	dw Act_SherbetLandBoss_JumpDown
	dw Act_SherbetLandBoss_JumpUp
	dw Act_SherbetLandBoss_Dead
	dw Act_SherbetLandBoss_Turn
	
; =============== Act_SherbetLandBoss_SetIntro ===============
; Prepares the intro cutscene for this boss.
; This makes the boss jump out of water
Act_SherbetLandBoss_SetIntro:
	xor  a
	ld   [sActLocalRoutineId], a
	
	; Set fast jump speed at 7px/frame
	mActSetYSpeed -$07			
	
	; Move 5 blocks below, to start from off-screen
	ld   a, [sActSetY_Low]		; HL = sActSetY
	ld   l, a
	ld   a, [sActSetY_High]
	ld   h, a					
	ld   bc, $50				; sActSetY += $50
	add  hl, bc
	ld   a, l					; Save back
	ld   [sActSetY_Low], a
	ld   a, h
	ld   [sActSetY_High], a
	
	; Making the actor face left, since we're on the right side
	push bc
	ld   bc, OBJLstPtrTable_Act_SherbetLandBoss_JumpIntroL
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, DIR_L
	ld   [sActSetDir], a
	
	;--
	; [TCRF] This would make the boss face right if he were to spawn on the left side of the screen.
	;        Except we're in the intro cutscene, and he always spawns on the right side of the screen.
	ld   a, [sActSetRelX]
	cp   a, $50					; On the right side? (X >= $50)
	ret  nc						; If so, return
	;--
	; [TCRF] Unreachable code below
	push bc
	ld   bc, OBJLstPtrTable_Act_SherbetLandBoss_Unused_JumpIntroR
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, DIR_R
	ld   [sActSetDir], a
	ret
	;--
	
; =============== Act_SherbetLandBoss_IntroJump ===============
; Handles the jump from off-screen for the intro.
; This mode ends once the boss lands on solid ground.
Act_SherbetLandBoss_IntroJump:
	; Handle jump speed
	call ActS_FallDownMax4Speed
	
	; If we're still moving up, don't bother checking for solid ground
	ld   a, [sActSetYSpeed_High]
	bit  7, a							
	ret  nz
	
	; Once we're moving down, check if we're over solid ground.
	; If so, switch to the next mode.
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, .endMode
	ret
.endMode:
	ld   a, SLBOSS_RTN_INTROPAUSE
	ld   [sActLocalRoutineId], a
	ld   a, $78								; Stay in next mode for $78 frames
	ld   [sActSherbetLandBossModeTimer], a
	
	; Set anim & damaging side depending on direction
	; ...through we can't collide with the boss yet.
	push bc
	ld   bc, OBJLstPtrTable_Act_SherbetLandBoss_AttackL			; Face left
	call ActS_SetOBJLstPtr
	pop  bc
	
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	;--
	; [TCRF] This mode is only called during the intro, so the actor is always facing left.
	;        This check always fails.
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	ret  z						; If not, jump
	
	; Unreachable code below
	push bc
	ld   bc, OBJLstPtrTable_Act_SherbetLandBoss_AttackR			; Face left
	call ActS_SetOBJLstPtr
	pop  bc
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	;--
	ret
	
; =============== Act_SherbetLandBoss_IntroPause ===============
; Pauses for $78 frames.
Act_SherbetLandBoss_IntroPause:
	call ActS_IncOBJLstIdEvery8
	; Handle timer
	ld   a, [sActSherbetLandBossModeTimer]
	dec  a
	ld   [sActSherbetLandBossModeTimer], a
	or   a
	jr   z, Act_SherbetLandBoss_SwitchToPause
	
	; Every $10 frames play sfx
	ld   a, [sActSetTimer]
	and  a, $0F
	ret  nz
	ld   a, SFX4_15
	ld   [sSFX4Set], a
	ret
	
; =============== Act_SherbetLandBoss_SwitchToPause ===============
; Starts the main mode cycle (pausing, then walking).
Act_SherbetLandBoss_SwitchToPause:
	ld   a, SLBOSS_RTN_PAUSE
	ld   [sActLocalRoutineId], a
	ld   a, $3C
	ld   [sActSherbetLandBossModeTimer], a
	
	; Hard bump the player when touching the front of the actor.
	
	; right
	push bc
	ld   bc, OBJLstPtrTable_Act_SherbetLandBoss_WalkL
	call ActS_SetOBJLstPtr
	pop  bc
	mActColiMask ACTCOLI_NORM, ACTCOLI_BUMP, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	ret  z						; If not, return
	
	; left
	push bc
	ld   bc, OBJLstPtrTable_Act_SherbetLandBoss_WalkR
	call ActS_SetOBJLstPtr
	pop  bc
	mActColiMask ACTCOLI_BUMP, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_SherbetLandBoss_Pause ===============
; Pauses for $3C frames.
Act_SherbetLandBoss_Pause:
	call ActS_IncOBJLstIdEvery8
	; Handle the timer
	ld   a, [sActSherbetLandBossModeTimer]
	dec  a
	ld   [sActSherbetLandBossModeTimer], a
	or   a
	jr   z, Act_SherbetLandBoss_SwitchToMove
	ret
	
	
; =============== Act_SherbetLandBoss_SwitchToTurn ===============
Act_SherbetLandBoss_SwitchToTurn:
	ld   a, SLBOSS_RTN_TURN
	ld   [sActLocalRoutineId], a
	ld   a, $3C
	ld   [sActSherbetLandBossModeTimer], a
	ret
; =============== Act_SherbetLandBoss_SwitchToTurn ===============
; Makes the actor delay for $3C frames before turning around.
Act_SherbetLandBoss_Turn:
	call ActS_IncOBJLstIdEvery8
	; Handle the delay
	ld   a, [sActSherbetLandBossModeTimer]
	dec  a
	ld   [sActSherbetLandBossModeTimer], a
	or   a
	ret  nz
	; Then turn direction (and wait for further $3C frames before walking again)
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	jr   Act_SherbetLandBoss_SwitchToPause
	
	
; =============== Act_SherbetLandBoss_SwitchToMove ===============
Act_SherbetLandBoss_SwitchToMove:
	ld   a, SLBOSS_RTN_MOVE
	ld   [sActLocalRoutineId], a
	ld   a, $28
	ld   [sActSherbetLandBossModeTimer], a
	
	; Hard bump the player when touching the front of the actor.
	
	;--
	; left
	push bc
	ld   bc, OBJLstPtrTable_Act_SherbetLandBoss_WalkL
	call ActS_SetOBJLstPtr
	pop  bc
	mActColiMask ACTCOLI_NORM, ACTCOLI_BUMP, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	;--
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	ret  z						; If not, return
	;--
	; right
	push bc
	ld   bc, OBJLstPtrTable_Act_SherbetLandBoss_WalkR
	call ActS_SetOBJLstPtr
	pop  bc
	mActColiMask ACTCOLI_BUMP, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_SherbetLandBoss_Move ===============
; Moves the actor forwards for $28 frames.
Act_SherbetLandBoss_Move:
	; Handle timer
	ld   a, [sActSherbetLandBossModeTimer]
	dec  a
	ld   [sActSherbetLandBossModeTimer], a
	or   a
	jp   z, .endMode
	
	call ActS_IncOBJLstIdEvery8
	; Handle horizontal movement
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, .moveRight
	bit  DIRB_L, a
	jr   nz, .moveLeft
	ret ; We never get here
	
; =============== .moveRight ===============
; Moves the actor right 1px.
.moveRight:
	; If there's no solid ground in front, turn
	call ActColi_GetBlockId_BottomR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, .turn
	; If there's a solid block in the way, turn
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, .turn
	
	; Otherwise move right
	ld   bc, +$01
	call ActS_MoveRight
	ret
	
; =============== .moveLeft ===============
; Moves the actor left 1px.
.moveLeft:
	; If there's no solid ground in front, turn
	call ActColi_GetBlockId_BottomL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, .turn
	; If there's a solid block in the way, turn
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, .turn
	
	; Otherwise move left
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
; =============== .turn ===============
; Switches to the (separate) turn mode.
.turn:
	jp   Act_SherbetLandBoss_SwitchToTurn
	
; =============== .endMode ===============
.endMode:
	ld   a, SLBOSS_RTN_ATTACK
	ld   [sActLocalRoutineId], a
	ld   a, $14
	ld   [sActSherbetLandBossModeTimer], a
	
	; Cause damage when touching the front of the actor, since this is the boxing glove mode.
	;
	; This is also (in practice) the only mode where touching the front of the actor deals damage,
	; in the other two modes it simply hard bumps the player.
	
	; left
	push bc
	ld   bc, OBJLstPtrTable_Act_SherbetLandBoss_AttackL
	call ActS_SetOBJLstPtr
	pop  bc
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	;--
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	ret  z						; If not, return
	;--
	; right
	push bc
	ld   bc, OBJLstPtrTable_Act_SherbetLandBoss_AttackR
	call ActS_SetOBJLstPtr
	pop  bc
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_SherbetLandBoss_Attack ===============
; "Boxing" attack mode.
Act_SherbetLandBoss_Attack:
	call ActS_IncOBJLstIdEvery8
	; Handle timer
	ld   a, [sActSherbetLandBossModeTimer]
	dec  a
	ld   [sActSherbetLandBossModeTimer], a
	or   a
	jp   z, Act_SherbetLandBoss_SwitchToMove
	
	; Every $10 frames play attack SFX
	ld   a, [sActSetTimer]
	and  a, $0F
	ret  nz
	ld   a, SFX4_15
	ld   [sSFX4Set], a
	ret
	
; =============== Act_SherbetLandBoss_OnStunAbove_NoDamage ===============
Act_SherbetLandBoss_OnStunAbove_NoDamage:
	call Pl_ActHurt
	ret
; =============== Act_SherbetLandBoss_OnStunAbove ===============
; Handles what happens when the boss is jumped on.
Act_SherbetLandBoss_OnStunAbove:

	; Even if the player somehow hits the boss without taking damage from the hat,
	; deal damage to the player anyway instead.
	; In practice we only get here when invulnerable after taking damage,
	; so it just ends up not dealing damage to the boss.
	ld   a, [sActSherbetLandBossHatStatus]
	or   a												; Is the hat on?
	jp   nz, Act_SherbetLandBoss_OnStunAbove_NoDamage	; If so, jump
	
	; If the boss isn't in the normal walk cycle (modes $02-$04, $0A), don't deal damage.
	ld   a, [sActLocalRoutineId]
	;--
	cp   a, SLBOSS_RTN_TURN					; Is the boss turning?
	jr   z, .setDamage						; If so, skip
	;--
	cp   a, $02								; Mode < $02?
	ret  c									; If so, ignore the hit
	cp   a, $05								; Mode >= $05?
	ret  nc									; If so
.setDamage:
	xor  a
	ld   [sActSetColiType], a
	ld   a, SFX1_2C
	ld   [sSFX1Set], a
	
	ld   a, [sActSherbetLandBossHitCount]	; Register the hit
	inc  a
	ld   [sActSherbetLandBossHitCount], a
	cp   a, $03								; Was the boss hit 3 times?
	jp   nc, Act_SherbetLandBoss_SetDead	; If so, kill it
	; Otherwise
	call SubCall_ActS_SpawnStunStar			; Show circling stars
	ld   a, SLBOSS_RTN_HIT
	ld   [sActLocalRoutineId], a
	ld   a, $1E
	ld   [sActSherbetLandBossModeTimer], a
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_SherbetLandBoss_HitL, OBJLstPtrTable_Act_SherbetLandBoss_HitR	; Set hurt anim
	ret
	
; =============== Act_SherbetLandBoss_Hit ===============
; Stays stunned for $1E frames, when taking damage.
Act_SherbetLandBoss_Hit:
	; Handle the timer
	ld   a, [sActSherbetLandBossModeTimer]
	dec  a
	ld   [sActSherbetLandBossModeTimer], a
	or   a
	ret  nz
	
	jp   .endMode
.endMode:
	ld   a, SLBOSS_RTN_HITPAUSE
	ld   [sActLocalRoutineId], a
	ld   a, $3C
	ld   [sActSherbetLandBossModeTimer], a
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_SherbetLandBoss_StandL, OBJLstPtrTable_Act_SherbetLandBoss_StandR
	ret
	
; =============== Act_SherbetLandBoss_HitPause ===============
; Pauses for $3C frames after taking damage.
Act_SherbetLandBoss_HitPause:
	; Handle the timer
	ld   a, [sActSherbetLandBossModeTimer]
	dec  a
	ld   [sActSherbetLandBossModeTimer], a
	or   a
	jr   z, .endMode
	ret
.endMode:
	ld   a, SLBOSS_RTN_JUMPDOWN
	ld   [sActLocalRoutineId], a
	mActSetYSpeed -$03
	ld   a, SFX1_29
	ld   [sSFX1Set], a
	ret
	
; =============== Act_SherbetLandBoss_JumpDown ===============
; Jumps back underwater.
Act_SherbetLandBoss_JumpDown:
	call ActS_FallDownMax4Speed		; Move down
	ld   a, [sActSetRelY]
	cp   a, $D0						; Are we off-screen now?
	jr   nc, .endMode				; If so, switch to the next mode
	ret
.endMode:
	; Set upwards jump
	ld   a, SLBOSS_RTN_JUMPUP
	ld   [sActLocalRoutineId], a
	mActSetYSpeed -$07
	ld   a, $3C
	ld   [sActSherbetLandBossModeTimer], a
	call Act_SherbetLandBoss_SpawnHat	; Spawn the spiky helmet
	ret
	
; =============== Act_SherbetLandBoss_JumpUp ===============
; Jumps from underwater, with a spiky helmet on.
Act_SherbetLandBoss_JumpUp:
	; Wait for $3C frames before jumping
	ld   a, [sActSherbetLandBossModeTimer]
	or   a
	jr   z, .doJump
	dec  a
	ld   [sActSherbetLandBossModeTimer], a
	
	or   a				; Did the timer just elapse?
	ret  nz				; If not, return
	ld   a, SFX1_31		; Otherwise, set waterjump SFX
	ld   [sSFX1Set], a
	ret
	
.doJump:
	call ActS_FallDownMax4Speed			; Handle jump speed
	; Check for landing on ground
	ld   a, [sActSetYSpeed_High]
	bit  7, a							; Are we moving up?			
	ret  nz								; If so, don't check for ground coli
	
	; Otherwise, if we're moving down and we're on a solid block,
	; return to the main walk mode.
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jp   nz, Act_SherbetLandBoss_SwitchToMove
	ret
	
; =============== Act_SherbetLandBoss_SetDead ===============
; Switches to the "Boss Defeated" routine, after the boss is hit 3 times.
Act_SherbetLandBoss_SetDead:
	xor  a									; Make intangible
	ld   [sActSetColiType], a
	ld   a, SLBOSS_RTN_DEAD
	ld   [sActLocalRoutineId], a
	mActSetYSpeed -$04						; Prepare jump death
	xor  a
	ld   [sActSherbetLandBossModeTimer], a
	ld   a, SFX1_09
	ld   [sSFX1Set], a
	ld   a, BGM_NONE
	ld   [sBGMSet], a
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_SherbetLandBoss_DeadL, OBJLstPtrTable_Act_SherbetLandBoss_DeadR
	ret
	
; =============== Act_SherbetLandBoss_Dead ===============
; Boss defeated routine and life game, special to this boss.
Act_SherbetLandBoss_Dead:
	call ActS_IncOBJLstIdEvery8
	
	ld   a, [sActSherbetLandBossHeartGameStarted]
	or   a						; Is the coin game started already?
	jr   nz, .heartGame			; If so, jump
	
	call ActS_FallDownMax4Speed
	
	; When the boss goes fully off-screen, start the coin game.
	ld   a, [sActSetRelY]
	cp   a, $D0					; YPos < $D0?
	ret  c						; If so, return
.startHeartGame:
	ld   a, $01
	ld   [sActSherbetLandBossHeartGameStarted], a
	ld   a, BGM_COINGAME
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	mSubCall LoadGFX_Act_BigHeart ; BANK $0F
	ret
.heartGame:
	call SubCall_ActS_HeartGame
	ret
	
OBJLstSharedPtrTable_Act_SherbetLandBoss:
	dw OBJLstPtrTable_Act_SherbetLandBoss_DeadL;X
	dw OBJLstPtrTable_Act_SherbetLandBoss_DeadR;X
	dw OBJLstPtrTable_Act_SherbetLandBoss_DeadL;X
	dw OBJLstPtrTable_Act_SherbetLandBoss_DeadR;X
	dw OBJLstPtrTable_Act_SherbetLandBoss_DeadL;X
	dw OBJLstPtrTable_Act_SherbetLandBoss_DeadR;X
	dw OBJLstPtrTable_Act_SherbetLandBoss_DeadL;X
	dw OBJLstPtrTable_Act_SherbetLandBoss_DeadR;X

OBJLstPtrTable_Act_SherbetLandBoss_WalkL:
	dw OBJLst_Act_SherbetLandBoss_WalkL0
	dw OBJLst_Act_SherbetLandBoss_WalkL1
	dw OBJLst_Act_SherbetLandBoss_WalkL0
	dw OBJLst_Act_SherbetLandBoss_WalkL2
	dw $0000
OBJLstPtrTable_Act_SherbetLandBoss_WalkR:
	dw OBJLst_Act_SherbetLandBoss_WalkR0
	dw OBJLst_Act_SherbetLandBoss_WalkR1
	dw OBJLst_Act_SherbetLandBoss_WalkR0
	dw OBJLst_Act_SherbetLandBoss_WalkR2
	dw $0000
OBJLstPtrTable_Act_SherbetLandBoss_DeadL:
	dw OBJLst_Act_SherbetLandBoss_DeadL0
	dw OBJLst_Act_SherbetLandBoss_DeadL1
	dw $0000
OBJLstPtrTable_Act_SherbetLandBoss_DeadR:
	dw OBJLst_Act_SherbetLandBoss_DeadR0
	dw OBJLst_Act_SherbetLandBoss_DeadR1
	dw $0000
OBJLstPtrTable_Act_SherbetLandBoss_JumpIntroL:
	dw OBJLst_Act_SherbetLandBoss_JumpL
	dw $0000;X
; [TCRF] The intro plays on one side only, so it goes unused.
;		 This *should* have been used for other jumps (JUMPUP), but the standing anim got used instead...
OBJLstPtrTable_Act_SherbetLandBoss_Unused_JumpIntroR:
	dw OBJLst_Act_SherbetLandBoss_Unused_JumpR;X
	dw $0000;X
OBJLstPtrTable_Act_SherbetLandBoss_AttackL:
	dw OBJLst_Act_SherbetLandBoss_WalkL0
	dw OBJLst_Act_SherbetLandBoss_AttackL0
	dw OBJLst_Act_SherbetLandBoss_WalkL0
	dw OBJLst_Act_SherbetLandBoss_AttackL1
	dw $0000
OBJLstPtrTable_Act_SherbetLandBoss_AttackR:
	dw OBJLst_Act_SherbetLandBoss_WalkR0
	dw OBJLst_Act_SherbetLandBoss_AttackR0
	dw OBJLst_Act_SherbetLandBoss_WalkR0
	dw OBJLst_Act_SherbetLandBoss_AttackR1
	dw $0000;X
OBJLstPtrTable_Act_SherbetLandBoss_HitL:
	dw OBJLst_Act_SherbetLandBoss_HitL
	dw $0000;X
OBJLstPtrTable_Act_SherbetLandBoss_HitR:
	dw OBJLst_Act_SherbetLandBoss_HitR
	dw $0000;X
OBJLstPtrTable_Act_SherbetLandBoss_StandL:
	dw OBJLst_Act_SherbetLandBoss_StandL
	dw $0000;X
OBJLstPtrTable_Act_SherbetLandBoss_StandR:
	dw OBJLst_Act_SherbetLandBoss_StandR
	dw $0000;X

OBJLst_Act_SherbetLandBoss_WalkL0: INCBIN "data/objlst/actor/sherbetlandboss_walkl0.bin"
OBJLst_Act_SherbetLandBoss_WalkL1: INCBIN "data/objlst/actor/sherbetlandboss_walkl1.bin"
OBJLst_Act_SherbetLandBoss_WalkL2: INCBIN "data/objlst/actor/sherbetlandboss_walkl2.bin"
OBJLst_Act_SherbetLandBoss_JumpL: INCBIN "data/objlst/actor/sherbetlandboss_jumpl.bin"
OBJLst_Act_SherbetLandBoss_AttackL0: INCBIN "data/objlst/actor/sherbetlandboss_attackl0.bin"
OBJLst_Act_SherbetLandBoss_AttackL1: INCBIN "data/objlst/actor/sherbetlandboss_attackl1.bin"
OBJLst_Act_SherbetLandBoss_HitL: INCBIN "data/objlst/actor/sherbetlandboss_hitl.bin"
OBJLst_Act_SherbetLandBoss_DeadL0: INCBIN "data/objlst/actor/sherbetlandboss_deadl0.bin"
OBJLst_Act_SherbetLandBoss_DeadL1: INCBIN "data/objlst/actor/sherbetlandboss_deadl1.bin"
OBJLst_Act_SherbetLandBoss_StandL: INCBIN "data/objlst/actor/sherbetlandboss_standl.bin"
; [TCRF] Unreferenced sprite mappings pointing to unused GFX.
;        This is for a vertical puff smoke.
OBJLst_Act_SherbetLandBoss_Unused_SmokeVL0: INCBIN "data/objlst/actor/sherbetlandboss_unused_smokevl0.bin"
OBJLst_Act_SherbetLandBoss_Unused_SmokeVL1: INCBIN "data/objlst/actor/sherbetlandboss_unused_smokevl1.bin"
OBJLst_Act_SherbetLandBoss_Unused_SmokeVL2: INCBIN "data/objlst/actor/sherbetlandboss_unused_smokevl2.bin"
OBJLst_Act_SherbetLandBossHat_L: INCBIN "data/objlst/actor/sherbetlandbosshat_l.bin"
; [TCRF] Mappings for a flashing heart, meant to go with GFX_Act_SherbetLandBoss_Unused_Heart.
;        Since those graphics aren't loaded, it appears as a broken key.
OBJLst_Act_SherbetLandBoss_Unused_HeartL0: INCBIN "data/objlst/actor/sherbetlandboss_unused_heartl0.bin"
OBJLst_Act_SherbetLandBoss_Unused_HeartL1: INCBIN "data/objlst/actor/sherbetlandboss_unused_heartl1.bin"
OBJLst_Act_SherbetLandBoss_WalkR0: INCBIN "data/objlst/actor/sherbetlandboss_walkr0.bin"
OBJLst_Act_SherbetLandBoss_WalkR1: INCBIN "data/objlst/actor/sherbetlandboss_walkr1.bin"
OBJLst_Act_SherbetLandBoss_WalkR2: INCBIN "data/objlst/actor/sherbetlandboss_walkr2.bin"
OBJLst_Act_SherbetLandBoss_Unused_JumpR: INCBIN "data/objlst/actor/sherbetlandboss_unused_jumpr.bin"
OBJLst_Act_SherbetLandBoss_AttackR0: INCBIN "data/objlst/actor/sherbetlandboss_attackr0.bin"
OBJLst_Act_SherbetLandBoss_AttackR1: INCBIN "data/objlst/actor/sherbetlandboss_attackr1.bin"
OBJLst_Act_SherbetLandBoss_HitR: INCBIN "data/objlst/actor/sherbetlandboss_hitr.bin"
OBJLst_Act_SherbetLandBoss_DeadR0: INCBIN "data/objlst/actor/sherbetlandboss_deadr0.bin"
OBJLst_Act_SherbetLandBoss_DeadR1: INCBIN "data/objlst/actor/sherbetlandboss_deadr1.bin"
OBJLst_Act_SherbetLandBoss_StandR: INCBIN "data/objlst/actor/sherbetlandboss_standr.bin"
; [TCRF] Horizontally flipped variations of the above, for whatever reason
OBJLst_Act_SherbetLandBoss_Unused_SmokeVR0: INCBIN "data/objlst/actor/sherbetlandboss_unused_smokevr0.bin"
OBJLst_Act_SherbetLandBoss_Unused_SmokeVR1: INCBIN "data/objlst/actor/sherbetlandboss_unused_smokevr1.bin"
OBJLst_Act_SherbetLandBoss_Unused_SmokeVR2: INCBIN "data/objlst/actor/sherbetlandboss_unused_smokevr2.bin"
OBJLst_Act_SherbetLandBossHat_R: INCBIN "data/objlst/actor/sherbetlandbosshat_r.bin"
OBJLst_Act_SherbetLandBoss_Unused_HeartR0: INCBIN "data/objlst/actor/sherbetlandboss_unused_heartr0.bin"
OBJLst_Act_SherbetLandBoss_Unused_HeartR1: INCBIN "data/objlst/actor/sherbetlandboss_unused_heartr1.bin"
GFX_Act_SherbetLandBoss: INCBIN "data/gfx/actor/sherbetlandboss.bin"
; [TCRF] Unreferenced extra block of tiles, part of the same "archive" as GFX_Act_SherbetLandBoss.
;        ActGroupGFXDef_C19_Room00 does not copy over the last two tiles though.
GFX_Act_SherbetLandBoss_Unused_Heart: INCBIN "data/gfx/actor/sherbetlandboss_unused_heart.bin"
OBJLstPtrTable_Act_SherbetLandBossHat_L:
	dw OBJLst_Act_SherbetLandBossHat_L
	dw $0000
OBJLstPtrTable_Act_SherbetLandBossHat_R:
	dw OBJLst_Act_SherbetLandBossHat_R
	dw $0000

; =============== Act_SherbetLandBoss_SpawnHat ===============
; Spawns the spiky hat on top of the boss.
Act_SherbetLandBoss_SpawnHat:
	;--
	; Not necessary
	ld   a, [sActSherbetLandBossHatStatus]
	or   a						; Is the hat enabled? (just in case)
	ret  nz						; If not, return
	;--
	
	; Find an empty slot
	ld   hl, sAct		; HL = Actor slot area
	ld   d, $05			; D = Total slots
	ld   e, $00			; E = Current slot
.checkSlot:
	ld   a, [hl]		; Read active status
	or   a				; Is the slot marked as active?
	jr   z, .slotFound	; If not, we found a slot
.nextSlot:
	inc  e				; Slot++
	dec  d				; Have we searched in all 5 slots?
	ret  z				; If so, return
	ld   a, l			; Move to next slot (HL += $20)
	add  (sActSet_End-sActSet)
	ld   l, a
	jr   .checkSlot
	
.slotFound:
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_SherbetLandBossHat
	
	ld   a, $02				; Enabled
	ldi  [hl], a
	ld   a, [sActSetX_Low]	; X = sActSetX
	ldi  [hl], a
	ld   a, [sActSetX_High]
	ldi  [hl], a
	ld   a, [sActSetY_Low]	; Y = sActSetY
	ldi  [hl], a
	ld   a, [sActSetY_High]
	ldi  [hl], a
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ldi  [hl], a
	
	; This collision box for this is very misleading. It's much larger than you would think it is.
	; It's even larger than the boss itself(!), which means you can get damaged if you get
	; bumped upwards by the boss.
	
	ld   a, -$18	; Coli box U
	ldi  [hl], a
	ld   a, -$10	; Coli box D
	ldi  [hl], a
	ld   a, -$0C	; Coli box L
	ldi  [hl], a
	ld   a, +$0C	; Coli box R
	ldi  [hl], a
	
	ld   a, [sActSetRelY]	; Rel.Y (Origin)
	ldi  [hl], a
	ld   a, [sActSetRelX]	; Rel.X (Origin)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstPtrTable_Act_None)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_None)
	ldi  [hl], a
	
	ld   a, [sActSetDir]	; Dir
	ldi  [hl], a
	xor  a					; OBJLst ID
	ldi  [hl], a
	
	ld   a, [sActSetId]		; Actor ID (same as parent)
	set  ACTB_NORESPAWN, a	; Don't make it respawn
	ldi  [hl], a
	
	xor  a					; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_SherbetLandBossHat)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_SherbetLandBossHat)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	ldi  [hl], a				; Timer 3
	ldi  [hl], a				; Timer 4
	ldi  [hl], a				; Timer 5
	ldi  [hl], a				; Timer 6
	ldi  [hl], a				; Timer 7
	ld   a, $01					; Flags
	ldi  [hl], a
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	ld   a, LOW(OBJLstSharedPtrTable_Act_SherbetLandBossHat)
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_SherbetLandBossHat)
	ld   [hl], a
	ld   a, SLBOSSHAT_YES		; Set hat on
	ld   [sActSherbetLandBossHatStatus], a
	ret
OBJLstSharedPtrTable_Act_SherbetLandBossHat:
	dw OBJLstPtrTable_Act_SherbetLandBossHat_L;X
	dw OBJLstPtrTable_Act_SherbetLandBossHat_R;X
	dw OBJLstPtrTable_Act_SherbetLandBossHat_L;X
	dw OBJLstPtrTable_Act_SherbetLandBossHat_R;X
	dw OBJLstPtrTable_Act_SherbetLandBossHat_L
	dw OBJLstPtrTable_Act_SherbetLandBossHat_R
	dw OBJLstPtrTable_Act_SherbetLandBossHat_L;X
	dw OBJLstPtrTable_Act_SherbetLandBossHat_R;X
; =============== Act_SherbetLandBossHat ===============
Act_SherbetLandBossHat:
	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActSherbetLandBossHatStatus]
	cp   a, SLBOSSHAT_DROP	; Hat drop triggered?
	jr   z, .setDead		; If so, jump
	
	; Sync with the boss' position, bobbing up by 1px every so often.
	
	; ActX = BossX
	ld   a, [sActSherbetLandBossX_Low]
	ld   [sActSetX_Low], a
	ld   a, [sActSherbetLandBossX_High]
	ld   [sActSetX_High], a
	; ActY = BossY - $10
	ld   a, [sActSherbetLandBossY_Low]
	sub  a, $10
	ld   [sActSetY_Low], a
	ld   a, [sActSherbetLandBossY_High]
	sbc  a, $00
	ld   [sActSetY_High], a
	
	; Every 8 frames alternate between moving up an extra 1 or 0 px
	ld   a, [sActSetTimer]
	and  a, $08
	call z, .useYOffset
	
	; Depending on the direction the boss' facing, pick a different ani,
	ld   a, [sActSherbetLandBossDir]
	bit  DIRB_R, a						; Facing right?
	jr   nz, .animR					; If so, jump
.animL:
	push bc
	ld   bc, OBJLstPtrTable_Act_SherbetLandBossHat_L
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.animR:
	push bc
	ld   bc, OBJLstPtrTable_Act_SherbetLandBossHat_R
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.useYOffset:
	ld   bc, -$01
	call ActS_MoveDown
	ret
; =============== .setDead ===============
; Marks the hat jump into offscreen.
.setDead:
	xor  a
	ld   [sActSherbetLandBossHatStatus], a
	jp   SubCall_ActS_StartJumpDead
	
; =============== ActInit_Mole ===============
; A mole carrying a spiked ball.
; See also: Act_Wolf
ActInit_Mole:
	; Setup collision box
	ld   a, -$14
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$06
	ld   [sActSetColiBoxL], a
	ld   a, +$06
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Mole
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_Mole_MoveL
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Mole
	call ActS_SetOBJLstSharedTablePtr
	
	; The mole itself is fully safe to touch
	mActColiMask ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	xor  a
	ld   [sActSetTimer], a
	ld   [sActMoleModeTimer], a
	ld   [sActMoleThrowDelay], a
	ld   [sActMoleYSpeed], a
	ld   [sActLocalRoutineId], a
	ld   [sActMoleSpikeAction], a
	ld   a, $28
	ld   [sActMoleMoveDelay], a
	ret
	
; =============== Act_Mole ===============
Act_Mole:
	; If the actor is overlapping with a solid block, kill it
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolid
	or   a
	jp   nz, SubCall_ActS_StartJumpDead
	
	; [BUG] Due to the way despawning actors works, it's possible to despawn the
	;       spike actor with sActMoleSpikeAction not being reset.
	;       A separate "no despawn on off-screen" actor flag would be needed to fix
	;       this, which would simply hide the actor and disable the collision.
	
	; Do we need to spawn the projectile?
	ld   a, [sActMoleSpikeAction]
	or   a							; Is the action defined yet?
	call z, Act_Mole_SpawnSpike		; If not, call
	
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Mole_Main
	dw .onPlColiH
	dw .onPlColiTop
	dw .starKill
	dw .onPlColiBelow
	dw .onPlColiBelow ; Heavy actor isn't dash-killed immediately
	dw Act_Mole_Walk;X
	dw Act_Mole_Walk;X
	dw .onJumpDead
	
; For all of these, we're signaling the spike projectile to kill itself
; (setting its mode to $03)
.starKill:
	ld   a, MOS_MODE_DESPAWN
	ld   [sActMoleSpikeAction], a
	jp   SubCall_ActS_StartStarKill
.onPlColiH:
	call SubCall_ActS_SpawnStunStar
	ld   a, MOS_MODE_DESPAWN
	ld   [sActMoleSpikeAction], a
	jp   SubCall_ActS_OnPlColiH
.onPlColiTop:
	call SubCall_ActS_SpawnStunStar
	ld   a, MOS_MODE_DESPAWN
	ld   [sActMoleSpikeAction], a
	jp   SubCall_ActS_OnPlColiTop
.onPlColiBelow:
	call SubCall_ActS_SpawnStunStar
	ld   a, MOS_MODE_DESPAWN
	ld   [sActMoleSpikeAction], a
	jp   SubCall_ActS_OnPlColiBelow
.onJumpDead:
	ld   a, MOS_MODE_DESPAWN
	ld   [sActMoleSpikeAction], a
	jp   SubCall_ActS_StartJumpDeadSameColi
Act_Mole_OnScreenShake:
	ld   a, MOS_MODE_DESPAWN
	ld   [sActMoleSpikeAction], a
	jp   SubCall_ActS_StartGroundPoundStun
	
Act_Mole_Main:
	; If the screen is shaking, stun the actor
	ld   a, [sScreenShakeTimer]
	or   a
	jr   nz, Act_Mole_OnScreenShake
	
	;--
	;
	; If the actor isn't on solid ground, make it fall down at increasing speed 
	;
.doYSpeed:
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is the actor on solid ground?
	jr   nz, .resetYSpeed				; If so, reset the vertical speed
	
	; The speed value can only be positive here
	ld   a, [sActMoleYSpeed]	; BC = sActMoleYSpeed
	ld   c, a
	ld   b, $00
	call ActS_MoveDown			; Move down by that
	
	; Every 4 frames increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $03
	jr   nz, .chkRtn			
	ld   a, [sActMoleYSpeed]
	inc  a
	ld   [sActMoleYSpeed], a
	
	jr   .chkRtn
.resetYSpeed:
	xor  a
	ld   [sActMoleYSpeed], a
	;--
	
.chkRtn:
	; Check for the delay before moving
	ld   a, [sActMoleMoveDelay]
	or   a							; Is the actor waiting to move?
	jr   nz, Act_Mole_WaitMove				; If so, continue to wait
	
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_Mole_Walk
	dw Act_Mole_Walk;X
	dw Act_Mole_Walk;X
	dw Act_Mole_ThrowSpike
	dw Act_Mole_PostThrowWait
	
; =============== Act_Mole_WaitMove ===============
; Handles the delay before moving.
Act_Mole_WaitMove:
	ld   a, [sActMoleMoveDelay]		; Timer--
	dec  a
	ld   [sActMoleMoveDelay], a
	or   a							; Has it elapsed?
	ret  nz							; If not, return
	; Prepare for movement next frame
	ld   a, $28						; Otherwise, set the cooldown timer
	ld   [sActMoleThrowDelay], a
	ret
	
; =============== Act_Mole_Walk ===============	
Act_Mole_Walk:
	; Check for the delay before the actor can move again
	ld   a, [sActMoleTurnDelay]
	or   a
	jp   nz, Act_Mole_WaitTurn
	
	call ActS_IncOBJLstIdEvery8
	
	; Move depending on the actor's direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_Mole_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_Mole_MoveLeft
	
	; Handle cooldown timer for throwing the spike
	ld   a, [sActMoleThrowDelay]
	or   a							; Has the cooldown timer elapsed yet?
	jr   z, Act_Mole_CheckPlPos		; If so, try to throw the spike
	dec  a							; Otherwise, decrement it
	ld   [sActMoleThrowDelay], a
	ret
	
; =============== Act_Mole_CheckPlPos ===============	
; Determines if the player is in the range of the actor, and if so, shoots the spike.
Act_Mole_CheckPlPos:
	; Identical rules to Act_Wolf_CheckPlPos.

	;
	; VERTICAL RANGE
	;
	
	ld   a, [sActSetRelY]	; D = Actor Y pos
	ld   d, a
	ld   a, [sPlYRel]		; A = Player Y pos
	sub  a, d				; Check locs
	
	; Avoid comparing negative numbers, so convert to positive when needed
	bit  7, a				; Is the player below the actor? (MSB clear)
	jr   z, .chkRangeD			; If so, jump
	cpl
.chkRangeU:
	cp   a, $39-$01			; Is the player less than $39 pixels above the actor?
	ret  nc					; If not, return
	jr   .doHRange
.chkRangeD:
	cp   a, $38				; Is the player less than $38 pixels below the actor?
	ret  nc					; If not, return
	
	;
	; HORIZONTAL RANGE
	;
.doHRange:
	ld   a, [sActSetRelX]	; D = Actor X pos
	ld   d, a
	ld   a, [sPlXRel]		; E = Player X pos
	ld   e, a
	
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Is the actor facing right?
	jr   nz, .chkRangeR		; If so, jump
.chkRangeL:
	ld   a, d				; A = Actor X pos
	cp   e					; Is ActX > PlX?
	jp   nc, Act_Mole_SwitchToThrow	; If so, jump
	ret
.chkRangeR:
	ld   a, d				; If so, jump
	cp   e					; Is ActX < PlX?
	jp   c, Act_Mole_SwitchToThrow	; If so, jump
	ret
	
; =============== Act_Mole_WaitTurn ===============
; Turns the actor once the turn timer elapses.
; IN
; - A: Must be sActMoleTurnDelay.
Act_Mole_WaitTurn:
	; Wait for the timer to elapse
	dec  a							; sActMoleTurnDelay--
	or   a							; Did the timer elapse?
	ld   [sActMoleTurnDelay], a		; (Save back value)
	ret  nz							; If not, return
	
	; Wait $28 frames before moving again
	ld   a, $28
	ld   [sActMoleMoveDelay], a
	
	; Now we can turn.
	ld   a, [sActSetDir]
	xor  DIR_L|DIR_R
	ld   [sActSetDir], a
	
	; Depending on the new direction, set the animation.
	bit  DIRB_R, a			; Facing right?
	jr   nz, .dirR			; If so, jump
.dirL:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Mole_MoveL
	ret
.dirR:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Mole_MoveR
	ret
	
; =============== Act_Mole_SetTurnDelay ===============
; Makes the actor delay for $14 frames before turning.
Act_Mole_SetTurnDelay:
	ld   a, $14						; Wait $14 before turning
	ld   [sActMoleTurnDelay], a
	ret
	
; =============== Act_Mole_MoveLeft ===============
; Moves the actor to the left.
Act_Mole_MoveLeft:
	; If there's any solid block in the way, delay for a bit before turning
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, Act_Mole_SetTurnDelay
	
	; If there isn't solid ground on the left, delay for a bit before turning
	call ActColi_GetBlockId_BottomL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, Act_Mole_SetTurnDelay
	
	; Move left 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveRight
	
	ld   a, LOW(OBJLstPtrTable_Act_Mole_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Mole_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Make the actor face left
	ld   a, [sActSetDir]
	and  a, $F8
	or   a, DIR_L
	ld   [sActSetDir], a
	
	ret
	
; =============== Act_Mole_MoveRight ===============
; Moves the actor to the right.
Act_Mole_MoveRight:
	; If there's any solid block in the way, delay for a bit before turning
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, Act_Mole_SetTurnDelay
	
	; If there isn't solid ground on the right, delay for a bit before turning
	call ActColi_GetBlockId_BottomR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, Act_Mole_SetTurnDelay
	
	; Move right 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveRight
	
	ld   a, LOW(OBJLstPtrTable_Act_Mole_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Mole_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Make the actor face right
	ld   a, [sActSetDir]
	and  a, $F8
	or   a, DIR_R
	ld   [sActSetDir], a
	
	ret
	
; =============== Act_Mole_SwitchToThrow ===============
; This subroutine switches to mode MOLE_RTN_ALERT.	
Act_Mole_SwitchToThrow:
	ld   a, MOLE_RTN_THROWKNIFE
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActMoleModeTimer], a
	
	; Pick a different animation and collision type (for the damaging part)
	; depending on the direction faced.
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Is the actor facing right?
	jr   nz, .dirR			; If so, jump
	mActOBJLstPtrTable OBJLstPtrTable_Act_Mole_ThrowL
	ret
.dirR:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Mole_ThrowR
	ret
	
; =============== Act_Mole_ThrowSpike ===============
Act_Mole_ThrowSpike:
	; Switch to the next mode once the animation ends
	ld   a, [sActSetOBJLstId]
	cp   a, $02						; Has the animation ended? (frame >= $02)
	jr   nc, .endMode				; If so, jump
	
	; Animate every $08 frames
	call ActS_IncOBJLstIdEvery8
	ret
	
.endMode:
	
	ld   a, MOLE_RTN_POSTKNIFE
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActMoleModeTimer], a
	
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	; Signal the spike actor to throw itself
	ld   a, MOS_MODE_THROW
	ld   [sActMoleSpikeAction], a
	ld   a, SFX4_15
	ld   [sSFX4Set], a
	ret
	
; =============== Act_Mole_PostThrowWait ===============
Act_Mole_PostThrowWait:
	; Wait for $32 frames before moving again.
	; This is enough time for the spike projectile to return back in hand,
	; with an extra delay as well.
	ld   a, [sActMoleModeTimer]
	cp   a, $32							; Timer reached the target value?
	jr   nc, Act_Mole_SetThrowDelay		; If so, return
	inc  a
	ld   [sActMoleModeTimer], a
	
	; Pick the correct anim depending on the direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	jr   nz, .dirR				; If so, jump
.dirL:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Mole_PostThrowL
	ret
.dirR:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Mole_PostThrowR
	ret
	
; =============== Act_Mole_SetThrowDelay ===============
; Makes the actor stop throwing for $50 frames after starting to move.
Act_Mole_SetThrowDelay:
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActMoleModeTimer], a
	ld   a, $50
	ld   [sActMoleThrowDelay], a
	ret
	
; =============== ActInit_Unused_MoleSpike ===============
; [TCRF] Unreachable init code. Goes unused since this actor is always spawned by another actor.
ActInit_Unused_MoleSpike:
	; Setup collision box
	; [TCRF] This collision box is smaller than the one used in Act_Mole_SpawnSpike
	ld   a, -$04
	ld   [sActSetColiBoxU], a
	ld   a, -$03
	ld   [sActSetColiBoxD], a
	ld   a, -$02
	ld   [sActSetColiBoxL], a
	ld   a, +$01
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_MoleSpike
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_MoleSpike
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_MoleSpike
	call ActS_SetOBJLstSharedTablePtr
	
	; Deal damage on all sides
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	xor  a
	ld   [sActSetTimer], a
	ld   [sActMoleSpikePathIndex], a
	ld   [sActSetTimer3], a
	ld   [sActSetTimer4], a
	ld   [sActMoleSpikeParentSlot], a
	ld   [sActMoleSpikeMode], a
	ld   [sActSetTimer7], a
	ret

; =============== Act_Mole_SpawnSpike ===============
Act_Mole_SpawnSpike:
	; Don't spawn the spike if the actor isn't visible
	ld   a, [sActSet]
	cp   a, $02
	ret  nz
	
	; Find an empty slot
	ld   hl, sAct		; HL = Actor slot area
	ld   d, $05			; D = Total slots
	ld   e, $00			; E = Current slot
.checkSlot:
	ld   a, [hl]		; Read active status
	or   a				; Is the slot marked as active?
	jr   z, .slotFound	; If not, we found a slot
.nextSlot:
	inc  e				; Slot++
	dec  d				; Have we searched in all 5 slots?
	ret  z				; If so, return
	ld   a, l			; Move to next slot (HL += $20)
	add  (sActSet_End-sActSet)
	ld   l, a
	jr   .checkSlot
	
.slotFound:
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_MoleSpike
	
	ld   a, $02				; Enabled
	ldi  [hl], a
	ld   a, [sActSetX_Low]	; X = sActSetX
	ldi  [hl], a
	ld   a, [sActSetX_High]
	ldi  [hl], a
	ld   a, [sActSetY_Low]	; Y = sActSetY
	ldi  [hl], a
	ld   a, [sActSetY_High]
	ldi  [hl], a
	
	; Collision type
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ldi  [hl], a
	
	ld   a, -$05				; Coli box U
	ldi  [hl], a
	ld   a, -$03				; Coli box D
	ldi  [hl], a
	ld   a, -$02				; Coli box L
	ldi  [hl], a
	ld   a, +$02				; Coli box R
	ldi  [hl], a
	
	ld   a, $00
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_None)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_None)
	ldi  [hl], a
	
	ld   a, [sActSetDir]		; Dir
	ldi  [hl], a
	xor  a						; OBJLst ID
	ldi  [hl], a
	
	ld   a, [sActSetId]			; Actor ID
	inc  a						; + 1
	set  ACTB_NORESPAWN, a		; Don't make the spike respawn
	ldi  [hl], a
	
	xor  a						; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_MoleSpike)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_MoleSpike)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	ldi  [hl], a				; Timer 3
	ldi  [hl], a				; Timer 4
	
	; Save the slot number of the parent actor.
	;
	; This child actor needs to read the value of sActMoleSpikeAction,
	; so we can send commands from the parent actor.
	ld   a, [sActNumProc]		
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer 6
	ldi  [hl], a				; Timer 7
	
	ld   a, $01					; Flags
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_MoleSpike)		; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_MoleSpike)
	ldi  [hl], a
	
	ld   a, MOS_MODE_HOLD		; Request arc hold mode
	ld   [sActMoleSpikeAction], a
	ret
	
; =============== Act_MoleSpike ===============
; The spike projectile thrown by Act_Mole.
Act_MoleSpike:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_MoleSpike
	
	;-- 
	; Get ptr to tracked slot, like mActSeekToParentSlot.
	; mActSeekToParentSlot sActMoleSpikeParentSlot
	ld   a, [sActMoleSpikeParentSlot]
	ld   hl, sAct + 0
	ld   d, $00
	and  a, $07
	swap a
	rlca
	ld   e, a
	add  hl, de
	;--
	; HL = Ptr to start of the parent slot
	ldi  a, [hl]
	cp   a, $02					; Is the parent actor visible?
	jp   nz, Act_MoleSpike_Despawn			; If not, delete itself
	
	; Sync over the variables.
	; Doing this means that any path tables or calls to ActS_Move* will have to be relative to this initial value.
	ldi  a, [hl]				; X...
	ld   [sActSetX_Low], a
	ldi  a, [hl]
	ld   [sActSetX_High], a
	ldi  a, [hl]				; Y...
	ld   [sActSetY_Low], a		
	ld   a, [hl]
	ld   [sActSetY_High], a
	ld   de, (sActSetDir-sActSetY_High)	; Seek ahead to direction
	add  hl, de
	ld   a, [hl]				; Direction...
	ld   [sActSetDir], a
	ld   de, (sActMoleSpikeAction-sActSetDir)	; Seek ahead to command id
	add  hl, de
	ld   a, [hl]					; Mode
	ld   [sActMoleSpikeMode], a
	
	; Which mode are we on?
	cp   a, MOS_MODE_HOLD
	jp   z, Act_MoleSpike_Hold
	cp   a, MOS_MODE_THROW
	jr   z, Act_MoleSpike_Throw
	cp   a, MOS_MODE_DESPAWN
	jp   z, Act_MoleSpike_Despawn
	ret ; [POI] We never get here
	
; =============== Act_MoleSpike_Throw ===============
; The spike is thrown in front, then returns back.
; This is done by indexing a table of X offsets, and moving right by that amount.
Act_MoleSpike_Throw:

	; Pick the correct path table for the direction.
	;
	; We're also picking the high byte of BC while we're here,
	; since ActS_MoveRight wants a 16bit value, while the table
	; is made of 8bit entries.
	
	ld   hl, Act_MoleSpike_Throw_RPath	; HL = Path when throwing right
	ld   b, HIGH(1)						; B = High byte (when moving right)
	ld   a, [sActSetDir]
	bit  DIRB_R, a						; Is the actor facing right?
	jr   nz, .indexTbl					; If so, jump
	ld   hl, Act_MoleSpike_Throw_LPath		
	ld   b, HIGH(-1)		
	
.indexTbl:
	; Indexing trick (see also: Act_Watch_Idle)
	ld   a, [sActMoleSpikePathIndex]	; DE = sActMoleSpikePathIndex / 4
	and  a, $3E					
	rrca
	ld   e, a
	ld   d, $00
	add  hl, de					; Offset the path table
	ld   c, [hl]				; B = Low byte
	call ActS_MoveRight			; Move right by BC
	
	; Place the spike 8px above than usual.
	ld   bc, -$08
	call ActS_MoveDown
	
	ld   a, [sActMoleSpikePathIndex]		; Index++
	inc  a
	ld   [sActMoleSpikePathIndex], a
	cp   a, $40					; Reached the end of the table?
	ret  c						; If not, return
	
	; Otherwise, we've ended the throw action.
	; Return back to the "HOLD" action.
	
	;--
	; Notify back to the parent actor the new status
	ld   a, [sActMoleSpikeParentSlot]			; A = SlotNum
	ld   hl, sAct+(sActMoleSpikeAction-sActSet) ; HL = Base value to seek to
	ld   d, $00						; DE = A * $20 (slot size)
	and  a, $07						
	swap a
	rlca
	ld   e, a
	add  hl, de						; Seek to the slot we want
	ld   a, MOS_MODE_HOLD			
	ld   [hl], a					; Save the new status
	;--
	
	xor  a
	ld   [sActMoleSpikePathIndex], a
	ret
	
; =============== Act_MoleSpike_Throw_LPath ===============
; Tables of offsets to the current X location.
;
; These are a bit special though, since they aren't relative to the last value,
; but to the parent actor's position.
; This is because the child actor's location is initially reset every frame to
; match the parent.
;
; The values must be all negative in this.
Act_MoleSpike_Throw_LPath: 
	db -$16,-$18,-$1A,-$1C,-$1E,-$20,-$22,-$24
	db -$26,-$28,-$2A,-$2C,-$2E,-$30,-$32,-$34
	db -$34,-$32,-$30,-$2E,-$2C,-$2A,-$28,-$26
	db -$24,-$22,-$20,-$1E,-$1C,-$1A,-$18,-$16
; Identical to the one above, except the values must all be positive.
Act_MoleSpike_Throw_RPath: 
	db +$16,+$18,+$1A,+$1C,+$1E,+$20,+$22,+$24
	db +$26,+$28,+$2A,+$2C,+$2E,+$30,+$32,+$34
	db +$34,+$32,+$30,+$2E,+$2C,+$2A,+$28,+$26
	db +$24,+$22,+$20,+$1E,+$1C,+$1A,+$18,+$16
	
; =============== Act_MoleSpike_Hold ===============
; The spike projectile is moved around in a circle-like motion.
; This is done by indexing a table with pairs of X and Y offsets, and moving by those amounts.
;
; See also: Act_MoleSpike_Throw.
Act_MoleSpike_Hold:
	; Reset this for Act_MoleSpike_Throw
	xor  a								
	ld   [sActMoleSpikePathIndex], a
	
	; Pick the path and high byte of BC depending on the direction.
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, .useR
.useL:
	ld   hl, Act_MoleSpike_Hold_LPath
	ld   b, HIGH(-1)
	jr   .indexTbl
.useR:
	ld   hl, Act_MoleSpike_Hold_RPath
	ld   b, HIGH(+1)
	
.indexTbl:

	;
	; Index the path table and get the horizontal/vertical offsets,
	; which we'll be adding to the current coordinates.
	;
	
	; Movement code trickery similar to Act_Pelican_UnderwaterMoveV, which is itself a variant of Act_Watch_Idle.
	; (Act_Pelican_UnderwaterYPath.end-Act_Pelican_UnderwaterYPath - 2) << 1 = $1C
	ld   a, [sActSetTimer]
	and  a, $1C				; DE = (Timer / 4) * 2
	rrca
	ld   e, a
	ld   d, $00
	add  hl, de				; Offset the path table
	ldi  a, [hl]			; C = Byte 0: Horz Movement
	ld   c, a				
	call ActS_MoveRight		; Move right by that
	
	ld   c, [hl]			; C = Byte 1: Vert movement
	ld   b, HIGH(-1)		; Assume always negative
	call ActS_MoveDown		; Move down by that
	
	; Every $20 frames play the SFX
	ld   a, [sActSetTimer]
	and  a, $1F
	ret  nz
	ld   a, SFX1_29
	ld   [sSFX1Set], a
	ret
Act_MoleSpike_Despawn:
	xor  a
	ld   [sActSet], a
	ret
	
; =============== Act_MoleSpike_Hold_*Path ===============
; Offsets for the moving spike projectile, relative to the parent actor.
; Each table entry is made of two bytes:
; - 0: The horizontal offset, passed to ActS_MoveRight
; - 1: The vertical offset, passed to ActS_MoveDown
;
; NOTE: These are some assumptions on the contents of these values:
; - LPath must contain negative X offsets, while RPath must have them positive.
; - All vertical offsets must be negative.
; - Both tables have to contain the same amount of values
Act_MoleSpike_Hold_LPath: 
	;  X    Y
	db -$14,-$08
	db -$10,-$0A
	db -$06,-$14
	db -$04,-$18
	db -$04,-$18
	db -$06,-$14
	db -$10,-$0A
	db -$14,-$08
Act_MoleSpike_Hold_RPath:
	;  X    Y
	db +$14,-$08
	db +$10,-$0A
	db +$06,-$14
	db +$04,-$18
	db +$04,-$18
	db +$06,-$14
	db +$10,-$0A
	db +$14,-$08
OBJLstSharedPtrTable_Act_Mole:
	dw OBJLstPtrTable_Act_Mole_StunL;X
	dw OBJLstPtrTable_Act_Mole_StunR;X
	dw OBJLstPtrTable_Act_Mole_MoveL
	dw OBJLstPtrTable_Act_Mole_MoveR
	dw OBJLstPtrTable_Act_Mole_StunL
	dw OBJLstPtrTable_Act_Mole_StunR
	dw OBJLstPtrTable_Act_Mole_MoveL;X
	dw OBJLstPtrTable_Act_Mole_MoveR;X

OBJLstPtrTable_Act_Mole_MoveL:
	dw OBJLst_Act_Mole_MoveL0
	dw OBJLst_Act_Mole_MoveL1
	dw OBJLst_Act_Mole_MoveL2
	dw OBJLst_Act_Mole_MoveL3
	dw $0000
OBJLstPtrTable_Act_Mole_MoveR:
	dw OBJLst_Act_Mole_MoveR0
	dw OBJLst_Act_Mole_MoveR1
	dw OBJLst_Act_Mole_MoveR2
	dw OBJLst_Act_Mole_MoveR3
	dw $0000
OBJLstPtrTable_Act_Mole_StunL:
	dw OBJLst_Act_Mole_StunL
	dw $0000
OBJLstPtrTable_Act_Mole_StunR:
	dw OBJLst_Act_Mole_StunR
	dw $0000
OBJLstPtrTable_Act_Mole_ThrowL:
	dw OBJLst_Act_Mole_MoveL0
	dw OBJLst_Act_Mole_ThrowL
	dw OBJLst_Act_Mole_ThrowL
	dw OBJLst_Act_Mole_ThrowL;X	; Not needed
	dw $0000;X
OBJLstPtrTable_Act_Mole_ThrowR:
	dw OBJLst_Act_Mole_MoveR0
	dw OBJLst_Act_Mole_ThrowR
	dw OBJLst_Act_Mole_ThrowR
	dw OBJLst_Act_Mole_ThrowR;X	; Not needed
	dw $0000;X
OBJLstPtrTable_Act_Mole_PostThrowL:
	dw OBJLst_Act_Mole_ThrowL
	dw $0000;X
OBJLstPtrTable_Act_Mole_PostThrowR:
	dw OBJLst_Act_Mole_ThrowR
	dw $0000;X
OBJLstPtrTable_Act_MoleSpike:
	dw OBJLst_Act_MoleSpike
	dw $0000;X

OBJLstSharedPtrTable_Act_MoleSpike:
	dw OBJLstPtrTable_Act_MoleSpike;X
	dw OBJLstPtrTable_Act_MoleSpike;X
	dw OBJLstPtrTable_Act_MoleSpike;X
	dw OBJLstPtrTable_Act_MoleSpike;X
	dw OBJLstPtrTable_Act_MoleSpike;X
	dw OBJLstPtrTable_Act_MoleSpike;X
	dw OBJLstPtrTable_Act_MoleSpike;X
	dw OBJLstPtrTable_Act_MoleSpike;X

OBJLst_Act_Mole_MoveL0: INCBIN "data/objlst/actor/mole_movel0.bin"
OBJLst_Act_Mole_MoveL1: INCBIN "data/objlst/actor/mole_movel1.bin"
OBJLst_Act_Mole_MoveL2: INCBIN "data/objlst/actor/mole_movel2.bin"
OBJLst_Act_Mole_MoveL3: INCBIN "data/objlst/actor/mole_movel3.bin"
OBJLst_Act_Mole_StunL: INCBIN "data/objlst/actor/mole_stunl.bin"
OBJLst_Act_Mole_ThrowL: INCBIN "data/objlst/actor/mole_throwl.bin"
OBJLst_Act_Mole_MoveR0: INCBIN "data/objlst/actor/mole_mover0.bin"
OBJLst_Act_Mole_MoveR1: INCBIN "data/objlst/actor/mole_mover1.bin"
OBJLst_Act_Mole_MoveR2: INCBIN "data/objlst/actor/mole_mover2.bin"
OBJLst_Act_Mole_MoveR3: INCBIN "data/objlst/actor/mole_mover3.bin"
OBJLst_Act_Mole_StunR: INCBIN "data/objlst/actor/mole_stunr.bin"
OBJLst_Act_Mole_ThrowR: INCBIN "data/objlst/actor/mole_throwr.bin"
GFX_Act_Mole: INCBIN "data/gfx/actor/mole.bin"
OBJLst_Act_MoleSpike: INCBIN "data/objlst/actor/molespike.bin"
GFX_Act_MoleSpike: INCBIN "data/gfx/actor/molespike.bin"

; =============== ActInit_MoleCutscene ===============
; A mole opening a coin lock at the end of C01A.
ActInit_MoleCutscene:
	; Setup collision box (not needed -- intangible)
	xor  a
	ld   [sActSetColiBoxU], a
	ld   [sActSetColiBoxD], a
	ld   [sActSetColiBoxL], a
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_MoleCutscene
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_MoleCutscene_Idle
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Mole
	call ActS_SetOBJLstSharedTablePtr
	
	; Clear timers
	xor  a
	ld   [sActSetTimer], a
	ld   [sActMoleCutsceneModeTimer], a
	ld   [sActSetTimer3], a
	ld   [sActSetTimer4], a			; Not used
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer6], a
	ld   [sActSetTimer7], a
	ld   [sActSetColiType], a		; Make intangible
	ret
; =============== OBJLstPtrTable_Act_MoleCutscene_* ===============
; This actor uses the same graphics as Act_Mole, so the same mappings will also work fine.
OBJLstPtrTable_Act_MoleCutscene_Idle:
	dw OBJLst_Act_Mole_MoveR0
	dw $0000
OBJLstPtrTable_Act_MoleCutscene_Turn:
	dw OBJLst_Act_Mole_MoveR0
	dw OBJLst_Act_Mole_MoveL0
	dw $0000
OBJLstPtrTable_Act_MoleCutscene_Throw:
	dw OBJLst_Act_Mole_ThrowR
	dw $0000;X
OBJLstPtrTable_Act_MoleCutscene_Walk:
	dw OBJLst_Act_Mole_MoveR0
	dw OBJLst_Act_Mole_MoveR1
	dw OBJLst_Act_Mole_MoveR2
	dw OBJLst_Act_Mole_MoveR3
	dw $0000

; =============== Act_MoleCutscene ===============
Act_MoleCutscene:
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_MoleCutscene_Idle
	dw Act_MoleCutscene_TurnRight
	dw Act_MoleCutscene_SpawnCoin
	dw Act_MoleCutscene_ThrowAnim
	dw Act_MoleCutscene_WaitWalk
	dw Act_MoleCutscene_Walk
	dw Act_MoleCutscene_TurnMulti
	
; =============== Act_MoleCutscene_Idle ===============
; Mode $00: Idle mode.
Act_MoleCutscene_Idle:
	mActOBJLstPtrTable OBJLstPtrTable_Act_MoleCutscene_Idle
	
	;
	; Start the cutscene when the player gets close enough.
	;
	ld   a, [sActSetX_Low]		; HL = Actor X
	ld   l, a
	ld   a, [sActSetX_High]
	ld   h, a
	ld   a, [sPlX_Low]			; BC = Player X
	ld   c, a
	ld   a, [sPlX_High]
	ld   b, a
	call ActS_GetPlDistance		; HL = Distance between ActX and PlX
	ld   a, l
	cp   a, $22					; Distance < $22?
	jr   c, .nextMode			; If so, switch to the next mode
	ret
.nextMode:
	ld   a, MOLEC_RTN_TURNMULTI
	ld   [sActLocalRoutineId], a
	
	xor  a
	ld   [sActMoleCutsceneModeTimer], a
	
	ld   a, $FA					; Freeze the player
	ld   [sPlFreezeTimer], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_MoleCutscene_Idle
	
	ld   a, BGMACT_FADEOUT
	ld   [sBGMActSet], a
	ld   a, BGM_TREASURE
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	ret
	
; =============== Act_MoleCutscene_TurnMulti ===============
; Mode $06: The mole "turns" multiple times.
Act_MoleCutscene_TurnMulti:
	; Animate every $10 frames
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .incTimer
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.incTimer:
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	; Update the timer
	ld   a, [sActMoleCutsceneModeTimer]		; Timer++
	inc  a
	ld   [sActMoleCutsceneModeTimer], a
	; Don't do anything if < $3C
	cp   a, $3C
	ret  c
	; When it reaches $5A, switch to the next mode
	cp   a, $5A
	jr   nc, .nextMode
	
.turnAnim:
	; Between frames $3C - $59, do the turn animation
	ld   a, LOW(OBJLstPtrTable_Act_MoleCutscene_Turn)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_MoleCutscene_Turn)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	;--
	; [TCRF] This... does nothing at all. Half-removed leftover?
	;        The way it's laid out implies two things:
	;        - This mode used to animate every 8 frames rather than $10
	;        - sActSetOBJLstId may have been reset every 8 frames
	ld   a, [sActMoleCutsceneModeTimer]
	and  a, $07
	ret  nz
	ld   a, [sActSetOBJLstId]
	cp   a, $01					; FrameId == $01?	
	jr   z, .end				; If so, jump
	ret
.end:
	ret
	;--
	
.nextMode:
	ld   a, MOLEC_RTN_TURNR
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActMoleCutsceneModeTimer], a
	ld   a, $F0
	ld   [sPlFreezeTimer], a
	ret
; =============== Act_MoleCutscene_TurnRight ===============
; Mode $01: The mole "turns" multiple times.
Act_MoleCutscene_TurnRight:
	; Turning is done through an animation
	mActOBJLstPtrTable OBJLstPtrTable_Act_MoleCutscene_Idle
	
	; Wait for $1E frames
	ld   a, [sActMoleCutsceneModeTimer]
	inc  a
	ld   [sActMoleCutsceneModeTimer], a
	cp   a, $1E
	jr   nc, .nextMode
	ret
.nextMode:
	ld   a, MOLEC_RTN_SPAWNCOIN
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActMoleCutsceneModeTimer], a
	ret
; =============== Act_MoleCutscene_SpawnCoin ===============
; Mode $03: Spawns the 10-coin.
Act_MoleCutscene_SpawnCoin:
	mActOBJLstPtrTable OBJLstPtrTable_Act_MoleCutscene_Idle
	
	; Wait for $0A frames before spawning the coin
	ld   a, [sActMoleCutsceneModeTimer]
	inc  a
	ld   [sActMoleCutsceneModeTimer], a
	cp   a, $0A
	jr   nc, .nextMode
	ret
.nextMode:
	ld   a, MOLEC_RTN_THROWANIM
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActMoleCutsceneModeTimer], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_MoleCutscene_Idle
	
	;
	; Spawn a 10-coin on the mole's hand.
	;
.spawnCoin:
	; Find an empty slot
	ld   hl, sAct			; HL = Actor slot area
	ld   e, $00				; E = Current slot
.checkSlot:
	ld   a, [hl]			; Read active status
	or   a					; Is the slot marked as active?
	jr   z, .slotFound		; If not, we found a slot
	ld   bc, (sActSet_End-sActSet)	; Move to next slot (HL += $20)
	add  hl, bc
	inc  e					; SlotNum++
	cp   a, $07				; Have we reached the end of the 7 slots?
	jr   c, .checkSlot		; If not, check the next one
	ret ; [POI] We never get here
.slotFound:
	mActS_SetOBJBank OBJLstPtrTable_Act_10Coin
	
	ld   a, $02				; Enabled
	ldi  [hl], a
	
	;--
	; Position the coin on the mole's hand on the right
	ld   a, [sActSetX_Low]	; X = sActSetX + $0C
	add  $0C
	ldi  [hl], a
	ld   a, [sActSetX_High]
	adc  a, $00
	ldi  [hl], a
	
	ld   a, [sActSetY_Low]	; Y = sActSetY - $14
	sub  a, $14
	ldi  [hl], a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ldi  [hl], a
	;--
	
	ld   a, ACTCOLI_10COIN	; Collision type
	ldi  [hl], a
	ld   a, -$0C			; Coli box U
	ldi  [hl], a
	ld   a, -$04			; Coli box D
	ldi  [hl], a
	ld   a, -$04			; Coli box L
	ldi  [hl], a
	ld   a, +$04			; Coli box R
	ldi  [hl], a
	
	ld   a, [sActSetRelY]	; Rel.Y (Origin)
	ldi  [hl], a
	ld   a, [sActSetRelX]	; Rel.X (Origin)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstPtrTable_Act_10Coin)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_10Coin)
	ldi  [hl], a
	
	ld   a, DIR_R			; The lock is on the right
	ldi  [hl], a
	xor  a					; OBJLst ID
	ldi  [hl], a
	ld   a, ACT_10COIN		; Actor ID (standard type)
	ldi  [hl], a
	xor  a					; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_ActS_ThrowDelay3C)		; Code ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_ActS_ThrowDelay3C)
	ldi  [hl], a	
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	
	ld   bc, -$02				; Initial Y Speed (for throw arc)
	ld   a, c
	ldi  [hl], a				
	ld   a, b
	ldi  [hl], a	
	
	ld   a, $01					; Timer 5 - H speed
	ldi  [hl], a				
	xor  a
	ldi  [hl], a				; Timer 6 - Kill held actor (no)
	ldi  [hl], a				; Timer 7 - No collision timer
	
	ld   a, $01					; Flags
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	; [POI] Weird value, but not like it's used.
	ld   a, LOW(OBJLstSharedPtrTable_Act_Mole)
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_Mole)
	ldi  [hl], a
	ret
	
; =============== Act_MoleCutscene_ThrowAnim ===============
; Mode $03: Handles the throw animation.
Act_MoleCutscene_ThrowAnim:
	; Handle the timer.
	ld   a, [sActMoleCutsceneModeTimer]	; Timer++
	inc  a
	ld   [sActMoleCutsceneModeTimer], a
	cp   a, $78							; Timer >= $78?
	jr   nc, .nextMode					; If so, switch to the next mode
	
	; When the timer is $3C, set the throw animation (which is only 1 frame).
	cp   a, $3C							; Timer != $3C?
	ret  nz								; If so, return
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_MoleCutscene_Throw
	ld   a, SFX1_0C
	ld   [sSFX1Set], a
	ret
.nextMode:
	ld   a, MOLEC_RTN_WAITWALK
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActMoleCutsceneModeTimer], a
	ret
; =============== Act_MoleCutscene_WaitWalk ===============
; Mode $04: Wait for $3C frames before moving.
Act_MoleCutscene_WaitWalk:
	mActOBJLstPtrTable OBJLstPtrTable_Act_MoleCutscene_Idle
	
	; Wait for $3C frames
	ld   a, [sActMoleCutsceneModeTimer]	; Timer++
	inc  a
	ld   [sActMoleCutsceneModeTimer], a
	cp   a, $3C							; Timer >= $3C?
	jr   nc, .nextMode					; If so, jump
	ret
.nextMode:
	ld   a, MOLEC_RTN_WALK
	ld   [sActLocalRoutineId], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_MoleCutscene_Walk
	
	xor  a
	ld   [sActMoleCutsceneModeTimer], a
	; Restore level music (hardcoded to C01A's music)
	ld   a, BGM_COURSE1						
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	ret
	
; =============== Act_MoleCutscene_Walk ===============
; Mode $05: Mole walks to the right, then despawns over the exit door.
Act_MoleCutscene_Walk:
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	; After $60 frames despawn the actor, which is when the actor is over the exit door.
	; With the movement speed of 0.5px/frame, the door is expected to be 3 blocks to the right.
	ld   a, [sActMoleCutsceneModeTimer]
	inc  a
	ld   [sActMoleCutsceneModeTimer], a
	cp   a, $30*$02
	jr   nc, .despawn
	
	; Move right at 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveRight
	ret
.despawn:
	xor  a
	ld   [sActSet], a
	ret
	
; =============== ActInit_Knight ===============
; The C40 miniboss.
ActInit_Knight:
	; Setup collision box
	ld   a, -$20
	ld   [sActSetColiBoxU], a
	ld   a, -$00
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Knight
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_Knight_WalkL
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Knight
	call ActS_SetOBJLstSharedTablePtr
	
	; Damage from the top when idle
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	xor  a
	ld   [sActSetTimer], a
	ld   [sActKnightTurnDelay], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ld   [sActLocalRoutineId], a
	ld   [sActKnightHitCount], a
	ld   [sActKnightModeTimer], a
	ld   [sActKnightDead], a
	ret
	
; =============== Act_Knight ===============
Act_Knight:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; If the actor is about to turn, wait for a bit before turning
	ld   a, [sActKnightTurnDelay]
	or   a
	jr   nz, Act_Knight_WaitTurn
	
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_Knight_Walk
	dw Act_Knight_Hit
	dw Act_Knight_Charge
	dw Act_Knight_Mode3
; =============== Act_Knight_SetTurnDelay ===============
; Makes the actor turn in $1E frames.
Act_Knight_SetTurnDelay:
	ld   a, $1E
	ld   [sActKnightTurnDelay], a
	ret
; =============== Act_Knight_WaitTurn ===============
Act_Knight_WaitTurn:
	; Wait for the timer to elapse
	ld   a, [sActKnightTurnDelay]
	dec  a
	ld   [sActKnightTurnDelay], a
	or   a
	ret  nz
	; Turn direction
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ret
; =============== Act_Knight_SwitchToWalk ===============
Act_Knight_SwitchToWalk:
	xor  a
	ld   [sActLocalRoutineId], a
	;--
	; Not necessary
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI						
	ld   [sActSetColiType], a
	ret
; =============== Act_Knight_Walk ===============
; Mode $00: Main mode where the actor is walking and vulnerable.
Act_Knight_Walk:
	;--
	; Act_Knight_Move* will always set the correct collision type for us.
	; It isn't necessary to always reset it.
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	;--
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Knight_Walk_Main
	dw Act_Knight_SwitchToHit
	dw Act_Knight_Walk_Main;X
	dw Act_Knight_SwitchToHit
	dw Act_Knight_Walk_Main
	dw Act_Knight_SwitchToHit
	dw Act_Knight_Walk_Main;X
	dw Act_Knight_Walk_Main
	dw Act_Knight_SwitchToHit
	
; =============== Act_Knight_PlayWalkSFX ===============
Act_Knight_PlayWalkSFX:
	ld   a, SFX4_19
	ld   [sSFX4Set], a
	ret
; =============== Act_Knight_Walk_Main ===============
Act_Knight_Walk_Main:
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	; Play walking SFX every $10 frames
	ld   a, [sActSetTimer]
	and  a, $0F
	call z, Act_Knight_PlayWalkSFX
	
	; Move horizontally at 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, Act_Knight_MoveRight
	bit  DIRB_L, a
	jr   nz, Act_Knight_MoveLeft
	ret ; [POI] We never get here
	
; =============== Act_Knight_MoveLeft ===============
; Makes the actor move left, until reaching a solid block.
; This is used for both walking and jumping (after being hit).
Act_Knight_MoveLeft:
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block in the way?
	jr   nz, Act_Knight_SetTurnDelay	; If so, turn
	; Move left 1px
	ld   bc, -$01
	call ActS_MoveRight
	
	; When we're walking, we've got to set the *actual* animation and collision type.
	; What was previously set in Act_Knight_Walk is just a default placeholder value.
	ld   a, [sActLocalRoutineId]
	or   a								; RoutineId == KNI_RTN_WALK?
	ret  nz								; If not, return
	; Bump the player when hitting the shield
	ld   a, LOW(OBJLstPtrTable_Act_Knight_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Knight_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	mActColiMask ACTCOLI_NORM, ACTCOLI_BUMP, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
; =============== Act_Knight_MoveRight ===============
; Makes the actor walk right, until reaching a solid block.
; This is used for both walking and jumping (after being hit).
Act_Knight_MoveRight:
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block in the way?
	jp   nz, Act_Knight_SetTurnDelay	; If so, turn
	; Move right 1px
	ld   bc, +$01
	call ActS_MoveRight
	
	; If we are walking, force the proper anim/collision type
	ld   a, [sActLocalRoutineId]
	or   a								; RoutineId == KNI_RTN_WALK?
	ret  nz								; If not, return
	ld   a, LOW(OBJLstPtrTable_Act_Knight_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Knight_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	; Bump the player when hitting the shield
	mActColiMask ACTCOLI_BUMP, ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_Knight_SwitchToCharge ===============
; Makes the boss charge for $B4 frames.
Act_Knight_SwitchToCharge:
	ld   a, KNI_RTN_CHARGE			; Charge...
	ld   [sActLocalRoutineId], a
	ld   a, $B4						; ...for $B4 frames
	ld   [sActKnightModeTimer], a
	; The player can only hit the actor from behind, 
	; so we want the actor to turn direction.
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ret
	
; =============== Act_Knight_Charge ===============
; The actor moves at a fast speed.
Act_Knight_Charge:
	; After the timer elapses, return to the normal walking mode.
	ld   a, [sActKnightModeTimer]		; Timer--
	or   a								; Timer == 0?
	jp   z, Act_Knight_SwitchToWalk		; If so, return walking
	dec  a
	ld   [sActKnightModeTimer], a
	
	; Animate every 4 global frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .moveH
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.moveH:
	; Play walking SFX every 8 frames (double the speed)
	ld   a, [sActSetTimer]
	and  a, $07
	call z, Act_Knight_PlayWalkSFX
	
	; Move horizontally depending on the current direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, Act_Knight_ChargeRight
	bit  DIRB_L, a
	jr   nz, Act_Knight_ChargeLeft
	ret ; [POI] We never get here
	
; =============== Act_Knight_ChargeLeft ===============
; Makes the actor run left, until reaching a solid block.
Act_Knight_ChargeLeft:
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block in the way?
	jp   nz, Act_Knight_SetTurnDelay	; If so, turn
	
	ld   bc, -$02
	call ActS_MoveRight
	
	; Set charge anim, with the spike on the left
	ld   a, LOW(OBJLstPtrTable_Act_Knight_ChargeL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Knight_ChargeL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	; Damage player on the left side
	; Note that we can't actually hit him from behind -- he moves too fast.
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
; =============== Act_Knight_ChargeRight ===============
; Makes the actor run right, until reaching a solid block.
Act_Knight_ChargeRight:
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block in the way?
	jp   nz, Act_Knight_SetTurnDelay	; If so, turn
	
	ld   bc, +$02
	call ActS_MoveRight
	
	; Set charge anim, with the spike on the right
	ld   a, LOW(OBJLstPtrTable_Act_Knight_ChargeR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Knight_ChargeR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	; Damage player on the right side
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
; =============== Act_Knight_SwitchToHit ===============
; Registers a hit to the miniboss.
Act_Knight_SwitchToHit:
	; Miniboss dies after 3 hits
	ld   a, [sActKnightHitCount]		; HitCount++
	inc  a
	ld   [sActKnightHitCount], a
	cp   a, $03							; Hit 3 times?
	jp   nc, Act_Knight_SwitchToDead	; If so, it's dead
	
.hit:
	ld   a, KNI_RTN_HIT
	ld   [sActLocalRoutineId], a
	ld   a, $40							; Stay in stun-mode for $40 frames 
	ld   [sActKnightModeTimer], a
	mActSetYSpeed -$03					; Trigger a jump
	call SubCall_ActS_SpawnStunStar		; Spawn the stars (like bosses/heavy actors do)
	
	xor  a								
	ld   [sActSetColiType], a			; Make intangible during this
	
	; Set stun animation
	ld   [sActSetOBJLstId], a			; Reset anim counter
	mActOBJLstPtrTable OBJLstPtrTable_Act_Knight_StunR	; Set the one when facing right first
	ld   a, [sActSetDir]
	bit  DIRB_R, a						; Facing right?
	ret  nz								; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_Knight_StunL	; Set the one when facing left
	ret
	
; =============== Act_Knight_Hit ===============
; Mode $01: Handles the hit effect.
Act_Knight_Hit:
	; After the timer elapses, make the knight attack
	ld   a, [sActKnightModeTimer]
	or   a
	jp   z, Act_Knight_SwitchToCharge
	dec  a
	ld   [sActKnightModeTimer], a
	
	; Do standard jump with ground check
	call ActS_FallDownMax4SpeedChkSolid
	
	; Move horizontally
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_Knight_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_Knight_MoveLeft
	
	xor  a							; Force intangible
	ld   [sActSetColiType], a
	
	; When the timer ticks down to $1E (when landing back on solid ground),
	; return to the charge animation.
	; Note that since we aren't animating anything in this mode, it will
	; look like the knight is sliding on the ground.
	ld   a, [sActKnightModeTimer]
	cp   a, $1E
	ret  nz
	
	ld   a, LOW(OBJLstPtrTable_Act_Knight_ChargeL)					; When facing left
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Knight_ChargeL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ld   a, [sActSetDir]
	bit  DIRB_L, a			; Facing left?
	ret  nz					; If so, return
	ld   a, LOW(OBJLstPtrTable_Act_Knight_ChargeR)					; When facing right
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Knight_ChargeR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
; =============== Act_Knight_SwitchToDead ===============
; Handles the death sequence.
Act_Knight_SwitchToDead:
	ld   a, $01					; Signal the door to open (and to remain open)
	ld   [sActKnightDead], a
	ld   a, SFX1_2C				; Play hit SFX
	ld   [sSFX1Set], a
	xor  a						; Make intangible
	ld   [sActSetColiType], a
	ld   a, KNI_RTN_DEAD
	ld   [sActLocalRoutineId], a
	ld   a, $8C					; Stay for $8C frames before despawning (enough to avoid despawning on-screen)
	ld   [sActKnightModeTimer], a
	mActSetYSpeed -$03			; Trigger jump at 3px/frame
	
	; Set defeat anim
	mActOBJLstPtrTable OBJLstPtrTable_Act_Knight_DeadL	; When facing left
	ld   a, [sActSetDir]
	bit  DIRB_L, a			; Facing left?
	ret  nz					; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_Knight_DeadR	; When facing right
	ret
	
; =============== Act_Knight_Mode3 ===============
Act_Knight_Mode3:
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	; Do the jump, increasing the speed every 8 frames (to off-screen below)
	call ActS_FallDownEvery8
	
	; Move down until the timer elapses
	ld   a, [sActKnightModeTimer]
	dec  a
	ld   [sActKnightModeTimer], a
	or   a
	ret  nz
	
	; Since the actor already is below the screen when we get here,
	; ActS_StartJumpDead only despawns the actor while awarding a single heart.
	jp   SubCall_ActS_StartJumpDead
	
OBJLstPtrTable_Act_Knight_WalkL:
	dw OBJLst_Act_Knight_WalkL0
	dw OBJLst_Act_Knight_WalkL1
	dw OBJLst_Act_Knight_WalkL0
	dw OBJLst_Act_Knight_WalkL2
	dw $0000
OBJLstPtrTable_Act_Knight_WalkR:
	dw OBJLst_Act_Knight_WalkR0
	dw OBJLst_Act_Knight_WalkR1
	dw OBJLst_Act_Knight_WalkR0
	dw OBJLst_Act_Knight_WalkR2
	dw $0000
OBJLstPtrTable_Act_Knight_ChargeL:
	dw OBJLst_Act_Knight_ChargeL0
	dw OBJLst_Act_Knight_ChargeL1
	dw OBJLst_Act_Knight_ChargeL0
	dw OBJLst_Act_Knight_ChargeL2
	dw $0000
OBJLstPtrTable_Act_Knight_ChargeR:
	dw OBJLst_Act_Knight_ChargeR0
	dw OBJLst_Act_Knight_ChargeR1
	dw OBJLst_Act_Knight_ChargeR0
	dw OBJLst_Act_Knight_ChargeR2
	dw $0000
OBJLstPtrTable_Act_Knight_StunL:
	dw OBJLst_Act_Knight_StunL
	dw $0000;X
OBJLstPtrTable_Act_Knight_StunR:
	dw OBJLst_Act_Knight_StunR
	dw $0000;X
OBJLstPtrTable_Act_Knight_DeadL:
	dw OBJLst_Act_Knight_DeadL0
	dw OBJLst_Act_Knight_DeadL1
	dw $0000
OBJLstPtrTable_Act_Knight_DeadR:
	dw OBJLst_Act_Knight_DeadR0
	dw OBJLst_Act_Knight_DeadR1
	dw $0000

OBJLstSharedPtrTable_Act_Knight:
	dw OBJLstPtrTable_Act_Knight_StunL;X
	dw OBJLstPtrTable_Act_Knight_StunR;X
	dw OBJLstPtrTable_Act_Knight_StunL;X
	dw OBJLstPtrTable_Act_Knight_StunR;X
	dw OBJLstPtrTable_Act_Knight_StunL
	dw OBJLstPtrTable_Act_Knight_StunR
	dw OBJLstPtrTable_Act_Knight_StunL;X
	dw OBJLstPtrTable_Act_Knight_StunR;X

OBJLst_Act_Knight_ChargeL0: INCBIN "data/objlst/actor/knight_chargel0.bin"
OBJLst_Act_Knight_ChargeL1: INCBIN "data/objlst/actor/knight_chargel1.bin"
OBJLst_Act_Knight_ChargeL2: INCBIN "data/objlst/actor/knight_chargel2.bin"
OBJLst_Act_Knight_WalkL0: INCBIN "data/objlst/actor/knight_walkl0.bin"
OBJLst_Act_Knight_WalkL1: INCBIN "data/objlst/actor/knight_walkl1.bin"
OBJLst_Act_Knight_WalkL2: INCBIN "data/objlst/actor/knight_walkl2.bin"
OBJLst_Act_Knight_StunL: INCBIN "data/objlst/actor/knight_stunl.bin"
OBJLst_Act_Knight_DeadL0: INCBIN "data/objlst/actor/knight_deadl0.bin"
OBJLst_Act_Knight_DeadL1: INCBIN "data/objlst/actor/knight_deadl1.bin"
OBJLst_Act_Knight_ChargeR0: INCBIN "data/objlst/actor/knight_charger0.bin"
OBJLst_Act_Knight_ChargeR1: INCBIN "data/objlst/actor/knight_charger1.bin"
OBJLst_Act_Knight_ChargeR2: INCBIN "data/objlst/actor/knight_charger2.bin"
OBJLst_Act_Knight_WalkR0: INCBIN "data/objlst/actor/knight_walkr0.bin"
OBJLst_Act_Knight_WalkR1: INCBIN "data/objlst/actor/knight_walkr1.bin"
OBJLst_Act_Knight_WalkR2: INCBIN "data/objlst/actor/knight_walkr2.bin"
OBJLst_Act_Knight_StunR: INCBIN "data/objlst/actor/knight_stunr.bin"
OBJLst_Act_Knight_DeadR0: INCBIN "data/objlst/actor/knight_deadr0.bin"
OBJLst_Act_Knight_DeadR1: INCBIN "data/objlst/actor/knight_deadr1.bin"
GFX_Act_Knight: INCBIN "data/gfx/actor/knight.bin"
; [TCRF] Unreferenced block of graphics, a copy of GFX_Act_MiniBossLock.
;        It's completely identical to GFX_Act_MiniBossLock, except it has an extra placeholder "X" tile.
;
;        This one is suspicious considering it's located right after the graphics for the miniboss,
;        as if it was once part of GFX_Act_Knight. 
;        Note that in other boss rooms, some actors which get spawned by the boss (and run under
;        its actor ID) have to include their GFX as part of the boss GFX.
;        Act_MiniBossLock is instead its own indipendent actor. Was this always the case though?   
GFX_Unused_Act_MiniBossLock_Copy: INCBIN "data/gfx/actor/minibosslock_unused.bin"

; =============== ActInit_MiniBossLock ===============
; The lock which opens after defeating the C40 miniboss.
ActInit_MiniBossLock:
	; Setup collision box
	ld   a, -$1E
	ld   [sActSetColiBoxU], a
	ld   a, -$00
	ld   [sActSetColiBoxD], a
	ld   a, -$06
	ld   [sActSetColiBoxL], a
	ld   a, +$06
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_MiniBossLock
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_MiniBossLock
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Knight
	call ActS_SetOBJLstSharedTablePtr
	
	ld   a, ACTCOLI_LOCK			; Bump on all sides + platform
	ld   [sActSetColiType], a
	xor  a							; Set LOCK_CLOSED
	ld   [sActLocalRoutineId], a
	
	; If the miniboss was already defeated, the door should be open
	ld   a, [sActKnightDead]
	or   a							; Boss dead?
	ret  z							; If not, return
.instaOpen:
	ld   a, LOCK_OPEN				; Set open
	ld   [sActLocalRoutineId], a
	ret
; =============== OBJLstPtrTable_Act_MiniBossLock ===============
OBJLstPtrTable_Act_MiniBossLock:
	dw OBJLst_Act_MiniBossLock
	dw $0000;X

; =============== Act_MiniBossLock ===============
Act_MiniBossLock:
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Depending on the status of the lock...
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_MiniBossLock_Closed
	dw Act_MiniBossLock_Opening
	dw Act_MiniBossLock_Open
	
; =============== Act_MiniBossLock_Closed ===============
; The lock is closed, and rebounds the player.
Act_MiniBossLock_Closed:
	; Wait until the knight is dead before opening
	ld   a, [sActKnightDead]
	or   a							; Is the knight dead?
	ret  z							; If not, return
	ld   a, LOCK_OPENING
	ld   [sActLocalRoutineId], a
	ret
	
; =============== Act_MiniBossLock_Opening ===============
; The lock is being opened and is moving out of the way.
Act_MiniBossLock_Opening:;I
	; Move up at 0.25px/frame
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   bc, -$01
	call ActS_MoveDown
	
	; As long as the lock is moving up, continue performing a screen shake.
	; Since the timer is set to $04 every time, it will quickly stop shaking
	; as soon as we switch to Act_MiniBossLock_Open.
	ld   a, SFX4_02		; Play screen shake SFX
	ld   [sSFX4Set], a
	ld   a, $04						; Shake for the next 4 frames
	ld   [sScreenShakeTimer], a
	
	ld   a, $0A						; Continue freezing the player
	ld   [sPlFreezeTimer], a
	
	; Wait for the lock to have moved up 20px (aka 2 blocks, the height of a door)
	ld   a, [sActMiniBossLockUnlockTimer]			; Timer++
	inc  a
	ld   [sActMiniBossLockUnlockTimer], a
	cp   a, $20						; Timer < $20?
	ret  c							; If so, return
	ld   a, LOCK_OPEN				; Otherwise, we're done
	ld   [sActLocalRoutineId], a
	ret
; =============== Act_MiniBossLock_Open ===============
; The lock is open, and can't be interacted with anymore.
Act_MiniBossLock_Open:
	xor  a						; Mark as intangible
	ld   [sActSetColiType], a
	ret
OBJLst_Act_MiniBossLock: INCBIN "data/objlst/actor/minibosslock.bin"
GFX_Act_MiniBossLock: INCBIN "data/gfx/actor/minibosslock.bin"
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L177CCE.asm"
ENDC