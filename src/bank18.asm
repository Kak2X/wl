;
; BANK $18 - Actor code
;
; =============== mActGetPlDirHRel ===============
; Used for inline ActS_GetPlDirHRel.
; OUT
; - C: If set (c), the player is to the right of the actor.
;      If clear (nc), the player is to the left of the actor. 
MACRO mActGetPlDirHRel
	; Add $100 to both of them, to prevent any underflowing
	ld   a, [sPlX_Low]		; BC = PlX + $100
	ld   c, a
	ld   a, [sPlX_High]
	add  $01
	ld   b, a			
	
	ld   a, [sActSetX_Low]	; HL = ActX + $100
	ld   l, a
	ld   a, [sActSetX_High]
	add  $01
	ld   h, a
	
	; Use carry to detect where the player is relative to the actor.
	ld   a, l		; PlX - ActX		
	sub  a, c
	ld   a, h		
	sbc  a, b		
ENDM

; =============== ActInit_RiceBeachBoss ===============
ActInit_RiceBeachBoss:
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, -$06
	ld   [sActSetColiBoxD], a
	ld   a, -$06
	ld   [sActSetColiBoxL], a
	ld   a, +$06
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_RiceBeachBoss
	call ActS_SetCodePtr
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_RiceBeachBoss
	call ActS_SetOBJLstSharedTablePtr
	
	xor  a
	ld   [sActSetTimer], a
	ld   [sActLocalRoutineId], a
	ld   [sActRiceBeachBossHitCount], a
	ld   [sActRiceBeachBossDropSpeed], a
	ld   [sActRiceBeachBossHSpeed_Low], a
	ld   [sActRiceBeachBossHSpeed_High], a
	
	mActColiMask ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_BUMP
	ld   a, COLI
	ld   [sActSetColiType], a
	call Act_RiceBeachBoss_SetIntro
	ld   a, $FA					; Freeze long enough for the intro
	ld   [sPlFreezeTimer], a
	ret
	
; =============== Act_RiceBeachBoss ===============
Act_RiceBeachBoss:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_RiceBeachBoss_Main
	dw Act_RiceBeachBoss_Main
	dw Act_RiceBeachBoss_OnHit
	dw Act_RiceBeachBoss_Main
	dw Act_RiceBeachBoss_OnHit
	dw Act_RiceBeachBoss_OnDashAttack
	dw Act_RiceBeachBoss_Main;X
	dw Act_RiceBeachBoss_Main
	dw Act_RiceBeachBoss_Main
	
; =============== Act_RiceBeachBoss_Main ===============
Act_RiceBeachBoss_Main:
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_RiceBeachBoss_Intro
	dw Act_RiceBeachBoss_RiseUp
	dw Act_RiceBeachBoss_Jump
	dw Act_RiceBeachBoss_Idle
	dw Act_RiceBeachBoss_SpinMove
	dw Act_RiceBeachBoss_SpinMoveAir
	dw Act_RiceBeachBoss_RiseDown
	dw Act_RiceBeachBoss_SpinUnderground
	dw Act_RiceBeachBoss_StunAir
	dw Act_RiceBeachBoss_Dead
	dw Act_RiceBeachBoss_SpinIdle
	dw Act_RiceBeachBoss_StunGround
	
; =============== Act_RiceBeachBoss_DoDropSpeed ===============
; Handle the drop speed during jumps.
Act_RiceBeachBoss_DoDropSpeed:
	; Make the actor drop down by sActRiceBeachBossDropSpeed.
	; Needs to be sign-extended for ActS_MoveDown.
	ld   a, [sActRiceBeachBossDropSpeed]	; BC = sActRiceBeachBossDropSpeed
	ld   c, a
	sext a									
	ld   b, a
	call ActS_MoveDown		; Move down by that
	
	; Every 4 frames increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, [sActRiceBeachBossDropSpeed]
	inc  a
	ld   [sActRiceBeachBossDropSpeed], a
	ret
	
; =============== Act_RiceBeachBoss_SetIntro ===============
; Prepares the intro cutscene for this boss.
Act_RiceBeachBoss_SetIntro:
	ld   a, $00
	ld   [sActLocalRoutineId], a
	ld   a, $64					
	ld   [sActRiceBeachBossModeTimer], a
	
	; Set left direction
	push bc
	ld   bc, OBJLstPtrTable_Act_RiceBeachBoss_SpinUndergroundL
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, DIR_L
	ld   [sActSetDir], a
	
	;--
	; [TCRF] Intro-only, so the boss can't face right
	ld   a, [sActSetRelX]
	cp   a, $50					; On the right side? (X >= $50)
	ret  nc						; If so, return
	; [TCRF] Unreachable code below
	push bc
	ld   bc, OBJLstPtrTable_Act_RiceBeachBoss_SpinUndergroundR
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, DIR_R
	ld   [sActSetDir], a
	ret
	
; =============== Act_RiceBeachBoss_Intro ===============
; Intro -- boss stays in-place on the ground.
Act_RiceBeachBoss_Intro:
	; Handle timer
	ld   a, [sActRiceBeachBossModeTimer]
	dec  a
	ld   [sActRiceBeachBossModeTimer], a
	or   a
	jr   z, Act_RiceBeachBoss_SwitchToRiseUp
	;--
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .end
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.end:
	ret
	
; =============== Act_RiceBeachBoss_SwitchToRiseUp ===============
Act_RiceBeachBoss_SwitchToRiseUp:
	ld   a, RBBOSS_RTN_RISEUP
	ld   [sActLocalRoutineId], a
	
	; While spinning, make all sides except for the bottom damage the player
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_RiceBeachBoss_RiseUp ===============
; Rises from underground.
Act_RiceBeachBoss_RiseUp:
	ld   a, [sActSetRelY]
	cp   a, $40				; Near the top of the screen? (Y < $40)
	jr   c, .endMode			; If so, switch to the next mode
	
	; This actor uses three different animations when rising from the ground.
	; - A less detailed spin anim with white stripes (when underground)
	; - Dust (when at around ground level)
	; - Normal spin anim.
	; Depending on the Y coord...
	cp   a, $78				; Is the boss on the ground? (Y == $78)
	call z, .setDustAnim	; If so, use the dust anim
	cp   a, $70				; Is the boss over the ground? (Y == $70)
	call z, .setMainAnim	; If so, use the normal spin anim
	; Otherwise, keep the white stripe anim from before.
	
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .moveUp
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.moveUp:
	; Move up 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveDown
	ret
	
.setDustAnim:
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_RiceBeachBoss_DustL, OBJLstPtrTable_Act_RiceBeachBoss_DustR
	ret
.setMainAnim:
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_RiceBeachBoss_SpinL, OBJLstPtrTable_Act_RiceBeachBoss_SpinR
	ret
	
.endMode:
	ld   a, RBBOSS_RTN_JUMP
	ld   [sActLocalRoutineId], a
	ld   a, -$03							; Prepare upwards jump
	ld   [sActRiceBeachBossDropSpeed], a
	mActColiMask ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_BUMP
	ld   a, COLI
	ld   [sActSetColiType], a
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_RiceBeachBoss_JumpL, OBJLstPtrTable_Act_RiceBeachBoss_JumpR
	ret
	
; =============== Act_RiceBeachBoss_Jump ===============
; Jumps after rising out of the ground.
Act_RiceBeachBoss_Jump:
	; If the actor is on a solid block, switch to the next mode
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, Act_RiceBeachBoss_SwitchToIdle
	
	call Act_RiceBeachBoss_DoDropSpeed
	
	; Prevent this animation from looping
	ld   a, [sActSetOBJLstId]
	cp   a, $02					; Did we reach the last frame?
	ret  nc						; If so, return
	; Otherwise, increase the anim counter every $10 frames
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .end
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.end:
	ret
; =============== Act_RiceBeachBoss_SwitchToIdle ===============
Act_RiceBeachBoss_SwitchToIdle:
	ld   a, [sActSetY_Low]				; Align to Y block grid
	and  a, $F0
	ld   [sActSetY_Low], a
	ld   a, RBBOSS_RTN_IDLE
	ld   [sActLocalRoutineId], a
	ld   a, $64							; $64 frames for safe attack
	ld   [sActRiceBeachBossModeTimer], a
	
	; Make vulnerable in front
	
	; left
	mActColiMask ACTCOLI_BUMP, ACTCOLI_NORM, ACTCOLI_BUMP, ACTCOLI_BUMP
	ld   a, COLI
	ld   [sActSetColiType], a
	push bc
	ld   bc, OBJLstPtrTable_Act_RiceBeachBoss_IdleL
	call ActS_SetOBJLstPtr
	pop  bc
	;--
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Facing right?
	ret  z					; If not, return
	;--
	; right
	mActColiMask ACTCOLI_NORM, ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_BUMP
	ld   a, COLI
	ld   [sActSetColiType], a
	push bc
	ld   bc, OBJLstPtrTable_Act_RiceBeachBoss_IdleR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_RiceBeachBoss_Idle ===============
; Idle, safe window for attacking.
Act_RiceBeachBoss_Idle:
	; Handle timer, once it expires switch to 0A.
	ld   a, [sActRiceBeachBossModeTimer]
	dec  a
	ld   [sActRiceBeachBossModeTimer], a
	or   a
	jr   z, Act_RiceBeachBoss_SwitchToSpinIdle
	call ActS_IncOBJLstIdEvery8
	ret
	
; =============== Act_RiceBeachBoss_SwitchToSpinIdle ===============
Act_RiceBeachBoss_SwitchToSpinIdle:
	ld   a, RBBOSS_RTN_SPINIDLE
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActRiceBeachBossHSpeed_Low], a
	ld   [sActRiceBeachBossHSpeed_High], a
	
	ld   a, $3C								; $3C frames of warning
	ld   [sActRiceBeachBossModeTimer], a
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_RiceBeachBoss_SpinL, OBJLstPtrTable_Act_RiceBeachBoss_SpinR
	ret
	
; =============== Act_RiceBeachBoss_SpinIdle ===============
; Attack phase - wait before moving.
Act_RiceBeachBoss_SpinIdle:
	; Handle timer
	ld   a, [sActRiceBeachBossModeTimer]
	or   a
	jp   z, .endMode
	dec  a
	ld   [sActRiceBeachBossModeTimer], a
	call ActS_IncOBJLstIdEvery8
	ret
.endMode:
	; [POI] It seems like the boss originally did not wait before moving,
	;       which would have been a bit mean.
	ld   a, RBBOSS_RTN_SPINMOVE
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActRiceBeachBossHSpeed_Low], a
	ld   [sActRiceBeachBossHSpeed_High], a
	; Move on the ground for 2 seconds.
	; This requires the player to jump over the boss around 3 times.
	ld   a, $78							
	ld   [sActRiceBeachBossModeTimer], a
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_RiceBeachBoss_SpinL, OBJLstPtrTable_Act_RiceBeachBoss_SpinR
	ret
; =============== Act_RiceBeachBoss_SpinMove ===============
; Attack phase - moving.
Act_RiceBeachBoss_SpinMove:
	; Handle timer
	ld   a, [sActRiceBeachBossModeTimer]
	or   a
	jr   z, .chkEndMode
	dec  a
	ld   [sActRiceBeachBossModeTimer], a
	
	jr   .setHSpeed
.chkEndMode:
	; Don't switch to the next mode immediately -- wait for the actor to slow down, then stop first.
	ld   a, [sActRiceBeachBossHSpeed_Low]
	or   a
	jp   z, Act_RiceBeachBoss_SwitchToSpinMoveAir
.setHSpeed:
	; Update horizontal *speed*
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_RiceBeachBoss_IncRSpeed
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_RiceBeachBoss_IncLSpeed
	
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .moveH
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	
.moveH:
	call Act_RiceBeachBoss_MoveHorz
	; Always make the actor face the player.
	; Because of the momentum effect used, this causes the actor to gradually slow down,
	; until moving in the other direction.
	call ActS_GetPlDirHRel
	ld   [sActSetDir], a
	ret
; =============== Act_RiceBeachBoss_IncRSpeed ===============
; This subroutine increses the actor's speed to the right,
; by gradually increasing the horizontal speed (capped at 6px/frame).
Act_RiceBeachBoss_IncRSpeed:
	; Increase speed every 4 frames
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	; Check for the speed cap
	ld   a, [sActRiceBeachBossHSpeed_Low]
	bit  7, a				; Speed < 0?
	jr   nz, .incSpeed		; If so, jump
	cp   a, +$06			; Speed >= 6?
	ret  nc					; If so, return
.incSpeed:
	; sActRiceBeachBossHSpeed++
	add  $01
	ld   e, a
	ld   [sActRiceBeachBossHSpeed_Low], a
	ld   a, [sActRiceBeachBossHSpeed_High]
	adc  a, $00
	ld   [sActRiceBeachBossHSpeed_High], a
	ret
; =============== Act_RiceBeachBoss_IncLSpeed ===============
; This subroutine increses the actor's speed to the left,
; by gradually decreasing the horizontal speed (capped at -6px/frame).
Act_RiceBeachBoss_IncLSpeed:
	; Increase speed every 4 frames
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	; Check for the speed cap
	ld   a, [sActRiceBeachBossHSpeed_Low]
	bit  7, a				; Speed > 0?
	jr   z, .decSpeed		; If so, jump
	cp   a, -$06			; Speed <= -6?
	ret  c					; If so, return
.decSpeed:
	; sActRiceBeachBossHSpeed--
	sub  a, $01
	ld   e, a
	ld   [sActRiceBeachBossHSpeed_Low], a
	ld   a, [sActRiceBeachBossHSpeed_High]
	sbc  a, $00
	ld   [sActRiceBeachBossHSpeed_High], a
	ret
; =============== Act_RiceBeachBoss_SwitchToSpinMoveAir ===============
Act_RiceBeachBoss_SwitchToSpinMoveAir:
	ld   a, RBBOSS_RTN_SPINMOVEAIR
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActRiceBeachBossHSpeed_Low], a
	ld   [sActRiceBeachBossHSpeed_High], a
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_RiceBeachBoss_SpinL, OBJLstPtrTable_Act_RiceBeachBoss_SpinR
	ret
	
; =============== Act_RiceBeachBoss_SpinMoveAir_MoveUp ===============
Act_RiceBeachBoss_SpinMoveAir_MoveUp:
	; Move up 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveDown
	
	ld   a, [sActSetRelY]
	cp   a, $42				; Are we close to the $40 target?
	ret  nz					; If not, return
	
	; Otherwise, setup the next timers for later
	ld   a, $A0
	ld   [sActRiceBeachBossModeTimer], a
	ld   a, $3C
	ld   [sActRiceBeachBossDAttackDelay], a
	ret
; =============== Act_RiceBeachBoss_SpinMoveAir_WaitMove ===============
Act_RiceBeachBoss_SpinMoveAir_WaitMove:
	; Wait until the timer elapses while spinning in the air
	ld   a, [sActRiceBeachBossDAttackDelay]
	dec  a
	ld   [sActRiceBeachBossDAttackDelay], a
	or   a
	ret  nz
	; After that, make the actor spin upside down
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_RiceBeachBoss_SpinInvL, OBJLstPtrTable_Act_RiceBeachBoss_SpinInvR
	ret
	
; =============== Act_RiceBeachBoss_SpinMoveAir ===============
; Upside down horizontal attack mode.
; This also handles upwards movement for setting it up.
Act_RiceBeachBoss_SpinMoveAir:
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .setSpeed
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	
.setSpeed:
	;
	; PHASE 1
	;
	; When this mode is first called, the actor is on the ground, with the Y pos being much higher than $40.
	; Move upwards while spinning, until the target Y pos is reached.
	ld   a, [sActSetRelY]
	cp   a, $40					; Y >= $40?
	jr   nc, Act_RiceBeachBoss_SpinMoveAir_MoveUp			; If so, keep moving up

	;
	; PHASE 2
	;
	; After that, spin in place for $3C frames.
	ld   a, [sActRiceBeachBossDAttackDelay]
	or   a						; Did the timer elapse?
	jr   nz, Act_RiceBeachBoss_SpinMoveAir_WaitMove			; If not, jump
	;--
	
	;
	; PHASE 2
	; 
	; Perform the same attack pattern as the previous mode, except upside down.
	; During this phase, thee boss can only be hit on top.
	
	; Handle timer
	ld   a, [sActRiceBeachBossModeTimer]
	or   a
	jr   z, .endMode
	dec  a
	ld   [sActRiceBeachBossModeTimer], a
	
	; Handle horizontal speed
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_RiceBeachBoss_IncRSpeed
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_RiceBeachBoss_IncLSpeed
	call Act_RiceBeachBoss_MoveHorz
	
	; Make the actor move torwards the player, done almost exactly like ActS_GetPlDirHRel.
	; This is being done inline since a different offset is used.
	ld   a, DIR_L
	ld   [sActSetDir], a
	mActGetPlDirHRel		
	ret  nc			; Is the player to the left of the actor? If so, return
	ld   a, DIR_R	; Otherwise, make the actor face right.
	ld   [sActSetDir], a
	ret
	
.endMode:
	ld   a, RBBOSS_RTN_RISEDOWN
	ld   [sActLocalRoutineId], a
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_RiceBeachBoss_RiseDown ===============
; Makes the actor move downwards, into the ground.
Act_RiceBeachBoss_RiseDown:
	; Like in RiseUp, pick different anims depending on where we are vertically.
	; We're going in from above this time, so the triggers are different.
	ld   a, [sActSetRelY]
	cp   a, $70					; Is the boss on the ground? (Y == $70)
	call z, .setDustAnim		; If so, use the dust anim
	cp   a, $78					; Is the boss underground? (Y == $78)
	call z, .setUndergroundAnim	; If so, use the white stripe anim
	;--
	cp   a, $90					; Did we reach Y >= $90?
	jr   nc, .endMode			; If so, switch to the next mode
	
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .moveD
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.moveD:
	; Move down 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveDown
	ret
.setDustAnim:
	; Skip handling collision since we can't touch the boss underground
	xor  a					
	ld   [sActSetColiType], a
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_RiceBeachBoss_DustL, OBJLstPtrTable_Act_RiceBeachBoss_DustR
	ret
.setUndergroundAnim:
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_RiceBeachBoss_SpinUndergroundL, OBJLstPtrTable_Act_RiceBeachBoss_SpinUndergroundR
	ret
.endMode:
	ld   a, RBBOSS_RTN_SPINUNDERGROUND
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActRiceBeachBossHSpeed_Low], a
	ld   [sActRiceBeachBossHSpeed_High], a
	ld   a, $A0
	ld   [sActRiceBeachBossModeTimer], a
	; Already done in setUndergroundAnim, not necessary
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_RiceBeachBoss_SpinUndergroundL, OBJLstPtrTable_Act_RiceBeachBoss_SpinUndergroundR
	ret
	
; =============== Act_RiceBeachBoss_SpinUnderground ===============
; Handles horizontal movement underground.
Act_RiceBeachBoss_SpinUnderground:
	; Handle timer
	ld   a, [sActRiceBeachBossModeTimer]
	or   a
	jp   z, Act_RiceBeachBoss_SwitchToRiseUp
	dec  a
	ld   [sActRiceBeachBossModeTimer], a
	
	; Handle horizontal speed
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_RiceBeachBoss_IncRSpeed
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_RiceBeachBoss_IncLSpeed
	
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .moveH
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	
.moveH:
	call Act_RiceBeachBoss_MoveHorz
	
	;--
	; Another inline ActS_GetPlDirHRel, identical to the one in Act_RiceBeachBoss_SpinMoveAir
	ld   a, DIR_L
	ld   [sActSetDir], a
	mActGetPlDirHRel
	ret  nc
	ld   a, DIR_R
	ld   [sActSetDir], a
	;--
	ret
	
; =============== Act_RiceBeachBoss_OnHit ===============
; Deals damage to the boss after jumping on or under it.
Act_RiceBeachBoss_OnHit:
	ld   a, SFX1_2C
	ld   [sSFX1Set], a
	ld   a, [sActRiceBeachBossHitCount]	; Register the hit
	inc  a
	ld   [sActRiceBeachBossHitCount], a
	cp   a, $03							; Was the boss hit 3 times?
	jp   nc, Act_RiceBeachBoss_SetDead					; If so, set as defeated
	
	; Otherwise, stun him out with a jump effect
	call SubCall_ActS_SpawnStunStar
	ld   a, RBBOSS_RTN_STUNAIR
	ld   [sActLocalRoutineId], a
	ld   a, $FD
	ld   [sActRiceBeachBossDropSpeed], a
	xor  a
	ld   [sActSetColiType], a
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_RiceBeachBoss_StunL, OBJLstPtrTable_Act_RiceBeachBoss_StunR
	ret
	
; =============== Act_RiceBeachBoss_StunAir ===============
; Stun routine.
Act_RiceBeachBoss_StunAir:
	; When the boss lands back on the ground, return to the idle frame.
	; This makes it possible to land a second hit.
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jp   nz, Act_RiceBeachBoss_SwitchToIdle
	
	call Act_RiceBeachBoss_DoDropSpeed
	ret
	
; =============== Act_RiceBeachBoss_OnDashAttack ===============
; Deals damage to the boss after attacking with a dash.
Act_RiceBeachBoss_OnDashAttack:
	ld   a, SFX1_2C
	ld   [sSFX1Set], a
	ld   a, [sActRiceBeachBossHitCount]	; Register the hit
	inc  a
	ld   [sActRiceBeachBossHitCount], a
	cp   a, $03							; Did we hit 3 times?
	jr   nc, Act_RiceBeachBoss_SetDead	; If so, mark the boss as defeated
	
	; Otherwise, prepare for the jump effect
	call SubCall_ActS_SpawnStunStar
	ld   a, RBBOSS_RTN_STUNGROUND
	ld   [sActLocalRoutineId], a
	ld   a, $FC
	ld   [sActRiceBeachBossDropSpeed], a
	xor  a								; Set as intangible
	ld   [sActSetColiType], a
	ld   [sActRiceBeachBossDashStunTimer], a
	
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_RiceBeachBoss_StunL, OBJLstPtrTable_Act_RiceBeachBoss_StunR
	ret
	
; =============== Act_RiceBeachBoss_StunGround ===============
; Stun on ground (with jump effect), after a dash attack.
Act_RiceBeachBoss_StunGround:
	; Skip if we're moving up
	ld   a, [sActRiceBeachBossDropSpeed]
	bit  7, a
	jr   nz, .incDropSpeed
	; If there isn't a solid block below, skip
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, .incDropSpeed
	
	; Otherwise, handle the timer when we're on the ground
	ld   a, [sActRiceBeachBossDashStunTimer]
	inc  a
	ld   [sActRiceBeachBossDashStunTimer], a
	cp   a, $5A
	ret  c
	
	; When we're done, we switch to the attack mode.
	; We don't return to the idle mode like in Mode 0A since we came from that mode.
	jp   Act_RiceBeachBoss_SwitchToSpinIdle
	
.incDropSpeed:
	call Act_RiceBeachBoss_DoDropSpeed
	ret
	
; =============== Act_RiceBeachBoss_SetDead ===============
; Marks the boss as being defeated.
Act_RiceBeachBoss_SetDead:
	ld   a, RBBOSS_RTN_DEAD
	ld   [sActLocalRoutineId], a
	ld   a, $FD								; Prepare for jump effect
	ld   [sActRiceBeachBossDropSpeed], a
	xor  a									; Set intangible
	ld   [sActSetColiType], a
	ld   a, $50								; Enough for the boss to move off-screen
	ld   [sActRiceBeachBossModeTimer], a
	ld   a, SFX1_09
	ld   [sSFX1Set], a
	ld   a, BGM_NONE
	ld   [sBGMSet], a
IF !OPTIMIZE
	call ActS_DespawnAllNormExceptCur_Broken
ENDC
	mActOBJLstPtrTableByDir OBJLstPtrTable_Act_RiceBeachBoss_DeadL, OBJLstPtrTable_Act_RiceBeachBoss_DeadR
	ret

; =============== Act_RiceBeachBoss_Dead ===============
Act_RiceBeachBoss_Dead:
	; Handle the timer
	ld   a, [sActRiceBeachBossModeTimer]
	or   a
	jr   z, .coinGame
	dec  a
	ld   [sActRiceBeachBossModeTimer], a
	
	; Until the timer expires, move the boss down
	call Act_RiceBeachBoss_DoDropSpeed
	
	; On the last frame we get here, setup the coin game BGM
	ld   a, [sActRiceBeachBossModeTimer]
	cp   a, $01
	ret  nz
	ld   a, BGM_COINGAME
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	ret
.coinGame:
	call SubCall_ActS_CoinGame
	ret
	
; =============== Act_RiceBeachBoss_MoveHorz ===============
; This subroutine moves the boss horizontally during the spin attack phase, 
;
; It also handles collision detection for solid walls, to avoid having the boss move off-screen.
; This is also why the arena has solid blocks on the side, instead of
; just relying on the fixed screen scroll mode.
Act_RiceBeachBoss_MoveHorz:
	; If the actor isn't moving, we don't care
	ld   a, [sActRiceBeachBossHSpeed_Low]
	or   a									
	ret  z						
	
	; Check if what's in front of the actor is a solid block
	ld   a, [sActRiceBeachBossHSpeed_High]
	bit  7, a								; Is the actor moving right?
	jr   z, .chkR							; If so, jump
.chkL:
	call ActColi_GetBlockId_LowL
	jr   .chkColi
.chkR:
	call ActColi_GetBlockId_LowR
