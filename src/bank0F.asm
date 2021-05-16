;
; BANK $0F - Actor code
;

; =============== Act_ItemInBox_Unused_SpawnCoin ===============
; [TCRF] Unreachable code -- an actor with the ID for the coin is never inside an item box.
;        BGColi_HitItemBox spawns a coin by calling SubCall_ActS_SpawnCoinFromBlock.
; Meant to be called by Act_ItemInBox.
Act_ItemInBox_Unused_SpawnCoin: 
	mActOBJLstPtrTable OBJLstPtrTable_Act_Coin
	jr   Act_ItemInBox_SetDrop
	
; =============== Act_ItemInBox_Unused_Spawn10Coin ===============
; [TCRF] Unreachable code -- a 10-coin is never placed inside item boxes.
; Meant to be called by Act_ItemInBox.
Act_ItemInBox_Unused_Spawn10Coin:
	mActOBJLstPtrTable OBJLstPtrTable_Act_10Coin
	jr   Act_ItemInBox_SetDrop
	
; =============== Act_ItemInBox_SpawnStar ===============
; Spawns a star from an item box.
; Meant to be called by Act_ItemInBox.
Act_ItemInBox_SpawnStar:
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_Star
	jr   Act_ItemInBox_SetDrop
	
; =============== Act_ItemInBox_SetDrop ===============
; Spawns an item that drops down through the item box.
Act_ItemInBox_SetDrop:
	call ActColi_SetForDefault
	
	; Set a small jump for the coin/star when coming out
	ld   a, LOW(-$0C)
	ld   [sActSetYSpeed_Low], a
	ld   a, HIGH(-$0C)
	ld   [sActSetYSpeed_High], a
	
	xor  a
	ld   [sActSetTimer2], a
	ld   [sActSetOBJLstId], a
	
	; Move whatever we're spawning 8px above, to make it look like
	; it's coming from the top of the item box.
	; (but still not a full block above, otherwise it could get stuck)
	ld   bc, -$08
	call ActS_MoveDown
	
	ld   a, $01
	ld   [sActSetOpts], a
	
	; Set code pointer of the coin, which handles the item dropping down
	ld   bc, SubCall_Act_Coin
	call ActS_SetCodePtr
	
	;
	; Make the actor drop in the same direction the player's facing
	;
	ld   a, DIR_R			; Move right
	ld   [sActSetDir], a
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a	; Player facing right?
	ret  nz					; If so, return
	ld   a, DIR_L			; Move left otherwise
	ld   [sActSetDir], a
	ret
	
; =============== Act_Unused_SpawnCustom ===============
; [TCRF] Unreferenced spawn code to make an actor spawn a custom actor at the current location.
;        This must be called from actor code.
;        Unlike all other spawn subroutines, this one can spawn multiple actor types... and it's broken.
Act_Unused_SpawnCustom:
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
	jr   z, .notFound	; If so, return
	ld   a, l			; Move to next slot (HL += $20)
	add  (sActSet_End-sActSet)
	ld   l, a
	jr   .checkSlot
.notFound:
	ret
.slotFound:
	mActS_SetOBJBank OBJLstPtrTable_Act_Unused_Blank
	
	ld   a, $02		; Enabled
	ldi  [hl], a
	
	;
	; X Position -- same as current actor
	;
	ld   a, [sActSetX_Low]	; X = sActSetX
	ldi  [hl], a
	ld   a, [sActSetX_High]
	ldi  [hl], a
	
	;
	; Y Position -- place it above current actor (relative to collision box)
	;
	
	; The up extend collision is negative, so convert it back to positive
	ld   a, [sActSetColiBoxU]	; C = -sActSetColiBoxU
	cpl  
	inc  a
	ld   c, a
	
	ld   a, [sActSetY_Low]		; Y = sActSetY + sActSetColiBoxU
	sub  c
	ldi  [hl], a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ldi  [hl], a
	
	xor  a						; Collision type -- intangible
	ldi  [hl], a
	ld   a, -$0C				; Coli box U
	ldi  [hl], a
	ld   a, -$04				; Coli box D
	ldi  [hl], a
	ld   a, -$04				; Coli box L
	ldi  [hl], a
	ld   a, +$04				; Coli box R
	ldi  [hl], a
	
	; Shift origin right and down by $10px
	ld   a, $10
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	; [POI] Uses this thing, interestingly
	ld   a, LOW(OBJLstPtrTable_Act_Unused_Blank)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_Unused_Blank)
	ldi  [hl], a
	
	xor  a						; Dir
	ldi  [hl], a
	xor  a						; OBJLst ID
	ldi  [hl], a
	
	; [POI] The actor ID comes straight from an otherwise unused variable.
	ld   a, [sAct_Unused_SpawnId]
	ldi  [hl], a
	
	xor  a						; Routine ID
	ldi  [hl], a
	
	; [POI] This points right in the middle of ActBGColi_IsSolidOnTop, 
	;       in the middle of an instruction no less, which is definitely wrong.
	;       Not sure what this should have been -- ActS_Throw_LandDefault is a good fit though.
	ld   bc, $41F8				; Code Ptr
	ld   a, c
	ldi  [hl], a
	ld   a, b
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	ldi  [hl], a				; Timer 3
	ldi  [hl], a				; Timer 4
	xor  a
	ldi  [hl], a				; Timer 5
	ldi  [hl], a				; Timer 6
	ldi  [hl], a				; Timer 7
	
	ld   a, ACTFLAG_UNUSED_NOBUMPKILL	; Flags
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_Key)
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_Key)
	ldi  [hl], a
	ret

; =============== mActS_SetOBJLstTableForDefault ===============
; This macro generates code for an inline ActS_SetOBJLstTableForDefault.
mActS_SetOBJLstTableForDefault: MACRO
	; Generate the table index
	; DE = ((sActSetId & $0F) - 7) * 2
	ld   a, [sActSetId]
	and  a, $0F				; Filter away no-respawn flag
	sub  a, $07				; Table starts at the 7th entry
	add  a					; *2 since this is a ptr table
	ld   e, a				
	ld   d, $00
	
	; Index the ptr table with OBJLstPtrTable
	ld   hl, OBJLstPtrTableSet_Act_Defaults		
	add  hl, de
	; Get the read pointer and use it as OBJLstPtrTable
	ldi  a, [hl]
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, [hl]
	ld   [sActSetOBJLstPtrTablePtr_High], a
ENDM
 
; =============== ActS_SetOBJLstTableForDefault ===============
; This subroutine sets the OBJLstPtrTable for the currently processed *default* actor.
ActS_SetOBJLstTableForDefault:;I
	mActS_SetOBJLstTableForDefault
	ret
	
; =============== ActColi_SetForDefault ===============
; This subroutine gets the collision type for the currently processed *default* actor.
; Obviously this should only be used for default actors (IDs >= $07).
;
; Because the collision type effectively defines the behaviour for default actors,
; this *partially* counts as an actor ID assignment table.
; Keyword being "partially", since in other places (like Act_Coin), don't use this
; and set the collision type directly in the spawn code (because the same code is used
; for both 10-coins and normal coins, and only the spawn code knows the correct collision type).
ActColi_SetForDefault:
	; The collision types are stored in a table.
	; Since the first 7 actors IDs can't be used for this, the table starts with the entry for ID 7.
	ld   a, [sActSetId]	; A = (ActorID & $0F) - 7
	and  a, $0F			; Filter away no-respawn flag
	sub  a, $07
	
	ld   hl, .table		; HL = Start of table
	ld   d, $00			; DE = A (Index)
	ld   e, a
	add  hl, de			; Index this table
	
	ld   a, [hl]		; Read the collision type
	ld   [sActSetColiType], a	; And set it to the current actor
	ret
.table:
	db ACTCOLI_POW_GARLIC ; $07
	db ACTCOLI_POW_JET ; $08
	db ACTCOLI_POW_DRAGON ; $09
	db ACTCOLI_KEY ; $0A
	db ACTCOLI_10HEART ; $0B
	db ACTCOLI_STAR ; $0C
	db ACTCOLI_COIN ;X  ; [TCRF] $0D - NOT USED (coins are spawned with this set manually) 
	db ACTCOLI_10COIN ; $0E
	db ACTCOLI_POW_BULL ; $0F
	
; =============== ActInit_Default_ItemUsed ===============
ActInit_Default_ItemUsed:

	; This subroutine is only meant to be used for items that stand still
	; on top of an used item box.
	
	; Coins, 10-coins and the star fall through blocks.
	; If any of these is somehow placed on the item block, perma-despawn it.
	;
	; This can be triggered in C11, for example, by hitting the star block
	; and immediately entering and re-entering the door -- the star will be gone.
	; If this wasn't checked for, the star would be standing still on top of the block.
	ld   a, [sActSetId]
	cp   a, ACT_STAR
	jr   z, .despawn
	cp   a, ACT_COIN
	jr   z, .despawn
	cp   a, ACT_10COIN
	jr   z, .despawn
	
	; Setup code ptr
	ld   bc, SubCall_ActS_DefaultStand
	call ActS_SetCodePtr
	
	; Set animation
	mActS_SetOBJLstTableForDefault
	
	; The item should stand on top of the block, not inside it
	ld   bc, -$10
	call ActS_MoveDown
	
	xor  a
	ld   [sActSetYSpeed_Low], a			; Reset speed
	ld   [sActSetYSpeed_High], a
	ld   a, ACTFLAG_UNUSED_NOBUMPKILL	; Unkillable
	ld   [sActSetOpts], a
	ret
.despawn:
	xor  a
	ld   [sActSetActive], a
	ret
; =============== ActS_DefaultStand ===============
; This subroutine contains the main code for default actors when they stand still.
ActS_DefaultStand:

	; [BUG] This never despawn actors after a certain amount of time.
	;		This is fine for the key, but not for the 10coin.
	;       As a result, it's possible to have 10coins fall off, have them spin in place
	;		and not despawn until you manually go off-screen.

	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, ACTFLAG_UNUSED_NOBUMPKILL
	ld   [sActSetOpts], a
	; Every 8 frames increase the OBJLst id
	call ActS_IncOBJLstIdEvery8
	
	; If the actor is standing on a solid block, return
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	ret  nz
	
	;--
	; If the actor is on a water block, make it fall slowly
	; [POI] Technically it's possible to trigger this jump, but it's extremely difficult
	; 		and probably not even possible without debug mode.
	; 		This is because when we get to this subroutine, the actor already landed on a solid block and isn't moving.
	; 		Execution can get here if, after that, solid ground disappears from the platform.
	; 		Outside of water, this can easily be triggered by throwing a key on a breakable block,
	; 		then destroying the blocks.
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a
	jr   z, .waterFall
	;--
	call ActS_FallDownMax4Speed
	ret
.waterFall:
	; Move down at a fixed 1px/frame speed
	xor  a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ld   bc, $01
	call ActS_MoveDown
	ret
	
; =============== ActInit_Default ===============
; Init code for all default actors (id >= $07)
ActInit_Default:
	; Set collision type of default actor
	call ActColi_SetForDefault
	
	; Setup collision box
	ld   a, -$0E
	ld   [sActSetColiBoxU], a
	ld   a, -$0A
	ld   [sActSetColiBoxD], a
	ld   a, -$06
	ld   [sActSetColiBoxL], a
	ld   a, +$06
	ld   [sActSetColiBoxR], a
	
	xor  a								; Init timer
	ld   [sActSetTimer2], a
	ld   a, ACTFLAG_UNUSED_NOBUMPKILL	; Don't instakill with the (unused) bumpkill
	ld   [sActSetOpts], a
	
	;
	; If the actor positioned over an item box block, consider it as the item that's inside.
	; As a result:
	; - It should be hidden if the item box isn't used
	; - It should be visible, but one block above if it's used
	;
	call ActColi_GetBlockId_Low			; A = Block IDD overlapping with
	cp   a, BLOCKID_ITEMUSED			; Over an used item box?
	jp   z, ActInit_Default_ItemUsed	; If so, jump
	cp   a, BLOCKID_ITEMBOX				; Over an item box?
	jr   z, .item						; If so, jump
	
	;
	; [POI] Keys are the only actors that can be found lying on the ground.
	;       Any other actor that somehow isn't over an item box (ie: hearts),
	;       it will be treated like it's over one and will fail to appear.
	;
	ld   a, [sActSetId]
	cp   a, ACT_KEY						; Is the actor a key?
	jr   z, .key						; If so, jump
	
	
.item:
	;
	; ITEM INSIDE ITEM BOX
	;
	
	; Make intangible
	xor  a								
	ld   [sActSetColiType], a
	
	; Setup main code
	ld   bc, SubCall_Act_ItemInBox
	call ActS_SetCodePtr
	
	; Make invisible (until the box is hit)
	mActS_SetBlankFrame
	ret
	
.key:
	;
	; KEY ON THE GROUND
	;
	ld   a, $1E					; Skip the rise-up animation
	ld   [sActItemRiseTimer], a
	
	; Setup main code
	ld   bc, SubCall_Act_ItemGround
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_Key
	
	ld   a, ACTFLAG_UNUSED_NOBUMPKILL	; Not necessary
	ld   [sActSetOpts], a
	ret
	
; =============== Act_ItemInBox ===============
Act_ItemInBox:
	; Make invisible and intangible
	mActS_SetBlankFrame
	xor  a
	ld   [sActSetColiType], a
	
	;
	; When the block we're over is hit, BGColi_HitItemBox will set its MSB for us.
	; Until that is set, continue staying hidden.
	;
	; [BUG] This is questionable reusing of the MSB.
	;
	;       The MSB of a block in the level layout is used to mark if an actor should
	;       spawn when it scrolls the screen.
	;       When an actor spawns, the bit is removed from the level layout.
	;       When an actor despawns by going off-screen, the bit is set back.
	;
	;       If an actor despawns on the same block as the item, the
	;       MSB gets set and the item pops out of the box. Oops!
	call ActColi_GetBlockId_Low		; A = Block ID of what we're over
	bit  7, a						; Is the MSB set?
	ret  z							; If not, return
	
.showItem:
	; Clear the MSB of the block
	ld   a, [sActSetLevelLayoutPtr]
	ld   l, a
	ld   a, [sActSetLevelLayoutPtr+1]
	ld   h, a
	res  7, [hl]
	
	;
	; Determine what we're actually spawning
	;
	ld   a, [sActSetId]
	; Stars are rare enough, but they exist
	cp   a, ACT_STAR
	jp   z, Act_ItemInBox_SpawnStar
	
	; [TCRF] Coins are spawned by default if no item is over the item box
	;        Because of this, it's actor ID is never placed inside a box.
	cp   a, ACT_COIN
	jp   z, Act_ItemInBox_Unused_SpawnCoin
	; [TCRF] 10-coins never come out of item boxes
	cp   a, ACT_10COIN
	jp   z, Act_ItemInBox_Unused_Spawn10Coin
	
	; Everything else pops out slowly (keys, powerups, hearts)
	ld   a, SFX1_0D				; Play item box SFX
	ld   [sSFX1Set], a
	
	;
	; Prevent the key from spawning if the key lock is already open.
	; (read: the treasure's been collected already)
	;
	ld   a, [sActSetId]
	and  a, $0F					; Filter away no-respawn flag
	cp   a, ACT_KEY				; Is this a key?
	jr   nz, .spawnOk			; If not, skip
	ld   a, [sLvlTreasureDoor]
	cp   a, LOCK_OPEN			; Is the key lock open?
	jr   nz, .spawnOk			; If not, skip
	xor  a						; Otherwise, don't spawn the key
	ld   [sActSet], a
	ret
.spawnOk:
	ld   a, $01
	ld   [sActSetTimer2], a
	xor  a
	ld   [sActItemYSpeed], a
	ld   [sActItemRiseTimer], a	; Rise up as normal
	ld   [sActSetOBJLstId], a	; Reset anim frame
	
	; Set animation
	mActS_SetOBJLstTableForDefault
	
	; Replace code ptr with the item
	ld   bc, SubCall_Act_ItemGround
	call ActS_SetCodePtr
	ret
	
; =============== Act_ItemGround ===============
; An item standing on the ground.
; By default, this rises up since it's mostly used by items inside item boxes.
Act_ItemGround:
	ld   a, [sActSetTimer]				; Timer++
	inc  a
	ld   [sActSetTimer], a
	ld   a, ACTFLAG_UNUSED_NOBUMPKILL	; Force mark unkillable
	ld   [sActSetOpts], a
	
	; Animate every $10 frames
	call ActS_IncOBJLstIdEvery8
	
	;
	; Make the item rise up from the item box.
	; The item will move a full block above by the end of the anim.
	;
	ld   a, [sActItemRiseTimer]
	cp   a, $10						; RiseTimer >= $10?	
	jr   nc, .chkGravity			; If so, skip
	
.riseUp:
	xor  a							; Make intangible during this
	ld   [sActSetColiType], a
	
	; Move up at 0.25px/frame
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, [sActItemRiseTimer]		; RiseTimer++
	inc  a
	ld   [sActItemRiseTimer], a
	ld   bc, -$01					; Move up 1px
	call ActS_MoveDown
	ret
.chkGravity:
	; Since the collision type is cleared during the rise-up anim,
	; we have to restore it.
	call ActColi_SetForDefault
	
	;
	; VERTICAL MOVEMENT / GRAVITY
	;
	
	; Only makes sense for keys
	ld   a, [sActSetId]
	cp   a, ACT_KEY				; Is this a key?
	ret  nz						; If not, return
	
	; Move down by the specified speed
	ld   a, [sActItemYSpeed]	; BC = YSpeed
	ld   c, a
	ld   b, $00
	call ActS_MoveDown			; Move down by that
	
	; If we are on solid ground, reset the fall speed.
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a						; Is there a solid block below?
	jr   z, .incYSpeed				; If not, jump
.onGround:
	xor  a						; Reset Y speed
	ld   [sActItemYSpeed], a
	ld   a, [sActSetY_Low]		; Align to Y block grid
	and  a, $F0
	ld   [sActSetY_Low], a
	ret
.incYSpeed:
	; Increase the drop speed every 4 frames, up to 4px/frame max.
	ld   a, [sActSetTimer]
	and  a, $03					; Every 4 frames...
	ret  nz
	ld   a, [sActItemYSpeed]
	cp   a, $04					; YSpeed >= $04?
	ret  nc						; If so, return
	inc  a						; Otherwise, YSpeed++
	ld   [sActItemYSpeed], a
	ret
; =============== Act_Coin_SwitchHorzMove ===============
; Inverts the coin's horizontal direction.
; Used when a coin reaches a wall.
Act_Coin_SwitchHorzMove:
	; Only one direction (DIR_R or DIR_L) may be active at a time.
	; xor both of them to invert their status.
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L		
	ld   [sActSetDir], a
	ret
; =============== Act_Coin_MoveRight ===============
; Used to move the current actor to the right.
; Internally used by the coin actor.
Act_Coin_MoveRight:
	; Move the coin
	ld   bc, +$01
	call ActS_MoveRight
	; If there's a solid block on the right, start moving left
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	call nz, Act_Coin_SwitchHorzMove
	ret
; =============== Act_Coin_MoveLeft ===============
; Used to move the current actor to the right.
; Internally used by the coin actor.
Act_Coin_MoveLeft:
	ld   bc, -$01
	call ActS_MoveRight
	; If there's a solid block on the left, start moving right
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	call nz, Act_Coin_SwitchHorzMove
	ret
	
; =============== ActS_Spawn10CoinHeld ===============
; Spawns a 10-coin held by the player.
ActS_Spawn10CoinHeld:
	; Don't spawn it if we're already holding something
	ld   a, [sActHeld]
	or   a
	ret  nz
	; Find an empty slot
	ld   b, $00			; B = Found 10-coins
	ld   hl, sAct		; HL = Actor slot area
	ld   d, $07			; D = Slot to search in
	ld   e, $00			; E = Current slot
.checkSlot:
	ld   a, [hl]
	or   a				; Is the slot empty?
	jr   z, .slotFound	; If so, jump
	
.checkCoinLimit:
	;--
	; [TCRF] The way the code is organized implies you could spawn more than one coin while another was on-screen.
	;        But, as soon as one 10coin is found the subroutine returns.
	;        This was very likely changed to avoid abusing the actor limit.
	;        Though this may just been copied over and adapted from something like Act_SSTeacupBoss_SpawnWatch.
	
	; NOTE: This doesn't account for possible empty slots being before the coin.
	; 		By spawning other actors, spawning a 10coin and then killing the actor, it's
	;		possible to spawn a second coin.
	; 		Though this is still enough to avoid most issues.
	
	ld   a, l			; Move to actor id location
	add  sActSetId-sActSet		
	ld   l, a
	ld   a, [hl]		; Read it
	cp   a, ACT_10COIN	; Is it a 10-coin?
	jr   nz, .nextSlot	; If not, jump
	
	inc  b				; Found++
	ld   a, b
	cp   a, $01			; Reached the limit of $01?
	ret  z				; If so, return
	;--
.nextSlot:
	inc  e				; Slot++
	dec  d				; Have we searched in all 7 slots?
	jr   z, .notFound	; If so, return
	ld   a, l			; If not, move to the next actor slot
	add  (sActSet_End-sActSet) - (sActSetId-sActSet)
	ld   l, a
	jr   .checkSlot
.notFound:
	ret
.slotFound:
	mActS_SetOBJBank OBJLstPtrTable_Act_10CoinHeld
	
	ld   a, $02					; Enabled
	ldi  [hl], a
	ld   a, [sPlX_Low]			; X
	ldi  [hl], a
	ld   a, [sPlX_High]
	ldi  [hl], a
	ld   a, [sPlY_Low]			; Y
	ldi  [hl], a
	ld   a, [sPlY_High]
	ldi  [hl], a
	xor  a						; Collision type
	ldi  [hl], a
	ld   a, -$0C				; Bounding Box U
	ldi  [hl], a
	ld   a, -$04				; Bounding Box D
	ldi  [hl], a
	ld   a, -$06				; Bounding Box L
	ldi  [hl], a
	ld   a, +$06				; Bounding Box R
	ldi  [hl], a
	ld   a, $10					
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	ld   a, LOW(OBJLstPtrTable_Act_10CoinHeld)	; OBJLst Table
	ldi  [hl], a				
	ld   a, HIGH(OBJLstPtrTable_Act_10CoinHeld)	; OBJLst Table
	ldi  [hl], a
	xor  a						; Dir
	ldi  [hl], a
	xor  a						; OBJLSt ID
	ldi  [hl], a
	ld   a, ACT_10COIN			; Actor ID
	ldi  [hl], a
	xor  a						; Routine ID
	ldi  [hl], a
	ld   a, LOW(SubCall_ActS_Held)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_ActS_Held)	; Code Ptr
	ldi  [hl], a
	ld   a, $0C					; Timer
	ldi  [hl], a
	xor  a
	ldi  [hl], a				; Timer 2
	ldi  [hl], a				; Jump Speed (Low byte)
	ldi  [hl], a				; Jump Speed (High byte)
	ldi  [hl], a				; Timer 5
	ldi  [hl], a				; Timer 6
	ldi  [hl], a				; Timer 7
	ld   a, $01					; Flags
	ldi  [hl], a
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock); Level layout ptr (not used)
	ldi  [hl], a
	ld   a, LOW(OBJLstSharedPtrTable_Act_10Coin)		; Shared table ptr 
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_10Coin)		; Shared table ptr
	ldi  [hl], a
	
	ld   a, $01					; Mark the coin as held
	ld   [sActHeld], a
	xor  a						; Not heavy
	ld   [sActHoldHeavy], a
	ld   a, SFX1_0B
	ld   [sSFX1Set], a
	ret
; =============== OBJLstSharedPtrTable_Act_10Coin ===============
OBJLstSharedPtrTable_Act_10Coin:
	dw OBJLstPtrTable_Act_10Coin;X
	dw OBJLstPtrTable_Act_10Coin;X
	dw OBJLstPtrTable_Act_10Coin;X
	dw OBJLstPtrTable_Act_10Coin;X
	dw OBJLstPtrTable_Act_10Coin
	dw OBJLstPtrTable_Act_10Coin
	dw OBJLstPtrTable_Act_10Coin;X
	dw OBJLstPtrTable_Act_10Coin;X

; =============== ActS_SpawnKeyHeld ===============
; Spawns a key held by the player.
ActS_SpawnKeyHeld:
	; Find an empty slot
	ld   hl, sAct		; HL = Actor slot area
	ld   d, $07			; D = Slots left
	ld   e, $00			; E = Current slot
.loop:
	ld   a, [hl]
	or   a				; Is the slot empty?
	jr   z, .slotFound	; If so, jum
	
	inc  e				; Slot++
	dec  d				; Have we searched in all 7 slots?
	ret  z				; If so, return
	ld   a, l			; If not, move to the next actor slot
	add  sActSet_End-sActSet
	ld   l, a
	jr   .loop
	
.slotFound:
	mActS_SetOBJBank OBJLstPtrTable_Act_Key
	
	ld   a, $02					; Enabled
	ldi  [hl], a
	ld   a, [sPlX_Low]		; X
	ldi  [hl], a
	ld   a, [sPlX_High]
	ldi  [hl], a
	ld   a, [sPlY_Low]		; Y
	ldi  [hl], a
	ld   a, [sPlY_High]
	ldi  [hl], a
	ld   a, $20					; Collision type
	ldi  [hl], a
	ld   a, -$0C				; Bounding Box U
	ldi  [hl], a
	ld   a, -$04				; Bounding Box D
	ldi  [hl], a
	ld   a, -$06				; Bounding Box L
	ldi  [hl], a
	ld   a, +$06				; Bounding Box R
	ldi  [hl], a
	ld   a, [sPlYRel]		; Rel.Y (Origin)
	ldi  [hl], a
	ld   a, [sPlXRel]		; Rel.X (Origin)
	ldi  [hl], a				
	ld   a, LOW(OBJLstPtrTable_Act_Key)		; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_Key)		; OBJLst Table
	ldi  [hl], a
	xor  a						; Dir
	ldi  [hl], a
	xor  a						; OBJLst ID
	ldi  [hl], a
	ld   a, $0A					; Actor ID
	ldi  [hl], a
	xor  a						; Routine ID
	ldi  [hl], a
	ld   a, LOW(SubCall_ActS_Held)		; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_ActS_Held)		; Code Ptr
	ldi  [hl], a
	ld   a, $0C					; Timer
	ldi  [hl], a
	xor  a
	ldi  [hl], a				; Timer 2
	ldi  [hl], a                ; Y Speed (Low byte)
	ldi  [hl], a                ; Y Speed (High byte)
	ldi  [hl], a                ; Timer 5
	ldi  [hl], a                ; Timer 6
	ldi  [hl], a                ; Timer 7
	ld   a, $01                 ; Flags
	ldi  [hl], a
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock); Level layout ptr (not used)
	ldi  [hl], a
	ld   a, LOW(OBJLstSharedPtrTable_Act_Key)	; Shared table ptr
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_Key)	; Shared table ptr
	ldi  [hl], a
	ld   a, $01					; Mark the key as held
	ld   [sActHeld], a
	ld   [sActHeldKey], a
	xor  a						; Not heavy
	ld   [sActHoldHeavy], a
	ld   a, SFX1_0B
	ld   [sSFX1Set], a
	ret
OBJLstSharedPtrTable_Act_Key:
	dw OBJLstPtrTable_Act_Key;X
	dw OBJLstPtrTable_Act_Key;X
	dw OBJLstPtrTable_Act_Key;X
	dw OBJLstPtrTable_Act_Key;X
	dw OBJLstPtrTable_Act_Key
	dw OBJLstPtrTable_Act_Key
	dw OBJLstPtrTable_Act_Key;X
	dw OBJLstPtrTable_Act_Key;X

; =============== ActS_SpawnStunStar ===============
; This subroutine spawns the circling stars shown when an heavy enemy or boss is stunned.
;
; Because its position should be kept in sync with the stunned actor, it should
; only be called when executing another actor's code.
; This subroutine expects the "sActSet" (currently executed actor) info to be available,
; as well as the slot number of the current actor.
ActS_SpawnStunStar:
	ld   hl, sAct			; HL = Actor slot area
	ld   d, $05				; D = Slots count (normal slots)
	ld   e, $00				; E = Current slot
	
.checkSlot:
	ld   a, [hl]			; Read active status
	or   a					; Is the slot free? (status == 0)
	jr   z, .slotFound			; If so, jump
	
	;--
	; Prevent more than one instance of this actor from spawning.
	; To do this, check if the code ptr matches with what we'll be setting.
	ld   a, l				; Seek to code ptr
	add  (sActSetCodePtr-sActSet)
	ld   l, a
	ldi  a, [hl]			; Read low byte
	cp   a, LOW(SubCall_Act_StunStar)	; Does it match?
	jr   nz, .nextSlot		; If not, continue searching
	ld   a, [hl]			; Read byte
	cp   a, HIGH(SubCall_Act_StunStar)	; Does it match?
	ret  z					; If so, stop searching
	;--
.nextSlot:
	inc  e					; Slot++
	dec  d					; Have we searched in all 5 slots?
	ret  z					; If so, return
	ld   a, l				; If not, move to the next actor slot
	add  (sActSet_End-sActSet) - (sActSetCodePtr-sActSet) - $01
	ld   l, a
	jr   .checkSlot
	
.slotFound:
	mActS_SetOBJBank OBJLstPtrTable_Act_StunStar
	
	ld   a, $02					; Enabled
	ldi  [hl], a
	ld   a, [sActSetX_Low]		; X = sActSetX
	ldi  [hl], a
	ld   a, [sActSetX_High]		
	ldi  [hl], a
	
	;--
	; Place stars right above the stunned actor collision box.
	; Y = sActSetY - ColiU
	
	; The top bounding box value is negative, so we need to convert it back to positive first.
	ld   a, [sActSetColiBoxU]	; C = -sActSetColiBoxU (since this value is negative)
	cpl
	inc  a
	ld   c, a
	
	; Then subtract it to the current actor's Y pos.
	; This being a 16bit value is why the conversion was necessary.
	ld   a, [sActSetY_Low]
	sub  a, c					; sActSetY -= C
	ldi  [hl], a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ldi  [hl], a
	;--
	
	xor  a						; Set as intangible
	ldi  [hl], a
	ld   a, $F4					; Coli box U
	ldi  [hl], a
	ld   a, $FC					; Coli box D
	ldi  [hl], a
	ld   a, $FA					; Coli box L
	ldi  [hl], a
	ld   a, $06					; Coli box R
	ldi  [hl], a
	
	ld   a, $10
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_StunStar)	; OBJLst
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_StunStar)
	ldi  [hl], a
	
	xor  a						; Dir (none)
	ldi  [hl], a
	xor  a						; OBJLst frame
	ldi  [hl], a
	
	; Actor ID is set to $06 purely to avoid conflicts.
	; It doesn't otherwise matter since this isn't an actor defined in an actor group.
	; That in turns means it will never be spawned back properly if put in an actor layout
	; and, well, we don't need to respawn this anyway.
	ld   a, ACT_NORESPAWN|$06	; Actor ID
	ldi  [hl], a
	
	xor  a						; Routine ID
	ldi  [hl], a
	ld   a, LOW(SubCall_Act_StunStar)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_StunStar)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	ldi  [hl], a				; Timer 3
	ldi  [hl], a				; Timer 4
	
	; Save slot number of the current actor, so its position
	; can be kept in sync.
	ld   a, [sActNumProc]		; Timer 5 (slot number of the actor hit)
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
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_StunStar)	; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_StunStar)
	ldi  [hl], a
	
	ret
	
OBJLstSharedPtrTable_Act_StunStar:
	dw OBJLstPtrTable_Act_StunStar;X
	dw OBJLstPtrTable_Act_StunStar;X
	dw OBJLstPtrTable_Act_StunStar;X
	dw OBJLstPtrTable_Act_StunStar;X
	dw OBJLstPtrTable_Act_StunStar;X
	dw OBJLstPtrTable_Act_StunStar;X
	dw OBJLstPtrTable_Act_StunStar;X
	dw OBJLstPtrTable_Act_StunStar;X
	
