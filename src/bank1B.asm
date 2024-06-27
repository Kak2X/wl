;
; BANK $1B - Actor code
;

; =============== ActInit_Lamp ===============
ActInit_Lamp:
	; Setup collision box
	ld   a, -$12
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Lamp
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_Lamp_IdleIntro
	
	; Init vars
	xor  a
	ld   [sActSetColiType], a
	ld   [sActLampRoutineId], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	; Adjust position from block grid
	ld   bc, +$03
	call ActS_MoveDown
	ld   bc, +$04
	call ActS_MoveRight

	; If spawning in the ending, start in routine 7
	ld   a, [sActSyrupCastleBossDead]
	or   a
	ret  z
	ld   a, LAMP_RTN_HELDNOTHROW
	ld   [sActLampRoutineId], a
	ret
	
; =============== Act_Lamp_Unused_SyncPos ===============
; [TCRF] Unreferenced code to sync the unused alt variables for Act_Lamp_Unused_ApplyScrollChanges.
;        The ActSetX copy isn't synched over though.
;        Meant to be used alongside Act_Lamp_Unused_ApplyScrollChanges.
Act_Lamp_Unused_SyncPos:
	ld   a, [sActSetY_Low]
	ld   [sActLamp_Unused_ActSetYLast_Low], a
	ld   a, [sActSetY_High]
	ld   [sActLamp_Unused_ActSetYLast_High], a
	ld   a, [sParallaxY0]
	ld   [sActLamp_Unused_Y0ParallaxLast], a
	ld   a, [sParallaxX0]
	ld   [sActLamp_Unused_X0ParallaxLast], a
	ret 

; =============== Act_Lamp ===============
Act_Lamp:
	; Update the value trackable by other code.
	; In theory it isn't needed, since the actor can only be loaded in a certain slot,
	; but using a separate variable likely made it easier to change things around.
	ld   a, [sActSetRelX]
	ld   [sActLampRelXCopy], a
	;--
	
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	;--
	; [POI] Unnecessary check.
	;       The code that sets PL_HLD_SPEC_NOTHROW already calls Act_Lamp_SwitchToNoThrow.
	;       Since this actor handles the held mode by itself, there's no way to throw it.
	ld   a, [sActHeld]
	cp   a, PL_HLD_SPEC_NOTHROW
	call z, Act_Lamp_SwitchToNoThrow
	;--
	
	ld   a, [sActLampRoutineId]
	rst  $28
	dw Act_Lamp_IntroIdle
	dw Act_Lamp_InitFlash
	dw Act_Lamp_Flash
	dw Act_Lamp_Fall
	dw Act_Lamp_Main
	dw Act_Lamp_Hold
	dw Act_Lamp_Thrown
	dw Act_Lamp_HeldNoThrow
IF FIX_BUGS == 1
	dw Act_Lamp_InitMain
ENDC
	
; =============== Act_Lamp_SwitchToNoThrow ===============
Act_Lamp_SwitchToNoThrow:
	ld   a, LAMP_RTN_HELDNOTHROW		; New mode
	ld   [sActLampRoutineId], a
	xor  a								; Make intangible
	ld   [sActSetColiType], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ret
	
; =============== Act_Lamp_IntroIdle ===============
; Mode $00 - Idle on solid ground.
Act_Lamp_IntroIdle:
	; Just redraw itself
	mActOBJLstPtrTable OBJLstPtrTable_Act_Lamp_IdleIntro
	ret
	
; =============== Act_Lamp_Flash* ===============
; Mode $01. Sets up the animation which flashes the Lamp's palette as part of the final boss intro.
Act_Lamp_InitFlash:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Lamp_Flash
	ld   a, LAMP_RTN_FLASH
	ld   [sActLampRoutineId], a
	ret
	
; =============== Act_Lamp_Flash ===============
; Mode $02. Does the palette flash effect.
; This is meant to execute indefinitely until Act_SyrupCastleBoss changes our routine ID. 
Act_Lamp_Flash:
	call ActS_IncOBJLstIdEvery8
	; Not needed
	xor  a								
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	; Play SFX every other frame
	ld   a, [sActSetOBJLstId]
	bit  0, a
	ret  z
	ld   a, SFX1_05
	ld   [sSFX1Set], a
	ret
	
; =============== Act_Lamp_Unused_SwitchToFall ===============
; [TCRF] Unreachable code. (see Act_Lamp_Fall)
; Switches to the "fall" mode when not thrown by the player.
Act_Lamp_Unused_SwitchToFall: 	
	; Not necessary
	mActOBJLstPtrTable OBJLstPtrTable_Act_Lamp_Spin
	ld   a, LAMP_RTN_FALL
	ld   [sActLampRoutineId], a
	ret  
	
; =============== Act_Lamp_Fall ===============
; Mode $03. This mode would be used when solid ground disappears from below the lamp.
;
; Because the only way to get the lamp in the air is to throw it (which is handled elsewhere),
; there's no way to trigger this... except that this mode is intentionally set during the intro scene,
; since the lamp's spawn position isn't aligned to the ground.
; (this mode can be avoided altogether by changing the X/Y movement in ActInit_Lamp to make it align properly)
Act_Lamp_Fall:
	; Set spinning anim
	ld   a, LOW(OBJLstPtrTable_Act_Lamp_Spin)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Lamp_Spin)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Animate sprite mapping
	call ActS_IncOBJLstIdEvery8
	
	; Move down at 0.5px/frame until it lands on a solid block
	ld   a, [sActSetTimer]			; Every other frame...
	and  a, $01						
	ret  nz
	call ActS_FallDownMax4Speed		; Move down
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is it over a solid block?
	ret  z							; If not, return
	
	; Otherwise, switch to the next routine
	ld   a, LAMP_RTN_MAIN
	ld   [sActLampRoutineId], a
	mActOBJLstPtrTable OBJLstPtrTable_Act_Lamp_Idle
	ret
	
IF FIX_BUGS == 1
; =============== Act_Lamp_InitMain ===============
; Mode $08: Prepares the jump to the idle mode.
Act_Lamp_InitMain:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Lamp_Spin
	ld   a, LAMP_RTN_MAIN
	ld   [sActLampRoutineId], a
	ret
ENDC
; =============== Act_Lamp_Main ===============
; Idle mode after landing.
Act_Lamp_Main:
	; This mode is allowed when starting the ending cutscene
	ld   a, [sActSyrupCastleBossDead]
	or   a								; Boss defeated?
	jr   z, .setFrame					; If not, jump
	ld   a, $01							; Otherwise, give the go-ahead for starting the ending
	ld   [sActLampEndingOk], a
	
.setFrame:
	; Set idle anim
	ld   a, LOW(OBJLstPtrTable_Act_Lamp_Spin)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Lamp_Spin)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Pickable on all sides
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Do the submode jump
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Lamp_Main_Idle
	dw Act_Lamp_SwitchToHold
	dw Act_Lamp_SwitchToHold
	dw Act_Lamp_Main_Idle
	dw Act_Lamp_Main_Idle
	dw Act_Lamp_SwitchToHold
	dw Act_Lamp_Main_Idle;X
	dw Act_Lamp_Main_Idle;X
	dw Act_Lamp_Main_Idle
	
; =============== Act_Lamp_Main_Idle ===============
; [TCRF] This mode ends up doing nothing, since this is only used when the lamp is on solid ground.
Act_Lamp_Main_Idle:
	; If the actor isn't on solid ground, make it fall.
	; [TCRF] This subroutine is only called when the lamp is on solid ground.
	;	     so it never jumps.
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop		; 1 = Solid ground below
	or   a								; Is there solid ground below?
	jp   z, Act_Lamp_Unused_SwitchToFall						; If not, fall down
	;--
	
	; If the actor is inside a solid block, try to move it in the opposite direction
	; if there's a blank block on either side.
	; Each frame the actor is moved by 1px, until it is no longer is inside a solid block.
	
	; [TCRF] There's no way for this to happen in the boss room, so it always returns.
	;        As well, this actor ignores solid block collisions when held by the player.
	
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolidOnTop		
	or   a								; Is the lamp inside a top-solid block?
	ret  z								; If not, return (always the case)
	
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop	
	or   a								; Is there a solid block on the right?
	call z, Act_Lamp_MoveRight			; If not, move it right
	
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop	
	or   a								; Is there a solid block on the left?
	call z, Act_Lamp_MoveLeft			; If not, move it left
	
	ret  
	;--
	
; =============== Act_Lamp_SwitchToHold ===============
; When an idle lamp is picked up.
Act_Lamp_SwitchToHold:
	
	;
	; If we're holding the lamp in the ending, prevent any more code from executing.
	; This mode switch should not be done in the ending, since it would make it
	; possible to throw the lamp.
	;
	ld   a, [sActHeld]
	
	; [BUG] We aren't accounting for holding 10-coins.
	or   a				
	jr   z, .nextMode	
	
	cp   a, PL_HLD_SPEC_NOTHROW	; Are we holding the lamp in the ending?
	ret  z				; If so, stop and don't switch
	;--
	
.nextMode:
	ld   a, LAMP_RTN_HOLD				; Switch mode
	ld   [sActLampRoutineId], a
	xor  a						
	ld   [sActSetColiType], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ld   a, PL_HLD_WAITHOLD			 ; Start hold mode
	ld   [sActHeld], a
	ret
	
; =============== Act_Lamp_Hold ===============
; Mode $05: This mode handles the held state for the lamp.
Act_Lamp_Hold:

	;
	; This mode is also allowed when starting the ending cutscene.
	;
	; Even though it could have been avoided, once the boss is dead we switch
	; immediately to a separate cut-down mode to save time.
	; Since a separate ending mode exists, sActHeld is forced to $02 instead of also allowing $03.
	;
	
	ld   a, [sActSyrupCastleBossDead]
	or   a								; Boss defeated?
	jr   z, .main						; If not, skip
.endingOk:
	ld   a, $01							; Otherwise, give the go-ahead for starting the ending
	ld   [sActLampEndingOk], a
	ld   a, PL_HLD_SPEC_NOTHROW			; Set the no-throw mode
	ld   [sActHeld], a
	jp   Act_Lamp_SwitchToNoThrow		; And switch over to a specific mode
	
.main:
	call ActS_SyncHeldPos				; Update actor's pos
	ld   a, $02							; Force held/throwable flag
	ld   [sActHeld], a
	xor  a								; Lamp isn't heavy
	ld   [sActHoldHeavy], a
	
	;--
	; Prevent throwing the lamp when the boss is dead.
	; [TCRF] We can't get here with sActSyrupCastleBossDead set.
	;        Was Act_Lamp_SwitchToNoThrow and its mode added later on?
	ld   a, [sActSyrupCastleBossDead]
	or   a
	ret  nz
	;--
	
	; [BUG?] Is this intentional?
	;        The normal held code uses hJoyNewKeys to prevent from being able to automatically
	;        throw something when holding B all the time.
	;        Admittedly, it's useful in this case.
	ldh  a, [hJoyKeys]
	bit  KEYB_B, a						; Pressing/holding B?
	jr   nz, Act_Lamp_SwitchToThrow		; If so, throw the lamp.
	ret
	
; =============== Act_Lamp_SwitchToThrow ===============
Act_Lamp_SwitchToThrow:
	;--
	; [POI] sActHeld is always $02 when we get here
	ld   a, [sActHeld]
	cp   a, $02				
	ret  nz
	;--
	
	; [POI][BUG?] There's no alternate jump arc when past the peak of the jump.
	;             Here, the pre-peak value is used even when falling down. 
	mActSetYSpeed -$03				; 
	xor  a							; Remove held status
	ld   [sActHeld], a
	ld   a, $06
	ld   [sActLampRoutineId], a
	
	mPlFlagsToXDir 					; Throw in the same direction the player's facing
	ld   [sActSetDir], a
	
	ld   a, SFX1_0C					; Play throw SFX
	ld   [sSFX1Set], a
	ld   a, $14						; Set delay?
	ld   [sActLampStopDelay], a
	ret
	
; =============== Act_Lamp_Thrown ===============
; Mode $06: When the lamp is thrown by the player.
Act_Lamp_Thrown:
	;
	; Handle spinning animations
	;
	; Force spinning anim
	ld   a, LOW(OBJLstPtrTable_Act_Lamp_Spin)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Lamp_Spin)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	; Animate spin every 8 frames
	call ActS_IncOBJLstIdEvery8
	
.moveH:
	;
	; Handle horizontal movement
	;
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Moving right?
	call nz, Act_Lamp_MoveRight	; If so, call
	ld   a, [sActSetDir]
	bit  DIRB_L, a				; Moving left?
	call nz, Act_Lamp_MoveLeft	; If so, call
	
.moveV:
	;
	; Handle vertical movement
	;
	call ActS_FallDownMax4SpeedChkSolid
	
.chkEnd:

	call ActColi_GetBlockId_Ground		; Check for ground collision
	mSubCall ActBGColi_IsSolidOnTop		
	or   a								; Is there a solid block below?
	ret  z								; If not, keep falling
	
	;--
	; Make the actor slide for $14 frames on the ground.
	; Since the ground is completely flat in the boss room, there's no need to
	; reset the delay if the actor falls off a platform during the slide.
	ld   a, [sActLampStopDelay]
	or   a						; Delay elapsed yet?
	jr   nz, .decDelay			; If not, decrement it
	
	; After that, return to the main idle mode
	ld   a, LAMP_RTN_MAIN
	ld   [sActLampRoutineId], a
	
	; Align to Y block boundary
	ld   a, [sActSetY_Low]
	and  a, $F0
	ld   [sActSetY_Low], a
	
	; We're in this animation already -- not necessary to this set again
	ld   a, LOW(OBJLstPtrTable_Act_Lamp_Spin)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Lamp_Spin)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Roll the dice for the small cloud to spawn.
	call Rand
	and  a, $03					; 1/4 chance it does
	ld   [sActSetOBJLstId], a	; Set the appropriate rotation frame
	or   a						; Is it frame $00 (the standing one)?
	ret  nz						; If not, return
	
	; The cloud always spawns to the left of the lamp.
	; Prevent the cloud from spawning if it's too much close to the left screen border.
	ld   a, [sActSetRelX]
	cp   a, $18					; LampX < $18?
	ret  c						; If so, return
	
	; Otherwise, we can spawn the cloud
	call Act_Lamp_SpawnCloudPlatform
	ld   a, SFX1_01			; Set appropriate SFX
	ld   [sSFX1Set], a
	ret
.decDelay:
	ld   a, [sActLampStopDelay]		; Delay--
	dec  a
	ld   [sActLampStopDelay], a
	ret
	
; =============== Act_Lamp_MoveLeft ===============
Act_Lamp_MoveLeft:
	; If there's a solid block in the way, turn right
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, Act_Lamp_Turn
	
	ld   bc, -$01
	call ActS_MoveRight
	ret
; =============== Act_Lamp_MoveRight ===============
Act_Lamp_MoveRight:
	; If there's a solid block in the way, turn left
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, Act_Lamp_Turn
	
	ld   bc, +$01
	call ActS_MoveRight
	ret
; =============== Act_Lamp_MoveRight ===============
Act_Lamp_Turn:
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ret
; =============== Act_Lamp_Unused_ApplyScrollChanges ===============
; [TCRF] Unreferenced code.
;
; Moves and animates the actor to keep it in sync with any changes in the parallax layer,
; relative to the call to Act_Lamp_Unused_SyncPos.
; This is suspicious, since the lamp actor never needs to be in sync with the background.
; Maybe the Genie could grab the lamp?
; 
Act_Lamp_Unused_ApplyScrollChanges:	

	; Get the offset between the current and last parallax values
	; C = sParallaxY0 - sActLamp_Unused_Y0ParallaxTarget
	ld   a, [sActLamp_Unused_Y0ParallaxLast]
	ld   e, a
	ld   a, [sParallaxY0]
	sub  e
	ld   c, a
	
	; Subtract that to the last ActSetY value
	; sActSetY = sActLamp_Unused_ActSetYLast - C
	ld   a, [sActLamp_Unused_ActSetYLast_Low]
	sub  c
	ld   [sActSetY_Low], a
	ld   a, [sActLamp_Unused_ActSetYLast_High]
	sbc  a, $00
	ld   [sActSetY_High], a
	
	;--
	; Do the same thing for the X position
	; C = sParallaxX0 - sActLamp_Unused_X0ParallaxTarget
	ld   a, [sActLamp_Unused_X0ParallaxLast]
	ld   e, a
	ld   a, [sParallaxX0]
	sub  e
	ld   c, a
	
	; sActSetX = sActLamp_Unused_ActSetXLast - C
	ld   a, [sActLamp_Unused_ActSetXLast_Low]
	sub  c
	ld   [sActSetX_Low], a
	ld   a, [sActLamp_Unused_ActSetXLast_High]
	sbc  a, $00
	ld   [sActSetX_High], a
	
	; Animate the actor
	call ActS_IncOBJLstIdEvery8
	ret 
	
; =============== Act_Lamp_HeldNoThrow ===============
; Mode $07: Forced hold mode for the ending.
Act_Lamp_HeldNoThrow:
	xor  a						; Force upright frame
	ld   [sActSetOBJLstId], a
	call ActS_SyncHeldPos		; Keep in the held pos
	xor  a						; Not heavy
	ld   [sActHoldHeavy], a
	ret
	
; =============== OBJLstPtrTable_Act_Lamp_Idle ===============
OBJLstPtrTable_Act_Lamp_Idle:
	dw OBJLst_Act_Lamp_U
	dw $0000;X
OBJLstPtrTable_Act_Lamp_IdleIntro:
	dw OBJLst_Act_Lamp_Idle
	dw $0000;X
OBJLstPtrTable_Act_Lamp_Flash:
	dw OBJLst_Act_Lamp_Idle
	dw OBJLst_Act_Lamp_Flash
	dw $0000
OBJLstPtrTable_Act_Lamp_Spin:
	dw OBJLst_Act_Lamp_U
	dw OBJLst_Act_Lamp_L
	dw OBJLst_Act_Lamp_D
	dw OBJLst_Act_Lamp_R
	dw $0000
	
; =============== ActInit_LampSmoke ===============
ActInit_LampSmoke:
	; Setup collision box (not needed for this)
	ld   a, -$20
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_LampSmoke
	call ActS_SetCodePtr
	
	; No preview sprite
	mActS_SetBlankFrame
	
	xor  a
	ld   [sActLampSmokeRoutineId], a
	ld   [sActSetColiType], a
	ld   [sActLocalRoutineId], a
	
	; Do detailed alignment
	ld   bc, +$08
	call ActS_MoveDown
	ret
	

; [TCRF] Unused anim for a larger 3x3 smoke cloud.
;        This only looks correct after the Genie graphics load in.
OBJLstPtrTable_Act_LampSmoke_Unused_Large:
	dw OBJLst_Act_LampSmoke_Unused_Large0;X
	dw OBJLst_Act_LampSmoke_Unused_Large1;X
	dw $0000;X
OBJLstPtrTable_Act_LampSmoke:
	dw OBJLst_Act_LampSmoke0
	dw OBJLst_Act_LampSmoke1
	dw $0000


; =============== Act_LampSmoke ===============
Act_LampSmoke:
	ld   a, [sActLampSmokeRoutineId]
	rst  $28
	dw Act_LampSmoke_Hide
	dw Act_LampSmoke_InitMove
	dw Act_LampSmoke_Move
	dw Act_LampSmoke_Hide;X [POI] Suspicious (see [TCRF] note below)
	
; =============== Act_LampSmoke_Hide ===============
; Mode $00
Act_LampSmoke_Hide:
	mActS_SetBlankFrame
	ret
	
; =============== Act_LampSmoke_InitMove ===============
; Mode $01: Initializer for mode $02.
Act_LampSmoke_InitMove:
	ld   a, LAMPSMOKE_RTN_MOVE
	ld   [sActLampSmokeRoutineId], a
	xor  a
	ld   [sActSetTimer2], a
	ret
; =============== Act_LampSmoke_Move ===============
; Mode $02: Move the smoke up at 0.125px/frame.
Act_LampSmoke_Move:
	;--
	; Make the smoke visible.
	; Could have been placed in Act_LampSmoke_InitMove...
	ld   a, LOW(OBJLstPtrTable_Act_LampSmoke)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_LampSmoke)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	;--
	
	; Animate every $10 frames
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .incTimer
	ld   a, [sActSetOBJLstId]	; AnimFrame++
	inc  a
	ld   [sActSetOBJLstId], a
	
.incTimer:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Move up the smoke every $08 frames
	and  a, $07
	ret  nz
	ld   bc, -$01				
	call ActS_MoveDown
	
	; [BUG] Timer#2 never manages to get > $40 before it gets hidden again by Act_SyrupCastleBoss_Intro_LoadGenie.
	;       This means the actor doesn't get despawned, which wastes time.
	ld   a, [sActSetTimer2]		; Timer2++
	inc  a
	ld   [sActSetTimer2], a		
IF FIX_BUGS == 1	
	cp   a, $10					; Timer2 > $40?
ELSE
	cp   a, $40					; Timer2 > $40?
ENDC
	ret  c
	; [TCRF] We never get here.
	ld   a, LAMPSMOKE_RTN_HIDE2			; Not needed
	ld   [sActLampSmokeRoutineId], a
	xor  a								; Delete from level
	ld   [sActSetActive], a
	ret

; =============== Act_Lamp_SpawnCloudPlatform ===============
; Spawns the cloud platforms which then become mini-genies.
Act_Lamp_SpawnCloudPlatform:

	;
	; Check all slots to prevent more than 2 clouds from being active at once.
	;
	ld   hl, sAct		; HL = Actor slot area
	ld   d, $07			; D = Total slots
	ld   e, $00			; E = Number of clouds
.chkActId:
	ld   a, l				; Move to the actor id location			
	add  sActSetId-sActSet
	ld   l, a
	
	; If it isn't a cloud platform, we can skip ahead (don't add to the counter)
	ld   a, [hl]			; Read it
	cp   a, $04				; Is this a cloud platform?
	jr   nz, .chkSlotEnd	; If so, skip this
	
	;####
.chkActive:
	ld   a, l			; Seek back to slot status				
	sub  a, sActSetId-sActSet
	ld   l, a
	
	; If the slot is free, don't add to the counter either
	ld   a, [hl]		; Read active status
	or   a				; Is the slot empty?
	jr   z, .reseekId	; If so, jump (stay on the same slot)