.chkColi:
	mSubCall ActBGColi_IsSolid
	or   a									; Is it a solid block?
	ret  nz									; If so, don't move
	
	; Otherwise, move horizontally
	ld   a, [sActRiceBeachBossHSpeed_Low]	; BC = sActRiceBeachBossHSpeed / 2
	sra  a
	ld   c, a
	ld   a, [sActRiceBeachBossHSpeed_High]
	ld   b, a
	call ActS_MoveRight						; Move down by that
	ret
	
OBJLstSharedPtrTable_Act_RiceBeachBoss:
	dw OBJLstPtrTable_Act_RiceBeachBoss_StunL;X
	dw OBJLstPtrTable_Act_RiceBeachBoss_StunR;X
	dw OBJLstPtrTable_Act_RiceBeachBoss_StunL;X
	dw OBJLstPtrTable_Act_RiceBeachBoss_StunR;X
	dw OBJLstPtrTable_Act_RiceBeachBoss_StunL;X
	dw OBJLstPtrTable_Act_RiceBeachBoss_StunR;X
	dw OBJLstPtrTable_Act_RiceBeachBoss_StunL;X
	dw OBJLstPtrTable_Act_RiceBeachBoss_StunR;X

OBJLstPtrTable_Act_RiceBeachBoss_JumpL:
	dw OBJLst_Act_RiceBeachBoss_JumpL
	dw OBJLst_Act_RiceBeachBoss_IdleL0
	dw OBJLst_Act_RiceBeachBoss_IdleL0
	dw $0000;X
OBJLstPtrTable_Act_RiceBeachBoss_JumpR:
	dw OBJLst_Act_RiceBeachBoss_JumpR
	dw OBJLst_Act_RiceBeachBoss_IdleR0
	dw OBJLst_Act_RiceBeachBoss_IdleR0
	dw $0000;X
; [TCRF] Unused animations playing the jump anim in reverse.
;        This must have been intended to use when preparing to attack from the idle anim.
;        In-game, it switches immediately from the idle to the spin anim.
OBJLstPtrTable_Act_RiceBeachBoss_Unused_00_L:
	dw OBJLst_Act_RiceBeachBoss_IdleL0;X
	dw OBJLst_Act_RiceBeachBoss_JumpL;X
	dw OBJLst_Act_RiceBeachBoss_JumpL;X
	dw $0000;X
OBJLstPtrTable_Act_RiceBeachBoss_Unused_00_R:
	dw OBJLst_Act_RiceBeachBoss_IdleR0;X
	dw OBJLst_Act_RiceBeachBoss_JumpR;X
	dw OBJLst_Act_RiceBeachBoss_JumpR;X
	dw $0000;X
OBJLstPtrTable_Act_RiceBeachBoss_SpinL:
	dw OBJLst_Act_RiceBeachBoss_SpinL0
	dw OBJLst_Act_RiceBeachBoss_SpinL1
	dw OBJLst_Act_RiceBeachBoss_SpinL2
	dw OBJLst_Act_RiceBeachBoss_SpinL3
	dw $0000
OBJLstPtrTable_Act_RiceBeachBoss_SpinR:
	dw OBJLst_Act_RiceBeachBoss_SpinR0
	dw OBJLst_Act_RiceBeachBoss_SpinR1
	dw OBJLst_Act_RiceBeachBoss_SpinR2
	dw OBJLst_Act_RiceBeachBoss_SpinR3
	dw $0000
OBJLstPtrTable_Act_RiceBeachBoss_SpinInvL:
	dw OBJLst_Act_RiceBeachBoss_SpinInvL0
	dw OBJLst_Act_RiceBeachBoss_SpinInvL1
	dw OBJLst_Act_RiceBeachBoss_SpinInvL2
	dw OBJLst_Act_RiceBeachBoss_SpinInvL3
	dw $0000
OBJLstPtrTable_Act_RiceBeachBoss_SpinInvR:
	dw OBJLst_Act_RiceBeachBoss_SpinInvR0
	dw OBJLst_Act_RiceBeachBoss_SpinInvR1
	dw OBJLst_Act_RiceBeachBoss_SpinInvR2
	dw OBJLst_Act_RiceBeachBoss_SpinInvR3
	dw $0000
OBJLstPtrTable_Act_RiceBeachBoss_SpinUndergroundL:
	dw OBJLst_Act_RiceBeachBoss_SpinUndergroundL0
	dw OBJLst_Act_RiceBeachBoss_SpinUndergroundL1
	dw OBJLst_Act_RiceBeachBoss_SpinUndergroundL2
	dw $0000
OBJLstPtrTable_Act_RiceBeachBoss_SpinUndergroundR:
	dw OBJLst_Act_RiceBeachBoss_SpinUndergroundR0
	dw OBJLst_Act_RiceBeachBoss_SpinUndergroundR1
	dw OBJLst_Act_RiceBeachBoss_SpinUndergroundR2
	dw $0000
OBJLstPtrTable_Act_RiceBeachBoss_StunL:
	dw OBJLst_Act_RiceBeachBoss_StunL
	dw $0000;X
OBJLstPtrTable_Act_RiceBeachBoss_StunR:
	dw OBJLst_Act_RiceBeachBoss_StunR
	dw $0000;X
OBJLstPtrTable_Act_RiceBeachBoss_DeadL:
	dw OBJLst_Act_RiceBeachBoss_DeadL
	dw $0000;X
OBJLstPtrTable_Act_RiceBeachBoss_DeadR:
	dw OBJLst_Act_RiceBeachBoss_DeadR
	dw $0000;X
OBJLstPtrTable_Act_RiceBeachBoss_DustL:
	dw OBJLst_Act_RiceBeachBoss_DustL
	dw $0000
OBJLstPtrTable_Act_RiceBeachBoss_DustR:
	dw OBJLst_Act_RiceBeachBoss_DustR
	dw $0000
OBJLstPtrTable_Act_RiceBeachBoss_IdleL:
	dw OBJLst_Act_RiceBeachBoss_IdleL0
	dw OBJLst_Act_RiceBeachBoss_IdleL1
	dw $0000
OBJLstPtrTable_Act_RiceBeachBoss_IdleR:
	dw OBJLst_Act_RiceBeachBoss_IdleR0
	dw OBJLst_Act_RiceBeachBoss_IdleR1
	dw $0000

OBJLst_Act_RiceBeachBoss_SpinUndergroundL0: INCBIN "data/objlst/actor/ricebeachboss_spinundergroundl0.bin"
OBJLst_Act_RiceBeachBoss_SpinUndergroundL1: INCBIN "data/objlst/actor/ricebeachboss_spinundergroundl1.bin"
OBJLst_Act_RiceBeachBoss_SpinUndergroundL2: INCBIN "data/objlst/actor/ricebeachboss_spinundergroundl2.bin"
OBJLst_Act_RiceBeachBoss_DustL: INCBIN "data/objlst/actor/ricebeachboss_dustl.bin"
OBJLst_Act_RiceBeachBoss_SpinL0: INCBIN "data/objlst/actor/ricebeachboss_spinl0.bin"
OBJLst_Act_RiceBeachBoss_SpinL1: INCBIN "data/objlst/actor/ricebeachboss_spinl1.bin"
OBJLst_Act_RiceBeachBoss_SpinL2: INCBIN "data/objlst/actor/ricebeachboss_spinl2.bin"
OBJLst_Act_RiceBeachBoss_SpinL3: INCBIN "data/objlst/actor/ricebeachboss_spinl3.bin"
OBJLst_Act_RiceBeachBoss_JumpL: INCBIN "data/objlst/actor/ricebeachboss_jumpl.bin"
OBJLst_Act_RiceBeachBoss_IdleL0: INCBIN "data/objlst/actor/ricebeachboss_idlel0.bin"
OBJLst_Act_RiceBeachBoss_IdleL1: INCBIN "data/objlst/actor/ricebeachboss_idlel1.bin"
OBJLst_Act_RiceBeachBoss_StunL: INCBIN "data/objlst/actor/ricebeachboss_stunl.bin"
OBJLst_Act_RiceBeachBoss_SpinInvL0: INCBIN "data/objlst/actor/ricebeachboss_spininvl0.bin"
OBJLst_Act_RiceBeachBoss_SpinInvL1: INCBIN "data/objlst/actor/ricebeachboss_spininvl1.bin"
OBJLst_Act_RiceBeachBoss_SpinInvL2: INCBIN "data/objlst/actor/ricebeachboss_spininvl2.bin"
OBJLst_Act_RiceBeachBoss_SpinInvL3: INCBIN "data/objlst/actor/ricebeachboss_spininvl3.bin"
OBJLst_Act_RiceBeachBoss_DeadL: INCBIN "data/objlst/actor/ricebeachboss_deadl.bin"
OBJLst_Act_RiceBeachBoss_SpinUndergroundR0: INCBIN "data/objlst/actor/ricebeachboss_spinundergroundr0.bin"
OBJLst_Act_RiceBeachBoss_SpinUndergroundR1: INCBIN "data/objlst/actor/ricebeachboss_spinundergroundr1.bin"
OBJLst_Act_RiceBeachBoss_SpinUndergroundR2: INCBIN "data/objlst/actor/ricebeachboss_spinundergroundr2.bin"
OBJLst_Act_RiceBeachBoss_DustR: INCBIN "data/objlst/actor/ricebeachboss_dustr.bin"
OBJLst_Act_RiceBeachBoss_SpinR0: INCBIN "data/objlst/actor/ricebeachboss_spinr0.bin"
OBJLst_Act_RiceBeachBoss_SpinR1: INCBIN "data/objlst/actor/ricebeachboss_spinr1.bin"
OBJLst_Act_RiceBeachBoss_SpinR2: INCBIN "data/objlst/actor/ricebeachboss_spinr2.bin"
OBJLst_Act_RiceBeachBoss_SpinR3: INCBIN "data/objlst/actor/ricebeachboss_spinr3.bin"
OBJLst_Act_RiceBeachBoss_JumpR: INCBIN "data/objlst/actor/ricebeachboss_jumpr.bin"
OBJLst_Act_RiceBeachBoss_IdleR0: INCBIN "data/objlst/actor/ricebeachboss_idler0.bin"
OBJLst_Act_RiceBeachBoss_IdleR1: INCBIN "data/objlst/actor/ricebeachboss_idler1.bin"
OBJLst_Act_RiceBeachBoss_StunR: INCBIN "data/objlst/actor/ricebeachboss_stunr.bin"
OBJLst_Act_RiceBeachBoss_SpinInvR0: INCBIN "data/objlst/actor/ricebeachboss_spininvr0.bin"
OBJLst_Act_RiceBeachBoss_SpinInvR1: INCBIN "data/objlst/actor/ricebeachboss_spininvr1.bin"
OBJLst_Act_RiceBeachBoss_SpinInvR2: INCBIN "data/objlst/actor/ricebeachboss_spininvr2.bin"
OBJLst_Act_RiceBeachBoss_SpinInvR3: INCBIN "data/objlst/actor/ricebeachboss_spininvr3.bin"
OBJLst_Act_RiceBeachBoss_DeadR: INCBIN "data/objlst/actor/ricebeachboss_deadr.bin"
GFX_Act_RiceBeachBoss: INCBIN "data/gfx/actor/ricebeachboss.bin"

; =============== ActInit_ParsleyWoodsBoss ===============
ActInit_ParsleyWoodsBoss:
	xor  a
	ld   [sActBossDead], a
	
	; Setup collision box
	ld   a, -$1C
	ld   [sActSetColiBoxU], a
	ld   a, -$08
	ld   [sActSetColiBoxD], a
	ld   a, -$0C
	ld   [sActSetColiBoxL], a
	ld   a, +$0C
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_ParsleyWoodsBoss
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBoss_IdleL
	call ActS_SetOBJLstPtr
	
	; Set OBJLst shared table
	pop  bc
	ld   bc, OBJLstSharedPtrTable_Act_ParsleyWoodsBoss
	call ActS_SetOBJLstSharedTablePtr
	xor  a
	
	ld   [sActSetTimer], a
	ld   [sActLocalRoutineId], a
	ld   [sActParsleyWoodsBossHitCount], a
	ld   [sActParsleyWoodsBossVSpeed], a
	ld   [sActParsleyWoodsBossHSpeed_Low], a
	ld   [sActParsleyWoodsBossHSpeed_High], a
	
	; Set as fully vulnerable (through only throwing something deals damage)
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	call Act_ParsleyWoodsBoss_SetIntro
	ld   a, [sActNumProc]				; Use transparency effect
	ld   [sActSlotTransparent], a
	ld   a, $B4
	ld   [sPlFreezeTimer], a
	ret
; =============== Act_ParsleyWoodsBoss ===============
Act_ParsleyWoodsBoss:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	;--
	; For this boss, when we're frozen (by the boss), make us visibly shake
	; by moving back and forth by 1px.
	ld   a, [sPlFreezeTimer]
	or   a						; Are we frozen?
	jr   z, .chkRoutine			; If not, skip
	
	; Every 4 frames offset the player's X position.
	; First time by +1, then -1 and so on.
	ld   bc, +$01
	ld   a, [sActSetTimer]
	and  a, $03					; Timer check
	jr   nz, .chkRoutine
	
	ld   a, [sActSetTimer]		; Alternate every time we get here
	bit  2, a					; (Timer / 4) % 2 != 0?
	jr   nz, .setPlPos			; If so, jump
	ld   bc, -$01
	
.setPlPos:
	ld   a, [sPlX_Low]			; sPlX += BC
	add  c
	ld   [sPlX_Low], a
	ld   a, [sPlX_High]
	adc  a, b
	ld   [sPlX_High], a
	;--
	
.chkRoutine:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_ParsleyWoodsBoss_Main
	dw Act_ParsleyWoodsBoss_OnTouch
	dw Act_ParsleyWoodsBoss_OnTouch
	dw Act_ParsleyWoodsBoss_Main
	dw Act_ParsleyWoodsBoss_OnTouch
	dw Act_ParsleyWoodsBoss_OnTouch;X
	dw Act_ParsleyWoodsBoss_Main;X
	dw Act_ParsleyWoodsBoss_Main;X
	dw Act_ParsleyWoodsBoss_OnThrow
	
; =============== Act_ParsleyWoodsBoss_OnTouch ===============
Act_ParsleyWoodsBoss_OnTouch:
	; Every time the player touches the boss, make him freeze.
	; This collision can last multiple frames, so avoid resetting the timer
	; unless it's < $3C.
	ld   a, [sPlFreezeTimer]
	cp   a, $3C							; Were we frozen not too long ago? (FreezeTimer >= $3C)
	jr   nc, Act_ParsleyWoodsBoss_Main	; If so, skip
	ld   a, $78							; Otherwise, freeze for $78 frames
	ld   [sPlFreezeTimer], a
	
; =============== Act_ParsleyWoodsBoss_Main ===============
Act_ParsleyWoodsBoss_Main:
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_ParsleyWoodsBoss_Intro
	dw Act_ParsleyWoodsBoss_Target0
	dw Act_ParsleyWoodsBoss_Arc0
	dw Act_ParsleyWoodsBoss_Target1
	dw Act_ParsleyWoodsBoss_Arc1
	dw Act_ParsleyWoodsBoss_Target2
	dw Act_ParsleyWoodsBoss_Arc2
	dw Act_ParsleyWoodsBoss_Target3
	dw Act_ParsleyWoodsBoss_Spawn3
	dw Act_ParsleyWoodsBoss_Dead
	dw Act_ParsleyWoodsBoss_Hit
	
; =============== COMMON SUBROUTINES FOR THE BOSS ===============	
	
; =============== Act_ParsleyWoodsBoss_DoIdleAnimByHDir ===============
; Updates the actor's animation to make it look like it's always facing the player.
; To save time, this is checked every $10 frames.
Act_ParsleyWoodsBoss_DoIdleAnimByHDir:
	ld   a, [sActSetTimer]
	and  a, $0F
	ret  nz
	ld   a, LOW(OBJLstPtrTable_Act_ParsleyWoodsBoss_IdleL)					; Face left
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_ParsleyWoodsBoss_IdleL)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	mActGetPlDirHRel	; Is the player to the right of the actor?
	ret  nc				; If not, return
	ld   a, LOW(OBJLstPtrTable_Act_ParsleyWoodsBoss_IdleR)					; Face right
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_ParsleyWoodsBoss_IdleR)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	ret
	
; This pair of subroutines handles the actor's vertical and horizontal direction.
; By changing the direction at the center of the screen, the actor slows down
; and then increases speed, moving back to the other side with the cycle repeating.
; With the momentum effect in place for both coordinates, this means the boss moves in an arc.
	
; =============== Act_ParsleyWoodsBoss_DoHDirByPos ===============
; Updates the actor's horizontal direction to always move to the center of the screen.
Act_ParsleyWoodsBoss_DoHDirByPos:
	ld   a, [sActSetDir]	; Set left direction
	and  a, DIR_U|DIR_D		; Preserve vertical direction
	or   a, DIR_L
	ld   [sActSetDir], a
	
	; If the boss is on the right side of the screen, we've set the correct direction.
	ld   a, [sActSetRelX]
	add  $20				
	cp   a, $5A+$20			; sActSetRelX >= $5A?
	ret  nc					; If so, return
	
	ld   a, [sActSetDir]	; Otherwise, set right dir
	and  a, DIR_U|DIR_D
	or   a, DIR_R
	ld   [sActSetDir], a
	ret
	
; =============== Act_ParsleyWoodsBoss_DoVDirByPos ===============
; Updates the actor's vertical direction to always move to the center of the screen.
Act_ParsleyWoodsBoss_DoVDirByPos:
	ld   a, [sActSetDir]	; Set up direction
	and  a, DIR_L|DIR_R		; Preserve horizontal direction
	or   a, DIR_U
	ld   [sActSetDir], a
	
	; If the boss is on the lower side of the screen, we've set the correct direction
	ld   a, [sActSetRelY]	
	add  $20
	cp   a, $60+$20			; sActSetRelY >= $60?
	ret  nc					; If so, return
	
	ld   a, [sActSetDir]	; Otherwise, set down dir
	and  a, DIR_L|DIR_R
	or   a, DIR_D
	ld   [sActSetDir], a
	ret
	
; =============== Act_ParsleyWoodsBoss_DoHSpeed ===============	
; Handles horizontal movement speed for the boss.
Act_ParsleyWoodsBoss_DoHSpeed:
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_ParsleyWoodsBoss_IncRSpeed
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_ParsleyWoodsBoss_IncLSpeed
	ret
; =============== Act_ParsleyWoodsBoss_IncRSpeed ===============
; Increases movement speed to the right.	
Act_ParsleyWoodsBoss_IncRSpeed:
	; Check for the speed cap
	ld   a, [sActParsleyWoodsBossHSpeed_Low]
	bit  7, a				; Speed < 0?
	jr   nz, .incSpeed		; If so, skip
	cp   a, $40				; Speed > $40?
	ret  nc					; If so, return
.incSpeed:
	add  $01				; HSpeed++
	ld   [sActParsleyWoodsBossHSpeed_Low], a
	ld   a, [sActParsleyWoodsBossHSpeed_High]
	adc  a, $00
	ld   [sActParsleyWoodsBossHSpeed_High], a
	ret
; =============== Act_ParsleyWoodsBoss_IncLSpeed ===============
; Increases movement speed to the left.
Act_ParsleyWoodsBoss_IncLSpeed:
	; Check for the speed cap
	ld   a, [sActParsleyWoodsBossHSpeed_Low]
	bit  7, a				; Speed > 0?
	jr   z, .decSpeed		; If so, skip
	cp   a, -$3F			; Speed < -$40?
	ret  c					; If so, return
.decSpeed:
	sub  a, $01				; HSpeed--
	ld   [sActParsleyWoodsBossHSpeed_Low], a
	ld   a, [sActParsleyWoodsBossHSpeed_High]
	sbc  a, $00
	ld   [sActParsleyWoodsBossHSpeed_High], a
	ret
	
; =============== Act_ParsleyWoodsBoss_DoVSpeed ===============	
; Handles vertical movement speed for the boss.
Act_ParsleyWoodsBoss_DoVSpeed:
	ld   a, [sActSetDir]
	bit  DIRB_U, a
	call nz, Act_ParsleyWoodsBoss_IncUSpeed
	ld   a, [sActSetDir]
	bit  DIRB_D, a
	call nz, Act_ParsleyWoodsBoss_IncDSpeed
	ret
; =============== Act_ParsleyWoodsBoss_IncDSpeed ===============
; Increases downwards movement speed.	
Act_ParsleyWoodsBoss_IncDSpeed:
	; Check for the speed cap
	ld   a, [sActParsleyWoodsBossVSpeed]
	bit  7, a				; Speed < 0?
	jr   nz, .incSpeed		; If so, skip
	cp   a, $40				; Speed > $40?
	ret  nc					; If so, return
.incSpeed:
	add  $01				; VSpeed++
	ld   [sActParsleyWoodsBossVSpeed], a
	ret
; =============== Act_ParsleyWoodsBoss_IncUSpeed ===============
; Increases upwards movement speed.	
Act_ParsleyWoodsBoss_IncUSpeed:
	; Check for the speed cap
	ld   a, [sActParsleyWoodsBossVSpeed]
	bit  7, a				; Speed > 0?
	jr   z, .decSpeed		; If so, skip
	cp   a, -$3F			; Speed < -$40?
	ret  c					; If so, return
.decSpeed:
	sub  a, $01				; VSpeed--
	ld   [sActParsleyWoodsBossVSpeed], a
	ret	
	
; =============== mPwBossPattern ===============
; This macro generates code to make the boss move to the specified coordinate,
; picking the fastest path possible, which results in the boss moving in a diagonal line.
;
; IN
; - 1: X Target position
; - 2: Y Target position
; OUT
; - A: If 0, we reached the target position (by not moving in any direction)
MACRO mPwBossTarget
	ld   d, $00				; Init return value
	
	;
	; X MOVEMENT | 1px/frame
	;
.chkMoveH:
	ld   bc, -$01			; Start with left movement
	ld   a, [sActSetRelX]
	add  $20				; Offset for boss size
	cp   a, \1+$20			; Did we reach the target position?
	jr   z, .chkMoveV		; If so, don't move horizontally
	jr   nc, .moveH 		; If we're on the right, move left (keep val)
	ld   bc, +$01			; Otherwise, move right
.moveH:
	call ActS_MoveRight
	ld   d, $01				; Mark that the actor moved
	
	;
	; Y MOVEMENT | 0.5px/frame
	;
.chkMoveV:
	ld   a, [sActSetTimer]	; Every other frame...
	and  a, $01
	ret  nz
	ld   bc, -$01			; Start with up movement
	ld   a, [sActSetRelY]
	add  $20				; Offset for boss size
	cp   a, \2+$20			; Did we reach the target position?
	jr   z, .end			; If so, don't move vertically
	jr   nc, .moveV			; If we're below it, move up (keep val)
	ld   bc, +$01			; Otherwise, move down
.moveV:
	call ActS_MoveDown
	ld   d, $01				; Mark that the actor moved
	
.end:
	ld   a, d				; Copy over result
	ret
ENDM

;                                                 X    Y
Act_ParsleyWoodsBoss_MoveTo_X94Y60: mPwBossTarget $94, $60
Act_ParsleyWoodsBoss_MoveTo_X14Y48: mPwBossTarget $14, $48
Act_ParsleyWoodsBoss_MoveTo_X14Y60: mPwBossTarget $14, $60

; =============== Act_ParsleyWoodsBoss_SetIntro ===============
; Prepares for the boss intro.
Act_ParsleyWoodsBoss_SetIntro:
	ld   a, PWBOSS_RTN_INTRO					; Set first routine
	ld   [sActLocalRoutineId], a
	ld   bc, $0040							; Move 4 blocks below (off-screen)
	call ActS_MoveDown
	push bc
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBoss_TargetL
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_ParsleyWoodsBoss_Intro ===============
; Intro. Boss moves to a certain coordinate.
Act_ParsleyWoodsBoss_Intro:
	call ActS_IncOBJLstIdEvery8
	call Act_ParsleyWoodsBoss_MoveTo_X94Y60
	or   a										; Did we reach the target?
	jr   z, Act_ParsleyWoodsBoss_SwitchToArc0	; If so, jump
	ret
	
; =============== Act_ParsleyWoodsBoss_SwitchToTarget0 ===============
Act_ParsleyWoodsBoss_SwitchToTarget0:
	ld   a, PWBOSS_RTN_TARGET0
	ld   [sActLocalRoutineId], a
	push bc
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBoss_TargetL
	call ActS_SetOBJLstPtr
	pop  bc
	; Restore collision box and transparency effect
	ld   a, -$1C
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$0C
	ld   [sActSetColiBoxL], a
	ld   a, +$0C
	ld   [sActSetColiBoxR], a
	
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ld   a, [sActNumProc]			
	ld   [sActSlotTransparent], a
	ret
	
; =============== Act_ParsleyWoodsBoss_Target0 ===============
; Boss moves to a certain coordinate after looping...
; [POI] ...but it's identical to Intro. 
Act_ParsleyWoodsBoss_Target0:
	call ActS_IncOBJLstIdEvery8
	call Act_ParsleyWoodsBoss_MoveTo_X94Y60
	or   a										; Did we reach the target?
	jp   z, Act_ParsleyWoodsBoss_SwitchToArc0	; If so, jump
	ret
	
; =============== Act_ParsleyWoodsBoss_SwitchToArc0 ===============
Act_ParsleyWoodsBoss_SwitchToArc0:
	ld   a, PWBOSS_RTN_ARC0
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSetOBJLstId], a
	ld   [sActParsleyWoodsBossModeTimer], a
	ld   [sActParsleyWoodsBossHSpeed_Low], a
	ld   [sActParsleyWoodsBossHSpeed_High], a
	ld   a, $0C
	ld   [sActParsleyWoodsBossVSpeed], a
	ret
	
