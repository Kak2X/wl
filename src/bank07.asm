;
; BANK $07 - Actor layouts & init code, Actor (group) defs, Actor code
;

; =============== Level_Unused_LoadDefaultActLayout ===============
; [TCRF] Loads the default (empty) actor layout for invalid levels.  
Level_Unused_LoadDefaultActLayout: 
	ld   hl, sActLayout
.loop:
	xor  a
	ldi  [hl], a
	ld   a, h
	cp   a, HIGH(sActLayout_End)
	jr   nz, .loop
	ret

; =============== Level_LoadActLayout ===============
; Loads/decompresses the actor layout to $B000-$BFFF and initializes misc variables.
; This requires the level layout to be already loaded, since
; this subroutine updates it to mark blocks where actors should appear.
Level_LoadActLayout:
	; Clear level flags
	xor  a
	ld   [sLvlSpecClear], a
	ld   [sActHeld], a
	ld   [sActHeldKey], a
	ld   [sLvlExitDoor], a
	ld   [sLvlTreasureDoor], a
	ld   [sActNumProc], a
	ld   [sActLastProc], a
	ld   [sActLastDraw], a
	ld   [sPlFreezeTimer], a
	ld   [sActBigItemBoxUsed], a
	ld   [sActBigItemBoxType], a
	ld   [sUnused_A3BD], a
	ld   [sActSyrupCastleBossDead], a
	ld   [sActLampEndingOk], a
	ld   [sActKnightDead], a
	
	; Init coin game timer (used when defeating a boss)
	ld   bc, $021C
	ld   a, c		
	ld   [sActCoinGameTimer_Low], a
	ld   a, b		
	ld   [sActCoinGameTimer_High], a
	ld   a, $01				; [TCRF] Not used
	ld   [sAct_Unused_InitDone], a
	ld   a, $74				; [POI] While stored as a variable, it's never something other than $74
	ld   [sActLYLimit], a
	
	mSubCall ActS_ClearRAM
	
	ld   hl, Level_ActLayoutPtrTable
	
	;--
	; [TCRF] If it's not a valid level ID, load blank actor data
	ld   a, [sLevelId]
	cp   a, LVL_LASTVALID + 1
	jr   nc, Level_Unused_LoadDefaultActLayout
	;--
	
	; Index the actor layout ptr table
	ld   d, $00
	ld   e, a		; DE = sLevelId * 2
	sla  e
	rl   d
	add  hl, de		
	
	; HL = Ptr to actor layout data
	ldi  a, [hl]	
	ld   h, [hl]
	ld   l, a
	
	;
	; LOOP 1: Copy over the actor data in the correct position
	;                                         (skipping the required amount of bytes)
	;
	
	ld   de, sActLayout			; DE = destination
.actorCopyLoop:
	;--
	; BYTE 0: Actor ID pair
	ldi  a, [hl]			; Copy the actor ID byte over
	ld   [de], a
	inc  de
	; If we reached the level layout data, we're done
	ld   a, d
	cp   a, HIGH(wLevelLayout)	
	jr   nc, .endCopyLoop
	
	;--
	; BYTE 1: bytes to skip between the current and next actor pair
	ldi  a, [hl]			; Get the skip count
	or   a					
	jr   z, .actorCopyLoop	; If it's 0, ignore
	
	; Otherwise write $00 the specified amount of times
	ld   b, a
.clearLoop:
	ld   a, $00				; No actor ID in this point (since it's being skipped)
	ld   [de], a
	inc  de
	
	; If we reached the level layout data, we're done
	ld   a, d
	cp   a, HIGH(wLevelLayout)	
	jr   nc, .endCopyLoop
	
	dec  b					; Are we done with the blank copy loop?
	jr   nz, .clearLoop		; If not, loop
	;--
	jr   .actorCopyLoop		; Otherwise read the next actor ID pair
	
	;
	; LOOP 2: Mark in the level layout data the actor locations (for convenience).
	;
.endCopyLoop:
	ld   de, sActLayout
	ld   hl, wLevelLayout
.actorMarkLoop:
	ld   a, [de]		; B = Actor IDs
	inc  de
	
	; Each byte stores 2 individual Actor IDs
	
	; HIGH NYBBLE (left block)
	ld   b, a		
	and  a, $F0			; Is there an actor ID in the high nybble?
	jr   z, .noMarkHigh	; If not, jump
	set  7, [hl]		; If so, mark the block
.noMarkHigh:
	inc  hl
	
	; LOW NYBBLE (right block)
	ld   a, b
	and  a, $0F			; Is there an actor ID in the high nybble?
	jr   z, .noMarkLow
	set  7, [hl]
.noMarkLow:
	inc  hl
	
	; If we reached the level layout data as source ptr, we're done
	ld   a, d
	cp   a, HIGH(wLevelLayout)	
	jr   c, .actorMarkLoop
	ret
	
; =============== ActS_InitGroup ===============
; Initializes all actors in the current actor group.
; IN:
; - BC: Ptr to actor group GFX list
ActS_InitGroup:
	call ActS_CopyGroupGFX
	call ActS_CreateTileBaseIndexTable
	
	; Use the same BG priority flag as the player
	ld   a, [sPlFlags]
	and  a, $80
	ld   [sActFlags], a
	
	; Init variables
	xor  a
	ld   [sLvlSpecClear], a
	ld   [sActHeldTreasure], a
	ld   [sLvlClearOnDeath], a
	ld   [sActBossParallaxFlashTimer], a
	ld   [sActBigItemBoxType], a
	ld   [sActLampEndingOk], a
	ld   a, $FF						; Disable transpacency effect
	ld   [sActSlotTransparent], a
	
	; Save back the updated locations of all active actors
	; (if we're in a room transition -- during level load there are none loaded)
	mSubCall ActS_SaveAllPos ; BANK $02
	
	mSubCall ActS_ClearRAM ; BANK $02
	
	; Blank respawn type table
	ld   hl, sActRespawnTypeTbl
	xor  a
REPT 7
	ldi  [hl], a
ENDR
	; Held actors
	ld   a, [sActHeld]
	or   a
	call nz, .checkHeldId

	; Initialize
	
	; [POI] Could have done "call HomeCall_Unused_ActS_InitScreenActors"
	mSubCall ActS_InitScreenActors ; BANK $02
	
	ld   a, $01						; [TCRF] Mark actor loading as done
	ld   [sAct_Unused_InitDone], a
	ret
.checkHeldId:
	; Don't allow holding non-default actors through rooms
	; as the ID doesn't point to the same
	ld   a, [sActHeldId]
	cp   a, ACT_DEFAULT_BASE
	jr   nc, .transferHeld
	
	; If not a default actor, remove the held status
	xor  a
	ld   [sActHeld], a
	ld   [sActHeldKey], a
	ret
.transferHeld:
	; [POI] Seemingly indexes the OBJLst bank table..., but DE is always $00 after the call to ActS_ClearRAM.
	; So sActOBJLstBank = $0F
	; Which is correct anyway, since the held actor is always the first one.
	ld   a, $0F
	;--
	push hl
	ld   hl, sActOBJLstBank
	ld   d, $00
	add  hl, de
	ld   [hl], a
	pop  hl
	;--
	
	; Immediately write the actor data for what we're holding
	; We're doing this after removing all actors, so the first slot is always empty.
	ld   hl, sAct
	ld   a, $02			; Status
	ldi  [hl], a			
	ld   a, [sPlX_Low]	; 01
	ldi  [hl], a			
	ld   a, [sPlX_High]	; 02
	ldi  [hl], a			
	ld   a, [sPlY_Low]	; 03
	ldi  [hl], a			
	ld   a, [sPlY_High]	; 04
	ldi  [hl], a			
	ld   a, [sActHeldColiType]	; Coli type
	ldi  [hl], a
	ld   a, -$0C				; Coli box U
	ldi  [hl], a
	ld   a, -$04				; Coli box D
	ldi  [hl], a
	ld   a, -$06				; Coli box L
	ldi  [hl], a
	ld   a, +$06				; Coli box R
	ldi  [hl], a
	
	; Ignore relative coords
	xor  a					
	ldi  [hl], a			; Rel.Y (Origin)
	ldi  [hl], a			; Rel.X (Origin)
	
	ld   a, [sActHeldOBJLstTablePtr_Low]	; OBJLst Table
	ldi  [hl], a
	ld   a, [sActHeldOBJLstTablePtr_High]	
	ldi  [hl], a
	
	; Ignore direction and anim frame
	xor  a
	ldi  [hl], a			; Dir
	ldi  [hl], a			; OBJLst ID
	
	ld   a, [sActHeldId]	; Actor ID
	ldi  [hl], a
	
	xor  a					; Routine ID
	ldi  [hl], a
	
	; Code for held actors
	ld   a, LOW(SubCall_ActS_Held)	; Code Ptr
	ldi  [hl], a
	ld   a, HIGH(SubCall_ActS_Held)	
	ldi  [hl], a
	
	; Timer
	ld   a, $0C				; Timer
	ldi  [hl], a
	
	xor  a
	ldi  [hl], a			; Timer 2
	ldi  [hl], a			; Y Speed
	ldi  [hl], a			; Timer 4
	ldi  [hl], a			; Timer 5
	ldi  [hl], a			; Timer 6
	ldi  [hl], a			; Timer 7
	
	ld   a, $01				; Flags
	ldi  [hl], a
	
	; Assign a dummy (otherwise unused) address for the level layout ptr
	; since this doesn't have a normal position assigned to it
	ld   a, LOW(sActDummyBlock)		
	ldi  [hl], a
	ld   a, HIGH(sActDummyBlock)	
	ldi  [hl], a
	
	; Set shared table ptr
	; [BUG] This doesn't account that you can also hold a key.
	;		So entering a door while holding a key, then dropping it (*not* throwing it),
	;		will make it look like a coin until it lands on the ground.
	;
	;		To make the key drop, you can:
	;		- Hold a bomb while holding a key. You can hold both at once (itself a bug),
	;		  and once it explodes, it drops anything you're holding.
	;		- Ending a level while holding the key (including bosses)
	;
	;		Though this can only be triggered if the key isn't thrown -- picking
	;		the key up corrects this problem.
IF FIX_BUGS == 1 
	ld   a, [sActHeldId]
	cp   a, ACT_KEY			; Are we holding a key?
	jr   z, .keyObj			; If so, jump
.coinObj:
	ld   a, LOW(OBJLstSharedPtrTable_Act_10Coin)
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_10Coin)
	ldi  [hl], a
	jr   .end
.keyObj:
	ld   a, LOW(OBJLstSharedPtrTable_Act_Key)
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_Key)
	ldi  [hl], a
