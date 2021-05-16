;
; BANK $15 - Actor code
;
; =============== ActInit_DoorFrame ===============
; The door frame is a special actor meant to be used in rooms where the BG priority flag is set.
; For example, in C09 it's placed over door tiles behind waterfalls (which go in front of the player).
; Doing this the normal way wouldn't have been with the limit of 4 animated tiles.
ActInit_DoorFrame:
	; Setup collision box
	; [TCRF] Fairly pointless since it can't be interacted with, but here it is.
	ld   a, -$30
	ld   [sActSetColiBoxU], a
	ld   a, -$10
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_DoorFrame
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_DoorFrame
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_DoorFrame
	call ActS_SetOBJLstSharedTablePtr
	
	; Set collision type
	xor  a
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	ret
	
OBJLstPtrTable_Act_DoorFrame:
	dw OBJLst_Act_DoorFrame
	dw $0000;X

Act_DoorFrame:;I
	; Yeah. Could have been omitted but oh well.
	ld   a, LOW(OBJLstPtrTable_Act_DoorFrame)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_DoorFrame)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
OBJLstSharedPtrTable_Act_DoorFrame:
	dw OBJLstPtrTable_Act_DoorFrame;X
	dw OBJLstPtrTable_Act_DoorFrame;X
	dw OBJLstPtrTable_Act_DoorFrame;X
	dw OBJLstPtrTable_Act_DoorFrame;X
	dw OBJLstPtrTable_Act_DoorFrame;X
	dw OBJLstPtrTable_Act_DoorFrame;X
	dw OBJLstPtrTable_Act_DoorFrame;X
	dw OBJLstPtrTable_Act_DoorFrame;X

OBJLst_Act_DoorFrame: INCBIN "data/objlst/actor/doorframe.bin"
GFX_Act_DoorFrame: INCBIN "data/gfx/actor/doorframe.bin"

; =============== ActInit_CoinLock ===============
; The skull lock at the end of every level.
ActInit_CoinLock:
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
	ld   bc, SubCall_Act_CoinLock
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_CoinLock_Closed
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_CoinLock
	call ActS_SetOBJLstSharedTablePtr
	
	; Set collision type
	ld   a, ACTCOLI_LOCK
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	; Is the lock marked as already opened (from actor group) or was opened beforehand (put a coin in already)?
	ld   a, [sLvlExitDoor]		
	ld   [sActLocalRoutineId], a
	or   a						; Already open?
	ret  z						; If not, return
.instaOpen:
	ld   bc, -$19				; Move lock out of the way
	call ActS_MoveDown
	ld   a, LOCK_OPEN		; Set the door status as already open
	ld   [sLvlExitDoor], a
	ld   [sActLocalRoutineId], a
	
	push bc						; Update OBJLst (since its eyes glow once open)
	ld   bc, OBJLstPtrTable_Act_CoinLock_Open
	call ActS_SetOBJLstPtr
	pop  bc
	
	xor  a						; Make intangible
	ld   [sActSetColiType], a
	ret
	
OBJLstPtrTable_Act_CoinLock_Closed:
	dw OBJLst_Act_CoinLock0
	dw $0000;X
OBJLstPtrTable_Act_CoinLock_Open:
	dw OBJLst_Act_CoinLock0
	dw OBJLst_Act_CoinLock1
	dw OBJLst_Act_CoinLock2
	dw OBJLst_Act_CoinLock1
	dw $0000

; =============== Act_CoinLock ===============
Act_CoinLock:
	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Depending on the status of the lock...
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_CoinLock_Closed
	dw Act_CoinLock_Opening
	dw Act_CoinLock_Open
	
; =============== Act_CoinLock_Closed ===============
; The lock is closed, and rebounds the player.
Act_CoinLock_Closed:
	; The only thing to do here is checking if a coin was thrown at the lock.
	; In that case, the thrown actor will have set the lock's routine to $08.
	ld   a, [sActSetRoutineId]
	and  a, $0F					
	cp   a, ACTRTN_SPEC_08		; Was something thrown at (or moved torwards) the lock?
	ret  nz						; If not, return
	
	; If the actor thrown at us wasn't a 10-coin, ignore
	mActCheckThrownId ACT_10COIN
	ret  nz
	
	; Delete the thrown actor
	ld   hl, sAct
	add  hl, de				; Offset the slot (we got DE in mActCheckThrownId)
	xor  a					; Mark slot as free
	ld   [hl], a
	ld   [sActHeld], a		; Clear any hold status (if we walked into the lock)
	ld   [sActHeldKey], a	; (not necessary here)
	ld   a, LOCK_OPENING	; Open the lock
	ld   [sActLocalRoutineId], a
	ld   [sLvlExitDoor], a	; Save it in the level info
	xor  a
	ld   [sActCoinLockUnlockTimer], a
	
	push bc					; Set glowing eyes
	ld   bc, OBJLstPtrTable_Act_CoinLock_Open
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, SFX1_26		; Play along screen shake effect
	ld   [sSFX1Set], a
	
	; Fall through the next subroutine
	
; =============== Act_CoinLock_Opening ===============
; The lock is being opened and is moving out of the way.
Act_CoinLock_Opening:
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
	
	ld   a, [sActCoinLockUnlockTimer]	; MovementLeft--;
	inc  a
	ld   [sActCoinLockUnlockTimer], a
	cp   a, $19					; Has the lock moved up all the way?
	ret  c						; If not, return
	
	; Otherwise mark the lock as open
	ld   a, LOCK_OPEN
	ld   [sActLocalRoutineId], a	
	ld   [sLvlExitDoor], a		; Also in the level info, in case we despawn the lock
	xor  a						; Mark as intangible
	ld   [sActSetColiType], a
	ret
	
; =============== Act_CoinLock_Open ===============
; The lock is open, and can't be interacted with anymore.
Act_CoinLock_Open:
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
	
OBJLstSharedPtrTable_Act_CoinLock:
	dw OBJLstPtrTable_Act_CoinLock_Closed;X
	dw OBJLstPtrTable_Act_CoinLock_Closed;X
	dw OBJLstPtrTable_Act_CoinLock_Closed;X
	dw OBJLstPtrTable_Act_CoinLock_Closed;X
	dw OBJLstPtrTable_Act_CoinLock_Closed;X
	dw OBJLstPtrTable_Act_CoinLock_Closed;X
	dw OBJLstPtrTable_Act_CoinLock_Closed;X
	dw OBJLstPtrTable_Act_CoinLock_Closed;X

OBJLst_Act_CoinLock0: INCBIN "data/objlst/actor/coinlock0.bin"
OBJLst_Act_CoinLock1: INCBIN "data/objlst/actor/coinlock1.bin"
OBJLst_Act_CoinLock2: INCBIN "data/objlst/actor/coinlock2.bin"
GFX_Act_CoinLock: INCBIN "data/gfx/actor/coinlock.bin"

; =============== ActInit_CartTrain ===============
ActInit_CartTrain:
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$10
	ld   [sActSetColiBoxL], a
	ld   a, +$10
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_CartTrain
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_CartTrain
	call ActS_SetOBJLstPtr
	
	; Set OBJLst shared table
	pop  bc
	ld   bc, OBJLstSharedPtrTable_Act_CartTrain
	call ActS_SetOBJLstSharedTablePtr
	
	ld   a, ACTCOLI_TOPSOLID
	ld   [sActSetColiType], a
	
	; Make these move right by default.
	; To make these move left, they are placed near solid blocks, since
	; they change direction when hitting a solid wall.
	ld   a, DIR_R				
	ld   [sActSetDir], a		
	xor  a						; Start idle
	ld   [sActCartTrainCanMove], a
	mSubCall ActS_SaveColiType ; BANK $02
	ret
	
OBJLstPtrTable_Act_CartTrain:
	dw OBJLst_Act_Cart00
	dw OBJLst_Act_Cart01
	dw OBJLst_Act_Cart02
	dw OBJLst_Act_Cart03
	dw $0000


; =============== Act_CartTrain ===============
Act_CartTrain:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Every 4 frames increase the anim counter
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkMove
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	
.chkMove:
	ld   a, [sActCartTrainCanMove]
	or   a					; Is the actor moving?
	jr   z, .idle			; If not, jump
	
	; Otherwise move in the specified direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a			
	call nz, Act_CartTrain_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call z, Act_CartTrain_MoveLeft
	ret
	
.idle:
	; Until the player lands on top again, don't reenable moving
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06			; Is player standing on top?
	ret  nz						; If not, return
	ld   a, $01					; Otherwise, resume moving
	ld   [sActCartTrainCanMove], a
	ret
	
; =============== Act_CartTrain_MoveRight ===============
Act_CartTrain_MoveRight:
	; Try to move right 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is there a solid block in the way?
	jr   nz, Act_CartTrain_StopMove	; If so, stop moving
	ld   bc, +$01					; Otherwise, move right
	call ActS_MoveRight
	
	; Since Act_CartTrain is specifically made for autoscrollers,
	; the subroutine for moving the player isn't the normal one -- this does not scroll the screen.
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06					; Is the player standing on the cart?
	ld   b, $01					
	call z, ActS_PlStand_MoveRight_NoScroll	; If so, move him as well
	ret
	
; =============== Act_CartTrain_MoveLeft ===============
Act_CartTrain_MoveLeft:
	; Try to move left 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is there a solid block in the way?
	jr   nz, Act_CartTrain_StopMove	; If so, stop moving
	ld   bc, -$01					; Otherwise, move left
	call ActS_MoveRight
	
	; Same detail about not scrolling the screen as Act_CartTrain_MoveRight.
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06				; Is the player standing on the cart?
	ld   b, $01					
	call z, ActS_PlStand_MoveLeft_NoScroll	; If so, move him as well
	ret
	
; =============== Act_CartTrain_StopMove ===============
Act_CartTrain_StopMove:
	ld   a, [sActSetDir]		; Invert the direction
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	xor  a						; Disable moving for now
	ld   [sActCartTrainCanMove], a
	ret
OBJLstSharedPtrTable_Act_CartTrain:
	dw OBJLstPtrTable_Act_CartTrain;X
	dw OBJLstPtrTable_Act_CartTrain;X
	dw OBJLstPtrTable_Act_CartTrain;X
	dw OBJLstPtrTable_Act_CartTrain;X
	dw OBJLstPtrTable_Act_CartTrain;X
	dw OBJLstPtrTable_Act_CartTrain;X
	dw OBJLstPtrTable_Act_CartTrain;X
	dw OBJLstPtrTable_Act_CartTrain;X

OBJLst_Act_Cart00: INCBIN "data/objlst/actor/cart00.bin"
OBJLst_Act_Cart01: INCBIN "data/objlst/actor/cart01.bin"
OBJLst_Act_Cart02: INCBIN "data/objlst/actor/cart02.bin"
OBJLst_Act_Cart03: INCBIN "data/objlst/actor/cart03.bin"
; [TCRF] A significant amount of unused sprite mappings went here.
;        These are perfectly valid (as a 2x2 square), but they appear broken (using the tiles reserved for powerups)
OBJLst_Act_Cart_Unused_04: INCBIN "data/objlst/actor/cart_unused_04.bin"
OBJLst_Act_Cart_Unused_05: INCBIN "data/objlst/actor/cart_unused_05.bin"
OBJLst_Act_Cart_Unused_06: INCBIN "data/objlst/actor/cart_unused_06.bin"
OBJLst_Act_Cart_Unused_07: INCBIN "data/objlst/actor/cart_unused_07.bin"
OBJLst_Act_Cart_Unused_08: INCBIN "data/objlst/actor/cart_unused_08.bin"
OBJLst_Act_Cart_Unused_09: INCBIN "data/objlst/actor/cart_unused_09.bin"
OBJLst_Act_Cart_Unused_0A: INCBIN "data/objlst/actor/cart_unused_0a.bin"
OBJLst_Act_Cart_Unused_0B: INCBIN "data/objlst/actor/cart_unused_0b.bin"
GFX_Act_Cart: INCBIN "data/gfx/actor/cart.bin"

; =============== ActInit_Cart ===============
; The wooden cart in non-train levels.
ActInit_Cart:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$10
	ld   [sActSetColiBoxL], a
	ld   a, +$10
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Cart
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_Cart
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Cart
	call ActS_SetOBJLstSharedTablePtr
	
	; Set collision type
	ld   a, ACTCOLI_TOPSOLID
	ld   [sActSetColiType], a
	
	; Set collision type
	ld   a, DIR_R
	ld   [sActSetDir], a
	xor  a
	ld   [sActCartCanMove], a
	ld   [sActSetTimer], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	mSubCall ActS_SaveColiType ; BANK $02
	ret
	
OBJLstPtrTable_Act_Cart:
	dw OBJLst_Act_Cart00
	dw OBJLst_Act_Cart01
	dw $0000

OBJLstPtrTable_Act_Cart_MoveR:
	dw OBJLst_Act_Cart03
	dw OBJLst_Act_Cart02
	dw OBJLst_Act_Cart01
	dw OBJLst_Act_Cart00
	dw $0000
; [TCRF] Doesn't get a chance to be used
OBJLstPtrTable_Act_Cart_Unused_MoveL:
	dw OBJLst_Act_Cart00;X
	dw OBJLst_Act_Cart01;X
	dw OBJLst_Act_Cart02;X
	dw OBJLst_Act_Cart03;X
	dw $0000;X


; =============== Act_Cart ===============
Act_Cart:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	call ActS_IncOBJLstIdEvery8
	
	call Act_Cart_DoFall		; Always handle gravity
	ld   a, [sActCartCanMove]
	or   a						; Is the cart idle?
	jp   z, Act_Cart_Idle				; If so, jump
	
	; Otherwise, move in the specified direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Moving right?
	call nz, Act_Cart_MoveRight	; If so, move right
	
	; [TCRF] This is impossible to trigger.
	;        Unlike Act_CartTrain, there's never a solid block in the way of these,
	;        even though it's actually handled similarly.
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Moving right?
	call z, Act_Cart_Unused_MoveLeft	; If not, move left
	ret
	
; =============== Act_Cart_DoFall ===============	
Act_Cart_DoFall:
	; Move down as specified
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown					; Drop down by that
	
	ld   a, [sActSetYSpeed_Low]		; B = sActSetYSpeed_Low
	ld   b, a					
	
	; Make sure the player stays attached to the cart, even when falling down,
	; as long as a solid block below the player isn't in the way.
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06					; Are we standing on it?
	call z, SubCall_PlBGColi_CheckGroundSolidOrMove	; If so, try to move down
	
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSpikeBlock
	or   a								; Is the cart on spike/lava?
	jp   nz, SubCall_ActS_StartStarKill	; If so, kill it
	
	;--
	; Check if there's any solid block below the (large) cart.
	call ActColi_GetBlockId_GroundHorz	; Read the block IDs on the ground
	
	; D = If block is solid (ground-left block)
	ld   a, b							
	push bc								
	mSubCall ActBGColi_IsSolidOnTop
	ld   d, a
	pop  bc
	; A = If block is solid (ground-right block)
	ld   a, c
	push de
	mSubCall ActBGColi_IsSolidOnTop
	pop  de
	or   a, d				; Is any of the two blocks solid?
	jr   z, .chkSpeed		; If not, skip
	;--
	; Otherwise, stop moving down
	ld   a, [sActSetY_Low]	; Align to Y block
	and  a, $F0
	ld   [sActSetY_Low], a
	xor  a					; Reset drop speed
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ret
.chkSpeed:
	; Every 4 frames increase the drop speed, up to 3px/frame
	ld   a, [sActSetTimer]
	and  a, $07
	ret  nz
	;--
	; [TCRF] There's no way to move up with the cart, so this is never taken
	ld   a, [sActSetYSpeed_Low]
	bit  7, a
	jr   nz, .incSpeed
	;--
	cp   a, $03		; Is the speed >= 3px/frame?
	ret  nc			; If so, return
.incSpeed:
	add  $01							; sActSetYSpeed++;
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00
	ld   [sActSetYSpeed_High], a
	ret
	
; =============== Act_Cart_Idle ===============
Act_Cart_Idle:
	; Until the player lands on top again, don't reenable moving
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06			; Is player standing on top?
	ret  nz						; If not, return
	ld   a, $01					; Otherwise, resume moving
	ld   [sActCartTrainCanMove], a
	
	; Depending on the direction, pick the correct OBJLstTable
	
	;--
	; [TCRF] This part is for the cart moving left, which can't happen
	push bc
	ld   bc, OBJLstPtrTable_Act_Cart_Unused_MoveL	; For moving left
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Is the cart facing right?
	ret  z						; If not, return
	;--
	push bc
	ld   bc, OBJLstPtrTable_Act_Cart_MoveR	; For moving right
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_Cart_MoveRight ===============
Act_Cart_MoveRight:
	; Try to move right 1px/frame
	
	; [TCRF] No solid blocks are ever placed in the way
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a								; Is there a solid block in the way?
	jr   nz, Act_Cart_Unused_StopMove	; If so, stop moving
	ld   bc, +$01						; Otherwise, move right
	call ActS_MoveRight
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06						; Is the player standing on the cart?
	call z, SubCall_ActS_PlStand_MoveRight	; If so, move him as well (and scroll the screen)
	ret
	
; =============== Act_Cart_Unused_MoveLeft ===============
; [TCRF] Unreachable subroutine, similar to Act_CartTrain_MoveLeft.
Act_Cart_Unused_MoveLeft: 
	; Try to move left 1px/frame
	
	; [TCRF] No solid blocks are ever placed in the way
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolid
	or   a								; Is there a solid block in the way?
	jr   nz, Act_Cart_Unused_StopMove	; If so, stop moving
	ld   bc, -$01						; Otherwise, move left
	call ActS_MoveRight
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06						; Is the player standing on the cart?
	call z, SubCall_ActS_PlStand_MoveLeft	; If so, move him as well (and scroll the screen)
	ret
	
; =============== Act_Cart_Unused_StopMove ===============
; [TCRF] Unreachable subroutine.
Act_Cart_Unused_StopMove: 
	ld   a, [sActSetDir]		; Invert the direction
	xor  a, DIR_R|DIR_L
	ld   [sActSetDir], a
	
	xor  a						; Disable moving for now
	ld   [sActCartCanMove], a
	
	;--
	; Special code unique to this subroutine, not found in Act_CartTrain_StopMove.
	; This reloads the animation, since we just changed direction.
	push bc
	ld   bc, OBJLstPtrTable_Act_Cart_Unused_MoveL	; For facing left
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Is it facing right?
	ret  z						; If not, return
	push bc
	ld   bc, OBJLstPtrTable_Act_Cart_MoveR	; For facing left
	call ActS_SetOBJLstPtr
	pop  bc
	;--
	ret  
OBJLstSharedPtrTable_Act_Cart:
	dw OBJLstPtrTable_Act_Cart;X
	dw OBJLstPtrTable_Act_Cart;X
	dw OBJLstPtrTable_Act_Cart;X
	dw OBJLstPtrTable_Act_Cart;X
	dw OBJLstPtrTable_Act_Cart;X
	dw OBJLstPtrTable_Act_Cart;X
	dw OBJLstPtrTable_Act_Cart;X
	dw OBJLstPtrTable_Act_Cart;X
	
; =============== ActInit_Wolf ===============
; Knife-throwing enemy.
ActInit_Wolf:
	; Setup collision box
	ld   a, $EC
	ld   [sActSetColiBoxU], a
	ld   a, $FC
	ld   [sActSetColiBoxD], a
	ld   a, $FA
	ld   [sActSetColiBoxL], a
	ld   a, $06
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Wolf
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_Wolf_WalkL
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Wolf
	call ActS_SetOBJLstSharedTablePtr
	
	; [BUG] The collision here is handled a bit inconsistently.
	;		At first, this actor is completely safe to touch even when it moves normally.
	;		When it turns, or switches to the "knife throwing" mode, collision fixes itself.
	;		After the knife is thrown, again it becomes completely safe to touch.
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	xor  a
	ld   [sActWolfTurnDelay], a
	ld   [sActLocalRoutineId], a
	ld   [sActWolfKnifeDelay], a	
	ld   [sActWolfYSpeed], a		
	mSubCall ActS_SaveColiType ; BANK $02
	
	ld   a, $28					; Wait for $28 frames before moving
	ld   [sActWolfMoveDelay], a
	ret
	
OBJLstPtrTable_ActInit_Unused_Wolf:
	dw OBJLst_Act_Wolf_AlertL1;X
	dw $0000;X

; =============== Act_Wolf ===============
Act_Wolf:
	; If inside a solid block, kill the actor
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolid
	or   a
	jp   nz, SubCall_ActS_StartJumpDead
	
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Do the routine jump
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Wolf_Main
	dw .onPlColiH
	dw .onPlColiTop
	dw SubCall_ActS_StartStarKill
	dw .onPlColiBelow
	dw .onPlColiBelow
	dw Act_Wolf_Walk;X
	dw SubCall_ActS_StartSwitchDir
	dw SubCall_ActS_StartJumpDeadSameColi
	
; Since this counts as a heavy actor, make circling stars spawn when stunned
.onPlColiH:
	call SubCall_ActS_SpawnStunStar
	jp   SubCall_ActS_OnPlColiH
.onPlColiTop:
	call SubCall_ActS_SpawnStunStar
	jp   SubCall_ActS_OnPlColiTop
.onPlColiBelow:
	call SubCall_ActS_SpawnStunStar
	jp   SubCall_ActS_OnPlColiBelow
	
Act_Wolf_Main:
	; If the screen is shaking, stun the actor
	ld   a, [sScreenShakeTimer]
	or   a
	jp   nz, SubCall_ActS_StartGroundPoundStun
	
	; If the actor isn't on solid ground, make him fall.
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is the actor on solid ground?
	jr   nz, .onGround				; If so, skip
	
	; Otherwise, fall down at an increasing speed
	
	; [POI] This is technically possible to trigger in-game without debug mode,
	;		but it requires a special setup (in C03).
	
	ld   a, [sActWolfYSpeed]
	ld   c, a						; BC = sActWolfYSpeed
	ld   b, $00
	call ActS_MoveDown				; Move down by that
	
	; Every 4 frames increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $03
	jr   nz, .chkRoutine
	ld   a, [sActWolfYSpeed]
	inc  a
	ld   [sActWolfYSpeed], a
	jr   .chkRoutine

.onGround:
	xor  a							; Reset drop speed
	ld   [sActWolfYSpeed], a
.chkRoutine:
	; Check for the delay before moving
	ld   a, [sActWolfMoveDelay]
	or   a							; Is the actor waiting to move?
	jr   nz, Act_Wolf_WaitMove		; If so, continue to wait
	
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_Wolf_Walk
	dw Act_Wolf_Walk;X ; [TCRF] Was there something here?
	dw Act_Wolf_Alert
	dw Act_Wolf_ThrowKnife
	dw Act_Wolf_PostKnifeWait
	
; =============== Act_Wolf_WaitMove ===============
; Handles the delay before moving.
Act_Wolf_WaitMove:
	ld   a, [sActWolfMoveDelay]		; Timer--
	dec  a
	ld   [sActWolfMoveDelay], a
	or   a							; Has it elapsed?
	ret  nz							; If not, return
	; Prepare for movement next frame
	ld   a, $28						; Otherwise, set the cooldown timer
	ld   [sActWolfKnifeDelay], a
	ret
	
; =============== Act_Wolf_Walk ===============	
Act_Wolf_Walk:
	; Check for the delay before the actor can move again
	ld   a, [sActWolfTurnDelay]
	or   a						
	jp   nz, Act_Wolf_WaitTurn	
	
	call ActS_IncOBJLstIdEvery8
	
	; Move depending on the actor's direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_Wolf_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_Wolf_MoveLeft
	
	; Handle cooldown timer for throwing knifes
	ld   a, [sActWolfKnifeDelay]
	or   a							; Has the cooldown timer elapsed yet?
	jr   z, Act_Wolf_CheckPlPos		; If so, try to throw a knife
	dec  a							; Otherwise, decrement it
	ld   [sActWolfKnifeDelay], a
	ret
	
; =============== Act_Wolf_CheckPlPos ===============	
; Determines if the player is in the range of the actor, and if so, throws a knife.
Act_Wolf_CheckPlPos:
	; This is fairly similar to what's done in ActS_GetPlDistance,
	; except we're using the relative pos to save time (it's one byte).

	;--
	;
	; VERTICAL RANGE
	; To pass the checks, the player must be either:
	; - Max $37 pixels below the actor
	; - Max $38 pixels above the actor
	;
	
	; Get the positions we need.
	ld   a, [sActSetRelY]	; D = Actor Y pos
	ld   d, a
	ld   a, [sPlYRel]		; A = Player Y pos
	
	; Subtract PlY to ActY.
	; This means we can check the MSB to know if the player is above or below the actor.
	sub  a, d				; Diff = PlY - ActY
	
	; Check if player is below the actor.
	; (PlY > ActY, so PlY - ActY > 0)
	bit  7, a				; Is the MSB clear?
	jr   z, .chkRangeD		; If so, jump
	
	
	; Otherwise, we have a negative diff to convert to positive.
	; we're also missing the usual "inc a", not like it's needed
	cpl						
	
.chkRangeU:
	cp   a, $39-$01	; Is the player less than $39 pixels above the actor?
	ret  nc			; If not, return
	jr   .doHRange