; =============== Act_ParsleyWoodsBoss_SwitchToArc0 ===============
; Moves the boss in a circle-like motion.
Act_ParsleyWoodsBoss_Arc0:
	call ActS_IncOBJLstIdEvery8
	call Act_ParsleyWoodsBoss_DoIdleAnimByHDir
	
	;--
	; Don't check for the X coordinate until the timer reaches $1E.
	; This is because the boss starts on the right side of the screen -- we don't want to switch mode directly.
	; This amount is long enough for the actor to move away from the right side of the screen.
	; It will be triggered when the actor moves back again on the right (thanks to the auto dir system).
	ld   a, [sActParsleyWoodsBossModeTimer]
	cp   a, $1E									; Timer > $1E?
	jr   nc, .chkEndMode						; If so, jump
	inc  a
	ld   [sActParsleyWoodsBossModeTimer], a
	jr   .arcMove								; Otherwise skip
.chkEndMode:
	ld   a, [sActSetRelX]
	add  $20
	cp   a, $94+$20								; Are we on the right of X $94?			
	jp   nc, .endMode							; If so, switch to the next mode
	;--
.arcMove:
	;
	; Handle the circle-like movement motion.
	; This is done by updating the standard momentum values at normal,
	; but dividing the horizontal and vertical speed by different amounts.
	;
	
	;--
	; Increase movement speed every other frame
	ld   a, [sActSetTimer]
	and  a, $01
	call z, Act_ParsleyWoodsBoss_DoHSpeed
	ld   a, [sActSetTimer]
	and  a, $01
	call z, Act_ParsleyWoodsBoss_DoVSpeed
	;--
	; Update direction depending on the side
	call Act_ParsleyWoodsBoss_DoHDirByPos
	call Act_ParsleyWoodsBoss_DoVDirByPos
	
	;--
	; Move horizontally by sActParsleyWoodsBossHSpeed / 8
	ld   a, [sActParsleyWoodsBossHSpeed_Low]	
	sra  a
	sra  a
	sra  a
	ld   c, a
	ld   a, [sActParsleyWoodsBossHSpeed_High]
	ld   b, a
	call ActS_MoveRight
	
	;--
	; Move vertically by sActParsleyWoodsBossVSpeed / 4
	ld   a, [sActParsleyWoodsBossVSpeed]
	sra  a
	sra  a
	; We've got to sign-extend the speed value
	ld   b, $00			; B = Upper byte when positive
	ld   c, a			; C = Low Byte
	bit  7, a			; Is sActParsleyWoodsBossVSpeed > 0?
	jr   z, .moveV		; If so, skip
	ld   b, $FF			; B = Upper byte when negative
.moveV:
	call ActS_MoveDown
	ret
	
.endMode:
	ld   a, PWBOSS_RTN_TARGET1
	ld   [sActLocalRoutineId], a
	
	push bc						; Set throw anim
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBoss_TargetL
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set new collision box when throwing, which is slightly smaller
	ld   a, -$1C
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$0C
	ld   [sActSetColiBoxL], a
	ld   a, +$0C
	ld   [sActSetColiBoxR], a
	
	; Spawn immediately the helper actor, though there's a delay before it actually activates
	call Act_ParsleyWoodsBoss_SpawnGhostGoom
	
	xor  a
	ld   [sActParsleyWoodsBossModeTimer], a
	ret
	
; =============== Act_ParsleyWoodsBoss_Target1 ===============
; Moves the actor to the left of the screen.
Act_ParsleyWoodsBoss_Target1:
	call ActS_IncOBJLstIdEvery8
	call Act_ParsleyWoodsBoss_DoIdleAnimByHDir
	call Act_ParsleyWoodsBoss_MoveTo_X14Y60
	or   a									; Reached the target?
	ret  nz									; If not, return
	
	; After that, wait for $28 frames before switching
	ld   a, [sActParsleyWoodsBossModeTimer]
	inc  a
	ld   [sActParsleyWoodsBossModeTimer], a
	cp   a, $28
	ret  c
	jp   .endMode
.endMode:
	ld   a, PWBOSS_RTN_ARC1
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSetOBJLstId], a
	ld   [sActParsleyWoodsBossModeTimer], a
	ld   [sActParsleyWoodsBossHSpeed_Low], a
	ld   [sActParsleyWoodsBossHSpeed_High], a
	ld   a, $18
	ld   [sActParsleyWoodsBossVSpeed], a
	ret
	
; =============== Act_ParsleyWoodsBoss_Arc1 ===============
; Half-circle-like motion.
; See also: Act_ParsleyWoodsBoss_Arc0
Act_ParsleyWoodsBoss_Arc1:
	call ActS_IncOBJLstIdEvery8
	call Act_ParsleyWoodsBoss_DoIdleAnimByHDir
	
	;--
	; Don't check for the X coordinate until the timer reaches $1E.
	ld   a, [sActParsleyWoodsBossModeTimer]
	cp   a, $1E									; Timer > $1E?
	jr   nc, .chkEndMode						; If so, jump
	inc  a
	ld   [sActParsleyWoodsBossModeTimer], a
	jr   .arcMove								; Otherwise skip
.chkEndMode:
	ld   a, [sActSetRelX]
	add  $20
	cp   a, $94+$20								; Are we on the right of X $94?			
	jp   nc, .endMode							; If so, switch to the next mode
	;--
.arcMove:
	;--
	; Increase movement speed every other frame
	ld   a, [sActSetTimer]
	and  a, $01
	call z, Act_ParsleyWoodsBoss_DoHSpeed
	ld   a, [sActSetTimer]
	and  a, $01
	call z, Act_ParsleyWoodsBoss_DoVSpeed
	; Update direction depending on the side
	call Act_ParsleyWoodsBoss_DoHDirByPos
	call Act_ParsleyWoodsBoss_DoVDirByPos
	
	
	;--
	; Move horizontally by sActParsleyWoodsBossHSpeed / 8
	ld   a, [sActParsleyWoodsBossHSpeed_Low]
	sra  a
	sra  a
	sra  a
	ld   c, a
	ld   a, [sActParsleyWoodsBossHSpeed_High]
	ld   b, a
	call ActS_MoveRight
	
	;--
	; Move vertically by sActParsleyWoodsBossVSpeed / 8
	ld   a, [sActParsleyWoodsBossVSpeed]
	sra  a
	sra  a
	sra  a
	ld   b, $00			; Do sign extension
	ld   c, a
	bit  7, a
	jr   z, .moveV
	ld   b, $FF
.moveV:
	call ActS_MoveDown
	ret
	
.endMode:
	; Spawn more ghosts as before
	ld   a, PWBOSS_RTN_TARGET2
	ld   [sActLocalRoutineId], a
	push bc
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBoss_TargetL
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, -$1C
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$0C
	ld   [sActSetColiBoxL], a
	ld   a, +$0C
	ld   [sActSetColiBoxR], a
	
	call Act_ParsleyWoodsBoss_SpawnGhostGoom
	xor  a
	ld   [sActParsleyWoodsBossModeTimer], a
	ret
	
; =============== Act_ParsleyWoodsBoss_Target2 ===============
; Moves center-right, and waits.
Act_ParsleyWoodsBoss_Target2:;I
	call ActS_IncOBJLstIdEvery8
	call Act_ParsleyWoodsBoss_DoIdleAnimByHDir
	call Act_ParsleyWoodsBoss_MoveTo_X94Y60
	or   a									; Reached the target?
	ret  nz									; If not, return
	
	; After that, wait for $28 frames before switching
	ld   a, [sActParsleyWoodsBossModeTimer]
	inc  a
	ld   [sActParsleyWoodsBossModeTimer], a
	cp   a, $28
	ret  c
	jp   .endMode
.endMode:
	ld   a, PWBOSS_RTN_ARC2
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSetOBJLstId], a
	ld   [sActParsleyWoodsBossModeTimer], a
	ld   [sActParsleyWoodsBossHSpeed_Low], a
	ld   [sActParsleyWoodsBossHSpeed_High], a
	ld   a, $18
	ld   [sActParsleyWoodsBossVSpeed], a
	ret
	
; =============== Act_ParsleyWoodsBoss_Target2 ===============
; Moves in a Y oscillating pattern.
Act_ParsleyWoodsBoss_Arc2:
	call ActS_IncOBJLstIdEvery8
	call Act_ParsleyWoodsBoss_DoIdleAnimByHDir
	
	;--
	; Don't check for the X coordinate until the timer reaches $1E.
	ld   a, [sActParsleyWoodsBossModeTimer]
	cp   a, $1E									; Timer < $1E?
	jr   c, .arcMove							; If so, skip
.chkEndMode:
	ld   a, [sActSetRelX]
	add  $20
	cp   a, $94+$20								; Are we on the right of X $94?			
	jp   nc, .endMode							; If so, switch to the next mode
.arcMove:
	;--
	; Increase movement speed to a whatever direction every other frame
	call Act_ParsleyWoodsBoss_DoVDirByPos
	ld   a, [sActSetTimer]
	and  a, $01
	call z, Act_ParsleyWoodsBoss_DoVSpeed
	;--
	; Move vertically by sActParsleyWoodsBossVSpeed / 8
	ld   a, [sActParsleyWoodsBossVSpeed]
	sra  a
	sra  a
	sra  a
	ld   b, $00			; Do sign extension
	ld   c, a
	bit  7, a
	jr   z, .moveV
	ld   b, $FF
.moveV:
	call ActS_MoveDown
	
	; Move horizontally 0.5px/frame.
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	; Depending on the timer, pick a direction
	ld   a, [sActParsleyWoodsBossModeTimer]
	inc  a
	ld   [sActParsleyWoodsBossModeTimer], a
	ld   bc, +$01
	cp   a, $78			; Timer >= $78?
	jr   nc, .moveH	; If so, move right
	ld   bc, -$01		; Otherwise, move left
.moveH:
	call ActS_MoveRight
	ret
.endMode:
	ld   a, PWBOSS_RTN_TARGET3
	ld   [sActLocalRoutineId], a
	push bc
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBoss_TargetL
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, -$1C
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$0C
	ld   [sActSetColiBoxL], a
	ld   a, +$0C
	ld   [sActSetColiBoxR], a
	
	xor  a
	ld   [sActParsleyWoodsBossModeTimer], a
	ret
	
; =============== Act_ParsleyWoodsBoss_Target3 ===============
; Moves center-left, and waits.
Act_ParsleyWoodsBoss_Target3:
	call ActS_IncOBJLstIdEvery8
	call Act_ParsleyWoodsBoss_MoveTo_X14Y48
	or   a									; Reached the target?
	ret  nz									; If not, return
	
	; After that, wait for $28 frames before switching
	ld   a, [sActParsleyWoodsBossModeTimer]
	inc  a
	ld   [sActParsleyWoodsBossModeTimer], a
	cp   a, $28
	ret  c
	jp   .endMode
.endMode:
	ld   a, PWBOSS_RTN_SPAWN3
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSetOBJLstId], a
	ld   [sActParsleyWoodsBossModeTimer], a
	ld   [sActParsleyWoodsBossHSpeed_Low], a
	ld   [sActParsleyWoodsBossHSpeed_High], a
	
	; [POI] Open the bag... which really hard to see since it almost immediately
	;       switches back to the main anim.
	push bc
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBoss_Bag
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, -$12
	ld   [sActSetColiBoxU], a
	ld   a, -$0A
	ld   [sActSetColiBoxD], a
	ld   a, -$0C
	ld   [sActSetColiBoxL], a
	ld   a, +$02
	ld   [sActSetColiBoxR], a
	
	call Act_ParsleyWoodsBoss_DoHDirByPos
	ret
	
; =============== Act_ParsleyWoodsBoss_Spawn3 ===============
; Spawn 3 ghosts.
Act_ParsleyWoodsBoss_Spawn3:
	; Animate every $10 frames
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .chkEndMode
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.chkEndMode:
	call Act_ParsleyWoodsBoss_DoIdleAnimByHDir
	
	; Spawn 3 ghosts, at timer ticks $20, $40 and $60
	ld   a, [sActParsleyWoodsBossModeTimer]
	and  a, $1F
	call z, Act_ParsleyWoodsBoss_SpawnGhostGoom
	
	; Handle the timer
	ld   a, [sActParsleyWoodsBossModeTimer]
	inc  a
	ld   [sActParsleyWoodsBossModeTimer], a
	cp   a, $78
	jp   nc, Act_ParsleyWoodsBoss_SwitchToTarget0
	ret
	
; =============== Act_ParsleyWoodsBoss_SpawnGhostGoom ===============
; Spawns a variant of the ghost goom used for the boss fight.
Act_ParsleyWoodsBoss_SpawnGhostGoom:

	; Find a free slot
	ld   hl, sAct				; HL = Actor slot area
	ld   d, ACTSLOT_COUNT_LO	; D = Total slots
	ld   e, $00					; E = Current slot
	ld   c, $00					; C = Ghosts spawned
.checkSlot:
	ld   a, [hl]		; Read active status
	or   a				; Is the slot marked as active?
	jr   z, .slotFound	; If not, we found a slot
	
	;--
	; Enforce the limit of 3 ghosts on-screen.
	; This is added on top of the checkSlot code, so while technically it's possible
	; to free some slots earlier on to make it spawn more ghosts, it isn't an issue (and it wouldn't really be either).
	
	ld   a, l				; Seek to actor ID
	add  (sActSetId-sActSet)
	ld   l, a
	ld   a, [hl]
	cp   a, $02				; Is it a ghost?
	call z, .incGhostCount	; If so, increase the count
	;--
	; [POI] Ghosts are spawned as coins first, so count them as well
	cp   a, ACT_COIN		; Is it a coin?
	call z, .incGhostCount	; If so, increase the count
	;--
	ld   a, c				
	cp   a, $03				; Are there (at least), 3 ghosts on screen?
	ret  nc					; If so, don't spawn any more
	;--
	inc  e					; Slot++
	dec  d					; Have we searched in all 5 slots?
	ret  z					; If so, return
	ld   a, l				; Move to next slot
	add  LOW(sActSet_End - (sActSetId-sActSet))
	ld   l, a
	jr   .checkSlot
.incGhostCount:
	inc  c					; GhostCount++
	ret
.slotFound:
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_ParsleyWoodsBossGhostGoom
	
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
	
	; Initially deal damage on both sides
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ldi  [hl], a
	
	ld   a, -$0A			; Coli box U
	ldi  [hl], a
	ld   a, -$04			; Coli box D
	ldi  [hl], a
	ld   a, -$08			; Coli box L
	ldi  [hl], a
	ld   a, +$08			; Coli box R
	ldi  [hl], a
	
	ld   a, $00
	ldi  [hl], a			; Rel.Y (Origin)
	ldi  [hl], a			; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_None)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_None)
	ldi  [hl], a
	
	ld   a, [sActSetDir]	; Same direction as boss
	ldi  [hl], a			; (makes it go across the screen)
	
	xor  a					; OBJLst ID
	ldi  [hl], a
	
	; This is set to this value purely to make it appear as a coin
	; (the actor ID determines which graphics the actor uses, among other things)
	ld   a, ACT_COIN		; Actor ID
	ldi  [hl], a
	
	xor  a					; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_ParsleyWoodsBossGhostGoom)	; Code ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_ParsleyWoodsBossGhostGoom)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a			; Timer
	ldi  [hl], a			; Timer 2
	
	ld   bc, -$03
	ld   a, c
	ldi  [hl], a			; Y Speed
	ld   a, b
	ldi  [hl], a			; Y Speed (high)
	xor  a
	ldi  [hl], a			; Timer 5
	ldi  [hl], a			; Timer 6
	ldi  [hl], a			; Timer 7
	
	xor  a					; Flags
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_ParsleyWoodsBossGhostGoom)
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_ParsleyWoodsBossGhostGoom)
	ld   [hl], a
	
	ld   a, SFX1_10
	ld   [sSFX1Set], a
	ret
	
; =============== Act_ParsleyWoodsBoss_OnThrow ===============
; Handles what happens when an actor is thrown.
Act_ParsleyWoodsBoss_OnThrow:

	; Only thrown Ghost Gooms should hit the boss.
	; Default actors like 10-coins shouldn't, so filter them away
	mActCheckThrownId ACT_DEFAULT_BASE	; Was it thrown a default actor? ( >= $07)
	jp   nc, Act_ParsleyWoodsBoss_Main	; If so, ignore
	
	;--
	; Make sure we actually threw the actor, and didn't just hold it while moving torwards the boss.
	; This can be done by checking if the actor's code pointer points to SubCall_ActS_DoJumpDead2,
	; which ends up being set when the goom collides with the boss.
	
	; Offset the code ptr of the thrown actor
	ld   hl, sAct+(sActSetCodePtr-sActSet)
	add  hl, de							; Offset the slot (we got DE in mActCheckThrownId)
	
	ld   bc, SubCall_ActS_DoJumpDead2	; BC = Blacklisted target
	ldi  a, [hl]						; Read low byte
	cp   a, c							; Do they match?
	jr   nz, Act_ParsleyWoodsBoss_SetHit; If not, skip
	ld   a, [hl]						; Read high byte
	cp   a, b							; Do they match?
	ret  z								; If so, return
	;--
	
; =============== Act_ParsleyWoodsBoss_SetHit ===============
Act_ParsleyWoodsBoss_SetHit:
	ld   a, SFX1_2C
	ld   [sSFX1Set], a
	ld   a, $FF								; Pause transparency effect
	ld   [sActSlotTransparent], a
	xor  a									; Make invulnerable
	ld   [sActSetColiType], a
	ld   a, [sActParsleyWoodsBossHitCount]	; Register the hit
	inc  a
	ld   [sActParsleyWoodsBossHitCount], a
	cp   a, $03								; Did we hit 3 times?
	jp   nc, Act_ParsleyWoodsBoss_SetDead	; If so, set as defeated
	
	; Otherwise...
	ld   a, PWBOSS_RTN_HIT
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSetOBJLstId], a
	ld   [sActParsleyWoodsBossModeTimer], a
	
	;--
	; Make boss face the player
	ld   a, DIR_L
	ld   [sActSetDir], a
	push bc
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBoss_StunL
	call ActS_SetOBJLstPtr
	pop  bc
	
	; If the player is to the left of the actor, we got the direction right
	ld   a, [sActSetRelX]	; B = ActX
	add  $20				; Fix for underflow
	ld   b, a
	ld   a, [sPlXRel]		; A = PlX
	add  $20
	cp   a, b				; PlX - ActX < 0? (PlX < ActX)
	ret  c					; If so, return
	
	; Otherwise, set the other dir
	ld   a, DIR_R
	ld   [sActSetDir], a
	push bc
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBoss_StunR
	call ActS_SetOBJLstPtr
	pop  bc
	
	ret
	
; =============== Act_ParsleyWoodsBoss_Hit ===============
; Stun routine.
Act_ParsleyWoodsBoss_Hit:
	ld   a, [sActParsleyWoodsBossModeTimer]
	inc  a
	ld   [sActParsleyWoodsBossModeTimer], a
	cp   a, $1E
	jp   nc, Act_ParsleyWoodsBoss_SwitchToTarget0
	ret
	
; =============== Act_ParsleyWoodsBoss_SetDead ===============
; Marks the boss as defeated.
Act_ParsleyWoodsBoss_SetDead:
	ld   a, PWBOSS_RTN_DEAD
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSetOBJLstId], a
	ld   [sActParsleyWoodsBossModeTimer], a
	
	mActSetYSpeed -$03
	
	ld   a, SFX1_09
	ld   [sSFX1Set], a
	ld   a, BGM_NONE
	ld   [sBGMSet], a
	
IF !OPTIMIZE
	call ActS_DespawnAllNormExceptCur_Broken
ENDC
	
	ld   a, $01
	ld   [sActBossDead], a
	xor  a						; Get rid of whatever we have in hand
	ld   [sActHeld], a
	
	;--
	; Make boss face the player
	ld   a, DIR_L
	ld   [sActSetDir], a
	push bc
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBoss_DeadL
	call ActS_SetOBJLstPtr
	pop  bc
	
	; If the player is to the left of the actor, we got the direction right
	ld   a, [sActSetRelX]	; B = ActX
	add  $20				; Fix for underflow
	ld   b, a
	ld   a, [sPlXRel]		; A = PlX
	add  $20
	cp   a, b				; PlX - ActX < 0? (PlX < ActX)
	ret  c					; If so, return
	
	; Otherwise, set the other dir
	ld   a, DIR_R
	ld   [sActSetDir], a
	push bc
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBoss_DeadR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_ParsleyWoodsBoss_Dead ===============
; Handles the death jump + Coin Game.
Act_ParsleyWoodsBoss_Dead:
	call ActS_FallDownEvery8
	
	; Wait for $64 frames while the boss moves down, before starting the coin game
	ld   a, [sActParsleyWoodsBossModeTimer]
	cp   a, $64
	jr   nc, .coinGame
	inc  a
	ld   [sActParsleyWoodsBossModeTimer], a
	
	; The last frame we get here, set the music 
	cp   a, $64
	ret  nz
	ld   a, BGM_COINGAME
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	ret
.coinGame:
	call SubCall_ActS_CoinGame
	ret
	
OBJLstSharedPtrTable_Act_ParsleyWoodsBoss:
	dw OBJLstPtrTable_Act_ParsleyWoodsBoss_DeadL;X
	dw OBJLstPtrTable_Act_ParsleyWoodsBoss_DeadR;X
	dw OBJLstPtrTable_Act_ParsleyWoodsBoss_DeadL;X
	dw OBJLstPtrTable_Act_ParsleyWoodsBoss_DeadR;X
	dw OBJLstPtrTable_Act_ParsleyWoodsBoss_DeadL;X
	dw OBJLstPtrTable_Act_ParsleyWoodsBoss_DeadR;X
	dw OBJLstPtrTable_Act_ParsleyWoodsBoss_DeadL;X
	dw OBJLstPtrTable_Act_ParsleyWoodsBoss_DeadR;X

OBJLstSharedPtrTable_Act_ParsleyWoodsBossGhostGoom:
	dw OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_RecoverL;X
	dw OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_RecoverR;X
	dw OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_RecoverL
	dw OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_RecoverR
	dw OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_StunL
	dw OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_StunR
	dw OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_StunL;X
	dw OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_StunR;X

OBJLstPtrTable_Act_ParsleyWoodsBoss_IdleL:
	dw OBJLst_Act_ParsleyWoodsBoss_IdleL0
	dw OBJLst_Act_ParsleyWoodsBoss_IdleL1
	dw $0000
OBJLstPtrTable_Act_ParsleyWoodsBoss_IdleR:
	dw OBJLst_Act_ParsleyWoodsBoss_IdleR0
	dw OBJLst_Act_ParsleyWoodsBoss_IdleR1
	dw $0000
OBJLstPtrTable_Act_ParsleyWoodsBoss_TargetL:
	dw OBJLst_Act_ParsleyWoodsBoss_IdleL0
	dw OBJLst_Act_ParsleyWoodsBoss_IdleL2
	dw $0000
OBJLstPtrTable_Act_ParsleyWoodsBoss_Unused_TargetR:
	dw OBJLst_Act_ParsleyWoodsBoss_IdleR0;X
	dw OBJLst_Act_ParsleyWoodsBoss_Unused_IdleR2;X
	dw $0000;X
OBJLstPtrTable_Act_ParsleyWoodsBoss_DeadL:
	dw OBJLst_Act_ParsleyWoodsBoss_DeadL;X
	dw $0000;X
OBJLstPtrTable_Act_ParsleyWoodsBoss_DeadR:
	dw OBJLst_Act_ParsleyWoodsBoss_DeadR
	dw $0000;X
OBJLstPtrTable_Act_ParsleyWoodsBoss_StunL:
	dw OBJLst_Act_ParsleyWoodsBoss_StunL;X
	dw $0000;X
OBJLstPtrTable_Act_ParsleyWoodsBoss_StunR:
	dw OBJLst_Act_ParsleyWoodsBoss_StunR
	dw $0000;X
; This only contains the bag itself.
OBJLstPtrTable_Act_ParsleyWoodsBoss_Bag:
	dw OBJLst_Act_ParsleyWoodsBoss_BagL0
	dw OBJLst_Act_ParsleyWoodsBoss_BagL1
	dw $0000;X
	
; [TCRF] Unused 1-frame variant of the one below,
;        likely meant to be used when the boss was preparing to throw a ghost.
OBJLstPtrTable_Act_ParsleyWoodsBoss_Unused_PreThrowL:
	dw OBJLst_Act_ParsleyWoodsBoss_Unused_ThrowL0;X
	dw $0000;X
OBJLstPtrTable_Act_ParsleyWoodsBoss_Unused_PreThrowR:
	dw OBJLst_Act_ParsleyWoodsBoss_Unused_ThrowR0;X
	dw $0000;X
	
; [TCRF] Unused animation for the boss throwing ghosts out of the bag.
;        Instead of using these, the animation for moving to a target gets reused.
OBJLstPtrTable_Act_ParsleyWoodsBoss_Unused_ThrowL:
	dw OBJLst_Act_ParsleyWoodsBoss_Unused_ThrowL0;X
	dw OBJLst_Act_ParsleyWoodsBoss_Unused_ThrowL1;X
	dw OBJLst_Act_ParsleyWoodsBoss_IdleL0;X
	dw OBJLst_Act_ParsleyWoodsBoss_IdleL0;X
	dw $0000;X