ELSE
	ld   a, LOW(OBJLstSharedPtrTable_Act_10Coin)
	ldi  [hl], a
	ld   a, HIGH(OBJLstSharedPtrTable_Act_10Coin)
	ldi  [hl], a
ENDC
	
.end:
	ld   a, $01
	ld   [sActHeld], a
	ret
	
; =============== Unused_B07_InfiniteLoop ===============
; [TCRF] Unreferenced infinite loop; possible part of an "assert" type handler.
Unused_B07_InfiniteLoop:
	jr Unused_B07_InfiniteLoop
	ret

; =============== ActS_CreateTileBaseIndexTable ===============
; Generates a table of indexes ($00-$06) to sActTileBaseTbl.
; Instead of directly indexing sActTileBaseIndexTbl, the index is indexed from here.
;
; The values generated here are the same as the index used to index the table.
ActS_CreateTileBaseIndexTable:
	ld   hl, sActTileBaseIndexTbl
	xor  a
	ldi  [hl], a
REPT 5
	inc  a
	ldi  [hl], a
ENDR
	ret
	
GFX_Act_StunStar: INCBIN "data/gfx/actor/star.bin"
.end:
; =============== Level_ActLayoutPtrTable ===============
; This table contains pointers to the actor layout.
;
; ACTOR LAYOUT FORMAT
; Each ActLayout is a list of 2 byte entries:
; - Actor IDs
;   Since actor IDs are in range $0-$F, this actually stores 2 actor IDs,
;   which allows the area in memory to take half the space of the level layout area.
;   Given two blocks in the level layout:
;   - the high nybble assigns the actor ID to the left block
;   - the low nybble assigns the actor ID to the right block
; - Skip Count
;   The amount of bytes to skip before writing the next Actor ID
;   Since a single byte can set 2 blocks, for any skipped byte the next actor is moved 2 blocks to the right.
;   
; "Skipped bytes" refers to what's written to $B000-$BFFF, which is the area of RAM reserved for Actor IDs.
Level_ActLayoutPtrTable: 
	dw ActLayout_C26 
	dw ActLayout_C33 
	dw ActLayout_C15 
	dw ActLayout_C20 
	dw ActLayout_C16 
	dw ActLayout_C10 
	dw ActLayout_C07 
	dw ActLayout_C01A
	dw ActLayout_C17 
	dw ActLayout_C12 
	dw ActLayout_C13 
	dw ActLayout_C29 
	dw ActLayout_C04 
	dw ActLayout_C09 
	dw ActLayout_C03A
	dw ActLayout_C02 
	dw ActLayout_C08 
	dw ActLayout_C11 
	dw ActLayout_C35 
	dw ActLayout_C34 
	dw ActLayout_C30 
	dw ActLayout_C21 
	dw ActLayout_C22 
	dw ActLayout_C01B
	dw ActLayout_C19 
	dw ActLayout_C05 
	dw ActLayout_C36 
	dw ActLayout_C24 
	dw ActLayout_C25 
	dw ActLayout_C32 
	dw ActLayout_C27 
	dw ActLayout_C28 
	dw ActLayout_C18 
	dw ActLayout_C14 
	dw ActLayout_C38 
	dw ActLayout_C39 
	dw ActLayout_C03B
	dw ActLayout_C37 
	dw ActLayout_C31A
	dw ActLayout_C23 
	dw ActLayout_C40 
	dw ActLayout_C06 
	dw ActLayout_C31B