.chkRangeD:
	cp   a, $38		; Is the player less than $38 pixels below the actor?
	ret  nc			; If not, return
	
	;--
	;
	; HORIZONTAL RANGE
	; Here we only need the player to be in front of the actor.
	;
.doHRange:
	; Get the vars
	ld   a, [sActSetRelX]	; D = Actor X pos
	ld   d, a
	ld   a, [sPlXRel]		; E = Player X pos
	ld   e, a
	
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Is the actor facing right?
	jr   nz, .chkRangeR		; If so, jump
.chkRangeL:
	; The actor is facing left, so the player must be to the left of the actor.
	; PlX < ActX, so ActX - PlX > 0. (nc)
	ld   a, d				; A = Actor X pos
	cp   e					; Is ActX > PlX?
	jp   nc, Act_Wolf_StartKnifeAlert		; If so, jump
	ret
.chkRangeR:
	; The actor is facing right, so the player must be to the right of the actor.
	; ActX < PlX, so ActX - PlX < 0. (c)
	ld   a, d				; A = Actor X pos
	cp   e					; Is ActX < PlX?
	jp   c, Act_Wolf_StartKnifeAlert			; If so, jump
	ret
	
; =============== Act_Wolf_WaitTurn ===============
; Turns the actor once the turn timer elapses.
; IN
; - A: Must be sActWolfTurnDelay.
Act_Wolf_WaitTurn:
	; Wait for the timer to elapse
	dec  a						; sActWolfTurnDelay--
	or   a
	ld   [sActWolfTurnDelay], a	; Save back value
	ret  nz						; Did the timer elapse? If not, return
	
	; Now we can turn.
	ld   a, $28					; Wait $28 frames before moving		
	ld   [sActWolfMoveDelay], a
	ld   a, [sActSetDir]		; Invert direction
	xor  DIR_L|DIR_R
	ld   [sActSetDir], a
	
	; Depending on the new direction, set the animation / collision box.
	; This makes sure the damaging side is set properly to the side of the knife.
	bit  DIRB_R, a			; Facing right?
	jr   nz, .dirR			; If so, jump
.dirL:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Wolf_WalkL
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
.dirR:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Wolf_WalkR
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_Wolf_SetTurnDelay ===============
; Makes the actor delay for $14 frames before turning.
; (not counting the movement delay, set after this one elapses)
Act_Wolf_SetTurnDelay:
	ld   a, $14
	ld   [sActWolfTurnDelay], a
	ret
	
; =============== Act_Wolf_MoveLeft ===============
; Moves the actor to the left.
Act_Wolf_MoveLeft:
	; If there's any solid block in the way, delay for a bit before turning
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, Act_Wolf_SetTurnDelay
	
	; If there isn't solid ground on the left, delay for a bit before turning
	call ActColi_GetBlockId_BottomL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, Act_Wolf_SetTurnDelay
	
	; Move left 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveRight
	
	ld   a, LOW(OBJLstPtrTable_Act_Wolf_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Wolf_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Make the actor face left
	ld   a, [sActSetDir]
	and  a, $F8				
	or   a, DIR_L
	ld   [sActSetDir], a
	ret
	
; =============== Act_Wolf_MoveRight ===============
; Moves the actor to the right.
Act_Wolf_MoveRight:

	; If there's any solid block in the way, delay for a bit before turning
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, Act_Wolf_SetTurnDelay
	
	; If there isn't solid ground on the right, delay for a bit before turning
	call ActColi_GetBlockId_BottomR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, Act_Wolf_SetTurnDelay
	
	; Move right 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveRight
	
	ld   a, LOW(OBJLstPtrTable_Act_Wolf_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Wolf_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Make the actor face right
	ld   a, [sActSetDir]
	and  a, $F8				
	or   a, DIR_R
	ld   [sActSetDir], a
	ret
	
; =============== Act_Wolf_StartKnifeAlert ===============
; This subroutine switches to mode WOLF_RTN_ALERT.
Act_Wolf_StartKnifeAlert:
	ld   a, WOLF_RTN_ALERT
	ld   [sActLocalRoutineId], a
	ld   a, $30						
	ld   [sActWolfModeTimer], a
	
	; Pick a different animation and collision type (for the damaging part)
	; depending on the direction faced.
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Is the actor facing right?
	jr   nz, .dirR				; If so, jump
.dirL:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Wolf_AlertL
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
.dirR:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Wolf_AlertR
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_Wolf_Alert ===============
; Stops for a bit while playing a sound effect (alerting of an incoming knife).
Act_Wolf_Alert:
	; Handle the timer
	ld   a, [sActWolfModeTimer]
	or   a						; Timer elapsed?
	jr   z, .endMode			; If so, return
	dec  a						; Otherwise, timer--;
	ld   [sActWolfModeTimer], a
	
	call ActS_IncOBJLstIdEvery8	
	
	; Every 8 frames play a SFX
	ld   a, [sActSetTimer]
	and  a, $07
	ret  nz
	ld   a, SFX1_28
	ld   [sSFX1Set], a
	ret
	
.endMode:
	ld   a, WOLF_RTN_THROWKNIFE	; Set routine id
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActWolfModeTimer], a
	
	; Depending on the direction facing, set a different anim
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Facing right?
	jr   nz, .dirR			; If so, jump
.dirL:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Wolf_ThrowL
	ret
.dirR:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Wolf_ThrowR
	ret
	
; =============== Act_Wolf_ThrowKnife ===============
; Waits for a bit before throwing the knife.
Act_Wolf_ThrowKnife:
	; Spawn the knife once the animation ends
	ld   a, [sActSetOBJLstId]
	cp   a, $04						; Has the animation ended? (frame >= $04)
	jr   nc, .endMode				; If so, jump
	
	; Otherwise continue animating it every 8 frames
	call ActS_IncOBJLstIdEvery8
	ret
.endMode:
	ld   a, WOLF_RTN_POSTKNIFE
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActWolfModeTimer], a
	
	; Make safe to touch since we don't have a knife anymore (at least for a bit)
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	; Throw the knife
	call Act_Wolf_SpawnKnife
	ret
	
; =============== Act_Wolf_PostKnifeWait ===============
; Waits for a bit before starting to move again.
Act_Wolf_PostKnifeWait:
	; Wait for $14 before moving again
	ld   a, [sActWolfModeTimer]
	cp   a, $14					; Timer reached the target value?
	jr   nc, .endMode			; If so, return
	inc  a
	ld   [sActWolfModeTimer], a
	
	; Pick the correct anim depending on the direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	jr   nz, .dirR				; If so, jump
.dirL:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Wolf_ThrowEndL
	ret
.dirR:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Wolf_ThrowEndR
	ret
.endMode:
	; Move immediately, but wait for $50 frames before another knife
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActWolfModeTimer], a
	ld   a, $50
	ld   [sActWolfKnifeDelay], a
	ret
	
; =============== Act_WolfKnife ===============
; Helper knife actor spawned by Act_Wolf.
Act_WolfKnife:
	call Act_WolfKnife_CheckOffScreen
	
	; If the knife hit the player, despawn it
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_07				; Dealt damage?
	jr   z, Act_WolfKnife_Despawn	; If so, jump
	
	ld   a, [sActWolfKnifeTimer]
	or   a							; Is the knife moving?
	jr   nz, Act_WolfKnife_WaitDespawn				; If not, return
	
	; Move the knife as specified
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_WolfKnife_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_WolfKnife_MoveLeft
	ret
	
; =============== Act_WolfKnife_CheckOffScreen ===============
; Despawns the knife as soon as it goes off-screen.
; NOTE: This is not necessary. 
;		The actor could have been spawned with the sActSetOpts flag ACTFLAGB_UNUSED_FREEOFFSCREEN.
Act_WolfKnife_CheckOffScreen:
	call ActS_CheckOffScreen	; Update offscreen status
	ld   a, [sActSet]
	cp   a, $02					; Is the actor visible & active?
	ret  nc						; If so, return
	xor  a						; Otherwise, despawn it
	ld   [sActSet], a
	ret
; =============== Act_WolfKnife_WallHit ===============
; Stops the knife once it hits a wall.
Act_WolfKnife_WallHit:
	ld   a, $01					; Stop the knife
	ld   [sActWolfKnifeTimer], a
	ld   a, ACTCOLI_TOPSOLID	; Make safe to touch/stand on
	ld   [sActSetColiType], a
	ld   a, SFX1_2D				; Play SFX
	ld   [sSFX1Set], a
	ret
; =============== Act_WolfKnife_WaitDespawn ===============
; Waits for $78 frames before despawning the knife.
Act_WolfKnife_WaitDespawn:
	ld   a, [sActWolfKnifeTimer]	; Timer++;
	inc  a
	ld   [sActWolfKnifeTimer], a
	cp   a, $78						; Timer < $78?
	ret  c							; If so, return
Act_WolfKnife_Despawn:
	xor  a
	ld   [sActSet], a
	ret
	
; =============== Act_WolfKnife_MoveLeft ===============
Act_WolfKnife_MoveLeft:
	ld   bc, -$03
	call ActS_MoveRight
	mActOBJLstPtrTable OBJLstPtrTable_Act_WolfKnifeL
	
	; If the knife reaches a solid block, stop it
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a							
	call nz, Act_WolfKnife_WallHit
	
	ret
; =============== Act_WolfKnife_MoveRight ===============
Act_WolfKnife_MoveRight:
	ld   bc, +$03
	call ActS_MoveRight
	mActOBJLstPtrTable OBJLstPtrTable_Act_WolfKnifeR
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	call nz, Act_WolfKnife_WallHit
	ret
	
; =============== Act_Wolf_SpawnKnife ===============
; Spawns the knife thrown by the actor.
Act_Wolf_SpawnKnife:
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
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_Wolf
	
	ld   a, $02				; Enabled
	ldi  [hl], a
	ld   a, [sActSetX_Low]	; X = sActSetX
	ldi  [hl], a
	ld   a, [sActSetX_High]
	ldi  [hl], a
	
	ld   a, [sActSetY_Low]	; Y = sActSetY - $08 (8px above the feet)
	sub  a, $08
	ldi  [hl], a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ldi  [hl], a
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ldi  [hl], a
	
	ld   a, -$04				; Coli box U
	ldi  [hl], a
	ld   a, -$03				; Coli box D
	ldi  [hl], a
	ld   a, -$02				; Coli box L
	ldi  [hl], a
	ld   a, +$01				; Coli box R
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
	
	; Actor ID
	; This uses the same ID as the wolf, making it use the same tile base, among other things.
	ld   a, [sActSetId]			
	set  ACTB_NORESPAWN, a		; Don't make the knife respawn (it'd duplicate the wolf)
	ldi  [hl], a
	
	xor  a						; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_WolfKnife)		; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_WolfKnife)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	ldi  [hl], a				; Timer 3
	ldi  [hl], a				; Timer 4
	ldi  [hl], a				; Timer 5
	ldi  [hl], a				; Timer 6
	ldi  [hl], a				; Timer 7
	
	; [NOTE] This could have used ACTFLAG_UNUSED_FREEOFFSCREEN, see 
	ld   a, $01					; Flags
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_Wolf)		; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_Wolf)
	ldi  [hl], a
	
	ld   a, SFX1_29		; Play knife throw SFX
	ld   [sSFX1Set], a
	ret
OBJLstSharedPtrTable_Act_Wolf:
	dw OBJLstPtrTable_Act_Wolf_StunL;X
	dw OBJLstPtrTable_Act_Wolf_StunR;X
	dw OBJLstPtrTable_Act_Wolf_WalkL
	dw OBJLstPtrTable_Act_Wolf_WalkR
	dw OBJLstPtrTable_Act_Wolf_StunL
	dw OBJLstPtrTable_Act_Wolf_StunR
	dw OBJLstPtrTable_Act_Wolf_WalkL;X
	dw OBJLstPtrTable_Act_Wolf_WalkR;X

OBJLstPtrTable_Act_Wolf_WalkL:
	dw OBJLst_Act_Wolf_WalkL0
	dw OBJLst_Act_Wolf_WalkL1
	dw OBJLst_Act_Wolf_WalkL2
	dw OBJLst_Act_Wolf_WalkL1
	dw $0000
OBJLstPtrTable_Act_Wolf_WalkR:
	dw OBJLst_Act_Wolf_WalkR0
	dw OBJLst_Act_Wolf_WalkR1
	dw OBJLst_Act_Wolf_WalkR2
	dw OBJLst_Act_Wolf_WalkR1
	dw $0000
OBJLstPtrTable_Act_Wolf_StunL:
	dw OBJLst_Act_Wolf_StunL
	dw $0000
OBJLstPtrTable_Act_Wolf_StunR:
	dw OBJLst_Act_Wolf_StunR
	dw $0000
OBJLstPtrTable_Act_Wolf_AlertL:
	dw OBJLst_Act_Wolf_AlertL0
	dw OBJLst_Act_Wolf_AlertL1
	dw OBJLst_Act_Wolf_AlertL0
	dw OBJLst_Act_Wolf_AlertL1
	dw $0000
OBJLstPtrTable_Act_Wolf_AlertR:
	dw OBJLst_Act_Wolf_AlertR0
	dw OBJLst_Act_Wolf_AlertR1
	dw OBJLst_Act_Wolf_AlertR0
	dw OBJLst_Act_Wolf_AlertR1
	dw $0000
OBJLstPtrTable_Act_Wolf_ThrowL:
	dw OBJLst_Act_Wolf_AlertL1
	dw OBJLst_Act_Wolf_ThrowL0
	dw OBJLst_Act_Wolf_ThrowL1
	dw OBJLst_Act_Wolf_ThrowL0
	dw OBJLst_Act_Wolf_AlertL1
	dw $0000;X
OBJLstPtrTable_Act_Wolf_ThrowR:
	dw OBJLst_Act_Wolf_AlertR1
	dw OBJLst_Act_Wolf_ThrowR0
	dw OBJLst_Act_Wolf_ThrowR1
	dw OBJLst_Act_Wolf_ThrowR0
	dw OBJLst_Act_Wolf_AlertR1
	dw $0000;X
OBJLstPtrTable_Act_Wolf_ThrowEndL:
	dw OBJLst_Act_Wolf_AlertL1
	dw $0000;X
OBJLstPtrTable_Act_Wolf_ThrowEndR:
	dw OBJLst_Act_Wolf_AlertR1
	dw $0000;X
OBJLstPtrTable_Act_WolfKnifeL:
	dw OBJLst_Act_WolfKnifeL
	dw $0000;X
OBJLstPtrTable_Act_WolfKnifeR:
	dw OBJLst_Act_WolfKnifeR
	dw $0000;X

OBJLst_Act_Wolf_AlertL1: INCBIN "data/objlst/actor/wolf_alertl1.bin"
OBJLst_Act_Wolf_AlertL0: INCBIN "data/objlst/actor/wolf_alertl0.bin"
OBJLst_Act_Wolf_StunL: INCBIN "data/objlst/actor/wolf_stunl.bin"
OBJLst_Act_Wolf_WalkL0: INCBIN "data/objlst/actor/wolf_walkl0.bin"
OBJLst_Act_Wolf_WalkL1: INCBIN "data/objlst/actor/wolf_walkl1.bin"
OBJLst_Act_Wolf_WalkL2: INCBIN "data/objlst/actor/wolf_walkl2.bin"
OBJLst_Act_WolfKnifeL: INCBIN "data/objlst/actor/wolfknifel.bin"
OBJLst_Act_Wolf_ThrowL1: INCBIN "data/objlst/actor/wolf_throwl1.bin"
OBJLst_Act_Wolf_ThrowL0: INCBIN "data/objlst/actor/wolf_throwl0.bin"
OBJLst_Act_Wolf_AlertR1: INCBIN "data/objlst/actor/wolf_alertr1.bin"
OBJLst_Act_Wolf_AlertR0: INCBIN "data/objlst/actor/wolf_alertr0.bin"
OBJLst_Act_Wolf_StunR: INCBIN "data/objlst/actor/wolf_stunr.bin"
OBJLst_Act_Wolf_WalkR0: INCBIN "data/objlst/actor/wolf_walkr0.bin"
OBJLst_Act_Wolf_WalkR1: INCBIN "data/objlst/actor/wolf_walkr1.bin"
OBJLst_Act_Wolf_WalkR2: INCBIN "data/objlst/actor/wolf_walkr2.bin"
OBJLst_Act_WolfKnifeR: INCBIN "data/objlst/actor/wolfknifer.bin"
OBJLst_Act_Wolf_ThrowR1: INCBIN "data/objlst/actor/wolf_throwr1.bin"
OBJLst_Act_Wolf_ThrowR0: INCBIN "data/objlst/actor/wolf_throwr0.bin"
GFX_Act_Wolf: INCBIN "data/gfx/actor/wolf.bin"

; =============== ActInit_Penguin ===============
; Penguin-like enemy throwing spike balls.
; See also: ActInit_Wolf.
ActInit_Penguin:
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
	ld   bc, SubCall_Act_Penguin
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_Penguin_WalkL
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Penguin
	call ActS_SetOBJLstSharedTablePtr
	
	; Set as safe to touch initially
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	ld   a, DIR_L
	ld   [sActSetDir], a
	xor  a
	ld   [sActPenguinTurnDelay], a
	ld   [sActPenguinPostKickDelay], a
	ld   [sActPenguinYSpeed], a
	ld   [sActLocalRoutineId], a
	ld   [sActPenguinSpawnDelay], a
	mSubCall ActS_SaveColiType ; BANK $02
	ld   a, $50					; Wait $50 frames before attempting to shoot
	ld   [sActPenguinAlertDelay], a
	ret
	
OBJLstPtrTable_ActInit_Unused_Penguin:
	dw OBJLst_Act_Penguin_WalkL0;X
	dw $0000;X
	
; =============== Act_Penguin ===============
Act_Penguin:
	; If the actor is overlapping with a solid block, kill it
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolid
	or   a
	jp   nz, SubCall_ActS_StartJumpDead
	
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Do the routine table
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Penguin_Main
	dw .onPlColiH
	dw .onPlColiTop
	dw SubCall_ActS_StartStarKill;X
	dw .onPlColiBelow
	dw .onPlColiBelow
	dw Act_Penguin_Walk;X
	dw SubCall_ActS_StartSwitchDir
	dw SubCall_ActS_StartJumpDeadSameColi
	
	; Since this is an heavy actor, show stars when stunned
.onPlColiH:
	call SubCall_ActS_SpawnStunStar
	jp   SubCall_ActS_OnPlColiH
.onPlColiTop:
	call SubCall_ActS_SpawnStunStar
	jp   SubCall_ActS_OnPlColiTop
.onPlColiBelow:
	call SubCall_ActS_SpawnStunStar
	jp   SubCall_ActS_OnPlColiBelow
	
; =============== Act_Penguin_Main ===============
Act_Penguin_Main:
	; If the screen is shaking, stun the actor
	ld   a, [sScreenShakeTimer]
	or   a
	jp   nz, SubCall_ActS_StartGroundPoundStun
	
	; If the actor isn't on solid ground, make him fall.
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is the actor on solid ground?
	jr   nz, .onGround				; If so, skip
	
	ld   a, [sActPenguinYSpeed]
	ld   c, a						; BC = sActPenguinYSpeed
	ld   b, $00
	call ActS_MoveDown				; Move down by that
	
	; Every 4 frames increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $03
	jr   nz, .chkRoutine
	ld   a, [sActPenguinYSpeed]
	inc  a
	ld   [sActPenguinYSpeed], a
	jr   .chkRoutine
	
.onGround:
	xor  a							; Reset drop speed
	ld   [sActPenguinYSpeed], a
.chkRoutine:
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_Penguin_Walk
	dw Act_Penguin_Walk;X ; [TCRF] Also here
	dw Act_Penguin_Alert
	dw Act_Penguin_Kick
	dw Act_Penguin_PostKickWait
	
; =============== Act_Penguin_Walk ===============
; Main code for the actor.
Act_Penguin_Walk:
	ld   a, [sActPenguinTurnDelay]
	or   a
	jr   nz, Act_Penguin_WaitTurn
	
	call ActS_IncOBJLstIdEvery8
	
	; Move depending on the actor's direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_Penguin_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_Penguin_MoveLeft
	
	;--
	; Always decrement the delay before shooting another spike ball.
	;
	; [POI] This is useless. Since the delay is set to a lower value than sActPenguinAlertDelay,
	;       and the only ways to interrupt the kick eventually causes the actor to go through the
	;       init code again (which sets sActPenguinAlertDelay), it means that there's
	;		no way to get to Act_Penguin_Alert with a non-zero SpawnDelay timer.
	ld   a, [sActPenguinSpawnDelay]
	or   a							
	jr   z, .chkDelay			
	dec  a							
	ld   [sActPenguinSpawnDelay], a
	;--
	
.chkDelay:
	; Handle the cooldown timer before trying to notice the player
	ld   a, [sActPenguinAlertDelay]			
	or   a							; Has the cooldown timer elapsed yet?
	jr   z, Act_Penguin_CheckPlPos	; If so, try shooting
	dec  a							; Otherwise, decrement it
	ld   [sActPenguinAlertDelay], a
	ret
	
; =============== Act_Penguin_CheckPlPos ===============	
; Determines if the player is in the range of the actor, and if so, shoots the spikeball.
Act_Penguin_CheckPlPos:
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
	jp   nc, Act_Penguin_StartShootAlert	; If so, jump
	ret
.chkRangeR:
	ld   a, d				; If so, jump
	cp   e					; Is ActX < PlX?
	jp   c, Act_Penguin_StartShootAlert	; If so, jump
	ret
	
; =============== Act_Penguin_WaitTurn ===============
; Turns the actor once the turn timer elapses.
; IN
; - A: Must be sActPenguinTurnDelay.
Act_Penguin_WaitTurn:
	; Wait for the timer to elapse
	dec  a							; sActPenguinTurnDelay--
	ld   [sActPenguinTurnDelay], a	; Save back value
	or   a							; Did the timer elapse?
	ret  nz							; If not, return
	
	; Now we can turn.
	ld   a, [sActSetDir]
	xor  DIR_L|DIR_R
	ld   [sActSetDir], a
	
	; Depending on the new direction, set the animation / collision box.
	; This makes sure the damaging side is set properly to the side of the spike.
	bit  DIRB_R, a			; Facing right?
	jr   nz, .dirR			; If so, jump
.dirL:
	push bc
	ld   bc, OBJLstPtrTable_Act_Penguin_WalkL
	call ActS_SetOBJLstPtr
	pop  bc
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
.dirR:
	push bc
	ld   bc, OBJLstPtrTable_Act_Penguin_WalkR
	call ActS_SetOBJLstPtr
	pop  bc
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_Penguin_SetTurnDelay ===============
; Makes the actor delay for $14 frames before turning,
; as well as preventing to shoot for $50 frames after moving.
Act_Penguin_SetTurnDelay:
	ld   a, $14						; Wait $14 before turning
	ld   [sActPenguinTurnDelay], a
	jp   Act_Penguin_SetShootDelay	; Wait $50 before shooting
	