OBJLstPtrTable_Act_ParsleyWoodsBoss_Unused_ThrowR:
	dw OBJLst_Act_ParsleyWoodsBoss_Unused_ThrowR0;X
	dw OBJLst_Act_ParsleyWoodsBoss_Unused_ThrowR1;X
	dw OBJLst_Act_ParsleyWoodsBoss_IdleR0;X
	dw OBJLst_Act_ParsleyWoodsBoss_IdleR0;X
	dw $0000;X
	
OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_MoveL:
	dw OBJLst_Act_ParsleyWoodsBossGhostGoom_MoveL0
	dw OBJLst_Act_ParsleyWoodsBossGhostGoom_MoveL1
	dw $0000
OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_MoveR:
	dw OBJLst_Act_ParsleyWoodsBossGhostGoom_MoveR0
	dw OBJLst_Act_ParsleyWoodsBossGhostGoom_MoveR1
	dw $0000
OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_StunL:
	dw OBJLst_Act_ParsleyWoodsBossGhostGoom_StunL
	dw $0000
OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_StunR:
	dw OBJLst_Act_ParsleyWoodsBossGhostGoom_StunR
	dw $0000
OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_RecoverL:
	dw OBJLst_Act_ParsleyWoodsBossGhostGoom_RecoverL
	dw $0000
OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_RecoverR:
	dw OBJLst_Act_ParsleyWoodsBossGhostGoom_RecoverR
	dw $0000
OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_Coin:
	dw OBJLst_Act_ParsleyWoodsBossGhostGoom_Coin0
	dw OBJLst_Act_ParsleyWoodsBossGhostGoom_Coin1
	dw OBJLst_Act_ParsleyWoodsBossGhostGoom_Coin0
	dw OBJLst_Act_ParsleyWoodsBossGhostGoom_Coin2
	dw $0000

OBJLst_Act_ParsleyWoodsBoss_IdleL0: INCBIN "data/objlst/actor/parsleywoodsboss_idlel0.bin"
OBJLst_Act_ParsleyWoodsBoss_IdleL1: INCBIN "data/objlst/actor/parsleywoodsboss_idlel1.bin"
OBJLst_Act_ParsleyWoodsBoss_IdleL2: INCBIN "data/objlst/actor/parsleywoodsboss_idlel2.bin"
OBJLst_Act_ParsleyWoodsBoss_Unused_ThrowL1: INCBIN "data/objlst/actor/parsleywoodsboss_unused_throwl1.bin"
OBJLst_Act_ParsleyWoodsBoss_Unused_ThrowL0: INCBIN "data/objlst/actor/parsleywoodsboss_unused_throwl0.bin"
OBJLst_Act_ParsleyWoodsBoss_StunL: INCBIN "data/objlst/actor/parsleywoodsboss_stunl.bin"
OBJLst_Act_ParsleyWoodsBossGhostGoom_MoveL0: INCBIN "data/objlst/actor/parsleywoodsbossghostgoom_movel0.bin"
OBJLst_Act_ParsleyWoodsBossGhostGoom_MoveL1: INCBIN "data/objlst/actor/parsleywoodsbossghostgoom_movel1.bin"
OBJLst_Act_ParsleyWoodsBossGhostGoom_StunL: INCBIN "data/objlst/actor/parsleywoodsbossghostgoom_stunl.bin"
OBJLst_Act_ParsleyWoodsBossGhostGoom_RecoverL: INCBIN "data/objlst/actor/parsleywoodsbossghostgoom_recoverl.bin"
OBJLst_Act_ParsleyWoodsBoss_BagL0: INCBIN "data/objlst/actor/parsleywoodsboss_bagl0.bin"
OBJLst_Act_ParsleyWoodsBoss_BagL1: INCBIN "data/objlst/actor/parsleywoodsboss_bagl1.bin"
OBJLst_Act_ParsleyWoodsBoss_DeadL: INCBIN "data/objlst/actor/parsleywoodsboss_deadl.bin"
OBJLst_Act_ParsleyWoodsBoss_IdleR0: INCBIN "data/objlst/actor/parsleywoodsboss_idler0.bin"
OBJLst_Act_ParsleyWoodsBoss_IdleR1: INCBIN "data/objlst/actor/parsleywoodsboss_idler1.bin"
OBJLst_Act_ParsleyWoodsBoss_Unused_IdleR2: INCBIN "data/objlst/actor/parsleywoodsboss_unused_idler2.bin"
OBJLst_Act_ParsleyWoodsBoss_Unused_ThrowR1: INCBIN "data/objlst/actor/parsleywoodsboss_unused_throwr1.bin"
OBJLst_Act_ParsleyWoodsBoss_Unused_ThrowR0: INCBIN "data/objlst/actor/parsleywoodsboss_unused_throwr0.bin"
OBJLst_Act_ParsleyWoodsBoss_StunR: INCBIN "data/objlst/actor/parsleywoodsboss_stunr.bin"
OBJLst_Act_ParsleyWoodsBossGhostGoom_MoveR0: INCBIN "data/objlst/actor/parsleywoodsbossghostgoom_mover0.bin"
OBJLst_Act_ParsleyWoodsBossGhostGoom_MoveR1: INCBIN "data/objlst/actor/parsleywoodsbossghostgoom_mover1.bin"
OBJLst_Act_ParsleyWoodsBossGhostGoom_StunR: INCBIN "data/objlst/actor/parsleywoodsbossghostgoom_stunr.bin"
OBJLst_Act_ParsleyWoodsBossGhostGoom_RecoverR: INCBIN "data/objlst/actor/parsleywoodsbossghostgoom_recoverr.bin"
; [TCRF] Right facing variation doesn't get used
OBJLst_Act_ParsleyWoodsBoss_Unused_BagR0: INCBIN "data/objlst/actor/parsleywoodsboss_unused_bagr0.bin"
OBJLst_Act_ParsleyWoodsBoss_Unused_BagR1: INCBIN "data/objlst/actor/parsleywoodsboss_unused_bagr1.bin"
OBJLst_Act_ParsleyWoodsBoss_DeadR: INCBIN "data/objlst/actor/parsleywoodsboss_deadr.bin"
; Also contains a copy of the ghosts themselves
GFX_Act_ParsleyWoodsBoss: INCBIN "data/gfx/actor/parsleywoodsboss.bin"
OBJLst_Act_ParsleyWoodsBossGhostGoom_Coin0: INCBIN "data/objlst/actor/parsleywoodsbossghostgoom_coin0.bin"
OBJLst_Act_ParsleyWoodsBossGhostGoom_Coin1: INCBIN "data/objlst/actor/parsleywoodsbossghostgoom_coin1.bin"
OBJLst_Act_ParsleyWoodsBossGhostGoom_Coin2: INCBIN "data/objlst/actor/parsleywoodsbossghostgoom_coin2.bin"

; =============== ActInit_ParsleyWoodsBossGhostGoom ===============
; Variant of the ghost goom which always moves and never turns direction.
; Because of how it is spawned, this is only called when the actor recovers after being stunned.
ActInit_ParsleyWoodsBossGhostGoom:
	; Setup collision box
	ld   a, -$0A
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	; Setup main code
	ld   bc, SubCall_Act_ParsleyWoodsBossGhostGoom
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_MoveL
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_ParsleyWoodsBossGhostGoom
	call ActS_SetOBJLstSharedTablePtr
	
	ld   a, BGHOST_RTN_MOVE					; Skip spawn anim
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSetTimer6], a
	ld   [sActStoveCanyonBossHitCount], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_ParsleyWoodsBossGhostGoom ===============
Act_ParsleyWoodsBossGhostGoom:
	; If the parent boss died, kill the actor as well
	ld   a, [sActBossDead]
	or   a
	jp   nz, SubCall_ActS_StartJumpDead
	
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	call ActS_IncOBJLstIdEvery8
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_ParsleyWoodsBossGhostGoom_Intro
	dw Act_ParsleyWoodsBossGhostGoom_Move
	dw Act_ParsleyWoodsBossGhostGoom_Stun
	
; =============== Act_ParsleyWoodsBossGhostGoom_Intro ===============
; Actor is thrown by the boss, dropping like a coin.
Act_ParsleyWoodsBossGhostGoom_Intro:
	ld   a, LOW(OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_Coin)
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_Coin)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	
	; Handle horizontal movement
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, ActS_MoveRight1
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, ActS_MoveLeft1
	; Handle vertical jump effect
	call ActS_FallDownMax4Speed
	
	; Wait for $24 frames while moving down
	ld   a, [sActParsleyWoodsBossGhostModeTimer]
	inc  a
	ld   [sActParsleyWoodsBossGhostModeTimer], a
	cp   a, $24
	ret  c
	
	ld   a, BGHOST_RTN_MOVE
	ld   [sActLocalRoutineId], a
	
	xor  a
	ld   [sActParsleyWoodsBossGhostModeTimer], a
	
	; Hardcoded ID assumption
	ld   a, $02				; Switch to the actual actor ID
	ld   [sActSetId], a
	ld   a, SFX1_29
	ld   [sSFX1Set], a
	
	;--
	; Make the actor face the player
	ld   a, DIR_L			; left?
	ld   [sActSetDir], a
	push bc
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_MoveL
	call ActS_SetOBJLstPtr
	pop  bc
	
	; If the player is to the left of the actor, we got the direction right
	ld   a, [sActSetRelX]	; B = ActX
	add  $20				; Fix for underflow
	ld   b, a
	ld   a, [sPlXRel]		; A = PlX
	add  $20
	cp   a, b				; PlX - ActX < 0? (PlX < ActX)
	ret  c					; If so, return
	
	; Otherwise, set the other dir
	ld   a, DIR_R
	ld   [sActSetDir], a
	push bc
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_MoveR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_ParsleyWoodsBossGhostGoom_Move ===============
; Main movement mode.
Act_ParsleyWoodsBossGhostGoom_Move:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_ParsleyWoodsBossGhostGoom_Move_Main
	dw Act_ParsleyWoodsBossGhostGoom_Move_Main
	dw Act_ParsleyWoodsBossGhostGoom_OnStun
	dw Act_ParsleyWoodsBossGhostGoom_Move_Main
	dw Act_ParsleyWoodsBossGhostGoom_OnStun
	dw Act_ParsleyWoodsBossGhostGoom_Move_Main
	dw Act_ParsleyWoodsBossGhostGoom_Move_Main;X
	dw Act_ParsleyWoodsBossGhostGoom_Move_Main
	dw SubCall_ActS_StartJumpDeadSameColi
	
; =============== Act_ParsleyWoodsBossGhostGoom_Move_Main ===============
Act_ParsleyWoodsBossGhostGoom_Move_Main:
	; Handle the timer.
	; Once it expires, stop tracking the player vertically.
	ld   a, [sActParsleyWoodsBossGhostModeTimer]
	cp   a, $64
	jr   nc, .move
	inc  a
	ld   [sActParsleyWoodsBossGhostModeTimer], a
	;--
.checkVDir:
	; Otherwise, make the actor always move torwards the player vertically.
	ld   d, DIR_U
	; If the player is above the actor, we got the direction right
	ld   a, [sActSetRelY]	; B = ActY
	add  $20				; Fix for underflow
	ld   b, a
	ld   a, [sPlYRel]		; A = PlY
	add  $20
	cp   a, b				; PlY - ActY < 0? (PlY < ActY)
	jr   c, .setDir			; If so, jump
	ld   d, DIR_D

.setDir:
	; Set the vertical direction
	ld   a, d				
	ld   a, [sActSetDir]
	and  a, $F0|DIR_R|DIR_L ; Preserve horz dir
	or   a, d				; Dir |= D 
	ld   [sActSetDir], a
.move:
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, .moveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, .moveLeft
	ld   a, [sActSetDir]
	bit  DIRB_U, a
	call nz, .moveUp
	ld   a, [sActSetDir]
	bit  DIRB_D, a
	call nz, .moveDown
	ret
	
; =============== .moveRight ===============
; Moves the actor right at 1px/frame.
.moveRight:
	ld   bc, +$01
	call ActS_MoveRight
	
	ld   a, LOW(OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_MoveR)
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_MoveR)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== .moveLeft ===============
; Moves the actor left at 1px/frame.
.moveLeft:
	ld   bc, -$01
	call ActS_MoveRight
	
	ld   a, LOW(OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_MoveL)
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_MoveL)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== .moveUp ===============
; Moves the actor up at 0.5px/frame.
.moveUp:
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveDown
	ret
	
; =============== .moveDown ===============
; Moves the actor down at 0.5px/frame.
.moveDown:
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveDown
	ret
	
; =============== Act_ParsleyWoodsBossGhostGoom_OnStun ===============
Act_ParsleyWoodsBossGhostGoom_OnStun:
	ld   a, BGHOST_RTN_STUN
	ld   [sActLocalRoutineId], a
	mActSetYSpeed -$04			; Set jump effect
	; Make fully vulnerable
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI				
	ld   [sActSetColiType], a
	ret
	
; =============== Act_ParsleyWoodsBossGhostGoom_Stun ===============
; Stun jump effect.
Act_ParsleyWoodsBossGhostGoom_Stun:
	; The stun effect for this actor is special, being more similar to the "jump death" effect.
	; It always moves down (with a 4px/frame speed cap), and if left alone, it will actually fall off-screen.
	
	; You're meant to catch the actor before that happens.
	; Curiously, it's only then that the stun animation is set.

	; If the actor is moving up (YSpeed < 0), don't interfere with the jump effect
	ld   a, [sActSetYSpeed_High]
	bit  7, a							; Is the actor moving up?
	jr   nz, .fall						; If so, ignore hold attempts
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw .fall
	dw Act_ParsleyWoodsBossGhostGoom_SwitchToHeld
	dw Act_ParsleyWoodsBossGhostGoom_SwitchToHeld
	dw .fall
	dw Act_ParsleyWoodsBossGhostGoom_SwitchToHeld
	dw Act_ParsleyWoodsBossGhostGoom_SwitchToHeld;X
	dw .fall;X
	dw .fall;X
	dw SubCall_ActS_StartJumpDead;X
.fall:
	call ActS_FallDownMax4Speed
	ret
	
; =============== Act_ParsleyWoodsBossGhostGoom_SwitchToHeld ===============
Act_ParsleyWoodsBossGhostGoom_SwitchToHeld:
	; Set stun animation depending on direction.
	push bc					; left?
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_StunL
	call ActS_SetOBJLstPtr
	pop  bc
	
	; If the player is to the left of the actor, we got the direction right
	ld   a, [sActSetRelX]	; B = ActX
	add  $20				; Fix for underflow
	ld   b, a
	ld   a, [sPlXRel]		; A = PlX
	add  $20
	cp   a, b				; PlX - ActX < 0? (PlX < ActX)
	jr   c, .end			; If so, return
	
	; Otherwise, set the other one
	push bc
	ld   bc, OBJLstPtrTable_Act_ParsleyWoodsBossGhostGoom_StunR
	call ActS_SetOBJLstPtr
	pop  bc
.end:
	jp   SubCall_ActS_StartHeld
	
; =============== ActInit_StoveCanyonBoss ===============
; See also: ActInit_SSTeacupBoss
ActInit_StoveCanyonBoss:
	; Setup collision box for the bumpable area
	ld   a, -$30
	ld   [sActSetColiBoxU], a
	ld   a, -$10
	ld   [sActSetColiBoxD], a
	ld   a, -$10
	ld   [sActSetColiBoxL], a
	ld   a, +$10
	ld   [sActSetColiBoxR], a
	
	; Setup main code
IF FIX_BUGS
	ld   bc, SubCall_ActInit2_StoveCanyonBoss
	call ActS_SetCodePtr
ELSE
	ld   bc, SubCall_Act_StoveCanyonBoss
	call ActS_SetCodePtr
ENDC

	; Does not have a visible sprite (at first)
	mActS_SetBlankFrame
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_StoveCanyonBoss
	call ActS_SetOBJLstSharedTablePtr
	
	
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActStoveCanyonBossBallDelay], a
	ld   [sActSetTimer], a
	ld   [sActStoveCanyonBossModeTimer], a
	ld   [sActSetYSpeed_Low], a
	
	;
	; Prepare for the intro
	;
	
	xor  a
	ld   [sActSetColiType], a
	
	; Align boss to where the tilemap will be written
	ld   bc, $0008			
	call ActS_MoveRight
	ld   bc, $002E			
	call ActS_MoveDown
	
	; Initialize the special scroll mode for this boss
	
	;--
	; Divide the screen in two sections for the parallax effect:
	; - Boss body
	; - Ground
	; However, the scroll mode for bosses has a fixed number of sections (4).
	; As a result, the boss body section gets duplicated twice (X0, X1, X2).
	
	; Starting coords for boss body (X: $70, Y: $30)
	; As the boss moves around, these will be updated (all at once, of course).
	di
	ld   a, $70
	ld   [sActBossParallaxX], a
	ld   [sParallaxX0], a
	ld   [sParallaxX1], a
	ld   [sParallaxX2], a
	ld   a, $30
	ld   [sActBossParallaxY], a
	ld   [sParallaxY0], a
	ld   [sParallaxY1], a
	ld   [sParallaxY2], a
	
	; For the ground, copy over the current scroll coords.
	; These won't ever be changed.
	ld   a, [sScrollX]
	ld   [sParallaxX3], a
	ldh  a, [hScrollY]
	ld   [sParallaxY3], a
	
	; The use of parallax sections is a bit questionable, screen tearing and all,
	; but at least here it's done like this to hide sections with garbage blocks.
	ld   a, $00
	ld   [sParallaxNextLY0], a
	ld   a, $20
	ld   [sParallaxNextLY1], a
	ld   a, $48
	ld   [sParallaxNextLY2], a
	ld   a, $68
	ld   [sParallaxNextLY3], a
	; Set scroll mode
	ld   a, PRX_BOSS0
	ld   [sParallaxMode], a
	
	;--
	; Enable LYC interrupt to enable the above parallax rules
	xor  a						; Clear all interrupts
	ldh  [rIF], a
	ldh  a, [rSTAT]				; Enable LYC in STAT
	set  STATB_LYC, a
	ldh  [rSTAT], a
	ldh  a, [rIE]				; Enable STAT
	set  IB_STAT, a
	ldh  [rIE], a				; Restore previous interrupts (+ STAT)
	;--
	ei
	
	ld   a, DIR_L
	ld   [sActSetDir], a
	
	ld   c, $40					; Move 4 blocks down, since the intro has it move up from off-screen
	call Act_StoveCanyonBoss_MoveDown
	call Act_StoveCanyonBoss_CopyPosToSync
IF !FIX_BUGS
	; [BUG] Like with the SSTeacup boss, this should have been done in a separate frame.
	call Act_StoveCanyonBoss_BGWrite_Body
ENDC

	xor  a
	ld   [sActBossParallaxFlashTimer], a
	ld   a, $B4
	ld   [sPlFreezeTimer], a
	ret
	
IF FIX_BUGS
; =============== ActInit2_StoveCanyonBoss ===============
ActInit2_StoveCanyonBoss:
	call Act_StoveCanyonBoss_BGWrite_Body
	ld   bc, SubCall_Act_StoveCanyonBoss
	call ActS_SetCodePtr
	ret
ENDC
; =============== Act_StoveCanyonBoss_CopyPosToSync ===============
; This subroutine copies the actor's own position to the area used
; for synching with the other actors.
;
; This is done because the boss is made of multiple actors, 
; and all of those need to move in sync, so it should be called every frame.
Act_StoveCanyonBoss_CopyPosToSync:
	ld   a, [sActSetX_Low]
	ld   [sActStoveCanyonBossXSync_Low], a
	ld   a, [sActSetX_High]
	ld   [sActStoveCanyonBossXSync_High], a
	ld   a, [sActSetY_Low]
	ld   [sActStoveCanyonBossYSync_Low], a
	ld   a, [sActSetY_High]
	ld   [sActStoveCanyonBossYSync_High], a
	ret
	
; =============== Act_StoveCanyonBoss_CopyPosFromSync ===============
; This subroutine updates the actor's position to be in sync with the global copy.
Act_StoveCanyonBoss_CopyPosFromSync:
	ld   a, [sActStoveCanyonBossXSync_Low]
	ld   [sActSetX_Low], a
	ld   a, [sActStoveCanyonBossXSync_High]
	ld   [sActSetX_High], a
	ld   a, [sActStoveCanyonBossYSync_Low]
	ld   [sActSetY_Low], a
	ld   a, [sActStoveCanyonBossYSync_High]
	ld   [sActSetY_High], a
	ret
	
; =============== Act_StoveCanyonBoss ===============
Act_StoveCanyonBoss:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; If the boss is dead, ignore the normal routine jump.
	; [BUG] This seems to have been added later on, and also
	;       the way it's done prevents the hit flash from applying in the death mode.
	;       SCBOSS_RTN_DEAD should have been excluded, or at least jumped to Act_StoveCanyonBoss_DoHitFlash instead.
	ld   a, [sActLocalRoutineId]
	cp   a, SCBOSS_RTN_DEAD
IF FIX_BUGS
	jr   z, .onDead
ELSE
	jp   z, Act_StoveCanyonBoss_Dead
ENDC
	cp   a, SCBOSS_RTN_COINGAME
	jp   z, Act_StoveCanyonBoss_CoinGame
	
	;--
	; Flash the boss when hit.
	ld   a, [sActBossParallaxFlashTimer]
	or   a
	jr   nz, Act_StoveCanyonBoss_DoHitFlash
	;--
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_StoveCanyonBoss_Main
	dw Act_StoveCanyonBoss_Main;X
	dw Act_StoveCanyonBoss_SwitchToHit;X
	dw Act_StoveCanyonBoss_Main
	dw Act_StoveCanyonBoss_Main;X
	dw Act_StoveCanyonBoss_Main;X
	dw Act_StoveCanyonBoss_Main;X
	dw Act_StoveCanyonBoss_Main
	dw Act_StoveCanyonBoss_CheckThrown
IF FIX_BUGS
.onDead:
	call Act_StoveCanyonBoss_DoHitFlash
	jp   Act_StoveCanyonBoss_Dead
ENDC
	
; =============== Act_StoveCanyonBoss_DoHitFlash ===============
; This subroutine performs the boss flash after an hit.
Act_StoveCanyonBoss_DoHitFlash:
	ld   a, [sActBossParallaxFlashTimer]
	dec  a						; Count--
	ld   [sActBossParallaxFlashTimer], a
	cp   a, $02					; Is it < $02?
	jr   c, .copyNorm			; If so, copy the parallax value directly
	
	; Flash the boss by replacing the parallax sections with blank areas,
	; alternating every 2 frames (to account for updating parallax modes mid-frame).
	ld   a, [sActSetTimer]
	bit  1, a
	jr   z, .copyNorm
.copyBlank:
	ld   a, $00
	ld   [sParallaxX0], a
	ld   [sParallaxX1], a
	ld   [sParallaxX2], a
	jr   .end
.copyNorm:
	ld   a, [sActBossParallaxX]
	ld   [sParallaxX0], a
	ld   [sParallaxX1], a
	ld   [sParallaxX2], a
.end:
	; [TCRF] It's impossible to get here with the routine SCBOSS_RTN_DEAD.
	;        This check being here hints that the boss was meant to flash upon defeat.
	ld   a, [sActLocalRoutineId]
	cp   a, SCBOSS_RTN_DEAD				; Are we dead?
	jp   z, Act_StoveCanyonBoss_Main	; If so, fall down as usual while flashing
	ret									; Otherwise return (don't move or do anything)
	
; =============== Act_StoveCanyonBoss_CheckThrown ===============
; This subroutine is called when something is thrown at the boss.
Act_StoveCanyonBoss_CheckThrown:
	; Verify that we aren't throwing a 10-coin at the boss.
	; We can do this by simply checking if it's a default actor.
	
	; DE -> slot offset
	mActCheckThrownId ACT_DEFAULT_BASE	; Was it thrown a default actor? ( >= $07)
	jp   nc, Act_StoveCanyonBoss_Main	; If so, jump
	
; =============== Act_StoveCanyonBoss_SwitchToHit ===============
; This subroutine is called when the boss is damaged.
Act_StoveCanyonBoss_SwitchToHit:
	ld   a, $96							; Flash for $96 frames
	ld   [sActBossParallaxFlashTimer], a
	ld   a, [sParallaxX0]				
	ld   [sActBossParallaxX], a
	ld   a, SFX1_2C
	ld   [sSFX1Set], a
	
	ld   a, [sActStoveCanyonBossHitCount]		; HitCount++
	inc  a
	ld   [sActStoveCanyonBossHitCount], a
	cp   a, $03									; Did we hit the boss 3 times?
	jp   nc, Act_StoveCanyonBoss_SwitchToDead	; If so, we defeated it
	ret
	
; =============== Act_StoveCanyonBoss_Main ===============
Act_StoveCanyonBoss_Main:
	call Act_StoveCanyonBoss_CopyPosToSync
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_StoveCanyonBoss_Intro
	dw Act_StoveCanyonBoss_MainMove
	dw Act_StoveCanyonBoss_Tongue
	dw Act_StoveCanyonBoss_Dead;X
	dw Act_StoveCanyonBoss_CoinGame;X
	
; =============== Act_StoveCanyonBoss_Intro ===============
; Intro. Boss moves up until reaching the target.
Act_StoveCanyonBoss_Intro:
	ld   a, [sActSetRelY]
	cp   a, $4C										; Y < $4C?
	jr   c, Act_StoveCanyonBoss_SwitchToMainMove	; If so, we reached the target
	
	; Otherwise, continue moving up 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   c, -$01
	call Act_StoveCanyonBoss_MoveDown
	ret
	
; =============== Act_StoveCanyonBoss_SwitchToMainMove ===============
; Prepares for the main movement mode.
Act_StoveCanyonBoss_SwitchToMainMove:
	ld   a, SCBOSS_RTN_MAIN
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActStoveCanyonBossModeTimer], a
	ld   [sActStoveCanyonBossTongueRoutineId], a
	
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_NoseIdle
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Make all sides bump the player
	mActColiMask ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_BUMP
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_StoveCanyonBoss_MainMove ===============
; Main movement mode.
Act_StoveCanyonBoss_MainMove:
	xor  a									
	ld   [sActStoveCanyonBossTongueRoutineId], a
	
	;
	; Brief overview of how this mode works.
	;
	; Every other frame, the boss moves both vertically and horizontally.
	;
	; Every frame, the game rolls the dice. 
	; There's a random 1/128 chance which makes the boss throw a snot ball.
	;
	; A separate timer also ticks up every time the boss moves vertically.
	; Once that reaches value $2C, the boss breaks a block below.
	;
	
	; If the boss is in snot ball mode, don't move
	ld   a, [sActStoveCanyonBossBallDelay]
	or   a									
	jp   nz, Act_StoveCanyonBoss_WaitBall						
	
	;--
	; Move vertically at 0.5px/frame.