; =============== ACTOR GROUP DEFINITIONS ===============
; Each actor group contains code to initialize actors.
; The common code to initialize actors is in the mActGroup macro,
; which loads the actor GFX and sets up the code pointers.
; Additional shared options in the form of macros are provided below. (or room-specific code).

; =============== mActGroup ===============
; Sets up the code/graphics for an actor group in a room.
;
; It sets up the following:
;
; ActGroupCodeDef (4 bytes)
; -0-1: Ptr to code
; -  2: Actor flags (ACTFLAGB_*)
; -  3: Bank number for OBJLst
;
; ActGroupGFXDef (4 bytes; shortneded through mActGFXDef)
; -  0: Bank number for GFX
; -1-2: Ptr to GFX
; -  3: Tile count
;
; IN
; - 1: Room identifier
mActGroup: MACRO
	ld   a, LOW(ActGroupCodeDef_\1)	; ActorID -> CodePtr Table
	ld   [sActGroupCodePtrTable], a
	ld   a, HIGH(ActGroupCodeDef_\1)
	ld   [sActGroupCodePtrTable+1], a
	ld   bc,ActGroupGFXDef_\1		; ActorID -> GFXPtr Table
	call ActS_InitGroup	
ENDM

; =============== mActGroup_Treasure ===============
; Sets the treasure associated with the room, without checking if it's already collected.
; Sometimes this is used instead of mActGroup_CheckTreasure only for treasure rooms...
; which doesn't make any difference at the end, since the treasure check if handled differently there.
; IN
; - 1: Treasure ID
mActGroup_Treasure: MACRO
	ld   a, \1
	ld   [sActTreasureId], a
ENDM

; =============== mActGroup_CheckTreasure ===============
; Sets the treasure associated with the room
; and performs the treasure check room to check a key or treasure door.
; IN
; - 1: Treasure ID
mActGroup_CheckTreasure: MACRO
	mActGroup_Treasure \1
	call Level_CheckTreasureStatus
ENDM

; =============== mActGroup_OpenExit ===============
; Option for a room to have the exit door automatically opened.
mActGroup_OpenExit: MACRO
	ld   a, LOCK_OPEN
	ld   [sLvlExitDoor], a
ENDM

; =============== mActGroup_BigItem ===============
; Option for specifying the contents of a big item box.
; IN
; - 1: Item type
mActGroup_BigItem: MACRO
	ld   a, \1
	ld   [sActBigItemBoxType], a
ENDM

; =============== mActGroup_CheckBoss ===============
; Checks if the specified boss level has already been cleared.
; If so, no actors will be spawned and the level clear flag is set.
; IN
; - 1: Ptr to map completion bitmask
; - 2: Level number
mActGroup_CheckBoss: MACRO
	ld   a, [\1]					; Is the boss already completed?
	bit  \2, a
	jp   nz, Level_AutoClearBoss	; If so, jump
ENDM

INCLUDE "data/lvl/c26/actor_group_init.asm"

; =============== Level_CheckTreasureStatusStatus ===============
; Automatically opens the treasure door if the treasure has been already collected.
; This will also prevent the key from spawning.
; Used when loading a room containing either a key or a treasure door.
Level_CheckTreasureStatus:

	; Index the table of completion bitmasks
	ld   a, [sActTreasureId]
	ld   hl, Level_TreasureCompletionMask
	ld   d, $00		; DE = TreasureId * 2
	add  a
	ld   e, a
	add  hl, de
	
	; BC = Bitmask for this treasure
	ldi  a, [hl]	
	ld   c, a
	ld   b, [hl]
	
	; Did we collect this treasure already?
	ld   a, [sTreasures]
	and  a, c
	ld   c, a
	ld   a, [sTreasures+1]
	and  a, b
	or   a, c
	ret  z	; If not, return
	
	; Otherwise, mark the door as already open 
	; and prevent the key from spawning
	ld   a, $02
	ld   [sLvlTreasureDoor], a
	ret
	
; =============== Level_TreasureCompletionMask ===============
; Table with sTreasures bitmasks, indexed by treasure id.
; Use to check of a treasure was collected.
; A copy of this exists in BANK $0F as Level_TreasureCompletionMask_B0F.
Level_TreasureCompletionMask:
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

INCLUDE "data/lvl/c33/actor_group_init.asm"
INCLUDE "data/lvl/c15/actor_group_init.asm"
INCLUDE "data/lvl/c20/actor_group_init.asm"
INCLUDE "data/lvl/c16/actor_group_init.asm"
INCLUDE "data/lvl/c10/actor_group_init.asm"
INCLUDE "data/lvl/c07/actor_group_init.asm"
INCLUDE "data/lvl/c01a/actor_group_init.asm"
INCLUDE "data/lvl/c17/actor_group_init.asm"
INCLUDE "data/lvl/c12/actor_group_init.asm"
INCLUDE "data/lvl/c13/actor_group_init.asm"
INCLUDE "data/lvl/c29/actor_group_init.asm"
INCLUDE "data/lvl/c04/actor_group_init.asm"
INCLUDE "data/lvl/c09/actor_group_init.asm"
INCLUDE "data/lvl/c03a/actor_group_init.asm"
INCLUDE "data/lvl/c02/actor_group_init.asm"
INCLUDE "data/lvl/c08/actor_group_init.asm"
INCLUDE "data/lvl/c11/actor_group_init.asm"
INCLUDE "data/lvl/c35/actor_group_init.asm"
INCLUDE "data/lvl/c34/actor_group_init.asm"
INCLUDE "data/lvl/c30/actor_group_init.asm"
INCLUDE "data/lvl/c21/actor_group_init.asm"
INCLUDE "data/lvl/c22/actor_group_init.asm"
INCLUDE "data/lvl/c01b/actor_group_init.asm"
INCLUDE "data/lvl/c19/actor_group_init.asm"
INCLUDE "data/lvl/c05/actor_group_init.asm"

; =============== Level_AutoClearBoss ===============
; Called to end the level when reaching the boss room on an already cleared level.
Level_AutoClearBoss:
	ld   a, LVLCLEAR_BOSS		; Force the level clear with the "boss cleared" music.
	ld   [sLvlSpecClear], a
	ld   a, $01					; [TCRF] Not read or set anywhere else
	ld   [sUnused_BossAlreadyDead], a
	ret

INCLUDE "data/lvl/c36/actor_group_init.asm"
INCLUDE "data/lvl/c24/actor_group_init.asm"
INCLUDE "data/lvl/c25/actor_group_init.asm"
INCLUDE "data/lvl/c32/actor_group_init.asm"
INCLUDE "data/lvl/c27/actor_group_init.asm"
INCLUDE "data/lvl/c28/actor_group_init.asm"
INCLUDE "data/lvl/c18/actor_group_init.asm"
INCLUDE "data/lvl/c14/actor_group_init.asm"
INCLUDE "data/lvl/c38/actor_group_init.asm"
INCLUDE "data/lvl/c39/actor_group_init.asm"
INCLUDE "data/lvl/c03b/actor_group_init.asm"
INCLUDE "data/lvl/c37/actor_group_init.asm"
INCLUDE "data/lvl/c31a/actor_group_init.asm"
INCLUDE "data/lvl/c23/actor_group_init.asm"
INCLUDE "data/lvl/c40/actor_group_init.asm"
INCLUDE "data/lvl/c06/actor_group_init.asm"
INCLUDE "data/lvl/c31b/actor_group_init.asm"
	