; =============== Act_Penguin_MoveLeft ===============
; Moves the actor to the left.
Act_Penguin_MoveLeft:
	; If there's any solid block in the way, delay for a bit before turning
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, Act_Penguin_SetTurnDelay
	
	; If there isn't solid ground on the left, delay for a bit before turning
	call ActColi_GetBlockId_BottomL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, Act_Penguin_SetTurnDelay
	
	
	ld   a, LOW(OBJLstPtrTable_Act_Penguin_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Penguin_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Make the actor face left
	ld   a, [sActSetDir]
	and  a, $F8
	or   a, DIR_L
	ld   [sActSetDir], a
	
	; Move left 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
; =============== Act_Penguin_MoveRight ===============
; Moves the actor to the right.
Act_Penguin_MoveRight:

	; If there's any solid block in the way, delay for a bit before turning
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, Act_Penguin_SetTurnDelay
	
	; If there isn't solid ground on the right, delay for a bit before turning
	call ActColi_GetBlockId_BottomR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, Act_Penguin_SetTurnDelay
	
	ld   a, LOW(OBJLstPtrTable_Act_Penguin_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Penguin_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Make the actor face right
	ld   a, [sActSetDir]
	and  a, $F8
	or   a, DIR_R
	ld   [sActSetDir], a
	
	; Move right 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveRight
	ret
	
; =============== Act_Penguin_StartShootAlert ===============
; This subroutine switches to mode PENG_RTN_ALERT.	
Act_Penguin_StartShootAlert:
	ld   a, PENG_RTN_ALERT
	ld   [sActLocalRoutineId], a
	
	; Pick a different animation and collision type (for the damaging part)
	; depending on the direction faced.
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Is the actor facing right?
	jr   nz, .dirR			; If so, jump
.dirL:
	push bc
	ld   bc, OBJLstPtrTable_Act_Penguin_OpenLidL
	call ActS_SetOBJLstPtr
	pop  bc
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
.dirR:;R
	push bc
	ld   bc, OBJLstPtrTable_Act_Penguin_OpenLidR
	call ActS_SetOBJLstPtr
	pop  bc
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
; =============== Act_Penguin_Alert ===============
; Stops for a bit while spawning a spike ball (alerting of an incoming attack).
Act_Penguin_Alert:
	; Every $10 frames continue the animation
	; This is expected to be a 4-frame animation.
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .chkSpawn
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	
.chkSpawn:
	;
	; Spawn the spike ball exactly when the lid opens (sActSetOBJLstId == $02)
	; When the lid closes (sActSetOBJLstId == $03), switch to the next mode.
	;
	; Note that since the spike ball is another actor, it will handle timing by itself.
	; It's meant to be in sync with the animation of the penguin kicking the spike ball,
	; as done in PENG_RTN_KICK, but on the spike ball side it's handled by an
	; unrelated timer by necessity.
	;
	; What this means is that the spikeball can't be prevented from moving
	; (ie: by stunning the penguin before he kicks the spikeball).
	;
	
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	ld   a, [sActSetOBJLstId]
	cp   a, $03					; AnimCnt >= $03?
	jr   nc, .endMode			; If so, switch to the next mode
	cp   a, $02					; AnimCnt < $02?
	ret  c						; If so, return
	
	; If the spawn delay (decremented elsewhere) isn't elapsed yet, don't spawn another spikeball
	ld   a, [sActPenguinSpawnDelay]
	or   a						; Is the timer set already?
	ret  nz						; If so, return
	ld   a, $30					; Otherwise, set a new delay
	ld   [sActPenguinSpawnDelay], a
	call Act_Penguin_SpawnSpikeBall	; And spawn the spikeball
	ret
	
.endMode:
	ld   a, PENG_RTN_KICK			; Set kick mode
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSetTimer2], a
	ld   [sActPenguinPostKickDelay], a
	
	; Depending on the direction facing, set a different facing kick anim
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Facing right?
	jr   nz, .dirR
.dirL:
	push bc
	ld   bc, OBJLstPtrTable_Act_Penguin_KickL
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.dirR:
	push bc
	ld   bc, OBJLstPtrTable_Act_Penguin_KickR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
; =============== Act_Penguin_Kick ===============
; Kicks the previously spawned spike ball.
; Meant to be in sync with the timing done in Act_PenguinSpike.
Act_Penguin_Kick:
	; Switch to the next mode once the animation ends
	ld   a, [sActSetOBJLstId]
	cp   a, $03					; Has the animation ended? (frame >= $03)
	jr   nc, .endMode			; If so, jump
	
	; Animate every $10 frames
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .end
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.end:
	ret
.endMode:
	ld   a, PENG_RTN_POSTKICK
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSetTimer2], a
	ld   [sActPenguinPostKickDelay], a
	
	; Make safe to touch (doesn't make much sense here though)
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_Penguin_PostKickWait ===============
; Waits for a bit before starting to move again.
Act_Penguin_PostKickWait:
	; Wait for $14 frames before moving again
	ld   a, [sActPenguinPostKickDelay]
	cp   a, $14							; Timer reached the target value?
	jr   nc, Act_Penguin_SetShootDelay	; If so, return
	inc  a
	ld   [sActPenguinPostKickDelay], a
	
	; Pick the correct anim depending on the direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	jr   nz, .dirR				; If so, jump
.dirL:
	push bc
	ld   bc, OBJLstPtrTable_Act_Penguin_PostKickL
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.dirR:
	push bc
	ld   bc, OBJLstPtrTable_Act_Penguin_PostKickR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
; =============== Act_Penguin_SetShootDelay ===============
; Makes the actor stop shooting for $50 frames after starting to move.
Act_Penguin_SetShootDelay:
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActPenguinPostKickDelay], a
	ld   a, $50							; This is added to sActPenguinSpawnDelay
	ld   [sActPenguinAlertDelay], a
	ret

; =============== Act_PenguinSpikeBall ===============
; Helper spikeball actor spawned by Act_Penguin.
Act_PenguinSpikeBall:
	call Act_PenguinSpikeBall_CheckOffScreen
	
	; Reuse first frame from MoveL animation.
	; Not a problem since we aren't cycling the animations until the thing moves.
	ld   a, LOW(OBJLstPtrTable_Act_PenguinSpikeBall_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_PenguinSpikeBall_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; With sActPenguinSpikeTimer starting out at $40,
	; don't move until the timer elapses.
	ld   a, [sActPenguinSpikeTimer]
	or   a								; Is the timer elapsed yet?
	jr   z, Act_PenguinSpikeBall_Move	; If so, jump
	dec  a
	ld   [sActPenguinSpikeTimer], a
	
	; The first frame we get here, set up the actor's position.
	cp   a, $3F				; Is this the first time we looped?
	ret  nz					; If not, return
	
	; At this point, it has the exact same coordinates as the penguin, but we
	; need to move it a bit out of the way.
	; That "move it a bit out of the way" depends on the direction it's facing.
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Facing right?
	jr   nz, .setR			; If so, move $20px to the right
.setL:
	; Otherwise, move $10px to the left.
	; (this difference depends from the penguin's collision box/sprite mappings)
	ld   a, [sActSetX_Low]	; sActSetX -= $10
	sub  a, $10
	ld   [sActSetX_Low], a
	ld   a, [sActSetX_High]
	sbc  a, $00
	ld   [sActSetX_High], a
	ret
.setR:
	ld   a, [sActSetX_Low]	; sActSetX += $20
	add  $20
	ld   [sActSetX_Low], a
	ld   a, [sActSetX_High]
	adc  a, $00
	ld   [sActSetX_High], a
	ret
	
Act_PenguinSpikeBall_Move:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	call ActS_IncOBJLstIdEvery8
	
.doBounce:
	; Handle bounce effect.
	; This actor bounces at a constant rate, similar to the big coin.
	
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown					; Move down by that
	
	; If we're moving up, we don't need to check for collision on the ground.
	ld   a, [sActSetYSpeed_High]
	bit  7, a							; Are we moving up? (speed < 0)
	jr   nz, .incDropSpeed				; If so, skip this
.chkMoveDown:
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Are we touching a solid block?
	jr   z, .incDropSpeed				; If not, skip
	
	; Otherwisw, bounce up at 2px/frame
	ld   bc, -$02
	ld   a, c
	ld   [sActSetYSpeed_Low], a
	ld   a, b
	ld   [sActSetYSpeed_High], a
	ld   a, SFX1_0B					; Play SFX
	ld   [sSFX1Set], a
	
.incDropSpeed:
	; Every 4 frames increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $03
	jr   nz, .chkMoveH
	ld   a, [sActSetYSpeed_Low]
	add  $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00
	ld   [sActSetYSpeed_High], a
	
.chkMoveH:
	; Move the spikeball horizontally as specified
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_PenguinSpikeBall_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_PenguinSpikeBall_MoveLeft
	ret
; =============== Act_PenguinSpikeBall_CheckOffScreen ===============
; Despawns the spikeball as soon as it goes off-screen.
; NOTE: This is not necessary. 
;		The actor could have been spawned with the sActSetOpts flag ACTFLAGB_UNUSED_FREEOFFSCREEN.
Act_PenguinSpikeBall_CheckOffScreen:
	call ActS_CheckOffScreen	; Update offscreen status
	ld   a, [sActSet]
	cp   a, $02					; Is the actor visible & active?
	ret  nc						; If so, return
	xor  a						; Otherwise, despawn it
	ld   [sActSet], a
	ret
; =============== Act_PenguinSpikeBall_MoveLeft ===============
Act_PenguinSpikeBall_MoveLeft:
	ld   bc, -$01				; Move left 1px
	call ActS_MoveRight
	
	; Animate in that direction
	ld   a, LOW(OBJLstPtrTable_Act_PenguinSpikeBall_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_PenguinSpikeBall_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; If the spikeball goes against a solid block, mark as dead
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolid
	or   a
	jp   nz, SubCall_ActS_StartJumpDead_NoHeart
	ret
	
; =============== Act_PenguinSpikeBall_MoveRight ===============
Act_PenguinSpikeBall_MoveRight:
	ld   bc, +$01				; Move left 1px
	call ActS_MoveRight
	
	; Animate in that direction
	ld   a, LOW(OBJLstPtrTable_Act_PenguinSpikeBall_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_PenguinSpikeBall_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; If the spikeball goes against a solid block, mark as dead
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a
	jp   nz, SubCall_ActS_StartJumpDead_NoHeart
	ret
	
; =============== Act_Penguin_SpawnSpikeBall ===============
; Spawns the spikeball kicked by the actor.
Act_Penguin_SpawnSpikeBall:
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
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_PenguinSpikeBall
	
	ld   a, $02				; Enabled
	ldi  [hl], a
	; Same position as penguin
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
	
	ld   a, -$07			; Coli box U
	ldi  [hl], a
	ld   a, -$04			; Coli box D
	ldi  [hl], a
	ld   a, -$02			; Coli box L
	ldi  [hl], a
	ld   a, +$01			; Coli box R
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
	
	; Actor ID
	; This uses the same ID as the penguin, making it use the same tile base, among other things.
	ld   a, [sActSetId]			
	set  ACTB_NORESPAWN, a		; Don't make it respawn (it'd duplicate the penguin)
	ldi  [hl], a
	
	xor  a						; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_PenguinSpikeBall)		; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_PenguinSpikeBall)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer
	ld   a, $40
	ldi  [hl], a				; Timer 2 (delay before moving)
	xor  a
	ldi  [hl], a				; Y Speed (Low byte)
	ldi  [hl], a				; Y Speed (High byte)
	ldi  [hl], a				; Timer 5
	ldi  [hl], a				; Timer 6
	ldi  [hl], a				; Timer 7
	
	ld   a, $01					; Flags
	ldi  [hl], a
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	ld   a, LOW(OBJLstSharedPtrTable_Act_PenguinSpikeBall)	; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_PenguinSpikeBall)
	ld   [hl], a
	ret
OBJLstSharedPtrTable_Act_Penguin:
	dw OBJLstPtrTable_Act_Penguin_StunL;X
	dw OBJLstPtrTable_Act_Penguin_StunR;X
	dw OBJLstPtrTable_Act_Penguin_WalkL
	dw OBJLstPtrTable_Act_Penguin_WalkR
	dw OBJLstPtrTable_Act_Penguin_StunL
	dw OBJLstPtrTable_Act_Penguin_StunR
	dw OBJLstPtrTable_Act_Penguin_WalkL;X
	dw OBJLstPtrTable_Act_Penguin_WalkR;X
OBJLstSharedPtrTable_Act_PenguinSpikeBall:
	dw OBJLstPtrTable_Act_PenguinSpikeBall_MoveL;X
	dw OBJLstPtrTable_Act_PenguinSpikeBall_MoveR;X
	dw OBJLstPtrTable_Act_PenguinSpikeBall_MoveL;X
	dw OBJLstPtrTable_Act_PenguinSpikeBall_MoveR;X
	dw OBJLstPtrTable_Act_PenguinSpikeBall_MoveL
	dw OBJLstPtrTable_Act_PenguinSpikeBall_MoveR
	dw OBJLstPtrTable_Act_PenguinSpikeBall_MoveL;X
	dw OBJLstPtrTable_Act_PenguinSpikeBall_MoveR;X

OBJLstPtrTable_Act_Penguin_WalkL:
	dw OBJLst_Act_Penguin_WalkL0
	dw OBJLst_Act_Penguin_WalkL1
	dw OBJLst_Act_Penguin_WalkL0
	dw OBJLst_Act_Penguin_WalkL2
	dw $0000
OBJLstPtrTable_Act_Penguin_WalkR:
	dw OBJLst_Act_Penguin_WalkR0
	dw OBJLst_Act_Penguin_WalkR1
	dw OBJLst_Act_Penguin_WalkR0
	dw OBJLst_Act_Penguin_WalkR2
	dw $0000
OBJLstPtrTable_Act_Penguin_StunL:
	dw OBJLst_Act_Penguin_StunL
	dw $0000
OBJLstPtrTable_Act_Penguin_StunR:
	dw OBJLst_Act_Penguin_StunR
	dw $0000
; [TCRF] OpenLid and Kick get cut short... but it's more of the same.
OBJLstPtrTable_Act_Penguin_OpenLidL:
	dw OBJLst_Act_Penguin_WalkL0
	dw OBJLst_Act_Penguin_OpenLidL0
	dw OBJLst_Act_Penguin_OpenLidL1
	dw OBJLst_Act_Penguin_OpenLidL1
	dw OBJLst_Act_Penguin_OpenLidL1;X
	dw $0000;X
OBJLstPtrTable_Act_Penguin_OpenLidR:
	dw OBJLst_Act_Penguin_WalkR0
	dw OBJLst_Act_Penguin_OpenLidR0
	dw OBJLst_Act_Penguin_OpenLidR1
	dw OBJLst_Act_Penguin_OpenLidR1
	dw OBJLst_Act_Penguin_OpenLidR1;X
	dw $0000;X
OBJLstPtrTable_Act_Penguin_KickL:
	dw OBJLst_Act_Penguin_WalkL0
	dw OBJLst_Act_Penguin_WalkL0
	dw OBJLst_Act_Penguin_WalkL1
	dw OBJLst_Act_Penguin_WalkL1
	dw OBJLst_Act_Penguin_WalkL1;X
	dw $0000;X
OBJLstPtrTable_Act_Penguin_KickR:
	dw OBJLst_Act_Penguin_WalkR0
	dw OBJLst_Act_Penguin_WalkR0
	dw OBJLst_Act_Penguin_WalkR1
	dw OBJLst_Act_Penguin_WalkR1
	dw OBJLst_Act_Penguin_WalkR1;X
	dw $0000;X
OBJLstPtrTable_Act_Penguin_PostKickL:
	dw OBJLst_Act_Penguin_WalkL0
	dw $0000;X
OBJLstPtrTable_Act_Penguin_PostKickR:
	dw OBJLst_Act_Penguin_WalkR0
	dw $0000;X
	
OBJLstPtrTable_Act_PenguinSpikeBall_MoveL:
	dw OBJLst_Act_PenguinSpikeBall0
	dw OBJLst_Act_PenguinSpikeBall1
	dw OBJLst_Act_PenguinSpikeBall2
	dw OBJLst_Act_PenguinSpikeBall3
	dw OBJLst_Act_PenguinSpikeBall4
	dw $0000
; [BUG] This is identical to MoveL, but it should have been in reverse-order.
;		It's barely noticeable anyway.
OBJLstPtrTable_Act_PenguinSpikeBall_MoveR:
	dw OBJLst_Act_PenguinSpikeBall0
	dw OBJLst_Act_PenguinSpikeBall1
	dw OBJLst_Act_PenguinSpikeBall2
	dw OBJLst_Act_PenguinSpikeBall3
	dw OBJLst_Act_PenguinSpikeBall4
	dw $0000

OBJLst_Act_Penguin_WalkL0: INCBIN "data/objlst/actor/penguin_walkl0.bin"
OBJLst_Act_Penguin_WalkL1: INCBIN "data/objlst/actor/penguin_walkl1.bin"
OBJLst_Act_Penguin_WalkL2: INCBIN "data/objlst/actor/penguin_walkl2.bin"
OBJLst_Act_Penguin_OpenLidL0: INCBIN "data/objlst/actor/penguin_openlidl0.bin"
OBJLst_Act_Penguin_OpenLidL1: INCBIN "data/objlst/actor/penguin_openlidl1.bin"
OBJLst_Act_Penguin_StunL: INCBIN "data/objlst/actor/penguin_stunl.bin"
OBJLst_Act_PenguinSpikeBall0: INCBIN "data/objlst/actor/penguinspikeball0.bin"
OBJLst_Act_PenguinSpikeBall1: INCBIN "data/objlst/actor/penguinspikeball1.bin"
OBJLst_Act_PenguinSpikeBall2: INCBIN "data/objlst/actor/penguinspikeball2.bin"
OBJLst_Act_PenguinSpikeBall3: INCBIN "data/objlst/actor/penguinspikeball3.bin"
OBJLst_Act_PenguinSpikeBall4: INCBIN "data/objlst/actor/penguinspikeball4.bin"
OBJLst_Act_Penguin_WalkR0: INCBIN "data/objlst/actor/penguin_walkr0.bin"
OBJLst_Act_Penguin_WalkR1: INCBIN "data/objlst/actor/penguin_walkr1.bin"
OBJLst_Act_Penguin_WalkR2: INCBIN "data/objlst/actor/penguin_walkr2.bin"
OBJLst_Act_Penguin_OpenLidR0: INCBIN "data/objlst/actor/penguin_openlidr0.bin"
OBJLst_Act_Penguin_OpenLidR1: INCBIN "data/objlst/actor/penguin_openlidr1.bin"
OBJLst_Act_Penguin_StunR: INCBIN "data/objlst/actor/penguin_stunr.bin"
; [TCRF] Block of unused sprite mappings in the middle of this data.
;        These are similarly broken as the unused ones in Act_Cart.
OBJLst_Act_Penguin_Unused_00: INCBIN "data/objlst/actor/penguin_unused_00.bin"
OBJLst_Act_Penguin_Unused_01: INCBIN "data/objlst/actor/penguin_unused_01.bin"
OBJLst_Act_Penguin_Unused_02: INCBIN "data/objlst/actor/penguin_unused_02.bin"
OBJLst_Act_Penguin_Unused_03: INCBIN "data/objlst/actor/penguin_unused_03.bin"
OBJLst_Act_Penguin_Unused_04: INCBIN "data/objlst/actor/penguin_unused_04.bin"
GFX_Act_Penguin: INCBIN "data/gfx/actor/penguin.bin"

; =============== ActInit_DD ===============
; Boomerang-throwing duck.
ActInit_DD:
	; Setup collision box
	ld   a, -$18
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$06
	ld   [sActSetColiBoxL], a
	ld   a, +$06
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_DD
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_DD_WalkL
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_DD
	call ActS_SetOBJLstSharedTablePtr
	
	; Set collision type
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	xor  a
	ld   [sActDDTurnDelay], a
	ld   [sActLocalRoutineId], a
	ld   [sActDDThrowDelay], a
	ld   [sActDDYSpeed], a
	mSubCall ActS_SaveColiType ; BANK $02
	ld   a, $14					; Wait $14 frames before moving
	ld   [sActDDMoveDelay], a
	ret
	
OBJLstPtrTable_ActInit_Unused_DD:
	dw OBJLst_Act_DD_WalkL0;X
	dw $0000;X

; =============== Act_DD ===============
Act_DD:
	; If the actor is overlapping with a solid block, kill it
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolid
	or   a
	jp   nz, SubCall_ActS_StartJumpDead
	
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Do the routine table
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_DD_Main
	dw .onPlColiH
	dw .onPlColiTop
	dw SubCall_ActS_StartStarKill
	dw .onPlColiBelow
	dw .onPlColiBelow
	dw Act_DD_Walk;X
	dw SubCall_ActS_StartSwitchDir;X
	dw SubCall_ActS_StartJumpDeadSameColi
	
	; Since this is an heavy actor, show stars when stunned
.onPlColiH:
	call SubCall_ActS_SpawnStunStar
	jp   SubCall_ActS_OnPlColiH
.onPlColiTop:
	call SubCall_ActS_SpawnStunStar
	jp   SubCall_ActS_OnPlColiTop
.onPlColiBelow:
	call SubCall_ActS_SpawnStunStar
	jp   SubCall_ActS_OnPlColiBelow
	
; =============== Act_DD_Main ===============
Act_DD_Main:
	; If the screen is shaking, stun the actor
	ld   a, [sScreenShakeTimer]
	or   a
	jp   nz, SubCall_ActS_StartGroundPoundStun
	
	; If the actor isn't on solid ground, make him fall.
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is the actor on solid ground?
	jr   nz, .onGround					; If so, skip
	
	ld   a, [sActDDYSpeed]
	ld   c, a							; BC = sActPenguinYSpeed
	ld   b, $00
	call ActS_MoveDown					; Move down by that
	
	; Every 4 frames increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $03
	jr   nz, .chkRoutine
	ld   a, [sActDDYSpeed]
	inc  a
	ld   [sActDDYSpeed], a
	jr   .chkRoutine
.onGround:
	xor  a								; Reset drop speed
	ld   [sActDDYSpeed], a
.chkRoutine:
	; Check for the delay before moving
	ld   a, [sActDDMoveDelay]
	or   a								; Is the actor waiting to move?
	jr   nz, Act_DD_WaitMove					; If so, continue to wait
	
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_DD_Walk
	dw Act_DD_Walk;X	; [TCRF] Also here
	dw Act_DD_Alert
	dw Act_DD_ThrowBoomerang
	dw Act_DD_PostThrowWait
	
; =============== Act_DD_WaitMove ===============
; Handles the delay before moving.
Act_DD_WaitMove:
	ld   a, [sActDDMoveDelay]			; Timer--
	dec  a
	ld   [sActDDMoveDelay], a
	or   a							; Has it elapsed?
	ret  nz							; If not, return
	; Prepare for movement next frame
	ld   a, $28						; Otherwise, set the cooldown timer
	ld   [sActDDThrowDelay], a
	ret
	
; =============== Act_DD_Walk ===============
Act_DD_Walk:
	; Check for the delay before the actor can move again
	ld   a, [sActDDTurnDelay]
	or   a
	jr   nz, Act_DD_WaitTurn
	
	call ActS_IncOBJLstIdEvery8
	
	; Move depending on the actor's direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_DD_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_DD_MoveLeft
	
	; Handle cooldown timer for throwing boomerangs
	ld   a, [sActDDThrowDelay]
	or   a								; Has the cooldown timer elapsed yet?
	jr   z, Act_DD_CheckPlPos			; If so, try to throw a boomerang
	dec  a								; Otherwise, decrement it
	ld   [sActDDThrowDelay], a
	ret
	
; =============== Act_DD_CheckPlPos ===============	
; Determines if the player is in the range of the actor, and if so, throws a boomerang.
Act_DD_CheckPlPos:
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
	jp   nc, Act_DD_StartAlert	; If so, jump
	ret
.chkRangeR:
	ld   a, d				; If so, jump
	cp   e					; Is ActX < PlX?
	jp   c, Act_DD_StartAlert	; If so, jump
	ret
	
; =============== Act_DD_WaitTurn ===============
; Turns the actor once the turn timer elapses.
; IN
; - A: Must be sActDDTurnDelay.
Act_DD_WaitTurn:
	; Wait for the timer to elapse
	dec  a					; sActWolfTurnDelay--
	or   a
	ld   [sActDDTurnDelay], a	; Save back value
	ret  nz					; Did the timer elapse? If not, return
	
	; Now we can turn.
	ld   a, $14				; Wait $14 frames before moving		
	ld   [sActDDMoveDelay], a
	ld   a, [sActSetDir]	; Invert direction
	xor  DIR_L|DIR_R
	ld   [sActSetDir], a
	
	; Depending on the new direction, set the animation.
	bit  DIRB_R, a			; Facing right?
	jr   nz, .dirR			; If so, jump
.dirL:
	push bc
	ld   bc, OBJLstPtrTable_Act_DD_WalkL
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.dirR:
	push bc
	ld   bc, OBJLstPtrTable_Act_DD_WalkR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_DD_SetTurnDelay ===============
; Makes the actor delay for $14 frames before turning.
; as well as making the actor stop throwing boomerangs for $50 frames after starting to move.
Act_DD_SetTurnDelay:
	ld   a, $14					; Wait $14 before turning
	ld   [sActDDTurnDelay], a
	jp   Act_DD_SetThrowDelay	; Wait $50 before shooting
	
; =============== Act_DD_MoveLeft ===============
; Moves the actor to the left.
Act_DD_MoveLeft:
	; If there's any solid block in the way, delay for a bit before turning
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, Act_DD_SetTurnDelay
	
	; If there isn't solid ground on the left, delay for a bit before turning
	call ActColi_GetBlockId_BottomL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, Act_DD_SetTurnDelay
	
	; Move left 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveRight
	
	ld   a, LOW(OBJLstPtrTable_Act_DD_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_DD_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Make the actor face left
	ld   a, [sActSetDir]
	and  a, $F8				
	or   a, DIR_L
	ld   [sActSetDir], a
	ret
	
; =============== Act_DD_MoveRight ===============
; Moves the actor to the right.
Act_DD_MoveRight:
	; If there's any solid block in the way, delay for a bit before turning
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, Act_DD_SetTurnDelay
	
	; If there isn't solid ground on the right, delay for a bit before turning
	call ActColi_GetBlockId_BottomR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, Act_DD_SetTurnDelay
	
	; Move right 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveRight
	
	ld   a, LOW(OBJLstPtrTable_Act_DD_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_DD_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Make the actor face right
	ld   a, [sActSetDir]
	and  a, $F8				
	or   a, DIR_R
	ld   [sActSetDir], a
	ret
	
; =============== Act_DD_StartAlert ===============
Act_DD_StartAlert:
	ld   a, DD_RTN_ALERT
	ld   [sActLocalRoutineId], a
	ld   a, $60
	ld   [sActDDModeTimer], a
	
	; Pick a different animation depending on the direction the actor's facing.
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Is the actor facing right?
	jr   nz, .dirR				; If so, jump
.dirL:
	push bc
	ld   bc, OBJLstPtrTable_Act_DD_AlertL
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.dirR:
	push bc
	ld   bc, OBJLstPtrTable_Act_DD_AlertR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_DD_Alert ===============
Act_DD_Alert:
	; Handle the timer
	ld   a, [sActDDModeTimer]
	or   a						; Timer elapsed?
	jr   z, .endMode			; If so, return
	dec  a						; Otherwise, timer--;
	ld   [sActDDModeTimer], a
	
	call ActS_IncOBJLstIdEvery8
	
	; Every $20 frames play the boomerang alert SFX
	ld   a, [sActDDModeTimer]
	and  a, $1F
	ret  nz
	ld   a, SFX4_15
	ld   [sSFX4Set], a
	ret
.endMode:
	ld   a, SFX4_16		; Play boomerang throw SFX
	ld   [sSFX4Set], a
	ld   a, DD_RTN_THROW		; Set routine id
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActDDModeTimer], a
	
	; Depending on the direction facing, set a different anim
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Facing right?
	jr   nz, .dirR			; If so, jump
.dirL:
	push bc
	ld   bc, OBJLstPtrTable_Act_DD_ThrowL
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.dirR:
	push bc
	ld   bc, OBJLstPtrTable_Act_DD_ThrowR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_DD_ThrowBoomerang ===============
; Waits for a bit before throwing the boomerang.
Act_DD_ThrowBoomerang:
	; Spawn the knife once the animation ends
	ld   a, [sActSetOBJLstId]
	cp   a, $03						; Has the animation ended? (frame >= $03)
	jr   nc, .endMode				; If so, jump
	
	; Otherwise continue animating it every 8 frames
	call ActS_IncOBJLstIdEvery8
	ret
.endMode:
	ld   a, DD_RTN_POSTTHROW
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActDDModeTimer], a
	; Throw the boomerang
	call Act_DD_SpawnBoomerang
	ret
	
