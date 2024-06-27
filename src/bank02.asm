;
; BANK $02 - Actor system and SubCall targets; Actor code
;

; =============== ActS_ClearRAM ===============
; This subroutine blanks the RAM range for actors ($A200-$A2FF).
ActS_ClearRAM:
	ld   hl, sAct
	ld   de, (sAct_End - sAct)
.loop:
	xor  a			; Clear byte
	ldi  [hl], a
	dec  de
	ld   a, d		; Is DE != 0?
	or   a, e
	jr   nz, .loop	; If so, loop
	ret
; =============== mActS_NextProc ===============
mActS_NextProc: MACRO
	mActS_Next sActLastProc
ENDM

; =============== mActS_Next ===============
; Generates code to increment an actor slot counter.
; If it reaches the end of the slot count ($07) it will be reset to $00.
; IN
; - 1: Ptr to slot counter
mActS_Next: MACRO
	; sActNumProc = (sActNumProc + 1) % 8
	ld   a, [\1]
	inc  a
	cp   a, $07
	jr   c, .noWrap\@
	xor  a
.noWrap\@:
	ld   [\1], a
ENDM

; =============== ActS_Do ===============
; Handles gameplay actors during the frame.
; It also draws them to the screen, so this needs to run every frame.
ActS_Do:
	; Update the global timer
	ld   a, [sActTimer]
	inc  a
	ld   [sActTimer], a
	
	; After the freeze effect is done, always blank out the pal inversion effect
	; [BUG] This doesn't check for the game being paused, which leads to a variety of glitches.
IF FIX_BUGS == 1
	ld   a, [sPaused]
	and  a						; Is the game paused?
	jr   nz, .chkScrollSpawn	; If so, don't decrement the freeze timer
ENDC
	ld   a, [sPlFreezeTimer]
	or   a						; Is the effect set?
	jr   z, .chkScrollSpawn		; If not, jump
	dec  a			 			; FreezeTimer--
	ld   [sPlFreezeTimer], a
	
	or   a						; Reached 0 yet?
	jr   nz, .chkScrollSpawn	; If not, jump
	
	ld   a, [sPlFlags]		; Otherwise, reset the palette inversion effect
	res  OBJLSTB_OBP1, a
	ld   [sPlFlags], a
	
.chkScrollSpawn:
	; If we're in a boss room, prevent actors from spawning when scrolling the screen
	ld   a, [sBossRoom]
	or   a
	jr   nz, .noSpawn
	call ActS_InitByScroll
	call ActS_StunByLevelLayoutPtr
.noSpawn:

	; Execute the code of all actors as much as we can before we get close to the end of the frame.
	; A value is stored which marks the last processed actor number.
	;
	; To avoid lag and to keep some time for drawing the sprite mappings (if enabled),
	; not all actors are processed every frame; in the next frame
	; processing resumes from the slot after the last processed actor.
	;
	
	; A value in memory keeps track of this:
	ld   a, [sActLastProc]			; Start from the last processed actor
	ld   [sActNumProc], a
	xor  a							; Reset the counter for the frame
	ld   [sActProcCount], a
.nextActor:
	call ActS_CopyToSet
	call ActS_Execute
	call ActS_CopyFromSet
	mActS_Next sActNumProc
	;--
	; If we haven't (tried to) process all 7 slots, loop
	ld   a, [sActProcCount]		; SlotCount++
	inc  a
	ld   [sActProcCount], a
	cp   a, $07					; < $07?
	jr   c, .nextActor			; If so, loop
	;--
	
	; After all 7 actors are processed, draw all on-screen actors, starting from where
	; we left the last time.
	ld   a, [sActLastDraw]
	ld   [sActNumProc], a
	xor  a
	ld   [sActProcCount], a
.nextDraw:
	;--
	; Perform the lag check again if this isn't a boss room
	ld   a, [sBossRoom]
	or   a
	jr   nz, .chkTransparency
	
	; If we're dangerously close to VBlank time, skip drawing all actor OBJLst
	ldh  a, [rLY]
	cp   a, LY_VBLANK - $04 ; LY >= $8C?
	ret  nc					; If so, return
	;--
.chkTransparency:
	; Handle the transparency effect for the specified actor slot.
	; Simply skips drawing the OBJLst for an actor every other frame.
	; Could have been simply bit in the actor options but oh well.
	
	; Every other frame always write all OBJ
	ld   a, [sActTimer]
	bit  0, a
	jr   z, .writeOBJ
	
	; Is the effect pointing to a valid actor ID? (defaulting to $FF, so no)
	ld   a, [sActSlotTransparent]
	cp   a, $08				; >= $08?
	jr   nc, .writeOBJ		; If not, always draw every frame
	
	; Is the current actor slot the one we should apply the effect?
	ld   b, a				; B = Target Slot
	ld   a, [sActNumProc]	; A = Current Slot
	cp   a, b				; Does the slot match?
	jr   z, .skip			; If so, don't draw the OBJLst
.writeOBJ:
	call ActS_LoadAndWriteOBJLst
.skip:
	; Next actor / update stats
	mActS_Next sActNumProc
	ld   [sActLastDraw], a
	
	ld   a, [sActProcCount]	
	inc  a
	ld   [sActProcCount], a
	
	cp   a, $07				; Are we done yet?
	jr   c, .nextDraw			; If not, loop
	ret
; =============== ActS_Execute_SkipEmptySlot ===============
; Called when trying to execute an inactive actor slot.
; This simply updates the slot number of the last processed slot and returns.
ActS_Execute_SkipEmptySlot:
	mActS_NextProc
	ret
	
; =============== ActS_Execute ===============
ActS_Execute:
	; Is the slot empty?
	ld   a, [sActSet]
	or   a
	jr   z, ActS_Execute_SkipEmptySlot
	
	;--
	; If this is a boss room, disable the the lag reduction feature
	ld   a, [sBossRoom]		
	or   a
	jr   nz, .noLagChk
	
	ld   a, [sActLYLimit]	; B = Max allowed LY
	ld   b, a
	ldh  a, [rLY]			; A = Current LY
	cp   a, b				; Is A >= B?
	jr   nc, .skipProc		; if so, skip processing
	;--
.noLagChk:
	; Type $03 runs for one frame even if actors are meant to be paused
	ld   a, [sActSetActive]
	cp   a, $03
	jr   z, .executeOffScreen
	; Are all actors paused (and not execute)?
	ld   a, [sPauseActors]
	or   a
	jr   nz, .skipProc
	;--
	jr   .execute
.executeOffScreen:
	ld   a, $01
	ld   [sActSet], a
.execute:
	call ActS_JumpToCodePtr
	mActS_NextProc
	; After executing the actor code, reset the routine id/interaction mode.
	; This is because these routines are for "special interactions" that should
	; only be valid for one frame they are executed.
	;
	; This also saves on complexity (ie: we don't need to do anything to check
	; when the player stops standing on top of another actor)
	call ActS_ClearRoutineId
.skipProc:
	;
	; POST PROCESSING (despawn checks, ...)
	;

	; Did the actor despawn? (slow now considered empty)
	ld   a, [sActSet]
	or   a
	jp   z, ActS_RemoveFromOrigLocation
	
	;--
	;
	; Determine if the actor can be despawned when going off-screen.
	; There's an option flag for actors to prevent off-screen despawning.
	; Additionally, held actors will never despawn (which would be an issue if we went off-screen above).
	;

	; Check if the actor can despawn off-screen
	ld   a, [sActSetOpts]			; Is the "no despawn" flag set?
	bit  ACTFLAGB_NODESPAWNOFFSCREEN, a
	jr   nz, .chkStatusNoDespawn	; If so, jump
	; Check if we're holding an actor
	ld   a, [sActHeld]				; Are we holding any actor?
	or   a						
	jr   z, .chkStatus				; If not, jump
	; Are we holding exactly this slot?
	ld   a, [sActHeldSlotNum]	
	ld   c, a						; C = Held slot
	ld   a, [sActNumProc]			; A = Current slot
	cp   a, c						; Are they the same?
	jr   z, .chkStatusNoDespawn		; If so, jump
	;--
.chkStatus:
	; Update the offscreen flag
	call ActS_CheckOffScreen
	
	; Did the off-screen check mark the actor as a "free slot"?
	; If so, save its coords before the slot gets reused
	ld   a, [sActSet]
	or   a
	jr   z, ActS_SavePos	
	
	; If the actor is off-screen (but active) handle some misc options
	ld   a, [sActSet]
	cp   a, $01
	jp   z, ActS_DoOffScreenMisc
	ret
.chkStatusNoDespawn:
	; Update the offscreen flag (with despawn option removed)
	call ActS_CheckOffScreenNoDespawn
	; If the actor is on-screen, return
	ld   a, [sActSet]
	cp   a, $02
	ret  nc
	; Otherwise force reset the anim
	xor  a
	ld   [sActSetOBJLstId], a
	ret
; =============== ActS_SavePos ===============
; Saves the updated location of the current actor to the level layout.
; This also handles priority for conflicts, when 2 actors occupy the same location.
;
; Done before despawning an actor.
ActS_SavePos:
	; Reset anim timer
	xor  a
	ld   [sActSetOBJLstId], a
	
	;
	; Check if we should update the actor's location or restore the original.
	;
	; Every actor has set a ptr to the level layout data, which marks
	; its initial position in the level.
	; If we use that, we bascially restore the original state of the actor.
	;

	; Keys are handled in a special way since while it is a default actor,
	; it can save back an updated position
	ld   a, [sActSetId]
	cp   a, ACT_KEY
	jr   z, .key
	
	
	; Actors with the MSB set (ie: stun stars) shouldn't ever save back a location,
	; so we can return before writing back to the actor layout.
	bit  7, a
	ret  nz
	
	; Default actors (id >= $07) should always stay on their original location
	cp   a, ACT_DEFAULT_BASE				
	jr   nc, .useInitial
	
	; For other actors, a table marks how they should respawn.
	; Most have it set to $00, which allows to save back the updated position.
	ld   hl, sActRespawnTypeTbl	; HL = Respawn Type Tbl
	ld   a, [sActSetId]
	and  a, $7F					; DE = sActId & $7F (Filter away no-respawn flag)
	ld   d, $00
	ld   e, a
	add  hl, de					; Offset the table
	
	ld   a, [hl]				; Get the respawn option for the current actor ID
	or   a						; Is it 0?
	jr   nz, .useInitial		; If not, use the original spawn location
	;--
	jr   .saveToLayout
.key:
	; If a key is being both despawned and held at the same time,
	; it means we're triggering a room transition.
	; In that case, permanently remove the original key actor,
	; since one will be auto-spawned when entering the new room.
	
	ld   a, [sActHeldKey]
	or   a
	jr   nz, ActS_RemoveFromOrigLocation
.saveToLayout:
	;
	; Saves back the updated position to the level layout.
	; For all non-default actors and the key.
	;

	ld   a, [sActSetX_Low]			; DE = X Pos
	ld   e, a
	ld   a, [sActSetX_High]
	ld   d, a
	
	ld   a, [sActSetY_Low]			; BC = Y Pos - $08
	sub  a, $08					; (subtract)
	ld   c, a
	ld   a, [sActSetY_High]
	sbc  a, $00					; (account for carry)
	ld   b, a
	
	;--
	; Calculate the offset to the block in the level layout
	; just like how it's done in Level_DrawFullScreen
	
	; L = sActX / 16
	ld   a, e		; L = sActSetX_Low >> 4
	and  a, $F0					
	swap a
	ld   l, a
	
	ld   a, d		; A = sActSetX_High << 4
	and  a, $0F
	swap a
	
	or   a, l		; L |= A
	ld   l, a
	
	; H = sActY / 16
	ld   a, c		; H = sActSetY_Low >> 4
	and  a, $F0
	swap a
	ld   h, a
	
	ld   a, b		; A = sActSetY_High << 4
	and  a, $0F
	swap a
	
	or   a, h		; A |= H
	
	add  HIGH(wLevelLayout)	; Add over the level layout base
	ld   h, a
	;--
	
	; Mark the actor in the level layout
	set  7, [hl]
	
	; Check the actor priority if both occupy the same block
	; Since for any 16x16 block there can only be 1 actor ID associated with it
	
	; Keys have max priority, and replace anything
	ld   a, [sActSetId]
	cp   a, ACT_KEY					
	jr   z, .saveUpdated
	
	; Otherwise, check what was set here (for any previous slots)
	ld   b, h
	ld   c, l
	call ActS_GetIdByLevelLayoutPtr
	
	; If there's a default actor (>= $07) on the previous location, we have less priority
	; Don't save back the location (and permanently despawn it, as a result).
	cp   a, ACT_DEFAULT_BASE
	ret  nc
.saveUpdated:
	; There's nothing in the previous location or we have more priority
	ld   a, [sActSetId]
	call ActS_SaveIdFromLevelLayout
	ret
.useInitial:
	;
	; Saves back the original location from the actor layout
	; For all default actors except for the key.
	;
	
	; HL = Ptr to original location in level layout
	ld   a, [sActSetLevelLayoutPtr]
	ld   l, a
	ld   a, [sActSetLevelLayoutPtr+1]
	ld   h, a
	; Mark the presence of an actor
	set  7, [hl]
	
	; Get the existing (if any) actor ID from the location
	ld   b, h
	ld   c, l
	call ActS_GetIdByLevelLayoutPtr
	
	; Avoid overlapping with other default actors
	cp   a, $07
	ret  nc
	
	; Save the updated ID
	ld   a, [sActSetId]
	call ActS_SaveIdFromLevelLayout
	ret
; =============== ActS_RemoveFromOrigLocation ===============
; Performs a clean removal of the actor ID from a layout.
; This removes both the entries in the level layout and actor layout.
;
; While not strictly necessary, this prevents outdated actors from being "revived"
; when a different actor despawns in their location.
ActS_RemoveFromOrigLocation:
	; Clear timer
	xor  a
	ld   [sActSetOBJLstId], a
	; HL = Ptr to original (?) loc in level layout
	ld   a, [sActSetLevelLayoutPtr]
	ld   l, a
	ld   a, [sActSetLevelLayoutPtr+1]
	ld   h, a
	
	; Get the existing (if any) actor ID from the location
	ld   b, h
	ld   c, l
	call ActS_GetIdByLevelLayoutPtr
	
	; Avoid removing anything if there's already a default actor on top 
	; (which will replace ours anyway)
	cp   a, $07
	ret  nc
	;--
	
	; Delete the spawn flag in the level layout
	res  7, [hl]
	; Delete the actor layout entry
	xor  a
	call ActS_SaveIdFromLevelLayout
	ret
; =============== ActS_DoOffScreenMisc ===============
; Handles misc options for off-screen actors.
ActS_DoOffScreenMisc:
	; [TCRF] Unused option bit.
	; 		 If set, the actor will be instantly deleted (without respawning) when it goes off screen.
	ld   a, [sActSetOpts]
	bit  ACTFLAGB_UNUSED_FREEOFFSCREEN, a
	jr   nz, .unused_despawn
	; By default off-screen actors simply use OBJLstId $00
	xor  a
	ld   [sActSetOBJLstId], a
	ret
.unused_despawn:
	xor  a
	ld   [sActSet], a
	ret
; =============== ActBGColi_IsSolidOnTop_Coin ===============
; Variant of ActBGColi_IsSolidOnTop used for coins only.
; IN
; - A: Block ID
; OUT
; - A: If 1, the block is solid on top.
ActBGColi_IsSolidOnTop_Coin:
	; Coins should fall through used item boxes.
	cp   a, BLOCKID_ITEMUSED
	jp   z, ActBGColi_Ret0
; =============== ActBGColi_IsSolidOnTop ===============
; Checks if the specified block ID is solid on top (ie: when standing on it).
; Used strictly for actor-to-block collision.
; IN
; - A: Block ID
; OUT
; - A: If 1, the block is solid on top.
ActBGColi_IsSolidOnTop:
	cp   a, BLOCKID_TIMED0
	jp   z, ActBGColi_TimedSolid0
	cp   a, BLOCKID_TIMED1
	jp   z, ActBGColi_TimedSolid1
	cp   a, BLOCKID_LADDERTOP
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_ITEMBOX
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_LADDER
	jp   z, ActBGColi_Ret0
	; [TCRF] This block is not used, but curiously, is defined as solid for the player!
	cp   a, BLOCKID_UNUSED_ACTEMPTY
	jp   z, ActBGColi_Ret0
	
	cp   a, BLOCKID_SAND
	jp   z, ActBGColi_Ret0
	cp   a, BLOCKID_SANDSPIKE
	jp   z, ActBGColi_Ret0

	cp   a, BLOCKID_WATERHARDBREAK
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_WATERBREAK
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_WATERBREAK2
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_WATERBREAKTODOOR
	jp   z, ActBGColi_Ret1
	
	; The all-solid and all-empty checks got thrown in the middle here
	cp   a, BLOCKID_EMPTY		; >= $60?
	jp   nc, ActBGColi_Ret0	; If so, jump
	cp   a, BLOCKID_SOLID_END	; < $28?
	jp   c, ActBGColi_Ret1		; If so, jump
	
	;--
	; Useless check
	cp   a, BLOCKID_WATERCUR	; >= $4B?
	jp   nc, ActBGColi_Ret0	; If so, empty
	;--
	cp   a, BLOCKID_COIN		; >= $46?
	jp   nc, ActBGColi_Ret0	; If so, empty
	jp   ActBGColi_Ret1		; Rest is solid
; =============== ActBGColi_IsEmptyWaterBlock ===============
; Determines if block ID specified is for an "empty" water block.
; Used strictly for actor-to-block collision.
; IN
; - A: Block ID
; OUT
; - A: If *0*, this is an empty water block
ActBGColi_IsEmptyWaterBlock:
	; This returns 0 for blocks:
	; - BLOCKID_WATER ($4A)
	; - BLOCKID_WATERCURU ($4C)
	; - BLOCKID_WATERCURD ($4D)
	; - BLOCKID_WATERCURL ($4E)
	; - BLOCKID_WATERCURR ($4F)
	; - BLOCKID_WATERCOIN ($53)
	; - BLOCKID_WATER2 ($55)
	; - BLOCKID_WATER3 ($56)
	; - BLOCKID_WATER4 ($57)
	; - BLOCKID_WATER5 ($58)
	; - BLOCKID_WATERSPIKE ($59)
	; - BLOCKID_UNUSED_WATERSPIKE2 ($5A)
	; - BLOCKID_WATERDOORTOP ($5B)
	; - BLOCKID_INSTAKILL ($5C)
	; - BLOCKID_SPIKE ($5D)
	; - BLOCKID_SPIKE2 ($5E)
	; - BLOCKID_SPIKEHIDE ($5F)
	;
	; [BUG] They forgot to check for BLOCKID_WATERDOOR!
	;       This causes Act_Seal to get stuck if placed between
	;       the door and a solid wall in C27.
	cp   a, BLOCKID_WATER				; == $4A
	jp   z, ActBGColi_Ret0
IF FIX_BUGS == 1
	cp   a, BLOCKID_WATERDOOR			; == $4B
	jp   z, ActBGColi_Ret0
ENDC
	cp   a, BLOCKID_WATERHARDBREAK		; not == $50
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_WATERBREAK			; not == $51
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_WATERBREAK2			; not == $52
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_WATERBREAKTODOOR	; not == $54
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_WATERCUR			; not < $4C
	jp   c, ActBGColi_Ret1
	cp   a, BLOCKID_EMPTY				; not >= 60
	jp   nc, ActBGColi_Ret1
	jp   ActBGColi_Ret0				; The rest is empty water
	
; =============== ActBGColi_IsSpikeBlock ===============
; Determines if block ID specified is for a spike/damaging block.
; Used strictly for actor-to-block collision.
; IN
; - A: Block ID
; OUT
; - A: If 1, the block is damaging
ActBGColi_IsSpikeBlock:
	; This returns 1 for blocks:
	; - BLOCKID_SANDSPIKE ($3F)
	; - BLOCKID_WATERSPIKE ($59)
	; - BLOCKID_UNUSED_WATERSPIKE2 ($5A)
	; - BLOCKID_INSTAKILL ($5C)
	; - BLOCKID_SPIKE ($5D)
	; - BLOCKID_SPIKE2 ($5E)
	; - BLOCKID_SPIKEHIDE ($5F)
	cp   a, BLOCKID_SANDSPIKE		; == $3F
	jp   z, ActBGColi_Ret1			; 
	cp   a, BLOCKID_WATERSPIKE		; not < $59
	jp   c, ActBGColi_Ret0			; 
	cp   a, BLOCKID_EMPTY			; not >= $60
	jp   nc, ActBGColi_Ret0		; 
	cp   a, BLOCKID_WATERDOORTOP	; not == $5B
	jp   z, ActBGColi_Ret0			;
	jp   ActBGColi_Ret1			; rest is spike
; =============== ActBGColi_IsSolid ===============
; Determines if block ID specified is a fully solid block.
; Used strictly for actor-to-block collision.
; IN
; - A: Block ID
; OUT
; - A: If 1, the block is fully solid
ActBGColi_IsSolid:
	; Alternating timed platform
	cp   a, BLOCKID_TIMED0
	jp   z, ActBGColi_TimedSolid0
	cp   a, BLOCKID_TIMED1
	jp   z, ActBGColi_TimedSolid1
	
	cp   a, BLOCKID_LADDERTOP		
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_ITEMBOX
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_LADDER
	jp   z, ActBGColi_Ret0
	cp   a, $3D
	jp   z, ActBGColi_Ret0
	cp   a, BLOCKID_SAND
	jp   z, ActBGColi_Ret0
	cp   a, BLOCKID_SANDSPIKE
	jp   z, ActBGColi_Ret0
	cp   a, BLOCKID_WATERHARDBREAK
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_WATERBREAK
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_WATERBREAK2
	jp   z, ActBGColi_Ret1
	cp   a, BLOCKID_WATERBREAKTODOOR
	jp   z, ActBGColi_Ret1
	
	; The all-solid and all-empty checks got thrown in the middle here
	cp   a, BLOCKID_EMPTY		; >= $60?
	jp   nc, ActBGColi_Ret0		; If so, jump
	cp   a, BLOCKID_SOLID_END	; < $28?
	jp   c, ActBGColi_Ret1		; If so, jump
	
	cp   a, BLOCKID_WATERCUR	; not >= $4C
	jp   nc, ActBGColi_Ret0
	cp   a, BLOCKID_COIN		; not < $46
	jp   nc, ActBGColi_Ret0
	cp   a, $40					; not == $40
	jp   z, ActBGColi_Ret0
	cp   a, $41					; not == $41
	jp   z, ActBGColi_Ret0
	cp   a, $42					; not == $42
	jp   z, ActBGColi_Ret0
	cp   a, $43					; not == $43
	jp   z, ActBGColi_Ret0
	; Everything else is just treated as solid
	jp   ActBGColi_Ret1
	
; =============== ActBGColi_Ret0 ===============
; Used for either returning 0, or marking an empty block (same constant value).
ActBGColi_Ret0:
	ld   a, COLI_EMPTY
	ret
; =============== ActBGColi_Ret1 ===============
; Used for either returning 1, or marking a solid block (same constant value).
ActBGColi_Ret1:
	ld   a, COLI_SOLID
	ret
	
; =============== ActBGColi_TimedSolid ===============
; Collision for disappearing/reapparing platform.
; These are aligned with the $00-$03 tile anim frames.
; These subroutine take advantage of COLI_EMPTY being 0 and COLI_SOLID being 1.
; OUT
; - A: If 1, the block is solid
ActBGColi_TimedSolid0:
	; Frame 0 is the empty one
	ld   a, [sLevelAnimFrame]
	or   a
	jr   z, ActBGColi_Ret0
	; Otherwise treat like a normal platform
	ld   a, COLI_SOLID
	ret
ActBGColi_TimedSolid1:
	; Frame 2 is the empty one
	ld   a, [sLevelAnimFrame]
	cp   a, $02
	jr   z, ActBGColi_Ret0
	; Otherwise treat like a normal platform
	ld   a, COLI_SOLID
	ret

; =============== ActS_PlStand_MoveRight ===============
; Performs the automatic player movement to the right,
; meant to be called only when the player is standing on an actor moving right.
ActS_PlStand_MoveRight:
	; This piggybacks off DoAutoScroll, so it automatically performs collision checks.
	ld   a, DIR_R						; Set temp autoscroll direction
	ld   [sLvlAutoScrollDir], a
	ld   b, $00
	mSubCall Level_Scroll_DoAutoScroll
	xor  a								; Reset autoscroll dir
	ld   [sLvlAutoScrollDir], a
	ret
; =============== ActS_PlStand_MoveLeft ===============
; Performs the automatic player movement to the left,
; meant to be called only when the player is standing on an actor moving left.
ActS_PlStand_MoveLeft:
	ld   a, DIR_L						; Set temp autoscroll direction
	ld   [sLvlAutoScrollDir], a
	ld   b, $00
	mSubCall Level_Scroll_DoAutoScroll
	xor  a								; Reset autoscroll dir
	ld   [sLvlAutoScrollDir], a
	ret
; =============== Act_Null ===============
; Dummy actor for unassigned slots in actor groups; not meant to be used.
Act_Null: 
	ret
; =============== ActS_Unused_TurnToIntDir ===============
; [TCRF] Unreferenced helper subroutine.
;        Makes the current actor turn to the direction it's being interacted/hit from.
;        ie: if the actor is interacted from the left (ACTINTB_L), it will turn left.
ActS_Unused_TurnToIntDir:
	ld   a, [sActSetRoutineId]
	and  a, $F0					; Get interaction direction
	swap a
	ld   [sActSetDir], a
	ret	

; =============== ActS_SaveColiType ===============
; Saves the collision type of the current actor to a temporary table.
; Used along with ActS_RestoreColiType for restoring the previous
; collision type when making temporary changes to the collisioh type.
ActS_SaveColiType:
	; Index the temporary collision type table
	ld   hl, sActColiSaveTbl	; HL = Table start
	ld   a, [sActNumProc]		; DE = sActNumProc * 2
	add  a
	ld   d, $00
	ld   e, a
	add  hl, de					; Offset it
	
	ld   a, [sActSetColiType]	; Save the current collision type there
	ld   [hl], a
	ret
	
; =============== ActS_RestoreColiType ===============
; Restore the previously saved collision type of the current actor.
ActS_RestoreColiType:
	; Index the temporary collision type table
	ld   hl, sActColiSaveTbl	; HL = Table start
	ld   a, [sActNumProc]		; DE = sActNumProc * 2
	add  a
	ld   d, $00
	ld   e, a
	add  hl, de					; Offset it
	
	ld   a, [hl]				; Restore the collision type
	ld   [sActSetColiType], a
	ret
; =============== ActS_GetIdByLevelLayoutPtr2 ===============
; Falls through ActS_GetIdByLevelLayoutPtr, just using HL instead of BC.
; IN
; - HL: Ptr to level layout
; OUT
; -  A: Actor ID
; - BC: Ptr to actor layout	
ActS_GetIdByLevelLayoutPtr2:
	ld   b, h
	ld   c, l
; =============== ActS_GetIdByLevelLayoutPtr ===============
; Gets the actor ID and its location in the actor layout from the
; specified location in the level layout.
; IN
; - BC: Ptr to level layout
; OUT
; -  A: Actor ID
; - BC: Ptr to actor layout
ActS_GetIdByLevelLayoutPtr:
	;--
	
	;
	; Determine the offset to the actor ID in its area ($B000-$BFFF)
	;
	
	; Remove the $C000 base to get the block offset
	; $1F = HIGH(wLevelLayout_End - wLevelLayout) - $01
	ld   a, b	
	and  a, $1F ; sub $C0
	ld   b, a
	
	; 1 byte in the actor layout stores IDs for 2 level blocks
	; so divide BC by 2
	xor  a
	srl  b			
	rr   c
	
	; The carry from BC becomes the odd/even indicator (determines nybble to pick)
	; because of this it's set in bit 7
	rra
	ld   d, a
	
	; Add the $B000 base to get the offset to the actor layout.
	; can be or'd since the max is $0FFF
	ld   a, b
	or   a, HIGH(sActLayout) ; add $B0 
	ld   b, a
	;--
	
	ld   a, [bc]		; Read the pair of actor IDs
	
	; Get the correct actor id
	; Which nybble?
	bit  7, d
	jr   nz, .lowNybble
.highNybble:
	and  a, $F0	; Id = A >> 4
	swap a		
	ret
.lowNybble:
	and  a, $0F	
	ret
; =============== ActS_SaveIdFromLevelLayout ===============
; Saves the specified actor ID to the actor layout, based on the
; specified location in the level layout.
; IN
; -  A: Actor ID to save
; - HL: Ptr to level layout
ActS_SaveIdFromLevelLayout:

	; E = Filtered actor ID
	and  a, $0F
	ld   e, a

	;--
	;
	; Determine the offset to the actor ID in its area ($B000-$BFFF)
	; just like in ActS_GetIdByLevelLayoutPtr
	
	; Get block offset relative to level layout
	ld   a, h
	and  a, $1F ; - $C000
	ld   h, a
	
	; HL >> 1
	xor  a
	srl  h
	rr   l
	
	; Save odd/even indicator
	rra
	ld   d, a
	
	; Add actor layout ptr base
	ld   a, h
	or   a, HIGH(sActLayout)
	ld   h, a
	;--
	
	; High or low nybble?
	bit  7, d
	jr   nz, .lowNybble
.highNybble:
	ld   a, e		; E = ActorID << 4
	swap a
	ld   e, a
	ld   a, [hl]	; Merge with existing value in low nybble
	and  a, $0F
	or   a, e
	ld   [hl], a	; Save back
	ret
.lowNybble:
	ld   a, [hl]	; Merge with existing value in high nybble
	and  a, $F0
	or   a, e
	ld   [hl], a	; Save back
	ret
	
; =============== ActS_CopyToSet ===============	
; Copies the current Act data from the 'Main' area to the 'Set' area.
; Used to prepare an actor data for processing.
ActS_CopyToSet:;C
	; Determine the offset to the current actor "main" entry
	ld   a, [sActNumProc]	
	swap a					; DE = sActNumProc * $20 (<< 5)
	rlca					
	ld   d, $00
	ld   e, a
	ld   hl, sAct
	add  hl, de				; Offset it
	
	;--
	; Copy all the actor data to the request area.
	ld   bc, sActSet			
	ld   d, ($20-$01)		; D = Bytes to copy
							; (excluding status, which is out of the loop)
	
	; Always copy over the first byte, which marks active status.
	ldi  a, [hl]			
	ld   [bc], a
	
	or   a					; Is the slot empty? (active status $00)
	ret  z					; If so, return and don't copy other bytes
	
	; Copy the remaining $1F bytes over
	inc  bc
.loop:
	ldi  a, [hl]			
	ld   [bc], a
	inc  bc
	dec  d
	jr   nz, .loop
	;--
	ret
; =============== ActS_CopyFromSet ===============	
; Copies the current Act data from the 'Set' area to the 'Main' area.
; Used to save the changes to the actor data after processing.
ActS_CopyFromSet:
	; Determine the offset to the current actor "main" entry
	ld   a, [sActNumProc]
	swap a					; DE = sActNumProc * $20 (<< 5)
	rlca
	ld   d, $00
	ld   e, a
	ld   hl, sAct
	add  hl, de				; Offset it
	
	;--
	; Copy all the actor data out of the request area to the location we just offsetted.
	ld   bc, sActSet
	ld   d, ($20-$01)		; D = Bytes to copy
							; (excluding status, which is out of the loop)
							
	; Always copy over the first byte, which marks active status.
	ld   a, [bc]			
	ldi  [hl], a
	
	or   a					; Is the slot empty? (active status $00)
	ret  z					; If so, return and don't copy other bytes
	
	; Copy the remaining $1F bytes over
	inc  bc
.loop:
	ld   a, [bc]
	ldi  [hl], a
	inc  bc
	dec  d
	jr   nz, .loop
	ret
	
; =============== ActS_SaveAllPos ===============
; Saves the updated location of all active actors in the level layout.
; Used before unloading all actors in room transitions.
ActS_SaveAllPos:
	ld   de, $0000
	xor  a
	ld   [sActNumProc], a
.loop:
	;--
	; Do this for all 7 actor slots.
	call ActS_CopyToSet		
	ld   a, [sActSet]			
	or   a						; Is this a free slot?
	call nz, ActS_SavePos		; If not, process it
	call ActS_CopyFromSet
	;--
	ld   a, [sActNumProc]	; CurActor++
	inc  a
	ld   [sActNumProc], a
	cp   a, $07				; Processed all 7 actors? (sActNumProc >= 7)
	ret  nc					; If so, return
	jr   .loop
	
; =============== ActS_InitByScroll ===============
; This subroutine is used to initialize all needed actors on the edge of the screen
; after the screen scrolls.
ActS_InitByScroll:

	; Calculate the offset to the level layout (ie: lvlscroll / 16)
	; Note how we aren't accounting for the LVLSCROLL offset here; it would be a waste to do so immediately.
	
	; [POI] While not necessary, sLvlScrollY (or sActLevelLayoutOffset_High) is never made sure to be in valid range.
	;       This is a problem with the scroll glitch, since it will try to load actors from god knows where.
	;       And possibly crash the game as a result.
	
	;       This isn't a problem with the X coord because the level length is high enough
	;		that all possible values for sActLevelLayoutOffset_Low are valid.
	;       $1000 / $10 is exactly what fits in a byte, however any actors spawned by this truncation
	;		would get immediately despawned for being off-screen.
	
	;		The Y coordinate though only goes up to $200, leaving blank spaces unaccounted for.
	
	; High byte
	; B = sLvlScrollY / $10
	ld   a, [sLvlScrollY_Low]
	swap a						; high nybble >> 4
	and  a, $0F
	ld   b, a
	ld   a, [sLvlScrollY_High]
	swap a						; low nybble << 4
	and  a, $F0					; sum them
	or   a, b
	ld   [sActLevelLayoutOffset_High], a
	
	; Low byte
	; C = sLvlScrollX / $10
	ld   a, [sLvlScrollX_Low]
	swap a						; high nybble >> 4
	and  a, $0F
	ld   c, a
	ld   a, [sLvlScrollX_High]
	swap a						; low nybble << 4
	and  a, $F0
	or   a, c					; sum them
	ld   [sActLevelLayoutOffset_Low], a
	
	; Only spawn actors if we moved to a different block X compared to the last frame.
	; We don't want to spawn and respawn actors over and over.
	ld   b, a		
	ld   a, [sActLevelLayoutOffsetLast_Low]
	cp   a, b
	jr   z, .checkY	; If not, jump
	
	; Otherwise update the copy value
	ld   a, b		
	ld   [sActLevelLayoutOffsetLast_Low], a
	; Then determine the horizontal direction we've moved to
	ld   a, [sLvlScrollDirAct]
	bit  DIRB_R, a
	call nz, ActS_InitByRightScroll
	ld   a, [sLvlScrollDirAct]
	bit  DIRB_L, a
	call nz, ActS_InitByLeftScroll
.checkY:

	; Perform the same block check for the Y offset.
	; Is it different compared to the last frame?
	ld   a, [sActLevelLayoutOffset_High]
	ld   b, a
	ld   a, [sActLevelLayoutOffsetLast_High]
	cp   a, b
	ret  z	; If not, return
	
	; Otherwise update the copy value
	ld   a, b
	ld   [sActLevelLayoutOffsetLast_High], a
	
	; Then determine the vertical direction we've moved to
	ld   a, [sLvlScrollDirAct]
	bit  DIRB_U, a
	call nz, ActS_InitByUpScroll
	ld   a, [sLvlScrollDirAct]
	bit  DIRB_D, a
	call nz, ActS_InitByDownScroll
	ret
; =============== ActS_InitScreenActors ===============
; This subroutine initializes all actors in the range of the visible screen area.
; (+ off-screen border areas)
; Used when loading a new room.
ActS_InitScreenActors:
	; Calculate the offset to the block in the level layout
	; like in Level_DrawFullScreen
	; (but we save the results to memory)
	
	; B = sLvlScrollY / 16
	ld   a, [sLvlScrollY_Low]
	swap a						; low nybble
	and  a, $0F
	ld   b, a
	ld   a, [sLvlScrollY_High]
	swap a						; high nybble
	and  a, $F0
	or   a, b
	ld   [sActLevelLayoutOffset_High], a
	; C = sLvlScrollX / 16
	ld   a, [sLvlScrollX_Low]
	swap a						; low nybblw
	and  a, $0F
	ld   c, a
	ld   a, [sLvlScrollX_High]
	swap a						; high nybble
	and  a, $F0
	or   a, c
	ld   [sActLevelLayoutOffset_Low], a
	;--
	
	; Initialize all actors around a $0E*$0B region of blocks,
	; where sActLevelLayoutOffset points to (more or less) the center area.
	; 
	
ACTLOAD_RANGE_X EQU $0E
ACTLOAD_RANGE_Y EQU $0B
	
	; BC = Top left corner of this area
	ld   a, [sActLevelLayoutOffset_Low]
	sub  a, $07 ; ACTLOAD_RANGE_X / 2
	ld   c, a
	ld   a, [sActLevelLayoutOffset_High]
	sub  a, $06 ; CEIL(ACTLOAD_RANGE_Y / 2)
	ld   b, a
	
	; Offset the level layout
	ld   hl, wLevelLayout
	add  hl, bc
	
	; For each block in the range, initialize the actors
	ld   d, ACTLOAD_RANGE_Y
.nextY:
	ld   e, ACTLOAD_RANGE_X
	;--
	push hl
.nextX:
	; Did we reach the end of the layout data?
	ld   a, h
	cp   a, HIGH(wLevelLayout_End)
	jr   nc, .skip		; If so, skip the byte
	;--
	; If there's an actor over this block, initialize it
	bit  7, [hl]
	call nz, ActS_InitByLevelLayoutPtr
.skip:
	inc  hl				; X++
	dec  e				; Finished the row?
	jr   nz, .nextX		; If not, loop
	
	pop  hl				; Restore start of row
	;--
	inc  h				; Y++				
	dec  d				; Finished all the rows?
	jr   nz, .nextY		; If not, loop
	ret