; =============== Actor Init Code Definitions ===============
; Defines the (initial) code an actor ID executes, before said
; init code replaces its pointers to the main code, if needed.
; All code pointers point to Bank $02 or Bank $00.

; [TCRF] Blank dummy object; Not meant to be used.
ActCodeDef_Null:
	mActCodeDef Act_Null, $02, $0F
ActCodeDef_Goom:
	mActCodeDefAuto ActInit_Goom, $00
ActCodeDef_Spark:
	mActCodeDefAuto ActInit_Spark, $00
ActCodeDef_BigFruit:
	mActCodeDefAuto ActInit_BigFruit, ACTFLAG_HEAVY|ACTFLAG_NORECOVER
ActCodeDef_SpikeBall:
	mActCodeDefAuto ActInit_SpikeBall, ACTFLAG_HEAVY|ACTFLAG_NORECOVER
ActCodeDef_SpearGoom:
	mActCodeDefAuto ActInit_SpearGoom, $00
ActCodeDef_Helmut:
	mActCodeDefAuto ActInit_Helmut, $00
ActCodeDef_SSTeacupBoss:
	mActCodeDefAuto ActInit_SSTeacupBoss, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_BigCoin:
	mActCodeDefAuto ActInit_BigCoin, $00
ActCodeDef_PouncerDrop:
	mActCodeDefAuto ActInit_PouncerDrop, $00
ActCodeDef_PouncerFollow:
	mActCodeDefAuto ActInit_PouncerFollow, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_Driller:
	mActCodeDefAuto ActInit_Driller, ACTFLAG_NORECOVER
ActCodeDef_Puff:
	mActCodeDefAuto ActInit_Puff, $00
ActCodeDef_LavaBubble:
	mActCodeDefAuto ActInit_LavaBubble, $00
ActCodeDef_DoorFrame:
	mActCodeDefAuto ActInit_DoorFrame, $00
ActCodeDef_CoinLock:
	mActCodeDefAuto ActInit_CoinLock, $00
ActCodeDef_CartTrain:
	mActCodeDefAuto ActInit_CartTrain, $00
ActCodeDef_Cart:
	mActCodeDefAuto ActInit_Cart, $00
ActCodeDef_Wolf:
	mActCodeDefAuto ActInit_Wolf, ACTFLAG_HEAVY
ActCodeDef_Penguin:
	mActCodeDefAuto ActInit_Penguin, ACTFLAG_HEAVY
ActCodeDef_DD:
	mActCodeDefAuto ActInit_DD, ACTFLAG_HEAVY
ActCodeDef_Checkpoint:
	mActCodeDefAuto ActInit_Checkpoint, $00
ActCodeDef_TreasureChestLid:
	mActCodeDefAuto ActInit_TreasureChestLid, $00
ActCodeDef_TorchFlame:
	mActCodeDefAuto ActInit_TorchFlame, $00
ActCodeDef_Treasure:
	mActCodeDefAuto ActInit_Treasure, $00
ActCodeDef_TreasureShine:
	mActCodeDefAuto ActInit_TreasureShine, $00
ActCodeDef_SSTeacupBossWatch:
	mActCodeDefAuto ActInit_SSTeacupBossWatch, ACTFLAG_NORECOVER
ActCodeDef_Watch:
	mActCodeDefAuto ActInit_Watch, ACTFLAG_NORECOVER
ActCodeDef_ChickenDuck:
	mActCodeDefAuto ActInit_ChickenDuck, $00
ActCodeDef_MtTeapotBoss:
	mActCodeDefAuto ActInit_MtTeapotBoss, ACTFLAG_HEAVY|ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_SherbetLandBoss:
	mActCodeDefAuto ActInit_SherbetLandBoss, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_RiceBeachBoss:
	mActCodeDefAuto ActInit_RiceBeachBoss, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_ParsleyWoodsBoss:
	mActCodeDefAuto ActInit_ParsleyWoodsBoss, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_ParsleyWoodsBossGhostGoom:
	mActCodeDefAuto ActInit_ParsleyWoodsBossGhostGoom, $00
ActCodeDef_StoveCanyonBoss:
	mActCodeDefAuto ActInit_StoveCanyonBoss, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_StoveCanyonBossEyes:
	mActCodeDefAuto ActInit_StoveCanyonBossEyes, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_StoveCanyonBossTongue:
	mActCodeDefAuto ActInit_StoveCanyonBossTongue, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_StoveCanyonBossBall:
	mActCodeDefAuto ActInit_Unused_StoveCanyonBossBall, ACTFLAG_NORECOVER
ActCodeDef_Floater:
	mActCodeDefAuto ActInit_Floater, $00
ActCodeDef_KeyLock:
	mActCodeDefAuto ActInit_KeyLock, $00
ActCodeDef_Bridge:
	mActCodeDefAuto ActInit_Bridge, ACTFLAG_NORECOVER
ActCodeDef_Snowman:
	mActCodeDefAuto ActInit_Snowman, $00
ActCodeDef_BigSwitchBlock:
	mActCodeDefAuto ActInit_BigSwitchBlock, $00
ActCodeDef_LavaWall:
	mActCodeDefAuto ActInit_LavaWall, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_SyrupCastlePlatformU:
	mActCodeDefAuto ActInit_SyrupCastlePlatformU, $00
ActCodeDef_SyrupCastlePlatformD:
	mActCodeDefAuto ActInit_SyrupCastlePlatformD, $00
ActCodeDef_HermitCrab:
	mActCodeDefAuto ActInit_HermitCrab, $00
ActCodeDef_GhostGoom:
	mActCodeDefAuto ActInit_GhostGoom, $00
ActCodeDef_Seahorse:
	mActCodeDefAuto ActInit_Seahorse, $00
ActCodeDef_BigItemBox:
	mActCodeDefAuto ActInit_BigItemBox, $00
ActCodeDef_Bomb:
	mActCodeDefAuto ActInit_Bomb, $00
ActCodeDef_CaptainSyrup:
	mActCodeDefAuto ActInit_SyrupCastleBoss, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_Lamp:
	mActCodeDefAuto ActInit_Lamp, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_LampSmoke:
	mActCodeDefAuto ActInit_LampSmoke, ACTFLAG_UNUSED_NOBUMPKILL
; [TCRF] Not used directly
ActCodeDef_MiniGenie:
	mActCodeDefAuto ActInit_Unused_MiniGenie, ACTFLAG_UNUSED_NOBUMPKILL
ActCodeDef_Pelican:
	mActCodeDefAuto ActInit_Pelican, $00