.addToCount:
	inc  e				; CloudCount++
.reseekId:
	ld   a, l			; Move back to the actor id location		
	add  sActSetId-sActSet
	ld   l, a
	;####
	
	; Exit out if we're finished checking the slots
.chkSlotEnd:;R
	dec  d					; Have we checked all slots?
	jr   z, .actCheckEnd	; If so, check the results
	
	; Otherwise, move to the next slot
	ld   a, l			; Seek ahead of what's missing
	add  (sActSet_End-sActSet-(sActSetId-sActSet))
	ld   l, a
	jr   .chkActId
	
.actCheckEnd:
	ld   a, e			; A = Number of clouds
	cp   a, $02			; CloudCount >= 2?
	ret  nc				; If so, don't spawn any further
	
	;
	; Now that we validated the number of spawned clouds/genies,
	; find a free slot.
	;
.getFreeSlot:
	ld   hl, sAct		; HL = Actor slot area
	ld   d, $07			; D = Total slots
	ld   e, $00			; E = Current slot6
.checkSlot:
	ld   a, [hl]		; Read active status
	or   a				; Is the slot marked as active?
	jr   z, .slotFound	; If not, we found a slot
.nextSlot:
	inc  e				; Slot++
	dec  d				; Have we searched in all 7 slots?
	ret  z				; If so, return
	ld   a, l			; Move to next slot (HL += $20)
	add  (sActSet_End-sActSet)
	ld   l, a
	jr   .checkSlot
	
.slotFound:
	mActS_SetOBJBank OBJLstPtrTable_Act_MiniGenie_Cloud
	
	ld   a, $02					; Enabled
	ldi  [hl], a
	ld   a, [sActSetX_Low]		; X = sActSetX - $10
	sub  a, $10
	ldi  [hl], a
	ld   a, [sActSetX_High]
	sbc  a, $00
	ldi  [hl], a
	ld   a, [sActSetY_Low]		; Y = sActSetX - $10
	sub  a, $10
	ldi  [hl], a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ldi  [hl], a
	
	ld   a, ACTCOLI_TOPSOLID	; Collision type
	ldi  [hl], a
	ld   a, -$0C				; Coli box U
	ldi  [hl], a
	ld   a, -$04				; Coli box D
	ldi  [hl], a
	ld   a, -$10				; Coli box L
	ldi  [hl], a
	ld   a, +$00				; Coli box R
	ldi  [hl], a
	
	ld   a, $00
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_MiniGenie_Cloud)		; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_MiniGenie_Cloud)
	ldi  [hl], a
	
	ld   a, [sActSetDir]		; Dir
	ldi  [hl], a
	xor  a						; OBJLst ID
	ldi  [hl], a
	ld   a, $04					; Actor ID -- hardcoded
	ldi  [hl], a				
	xor  a						; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_MiniGenie)		; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_MiniGenie)
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
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_MiniGenie)		; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_MiniGenie)
	ldi  [hl], a
	ret
	
; =============== ActInit_Unused_MiniGenie ===============
; [TCRF] This actor is spawned directly by another actor, without going through here.
;        If it were part of the actor layout, this code would be used.
ActInit_Unused_MiniGenie: 
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_MiniGenie
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_MiniGenie_Cloud
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_MiniGenie
	call ActS_SetOBJLstSharedTablePtr
	
	; Set collision
	ld   a, ACTCOLI_TOPSOLID
	ld   [sActSetColiType], a
	
	; Clear custom
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSetTimer2], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer6], a
	ld   [sActSetTimer7], a
	ret

; =============== Act_MiniGenie ===============
Act_MiniGenie:
	; When the boss dies, kill all mini-genies/clouds.
	ld   a, [sActSyrupCastleBossDead]
	or   a
	jp   nz, SubCall_ActS_StartJumpDead
	
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_MiniGenie_RiseUp			
	dw Act_MiniGenie_Blink
	dw Act_MiniGenie_FallDown
	dw Act_MiniGenie_Genie
	
; =============== Act_MiniGenie_RiseUp ===============
; Mode $00: Cloud rises up.
Act_MiniGenie_RiseUp:
	call ActS_IncOBJLstIdEvery8
	
	; Use cloud anim
	ld   a, LOW(OBJLstPtrTable_Act_MiniGenie_Cloud)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_MiniGenie_Cloud)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Rise up 0.25px/frame
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   bc, -$01
	call ActS_MoveDown
	
	; If the player is standing on the cloud, move him up as well
	ld   a, [sActSetRoutineId]
	and  a, $0F						; Filter away interaction direction
	cp   a, ACTRTN_06				; Standing on top?
	ld   b, $01
	call z, SubCall_PlBGColi_DoTopAndMove	; If so, call
	
	; When reaching
	ld   a, [sActSetRelY]
	cp   a, $38						; Y < $38?
	jr   c, Act_MiniGenie_SwitchToBlink					; If so, start blinking
	ret
	
Act_MiniGenie_SwitchToBlink:
	ld   a, CPTSMINI_RTN_BLINK		; Set new mode
	ld   [sActLocalRoutineId], a
	mActOBJLstPtrTable OBJLstPtrTable_Act_MiniGenie_CloudBlink ; Set blink anim
	xor  a							; Init timer
	ld   [sActMiniGenieBlinkTimer], a
	ld   [sActSetColiType], a		; Make intangible
	ret
	
; =============== Act_MiniGenie_Blink ===============
; Mode $01: Cloud blinks.
Act_MiniGenie_Blink:
	; Blink (animate) every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .wait
	ld   a, [sActSetOBJLstId]	; AnimFrame++
	inc  a
	ld   [sActSetOBJLstId], a
	
.wait:
	; Wait for $3C frames...
	ld   a, [sActMiniGenieBlinkTimer]	; Timer++
	inc  a
	ld   [sActMiniGenieBlinkTimer], a
	cp   a, $3C								; Timer < $3C?
	ret  c									; If so, return
	
.nextMode:
	mActOBJLstPtrTable OBJLstPtrTable_Act_MiniGenie_MoveV
	ld   a, CPTSMINI_RTN_FALLDOWN			; Next mode
	ld   [sActLocalRoutineId], a
	mActSetYSpeed -$03
	ret
	
; =============== Act_MiniGenie_Blink ===============
; Mode $02: The cloud becomes a falling mini-genie.
Act_MiniGenie_FallDown:
	mActOBJLstPtrTable OBJLstPtrTable_Act_MiniGenie_MoveV
	
	; Drop down until reaching Y $70
	ld   a, [sActSetRelY]
	cp   a, $70
	jr   nc, .nextMode
	call ActS_FallDownMax4Speed
	ret
.nextMode:
	
	ld   a, CPTSMINI_RTN_MAIN
	ld   [sActLocalRoutineId], a
	xor  a								; Reset speed
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_MiniGenie_MoveH
	
	; The genie now becomes tangible
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	ret
	
; =============== Act_MiniGenie_Genie ===============
; Mode $03: Main mode.
Act_MiniGenie_Genie:
	mActOBJLstPtrTable OBJLstPtrTable_Act_MiniGenie_MoveH
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_MiniGenie_Genie_Main
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartStarKill
	dw Act_MiniGenie_Genie_Main
	dw SubCall_ActS_StartDashKill
	dw Act_MiniGenie_Genie_Main;X
	dw Act_MiniGenie_Genie_Main;X
	dw SubCall_ActS_StartJumpDead
	
; =============== Act_MiniGenie_Genie_Main ===============
Act_MiniGenie_Genie_Main:
	; Handle horizontal movement (of 1px/frame)
	call Act_MiniGenie_ChkMoveRight
	
	; Every $20 frames spawn a projectile
	ld   a, [sActSetTimer]
	and  a, $1F
	call z, Act_MiniGenie_SpawnProjectile
	ret
	
; =============== Act_MiniGenie_Genie_Main ===============
Act_MiniGenie_ChkMoveRight:
	ld   a, [sActSetDir]
	bit  DIRB_L, a						; Moving actually left?
	jr   nz, Act_MiniGenie_ChkMoveLeft	; If so, jump there
	
	; Try to move right
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block on the right?
	jr   nz, Act_MiniGenie_Turn			; If so, turn left
	ld   bc, +$01
	call ActS_MoveRight
	ret
	
; =============== Act_MiniGenie_ChkMoveLeft ===============
Act_MiniGenie_ChkMoveLeft:
	; Try to move left
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block on the left?
	jr   nz, Act_MiniGenie_Turn			; If so, turn right
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
; =============== Act_MiniGenie_Turn ===============
Act_MiniGenie_Turn:
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ret
	
; =============== OBJLstSharedPtrTable_Act_MiniGenie ===============
OBJLstSharedPtrTable_Act_MiniGenie:
	dw OBJLstPtrTable_Act_MiniGenie_Stun;X
	dw OBJLstPtrTable_Act_MiniGenie_Stun;X
	dw OBJLstPtrTable_Act_MiniGenie_Stun;X
	dw OBJLstPtrTable_Act_MiniGenie_Stun;X
	dw OBJLstPtrTable_Act_MiniGenie_Stun
	dw OBJLstPtrTable_Act_MiniGenie_Stun
	dw OBJLstPtrTable_Act_MiniGenie_Stun;X
	dw OBJLstPtrTable_Act_MiniGenie_Stun;X

OBJLstPtrTable_Act_MiniGenie_Cloud:
	dw OBJLst_Act_MiniGenie_Cloud0
	dw OBJLst_Act_MiniGenie_Cloud1
	dw $0000
OBJLstPtrTable_Act_MiniGenie_CloudBlink:
	dw OBJLst_Act_MiniGenie_Cloud0
	dw OBJLst_Act_None
	dw $0000
OBJLstPtrTable_Act_MiniGenie_MoveV:
	dw OBJLst_Act_MiniGenie_MoveV
	dw $0000;X
OBJLstPtrTable_Act_MiniGenie_MoveH:
	dw OBJLst_Act_MiniGenie_MoveH
	dw $0000;X
OBJLstPtrTable_Act_MiniGenie_Stun:
	dw OBJLst_Act_MiniGenie_Stun
	dw $0000
; [TCRF] Unused upside-down variant of the stun animation.
OBJLstPtrTable_Act_MiniGenie_Unused_StunAlt:
	dw OBJLst_Act_MiniGenie_Unused_StunAlt;X
	dw $0000;X
OBJLstPtrTable_Act_MiniGenieProjectile:
	dw OBJLst_Act_MiniGenieProjectile
	dw $0000;X


; =============== Act_MiniGenie_SpawnProjectile ===============
Act_MiniGenie_SpawnProjectile:
	; Find an empty slot
	ld   hl, sAct		; HL = Actor slot area
	ld   d, $07			; D = Total slots
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
	mActS_SetOBJBank .slotFound
	
	ld   a, $02				; Enabled
	ldi  [hl], a
	ld   a, [sActSetX_Low]	; X = sActSetX
	ldi  [hl], a
	ld   a, [sActSetX_High]
	ldi  [hl], a
	ld   a, [sActSetY_Low]	; Y = sActSetX
	ldi  [hl], a
	ld   a, [sActSetY_High]
	ldi  [hl], a
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ldi  [hl], a
	
	ld   a, -$08			; Coli box U
	ldi  [hl], a
	ld   a, -$02			; Coli box D
	ldi  [hl], a
	ld   a, -$01			; Coli box L
	ldi  [hl], a
	ld   a, +$01			; Coli box R
	ldi  [hl], a
	
	ld   a, $00
	ldi  [hl], a			; Rel.Y (Origin)
	ldi  [hl], a			; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_MiniGenieProjectile)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_MiniGenieProjectile)
	ldi  [hl], a
	
	ld   a, [sActSetDir]	; Dir
	ldi  [hl], a
	xor  a					; OBJLst ID
	ldi  [hl], a
	ld   a, [sActSetId]		; Actor ID -- same as mini-genie
	ldi  [hl], a
	xor  a					; Routine ID
	ldi  [hl], a
	ld   a, LOW(SubCall_Act_MiniGenieProjectile)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_MiniGenieProjectile)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a			; Timer
	ldi  [hl], a			; Timer 2
	ldi  [hl], a			; Timer 3
	ldi  [hl], a			; Timer 4
	ldi  [hl], a			; Timer 5
	ldi  [hl], a			; Timer 6
	ldi  [hl], a			; Timer 7
	
	ld   a, $01				; Flags
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_MiniGenie)		; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_MiniGenie)
	ldi  [hl], a
	
	ld   a, SFX4_13
	ld   [sSFX4Set], a
	ret
; =============== ActInit_SyrupCastleBoss ===============
Act_MiniGenieProjectile:
	; Set frame for projectile (not needed)
	mActOBJLstPtrTable OBJLstPtrTable_Act_MiniGenieProjectile
	
	; Move down 4px/frame until reaching solid ground
	ld   bc, +$04
	call ActS_MoveDown
	call ActColi_GetBlockId_Ground		
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Touching the ground?
	ret  z								; If not, return
	
	; Kill self with star effect
	jp   SubCall_ActS_StartStarKill_NoHeart
	
; =============== ActInit_SyrupCastleBoss ===============
; The actor for the final boss.
; The code for this runs both during gameplay and ending modes.
ActInit_SyrupCastleBoss:
	; If the Genie was defeated already, start the ending sequence (post-boss).
	; This can only happen when the actor is called from the ending mode
	; and not during gameplay.
	ld   a, [sActSyrupCastleBossDead]
	or   a
	jr   nz, ActInit_SyrupCastleBoss_Ending
	;--
	
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$28
	ld   [sActSetColiBoxL], a
	ld   a, -$10
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_SyrupCastleBoss
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActS_SetBlankFrame
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_SyrupCastleBoss
	call ActS_SetOBJLstSharedTablePtr
	
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActSyrupCastleBossModeIncTimer], a
	ld   [sActSyrupCastleBossSubRoutineId], a
	ld   [sActSetTimer], a
	ld   [sActSyrupCastleBossYPathIndex], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	ld   [sActSetColiType], a	; Set as intangible
	mSubCall ActS_SaveColiType ; BANK $02
	
	ld   a, DIR_L				; Face the player
	ld   [sActSetDir], a
	ld   bc, BLOCK_HEIGHT/2		; Move at the center of the block
	call ActS_MoveRight
	
	; Freeze player indefinitely
	; A few routines always reset the freeze timer as the first thing, making sure
	; the player doesn't escape.
	ld   a, $FF					
	ld   [sPlFreezeTimer], a
	xor  a
	ld   [sActSyrupCastleBossHitCount], a
	ld   [sActSyrupCastleBoss_Unused_A3C9], a
	ld   [sActLampEndingOk], a
	xor  a
	ld   [sActBossParallaxFlashTimer], a
	ld   [sActSyrupCastleBossBlankBG], a
	ret
	
; =============== ActInit_SyrupCastleBoss_Ending ===============
; Sets up the initial part for the ending, inside the boss room.
ActInit_SyrupCastleBoss_Ending:
	; Setup main code
	ld   bc, SubCall_Act_SyrupCastleBoss
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActS_SetBlankFrame
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_SyrupCastleBoss
	call ActS_SetOBJLstSharedTablePtr
	
	ld   a, CPTS_RTN_ENDING_10
	ld   [sActLocalRoutineId], a
	
	xor  a
	ld   [sActSyrupCastleBossModeIncTimer], a
	ld   [sActSyrupCastleBossSubRoutineId], a
	ld   [sActSetTimer], a
	ld   [sActSyrupCastleBossYPathIndex], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ld   [sActSetRoutineId], a
	ld   [sActSetColiType], a
	
	; Restore actor's coords from before the actor's jump
	ld   a, [sActSyrupCastleBossXBak_Low]
	ld   [sActSetX_Low], a
	ld   a, [sActSyrupCastleBossXBak_High]
	ld   [sActSetX_High], a
	ld   a, [sActSyrupCastleBossYBak_Low]
	ld   [sActSetY_Low], a
	ld   a, [sActSyrupCastleBossYBak_High]
	ld   [sActSetY_High], a
	ld   a, $FF						; Freeze player long enough
	ld   [sPlFreezeTimer], a
	ld   a, BGM_FINALBOSSOUTRO
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	ret
	
; =============== Act_SyrupCastleBoss_DoHitShake ===============
; This subroutine performs the boss flash after an hit...
; ...which for this boss, isn't actually an hit flash, but an horizontal shake effect.
;
; The code itself is almost identical to the other foreground-based bosses,
; with the exception being instead of moving the boss off-screen every 2 alt. frames,
; it offsets it by 8 px.
Act_SyrupCastleBoss_DoHitShake:
	ld   a, [sActBossParallaxFlashTimer]
	dec  a						; Count--
	ld   [sActBossParallaxFlashTimer], a
	cp   a, $02					; Is it < $02?
	jr   c, .copyNorm			; If so, copy the parallax value directly
	
	; Shake the boss by shifting the parallax sections by 8px,
	; alternating every 2 frames (instead of 1, to account for updating parallax modes mid-frame).
	ld   a, [sActSetTimer]
	bit  1, a
	jr   z, .copyNorm
.copyShifted:
	ld   a, [sActBossParallaxX]
	add  $08
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
	ret
	
; =============== Act_SyrupCastleBoss_DoBlank ===============
; This subroutine performs blanks the parallax sections for the Genie.
; [TCRF] The only place this is used is completely pointless, since the Genie isn't visible anyway.
Act_SyrupCastleBoss_DoBlank:
	; Move parallax section off-screen, which replaces the visible area with blank tiles.
	ld   a, $E0
	ld   [sParallaxX0], a
	ld   [sParallaxX1], a
	ld   [sParallaxX2], a
	ret
	
; =============== Act_SyrupCastleBoss ===============
Act_SyrupCastleBoss:
	ld   a, [sActSetTimer]	; Timer
	inc  a
	ld   [sActSetTimer], a
	
	; Handle the parallax boss screen shake effect
	ld   a, [sActBossParallaxFlashTimer]
	or   a
	call nz, Act_SyrupCastleBoss_DoHitShake
	; And the BG disable toggle (after defeating the boss)
	ld   a, [sActSyrupCastleBossBlankBG]
	or   a
	call nz, Act_SyrupCastleBoss_DoBlank
	
	; There's a lot to this boss
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_SyrupCastleBoss_Intro_Lay
	dw Act_SyrupCastleBoss_Intro_Stand
	dw Act_SyrupCastleBoss_Intro_MoveDown
	dw Act_SyrupCastleBoss_Intro_LampTouch
	dw Act_SyrupCastleBoss_Intro_Stand
	dw Act_SyrupCastleBoss_Intro_LampTouch2
	dw Act_SyrupCastleBoss_Intro_LampFlash
	dw Act_SyrupCastleBoss_Intro_ShowSmoke
	dw Act_SyrupCastleBoss_Intro_LoadGenie
	dw Act_SyrupCastleBoss_Intro_MoveGenieDown
	dw Act_SyrupCastleBoss_Intro_JumpToGenie
	dw Act_SyrupCastleBoss_Intro_MoveGenieUp
	dw Act_SyrupCastleBoss_Intro_MoveBossUp
	dw Act_SyrupCastleBoss_Intro_LayOnGenie
	dw Act_SyrupCastleBoss_Game
	dw Act_SyrupCastleBoss_Dead
	dw Act_SyrupCastleBoss_Ending_Angry
	dw Act_SyrupCastleBoss_Ending_Stand
	dw Act_SyrupCastleBoss_Ending_Jump
	dw Act_SyrupCastleBoss_Ending_ThrowBomb
	dw Act_SyrupCastleBoss_Ending_WaitBomb
	dw Act_SyrupCastleBoss_Ending_ExitToMap
	dw Act_SyrupCastleBoss_WaitReload
	dw .unused_none;X
	
; [TCRF] Dummy routine at the end of the table.
.unused_none:
	ret
; =============== COMMON HELPER SUBROUTINES ===============

; =============== Act_SyrupCastleBoss_WaitIncMode ===============
; This subroutine waits for the "Mode Inc Timer" to reach the specified target
; before switching to the next mode.
; Every time this subroutine is called the timer increases, so it
; can be used to define the length of a mode.
; IN
; - D: Timer target
Act_SyrupCastleBoss_WaitIncMode:
	ld   a, [sActSyrupCastleBossModeIncTimer]	; A = CurTimer
	cp   a, d								; D = Target
	; If the timer reached (>=) the target, switch to the next mode
	jr   nc, Act_SyrupCastleBoss_IncMode
	inc  a									; Otherwise, Timer++
	ld   [sActSyrupCastleBossModeIncTimer], a
	ret
	
; =============== Act_SyrupCastleBoss_IncMode ===============
; This subroutine increases the mode/localRoutine id.
; Most of the time Act_SyrupCastleBoss_WaitIncMode is called instead of calling this directly.
Act_SyrupCastleBoss_IncMode:
	ld   a, [sActLocalRoutineId]			; RoutineId++
	inc  a
	ld   [sActLocalRoutineId], a
	xor  a									; Reset the timer for the next Act_SyrupCastleBoss_WaitIncMode call
	ld   [sActSyrupCastleBossModeIncTimer], a
	ret
	
; =============== Act_SyrupCastleBoss_Intro_Lay ===============
; Intro (1), when initially spawned.
Act_SyrupCastleBoss_Intro_Lay:
	call ActS_IncOBJLstIdEvery8
	;--
	; Set the OBJLst info for the first frame.
	; For the rest, keep waiting for $78 frames before switching.
	; NOTE: Other modes also follow this template.
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	jr   nc, .wait
	;--
	; Set bed lay anim
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_Lay)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_Lay)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a										; Clear anim counter
	ld   [sActSetOBJLstId], a
.wait:
	ld   d, $78
	call Act_SyrupCastleBoss_WaitIncMode
	ret
	
; =============== Act_SyrupCastleBoss_Intro_Stand ===============
; Intro (2) - Stand up
Act_SyrupCastleBoss_Intro_Stand:
	ld   a, $FF
	ld   [sPlFreezeTimer], a
	;--
	call ActS_IncOBJLstIdEvery8
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	jr   nc, .wait
	;--
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_Stand)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_Stand)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
.wait:
	ld   d, $1E
	call Act_SyrupCastleBoss_WaitIncMode
	ret
	