; =============== Act_StunStar ===============
; Loop code for the star effect applied to another stunned actor.
Act_StunStar:

	;--
	;
	; Sync the actor's coords with the one we're tracking.
	;
	
	; First, get the offset to the actor's slot info.
	; DE = TrackedSlotNum * $20
	;      TrackedSlotNum << 5
	ld   a, [sActStunStarParentSlot]
	and  a, $07					; Keep in range $00-$07
	swap a						; A << 4
	rlca						; A << 1
	ld   d, $00					; DE = Index
	ld   e, a
	
	; Now we just need to do what we've previously done in the spawn code, more or less.
	
	; Seek to the height of the top collision box. We're using it to position
	; the stars right above it (since they more or less match the visible sprite).
	ld   hl, sAct+(sActSetColiBoxU-sActSet)	; HL = Collision for first slot			
	add  hl, de					; Offset the correct slot
	
	; The top bounding box value is negative, so we need to convert it back to positive first.
	ld   a, [hl]	; C = -sActSetColiBoxU
	cpl
	inc  a
	ld   c, a
	
	; Seek to the coords
	ld   hl, sAct+(sActSetX_Low-sActSet)	; HL = X for first slot	
	add  hl, de					; Offset the correct slot
	
	; Update X coord
	ldi  a, [hl]
	ld   [sActSetX_Low], a
	ldi  a, [hl]
	ld   [sActSetX_High], a
	
	; Update Y coord.
	; This being a 16bit value is why the conversion was necessary.
	ldi  a, [hl]
	sub  a, c				; Y = TrackedY - C
	ld   [sActSetY_Low], a
	ldi  a, [hl]
	sbc  a, $00
	ld   [sActSetY_High], a
	;--
	
	; Every other frame increase the anim frame
	ld   a, [sTimer]
	and  a, $01
	jr   nz, .chkDespawn
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.chkDespawn:
	; Despawn after $3C frames
	ld   a, [sActSetTimer]
	inc  a						; Timer++
	ld   [sActSetTimer], a
	cp   a, $3C					; Timer < $3C?
	ret  c						; If so, return
	xor  a						; Otherwise, despawn stars
	ld   [sActSet], a
	ret
	
OBJLst_Act_StunStar0: INCBIN "data/objlst/actor/stunstar0.bin"
OBJLst_Act_StunStar1: INCBIN "data/objlst/actor/stunstar1.bin"
OBJLst_Act_StunStar2: INCBIN "data/objlst/actor/stunstar2.bin"
OBJLst_Act_StunStar3: INCBIN "data/objlst/actor/stunstar3.bin"
OBJLst_Act_StunStar4: INCBIN "data/objlst/actor/stunstar4.bin"
OBJLst_Act_StunStar5: INCBIN "data/objlst/actor/stunstar5.bin"
OBJLst_Act_StunStar6: INCBIN "data/objlst/actor/stunstar6.bin"
OBJLst_Act_StunStar8: INCBIN "data/objlst/actor/stunstar8.bin"

; =============== ActS_SpawnHeartInvincible ===============
; Spawns a heart after interacting with an actor while invincible, then awards 10 hearts. 
ActS_SpawnHeartInvincible:
	;--
	; If we aren't invincible, don't do anything
	ld   a, [sPlInvincibleTimer]
	or   a
	ret  z
	cp   a, $FF
	ret  z
	;--
	; Find the first empty slot we can use
	ld   hl, sAct
	ld   d, $07		; D = Total slots
	ld   e, $00		; E = Slot ID
.nextSlot:
	ld   a, [hl]	; Is this an empty slot?
	or   a
	jr   z, .slotFound	; If so, use it
	
	;--
	; Prevent spawning more than one heart at a time.
	; If the code pointer already points to SubCall_Act_HeartInvincible, return immediately.
	
	; Point to the code ptr
	ld   a, l							; HL += $12
	add  (sActSetCodePtr-sActSet)
	ld   l, a
	
	ldi  a, [hl]
	cp   a, LOW(SubCall_Act_HeartInvincible)	; Low byte ends with $FB?
	jr   nz, .setNext		; If not, switch to the next slot
	ld   a, [hl]			
	cp   a, HIGH(SubCall_Act_HeartInvincible)	; High byte starts with $38?
	ret  z					; If so, return
	;--
.setNext:
	; Switch to next slot
	inc  e				; SlotCount++
	dec  d				; Did we check all slots?
	jr   z, .noSpawn	; If so, don't spawn the heart
	
	; Add the remainder of the slot size (for a total add of $20)
	; We previously added $12 (sActSetCodePtr), then increased by 1 with an ldi
	; With the slot size being $20, $0D bytes should be added to point to the next slot ($20-$12-$01 = $0D)
	ld   a, l			
	add  (sActSet_End-sActSetCodePtr-1)
	ld   l, a
	jr   .nextSlot
.noSpawn: 
	ret
	
.slotFound:
	mActS_SetOBJBank OBJLstPtrTable_Act_Heart
	
	ld   a, $02					; Active actor
	ldi  [hl], a
	
	ld   a, [sActSetX_Low]		; X
	ldi  [hl], a
	ld   a, [sActSetX_High]
	ldi  [hl], a
	;--
	; [BUG] This is meant to spawn the heart exactly above the actor, to make it immediately visible.
	;		Otherwise, it would spawn over the star effect.
	;		The top collision box size is a good value to determine this, 
	;		since it goes off the same origin, and its height matches more or less the sprite height.
	;		However, they used the wrong collision border here.
	;		It should have been sActSetColiBoxL, though the error is barely perceptible.
	ld   a, [sActSetColiBoxU]	; C = ABS(sActSetColiBoxU)
	cpl							; Note: sActSetColiBoxU is always negative
	inc  a
	ld   c, a
	
	ld   a, [sActSetY_Low]		; Y = sActSetY_Low - C
	sub  a, c
	ldi  [hl], a
	ld   a, [sActSetY_High]
	sbc  a, $00					; account for carry
	ldi  [hl], a
	;--
	
	xor  a						; Collision type (intangible)	
	ldi  [hl], a				
	ld   a, $F4					; Coli box U
	ldi  [hl], a
	ld   a, $FC					; Coli box D
	ldi  [hl], a
	ld   a, $FA					; Coli box L
	ldi  [hl], a
	ld   a, $06					; Coli box R
	ldi  [hl], a				
	
	ld   a, $10					
	ldi  [hl], a				; Rel Y / Origin
	ldi  [hl], a				; Rel X / Origin
	
	ld   a, LOW(OBJLstPtrTable_Act_Heart)		; OBJLst table ptr
	ldi  [hl], a				
	ld   a, HIGH(OBJLstPtrTable_Act_Heart)	; OBJLst table ptr
	ldi  [hl], a				
	
	xor  a						; Direction
	ldi  [hl], a
	xor  a						; OBJLstId
	ldi  [hl], a
	ld   a, ACT_HEART			; Actor ID -- doesn't really change anything here
	ldi  [hl], a
	xor  a						; Routine ID 
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_HeartInvincible)		; Code ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_HeartInvincible)		; Code ptr
	ldi  [hl], a
	
	xor  a						
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	ldi  [hl], a				; Timer 3 (not used)
	ldi  [hl], a				; Timer 4 (not used)
	ld   a, [sActNumProc]		; Timer 5 (store slot number)
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
	ld   a, LOW(OBJLstSharedTablePtr_Act_HeartInvincible)		; OBJLstSharedTable ptr
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedTablePtr_Act_HeartInvincible)		; OBJLstSharedTable ptr
	ldi  [hl], a
	; Award 10 hearts for the kill (alongside the normal 1 heart given)
	call Game_Add10Hearts
	ret
	
OBJLstSharedTablePtr_Act_HeartInvincible:
	dw OBJLstPtrTable_Act_Heart;X
	dw OBJLstPtrTable_Act_Heart;X
	dw OBJLstPtrTable_Act_Heart;X
	dw OBJLstPtrTable_Act_Heart;X
	dw OBJLstPtrTable_Act_Heart;X
	dw OBJLstPtrTable_Act_Heart;X
	dw OBJLstPtrTable_Act_Heart;X
	dw OBJLstPtrTable_Act_Heart;X
	
; =============== Act_HeartInvincible ===============
Act_HeartInvincible:
	call ActS_CheckOffScreen	; Update offscreen status
	ld   a, [sActSet]
	cp   a, $02					; Is it visible and active? >= $02?
	jr   c, .despawn				; If not, despawn it
	
	; Every 4 frames increase the anim frame
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .moveUp
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.moveUp:
	ld   bc, -$02				; Move 2px up
	call ActS_MoveDown
	
	; Show this actor for $14 frames
	ld   a, [sActSetTimer]
	inc  a						; Timer++
	ld   [sActSetTimer], a
	cp   a, $14					; Has it reached $14?
	ret  c						; If not, return
.despawn:
	xor  a						; Otherwise, hard despawn it
	ld   [sActSet], a
	ret
	
; =============== ActS_CoinGame ===============
; This subroutine, meant to execute under a boss actor, handles the coin rain after defeating a boss.
ActS_CoinGame:

	;--
	; Handle the global time limit. When it expires trigger the stage clear.
	; This one starts out at $021C (see Level_LoadActLayout).
	ld   a, [sActCoinGameTimer_Low]		; BC = sActCoinGameTimer
	ld   c, a
	ld   a, [sActCoinGameTimer_High]
	ld   b, a
	or   a, c							; TimerLeft == 0?
	jp   z, .endGame					; If so, end the game
	dec  bc								; Otherwise, decrement the timer
	ld   a, c
	ld   [sActCoinGameTimer_Low], a
	ld   a, b
	ld   [sActCoinGameTimer_High], a
	;--
	ld   a, [sPlAction]
	cp   a, PL_ACT_JUMP		; Is the player jumping?
	ret  z					; If so, don't spawn coins
	
	;--
	; Find a free slot to spawn the coin in.
	; If the player isn't jumping, this won't give any cooldown time.
	ld   hl, sAct	; HL = Slot area
	ld   d, $07		; D = Slots left
	ld   e, $00		; E = Current slot num 
.checkSlot:;
	ld   a, [hl]	; Read status
	or   a			; Is this slot marked as free?
	jr   z, .slotFound	; If so, jump
.nextSlot:
	inc  e			; SlotNum++
	dec  d			; SlotsLeft--
	ret  z			; If there are none left, return
	ld   a, l		; HL += SlotSize
	add  (sActSet_End-sActSet)
	ld   l, a
	jr   .checkSlot
.slotFound:
	;--
	
	; Set sLvlClearOnDeath to make sure the player can't die when falling in lava.
	; Since we need to set it, we might as well reuse it as a (secondary) timer.
	ld   a, [sLvlClearOnDeath]
	cp   a, $1E					; Don't spawn any coins for the first $1E frames
	jp   nc, .incSecTimer
	
assert BANK(OBJLstPtrTable_Act_Coin) == BANK(OBJLstPtrTable_Act_10Coin), "OBJLstPtrTable_Act_Coin and OBJLstPtrTable_Act_10Coin must be in the same bank."
	mActS_SetOBJBank OBJLstPtrTable_Act_Coin
	
	;--
	; Randomize the properties of the spawned coin
	call Rand
	ld   a, [sRandom]
	bit  6, a
	jr   nz, .spawn10Coin
.spawnCoin:
	ld   a, ACTCOLI_COIN
	ld   [sCoinGameColiType], a
	ld   a, LOW(OBJLstPtrTable_Act_Coin)
	ld   [sCoinGameOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Coin)
	ld   [sCoinGameOBJLstPtrTablePtr_High], a
	jr   .spawnAct
.spawn10Coin:
	ld   a, ACTCOLI_10COIN
	ld   [sCoinGameColiType], a
	ld   a, LOW(OBJLstPtrTable_Act_10Coin)
	ld   [sCoinGameOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_10Coin)
	ld   [sCoinGameOBJLstPtrTablePtr_High], a
	;--
	
.spawnAct:
	ld   a, [sActSet]			; Copy over activity status (this is $02 in practice)
	ldi  [hl], a
	
	ld   a, [sLvlScrollX_Low]	; X = LvlScrollX
	ldi  [hl], a
	ld   a, [sLvlScrollX_High]
	ldi  [hl], a
	
	ld   a, [sLvlScrollY_Low]	; Y = LvlScrollY - $20
	sub  a, $20
	ldi  [hl], a
	ld   a, [sLvlScrollY_High]
	sbc  a, $00
	ldi  [hl], a
	
	ld   a, [sCoinGameColiType]				; Collision type (coin or 10 coin?)
	ldi  [hl], a
	ld   a, -$0C				; Coli box U
	ldi  [hl], a
	ld   a, -$04				; Coli box D
	ldi  [hl], a
	ld   a, -$06				; Coli box L
	ldi  [hl], a
	ld   a, +$06				; Coli box R
	ldi  [hl], a
	
	ld   a, [sActSetRelY]		; Rel.Y (Origin)
	ldi  [hl], a
	ld   a, [sActSetRelX]		; Rel.X (Origin)
	ldi  [hl], a
	ld   a, [sCoinGameOBJLstPtrTablePtr_Low]	; OBJLst Table
	ldi  [hl], a
	ld   a, [sCoinGameOBJLstPtrTablePtr_High]
	ldi  [hl], a
	
	;--
	; Direction depends on the random value
	
	; Randomize bit 0
	ld   a, [sRandom]
	and  a, $10			
	swap a
	ld   b, a			; B = SWAP(sRandom % 10)
	
	; Make sure bit 1 won't be set
	rlca				; << 1 the aforemented bit (now bit 1)
	xor  $02			; invert it, so we don't get invalid directions
	
	or   a, b			; Merge the two bits
	ldi  [hl], a		; Write the result
	;--
	
	xor  a				; OBJLst ID
	ldi  [hl], a
	ld   a, ACT_COIN	; Actor ID
	ldi  [hl], a
	ld   a, [sActSetRoutineId]	 ; Routine ID
	ldi  [hl], a
	ld   a, LOW(SubCall_Act_CoinGame_Coin)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_CoinGame_Coin)
	ldi  [hl], a		
	xor  a
	ldi  [hl], a		; Timer
	ldi  [hl], a		; Timer 2
	
	;--
	; Initial Y speed depends on the random value
	ld   a, [sRandom]	; YSpeed = -((sRandom % 8) + 3)
	and  a, $07			; +3 since "cpl" was done without an extra "inc a"
	add  $04
	cpl
	ldi  [hl], a
	;--
	
	ld   a, $FF			; Timer 4
	ldi  [hl], a
	xor  a
	ldi  [hl], a		; Timer 5
	ldi  [hl], a		; Timer 6
	ldi  [hl], a		; Timer 7
	ld   a, $01			; Flags
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_Coin)	; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_Coin)
	ld   [hl], a
.incSecTimer:
	; Handle the secondary time limit.
	ld   a, [sLvlClearOnDeath]	; SecTimer++
	inc  a
	ld   [sLvlClearOnDeath], a
	
	; This timer mostly exists to limit the amount of coins spawned.
	; Any time the game tries to spawn a coin, the timer will get incremented.
	; (though for the first $1E frames, it won't spawn them anyway -- leading to max $5A coins being spawned)
	; This way, both the amount of coins and the max bonus game time are limited.
	cp   a, $78					; Has it reached $78 yet?
	ret  c						; If not, return
	;--
.endGame:
	; Trigger the stage clear as soon as the player isn't jumping.
	; ("coincidentally", the jet dash doesn't count as jumping)
	ld   a, [sPlAction]
	cp   a, PL_ACT_JUMP		; Is the player jumping?
	ret  z					; If so, return
	ld   a, LVLCLEAR_BOSS	; Otherwise, trigger the alternate level clear effect
	ld   [sLvlSpecClear], a
	ret
; =============== ActS_SpawnCoinFromDash ===============
; Spawns a coin after defeating an enemy with a dash.
ActS_SpawnCoinFromDash:
	; Find the first empty slot we can use
	ld   hl, sAct
	ld   d, $07		; D = Total slots (coins are default actors; so all slots can be used)
	ld   e, $00		; E = Slot ID
.nextSlot:
	ld   a, [hl]	; Is this an empty slot?
	or   a
	jr   z, .found	; If so, use it
	
	inc  e
	dec  d			; Did we check all slots?
	ret  z			; If so, don't spawn the coin
	
	ld   a, l		; Move to the next slot
	add  sActSet_End-sActSet
	ld   l, a
	jr   .nextSlot
.found:
	mActS_SetOBJBank OBJLstPtrTable_Act_Coin
	
	ld   a, [sActSet]			; Activity status
	ldi  [hl], a
	
	ld   a, [sActSetX_Low]		; X = sActSetX
	ldi  [hl], a
	ld   a, [sActSetX_High]
	ldi  [hl], a
	
	ld   a, [sActSetY_Low]		; Y = sActSetY - $04
	sub  a, $04
	ldi  [hl], a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ldi  [hl], a
	
	ld   a, ACTCOLI_COIN		; Collision type
	ldi  [hl], a
	ld   a, -$0C				; Collision box - U size
	ldi  [hl], a
	ld   a, -$04				; Collision box - D size
	ldi  [hl], a
	ld   a, -$06				; Collision box - L size
	ldi  [hl], a
	ld   a, +$06				; Collision box - R size
	ldi  [hl], a
	ld   a, [sActSetRelY]		; Y Origin
	ldi  [hl], a
	ld   a, [sActSetRelX]		; X Origin
	ldi  [hl], a
	
	ld   a, LOW(OBJLstPtrTable_Act_Coin) ; OBJLstPtrTable
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_Coin)
	ldi  [hl], a
	
	; Make the coin go to the opposite side of the actor (read: going torwards the player)
	; Since the "interaction direction" uses the same RLUD bit order
	; and it works in reverse, we can straight up copy it over.
	ld   a, [sActSetRoutineId]	; Direction = sActSetRoutineId >> 4
	and  a, $F0					
	swap a						
	ldi  [hl], a
	
	xor  a						; OBJLstId (reset)
	ldi  [hl], a
	ld   a, ACT_COIN			; Actor ID
	ldi  [hl], a
	ld   a, [sActSetRoutineId]	; Routine ID
	ldi  [hl], a
	ld   a, LOW(SubCall_Act_Coin)		; Code ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_Coin)
	ldi  [hl], a				
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Ground timer
	
	ld   a, LOW(-$0A)			; Initial Y speed
	ldi  [hl], a
	ld   a, HIGH(-$0A)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer 5 - Not used
	ldi  [hl], a				; Timer 6 - Not used
	ldi  [hl], a				; Timer 7 - Not used
	
	ld   a, $01					; Flags
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_Coin)	; Shared table ptr
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_Coin)	; Shared table ptr
	ldi  [hl], a
	ret
	
; =============== ActS_Spawn10Coin ===============
; Spawns a 10 coin from an actor.
; This can happen when crushed by a pouncer or defeating crabs.
ActS_Spawn10Coin:
	; Find the first empty slot we can use
	ld   hl, sAct
	ld   d, $07		; D = Total slots (coins are default actors; so all slots can be used)
	ld   e, $00		; E = Slot ID
.nextSlot:
	ld   a, [hl]	; Is this an empty slot?
	or   a
	jr   z, .found	; If so, use it
	
	inc  e
	dec  d			; Did we check all slots?
	ret  z			; If so, don't spawn the coin
	
	ld   a, l		; Move to the next slot
	add  sActSet_End-sActSet
	ld   l, a
	jr   .nextSlot
.found:
	mActS_SetOBJBank OBJLstPtrTable_Act_10Coin
	ld   a, [sActSet]			; Activity status
	ldi  [hl], a
	
	ld   a, [sActSetX_Low]		; X = sActSetX
	ldi  [hl], a
	ld   a, [sActSetX_High]
	ldi  [hl], a
	
	ld   a, [sActSetY_Low]		; Y = sActSetY - $04
	sub  a, $04
	ldi  [hl], a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ldi  [hl], a
	
	ld   a, ACTCOLI_10COIN		; Collision type
	ldi  [hl], a
	ld   a, -$0C				; Collision box - U size
	ldi  [hl], a
	ld   a, -$04				; Collision box - D size
	ldi  [hl], a
	ld   a, -$06				; Collision box - L size
	ldi  [hl], a
	ld   a, +$06				; Collision box - R size
	ldi  [hl], a
	ld   a, [sActSetRelY]		; Y Origin
	ldi  [hl], a
	ld   a, [sActSetRelX]		; X Origin
	ldi  [hl], a
	
	ld   a, LOW(OBJLstPtrTable_Act_10Coin) ; OBJLstPtrTable
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_10Coin)
	ldi  [hl], a
	
	; Make the 10-coin move away from the player, unlike normal coins
	ld   a, [sActSetDir]		; Direction
	ldi  [hl], a
	
	xor  a						; OBJLstId (reset)
	ldi  [hl], a
	
	; This reuses the actor ID for normal coins.
	; Possibly to make it not count torwards the limit of thrown coins, which explicitly check for the proper ACT_10COIN
	ld   a, ACT_COIN			; Actor ID
	ldi  [hl], a
	ld   a, [sActSetRoutineId]	; Routine ID
	ldi  [hl], a
	ld   a, LOW(SubCall_Act_Coin)		; Code ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_Coin)
	ldi  [hl], a	
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Ground timer
	
	ld   a, LOW(-$0A)			; Initial Y speed
	ldi  [hl], a
	ld   a, HIGH(-$01)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer 5 - Not used
	ldi  [hl], a				; Timer 6 - Not used
	ldi  [hl], a				; Timer 7 - Not used
	
	ld   a, $01					; Flags
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_10Coin)	; OBJLst shared table ptr
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_10Coin)
	ldi  [hl], a
	ret
; =============== ActS_SpawnCoinFromBlock ===============
; Spawns a coin from an item box or as a random drop.
ActS_SpawnCoinFromBlock:
	; Find the first empty slot we can use
	ld   hl, sAct
	ld   d, $07		; D = Total slots (coins are default actors; so all slots can be used)
	ld   e, $00		; E = Slot ID
.nextSlot:
	ld   a, [hl]	; Is this an empty slot?
	or   a
	jr   z, .found	; If so, use it
	
	inc  e			
	dec  d			; Did we check all slots?
	ret  z			; If so, don't spawn the coin
	
	ld   a, l		; Move to the next slot
	add  $20
	ld   l, a
	jr   .nextSlot
.found:
	mActS_SetOBJBank OBJLstPtrTable_Act_Coin
	
	ld   a, $02					; Active actor
	ldi  [hl], a
	
	ld   a, [sExActOBJX_Low]	; X
	ldi  [hl], a
	ld   a, [sExActOBJX_High]
	ldi  [hl], a
	
	ld   a, [sExActOBJY_Low]	; Y
	ldi  [hl], a
	ld   a, [sExActOBJY_High]
	ldi  [hl], a				
	
	ld   a, ACTCOLI_COIN		; Collision type
	ldi  [hl], a				
	ld   a, -$0C				; Coli box U
	ldi  [hl], a
	ld   a, -$04				; Coli box D
	ldi  [hl], a
	ld   a, -$06				; Coli box L
	ldi  [hl], a
	ld   a, +$06				; Coli box R
	ldi  [hl], a
	ld   a, $00					; Rel Y (not used)
	ldi  [hl], a
	ld   a, $00					; Rel X (not used)
	ldi  [hl], a
	ld   a, LOW(OBJLstPtrTable_Act_Coin)		; OBJLst table ptr
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_Coin)		; OBJLst table ptr
	ldi  [hl], a
	
	; Pick the coin direction based on the player's direction.
	mPlFlagsToXDir
	
	ldi  [hl], a
	xor  a						; OBJLst Id
	ldi  [hl], a
	ld   a, ACT_COIN			; Actor ID
	ldi  [hl], a
	xor  a						; Routine ID
	ldi  [hl], a
	ld   a, LOW(SubCall_Act_Coin)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_Coin)
	ldi  [hl], a
	
	xor  a					
	ldi  [hl], a			; Timer
	ldi  [hl], a			; Ground timer
	
	;--
	; [BUG] MOSTLY A NOTE FOR ALLOWING BLOCK INSTABREAK.
	;       This code is in theory incorrect, but in practice it doesn't affect anything.
	;
	; This subroutine can be eventually called when Pl_JumpSubY and Pl_JumpAddY check for ground or ceiling collision.
	; The stack goes something along the lines of:
	; Pl_JumpAddY -> PlBGColi_DoGround (does DynJump to breakable block code) -> ActS_SpawnBlockBreak -> here 
	;
	; Pl_JumpAddY and Pl_JumpAddY expect the value of 'C' to never be changed, or at least to be restored when changed.
	; What C cointains is the amount of pixels to move the player.
	;
	; This coin spawn subroutine is a copy/paste from other code which doesn't need to deal with this,
	; and it ends up overwriting C with -$08 when setting the low byte of the coin's Y Speed
	; without restoring it in any way.
	;
	; If PlJumpAddY were to move the player down, it would use the broken -$08 value, leading to the player
	; being moved down by 120px instead (chances are, it will instakill the player).
	; Meanwhile, PlJumpSubY would move the player up by 120px instead, which is also bad.
	;
	; It's only by chance this bug doesn't affect anything in an unmodified game -- breakable blocks
	; are always treated as solid, and if we are spawning a coin we must have hit one.
	; As a result, the broken value doesn't get used.
	;
	; If you're treating fully destroyed breakable blocks as empty (to allow dashing through them uninterrupted),
	; then the broken value will be a problem.
	; To fix this, avoid using "ld   bc, -$08" to set the speed:
	;
	; ld   a, LOW(-$08)				; Y Speed (Low byte)
	; ldi  [hl], a			
	; ld   a, HIGH(-$08)			; Y Speed (High byte)
	; ldi  [hl], a	
	
	ld   bc, -$08
	ld   a, c				; Y Speed (Low byte)
	ldi  [hl], a			
	ld   a, b				; Y Speed (High byte)
	ldi  [hl], a
	;--
	
	xor  a
	ldi  [hl], a			; Timer 5 - Not used
	ldi  [hl], a			; Timer 6 - Not used
	ldi  [hl], a			; Timer 7 - Not used
	ld   a, $01				; Flags
	ldi  [hl], a			
	ld   a, LOW(sActDummyBlock2)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock2)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, LOW(OBJLstSharedPtrTable_Act_Coin)	; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_Coin)	; OBJLst shared table
	ldi  [hl], a
	ret
; =============== OBJLstSharedPtrTable_Act_Coin ===============
; [TCRF] Not used, and no reason to use it.
OBJLstSharedPtrTable_Act_Coin:
	dw OBJLstPtrTable_Act_Coin;X
	dw OBJLstPtrTable_Act_Coin;X
	dw OBJLstPtrTable_Act_Coin;X
	dw OBJLstPtrTable_Act_Coin;X
	dw OBJLstPtrTable_Act_Coin;X
	dw OBJLstPtrTable_Act_Coin;X
	dw OBJLstPtrTable_Act_Coin;X
	dw OBJLstPtrTable_Act_Coin;X

; =============== Act_Coin ===============
; Loop code for coins and 10-coins.
Act_Coin:
	ld   a, [sActSetTimer]		; sActSetTimer++
	inc  a
	ld   [sActSetTimer], a
	
	; If the coin goes off-screen, despawn it
	call ActS_CheckOffScreen		; Update offscreen status
	ld   a, [sActSet]
	cp   a, $02						; Is it visible and active? (>= $02)
	jr   nc, Act_Coin_ChkAnimSpeed	; If so, jump
	xor  a							; Otherwise free the slot
	ld   [sActSet], a
	; No ret here?
	
Act_Coin_ChkAnimSpeed:
	;
	; Animate the coin every certain amount of frames.
	; This amount changes if the coin is in water.
	;
	
	; If the coin is in water, fall and animate slower
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a						; Is it in water?
	jr   nz, Act_Coin_ChkAnimSpeed_Ground	; If not, jump
	
.inWater:
	; Move normally every other execution frame.
	ld   a, [sActSetTimer]
	bit  0, a								; sTimer % 2 == 0?
	jr   z, Act_Coin_ChkAnimSpeed_Ground	; If so, move the coin
	
	; Otherwise, just animate it every $10 frames.
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .end
	; Increase the anim frame
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.end:
	ret

Act_Coin_ChkAnimSpeed_Ground:
	; Depending on how much it stayed on the ground, animate the coin at gradualy slower speed.
	; Given the timer starting at $00 and gradually increasing over time:
	ld   a, [sActCoinGroundTimer]
	cp   a, $03					; < $03?
	jr   c, Act_Coin_Anim2		; If so, animate every other frame
	cp   a, $14					; < $14?
	jr   c, Act_Coin_Anim4		; If so, animate every 4 frames
	; Otherwise, animate every 8 frames
Act_Coin_Anim8:
	call ActS_IncOBJLstIdEvery8
	jr   Act_Coin_MoveHorz
	
Act_Coin_Anim4:
	; Every 4 frames increase the anim frame
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .noInc
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.noInc:
	jr   Act_Coin_MoveHorz
	
Act_Coin_Anim2:
	; Every other frame increase the anim frame
	ld   a, [sTimer]
	and  a, $01
	jr   nz, .noInc
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.noInc:
;--

Act_Coin_MoveHorz:
	; Move the coin horizontally every 4 execution frames.
	; At least one of those should be set.
	ld   a, [sActSetTimer]
	and  a, $03					; sActSetTimer & 4 == 0?
	jr   nz, Act_Coin_MoveVert	; If not, skip this
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Coin facing right?
	call nz, Act_Coin_MoveRight	; If so, move right
	ld   a, [sActSetDir]
	bit  DIRB_L, a				; Coin facing left?
	call nz, Act_Coin_MoveLeft  ; Move left
	
Act_Coin_MoveVert:
	;
	; Perform the vertical bounce effect for the coin.
	;
	
	; First move the coin down, then check for collision.
	
	; NOTE: When doing this for negative numbers, the upper byte becomes positive.
	;       In practice it doesn't break only because of the level height used.
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed / 4 for a slower speed
	ld   c, a							
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	sra  b								; >> 1			
	rr   c								; with carry into C
	sra  b
	rr   c
	call ActS_MoveDown					; Move down by that
	
	; Check for solid collision either above or below
	ld   a, [sActSetYSpeed_High]	
	bit  7, a							; Did the coin move up? (MSB set)
	jr   z, .chkDown					; If not, jump
.moveD:
	; If there isn't a solid block above, gradually increase the downwards speed
	; from negative back to positive
	call ActColi_GetBlockId_Top
	mSubCall ActBGColi_IsSolid
	or   a
	jr   z, .speedInc
	
	; If there is, immediately start the descent
	xor  a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ret
.speedInc:
	; sActSetYSpeed++;
	; [TCRF] This also sets the new value to BC, but it isn't used.
	;		 It was probably derived from the code below, which does use it.
	ld   a, [sActSetYSpeed_Low]
	add  $01							; sActSetYSpeed_Low++
	ld   c, a							; Save to C
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]	; sActSetYSpeed_High for carry
	adc  a, $00
	ld   b, a							; Save to B
	ld   [sActSetYSpeed_High], a
	ret
.chkDown:
	; If there isn't a solid block below, increase the downwards speed
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop_Coin
	or   a
	jr   z, .speedInc
	
	;--
	; Otherwise, we've reached the ground. The coin should bounce upwards now at a slightly lower speed.
	; Calculate the upwards speed, relative to the current one.
	; 
	; NewSpeed = - MAX(sActSetYSpeed - $0C, 0)
	;
	; This way, every time the coin touches the ground it loses absolute speed,
	; and eventually it only moves horizontally.
	
	; Increase the ground timer, which only activates when it stops bouncing
	ld   a, [sActCoinGroundTimer]			; sActCoinGroundTimer++
	inc  a
	ld   [sActCoinGroundTimer], a
	
	; Subtract $0C to the current speed
	;
	; BC = sActSetYSpeed - $0C 
	;
	; Lower byte
	ld   a, [sActSetYSpeed_Low]		
	sub  a, $0C
	ld   c, a
	ld   [sActSetYSpeed_Low], a ; (useless)
	; Upper byte (account for carry)
	ld   a, [sActSetYSpeed_High]
	sbc  a, $00
	ld   b, a
	ld   [sActSetYSpeed_High], a ; (useless)
	
	;##
	
	; If the speed is now negative (we underflowed), it means it isn't high enough to perform another bounce.
	; So we reset it back to $00.
	jr   c, .noBounce	; went from $00 to $FF? If so, jump
	
	;##
	
	; Otherwise, we still have enough speed for another bounce up.
	; To make the coin move up we need a negative speed, so we convert the number to negative, then save it back.
	; Basically do the usual cpl with decrement by 1 for the offset,
	; except we get to do it on a 16bit number here.
	
	dec  bc							; Account for cpl
	; Invert lower byte and save
	ld   a, c
	cpl
	ld   [sActSetYSpeed_Low], a
	; Invert upper byte and save
	ld   a, b
	cpl
	ld   [sActSetYSpeed_High], a
	
	ld   a, SFX1_0B
	ld   [sSFX1Set], a
	ret