ActCodeDef_SpikePillarR:
	mActCodeDefAuto ActInit_SpikePillarR, ACTFLAG_NORECOVER
ActCodeDef_SpikePillarL:
	mActCodeDefAuto ActInit_SpikePillarL, ACTFLAG_NORECOVER
ActCodeDef_SpikePillarU:
	mActCodeDefAuto ActInit_SpikePillarU, ACTFLAG_NORECOVER
ActCodeDef_SpikePillarD:
	mActCodeDefAuto ActInit_SpikePillarD, ACTFLAG_NORECOVER
ActCodeDef_CoinCrab:
	mActCodeDefAuto ActInit_CoinCrab, ACTFLAG_NORECOVER
ActCodeDef_StoveCanyonPlatform:
	mActCodeDefAuto ActInit_StoveCanyonPlatform, $00
ActCodeDef_Togemaru:
	mActCodeDefAuto ActInit_Togemaru, $00
ActCodeDef_ThunderCloud:
	mActCodeDefAuto ActInit_ThunderCloud, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_Mole:
	mActCodeDefAuto ActInit_Mole, ACTFLAG_HEAVY
ActCodeDef_MoleSpike:
	mActCodeDefAuto ActInit_Unused_MoleSpike, $00
ActCodeDef_Croc:
	mActCodeDefAuto ActInit_Croc, $00
ActCodeDef_Seal:
	mActCodeDefAuto ActInit_Seal, $00
ActCodeDef_BigHeart:
	mActCodeDefAuto ActInit_BigHeart, $00
ActCodeDef_Spider:
	mActCodeDefAuto ActInit_Spider, $00
ActCodeDef_Hedgehog:
	mActCodeDefAuto ActInit_Hedgehog, $00
ActCodeDef_MoleCutscene:
	mActCodeDefAuto ActInit_MoleCutscene, $00
ActCodeDef_FireMissile:
	mActCodeDefAuto ActInit_FireMissile, $00
ActCodeDef_StickBomb:
	mActCodeDefAuto ActInit_StickBomb, $00
ActCodeDef_Knight:
	mActCodeDefAuto ActInit_Knight, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_MiniBossLock:
	mActCodeDefAuto ActInit_MiniBossLock, ACTFLAG_NODESPAWNOFFSCREEN
ActCodeDef_Fly:
	mActCodeDefAuto ActInit_Fly, $00
ActCodeDef_ExitSkull:
	mActCodeDefAuto ActInit_ExitSkull, $00
ActCodeDef_Bat:
	mActCodeDefAuto ActInit_Bat, $00

; =============== ACTOR SLOTS - CODE DEFS ===============
; List of code tables for every room, indexed by actor id in the group.
;
; NOTES / WARNING / etc.
;
; ----
; You'll notice that the last entry (actor id $06) is always empty.
; A few special actors not defined in any actor group (which use the ACT_NORESPAWN flag),
; intentionally set their actor ID as $06 when spawned, since it's always assumed to be free.
; 
; Setting the sixth entry to anything but ActCodeDef_Null may cause these actors
; to not work properly (namely, when the actor ID is used to index something).
; ----
; When certain actors spawn others, and those actors are part of the actor group,
; there are some hardcoded assumptions about their order:
; - When ActCodeDef_TreasureChestLid is used, ActCodeDef_Treasure must be 2 slots after.
; - When ActCodeDef_SSTeacupBoss is used, ActCodeDef_SSTeacupBossWatch must be exactly after.
; - When Act_ParsleyWoodsBoss_SpawnGhostGoom spawns, Act_ParsleyWoodsBossGhostGoom must exist and have ID $02.
;   This requirement exists only because it checks the actor ID as part of the spawn limit to the amount of on-screen ghosts.
; - Act_ParsleyWoodsBossGhostGoom itself expects to se in slot $02, since it's initially set with the actor ID of a coin and it has to change back at some point.
; - Act_StoveCanyonBoss spawns Act_StoveCanyonBossBall with the actor ID $04.
; - Actors which spawn 3UP Hearts or 100-coins have to account for the spawned actor having the
;   ID set as <current actor>+1.
;   For example, the parent actor is generally a big item box, and assuming it's in slot $01, it requires
;   the spawned item to be in slot $02.
; - Act_Lamp expects Act_MiniGenie to be in slot $04.
; - Act_Pelican expects Act_Bomb to be in the slot after.
; - Act_Mole expects Act_MoleSpike to be in the slot after.
;
INCLUDE "data/lvl/c26/actor_slots_code.asm"
INCLUDE "data/lvl/c33/actor_slots_code.asm"
INCLUDE "data/lvl/c15/actor_slots_code.asm"
INCLUDE "data/lvl/c20/actor_slots_code.asm"
INCLUDE "data/lvl/c16/actor_slots_code.asm"
INCLUDE "data/lvl/c10/actor_slots_code.asm"
INCLUDE "data/lvl/c07/actor_slots_code.asm"
INCLUDE "data/lvl/c01a/actor_slots_code.asm"
INCLUDE "data/lvl/c17/actor_slots_code.asm"
INCLUDE "data/lvl/c12/actor_slots_code.asm"
INCLUDE "data/lvl/c13/actor_slots_code.asm"
INCLUDE "data/lvl/c29/actor_slots_code.asm"
INCLUDE "data/lvl/c04/actor_slots_code.asm"
INCLUDE "data/lvl/c09/actor_slots_code.asm"
INCLUDE "data/lvl/c03a/actor_slots_code.asm"
INCLUDE "data/lvl/c02/actor_slots_code.asm"
INCLUDE "data/lvl/c08/actor_slots_code.asm"
INCLUDE "data/lvl/c11/actor_slots_code.asm"
INCLUDE "data/lvl/c35/actor_slots_code.asm"
INCLUDE "data/lvl/c34/actor_slots_code.asm"
INCLUDE "data/lvl/c30/actor_slots_code.asm"
INCLUDE "data/lvl/c21/actor_slots_code.asm"
INCLUDE "data/lvl/c22/actor_slots_code.asm"
INCLUDE "data/lvl/c01b/actor_slots_code.asm"
INCLUDE "data/lvl/c19/actor_slots_code.asm"
INCLUDE "data/lvl/c05/actor_slots_code.asm"
INCLUDE "data/lvl/c36/actor_slots_code.asm"
INCLUDE "data/lvl/c24/actor_slots_code.asm"
INCLUDE "data/lvl/c25/actor_slots_code.asm"
INCLUDE "data/lvl/c32/actor_slots_code.asm"
INCLUDE "data/lvl/c27/actor_slots_code.asm"
INCLUDE "data/lvl/c28/actor_slots_code.asm"
INCLUDE "data/lvl/c18/actor_slots_code.asm"
INCLUDE "data/lvl/c14/actor_slots_code.asm"
INCLUDE "data/lvl/c38/actor_slots_code.asm"
INCLUDE "data/lvl/c39/actor_slots_code.asm"
INCLUDE "data/lvl/c03b/actor_slots_code.asm"
INCLUDE "data/lvl/c37/actor_slots_code.asm"
INCLUDE "data/lvl/c31a/actor_slots_code.asm"
INCLUDE "data/lvl/c23/actor_slots_code.asm"
INCLUDE "data/lvl/c40/actor_slots_code.asm"
INCLUDE "data/lvl/c06/actor_slots_code.asm"
INCLUDE "data/lvl/c31b/actor_slots_code.asm"

