; =============== mHomeCall ===============
; This macro generates code to perform a bankswitch, then jump to the code the label points to.
; After it's done, the previous bank is restored.
; For obvious reasons, the code should only be placed in bank 00.
;
; IN
; - 1: A label from a bank != 0.
;
mHomeCall: MACRO
	; Save currently loaded bank
	ld a, [sROMBank]
	push af
	
	ld a, BANK(\1) 			; Calculate the bank the label points to
	ld [sROMBank], a		; Save it
	ld [MBC1RomBank], a		; Perform the bankswitch
	call \1
	
	; Restore the previous bank
	pop af
	ld [sROMBank], a
	ld [MBC1RomBank], a
ENDM

; Commonly used in bank00
mHomeCallRet: MACRO
	mHomeCall \1
	ret
ENDM

;mImport: MACRO
;HomeCall_\1: mHomeCall \1
;	ret
;ENDM

; =============== mSubCall ===============
; This macro generates code to call the SubCall subroutine
; to execute the specified routine.
;
; IN
; - 1: A label from a bank != 0.
;
mSubCall: MACRO
	ld   d, BANK(\1)
	ld   hl, \1
	call SubCall
ENDM

; Shorthand for subroutines which call SubCall and return
mSubCallRet: MACRO
	mSubCall \1
	ret
ENDM

;mSubImport: MACRO
;SubCall_\1: mSubCall \1
;	ret
;ENDM

; =============== mWaitHBlankEnd ===============
; Waits for the current HBlank to finish, if we're in one.
mWaitForHBlankEnd: MACRO
.waitHBlankEnd_\@:
	ldh  a, [rSTAT]
	and  a, $03
	jr   z, .waitHBlankEnd_\@
ENDM
; =============== mWaitHBlank ===============
; Waits for the HBlank period.
mWaitForHBlank: MACRO
.waitHBlank_\@:
	ldh  a, [rSTAT]
	and  a, $03
	jr   nz, .waitHBlank_\@
ENDM
; =============== mWaitForNewHBlank ===============
; Waits for the start of a new HBlank period.
mWaitForNewHBlank: MACRO
	; If we're in HBlank already, wait for it to finish
	mWaitForHBlankEnd
	; Then wait for the HBlank proper
	mWaitForHBlank
ENDM


; =============== mIncludeMultiInt ===============
; Shorthand for including Overworld animated GFX
mIncludeMultiInt: MACRO
	mIncludeMultiIntCust \1, 8, 8
ENDM

; =============== mIncludeMultiInt6 ===============
; Shorthand for including Rice Beach animated GFX
mIncludeMultiInt6: MACRO
	mIncludeMultiIntCust \1, 6, 8
ENDM

; =============== mIncludeMultiIntCust ===============
; This macro includes a "multi interleaved" graphic, where
; the first byte of all frames are stored first,
; then the second byte of all frames, etc...
;
; IN
; - 1: The file to include
; - 2: Number of frames in the graphic
; - 3: Size of each frame in bytes
mIncludeMultiIntCust: MACRO
I = 0
REPT \3
J = 0
	REPT \2 
		INCBIN \1,I+J,1
J = J + \3
	ENDR
I = I + 1
ENDR
ENDM

; Not applicable. The 32 byte area isn't always empty.
;; =============== mIncludeLevelLayout ===============
;; This macro includes level layout data.
;; This also generates the requires 32 byte $FF area before the layout proper.
;;
;; IN
;; - 1: The file to include
;mIncludeLevelLayout: MACRO
;REPT 32
;	db $FF
;ENDR
;	INCBIN \1
;ENDM

; =============== dwb ===============
; Shorthand for big-endian pointers.
dwb: MACRO
	db HIGH(\1),LOW(\1)
ENDM

; =============== dp ===============
; Shorthand for data pointers
dp: MACRO
	db BANK(\1)
	dw \1
ENDM

; =============== dc ===============
; Shorthand for packed coordinates
; IN:
; - 1: Y coord
; - 2: X coord
dc: MACRO
	; Make sure the nybbles are in range for this
assert HIGH(\1) < $10
assert HIGH(\2) < $10
	db ((HIGH(\1) & $0F)<<4)|(HIGH(\2) & $0F)
	db LOW(\1)
	db LOW(\2)
ENDM

; =============== sext ===============
; Shorthand for generating the high byte of a value when doing sign-extension
; IN
; - 1: Register to use
sext: MACRO
	; Shifting right 7 times duplicates the MSB over the entire value.
	; This basically gives out either $FF or $00.