.noBounce:
	; Reset the speed back to $00
	xor  a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	ld   a, [sActCoinGroundTimer]
	cp   a, $78					; Did we stay on the ground for more than $77 frames?
	ret  c						; If so, return
	xor  a						; Otherwise, despawn the coin
	ld   [sActSet], a
	ret
	
; =============== Act_CoinGame_Coin ===============
; Loop code for a coin or 10-coin spawned by the random coin spanwer (ActS_CoinGame).
; The reason this exists instead of just reusing Act_Coin is to save on processing time,
; as the code for this coin is a cut down version of Act_Coin that gets rid
; of unnecessary code paths, like the underwater code (of which there's none in boss rooms).
;
; This helps in reducing lag (though it can still happen), especially since the coin
; spawner continuously tries to fill all actor slots.
;
; See also: Act_Coin
Act_CoinGame_Coin:;I
	ld   a, [sActSetTimer]		; sActSetTimer++
	inc  a
	ld   [sActSetTimer], a
	
	; If the coin goes off-screen, despawn it
	call ActS_CheckOffScreen	; Update offscreen status
	ld   a, [sActSet]			
	cp   a, $02					; Is it visible and active? (>= $02)
	jr   nc, Act_CoinGame_Coin_ChkAnimSpeed	; If so, jump
	xor  a						; Otherwise free the slot
	ld   [sActSet], a
	
Act_CoinGame_Coin_ChkAnimSpeed:
	;
	; Animate the coin every certain amount of frames.
	; This here does not perform collision detection for a water block,
	; so the normal fall speed is used.
	;
	
	; Depending on how much it stayed on the ground, animate the coin at gradualy slower speed.
	; Given the timer starting at $00 and gradually increasing over time:
	ld   a, [sActCoinGroundTimer]
	cp   a, $03						; < $03?
	jr   c, Act_CoinGame_Coin_Anim2	; If so, animate every other frame
	cp   a, $14						; < $14?
	jr   c, Act_CoinGame_Coin_Anim4	; If so, animate every 4 frames
	
	; Otherwise, animate every 8 frames
Act_CoinGame_Coin_Anim8:
	call ActS_IncOBJLstIdEvery8
	jr   Act_CoinGame_Coin_MoveHorz
	
Act_CoinGame_Coin_Anim4:
	; Every 4 frames increase the anim frame
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .noInc
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.noInc:
	jr   Act_CoinGame_Coin_MoveHorz
	
Act_CoinGame_Coin_Anim2:
	; Every other frame increase the anim frame
	ld   a, [sTimer]
	and  a, $01
	jr   nz, .noInc
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.noInc:
;--

Act_CoinGame_Coin_MoveHorz:
	; Move the coin horizontally every *other* execution frame.
	; At least one of those should be set.
	
	; Compared to normal coins, these move at double speed.
	ld   a, [sActSetTimer]
	and  a, $01								; sActSetTimer & 2 == 0?
	jr   nz, Act_CoinGame_Coin_MoveVert		; If not, skip this
	ld   a, [sActSetDir]
	bit  DIRB_R, a							; Coin facing right?
	call nz, Act_CoinGame_Coin_MoveRight	; If so, move right
	ld   a, [sActSetDir]
	bit  DIRB_L, a							; Coin facing left?
	call nz, Act_CoinGame_Coin_MoveLeft		; If so, move left
	
Act_CoinGame_Coin_MoveVert:
	;
	; Perform the vertical bounce effect for the coin.
	;
	
	; First move the coin down, then check for collision.
	
	; NOTE: When doing this for negative numbers, the upper byte becomes positive.
	;       In practice it doesn't break only because of the level height used.
	
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed / 4 for a slower speed
	ld   c, a							
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	sra  b								; >> 1			
	rr   c								; with carry into C
	sra  b
	rr   c
	call ActS_MoveDown					; Move down by that
	
	; Check for solid collision either above or below
	ld   a, [sActSetYSpeed_High]
	bit  7, a							; Did the coin move up? (MSB set)
	jr   z, .chkDown					; If not, jump
.speedInc:
	; *Ceiling check (.moveD) omitted from this*
	
	; Otherwise, increase the fall speed
	ld   a, [sActSetYSpeed_Low]
	add  $01							; sActSetYSpeed++;
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00
	ld   [sActSetYSpeed_High], a
	ret
.chkDown:
	; If there isn't a solid block below, increase the downwards speed
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop_Coin
	or   a
	jr   z, .speedInc
	
	;--
	; Otherwise, we've reached the ground. The coin should bounce upwards now at a slightly lower speed.
	; Calculate the upwards speed, relative to the current one.
	; 
	; NewSpeed = - MAX(sActSetYSpeed - $0C, 0)
	;
	; This way, every time the coin touches the ground it loses absolute speed,
	; and eventually it only moves horizontally.
	
	; Increase the ground timer, which only activates when it stops bouncing
	ld   a, [sActCoinGroundTimer]				; sActCoinGroundTimer++
	inc  a
	ld   [sActCoinGroundTimer], a
	
	; Subtract $0C to the current speed
	;
	; BC = sActSetYSpeed - $0C 
	;
	; Lower byte
	ld   a, [sActSetYSpeed_Low]
	sub  a, $0C
	ld   c, a
	ld   [sActSetYSpeed_Low], a ; (useless -- done later)
	; Upper byte (account for carry)
	ld   a, [sActSetYSpeed_High]
	sbc  a, $00
	ld   b, a
	ld   [sActSetYSpeed_High], a ; (useless -- done later)
	
	;##
	
	; If the speed is now negative (we underflowed), it means it isn't high enough to perform another bounce.
	; So we reset it back to $00.
	jr   c, .noBounce		; went from $00 to $FF? If so, jump
	
	;##
	
	; Otherwise, we still have enough speed for another bounce up.
	; To make the coin move up we need a negative speed, so we convert the number to negative, then save it back.
	; Basically do the usual cpl with decrement by 1 for the offset,
	; except we get to do it on a 16bit number here.
	
	dec  bc								; Account for cpl
	; Invert lower byte and save
	ld   a, c
	cpl
	ld   [sActSetYSpeed_Low], a
	; Invert upper byte and save
	ld   a, b
	cpl
	ld   [sActSetYSpeed_High], a
	
	ld   a, SFX1_0B
	ld   [sSFX1Set], a
	ret
.noBounce:
	; Reset the speed back to $00
	xor  a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ld   a, [sActCoinGroundTimer]
	cp   a, $64						; Did we stay on the ground for more than $63 frames? (less time than the normal coin)
	ret  c							; If so, return
	xor  a							; Otherwise, despawn the coin
	ld   [sActSet], a
	ret
	
; =============== Act_CoinGame_Coin_MoveRight ===============
; Used to move the current actor to the right.
; Internally used by the coin actor spawned by the coin game.
Act_CoinGame_Coin_MoveRight:
	; Compared to Act_Coin_MoveRight, this omits the collision detection check.
	; Since in practice there aren't any solid walls in boss rooms, we can save time.
	ld   bc, +$01
	call ActS_MoveRight
	ret
; =============== Act_CoinGame_Coin_MoveLeft ===============
; Used to move the current actor to the left.
; Internally used by the coin actor spawned by the coin game.
Act_CoinGame_Coin_MoveLeft:
	; Same as above
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
; =============== OBJLstPtrTableSet_Act_Defaults ===============
; This table defines the OBJLstPtrTable used for the default actors.
OBJLstPtrTableSet_Act_Defaults:
	dw OBJLstPtrTable_Act_GarlicPot
	dw OBJLstPtrTable_Act_JetPot
	dw OBJLstPtrTable_Act_DragonPot
	dw OBJLstPtrTable_Act_Key
	dw OBJLstPtrTable_Act_Heart
	dw OBJLstPtrTable_Act_Star;X
	dw OBJLstPtrTable_Act_Coin;X
	dw OBJLstPtrTable_Act_10Coin
	dw OBJLstPtrTable_Act_BullPot
	
OBJLstPtrTable_Act_GarlicPot:
	dw OBJLst_Act_GarlicPot0
	dw OBJLst_Act_GarlicPot1
	dw OBJLst_Act_GarlicPot0
	dw OBJLst_Act_GarlicPot1
	dw $0000
	dw $0000;X
	dw $0000;X
	dw $0000;X
OBJLstPtrTable_Act_DragonPot:
	dw OBJLst_Act_DragonPot0
	dw OBJLst_Act_DragonPot1
	dw OBJLst_Act_DragonPot0
	dw OBJLst_Act_DragonPot1
	dw $0000
	dw $0000;X
	dw $0000;X
	dw $0000;X
OBJLstPtrTable_Act_JetPot:
	dw OBJLst_Act_JetPot0
	dw OBJLst_Act_JetPot1
	dw OBJLst_Act_JetPot0
	dw OBJLst_Act_JetPot1
	dw $0000
	dw $0000;X
	dw $0000;X
	dw $0000;X
; [TCRF] The key has two frames like other items, but they are identical.
OBJLstPtrTable_Act_Key:
	dw OBJLst_Act_Key0
	dw OBJLst_Act_Key1
	dw OBJLst_Act_Key0
	dw OBJLst_Act_Key1
	dw $0000
	dw $0000;X
	dw $0000;X
	dw $0000;X
OBJLstPtrTable_Act_Heart:
	dw OBJLst_Act_Heart0
	dw OBJLst_Act_Heart1
	dw OBJLst_Act_Heart0
	dw OBJLst_Act_Heart1
	dw $0000
	dw $0000;X
	dw $0000;X
	dw $0000;X
OBJLstPtrTable_Act_Star:
	dw OBJLst_Act_Star0
	dw OBJLst_Act_Star1
	dw OBJLst_Act_Star0
	dw OBJLst_Act_Star1
	dw $0000
	dw $0000;X
	dw $0000;X
	dw $0000;X
OBJLstPtrTable_Act_Coin:
	dw OBJLst_Act_Coin0
	dw OBJLst_Act_Coin1
	dw OBJLst_Act_Coin2
	dw OBJLst_Act_Coin1
	dw $0000
	dw $0000
	dw $0000
	dw $0000;X
OBJLstPtrTable_Act_10Coin:
	dw OBJLst_Act_10Coin0
	dw OBJLst_Act_10Coin1
	dw OBJLst_Act_10Coin2
	dw OBJLst_Act_10Coin1
	dw $0000
	dw $0000
	dw $0000;X
	dw $0000;X
OBJLstPtrTable_Act_10CoinHeld:
	dw OBJLst_Act_10Coin0
	dw OBJLst_Act_10Coin0
	dw OBJLst_Act_10Coin0
	dw OBJLst_Act_10Coin0
	dw $0000
	dw $0000
	dw $0000;X
	dw $0000;X
OBJLstPtrTable_Act_BullPot:
	dw OBJLst_Act_BullPot0
	dw OBJLst_Act_BullPot1
	dw OBJLst_Act_BullPot0
	dw OBJLst_Act_BullPot1
	dw $0000
	dw $0000;X
	dw $0000;X
	dw $0000;X
	
; [TCRF] Unused blank sprite map list, only used by unreferenced spawn code.
;        May have been used for invisible actors. 
OBJLstPtrTable_Act_Unused_Blank:
	dw OBJLst_Act_Unused_Blank;X
	dw $0000;X
	dw $0000;X
	dw $0000;X
	dw $0000;X


OBJLstPtrTable_Act_StunStar: 	
	dw OBJLst_Act_StunStar0
	dw OBJLst_Act_StunStar1
	dw OBJLst_Act_StunStar2
	dw OBJLst_Act_StunStar3
	dw OBJLst_Act_StunStar4
	dw OBJLst_Act_StunStar5
	dw OBJLst_Act_StunStar6
	dw OBJLst_Act_StunStar8
	dw $0000
	dw $0000;X
	dw $0000;X
	dw $0000;X

OBJLstPtrTable_Act_StarKill:
	dw OBJLst_Act_StarKill0
	dw OBJLst_Act_StarKill1
	dw OBJLst_Act_StarKill2
	dw OBJLst_Act_StarKill3
	dw OBJLst_Act_StarKill_Blank
	dw OBJLst_Act_StarKill_Blank
	dw $0000;X
	dw $0000;X
	dw $0000;X
	dw $0000;X

OBJLst_Act_StarKill0: INCBIN "data/objlst/actor/starkill0.bin"
OBJLst_Act_StarKill1: INCBIN "data/objlst/actor/starkill1.bin"
OBJLst_Act_StarKill2: INCBIN "data/objlst/actor/starkill2.bin"
OBJLst_Act_StarKill3: INCBIN "data/objlst/actor/starkill3.bin"
OBJLst_Act_Coin0: INCBIN "data/objlst/actor/coin0.bin"
OBJLst_Act_Coin1: INCBIN "data/objlst/actor/coin1.bin"
OBJLst_Act_Coin2: INCBIN "data/objlst/actor/coin2.bin"
OBJLst_Act_10Coin0: INCBIN "data/objlst/actor/10coin0.bin"
OBJLst_Act_10Coin1: INCBIN "data/objlst/actor/10coin1.bin"
OBJLst_Act_10Coin2: INCBIN "data/objlst/actor/10coin2.bin"
OBJLst_Act_GarlicPot0: INCBIN "data/objlst/actor/garlicpot0.bin"
OBJLst_Act_GarlicPot1: INCBIN "data/objlst/actor/garlicpot1.bin"
OBJLst_Act_DragonPot0: INCBIN "data/objlst/actor/dragonpot0.bin"
OBJLst_Act_DragonPot1: INCBIN "data/objlst/actor/dragonpot1.bin"
OBJLst_Act_JetPot0: INCBIN "data/objlst/actor/jetpot0.bin"
OBJLst_Act_JetPot1: INCBIN "data/objlst/actor/jetpot1.bin"
OBJLst_Act_BullPot0: INCBIN "data/objlst/actor/bullpot0.bin"
OBJLst_Act_BullPot1: INCBIN "data/objlst/actor/bullpot1.bin"
OBJLst_Act_Key0: INCBIN "data/objlst/actor/key0.bin"
OBJLst_Act_Key1: INCBIN "data/objlst/actor/key1.bin" ; [TCRF] Same as OBJLst_Act_Key0
OBJLst_Act_Heart0: INCBIN "data/objlst/actor/heart0.bin"
OBJLst_Act_Heart1: INCBIN "data/objlst/actor/heart1.bin"
OBJLst_Act_Star0: INCBIN "data/objlst/actor/star0.bin"
OBJLst_Act_Star1: INCBIN "data/objlst/actor/star1.bin"
OBJLst_Act_Unused_Blank: INCBIN "data/objlst/actor/unused_blank.bin"
OBJLst_Act_StarKill_Blank: INCBIN "data/objlst/actor/starkill_blank.bin"

; =============== ActInit_Helmut ===============
ActInit_Helmut:
	; Setup collision box
	ld   a, -$14
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$04
	ld   [sActSetColiBoxL], a
	ld   a, +$04
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Helmut
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_Helmut
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Helmut
	call ActS_SetOBJLstSharedTablePtr
	ret
	
OBJLstPtrTable_ActInit_Helmut:
	dw OBJLst_Act_Helmut_MoveD
	dw $0000;X

; =============== ActInit_Helmut ===============
Act_Helmut:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Helmut_Main
	dw SubCall_ActS_OnPlColiH;X
	dw SubCall_ActS_OnPlColiTop;X
	dw SubCall_ActS_StartStarKill
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartDashKill
	dw Act_Helmut_Main;X
	dw Act_Helmut_Main
	dw SubCall_ActS_StartJumpDeadSameColi
; =============== Act_Helmut_Main ===============
Act_Helmut_Main:
	mActColiMask ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Timer++
	ld   a, [sActSetTimer]
	inc  a
	ld   [sActSetTimer], a
	
	; Is it moving upwards or downwards?
	ld   a, [sActHelmutVDir]
	bit  0, a						; Moving down?
	jr   nz, .moveU					; If not, jump
.moveD:
	; Move down at a constant 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveDown
	
	; Set OBJLst ptr
	ld   a, LOW(OBJLstPtrTable_Act_Helmut_MoveD)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Helmut_MoveD)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; When the ground is reached, start moving upwards
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a
	jr   nz, .invertDir
	ret
.moveU:
	; When there isn't an empty solid block above, play a SFX
	; and start moving down.
	call ActColi_GetBlockId_Top
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a
	jr   nz, .topReached
	
	;--
	; Upwards movement is based off a table of 16bit entries indexed by the timer.
	; This is done to make the movement seem less "cheap".
	
	ld   a, [sActSetTimer]
	and  a, $0E				; DE = sActSetTimer & $0E
	ld   d, $00				; $0E to filter away bit 0 (as these are word values)
	ld   e, a
	ld   hl, Act_Helmut_MoveUOffTbl	; HL = Y movement table
	add  hl, de				; Offset it
	; Save the indexed value to BC
	ld   c, [hl]
	inc  hl
	ld   b, [hl]
	call ActS_MoveDown		; And move down by that
	;--
	
	; Use different OBJLst if we moved up or down
	ld   a, LOW(OBJLstPtrTable_Act_Helmut_MoveU)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Helmut_MoveU)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	bit  7, b				; MSB set (moving up)?
	ret  nz					; If so, return
	ld   a, LOW(OBJLstPtrTable_Act_Helmut_MoveD)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Helmut_MoveD)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
.topReached:
	ld   a, SFX4_11
	ld   [sSFX4Set], a
.invertDir:
	; Switch between vertical directions
	ld   a, [sActHelmutVDir]
	xor  $01
	ld   [sActHelmutVDir], a
	ret
; =============== Act_Helmut_MoveUOffTbl ===============
; Movement table used when the actor is moving upwards.
; Values in this table will be added to the actor's current Y pos.
Act_Helmut_MoveUOffTbl:
	dw $FFFD
	dw $FFFE
	dw $FFFF
	dw $FFFF
	dw $FFFF
	dw $FFFF
	dw $0000
	dw $0001
.end:
OBJLstPtrTable_Act_Helmut_Idle:
	dw OBJLst_Act_Helmut_MoveD
	dw OBJLst_Act_Helmut_MoveU
	dw $0000
OBJLstPtrTable_Act_Helmut_MoveU:
	dw OBJLst_Act_Helmut_MoveU
	dw $0000;X
OBJLstPtrTable_Act_Helmut_MoveD:
	dw OBJLst_Act_Helmut_MoveD
	dw $0000;X
OBJLstSharedPtrTable_Act_Helmut:
	dw OBJLstPtrTable_Act_Helmut_Idle;X
	dw OBJLstPtrTable_Act_Helmut_Idle;X
	dw OBJLstPtrTable_Act_Helmut_Idle;X
	dw OBJLstPtrTable_Act_Helmut_Idle;X
	dw OBJLstPtrTable_Act_Helmut_Idle
	dw OBJLstPtrTable_Act_Helmut_Idle
	dw OBJLstPtrTable_Act_Helmut_Idle;X
	dw OBJLstPtrTable_Act_Helmut_Idle;X
	
OBJLst_Act_Helmut_MoveD: INCBIN "data/objlst/actor/helmut_moved.bin"
OBJLst_Act_Helmut_MoveU: INCBIN "data/objlst/actor/helmut_moveu.bin"
; [TCRF] Unused mapping for the stun frame. There's only one of them mapped though.
OBJLst_Act_Helmut_Unused_Stun: INCBIN "data/objlst/actor/helmut_unused_stun.bin"
GFX_Act_Helmut: INCBIN "data/gfx/actor/helmut.bin"
; =============== ActInit_Goom ===============
ActInit_Goom:
	; Setup collision box
	ld   a, -$0C
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$06
	ld   [sActSetColiBoxL], a
	ld   a, +$06
	ld   [sActSetColiBoxR], a
	; Setup main code
	ld   bc, SubCall_Act_Goom
	call ActS_SetCodePtr
	;--
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_Goom
	call ActS_SetOBJLstPtr
	pop  bc
	;--
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Goom
	call ActS_SetOBJLstSharedTablePtr
	
	; Set the collision type, and save it as default.
	; This actor is completely harmless
	mActColiMask ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	ret
	
OBJLstPtrTable_ActInit_Goom:
	dw OBJLst_Act_Goom_WalkL0
	dw $0000

; =============== Act_Goom ===============
Act_Goom:
	;--
	; If the actor gets stuck inside a solid block, kill it automatically (jump anim).
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolid
	or   a ; COLI_EMPTY			; Are we inside an empty block?
	jp   nz, SubCall_ActS_StartJumpDead			; If not, jump
	;--
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Goom_Main
	dw SubCall_ActS_OnPlColiH
	dw SubCall_ActS_OnPlColiTop
	dw SubCall_ActS_StartStarKill
	dw SubCall_ActS_OnPlColiBelow
	dw SubCall_ActS_StartDashKill
	dw Act_Goom_Main;X
	dw SubCall_ActS_StartSwitchDir;X
	dw SubCall_ActS_StartJumpDeadSameColi
; =============== Act_Goom_Main ===============
; Main code for the goom actor.
Act_Goom_Main:
	; If the screen is shaking, stun the actor
	ld   a, [sScreenShakeTimer]
	or   a
	jp   nz, SubCall_ActS_StartGroundPoundStun
	
	; Handle collision on the left
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSpikeBlock
	or   a
	jp   nz, SubCall_ActS_StartStarKill
	
	; Timer++
	ld   a, [sActSetTimer]
	inc  a
	ld   [sActSetTimer], a
	
	;--
	; 
	; Handle vertical drops
	;
	
	; If it's on the ground, skip this and set a vertical speed of $00
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, .noDrop
.drop:
	ld   a, [sActSetYSpeed_Low]	; BC = sActSetYSpeed_Low
	ld   c, a							
	ld   b, $00
	call ActS_MoveDown				; Move down by that
	
	; Every 4 frames increase the downwards speed
	ld   a, [sActSetTimer]
	and  a, $03
	jr   nz, .chkWalkDelay
	ld   a, [sActSetYSpeed_Low]
	inc  a
	ld   [sActSetYSpeed_Low], a
	jr   .chkWalkDelay
.noDrop:
	xor  a
	ld   [sActSetYSpeed_Low], a
	;--
.chkWalkDelay:
	; sActGoomTurnDelay is used to set a delay before moving again.
	; This is most commonly used when an actor stops right before the end of a platform.
	ld   a, [sActGoomTurnDelay]
	or   a						; Is a delay active?
	jr   z, Act_Goom_Move		; If not, jump
	dec  a						; Otherwise, decrement the delay and wait
	ld   [sActGoomTurnDelay], a
	ret
; =============== Act_Goom_Move ===============
; Attempts to move the actor.
Act_Goom_Move:
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	; Moving left or right?
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Are we facing right?
	jr   nz, .moveR				; If so, move right