.chkMoveV:
	ld   a, [sActSetTimer]
	and  a, $01
	jr   nz, .chkMoveH
	
	; Every time the boss moves vertically, increment the timer.
	; When that timer reaches $2C (the end of the table), switch to the next mode.
	ld   a, [sActStoveCanyonBossModeTimer]
	inc  a						; Timer++
	cp   a, (Act_StoveCanyonBoss_YPath.end-Act_StoveCanyonBoss_YPath)	; Has it reached the target value?
	jr   c, .moveV				; If not, move vertically
	xor  a						; Otherwise, switch to the tongue mode
	ld   [sActStoveCanyonBossModeTimer], a
	jp   .endMode
.moveV:
	; Move vertically based on a Y offset table, indexed by sActStoveCanyonBossModeTimer
	ld   [sActStoveCanyonBossModeTimer], a
	ld   d, $00			; DE = Index
	ld   e, a
	ld   hl, Act_StoveCanyonBoss_YPath	; HL = YOffset Table
	add  hl, de			; Offset it
	
	ld   a, [hl]		; Read out the value
	ld   c, a
	call Act_StoveCanyonBoss_MoveDown	; And move down by that
	
.chkMoveH:
	;--
	push bc					; Set main move anim
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_NoseIdle
	call ActS_SetOBJLstPtr
	pop  bc
	
	;--
	; Roll the dice for triggering a snot ball
	call Rand
	ld   a, [sRandom]
	and  a, $7F			; 1/128 chance
	call z, Act_StoveCanyonBoss_SetBall		; If triggered, set the ball delay
	;--

	; Move horizontally 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, .moveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, .moveLeft
	ret
	
; =============== .moveRight ===============
; Moves the boss right.
.moveRight:
	ld   a, [sActSetRelX]
	cp   a, $AC				; Reached the right border of the screen?
	jr   nc, .turn			; If so, turn left
	ld   c, +$01
	call Act_StoveCanyonBoss_MoveRight
	ret
	
; =============== .moveLeft ===============
; Moves the boss left.
.moveLeft:
	ld   a, [sActSetRelX]
	cp   a, $0E				; Reached the left border of the screen?
	jr   c, .turn			; If so, turn right
	ld   c, -$01
	call Act_StoveCanyonBoss_MoveRight
	ret
	
; =============== .turn ===============
.turn:
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ret
	
; =============== .endMode ===============
; Switches to the tongue mode.
.endMode:
	ld   a, SCBOSS_RTN_TONGUE
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActStoveCanyonBossUpMove], a
	
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_NoseIdle
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, $01					; Trigger the tongue to activate
	ld   [sActStoveCanyonBossTongueRoutineId], a
	ld   a, SFX4_04	; Play fire SFX
	ld   [sSFX4Set], a
	ret
	
; =============== Act_StoveCanyonBoss_Tongue ===============
; Moves vertically (first down, then up) while the tongue (another actor) is out.
Act_StoveCanyonBoss_Tongue:
	; Move every other frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	
	ld   a, [sActStoveCanyonBossUpMove]
	or   a					; Are we moving up?
	jr   nz, .moveUp		; If so, jump
.moveDown:
	; Move down until reaching Y $6C
	ld   c, $01
	call Act_StoveCanyonBoss_MoveDown
	
	ld   a, [sActSetRelY]
	cp   a, $6C				; Did we reach the initial target?
	ret  c					; If so, move up instead
	ld   a, $01				; Mark upwards movement as next
	ld   [sActStoveCanyonBossUpMove], a
	ret
.moveUp:
	; Move up until reaching Y $4C
	ld   a, [sActSetRelY]
	cp   a, $4C				; Did we reach the final target?
	jp   c, Act_StoveCanyonBoss_SwitchToMainMove	; If so, return to the main mode
	ld   c, -$01
	call Act_StoveCanyonBoss_MoveDown
	ret
	
; =============== Act_StoveCanyonBoss_SetBall ===============
; Sets up the alert for a snot ball about to be thrown.
Act_StoveCanyonBoss_SetBall:

	; Here, we set up a timer which counts down every frame.
	; When the timer is active, instead of performing normal movement,
	; execution reaches Act_StoveCanyonBoss_WaitBall.

	ld   a, $64												; Wait for $64 frames before shooting
	ld   [sActStoveCanyonBossBallDelay], a
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_NoseShoot	; Nose anim
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_StoveCanyonBoss_WaitBall ===============
; Handles the "snot ball" mode.
Act_StoveCanyonBoss_WaitBall:

	; This subroutine ends up waiting $28 frames before spawning a snot ball,
	; then wait for $3C other frames for the timer to expire, before starting to move again.

	ld   a, [sActStoveCanyonBossBallDelay]	; Timer--
	dec  a
	ld   [sActStoveCanyonBossBallDelay], a
	
	call ActS_IncOBJLstIdEvery8
	
	; Every time the anim frame reaches $01, check if the ball should be thrown.
	ld   a, [sActSetOBJLstId]
	cp   a, $01
	ret  nz
	ld   a, [sActStoveCanyonBossBallDelay]
	cp   a, $3C								; Is the timer $3C?
	call z, Act_StoveCanyonBoss_SpawnBall	; If so, spawn the ball
	
	; Every 8 frames, play the nose SFX
	ld   a, [sActSetTimer]
	and  a, $07
	ret  nz
	ld   a, SFX1_11
	ld   [sSFX1Set], a
	ret
	
; =============== Act_StoveCanyonBoss_SpawnBall ===============
; Spawns a snot ball thrown diagonally down.
Act_StoveCanyonBoss_SpawnBall:
	; Find an empty slot
	; Also use upper slots because of the multiple actor slots the boss uses
	ld   hl, sAct			; HL = Actor slot area
	ld   d, ACTSLOT_COUNT	; D = Total slots
	ld   e, $00				; E = Current slot
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
	mActS_SetOBJBank Act_StoveCanyonBoss_SpawnBall
	
	ld   a, $02				; Enabled
	ldi  [hl], a
	
	
	;--
	; Calc direction.
	; If the player is to the left of the actor, make the actor move left
	ld   a, [sActSetRelX]	; B = ActX
	add  $20				; Fix for underflow
	ld   b, a
	ld   a, [sPlXRel]		; A = PlX
	add  $20
	cp   a, b				; PlX - ActX < 0? (PlX < ActX)
	jr   c, .dirL			; If so, jump
.dirR:
	ld   a, DIR_R			; Otherwise, use right
	jr   .saveDir
.dirL:
	ld   a, DIR_L
.saveDir:
	ld   [sActStoveCanyonBossBallDir], a
	;--
	
	;--
	; Depending on the direction we just determined, set a different X offset,
	; to align to the correct nosestril.
	ld   bc, +$0C
	bit  DIRB_R, a			; Facing right?
	jr   nz, .setX			; If so, we got it right
	ld   bc, -$0C			; Otherwise, set the left offset
.setX:
	ld   a, [sActSetX_Low]	; X = sActSetX + BC
	add  c
	ldi  [hl], a
	ld   a, [sActSetX_High]
	adc  a, b
	ldi  [hl], a
	;--
	
	ld   a, [sActSetY_Low]	; Y = sActSetY - $08
	sub  a, $08
	ldi  [hl], a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ldi  [hl], a
	
	; Deal damage (until it lands)
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ldi  [hl], a
	
	ld   a, -$0C		; Coli box U
	ldi  [hl], a
	ld   a, -$04		; Coli box D
	ldi  [hl], a
	ld   a, -$04		; Coli box L
	ldi  [hl], a
	ld   a, +$04		; Coli box R
	ldi  [hl], a
	
	ld   a, $00
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_None)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_None)
	ldi  [hl], a
	
	ld   a, [sActStoveCanyonBossBallDir]	; Direction
	ldi  [hl], a
	xor  a						; OBJLst ID
	ldi  [hl], a
	
	; Assumption about actor ID order
	ld   a, $04					; Actor ID
	ldi  [hl], a
	
	xor  a						; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_StoveCanyonBossBall)		; Code ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_StoveCanyonBossBall)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	ldi  [hl], a				; Timer 3
	ldi  [hl], a				; Timer 4
	ldi  [hl], a				; Timer 5
	ldi  [hl], a				; Timer 6
	ldi  [hl], a				; Timer 7
	
	ld   a, ACTFLAG_NORECOVER	; Flags -- prevent reinit in fireball mode
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_StoveCanyonBoss_Ball)		; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_StoveCanyonBoss_Ball)
	ldi  [hl], a
	
	ld   a, SFX4_13				; Throw ball SFX
	ld   [sSFX4Set], a
	ret
	
; =============== Act_StoveCanyonBoss_SwitchToDead ===============
; Switches to the boss defeated mode.
Act_StoveCanyonBoss_SwitchToDead:
	ld   a, SCBOSS_RTN_DEAD					; Mark set dead
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActStoveCanyonBossModeTimer], a
	ld   a, SFX1_09
	ld   [sSFX1Set], a
	ld   a, BGM_NONE
	ld   [sBGMSet], a
IF !OPTIMIZE
	call ActS_DespawnAllNormExceptCur_Broken
ENDC
	ret
	
; =============== Act_StoveCanyonBoss_Dead ===============
; Makes the boss move down.
Act_StoveCanyonBoss_Dead:
	
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_NoseIdle
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, $C8						; [TCRF] Make boss flash during the whole time (in theory)
	ld   [sActBossParallaxFlashTimer], a
	
	; When the boss goes off-screen, switch to the coin game.
	ld   a, [sActSetRelY]			
	cp   a, $B4				; Y >= $B4?
	jr   nc, .endMode		; If so, we're done
	
	
	; Move down by sActStoveCanyonBossModeTimer
	ld   a, [sActStoveCanyonBossModeTimer]
	ld   c, a
	call Act_StoveCanyonBoss_MoveDown
	
	; Increase fall speed every $10 frames
	ld   a, [sActSetTimer]
	and  a, $0F
	ret  nz
	ld   a, [sActStoveCanyonBossModeTimer]
	inc  a
	ld   [sActStoveCanyonBossModeTimer], a
	ret
.endMode:
	ld   a, SCBOSS_RTN_COINGAME
	ld   [sActLocalRoutineId], a
	ld   a, BGM_COINGAME
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	ret
	
; =============== Act_StoveCanyonBoss_CoinGame ===============
; Stub to the coin game.
Act_StoveCanyonBoss_CoinGame:
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_NoseIdle
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, $C8								; what?
	ld   [sActBossParallaxFlashTimer], a
	
	call SubCall_ActS_CoinGame
	ret
	
; =============== Act_StoveCanyonBoss_MoveDown ===============
; This subroutine moves the boss downwards, 
; applied to both the parallax effect and the invisible actor.
;
; Because we control the parallax screen, and not the boss directly 
; (since it's part of the BG and all), the movement is "inverted".
; As in, moving the screen left causes the boss to appear to move right.
;
; The hidden actor used for collision detection also moves to keep itself aligned.
; This one can move in the proper direction.
;
; IN:
; - C: Pixels to move down
Act_StoveCanyonBoss_MoveDown:
	; Move the *parallax section* up. This causes the boss to move down.
	ld   a, [sActBossParallaxY]
	sub  a, c
	ld   [sActBossParallaxY], a
	; And update the parallax sections
	ld   [sParallaxY0], a
	ld   [sParallaxY1], a
	ld   [sParallaxY2], a
	
	; Sign-extend since ActS_MoveDown goes off a 16bit value
	ld   a, c
	sext a
	ld   b, a
	call ActS_MoveDown
	
	;--
	; Hide sections displaying garbage blocks.
	;
	; Since this is a BG-based boss, scrolling too much a parallax section will show
	; blocks in the tilemap that aren't meant to be seen.
	;
	; To fix this, the boss is split in 3 parallax sections.
	; Depending on the boss' vertical position, any section which would display garbage
	; blocks is made to point to a safe "blank" area instead.
	; 
	; If the boss was positioned so no solid ground was below it, this wouldn't have been necessary.
	
	call ActS_CheckOffScreen	; Update offscreen status
	
	; Section 0: Hide when Y > $68
	; Hides garbage from above when the boss moves near the bottom.
	ld   a, [sActSetRelY]
	cp   a, $68					; Y >= $68?
	call nc, .clearY0			; If so, call
	
	; Section 1: Hide when Y >= $90 && Y < $C0
	; Meant to hide garbage from above when the boss rises from the ground (or during the death anim)
	; ...but there's nothing to hide.
	ld   a, [sActSetRelY]
	cp   a, $90					; Y >= $90?
	call nc, .clearY1			; If so, call
	
	; Section 2: Hide when Y < $50
	; Hides garbage from below when the boss moves near the top.
	ld   a, [sActSetRelY]
	cp   a, $50					; Y < $50?
	call c, .clearY2			; If so, call
	ret
	
	; [POI] All of these could have "xor a"'d the parallax section.
	;       For some reason, only .clearY2 does it.
.clearY0:
	ld   a, $48					
	ld   [sParallaxY0], a
	ret
.clearY1:
	; The section contains valid blocks when the boss moves partially off-screen above.
	; Don't accidentaly delete it.
	ld   a, [sActSetRelY]
	cp   a, $C0				; Y > -$40?
	ret  nc					; If so, return
	ld   a, $20					
	ld   [sParallaxY1], a
	ret
.clearY2:
	xor  a
	ld   [sParallaxY2], a
	ret
	
; =============== Act_StoveCanyonBoss_MoveRight ===============
; This subroutine moves the boss to the right, 
; applied to both the parallax effect and the invisible actor.
; IN:
; - C: Pixels to move right
Act_StoveCanyonBoss_MoveRight:
	; Move the *parallax section* left, which causes the boss to move right.
	ld   a, [sParallaxX0]
	sub  a, c
	; And update the parallax sections
	ld   [sParallaxX0], a
	ld   [sParallaxX1], a
	ld   [sParallaxX2], a
	
	; Sign-extend since ActS_MoveRight goes off a 16bit value
	ld   a, c
	sext  a
	ld   b, a
	call ActS_MoveRight
	ret
	
; =============== Act_StoveCanyonBoss_YPath ===============
; This Y offset table defines the boss' Y movement path.
; Every time the boss needs to move vertically, this table is indexed,
; and the indexed value is added to the boss' current Y pos (alongside scrolling the parallax).
;
; The table length directly determines the amount of time it takes
; before the boss switches to the tongue mode, since it does so
; when the index points at the end of the table.
;
; [TCRF] The index is pre-incremented, so the first entry doesn't get used.
Act_StoveCanyonBoss_YPath: 
	db -$03,-$02,-$02,-$02,-$02,-$01,-$01,-$01,-$01,+$00,+$00,+$00,+$00,+$01,+$01,+$01
	db +$01,+$02,+$02,+$02,+$02,+$03,+$03,+$02,+$02,+$02,+$02,+$01,+$01,+$01,+$01,+$00
	db +$00,+$00,+$00,-$01,-$01,-$01,-$01,-$02,-$02,-$02,-$02,-$03
.end:

OBJLstSharedPtrTable_Act_StoveCanyonBoss:
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Unused_00;X
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Unused_00;X
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Unused_00;X
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Unused_00;X
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Unused_00;X
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Unused_00;X
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Unused_00;X
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Unused_00;X

; The idle animation is... nothing!
OBJLstPtrTable_Act_StoveCanyonBoss_NoseIdle:
	dw OBJLst_Act_None
	dw $0000;X
OBJLstPtrTable_Act_StoveCanyonBoss_NoseShoot:
	dw OBJLst_Act_StoveCanyonBoss_Nose_Shoot0
	dw OBJLst_Act_StoveCanyonBoss_Nose_Shoot1
	dw OBJLst_Act_StoveCanyonBoss_Nose_Shoot0
	dw OBJLst_Act_None
	dw $0000
;--	
; [TCRF] Set of unused sprite animations all pointing to unused graphics.


OBJLstPtrTable_Act_StoveCanyonBoss_Unused_00:
	dw OBJLst_Act_StoveCanyonBoss_Tongue_Unused_Lick0;X
	dw $0000;X
; Sprite version of the block.
OBJLstPtrTable_Act_StoveCanyonBoss_Unused_Block:
	dw OBJLst_Act_StoveCanyonBoss_Unused_Block0;X
	dw OBJLst_Act_StoveCanyonBoss_Unused_Block1;X
	dw $0000;X

; Small Wario facing the screen.
; The mappings place Wario exactly where the boss' mouth is.
OBJLstPtrTable_Act_StoveCanyonBoss_Unused_Wario:
	dw OBJLst_Act_StoveCanyonBoss_Unused_Wario0;X
	dw OBJLst_Act_StoveCanyonBoss_Unused_Wario1;X
	dw $0000;X
;--

OBJLst_Act_StoveCanyonBoss_EyesD: INCBIN "data/objlst/actor/stovecanyonboss_eyesd.bin"
OBJLst_Act_StoveCanyonBoss_EyesR: INCBIN "data/objlst/actor/stovecanyonboss_eyesr.bin"
OBJLst_Act_StoveCanyonBoss_EyesL: INCBIN "data/objlst/actor/stovecanyonboss_eyesl.bin"
OBJLst_Act_StoveCanyonBoss_EyesU: INCBIN "data/objlst/actor/stovecanyonboss_eyesu.bin"
OBJLst_Act_StoveCanyonBoss_Nose_Shoot0: INCBIN "data/objlst/actor/stovecanyonboss_nose_shoot0.bin"
OBJLst_Act_StoveCanyonBoss_Nose_Shoot1: INCBIN "data/objlst/actor/stovecanyonboss_nose_shoot1.bin"
OBJLst_Act_StoveCanyonBoss_Ball_Idle: INCBIN "data/objlst/actor/stovecanyonboss_ball_idle.bin"
OBJLst_Act_StoveCanyonBoss_Ball_FireL: INCBIN "data/objlst/actor/stovecanyonboss_ball_firel.bin"
OBJLst_Act_StoveCanyonBoss_Tongue0: INCBIN "data/objlst/actor/stovecanyonboss_tongue0.bin"
OBJLst_Act_StoveCanyonBoss_Tongue1: INCBIN "data/objlst/actor/stovecanyonboss_tongue1.bin"
OBJLst_Act_StoveCanyonBoss_Tongue2: INCBIN "data/objlst/actor/stovecanyonboss_tongue2.bin"
OBJLst_Act_StoveCanyonBoss_Tongue3: INCBIN "data/objlst/actor/stovecanyonboss_tongue3.bin"
OBJLst_Act_StoveCanyonBoss_Tongue4: INCBIN "data/objlst/actor/stovecanyonboss_tongue4.bin"
OBJLst_Act_StoveCanyonBoss_Tongue_Unused_Lick0: INCBIN "data/objlst/actor/stovecanyonboss_tongue_unused_lick0.bin"
OBJLst_Act_StoveCanyonBoss_Tongue_Unused_Lick1: INCBIN "data/objlst/actor/stovecanyonboss_tongue_unused_lick1.bin"
OBJLst_Act_StoveCanyonBoss_Ball_Splash0: INCBIN "data/objlst/actor/stovecanyonboss_ball_splash0.bin"
OBJLst_Act_StoveCanyonBoss_Ball_Splash1: INCBIN "data/objlst/actor/stovecanyonboss_ball_splash1.bin"
OBJLst_Act_StoveCanyonBoss_Ball_Splash2: INCBIN "data/objlst/actor/stovecanyonboss_ball_splash2.bin"
OBJLst_Act_StoveCanyonBoss_Ball_Splash3: INCBIN "data/objlst/actor/stovecanyonboss_ball_splash3.bin"
OBJLst_Act_StoveCanyonBoss_Ball_Splash4: INCBIN "data/objlst/actor/stovecanyonboss_ball_splash4.bin"
OBJLst_Act_StoveCanyonBoss_Ball_Splash5: INCBIN "data/objlst/actor/stovecanyonboss_ball_splash5.bin"
OBJLst_Act_StoveCanyonBoss_Unused_Block0: INCBIN "data/objlst/actor/stovecanyonboss_unused_block0.bin"
OBJLst_Act_StoveCanyonBoss_Unused_Block1: INCBIN "data/objlst/actor/stovecanyonboss_unused_block1.bin"
OBJLst_Act_StoveCanyonBoss_Unused_Wario0: INCBIN "data/objlst/actor/stovecanyonboss_unused_wario0.bin"
OBJLst_Act_StoveCanyonBoss_Unused_Wario1: INCBIN "data/objlst/actor/stovecanyonboss_unused_wario1.bin"
OBJLst_Act_StoveCanyonBoss_Ball_FireR: INCBIN "data/objlst/actor/stovecanyonboss_ball_firer.bin"
GFX_Act_StoveCanyonBoss: INCBIN "data/gfx/actor/stovecanyonboss.bin"
; [TCRF] Extra tile which doesn't get loaded to VRAM.
GFX_Act_StoveCanyonBoss_Unused_Extra: INCBIN "data/gfx/actor/stovecanyonboss_unused_extra.bin"

; =============== mStoveCanyonBoss_BGWriteCall ===============
; Helper macro for writing a number of tiles to location in the tilemap.
; IN
; - 1: Base address
; - 2: Rows to draw.
MACRO mStoveCanyonBoss_BGWriteCall
DEF I = 0
REPT \2
	ld   hl, \1 + (BG_TILECOUNT_H * I)
	call Act_StoveCanyonBoss_BGWrite4
	call Act_StoveCanyonBoss_BGWrite4
DEF I = I + 1
ENDR
ENDM

; =============== Act_StoveCanyonBoss_BGWrite_* ===============
; This set of subroutines copies tilemaps for the boss body.
Act_StoveCanyonBoss_BGWrite_Body:
	ld   bc, BG_Act_StoveCanyonBoss_Body	; BC = Ptr to tilemap
	;                            VRAM                    ROWS
	mStoveCanyonBoss_BGWriteCall vBGStoveCanyonBossBody, 8
	ret
	
Act_StoveCanyonBoss_BGWrite_MouthClosed:;C
	ld   bc, BG_Act_StoveCanyonBoss_MouthClosed
	;                            VRAM                     ROWS
	mStoveCanyonBoss_BGWriteCall vBGStoveCanyonBossMouth, 3
	ret
Act_StoveCanyonBoss_BGWrite_MouthOpen:;C
	ld   bc, BG_Act_StoveCanyonBoss_MouthOpen
	;                            VRAM                     ROWS
	mStoveCanyonBoss_BGWriteCall vBGStoveCanyonBossMouth, 3
	ret
	
BG_Act_StoveCanyonBoss_Body: INCBIN "data/bg/level/stovecanyonboss_body.bin"
BG_Act_StoveCanyonBoss_MouthClosed: INCBIN "data/bg/level/stovecanyonboss_mouthclosed.bin"
BG_Act_StoveCanyonBoss_MouthOpen: INCBIN "data/bg/level/stovecanyonboss_mouthopen.bin"

; =============== mStoveCanyonBoss_BGWrite ===============
; This macro copies a single tile from the specified tilemap directly to VRAM.
;
; Since this is meant to be called outside VBlank, with the display still enabled,
; this copy has to be done during HBlank.
; This makes it take a significant amount of cycles.
; IN
; - BC: Ptr to tilemap
; - HL: Destination in VRAM
MACRO mStoveCanyonBoss_BGWrite
	mWaitForNewHBlank
	ld   a, [bc]		; A = Tile ID
	inc  bc				; TilemapPtr++
	ldi  [hl], a		; Write it to VRAM
ENDM


; =============== Act_StoveCanyonBoss_BGWrite<N> ===============
; Set of helper subroutines for copying N tiles from the specified tilemap directly to VRAM.
; IN
; - BC: Ptr to tilemap
; - HL: Destination in VRAM
Act_StoveCanyonBoss_BGWrite4:
REPT 4
	mStoveCanyonBoss_BGWrite
ENDR
	ret
	
; =============== ActInit_StoveCanyonBossEyes ===============
; Eyes more or less tracking the player.
ActInit_StoveCanyonBossEyes:
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, -$08
	ld   [sActSetColiBoxD], a
	ld   a, -$04
	ld   [sActSetColiBoxL], a
	ld   a, +$04
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_StoveCanyonBossEyes
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_EyesD
	call ActS_SetOBJLstPtr
	pop  bc
	
	xor  a							; Make intangible
	ld   [sActSetColiType], a
	
	; Always sync with boss position:
	; - X: BossX
	; - Y: BossY - $06
	call Act_StoveCanyonBoss_CopyPosFromSync
	ld   bc, -$06
	call ActS_MoveDown
	ret
	
; =============== Act_StoveCanyonBossEyes ===============
Act_StoveCanyonBossEyes:
	;--
	; Hide if the boss is flashing after being hit
	ld   a, [sActBossParallaxFlashTimer]
	or   a
	jr   nz, .noEyes
	; Hide if the boss is off-screen.
	; [POI] This would have been better if the eyes weren't visible from behind
	;       the blocks and the lava, maybe. (use a lower Y target value)
	ld   a, [sActSetRelY]
	cp   a, $C0				; Is the actor off-screen below?
	jr   nc, .noEyes		; If so, hide the eyes
	;--
	
	; Sync with boss position
	call Act_StoveCanyonBoss_CopyPosFromSync
	ld   bc, -$06
	call ActS_MoveDown
	
	;
	; Determine which sprite mapping to use, depending on the player position.
	; It should look like the eyes are tracking the player.
	;
	
	
	;
	; X TRACK
	; A $1E value is offset to the actor's position both for checking if it's
	; to the left or to the right of the actor.
	;
	; This was done to split the screen in 3 sections relative to the boss (left, below/over, center)
	; where each section has its own eye position, so in theory they'd be organized like this:
	;
	;    |  U   |    
	;    | #### |  
	; L  |_BOSS_| R    
	;    | #### |    
	;    |  D   |   
	;    |      |    
	;
	; [BUG] But they inverted the conditions so eye tracking is broken in the middle section.
	;       It instead looks like this:
	;
	;    |  R        
	;    | ####    
	; L  | BOSS   R    
	;    | ####      
	;    |  R       
	;    |           
	;

	ld   a, [sPlXRel]		; B = PlX
	ld   b, a
	ld   a, [sActSetRelX]	; A = ActX - $1E
	
	; [BUG] What this was meant to check:
	;       -> If the player is to the left of the boss (- offset for the center area), use the left-eye set.
	;       What this actually does:
	;       -> If the player is to the right of the boss (- offset for the center area), use the right-eye set.
	;       This means the right section *and* the center section all make use of the right eye set.
	;       It's particularly noticeable when bumping the boss from the left side -- which causes it
	;       to move the eyes to the right, which is definitely wrong.
	sub  a, $1E
	cp   a, b				; ActX - $1E < PlX?
IF FIX_BUGS
	jr  nc, .eyesL			; If so, jump
ELSE
	jr   c, .eyesR			; If so, jump
ENDC
	
	
	; [BUG] What this was meant to check:
	;       -> If the player is to the right of the boss (+ offset for the center area), use the right-eye set.
	;       What this actually does:
	;       -> If the player is to the left of the boss (+ offset for the center area), use the left-eye set.
	;       This would cause it to trigger in the center section, but that's already stolen by the previous buggy check.
	
	; (add an extra $1E back to account for the one subtracted before)
	add  $1E+$1E			; A = ActX + $1E
	cp   a, b				; ActX + $1E > PlX?
IF FIX_BUGS
	jr   c, .eyesR			; If so, jump
ELSE
	jr   nc, .eyesL			; If so, jump
ENDC
	
	
	; If the player is in the middle $3C area, pick different frames
	; depending on the vertical position.
	;
	; Y TRACK
	;
	
	ld   a, [sPlYRel]		; B = PlY
	ld   b, a
	ld   a, [sActSetRelY]	; A = ActY - $20
	
	; If the player is below the actor, use the down-eye set
	sub  a, $20
	cp   a, b				; ActY - $20 < PlY?
	jr   c, .eyesD			; If so, jump

.eyesU:
	; Otherwise, use the up-eye set.
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_EyesU
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.eyesR:;R
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_EyesR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.eyesL:;R
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_EyesL
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.eyesD:;R
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_EyesD
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.noEyes:;R
	mActS_SetBlankFrame
	ret
	
OBJLstPtrTable_Act_StoveCanyonBoss_EyesD:
	dw OBJLst_Act_StoveCanyonBoss_EyesD
	dw $0000;X
OBJLstPtrTable_Act_StoveCanyonBoss_EyesR:
	dw OBJLst_Act_StoveCanyonBoss_EyesR
	dw $0000;X
OBJLstPtrTable_Act_StoveCanyonBoss_EyesL:
	dw OBJLst_Act_StoveCanyonBoss_EyesL
	dw $0000;X
OBJLstPtrTable_Act_StoveCanyonBoss_EyesU:
	dw OBJLst_Act_StoveCanyonBoss_EyesU
	dw $0000;X

; =============== ActInit_StoveCanyonBossTongue ===============
ActInit_StoveCanyonBossTongue:
	; Setup collision box
	ld   a, -$20
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$04
	ld   [sActSetColiBoxL], a
	ld   a, +$04
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_StoveCanyonBossTongue
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_Tongue_Show
	call ActS_SetOBJLstPtr
	pop  bc
	
	xor  a										; Start as intangible
	ld   [sActSetColiType], a
	
	; Always sync with boss position:
	; - X: BossX
	; - Y: BossY + $20
	call Act_StoveCanyonBoss_CopyPosFromSync
	ld   bc, $0020
	call ActS_MoveDown
	
	xor  a
	ld   [sActStoveCanyonBossTongueRoutineId], a
	ret
; =============== Act_StoveCanyonBossTongue ===============
Act_StoveCanyonBossTongue:
	; If the boss is flashing, hide the tongue
	ld   a, [sActBossParallaxFlashTimer]
	or   a
	jr   nz, Act_StoveCanyonBossTongue_Hide
	
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Sync with boss position
	call Act_StoveCanyonBoss_CopyPosFromSync		
	ld   bc, $0020
	call ActS_MoveDown
	
	ld   a, [sActStoveCanyonBossTongueRoutineId]
	rst  $28
	dw Act_StoveCanyonBossTongue_Disabled
	dw Act_StoveCanyonBossTongue_SwitchToEnabled
	dw Act_StoveCanyonBossTongue_Enabled
	
; =============== Act_StoveCanyonBossTongue_Hide ===============
; Makes the tongue intangible and hides it.
Act_StoveCanyonBossTongue_Hide:
	xor  a
	ld   [sActSetColiType], a
	ld   a, LOW(OBJLstPtrTable_Act_StoveCanyonBoss_Tongue_None)					
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_StoveCanyonBoss_Tongue_None)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	ret
	