; =============== Act_SyrupCastleBoss_Intro_MoveDown ===============
; Intro (3) - Move down $1E times
Act_SyrupCastleBoss_Intro_MoveDown:
	ld   a, $FF
	ld   [sPlFreezeTimer], a
	call ActS_IncOBJLstIdEvery8
	;--
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	jr   nc, .wait
	;--
	; [POI] Not necessary, the last mode set this already
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_Stand)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_Stand)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
.wait:
	ld   d, $1E
	call Act_SyrupCastleBoss_WaitIncMode
	ld   bc, $01
	call ActS_MoveDown
	ret
	
; =============== Act_SyrupCastleBoss_Intro_LampTouch ===============
; Intro (4) - Lamp touch 1
Act_SyrupCastleBoss_Intro_LampTouch:
	; Animate every $10 frames
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .setAnim
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.setAnim:
	;--
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	jr   nc, .waitMode
	;--
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_StandRub)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_StandRub)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
.waitMode:
	ld   d, $50
	call Act_SyrupCastleBoss_WaitIncMode
	
	; Save the current position for later.
	; After the final boss is defated, the will respawn using these coords
	; when the room reloads.
	ld   a, [sActSetX_Low]
	ld   [sActSyrupCastleBossXBak_Low], a
	ld   a, [sActSetX_High]
	ld   [sActSyrupCastleBossXBak_High], a
	ld   a, [sActSetY_Low]
	ld   [sActSyrupCastleBossYBak_Low], a
	ld   a, [sActSetY_High]
	ld   [sActSyrupCastleBossYBak_High], a
	ret
	
	
; =============== Act_SyrupCastleBoss_Intro_LampTouch2 ===============
; Intro (5) - Lamp touch 2
Act_SyrupCastleBoss_Intro_LampTouch2:
	ld   a, $FF
	ld   [sPlFreezeTimer], a
	
	call ActS_IncOBJLstIdEvery8
	;--
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	jr   nc, .wait
	;--
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_DuckRub)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_DuckRub)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
.wait:
	ld   d, $50
	call Act_SyrupCastleBoss_WaitIncMode
	
	; Play SFX whenever the lamp is touched (frame $01)
	ld   a, [sActSetOBJLstId]
	cp   a, $01
	ret  nz
	ld   a, SFX1_11
	ld   [sSFX1Set], a
	ret
	
; =============== Act_SyrupCastleBoss_Intro_LampFlash ===============
; Intro (6) - Lamp flash
Act_SyrupCastleBoss_Intro_LampFlash:
	call ActS_IncOBJLstIdEvery8
	;--
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	jr   nc, .wait
	;--
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_Stand)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_Stand)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
.wait:
	ld   d, $3C
	call Act_SyrupCastleBoss_WaitIncMode
	; Make the lamp flash if it isn't already
	ld   a, [sActLampRoutineId]
	or   a
	ret  nz
	ld   a, LAMP_RTN_INITFLASH
	ld   [sActLampRoutineId], a
	ret
	
; =============== Act_SyrupCastleBoss_Intro_ShowSmoke ===============
; Intro (7) - Display smoke
Act_SyrupCastleBoss_Intro_ShowSmoke:
	call ActS_IncOBJLstIdEvery8
	ld   d, $78
	call Act_SyrupCastleBoss_WaitIncMode
	;--
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	jr   nc, .chkSmoke
	;--
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_StandOpen)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_StandOpen)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
.chkSmoke:
	; If the smoke isn't coming out of the lamp yet, make it.
	ld   a, [sActLampSmokeRoutineId]
	or   a
	ret  nz
	ld   a, LAMPSMOKE_RTN_INITMOVE
	ld   [sActLampSmokeRoutineId], a
	ld   a, SFX1_01
	ld   [sSFX1Set], a
	ret
	
; =============== Act_SyrupCastleBoss_Intro_LoadGenie ===============
; Intro (8) - Screen wave effect and genie GFX load.
Act_SyrupCastleBoss_Intro_LoadGenie:
	ld   a, $B4
	ld   [sPlFreezeTimer], a
IF FIX_BUGS == 0
	ld   a, LAMPSMOKE_RTN_HIDE
	ld   [sActLampSmokeRoutineId], a
ENDC
	; This is the only real point this lamp mode is used.
	; It could have been avoided by placing the lamp aligned to solid ground.
	; [BUG] This also causes the lamp to tilt for 2 frames, though it's barely visible.
IF FIX_BUGS == 1
	ld   a, LAMP_RTN_INITMAIN
ELSE
	ld   a, LAMP_RTN_FALL
ENDC
	ld   [sActLampRoutineId], a
	
	; Load the VRAM and the main body (while the wavy effect happens)
	call Act_SyrupCastleBoss_LoadVRAMGenieAndSetParallax
	call Act_SyrupCastleBoss_IncMode
	; Then put the correct details
	call Act_SyrupCastleBoss_BGWrite_GenieHandOpenL
	call Act_SyrupCastleBoss_BGWrite_GenieHandOpenR
	call Act_SyrupCastleBoss_BGWrite_GenieFootUpL
	call Act_SyrupCastleBoss_BGWrite_GenieFootUpR
	
	; Wait for boss music
	ld   a, BGM_FINALBOSS
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	ret
	
; =============== Act_SyrupCastleBoss_Intro_MoveGenieDown ===============
; Intro (9) - Move boss down.
Act_SyrupCastleBoss_Intro_MoveGenieDown:
	; Every 4 frames
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	;--
	; $20 times...
	ld   d, $20
	call Act_SyrupCastleBoss_WaitIncMode
	;--
	; ...move the boss down at 1px/frame
	ld   c, $01
	call Act_SyrupCastleBoss_MoveGenieDown
	ret
	
; =============== Act_SyrupCastleBoss_Intro_JumpToGenie ===============
; Intro (10) - Captain Syrup jumps to the Genie
Act_SyrupCastleBoss_Intro_JumpToGenie:
	; Skip the init code if already run
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02								; 2 frames passed?
	jr   nc, .doJumpAnim					; If so, skip
.setJumpAnim:
	;--
	; Setup jump anim
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_JumpFrontL)					
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_JumpFrontL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
.doJumpAnim:
	ld   d, $34
	call Act_SyrupCastleBoss_WaitIncMode
	;--
	; Make Cpt Syrup jump to the left
	ld   bc, -$01			; 1px/frame up
	call ActS_MoveDown
	
	ld   a, [sActSetTimer]	; 0.5px/frame left
	and  a, $01
	ret  nz
	ld   bc, -$01			
	call ActS_MoveRight
	ret
	
; =============== Act_SyrupCastleBoss_Intro_MoveGenieUp ===============
; Intro (11) - The Genie moves up again -- the jump finishes.
Act_SyrupCastleBoss_Intro_MoveGenieUp:
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	jr   nc, .move
.setObjLst:
	; Set sprite for standing on the genie
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_Syrup_StandOpen_Copy)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_Syrup_StandOpen_Copy)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a							; Reset anim
	ld   [sActSetOBJLstId], a
.move:
	ld   d, $28
	call Act_SyrupCastleBoss_WaitIncMode

	; Do only for the first frame
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $01
	ret  nz
.bgInit:
	call Act_SyrupCastleBoss_BGWrite_GenieHandClosedL	; Close both arms
	call Act_SyrupCastleBoss_BGWrite_GenieHandClosedR
	ld   bc, +$03										; Fix to cpt. syrup to the genie's top right
	call ActS_MoveRight
	ld   bc, -$09
	call ActS_MoveDown
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownR
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownL
	ret
	
; =============== Act_SyrupCastleBoss_Intro_MoveBossUp ===============
; Intro (12) - Move the boss (actor+genie) up $23*$02 times.
Act_SyrupCastleBoss_Intro_MoveBossUp:
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	;--
	ld   d, $23
	call Act_SyrupCastleBoss_WaitIncMode
	;--
	ld   c, -$01
	call Act_SyrupCastleBoss_MoveGenieDown
	ld   bc, -$01
	call ActS_MoveDown
	ret
; =============== Act_SyrupCastleBoss_Intro_LayOnGenie ===============
; Intro (13) - Sets Cpt Syrup's on-genie animation.
Act_SyrupCastleBoss_Intro_LayOnGenie:
	; Handle animations
	call ActS_IncOBJLstIdEvery8
	
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02									; Are we on frame 2+?
	jr   nc, .wait								; If so, skip the anim init code
.setAnim:
	; The "on-genie" sprites are basically the upper half of the standing sprites.
	; They have less data, so it's convenient to use them to save time.
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_OnGenieArmWave)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_OnGenieArmWave)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
.wait:
	ld   d, $1E
	call Act_SyrupCastleBoss_WaitIncMode
	ret
	
; =============== Act_SyrupCastleBoss_Ending_Angry ===============
; Ending (1) - Captain Syrup after defeating the final boss.
; Set after the room loads back.
Act_SyrupCastleBoss_Ending_Angry:
	call ActS_IncOBJLstIdEvery8
	
	; From the second frame...
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	jr   nc, .wait
.setAnim:
	; Set initial anim
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_Dead)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_Dead)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
.wait:
	;--
	ld   d, $D2
	call Act_SyrupCastleBoss_WaitIncMode
	;--
	; Keep the player from moving
	ld   a, $FF
	ld   [sPlFreezeTimer], a
	;--
	; [POI] Was something commented out?
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	ret  nz
	;--
	ret
; =============== Act_SyrupCastleBoss_Ending_Stand ===============
; Ending (2) - Makes Cpt Syrup stand.
Act_SyrupCastleBoss_Ending_Stand:
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	jr   nc, .wait
.setAnim:
	; Set the stand anim
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_Stand)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_Stand)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
.wait:
	ld   d, $3C
	call Act_SyrupCastleBoss_WaitIncMode
	;--
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	ret  nz
	ld   a, BGM_NONE
	ld   [sSFX1Set], a
	; Setup the Y speed for the next mode
	mActSetYSpeed -$05
	ret
	
; =============== Act_SyrupCastleBoss_Ending_Jump ===============
; Ending (3) - Cpt Syrup jumps to the right, off-screen.
Act_SyrupCastleBoss_Ending_Jump:
	call ActS_IncOBJLstIdEvery8
	
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02								; Frame >= $02? (not first run)
	jr   nc, .move							; If so, skip
.setAnim:
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_JumpSideR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_JumpSideR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
.move:
	ld   d, $32
	call Act_SyrupCastleBoss_WaitIncMode
	
	; Handle horz/vert movement
	ld   bc, +$01							; Move 1px/frame right
	call ActS_MoveRight
	call ActS_FallDownMax4Speed				; Handle gradual fall speed
	
	; Fade out the boss outro
	ld   a, BGMACT_FADEOUT					
	ld   [sBGMActSet], a
	ld   [sHurryUpBGM], a ; ?
	
	; On frame $30, set the initial position of the bomb.
	; The bomb is the same actor (except with a different OBJLst),
	; so it uses the same memory addresses for its X/Y info.
	
	; NOTE: This is triggered at frame $30, but this mode executes until frame $32.
	;       During frame $31 the normal ActS_FallDownMax4Speed code executes,
	;       but it doesn't really matter.
	ld   a, [sActSyrupCastleBossModeIncTimer]	
	cp   a, $30
	ret  nz
	mActSetYSpeed -$06						; Make bomb jump up
	ld   bc, -$20							; Start 2 blocks above the current pos
	call ActS_MoveDown
	ret
	
; =============== Act_SyrupCastleBoss_Ending_ThrowBomb ===============
; Ending (4) - Bomb jumps to the left, then slides.
Act_SyrupCastleBoss_Ending_ThrowBomb:
	call ActS_IncOBJLstIdEvery8
	
	; Skip .setanim from the second frame
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	jr   nc, .move
.setAnim:
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_Bomb)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_Bomb)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
	
.move:
	ld   d, $4B
	call Act_SyrupCastleBoss_WaitIncMode
	;--
	; Move the bomb
	ld   bc, -$01
	call ActS_MoveRight
	call ActS_FallDownMax4SpeedChkSolid
	
	; On the second frame...
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	ret  nz
	ld   a, SFX1_29		; Set bomb throw SFX
	ld   [sSFX1Set], a
	ld   a, $FF					; Renew the freeze status
	ld   [sPlFreezeTimer], a
	ret
	
; =============== Act_SyrupCastleBoss_Ending_WaitBomb ===============
; Ending (5) - Bomb stops and plays ticking SFX.
Act_SyrupCastleBoss_Ending_WaitBomb:
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chk1stRun
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	
.chk1stRun:
	; Set anim only the first time
	ld   a, [sActSyrupCastleBossModeIncTimer]
	cp   a, $02
	jr   nc, .wait
	;--
.setAnim:
	; [POI] Not necessary
	ld   a, LOW(OBJLstPtrTable_Act_SyrupCastleBoss_Bomb)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SyrupCastleBoss_Bomb)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
	
.wait:
	ld   d, $50
	call Act_SyrupCastleBoss_WaitIncMode
	;--
	; Play ticking SFX every 4 frames
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, SFX4_14
	ld   [sSFX4Set], a
	ret
	
; =============== Act_SyrupCastleBoss_Ending_ExitToMap ===============
; Ending (6) - Triggers a fade out to the map screen ending cutscene.
Act_SyrupCastleBoss_Ending_ExitToMap:
	ld   a, BGMACT_FADEOUT
	ld   [sBGMActSet], a
	; Signal to the ending code to start the next part of the ending
	ld   a, LVLCLEAR_FINALEXITTOMAP				
	ld   [sLvlSpecClear], a
	ret
	
; =============== Act_SyrupCastleBoss_Game ===============
; Main mode for the final boss.
Act_SyrupCastleBoss_Game:
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_SyrupCastleBoss_Game_Main
	dw Act_SyrupCastleBoss_Game_Main
	dw Act_SyrupCastleBoss_SwitchToHit
	dw Act_SyrupCastleBoss_Game_Main
	dw Act_SyrupCastleBoss_Game_Main
	dw Act_SyrupCastleBoss_SwitchToHit
	dw Act_SyrupCastleBoss_Game_Main;X
	dw Act_SyrupCastleBoss_Game_Main;X
	dw Act_SyrupCastleBoss_Game_Main
	
; =============== Act_SyrupCastleBoss_SwitchToHit ===============
; Called when the boss is hit.
Act_SyrupCastleBoss_SwitchToHit:
	; Set SFX
	ld   a, SFX1_2C
	ld   [sSFX1Set], a
	; Write all of the BG mappings for the pose
	call Act_SyrupCastleBoss_BGWrite_GenieFaceHit
	call Act_SyrupCastleBoss_BGWrite_GenieHandPointR
	call Act_SyrupCastleBoss_BGWrite_GenieHandPointL
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownR
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownL
	
	ld   a, $64									; Play damage anim for $64 frames
	ld   [sActSyrupCastleBossHitAnimTimer], a
	ld   a, CPTS_SUBRTN_HIT						; Set hit mode
	ld   [sActSyrupCastleBossSubRoutineId], a
	xor  a										; Make invulnerable in hit state
	ld   [sActSetColiType], a
	ld   a, $64
	ld   [sActBossParallaxFlashTimer], a
	ret
	
; =============== Act_SyrupCastleBoss_OnHit ===============
; Handles the hit animation until the timer elapses.
Act_SyrupCastleBoss_OnHit:
	xor  a							; Clear collision always
	ld   [sActSetColiType], a
	
	; Handle the hit anim timer
	ld   a, [sActSyrupCastleBossHitAnimTimer]
	or   a							; Did the timer elapse?
	jr   z, .endHit					; If so, we're done
	dec  a							
	ld   [sActSyrupCastleBossHitAnimTimer], a
	;--
	; Every 8 frames...
	ld   a, [sActSetTimer]
	ld   b, a						; save for check below	
	and  a, $07						; Timer % 7 != 0?
	ret  nz							; If so, return
	
	; ...alternate between foot direction
	bit  3, b						; Check 4th bit (7 takes up the 3 bits)
	jr   z, .footUp
.footDown:
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownR
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownL
	ret
.footUp:
	call Act_SyrupCastleBoss_BGWrite_GenieFootUpR
	call Act_SyrupCastleBoss_BGWrite_GenieFootUpL
	ret
.endHit:
	;--
	; Register a hit to the boss
	ld   a, [sActSyrupCastleBossHitCount]		; HitCount++;
	inc  a
	ld   [sActSyrupCastleBossHitCount], a
	cp   a, $06									; Did we hit the boss 6 times?
	jp   nc, Act_SyrupCastleBoss_SwitchToDead	; If so, we defeated it
	
	; Otherwise, restore the normal Genie tilemaps
	call Act_SyrupCastleBoss_BGWrite_GenieFace
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownR
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownL
	call Act_SyrupCastleBoss_BGWrite_GenieHandClosedR
	call Act_SyrupCastleBoss_BGWrite_GenieHandClosedL
	xor  a										; Return to the main submode
	ld   [sActSyrupCastleBossSubRoutineId], a
	ret
	
; =============== Act_SyrupCastleBoss_Game_Main ===============
Act_SyrupCastleBoss_Game_Main:
	ld   a, [sActSyrupCastleBossSubRoutineId]			; Depending on the sub-routine id
	rst  $28
	dw Act_SyrupCastleBoss_Game_Main_Move
	dw Act_SyrupCastleBoss_Game_Main_WaitFire
	dw Act_SyrupCastleBoss_Game_Main_Fire
	dw Act_SyrupCastleBoss_OnHit
	dw Act_SyrupCastleBoss_Game_Main_Move;X
	dw Act_SyrupCastleBoss_Game_Main_Move;X
	
; =============== Act_SyrupCastleBoss_Game_Main_Move ===============
Act_SyrupCastleBoss_Game_Main_Move:
	mActOBJLstPtrTable OBJLstPtrTable_Act_SyrupCastleBoss_OnGenieStand

.chkYMove:
	;--
	; Move the boss vertically every frame.
	; This uses a path table with Y offsets, indexed by timer#2 (sActSyrupCastleBossYPathIndex)
	
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	jr   nz, .doMove
	
	; ...increase the table index until it reaches $2C (the end of the path table).
	ld   a, [sActSyrupCastleBossYPathIndex]
	inc  a						; I++
	cp   a, (Act_SyrupCastleBoss_YPath.end-Act_SyrupCastleBoss_YPath) ; Reached the end of the table yet?
	jr   c, .resetTimer			; If not, jump
	xor  a						; Otherwise, reset the index
.resetTimer:
	ld   [sActSyrupCastleBossYPathIndex], a
.doMove:
	
	; Fetch the indexed table value...
	ld   a, [sActSyrupCastleBossYPathIndex]	; DE = Index
	ld   d, $00
	ld   e, a
	ld   hl, Act_SyrupCastleBoss_YPath		; HL = PathTable
	add  hl, de								; Index it
	ld   a, [hl]							; C = Y Offset
	ld   c, a
	; ...then send it out directly to the movement subroutines
	call Act_SyrupCastleBoss_MoveGenieDown
	call Act_SyrupCastleBoss_MoveActDown
;--
	
.chkXMove:
	; Move the boss horizontally every other frame.
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Boss is facing right?
	call nz, .chkMoveR		; If so, try moving right
	ld   a, [sActSetDir]
	bit  DIRB_L, a			; Boss is facing left?
	call nz, .chkMoveL		; If so, try moving left
	ret
	
; =============== .chkMoveR ===============
.chkMoveR:
	; Move right 1px unless we're near the right border of the screen
	; (accounting the background scroll)
	ld   a, [sActSetRelX]
	cp   a, $AC				; Boss X >= $AC?
	jr   nc, .turn			; If so, turn left
	ld   c, +$01
	call Act_SyrupCastleBoss_MoveRight
	ret
; =============== .chkMoveL ===============
.chkMoveL:
	; Move left 1px unless we've touched the left border of the screen
	; (accounting the background scroll)
	ld   a, [sActSetRelX]
	cp   a, $28				; Boss X < $28?
	jr   c, .turn			; If so, turn right
	ld   c, -$01
	call Act_SyrupCastleBoss_MoveRight
	ret
; =============== .turn ===============
.turn:
	; Switch direction immediately.
	; This also means that, if we were going left and now turned right,
	; the genie will do the hand anim on the right when calling Act_SyrupCastleBoss_BGWrite_GenieHandOpen.
	ld   a, [sActSetDir]	
	xor  DIR_L|DIR_R
	ld   [sActSetDir], a
	
	ld   a, CPTS_SUBRTN_WAITFIRE	; Switch to the fire/point mode
	ld   [sActSyrupCastleBossSubRoutineId], a
	
	xor  a					
	ld   [sActSyrupCastleBossFireTimer], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_SyrupCastleBoss_OnGenieArmWave	; Set anim
	
	call Act_SyrupCastleBoss_BGWrite_GenieHandOpen
	ret
	
; =============== Act_SyrupCastleBoss_Game_Main_WaitFire ===============
; When the Genie stops moving before firing.
Act_SyrupCastleBoss_Game_Main_WaitFire:
	call ActS_IncOBJLstIdEvery8
	
	;--
	; Wait for $20 frames
	ld   a, [sActSyrupCastleBossFireTimer]	; Timer++
	inc  a
	ld   [sActSyrupCastleBossFireTimer], a
	cp   a, $20								; Timer < $20?
	ret  c									; If so, return
	xor  a									; Reset for the next mode
	ld   [sActSyrupCastleBossFireTimer], a
	;--
	; Switch to the next mode and switch BG tilemaps
	ld   a, CPTS_SUBRTN_FIRE
	ld   [sActSyrupCastleBossSubRoutineId], a
	call Act_SyrupCastleBoss_BGWrite_GenieHandPoint
	mActOBJLstPtrTable OBJLstPtrTable_Act_SyrupCastleBoss_OnGenieStand
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownR
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownL
	ret