REPT 7
	sra \1
ENDR
ENDM

;; =============== admw ===============
;; Shorthand for increasing a word value stored in memory.
;; The addresses must follow the "_Low" and "_High" naming convention.
;; IN
;; - 1: Partial label for the address to use
;; - 2: Amount to add
;admw: MACRO
;	ld   a, [\1_Low]		
;	add  \2				; mem += \2
;	ld   [\1_Low], a
;	ld   a, [\1_High]
;	adc  $00			; account for carry
;	ld   [\1_High], a
;ENDM
;
;; =============== sbmw ===============
;; Shorthand for decreasing a word value stored in memory.
;; The addresses must follow the "_Low" and "_High" naming convention.
;; IN
;; - 1: Partial label for the address to use
;; - 2: Amount to subtract
;sbmw: MACRO
;	ld   a, [\1_Low]		
;	sub  \2				; mem -= \2
;	ld   [\1_Low], a
;	ld   a, [\1_High]
;	sbc  $00			; account for carry
;	ld   [\1_High], a
;ENDM

; =============== ACTOR DEFN ===============

; =============== mActGFXDef ===============
; Defines an actor GFX (load) definition.
; IN:
; - 1: Ptr to GFX data
; - 2: Tile count
mActGFXDef: MACRO
	dp \1
	db \2
ENDM
; =============== mActGFX_End ===============
; Marks the end of an ActGroupGFX table.
mActGFX_End: MACRO
	db $00,$00,$00,$FF
ENDM

; =============== mActCodeDef ===============
; Defines the init code for actors in the level layout.
; IN:
; - 1: Ptr to init code (Bank $02)
; - 2: Actor flags (ACTFLAGB_*)
; - 3: Bank number for (initial?) OBJLst
mActCodeDef: MACRO
	dw \1
	db \2,\3
ENDM


; =============== mActColiMask ===============
; Generates the player-to-actor collision (bitmask format) for all directions.
; The usable collision types are:
; - ACTCOLI_NORM: Normal bumpable side
; - ACTCOLI_BUMP: Causes hard bump
; - ACTCOLI_DAMAGE: Causes damage
; Due to limitations, this is stored in the temp variable 'COLI'
; IN
; - 1: Collision type for RIGHT border
; - 2: Collision type for LEFT border
; - 3: Collision type for UP border
; - 4: Collision type for DOWN border
; OUT
; - COLI: Calculated result
mActColiMask: MACRO
COLI = \1<<ACTCOLIMB_R|\2<<ACTCOLIMB_L|\3<<ACTCOLIMB_U|\4<<ACTCOLIMB_D
ENDM

; =============== mActOBJLstPtrTable ===============
; Sets the specified OBJLst for the currently processed actor.
; IN
; - 1: Ptr to OBJLstPtrTable
mActOBJLstPtrTable: MACRO
	push bc
	ld   bc, \1
	call ActS_SetOBJLstPtr
	pop  bc
ENDM

; =============== mActS_SetBlankFrame ===============
; Switches the OBJLst for the current actor to the empty one.
; Used to hide the actor.
mActS_SetBlankFrame: MACRO
	mActOBJLstPtrTable OBJLstPtrTable_Act_None
ENDM

; =============== mActOBJLstPtrTableByDir ===============
; Like mActOBJLstPtrTable, except the animation used depends on the direction it's facing.
; This is meant for actors, since they don't support OBJLst flipping, so they have to split
; the left-facing and right-facing variations as two different OBJLst.
; IN
; - 1: Ptr to OBJLstPtrTable to use when facing left
; - 2: Ptr to OBJLstPtrTable to use when facing right
mActOBJLstPtrTableByDir: MACRO
	mActOBJLstPtrTable \1		; Set the one when facing left first
	ld   a, [sActSetDir]
	bit  DIRB_R, a			; Facing right?
	ret  z					; If not, return
	mActOBJLstPtrTable \2		; Set the one when facing right
ENDM

; =============== mActSetYSpeed ===============
; Sets the vertical speed for the currently processed actor. 
; Generally this is used for jump arcs, so once set it may increases or decreases over time.
; IN
; - BC: Downwards speed /frame. If negative, the actor is moved upwards.
mActSetYSpeed: MACRO
	ld   bc, \1						
	ld   a, c						
	ld   [sActSetYSpeed_Low], a
	ld   a, b
	ld   [sActSetYSpeed_High], a
ENDM