; =============== Act_StoveCanyonBossTongue_Disabled ===============
; Tongue disabled.
Act_StoveCanyonBossTongue_Disabled:
	mActS_SetBlankFrame
	
	; [BUG?] I don't even know.
	;        The enable tongue option is meant to be set only by the boss itself.
	;        If we change it here, it will be set back to $00 by the boss code,
	;        meaning it ends up opening the mouth only for a few frames.
IF !FIX_BUGS
	ld   a, [sActSetTimer]
	and  a, $FF
	jr   z, Act_StoveCanyonBossTongue_SwitchToEnabled
ENDC
	; Every $10 frames write the closed mouth.
	; This, along with the above check, should have really been placed elsewhere...
	ld   a, [sActSetTimer]
	and  a, $0F
	ret  nz
	call Act_StoveCanyonBoss_BGWrite_MouthClosed
	
	ret
	
; =============== Act_StoveCanyonBossTongue_SwitchToEnabled ===============
; Enables the tongue.
Act_StoveCanyonBossTongue_SwitchToEnabled:
	call Act_StoveCanyonBoss_BGWrite_MouthOpen
	
	ld   a, SCBOSSTNG_RTN_ENABLED
	ld   [sActStoveCanyonBossTongueRoutineId], a
	
	push bc							; Show visible sprite
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_Tongue_Show
	call ActS_SetOBJLstPtr
	pop  bc
	
	xor  a
	ld   [sActStoveCanyonBossTongueBlockHit], a	; Allow breaking a block
	ld   a, SFX1_1C 			
	ld   [sSFX1Set], a
	ret
	
; =============== Act_StoveCanyonBossTongue_Enabled ===============
; Handles the tongue when it's enabled.
Act_StoveCanyonBossTongue_Enabled:
	;--
	; Handle the collision type
	; By default, make the tongue intangible...
	xor  a						
	ld   [sActSetColiType], a
	; ...except it's displaying the 4th anim frame.
	; In that case, it should deal damage to the player.
	ld   a, [sActSetOBJLstId]
	cp   a, $04
	call z, Act_StoveCanyonBossTongue_Hit
	;--
	
	ld   a, LOW(OBJLstPtrTable_Act_StoveCanyonBoss_Tongue_Show)
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_StoveCanyonBoss_Tongue_Show)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	
	; Animate every $10 frames
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .chkEnd
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.chkEnd:

	; When the animation ends, disable the tongue once again.
	ld   a, [sActSetOBJLstId]
	cp   a, $09
	ret  c
	xor  a
	ld   [sActStoveCanyonBossTongueRoutineId], a
	ret
; =============== Act_StoveCanyonBossTongue_Hit ===============
; Causes the tongue to try break the block below (if it wasn't done already),
; and also tries to damage the player on the way.
Act_StoveCanyonBossTongue_Hit:

	; Try to hit the player
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	;--
	; Try to hit a breakable block
	ld   a, [sActStoveCanyonBossTongueBlockHit]
	or   a				; Was it already done? 
	ret  nz				; If so, return. Don't hit blocks more than once per pass.
	ld   a, $01
	ld   [sActStoveCanyonBossTongueBlockHit], a
	
	
	; Get a ptr to the level layout based on the current tongue's location.
	; Since an actor's origin is at the very bottom, these coordinates as-is work out.
	ld   a, [sActSetX_Low]	; DE = ActorX
	ld   e, a
	ld   a, [sActSetX_High]
	ld   d, a
	ld   a, [sActSetY_Low]	; BC = ActorY
	ld   c, a
	ld   a, [sActSetY_High]
	ld   b, a
	; Use them to generate a level layout ptr, and save it to HL
	mActColi_GetBlockId_GetLevelLayoutPtr	
	
	; Simulate a dragon flame attack on this block.
	ld   a, h						; HL = Block to hit
	ld   [sBlockTopLeftPtr_High], a
	ld   a, l
	ld   [sBlockTopLeftPtr_Low], a
	; Because this goes through the normal breakable block collision code,
	; if we're Bull Wario, the tongue would instantly break the block.
	; That would be bad.
	; Temporarily set the powerup status to an invalid value, which
	; will make the instant break check fail.
	ld   a, [sPlPower]				
	add  $10
	ld   [sPlPower], a
	call ExActBGColi_DragonHatFlame_CheckBlockId
	ld   a, [sPlPower]				
	sub  a, $10
	ld   [sPlPower], a
	ret
	
; =============== ActInit_Unused_StoveCanyonBossBall ===============
; [TCRF] Unreachable init code for the snot ball.
;        This actor is only spawned by the boss, so this goes unused.
;
;        The presence of this code is curious, since unlike the spawn routine in the boss code,
;        this one skips the fireball mode.
;        Note that this code would be used if this were to be part of an actor layout.
ActInit_Unused_StoveCanyonBossBall:
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, -$08
	ld   [sActSetColiBoxD], a
	ld   a, -$04
	ld   [sActSetColiBoxL], a
	ld   a, +$04
	ld   [sActSetColiBoxR], a
	
	; Setup code ptr
	ld   bc, SubCall_Act_StoveCanyonBossBall
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Idle
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_StoveCanyonBoss_Ball
	call ActS_SetOBJLstSharedTablePtr
	
	; Skip fireball mode
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ld   a, SCBOSSBALL_RTN_SAFE					
	ld   [sActLocalRoutineId], a
	
	mActSetYSpeed $00
	ret
	
; =============== Act_StoveCanyonBossBall ===============
Act_StoveCanyonBossBall:
	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	;--
	; Avoid retriggering the effect below
	ld   a, [sActLocalRoutineId]
	cp   a, $02
	jp   z, Act_StoveCanyonBossBall_Splash
	
	; If the actor is over a lava block, show a splash effect
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSpikeBlock
	or   a
	jp   nz, Act_StoveCanyonBossBall_SwitchToSplash
	;--
	
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_StoveCanyonBossBall_Fireball
	dw Act_StoveCanyonBossBall_Safe
	dw Act_StoveCanyonBossBall_Splash
	
; =============== Act_StoveCanyonBossBall_Fireball ===============
; Fireball mode, as shoot by the boss.
; This moves down until it touches solid ground.
Act_StoveCanyonBossBall_Fireball:
	call ActS_IncOBJLstIdEvery8
	
	; A fireball is deadly to touch no matter which side it is
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Move horizontally
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_StoveCanyonBossBall_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_StoveCanyonBossBall_MoveLeft
	
	; Move down 3px/frame
	ld   bc, +$03
	call ActS_MoveDown
	
	; When it touches solid ground, switch to the next mode
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is the actor on a solid block?
	ret  z								; If not, return
	
	ld   a, SCBOSSBALL_RTN_SAFE
	ld   [sActLocalRoutineId], a
	mActSetYSpeed -$04
	
	ret
	
; =============== Act_StoveCanyonBossBall_MoveRight ===============
; Moves the fireball right 1px.
Act_StoveCanyonBossBall_MoveRight:
	ld   bc, +$01
	call ActS_MoveRight
	ld   a, LOW(OBJLstPtrTable_Act_StoveCanyonBoss_Ball_FireR)
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_StoveCanyonBoss_Ball_FireR)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	ret
	
; =============== Act_StoveCanyonBossBall_MoveLeft ===============
; Moves the fireball left 1px.
Act_StoveCanyonBossBall_MoveLeft:
	ld   bc, -$01
	call ActS_MoveRight
	ld   a, LOW(OBJLstPtrTable_Act_StoveCanyonBoss_Ball_FireL)
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_StoveCanyonBoss_Ball_FireL)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	ret
	
; =============== Act_StoveCanyonBossBall_Safe ===============
; Harmless ball mode.
; If left to itself, it ignores solid blocks and falls in lava.
Act_StoveCanyonBossBall_Safe:
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_StoveCanyonBossBall_Safe_Main
	dw SubCall_ActS_StartHeld
	dw SubCall_ActS_StartHeld
	dw SubCall_ActS_StartStarKill;X
	dw SubCall_ActS_StartHeld
	dw SubCall_ActS_StartHeld
	dw Act_StoveCanyonBossBall_Safe_Main;X
	dw Act_StoveCanyonBossBall_Safe_Main;X
	dw Act_StoveCanyonBossBall_Safe_Main
	
; =============== Act_StoveCanyonBossBall_Safe_Main ===============
Act_StoveCanyonBossBall_Safe_Main:
	call ActS_IncOBJLstIdEvery8
	
	; Always fall down regardless of solidity
	call ActS_FallDownMax4Speed
	
	; Move horizontally
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_StoveCanyonBossBall_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_StoveCanyonBossBall_MoveLeft
	
	; The above subroutines set the OBJLst used for the fireball mode.
	; Set the correct one to fix that.
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Idle
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Permanently despawn once off-screen.
	; (the built-in flag could have been used... again)
	call ActS_CheckOffScreen	; Update offscreen status
	ld   a, [sActSetStatus]
	cp   a, ATV_ONSCREEN		; Is the actor visible?
	ret  nc						; If so, return
	xor  a						; Otherwise, despawn it
	ld   [sActSetStatus], a
	ret
	
; =============== Act_StoveCanyonBossBall_SwitchToSplash ===============	
Act_StoveCanyonBossBall_SwitchToSplash:
	ld   a, SCBOSSBALL_RTN_SPLASH
	ld   [sActLocalRoutineId], a
	
	xor  a								; It's only a visual effect
	ld   [sActSetColiType], a
	ld   [sActStoveCanyonBossBallModeTimer], a
	
	; Move almost 1 block above.
	; This is to make the effect play on top of the lava, not inside it.
	ld   bc, -$0C						
	call ActS_MoveDown
	
	push bc
	ld   bc, OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Splash
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, SFX4_0C			
	ld   [sSFX4Set], a
	ret
; =============== Act_StoveCanyonBossBall_Splash ===============
; Lava splash mode.
Act_StoveCanyonBossBall_Splash:
	xor  a
	ld   [sActSetColiType], a
	
	ld   a, LOW(OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Splash)
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Splash)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	
	call ActS_IncOBJLstIdEvery8
	
	; Handle the timer.
	; After $38 frames (some time before the anim ends), despawn the actor.
	ld   a, [sActStoveCanyonBossBallModeTimer]	; Timer++
	inc  a
	ld   [sActStoveCanyonBossBallModeTimer], a
	cp   a, $38									; Timer < $38?
	ret  c										; If so, return
	xor  a
	ld   [sActSetStatus], a
	ret
	
OBJLstSharedPtrTable_Act_StoveCanyonBoss_Ball:
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Idle;X
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Idle;X
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Idle;X
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Idle;X
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Idle
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Idle
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Idle;X
	dw OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Idle;X

OBJLstPtrTable_Act_StoveCanyonBoss_Ball_FireL:
	dw OBJLst_Act_StoveCanyonBoss_Ball_Idle
	dw OBJLst_Act_StoveCanyonBoss_Ball_FireL
	dw $0000
OBJLstPtrTable_Act_StoveCanyonBoss_Ball_FireR:
	dw OBJLst_Act_StoveCanyonBoss_Ball_Idle
	dw OBJLst_Act_StoveCanyonBoss_Ball_FireR
	dw $0000
OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Idle:
	dw OBJLst_Act_StoveCanyonBoss_Ball_Idle
	dw $0000
OBJLstPtrTable_Act_StoveCanyonBoss_Ball_Splash:
	dw OBJLst_Act_StoveCanyonBoss_Ball_Splash0 ; 0
	dw OBJLst_Act_StoveCanyonBoss_Ball_Splash1 ; 08
	dw OBJLst_Act_StoveCanyonBoss_Ball_Splash2 ; 10
	dw OBJLst_Act_StoveCanyonBoss_Ball_Splash3 ; 18
	dw OBJLst_Act_StoveCanyonBoss_Ball_Splash4 ; 20
	dw OBJLst_Act_StoveCanyonBoss_Ball_Splash5 ; 28
	dw OBJLst_Act_StoveCanyonBoss_Ball_Splash0 ; 30
	dw OBJLst_Act_StoveCanyonBoss_Ball_Splash0 ; 38
	dw OBJLst_Act_None;X
	dw $0000;X

OBJLstPtrTable_Act_StoveCanyonBoss_Tongue_Show:
	dw OBJLst_Act_StoveCanyonBoss_Tongue0
	dw OBJLst_Act_StoveCanyonBoss_Tongue1
	dw OBJLst_Act_StoveCanyonBoss_Tongue2
	dw OBJLst_Act_StoveCanyonBoss_Tongue3
	dw OBJLst_Act_StoveCanyonBoss_Tongue4 ; This causes damage
	dw OBJLst_Act_StoveCanyonBoss_Tongue3
	dw OBJLst_Act_StoveCanyonBoss_Tongue2
	dw OBJLst_Act_StoveCanyonBoss_Tongue1
	dw OBJLst_Act_StoveCanyonBoss_Tongue0
	dw $0000

; [POI] Why is this so long?
OBJLstPtrTable_Act_StoveCanyonBoss_Tongue_None:
	dw OBJLst_Act_None
	dw OBJLst_Act_None;X
	dw OBJLst_Act_None;X
	dw OBJLst_Act_None;X
	dw OBJLst_Act_None;X
	dw OBJLst_Act_None;X
	dw OBJLst_Act_None;X
	dw OBJLst_Act_None;X
	dw OBJLst_Act_None;X
	dw OBJLst_Act_None;X
	dw $0000;X
	
; [TCRF] Unused licking animation.
;        The first frame uses the only tile in the GFX "archive" which doesn't get loaded.
OBJLstPtrTable_Act_StoveCanyonBoss_Tongue_Unused_Lick:
	dw OBJLst_Act_StoveCanyonBoss_Tongue_Unused_Lick0;X
	dw OBJLst_Act_StoveCanyonBoss_Tongue_Unused_Lick1;X
	dw OBJLst_Act_StoveCanyonBoss_Tongue1;X
	dw OBJLst_Act_StoveCanyonBoss_Tongue0;X
	dw $0000;X
; [TCRF] And whatever this is, probably set after the lick anim finished.
OBJLstPtrTable_Act_StoveCanyonBoss_Tongue_Unused_PostLick:
	dw OBJLst_Act_StoveCanyonBoss_Tongue0;X
	dw $0000;X

; =============== ActInit_Floater ===============
ActInit_Floater:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, $E8
	ld   [sActSetColiBoxU], a
	ld   a, $00
	ld   [sActSetColiBoxD], a
	ld   a, $F8
	ld   [sActSetColiBoxL], a
	ld   a, $08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Floater
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_Floater_Idle
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Floater
	call ActS_SetOBJLstSharedTablePtr
	
	ld   a, ACTCOLI_TOPSOLID
	ld   [sActSetColiType], a
	xor  a						; Start by not moving
	ld   [sActSetDir], a
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActFloaterDir], a
	mSubCall ActS_SaveColiType ; BANK $02
	call Act_Floater_SpawnArrow
	ret
	
OBJLstPtrTable_Act_Floater_Idle:
	dw OBJLst_Act_Floater_Idle0
	dw OBJLst_Act_Floater_Idle1
	dw OBJLst_Act_Floater_Idle2
	dw OBJLst_Act_Floater_Idle3
	dw $0000
OBJLstPtrTable_Act_Floater_Push:
	dw OBJLst_Act_Floater_Idle0
	dw OBJLst_Act_Floater_Push
	dw OBJLst_Act_Floater_Push
	dw OBJLst_Act_Floater_Idle0
	dw OBJLst_Act_Floater_Idle0;X
	dw $0000;X
OBJLstPtrTable_Act_Floater_Move:
	dw OBJLst_Act_Floater_Idle0
	dw $0000;X

; =============== Act_Floater ===============
Act_Floater:
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_Floater_Idle
	dw Act_Floater_WaitMove
	dw Act_Floater_Move
	dw Act_Floater_WaitIdle
	
; =============== Act_Floater_SwitchToIdle ===============

Act_Floater_SwitchToIdle:
	xor  a
	ld   [sActLocalRoutineId], a
	push bc
	ld   bc, OBJLstPtrTable_Act_Floater_Idle
	call ActS_SetOBJLstPtr
	pop  bc
	xor  a
	ld   [sActFloaterIdleIndex], a
	ret
	
; =============== Act_Floater_Idle ===============
; Idle.
Act_Floater_Idle:
	call ActS_IncOBJLstIdEvery8
	
	; Move every other frame.
	ld   a, [sActSetTimer]
	and  a, $01
	jr   nz, .chkTop
	
	
	; When we aren't on this actor, it moves by itself in a circle-like motion.
	; This path is specified as an offset table.
	; Each table entry contains 2 bytes:
	; - 0: X offset
	; - 1: Y offset
	
	;
	; This table is indexed by sActFloaterIdleIndex, which we're increasing every other frame.
	;
	ld   a, [sActFloaterIdleIndex]
	inc  a							; Index++
	cp   a, (Act_Floater_Idle_PosOffTbl.end-Act_Floater_Idle_PosOffTbl)/2	; Did we reach the end of the table?
	jr   c, .setIdx					; If not, skip
	xor  a							; Otherwise, reset back
.setIdx:
	ld   [sActFloaterIdleIndex], a
	;--
	
	;
	; Index the offset table
	;
	ld   hl, Act_Floater_Idle_PosOffTbl	; HL = Table
	add  a							; DE = sActFloaterIdleIndex * 2
	ld   d, $00
	ld   e, a
	add  hl, de						; Offset it
	
	;
	; Update the X pos
	;
	ldi  a, [hl]					; BC = X position
	ld   b, $00
	ld   c, a
	; Sign-extend it
	bit  7, a						; Is this a positive offset?
	jr   z, .setX					; If so, jump
	ld   b, $FF
.setX:
	push hl
	call ActS_MoveRight
	pop  hl
	
	;
	; Update the Y pos
	;
	ld   a, [hl]					; BC = Y position
	ld   b, $00
	ld   c, a
	bit  7, a						; Is this a positive offset?
	jr   z, .setY					; If so, jump
	ld   b, $FF
.setY:
	call ActS_MoveDown
	
	;
	; COLLISION CHECKS
	;
	
	; These are done in all directions, to prevent the circle movement from
	; pushing the actor into a solid block.
	; Each of these checks follows the same template -- if the actor is touching a solid
	; block on a certain direction, it is moved 1px in the opposite direction.
	;
	; Eventually, as frames pass with the actor trying to move in a circle motion,
	; there will be enough space available.
	; 
	
.chkGround:
	; If there's a block below move up
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, .chkTop
	ld   bc, -$01
	call ActS_MoveDown
	
.chkTop:
	; If there's a block on top move down
	call ActColi_GetBlockId_Top
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, .chkR
	ld   bc, +$01
	call ActS_MoveDown
	
.chkR:
	; If there's a block on the right move left
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, .chkL
	ld   bc, -$01
	call ActS_MoveRight
	
.chkL:
	; If there's a block on the left move right
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, .chkStand
	ld   bc, +$01
	call ActS_MoveRight
	
.chkStand:
	; If the player is standing on the actor, switch to the movement mode
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06
	jp   z, Act_Floater_SwitchToWaitMove
	ret
	