; =============== Act_SyrupCastleBoss_Game_Main_Fire ===============
; When the Genie throws fireballs.
Act_SyrupCastleBoss_Game_Main_Fire:
	; Spawn fireballs when the timer hits a certain value
	ld   a, [sActSyrupCastleBossFireTimer]		; Timer++
	inc  a
	ld   [sActSyrupCastleBossFireTimer], a
	cp   a, $24									; Timer == $24?
	call z, Act_SyrupCastleBoss_SpawnFireball	; If so, spawn the first fireball
	ld   a, [sActSyrupCastleBossFireTimer]
	cp   a, $3C									; Timer == $3C?
	call z, Act_SyrupCastleBoss_SpawnFireball	; If so, spawn the second fireball
	ld   a, [sActSyrupCastleBossFireTimer]
	cp   a, $40									; Timer >= $40?
	jr   nc, .end								; If so, start moving again
.doAnim:
	; Switch between Open/Point hand tilemaps every 8 frames.
	
	; Every 8 frames...
	ld   b, a
	and  a, $07				; Timer % 7 == 0?							
	ret  nz					; If so, return
	ld   a, b
	and  a, $08				; (Timer / 8) %2
	jr   nz, .setPointFrame
.setOpenFrame:
	call Act_SyrupCastleBoss_BGWrite_GenieHandOpen
	ret
.setPointFrame:
	call Act_SyrupCastleBoss_BGWrite_GenieHandPoint
	ret
.end:
	xor  a
	ld   [sActSyrupCastleBossFireTimer], a
	ld   a, CPTS_SUBRTN_MOVE
	ld   [sActSyrupCastleBossSubRoutineId], a
	call Act_SyrupCastleBoss_BGWrite_GenieHandClosedR
	call Act_SyrupCastleBoss_BGWrite_GenieHandClosedL
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownR
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownL
	ret
	
; =============== Act_SyrupCastleBoss_BGWrite_GenieHandOpen ===============
Act_SyrupCastleBoss_BGWrite_GenieHandOpen:
	; Set the correct direction depending on the current direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_SyrupCastleBoss_BGWrite_GenieHandOpenR
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_SyrupCastleBoss_BGWrite_GenieHandOpenL
	ret
; =============== Act_SyrupCastleBoss_BGWrite_GenieHandPoint ===============
Act_SyrupCastleBoss_BGWrite_GenieHandPoint:
	; Set the correct direction depending on the current direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_SyrupCastleBoss_BGWrite_GenieHandPointR
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_SyrupCastleBoss_BGWrite_GenieHandPointL
	ret
	
; =============== Act_SyrupCastleBoss_SpawnFireball ===============
Act_SyrupCastleBoss_SpawnFireball:
	call Act_SyrupCastleBoss_BGWrite_GenieFootUpR
	call Act_SyrupCastleBoss_BGWrite_GenieFootUpL
	
	; Find a free slot
	ld   hl, sAct		; HL = Actor slot area
	ld   d, $07			; D = Total slots
	ld   e, $00			; E = Current slot
.checkSlot:;R
	ld   a, [hl]		; Read active status
	or   a				; Is the slot marked as active?
	jr   z, .slotFound	; If not, we found a slot
	inc  e				; Slot++
	dec  d				; Have we searched in all 5 slots?
	ret  z				; If so, return
	ld   a, l			; Move to next slot
	add  LOW(sActSet_End - sActSet)
	ld   l, a
	jr   .checkSlot
.slotFound:
	mActS_SetOBJBank Act_SyrupCastleBossFireball
	
	ld   a, $02			; Enabled
	ldi  [hl], a
	
	; The fireball's starting X pos should be near the Genie's hand.
	; The hand to spawn from changes depending on the Genie's direction.
	
	; Pick a different offset depending on the direction the Genie's facing,
	; relative to the *actor*'s position. 
	; (which is why the two offsets are different -- Cpt Syrup is more on the right)
	ld   bc, -$48			; When facing left
	ld   a, [sActSetDir]
	bit  DIRB_L, a			; Genie facing left?
	jr   nz, .setX			; If so, jump
	ld   bc, +$1C			; When facing right
.setX:
	ld   a, [sActSetX_Low]	; X = sActSetX - XOffset
	add  c
	ldi  [hl], a
	ld   a, [sActSetX_High]
	adc  a, b
	ldi  [hl], a
	
	ld   a, [sActSetY_Low]	; Y = sActSetY + $14
	add  $14
	ldi  [hl], a
	ld   a, [sActSetY_High]
	adc  a, $00
	ldi  [hl], a
	
	; Fireballs are of course deadly to touch
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ldi  [hl], a
	
	ld   a, -$05			; Coli box U
	ldi  [hl], a
	ld   a, -$01			; Coli box D
	ldi  [hl], a
	ld   a, -$08			; Coli box L
	ldi  [hl], a
	ld   a, -$03			; Coli box R
	ldi  [hl], a
	
	ld   a, $00
	ldi  [hl], a			; Rel.Y (Origin)
	ldi  [hl], a			; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_None)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_None)
	ldi  [hl], a
	
	ld   a, [sActSetDir]	; Same jump direction as the boss (is pointing at)
	ldi  [hl], a			
	
	xor  a					; OBJLst ID
	ldi  [hl], a
	
	ld   a, [sActSetId]		; Run under the same Actor ID as the boss
	ldi  [hl], a
	
	xor  a					; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_SyrupCastleBossFireball)	; Code ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_SyrupCastleBossFireball)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a			; Timer
	ldi  [hl], a			; Timer 2
	
	ld   bc, -$03			; Y Speed
	ld   a, c
	ldi  [hl], a			
	ld   a, b
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a			; Timer 5
	ldi  [hl], a			; Timer 6
	ldi  [hl], a			; Timer 7
	
	ld   a, $01				; Flags
	ldi  [hl], a
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_None)	; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_None)
	ldi  [hl], a
	
	ld   a, SFX1_29
	ld   [sSFX1Set], a
	ret
	
; =============== Act_SyrupCastleBossFireball ===============
Act_SyrupCastleBossFireball:
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActLocalRoutineId]
	or   a											; RoutineId != 0?
	jr   nz, Act_SyrupCastleBossFireball_OnGround	; If so, the fireball is sliding on the ground

; =============== Act_SyrupCastleBossFireball_OnAir ===============
Act_SyrupCastleBossFireball_OnAir:
	mActOBJLstPtrTable OBJLstPtrTable_Act_SyrupCastleBossFireball_Air
	
	; Handle horizontal movement
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Facing right?
	call nz, Act_SyrupCastleBossFireball_AirMoveR
	ld   a, [sActSetDir]
	bit  DIRB_L, a			; Facing left?
	call nz, Act_SyrupCastleBossFireball_AirMoveL		
	
	; Handle vertical movement
	call ActS_FallDownMax4Speed
	
	; If we landed on solid ground, switch to the ground mode,
	; where the fireball slides across the ground, towards the player
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block below?
	ret  z								; If not, return
	
.switchToGround:
	; Otherwise, setup the next mode
	ld   a, SFX4_13
	ld   [sSFX4Set], a
	ld   a, CPTSBALL_RTN_GROUND
	ld   [sActLocalRoutineId], a
	
	; Align to block Y grid
	ld   a, [sActSetY_Low]
	and  a, $F0
	ld   [sActSetY_Low], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_SyrupCastleBossFireball_Ground
	
	; Make the fireball move towards the player
	ld   a, DIR_R					; Set default direction
	ld   [sActSetDir], a
	ld   a, [sActSetRelX]			; B = ActX + $20
	add  $20
	ld   b, a
	ld   a, [sPlXRel]				; A = PlX + $20
	add  $20
	cp   a, b						; PlX > ActX? (Player on the right?)
	ret  nc							; If so, return (we set the correct direction already)
	ld   a, DIR_L					; Otherwise, make it move to the left
	ld   [sActSetDir], a
	ret
	
; =============== Act_SyrupCastleBossFireball_OnGround ===============
Act_SyrupCastleBossFireball_OnGround:
	; Permanently despawn once off-screen.
	; (the built-in flag could have been used... again)
	call ActS_CheckOffScreen	; Update offscreen status
	ld   a, [sActSet]			
	cp   a, $02					; Is the actor visible?
	jr   nc, .chkMove			; If so, jump
	xor  a						; Otherwise, despawn it
	ld   [sActSet], a
	ret
	
.chkMove:
; =============== Act_SyrupCastleBossFireball_GroundMove ===============
; Moves the fireball horizontally at 3px/frame.
Act_SyrupCastleBossFireball_GroundMove:
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Moving right?
	jr   nz, .moveR				; If so, jump
.moveL:
	ld   bc, -$03
	call ActS_MoveRight
	ret
.moveR:
	ld   bc, +$03
	call ActS_MoveRight
	ret
	
; =============== Act_SyrupCastleBossFireball_AirMoveL ===============
; Moves the fireball to the left at 0.5px/frame.
Act_SyrupCastleBossFireball_AirMoveL:
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveRight
	ret
; =============== Act_SyrupCastleBossFireball_AirMoveL ===============
; Moves the fireball to the right at 0.5px/frame.
Act_SyrupCastleBossFireball_AirMoveR:;C
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveRight
	ret
	
; =============== Act_SyrupCastleBoss_SwitchToDead ===============
; Called when the final boss is defeated (right after the 6th hit registers).
Act_SyrupCastleBoss_SwitchToDead:
	ld   a, CPTS_RTN_DEAD					; Set next mode
	ld   [sActLocalRoutineId], a
	
	xor  a								; Reset V speed
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ld   [sActSetColiType], a			; Make intangible
	
	ld   a, SFX1_09
	ld   [sSFX1Set], a
	ld   a, BGM_NONE
	ld   [sBGMSet], a
	
	; Hack for the Actor group code, to set an alternate BGM when the room reloads.
	; See also: ActGroup_C40_Room00
	ld   a, $01							
	ld   [sActSyrupCastleBossDead], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_SyrupCastleBoss_Duck
	ld   a, $C8
	ld   [sActBossParallaxFlashTimer], a
	ret
	
; =============== Act_SyrupCastleBoss_Dead ===============
; When the boss dies.
Act_SyrupCastleBoss_Dead:

	;
	; Handle the downwards movement of both the BG Genie viewport and of Cpt. Syrup.
	; The main things we're doing now are:
	; - Making the BG boss move down until it goes off-screen below.
	;   This coincides with the boss Y speed becoming $06 (CPTS_BG_YTARGET).
	; - Making the actor (Cpt. Syrup) move down in sync with the boss,
	;   until it reaches an hardcoded Rel. Y position (CPTS_ACT_YTARGET).
	;   This position should visually match the solid ground.
	; - Switching to the next mode when both conditions are true.
	;
	
	; Wait for the Lamp to be in the proper state for this.
	ld   a, [sActLampEndingOk]
	or   a								; sActLampEndingOk == 0?
	jr   z, .chkMoveBG					; If so, jump
	
	; Skip if the BG boss fall speed hasn't reached $06 yet.
	ld   a, [sActSyrupCastleBossBGYSpeed]
	cp   a, CPTS_BG_YTARGET				; Boss Y speed < $06?
	jr   c, .chkMoveBG					; If so, jump
	
	; Skip if Cpt Syrup hasn't landed yet.
	ld   a, [sActSetRelY]
	cp   a, CPTS_ACT_YTARGET			; Boss Y < $8F? (in the air)
	jr   c, .chkMoveBG					; If so, jump
	
	; Skip if we're holding something already.
	; [POI] Could have used "jr nz, .chkMoveBG" but oh well.
	ld   a, [sActHeld]
	cp   a, PL_HLD_WAITHOLD				; Holding something?
	jr   z, .chkMoveBG					; If so, jump
	cp   a, PL_HLD_HOLDING				; ""
	jr   z, .chkMoveBG					; ""
	
	; If we survived the gauntlet, we can trigger the level clear
	jp   .endMode
	
.chkMoveBG:
	;
	; Move the boss BG down until the target speed is reached.
	;
	
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	jr   nz, .chkMoveAct
	
	ld   a, [sActSyrupCastleBossBGYSpeed]
	cp   a, CPTS_BG_YTARGET				; Y Speed >= $06?
	jr   nc, .chkMoveAct				; If so, skip
	
	; Move genie down by the Y Speed
	ld   c, a						
	call Act_SyrupCastleBoss_MoveGenieDown
	
.chkMoveAct:
	;
	; Move the actor down until it reaches the target Y pos.
	; If it goes past that, force it back to the target.
	;
	ld   a, [sActSetRelY]
	cp   a, CPTS_ACT_YTARGET			; Y Pos >= Target?
	jr   nc, .targetReached				; If so, make it stay on the target
	
	ld   a, [sActSyrupCastleBossActYSpeed]	; BC = Y speed
	ld   c, a
	ld   b, $00
	call ActS_MoveDown						; Move down by that
	jr   .chkIncBGYSpeed
.targetReached:
	ld   a, CPTS_ACT_YTARGET
	ld   [sActSetRelY], a

.chkIncBGYSpeed:
	;
	; Increase the BG Y speed until the limit
	;

	; Every $10 frames...
	ld   a, [sActSetTimer]
	and  a, $0F
	jr   nz, .chkIncActYSpeed
	
	ld   a, [sActSyrupCastleBossBGYSpeed]
	cp   a, CPTS_BG_YTARGET					; YSpeed > $06?
	jr   nc, .chkIncActYSpeed				; If so, skip
	add  $01								; Otherwise, YSpeed++
	ld   [sActSyrupCastleBossBGYSpeed], a
	
.chkIncActYSpeed:
	;
	; Increase the Actor Y speed
	;
	
	; Every 8 frames...
	ld   a, [sActSetTimer]
	ld   b, a
	and  a, $07
	ret  nz
	
	ld   a, [sActSyrupCastleBossActYSpeed]	; YSpeed++
	inc  a
	ld   [sActSyrupCastleBossActYSpeed], a
	
	;
	; Alternate between up/down foot mappings
	;
	ld   a, [sActSetTimer]
	bit  3, b				; == 0?
	jr   z, .writeUp		; If so, jump
.writeDown:
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownR
	call Act_SyrupCastleBoss_BGWrite_GenieFootDownL
	ret
.writeUp:
	call Act_SyrupCastleBoss_BGWrite_GenieFootUpR
	call Act_SyrupCastleBoss_BGWrite_GenieFootUpL
	ret
	
.endMode:
	; Remove the boss layer
	; [POI] This isn't actually needed.
	ld   a, $01								
	ld   [sActSyrupCastleBossBlankBG], a
	
	; Play all clear bgm
	ld   a, BGM_BOSSCLEAR
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	
	; Set timer for next mode
	xor  a
	ld   [sActSyrupCastleBossClearTimer], a
	ld   a, CPTS_RTN_WAITRELOAD
	ld   [sActLocalRoutineId], a
	ret
; =============== Act_SyrupCastleBoss_WaitReload ===============
; Waits $78 frames, then triggers the level clear mode LVLCLEAR_FINALDEAD.
Act_SyrupCastleBoss_WaitReload:
	ld   a, [sActSyrupCastleBossClearTimer]	; Timer++;
	inc  a
	ld   [sActSyrupCastleBossClearTimer], a
	cp   a, $78								; Timer < $78?
	ret  c									; If so, return
	
	; Trigger the special level clear mode for defeating the final boss.
	; This will cause the player to transform back to Normal Wario, go towards the lamp, etc...
	;
	; When this is reached, the actor code is effectively disabled  -- there's no more logic here.
	; This continues until the level clear code reloads the room.
	;
	; Setting the special clear mode will cause the main game loop (more specifically, Game_CheckSpecClear)
	; to start the main ending scene by calling HomeCall_Game_StartEnding.
	; When that happens, the main gameplay loop isn't executed anymore. It may look like it is
	; since the first part of the ending takes place in the level, but it isn't.
	ld   a, LVLCLEAR_FINALDEAD
	ld   [sLvlSpecClear], a
	ret
	
; =============== Act_SyrupCastleBoss_MoveActDown ===============
; This subroutine moves the Captain Syrup actor downwards by the amount specified.
; IN
; - C: Pixels to move down
Act_SyrupCastleBoss_MoveActDown:
	; ActS_MoveDown wants BC, so sign extend C to B
	ld   a, c
	sext a
	ld   b, a
	call ActS_MoveDown
	ret
	
; =============== Act_SyrupCastleBoss_MoveGenieDown ===============
; This subroutine moves the Genie downwards by the amount specified.
; IN
; - C: Pixels to move down
Act_SyrupCastleBoss_MoveGenieDown:
	; Move the *parallax viewports* up. This causes the boss to move down.
	ld   a, [sActBossParallaxY]	; ParallaxY -= C
	sub  a, c
	ld   [sActBossParallaxY], a
	ld   [sParallaxY0], a		
	ld   [sParallaxY1], a
	ld   [sParallaxY2], a
	
	;--
	; The boss room is setup to have a row of solid blocks at the very bottom of the tilemap.
	;
	; When the viewport Y underflows, which happens when the boss moves down off-screen
	; after dying, it would make these blocks visible at the top of the screen.
	;
	; We don't want that, so if the Y coord underflowed we're forcing it back to $20,
	; which makes it draw blank tiles.
	
	cp   a, $A0					; Y >= $A0?
	jr   nc, .hideSect0			; If so, jump
	ret
.hideSect0:
	ld   a, $20
	ld   [sParallaxY0], a
	ret
	
; =============== Act_SyrupCastleBoss_MoveRight ===============
; This subroutine moves both the Captain Syrup actor and the Genie to the right.
; IN
; - C: Pixels to move right
Act_SyrupCastleBoss_MoveRight:
	; Same note about the viewport working in reverse
	ld   a, [sActBossParallaxX]	; ParallaxX -= C
	sub  a, c
	ld   [sActBossParallaxX], a
	ld   [sParallaxX0], a
	ld   [sParallaxX1], a
	ld   [sParallaxX2], a
	; ActS_MoveRight wants BC, so sign extend C to B
	ld   a, c
	sext a
	ld   b, a
	call ActS_MoveRight
	ret
	
; =============== Act_SyrupCastleBoss_YPath ===============
; Y offsets relative to the current position, for moving the genie once a frame.
; NOTE: Each value is used for 2 frames, then the next one is picked.
; These are sent directly to Act_SyrupCastleBoss_MoveActDown and Act_SyrupCastleBoss_MoveGenieDown.
Act_SyrupCastleBoss_YPath: 
	db -$01,-$01,-$01,-$01,-$01,-$01,+$00,-$01
	db +$00,+$00,+$00,+$00,+$00,+$01,+$00,+$01
	db +$01,+$01,+$01,+$01,+$01,+$01,+$01,+$01
	db +$01,+$01,+$01,+$01,+$00,+$01,+$00,+$00
	db +$00,+$00,+$00,-$01,+$00,-$01,-$01,-$01
	db -$01,-$01,-$01,-$01
.end:
; =============== OBJLstSharedPtrTable_Act_SyrupCastleBoss ===============
; [TCRF] Not used -- and points to incorrect anims
OBJLstSharedPtrTable_Act_SyrupCastleBoss:
	dw OBJLstPtrTable_Act_SyrupCastleBoss_Unused_01;X
	dw OBJLstPtrTable_Act_SyrupCastleBoss_Unused_01;X
	dw OBJLstPtrTable_Act_SyrupCastleBoss_Unused_01;X
	dw OBJLstPtrTable_Act_SyrupCastleBoss_Unused_01;X
	dw OBJLstPtrTable_Act_SyrupCastleBoss_Unused_01;X
	dw OBJLstPtrTable_Act_SyrupCastleBoss_Unused_01;X
	dw OBJLstPtrTable_Act_SyrupCastleBoss_Unused_01;X
	dw OBJLstPtrTable_Act_SyrupCastleBoss_Unused_01;X
	
; [TCRF] Unused 2x2 animating square with broken graphics, like the ones seen in Act_Cart.
OBJLstPtrTable_Act_SyrupCastleBoss_Unused_00:
	dw OBJLst_Act_SyrupCastleBoss_Unused_00;X
	dw OBJLst_Act_SyrupCastleBoss_Unused_01;X
	dw $0000;X
; [TCRF] Unused 3x2 animating square with broken graphics
OBJLstPtrTable_Act_SyrupCastleBoss_Unused_01:
	dw OBJLst_Act_SyrupCastleBoss_Unused_04;X
	dw OBJLst_Act_SyrupCastleBoss_Unused_05;X
	dw $0000;X
	
OBJLstPtrTable_Act_SyrupCastleBoss_Lay:
	dw OBJLst_Act_SyrupCastleBoss_Lay
	dw $0000
OBJLstPtrTable_Act_SyrupCastleBoss_Stand:
	dw OBJLst_Act_SyrupCastleBoss_Stand
	dw $0000
OBJLstPtrTable_Act_SyrupCastleBoss_StandOpen:
	dw OBJLst_Act_SyrupCastleBoss_StandOpen
	dw $0000
OBJLstPtrTable_Act_SyrupCastleBoss_StandRub:
	dw OBJLst_Act_SyrupCastleBoss_StandRub0
	dw OBJLst_Act_SyrupCastleBoss_StandRub1
	dw $0000
OBJLstPtrTable_Act_SyrupCastleBoss_DuckRub:
	dw OBJLst_Act_SyrupCastleBoss_DuckRub0
	dw OBJLst_Act_SyrupCastleBoss_DuckRub1
	dw $0000
OBJLstPtrTable_Act_SyrupCastleBoss_Duck:
	dw OBJLst_Act_SyrupCastleBoss_Dead0
	dw $0000;X
OBJLstPtrTable_Act_SyrupCastleBoss_Dead:
	dw OBJLst_Act_SyrupCastleBoss_Dead0
	dw OBJLst_Act_SyrupCastleBoss_Dead1
	dw OBJLst_Act_SyrupCastleBoss_Dead2
	dw $0000
OBJLstPtrTable_Act_SyrupCastleBoss_JumpSideR:
	dw OBJLst_Act_SyrupCastleBoss_JumpSideR
	dw $0000
OBJLstPtrTable_Act_SyrupCastleBoss_Bomb:
	dw OBJLst_Act_SyrupCastleBoss_Bomb0
	dw OBJLst_Act_SyrupCastleBoss_Bomb1
	dw $0000
OBJLstPtrTable_Act_SyrupCastleBoss_JumpFrontL:
	dw OBJLst_Act_SyrupCastleBoss_JumpFrontL
	dw $0000;X
OBJLstPtrTable_Act_SyrupCastleBoss_Syrup_StandOpen_Copy:
	dw OBJLst_Act_SyrupCastleBoss_Syrup_StandOpen_Copy
	dw $0000;X