; =============== mActS_SetOBJBank ===============
; Saves the bank number for locating the OBJLst.
; Should be used during actor spawning.
; IN:
; - 1: Label to OBJLst ptr table
; - E: Slot ID
mActS_SetOBJBank: MACRO
	ld   a, BANK(\1)		; A = Target bank
	push hl
	ld   hl, sActOBJLstBank	; HL = Start of bank table
	ld   d, $00				; DE = Slot Id
	add  hl, de				; Index it
	ld   [hl], a			
	pop  hl
ENDM

; =============== mActS_RespawnOnOrigPos ===============
; Makes the current actor respawn at the original position
; instead of the last position before despawning.
mActS_RespawnOnOrigPos: MACRO
	ld   hl, sActRespawnTypeTbl	; HL = Ptr to respawn table
	ld   a, [sActSetId]			; DE = sActSetId (minus MSB)
	and  a, $7F
	ld   d, $00
	ld   e, a
	add  hl, de					; Index the respawn table by 
	ld   a, $01					; Set the alternate respawn mode
	ld   [hl], a				; Save back the value
ENDM

; =============== mExActS_SetCenterBlock ===============
; Shorthand macro for positioning an ExAct in a way that it overlaps a block.
; The block's level layout ptr is expected to be in sBlockTopLeftPtr.
mExActS_SetCenterBlock: MACRO
	;--
	; Set the Y position to start at the lowest point of the block
	; sExActOBJY = (sBlockTopLeftPtr_High - $C0) * $10 + $0F 
	
	ld   a, [sBlockTopLeftPtr_High]	
	swap a
	
	; HIGH NYBBLE
	; sExActOBJY_High = (sBlockTopLeftPtr_High >> 4) & $01
	; The and op gets rid of the level layout base.
	; This works since level layout data in the range at $C000-$DFFF, so:
	; $0C & $01 -> $00
	; $0D & $01 -> $01
	ld   b, a
	and  a, $01	; HIGH(wLevelLayout_End - wLevelLayout - 1)			
	ld   [sExActOBJY_High], a
	
	; LOW NYBBLE
	; sExActOBJY_Low = sBlockTopLeftPtr_High << 4 | $0F
	; +$0F to start at the lowest point of the block
	;      (the actor Y origin is at the bottom)
	ld   a, b				
	and  a, $F0
	add  $0F				
	ld   [sExActOBJY_Low], a
	
	;--
	; Do similar for the X position, except we don't have to worry about the level layout base
	; sExActOBJX = sBlockTopLeftPtr_Low * $10 + $08 
	; +$08 to start at the center of the block
	ld   a, [sBlockTopLeftPtr_Low]
	swap a						
	
	; sExActOBJX_High = sBlockTopLeftPtr_Low >> 4
	ld   b, a		
	and  a, $0F
	ld   [sExActOBJX_High], a
	; sExActOBJX_Low = sBlockTopLeftPtr_Low << 4 | $08
	ld   a, b
	and  a, $F0
	add  $08
	ld   [sExActOBJX_Low], a
ENDM

; =============== mActColi_GetBlockId_GetPos ===============	
; Saves the current (original) actor coords to the registers.
; OUT
; - BC: Actor Y pos
; - DE: Actor X pos
mActColi_GetBlockId_GetPos: MACRO
	; DE = sActSetX
	ld   hl, sActSetX_Low
	ld   e, [hl]			; E = X Low
	inc  l
	ld   d, [hl]			; D = X High
	; BC = sActSetY
	inc  l
	ld   c, [hl]			; C = Y Low
	inc  l
	ld   b, [hl]			; B = Y High
ENDM

; =============== mActColi_GetBlockId_SetXOffset ===============	
; Sets the offset to the Actor X position.
; IN
; - 1: X Offset
; OUT
; - DE: Updated actor X pos
mActColi_GetBlockId_SetXOffset: MACRO
	; Apply X offset
	ld   hl, \1		; DE += \1
	add  hl, de
	ld   d, h
	ld   e, l
ENDM

; =============== mActColi_GetBlockId_SetYOffset ===============	
; Sets the offset to the Actor Y position.
; IN
; - 1: Y Offset
; OUT
; - BC: Updated actor Y pos
mActColi_GetBlockId_SetYOffset: MACRO
	ld   hl, \1		; BC += \1
	add  hl, bc
	ld   b, h
	ld   c, l
ENDM