; =============== Act_Floater_SwitchToWaitMove ===============
Act_Floater_SwitchToWaitMove:
	ld   a, FLO_RTN_WAITMOVE
	ld   [sActLocalRoutineId], a
	
	push bc
	ld   bc, OBJLstPtrTable_Act_Floater_Push
	call ActS_SetOBJLstPtr
	pop  bc
	
	xor  a
	ld   [sActFloaterModeTimer], a
	
	; Cycle between directions (in order: down, right, up, left)
	ld   a, [sActFloaterDir]		; sActFloaterDir = (sActFloaterDir+1)%4
	inc  a
	and  a, $03
	ld   [sActFloaterDir], a
	
	ld   a, SFX4_19
	ld   [sSFX4Set], a
	; Fall through
	
; =============== Act_Floater_WaitMove ===============	
; Pauses for $18 frames before moving in a direction.
Act_Floater_WaitMove:
	call ActS_IncOBJLstIdEvery8
	
	; Handle the timer
	ld   a, [sActFloaterModeTimer]
	inc  a
	ld   [sActFloaterModeTimer], a
	cp   a, $18
	ret  c
	; Once it reaches $18, start moving
	ld   a, $02
	ld   [sActLocalRoutineId], a
	push bc
	ld   bc, OBJLstPtrTable_Act_Floater_Move
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_Floater_Move ===============	
; Movement mode.
Act_Floater_Move:
	; If the player is no longer standing on the actor, switch mode
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06
	jp   nz, Act_Floater_SwitchToWaitIdle
	
	; Move every other frame (0.5px/frame)
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	; Which direction are we moving to?
	ld   a, [sActFloaterDir]
	and  a, $03
	rst  $28
	dw Act_Floater_MoveDown
	dw Act_Floater_MoveRight
	dw Act_Floater_MoveUp
	dw Act_Floater_MoveLeft
	
; =============== Act_Floater_MoveDown ===============		
Act_Floater_MoveDown:
	; If there's a solid block below, don't move
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	ret  nz
	
	ld   bc, +$01
	call ActS_MoveDown
	
	; [POI] Unnecessary check. We can't get here if we aren't standing on the actor.
	;       This is common alongside all Act_Floater_Move* subroutines.
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06
	
	; Move player down if there isn't a solid block in the way
	; (ie: standing on the edge of the actor, with a solid block on the other side)
	ld   b, $01
	call z, SubCall_PlBGColi_CheckGroundSolidOrMove
	ret
	
; =============== Act_Floater_MoveRight ===============		
Act_Floater_MoveRight:
	; If there's a solid block on the right, don't move
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	ret  nz
	
	ld   bc, +$01
	call ActS_MoveRight
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06
	; Move player right if there isn't a solid block in the way
	call z, SubCall_ActS_PlStand_MoveRight
	ret
	
; =============== Act_Floater_MoveUp ===============		
Act_Floater_MoveUp:
	; If there's a solid block *two blocks* above, don't move.
	; This is to make sure there's enough space for the player to jump,
	; even as Big Wario. Otherwise we wouldn't be able to switch directions.
	ld   bc, -2*BLOCK_HEIGHT		; Trick ActColi in getting the block ID we need
	call ActS_MoveDown
	call ActColi_GetBlockId_Top
	push af
	ld   bc, 2*BLOCK_HEIGHT			; Move back down
	call ActS_MoveDown
	pop  af
	; [BUG] While it *almost* doesn't matter, this should have really used ActBGColi_IsSolid.
	;       This makes it impossible to travel through platforms.
IF FIX_BUGS
	mSubCall ActBGColi_IsSolid
ELSE
	mSubCall ActBGColi_IsSolidOnTop
ENDC
	or   a
	ret  nz
	; NOTE: To save time, we don't actually check if there's something on top of the actor itself. 
	
	ld   bc, -$01
	call ActS_MoveDown
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06
	ld   b, $01
	; Move player up if there isn't a solid block in the way
	call z, SubCall_PlBGColi_DoTopAndMove
	ret
	
; =============== Act_Floater_MoveLeft ===============		
Act_Floater_MoveLeft:
	; If there's a solid block on the left, don't move
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	ret  nz
	
	ld   bc, -$01
	call ActS_MoveRight
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06
	
	; Move player left if there isn't a solid block in the way
	call z, SubCall_ActS_PlStand_MoveLeft
	ret
	
; =============== Act_Floater_SwitchToWaitIdle ===============
Act_Floater_SwitchToWaitIdle:
	ld   a, FLO_RTN_WAITIDLE
	ld   [sActLocalRoutineId], a
	push bc
	ld   bc, OBJLstPtrTable_Act_Floater_Idle
	call ActS_SetOBJLstPtr
	pop  bc
	xor  a
	ld   [sActFloaterModeTimer], a
	ret
	
; =============== Act_Floater_WaitIdle ===============
; Pauses for a bit before returning to the idle. 
Act_Floater_WaitIdle:
	call ActS_IncOBJLstIdEvery8
	
	; Wait $3C frames before switching back to the idle mode.
	; During this time, landing back on the platform (ie: small hop)
	; makes it switch direction without going through the idle movement.
	
	ld   a, [sActFloaterModeTimer]		; Timer++
	inc  a
	ld   [sActFloaterModeTimer], a
	cp   a, $3C							; Timer expired?
	jp   nc, Act_Floater_SwitchToIdle	; If so, jump
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06					; Player standing on actor?
	jp   z, Act_Floater_SwitchToWaitMove	; If so, change direction
	ret
	
OBJLstSharedPtrTable_Act_Floater:
	dw OBJLstPtrTable_Act_Floater_Idle;X
	dw OBJLstPtrTable_Act_Floater_Idle;X
	dw OBJLstPtrTable_Act_Floater_Idle;X
	dw OBJLstPtrTable_Act_Floater_Idle;X
	dw OBJLstPtrTable_Act_Floater_Idle;X
	dw OBJLstPtrTable_Act_Floater_Idle;X
	dw OBJLstPtrTable_Act_Floater_Idle;X
	dw OBJLstPtrTable_Act_Floater_Idle;X

OBJLst_Act_Floater_Idle0: INCBIN "data/objlst/actor/floater_idle0.bin"
OBJLst_Act_Floater_Idle1: INCBIN "data/objlst/actor/floater_idle1.bin"
OBJLst_Act_Floater_Idle2: INCBIN "data/objlst/actor/floater_idle2.bin"
OBJLst_Act_Floater_Idle3: INCBIN "data/objlst/actor/floater_idle3.bin"
OBJLst_Act_FloaterArrow_R: INCBIN "data/objlst/actor/floaterarrow_r.bin"
OBJLst_Act_FloaterArrow_U: INCBIN "data/objlst/actor/floaterarrow_u.bin"
OBJLst_Act_FloaterArrow_L: INCBIN "data/objlst/actor/floaterarrow_l.bin"
OBJLst_Act_FloaterArrow_D: INCBIN "data/objlst/actor/floaterarrow_d.bin"
OBJLst_Act_Floater_Push: INCBIN "data/objlst/actor/floater_push.bin"
GFX_Act_Floater: INCBIN "data/gfx/actor/floater.bin"

; =============== Act_Floater_Idle_PosOffTbl ===============
; This table specifies the circle-like path the actor takes when
; we aren't standing on it. 
;
; Each table entry contains 2 bytes:
; - 0: X offset
; - 1: Y offset
;
; These values are added every other frame to the actor's current X and Y positions.
Act_Floater_Idle_PosOffTbl: 
	;  X     Y
	db -$01, +$00
	db -$01, +$00
	db -$01, +$01
	db -$01, +$00
	db -$01, +$01
	db -$01, +$01
	db +$00, +$01
	db -$01, +$01
	db +$00, +$01
	db +$00, +$01
	db +$00, +$01
	db +$00, +$01
	db +$00, +$01
	db +$01, +$01
	db +$00, +$01
	db +$01, +$01
	db +$01, +$01
	db +$01, +$00
	db +$01, +$01
	db +$01, +$00
	db +$01, +$00
	db +$01, +$00
	db +$01, +$00
	db +$01, +$00
	db +$01, -$01
	db +$01, +$00
	db +$01, -$01
	db +$01, -$01
	db +$00, -$01
	db +$01, -$01
	db +$00, -$01
	db +$00, -$01
	db +$00, -$01
	db +$00, -$01
	db +$00, -$01
	db -$01, -$01
	db +$00, -$01
	db -$01, -$01
	db -$01, -$01
	db -$01, +$00
	db -$01, -$01
	db -$01, +$00
	db -$01, +$00
	db -$01, +$00
.end:

; =============== Act_Floater_SpawnArrow ===============
; Spawns the direction marker.
Act_Floater_SpawnArrow:
	; Find an empty slot
	ld   hl, sAct				; HL = Actor slot area
	ld   d, ACTSLOT_COUNT_LO	; D = Total slots
	ld   e, $00					; E = Current slot
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
	mActS_SetOBJBank Act_FloaterArrow
	ld   a, ATV_ONSCREEN		; Enabled
	ldi  [hl], a
	ld   a, [sActSetX_Low]		; X
	ldi  [hl], a
	ld   a, [sActSetX_High]
	ldi  [hl], a
	ld   a, [sActSetY_Low]		; Y
	ldi  [hl], a
	ld   a, [sActSetY_High]
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Collision type
	ldi  [hl], a				; Coli box U
	ldi  [hl], a				; Coli box D
	ldi  [hl], a				; Coli box L
	ldi  [hl], a				; Coli box R
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
	
	ld   a, [sActSetId]			; Actor ID (same as parent)
	set  ACTB_NORESPAWN, a		; Don't make it respawn
	ldi  [hl], a
	
	xor  a						; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_FloaterArrow)		; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_FloaterArrow)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	ldi  [hl], a				; Timer 3
	ldi  [hl], a				; Timer 4
	ldi  [hl], a				; Timer 5
	ldi  [hl], a				; Timer 6
	ld   a, [sActNumProc]		; Timer 7 (parent slot for tracking)
	ldi  [hl], a
	
	ld   a, $01					; Flags
	ldi  [hl], a
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	ld   a, LOW(OBJLstSharedPtrTable_Act_None)	; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_None)
	ld   [hl], a
	ret
	
; =============== Act_FloaterArrow ===============
; Helper actor showing the movement direction of the parent Act_Floater.
Act_FloaterArrow:

	;-- 
	; Get ptr to tracked slot, like mActSeekToParentSlot.
	; mActSeekToParentSlot sActSetTimer7
	ld   a, [sActFloaterArrowParentSlot]
	and  a, ACTSLOT_COUNT
	rlca
	swap a
	ld   d, $00
	ld   e, a
	ld   hl, sAct
	add  hl, de
	;--
	
	; If the parent actor despawned, go down with it
	ldi  a, [hl]				; Read parent actor status
	or   a						; Is the slot empty?
	jr   z, .despawn			; If so, kill itself
	
	; Copy over the main actor coords.
	; The sprite mappings themselves position the arrow.
	ldi  a, [hl]				
	ld   [sActSetX_Low], a
	ldi  a, [hl]
	ld   [sActSetX_High], a
	ldi  a, [hl]
	ld   [sActSetY_Low], a
	ld   a, [hl]
	ld   [sActSetY_High], a
	
	; Seek to the actor's movement direction
	ld   hl, sAct+(sActFloaterDir-sActSet)
	add  hl, de					; Offset slotNum*$20
	
	; Show a different arrow depending on what's displayed
	ld   a, [hl]	; Read direction
	and  a, $03		; Filter away any invalid value
	rst  $28
	dw .down
	dw .right
	dw .up
	dw .left
.up:
	push bc
	ld   bc, OBJLstPtrTable_Act_FloaterArrow_U
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.down:
	push bc
	ld   bc, OBJLstPtrTable_Act_FloaterArrow_D
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.left:
	push bc
	ld   bc, OBJLstPtrTable_Act_FloaterArrow_L
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.right:
	push bc
	ld   bc, OBJLstPtrTable_Act_FloaterArrow_R
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.despawn:
	xor  a
	ld   [sActSetStatus], a
	ret
	
OBJLstPtrTable_Act_FloaterArrow_R:
	dw OBJLst_Act_FloaterArrow_R
	dw $0000;X
OBJLstPtrTable_Act_FloaterArrow_L:
	dw OBJLst_Act_FloaterArrow_L
	dw $0000;X
OBJLstPtrTable_Act_FloaterArrow_U:
	dw OBJLst_Act_FloaterArrow_U
	dw $0000;X
OBJLstPtrTable_Act_FloaterArrow_D:
	dw OBJLst_Act_FloaterArrow_D
	dw $0000;X


; =============== ActInit_KeyLock ===============
; The lock guarding treasure room doors.
; See also: ActInit_CoinLock
ActInit_KeyLock:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$30
	ld   [sActSetColiBoxU], a
	ld   a, -$10
	ld   [sActSetColiBoxD], a
	ld   a, -$04
	ld   [sActSetColiBoxL], a
	ld   a, +$04
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_KeyLock
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_KeyLock_Closed
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_KeyLock
	call ActS_SetOBJLstSharedTablePtr
	
	; Set collision type
	ld   a, ACTCOLI_LOCK
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	; Was the lock opened beforehand?
	ld   a, [sLvlTreasureDoor]
	ld   [sActKeyLockOpenStatus], a
	or   a						; Already open?
	ret  z						; If not, return
.instaOpen:
	; [BUG] This value isn't consistent with the timer target for the unlock anim.
	;		What this means is that, after unlocking the lock and respawning the actor,
	;		the opened lock will be placed slightly higher than it should be.
	;		This should have been -$19.
IF FIX_BUGS
	ld   bc, -$19				; Move lock out of the way
ELSE
	ld   bc, -$20				; Move lock out of the way
ENDC
	call ActS_MoveDown
	ld   a, LOCK_OPEN			; Set the door status as already open
	ld   [sLvlTreasureDoor], a
	ld   [sActKeyLockOpenStatus], a
	
	push bc						; Update OBJLst (since its eyes glow once open)
	ld   bc, OBJLstPtrTable_Act_KeyLock_Open	
	call ActS_SetOBJLstPtr
	pop  bc
	
	xor  a						; Make intangible
	ld   [sActSetColiType], a
	ret
	
OBJLstPtrTable_Act_KeyLock_Closed:
	dw OBJLst_Act_KeyLock0
	dw $0000;X
OBJLstPtrTable_Act_KeyLock_Open:
	dw OBJLst_Act_KeyLock0
	dw OBJLst_Act_KeyLock1
	dw OBJLst_Act_KeyLock2
	dw OBJLst_Act_KeyLock1
	dw $0000

; =============== Act_KeyLock ===============
Act_KeyLock:
	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Depending on the status of the lock...
	ld   a, [sActKeyLockOpenStatus]
	rst  $28
	dw Act_KeyLock_Closed
	dw Act_KeyLock_Opening
	dw Act_KeyLock_Open
	
; =============== Act_KeyLock_Closed ===============
; The lock is closed, and rebounds the player.
Act_KeyLock_Closed:
	; The only thing to do here is checking if a key was thrown at the lock.
	; In that case, the thrown actor will have set the lock's routine to $08.
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_SPEC_08		; Was something thrown at (or moved torwards) the lock?
	ret  nz						; If not, return
	
	; If the actor thrown at us wasn't a key, ignore
	mActCheckThrownId ACT_KEY
	ret  nz
	
	; Delete the thrown actor
	ld   hl, sAct
	add  hl, de					; Offset the slot (we got DE in mActCheckThrownId)
	xor  a						; Mark slot as free
	ld   [hl], a
	ld   [sActHeld], a			; Clear any hold status (if we walked into the lock)
	ld   [sActHeldKey], a		; 
	ld   a, LOCK_OPENING		; Open the lock
	ld   [sActKeyLockOpenStatus], a
	ld   [sLvlTreasureDoor], a	; Save it in the level info
	xor  a
	ld   [sActKeyLockUnlockTimer], a
	
	push bc						; Set glowing eyes
	ld   bc, OBJLstPtrTable_Act_KeyLock_Open
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, SFX1_08
	ld   [sSFX1Set], a
	
	; Fall through the next subroutine
	
; =============== Act_CoinLock_Opening ===============
; The lock is being opened and is moving out of the way.
Act_KeyLock_Opening:
	; Every $10 frames increase the anim counter
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .moveUp
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.moveUp:
	; Move up lock at 0.25px/frame
	ld   a, [sActSetTimer]
	and  a, $03					; Every 4 frames
	ret  nz
	ld   bc, -$01
	call ActS_MoveDown			; Move up 1px
	
	ld   a, SFX4_02
	ld   [sSFX4Set], a
	ld   a, $04					; Shake for 4 more frames
	ld   [sScreenShakeTimer], a
	ld   a, $0A					; And freeze player for more
	ld   [sPlFreezeTimer], a
	ld   a, [sActKeyLockUnlockTimer]	; MovementLeft--;
	inc  a
	ld   [sActKeyLockUnlockTimer], a
	cp   a, $19					; Has the lock moved up all the way?
	ret  c						; If not, return
	
	; Otherwise mark the lock as open
	ld   a, LOCK_OPEN
	ld   [sActKeyLockOpenStatus], a
	ld   [sLvlTreasureDoor], a	; Also in the level info, in case we despawn the lock
	xor  a						; Mark as intangible
	ld   [sActSetColiType], a
	ret
	
; =============== Act_CoinLock_Open ===============
; The lock is open, and can't be interacted with anymore.
Act_KeyLock_Open:
	xor  a						; Continue marking as intangible (just in case?)
	ld   [sActSetColiType], a
	
	; Every $10 frames increase the anim counter
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .end
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.end:
	ret
OBJLstSharedPtrTable_Act_KeyLock:
	dw OBJLstPtrTable_Act_KeyLock_Closed;X
	dw OBJLstPtrTable_Act_KeyLock_Closed;X
	dw OBJLstPtrTable_Act_KeyLock_Closed;X
	dw OBJLstPtrTable_Act_KeyLock_Closed;X
	dw OBJLstPtrTable_Act_KeyLock_Closed;X
	dw OBJLstPtrTable_Act_KeyLock_Closed;X
	dw OBJLstPtrTable_Act_KeyLock_Closed;X
	dw OBJLstPtrTable_Act_KeyLock_Closed;X

OBJLst_Act_KeyLock0: INCBIN "data/objlst/actor/keylock0.bin"
OBJLst_Act_KeyLock1: INCBIN "data/objlst/actor/keylock1.bin"
OBJLst_Act_KeyLock2: INCBIN "data/objlst/actor/keylock2.bin"
; [TCRF] Unused fourth mapping frame, identical to OBJLst_Act_KeyLock0
OBJLst_Act_KeyLock_Unused_3: INCBIN "data/objlst/actor/keylock_unused_3.bin"
GFX_Act_KeyLock: INCBIN "data/gfx/actor/keylock.bin"

; [TCRF] Technically possible to reach it, but only if despawning a bridge segment...
;        ...when its actor code isn't executing, since there's a check to delete the actor when it goes off-screen.
;        What this means is that it can only be triggered in debug freemove only, alongside the otherwise unused Routine $00.
;
;        When execution gets here, the bridge segment doesn't immediately drop, but it's
;        obvious that it's different compared to otber segments (since it's slightly below the others).
ActInit_Bridge:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, -$08
	ld   [sActSetColiBoxD], a
	ld   a, -$03
	ld   [sActSetColiBoxL], a
	ld   a, +$03
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Bridge
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_Bridge
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Bridge
	call ActS_SetOBJLstSharedTablePtr
	
	ld   a, ACTCOLI_TOPSOLID
	ld   [sActSetColiType], a
	ld   a, DIR_R
	ld   [sActSetDir], a
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	mSubCall ActS_SaveColiType
	ret  
	
OBJLstPtrTable_Act_Bridge:
	dw OBJLst_Act_Bridge
	dw $0000;X
	
; =============== Act_Bridge ===============
Act_Bridge:
	; Delete the actor when it goes off-screen.
	call ActS_CheckOffScreen	
	ld   a, [sActSetStatus]
	cp   a, ATV_ONSCREEN	; Visible & active?
	jr   nc, .main			; If so, skip
	xor  a					; Otherwise delete from level
	ld   [sActSetStatus], a
	ret
	
.main:
	push bc
	ld   bc, OBJLstPtrTable_Act_Bridge
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	;--
	; [TCRF] Assert that the routine ID isn't invalid. (< $03)
	;        If it is, infinite loop.
	ld   a, [sActLocalRoutineId]
	cp   a, BRIDGE_RTN_FAIL+1
	jr   nc, .assert_invalidMode
	;--
	rst  $28
	dw Act_Bridge_Idle;X
	dw Act_Bridge_Alert
	dw Act_Bridge_Fall
	dw .assert_invalidMode;X
	
.assert_invalidMode: jr .assert_invalidMode

; =============== Act_Bridge_Idle ===============
; [TCRF] This is an unused mode in practice, since the only
;        way to see it is through a side-effect of debug freemove mode.
; Waits for the player to step on it.
Act_Bridge_Idle:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06			; Is the player standing on it?
	ret  nz						; If not, return
	
	ld   a, BRIDGE_RTN_ALERT
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActBridgeModeTimer], a
	ret 
	
; =============== Act_Bridge_Alert ===============
; Bridge moves in place, to alert the player.
Act_Bridge_Alert:
	; Every 4 frames
	ld   a, [sActSetTimer]
	ld   b, a				; B = sActSetTimer
	and  a, $03
	jr   nz, .incTimer		
	
	; Move depending on a position offset table.
	ld   a, b				; Index = (sActSetTimer & 0b1100) / 2
	and  a, $0C				; Limit by table size
	rrca					; /2 for each entry being 2 bytes
	ld   hl, Act_Bridge_AlertXPath	; HL = Ptr to start of table
	ld   d, $00				; DE = Index
	ld   e, a
	add  hl, de				; Offset it
	ldi  a, [hl]			; BC = X offset
	ld   c, a
	ld   a, [hl]
	ld   b, a
	call ActS_MoveRight		; Move right by that
	
	; Every 8 frames play a SFX
	ld   a, [sActSetTimer]
	and  a, $07
	jr   nz, .incTimer
	ld   a, SFX4_19
	ld   [sSFX4Set], a
.incTimer:
	
	; After $19 frames, make the bridge segment fall
	ld   a, [sActBridgeModeTimer]
	inc  a
	ld   [sActBridgeModeTimer], a
	cp   a, $19
	ret  c
	
	ld   a, BRIDGE_RTN_FALL
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActBridgeModeTimer], a
	ret
	
Act_Bridge_AlertXPath: 
	dw -$01,+$00,+$01,+$00
	
; =============== Act_Bridge_Fall ===============
; Fall down at an increasing speed.
Act_Bridge_Fall:
	ld   a, [sActSetYSpeed_Low]	; BC = sActSetYSpeed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown				; Move down by that
	
	ld   a, [sActSetYSpeed_Low]
	ld   b, a
	
	; If the player is standing on it, make him move down as well,
	; as long as a solid block isn't on the way.
	; [POI] If would have been better here having a special case for jumping or air dashing.
	;       Sometimes you get dragged down the first few frames of jumping due to the game
	;       not updating sActSetRoutineId in time.
	;       At the faster drop speed of 3px/frame, this is a problem.
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06
	call z, SubCall_PlBGColi_CheckGroundSolidOrMove
	
	; Increase the drop speed every 8 frames, capped to 3px/frame
	ld   a, [sActSetTimer]
	and  a, $07
	ret  nz
	ld   a, [sActSetYSpeed_Low]
	cp   a, $03						; 3px/frame limit reached?
	ret  nc							; If so, return
	add  $01						; Otherwise, YSpeed++
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00
	ld   [sActSetYSpeed_High], a
	ret
	
OBJLstSharedPtrTable_Act_Bridge:
	dw OBJLstPtrTable_Act_Bridge;X
	dw OBJLstPtrTable_Act_Bridge;X
	dw OBJLstPtrTable_Act_Bridge;X
	dw OBJLstPtrTable_Act_Bridge;X
	dw OBJLstPtrTable_Act_Bridge;X
	dw OBJLstPtrTable_Act_Bridge;X
	dw OBJLstPtrTable_Act_Bridge;X
	dw OBJLstPtrTable_Act_Bridge;X
	
OBJLst_Act_Bridge: INCBIN "data/objlst/actor/bridge.bin"
GFX_Act_Bridge: INCBIN "data/gfx/actor/bridge.bin"

; =============== ActS_SpawnBridge ===============
; Spawns the falling bridge actor.
; OUT
; - sActBridgeSpawned: If 0, the actor was spawned
ActS_SpawnBridge:
	; Find the first empty slot we can use
	ld   hl, sAct
	ld   d, ACTSLOT_COUNT_LO	; D = Total allowed slots
	ld   e, $00					; E = Slot ID
.nextSlot:
	ld   a, [hl]	; Is this an empty slot?
	or   a
	jr   z, .found	; If so, use it
	
	inc  e			
	dec  d			; Did we check all slots?
	jr   z, .notFound	; If so, don't spawn the actor
	
	ld   a, l		; Move to the next slot
	add  $20
	ld   l, a
	jr   .nextSlot
.notFound:
	ld   a, $01
	ld   [sActBridgeSpawned], a
	ret