OBJLstPtrTable_Act_SyrupCastleBoss_OnGenieArmWave:
	dw OBJLst_Act_SyrupCastleBoss_OnGenie0
	dw OBJLst_Act_SyrupCastleBoss_OnGenie1
	dw $0000
OBJLstPtrTable_Act_SyrupCastleBoss_OnGenieStand:
	dw OBJLst_Act_SyrupCastleBoss_OnGenie0
	dw $0000;X
; [TCRF] Unused copy of OBJLstPtrTable_Act_SyrupCastleBoss_Duck with unused duplicate frames
OBJLstPtrTable_Act_SyrupCastleBoss_Unused_Duck:
	dw OBJLst_Act_SyrupCastleBoss_Unused_Dead0_Copy;X
	dw $0000;X
; [TCRF] Unused copy of OBJLstPtrTable_Act_SyrupCastleBoss_Dead with unused duplicate frames
OBJLstPtrTable_Act_SyrupCastleBoss_Unused_03:
	dw OBJLst_Act_SyrupCastleBoss_Unused_Dead0_Copy;X
	dw OBJLst_Act_SyrupCastleBoss_Unused_Dead1_Copy;X
	dw OBJLst_Act_SyrupCastleBoss_Unused_Dead2_Copy;X
	dw $0000;X
OBJLstPtrTable_Act_SyrupCastleBossFireball_Air:
	dw OBJLst_Act_SyrupCastleBossFireball_Air
	dw $0000;X
OBJLstPtrTable_Act_SyrupCastleBossFireball_Ground:
	dw OBJLst_Act_SyrupCastleBossFireball_Ground
	dw $0000;X

OBJLst_Act_SyrupCastleBoss_Syrup_StandOpen_Copy: INCBIN "data/objlst/actor/syrupcastleboss_syrup_standopen_copy.bin"
OBJLst_Act_SyrupCastleBoss_JumpFrontL: INCBIN "data/objlst/actor/syrupcastleboss_jumpfrontl.bin"
OBJLst_Act_SyrupCastleBoss_OnGenie0: INCBIN "data/objlst/actor/syrupcastleboss_ongenie0.bin"
OBJLst_Act_SyrupCastleBoss_OnGenie1: INCBIN "data/objlst/actor/syrupcastleboss_ongenie1.bin"
OBJLst_Act_SyrupCastleBoss_Unused_Dead0_Copy: INCBIN "data/objlst/actor/syrupcastleboss_unused_dead0_copy.bin"
OBJLst_Act_SyrupCastleBoss_Unused_Dead1_Copy: INCBIN "data/objlst/actor/syrupcastleboss_unused_dead1_copy.bin"
OBJLst_Act_SyrupCastleBoss_Unused_Dead2_Copy: INCBIN "data/objlst/actor/syrupcastleboss_unused_dead2_copy.bin"
OBJLst_Act_Lamp_U: INCBIN "data/objlst/actor/lamp_u.bin"
OBJLst_Act_Lamp_L: INCBIN "data/objlst/actor/lamp_l.bin"
OBJLst_Act_Lamp_D: INCBIN "data/objlst/actor/lamp_d.bin"
OBJLst_Act_Lamp_R: INCBIN "data/objlst/actor/lamp_r.bin"
OBJLst_Act_SyrupCastleBoss_Unused_00: INCBIN "data/objlst/actor/syrupcastleboss_unused_00.bin"
OBJLst_Act_SyrupCastleBoss_Unused_01: INCBIN "data/objlst/actor/syrupcastleboss_unused_01.bin"
OBJLst_Act_SyrupCastleBoss_Unused_02: INCBIN "data/objlst/actor/syrupcastleboss_unused_02.bin"
OBJLst_Act_SyrupCastleBoss_Unused_03: INCBIN "data/objlst/actor/syrupcastleboss_unused_03.bin"
OBJLst_Act_SyrupCastleBoss_Unused_04: INCBIN "data/objlst/actor/syrupcastleboss_unused_04.bin"
OBJLst_Act_SyrupCastleBoss_Unused_05: INCBIN "data/objlst/actor/syrupcastleboss_unused_05.bin"
OBJLst_Act_MiniGenie_MoveV: INCBIN "data/objlst/actor/minigenie_movev.bin"
OBJLst_Act_MiniGenie_MoveH: INCBIN "data/objlst/actor/minigenie_moveh.bin"
OBJLst_Act_MiniGenie_Stun: INCBIN "data/objlst/actor/minigenie_stun.bin"
OBJLst_Act_MiniGenie_Unused_StunAlt: INCBIN "data/objlst/actor/minigenie_unused_stunalt.bin"
OBJLst_Act_SyrupCastleBossFireball_Air: INCBIN "data/objlst/actor/syrupcastlebossfireball_air.bin"
OBJLst_Act_SyrupCastleBossFireball_Ground: INCBIN "data/objlst/actor/syrupcastlebossfireball_ground.bin"
OBJLst_Act_LampSmoke_Unused_Large0: INCBIN "data/objlst/actor/lampsmoke_unused_large0.bin"
OBJLst_Act_LampSmoke_Unused_Large1: INCBIN "data/objlst/actor/lampsmoke_unused_large1.bin"
OBJLst_Act_MiniGenie_Cloud0: INCBIN "data/objlst/actor/minigenie_cloud0.bin"
OBJLst_Act_MiniGenie_Cloud1: INCBIN "data/objlst/actor/minigenie_cloud1.bin"
OBJLst_Act_MiniGenieProjectile: INCBIN "data/objlst/actor/minigenieprojectile.bin"
OBJLst_Act_SyrupCastleBoss_Lay: INCBIN "data/objlst/actor/syrupcastleboss_lay.bin"
OBJLst_Act_SyrupCastleBoss_Stand: INCBIN "data/objlst/actor/syrupcastleboss_stand.bin"
OBJLst_Act_SyrupCastleBoss_StandRub0: INCBIN "data/objlst/actor/syrupcastleboss_standrub0.bin"
OBJLst_Act_SyrupCastleBoss_StandRub1: INCBIN "data/objlst/actor/syrupcastleboss_standrub1.bin"
OBJLst_Act_SyrupCastleBoss_DuckRub0: INCBIN "data/objlst/actor/syrupcastleboss_duckrub0.bin"
OBJLst_Act_SyrupCastleBoss_DuckRub1: INCBIN "data/objlst/actor/syrupcastleboss_duckrub1.bin"
OBJLst_Act_SyrupCastleBoss_Dead0: INCBIN "data/objlst/actor/syrupcastleboss_dead0.bin"
OBJLst_Act_SyrupCastleBoss_Dead1: INCBIN "data/objlst/actor/syrupcastleboss_dead1.bin"
OBJLst_Act_SyrupCastleBoss_Dead2: INCBIN "data/objlst/actor/syrupcastleboss_dead2.bin"
OBJLst_Act_SyrupCastleBoss_JumpSideR: INCBIN "data/objlst/actor/syrupcastleboss_jumpsider.bin"
OBJLst_Act_Lamp_Idle: INCBIN "data/objlst/actor/lamp_idle.bin"
OBJLst_Act_Lamp_Flash: INCBIN "data/objlst/actor/lamp_flash.bin"
OBJLst_Act_SyrupCastleBoss_Bomb0: INCBIN "data/objlst/actor/syrupcastleboss_bomb0.bin"
OBJLst_Act_SyrupCastleBoss_Bomb1: INCBIN "data/objlst/actor/syrupcastleboss_bomb1.bin"
OBJLst_Act_LampSmoke0: INCBIN "data/objlst/actor/lampsmoke0.bin"
OBJLst_Act_LampSmoke1: INCBIN "data/objlst/actor/lampsmoke1.bin"
OBJLst_Act_SyrupCastleBoss_StandOpen: INCBIN "data/objlst/actor/syrupcastleboss_standopen.bin"

GFX_Act_SyrupCastleBossIntro: INCBIN "data/gfx/actor/syrupcastlebossintro.bin"
GFX_Level_GenieBoss: INCBIN "data/gfx/level/level_genieboss.bin"

; =============== Act_SyrupCastleBoss_ClearBG ===============
; Blanks (in practice) the entirety of the BG area.
; This requires the wave effect to not be done.
Act_SyrupCastleBoss_ClearBG:
	ld   hl, BGMap_Begin				; HL = Initial address
	ld   de, BGMap_End-BGMap_Begin-$18	; DE = Bytes to clear
	
.loop:
	mWaitForNewHBlank
	; Clear 4 bytes at a time
	ld   a, $1A				; Blank tile	
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	dec  de					; BytesLeft -= 4
	dec  de
	dec  de
	dec  de
	
	bit  7, d				; DE < 0?
	jr   z, .loop			; If not, loop
	ret
	
; =============== Act_SyrupCastleBoss_BGWrite_Ground ===============
; Writes a row of $10 blocks at the bottom of the tilemap.
Act_SyrupCastleBoss_BGWrite_Ground:
	ld   bc, vBGGenieBossGround0	
	ld   hl, vBGGenieBossGround1
	ld   d, BG_BLOCKCOUNT_H
.loop:
	;--
	; Upper 8x8
	mWaitForNewHBlank
	ld   a, TILEID_GENIE_SOLID_UL
	ld   [bc], a
	inc  bc
	ld   a, TILEID_GENIE_SOLID_UR
	ld   [bc], a
	inc  bc
	
	;--
	; Lower 8x8
	; [TCRF] The lower portion of the blocks is always cut off by the status bar,
	;        so we don't actually need to o this.
	mWaitForNewHBlank
	ld   a, TILEID_GENIE_SOLID_DL
	ldi  [hl], a
	ld   a, TILEID_GENIE_SOLID_DR
	ldi  [hl], a
	
	dec  d			; Have we copied all $10 blocks yet?
	jr   nz, .loop	; If not, loop
	ret
	
; =============== mSyrupCastleBoss_BGWriteCall* ===============
; Helper macro for generating a call to Act_SyrupCastleBoss_BGWrite*
; IN
; - 1: Base address
; - 2: X offset (in tiles)
; - 3: Y offset (in tiles)
; - 4: Tiles to copy
mAct_SyrupCastleBoss_BGWriteCall: MACRO
	ld   hl, \1 + (BG_TILECOUNT_H * \3) + \2
	call Act_SyrupCastleBoss_BGWrite\4
ENDM
; for first loading only
mAct_SyrupCastleBoss_BGWriteCall2: MACRO
	ld   hl, \1 + (BG_TILECOUNT_H * \3) + \2
	call Act_SyrupCastleBoss_BGWrite\4
	call Act_SyrupCastleBoss_BGWrite\4
	call Act_SyrupCastleBoss_DoWaveEffectSoftStub
ENDM	
	
; =============== Act_SyrupCastleBoss_BGWrite_* ===============
; This set of subroutines copies tilemaps for the Genie boss body.

; =============== Act_SyrupCastleBoss_BGWrite_GenieBody ===============
; Writes the tilemap for the main genie body.
; This is meant to be done only when the boss first loads.
Act_SyrupCastleBoss_BGWrite_GenieBody:
	ld   bc, BG_Act_SyrupCastleBoss_GenieBody
	;                                 BASE              X  Y  Count
	mAct_SyrupCastleBoss_BGWriteCall2 vBGGenieBossBody, 0, 0, 5
	mAct_SyrupCastleBoss_BGWriteCall2 vBGGenieBossBody, 0, 1, 5
	mAct_SyrupCastleBoss_BGWriteCall2 vBGGenieBossBody, 0, 2, 5
	mAct_SyrupCastleBoss_BGWriteCall2 vBGGenieBossBody, 0, 3, 5
	mAct_SyrupCastleBoss_BGWriteCall2 vBGGenieBossBody, 0, 4, 5
	mAct_SyrupCastleBoss_BGWriteCall2 vBGGenieBossBody, 0, 5, 5
	mAct_SyrupCastleBoss_BGWriteCall2 vBGGenieBossBody, 0, 6, 5
	mAct_SyrupCastleBoss_BGWriteCall2 vBGGenieBossBody, 0, 7, 5
	mAct_SyrupCastleBoss_BGWriteCall2 vBGGenieBossBody, 0, 8, 5
	mAct_SyrupCastleBoss_BGWriteCall2 vBGGenieBossBody, 0, 9, 5
	ret
	
Act_SyrupCastleBoss_BGWrite_GenieHandClosedL:;C
	ld   bc, BG_Act_SyrupCastleBoss_GenieHandClosedL
	;                                BASE               X  Y  Count
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandL, 0, 0, 5
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandL, 0, 1, 5
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandL, 0, 2, 5
	ret
Act_SyrupCastleBoss_BGWrite_GenieHandOpenL:
	ld   bc, BG_Act_SyrupCastleBoss_GenieHandOpenL
	;                                BASE               X  Y  Count
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandL, 0, 0, 5
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandL, 0, 1, 5
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandL, 0, 2, 5
	ret
Act_SyrupCastleBoss_BGWrite_GenieHandPointL:
	ld   bc, BG_Act_SyrupCastleBoss_GenieHandPointL
	;                                BASE               X  Y  Count
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandL, 0, 0, 5
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandL, 0, 1, 5
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandL, 0, 2, 5
	ret
Act_SyrupCastleBoss_BGWrite_GenieHandClosedR:
	ld   bc, BG_Act_SyrupCastleBoss_GenieHandClosedR
	;                                BASE               X  Y  Count
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandR, 0, 0, 5
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandR, 0, 1, 5
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandR, 0, 2, 5
	ret
Act_SyrupCastleBoss_BGWrite_GenieHandOpenR:
	ld   bc, BG_Act_SyrupCastleBoss_GenieHandOpenR
	;                                BASE               X  Y  Count
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandR, 0, 0, 5
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandR, 0, 1, 5
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandR, 0, 2, 5
	ret
Act_SyrupCastleBoss_BGWrite_GenieHandPointR:
	ld   bc, BG_Act_SyrupCastleBoss_GenieHandPointR
	;                                BASE               X  Y  Count
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandR, 0, 0, 5
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandR, 0, 1, 5
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossHandR, 0, 2, 5
	ret
Act_SyrupCastleBoss_BGWrite_GenieFootDownL:
	ld   bc, BG_Act_SyrupCastleBoss_GenieFootDownL
	;                                BASE               X  Y  Count
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFootL, 0, 0, 2
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFootL, 0, 1, 4
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFootL, 2, 2, 3
	ret
Act_SyrupCastleBoss_BGWrite_GenieFootUpL:
	ld   bc, BG_Act_SyrupCastleBoss_GenieFootUpL
	;                                BASE               X  Y  Count
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFootL, 0, 0, 2
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFootL, 0, 1, 4
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFootL, 2, 2, 3
	ret
Act_SyrupCastleBoss_BGWrite_GenieFootDownR:
	ld   bc, BG_Act_SyrupCastleBoss_GenieFootDownR
	;                                BASE               X  Y  Count
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFootR, 3, 0, 2
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFootR, 1, 1, 4
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFootR, 0, 2, 3
	ret
Act_SyrupCastleBoss_BGWrite_GenieFootUpR:
	ld   bc, BG_Act_SyrupCastleBoss_GenieFootUpR
	;                                BASE               X  Y  Count
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFootR, 3, 0, 2
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFootR, 1, 1, 4
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFootR, 0, 2, 3
	ret
Act_SyrupCastleBoss_BGWrite_GenieFaceHit:
	ld   bc, BG_Act_SyrupCastleBoss_GenieFaceHit
	;                                BASE              X  Y  Count
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFace, 0, 0, 4
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFace, 0, 1, 4
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFace, 1, 2, 2
	ret
Act_SyrupCastleBoss_BGWrite_GenieFace:
	ld   bc, BG_Act_SyrupCastleBoss_GenieFace
	;                                BASE              X  Y  Count
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFace, 0, 0, 4
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFace, 0, 1, 4
	mAct_SyrupCastleBoss_BGWriteCall vBGGenieBossFace, 1, 2, 2
	ret
	
BG_Act_SyrupCastleBoss_GenieBody: INCBIN "data/bg/level/syrupcastleboss_geniebody.bin"
BG_Act_SyrupCastleBoss_GenieFaceHit: INCBIN "data/bg/level/syrupcastleboss_geniefacehit.bin"
BG_Act_SyrupCastleBoss_GenieFace: INCBIN "data/bg/level/syrupcastleboss_genieface.bin"
BG_Act_SyrupCastleBoss_GenieHandClosedL: INCBIN "data/bg/level/syrupcastleboss_geniehandclosedl.bin"
BG_Act_SyrupCastleBoss_GenieHandOpenL: INCBIN "data/bg/level/syrupcastleboss_geniehandopenl.bin"
BG_Act_SyrupCastleBoss_GenieHandPointL: INCBIN "data/bg/level/syrupcastleboss_geniehandpointl.bin"
BG_Act_SyrupCastleBoss_GenieHandClosedR: INCBIN "data/bg/level/syrupcastleboss_geniehandclosedr.bin"
BG_Act_SyrupCastleBoss_GenieHandOpenR: INCBIN "data/bg/level/syrupcastleboss_geniehandopenr.bin"
BG_Act_SyrupCastleBoss_GenieHandPointR: INCBIN "data/bg/level/syrupcastleboss_geniehandpointr.bin"
BG_Act_SyrupCastleBoss_GenieFootDownL: INCBIN "data/bg/level/syrupcastleboss_geniefootdownl.bin"
BG_Act_SyrupCastleBoss_GenieFootUpL: INCBIN "data/bg/level/syrupcastleboss_geniefootupl.bin"
BG_Act_SyrupCastleBoss_GenieFootDownR: INCBIN "data/bg/level/syrupcastleboss_geniefootdownr.bin"
BG_Act_SyrupCastleBoss_GenieFootUpR: INCBIN "data/bg/level/syrupcastleboss_geniefootupr.bin"

; =============== mAct_SyrupCastleBoss_BGWrite ===============
; This macro copies tiles from the specified tilemap directly to VRAM
; during HBlank time.
; See also: mSSTeacupBoss_BGWrite
; IN
; - 1: Tiles to copy
; - BC: Ptr to tilemap
; - HL: Destination in VRAM
mAct_SyrupCastleBoss_BGWrite: MACRO
	mWaitForNewHBlank
REPT \1
	ld   a, [bc]		; A = Tile ID
	inc  bc				; TilemapPtr++
	ldi  [hl], a		; Write it to VRAM
ENDR
ENDM


; =============== Act_SyrupCastleBoss_BGWrite<N> ===============
; Set of helper subroutines for copying N tiles from the specified tilemap directly to VRAM.
; IN
; - BC: Ptr to tilemap
; - HL: Destination in VRAM
Act_SyrupCastleBoss_BGWrite2:
	mAct_SyrupCastleBoss_BGWrite 2
	ret
Act_SyrupCastleBoss_BGWrite3:
	mAct_SyrupCastleBoss_BGWrite 2
	mAct_SyrupCastleBoss_BGWrite 1
	ret
Act_SyrupCastleBoss_BGWrite4:
	mAct_SyrupCastleBoss_BGWrite 2
	mAct_SyrupCastleBoss_BGWrite 2
	ret
Act_SyrupCastleBoss_BGWrite5:
REPT 5
	; Could have been 5 times mAct_SyrupCastleBoss_BGWrite 1
	mWaitForNewHBlank
	ld   a, [bc]
	ldi  [hl], a	
	inc  bc			
ENDR
	ret
	
; =============== Act_SyrupCastleBoss_Unused_ClearBG14H ===============
; [TCRF] Unreferenced code.
; Blanks $0D tiles horizontally starting at the specified location.
;
; IN
; - HL: Starting tilemap ptr
;
Act_SyrupCastleBoss_Unused_ClearBG14H:
	ld   b, $1A ; Blank tile
REPT 3
	mWaitForNewHBlank
	ld   a, b				
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
ENDR
	mWaitForNewHBlank
	ld   a, b				
	ldi  [hl], a
	ldi  [hl], a
	ret

; =============== Act_SyrupCastleBoss_LoadVRAMGenieAndSetParallax ===============
; Sets up the VRAM for displaying the Genie boss and sets the special scroll mode for the final boss.
;
; [POI] This subroutine calls other subroutines which take up several frames without returning,
;       which is the reason the game can't be paused during the parallax effect.
;       Subroutines which do this are marked with "[WAIT]".
Act_SyrupCastleBoss_LoadVRAMGenieAndSetParallax:
	;--
	; Set up the GFX copy for the genie graphics.
	ld   a, LOW(vGFXGenieBoss)
	ld   [sCopyGFXDestPtr_Low], a
	ld   a, HIGH(vGFXGenieBoss)
	ld   [sCopyGFXDestPtr_High], a
	ld   a, LOW(GFX_Level_GenieBoss)
	ld   [sCopyGFXSourcePtr_Low], a
	ld   a, HIGH(GFX_Level_GenieBoss)
	ld   [sCopyGFXSourcePtr_High], a
	ld   a, [sScrollX]
	ld   [sActSyrupCastleBossWaveXOffset], a
	;--
	
	; Execute the line shift effect for $3C frames (with the background)
	call Act_SyrupCastleBoss_DoWaveEffectSoft3C ; [WAIT]
	call Act_SyrupCastleBoss_ClearBG
	
	; We need to enable an interrupt, so stop them all
	di
	
	;--
	; For the parallax effect, we need to divide the screen in 2 sections
	; - Boss body
	; - Ground
	
	; Starting coords for boss body (X: $70, Y: $60)
	; As the boss moves around, these will be updated (all at once, of course).
	ld   a, $70
	ld   [sActBossParallaxX], a
	ld   [sParallaxX0], a
	ld   [sParallaxX1], a
	ld   [sParallaxX2], a
	ld   a, $60
	ld   [sActBossParallaxY], a
	ld   [sParallaxY0], a
	ld   [sParallaxY1], a
	ld   [sParallaxY2], a
	
	; For the ground, use fixed values which won't be changed.
	ld   a, $00
	ld   [sParallaxX3], a
	ld   a, $70
	ld   [sParallaxY3], a
	
	; Set parallax line triggers
	ld   a, $00
	ld   [sParallaxNextLY0], a
	ld   a, $28
	ld   [sParallaxNextLY1], a
	ld   a, $7E
	ld   [sParallaxNextLY2], a
	ld   a, $80
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
	
	ld   a, [sParallaxX0]
	ld   [sActSyrupCastleBossWaveXOffset], a
	call Act_SyrupCastleBoss_BGWrite_GenieBody
	call Act_SyrupCastleBoss_BGWrite_Ground
	call Act_SyrupCastleBoss_LoadGFXGenieAndDoWaveEffect ; [WAIT]
	call Act_SyrupCastleBoss_DoWaveEffectSoft3C ; [WAIT]
	ret
	