; =============== Act_DD_PostThrowWait ===============
; Waits for a bit before starting to move again.
Act_DD_PostThrowWait:
	; Wait for $50 frames before moving again.
	; This is enough time for the boomerang to return back.
	ld   a, [sActDDModeTimer]
	cp   a, $50					; Timer reached the target value?
	jr   nc, Act_DD_SetThrowDelay	; If so, return
	inc  a
	ld   [sActDDModeTimer], a
	
	; Pick the correct anim depending on the direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	jr   nz, .dirR				; If so, jump
.dirL:
	push bc
	ld   bc, OBJLstPtrTable_Act_DD_PostThrowL
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.dirR:
	push bc
	ld   bc, OBJLstPtrTable_Act_DD_PostThrowR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
; =============== Act_DD_SetThrowDelay ===============
; Makes the actor stop throwing boomerangs for $50 frames after starting to move.
Act_DD_SetThrowDelay:
	; Move immediately, but wait for $28 frames before another boomerang
	xor  a
	ld   [sActLocalRoutineId], a
	ld   a, $28
	ld   [sActDDThrowDelay], a
	ret
	
; =============== Act_DDBoomerang ===============
; Helper boomerang actor spawned by Act_DD.
Act_DDBoomerang:
	call Act_DDBoomerang_CheckOffScreen
	
	; Every other frame update the anim counter
	ld   a, [sTimer]
	and  a, $01
	jr   nz, .move
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	
.move:
	ld   a, [sActSetTimer]				; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Despawn after $6E frames
	cp   a, $6E					
	jr   nc, Act_DDBoomerang_Despawn
	; Turn back after $3C frames
	cp   a, $3C
	call z, Act_DDBoomerang_Turn
	
	; Move the boomerang as specified
	call Act_DDBoomerang_MoveVert
	ld   a, [sActSetDir]
	bit  DIRB_R, a						; Is it moving right?
	call nz, Act_DDBoomerang_MoveRight	; If so, move right
	ld   a, [sActSetDir]
	bit  DIRB_L, a						; Is it moving left?
	call nz, Act_DDBoomerang_MoveLeft	; If so, move left
	ret
	
; =============== Act_DDBoomerang_CheckOffScreen ===============
; Despawns the actor as soon as it goes off-screen.
; NOTE: This is not necessary. 
;		The actor could have been spawned with the sActSetOpts flag ACTFLAGB_UNUSED_FREEOFFSCREEN.
Act_DDBoomerang_CheckOffScreen:
	call ActS_CheckOffScreen	; Update offscreen status
	ld   a, [sActSet]
	cp   a, $02					; Is the actor visible & active?
	ret  nc						; If so, return
	xor  a						; Otherwise, despawn it
	ld   [sActSet], a
	ret
; =============== Act_DDBoomerang_Despawn ===============
Act_DDBoomerang_Despawn:
	xor  a
	ld   [sActSet], a
	ret
; =============== Act_DDBoomerang_MoveLeft ===============
Act_DDBoomerang_MoveLeft:
	ld   bc, -$01
	call ActS_MoveRight
	ld   a, LOW(OBJLstPtrTable_Act_DDBoomerang_SpinL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_DDBoomerang_SpinL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
; =============== Act_DDBoomerang_MoveRight ===============
Act_DDBoomerang_MoveRight:
	ld   bc, +$01
	call ActS_MoveRight
	ld   a, LOW(OBJLstPtrTable_Act_DDBoomerang_SpinR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_DDBoomerang_SpinR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
; =============== Act_DDBoomerang_MoveVert ===============
; Handles the vertical movement arc of the boomerang.
Act_DDBoomerang_MoveVert:
	; A couple of notes about this:
	;
	; - We use the timer to generate the index to a Y offset table,
	;   since it starts at $00 when this spawns, and increases every frame.
	; - The value we're AND'ing with has its 3 lowest bits clear --
	;   meaning every 8 frames the index will increase.
	; - Every table entry is two bytes large. This takes up bit 0, leaving 2 empty bits.
	;   So the offset to the table entry, after AND'ing the 3 lowest bits,
	;   has to be >> 2'd.
	; - Because the same index could be used for multiple frames, there needs
	;   to be a way to tell when the boomerang can be moved.
	;	This results in this table format:
	;   - The first byte is a mask AND'ed with the timer, like with animation masks.
	;     The Y offset gets added over only if Mask & Timer == 0.
	;   - The second byte is the Y offset, added over the current Y pos.
	
	; Offset the Y offset table
	ld   a, [sActSetTimer]	; DE = Timer / 8 * 2
	and  a, %01111000		; Update position every 8 frames
	rrca					; >> 1
	rrca					; >> 1
	ld   e, a
	ld   d, $00
	ld   hl, Act_DDBoomerang_YPath	; HL = Y offset table
	add  hl, de							; Offset it
	
	; Check if we can move the boomerang this frame
	ldi  a, [hl]			; B = Movement Mask (byte 0)
	ld   b, a
	ld   a, [sActSetTimer]	; A = Timer
	and  a, b				; Mask & Timer != 0?
	ret  nz					; If so, return
	
	; Move the boomerang down by that.
	; ActS_MoveDown takes in a 16bit number, so we have to sign-extend this.
	ld   a, [hl]			; C = Movement value (byte 1)
	ld   c, a
	sext a					; B = Sign extended C
	ld   b, a
	call ActS_MoveDown		; Move down by that
	ret
	
	
; =============== Act_DDBoomerang_YPath ===============
; Table format:
;  - $00 | Speed mask, AND'ed over the timer
;  - $01 | Y offset, added over the current Y pos.
Act_DDBoomerang_YPath:
	;  MASK|SPEED
	db $07, +$00
	db $07, +$00
	db $07, +$00
	db $07, +$00
	db $03, -$01
	db $01, -$01
	db $01, -$01
	db $00, -$01
	db $01, -$01
	db $03, -$01
	db $07, +$00
	db $07, +$00
	db $03, +$01
	db $01, +$01
	; [TCRF] The boomerang anim gets cut short
	db $00, +$01;X
	db $00, +$01;X
	
; =============== Act_DDBoomerang_Turn ===============
; Makes the boomerang turn direction, used at the peak for horizontal movement.
Act_DDBoomerang_Turn:
	ld   a, [sActSetDir]		; Switch direction
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	xor  a						; Reset anim frame
	ld   [sActSetOBJLstId], a
	ret
; =============== Act_DD_SpawnBoomerang ===============
; Spawns the boomerang thrown by the actor.
Act_DD_SpawnBoomerang:
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
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_DD
	
	ld   a, $02				; Enabled
	ldi  [hl], a
	
	ld   a, [sActSetX_Low]	; X = sActSetX + $08
	add  $08
	ldi  [hl], a
	ld   a, [sActSetX_High]
	adc  a, $00
	ldi  [hl], a
	
	ld   a, [sActSetY_Low]	; Y = sActSetY
	ldi  [hl], a
	ld   a, [sActSetY_High]
	ldi  [hl], a
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ldi  [hl], a
	
	ld   a, -$07			; Coli box U
	ldi  [hl], a
	ld   a, -$04			; Coli box D
	ldi  [hl], a
	ld   a, -$07			; Coli box L
	ldi  [hl], a
	ld   a, -$04			; Coli box R
	ldi  [hl], a
	
	ld   a, $00
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_DDBoomerang_SpinL)		; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_DDBoomerang_SpinL)
	ldi  [hl], a
	
	ld   a, [sActSetDir]		; Dir
	ldi  [hl], a
	xor  a						; OBJLst ID
	ldi  [hl], a
	
	
	; Actor ID
	; This uses the same ID as DD, making it use the same tile base, among other things.
	ld   a, [sActSetId]			
	set  ACTB_NORESPAWN, a		; Don't make the boomerang respawn (it'd duplicate the DD)
	ldi  [hl], a
	
	xor  a						; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_DDBoomerang)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_DDBoomerang)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	ldi  [hl], a				; Timer 3
	ldi  [hl], a				; Timer 4
	ldi  [hl], a				; Timer 5
	ldi  [hl], a				; Timer 6
	ldi  [hl], a				; Timer 7
	
	; [NOTE] This could have used ACTFLAG_UNUSED_FREEOFFSCREEN
	ld   a, $01					; Flags
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_DD)		; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_DD)
	ldi  [hl], a
	ret
OBJLstSharedPtrTable_Act_DD:
	dw OBJLstPtrTable_Act_DD_StunL;X
	dw OBJLstPtrTable_Act_DD_StunR;X
	dw OBJLstPtrTable_Act_DD_StunL
	dw OBJLstPtrTable_Act_DD_StunR
	dw OBJLstPtrTable_Act_DD_StunL
	dw OBJLstPtrTable_Act_DD_StunR
	dw OBJLstPtrTable_Act_DD_StunL;X
	dw OBJLstPtrTable_Act_DD_StunR;X

OBJLstPtrTable_Act_DD_WalkL:
	dw OBJLst_Act_DD_WalkL0
	dw OBJLst_Act_DD_WalkL1
	dw OBJLst_Act_DD_WalkL0
	dw OBJLst_Act_DD_WalkL2
	dw $0000
OBJLstPtrTable_Act_DD_WalkR:
	dw OBJLst_Act_DD_WalkR0
	dw OBJLst_Act_DD_WalkR1
	dw OBJLst_Act_DD_WalkR0
	dw OBJLst_Act_DD_WalkR2
	dw $0000
OBJLstPtrTable_Act_DD_StunL:
	dw OBJLst_Act_DD_StunL
	dw $0000
OBJLstPtrTable_Act_DD_StunR:
	dw OBJLst_Act_DD_StunR
	dw $0000
OBJLstPtrTable_Act_DD_AlertL:
	dw OBJLst_Act_DD_WalkL0
	dw OBJLst_Act_DD_AlertL0
	dw OBJLst_Act_DD_WalkL0
	dw OBJLst_Act_DD_AlertL1
	dw $0000
OBJLstPtrTable_Act_DD_AlertR:
	dw OBJLst_Act_DD_WalkR0
	dw OBJLst_Act_DD_AlertR0
	dw OBJLst_Act_DD_WalkR0
	dw OBJLst_Act_DD_AlertR1
	dw $0000
OBJLstPtrTable_Act_DD_ThrowL:
	dw OBJLst_Act_DD_WalkL0
	dw OBJLst_Act_DD_AlertL0
	dw OBJLst_Act_DD_WalkL0
	dw OBJLst_Act_DD_ThrowL
	dw $0000;X
OBJLstPtrTable_Act_DD_ThrowR:
	dw OBJLst_Act_DD_WalkR0
	dw OBJLst_Act_DD_AlertR0
	dw OBJLst_Act_DD_WalkR0
	dw OBJLst_Act_DD_ThrowR
	dw $0000;X
OBJLstPtrTable_Act_DD_PostThrowL:
	dw OBJLst_Act_DD_ThrowL
	dw $0000;X
OBJLstPtrTable_Act_DD_PostThrowR:
	dw OBJLst_Act_DD_ThrowR
	dw $0000;X
OBJLstPtrTable_Act_DDBoomerang_SpinL:
	dw OBJLst_Act_DDBoomerang0
	dw OBJLst_Act_DDBoomerang1
	dw OBJLst_Act_DDBoomerang2
	dw OBJLst_Act_DDBoomerang3
	dw OBJLst_Act_DDBoomerang4
	dw OBJLst_Act_DDBoomerang5
	dw OBJLst_Act_DDBoomerang6
	dw OBJLst_Act_DDBoomerang7
	dw $0000
OBJLstPtrTable_Act_DDBoomerang_SpinR:
	dw OBJLst_Act_DDBoomerang7
	dw OBJLst_Act_DDBoomerang6
	dw OBJLst_Act_DDBoomerang5
	dw OBJLst_Act_DDBoomerang4
	dw OBJLst_Act_DDBoomerang3
	dw OBJLst_Act_DDBoomerang2
	dw OBJLst_Act_DDBoomerang1
	dw OBJLst_Act_DDBoomerang0
	dw $0000

OBJLst_Act_DD_WalkL0: INCBIN "data/objlst/actor/dd_walkl0.bin"
OBJLst_Act_DD_AlertL0: INCBIN "data/objlst/actor/dd_alertl0.bin"
OBJLst_Act_DD_AlertL1: INCBIN "data/objlst/actor/dd_alertl1.bin"
OBJLst_Act_DD_StunL: INCBIN "data/objlst/actor/dd_stunl.bin"
; [TCRF] Unused duplicate of OBJLst_Act_DD_WalkL0.
OBJLst_Act_DD_Unused_WalkL0Copy: INCBIN "data/objlst/actor/dd_unused_walkl0_copy.bin"
OBJLst_Act_DD_WalkL1: INCBIN "data/objlst/actor/dd_walkl1.bin"
OBJLst_Act_DD_WalkL2: INCBIN "data/objlst/actor/dd_walkl2.bin"
OBJLst_Act_DD_ThrowL: INCBIN "data/objlst/actor/dd_throwl.bin"
OBJLst_Act_DDBoomerang0: INCBIN "data/objlst/actor/ddboomerang0.bin"
OBJLst_Act_DDBoomerang2: INCBIN "data/objlst/actor/ddboomerang2.bin"
OBJLst_Act_DDBoomerang4: INCBIN "data/objlst/actor/ddboomerang4.bin"
OBJLst_Act_DDBoomerang6: INCBIN "data/objlst/actor/ddboomerang6.bin"
OBJLst_Act_DDBoomerang7: INCBIN "data/objlst/actor/ddboomerang7.bin"
OBJLst_Act_DDBoomerang1: INCBIN "data/objlst/actor/ddboomerang1.bin"
OBJLst_Act_DDBoomerang3: INCBIN "data/objlst/actor/ddboomerang3.bin"
OBJLst_Act_DDBoomerang5: INCBIN "data/objlst/actor/ddboomerang5.bin"
OBJLst_Act_DD_WalkR0: INCBIN "data/objlst/actor/dd_walkr0.bin"
OBJLst_Act_DD_AlertR0: INCBIN "data/objlst/actor/dd_alertr0.bin"
OBJLst_Act_DD_AlertR1: INCBIN "data/objlst/actor/dd_alertr1.bin"
OBJLst_Act_DD_StunR: INCBIN "data/objlst/actor/dd_stunr.bin"
; [TCRF] Unused duplicate of OBJLst_Act_DD_WalkR0.
OBJLst_Act_DD_Unused_WalkR0Copy: INCBIN "data/objlst/actor/dd_unused_walkr0_copy.bin"
OBJLst_Act_DD_WalkR1: INCBIN "data/objlst/actor/dd_walkr1.bin"
OBJLst_Act_DD_WalkR2: INCBIN "data/objlst/actor/dd_walkr2.bin"
OBJLst_Act_DD_ThrowR: INCBIN "data/objlst/actor/dd_throwr.bin"
; [TCRF] Unused broken mappings like Act_Cart.
;        Again, these are likely not meant to be for this actor, even though they've been put here.
OBJLst_Act_DD_Unused_01: INCBIN "data/objlst/actor/dd_unused_01.bin"
OBJLst_Act_DD_Unused_02: INCBIN "data/objlst/actor/dd_unused_02.bin"
OBJLst_Act_DD_Unused_03: INCBIN "data/objlst/actor/dd_unused_03.bin"
OBJLst_Act_DD_Unused_04: INCBIN "data/objlst/actor/dd_unused_04.bin"
OBJLst_Act_DD_Unused_05: INCBIN "data/objlst/actor/dd_unused_05.bin"
OBJLst_Act_DD_Unused_06: INCBIN "data/objlst/actor/dd_unused_06.bin"
OBJLst_Act_DD_Unused_07: INCBIN "data/objlst/actor/dd_unused_07.bin"
OBJLst_Act_DD_Unused_08: INCBIN "data/objlst/actor/dd_unused_08.bin"
GFX_Act_DD: INCBIN "data/gfx/actor/dd.bin"

; =============== ActInit_PouncerDrop ===============
ActInit_PouncerDrop:
	; Respawn at the original actor layout position, since
	; the spawn location has a special purpose here.
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$20
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$0A
	ld   [sActSetColiBoxL], a
	ld   a, +$0A
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_PouncerDrop
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_PouncerDrop
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_PouncerDrop
	call ActS_SetOBJLstSharedTablePtr
	
	; Make every side except the top bounce the player.
	; The bounce effect will have to be overridden to instakill the player.
	ld   a, ACTCOLI_BIGBLOCK
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	; Make it drop immediately when it spawns
	xor  a
	ld   [sActPouncerDropPostDropDelay], a
	ld   [sActPouncerDropPreDropDelay], a
	ld   [sActSetYSpeed_Low], a
	
	;--
	; Save the original spawn position.
	; When this Y position is reached, the actor drops down.
	
	; However, this position is relative to the screen, meaning it won't work properly
	; in free scroll mode.
	ld   a, [sActSetRelY]
	ld   [sActPouncerDropYTarget], a
	;--
	
	; Define upwards speed of 0.625px/frame.
	ld   a, %01101011
	ld   [sActPouncerDropMoveUMask], a
	ret
	
OBJLstPtrTable_ActInit_PouncerDrop:
	dw OBJLst_Act_Pouncer_Angry
	dw $0000;X

; =============== Act_PouncerDrop ===============
Act_PouncerDrop:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_PouncerDrop_Main
	dw .kill;X
	dw .kill;X
	dw Act_PouncerDrop_Main;X
	dw .kill
	dw .kill;X
	dw Act_PouncerDrop_Main ; Standing on top
	dw .kill
	dw Act_PouncerDrop_Main;X
	
; Make any contact except for standing on top instakill the player
; regardless of invincibility status.
; Doing this also means we don't need to care about the player potentially
; getting stuck when invincible.
.kill:
	call Pl_StartDeathAnim
	
; =============== Act_PouncerDrop_Main ===============
Act_PouncerDrop_Main:
	; Override animation always
	ld   a, LOW(OBJLstPtrTable_Act_PouncerDrop_Angry)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_PouncerDrop_Angry)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Every $10 frames increase the anim frame
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .chkTimers
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	
.chkTimers:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; A pair of timers here decide when the drop starts or ends.
	
	; Are we pausing for a bit before starting to drop?
	ld   a, [sActPouncerDropPreDropDelay]
	or   a									; sActPouncerDropPreDropDelay != 0?
	jr   nz, Act_PouncerDrop_WaitBeforeDrop	; If so, jump
	
	; Are we in the middle of a drop?
	ld   a, [sActPouncerDropPostDropDelay]
	or   a									; sActPouncerDropPostDropDelay == 0?
	jr   z, Act_PouncerDrop_Drop			; If so, jump
	
	; Are we pausing for a bit after ending the drop? (during the screen shake)
	ld   a, [sActPouncerDropPostDropDelay]
	cp   a, $3C								; sActPouncerDropPostDropDelay < $3C?
	jr   c, Act_PouncerDrop_WaitAfterDrop	; If so, jump
	
; =============== Act_PouncerDrop_MoveUp ===============
; In this mode, the actor moves up slowly until the target pos is reached.
Act_PouncerDrop_MoveUp:
	ld   a, LOW(OBJLstPtrTable_Act_PouncerDrop_Neutral)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_PouncerDrop_Neutral)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Check if we reached the target Y pos, and if so, stop moving for a bit before dropping.
	ld   a, [sActSetRelY]		; B = Y pos
	ld   b, a
	ld   a, [sActPouncerDropYTarget]; A = Target pos
	cp   a, b					; TargetPos > YPos?
	jr   nc, .endMode			; If so, jump (we reached the target)

	; Every frame we get here, the movement mask gets rotated right,
	; copying over bit 0 to the carry.
	; We can move up 1px only if this bit is set.
	
	ld   a, [sActPouncerDropMoveUMask]	
	rrca							; RotateR + copy bit0 to carry
	ld   [sActPouncerDropMoveUMask], a	; Save back mask
	ret  nc							; Was that bit == 0? If so, return
	; Otherwise, move up 1px
	ld   bc, -$01
	call ActS_MoveDown
	
	; Also move the player if needed
	ld   a, [sActSetRoutineId]
	and  a, $0F						
	cp   a, $06								; Is the player standing on top?
	ld   b, $01
	call z, SubCall_PlBGColi_DoTopAndMove	; If so, move it up too
	
	ret
	
.endMode:
	xor  a							
	ld   [sActPouncerDropPostDropDelay], a
	ld   a, $3C						
	ld   [sActPouncerDropPreDropDelay], a
	ret
	
; =============== Act_PouncerDrop_WaitBeforeDrop ===============
; In this mode, the actor waits while the timer elapses.
; In the middle of this, the animation is updated to the angry frame.
Act_PouncerDrop_WaitBeforeDrop:
	; Set the angry face at first
	ld   a, LOW(OBJLstPtrTable_Act_PouncerDrop_Angry)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_PouncerDrop_Angry)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Handle the timer...
	ld   a, [sActPouncerDropPreDropDelay]			; Timer--;
	dec  a
	ld   [sActPouncerDropPreDropDelay], a
	cp   a, $14									; Timer < $14?
	ret  c										; If so, return
	
	; Then, if the timer was >= $14, write back the neutral face
	ld   a, LOW(OBJLstPtrTable_Act_PouncerDrop_Neutral)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_PouncerDrop_Neutral)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
; =============== Act_PouncerDrop_WaitAfterDrop ===============
; Simply increases the timer continuously.
Act_PouncerDrop_WaitAfterDrop:
	ld   a, [sActPouncerDropPostDropDelay]
	inc  a
	ld   [sActPouncerDropPostDropDelay], a
	ret
	