.moveL:
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolid
	or   a							; Is there a solid block in front?
	jr   nz, Act_Goom_SwitchMove	; If so, jump
	
	call ActColi_GetBlockId_BottomL
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is there solid ground in front?
	jr   z, Act_Goom_SwitchMove		; If not, jump
	
	;--
	; If we got here, we can move left at 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  z
	
	ld   bc, -$01		
	call ActS_MoveRight
	
	ld   a, LOW(OBJLstPtrTable_Act_Goom_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Goom_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	;--
	ret
.moveR:
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a							; Is there a solid block in front?
	jr   nz, Act_Goom_SwitchMove	; If so, jump
	
	call ActColi_GetBlockId_BottomR
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is there solid ground in front?
	jr   z, Act_Goom_SwitchMove		; If not, jump
	
	;--
	; If we got here, we can move right at 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  z
	
	ld   bc, +$01
	call ActS_MoveRight
	
	ld   a, LOW(OBJLstPtrTable_Act_Goom_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Goom_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
; =============== Act_Goom_SwitchMove ===============
; Starts moving the actor in the opposite direction.
Act_Goom_SwitchMove:
	; Reset anim frame to standing frame
	xor  a
	ld   [sActSetOBJLstId], a
	
	; Set a delay of $1E frames before moving again
	ld   a, $1E
	ld   [sActGoomTurnDelay], a
	
	; Invert the moving direction
	ld   a, [sActSetDir]
	xor  $03
	ld   [sActSetDir], a
	
	; Make the actor freeze in the same direction we were going before,
	; even though we technically just switched direction.
	; So if the actor was moving right, it continues facing right until the delay ends.
	bit  DIRB_R, a					; Will we be moving right?
	jr   z, .toL					; If not, use the right frame
.toR:
	ld   a, LOW(OBJLstPtrTable_Act_Goom_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Goom_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
.toL:
	ld   a, LOW(OBJLstPtrTable_Act_Goom_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Goom_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
; =============== OBJLstSharedPtrTable_Act_Goom ===============
; Global OBJLst table for Act_Goom
OBJLstSharedPtrTable_Act_Goom: 
	; Standard tables
	
	; [TCRF] OBJLstPtrTable_Act_Goom_Unused_* is a pair of unused 1-frame animations.
	;		 It uses one frame from the stun animation, except it's not displayed upside down.
	;		 The OBJLst data is unique, since X and Y flipping isn't supported.
	dw OBJLstPtrTable_Act_Goom_Unused_StunAltL;X	; [TCRF] Unused copy of one frame of the stun
	dw OBJLstPtrTable_Act_Goom_Unused_StunAltR;X
	dw OBJLstPtrTable_Act_Goom_RestoreL
	dw OBJLstPtrTable_Act_Goom_RestoreR
	dw OBJLstPtrTable_Act_Goom_StunL
	dw OBJLstPtrTable_Act_Goom_StunR
	dw OBJLstPtrTable_Act_Goom_WalkL;X	; [TCRF] Custom entries, but they are directly used
	dw OBJLstPtrTable_Act_Goom_WalkR;X

OBJLstPtrTable_Act_Goom_WalkL:
	dw OBJLst_Act_Goom_WalkL0
	dw OBJLst_Act_Goom_WalkL1
	dw OBJLst_Act_Goom_WalkL0
	dw OBJLst_Act_Goom_WalkL2
	dw $0000
OBJLstPtrTable_Act_Goom_WalkR:
	dw OBJLst_Act_Goom_WalkR0
	dw OBJLst_Act_Goom_WalkR1
	dw OBJLst_Act_Goom_WalkR0
	dw OBJLst_Act_Goom_WalkR2
	dw $0000
OBJLstPtrTable_Act_Goom_StunL:
	dw OBJLst_Act_Goom_StunL0
	dw OBJLst_Act_Goom_StunL1
	dw OBJLst_Act_Goom_StunL0
	dw OBJLst_Act_Goom_StunL2
	dw $0000
OBJLstPtrTable_Act_Goom_StunR:
	dw OBJLst_Act_Goom_StunR0
	dw OBJLst_Act_Goom_StunR1
	dw OBJLst_Act_Goom_StunR0
	dw OBJLst_Act_Goom_StunR2
	dw $0000
OBJLstPtrTable_Act_Goom_Unused_StunAltL:
	dw OBJLst_Act_Goom_Unused_StunAltL;X
	dw $0000;X
OBJLstPtrTable_Act_Goom_Unused_StunAltR:
	dw OBJLst_Act_Goom_Unused_StunAltR;X
	dw $0000;X
OBJLstPtrTable_Act_Goom_RestoreL:
	dw OBJLst_Act_Goom_StunL0
	dw OBJLst_Act_Goom_WalkL1
	dw OBJLst_Act_Goom_WalkL1
	dw $0000;X
OBJLstPtrTable_Act_Goom_RestoreR:
	dw OBJLst_Act_Goom_StunR0
	dw OBJLst_Act_Goom_WalkR1
	dw OBJLst_Act_Goom_WalkR1
	dw $0000;X

; [TCRF] OBJLst_Act_Goom_Unused_Spit* is for spitting out the projectile.
;        There's a proper sprite mapping for this.
OBJLst_Act_Goom_WalkL0: INCBIN "data/objlst/actor/goom_walkl0.bin"
OBJLst_Act_Goom_WalkL1: INCBIN "data/objlst/actor/goom_walkl1.bin"
OBJLst_Act_Goom_WalkL2: INCBIN "data/objlst/actor/goom_walkl2.bin"
OBJLst_Act_Goom_Unused_SpitL: INCBIN "data/objlst/actor/goom_unused_spitl.bin"
OBJLst_Act_Goom_StunL0: INCBIN "data/objlst/actor/goom_stunl0.bin"
OBJLst_Act_Goom_StunL1: INCBIN "data/objlst/actor/goom_stunl1.bin"
OBJLst_Act_Goom_StunL2: INCBIN "data/objlst/actor/goom_stunl2.bin"
OBJLst_Act_Goom_Unused_StunAltL: INCBIN "data/objlst/actor/goom_unused_stunaltl.bin"
OBJLst_Act_Goom_WalkR0: INCBIN "data/objlst/actor/goom_walkr0.bin"
OBJLst_Act_Goom_WalkR1: INCBIN "data/objlst/actor/goom_walkr1.bin"
OBJLst_Act_Goom_WalkR2: INCBIN "data/objlst/actor/goom_walkr2.bin"
OBJLst_Act_Goom_Unused_SpitR: INCBIN "data/objlst/actor/goom_unused_spitr.bin"
OBJLst_Act_Goom_StunR0: INCBIN "data/objlst/actor/goom_stunr0.bin"
OBJLst_Act_Goom_StunR1: INCBIN "data/objlst/actor/goom_stunr1.bin"
OBJLst_Act_Goom_StunR2: INCBIN "data/objlst/actor/goom_stunr2.bin"
OBJLst_Act_Goom_Unused_StunAltR: INCBIN "data/objlst/actor/goom_unused_stunaltr.bin"
GFX_Act_Goom: INCBIN "data/gfx/actor/goom.bin"

; =============== ActInit_SSTeacupBoss ===============
ActInit_SSTeacupBoss:
	xor  a
	ld   [sActBossDead], a
	
	; Setup collision box for the part which can be bumped into.
	;
	; Note how we aren't setting the collision type yet.
	; This is because we don't want to enable it until the boss fully scrolls into view,
	; which is after mode $05 ends.
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_SSTeacupBoss
	call ActS_SetCodePtr
	
	; This boss moves in the foreground -- there's no visible sprite
	mActS_SetBlankFrame
	ld   bc, OBJLstSharedPtrTable_Act_None
	call ActS_SetOBJLstSharedTablePtr
	
	; Adjust the actor's position slightly, since it isn't aligned to the
	; 16x16 grid limitation of the actor layout.
	ld   bc, +$08
	call ActS_MoveRight
	ld   bc, -$20
	call ActS_MoveDown
	
	; Copy over the tilemaps for the main body
	; [BUG] Shouldn't have been done here. See comment at ActInit_SSTeacupBoss_SetParallax. 
	; [POI] Some of these don't seem to be necessary... ClawsDown and Eyes are already in Body
	call Act_SSTeacupBoss_BGWrite_Body
	call Act_SSTeacupBoss_BGWrite_BeakOpen
	call Act_SSTeacupBoss_BGWrite_ClawsDown
	call Act_SSTeacupBoss_BGWrite_Eyes
	
	xor  a
	ld   [sActSSTeacupBossHitCount], a
	; Set intro movement mode (where the boss slowly scrolls into view)
	ld   a, SSBOSS_RTN_INTRO
	ld   [sActLocalRoutineId], a
	
	call ActInit_SSTeacupBoss_SetParallax
	
	xor  a
	ld   [sActBossParallaxFlashTimer], a
	
	; Freeze player for $78 frames while the boss moves in
	ld   a, $78
	ld   [sPlFreezeTimer], a
	
	call ActS_CheckOffScreen			; Update offscreen status
	ld   a, [sActSetRelX]
	ld   [sActSSTeacupBossRelXTarget], a
	
	; Push the boss right 50px (off-screen) to prepare for the intro
	ld   c, $50
	call Act_SSTeacupBoss_MoveRight
	ret
; =============== ActInit_SSTeacupBoss_SetParallax ===============
; Initializes the special scroll mode for the SSTeacup Boss room.
ActInit_SSTeacupBoss_SetParallax:
	; We need to enable an interrupt, so stop them all
	di
	
	;--
	; For the parallax effect, we need to divide the screen in 2 sections
	; - Boss body
	; - Ground
	; However, the scroll mode for bosses has a fixed number of sections (4).
	; As a result, the boss body section gets duplicated twice (X0, X1, X2).
	
	; Starting coords for boss body (X: $40, Y: $50)
	; As the boss moves around, these will be updated (all at once, of course).
	ld   a, $40					
	ld   [sActBossParallaxX], a
	ld   [sParallaxX0], a
	ld   [sParallaxX1], a
	ld   [sParallaxX2], a
	ld   a, $50
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
	
	; [BUG] But a minor one at that.
	; This is a sligtly questionable use of the useless parallax sections which
	; can cause screen tearing (during the boss flash) and occasionally glitch lines.
	;
	; These weird values were likely picked to partially mask a worse scroll bug at the start of the boss,
	; caused by writing the boss body to the tilemap (which happens before the parallax is updated, even!).
	;
	; To fix this:
	; - A secondary ActInit mode should be added, for specifically writing the tilemaps to VRAM.
	;	Since this way it's definitely done after the parallax is applied.
	; - Fix the parallax modes. The easy way would be to set LY2 to $01 and LY3 to $03.
	;	Since the boss generally never goes high enough, any visual glitches will be hidden.
	;	The correct way would be to use LY1 for the ground and move LY2 and LY3 off-screen.
	ld   a, $00					; Start sect0 (boss body) at $00
	ld   [sParallaxNextLY0], a
	ld   a, $20					; Start sect1 at $20 (bad)
	ld   [sParallaxNextLY1], a
	ld   a, $50					; Start sect2 at $50 (bad)
	ld   [sParallaxNextLY2], a
	ld   a, $6F					; Start sect3 (ground) at $6F
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
	ret
	
; =============== Act_SSTeacupBoss_DoHitFlash ===============
; This subroutine performs the boss flash after an hit.
Act_SSTeacupBoss_DoHitFlash:
	ld   a, [sActBossParallaxFlashTimer]
	dec  a						; Count--
	ld   [sActBossParallaxFlashTimer], a
	cp   a, $02					; Is it < $02?
	jr   c, .copyNorm			; If so, copy the parallax value directly
	
	; Since this is a foreground-based boss, it can't be flashed like normal bosses.
	
	; Instead, every 2 frames, the X parallax for the boss section 
	; alternates between the normal values and $E0.
	; X $E0 is off-screen, effectively hiding the boss.
	
	; As for why it's alternating every 2 frames instead of every other frame,
	; it's to account for the already drawn scanlines (this is an HBlank effect and all).
	; With a second frame, there's at least one frame where the entire boss flashes.
	
	ld   a, [sActSetTimer]
	bit  1, a					; sActSetTimer & 2 != 0?
	jr   z, .copyNorm			; If so, show the boss
.copyE0:
	ld   a, $E0					; Otherwise, hide the boss
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
	
; =============== Act_SSTeacupBoss ===============
Act_SSTeacupBoss:
	; Timer++
	ld   a, [sActSetTimer]
	inc  a
	ld   [sActSetTimer], a
	
	; Flash boss post-hit
	ld   a, [sActBossParallaxFlashTimer]
	or   a
	call nz, Act_SSTeacupBoss_DoHitFlash
	
	; Which action is the boss taking?
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_SSTeacupBoss_Mode_Wind
	dw Act_SSTeacupBoss_Mode_YArc
	dw Act_SSTeacupBoss_Mode_Hit
	dw Act_SSTeacupBoss_Mode_Dead
	dw Act_SSTeacupBoss_Mode_CoinGame
	dw Act_SSTeacupBoss_Mode_Intro
	
; =============== Act_SSTeacupBoss_Mode_Intro ===============
; This mode is used for the intro scene, where the boss scrolls into view.
; Collision is disabled during this.
Act_SSTeacupBoss_Mode_Intro:
	call Act_SSTeacupBoss_AnimWingsV
	
	;--
	;
	; Move the boss left at 0.5px/frame until the target X pos is reached.
	;
	
	ld   a, [sActSetTimer]						; Every other frame...
	and  a, $01
	ret  nz
	
	; We're comparing against the "invisible" actor
	ld   a, [sActSetRelX]						; C = Current X pos
	ld   c, a
	ld   a, [sActSSTeacupBossRelXTarget]		; A = Target X pos
	cp   a, c									; CurrentPos < TargetPos?
	jr   nc, Act_SSTeacupBoss_SwitchToWind		; If so, switch to the wind mode
	
	ld   c, -$01								; Otherwise continue moving left
	call Act_SSTeacupBoss_MoveRight
	;--
	ret
	
; =============== Act_SSTeacupBoss_SwitchToWind ===============
; Switches to routine $00.
Act_SSTeacupBoss_SwitchToWind:
	xor  a									; Change movement mode
	ld   [sActLocalRoutineId], a
	
	mActColiMask ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_NORM, ACTCOLI_BUMP
	ld   a, COLI							; Enable damage from above
	ld   [sActSetColiType], a
	
	ld   a, $AA								; Stay in wind mode for $AA frames
	ld   [sActSSTeacupBossModeTimer], a
	
	call Act_SSTeacupBoss_BGWriteGroup_Wind	; Prepare tilemap
	ret
	
; =============== Act_SSTeacupBoss_Mode_Wind ===============
; This mode is used when the boss blows air against the player.
Act_SSTeacupBoss_Mode_Wind:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_SSTeacupBoss_Mode_Wind_Main
	dw Act_SSTeacupBoss_Mode_Wind_Main;X
	dw Act_SSTeacupBoss_SwitchToHit
	dw Act_SSTeacupBoss_SwitchToHit;X
	dw Act_SSTeacupBoss_Mode_Wind_Main;X
	dw Act_SSTeacupBoss_SwitchToHit;X
	dw Act_SSTeacupBoss_Mode_Wind_Main;X
	dw Act_SSTeacupBoss_Mode_Wind_Main
	dw Act_SSTeacupBoss_Mode_Wind_CheckThrown
Act_SSTeacupBoss_Mode_Wind_Main:
	
	; Decrement the time remaining for this mode.
	; Once it elapses, switch to mode $01.
	ld   a, [sActSSTeacupBossModeTimer]
	or   a
	jr   z, Act_SSTeacupBoss_SwitchToYArc
	dec  a
	ld   [sActSSTeacupBossModeTimer], a
	
	call Act_SSTeacupBoss_AnimWingsH			
	
	;--
	; [POI] Update the anim frame every 4 global frames...
	;       ...except this boss doesn't have a visible sprite, so it ends up doing nothing.
	;
	; Result of copy/paste from a boss which does have sprites.
	ld   a, [sActTimer]
	cp   a, $03							; Timer < $03?
	jr   c, .tryMove					; If so, skip
	xor  a								; Otherwise, reset the timer
	ld   [sActTimer], a
	ld   a, [sActSetOBJLstId]			; AnimFrame++
	inc  a
	ld   [sActSetOBJLstId], a
	;--
.tryMove:
	;--
	;
	; Attempt to move the player left at 0.5px/frame
	;
	
	; Every other frame...
	ld   a, [sActSetTimer]				
	and  a, $01							
	ret  nz
	; If the player is ducking, don't move.
	; Curiously, this outright returns, meaning the boss doesn't get to move either.
	ld   a, [sPlDuck]
	or   a								
	ret  nz								
	; Otherwise, move left 1px
	ld   b, $01							
	call Pl_MoveLeft
	;--
	
	;
	; Do boss movement at 0.25px/frame
	;
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	
	ld   c, $01							
	call Act_SSTeacupBoss_MoveRight
	
	; Move boss torwards Y pos $40
	ld   a, [sActSetRelY]				; Depending on the current Y pos...
	cp   a, $40							; Y == $40?
	ret  z								; If so, don't move
	jr   c, .moveUp						; If < $40, move down
	ld   c, $FF							; Otherwise, move up
	call Act_SSTeacupBoss_MoveDown
	ret
.moveUp:
	ld   c, $01
	call Act_SSTeacupBoss_MoveDown
	ret
	
; =============== Act_SSTeacupBoss_SwitchToYArc ===============
Act_SSTeacupBoss_SwitchToYArc:
	ld   a, SSBOSS_RTN_YARC					; Set Y oscillation mode
	ld   [sActLocalRoutineId], a
	ld   a, $C8								; Stay for $C8 frames
	ld   [sActSSTeacupBossModeTimer], a
	xor  a									; Reset the number of spawned birds
	ld   [sActSSTeacupBossSpawnCount], a
	call Act_SSTeacupBoss_BGWrite_BeakOpen
	call Act_SSTeacupBoss_BGWrite_ClawsDown
	call Act_SSTeacupBoss_BGWrite_Eyes
	ret
	
; =============== Act_SSTeacupBoss_Mode_YArc ===============
Act_SSTeacupBoss_Mode_YArc:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_SSTeacupBoss_Mode_YArc_Main
	dw Act_SSTeacupBoss_Mode_YArc_Main;X
	dw Act_SSTeacupBoss_SwitchToHit
	dw Act_SSTeacupBoss_SwitchToHit
	dw Act_SSTeacupBoss_Mode_YArc_Main;X
	dw Act_SSTeacupBoss_SwitchToHit;X
	dw Act_SSTeacupBoss_Mode_YArc_Main;X
	dw Act_SSTeacupBoss_Mode_YArc_Main
	dw Act_SSTeacupBoss_Mode_YArc_CheckThrown
	
; =============== Act_SSTeacupBoss_AnimWingsV ===============
; This subroutine animates the boss' wings by updating the BG tilemap.
; This is for making the wings move vertically.
;
; [BUG] This doesn't account in any way for Bobo's beak being open.
;		So there's a minor visual glitch with part of the beak getting cut off.
Act_SSTeacupBoss_AnimWingsV:
	; Animate every $08 frames
	ld   a, [sActSetTimer]
	and  a, $07
	ret  nz
	
	; Since this goes off every $08 frames, the lower three bits are always 0.
	; We can generate the index by >> 3'ing the timer.
	ld   a, [sActSetTimer]
	and  a, $18				; make it in the valid range $08 * <table size>
	; do a fast >> 3
	rlca					; << 1
	swap a					; >> 4
	
	; And then choose which tilemap to copy over
	rst  $28
	dw Act_SSTeacupBoss_BGWrite_WingV0
	dw Act_SSTeacupBoss_BGWrite_WingV1
	dw Act_SSTeacupBoss_BGWrite_WingV2
	dw Act_SSTeacupBoss_BGWrite_WingV1
	
; =============== Act_SSTeacupBoss_AnimWingsH ===============
; This subroutine animates the boss' wings by updating the BG tilemap.
; This is for making the wings move horizontally (when blowing the player closer to the pit).
Act_SSTeacupBoss_AnimWingsH:
	; Animate every $04 frames
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	
	; Since this goes off every $04 frames, the lower two bits are always 0.
	; Generate the index by >> 2'ing the timer
	ld   a, [sActSetTimer]
	and  a, $04				; $02*<table size>
	rrca					; >> 1
	rrca					; >> 1
	
	rst  $28
	dw Act_SSTeacupBoss_BGWrite_WingH0
	dw Act_SSTeacupBoss_BGWrite_WingH1
	
; =============== Act_SSTeacupBoss_BGWriteGroup_Wind ===============
; Copies all of the tilemaps visible during the "wind blow" effect.
Act_SSTeacupBoss_BGWriteGroup_Wind:
	; [POI] CloseBreak and Eyes aren't necessary since Body contains them already
	call Act_SSTeacupBoss_BGWrite_Body
	call Act_SSTeacupBoss_BGWrite_BeakClosed
	call Act_SSTeacupBoss_BGWrite_ClawsUp
	call Act_SSTeacupBoss_BGWrite_Eyes
	ret
	
; =============== Act_SSTeacupBoss_Mode_YArc_Main ===============
; Y offset table for the boss when moving vertically.
; The values used result in the boss moving in an arc, slowing down gradually around the edges.
Act_SSTeacupBoss_YPath:
	db +$00,+$01,+$02,+$03,+$03,+$02,+$01,+$00
	db -$00,-$01,-$02,-$03,-$03,-$02,-$01,-$00
	
; =============== Act_SSTeacupBoss_Mode_YArc_Main ===============
; Handle vertical movement
Act_SSTeacupBoss_Mode_YArc_Main:
	call Act_SSTeacupBoss_AnimWingsV
	
	; Perform movement every 4 frames (0.25px/frame)
	ld   a, [sActSetTimer]
	ld   b, a				; B = Timer
	and  a, $03				; Is it the 4th frame?
	jr   nz, .decTimer		; If not, skip
	
	;--
	; Move the boss vertically based on the table values.
	
	; Generate the index (every 4 frames -> 2 bits, so >> 2 the timer)
	; This requires the table size to be a multiple of 2.
	ld   a, b
	and  a, $3C							; A = (Timer >> 2) & $0F
	rrca								
	rrca								
	ld   hl, Act_SSTeacupBoss_YPath	; HL = Table
	ld   d, $00							; DE = A
	ld   e, a
	add  hl, de							; Offset the table
	ld   c, [hl]						; C = Pixels to move down
	call Act_SSTeacupBoss_MoveDown
	;--
	
	; Move the boss left until it reaches the target
	ld   a, [sActSetRelX]					; C = X Pos
	ld   c, a
	ld   a, [sActSSTeacupBossRelXTarget]	; A = Target Pos
	cp   a, c								; Did we already go past the target?
	jr   nc, .decTimer						; If so, skip this
	ld   c, -$01							; Otherwise move left 1px
	call Act_SSTeacupBoss_MoveRight
	
.decTimer:
	; Handle time remaining for this mode
	ld   a, [sActSSTeacupBossModeTimer]
	or   a									; Is the timer elapsed?
	jp   z, Act_SSTeacupBoss_SwitchToWind	; If so, switch back to the wind mode.
	dec  a									; Otherwise, decremrnt it
	ld   [sActSSTeacupBossModeTimer], a
	
	; Every $20 frames try to spawn a bird
	ld   a, [sActSetTimer]
	and  a, $1F					
	ret  nz						
	call Act_SSTeacupBoss_SpawnWatch
	ret
	
; =============== Act_SSTeacupBoss_MoveDown ===============
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
Act_SSTeacupBoss_MoveDown:
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
	ret
	
; =============== Act_SSTeacupBoss_MoveRight ===============
; This subroutine moves the boss to the right, 
; applied to both the parallax effect and the invisible actor.
; IN:
; - C: Pixels to move right
Act_SSTeacupBoss_MoveRight:
	; Move the *parallax section* left, which causes the boss to move right.
	ld   a, [sActBossParallaxX]
	sub  a, c								
	ld   [sActBossParallaxX], a
	; And update the parallax sections
	ld   [sParallaxX0], a
	ld   [sParallaxX1], a
	ld   [sParallaxX2], a
	
	; Sign-extend since ActS_MoveRight goes off a 16bit value
	ld   a, c
	sext a
	ld   b, a
	call ActS_MoveRight
	ret
	
; =============== Act_SSTeacupBoss_SpawnWatch ===============
; Tries to spawn a Watch (pickable ver.).
; Must be called from when executing the Boss actor.
Act_SSTeacupBoss_SpawnWatch:
	; Find an empty slot
	ld   hl, sAct			; HL = Actor slot area
	ld   d, $05				; D = Slots count (normal slots)
	ld   e, $00				; E = Current slot
	ld   c, $00				; C = Existing Watch actors
	
	; Determine the actor ID for what we're trying to spawn.
	; We need this later to count how many actors were already spawned.
	;
	; NOTE: For this to work properly, it requires a specific order in the Actor group definition.
	;		The actor we're trying to spawn must be exactly after the actor we're currently executing.
	;
	;		Basically, ActCodeDef_SSTeacupBossWatch (what we're spawning) must be exactly
	;		after ActCodeDef_SSTeacupBoss (the actor code being executed).
	;		(see: ActGroupCodeDef_C30_Room00).
	
	ld   a, [sActSetId]		; B = Actor ID of what we're spawning
	inc  a					;     sActSetId + 1
	ld   b, a
	
.checkSlot:
	ld   a, [hl]			; Read active status
	cp   a, $02				; Is it visible & active?
	jr   nz, .slotFound		; If not, we found a slot.
	
	;--
	inc  e					; Slot++
	
	;--
	;
	; No more than 2 Watches should be active at once.
	; Kill the spawn request if we found enough already.
	;
	
	ld   a, l				; Move to the actor id location			
	add  sActSetId-sActSet
	ld   l, a
	ld   a, [hl]			; Read it
	cp   a, b				; Is it a Watch?
	jr   nz, .nextSlot		; If not, skip
	inc  c					; Found++
	ld   a, c				
	cp   a, $02				; Reached the limit of $02?
	ret  nc					; If so, return
	;--
	
.nextSlot:
	dec  d					; Have we searched in all 5 slots?
	ret  z					; If so, return
	ld   a, l				; If not, move to the next actor slot
	add  (sActSet_End-sActSet) - (sActSetId-sActSet)
	ld   l, a
	jr   .checkSlot
	
.slotFound:
	; We found the slot to use (either free, or off-screen)
	
	; Prevent spawning more than 3 birds for each cycle
	ld   a, [sActSSTeacupBossSpawnCount]
	cp   a, $03					; SpawnCount >= $03?
	ret  nc						; if so, return
	inc  a						; SpawnCount++
	ld   [sActSSTeacupBossSpawnCount], a
	
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_Watch
	
	ld   a, $02					; Enabled
	ldi  [hl], a
	
	ld   a, [sActSetX_Low]		; X = sActSetX
	ldi  [hl], a
	ld   a, [sActSetX_High]		
	ldi  [hl], a
	
	ld   a, [sActSetY_Low]		; Y = sActSetY + $08
	add  $08
	ldi  [hl], a
	ld   a, [sActSetY_High]
	adc  a, $00
	ldi  [hl], a
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ldi  [hl], a
	
	ld   a, $F1					; Coli box U
	ldi  [hl], a
	ld   a, $FF					; Coli box D
	ldi  [hl], a
	ld   a, $F6					; Coli box L
	ldi  [hl], a
	ld   a, $0A					; Coli box R
	ldi  [hl], a
	
	ld   a, $00
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_None)	; OBJLst Table (none)
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_None)
	ldi  [hl], a
	
	ld   a, DIR_L			; Dir
	ldi  [hl], a
	xor  a						; OBJLst ID
	ldi  [hl], a
	
	; Actor ID -- With the same assumption about the actor group.
	ld   a, [sActSetId]			; CurActorId + 1	
	inc  a
	ldi  [hl], a
	
	xor  a						; Routine ID
	ldi  [hl], a
	ld   a, LOW(SubCall_Act_SSTeacupBossWatch)		; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_SSTeacupBossWatch)
	ldi  [hl], a
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	; Spawn at birds at progressively lower positions
	ld   a, [sActSSTeacupBossSpawnCount]		; Y Speed = SpawnCount + 2
	add  $02
	ldi  [hl], a
	xor  a
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
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_Watch)		; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_Watch)
	ldi  [hl], a
	
	ld   a, SFX1_29		; Play SFX
	ld   [sSFX1Set], a
	ret
	
; =============== Act_SSTeacupBoss_Mode_Wind_CheckThrown ===============
; This subroutine is called when something is thrown at the boss during the Wind mode.
Act_SSTeacupBoss_Mode_Wind_CheckThrown:
	; Verify that we aren't throwing a 10-coin or key at the boss.
	; We can do this by simply checking if it's a default actor.
	mActCheckThrownId ACT_DEFAULT_BASE			; Were we thrown a default actor? ( >= $07)
	jp   nc, Act_SSTeacupBoss_Mode_Wind_Main	; If so, don't register the hit
	jr   Act_SSTeacupBoss_SwitchToHit
	
; =============== Act_SSTeacupBoss_Mode_YArc_CheckThrown ===============
; This subroutine is called when something is thrown at the boss during the YArc mode.
; Almost identical to the subroutine above.
Act_SSTeacupBoss_Mode_YArc_CheckThrown:
	mActCheckThrownId ACT_DEFAULT_BASE			; Were we thrown a default actor? ( >= $07)
	jp   nc, Act_SSTeacupBoss_Mode_YArc_Main	; If so, don't register the hit
	
; =============== Act_SSTeacupBoss_SwitchToHit ===============
; This subroutine is called when the boss is damaged.
Act_SSTeacupBoss_SwitchToHit:
	ld   a, SSBOSS_RTN_HIT				; Set new routine
	ld   [sActLocalRoutineId], a
	ld   a, $1E							; Stay in the damage routine for $1E frames
	ld   [sActSSTeacupBossModeTimer], a
	
	; Give mercy invincibility to boss
	mActColiMask ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_BUMP, ACTCOLI_BUMP
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Write new tilemaps
	call Act_SSTeacupBoss_BGWrite_BeakOpen
	call Act_SSTeacupBoss_BGWrite_EyesHit
	
	ld   a, SFX1_2C				; Play SFX
	ld   [sSFX1Set], a
	
	ld   a, [sActSSTeacupBossHitCount]	; HitCount++
	inc  a
	ld   [sActSSTeacupBossHitCount], a
	cp   a, $03							; Did we hit the boss 3 times?
	jr   nc, Act_SSTeacupBoss_SwitchToDead	; If so, we defeated it
	
	call SubCall_ActS_SpawnStunStar
	
	; Flash boss for $1E frames (same as sActSSTeacupBossModeTimer)
	ld   a, $1E
	ld   [sActBossParallaxFlashTimer], a
	ret
; =============== Act_SSTeacupBoss_Mode_Hit ===============
; This handles the stun effect when the boss is hit.
Act_SSTeacupBoss_Mode_Hit:
	; Once the stun effect expires, return to the arc movement mode
	ld   a, [sActSSTeacupBossModeTimer]
	or   a
	jp   z, Act_SSTeacupBoss_SwitchToYArc
	dec  a
	ld   [sActSSTeacupBossModeTimer], a
	
	;--
	; [POI] Not necessary here. This actor has no visible sprites.
	; Every other frame increase the anim frame.
	ld   a, [sTimer]
	and  a, $01
	jr   nz, .chkDuck
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	;--
.chkDuck:
	; Move the player left 1px (as if the wind effect was active)
	; Presumably meant to make it harder to combo the boss when jumping on top.
	ld   a, [sPlDuck]
	or   a				; Is the player ducking?
	ret  nz				; If so, don't move [POI]
	ld   b, $01			; Otherwise move left
	call Pl_MoveLeft
	ret
	
; =============== Act_SSTeacupBoss_SwitchToDead ===============
; This subroutine is called when the boss is damaged 3 times.
Act_SSTeacupBoss_SwitchToDead:
	ld   a, SSBOSS_RTN_DEAD
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSSTeacupBossModeTimer], a
	; [TCRF] High byte isn't used
	ld   bc, -$02						; Set initial speed for jump arc
	ld   a, c
	ld   [sActSetYSpeed_Low], a
	ld   a, SFX1_09
	ld   [sSFX1Set], a
	ld   a, BGM_NONE
	ld   [sBGMSet], a
	ld   a, $C8							; Flash boss long enough that it won't stop until it goes off-screen
	ld   [sActBossParallaxFlashTimer], a
	ld   a, $01
	ld   [sActBossDead], a
	xor  a
	ld   [sActHeld], a
	call ActS_DespawnAllNormExceptCur_Broken
	ret
; =============== Act_SSTeacupBoss_Mode_Dead ===============
; This handles the downwards movement after the boss is defeated.
Act_SSTeacupBoss_Mode_Dead:
	; Switch to the next mode if the boss is off-screen now
	ld   a, [sActSetRelY]
	cp   a, $A0								; Y >= $A0?
	jr   nc, Act_SSTeacupBoss_SwitchToCoinGame	; If so, jump
	
	ld   a, [sActSetYSpeed_Low]			; C = sActSetYSpeed_Low
	ld   c, a
	call Act_SSTeacupBoss_MoveDown			; Move down by that
	
	; Every 8 frames increase the fall speed
	ld   a, [sActSetTimer]
	and  a, $07
	jr   nz, .end
	ld   a, [sActSetYSpeed_Low]			
	add  $01								
	ld   [sActSetYSpeed_Low], a
.end:
	ret
	
; =============== Act_SSTeacupBoss_SwitchToCoinGame ===============
; Sets up the coin game mode.
Act_SSTeacupBoss_SwitchToCoinGame:
	;--
	; Set the boss position at exactly $A0.
	
	; For convenience we're using Act_SSTeacupBoss_MoveDown to do this, but that subroutine 
	; only accepts a Y offset as parameter.
	; So we have to move upwards by (Y - $A0), which means we're converting this number to negative. 
	
	; C = -(Y-$A0)
	ld   a, [sActSetRelY]	; With Y being >= $A0...
	sub  a, $A0				; Y -= $A0
	cpl						; Convert to positive
	inc  a					; fix for above
	ld   c, a
	call Act_SSTeacupBoss_MoveDown	; Move down by that
	;--
	ld   a, SSBOSS_RTN_COINGAME		; Set new routine
	ld   [sActLocalRoutineId], a
	ld   a, BGM_COINGAME			; Start bgm for coin rain
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a			; ?
	ret
	
; =============== Act_SSTeacupBoss_Mode_CoinGame ===============
Act_SSTeacupBoss_Mode_CoinGame:
	call SubCall_ActS_CoinGame
	ret
	
; =============== mSSTeacupBoss_BGWriteCall* ===============
; Helper macro for generating a call to Act_SSTeacupBoss_BGWrite*
; IN
; - 1: Base address
; - 2: X offset (in tiles)
; - 3: Y offset (in tiles)
; - 4: Tiles to copy
mSSTeacupBoss_BGWriteCall: MACRO
	ld   hl, \1 + (BG_TILECOUNT_H * \3) + \2
	call Act_SSTeacupBoss_BGWrite\4
ENDM
	
; =============== Act_SSTeacupBoss_BGWrite_* ===============
; This set of subroutines copies tilemaps for the SSTeacup boss body.
Act_SSTeacupBoss_BGWrite_Body:
	; Tile IDs written: $58
	; Each of these defines how many tiles to write in a row.
	ld   de, BG_Act_SSTeacupBoss_Body				; DE = Ptr to tilemap
I = 0
REPT 11
	;                         VRAM                 X  Y  Count
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossBody, 0, I, 8
I = I + 1
ENDR
	ret
	
Act_SSTeacupBoss_BGWrite_WingV0:
	ld   de, BG_Act_SSTeacupBoss_WingV0
	;                         VRAM                 X  Y  Count
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 0, 0, 2
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 3, 0, 3
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 3, 1, 3
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 3, 2, 3
	ret
Act_SSTeacupBoss_BGWrite_WingV1:
	ld   de, BG_Act_SSTeacupBoss_WingV1
	;                         VRAM                 X  Y  Count
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 0, 0, 2
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 3, 0, 3
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 3, 1, 3
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 3, 2, 3
	ret
Act_SSTeacupBoss_BGWrite_WingV2:
	ld   de, BG_Act_SSTeacupBoss_WingV2
	;                         VRAM                 X  Y  Count
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 0, 0, 2
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 3, 0, 3
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 3, 1, 3
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 3, 2, 3
	ret
Act_SSTeacupBoss_BGWrite_BeakOpen:
	ld   de, BG_Act_SSTeacupBoss_BeakOpen
	;                         VRAM                 X  Y  Count
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossBeak, 0, 0, 3
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossBeak, 0, 1, 3
	ret
Act_SSTeacupBoss_BGWrite_BeakClosed:
	ld   de, BG_Act_SSTeacupBoss_BeakClosed
	;                         VRAM                 X  Y  Count
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossBeak, 0, 0, 3
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossBeak, 1, 1, 1
	ret
Act_SSTeacupBoss_BGWrite_WingH0:
	ld   de, BG_Act_SSTeacupBoss_WingH0
	;                         VRAM                 X  Y  Count
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 0, 0, 6
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 0, 1, 6
	ret
Act_SSTeacupBoss_BGWrite_WingH1:
	ld   de, BG_Act_SSTeacupBoss_WingH1
	;                         VRAM                 X  Y  Count
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 0, 0, 6
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossWing, 0, 1, 6
	ret
Act_SSTeacupBoss_BGWrite_EyesHit:
	ld   de, BG_Act_SSTeacupBoss_EyesHit
	;                         VRAM                 X  Y  Count
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossEyes, 0, 0, 3
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossEyes, 0, 1, 3
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossEyes, 0, 2, 3
	ret
Act_SSTeacupBoss_BGWrite_Eyes:
	ld   de, BG_Act_SSTeacupBoss_Eyes
	;                         VRAM                 X  Y  Count
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossEyes, 0, 0, 3
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossEyes, 0, 1, 3
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossEyes, 0, 2, 3
	ret
Act_SSTeacupBoss_BGWrite_ClawsDown:
	ld   de, BG_Act_SSTeacupBoss_ClawsDown
	;                         VRAM                  X  Y  Count
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossClaws, 0, 0, 5
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossClaws, 1, 1, 4
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossClaws, 1, 2, 7
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossClaws, 4, 3, 4
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossClaws, 4, 4, 4
	ret
Act_SSTeacupBoss_BGWrite_ClawsUp:
	ld   de, BG_Act_SSTeacupBoss_ClawsUp
	;                         VRAM                  X  Y  Count
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossClaws, 0, 0, 5
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossClaws, 1, 1, 4
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossClaws, 1, 2, 7
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossClaws, 4, 3, 4
	mSSTeacupBoss_BGWriteCall vBGSSTeacupBossClaws, 4, 4, 4
	ret
	
BG_Act_SSTeacupBoss_Body: INCBIN "data/bg/level/ssteacupboss_body.bin"
BG_Act_SSTeacupBoss_WingV0: INCBIN "data/bg/level/ssteacupboss_wingv0.bin"
BG_Act_SSTeacupBoss_WingV1: INCBIN "data/bg/level/ssteacupboss_wingv1.bin"
BG_Act_SSTeacupBoss_WingV2: INCBIN "data/bg/level/ssteacupboss_wingv2.bin"
BG_Act_SSTeacupBoss_BeakOpen: INCBIN "data/bg/level/ssteacupboss_beakopen.bin"
BG_Act_SSTeacupBoss_BeakClosed: INCBIN "data/bg/level/ssteacupboss_beakclosed.bin"
BG_Act_SSTeacupBoss_WingH0: INCBIN "data/bg/level/ssteacupboss_wingh0.bin"
BG_Act_SSTeacupBoss_WingH1: INCBIN "data/bg/level/ssteacupboss_wingh1.bin"
BG_Act_SSTeacupBoss_EyesHit: INCBIN "data/bg/level/ssteacupboss_eyeshit.bin"
BG_Act_SSTeacupBoss_Eyes: INCBIN "data/bg/level/ssteacupboss_eyes.bin"
BG_Act_SSTeacupBoss_ClawsDown: INCBIN "data/bg/level/ssteacupboss_clawsdown.bin"
BG_Act_SSTeacupBoss_ClawsUp: INCBIN "data/bg/level/ssteacupboss_clawsup.bin"

; =============== mSSTeacupBoss_BGWrite ===============
; This macro copies a single tile from the specified tilemap directly to VRAM.
;
; This is meant to be used with the SSTeacup boss, but equivalent code exists for
; other foreground-based bosses.
;
; Since this is meant to be called outside VBlank, with the display still enabled,
; this copy has to be done during HBlank.
; This makes it take a significant amount of cycles.
; IN
; - DE: Ptr to tilemap
; - HL: Destination in VRAM
mSSTeacupBoss_BGWrite: MACRO
	mWaitForNewHBlank
	ld   a, [de]		; A = Tile ID
	inc  de				; TilemapPtr++
	ldi  [hl], a		; Write it to VRAM
ENDM