; =============== mActColi_GetBlockId_GetLevelLayoutPtr ===============	
; This macro calculates the block offset to the level layout from an actor's position.
; This is done in the usual way as seen in more detail in Level_DrawFullScreen.
; IN
; - BC: Actor Y coord
; - DE: Actor X coord
; OUT
; - HL: Ptr to level layout
mActColi_GetBlockId_GetLevelLayoutPtr: MACRO
	; To get the index to the level layout in HL, we're just dividing both coords by 16. (block width & block height)
	; The X coord goes in L, while the Y coord goes in H.
	; Since dividing by 16 (>> 4) gets rid of a nybble, and the high nybble of the upper byte
	; is never used, each result can fit in a byte.
	
	; The fixed level width of $1000 is what allows for this neat shortcut,
	; since it means a level is always $100 blocks wide -- exactly what fits in a byte.
	
	;
	; X COMPONENT (LOW BYTE)
	; 
	; L = (DE)sActSetX / 16
	ld   a, e			; L = E >> 4
	and  a, $F0				
	swap a
	ld   l, a				
	ld   a, d			; A = D << 4
	and  a, $0F
	swap a
	or   a, l			; Merge the two nybbles
	ld   l, a
	
	;
	; Y COMPONENT (HIGH BYTE)
	; 
	; H = (HL)sActSetY / 16
	ld   a, c			; H = C >> 4
	and  a, $F0
	swap a
	ld   h, a
	ld   a, b			; A = B << 4
	and  a, $0F
	swap a
	or   a, h			; Merge the two nybbles
	
	;
	; THE REST
	; 
	
	; Add the level layout base to get the proper level layout ptr
	add  HIGH(wLevelLayout)	; HL += $C000
	ld   h, a
ENDM

; =============== mActSeekToParentSlot ===============
; Generates a pointer to the actor's slot by a slot number.
;
; This is meant to be used for actors which track another actor by slot number.
; For example, the child actor could copy the parent actor's coordinates to be kept in sync.
;
; IN
; - 1: Ptr to slot number
; OUT
; - HL: Ptr to the parent actor's slot
mActSeekToParentSlot: MACRO
	; Create the offset to the slot number.
	; An actor slot is $20 bytes large, so SlotNum should be multiplied by $20 (<< 5).
	; A = SlotNum *= $20
	ld   a, [\1]
	swap a									; << 4
	rlca									; << 1
	
	; Offset the actor area stats
	ld   hl, sAct							; HL = Start of first slot
	ld   d, $00								; DE = Index
	ld   e, a
	add  hl, de								; Offset it
ENDM

; =============== mActCheckThrownId ===============
; Checks if the actor that was thrown at the current actor has the specified ID.
; This macro should be executed after being thrown something at, but we want something specific 
; (ie: a 10-coin for the coin lock).  
;  
; IN
; - 1: Actor ID we're looking for
; OUT
; - DE: Offset to the slot area
; - Z: If set, it was the one we're looking for
; - C: If set, its ID was >= than what we're looking for. 
;      In practice only useful with $07, to check if we were thrown a default actor.
mActCheckThrownId: MACRO
	; First of all, extract the slot number from the upper nybble of the routine ID
	; and convert it to an offset to the slot area.
	
	; Conveniently, it's a << 1 away of being usable an offset to the slot area.
	
	ld   a, [sActSetRoutineId]
	and  a, $70							; Filter slot number
	rlca								; << 1 to have SlotNumber * $20
	ld   d, $00							; DE = SlotOffset
	ld   e, a
	; Add that offset over
	ld   hl, sAct+(sActSetId-sActSet)	; HL = Slot area (seeked to actor id)
	add  hl, de							; Offset it
	ld   a, [hl]						; A = Actor ID
	cp   a, \1							; Perform the comparison
ENDM