; Actor slot GFX definitions
; These associate the graphics to each of the actor slots.
; Must be in the same order of the actor code definitions.	
INCLUDE "data/lvl/c26/actor_slots_gfx.asm"
INCLUDE "data/lvl/c33/actor_slots_gfx.asm"
INCLUDE "data/lvl/c15/actor_slots_gfx.asm"
INCLUDE "data/lvl/c20/actor_slots_gfx.asm"
INCLUDE "data/lvl/c16/actor_slots_gfx.asm"
INCLUDE "data/lvl/c10/actor_slots_gfx.asm"
INCLUDE "data/lvl/c07/actor_slots_gfx.asm"
INCLUDE "data/lvl/c01a/actor_slots_gfx.asm"
INCLUDE "data/lvl/c17/actor_slots_gfx.asm"
INCLUDE "data/lvl/c12/actor_slots_gfx.asm"
INCLUDE "data/lvl/c13/actor_slots_gfx.asm"
INCLUDE "data/lvl/c29/actor_slots_gfx.asm"
INCLUDE "data/lvl/c04/actor_slots_gfx.asm"
INCLUDE "data/lvl/c09/actor_slots_gfx.asm"
INCLUDE "data/lvl/c03a/actor_slots_gfx.asm"
INCLUDE "data/lvl/c02/actor_slots_gfx.asm"
INCLUDE "data/lvl/c08/actor_slots_gfx.asm"
INCLUDE "data/lvl/c11/actor_slots_gfx.asm"
INCLUDE "data/lvl/c35/actor_slots_gfx.asm"
INCLUDE "data/lvl/c34/actor_slots_gfx.asm"
INCLUDE "data/lvl/c30/actor_slots_gfx.asm"
INCLUDE "data/lvl/c21/actor_slots_gfx.asm"
INCLUDE "data/lvl/c22/actor_slots_gfx.asm"
INCLUDE "data/lvl/c01b/actor_slots_gfx.asm"
INCLUDE "data/lvl/c19/actor_slots_gfx.asm"
INCLUDE "data/lvl/c05/actor_slots_gfx.asm"
INCLUDE "data/lvl/c36/actor_slots_gfx.asm"
INCLUDE "data/lvl/c24/actor_slots_gfx.asm"
INCLUDE "data/lvl/c25/actor_slots_gfx.asm"
INCLUDE "data/lvl/c32/actor_slots_gfx.asm"
INCLUDE "data/lvl/c27/actor_slots_gfx.asm"
INCLUDE "data/lvl/c28/actor_slots_gfx.asm"
INCLUDE "data/lvl/c18/actor_slots_gfx.asm"
INCLUDE "data/lvl/c14/actor_slots_gfx.asm"
INCLUDE "data/lvl/c38/actor_slots_gfx.asm"
INCLUDE "data/lvl/c39/actor_slots_gfx.asm"
INCLUDE "data/lvl/c03b/actor_slots_gfx.asm"
INCLUDE "data/lvl/c37/actor_slots_gfx.asm"
INCLUDE "data/lvl/c31a/actor_slots_gfx.asm"
INCLUDE "data/lvl/c23/actor_slots_gfx.asm"
INCLUDE "data/lvl/c40/actor_slots_gfx.asm"
INCLUDE "data/lvl/c06/actor_slots_gfx.asm"
INCLUDE "data/lvl/c31b/actor_slots_gfx.asm"