; =============== Act_SSTeacupBoss_BGWrite<N> ===============
; Set of helper subroutines for copying N tiles from the specified tilemap directly to VRAM.
; IN
; - DE: Ptr to tilemap
; - HL: Destination in VRAM
Act_SSTeacupBoss_BGWrite8:
REPT 8
	mSSTeacupBoss_BGWrite
ENDR
	ret
Act_SSTeacupBoss_BGWrite7:
REPT 7
	mSSTeacupBoss_BGWrite
ENDR
	ret
Act_SSTeacupBoss_BGWrite6:
REPT 6
	mSSTeacupBoss_BGWrite
ENDR
	ret
Act_SSTeacupBoss_BGWrite5:
REPT 5
	mSSTeacupBoss_BGWrite
ENDR
	ret
Act_SSTeacupBoss_BGWrite4:
REPT 4
	mSSTeacupBoss_BGWrite
ENDR
	ret
Act_SSTeacupBoss_BGWrite3:
REPT 3
	mSSTeacupBoss_BGWrite
ENDR
	ret
Act_SSTeacupBoss_BGWrite2:
REPT 2
	mSSTeacupBoss_BGWrite
ENDR
	ret
Act_SSTeacupBoss_BGWrite1:
	mSSTeacupBoss_BGWrite
	ret

; [TCRF] This is also used as a GFX pointer for some reason!
;        How did this happen?
; =============== ActS_SpawnBigCoin ===============
; Spawns a 100-coin from a big item box.
; This is specifically meant to be spawned from another actor.
ActS_SpawnBigCoin:
	; Find an empty slot
	ld   hl, sAct		; HL = Actor slot area
	ld   d, $05			; D = Total slots (not $07, unlike in ActS_SpawnBigHeart)
	ld   e, $00			; E = Current slot
.checkSlot:
	ld   a, [hl]		; Read active status
	or   a				; Is the slot marked as active?
	jr   z, .slotFound	; If not, we found a slot
	
	inc  e				; Slot++
	dec  d				; Have we searched in all 5 slots?
	jr   z, .noSpawn	; If so, return
	
	ld   a, l			; Move to next slot (HL += $20)
	add  (sActSet_End-sActSet)
	ld   l, a
	jr   .checkSlot
.noSpawn:
	ret ; We actually never get here
.slotFound:
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_BigCoin
	
	ld   a, $02					; Enabled
	ldi  [hl], a
	ld   a, [sActSetX_Low]		; X = sActSetX + $04
	add  $04
	ldi  [hl], a
	ld   a, [sActSetX_High]
	adc  a, $00
	ldi  [hl], a
	
	; Place the big coin on top of the parent actor.
	; The parent actor's Y coord points to its origin, so we subtract the height
	; of its upper bounding box height to get right above it.
	
	; This "parent actor" will be a big item box, which is the only actor
	; which calls this subroutine.
	
	ld   a, [sActSetColiBoxU]	; C = -sActSetColiBoxU
	cpl							; cpl inversion
	inc  a						; fix for above
	ld   c, a
	ld   a, [sActSetY_Low]		; Y = sActSetY + sActSetColiBoxU
	sub  a, c
	ldi  [hl], a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ldi  [hl], a
	
	ld   a, ACTCOLI_BIGCOIN		; Collision type
	ldi  [hl], a
	ld   a, -$18				; Coli box U
	ldi  [hl], a
	ld   a, -$08				; Coli box D
	ldi  [hl], a
	ld   a, -$08				; Coli box L
	ldi  [hl], a
	ld   a, +$08				; Coli box R
	ldi  [hl], a
	
	ld   a, $10
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_None)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_None)
	ldi  [hl], a
	
	xor  a						; Dir
	ldi  [hl], a
	xor  a						; OBJLst ID
	ldi  [hl], a
	
	; Assume current + 1
	ld   a, [sActSetId]			; Actor ID
	inc  a
	ldi  [hl], a
	
	xor  a						; Dir
	ldi  [hl], a
	ld   a, LOW(SubCall_Act_BigCoin)	; Code ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_BigCoin)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	
	ld   bc, -$01				; Y Speed
	ld   a, c
	ldi  [hl], a				
	ld   a, b
	ldi  [hl], a
	
	ldi  [hl], a				; Timer 5
	ldi  [hl], a				; Timer 6
	ldi  [hl], a				; Timer 7
	
	ld   a, $01					; Flags
	ldi  [hl], a
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	ld   a, LOW(OBJLstSharedPtrTable_Act_BigCoin)	; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_BigCoin)
	ldi  [hl], a
	
	ret
	
; =============== ActInit_BigCoin ===============
ActInit_BigCoin:
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
	ld   bc, SubCall_Act_BigCoin
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_BigCoin
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_BigCoin
	call ActS_SetOBJLstSharedTablePtr
	
	; Set collision type
	ld   a, ACTCOLI_BIGCOIN
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	; Reset timers
	xor  a
	ld   [sActSetTimer2], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	; Big item boxes are slightly larger than a 16x16 block, so they get centered.
	; Align the content of the item box in the same way (at least horizontally).
	ld   bc, +$04
	call ActS_MoveRight
	ret
	
OBJLstPtrTable_ActInit_BigCoin:
	dw OBJLst_Act_BigCoin0
	dw $0000;X
	
; =============== Act_BigCoin ===============
Act_BigCoin:
	; Force set the correct sprite map table
	ld   a, LOW(OBJLstPtrTable_BigCoinL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_BigCoinL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	call Act_BigCoin_Move			
	
	; Every 4 frames increase the anim frame
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .end
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.end:
	ret
	
; =============== Act_BigCoin_Move ===============
; This subroutine contains the movement code for the big coin.
;
; This bounces the current actor with a constant jump speed.
; It could be used for other actors as well, as long as they use sActSetYSpeed_High.
Act_BigCoin_Move:
	;--
	;
	; Before moving, check if we're touching solid ground.
	;
	
	; If we're moving up we can't be touching the ground
	ld   a, [sActSetYSpeed_High]
	bit  7, a							; Is the coin moving up? (MSB set)
	jr   nz, .move						; If so, skip this
	
	call ActColi_GetBlockId_Ground		; Get block ID for what's below
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is this a solid block?
	jr   nz, .onGround					; If so, jump
	;--
	
.move:
	
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown					; Move down by that
	
	; Every 4 frames increase the downwards speed
	ld   a, [sActSetTimer]
	and  a, $03
	jr   nz, .end
	ld   a, [sActSetYSpeed_Low]
	add  $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00
	ld   [sActSetYSpeed_High], a
	
	jr   .end
.onGround:
	; We hit the ground, so we should bounce up again.
	; Unlike normal coins, the 100-coin bounces up at the same speed.
	
	; This part is very similar to Act_PouncerDrop_Drop.onGround.

	; [TCRF] Impossible condition. 
	;        The upwards movement speed is set as -$04 when bouncing, so it's impossible
	;        to reach a downwards speed of $06.
	;		 Maybe big coins were found directly outside boxes at one point?
	ld   a, [sActSetYSpeed_Low]
	cp   a, $06							; YSpeed < $06?
	jr   c, .playLowBounceSFX			; If so, skip this
	
	;--
	; [TCRF] Unreachable functionality.
	;        The big coin is meant to trigger a screen shake when it hits the ground at high speed.
	
	mSetScreenShakeFor8
	
	ld   a, SFX4_02	; Play alternate SFX
	ld   [sSFX4Set], a
	
	; Align actor to Y block grid 
	; (curious this isn't done in .setUpBounce, when it is in Act_PouncerDrop_Drop)
	ld   a, [sActSetY_Low]				
	and  a, $F0
	ld   [sActSetY_Low], a
	jr   .setUpBounce
	;--
.playLowBounceSFX:
	ld   a, SFX1_0B			; Reuse this when hitting the ground
	ld   [sSFX1Set], a
.setUpBounce:
	ld   bc, -$04				; Set upwards movement speed
	ld   a, c
	ld   [sActSetYSpeed_Low], a
	ld   a, b
	ld   [sActSetYSpeed_High], a
.end:
	ret
OBJLstPtrTable_BigCoinL:
	dw OBJLst_Act_BigCoin0
	dw OBJLst_Act_BigCoin0
	dw OBJLst_Act_BigCoin1
	dw OBJLst_Act_BigCoin2
	dw OBJLst_Act_BigCoin3
	dw $0000

; [TCRF] Unused animation which is like OBJLstPtrTable_BigCoinL, but in reverse,
;        meant for big coins facing right. (somehow)
;		 This is referenced in the parent table, but it never gets a chance to be used.
OBJLstPtrTable_BigCoin_Unused_R:
	dw OBJLst_Act_BigCoin3;X
	dw OBJLst_Act_BigCoin2;X
	dw OBJLst_Act_BigCoin1;X
	dw OBJLst_Act_BigCoin0;X
	dw OBJLst_Act_BigCoin0;X
	dw $0000;X

; [TCRF] This curiously references the unused animation instead of having dummy entries.
OBJLstSharedPtrTable_Act_BigCoin:
	dw OBJLstPtrTable_BigCoinL;X
	dw OBJLstPtrTable_BigCoin_Unused_R;X
	dw OBJLstPtrTable_BigCoinL;X
	dw OBJLstPtrTable_BigCoin_Unused_R;X
	dw OBJLstPtrTable_BigCoinL;X
	dw OBJLstPtrTable_BigCoin_Unused_R;X
	dw OBJLstPtrTable_BigCoinL;X
	dw OBJLstPtrTable_BigCoin_Unused_R;X

OBJLst_Act_BigCoin0: INCBIN "data/objlst/actor/bigcoin0.bin"
OBJLst_Act_BigCoin1: INCBIN "data/objlst/actor/bigcoin1.bin"
OBJLst_Act_BigCoin2: INCBIN "data/objlst/actor/bigcoin2.bin"
OBJLst_Act_BigCoin3: INCBIN "data/objlst/actor/bigcoin3.bin"
GFX_Act_BigCoin: INCBIN "data/gfx/actor/bigcoin.bin"

; =============== ActInit_Checkpoint ===============
; See also: ActInit_CoinLock
ActInit_Checkpoint:

	; Setup collision box
	ld   a, -$30
	ld   [sActSetColiBoxU], a
	ld   a, -$28
	ld   [sActSetColiBoxD], a
	ld   a, -$04
	ld   [sActSetColiBoxL], a
	ld   a, +$04
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Checkpoint
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_Checkpoint_Inactive
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Checkpoint
	call ActS_SetOBJLstSharedTablePtr
	
	; Set collision type
	ld   a, $10
	ld   [sActSetColiType], a
	
	; If a coin was already inserted, light up the checkpoint automatically
	xor  a
	ld   [sActCheckPointStatus], a
	ld   a, [sCheckpoint]
	or   a							; Already activated previously?
	ret  z							; If not, return
.activate:
	ld   a, CHECKPOINT_ACTIVE		; Otherwise, activate it
	ld   [sActCheckPointStatus], a
	
	push bc							; and light up the eyes
	ld   bc, OBJLstPtrTable_Act_Checkpoint_Active
	call ActS_SetOBJLstPtr
	pop  bc
	
	ret
	
; =============== ActInit_Checkpoint ===============
Act_Checkpoint:
	ld   a, [sActCheckPointStatus]
	and  a, $03
	rst  $28
	dw Act_Checkpoint_Inactive
	dw Act_Checkpoint_Activating
	dw Act_Checkpoint_Active
	
; =============== Act_Checkpoint_Inactive ===============
; The checkpoint waits for a 10-coin to be inserted.
Act_Checkpoint_Inactive:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_SPEC_08		; Was something thrown at (or moved over) the checkpoint?
	ret  nz						; If not, return
	
	; If the actor thrown at us wasn't a 10-coin, ignore
	mActCheckThrownId ACT_10COIN
	ret  nz
	
	ld   hl, sAct
	add  hl, de						; Offset the slot (we got DE in mActCheckThrownId)
	xor  a							; Mark slot as free
	ld   [hl], a
	ld   [sActHeld], a				; Clear any hold status (if we walked into the lock)
	ld   [sActHeldKey], a			; (not necessary here)
	ld   a, CHECKPOINT_ACTIVATING	; Activate the checkpoint
	ld   [sActCheckPointStatus], a
	
	push bc							; Set glowing eyes
	ld   bc, OBJLstPtrTable_Act_Checkpoint_Activating
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, CHECKPOINT_ACTIVATING	; Save checkpoint flag
	ld   [sCheckpoint], a
	ld   a, [sLevelId]				; and the level we saved on
	ld   [sCheckpointLevelId], a
	ld   a, SFX1_2B
	ld   [sSFX1Set], a
	ret
	
; =============== Act_Checkpoint_Inactive ===============
Act_Checkpoint_Activating:
	call ActS_IncOBJLstIdEvery8
	ld   a, [sActSetOBJLstId]
	cp   a, $02					; Is the animation over?
	ret  c						; If not, return
	
	; Otherwise, mark the checkpoint as active, for real
	ld   a, CHECKPOINT_ACTIVE
	ld   [sActCheckPointStatus], a
	
	push bc
	ld   bc, OBJLstPtrTable_Act_Checkpoint_Active
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_Checkpoint_Active ===============
Act_Checkpoint_Active:
	call ActS_IncOBJLstIdEvery8
	ld   a, LOW(OBJLstPtrTable_Act_Checkpoint_Active)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Checkpoint_Active)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
OBJLstSharedPtrTable_Act_Checkpoint:
	dw OBJLstPtrTable_Act_Checkpoint_Inactive;X
	dw OBJLstPtrTable_Act_Checkpoint_Inactive;X
	dw OBJLstPtrTable_Act_Checkpoint_Inactive;X
	dw OBJLstPtrTable_Act_Checkpoint_Inactive;X
	dw OBJLstPtrTable_Act_Checkpoint_Inactive;X
	dw OBJLstPtrTable_Act_Checkpoint_Inactive;X
	dw OBJLstPtrTable_Act_Checkpoint_Inactive;X
	dw OBJLstPtrTable_Act_Checkpoint_Inactive;X

OBJLstPtrTable_Act_Checkpoint_Inactive:
	dw OBJLst_Act_Checkpoint0
	dw $0000;X
; [TCRF] Last frame doesn't get to be played, though it's used elsewhere.
OBJLstPtrTable_Act_Checkpoint_Activating:
	dw OBJLst_Act_Checkpoint0
	dw OBJLst_Act_Checkpoint1
	dw OBJLst_Act_Checkpoint2;X
	dw $0000;X
OBJLstPtrTable_Act_Checkpoint_Active:
	dw OBJLst_Act_Checkpoint1
	dw OBJLst_Act_Checkpoint2
	dw $0000

OBJLst_Act_Checkpoint0: INCBIN "data/objlst/actor/checkpoint0.bin"
OBJLst_Act_Checkpoint1: INCBIN "data/objlst/actor/checkpoint1.bin"
OBJLst_Act_Checkpoint2: INCBIN "data/objlst/actor/checkpoint2.bin"
GFX_Act_Checkpoint: INCBIN "data/gfx/actor/checkpoint.bin"

; =============== ActInit_Puff ===============
ActInit_Puff:
	; Setup collision box
	ld   a, -$08
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$03
	ld   [sActSetColiBoxL], a
	ld   a, +$03
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Puff
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_Puff
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Puff
	call ActS_SetOBJLstSharedTablePtr
	
	; Make defeatable on all sides
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType
	
	
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer6], a
	ld   [sActSetTimer7], a
	ld   [sActPuffYSpeed], a
	ld   [sActSetTimer4], a ; Not used
	ret
	
OBJLstPtrTable_ActInit_Puff:
	dw OBJLst_Act_Puff_Idle0
	dw $0000;X
	
; =============== Act_Puff ===============
Act_Puff:;I
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActLocalRoutineId]
	cp   a, $02					; Timer4 >= $02?
	jr   nc, Act_Puff_Main		; If so, jump
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Puff_Main
	dw Act_Puff_Activate
	dw Act_Puff_Activate
	dw SubCall_ActS_StartStarKill
	dw Act_Puff_Activate_NoJump;X 	; [TCRF] If activated from below, it will puff up, but not cause the player to jump
	dw SubCall_ActS_StartDashKill
	dw Act_Puff_Main;X
	dw Act_Puff_Main;X
	dw SubCall_ActS_StartJumpDeadSameColi;X
	
Act_Puff_Main:
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is this actor on the ground?
	jr   nz, .onGround					; If so, skip
	
	; [TCRF] This actor is always on the ground, so this block is unreachable.
	;        This is also the only place sActPuffYSpeed would be used.
.unused_dropDown:
	ld   a, [sActPuffYSpeed]		; BC = sActSetYSpeed
	ld   c, a
	ld   b, $00
	call ActS_MoveDown					; Move down by that
	
	; Every 4 frames increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $03
	jr   nz, .chkRoutine
	ld   a, [sActPuffYSpeed]
	inc  a
	ld   [sActPuffYSpeed], a
	jr   .chkRoutine
	;--
	
.onGround:
	xor  a
	ld   [sActPuffYSpeed], a
.chkRoutine:
	; Check in which mode we're in.
	;
	; Modes are grouped in pairs (ie: Idle0, Idle1) which are very similar to each other.
	; The main difference between modes in a pair is about:
	; - Collision type (to avoid retriggering any effect)
	; - Collision box size
	; - Animation (aka OBJLstPtrTable)
	
	ld   a, [sActLocalRoutineId]
	and  a, $03
	rst  $28
	dw Act_Puff_IdleNoAnim
	dw Act_Puff_IdleWithAnim
	dw Act_Puff_Inflate
	dw Act_Puff_Deflate
	
; =============== Act_Puff_Activate ===============
; This subroutine causes the actor to puff up, with the player being flung up.
Act_Puff_Activate:
	ld   a, $01					; Trigger a super jump (into spikes, usually)
	ld   [sPlSuperJumpSet], a
	call HomeCall_Pl_StartJump
Act_Puff_Activate_NoJump:
	; Make intangible to avoid retriggering the effect.
	; This would also help if you could activate one from below.
	xor  a						
	ld   [sActSetColiType], a	
	ld   a, $02
	ld   [sActLocalRoutineId], a
	
	push bc
	ld   bc, OBJLstPtrTable_Act_Puff_Inflate			; Update OBJLst
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, -$14				; Increase collision box height
	ld   [sActSetColiBoxU], a
	ret
	
; =============== Act_Puff_IdleNoAnim ===============
; Idle mode without animation.
Act_Puff_IdleNoAnim:
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	call ActS_IncOBJLstIdEvery8
	ld   a, LOW(OBJLstPtrTable_Act_Puff_Idle)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Puff_Idle)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; 1/10th chance of switching to Act_Puff_IdleWithAnim.
	; This is done to make the idle animation start at random intervals.
	call Rand
	and  a, $0F
	ret  nz
	
	ld   a, PUFF_RTN_IDLEANIM
	ld   [sActLocalRoutineId], a
	
	push bc
	ld   bc, OBJLstPtrTable_Act_Puff_Wave
	call ActS_SetOBJLstPtr
	pop  bc
	
	ret
	
; =============== Act_Puff_IdleWithAnim ===============
; Idle mode with animation.
Act_Puff_IdleWithAnim:
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	call ActS_IncOBJLstIdEvery8
	
	ld   a, LOW(OBJLstPtrTable_Act_Puff_Wave)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Puff_Wave)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Display the 4 frames of animation.
	; Once we're done, return to the main idle mode.
	ld   a, [sActSetOBJLstId]
	cp   a, $04					; sActSetOBJLstId < $04?
	ret  c						; If so, return
	; Otherwise, return to routine $00
	ld   a, PUFF_RTN_IDLE
	ld   [sActLocalRoutineId], a
	push bc
	ld   bc, OBJLstPtrTable_Act_Puff_Idle
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_Puff_Inflate ===============
; Mode used when the actor is puffed up, along with Act_Puff_Deflate.
Act_Puff_Inflate:
	; Clear collision to avoid retriggering the effect
	xor  a
	ld   [sActSetColiType], a
	
	; Every 4 frames increase the anim counter
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkAnim
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.chkAnim:
	; Set OBJLst for this animation
	ld   a, LOW(OBJLstPtrTable_Act_Puff_Inflate)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Puff_Inflate)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Wait until all $0C frames are played
	ld   a, [sActSetOBJLstId]
	cp   a, $0C						; sActSetOBJLstId < $0C?
	ret  c							; If so, return
	
	; After that, switch to routine $03
	ld   a, PUFF_RTN_DEFLATE
	ld   [sActLocalRoutineId], a
	
	push bc
	ld   bc, OBJLstPtrTable_Act_Puff_Deflate
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, -$08					; Reduce height from $14 to $08
	ld   [sActSetColiBoxU], a
	ret
	
; =============== Act_Puff_Deflate ===============
; This mode mostly restores the changes made by Act_Puff_Inflate.
Act_Puff_Deflate:
	; Restore collision type
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	call ActS_IncOBJLstIdEvery8
	
	ld   a, LOW(OBJLstPtrTable_Act_Puff_Deflate)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Puff_Deflate)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	
	; Wait until all $0C frames are played
	ld   a, [sActSetOBJLstId]
	cp   a, $0C						; sActSetOBJLstId < $0C?
	ret  c							; If so, return
	
	; After that, switch to routine $00
	ld   a, $00
	ld   [sActLocalRoutineId], a
	push bc
	ld   bc, OBJLstPtrTable_Act_Puff_Idle
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
OBJLstPtrTable_Act_Puff_Idle:
	dw OBJLst_Act_Puff_Idle0
	dw $0000
OBJLstPtrTable_Act_Puff_Wave:
	dw OBJLst_Act_Puff_Idle0
	dw OBJLst_Act_Puff_Idle1
	dw OBJLst_Act_Puff_Idle0
	dw OBJLst_Act_Puff_Idle2
	dw $0000;X
OBJLstPtrTable_Act_Puff_Inflate:
	dw OBJLst_Act_Puff_Idle0
	dw OBJLst_Act_Puff_Idle0
	dw OBJLst_Act_Puff_Inflate0
	dw OBJLst_Act_Puff_Inflate0
	dw OBJLst_Act_Puff_Inflate1
	dw OBJLst_Act_Puff_Inflate1
	dw OBJLst_Act_Puff_Inflate2
	dw OBJLst_Act_Puff_Inflate2
	dw OBJLst_Act_Puff_Inflate1
	dw OBJLst_Act_Puff_Inflate2
	dw OBJLst_Act_Puff_Inflate1
	dw OBJLst_Act_Puff_Inflate2
	dw $0000;X
OBJLstPtrTable_Act_Puff_Deflate:
	dw OBJLst_Act_Puff_Inflate2
	dw OBJLst_Act_Puff_Inflate2
	dw OBJLst_Act_Puff_Inflate2
	dw OBJLst_Act_Puff_Inflate2
	dw OBJLst_Act_Puff_Inflate2
	dw OBJLst_Act_Puff_Inflate1
	dw OBJLst_Act_Puff_Inflate0
	dw OBJLst_Act_Puff_Idle0
	dw OBJLst_Act_Puff_Idle1
	dw OBJLst_Act_Puff_Idle0
	dw OBJLst_Act_Puff_Idle2
	dw OBJLst_Act_Puff_Idle0
	dw $0000;X

; [TCRF] Stun animation gets cut short since only the first frame
;        is displayed when the actor is defeated.
OBJLstPtrTable_Act_Puff_Stun:
	dw OBJLst_Act_Puff_Stun0
	dw OBJLst_Act_Puff_Stun_Unused_1;X
	dw OBJLst_Act_Puff_Stun0;X
	dw OBJLst_Act_Puff_Stun_Unused_2;X
	dw $0000;X

OBJLstSharedPtrTable_Act_Puff:
	dw OBJLstPtrTable_Act_Puff_Stun;X
	dw OBJLstPtrTable_Act_Puff_Stun;X
	dw OBJLstPtrTable_Act_Puff_Stun;X
	dw OBJLstPtrTable_Act_Puff_Stun;X
	dw OBJLstPtrTable_Act_Puff_Stun
	dw OBJLstPtrTable_Act_Puff_Stun;X
	dw OBJLstPtrTable_Act_Puff_Stun;X
	dw OBJLstPtrTable_Act_Puff_Stun;X

OBJLst_Act_Puff_Idle0: INCBIN "data/objlst/actor/puff_idle0.bin"
OBJLst_Act_Puff_Idle1: INCBIN "data/objlst/actor/puff_idle1.bin"
OBJLst_Act_Puff_Idle2: INCBIN "data/objlst/actor/puff_idle2.bin"
OBJLst_Act_Puff_Inflate0: INCBIN "data/objlst/actor/puff_inflate0.bin"
OBJLst_Act_Puff_Inflate1: INCBIN "data/objlst/actor/puff_inflate1.bin"
OBJLst_Act_Puff_Inflate2: INCBIN "data/objlst/actor/puff_inflate2.bin"
OBJLst_Act_Puff_Stun0: INCBIN "data/objlst/actor/puff_stun0.bin"
OBJLst_Act_Puff_Stun_Unused_1: INCBIN "data/objlst/actor/puff_stun_unused_1.bin"
OBJLst_Act_Puff_Stun_Unused_2: INCBIN "data/objlst/actor/puff_stun_unused_2.bin"
GFX_Act_Puff: INCBIN "data/gfx/actor/puff.bin"

; =============== ActInit_LavaBubble ===============
ActInit_LavaBubble:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$0E
	ld   [sActSetColiBoxU], a
	ld   a, -$02
	ld   [sActSetColiBoxD], a
	ld   a, -$06
	ld   [sActSetColiBoxL], a
	ld   a, +$06
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_LavaBubble
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_LavaBubble
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_LavaBubble
	call ActS_SetOBJLstSharedTablePtr
	
	; Touching a fireball should hurt on all sides, obviously
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer6], a
	ld   [sActSetTimer2], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ld   a, $50							; Wait $50 frames before jumping
	ld   [sActLavaBubbleJumpDelay], a
	ret
	
; [POI] This "preview animation" is only visible in debug freeroam mode.
;       Well, everything under OBJLstPtrTable_ActInit is only technically visible in debug,
;       but for the lava bubble it's particularly noticeable since it isn't visible at first in normal gameplay.
;       As soon as the game is unpaused, the lava bubble hides itself.
OBJLstPtrTable_ActInit_LavaBubble:
	dw OBJLst_Act_LavaBubble0
	dw $0000;X
	
; =============== Act_LavaBubble ===============
Act_LavaBubble:
	; There's no point to this, since they are all the same!
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_LavaBubble_Main
	dw Act_LavaBubble_Main;X
	dw Act_LavaBubble_Main;X
	dw Act_LavaBubble_Main
	dw Act_LavaBubble_Main;X
	dw Act_LavaBubble_Main;X
	dw Act_LavaBubble_Main;X
	dw Act_LavaBubble_Main
	dw Act_LavaBubble_Main
; =============== Act_LavaBubble_Wait ===============
; This subroutine is called when the lava bubble is waiting to jump out the lava.
; Until it jumps out, it will be invisible and intangible.
Act_LavaBubble_Wait:
	xor  a						; Clear collision
	ld   [sActSetColiType], a
	mActS_SetBlankFrame			; Hide
	ld   a, [sActLavaBubbleJumpDelay]	; TimeLeft--;
	dec  a
	ld   [sActLavaBubbleJumpDelay], a
	or   a						; Did the timer elapse?
	ret  nz						; If not, return
.startJump:
	; Otherwise, set the jump properties
	mActSetYSpeed -$05			; 5px/frame speed
	xor  a						; Reset timer
	ld   [sActSetTimer], a
	ld   a, SFX4_11				; Play lava SFX
	ld   [sSFX4Set], a
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI				; Deal damage on touch				
	ld   [sActSetColiType], a
	ret
; =============== Act_LavaBubble_Main ===============
Act_LavaBubble_Main:
	call ActS_IncOBJLstIdEvery8
	
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a

	ld   a, [sActLavaBubbleJumpDelay]
	or   a							; Are we still waiting to jump out?
	jr   nz, Act_LavaBubble_Wait	; If so, continue to wait
	
.chkJump:
	ld   a, LOW(OBJLstPtrTable_Act_LavaBubble)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_LavaBubble)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	call Act_LavaBubble_ChkJump
	ret
	
; =============== Act_LavaBubble_ChkJump ===============
; This subroutine handles the checks before doing the jump arc of a lava bubble.
Act_LavaBubble_ChkJump:
	ld   a, [sActSetYSpeed_High]
	bit  7, a						; Are we moving up? (MSB set)
	jr   nz, .jump					; If so, skip
	
	; If the lava bubble went back into lava, end the jump and hide it
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSpikeBlock
	or   a							; Is the actor over a lava(/spike) block?
	jr   nz, .endJump				; If so, jump
	
	jr   .jump
.jump:
	call ActS_FallDownEvery8
	ret
	
.endJump:
	mActS_SetBlankFrame				; Hide sprite
	ld   a, [sActSetY_Low]
	and  a, $F0						; Align to Y block (we always want it to start at the same point)
	ld   [sActSetY_Low], a
	ld   a, $50						; Wait $50 frames before jumping
	ld   [sActLavaBubbleJumpDelay], a
	ld   a, SFX4_10
	ld   [sSFX4Set], a
	ret
OBJLstPtrTable_Act_LavaBubble:
	dw OBJLst_Act_LavaBubble0
	dw OBJLst_Act_LavaBubble1
	dw OBJLst_Act_LavaBubble2
	dw $0000
OBJLstSharedPtrTable_Act_LavaBubble:
	dw OBJLstPtrTable_Act_LavaBubble;X
	dw OBJLstPtrTable_Act_LavaBubble;X
	dw OBJLstPtrTable_Act_LavaBubble;X
	dw OBJLstPtrTable_Act_LavaBubble;X
	dw OBJLstPtrTable_Act_LavaBubble;X
	dw OBJLstPtrTable_Act_LavaBubble;X
	dw OBJLstPtrTable_Act_LavaBubble;X
	dw OBJLstPtrTable_Act_LavaBubble;X

OBJLst_Act_LavaBubble0: INCBIN "data/objlst/actor/lavabubble0.bin"
OBJLst_Act_LavaBubble1: INCBIN "data/objlst/actor/lavabubble1.bin"
OBJLst_Act_LavaBubble2: INCBIN "data/objlst/actor/lavabubble2.bin"
GFX_Act_LavaBubble: INCBIN "data/gfx/actor/lavabubble.bin"

; =============== ActInit_TreasureChestLid ===============
ActInit_TreasureChestLid:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$0A
	ld   [sActSetColiBoxU], a
	ld   a, +$1C
	ld   [sActSetColiBoxD], a
	ld   a, -$17
	ld   [sActSetColiBoxL], a
	ld   a, +$06
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_TreasureChestLid
	call ActS_SetCodePtr
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_TreasureChestLid
	call ActS_SetOBJLstSharedTablePtr
	
	;--
	; [TCRF] Asserts that a valid treasure ID was specified in the room definition.
	;        If none was specified, it will infinite loop.
	ld   a, [sActTreasureId]
	and  a, $0F
	jr   z, .assert_fail
	;--
	
	; Offset the table with treasure bit masks
	ld   hl, Level_TreasureCompletionMask_B0F	; HL = Table
	ld   d, $00			; DE = sActTreasureId * 2
	add  a
	ld   e, a
	add  hl, de			; Offset the table
	
	; Read out the bitmask with the bit number for the treasure
	ldi  a, [hl]		; BC = Bitmask
	ld   c, a
	ld   b, [hl]
	
	; AND the mask over the bitmask of the already collected treasure.
	; If the bit specified in the treasure mask is already set in sTreasures,
	; we've collected the treasure already, so open the lid.
	
	ld   a, [sTreasures]	; C = sTreasures_Low & TreasureMask_Low
	and  a, c
	ld   c, a
	ld   a, [sTreasures+1]
	and  a, b				; A = sTreasures_High & TreasureMask_High
	or   a, c				; Is the bit already set?
	jr   z, .isClosed		; If not, jump
	
.isOpen:
	; Set initial OBJLst when open
	push bc
	ld   bc, OBJLstPtrTable_Act_TreasureChestLid_Open
	call ActS_SetOBJLstPtr
	pop  bc
	
	xor  a						; Make intangible
	ld   [sActSetColiType], a
	ld   a, $01					; Mark as open
	ld   [sActLocalRoutineId], a
	ret