; =============== ActS_InitByRightScroll ===============
; Sets of subroutines for spawning actors when the screen scrolls to a certain direction.
;
; What this does is spawn all actors currently on a column/row of blocks, depending on the direction.
ActS_InitByRightScroll:
	; Determine the level layout ptr to the topmost block in the "spawn column".
	; Note that the source offset doesn't account for the LVLSCROLL offset.
	
	; With that accounted for, the block offset is:
	; - 11 blocks right
	; -  2 blocks up
	; (all relative to the topleft corner of the screen)
	
	ld   a, [sActLevelLayoutOffset_Low]
	add  -LVLSCROLL_XBLOCKOFFSET+$0B ; $06
	ld   c, a
	ld   a, [sActLevelLayoutOffset_High]
	sub  a, LVLSCROLL_YBLOCKOFFSET+$02 ; $06
	ld   b, a
	
	ld   hl, wLevelLayout		; Add the level layout base
	add  hl, bc
	
	; Init all actors that are on spawn column
	ld   e, $0D		; E = Blocks in column
.loop:
	; [BUG] All of the ActS_InitBy*Scroll subroutines do incomplete validation on the level layout ptr.
	;		since it doesn't account for the ptr overflowing.
	;
	;		The check that's here is all that's normally needed when staying in the level range,
	;		but with the scroll glitch it's possible to overflow underflow HL.
	;		If the spawn checks succeed and the game gets to ActS_InitToSlot, 
	;		the game will most likely crash by accidentally disabling SRAM (set/res HL on ROM).
	;
	;		This is the only reason the game can crash while doing the scroll glitch.
	
	; Have we reached the end of level layout?
	; (done in case we're near the bottom of the level)
	ld   a, h		
	cp   a, HIGH(wLevelLayout_End)		; LayoutPtr >= LayoutEnd?
	ret  nc								; If so, don't spawn it
	IF FIX_BUGS == 1
		cp   a, HIGH(wLevelLayout)	; LayoutPtr < LayoutStart?
		ret  c								; If so, don't spawn it
	ENDC
	; If there's an actor on this block (MSB set), spawn it
	bit  7, [hl]
	call nz, ActS_InitByLevelLayoutPtr
	inc  h					; Move 1 block down
	
	dec  e					; BlocksLeft--
	jr   nz, .loop			; Are we done yet?
	ret
	
; =============== ActS_InitByLeftScroll ===============
ActS_InitByLeftScroll:

	; Get the starting level layout ptr for the column
	; Offset:
	; - 2 blocks left
	; - 2 blocks up
	ld   a, [sActLevelLayoutOffset_Low]
	sub  a, LVLSCROLL_XBLOCKOFFSET+$02
	ld   c, a
	ld   a, [sActLevelLayoutOffset_High]
	sub  a, LVLSCROLL_YBLOCKOFFSET+$02
	ld   b, a
	ld   hl, wLevelLayout
	add  hl, bc
	
	; Spawn all actors in the column
	ld   e, $0D
.loop:
	; Have we reached the end of level layout?
	ld   a, h		
	cp   a, HIGH(wLevelLayout_End)		; LayoutPtr >= LayoutEnd?
	ret  nc								; If so, don't spawn it
	IF FIX_BUGS == 1
		cp   a, HIGH(wLevelLayout)	; LayoutPtr < LayoutStart?
		ret  c								; If so, don't spawn it
	ENDC
	; If there's an actor on this block (MSB set), spawn it
	bit  7, [hl]
	call nz, ActS_InitByLevelLayoutPtr
	inc  h					; Move 1 block down
	
	dec  e
	jr   nz, .loop
	ret
; =============== ActS_InitByUpScroll ===============
ActS_InitByUpScroll:

	; Get the starting level layout ptr for the row
	; Offset:
	; - 2 blocks left
	; - 2 blocks up
	ld   a, [sActLevelLayoutOffset_Low]
	sub  a, LVLSCROLL_XBLOCKOFFSET+$02
	ld   c, a
	ld   a, [sActLevelLayoutOffset_High]
	sub  a, LVLSCROLL_YBLOCKOFFSET+$02
	ld   b, a
	ld   hl, wLevelLayout
	add  hl, bc
	
	; Spawn all actors in the row
	ld   e, $0E
.loop:
	; Have we reached the end of level layout?
	ld   a, h		
	cp   a, HIGH(wLevelLayout_End)		; LayoutPtr >= LayoutEnd?
	ret  nc								; If so, don't spawn it
	IF FIX_BUGS == 1
		cp   a, HIGH(wLevelLayout)	; LayoutPtr < LayoutStart?
		ret  c								; If so, don't spawn it
	ENDC
	; If there's an actor on this block (MSB set), spawn it
	bit  7, [hl]
	call nz, ActS_InitByLevelLayoutPtr
	inc  hl					; Move 1 block right
	
	dec  e
	jr   nz, .loop
	ret
; =============== ActS_InitByDownScroll ===============
ActS_InitByDownScroll:

	; Get the starting level layout ptr for the row
	; Offset:
	; - 2  blocks left
	; - 10 blocks down
	ld   a, [sActLevelLayoutOffset_Low]
	sub  a, LVLSCROLL_XBLOCKOFFSET+$02
	ld   c, a
	ld   a, [sActLevelLayoutOffset_High]
	add  -LVLSCROLL_YBLOCKOFFSET+$0A
	ld   b, a
	ld   hl, wLevelLayout
	add  hl, bc
	
	; Spawn all actors in the row
	ld   e, $0E
.loop:
	; Have we reached the end of level layout?
	ld   a, h		
	cp   a, HIGH(wLevelLayout_End)		; LayoutPtr >= LayoutEnd?
	ret  nc								; If so, don't spawn it
	IF FIX_BUGS == 1
		cp   a, HIGH(wLevelLayout)	; LayoutPtr < LayoutStart?
		ret  c								; If so, don't spawn it
	ENDC
	; If there's an actor on this block (MSB set), spawn it
	bit  7, [hl]
	call nz, ActS_InitByLevelLayoutPtr
	inc  hl					; Move 1 block right
	
	dec  e
	jr   nz, .loop
	ret
	
; =============== ActS_InitByLevelLayoutPtr ===============
; This subroutine initializes the actor enabled on the specified level block.
; IN
; - HL: Ptr to level layout
ActS_InitByLevelLayoutPtr:
	; Save HL to mem
	ld   a, h							
	ld   [sActLevelLayoutPtr_High], a	
	ld   a, l
	ld   [sActLevelLayoutPtr_Low], a
	push af
	push bc
	push de
	push hl
	; BC = Ptr to level layout
	ld   b, h
	ld   c, l
	;--
	call SubCall_ActS_GetIdByLevelLayoutPtr
	or   a					; Is the actor id $00?
	jr   z, .end			; If so, skip everthing
	
	ld   [sActSetId], a		; Set the found actor ID
	
	call ActS_FindFirstFreeSlot ; Seek to the first free slot
	ld   a, b
	cp   a, $FF				; Did we found any? (slotNum != $FF)
	call nz, ActS_InitToSlot; If so, initialize the actor to this slot
	;--
.end:
	pop  hl
	pop  de
	pop  bc
	pop  af
	ret
; =============== ActS_FindFirstFreeSlot ===============
; Finds the first free actor slot.
; OUT
; - HL: Ptr to actor slot
; -  B: Slot number. If $FF, there's no free slot.
ActS_FindFirstFreeSlot:
	; Determine how many slots to search for.
	; Normal actors have 5 slots.
	; Default actors have 2 extra slots.
	ld   c, $05					
	cp   a, ACT_DEFAULT_BASE	; Actor ID < $07?
	jr   c, .start				; If so, no extra slots
	ld   c, $07					
.start:
	ld   hl, sAct	; HL = Start ptr
	ld   de, $0020	; DE = Size of actor data
	ld   b, $00
.loop:
	ld   a, [hl]	; Read the status byte
	or   a			; Is this a free slot?
	ret  z			; If so, we're done
	
	add  hl, de		; Next Actor slot
	inc  b
	ld   a, b
	cp   a, c		; Have we reached the limit?
	jr   c, .loop	; If not, search in the next
.noSlots:
	ld   b, $FF
	ret
	
	
; =============== ActS_SetIndexedOBJLstPtrTable*** ===============
; Sets of subroutines which follow the same template.
; See also: ActS_SetIndexedOBJLstPtrTable
;
; These subroutines set a new OBJLstPtrTable for the actor -- and reset the OBJLstId.
; The new table ptr is picked through the shared table as seen in ActS_SetIndexedOBJLstPtrTable.
; while the index used depends on the subroutine called.
;

; =============== mActS_SetOBJLstShared ===============
; This macro generates code to use a pair of OBJLstSharedPtrTable shared indexes.
; These indexes will be used for all "generic actors" (ie: ActS_Throw) that
; need to be executed under multiple different actors.
; IN
; - 1: Shared tbl offset (facing left)
; - 2: Shared tbl offset (facing right)
mActS_SetOBJLstShared: MACRO
	; Use the shared parent offset depending on the direction it's facing.
	; Yes, the game uses different OBJLst depending on the actor's direction,
	; likely to save on processing time.
	ld   bc, \1				; B = Index for facing left
	ld   a, [sActSetDir]	
	bit  DIRB_R, a			; Is the actor facing right?
	jr   z, .set			; If not, jump
	ld   bc, \2				; B = Index for facing right
.set:
	call ActS_SetIndexedOBJLstPtrTable
	ret
ENDM

; =============== ActS_Unused_SetIndexedOBJLstPtrTable_00_02 ===============
; [TCRF] Offsets $00 and $02 are never used outside of unreferenced code.
;		 They may have been for an alternate stun animation (or death?)
ActS_Unused_SetIndexedOBJLstPtrTable_00_02: mActS_SetOBJLstShared $00, $02
; =============== ActS_SetRecoverOBJLst ===============
; Used when the actor recovers from a stun.
ActS_SetRecoverOBJLst: mActS_SetOBJLstShared ACTOLP_RECOVERL, ACTOLP_RECOVERR
; =============== ActS_SetStunOBJLst ===============
; Used when the actor is stunned or dead.
ActS_SetStunOBJLst: mActS_SetOBJLstShared ACTOLP_STUNL, ACTOLP_STUNR
; =============== ActS_Unused_StartJumpDeadOnPlBig ===============
; [TCRF] Unreferenced code.
; Makes the currently processed actor die with the jump animation, but only if the player is big.
; If the player is Small Wario, it just gets stunned instead and slides on the ground for a bit.
; No actor has this behaviour in the final game.
ActS_Unused_StartJumpDeadOnPlBig:
	ld   a, [sPlPower]		; A = Current powerup state
	and  a, $0F				; Filter away upper nybble
	; Weird that it jumps to stubs instead of the real subroutines
	jp   nz, ActS_Unused_DoStartJumpDeadStub		; If we aren't small, jump
	jp   ActS_Unused_StartStunGroundMoveStub		; Otherwise, jump here
	
; =============== ActS_StartHeld ===============
; Init code for setting the currently processed actor in the held state.
; This should be called only when an actor is stunned.
ActS_StartHeld:
	ld   a, [sActHeld]
	or   a						; Are we already holding something?
	jp   nz, ActS_StartJumpDead	; If so, kill the actor instead
								; and continue holding whatever we have
; =============== ActS_StartHeldForce ===============
; Like ActS_StartHeld, except the new actor is held anyway,
; causing to kill whatever we were holding previously.
; Used in practice only for Treasures, which don't handle the held state by themselves.
ActS_StartHeldForce:
	;--
	; Determine if the actor is heavy or not
	ld   a, $01					; Default to true
	ld   [sActHoldHeavy], a
	ld   a, [sActSetOpts]
	bit  ACTFLAGB_HEAVY, a		; If bit 7 of the options set?
	jr   nz, .setHeld			; If so, confirm the heavy status
	xor  a						; Otherwise set to false
	ld   [sActHoldHeavy], a
	;--
.setHeld:
	xor  a						; Reset anim frame
	ld   [sActSetOBJLstId], a
	ld   bc, SubCall_ActS_Held	; Set code ptr for held actors
	call ActS_SetCodePtr
	xor  a						; Reset timer
	ld   [sActSetTimer], a
	ld   [sActHeldDelay], a
	ld   a, $00					; Set as intangible, since held actor collision is special
	ld   [sActSetColiType], a
	ld   a, $01					; Set held status
	ld   [sActHeld], a
	ld   a, SFX1_0B			; Play grab SFX
	ld   [sSFX1Set], a
	ret
; =============== ActS_Held ===============	
; Main code for an actor when being held.
ActS_Held:
	;
	; Kill held actors when clibing or swimming.
	; Why this isn't allowed for all actors is a good question. Currently, collision detection is still enabled,
	; which has some weird side effects for most actors:
	; - Ladder top tiles are considered fully solid block by actors.
	;   Climbing down a ladder will make the actor overlap that solid block.
	;   When this happens, the actor is marked as dead, which looks buggy.
	; - If there isn't space above the player when swimming, the actor falls off.
	
	; Don't do this for default actors.
	; We want to be able to hold things like keys or coins when climbing or underwater.
	ld   a, [sActSetId]			; A = Held actor ID
	and  a, $7F					; Filter away no-respawn flag
	cp   a, $07					; Is this a default actor? (ID >= $07)
	jr   nc, .chkHeldStop		; If so, ignore the checks
	
	ld   a, [sPlAction]
	cp   a, PL_ACT_CLIMB						; Are we climbing?
	jp   z, ActS_StartJumpDeadSameColiFromHeld	; If so, kill it
	cp   a, PL_ACT_SWIM							; Are we swimming?
	jp   z, ActS_StartJumpDeadSameColiFromHeld	; If so, kill it
	
.chkHeldStop:
	;
	; Check for held stop
	;
	ld   a, [sActHeld]
	or   a							; Are we still holding the actor?
	jp   z, ActS_StartStun	; If not, set it in the stun state
	ld   a, [sActSyrupCastleBossDead]
	or   a							; Are we starting the ending cutscene?
	jp   nz, ActS_Held_ForceDelete	; If so, get rid of anything we're holding (note that the lamp handles the held code by itself)
	
	;
	; Check for autokill if we're also holding a key
	;
	ld   a, [sActSetId]			; A = Held actor ID
	cp   a, ACT_KEY				; Are we holding a key?
	jr   z, .setStat			; If so, skip
	ld   a, [sActHeldKey]
	or   a						; Are we marked as holding a key?
	jr   z, .setStat			; If not, skip
	
	; If we got here, the current actor we're holding *isn't* a key, but we're *also* holding a key.
	; This means we grabbed a key while holding the current actor.
	; This can happen since the subroutine to start holding a key is different from the one used for normal actors.
	; Normally, trying to grab an actor while already holding something will kill the actor instead.
	; Keys have max priority though so they do get grabbed anyway, and here we kill the held actor (while preserving the held state).
	jp   ActS_StartJumpDead
	
.setStat:
	ld   a, [sActNumProc]					; Sync held number
	ld   [sActHeldSlotNum], a
	ld   a, [sActSetId]						; Sync actor id
	and  a, $7F								; Filter away no-respawn flag
	ld   [sActHeldId], a
	
	ld   a, [sActSetOBJLstPtrTablePtr_Low]	; Sync OBJLst
	ld   [sActHeldOBJLstTablePtr_Low], a
	ld   a, [sActSetOBJLstPtrTablePtr_High]
	ld   [sActHeldOBJLstTablePtr_High], a
	ld   a, [sActSetColiType]				; Sync collision type
	ld   [sActHeldColiType], a
	
	;
	; When we get hit, we drop anything we're holding (except the key)...
	; [POI] ...but only if we collided with a level block.
	;		We don't do this when hit by other actors.
	;
	ld   a, [sActSetId]
	cp   a, ACT_KEY					; Holding a key?
	jr   z, .chkActColi				; If not, skip
	ld   a, [sPlHurtType]
	cp   a, PL_HT_BGHURT			; Are we hurt by a block?
	jp   z, ActS_StartStun			; If so, drop it
	
	
	;
	; Handle actor-to-actor collision
	;
.chkActColi:
	; [POI] There's no way to make a treasure collide with another actor
	ld   a, [sActHeldTreasure]	; Are we holding a treasure?
	or   a
	jr   nz, .checkStatus		; If so, don't perform collision checks
	;--
	ld   a, [sPlFreezeTimer]
	or   a						; Is the player frozen?
	jr   nz, .checkStatus		; If so, skip
	
	; Handle the held_actor-to-actor collision
	; If there's an overlap, set their routine IDs to $08, which kills them
	ld   a, $08					; Target routine ID
	ld   [sActHeldColiRoutineId], a
	ld   a, [sActNumProc]		; Actor slot we're holding
	call ActHeldOrThrownActColi_Do
	
	;--
	; Now verify if the actor has collided with another actor.
	; If that's the case, the actor's routine will be set to $08 (if it isn't a default actor)
	
	;##
	; Not really necessary -- this is already checked by ActHeldOrThrownActColi_Do before updating the routine ID
	; Maybe there's other code sets it to the dead routine without accounting for it?
	ld   a, [sActSetId]
	and  a, $7F									; Filter away no-respawn flag
	cp   a, $07									; Is this a default actor?
	jr   nc, .checkStatus						; If so, jump
	;##
	ld   a, [sActSetRoutineId]					; Read the routine ID
	and  a, $0F
	cp   a, $08									; Is the actor marked as dead?
	jp   z, ActS_StartJumpDeadSameColiFromHeld	; If so, stop holding it and kill it
	
	
.checkStatus:
	; Determine at what point of the held action we are.
	; This is to disallow throwing the actor the first frame we get here,
	; before block collision and others are checked.
	
	ld   a, [sActHeld]			
	cp   a, $02			; == $02?
	jr   z, .chkThrow	; If so, we've been already holding it
	
	; Otherwise, we've just started holding it
	ld   a, $02			; Mark main mode
	ld   [sActHeld], a
	jr   .chkBGColi
.instakill:
	xor  a							; Stop holding the actor
	ld   [sActHeld], a
	jp   SubCall_ActS_StartStarKill ; Replace actor with star effect
	
.chkThrow:
	ldh  a, [hJoyNewKeys]		
	bit  KEYB_B, a					; Did we press B?
	jp   nz, ActS_StartThrow		; If so, throw the actor
	
	;
	; Handle actor-to-block16 collision
	;
.chkBGColi:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActSetId]			; 
	and  a, $7F					; Filter away no-respawn flag
	cp   a, $07					; Is this a default actor?
	jr   nc, .chkGrab			; If so, skip this
	
	; Kill non-default actors if they touch a spike/lava block
	call ActColi_GetBlockId_Low	; Read block ID
	call ActBGColi_IsSpikeBlock	; Check it
	or   a						; Is this a spike block?
	jr   nz, .instakill			; If so, kill the actor
	
	; Drop non-default actors if they touch a solid block
	call ActColi_GetBlockId_Low
	call ActBGColi_IsSolid
	or   a
	jp   nz, ActS_StartStun
	
	;---------------------
	;
	; This last part is for updating the actor's position (sActSetY and sActSetX),
	; to make sure it stays in sync with the player.
	;
	; Of course, it isn't enough to just copy over the player's position, since
	; there are multiple things which change the hold position.
	; So we need first to determine the X and Y offsets, relative to the player position.
	
	;
	; Y OFFSET: Will be stored in B and subtracted to the player's Y position.
	; X OFFSET: Will be stored in DE and added to the player's X position.
	;
.chkGrab:
	; The held actor should be harmess
	xor  a						
	ld   [sActSetColiType], a
	
	;--
	; Grab delay, part 1
	;
	; This is when first grabbing an actor, where the player is frozen for a few frames on the ground.
	; Different X and Y offsets are used during this.
	;
	ld   b, $0E					; B = Y offset during the grab delay
	
	ld   a, [sActHeldDelay] 	
	or   a						; Is the grab delay already over?
	jr   nz, .chkClimb			; If so, jump
	
	; Otherwise, determine if it finished.
	; If the actor is heavy, it takes a longer time to finish.
	;
	; NOTE: When first grabbing an actor, its timer is reset to $00.
	;       Therefore, we can check if the timer reaches a certain value for this.
	; 		If we don't jump to .chkXGrab, sActHeldDelay will be set to $01.
	ld   a, [sActSetOpts]		
	bit  ACTFLAGB_HEAVY, a		; Is this an heavy actor?
	jr   z, .lightHold			; If not, jump
.heavyHold:
	ld   a, [sActSetTimer]
	cp   a, $24					; sActSetTimer < $24?
	jr   c, .chkXGrab			; If so, it's not elapsed yet
	jr   .chkClimb
.lightHold:
	ld   a, [sActSetTimer]
	cp   a, $0C					; sActSetTimer < $0C?
	jr   c, .chkXGrab			; If so, it's not elapsed yet
	;--
.chkClimb:
	ld   b, $1B					; B = Default Y offset
	ld   a, [sPlAction]
	cp   a, PL_ACT_CLIMB		; Is the player climbing?
	jr   nz, .chkDuck			; If not, skip
	ld   b, $17					; B = Y offset when climbing
.chkDuck:
	ld   a, [sPlDuck]
	or   a						; Is the player ducking?
	jr   z, .chkXNorm			; If not, skip
	ld   b, $13					; B = Y offset when ducking
.chkXNorm:
	; Mark grab delay/animation as finished
	ld   a, $01					
	ld   [sActHeldDelay], a
	; Pick different coord depending on player direction
	ld   de, +$0C				; DE = X offset when facing right
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a		; Is the player facing right?
	jr   nz, .chkYPow			; If so, jump
	ld   de, -$0C				; DE = X offset when facing left
	jr   .chkYPow
	;--
	; Grab delay, part 2
.chkXGrab:
	; Pick different coord depending on player direction, like above
	ld   de, +$10				; DE = X offset when facing right
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a		; Is the player facing right?
	jr   nz, .chkYPow			; If so, jump
	ld   de, -$10				; DE = X offset when facing left
	;--
	
.chkYPow:
	; Depending on player status, override the Y offset
	ld   a, [sPlPower]
	and  a, $0F					; Are we Small Wario?
	jr   nz, .chkXSwim			; If not, jump
.chkYPow_small:
	ld   b, $0F					; B = Y offset when small
	ld   a, [sPlAction]
	cp   a, PL_ACT_CLIMB		; Are we climbing?
	jr   nz, .chkXSwim			; If not, jump
	ld   b, $14                 ; B = Y offset when climbing while small
.chkXSwim:
	; When swimming or climbing, place the actor directly above the player
	; [POI] The way it's laid out suggests these values used to be different. Or maybe not.
	ld   a, [sPlAction]
	cp   a, PL_ACT_SWIM			; Are we swimming?
	jr   nz, .chkXClimb			; If not, jump
	ld   de, $0000				; DE = X offset when swimming
.chkXClimb:
	cp   a, PL_ACT_CLIMB		; Are we climbing?
	jr   nz, .setOff			; If not, jump
	ld   de, $0000				; DE = X offset when climbing
.setOff:
	;--
	; Set the new actor position
	
	;
	; Y POS
	;
	; sActSetY = sPlY - B
	ld   a, [sPlY_Low]			
	sub  a, b					
	ld   [sActSetY_Low], a
	ld   a, [sPlY_High]
	sbc  a, $00					; account for carry
	ld   [sActSetY_High], a
	
	;
	; X POS
	;
	; sActSetX = sPlX + DE
	ld   a, [sPlX_Low]		; HL = sPlX
	ld   l, a
	ld   a, [sPlX_High]
	ld   h, a
	add  hl, de				; Add the X offset
	ld   a, l				; Save it back to sActSetX
	ld   [sActSetX_Low], a
	ld   a, h
	ld   [sActSetX_High], a
	;--
	; Increase the anim frame every $04 frames
	ld   a, [sTimer]
	and  a, $03					; sTimer % 04 == 0?
	jr   nz, .end				; If not, skip
	ld   a, [sActSetOBJLstId]	; AnimFrame++
	inc  a
	ld   [sActSetOBJLstId], a
.end:
	ret
; =============== ActS_Held_ForceDelete ===============	
; Forcibly removes the currently held actor from the level.
ActS_Held_ForceDelete:
	xor  a
	ld   [sActSet], a			; Permadespawn
	ld   [sActHeld], a			
	ld   [sActSetColiType], a	
	ret
; =============== ActS_StartStun ===============
; This subroutine sets up the code to make the current actor stunned.
ActS_StartStun:
	; Make the actor face the same direction the player's facing
	mPlFlagsToXDir ; A = Direction value
	ld   [sActSetDir], a
	
	ld   a, SFX1_20
	ld   [sSFX1Set], a
	
	; Different code is executed for default actors
	ld   a, [sActSetId]	
	and  a, $7F			; Filter away no-respawn flag
	cp   a, $07			; Actor ID >= $07?
	jr   nc, .defAct	; If so, it's a default actor
.normAct:
	ld   bc, SubCall_ActS_Stun
	call ActS_SetCodePtr
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ld   [sActHeld], a
	ld   [sActSetColiType], a
	ld   a, $3C					; Drop (ignore player collision) for $3C frames
	ld   [sActStunDrop], a
	call ActS_SetStunOBJLst
	ret
.defAct:
	ld   bc, SubCall_ActS_StunDefault
	call ActS_SetCodePtr
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ld   [sActHeld], a
	ld   [sActHeldKey], a
	ld   a, $3C					; Drop (ignore player collision) for $3C frames
	ld   [sActStunDrop], a
	call ActS_SetStunOBJLst
	ret
	
; =============== ActS_StartThrow_ErrorSfx ===============
; Alerts the player that he isn't allowed to throw the actor.
ActS_StartThrow_ErrorSfx:
	ld   a, SFX2_01
	ld   [sSFX2Set], a
; =============== ActS_StartThrow_Cancel ===============
; Same as above, but without playing SFX.
ActS_StartThrow_Cancel:
	ld   a, $01
	ld   [sActHeld], a
	ret
	
; =============== ActS_StartThrow ===============
; This subroutine makes the player throw the currently held actor.
ActS_StartThrow:
	;
	; Start by checking if we're allowed to throw the actor.
	;

	; Disallow throwing the treasure (controls are supposed to be disabled here), 
	; but don't play the error sound.
	ld   a, [sActHeldTreasure]
	or   a
	jr   nz, ActS_StartThrow_Cancel
	;--
	; Disallow if we're too close to the top of the screen,
	; in a way that'd make the actor go off-screen (and immediately despawn).
	ld   a, [sPlYRel]		
	add  $40				; (sPlYRel + $40) < $60
	cp   a, $60				; sPlYRel < $20?
	jr   c, ActS_StartThrow_ErrorSfx	; If so, jump
	
	;--
	; Disallow if the actor is overlapping with a solid block
	; (just in case I assume -- this would cause an auto drop)
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolid
	or   a
	jr   nz, ActS_StartThrow_ErrorSfx
	
	;--
	; Disallow if there's a solid block right in front of the actor.
	; Of course we need to determine the player orientation for this.
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a		; Is the player facing right?
	jr   z, .chkSolidL			; If not, jump
.chkSolidR:
	; Disallow if there's a solid block on the right of the actor
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a
	jr   nz, ActS_StartThrow_ErrorSfx
	; Disallow if there's a solid block on the bottom right of the actor
	call ActColi_GetBlockId_BottomR
	mSubCall ActBGColi_IsSolid
	or   a
	jr   nz, ActS_StartThrow_ErrorSfx
	
	jr   .chkCoinAnim
.chkSolidL:
	; Disallow if there's a solid block on the left of the actor
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolid
	or   a
	jr   nz, ActS_StartThrow_ErrorSfx
	; Disallow if there's a solid block on the bottom left of the actor
	call ActColi_GetBlockId_BottomL
	mSubCall ActBGColi_IsSolid
	or   a
	jr   nz, ActS_StartThrow_ErrorSfx
	;--
	
	;
	; Validation successful!
	;
	
.chkCoinAnim:
	; If we're throwing a 10coin, make it spin.
	
	; This is because when held, a 10coin uses the OBJLst OBJLstPtrTable_Act_10CoinHeld,
	; which doesn't have any animation.
	; Once thrown, it switches here to the normal OBJLst OBJLstPtrTable_Act_10Coin,
	; which has an animation of a coin spinning.
	ld   a, [sActSetId]
	and  a, $7F				; Filter away no-respawn flag
	cp   a, ACT_10COIN		; Are we throwing a 10coin?
	jr   nz, .setVars		; If not, skip
	; Otherwise, set the alternate OBJLst for animating the coin spin
	push bc
	ld   bc, OBJLstPtrTable_Act_10Coin
	call ActS_SetOBJLstPtr
	pop  bc
	
.setVars:
	xor  a						; Reset anim frame
	ld   [sActSetOBJLstId], a
	ld   bc, SubCall_ActS_Throw	; Set loop code
	call ActS_SetCodePtr
	
	xor  a						; Reset vars and held status
	ld   [sActSetTimer], a
	ld   [sActHeld], a
	ld   [sActHeldKey], a
	ld   [sActSetColiType], a
	ld   a, $02					; Set initial horz speed
	ld   [sActThrowHSpeed], a
	xor  a
	ld   [sActThrowDead], a
	ld   [sActThrowNoColiTimer], a
	
	ld   a, SFX1_0C				; Play throw SFX
	ld   [sSFX1Set], a
	
	; Set horizontal direction to be the same as the player's
	mPlFlagsToXDir
	ld   [sActSetDir], a
	
	; By default, throw in a downwards arc (initial Y speed $00).
	; However, if we're jumping and we haven't reached the peak of the jump yet,
	; make that arc initially upwards (until the Y speed becomes positive again, that is).
	
	; [BUG] This doesn't account for the high jump having a different peak value.
	mActSetYSpeed $00
	ld   a, [sPlAction]
	cp   a, PL_ACT_JUMP				; Are we jumping?
	ret  nz							; If not, return
	
	IF FIX_BUGS == 1
		; Determine peak value for the jump
		ld   b, (Pl_JumpYPath.down-Pl_JumpYPath) ; B = Normal jump peak
		ld   a, [sHighJump]
		and  a							; Doing an high jump?
		jr   z, .setJump				; If not, skip ahead
		ld   b, (Pl_HighJumpYPath.down-Pl_HighJumpYPath) ; B = High jump peak
	.setJump:
		ld   a, [sPlJumpYPathIndex]
		cp   a, b						; Are we past the peak of the jump (ie: moving downwards, hopefully)	
		ret  nc							; If so, return
		mActSetYSpeed -$04				; Otherwise, change the throw arc
	ELSE
		ld   a, [sPlJumpYPathIndex]
		cp   a, (Pl_JumpYPath.down-Pl_JumpYPath)	; Are we past the peak of the jump (ie: moving downwards, hopefully)	
		ret  nc										; If so, return
		mActSetYSpeed -$04							; Otherwise, change the throw arc
	ENDC
	

	ret
	
; =============== ActS_Throw_OnCollide ===============
; Handles what happens when the thrown actor collides with another actor.
ActS_Throw_OnCollide:
	; Setup a new bounce
	mActSetYSpeed -$03			; Allow jump to continue
	; Mark actor as to be killed
	ld   a, [sActThrowDead]		; KillCount++
	inc  a
	ld   [sActThrowDead], a
	; For $14 frames ignore collision with other actors
	; to avoid increasing the count over and over
	ld   a, $14
	ld   [sActThrowNoColiTimer], a
	ret
	
; =============== ActS_ThrowDelay3C ===============
; Waits for $3C frames, then switches to the throw routine.
; Used specifically to delay throwing the spawned coin by Act_MoleCutscene.
ActS_ThrowDelay3C:
	; Timer++
	ld   a, [sActSetTimer]
	inc  a
	ld   [sActSetTimer], a
	; Has it reached $3C yet
	cp   a, $3C						; Has it reached $3C yet?
	ret  c							; If not, return
	ld   bc, SubCall_ActS_Throw		; Otherwise, switch to the throw routine
	call ActS_SetCodePtr
	xor  a
	ld   [sActSetTimer], a
	
; =============== ActS_Throw ===============	
; Loop code for a normal actor when thrown.
; This basically handles a bounce effect.
ActS_Throw:
	; The timer is used for ignoring all actor & spike block collision
	ld   a, [sActThrowNoColiTimer]
	or   a
	jr   nz, .skipDeadColi
	
	;--
	; If this is a non-default actor, 
	; instakill it when it comes in contact with a spike block.
	ld   a, [sActSetId]			; Get actor ID
	and  a, $7F					; Filter away no-respawn flag
	cp   a, ACT_DEFAULT_BASE	; If this a default one? (>= $07)
	jr   nc, .chkActColi		; If so, skip
	
	call ActColi_GetBlockId_Low			; Get block ID the actor is currently overlapping with
	mSubCall ActBGColi_IsSpikeBlock		; Check if it's a spike block
	or   a								; Is the actor over a spike block?
	jp   nz, SubCall_ActS_StartStarKill	; If so, kill it
	;--
	
.chkActColi:
	; Perform actor-to-actor collision
	ld   a, $08							; Target subroutine if overlapping with another actor
	ld   [sActHeldColiRoutineId], a
	ld   a, [sActNumProc]
	call ActHeldOrThrownActColi_Do
	
	; If we hit something from the actor-to-actor check, we have to mark the current actor as killed,
	; but not killing it immediately. It should take effect only when it stops bouncing or hits a wall.
	; This should *not* count for throwable default actors (ie: keys and coins) for obvious reasons.
	ld   a, [sActSetId]
	and  a, $7F					; Filter away no-respawn flag
	cp   a, ACT_DEFAULT_BASE	; If this a default one? (>= $07)
	jr   nc, ActS_Throw_Main	; If so, skip directly to the main handler
	
	ld   a, [sActSetRoutineId]	; Otherwise pick the routine
	and  a, $0F
	rst  $28
	dw ActS_Throw_Main
	dw ActS_StartHeld
	dw ActS_Throw_Main
	dw ActS_StartStarKill
	dw ActS_StartHeld
	dw ActS_Throw_Main
	dw ActS_Throw_Main;X
	dw ActS_Throw_Main;X
	dw ActS_Throw_OnCollide ; 08
.skipDeadColi:
	dec  a						; Timer--
	ld   [sActThrowNoColiTimer], a
	jr   ActS_Throw_Main		; Skip to main
; =============== ActS_Throw_SetColi ===============	
; Sets the updated collision type used when the actor is stunned.
; When starting the throw, the actor has no collision, so it needs to be reset.
ActS_Throw_SetColi:
	; Default actors depend on their collision type to do anything special to the player.
	; Therefore, if we threw one of those, the proper collision type should be set
	ld   a, [sActSetId]
	and  a, $7F					; Filter away no-respawn flag
	cp   a, ACT_DEFAULT_BASE	; If this a default actor? (>= $07)
	jr   nc, .default			; If so, use the custom one
	; For everything else, make all sides safe to touch
	mActColiMask ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
.default:
	call SubCall_ActColi_SetForDefault
	ret
	
; =============== ActS_Throw_Main ===============	
ActS_Throw_Main:
	; After $0A frames, set the actor's actual collision type when stunned
	ld   a, [sActSetTimer]
	cp   a, $0A
	call z, ActS_Throw_SetColi
	
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; When an actor falls in water, make it fall slowly
	; Curiously, the key specifically bypasses this behaviour.
	ld   a, [sActSetId]
	cp   a, ACT_KEY						; Is this a key?
	jr   z, .incAnim					; If so, skip
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a								; Is the actor over a water block?
	jr   z, .water_do						; If so, jump
	
.incAnim:
	; Every 4 frames increase the anim frame
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .horzMove
	ld   a, [sActSetOBJLstId]	; AnimFrame++
	inc  a
	ld   [sActSetOBJLstId], a
	
.horzMove:
	; Try to move the actor on the opposite direction it's facing.
	; Note that this horizontal movement will be always applied until we get out of the ActS_Throw routine.
	ld   a, [sActSetDir]
	bit  DIRB_R, a					; Facing right?
	call nz, ActS_Throw_MoveRight	; If so, move right
	ld   a, [sActSetDir]
	bit  DIRB_L, a					; Facing left?
	call nz, ActS_Throw_MoveLeft	; If so, move left
	
.chkColiD:
	; When the player touches the ground, perform the kill check
	call ActColi_GetBlockId_Ground
	call ActBGColi_IsSolidOnTop
	or   a
	jr   nz, .chkLand
	
.chkVertType:
	; Reset the throw end delay
	ld   a, $02
	ld   [sActThrowHSpeed], a
	
	; We already performed the ground check previously
	; (even when bouncing up, for some reason), so we only need to check for top
	; collision when moving up.
	ld   a, [sActSetYSpeed_High]
	bit  7, a							; Is the actor bouncing up? (MSB set)
	jr   z, .moveVert					; If not, jump
.chkColiU:
	; If there's a solid block above the actor, reset the vertical speed
	call ActColi_GetBlockId_Top
	call ActBGColi_IsSolid
	or   a							; Solid block above?
	jr   z, .moveVert					; If not, skip
	xor  a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
.moveVert:
	; Move the actor vertically by sActSetYSpeed
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown					; Move down by that
	
	; Every 4 frames, increase the downwards speed by 1
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, [sActSetYSpeed_Low]		; sActSetYSpeed++
	add  $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00
	ld   [sActSetYSpeed_High], a
	ret
	
.water_do:
	; For actors when thrown into water.
	; This will kill them once they reach the ground (unless they are a default actor).

	; Every other frame play the water ambient SFX
	ld   a, [sActSetYSpeed_Low]
	or   a
	jr   z, .water_moveDown
	
	ld   a, SFX4_10
	ld   [sSFX4Set], a
	
.water_moveDown:
	; Animate slowly, every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	; Move down at a fixed speed of 1px/frame
	ld   bc, $0001
	call ActS_MoveDown
	
	; And override the vertical speed values
	xor  a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	;--
	; Handle ground touch
	call ActColi_GetBlockId_Ground
	call ActBGColi_IsSolidOnTop
	or   a							; Is the actor over a solid block?
	ret  z							; If not, return
	ld   a, [sActSetId]
	and  a, $7F						; Filter away no-respawn flag
	cp   a, $07						; Is this a default actor?
	jr   nc, ActS_Throw_LandDefault	; If so, execute the special case for keys and coins
	jp   ActS_StartJumpDead			; Otherwise, kill it immediately
	;--
.chkLand:
	; When we get here, the actor has landed or is standing on the ground.
	
	; When an actor lands on the ground, it may either:
	; - Perform another bounce, if it landed at a faster speed than 4px/frame
	; - Stop moving vertically
	;
	
	; If the actor is moving up, return to the main code
	ld   a, [sActSetYSpeed_High]
	bit  7, a						; sActSetYSpeed < 0?
	jr   nz, .chkVertType			; If so, jump
	
	; Was the actor moving down slower than 5px/frame?
	ld   a, [sActSetYSpeed_Low]
	cp   a, $05						; Is sActSetYSpeed < 5?
	jr   c, .chkEnd					; If so, jump
	
	mActSetYSpeed -$03				; Otherwise, set a new bounce of negative
	jp   .chkVertType
	
.chkEnd:
	; This is a bit unintuitive, so it needs some explaination.
	;
	; sActThrowHSpeed has the purpose of delaying the end of a throw.
	; Until it elapses, the actor continues moving horizontally without switching to the main stun routine.
	;
	; When an actor is marked as "heavy", the timer decrements at a faster rate (every other frame instead of 1/8),
	; which means it slides less horizontally.
	; The usage of the actor's internal timers means this is not random, since they get decremented only on execution frames.
	;
	; Also, whenever an actor is in the air, sActThrowHSpeed is reset to $02, making sure that, if the horizontal movement
	; pushes an actor off a platform, the other bounces won't prematurely end.
	
	ld   a, [sActSetOpts]
	bit  ACTFLAGB_HEAVY, a			; Is the actor heavy?
	jr   nz, .chkEndHeavy			; If so, jump
.chkEndNorm:
	; Every 8 frames check if we can switch to the main stun routine
	ld   a, [sActSetTimer]
	and  a, $07
	jr   nz, .chkKillOnLand
	
	ld   a, [sActThrowHSpeed]
	or   a							; Is the timer elapsed yet?
	jp   z, ActS_StartStunNormStub	; If so, switch to the stun code
	dec  a							; Otherwise, decrease it
	ld   [sActThrowHSpeed], a
	jr   .chkKillOnLand				; And continue moving horizontally
.chkEndHeavy:
	; Every other framee check if we can switch to the main stun routine
	ld   a, [sActSetTimer]
	and  a, $01
	jr   nz, .chkKillOnLand
	
	ld   a, [sActThrowHSpeed]			
	or   a							; Is the timer elapsed yet?
	jp   z, ActS_StartStunNormStub	; If so, switch to the stun code
	dec  a							; Otherwise, decrease it
	ld   [sActThrowHSpeed], a
	;--
	
.chkKillOnLand:
	; sActThrowDead is used as a death indicator when colliding with other actors.
	; It only takes effect when landing on solid ground, which is here.
	ld   a, [sActThrowDead]
	or   a							; Is the flag set?
	jp   nz, ActS_StartJumpDead		; If so, kill the actor with a jump effect
	
	; If this is a default actor, immediately make it land without making it slide
	ld   a, [sActSetId]
	and  a, $7F
	cp   a, ACT_DEFAULT_BASE		; Is this a default actor?
	jr   nc, ActS_Throw_LandDefault	; If so, jump
	
	; Otherwise, force the Y speed to $00.
	xor  a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ret

; =============== ActS_Throw_LandDefault ===============
; Special case when a default actor lands and needs to return to the default state.
ActS_Throw_LandDefault:
	; Set default collision type
	call SubCall_ActColi_SetForDefault
	
	ld   a, [sActSetId]
	cp   a, ACT_KEY			; Is this a key?
	jr   z, .key			; If so, jump
	; Otherwise, it must be a 10coin
.coin:
	; A coin bounces multiple times on the ground at decreasing speed.
	ld   a, LOW(-$0A)
	ld   [sActSetYSpeed_Low], a
	ld   a, HIGH(-$0A)
	ld   [sActSetYSpeed_High], a
	; Reset vars
	xor  a
	ld   [sActSetTimer2], a		; (not used?)
	ld   [sActSetOBJLstId], a
	
	;--
	; sActSetOpts = (sActSetOpts & $F0) | $01
	ld   a, [sActSetOpts]
	and  a, $F0
	ld   b, a
	ld   a, $01
	and  a, $0F
	or   a, b
	ld   [sActSetOpts], a
	;--
	
	ld   bc, SubCall_Act_Coin
	call ActS_SetCodePtr
	ret
	
.key:
	; A key just lands, and doesn't do smaller bounces.
	xor  a
	ld   [sActSetTimer2], a		; (not used?)
	ld   [sActSetOBJLstId], a
	
	ld   a, $14					; Drop for $14 frames
	ld   [sActStunDrop], a
	
	;--
	; sActSetOpts = (sActSetOpts & $F0) | $01
	ld   a, [sActSetOpts]
	and  a, $F0
	ld   b, a
	ld   a, $01
	and  a, $0F
	or   a, b
	ld   [sActSetOpts], a
	;--
	
	ld   bc, SubCall_ActS_StunDefault
	call ActS_SetCodePtr
	ret
; =============== ActS_Throw_Move* ===============
; Helper subroutines for moving horizontally the current actor when thrown.
; =============== ActS_Throw_MoveRight ===============
ActS_Throw_MoveRight:
	call ActColi_GetBlockId_LowR
	call ActBGColi_IsSolid
	or   a								; Is there a solid block on the right?
	jr   nz, ActS_Throw_SwitchHorzMove	; If so, try to start moving left
	
	ld   a, [sActThrowHSpeed]
	ld   c, a							; BC = sActThrowHSpeed
	ld   b, $00
	call ActS_MoveRight					; Move right by that
	ret
; =============== ActS_Throw_MoveLeft ===============
ActS_Throw_MoveLeft:
	call ActColi_GetBlockId_LowL
	call ActBGColi_IsSolid
	or   a								; Is there a solid block on the left?
	jr   nz, ActS_Throw_SwitchHorzMove	; If so, try to start moving right
	
	ld   a, [sActThrowHSpeed]
	ld   c, a							; BC = sActThrowHSpeed
	ld   b, $00
	call ActS_MoveLeft					; Move left by that
	ret
; =============== ActS_Throw_SwitchHorzMove ===============
; Called when a thrown actor hits a solid block.
ActS_Throw_SwitchHorzMove:
	; If the actor is heavy, kill it instead of bouncing more.
	ld   a, [sActSetOpts]
	bit  ACTFLAGB_HEAVY, a
	jp   nz, ActS_StartJumpDeadSameColi
	
	; Otherwise, do the normal direction switch effect, as seen elsewhere
	ld   a, [sActSetDir]
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ret
; =============== ActS_StartStunNormStub ===============	
ActS_StartStunNormStub:
	jp   ActS_StartStunNorm
	
; =============== mAbsBoxBoundSave ===============
; Gets the position of a collision border, relative to the screen, and saves it somewhere.
; See also: mAbsBoxBound (BANK $0D).
; IN
; - 1: Ptr to box collision border height/width
; - 2: Ptr to where the result (collision box pos) is saved
; - C: Actor relative coord (X or Y), aka the origin
; - E: Some constant which is always $B0
mSetAbsBoxBound: MACRO
	; Res = ColiSize + Origin - $B0
	ld   a, [\1]	; Get the box width or height (relative to the origin)
	add  c		; Add the origin
	sub  a, e		; (ignore this)
	ld   [\2], a	; Save the result where specified
ENDM
	
; =============== ActHeldOrThrownActColi_Do ===============
; This subroutine checks for actor collision against other actors,
; specifically when the actor we're checking is held or thrown.
; Actor-to-actor collision isn't executed otherwise.
; For more info on the bounding box checks, see ExActActColi_DragonHatFlame.
; IN
; - A: Current actor slot number
; - sActHeldColiRoutineId: Routine ID set to overlapping actors
ActHeldOrThrownActColi_Do:

	ld   [sActTmpHeldNum], a	; Save actor slot		
	
	;--
	;
	; We need to calculate the absolute coordinates of the collision box to perform the box checks later on.
	; To do this, we can add the amount the collision box extends to the actor's origin value.
	; The helper macro mSetAbsBoxBound can be used for this.
	;
	
	; Like for other x-to-actor collision checks, this constant value will get subtracted to everything.
	; For some reason.
	ld   e, $B0					; E = $B0
	
	;
	; Horizontal collision borders
	;
	ld   a, [sActSetRelY]		; C = Y Origin
	ld   c, a
	mSetAbsBoxBound sActSetColiBoxU, sActTmpAbsColiBoxU
	mSetAbsBoxBound sActSetColiBoxD, sActTmpAbsColiBoxD
	
	;
	; Vertical collision borders
	;
	ld   a, [sActSetRelX]		; C = sActSetRelX
	ld   c, a
	mSetAbsBoxBound sActSetColiBoxL, sActTmpAbsColiBoxL
	mSetAbsBoxBound sActSetColiBoxR, sActTmpAbsColiBoxR
	;--
	
	; Now we loop through all normal actor slots, and check for collision against all of them.
	ld   hl, sAct					; HL = Start of actor slot area
	xor  a
	ld   [sActTmpCurSlotNum], a		; SlotNum = 0
	
.checkSlot:
	;##
	; Save HL, which currently points at the start of an actor slot.
	; This is because we want to easily add +$20 to switch to the next slot,
	; and the collision checks seek to various parts of the slot.
	push hl
	
	; Don't check for collision against self
	ld   a, [sActTmpHeldNum]	; D = Slot number we're holding
	ld   d, a
	ld   a, [sActTmpCurSlotNum]	; A = Current slot number
	cp   a, d					; Do they match
	jr   z, .nextSlot			; If so, jump
	
	; Ignore the actor if it isn't visible and active (as it won't have an origin set)
	ld   a, [hl]		; Read active status
	cp   a, $02			; Is the actor visible and active?
	jr   nz, .nextSlot	; If not, skip
	
	; Verify that the actor is tangible and isn't a big block
	ld   de, (sActSetColiType - sActSet) ; Seek to collision type
	add  hl, de
	ldi  a, [hl]				; Read collision type
	or   a						; Is it intangible?
	jr   z, .nextSlot			; If so, jump
	; [POI] Some actors with this collision type have unique handlers for being thrown something at.
	;		This exclusion makes them go unused.
	cp   a, ACTCOLI_BIGBLOCK	; Is this a big block?
	jr   z, .nextSlot			; If so, jump
	
	;
	; We've found a suitable actor to do the box check.
	;

	; Copy over the collision boxes
	ldi  a, [hl]	; B = Coli box U
	ld   b, a
	ldi  a, [hl]	; C = Coli box D
	ld   c, a
	ldi  a, [hl]	; D = Coli box L
	ld   d, a
	ldi  a, [hl]	; E = Coli box R
	ld   e, a
	
	;--
	; Perform the collision check on left border.
	; All of these use a similar template.
	
	; Calculate the absolute position (well, relative to the screen) of the other actor's left collision border.
	; This is done by adding the... Y origin, to the left collision box size.
	; (it should have been the X origin)
	ld   a, [hl]					; C = OtherColiBoxR + RelY - $B0
	add  c		
	sub  a, $B0		
	ld   c, a
	
	; Check if the aforemented topmost collision point is placed after 
	; the bottom collision point of the actor we're holding.
	; If that's true, there's no way the two collision boxes can overlap, so we skip to the next actor.
	ld   a, [sActTmpAbsColiBoxU]	; A = sActTmpAbsColiBoxU
	cp   a, c						; Is ColiBoxU > OtherColiBoxD
	jr   nc, .nextSlot				; If so, there's no collision
	;--
	; Now do similar things for the bottom border.
	ldi  a, [hl]					; B = OtherColiBoxU + RelY - $B0
	add  b
	sub  a, $B0
	ld   b, a
	
	ld   a, [sActTmpAbsColiBoxD]	; A = sActTmpAbsColiBoxD
	cp   a, b						; Is ColiBoxD < OtherColiBoxU
	jr   c, .nextSlot				; If so, there's no collision
	;--
	; Leftmost border
	ld   a, [hl]					; E = OtherColiBoxR + RelX - $B0
	add  e
	sub  a, $B0
	ld   e, a
	
	ld   a, [sActTmpAbsColiBoxL]	; A = sActTmpAbsColiBoxL
	cp   e							; Is ColiBoxL > OtherColiBoxR
	jr   nc, .nextSlot				; If so, there's no collision
	;--
	; Rightmost border
	ldi  a, [hl]					; E = OtherColiBoxL + RelX - $B0
	add  d
	sub  a, $B0
	ld   d, a
	
	ld   a, [sActTmpAbsColiBoxR]	; A = sActTmpAbsColiBoxR
	cp   a, d						; Is ColiBoxR < OtherColiBoxL
	jr   c, .nextSlot				; If so, there's no collision
	
	; If we got here, there's an overlap between the two collision boxes.
	; Perform some final checks, then mark the overlap.
	;--
	
	; Check the actor ID
	
	; Now HL points to byte $0C of the slot data.
	; We want to point to the actor ID (byte $10, so $10 - $0C = $04)
	ld   de, (sActSetId - sActSetOBJLstPtrTablePtr_Low)
	add  hl, de
	
	ldi  a, [hl]					; Read the actor ID
	cp   a, $07						; Is this a default actor (ie: powerups, key, ...)?
	jr   nc, .nextSlot				; If so, ignore collision
	
	;--
	; Check the routine ID
	; We only want to collide with the actor in its default state (when its specific code is running basically)
	; and not during special actions like being thrown.
	
	ld   a, [hl]					; Read routine ID
	and  a, $0F						; Is the actor in the default routine ID?
	jr   nz, .nextSlot				; If not, skip	
	;--
	
	; Set the new Routine ID. Since only the lower nybble is used:
	; - Lower nybble: New routine ID (previously set in sActHeldColiRoutineId)
	; - Upper nybble: Slot number of the actor collided with
	ld   a, [sActHeldColiRoutineId]	; B = sActHeldColiRoutineId
	ld   b, a
	ld   a, [sActNumProc]			; A = sActNumProc << 4
	and  a, $07
	swap a
	or   a, b						; Merge the values
	ld   [hl], a					; Set the routine ID
	;--
	; Also set this routine ID to the actor we're holding,
	; but only if it isn't a default actor.
	ld   b, a						; Save routine ID
	ld   a, [sActSetId]
	res  ACTB_NORESPAWN, a			; Filter away respawn flag for ID check
	cp   a, $07						; Is this a default actor? (ID >= $07?)
	jr   nc, .nextSlot				; If so, skip this
	ld   a, b						; Restore routine ID
	ld   [sActSetRoutineId], a		; Set it to the actor we're holding