; =============== Act_PouncerDrop_Drop ===============
; This is the mode where the actor drops down at a faster speed.
; This mode ends when it reaches solid ground.
Act_PouncerDrop_Drop:

	;--
	;
	; Check if we're on solid ground before moving down.
	;
	; Since the pouncer has a big collision box, two blocks have to be checked.
	; If any of the two blocks is marked as solid on top, this has ground.
	;

	call ActColi_GetBlockId_GroundHorz	; Read block IDs for both blocks below		
	; -  B: Block ID on the left
	; -  C: Block ID on the right

	; Block ID on the left
	ld   a, b							
	push bc
	mSubCall ActBGColi_IsSolidOnTop		; D = If 1, the block is solid
	ld   d, a
	pop  bc
	
	; Block ID on the right
	ld   a, c
	push de
	mSubCall ActBGColi_IsSolidOnTop		; A = if 1, the block is solid
	pop  de
	or   a, d							; Are any of them solid? (a == 1 || d == 1)?
	jr   nz, .onGround					; If so, jump (we've reached solid ground)
	;--
.moveDown:
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed_Low
	ld   c, a
	ld   b, $00
	call ActS_MoveDown					; Move down by that
	
	; Every 4 frames increase the anim counter
	ld   a, [sActSetTimer]
	and  a, $03
	jr   nz, .end
	ld   a, [sActSetYSpeed_Low]
	inc  a
	ld   [sActSetYSpeed_Low], a
	
	jr   .end
	
.onGround:
	; When the ground is reached, perform a screen shake effect.
	
	; Execution will get here twice:
	; - After landing, when the Y speed is still != 0.
	;	The screen shake is triggered and the speed gets reset to 0.
	; - The next frame, where it will just setup the delay before moving up again.
	
	; [TCRF] If the drop speed isn't high enough, it will skip the screen shake.
	;        However, none of the ones placed in-game can trigger this behaviour.
	ld   a, [sActSetYSpeed_Low]
	cp   a, $05					; sActSetYSpeed_Low < $05?
	jr   c, .endMode			; If so, jump
	
	mSetScreenShakeFor8
	
	;--
	; When not jumping, drop anything except the key
	ld   a, [sActHeldKey]
	or   a					; Holding a key?
	jr   nz, .playSFX		; If so, skip
	ld   a, [sPlAction]
	cp   a, PL_ACT_JUMP		; Are we jumping?
	jr   z, .playSFX		; If so, skip
	xor  a					; Otherwise, drop the actor
	ld   [sActHeld], a
	;--
	
.playSFX:
	ld   a, SFX4_02	; Play alternate SFX
	ld   [sSFX4Set], a
	call Act_PouncerDrop_KillOtherAct
	
	xor  a						; Reset speed. This will cause a jump to .endMode the next frame.
	ld   [sActSetYSpeed_Low], a
	
	ld   a, [sActSetY_Low]		; Align actor to Y block grid		
	and  a, $F0
	ld   [sActSetY_Low], a
	
	ld   bc, -$08				; Move down 8px/frame
	call ActS_MoveDown
.end:
	ret
.endMode:
	ld   a, $01
	ld   [sActPouncerDropPostDropDelay], a
	ret
	
; =============== Act_PouncerDrop_KillOtherAct ===============
; Instakills any other actor below the pouncer, and releases a 10 coin in its place.
Act_PouncerDrop_KillOtherAct:
	; Set the actor's direction to be torwards the player.
	; This is done so, when the coin is spawned, it moves torwards the player.
	call ActS_GetPlDirHRel						
	ld   [sActSetDir], a	
	
	; Fun reuse of the subroutine that normally handles collision for the thrown actor.
	;
	; If there's any collision between the two actors, in *both* the instakill routine will be set.
	; What this ends up doing is:
	; - trigger the instakill on the *other* actor
	; - notify us if collision occurred by checking *our* routine ID
	;
	; Of course, to avoid broken behaviour we then need to reset the routine ID of our actor.
	; We can't leave it to $03 (even though it acts the same as $00 here) since it'd cause
	; any further drop to leave 10-coins.
	
	ld   a, ACTRTN_03					; Trigger instakill on collision
	ld   [sActHeldColiRoutineId], a		
	ld   a, [sActNumProc]				; Do it
	call SubCall_ActHeldOrThrownActColi_Do
	
	; If the actor collided with any other one, spawn a 10-coin.
	ld   a, [sActSetRoutineId]			; Read result
	and  a, $0F							; filter away direction/slot info
	cp   a, ACTRTN_03					; Did the collision occur?
	call z, SubCall_ActS_Spawn10Coin	; If so, spawn a 10-coin in place of the killed actor
	
	xor  a								; Cleanup
	ld   [sActSetRoutineId], a
	ret
	
OBJLstPtrTable_Act_PouncerDrop_Neutral:
	dw OBJLst_Act_Pouncer_Neutral
	dw $0000
OBJLstPtrTable_Act_PouncerDrop_Angry:
	dw OBJLst_Act_Pouncer_Angry
	dw $0000

OBJLstSharedPtrTable_Act_PouncerDrop:
	dw OBJLstPtrTable_Act_PouncerDrop_Angry;X
	dw OBJLstPtrTable_Act_PouncerDrop_Angry;X
	dw OBJLstPtrTable_Act_PouncerDrop_Angry;X
	dw OBJLstPtrTable_Act_PouncerDrop_Angry;X
	dw OBJLstPtrTable_Act_PouncerDrop_Angry;X
	dw OBJLstPtrTable_Act_PouncerDrop_Angry;X
	dw OBJLstPtrTable_Act_PouncerDrop_Angry;X
	dw OBJLstPtrTable_Act_PouncerDrop_Angry;X

OBJLst_Act_Pouncer_Angry: INCBIN "data/objlst/actor/pouncer_angry.bin"
OBJLst_Act_Pouncer_Neutral: INCBIN "data/objlst/actor/pouncer_neutral.bin"
GFX_Act_Pouncer: INCBIN "data/gfx/actor/pouncer.bin"

; =============== ActInit_PouncerFollow ===============
ActInit_PouncerFollow:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$20
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$0A
	ld   [sActSetColiBoxL], a
	ld   a, +$0A
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_PouncerFollow
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_PouncerFollow
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_PouncerDrop
	call ActS_SetOBJLstSharedTablePtr
	
	ld   a, $00							; Collision will be set later
	ld   [sActSetColiType], a
	ld   a, $40							; (not necessary here)
	ld   [sActPouncerFollowDownDelay], a
	xor  a								; (not used)
	ld   [sActSetYSpeed_Low], a
	ld   a, PCFW_DIR_R					; Start by moving right
	ld   [sActPouncerFollowDir], a
	ret
	
; =============== Act_PouncerFollow ===============
Act_PouncerFollow:
	ld   a, LOW(OBJLstPtrTable_Act_PouncerFollow)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_PouncerFollow)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Every $10 frames increase the anim frame
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .setColi
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	
.setColi:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; To save on time, if the actor is off-screen, make it intangible 
	xor  a							; Clear collision
	ld   [sActSetColiType], a
	ld   a, [sActSet]				; Read status
	cp   a, $02						; Is it visible & active?
	jr   c, Act_PouncerFollow_Main	; If not, jump
	ld   a, ACTCOLI_BIGBLOCK		; Otherwise set the real collision
	ld   [sActSetColiType], a
	
	; Do the routine jump
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_PouncerFollow_Main
	dw .kill;X
	dw .kill;X
	dw Act_PouncerFollow_Main;X
	dw .kill;X
	dw .kill;X
	dw Act_PouncerFollow_Main
	dw .kill;X
	dw Act_PouncerFollow_Main;X
.kill:
	call Pl_StartDeathAnim
	
; =============== Act_PouncerFollow_Main ===============
Act_PouncerFollow_Main:
	; This actor tries to move in a path along the ground.
	
	;
	; DOWN DIRECTION
	; Move down, otherwise move right.
	;
	ld   a, [sActPouncerFollowDir]
	cp   a, PCFW_DIR_D							; Are we trying to move down?
	jr   nz, .chkDirR							; If not, jump
.chkMoveD:
	call Act_PouncerFollow_GetBlockId_GroundL
	mSubCall ActBGColi_IsSolid
	or   a										; Is there a solid block below?
	jp   z, Act_PouncerFollow_MoveDown			; If not, move down
	
	ld   a, $02									; Otherwise, try moving right next time
	ld   [sActPouncerFollowDir], a
	ret
	
	;
	; RIGHT DIRECTION (from above)
	; If possible move down, otherwise continue right, and if even that fails move up.
	;
.chkDirR:
	ld   a, [sActPouncerFollowDir]
	cp   a, PCFW_DIR_R							; Are we trying to move down?
	jr   nz, .chkDirU							; If not, jump
.chkMoveR:
	; priority check
	call Act_PouncerFollow_GetBlockId_GroundL
	mSubCall ActBGColi_IsSolid					
	or   a										; Is there a solid block below?
	jr   z, .setBackD							; If not, move down next time
	
	call Act_PouncerFollow_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a										; Is there a solid block on the right?
	jp   z, Act_PouncerFollow_MoveRight			; If not, move right
	
	; [POI] This "randomization" isn't necessary. 
	;		In practice we can only move up when we get here, since there's already
	;		a check for moving down.
	; Otherwise, pick a vertical direction ($01 or $03) depending on the execution timer.
	ld   a, [sActSetTimer]						
	and  a, $02									; DIR = (Timer & $02)++
	or   a, $01
	ld   [sActPouncerFollowDir], a
	ret
.setBackD:
	ld   a, PCFW_DIR_D
	ld   [sActPouncerFollowDir], a
	ret
	
	;
	; UP DIRECTION
	; Move right (alternate direction) if possible, otherwise continue up.
	;
.chkDirU:
	ld   a, [sActPouncerFollowDir]
	cp   a, PCFW_DIR_U							; Are we trying to move up?
	jr   nz, .chkDirR2							; If not, jump
.chkMoveU:
	call Act_PouncerFollow_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a										; Is there a solid block below?
	jr   z, .setDirR2							; If not, move right next time
	
	call Act_PouncerFollow_GetBlockId_Top
	mSubCall ActBGColi_IsSolid
	or   a
	jr   z, Act_PouncerFollow_MoveUp
.setDirR2:
	ld   a, PCFW_DIR_R2							; Set forced right direction
	ld   [sActPouncerFollowDir], a
	ld   a, $40									; For $40 frames
	ld   [sActPouncerFollowDownDelay], a
	ret
	
	;
	; RIGHT DIRECTION (from below)
	; This exists to bypass the downwards movement check with PCFW_DIR_R.
	; Otherwise, once it'd climb up a solid wall, it would move down instead of going right.
	;
.chkDirR2:
	; [TCRF] Sanity check that can't be triggered
	ld   a, [sActPouncerFollowDir]
	cp   a, PCFW_DIR_R2							; Are we trying to move right?
	ret  nz										; If not, peter out
	
	; To this purpose, there's a delay before we're allowed to move down again,
	; by switching to the main PCFW_DIR_R direction.
	ld   a, [sActPouncerFollowDownDelay]
	or   a										; Is the timer expired?
	jr   z, .setBackR							; If so, switch back to the main right dir
	dec  a										; Timer--
	ld   [sActPouncerFollowDownDelay], a
	
	call Act_PouncerFollow_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a										; Is there a solid block on the right?
	jr   z, Act_PouncerFollow_MoveRight			; If not, continue moving right
	
	; Otherwise, switch immediately back to the main right mode,
	; which will immediately trigger an attempt to move down.
	
.setBackR:
	ld   a, PCFW_DIR_R
	ld   [sActPouncerFollowDir], a
	ld   a, $40									; (not necessary here)
	ld   [sActPouncerFollowDownDelay], a
	ret
	
; =============== Act_PouncerFollow_MoveUp ===============
; Moves the actor up and the player standing on it at 0.5px/frame.
Act_PouncerFollow_MoveUp:
	; Move up every other frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveDown
	
	; If the player is standing on top, make him move up as well.
	ld   a, [sActSet]
	cp   a, $02					; Is the actor visible?
	ret  c						; If not, we can't be standing on it
	ld   b, $01					; B = Px to move up
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06			; Are we standing on it?
	call z, SubCall_PlBGColi_DoTopAndMove ; If so, try to move up
	ret
	
; =============== Act_PouncerFollow_MoveRight ===============
; Moves the actor right and the player standing on it at 0.5px/frame.
Act_PouncerFollow_MoveRight:
	; Move right every other frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveRight
	
	; If the player is standing on top, make him move right as well.
	; Curiously, this uses ActS_PlStand_MoveRight, which does not allow a custom speed.
	ld   a, [sActSet]
	cp   a, $02					; Is the actor visible?
	ret  c						; If not, we can't be standing on it
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06			; Are we standing on it?
	call z, SubCall_ActS_PlStand_MoveRight ; If so, try to move right
	ret
	
; =============== Act_PouncerFollow_MoveDown ===============
; Moves the actor down and the player standing on it at 0.5px/frame.
Act_PouncerFollow_MoveDown:
	; Move down every other frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveDown
	
	; If the player is standing on top, make him move down as well.
	ld   a, [sActSet]
	cp   a, $02					; Is the actor visible?
	ret  c						; If not, we can't be standing on it
	ld   b, $01					; B = Px to move down
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06			; Are we standing on it?
	call z, SubCall_PlBGColi_CheckGroundSolidOrMove	; If so, try to move down
	ret
	
	
;
; This is a set of extra subroutines all following the convention in ActColi_GetBlockId_*,
; used to get the block ID of the level layout.
;

; =============== Act_PouncerFollow_GetBlockId_LowR ===============
; Gets the block ID the actor is overlapping with on the right side.
; [POI] This checks for the block in the lower part of the body, but nothing checks the upper part (to save time)
; 		This means it can fit in 1 block high gaps when moving right.
Act_PouncerFollow_GetBlockId_LowR:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetXOffset +$10
	mActColi_GetBlockId_SetYOffset -$01
	mActColi_GetBlockId_GetLevelLayoutPtr
	ld   a, [hl]	; Read the block ID
	and  a, $7F		; Remove MSB
	ret
	
; =============== Act_PouncerFollow_GetBlockId_Top ===============
; Gets the block ID the actor is overlapping with on the top side.
Act_PouncerFollow_GetBlockId_Top:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetYOffset -$21
	mActColi_GetBlockId_GetLevelLayoutPtr
	ld   a, [hl]	; Read the block ID
	and  a, $7F		; Remove MSB
	ret
	
; =============== Act_PouncerFollow_GetBlockId_GroundL ===============
; Gets the block ID the actor is overlapping with on the ground (left block) side.
; This is purely used to check if the actor is touching solid ground.
Act_PouncerFollow_GetBlockId_GroundL:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetXOffset -$10
	mActColi_GetBlockId_GetLevelLayoutPtr
	ld   a, [hl]	; Read the block ID
	and  a, $7F		; Remove MSB
	ret
	
OBJLstPtrTable_Act_PouncerFollow:
	dw OBJLst_Act_Pouncer_Angry
	dw OBJLst_Act_Pouncer_Neutral
	dw $0000

; =============== ActInit_Driller ===============
ActInit_Driller:
	; Respawn at the original actor layout position
	; Otherwise it'd risk spawning over the ground after it drops, which is just wrong.
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$0A
	ld   [sActSetColiBoxU], a
	ld   a, -$05
	ld   [sActSetColiBoxD], a
	ld   a, -$05
	ld   [sActSetColiBoxL], a
	ld   a, +$05
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Driller
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_Driller
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Driller
	call ActS_SetOBJLstSharedTablePtr
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	
	xor  a
	ld   [sActSetTimer], a
	ld   [sActDrillerSafeTouch], a
	ld   a, $20
	ld   [sActDrillerTurnTimer], a
	ld   a, DIR_R
	ld   [sActSetDir], a
	ret

OBJLstPtrTable_ActInit_Driller:
	dw OBJLst_Act_Driller_Move0
	dw $0000
	
; =============== Act_Driller ===============
Act_Driller:
	; This actor doesn't move in the opposite direction when it reaches a solid wall.
	; Instead, it will continue moving.
	; If the actor is inside a solid wall, kill it
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolid
	or   a
	jp   nz, SubCall_ActS_StartJumpDead
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Driller_Main
	dw Act_Driller_Main;X
	dw Act_Driller_Main;X
	dw SubCall_ActS_StartStarKill
	dw Act_Driller_Main;X
	dw Act_Driller_Main;X
	dw Act_Driller_Main;X
	dw Act_Driller_Main;X
	dw SubCall_ActS_StartJumpDeadSameColi
	
; =============== Act_Driller_Main ===============
Act_Driller_Main:;I
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	call ActS_IncOBJLstIdEvery8		; Increase anim counter every 8 frames
	
	; Move every 8 frames
	ld   a, [sActSetTimer]
	and  a, $07
	jr   nz, .checkDrop
	
	; Decrement the timer. Once it expires, switch direction.
	ld   a, [sActDrillerTurnTimer]	
	dec  a							; Is it expired?
	jr   z, Act_Driller_Turn		; If so, jump
	ld   [sActDrillerTurnTimer], a
	
	; Move horizontally
	ld   a, [sActSetDir]
	bit  DIRB_R, a					; Are we moving right?
	call nz, Act_Driller_MoveRight	
	ld   a, [sActSetDir]
	bit  DIRB_L, a					; Are we moving left
	call nz, Act_Driller_MoveLeft
	call Act_Driller_TurnOnNoCeiling ; Turn if there's nothing in the ceiling
	
.checkDrop:
	;--
	; If the player is less than $20px (2 blocks) away from the actor,
	; make it drop to the ground.
	
	; Calculate the player's distance to HL.
	ld   a, [sActSetX_Low]			; HL = Actor X pos
	ld   l, a
	ld   a, [sActSetX_High]
	ld   h, a
	ld   a, [sPlX_Low]				; BC = Player X pos
	ld   c, a
	ld   a, [sPlX_High]
	ld   b, a
	call ActS_GetPlDistance			
	
	ld   a, l
	cp   a, $20						; Distance < $20?
	jr   c, Act_Driller_StartDrop					; If so, drop
	;--
	
	ld   a, [sScreenShakeTimer]
	or   a							; Is there's a screen shake active?
	jr   nz, Act_Driller_StartDrop				; If so, drop
	ret
	
; =============== Act_Driller_MoveLeft ===============
; Moves the actor 1px to the left.
Act_Driller_MoveLeft:
	ld   bc, -$01
	call ActS_MoveRight
	ld   a, LOW(OBJLstPtrTable_Act_Driller_Move)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Driller_Move)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
; =============== Act_Driller_MoveRight ===============
; Moves the actor 1px to the right.
Act_Driller_MoveRight:
	ld   bc, +$01
	call ActS_MoveRight
	ld   a, LOW(OBJLstPtrTable_Act_Driller_Move)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Driller_Move)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
; =============== Act_Driller_Turn ===============
; This subroutine is called when the actor turns.
Act_Driller_Turn:
	ld   a, $20					; Move in the next direction for $20 frames
	ld   [sActDrillerTurnTimer], a
	ld   a, [sActSetDir]		; Invert direction
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ret
; =============== Act_Driller_TurnOnNoCeiling ===============
; This subroutine causes the actor to turn if there isn't any ceiling above.
Act_Driller_TurnOnNoCeiling:
	call ActColi_GetBlockId_Top
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block above the actor?
	call z, Act_Driller_Turn			; If not, turn (to walk back where there's ceiling)
	ret
	
; =============== Act_Driller_StartDrop ===============
; This subroutine sets up the drop mode for this actor.
Act_Driller_StartDrop:
	ld   bc, SubCall_Act_DrillerDrop			; Different code ptr for this
	call ActS_SetCodePtr
	
	push bc										; Set drill anim
	ld   bc, OBJLstPtrTable_Act_Driller_Drop
	call ActS_SetOBJLstPtr
	pop  bc
	
	xor  a										; Reset drop speed
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	ld   a, SFX1_29						; Play SFX
	ld   [sSFX1Set], a
	ret
	
; =============== Act_DrillerDrop ===============
Act_DrillerDrop:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_DrillerDrop_Main
	dw SubCall_ActS_StartHeld
	dw SubCall_ActS_StartHeld
	dw SubCall_ActS_StartStarKill
	dw Act_DrillerDrop_Main
	dw SubCall_ActS_StartDashKill
	dw Act_DrillerDrop_Main;X
	dw Act_DrillerDrop_Main
	dw SubCall_ActS_StartJumpDeadSameColi
	
; =============== Act_DrillerDrop_Main ===============
; In this mode, the actor spins in place while dropping to the ground.
; While this happens, it's not safe to touch.
; As soon as it lands on the ground, it stops spinning and becomes safe to touch.
Act_DrillerDrop_Main:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	call ActS_IncOBJLstIdEvery8	; Increase anim counter every 8 frames
	
.chkLand:
	ld   a, [sActDrillerSafeTouch]
	or   a							; Has the actor landed once yet?
	jp   nz, Act_DrillerDrop_Safe	; If so, jump
	
	; Otherwise, all sides hurt
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is the actor on a solid block?
	jp   nz, Act_DrillerDrop_Land	; If so, jump
	
Act_DrillerDrop_MoveDown:
	; Make the actor drop down. 
	; Depending if it's underwater or not, use a different speed.
	
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a							; Is the actor in a water block?
	jr   z, .water					; If so, jump
.air:
	; In the air, the drop speed gradually increases over time
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown					; Drop down by that
	
	; Every 8 frames increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $07
	ret  nz
	ld   a, [sActSetYSpeed_Low]		; sActSetYSpeed++
	add  $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00
	ld   [sActSetYSpeed_High], a
	ret
.water:
	; When underwater, move down at a fixed 0.5px/frame speed
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveDown
	
	xor  a								; Reset drop speed
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ret
	
Act_DrillerDrop_Land:
	; This subroutine is called when the actor first lands, still in the spinning animation.
	; On further drops, if any, this shouldn't be called.

	; Make all sides safe to touch
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ld   a, $01						; and mark it
	ld   [sActDrillerSafeTouch], a
	
	xor  a							; Reset drop speed
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	push bc
	
	ld   bc, OBJLstPtrTable_Act_Driller_Land	; We aren't spinning anymore
	call ActS_SetOBJLstPtr
	pop  bc
	ret
Act_DrillerDrop_Safe:
	; [POI] This check if very difficult (if not impossible) to trigger, since none are placed
	;       over disappearing blocks, and once stunned they never recover.
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is the actor on a solid block?
	jp   z, Act_DrillerDrop_MoveDown	; If not, jump
	
	ret
	
OBJLstPtrTable_Act_Driller_Move:
	dw OBJLst_Act_Driller_Move0
	dw OBJLst_Act_Driller_Move1
	dw OBJLst_Act_Driller_Move2
	dw $0000
OBJLstPtrTable_Act_Driller_Drop:
	dw OBJLst_Act_Driller_Drop0
	dw OBJLst_Act_Driller_Drop1
	dw $0000
OBJLstPtrTable_Act_Driller_Land:
	dw OBJLst_Act_Driller_Land0
	dw OBJLst_Act_Driller_Land1
	dw OBJLst_Act_Driller_Land2
	dw $0000

OBJLstSharedPtrTable_Act_Driller:
	dw OBJLstPtrTable_Act_Driller_Move;X
	dw OBJLstPtrTable_Act_Driller_Move;X
	dw OBJLstPtrTable_Act_Driller_Move;X
	dw OBJLstPtrTable_Act_Driller_Move;X
	dw OBJLstPtrTable_Act_Driller_Land
	dw OBJLstPtrTable_Act_Driller_Land
	dw OBJLstPtrTable_Act_Driller_Move;X
	dw OBJLstPtrTable_Act_Driller_Move;X
	
OBJLst_Act_Driller_Move0: INCBIN "data/objlst/actor/driller_move0.bin"
OBJLst_Act_Driller_Move1: INCBIN "data/objlst/actor/driller_move1.bin"
OBJLst_Act_Driller_Move2: INCBIN "data/objlst/actor/driller_move2.bin"
OBJLst_Act_Driller_Land0: INCBIN "data/objlst/actor/driller_land0.bin"
OBJLst_Act_Driller_Land1: INCBIN "data/objlst/actor/driller_land1.bin"
OBJLst_Act_Driller_Land2: INCBIN "data/objlst/actor/driller_land2.bin"
OBJLst_Act_Driller_Drop0: INCBIN "data/objlst/actor/driller_drop0.bin"
OBJLst_Act_Driller_Drop1: INCBIN "data/objlst/actor/driller_drop1.bin"
GFX_Act_Driller: INCBIN "data/gfx/actor/driller.bin"

; =============== ActInit_SpikeBall ===============
; See also: ActInit_BigFruit
ActInit_SpikeBall:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$16
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_SpikeBall
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_SpikeBall
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_SpikeBall
	call ActS_SetOBJLstSharedTablePtr
	
	; Set collision type
	mActColiMask ACTCOLI_DAMAGE,ACTCOLI_DAMAGE,ACTCOLI_DAMAGE,ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	; Reset vars
	xor  a
	ld   [sActSpikeBallMoveDelay], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSpikeBallDropTimer], a
	ld   [sActSpikeBallLandTimer], a
	
	; Depending on the direction, set a different OBJLstPtrTable.
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, ActInit_SpikeBall_SetOBJLstPtrTableR
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, ActInit_SpikeBall_SetOBJLstPtrTableL
	xor  a
	ld   [sActSetOBJLstId], a
	ret
	
; =============== OBJLstPtrTable_ActInit_SpikeBall ===============
OBJLstPtrTable_ActInit_SpikeBall:
	dw OBJLst_Act_SpikeBall0
	dw $0000

; =============== Act_SpikeBall ===============
Act_SpikeBall:
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
	ld   a, [sActSpikeBallDropTimer]
	cp   a, $23							; Is the delay over yet?
	jr   nc, .chkTimer2					; If so, jump
	inc  a								; DropTimer++
	ld   [sActSpikeBallDropTimer], a
	ret
.chkTimer2:
	; If the secondary timer is set, wait for that too before continuing
	ld   a, [sActSpikeBallMoveDelay]
	or   a								; Is the delay over yet?
	jr   z, .move						; If so, jump
	dec  a								; DropTimer2--
	ld   [sActSpikeBallMoveDelay], a
	ret
.move:
	; The actor should not animate until it lands for the first time.
	; After that, it will do the rolling anim even in the air.
	; Horizontal movement, however, should only happen on solid ground.
	
	call Act_SpikeBall_CheckDrop
	ld   a, [sActSpikeBallLandTimer]
	or   a								; Has the actor landed once yet?
	ret  z								; If not, return
	
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkAir
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	
.chkAir:
	ld   a, [sActSetYSpeed_Low]
	or   a								; Is the actor in the air?
	ret  nz								; If so, don't move horizontally
	
	ld   a, [sActSetDir]
	bit  DIRB_R, a						; Is the fruit facing right?
	call nz, Act_SpikeBall_MoveRight	; If so, move right
	ld   a, [sActSetDir]
	bit  DIRB_L, a						; Is the fruit facing left?
	call nz, Act_SpikeBall_MoveLeft		; If so, move left
	ret
; =============== Act_SpikeBall_MoveLeft ===============
; Moves the actor to the left.
Act_SpikeBall_MoveLeft:
	; If there's a solid block on the left, kill the actor
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolid
	or   a
	jr   nz, Act_SpikeBall_Dead
	; Otherwise move left at 1px/frame
	ld   bc, -$01
	call ActS_MoveRight