; =============== Act_SyrupCastleBoss_LoadGFXGenieAndDoWaveEffect ===============
; This subroutine loads the GFX data for the Genie boss 1 tile/frame.
; While that happens, an hard wavy line shift effect is performed for the 
; entire duration of the frame, to hide any graphical glitches.
; 
; See also: Act_SyrupCastleBoss_DoWaveEffectSoft.
Act_SyrupCastleBoss_LoadGFXGenieAndDoWaveEffect:
.start:
	; Increase wave pattern & play sound
	call Act_SyrupCastleBoss_DoWaveEffect_WaitEndFrame
	
	; [BUG] Same bug as Act_SyrupCastleBoss_DoWaveEffectSoft about the lack of HBlank checks.
.loop:
IF FIX_BUGS == 1
	mWaitForNewHBlank
ENDC
	;--
	; B = WaveTable[((Timer & $1E) >> 1) + rowVal]
	
	; Calc scanline-based index
	ldh  a, [rLY]
	and  a, $0F
	ld   hl, Act_SyrupCastleBoss_WaveHardTbl
	
	; Calc timer-based index
	ld   d, $00
	ld   e, a
	ld   a, [sActSetTimer]
	and  a, $0F
	add  e
	ld   e, a
	
	add  hl, de
	ld   a, [hl]
	ld   b, a
	;--
	
	; Offset the scroll effect by the amount specified.
.addOffset:
	ld   a, [sActSyrupCastleBossWaveXOffset]
	add  b
	ldh  [rSCX], a
	
	; If we aren't in VBlank yet, execute the effect again.
	ldh  a, [rLY]
IF FIX_BUGS == 1
	cp   a, LY_VBLANK-1		
	jr   c, .loop
ELSE
	cp   a, LY_VBLANK+1		; rLY < LY_VBLANK+1?
	jr   c, .loop			; If so, loop
ENDC
	
	; Otherwise, copy 1 single tile
	call CopyGFX_MultiFrame
	or   a						; Copied all tiles?
	jr   nz, .start				; If not, start again
	ret
	
; =============== Act_SyrupCastleBoss_DoWaveEffectSoftStub ===============
Act_SyrupCastleBoss_DoWaveEffectSoftStub:
	call Act_SyrupCastleBoss_DoWaveEffectSoft
	ret
	
; =============== Act_SyrupCastleBoss_DoWaveEffectSoft3C ===============
; Executes the soft line shift effect $3C times.
;
; This takes exclusive control for the entire duration of the effect,
; meaning that for $3C frames any other code except for VBlank won't execute.
Act_SyrupCastleBoss_DoWaveEffectSoft3C:
	ld   bc, $003C		; BC = Times to execute the effect
.loop:
	call Act_SyrupCastleBoss_DoWaveEffectSoft		
	dec  bc				; Lines--
	ld   a, b			
	or   a, c			; Lines != 0?
	jr   nz, .loop		; If so, loop
	ret
; =============== Act_SyrupCastleBoss_DoWaveEffectSoft ===============
; This subroutine performs the soft wavy line shift effect for the entire duration of the frame.
;
; This is named "soft" since the waves generated by this aren't as large as the "hard" variant.
Act_SyrupCastleBoss_DoWaveEffectSoft:
	push bc
	push de
	push hl
	
	;--
	; If we're still in VBlank mode (from a previous execution), wait until we've exited it.
.waitVBlankEnd:
	ldh  a, [rLY]
	cp   a, LY_VBLANK+1
	jr   nc, .waitVBlankEnd
	;--
	
	; [BUG] There's no HBlank check anywhere here, which causes the wave effect to be imprecise,
	;       since LY may change in the middle of the loop.
	;       Adding mWaitForNewHBlank at the start of the .loop will fix this, as well as fixing
	;       the loop check to avoid waiting for HBlank during VBlank (which would freeze the game).
	;		LY_VBLANK-1 is a good value to account for any inaccuracies.
.loop:
IF FIX_BUGS == 1
	mWaitForNewHBlank