.nextSlot:
	pop  hl							; Restore ptr to start of actor slot
	;##
	ld   de, (sActSet_End-sActSet)	; Seek to the next slot
	add  hl, de
	ld   a, [sActTmpCurSlotNum]		; Increase slot number
	inc  a
	ld   [sActTmpCurSlotNum], a
	cp   a, $05						; Have we reached the limit?
	jp   c, .checkSlot				; If not, loop
	ret

; =============== ActS_StartDashKill ===============
; This subroutine sets up code for the arc.
ActS_StartDashKill:
	; Reset anim frame
	xor  a
	ld   [sActSetOBJLstId], a
	; Set loop code
	ld   bc, SubCall_ActS_DashKill
	call ActS_SetCodePtr
	; Reset timer
	ld   a, $00
	ld   [sActSetTimer], a
	ld   [sActLocalRoutineId], a		; (not used?)
	; Set initial speed for jump arc
	ld   bc, -$05
	ld   a, c
	ld   [sActSetYSpeed_Low], a
	ld   a, b
	ld   [sActSetYSpeed_High], a
	; Make intangible
	xor  a
	ld   [sActSetColiType], a
	; Set default OBJLst
	call ActS_SetStunOBJLst
	; Award 1 heart
	call Game_Add1Heart
	ret
; =============== ActS_OnPlColiH ===============
; Common handler when an actor is bumped horizontally from the player.
; This determines what type of bump should be inflicted to the actor.
; The possible choices are:
; - Death (underwater)
; - Soft (actor stays on the ground but moves away)
; - Normal (actor is stunned)
; - Far (actor is stunned and lands away twice as far)
ActS_OnPlColiH:
	; The actor should die when touched by the player underwater
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a
	jp   z, ActS_StartJumpDead
	
.chkJump:
	;
	; Don't affect the actor when jumping upwards
	;
	ld   a, [sPlAction]
	cp   a, PL_ACT_JUMP				; Is the player jumping?
	jr   nz, .chkPower				; If not, jump
	ld   a, [sPlJumpYPathIndex]
	; [POI] This isn't the normal value used for the peak of the jump in Pl_JumpYPath
	cp   a, $1D						; Is it after the peak of the jump?
	ret  nc							; If so, return
	jr   ActS_StartStunBump
	
.chkPower:
	;
	; Perform a soft bump if small or when ducking
	;
	ld   a, [sPlPower]
	and  a, $0F						; Is the player big?
	jp   z, .small					; If not, jump
	ld   a, [sPlAction]
	cp   a, PL_ACT_DUCK				; Is the player ducking?		
	jp   z, ActS_StartBumpSoft		; If so, jump
	
	;
	; Bull Wario bumps actors further away.
	; Or rather, it does so at twice the speed, but it still takes the 
	; same amount of time as a normal bump.
	;
	ld   a, [sPlPower]
	and  a, $0F
	cp   a, PL_POW_BULL				; Is the player Bull Wario?
	jp   z, .bull					; If so, bump at 2px/frame
	jr   ActS_StartStunBump			; Otherwise, bump at 1px/frame
.small:
	jr   ActS_StartBumpSoft
.bull:
	jp   ActS_StartStunBumpFar
	
; =============== ActS_StartBumpSoft ===============
; Sets up the loop code for a bump to the currrent actor.
ActS_StartBumpSoft:
	; Start speed at 2px/frame, which then decreases
	ld   a, $02						
	ld   [sActBumpSoftAltHSpeed], a
	ld   bc, SubCall_ActS_BumpSoft
	call ActS_SetCodePtr
	ld   a, $00
	ld   [sActSetTimer], a
	ld   [sActSetTimer2], a
	ld   [sActSetYSpeed_Low], a
	ret
; =============== ActS_StartStunBump ===============
; Sets up the loop code for a bump which stuns the currrent actor.
ActS_StartStunBump:
	ld   bc, SubCall_ActS_StunBumpNorm	; Set code ptr
	call ActS_SetCodePtr
	ld   a, $00							; Reset timer
	ld   [sActSetTimer], a
	mActSetYSpeed -$01					; Set jump height
	call ActS_SetStunOBJLst
	ret
; =============== ActS_StartStunBumpFar ===============
; Sets up the loop code for a far bump which stuns the currrent actor.
ActS_StartStunBumpFar:
	ld   bc, SubCall_ActS_StunBumpFar	; Set code ptr
	call ActS_SetCodePtr
	ld   a, $00							; Reset timer
	ld   [sActSetTimer], a
	mActSetYSpeed -$02					; Slightly bigger jump
	call ActS_SetStunOBJLst
	ret
	
; =============== ActS_Unused_StartJumpDownDeadStub ===============
; [TCRF] Stubs used by the unreferenced subroutine 
ActS_Unused_StartJumpDownDeadStub:
	jp   ActS_Unused_StartJumpDownDead
ActS_Unused_DoStartJumpDeadStub2: 
	jp   ActS_DoStartJumpDead
	
; =============== ActS_StunBumpNorm ===============
; Loop code for the stun routine when an actor is bumped (horizontally or from below).
; Horizontal movement speed: 1px/frame.
ActS_StunBumpNorm:
	; If the actor is in a water block, jump
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a
	jr   z, ActS_StunBump_MoveVert
	; Execute the main routine
	ld   bc, $0001
	jr   ActS_StunBump
	
; =============== ActS_StunBumpFar ===============
; Loop code for the stun routine when an actor is bumped as Bull Wario.
; Horizontal movement speed: 2px/frame.	
ActS_StunBumpFar:
	; If the actor is in a water block, jump
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a
	jr   z, ActS_StunBump_MoveVert
	; Execute the main routine
	ld   bc, $0002
	jr   ActS_StunBump
	
; =============== ActS_StunBump ===============
; Loop code for handling horizontal movement when an actor is stunned after being interacted horizontally or from below.
; This is only done when outside of water.
; IN
; - BC: Horizontal movement speed
ActS_StunBump:
	; NOTE: When an actor is stunned this way, the interaction direction is always set.
	; As a result, one of these two routines always executes.

	; If the actor is being interacted from the left, move it right
	ld   a, [sActSetRoutineId]
	bit  ACTINTB_L, a
	push bc
	call nz, ActS_StunBump_MoveRight
	pop  bc
	; If the actor is being interacted from the right, move it left
	ld   a, [sActSetRoutineId]
	bit  ACTINTB_R, a
	call nz, ActS_StunBump_MoveLeft
	
; =============== ActS_StunBump_MoveVert ===============
; Loop code for handling the vertical movement portion of the stun effect.
ActS_StunBump_MoveVert:
	;--
	; Every 4 frames increase the anim frame
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkColi
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	;--
.chkColi:
	ld   a, [sActSetTimer]			; sActSetTimer++
	inc  a
	ld   [sActSetTimer], a
	
	; If the actor is over a spike block, instakill it
	call ActColi_GetBlockId_Low
	call ActBGColi_IsSpikeBlock
	or   a
	jp   nz, ActS_StartStarKill
	
	;
	; Handle the jump arc.
	; The initial vertical speed is set to negative, which makes the actor move up for a bit.	
	; Every 4 frames this value increases, which eventually makes it become positive.
	; At that point the actor will start moving down.
	;
	
	; Determine the vertical direction we should check for solid collision.
	; This is different if we're moving upwards or downwards.
	ld   a, [sActSetYSpeed_High]
	bit  7, a							; Are we moving up?
	jr   z, .chkMoveDown				; If not, jump
.chkMoveUp:
	; If there's a solid block above, pause vertical movement.
	; Notice how this doesn't immediately start downwards movement -- the downwards speed
	; is still increased as normal, but it just skips the part where it moves the player.
	call ActColi_GetBlockId_Top
	call ActBGColi_IsSolid
	or   a
	jp   nz, ActS_StunBump_IncDownSpeed
	; Otherwise continue moving vertically
	jp   ActS_StunBump_DoMoveVert
.chkMoveDown:
	; If there's a solid block below, jump
	call ActColi_GetBlockId_Ground
	call ActBGColi_IsSolidOnTop
	or   a
	jp   nz, .landed
	; Otherwise continue moving vertically
	jp   ActS_StunBump_DoMoveVert
	
.landed:
	jp   ActS_StartStunGroundMove
	
; =============== ActS_StunBump_MoveRight ===============
; Moves the actor right during the jump arc when stunned.
; IN
; - BC: Movement speed
ActS_StunBump_MoveRight:
	; Move right by BC
	call ActS_MoveRight
	; If there's a solid block on the right, start moving the actor to the left.
	; This is part of what accounts for the famous (?) bounce around when stunning actors.
	call ActColi_GetBlockId_LowR
	call ActBGColi_IsSolid
	or   a
	jr   nz, ActS_StunBump_SwitchHorzMove
	
	ret
	
; =============== ActS_StunBump_MoveLeft ===============	
; Moves the actor left during the jump arc when stunned.
; IN
; - BC: Movement speed
ActS_StunBump_MoveLeft:
	call ActS_MoveLeft
	
	; If there's a solid block on the left, start moving the actor to the right.
	call ActColi_GetBlockId_LowL
	call ActBGColi_IsSolid
	or   a
	jr   nz, ActS_StunBump_SwitchHorzMove
	
	ret
	
; =============== ActS_StunBump_SwitchHorzMove ===============	
; This subroutine is called when a solid wall is reached.
; It inverts the direction the actor's moving to make it rebound when it hits a wall.
ActS_StunBump_SwitchHorzMove:
	ld   a, [sActSetRoutineId]
	xor  $30
	ld   [sActSetRoutineId], a
	ret
	
; =============== ActS_StartJumpDeadSameColiFromHeld ===============
; Variation of ActS_StartJumpDeadSameColi called when the current actor is being held.
ActS_StartJumpDeadSameColiFromHeld:
	; Make sure to clear the held status since we're killing it
	xor  a
	ld   [sActHeld], a
	ld   [sActHeldKey], a
; =============== ActS_StartJumpDeadSameColi ===============
; Parent subroutine for starting the jump animation for actors when they die.
; Called when an actor dies after something is thrown at it.
; [TCRF] This is almost identical to ActS_StartJumpDead.
;        The only difference is that this one does not set the actor collision as intangible...
;        ...but it doesn't even matter!
;        By jumping to ActS_StartJumpDead, this will set the actor as intangible anyway.
;
;        Considering this is called only when an actor dies after being thrown something at it,
;        maybe you were meant to be able to pick it up again (much like the actor bouncing around)?
ActS_StartJumpDeadSameColi:
	xor  a
	ld   [sActSetRoutineId], a
	ld   a, SFX1_14
	ld   [sSFX1Set], a
	jr   ActS_DoStartJumpDead
	
; =============== ActS_Unused_DoStartJumpDeadStub ===============
; [TCRF] Unused stubs used by ActS_Unused_StartJumpDeadOnPlBig.
; =============== ActS_Unused_DoStartJumpDeadStub ===============
ActS_Unused_DoStartJumpDeadStub: 
	jr   ActS_DoStartJumpDead
ActS_Unused_StartStunGroundMoveStub:
	jp   ActS_StartStunGroundMove
	
; =============== ActS_Unused_StartJumpDownDead ===============
; This unreferenced subroutine is almost identical to ActS_StunGroundMove_Kill,
; which is routine $02 for ActS_StunGroundMove.
;
; The only difference is that the actor's routine ID isn't reset here.
ActS_Unused_StartJumpDownDead:
	; Award 1 heart
	call Game_Add1Heart
	;--
	; [POI] Again with this. 
	; This just clears the lower nybble of sActSetOpts, but it's very weird.
	ld   a, [sActSetOpts]
	and  a, $F0
	; This whole part with 'b' does nothing at all, since a is $00
	ld   b, a
	ld   a, $00
	and  a, $0F
	or   a, b
	ld   [sActSetOpts], a
	;--

	; Set loop code
	ld   bc, SubCall_ActS_DoJumpDead1
	call ActS_SetCodePtr
	
	; Reset vars and OBJLst
	xor  a
	ld   [sActSetColiType], a
	ld   [sActSetTimer], a
	call ActS_SetStunOBJLst
	
	; Set initial upwards speed for jump arc
	mActSetYSpeed -$02
	ret
	
; =============== ActS_DoStartJumpDead ===============
; This subroutine contains the common code for starting the jump animation for actors when they die.
;
; This are those where the actor:
; - doesn't die immediately (ie: not groundpound or lava)
; - doesn't award any coins (ie: not a dash)
ActS_DoStartJumpDead:
	; Award one heart
	call Game_Add1Heart
	;--
	; [POI] This just clears the lower nybble of the actor flags, but it's very weird.
	;       Likely copy/pasted and modified from other code which made more sense.
	ld   a, [sActSetOpts]
	and  a, $F0
	; This whole part with 'b' does nothing at all, since a is $00
	ld   b, a
	ld   a, $00
	and  a, $0F
	or   a, b
	ld   [sActSetOpts], a
	;--
; =============== ActS_DoStartJumpDead_NoHeart ===============
; Basically ActS_DoStartJumpDead but skips awarding the 1 heart.
ActS_DoStartJumpDead_NoHeart:
	; Set code for jump effect
	ld   bc, SubCall_ActS_DoJumpDead2
	call ActS_SetCodePtr
	
	; [TCRF] And this is why the difference between ActS_StartJumpDead 
	;        and ActS_StartJumpDeadSameColi does not matter.
	;        The collision type gets reset, and both subroutines get here!
	xor  a
	ld   [sActSetColiType], a
	ld   [sActSetTimer], a
	
	; Set new OBJLstPtr
	call ActS_SetStunOBJLst
	;--
	; Start the upwards jump by setting a negative downwards movement speed.
	;
	; This will make the actor move upwards at first until it gets incremented over time,
	; which eventually makes it positive again.
	ld   bc, -$03
	ld   a, c
	ld   [sActSetYSpeed_Low], a
	ld   a, b
	ld   [sActSetYSpeed_High], a
	ret
; =============== ActS_StartJumpDead ===============
; Parent subroutine for starting the jump animation for actors when they die.
; See also: ActS_StartJumpDeadSameColi.
ActS_StartJumpDead:
	xor  a
	ld   [sActSetColiType], a
	ld   [sActSetRoutineId], a
	ld   a, SFX1_14
	ld   [sSFX1Set], a
	jp   ActS_DoStartJumpDead
; =============== ActS_StartJumpDead_NoHeart ===============
; Parent subroutine for starting the jump animation for actors when they die.
; This variant does not award any heart.
; See also: ActS_StartJumpDeadSameColi.
ActS_StartJumpDead_NoHeart:
	xor  a
	ld   [sActSetColiType], a
	ld   [sActSetRoutineId], a
	ld   a, SFX1_14
	ld   [sSFX1Set], a
	jp   ActS_DoStartJumpDead_NoHeart
	
; =============== ActS_StunGroundMove_Kill ===============
; This subroutine kills the currently processed actor.
; Routine $02 for ActS_StunGroundMove.
; This is meant to be used when landing on an actor too quickly after stunning it
; -- we assume this happens when there isn't enough vertical space to bounce away.
; To avoid getting the player stuck, the actor is killed.
ActS_StunGroundMove_Kill:
	; Award 1 heart
	call Game_Add1Heart
	;--
	; [POI] Again with this. 
	; This just clears the lower nybble of sActSetOpts, but it's very weird.
	ld   a, [sActSetOpts]
	and  a, $F0
	; This whole part with 'b' does nothing at all, since a is $00
	ld   b, a
	ld   a, $00
	and  a, $0F
	or   a, b
	ld   [sActSetOpts], a
	;--

	; Set loop code
	ld   bc, SubCall_ActS_DoJumpDead1
	call ActS_SetCodePtr
	
	; Reset vars and OBJLst
	xor  a
	ld   [sActSetColiType], a
	ld   [sActSetTimer], a
	ld   [sActSetRoutineId], a
	call ActS_SetStunOBJLst
	
	; Set initial upwards speed for jump arc
	mActSetYSpeed -$02
	ret
	
; =============== ActS_DoJumpDead* ===============	
; Each of these wraps ActS_DoJumpDead, specifying a different interaction movement speed.
; =============== ActS_DoJumpDead1 ===============
ActS_DoJumpDead1:
	ld   bc, $01
	jr   ActS_DoJumpDead
; =============== ActS_DoJumpDead2 ===============
ActS_DoJumpDead2:
	ld   bc, $02
	jr   ActS_DoJumpDead
; =============== ActS_Unused_DoJumpDead3 ===============
; [TCRF] This happens to not be used.	
ActS_Unused_DoJumpDead3:
	ld   bc, $03
	jr   ActS_DoJumpDead
; =============== ActS_DoJumpDead ===============
; This subroutine handles the jump animation for actors when they die.
; This makes them jump upwards for a bit, then fall down until they get off-screen.
;
; This is meant to be executed instead of the normal actor code after one is considered dead --
; the actor code ptr will point to a small subroutine that simply calls this with the right parameters.
;
; NOTE: This is strictly used for the vertical jump effect when actors die, *not* for any part of the throw effect.
;		However, if a thrown actor that hit another actor isn't grabbed back in time, execution will get here.
;		At that point, the actor won't be tangible anymore (unless you manage to scroll it off-screen :D).
; IN
; - BC: Horizontal movement speed if interacted from left or right
ActS_DoJumpDead:

	;--
	; If we've been interacted *from* a certain direction, make the actor move in the opposite one.
	; Most of the time the flags are never set.
	ld   a, [sActSetRoutineId]
	bit  ACTINTB_L, a			; Was this actor interacted from the left?
	call nz, ActS_MoveRight		; If so, move it right 
	ld   a, [sActSetRoutineId]
	bit  ACTINTB_R, a			; Was this actor interacted from the right?
	call nz, ActS_MoveLeft		; If so, move it left 
	;--
	
	; Reset collision type to make actor intangible
	xor  a
	ld   [sActSetColiType], a
	
	; Timer++
	ld   a, [sActSetTimer]			
	inc  a
	ld   [sActSetTimer], a
	
	;--
	; Every 4 frames, increase the anim frame id
	ld   a, [sTimer]
	and  a, $03						
	jr   nz, .setSpd
	ld   a, [sActSetOBJLstId]		; sActSetOBJLstId++
	inc  a
	ld   [sActSetOBJLstId], a
	;--
.setSpd:
	; Process the jump speed
	call ActS_FallDownMax4Speed
	
	; Despawn the actor if it ends up offscreen
	call ActS_CheckOffScreen		; Update offscreen status
	ld   a, [sActSet]
	cp   a, $02						; Is the actor visible (and active)?
	ret  nc							; If so, jump
	xor  a							; Otherwise, permanently despawn it
	ld   [sActSet], a
	ret
	
; =============== ActS_OnPlColiBelow ===============
; This subroutine starts the stun effect for actors when interacting them from below.
; This sets up the initial properties for the jump arc, among other things.
ActS_OnPlColiBelow:
	ld   a, SFX1_01				; Set SFX
	ld   [sSFX1Set], a
	ld   bc, SubCall_ActS_StunBumpNorm	; Set loop code
	call ActS_SetCodePtr
	ld   a, $00						; Reset timer
	ld   [sActSetTimer], a
	
	; Set initial Y movement speed for the jump arc
	mActSetYSpeed -$03				; (moves 3px/frame upwards)
	
	; Move actor upwards by 8px, to move it away from the player
	ld   bc, -$08					
	call ActS_MoveDown	
	
	; Make all sides safe to touch
	mActColiMask ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Set default OBJLst from the shared table
	call ActS_SetStunOBJLst
	
	; Save the horizontal direction for the jump arc.
	; This is set to the same direction the player's facing.
	; (ie: if the player is facing right, the actor's is bumped right)
	;
	; Since this is done through the "interaction direction", this works in reverse.
	; (ie: when the actor is marked as being interacted from the left, this pushes it to the right)
	ld   a, ACTINT_L				; Mark as interacted from the left (to move right)
	ld   [sActSetRoutineId], a		; Save this in the routine ID as usual
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a			; Is the player facing right?
	ret  nz							; If so, return
	ld   a, ACTINT_R				; Otherwise, mark as interacted from the right (to move left)
	ld   [sActSetRoutineId], a
	ret
	
; =============== ActS_Unused_StartJumpDeadTest ===============
; [TCRF] Unreferenced subroutine.
;        This subroutine kills the currently processed actor, but it does that
;        in different ways if we're holding B or not.
;
;        In practice, when B is held the actor doesn't move up in the jump effect.
;
;        The way it's structured and what it does make no sense, so it
;        may have been used for quickly testing the subroutines.
ActS_Unused_StartJumpDeadTest:
	; This even uses the otherwise unused ActS_Unused_StartJumpDownDead
	ldh  a, [hJoyKeys]
	bit  KEYB_B, a								; Are we holding B?
	jp   z, ActS_Unused_StartJumpDownDeadStub	; If not, jump
	; Otherwise, use standard "death jump" to bottom of the screen effect
	jp   ActS_Unused_DoStartJumpDeadStub2
	
; =============== ActS_OnPlColiTop ===============
; This subroutine starts the stun effect for actors when interacting them from above.
ActS_OnPlColiTop:
	; Player collision underwater kills the actor
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a
	jp   z, ActS_StartJumpDead
	; Otherwise switch to ActS_StartStunGroundMove
	jp   ActS_StartStunGroundMove
; =============== ActS_StartStarKill ===============
; This subroutine starts the instakill effect for actors when they die.
; This is where the actor:
; - dies immiediately with a star effect (ie: falling into lava/spikes)
; - doesn't award any coins
;
; What this does is initialize the "star kill" effect over the current actor slot.
; "Star kill" refers to the pair of small stars which appear when an actor dies
; when falling on spikes/being groundpounded on, ...
;
ActS_StartStarKill:
	; Award 1 heart
	call Game_Add1Heart
ActS_StartStarKill_NoHeart:
	; Set code ptr
	ld   bc, SubCall_ActS_StarKill
	call ActS_SetCodePtr
	; Reset timer
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSetTimer2], a		; (not used?)
	ld   [sActSetOBJLstId], a
	; Make intangible
	xor  a
	ld   [sActSetColiType], a
	; Special value for star effect (which doubles as setting ACT_NORESPAWN)
	ld   a, $81
	ld   [sActSetId], a
	; Set death SFX
	ld   a, SFX1_0F
	ld   [sSFX1Set], a
	;--
	; Set the OBJLst table for the small stars (kill ver)
	push bc
	ld   bc, OBJLstPtrTable_Act_StarKill
	call ActS_SetOBJLstPtr
	pop  bc
	;--
	; mActS_SetOBJBank OBJLstPtrTable_Act_StarKill
	ld   b, BANK(OBJLstPtrTable_Act_StarKill)		; B = Target bank
	ld   hl, sActOBJLstBank		; HL = Start of bank table
	ld   a, [sActNumProc]
	ld   d, $00					; DE = Slot Id
	ld   e, a
	add  hl, de					; Index it
	ld   [hl], b
	;--
	; If we're invincible while the actor is dying, award 10 hearts and a show heart gfx.
	; Because of careful powerup placement, the only way to trigger this is when touching
	; an enemy while invicible.
	call SubCall_ActS_SpawnHeartInvincible
	ret
; =============== ActS_StartGroundPoundStun ===============
; Starts the post-ground pound stun effect for the currently loaded actor.
ActS_StartGroundPoundStun:
	; Set the collision type as bumpable on all sides
	mActColiMask ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Unreferenced subcall points to this label.
ActS_StartGroundPoundStun_NoChgColi:			
	; Execute the main stun Replace code ptr
	ld   bc, SubCall_ActS_DoGroundPoundStun
	call ActS_SetCodePtr
	
	; The OBJLstPtrTable for the stun effect uses a known index shared across actors.
	; So we can update that here.
	xor  a
	ld   [sActSetTimer], a
	call ActS_SetStunOBJLst
	ret
	
; =============== ActS_StartStunNorm ===============
; This subroutine sets up the code to make the current actor stunned.
; This is meant to be used for non-default actors only, unlike ActS_StartStun.
ActS_StartStunNorm:
	; Set code ptr
	ld   bc, SubCall_ActS_Stun
	call ActS_SetCodePtr
	; Reset timers
	xor  a
	ld   [sActSetTimer], a
	ld   a, $00 				; [POI] Quickly patched out?
	ld   [sActStunDrop], a
	call ActS_SetStunOBJLst
	; Set as safe to touch
	mActColiMask ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM	
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== ActS_StartSwitchDir ===============
; This subroutine is called when an actor changes direction prematurely
; due to player interaction.
; This generally happens at the end of a soft bump, but also after
; an actor deals damage.
;
; Note that a few actors partially handle this in their own way 
; (ie: hedgehogs changing direction after becoming spiky)
ActS_StartSwitchDir:
	; Set code ptr
	ld   bc, SubCall_ActS_SwitchDir
	call ActS_SetCodePtr
	; Reset vars
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSetTimer2], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer6], a
	ld   [sActSetTimer7], a
	ld   [sActSetRoutineId], a
	
	; Switch the current direction
	ld   a, [sActSetDir]
	xor  DIR_L|DIR_R
	ld   [sActSetDir], a
	ret
	