.isClosed:
	; Set initial OBJLst when closed
	push bc
	ld   bc, OBJLstPtrTable_Act_TreasureChestLid_Closed
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, ACTCOLI_TOPSOLIDHIT		; Dash to open
	ld   [sActSetColiType], a
	
	xor  a							; Mark as closed
	ld   [sActLocalRoutineId], a
	ld   a, BGM_TREASURE			; Play special BGM
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	ret
; [TCRF] See assert note above.
.assert_fail: jr .assert_fail

; =============== Level_TreasureCompletionMask_B0F ===============
; Copy of Level_TreasureCompletionMask, local to this bank.
; Table with sTreasures bitmasks, indexed by treasure id.
; Use to check of a treasure was collected.
Level_TreasureCompletionMask_B0F:
	dw %0000000000000000 ; (none)
	dw %0000000000000010 ; C
	dw %0000000000000100 ; I
	dw %0000000000001000 ; F
	dw %0000000000010000 ; O
	dw %0000000000100000 ; A
	dw %0000000001000000 ; N
	dw %0000000010000000 ; H
	dw %0000000100000000 ; M
	dw %0000001000000000 ; L
	dw %0000010000000000 ; K
	dw %0000100000000000 ; B
	dw %0001000000000000 ; D
	dw %0010000000000000 ; G
	dw %0100000000000000 ; J
	dw %1000000000000000 ; E

OBJLstPtrTable_Act_TreasureChestLid_Closed:
	dw OBJLst_Act_TreasureChestLid_Closed
	dw $0000;X
OBJLstPtrTable_Act_TreasureChestLid_Open:
	dw OBJLst_Act_TreasureChestLid_Open
	dw $0000;X
	
; =============== Act_TreasureChestLid ===============
Act_TreasureChestLid:
	ld   a, [sActLocalRoutineId]
	and  a, $01
	rst  $28
	dw Act_TreasureChestLid_Closed
	dw Act_TreasureChestLid_Open
	
; =============== Act_TreasureChestLid_Closed ===============
Act_TreasureChestLid_Closed:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_03			; Did we fire on the lid?
	jr   z, .openLid			; If so, jump
	cp   a, ACTRTN_05			; Did we dash against the lid?
	jr   z, .openLid			; If so, jump
	ret
.openLid:
	push bc
	ld   bc, OBJLstPtrTable_Act_TreasureChestLid_Open	; Set opened frame
	call ActS_SetOBJLstPtr
	pop  bc
	
	xor  a						; Clear collision
	ld   [sActSetColiType], a
	ld   a, $01					; Set new routine
	ld   [sActLocalRoutineId], a
	call Act_TreasureChestLid_SpawnTreasure				; Spawn treasure
	ret
	
; =============== Act_TreasureChestLid_Open ===============
Act_TreasureChestLid_Open:
	ld   a, LOW(OBJLstPtrTable_Act_TreasureChestLid_Open)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_TreasureChestLid_Open)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetColiType], a
	ret
	
; =============== Act_TreasureChestLid_SpawnTreasure ===============
; Spawns the treasure chest after opening the lid.
Act_TreasureChestLid_SpawnTreasure:
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
	ret ; We can't get here
.slotFound:
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_Treasure
	
	ld   a, $02					; Enabled
	ldi  [hl], a
	ld   a, [sActSetX_Low]		; X
	ldi  [hl], a
	ld   a, [sActSetX_High]
	ldi  [hl], a
	ld   a, [sActSetY_Low]		; Y
	ldi  [hl], a
	ld   a, [sActSetY_High]
	ldi  [hl], a
	
	ld   a, [sActTreasureId]	; Collision type (special for treasure)
	ldi  [hl], a
	
	
	xor  a
	ldi  [hl], a				; Coli box U
	ldi  [hl], a				; Coli box D
	ldi  [hl], a				; Coli box L
	ldi  [hl], a				; Coli box R
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_Treasure)		; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_Treasure)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Dir
	ldi  [hl], a				; OBJLst ID
	
	; Actor ID
	; This does an assuption on the actor group definition.
	ld   a, [sActSetId]			; <actorId of lid> + $02
	add  $02
	ldi  [hl], a
	
	xor  a						; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_ActInit_Treasure)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_ActInit_Treasure)
	ldi  [hl], a	
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2 (sActTreasurePopUpTimer)
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
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_Treasure)		; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_Treasure)
	ldi  [hl], a
	ret
	
OBJLstSharedPtrTable_Act_TreasureChestLid:
	dw OBJLstPtrTable_Act_TreasureChestLid_Closed;X
	dw OBJLstPtrTable_Act_TreasureChestLid_Closed;X
	dw OBJLstPtrTable_Act_TreasureChestLid_Closed;X
	dw OBJLstPtrTable_Act_TreasureChestLid_Closed;X
	dw OBJLstPtrTable_Act_TreasureChestLid_Closed;X
	dw OBJLstPtrTable_Act_TreasureChestLid_Closed;X
	dw OBJLstPtrTable_Act_TreasureChestLid_Closed;X
	dw OBJLstPtrTable_Act_TreasureChestLid_Closed;X

OBJLst_Act_TreasureChestLid_Closed: INCBIN "data/objlst/actor/treasurechestlid_closed.bin"
OBJLst_Act_TreasureChestLid_Open: INCBIN "data/objlst/actor/treasurechestlid_open.bin"
GFX_Act_TreasureChestLid: INCBIN "data/gfx/actor/treasurechestlid.bin"

; =============== ActInit_Treasure ===============
ActInit_Treasure:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, $F6
	ld   [sActSetColiBoxU], a
	ld   a, $FE
	ld   [sActSetColiBoxD], a
	ld   a, $FC
	ld   [sActSetColiBoxL], a
	ld   a, $04
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Treasure
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_Treasure
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Treasure
	call ActS_SetOBJLstSharedTablePtr
	
	; Treasure ID doubles as collision type (more or less).
	; The specific treasure you get once you touch it does depend on the collision type.
	ld   a, [sActTreasureId]
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	xor  a
	ld   [sActTreasurePopUpTimer], a
	
	ld   bc, +$10			; Place inside the chest (for the pop up anim)
	call ActS_MoveDown
	ld   bc, -$08			; Chest is 2 blocks large, this spawns on the right block, so move half a block left
	call ActS_MoveRight
	
	; Spawn shine helper
	call Act_Treasure_SpawnShine
	
	; Prevent from respawning, since it's spawned by another actor (treasure chest lid)
	; and that actor respawns already
	ld   a, [sActSetId]		
	set  ACTB_NORESPAWN, a	
	ld   [sActSetId], a
	ret
	
; All treasures use the same sprite mappings (they are all 2x2 anyway, with the graphics loaded at the same address...)
OBJLstPtrTable_Act_Treasure:
	dw OBJLst_Act_Treasure0
	dw OBJLst_Act_Treasure0
	dw OBJLst_Act_Treasure1
	dw $0000
OBJLstPtrTable_ActInit_Treasure:
	dw OBJLst_Act_Treasure2
	dw $0000;X

; =============== Act_Treasure ===============
Act_Treasure:
	;
	; Handle the pop-up animation, where it rises from the treasure chest.
	; This ends up moving the treasure 1 block above (the same amount specified in the init code).
	;
	ld   a, [sActTreasurePopUpTimer]
	cp   a, $40					; Have we moved all the way?
	jr   nc, .anim				; If so, skip
	inc  a						; Timer++
	ld   [sActTreasurePopUpTimer], a
	
	; Move treasure up at 0.25px/frame
	and  a, $03
	jr   nz, .chkColi
	ld   bc, $FFFF
	call ActS_MoveDown
	jr   .chkColi
	
.anim:
	;
	; Once the treasure rises from the chest, animate it.
	;
	
	ld   a, LOW(OBJLstPtrTable_Act_Treasure)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Treasure)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Every 4 frames increase the anim counter
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkColi
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	
.chkColi:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_SPEC_09			; Did we grab the treasure?
	ret  nz							; If not, return
	
	; Otherwise...
	ld   a, $01						; Mark a treasure as held (so we can't throw it)
	ld   [sActHeldTreasure], a
	ld   a, LOW(OBJLstPtrTable_Act_Treasure)			; ?
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Treasure)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	jp   SubCall_ActS_StartHeldForce
	
; =============== Act_Treasure_SpawnShine ===============
; Spawns the actor handling the shiny aura around the actual treasure.
Act_Treasure_SpawnShine:
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
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_TreasureShine
	
	ld   a, $02				; Enabled
	ldi  [hl], a
	
	; NOTE: These are initial values -- the actor itself will track the treasure's position
	ld   a, [sActSetX_Low]	; X = sActSetX
	ldi  [hl], a
	ld   a, [sActSetX_High]	
	ldi  [hl], a
	ld   a, [sActSetY_Low]	; Y = sActSetY
	ldi  [hl], a
	ld   a, [sActSetY_High]
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a			; Collision type
	ldi  [hl], a			; Coli box U
	ldi  [hl], a			; Coli box D
	ldi  [hl], a			; Coli box L
	ldi  [hl], a			; Coli box R
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_TreasureShine)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_TreasureShine)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a			; Dir
	ldi  [hl], a			; OBJLst ID
	
	ld   a, [sActSetId]		; Actor ID - same as treasure
	inc  a
	set  ACTB_NORESPAWN, a
	ldi  [hl], a
	
	xor  a					; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_ActInit_TreasureShine)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_ActInit_TreasureShine)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a			; Timer
	ldi  [hl], a			; Timer 2
	ldi  [hl], a			; Timer 3
	ldi  [hl], a			; Timer 4
	ld   a, [sActNumProc]	; Timer 5 (slot of the actor that spawned this, for tracking)
	ldi  [hl], a
	xor  a
	ldi  [hl], a			; Timer 6
	ldi  [hl], a			; Timer 7
	
	ld   a, $01				; Flags
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_TreasureShine)	; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_TreasureShine)
	ldi  [hl], a
	ret
OBJLstSharedPtrTable_Act_Treasure:
	dw OBJLstPtrTable_Act_Treasure;X
	dw OBJLstPtrTable_Act_Treasure;X
	dw OBJLstPtrTable_Act_Treasure
	dw OBJLstPtrTable_Act_Treasure
	dw OBJLstPtrTable_Act_Treasure
	dw OBJLstPtrTable_Act_Treasure
	dw OBJLstPtrTable_Act_Treasure;X
	dw OBJLstPtrTable_Act_Treasure;X

OBJLst_Act_Treasure0: INCBIN "data/objlst/actor/treasure0.bin"
OBJLst_Act_Treasure1: INCBIN "data/objlst/actor/treasure1.bin"
OBJLst_Act_Treasure2: INCBIN "data/objlst/actor/treasure2.bin"
GFX_Act_TreasureC: INCBIN "data/gfx/actor/treasurec.bin"
GFX_Act_TreasureI: INCBIN "data/gfx/actor/treasurei.bin"
GFX_Act_TreasureF: INCBIN "data/gfx/actor/treasuref.bin"
GFX_Act_TreasureO: INCBIN "data/gfx/actor/treasureo.bin"
GFX_Act_TreasureA: INCBIN "data/gfx/actor/treasurea.bin"
GFX_Act_TreasureN: INCBIN "data/gfx/actor/treasuren.bin"
GFX_Act_TreasureH: INCBIN "data/gfx/actor/treasureh.bin"
GFX_Act_TreasureM: INCBIN "data/gfx/actor/treasurem.bin"
GFX_Act_TreasureL: INCBIN "data/gfx/actor/treasurel.bin"
GFX_Act_TreasureK: INCBIN "data/gfx/actor/treasurek.bin"
GFX_Act_TreasureB: INCBIN "data/gfx/actor/treasureb.bin"
GFX_Act_TreasureD: INCBIN "data/gfx/actor/treasured.bin"
GFX_Act_TreasureG: INCBIN "data/gfx/actor/treasureg.bin"
GFX_Act_TreasureJ: INCBIN "data/gfx/actor/treasurej.bin"
GFX_Act_TreasureE: INCBIN "data/gfx/actor/treasuree.bin"

; =============== ActInit_TreasureShine ===============
; NOTE: This is not meant to be used directly in the actor layout.
;       It should only be spawned by Act_Treasure.
ActInit_TreasureShine:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$08
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$04
	ld   [sActSetColiBoxL], a
	ld   a, +$04
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_TreasureShine
	call ActS_SetCodePtr
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_TreasureShine
	call ActS_SetOBJLstSharedTablePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_TreasureShine
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Make intangible
	xor  a
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	; Like the treasure, don't respawn since it was spawned by something else
	ld   a, [sActSetId]
	set  ACTB_NORESPAWN, a
	ld   [sActSetId], a
	ret
	
OBJLstPtrTable_Act_TreasureShine:
	dw OBJLst_Act_TreasureShine0
	dw OBJLst_Act_TreasureShine1
	dw OBJLst_Act_None
	dw OBJLst_Act_None
	dw $0000

; =============== Act_TreasureShine ===============
Act_TreasureShine:
	; Every other frame increase the anim counter
	ld   a, [sTimer]
	and  a, $01
	jr   nz, .trackPos
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.trackPos:

	ld   a, LOW(OBJLstPtrTable_Act_TreasureShine)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_TreasureShine)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	;
	; Make the shine use the same position as the treasure
	;
	
	; Seek to the parent actor's slot info
	ld   a, [sActTreasureShineParentSlot]
	swap a									; DE = SlotNum *= $20
	rlca
	ld   hl, sAct							; HL = Actor area base
	ld   d, $00
	ld   e, a
	add  hl, de								; Offset it
	
	; Copy over the...
	ldi  a, [hl]							; ...active status							
	ld   [sActSet], a
	ldi  a, [hl]							; X Pos
	ld   [sActSetX_Low], a
	ldi  a, [hl]
	ld   [sActSetX_High], a
	ldi  a, [hl]							; Y Pos
	ld   [sActSetY_Low], a
	ldi  a, [hl]
	ld   [sActSetY_High], a
	ret
	
OBJLstSharedPtrTable_Act_TreasureShine:
	dw OBJLstPtrTable_Act_TreasureShine;X
	dw OBJLstPtrTable_Act_TreasureShine;X
	dw OBJLstPtrTable_Act_TreasureShine;X
	dw OBJLstPtrTable_Act_TreasureShine;X
	dw OBJLstPtrTable_Act_TreasureShine;X
	dw OBJLstPtrTable_Act_TreasureShine;X
	dw OBJLstPtrTable_Act_TreasureShine;X
	dw OBJLstPtrTable_Act_TreasureShine;X

OBJLst_Act_TreasureShine0: INCBIN "data/objlst/actor/treasureshine0.bin"
OBJLst_Act_TreasureShine1: INCBIN "data/objlst/actor/treasureshine1.bin"
GFX_Act_TreasureShine: INCBIN "data/gfx/actor/treasureshine.bin"

; =============== ActInit_TorchFlame ===============
; Decorative torch in treasure rooms.
ActInit_TorchFlame:
	; Setup collision box
	ld   a, -$08
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$04
	ld   [sActSetColiBoxL], a
	ld   a, +$04
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_TorchFlame
	call ActS_SetCodePtr
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_TorchFlame
	call ActS_SetOBJLstSharedTablePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_TorchFlame
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set blank collision type
	xor  a
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	ret
	
OBJLstPtrTable_Act_TorchFlame:
	dw OBJLst_Act_TorchFlame0
	dw OBJLst_Act_TorchFlame0
	dw OBJLst_Act_None
	dw OBJLst_Act_TorchFlame1
	dw OBJLst_Act_TorchFlame1
	dw OBJLst_Act_None
	dw $0000

; =============== Act_TorchFlame ===============
Act_TorchFlame:
	; There are two torches/room, so the actor transparency feature can't be used.
	; So the transparency's baked in the animation.
	
	; Every other frame increase the anim counter
	ld   a, [sTimer]
	and  a, $01
	jr   nz, .setOBJLst
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.setOBJLst:
	; Not sure why that's here
	ld   a, LOW(OBJLstPtrTable_Act_TorchFlame)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_TorchFlame)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	ret
	
OBJLstSharedPtrTable_Act_TorchFlame:
	dw OBJLstPtrTable_Act_TorchFlame;X
	dw OBJLstPtrTable_Act_TorchFlame;X
	dw OBJLstPtrTable_Act_TorchFlame;X
	dw OBJLstPtrTable_Act_TorchFlame;X
	dw OBJLstPtrTable_Act_TorchFlame;X
	dw OBJLstPtrTable_Act_TorchFlame;X
	dw OBJLstPtrTable_Act_TorchFlame;X
	dw OBJLstPtrTable_Act_TorchFlame;X

OBJLst_Act_TorchFlame0: INCBIN "data/objlst/actor/torchflame0.bin"
OBJLst_Act_TorchFlame1: INCBIN "data/objlst/actor/torchflame1.bin"
GFX_Act_TorchFlame: INCBIN "data/gfx/actor/torchflame.bin"

; =============== ActInit_Spark ===============
ActInit_Spark:
	; Setup collision box
	ld   a, -$0A
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, $FC
	ld   [sActSetColiBoxL], a
	ld   a, $04
	ld   [sActSetColiBoxR], a
	; Setup main code
	ld   bc, SubCall_Act_Spark
	call ActS_SetCodePtr
	;--
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_Spark
	call ActS_SetOBJLstPtr
	pop  bc
	;--
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Spark
	call ActS_SetOBJLstSharedTablePtr
	
	; Set the collision type, and save it as default.
	mActColiMask ACTCOLI_DAMAGE,ACTCOLI_DAMAGE,ACTCOLI_DAMAGE,ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	; Reset all timers
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSetTimer2], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSparkAntiClockwise], a
	ld   [sActLocalRoutineId], a
	ld   [sActSparkStepsLeft], a
	ld   [sActSparkDir], a
	ret
OBJLstPtrTable_ActInit_Spark:
	dw OBJLst_Act_Spark0
	dw $0000;X
; =============== Act_Spark ===============
Act_Spark:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Spark_Main
	dw Act_Spark_Main;X
	dw SubCall_ActS_StartGroundPoundStun;X
	dw SubCall_ActS_StartStarKill;X
	dw SubCall_ActS_OnPlColiBelow;X
	dw Act_Spark_Main;X
	dw Act_Spark_Main;X
	dw Act_Spark_Main
	dw SubCall_ActS_StartJumpDeadSameColi
; =============== Act_Spark_Main ===============
Act_Spark_Main:
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a
	;--
	;
	; This actor normally moves along solid blocks.
	; After doing a ground pound, it should drop down.
	;
	
	ld   a, [sActSetYSpeed_Low]
	or   a							; Is the actor falling down?
	jp   nz, Act_Spark_Drop			; If so, jump
	ld   a, [sScreenShakeTimer]
	or   a							; Is a screen shake active?
	jr   z, .incAnim				; If not, skip
.setDrop:
	; Otherwise, make the actor drop to the ground
	ld   a, $01
	ld   [sActSetYSpeed_Low], a
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jp   z, Act_Spark_Drop
	;--
	ret
.incAnim:
	xor  a							; Reset drop speed
	ld   [sActSetYSpeed_Low], a
	; Every 4 frames increase the anim frame
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .move
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.move:
	; Weird that it's being set all the time (it's also the only OBJLst this actor has)
	ld   a, LOW(OBJLstPtrTable_Act_Spark)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Spark)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Every other execution frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	; sActSparkStepsLeft determines how many frames to move in a certain direction
	; before checking for solid collision again.
	; This is normally set to $08 and decrements for every 1px movement,
	; but it can be set to $00 prematurely if a solid block is reached.
	; Since there's no Y alignment, this does mean the path taken isn't completely aligned to the actual block collision.
	ld   a, [sActSparkStepsLeft]
	or   a							; Did it expire?
	call z, Act_Spark_ChkColi		; If so, check for a new direction
	ld   a, [sActSparkStepsLeft]
	or   a						
	call nz, Act_Spark_Move			; If not, continue moving along the path
	ret
	
Act_Spark_TurnAntiClockwise:
	ld   a, [sActSparkStepsLeft]
	or   a
	ret  nz
	
	; Turn anti clockwise to the next direction
	ld   a, [sActSparkDir]	; sActSparkDir = sActSparkDir+1 % 4
	inc  a
	and  a, $03
	ld   [sActSparkDir], a
	
	; Make actor move continuously $10 times.
	; This "happens" to be the width and height of a block.
	ld   a, BLOCK_WIDTH					
	ld   [sActSparkStepsLeft], a
	xor  a							; Clear "new" indicator
	ld   [sActSparkAntiClockwise], a
	ret
Act_Spark_TurnClockwise:
	; Turn clockwise to the next direction
	ld   a, [sActSparkDir]	; sActSparkDir = sActSparkDir-1 % 4
	dec  a
	and  a, $03
	ld   [sActSparkDir], a
	ret
	
; =============== Act_Spark_ChkColi ===============
; Handles BG collision detection.
; This actor continues moving until it hits a solid wall.
; Since the first direction value is $00, it will first try to turn anti-clockwise.
Act_Spark_ChkColi:
	ld   a, [sActSparkDir]
	rst  $28
	dw Act_Spark_ChkLeft
	dw Act_Spark_ChkDown
	dw Act_Spark_ChkRight
	dw Act_Spark_moveD
Act_Spark_ChkLeft:
	; All of these follow this template:
	; - Check if there's a solid block in front of the actor (relative to the current direction)
	;  - If there is, turn clockwise
	; - Check if there's anything to the left of the actor (relative to the current direction)
	;  - If there is, continue with the current direction
	;  - If there isn't turn anticlockwise
	;
	; [POI] Note that this is incomplete collision detection to save time -- for example if there's a solid
	;		block in front of the actor, it will always move clockwise, even if a solid block is there.
	;       This means the room layout needs to account for this.
	;
	; 		Also, these subroutines make use of the ActColi "2" variants for some reason,
	;		which check 1px further than the normal subroutines.
	
	; Try clockwise (with a solid block)
	call ActColi_GetBlockId_LowL2		
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block on the left?
	jp   nz, Act_Spark_TurnClockwise	; If so, start moving upwards (clockwise) on that block
	
	; Try continuing
	call ActColi_GetBlockId_Ground2
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block below?
	jp   nz, Act_Spark_ContinueMove		; If so, we can't move down, so we can only continue moving on the same direction
	
	; Anticlockwise
	; Otherwise we aren't on the ground anymore, so start moving downwards (anticlockwise)
	ld   a, $08							
	ld   [sActSparkStepsLeft], a
	ld   [sActSparkAntiClockwise], a
	ret
Act_Spark_ChkDown:
	; Try clockwise
	call ActColi_GetBlockId_Ground2
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block below?
	jr   nz, Act_Spark_TurnClockwise	; If so, start moving left
	
	; Try continuing
	call ActColi_GetBlockId_LowR2
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block on the right?
	jr   nz, Act_Spark_ContinueMove		; If so, continue moving
	
	; Anticlockwise
	ld   a, $08							; Otherwise start moving right
	ld   [sActSparkStepsLeft], a
	ld   [sActSparkAntiClockwise], a
	ret
Act_Spark_ChkRight:
	; Try clockwise
	call ActColi_GetBlockId_LowR2
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block on the right?
	jp   nz, Act_Spark_TurnClockwise	; If so, start moving down
	
	; Try continuing
	call ActColi_GetBlockId_Top2
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block on the top?
	jr   nz, Act_Spark_ContinueMove		; If so, continue moving
	
	; Anticlockwise
	ld   a, $08							; Otherwise, start moving up
	ld   [sActSparkStepsLeft], a
	ld   [sActSparkAntiClockwise], a
	ret
Act_Spark_moveD:
	; Try clockwise
	call ActColi_GetBlockId_Top2
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block above?
	jp   nz, Act_Spark_TurnClockwise	; If not, start moving right
	; Try continuing
	call ActColi_GetBlockId_LowL2
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block on the left?
	jr   nz, Act_Spark_ContinueMove		; If so, continue moving upwards on that block
	
	; Anticlockwise
	ld   a, $08							; Otherwise, start moving left
	ld   [sActSparkStepsLeft], a
	ld   [sActSparkAntiClockwise], a
	ret
Act_Spark_ContinueMove:
	; Move for another pixel in the same direction before checking for collision again
	; This seems weird... why not set 8px?
	ld   a, $01
	ld   [sActSparkStepsLeft], a
	xor  a
	ld   [sActSparkAntiClockwise], a
	ld   [sActSetTimer2], a				
	ret
Act_Spark_Move:
	; Decrement the amount of steps left
	ld   a, [sActSparkStepsLeft]
	dec  a
	ld   [sActSparkStepsLeft], a
	
	; If we were set to turn anti-clockwise (incrementing the direction value),
	; perform the change here.
	ld   a, [sActSparkAntiClockwise]	
	or   a									; Should we turn?
	call nz, Act_Spark_TurnAntiClockwise	; If so, jump
	
	; Move depending on the direction we're going
	ld   a, [sActSparkDir]
	cp   a, $00				
	jp   z, .left			
	cp   a, $01
	jp   z, .down
	cp   a, $02
	jp   z, .right
	cp   a, $03
	jp   z, .up
	ret ; We never get here
.left:
	ld   bc, -$01
	call ActS_MoveRight
	ret
.down:
	ld   bc, +$01
	call ActS_MoveDown
	ret
.right:
	ld   bc, +$01
	call ActS_MoveRight
	ret
.up:
	ld   bc, -$01
	call ActS_MoveDown
	ret
; =============== Act_Spark_Drop ===============
; Makes the actor drop to the ground at an increasing speed.
Act_Spark_Drop:
	ld   a, [sActSetYSpeed_Low]	; BC = sActSetYSpeed_Low
	ld   b, $00
	ld   c, a
	call ActS_MoveDown				; Move down by that

	; If the actor's on top of a solid block, end this
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jp   nz, .landed
	
	; Otherwise increase the drop speed every 4 frames
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, [sActSetYSpeed_Low]
	inc  a
	ld   [sActSetYSpeed_Low], a
	ret
.landed:
	ld   a, [sActSetY_Low]			; Align to Y block
	and  a, $F0
	ld   [sActSetY_Low], a
	xor  a							; Reset vars
	ld   [sActSetYSpeed_Low], a
	ld   [sActSparkDir], a
	ld   [sActSparkAntiClockwise], a
	ld   [sActSparkStepsLeft], a
	ret
	
; =============== OBJLstPtrTable_Act_Spark ===============
OBJLstPtrTable_Act_Spark:
	dw OBJLst_Act_Spark0
	dw OBJLst_Act_Spark1
	dw OBJLst_Act_Spark2
	dw OBJLst_Act_Spark3
	dw $0000

OBJLstSharedPtrTable_Act_Spark:
	dw OBJLstPtrTable_Act_Spark;X
	dw OBJLstPtrTable_Act_Spark;X
	dw OBJLstPtrTable_Act_Spark;X
	dw OBJLstPtrTable_Act_Spark;X
	dw OBJLstPtrTable_Act_Spark
	dw OBJLstPtrTable_Act_Spark;X
	dw OBJLstPtrTable_Act_Spark;X
	dw OBJLstPtrTable_Act_Spark;X

; [TCRF] The unused frames are variations of existing frames with an alternate palette
OBJLst_Act_Spark0: INCBIN "data/objlst/actor/spark0.bin"
OBJLst_Act_Spark1: INCBIN "data/objlst/actor/spark1.bin"
OBJLst_Act_Spark_Unused_Alt3: INCBIN "data/objlst/actor/spark_unused_alt3.bin"
OBJLst_Act_Spark2: INCBIN "data/objlst/actor/spark2.bin"
OBJLst_Act_Spark_Unused_Alt1: INCBIN "data/objlst/actor/spark_unused_alt1.bin"
OBJLst_Act_Spark3: INCBIN "data/objlst/actor/spark3.bin"
GFX_Act_Spark: INCBIN "data/gfx/actor/spark.bin"

; =============== ActInit_Seal ===============
ActInit_Seal:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$08
	ld   [sActSetColiBoxU], a
	ld   a, +$08
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Seal
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_ActInit_Seal
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Seal
	call ActS_SetOBJLstSharedTablePtr
	
	; The actor carries the spear pointing below, so that's the side which deals damage.
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSealTurnTimer], a
	ld   [sActSetYSpeed_Low], a		; Not used
	ld   [sActSetYSpeed_High], a	; Not used
	ld   [sActLocalRoutineId], a
	ld   a, $1E
	ld   [sActSealRangeCheckDelay], a
	xor  a
	ld   [sActSetTimer7], a
	ret
; =============== OBJLstPtrTable_ActInit_Seal ===============
OBJLstPtrTable_ActInit_Seal:
	dw OBJLst_Act_Seal_IdleL0
	dw $0000

; =============== Act_Seal ===============
Act_Seal:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Seal_Main
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartStarKill;X
	dw SubCall_ActS_StartJumpDead
	dw SubCall_ActS_StartDashKill
	dw Act_Seal_Main;X
	dw Act_Seal_Main
	dw SubCall_ActS_StartJumpDead;X
	
; =============== Act_Seal_Main ===============
Act_Seal_Main:
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_Seal_Idle
	dw Act_Seal_Track
	dw Act_Seal_Shoot
	dw Act_Seal_Retreat
	