; =============== ActInit_SpikeBall_SetOBJLstPtrTableL ===============
; Sets the initial OBJLstPtrTable when the actor is facing left.
ActInit_SpikeBall_SetOBJLstPtrTableL:
	ld   a, LOW(OBJLstPtrTable_Act_SpikeBallL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SpikeBallL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
; =============== Act_SpikeBall_MoveRight ===============
; Moves the actor to the right.
Act_SpikeBall_MoveRight:
	; If there's a solid block on the left, kill the actor
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a
	jr   nz, Act_SpikeBall_Dead
	; Otherwise move right at 1px/frame
	ld   bc, +$01
	call ActS_MoveRight
	
; =============== ActInit_SpikeBall_SetOBJLstPtrTableR ===============
; Sets the initial OBJLstPtrTable when the actor is facing right.
ActInit_SpikeBall_SetOBJLstPtrTableR:
	ld   a, LOW(OBJLstPtrTable_Act_SpikeBallR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SpikeBallR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
; =============== Act_SpikeBall_Dead ===============
; Kills the spikeball.
Act_SpikeBall_Dead:
	ld   a, [sActSetRoutineId]	; ...uh?
	and  a, $CF
	ld   [sActSetRoutineId], a
	; Play dead SFX and start jump effect
	ld   a, SFX1_14
	ld   [sSFX1Set], a
	jp   SubCall_ActS_DoStartJumpDead
	
; =============== Act_SpikeBall_CheckDrop ===============
; Handles the vertical drop of the actor when it isn't standing on solid ground.
Act_SpikeBall_CheckDrop:
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
	
	; Otherwise, we're in the air and should fall down.
	
	; If the actor is underwater, drop at a fixed 1px/frame speed
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a
	jr   z, .water
	
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
.water:;R
	ld   a, $01
	ld   [sActSetYSpeed_Low], a		; sActSetYSpeed_Low = 1
	ld   bc, +$01
	call ActS_MoveDown					; Move down by that
	ret
.landed:;R
	; [POI] This uses of a timer (instead of a flag) for some reason
	ld   a, [sActSpikeBallLandTimer]
	inc  a
	ld   [sActSpikeBallLandTimer], a
	
	; If the actor was on the ground or its drop speed was < 5px/frame, don't shake the screen.
	ld   a, [sActSetYSpeed_Low]
	or   a								; Was the actor on the ground?
	jr   z, .noShake					; If so, jump
	cp   a, $05							; Is it slower than 5px/frame?
	jr   c, .noShake					; If so, jump

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
	ld   [sActSpikeBallMoveDelay], a
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
OBJLstPtrTable_Act_SpikeBallL:
	dw OBJLst_Act_SpikeBall0
	dw OBJLst_Act_SpikeBall1
	dw OBJLst_Act_SpikeBall2
	dw OBJLst_Act_SpikeBall3
	dw $0000
OBJLstPtrTable_Act_SpikeBallR:
	dw OBJLst_Act_SpikeBall3
	dw OBJLst_Act_SpikeBall2
	dw OBJLst_Act_SpikeBall1
	dw OBJLst_Act_SpikeBall0
	dw $0000
OBJLstSharedPtrTable_Act_SpikeBall:
	dw OBJLstPtrTable_ActInit_SpikeBall;X
	dw OBJLstPtrTable_ActInit_SpikeBall;X
	dw OBJLstPtrTable_ActInit_SpikeBall;X
	dw OBJLstPtrTable_ActInit_SpikeBall;X
	dw OBJLstPtrTable_ActInit_SpikeBall
	dw OBJLstPtrTable_ActInit_SpikeBall
	dw OBJLstPtrTable_ActInit_SpikeBall;X
	dw OBJLstPtrTable_ActInit_SpikeBall;X

OBJLst_Act_SpikeBall0: INCBIN "data/objlst/actor/spikeball0.bin"
OBJLst_Act_SpikeBall1: INCBIN "data/objlst/actor/spikeball1.bin"
OBJLst_Act_SpikeBall2: INCBIN "data/objlst/actor/spikeball2.bin"
OBJLst_Act_SpikeBall3: INCBIN "data/objlst/actor/spikeball3.bin"
GFX_Act_SpikeBall: INCBIN "data/gfx/actor/spikeball.bin"

; =============== ActInit_CoinCrab ===============
ActInit_CoinCrab:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
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
	ld   bc, SubCall_Act_CoinCrab
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_ActInit_CoinCrab
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_CoinCrab
	call ActS_SetOBJLstSharedTablePtr
	
	; It's intangible by default (when hidden in the sand)
	xor  a
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	; Start inside the sand
	xor  a
	ld   [sActLocalRoutineId], a
	
	; [TCRF] Backup the original Y coords for the unused mode
	ld   a, [sActSetY_Low]
	ld   [sActCoinCrabYOrig_Low], a
	ld   a, [sActSetY_High]
	ld   [sActCoinCrabYOrig_High], a
	ret
	
; =============== Act_CoinCrab ===============
Act_CoinCrab:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_CoinCrab_Main
	dw Act_CoinCrab_Main
	dw Act_CoinCrab_Main
	dw SubCall_ActS_StartStarKill
	dw Act_CoinCrab_Main
	dw .onDashAttack
	dw Act_CoinCrab_Main;X
	dw Act_CoinCrab_Main
	dw Act_CoinCrab_Main;X
	
; =============== Act_CoinCrab ===============
.onDashAttack:
	; Give out an extra 10-coin for the trouble
	call SubCall_ActS_Spawn10Coin
	jp   SubCall_ActS_StartDashKill
	
; =============== Act_CoinCrab_Main ===============
Act_CoinCrab_Main:
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_CoinCrab_Hidden
	dw Act_CoinCrab_ExitSand
	dw Act_CoinCrab_Stand
	dw Act_CoinCrab_Run
	; [TCRF] Unused functionality. Crabs never go back in the sand once out.
	;        Judging from how the code is laid out, they likely weren't supposed to run
	;        indefinitely (and through walls).
	dw Act_CoinCrab_Unused_EnterSand;X
	
; =============== Act_CoinCrab_Unused_SwitchToHidden ===============
; [TCRF] Unreferenced code (referenced only by unreferenced code).
;        Meant to be used when switching back from Mode $05 to Mode $00.
Act_CoinCrab_Unused_SwitchToHidden:
	xor  a
	ld   [sActLocalRoutineId], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_CoinCrab_Hidden
	
	; Warp back to the original position when the crab burrows back into the sand.
	; (to avoid misalignments when solid blocks are in the way)
	ld   a, [sActCoinCrabYOrig_Low]
	ld   [sActSetY_Low], a
	ld   a, [sActCoinCrabYOrig_High]
	ld   [sActSetY_High], a
	ret  

; =============== Act_CoinCrab_Hidden ===============
; Mode $00. The crab is hidden in the ground, intangible.
Act_CoinCrab_Hidden:
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	; Turn every 8 frames
	ld   a, [sActSetTimer]
	and  a, $07
	call z, .turn
	
	; If the screen is shaking, reveal the crab
	ld   a, [sScreenShakeTimer]
	or   a
	jr   nz, .nextMode
	
	; Move horizontally at 0.5px/frame
	ld   a, [sActSetTimer]	; Every other frame...
	and  a, $01					
	ret  nz
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, .moveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, .moveLeft
	ret
.turn:
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ret
.moveRight:
	ld   bc, +$01
	call ActS_MoveRight
	ret
.moveLeft:
	ld   bc, -$01
	call ActS_MoveRight
	ret
.nextMode:
	ld   a, CCRB_RTN_EXITSAND		; Next mode
	ld   [sActLocalRoutineId], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_CoinCrab_Hidden
	
	; Set the jump out of sand
	mActSetYSpeed -$05
	
	xor  a
	ld   [sActCoinCrabAnimTimer], a
	
	; Prevent player from hitting the crab while jumping out
	mActColiMask ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_BUMP
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_CoinCrab_ExitSand ===============
; Mode $01: The crab jumps out of the sand.
Act_CoinCrab_ExitSand:


	
	;
	; Handle the changes in the crab animation.
	; NOTE: When first called, the crab is in the "hiding" anim.
	;
	ld   a, [sActCoinCrabAnimTimer]		; Timer++
	inc  a
	ld   [sActCoinCrabAnimTimer], a
	
	cp   a, $04							; Timer == $04?
	call z, Act_CoinCrab_SetDustAnim	; If so, set the "sand dust" frame
	ld   a, [sActCoinCrabAnimTimer]
	cp   a, $10							; Timer == $10?
	call z, Act_CoinCrab_SetStandAnim	; If so, set the main stand frame
	
	;
	; Process the vertical jump movement
	;
	call ActS_FallDownMax4Speed
	
	; [BUG] ActS_IncOBJLstIdEvery8 is not called here.
	;       This makes unused the second frame of OBJLstPtrTable_Act_CoinCrab_Dust.
	
	
	;
	; After landing on solid ground, switch to the next mode
	;
	
	; If we're moving up we can't be touching the ground
	ld   a, [sActSetYSpeed_High]
	bit  7, a							; YSpeed < 0?
	ret  nz								; If so, return
	
	; As soon as the crab starts moving down, make it intangible
	xor  a
	ld   [sActSetColiType], a
	
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is the actor on a solid block?
	jr   nz, Act_CoinCrab_SwitchToStand	; If so, jump
	ret
	
; =============== Act_CoinCrab_Unused_SetHiddenAnim ===============
; [TCRF] Unreachable code.
;        This animation is only set during Mode $04, which is unused.
Act_CoinCrab_Unused_SetHiddenAnim: 
	mActOBJLstPtrTable OBJLstPtrTable_Act_CoinCrab_Hidden
	ret
; =============== Act_CoinCrab_SetDustAnim ===============
Act_CoinCrab_SetDustAnim:
	mActOBJLstPtrTable OBJLstPtrTable_Act_CoinCrab_Dust
	ret
; =============== Act_CoinCrab_SetStandAnim ===============
Act_CoinCrab_SetStandAnim:
	mActOBJLstPtrTable OBJLstPtrTable_Act_CoinCrab_Stand
	ret
	
; =============== Act_CoinCrab_SwitchToStand ===============
Act_CoinCrab_SwitchToStand:
	ld   a, CCRB_RTN_STAND
	ld   [sActLocalRoutineId], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_CoinCrab_Stand ; Not necessary
	
	call Act_CoinCrab_SetRunDir
	
	xor  a
	ld   [sActCoinCrabModeTimer], a
	
	; Align to Y block boundary
	ld   a, [sActSetY_Low]
	and  a, $F0
	ld   [sActSetY_Low], a
	
	; *Now* make the crab defeatable
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_CoinCrab_Stand ===============
; Mode $02: Crabs stands still.
Act_CoinCrab_Stand:
	; Stand for $28 frames before running
	ld   a, [sActCoinCrabModeTimer]		; Timer++
	inc  a
	ld   [sActCoinCrabModeTimer], a
	cp   a, $28							; Timer >= $28?	
	jr   nc, .nextMode					; If so, switch
	ret
.nextMode:
	ld   a, CCRB_RTN_RUN
	ld   [sActLocalRoutineId], a
	mActOBJLstPtrTable OBJLstPtrTable_Act_CoinCrab_Run
	xor  a
	ld   [sActCoinCrabModeTimer], a
	ret
	
; =============== Act_CoinCrab_Run ===============
Act_CoinCrab_Run:
	; [TCRF] This variable is not checked in this mode.
	;        It was meant to reach a certain value before switching to the next mode,
	;        however the check itself it was quickly removed/commented out.
	;
	;        As for why they removed it -- allowing crabs to move back in the sand makes it
	;        easy to abuse the actor limit.
	;	     Also, crabs can go through walls. If they jump back in the sand while inside
	;        a wall	it causes problems (but that's easily fixable).
	ld   a, [sActCoinCrabModeTimer]
	inc  a
	ld   [sActCoinCrabModeTimer], a
	; cp  a, $<some val>
	; jr  c, Act_CoinCrab_Unused_SwitchToEnterSand
	
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	; Move horizontally
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Moving right?
	call nz, .moveRight			; If so, call
	ld   a, [sActSetDir]
	bit  DIRB_L, a				; Moving left?
	call nz, .moveLeft			; If so, call
	ret
.moveRight:
	ld   bc, +$02
	call ActS_MoveRight
	ret
.moveLeft:
	ld   bc, -$02
	call ActS_MoveRight
	ret
	
; =============== Act_CoinCrab_SetRunDir ===============
; Sets the actor's direction to make the crab run away from the player.
Act_CoinCrab_SetRunDir:
	ld   a, DIR_R			; Default to running right
	ld   [sActSetDir], a
	ld   a, [sActSetRelX]	; B = Actor X pos
	ld   b, a
	ld   a, [sPlXRel]		; A = Player X pos
	cp   a, b				; Is the player to the left of the actor? (PlayerX < ActorX)
	ret  c					; If so, return
	ld   a, DIR_L			; Otherwise, run to the left
	ld   [sActSetDir], a
	ret
	
; =============== Act_CoinCrab_Unused_SwitchToEnterSand ===============
; [TCRF] Unreachable code.
Act_CoinCrab_Unused_SwitchToEnterSand: 
	ld   a, CCRB_RTN_UNUSED_ENTERSAND
	ld   [sActLocalRoutineId], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_CoinCrab_Stand
	
	xor  a
	ld   [sActCoinCrabAnimTimer], a
	
	mActSetYSpeed -$04				; Trigger jump
	
	xor  a							; Make intangible
	ld   [sActSetColiType], a
	ret  
	
; =============== Act_CoinCrab_Unused_EnterSand ===============
; [TCRF] Unreachable code.
;        See Act_CoinCrab_Run for more info.
Act_CoinCrab_Unused_EnterSand: 
	call ActS_IncOBJLstIdEvery8
	call ActS_FallDownMax4Speed

	ld   a, [sActCoinCrabAnimTimer]		; Timer++
	inc  a
	ld   [sActCoinCrabAnimTimer], a
	
	; Switch back to the first mode when the timer reaches $28
	cp   a, $28									; Timer == $28?
	jp   nc, Act_CoinCrab_Unused_SwitchToHidden	; If so, jump
	
	;
	; Handle the changes in the crab animation.
	; Starting at $20 to account for the length of the jump.
	;
	ld   a, [sActCoinCrabAnimTimer]
	cp   a, $20									; Timer == $20?
	call z, Act_CoinCrab_SetDustAnim			; If so, set the "sand dust" frame
	ld   a, [sActCoinCrabAnimTimer]
	cp   a, $24									; Timer == $24?
	call z, Act_CoinCrab_Unused_SetHiddenAnim	; If so, set the "sand dust" frame
	ret
	
OBJLstSharedPtrTable_Act_CoinCrab:
	dw OBJLstPtrTable_Act_CoinCrab_Stun;X
	dw OBJLstPtrTable_Act_CoinCrab_Stun;X
	dw OBJLstPtrTable_Act_CoinCrab_Stun;X
	dw OBJLstPtrTable_Act_CoinCrab_Stun;X
	dw OBJLstPtrTable_Act_CoinCrab_Stun
	dw OBJLstPtrTable_Act_CoinCrab_Stun
	dw OBJLstPtrTable_Act_CoinCrab_Stun;X
	dw OBJLstPtrTable_Act_CoinCrab_Stun;X

OBJLstPtrTable_ActInit_CoinCrab:
	dw OBJLst_Act_CoinCrab_Hidden
	dw $0000
OBJLstPtrTable_Act_CoinCrab_Stand:
	dw OBJLst_Act_CoinCrab_Stand
	dw $0000;X
OBJLstPtrTable_Act_CoinCrab_Dust:
	dw OBJLst_Act_CoinCrab_Dust0
	dw OBJLst_Act_CoinCrab_Unused_Dust1;X ; [TCRF] The mode where this would be used doesn't animate frames
	dw OBJLst_Act_CoinCrab_Unused_Dust1;X
	dw $0000;X
OBJLstPtrTable_Act_CoinCrab_Stun:
	dw OBJLst_Act_CoinCrab_Stun
	dw $0000;X
OBJLstPtrTable_Act_CoinCrab_Hidden:
	dw OBJLst_Act_CoinCrab_Hidden
	dw $0000;X
OBJLstPtrTable_Act_CoinCrab_Run:
	dw OBJLst_Act_CoinCrab_Run0
	dw OBJLst_Act_CoinCrab_Run1
	dw OBJLst_Act_CoinCrab_Run0
	dw OBJLst_Act_CoinCrab_Run2
	dw $0000

OBJLst_Act_CoinCrab_Run0: INCBIN "data/objlst/actor/coincrab_run0.bin"
OBJLst_Act_CoinCrab_Run1: INCBIN "data/objlst/actor/coincrab_run1.bin"
OBJLst_Act_CoinCrab_Run2: INCBIN "data/objlst/actor/coincrab_run2.bin"
OBJLst_Act_CoinCrab_Stand: INCBIN "data/objlst/actor/coincrab_stand.bin"
OBJLst_Act_CoinCrab_Stun: INCBIN "data/objlst/actor/coincrab_stun.bin"
OBJLst_Act_CoinCrab_Dust0: INCBIN "data/objlst/actor/coincrab_dust0.bin"
OBJLst_Act_CoinCrab_Unused_Dust1: INCBIN "data/objlst/actor/coincrab_unused_dust1.bin"
OBJLst_Act_CoinCrab_Hidden: INCBIN "data/objlst/actor/coincrab_hidden.bin"
GFX_Act_CoinCrab: INCBIN "data/gfx/actor/coincrab.bin"

; =============== ActInit_ThunderCloud ===============
ActInit_ThunderCloud:
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, -$00
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_ThunderCloud
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_ThunderCloud_Move
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_ThunderCloud
	call ActS_SetOBJLstSharedTablePtr
	
	; Make intangible
	xor  a							
	ld   [sActSetColiType], a
	
	xor  a
	ld   [sActSetTimer], a
	ld   [sActThunderCloudShootTimer], a
	ld   [sActThunderCloudHSpeed_Low], a
	ld   [sActThunderCloudHSpeed_High], a
	; Save the original spawn Y pos
	ld   a, [sActSetY_Low]
	ld   [sActThunderCloudYOrig_Low], a
	ld   a, [sActSetY_High]
	ld   [sActThunderCloudYOrig_High], a
	xor  a
	ld   [sActSetTimer7], a
	ret
	
; =============== Act_ThunderCloud ===============
Act_ThunderCloud:
	
	;--
	; If the actor isn't visible, reset the animation
	ld   a, [sActSet]			; Read active status?
	cp   a, $02					; Is it visible & active?
	jr   z, .incTimer			; If so, jump
	xor  a
	ld   [sActSetOBJLstId], a
.incTimer:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	ld   b, a					; B = Timer
	;--
	
	ld   a, [sActThunderCloudShootTimer]		
	or   a								; About to shoot a thunderbolt?
	jr   nz, Act_ThunderCloud_WaitShoot	; If so, jump
	
; =============== Act_ThunderCloud_Main ===============
; Main movement mode, where the cloud tracks the player.
Act_ThunderCloud_Main:
	xor  a						; Make intangible
	ld   [sActSetColiType], a
	
	;
	; Do the vertical movement.
	; The cloud bobs up and down as an extra effect.
	;
.moveV:
	; Move every $04 frames
	ld   a, b					
	and  a, $03
	jr   nz, .moveH
	
	; Identical indexing trick to the one used in Act_Watch_Idle
	; (Act_ThunderCloud_YPath.end-Act_ThunderCloud_YPath-1) << 2 = $1C
	ld   a, b		; DE = sActSetTimer / 4
	and  a, $1C
	rrca
	rrca
	ld   e, a
	ld   d, $00
	ld   hl, Act_ThunderCloud_YPath	; HL = Y offset table
	add  hl, de			; Offset it 
	ld   a, [hl]		; C = Amount to move down
	ld   c, a	
	
	; [POI] Shortcut: Incomplete sign extension (sra should have been done 7 times).
	; This doesn't matter because of the level height used.
REPT 6
	sra  a				; B = Sign extended C
ENDR			
	ld   b, a
	call ActS_MoveDown	; Move down by BC
	
	;
	; Do the horizontal movement / player tracking.
	;
.moveH:
	call Act_ThunderCloud_UpdateHSpeed
	call Act_ThunderCloud_MoveH
	
	call ActS_IncOBJLstIdEvery8
	
	;
	; When the cloud's speed is $00, 1/8 chance of shooting out a thunderbolt.
	; This happens when the cloud turns direction after the player passes under it.
	;
.chkSpawnThunder:
	ld   a, [sActThunderCloudHSpeed_Low]
	or   a					; Speed == 0?
	ret  nz					; If so, return
	call Rand				
	ld   a, [sRandom]
	and  a, $07				; 1/8th chance
	ret  nz
	
	; Wait $3C frames in the "flashing" anim before shooting
	ld   a, $3C				
	ld   [sActThunderCloudShootTimer], a
	mActOBJLstPtrTable OBJLstPtrTable_Act_ThunderCloud_Shoot	
	
	; Since the cloud can bob up and down, restore the original Y coord,
	; so thunderbolts spawn from the same Y position.
	ld   a, [sActThunderCloudYOrig_Low]
	ld   [sActSetY_Low], a
	ld   a, [sActThunderCloudYOrig_High]
	ld   [sActSetY_High], a
	ret
	
; =============== Act_ThunderCloud_WaitShoot ===============
; The cloud flashes before spawning a thunderbolt.
Act_ThunderCloud_WaitShoot:
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkSpawn
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.chkSpawn:
	ld   a, LOW(OBJLstPtrTable_Act_ThunderCloud_Shoot)	; Set anim
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_ThunderCloud_Shoot)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	ld   a, [sActThunderCloudShootTimer]	; Delay--
	dec  a
	ld   [sActThunderCloudShootTimer], a
	or   a									; Is it elapsed yet?
	call z, Act_ThunderCloud_SpawnThunder	; If so, spawn the thunderbolt
	ret
	
; =============== Act_ThunderCloud_UpdateHSpeed ===============
; This subroutine gradually updates the horizontal speed of the cloud.
;
; It tracks the player location, gradually reducing or increasing the
; speed to make it move closer to the player.
Act_ThunderCloud_UpdateHSpeed:
	; Do this every 8 frames
	ld   a, [sActSetTimer]
	and  a, $07
	ret  nz
	
	call ActS_GetPlDirHRel	; Get the player direction
	bit  DIRB_R, a			; Is the player to the right?
	jr   nz, Act_ThunderCloud_IncHSpeed		; If so, increase the speed to the right (+speed)
	bit  DIRB_L, a			; Is the player to the left?
	jr   nz, Act_ThunderCloud_DecHSpeed		; If so, increase the speed to the left (-speed)
	ret ; [POI] We never get here
	
; =============== Act_ThunderCloud_DecHSpeed ===============
Act_ThunderCloud_DecHSpeed:
	;--
	; Prevent the cloud from moving faster than 2px/frame
	ld   a, [sActThunderCloudHSpeed_Low]		
	bit  7, a					; Speed > 0?
	jr   z, .ok					; If so, we're ok
	; It's a negative speed so invert it first for this check
	ld   b, a					
	cpl				; A = -HSpeed		
	inc  a
	cp   a, $02		; Speed >= 2px/frame?
	ret  nc			; If so, don't decrease it
	ld   a, b
	;--
.ok:
	sub  a, $01							; Speed--;
	ld   [sActThunderCloudHSpeed_Low], a
	ld   a, [sActThunderCloudHSpeed_High]
	sbc  a, $00
	ld   [sActThunderCloudHSpeed_High], a
	ret
	
; =============== Act_ThunderCloud_IncHSpeed ===============
Act_ThunderCloud_IncHSpeed:
	;--
	; Prevent the cloud from moving faster than 2px/frame
	ld   a, [sActThunderCloudHSpeed_Low]
	bit  7, a					; Speed < 0?
	jr   nz, .ok				; If so, we're ok
	cp   a, $02					; Speed >= 2px/frame?
	ret  nc						; If so, don't increase it
.ok:
	add  $01					; Speed++
	ld   [sActThunderCloudHSpeed_Low], a
	ld   a, [sActThunderCloudHSpeed_High]
	adc  a, $00
	ld   [sActThunderCloudHSpeed_High], a
	ret
	
; =============== Act_ThunderCloud_MoveH ===============
; Moves the cloud horizontally by the current speed.
Act_ThunderCloud_MoveH:
	; Slow down movement x2 compared to speed value
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_ThunderCloud_Move
	
	; Prevent the cloud from going through solid blocks
	ld   a, [sActThunderCloudHSpeed_High]
	bit  7, a								; Speed < 0?
	jr   nz, .moveL							; If so, jump
.moveR:
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop		
	or   a									; Is there a solid block on the left?
	ret  nz									; If so, return
	ld   a, [sActThunderCloudHSpeed_Low]	; BC = sActThunderCloudHSpeed
	ld   c, a
	ld   a, [sActThunderCloudHSpeed_High]
	ld   b, a
	call ActS_MoveRight						; Move right by that
	ret
.moveL:;R
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a									; Is there a solid block on the left?
	ret  nz									; If so, return
	ld   a, [sActThunderCloudHSpeed_Low]	; BC = sActThunderCloudHSpeed
	ld   c, a
	ld   a, [sActThunderCloudHSpeed_High]
	ld   b, a
	call ActS_MoveRight						; Move right by that
	ret
Act_ThunderCloud_YPath: 
	db +$00,+$01,+$02,+$01,+$00,-$01,-$02,-$01
.end:

OBJLstPtrTable_Act_ThunderCloud_Move:
	dw OBJLst_Act_ThunderCloud0
	dw $0000
OBJLstPtrTable_Act_ThunderCloud_Shoot:
	dw OBJLst_Act_ThunderCloud0
	dw OBJLst_Act_ThunderCloud1
	dw $0000
OBJLstPtrTable_Act_Thunder:
	dw OBJLst_Act_Thunder0
	dw OBJLst_Act_Thunder1
	dw $0000

OBJLstSharedPtrTable_Act_ThunderCloud:
	dw OBJLstPtrTable_Act_ThunderCloud_Move;X
	dw OBJLstPtrTable_Act_ThunderCloud_Move;X
	dw OBJLstPtrTable_Act_ThunderCloud_Move;X
	dw OBJLstPtrTable_Act_ThunderCloud_Move;X
	dw OBJLstPtrTable_Act_ThunderCloud_Move;X
	dw OBJLstPtrTable_Act_ThunderCloud_Move;X
	dw OBJLstPtrTable_Act_ThunderCloud_Move;X
	dw OBJLstPtrTable_Act_ThunderCloud_Move;X

OBJLst_Act_ThunderCloud0: INCBIN "data/objlst/actor/thundercloud0.bin"
OBJLst_Act_Thunder0: INCBIN "data/objlst/actor/thunder0.bin"
OBJLst_Act_Thunder1: INCBIN "data/objlst/actor/thunder1.bin"
OBJLst_Act_ThunderCloud1: INCBIN "data/objlst/actor/thundercloud1.bin"
GFX_Act_ThunderCloud: INCBIN "data/gfx/actor/thundercloud.bin"

; =============== Act_ThunderCloud_SpawnThunder ===============
Act_ThunderCloud_SpawnThunder:
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
	mActS_SetOBJBank .slotFound
	
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
	
	ld   a, -$08				; Coli box U
	ldi  [hl], a
	ld   a, -$02				; Coli box D
	ldi  [hl], a
	ld   a, -$01				; Coli box L
	ldi  [hl], a
	ld   a, +$01				; Coli box R
	ldi  [hl], a

	ld   a, $00
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_Thunder)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_Thunder)
	ldi  [hl], a
	
	ld   a, [sActSetDir]	; Dir
	ldi  [hl], a
	xor  a					; OBJLst ID
	ldi  [hl], a
	
	ld   a, [sActSetId]		; Actor ID
	set  ACTB_NORESPAWN, a	; Don't make it respawn
	
	ldi  [hl], a			; Routine ID
	xor  a
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_Thunder)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_Thunder)
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
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_ThunderCloud)	; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_ThunderCloud)
	ldi  [hl], a
	
	ld   a, SFX4_07	; Play shoot SFX
	ld   [sSFX4Set], a
	ret
	