; =============== ActInit_SpearGoom ===============
ActInit_SpearGoom:
	; Setup collision box
	ld   a, -$0A
	ld   [sActSetColiBoxU], a
	ld   a, +$00
	ld   [sActSetColiBoxD], a
	ld   a, -$0C
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	
	; Setup main code
	ld   bc, SubCall_Act_SpearGoom
	call ActS_SetCodePtr
	
	; Set initial OBJLst
	push bc
	ld   bc, OBJLstPtrTable_ActInit_SpearGoom
	call ActS_SetOBJLstPtr
	pop  bc
	
	; Set OBJLst shared table
	ld   bc, OBJLstSharedPtrTable_Act_SpearGoom
	call ActS_SetOBJLstSharedTablePtr
	
	; [POI] By default, this is set as fully safe to touch, and it seems intentional,
	;		since there's an actual delay before the proper collision is set.
	;
	; The default subroutine for switching the actor's direction,
	; called here when it reaches the end of a solid platform, reloads the actor to its initial state.
	; This includes reloading the default collision type. 
	;
	; This is why the spear doesn't damage the player when the actor stands still.
	; (also, there's a delay applied in the loop code before the proper collision is set) 
	mActColiMask ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	mSubCall ActS_SaveColiType ; BANK $02
	xor  a
	ld   [sActSpearGoomColiDelay], a
	ret
OBJLstPtrTable_ActInit_SpearGoom: 
	dw OBJLst_Act_SpearGoom_WalkL0
	dw $0000;X
; =============== Act_SpearGoom ===============
Act_SpearGoom:
	; If the actor is overlapping with a solid block, kill it
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSolid
	or   a
	jp   nz, SubCall_ActS_StartJumpDead

	; Also reset to the default collision over and over.
	; The side which damages the player will be set elsewhere in Act_SpearGoom_Main.
	mActColiMask ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM,ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	; Do the routine table
	ld   a, [sActSetRoutineId]
	and  a, $0F
	rst  $28
	dw Act_SpearGoom_Main
	dw .onPlColiH
	dw .onPlColiTop
	dw SubCall_ActS_StartStarKill
	dw .onPlColiBelow
	dw SubCall_ActS_StartDashKill
	dw Act_SpearGoom_Main;X
	dw .onSwitchDir
	dw SubCall_ActS_StartJumpDeadSameColi
; NOTE: We're setting sActSpearGoomColiDelay for later, once we return to the main code.
;       (the address for it won't be overwritten in the called subroutines here)
.onPlColiH:
	ld   a, $14
	ld   [sActSpearGoomColiDelay], a
	jp   SubCall_ActS_OnPlColiH
.onPlColiTop:
	ld   a, $14
	ld   [sActSpearGoomColiDelay], a
	jp   SubCall_ActS_OnPlColiTop
.onPlColiBelow:
	ld   a, $14
	ld   [sActSpearGoomColiDelay], a
	jp   SubCall_ActS_OnPlColiBelow
.onSwitchDir:
	ld   a, $14
	ld   [sActSpearGoomColiDelay], a
	jp   SubCall_ActS_StartSwitchDir
; =============== Act_SpearGoom_Main ===============
Act_SpearGoom_Main:
	; If the collision delay timer is set, decrement it
	ld   a, [sActSpearGoomColiDelay]
	or   a							
	call nz, Act_SpearGoom_DecColiDelay				
	
	; If the screen is shaking, stun the actor
	ld   a, [sScreenShakeTimer]
	or   a
	jp   nz, SubCall_ActS_StartGroundPoundStun
	
	; If the actor is overlapping with a spike block, instakill it
	call ActColi_GetBlockId_Low
	mSubCall ActBGColi_IsSpikeBlock
	or   a
	jp   nz, SubCall_ActS_StartStarKill
	
	ld   a, [sActSetTimer]			; Timer++
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
	or   a							; Is the actor is inside a water block?
	jr   nz, .noWater				; If not, jump
;--
.water:
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop
	or   a							; Is the actor on solid ground?
	jr   nz, .water_chkAnim			; If so, skip
	
	; We don't need to perform any Y block alignment because of the 1px/frame speed
	
	ld   bc, +$01					; Otherwise, fall down at a fixed 1px/frame
	call ActS_MoveDown
.water_chkAnim:
	; Every alternating 2 frames call the anim subroutine.
	; Unlike the one in noWater, the actor doesn't move
	ld   a, [sActSetTimer]
	and  a, $02						; sActSetTimer % 2 == 0?
	jr   z, .chkTurnDelay			; If so, jump
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
	
	ld   a, [sActSpearGoomTurnDelay]
	or   a							; Is the turn delay set?
	jr   z, .anim					; If not, skip
	dec  a							; Otherwise, decrement it
	ld   [sActSpearGoomTurnDelay], a
	or   a							; Did it elapse?
	ret  nz							; If not, return
	call Act_SpearGoom_Turn			; Otherwise, turn to the other direction
.anim:
	call ActS_IncOBJLstIdEvery8
	
; Perform horizontal movement
Act_SpearGoom_SetMove:
	ld   a, [sActSetDir]
	bit  DIRB_R, a					; Is the actor facing right?
	jr   nz, .moveR					; If so, jump
.moveL:
	; Set sprite mapping
	ld   a, LOW(OBJLstPtrTable_Act_SpearGoom_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SpearGoom_WalkL)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Set left direction
	ld   a, [sActSetDir]
	and  a, $F8						; Clear all but what would be DIR_D
	or   a, DIR_L
	ld   [sActSetDir], a
	
	; [POI] Give a bit of leeway with updating the collision.
	; 		Set the left side as damaging only after the timer elapses.
	; This makes it possible to hit the actor through (what would be) the damaging part
	; if done very quickly after it turns.
	ld   a, [sActSpearGoomColiDelay]
	or   a						
	call z, Act_SpearGoom_SetColiL
	
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
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	
	; Move left 1px
	ld   bc, -$01
	call ActS_MoveRight
	
	; Set collision box
	ld   a, -$0C
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	ret
	
.moveR:
	; Set sprite mapping
	ld   a, LOW(OBJLstPtrTable_Act_SpearGoom_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, HIGH(OBJLstPtrTable_Act_SpearGoom_WalkR)
	ld   [sActSetOBJLstPtrTablePtr_High], a
	
	; Set right direction
	ld   a, [sActSetDir]
	and  a, $F8
	or   a, DIR_R
	ld   [sActSetDir], a
	
	; [POI] Give a bit of leeway with updating the collision.
	; 		Set the right side as damaging only after the timer elapses.
	ld   a, [sActSpearGoomColiDelay]
	or   a							
	call z, Act_SpearGoom_SetColiR					
	
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
	; Every other frame...
	ld   a, [sActSetTimer]
	and  a, $01
	ret  nz
	; Move right 1px
	ld   bc, +$01
	call ActS_MoveRight
	
	; Set collision box
	ld   a, -$08
	ld   [sActSetColiBoxL], a
	ld   a, +$0C
	ld   [sActSetColiBoxR], a
	ret
.setTurnDelay:
	ld   a, $1E
	ld   [sActSpearGoomTurnDelay], a
	ret
; =============== Act_SpearGoom_Turn ===============
; Makes the actor switch direction.
Act_SpearGoom_Turn:
	xor  a						; Reset anim frame
	ld   [sActSetOBJLstId], a
	ld   a, $14					; Wait $14 frames before setting the new collision (see below)
	ld   [sActSpearGoomColiDelay], a
	ld   a, [sActSetDir]		; Switch direction
	xor  DIR_L|DIR_R
	ld   [sActSetDir], a
	ret
; =============== Act_SpearGoom_SetColiL ===============
; Sets up the collision box when the actor is facing left, with the damaging side on the left.
Act_SpearGoom_SetColiL:
	;            R             L               U             D
	mActColiMask ACTCOLI_NORM, ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ld   a, -$0C
	ld   [sActSetColiBoxL], a
	ld   a, +$08
	ld   [sActSetColiBoxR], a
	ret
; =============== Act_SpearGoom_SetColiR ===============
; Sets up the collision box when the actor is facing right, with the damaging side on the right.
Act_SpearGoom_SetColiR:
	;            R               L             U             D
	mActColiMask ACTCOLI_DAMAGE, ACTCOLI_NORM, ACTCOLI_NORM, ACTCOLI_NORM
	ld   a, COLI
	ld   [sActSetColiType], a
	ld   a, $F8
	ld   [sActSetColiBoxL], a
	ld   a, $0C
	ld   [sActSetColiBoxR], a
	ret
; =============== Act_SpearGoom_DecColiDelay ===============
Act_SpearGoom_DecColiDelay:
	;--
	; [POI] We already check for this before calling this subroutine.
	ld   a, [sActSpearGoomColiDelay]
	or   a								
	ret  z
	;--
	dec  a
	ld   [sActSpearGoomColiDelay], a
	ret
OBJLstSharedPtrTable_Act_SpearGoom:
	dw OBJLstPtrTable_Act_SpearGoom_UnusedL;X
	dw OBJLstPtrTable_Act_SpearGoom_UnusedR;X
	dw OBJLstPtrTable_Act_SpearGoom_RestoreL
	dw OBJLstPtrTable_Act_SpearGoom_RestoreR
	dw OBJLstPtrTable_Act_SpearGoom_StunL
	dw OBJLstPtrTable_Act_SpearGoom_StunR
	dw OBJLstPtrTable_Act_SpearGoom_WalkL;X
	dw OBJLstPtrTable_Act_SpearGoom_WalkR;X
OBJLstPtrTable_Act_SpearGoom_UnusedL:
	dw OBJLst_Act_SpearGoom_WalkL1;X
	dw $0000;X
OBJLstPtrTable_Act_SpearGoom_UnusedR:
	dw OBJLst_Act_SpearGoom_WalkR1;X
	dw $0000;X
OBJLstPtrTable_Act_SpearGoom_RestoreL:
	dw OBJLst_Act_SpearGoom_StunL1
	dw OBJLst_Act_SpearGoom_WalkL1
	dw OBJLst_Act_SpearGoom_WalkL1
	dw $0000;X
OBJLstPtrTable_Act_SpearGoom_RestoreR:
	dw OBJLst_Act_SpearGoom_StunR1
	dw OBJLst_Act_SpearGoom_WalkR1
	dw OBJLst_Act_SpearGoom_WalkR1
	dw $0000;X
OBJLstPtrTable_Act_SpearGoom_StunL:
	dw OBJLst_Act_SpearGoom_StunL0
	dw OBJLst_Act_SpearGoom_StunL1
	dw OBJLst_Act_SpearGoom_StunL0
	dw OBJLst_Act_SpearGoom_StunL2
	dw $0000
OBJLstPtrTable_Act_SpearGoom_StunR:
	dw OBJLst_Act_SpearGoom_StunR0
	dw OBJLst_Act_SpearGoom_StunR1
	dw OBJLst_Act_SpearGoom_StunR0
	dw OBJLst_Act_SpearGoom_StunR2
	dw $0000
OBJLstPtrTable_Act_SpearGoom_WalkL:
	dw OBJLst_Act_SpearGoom_WalkL0
	dw OBJLst_Act_SpearGoom_WalkL1
	dw OBJLst_Act_SpearGoom_WalkL0
	dw OBJLst_Act_SpearGoom_WalkL2
	dw $0000
OBJLstPtrTable_Act_SpearGoom_WalkR:
	dw OBJLst_Act_SpearGoom_WalkR0
	dw OBJLst_Act_SpearGoom_WalkR1
	dw OBJLst_Act_SpearGoom_WalkR0
	dw OBJLst_Act_SpearGoom_WalkR2
	dw $0000
OBJLst_Act_SpearGoom_WalkL0: INCBIN "data/objlst/actor/speargoom_walkl0.bin"
OBJLst_Act_SpearGoom_WalkL1: INCBIN "data/objlst/actor/speargoom_walkl1.bin"
OBJLst_Act_SpearGoom_WalkL2: INCBIN "data/objlst/actor/speargoom_walkl2.bin"
OBJLst_Act_SpearGoom_StunL0: INCBIN "data/objlst/actor/speargoom_stunl0.bin"
OBJLst_Act_SpearGoom_StunL1: INCBIN "data/objlst/actor/speargoom_stunl1.bin"
OBJLst_Act_SpearGoom_StunL2: INCBIN "data/objlst/actor/speargoom_stunl2.bin"
OBJLst_Act_SpearGoom_Unused_StunAltL: INCBIN "data/objlst/actor/speargoom_unused_stunaltl.bin"
OBJLst_Act_SpearGoom_WalkR0: INCBIN "data/objlst/actor/speargoom_walkr0.bin"
OBJLst_Act_SpearGoom_WalkR1: INCBIN "data/objlst/actor/speargoom_walkr1.bin"
OBJLst_Act_SpearGoom_WalkR2: INCBIN "data/objlst/actor/speargoom_walkr2.bin"
OBJLst_Act_SpearGoom_StunR0: INCBIN "data/objlst/actor/speargoom_stunr0.bin"
OBJLst_Act_SpearGoom_StunR1: INCBIN "data/objlst/actor/speargoom_stunr1.bin"
OBJLst_Act_SpearGoom_StunR2: INCBIN "data/objlst/actor/speargoom_stunr2.bin"
OBJLst_Act_SpearGoom_Unused_StunAltR: INCBIN "data/objlst/actor/speargoom_unused_stunaltr.bin"
GFX_Act_SpearGoom: INCBIN "data/gfx/actor/speargoom.bin"
	mIncJunk "L076EB2"

ActLayout_C26: INCBIN "data/lvl/c26/actor_layout.bin"
ActLayout_C33: INCBIN "data/lvl/c33/actor_layout.bin"
ActLayout_C15: INCBIN "data/lvl/c15/actor_layout.bin"
ActLayout_C20: INCBIN "data/lvl/c20/actor_layout.bin"
ActLayout_C16: INCBIN "data/lvl/c16/actor_layout.bin"
ActLayout_C10: INCBIN "data/lvl/c10/actor_layout.bin"
ActLayout_C07: INCBIN "data/lvl/c07/actor_layout.bin"
ActLayout_C01A: INCBIN "data/lvl/c01a/actor_layout.bin"
ActLayout_C17: INCBIN "data/lvl/c17/actor_layout.bin"
ActLayout_C12: INCBIN "data/lvl/c12/actor_layout.bin"
ActLayout_C13: INCBIN "data/lvl/c13/actor_layout.bin"
ActLayout_C29: INCBIN "data/lvl/c29/actor_layout.bin"
ActLayout_C04: INCBIN "data/lvl/c04/actor_layout.bin"
ActLayout_C09: INCBIN "data/lvl/c09/actor_layout.bin"
ActLayout_C03A: INCBIN "data/lvl/c03a/actor_layout.bin"
ActLayout_C02: INCBIN "data/lvl/c02/actor_layout.bin"
ActLayout_C08: INCBIN "data/lvl/c08/actor_layout.bin"
ActLayout_C11: INCBIN "data/lvl/c11/actor_layout.bin"
ActLayout_C35: INCBIN "data/lvl/c35/actor_layout.bin"
ActLayout_C34: INCBIN "data/lvl/c34/actor_layout.bin"
ActLayout_C30: INCBIN "data/lvl/c30/actor_layout.bin"
ActLayout_C21: INCBIN "data/lvl/c21/actor_layout.bin"
ActLayout_C22: INCBIN "data/lvl/c22/actor_layout.bin"
ActLayout_C01B: INCBIN "data/lvl/c01b/actor_layout.bin"
ActLayout_C19: INCBIN "data/lvl/c19/actor_layout.bin"
ActLayout_C05: INCBIN "data/lvl/c05/actor_layout.bin"
ActLayout_C36: INCBIN "data/lvl/c36/actor_layout.bin"
ActLayout_C24: INCBIN "data/lvl/c24/actor_layout.bin"
ActLayout_C25: INCBIN "data/lvl/c25/actor_layout.bin"
ActLayout_C32: INCBIN "data/lvl/c32/actor_layout.bin"
ActLayout_C27: INCBIN "data/lvl/c27/actor_layout.bin"
ActLayout_C28: INCBIN "data/lvl/c28/actor_layout.bin"
ActLayout_C18: INCBIN "data/lvl/c18/actor_layout.bin"
ActLayout_C14: INCBIN "data/lvl/c14/actor_layout.bin"
ActLayout_C38: INCBIN "data/lvl/c38/actor_layout.bin"
ActLayout_C39: INCBIN "data/lvl/c39/actor_layout.bin"
ActLayout_C03B: INCBIN "data/lvl/c03b/actor_layout.bin"
ActLayout_C37: INCBIN "data/lvl/c37/actor_layout.bin"
ActLayout_C31A: INCBIN "data/lvl/c31a/actor_layout.bin"
ActLayout_C23: INCBIN "data/lvl/c23/actor_layout.bin"
ActLayout_C40: INCBIN "data/lvl/c40/actor_layout.bin"
ActLayout_C06: INCBIN "data/lvl/c06/actor_layout.bin"
ActLayout_C31B: INCBIN "data/lvl/c31b/actor_layout.bin"

; =============== END OF BANK ===============
	mIncJunk "L077F66"