; =============== Act_Seal_SwitchToIdle ===============
; Makes the seal switch back to idle mode.
Act_Seal_SwitchToIdle:
	; Reset to the main mode
	xor  a
	ld   [sActLocalRoutineId], a
	
	; Restore the original collision options (same as ActInit_Seal), in case
	; this was called from the "retreat" mode, which sets a different collision flag
	; (as there's no visible spear in those sprites).
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	ld   a, $1E					; Reset throw delay
	ld   [sActSealRangeCheckDelay], a
	
	xor  a						; Reset anim
	ld   [sActSetOBJLstId], a
	ld   [sActSealTurnTimer], a
	ret
	
; =============== Act_Seal_Idle ===============
; Mode $00: The seal moves back and forth until the player gets "close enough".
; The spear points down below in this mode.
Act_Seal_Idle:
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
.chkRange:
	; 
	; Check if the player is in the horizontal range of the actor.
	; When the player is in range, the actor starts moving towards the player.
	;
	; This range is a ridiculous $4A*2 area around the actor -- the only
	; way to avoid activating it is making sure the actor stands at the edge
	; of the screen, assuming the player is at the center.
	;
	; In other words, most of the time this check succeeds very quickly.
	;
	; To save time we're checking this every $1E frames.
	;
	ld   a, [sActSealRangeCheckDelay]
	or   a						; Are we skipping this check?
	jr   nz, .chkMoveH			; If so, jump
	
	ld   a, [sActSetX_Low]		; HL = Actor X
	ld   l, a
	ld   a, [sActSetX_High]
	ld   h, a
	ld   a, [sPlX_Low]			; BC = Player X
	ld   c, a
	ld   a, [sPlX_High]
	ld   b, a
	call ActS_GetPlDistance		; HL = Distance between
	ld   a, l
	cp   a, $4A					; HL < $4A?
	jp   c, Act_Seal_SwitchToTracking	; If so, the player is in range
	ld   a, $1E							; Otherwise continue moving
	ld   [sActSealRangeCheckDelay], a
	ret
	
.chkMoveH:
	;
	; All the other $1D frames we're moving the actor horizontally at 0.5px/frame.
	; After $32 frames, we're turning in the other direction.
	;
	ld   a, [sActSealRangeCheckDelay]		; RangeCheckDelay--
	dec  a
	ld   [sActSealRangeCheckDelay], a
	
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	; If we've somehow gone past $32 frames and we're still here, turn direction
	ld   a, [sActSealTurnTimer]		; Timer++
	inc  a
	ld   [sActSealTurnTimer], a
	cp   a, $32					; Timer >= $32?
	jr   nc, .turn				; If so, jump
	
	; Otherwise move horizontally as normal
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, .moveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, .moveLeft
	ret
	
.turn:
	ld   a, [sActSetDir]		; Turn direction
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	xor  a						; Move for other $32 frames in the new direction
	ld   [sActSealModeTimer], a
	ld   a, $1E					; Wait $1E frames before checking the player's pos
	ld   [sActSealRangeCheckDelay], a
	ld   a, SFX1_29		; Play SFX
	ld   [sSFX1Set], a
	ret

; =============== .moveRight ===============
; Moves the actor right 1px until it reaches a solid block.
.moveRight:
	; Set idle swim anim
	ld   a, LOW(OBJLstPtrTable_Act_Seal_IdleR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Seal_IdleR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	; If there's a solid block in the way, turn immediately
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a
	jr   nz, .turn
	;--
	ld   bc, +$01
	call ActS_MoveRight
	ret
	
; =============== .moveLeft ===============
; Moves the actor left 1px until it reaches a solid block.
.moveLeft:
	; Set idle swim anim
	ld   a, LOW(OBJLstPtrTable_Act_Seal_IdleL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Seal_IdleL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	; If there's a solid block in the way, turn immediately
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a
	jr   nz, .turn
	;--
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
; =============== Act_Seal_SwitchToTracking ===============
Act_Seal_SwitchToTracking:
	ld   a, SEAL_RTN_TRACK			; Next mode
	ld   [sActLocalRoutineId], a
	xor  a							; Reset anim / mode timer
	ld   [sActSetOBJLstId], a
	ld   [sActSealModeTimer], a
	ret
	
; =============== Act_Seal_Track ===============
; Mode $01: Tracks the player both horizontally and vertically for a bit before shooting.
Act_Seal_Track:
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	;
	; Move horizontally at 0.5px/frame towards the player until we either:
	; - Get out of the actor's horz range of $50*2
	;   (switches back to the idle mode)
	; - $5A frames pass in this mode
	;   (the seal shoots the spear)
	;
	
	
	;
	; Increase the timer. When it reaches the limit, shoot.
	;
	ld   a, [sActSealModeTimer]		; Timer++
	inc  a
	ld   [sActSealModeTimer], a
	cp   a, $5A						; Timer >= $5A?
	jp   nc, Act_Seal_SwitchToShoot	; If so, shoot
	
	
	;
	; Get the player's horizontal distance every other frame and save it to HL.
	;
	
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	; Get the horizontal distance between player and actor
	ld   a, [sActSetX_Low]		; HL = ActorX
	ld   l, a
	ld   a, [sActSetX_High]
	ld   h, a
	ld   a, [sPlX_Low]			; BC = PlayerX
	ld   c, a
	ld   a, [sPlX_High]
	ld   b, a
	call ActS_GetPlDistance		; HL = ABS(ActorX - PlayerX)
	
	;
	; If we're out of range, return to the idle mode
	;
	ld   a, l
	cp   a, $50						; HL < $50?
	jp   nc, Act_Seal_SwitchToIdle	; If so, jump
	
	;
	; Track the player's direction, except when the player's horizontal position 
	; is very close to the actor's (< $08 px).
	;
	; This to avoid having the sprite visibly flicker back and forth
	; between directions, as well as making the movement seem less weird.
	; 
	cp   a, $08						; Distance < $08?
	jr   c, .moveH					; If so, don't change direction
	call ActS_GetPlDirHRel			; Otherwise, move towards the player
	ld   [sActSetDir], a
.moveH:
	;
	; Move horizontally at 0.25px/frame
	;
	ld   a, [sActSetTimer]	; Every 4 frames...
	and  a, $03
	jr   nz, .trackY
	
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_Seal_Track_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_Seal_Track_MoveLeft
	
.trackY:
	;
	; Determine if the player is above or below the actor,
	; then move the actor closer to the player accordingly.
	;
	
	; Arbitrary value of $40 added to avoid comparing positive and negative number
	
	; BC = sPlY + $40
	ld   a, [sPlY_Low]	; C = sPlY_Low + $40
	add  $40
	ld   c, a
	ld   a, [sPlY_High]	; B = sPlY_High + (carry)
	adc  a, $00
	ld   b, a
	; HL = sActSetY + $40
	ld   a, [sActSetY_Low]
	add  $40
	ld   l, a
	ld   a, [sActSetY_High]
	adc  a, $00
	ld   h, a
	
	;--
	; We don't need the exact value of the distance.
	; All that matters is if (HL - BC > 0) -- which only requires the carry flag.
	;                        (aka HL > BC, or "is the player above the actor?")
	; 
	; This is why we aren't saving the result of the calculation anywhere.
	
	; Performing the subtraction of the low bytes sets the carry flag...
	ld   a, l		; A = L - C
	sub  a, c
	; ...which we're bringing over to the subtraction of the high byte
	ld   a, h		; A = H - B - (carry)
	sbc  a, b
	; If that's > 0, the player is above the actor)
	jr   nc, .plAbove
	
	;
	; Based on that, move the player to the requested vertical direction,
	; so that it moves closer to the player.
	;
	
	; [POI] Weird way to do it. Why not jump directly to the subroutines?
.plBelow:
	ld   a, DIR_D
	jr   .moveV
.plAbove:
	ld   a, DIR_U
.moveV:
	bit  DIRB_U, a
	jr   nz, Act_Seal_Track_MoveUp
	bit  DIRB_D, a
	jr   nz, Act_Seal_Track_MoveDown
	ret ; [POI] We never get here
	
; =============== Act_Seal_Track_MoveDown ===============
Act_Seal_Track_MoveDown:
	; Don't move through solid blocks
	
	; [BUG] There is a problem with this, which ends up causing a siren-like SFX to play continuously.
	;
	;       This check is meant to allow moving down only if there's a water block below.
	;
	;       However, ActColi_GetBlockId_Ground in particular has a special case where trying to read below
	;		the level layout area always returns BLOCKID_INSTAKILL.
	;       ActBGColi_IsEmptyWaterBlock treats BLOCKID_INSTAKILL as a valid water block 
	;		(since it technically is one), and here we're doing nothing to account for it.
	;
	;		The subroutines for checking the block ID on the left/right/above obviously do not need to
	;       check for this, so they return a block ID that, chances are, isn't a valid water block.
	;
	;		What this means is that if the actor goes below the level in "retreat" mode, once
	;       it returns to "idle" mode, it will get stuck and continuously turn back and forth.
	;		Turning plays a sound effect, so it ends up playing continuously.
	;
	;		Bonus: one of the seals in C27 is placed in a way which makes it easy to trigger the bug.
	;
	; 		To fix this, the actor should be either not be allowed to move over BLOCKID_INSTAKILL,
	;		or going below the end of the level. Alternatively, it could be manually despawned.	
	
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a							; Is there a water block below?
	ret  nz							; If not (ie: solid) don't move
	
	ld   bc, +$01
	call ActS_MoveDown
	ret
	
; =============== Act_Seal_Track_MoveUp ===============
Act_Seal_Track_MoveUp:
	; Don't move through solid blocks or above the water surface
	call ActColi_GetBlockId_Top
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a							; Is there a water block above?
	ret  nz							; If not, don't move
	
	ld   bc, -$01
	call ActS_MoveDown
	ret
	
; =============== Act_Seal_Track_MoveRight ===============
Act_Seal_Track_MoveRight:
	; Don't move if there isn't a water block on the right
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a
	ret  nz
	
	; Set swim/track anim
	ld   a, LOW(OBJLstPtrTable_Act_Seal_TrackR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Seal_TrackR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Move right 1px
	ld   bc, +$01
	call ActS_MoveRight
	
	; Set damaging part on the right side
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Adjust the collision box to account for the spear being on the right.
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$10
	ld   [sActSetColiBoxR], a
	ret
	
; =============== Act_Seal_Track_MoveLeft ===============
Act_Seal_Track_MoveLeft:
	; Don't move if there isn't a water block on the left
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a
	ret  nz
	
	; Set swim/track anim
	ld   a, LOW(OBJLstPtrTable_Act_Seal_TrackL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Seal_TrackL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Move left 1px
	ld   bc, -$01
	call ActS_MoveRight
	
	; Set damaging part on the left side
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Adjust the collision box to account for the spear being on the left.
	ld   a, -$10
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	ret
	
; =============== Act_Seal_Track_MoveLeft ===============
Act_Seal_SwitchToShoot:
	ld   a, SEAL_RTN_SHOOT
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSealModeTimer], a
	
	; The actor doesn't have a spear anymore since it will be thrown.
	; Make it vulnerable on all sides.
	; (the separate spear will be spawned later on)
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	; Readjust collision size
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	ld   a, SFX4_15
	ld   [sSFX4Set], a
	ret
	
; =============== Act_Seal_Shoot ===============
; Mode $02: The seal shoots the projectile.
Act_Seal_Shoot:
	; After $3C frames switch to the next mode
	ld   a, [sActSealModeTimer]
	inc  a
	ld   [sActSealModeTimer], a
	cp   a, $3C
	jr   nc, .nextMode
	
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	; At frame $10, spawn the separate spear actor and set the new anim frame without the spear.
	ld   a, [sActSealModeTimer]
	cp   a, $0F
	ret  nz
.throw:
	call Act_Seal_SpawnSpear
	
	; Set proper animation depending on the actor's direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, .setFrameR
	bit  DIRB_L, a
	jr   nz, .setFrameL
	ret ; [POI] We never get here
.setFrameR:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Seal_ShootR
	ret
.setFrameL:
	mActOBJLstPtrTable OBJLstPtrTable_Act_Seal_ShootL
	ret
.nextMode:
	ld   a, SEAL_RTN_RETREAT
	ld   [sActLocalRoutineId], a
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	xor  a
	ld   [sActSealModeTimer], a
	ld   [sActSetOBJLstId], a
	ret
	
; =============== Act_Seal_Shoot ===============
; Mode $03: The seal moves away in the opposite direction for $96 frames.
Act_Seal_Retreat:
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	; When the mode timer reaches $96, switch back to the idle mode
	ld   a, [sActSealModeTimer]		
	inc  a
	ld   [sActSealModeTimer], a
	cp   a, $96
	jp   nc, Act_Seal_SwitchToIdle
	
	
	;
	; HORIZONTAL MOVEMENT (1px/frame)
	;
	; Always move in the opposite direction of where the player is.
	; This does mean if the player goes past the seal, it will turn direction.
	call ActS_GetPlDirHRel		; A = Where the player is
	ld   [sActSetDir], a
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Is the player to the right of the actor?
	call nz, .moveLeft			; If so, move left
	ld   a, [sActSetDir]
	bit  DIRB_L, a				; Is the player to the left of the actor?
	call nz, .moveRight			; If so, move right
	
	;
	; VERTICAL MOVEMENT (0.5px/frame)
	;
	; Same thing as Act_Seal_Track.trackY, except this time we're moving in the opposite direction.
	; It even uses the same Y movement routines, since they just work.
	
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   a, [sPlY_Low]			; BC = sPlY + $40
	add  $40
	ld   c, a
	ld   a, [sPlY_High]
	adc  a, $00
	ld   b, a
	ld   a, [sActSetY_Low]		; HL = sActSetY + $40
	add  $40
	ld   l, a
	ld   a, [sActSetY_High]
	adc  a, $00
	ld   h, a
	
	ld   a, l					; HL - BC > 0? (player above actor?)
	sub  a, c
	ld   a, h
	sbc  a, b
	;--
	; Weird way to do this, again. Could have just been:
	; jr nc, Act_Seal_Track_MoveDown
	; jr Act_Seal_Track_MoveUp
	jr   nc, .plAbove			; If so, jump
.plBelow:
	ld   a, DIR_D					; Player is below
	jr   .moveV
.plAbove:
	ld   a, DIR_U					; Player is above
.moveV:
	bit  DIRB_D, a					; Is the player above?
	jp   nz, Act_Seal_Track_MoveUp
	bit  DIRB_U, a
	jp   nz, Act_Seal_Track_MoveDown
	ret ; [POI] We never get here
	;--

; =============== .moveLeft ===============
; Moves the actor left 1px, setting the proper anim.
.moveLeft:
	ld   a, LOW(OBJLstPtrTable_Act_Seal_RetreatL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Seal_RetreatL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; If there isn't a water block in the way, don't move
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a
	ret  nz
	
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
; =============== .moveRight ===============
; Moves the actor left 1px, setting the proper anim.
.moveRight:
	ld   a, LOW(OBJLstPtrTable_Act_Seal_RetreatR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Seal_RetreatR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	; If there isn't a water block in the way, don't move
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a
	ret  nz
	
	ld   bc, +$01
	call ActS_MoveRight
	ret
	
; =============== Act_SealSpear ===============
; The spear thrown by Act_Seal.
Act_SealSpear:
	call Act_SealSpear_CheckOffScreen
	
	; If the spear hit the player, despawn it
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_07					; Dealt damage?
	jr   z, Act_SealSpear_Despawn		; If so, jump
	
	ld   a, [sActSealSpearTimer]
	or   a								; Is the spear moving?
	jr   nz, Act_SealSpear_WaitDespawn	; If not, return
	
	; Move the spear as specified
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_SealSpear_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_SealSpear_MoveLeft
	ret
	
; =============== Act_SealSpear_CheckOffScreen ===============
; Despawns the knife as soon as it goes off-screen.
; NOTE: This is not necessary. 
;		The actor could have been spawned with the sActSetOpts flag ACTFLAGB_UNUSED_FREEOFFSCREEN.
Act_SealSpear_CheckOffScreen:
	call ActS_CheckOffScreen	; Update offscreen status
	ld   a, [sActSet]
	cp   a, $02					; Is the actor visible & active?
	ret  nc						; If so, return
	xor  a						; Otherwise, despawn it
	ld   [sActSet], a
	ret
; =============== Act_SealSpear_WallHit ===============
; Stops the spear once it hits a wall.
Act_SealSpear_WallHit:
	ld   a, $01						; Stop the spear
	ld   [sActSealSpearTimer], a
	xor  a							; Make intangible
	ld   [sActSetColiType], a
	ret
; =============== Act_SealSpear_WaitDespawn ===============
; Waits for $28 frames before despawning the spear.
Act_SealSpear_WaitDespawn:;R
	ld   a, [sActSealSpearTimer]	; Timer++;
	inc  a
	ld   [sActSealSpearTimer], a
	cp   a, $28						; Timer < $28?
	ret  c							; If so, return
; =============== Act_SealSpear_Despawn ===============
Act_SealSpear_Despawn:
	xor  a
	ld   [sActSet], a
	ret
; =============== Act_SealSpear_MoveLeft ===============
; Moves the spear left 2px/frame until it reaches a solid block.
Act_SealSpear_MoveLeft:
	ld   bc, -$02
	call ActS_MoveRight
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_SealSpearL
	
	; If the spear reaches a solid block, stop it
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	call nz, Act_SealSpear_WallHit
	ret
	
; =============== Act_SealSpear_MoveRight ===============
; Moves the spear right 2px/frame until it reaches a solid block.
Act_SealSpear_MoveRight:
	ld   bc, +$02
	call ActS_MoveRight
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_SealSpearR
	
	; If the spear reaches a solid block, stop it
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	call nz, Act_SealSpear_WallHit
	ret
	
; =============== Act_Seal_SpawnSpear ===============
; This subroutine spawns the spear thrown by the seal.
Act_Seal_SpawnSpear:
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
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_Seal
	
	ld   a, $02				; Enabled
	
	; Offset the bomb 8px away from the seal, depending on the direction.
	ldi  [hl], a
	ld   bc, -$08			; BC = Offset when facing left
	ld   a, [sActSetDir]
	bit  DIRB_L, a			; Facing left?
	jr   nz, .setX			; If so, jump
	ld   bc, +$08			; BC = Offset when facing right
.setX:
	ld   a, [sActSetX_Low]	; X = sActSetX + BC
	add  c
	ldi  [hl], a
	ld   a, [sActSetX_High]
	adc  a, b
	ldi  [hl], a
	
	ld   a, [sActSetY_Low]	; Y = sActSetY
	sub  a, $04
	ldi  [hl], a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ldi  [hl], a
	
	; Collision type
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ldi  [hl], a
	
	ld   a, -$04				; Coli box U
	ldi  [hl], a
	ld   a, -$02				; Coli box D
	ldi  [hl], a
	ld   a, -$04				; Coli box L
	ldi  [hl], a
	ld   a, +$04				; Coli box R
	ldi  [hl], a

	ld   a, $00					
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_None)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_None)
	ldi  [hl], a
	
	ld   a, [sActSetDir]		; Direction
	ldi  [hl], a
	
	xor  a						; OBJLst ID
	ldi  [hl], a
	
	ld   a, [sActSetId]			; Actor ID
	set  ACTB_NORESPAWN, a		; Don't respawn this actor
	ldi  [hl], a
	
	xor  a						; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_SealSpear)	; Code ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_SealSpear)
	ldi  [hl], a
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2 (sActSealSpearTimer)
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
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_Seal)		; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_Seal)
	ldi  [hl], a
	ret
	
; =============== OBJLstSharedPtrTable_Act_Seal ===============
OBJLstSharedPtrTable_Act_Seal:
	dw OBJLstPtrTable_Act_Seal_StunL;X
	dw OBJLstPtrTable_Act_Seal_StunR;X
	dw OBJLstPtrTable_Act_Seal_StunL;X
	dw OBJLstPtrTable_Act_Seal_StunR;X
	dw OBJLstPtrTable_Act_Seal_StunL
	dw OBJLstPtrTable_Act_Seal_StunR
	dw OBJLstPtrTable_Act_Seal_StunL;X
	dw OBJLstPtrTable_Act_Seal_StunR;X

OBJLstPtrTable_Act_Seal_IdleL:
	dw OBJLst_Act_Seal_IdleL0
	dw OBJLst_Act_Seal_IdleL1
	dw $0000
OBJLstPtrTable_Act_Seal_IdleR:
	dw OBJLst_Act_Seal_IdleR0
	dw OBJLst_Act_Seal_IdleR1
	dw $0000
OBJLstPtrTable_Act_Seal_TrackL:
	dw OBJLst_Act_Seal_TrackL0
	dw OBJLst_Act_Seal_TrackL1
	dw $0000
OBJLstPtrTable_Act_Seal_TrackR:
	dw OBJLst_Act_Seal_TrackR0
	dw OBJLst_Act_Seal_TrackR1
	dw $0000
OBJLstPtrTable_Act_Seal_ShootL:
	dw OBJLst_Act_Seal_RetreatL0
	dw $0000
OBJLstPtrTable_Act_Seal_ShootR:
	dw OBJLst_Act_Seal_RetreatR0
	dw $0000
OBJLstPtrTable_Act_Seal_StunL:
	dw OBJLst_Act_Seal_StunL
	dw $0000
OBJLstPtrTable_Act_Seal_StunR:
	dw OBJLst_Act_Seal_StunR
	dw $0000
OBJLstPtrTable_Act_Seal_RetreatL:
	dw OBJLst_Act_Seal_RetreatL0
	dw OBJLst_Act_Seal_RetreatL1
	dw $0000
OBJLstPtrTable_Act_Seal_RetreatR:
	dw OBJLst_Act_Seal_RetreatR0
	dw OBJLst_Act_Seal_RetreatR1
	dw $0000
OBJLstPtrTable_Act_SealSpearL:
	dw OBJLst_Act_SealSpearL
	dw $0000;X
OBJLstPtrTable_Act_SealSpearR:
	dw OBJLst_Act_SealSpearR
	dw $0000;X

OBJLst_Act_Seal_IdleL0: INCBIN "data/objlst/actor/seal_idlel0.bin"
OBJLst_Act_Seal_IdleL1: INCBIN "data/objlst/actor/seal_idlel1.bin"
OBJLst_Act_Seal_StunL: INCBIN "data/objlst/actor/seal_stunl.bin"
OBJLst_Act_Seal_TrackL0: INCBIN "data/objlst/actor/seal_trackl0.bin"
OBJLst_Act_Seal_TrackL1: INCBIN "data/objlst/actor/seal_trackl1.bin"
OBJLst_Act_SealSpearL: INCBIN "data/objlst/actor/sealspearl.bin"
OBJLst_Act_Seal_RetreatL0: INCBIN "data/objlst/actor/seal_retreatl0.bin"
OBJLst_Act_Seal_RetreatL1: INCBIN "data/objlst/actor/seal_retreatl1.bin"
OBJLst_Act_Seal_IdleR0: INCBIN "data/objlst/actor/seal_idler0.bin"
OBJLst_Act_Seal_IdleR1: INCBIN "data/objlst/actor/seal_idler1.bin"
OBJLst_Act_Seal_StunR: INCBIN "data/objlst/actor/seal_stunr.bin"
OBJLst_Act_Seal_TrackR0: INCBIN "data/objlst/actor/seal_trackr0.bin"
OBJLst_Act_Seal_TrackR1: INCBIN "data/objlst/actor/seal_trackr1.bin"
OBJLst_Act_SealSpearR: INCBIN "data/objlst/actor/sealspearr.bin"
OBJLst_Act_Seal_RetreatR0: INCBIN "data/objlst/actor/seal_retreatr0.bin"
OBJLst_Act_Seal_RetreatR1: INCBIN "data/objlst/actor/seal_retreatr1.bin"
GFX_Act_Seal: INCBIN "data/gfx/actor/seal.bin"

; =============== LoadGFX_Act_BigHeart ===============
; Loads the graphics of the Big Heart to VRAM.
; This is meant to be used when starting the "Heart Game" after defeating a boss.
LoadGFX_Act_BigHeart:
	; Total size: $C0 bytes.
	; Split in two VRAM addresses.
	
	ld   hl, GFX_Act_BigHeart	; HL = Ptr to unc. GFX
	ld   bc, vGFXBigHeart0		; DE = Destination in VRAM
	ld   d, $70					; D  = Bytes to copy
.loop1:
	mWaitForNewHBlank
	ldi  a, [hl]				; Copy the byte over
	ld   [bc], a
	inc  bc
	dec  d						; Have we copied all the bytes?
	jr   nz, .loop1				; If not, jump
	
	ld   bc, vGFXBigHeart1		; DE = Destination in VRAM
	ld   d, $50					; D  = Bytes to copy
.loop2:
	mWaitForNewHBlank
	ldi  a, [hl]				
	ld   [bc], a		
	inc  bc				
	dec  d
	jr   nz, .loop2
	ret
	
; =============== ActS_SpawnBigHeart ===============
ActS_SpawnBigHeart:
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
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_BigHeart
	
	ld   a, $02					; Enabled
	ldi  [hl], a
	ld   a, [sActSetX_Low]		; X = sActSetX
	ldi  [hl], a
	ld   a, [sActSetX_High]
	ldi  [hl], a
	ld   a, [sActSetY_Low]		; Y = sActSetY 
	ldi  [hl], a
	ld   a, [sActSetY_High]
	ldi  [hl], a
	
	xor  a						; Collision type (intangible)
	ldi  [hl], a
	
	ld   a, -$20				; Coli box U
	ldi  [hl], a
	ld   a, -$00				; Coli box D
	ldi  [hl], a
	ld   a, -$0A				; Coli box L
	ldi  [hl], a
	ld   a, +$0A				; Coli box R
	ldi  [hl], a
	
	ld   a, $10
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_None)	; OBJLst Table
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_None)
	ldi  [hl], a
	
	xor  a						; Dir
	ldi  [hl], a
	xor  a						; OBJLst ID
	ldi  [hl], a
	
	; Assume current + 1
	ld   a, [sActSetId]			; Actor ID
	inc  a
	ldi  [hl], a
	
	xor  a						; Dir
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_BigHeart)	; Code ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_BigHeart)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	ldi  [hl], a				; Timer 3
	ldi  [hl], a				; Timer 4
	ldi  [hl], a				; Timer 5
	ld   a, $28					; Move upwards and stay intangible for $28 frames
	ldi  [hl], a
	xor  a
	ldi  [hl], a				; Timer 7
	
	ld   a, $01					; Flags
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_BigHeart)		; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_BigHeart)
	ldi  [hl], a
	ret
	
; =============== ActS_HeartGame ===============
; This subroutine, meant to execute under a boss actor, spawns 3UP hearts after defeating a boss.
ActS_HeartGame:
	;--
	; This isn't particulatly obvious.
	; This actor check makes sure to wait until the player collects all the hearts before ending the level.
	; It's done by checking if any actors have the ACTCOLI_BIGHEART collision type.
	;
	; While Act_BigHearts is spawned with the collision type ACTCOLI_BIGHEART,
	; the BigHeart actor becomes intangible while it rises from the ground, which prevents the collision
	; check from triggering early (and locking out on one heart at a time).
	; Every consecutive frame a heart is spawned.
	; 
	ld   hl, sAct					; HL = Slot area
	ld   d, $07						; D = Slots left
	ld   e, $00						; E = Current slot num 
	ld   c, e						; C = E
.checkSlot:
	ld   a, [hl]					; Read status
	or   a							; Is this slot marked as free?
	jr   z, .nextSlot				; If so, skip
.chkColiType:
	; Otherwise, check if the slot contains a big heart.
	; Since this is a special actor, the collision type here counts as the actor ID.
	ld   a, l						; Seek to the collision type
	add  (sActSetColiType-sActSet)
	ld   l, a
	ld   a, [hl]		
	cp   a, ACTCOLI_BIGHEART		; Is this a big heart?
	ret  z							; If so, we've already spawned the hearts
	ld   a, l
	sub  a, (sActSetColiType-sActSet)
	ld   l, a
	
.nextSlot:
	inc  e							; SlotNum++
	ld   a, l						; Seek to the next slot
	add  (sActSet_End-sActSet)
	ld   l, a
	dec  d				; Have we checked all slots?
	jr   nz, .checkSlot	; If not, loop
	
	; Otherwise, we can spawn the hearts
ActS_HeartGame_SpawnHearts:
	ld   hl, sAct	; HL = Slot area
	ld   d, $07		; D = Slots left
	ld   e, $00		; E = Current slot num 
.checkSlot:
	ld   a, [hl]	; Read status
	or   a			; Is this slot marked as free?
	jr   z, .slotFound	; If so, jump
.nextSlot:
	inc  e			; SlotNum++
	dec  d			; SlotsLeft--
	ret  z			; If there are none left, return
	ld   a, l		; HL += SlotSize
	add  (sActSet_End-sActSet)
	ld   l, a
	jr   .checkSlot
.slotFound:
	;--
	; Since sLvlClearOnDeath only needs to be != 0, it gets reused as a multipurpose timer.
	; Any time we get here, it will be increased by $01, capping at $F0.
	
	; It has two purposes here:
	; - Counting how many hearts were spawned. If more than 5, it stops spawning them.
	; - To delay the automatic level completion upon collecting all of the hearts.
	;	When the counter reaches $F0, an automatic level completion is triggered.
	;	(though because of checks above, the timer doesn't get increased when hearts are on-screen)
	ld   a, [sLvlClearOnDeath]
	cp   a, $05					; Were 5 hearts spawned already?
	jp   nc, .noSpawn			; If so, skip
	
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_BigHeart
	
	ld   a, $02					; Enabled
	ldi  [hl], a
	
	; Randomize X position
	; X = (Rand & $78) + $10
	call Rand
	and  a, $78					; Make sure it spawns on screen (aligned to 8x8 grid)
	add  $10					; Account for origin (don't spawn halfway off-screen)
	ldi  [hl], a				
	ld   a, $00
	ldi  [hl], a
	
	ld   bc, $00F8				; Y
	ld   a, c
	ldi  [hl], a
	ld   a, b
	ldi  [hl], a
	
	ld   a, ACTCOLI_BIGHEART	; Collision type
	ldi  [hl], a
	ld   a, -$20				; Coli box U
	ldi  [hl], a
	ld   a, +$00				; Coli box D
	ldi  [hl], a
	ld   a, -$0A				; Coli box L
	ldi  [hl], a
	ld   a, +$0A				; Coli box R
	ldi  [hl], a
	
	ld   a, $10
	ldi  [hl], a				; Rel.Y (Origin)
	ldi  [hl], a				; Rel.X (Origin)
	
	ld   a, LOW(OBJLstPtrTable_Act_None)	; OBJLstPtrTable
	ldi  [hl], a
	ld   a, HIGH(OBJLstPtrTable_Act_None)
	ldi  [hl], a
	
	xor  a						; Direction
	ldi  [hl], a
	xor  a						; OBJLst Id
	ldi  [hl], a
	ld   a, [sActSetId]			; Actor ID
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_BigHeart)		; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_BigHeart)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
	ldi  [hl], a				; Timer 3
	ldi  [hl], a				; Timer 4
	ldi  [hl], a				; Timer 5
	ld   a, $28					; Move upwards and stay intangible for $28 frames
	ldi  [hl], a
	xor  a
	ldi  [hl], a				; Timer 7
	
	ld   a, $01					; Flags
	ldi  [hl], a
	
	ld   a, LOW(sActDummyBlock)	; Level layout ptr (not used)
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)
	ldi  [hl], a
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_BigHeart)		; OBJLst shared table
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_BigHeart)
	ldi  [hl], a
	
.noSpawn:
	ld   a, [sLvlClearOnDeath]	; Timer++
	inc  a
	ld   [sLvlClearOnDeath], a
	cp   a, $F0					; Timer < $F0?
	ret  c						; If so, return
	
	; Otherwise, autoclear the level as soon as we stop jumping
	ld   a, $7D					; Reset back to $7D (prevent rollover)
	ld   [sLvlClearOnDeath], a
	ld   a, [sPlAction]
	cp   a, PL_ACT_JUMP			; Are we jumping?
	ret  z						; If so, return
	ld   a, LVLCLEAR_BOSS		; Otherwise, mark as boss clear
	ld   [sLvlSpecClear], a
	ret
	
; =============== ActInit_BigHeart ===============
; Spawns a 3UP Heart coming from a big block.
ActInit_BigHeart:
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
	ld   bc, SubCall_Act_BigHeart
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_ActInit_BigHeart
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_BigHeart
	call ActS_SetOBJLstSharedTablePtr
	
	ld   a, ACTCOLI_BIGHEART
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	xor  a
	ld   [sActSetTimer2], a ; Not used
	ld   [sActSetTimer3], a ; Not used
	ld   [sActSetTimer4], a ; Not used
	ld   [sActBigHeartPopUpTimer], a
	ret
	
OBJLstPtrTable_ActInit_BigHeart:
	dw OBJLst_Act_BigHeart0
	dw $0000;X

; =============== Act_BigHeart ===============
Act_BigHeart:
	ld   a, [sActSetTimer]	; Timer++
	inc  a					
	ld   [sActSetTimer], a
	call ActS_IncOBJLstIdEvery8
	
	ld   a, LOW(OBJLstPtrTable_Act_BigHeart)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_BigHeart)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Until the heart is rising from the big block/ground, make it intangible
	ld   a, [sActBigHeartPopUpTimer]
	or   a									; Is the heart still moving up?
	jr   nz, .rising						; If so, jump
	
	; Otherwise, set the standard collision type, which triggers the timer check in the heart game.
	ld   a, ACTCOLI_BIGHEART				
	ld   [sActSetColiType], a
	ret
.rising:
	dec  a
	ld   [sActBigHeartPopUpTimer], a
	xor  a									; Set as intangible
	ld   [sActSetColiType], a
	; Move up 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveDown
	ret
OBJLstPtrTable_Act_BigHeart:
	dw OBJLst_Act_BigHeart0
	dw OBJLst_Act_BigHeart1
	dw $0000
OBJLstSharedPtrTable_Act_BigHeart:
	dw OBJLstPtrTable_Act_BigHeart;X
	dw OBJLstPtrTable_Act_BigHeart;X
	dw OBJLstPtrTable_Act_BigHeart;X
	dw OBJLstPtrTable_Act_BigHeart;X
	dw OBJLstPtrTable_Act_BigHeart;X
	dw OBJLstPtrTable_Act_BigHeart;X
	dw OBJLstPtrTable_Act_BigHeart;X
	dw OBJLstPtrTable_Act_BigHeart;X

OBJLst_Act_BigHeart0: INCBIN "data/objlst/actor/bigheart0.bin"
OBJLst_Act_BigHeart1: INCBIN "data/objlst/actor/bigheart1.bin"
GFX_Act_BigHeart: INCBIN "data/gfx/actor/bigheart.bin"