; =============== Act_Thunder ===============
; The projectile thrown by Act_ThunderCloud.
Act_Thunder:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	call ActS_CheckOffScreen	; Update offscreen status
	cp   a, $02					; Is the actor visible & active?
	jr   nz, .despawn			; If not, jump
	
	; Animate every 4 global frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .moveDown
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.moveDown:
	; Move down at 4px/frame until hitting a solid block
	ld   bc, +$04
	call ActS_MoveDown
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block below?
	ret  z								; If not, return
	
	; When hitting a solid block, produce a star effect.
	
	; This actually has a larger hitbox.
	ld   a, -$0C
	ld   [sActSetColiBoxU], a
	ld   a, +$04
	ld   [sActSetColiBoxD], a
	ld   a, -$10
	ld   [sActSetColiBoxL], a
	ld   a, +$10
	ld   [sActSetColiBoxR], a
	
	; [POI] There's no point in doing this.
	call ActS_GetPlDirHRel
	ld   [sActSetDir], a		; Face the player
	
	; Kill any actors which come in contact with it, by setting their rtn to $03.
	; If there's any contact, our routine ID will be also set to $03.
	
	; [BUG] This doesn't account for our sActSetRoutineId being already set to $03,
	;       which happens when it overlaps with the dragon hat flame.
	;       To fix this, sActSetRoutineId should be reset before calling SubCall_ActHeldOrThrownActColi_Do
	ld   a, ACTRTN_03
	ld   [sActHeldColiRoutineId], a
	ld   a, [sActNumProc]
	call SubCall_ActHeldOrThrownActColi_Do
	
	; If an actor was killed, spawn a 10-coin
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_03
	call z, SubCall_ActS_Spawn10Coin
	
	; Switch to the starkill effect
	jp   SubCall_ActS_StartStarKill_NoHeart
.despawn:
	xor  a
	ld   [sActSet], a
	ret
	
; =============== ActInit_Hedgehog ===============
ActInit_Hedgehog:
	; Setup collision box
	ld   a, -$0C
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Hedgehog
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_ActInit_Hedgehog
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Hedgehog
	call ActS_SetOBJLstSharedTablePtr
	
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	ret
	
OBJLstPtrTable_ActInit_Hedgehog:
	dw OBJLst_Act_Hedgehog_MoveL0
	dw $0000;X
	
; =============== Act_Hedgehog ===============
Act_Hedgehog:
	; If the actor is overlapping with a solid block, kill it
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolid
	or   a
	jp   nz, SubCall_ActS_StartJumpDead
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Hedgehog_Main
	dw SubCall_ActS_OnPlColiH
	dw Act_Hedgehog_Main
	dw SubCall_ActS_StartStarKill
	dw SubCall_ActS_OnPlColiBelow
	dw SubCall_ActS_StartDashKill
	dw Act_Hedgehog_Main;X
	dw SubCall_ActS_StartSwitchDir
	dw SubCall_ActS_StartJumpDeadSameColi
	
; =============== Act_Hedgehog_Main ===============
Act_Hedgehog_Main:
	; If the screen is shaking, stun the actor
	ld   a, [sScreenShakeTimer]
	or   a
	jp   nz, SubCall_ActS_StartGroundPoundStun
	
	; If the actor is overlapping with a spike block, instakill it
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSpikeBlock
	or   a
	jp   nz, SubCall_ActS_StartStarKill
	
	ld   a, [sActSetTimer]					; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	;
	; Handle fall speed & anim.
	; Must be done before the other movement code since the actor should drop down
	; even during the turn delay.
	; Note that the turn delay is set (later on) as soon as there's no ground below the actor.
	;
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a									; Is the actor is inside a water block?
	jr   nz, .noWater						; If not, jump
;--
.water:
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a									; Is the actor on solid ground?
	jr   nz, .water_chkAnim					; If so, skip
	ld   bc, +$01							; Otherwise, fall down at a fixed 1px/frame
	call ActS_MoveDown
.water_chkAnim:
	; Animate every alternating 2 frames.
	; Unlike the one in noWater, the actor doesn't move
	ld   a, [sActSetTimer]
	and  a, $02								; sActSetTimer % 2 == 0?
	jr   z, .chkStartAttack					; If so, jump
	call ActS_IncOBJLstIdEvery8
	ret
;--
.noWater:
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a									; Is the actor on solid ground?
	jr   nz, .noWater_onSolid				; If so, skip
	
	ld   a, [sActSetYSpeed_Low]
	ld   c, a								; BC = sActSetYSpeed_Low
	ld   b, $00
	call ActS_MoveDown						; Move down by that
	
	; Every 4 frames increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $03
	jr   nz, .chkStartAttack
	ld   a, [sActSetYSpeed_Low]
	inc  a
	ld   [sActSetYSpeed_Low], a
	jr   .chkStartAttack
.noWater_onSolid:
	; If the actor just landed, align to the floor
	ld   a, [sActSetYSpeed_Low]
	or   a									; Did the actor just land?
	jr   z, .chkStartAttack					; If not, skip
	xor  a									; Otherwise, reset the drop speed
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetY_Low]					; And align to Y block
	and  a, $F0
	ld   [sActSetY_Low], a
;--

.chkStartAttack:
	; Once we get here, we've done the downwards movement.
	
	;
	; Check for attack mode
	;
	call Act_Hedgehog_CheckStartAttack	; Handle the setup for attacking
	ld   a, [sActHedgehogSpikeTimer]
	or   a								; Did we start attacking / Are we in the middle of attacking the player?
	jr   nz, .attack					; If so, jump
	
	; If we aren't attacking (anymore), restore the default collision
	; size / type (identical to ActInit_Hedgehog)
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
.chkTurnDelay:
	; If any turn delay is set, make sure the actor doesn't move horizontally.
	ld   a, [sActHedgehogTurnDelay]
	or   a								; Is the turn delay set?
	jr   z, Act_Hedgehog_MoveH			; If not, skip
	dec  a								; Otherwise, decrement it
	ld   [sActHedgehogTurnDelay], a
	or   a								; If not, return
	call z, Act_Hedgehog_Turn			; Otherwise, turn to the other direction
	ret
	
.attack:
	;
	; Handle the timer, which is initially set to $3C.
	; When it ticks down to $28, attack the player (meaning it activates in $14 frames).
	;
	ld   a, [sActHedgehogSpikeTimer]	; Timer--
	dec  a
	ld   [sActHedgehogSpikeTimer], a
	cp   a, $28							; Timer == $28?
	ret  nz								; If not, return
	
	;
	; Activate the attack.
	;
	
	; Enlarge collision box
	ld   a, -$0C
	ld   [sActSetColiBoxL], a
	ld   a, +$0C
	ld   [sActSetColiBoxR], a
	ld   a, SFX4_15
	ld   [sSFX4Set], a
	
	; Set both the animation and the side which deals damage depending on the direction
	; It also makes it deal damage when jumping on top since the game only processes
	; one side of the collision box, and jumping on top makes the topmost side win.
	;
	; Though it does also mean you get damaged when jumping on what's visibly
	; empty space near the hedgehog's face.
	; They could have made it so the top of the actor didn't damage the player
	; to avoid getting damaged by jumping on the hedgehog's face, but they didn't.
	
	; Set the one when facing left first
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mActOBJLstPtrTable OBJLstPtrTable_Act_Hedgehog_SpikeL		
	ld   a, [sActSetDir]
	
	bit  DIRB_L, a					; Facing left?
	ret  nz							; If so, return
	
	; Set the one when facing right
	mActOBJLstPtrTable OBJLstPtrTable_Act_Hedgehog_SpikeR		
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	ret
	
Act_Hedgehog_MoveH:
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	ld   a, [sActSetDir]
	bit  DIRB_R, a					; Is the actor facing right?
	jr   nz, .moveR					; If so, jump