; =============== ActS_StartStunGroundMove ===============
; Sets up code for having a stunned actor move horizonally on the ground.
; This is not meant to be used when an actor is thrown.
ActS_StartStunGroundMove:
	; Set initial horz movement speed of 2px/frame
	ld   a, $02
	ld   [sActStunGroundMoveAltHSpeed], a
	; Set code / OBJLst ptrs
	ld   bc, SubCall_ActS_StunGroundMove
	call ActS_SetCodePtr
	call ActS_SetStunOBJLst
	; Reset timer
	xor  a
	ld   [sActSetTimer], a
	ret
	
; =============== ActInitS_Unused_StunFloatingMovingPlatform ===============
; [TCRF]  Unreferenced init code for platforms floating on the water surface,
;         meant to be called by another actor's code.
ActInitS_Unused_StunFloatingMovingPlatform:
	; Make intangible (for a while) to avoid interrupting the bounce
	xor  a
	ld   [sActSetColiType], a
	
	; Set new OBJLstPtrTable
	; Interestingly, it uses the first set of shared animations, which is otherwise
	; unused but has a similar (the same?) purpose to ActS_SetStunOBJLst.
	call ActS_Unused_SetIndexedOBJLstPtrTable_00_02
	
	; Set code ptr
	ld   bc, SubCall_ActS_Unused_StunFloatingMovingPlatform
	call ActS_SetCodePtr
	
	; Init vars
	ld   a, $00					
	ld   [sActSetTimer], a
	ld   [sActSetTimer2], a
	ld   [sActSetTimer3], a
	
	; Move from the opposite direction we're being interacted from.
	; ie: If we got bumped from the left side, move to the right.
	ld   a, [sActSetRoutineId]
	swap a
	xor  a, DIR_R|DIR_L
	ld   [sActSetDir], a
	
	;
	; If we're holding B, start moving with an higher horz. speed.
	; Note that, eventually, the speed decreases to $08.
	;
	ldh  a, [hJoyKeys]
	bit  KEYB_B, a				; Are we holding B?
	jr   nz, .fast				; If so, move away faster
	ld   a, $14
	ld   [sActStunPlatformHSpeed], a
	ret  
.fast:
	ld   a, $1C
	ld   [sActStunPlatformHSpeed], a
	ret 
; =============== ActS_StartStunRecover ===============
; Sets up the current actor's routine to one for small jump after the stun ends.
ActS_StartStunRecover:
	; Set new OBJLstPtrTable
	call ActS_SetRecoverOBJLst
	; Set code ptr
	ld   bc, SubCall_ActS_DoStunRecover
	call ActS_SetCodePtr
	; Reset collision and index (for jump effect)
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSetColiType], a
	; Play wake up SFX
	ld   a, SFX1_11
	ld   [sSFX1Set], a
	ret
	
; =============== ActInitS_Unused_StunRecoverInstant ===============
; [TCRF] Unreferenced variant of ActS_StartStunRecover.
;        The difference here is that the small jump is skipped and the
;        actor recovers immediately.
ActInitS_Unused_StunRecoverInstant:
	; Drop whatever actor we're holding, for some reason
	xor  a				
	ld   [sActHeld], a
	
	; Set new OBJLstPtrTable
	call ActS_SetRecoverOBJLst
	; Set code ptr
	ld   bc, SubCall_ActS_DoStunRecover
	call ActS_SetCodePtr
	
	; Set timer far enough that the actor immediately reloads itself
	ld   a, $32				
	ld   [sActSetTimer], a
	; Reset collision type
	xor  a					
	ld   [sActSetColiType], a
	ret  
	
; =============== ActS_StarKill ===============
; Handles the effect of actors being instakilled (star effect).
; This updates the anim frame 4 times, then permadespawns the actor.
ActS_StarKill:
	; Every 4 frames increase the anim frame
	; [NOTE] This could have gone off sActSetTimer instead, since sTimer is not aligned to sActSetTimer.
	; Not like it matters much since the OBJLstTable we're using has dummy entries for this past the last real index.
	; Also note that sTimer is always updated, while sActSetTimer isn't if the actor isn't processed.
	; This means the animation increase may be different depending on lag frames.
	ld   a, [sTimer]
	and  a, $03					; Timer % 4 == 0?
	jr   nz, .setTimer			; If not, jump
	ld   a, [sActSetOBJLstId]	; AnimFrame++
	inc  a
	ld   [sActSetOBJLstId], a
	
.setTimer:
	ld   a, [sActSetTimer]		; ActTimer++
	inc  a
	ld   [sActSetTimer], a
	;--
	; Should we mark the actor as permadespawned yet?
	; (read: marking the slot as freed without saving back to the actor layout)
	;
	; NOTE: The code for this is weird and longer than it should have been.
	; What this basically does is check for sActSetTimer < $10.
	; Since every 4 timer ticks the anim frame is increased, what this actually means is checking for sActSetOBJLstId < $04.
	; Anim frame $04 is the first blank frame.
	;
	; So, what we actually want is to despawn the actor when it reaches its blank frame.
	; (more or less... as it will try to use the fourth frame for a bit due to the [NOTE] mentioned above)
	
	
	; Every 4 ActTimer ticks check for this
	ld   b, a		; Save A
	and  a, $03		; ActTimer % 4 == 0?
	ret  nz			; If not, return
	
	ld   a, b		; Restore A
	srl  a			; A = A / 4 (divide by number of frames it takes to update the frame)
	srl  a
	cp   a, $04		; Have we increased the frame 4 times?
	ret  c			; If not, return
	xor  a			; Otherwise, despawn the actor
	ld   [sActSet], a
	ret

; =============== ActS_DashKill ===============
; Loop code for an actor when it's defeated by a dash attack.
ActS_DashKill:
	ld   a, [sActSetTimer]		; sActSetTimer++
	inc  a
	ld   [sActSetTimer], a
	
	; After 4 frames, spawn the awarded coin
	cp   a, $04
	call z, SubCall_ActS_SpawnCoinFromDash
	
	; Move it horizontally based on the direction it was interacted from
	ld   a, [sActSetRoutineId]
	bit  ACTINTB_L, a					; Attacked from the left?
	call nz, ActS_DashKill_MoveRight	; If so, move it right.
	ld   a, [sActSetRoutineId]
	bit  ACTINTB_R, a					; Attacked from the right?
	call nz, ActS_DashKill_MoveLeft		; If so, move it left.
	
	; Handle the vertical jump arc
	; Remember this value starts out as negative
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown					; Move down by that
	
	; Every 4 frames increase the downwards speed
	ld   a, [sActSetTimer]
	and  a, $03
	jr   nz, .chkOffScreen
	ld   a, [sActSetYSpeed_Low]		; sActSetYSpeed++
	add  $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00							; account for carry
	ld   [sActSetYSpeed_High], a
.chkOffScreen:;R
	; When the actor goes off screen, permadespawn it by freeing the slot
	; and not saving back to the actor layout.
	
	; Note that other code may save it back in the actor layout.
	; ie: Entering a door before the actor goes off screen "revives" it.
	call ActS_CheckOffScreen			; Update offscreen status
	ld   a, [sActSet]
	cp   a, $02							; Is the actor visible and active?
	ret  nc								; If so, return
	xor  a								; Otherwise, mark the slot as free.
	ld   [sActSet], a
	ret
; =============== ActS_DashKill_Move* ===============
; Horizontal movement subroutines for an actor when dash attacked.
; Since collision detection doesn't happen anymore when an actor is killed, these are simple.

; =============== ActS_DashKill_MoveRight ===============
ActS_DashKill_MoveRight:
	ld   bc, +$03
	call ActS_MoveRight
	ret
; =============== ActS_DashKill_MoveLeft ===============
ActS_DashKill_MoveLeft:
	ld   bc, -$03
	call ActS_MoveRight
	ret
	
; =============== ActS_BumpSoft ===============
; This subroutine handles "soft bump" state for actors.
;
; Soft bumps happen exclusively when walking into actors as Small Wario or when ducking.
; These do not put the actor into the stun state, but just freeze it for a few
; frames, then make it change direction.
ActS_BumpSoft:
	; Reset the timer when stunning the actor again in this state (horizontal or from below).
	; This extends the length of the soft bump.
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw ActS_BumpSoft_Main
	dw ActS_BumpSoft_Reset	
	dw ActS_BumpSoft_Reset
	dw ActS_StartStarKill;X
	dw ActS_OnPlColiBelow;X
	dw ActS_StartDashKill;X
	dw ActS_BumpSoft_Main;X
	dw ActS_BumpSoft_Main;X
	dw ActS_StartJumpDeadSameColi;X
ActS_BumpSoft_Reset:
	xor  a
	ld   [sActSetTimer], a
ActS_BumpSoft_Main:
	; If overlapping with a spike block, instakill the actor
	call ActColi_GetBlockId_Low
	call ActBGColi_IsSpikeBlock
	or   a
	jp   nz, ActS_StartStarKill
	
	; Timer++
	ld   a, [sActSetTimer]
	inc  a
	ld   [sActSetTimer], a
	
	; When the timer reaches $24, end the bump
	cp   a, $24
	jp   nc, ActS_StartSwitchDir
	
	; If the actor is on a water block, prevent horizontal movement
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a
	call z, ActS_ClearInteractDir
	
ActS_BumpSoft_MoveHorz:
	; Move the actor depending on where it was being interacted from
	ld   a, [sActSetRoutineId]
	bit  ACTINTB_L, a						; Interacted from the left?
	jr   nz, ActS_BumpSoft_MoveRight		; If so, move right
	bit  ACTINTB_R, a						; Interacted from the right?
	jr   nz, ActS_BumpSoft_MoveLeft			; If so, move left
	
ActS_BumpSoft_MoveVert:
	; If there's a solid block below, just reset the vertical speed and return
	call ActColi_GetBlockId_Ground
	call ActBGColi_IsSolidOnTop
	or   a
	jr   nz, ActS_ResetYSpeedLow
	
	; If we went underwater, drop straight down and leave this to ActS_SafeDropUnderwater
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a
	jp   z, ActS_SafeDropUnderwater
	
	; Otherwise, we're in the air.
	; Drop the actor down at an increasing Y speed.
	ld   a, [sActSetYSpeed_Low]			; BC = sActSetYSpeed_Low
	ld   c, a
	ld   b, $00
	call ActS_MoveDown						; Move down by that
	; Every 4 frames increase the Y speed
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, [sActSetYSpeed_Low]
	inc  a
	ld   [sActSetYSpeed_Low], a
	ret
; =============== ActS_ResetYSpeedLow ===============
; Resets the drop speed, for use after landing on a solid block.
; Meant to be used when an actor moves bumped along the ground.
ActS_ResetYSpeedLow:
	xor  a
	ld   [sActSetYSpeed_Low], a
	ret
; =============== ActS_BumpSoft_MoveRight ===============
; Moves the actor to the right when soft bumped.
ActS_BumpSoft_MoveRight:
	; If there's a solid block on the right, stun the actor
	call ActColi_GetBlockId_LowR
	call ActBGColi_IsSolid
	or   a
	jr   nz, ActS_BumpSoft_SwitchToStun
	
	; If a custom speed value is specified in sActBumpSoftAltHSpeed, use that.
	; Otherwise, default to 1px/frame.
	; This is used to move the actor away at 2px/frame for a single frame.
	ld   a, [sActBumpSoftAltHSpeed]
	or   a							; Is the alt speed set?
	jr   z, .useDef					; If not, use the fixed 1px/frame
.useAlt:
	ld   c, a						; BC = sActBumpSoftAltHSpeed
	ld   b, $00
	call ActS_MoveRight				; Move right by that
	call ActS_DecBumpHSpeed			; Decrement the speed
	jr   ActS_BumpSoft_MoveVert
.useDef:
	ld   bc, +$01
	call ActS_MoveRight
	jr   ActS_BumpSoft_MoveVert
; =============== ActS_BumpSoft_SwitchToStun ===============
ActS_BumpSoft_SwitchToStun:
	ld   a, [sActSetRoutineId]		; Invert the interaction direction
	xor  ACTINT_R|ACTINT_L
	ld   [sActSetRoutineId], a
	jp   ActS_StartStunBump			; Stun the actor
	
; =============== ActS_DecBumpHSpeed ===============
; Decrements the extra horizontal speed for bumped/stunned actors which move along the ground.
; This should only be used when sActBumpSoftAltHSpeed marks an additional horizontal speed.
;
; For example, after jumping on an actor, it gets stunned and moves along the ground.
; The first few frames it moves at a 2px/frame speed, which then decreases quickly
; until it reaches 1px/frame.
; The way this is done is by always moving at 1px/frame, but having an additional
; 2px/frame speed applied as well. sActBumpSoftAltHSpeed gets reused for storing this extra speed.
; This subroutine is what decreases that speed.
ActS_DecBumpHSpeed:
	; [POI] Curiously, for heavy actors the extra speed is never decremented.
	;		So they get to move at a fixed 2px/frame speed.
	;		Doesn't it make more sense the other way around, since they are heavier?
	ld   a, [sActSetOpts]
	bit  ACTFLAGB_HEAVY, a		; Is this an heavy actor?
	ret  nz						; If so, return
	
	; Every other frame decrement the extra speed by 1.
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   a, [sActBumpSoftAltHSpeed]
	dec  a
	ld   [sActBumpSoftAltHSpeed], a
	ret
	
; =============== ActS_BumpSoft_MoveLeft ===============
; Moves the actor to the left when soft bumped.
ActS_BumpSoft_MoveLeft:
	; If there's a solid block on the left, stun the actor
	call ActColi_GetBlockId_LowL
	call ActBGColi_IsSolid
	or   a
	jr   nz, ActS_BumpSoft_SwitchToStun
	
	; If a custom speed value is specified in sActBumpSoftAltHSpeed, use that.
	; Otherwise, default to 1px/frame.
	; This is used to move the actor away at 2px/frame for a single frame.
	ld   a, [sActBumpSoftAltHSpeed]
	or   a							; Is the alt speed set?
	jr   z, .useDef					; If not, use the fixed 1px/frame
.useAlt:
	; Convert the positive number to negative
	; BC = -sActBumpSoftAltHSpeed
	ld   c, a							
	xor  a							; A = 0
	sub  a, c						; A -= sActBumpSoftAltHSpeed
	ld   c, a
	ld   b, $FF						
	call ActS_MoveRight				; Move right by that
	call ActS_DecBumpHSpeed
	jp   ActS_BumpSoft_MoveVert
.useDef:
	ld   bc, -$01
	call ActS_MoveRight
	jp   ActS_BumpSoft_MoveVert
	
; =============== ActS_ClearInteractDir ===============
; This subroutine clears the interaction direction value (high nybble of the routine id).
; This stops horizontal movement when an actor is stunned.
ActS_ClearInteractDir:
	ld   a, [sActSetRoutineId] ; sActSetRoutineId &= $0F
	and  a, $0F
	ld   [sActSetRoutineId], a
	ret
	
; =============== ActS_SafeDropUnderwater ===============
; Makes the currently processed actor move downwards while underwater.
; This is called when an actor is falling underwater but can safely land
; (read: not when thrown, which kills the actor when it lands).
ActS_SafeDropUnderwater:
	; Move down at a fixed 1px/frame speed (ignore sActSetYSpeed_Low)
	ld   bc, $0001
	call ActS_MoveDown
	
	; If the actor was set to drop at a faster speed, sync it up.
	; This in practice happens when first entering the water surface.
	ld   a, [sActSetYSpeed_Low]
	cp   a, $02							; DropSpeed > $01?
	ret  c								; If not, return
	ld   a, SFX4_10						; Play water enter SFX
	ld   [sSFX4Set], a
	ld   a, $01							; Sync DropSpeed to actual value
	ld   [sActSetYSpeed_Low], a
IF FIX_BUGS == 1
	xor  a								; fix for stunning underwater actors	
	ld   [sActSetYSpeed_High], a
ENDC
	ret	
	
; =============== ActS_StunGroundMove ===============
; Loop code for a stunned actor when it moves horizontally on the ground.
; This can be easily seen when jumping on an actor, for example. 
; This is not for when an actor is thrown.
ActS_StunGroundMove:
	;--
	; Every 4 frames increase the anim frame
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkRestr
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	;--
.chkRestr:
	; Prevent player interaction in the first five frames
	ld   a, [sActSetTimer]
	cp   a, $05							; Is the timer <= $05?
	jr   c, ActS_StunGroundMove_Main	; If so, skip the routine block
	
	; Handle the player interaction routine
	; Note how routine $02 (for jumping on the actor) kills the actor here.
	; 
	; This is what accounts for the player killing an actor if it stuns
	; and actor, then very quickly jumps on it.
	; This is easy to recreate when there isn't enough vertical space.
	; Until the loop code is changed to the other stun routine, the actor
	; can't be picked up by jumping on it.
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw ActS_StunGroundMove_Main
	dw ActS_StartHeld
	dw ActS_StunGroundMove_Kill
	dw ActS_StartStarKill
	dw ActS_OnPlColiBelow
	dw ActS_StartDashKill
	dw ActS_StunGroundMove_Main;X
	dw ActS_StunGroundMove_Main;X
	dw ActS_StartJumpDeadSameColi ; Custom one