.found:
	mActS_SetOBJBank OBJLstPtrTable_Act_Bridge
	
	ld   a, $02					; Visible; active
	ldi  [hl], a
	
	ld   a, [sExActOBJX_Low]	; X
	ldi  [hl], a
	ld   a, [sExActOBJX_High]
	ldi  [hl], a
	
	ld   a, [sExActOBJY_Low]	; Y
	ldi  [hl], a
	ld   a, [sExActOBJY_High]
	ldi  [hl], a
	
	ld   a, $10					; Collision type
	ldi  [hl], a
	ld   a, $F0					; ColiBox L
	ldi  [hl], a
	ld   a, $F8					; ColiBox R
	ldi  [hl], a
	ld   a, $FD					; ColiBox U
	ldi  [hl], a
	ld   a, $03					; ColiBox D
	ldi  [hl], a
	ld   a, $00					; Rel Y (not set)
	ldi  [hl], a
	ld   a, $00					; Rel X (not set)
	ldi  [hl], a
	ld   a, LOW(OBJLstPtrTable_Act_Bridge)		; OBJLst table ptr
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_Bridge)		; OBJLst table ptr
	ldi  [hl], a
	
	xor  a						; Direction (not used)
	ldi  [hl], a
	xor  a						; OBJLst Id
	ldi  [hl], a
	ld   a, $01					; Actor ID
	ldi  [hl], a
	xor  a						; Routine ID
	ldi  [hl], a
	ld   a, LOW(SubCall_Act_Bridge)		; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_Bridge)		; Code Ptr
	ldi  [hl], a
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	ldi  [hl], a				; Y Speed (Low byte)
	ldi  [hl], a				; Y Speed (High byte)
	ld   a, BRIDGE_RTN_ALERT		; Local Routine ID
	ldi  [hl], a
	xor  a
	ldi  [hl], a				; Timer 6
	ldi  [hl], a				; Timer 7
	ld   a, $01					; Flags
	ldi  [hl], a				
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock); Level layout ptr (not used)
	ldi  [hl], a
	ld   a, LOW(OBJLstSharedPtrTable_Act_Bridge)	; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_Bridge)	; OBJLst shared table
	ldi  [hl], a
	
	xor  a
	ld   [sActBridgeSpawned], a
	
	ld   b, $01
	call SubCall_PlBGColi_CheckGroundSolidOrMove
	ret
	
; =============== ActInit_StickBomb ===============
; Bomb that sticks to the player it touched on anything but above.
ActInit_StickBomb:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, $FA
	ld   [sActSetColiBoxU], a
	ld   a, $06
	ld   [sActSetColiBoxD], a
	ld   a, $FA
	ld   [sActSetColiBoxL], a
	ld   a, $06
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_StickBomb
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_StickBomb_Idle
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_StickBomb
	call ActS_SetOBJLstSharedTablePtr
	
	; Reset timers
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ld   [sActLocalRoutineId], a
	ld   [sActStickBombPlRelY], a
	ld   [sActStickBombPlRelX], a
	
	; Make safe to touch
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	;--
	; Not necessary -- will be done in Act_StickBomb_SwitchToIdle
	ld   a, $3C				
	ld   [sActStickBombModeTimer], a
	;--
	
	call Act_StickBomb_SwitchToIdle
	ret
; =============== Act_StickBomb ===============
Act_StickBomb:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_StickBomb_Main
	dw Act_StickBomb_SwitchToStick
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartStarKill
	dw Act_StickBomb_SwitchToStick
	dw Act_StickBomb_SwitchToStick
	dw Act_StickBomb_SwitchToStick;X
	dw Act_StickBomb_Main
	dw SubCall_ActS_StartJumpDead
; =============== Act_StickBomb_Main ===============
Act_StickBomb_Main:;I
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_StickBomb_Idle
	dw Act_StickBomb_Move
	dw Act_StickBomb_Stick
	dw Act_StickBomb_Explode
	
; =============== Act_StickBomb_SwitchToIdle ===============
Act_StickBomb_SwitchToIdle:
	xor  a							; Switch to mode 0
	ld   [sActLocalRoutineId], a
	mActOBJLstPtrTable OBJLstPtrTable_Act_StickBomb_Idle	; Set initial anim
	
	; Do the idle movement for $3C frames
	ld   a, $3C						
	ld   [sActStickBombModeTimer], a
	ret
	
; =============== Act_StickBomb_Idle ===============
; Mode $00: The bomb waits for $3C frames while bobbing up and down by 1px.
Act_StickBomb_Idle:
	; Wait for the timer to elapse before moving
	ld   a, [sActStickBombModeTimer]
	dec  a
	ld   [sActStickBombModeTimer], a
	or   a
	jr   z, .nextMode
	
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	;
	; Do the vertical bob effect through a table of vertical offsets with 8 entries.
	; Note that the second entry is the one that is first used we get here the first time.
	;
	
	; Every other frame...
	ld   a, [sActSetTimer]
	ld   b, a				; B = Timer
	and  a, $01				; Timer % 2 == 1?
	ret  nz					; If so, return
	; DE = (Timer % 16) / 2
	ld   a, b				
	and  a, $0E				; Filter table size (shifted 1 bit for slower speed)
	rrca					; >> 1
	ld   d, $00
	ld   e, a
	ld   hl, .yPathTbl		; HL = Start of table		
	add  hl, de				; Offset it
	; Move down by that specified amount
	ld   a, [hl]			; C = Y amount to move
	ld   c, a
	sext a					; B = Sign-extended C
	ld   b, a
	call ActS_MoveDown		; Move down by BC
	ret
.yPathTbl:
	db -$01,-$01,-$01,-$00,+$01,+$01,+$01,+$00
	
.nextMode:
	ld   a, BOMS_RTN_MOVE
	ld   [sActLocalRoutineId], a
	; Set anim
	ld   a, LOW(OBJLstPtrTable_Act_StickBomb_Idle)
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_StickBomb_Idle)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	
	mActSetYSpeed +$04
	xor  a						; Clear timer
	ld   [sActSetTimer], a
	ret
	
; =============== Act_StickBomb_Move ===============
; Mode $01: Handles the downwards movement arc.
Act_StickBomb_Move:
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	;
	; Move horizontally
	;
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_StickBomb_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_StickBomb_MoveLeft
	
	;
	; Move vertically
	;
	call Act_StickBomb_MoveV
	
	;
	; If the upwards movement speed is faster than 4px, we've finished moving.
	;
	ld   a, [sActSetYSpeed_High]
	or   a								; YSpeed > 0?
	ret  z								; If so, it can't be < -$04
	ld   a, [sActSetYSpeed_Low]
	cp   a, -$04						; Y Speed >= -$04?
	ret  nc								; If so, return
	
	; Otherwise, we've reached the end of the path.
	; Turn direction and switch back to the idle mode.
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	jp   Act_StickBomb_SwitchToIdle
	
; =============== Act_StickBomb_MoveV ===============
Act_StickBomb_MoveV:
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	; Move down by the current vertical speed
	ld   a, [sActSetYSpeed_Low]		; BC = Y speed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown					; Move down by that
	
	; Decrease the downwards speed every 8 frames
	ld   a, [sActSetTimer]
	and  a, $07							; Timer % 8 != 0?
	ret  nz								; If so, return
	ld   a, [sActSetYSpeed_Low]		; YSpeed--
	sub  a, $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	sbc  a, $00
	ld   [sActSetYSpeed_High], a
	ret
	
; =============== Act_StickBomb_MoveRight ===============
; Moves the bomb right at 0.5px/frame.
Act_StickBomb_MoveRight:
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveRight
	ret
	
; =============== Act_StickBomb_MoveLeft ===============
; Moves the bomb left at 0.5px/frame.
Act_StickBomb_MoveLeft:
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
; =============== Act_StickBomb_SwitchToStick ===============
Act_StickBomb_SwitchToStick:
	ld   a, BOMS_RTN_STICK
	ld   [sActLocalRoutineId], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_StickBomb_Stick
	
	; Wait for $C8 frames before exploding
	ld   a, $C8
	ld   [sActStickBombModeTimer], a
	
	; The bomb sticks to the same position
	
	; Save the current horizontal distance between player and actor.
	; From now on, the actor will be repositioned to have the same
	; horizontal distance we have now, giving the effect of "sticking" to the player.
	ld   a, [sPlXRel]			; E = Player X pos
	ld   e, a
	ld   a, [sActSetRelX]		; A = Actor X pos
	sub  a, e					; Diff = ActorX - PlayerX
	ld   [sActStickBombPlRelX], a		; Save the value
	
	; Do the same for the vertical distance
	ld   a, [sPlYRel]			; E = Player Y pos
	ld   e, a
	ld   a, [sActSetRelY]		; A = Actor Y pos
	sub  a, e					; Diff = ActorY - PlayerY
	ld   [sActStickBombPlRelY], a		; Save the value
	
	xor  a						; Make intangible
	ld   [sActSetColiType], a
	ret
	
; =============== Act_StickBomb_Stick ===============	
; Mode $02: The bomb sticks to the player at the same rel. position
;           we set in Act_StickBomb_SwitchToStick.
Act_StickBomb_Stick:
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkExplode
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.chkExplode:
	; Time the explosion warning sequence.
	ld   a, [sActStickBombModeTimer]	; Timer--
	dec  a
	ld   [sActStickBombModeTimer], a
	or   a								; Timer == 0?
	jr   z, .nextMode					; If so, explode
	cp   a, $64							; Timer == $64?
	call z, .setFlash					; If so, start flashing
	ld   a, [sActStickBombModeTimer]
	call c, .flash						; Timer < $64? If so, continue flash
	
.followPl:
	;
	; Stick to the player until the actor *overlaps* with a solid block.
	; Since it's using ActColi_GetBlockId_Low, it needs to get partially
	; embedded in a wall.
	;
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is the actor overlapping with a wall?
	ret  nz							; If so, don't track the player anymore (stick to the wall)
	; Otherwise, track the player
	ld   a, [sActStickBombPlRelY]	; BC = Y stick distance to player
	ld   c, a						; C = Y distance
	sext a							; B = Sign-extended C
	ld   b, a
	ld   a, [sActStickBombPlRelX]	; DE = X stick distance to player
	ld   e, a
	sext a
	ld   d, a
	
	; Update the bomb's Y position to keep the same relative position to the player
	ld   a, [sPlY_Low]				; sActSetY = sPlY + BC
	add  c
	ld   [sActSetY_Low], a
	ld   a, [sPlY_High]
	adc  a, b
	ld   [sActSetY_High], a
	
	; And do the same for the X position
	ld   a, [sPlX_Low]				; sActSetX = sPlX + DE
	add  e
	ld   [sActSetX_Low], a
	ld   a, [sPlX_High]
	adc  a, d
	ld   [sActSetX_High], a
	
	ret
	
.setFlash:
	mActOBJLstPtrTable OBJLstPtrTable_Act_StickBomb_Flash
	ret
	
.flash:
	; Play the bomb ticking SFX every 4 frames
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, SFX4_14
	ld   [sSFX4Set], a
	ret
.nextMode:
	ld   a, BOMS_RTN_EXPLODE
	ld   [sActLocalRoutineId], a
	mActOBJLstPtrTable OBJLstPtrTable_Act_StickBomb_Explode
	ld   a, SFX4_13					; Play stick explosion SFX
	ld   [sSFX4Set], a
	ret
; =============== Act_StickBomb_Explode ===============
Act_StickBomb_Explode:
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	; Timing the collision box/despawn is based off the animation frame,
	; so there are hardcoded assumptions about it.
	ld   a, [sActSetOBJLstId]
	; When it reaches $02 (large explosion), set a large collision box to damage the player
	cp   a, $02
	jr   z, .setColi
	; When it reaches $04 (slightly less large explosion), delete the actor from the level
	cp   a, $04
	ret  c
	xor  a
	ld   [sActSetStatus], a
	ret
.setColi:
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI			
	ld   [sActSetColiType], a
	; 28*28 area for the large explosion, with the animation making you think you
	; would be able to duck under it, even though the box collision disagrees.
	ld   a, -$0E
	ld   [sActSetColiBoxU], a
	ld   a, +$0E
	ld   [sActSetColiBoxD], a
	ld   a, -$0E
	ld   [sActSetColiBoxL], a
	ld   a, +$0E
	ld   [sActSetColiBoxR], a
	ret
	
OBJLstSharedPtrTable_Act_StickBomb:
	dw OBJLstPtrTable_Act_StickBomb_Stun;X
	dw OBJLstPtrTable_Act_StickBomb_Stun;X
	dw OBJLstPtrTable_Act_StickBomb_Stun;X
	dw OBJLstPtrTable_Act_StickBomb_Stun;X
	dw OBJLstPtrTable_Act_StickBomb_Stun
	dw OBJLstPtrTable_Act_StickBomb_Stun
	dw OBJLstPtrTable_Act_StickBomb_Stun;X
	dw OBJLstPtrTable_Act_StickBomb_Stun;X

OBJLstPtrTable_Act_StickBomb_Stun:
	dw OBJLst_Act_StickBomb_Idle1
	dw $0000
OBJLstPtrTable_Act_StickBomb_Idle:
	dw OBJLst_Act_StickBomb_Idle0
	dw OBJLst_Act_StickBomb_Idle1
	dw $0000
OBJLstPtrTable_Act_StickBomb_Stick:
	dw OBJLst_Act_StickBomb_Stick0
	dw OBJLst_Act_StickBomb_Stick1
	dw $0000
OBJLstPtrTable_Act_StickBomb_Flash:
	dw OBJLst_Act_StickBomb_Flash0
	dw OBJLst_Act_StickBomb_Flash1
	dw $0000
OBJLstPtrTable_Act_StickBomb_Explode:
	dw OBJLst_Act_StickBomb_Explode0
	dw OBJLst_Act_StickBomb_Explode1
	dw OBJLst_Act_StickBomb_Explode2
	dw OBJLst_Act_None
	dw OBJLst_Act_None;X
	dw $0000;X

OBJLst_Act_StickBomb_Idle0: INCBIN "data/objlst/actor/stickbomb_idle0.bin"
OBJLst_Act_StickBomb_Idle1: INCBIN "data/objlst/actor/stickbomb_idle1.bin"
OBJLst_Act_StickBomb_Stick0: INCBIN "data/objlst/actor/stickbomb_stick0.bin"
OBJLst_Act_StickBomb_Stick1: INCBIN "data/objlst/actor/stickbomb_stick1.bin"
OBJLst_Act_StickBomb_Flash0: INCBIN "data/objlst/actor/stickbomb_flash0.bin"
OBJLst_Act_StickBomb_Flash1: INCBIN "data/objlst/actor/stickbomb_flash1.bin"
OBJLst_Act_StickBomb_Explode0: INCBIN "data/objlst/actor/stickbomb_explode0.bin"
OBJLst_Act_StickBomb_Explode1: INCBIN "data/objlst/actor/stickbomb_explode1.bin"
OBJLst_Act_StickBomb_Explode2: INCBIN "data/objlst/actor/stickbomb_explode2.bin"
GFX_Act_StickBomb: INCBIN "data/gfx/actor/stickbomb.bin"

; =============== ActInit_SSTeacupBossWatch ===============
; Special version of Act_Watch which turns around can be picked up and thrown.
ActInit_SSTeacupBossWatch:
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
	ld   bc, SubCall_Act_SSTeacupBossWatch
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_ActInit_SSTeacupBossWatch
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Watch
	call ActS_SetOBJLstSharedTablePtr
	
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	ld   a, DIR_L				; Boss is on the right, so move left
	ld   [sActSetDir], a
	
	xor  a
	ld   [sActSetTimer6], a
	ld   [sActSetTimer7], a
	ld   [sActSetYSpeed_High], a
	ld   a, $03
	ld   [sActSetYSpeed_Low], a
	ret
	
OBJLstPtrTable_ActInit_SSTeacupBossWatch:
	dw OBJLst_Act_Watch_MoveL0
	dw $0000;X

; =============== Act_SSTeacupBossWatch ===============
Act_SSTeacupBossWatch:
	; If the parent actor (SS Teacup boss) died, kill this one as well
	ld   a, [sActBossDead]
	or   a
	jp   nz, SubCall_ActS_StartJumpDead
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_SSTeacupBossWatch_Main
	dw Act_SSTeacupBossWatch_Main
	dw SubCall_ActS_OnPlColiBelow
	dw SubCall_ActS_StartStarKill
	dw SubCall_ActS_OnPlColiBelow
	dw Act_SSTeacupBossWatch_Main
	dw Act_SSTeacupBossWatch_Main;X
	dw Act_SSTeacupBossWatch_Main
	dw SubCall_ActS_StartJumpDead
	
; =============== Act_SSTeacupBossWatch ===============
Act_SSTeacupBossWatch_Main:
	call ActS_IncOBJLstIdEvery8
	
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Handle vertical & horizontal movement
	call Act_SSTeacupBossWatch_MoveVert
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_SSTeacupBossWatch_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_SSTeacupBossWatch_MoveLeft
	ret
	
; =============== Act_SSTeacupBossWatch_MoveRight ===============
; Moves the actor left 1px, updating the collision box as needed.
Act_SSTeacupBossWatch_MoveRight:
	ld   a, LOW(OBJLstPtrTable_Act_Watch_MoveR)
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_Watch_MoveR)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	
	ld   bc, +$01
	call ActS_MoveRight
	
	; Set right side as the one dealing damage
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Note that there's no collision check here.
	; Since the actor always starts moving left first, by the time it reaches the right border
	; it has lived long enough that we can make it go off-screen (and despawn).
	
	ret
; =============== Act_SSTeacupBossWatch_MoveRight ===============
; Moves the actor right 1px, updating the collision box as needed.
Act_SSTeacupBossWatch_MoveLeft:
	ld   a, LOW(OBJLstPtrTable_Act_Watch_MoveL)
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_Watch_MoveL)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	
	ld   bc, -$01
	call ActS_MoveRight
	
	; Set left side as the one dealing damage
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Turn right if we're touching the left border of the screen
	ld   a, [sActSetRelX]
	cp   a, $10				; Rel.X == $10? (2 tiles)
	call z, Act_SSTeacupBossWatch_Turn			; If so, turn
	ret
; =============== Act_SSTeacupBossWatch_Turn ===============
Act_SSTeacupBossWatch_Turn:
	ld   a, [sActSetDir]			; Switch direction
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ld   a, $03						; Move down in an arc, to make the bird stay a bit longer on-screen
	ld   [sActSetYSpeed_Low], a	
	xor  a
	ld   [sActSetYSpeed_High], a
	ret
; =============== Act_SSTeacupBossWatch_MoveVert ===============
; Almost identical to Act_Watch_MoveVert, except for two difference.
Act_SSTeacupBossWatch_MoveVert:
	; Update vertical pos every other frame
	ld   a, [sActSetTimer]
	and  a, $01
	jr   nz, .decSpeed		; [POI] In Act_Watch, it's "ret nz", as a slight optimization (the .chkSpeed check would fail anyway)
.move:
	; [POI] The /2 is specific to this actor
	ld   a, [sActSetYSpeed_Low]	; BC = sActSetYSpeed / 2
	sra  a							; (only the low byte to avoid affecting $FF)
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
	
OBJLstPtrTable_Act_Watch_MoveL:
	dw OBJLst_Act_Watch_MoveL0
	dw OBJLst_Act_Watch_MoveL1
	dw $0000
OBJLstPtrTable_Act_Watch_MoveR:
	dw OBJLst_Act_Watch_MoveR0
	dw OBJLst_Act_Watch_MoveR1
	dw $0000
; [TCRF] Same frame used 3 times. Was there something more to it?
OBJLstPtrTable_Act_Watch_StunL:
	dw OBJLst_Act_Watch_StunL
	dw OBJLst_Act_Watch_StunL
	dw OBJLst_Act_Watch_StunL
	dw $0000
OBJLstPtrTable_Act_Watch_StunR:
	dw OBJLst_Act_Watch_StunR
	dw OBJLst_Act_Watch_StunR
	dw OBJLst_Act_Watch_StunR
	dw $0000

OBJLstSharedPtrTable_Act_Watch:
	dw OBJLstPtrTable_Act_Watch_StunL;X
	dw OBJLstPtrTable_Act_Watch_StunR;X
	dw OBJLstPtrTable_Act_Watch_StunL
	dw OBJLstPtrTable_Act_Watch_StunR
	dw OBJLstPtrTable_Act_Watch_StunL
	dw OBJLstPtrTable_Act_Watch_StunR
	dw OBJLstPtrTable_Act_Watch_StunL;X
	dw OBJLstPtrTable_Act_Watch_StunR;X

OBJLst_Act_Watch_MoveL0: INCBIN "data/objlst/actor/watch_movel0.bin"
OBJLst_Act_Watch_MoveL1: INCBIN "data/objlst/actor/watch_movel1.bin"
OBJLst_Act_Watch_StunL: INCBIN "data/objlst/actor/watch_stunl.bin"
OBJLst_Act_Watch_MoveR0: INCBIN "data/objlst/actor/watch_mover0.bin"
OBJLst_Act_Watch_MoveR1: INCBIN "data/objlst/actor/watch_mover1.bin"
OBJLst_Act_Watch_StunR: INCBIN "data/objlst/actor/watch_stunr.bin"
GFX_Act_Watch: INCBIN "data/gfx/actor/watch.bin"

; =============== ActInit_Watch ===============
; That bird with an annoyingly large hitbox.
ActInit_Watch:
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
	ld   bc, SubCall_Act_Watch
	call ActS_SetCodePtr
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Watch
	call ActS_SetOBJLstSharedTablePtr
	
	; Set initial collision box (damaging side doesn't matter here)
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer6], a
	ld   [sActSetTimer7], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	; Depending on the direction the actor's facing, pick a different animation
	push bc
	ld   bc, OBJLstPtrTable_Act_Watch_MoveL	; Set initial OBJLst (left facing)
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, [sActSetDir]
	bit  DIRB_L, a			; Facing left?
	ret  nz					; If so, return
	push bc
	ld   bc, OBJLstPtrTable_Act_Watch_MoveR	; Set initial OBJLst (right facing)
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_Watch ===============
Act_Watch:
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Watch_Main
	dw Act_Watch_Main
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartStarKill
	dw SubCall_ActS_StartJumpDead
	dw Act_Watch_Main
	dw Act_Watch_Main;X
	dw Act_Watch_Main
	dw SubCall_ActS_StartJumpDeadSameColi
; =============== Act_Watch_Main ===============
Act_Watch_Main:
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_Watch_Idle
	dw Act_Watch_Attack
; =============== Act_Watch_Idle ===============
Act_Watch_Idle:
	call ActS_IncOBJLstIdEvery8
	
	; Update vertical position every 4 frames
	; (for the fly in-place effect)
	ld   a, [sActSetTimer]
	ld   b, a				; B = sActSetTimer
	and  a, $03
	jr   nz, .chkPlDistance
	
	; Move by a Y offset table.
	; The "AND" value used to keep the index in range relies on the number of entries in the table ($08)
	; as well as the ">> 2" operation (which ignores the lowest two bits).
	; (Act_Watch_Idle_YPath.end-Act_Watch_Idle_YPath-1) << 2 = $1C
	ld   a, b				; DE = sActSetTimer / 4
	and  a, $1C				
	rrca
	rrca
	ld   d, $00
	ld   e, a
	ld   hl, Act_Watch_Idle_YPath	; HL = Y offset table
	add  hl, de						; Offset it 
	
	ld   a, [hl]			; C = Amount to move down
	ld   c, a
	
	; [POI] Shortcut: Incomplete sign extension (sra should have been done 7 times).
	; This doesn't matter because of the level height used.
REPT 5						; B = Sign extended C
	sra  a					
ENDR
	ld   b, a
	call ActS_MoveDown
	
.chkPlDistance:
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
	ret  nc						; If so, return
	
	; Otherwise, start the attack sequence
	ld   a, BIRD_RTN_ATK
	ld   [sActLocalRoutineId], a
	mActSetYSpeed $03
	ld   a, SFX1_29
	ld   [sSFX1Set], a
	ret
Act_Watch_Idle_YPath: 
	db -$01,-$01,-$01,-$00,+$01,+$01,+$01,+$00
.end:

; =============== Act_Watch_Attack ===============
Act_Watch_Attack:
	call ActS_IncOBJLstIdEvery8
	
	; Handle vertical & horizontal movement
	call Act_Watch_MoveVert
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_Watch_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_Watch_MoveLeft
	
	; Instadespawn as soon as it goes off screen.
	; This could have been done through ACTFLAGB_UNUSED_FREEOFFSCREEN.
	call ActS_CheckOffScreen
	ld   a, [sActSetStatus]	; Read status
	cp   a, ATV_ONSCREEN	; Is it visible & active?
	ret  nc					; If so, return
	xor  a					; Otherwise, free the slot
	ld   [sActSetStatus], a
	ret
; =============== Act_Watch_MoveRight ===============
; Moves the actor right 1px, updating the collision box as needed.
Act_Watch_MoveRight:
	ld   a, LOW(OBJLstPtrTable_Act_Watch_MoveR)
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_Watch_MoveR)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	
	ld   bc, +$01
	call ActS_MoveRight
	
	; Set right side as the one dealing damage
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
; =============== Act_Watch_MoveLeft ===============
; Moves the actor left 1px, updating the collision box as needed.
Act_Watch_MoveLeft:
	ld   a, LOW(OBJLstPtrTable_Act_Watch_MoveL)
	ld   [sActSetOBJLstPtrTablePtr], a
	ld   a, HIGH(OBJLstPtrTable_Act_Watch_MoveL)
	ld   [sActSetOBJLstPtrTablePtr+1], a
	ld   bc, -$01
	call ActS_MoveRight
	
	; Set left side as the one dealing damage
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_Watch_MoveVert ===============
Act_Watch_MoveVert:
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
	
; =============== END OF BANK ===============
	mIncJunk "L187F2F"