.moveL:
	; Set sprite mapping
	ld   a, LOW(OBJLstPtrTable_Act_Hedgehog_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Hedgehog_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Set left direction
	ld   a, [sActSetDir]
	and  a, $F8						; Clear all but what would be DIR_D
	or   a, DIR_L
	ld   [sActSetDir], a
	
	; If there's anything in the way, stop moving and start turning around
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolid
	or   a							; Is there a solid block on the left?
	jp   nz, .setTurnDelay			; If so, stop moving
	
	
	call ActColi_GetBlockId_BottomL
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Are we standing on a solid block?
	jp   z, .setTurnDelay			; If not, stop moving
	
	; Move left 0.5px/frame
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	; Move left 1px
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
.moveR:
	; Set sprite mapping
	ld   a, LOW(OBJLstPtrTable_Act_Hedgehog_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Hedgehog_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_High], a

	; Set right direction
	ld   a, [sActSetDir]
	and  a, $F8
	or   a, DIR_R
	ld   [sActSetDir], a
	
	; If there's anything in the way, stop moving and start turning around
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a							; Is there a solid block on the right?
	jr   nz, .setTurnDelay			; If so, stop moving
	
	call ActColi_GetBlockId_BottomR
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Are we standing on a solid block?
	jr   z, .setTurnDelay			; If not, stop moving
	
	; Move right 0.5px/frame
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	; Move right 1px
	ld   bc, +$01
	call ActS_MoveRight
	ret
	
.setTurnDelay:
	ld   a, $1E
	ld   [sActHedgehogTurnDelay], a
	ret
	
; =============== Act_Hedgehog_CheckStartAttack ===============
; Checks if the player is facing the actor and is in range.
; If both checks pass, the hedgehog will turn and start to attack the player.
Act_Hedgehog_CheckStartAttack:

	;
	; Check if the player is facing the hedgehog (and vice versa).
	; If not, don't attack him.
	;
	; [NOTE] This is also an implicit way to avoid restarting the attack
	;        when in the middle of starting one (when sActHedgehogSpikeTimer != 0).
	;        It works since the actor turns right before starting the attack,
	;        which makes the check below fail.
	;

	; B = If 1, the player is moving right
	ld   a, [sPlFlags]
	and  a, OBJLST_XFLIP	; Filter the X flip flag (if $20; we're moving right)
	swap a					; A >> 4 (and shift it out to the first bit)
	rrca					; A >> 1 ("")
	ld   b, a
	; A = Actor's horizontal direction.
	; It's a DIR_* value, but since we're only using bit 0, it means
	; it will be 1 when facing right, and 0 when facing left.
	ld   a, [sActSetDir]	
	and  a, $01				; Filter the R/L flag
	; Return if the player is facing the same direction as the actor.
	;
	; This is done to make it look like the hedgehog has to "see" the player
	; before attacking him, otherwise it could attack when the player is anywhere
	; in range, including behind.
	;
	; For reference, depending on the possible values:
	; Act: 0 (L); Pl: 0 (L) -> return
	; Act: 1 (R); Pl: 1 (R) -> return
	; Act: 0 (L): Pl: 1 (R) -> ok
	; Act: 1 (R): Pl: 0 (L) -> ok
	xor  a, b				
	ret  z
	
	
	;
	; Check if the player is the vertical and horizontal range.
	; This is a $26*$1E area around the actor (relative to its origin). 
	;
	
	; Get the vertical distance between player and actor
	ld   a, [sActSetY_Low]	; HL = Actor Y coord
	ld   l, a
	ld   a, [sActSetY_High]
	ld   h, a
	ld   a, [sPlY_Low]		; BC = Player Y coord
	ld   c, a
	ld   a, [sPlY_High]
	ld   b, a
	call ActS_GetPlDistance	; HL = ABS(ActorY - PlayerY)
	; Vertical activation range of $0Fpx above and below the actor.
	; Since the actor's origin is at the bottom, it means the check succeeds when
	; we're either on the same row of blocks as the hedgehog, or *almost* one block below that.
	;
	; [BUG?] It's not clear if it was intentional or not, but the value used here
	;        just happens to be off-by-one to prevent the hedgehog from attracking when the
	;        player stands on either the block below or above.
	;
	;        This is because blocks are $10px high, and we're returning with a distance >= $10.
	;        When standing on the block below (like at the start of C19), doing a small hop
	;        *will* make the player in-range though.
	ld   a, l
	cp   a, $10				; HL >= $10?
	ret  nc					; If so, return
	
	; Get the horizontal distance between player and actor
	ld   a, [sActSetX_Low]	; HL = Actor X coord
	ld   l, a
	ld   a, [sActSetX_High]
	ld   h, a
	ld   a, [sPlX_Low]		; BC = Player X coord
	ld   c, a
	ld   a, [sPlX_High]
	ld   b, a
	call ActS_GetPlDistance	; HL = ABS(ActorX - PlayerX)
	; Horizontal range of $13px to the left or right of the actor.
	; [BUG?] Because of collision box differences, this is just enough to damage Big Wario,
	;        but not enough to damage Small Wario.
	;        When standing still, the hedgehog can't attack Small Wario if there's enough space.
	ld   a, l
	cp   a, $14				; HL >= $14?
	ret  nc					; If so, return
	
	
.attack:
	;
	; If both checks succeed, start attacking the player.
	;
	
	; Turn the other side to make the spikes face the player, (and make facing check above fail)
	call Act_Hedgehog_Turn
	; Wait for $14 frames before shooting out the spikes (see .attack for why $28 is there)
	ld   a, $14+$28
	ld   [sActHedgehogSpikeTimer], a
	
	; Set the correct stand anim
	mActOBJLstPtrTable OBJLstPtrTable_Act_Hedgehog_MoveL		; Set the one when facing left first
	ld   a, [sActSetDir]
	bit  DIRB_L, a					; Facing left?
	ret  nz							; If so, return
	mActOBJLstPtrTable OBJLstPtrTable_Act_Hedgehog_MoveR		; Set the one when facing right
	ret
	
; =============== Act_SpearGoom_Turn ===============
; Makes the actor switch direction.
Act_Hedgehog_Turn:
	xor  a						; Reset anim frame
	ld   [sActSetOBJLstId], a
	ld   a, [sActSetDir]		; Switch direction
	xor  DIR_L|DIR_R
	ld   [sActSetDir], a
	ret
; =============== OBJLstSharedPtrTable_Act_Hedgehog ===============
OBJLstSharedPtrTable_Act_Hedgehog:
	dw OBJLstPtrTable_Act_Hedgehog_StunL;X
	dw OBJLstPtrTable_Act_Hedgehog_StunR;X
	dw OBJLstPtrTable_Act_Hedgehog_RecoverL
	dw OBJLstPtrTable_Act_Hedgehog_RecoverR
	dw OBJLstPtrTable_Act_Hedgehog_StunL
	dw OBJLstPtrTable_Act_Hedgehog_StunR
	dw OBJLstPtrTable_Act_Hedgehog_MoveL;X
	dw OBJLstPtrTable_Act_Hedgehog_MoveR;X

OBJLstPtrTable_Act_Hedgehog_SpikeL:
	dw OBJLst_Act_Hedgehog_SpikeL
	dw $0000;X
OBJLstPtrTable_Act_Hedgehog_SpikeR:
	dw OBJLst_Act_Hedgehog_SpikeR
	dw $0000;X
OBJLstPtrTable_Act_Hedgehog_RecoverL:
	dw OBJLst_Act_Hedgehog_StunL0
	dw OBJLst_Act_Hedgehog_MoveL0
	dw OBJLst_Act_Hedgehog_MoveL0
	dw $0000;X
OBJLstPtrTable_Act_Hedgehog_RecoverR:
	dw OBJLst_Act_Hedgehog_StunR0
	dw OBJLst_Act_Hedgehog_MoveR0
	dw OBJLst_Act_Hedgehog_MoveR0
	dw $0000;X
OBJLstPtrTable_Act_Hedgehog_StunL:
	dw OBJLst_Act_Hedgehog_StunL0
	dw OBJLst_Act_Hedgehog_StunL1
	dw $0000
OBJLstPtrTable_Act_Hedgehog_StunR:
	dw OBJLst_Act_Hedgehog_StunR0
	dw OBJLst_Act_Hedgehog_StunR1
	dw $0000
OBJLstPtrTable_Act_Hedgehog_MoveL:
	dw OBJLst_Act_Hedgehog_MoveL0
	dw OBJLst_Act_Hedgehog_MoveL1
	dw OBJLst_Act_Hedgehog_MoveL0
	dw OBJLst_Act_Hedgehog_MoveL2
	dw $0000
OBJLstPtrTable_Act_Hedgehog_MoveR:
	dw OBJLst_Act_Hedgehog_MoveR0
	dw OBJLst_Act_Hedgehog_MoveR1
	dw OBJLst_Act_Hedgehog_MoveR0
	dw OBJLst_Act_Hedgehog_MoveR2
	dw $0000

OBJLst_Act_Hedgehog_MoveL0: INCBIN "data/objlst/actor/hedgehog_movel0.bin"
OBJLst_Act_Hedgehog_MoveL1: INCBIN "data/objlst/actor/hedgehog_movel1.bin"
OBJLst_Act_Hedgehog_MoveL2: INCBIN "data/objlst/actor/hedgehog_movel2.bin"
OBJLst_Act_Hedgehog_SpikeL: INCBIN "data/objlst/actor/hedgehog_spikel.bin"
; [TCRF] Unused animation frame using otherwise unused graphics, likely the original stun animation.
;        The stun animation used here is... odd. Unlike most other actors, it's more or less
;        identical to the walking animation, except upside down.
;        However, a frame more in line with what's used for other actors exists, unused.
OBJLst_Act_Hedgehog_Unused_DeadL: INCBIN "data/objlst/actor/hedgehog_unused_deadl.bin"
OBJLst_Act_Hedgehog_StunL0: INCBIN "data/objlst/actor/hedgehog_stunl0.bin"
OBJLst_Act_Hedgehog_StunL1: INCBIN "data/objlst/actor/hedgehog_stunl1.bin"
OBJLst_Act_Hedgehog_MoveR0: INCBIN "data/objlst/actor/hedgehog_mover0.bin"
OBJLst_Act_Hedgehog_MoveR1: INCBIN "data/objlst/actor/hedgehog_mover1.bin"
OBJLst_Act_Hedgehog_MoveR2: INCBIN "data/objlst/actor/hedgehog_mover2.bin"
OBJLst_Act_Hedgehog_SpikeR: INCBIN "data/objlst/actor/hedgehog_spiker.bin"
; [TCRF] Same as the above one, except flipped horizontally.
OBJLst_Act_Hedgehog_Unused_DeadR: INCBIN "data/objlst/actor/hedgehog_unused_deadr.bin"
OBJLst_Act_Hedgehog_StunR0: INCBIN "data/objlst/actor/hedgehog_stunr0.bin"
OBJLst_Act_Hedgehog_StunR1: INCBIN "data/objlst/actor/hedgehog_stunr1.bin"
GFX_Act_Hedgehog: INCBIN "data/gfx/actor/hedgehog.bin"


; =============== ActInit_SpikePillar* ===============
; Sets of moving pillars found in underwater areas.

; =============== ActInit_SpikePillarR ===============
ActInit_SpikePillarR:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$0C
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$14
	ld   [sActSetColiBoxL], a
	ld   a, +$14
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_SpikePillarR
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_SpikePillarR
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_SpikePillar
	call ActS_SetOBJLstSharedTablePtr
	
	; Touching a spiky pillar deals damage no matter what
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	
	mSubCall ActS_SaveColiType ; BANK $02
	
	xor  a
	ld   [sActSpikePillarMoveTimer], a
	
	; Move 1 block right
	ld   bc, +$10
	call ActS_MoveRight
	ret
	
; =============== ActInit_SpikePillarL ===============
ActInit_SpikePillarL:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$0C
	ld   [sActSetColiBoxU], a
	ld   a, -$04
	ld   [sActSetColiBoxD], a
	ld   a, -$14
	ld   [sActSetColiBoxL], a
	ld   a, +$14
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_SpikePillarL
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_SpikePillarL
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_SpikePillar
	call ActS_SetOBJLstSharedTablePtr
	
	; Touching a spiky pillar deals damage no matter what
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	
	mSubCall ActS_SaveColiType ; BANK $02
	
	xor  a
	ld   [sActSpikePillarMoveTimer], a
	
	; Move 1 block left
	ld   bc, -$10
	call ActS_MoveRight
	ret
	
; =============== ActInit_SpikePillarU ===============
ActInit_SpikePillarU:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$1E
	ld   [sActSetColiBoxU], a
	ld   a, -$0A
	ld   [sActSetColiBoxD], a
	ld   a, -$04
	ld   [sActSetColiBoxL], a
	ld   a, +$04
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_SpikePillarU
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_SpikePillarU
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_SpikePillar
	call ActS_SetOBJLstSharedTablePtr
	
	; Touching a spiky pillar deals damage no matter what
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	xor  a
	ld   [sActSpikePillarMoveTimer], a
	ret
	
; =============== ActInit_SpikePillarU ===============
ActInit_SpikePillarD:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$1E
	ld   [sActSetColiBoxU], a
	ld   a, -$0A
	ld   [sActSetColiBoxD], a
	ld   a, -$04
	ld   [sActSetColiBoxL], a
	ld   a, +$04
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_SpikePillarD
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_SpikePillarD
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_SpikePillar
	call ActS_SetOBJLstSharedTablePtr
	
	; Touching a spiky pillar deals damage no matter what
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	xor  a
	ld   [sActSpikePillarMoveTimer], a
	ret
	
OBJLstPtrTable_Act_SpikePillarR:
	dw OBJLst_Act_SpikePillarR
	dw $0000;X
OBJLstPtrTable_Act_SpikePillarL:
	dw OBJLst_Act_SpikePillarL
	dw $0000;X
OBJLstPtrTable_Act_SpikePillarD:
	dw OBJLst_Act_SpikePillarD
	dw $0000;X
OBJLstPtrTable_Act_SpikePillarU:
	dw OBJLst_Act_SpikePillarU
	dw $0000;X


; =============== Act_SpikePillarR ===============
; All of the pillars work the same way.
Act_SpikePillarR:
	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Move the pillar back and forth at 0.5px/frame.
	; The timer always increments and stays in range $00-$41.
	
	; Every other frame...
	and  a, $01
	ret  nz
	
	ld   a, [sActSpikePillarMoveTimer]	; Timer++
	inc  a
	ld   [sActSpikePillarMoveTimer], a
	cp   a, $21				; Timer < $21?
	jr   c, .moveL			; If so, move left
	cp   a, $41				; Timer < $41?
	jr   c, .moveR			; If so, move right
	xor  a					; Restart the cycle again
	ld   [sActSpikePillarMoveTimer], a
	ret
.moveL:
	ld   bc, -$01
	call ActS_MoveRight
	ret
.moveR:
	ld   bc, +$01
	call ActS_MoveRight
	ret
	
; =============== Act_SpikePillarL ===============
Act_SpikePillarL:
	ld   a, [sActSetTimer]				; Timer++
	inc  a
	ld   [sActSetTimer], a

	; Every other frame...
	and  a, $01
	ret  nz
	
	ld   a, [sActSpikePillarMoveTimer]	; Timer++
	inc  a
	ld   [sActSpikePillarMoveTimer], a
	
	; Move 1px in a certain direction depending on the timer
	cp   a, $21				
	jr   c, .moveR			
	cp   a, $41				
	jr   c, .moveL			
	xor  a					
	ld   [sActSpikePillarMoveTimer], a
	ret
.moveL:
	ld   bc, -$01
	call ActS_MoveRight
	ret
.moveR:
	ld   bc, +$01
	call ActS_MoveRight
	ret
	
Act_SpikePillarU:
	ld   a, [sActSetTimer]				; Timer++
	inc  a
	ld   [sActSetTimer], a

	; Every other frame...
	and  a, $01
	ret  nz
	
	ld   a, [sActSpikePillarMoveTimer]	; Timer++
	inc  a
	ld   [sActSpikePillarMoveTimer], a
	
	; Move 1px in a certain direction depending on the timer
	cp   a, $21				
	jr   c, .moveU			
	cp   a, $41				
	jr   c, .moveD			
	xor  a					
	ld   [sActSpikePillarMoveTimer], a
	ret
.moveU:
	ld   bc, -$01
	call ActS_MoveDown
	ret
.moveD:
	ld   bc, +$01
	call ActS_MoveDown
	ret
	
Act_SpikePillarD:;I
	ld   a, [sActSetTimer]				; Timer++
	inc  a
	ld   [sActSetTimer], a

	; Every other frame...
	and  a, $01
	ret  nz
	
	ld   a, [sActSpikePillarMoveTimer]	; Timer++
	inc  a
	ld   [sActSpikePillarMoveTimer], a
	
	; Move 1px in a certain direction depending on the timer
	cp   a, $21				
	jr   c, .moveD			
	cp   a, $41				
	jr   c, .moveU		
	xor  a					
	ld   [sActSpikePillarMoveTimer], a
	ret
.moveU:
	ld   bc, -$01
	call ActS_MoveDown
	ret
.moveD:
	ld   bc, +$01
	call ActS_MoveDown
	ret
	
OBJLstSharedPtrTable_Act_SpikePillar:
	dw OBJLstPtrTable_Act_SpikePillarR;X
	dw OBJLstPtrTable_Act_SpikePillarL;X
	dw OBJLstPtrTable_Act_SpikePillarR;X
	dw OBJLstPtrTable_Act_SpikePillarL;X
	dw OBJLstPtrTable_Act_SpikePillarR;X
	dw OBJLstPtrTable_Act_SpikePillarL;X
	dw OBJLstPtrTable_Act_SpikePillarR;X
	dw OBJLstPtrTable_Act_SpikePillarL;X

OBJLst_Act_SpikePillarR: INCBIN "data/objlst/actor/spikepillarr.bin"
OBJLst_Act_SpikePillarL: INCBIN "data/objlst/actor/spikepillarl.bin"
OBJLst_Act_SpikePillarD: INCBIN "data/objlst/actor/spikepillard.bin"
OBJLst_Act_SpikePillarU: INCBIN "data/objlst/actor/spikepillaru.bin"
GFX_Act_SpikePillarH: INCBIN "data/gfx/actor/spikepillarh.bin"
GFX_Act_SpikePillarV: INCBIN "data/gfx/actor/spikepillarv.bin"

; =============== END OF BANK ===============
L157D07: db $4E;X
L157D08: db $C2;X
L157D09: db $5C;X
L157D0A: db $C4;X
L157D0B: db $BE;X
L157D0C: db $FF;X
L157D0D: db $FF;X
L157D0E: db $EE;X
L157D0F: db $FA;X
L157D10: db $FF;X
L157D11: db $EF;X
L157D12: db $5E;X
L157D13: db $DF;X
L157D14: db $AF;X
L157D15: db $FF;X
L157D16: db $FB;X
L157D17: db $FF;X
L157D18: db $EF;X
L157D19: db $FE;X
L157D1A: db $FF;X
L157D1B: db $FB;X
L157D1C: db $EF;X
L157D1D: db $FF;X
L157D1E: db $BF;X
L157D1F: db $B6;X
L157D20: db $FD;X
L157D21: db $37;X
L157D22: db $DB;X
L157D23: db $FF;X
L157D24: db $F7;X
L157D25: db $F7;X
L157D26: db $FF;X
L157D27: db $FD;X
L157D28: db $DF;X
L157D29: db $FB;X
L157D2A: db $FF;X
L157D2B: db $F2;X
L157D2C: db $FF;X
L157D2D: db $AD;X
L157D2E: db $F5;X
L157D2F: db $FF;X
L157D30: db $C9;X
L157D31: db $F6;X
L157D32: db $F7;X
L157D33: db $FE;X
L157D34: db $8F;X
L157D35: db $FF;X
L157D36: db $F4;X
L157D37: db $FC;X
L157D38: db $B3;X
L157D39: db $FE;X
L157D3A: db $FE;X
L157D3B: db $FC;X
L157D3C: db $BB;X
L157D3D: db $DF;X
L157D3E: db $BF;X
L157D3F: db $F7;X
L157D40: db $FF;X
L157D41: db $EF;X
L157D42: db $FB;X
L157D43: db $FF;X
L157D44: db $FF;X
L157D45: db $DF;X
L157D46: db $FE;X
L157D47: db $FF;X
L157D48: db $CF;X
L157D49: db $AD;X
L157D4A: db $BF;X
L157D4B: db $B7;X
L157D4C: db $DE;X
L157D4D: db $CF;X
L157D4E: db $FF;X
L157D4F: db $79;X
L157D50: db $77;X
L157D51: db $FF;X
L157D52: db $DF;X
L157D53: db $DE;X
L157D54: db $AF;X
L157D55: db $FF;X
L157D56: db $7D;X
L157D57: db $B5;X
L157D58: db $FF;X
L157D59: db $FF;X
L157D5A: db $FF;X
L157D5B: db $F9;X
L157D5C: db $1A;X
L157D5D: db $FC;X
L157D5E: db $BE;X
L157D5F: db $DE;X
L157D60: db $F9;X
L157D61: db $FB;X
L157D62: db $FF;X
L157D63: db $FF;X
L157D64: db $FF;X
L157D65: db $ED;X
L157D66: db $5F;X
L157D67: db $7F;X
L157D68: db $97;X
L157D69: db $BC;X
L157D6A: db $FD;X
L157D6B: db $F6;X
L157D6C: db $FA;X
L157D6D: db $FF;X
L157D6E: db $7F;X
L157D6F: db $9F;X
L157D70: db $FA;X
L157D71: db $FB;X
L157D72: db $FF;X
L157D73: db $FF;X
L157D74: db $FF;X
L157D75: db $BF;X
L157D76: db $FF;X
L157D77: db $F7;X
L157D78: db $7B;X
L157D79: db $5D;X
L157D7A: db $FF;X
L157D7B: db $DD;X
L157D7C: db $FF;X
L157D7D: db $EE;X
L157D7E: db $EF;X
L157D7F: db $E9;X
L157D80: db $10;X
L157D81: db $04;X
L157D82: db $00;X
L157D83: db $00;X
L157D84: db $00;X
L157D85: db $00;X
L157D86: db $00;X
L157D87: db $00;X
L157D88: db $00;X
L157D89: db $00;X
L157D8A: db $00;X
L157D8B: db $00;X
L157D8C: db $00;X
L157D8D: db $80;X
L157D8E: db $00;X
L157D8F: db $00;X
L157D90: db $00;X
L157D91: db $00;X
L157D92: db $11;X
L157D93: db $00;X
L157D94: db $00;X
L157D95: db $00;X
L157D96: db $00;X
L157D97: db $20;X
L157D98: db $20;X
L157D99: db $00;X
L157D9A: db $00;X
L157D9B: db $C0;X
L157D9C: db $00;X
L157D9D: db $00;X
L157D9E: db $00;X
L157D9F: db $00;X
L157DA0: db $00;X
L157DA1: db $00;X
L157DA2: db $00;X
L157DA3: db $00;X
L157DA4: db $20;X
L157DA5: db $00;X
L157DA6: db $00;X
L157DA7: db $00;X
L157DA8: db $00;X
L157DA9: db $04;X
L157DAA: db $00;X
L157DAB: db $00;X
L157DAC: db $00;X
L157DAD: db $00;X
L157DAE: db $00;X
L157DAF: db $00;X
L157DB0: db $00;X
L157DB1: db $00;X
L157DB2: db $00;X
L157DB3: db $00;X
L157DB4: db $80;X
L157DB5: db $03;X
L157DB6: db $00;X
L157DB7: db $80;X
L157DB8: db $00;X
L157DB9: db $01;X
L157DBA: db $00;X
L157DBB: db $00;X
L157DBC: db $00;X
L157DBD: db $00;X
L157DBE: db $08;X
L157DBF: db $00;X
L157DC0: db $00;X
L157DC1: db $09;X
L157DC2: db $00;X
L157DC3: db $00;X
L157DC4: db $00;X
L157DC5: db $00;X
L157DC6: db $00;X
L157DC7: db $00;X
L157DC8: db $00;X
L157DC9: db $00;X
L157DCA: db $00;X
L157DCB: db $00;X
L157DCC: db $00;X
L157DCD: db $00;X
L157DCE: db $00;X
L157DCF: db $08;X
L157DD0: db $00;X
L157DD1: db $00;X
L157DD2: db $00;X
L157DD3: db $00;X
L157DD4: db $00;X
L157DD5: db $04;X
L157DD6: db $00;X
L157DD7: db $00;X
L157DD8: db $00;X
L157DD9: db $00;X
L157DDA: db $00;X
L157DDB: db $00;X
L157DDC: db $00;X
L157DDD: db $00;X
L157DDE: db $40;X
L157DDF: db $00;X
L157DE0: db $20;X
L157DE1: db $00;X
L157DE2: db $00;X
L157DE3: db $40;X
L157DE4: db $02;X
L157DE5: db $00;X
L157DE6: db $00;X
L157DE7: db $00;X
L157DE8: db $00;X
L157DE9: db $00;X
L157DEA: db $20;X
L157DEB: db $00;X
L157dec: db $00;X
L157DED: db $00;X
L157DEE: db $00;X
L157DEF: db $00;X
L157DF0: db $00;X
L157DF1: db $00;X
L157DF2: db $20;X
L157DF3: db $05;X
L157DF4: db $00;X
L157DF5: db $00;X
L157DF6: db $00;X
L157DF7: db $00;X
L157DF8: db $00;X
L157DF9: db $00;X
L157DFA: db $00;X
L157DFB: db $00;X
L157DFC: db $00;X
L157DFD: db $00;X
L157DFE: db $00;X
L157DFF: db $00;X
L157E00: db $FF;X
L157E01: db $FF;X
L157E02: db $FF;X
L157E03: db $FF;X
L157E04: db $FF;X
L157E05: db $F3;X
L157E06: db $7D;X
L157E07: db $FE;X
L157E08: db $EB;X
L157E09: db $FA;X
L157E0A: db $ED;X
L157E0B: db $FF;X
L157E0C: db $FF;X
L157E0D: db $FF;X
L157E0E: db $FF;X
L157E0F: db $FF;X
L157E10: db $FF;X
L157E11: db $FB;X
L157E12: db $FF;X
L157E13: db $DF;X
L157E14: db $FF;X
L157E15: db $FF;X
L157E16: db $FF;X
L157E17: db $FF;X
L157E18: db $FE;X
L157E19: db $DF;X
L157E1A: db $FF;X
L157E1B: db $FF;X
L157E1C: db $FF;X
L157E1D: db $FF;X
L157E1E: db $F7;X
L157E1F: db $FE;X
L157E20: db $7F;X
L157E21: db $7F;X
L157E22: db $FF;X
L157E23: db $DF;X
L157E24: db $7F;X
L157E25: db $FF;X
L157E26: db $FF;X
L157E27: db $FB;X
L157E28: db $FB;X
L157E29: db $FF;X
L157E2A: db $FF;X
L157E2B: db $EF;X
L157E2C: db $FF;X
L157E2D: db $FF;X
L157E2E: db $7F;X
L157E2F: db $FF;X
L157E30: db $FF;X
L157E31: db $FF;X
L157E32: db $FF;X
L157E33: db $FF;X
L157E34: db $FF;X
L157E35: db $FF;X
L157E36: db $EF;X
L157E37: db $FE;X
L157E38: db $FE;X
L157E39: db $FF;X
L157E3A: db $3F;X
L157E3B: db $FF;X
L157E3C: db $FF;X
L157E3D: db $FF;X
L157E3E: db $F3;X
L157E3F: db $FF;X
L157E40: db $DF;X
L157E41: db $FF;X
L157E42: db $FF;X
L157E43: db $FF;X
L157E44: db $FF;X
L157E45: db $FF;X
L157E46: db $FF;X
L157E47: db $DF;X
L157E48: db $FD;X
L157E49: db $FF;X
L157E4A: db $FF;X
L157E4B: db $FF;X
L157E4C: db $7F;X
L157E4D: db $DF;X
L157E4E: db $FD;X
L157E4F: db $FF;X
L157E50: db $FF;X
L157E51: db $FF;X
L157E52: db $FF;X
L157E53: db $FF;X
L157E54: db $FF;X
L157E55: db $FE;X
L157E56: db $F7;X
L157E57: db $FF;X
L157E58: db $FD;X
L157E59: db $FF;X
L157E5A: db $FF;X
L157E5B: db $FB;X
L157E5C: db $F7;X
L157E5D: db $FF;X
L157E5E: db $FF;X
L157E5F: db $7F;X
L157E60: db $FF;X
L157E61: db $FF;X
L157E62: db $FF;X
L157E63: db $FD;X
L157E64: db $FF;X
L157E65: db $FF;X
L157E66: db $FF;X
L157E67: db $FF;X
L157E68: db $FF;X
L157E69: db $FF;X
L157E6A: db $BF;X
L157E6B: db $FF;X
L157E6C: db $FF;X
L157E6D: db $FF;X
L157E6E: db $9B;X
L157E6F: db $FF;X
L157E70: db $FF;X
L157E71: db $FF;X
L157E72: db $EF;X
L157E73: db $FB;X
L157E74: db $FF;X
L157E75: db $FD;X
L157E76: db $FF;X
L157E77: db $FF;X
L157E78: db $DF;X
L157E79: db $FF;X
L157E7A: db $FF;X
L157E7B: db $FF;X
L157E7C: db $FF;X
L157E7D: db $FB;X
L157E7E: db $FF;X
L157E7F: db $FF;X
L157E80: db $00;X
L157E81: db $00;X
L157E82: db $00;X
L157E83: db $40;X
L157E84: db $08;X
L157E85: db $01;X
L157E86: db $40;X
L157E87: db $A0;X
L157E88: db $10;X
L157E89: db $12;X
L157E8A: db $18;X
L157E8B: db $05;X
L157E8C: db $00;X
L157E8D: db $00;X
L157E8E: db $08;X
L157E8F: db $24;X
L157E90: db $00;X
L157E91: db $00;X
L157E92: db $40;X
L157E93: db $80;X
L157E94: db $08;X
L157E95: db $88;X
L157E96: db $A0;X
L157E97: db $01;X
L157E98: db $01;X
L157E99: db $10;X
L157E9A: db $40;X
L157E9B: db $A0;X
L157E9C: db $00;X
L157E9D: db $0C;X
L157E9E: db $10;X
L157E9F: db $14;X
L157EA0: db $20;X
L157EA1: db $00;X
L157EA2: db $00;X
L157EA3: db $08;X
L157EA4: db $00;X
L157EA5: db $80;X
L157EA6: db $00;X
L157EA7: db $10;X
L157EA8: db $81;X
L157EA9: db $08;X
L157EAA: db $04;X
L157EAB: db $98;X
L157EAC: db $42;X
L157EAD: db $04;X
L157EAE: db $40;X
L157EAF: db $40;X
L157EB0: db $49;X
L157EB1: db $22;X
L157EB2: db $00;X
L157EB3: db $10;X
L157EB4: db $00;X
L157EB5: db $20;X
L157EB6: db $14;X
L157EB7: db $10;X
L157EB8: db $00;X
L157EB9: db $20;X
L157EBA: db $80;X
L157EBB: db $01;X
L157EBC: db $00;X
L157EBD: db $80;X
L157EBE: db $D0;X
L157EBF: db $C4;X
L157EC0: db $12;X
L157EC1: db $02;X
L157EC2: db $00;X
L157EC3: db $48;X
L157EC4: db $00;X
L157EC5: db $0A;X
L157EC6: db $10;X
L157EC7: db $22;X
L157EC8: db $00;X
L157EC9: db $24;X
L157ECA: db $10;X
L157ECB: db $70;X
L157ECC: db $00;X
L157ECD: db $00;X
L157ECE: db $00;X
L157ECF: db $40;X
L157ED0: db $10;X
L157ED1: db $08;X
L157ED2: db $00;X
L157ED3: db $00;X
L157ED4: db $00;X
L157ED5: db $00;X
L157ED6: db $21;X
L157ED7: db $00;X
L157ED8: db $A8;X
L157ED9: db $41;X
L157EDA: db $08;X
L157EDB: db $10;X
L157EDC: db $00;X
L157EDD: db $00;X
L157EDE: db $84;X
L157EDF: db $08;X
L157EE0: db $90;X
L157EE1: db $00;X
L157EE2: db $08;X
L157EE3: db $08;X
L157EE4: db $80;X
L157EE5: db $00;X
L157EE6: db $00;X
L157EE7: db $03;X
L157EE8: db $00;X
L157EE9: db $00;X
L157EEA: db $00;X
L157EEB: db $61;X
L157EEC: db $00;X
L157EED: db $A8;X
L157EEE: db $00;X
L157EEF: db $00;X
L157EF0: db $50;X
L157EF1: db $04;X
L157EF2: db $00;X
L157EF3: db $02;X
L157EF4: db $02;X
L157EF5: db $00;X
L157EF6: db $05;X
L157EF7: db $10;X
L157EF8: db $00;X
L157EF9: db $00;X
L157EFA: db $00;X
L157EFB: db $28;X
L157EFC: db $C3;X
L157EFD: db $00;X
L157EFE: db $80;X
L157EFF: db $40;X
L157F00: db $FF;X
L157F01: db $FF;X
L157F02: db $EB;X
L157F03: db $FF;X
L157F04: db $FF;X
L157F05: db $F7;X
L157F06: db $FF;X
L157F07: db $FF;X
L157F08: db $FF;X
L157F09: db $FE;X
L157F0A: db $EF;X
L157F0B: db $FF;X
L157F0C: db $FD;X
L157F0D: db $FF;X
L157F0E: db $FF;X
L157F0F: db $FF;X
L157F10: db $FF;X
L157F11: db $7F;X
L157F12: db $9F;X
L157F13: db $FF;X
L157F14: db $7F;X
L157F15: db $DF;X
L157F16: db $FF;X
L157F17: db $FF;X
L157F18: db $FF;X
L157F19: db $FF;X
L157F1A: db $FF;X
L157F1B: db $FF;X
L157F1C: db $EF;X
L157F1D: db $FF;X
L157F1E: db $FF;X
L157F1F: db $FF;X
L157F20: db $FF;X
L157F21: db $FF;X
L157F22: db $FD;X
L157F23: db $DF;X
L157F24: db $7E;X
L157F25: db $FF;X
L157F26: db $FF;X
L157F27: db $FF;X
L157F28: db $EF;X
L157F29: db $FC;X
L157F2A: db $DF;X
L157F2B: db $FF;X
L157F2C: db $EF;X
L157F2D: db $FF;X
L157F2E: db $FF;X
L157F2F: db $FF;X
L157F30: db $AF;X
L157F31: db $FF;X
L157F32: db $FF;X
L157F33: db $FF;X
L157F34: db $FB;X
L157F35: db $FE;X
L157F36: db $FF;X
L157F37: db $FF;X
L157F38: db $FF;X
L157F39: db $FF;X
L157F3A: db $FF;X
L157F3B: db $FF;X
L157F3C: db $FF;X
L157F3D: db $6F;X
L157F3E: db $EF;X
L157F3F: db $FF;X
L157F40: db $EF;X
L157F41: db $FF;X
L157F42: db $FF;X
L157F43: db $FF;X
L157F44: db $FF;X
L157F45: db $FF;X
L157F46: db $FF;X
L157F47: db $FF;X
L157F48: db $DF;X
L157F49: db $FF;X
L157F4A: db $77;X
L157F4B: db $F7;X
L157F4C: db $FF;X
L157F4D: db $FD;X
L157F4E: db $FF;X
L157F4F: db $FF;X
L157F50: db $EF;X
L157F51: db $FF;X
L157F52: db $FF;X
L157F53: db $FF;X
L157F54: db $7F;X
L157F55: db $FF;X
L157F56: db $FF;X
L157F57: db $FF;X
L157F58: db $FF;X
L157F59: db $FF;X
L157F5A: db $FF;X
L157F5B: db $FF;X
L157F5C: db $FF;X
L157F5D: db $F7;X
L157F5E: db $EF;X
L157F5F: db $FD;X
L157F60: db $FF;X
L157F61: db $FF;X
L157F62: db $FF;X
L157F63: db $FF;X
L157F64: db $FF;X
L157F65: db $EF;X
L157F66: db $DF;X
L157F67: db $F7;X
L157F68: db $7F;X
L157F69: db $FB;X
L157F6A: db $FF;X
L157F6B: db $F7;X
L157F6C: db $FF;X
L157F6D: db $FF;X
L157F6E: db $FF;X
L157F6F: db $FF;X
L157F70: db $FF;X
L157F71: db $FD;X
L157F72: db $AF;X
L157F73: db $FD;X
L157F74: db $EF;X
L157F75: db $FF;X
L157F76: db $FF;X
L157F77: db $F7;X
L157F78: db $DE;X
L157F79: db $BF;X
L157F7A: db $FF;X
L157F7B: db $FF;X
L157F7C: db $FE;X
L157F7D: db $EF;X
L157F7E: db $BF;X
L157F7F: db $FF;X
L157F80: db $00;X
L157F81: db $C0;X
L157F82: db $00;X
L157F83: db $D0;X
L157F84: db $48;X
L157F85: db $E0;X
L157F86: db $80;X
L157F87: db $C0;X
L157F88: db $A0;X
L157F89: db $04;X
L157F8A: db $00;X
L157F8B: db $00;X
L157F8C: db $00;X
L157F8D: db $81;X
L157F8E: db $00;X
L157F8F: db $00;X
L157F90: db $20;X
L157F91: db $02;X
L157F92: db $00;X
L157F93: db $00;X
L157F94: db $00;X
L157F95: db $20;X
L157F96: db $01;X
L157F97: db $02;X
L157F98: db $08;X
L157F99: db $60;X
L157F9A: db $80;X
L157F9B: db $00;X
L157F9C: db $00;X
L157F9D: db $08;X
L157F9E: db $20;X
L157F9F: db $00;X
L157FA0: db $00;X
L157FA1: db $00;X
L157FA2: db $00;X
L157FA3: db $20;X
L157FA4: db $00;X
L157FA5: db $81;X
L157FA6: db $05;X
L157FA7: db $88;X
L157FA8: db $02;X
L157FA9: db $84;X
L157FAA: db $88;X
L157FAB: db $02;X
L157FAC: db $80;X
L157FAD: db $20;X
L157FAE: db $88;X
L157FAF: db $00;X
L157FB0: db $04;X
L157FB1: db $80;X
L157FB2: db $90;X
L157FB3: db $20;X
L157FB4: db $00;X
L157FB5: db $A8;X
L157FB6: db $80;X
L157FB7: db $00;X
L157FB8: db $00;X
L157FB9: db $44;X
L157FBA: db $00;X
L157FBB: db $00;X
L157FBC: db $00;X
L157FBD: db $00;X
L157FBE: db $20;X
L157FBF: db $00;X
L157FC0: db $00;X
L157FC1: db $04;X
L157FC2: db $20;X
L157FC3: db $00;X
L157FC4: db $02;X
L157FC5: db $20;X
L157FC6: db $82;X
L157FC7: db $80;X
L157FC8: db $00;X
L157FC9: db $02;X
L157FCA: db $00;X
L157FCB: db $44;X
L157FCC: db $00;X
L157FCD: db $00;X
L157FCE: db $00;X
L157FCF: db $00;X
L157FD0: db $00;X
L157FD1: db $00;X
L157FD2: db $00;X
L157FD3: db $00;X
L157FD4: db $00;X
L157FD5: db $60;X
L157FD6: db $40;X
L157FD7: db $02;X
L157FD8: db $20;X
L157FD9: db $20;X
L157FDA: db $88;X
L157FDB: db $20;X
L157FDC: db $00;X
L157FDD: db $08;X
L157FDE: db $00;X
L157FDF: db $00;X
L157FE0: db $00;X
L157FE1: db $00;X
L157FE2: db $00;X
L157FE3: db $10;X
L157FE4: db $00;X
L157FE5: db $80;X
L157FE6: db $00;X
L157FE7: db $09;X
L157FE8: db $06;X
L157FE9: db $00;X
L157FEA: db $02;X
L157FEB: db $02;X
L157FEC: db $00;X
L157FED: db $A0;X
L157FEE: db $02;X
L157FEF: db $00;X
L157FF0: db $00;X
L157FF1: db $84;X
L157FF2: db $20;X
L157FF3: db $88;X
L157FF4: db $01;X
L157FF5: db $29;X
L157FF6: db $40;X
L157FF7: db $60;X
L157FF8: db $02;X
L157FF9: db $10;X
L157FFA: db $80;X
L157FFB: db $80;X
L157FFC: db $00;X
L157FFD: db $08;X