ActS_StunGroundMove_Main:
	; If the actor is over a spike block, instakill it
	call ActColi_GetBlockId_Low
	call ActBGColi_IsSpikeBlock
	or   a
	jp   nz, ActS_StartStarKill
	
	; Increase the timer until it gets to a certain value.
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	cp   a, $18					; Has it reached $18?
	jp   nc, ActS_StartStunNorm	; If so, switch to the normal stun sequence
								; where the actor stops moving
	
	;
	; HORIZONTAL MOVEMENT
	;
	
	; If the actor is in a water block, prevent horizontal movement
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a
	call z, ActS_ClearInteractDir
	
	; Move the actor depending on where it was being interacted from
	ld   a, [sActSetRoutineId]
	bit  ACTINTB_L, a						; Interacted from the left?
	jr   nz, ActS_StunGroundMove_MoveRight	; If so, move right
	bit  ACTINTB_R, a						; Interacted from the right?
	jr   nz, ActS_StunGroundMove_MoveLeft	; If so, move left
	;--
	
	;
	; VERTICAL MOVEMENT
	; (only for moving an actor down when there's no solid ground below)
	;
ActS_StunGroundMove_CheckDrop:
	; If the actor is on top of a solid block, jump
	call ActColi_GetBlockId_Ground
	call ActBGColi_IsSolidOnTop
	or   a
	jp   nz, ActS_ResetYSpeedLow
	;--
	; Otherwise, there's nothing below the actor and it can be moved down.
	
	; If the actor is in a water block, make it drop slowly
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a
	jp   z, ActS_SafeDropUnderwater
	
	;--
	; Otherwise make it fall at an increasingly faster speed
	ld   a, [sActSetYSpeed_Low]
	ld   c, a						; BC = sActSetYSpeed_Low
	ld   b, $00
	call ActS_MoveDown				; Move down by that speed
	; Every 4 frames, increase that speed
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, [sActSetYSpeed_Low]
	inc  a
	ld   [sActSetYSpeed_Low], a
	ret
	
; =============== ActS_StunGroundMove_MoveRight ===============
; Moves the actor right when it moves along the ground when stunned.
ActS_StunGroundMove_MoveRight:
	; If there's a solid block on the right, invert the direction
	call ActColi_GetBlockId_LowR
	call ActBGColi_IsSolid
	or   a
	jr   nz, ActS_StunGroundMove_SwitchHorzMove
	
	; The timer here is treated as an additional movement speed which decreases very quickly.
	; This starts at $02.
	ld   a, [sActStunGroundMoveAltHSpeed]
	or   a						; Has it reached $00?
	jr   z, .slow				; If so, skip this 
	
	ld   c, a					; BC = sActStunGroundMoveAltHSpeed
	ld   b, $00
	call ActS_MoveRight			; Move the actor right by sActStunGroundMoveAltHSpeed
	call ActS_DecBumpHSpeed		; Try to decrement the speed
	jr   ActS_StunGroundMove_CheckDrop
	
.slow:
	; Move right at a fixed 1px/frame
	ld   bc, +$01
	call ActS_MoveRight
	jr   ActS_StunGroundMove_CheckDrop
	
; =============== ActS_StunGroundMove_SwitchHorzMove ===============	
; This subroutine is called when a solid wall is reached.
; It inverts the direction the actor's moving to make it rebound when it hits a wall.
ActS_StunGroundMove_SwitchHorzMove:
	ld   a, [sActSetRoutineId]
	xor  $30
	ld   [sActSetRoutineId], a
	jr   ActS_StunGroundMove_CheckDrop
	
; =============== ActS_StunGroundMove_MoveLeft ===============
; Moves the actor left when it moves along the ground when stunned.
ActS_StunGroundMove_MoveLeft:
	; If there's a solid block on the left, invert the direction
	call ActColi_GetBlockId_LowL
	call ActBGColi_IsSolid
	or   a
	jr   nz, ActS_StunGroundMove_SwitchHorzMove
	
	; The timer here is treated as an additional movement speed which decreases very quickly.
	; This starts at $02.
	ld   a, [sActStunGroundMoveAltHSpeed]
	or   a						; Has it reached $00?
	jr   z, .slow				; If so, skip this 
	
	; Invert the value from positive to negative
	; BC = 0 - C
	ld   c, a									
	xor  a			; A = $00
	sub  a, c		; A = $00 - C
	ld   c, a		
	ld   b, $FF		; Upper byte very negative too
	
	call ActS_MoveRight					; Move right by that speed
	call ActS_DecBumpHSpeed				; Try to decrement the speed
	jp   ActS_StunGroundMove_CheckDrop
	
.slow:
	; Move left at a fixed 1px/frame
	ld   bc, -$01
	call ActS_MoveRight
	jp   ActS_StunGroundMove_CheckDrop
	
; =============== ActS_Unused_StunFloatingMovingPlatform ===============	
; [TCRF] Unused (shared) actor.
;        This... is pretty unique. It appears to be a variant of ActS_StunFloatingPlatform.
;        It's a platform floating on the water surface that moves horizontally.
;
;        Because of how player collision works, it's also incredibly glitchy, 
;        which may have been part of the reason this wasn't used.
;        (the water surface has... problems in this game)
ActS_Unused_StunFloatingMovingPlatform:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw .main;X
	dw .main;X
	dw .main;X
	dw ActS_StartStarKill;X
	dw .main;X
	dw .main;X
	dw .main;X
	dw .main;X
	dw ActS_StartJumpDeadSameColi;X
.main:          
	; If the actor is over a spike block, instakill it
	call ActColi_GetBlockId_Low
	call ActBGColi_IsSpikeBlock
	or   a
	jp   nz, ActS_StartStarKill
	
	;
	; HORIZONTAL MOVEMENT
	;
.chkMoveH:
	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Move every other frame depending on the horizontal speed.
	and  a, $01
	ret  nz
.moveH:
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Facing right?
	call nz, .moveR			; If so, move right
	ld   a, [sActSetDir]
	bit  DIRB_L, a			; Facing left?
	call nz, .moveL			; If so, move left
	
.chkFloatUp:
	;
	; If the actor is underwater, make it rise up and don't do anything else.
	; As a result, the player can go through it (no standing check).
	;
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a							; Overlapping with a water block?
	jr   nz, .chkStand				; If not, jump
	ld   a, [sActSetTimer]			; Otherwise, move up at 0.25px/frame
	and  a, $03
	ret  nz
	ld   bc, -$01
	call ActS_MoveDown
	ret  
.chkStand:
	; When it's not underwater, force it to be a top-solid platform.
	; Like any other top-solid platform, if we're standing on it and
	; the platform moved (which it did if we got here), the player should move as well.
	ld   a, ACTCOLI_TOPSOLID
	ld   [sActSetColiType], a
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06			; Standing on top of the actor?
	ret  nz						; If not, return
	; Otherwise, move the player in the same direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Moving right?
	call nz, ActS_PlStand_MoveRight ; If so, move the player right as well
	ld   a, [sActSetDir]
	bit  DIRB_L, a				; Moving left?
	call nz, ActS_PlStand_MoveLeft ; If so, move the player left as well
	ret  
	
.moveR:
	ld   a, DIR_R			; Face right
	ld   [sActSetDir], a
	
	;--
	ld   a, [sActSetTimer]	; Already did this -- not necessary
	and  a, $01
	ret  nz
	;--
	
	;
	; Move right depending on the speed.
	; The actual speed is value is multiplied by 8, and considering the actor
	; is moved every other frame, it's the same as HSpeed*4/frame.
	;
	ld   a, [sActStunPlatformHSpeed] ; BC = Speed * 8
	ld   c, a
	srl  c
	srl  c
	srl  c
	ld   b, $00
	call ActS_MoveRight		; Move right by that
	
	;
	; The location we're moving to must be above the water surface.
	; If it isn't, turn in the other direction.
	; As a result, the actor essentially stops moving if it's on solid ground.
	;
	; We're using ActColi_GetBlockId_BottomR because of the previous "is the actor underwater?" check.
	; That used ActColi_GetBlockId_Low, meaning that once we get here, the actor moved just high enough
	; that using ActColi_GetBlockId_LowR won't detect the water.
	;
	call ActColi_GetBlockId_BottomR
	call ActBGColi_IsEmptyWaterBlock
	or   a								; Is there water below?
	jr   nz, .turn				; If not, turn left
	
	;
	; Otherwise, decrease the movement speed, with the minimum value being 8.
	;
	ld   a, [sActStunPlatformHSpeed]	; HSpeed--
	dec  a
	ld   [sActStunPlatformHSpeed], a
	and  a, $F8							; HSpeed > $08?
	ret  nz								; If not, return
	ld   a, $08							; Otherwise, HSpeed = $08?
	ld   [sActStunPlatformHSpeed], a
	ret  
.turn:
	ld   a, [sActSetDir]
	xor  a, DIR_R|DIR_L
	ld   [sActSetDir], a
	ret  
.moveL:
	; Like .moveR, but for the other direction
	ld   a, DIR_L
	ld   [sActSetDir], a
	;--
	ld   a, [sActSetTimer]	; Already did this -- not necessary
	and  a, $01
	ret  nz
	;--
	; Move left by the horz. speed
	ld   a, [sActStunPlatformHSpeed] ; BC = HSpeed * 8
	srl  a
	srl  a
	srl  a
	ld   c, a
	ld   b, $00
	call ActS_MoveLeft
	
	; If we're over a solid block, turn right
	call ActColi_GetBlockId_BottomL
	call ActBGColi_IsEmptyWaterBlock
	or   a
	jr   nz, .turn
	
	; Decrease the speed down to 8
	ld   a, [sActStunPlatformHSpeed]
	dec  a
	ld   [sActStunPlatformHSpeed], a
	and  a, $F8
	ret  nz
	ld   a, $08
	ld   [sActStunPlatformHSpeed], a
	ret

; =============== ActInitS_StunFloatingPlatform ===============	
; Init code for platforms floating on the water surface, meant to be called by another actor's code.
; Used by actors that, when stunned, act as a top-solid platform.
ActInitS_StunFloatingPlatform:
	; Set loop code
	ld   bc, SubCall_ActS_StunFloatingPlatform
	call ActS_SetCodePtr
	
	; Reset Y speed and timers
	ld   a, $00
	ld   [sActSetTimer], a
	ld   [sActSetTimer2], a
	ld   [sActSetYSpeed_Low], a
	
	; Set the stun animation for the actor, according to the actor's shared anim table
	call ActS_ClearRoutineId
	call ActS_SetStunOBJLst
	ret
	
; =============== ActS_StunFloatingPlatform ===============
; Loop code for underwater actors that, when stunned, become top-solid platforms (ie: pelican).
; The actor remains in this state until it is despawned/reloaded.
ActS_StunFloatingPlatform:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw ActS_StunFloatingPlatform_Main
	dw ActS_StunFloatingPlatform_Main
	dw ActS_StunFloatingPlatform_Main
	dw ActS_StartStarKill
	dw ActS_StunFloatingPlatform_Main
	dw ActS_StartDashKill
	dw ActS_StunFloatingPlatform_Main
	dw ActS_StunFloatingPlatform_Main;X
	dw ActS_StartJumpDeadSameColi
	
; =============== ActS_StunFloatingPlatform_Main ===============
ActS_StunFloatingPlatform_Main:
	ld   a, [sActSetTimer]				; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	;
	; To perform the effect, the actor needs to be near the water surface.
	; If it isn't, we must move it there first.
	;
	

.chkBelowSurface:
	; If the actor is fully underwater (the block above it isn't an empty space),
	; make it rise up before performing the bob effect.
	; [TCRF] This never happens. All actors which can go through ActS_StunFloatingPlatform_Main
	;        are already placed on the water surface.
	call ActColi_GetBlockId_Top
	call ActBGColi_IsEmptyWaterBlock
	or   a										; Is there a water block above?
	jr   z, ActS_StunFloatingPlatform_Unused_InWater	; If so, jump
	;--
	
	; Use the "defeatable platform" type, since we should still
	; be able to kill the actor with a dash
	ld   a, ACTCOLI_TOPSOLIDHIT			
	ld   [sActSetColiType], a
	
.chkAboveSurface:

	;
	; If the actor is above water, make it slowly fall until it reaches a water block.
	;
	; Unlike ActS_StunFloatingPlatform_Unused_InWater, this is actually used because of how
	; Act_Pelican is aligned to the level layout -- when first stunning the actor,
	; it is *on top* of a water block, but not *inside* it.
	;
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a								; Is the actor underwater?
	jr   nz, .moveDown					; If not, jump
	
.ok:
	; Movement code trickery identical to Act_Pelican_UnderwaterMoveV, which is itself a variant of Act_Watch_Idle.
	; See those for more info.
	
	; Every 4 frames...
	ld   a, [sActSetTimer]
	ld   e, a
	and  a, $03
	ret  nz
	
	ld   a, e				; DE = ((sActSetTimer / 2) % $08)
	and  a, $1C				; keep in range, slowed down 2x
	rrca
	ld   e, a
	ld   d, $00
	ld   hl, ActS_StunFloatingPlatform_UnderwaterYPath	; HL = Y path table
	add  hl, de				; Offset it
	ld   c, [hl]			; BC = Y offset
	inc  hl
	ld   b, [hl]
	call ActS_MoveDown		; Move down by that
	
	
	; If the player is standing on the platform, move him as well
	ld   a, [sActSetRoutineId]
	and  a, $0F				; Clear interact. direction
	cp   a, ACTRTN_06		; Player standing on top?
	call z, ActS_StunFloatingPlatform_SyncPlMove	; If so, call
	ret
	
.moveDown:
	ld   bc, +$01
	call ActS_MoveDown
	ret
	
; =============== ActS_StunFloatingPlatform_Unused_InWater ===============
; IN
; - BC: Vertical movement
ActS_StunFloatingPlatform_SyncPlMove:
	bit  7, c				; Is the actor moving up?
	jr   nz, .moveUp		; If so, move the player up as well
.moveDown:
	; Move down 1px if there isn't a solid block in the way
	ld   b, $01
	call SubCall_PlBGColi_CheckGroundSolidOrMove
	ret
.moveUp:
	; Move up 1px if there isn't a solid block in the way
	ld   b, $01
	call SubCall_PlBGColi_DoTopAndMove
	ret
	
; =============== ActS_StunFloatingPlatform_Unused_InWater ===============
; [TCRF] When an actor going through ActS_StunFloatingPlatform is underwater,
;        this would make it rise up to the water surface.
; [BUG] Likely due to this not being used, it doesn't work properly.
;       The actor doesn't fully rise on the water surface, meaning that
;       after this finishes moving, the player will be actually swimming
;       when standing on top of the platform. 
ActS_StunFloatingPlatform_Unused_InWater: 
	; Curiously, the actor is made intangible while rising up.
	; There's not even a call to ActS_StunFloatingPlatform_SyncPlMove.
	xor  a
	ld   [sActSetColiType], a
	
	; Move up 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  z
	ld   bc, -$01
	call ActS_MoveDown
	ret
	
; =============== ActS_StunFloatingPlatform_UnderwaterYPath ===============
ActS_StunFloatingPlatform_UnderwaterYPath: 
	dw -$01,-$01,-$01,-$01,+$01,+$01,+$01,+$01
.end:

; =============== ActS_Stun ===============	
; Loop code for a normal actor when stunned.
ActS_Stun:

	; When an actor is dropped, a timer is set which decrements every execution frame.
	; This is done for two reasons:
	; - Normally, going near a stunned actor makes the player pick him up. This shouldn't happen immediately after dropping them.
	; - Dropped actors would trigger the solid block check (right after this one) and kill themselves immediately.
	; To avoid this, a timer is set when starting to drop an actor, and until it elapses it's not possible to pick the actor back.
	ld   a, [sActStunDrop]
	or   a								; Are we still in the drop sequence?
	jr   nz, .drop						; If so, jump
	
	; If it's overlapping with a solid block, kill the actor
	call ActColi_GetBlockId_Low
	call ActBGColi_IsSolid
	or   a
	jp   nz, ActS_StartJumpDead
	
	; Force the actor to be always harmless and pickable
	mActColiMask ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Switch to the specific routine
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw ActS_Stun_Main
	dw ActS_StartHeld
	dw ActS_StartHeld
	dw ActS_StartStarKill
	dw ActS_OnPlColiBelow
	dw ActS_StartDashKill
	dw ActS_Stun_Main;X
	dw ActS_Stun_Main;X
	dw ActS_StartJumpDeadSameColi
.drop:
	;
	; DROP SPECIFIC SEQUENCE
	;
	
	; Decrease the drop timer
	dec  a							; Timer--
	ld   [sActStunDrop], a
	
	; The drop sequence is the only way a stunned actor can move horizontally.
	; Until the timer ticks down to $1E, allow movement.
	; This (along with the vertical movement) makes it look like it's moving down in an arc.
	cp   a, $1E						; Is it < $1E now?
	jr   c, ActS_Stun_Main			; If so, stop movement.
	
	; Try to move the actor on the opposite direction it's facing.
	; This works since the actor's direction is set to be the same as the player direction
	; when first setting up the stun state.
	; As for why the reverse was picked, in theory this is mostly to account for moving too close to a wall
	; while holding an actor -- you want it to move further away from a wall when it drops, not closer.
	; In practice there's no real difference since it'd hit the solid block and bounce the other way around
	; anyway, though it's a little less elegant.
	ld   a, [sActSetDir]
	bit  DIRB_L, a					; Facing left? ($02)
	call nz, ActS_Stun_MoveRight	; If so, move right
	ld   a, [sActSetDir]
	bit  DIRB_R, a					; Facing right? ($01)
	call nz, ActS_Stun_MoveLeft		; If so, move left
	
	; Switch to the specific routine, which basically ignores almost every other action.
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw ActS_Stun_Main
	dw ActS_Stun_Main;X
	dw ActS_Stun_Main;X
	dw ActS_StartStarKill;X
	dw ActS_Stun_Main;X
	dw ActS_Stun_Main;X
	dw ActS_Stun_Main;X
	dw ActS_Stun_Main;X
	dw ActS_Stun_Main;X
; =============== ActS_Stun_Main ===============
; Main code for the actor when stunned.
ActS_Stun_Main:
	; If the actor is overlapping with a spike block, kill it
	call ActColi_GetBlockId_Low
	call ActBGColi_IsSpikeBlock
	or   a
	jp   nz, ActS_StartStarKill
	
	;--
	; Use the actor timer as "stun timer".
	; This is set to $00 when an actor is first stunned.
	; Once it reaches a certain value, the stun ends.
	
	; This value is different if the actor is heavy.
	ld   b, $64				; B = Target when heavy
	ld   a, [sActSetOpts]	
	bit  ACTFLAGB_HEAVY, a	; Is the actor heavy?
	jr   z, .incTimer		; If not, jump
	ld   b, $4B				; B = Target when light
.incTimer:
	ld   a, [sActSetTimer]	; Timer++
	inc  a
	cp   a, b				; Did we reach (or go past) the target value?
	jr   nc, .endStun		; If so, end the stun effect
	ld   [sActSetTimer], a
	
	;--
	; Every 4 frames increase the anim frame
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkColi2
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.chkColi2:
	;--
	; Make the actor fall down if there isn't a solid block below.
	
	
	; If the actor is standing on a solid block, don't move it
	call ActColi_GetBlockId_Ground
	call ActBGColi_IsSolidOnTop
	or   a
	jr   nz, .noFall
	
	; Is the actor is in a water block, make it drop slowly.
	; Since we didn't throw the actor, it can safely land once it reaches solid ground.
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a
	jp   z, ActS_SafeDropUnderwater
	
	; Otherwise move down by the amount specified in sActSetYSpeed_Low
	ld   a, [sActSetYSpeed_Low]
	ld   c, a						; BC = sActSetYSpeed_Low
	ld   b, $00
	call ActS_MoveDown				; Move down by that
	
	; Every 4 frames, increase the fall speed.
	; Note that there's no upper bound to this, but there's pratically 
	; no way to trigger the limit so who cares.
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, [sActSetYSpeed_Low]	; sActSetYSpeed_Low++
	inc  a
	ld   [sActSetYSpeed_Low], a
	ret
.noFall:
	; Reset fall speed
	xor  a
	ld   [sActSetYSpeed_Low], a
	ret
.endStun:
	; End the stun effect.
	ld   a, [sActSetOpts]
	bit  ACTFLAGB_NORECOVER, a		; Can this actor recover?
	jp   z, ActS_StartStunRecover	; If so, switch to the stun recover routine
	xor  a							; Otherwise, reset and continue indefinitely here
	ld   [sActSetTimer], a
	ret
; =============== ActS_StunDefault ===============	
; Loop code for a default actor when being stunned (dropped, or at the end of the throw for keys).
; In practice this happens for keys and 10coins.
; See also: ActS_Stun
ActS_StunDefault:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; If not in the drop sequence, ignore movement.
	ld   a, [sActStunDrop]
	or   a
	jr   nz, .drop
	
	; Switch to the specific routine
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw ActS_StunDefault_Main
	dw ActS_StartHeldForce;X
	dw ActS_StartHeldForce;X
	dw ActS_StartHeldForce;X
	dw ActS_StunDefault_Main;X
	dw ActS_StartHeldForce;X
	dw ActS_StunDefault_Main;X
	dw ActS_StunDefault_Main;X
	dw ActS_StunDefault_Main;X
.drop:
	;
	; DROP SPECIFIC SEQUENCE
	;
	
	; Decrease the drop timer
	dec  a
	ld   [sActStunDrop], a
	
	; If the timer is < $14, stop any horizontal movement
	cp   a, $14
	jr   c, ActS_StunDefault_Main
	
	; Move the actor on the opposite side it's facing, to hopefully move away from any walls in front of the player.
	; This is first set when dropping an actor to be the same direction as the player's facing.
	ld   a, [sActSetDir]
	bit  1, a						; Facing left? ($02)
	call nz, ActS_Stun_MoveRight	; If so, move right
	ld   a, [sActSetDir]
	bit  0, a						; Facing right? ($02)
	call nz, ActS_Stun_MoveLeft		; If so, move left
	
; =============== ActS_StunDefault_Main ===============	
; Main code for a default actor when being stunned.
ActS_StunDefault_Main:

	;--
	; Every 4 frames increase the anim frame
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkColi2
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.chkColi2:
	;--
	
	; Make the actor fall down if there isn't a solid block below.
	
	; If the actor is standing on a solid block, don't move it
	call ActColi_GetBlockId_Ground
	call ActBGColi_IsSolidOnTop
	or   a
	jr   nz, .noFall
	
	; Is the actor is in a water block, make it drop slowly.
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a
	jp   z, ActS_SafeDropUnderwater
	
	; Otherwise move down at an increasing speed (max 4)
	call ActS_FallDownMax4Speed
	ret
	
.noFall:
	ld   a, [sActSetY_Low]	; sActSetY_Low &= $F0
	and  a, $F0
	ld   [sActSetY_Low], a
	
	; [BUG] This should not be set when the actor is a 10-coin.
	;       Otherwise, the coin will indefinitely spin in-place.
	
	
;IF FIX_BUGS == 1
;	;--
;	ld   b, a				; Save A
;	ld   a, [sActSetId]
;	cp   a, ACT_KEY			; Are we holding a key?
;	jr   z, .noCheck		; If so, skip
;	ld   a, b				; Restore A
;		
;	ld   a, [sActCoinGroundTimer]
;	cp   a, $78					; Did we stay on the ground for more than $77 frames?
;	ret  c						; If so, return
;	xor  a						; Otherwise, despawn the coin
;	ld   [sActSet], a
;	;--
;.noCheck:
;ENDC
	
IF FIX_BUGS == 1
	ld   bc, SubCall_ActS_DefaultStand		; Set code ptr for key
	ld   a, [sActSetId]
	cp   a, ACT_KEY							; Are we holding a key?
	jr   z, .setCodePtr						; If so, skip
	ld   bc, SubCall_Act_Coin				; Set code ptr for 10coin
.setCodePtr:
ELSE
	ld   bc, SubCall_ActS_DefaultStand		; Set code ptr
ENDC
	call ActS_SetCodePtr
	
	;--
	; Save the bank number for locating the OBJLst to the table
	ld   b, $0F				; B = Bank number
	ld   hl, sActOBJLstBank ; HL = Start of table
	ld   a, [sActNumProc]	; 
	ld   d, $00				; DE = sActNumProc
	ld   e, a
	add  hl, de				; Index the table
	ld   [hl], b			; Save the bank number there
	;--
	
	call SubCall_ActColi_SetForDefault
	call SubCall_ActS_SetOBJLstTableForDefault
	ret
	
; =============== ActS_Stun Helpers ===============
; Helper subroutines only meant to be called to move an actor while falling
; in the stun state (after being dropped).

; =============== ActS_Stun_MoveRight ===============
; This subroutine moves the current actor 1 pixel to the right.
; Movement stops if there's a solid block on the right.
ActS_Stun_MoveRight:
	call ActColi_GetBlockId_LowR	
	call ActBGColi_IsSolid
	or   a								; Is there a solid block?
	jr   nz, ActS_Stun_SwitchHorzMove	; If so, invert movement
	ld   bc, +$01						; Otherwise, move right 1px
	call ActS_MoveRight
	ret
; =============== ActS_Stun_MoveRight ===============
; This subroutine moves the current actor 1 pixel to the left.
; Movement stops if there's a solid block on the left.
ActS_Stun_MoveLeft:
	call ActColi_GetBlockId_LowL
	call ActBGColi_IsSolid
	or   a							; Is there a solid block?
	jr   nz, ActS_Stun_SwitchHorzMove	; If so, invert movement
	ld   bc, -$01					; Otherwise, move left 1px
	call ActS_MoveRight
	ret
; =============== ActS_Stun_SwitchHorzMove ===============
; This subroutine inverts horizontal movement for the current actor.
ActS_Stun_SwitchHorzMove:
	ld   a, [sActSetDir]
	xor  $03
	ld   [sActSetDir], a
	ret
	
; =============== ActS_DoGroundPoundStun ===============
; Handles the ground-pound stun effect for the currently processed actor.
; During a stun, the actor is completely harmless and can be picked up (if it is pickable).
; This subroutine handles:
; - The start of the stun, where it does a small jump
; - Mid stun, with the collision checks for falling down 
; The end of the stun (the last jump), is handled elsewhere -- see ActS_StartStunRecover for that.
ActS_DoGroundPoundStun:
	;--
	; Every 4 frames increase anim frame
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .setTimer
	
	ld   a, [sActSetOBJLstId]	; sActSetOBJLstId++
	inc  a
	ld   [sActSetOBJLstId], a
	;--
.setTimer:
	; This times the entirety of the stun effect (including the starting and ending jump)
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Handle start/end action
	cp   a, $78			; >= $78?
	jr   nc, .endStun	; If so, we should recover from the stun
	; Since the timer doubles as index for the initial jump...
	cp   a, (ActS_StunJumpYPath.end-ActS_StunJumpYPath)/2	; < $0F?
	jr   c, .startStun		; If so, we're at the start of a stun (during the jump)

.midStun:
	; Otherwise, we're in the middle of the stun animation.
	; The actor should always be pickable (or non-lethal) on all sides.
	mActColiMask ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM
	ld   a, COLI			
	ld   [sActSetColiType], a
	
	; Depending on the current routine ID...
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw .norm
	dw ActS_StartHeld
	dw ActS_StartHeld
	dw ActS_StartStarKill
	dw ActS_OnPlColiBelow
	dw ActS_StartDashKill
	dw .norm;X
	dw .norm;X
	dw ActS_StartJumpDeadSameColi
	; Normal case
.norm:
	;--
	; If the the actor over a spike / instakill block, kill it
	call ActColi_GetBlockId_Low
	call ActBGColi_IsSpikeBlock
	or   a
	jp   nz, ActS_StartStarKill
	;--
	; If the actor is standing on solid ground, return (don't move it downwards)
	call ActColi_GetBlockId_Ground
	call ActBGColi_IsSolidOnTop
	or   a
	ret  nz
	;--
	; If we're on a water block, fall slower
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a
	jp   z, ActS_SafeDropUnderwater
	;--
	; If we get here, there's nothing below the actor.
	; Move it down, with the speed increasing every 4 frames.
	; The timer is also paused until it lands back on solid ground,
	; since we don't want to start the post-stun jump in mid-air.
	
	; Move down
	ld   a, [sActSetYSpeed_Low] ; BC = sActSetYSpeed_Low
	ld   c, a
	ld   b, $00
	call ActS_MoveDown
	; Every 4 frames increase the fall speed
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, [sActSetYSpeed_Low]
	inc  a
	ld   [sActSetYSpeed_Low], a
	ret
.endStun:
	jp   ActS_StartStunRecover
.startStun:
	; When the actor is first stunned, a jump effect takes place.
	; This goes off through a table of 16bit Y offsets.
	
	; Create the offset
	; DE = sActSetTimer * 2
	ld   a, [sActSetTimer]
	add  a						; each entry is 2bytes 
	ld   e, a
	ld   d, $00
	
	; Offset the Y offset table
	ld   hl, ActS_StunJumpYPath
	add  hl, de
	
	; Read the 16bit value to BC.
	; Move down by that amount.
	ldi  a, [hl]
	ld   c, a
	ld   b, [hl]
	call ActS_MoveDown
	ret
	
; =============== ActS_StunJumpYPath ===============
; Table of 16-bit Y offsets for the jump at the start and end of the stun anim.
ActS_StunJumpYPath: 
	dw -$03;X
	dw -$03
	dw -$03
	dw -$02
	dw -$02
	dw -$01
	dw -$01
	dw -$00
	dw +$00
	dw +$01
	dw +$01
	dw +$02
	dw +$02
	dw +$03
	dw +$03
.end:
	; [TCRF] The table is cut off early, leaving these values unused
	dw +$03
	dw +$00
	dw +$00
	;--
;--
; =============== ActS_Unused_StunBumpKill ===============
; [TCRF] Unreferenced stun actor code, seemingly related to ActS_StunBump.
;        This makes the actor bump in the opposite direction, then kills it
;        with a star effect.
ActS_Unused_StunBumpKill:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; If the actor is overlapping with a spike block, instakill it
	call ActColi_GetBlockId_Low
	call ActBGColi_IsSpikeBlock
	or   a
	jp   nz, ActS_StartStarKill
	
	; Animate every 4 global frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .moveH
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.moveH:          
	;
	; HORIZONTAL MOVEMENT
	;
		
	; Because this subroutine is meant for stunned actors,
	; it should stop moving horizontally when it goes underwater
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a							; Overlapping with a water block?
	call z, ActS_ClearInteractDir	; If so, clear int. direction
	; ...right before the horizontal movement checks
	
	ld   a, [sActSetRoutineId]
	bit  ACTINTB_L, a						; Interacted from the left side?
	call nz, ActS_Unused_StunBumpKill_MoveR	; If so, move right
	ld   a, [sActSetRoutineId]
	bit  ACTINTB_R, a						; Interacted from the right side?
	call nz, ActS_Unused_StunBumpKill_MoveL	; If so, move left
	
	;
	; VERTICAL MOVEMENT
	;
.chkMoveV:
	;
	; Determine which direction we should check for solid collision.
	; When moving down, we only want to check down.
	;
	ld   a, [sActSetYSpeed_High]
	bit  7, a						; Moving down? (HSpeed > 0)
	jr   z, .chkMoveD				; If so, check for ground collision
	
.chkMoveU:
	; Otherwise we're moving up, so check for ceiling collision.
	; If there's a solid block, don't move and just decrement the speed.
	; This goes on until the speed becomes negative, where it goes to .chkMoveD.
	; (This is a bit unusual -- normally the speed would be immediately reset to $00)
	call ActColi_GetBlockId_Top
	call ActBGColi_IsSolid
	or   a								; Solid block above?
	jr   nz, ActS_StunBump_IncDownSpeed	; If so, don't move
	; There's no way to go back underwater if we're moving up, so
	; we can skip the horribly broken underwater check.
	jr   ActS_StunBump_DoMoveVertNoWater ; Otherwise, move up
.chkMoveD:                 
	; If there's a solid block below, stop moving vertically
	call ActColi_GetBlockId_Ground
	call ActBGColi_IsSolidOnTop
	or   a								; Solid block below?
	jp   nz, ActS_Unused_StunBumpKill_OnLand ; If so, jump	
	; Otherwise handle the fall speed like ActS_StunBump
	
; =============== ActS_StunBump_DoMoveVert ===============
; Moves the player vertically during the jump arc when an actor is stunned from below.
ActS_StunBump_DoMoveVert:
	; If the actor is in a water block, move at a fixed 1px/frame speed
	
	; [BUG] Stunning actors underwater is completely broken.
	;  		All because ActS_SafeDropUnderwater is being used to update a word value as if it was a byte,
	;		and so ends up setting a broken YSpeed of $FF01.
	;
	;		Even though this is very much not correct, it isn't immediately a problem. As long as the actor is in a water block,
	;		the fall speed is an hardcoded 1px/frame that ignores the contents of the YSpeed value.
	;
	;       The problem is that the upper byte is never updated. 
	;		The collision detection code breaks since it relies on that MSB to know if collision should be checked above or below the actor.
	;		So the actor goes through the solid block until the collision above the actor is reported as solid.
	;		When that happens, the actor is no longer inside a water block, so the broken YSpeed value *does* get applied...
	;		...which promptly teleports the actor one screen above.
	;
	;		The correct way to fix this would be to make ActS_SafeDropUnderwater also set the high byte of YSpeed to $00.
	;		We don't need to care for other actors using the high byte of the Y speed for different purposes, since they
	;		have to go through initialization again anyway.
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a
	jp   z, ActS_SafeDropUnderwater
	
	; [TCRF] Label only used for unused code.
ActS_StunBump_DoMoveVertNoWater:
	; Otherwise move it at the speed specified in sActSetYSpeed
	ld   a, [sActSetYSpeed_Low]
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown
; =============== ActS_StunBump_IncDownSpeed ===============
; For skipping the above part, when it's not possible to move (upwards).
ActS_StunBump_IncDownSpeed:
	; Every 4 frames increase the downwards movement speed by 1
	ld   a, [sActSetTimer]
	and  a, $03						; sActSetTimer % 4 == 0?
	ret  nz							; If not, jump
	ld   a, [sActSetYSpeed_Low]	; sActSetYSpeed++
	add  $01						
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00						; account for carry
	ld   [sActSetYSpeed_High], a
	ret
	
; =============== ActS_Unused_StunBumpKill_* ===============
; [TCRF] Block of helper subroutines used by ActS_Unused_StunBumpKill.

; =============== ActS_Unused_StunBumpKill_MoveR ===============
ActS_Unused_StunBumpKill_MoveR:           
	; If there's a solid block in the way, stop moving
	call ActColi_GetBlockId_LowR
	call ActBGColi_IsSolid
	or   a
	jr   nz, ActS_Unused_StunBumpKill_StopHMove
	
	;
	; Heavy actors move at half the speed.
	;
	ld   a, [sActSetOpts]
	bit  ACTFLAGB_HEAVY, a	; Is actor heavy?
	jr   z, .fast			; If not, jump
.norm:
	ld   bc, +$01
	call ActS_MoveRight
	ret  
.fast:
	ld   bc, +$02
	call ActS_MoveRight
	ret  
	
; =============== ActS_Unused_StunBumpKill_StopHMove ===============
; Stops moving by clearing the horz. interaction dir. flags.
ActS_Unused_StunBumpKill_StopHMove:
	ld   a, [sActSetRoutineId]
	and  a, ACTINT_U|ACTINT_D|$0F
	ld   [sActSetRoutineId], a
	ret  
	
; =============== ActS_Unused_StunBumpKill_MoveL ===============
ActS_Unused_StunBumpKill_MoveL:
	; If there's a solid block in the way, stop moving
	call ActColi_GetBlockId_LowL
	call ActBGColi_IsSolid
	or   a
	jr   nz, ActS_Unused_StunBumpKill_StopHMove
	
	;
	; Heavy actors move at half the speed.
	;
	ld   a, [sActSetOpts]
	bit  ACTFLAGB_HEAVY, a	; Is actor heavy?
	jr   z, .fast			; If not, jump
.norm:
	ld   bc, -$01
	call ActS_MoveRight
	ret  
.fast:
	ld   bc, -$02
	call ActS_MoveRight
	ret
	
; =============== ActS_Unused_StunBumpKill_OnLand ===============
; Called when ActS_Unused_StunBumpKill lands on solid ground.
; It transitions to ActS_StunGroundMove, to make the actor slide on the ground.
ActS_Unused_StunBumpKill_OnLand:

	;---
	;
	; Get rid of the first bit of the option flags.
	; If it's already cleared, kill the actor (for almost every actor this is the case).
	;

	; [POI] This is the only place where the first bit is accounted for --
	;       and it's used to determine if the actor should instakill with a star effect.
	;      
	;       The check itself doesn't make it obvious, but keep in mind only the first bit
	;       of the lower nybble is ever set, so it means that:
	;       - Lower nybble 0    -> actor is marked as dead
	;       - Lower nybble != 0 -> the lower nybble is $1, and the actor isn't dead
	;
	ld   a, [sActSetOpts]		; B = ActFlags
	ld   b, a				
	and  a, $0F					; Lower nybble == 0?
	jp   z, ActS_StartStarKill	; If so, jump
	
	; As a result, decrementing that nybble by 1 clears that bit.
	; C = LOWN(ActFlags) - 1
	dec  a					
	ld   c, a
	; sActSetOpts = (ActFlags & $F0) | ((ActFlags & $0F) - 1) 
	ld   a, b				
	and  a, $F0
	or   c
	ld   [sActSetOpts], a
	;---
	
	; Set code ptr
	ld   bc, SubCall_ActS_StunGroundMove
	call ActS_SetCodePtr
	
	xor  a						
	ld   [sActSetTimer], a
	
	; Turn direction after landing (...but why?)
	; (for reference, ActS_StunGroundMove uses sActSetRoutineId in the same way as ActS_Unused_StunBumpKill)
	call ActS_Unused_StunBumpKill_Turn
	ret  
; =============== ActS_Unused_StunBumpKill_Turn ===============
; Turns the currently processed actor direction.
ActS_Unused_StunBumpKill_Turn:
	; Don't turn if we aren't moving horizontally
	ld   a, [sActSetRoutineId]		
	and  a, ACTINT_R|ACTINT_L		; Not interacted in any direction?
	ret  z							; If so, return
	; Otherwise, can turn
	ld   a, [sActSetRoutineId]
	xor  a, ACTINT_R|ACTINT_L		
	ld   [sActSetRoutineId], a
	ret
	
; =============== ActS_SwitchDir ===============
ActS_SwitchDir:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw ActS_SwitchDir_Main
	dw ActS_OnPlColiH
	dw ActS_OnPlColiTop
	dw ActS_StartStarKill;X
	dw ActS_OnPlColiBelow;X
	dw ActS_StartDashKill;X
	dw ActS_SwitchDir_Main;X
	dw ActS_SwitchDir_Main;X
	dw ActS_StartJumpDeadSameColi
; =============== ActS_SwitchDir_Main ===============
ActS_SwitchDir_Main:
	; If a ground pound is active, stun the actor
	ld   a, [sScreenShakeTimer]
	or   a
	jp   nz, ActS_StartGroundPoundStun
	
	; If overlapping with a spike block, instakill the actor
	call ActColi_GetBlockId_Low
	call ActBGColi_IsSpikeBlock
	or   a
	jp   nz, ActS_StartStarKill
	
	; Timer++
	ld   a, [sActSetTimer]
	inc  a
	ld   [sActSetTimer], a
	
	; If the actor is standing on a solid block, jump
	call ActColi_GetBlockId_Ground
	call ActBGColi_IsSolidOnTop
	or   a
	jr   nz, .stand
	
	; If in water, handle the underwater drop the usual way
	call ActColi_GetBlockId_Low
	call ActBGColi_IsEmptyWaterBlock
	or   a
	jp   z, ActS_SafeDropUnderwater
	
	; Otherwise, drop at an increasing vertical speed
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed_Low & $07
	and  a, $07							; (curiously we're limiting to 7)
	ld   c, a							
	ld   b, $00
	call ActS_MoveDown					; Move down by that
	; Every 4 frames increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, [sActSetYSpeed_Low]
	inc  a
	ld   [sActSetYSpeed_Low], a
	ret
.stand:
	; We're standing on a solid block, so clear any vertical speed
	xor  a
	ld   [sActSetYSpeed_Low], a
	
	ld   a, [sActSetTimer]
	cp   a, $14				; Did the timer reach $14 yet?
	jr   nc, .reload		; If so, reload the actor
	ret
.reload:
	; Align to block Y boundary in case the drop speed
	; put the actor partially into the ground
	ld   a, [sActSetY_Low]
	and  a, $F0
	ld   [sActSetY_Low], a
	; Setup reload to init code
	call ActS_ReloadInitial
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSetTimer7], a
	ret
; =============== ActS_DoStunRecover ===============
; Performs the jump effect when an actor recovers from a stun.
; This is shared between all types of stuns (ground pound and contact).
ActS_DoStunRecover:
	call ActS_IncOBJLstIdEvery8				
	; For $0F frames, do the jump effect through an Y offset table
	ld   a, [sActSetTimer]				; Index++
	inc  a
	ld   [sActSetTimer], a
	cp   a, (ActS_StunJumpYPath.end-ActS_StunJumpYPath)/2	; Reached $0F?
	jr   c, .jump												; If not, jump
	;--
	; If we got here, the jump is over
	
	; Restore the default collision type
	call ActS_RestoreColiType
	
	; Align actor to block Y boundary
	ld   a, [sActSetY_Low]
	and  a, $F0				
	ld   [sActSetY_Low], a
	
	; Setup reload to init code
	call ActS_ReloadInitial
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSetTimer7], a
	ret
.jump:
	; This works identically to the jump at the start of the stun in ActS_DoGroundPoundStun,
	; right down to the Y offset table used.
	
	; Create the offset
	; DE = sActSetTimer * 2
	ld   a, [sActSetTimer]
	add  a						; each entry is 2bytes 
	ld   e, a
	ld   d, $00
	
	; Offset the Y offset table
	ld   hl, ActS_StunJumpYPath
	add  hl, de
	
	; Read the 16bit value to BC.
	; Move down by that amount (which may be negative too, moving up).
	ldi  a, [hl]
	ld   c, a
	ld   b, [hl]
	call ActS_MoveDown
	ret
; =============== ActS_StunByLevelLayoutPtr ===============
; Triggers the stun routine for actors standing in the specified level layout block.
; This is used with a specifically created level layout ptr 
; to stun enemies when hitting the item box they are standing on.
;
; This is only checked for the 5 normal actor slots -- the 2 default slots don't get stunned.
ActS_StunByLevelLayoutPtr:
	; Is there a level layout ptr specified?
	ld   a, [sActStunLevelLayoutPtr_High]
	or   a
	ret  z	; If not, return
	
	; Loop between all 5 normal slots ($00-$04)
	ld   hl, sAct			; HL = Actor area
	xor  a
	ld   [sActStunBProc], a
.loop:
	; If the slot is empty (first byte $00), skip it
	ld   a, [hl]			
	or   a
	jr   z, .nextActor
	;--
	push hl
	; DE = ActorX
	inc  l
	ld   e, [hl]
	inc  l
	ld   d, [hl]
	; BC = ActorY + $08
	inc  l
	ld   c, [hl]
	inc  l
	ld   b, [hl]
	ld   hl, $0008	; += $08
	add  hl, bc
	ld   b, h		; copy back to BC
	ld   c, l
	
	; Get the level layout offset by dividing both X and Y coords by 16
	; then treating X as low byte and Y as high byte
	
	; L = ActorX / 16
	ld   a, e	; low byte >> 4
	and  a, $F0	
	swap a
	ld   l, a
	ld   a, d	; high byte << 4
	and  a, $0F	
	swap a
	or   a, l	; merge nybbles
	ld   l, a
	; H = ActorY / 16
	ld   a, c	; low byte >> 4
	and  a, $F0	
	swap a
	ld   h, a
	ld   a, b	; high byte << 4
	and  a, $0F	
	swap a
	or   a, h	; Merge nybbles
	
	; Get the level layout ptr by adding its base
	add  HIGH(wLevelLayout)
	ld   h, a
	ld   b, h
	ld   c, l
	
	pop  hl
	;--
	; Does it match with what we're searching for?
	ld   a, [sActStunLevelLayoutPtr_High]
	cp   a, b
	jr   nz, .nextActor
	ld   a, [sActStunLevelLayoutPtr_Low]
	cp   a, c
	jr   nz, .nextActor
	;--
	push hl
	; If the level layout matches, we can stun that actor.
	; Multiple stun routines exist, which have in common bit 2 being set.
	
	; Get the routine ID (byte $11)
	ld   bc, $0011
	add  hl, bc
	ld   a, [hl]
	and  a, $F0
	or   a, 1 << 2		; Mark the stun bit
	ld   [hl], a
	pop  hl
	;--
.nextActor:
	ld   a, [sActStunBProc]		; Actor++
	inc  a
	ld   [sActStunBProc], a
	
	cp   a, $05			; Did we finish handling the 5th slot (the last normal one)
	ret  nc				; If so, return
	
	ld   bc, $0020		; Otherwise point to the next actor slot
	add  hl, bc
	jr   .loop
	
; =============== START OF ACTOR SUBCALL TARGETS ===============
; Note that all of those pointing to this bank don't need to be subcalls.
SubCall_ActInit_SSTeacupBoss: mSubCallRet ActInit_SSTeacupBoss ; BANK $0F
IF FIX_BUGS == 1
SubCall_ActInit2_SSTeacupBoss: mSubCallRet ActInit2_SSTeacupBoss ; BANK $0F
ENDC
SubCall_Act_SSTeacupBoss: mSubCallRet Act_SSTeacupBoss ; BANK $0F
SubCall_ActInit_SSTeacupBossWatch: mSubCallRet ActInit_SSTeacupBossWatch ; BANK $18
SubCall_Act_SSTeacupBossWatch: mSubCallRet Act_SSTeacupBossWatch ; BANK $18
SubCall_ActInit_Watch: mSubCallRet ActInit_Watch ; BANK $18
SubCall_Act_Watch: mSubCallRet Act_Watch ; BANK $18
SubCall_ActInit_Helmut: mSubCallRet ActInit_Helmut ; BANK $0F
SubCall_Act_Helmut: mSubCallRet Act_Helmut ; BANK $0F
SubCall_ActInit_Goom: mSubCallRet ActInit_Goom ; BANK $0F
SubCall_Act_Goom: mSubCallRet Act_Goom ; BANK $0F
SubCall_ActInit_BigFruit: mSubCallRet ActInit_BigFruit ; BANK $12
SubCall_Act_BigFruit: mSubCallRet Act_BigFruit ; BANK $12
SubCall_Act_BigFruit_Unused_NoMove: mSubCallRet Act_BigFruit_Unused_NoMove ; BANK $12
SubCall_ActInit_SpikeBall: mSubCallRet ActInit_SpikeBall ; BANK $15
SubCall_Act_SpikeBall: mSubCallRet Act_SpikeBall ; BANK $15
SubCall_ActInit_Spark: mSubCallRet ActInit_Spark ; BANK $0F
SubCall_Act_Spark: mSubCallRet Act_Spark ; BANK $0F
SubCall_ActInit_SpearGoom: mSubCallRet ActInit_SpearGoom ; BANK $07
SubCall_Act_SpearGoom: mSubCallRet Act_SpearGoom ; BANK $07
SubCall_ActInit_PouncerDrop: mSubCallRet ActInit_PouncerDrop ; BANK $15
SubCall_Act_PouncerDrop: mSubCallRet Act_PouncerDrop ; BANK $15
SubCall_ActInit_PouncerFollow: mSubCallRet ActInit_PouncerFollow ; BANK $15
SubCall_Act_PouncerFollow: mSubCallRet Act_PouncerFollow ; BANK $15
SubCall_ActInit_Driller: mSubCallRet ActInit_Driller ; BANK $15
SubCall_Act_Driller: mSubCallRet Act_Driller ; BANK $15
SubCall_Act_DrillerDrop: mSubCallRet Act_DrillerDrop ; BANK $15
SubCall_ActInit_Puff: mSubCallRet ActInit_Puff ; BANK $0F
SubCall_Act_Puff: mSubCallRet Act_Puff ; BANK $0F
SubCall_ActInit_LavaBubble: mSubCallRet ActInit_LavaBubble ; BANK $0F
SubCall_Act_LavaBubble: mSubCallRet Act_LavaBubble ; BANK $0F
SubCall_ActInit_DoorFrame: mSubCallRet ActInit_DoorFrame ; BANK $15
SubCall_Act_DoorFrame: mSubCallRet Act_DoorFrame ; BANK $15
SubCall_ActInit_CoinLock: mSubCallRet ActInit_CoinLock ; BANK $15
SubCall_Act_CoinLock: mSubCallRet Act_CoinLock ; BANK $15
SubCall_ActInit_CartTrain: mSubCallRet ActInit_CartTrain ; BANK $15
SubCall_Act_CartTrain: mSubCallRet Act_CartTrain ; BANK $15
SubCall_ActInit_Cart: mSubCallRet ActInit_Cart ; BANK $15
SubCall_Act_Cart: mSubCallRet Act_Cart ; BANK $15
SubCall_ActInit_Wolf: mSubCallRet ActInit_Wolf ; BANK $15
SubCall_Act_Wolf: mSubCallRet Act_Wolf ; BANK $15
SubCall_ActInit_Penguin: mSubCallRet ActInit_Penguin ; BANK $15
SubCall_Act_Penguin: mSubCallRet Act_Penguin ; BANK $15
SubCall_ActInit_DD: mSubCallRet ActInit_DD ; BANK $15
SubCall_Act_DD: mSubCallRet Act_DD ; BANK $15
SubCall_Act_DDBoomerang: mSubCallRet Act_DDBoomerang ; BANK $15
SubCall_Act_WolfKnife: mSubCallRet Act_WolfKnife ; BANK $15
SubCall_Act_PenguinSpikeBall: mSubCallRet Act_PenguinSpikeBall ; BANK $15
SubCall_ActInit_ChickenDuck: mSubCallRet ActInit_ChickenDuck ; BANK $17
SubCall_Act_ChickenDuck: mSubCallRet Act_ChickenDuck ; BANK $17
SubCall_ActInit_MtTeapotBoss: mSubCallRet ActInit_MtTeapotBoss ; BANK $17
SubCall_Act_MtTeapotBoss: mSubCallRet Act_MtTeapotBoss ; BANK $17
SubCall_ActInit_SherbetLandBoss: mSubCallRet ActInit_SherbetLandBoss ; BANK $17
SubCall_Act_SherbetLandBoss: mSubCallRet Act_SherbetLandBoss ; BANK $17
SubCall_Act_SherbetLandBossHat: mSubCallRet Act_SherbetLandBossHat ; BANK $17
SubCall_ActInit_RiceBeachBoss: mSubCallRet ActInit_RiceBeachBoss ; BANK $18
SubCall_Act_RiceBeachBoss: mSubCallRet Act_RiceBeachBoss ; BANK $18
SubCall_ActInit_ParsleyWoodsBoss: mSubCallRet ActInit_ParsleyWoodsBoss ; BANK $18
SubCall_ActInit_ParsleyWoodsBossGhostGoom: mSubCallRet ActInit_ParsleyWoodsBossGhostGoom ; BANK $18
SubCall_Act_ParsleyWoodsBoss: mSubCallRet Act_ParsleyWoodsBoss ; BANK $18
SubCall_Act_ParsleyWoodsBossGhostGoom: mSubCallRet Act_ParsleyWoodsBossGhostGoom ; BANK $18
SubCall_ActInit_StoveCanyonBoss: mSubCallRet ActInit_StoveCanyonBoss ; BANK $18
IF FIX_BUGS == 1
SubCall_ActInit2_StoveCanyonBoss: mSubCallRet ActInit2_StoveCanyonBoss ; BANK $18
ENDC
SubCall_Act_StoveCanyonBoss: mSubCallRet Act_StoveCanyonBoss ; BANK $18
SubCall_ActInit_StoveCanyonBossTongue: mSubCallRet ActInit_StoveCanyonBossTongue ; BANK $18
SubCall_Act_StoveCanyonBossTongue: mSubCallRet Act_StoveCanyonBossTongue ; BANK $18
SubCall_ActInit_StoveCanyonBossEyes: mSubCallRet ActInit_StoveCanyonBossEyes ; BANK $18
SubCall_Act_StoveCanyonBossEyes: mSubCallRet Act_StoveCanyonBossEyes ; BANK $18
SubCall_ActInit_Unused_StoveCanyonBossBall: mSubCallRet ActInit_Unused_StoveCanyonBossBall ; BANK $18
SubCall_Act_StoveCanyonBossBall: mSubCallRet Act_StoveCanyonBossBall ; BANK $18
SubCall_ActInit_Floater: mSubCallRet ActInit_Floater ; BANK $18
SubCall_Act_Floater: mSubCallRet Act_Floater ; BANK $18
SubCall_Act_FloaterArrow: mSubCallRet Act_FloaterArrow ; BANK $18
SubCall_ActInit_KeyLock: mSubCallRet ActInit_KeyLock ; BANK $18
SubCall_Act_KeyLock: mSubCallRet Act_KeyLock ; BANK $18
SubCall_ActInit_Bridge: mSubCallRet ActInit_Bridge ; BANK $18
SubCall_Act_Bridge: mSubCallRet Act_Bridge ; BANK $18
SubCall_ActInit_Snowman: mSubCallRet ActInit_Snowman ; BANK $02
SubCall_Act_Snowman: mSubCallRet Act_Snowman ; BANK $02
SubCall_Act_SnowmanIce: mSubCallRet Act_SnowmanIce ; BANK $02
SubCall_ActInit_BigSwitchBlock: mSubCallRet ActInit_BigSwitchBlock ; BANK $02
SubCall_Act_BigSwitchBlock: mSubCallRet Act_BigSwitchBlock ; BANK $02
SubCall_ActInit_LavaWall: mSubCallRet ActInit_LavaWall ; BANK $02
SubCall_Act_LavaWall: mSubCallRet Act_LavaWall ; BANK $02
SubCall_ActInit_SyrupCastlePlatformU: mSubCallRet ActInit_SyrupCastlePlatformU ; BANK $02
SubCall_Act_SyrupCastlePlatformU: mSubCallRet Act_SyrupCastlePlatformU ; BANK $02
SubCall_ActInit_SyrupCastlePlatformD: mSubCallRet ActInit_SyrupCastlePlatformD ; BANK $02
SubCall_Act_SyrupCastlePlatformD: mSubCallRet Act_SyrupCastlePlatformD ; BANK $02
SubCall_ActInit_HermitCrab: mSubCallRet ActInit_HermitCrab ; BANK $02
SubCall_Act_HermitCrab: mSubCallRet Act_HermitCrab ; BANK $02
SubCall_ActInit_GhostGoom: mSubCallRet ActInit_GhostGoom ; BANK $02
SubCall_Act_GhostGoom: mSubCallRet Act_GhostGoom ; BANK $02
SubCall_ActInit_Seahorse: mSubCallRet ActInit_Seahorse ; BANK $02
SubCall_Act_Seahorse: mSubCallRet Act_Seahorse ; BANK $02
SubCall_ActInit_BigItemBox: mSubCallRet ActInit_BigItemBox ; BANK $02
SubCall_Act_BigItemBox: mSubCallRet Act_BigItemBox ; BANK $02
SubCall_ActInit_Bomb: mSubCallRet ActInit_Bomb ; BANK $02
; [TCRF] Unused, seemingly patched out.
SubCall_Unused_Act_Bomb_WaitExplode: mSubCallRet Act_Bomb_WaitExplode ; BANK $02
SubCall_Act_Bomb: mSubCallRet Act_Bomb ; BANK $02
SubCall_ActInit_SyrupCastleBoss: mSubCallRet ActInit_SyrupCastleBoss ; BANK $1B
SubCall_Act_SyrupCastleBoss: mSubCallRet Act_SyrupCastleBoss ; BANK $1B
SubCall_ActInit_Lamp: mSubCallRet ActInit_Lamp ; BANK $1B
SubCall_Act_Lamp: mSubCallRet Act_Lamp ; BANK $1B
SubCall_ActInit_LampSmoke: mSubCallRet ActInit_LampSmoke ; BANK $1B
SubCall_Act_LampSmoke: mSubCallRet Act_LampSmoke ; BANK $1B
SubCall_Act_SyrupCastleBossFireball: mSubCallRet Act_SyrupCastleBossFireball ; BANK $1B
; [TCRF] Unused subcall to unused init call
SubCall_ActInit_Unused_MiniGenie: mSubCallRet ActInit_Unused_MiniGenie ; BANK $1B
SubCall_Act_MiniGenie: mSubCallRet Act_MiniGenie ; BANK $1B
SubCall_Act_MiniGenieProjectile: mSubCallRet Act_MiniGenieProjectile ; BANK $1B
SubCall_ActInit_Pelican: mSubCallRet ActInit_Pelican ; BANK $1B
SubCall_Act_Pelican: mSubCallRet Act_Pelican ; BANK $1B
SubCall_ActInit_SpikePillarR: mSubCallRet ActInit_SpikePillarR ; BANK $15
SubCall_Act_SpikePillarR: mSubCallRet Act_SpikePillarR ; BANK $15
SubCall_ActInit_SpikePillarL: mSubCallRet ActInit_SpikePillarL ; BANK $15
SubCall_Act_SpikePillarL: mSubCallRet Act_SpikePillarL ; BANK $15
SubCall_ActInit_SpikePillarU: mSubCallRet ActInit_SpikePillarU ; BANK $15
SubCall_Act_SpikePillarU: mSubCallRet Act_SpikePillarU ; BANK $15
SubCall_ActInit_SpikePillarD: mSubCallRet ActInit_SpikePillarD ; BANK $15
SubCall_Act_SpikePillarD: mSubCallRet Act_SpikePillarD ; BANK $15
SubCall_ActInit_CoinCrab: mSubCallRet ActInit_CoinCrab ; BANK $15
SubCall_Act_CoinCrab: mSubCallRet Act_CoinCrab ; BANK $15
SubCall_ActInit_StoveCanyonPlatform: mSubCallRet ActInit_StoveCanyonPlatform ; BANK $1B
SubCall_Act_StoveCanyonPlatform: mSubCallRet Act_StoveCanyonPlatform ; BANK $1B
SubCall_ActInit_Togemaru: mSubCallRet ActInit_Togemaru ; BANK $1B
SubCall_Act_Togemaru: mSubCallRet Act_Togemaru ; BANK $1B
SubCall_ActInit_ThunderCloud: mSubCallRet ActInit_ThunderCloud ; BANK $15
SubCall_Act_ThunderCloud: mSubCallRet Act_ThunderCloud ; BANK $15
SubCall_Act_Thunder: mSubCallRet Act_Thunder ; BANK $15
SubCall_ActInit_Mole: mSubCallRet ActInit_Mole ; BANK $17
SubCall_Act_Mole: mSubCallRet Act_Mole ; BANK $17
; [TCRF] This actor is only spawned by Act_Mole, so this goes unused.
SubCall_ActInit_Unused_MoleSpike: mSubCallRet ActInit_Unused_MoleSpike ; BANK $17
SubCall_Act_MoleSpike: mSubCallRet Act_MoleSpike ; BANK $17
SubCall_ActInit_Croc: mSubCallRet ActInit_Croc ; BANK $1B
SubCall_Act_Croc: mSubCallRet Act_Croc ; BANK $1B
SubCall_ActInit_Seal: mSubCallRet ActInit_Seal ; BANK $0F
SubCall_Act_Seal: mSubCallRet Act_Seal ; BANK $0F
SubCall_Act_SealSpear: mSubCallRet Act_SealSpear ; BANK $0F
SubCall_ActInit_Spider: mSubCallRet ActInit_Spider ; BANK $1B
SubCall_Act_Spider: mSubCallRet Act_Spider ; BANK $1B
SubCall_ActInit_Hedgehog: mSubCallRet ActInit_Hedgehog ; BANK $15
SubCall_Act_Hedgehog: mSubCallRet Act_Hedgehog ; BANK $15
SubCall_ActInit_MoleCutscene: mSubCallRet ActInit_MoleCutscene ; BANK $17
SubCall_Act_MoleCutscene: mSubCallRet Act_MoleCutscene ; BANK $17
SubCall_ActInit_FireMissile: mSubCallRet ActInit_FireMissile ; BANK $1B
SubCall_Act_FireMissile: mSubCallRet Act_FireMissile ; BANK $1B
SubCall_ActInit_StickBomb: mSubCallRet ActInit_StickBomb ; BANK $18
SubCall_Act_StickBomb: mSubCallRet Act_StickBomb ; BANK $18
SubCall_ActInit_Knight: mSubCallRet ActInit_Knight ; BANK $17
SubCall_Act_Knight: mSubCallRet Act_Knight ; BANK $17
SubCall_ActInit_MiniBossLock: mSubCallRet ActInit_MiniBossLock ; BANK $17
SubCall_Act_MiniBossLock: mSubCallRet Act_MiniBossLock ; BANK $17
SubCall_ActInit_Fly: mSubCallRet ActInit_Fly ; BANK $02
SubCall_Act_Fly: mSubCallRet Act_Fly ; BANK $02
SubCall_ActInit_ExitSkull: mSubCallRet ActInit_ExitSkull ; BANK $02
SubCall_Act_ExitSkull: mSubCallRet Act_ExitSkull ; BANK $02
SubCall_ActInit_Bat: mSubCallRet ActInit_Bat ; BANK $12
SubCall_Act_Bat: mSubCallRet Act_Bat ; BANK $12
; =============== END OF ACTOR SUBCALL TARGETS ===============

; =============== ActInit_Snowman ===============
; See also: ActInit_Wolf
ActInit_Snowman:
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
	ld   bc, SubCall_Act_Snowman
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_Snowman_MoveL
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Snowman
	call ActS_SetOBJLstSharedTablePtr
	
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ld   a, DIR_L
	ld   [sActSetDir], a
	xor  a
	ld   [sActSnowmanTurnDelay], a
	ld   [sActSnowmanPostKickDelay], a
	ld   [sActLocalRoutineId], a
	ld   [sActSnowmanShootDelay], a
	ld   [sActSnowman_Unused_SpawnDelay], a
	mSubCall ActS_SaveColiType ; BANK $02
	ret
	
; [TCRF] Unused init anim.
OBJLstPtrTable_Unused_ActInit_Snowman:
	dw OBJLst_Act_Snowman_MoveL0;X
	dw $0000;X

; =============== Act_Snowman ===============
Act_Snowman:
	; If the actor is overlapping with a solid block, kill it
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolid
	or   a
	jp   nz, SubCall_ActS_StartJumpDead
	
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Snowman_Main
	dw .onPlColiH
	dw .onPlColiTop
	dw SubCall_ActS_StartStarKill
	dw SubCall_ActS_OnPlColiBelow
	dw SubCall_ActS_StartDashKill
	dw Act_Snowman_Move;X
	dw SubCall_ActS_StartSwitchDir;X
	dw SubCall_ActS_StartJumpDeadSameColi;X
	
; Since this counts as a heavy actor, make circling stars spawn when stunned
.onPlColiH:
	call SubCall_ActS_SpawnStunStar
	jp   SubCall_ActS_OnPlColiH
.onPlColiTop:
	call SubCall_ActS_SpawnStunStar
	jp   SubCall_ActS_OnPlColiTop
	
; =============== Act_Snowman_Main ===============
Act_Snowman_Main:
	; If the screen is shaking, stun the actor
	ld   a, [sScreenShakeTimer]
	or   a
	jp   nz, SubCall_ActS_StartGroundPoundStun
	
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_Snowman_Move
	dw Act_Snowman_Move;X ; [POI] Unused modes likely from copy/paste
	dw Act_Snowman_Move;X
	dw Act_Snowman_Shoot
	dw Act_Snowman_PostShoot
	
; =============== Act_Snowman_Move ===============
; Movement mode.
Act_Snowman_Move:
	; Check for the delay before the actor can move again
	ld   a, [sActSnowmanTurnDelay]
	or   a							
	jr   nz, Act_Snowman_WaitTurn	
	
	call ActS_IncOBJLstIdEvery8
	
	; Move depending on the actor's direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	call nz, Act_Snowman_MoveRight
	ld   a, [sActSetDir]
	bit  DIRB_L, a
	call nz, Act_Snowman_MoveLeft
	
	;--
	; [TCRF] Holdover from Act_Penguin_Walk, not even used here.
	ld   a, [sActSnowman_Unused_SpawnDelay]
	or   a							
	jr   z, .chkDelay			
	dec  a							
	ld   [sActSnowman_Unused_SpawnDelay], a
	;--
.chkDelay:
	; Handle cooldown timer for shooting ice
	ld   a, [sActSnowmanShootDelay]
	or   a							; Has the cooldown timer elapsed yet?
	jr   z, Act_Snowman_CheckPlPos	; If so, try to shoot ice
	dec  a							; Otherwise, decrement it
	ld   [sActSnowmanShootDelay], a
	ret
	
; =============== Act_Snowman_CheckPlPos ===============
Act_Snowman_CheckPlPos:
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
	jp   nc, Act_Snowman_StartShoot	; If so, jump
	ret
.chkRangeR:
	ld   a, d				; If so, jump
	cp   e					; Is ActX < PlX?
	jp   c, Act_Snowman_StartShoot	; If so, jump
	ret
	
; =============== Act_Snowman_WaitTurn ===============
; Turns the actor once the turn timer elapses.
; IN
; - A: Must be sActSnowmanTurnDelay.
Act_Snowman_WaitTurn:
	dec  a							; sActSnowmanTurnDelay--
	ld   [sActSnowmanTurnDelay], a	; Save back value
	or   a							; Did the timer elapse?
	ret  nz							; If not, return
	
	; Now we can turn.
	ld   a, [sActSetDir]			
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	
	; Depending on the new direction, set the animation.
	bit  DIRB_R, a				; Facing right now?
	jr   nz, .dirR				; If so, jump
.dirL:
	push bc
	ld   bc, OBJLstPtrTable_Act_Snowman_MoveL
	call ActS_SetOBJLstPtr
	pop  bc
	; Not necessary
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
.dirR:
	push bc
	ld   bc, OBJLstPtrTable_Act_Snowman_MoveR
	call ActS_SetOBJLstPtr
	pop  bc
	; Not necessary
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_Snowman_SetTurnDelay ===============
; Makes the actor delay for $14 frames before turning.
Act_Snowman_SetTurnDelay:
	ld   a, $14
	ld   [sActSnowmanTurnDelay], a
	ret
	
; =============== Act_Snowman_MoveLeft ===============
Act_Snowman_MoveLeft:
	; If there's a solid block on the left, turn right
	call ActColi_GetBlockId_LowL
IF FIX_BUGS == 1
	mSubCall ActBGColi_IsSolid
ELSE
	mSubCall ActBGColi_IsSolidOnTop ; [BUG] Should be ActBGColi_IsSolid
ENDC
	or   a
	jr   nz, Act_Snowman_SetTurnDelay
	
	; If there's no ground on the left, turn right
	call ActColi_GetBlockId_BottomL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, Act_Snowman_SetTurnDelay
	
	; Otherwise, continue moving left
	ld   a, LOW(OBJLstPtrTable_Act_Snowman_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Snowman_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	ld   a, [sActSetDir]
	and  a, $F0|DIR_D
	or   a, DIR_L
	ld   [sActSetDir], a
	
	; Move left 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveRight
	ret

; =============== Act_Snowman_MoveRight ===============
Act_Snowman_MoveRight:
	; If there's a solid block on the right, turn left
	call ActColi_GetBlockId_LowR
IF FIX_BUGS == 1
	mSubCall ActBGColi_IsSolid
ELSE
	mSubCall ActBGColi_IsSolidOnTop ; [BUG] Should be ActBGColi_IsSolid
ENDC
	or   a
	jr   nz, Act_Snowman_SetTurnDelay
	
	; If there's no ground on the right, turn left
	call ActColi_GetBlockId_BottomR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   z, Act_Snowman_SetTurnDelay
	
	; Otherwise, continue moving right
	ld   a, LOW(OBJLstPtrTable_Act_Snowman_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Snowman_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	ld   a, [sActSetDir]
	and  a, $F0|DIR_D
	or   a, DIR_R
	ld   [sActSetDir], a
	
	; Move right 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveRight
	ret
	
; =============== Act_Snowman_StartShoot ===============
; This subroutine switches to mode SNOW_RTN_SHOOT.	
Act_Snowman_StartShoot:
	ld   a, SFX1_28			; Play shoot SFX
	ld   [sSFX1Set], a
	
	call Act_Snowman_SpawnIce	; Spawn the projectile immediately
	
	ld   a, SNOW_RTN_SHOOT
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSnowmanTurnDelay], a
	ld   [sActSnowmanPostKickDelay], a
	
	; Pick a different animation depending on the direction faced.
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Is the actor facing right?
	jr   nz, .dirR			; If so, jump
.dirL:
	push bc
	ld   bc, OBJLstPtrTable_Act_Snowman_ShootL
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.dirR:
	push bc
	ld   bc, OBJLstPtrTable_Act_Snowman_ShootR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_Snowman_Shoot ===============
; Plays the shoot animation.
Act_Snowman_Shoot:
	; [BUG] / [TCRF] The animation is being interrupted early.
	; This value cuts out an extra frame.
	ld   a, [sActSetOBJLstId]
IF FIX_BUGS == 1
	cp   a, $05					; Is the anim. over yet? (or rather, "is this the last valid sprite id?")
ELSE
	cp   a, $03					; Is the anim. over yet?
ENDC
	jr   nc, .endMode			; If so, jump
	call ActS_IncOBJLstIdEvery8
	ret
.endMode:
	ld   a, SNOW_RTN_POSTSHOOT
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActSnowmanTurnDelay], a
	ld   [sActSnowmanPostKickDelay], a
	; Not necessary
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_Snowman_PostShoot ===============
; Waits for a bit before starting to move again.
Act_Snowman_PostShoot:
	; Wait for $14 frames before moving again
	ld   a, [sActSnowmanPostKickDelay]
	cp   a, $46							; Timer reached the target value?
	jr   nc, Act_Snowman_SetShootDelay	; If so, return
	inc  a
	ld   [sActSnowmanPostKickDelay], a
	
	; Pick the correct anim depending on the direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a				; Facing right?
	jr   nz, .dirR				; If so, jump
.dirL:
	push bc
	ld   bc, OBJLstPtrTable_Act_Snowman_PostShootL
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.dirR:
	push bc
	ld   bc, OBJLstPtrTable_Act_Snowman_PostShootR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_Snowman_SetShootDelay ===============
; Makes the actor stop shooting for $32 frames after starting to move.
Act_Snowman_SetShootDelay:
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActSnowmanTurnDelay], a
	ld   [sActSnowmanPostKickDelay], a
	ld   a, $32
	ld   [sActSnowmanShootDelay], a
	ret
	
; =============== ActInit_Unused_SnowmanIce ===============
; [TCRF] Unreferenced init code for the projectile -- not necessary.
ActInit_Unused_SnowmanIce:
	; Setup collision box
	ld   a, -$06
	ld   [sActSetColiBoxU], a
	ld   a, -$02
	ld   [sActSetColiBoxD], a
	ld   a, -$03
	ld   [sActSetColiBoxL], a
	ld   a, +$03
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_SnowmanIce
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_SnowmanIce
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_SnowmanIce
	call ActS_SetOBJLstSharedTablePtr
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSetTimer2], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer6], a
	ld   [sActSetTimer7], a
	ret  
	