; =============== END OF BANK ===============
L0F7C44: db $C1;X
L0F7C45: db $C1;X
L0F7C46: db $F3;X
L0F7C47: db $B2;X
L0F7C48: db $7B;X
L0F7C49: db $4B;X
L0F7C4A: db $7E;X
L0F7C4B: db $47;X
L0F7C4C: db $3A;X
L0F7C4D: db $2F;X
L0F7C4E: db $17;X
L0F7C4F: db $1D;X
L0F7C50: db $17;X
L0F7C51: db $1C;X
L0F7C52: db $77;X
L0F7C53: db $6C;X
L0F7C54: db $03;X
L0F7C55: db $03;X
L0F7C56: db $8F;X
L0F7C57: db $8D;X
L0F7C58: db $9E;X
L0F7C59: db $92;X
L0F7C5A: db $7E;X
L0F7C5B: db $E2;X
L0F7C5C: db $9C;X
L0F7C5D: db $74;X
L0F7C5E: db $28;X
L0F7C5F: db $D8;X
L0F7C60: db $9E;X
L0F7C61: db $FE;X
L0F7C62: db $BF;X
L0F7C63: db $E1;X
L0F7C64: db $E3;X
L0F7C65: db $BF;X
L0F7C66: db $74;X
L0F7C67: db $7B;X
L0F7C68: db $11;X
L0F7C69: db $1F;X
L0F7C6A: db $3B;X
L0F7C6B: db $2E;X
L0F7C6C: db $7F;X
L0F7C6D: db $46;X
L0F7C6E: db $79;X
L0F7C6F: db $49;X
L0F7C70: db $F1;X
L0F7C71: db $B1;X
L0F7C72: db $C0;X
L0F7C73: db $C0;X
L0F7C74: db $3E;X
L0F7C75: db $E6;X
L0F7C76: db $18;X
L0F7C77: db $F8;X
L0F7C78: db $A8;X
L0F7C79: db $D8;X
L0F7C7A: db $DC;X
L0F7C7B: db $74;X
L0F7C7C: db $FE;X
L0F7C7D: db $62;X
L0F7C7E: db $DE;X
L0F7C7F: db $52;X
L0F7C80: db $CF;X
L0F7C81: db $4D;X
L0F7C82: db $83;X
L0F7C83: db $83;X
L0F7C84: db $00;X
L0F7C85: db $10;X
L0F7C86: db $00;X
L0F7C87: db $00;X
L0F7C88: db $00;X
L0F7C89: db $00;X
L0F7C8A: db $00;X
L0F7C8B: db $00;X
L0F7C8C: db $05;X
L0F7C8D: db $00;X
L0F7C8E: db $03;X
L0F7C8F: db $00;X
L0F7C90: db $80;X
L0F7C91: db $00;X
L0F7C92: db $00;X
L0F7C93: db $00;X
L0F7C94: db $00;X
L0F7C95: db $40;X
L0F7C96: db $00;X
L0F7C97: db $00;X
L0F7C98: db $00;X
L0F7C99: db $00;X
L0F7C9A: db $08;X
L0F7C9B: db $40;X
L0F7C9C: db $00;X
L0F7C9D: db $03;X
L0F7C9E: db $00;X
L0F7C9F: db $60;X
L0F7CA0: db $40;X
L0F7CA1: db $10;X
L0F7CA2: db $00;X
L0F7CA3: db $00;X
L0F7CA4: db $00;X
L0F7CA5: db $00;X
L0F7CA6: db $08;X
L0F7CA7: db $08;X
L0F7CA8: db $80;X
L0F7CA9: db $00;X
L0F7CAA: db $00;X
L0F7CAB: db $00;X
L0F7CAC: db $40;X
L0F7CAD: db $80;X
L0F7CAE: db $40;X
L0F7CAF: db $00;X
L0F7CB0: db $40;X
L0F7CB1: db $00;X
L0F7CB2: db $02;X
L0F7CB3: db $01;X
L0F7CB4: db $00;X
L0F7CB5: db $00;X
L0F7CB6: db $02;X
L0F7CB7: db $08;X
L0F7CB8: db $00;X
L0F7CB9: db $08;X
L0F7CBA: db $20;X
L0F7CBB: db $08;X
L0F7CBC: db $00;X
L0F7CBD: db $20;X
L0F7CBE: db $00;X
L0F7CBF: db $00;X
L0F7CC0: db $00;X
L0F7CC1: db $40;X
L0F7CC2: db $24;X
L0F7CC3: db $00;X
L0F7CC4: db $00;X
L0F7CC5: db $00;X
L0F7CC6: db $00;X
L0F7CC7: db $00;X
L0F7CC8: db $00;X
L0F7CC9: db $04;X
L0F7CCA: db $00;X
L0F7CCB: db $40;X
L0F7CCC: db $00;X
L0F7CCD: db $04;X
L0F7CCE: db $00;X
L0F7CCF: db $05;X
L0F7CD0: db $00;X
L0F7CD1: db $00;X
L0F7CD2: db $12;X
L0F7CD3: db $00;X
L0F7CD4: db $50;X
L0F7CD5: db $00;X
L0F7CD6: db $48;X
L0F7CD7: db $03;X
L0F7CD8: db $00;X
L0F7CD9: db $02;X
L0F7CDA: db $00;X
L0F7CDB: db $00;X
L0F7CDC: db $04;X
L0F7CDD: db $00;X
L0F7CDE: db $08;X
L0F7CDF: db $00;X
L0F7CE0: db $00;X
L0F7CE1: db $00;X
L0F7CE2: db $08;X
L0F7CE3: db $00;X
L0F7CE4: db $00;X
L0F7CE5: db $A0;X
L0F7CE6: db $80;X
L0F7CE7: db $30;X
L0F7CE8: db $80;X
L0F7CE9: db $00;X
L0F7CEA: db $00;X
L0F7CEB: db $10;X
L0F7CEC: db $04;X
L0F7CED: db $08;X
L0F7CEE: db $10;X
L0F7CEF: db $80;X
L0F7CF0: db $00;X
L0F7CF1: db $00;X
L0F7CF2: db $00;X
L0F7CF3: db $00;X
L0F7CF4: db $00;X
L0F7CF5: db $80;X
L0F7CF6: db $00;X
L0F7CF7: db $00;X
L0F7CF8: db $80;X
L0F7CF9: db $10;X
L0F7CFA: db $00;X
L0F7CFB: db $08;X
L0F7CFC: db $00;X
L0F7CFD: db $40;X
L0F7CFE: db $00;X
L0F7CFF: db $80;X
L0F7D00: db $FF;X
L0F7D01: db $7F;X
L0F7D02: db $FF;X
L0F7D03: db $FF;X
L0F7D04: db $FF;X
L0F7D05: db $BF;X
L0F7D06: db $FF;X
L0F7D07: db $FF;X
L0F7D08: db $FF;X
L0F7D09: db $FF;X
L0F7D0A: db $FF;X
L0F7D0B: db $FF;X
L0F7D0C: db $FD;X
L0F7D0D: db $BF;X
L0F7D0E: db $FF;X
L0F7D0F: db $FE;X
L0F7D10: db $FF;X
L0F7D11: db $F7;X
L0F7D12: db $FF;X
L0F7D13: db $FF;X
L0F7D14: db $FF;X
L0F7D15: db $FF;X
L0F7D16: db $FF;X
L0F7D17: db $FF;X
L0F7D18: db $FD;X
L0F7D19: db $FF;X
L0F7D1A: db $FF;X
L0F7D1B: db $EF;X
L0F7D1C: db $FF;X
L0F7D1D: db $FF;X
L0F7D1E: db $FF;X
L0F7D1F: db $FF;X
L0F7D20: db $FF;X
L0F7D21: db $FF;X
L0F7D22: db $FF;X
L0F7D23: db $FB;X
L0F7D24: db $FF;X
L0F7D25: db $FD;X
L0F7D26: db $FF;X
L0F7D27: db $FF;X
L0F7D28: db $F7;X
L0F7D29: db $FF;X
L0F7D2A: db $FF;X
L0F7D2B: db $FF;X
L0F7D2C: db $DF;X
L0F7D2D: db $FF;X
L0F7D2E: db $7F;X
L0F7D2F: db $FF;X
L0F7D30: db $7F;X
L0F7D31: db $FF;X
L0F7D32: db $DF;X
L0F7D33: db $FB;X
L0F7D34: db $FF;X
L0F7D35: db $DE;X
L0F7D36: db $BD;X
L0F7D37: db $FF;X
L0F7D38: db $FF;X
L0F7D39: db $EF;X
L0F7D3A: db $FF;X
L0F7D3B: db $FF;X
L0F7D3C: db $FF;X
L0F7D3D: db $FF;X
L0F7D3E: db $FF;X
L0F7D3F: db $DF;X
L0F7D40: db $FF;X
L0F7D41: db $BF;X
L0F7D42: db $FF;X
L0F7D43: db $FF;X
L0F7D44: db $FF;X
L0F7D45: db $FF;X
L0F7D46: db $FE;X
L0F7D47: db $FF;X
L0F7D48: db $FF;X
L0F7D49: db $DF;X
L0F7D4A: db $FE;X
L0F7D4B: db $FF;X
L0F7D4C: db $FF;X
L0F7D4D: db $FF;X
L0F7D4E: db $FF;X
L0F7D4F: db $EF;X
L0F7D50: db $FF;X
L0F7D51: db $FE;X
L0F7D52: db $FF;X
L0F7D53: db $FF;X
L0F7D54: db $DF;X
L0F7D55: db $EB;X
L0F7D56: db $FF;X
L0F7D57: db $7F;X
L0F7D58: db $FF;X
L0F7D59: db $FF;X
L0F7D5A: db $F7;X
L0F7D5B: db $F7;X
L0F7D5C: db $FF;X
L0F7D5D: db $F7;X
L0F7D5E: db $FE;X
L0F7D5F: db $FF;X
L0F7D60: db $FF;X
L0F7D61: db $FF;X
L0F7D62: db $FF;X
L0F7D63: db $FF;X
L0F7D64: db $FF;X
L0F7D65: db $FF;X
L0F7D66: db $FF;X
L0F7D67: db $ED;X
L0F7D68: db $FF;X
L0F7D69: db $FF;X
L0F7D6A: db $FF;X
L0F7D6B: db $FF;X
L0F7D6C: db $FF;X
L0F7D6D: db $F9;X
L0F7D6E: db $FD;X
L0F7D6F: db $FF;X
L0F7D70: db $FF;X
L0F7D71: db $FF;X
L0F7D72: db $FF;X
L0F7D73: db $BF;X
L0F7D74: db $FF;X
L0F7D75: db $FF;X
L0F7D76: db $FF;X
L0F7D77: db $F7;X
L0F7D78: db $ED;X
L0F7D79: db $FE;X
L0F7D7A: db $FF;X
L0F7D7B: db $FF;X
L0F7D7C: db $FF;X
L0F7D7D: db $E9;X
L0F7D7E: db $FF;X
L0F7D7F: db $FF;X
L0F7D80: db $00;X
L0F7D81: db $02;X
L0F7D82: db $00;X
L0F7D83: db $00;X
L0F7D84: db $14;X
L0F7D85: db $00;X
L0F7D86: db $00;X
L0F7D87: db $10;X
L0F7D88: db $10;X
L0F7D89: db $20;X
L0F7D8A: db $00;X
L0F7D8B: db $00;X
L0F7D8C: db $00;X
L0F7D8D: db $02;X
L0F7D8E: db $14;X
L0F7D8F: db $00;X
L0F7D90: db $00;X
L0F7D91: db $30;X
L0F7D92: db $00;X
L0F7D93: db $10;X
L0F7D94: db $00;X
L0F7D95: db $10;X
L0F7D96: db $10;X
L0F7D97: db $00;X
L0F7D98: db $00;X
L0F7D99: db $00;X
L0F7D9A: db $20;X
L0F7D9B: db $00;X
L0F7D9C: db $00;X
L0F7D9D: db $00;X
L0F7D9E: db $40;X
L0F7D9F: db $10;X
L0F7DA0: db $10;X
L0F7DA1: db $00;X
L0F7DA2: db $00;X
L0F7DA3: db $00;X
L0F7DA4: db $00;X
L0F7DA5: db $40;X
L0F7DA6: db $00;X
L0F7DA7: db $00;X
L0F7DA8: db $01;X
L0F7DA9: db $01;X
L0F7DAA: db $00;X
L0F7DAB: db $00;X
L0F7DAC: db $00;X
L0F7DAD: db $00;X
L0F7DAE: db $00;X
L0F7DAF: db $10;X
L0F7DB0: db $00;X
L0F7DB1: db $00;X
L0F7DB2: db $20;X
L0F7DB3: db $00;X
L0F7DB4: db $00;X
L0F7DB5: db $10;X
L0F7DB6: db $00;X
L0F7DB7: db $00;X
L0F7DB8: db $00;X
L0F7DB9: db $20;X
L0F7DBA: db $01;X
L0F7DBB: db $00;X
L0F7DBC: db $04;X
L0F7DBD: db $D0;X
L0F7DBE: db $00;X
L0F7DBF: db $26;X
L0F7DC0: db $00;X
L0F7DC1: db $00;X
L0F7DC2: db $10;X
L0F7DC3: db $08;X
L0F7DC4: db $00;X
L0F7DC5: db $10;X
L0F7DC6: db $40;X
L0F7DC7: db $00;X
L0F7DC8: db $00;X
L0F7DC9: db $81;X
L0F7DCA: db $02;X
L0F7DCB: db $01;X
L0F7DCC: db $00;X
L0F7DCD: db $00;X
L0F7DCE: db $00;X
L0F7DCF: db $00;X
L0F7DD0: db $A0;X
L0F7DD1: db $00;X
L0F7DD2: db $00;X
L0F7DD3: db $00;X
L0F7DD4: db $00;X
L0F7DD5: db $06;X
L0F7DD6: db $40;X
L0F7DD7: db $01;X
L0F7DD8: db $80;X
L0F7DD9: db $00;X
L0F7DDA: db $10;X
L0F7DDB: db $02;X
L0F7DDC: db $04;X
L0F7DDD: db $00;X
L0F7DDE: db $80;X
L0F7DDF: db $84;X
L0F7DE0: db $00;X
L0F7DE1: db $01;X
L0F7DE2: db $00;X
L0F7DE3: db $02;X
L0F7DE4: db $00;X
L0F7DE5: db $00;X
L0F7DE6: db $00;X
L0F7DE7: db $04;X
L0F7DE8: db $00;X
L0F7DE9: db $84;X
L0F7DEA: db $08;X
L0F7DEB: db $00;X
L0F7dec: db $00;X
L0F7DED: db $01;X
L0F7DEE: db $00;X
L0F7DEF: db $00;X
L0F7DF0: db $02;X
L0F7DF1: db $00;X
L0F7DF2: db $00;X
L0F7DF3: db $00;X
L0F7DF4: db $20;X
L0F7DF5: db $04;X
L0F7DF6: db $00;X
L0F7DF7: db $00;X
L0F7DF8: db $00;X
L0F7DF9: db $00;X
L0F7DFA: db $10;X
L0F7DFB: db $00;X
L0F7DFC: db $00;X
L0F7DFD: db $20;X
L0F7DFE: db $08;X
L0F7DFF: db $80;X
L0F7E00: db $FF;X
L0F7E01: db $DF;X
L0F7E02: db $F3;X
L0F7E03: db $FB;X
L0F7E04: db $FF;X
L0F7E05: db $FF;X
L0F7E06: db $EB;X
L0F7E07: db $FD;X
L0F7E08: db $FF;X
L0F7E09: db $FF;X
L0F7E0A: db $FF;X
L0F7E0B: db $DF;X
L0F7E0C: db $FF;X
L0F7E0D: db $FF;X
L0F7E0E: db $FF;X
L0F7E0F: db $FF;X
L0F7E10: db $FF;X
L0F7E11: db $7F;X
L0F7E12: db $EF;X
L0F7E13: db $DF;X
L0F7E14: db $FF;X
L0F7E15: db $FF;X
L0F7E16: db $FE;X
L0F7E17: db $FE;X
L0F7E18: db $FF;X
L0F7E19: db $FF;X
L0F7E1A: db $FF;X
L0F7E1B: db $FF;X
L0F7E1C: db $FF;X
L0F7E1D: db $FB;X
L0F7E1E: db $FF;X
L0F7E1F: db $FF;X
L0F7E20: db $FF;X
L0F7E21: db $7F;X
L0F7E22: db $FF;X
L0F7E23: db $FF;X
L0F7E24: db $FF;X
L0F7E25: db $FF;X
L0F7E26: db $FF;X
L0F7E27: db $FF;X
L0F7E28: db $FF;X
L0F7E29: db $FF;X
L0F7E2A: db $FF;X
L0F7E2B: db $FD;X
L0F7E2C: db $F5;X
L0F7E2D: db $FF;X
L0F7E2E: db $DB;X
L0F7E2F: db $FD;X
L0F7E30: db $FF;X
L0F7E31: db $F7;X
L0F7E32: db $FF;X
L0F7E33: db $FD;X
L0F7E34: db $FF;X
L0F7E35: db $FF;X
L0F7E36: db $F3;X
L0F7E37: db $FF;X
L0F7E38: db $FF;X
L0F7E39: db $FF;X
L0F7E3A: db $FF;X
L0F7E3B: db $77;X
L0F7E3C: db $FF;X
L0F7E3D: db $FF;X
L0F7E3E: db $EF;X
L0F7E3F: db $7F;X
L0F7E40: db $FF;X
L0F7E41: db $FF;X
L0F7E42: db $FE;X
L0F7E43: db $FF;X
L0F7E44: db $FF;X
L0F7E45: db $FE;X
L0F7E46: db $1F;X
L0F7E47: db $DF;X
L0F7E48: db $FF;X
L0F7E49: db $FF;X
L0F7E4A: db $BF;X
L0F7E4B: db $FF;X
L0F7E4C: db $FF;X
L0F7E4D: db $FF;X
L0F7E4E: db $FF;X
L0F7E4F: db $FF;X
L0F7E50: db $FF;X
L0F7E51: db $FF;X
L0F7E52: db $FF;X
L0F7E53: db $FF;X
L0F7E54: db $FF;X
L0F7E55: db $DF;X
L0F7E56: db $FF;X
L0F7E57: db $F7;X
L0F7E58: db $FF;X
L0F7E59: db $FF;X
L0F7E5A: db $DF;X
L0F7E5B: db $FF;X
L0F7E5C: db $FF;X
L0F7E5D: db $7F;X
L0F7E5E: db $FF;X
L0F7E5F: db $FF;X
L0F7E60: db $FF;X
L0F7E61: db $FF;X
L0F7E62: db $EF;X
L0F7E63: db $BF;X
L0F7E64: db $EF;X
L0F7E65: db $FF;X
L0F7E66: db $FF;X
L0F7E67: db $EF;X
L0F7E68: db $7F;X
L0F7E69: db $FF;X
L0F7E6A: db $FF;X
L0F7E6B: db $FF;X
L0F7E6C: db $FF;X
L0F7E6D: db $EF;X
L0F7E6E: db $FD;X
L0F7E6F: db $FF;X
L0F7E70: db $FF;X
L0F7E71: db $CF;X
L0F7E72: db $FF;X
L0F7E73: db $F7;X
L0F7E74: db $FF;X
L0F7E75: db $FF;X
L0F7E76: db $FF;X
L0F7E77: db $FF;X
L0F7E78: db $FF;X
L0F7E79: db $FE;X
L0F7E7A: db $DF;X
L0F7E7B: db $FF;X
L0F7E7C: db $BF;X
L0F7E7D: db $FE;X
L0F7E7E: db $FF;X
L0F7E7F: db $FF;X
L0F7E80: db $00;X
L0F7E81: db $00;X
L0F7E82: db $74;X
L0F7E83: db $00;X
L0F7E84: db $03;X
L0F7E85: db $C5;X
L0F7E86: db $01;X
L0F7E87: db $02;X
L0F7E88: db $08;X
L0F7E89: db $81;X
L0F7E8A: db $00;X
L0F7E8B: db $20;X
L0F7E8C: db $00;X
L0F7E8D: db $00;X
L0F7E8E: db $70;X
L0F7E8F: db $60;X
L0F7E90: db $00;X
L0F7E91: db $00;X
L0F7E92: db $82;X
L0F7E93: db $14;X
L0F7E94: db $02;X
L0F7E95: db $10;X
L0F7E96: db $00;X
L0F7E97: db $11;X
L0F7E98: db $40;X
L0F7E99: db $01;X
L0F7E9A: db $06;X
L0F7E9B: db $00;X
L0F7E9C: db $00;X
L0F7E9D: db $08;X
L0F7E9E: db $00;X
L0F7E9F: db $05;X
L0F7EA0: db $10;X
L0F7EA1: db $40;X
L0F7EA2: db $02;X
L0F7EA3: db $00;X
L0F7EA4: db $00;X
L0F7EA5: db $C0;X
L0F7EA6: db $08;X
L0F7EA7: db $E2;X
L0F7EA8: db $0C;X
L0F7EA9: db $12;X
L0F7EAA: db $84;X
L0F7EAB: db $01;X
L0F7EAC: db $01;X
L0F7EAD: db $40;X
L0F7EAE: db $C0;X
L0F7EAF: db $94;X
L0F7EB0: db $08;X
L0F7EB1: db $8C;X
L0F7EB2: db $10;X
L0F7EB3: db $00;X
L0F7EB4: db $10;X
L0F7EB5: db $40;X
L0F7EB6: db $C2;X
L0F7EB7: db $28;X
L0F7EB8: db $00;X
L0F7EB9: db $21;X
L0F7EBA: db $02;X
L0F7EBB: db $20;X
L0F7EBC: db $00;X
L0F7EBD: db $00;X
L0F7EBE: db $0C;X
L0F7EBF: db $00;X
L0F7EC0: db $00;X
L0F7EC1: db $10;X
L0F7EC2: db $02;X
L0F7EC3: db $00;X
L0F7EC4: db $41;X
L0F7EC5: db $42;X
L0F7EC6: db $04;X
L0F7EC7: db $58;X
L0F7EC8: db $20;X
L0F7EC9: db $81;X
L0F7ECA: db $10;X
L0F7ECB: db $00;X
L0F7ECC: db $00;X
L0F7ECD: db $40;X
L0F7ECE: db $80;X
L0F7ECF: db $40;X
L0F7ED0: db $08;X
L0F7ED1: db $82;X
L0F7ED2: db $C1;X
L0F7ED3: db $10;X
L0F7ED4: db $00;X
L0F7ED5: db $00;X
L0F7ED6: db $00;X
L0F7ED7: db $02;X
L0F7ED8: db $28;X
L0F7ED9: db $00;X
L0F7EDA: db $40;X
L0F7EDB: db $A0;X
L0F7EDC: db $00;X
L0F7EDD: db $00;X
L0F7EDE: db $02;X
L0F7EDF: db $40;X
L0F7EE0: db $00;X
L0F7EE1: db $20;X
L0F7EE2: db $80;X
L0F7EE3: db $04;X
L0F7EE4: db $01;X
L0F7EE5: db $00;X
L0F7EE6: db $00;X
L0F7EE7: db $09;X
L0F7EE8: db $10;X
L0F7EE9: db $19;X
L0F7EEA: db $00;X
L0F7EEB: db $10;X
L0F7EEC: db $24;X
L0F7EED: db $10;X
L0F7EEE: db $40;X
L0F7EEF: db $60;X
L0F7EF0: db $08;X
L0F7EF1: db $00;X
L0F7EF2: db $10;X
L0F7EF3: db $14;X
L0F7EF4: db $02;X
L0F7EF5: db $00;X
L0F7EF6: db $0A;X
L0F7EF7: db $40;X
L0F7EF8: db $26;X
L0F7EF9: db $24;X
L0F7EFA: db $00;X
L0F7EFB: db $23;X
L0F7EFC: db $03;X
L0F7EFD: db $00;X
L0F7EFE: db $44;X
L0F7EFF: db $20;X
L0F7F00: db $FF;X
L0F7F01: db $FB;X
L0F7F02: db $7F;X
L0F7F03: db $FF;X
L0F7F04: db $FF;X
L0F7F05: db $FF;X
L0F7F06: db $FF;X
L0F7F07: db $DD;X
L0F7F08: db $BF;X
L0F7F09: db $FF;X
L0F7F0A: db $FF;X
L0F7F0B: db $FF;X
L0F7F0C: db $F7;X
L0F7F0D: db $FD;X
L0F7F0E: db $FF;X
L0F7F0F: db $FF;X
L0F7F10: db $FF;X
L0F7F11: db $FF;X
L0F7F12: db $FF;X
L0F7F13: db $FF;X
L0F7F14: db $EF;X
L0F7F15: db $FB;X
L0F7F16: db $EF;X
L0F7F17: db $FF;X
L0F7F18: db $FF;X
L0F7F19: db $EF;X
L0F7F1A: db $FF;X
L0F7F1B: db $FF;X
L0F7F1C: db $FF;X
L0F7F1D: db $FF;X
L0F7F1E: db $BF;X
L0F7F1F: db $7F;X
L0F7F20: db $FF;X
L0F7F21: db $FE;X
L0F7F22: db $FF;X
L0F7F23: db $FF;X
L0F7F24: db $7F;X
L0F7F25: db $FF;X
L0F7F26: db $FF;X
L0F7F27: db $FF;X
L0F7F28: db $FF;X
L0F7F29: db $BB;X
L0F7F2A: db $FF;X
L0F7F2B: db $FF;X
L0F7F2C: db $FF;X
L0F7F2D: db $FF;X
L0F7F2E: db $FE;X
L0F7F2F: db $FF;X
L0F7F30: db $FF;X
L0F7F31: db $FF;X
L0F7F32: db $EF;X
L0F7F33: db $FF;X
L0F7F34: db $FF;X
L0F7F35: db $FF;X
L0F7F36: db $FF;X
L0F7F37: db $FF;X
L0F7F38: db $FF;X
L0F7F39: db $FE;X
L0F7F3A: db $FF;X
L0F7F3B: db $EF;X
L0F7F3C: db $FF;X
L0F7F3D: db $BE;X
L0F7F3E: db $FF;X
L0F7F3F: db $F7;X
L0F7F40: db $FE;X
L0F7F41: db $FF;X
L0F7F42: db $FF;X
L0F7F43: db $FF;X
L0F7F44: db $FF;X
L0F7F45: db $FF;X
L0F7F46: db $AF;X
L0F7F47: db $7B;X
L0F7F48: db $FF;X
L0F7F49: db $FF;X
L0F7F4A: db $F7;X
L0F7F4B: db $EF;X
L0F7F4C: db $FF;X
L0F7F4D: db $FB;X
L0F7F4E: db $F7;X
L0F7F4F: db $EF;X
L0F7F50: db $EF;X
L0F7F51: db $BF;X
L0F7F52: db $FF;X
L0F7F53: db $FF;X
L0F7F54: db $FF;X
L0F7F55: db $FF;X
L0F7F56: db $FF;X
L0F7F57: db $FF;X
L0F7F58: db $FF;X
L0F7F59: db $FF;X
L0F7F5A: db $FF;X
L0F7F5B: db $FF;X
L0F7F5C: db $3F;X
L0F7F5D: db $FB;X
L0F7F5E: db $FF;X
L0F7F5F: db $FB;X
L0F7F60: db $FF;X
L0F7F61: db $FF;X
L0F7F62: db $FF;X
L0F7F63: db $FF;X
L0F7F64: db $FF;X
L0F7F65: db $DF;X
L0F7F66: db $DF;X
L0F7F67: db $FF;X
L0F7F68: db $FF;X
L0F7F69: db $FD;X
L0F7F6A: db $FE;X
L0F7F6B: db $FF;X
L0F7F6C: db $FF;X
L0F7F6D: db $FF;X
L0F7F6E: db $DF;X
L0F7F6F: db $FF;X
L0F7F70: db $FF;X
L0F7F71: db $FF;X
L0F7F72: db $FF;X
L0F7F73: db $FF;X
L0F7F74: db $FF;X
L0F7F75: db $FF;X
L0F7F76: db $FF;X
L0F7F77: db $FF;X
L0F7F78: db $F7;X
L0F7F79: db $EF;X
L0F7F7A: db $FF;X
L0F7F7B: db $FE;X
L0F7F7C: db $FF;X
L0F7F7D: db $FF;X
L0F7F7E: db $EF;X
L0F7F7F: db $FF;X
L0F7F80: db $10;X
L0F7F81: db $20;X
L0F7F82: db $01;X
L0F7F83: db $00;X
L0F7F84: db $84;X
L0F7F85: db $90;X
L0F7F86: db $10;X
L0F7F87: db $80;X
L0F7F88: db $80;X
L0F7F89: db $00;X
L0F7F8A: db $80;X
L0F7F8B: db $01;X
L0F7F8C: db $23;X
L0F7F8D: db $08;X
L0F7F8E: db $49;X
L0F7F8F: db $20;X
L0F7F90: db $01;X
L0F7F91: db $00;X
L0F7F92: db $00;X
L0F7F93: db $00;X
L0F7F94: db $00;X
L0F7F95: db $05;X
L0F7F96: db $00;X
L0F7F97: db $02;X
L0F7F98: db $00;X
L0F7F99: db $00;X
L0F7F9A: db $08;X
L0F7F9B: db $20;X
L0F7F9C: db $00;X
L0F7F9D: db $80;X
L0F7F9E: db $02;X
L0F7F9F: db $04;X
L0F7FA0: db $80;X
L0F7FA1: db $81;X
L0F7FA2: db $04;X
L0F7FA3: db $01;X
L0F7FA4: db $00;X
L0F7FA5: db $80;X
L0F7FA6: db $01;X
L0F7FA7: db $00;X
L0F7FA8: db $C1;X
L0F7FA9: db $00;X
L0F7FAA: db $02;X
L0F7FAB: db $03;X
L0F7FAC: db $00;X
L0F7FAD: db $00;X
L0F7FAE: db $00;X
L0F7FAF: db $00;X
L0F7FB0: db $11;X
L0F7FB1: db $80;X
L0F7FB2: db $0A;X
L0F7FB3: db $08;X
L0F7FB4: db $04;X
L0F7FB5: db $06;X
L0F7FB6: db $A1;X
L0F7FB7: db $00;X
L0F7FB8: db $00;X
L0F7FB9: db $02;X
L0F7FBA: db $07;X
L0F7FBB: db $10;X
L0F7FBC: db $08;X
L0F7FBD: db $00;X
L0F7FBE: db $00;X
L0F7FBF: db $00;X
L0F7FC0: db $01;X
L0F7FC1: db $00;X
L0F7FC2: db $80;X
L0F7FC3: db $22;X
L0F7FC4: db $00;X
L0F7FC5: db $83;X
L0F7FC6: db $00;X
L0F7FC7: db $00;X
L0F7FC8: db $00;X
L0F7FC9: db $80;X
L0F7FCA: db $64;X
L0F7FCB: db $24;X
L0F7FCC: db $21;X
L0F7FCD: db $10;X
L0F7FCE: db $01;X
L0F7FCF: db $80;X
L0F7FD0: db $00;X
L0F7FD1: db $29;X
L0F7FD2: db $00;X
L0F7FD3: db $00;X
L0F7FD4: db $04;X
L0F7FD5: db $85;X
L0F7FD6: db $06;X
L0F7FD7: db $00;X
L0F7FD8: db $00;X
L0F7FD9: db $20;X
L0F7FDA: db $40;X
L0F7FDB: db $80;X
L0F7FDC: db $02;X
L0F7FDD: db $80;X
L0F7FDE: db $10;X
L0F7FDF: db $20;X
L0F7FE0: db $80;X
L0F7FE1: db $08;X
L0F7FE2: db $21;X
L0F7FE3: db $00;X
L0F7FE4: db $00;X
L0F7FE5: db $00;X
L0F7FE6: db $00;X
L0F7FE7: db $00;X
L0F7FE8: db $00;X
L0F7FE9: db $03;X
L0F7FEA: db $2A;X
L0F7FEB: db $85;X
L0F7FEC: db $00;X
L0F7FED: db $00;X
L0F7FEE: db $02;X
L0F7FEF: db $80;X
L0F7FF0: db $00;X
L0F7FF1: db $46;X
L0F7FF2: db $00;X
L0F7FF3: db $0C;X
L0F7FF4: db $00;X
L0F7FF5: db $00;X
L0F7FF6: db $00;X
L0F7FF7: db $02;X
L0F7FF8: db $11;X
L0F7FF9: db $04;X
L0F7FFA: db $84;X
L0F7FFB: db $08;X
L0F7FFC: db $40;X
L0F7FFD: db $04;X
L0F7FFE: db $13;X
L0F7FFF: db $CC;X