ENDC
	; Calculate the *scanline-based* table index for this specific row.
	; DE = rLY % $10
	;      TIMER  TableSize
	;
	; Because this is tied to rLY, it will increase by one when it processes a new line.
	; As the values in the table are in a specific pattern, this will cause a wave-like scrolling effect.
	;
	; The indexes also loop every 16 values.
	ldh  a, [rLY]		
	and  a, $0F
	
	; HL = Base offset for the wave effect table.
	ld   hl, Act_SyrupCastleBoss_WaveSoftTbl
	
	; Calculate the *timer-based* index.
	; DE = ((Timer & $1E) >> 1)
	;
	; It's used to pick the initial index to the wave table.
	; Because this depends on the timer (albeit >> 1'd to use a slower speed),
	; this will result in the waves appearing to move upwards.
	;
	; With this and the current index above, the current wave entry to use can be calculated as:
	; Offset = WaveTable[((Timer & $1E) >> 1) + rowVal]
	;
	; With "rowVal" changing on each scanline, and the Timer changing at the end of every frame.
	ld   d, $00				
	ld   e, a				
	ld   a, [sActSetTimer]	
	and  a, $1E
	rrca					; A = ((Timer & $1E) >> 1)
	add  e				; A += rowVal
	ld   e, a
	add  hl, de
	ld   a, [hl]			; D = Scroll offset
	ld   d, a
	
	; Offset the scroll effect by the amount specified.
.addOffset:
	ld   a, [sActSyrupCastleBossWaveXOffset]
	add  d
	ldh  [rSCX], a
	
	; If we aren't in VBlank yet, execute the effect again.
	ldh  a, [rLY]
IF FIX_BUGS == 1
	cp   a, LY_VBLANK-1		
	jr   c, .loop
ELSE
	cp   a, LY_VBLANK+1		
	jr   c, .loop
ENDC
	; Otherwise, we've reached the end of the frame.
	; Shift the wave pattern.
.end:
	call Act_SyrupCastleBoss_DoWaveEffect_EndFrame
	pop  hl
	pop  de
	pop  bc
	ret
	
; =============== Act_SyrupCastleBoss_DoWaveEffect_WaitEndFrame ===============
; Seems like it was meant to wait for the end of the frame before falling 
; through Act_SyrupCastleBoss_DoWaveEffect_EndFrame, but it's broken.
Act_SyrupCastleBoss_DoWaveEffect_WaitEndFrame:
.wait:
	ldh  a, [rLY]		
	cp   a, LY_VBLANK+1		
	; [BUG] This makes no sense. Was it supposed to be "jr c" instead?
IF FIX_BUGS == 1
	jr   c, .wait
ELSE
	jr   z, .wait
ENDC	
	
; =============== Act_SyrupCastleBoss_DoWaveEffect_EndFrame ===============
; Executes the bare minimum after performing the wave effect for the entire frame.
Act_SyrupCastleBoss_DoWaveEffect_EndFrame:
	ld   a, [sActSetTimer]	; Increase the timer to shift the wave pattern
	inc  a
	ld   [sActSetTimer], a
	mSubCall Sound_DoStub	; Execute the sound code
	ret
	
; =============== Act_SyrupCastleBoss_WaveSoftTbl ===============
Act_SyrupCastleBoss_WaveSoftTbl: 
	db +$04,+$07,+$09,+$0A,+$0A,+$09,+$07,+$04
	db -$04,-$07,-$09,-$0A,-$0A,-$09,-$07,-$04
	db +$04,+$07,+$09,+$0A,+$0A,+$09,+$07,+$04
	db -$04,-$07,-$09,-$0A,-$0A,-$09,-$07
	db -$04 ; [POI] Cut off, not used
	
; =============== Act_SyrupCastleBoss_WaveHardTbl ===============
Act_SyrupCastleBoss_WaveHardTbl: 
	db +$08,+$0E,+$12,+$14,+$14,+$12,+$0E,+$08
	db -$08,-$0E,-$12,-$14,-$14,-$12,-$0E,-$08
	db +$08,+$0E,+$12,+$14,+$14,+$12,+$0E,+$08
	db -$08,-$0E,-$12,-$14,-$14,-$12,-$0E
	db -$08 ; [POI] Cut off, not used
	
; =============== ActInit_Pelican ===============
ActInit_Pelican:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$04
	ld   [sActSetColiBoxL], a
	ld   a, +$04
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Pelican
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_Pelican_MoveL
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Pelican
	call ActS_SetOBJLstSharedTablePtr
	
	; Don't throw a bomb immediately (or turn)
	xor  a
	ld   [sActPelicanThrowTimer], a
	
	; This actor is always defeatable on all sides
	; (while the projectile itself is what actually deals damage, but that's a separate actor)
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Move $10 frames towards the player before throwing a bomb
	ld   a, $10
	ld   [sActPelicanMoveTimer], a
	
	; Save the previously set collision type
	mSubCall ActS_SaveColiType ; BANK $02
	ret
	
; =============== Act_Pelican ===============
Act_Pelican:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Pelican_Main
	dw SubCall_ActInitS_StunFloatingPlatform
	dw SubCall_ActInitS_StunFloatingPlatform
	dw SubCall_ActS_StartStarKill
	dw .onPlColiBelow
	dw SubCall_ActS_StartDashKill
	dw Act_Pelican_Main;X
	dw Act_Pelican_Main;X
	dw SubCall_ActS_StartJumpDead
	
.onPlColiBelow:
	ld   a, SFX1_01
	ld   [sSFX1Set], a
	jp   SubCall_ActInitS_StunFloatingPlatform
	
; =============== Act_Pelican_Main ===============
Act_Pelican_Main:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Do the actor specific code basically
	call Act_Pelican_DoActions
	
	; Animate every $10 frames
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .moveV
	ld   a, [sActSetOBJLstId]	; AnimFrame++
	inc  a
	ld   [sActSetOBJLstId], a
	
.moveV:
	; Bob on water
	call Act_Pelican_MoveV
	ret
	
; =============== Act_Pelican_DoActions ===============
; Handle actor movement and bomb throwing.
Act_Pelican_DoActions:
	; Every 4 frames...
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	
	; Actions are handled in sequence through two decrementing timers.
	; This actor goes between two phases:
	; - Bomb throwing
	;   When sActPelicanThrowTimer is != 0.
	; - Movement
	;   When sActPelicanThrowTimer is 0, and sActPelicanMoveTimer != 0
	;
	; When both timers elapse, both values are reset and the cycle repeats.
	
.chkBombMode:
	ld   a, [sActPelicanThrowTimer]
	or   a								; Timer == $00?
	jr   z, .chkMoveMode				; If so, move instead
.bombMode:
	dec  a								; Timer--
	ld   [sActPelicanThrowTimer], a
	
	;
	; Handle the sequence for animating the bomb spawning anim.
	; (and spawning the bomb, of course).
	;
	ld   a, [sActPelicanThrowTimer]
	cp   a, $1E							
	jr   z, Act_Pelican_OpenMouth					
	ld   a, [sActPelicanThrowTimer]
	cp   a, $16							
	jp   z, Act_Pelican_SpawnBomb		
	ld   a, [sActPelicanThrowTimer]
	cp   a, $0F
	jr   z, Act_Pelican_CloseMouth		
	
	; After closing the beak, wait for a few frames before turning around
	ld   a, [sActPelicanThrowTimer]
	cp   a, $01
	ret  nz
.turnDir:
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ret
	
.chkMoveMode:
	; If the timer elapses, repeat the cycle again
	ld   a, [sActPelicanMoveTimer]
	or   a									; Timer == 0?
	jr   z, Act_Pelican_SwitchToBombMode	; If so, jump
.moveMode:
	dec  a
	ld   [sActPelicanMoveTimer], a
	
	; Move depending on the direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, Act_Pelican_MoveRight
	bit  DIRB_L, a
	jr   nz, Act_Pelican_MoveLeft
	ret ; [POI] We never get here
	
; =============== Act_Pelican_SwitchToBombMode ===============
; Resets both timers to their default values.
Act_Pelican_SwitchToBombMode:
	ld   a, $30						; Allow movement for $30(*4) frames
	ld   [sActPelicanMoveTimer], a
	ld   a, $28						; But first play the bomb throw sequence
	ld   [sActPelicanThrowTimer], a
	ret
	
; =============== Act_Pelican_OpenMouth ===============
Act_Pelican_OpenMouth:
	ld   a, SFX1_2F		; Play bomb SFX as warning
	ld   [sSFX1Set], a
	
	; Set the open mouth anim
	mActOBJLstPtrTable OBJLstPtrTable_Act_Pelican_OpenR	; Set the one when facing right
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	ret  nz						; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_Pelican_OpenL	; Set the one when facing left
	ret
; =============== Act_Pelican_CloseMouth ===============
Act_Pelican_CloseMouth:
	; Set the closed mouth anim
	mActOBJLstPtrTable OBJLstPtrTable_Act_Pelican_MoveR	; Set the one when facing right
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	ret  nz						; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_Pelican_MoveL	; Set the one when facing left
	ret
	
; =============== Act_Pelican_MoveLeft ===============
; Moves the actor 1px to the left, setting the correct anim.
Act_Pelican_MoveLeft:
	; If a solid block is in the way, stop moving and throw a bomb
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jp   nz, Act_Pelican_SwitchToBombMode
	
	ld   bc, -$01
	call ActS_MoveRight
	; Use the swimming anim
	ld   a, LOW(OBJLstPtrTable_Act_Pelican_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Pelican_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
; =============== Act_Pelican_MoveLeft ===============
; Moves the actor 1px to the right, setting the correct anim.
Act_Pelican_MoveRight:
	; If a solid block is in the way, stop moving and throw a bomb
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jp   nz, Act_Pelican_SwitchToBombMode
	
	ld   bc, +$01
	call ActS_MoveRight
	; Use the swimming anim
	ld   a, LOW(OBJLstPtrTable_Act_Pelican_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Pelican_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
; =============== Act_Pelican_MoveV ===============
; Handles vertical movement for the actor.
Act_Pelican_MoveV:

	; [TCRF] There is code to handle this outside of water,
	;        but this actor is always placed on the water surface.
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a									; Is the actor underwater?
	jp   z, Act_Pelican_UnderwaterMoveV		; If so, jump (always the case)
	
	; [TCRF] Unreachable code below.
	;
	;        This would be used when a pelican spawns in the air, to make
	;        it drop down to either solid ground or a water block.
	;
	;        Possibly due to the nature of copy/paste, it also checks for
	;        negative jump speed.
	;
	
	;
	; Check if we're standing on a solid block.
  	;
.chkSolidGround:
	; If we're moving up, we can't be standing on one
	ld   a, [sActSetYSpeed_High]
	bit  7, a								; Y Speed < 0? (moving up)
	jr   nz, .chkSolidTop					; If so, skip
.onMoveDown:
	; If there's a solid block below, do not move vertically
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a									; Solid block below?
	jr   nz, .noVMove						; If so, jump
	jr   .moveV								; Otherwise continue falling
	
	;
	; Since we're moving up, check if there's a solid block on top
  	;
.chkSolidTop:
	; If there's one, stop moving up
	call ActColi_GetBlockId_Top
	mSubCall ActBGColi_IsSolid
	or   a									; Is there a solid block above?
	jr   nz, .noVMove						; If so, jump
	
	;
	; Apply the vertical movement.
  	;
.moveV:
	ld   a, [sActSetYSpeed_Low]			; Move down by sActSetYSpeed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown
	
	; Increase the fall speed every $04 frames
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, [sActSetYSpeed_Low]			; sActSetYSpeed++
	add  $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00
	ld   [sActSetYSpeed_High], a
	ret  
	
.noVMove:
	mActSetYSpeed +$00
	ret
	; [TCRF] End of unreachable code block

; =============== Act_Pelican_UnderwaterMoveV ===============
; Handles the bob effect when moving underwater.
Act_Pelican_UnderwaterMoveV:
	; This effect is done through a table of Y offsets.
	
	; The always-incresing actor timer is used as index to this table.
	
	; Move slowly, every 4 frames
	ld   a, [sActSetTimer]
	ld   b, a
	and  a, $03
	ret  nz
	
	; Similar YPath indexing/forced range/slowdown trick to what's used in Act_Watch_Idle
	; However only one "rrca" is needed, because:
	; - This table is $10 bytes long
	; - Each entry is $02 bytes long. Avoiding the other rrca to always index
	;   the start of a word value is mandatory.
	; 
	; (Act_Pelican_UnderwaterYPath.end-Act_Pelican_UnderwaterYPath - 2) << 1 = $1C
	
	; DE = ((sActSetTimer / 2) % $08)
	ld   a, b				
	and  a, $1C			; keep in range, slowed down 2x
	rrca
	ld   d, $00
	ld   e, a
	
	ld   hl, Act_Pelican_UnderwaterYPath	; HL = Y path table
	add  hl, de				; Offset it
	
	ldi  a, [hl]			; BC = Y offset
	ld   c, a
	ld   b, [hl]			
	call ActS_MoveDown		; Move down by that
	ret
Act_Pelican_UnderwaterYPath: 
	dw +$00,+$01,+$01,+$01,+$00,-$01,-$01,-$01
.end:

; =============== Act_Pelican_SpawnBomb ===============
; This subroutine spawns a bomb thrown by the pelican.
; These bombs spawn in their thrown state, with an active countdown.
Act_Pelican_SpawnBomb:
	; Do not spawn bombs when off-screen
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
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_Bomb
	
	ld   a, $02					; Enabled
	ldi  [hl], a
	
	; Position the bomb 8px closer to the beak
	; BC = XOffset
	ld   bc, +$08			; When facing right, the beak is more to the right
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Facing right?
	jr   nz, .setX			; If so, jump
	ld   bc, -$08			; Same but for the left
	
.setX:
	ld   a, [sActSetX_Low]	; X = sActSetX + BC
	add  c
	ldi  [hl], a
	ld   a, [sActSetX_High]
	adc  a, b
	ldi  [hl], a
	
	ld   a, [sActSetY_Low]	; Y = sActSetY - $08
	sub  a, $08
	ldi  [hl], a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ldi  [hl], a
	
	; Bombs don't deal damage immediately on contact (only after they explode)
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ldi  [hl], a
	
	ld   a, -$08				; Coli box U
	ldi  [hl], a
	ld   a, -$04				; Coli box D
	ldi  [hl], a
	ld   a, -$03				; Coli box L
	ldi  [hl], a
	ld   a, +$03				; Coli box R
	ldi  [hl], a
	
	ld   a, $00					; Rel.Y (Origin)
	ldi  [hl], a
	ldi  [hl], a
	
	ld   a, LOW(OBJLstPtrTable_Act_None)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_None)
	ldi  [hl], a
	
	ld   a, [sActSetDir]		; Dir
	ldi  [hl], a
	xor  a						; OBJLst ID
	ldi  [hl], a
	
	; Actor ID.
	; We're expecting the bomb to be in the slot after
	ld   a, [sActSetId]
	inc  a
	set  ACTB_NORESPAWN, a		; Don't make the bomb respawn
	ldi  [hl], a
	
	xor  a							; Routine ID
	ldi  [hl], a
	ld   a, LOW(SubCall_Act_Bomb)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_Bomb)
	ldi  [hl], a					
	xor  a
	ldi  [hl], a					; Timer
	ldi  [hl], a					; Timer 2
	
	ld   bc, -$03					; Jump speed
	ld   a, c
	ldi  [hl], a
	ld   a, b
	ldi  [hl], a
	
	ld   a, BOMB_RTN_THROW			; Local Routine ID
	ldi  [hl], a
	ld   a, $01						; Bomb is thrown
	ldi  [hl], a
	ld   a, $96						; Countdown of $96 frames
	ldi  [hl], a
	
	ld   a, $01						; Flags
	ldi  [hl], a
	ld   a, LOW(sActDummyBlock)		; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	ld   a, LOW(OBJLstSharedPtrTable_Act_Bomb)	; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_Bomb)
	ldi  [hl], a
	ret
	
OBJLstSharedPtrTable_Act_Pelican:
	dw OBJLstPtrTable_Act_Pelican_StunL;X
	dw OBJLstPtrTable_Act_Pelican_StunR;X
	dw OBJLstPtrTable_Act_Pelican_StunL;X
	dw OBJLstPtrTable_Act_Pelican_StunR;X
	dw OBJLstPtrTable_Act_Pelican_StunL
	dw OBJLstPtrTable_Act_Pelican_StunR
	dw OBJLstPtrTable_Act_Pelican_MoveL;X
	dw OBJLstPtrTable_Act_Pelican_MoveR;X

OBJLstPtrTable_Act_Pelican_MoveL:
	dw OBJLst_Act_Pelican_MoveL0
	dw OBJLst_Act_Pelican_MoveL1
	dw $0000
OBJLstPtrTable_Act_Pelican_MoveR:
	dw OBJLst_Act_Pelican_MoveR0
	dw OBJLst_Act_Pelican_MoveR1
	dw $0000
OBJLstPtrTable_Act_Pelican_OpenL:
	dw OBJLst_Act_Pelican_OpenL
	dw $0000
OBJLstPtrTable_Act_Pelican_OpenR:
	dw OBJLst_Act_Pelican_OpenR
	dw $0000
OBJLstPtrTable_Act_Pelican_StunL:
	dw OBJLst_Act_Pelican_StunL
	dw $0000
OBJLstPtrTable_Act_Pelican_StunR:
	dw OBJLst_Act_Pelican_StunR
	dw $0000;X

OBJLst_Act_Pelican_MoveL0: INCBIN "data/objlst/actor/pelican_movel0.bin"
OBJLst_Act_Pelican_MoveL1: INCBIN "data/objlst/actor/pelican_movel1.bin"
OBJLst_Act_Pelican_OpenL: INCBIN "data/objlst/actor/pelican_openl.bin"
OBJLst_Act_Pelican_StunL: INCBIN "data/objlst/actor/pelican_stunl.bin"
OBJLst_Act_Pelican_MoveR0: INCBIN "data/objlst/actor/pelican_mover0.bin"
OBJLst_Act_Pelican_MoveR1: INCBIN "data/objlst/actor/pelican_mover1.bin"
OBJLst_Act_Pelican_OpenR: INCBIN "data/objlst/actor/pelican_openr.bin"
OBJLst_Act_Pelican_StunR: INCBIN "data/objlst/actor/pelican_stunr.bin"
GFX_Act_Pelican: INCBIN "data/gfx/actor/pelican.bin"

; =============== ActInit_StoveCanyonPlatform ===============
ActInit_StoveCanyonPlatform:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, -$08
	ld   [sActSetColiBoxD], a
	ld   a, -$0A
	ld   [sActSetColiBoxL], a
	ld   a, +$0A
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_StoveCanyonPlatform
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_StoveCanyonPlatform
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_StoveCanyonPlatform
	call ActS_SetOBJLstSharedTablePtr
	
	; Set collision type
	ld   a, ACTCOLI_TOPSOLID
	ld   [sActSetColiType], a
	
	; Start out in "var init" -> "move down" mode
	ld   a, $40
	ld   [sActStoveCanyonPlatformMoveTimer], a
	; Make the current position the upper Y limit
	; (of course the platform will have to bo
	ld   a, [sActSetRelY]
	ld   [sActStoveCanyonMinY], a
	ret
	
OBJLstPtrTable_Act_StoveCanyonPlatform:
	dw OBJLst_Act_StoveCanyonPlatform
	dw $0000;X

; =============== Act_StoveCanyonPlatform ===============
; This platform moves vertically back and forth, in this sequence:
; -< $20*4 frames moving down
; -> $20*4 frames moving up
; -> $10*4 frames standing still
; 
Act_StoveCanyonPlatform:
	
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Every 4 frames...
	and  a, $03
	ret  nz
	
	; Depending on the timer value, move up or down
	ld   a, [sActStoveCanyonPlatformMoveTimer]		; Timer2++
	inc  a
	ld   [sActStoveCanyonPlatformMoveTimer], a
	
	cp   a, $40			; Timer >= $40?
	jr   nc, .reset		; If so, jump
	cp   a, $20			; Timer >= $20?
	jr   nc, .moveUp	; If so, jump
.moveDown:
	; Move the actor down
	ld   bc, +$01
	call ActS_MoveDown
	; And move the player down as well if standing on it
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06			
	ld   b, $01
	call z, SubCall_PlBGColi_CheckGroundSolidOrMove
	ret
.moveUp:
	
	; Prevent the actor from moving up than the min allowed,
	; which would be the spawn Y pos
	ld   a, [sActSetRelY]				; B = ActorY
	ld   b, a
	ld   a, [sActStoveCanyonMinY]		; A = MinY
	cp   a, b							; Min >= ActorY?
	jr   nc, .reset						; If so, jump
	
	; Move the actor up 1px
	ld   bc, -$01
	call ActS_MoveDown
	; And move the player up as well if standing on it
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06
	ld   b, $01
	call z, SubCall_PlBGColi_DoTopAndMove
	ret
.reset:
	; Wait for $10 frames before starting to move down again
	ld   a, [sActStoveCanyonPlatformMoveTimer]
	cp   a, $50
	ret  c
	xor  a
	ld   [sActStoveCanyonPlatformMoveTimer], a
	ret
OBJLstSharedPtrTable_Act_StoveCanyonPlatform:
	dw OBJLstPtrTable_Act_StoveCanyonPlatform;X
	dw OBJLstPtrTable_Act_StoveCanyonPlatform;X
	dw OBJLstPtrTable_Act_StoveCanyonPlatform;X
	dw OBJLstPtrTable_Act_StoveCanyonPlatform;X
	dw OBJLstPtrTable_Act_StoveCanyonPlatform;X
	dw OBJLstPtrTable_Act_StoveCanyonPlatform;X
	dw OBJLstPtrTable_Act_StoveCanyonPlatform;X
	dw OBJLstPtrTable_Act_StoveCanyonPlatform;X

OBJLst_Act_StoveCanyonPlatform: INCBIN "data/objlst/actor/stovecanyonplatform.bin"
GFX_Act_StoveCanyonPlatform: INCBIN "data/gfx/actor/stovecanyonplatform.bin"

; =============== ActInit_Togemaru ===============
ActInit_Togemaru:
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, -$02
	ld   [sActSetColiBoxD], a
	ld   a, -$06
	ld   [sActSetColiBoxL], a
	ld   a, +$06
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Togemaru
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_Togemaru_Bounce
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Togemaru
	call ActS_SetOBJLstSharedTablePtr
	
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	xor  a
	ld   [sActSetTimer6], a
	ld   [sActTogemaruBounceCount], a
	; Initial jump speed -$03
	ld   [sActSetYSpeed_High], a
	ld   a, $03
	ld   [sActSetYSpeed_Low], a
	ret
	
; =============== OBJLstPtrTable_Act_Togemaru_Unused_Move_Copy ===============
; [TCRF] Unused copy of OBJLstPtrTable_Act_Togemaru_Bounce, likely meant 
;        to be used as the default sprite ("OBJLstPtrTable_ActInit").
OBJLstPtrTable_Act_Togemaru_Unused_Move_Copy:
	dw OBJLst_Act_Togemaru_Move1;X
	dw $0000;X

; =============== Act_Togemaru ===============
Act_Togemaru:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Togemaru_Main
	dw SubCall_ActS_OnPlColiH;X
	dw SubCall_ActS_OnPlColiTop;X
	dw SubCall_ActS_StartStarKill
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartDashKill
	dw Act_Togemaru_Main;X
	dw Act_Togemaru_Main
	dw SubCall_ActS_StartJumpDeadSameColi
	
; =============== Act_Togemaru_Main ===============
Act_Togemaru_Main:
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Move horizontally every 4 frames
	ld   a, [sActSetTimer]
	and  a, $03				; sActSetTimer % 4 != 0?
	jr   nz, .moveV			; If so, skip
.moveH:
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Moving right?
	call nz, .moveRight		; If so, move right
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, .moveLeft
.moveV:
	; Move vertically every frame
	call Act_Togemaru_MoveV
	ret
	
; =============== .moveRight ===============
.moveRight:
	ld   bc, +$01			; Move right 1px
	call ActS_MoveRight
	; If there's a solid block in the way, turn
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a					
	call nz, .turn
	ret
.moveLeft:
	ld   bc, -$01			; Move left 1px
	call ActS_MoveRight
	; If there's a solid block in the way, turn
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolid
	or   a
	call nz, .turn
	ret
.turn:
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ret
	
; =============== Act_Togemaru_MoveV ===============
; Handles the vertical bounce effect.
Act_Togemaru_MoveV:
	
	; If the actor is moving up, check the ceiling instead.
	ld   a, [sActSetYSpeed_High]
	bit  7, a							; YSpeed < 0?
	jr   nz, .chkTopSolid				; If so, jump
	
.chkGroundSolid:
	; If touching the solid ground, set up a new bounce
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is the actor on solid ground?
	jr   nz, .setBounce					; If so, jump
	
	; Otherwise handle the existing bounce as normal
	jr   .moveV
	
.chkTopSolid:
	; If there's a solid block above, reset the vertical speed
	call ActColi_GetBlockId_Top
	mSubCall ActBGColi_IsSolid			
	or   a								; Is there a solid block on top?
	jr   nz, .resetSpeed				; If so, jump
	
.moveV:
	; Do the vertical movement
	ld   a, [sActSetYSpeed_Low]		; BC = Y speed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown					; Move down by that
	
	; Increase Y speed every $10 frames, with no limit
	ld   a, [sActSetTimer]
	and  a, $0F
	ret  nz
	ld   a, [sActSetYSpeed_Low]		; sActSetYSpeed++
	add  $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00
	ld   [sActSetYSpeed_High], a
	
	; As soon as the vertical speed is increased, switch back to the main movement frame.
	; With this, the "bounce" frame will be visible for a few frames after landing on solid ground,
	; ($10 at most), before returning back to this for the remainder of the jump.
	mActOBJLstPtrTable OBJLstPtrTable_Act_Togemaru_Move
	ret
	
.setBounce:
	; Set up a new bounce at 2px/frame.
	; Every 4th bounce is 3px/frame. 
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_Togemaru_Bounce	; Set bouncing frame
	mActSetYSpeed -$02					; Set normal ump speed
	ld   a, [sActTogemaruBounceCount]	; BounceCount++
	inc  a
	ld   [sActTogemaruBounceCount], a
	cp   a, $03							; BounceCount < $03?
	ret  c								; If so, return
	xor  a								; Otherwise, reset the bounce counter
	ld   [sActTogemaruBounceCount], a
	mActSetYSpeed -$03					; And set the higher bounce speed
	ret
	
.resetSpeed:
	; Also use the bounce frame here, when a solid wall's on top
	mActOBJLstPtrTable OBJLstPtrTable_Act_Togemaru_Bounce
	mActSetYSpeed +$00
	ret
	
OBJLstPtrTable_Act_Togemaru_Bounce:
	dw OBJLst_Act_Togemaru_Move1
	dw $0000
OBJLstPtrTable_Act_Togemaru_Move:
	dw OBJLst_Act_Togemaru_Move0
	dw $0000
OBJLstPtrTable_Act_Togemaru_Stun:
	dw OBJLst_Act_Togemaru_Stun0
	dw OBJLst_Act_Togemaru_Stun1
	dw $0000
; [TCRF] Unused alternate stun animation.
;        It's only 1 frame long and the actor is upside down.
OBJLstPtrTable_Act_Togemaru_Unused_StunAlt:
	dw OBJLst_Act_Togemaru_Unused_StunAlt;X
	dw $0000;X

OBJLstSharedPtrTable_Act_Togemaru:
	dw OBJLstPtrTable_Act_Togemaru_Stun;X
	dw OBJLstPtrTable_Act_Togemaru_Stun;X
	dw OBJLstPtrTable_Act_Togemaru_Stun;X
	dw OBJLstPtrTable_Act_Togemaru_Stun;X
	dw OBJLstPtrTable_Act_Togemaru_Stun
	dw OBJLstPtrTable_Act_Togemaru_Stun
	dw OBJLstPtrTable_Act_Togemaru_Stun;X
	dw OBJLstPtrTable_Act_Togemaru_Stun;X

OBJLst_Act_Togemaru_Move0: INCBIN "data/objlst/actor/togemaru_move0.bin"
OBJLst_Act_Togemaru_Move1: INCBIN "data/objlst/actor/togemaru_move1.bin"
OBJLst_Act_Togemaru_Stun0: INCBIN "data/objlst/actor/togemaru_stun0.bin"
OBJLst_Act_Togemaru_Unused_StunAlt: INCBIN "data/objlst/actor/togemaru_unused_stunalt.bin"
OBJLst_Act_Togemaru_Stun1: INCBIN "data/objlst/actor/togemaru_stun1.bin"
GFX_Act_Togemaru: INCBIN "data/gfx/actor/togemaru.bin"

; =============== ActInit_Croc ===============
; Crocodile moving near the water surface that jumps up when you get close.
ActInit_Croc:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, $F0
	ld   [sActSetColiBoxU], a
	ld   a, $FC
	ld   [sActSetColiBoxD], a
	ld   a, $FC
	ld   [sActSetColiBoxL], a
	ld   a, $04
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Croc
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_Croc_MoveL
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Croc
	call ActS_SetOBJLstSharedTablePtr
	
	xor  a
	ld   [sActCrocJumpTimer], a
	ld   [sActSetTimer7], a
	ld   a, ACTCOLI_TOPSOLIDHIT
	ld   [sActSetColiType], a
	ld   a, $10
	ld   [sActCrocJumpDelay], a
	mSubCall ActS_SaveColiType ; BANK $02
	ret
	
; =============== Act_Croc ===============
Act_Croc:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Croc_Main
	dw SubCall_ActInitS_StunFloatingPlatform
	dw SubCall_ActInitS_StunFloatingPlatform;X
	dw SubCall_ActS_StartStarKill
	dw SubCall_ActInitS_StunFloatingPlatform;X
	dw SubCall_ActS_StartDashKill
	dw Act_Croc_Main
	dw Act_Croc_Main
	dw SubCall_ActInitS_StunFloatingPlatform;X
	
; =============== Act_Croc_Main ===============
Act_Croc_Main:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	call Act_Croc_DoActions
	
	; Animate every $10 frames
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .moveV
	ld   a, [sActSetOBJLstId]	; AnimFrame++
	inc  a
	ld   [sActSetOBJLstId], a
.moveV:
	call Act_Croc_MoveV
	ret
	
; =============== Act_Croc_DoActions ===============
; Handle actor movement and position checks.
Act_Croc_DoActions:
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	; Actions are handled in sequence through two decrementing timers.
	; This actor goes between two phases:
	; - Jimping up
	;   When sActCrocJumpTimer is != 0.
	; - Movement
	;   When sActCrocJumpTimer is 0. The actor will jump up when the player gets
	;   close enough, but only when the cooldown timer sActCrocJumpDelay elapses.
	;
	
	
.chkJumpMode:
	ld   a, [sActCrocJumpTimer]
	or   a						; JumpTimer == 0?
	jr   z, .chkTrackMode		; If so, we aren't jumping
	dec  a
	ld   [sActCrocJumpTimer], a
	
	;
	; Handle the sequence for animating the jump.
	;
	ld   a, [sActCrocJumpTimer]
	cp   a, $1E
	jr   z, Act_Croc_OpenMouth
	ld   a, [sActCrocJumpTimer]
	cp   a, $16
	jp   z, Act_Croc_Jump
	ld   a, [sActCrocJumpTimer]
	cp   a, $0F
	jp   z, Act_Croc_JumpDown
	
	; After the jump ends, wait for a few frames before turning around
	ld   a, [sActCrocJumpTimer]
	cp   a, $01
	ret  nz
.end:
	; Turn after the jump ends
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ld   a, $30					; Cooldown timer of $30 before another jump
	ld   [sActCrocJumpDelay], a
	ld   a, SFX4_10
	ld   [sSFX4Set], a
	ret
	
.chkTrackMode:
	; Make sure there's a cooldown timer between jumps.
	; After it elapses, the actor will jump as soon as the player gets in range.
	ld   a, [sActCrocJumpDelay]
	or   a						; Is the timer elapsed yet?
	jr   nz, .moveH				; If so, skip
	ld   a, [sActSetX_Low]		; HL = Actor X pos
	ld   l, a
	ld   a, [sActSetX_High]
	ld   h, a
	ld   a, [sPlX_Low]			; BC = Player X pos
	ld   c, a
	ld   a, [sPlX_High]
	ld   b, a
	call ActS_GetPlDistance		; HL = Distance between ActX and PlX
	ld   a, l
	cp   a, $30					; HL < $30?
	jr   c, .switchToJump		; If so, jump up
	
	; Otherwise, continue moving as normal.
	; Skip ahead .moveH to avoid underflowing the delay (that would be bad).
	jr   .moveH2				
.moveH:
	;
	; Otherwise, move horizontally depending on the actor's current direction.
	;
	ld   a, [sActCrocJumpDelay]		; Delay--
	dec  a
	ld   [sActCrocJumpDelay], a
.moveH2:
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Moving right?
	jp   nz, Act_Croc_MoveRight	; If so, jump
	bit  DIRB_L, a				; Moving left?
	jp   nz, Act_Croc_MoveLeft	; If so, jump
	ret ; We never get here
.switchToJump:
	ld   a, $28
	ld   [sActCrocJumpTimer], a
	ld   a, SFX4_11
	ld   [sSFX4Set], a
	ret
	
; =============== Act_Croc_Unused_Turn ===============
; [TCRF] Unreferenced code. 
;        Likely the original entry point for the subroutine Act_Croc_Turn.
;        If this were used, the actor wouldn't be able to move for a bit 
;        after turning, which would have been a problem in C26 as some
;        crocodiles are placed in two block wide gaps.
Act_Croc_Unused_Turn:
	ld   a, $30					; Cooldown timer of $30 before another jump
	ld   [sActCrocJumpDelay], a
; =============== Act_Croc_Turn ===============
Act_Croc_Turn:
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ret
; =============== Act_Croc_OpenMouth ===============
Act_Croc_OpenMouth:
	ld   a, $2F					; Play SFX
	ld   [sSFX1Set], a
	
	; Make upwards part (teeth) hurt on touch already
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI		
	ld   [sActSetColiType], a
		
	; Prepare the jump (up) anim
	mActOBJLstPtrTable OBJLstPtrTable_Act_Croc_MouthOpenR
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	ret  nz						; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_Croc_MouthOpenL
	ret
	
; =============== Act_Croc_Jump ===============
Act_Croc_Jump:
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Send out the actual jump command, with initial speed of 5px/frame.
	mActSetYSpeed -$05
	
	; Set open mouth jump anim
	mActOBJLstPtrTable OBJLstPtrTable_Act_Croc_JumpUpR
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	ret  nz						; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_Croc_JumpUpL
	ret
	
; =============== Act_Croc_JumpDown ===============
Act_Croc_JumpDown:
	; Return to the original collision type once moving down
	ld   a, ACTCOLI_TOPSOLIDHIT
	ld   [sActSetColiType], a
	
	; Set open mouth jump anim
	mActOBJLstPtrTable OBJLstPtrTable_Act_Croc_JumpDownR
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	ret  nz						; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_Croc_JumpDownL
	ret
	
; =============== Act_Croc_MoveLeft ===============
; Moves the actor 1px to the left, setting the correct anim.
Act_Croc_MoveLeft:
	; If a solid block is in the way, turn right
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jp   nz, Act_Croc_Turn
	
	ld   bc, -$01
	call ActS_MoveRight
	; Set swim anim
	ld   a, LOW(OBJLstPtrTable_Act_Croc_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Croc_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
; =============== Act_Croc_MoveRight ===============
; Moves the actor 1px to the right, setting the correct anim.
Act_Croc_MoveRight:
	; If a solid block is in the way, turn left
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jp   nz, Act_Croc_Turn
	
	ld   bc, +$01
	call ActS_MoveRight
	; Set swim anim
	ld   a, LOW(OBJLstPtrTable_Act_Croc_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Croc_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
; =============== Act_Croc_MoveV ===============
Act_Croc_MoveV:
	
	; If the actor is moving up, don't treat it as underwater since it won't matter.
	; Instead, just handle the current jump.
	ld   a, [sActSetYSpeed_High]
	bit  7, a								; Speed < 0?							
	jr   nz, .doJump						; If so, jump
	
	; Once it's either moving down or not moving at all, check if the actor's underwater.
	; If it isn't, we're still in the middle of the jump.
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a									; Is the actor on a water block?
	jp   z, Act_Croc_UnderwaterMoveV							; If so, jump
	jr   .doJump							; heh
.doJump:
	call ActS_FallDownMax4Speed
	ret
; =============== .unused_noVMove ===============
; [TCRF] Unreferenced code, likely leftover from Act_Pelican_MoveV.
.unused_noVMove:
	mActSetYSpeed +$00
	ret
; =============== Act_Croc_UnderwaterMoveV ===============
; Handles the bob effect when moving underwater, completely identical to Act_Pelican_UnderwaterMoveV.
Act_Croc_UnderwaterMoveV:
	; This effect is done through a table of Y offsets.
	; The always-incresing actor timer is used as index to this table.
	
	; Move slowly, every 4 frames
	ld   a, [sActSetTimer]
	ld   b, a
	and  a, $03
	ret  nz
	
	; Similar YPath indexing/forced range/slowdown trick to what's used in Act_Watch_Idle
	; However only one "rrca" is needed, because:
	; - This table is $10 bytes long
	; - Each entry is $02 bytes long. Avoiding the other rrca to always index
	;   the start of a word value is mandatory.
	; 
	; (Act_Croc_UnderwaterYPath.end-Act_Croc_UnderwaterYPath - 2) << 1 = $1C
	
	; DE = ((sActSetTimer / 2) % $08)
	ld   a, b				
	and  a, $1C			; keep in range, slowed down 2x
	rrca
	ld   d, $00
	ld   e, a
	
	ld   hl, Act_Croc_UnderwaterYPath	; HL = Y path table
	add  hl, de				; Offset it
	
	ldi  a, [hl]			; BC = Y offset
	ld   c, a
	ld   b, [hl]			
	call ActS_MoveDown		; Move down by that
	ret
Act_Croc_UnderwaterYPath: 
	dw +$00,+$01,+$01,+$01,+$00,-$01,-$01,-$01
.end:
OBJLstSharedPtrTable_Act_Croc:
	dw OBJLstPtrTable_Act_Croc_StunL;X
	dw OBJLstPtrTable_Act_Croc_StunR;X
	dw OBJLstPtrTable_Act_Croc_StunL;X
	dw OBJLstPtrTable_Act_Croc_StunR;X
	dw OBJLstPtrTable_Act_Croc_StunL
	dw OBJLstPtrTable_Act_Croc_StunR
	dw OBJLstPtrTable_Act_Croc_MoveL;X
	dw OBJLstPtrTable_Act_Croc_MoveR;X

OBJLstPtrTable_Act_Croc_MoveL:
	dw OBJLst_Act_Croc_MoveL0
	dw OBJLst_Act_Croc_MoveL1
	dw OBJLst_Act_Croc_MoveL0
	dw OBJLst_Act_Croc_MoveL2
	dw $0000
OBJLstPtrTable_Act_Croc_MoveR:
	dw OBJLst_Act_Croc_MoveR0
	dw OBJLst_Act_Croc_MoveR1
	dw OBJLst_Act_Croc_MoveR0
	dw OBJLst_Act_Croc_MoveR2
	dw $0000
OBJLstPtrTable_Act_Croc_MouthOpenL:
	dw OBJLst_Act_Croc_MouthOpenL
	dw $0000
OBJLstPtrTable_Act_Croc_MouthOpenR:
	dw OBJLst_Act_Croc_MouthOpenR
	dw $0000
OBJLstPtrTable_Act_Croc_JumpUpL:
	dw OBJLst_Act_Croc_JumpUpL
	dw $0000
OBJLstPtrTable_Act_Croc_JumpUpR:
	dw OBJLst_Act_Croc_JumpUpR
	dw $0000
OBJLstPtrTable_Act_Croc_JumpDownL:
	dw OBJLst_Act_Croc_JumpDownL
	dw $0000
OBJLstPtrTable_Act_Croc_JumpDownR:
	dw OBJLst_Act_Croc_JumpDownR
	dw $0000
; [TCRF] Unused animation. Variant of OBJLstPtrTable_Act_Croc_Stun* except not upside down.
OBJLstPtrTable_Act_Croc_Unused_StunAltL:
	dw OBJLst_Act_Croc_Unused_StunAltL;X
	dw $0000;X
OBJLstPtrTable_Act_Croc_Unused_StunAltR:
	dw OBJLst_Act_Croc_Unused_StunAltR;X
	dw $0000;X
OBJLstPtrTable_Act_Croc_StunL:
	dw OBJLst_Act_Croc_StunL
	dw $0000;X
OBJLstPtrTable_Act_Croc_StunR:
	dw OBJLst_Act_Croc_StunR
	dw $0000;X

OBJLst_Act_Croc_MoveL0: INCBIN "data/objlst/actor/croc_movel0.bin"
OBJLst_Act_Croc_MoveL1: INCBIN "data/objlst/actor/croc_movel1.bin"
OBJLst_Act_Croc_MoveL2: INCBIN "data/objlst/actor/croc_movel2.bin"
OBJLst_Act_Croc_MouthOpenL: INCBIN "data/objlst/actor/croc_mouthopenl.bin"
OBJLst_Act_Croc_JumpUpL: INCBIN "data/objlst/actor/croc_jumpupl.bin"
OBJLst_Act_Croc_Unused_StunAltL: INCBIN "data/objlst/actor/croc_unused_stunaltl.bin"
OBJLst_Act_Croc_StunL: INCBIN "data/objlst/actor/croc_stunl.bin"
OBJLst_Act_Croc_JumpDownL: INCBIN "data/objlst/actor/croc_jumpdownl.bin"
OBJLst_Act_Croc_MoveR0: INCBIN "data/objlst/actor/croc_mover0.bin"
OBJLst_Act_Croc_MoveR1: INCBIN "data/objlst/actor/croc_mover1.bin"
OBJLst_Act_Croc_MoveR2: INCBIN "data/objlst/actor/croc_mover2.bin"
OBJLst_Act_Croc_MouthOpenR: INCBIN "data/objlst/actor/croc_mouthopenr.bin"
OBJLst_Act_Croc_JumpUpR: INCBIN "data/objlst/actor/croc_jumpupr.bin"
OBJLst_Act_Croc_Unused_StunAltR: INCBIN "data/objlst/actor/croc_unused_stunaltr.bin"
OBJLst_Act_Croc_StunR: INCBIN "data/objlst/actor/croc_stunr.bin"
OBJLst_Act_Croc_JumpDownR: INCBIN "data/objlst/actor/croc_jumpdownr.bin"
GFX_Act_Croc: INCBIN "data/gfx/actor/croc.bin"

; =============== ActInit_Spider ===============
ActInit_Spider:
	; Setup collision box
	ld   a, $F2
	ld   [sActSetColiBoxU], a
	ld   a, $FE
	ld   [sActSetColiBoxD], a
	ld   a, $FA
	ld   [sActSetColiBoxL], a
	ld   a, $06
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Spider
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_Spider_MoveD
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Spider
	call ActS_SetOBJLstSharedTablePtr
	
	; Default to defeatable both up and down.
	; The proper damaging side will be set later on.
	mActColiMask ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	ld   a, DIR_D
	ld   [sActSetDir], a
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSpiderTurnDelay], a
	ret
	
; =============== Act_Spider ===============
Act_Spider:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Spider_Main
	dw SubCall_ActS_StartJumpDead;X
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartStarKill
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartDashKill
	dw Act_Spider_Main;X
	dw Act_Spider_Main
	dw SubCall_ActS_StartJumpDead
	
; =============== Act_Spider_Main ===============
Act_Spider_Main:
	; If the actor is waiting to move, decrement the timer instead.
	ld   a, [sActSpiderTurnDelay]
	or   a						
	jr   nz, .waitTurn
	;--
	
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	; Move vertically as specified
	ld   a, [sActSetDir]
	bit  DIRB_D, a
	jp   nz, Act_Spider_MoveDown
	ld   a, [sActSetDir]
	bit  DIRB_U, a
	jp   nz, Act_Spider_MoveUp
	ret ; [POI] We never get here
.waitTurn:
	dec  a
	ld   [sActSpiderTurnDelay], a
	ret
	
; =============== Act_Spider_MoveUp ===============
; Moves the actor up at 0.5px/frame.
Act_Spider_MoveUp:
	; Set animation
	ld   a, LOW(OBJLstPtrTable_Act_Spider_MoveU)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Spider_MoveU)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	; Make the actor stop when there's no ladder block above
	call ActColi_GetBlockId_Top		; A = Block ID above
	cp   a, BLOCKID_LADDER			; Is it a ladder body block?
	jr   z, .move					; If so, move
	cp   a, BLOCKID_LADDERTOP		; Is it a ladder top block?
	jr   z, .move					; If so, move
	jr   Act_Spider_SetTurnDelay	; Otherwise, stop moving
.move:
	ld   bc, -$01
	call ActS_MoveDown
	; Set damaging part above
	mActColiMask ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI				
	ld   [sActSetColiType], a
	ret
; =============== Act_Spider_MoveDown ===============
; Moves the actor down at 0.5px/frame.
Act_Spider_MoveDown:
	; Set animation
	ld   a, LOW(OBJLstPtrTable_Act_Spider_MoveD)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Spider_MoveD)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	; Make the actor stop when there's no ladder block below
	call ActColi_GetBlockId_Ground	; A = Block ID above
	cp   a, BLOCKID_LADDER			; Is it a ladder body block?
	jr   z, .move					; If so, move
	cp   a, BLOCKID_LADDERTOP		; Is it a ladder top block?
	jr   z, .move					; If so, move
	jr   Act_Spider_SetTurnDelay	; Otherwise, stop moving
.move:
	ld   bc, +$01
	call ActS_MoveDown
	; Set damaging part below
	mActColiMask ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_NORM, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_Spider_SetTurnDelay ===============
Act_Spider_SetTurnDelay:
	; This is a bit weirdly structured.
	; When the actor reaches the end of a ladder, it immediately switches direction but does
	; nothing else, other than setting a delay before moving again.
	;
	; Since the subroutines which move the actor are the only place that set the collision type
	; and animation, the actor visually stops in the previous direction.
	;
	; When the delay elapses and the actor moves again, only then it will visibly turn.
	; (it's why Act_Spider_MoveDown and Act_Spider_MoveUp set the collision type/anim all the time)
	ld   a, [sActSetDir]	; Turn immediately (doesn't take effect until we're moving again)
	xor  DIR_U|DIR_D
	ld   [sActSetDir], a
	ld   a, $1E				; Wait for $1E frames before moving again
	ld   [sActSpiderTurnDelay], a
	ret
OBJLstPtrTable_Act_Spider_MoveD:
	dw OBJLst_Act_Spider_MoveD0
	dw OBJLst_Act_Spider_MoveD1
	dw $0000
OBJLstPtrTable_Act_Spider_MoveU:
	dw OBJLst_Act_Spider_MoveU0
	dw OBJLst_Act_Spider_MoveU1
	dw $0000
; [TCRF] Unused alternate variant of OBJLstPtrTable_Act_Spider_Stun, with the spider facing down.
OBJLstPtrTable_Act_Spider_Unused_StunAlt:
	dw OBJLst_Act_Spider_Unused_StunAlt;X
	dw $0000;X
OBJLstPtrTable_Act_Spider_Stun:
	dw OBJLst_Act_Spider_Stun
	dw $0000

OBJLstSharedPtrTable_Act_Spider:
	dw OBJLstPtrTable_Act_Spider_Stun;X
	dw OBJLstPtrTable_Act_Spider_Stun;X
	dw OBJLstPtrTable_Act_Spider_Stun;X
	dw OBJLstPtrTable_Act_Spider_Stun;X
	dw OBJLstPtrTable_Act_Spider_Stun
	dw OBJLstPtrTable_Act_Spider_Stun;X
	dw OBJLstPtrTable_Act_Spider_Stun;X
	dw OBJLstPtrTable_Act_Spider_Stun;X

OBJLst_Act_Spider_MoveD0: INCBIN "data/objlst/actor/spider_moved0.bin"
OBJLst_Act_Spider_MoveD1: INCBIN "data/objlst/actor/spider_moved1.bin"
OBJLst_Act_Spider_Unused_StunAlt: INCBIN "data/objlst/actor/spider_unused_stunalt.bin"
OBJLst_Act_Spider_MoveU0: INCBIN "data/objlst/actor/spider_moveu0.bin"
OBJLst_Act_Spider_MoveU1: INCBIN "data/objlst/actor/spider_moveu1.bin"
OBJLst_Act_Spider_Stun: INCBIN "data/objlst/actor/spider_stun.bin"
GFX_Act_Spider: INCBIN "data/gfx/actor/spider.bin"

; =============== ActInit_FireMissile ===============
; Horizontal fireball thrown by eagle-like blocks in Syrup Castle.
ActInit_FireMissile:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$08
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$02
	ld   [sActSetColiBoxL], a
	ld   a, +$02
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_FireMissile
	call ActS_SetCodePtr
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_FireMissile
	call ActS_SetOBJLstSharedTablePtr
	
	; Fireball should be intangible when it isn't shot yet
	xor  a
	ld   [sActSetColiType], a
	
	
	xor  a
	ld   [sActSetTimer], a			; Not used
	ld   [sActFireMissileModeTimer], a
	ld   [sActSetTimer3], a			; Not used
	ld   [sActSetTimer4], a			; Not used
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer6], a			; Not used
	ld   [sActSetTimer7], a			; Not used
	
	
	; When spawning an actor, the actor spawner sets its direction to make it face the player.
	; This is fine for most actors, but not for this one.
	
	; So we need to determine the actor's direction for two reasons:
	; - This actor is always placed on an empty block right next to an eagle (solid) block.
	;   It should not move towards the solid block.
	; - It needs adjustment to move it 8px closer to the eagle block.
.setL:
	; Start by setting the left-facing options
	; (Could have been moved to .setLOff)
	mActOBJLstPtrTable OBJLstPtrTable_Act_FireMissile_WarnL		
	ld   a, DIR_L
	ld   [sActSetDir], a
	
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block on the right?
	jr   nz, .setLOff					; If so, we set the correct direction
.setR:
	; Otherwise face right
	mActOBJLstPtrTable OBJLstPtrTable_Act_FireMissile_WarnR			
	ld   a, DIR_R
	ld   [sActSetDir], a
	; Adjust 8px closer to the solid block
	ld   bc, -$08
	call ActS_MoveRight
	ret
.setLOff:
	; Adjust 8px closer to the solid block
	ld   bc, +$08
	call ActS_MoveRight
	ret
	
OBJLstPtrTable_Act_FireMissile_WarnL:
	dw OBJLst_Act_FireMissile_WarnL0
	dw OBJLst_Act_FireMissile_WarnL1
	dw $0000
OBJLstPtrTable_Act_FireMissile_WarnR:
	dw OBJLst_Act_FireMissile_WarnR0
	dw OBJLst_Act_FireMissile_WarnR1
	dw $0000
OBJLstPtrTable_Act_FireMissile_MoveL:
	dw OBJLst_Act_FireMissile_MoveL0
	dw OBJLst_Act_FireMissile_MoveL1
	dw $0000
OBJLstPtrTable_Act_FireMissile_MoveR:
	dw OBJLst_Act_FireMissile_MoveR0
	dw OBJLst_Act_FireMissile_MoveR1
	dw $0000
OBJLstPtrTable_Act_FireMissile_SolidHit0L:
	dw OBJLst_Act_FireMissile_SolidHit0_L0
	dw OBJLst_Act_FireMissile_SolidHit0_L1
	dw $0000;X
OBJLstPtrTable_Act_FireMissile_SolidHit0R:
	dw OBJLst_Act_FireMissile_SolidHit0_R0
	dw OBJLst_Act_FireMissile_SolidHit0_R1
	dw $0000;X
OBJLstPtrTable_Act_FireMissile_SolidHit1L:
	dw OBJLst_Act_FireMissile_SolidHit1_L0
	dw OBJLst_Act_FireMissile_SolidHit1_L1
	dw $0000
OBJLstPtrTable_Act_FireMissile_SolidHit1R:
	dw OBJLst_Act_FireMissile_SolidHit1_R0
	dw OBJLst_Act_FireMissile_SolidHit1_R1
	dw $0000

; =============== ActInit_FireMissile ===============
Act_FireMissile:
	; Animate every 4 global frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkRoutine
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.chkRoutine:

	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_FireMissile_Warn
	dw Act_FireMissile_Move
	dw Act_FireMissile_SolidHit0
	dw Act_FireMissile_SolidHit1
	dw Act_FireMissile_MoveBack
	dw Act_FireMissile_Wait
	
; =============== Act_FireMissile_SwitchToWarn ===============
; Resets back to the warning mode.
Act_FireMissile_SwitchToWarn:
	ld   a, FRM_RTN_WARN
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActFireMissileModeTimer], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_FireMissile_WarnR	; Set the one when facing right first
	ld   a, [sActSetDir]
	bit  DIRB_R, a					; Facing right?
	ret  nz							; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_FireMissile_WarnL	; Set the one when facing left
	ret
	