; =============== mActFlagToDir ===============
; Gets the actor direction value given an OBJLst flags bitmask.
; IN
; - 1: Ptr to OBJLst flags value
; OUT
; - A: Directional value
mActFlagsToXDir: MACRO
	; The direction value doesn't proportionally map to the XFLIP.
	; They are almost inverted bits, enough for a xor to work.
	;   XFLIP  DIR
	; R $20 -> $01
	; L $00 -> $02
	ld   a, [\1]
	and  a, OBJLST_XFLIP	; Filter the X flip flag (if $20; we're moving right)
	ld   b, a				; For the xor to work, the R value only needs to become $30
	rrca					; A |= (A >> 1) will do
	or   a, b				
	xor  OBJLST_XFLIP		; Invert the flip bit
	swap a					; >> 4
ENDM

; =============== mActFlagToDir ===============
; Gets the actor direction value based on the direction the player's facing
; IN
; - 1: Ptr to OBJLst flags value
mPlFlagsToXDir: MACRO
	mActFlagsToXDir sPlFlags
ENDM

; =============== mSetScreenShakeFor8 ===============
; Triggers a screen shake for 8 frames + max 3 extra frames if an existing screen shake is active.
mSetScreenShakeFor8: MACRO
	; The initial value of the timer ($08) is specifically picked so that, if added to an existing 
	; screen shake timer, it won't touch the 3 lowest bits (though only two are kept).
	
	; sScreenShakeTimer = (sScreenShakeTimer % 4) | $08
	ld   a, $08					; B = $08
	and  a, $FC					; (ignore)
	ld   b, a
	ld   a, [sScreenShakeTimer]	; A = sScreenShakeTimer & $03
	and  a, $03					; Preserve the 2 lowest bits (to slightly extend the duration, if one was already playing)
	or   b						; Merge the init val and the existing one
	ld   [sScreenShakeTimer], a
ENDM

; =====================================================
; =============== BGM PLAYBACK COMMANDS ===============
; =====================================================

; =============== sndend ===============
; Marks the end of a command table.
; The game will switch to the next one in the chunk.
sndend: MACRO
	db BGMCMD_END
ENDM
; =============== sndregex ===============
; Changes the additional sound registers a normal data command can't modify.
; Use for channels 1 and 2
; IN
; - 1: Channel volume
; - 2: Sweep Options (rNR?0)
; - 3: Sound Wave Duty/Length (rNR?1)
; - 4: Post-parse pitch change command (BGMPP_*)
sndregex: MACRO
	db BGMCMD_SETOPTREG, \1, \2, (\3 | \4)
ENDM
; =============== sndregex3 ===============
; Changes the additional sound registers a normal data command can't modify.
; Use for channel 3 only.
; IN
; - 1: Ptr to Wave data
; - 2: Channel volume
sndregex3: MACRO
	db BGMCMD_SETOPTREG
	dw \1
	db \2
ENDM
; =============== sndlentbl ===============
; Sets a new BGM length table pointer.
; Note that this won't reset the index. Call sndlenid manually for that.
; IN
; - 1: Ptr to the length table
; - 2: Channel volume
sndlentbl: MACRO
	db BGMCMD_SETLENGTHPTR
	dw \1
ENDM
; =============== sndlenid ===============
; Sets a new index to the currently used BGM length table.
; IN
; - 1: Index to the length table. Should be $0-$F in range.
sndlenid: MACRO
	db BGMCMD_SETLENGTHID + \1
ENDM

; =============== sndpitchbase ===============
; Sets a new pitch base offset, relative to the song's default pitch option.
; IN
; - 1: Pitch offset value
sndpitchbase: MACRO
	db BGMCMD_SETPITCH, \1
ENDM

; =============== sndsetloop ===============
; Sets the current location as a loop point.
; When sndloop is called, it will loop to this location.
; IN
; - 1: Amount of times to loop
sndsetloop: MACRO
	db BGMCMD_SETLOOP, \1
ENDM

; =============== sndloop ===============
; Sets a new index to the currently used BGM length table.
sndloop: MACRO
	db BGMCMD_LOOP
ENDM

; =============== sndstop ===============
; Stops all currently playing sound effects and music without disabling the entire sound playback.
; IN
; - 1: Must be in range $00-$0A.
;      There's no difference between those -- it's just there for having a bit-perfect assembly.
sndstop: MACRO
	db BGMCMD_STOPALL, \1
ENDM

; =============== sndstop ===============
; Mutes the current sound channel.
sndmutech: MACRO
	db BGMDATACMD_MUTECH
ENDM

; =============== sndhienv ===============
; Sets the "high envelope" option for the current sound channel.
sndhienv: MACRO
	db BGMDATACMD_HIGHENV
ENDM

; =============== sndloenv ===============
; Sets the "low envelope" option for the current sound channel.
sndloenv: MACRO
	db BGMDATACMD_LOWENV
ENDM

; =============== snddb ===============
; Offset to a table, which has different meaning between channel 4 and the others.
;
; CHANNEL 1/2/3:
;     Sets the offset to the index of the pitch table.
;     The resulting index to the pitch table is given by
;     adding \1 to the value specified in sndpitchbase.
;     Because of this, this value must be even.
;
; CHANNEL 4:
;     Sets the offset to a separate table of raw ch4 register data.
;     Must be a multiple of 4, since that's the length of ch4's register data,
;
; Regardless of channels, the values used must be even.
; This also guarantees no ambiguity with the BGMDATACMD_* commands, that are all odd values.
;
; IN
;   - 1: The table offset
snddb: MACRO
	db \1
ENDM