; =============== Act_SnowmanIce ===============
Act_SnowmanIce:
	; Permadespawn once it goes off-screen
	; Again, could have spawned with ACTFLAG_UNUSED_FREEOFFSCREEN
	call ActS_CheckOffScreen	; Update offscreen status
	ld   a, [sActSet]
	cp   a, $02					; Is it visible & active?
	jr   nc, .main				; If so, jump
	xor  a						; Otherwise, free the slot
	ld   [sActSet], a
	ret
.main:
	ld   a, LOW(OBJLstPtrTable_Act_SnowmanIce)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SnowmanIce)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	call ActS_IncOBJLstIdEvery8
	
	;
	; VERTICAL MOVEMENT
	;
.moveV:
	; Always handle drop speed
	ld   a, [sActSetYSpeed_Low]		; BC = Y Speed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown					; Move down by that
	
	;--
	; Check if we should reset the drop speed
	ld   a, [sActSetYSpeed_High]
	bit  7, a							; Is the actor moving up? (not necessary to check)
	jr   nz, .incDropSpeed				; If so, jump
	
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is the actor standing on a solid block?
	jr   z, .incDropSpeed				; If not, jump
	;--
	
	; Otherwise, reset the drop speed.
	mActSetYSpeed $00
	jr   .moveH
.incDropSpeed:

	; Every 4 frames, increase the drop speed.
	ld   a, [sActSetTimer]
	and  a, $03
	jr   nz, .moveH
	ld   a, [sActSetYSpeed_Low]
	add  $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00
	ld   [sActSetYSpeed_High], a
	
	;
	; HORIZONTAL MOVEMENT
	;
.moveH:
	ld   a, [sActSetDir]
	bit  DIRB_R, a						; Facing right?
	jr   nz, .dirR						; If so, jump
.dirL:
	ld   bc, -$01
	call ActS_MoveRight
	
	ld   a, LOW(OBJLstPtrTable_Act_SnowmanIce)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SnowmanIce)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; If there's a solid block on the left, kill the actor with a jump effect
	; (without awarding hearts, since this is a projectile)
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolid
	or   a
	jp   nz, SubCall_ActS_StartJumpDead_NoHeart
	
	ret
	
.dirR:
	ld   bc, +$01
	call ActS_MoveRight
	ld   a, LOW(OBJLstPtrTable_Act_SnowmanIce)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SnowmanIce)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; If there's a solid block on the right, kill the actor with a jump effect
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a
	jp   nz, SubCall_ActS_StartJumpDead_NoHeart
	ret
	
; =============== Act_Snowman_SpawnIce ===============
Act_Snowman_SpawnIce:
	; Find an empty slot
	ld   hl, sAct			; HL = Actor slot area
	ld   d, $05				; D = Slots count (normal slots)
	ld   e, $00				; E = Current slot
	ld   c, $00				; C = Existing Act_SnowmanIce actors
.checkSlot:
	ld   a, [hl]		; Read active status
	or   a				; Is the slot marked as active?
	jr   z, .slotFound	; If not, we found a slot
.checkCode:
	; Check if a projectile was already spawned, to enforce a limit of 2 projectiles on screen.
	; This would be done by checking if the actor's code ptr points to the location of Act_SnowmanIce.

	; [BUG] Except it doesn't work, since it's pointing to the wrong address. (off by one)
	;       It should have used sActSetCodePtr, but it's using sActSetRoutineId instead.
	;       The location of SubCall_Act_SnowmanIce is at $59CB, which causes the broken check to 
	;       always fail since sActSetRoutineId can't ever be $CB.
	
	ld   a, l							; Seek to (what should have been) code ptr
IF FIX_BUGS == 1
	add  (sActSetCodePtr-sActSet)	
ELSE
	add  (sActSetRoutineId-sActSet)	
ENDC
	ld   l, a
	
	; Only compare with the low byte to save time
	ld   a, [hl]		; Read value
	cp   a, LOW(SubCall_Act_SnowmanIce); Does the low byte match?
	jr   nz, .nextSlot	; If not, skip
.unused_incActCount:
	;--
	; We can't get here
	inc  c				; IceCount++
	ld   a, c           
	cp   a, $02			; Have we reached the limit of 2 projectiles at once?
	ret  nc				; If so, don't spawn it
	;--
.nextSlot:
	inc  e                  ; Slot++
	dec  d					; Have we searched in all 5 slots?
	ret  z					; If so, return
	ld   a, l				; If not, move to the next actor slot
IF FIX_BUGS == 1
	add  (sActSet_End-sActSet) - (sActSetCodePtr-sActSet)
ELSE
	add  (sActSet_End-sActSet) - (sActSetRoutineId-sActSet)
ENDC
	ld   l, a
	jr   .checkSlot
	
.slotFound:
	mActS_SetOBJBank OBJLstSharedPtrTable_Act_SnowmanIce
	
	ld   a, $02				; Enabled
	ldi  [hl], a
	ld   a, [sActSetX_Low]	; X
	ldi  [hl], a
	ld   a, [sActSetX_High]
	ldi  [hl], a
	ld   a, [sActSetY_Low]	; Y
	ldi  [hl], a
	ld   a, [sActSetY_High]
	ldi  [hl], a
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI		; Collision type		
	ldi  [hl], a
	ld   a, -$06		; Coli box U
	ldi  [hl], a
	ld   a, -$02		; Coli box D
	ldi  [hl], a
	ld   a, -$03		; Coli box L
	ldi  [hl], a
	ld   a, +$03		; Coli box R
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
	set  ACTB_NORESPAWN, a		; Don't respawn this actor
	ldi  [hl], a
	
	xor  a						; Routine ID
	ldi  [hl], a
	
	ld   a, LOW(SubCall_Act_SnowmanIce)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_Act_SnowmanIce)
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a				; Timer
	ldi  [hl], a				; Timer 2
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
	
	ld   a, LOW(OBJLstSharedPtrTable_Act_SnowmanIce)
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_SnowmanIce)
	ld   [hl], a
	ret
	
OBJLstSharedPtrTable_Act_Snowman:
	dw OBJLstPtrTable_Act_Snowman_StunL;X
	dw OBJLstPtrTable_Act_Snowman_StunR;X
	dw OBJLstPtrTable_Act_Snowman_StunL
	dw OBJLstPtrTable_Act_Snowman_StunR
	dw OBJLstPtrTable_Act_Snowman_StunL
	dw OBJLstPtrTable_Act_Snowman_StunR
	dw OBJLstPtrTable_Act_Snowman_StunL;X
	dw OBJLstPtrTable_Act_Snowman_StunR;X

OBJLstSharedPtrTable_Act_SnowmanIce:
	dw OBJLstPtrTable_Act_SnowmanIce;X
	dw OBJLstPtrTable_Act_SnowmanIce;X
	dw OBJLstPtrTable_Act_SnowmanIce;X
	dw OBJLstPtrTable_Act_SnowmanIce;X
	dw OBJLstPtrTable_Act_SnowmanIce
	dw OBJLstPtrTable_Act_SnowmanIce
	dw OBJLstPtrTable_Act_SnowmanIce;X
	dw OBJLstPtrTable_Act_SnowmanIce;X

OBJLstPtrTable_Act_Snowman_MoveL:
	dw OBJLst_Act_Snowman_MoveL0
	dw OBJLst_Act_Snowman_MoveL1
	dw OBJLst_Act_Snowman_MoveL0
	dw OBJLst_Act_Snowman_MoveL2
	dw $0000
OBJLstPtrTable_Act_Snowman_MoveR:
	dw OBJLst_Act_Snowman_MoveR0
	dw OBJLst_Act_Snowman_MoveR1
	dw OBJLst_Act_Snowman_MoveR0
	dw OBJLst_Act_Snowman_MoveR2
	dw $0000
OBJLstPtrTable_Act_Snowman_StunL:
	dw OBJLst_Act_Snowman_StunL
	dw $0000
OBJLstPtrTable_Act_Snowman_StunR:
	dw OBJLst_Act_Snowman_StunR
	dw $0000
	
; [TCRF] The last frame is cut off, and points to otherwise unused graphics.
OBJLstPtrTable_Act_Snowman_ShootL:
	dw OBJLst_Act_Snowman_MoveL0
	dw OBJLst_Act_Snowman_ShootL0
	dw OBJLst_Act_Snowman_ShootL1
	dw OBJLst_Act_Snowman_ShootL1
	dw OBJLst_Act_Snowman_Unused_ShootL2;X
	dw OBJLst_Act_Snowman_Unused_ShootL2;X
	dw $0000;X
OBJLstPtrTable_Act_Snowman_ShootR:
	dw OBJLst_Act_Snowman_MoveR0
	dw OBJLst_Act_Snowman_ShootR0
	dw OBJLst_Act_Snowman_ShootR1
	dw OBJLst_Act_Snowman_ShootR1
	dw OBJLst_Act_Snowman_Unused_ShootR2;X
	dw OBJLst_Act_Snowman_Unused_ShootR2;X
	dw $0000;X
OBJLstPtrTable_Act_Snowman_PostShootL:
	dw OBJLst_Act_Snowman_MoveL0
	dw $0000;X
OBJLstPtrTable_Act_Snowman_PostShootR:
	dw OBJLst_Act_Snowman_MoveR0
	dw $0000;X
OBJLstPtrTable_Act_SnowmanIce:
	dw OBJLst_Act_SnowmanIce0
	dw OBJLst_Act_SnowmanIce1
	dw $0000

OBJLst_Act_Snowman_MoveL0: INCBIN "data/objlst/actor/snowman_movel0.bin"
OBJLst_Act_Snowman_ShootL0: INCBIN "data/objlst/actor/snowman_shootl0.bin"
OBJLst_Act_Snowman_ShootL1: INCBIN "data/objlst/actor/snowman_shootl1.bin"
OBJLst_Act_Snowman_Unused_ShootL2: INCBIN "data/objlst/actor/snowman_unused_shootl2.bin"
OBJLst_Act_SnowmanIce0: INCBIN "data/objlst/actor/snowmanice0.bin"
OBJLst_Act_SnowmanIce1: INCBIN "data/objlst/actor/snowmanice1.bin"
OBJLst_Act_Snowman_MoveL1: INCBIN "data/objlst/actor/snowman_movel1.bin"
OBJLst_Act_Snowman_MoveL2: INCBIN "data/objlst/actor/snowman_movel2.bin"
OBJLst_Act_Snowman_StunL: INCBIN "data/objlst/actor/snowman_stunl.bin"
OBJLst_Act_Snowman_MoveR0: INCBIN "data/objlst/actor/snowman_mover0.bin"
OBJLst_Act_Snowman_ShootR0: INCBIN "data/objlst/actor/snowman_shootr0.bin"
OBJLst_Act_Snowman_ShootR1: INCBIN "data/objlst/actor/snowman_shootr1.bin"
OBJLst_Act_Snowman_Unused_ShootR2: INCBIN "data/objlst/actor/snowman_unused_shootr2.bin"
; [TCRF] Look the same as OBJLst_Act_SnowmanIce0 and OBJLst_Act_SnowmanIce1, but aren't identical.
;        Seemingly meant for a right-facing projectile, given the context.
OBJLst_Act_SnowmanIce_Unused0: INCBIN "data/objlst/actor/snowmanice_unused0.bin"
OBJLst_Act_SnowmanIce_Unused1: INCBIN "data/objlst/actor/snowmanice_unused1.bin"
OBJLst_Act_Snowman_MoveR1: INCBIN "data/objlst/actor/snowman_mover1.bin"
OBJLst_Act_Snowman_MoveR2: INCBIN "data/objlst/actor/snowman_mover2.bin"
OBJLst_Act_Snowman_StunR: INCBIN "data/objlst/actor/snowman_stunr.bin"
GFX_Act_Snowman: INCBIN "data/gfx/actor/snowman.bin"

; =============== ActInit_BigSwitchBlock ===============
ActInit_BigSwitchBlock:
	; Setup collision box
	ld   a, $E0
	ld   [sActSetColiBoxU], a
	ld   a, $00
	ld   [sActSetColiBoxD], a
	ld   a, $F0
	ld   [sActSetColiBoxL], a
	ld   a, $10
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_BigSwitchBlock
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_BigSwitchBlock_Idle
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_BigSwitchBlock
	call ActS_SetOBJLstSharedTablePtr
	
	ld   a, ACTCOLI_BIGBLOCK
	ld   [sActSetColiType], a
	xor  a
	ld   [sActLocalRoutineId], a
	ret
	
OBJLstPtrTable_Act_BigSwitchBlock_Idle:
	dw OBJLst_Act_BigSwitchBlock_Idle
	dw $0000;X
OBJLstPtrTable_Act_BigSwitchBlock_Hit:
	dw OBJLst_Act_BigSwitchBlock_Hit
	dw $0000;X

; =============== Act_BigSwitchBlock ===============
Act_BigSwitchBlock:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_BigSwitchBlock_Idle
	dw Act_BigSwitchBlock_Stun
	dw Act_BigSwitchBlock_Alert
	
; =============== Act_BigSwitchBlock_Idle ===============
; Waits for the player to activate the block.
Act_BigSwitchBlock_Idle:
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_04			; Did we hit the block from below?
	ret  nz						; If not, ignore
	
	; Activate the block now
	xor  a
	ld   [sActSetColiType], a
	ld   a, BIGSW_RTN_HIT
	ld   [sActLocalRoutineId], a
	
	push bc						; Set while block effect
	ld   bc, OBJLstPtrTable_Act_BigSwitchBlock_Hit				
	call ActS_SetOBJLstPtr
	pop  bc
	
	xor  a
	ld   [sActModeTimer], a
	ld   a, SFX4_02	; Trigger screen shake with appropriate sfx
	ld   [sSFX4Set], a
	ld   a, $04
	ld   [sScreenShakeTimer], a
	ret
	
; =============== Act_BigSwitchBlock_Stun ===============
Act_BigSwitchBlock_Stun:
	;--
	; Handle the mode timer...
	ld   a, [sActModeTimer]
	cp   a, $08
	jr   nc, .endMode
	inc  a
	ld   [sActModeTimer], a
	;--
	
	; ...which also doubles as index for a movement table.
	; Move the block upwards for a bit, similar to what's done for normal blocks.
	;
	; Difference being, that we're already an actor here, so we can move it
	; right away without spawning any ExAct.
	
	ld   hl, .YPath	; HL = Table
	ld   d, $00			; DE = sActModeTimer
	ld   e, a
	add  hl, de			; Offset it
	
	; Get the value and (incomplete) sign-extend the other.
	; [POI] Shortcut: incomplete sign extension, see also Act_Watch_Idle.
	ld   a, [hl]		; C = Y Speed
	ld   c, a
REPT 5					; Sign extend to B
	sra  a
ENDR
	ld   b, a
	call ActS_MoveDown	; And move actor down by BC
	ret
	
.YPath:
	db $00 ; Not used, blank
	db -$06,-$04,-$03,-$02
	db +$02,+$03,+$04,+$06
	
.endMode:
	ld   a, BIGSW_RTN_POSTHIT		
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActModeTimer], a
	push bc
	ld   bc, OBJLstPtrTable_Act_BigSwitchBlock_Idle
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_BigSwitchBlock_Alert ===============
Act_BigSwitchBlock_Alert:
	; Wait for $1E frames before ending the level
	ld   a, [sActModeTimer]
	inc  a
	ld   [sActModeTimer], a
	ld   a, [sActModeTimer]
	cp   a, $1E
	ret  c
	
	ld   a, LVLCLEAR_BIGSWITCH		; Use non-door exit type
	ld   [sLvlSpecClear], a
	ret
	
OBJLstSharedPtrTable_Act_BigSwitchBlock:
	dw OBJLstPtrTable_Act_BigSwitchBlock_Idle;X
	dw OBJLstPtrTable_Act_BigSwitchBlock_Idle;X
	dw OBJLstPtrTable_Act_BigSwitchBlock_Idle;X
	dw OBJLstPtrTable_Act_BigSwitchBlock_Idle;X
	dw OBJLstPtrTable_Act_BigSwitchBlock_Idle;X
	dw OBJLstPtrTable_Act_BigSwitchBlock_Idle;X
	dw OBJLstPtrTable_Act_BigSwitchBlock_Idle;X
	dw OBJLstPtrTable_Act_BigSwitchBlock_Idle;X

OBJLst_Act_BigSwitchBlock_Idle: INCBIN "data/objlst/actor/bigswitchblock_idle.bin"
OBJLst_Act_BigSwitchBlock_Hit: INCBIN "data/objlst/actor/bigswitchblock_hit.bin"
GFX_Act_BigSwitchBlock: INCBIN "data/gfx/actor/bigswitchblock.bin"

; =============== ActInit_LavaWall ===============
; Lava block generator in C20
ActInit_LavaWall:
	; Setup collision box
	ld   a, -$70				; Must cover the entire scroll segment (and more)
	ld   [sActSetColiBoxU], a
	ld   a, -$00
	ld   [sActSetColiBoxD], a
	ld   a, -$10
	ld   [sActSetColiBoxL], a
	ld   a, -$08				; Negative right border! This has to be accounted for.
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_LavaWall
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_LavaWall
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_LavaWall
	call ActS_SetOBJLstSharedTablePtr
	
	xor  a						
	ld   [sActSetColiType], a
	
	xor  a
	ld   [sActLavaWallTileIdU], a
	ld   [sActLavaWallTileIdD], a
	ld   [sActSetTimer], a
	ld   [sActSetYSpeed_Low], a
	ret
	
OBJLstSharedPtrTable_Act_LavaWall:
	dw $0000
	
; =============== Act_LavaWall ===============
Act_LavaWall:
	; To save time, set the actor's collision only if it's on-screen.
	;
	; While the actor creates lava blocks, we generally don't collide with them.
	; We collide with the lava wall actor, which kills the player on touch.
	; This is done for two reasons:
	; - We don't want to wait for the lava block being placed.
	; - No collision detection is checked when standing still or when dashing,
	;   leading to glitchy effects with the player stand inside lava.
	
	xor  a						; Intangible by default
	ld   [sActSetColiType], a
	ld   a, [sActSet]
	cp   a, $02					; Is the actor not visible? (< $02)
	jr   c, Act_LavaWall_Main				; If so, skip
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_LavaWall_Main
	dw .onTouch;X
	dw .onTouch;X
	dw Act_LavaWall_Main;X
	dw .onTouch;X
	dw .onTouch;X
	dw .onTouch;X
	dw .onTouch;X
	dw Act_LavaWall_Main
.onTouch:
	call Pl_StartDeathAnim
	
; =============== Act_LavaWall_Main ===============
; Handles the lava wall effect.
;
; To save OAM space, this actor has to be very small.
; The smallest we can get is by having a high wall of 8x8 sprites.
;
; As soon as the actor becomes aligned to the 8x8 grid, we write the 8x8 tile for a lava block
; to what would be its current location in the tilemap, as well as replacing the 16x16 block.
; This is done to a column of 8 blocks (almost the entire height of a segscrl) to make 
; the lava wall look continuous while using the least amount of sprites.
Act_LavaWall_Main:
	; Animate every $10 frames
	ld   a, [sTimer]
	and  a, $0F
	jr   nz, .incTimer
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
.incTimer:

	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Move right 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveRight
	
	; Spawn the lava block only if the actor is aligned to the 8x8 grid.
	; This is being done when aligned to the 8x8 grid instead of the 16x16 grid,
	; to cater to the tilemap update routine, which is also being done.
	ld   a, [sActSetX_Low]
	ld   e, a				
	and  a, $07					; ActX % 8 == 0? (Aligned to the 8x8 grid?)
	ret  nz						; If not, return
	
	
	; Get the level layout ptr for the actor's current block location.
	; The "current block location" is offset to a certain amount in order to
	; pick the lowest point in the lava block spawn should be applied to.
	
	
	; X OFFSET
	; Because this actor uses a negative right border for the collision box,
	; we can't use its X location directly, otherwise we'd spawn a block to
	; the right of the generator.
	; Offset it by -$08, to account for the aforemented sActSetColiBoxR being set to -$08.
	ld   a, e					; DE = ActX - $08
	sub  a, $08
	ld   e, a
	ld   a, [sActSetX_High]
	sbc  a, $00
	ld   d, a
	
	; Y OFFSET
	ld   a, [sActSetY_Low]		; BC = ActY - $0F
	sub  a, $0F					; (1 block above)
	ld   c, a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ld   b, a
	
	mActColi_GetBlockId_GetLevelLayoutPtr	; HL = Level layout Get block 
	
	;--
	; Determine the set of tile IDs to use.
	; The lava block uses different tile IDs for the upper and lower halves of the 16x16 block.
	; These are also switched around for the left and right sides of the block.
	;	
	; These tile IDs are hardcoded to point to where the lava tiles are in the first room of C20,
	; which is part of the animated tiles.
	;
	; The configuration is this, using the same config as LevelBlock_Lava:
	; $22,$23
	; $23,$22
	;
	
	ld   a, [sActSetX_Low]
	bit  3, a				; Are we writing to the left side?
	jr   nz, .tileL			; If so, jump
.tileR:
	ld   a, $23
	ld   [sActLavaWallTileIdU], a
	ld   a, $22
	ld   [sActLavaWallTileIdD], a
	jr   Act_LavaWall_SetBlocks
.tileL:
	ld   a, $22
	ld   [sActLavaWallTileIdU], a
	ld   a, $23
	ld   [sActLavaWallTileIdD], a
	;--
	
; =============== Act_LavaWall_SetBlocks ===============
; This part of the subroutine loops over the level layout blocks in the column,
; converting them to lava blocks, and updating the tilemap if necessary.
Act_LavaWall_SetBlocks:

	; The column of blocks to apply the effect is 8 blocks high.
	ld   a, $08					; Convert 8 rows to lava
	ld   [sActSetTimer2], a
	
	;--
	; What this "inc h" does is move the initial position for the effect 1 block below.
	;
	; As for why it's here to begin with, it seems to be specifically made for C20,
	; which is the only place this actor's used.
	; In C20, the actor is placed two block above the bottom edge of the level. This is aligned to
	; the ground for most of the stage, but it also needs to cover the block below
	; when terrain dips down (hence, moving down 1 block).
	; This isn't increased twice because all blocks in the lowest row are already solid
	; or lava, so we don't need to run the effect on them.
	;
	; They could have simply moved the actor's position instead of doing this...
	
	inc  h						; Row++
	;--
.loop:

	; Convert the level block to a lava block.
	; For a better effect and to save time, solid blocks are ignored during this.
	ld   a, [hl]				; Read block ID from level layout
	and  a, $7F					; Remove actor flag
	push hl
	mSubCall ActBGColi_IsSolid
	pop  hl
	or   a						; Is it a solid block?
	jr   nz, .nextBlock			; If so, skip this

	ld   a, BLOCKID_INSTAKILL	; Otherwise, replace it with a lava block
	ld   [hl], a				; and write it back to the level layout
	
	; Since replacing an on-screen block doesn't redraw it, we have to do that manually.
	; If the actor is visible, update the *two* 8x8 blocks at the same location as the lava wall.
	
	; What we need here is making the lava wall look continuous while using the least amount of sprites.
	; The lava wall uses small 8x8 sprites aligned in a column.
	; As soon as the OBJ become aligned to the 8x8 grid, we write the 8x8 tile for a lava block
	; immediately on the tile to the left.
	
	ld   a, [sActSet]
	cp   a, $02					; Is the actor visible?
	jr   c, .nextBlock			; If not, skip
	
	;##
	push hl						; Save level layout ptr for later
	
	; Calculate the initial offset of the block.
	; This points to the upper-left 8x8 tile of the block.
	call GetBGMapOffsetFromBlock	; HL = Tilemap ptr for start of 16x16 block
	
	; Determine the offset for the tilemap ptr (for picking the left or right side of a 16x16 block).
	; We're always picking the 8x8 tile to the left of the actor, so:
	; - If the actor is at the start of a 16x16 boundary, the previous 8x8 tile is the upper-right
	;   tile of the block. (add $01 offset from upper-left tile)
	; - Otherwise, it's at the start of the 8x8 boundary in the middle of a block.
	;   The previous 8x8 tile is the upper-left tile of the same block. (no offset)
	;
	; XOffset -> BlockOffset
	; $08     -> $00
	; $00     -> $01
	; This is basically the result of inverting the 4th bit, so:
	; Offset = ^(ActX / 8)
	
	ld   a, [sActSetX_Low]
	and  a, $08						; Align to 8x8 block
	xor  $08						; Invert bit 3 since we're looking at the previous tile
	rrca							; and move it down to bit 0
	rrca
	rrca
	ld   e, a						; DE = Offset
	ld   d, $00
	add  hl, de						; And add it over
	
	;--
	;
	; Update the 2 tile IDs for the block.
	;
	ld   de, BG_TILECOUNT_H			; DE = Block IDs to add for moving down 1 tile down in the tilemap
	
	
	; TILE 1
.cp1:
	mWaitForNewHBlank
	ld   a, [sActLavaWallTileIdU]	; Read the tile id for the upper half
	ld   [hl], a					; Write it to the tilemap
	
	add  hl, de						; Move 1 tile below
	
	; [POI] We never reach the end of the tilemap
	ld   a, h						
	cp   a, HIGH(BGMap_End)			; Did we reach the end of the tilemap?
	jr   c, .cp2					; If not, jump
	ld   h, HIGH(BGMap_Begin)		; Otherwise, loop back to the beginning
	
	
	; TILE 2
.cp2:
	mWaitForNewHBlank
	
	ld   a, [sActLavaWallTileIdD]	; Read the tile id for the lower half
	ld   [hl], a					; Write it to the tilemap
	add  hl, de						; Move 1 tile below again (not necessary)
	; [POI] We never reach the end of the tilemap
	ld   a, h						
	cp   a, HIGH(BGMap_End)			; Did we reach the end of the tilemap?
	jr   c, .cpEnd					; If not, jump
	ld   h, HIGH(BGMap_Begin)		; Otherwise, loop back to the beginning
.cpEnd:
	pop  hl							; Restore orig level layout ptr
	;##
	
.nextBlock:
	dec  h							; Move 1 block up
	ld   a, [sActLavaWallRowsLeft]
	dec  a							; Did we write blocks to all rows?
	ld   [sActLavaWallRowsLeft], a
	jr   nz, .loop					; If not, loop
	ret
	
OBJLstPtrTable_Act_LavaWall:
	dw OBJLst_Act_LavaWall0
	dw OBJLst_Act_LavaWall1
	dw OBJLst_Act_LavaWall2
	dw OBJLst_Act_LavaWall3
	dw $0000

OBJLst_Act_LavaWall0: INCBIN "data/objlst/actor/lavawall0.bin"
OBJLst_Act_LavaWall1: INCBIN "data/objlst/actor/lavawall1.bin"
OBJLst_Act_LavaWall2: INCBIN "data/objlst/actor/lavawall2.bin"
OBJLst_Act_LavaWall3: INCBIN "data/objlst/actor/lavawall3.bin"
GFX_Act_LavaWall: INCBIN "data/gfx/actor/lavawall.bin"