; =============== Act_FireMissile_Warn ===============
; Mode $00: Warning SFX before shooting.
Act_FireMissile_Warn:
	ld   a, [sActFireMissileModeTimer]
	inc  a
	ld   [sActFireMissileModeTimer], a
	cp   a, $1E							; Timer >= $1E?
	jr   nc, .nextMode					; If so, jump
	
	; Play warning SFX every 4 frames
	ld   a, [sActFireMissileModeTimer]
	and  a, $03
	ret  nz
	ld   a, SFX1_13
	ld   [sSFX1Set], a
	ret
.nextMode:
	ld   a, SFX4_07		; Play shoot sfx
	ld   [sSFX4Set], a
	
	ld   a, FRM_RTN_MOVE			; Next mode
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActFireMissileModeTimer], a
	; Make it hurt on touch
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_FireMissile_MoveR	; Set the one when facing right first
	ld   a, [sActSetDir]
	bit  DIRB_R, a					; Facing right?
	ret  nz							; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_FireMissile_MoveL	; Set the one when facing left
	ret
	
; =============== Act_FireMissile_Move ===============
; Mode $01: Moves horizontally at 2px/frame, until reaching a solid block.
Act_FireMissile_Move:
	; Move depending on the direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, .moveR
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	jr   nz, .moveL
	ret ; [POI] We never get here
	
.moveR:
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is there a solid block on the right?
	jr   nz, .nextMode				; If so, stop moving	
	ld   bc, +$02
	call ActS_MoveRight
	ret
.moveL:
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is there a solid block on the left?
	jr   nz, .nextMode				; If so, stop moving
	ld   bc, -$02
	call ActS_MoveRight
	ret
.nextMode:
	ld   a, FRM_RTN_SOLIDHIT0
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActFireMissileModeTimer], a
	ld   [sActSetColiType], a		; Make intangible again
	
	; Set block hit anim 1
	mActOBJLstPtrTable OBJLstPtrTable_Act_FireMissile_SolidHit0R	; Set the one when facing right first
	ld   a, [sActSetDir]
	bit  DIRB_R, a					; Facing right?
	ret  nz							; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_FireMissile_SolidHit0L	; Set the one when facing left
	ret
	
; =============== Act_FireMissile_SolidHit0 ===============
; Mode $02: Waits for a bit after hitting the block.
;
; Used alongside Mode $03 to show the full block-hit anim, which is made of two separate animations.
; This mode plays the first part, with mode $03 playing the second part.
Act_FireMissile_SolidHit0:
	; Wait for $05 frames in the previously set anim
	ld   a, [sActFireMissileModeTimer]	; Timer++
	inc  a
	ld   [sActFireMissileModeTimer], a
	cp   a, $05							; Timer >= $05?
	jr   nc, .nextMode					; If so, jump
	ret
.nextMode:
	ld   a, FRM_RTN_SOLIDHIT1
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActFireMissileModeTimer], a
	ld   [sActSetColiType], a			; (not needed, copy/paste wins again)
	
	; Set block hit anim 2
	mActOBJLstPtrTable OBJLstPtrTable_Act_FireMissile_SolidHit1R	; Set the one when facing right first
	ld   a, [sActSetDir]
	bit  DIRB_R, a					; Facing right?
	ret  nz							; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_FireMissile_SolidHit1L	; Set the one when facing left
	ret
; =============== Act_FireMissile_SolidHit1 ===============
; Mode $03: Waits for a bit after hitting the block.
Act_FireMissile_SolidHit1:
	; Wait for $0A frames
	ld   a, [sActFireMissileModeTimer]
	inc  a
	ld   [sActFireMissileModeTimer], a
	cp   a, $0A
	jr   nc, .nextMode
	ret
.nextMode:
	ld   a, FRM_RTN_MOVEBACK
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActFireMissileModeTimer], a
	ld   [sActSetColiType], a		; Not needed
	; Hide while moving back
	mActS_SetBlankFrame
	ret
	
; =============== Act_FireMissile_MoveBack ===============
; Mode $04: Moves the flame gradually back to the solid block.
;
; [TCRF] The way this is done is... really weird.
;        Instead of just saving the original coordinates during init
;        and restoring those, every frame we move back the (hidden, intangible)
;        fireball at a fast 4px/frame.
;        This also does mean the longer the fireball travelled, the longer it will
;        take to move back... not like it matters at all though, since chances are,
;        it will despawn anyway!
;
;        Was the fireball supposed to bounce back on walls, and still hurt the player?
Act_FireMissile_MoveBack:
	; Move the opposite way we're facing
	ld   a, [sActSetDir]
	bit  DIRB_L, a			; Facing left?
	jr   nz, .moveR			; If so, move right
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Facing right?
	jr   nz, .moveL			; If so, move left
	ret ; [POI] We never get here
.moveR:
	; Both use ActColi_GetBlockId_Low instead of ActColi_GetBlockId_LowR or ActColi_GetBlockId_LowL
	; to take advantage of how the actor's origin is at the center of the actor.
	; By moving 4px at a time, we eventually land back at the correct "8px offsetted" position.
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is there a solid block on the right?
	jr   nz, .nextMode				; If so, stop moving	
	ld   bc, +$04
	call ActS_MoveRight
	ret
.moveL:
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is there a solid block on the left?
	jr   nz, .nextMode				; If so, stop moving
	ld   bc, -$04
	call ActS_MoveRight
	ret
.nextMode:
	ld   a, FRM_RTN_WAIT
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActFireMissileModeTimer], a
	mActS_SetBlankFrame
	ret
	
; =============== Act_FireMissile_Wait ===============
; Mode $05: Waits $1E before preparing to fire again.	
Act_FireMissile_Wait:
	ld   a, [sActFireMissileModeTimer]
	inc  a
	ld   [sActFireMissileModeTimer], a
	cp   a, $1E
	jp   nc, Act_FireMissile_SwitchToWarn
	ret
	
OBJLstSharedPtrTable_Act_FireMissile:
	dw OBJLstPtrTable_Act_FireMissile_MoveL;X
	dw OBJLstPtrTable_Act_FireMissile_MoveR;X
	dw OBJLstPtrTable_Act_FireMissile_MoveL;X
	dw OBJLstPtrTable_Act_FireMissile_MoveR;X
	dw OBJLstPtrTable_Act_FireMissile_MoveL;X
	dw OBJLstPtrTable_Act_FireMissile_MoveR;X
	dw OBJLstPtrTable_Act_FireMissile_MoveL;X
	dw OBJLstPtrTable_Act_FireMissile_MoveR;X

OBJLst_Act_FireMissile_WarnL0: INCBIN "data/objlst/actor/firemissile_warnl0.bin"
OBJLst_Act_FireMissile_WarnL1: INCBIN "data/objlst/actor/firemissile_warnl1.bin"
OBJLst_Act_FireMissile_MoveL0: INCBIN "data/objlst/actor/firemissile_movel0.bin"
OBJLst_Act_FireMissile_MoveL1: INCBIN "data/objlst/actor/firemissile_movel1.bin"
OBJLst_Act_FireMissile_SolidHit0_L0: INCBIN "data/objlst/actor/firemissile_solidhit0_l0.bin"
OBJLst_Act_FireMissile_SolidHit0_L1: INCBIN "data/objlst/actor/firemissile_solidhit0_l1.bin"
OBJLst_Act_FireMissile_SolidHit1_L0: INCBIN "data/objlst/actor/firemissile_solidhit1_l0.bin"
OBJLst_Act_FireMissile_SolidHit1_L1: INCBIN "data/objlst/actor/firemissile_solidhit1_l1.bin"
OBJLst_Act_FireMissile_WarnR0: INCBIN "data/objlst/actor/firemissile_warnr0.bin"
OBJLst_Act_FireMissile_WarnR1: INCBIN "data/objlst/actor/firemissile_warnr1.bin"
OBJLst_Act_FireMissile_MoveR0: INCBIN "data/objlst/actor/firemissile_mover0.bin"
OBJLst_Act_FireMissile_MoveR1: INCBIN "data/objlst/actor/firemissile_mover1.bin"
OBJLst_Act_FireMissile_SolidHit0_R0: INCBIN "data/objlst/actor/firemissile_solidhit0_r0.bin"
OBJLst_Act_FireMissile_SolidHit0_R1: INCBIN "data/objlst/actor/firemissile_solidhit0_r1.bin"
OBJLst_Act_FireMissile_SolidHit1_R0: INCBIN "data/objlst/actor/firemissile_solidhit1_r0.bin"
OBJLst_Act_FireMissile_SolidHit1_R1: INCBIN "data/objlst/actor/firemissile_solidhit1_r1.bin"
GFX_Act_FireMissile: INCBIN "data/gfx/actor/firemissile.bin"

; =============== END OF BANK ===============
	mIncJunk "L1B7C49"