; =============== ActInit_SyrupCastlePlatformU ===============
; Platform used in a single room in C39, always moving up.
ActInit_SyrupCastlePlatformU:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, -$08
	ld   [sActSetColiBoxD], a
	ld   a, -$02
	ld   [sActSetColiBoxL], a
	ld   a, +$12
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_SyrupCastlePlatformU
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_SyrupCastlePlatform
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_SyrupCastlePlatform
	call ActS_SetOBJLstSharedTablePtr
	
	ld   a, ACTCOLI_TOPSOLID
	ld   [sActSetColiType], a
	ret
	
; =============== ActInit_SyrupCastlePlatformD ===============	
; Platform used in a single room in C39, always moving down.
ActInit_SyrupCastlePlatformD:;I
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$10
	ld   [sActSetColiBoxU], a
	ld   a, -$08
	ld   [sActSetColiBoxD], a
	ld   a, -$02
	ld   [sActSetColiBoxL], a
	ld   a, +$12
	ld   [sActSetColiBoxR], a
	
	ld   bc, SubCall_Act_SyrupCastlePlatformD
	call ActS_SetCodePtr
	
	push bc
	ld   bc, OBJLstPtrTable_Act_SyrupCastlePlatform
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   bc, OBJLstSharedPtrTable_Act_SyrupCastlePlatform
	call ActS_SetOBJLstSharedTablePtr
	
	ld   a, ACTCOLI_TOPSOLID
	ld   [sActSetColiType], a
	ret
	
OBJLstPtrTable_Act_SyrupCastlePlatform:
	dw OBJLst_Act_SyrupCastlePlatform
	dw $0000;X

; =============== Act_SyrupCastlePlatformU ===============	
Act_SyrupCastlePlatformU:
	ld   a, [sActSetTimer]	; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Move up 0.5px/frame
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveDown
	
	; If the player is standing on it, move him up as well
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06			; Standing on the platform?
	ld   b, $01
	call z, SubCall_PlBGColi_DoTopAndMove	; If so, call
	
	; As soon as the actor goes off screen above, shift it off-screen below.
	ld   a, [sActSetRelY]
	add  $10				; Account for actor's height
	cp   a, $01				; Is it visible? (>= 1)
	ret  nc					; If so, return
	; Otherwise, warp it 2 blocks off-screen below
	ld   bc, SCREEN_V + $10 + $20
	call ActS_MoveDown
	ret
	
; =============== Act_SyrupCastlePlatformD ===============	
Act_SyrupCastlePlatformD:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; Move down 0.5px/frame
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveDown
	
	; If the player is standing on it, move him up as well
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_06			; Standing on the platform?
	ld   b, $01
	call z, SubCall_PlBGColi_CheckGroundSolidOrMove	; If so, call
	
	; As soon as the actor goes off screen below, shift it off-screen above.
	ld   a, [sActSetRelY]
	cp   a, SCREEN_V + $10
	ret  c
	ld   bc, -SCREEN_V
	call ActS_MoveDown
	ret
	
OBJLstSharedPtrTable_Act_SyrupCastlePlatform:
	dw OBJLstPtrTable_Act_SyrupCastlePlatform;X
	dw OBJLstPtrTable_Act_SyrupCastlePlatform;X
	dw OBJLstPtrTable_Act_SyrupCastlePlatform;X
	dw OBJLstPtrTable_Act_SyrupCastlePlatform;X
	dw OBJLstPtrTable_Act_SyrupCastlePlatform;X
	dw OBJLstPtrTable_Act_SyrupCastlePlatform;X
	dw OBJLstPtrTable_Act_SyrupCastlePlatform;X
	dw OBJLstPtrTable_Act_SyrupCastlePlatform;X

OBJLst_Act_SyrupCastlePlatform: INCBIN "data/objlst/actor/syrupcastleplatform.bin"
GFX_Act_SyrupCastlePlatform: INCBIN "data/gfx/actor/syrupcastleplatform.bin"

; =============== ActInit_HermitCrab ===============
; See also: ActInit_SpearGoom
ActInit_HermitCrab:
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
	ld   bc, SubCall_Act_HermitCrab
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_HermitCrab
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_HermitCrab
	call ActS_SetOBJLstSharedTablePtr
	
	; Set this as default once, but change it immediately
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	ret
	
OBJLstPtrTable_ActInit_HermitCrab:
	dw OBJLst_Act_HermitCrab_MoveL0
	dw $0000

; =============== Act_HermitCrab ===============
Act_HermitCrab:
	; If the actor is overlapping with a solid block, kill it
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolid
	or   a
	jp   nz, SubCall_ActS_StartJumpDead
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_HermitCrab_Main
	dw SubCall_ActS_OnPlColiH
	dw Act_HermitCrab_Main
	dw SubCall_ActS_StartStarKill
	dw SubCall_ActS_OnPlColiBelow
	dw SubCall_ActS_StartDashKill
	dw Act_HermitCrab_Main;X
	dw SubCall_ActS_StartSwitchDir
	dw SubCall_ActS_StartJumpDeadSameColi
Act_HermitCrab_Main:
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
	; We don't need to perform any Y block alignment because of the 1px/frame speed
	ld   bc, +$01					; Otherwise, fall down at a fixed 1px/frame
	call ActS_MoveDown
.water_chkAnim:
	ld   a, [sActSetTimer]
	and  a, $02
	jr   z, .chkTurnDelay
	call ActS_IncOBJLstIdEvery8
	ret
;--
.noWater:
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is the actor on solid ground?
	jr   nz, .noWater_onSolid		; If so, skip
	; Otherwise, fall down at an increasing speed
	ld   a, [sActSetYSpeed_Low]
	ld   c, a						; BC = sActSetYSpeed_Low
	ld   b, $00
	call ActS_MoveDown				; Move down by that
	
	; Every 4 frames increase the drop speed
	ld   a, [sActSetTimer]
	and  a, $03
	jr   nz, .chkTurnDelay
	ld   a, [sActSetYSpeed_Low]
	inc  a
	ld   [sActSetYSpeed_Low], a
	jr   .chkTurnDelay
.noWater_onSolid:
	; If the actor just landed, align to the floor
	ld   a, [sActSetYSpeed_Low]
	or   a							; Did the actor just land?
	jr   z, .chkTurnDelay			; If not, skip
	xor  a							; Otherwise, reset the drop speed
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetY_Low]			; And align to Y block
	and  a, $F0
	ld   [sActSetY_Low], a
;--

.chkTurnDelay:
	; Once we get here, we've done the downards movement.
	; If any turn delay is set, make sure the actor doesn't move horizontally.
	
	ld   a, [sActHermitCrabTurnDelay]
	or   a							; Is the turn delay set?
	jr   z, .anim					; If not, skip
	dec  a							; Otherwise, decrement it
	ld   [sActHermitCrabTurnDelay], a
	
	or   a							; Did it just elapse?
	call z, Act_HermitCrab_Turn		; If so, call
	
	; $19 frames after the actor stopped moving, close down shell,
	; making it unsafe to touch on both sides
	ld   a, [sActHermitCrabTurnDelay]
	cp   a, $3C-$19						
	call z, Act_HermitCrab_TurnFront	; If so, call
	ret
	
.anim:
	call ActS_IncOBJLstIdEvery8
	
; Perform horizontal movement
.moveH:
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, .moveR
.moveL:
	ld   a, LOW(OBJLstPtrTable_Act_HermitCrab_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_HermitCrab_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Set left direction
	ld   a, [sActSetDir]
	and  a, $F0|DIR_D				; Clear all but what would be DIR_D
	or   a, DIR_L
	ld   [sActSetDir], a
	
	; Unlike Act_SpearGoom, there's no delay before setting it
	call Act_HermitCrab_SetColiL	; Set collision for left movement
	
	; If there's anything on the way, stop moving and start turning around
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolid
	or   a							; Is there a solid block on the left?
	jp   nz, .setTurnDelay			; If so, stop moving
	
	call ActColi_GetBlockId_BottomL
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Are we standing on a solid block?
	jp   z, .setTurnDelay			; If not, stop moving
	
	; Move left 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
.moveR:
	ld   a, LOW(OBJLstPtrTable_Act_HermitCrab_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_HermitCrab_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Set right direction
	ld   a, [sActSetDir]
	and  a, $F0|DIR_D
	or   a, DIR_R
	ld   [sActSetDir], a
	
	; Unlike Act_SpearGoom, there's no delay before setting it
	call Act_HermitCrab_SetColiR	; Set collision for right movement
	
	; If there's anything on the way, stop moving and start turning around
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a							; Is there a solid block on the right?
	jr   nz, .setTurnDelay			; If so, stop moving
	
	call ActColi_GetBlockId_BottomR
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Are we standing on a solid block?
	jr   z, .setTurnDelay			; If not, stop moving
	
	; Move right 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, +$01
	call ActS_MoveRight
	ret
.setTurnDelay:
	ld   a, $3C
	ld   [sActHermitCrabTurnDelay], a
	ret
	
; =============== Act_HermitCrab_TurnFront ===============
; Turns the actor to face the screen (?), making every side except the bottom
; deal damage to the player.
Act_HermitCrab_TurnFront:
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	; Set animation depending on direction
	; [POI] These are so similar, they might as well may have been merged.
	push bc
	ld   bc, OBJLstPtrTable_Act_HermitCrab_FrontL	; When facing left
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, [sActSetDir]
	bit  DIRB_L, a			; Facing left?
	ret  nz					; If so, return
	push bc
	ld   bc, OBJLstPtrTable_Act_HermitCrab_FrontR	; When facing right
	call ActS_SetOBJLstPtr
	pop  bc
	
	ret
	
; =============== Act_HermitCrab_Turn ===============
; Makes the actor switch direction.
Act_HermitCrab_Turn:
	xor  a						; Reset anim frame
	ld   [sActSetOBJLstId], a
	ld   a, [sActSetDir]		; Switch direction
	xor  DIR_L|DIR_R
	ld   [sActSetDir], a
	ret
; =============== Act_HermitCrab_SetColiL ===============
; Sets the actor's collision for facing left (safe side on the right).
Act_HermitCrab_SetColiL:
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
; =============== Act_HermitCrab_SetColiR ===============
; Sets the actor's collision for facing right (safe side on the left).
Act_HermitCrab_SetColiR:
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
OBJLstSharedPtrTable_Act_HermitCrab:
	dw OBJLstPtrTable_Act_HermitCrab_StunL;X
	dw OBJLstPtrTable_Act_HermitCrab_StunR;X
	dw OBJLstPtrTable_Act_HermitCrab_RecoverL
	dw OBJLstPtrTable_Act_HermitCrab_RecoverR
	dw OBJLstPtrTable_Act_HermitCrab_StunL
	dw OBJLstPtrTable_Act_HermitCrab_StunR
	dw OBJLstPtrTable_Act_HermitCrab_MoveL;X
	dw OBJLstPtrTable_Act_HermitCrab_MoveR;X

OBJLstPtrTable_Act_HermitCrab_FrontL:
	dw OBJLst_Act_HermitCrab_FrontL
	dw $0000
OBJLstPtrTable_Act_HermitCrab_FrontR:
	dw OBJLst_Act_HermitCrab_FrontR
	dw $0000
OBJLstPtrTable_Act_HermitCrab_RecoverL:
	dw OBJLst_Act_HermitCrab_StunL
	dw OBJLst_Act_HermitCrab_MoveL0
	dw OBJLst_Act_HermitCrab_MoveL0
	dw $0000;X
OBJLstPtrTable_Act_HermitCrab_RecoverR:
	dw OBJLst_Act_HermitCrab_StunR
	dw OBJLst_Act_HermitCrab_MoveR0
	dw OBJLst_Act_HermitCrab_MoveR0
	dw $0000;X
OBJLstPtrTable_Act_HermitCrab_StunL:
	dw OBJLst_Act_HermitCrab_StunL
	dw $0000
OBJLstPtrTable_Act_HermitCrab_StunR:
	dw OBJLst_Act_HermitCrab_StunR
	dw $0000
OBJLstPtrTable_Act_HermitCrab_MoveL:
	dw OBJLst_Act_HermitCrab_MoveL0
	dw OBJLst_Act_HermitCrab_MoveL1
	dw OBJLst_Act_HermitCrab_MoveL0
	dw OBJLst_Act_HermitCrab_MoveL2
	dw $0000
OBJLstPtrTable_Act_HermitCrab_MoveR:
	dw OBJLst_Act_HermitCrab_MoveR0
	dw OBJLst_Act_HermitCrab_MoveR1
	dw OBJLst_Act_HermitCrab_MoveR0
	dw OBJLst_Act_HermitCrab_MoveR2
	dw $0000

OBJLst_Act_HermitCrab_MoveL0: INCBIN "data/objlst/actor/hermitcrab_movel0.bin"
OBJLst_Act_HermitCrab_MoveL1: INCBIN "data/objlst/actor/hermitcrab_movel1.bin"
OBJLst_Act_HermitCrab_MoveL2: INCBIN "data/objlst/actor/hermitcrab_movel2.bin"
OBJLst_Act_HermitCrab_FrontL: INCBIN "data/objlst/actor/hermitcrab_frontl.bin"
OBJLst_Act_HermitCrab_StunL: INCBIN "data/objlst/actor/hermitcrab_stunl.bin"
OBJLst_Act_HermitCrab_MoveR0: INCBIN "data/objlst/actor/hermitcrab_mover0.bin"
OBJLst_Act_HermitCrab_MoveR1: INCBIN "data/objlst/actor/hermitcrab_mover1.bin"
OBJLst_Act_HermitCrab_MoveR2: INCBIN "data/objlst/actor/hermitcrab_mover2.bin"
OBJLst_Act_HermitCrab_FrontR: INCBIN "data/objlst/actor/hermitcrab_frontr.bin"
OBJLst_Act_HermitCrab_StunR: INCBIN "data/objlst/actor/hermitcrab_stunr.bin"
GFX_Act_HermitCrab: INCBIN "data/gfx/actor/hermitcrab.bin"

; =============== ActInit_GhostGoom ===============
ActInit_GhostGoom:
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
	ld   bc, SubCall_Act_GhostGoom
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_GhostGoom_MoveL
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_GhostGoom
	call ActS_SetOBJLstSharedTablePtr
	
	xor  a
	ld   [sActSetTimer], a
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer6], a
	ld   [sActSetTimer7], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
OBJLstSharedPtrTable_Act_GhostGoom:
	dw OBJLstPtrTable_Act_GhostGoom_RecoverL;X
	dw OBJLstPtrTable_Act_GhostGoom_RecoverR;X
	dw OBJLstPtrTable_Act_GhostGoom_RecoverL
	dw OBJLstPtrTable_Act_GhostGoom_RecoverR
	dw OBJLstPtrTable_Act_GhostGoom_StunL
	dw OBJLstPtrTable_Act_GhostGoom_StunR
	dw OBJLstPtrTable_Act_GhostGoom_MoveL;X
	dw OBJLstPtrTable_Act_GhostGoom_MoveR;X

; =============== Act_GhostGoom ===============
Act_GhostGoom:
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	call ActS_IncOBJLstIdEvery8
	call Act_GhostGoom_FacePl
	
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_GhostGoom_Move
	dw Act_GhostGoom_Stun
	
; =============== Act_GhostGoom_Move ===============
Act_GhostGoom_Move:
	; Like Boos, this only moves when you aren't looking at it.
	
	
	; B = If the player is facing right
	ld   a, [sPlFlags]
	and  a, OBJLST_XFLIP	; A = $20..
	swap a					; >> 4
	rrca					; >> 1
	ld   b, a
	
	ld   a, [sActSetDir]
	and  a, DIR_R			; A = If the actor is facing right
	xor  a, b				; Is the actor facing the same direction? (B ^ A) == 0
	jr   z, .chkRoutine		; If so, move torwards the player
	
	; Otherwise, don't move.
	
	; Perform a transparency effect by switching every other frame
	; between the intended frame and nothing.
	;
	; A side effect of doing this is that switching to the blank anim ends up
	; resetting the anim. counter shortly after ActS_IncOBJLstIdEvery8 is run,
	; since the blank animation is only 1 frame long.
	; This is actually what we want, since the actor isn't moving.
	

	mActS_SetBlankFrame			; Clear the frame first
	xor  a						; Make intangible when hidden
	ld   [sActSetColiType], a
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	; Pick direction depending on the direction faced
	push bc
	ld   bc, OBJLstPtrTable_Act_GhostGoom_MoveR		; right
	call ActS_SetOBJLstPtr
	pop  bc
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Facing right?
	ret  nz					; If so, return
	push bc
	ld   bc, OBJLstPtrTable_Act_GhostGoom_MoveL		; left
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
.chkRoutine:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_GhostGoom_Move_Main
	dw Act_GhostGoom_Move_Main;X
	dw Act_GhostGoom_SwitchToStun
	dw Act_GhostGoom_Move_Main;X
	dw Act_GhostGoom_SwitchToStun
	dw Act_GhostGoom_Move_Main;X
	dw Act_GhostGoom_Move_Main;X
	dw Act_GhostGoom_Move_Main
	dw SubCall_ActS_StartJumpDeadSameColi;X
	
; =============== Act_GhostGoom_FacePl ===============
; This subroutine makes the actor always face/move to the player horizontally.
Act_GhostGoom_FacePl:
	ld   d, DIR_L
	; If the player is to the left of the actor, we got the direction right
	ld   a, [sActSetRelX]	; B = ActX
	add  $20				; Fix for underflow
	ld   b, a
	ld   a, [sPlXRel]		; A = PlX
	add  $20
	cp   a, b				; PlX - ActX < 0? (PlX < ActX)
	jr   c, .setDir			; If so, jump
	; Otherwise, set the other dir
	ld   d, DIR_R
.setDir:
	ld   a, [sActSetDir]
	and  a, $F0|DIR_D|DIR_U
	or   a, d
	ld   [sActSetDir], a
	ret
	
; =============== Act_GhostGoom_Move_Main ===============
Act_GhostGoom_Move_Main:
	; Make the actor always move torwards the player vertically.
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
	;--
	
.setDir:			
	ld   a, [sActSetDir]
	and  a, $F0|DIR_R|DIR_L ; Preserve horz dir
	or   a, d				; Dir |= D 
	ld   [sActSetDir], a
	
	; Move 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
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
.moveRight:
	ld   bc, +$01
	call ActS_MoveRight
	ld   a, LOW(OBJLstPtrTable_Act_GhostGoom_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_GhostGoom_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	; Spear on the left
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret

; =============== .moveLeft ===============
.moveLeft:
	ld   bc, -$01
	call ActS_MoveRight
	ld   a, LOW(OBJLstPtrTable_Act_GhostGoom_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_GhostGoom_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	; Spear on the right
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== .moveUp ===============
.moveUp:
	ld   bc, -$01
	call ActS_MoveDown
	ret
	
; =============== .moveDown ===============
.moveDown:
	ld   bc, $01
	call ActS_MoveDown
	ret
	
; =============== Act_GhostGoom_SwitchToStun ===============
Act_GhostGoom_SwitchToStun:
	ld   a, GHOST_RTN_STUN
	ld   [sActLocalRoutineId], a
	mActSetYSpeed -$04				; Set jump effect
	; Make fully vulnerable
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
	
; =============== Act_GhostGoom_SwitchToStun ===============
; Stun routine.
Act_GhostGoom_Stun:
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
	dw Act_GhostGoom_SwitchToHeld
	dw Act_GhostGoom_SwitchToHeld
	dw .fall;X
	dw Act_GhostGoom_SwitchToHeld
	dw Act_GhostGoom_SwitchToHeld;X
	dw .fall;X
	dw .fall;X
	dw SubCall_ActS_StartJumpDeadSameColi;X
	
.fall:;
	call ActS_FallDownMax4Speed
	;--
	; Permanently despawn the actor once it goes off-screen in this state.
	call ActS_CheckOffScreen
	ld   a, [sActSet]
	cp   a, $02					; Visible & active?
	ret  nc						; If so, return
	xor  a
	ld   [sActSet], a
	ret
	;--
	
; =============== Act_GhostGoom_SwitchToHeld ===============	
Act_GhostGoom_SwitchToHeld:
	push bc					; left?
	ld   bc, OBJLstPtrTable_Act_GhostGoom_StunL
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
	
	push bc
	ld   bc, OBJLstPtrTable_Act_GhostGoom_StunR
	call ActS_SetOBJLstPtr
	pop  bc
.end:
	jp   SubCall_ActS_StartHeld
	
OBJLstPtrTable_Act_GhostGoom_MoveL:
	dw OBJLst_Act_GhostGoom_MoveL0
	dw OBJLst_Act_GhostGoom_MoveL1
	dw $0000
OBJLstPtrTable_Act_GhostGoom_MoveR:
	dw OBJLst_Act_GhostGoom_MoveR0
	dw OBJLst_Act_GhostGoom_MoveR1
	dw $0000
OBJLstPtrTable_Act_GhostGoom_StunL:
	dw OBJLst_Act_GhostGoom_StunL
	dw $0000
OBJLstPtrTable_Act_GhostGoom_StunR:
	dw OBJLst_Act_GhostGoom_StunR
	dw $0000
OBJLstPtrTable_Act_GhostGoom_RecoverL:
	dw OBJLst_Act_GhostGoom_RecoverL
	dw $0000
OBJLstPtrTable_Act_GhostGoom_RecoverR:
	dw OBJLst_Act_GhostGoom_RecoverR
	dw $0000

OBJLst_Act_GhostGoom_MoveL0: INCBIN "data/objlst/actor/ghostgoom_movel0.bin"
OBJLst_Act_GhostGoom_MoveL1: INCBIN "data/objlst/actor/ghostgoom_movel1.bin"
OBJLst_Act_GhostGoom_StunL: INCBIN "data/objlst/actor/ghostgoom_stunl.bin"
OBJLst_Act_GhostGoom_RecoverL: INCBIN "data/objlst/actor/ghostgoom_recoverl.bin"
OBJLst_Act_GhostGoom_MoveR0: INCBIN "data/objlst/actor/ghostgoom_mover0.bin"
OBJLst_Act_GhostGoom_MoveR1: INCBIN "data/objlst/actor/ghostgoom_mover1.bin"
OBJLst_Act_GhostGoom_StunR: INCBIN "data/objlst/actor/ghostgoom_stunr.bin"
OBJLst_Act_GhostGoom_RecoverR: INCBIN "data/objlst/actor/ghostgoom_recoverr.bin"
GFX_Act_GhostGoom: INCBIN "data/gfx/actor/ghostgoom.bin"

; =============== ActInit_Seahorse ===============
ActInit_Seahorse:
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
	ld   bc, SubCall_Act_Seahorse
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_Seahorse_MoveR
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Seahorse
	call ActS_SetOBJLstSharedTablePtr
	
	xor  a
	ld   [sActLocalRoutineId], a
	
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	
	; Save original spawn Y position, since after moving up, we need to return
	; to the original position.
	ld   a, [sActSetY_Low]				
	ld   [sActSeahorseOrigY_Low], a
	ld   a, [sActSetY_High]
	ld   [sActSeahorseOrigY_High], a
	ret
	
; =============== Act_Seahorse ===============
Act_Seahorse:
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Seahorse_Main
	dw Act_Seahorse_Main
	dw Act_Seahorse_Main
	dw SubCall_ActS_StartStarKill
	dw Act_Seahorse_Main
	dw Act_Seahorse_Main
	dw Act_Seahorse_Main;X
	dw Act_Seahorse_Main
	dw SubCall_ActS_StartJumpDead
	
; =============== Act_Seahorse_Main ===============
Act_Seahorse_Main:
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_Seahorse_MoveUp
	dw Act_Seahorse_MoveDown
	dw Act_Seahorse_Alert
	dw Act_Seahorse_Attack
	
; =============== Act_Seahorse_SwitchToMoveUp ===============
Act_Seahorse_SwitchToMoveUp:
	ld   a, SEAH_RTN_MOVEUP
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActModeTimer], a
	ret
	
; =============== Act_Seahorse_MoveUp ===============
Act_Seahorse_MoveUp:
	call ActS_IncOBJLstIdEvery8
	
	;--
	; Stay in this mode for $18 frames before switching
	ld   a, [sActModeTimer]
	cp   a, $18
	jp   nc, Act_Seahorse_SwitchToMoveDown
	inc  a
	ld   [sActModeTimer], a
	;--
	
.chkMoveV:
	; Move actor up if there's a water block above
	call ActColi_GetBlockId_Top
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a					; Is there one?
	jr   nz, .moveH			; If not, skip
.moveV:
	; Otherwise, move as specified by the table (16 bytes large, each entry 2bytes), indexed by the timer.
	; The table values make the actor move up.
	ld   a, [sActModeTimer]	
	and  a, $0E							; Keep in range (+ clear bit 0 for *2, since entries are 16bit)
	ld   d, $00							; DE = sActModeTimer
	ld   e, a
	ld   hl, Act_Seahorse_MoveUp_YPath	; HL = Table
	add  hl, de							; Offset it
	
	ld   c, [hl]		; BC = Amount to move down
	inc  hl
	ld   b, [hl]
	call ActS_MoveDown	; Move down by that
	
.moveH:
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, Act_Seahorse_MoveUp_MoveRight
	bit  DIRB_L, a
	jr   nz, Act_Seahorse_MoveUp_MoveLeft
	ret ; We never get here
	
; =============== Act_Seahorse_MoveUp_MoveLeft ===============
Act_Seahorse_MoveUp_MoveLeft:
	; If there's a solid block in the way, turn right
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, .turn
	
	ld   bc, -$01
	call ActS_MoveRight
	ld   a, LOW(OBJLstPtrTable_Act_Seahorse_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Seahorse_MoveR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
.turn:
	ld   a, DIR_R
	ld   [sActSetDir], a
	xor  a
	ld   [sActSetOBJLstId], a
	ret
	
; =============== Act_Seahorse_MoveUp_MoveRight ===============
Act_Seahorse_MoveUp_MoveRight:
	; If there's a solid block in the way, turn left
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolidOnTop
	or   a
	jr   nz, .turn
	
	ld   bc, +$01
	call ActS_MoveRight
	
	ld   a, LOW(OBJLstPtrTable_Act_Seahorse_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Seahorse_MoveL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ret
.turn:
	ld   a, DIR_L
	ld   [sActSetDir], a
	xor  a
	ld   [sActSetOBJLstId], a
	ret
	
; =============== Act_Seahorse_MoveUp_YPath ===============
; Vertical movement path for the actor during MoveUp.
Act_Seahorse_MoveUp_YPath: 
	db -$01,-$01,-$01,-$01,+$00,+$00,-$01,-$01,+$00,+$00,-$01,-$01,+$00,+$00,+$00,+$00
	
; =============== Act_Seahorse_SwitchToMoveDown ===============
Act_Seahorse_SwitchToMoveDown:
	ld   a, SEAH_RTN_MOVEDOWN
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActModeTimer], a
	ret
	
; =============== Act_Seahorse_MoveDown ===============
Act_Seahorse_MoveDown:
	xor  a						; Don't animate here
	ld   [sActSetOBJLstId], a
	
	; Move down every other frame until the original position is reached.
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	; Check for orig pos
	ld   a, [sActSetY_Low]			; BC = Current Y pos
	ld   c, a
	ld   a, [sActSetY_High]
	ld   b, a
	ld   a, [sActSeahorseOrigY_Low]	; AE = Target Y pos - Current Y pos
	sub  a, c
	ld   e, a
	ld   a, [sActSeahorseOrigY_High]
	sbc  a, b
	or   a, e						; Are they the same? (so BC - AE == 0)
	jr   z, Act_Seahorse_MoveDown_End					; If so, jump
	ld   bc, +$01					; Otherwise keep moving down
	call ActS_MoveDown
	ret
	
; =============== Act_Seahorse_IsPlInRange ===============
; Determines if the player is in the range of the actor.
; OUT
; - A: If the player is in range
Act_Seahorse_IsPlInRange:
	
	;
	; X DISTANCE
	;
	ld   a, [sActSetX_Low]		; HL = Actor X
	ld   l, a
	ld   a, [sActSetX_High]
	ld   h, a
	ld   a, [sPlX_Low]			; BC = Player X
	ld   c, a
	ld   a, [sPlX_High]
	ld   b, a
	call ActS_GetPlDistance		; HL = Diff
	; Diff must be < $30
	ld   a, l					
	cp   a, $30					; Is the player in the range of the actor?
	jr   nc, .false				; If not, return false
	
	;
	; Y DISTANCE
	;
	ld   a, [sActSetY_Low]		; HL = Actor Y
	ld   l, a
	ld   a, [sActSetY_High]
	ld   h, a
	ld   a, [sPlY_Low]			; BC = Player Y
	ld   c, a
	ld   a, [sPlY_High]
	ld   b, a
	call ActS_GetPlDistance		; HL = Diff
	; Diff must be < $20
	ld   a, l
	cp   a, $20					; Is the player in the range of the actor?
	jr   nc, .false				; If not, return false
	; Otherwise, we're in range.
.true:
	ld   a, $01
	ret
.false:
	xor  a
	ret
	
; =============== Act_Seahorse_MoveDown_End ===============
Act_Seahorse_MoveDown_End:
	; Every time (and only when) the actor finishes moving down, it checks where the player is.
	call Act_Seahorse_IsPlInRange
	or   a									; Is the player in range?
	jp   z, Act_Seahorse_SwitchToMoveUp		; If not, start moving up again
	;--
	
	; Otherwise, perform a check on the direction.
	; The actor should start attacking only if we're in front of it,
	; but keep in mind this actor moves backwards!
	;
	; The sActSetDir value matches to the movement direction, so when
	; DIRB_R is set, the actor is indeed moving right but facing left visually.
	;
	; The only things that matter here for this backwards movement are:
	; - The comparision checks in .chkRight and .chkLeft.
	; - Picking the OBJLst for the opposite direction
	; Everything else is the same.
	
	ld   a, SEAH_RTN_ALERT
	ld   [sActLocalRoutineId], a
	
	; Depending on the direction faced...
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, .chkRight
	bit  DIRB_L, a
	jr   nz, .chkLeft
	ret ; We never get here
.chkLeft:
	; The actor is moving left, so it is visually facing right.
	; Therefore, so the player must be on the right to start attacking.
	
	ld   a, [sActSetRelX]	; D = ActX
	ld   d, a
	ld   a, [sPlXRel]		; A = PlX
	cp   a, d				; Is the player to the left of the actor? (PlX < ActX?)
	jp   c, Act_Seahorse_SwitchToMoveUp	; If so, don't attack
	
	push bc
	ld   bc, OBJLstPtrTable_Act_Seahorse_AlertR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.chkRight:

	; The actor is moving right, so it is visually facing left.
	; Therefore, so the player must be on the left to start attacking.
	
	ld   a, [sActSetRelX]	; D = ActX
	ld   d, a
	ld   a, [sPlXRel]		; A = PlX
	cp   a, d				; Is the player to the right of the actor? (PlX > ActX?)
	jp   nc, Act_Seahorse_SwitchToMoveUp 	; If so, don't attack
	
	push bc
	ld   bc, OBJLstPtrTable_Act_Seahorse_AlertL
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_Seahorse_Alert ===============
; Waiting for attack.
Act_Seahorse_Alert:
	call ActS_IncOBJLstIdEvery8
	; Wait for the animation to end befoe attacking.
	ld   a, [sActSetOBJLstId]
	cp   a, $07					; Anim counter >= $07?
	jr   nc, .endMode			; If so, we're done
	ret
	
.endMode:
	ld   a, SEAH_RTN_ATTACK
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActModeTimer], a
	; Curl up as a spiny blade
	
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	
	; Pick a different anim depending on direction
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, .animR
	bit  DIRB_L, a
	jr   nz, .animL
	ret ; We never get here
.animR:
	push bc
	ld   bc, OBJLstPtrTable_Act_Seahorse_AttackL
	call ActS_SetOBJLstPtr
	pop  bc
	ret
.animL:
	push bc
	ld   bc, OBJLstPtrTable_Act_Seahorse_AttackR
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
; =============== Act_Seahorse_Attack ===============
; Attack mode.
Act_Seahorse_Attack:
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .moveH
	ld   a, [sActSetOBJLstId]
	inc  a
	ld   [sActSetOBJLstId], a
	
.moveH:
	; Move for $40 frames back and forth
	ld   a, [sActModeTimer]
	cp   a, $40
	jp   nc, Act_Seahorse_SwitchToMoveUp
	inc  a
	ld   [sActModeTimer], a
	
	; Move horizontally based on the path info in the table.
	; Each entry in this table is 2bytes large, so we're filtering by $1E instead of $1F.
	and  a, $1E							; Keep index in range
	ld   hl, Act_Seahorse_Attack_XPath	; HL = Table
	ld   d, $00							; DE = Index
	ld   e, a
	add  hl, de							; Offset the table
	ldi  a, [hl]						; BC = Amount to move right
	ld   c, a
	ld   b, [hl]
	call ActS_MoveRight					; Move by that
	ret
	
; =============== Act_Seahorse_Attack_XPath ===============
Act_Seahorse_Attack_XPath:
	db -$02,-$01,-$02,-$01,-$01,-$01,-$01,-$01,-$01,-$01,-$01,-$01,+$00,+$00,+$00,+$00
	db +$02,+$00,+$02,+$00,+$01,+$00,+$01,+$00,+$01,+$00,+$01,+$00,+$00,+$00,+$00,+$00
	
OBJLstSharedPtrTable_Act_Seahorse:
	dw OBJLstPtrTable_Act_Seahorse_StunL;X
	dw OBJLstPtrTable_Act_Seahorse_StunR;X
	dw OBJLstPtrTable_Act_Seahorse_StunL;X
	dw OBJLstPtrTable_Act_Seahorse_StunR;X
	dw OBJLstPtrTable_Act_Seahorse_StunL
	dw OBJLstPtrTable_Act_Seahorse_StunR
	dw OBJLstPtrTable_Act_Seahorse_MoveL;X
	dw OBJLstPtrTable_Act_Seahorse_MoveR;X

OBJLstPtrTable_Act_Seahorse_MoveL:
	dw OBJLst_Act_Seahorse_MoveL0
	dw OBJLst_Act_Seahorse_MoveL1
	dw OBJLst_Act_Seahorse_MoveL0
	dw OBJLst_Act_Seahorse_MoveL2
	dw $0000
OBJLstPtrTable_Act_Seahorse_MoveR:
	dw OBJLst_Act_Seahorse_MoveR0
	dw OBJLst_Act_Seahorse_MoveR1
	dw OBJLst_Act_Seahorse_MoveR0
	dw OBJLst_Act_Seahorse_MoveR2
	dw $0000
OBJLstPtrTable_Act_Seahorse_AlertL:
	dw OBJLst_Act_Seahorse_StunL
	dw OBJLst_Act_Seahorse_StunL
	dw OBJLst_Act_Seahorse_StunL
	dw OBJLst_Act_Seahorse_StunL
	dw OBJLst_Act_Seahorse_MoveL0
	dw OBJLst_Act_Seahorse_AttackL0
	dw OBJLst_Act_Seahorse_AttackL1
	dw OBJLst_Act_Seahorse_AttackL1;X
	dw $0000;X
OBJLstPtrTable_Act_Seahorse_AlertR:
	dw OBJLst_Act_Seahorse_StunR
	dw OBJLst_Act_Seahorse_StunR
	dw OBJLst_Act_Seahorse_StunR
	dw OBJLst_Act_Seahorse_StunR
	dw OBJLst_Act_Seahorse_MoveR0
	dw OBJLst_Act_Seahorse_AttackR0
	dw OBJLst_Act_Seahorse_AttackR1
	dw OBJLst_Act_Seahorse_AttackR1;X
	dw $0000;X
OBJLstPtrTable_Act_Seahorse_AttackL:
	dw OBJLst_Act_Seahorse_AttackL1
	dw OBJLst_Act_Seahorse_AttackL2
	dw $0000
OBJLstPtrTable_Act_Seahorse_AttackR:
	dw OBJLst_Act_Seahorse_AttackR1
	dw OBJLst_Act_Seahorse_AttackR2
	dw $0000
OBJLstPtrTable_Act_Seahorse_StunL:
	dw OBJLst_Act_Seahorse_StunL
	dw $0000
OBJLstPtrTable_Act_Seahorse_StunR:
	dw OBJLst_Act_Seahorse_StunR
	dw $0000

OBJLst_Act_Seahorse_MoveL0: INCBIN "data/objlst/actor/seahorse_movel0.bin"
OBJLst_Act_Seahorse_MoveL1: INCBIN "data/objlst/actor/seahorse_movel1.bin"
OBJLst_Act_Seahorse_MoveL2: INCBIN "data/objlst/actor/seahorse_movel2.bin"
OBJLst_Act_Seahorse_StunL: INCBIN "data/objlst/actor/seahorse_stunl.bin"
OBJLst_Act_Seahorse_AttackL0: INCBIN "data/objlst/actor/seahorse_attackl0.bin"
OBJLst_Act_Seahorse_AttackL1: INCBIN "data/objlst/actor/seahorse_attackl1.bin"
OBJLst_Act_Seahorse_AttackL2: INCBIN "data/objlst/actor/seahorse_attackl2.bin"
OBJLst_Act_Seahorse_MoveR0: INCBIN "data/objlst/actor/seahorse_mover0.bin"
OBJLst_Act_Seahorse_MoveR1: INCBIN "data/objlst/actor/seahorse_mover1.bin"
OBJLst_Act_Seahorse_MoveR2: INCBIN "data/objlst/actor/seahorse_mover2.bin"
OBJLst_Act_Seahorse_StunR: INCBIN "data/objlst/actor/seahorse_stunr.bin"
OBJLst_Act_Seahorse_AttackR0: INCBIN "data/objlst/actor/seahorse_attackr0.bin"
OBJLst_Act_Seahorse_AttackR1: INCBIN "data/objlst/actor/seahorse_attackr1.bin"
OBJLst_Act_Seahorse_AttackR2: INCBIN "data/objlst/actor/seahorse_attackr2.bin"
GFX_Act_Seahorse: INCBIN "data/gfx/actor/seahorse.bin"

; =============== ActInit_BigItemBox ===============
ActInit_BigItemBox:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$14
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$06
	ld   [sActSetColiBoxL], a
	ld   a, +$06
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_BigItemBox
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_BigItemBox_Idle
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_BigItemBox
	call ActS_SetOBJLstSharedTablePtr
	
	ld   a, ACTCOLI_BIGBLOCK
	ld   [sActSetColiType], a
	
	xor  a
	ld   [sActLocalRoutineId], a
	
	
	ld   a, [sActBigItemBoxUsed]
	or   a							; Is the block already hit?
	ret  z							; If not, return
	
	; Otherwise, set the properties of the used block
	push bc							; Alternate sprite mappings
	ld   bc, OBJLstPtrTable_Act_BigItemBox_Used					
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, $02						; Set routine
	ld   [sActLocalRoutineId], a
	ld   a, ACTCOLI_TOPSOLID
	ld   [sActSetColiType], a
	ld   a, -$08					; Reduce size to avoid having the player warp up
	ld   [sActSetColiBoxD], a
	ret
	
OBJLstPtrTable_Act_BigItemBox_Idle:
	dw OBJLst_Act_BigItemBox_Idle
	dw $0000;X
OBJLstPtrTable_Act_BigItemBox_Hit:
	dw OBJLst_Act_BigItemBox_Hit
	dw $0000;X
OBJLstPtrTable_Act_BigItemBox_Used:
	dw OBJLst_Act_BigItemBox_Used
	dw $0000;X

; =============== Act_BigItemBox ===============
Act_BigItemBox:
	ld   a, [sActSetTimer]
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_BigItemBox_Idle
	dw Act_BigItemBox_Hit
	dw Act_BigItemBox_Used
	
; =============== Act_BigItemBox_Idle ===============
; Wait for the player hitting the box.
Act_BigItemBox_Idle:
	; Depending on the action the player took...
	ld   a, [sActSetRoutineId]
	and  a, $0F
	cp   a, ACTRTN_01				; Hit from the side?
	jr   z, .hit					; If so, activate it
	cp   a, ACTRTN_04				; Hit from below?
	jr   z, .hit					; If so, activate it
	ret
	
.hit:
	ld   a, ACTCOLI_TOPSOLID		; Prevent further hits
	ld   [sActSetColiType], a
	ld   a, -$08					; Decrease collision height by 8px
	ld   [sActSetColiBoxD], a
	ld   a, BBOX_RTN_HIT
	ld   [sActLocalRoutineId], a
	
	push bc							; Set "hit" frame
	ld   bc, OBJLstPtrTable_Act_BigItemBox_Hit
	call ActS_SetOBJLstPtr
	pop  bc
	
	xor  a
	ld   [sActModeTimer], a
	; [BUG] Hitting the block by dashing underwater glitches the player upwards, softlocking them until time runs out.
	;       Prevent that from happening by resetting the jet dash timer.
IF FIX_BUGS
	ld   [sPlJetDashTimer], a
ENDC

	ld   a, SFX4_02
	ld   [sSFX4Set], a
	ld   a, $04						; Trigger screen shake for 4 frames
	ld   [sScreenShakeTimer], a
	ld   a, $01						; Mark as used for the entire level
	ld   [sActBigItemBoxUsed], a
	ret
	
; =============== Act_BigItemBox_Hit ===============
; Handles the "hit" effect, similar to the one for big switch boxes.
Act_BigItemBox_Hit:

	; Move every other frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	; Move the actor by the path info in the table, indexed by sActModeTimer.
	; Each value is added to the current actor's position.
	ld   a, [sActModeTimer]		; A = Index
	cp   a, $08					; Reached the end of the table?
	jr   nc, .endMode			; If so, we're done
	inc  a						; Index++
	ld   [sActModeTimer], a
	
	ld   hl, .yPath				; HL = Start of Y offset table
	ld   d, $00					; DE = Index
	ld   e, a
	add  hl, de					; Index the table
	ld   a, [hl]				; C = Y offset
	ld   c, a					
REPT 5							; Sign extend it to B
	sra  a						; (incomplete sign extension shortcut, as seen elsewhere)
ENDR
	ld   b, a					
	call ActS_MoveDown			; Move down by BC
	ret
	
	; This path is the same as the one used for the big switch block.
.yPath: 
	db $00 ; Dummy unused value (pre-increment)
	db -$06,-$04,-$03,-$02
	db +$02,+$03,+$04,+$06
	
.endMode:
	ld   a, BBOX_RTN_USED
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActModeTimer], a
	
	push bc						; Set used box
	ld   bc, OBJLstPtrTable_Act_BigItemBox_Used
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Which item should come out of the box?
	ld   a, [sActBigItemBoxType]
	or   a	; BIGITEM_COIN			; Is it a 100-coin? 
	call z, SubCall_ActS_SpawnBigCoin
	ld   a, [sActBigItemBoxType]
	cp   a, BIGITEM_HEART			; Is it a 3UP Heart?
	call z, SubCall_ActS_SpawnBigHeart
	ret
	
; =============== Act_BigItemBox_Used ===============
Act_BigItemBox_Used:
	ld   a, ACTCOLI_TOPSOLID
	ld   [sActSetColiType], a
	ret

OBJLstSharedPtrTable_Act_BigItemBox:
	dw OBJLstPtrTable_Act_BigItemBox_Used;X
	dw OBJLstPtrTable_Act_BigItemBox_Used;X
	dw OBJLstPtrTable_Act_BigItemBox_Used;X
	dw OBJLstPtrTable_Act_BigItemBox_Used;X
	dw OBJLstPtrTable_Act_BigItemBox_Used;X
	dw OBJLstPtrTable_Act_BigItemBox_Used;X
	dw OBJLstPtrTable_Act_BigItemBox_Used;X
	dw OBJLstPtrTable_Act_BigItemBox_Used;X

OBJLst_Act_BigItemBox_Idle: INCBIN "data/objlst/actor/bigitembox_idle.bin"
OBJLst_Act_BigItemBox_Hit: INCBIN "data/objlst/actor/bigitembox_hit.bin"
OBJLst_Act_BigItemBox_Used: INCBIN "data/objlst/actor/bigitembox_used.bin"
GFX_Act_BigItemBox: INCBIN "data/gfx/actor/bigitembox.bin"

; =============== ActInit_Bomb ===============
ActInit_Bomb:
	; Setup collision box
	ld   a, -$06
	ld   [sActSetColiBoxU], a
	ld   a, +$06
	ld   [sActSetColiBoxD], a
	ld   a, -$06
	ld   [sActSetColiBoxL], a
	ld   a, +$06
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Bomb
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_Act_Bomb_Main
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Bomb
	call ActS_SetOBJLstSharedTablePtr
	
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActBombThrown], a
	ld   [sActBombExplTimer], a
	ld   [sActSetTimer], a
	ld   [sActBombBlockExplIndex], a
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	ret
	
; =============== Act_Bomb ===============
; Pickable bomb actor.
Act_Bomb:
	ld   a, [sActSetTimer]			; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_Bomb_Idle
	dw Act_Bomb_Thrown
	dw Act_Bomb_Explode
	dw Act_Bomb_Held
	
; =============== Act_Bomb_Idle ===============	
; Main loop for the bomb, when it's waiting to be interacted with.
Act_Bomb_Idle:
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Bomb_Idle_Main
	dw Act_Bomb_Idle_OnTouch
	dw Act_Bomb_Idle_OnTouch
	dw Act_Bomb_Idle_OnThrowOrGroundpound
	dw Act_Bomb_Idle_Main
	dw Act_Bomb_Idle_OnTouch
	dw Act_Bomb_Idle_Main;X
	dw Act_Bomb_Idle_Main;X
	dw Act_Bomb_Idle_OnThrowOrGroundpound
	
; =============== Act_Bomb_Idle_Main ===============
; During idle mode, basically only handle ground collision.
Act_Bomb_Idle_Main:
	call Act_Bomb_Move
	ret
	
; =============== Act_Bomb_Idle_OnTouch ===============
; Handles what happens when the bomb is touched in a way which makes it possible to hold it.
; (Separated from the ground pound action, which does not make the player hold it)
Act_Bomb_Idle_OnTouch:
	ld   a, $64						; Explode after $64 frames
	ld   [sActBombExplTimer], a
	xor  a							; Prevent picking up once activated
	ld   [sActSetColiType], a
	
	; Try to hold the bomb on touch.
	; Except if it's underwater. Since it's not possible to start grabbing actors underwater,
	; for consistency we aren't grabbing it either.
	ld   a, BOMB_RTN_THROW						
	ld   [sActLocalRoutineId], a
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a									; Is it underwater?
	jp   z, Act_Bomb_WaitExplode			; If so, jump
	
	; [BUG] No check if we're already holding something.
	;       This means we can hold multiple actors at once, which is buggy.
	IF FIX_BUGS == 1
		ld   a, [sActHeld]
		and  a							; Are we currrently holding something else?
		jp   nz, Act_Bomb_WaitExplode	; If so, make it explode but don't hold it
	ENDC
	
.end:
	ld   a, BOMB_RTN_HELD
	ld   [sActLocalRoutineId], a
	ret
	
; =============== Act_Bomb_Held ===============
; This mode handles the held state for the bomb.
;
; [BUG] This actor has the dubious honour of handling the held state by itself
;       outside of boss rooms.
;       It's also missing logic which makes it behave in buggy ways:
;       - It doesn't clear sActHeldId, which makes it possible to clone
;         previously held default actors (read: 10-coins and keys).
;         The value isn't even cleared when coming from other levels -- Act_Held in the only
;         one that syncs the value when needed (when holding something), but this forgets to do it.
;       - It doesn't care if we were already holding something previously, so
;         we can hold multiple actors at once.
;         (this would have gone to Act_Bomb_Idle_OnTouch)
;       - If the player goes underwater, the actor doesn't move above the player's head,
;         since ActS_SyncHeldPos is not expected to be called when underwater.
Act_Bomb_Held:
	call ActS_SyncHeldPos		; Update actor's pos
	
	ld   a, $02					; Force held flag
	ld   [sActHeld], a
	xor  a						; Force light
IF FIX_BUGS == 1
	ld   [sActHeldId], a		; We don't need this (only useful to transfer actors between doors, and we can't do that with bombs)
ENDC
	ld   [sActHoldHeavy], a
	
	; [BUG?] Is this intentional?
	;        The normal held code uses hJoyNewKeys to prevent from being able to automatically
	;        throw something when holding B all the time.
	ldh  a, [hJoyKeys]
	bit  KEYB_B, a						; Is the player pressing/holding B?
	jr   nz, Act_Bomb_SwitchToThrown	; If so, throw it
	
	jp   Act_Bomb_WaitExplode
	
; =============== Act_Bomb_SwitchToThrown ===============
; Starts to throw the bomb.
Act_Bomb_SwitchToThrown:
	ld   a, SFX1_0C
	ld   [sSFX1Set], a
	ld   a, BOMB_RTN_THROW
	ld   [sActLocalRoutineId], a
	
	; Again, this doesn't touch the held actor's id
	xor  a						
	ld   [sActHeld], a
	ld   a, $01
	ld   [sActBombThrown], a
	
	; Set horizontal direction to be the same as the player's
	mPlFlagsToXDir
	ld   [sActSetDir], a
	
	; By default, throw in a downwards arc (initial Y speed $00).
	; However, if we're jumping and we haven't reached the peak of the jump yet,
	; make that arc initially upwards (until the Y speed becomes positive again, that is).
	
	; [POI]
	; This is identical to the relevant snippet in the normal throw code,
	; except jump-throw speed is -$03, and not -$04.
	
	; [BUG] This doesn't account for the high jump having a different peak value.
	mActSetYSpeed $00
	ld   a, [sPlAction]
	cp   a, PL_ACT_JUMP				; Are we jumping?
	ret  nz							; If not, return
	
	
	IF FIX_BUGS == 1
		; Determine peak value for the jump
		ld   b, (Pl_JumpYPath.down-Pl_JumpYPath) ; B = Normal jump peak
		ld   a, [sHighJump]
		and  a							; Doing an high jump?
		jr   z, .setJump				; If not, skip ahead
		ld   b, (Pl_HighJumpYPath.down-Pl_HighJumpYPath) ; B = High jump peak
	.setJump:
		ld   a, [sPlJumpYPathIndex]
		cp   a, b						; Are we past the peak of the jump (ie: moving downwards, hopefully)	
		ret  nc							; If so, return
		mActSetYSpeed -$03				; Otherwise, change the throw arc
	ELSE
		ld   a, [sPlJumpYPathIndex]
		cp   a, (Pl_JumpYPath.down-Pl_JumpYPath); Are we past the peak of the jump (ie: moving downwards, hopefully)	
		ret  nc										; If so, return
		mActSetYSpeed -$03				; Otherwise, change the throw arc
	ENDC
	ret
	
; =============== Act_Bomb_Idle_OnThrowOrGroundpound ===============
Act_Bomb_Idle_OnThrowOrGroundpound:
	xor  a								; Prevent picking up once activated
	ld   [sActSetColiType], a
	ld   a, BOMB_RTN_THROW
	ld   [sActLocalRoutineId], a
	; If the bomb timer is already counting down, don't reset it
	ld   a, [sActBombExplTimer]
	or   a
	ret  nz
	ld   a, $64							; Explode after $64 frames
	ld   [sActBombExplTimer], a
	ret
	
; =============== Act_Bomb_Thrown ===============	
Act_Bomb_Thrown:
	call Act_Bomb_Move
	
; =============== Act_Bomb_WaitExplode ===============
; Waiting for the bomb to explode.
; While that happens, play SFX and flash it.
Act_Bomb_WaitExplode:
	push bc
	ld   bc, OBJLstPtrTable_Act_Bomb_Main
	call ActS_SetOBJLstPtr
	pop  bc
	
	ld   a, [sActBombExplTimer]
	or   a						; Did the timer elapse?
	jr   z, .explode			; If so, explode
	dec  a						; Otherwise, Timer--
	ld   [sActBombExplTimer], a
	
	;--
	; After $32 frames pass, start flashing and playing SFX
	cp   a, $64-$32				; Timer >= $32				
	ret  nc						; If so, return
	
	call .playSFX
	
	; Every alternating 4 frames, switch between normal and flashing bomb
	ld   a, [sActSetTimer]
	and  a, $04
	ret  z
	push bc
	ld   bc, OBJLstPtrTable_Act_Bomb_Flash
	call ActS_SetOBJLstPtr
	pop  bc
	ret
	
.playSFX:
	; Every 8 frames play the SFX again, for a continuous effect.
	ld   a, [sActSetTimer]
	and  a, $07
	ret  nz
	ld   a, SFX4_14
	ld   [sSFX4Set], a
	ret
	
.explode:
	; If we're still holding the bomb, drop it.
	ld   a, [sActLocalRoutineId]
	cp   a, BOMB_RTN_HELD
	jr   nz, .setRtn
	xor  a
	ld   [sActHeld], a
	
.setRtn:
	ld   a, BOMB_RTN_EXPLODE
	ld   [sActLocalRoutineId], a
	xor  a
	ld   [sActBombBlockExplIndex], a
	
	push bc							; Set anim
	ld   bc, OBJLstPtrTable_Act_Bomb_Explode
	call ActS_SetOBJLstPtr
	pop  bc
	
	; [TCRF] It makes no sense to set the code ptr to the value it's at already!
	;        This being here suggests the game at some point switched the code ptr to
	;        SubCall_Unused_Act_Bomb_WaitExplode, possibly before calling this subroutine the first time.
	ld   bc, SubCall_Act_Bomb		
	call ActS_SetCodePtr
	
	xor  a
	ld   [sActBombExplTimer], a
	ret
	
; =============== Act_Bomb_Explode ===============
Act_Bomb_Explode:
	ld   a, [sActSet]
	cp   a, $02							; Is the bomb on-screen?
	jr   nz, Act_Bomb_Explode_Offscreen	; If not, jump
	
	; When 
	ld   a, [sActSetOBJLstId]
	cp   a, $08							; Frame == $08?
	call z, Act_Bomb_Explode_OnAnim08	; If so, call
	ld   a, [sActSetOBJLstId]
	cp   a, $09							; Frame >= $09?
	call nc, Act_Bomb_Explode_OnAnim09P	; If so, call
	
	;--
	; Weird logic for animating the explosion.
	
	; Unlike most other actors, this uses the global actor timer.
	; Since this keeps updating whether the bomb code is executed or not, it can lead to
	; inconsistent effects when it comes to game lag and LY-saving, leading sometimes
	; to prolongued wait times before it actually explodes.
	ld   a, [sActTimer]			; Keep timer in range $00-$02
	cp   a, $03					; Timer < $03?
	jr   c, .incAnim			; If so, skip
	xor  a						; Otherwise, reset it
	ld   [sActTimer], a
	ld   a, [sActSetOBJLstId]	; AnimCounter++
	inc  a
	ld   [sActSetOBJLstId], a
.incAnim:
	ld   a, [sActSetOBJLstId]
	cp   a, $0F					; Is the animation over?
	ret  c						; If not, return
	xor  a						; Otherwise, delete actor
	ld   [sActSet], a
	ret
	
; =============== Act_Bomb_Explode_Offscreen ===============
Act_Bomb_Explode_Offscreen:
	xor  a
	ld   [sActSetColiType], a
	
	;--
	; Same timer logic as above.
	ld   a, [sActTimer]			; Keep timer in range $00-$02
	cp   a, $03					; Timer < $03?
	jr   c, .incAnim			; If so, skip
	xor  a						; Otherwise, reset it
	ld   [sActTimer], a
	ld   a, [sActSetOBJLstId]	; AnimCounter++
	inc  a
	ld   [sActSetOBJLstId], a
.incAnim:
	ld   a, [sActSetOBJLstId]
	cp   a, $0F					; Is the animation over?
	ret  c						; If not, return
	;--
	; [POI] We don't actually get here, since the actor doesn't explode off-screen.
	xor  a						; Otherwise, delete actor
	ld   [sActSet], a
	ret
	;--
	
; =============== Act_Bomb_Explode_SetExpl ===============
; Sets up the actual explosion effect.
Act_Bomb_Explode_OnAnim08:
	; When the actor gets to the anim frame $08, the bomb explosion gains an actual hitbox,
	; and will damage the player.

	; Set collision box for explosion
	ld   a, -$0E
	ld   [sActSetColiBoxU], a
	ld   a, +$0E
	ld   [sActSetColiBoxD], a
	ld   a, -$0E
	ld   [sActSetColiBoxL], a
	ld   a, +$0E
	ld   [sActSetColiBoxR], a
	
	; Deal damage on touch
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE, ACTCOLI_DAMAGE
	ld   a, COLI
	ld   [sActSetColiType], a
	
	;
	; SET BLOCK DESTRUCTION EFFECT
	;
	; This sets the origin for the block destruction effect, based on
	; the bomb's current position.
	
	ld   a, [sActSetX_Low]		; DE = Actor X
	ld   e, a
	ld   a, [sActSetX_High]
	ld   d, a
	ld   a, [sActSetY_Low]		; BC = Actor Y - $10
	sub  a, $10
	ld   c, a
	ld   a, [sActSetY_High]
	sbc  a, $00
	ld   b, a
	; Get level layout ptr for that location
	mActColi_GetBlockId_GetLevelLayoutPtr
	; And save it to sActBombLevelExplPtr
	ld   a, h
	ld   [sActBombLevelExplPtr_High], a
	ld   a, l
	ld   [sActBombLevelExplPtr_Low], a
	ld   a, SFX4_13
	ld   [sSFX4Set], a
	ret
	
; =============== Act_Bomb_Explode_TriggerExpl ===============
Act_Bomb_Explode_OnAnim09P:
	;--
	ld   a, $03
	ld   [sActHeldColiRoutineId], a
	ld   a, [sActNumProc]
	call SubCall_ActHeldOrThrownActColi_Do
	;--
	
	;
	; DO BLOCK DESTRUCTION EFFECT
	; 
	
	; Previously we set up a pointer to the level layout, marking the origin point for the explosion.
	; Now, every frame we get here, we destroy a breakable block around the 3x3 area.
	;
	; This effect is executed for $09 frames, guaranteeing the entire 3x3 area gets destroyed.
	ld   a, [sActBombBlockExplIndex]
	cp   a, $09
	ret  nc
	inc  a
	ld   [sActBombBlockExplIndex], a
	
	; The list of relative offsets for the 3x3-ish grid is in a separate table.
	;
	; Each iteration, the origin is increased by the amount we get from the table entry,
	; and the updated value is set as the target for the block smash effect.
	
	; Index it to get the offset to the level layout origin ptr.
	add  a					; BC = sActBombBlockExplIndex * 2
	ld   c, a
	ld   b, $00
	ld   hl, .originGrid	; HL = Table
	add  hl, bc				; Index it
	
	ldi  a, [hl]			; BC = Offset
	ld   c, a
	ld   b, [hl]
	ld   a, [sActBombLevelExplPtr_Low]	; HL = Origin
	ld   l, a
	ld   a, [sActBombLevelExplPtr_High]
	ld   h, a
	add  hl, bc							; Apply the offset

	; And trick the dragon flame routone into destroying the blocks.
	ld   a, l							; Set block to attempt destroy
	ld   [sBlockTopLeftPtr_Low], a
	ld   a, h
	ld   [sBlockTopLeftPtr_High], a
	
	; We've got to instantly destroy the blocks we hit.
	; Since CheckBlockId calls into the standard breakable block code,
	; we can trick it into doing just that by faking the powerup status.
	
	; Once we've done executing it, we restore the normal value.
	ld   a, [sPlPower]		; Backup the powerup state
	ld   [sPlPowerBak], a
	ld   a, $02				; Fake bull hat for instabreak
	ld   [sPlPower], a
	call ExActBGColi_DragonHatFlame_CheckBlockId
	ld   a, [sPlPowerBak]	; Restore it
	ld   [sPlPower], a
	;--
	
	; Stop hurting the player after 5 frames (but keep destroying blocks)
	ld   a, [sActBombBlockExplIndex]
	cp   a, $05
	ret  c
	xor  a
	ld   [sActSetColiType], a
	ret
.originGrid: 
	; List of blocks affected by explosion, relative to bomb's location
	;  X    Y
	db +$00,+$00;X
	db -$01,-$02 
	db +$00,-$01 
	db +$01,-$01 
	db -$01,-$01 
	db +$01,+$00 
	db -$01,+$00 
	db +$00,+$01
	db +$01,+$01
	db +$00,+$00
	db +$00,+$00;X

; =============== Act_Bomb_MoveH ===============
; Handles horizontal movement and collision checks when the bomb is thrown.
Act_Bomb_MoveH:
	; Once the bomb starts moving horizontally, it will bounce back and forth
	; and never stop (until it reaches water, or explodes).
	ld   a, [sActSetDir]
	bit  DIRB_R, a
	jr   nz, .moveRight
	bit  DIRB_L, a
	jr   nz, .moveLeft
	ret ; We never get here, since a thrown bomb always moves.
	
.moveRight:
	; If there's a solid block in the way, turn left
	call ActColi_GetBlockId_LowR
	mSubCall ActBGColi_IsSolid
	or   a
	jr   nz, .turn
	
	ld   bc, +$02
	call ActS_MoveRight
	ret

.moveLeft:
	; If there's a solid block in the way, turn right
	call ActColi_GetBlockId_LowL
	mSubCall ActBGColi_IsSolid
	or   a
	jr   nz, .turn
	ld   bc, -$02
	call ActS_MoveRight
	ret
.turn:
	ld   a, [sActSetDir]	; Switch direction
	xor  DIR_R|DIR_L
	ld   [sActSetDir], a
	ret
	
; =============== Act_Bomb_Move ===============
; This subroutine handles movement for the actor.
Act_Bomb_Move:
	; Special movement when underwater
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsEmptyWaterBlock
	or   a							; Is the actor inside a water block?
	jp   z, Act_Bomb_Move_Water		; If so, jump
.air:
	ld   a, [sActBombThrown]
	or   a							; Was the bomb thrown?
	call nz, Act_Bomb_MoveH			; If so, move horizontally as well
	
; =============== Act_Bomb_MoveV ===============
; Handles vertical movement and collision checks.
Act_Bomb_MoveV:
	; Check for collision in the same direction we're moving.
	ld   a, [sActSetYSpeed_High]
	bit  7, a							; Is the actor moving up?
	jr   nz, .chkMoveU					; If so, check for collision above
	
.chkMoveD:
	; The actor is moving down, so check for collision below
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a								; Is there a solid block below?
	jr   nz, .chkNewBounce				; If so, stop moving vertically
	
	jr   .moveV
.chkMoveU:
	; The actor is moving up, so check for collision above
	call ActColi_GetBlockId_Top
	mSubCall ActBGColi_IsSolid
	or   a								; Is there a solid block above?
	jr   nz, .clearVSpeed				; If so, check for a new bounce
	
.moveV:
	; Since we're in the air, move down
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown					; Move down by that
	
	; Increase drop speed every 4 frames
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	ld   a, [sActSetYSpeed_Low]		; sActSetYSpeed++
	add  $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00
	ld   [sActSetYSpeed_High], a
	
	ret
	
.chkNewBounce:
	; We've reached solid ground while moving down. 
	; Check if we had enough speed to trigger a new bounce
	ld   a, [sActSetYSpeed_Low]
	cp   a, $05						; Speed >= $05?
	jr   c, .clearVSpeed			; If not, return
	
	; Otherwise, setup a new Y speed equal to -YSpeed+$02, meaning the
	; actor will move up with the speed reduced by 2.
	; NOTE: It's +$02 and not +$03 since the mandatory "inc a" needed for inverting
	;       a number's sign with cpl is merged with the add instruction.
	cpl								; Invert bits
	add  $02+$01					; 2 + inc a
	ld   [sActSetYSpeed_Low], a
	ld   a, $FF
	ld   [sActSetYSpeed_High], a
	ret
.clearVSpeed:
	; We hit the ceiling, so clear any remaining vertical speed
	; to make the actor move down from the next few frames.
	mActSetYSpeed $00
	ret
	
; =============== Act_Bomb_Move_Water ===============
; Moves the actor when underwater (both types).
Act_Bomb_Move_Water:

	; When a bomb is underwater it moves in-place an oscillating path.
	
	; ...except if it's been thrown.
	; Since a thrown bomb must have been moving downwards before getting underwater,
	; it will continue moving down.
	;
	; This is specifically *not* done when they aren't thrown (unlike when above water, where gravity always applies)
	; to make it possible to have them as floating obstacles in underwater sections.
	ld   a, [sActBombThrown]
	or   a						; Was the actor thrown?
	jr   nz, .linearDown		; If so, move down at a fixed 0.5px/frame speed

	; Otherwise, follow the path as specified in the table,
	; indexed with the main timer.
	
	; Move every 4 frames
	ld   a, [sActSetTimer]
	ld   b, a					; B = sActSetTimer
	and  a, $03
	ret  nz
	
	; The "and" value does a trick here which takes advantage of the table size.
	; The movement table is $10 bytes large, with each entry being 2bytes large.
	;
	; To both keep the index in range and clear bit 0 to index it correctly, the value $0E could be used.
	; However, $1C is used instead to slow down the speed in which the index updates.
	; $1C happens to be ($0E << 1), so we've got to >> 1 it after.
	ld   a, b					
	and  a, ($0E<<1)			; Keep in range + << 1
	rrca						; >> 1
	ld   d, $00
	ld   e, a
	ld   hl, Act_Bomb_WaterYPath	; HL = Table
	add  hl, de						; Offset it
	
	ldi  a, [hl]				; BC = Y offset
	ld   c, a
	ld   b, [hl]
	call ActS_MoveDown			; Move down by that
	ret
.linearDown:
	; Move down 0.5px/frame
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	ld   bc, $01
	call ActS_MoveDown
	ret
	
Act_Bomb_WaterYPath:
	dw +$00,+$01,+$02,+$01
	dw -$00,-$01,-$02,-$01

OBJLstPtrTable_Act_Bomb_Main:
	dw OBJLst_Act_Bomb_Main
	dw $0000;X
OBJLstPtrTable_Act_Bomb_Flash:
	dw OBJLst_Act_Bomb_Flash
	dw $0000;X
OBJLstPtrTable_Act_Bomb_Explode:
	dw OBJLst_Act_Bomb_Main
	dw OBJLst_Act_Bomb_Main
	dw OBJLst_Act_Bomb_Flash
	dw OBJLst_Act_Bomb_Flash
	dw OBJLst_Act_Bomb_Explode0
	dw OBJLst_Act_Bomb_Explode0
	dw OBJLst_Act_Bomb_Explode1
	dw OBJLst_Act_Bomb_Explode1
	dw OBJLst_Act_Bomb_Explode2
	dw OBJLst_Act_Bomb_Explode3
	dw OBJLst_Act_Bomb_Explode4
	dw OBJLst_Act_Bomb_Explode4
	dw OBJLst_Act_Bomb_Explode5
	dw OBJLst_Act_Bomb_Explode5
	dw OBJLst_Act_Bomb_Explode6
	dw OBJLst_Act_Bomb_Explode6;X
	dw $0000;X

OBJLstSharedPtrTable_Act_Bomb:
	dw OBJLstPtrTable_Act_Bomb_Main;X
	dw OBJLstPtrTable_Act_Bomb_Main;X
	dw OBJLstPtrTable_Act_Bomb_Main;X
	dw OBJLstPtrTable_Act_Bomb_Main;X
	dw OBJLstPtrTable_Act_Bomb_Main;X
	dw OBJLstPtrTable_Act_Bomb_Main;X
	dw OBJLstPtrTable_Act_Bomb_Main;X
	dw OBJLstPtrTable_Act_Bomb_Main;X

OBJLst_Act_Bomb_Main: INCBIN "data/objlst/actor/bomb_main.bin"
OBJLst_Act_Bomb_Flash: INCBIN "data/objlst/actor/bomb_flash.bin"
OBJLst_Act_Bomb_Explode0: INCBIN "data/objlst/actor/bomb_explode0.bin"
OBJLst_Act_Bomb_Explode1: INCBIN "data/objlst/actor/bomb_explode1.bin"
OBJLst_Act_Bomb_Explode2: INCBIN "data/objlst/actor/bomb_explode2.bin"
OBJLst_Act_Bomb_Explode4: INCBIN "data/objlst/actor/bomb_explode4.bin"
OBJLst_Act_Bomb_Explode5: INCBIN "data/objlst/actor/bomb_explode5.bin"
OBJLst_Act_Bomb_Explode6: INCBIN "data/objlst/actor/bomb_explode6.bin"
OBJLst_Act_Bomb_Explode3: INCBIN "data/objlst/actor/bomb_explode3.bin"
GFX_Act_Bomb: INCBIN "data/gfx/actor/bomb.bin"

; =============== ActInit_Fly ===============
ActInit_Fly:
	; Respawn at the original actor layout position
	mActS_RespawnOnOrigPos
	
	; Setup collision box
	ld   a, -$0E
	ld   [sActSetColiBoxU], a
	ld   a, -$02
	ld   [sActSetColiBoxD], a
	ld   a, -$0C
	ld   [sActSetColiBoxL], a
	ld   a, +$0C
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_Fly
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_Fly_Idle
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_Fly
	call ActS_SetOBJLstSharedTablePtr
	
	mActColiMask ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	xor  a
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer], a
	ret
	
; =============== Act_Fly ===============
Act_Fly:
	; Animate every 8 frames
	call ActS_IncOBJLstIdEvery8
	
	ld   a, [sActSetTimer]		; Timer++
	inc  a
	ld   [sActSetTimer], a
	
	; If the screen is shaking, make it fly away
	; (in practice it takes effect when the screen stops shaking)
	ld   a, [sScreenShakeTimer]
	or   a
	jp   nz, Act_Fly_SwitchToFly
	
	
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_Fly_Main
	dw Act_Fly_SwitchToFly
	dw Act_Fly_SwitchToDead
	dw SubCall_ActS_StartStarKill
	dw SubCall_ActS_StartJumpDead;X
	dw SubCall_ActS_StartJumpDead;X
	dw Act_Fly_Main;X
	dw Act_Fly_Main;X
	dw SubCall_ActS_StartJumpDead
	
; =============== Act_Fly_Main ===============
Act_Fly_Main:
	ld   a, [sActLocalRoutineId]
	rst  $28
	dw Act_Fly_Idle
	dw Act_Fly_FlyAway
	dw Act_Fly_Dead
	
; =============== Act_Fly_Idle ===============
; Mode $00: Waiting for the player to be in-range before flying away.
Act_Fly_Idle:
	; Set idle anim
	ld   a, LOW(OBJLstPtrTable_Act_Fly_Idle)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_Fly_Idle)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; [POI] You can duck to avoid getting detected by the fly
	ld   a, [sPlDuck]
	or   a
	ret  nz
	
	;
	; If the player is within range, fly away.
	;
	ld   a, [sActSetX_Low]		; HL = Actor X
	ld   l, a
	ld   a, [sActSetX_High]
	ld   h, a
	ld   a, [sPlX_Low]			; BC = Player X
	ld   c, a
	ld   a, [sPlX_High]
	ld   b, a
	call ActS_GetPlDistance		; HL = Distance between actor and player
	ld   a, l
	cp   a, $30					; HL < $30?
	jr   c, Act_Fly_SwitchToFly				; If so, fly away
	ret
	
; =============== Act_Fly_SwitchToFly ===============
Act_Fly_SwitchToFly:
	ld   a, FLY_RTN_FLY
	ld   [sActLocalRoutineId], a
	
	mActOBJLstPtrTable OBJLstPtrTable_Act_Fly_Fly
	
	xor  a								; Reset Y speed
	ld   [sActSetYSpeed_Low], a
	ld   [sActSetYSpeed_High], a
	
	call ActS_GetPlDirHRel				; A = Player location (relative to the actor)
	ld   [sActSetDir], a
	
	xor  a								; Make intangible
	ld   [sActSetColiType], a
	ret
	
; =============== Act_Fly_FlyAway ===============
; Mode $01: The fly flies away off-screen.
;           Note that we aren't permanently despawning it when it goes off-screen.
Act_Fly_FlyAway:
	; Move horizontally depending on the location where the player was.
	; Since that's exactly where we *don't* want to go, we're reversing the direction.
	ld   a, [sActSetDir]
	bit  DIRB_L, a			; Is the player on the left?
	call nz, .moveR			; If so, move right
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Is the player on the right?
	call nz, .moveL			; If so, move left
	
	; Move in an upwards arc, at increasingly faster speed
	ld   a, [sActSetYSpeed_Low]		; BC = Y Speed
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown					; Move down by that
	
	; Every $10 frames, decrease the speed
	ld   a, [sActSetTimer]
	and  a, $0F
	ret  nz
	ld   a, [sActSetYSpeed_Low]		; YSpeed--
	sub  a, $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	sbc  a, $00
	ld   [sActSetYSpeed_High], a
	ret
.moveR:
	ld   bc, +$01
	call ActS_MoveRight
	ret
.moveL:
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
; =============== Act_Fly_SwitchToDead ===============
; Kills the fly when jumping on it.
Act_Fly_SwitchToDead:
	ld   a, FLY_RTN_DEAD
	ld   [sActLocalRoutineId], a
	mActOBJLstPtrTable OBJLstPtrTable_Act_Fly_Hit
	xor  a							; Mark as intangible
	ld   [sActSetColiType], a
	ld   [sActFlyModeTimer], a
	ret
; =============== Act_Fly_Dead ===============
; Mode $02: Handles the death sequence for the actor.
Act_Fly_Dead:
	; Time the death sequence
	ld   a, [sActFlyModeTimer]
	inc  a
	ld   [sActFlyModeTimer], a
	; After $1E frames, do the standard death jump
	cp   a, $1E
	jp   nc, SubCall_ActS_StartJumpDead
	; After $14 frames, spawn a 10-coin for the trouble
	; (killing flies is supposed to be a secret feature, you know)
	cp   a, $14
	call z, SubCall_ActS_Spawn10Coin
	ret
	
OBJLstPtrTable_Act_Fly_Idle:
	dw OBJLst_Act_Fly_Main0
	dw OBJLst_Act_Fly_Main1
	dw $0000
OBJLstPtrTable_Act_Fly_Fly:
	dw OBJLst_Act_Fly_Main0
	dw OBJLst_Act_Fly_Main2
	dw $0000
OBJLstPtrTable_Act_Fly_Hit:
	dw OBJLst_Act_Fly_Hit
	dw OBJLst_Act_Fly_Hit ; [TCRF] Why is it two frames long?
	dw $0000
OBJLstPtrTable_Act_Fly_Dead:
	dw OBJLst_Act_Fly_Dead
	dw OBJLst_Act_Fly_Dead ; [TCRF] Why is it two frames long?
	dw $0000

OBJLstSharedPtrTable_Act_Fly:
	dw OBJLstPtrTable_Act_Fly_Dead;X
	dw OBJLstPtrTable_Act_Fly_Dead;X
	dw OBJLstPtrTable_Act_Fly_Dead;X
	dw OBJLstPtrTable_Act_Fly_Dead;X
	dw OBJLstPtrTable_Act_Fly_Dead
	dw OBJLstPtrTable_Act_Fly_Dead
	dw OBJLstPtrTable_Act_Fly_Dead;X
	dw OBJLstPtrTable_Act_Fly_Dead;X

OBJLst_Act_Fly_Main0: INCBIN "data/objlst/actor/fly_main0.bin"
OBJLst_Act_Fly_Main1: INCBIN "data/objlst/actor/fly_main1.bin"
OBJLst_Act_Fly_Main2: INCBIN "data/objlst/actor/fly_main2.bin"
OBJLst_Act_Fly_Hit: INCBIN "data/objlst/actor/fly_hit.bin"
OBJLst_Act_Fly_Dead: INCBIN "data/objlst/actor/fly_dead.bin"
GFX_Act_Fly: INCBIN "data/gfx/actor/fly.bin"

; =============== ActInit_ExitSkull ===============
; Extra actor placed over the level's exit door, to get
; around tileset/block16 limits.
ActInit_ExitSkull:
	; Setup collision box (not necessary)
	ld   a, -$20
	ld   [sActSetColiBoxU], a
	ld   a, -$00
	ld   [sActSetColiBoxD], a
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_ExitSkull
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	mActOBJLstPtrTable OBJLstPtrTable_Act_ExitSkull
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_None
	call ActS_SetOBJLstSharedTablePtr
	
	; Make intangible
	xor  a
	ld   [sActSetColiType], a
	ret
OBJLstPtrTable_Act_ExitSkull:
	dw OBJLst_Act_ExitSkull
	dw $0000;X

Act_ExitSkull:;I
	;--
	; Pointless to do
	ld   a, LOW(OBJLstPtrTable_Act_ExitSkull)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_ExitSkull)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	;--
	ret
OBJLst_Act_ExitSkull: INCBIN "data/objlst/actor/exitskull.bin"
GFX_Act_ExitSkull: INCBIN "data/gfx/actor/exitskull.bin"
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L027F5C.asm"
ENDC