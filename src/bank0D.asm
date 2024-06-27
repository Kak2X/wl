;
; BANK $0D - Gameplay, Player Controls, Credits Text, ExActor handler + code, Screen event and Parallax modes
;
; =============== Pl_Anim2Frame ===============
; Animates a player's 2 frame animation cycle every $08 frames.
Pl_Anim2Frame:
	; Animate every $08 frames
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	; This requires the two frames to be one after the other,
	; since we end up setting and resetting bit 0
	ld   a, [sPlLstId]
	xor  $01
	ld   [sPlLstId], a
	ret
; =============== Pl_HatSwitchAnim_SetNextAction ===============
; This subroutines determines the player action to switch to when
; the hat switch animation ends, primarily to account for the differences
; in animations between Small and Normal Wario.
;
; Some of the subroutines in this table are normally used to *start* the action,
; so they can cause some odd side effects.
Pl_HatSwitchAnim_SetNextAction:
	ld   a, [sPlAction]
	rst  $28
	dw Pl_SwitchToStand 	; No change
	dw Pl_SetMoveAction 	; No change
	dw Pl_SetDuckAction 	; No change
	dw Pl_GrabLadder		; No change
	dw Pl_SwitchToSwim  	; No change, [BUG] but ends up spawning the water splash (fixed elsewhere)
	dw Pl_SwitchToJump		; ...
	dw Pl_SwitchToJump		; Cancel grab
	dw Pl_SwitchToHardBumpAir				; Pl_SwitchToHardBump
	dw Pl_SwitchToJump	
	dw Pl_StartDeathAnim	; While dead...
	dw Pl_SwitchToJump 
	dw Pl_SwitchToJump
	dw Pl_SwitchToJump
	dw Pl_SwitchToJump
	dw Pl_SwitchToJump
	dw Pl_SetGrab2Action
	dw Pl_StartThrowAction
	dw Pl_SwitchToSand 		; No change
	dw Pl_SwitchToTreasureGet;X 			; [TCRF] Not possible to trigger under any circumstance
	
; =============== Pl_SwitchToJump ===============
; Only called when switching to the jump action after triggering an hat switch.
Pl_SwitchToJump:
	ld   a, PL_ACT_JUMP
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	; Reset vars
	xor  a
	ld   [sPlTimer], a
	; [BUG] Resetting the jump table index allows you to start a new jump while in the air.
	;       This isn't correct since this is called when already in the air.
IF FIX_FUN_BUGS == 0
	ld   [sPlJumpYPathIndex], a
ENDC
IF IMPROVE == 0
	ld   [sPlMovingJump], a
ENDC
	ld   [sPlGroundDashTimer], a
	ld   [sPlJetDashTimer], a
	
	; Pick the correct anim frame
	ld   a, OBJ_WARIO_JUMP
	ld   [sPlLstId], a
	ld   a, [sSmallWario]
	and  a
	ret  z
	ld   a, [sPlLstId]
	add  OBJ_SMALLWARIO_JUMP-OBJ_WARIO_JUMP
	ld   [sPlLstId], a
	ret
	
; =============== Level_Screen_DoTrainShake ===============
; Performs the screen shake effect for the train inside rooms (using LVLSCROLL_TRAIN).
Level_Screen_DoTrainShake:
	; Only if we're in the train segscrl mode
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_TRAIN
	ret  nz
	
	ld   a, [sTrainShakeTimer]		; Timer++
	inc  a
	ld   [sTrainShakeTimer], a
	
	; The camera shake effect is handled through a timer chain.
	; Depending on what value the timer reached, scroll the screen up or down.
	
	; The important detail here is to make sure .scrollDown and .scrollUp
	; are called the same amount of times before the timer overflows.
	cp   a, $A8				; Timer < $A8?
	ret  c					; If so, return
	cp   a, $AC				; ...
	jr   c, .scrollDown
	cp   a, $B0
	jr   c, .scrollUp
	cp   a, $B8
	ret  c
	cp   a, $BC
	jr   c, .scrollDown
	cp   a, $C0
	jr   c, .scrollUp
	cp   a, $E8
	ret  c
	cp   a, $EC
	jr   c, .scrollDown
	cp   a, $F0
	jr   c, .scrollUp
	cp   a, $F8
	ret  c
	cp   a, $FC
	jr   c, .scrollDown
.scrollUp:
	; Scroll screen up by 1 px
	ld   b, $01
	call Level_Screen_MoveUp
	ret
.scrollDown:
	; Scroll the screen down by 1px
	cp   a, $A8			; Also play train SFX at specific values
	call z, .playSFX
	cp   a, $E8
	call z, .playSFX
	ld   b, $01
	call Level_Screen_MoveDown
	ret
.playSFX:
	ld   a, SFX4_17
	ld   [sSFX4Set], a
	ret
	
; =============== SaveSel_AnimPipes ===============
; Animates the screen event data for the pipes in the stage select screen.
SaveSel_AnimPipes:
	; Every other frame
	ld   a, [sTimer]
	and  a, $01
	ret  nz
	;--
	ld   hl, sSavePipeAnimTiles
	
.checkSave1:
	ld   a, [sSaveAllClear]
	bit  0, a					; Is the save marked as all clear?
	jr   z, .noAllClear1		; If not, skip to the next pipe
	call SaveSel_AnimPipe1Text	; Otherwise animate it
	call SaveSel_AnimPipeBG
	jr   .checkSave2
.noAllClear1:
	inc  l
	inc  l
	inc  l
.checkSave2:;R
	ld   a, [sSaveAllClear]
	bit  1, a
	jr   z, .noAllClear2
	call SaveSel_AnimPipe2Text
	call SaveSel_AnimPipeBG
	jr   .checkSave3
.noAllClear2:
	inc  l
	inc  l
	inc  l
.checkSave3:
	ld   a, [sSaveAllClear]
	bit  2, a
	jr   z, .end
	call SaveSel_AnimPipe3Text
	call SaveSel_AnimPipeBG
.end:
	ld   a, SCRUPD_SAVEPIPE
	ld   [sScreenUpdateMode], a ; Force correct screen update mode
	ld   a, [sSavePipeAnimId]	; Update next frame
	inc  a
	ld   [sSavePipeAnimId], a
	; Reset the id if we've reached the end of the ptr table
	cp   a, (SaveSel_AnimPipeBG.ptrEnd - SaveSel_AnimPipeBG.ptrStart) / 2
	ret  nz
	xor  a
	ld   [sSavePipeAnimId], a
	ret
	
; =============== mAnimPipeText ===============
; Used by sets of subroutines to flash the level count digits of completed saves.
; IN:
; - 1: Ptr to left digit (WorkOAM)
MACRO mAnimPipeText
	; Every $08 frames...
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	; ...switch to the different palette line
	; Since OBP1 is all white, this will cause the digits to flash.
	ld   a, [\1+OAM_FLAGS]		; High digit
	xor  $10
	ld   [\1+OAM_FLAGS], a
	ld   a, [\1+$04+OAM_FLAGS]	; Low digit
	xor  $10
	ld   [\1+$04+OAM_FLAGS], a
	ret
ENDM

SaveSel_AnimPipe1Text: mAnimPipeText sSaveDigit0
SaveSel_AnimPipe2Text: mAnimPipeText sSaveDigit2
SaveSel_AnimPipe3Text: mAnimPipeText sSaveDigit4

; =============== mSavePipeFrame ===============
; Shorthand for defining the Tile IDs to use for a pipe anim frame.
; IN
; - 1: Tile ID 0
; - 2: Tile ID 1
; - 3: Tile ID 2
MACRO mPipeFrame
	ld   a, [sBGTmpPtr]		; HL = Ptr to pipe in screen update dats
	ld   h, a
	ld   a, [sBGTmpPtr+1]
	ld   l, a
	;--
	ld   a, \1				; Write the tile IDs over
	ldi  [hl], a
	ld   a, \2
	ldi  [hl], a
	ld   a, \3
	ldi  [hl], a
	ret
ENDM

; =============== SaveSel_AnimPipeBG ===============
; Performs the tile update to animate the pipes marked as all-clear.
SaveSel_AnimPipeBG:
	; HL = Ptr to pipe in screen update data
	ld   a, h
	ld   [sBGTmpPtr], a
	ld   a, l
	ld   [sBGTmpPtr+1], a
	; Which tile combination ("frame")? 
	ld   a, [sSavePipeAnimId]
	rst  $28
	.ptrStart:
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
	dw .frame4
	dw .frame5
	dw .frame6
	dw .frame7
	dw .frame8
	dw .frame9
	dw .frameA
	dw .frameB
	dw .frameC
	dw .frameD
	dw .frameE
	dw .frame0
	dw .frame0
	dw .frame0
	dw .frame0
	dw .frame0
	.ptrEnd:

.frame0: mPipeFrame $73,$73,$73
.frame1: mPipeFrame $74,$73,$73
.frame2: mPipeFrame $75,$73,$73
.frame3: mPipeFrame $76,$73,$73
.frame4: mPipeFrame $77,$73,$73
.frame5: mPipeFrame $78,$74,$73
.frame6: mPipeFrame $79,$75,$73
.frame7: mPipeFrame $73,$76,$73
.frame8: mPipeFrame $73,$77,$73
.frame9: mPipeFrame $73,$78,$74
.frameA: mPipeFrame $73,$79,$75
.frameB: mPipeFrame $73,$73,$76
.frameC: mPipeFrame $73,$73,$77
.frameD: mPipeFrame $73,$73,$78
.frameE: mPipeFrame $73,$73,$79

; =============== Credits_WriteLineForRow1ToBuffer ===============
; Writes to a temporary buffer the current line to display in the first row
; of the credits text.
;
; This is done once per line -- when the text is written character by character
; later on, it reads from this buffer.
Credits_WriteLineForRow1ToBuffer:
	;
	; Index the table, read the pointer out and copy whatever
	; it's pointing to until an $FF terminator is reached.
	;
	ld   hl, Credits_Row1LinesPtrTable	; HL = Pointer table
	ld   a, [sCreditsRow1LineId]		; DE = LineId * 2 (pointers are 2 bytes, of course)
	add  a
	ld   e, a
	ld   d, $00
	add  hl, de				; Offset that table
	; Read the two values, treat it as a pointer and store it to HL
	ldi  a, [hl]						
	ld   h, [hl]
	ld   l, a				; HL = Ptr to text in this line
	ld   de, sEndingText	; DE = Destination (tile ID buffer)
.loop:
	ldi  a, [hl]	; A = Read tile ID
	cp   a, $FF		; Reached the $FF terminator?
	jr   z, .end	; If so, jump
	ld   [de], a	; Otherwise, copy it to the buffer
	inc  de			; BufferPtr++
	jr   .loop
.end:
	ld   a, $FF		; Add the separator ourselves
	ld   [de], a
	ret
	
; =============== Credits_WriteLineForRow2ToBuffer ===============
; Like Credits_WriteLineForRow1ToBuffer except for the second row.
; The only real difference is that this one treats tile IDs $FC-$FE as special commands.
; See also: Credits_WriteLineForRow1ToBuffer
Credits_WriteLineForRow2ToBuffer:
	ld   hl, Credits_Row2LinesPtrTable	; HL = Pointer table
	ld   a, [sCreditsRow2LineId]		; DE = LineId * 2 (pointers are 2 bytes, of course)
	add  a
	ld   e, a
	ld   d, $00
	add  hl, de				; Offset that table
	; Read the two values, treat it as a pointer and store it to HL
	ldi  a, [hl]
	ld   h, [hl]
	ld   l, a				; HL = Ptr to text in this line
	ld   de, sEndingText	; DE = Destination (tile ID buffer)
.loop:
	ldi  a, [hl]			; A = Read tile ID
	;--
	; Determine if it's a special end terminator command.
	
	; Last line has this to halt
	cp   a, $FC				; No more lines next?
	jr   z, .cmdNoMoreRows	; If so, jump
	; To choose the last line correctly
	cp   a, $FD				; Ending-specific text next?
	jr   z, .cmdLastLineNext; If so, jump
	; Makes the second row scroll away
	cp   a, $FE				; End terminator (keep same row 1)?
	jr   z, .cmdEnd			; If so, jump
	; Makes both rows scroll away
	cp   a, $FF				; End terminator (next row 1)?
	jr   z, .cmdNextRow1	; If so, jump
	;--
	
.noTerminator:
	ld   [de], a			; Otherwise, copy the tile ID
	inc  de
	jr   .loop
	
.cmdLastLineNext:
	ld   a, CTN_LASTLINE
	ld   [sCreditsNextRow1Mode], a
	jr   .nextRow1
.cmdNoMoreRows:
	ld   a, CTN_HALT
	ld   [sCreditsNextRow1Mode], a
	jr   .nextRow1
.cmdNextRow1:
	ld   a, CTN_CLEARBOTH
	ld   [sCreditsNextRow1Mode], a
.nextRow1:
	ld   a, [sCreditsRow1LineId]	; Line1Id++
	inc  a
	ld   [sCreditsRow1LineId], a
.cmdEnd:
	ld   a, [sCreditsRow2LineId]	; Line2Id++
	inc  a
	ld   [sCreditsRow2LineId], a
	ld   a, $FF
	ld   [de], a
	ret
	
Credits_Row1LinesPtrTable:
	dw .ln0
	dw .ln1
	dw .ln2
	dw .ln3
	dw .ln4
	dw .ln5
	dw .ln6
	dw .ln7
	dw .ln8
	dw .ln9
	dw .lnA
	dw .lnB

.ln0: db $5A,$5A,$5A,$5A,$56,$40,$51,$48,$4E,$4B,$40,$4D,$43,$FF
.ln1: db $5A,$5A,$5A,$5A,$5A,$43,$48,$51,$44,$42,$53,$4E,$51,$FF
.ln2: db $5A,$5A,$5A,$5A,$4F,$51,$4E,$46,$51,$40,$4C,$4C,$44,$51,$FF
.ln3: db $5A,$46,$51,$40,$4F,$47,$48,$42,$5A,$43,$44,$52,$48,$46,$4D,$44,$51,$FF
.ln4: db $5A,$5A,$4C,$54,$52,$48,$42,$5A,$42,$4E,$4C,$4F,$4E,$52,$44,$51,$FF
.ln5: db $5A,$4F,$40,$42,$4A,$40,$46,$44,$5A,$43,$44,$52,$48,$46,$4D,$44,$51,$FF
.ln7: db $5A,$5A,$53,$44,$52,$53,$48,$4D,$46,$5A,$4F,$4B,$40,$58,$44,$51,$FF
.ln8: db $5A,$5A,$5A,$5A,$5A,$4F,$51,$4E,$43,$54,$42,$44,$51,$FF
.ln6: db $52,$4F,$44,$42,$48,$40,$4B,$5A,$53,$47,$40,$4D,$4A,$52,$5A,$53,$4E,$FF
.ln9: db $5A,$5A,$5A,$4F,$51,$44,$52,$44,$4D,$53,$44,$43,$5A,$41,$58,$FF
.lnA: db $5A,$5A,$5A,$5A,$5A,$5A,$4F,$4B,$44,$40,$52,$44,$FF
.lnB: db $5A,$5A,$5A,$5A,$5A,$4F,$44,$51,$45,$44,$42,$53,$FF
Credits_Row2LinesPtrTable:
	dw .ln00
	dw .ln01
	dw .ln02
	dw .ln03
	dw .ln04
	dw .ln05
	dw .ln06
	dw .ln07
	dw .ln08
	dw .ln09
	dw .ln0A
	dw .ln0B
	dw .ln0C
	dw .ln0D
	dw .ln0E
	dw .ln0F
	dw .ln10
	dw .ln11
	dw .ln12
	dw .ln13
	dw .ln14
	dw .ln15
	dw .ln16
	dw .ln17
	dw .ln18
	dw .ln19
	dw .ln1A
	dw .ln1B
	dw .ln1C
	dw .ln1D
	dw .ln1E
	dw .ln1F
	dw .ln20
	dw .ln21
	dw .ln22
	dw .ln23
	dw .ln24
	dw .ln25
	dw .ln26
	dw .ln27
	dw .ln28
	dw .ln29
	dw .ln2A
	dw .ln2B
	dw .ln2C
	dw .ln2D
	dw .ln2E
	dw .ln2F
	dw .ln30
	dw .ln31

.ln00: db $5A,$5A,$5A,$5A,$5A,$5A,$52,$53,$40,$45,$45,$FF
.ln01: db $5A,$4A,$48,$58,$4E,$53,$40,$4A,$44,$5A,$47,$48,$51,$4E,$49,$48,$FE
.ln02: db $47,$4E,$52,$4E,$4A,$40,$56,$40,$5A,$53,$40,$4A,$44,$47,$48,$4A,$4E,$FF
.ln03: db $5A,$58,$40,$4C,$40,$4D,$40,$4A,$40,$5A,$4C,$40,$52,$40,$51,$54,$FE
.ln04: db $5A,$5A,$5A,$4E,$46,$40,$56,$40,$5A,$58,$54,$59,$54,$51,$54,$FE
.ln05: db $5A,$5A,$5A,$47,$48,$51,$40,$4D,$4E,$5A,$48,$52,$40,$4E,$FE
.ln06: db $4A,$40,$53,$52,$54,$4A,$48,$5A,$58,$4E,$52,$47,$48,$4D,$4E,$51,$48,$FF
.ln07: db $5A,$4A,$48,$58,$4E,$53,$40,$4A,$44,$5A,$47,$48,$51,$4E,$49,$48,$FE
.ln08: db $47,$4E,$52,$4E,$4A,$40,$56,$40,$5A,$53,$40,$4A,$44,$47,$48,$4A,$4E,$FE
.ln09: db $5A,$5A,$52,$54,$46,$48,$4D,$4E,$5A,$4A,$44,$4D,$48,$42,$47,$48,$FF
.ln0A: db $5A,$58,$4E,$52,$47,$48,$53,$4E,$4C,$48,$5A,$51,$58,$4E,$49,$48,$FE
.ln0B: db $5A,$5A,$48,$52,$47,$48,$4A,$40,$56,$40,$5A,$4A,$4E,$59,$54,$44,$FF
.ln0C: db $5A,$5A,$4D,$4E,$4C,$54,$51,$40,$5A,$45,$54,$49,$48,$4A,$4E,$FE
.ln0D: db $5A,$5A,$4D,$40,$4A,$40,$4D,$4E,$5A,$58,$54,$52,$54,$4A,$44,$FF
.ln0E: db $5A,$48,$59,$54,$52,$47,$48,$5A,$53,$40,$4A,$44,$47,$48,$51,$4E,$FE
.ln0F: db $5A,$5A,$58,$40,$4C,$40,$4C,$4E,$53,$4E,$5A,$4C,$40,$52,$40,$4E,$FE
.ln10: db $5A,$47,$40,$51,$40,$43,$40,$5A,$53,$40,$4A,$40,$47,$48,$51,$4E,$FE
.ln11: db $5A,$5A,$4E,$59,$40,$4A,$48,$5A,$4D,$4E,$41,$54,$47,$48,$51,$4E,$FE
.ln12: db $5A,$5A,$5A,$5A,$43,$40,$4D,$5A,$4E,$56,$52,$44,$4D,$FE
.ln13: db $5A,$5A,$5A,$43,$40,$58,$55,$5A,$41,$51,$4E,$4E,$4A,$52,$FE
.ln14: db $5A,$5A,$5A,$53,$40,$4C,$54,$51,$40,$5A,$4A,$44,$48,$4A,$4E,$FE
.ln15: db $5A,$5A,$5A,$4C,$40,$51,$58,$5A,$42,$4E,$42,$4E,$4C,$40,$FE
.ln16: db $5A,$5A,$5A,$47,$48,$51,$4E,$5A,$58,$40,$4C,$40,$43,$40,$FE
.ln17: db $5A,$5A,$5A,$43,$40,$55,$48,$43,$5A,$4F,$40,$53,$53,$4E,$4D,$FE
.ln18: db $5A,$5A,$46,$51,$40,$47,$40,$4C,$5A,$40,$51,$42,$47,$44,$51,$FE
.ln19: db $5A,$5A,$52,$47,$48,$41,$40,$53,$40,$5A,$52,$40,$53,$4E,$51,$54,$FF
.ln1A: db $5A,$5A,$5A,$4E,$4A,$40,$43,$40,$5A,$4C,$40,$52,$40,$51,$54,$FE
.ln1B: db $5A,$5A,$5A,$4A,$40,$4D,$4E,$47,$5A,$4C,$40,$4A,$4E,$53,$4E,$FE
.ln1C: db $52,$40,$4A,$40,$52,$47,$48,$53,$40,$5A,$4C,$40,$52,$40,$45,$54,$4C,$48,$FE
.ln1D: db $5A,$5A,$5A,$45,$54,$4A,$54,$48,$5A,$4A,$4E,$47,$53,$40,$FE
.ln1E: db $5A,$53,$44,$51,$40,$52,$40,$4A,$48,$5A,$4A,$44,$48,$52,$54,$4A,$44,$FE
.ln1F: db $5A,$4C,$40,$52,$47,$48,$4C,$4E,$5A,$4C,$40,$52,$40,$47,$48,$4A,$4E,$FE
.ln20: db $5A,$58,$40,$4C,$40,$46,$40,$4C,$48,$5A,$47,$48,$53,$4E,$52,$47,$48,$FE
.ln21: db $5A,$5A,$53,$4E,$53,$40,$4A,$40,$5A,$4A,$40,$59,$54,$4C,$48,$FE
.ln22: db $5A,$58,$40,$4C,$40,$4D,$44,$5A,$53,$4E,$4C,$4E,$58,$4E,$52,$47,$48,$FE
.ln23: db $5A,$5A,$5A,$5A,$47,$4E,$51,$48,$5A,$58,$54,$49,$48,$FE
.ln24: db $5A,$5A,$5A,$48,$4C,$4E,$53,$4E,$5A,$53,$40,$4A,$40,$52,$47,$48,$FE
.ln25: db $4A,$40,$4D,$44,$52,$47,$48,$46,$44,$5A,$53,$52,$54,$53,$4E,$4C,$54,$FE
.ln26: db $5A,$4A,$40,$56,$40,$4D,$4E,$5A,$4C,$40,$52,$40,$47,$48,$51,$4E,$FE
.ln27: db $5A,$4D,$40,$46,$40,$51,$44,$43,$40,$5A,$53,$40,$4A,$44,$52,$47,$48,$FE
.ln28: db $4C,$40,$53,$52,$54,$4C,$54,$51,$40,$5A,$52,$40,$53,$4E,$52,$47,$48,$FE
.ln29: db $58,$40,$4C,$40,$4C,$4E,$53,$4E,$5A,$58,$54,$4A,$48,$47,$48,$51,$4E,$FE
.ln2A: db $5A,$58,$40,$4C,$40,$54,$42,$47,$48,$5A,$4C,$40,$4A,$4E,$53,$4E,$FE
.ln2B: db $5A,$5A,$4D,$4E,$46,$40,$4C,$48,$5A,$52,$40,$53,$4E,$52,$47,$48,$FE
.ln2C: db $5A,$5A,$53,$40,$4A,$44,$54,$42,$47,$48,$5A,$44,$48,$4A,$4E,$FE
.ln2D: db $5A,$5A,$4C,$40,$51,$54,$4D,$4E,$5A,$40,$53,$52,$54,$52,$47,$48,$FF
; [TCRF] Unreferenced lines, right after the end of the "TESTERS"
.unused_ln00: db $5A,$5A,$5A,$5A,$5A,$5A,$53,$44,$53,$52,$54,$FE ; "TETSU"
.unused_ln01: db $5A,$5A,$5A,$5A,$58,$4E,$52,$47,$48,$44,$5A,$52,$40,$4D,$FE ; "YOSHIE SAN"
.ln2E: db $5A,$5A,$5A,$58,$4E,$4A,$4E,$48,$5A,$46,$54,$4C,$4F,$44,$48,$FF
.ln2F: db $5A,$5A,$5A,$5A,$5A,$4D,$48,$4D,$53,$44,$4D,$43,$4E,$FD
.ln30: db $5A,$5A,$5A,$5A,$5A,$5A,$51,$44,$53,$51,$58,$5B,$FC
.ln31: db $5A,$5A,$5A,$5A,$5A,$5A,$46,$40,$4C,$44,$5B,$FC

; ================== Demo_GetInput =====================
; This subroutine updates the keypress values during the game demo.
; It retrieves the Joypad input and keypress length from a table $80 bytes long,
; with bytes in the format <KeyPress, Length>.
; As such, each demo contains exactly $40 keypresses.
;
; SPEC: From HomeCall
Demo_GetInput:
	ld   de, $0007		; E = Amount of times to shift right 
						; (resulting in multiplication by $80, which is the length of a demo table)
	ld   a, [sDemoId]	; A = Demo Index
;--
; Calculate the offset for the current demo input table.
; This ends up doing:
; DE = sDemoId * $80
.loop:
	sla  a 						; DE << 1
	rl   d 						; (basically << 1 for the carry)
	dec  e
	jr   nz, .loop
	ld   e, a					
;--
	; Get the ptr to the current input demo table
	ld   hl, Demo_InputTable	
	add  hl, de					; HL = Inputs for the current demo
	
	; Index the current table entry (already multiplied by 2)
	ld   a, [sDemoInputOffset] 
IF SKIP_JUNK == 0
	add  l
	ld   l, a					; L = Current Entry
ELSE
	; "add l" requires the data to be aligned to a $100 boundary.
	; It won't work if the padding areas are removed.
	ld   d, $00
	ld   e, a
	add  hl, de
ENDC
	
	; Handle the joypad key status
	ldi  a, [hl] 				; Get the current keypress
	ld   c, a
	ldh  a, [hJoyKeys] 			; And update the hJoyKeys and hJoyNewKeys values as it would be done normally
	xor  a, c					; same ((oldKeys ^ newKeys) & newKeys)
	and  a, c
	ldh  [hJoyNewKeys], a
	ld   a, c
	ldh  [hJoyKeys], a
	
	; Handle the number of frames
	ld   a, [sDemoInputLength] 	; Increase the current input length
	inc  a
	ld   [sDemoInputLength], a 	; Have we reached the specified number of frames?
	cp   a, [hl]
	ret  nz						; If not return
	
	; If the target number of frames is reached, prepare for the next table entry
	xor  a						; Otherwise, reset the length
	ld   [sDemoInputLength], a
	ld   a, [sDemoInputOffset]	; and update the offset to point to the next table entry
	add  $02
	ld   [sDemoInputOffset], a
	ret
	
; =============== Game_Do ===============
; Starts a chain of subroutines for common actions to perform during gameplay,
; including player controls / collision detection and screen effects.
Game_Do:
	call Level_Screen_DoTrainShake
	
	; The "new" action needs to be valid for 1 frame only
	xor  a
	ld   [sPlNewAction], a
	
	;
	; Handle the screen shake effect for hitting a switch.
	;
	
	; Only if the player is frozen
	ld   a, [sPlFreezeTimer]
	and  a						; Is the player frozen?
	jr   z, Game_CheckSpecClear	; If not, skip ahead
	
	; Default with an empty offset.
	; If we aren't setting any value for a frame, it will default to this.
	xor  a
	ld   [sScrollYOffset], a
	; If the timer elapsed, don't shake the screen anymore
	ld   a, [sScreenShakeTimer]
	and  a
	ret  z						
	
	; Every other frame don't set any value (restore $00 offset)
	ld   a, [sScreenShakeTimer]				
	and  a, $01					
	jr   nz, .setOffset00		
	
	; For the other frames, alternate between the up and down offsets.
	ld   a, [sScreenShakeTimer]
	and  a, $02					
	jr   z, .setOffsetD	
.setOffsetU:
	ld   a, -$02
	jr   .setOffset
.setOffsetD:
	ld   a, +$02
.setOffset:
	ld   [sScrollYOffset], a
.setOffset00:
	ld   hl, sScreenShakeTimer
	dec  [hl]
	ret

; =============== Game_CheckSpecClear ===============
; Part 2 of Game_Do.
; This subroutine handles the special level clear modes.
; (ie: everything except going through the level clear door).
Game_CheckSpecClear:
	; reminder that sLvlSpecClear isn't used for the normal level clear
	ld   a, [sLvlSpecClear]
	and  a							; Any special level clear?
	jr   z, Level_Screen_MoveUpFor	; If not, jump
	dec  a							; LVLCLEAR_BOSS
	jr   z, .bossClear
	dec  a							; LVLCLEAR_BIGSWITCH
	jr   z, .bigSwitchBlock
	dec  a							; LVLCLEAR_FINALDEAD
	jr   z, .syrupCastleBossClear
	; LVLCLEAR_FINALEXITTOMAP is not meant to be used in the main gameplay mode,
	; so it isn't checked here.
	ret ; We never get here
.bigSwitchBlock:

	; Hitting a big switch block causes a fade out to a map screen mode.
	ld   a, GM_LEVELCLEAR2
	ld   [sGameMode], a
	ld   a, [sPlFlags]
	res  OBJLSTB_OBP1, a			; Clear inverted palette, if any
	ld   [sPlFlags], a
	xor  a
	ld   [sMapRetVal], a
	ld   [sSubMode], a
	ld   [sPlDragonHatActive], a
	ld   [sCheckpoint], a
	ld   [sHurryUp], a
	ld   [sExActCount], a
	ld   a, BGM_LEVELCLEAR
	ld   [sBGMSet], a
	; Depending on the level we're on, trigger a specific cutscene.
	ld   a, [sLevelId]
	cp   a, LVL_C12
	jr   z, .c12
	cp   a, LVL_C32
	jr   z, .c32
	cp   a, LVL_C38
	jr   z, .c38
	cp   a, LVL_C39
	jr   z, .c39
	ret ; We never get here
.c12:
	ld   a, MAP_MODE_INITMTTEAPOTCUTSCENE
	jr   .setMap
.c32:
	ld   a, MAP_MODE_INITPARSLEYWOODSCUTSCENE
	jr   .setMap
.c38:
	ld   a, MAP_MODE_INITSYRUPCASTLEC38CUTSCENE
	jr   .setMap
.c39:
	ld   a, MAP_MODE_INITSYRUPCASTLEC39CUTSCENE
.setMap:
	ld   [sMapId], a
	ret
.bossClear:
	call Level_EnterClearDoor
	ret
.syrupCastleBossClear:
	call HomeCall_Game_StartEnding
	ret
; =============== Level_Screen_MoveUpFor ===============
; Part 3 of Game_Do.
; If enabled, scrolls the screen up until the timer elapses.
Level_Screen_MoveUpFor:
	ld   a, [sLvlScrollSet]
	bit  DIRB_U, a				; Upwards movement requested?
	jr   z, Level_Screen_MoveDownFor				; If not, jump
	;--
	; Move the screen upwards by 2 px
	ld   b, $02
	ld   a, [sLvlScrollVAmount]
	sub  a, b
	ld   [sLvlScrollVAmount], a
	; Timer--
	ld   a, [sLvlScrollTimer]
	sub  a, b
	; If fully elapsed, end this scroll request
	ld   [sLvlScrollTimer], a
	ret  nz
	ld   hl, sLvlScrollSet
	res  DIRB_U, [hl]
	xor  a
	ld   [sPauseActors], a
	jr   Game_ChkLadderCenterRight
; =============== Level_Screen_MoveDownFor ===============
; Part 4 of Game_Do.
; If enabled, scrolls the screen down until the timer elapses.
Level_Screen_MoveDownFor:
	ld   a, [sLvlScrollSet]
	bit  DIRB_D, a				; Downwards movement requested?
	jr   z, Game_ChkLadderCenterRight				; If not, jump
	;--
	; Move the screen downwards by 2 px
	ld   b, $02
	ld   a, [sLvlScrollVAmount]
	add  b
	ld   [sLvlScrollVAmount], a
	; Timer--
	ld   a, [sLvlScrollTimer]
	sub  a, b
	; If fully elapsed, end this scroll request
	ld   [sLvlScrollTimer], a
	ret  nz
	ld   hl, sLvlScrollSet
	res  DIRB_D, [hl]
	xor  a
	ld   [sPauseActors], a
; =============== Game_ChkLadderCenterRight ===============
; Part 5 of Game_Do.
; Handles the automatic player movement to the right when climbing/approaching a
; ladder from its left border.
; Nice convenience feature to avoid colliding with blocks to the left of a ladder when climbing it.
Game_ChkLadderCenterRight:
	ld   a, [sLvlScrollSet]
	bit  DIRB_R, a					; Is it enabled?
	jr   z, Game_ChkLadderCenterLeft
	;--
	; Check the current collision type.
	; Depending on the block collision in at the left or right of the player at ground level,
	; different values are set.
	; We're waiting for bit 2, which is only set for collision values $05 and $06.
	; Those values are for when both the top left and top right blocks are ladders 
	; (ladder body and ladder top respectively).
	call PlBGColi_CheckLadderLow		; Check the current collision type
	bit  COLILDB_LADDERANY2, a		; Are we fully on a ladder?
	jr   nz, .end					; If so, we're done.
	;--
	call Level_ScreenLock_DoRight	; Update screen lock info
	ld   b, $01						; B = Movement speed
	; If the screen is locked horizontally (either left or right border)
	; only move the player without scrolling the screen.
	ld   a, [sLvlScrollLockCur]
	and  a, DIR_L|DIR_R
	jr   nz, .noScrMove
	ld   a, [sLvlScrollHAmount]
	add  b
	ld   [sLvlScrollHAmount], a
.noScrMove:
	call Pl_MoveRight
	ret
.end:
	ld   hl, sLvlScrollSet
	res  DIRB_R, [hl]
	xor  a
	ld   [sPauseActors], a
	jr   Game_DoScreenShake
; =============== Game_ChkLadderCenterLeft ===============
; Part 6 of Game_Do.
; Like Game_ChkLadderCenterRight, but when moving from the right border.
Game_ChkLadderCenterLeft:
	ld   a, [sLvlScrollSet]
	bit  DIRB_L, a				; Is it enabled?
	jr   z, Game_DoScreenShake
	;--
	; If we're fully on a ladder, we're done
	call PlBGColi_CheckLadderLow
	bit  COLILDB_LADDERANY2, a
	jr   nz, .end
	;--
	call Level_ScreenLock_DoLeft	; Update screen lock info
	ld   b, $01						; B = Movement speed
	; If the screen is locked horizontally (either left or right border)
	; only move the player without scrolling the screen.
	ld   a, [sLvlScrollLockCur]
	and  a, DIR_L|DIR_R
	jr   nz, .noScrMove
	ld   a, [sLvlScrollHAmount]
	sub  a, b
	ld   [sLvlScrollHAmount], a
.noScrMove:
	call Pl_MoveLeft
	ret
.end:
	ld   hl, sLvlScrollSet
	res  DIRB_L, [hl]
	xor  a
	ld   [sPauseActors], a
; =============== Game_DoScreenShake ===============
; Part 7 of Game_Do.
; Handles the generic screen shake effect during levels.
; Anything which shakes the screen (ground pound, actors, switch block) is handled here.
Game_DoScreenShake:
	; By default always reset the screen offset.
	xor  a
	ld   [sLvlScrollDirAct], a
	ld   [sScrollYOffset], a
	
	; If there's no screen shake active, ignore
	ld   a, [sScreenShakeTimer]
	and  a
	jr   z, Game_DoPostHitInvuln
	; If the player's dead, ignore
	ld   a, [sPlAction]
	cp   a, PL_ACT_DEAD
	jr   z, Game_DoPostHitInvuln
	
	; Every other frame don't set any value (restore $00 offset)
	ld   a, [sScreenShakeTimer]
	and  a, $01
	jr   nz, .setOffset00
	; For the other frames, alternate between the up and down offsets.
	ld   a, [sScreenShakeTimer]
	and  a, $02
	jr   z, .setOffsetD
.setOffsetU:
	ld   a, -$02
	jr   .setOffset
.setOffsetD:
	ld   a, +$02
.setOffset:
	ld   [sScrollYOffset], a
.setOffset00:
	ld   hl, sScreenShakeTimer	; Timer--
	dec  [hl]					; Have we elapsed the timer?
	jr   z, .timerEnd			; If so, jump
	
	;--
	; Handle the player freeze effect when a screen shake effect is active.
	; During a screen shake, player movement is completely ignored (by returning early)
	; if we aren't over an empty block.
	
	; Bull Wario as usual is completely unaffacted by this
	ld   a, [sPlPower]
	cp   a, PL_POW_BULL			
	jr   z, Game_DoPostHitInvuln				
	
	call PlBGColi_DoGround
	and  a						; Are we on an empty block ($00)?
	ret  nz						; If not, return (don't handle player actions)
	;--
	jr   Game_DoPostHitInvuln				; Otherwise continue as normal
	
.timerEnd:
	ld   a, [sPlScreenShake]	; Did we cause the screen shake effect? (ground pound, switch block)
	and  a
	jr   z, Game_DoPostHitInvuln				; If not, it was caused by an actor (which should turn off itself the effect)
	
	xor  a						; End the screen shake effect
	ld   [sPlScreenShake], a
	
IF FIX_BUGS == 1
	ret
ELSE
	;--
	; [BUG] This is absolutely not correct; and I'm not even sure why it's here.
	;
	; This causes Wario's action to reset to the walking frame, regardless of what we're actually doing.
	; This can cause Wario to be set on ground for a single frame if we aren't supposed to be on the ground.
	; The frame is enough to cause these bugs:
	; - Walking normally on 1 block high gaps
	; - Queueing up a dash for later
	; - Walking at normal speed after hitting a switch.
	; - Double jumping
	; - Walking normally on shallow water or on sand (the harder way to trigger it)
	; - Switching from normal to high jump in the middle of the jump
	; - Sliding on ice after the screen shake ends, without having to press anything else
	jp   Pl_SetMoveAction
	;--
ENDC

; =============== Game_DoPostHitInvuln ===============
; Part 8 of Game_Do.
; Handles the timer for the post-invulnerability state.
Game_DoPostHitInvuln:
	; If we aren't invincible, skip this
	ld   a, [sPlPostHitInvulnTimer]
	and  a
	jr   z, Pl_DoCtrl
	;--
	call Pl_FlashPal
	; Every other frame decrement the invulnerability timer
	ld   a, [sTimer]
	and  a, $01
	jr   nz, Pl_DoCtrl
	ld   a, [sPlPostHitInvulnTimer]
	dec  a
	ld   [sPlPostHitInvulnTimer], a
	jr   z, .timerEnd	; If the timer elapsed, jump
	jr   Pl_DoCtrl
.timerEnd:
	xor  a
	ld   [sPlPostHitInvulnTimer], a
	ld   [sPlHurtType], a
	; Reset palette
	ld   hl, sPlFlags
	res  OBJLSTB_OBP1, [hl]
	
	; Check which block we're colliding with on the lower portion of the body.
	; This is necessary since damage collision isn't checked when the player stands still.
	; [BUG] This doesn't account for the edge case of getting a powerup shortly after being hit,
	;       since the upper portion of the body isn't checked.
	call PlBGColi_GetBlockIdLow
	cp   a, BLOCKID_SANDSPIKE	; $3F Sand damage
	jr   z, .spike		
	cp   a, $59					; < $59: ok
	jr   c, Pl_DoCtrl
	cp   a, $5B					; < $5B: generic spikes
	jr   c, .spike
	cp   a, BLOCKID_INSTAKILL	; $5C instakill
	jr   z, .instakill
	cp   a, $5D					; < $5D ok
	jr   c, Pl_DoCtrl
	cp   a, BLOCKID_EMPTY_START	; >= $60 all empty
	jr   nc, Pl_DoCtrl
								; < $60 main spike area
.spike:
	call BGColi_Spike
	ret
; [TCRF] Extremely difficult, if not impossible to trigger.
;        Lava always instakills regardless of invulnerability.
.instakill: 
	call BGColi_InstaDeath
	ret
	
; =============== Pl_DoCtrl ===============
; Part 9 of Game_Do.
; Main subroutine for handling player control during gameplay.
;
; This is the very end of the chain of gameplay modes.
; If we don't get here (ie: we returned early), the player is basically frozen.
Pl_DoCtrl:
	ld   a, [sPlAction]
	rst  $28
	dw Pl_DoCtrl_Stand
	dw Pl_DoCtrl_Walk
	dw Pl_DoCtrl_Duck
	dw Pl_DoCtrl_Climb
	dw Pl_DoCtrl_Swim
	dw Pl_DoCtrl_Jump
	dw Pl_DoCtrl_ActInt ; Actor interaction (dash against, grab)
	dw Pl_DoCtrl_HardBump
	dw Pl_DoCtrl_JumpOnAct
	dw Pl_DoCtrl_Dead
	dw Pl_DoCtrl_Cling
	dw Pl_DoCtrl_Dash
	dw Pl_DoCtrl_DashRebound
	dw Pl_DoCtrl_DashJump
	dw Pl_DoCtrl_DashJet
	dw Pl_DoCtrl_DuckActGrab
	dw Pl_DoCtrl_Throw
	dw Pl_DoCtrl_Sand
	dw Pl_DoCtrl_TreasureGet
	ret
; =============== Pl_DoCtrl_Stand ===============
Pl_DoCtrl_Stand:

IF FIX_BUGS == 1
	ld   a, [sPlActSolid]
	and  a								; Standing on a solid actor?
	call z, Level_Scroll_CheckSegScroll	; If not, call
ENDC

	; Start by checking if we've just started to hold an enemy (held: 1, last: 0)
	; This would start a fast anim in which player ctrl is disabled.
	; Code setup like this can be found in other actions.
	ld   a, [sActHeld]
	and  a						; Holding something?
	jr   z, .checkThrow			; If not, skip
	
	ld   a, [sActHeldLast]
	and  a						; Is the last value 0?	
	jr   nz, .checkThrow		; If not, jump
	jp   Pl_SetGrab2Action
	;--
.checkThrow:
	; If we were holding something in the last frame but now we aren't anymore,
	; it means we've been signaled to throw (or drop) the actor we're holding.
	; (held: 0, last != 0)
	ld   a, [sActHeldLast]
	and  a							; Is the status 0?
	jr   z, .checkUp				; If so, jump
	ld   a, [sActHeld]
	and  a							; Holding something?
	jp   z, Pl_StartThrowAction		; If not, jump
	;--
	
; Start of chained key control check.
; This checks the actions mapped ot the UP button.
.checkUp:
	ldh  a, [hJoyKeys]
	bit  KEYB_UP, a		
	jr   z, Pl_DoCtrl_Stand_CheckB
	;--
	
	; Door collision
.checkDoorEnter:
	call PlBGColi_GetBlockIdLow
	cp   a, BLOCKID_DOOR		; Are we colliding with a door?
	jr   nz, .checkLadder		; If not, jump
	ld   a, [sPlBgColiBlockEq]
	and  a						; Are we precisely over the door? (not between door and another tile)
	jr   z, .checkLadder		; If not, jump
	call Level_EnterDoor
	ret
	
.checkLadder:
	; Check for ladder collision above ground level (but still on the lower part of the body)
	call PlBGColi_CheckLadderLow
	and  a							; Are we colliding with a ladder?
	jr   z, Pl_DoCtrl_Stand_CheckB	; If not, ignore this
	
; =============== Pl_GrabLadder ===============
Pl_GrabLadder:
	; If we're in the ladder grab anim already, ignore this
	ld   a, [sLvlScrollSet]
	and  a						
	jr   nz, Pl_SetClimbAction
	
	; Get the ladder status and low-left/low-right block IDs to determine where the ladder is located.
	call PlBGColi_CheckLadderLow
	
	; If we're fully on a ladder (or between two) skip the grab movement
	bit  COLILDB_LADDERANY2, a
	jr   nz, Pl_SetClimbAction				
	
	; Otherwise, depending on where the ladder block is, move to the respective direction
	; (both for ladder top and ladder body)
	cp   a, COLILD_LADDERTOP		; Colliding with the ladder top?
	jr   z, .ladderTop					
.ladderBody:
	ld   a, [sPlBGColiBlockId]		; left
	cp   a, BLOCKID_LADDER
	jr   z, .left
	
	ld   a, b						; right
	cp   a, BLOCKID_LADDER
	jr   z, .right
	
	jr   Pl_SetClimbAction
	
.ladderTop:
	ld   a, [sPlBGColiBlockId]		; left
	cp   a, BLOCKID_LADDERTOP
	jr   z, .left
	
	ld   a, b						; right
	cp   a, BLOCKID_LADDERTOP
	jr   nz, Pl_SetClimbAction
	
.right:
	ld   a, DIR_R
	ld   [sLvlScrollSet], a
	jr   Pl_SetClimbAction
.left:
	ld   a, DIR_L
	ld   [sLvlScrollSet], a

; =============== Pl_SetClimbAction ===============
; This subroutine switches to the climbing action.
Pl_SetClimbAction:
	xor  a
	ld   [sPlTimer], a
	ld   [sPlJumpYPathIndex], a
	ld   a, PL_ACT_CLIMB
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	; Set the correct climb frame
	ld   a, OBJ_WARIO_CLIMB0
	ld   [sPlLstId], a
	ld   a, [sSmallWario]
	and  a
	ret  z
	ld   a, [sPlLstId]
	add  OBJ_SMALLWARIO_CLIMB0-OBJ_WARIO_CLIMB0
	ld   [sPlLstId], a
	ret
; =============== Pl_DoCtrl_Stand_CheckB ===============
; Checks the action mapped to the B button.
Pl_DoCtrl_Stand_CheckB:
	ld   a, [sPlLstId]
	cp   a, OBJ_WARIO_HOLD			; Holding something?
	jr   z, .checkDownLadder		; If so, ignore
	
	; Can't be a jump since we don't necessarily trigger any action in Pl_StartActionB
	ldh  a, [hJoyNewKeys]
	bit  KEYB_B, a					; Pressed B?
	call nz, Pl_StartActionB		; If so, jump
	
	; But if we triggered one, ignore everything else
	ld   a, [sPlNewAction]
	and  a
	ret  nz
	
; Checks if we're starting to climb down a ladder.
.checkDownLadder:
	ldh  a, [hJoyKeys]
	bit  KEYB_DOWN, a			
	jr   z, .checkA
	;--
	; If there's a ladder below, grab it
	call PlBGColi_DoGround
	ld   a, [sPlBGColiLadderType]
	and  a							; Colliding with a ladder?
	jr   z, .checkA	; If not, jump
	jr   Pl_SetClimbAction
	
; Checks if we're starting a jump.
.checkA:
	; If we've just pressed A, try to start a jump
	ldh  a, [hJoyNewKeys]
	bit  KEYB_A, a
	jp   nz, Pl_StartJump

	; Otherwise check if we aren't standing on the ground anymore.
	call PlBGColi_DoGround
	cp   a, COLI_WATER				; Went into water?
	jp   z, Pl_SwitchToSwim			
	cp   a, COLI_SOLID				; Ground disappeared?
	jp   nz, Pl_SwitchToJumpFall2		
	
; Checks if we're starting a duck.
.checkDuck:
	ldh  a, [hJoyKeys]
	bit  KEYB_DOWN, a			
	jr   z, Pl_DoCtrl_Stand_CheckRight		
	;--	
	; Small Wario can't duck
	ld   a, [sSmallWario]
	and  a						
	jr   nz, Pl_DoCtrl_Stand_CheckRight
; =============== Pl_SetDuckAction ===============
; This subroutine switches to the duck action.
Pl_SetDuckAction:
	xor  a
	ld   [sPlTimer], a
	ld   a, PL_ACT_DUCK
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	xor  a
	ld   [sPlGroundDashTimer], a
	ld   [sPlIceDelayTimer], a
	ld   [sPlIceDelayDir], a
	ld   a, $01
	ld   [sPlDuck], a
	; Use a different frame if holding something
	ld   a, OBJ_WARIO_DUCK
	ld   [sPlLstId], a
	ld   a, [sActHeld]
	and  a
	ret  z
	ld   a, OBJ_WARIO_DUCKHOLD
	ld   [sPlLstId], a
	ret
	
; =============== Pl_DoCtrl_Stand_CheckRight ===============
; Checks if we're starting movement to the right.
Pl_DoCtrl_Stand_CheckRight:
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jr   z, Pl_DoCtrl_Stand_CheckLeft
	;--
	
	; If we've started movement on ice, set a delay of $10 frames before actually moving
	ld   a, [sPlIce]
	and  a
	jr   z, Pl_SetMoveRightAction
	ld   a, $10
	ld   [sPlIceDelayTimer], a
	xor  a
	ld   [sPlIceDelayDir], a
; =============== Pl_SetMoveRightAction ===============
; Switches to the player walking action; moving right.
Pl_SetMoveRightAction:
	; Set the obj direction
	ld   hl, sPlFlags
	set  OBJLSTB_XFLIP, [hl]
	
; =============== Pl_SetMoveAction ===============
; Switches to the player walking action.
Pl_SetMoveAction:
	ld   a, PL_ACT_WALK
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	xor  a
	ld   [sPlTimer], a
	
	;--
	; [POI] We never get here anyway if the timer is active.
	ld   a, [sPlHatSwitchTimer]
	and  a
	jr   nz, .normalFrame
	;--
	
	; Use the appropriate walking frame
	ld   a, [sActHeld]
	and  a
	jr   nz, .heldFrame
.normalFrame:
	ld   a, OBJ_WARIO_WALK0
	ld   [sPlLstId], a
	ld   a, [sSmallWario]
	and  a
	ret  z
	ld   a, [sPlLstId]
	add  OBJ_SMALLWARIO_WALK0-OBJ_WARIO_WALK0
	ld   [sPlLstId], a
	ret
.heldFrame:
	ld   a, OBJ_WARIO_HOLDWALK0
	ld   [sPlLstId], a
	ld   a, [sSmallWario]
	and  a
	ret  z
	ld   a, OBJ_SMALLWARIO_HOLDWALK0
	ld   [sPlLstId], a
	ret
	
; =============== Pl_DoCtrl_Stand_CheckLeft ===============
; Checks if we're starting movement to the left.
; See also: Pl_DoCtrl_Stand_CheckRight
Pl_DoCtrl_Stand_CheckLeft:
	bit  KEYB_LEFT, a
	jr   z, Pl_DoCtrl_Stand_CheckIceSlide
	;--
	; If we're on ice, set the delay before moving
	ld   a, [sPlIce]
	and  a
	jr   z, Pl_SetMoveLeftAction
	ld   a, $10
	ld   [sPlIceDelayTimer], a
	xor  a
	ld   [sPlIceDelayDir], a
; =============== Pl_SetMoveLeftAction ===============
; Switches to the player walking action; moving left.
Pl_SetMoveLeftAction:
	ld   hl, sPlFlags
	res  OBJLSTB_XFLIP, [hl]		; Left direction
	jr   Pl_SetMoveAction
	
; =============== Pl_DoCtrl_Stand_CheckIceSlide ===============
; Handles the ice sliding movement when standing still.
Pl_DoCtrl_Stand_CheckIceSlide:
	ld   a, [sPlIceDelayTimer]
	and  a
	jr   z, Pl_DoCtrl_Stand_CheckUp2
	;--
	dec  a							; Timer--
	ld   [sPlIceDelayTimer], a
	jr   z, .endSlide				; Are we done yet?
.notDone:
	ld   a, [sPlIce]
	and  a						; Are we still on ice?	
	jr   z, .endSlide			; If not, end the slide
	
	; Which direction?
	ld   a, [sPlIceDelayDir]
	bit  7, a					; $FF: left
	jr   nz, .leftSlide
.rightSlide:
	call Level_ScreenLock_DoRight
	; If we reached a solid block, stop the effect
	call PlBGColi_DoFront
	dec  a
	ret  z
	; Slow down the slide speed by half near the end of the slide
	ld   a, [sPlIceDelayTimer]
	cp   a, $08					; >= $08?
	jr   nc, .normSpeedR		; If so, always move 1px/frame
	ld   a, [sTimer]			; Otherwise, move 0.5px/frame
	and  a, $01
	ret  nz
.normSpeedR:
	ld   b, $01
	jp   Pl_MoveRightWithScreen
.leftSlide:
	call Level_ScreenLock_DoLeft
	; If we reached a solid block, stop the effect
	call PlBGColi_DoFront
	dec  a
	ret  z
	; Slow down the slide speed by half near the end of the slide
	ld   a, [sPlIceDelayTimer]
	cp   a, $08
	jr   nc, .normSpeedL
	ld   a, [sTimer]
	and  a, $01
	ret  nz
.normSpeedL:
	ld   b, $01
	jp   Pl_MoveLeftWithScreen
.endSlide:
	xor  a
	ld   [sPlIceDelayTimer], a
	ld   [sPlIceDelayDir], a
	
; Handles the holding up action (again), for generating 10-coins this time.
Pl_DoCtrl_Stand_CheckUp2:
	; Don't allow holding up altogether while there's a dragon flame.
	ld   a, [sPlDragonHatActive]
	and  a							
	jr   nz, .end
	;--
	ldh  a, [hJoyKeys]
	bit  KEYB_UP, a				; Holding up?		
	jr   nz, .holdAnim
.end:
	; End of chain -- handle the idle pose
	call Pl_DoCtrl_Stand_Idle
	ret
	;--
.holdAnim:
	; Can't generate coins if we're already holding something
	; (the correct anim would be set previously too)
	ld   a, [sActHeld]
	and  a
	ret  nz
	; Pick the correct frame
	ld   a, OBJ_WARIO_HOLD
	ld   [sPlLstId], a
	ld   a, [sSmallWario]
	and  a
	jr   z, .checkHoldCoin
	ld   a, OBJ_SMALLWARIO_HOLD
	ld   [sPlLstId], a
	
.checkHoldCoin:
	; When holding UP and pressing B, generate a 10-coin
	ldh  a, [hJoyNewKeys]
	bit  KEYB_B, a
	ret  z
	; Do we have enough coins to do this?
	ld   a, [sLevelCoins_High]
	and  a						; >= 100 ok
	jr   nz, .make10Coin
	ld   a, [sLevelCoins_Low]
	cp   a, $10					; >= 10 ok
	jr   nc, .make10Coin
.denied:
	ld   a, SFX2_01
	ld   [sSFX2Set], a
	ret
.make10Coin:
	call SubCall_ActS_Spawn10CoinHeld
	call .decStats
	ret
.decStats:
	ld   a, [sActHeld]
	and  a
	jr   z, .denied
	; Subtract 10 coins from the total
	ld   a, [sLevelCoins_Low]
	sub  a, $0A
	daa
	ld   [sLevelCoins_Low], a
	ld   a, [sLevelCoins_High]
	sbc  a, $00
	ld   [sLevelCoins_High], a
	; Update the coin counter
	call StatusBar_DrawLevelCoins
	ld   a, SFX1_10
	ld   [sSFX1Set], a
	ret
	
; =============== Pl_DoCtrl_Walk ===============
Pl_DoCtrl_Walk:
	; Did we start holding an actor? (held:1, last:0)
	ld   a, [sActHeld]
	and  a					
	jr   z, Pl_DoCtrl_Walk_CheckThrow
	ld   a, [sActHeldLast]
	and  a
	jr   nz, Pl_DoCtrl_Walk_CheckThrow
; =============== Pl_SetGrab2Action ===============
; Switches to the beginning of the grab action.
Pl_SetGrab2Action:
	ld   a, PL_ACT_ACTGRAB2
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	xor  a
	ld   [sPlTimer], a
	
	; Pick the correct player anim depending on big/small status
IF FIX_BUGS == 1
		ld   a, [sSmallWario]	
		and  a					; Are we small Wario?
		jr   nz, .plSmall		; If so, jump
		ld   a, [sPlDuck]
		and  a					; Are we ducking?
		jr   nz, .plDuck		; If so, jump
		
	.plBig:
		ld   a, OBJ_WARIO_GRAB
		ld   [sPlLstId], a
		ret
	.plDuck:
		ld   a, OBJ_WARIO_DUCKHOLD
		ld   [sPlLstId], a
		ret
	.plSmall:	
		ld   a, OBJ_SMALLWARIO_HOLD
		ld   [sPlLstId], a
		ret
	
ELSE
	ld   a, OBJ_WARIO_GRAB	; Default to normal grab
	ld   [sPlLstId], a
	ld   a, [sSmallWario]	; If we're small, pick the other one
	and  a
	ret  z
	ld   a, OBJ_SMALLWARIO_HOLD
	ld   [sPlLstId], a
	

	; [BUG] Badly placed check.
	; This is checked only if we're Small Wario, who can never duck.
	; As a result, the correct grab anim isn't used when ducking (until the anim ends).
	ld   a, [sPlDuck]
	and  a
	ret  z
	;--
	; [TCRF] So this is unreachable as a result.
	ld   a, OBJ_WARIO_DUCKHOLD
	ld   [sPlLstId], a
	ret
ENDC
	
Pl_DoCtrl_Walk_CheckThrow:
	; If we were holding something in the last frame but we aren't anymore, throw the actor.
	ld   a, [sActHeldLast]
	and  a
	jr   z, Pl_DoCtrl_Walk_CheckLadderUp
	ld   a, [sActHeld]
	and  a
	jp   z, Pl_StartThrowAction
	
Pl_DoCtrl_Walk_CheckLadderUp:
	; When pressing/holding up, always try to grab a ladder
	ldh  a, [hJoyKeys]
	bit  KEYB_UP, a
	jr   z, Pl_DoCtrl_Walk_CheckLadderDown
	call PlBGColi_CheckLadderLow		; Is there a ladder at low body level?
	and  a
	jp   nz, Pl_GrabLadder				; If so, jump
Pl_DoCtrl_Walk_CheckLadderDown:
	; Do the same when pressing/holding down.
	ldh  a, [hJoyKeys]
	bit  KEYB_DOWN, a
	jr   z, Pl_DoCtrl_Walk_CheckMain
	call PlBGColi_DoGround			; Is there a ladder below?
	ld   a, [sPlBGColiLadderType]
	and  a
	jp   nz, Pl_SetClimbAction			; If so, jump
Pl_DoCtrl_Walk_CheckMain:
	; Main player ctrl checks
	
	; Start a (moving) jump when pressing A
	ldh  a, [hJoyNewKeys]
	bit  KEYB_A, a
IF IMPROVE == 1
	jp   nz, Pl_StartJump
ELSE
	jp   nz, Pl_StartMovingJump
ENDC
	; Perform the powerup-specific action when pressing B
	ldh  a, [hJoyNewKeys]
	bit  KEYB_B, a
	call nz, Pl_StartActionB
	; If a new action was started in the last call, don't continue
	ld   a, [sPlNewAction]
	and  a
	ret  nz
	
	; What are we walking over?
	call PlBGColi_DoGround
	cp   a, COLI_WATER			; Water?
	jp   z, Pl_SwitchToSwim		; If so, jump
	and  a						; Nothing? (ie: walked off solid ground)
	jp   z, Pl_SwitchToJumpFall	; If so, jump
	
	; Disallow normal movement during super jumps
	ld   a, [sPlSuperJump]
	and  a
	ret  nz
	
	;--
	; If we're pressing down, start the duck action
	; (if we got here, the ladder check failed)
	
	; Small Wario can't duck
	ld   a, [sSmallWario]
	and  a
	jr   nz, .checkDir
	
	ldh  a, [hJoyKeys]
	bit  KEYB_DOWN, a
	jp   nz, Pl_SetDuckAction
	;--
.checkDir:
	; Which direction are we moving to?
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jp   nz, Pl_WalkRight
	bit  KEYB_LEFT, a
	jp   nz, Pl_WalkLeft
	
	;--
	; If neither, stop the movement and switch to the stand action
	; Though if we're on ice we need to setup the slide effect first
	ld   a, [sPlIce]			
	and  a
	jp   z, Pl_SwitchToStand
	
	; Determine the length of the slide.
	; When starting to move left or right on ice, a countdown is set before you're allowed moving (while still in the walk action).
	; If we switch back to the Stand action before the countdown reaches $00, a short slide will be picked here.
	ld   a, [sPlIceDelayTimer]
	and  a						; Did we interrupt the pre-movement countdown?
	jr   nz, .shortSlide		; If so, jump
	
.normSlide:

	; Pick the direction depending on OBJ orientation
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a		; Player facing right?
	jr   nz, .iceRight			; If so, jump
.iceLeft:
	ld   a, $20
	ld   [sPlIceDelayTimer], a
	ld   a, -$01
	ld   [sPlIceDelayDir], a
	jp   Pl_SwitchToStand
.iceRight:
	ld   a, $20
	ld   [sPlIceDelayTimer], a
	ld   a, +$01
	ld   [sPlIceDelayDir], a
	jp   Pl_SwitchToStand
	
.shortSlide:

	; Pick the direction depending on OBJ orientation
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a		; Player facing right?
	jr   nz, .iceRight2			; If so, jump
.iceLeft2:
	ld   a, $10
	ld   [sPlIceDelayTimer], a
	ld   a, -$01
	ld   [sPlIceDelayDir], a
	jp   Pl_SwitchToStand
.iceRight2:
	ld   a, $10
	ld   [sPlIceDelayTimer], a
	ld   a, +$01
	ld   [sPlIceDelayDir], a
	jp   Pl_SwitchToStand
	
; =============== Pl_DoCtrl_Duck ===============
Pl_DoCtrl_Duck:
	; Small Wario can't duck
	ld   a, [sSmallWario]
	and  a						; Are we Small Wario?
	jp   nz, Pl_SwitchToStand	; If so, we can't duck
	
	; Did we start holding an actor?
	ld   a, [sActHeld]
	and  a						; held: 1?
	jr   z, .checkThrow			; If not, skip
	ld   a, [sActHeldLast]
	and  a						; last: 0?
	jr   nz, .checkThrow		; If not, skip
	jp   Pl_SetGrab2Action
.checkThrow:
	; Have we been signaled to throw an actor?
	ld   a, [sActHeldLast]
	and  a						; last: != 0?
	jr   z, .chkGroundColi		; If not, skip
	ld   a, [sActHeld]
	and  a						; held: 0?
	jp   z, Pl_StartThrowAction	; If not, jump
.chkGroundColi:

	; Check what we're crouching over
	call PlBGColi_DoGround
	cp   a, COLI_WATER				; Water?
	jp   z, Pl_SwitchToSwim			; If so, switch to the swim
	and  a							; Empty?
	jp   z, Pl_SwitchToJumpFall2	; If so, switch to crouch jump
	
	; If there's a bounce block on the ground, we're in the jump state.
	; Don't handle the crouching for this frame.
	ld   a, [sPlSuperJump]
	and  a
	ret  nz
	
	; Start the powerup specific action when pressing B
	ldh  a, [hJoyNewKeys]
	bit  KEYB_B, a
	call nz, Pl_StartActionB
	ld   a, [sPlNewAction]	; If we've started a new one don't continue
	and  a
	ret  nz
	
	;--
	; Check for uncrouch
	; Not holding DOWN should normally return to the stand action,
	; unless theres's a solid block on top
	ldh  a, [hJoyKeys]
	bit  KEYB_DOWN, a		; Still holding DOWN?
	jr   nz, .checkDuckJump	; If so, jump
	
	ldh  a, [hJoyNewKeys]
	bit  KEYB_A, a			; Starting a jump?
	jr   nz, .startDuckJump	; If so, jump
	
	; Check the collision on top
	xor  a					; Simulate uncrouch to check for top block
	ld   [sPlDuck], a
	ld   a, $01				; Read-only ish state (don't destroy blocks, etc...)
	ld   [sPlBGColiSolidReadOnly], a
	call PlBGColi_DoTop
	; [POI] This causes water blocks on top to be treated as solid (through glitches)
	and  a					; Is there an empty block on top?
	jr   nz, .keepDuck		; If not, keep ducking
	xor  a
	ld   [sPlBGColiSolidReadOnly], a
	jp   Pl_SwitchToStand
	;--
.checkDuckJump:
	ldh  a, [hJoyNewKeys]
	bit  KEYB_A, a			; Starting a jump?
	jr   z, .keepDuck		; If not, skip
.startDuckJump:
	; Check if we can actually jump
	; Since we're explicitly trying to move this doesn't use read-only mode
	xor  a					; Simulate uncrouch to check for top block
	ld   [sPlDuck], a
	call PlBGColi_DoTop	; Check collosion and trigger any blocks
	and  a					; Is there an empty block on top?
	jr   nz, .keepDuck		; If not, keep ducking
	; Otherwise, start a duck jump
	ld   a, $01
	ld   [sPlDuck], a
	jp   Pl_StartJump
.keepDuck:
	xor  a
	ld   [sPlBGColiSolidReadOnly], a
	ld   a, $01
	ld   [sPlDuck], a
	; Now that we know the player is still ducking, handle right/left movement
.checkMoveRight:
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jr   z, .checkMoveLeft
	;--
	ld   hl, sPlFlags			; Set dir
	set  OBJLSTB_XFLIP, [hl]
	call Pl_Anim2FrameSlow
	
	; If there's a solid block in front of the player, don't move
	; Since ducking reduces the player height, there's only one block which can be triggered
	
	; [POI] And this is why moving while ducking underwater works (through glitches)
	call PlBGColi_DoFront
	dec  a							; Is there a solid block?
	ret  z							; If so, return
	; Move at 0.5px/frame
	ld   a, [sTimer]
	and  a, $01
	ret  nz
	call Level_ScreenLock_DoRight	; Setup screenlock for Pl_MoveRightWithScreen
	ld   b, $01						; Move player/screen
	jp   Pl_MoveRightWithScreen
.checkMoveLeft:
	ldh  a, [hJoyKeys]
	bit  KEYB_LEFT, a
	jr   z, .end
	;--
	ld   hl, sPlFlags			; Set dir
	res  OBJLSTB_XFLIP, [hl]
	call Pl_Anim2FrameSlow
	
	; If there's a solid block in front of the player, don't move
	call PlBGColi_DoFront
	dec  a							; Is there a solid block?
	ret  z							; If so, return
	; Move at 0.5px/frame
	ld   a, [sTimer]
	and  a, $01
	ret  nz
	call Level_ScreenLock_DoLeft	; Setup screenlock for Pl_MoveRightWithScreen
	ld   b, $01						; Move player/screen
	jp   Pl_MoveLeftWithScreen
	
.end:
	; If we got here, we're standing still while ducking
	xor  a
	ld   [sPlTimer], a
	
	ld   a, OBJ_WARIO_DUCK		; Set main frame
	ld   [sPlLstId], a
	ld   a, [sActHeld]			
	and  a						; Are we holding something?
	ret  z						; If not, return
	ld   a, OBJ_WARIO_DUCKHOLD	; If so, Set the hold frame
	ld   [sPlLstId], a
	ret
; =============== Pl_DoCtrl_Climb ===============
Pl_DoCtrl_Climb:
	; Check for all possible directions when climbing a ladder.
	; There's no distinction between vertical-only ladders and freeroam ladders in this game.
	
	ldh  a, [hJoyKeys]
	bit  KEYB_UP, a
	jr   z, .checkDown
	;--
	
	; Check if we reached the end of the top-solid ladder block.
	; Keep in mind top solid blocks count as solid only at the top 3 pixel rows.
	call PlBGColi_CheckLadderLow
	and  a								; Is there a solid block on the low part of the body?
	jr   z, .switchToStand				; If so, switch to the stand action
	
	xor  a
	ld   [sPlTimer], a
	call Level_Scroll_CheckSegScroll	; Scroll the screen when needed
	and  a								; Did we do it?
	ret  nz								; If so, return
	
	call Pl_AnimClimb
	
	; CheckTop really isn't that great for this, since when big it makes
	; the solid collision check the opposite of generous.
	call PlBGColi_DoTop
	and  a								; Is there an empty block above?
	ret  nz								; If not, return
	ld   b, $01							; Otherwise, move up by 1px
	call Pl_MoveUp
	ret
.checkDown:
	ldh  a, [hJoyKeys]
	bit  KEYB_DOWN, a
	jr   z, .noVMove
	;--
	
	call Level_Scroll_CheckSegScroll	; Scroll the screen when needed
	and  a								; Did we do it?
	ret  nz								; If so, return
	
	call Pl_AnimClimb
	
	
IF FIX_FUN_BUGS == 1
	; Reorganized to work with the ladder body being set as COLI_EMPTY.
	
	; Even when not moving, always check what we're over
	call PlBGColi_CheckLadderLow
	and  a							; Are we over a ladder block?
	jr   nz, .moveDown				; If so, skip ahead
	
	call PlBGColi_DoGround
	cp   a, COLI_WATER				; Is there water below?
	jp   z, Pl_SwitchToSwim			; If so, jump
	and  a							; Is it empty below?
	jp   z, Pl_SwitchToJumpFall2	; If so, fall
	
	ld   a, [sPlBGColiLadderType]		
	and  a							; Is there a ladder block below?
	jr   z, .switchToStand			; If not, it's a solid
ELSE
	; This is also not great for ladders; again when big, *only* checking 
	; for the bottom collision makes it the opposite of generous.
	call PlBGColi_DoGround
	cp   a, COLI_WATER					; Is there water below?
	jp   z, Pl_SwitchToSwim				; If so, jump
	and  a								; Is it empty below?
	jp   z, Pl_SwitchToJumpFall2		; If so, fall
	
	ld   a, [sPlBGColiLadderType]		
	and  a								; Is there a ladder block below?
	jr   z, .switchToStand				; If not, it's a solid
ENDC
.moveDown:
	ld   b, $01							; Otherwise, move downwards 
	call Pl_MoveDown
	ret
.switchToStand:
	; Align the player to the closest block Y boundary,
	; to make sure the player stands in the ground instead of briefly falling
	ld   a, [sPlY_Low]				
	and  a, $F0
	ld   [sPlY_Low], a
	jp   Pl_SwitchToStand
	
.noVMove:
IF FIX_FUN_BUGS == 1
	; Reorganized to work with the ladder body being set as COLI_EMPTY.
	
	; Even when not moving, always check what we're over
	call PlBGColi_CheckLadderLow
	and  a							; Are we over a ladder block?
	jr   nz, .checkHMove			; If so, skip ahead
	
	call PlBGColi_DoGround
	cp   a, COLI_WATER				; Water?
	jp   z, Pl_SwitchToSwim
	and  a							; Empty?
	jp   z, Pl_SwitchToJumpFall2
	jr   .switchToStand				; Solid!
ELSE
	; Even when not moving, always check what we're over
	call PlBGColi_DoGround
	cp   a, COLI_WATER				; Water?
	jp   z, Pl_SwitchToSwim
	and  a							; Empty?
	jp   z, Pl_SwitchToJumpFall2
	
	call PlBGColi_CheckLadderLow
	and  a							; Solid?
	jr   z, .switchToStand
ENDC

	;--
.checkHMove:
	ldh  a, [hJoyKeys]
	and  a, KEY_LEFT|KEY_RIGHT		; Is there horizontal movement?
	ret  z							; If not, return
	call Pl_AnimClimb
	ldh  a, [hJoyKeys]				; Otherwise move the appropriate direction
	bit  KEYB_RIGHT, a
	jp   nz, Pl_AirMoveRight
	jp   Pl_AirMoveLeft
	
IF IMPROVE == 0
	; =============== Pl_StartMovingJump ===============
	; This subroutine starts a jump from the ground when walking.
	; This one sets a flag that allows horizontal movement by just holding A,
	; without explicitly holding LEFT/RIGHT.
	; The code to handle this is in Pl_DoCtrl_Jump.
	Pl_StartMovingJump:
		ld   a, $01
		ld   [sPlMovingJump], a
ENDC

; =============== Pl_StartJump ===============
; This subroutine starts a jump from the ground.
; Not for the dash-jump.
Pl_StartJump:
	ld   a, [sPlSuperJumpSet]
	and  a						; Are we being launched up by a bounce block?
	jr   z, .normal				; If not, jump
.bounceBlock:
	xor  a						; Reset the request flag
	ld   [sPlSuperJumpSet], a
	ld   a, $01					; Activate the superjump proper
	ld   [sPlSuperJump], a
	ld   a, SFX1_2E				; Play a different SFX
	ld   [sSFX1Set], a
	jr   .startJump
.normal:
	ld   a, SFX1_05
	ld   [sSFX1Set], a
.startJump:
	; Start from the first entry since this starts a full jump
	xor  a
	ld   [sPlJumpYPathIndex], a
	
	; Clear the automatic movement/scrolling from the conveyor belt.
	; ...except during an autoscroller, since those also determine the scroll speed!
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_CHKAUTO	; Are we in an autoscroller?
	jr   nc, .chkSlow			; If so, jump
	xor  a						; Otherwise, reset those...?
	ld   [sLvlAutoScrollDir], a
	ld   [sLvlAutoScrollSpeed], a
	
.chkSlow:
	; Check if the slow jump should be anabled, caused by carrying heavy enemies.
	
	; If we're Bull Wario, the jump is never slow
	ld   a, [sPlPower]		
	cp   a, PL_POW_BULL
	jr   z, .normalJump
	; If we aren't holding anything, we obviously aren't holding an heavy enemy
	; (why do we check this?)
	ld   a, [sActHeld]			
	and  a
	jr   z, .normalJump	; If not, jump
	; Are we holding a heavy enemy?
	ld   a, [sActHoldHeavy]				
	and  a
	jr   z, .normalJump	; If not, jump
	
	ld   a, $01
	ld   [sPlSlowJump], a
	
.normalJump:
	xor  a
	ld   [sPlIceDelayTimer], a
	ld   [sPlIceDelayDir], a
	; Trigger jump action
	ld   a, PL_ACT_JUMP
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	; If we're holding UP, trigger an high jump
	ldh  a, [hJoyKeys]
	bit  KEYB_UP, a
	ret  z
	ld   a, $01
	ld   [sHighJump], a
	ret
; =============== Pl_StartJetDashWater ===============
; Starts the underwater jet dash action.
Pl_StartJetDashWater:
	ld   a, $01					; Signal an action
	ld   [sPlWaterAction], a
	xor  a						; Unmark the ground swim action
	ld   [sPlSwimGround], a
	
IF IMPROVE == 0
	; If there isn't a solid block above, jet dashing moves the player upwards by 2px.
	; This is very likely done to (badly) mask a collision bug which is easy to fix anyway.
	ld   a, $01
	ld   [sPlBGColiSolidReadOnly], a
	call PlBGColi_DoTop
	dec  a							; Is there a solid block above?
	jr   z, .noMoveUp				; If so, don't move up
	ld   b, $02
	call Pl_MoveUp
.noMoveUp:
	xor  a
	ld   [sPlBGColiSolidReadOnly], a
ENDC
	ret
	
; =============== Pl_DoCtrl_Swim ===============
Pl_DoCtrl_Swim:
	ldh  a, [hJoyNewKeys]
	bit  KEYB_B, a					; Start a new action on B
	call nz, Pl_StartActionB_JetOrDragon
	
	ld   a, [sPlJetDashTimer]
	and  a							; Did we start an underwater jet dash?
	jr   nz, Pl_StartJetDashWater	; If so, jump
	
	call ExActS_SpawnBubble			; Try to spawn bubble
	
	ld   a, [sPlSwimGround]		
	and  a							; Are we walking on the ground?
	jp   nz, Pl_SwimGroundWalk				; If so, jump
	;--
	
	;
	; SWIMMING CONTROLS
	;
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a			; Swim left
	call nz, Pl_AirMoveRight
	ldh  a, [hJoyKeys]
	bit  KEYB_LEFT, a			; Swim right
	call nz, Pl_AirMoveLeft
	
	ldh  a, [hJoyNewKeys]
	bit  KEYB_A, a				; Starting to swim up?
	jp   nz, Pl_StartSwimUp
	ld   a, [sPlSwimUpTimer]
	and  a						; Continuing to swim up?
	jp   nz, Pl_SwimUp
	
; =============== Pl_SwimDown ===============
; Handles the descent during swimming down (or idle).
Pl_SwimDown:
	call Pl_Anim2Frame
	
	; Handle the ground collision
	call PlBGColi_DoGround
	and  a							; Is there an empty block below?
	jp   z, Pl_SwitchToJumpFall2	; If so, fall
	cp   a, COLI_SOLID				; Is there a solid block?
	jp   z, Pl_SwitchToSwimStand	; If so, stand on the ground
	
	; Otherwise, move down on the water.
	; Pick different speed depending on action.
	ld   a, [sLvlAutoScrollDir]
	and  a							; Are we being moved by a water current?
	jr   z, .moveDownSlow			; If not, descent slowly
	ldh  a, [hJoyKeys]
	bit  KEYB_DOWN, a				; Are we explictly moving down?
	jr   nz, .moveDown				; If so, descent faster
	
	ld   a, [sLvlAutoScrollDir]
	bit  DIRB_U, a					; Are we on a downwards current?
	ret  nz							; If so, don't do anything (the block code for that handles it)
	
	; Otherwise, move down *very* slowly (0.0625px/frame) which is done
	; to reduce "falling off" currents while still having some descent
	ld   a, [sTimer]
	and  a, $0F
	ret  nz
	jr   .moveDown
.moveDownSlow:
	; When moving down, holding down increases the descent speed.
	; 0.5px/frame -> 1px/frame
	ldh  a, [hJoyKeys]
	bit  KEYB_DOWN, a		; Holding DOWN?
	jr   nz, .moveDown		; If so, move down all the frames
	ld   a, [sTimer]		; otherwise, move down every other frame
	and  a, $01
	ret  nz
.moveDown:
	ld   b, $01
	call Pl_MoveDown
	ret
; =============== Pl_SwimUp ===============
; Handles the swimming up part.
Pl_SwimUp:
	; Trigger the top collision.
	call PlBGColi_DoTop
	and  a ; COLI_EMPTY		; Empty block?
	jr   z, .exitWater		; 
	cp   a, COLI_WATER		; Water block?
	jr   z, .moveUp			; 
	
	; Otherwise, it's a solid block.
	; Prevent moving further up.
	
	; If we're still trying to swim up (or the timer wasn't reset yet), don't move downwards
	ld   a, [sPlSwimUpTimer]
	and  a						
	jr   nz, .setAnim			; Skip the .moveUp part
	
	; If we got here, the collision code for a block manually reset the timer (ie: breakable blocks)
	; This signals to ignore upwards movement and start the descent.
	jr   .useAltFrame			
.moveUp:
	ld   b, $01
	call Pl_MoveUp
	
.setAnim:
	; Update the swim timer. This is used for three things:
	; - Marking if we're swimming up (!=0) or not.
	; - Time the animation frames used for swimming
	; - Adding a slight delay before checking if we're still swimming up
	;   as a way to do pseudo momentum.

	ld   hl, sPlSwimUpTimer		; SwimTimer++
	ld   a, [hl]
	inc  a
	ld   [hl], a
	
	cp   a, $0A					; Reached $0A?		
	jr   z, .useAltFrame		; If so, switch to a different frame
	cp   a, $10					; Reached $10?
	ret  nz						; If not, don't check for input yet
	
	; And this is how the frame switch works.
	; If we're still holding A, we jump to the swim start code,
	; which resets the timer to $01 and the anim frame.
	ldh  a, [hJoyKeys]			
	bit  KEYB_A, a
	jr   nz, Pl_StartSwimUp
	
	; If we aren't, reset sPlSwimUpTimer to $00 which begins the descent
	ld   [hl], $00
	ret
	
.exitWater:
	; Play SFX and switch to jump action
	xor  a
	ld   [sPlSwimUpTimer], a
	ld   a, SFX4_0D
	ld   [sSFX4Set], a
	jp   Pl_StartJump
	
.useAltFrame:
	; Pick correct frame depending on player status.
	; Because of how the timer works, OBJ_WARIO_SWIM0 always ends up being picked before starting the descent.
	; Which is important since OBJ_WARIO_SWIM0 is next to OBJ_WARIO_SWIM1, allowing the descent code to use Anim2Frame.
	ld   a, OBJ_WARIO_SWIM0		
	ld   [sPlLstId], a
	ld   a, [sSmallWario]
	and  a						
	ret  z						
	ld   a, [sPlLstId]
	add  OBJ_SMALLWARIO_SWIM0-OBJ_WARIO_SWIM0
	ld   [sPlLstId], a
	ret
; =============== Pl_StartSwimUpFromGround ===============
; This subroutine makes the player start swimming up.
; Used when the player is standing on the ground.
Pl_StartSwimUpFromGround:
	xor  a
	ld   [sPlSwimGround], a
	ld   [sPlDuck], a
	
	
; =============== Pl_StartSwimUp ===============
; This subroutine makes the player start swimming up.
Pl_StartSwimUp:
	ld   a, SFX1_12		; play SFX
	ld   [sSFX1Set], a
	ld   a, $01				; the important part
	ld   [sPlSwimUpTimer], a
	
	ld   a, OBJ_WARIO_SWIM2	; set frame
	ld   [sPlLstId], a
	ld   a, [sSmallWario]
	and  a
	ret  z
	ld   a, [sPlLstId]
	add  OBJ_SMALLWARIO_SWIM2-OBJ_WARIO_SWIM2
	ld   [sPlLstId], a
	ret
	
; =============== Pl_SwimGroundWalk ===============
; Handles the player walking on the ground underwater.
Pl_SwimGroundWalk:
	; If the player is ducking, don't allow swimming up
	ld   a, [sPlDuck]
	and  a								; Ducking?
	jr   nz, .chkType					; If so, skip it
	ldh  a, [hJoyNewKeys]
	bit  KEYB_A, a
	jr   nz, Pl_StartSwimUpFromGround
	
.chkType:
	; Which action are we on?
	ld   a, [sPlSwimGround]
	dec  a
	jr   z, Pl_SwimGroundWalk_Stand
	dec  a
	jr   z, Pl_SwimGroundWalk_Duck
	jp   Pl_SwimGroundWalk_Walk
	
; =============== Pl_SwimGroundWalk_Stand ===============
; Handles when the player stands idle underwater.
Pl_SwimGroundWalk_Stand:
	; Check for all controls
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jp   nz, Pl_StartSwimWalkRight
	bit  KEYB_LEFT, a
	jp   nz, Pl_StartSwimWalkLeft
	bit  KEYB_DOWN, a
	jp   nz, Pl_StartSwimDuck
	bit  KEYB_UP, a
	jr   z, Pl_SwimGroundWalk_DoStandColi	; No manual movement
.upKey:
	; Try to enter a door
	call PlBGColi_GetBlockIdLow
	cp   a, BLOCKID_WATERDOOR	; Are we colliding with a door?
	ret  nz						; If not, return
	ld   a, [sPlBgColiBlockEq]		
	and  a						; Are we *only* colliding with the door?
	ret  z						; If not, return
	call Level_EnterDoor		; If so, enter the door
	ret
; =============== Pl_SwimGroundWalk_DoStandColi ===============
; Handles the block collision when standing underwater idle.
Pl_SwimGroundWalk_DoStandColi:
	; If we aren't over ground anymore (ie: moved away by a water current),
	; make the player fall while swimming
	call PlBGColi_DoGround
	cp   a, COLI_WATER
	jp   z, Pl_SwimGroundWalk_StartSwimFall
	
	;--
	; To handle collision on the back, simply invert the player orientation.
	; before calling PlBGColi_DoFront.
	;
	; The reason we do this is because water current are one of the few ways
	; the player can move while facing the opposite direction.
	; The normal collision check on the front ignores what's behind the player. 
	ld   a, [sPlFlags]
	xor  OBJLST_XFLIP
	ld   [sPlFlags], a
	call PlBGColi_DoFront
	ld   a, [sPlFlags]
	xor  OBJLST_XFLIP
	ld   [sPlFlags], a
	;--
	; Handle what's ground-specific
	
	; Ignore currents moving the player down, since we're already walking on ground
	ld   a, [sLvlAutoScrollDir]
	res  DIRB_D, a
	ld   [sLvlAutoScrollDir], a
	;--
	; If there's a current moving us left or right already, ignore upwards currents.
	bit  DIRB_R, a
	jr   nz, .end
	bit  DIRB_L, a
	jr   nz, .end
	;--
	; Upwards water current should make the player leave the ground state
	bit  DIRB_U, a
	jp   nz, Pl_StartSwimUpFromGround
	ret
.end:
	ret
; =============== Pl_SwimGroundWalk_Duck ===============
; The player stands idle underwater.
Pl_SwimGroundWalk_Duck:
	; The duck state needs to be reconfirmed every time.
	xor  a
	ld   [sPlDuck], a
	
	ldh  a, [hJoyKeys]
	bit  KEYB_DOWN, a					; Are we holding DOWN?
	jr   nz, Pl_SwimGroundWalk_SetDuck	; If so, confirm ducking
	
	; If not, check what's above us without activating any solid blocks
	ld   a, $01
	ld   [sPlBGColiSolidReadOnly], a
	call PlBGColi_DoTop
	dec  a								; Is there a solid block? 
	jr   z, Pl_SwimGroundWalk_SetDuck	; If so, keep ducking
	xor  a
	ld   [sPlBGColiSolidReadOnly], a
.noDuck:
	; This almost seems a mistake that it uses hJoyNewKeys instead of hJoyKeys
	; As a result it's very difficult to trigger.
	ldh  a, [hJoyNewKeys]
	bit  KEYB_A, a
	jp   nz, Pl_StartSwimUpFromGround
	
	; You can check for those too.
	; The standing action would handle those anyway the next frame...
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jr   nz, Pl_StartSwimWalkRight
	bit  KEYB_LEFT, a
	jr   nz, Pl_StartSwimWalkLeft
	jr   Pl_SwitchToSwimStand
; =============== Pl_SwimGroundWalk_SetDuck ===============
; Starts/Confirms the ducking state for the player.
Pl_SwimGroundWalk_SetDuck:
	ld   a, $01					; Set duck state
	ld   [sPlDuck], a
	xor  a
	ld   [sPlBGColiSolidReadOnly], a
	ld   [sPlTimer], a
	ld   a, OBJ_WARIO_DUCK
	ld   [sPlLstId], a
	jr   Pl_SwimGroundWalk_DoStandColi
	
; =============== Pl_StartSwimWalkRight ===============
; Makes the player start walking right underwater.
Pl_StartSwimWalkRight:
	ld   hl, sPlFlags
	set  OBJLSTB_XFLIP, [hl]	; Set right orientation
	jr   Pl_StartSwimWalk
; =============== Pl_StartSwimWalkRight ===============
Pl_StartSwimWalkLeft:
	; Makes the player start walking right underwater.
	ld   hl, sPlFlags
	res  OBJLSTB_XFLIP, [hl]	; Set left orientation
; =============== Pl_StartSwimWalk ===============
Pl_StartSwimWalk:
	xor  a
	ld   [sPlTimer], a
	ld   a, OBJ_WARIO_WALK0		; Set initial frame (when big)
	ld   [sPlLstId], a
	ld   a, PL_SGM_WALK			; Set ground mode
	ld   [sPlSwimGround], a
	ld   a, [sSmallWario]		; Replace frame if small
	and  a
	ret  z
	ld   a, [sPlLstId]
	add  OBJ_SMALLWARIO_WALK0-OBJ_WARIO_WALK0
	ld   [sPlLstId], a
	ret
; =============== Pl_StartSwimDuck ===============
; Makes the player start ducking underwater.
Pl_StartSwimDuck:
	; Small Wario can't duck
	ld   a, [sSmallWario]
	and  a
	jr   nz, Pl_SwitchToSwimStand
	
	ld   a, PL_SGM_DUCK				; Switch mode
	ld   [sPlSwimGround], a
	jr   Pl_SwimGroundWalk_SetDuck			; Set anim frame
	
; =============== Pl_SwitchToSwimStand ===============
; Marks the player as having landed on the ground underwater.
Pl_SwitchToSwimStand:
	ld   a, [sPlY_Low]
	and  a, $F0					; Align to Y block boundary
	ld   [sPlY_Low], a
	ld   a, $01					; Set ground walk mode
	ld   [sPlSwimGround], a
	ld   a, OBJ_WARIO_STAND		; Set anim frame
	ld   [sPlLstId], a
	ld   a, [sSmallWario]
	and  a
	ret  z
	ld   a, [sPlLstId]
	add  OBJ_SMALLWARIO_STAND-OBJ_WARIO_STAND
	ld   [sPlLstId], a
	ret
; =============== Pl_SwimGroundWalk_Walk ===============
; The player is walking on the ground underwater.
Pl_SwimGroundWalk_Walk:
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a	; Are we facing right?
	jr   z, .left			; If not, jump
.right:
	ldh  a, [hJoyKeys]
	bit  KEYB_LEFT, a					; Moving left now?
	jr   nz, Pl_StartSwimWalkLeft
	bit  KEYB_DOWN, a					; Starting to duck?
	jr   nz, Pl_StartSwimDuck
	and  a, KEY_RIGHT|KEY_LEFT|KEY_DOWN	; Holding any of these keys?
	jr   z, Pl_SwitchToSwimStand		; If not, stand
	;--
	; Perform right movement if possible
	
	call Pl_WalkAnimSlow
	
	; Walk speed: 0.25px/frame
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkWaterCurrent
	
	call Level_ScreenLock_DoRight	; Update right screen lock
	
	; Handle ground collision and
	; make sure there's a solid block below
	call PlBGColi_DoGround		; Handle ground collision
	cp   a, COLI_WATER				; Is there a water block below?
	jr   z, Pl_SwimGroundWalk_StartSwimFall
	and  a ; COLI_EMPTY				; Is there an empty block below?
	jp   z, Pl_SwitchToJumpFall2
	
	; Handle collision on front and
	; avoid movement if there's a solid block in the way
	
	; [BUG] Because of how block IDs are organized and because they took a shortcut in not checking	PlBGColi_DoHorzNext,
	;		this disables certain underwater collisions for rows of spikes.
	;
	;		Unlike normal spikes, which have a lower ID than empty blocks,
	;       underwater spikes have an higher ID than normal water blocks so they get less priority.
	;		As a result, you can walk through underwater spikes unharmed when there's a single row of spikes, 
	;		as long as you aren't Small Wario or ducking.
	;		See: The area near the key lock in C03B.
	
	call PlBGColi_DoFront		; Handle front collision
	dec  a ; COLI_SOLID				; Is there any solid block in front?
	jr   z, .chkWaterCurrent		; If so, skip movement
	
	ld   b, $01						; Move the player right 1px
	call Pl_MoveRightWithScreen
.chkWaterCurrent:
	; Ignore downwards currents since we're on the ground already
	ld   a, [sLvlAutoScrollDir]
	res  DIRB_D, a
	ld   [sLvlAutoScrollDir], a
	; An upwards current should lift the player from the ground
	bit  DIRB_U, a
	jp   nz, Pl_StartSwimUpFromGround
	ret
.left:
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a					; Moving right now?
	jp   nz, Pl_StartSwimWalkRight
	bit  KEYB_DOWN, a					; Starting to duck?
	jr   nz, Pl_StartSwimDuck
	and  a, KEY_RIGHT|KEY_LEFT|KEY_DOWN	; Holding any of these keys?
	jr   z, Pl_SwitchToSwimStand		; If not, stand
	;--
	; Perform left movement if possible
	
	call Pl_WalkAnimSlow
	
	; Walk speed: 0.25px/frame
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkWaterCurrent
	
	call Level_ScreenLock_DoLeft		; Update left screen lock
	
	; Make sure there's a solid block below
	call PlBGColi_DoGround		; Handle ground collision
	cp   a, COLI_WATER				; Is there a water block below?
	jr   z, Pl_SwimGroundWalk_StartSwimFall
	and  a ; COLI_EMPTY				; Is there an empty block below?
	jp   z, Pl_SwitchToJumpFall2
	
	; Avoid movement if there's a solid block in the way
	call PlBGColi_DoFront		; Handle front collision
	dec  a ; COLI_SOLID				; Is there any solid block in front?
	jr   z, .chkWaterCurrent		; If so, skip movement
	
	ld   b, $01						; Move the player left 1px
	call Pl_MoveLeftWithScreen
	jr   .chkWaterCurrent
; =============== Pl_SwimGroundWalk_StartSwimFall ===============
; Makes the player swim after walking off a solid block underwater.
Pl_SwimGroundWalk_StartSwimFall:
	; Unmark ground/duck status
	xor  a
	ld   [sPlSwimGround], a
	ld   [sPlDuck], a
	; Set anim frame
	ld   a, OBJ_WARIO_SWIM0
	ld   [sPlLstId], a
	ld   a, [sSmallWario]
	and  a
	ret  z
	ld   a, [sPlLstId]
	add  OBJ_SMALLWARIO_SWIM0-OBJ_WARIO_SWIM0
	ld   [sPlLstId], a
	ret
; =============== ExActS_SpawnBubble ===============
; Spawns the underwater bubble coming in front of the player.
ExActS_SpawnBubble:
	; Spawn every 256 frames
	ld   a, [sTimer]
	and  a
	ret  nz
	; Prevent spawning if there's any other extra actor already spawned
	ld   a, [sExActCount]
	and  a
	ret  nz
	;--
.spawn:
	ld   a, EXACT_WATERBUBBLE
	ld   [sExActSet], a
	
	; Set Y coord
	ld   b, $04					; 4px above
	call PlTarget_SetUpPos
	ld   a, [sTarget_High]
	ld   [sExActOBJY_High], a
	ld   a, [sTarget_Low]
	ld   [sExActOBJY_Low], a
	
	; Set X coord
	; Place bubble around the front of the player
	ld   a, [sPlFlags]		
	bit  OBJLSTB_XFLIP, a		; meaning it's different depending on orientation
	jr   nz, .objRight
.objLeft:
	ld   b, $07
	call PlTarget_SetLeftPos
	jr   .setX
.objRight:
	ld   b, $10
	call PlTarget_SetRightPos
.setX:
	ld   a, [sTarget_High]
	ld   [sExActOBJX_High], a
	ld   a, [sTarget_Low]
	ld   [sExActOBJX_Low], a
	
	ld   a, OBJ_JETHATFLAME0	; nice reuse
	ld   [sExActOBJLstId], a
	xor  a
	ld   [sExActOBJFlags], a
	; Clear rest
	ld   hl, sExActLevelLayoutPtr_High
	xor  a
	ld   b, $09
	call ClearRAMRange_Mini
	
	call ExActS_Spawn
	ret

; =============== Pl_DoCtrl_Jump ===============
Pl_DoCtrl_Jump:
	; Starting a new action?
	ldh  a, [hJoyNewKeys]
	bit  KEYB_B, a							; Did we just press B?
	call nz, Pl_StartActionB_JetOrDragon	; If so, try to perform the powerup-specific air action
	ld   a, [sPlNewAction]
	and  a									; Did we effectively start a new action in Pl_StartActionB_JetOrDragon?
	ret  nz									; If so, don't execute the rest of this subroutine
	;--
	
	;
	; UP: LADDER GRAB
	;
	ldh  a, [hJoyKeys]
	bit  KEYB_UP, a			; Holding UP?
	jr   z, .main			; If not, jump
	
	call PlBGColi_CheckLadderLow	
	and  a					; Colliding with a ladder block?
	jr   z, .main			; If not, jump
IF IMPROVE == 0
	xor  a					; If so, end the jump
	ld   [sPlMovingJump], a
ENDC
	jp   Pl_GrabLadder		; and grab the ladder
	;--
.main:
	; Perform the jump
	call Pl_JumpAnim
	call Pl_JumpSetY
	ld   a, [sPlJumpYPathIndex]
	and  a								; Did the jump end? (index == $00)
	ret  z								; If so, return
	
	; Handle the normal air controls
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jp   nz, Pl_AirMoveRight
	bit  KEYB_LEFT, a
	jp   nz, Pl_AirMoveLeft
	
IF IMPROVE == 1
	; Moving jumps suck
	ret
ELSE
	;--
	; Special case for the "moving jumps", which are jumps started while walking (instead of standing still)
	; When holding A, the player automatically moves to the direction he's facing.
	
	; This is very questionable, since it makes these jumps imprecise and it ends up looking like a bug!
	; Releasing and pressing A in this state stops and starts movement, which doesn't help.
	
	bit  KEYB_A, a				; Holding A?
	ret  z						; If not, return
	ld   a, [sPlMovingJump]		; Is this a moving jump?
	and  a
	ret  z						; If not, return
	
	; Move player depending on the direction we're facing
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a	; Facing right?
	jp   z, Pl_AirMoveLeft	; If not, move left
	jp   Pl_AirMoveRight
	;--
ENDC
	
; =============== Pl_DoCtrl_ActInt ===============
; Used for actor interactions which freeze the player for a while.
; This includes:
; - Holding an actor on the ground (not while in the air)
; - Dashing against an enemy (not a jet dash).
Pl_DoCtrl_ActInt:
	; If somehow we're starting a jump at the same frame, it should count as an air grab.
	ldh  a, [hJoyNewKeys]
	bit  KEYB_A, a
	jr   nz, .skip
	
	; Until the timer elapses, don't return to the standing frame.
	; This disables the controls and freezes the player in the previously set anim.
	ld   a, [sPlDashHitTimer]
	dec  a
	ld   [sPlDashHitTimer], a
	ret  nz
	
	jp   Pl_SwitchToStand
.skip:
	xor  a
	ld   [sPlDashHitTimer], a
	jp   Pl_StartJump
	
; =============== Pl_DoCtrl_HardBump ===============
; Handles hard bumping against certain solid actors (like coin locks),
; as well as the jump after taking damage.
; This bump moves the player in an arc.
Pl_DoCtrl_HardBump:
	; Determine if it's a ground bump or an air bump.
	; Ground bumps are caused by ducking before hard bumping.
	ld   a, [sPlHardBumpGround]
	cp   a, PL_ACT_DUCK				; Is it an ground bump?
	jr   nz, Pl_DoCtrl_HardBumpAir				; If not, jump
	
	; Regardless of bump type, during a bump the player is moved in the opposite direction.
	; Therefore, we need to handle the collision for that.
	
; =============== Pl_DoCtrl_HardBumpGround ===============
; An hard bump on the ground doesn't change the player's Y pos.
Pl_DoCtrl_HardBumpGround:
	ld   a, [sPlHardBumpDir]
	cp   a, DIR_R					; Is the dir indicator pointing right?
	jr   z, .right					; If so, jump
.left:
	call PlBGColi_DoLeft			; Handle the collision on the left
	dec  a ; COLI_EMPTY				; Is there an empty block?
	jr   z, .incTblIndex			; If not, don't move the player
	call Level_ScreenLock_DoLeft
	ld   b, $01						; Move the player 1px to the left
	call Pl_MoveLeftWithScreen
	jr   .incTblIndex
.right:
	call PlBGColi_DoRight			; Handle the collision on the right
	and  a ; COLI_EMPTY				; Is there an empty block?
	jr   nz, .incTblIndex			; If not, don't move the player
	call Level_ScreenLock_DoRight
	ld   b, $01						; Move the player 1px to the right
	call Pl_MoveRightWithScreen
.incTblIndex:
	ld   a, [sPlBumpYPathIndex]	; Timer++
	inc  a
	ld   [sPlBumpYPathIndex], a
	cp   a, $10						; Have we reached the end?
	ret  nz							; If not, return
	
	; Restore the duck action
	; sPlHardBumpGround is set to the previous action, which here is always PL_ACT_DUCK
	ld   a, [sPlHardBumpGround]		; A = PL_ACT_DUCK
	ld   [sPlAction], a
	; [BUG] This doesn't explicitly set the OBJLst frame to OBJ_WARIO_DUCKWALK.
	;       Because of this, when holding LEFT/RIGHT after a ground bump,
	;		the game does Anim2Frame with incorrect frames. (alternates between OBJ_WARIO_BUMPAIR and OBJ_WARIO_SWIM2)
IF FIX_BUGS == 1
	ld   a, OBJ_WARIO_DUCKWALK
	ld   [sPlLstId], a
ENDC
	xor  a
	ld   [sPlBumpYPathIndex], a
	ld   [sPlHurtType], a
	ld   [sPlHardBumpGround], a
	ret
	
; =============== Pl_DoCtrl_HardBumpAir ===============
Pl_DoCtrl_HardBumpAir:
	; To update the player's Y position while bumping, a table of Y offsets is used.
	; sPlBumpYPathIndex is used as index, which also counts as a timer incrementing every frame.
	
	; Like the one used in the save select screen, there are no negative numbers in the table
	; so there are explicit add/subtract code paths.
	
	ld   hl, Pl_HardBumpYPath		; HL = Y Offset Table
	ld   d, $00						; DE = Index
	ld   a, [sPlBumpYPathIndex]
	ld   e, a
	add  hl, de						; Index the table
	ld   b, [hl]					; B = Y Offset
	
	; Adding or subtracting the value? (before or after the peak of the arc?)
	cp   a, Pl_HardBumpYPath.down-Pl_HardBumpYPath 	; >= $10?
	jr   nc, .chkMoveDown 			; If so, jump
	
.chkMoveUp:
	; Attempt to move the player up by the specified amount of pixels	
	ld   c, b						; Do collision on the top
	call PlBGColi_DoTop
	cp   a, COLI_SOLID				; Is there a solid block on top?
	jr   z, .setPeak				; If so, don't move and immediately switch to the peak of the jump
	ld   b, c						; Otherwise move the player up
	call Pl_MoveUp
	ld   a, [sPlBumpYPathIndex]	; Index++
	inc  a
	ld   [sPlBumpYPathIndex], a
	
.moveAuto:
	; If no bump direction is specified, ignore automatic horizontal movement.
	ld   a, [sPlHardBumpDir]
	and  a
	ret  z
	
	cp   a, DIR_R			; Moving right?
	jr   z, .autoMoveRight	; If so, jump
.autoMoveLeft:
	; If there's a solid block, don't move the player
	call PlBGColi_DoLeft
	dec  a
	ret  z
	
	; Try to keep the screen fixed while the player moves.
	; However, if the player is near the left border of the screen,
	; the screen should be scrolled as well to avoid desyncing the player and scroll pos.
	call Level_ScreenLock_DoLeft	; Update screen lock
	ld   b, $01
	ld   a, [sPlXRel]			
	cp   a, $00+$08					; sPlXRel < $08?
	jr   c, .screenL				; If so, also move the screen
	call Pl_MoveLeftStub
	ret
.screenL:
	call Pl_MoveLeftWithScreen
	ret
.autoMoveRight:
	; If there's a solid block, don't move the player
	call PlBGColi_DoRight
	and  a
	ret  nz
	
	; Try to not move the screen unless absolutely necessary, like before
	call Level_ScreenLock_DoRight	; Update screen lock
	ld   b, $01
	ld   a, [sPlXRel]
	cp   a, SCREEN_H 				; sPlXRel >= $A0?
	jr   nc, .screenR				; If so, move thr screen too
	call Pl_MoveRightStub
	ret
.screenR:
	call Pl_MoveRightWithScreen
	ret
	
.setPeak:
	ld   a, Pl_HardBumpYPath.down-Pl_HardBumpYPath
	ld   [sPlBumpYPathIndex], a
	ret
	
.chkMoveDown:
	; Handle SEGSCRL vertical scrolling
	call Level_Scroll_CheckSegScrollDown
	and  a
	ret  nz
	;--
	; Handle ground collision
	ld   c, b
	call PlBGColi_DoGround
	dec  a ; COLI_SOLID		; Is there a solid block below?
	jr   z, .landSolid		; If so, jump
	dec  a ; COLI_WATER		; If there a water block below?
	jr   z, .landWater		; If so, jump
.moveDown:
	ld   b, c
	;--
	call Pl_MoveDown		
	;--
	; If we didn't reach the end of the table, inc the index
	ld   a, [sPlBumpYPathIndex]
	inc  a
	cp   a, Pl_HardBumpYPath.end-Pl_HardBumpYPath
	jr   z, .chkInput
	ld   [sPlBumpYPathIndex], a
.chkInput:
	;--
	; Allow manual left/right movement after reaching peak of the jump height.
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jr   nz, .moveRight
	bit  KEYB_LEFT, a
	jr   nz, .moveLeft
	; Otherwise, fall back to the automatic horz movement
	jr   .moveAuto
.moveRight:
	xor  a
	ld   [sPlHardBumpDir], a
	jp   Pl_AirMoveRight
.moveLeft:
	xor  a
	ld   [sPlHardBumpDir], a
	jp   Pl_AirMoveLeft
.landWater:
	; If landing on water, switch to the swim action
	xor  a
	ld   [sPlHurtType], a
	ld   [sPlBumpYPathIndex], a
	ld   [sPlHardBumpDir], a
	jp   Pl_SwitchToSwim
.landSolid:
	; If landing on ground, switch to the stand action
	
	; If we managed to land on a bounce block, don't switch to the stand animation.
	; Let the superjump code move the player up instead.
	ld   a, [sPlSuperJump]
	and  a
	ret  nz
	
	; As usual is ladder blocks are marked as solid though they really aren't,
	; so they require special handling.
	ld   a, [sPlBGColiLadderType]
	and  a
	jr   nz, .chkLadder
	
	ld   a, [sPlY_Low]			; Align to block Y boundary
	and  a, $F0
	ld   [sPlY_Low], a
	xor  a							; Switch to stand
	ld   [sPlBumpYPathIndex], a
	ld   [sPlHardBumpDir], a
	ld   [sPlHurtType], a
	ld   [sPlJumpYPathIndex], a
	jp   Pl_SwitchToStand
.chkLadder:
	; Bumping/taking damage and going into a ladder top will automatically
	; cause the player to grab into it.
	; This is weird and difficult to trigger.
	ld   a, [sPlBGColiLadderType]
	bit  COLILDB_LADDERTOP, a
	jr   nz, .grabLadder
	
	; If we're holding UP, automatically grab on the ladder
	ldh  a, [hJoyKeys]
	bit  KEYB_UP, a
	jr   z, .moveDown
.grabLadder:
	xor  a
	ld   [sPlBumpYPathIndex], a
	ld   [sPlHardBumpDir], a
	ld   [sPlHurtType], a
	ld   [sPlJumpYPathIndex], a
	jp   Pl_GrabLadder
	
; =============== Pl_HardBumpYPath ===============
; Y Offset table used for hard bumps, damage jump, and rebounding from a dash.
Pl_HardBumpYPath: 
	db $02,$02,$02,$02,$01,$02,$01,$01,$00,$01,$00,$01,$00,$00,$00,$00
.down:
	db $00,$01,$02,$02,$01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
.end:

; =============== Pl_DoCtrl_JumpOnAct ===============
; When jumping on an actor.
Pl_DoCtrl_JumpOnAct:
	; Reuse the same jump table for normal jumps
	call Pl_JumpAnim
	ld   hl, Pl_JumpYPath			; HL = Pl_JumpYPath
	ld   d, $00							; DE = sPlJumpYPathIndex
	ld   a, [sPlJumpYPathIndex]
	ld   e, a
	add  hl, de							; Index it
	ld   b, [hl]						; Get the value
	
	; Add or decrement it to the Y pos
	cp   a, Pl_JumpYPath.down-Pl_JumpYPath
	jp   nc, Pl_SwitchToJumpFall2 ; if index > down limit
.moveUp:
	;--
	ld   c, b
	call PlBGColi_DoTop					; Handle top collision
	and  a								; Is there an empty block on top?
	jp   nz, Pl_SwitchToJumpFall2		; If not, move downwards
	ld   b, c
	;--
	; Otherwise continue upwards movement
	call Pl_MoveUp
	ld   a, [sPlJumpYPathIndex]	; Index++
	inc  a
	ld   [sPlJumpYPathIndex], a
	; Manual movement?
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jp   nz, Pl_AirMoveRight
	bit  KEYB_LEFT, a
	jp   nz, Pl_AirMoveLeft
	ret
; =============== Pl_JumpSetY ===============
; This subroutine updates the player's Y position during the jumping/falling action.
Pl_JumpSetY:
	; To determine by how much to move the player, a table of Y offsets is indexed with a timer.
	; There are two different tables. One for normal jumps, and the other for high jumps.
	
	; Here we determine which table should be used.
	; Any of these should use an high jump.
	ld   a, [sPlSuperJump]		; bounce block special
	and  a					
	jr   nz, .superJump	
	ld   a, [sPlPower]		; jet always high jumps
	cp   a, PL_POW_JET			
	jr   z, .highJump
	ld   a, [sHighJump]			; manual high jump
	and  a						
	jr   nz, .highJump
	ld   a, [sPlInvincibleTimer]; invincibility always high jumps
	and  a						
	jr   nz, .highJump
	; Othwerwise, use the normal jump
.normalJump:
	; Index the table of Y offsets
	ld   hl, Pl_JumpYPath			; HL = Pl_JumpYPath
	ld   d, $00							; DE = sPlJumpYPathIndex
	ld   a, [sPlJumpYPathIndex]
	ld   e, a
	add  hl, de							;
	ld   b, [hl]						; B = Y Offset
	
	; Depending on the index used to access the table, the value
	; should either be added or subtracted to the player Y pos.
	; The index chosen depends on the table and marks the peak of the jump.
	
	cp   a, Pl_JumpYPath.down-Pl_JumpYPath	
	jr   nc, Pl_JumpAddY	; If it's before the peak of the jump arc, add it
	jr   Pl_JumpSubY		; Otherwise subtract it
.highJump:
	; Like .normalJump, but with different table and indexes
	
	; Index the table
	ld   hl, Pl_HighJumpYPath
	ld   d, $00
	ld   a, [sPlJumpYPathIndex]
	ld   e, a
	add  hl, de
	ld   b, [hl]
	; Update the Y pos
	cp   a, Pl_HighJumpYPath.down-Pl_HighJumpYPath
	jr   nc, Pl_JumpAddY
	jr   Pl_JumpSubY
.superJump:
	; Like .highJump, but upwards movement is handled differently
	
	; Index the table
	ld   hl, Pl_HighJumpYPath
	ld   d, $00
	ld   a, [sPlJumpYPathIndex]
	ld   e, a
	add  hl, de
	ld   b, [hl]
	
	; Update the Y pos
	cp   a, Pl_HighJumpYPath.down-Pl_HighJumpYPath
	jr   nc, Pl_JumpAddY
	; If the index is before the peak of the jump, we have upwards movement.
	sla  b				; Move at twice the normal speed (of the high table)
	jr   Pl_JumpSubY2	; Always move up, even when not holding A
	
; =============== Pl_JumpSubY ===============
; Attempts to move the player up by the specified amount during a jump.
; IN
; - B: Pixels to move the player up
Pl_JumpSubY:
	; If we aren't holding A, set the player in the falling state
	; (read: update table index to jump peak)
	ldh  a, [hJoyKeys]
	bit  KEYB_A, a
	jp   z, Pl_SetJumpYFall
Pl_JumpSubY2:
	;--
	; Check for top collision
	ld   c, b				; Save for later
	call PlBGColi_DoTop		; Handle top collision
	cp   a, COLI_WATER		; Is there a water/sand block?
IF IMPROVE == 1
	jr   z, .startSwim
ELSE
	jp   z, Pl_SwitchToSwim	; If so, try to swim on it (not that it works)
ENDC
	and  a	; COLI_EMPTY	; Is there an empty block?
	jp   nz, Pl_JumpSolidTop	; If not, there's a solid block so end the jump
	ld   b, c
	;--
	
	; Handle the slowed down jump when holding an heavy actor)
	; What this does is redice the max speed value of 2 into 1.5.
	; This works since $02 is the most commonly used value, and the highest value used.
	
	ld   a, [sPlSlowJump]
	and  a					; Is it active?
	jr   z, .moveUp			; If not, jump normally
	ld   a, b
	cp   a, $02				; The jump speed should be 2
	jr   nz, .moveUp		; If it isn't, ignore
	; Every other frame, reduce the jump speed of 2 to 1
	ld   a, [sTimer]
	and  a, $01
	jr   nz, .moveUp
	dec  b
.moveUp:
	call Pl_MoveUp						; Move up by that amount
	ld   a, [sPlJumpYPathIndex]	; Timer++
	inc  a
	ld   [sPlJumpYPathIndex], a
	ret
IF IMPROVE == 1
.startSwim:
    ;ld   a, [sPlSand]
	;and  a						; Did we hit a sand block?
	ld   a, $01					
	;jr   nz, .startSand		; If so, jump
	ld   [sPlSwimUpTimer], a	; Continue swimming up
	jp   Pl_SwitchToSwim
;.startSand:			
;	ld   [sPlSandJump], a		; Start in the jump mode to avoid falling off
;	jp   Pl_SwitchToSand
ENDC
; =============== Pl_JumpAddY ===============
; Attempts to move the player down by the specified amount during a fall.
; IN
; - B: Pixels to move the player down
Pl_JumpAddY:
	; In SEGSCRL mode, scroll the screen when reaching the bottom level
	call Level_Scroll_CheckSegScrollDown
	and  a
	ret  nz	; And prevent moving further down while this happens
	
	;--
	ld   c, b
	call PlBGColi_DoGround	; Handle bottom collision
	cp   a, COLI_WATER		; Is there a water block below?
	jp   z, Pl_SwitchToSwim	; If so, swim
	and  a					; Is there an empty block below?
	jr   nz, .chkGround		; If not, switch to the stand action
.moveDown:
	ld   b, c
	;--
	
	call Pl_MoveDown		; Move the player down
	
	; If we didn't reach the end of the table, update the index
	ld   a, [sPlJumpYPathIndex]
	inc  a
	cp   a, Pl_JumpYPath.end-Pl_JumpYPath
	ret  z
	ld   [sPlJumpYPathIndex], a
	ret
.chkGround:
	; If we're colliding with a ladder body, treat it as an empty block.
	; This is because the ladder body is marked as solid collision.
	ld   a, [sPlBGColiLadderType]
	and  a							; Colliding with a ladder?
	jr   z, .ground					; If not, skip this
	bit  COLILDB_LADDERTOP, a		; Colliding with the top of a ladder?
	jr   nz, .ground				; If so, skip this
	
	jr   .moveDown
.ground:

	xor  a
	ld   [sPlSuperJump], a
	ld   [sPlSlowJump], a
	xor  a
	ld   [sPlJumpThrowTimer], a
	
	ld   a, [sPlActSolid]	; Standing on solid actors isn't confined to the Y boundary
	and  a
	jr   nz, .setAnim		
	
	ld   a, [sPlY_Low]	; Align player to block Y boundary
	and  a, $F0
	ld   [sPlY_Low], a
	
	; Special case for landing on ice
	ld   a, [sPlIce]
	and  a
	jr   z, .setAnim
	
	xor  a
IF IMPROVE == 0
	ld   [sPlMovingJump], a
ENDC
	ld   [sPlJumpYPathIndex], a
	ld   [sHighJump], a
	; If holding LEFT/RIGHT, go straight into the walking action
	; instead of going through the stand action.
	; Important when landing on ice to avoid triggering the slide delay.
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jp   nz, Pl_SetMoveRightAction
	bit  KEYB_LEFT, a
	jp   nz, Pl_SetMoveLeftAction
	;--
.setAnim:
	ld   a, SFX1_21				; Play SFX
	ld   [sSFX1Set], a
	xor  a								; Reset vars
IF IMPROVE == 0
	ld   [sPlMovingJump], a
ENDC
	ld   [sPlJumpYPathIndex], a
	ld   [sHighJump], a
	
	ld   a, [sPlDuck]					; If ducking, switch seamlessly to the duck (walk) action
	and  a
	jp   nz, Pl_SetDuckAction
	
	; If we're ground pounding, trigger the screen shake effect
	; Otherwise just land normally
	ld   a, [sPlLstId]
	cp   a, OBJ_WARIO_GROUNDPOUND
	jr   z, .groundPound
	cp   a, OBJ_WARIO_HOLDGROUNDPOUND
	jp   nz, Pl_SwitchToStand
.groundPound:
	; [TCRF] This is never set anywhere, but it would disable the ground pound once.
	;        Purpose unknown.
	ld   a, [s_Unused_PlNoGroundPound]
	and  a
	jr   nz, .skipGroundPound
	
	;--
	; [BUG] This doesn't take into account the "standing on actor" flag.
	;       As a result, ground pounding on a solid actor (ie: coin lock) near the top of the screen
	;		will cause the screen to scroll upwards, which is wrong.
IF FIX_BUGS == 1
	ld   a, [sPlActSolid]
	and  a									; Standing on a solid actor?
	call z, Level_Scroll_CheckSegScroll		; If not, call
ELSE
	IF OPTIMIZE == 1
		call Level_Scroll_CheckSegScroll
	ELSE
		call Level_Scroll_CheckSegScrollAlt
	ENDC
ENDC
	;--
	ld   a, [sScreenShakeTimer]
	and  a							; Is a ground pound/screen shake already active?
	jr   nz, .skipGroundPound		; If so, don't start a new one
	
	ld   a, $20						; Screen shake for $20 frames
	ld   [sScreenShakeTimer], a
	ld   a, SFX4_02		; Play SFX
	ld   [sSFX4Set], a
	ld   a, $01						; Enable it
	ld   [sPlScreenShake], a
	jp   Pl_SwitchToStand2
.skipGroundPound:
	xor  a
	ld   [s_Unused_PlNoGroundPound], a
	
	; [BUG] Calling this resets our frame to the standing frame, instead of leaving it as-is.
	;       As a result, the player isn't considered to be groundpounding anymore.
	;       When breakable blocks are arranged in a 2x2 pattern, this bug makes it impossible
	;       to destroy all of them in one go. At most, three blocks can be destroyed.
	;
	;    Pl_SwitchToStand2 should be called instead.
IF FIX_BUGS == 1
	jp   Pl_SwitchToStand2
ELSE
	jp   Pl_SwitchToStand
ENDC

	
; =============== Pl_SwitchToJumpFall ===============
; Switches to the jump action in the falling state (when moving off the edge of a platform, ...).
; This is done through the table of Y offsets used for jumping.
; By starting around the middle values, you'll only get moved downwards.
Pl_SwitchToJumpFall:
	ldh  a, [hJoyKeys]
	bit  KEYB_UP, a					; Are we holding UP?
	jr   z, Pl_SwitchToJumpFall2	; If not, jump
	ld   a, $01						; Otherwise, set the high jump
	ld   [sHighJump], a
; =============== Pl_SwitchToJumpFall2 ===============
; See above, but without setting an high jump.
Pl_SwitchToJumpFall2:
	xor  a
	ld   [sPlSwimGround], a
	ld   [sPlGroundDashTimer], a
	; Switch to the jump action
	ld   a, PL_ACT_JUMP
	ld   [sPlAction], a
	
; =============== Pl_SetJumpYFall ===============
; Sets the player in the falling state, without setting the jumping action.
; This updates the index to the table used for updating the player's Y pos while jumping.
Pl_SetJumpYFall:
	; Start by setting the index for the normal jumpY table
	ld   a, Pl_JumpYPath.down - Pl_JumpYPath
	ld   [sPlJumpYPathIndex], a
	
	; Then check if we're actually doing an high jump,
	; since the high jump table is longer and uses a different index for the entries triggering downwards movement.
	ld   a, [sPlSuperJump]
	and  a						; Jumped from a bounce block?
	jr   nz, .highJump			; If so, always high jump
	ld   a, [sPlPower]
	cp   a, PL_POW_JET			; Jet Wario always high jumps
	jr   z, .highJump
	ld   a, [sPlInvincibleTimer]
	and  a						; Same in the invincibility state
	jr   nz, .highJump
	ld   a, [sHighJump]
	and  a						; Did we trigger a normal high jump?
	ret  z						; If not, return (and keep the index for the normal jump)
.highJump:
	ld   a, Pl_HighJumpYPath.down - Pl_HighJumpYPath
	ld   [sPlJumpYPathIndex], a
	ret
	
; =============== Pl_JumpSolidTop ===============
; This subroutine handles what happens when a there's a solid block above the player during a jump. 
; Most of the time it marks the player in the fall state.
Pl_JumpSolidTop:
	; Check if we're trying to cling on a solid block.
	; If not, set the fall state.
	
	ld   a, [sPlPower]
	cp   a, PL_POW_BULL			; Only Bull Wario can cling
	jr   nz, Pl_SetJumpYFall
	
	ldh  a, [hJoyKeys]
	bit  KEYB_UP, a				; Holding UP?
	jr   z, Pl_SetJumpYFall		; If not, jump
	
	; Switch blocks cannot be clinged on.
	; Curiously (or not) the unused switch block (BLOCKID_UNUSED_SWITCH1T1) isn't on here
	ld   a, [sPlBGColiBlockId]	
	cp   a, BLOCKID_SWITCH0T0
	jr   z, Pl_SetJumpYFall
	cp   a, BLOCKID_SWITCH0T1
	jr   z, Pl_SetJumpYFall
	
	; If all checks passed, we can cling to the block
	xor  a
	ld   [sPlJumpYPathIndex], a
	ld   a, PL_ACT_CLING
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	ld   a, SFX4_0E
	ld   [sSFX4Set], a
	ret
; =============== Pl_SwitchToSwim  ===============
; Handle the switching to the swimming action.
; Generally happens after entering water, but other actions that have their own modes (jet dash),
; will call this too.
Pl_SwitchToSwim:
	; Ignore water/sand when dead
	ld   a, [sPlAction]
	cp   a, PL_ACT_DEAD
	ret  z
	;--
IF IMPROVE == 0
	xor  a
	ld   [sPlMovingJump], a
ENDC
	; Sand is a """subtype""" of the water collision type.
	; If the special flag is set, treat it as sand instead.
	ld   a, [sPlSand]
	and  a
	jr   nz, Pl_SwitchToSand
	;--
	xor  a
	ld   [sPlTimer], a
	ld   [sPlDuck], a
	ld   hl, sPlFlags
	res  OBJLSTB_OBP1, [hl]
	
	; Set the swimming frame
	ld   a, OBJ_WARIO_SWIM0
	ld   [sPlLstId], a
	ld   a, [sSmallWario]			
	and  a
	jr   z, .setAct
	ld   a, [sPlLstId]
	add  OBJ_SMALLWARIO_SWIM0-OBJ_WARIO_SWIM0
	ld   [sPlLstId], a
	
.setAct:
	; Since we're most likely coming from a jump
	xor  a
	ld   [sPlJumpYPathIndex], a
	
	; Switch to the swimming action
	ld   a, PL_ACT_SWIM
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	
	; Were we underwater previously?
	; If so (ie: coming from an underwater dash) don't spawn the water splash
	ld   a, [sPlWaterAction]
	and  a
	jr   z, .spawnSplash
	xor  a						; Reset the flag
	ld   [sPlWaterAction], a
	ret
.spawnSplash:
	; Spawn the water splash actor
	ld   a, SFX4_0C
	ld   [sSFX4Set], a
	ld   a, EXACT_WATERSPLASH		; ExSct ID
	ld   [sExActSet], a
	ld   a, [sPlY_High]			; Y = sPlY & $FFF0
	ld   [sExActOBJY_High], a		
	ld   a, [sPlY_Low]			
	and  a, $F0						;     (align to block boundary)
	ld   [sExActOBJY_Low], a
	ld   a, [sPlX_High]			; X = sPlX
	ld   [sExActOBJX_High], a
	ld   a, [sPlX_Low]
	ld   [sExActOBJX_Low], a
	ld   a, OBJ_WATERSPLASH0		; Frame
	ld   [sExActOBJLstId], a
	xor  a							; Flags
	ld   [sExActOBJFlags], a
	; Clear rest
	ld   hl, sExActLevelLayoutPtr_High
	xor  a
	ld   b, $09
	call ClearRAMRange_Mini
	call ExActS_Spawn
	ret
; =============== Pl_SwitchToSand  ===============
; Handle the switching to the quicksand action.
Pl_SwitchToSand:
	xor  a
	ld   [sPlTimer], a
	ld   [sPlJumpYPathIndex], a
	ld   [sPlBumpYPathIndex], a
	ld   [sPlDuck], a
	
	ld   hl, sPlFlags
	res  OBJLSTB_OBP1, [hl]
	
	; Switch to the sand action
	ld   a, PL_ACT_SAND
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	
	; Pick the proper anim frame
	; Since the only way to get into the quicksand *action* is jumping into it,
	; those are the only frames we care about.
	ld   a, [sSmallWario]
	and  a						; Small Wario?
	jr   nz, .small				; If not, jump
.norm:
	ld   a, OBJ_WARIO_JUMP
	ld   [sPlLstId], a
	ld   a, [sActHeld]			
	and  a						; Holding something?
	ret  z						; If not, return
	ld   a, OBJ_WARIO_HOLDJUMP
	ld   [sPlLstId], a
	ret
.small:
	ld   a, OBJ_SMALLWARIO_JUMP
	ld   [sPlLstId], a
	ld   a, [sActHeld]
	and  a						; Holding something?
	ret  z						; If not, return
	ld   a, OBJ_SMALLWARIO_HOLDJUMP
	ld   [sPlLstId], a
	ret
	
; =============== Pl_DoCtrl_Dead ===============
Pl_DoCtrl_Dead:
	; Kill the autoscroll
	xor  a
	ld   [sLvlAutoScrollDir], a
	ld   [sLvlAutoScrollSpeed], a
	
	; Wait until the timer elapses.
	; When elapsed, reset the coin count back to 0, then move the player.
	ld   a, [sPlTimer2]
	and  a					; Is the timer elapsed?
	jr   z, .move			; If so, jump
	dec  a					; Timer--
	ld   [sPlTimer2], a		; Did the timer just elapse?
	ret  nz					; If not, return
	; Reset the coin count
	xor  a
	ld   [sLevelCoins_High], a
	ld   [sLevelCoins_Low], a
	call StatusBar_DrawLevelCoins
	ret
.move:
	; Reuse normal Y jump table again
	ld   hl, Pl_JumpYPath			; HL = Y Offset table
	ld   d, $00							; DE = Index
	ld   a, [sPlJumpYPathIndex]
	ld   e, a
	add  hl, de							;
	ld   b, [hl]						; B = Y offset
	cp   a, Pl_JumpYPath.down-Pl_JumpYPath	; Is this before the jump peak?
	jr   nc, .moveDown					; If not, move down
.moveUp:
	call Pl_MoveUp
	ld   a, [sPlJumpYPathIndex]
	inc  a
	ld   [sPlJumpYPathIndex], a
	ret
.moveDown:
	; As soon as Wario is completely off-screen, end the level
	ld   a, [sPlYRel]
	and  a, $F0				; remove sub-block precision
	cp   a, SCREEN_V+$20	; Off screen yet?
	jr   z, .endLevel		; If so, end the level
	
	call Pl_MoveDown		; Move down by Y offset
	
	; Increase the table index if we didn't reach the end yet
	ld   a, [sPlJumpYPathIndex]
	inc  a
	cp   a, Pl_JumpYPath.end-Pl_JumpYPath
	ret  z
	ld   [sPlJumpYPathIndex], a
	ret
.endLevel:
	; Trigger the fade out after dying
	ld   a, GM_LEVELDEADFADEOUT
	ld   [sGameMode], a
	
	ld   a, [sLives]
	and  a				; Are we out of lives?
	jr   z, .gameOver	; If so, trigger the game over
	
	sub  a, $01			; Lives--;
	daa
	ld   [sLives], a
	ret
.gameOver:
	ld   a, $01
	ld   [sGameOver], a
	ret
	
; =============== Pl_DoCtrl_Cling ===============
Pl_DoCtrl_Cling:
	; Handle collision with the block on top
	call PlBGColi_DoTop				
	and  a							; Is it solid?
	jp   z, Pl_SwitchToJumpFall2	; If not, cancel the cling
	ldh  a, [hJoyKeys]
	bit  KEYB_UP, a					; Are we holding the UP button?
	ret  nz							; If so, return
	jp   Pl_SwitchToJumpFall2		; Otherwise, uncling
	
; =============== Pl_DoCtrl_Dash ===============
Pl_DoCtrl_Dash:
	call PlBGColi_DoDash			; Handle block collision
	
	ld   a, [sPlDashSolidHit]
	and  a							; Did we hit a solid wall?
	jp   nz, Pl_SwitchToDashRebound		; If so, end the dash
	
	ldh  a, [hJoyNewKeys]
	bit  KEYB_A, a					; Did we press A?
	jp   nz, Pl_SwitchToDashJump				; If so, switch to the dash jump
	
	call Wario_DoDashAfterimages	; Do anim effect
	
	; In which direction this dash is?
	ld   hl, sPlFlags
	bit  OBJLSTB_XFLIP, [hl]
	jr   z, .leftDash
.rightDash:
	; End the dash when pressing the opposite direction
	ldh  a, [hJoyNewKeys]
	bit  KEYB_LEFT, a				; Did we press left?
	jr   nz, .endDash				; If so, end the dash
	
	call Level_ScreenLock_DoRight	; Update screen lock
	
	;--
	; Set the dash speed of 1.5px/frame
	ld   b, $01			; B = Base speed
	ld   a, [sTimer]	; Every other frame...
	and  a, $01
	jr   z, .tryScrollRight
	inc  b				; ...add an extra px of speed
.tryScrollRight:
	;--
	; Try to scroll the screen right if we can.
	ld   a, [sLvlScrollLockCur]
	and  a, DIR_R|DIR_L				; Is there a scroll lock active?
	jr   nz, .moveRight				; If so, don't scroll
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_CHKAUTO		; Are we in an autoscroll/noscroll mode?
	jr   nc, .moveRight				; If so, there's no manual scrolling
	ld   a, [sLvlScrollHAmount]
	add  b							; Otherwise, request a screen scroll to the right
	ld   [sLvlScrollHAmount], a
.moveRight:
	;--
	call Pl_MoveRight				; Move the player
	ld   a, [sPlGroundDashTimer]	; FramesLeft--
	dec  a
	ld   [sPlGroundDashTimer], a	; Is the dash over?
	ret  nz							; If not, return
	; If we got here, the dash ended and we didn't hit anything or manually end it
	jp   Pl_SetMoveAction
.endDash:
	; This is called when ending a dash manually
	; [BUG] By the time we get here we should have accounted for the ladder being set as a solid block.
	;		This doesn't happen with a dash though.
	;       Which is why you can stand in the middle of a laddder if ending a dash over them.
	xor  a
	ld   [sPlGroundDashTimer], a
	jp   Pl_SetMoveAction
.leftDash:
	; End the dash when pressing the opposite direction
	ldh  a, [hJoyNewKeys]
	bit  KEYB_RIGHT, a				; Did we press right?
	jr   nz, .endDash				; If so, end the dash
	
	call Level_ScreenLock_DoLeft	; Update screen lock
	
	;--
	; Set the dash speed of 1.5px/frame
	ld   b, $01			; B = Base speed
	ld   a, [sTimer]	; Every other frame...
	and  a, $01
	jr   z, .tryScrollLeft
	inc  b				; ...add an extra px of speed
.tryScrollLeft:
	;--
	; Try to scroll the screen left if we can.
	ld   a, [sLvlScrollLockCur]
	and  a, DIR_R|DIR_L				; Is there a scroll lock active?
	jr   nz, .moveLeft				; If so, don't scroll
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_CHKAUTO		; Are we in an autoscroll/noscroll mode?
	jr   nc, .moveLeft				; If so, there's no manual scrolling
	ld   a, [sLvlScrollHAmount]
	sub  a, b						; Otherwise, request a screen scroll to the left
	ld   [sLvlScrollHAmount], a
.moveLeft:
	;--
	call Pl_MoveLeft				; Move the player
	ld   a, [sPlGroundDashTimer]	; FramesLeft--
	dec  a
	ld   [sPlGroundDashTimer], a	; Is the dash over?
	ret  nz							; If not, return
	; If we got here, the dash ended and we didn't hit anything or manually end it
	jp   Pl_SetMoveAction
; =============== Pl_SwitchToDashRebound ===============
; Switches to the dash rebound action (ie: after hitting a wall).
Pl_SwitchToDashRebound:
	ld   a, SFX4_03
	ld   [sSFX4Set], a
	ld   a, OBJ_WARIO_DASH1	; DASH0 would look wrong in the air
	ld   [sPlLstId], a
	xor  a
	ld   [sPlBumpYPathIndex], a
IF IMPROVE == 0
	ld   [sPlMovingJump], a
ENDC
	ld   [sPlJetDashTimer], a
	ld   [sPlTimer], a
	ld   [sPlGroundDashTimer], a
	ld   a, PL_ACT_DASHREBOUND
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	ret
; =============== Pl_SwitchToDashJump ===============
; Switches the ground dash action to a jumpdash action.
Pl_SwitchToDashJump:
	ld   a, OBJ_WARIO_DASHJUMP
	ld   [sPlLstId], a
	xor  a
	ld   [sPlTimer], a
	ld   [sPlJumpYPathIndex], a
	ld   [sPlBumpYPathIndex], a
	ld   a, PL_ACT_DASHJUMP
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	ret
; =============== Pl_DoCtrl_DashRebound ===============
Pl_DoCtrl_DashRebound:
	; The dash rebound effect is similar to an hard bump.
	; The key difference here is that after the peak of the jump,
	; there's no automatic horizontal movement.

	; Reuse the hard bump Y offset table for this
	ld   hl, Pl_HardBumpYPath		; HL = Y Offset table
	ld   d, $00						; DE = sPlBumpYPathIndex
	ld   a, [sPlBumpYPathIndex]
	ld   e, a
	add  hl, de						; Index the table
	ld   b, [hl]					; B = Y Offset
	
	; Determine if before (subtract) or after (add) the peak of the jump
	cp   a, Pl_HardBumpYPath.down-Pl_HardBumpYPath
	jr   nc, .moveDown
.moveUp:
	;--
	; Detect solid on top block
	ld   c, b
	call PlBGColi_DoTop				; Handle top collision
	and  a							; Is there an empty block above?
	jr   nz, .switchToDown			; If not, start moving down
	ld   b, c
	;--
	; Move up by that amount of pixels
	call Pl_MoveUp
	
	ld   a, [sPlBumpYPathIndex]	; Index++
	inc  a
	ld   [sPlBumpYPathIndex], a
	
	; Do automatic movement in the opposite direction the player's facing
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a			; Facing right?
	jr   z, .faceLeft				; If not, jump
.faceRight:
	; Of course it needs to check for collision.
	
	; [BUG] Unlike the hard rebound code, this doesn't ever scroll the screen,
	;       even if the player is near the screen edge.
	;       This can be abused to wrong warp.
	call PlBGColi_DoLeft			
	dec  a							; and if there's a solid block behind
	ret  z							; don't actually move
	call Level_ScreenLock_DoLeft
	ld   b, $01						; Otherwise move left by 1px
IF FIX_BUGS == 1
	ld   a, [sPlXRel]			
	cp   a, $00+$08					; sPlXRel < $08?
	jr   c, .screenL				; If so, also move the screen
ENDC
	call Pl_MoveLeftStub
	ret

.faceLeft:
	; Like before, but moving right. Same [BUG] applies.
	call PlBGColi_DoRight
	and  a
	ret  nz
	call Level_ScreenLock_DoRight
	ld   b, $01
IF FIX_BUGS == 1
	ld   a, [sPlXRel]
	cp   a, SCREEN_H 				; sPlXRel >= $A0?
	jr   nc, .screenR				; If so, move thr screen too
ENDC
	call Pl_MoveRightStub
	ret
	
IF FIX_BUGS == 1
.screenL:
	call Pl_MoveLeftWithScreen
	ret
.screenR:
	call Pl_MoveRightWithScreen
	ret
ENDC

.switchToDown:
	ld   a, Pl_HardBumpYPath.down-Pl_HardBumpYPath
	ld   [sPlBumpYPathIndex], a
	ret
.moveDown:
	; Handle vertical scrolling in SEGSCRL mode
	call Level_Scroll_CheckSegScrollDown
	and  a
	ret  nz
	
	; Check for ground collision type
	ld   c, b
	
IF FIX_FUN_BUGS == 1
	; [BUG] Part of a bugfix to prevent walking normally after jetdashing on sand.
	;       Unlike elsewhere, we don't need to check if we're underwater,
	;       since we can't dash rebound to begin with in that case.
	call PlBGColi_GetBlockIdLow	; A = Block ID we're over
	cp   a, BLOCKID_SAND		; Is it a sand block?
	jp   z, Pl_SwitchToSand		; If so, jump
	cp   a, BLOCKID_SANDSPIKE	; Is it a sand block with spikes?
	jp   z, Pl_SwitchToSand		; If so, jump
	ld   [sTmp_A9EE], a			; Save for later	
ENDC
	call PlBGColi_DoGround		; Handle collision
	cp   a, COLI_WATER			; Is there a water block below?
	jr   z, .landWater			; If so, jump
	and  a ; COLI_EMPTY			; Is there an empty block below?
	jr   nz, .chkLandSolid		; If not (solid block), jump
	
	; FIX_FUN_BUGS makes ladder blocks of type COLI_EMPTY, so this needs to be moved here
IF FIX_FUN_BUGS == 1
.chkLadderAsEmpty:
	; Special case for ladder collision
	ld   a, [sPlBGColiLadderType]
	and  a
	jr   nz, .chkLadder
ENDC
.doMoveDown:
	ld   b, c					; Move player down
	call Pl_MoveDown
	
	; Index++ if we didn't reach the end of the table
	ld   a, [sPlBumpYPathIndex]	
	inc  a
	cp   a, Pl_HardBumpYPath.end-Pl_HardBumpYPath
	jr   z, .chkManualCtrl
	ld   [sPlBumpYPathIndex], a
.chkManualCtrl:
	; Allow manual control (only) during the descent
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jp   nz, Pl_AirMoveRight
	bit  KEYB_LEFT, a
	jp   nz, Pl_AirMoveLeft
	ret
	
.landWater:
	xor  a
	ld   [sPlBumpYPathIndex], a
	jp   Pl_SwitchToSwim
	
.chkLandSolid:
	; As long as a super jump is active, ignore the rest
	ld   a, [sPlSuperJump]
	and  a
	ret  nz
	
IF FIX_FUN_BUGS == 1
	ld   a, [sTmp_A9EE]			; A = Block ID | Restored
	; [BUG] Fixes ground walking when descending on water.
	; If we're over a water block, switch to the swim action .
	; This can only happen if a water current moves us down during a jet dash.
	cp   a, BLOCKID_WATER_START	; Block ID < WATER_START?
	jr   c, .noLandWater   		; If so, jump
	cp   a, BLOCKID_WATER_END	; Block ID < (first ID after end of water blocks)?
	jr   c, .landWater			; If so, jump
.noLandWater:
ENDC
	; Special case for ladder collision (since they are set as solid, but really aren't)
	ld   a, [sPlBGColiLadderType]
	and  a
	jr   nz, .chkLadder
	
	ld   a, [sPlY_Low]				; Align to block Y boundary
	and  a, $F0
	ld   [sPlY_Low], a
	xor  a								; Set stand action
	ld   [sPlBumpYPathIndex], a
	ld   [sPlJumpYPathIndex], a
	jp   Pl_SwitchToStand
.chkLadder:
	; Rebounding off a ladder top automatically grabs into it
	ld   a, [sPlBGColiLadderType]
	bit  COLILDB_LADDERTOP, a
	jr   nz, .grabLadder
	; Holding UP will grab the ladder
	ldh  a, [hJoyKeys]
	bit  KEYB_UP, a
	jr   z, .doMoveDown
.grabLadder:
	; When grabbing a ladder in SEGSCRL mode, make sure to scroll 
	; the screen upwards when needed.
	xor  a
	ld   [sPlBumpYPathIndex], a
	ld   [sPlJumpYPathIndex], a
IF OPTIMIZE == 1
	call Level_Scroll_CheckSegScroll
ELSE
	call Level_Scroll_CheckSegScrollAlt
ENDC
	jp   Pl_GrabLadder
	
; =============== Pl_DoCtrl_DashJump ===============
Pl_DoCtrl_DashJump:
	; Do same collision check as a normal dash
	call PlBGColi_DoDash
	ld   a, [sPlDashSolidHit]
	and  a
	jp   nz, Pl_SwitchToDashRebound
	;--
	; Dash jumps use the high jump Y offset table
	ld   hl, Pl_HighJumpYPath		; HL = Y Offset Table
	ld   d, $00							; DE = sPlJumpYPathIndex
	ld   a, [sPlJumpYPathIndex]
	ld   e, a
	add  hl, de							; Index it
	ld   b, [hl]						; B = Y Offset
	
	; [POI] Curiously, this uses the same peak value as Pl_JumpYPath, which
	;       is different compared to Pl_HighJumpYPath.
	
	; Determine if before or after peak
	; When the jump peak is reached here the dashjump ends.
	cp   a, Pl_JumpYPath.down-Pl_JumpYPath
	jr   nc, .endDash
	; If there's a solid block on top, the dash ends
	ld   c, b
	call PlBGColi_DoTop		; Handle top collision
	and  a
	jr   nz, .endDash
	ld   b, c
	; Otherwise move upwards by the specified amount of px
	call Pl_MoveUp
	
	ld   a, [sPlJumpYPathIndex]	; Index++
	inc  a
	ld   [sPlJumpYPathIndex], a
	
	; Move horizontally depending on the direction the player's facing
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a	; Facing right?
	jr   nz, .moveRight		; If so, move right
.moveLeft:
	; This seems suspicious -- this collision check is already performed by PlBGColi_DoDash!
	; Hitting a solid block triggers Pl_SwitchToDashRebound before we get here.
	; Probably the result of copied code.
	call PlBGColi_DoLeft
	dec  a					
	ret  z				
	;--
	; Move player and screen 1.5px to the left
	
	call Level_ScreenLock_DoLeft	; Update screen lock
	ld   b, $01				; B = Base speed
	ld   a, [sTimer]		; Every other frame...
	and  a, $01
	jr   z, .doMoveL
	inc  b					; ...add 1 speed
.doMoveL:
	jp   Pl_MoveLeftWithScreen
	
.moveRight:
	; Same as above, but for the right direction
	call PlBGColi_DoRight
	and  a
	ret  nz
	
	; Move player and screen 1.5px to the right
	call Level_ScreenLock_DoRight
	ld   b, $01
	ld   a, [sTimer]
	and  a, $01
	jr   z, .doMoveR
	inc  b
.doMoveR:
	jp   Pl_MoveRightWithScreen
.endDash:
	jp   Pl_SwitchToJumpFall
	
; =============== Pl_DoCtrl_DashJump ===============
Pl_DoCtrl_DashJet:
	; Usual dash collision check
	call PlBGColi_DoDash
	ld   a, [sPlDashSolidHit]	
	and  a						; Did we hit a solid block?
	jr   z, .noRebound			; If not, jump
	
	; Otherwise, setup a rebound
	xor  a
	ld   [sPlJetDashTimer], a
	ld   a, [sPlWaterAction]
	and  a						; Unless we're in water
	jp   nz, Pl_SwitchToSwim	; In which case we swim automatically
	jp   Pl_SwitchToDashRebound
.noRebound:
	ldh  a, [hJoyNewKeys]
	and  a, KEY_A|KEY_B			; Are A or B pressed?
	jr   nz, .endDash			; If so, end the dash
	
	; Determine dash direction
	ld   hl, sPlFlags
	bit  OBJLSTB_XFLIP, [hl]	; Facing right?
	jr   z, .leftDash			; If not, jump
.rightDash:
	; Pressing/holding the opposite direction ends the dash
	ldh  a, [hJoyKeys]
	bit  KEYB_LEFT, a
	jr   nz, .endDash
	
	call Level_ScreenLock_DoRight	; Update screen lock
	
	ld   b, $02					; B = Normal jet dash speed (2px/frame)
	ld   a, [sPlWaterAction]
	and  a						; Are we underwater?
	jr   z, .tryScrollRight		; If not, skip
	dec  b						; B = Underwater dash speed (1px/frame)
.tryScrollRight:
	;--
	; Try to scroll the screen right
	ld   a, [sLvlScrollLockCur]
	and  a, DIR_L|DIR_R			; Is there a scroll lock set?	
	jr   nz, .moveRight			; If so, don't scroll
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_CHKAUTO	; Are we in an autoscrolling/noscroll mode?
	jr   nc, .moveRight			; If so, we can't scroll the screen manually
	ld   a, [sLvlScrollHAmount]
	add  b						; Request screen scroll to the right
	ld   [sLvlScrollHAmount], a
.moveRight:
	call Pl_MoveRight
	
.chkDescend:
	; If the dash timer elapsed, start/continue the slow descent
	ld   a, [sPlJetDashTimer]
	and  a
	jr   z, .descend
	dec  a
	ld   [sPlJetDashTimer], a
	ret
.leftDash:
	; Pressing/holding the opposite direction ends the dash
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jr   nz, .endDash
	call Level_ScreenLock_DoLeft	; Update screen lock
	ld   b, $02					; B = Normal jet dash speed (2px/frame)
	ld   a, [sPlWaterAction]
	and  a						; Are we underwater?
	jr   z, .tryScrollLeft		; If not, skip
	dec  b						; B = Underwater dash speed (1px/frame)
.tryScrollLeft:
	;--
	; Try to scroll the screen left
	ld   a, [sLvlScrollLockCur]
	and  a, DIR_L|DIR_R			; Is there a scroll lock set?	
	jr   nz, .moveLeft			; If so, don't scroll
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_CHKAUTO	; Are we in an autoscrolling/noscroll mode?
	jr   nc, .moveLeft			; If so, we can't scroll the screen manually
	ld   a, [sLvlScrollHAmount]
	sub  a, b					; Request screen scroll to the left
	ld   [sLvlScrollHAmount], a
.moveLeft:
	call Pl_MoveLeft
	jr   .chkDescend
	
.endDash:
	; Ends a jet dash immediately, without going through the descent phase
	xor  a
	ld   [sPlJetDashTimer], a
	
	ld   a, [sPlWaterAction]
	and  a						; Were we in water?
	jp   nz, Pl_SwitchToSwim	; If so, switch back to the swim action
	
	; [BUG] Collision for the block low isn't also checked
	;       This is noticeable when jet dashing on quicksand while on the ground,
	;       since it will let you walk normally on sand. 
	;       (this needs to be added elsewhere too, like when rebounding off a wall or when descending)
IF FIX_FUN_BUGS == 1
	; Dashing on sand doesn't set sPlWaterAction, so check for the block ID directly
	call PlBGColi_GetBlockIdLow	; A = Block ID we're over
	cp   a, BLOCKID_SAND		; Is it a sand block?
	jp   z, Pl_SwitchToSand		; If so, jump
	cp   a, BLOCKID_SANDSPIKE	; Is it a sand block with spikes?
	jp   z, Pl_SwitchToSand		; If so, jump
ENDC

	call PlBGColi_DoGround		; Do ground collision
	dec  a ; COLI_SOLID			; Are we over a solid block?
	jr   z, .switchToStand		; If so, jump
	cp   a, COLI_WATER			; Are we over a water block?
	jp   z, Pl_SwitchToSwim		; If so, swim
	jp   Pl_SwitchToJumpFall2
	
.descend:
	; During the descent, the player moves down until solid/water ground is reached.
	
	; Since we're moving down, handle downwards scrolling in SEGSCRL mode
	call Level_Scroll_CheckSegScrollDown
	and  a
	ret  nz
	
	; [BUG] This should check for sPlWaterAction, but it doesn't.
	;       While partially masked by the game moving the player upwards on underwater jet dashes,
	;		this allows you to walk normally on ground by making the ground check below detect solid.	
IF FIX_FUN_BUGS == 1
	ld   a, [sPlWaterAction]
	and  a						; Were we in water?
	jp   nz, Pl_SwitchToSwim	; If so, switch back to the swim action
	; Dashing on sand doesn't set sPlWaterAction, so check for the block ID directly
	call PlBGColi_GetBlockIdLow	; A = Block ID we're over
	cp   a, BLOCKID_SAND		; Is it a sand block?
	jp   z, Pl_SwitchToSand		; If so, jump
	cp   a, BLOCKID_SANDSPIKE	; Is it a sand block with spikes?
	jp   z, Pl_SwitchToSand		; If so, jump
ENDC
	
	call PlBGColi_DoGround		; Handle block collision below
	cp   a, COLI_WATER			; Is there a water block below?	
	jp   z, Pl_SwitchToSwim		
	cp   a, COLI_SOLID			; Is there a solid block below?	
	jr   z, .switchToStand
	; Otherwise, we're over an empty block
	; Continue moving down at 1px/frame
	ld   b, $01
	call Pl_MoveDown
	ret
	
.switchToStand:
	ld   a, [sPlY_Low]		; Align to Y block boundary
	and  a, $F0
	ld   [sPlY_Low], a
	
	jp   Pl_SwitchToStand
	
	
; =============== Pl_DoCtrl_DuckActGrab ===============
; Starts a grab when ducking.
Pl_DoCtrl_DuckActGrab:
	; The anim frame for grabbing is set when the game switches to the throw action.
	; Now we pause for 4 frames, which freezes the player in that anim.
	ld   a, [sActHeld]				
	and  a						; Are we holding anything now?
	jr   z, Pl_StartThrowAction	; If not, throw the actor
	
	; Pick a different delay if the actor is heavy
	ld   b, $04					; B = Normal delay
	ld   a, [sActHoldHeavy]
	and  a						; Is it heavy?
	jr   z, .noHeavy			; If not, jump
	ld   b, $30					; B = Delay for heavy actors
.noHeavy:
	ld   a, [sPlTimer2]
	inc  a						; Timer++;
	ld   [sPlTimer2], a
	cp   a, b					; Does the timer match the required value?
	ret  nz						; If not, return
	
	; Reset timer and return to the correct action
	xor  a
	ld   [sPlTimer2], a
	ld   a, [sPlDuck]
	and  a
	jp   nz, Pl_SetDuckAction
	jp   Pl_SwitchToStand 		; Not entirely sure how this could be triggered
	
; =============== Pl_StartThrowAction ===============
; Starts the actor throw player action.
; Also used when dropping an actor.
Pl_StartThrowAction:
	ld   a, PL_ACT_THROW
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	
	xor  a
	ld   [sPlTimer2], a
	ld   [sPlTimer], a
	
	; Set the correct player anim for throwing.
	ld   a, [sSmallWario]
	and  a					
	jr   nz, .small
.normal:
	ld   a, OBJ_WARIO_THROW
	ld   [sPlLstId], a
	ld   a, [sPlDuck]
	and  a
	ret  z
	ld   a, OBJ_WARIO_DUCKTHROW
	ld   [sPlLstId], a
	ret
.small:
	; No special throw anim for small wario
	ld   a, OBJ_SMALLWARIO_STAND
	ld   [sPlLstId], a
	ret
; =============== Pl_DoCtrl_Throw ===============
; Handles the throw animation when standing on the ground.
; This isn't called when throwing something mid-air.
Pl_DoCtrl_Throw:
	; The anim frame for throwing is set when the game switches to the throw action.
	; Now we pause for 4 frames, which freezes the player in that anim.
	ld   a, [sPlTimer2]
	inc  a
	ld   [sPlTimer2], a
	cp   a, $04
	ret  nz
	; Once we're done, unfreeze the player by returning to the correct action
	xor  a
	ld   [sPlTimer2], a
	ld   [sPlTimer], a
	ld   a, [sPlDuck]
	and  a						; Are we ducking?
	jp   nz, Pl_SetDuckAction	; If so, jump
	jp   Pl_SwitchToStand
	
; =============== Pl_WalkRight ===============
; Handles the player walking to the right.
Pl_WalkRight:
	call Pl_WalkAnim			; Normal walk cycle
	ld   hl, sPlFlags		; Set obj direction
	set  OBJLSTB_XFLIP, [hl]	
	
	ld   a, [sPlIceDelayTimer]	
	and  a						; Is there a delay before moving (by standing on ice)?
	jr   z, .checkFrontSolid	; If not, skip this
	dec  a						; Otherwise, decrement the delay
	ld   [sPlIceDelayTimer], a
	ret							; and don't do anything else
	
.checkFrontSolid:
	;--
	; Can we move left?

	; Since a player can be 2 blocks tall (more or less), we should check collision for both blocks.
	; In practice, a shortcut is taken and most of the time only the block with highest priority is checked.
	
	; For this to work the empty blocks must be the ones with least priority, which in this case works.
	; See the note PlBGColi_DoHorz for more info.
	
	call PlBGColi_DoFront		
	dec  a							; Is there a solid block (either on the top or bottom)? ($01)
	jr   nz, Pl_MoveRightChkSpeed	; If not, jump
	
	call PlBGColi_DoHorzNext		
	and  a							; Is the block *on the bottom* empty?
	ret  nz							; If not, we're going against a solid wall.
	
	ld   b, $03						; Otherwise, we can fit into the gap when ducking
	call Pl_MoveRight				
	jp   Pl_SetDuckAction			; Autoduck
; =============== Pl_AirMoveRight ===============
; Variant of Pl_AirMoveRight for moving right while in the air.
; and without checking for the auto-crouching.
Pl_AirMoveRight:
	ld   hl, sPlFlags		; Set OBJ direction
	set  OBJLSTB_XFLIP, [hl]
	
	; The timer should count down normally, even in the air
	ld   a, [sPlIceDelayTimer]
	and  a
	jr   z, .checkFrontSolid
	dec  a
	ld   [sPlIceDelayTimer], a
	ret
.checkFrontSolid:
	; We can't perform the automatic crouching in the air.
	
	; This makes the collision check straightforward: 
	; if there's a solid block in front of the player, we can't move left.
	call PlBGColi_DoFront
	dec  a
	ret  z
	
; =============== Pl_MoveRightChkSpeed ===============
; This subroutine determines how many pixels to move the player.
; After that, it moves the player to the right by that amount.
Pl_MoveRightChkSpeed:
	call Level_ScreenLock_DoRight		; Update screen lock info
	
	; Slow speed:   0.75px/frame
	; Normal speed: 1.00px/frame
	; Fast speed:   1.50px/frame
	
	ld   a, [sPlJumpYPathIndex]
	and  a								; Are we in the air anymore?
	jr   z, .ground						; If not, jump
	
	; The different types of jumps have different movement speed.
	ld   b, $01							; B = Normal horizontal speed for jumps
	ld   a, [sPlSuperJump]
	and  a								; == Super jump?
	jr   nz, .chkFastSpeed				
	ld   a, [sHighJump]
	and  a								; == Normal jump?
	jr   z, Pl_MoveRightWithScreen
	jr   .chkFastSpeed					; == High jump
	;--
.ground:
	ld   b, $01							; B = Normal horizontal speed
	ld   a, [sPlAction]
	; Climbing/swimming is at fixed speed
	cp   a, PL_ACT_CLIMB
	jr   z, Pl_MoveRightWithScreen
	cp   a, PL_ACT_SWIM
	jr   z, Pl_MoveRightWithScreen
	
	; Invincibility and Jet Wario try to move at fast speed
	ld   a, [sPlInvincibleTimer]
	and  a
	jr   nz, .chkFastSpeed
	ld   a, [sPlPower]
	cp   a, PL_POW_JET
	jr   z, .chkFastSpeed
	
	; Bull Wario walks at normal speed, even when holding beavy actors
	ld   a, [sPlPower]
	cp   a, PL_POW_BULL
	jr   z, Pl_MoveRightWithScreen
	
	; If we aren't holding anything or it's not heavy, move at normal speed
	ld   a, [sActHeld]
	and  a
	jr   z, Pl_MoveRightWithScreen
	ld   a, [sActHoldHeavy]
	and  a
	jr   z, Pl_MoveRightWithScreen
	
	; Otherwise, we're holding an heavy actor. Move at slow speed.
	; Every 4 frames we decrement the speed by 1. (resulting in not moving at all)
	ld   a, [sTimer]
	and  a, $03
	jr   nz, Pl_MoveRightWithScreen
	dec  b
	jr   Pl_MoveRightWithScreen
.chkFastSpeed:
	; Not sure if intentional or not, but there's no check for Bull Wario here.
	; As a result, it's never possible to do an high jump when carrying an heavy enemy.
	ld   a, [sActHeld]
	and  a							; Holding something?
	jr   z, .fastSpeed				; If not, confirm the fast speed
	ld   a, [sActHoldHeavy]
	and  a							; Holding an heavy enemy?
	jr   nz, Pl_MoveRightWithScreen	; If so, slow down the fast speed back to normal speed
.fastSpeed:
	; Fast speed: every other frame, add 1 to the base speed (1.5px/frame)
	ld   a, [sTimer]
	and  a, $01
	jr   z, Pl_MoveRightWithScreen
	inc  b
; =============== Pl_MoveRightWithScreen ===============
; Moves the player to the right and attempts to scroll the screen at the same speed.
; IN
; - B: Pixels of movement to the right
Pl_MoveRightWithScreen:
	; Don't scroll the screen if there's a scroll lock or we are in an autoscroller/boss scroll
	ld   a, [sLvlScrollLockCur]
	and  a, DIR_L|DIR_R
	jr   nz, Pl_MoveRightStub
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_CHKAUTO
	jr   nc, Pl_MoveRightStub
	;--
	ld   a, [sLvlScrollHAmount]
	add  b							; Scroll += B
	ld   [sLvlScrollHAmount], a
; =============== Pl_MoveRightStub ===============
; Moves the player to the right.
; IN
; - B: Pixels of movement
Pl_MoveRightStub:
	call Pl_MoveRight
	ret
	
; =============== Pl_WalkLeft ===============
; Handles the player walking to the left.
Pl_WalkLeft:
	call Pl_WalkAnim			; Normal walk cycle
	ld   hl, sPlFlags		; Set obj direction
	res  OBJLSTB_XFLIP, [hl]	
	
	ld   a, [sPlIceDelayTimer]	
	and  a						; Is there a delay before moving (by standing on ice)?
	jr   z, .checkFrontSolid	; If not, skip this
	dec  a						; Otherwise, decrement the delay
	ld   [sPlIceDelayTimer], a
	ret							; and don't do anything else
	
.checkFrontSolid:
	;--
	; Can we move left?

	; Check the contents of *both* blocks in front of the player, if any.
	; Since a player can be 2 blocks tall (more or less), we need to check both blocks.
	; (the check with less priority will be ignored if possible)
	
	; [BUG] See the one from Pl_WalkRight
	
	call PlBGColi_DoFront		
	dec  a							; Is there a solid block (either on the top or bottom)? ($01)
	jr   nz, Pl_MoveLeftChkSpeed	; If not, jump
	
	
	call PlBGColi_DoHorzNext		
	and  a							; Is the block *on the bottom* empty?
	ret  nz							; If not, we're going against a solid wall.
	
	ld   b, $03						; Otherwise, we can fit into the gap when ducking
	call Pl_MoveLeft				
	jp   Pl_SetDuckAction			; Autoduck
	
; =============== Pl_AirMoveLeft ===============
; Variant of Pl_WalkLeft for moving left while in the air.
; and without checking for the auto-crouching.
Pl_AirMoveLeft:
	ld   hl, sPlFlags		; Set OBJ direction
	res  OBJLSTB_XFLIP, [hl]
	
	; The timer should count down normally, even in the air
	ld   a, [sPlIceDelayTimer]
	and  a
	jr   z, .checkFrontSolid
	dec  a
	ld   [sPlIceDelayTimer], a
	ret
.checkFrontSolid:
	; We can't perform the automatic crouching in the air.
	
	; This makes the collision check straightforward: 
	; if there's a solid block in front of the player, we can't move left.
	call PlBGColi_DoFront
	dec  a
	ret  z
;--

; =============== Pl_MoveLeftChkSpeed ===============
; This subroutine determines how many pixels to move the player.
; After that, it moves the player to the left by that amount.
Pl_MoveLeftChkSpeed:
	call Level_ScreenLock_DoLeft		; Update screen lock status
	
	; Slow speed:   0.75px/frame
	; Normal speed: 1.00px/frame
	; Fast speed:   1.50px/frame
	
	ld   a, [sPlJumpYPathIndex]	
	and  a								; Are we in the air anymore?			
	jr   nz, .air					; If so, jump (like two instructions after)
	jr   .ground
.air:
	; The different types of jumps have different movement speed.
	ld   b, $01							; B = Normal horizontal speed for jumps
	ld   a, [sPlSuperJump]
	and  a								; == Super jump?
	jr   nz, .chkFastSpeed				
	ld   a, [sHighJump]
	and  a								; == Normal jump?
	jr   z, Pl_MoveLeftWithScreen
	jr   .chkFastSpeed		
	
.ground:
	ld   b, $01							; B = Normal horizontal speed
	ld   a, [sPlAction]
	; Climbing/swimming is at fixed speed
	cp   a, PL_ACT_CLIMB
	jr   z, Pl_MoveLeftWithScreen
	cp   a, PL_ACT_SWIM
	jr   z, Pl_MoveLeftWithScreen
	; Invincibility and Jet Wario try to move at fast speed
	ld   a, [sPlInvincibleTimer]
	and  a
	jr   nz, .chkFastSpeed
	ld   a, [sPlPower]
	cp   a, PL_POW_JET
	jr   z, .chkFastSpeed
	
	; [BUG] They forgot to add a check for Bull Wario here!
	;		You're meant to always move at normal speed in that state, even when carrying an heavy actor.
	;		As a result you move right faster than moving left (when holding an heavy actor).
	
IF FIX_BUGS == 1
	; Bull Wario walks at normal speed, even when holding heavy actors
	ld   a, [sPlPower]
	cp   a, PL_POW_BULL
	jr   z, Pl_MoveLeftWithScreen
ENDC

	; If we aren't holding anything or it's not heavy, move at normal speed
	ld   a, [sActHeld]
	and  a
	jr   z, Pl_MoveLeftWithScreen
	ld   a, [sActHoldHeavy]
	and  a
	jr   z, Pl_MoveLeftWithScreen
	
	; Otherwise, we're holding an heavy actor. Move at slow speed.
	; Every 4 frames we decrement the speed by 1. (resulting in not moving at all)
	ld   a, [sTimer]
	and  a, $03
	jr   nz, Pl_MoveLeftWithScreen
	dec  b
	jr   Pl_MoveLeftWithScreen
.chkFastSpeed:
	; Not sure if intentional or not, but there's no check for Bull Wario here.
	; As a result, it's never possible to do an high jump when carrying an heavy enemy.
	ld   a, [sActHeld]
	and  a							; Holding something?
	jr   z, .fastSpeed				; If not, confirm the fast speed
	ld   a, [sActHoldHeavy]
	and  a							; Holding an heavy enemy?
	jr   nz, Pl_MoveLeftWithScreen	; If so, slow down the fast speed back to normal speed
.fastSpeed:
	; Fast speed: every other frame, add 1 to the base speed (1.5px/frame)
	ld   a, [sTimer]
	and  a, $01
	jr   z, Pl_MoveLeftWithScreen
	inc  b
	
; =============== Pl_MoveLeftWithScreen ===============
; Moves the player to the left and attempts to scroll the screen at the same speed.
; IN
; - B: Pixels of movement to the left
Pl_MoveLeftWithScreen:
	; Don't scroll the screen if there's a scroll lock or we are in an autoscroller/boss scroll
	ld   a, [sLvlScrollLockCur]
	and  a, DIR_L|DIR_R
	jr   nz, Pl_MoveLeftStub
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_CHKAUTO
	jr   nc, Pl_MoveLeftStub
	;--
	ld   a, [sLvlScrollHAmount]
	sub  a, b						; Scroll -= B
	ld   [sLvlScrollHAmount], a
; =============== Pl_MoveLeftStub ===============
; Moves the player to the left.
; IN
; - B: Pixels of movement
Pl_MoveLeftStub:
	call Pl_MoveLeft
	ret
	
; =============== Pl_Unused_SwitchToDuck ===============
; [TCRF] Unreferenced subroutine.
; Makes the player duck if he isn't climbing, without setting
; the actual sPlDuck flag though.
; Purpose unknown.
Pl_Unused_SwitchToDuck: 
	ld   a, [sPlAction]
	cp   a, PL_ACT_CLIMB	; Climbing a ladder?
	ret  z					; If so, return
	
	; Otherwise, make the player duck
	ld   a, OBJ_WARIO_DUCK
	ld   [sPlLstId], a
	ld   a, PL_ACT_DUCK
	ld   [sPlAction], a
	ret
	
; =============== Pl_WalkAnimSlow ===============
; Handles the player walk cycle when carrying heavy actors.
Pl_WalkAnimSlow:
	; Simply perform the normal effect every 8 frames
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	jr   Pl_WalkAnimOBJLst
; =============== Pl_WalkAnim ===============
; Handles the player walk animation (frame setup + SFX).
Pl_WalkAnim:
	; If we aren't walking already, set it now (and start the anim next frame)
	ld   a, [sPlAction]
	cp   a, PL_ACT_WALK
	jp   nz, Pl_SetMoveAction
	
	;--
	; Play the walk SFX and specify the anim speed
	
	; Invincibility or Jet Wario have a fast walk
	ld   a, [sPlInvincibleTimer]
	and  a
	jr   nz, .fastSFX
	ld   a, [sPlPower]
	cp   a, PL_POW_JET
	jr   z, .fastSFX
	; Everything else uses the normal SFX
.normSfx:
	call Wario_PlayWalkSFX_Norm
	; Animate walk cycle every 4 frames
	ld   a, [sTimer]
	and  a, $03
	ret  nz
	jr   Pl_WalkAnimOBJLst
.fastSFX:
	; Fast uses a different SFX
	call Wario_PlayWalkSFX_Fast
	; Animate walk cycle every other frame
	ld   a, [sTimer]
	and  a, $01
	ret  nz
	;--
; =============== Pl_WalkAnimOBJLst ===============
; Updates the player animation frames to perform the walk cycle.
Pl_WalkAnimOBJLst:
	; Small Wario has a different cycle
	ld   a, [sSmallWario]
	and  a
	jr   nz, Pl_WalkAnimOBJLst_Small
	;--
	; Update the player OBJLstId
	ld   hl, OBJLstAnimOff_WarioWalk	
	ld   a, [sPlTimer]	; Index++			
	inc  a
	cp   a, OBJLstAnimOff_WarioWalk.end-OBJLstAnimOff_WarioWalk	; Have we reached the end of the table?
	jr   nz, .noReset		; If not, jump
	xor  a					; Otherwise, reset the index
.noReset:
	ld   [sPlTimer], a	; DE = sPlTimer
	ld   e, a
	ld   d, $00
	add  hl, de				; Offset the anim table
	ld   a, [sPlLstId]	; Add the offset to the frame id
	add  [hl]
	ld   [sPlLstId], a
	ret
OBJLstAnimOff_WarioWalk:
	db -$02,+$01,+$01,-$02,+$03,-$01
.end:
Pl_WalkAnimOBJLst_Small:
	; Same thing for Small Wario
	ld   hl, OBJLstAnimOff_SmallWarioWalk
	ld   a, [sPlTimer]		; Timer++
	inc  a
	; Reset if we reached the end of the table
	cp   a, OBJLstAnimOff_SmallWarioWalk.end-OBJLstAnimOff_SmallWarioWalk
	jr   nz, .noReset
	xor  a
.noReset:
	ld   [sPlTimer], a	; DE = sPlTimer
	ld   e, a
	ld   d, $00
	add  hl, de				; Offset the anim table
	ld   a, [sPlLstId]	; Add the offset to the frame id
	add  [hl]
	ld   [sPlLstId], a
	ret
OBJLstAnimOff_SmallWarioWalk:
	db -$02,+$01,+$01
.end:

; =============== Pl_JumpAnim ===============
; Handles the jumping animation for the player.
; This is special since it accounts for all of the player actions.
Pl_JumpAnim:
	; If we're set to display the throw anim
	ld   a, [sPlJumpThrowTimer]
	and  a							; Is the timer elapsed or not set?
	jr   z, .chkThrowStart			; If so, skip
	dec  a							; Timer--
	ld   [sPlJumpThrowTimer], a
	jr   .setThrow
	;--
.chkThrowStart:
	; Small Wario has no throw anim, so it skips this
	ld   a, [sSmallWario]
	and  a
	jr   nz, .setJumpSmall
	
	; Have we been set to throw something? (last: != 0, held: 0)
	ld   a, [sActHeldLast]
	and  a						; last != 0?
	jr   z, .chkGroundPound		; if not, skip
	ld   a, [sActHeld]
	and  a						; held == 0?
	jr   nz, .chkGroundPound	; if not, skip
	; Show the throw anim for 5 frames
	ld   a, $05-$01
	ld   [sPlJumpThrowTimer], a
.setThrow:
	; sPlDuck ? OBJ_WARIO_DUCKTHROW : OBJ_WARIO_JUMPTHROW
	ld   a, OBJ_WARIO_JUMPTHROW
	ld   [sPlLstId], a
	ld   a, [sPlDuck]			
	and  a
	ret  z
	ld   a, OBJ_WARIO_DUCKTHROW
	ld   [sPlLstId], a
	ret
	;--
.chkGroundPound:
	ld   a, [sPlDuck]
	and  a						; Are we ducking?
	jr   nz, .chkDuck			; If so, we can't be ground pounding
	
	ld   a, [sPlPower]
	cp   a, PL_POW_BULL			; Are we Bull Wario?
	jr   nz, .setJump			; If not, use the normal frame
	
	ldh  a, [hJoyKeys]
	bit  KEYB_DOWN, a			; Are we holding DOWN?
	jr   nz, .setGroundPound	; If so, use the ground pound frame
	
	; Otherwise, fall back to the standard jumping frame
.setJump:
	; sActHeld ? OBJ_WARIO_HOLDJUMP : OBJ_WARIO_JUMP
	ld   a, OBJ_WARIO_JUMP
	ld   [sPlLstId], a
	ld   a, [sActHeld]
	and  a
	ret  z
	ld   a, OBJ_WARIO_HOLDJUMP
	ld   [sPlLstId], a
	ret
.setGroundPound:
	; sActHeld ? OBJ_WARIO_HOLDGROUNDPOUND : OBJ_WARIO_GROUNDPOUND
	ld   a, OBJ_WARIO_GROUNDPOUND
	ld   [sPlLstId], a
	ld   a, [sActHeld]
	and  a
	ret  z
	ld   a, OBJ_WARIO_HOLDGROUNDPOUND
	ld   [sPlLstId], a
	ret
.setJumpSmall:
	; Small Wario lacks many of the special frames while jumping.
	; Only one for holding something exists.
	ld   a, OBJ_SMALLWARIO_JUMP
	ld   [sPlLstId], a
	ld   a, [sActHeld]
	and  a
	ret  z
	ld   a, OBJ_SMALLWARIO_HOLDJUMP
	ld   [sPlLstId], a
	ret
.chkDuck:
	; If we aren't holding DOWN, try to unduck
	ldh  a, [hJoyKeys]
	bit  KEYB_DOWN, a		; Are we (still) holding down?
	jr   z, .chkJump		; If not, try to set the jump anim
	
	; Use the appropriate ducking frame
.setDuck:
	ld   a, [sActHeld]
	and  a
	jr   nz, .setDuckHold
.setDuckNorm:
	ld   a, OBJ_WARIO_DUCK
	ld   [sPlLstId], a
	ret
.setDuckHold:
	ld   a, OBJ_WARIO_DUCKHOLD
	ld   [sPlLstId], a
	ret
.chkJump:
	; The duck flag in the air ends up being set here.
	
	; [BUG] The intention here is to keep the player in the ducking state until there's enough space on top to unduck.
	; 		If there's not enough space yet, the duck flag is properly set...
	; 		...but the animation frame isn't! It's set to the jumping frame by accident.
	;		Because of this, the player appears to partially clip into the ceiling,
	;		even though he's actually not. (which is why you can't jet dash in the "clipping" state)
	
	ld   hl, sPlFlags
	res  OBJLSTB_OBP1, [hl]
	
	xor  a				; Handle the collision for the block above		
	ld   [sPlDuck], a	; which requires unducking, at least temporarily
	call PlBGColi_DoTop
	and  a				; Is there an empty block on top?
	jr   z, .setJump	; If so, use the jump anim
	
	; Otherwise, keep ducking
	ld   a, $01
	ld   [sPlDuck], a
IF FIX_BUGS == 1
	jr   .setDuck
ELSE
	jr   .setJump	; ...and the bug. Should have jumped to .setDuck
ENDC

; =============== Pl_AnimClimb ===============
; Animates the player's climbing animation.
Pl_AnimClimb:
	call Pl_Anim2Frame
	ret
; =============== Pl_StartActionB ===============
; This subroutine starts the powerup-specific action mapped to the B buttton.
Pl_StartActionB:
	; Small Wario has no action assigned to the B key
	ld   a, [sSmallWario]
	and  a
	ret  nz
	; If there's already a dash in progress, don't start a new one
	ld   a, [sPlGroundDashTimer]
	and  a
	ret  nz
	ld   a, [sPlJetDashTimer]
	and  a
	ret  nz
	
	; Depending on the powerup status, pick the action.
	; As a general note, each fo these makes sure the action can't start if we're holding something.
	; This is because throwing is also activated by pressing B.
	ld   a, [sPlPower]
	cp   a, PL_POW_JET
	jp   z, Pl_StartActionB_Jet
	cp   a, PL_POW_DRAGON
	jp   z, Pl_StartActionB_JetOrDragon
; =============== Pl_StartActionB_Garlic ===============
; Starts the action mapped to the B button in the garlic/bull states. 
; This starts a ground dash, with a longer length if we're Bull Wario.
Pl_StartActionB_Garlic:
	; Not if we're holding something
	ld   a, [sActHeld]
	and  a
	ret  nz
	
	; If we're ducking, we may not have enough space to perform a dash
	ld   a, [sPlDuck]
	and  a				; Are we ducking?
	jr   z, .start		; If not, jump
.chkDuck:
	; Disable duck temporarily to allow checking what's above us
	; (since the collision check accounts for ducking)
	xor  a
	ld   [sPlDuck], a
	
	; Check in the alternate mode since checking with the normal set
	; would lead to any blocks above being destroyed/triggered.
	; We don't want to change any blocks with this.
	ld   a, $01
	ld   [sPlBGColiSolidReadOnly], a
	call PlBGColi_DoTop
	and  a				; Is there an empty block above us (collision $00)?
	jr   z, .okSpace	; If so, jump
	; If not, we don't have enough space, so we keep ducking and ignore the request.
	xor  a
	ld   [sPlBGColiSolidReadOnly], a
	ld   a, $01
	ld   [sPlDuck], a
	ret
.okSpace:
	xor  a
	ld   [sPlBGColiSolidReadOnly], a
.start:
	ld   a, OBJ_WARIO_DASH0			; Set initial frame
	ld   [sPlLstId], a
	xor  a							; Reset timers
	ld   [sPlTimer], a
	ld   [sPlDuck], a
	ld   a, PL_ACT_DASH
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	ld   a, SFX4_01
	ld   [sSFX4Set], a
	; Depending on the powerup status, pick the dash length
	ld   a, $30						; Bull Wario: $30
	ld   [sPlGroundDashTimer], a
	ld   a, [sPlPower]
	cp   a, PL_POW_BULL				; Are we bull Wario?
	ret  z							; If so, return
	ld   a, $18						; Garlic: $18
	ld   [sPlGroundDashTimer], a
	ret
; =============== Pl_StartActionB_Jet ===============
; Starts the action mapped to the B button in the jet state. 
; This starts a jet dash.
Pl_StartActionB_Jet:
	ld   a, [sPlPower]		; Just in case
	cp   a, PL_POW_JET
	ret  nz
	ld   a, [sPlJetDashTimer]	; Not if we're already dashing
	and  a
	ret  nz
	ld   a, [sActHeld]			; Of it we're holding something
	and  a
	ret  nz
	
	; If we're ducking, check if we have enough space to start a dash
	; Like what's done for the ground dash
	ld   a, [sPlDuck]
	and  a						; Are we ducking?
	jr   z, .start				; If not, skip
.chkDuck:
	xor  a						
	ld   [sPlDuck], a
	ld   a, $01
	ld   [sPlBGColiSolidReadOnly], a
	call PlBGColi_DoTop
	and  a						; Is there an empty block above us?
	jr   z, .okSpace			; If so, jump
	; If not, keep ducking and ignore the request.
	xor  a
	ld   [sPlBGColiSolidReadOnly], a
	ld   a, $01
	ld   [sPlDuck], a
	ret
.okSpace:
	xor  a
	ld   [sPlBGColiSolidReadOnly], a
.start:
	ld   a, $80
	ld   [sPlJetDashTimer], a
	ld   a, SFX4_0F
	ld   [sSFX4Set], a
	xor  a
	ld   [sPlSuperJump], a
	ld   [sPlJumpYPathIndex], a
	ld   [sPlDuck], a
	ld   [sPlSlowJump], a		; 
	ld   a, PL_ACT_DASHJET
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	ld   a, OBJ_WARIO_DASHFLY
	ld   [sPlLstId], a
	ld   hl, sPlFlags		; Not sure why the palette's reset 
	res  OBJLSTB_OBP1, [hl]
	;--
	; Spawn the jet flame actor
	ld   a, EXACT_JETHATFLAME
	ld   [sExActSet], a
	; Same Y as player
	ld   a, [sPlY_High]
	ld   [sExActOBJY_High], a
	ld   a, [sPlY_Low]
	ld   [sExActOBJY_Low], a
	; Position the jet flame depending on the player direction
	; (opposite direction since it's behind the player)
	ld   b, $16
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a		; Is the X flip set?
	jr   nz, .right				; If so, the player is facing right
.left:
	call PlTarget_SetRightPos
	jr   .setX
.right:
	call PlTarget_SetLeftPos
.setX:
	ld   a, [sTarget_High]
	ld   [sExActOBJX_High], a
	ld   a, [sTarget_Low]
	ld   [sExActOBJX_Low], a
	
	ld   a, OBJ_JETHATFLAME0
	ld   [sExActOBJLstId], a
	ld   a, [sPlFlags]
	ld   [sExActOBJFlags], a
	; Clear unused area
	ld   hl, sExActLevelLayoutPtr_High
	xor  a
	ld   b, $09
	call ClearRAMRange_Mini
	call ExActS_Spawn
	ret
; =============== Pl_StartActionB_JetOrDragon ===============
Pl_StartActionB_JetOrDragon:
	; Jump accordingly based on the powerup
	ld   a, [sPlPower]			
	cp   a, PL_POW_JET
	jp   z, Pl_StartActionB_Jet
	cp   a, PL_POW_DRAGON
	ret  nz
	ld   a, [sPlDragonHatActive]	; Ignore if the flame is active already
	and  a
	ret  nz
	ld   a, [sActHeld]				; Or if we're holding something
	and  a
	ret  nz
	
	ld   a, $01
	ld   [sPlDragonHatActive], a
	
	;--
	; Spawn the dragon flame actor
	ld   a, EXACT_DRAGONHATFLAME
	ld   [sExActSet], a
	; If the player is ducking use a different Y pos
	ld   b, $10						; $10: Default Y pos
	ld   a, [sPlDuck]
	and  a							; Is the player ducking?
	jr   z, .highYPos				; If not, jump
	ld   b, $08						; $08: Y pos when ducking
.highYPos:
	call PlTarget_SetUpPos
	ld   a, [sTarget_High]
	ld   [sExActOBJY_High], a
	ld   a, [sTarget_Low]
	ld   [sExActOBJY_Low], a
	; Pick a different X pos depending on the player direction
	ld   b, $14						
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a			; Is the X flip set?
	jr   nz, .right					; If so, the player is facing right
.left:
	call PlTarget_SetLeftPos		; $14 left: When facing left
	jr   .setX
.right:
	call PlTarget_SetRightPos		; $14 right: When facing right
.setX:
	ld   a, [sTarget_High]
	ld   [sExActOBJX_High], a
	ld   a, [sTarget_Low]
	ld   [sExActOBJX_Low], a
	
	ld   a, OBJ_DRAGONHATFLAME_A0
	ld   [sExActOBJLstId], a
	ld   a, [sPlFlags]
	ld   [sExActOBJFlags], a
	; Clear rest of space
	ld   hl, sExActLevelLayoutPtr_High
	xor  a
	ld   b, $09
	call ClearRAMRange_Mini
	call ExActS_Spawn
	ret
; =============== Pl_DoCtrl_Stand_Idle ===============
; Handles the action in which the player stands still without doing anything.
; This will play the idle anim and reset various vars.
Pl_DoCtrl_Stand_Idle:
	; [POI] These checks are pointless.
	; This is only called when we're already in the stand action.
	; To switch to the standing anim, other actions call Pl_SwitchToStand directly.
	;--
	ld   a, [sPlAction]
	cp   a, PL_ACT_CLIMB
	ret  z
	and  a 							
	jp   nz, Pl_SwitchToStand	
	;--
; =============== Pl_IdleAnim ===============
Pl_IdleAnim:
	; Every 8 frames
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	;--
	; Small Wario uses different frames
	ld   a, [sSmallWario]
	and  a
	jr   nz, .small
	
	; No idle anim when holding something
	ld   a, [sActHeld]		
	and  a
	ret  nz
	;--
	; If we've stopped holding something but we're still using that frame,
	; reset it to the standing frame.
	ld   a, [sPlLstId]	
	cp   a, OBJ_WARIO_HOLD
	jr   nz, .noStandReset
	
	xor  a
	ld   [sPlTimer], a
	ld   a, OBJ_WARIO_STAND
	ld   [sPlLstId], a
	;--
.noStandReset:	
	; Each entry in this table marks the amount to add to sPlLstId.
	ld   hl, OBJLstAnimOff_WarioIdle		; HL = Ptr to anim offset table
	
	; Update the idle frame timer, which will be treated as as index
	; sPlTimer = ((sPlTimer+1) & $1C) (+8 on folliwing loops)
	ld   a, [sPlTimer]	
	inc  a
	cp   a, (OBJLstAnimOff_WarioIdle.end-OBJLstAnimOff_WarioIdle) ; Did we reach the end of the table?
	jr   nz, .noTimerReset	; If not, jump
	ld   a, $08				; If so, reset the index back to $08 (skipping the initial delay)
.noTimerReset:
	ld   [sPlTimer], a
	
	ld   e, a				; Index the offset table
	ld   d, $00
	add  hl, de
	
	ld   a, [sPlLstId]	; sPlLstId += OBJLstAnimOff_WarioIdle[sPlTimer]
	add  [hl]
	ld   [sPlLstId], a
	ret
	
.small:
	; Do similar for Small Wario, except with different frame numbers and table ptrs
	ld   a, [sActHeld]
	and  a
	ret  nz
	;--
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	
	;--
	; Reset held anim
	ld   a, [sPlLstId]
	cp   a, OBJ_SMALLWARIO_HOLD
	jr   nz, .noStandResetS
	xor  a
	ld   [sPlTimer], a
	ld   a, OBJ_SMALLWARIO_STAND
	ld   [sPlLstId], a
.noStandResetS:
	; Index the anim offsets table
	; Once we go past it, reset the index to $00
	ld   hl, OBJLstAnimOff_SmallWarioIdle
	ld   a, [sPlTimer]	; Index++
	inc  a
	cp   a, (OBJLstAnimOff_SmallWarioIdle.end-OBJLstAnimOff_SmallWarioIdle)
	jr   nz, .noTimerResetS
	xor  a
.noTimerResetS:
	ld   [sPlTimer], a	; Index it
	ld   e, a
	ld   d, $00
	add  hl, de
	
	ld   a, [sPlLstId]	; sPlLstId += OBJLstAnimOff_SmallWarioIdle[sPlTimer]
	add  [hl]
	ld   [sPlLstId], a
	ret
; =============== Pl_SwitchToStand ===============
; Switches to the stand action.
Pl_SwitchToStand:
	;--
	; Why are we checking for this here? 
	; Because of back and forths with the collision code when 
	; updating the player action in the middle of things.
	;
	; When hitting a bounce block, two main things happen:
	; - The superjump flag is set
	; - The player is put in the "jumping" action
	;
	; The bounce block is still considered a solid block though.
	;
	; When the code for the standing action checks collision with the block 
	; on the ground through PlBGColi_Ground, the bounce block is activated.
	; Then it sees that:
	; - The player's action isn't PL_ACT_STAND anymore
	; - There is a solid block below
	;
	; So it calls this subroutine to put the player back in the standing action.
	; Which is where we avoid resetting everything if the superjump is active.
	;
	; This isn't a problem with normal jumps, since it detect the player holding "A"
	; and skips the part of code which would call this.
	;
	; Also note that when landing from a jump, sPlSuperJump is first reset and then game calls this subroutine.
	; This means we inevitably switch to the standing mode, even after landing on a bounce block (since it's solid, after all).
	ld   a, [sPlSuperJump]
	and  a
	ret  nz
	;--
	; Reset everything
	xor  a
	ld   [sPlTimer], a
	ld   [sPlDuck], a
	ld   [sPlGroundDashTimer], a
	ld   [sPlJetDashTimer], a
IF IMPROVE == 0
	ld   [sPlMovingJump], a
ENDC
	ld   [sHighJump], a
	ld   [sPlJumpYPathIndex], a
	
	ld   hl, sPlFlags
	res  OBJLSTB_OBP1, [hl]
	; Set the stand anim depending on small/big Wario
	ld   a, OBJ_WARIO_STAND
	ld   [sPlLstId], a
	ld   a, [sSmallWario]
	and  a
	jr   z, Pl_SwitchToStand2
	ld   a, [sPlLstId]
	add  OBJ_SMALLWARIO_STAND-OBJ_WARIO_STAND
	ld   [sPlLstId], a
; =============== Pl_SwitchToStand2 ===============
; Switches to the stand action without updating the player frame (though the hold frame will be set regardless).
; Can be used to set an alternate standing frame.
Pl_SwitchToStand2:
	xor  a
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	;--
	; [POI] It shouldn't be possible anyway
	ld   a, [sPlHatSwitchTimer]
	and  a
	ret  nz
	;--
	
	; Check if we should scroll the screen.
	; This is generally triggered after landing from a jump.
	; ...unless we're standing on a solid actor (ie: checkpoint; coin lock, ...).
	;
	; There's a good(?) reason for this: actors you can stand on top of are occasionally
	; positioned near the edge of a scroll level. Going by the normal SEGSCRL rules, 
	; stepping on one of those would cause the screen to scroll up, reveal possibly blocks of other rooms,
	; and then the solid actor would despawn, causing the screen to scroll back down.
	; This isn't very nice (but you can still trigger this anyway since they forgot to account for this in the ground pound...)
	ld   a, [sPlActSolid]
	and  a									; Standing on a solid actor?
IF OPTIMIZE == 1
	call z, Level_Scroll_CheckSegScroll	; If not, call
ELSE
	call z, Level_Scroll_CheckSegScrollAlt	; If not, call
ENDC
	; If we're holding something, pick the correct anim
	ld   a, [sActHeld]
	and  a					; Holding something?
	ret  z					; If not, return
	ld   a, OBJ_WARIO_HOLD
	ld   [sPlLstId], a
	ld   a, [sSmallWario]
	and  a					; Small Wario?
	ret  z					; If not, return
	ld   a, OBJ_SMALLWARIO_HOLD
	ld   [sPlLstId], a
	ret
; =============== OBJLstAnimOff_WarioIdle ===============
; Table of offsets (inc amount to current anim frame) for playing the idle anim.
OBJLstAnimOff_WarioIdle: 
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$01	; Hands down
	db +$00 ; Start of next loops
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$01	; Blinking
	db -$01
	db +$01
	db -$01
.end:
OBJLstAnimOff_SmallWarioIdle:
	db -$01
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$00
	db +$01
	db -$01
	db +$01
.end:

; =============== Level_Scroll_CheckSegScroll ===============
; Checks if the screen should be scrolled up or down in SEGSCRL mode.
; OUT
; - A: Scroll direction value
Level_Scroll_CheckSegScroll:
	; Ignore movement outside of SEGSCRL mode (and the train effect mode $01)
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_FREE					; Are we in SEGSCRL mode? (< $10)
	jr   nc, Level_Scroll_SegScrollNoChange	; If not, jump
	
	; NOTE: Scroll levels are "reversed" compared to the Y coordinate.
	;       The scroll level at the very bottom is "Level 1", and the number increases going upwards.
	call Level_GetScrollLevel				; C = Current scroll level
	ld   a, [sLvlScrollLevel]				; A = Old scroll level
	sub  a, c								; Are they identical? (A - C == 0)
	ret  z									; If so, the scroll pos is fine
	
	jr   c, Level_Scroll_SegScrollUp		; Old < Current?
	
; [BUG] Both subroutines are bugged and can cause the scroll glitch.
;
;       The problem here is the inconsistency between how sLvlScrollLevel is updated and how the screen scroll timer is set.
;       The screen can scroll at most by one level, which accounts for the timer being set to $80.
;       However, sLvlScrollLevel is set by C, which is calculated by adding or subtracting the difference 
;       between the current (Level_GetScrollLevel) and reported (sLvlScrollLevel) level.
;       This breaks if the screen scrolls more than one level, which causes sLvlScrollLevel to desync.
;       After that, the screen won't scroll a second time, since the game believes the scrolling is already correct.
;
;		Incrementing or decrementing sLvlScrollLevel by exactly 1 will prevent the desync from occurring,
;       though the screen will still scroll up only once
;       (until an action that scrolls the screen is triggered, like switching to the stand action).
;		Ideally there should also be a flag to request a re-scroll (or just calling Level_Scroll_CheckSegScroll while standing).

; =============== Level_Scroll_SegScrollDown ===============
; This subroutine scrolls the screen downwards by a single scroll level during SEGSCRL mode.
; IN
; - C: Should be sLvlScrollLevel-1
; OUT
; - A: Scroll direction value
Level_Scroll_SegScrollDown:
IF FIX_BUGS == 1
	ld   a, [sLvlScrollLevel]
	dec  a
ELSE
	ld   a, c					; [BUG] Set the updated scroll level (hopefully only differs by 1)
ENDC
	ld   [sLvlScrollLevel], a
	ld   a, DIR_D				; Trigger the screen scroll
	ld   [sLvlScrollSet], a
	ld   a, $01					; Freeze actors while this happens (too bad pausing cancels this)
	ld   [sPauseActors], a
	ld   a, $80					; Scroll for a single screen
	ld   [sLvlScrollTimer], a
	ld   a, SFX1_07
	ld   [sSFX1Set], a
	ld   a, +$01				; Down
	ret
; =============== Level_Scroll_SegScrollUp ===============
; This subroutine scrolls the screen upwards by a single scroll level during SEGSCRL mode.
; IN
; - C: Should be sLvlScrollLevel+1
; OUT
; - A: Scroll direction value
Level_Scroll_SegScrollUp:
IF FIX_BUGS == 1
	ld   a, [sLvlScrollLevel]
	inc  a
ELSE
	ld   a, c					; [BUG] Set the updated scroll level (hopefully only differs by 1)
ENDC
	ld   [sLvlScrollLevel], a
	ld   a, DIR_U				; Trigger the screen scroll
	ld   [sLvlScrollSet], a
	ld   a, $01					; Freeze actors while this happens (too bad pausing cancels this)
	ld   [sPauseActors], a
	ld   a, $80					; Scroll for a single screen
	ld   [sLvlScrollTimer], a
	ld   a, SFX1_07
	ld   [sSFX1Set], a
	ld   a, -$01				; Down
	ret
; =============== Level_Scroll_CheckSegScrollDown ===============
; Checks if the screen should be scrolled down in SEGSCRL mode.
; Similar to Level_Scroll_CheckSegScroll, but requests for scrolling the screen up will be ignored.
; OUT
; - A: Scroll direction value
Level_Scroll_CheckSegScrollDown:
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_FREE					; Are we in SEGSCRL mode? (< $10)
	jr   nc, Level_Scroll_SegScrollNoChange	; If not, jump
	
	call Level_GetScrollLevel				; C = Current scroll level
	ld   a, [sLvlScrollLevel]				; A = Old scroll level
	sub  a, c								; Are they identical? (A - C == 0)
	ret  z									; If so, the scroll pos is fine
	
	jr   nc, Level_Scroll_SegScrollDown		; Old > Current?
	; Ignore the upwards request
	
; =============== Level_Scroll_SegScrollNoChange ===============
; Used to mark no-change if the current scroll mode isn't SEGSCRL.
; OUT
; - A: $00 (No direction)
Level_Scroll_SegScrollNoChange:
	xor  a						; No change
	ret
	
; Since it's a duplicate subroutine, it can be removed.
IF OPTIMIZE == 0
; =============== Level_Scroll_CheckSegScrollAlt ===============
; Checks if the screen should be scrolled up or down in SEGSCRL mode.
; This is identical to Level_Scroll_CheckSegScroll, but is only called after a few actions (like ending a jump).
; OUT
; - A: Scroll direction value
Level_Scroll_CheckSegScrollAlt:
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_FREE					; Are we in SEGSCRL mode? (< $10)
	jr   nc, Level_Scroll_SegScrollNoChange	; If not, jump
	
	call Level_GetScrollLevel				; C = Current scroll level
	ld   a, [sLvlScrollLevel]				; A = Old scroll level
	sub  a, c								; Are they identical? (A - C == 0)
	ret  z									; If so, the scroll pos is fine
	
	jr   c, Level_Scroll_SegScrollUp		; Old < Current?
	; [TCRF] We never get here, since downwards scrolling is automatic and not action-specific.
	jr   Level_Scroll_SegScrollDown 
ENDC

; =============== Pl_Anim2FrameSlow ===============
; Animates a player's 2 frame animation cycle every $10 frames.
; Identical to Pl_Anim2Frame except slower.
; Only used for animating the duck walk.
Pl_Anim2FrameSlow:
	; Animate every $10 frames
	ld   a, [sTimer]
	and  a, $0F
	ret  nz
	; Alternate between OBJ_WARIO_DUCK ($10) and OBJ_WARIO_DUCKWALK ($11)
	ld   a, [sPlLstId]
	xor  $01
	ld   [sPlLstId], a
	ret
	
; =============== Pl_DoCtrl_Sand ===============
Pl_DoCtrl_Sand:
	; Always prevent ducking
	; Would have been nicer if you couldn't duck when coming from a walk/dash but oh well
	xor  a
	ld   [sPlDuck], a
	
	call Pl_SetFlipByJoyKeys
	;--
	; Handle player controls
	; When inside a sand block, it's possible to start a new jump while another jump is active.
	; Because jumps are so low, this is required to navigate it.
	ldh  a, [hJoyNewKeys]
	bit  KEYB_A, a			; Starting a new jump?
	jr   nz, .startJump		; If so, jump
	
	bit  KEYB_B, a			; B: New special action
	call nz, Pl_StartActionB_JetOrDragon
	ld   a, [sPlNewAction]
	and  a					; Did we start an action on Pl_StartActionB_JetOrDragon?
	ret  nz					; If so, end this
	;--
	; Check for the an existing jump
	ld   a, [sPlSandJump]
	and  a
	jr   nz, .doJump
	; Otherwise we're on the ground or moving below
	jp   .chkFall
	
;
; JUMP / "AIR" MOVEMENT
;
.startJump:
	ld   a, SFX1_05		; Set SFX
	ld   [sSFX1Set], a
	ld   a, $01				; Signal start of sand jump
	ld   [sPlSandJump], a
	
	xor  a					; Reset jump index
	ld   [sPlJumpYPathIndex], a
	;--
	; Determine correct jump frame, based on small and held status
	ld   a, [sSmallWario]
	and  a						; Are we small?
	jr   nz, .sjSmall			; If so, jump
.sjNormal:
	ld   a, OBJ_WARIO_JUMP		; Set normal frame
	ld   [sPlLstId], a
	ld   a, [sActHeld]
	and  a						; Are we holding something?
	jr   z, .doJump				; If not, jump
	ld   a, OBJ_WARIO_HOLDJUMP	; Set held frame
	ld   [sPlLstId], a
	jr   .doJump
.sjSmall:
	ld   a, OBJ_SMALLWARIO_JUMP	; Set normal small frame
	ld   [sPlLstId], a
	ld   a, [sActHeld]
	and  a						; Holding something?
	jr   z, .doJump				; If not, jump
	ld   a, OBJ_SMALLWARIO_HOLDJUMP ; Set held small frame
	ld   [sPlLstId], a
.doJump:
	;--
	ldh  a, [hJoyKeys]
	bit  KEYB_A, a				; Are we pressing A?
	jr   z, .endJump			; If not, jump
	
	; Handle the collision for the block on top.
	call PlBGColi_DoTop
	and  a ; COLI_EMPTY			; Is this an empty block?
	jp   z, .switchToNormalJump	; If so, jump
	dec  a ; COLI_SOLID			; Is this a solid block?
	jr   z, .endJump			; If so, jump
	
	; Otherwise, we're still in sand (water block)
	; Get the amount of px to move the player up.
	ld   a, [sPlJumpYPathIndex]	; DE = sPlJumpYPathIndex
	ld   e, a
	ld   d, $00
	ld   hl, Pl_SandJumpYOffTable		; HL = Y Offset table
	add  hl, de							; Index it
	ld   a, [hl]						; B = Y offset
	; $80 is a special value that ends the jump.
	; (unlike other Y Offset tables, this one has an end separator).
	cp   a, $80
	jr   z, .endJump
	; Move the player up by that amount of px
	ld   b, a
	call Pl_MoveUp
	ld   hl, sPlJumpYPathIndex	; Index++
	inc  [hl]
	
	; For some reason, collision in front is checked every other frame
	ld   a, [sTimer]				
	and  a, $01
	ret  nz
	call PlBGColi_DoFront
	dec  a
	ret  z
	
.chkCtrlLR:
	; Handle LEFT/RIGHT movement (only when jumping)
	; These actions move the screen and the player 1px to the left or right
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jr   nz, .airMoveRight
	bit  KEYB_LEFT, a
	jr   nz, .airMoveLeft
	ret
.airMoveRight:
	call Level_ScreenLock_DoRight	; Update screen scroll
	ld   b, $01						; Move 1px right
	call Pl_MoveRightWithScreen
	ret
.airMoveLeft:
	call Level_ScreenLock_DoLeft
	ld   b, $01
	call Pl_MoveLeftWithScreen
	ret
.endJump:
	xor  a
	ld   [sPlJumpYPathIndex], a
	ld   [sPlSandJump], a
	
;
; GROUND / FALL MOVEMENT
;
.chkFall:
	; Check what's below
	call PlBGColi_DoGround
	
	; [BUG?] This check ends up preventing jumping into sand from below,
	;		 since it would trigger as soon as you jump into it.
	;        (water has a similar problem)
	and  a ; COLI_EMPTY				; Is there an empty block below?
	jp   z, Pl_SwitchToJumpFall2	; If so, switch to the fall anim
	
	cp   a, COLI_SOLID				; Is there a solid block below?
	jr   nz, .fallSand				; If not, jump
	
	; Otherwise, there's solid ground below
.ground:

	; There's no real movement on the ground.
	; All we can do is duck (if we aren't Small Wario), while the rest
	; just sets up the correct anim frame.
	
	ld   a, [sSmallWario]
	and  a					; Are we Small Wario?
	jr   nz, .gSmall		; If so, skip the duck check
	ldh  a, [hJoyKeys]
	bit  KEYB_DOWN, a		; Are we ducking?
	jr   nz, .gDuck			; If so, jump
.gNormal:
	; Pick correct anim frame
	ld   a, OBJ_WARIO_IDLE0
	ld   [sPlLstId], a
	ld   a, [sActHeld]
	and  a
	ret  z
	ld   a, OBJ_WARIO_HOLD
	ld   [sPlLstId], a
	ret
.gSmall:
	; Pick correct anim frame for Small Wario
	ld   a, OBJ_SMALLWARIO_STAND
	ld   [sPlLstId], a
	ld   a, [sActHeld]
	and  a
	ret  z
	ld   a, OBJ_SMALLWARIO_HOLD
	ld   [sPlLstId], a
	ret
.gDuck:
	; Set duck flag
	ld   a, $01
	ld   [sPlDuck], a
	; Pick correct anim frame when ducking
	ld   a, OBJ_WARIO_DUCK
	ld   [sPlLstId], a
	ld   a, [sActHeld]
	and  a
	ret  z
	ld   a, OBJ_WARIO_DUCKHOLD
	ld   [sPlLstId], a
	ret
	
.fallSand:
	; We're falling in the sand
	; Normally downwards movement is 1px/frame, but holding DOWN will increase it to 2px/frame.
	
	ldh  a, [hJoyKeys]
	bit  KEYB_DOWN, a		; Holding DOWN?
	jr   nz, .fastFall		; If so, use the faster fall speed.
.normFall:
	ld   b, $01				; B = Normal fall speed
	jr   .doFall
.fastFall:
	ld   b, $02				; B = Faster fall speed
.doFall:
	call Pl_MoveDown		; Move player down by that amount
	
	; Handle collision on front every other frame
	ld   a, [sTimer]
	and  a, $01
	ret  nz
	call PlBGColi_DoFront
	dec  a ; COLI_EMPTY		; Is there a solid block on in front?
	ret  z					; If so, return
	jp   .chkCtrlLR			; Otherwise, allow LEFT/RIGHT movement while falling
	
.switchToNormalJump:
	; Triggered when exiting quicksand
	xor  a
	ld   [sPlSand], a
	ld   [sPlSandJump], a
	jp   Pl_StartJump
	
; All upwards movement for the small jumps in quicksand
Pl_SandJumpYOffTable: 
	db $02,$02,$02,$01,$01,$01,$00
	db $80 ; END
	
; =============== Pl_SetFlipByJoyKeys ===============
; This subroutine sets the player's OBJLst flip status depending on the direction held.
Pl_SetFlipByJoyKeys:
	ldh  a, [hJoyKeys]
	bit  KEYB_RIGHT, a
	jr   nz, .right
	bit  KEYB_LEFT, a
	jr   nz, .left
	ret
.right:
	ld   hl, sPlFlags
	set  OBJLSTB_XFLIP, [hl]
	ret
.left:
	ld   hl, sPlFlags
	res  OBJLSTB_XFLIP, [hl]
	ret
; =============== Pl_DoCtrl_TreasureGet ===============
; This is a special action used when controls are frozen after holding an hidden treasure.
; After a while, the game switches to the treasure room and plays the anim.
Pl_DoCtrl_TreasureGet:
	; The anim frame is handled "automatically" elsewhere
	ld   a, [sPlLstId]
	cp   a, OBJ_WARIO_HOLD	; Is the player in the *standing* hold anim?
	jr   z, .ground			; If so, jump
	
.air:
	; Otherwise, we're still in the air
	; Make the player fall until landing on solid ground.
	call PlBGColi_DoGround		; Handle collision below
	dec  a ; COLI_SOLID			; Is there a solid block below?
	jr   z, .switchToGround				; If so, switch to ground
	ld   a, $70
	ld   [sPlLstId], a
	ld   hl, Pl_JumpYPath
	ld   d, $00
	ld   a, [sPlJumpYPathIndex]
	ld   e, a
	add  hl, de
	ld   b, [hl]
	call Pl_MoveDown
	ld   a, [sPlJumpYPathIndex]
	inc  a
	cp   a, $48
	ret  z
	ld   [sPlJumpYPathIndex], a
	ret
.switchToGround:
	; Switching to the ground starts the anim proper
	ld   a, [sPlY_Low]		; Align to block Y boundary
	and  a, $F0
	ld   [sPlY_Low], a
	ld   a, SFX1_21		; Set SFX/BGM
	ld   [sSFX1Set], a
	ld   a, BGM_TREASUREGET
	ld   [sBGMSet], a
	ld   a, OBJ_WARIO_HOLD		; Set anim frame
	ld   [sPlLstId], a
	ld   a, $E0					; Set delay before fading out to treasure screen
	ld   [sPlTimer2], a
	ret
.ground:
	; Wait until the timer is elapsed
	ld   a, [sPlTimer2]
	dec  a
	ld   [sPlTimer2], a
	ret  nz
	
	;--
	; Permanently despawn the actor for the treasure from the level.
	
	; First, mark the actor slot as free
	ld   a, [sTreasureActSlotPtr_High]	; HL = Ptr to actor slot for treasure
	ld   h, a
	ld   a, [sTreasureActSlotPtr_Low]
	ld   l, a
	ld   [hl], $00	; Write $00 to mark the slot as free
	
	; Then, remove the actor flag from the block
	; Doing this when marking the slot as free prevents the game from saving
	; the actor coordinates back to the actor layout, permanently despawning it.
	ld   de, $001C	; Point to the level layout ptr
	add  hl, de		
	ldi  a, [hl]	; HL = Value from the table
	ld   h, [hl]
	ld   l, a
	res  7, [hl]	; Remove actor flag (MSB)
	;--
	xor  a
	ld   [sActHeld], a
	ld   [sActHeldLast], a
	; Fade out to the treasure room
	ld   a, GM_TREASURE
	ld   [sGameMode], a
	xor  a
	ld   [sSubMode], a
	ret
	
; =============== Actor collision box helpers ===============
	
; =============== mAbsBoxBound ===============
; Gets the position of a collision border, relative to the screen.
; Must be used since collision boxes are relative to the actor's origin.
; IN
; - 1: Ptr to box collision border height/width
; - 2: Ptr to coordinate the box collision is relative to
; - E: Some constant which is always $B0
; OUT
; - A: Collision border position (x or y), relative to the screen.
MACRO mAbsBoxBound
	ld   hl, \1			; HL = Box height in direction (relative to origin)
	ld   a, [\2]		; A = Actor relative coord (X or Y)
	add  [hl]		; A = Box + ActRelCoord
	sub  a, e			; (ignore this line)
ENDM

; Shorthand for performing a bounds check on a single border.
; IN
; - 1: Ptr to lower box collision border higher (top or left border)
; - 2: Ptr to the coordinate \1 is relative to
; - 3: Ptr to higher box collision border (bottom or right border)
; - 4: Ptr to the coordinate \3 is relative to
; - 5: Ptr to label for failed check
; - 6: Jump type
; OUT
; - A: Distance between the two borders 
;      The smallest the value is, the higher priority it has.
MACRO mActColiChkBorder
	; The lower/higher designation is important.
	
	; By checking the opposite corners (right -> left, up -> down...) of two different bounding boxes,
	; we can determine if there's no collision, and just skip to the next slot.
	; If the higher coordinate of one box is after the lower of another one, it's impossible to have a collision between those.
	; ie:    (top)                                     (bottom)
	; ie:    (left)                                    (right)
	
	; Calculate the absolute value of the higher direction
	; B = \1 + \2 
	mAbsBoxBound \1, \2
	ld   b, a				
	; Calculate the absolute value of the lower direction
	; A = \3 + \4
	mAbsBoxBound \3, \4	
	
	; Calculate the distance between the two borders.
	; If it ends up being negative (LowAbs < HighAbs), the two actors aren't touching
	sub  a, b							; Is A < B?
	\6   c, \5							; If so, jump
	;--
ENDM
	
; =============== ExActActColi_DragonHatFlame ===============
; This subroutine checks for actor collision against the dragon hat flame.
; The first actor which satisfies the collision type and bounding box requirement is picked,
; as only one actor at a time can be handled.
;
; This can only be called when processing the dragon hat flame ExAct, and after it's drawn on screen,
; since it expects variables like sExActOBJYRel to point to the dragon hat info.
ExActActColi_DragonHatFlame:
	; The dragon hat flame can actually stay active while dead.
	; Though we shouldn't process collision anymore in that case.
	ld   a, [sPlAction]
	cp   a, PL_ACT_DEAD			
	ret  z
	
	;--
	; Loop through all actor slots, to find one which satisfies the aforemented requirements.
	ld   hl, sAct				; HL = Ptr to first actor slot
.loop:
	ld   a, h				
	cp   a, HIGH(sAct_End)		; Have we reached the end of the actor slot area?
	ret  z						; If so, it didn't collide with anything
	;--
	ld   [sActSlotPtr_High], a	; Save the actor slot ptr we're on
	ld   a, l
	ld   [sActSlotPtr_Low], a
	
	; As a side effect of going by the relative position calculated by writing the OBJLst,
	; we can only interact with visible actors.
	ld   a, [hl]				; Read active status
	cp   a, $02					; Is it visible and active?
	jr   nz, .nextSlot			; If not, jump
	;--
	
	; Verify that the flame can interact with the actor.
	; To do this we simply check the collision type currently set to the slot.
	ld   de, sActSetColiType - sActSet	; Point to collision value ptr
	add  hl, de
	
	; Verify collision type.
	; With the exception of ACT_TOPSOLIDHIT (since you can attack it with the hat flame),
	; all other actors with special collision types should be ignored. 
	ldi  a, [hl]
	cp   a, ACTCOLI_TOPSOLIDHIT	; Is this an attackable top solid platform (including trasure lid)? 
	jr   z, .valOk				; If so, we can open it
	and  a, $C0					; Is this a standard collision bitmask? (val >= $40)?
	jr   z, .nextSlot			; If not, ignore the slot
.valOk:
	; Copy everything needed for the bounding box check to the working area
	ldi  a, [hl]		; $06 - Bounding box top
	ld   [sActTmpColiBoxU], a
	ldi  a, [hl]		; $07 - Bounding box bottom
	ld   [sActTmpColiBoxD], a
	ldi  a, [hl]		; $08 - Bounding box left
	ld   [sActTmpColiBoxL], a
	ldi  a, [hl]		; $09 - Bounding box right
	ld   [sActTmpColiBoxR], a
	ldi  a, [hl]		; $0A - RelY / Origin
	ld   [sActTmpRelY], a
	ld   a, [hl]		; $0B - RelX / Origin
	ld   [sActTmpRelX], a
	
	; Perform the bounding box check to determine if the dragon hat flame is colliding with an actor.
	; For each of these we simply compare the range values.
	;
	; As usual this is based on the relative coords OBJLst are drawn,
	; which is why you can interact with them even after triggering the scroll glitch.
	
	; [POI] Curiously, the bounding box of the dragon hat flame isn't hardcoded
	;		even though it's always set to the same values.
	;		Maybe there was some way it could change? (ie: when starting or ending the flame)
	
	; For some reason, all values in the checks are subtracted by $B0.
	; This cancels itself out, so it might as well be $00.
	ld   e, $B0	

	; All border checks follow a similar template
	; (except with Actor and Flame variables checked on the opposite side for < checks)
	;
	; For an example with the top bounding box:
	; ColiBoxU is the height the collision box extends upwards, relative to the actor's origin (aka the relative pos here).
	; For comparing between actor and flame coli boxes, both need to be relative to the same location.
	; Add their relative Y pos (different between actor and flame) to do just that.
	; mAbsBoxBound is the helper macro which does it.
	
	; For the first check to succeed:
	; FlameBoxBottom + FlameRelY > ActBoxTop + ActRelY
	;             |                       |
	;             v                       v
	; FlameBoxBottomAbs          > ActBoxTopAbs
	; The lower border of the flame must be below (higher value than) the top border of the actor.
	
	mActColiChkBorder sActTmpColiBoxU, sActTmpRelY, sPlDragonFlameColiBoxD, sExActOBJYRel,  .nextSlot, jp ; ACTORBOX UP / FLAMEBOX DOWN
	ld   c, a ; Not used
	mActColiChkBorder sPlDragonFlameColiBoxU, sExActOBJYRel, sActTmpColiBoxD, sActTmpRelY,  .nextSlot, jp ; ACTORBOX DOWN / FLAMEBOX UP
	mActColiChkBorder sActTmpColiBoxL, sActTmpRelX, sPlDragonFlameColiBoxR, sExActOBJXRel,  .nextSlot, jr ; ACTORBOX LEFT / FLAMEBOX RIGHT
	ld   c, a ; Not used
	mActColiChkBorder sPlDragonFlameColiBoxL, sExActOBJXRel, sActTmpColiBoxR, sActTmpRelX,  .nextSlot, jr ; ACTORBOX RIGHT / FLAMEBOX LEFT
	
	; If the four checks succeeded,
	; we can mark the actor as being interacted by the dragon flame
	jr   .found
.nextSlot:
	; Set slot ptr to next slot
	ld   a, [sActSlotPtr_High] ; HL = Ptr to (start of) actor slot
	ld   h, a
	ld   a, [sActSlotPtr_Low]
	ld   l, a
	ld   de, sActSet_End-sActSet		; DE = Slot size
	add  hl, de							; SlotPtr += $20
	jp   .loop
.found:
	; Set routine ID for crushing the enemy
	ld   b, $03							
	jp   ActS_SetRoutineId
	
; =============== PlActColi_Do ===============
; This subroutine checks for actor collision against the player.
; For more info on the bounding box checks, see ExActActColi_DragonHatFlame.
PlActColi_Do:
	xor  a							; This flag will have to be reconfirmed
	ld   [sPlActSolid], a
	
	ld   a, [sPlAction]			; Ignore actor collisions if dead
	cp   a, PL_ACT_DEAD
	ret  z
	
	; Determine the player collision box to use.
	; There are three possible configurations:
	; - Normal
	; - Small Wario
	; - Ducking
	ld   a, [sSmallWario]
	and  a						
	jr   nz, .plSmall
.plNorm:
	; Normal l/r
	ld   a, -$09			
	ld   [sPlColiBoxL], a
	ld   a, +$09
	ld   [sPlColiBoxR], a
	; Ducking reduces the top border to the same value used for Small Wario
	ld   a, [sPlAction]
	cp   a, PL_ACT_DUCK
	jr   z, .plDuck
	ld   a, [sPlSwimGround]
	cp   a, PL_SGM_DUCK
	jr   z, .plDuck
.plNormNoDuck:
	ld   a, -$1B
	jr   .plSetYBox
.plSmall:
	; Very slightly less than Normal Wario.
	; This is actually smaller enough that when standing still, some enemies like the hedgehog cannot damage you.
	ld   a, -$06
	ld   [sPlColiBoxL], a
	ld   a, +$06
	ld   [sPlColiBoxR], a
.plDuck:
	ld   a, -$0E
.plSetYBox:
	ld   [sPlColiBoxU], a
	ld   a, -$01
	ld   [sPlColiBoxD], a
	
	; Loop through all actor slots, to find a visible one which overlaps our collision box
	ld   hl, sAct				; HL = Ptr to first actor slot
PlActColi_LoopSearch:
	ld   a, h
	cp   a, HIGH(sAct_End)		; Have we reached the end of the actor slot area?
	ret  z						; If so, we didn't collide with anything
	;--
	ld   [sActSlotPtr_High], a	; Save the actor slot ptr we're on
	ld   a, l
	ld   [sActSlotPtr_Low], a
	
	ld   a, [hl]
	cp   a, $02					; Is the actor visible and active?
	jp   nz, PlActColi_NextSlot			; If not, it can't be used
	;--
	
	; Verify that the actor is tangible (collision type != $00)
	ld   de, sActSetColiType - sActSet ; Point to collision value ptr
	add  hl, de
	ldi  a, [hl]				; Read collision type
	and  a						; Is it intangible?
	jp   z, PlActColi_NextSlot	; If so, skip this slot
	ld   [sActTmpColiType], a
	
	; Copy everything needed for the bounding box check
	ldi  a, [hl]				; $06 - Bounding box top
	ld   [sActTmpColiBoxU], a	
	ldi  a, [hl]				; $07 - Bounding box bottom
	ld   [sActTmpColiBoxD], a	
	ldi  a, [hl]				; $08 - Bounding box left
	ld   [sActTmpColiBoxL], a
	ldi  a, [hl]				; $09 - Bounding box right
	ld   [sActTmpColiBoxR], a
	ldi  a, [hl]				; $0A - RelY / Origin
	ld   [sActTmpRelY], a		
	ld   a, [hl]				; $0B - RelX / Origin
	ld   [sActTmpRelX], a
	;--
	
	
	;--
	; Perform the bounding box check.
	
	; At the same time, we'll be detecting from which direction the actor is being interacted with,
	; by checking the distance between opposite border (same pairs as the bounding box check).
	; This one has multiple "rounds" of filtering.
	
	; Don't mark any until the collision check passed
	xor  a						
	ld   [sActTmpColiDir], a
	
	; Since the smallest distance is picked between distance values on a single axis,
	; initialize these to the lowest possible priority.
	; (see note on "distance values")
	ld   a, $FF
	ld   [sActColiBoxDistanceD], a
	ld   [sActColiBoxDistanceU], a
	ld   [sActColiBoxDistanceL], a
	ld   [sActColiBoxDistanceR], a
	
	; As usual this value is subtracted to all collision checks, so it might as well be $00
	ld   e, $B0
	
.chkUpDown:
	; ACTBOX UP / PLBOX DOWN
	mActColiChkBorder sActTmpColiBoxU, sActTmpRelY, sPlColiBoxD, sPlYRel,  PlActColi_NextSlot, jp
	ld   c, a	; C = Distance between borders (ActUp)
	
	; ACTBOX DOWN / PLBOX UP	
	mActColiChkBorder sPlColiBoxU, sPlYRel, sActTmpColiBoxD, sActTmpRelY,  PlActColi_NextSlot, jp 
	ld   d, a	; D = Distance between borders (ActDown)
	
	
	; Detect from which vertical direction the actor is being interacted with.
	; It's only required to set the values for the smallest direction (for the border we're closer to),
	; so we can ignore the larger one and leave it as $FF.
	; If the distance is equal, both are set.
	sub  a, c			; Is ActDown closer than ActUp?
	jr   c, .vertD		; If so, pick DOWN
	jr   z, .vertEq		; If equal, pick both
						; Otherwise, pick UP
.vertU:
	ld   a, c
	ld   [sActColiBoxDistanceU], a
	jr   .chkLeftRight
.vertEq:
	ld   a, c
	ld   [sActColiBoxDistanceU], a
.vertD:
	ld   a, d
	ld   [sActColiBoxDistanceD], a
	
.chkLeftRight:
	; ACTBOX LEFT / PLBOX RIGHT
	mActColiChkBorder sActTmpColiBoxL, sActTmpRelX, sPlColiBoxR, sPlXRel,  PlActColi_NextSlot, jr
	ld   c, a	; C = Distance between borders (ActLeft)
	
	; ACTBOX RIGHT / PLBOX LEFT
	mActColiChkBorder sPlColiBoxL, sPlXRel, sActTmpColiBoxR, sActTmpRelX,  PlActColi_NextSlot, jr
	ld   d, a	; D = Distance between borders (ActRight)
	
	; Same thing with horizontal distance 
	sub  a, c			; Is ActRight closer than ActLeft?
	jr   c, .horzR		; If so, set RIGHT
	jr   z, .horzEq		; If equal, set both
						; Otherwise, set LEFT
.horzL:
	ld   a, c
	ld   [sActColiBoxDistanceL], a
	jr   PlActColi_MakeColiDir
.horzEq:
	ld   a, c
	ld   [sActColiBoxDistanceL], a
.horzR:
	ld   a, d
	ld   [sActColiBoxDistanceR], a
	
PlActColi_MakeColiDir:
	; Generate the bitmask which marks from which direction(s) the actor is being interacted with.
	; It's initialized to all directions, and unneeded bits will be unmarked later.
	ld   hl, sActTmpColiDir
	ld   a, DIR_R|DIR_L|DIR_U|DIR_D
	ld   [hl], a
	
.chkDirHorz:
	ld   a, [sActColiBoxDistanceR]	; B = ActRight distance
	ld   b, a
	ld   a, [sActColiBoxDistanceL]	; C = ActLeft distance
	ld   c, a
	
	; Unmark the bit for the direction with a larger distance.
	; Done similarly to the sActColiBoxDistanceR setup code.
	
	cp   a, b				;  	
	jr   z, .chkDirVert		; ActLeft == ActRight? 
							; If so, don't unmark anything
	jr   c, .clrR			; ActLeft < ActRight?
							; Is so, jump (unmark the right border)
							; Otherwise, unmark the left one
.clrL:
	res  DIRB_L, [hl]
	jr   .chkDirVert		; (B already correct)
.clrR:
	res  DIRB_R, [hl]
	; For the final vertical/horizontal direction check later on, the
	; value in B should be set to the smallest distance value possible.
	; When going through .clrL it's already correct, but not here.
	ld   b, c
	
.chkDirVert:
	; Do the same for the vertical distance
	ld   a, [sActColiBoxDistanceD]	; D = ActDown distance
	ld   d, a
	ld   a, [sActColiBoxDistanceU]	; E = ActUp distance
	ld   e, a
	
	; Unmark bit for larget direction value
	cp   a, d
	jr   z, .chkAxis		; ActUp == ActDown?
							; If so, don't unmark anything
	jr   c, .clrD			; ActUp < ActDown?
							; Is so, jump (unmark the bottom border)
							; Otherwise, unmark the top one
.clrU:
	res  DIRB_U, [hl]		; actdown/plup
	jr   .chkAxis			; (D already correct)
.clrD:
	res  DIRB_D, [hl]		; pldown/actup
	ld   d, e				; D = Smallest vert distance value
.chkAxis:

	; Final direction check.
	; Compare the smallest border distance in the horz axis with the one in the vert axis.
	; Standard rules apply, so the smallest one will be picked and the other will have their bits unmarked.
	; With the same distance, both bits are preserved.
	
	ld   a, b					; B = Smallest horz distance
	cp   a, d					; D = Smallest vert distance
	jr   z, PlActColi_ChkHType	; HorzMax == VertMax 
								; If so, don't unmark anything
	jr   c, .clrVert			; HorzMax < VertMax?
								; If so, jump (unmark vertical)
								; Otherwise, unmark horizontal
.clrHorz:
	res  DIRB_R, [hl]
	res  DIRB_L, [hl]
	jr   PlActColi_ChkHType
.clrVert:
	res  DIRB_U, [hl]
	res  DIRB_D, [hl]
	jr   PlActColi_ChkHType
	
PlActColi_NextSlot:
	; Set slot ptr to next slot
	ld   a, [sActSlotPtr_High]		; HL = Ptr to (start of) actor slot
	ld   h, a
	ld   a, [sActSlotPtr_Low]
	ld   l, a
	ld   de, sActSet_End-sActSet	; DE = Slot size
	add  hl, de						; SlotPtr += SlotSize
	jp   PlActColi_LoopSearch
PlActColi_ChkHType:
	; Determine how to handle the collision type.
	; This is either a type ID (for special collisions), or a bitmask with 4 pairs of collision types, one for each direction (for normal enemies).
	; The former is never higher than $33, and the latter never uses the blank collision pair $00.
	;
	; So we can detect if it's the bitmask by checking if bits 6-7 are 0.
	; If they are, this is definitely a type ID.
	ld   a, [sActTmpColiType]
	and  a, $C0						; Is this a collision bitmask?
	jp   z, PlActColiId_CheckType	; If not, jump
	
	; Actors using the collision bitmask can always be (marked as) defeated with invincibility
	ld   a, [sPlInvincibleTimer]
	and  a							; Are we invincibile?
	jr   z, PlActColiMask_ClrByDir	; If not, skip
	
; =============== ActS_SetCrushRoutineId ===============
; Falls into ActS_SetRoutineId with the routine ID set to $03.
ActS_SetCrushRoutineId:
	ld   b, ACTRTN_03
	
; =============== ActS_SetRoutineId ===============
; Sets the specified routine ID to the currently saved actor slot.
; IN
; - sActSlotPtr: Ptr to actor slot
; - B: Routine ID
ActS_SetRoutineId:
	; Point to the routine ID
	ld   a, [sActSlotPtr_High]			; HL = Start of slot
	ld   h, a
	ld   a, [sActSlotPtr_Low]
	ld   l, a
	ld   de, sActSetRoutineId-sActSet	; Point to byte $11
	add  hl, de
	
	; If a special routine is currently executing, don't set a new one.
	; We must be on routine $00, which is the default one where all main actor code runs.
	ld   a, [hl]						; Read the value
	and  a, $0F							; Remove invalid part
	ret  nz								; If special routine, return
	;--
	ld   [hl], b						; Otherwise, update the routine ID
	ld   a, b							; Save the bookkeeping (?)
	ld   [sAct_Unused_LastSetRoutineId], a
	ret
	
	
; The collision byte can be split in four pairs of bits,
; each of which marks a collision type for a single direction.

; Now that we know from which direction the actor is being interacted with, 
; we can pick the appropriate collision type and set the direction the actor should be bumped to.
; (the latter being set in the upper nybble of the Routine ID... yeah).
	
; Brief overview of what will be done, now that we know the interaction direction:
; - Remove the bits for the directions we aren't interacting the actor with
; - Split the bit pairs in four registers, with blank pairs being set to $FF
; - Pick the register with the smallest collision type (and the direction it's meant for)
; - Save the bump direction to the higher nybble of the routine ID
;   and also set another direction for vertical interactions, to make sure the
;   actor is also bumped horizontally.

PlActColiMask_ClrByDir:
	; Ignore/clear the bits for the directions the actor isn't being collided with.
	; As a result, most of the time only one bit pair will remain set.
	ld   a, [sActTmpColiDir]
	ld   b, a					;
	bit  DIRB_D, b				; Is actor being interacted from below?
	jr   nz, .chkU				; If so, jump
	ld   a, [sActTmpColiType]	; Otherwise, unmark the bits for this collision option
	and  a, $FF^ACTCOLIM_D		; Remove bits 6-7
	ld   [sActTmpColiType], a
.chkU:
	bit  DIRB_U, b
	jr   nz, .chkL
	ld   a, [sActTmpColiType]
	and  a, $FF^ACTCOLIM_U		; Remove bits 4-5
	ld   [sActTmpColiType], a
.chkL:
	bit  DIRB_L, b
	jr   nz, .chkR
	ld   a, [sActTmpColiType]
	and  a, $FF^ACTCOLIM_L		; Remove bits 2-3
	ld   [sActTmpColiType], a
.chkR:
	bit  DIRB_R, b
	jr   nz, PlActColiMask_SetColiRegs
	ld   a, [sActTmpColiType]
	and  a, $FF^ACTCOLIM_R		; Remove bits 0-1
	ld   [sActTmpColiType], a
	
PlActColiMask_SetColiRegs:
	; Split the pairs of bits into the different registers.
	; Each of these registers will have a value corresponding to the ACTCOLI_* enum.
	; For pairs with no bits set, the respective register will be set to $FF,
	; which causes it to be ignored.
	; NOTE: It's important that actors that go through this never use ACTCOLI_NONE.
	;		This collision type isn't handled further down below in PlActColiMask_CheckType,
	;		which causes it to fall back to Type 03 (ACTCOLI_DAMAGE)!
	;       As a result, the only bit pairs set to $00 will be the ones unmarked
	;		in the previous check.
	ld   a, [sActTmpColiType]	; B = sActTmpColiType
	
	; Check the pairs in order
.chkR:
	; E = (RIGHT) Bit result 0/1
	ld   b, a					; A = B & %11
	and  a, $03					; Bits 0 or 1 set?
	jr   nz, .saveR				; If so, jump
	ld   a, $FF					; Otherwise, set default
.saveR:
	ld   e, a					; Save bit result
	
.chkL:
	; D = (LEFT) Bit result 2/3
	ld   a, b					; A = (B >> 2) & %11
	srl  a
	srl  a
	and  a, $03					; Bits 2 or 3 set?
	jr   nz, .saveL			
	ld   a, $FF					
.saveL:
	ld   d, a					
	
.chkU:
	; C = (UP) Bit result 4/5
	ld   a, b					; A = (B >> 4) & %11
	swap a
	and  a, $03					; Bits 4 or 5 set?
	jr   nz, .saveU
	ld   a, $FF
.saveU:
	ld   c, a
	
.chkD:
	; B = (DOWN) Bit result 6/7
	ld   a, b
	rlca						; A = (B >> 6) & %11
	rlca						
	and  a, $03					; Bits 6 or 7 set?
	jr   nz, .saveD
	ld   a, $FF
.saveD:
	ld   b, a
	
PlActColiMask_GetLowerReg:
	; Of the registers with collision types we just set, pick the one with the smallest value.
	; Since the pair positions have a direction assigned to them, we can also determine the
	; actor bump direction along with it.
	; Since blanked directions are set to $FF, they will essentially be ignored.
	; IN
	; - B: Down collision type
	; - C: Up collision type
	; - D: Left collision type
	; - E: Right collision type
	; OUT
	; - C: Smallest collision type
	; - B: Actor interaction direction value picked (the one for C)
.chkR:
	ld   a, e			; A = Right
	cp   a, d			; Right > Left?
	jr   nc, .chkL	
	cp   a, b			; Right > Down?
	jr   nc, .chkD	
	cp   a, c			; Right > Up?
	jr   nc, .chkU
	; If not, Right is the smallest value, so it gets picked
.setR:
	ld   c, e			; Set collision type
	ld   b, ACTINT_R	; Bump actor right
	jr   PlActColiMask_SetColiHorz
.chkL:
	ld   a, d
	cp   a, b			; Left > Down?
	jr   nc, .chkD
	cp   a, c			; Left > Up?
	jr   nc, .chkU
.setL:
	ld   c, d
	ld   b, ACTINT_L	; Bump actor left
	jr   PlActColiMask_SetColiHorz
.chkD:
	ld   a, b
	cp   a, c			; Down > Up?
	jr   nc, .chkU
.setD:
	ld   c, b
	ld   b, ACTINT_D	; Bump actor down
	jr   PlActColiMask_SetColiVert
.chkU:
.setU:
	ld   b, ACTINT_U	; Bump actor upwards
	
	
PlActColiMask_SetColiVert:
	; Save the bumped direction to the upper nybble of the routine ID.
	ld   a, [sActSlotPtr_High]			; HL = Ptr to slot
	ld   h, a
	ld   a, [sActSlotPtr_Low]
	ld   l, a
	ld   de, sActSetRoutineId-sActSet	; Point to Routine ID
	add  hl, de
	ld   a, [hl]						; Read it
	and  a, $0F							; Is it in a special routine ID? (!= $00)
	ret  nz								; If so, ignore this
	; Set the interaction direction
	ld   [hl], b						; Save in upper nybble of Routine ID	
	ld   a, b
	ld   [sActInteractDir], a			; Save as standalone copy
	ld   a, c							
	ld   [sAct_Unused_InteractDirType], a	; Also save the collision type for this direction (not used -- register is used directly)
	
	; And this is why there's a difference between vertical and horizontal handlers.
	; If we only go by the actor interaction direction (which is almost always just a single one),
	; we'd have no way of bumping the actor horizontally when interacting with it from above.
	; Of course this isn't a problem when the interaction direction is already horizontal.
	;
	; Since the aforemented direction points to a vertical one here, we have to use the raw L/R distance values.
	; Usual rules apply -- the smallest distance is picked,
	; and the actor is set to be bumped *from* the picked direction.
	;
	; This makes it possible to bump the actor horizontally, for example, when jumping on it.
	ld   a, [sActColiBoxDistanceL]	; D = ActLeft
	ld   d, a
	ld   a, [sActColiBoxDistanceR]	; A = ActRight
	cp   a, d						; ActRight < ActLeft?
	jr   c, .setR					; If so, set the right interaction		
.setL:	
	set  ACTINTB_L, [hl]
	jr   PlActColiMask_CheckType
.setR:
	set  ACTINTB_R, [hl]
	jr   PlActColiMask_CheckType
	
PlActColiMask_SetColiHorz:
	; Do similar for the horizontal collision.
	ld   a, [sActSlotPtr_High]			; HL = Ptr to slot
	ld   h, a
	ld   a, [sActSlotPtr_Low]
	ld   l, a
	ld   de, sActSetRoutineId-sActSet	; Point to Routine ID
	add  hl, de
	ld   a, [hl]						; Read it
	and  a, $0F							; Is it in a special routine ID? (!= $00)
	ret  nz								; If so, ignore this
	
	; Set the direction the actor will be bumped to.
	ld   [hl], b
	ld   a, b
	ld   [sActInteractDir], a
	ld   a, c
	ld   [sAct_Unused_InteractDirType], a


; Handle the player-to-actor collision type for the picked direction.
PlActColiMask_CheckType:
	ld   a, c							; A = Collision type ($01-$03)
	dec  a									; Type 01?
	jr   z, PlActColiMask_CheckType_Norm	; If so, jump
	dec  a									; Type 02?
	jp   z, PlActColiMask_CheckType_Bump	; If so, jump
	jp   PlActColiMask_CheckType_Damage		; Otherwise, Type 03
	
; =============== Actor Collision Type 01 ===============
; Normal collision for pickable (sides of) actors.
PlActColiMask_CheckType_Norm:
	; Mark collision bit
	ld   a, [sActTmpColiDir]		
	set  ACTCOLIDB_NORM, a
	ld   [sActTmpColiDir], a
	
	; Get the dashing actions out of the way
	ld   a, [sPlGroundDashTimer]
	and  a							; Dashing against it?
	jp   nz, PlActColi_GroundDash	; If so, jump
	ld   a, [sPlJetDashTimer]
	and  a							; Jet dashing against it?
	jp   nz, PlActColi_JetDash		; If so, jump
	
	;--
	; From below?
	ld   a, [sActInteractDir]
	bit  ACTINTB_D, a						; Is the actor being interacted from below?
	jr   z, .chkAbove						; If not, jump
	ld   b, ACTRTN_04						; $04 - Below Interact
	jr   PlActColiMask_CheckType_SetRoutineId
	;--
.chkAbove:
	;--
	; From above?
	
	; Curiously, this interaction is not applicable when swimming.
	ld   a, [sPlAction]
	cp   a, PL_ACT_SWIM						; Are we swimming?
	jr   z, .chkBump						; If so, ignore the above interaction
	
	ld   a, [sActInteractDir]
	bit  ACTINTB_U, a						; Is the actor being interacted from above?
	jr   nz, .fromAbove						; If so, jump
	;--
.chkBump:
	; If we're invulnerable (post hit) we just... start the whole thing again for the next actor.
	ld   a, [sPlPostHitInvulnTimer]
	and  a									; Are we invulnerable (post-hit)?
	jp   nz, PlActColi_NextSlot				; If so, ignore this collision
	
	; Determine if we should switch to the bump action, which stops you momentarily.
	ld   a, [sPlAction]
	cp   a, PL_ACT_DUCK						; Are we standing or walking?			
	jr   nc, .skipBump						; If not, skip it
	ld   a, [sSmallWario]
	and  a									; Are we Small Wario
	jr   nz, .skipBump						; If so, skip it
	
	; [POI] Holding B ignores the bump action when standing or walking.
	;		This allows you to walk against enemies without being stopped by the bump action.
	ldh  a, [hJoyKeys]
	bit  KEYB_B, a
	jr   nz, .skipBump
	
	call Pl_SwitchToActBumpAction
.skipBump:
	; Play the bump SFX if we aren't playing it already
	ld   a, [sSFX1]
	cp   a, SFX1_01		; Playing it already?
	jr   z, .setRoutine01	; If so, jump
	ld   a, SFX1_01		; Otherwise, set the SFX
	ld   [sSFX1Set], a
.setRoutine01:
	; Set the "stun" routine for the actor
	ld   b, $01
	jr   PlActColiMask_CheckType_SetRoutineId
	
.fromAbove:

	;
	; When jumping on an actor, setup a new normal jump by switching to the "Actor Jump" action.
	;
	
IF IMPROVE == 0
	; Stop any existing "moving jump"
	xor  a
	ld   [sPlMovingJump], a
ENDC
	
	; If holding A start a full normal jump, otherwise start a small hop.
	; This is done by choosing a different initial jump Y table index.
	ld   a, $10							; A = JumpY index for small hops
	ld   [sPlJumpYPathIndex], a
	ldh  a, [hJoyKeys]
	bit  KEYB_A, a						; Holding A?
	jr   z, .switchToJump				; If not, jump
	xor  a								; A = JumpY index for full jump
	ld   [sPlJumpYPathIndex], a
.switchToJump:
	ld   a, PL_ACT_JUMPONACT
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	ld   a, SFX1_02
	ld   [sSFX1Set], a
	; When doing a ground pound, set actor routine $03 to crush it.
	; Otherwise, set routine $02 to stun it.
	ld   b, ACTRTN_02
	ld   a, [sPlLstId]
	cp   a, OBJ_WARIO_GROUNDPOUND				; Are we ground pounding?
	jr   nz, PlActColiMask_CheckType_SetRoutineId	; If not, jump
	jp   ActS_SetCrushRoutineId
	
; =============== PlActColiMask_CheckType_SetRoutineId ===============
; Sets the subroutine ID of the current actor to the specified value,
; but only if the actor isn't in a special subroutine.
; IN
; - B: Subroutine ID
PlActColiMask_CheckType_SetRoutineId:
	ld   a, [sActSlotPtr_High]		; HL = Actor slot ptr
	ld   h, a
	ld   a, [sActSlotPtr_Low]
	ld   l, a
	ld   de, sActSetRoutineId-sActSet	; Point to routine ID
	add  hl, de
	;--
	; Particuarly useless check since we've done it before
	ld   a, [hl]					
	and  a, $0F						; Is the actor in a special subroutine (!= $00)?
	ret  nz							; If so, return
	;--
	ld   a, [hl]					
	add  b							; Add subroutine ID to avoid modifying upper nybble
	ld   [hl], a					; (lower nybble will have to be $0 anyway)
	ld   [sAct_Unused_LastSetRoutineId], a
	ret
PlActColi_GroundDash:
	; Freeze the player for a bit after hitting an actor during a dash
	ld   a, OBJ_WARIO_DASHENEMY
	ld   [sPlLstId], a
	call Pl_SwitchToActBumpAction2
	; But not if it's a jet dash
PlActColi_JetDash:
	; If we were underwater when we started the dash, return to that
	ld   a, [sPlWaterAction]
	and  a
	call nz, Pl_SwitchToSwim
	; Reset vars for dash hit
	xor  a
	ld   [sPlWaterAction], a
	ld   [sPlSwimGround], a
	ld   [sPlGroundDashTimer], a
	ld   [sPlJetDashTimer], a
	ld   a, SFX1_16
	ld   [sSFX1Set], a
	ld   b, ACTRTN_05
	jr   PlActColiMask_CheckType_SetRoutineId
	
; =============== Actor Collision Type 02 ===============
; Triggers an hard bump in contact (ie: coin locks)
PlActColiMask_CheckType_Bump:
	; Standard post invulnerability ignore
	ld   a, [sPlPostHitInvulnTimer]
	and  a
	jp   nz, PlActColi_NextSlot
	; Mark collision bit
	ld   a, [sActTmpColiDir]
	set  ACTCOLIDB_BUMP, a
	ld   [sActTmpColiDir], a
	;--
	; Set actor post-bump routine (usually pauses it, then makes it turn around)
	ld   b, ACTRTN_07
	call PlActColiMask_CheckType_SetRoutineId
	xor  a
	ld   [sPlGroundDashTimer], a
	ld   [sPlJetDashTimer], a
	ld   [sPlSwimGround], a
	ld   [sPlSuperJump], a
	; Set hard bump
	call Pl_SwitchToHardBump
	; [TCRF] Was possibly an unique SFX
	ld   a, SFX1_15
	ld   [sSFX1Set], a
	ret
; =============== Actor Collision Type 03 ===============
; Triggers player damage (or death).
PlActColiMask_CheckType_Damage:
	; Standard post invulnerability ignore
	ld   a, [sPlPostHitInvulnTimer]
	and  a
	jp   nz, PlActColi_NextSlot
	; Mark collision bit
	ld   a, [sActTmpColiDir]
	set  ACTCOLIDB_DAMAGE, a
	ld   [sActTmpColiDir], a
	;--
	xor  a
	ld   [sPlGroundDashTimer], a
	ld   [sPlJetDashTimer], a
	ld   [sPlFreezeTimer], a
	ld   [sPlSuperJump], a
	; Set actor post-bump routine (usually pauses it, then makes it turn around)
	ld   b, ACTRTN_07
	call PlActColiMask_CheckType_SetRoutineId
	; Damage the player
	ld   a, [sSmallWario]
	and  a					; Are we Small Wario?
	jr   nz, .kill			; If so, kill the player
.damage:
	ld   a, PL_HT_ACTHURT	; Otherwise, register damage from an actor
	ld   [sPlHurtType], a	
	; [POI] Does not use "xor a" in this suspicious location.
	;		Did taking damage work like SML2 originally?
	ld   a, PL_POW_NONE		; Switch to Small Wario
	ld   [sPlPowerSet], a
	call Game_InitHatSwitch
	ret
.kill:
	call Pl_StartDeathAnim
	ret
	
; =============== PlActColiId_CheckType ===============
; Checks for player-to-actor collision when a collision type ID is used.
; This is for special collision types.
PlActColiId_CheckType:
	ld   a, [sActTmpColiType]
	; Types $00-$0F reserved for treasures
	; [POI] Even though 16 IDs are reserved (enough for the 15 treasures), they don't actually matter.
	; The treasure you get depends on the currently loaded level, not on the collision ID.
	cp   a, $10					
	jp   c, PlActColiId_Treasure
	cp   a, $20					; Types $10-$1F?
	jr   c, PlActColiId_TypesTopSolid
	cp   a, $30					; Types $20-$2F?
	jp   c, PlActColiId_TypesItem
	
	; If not, treat (sActTmpColiType-$2F) as a powerup state.
	; This results in:
	; $30 -> $01 Garlic
	; $31 -> $02 Bull
	; $32 -> $03 Jet
	; $33 -> $04 Dragon
	; Everything after is ignored.
	
	sub  a, ACTCOLI_POW-1			; Offset by 1 since there's no powerdown
	
	cp   a, PL_POW_GARLIC			; Garlic powerup?
	jr   nz, PlActColiId_Powerup	; If not, jump
PlActColiId_GarlicPowerup:
	; Garlic Powerup acts as Bull if we aren't Small Wario
	ld   a, [sSmallWario]
	and  a							; Are we Small Wario?
	jr   nz, PlActColiId_Powerup	; If so, skip (set Garlic powerup as normal)
	ld   a, PL_POW_BULL				; Otherwise, treat as Bull powerup.
PlActColiId_Powerup:
	; [POI] Sanity check.
	; If the would-be powerup is invalid, don't do the hat switch anim
	; and pretend the collision never took place.
	; (the game would instantly crash if it did)
	ld   [sPlPowerSet], a
	cp   a, PL_POW_DRAGON+1			; >= $05?
	jp   nc, PlActColi_NextSlot		; If so, ignore this
	
	; Don't perform the anim if we're already in that powerup state
	ld   a, [sPlPowerSet]		; B = sPlPowerSet
	ld   b, a					
	ld   a, [sPlPower]			; A = sPlPower
	cp   a, b						; sPlPowerSet == sPlPower?
	jr   nz, .doHatSwitch			; If not, perform the hat switch
.noSwitch:
	call Game_Add10HeartsStub	; Otherwise, treat as heart
	jr   PlActColiId_DespawnItem
.doHatSwitch:
	call Game_InitHatSwitch
; =============== PlActColiId_DespawnItem ===============
; Permanently removes from the level the currently processed actor.
; This is strictly used to delete an item/powerup actor from the level layout.
PlActColiId_DespawnItem:
	ld   a, [sActSlotPtr_High]	; HL = Actor slot
	ld   h, a
	ld   a, [sActSlotPtr_Low]
	ld   l, a
	
	; Mark slot as free
	ld   [hl], $00				
	
	; Point to level layout ptr
	ld   de, sActSetLevelLayoutPtr-sActSet	
	add  hl, de
	
	; Remove actor indicator from level layout data
	ldi  a, [hl]	; HL = Level layout ptr
	ld   h, [hl]
	ld   l, a
	res  7, [hl]	; Clear actor flag
	ret
; =============== PlActColiId_TypesTopSolid ===============
; These types of actor collisions set the sPlActSolid flag,
; and as such can be stood on.
PlActColiId_TypesTopSolid:
	; Handle the top-solid flag
	ld   a, [sActTmpColiDir]
	bit  DIRB_U, a						; Interacting with it from above? (landing on it)
	jp   nz, PlActColi_SetPlActSolid	; If so, jump
	
	; Check for detail
	ld   a, [sActTmpColiType]
	sub  a, $10							
	jp   z, PlActColi_NextSlot			; Type $10 has nothing special
	dec  a								; Type $11?
	jr   z, PlActColiId_Unused_Type11
	dec  a								; Type $12?
	jr   z, PlActColiId_TreasureLid
	dec  a								; Type $13?
	jr   z, PlActColiId_BigBlock
	dec  a								; Type $14?
	jr   z, PlActColiId_Lock
	jp   PlActColi_NextSlot ; We never get here

; =============== PlActColiId_Unused_Type11 ===============
; [TCRF] Unused actor collision type.
; Interacting with this damages the player unless staying on top of it, but it can't be defeated.
; Similar to the collision type used by "Thwomps" (Act_Pouncer), except it doesn't instakill the player
; and invincibility can be used to ignore the damage.
PlActColiId_Unused_Type11: 
	ld   a, [sPlPostHitInvulnTimer]
	and  a									; Are we invulnerable?
	jp   nz, PlActColi_NextSlot				; If so, ignore this actor
	jp   PlActColiMask_CheckType_Damage
	
; =============== PlActColiId_TreasureLid ===============
; Used for the lid of treasure boxes.
PlActColiId_TreasureLid:
	; Mark collision bit
	ld   a, [sActTmpColiDir]
	set  ACTCOLIDB_NORM, a
	ld   [sActTmpColiDir], a
	
	; Same dash behaviour as pickable actors PlActColiMask_CheckType_Norm
	; This is because a dash attack is what opens the lid
	ld   a, [sPlGroundDashTimer]
	and  a
	jp   nz, PlActColi_GroundDash
	ld   a, [sPlJetDashTimer]
	and  a
	jp   nz, PlActColi_JetDash
	
	ld   b, ACTRTN_01
	jp   PlActColiMask_CheckType_SetRoutineId
	
; =============== PlActColiId_BigBlock ===============
; Used for big item boxes and big ! blocks.
; Top solid collision type that bumps the player when interacted on the LEFT or RIGHT side.
; When interacted from below, the block is triggered (set to stun routine)
; and the player is set to fall instead.
PlActColiId_BigBlock:
	ld   a, [sActTmpColiDir]
	bit  DIRB_D, a					; Actor interacted on the bottom?
	jr   z, PlActColiId_HardBump	; If not, jump
	ld   b, ACTRTN_04				; Otherwise, stun the actor
	call PlActColiMask_CheckType_SetRoutineId
	jp   Pl_SwitchToJumpFall2
; =============== PlActColiId_HardBump ===============
; This collision type makes the player hard bump in the same horizontal direction
; the actor is being interacted with.
; ie: player is bumped right if the actor is interacted from the right.
PlActColiId_HardBump:
	; Set hard bump for actor
	ld   b, ACTRTN_07
	call PlActColiMask_CheckType_SetRoutineId
	; Set special collision bit
	ld   a, [sActTmpColiDir]
	set  ACTCOLIDB_BUMP, a
	ld   [sActTmpColiDir], a
	; End any dashes
	xor  a
	ld   [sPlGroundDashTimer], a
	ld   [sPlJetDashTimer], a
	ld   [sPlSwimGround], a
	; Depending on which direction we're interacting with the actor,
	; bump the player in the same direction.
	ld   a, [sActTmpColiDir]
	bit  DIRB_R, a				; Is the actor being interacted on the right?
	jr   nz, .fromRight			; If so, bump the player from the right
.fromLeft:
	ld   a, ACTINT_L			; Otherwise, bump the player from the left
	ld   [sActInteractDir], a
	jr   .end
.fromRight:
	ld   a, ACTINT_R			
	ld   [sActInteractDir], a
.end:
	call Pl_SwitchToHardBump
	
	ld   a, SFX1_15				; Set hard bump SFX
	ld   [sSFX1Set], a
	ret
; =============== PlActColiId_Lock ===============
; Used for coin locks and key locks.
; Basically identical to PlActColiId_HardBump, however it ignores the downwards check to save time.
; As a result you always place locks on solid ground.
PlActColiId_Lock:
	jr   PlActColiId_HardBump
	
; =============== PlActColi_SetPlActSolid ===============
; This subroutine sets the "solid actor" flag.
PlActColi_SetPlActSolid:
	; Snap the player on the top border of the actor's bounding box.
	; This distance will never be negative (ie: player is above) when we get here.
	; Done to make the landing position consistent and to give maximum
	; priority to the top border collision (since starting on the next frame, it will be $00)
	ld   a, [sActColiBoxDistanceU]		; Since we have the exact distance
	ld   b, a
	call Pl_MoveUp						; Move up by that
	
	; Enable solid ground flag
	ld   a, $01
	ld   [sPlActSolid], a
	
	; Set routine for standing on actor
	ld   b, ACTRTN_06
	call ActS_SetRoutineId
	jp   PlActColi_NextSlot
	
; =============== PlActColiId_TypesItem ===============
; These types of actor collisions are collectible items,
; generally found inside item boxes.
PlActColiId_TypesItem:
	; Items are gone as soon as collected
	call PlActColiId_DespawnItem
	
	; Check for detail
	ld   a, [sActTmpColiType]
	sub  a, $20						; Type $20?
	jr   z, PlActColiId_Key
	dec  a							; Type $21?
	jp   z, Game_Add10HeartsStub
	dec  a							; Type $22?
	jp   z, PlActColiId_Star
	dec  a							; Type $23?
	jr   z, PlActColiId_Coin
	dec  a							; Type $24?
	jr   z, Game_Add10Coins
	dec  a							; Type $25?
	jr   z, Game_Add100Coins
	dec  a							; Type $26?
	jr   z, PlActColiId_BigHeart
	ret ; We never get here
	
; =============== PlActColiId_Coin ===============	
PlActColiId_Coin:
	call Game_AddCoin
	ret
	
; =============== Game_Add10Coins ===============
; This subroutine gives the player 10 coins, and redraws the status bar.
Game_Add10Coins:
	;--
	ld   a, [sLevelCoins_Low]	; sLevelCoins += 10
	add  $0A
	daa							; bcd account
	ld   [sLevelCoins_Low], a
	ld   a, [sLevelCoins_High]
	adc  a, $00					; account high byte
	ld   [sLevelCoins_High], a
	;--
	; Enforce a cap of 999 coins, which triggers if we go past that number
	; [TCRF] Impossible to reach the cap without cheating
	cp   a, $0A					; Did we go past 999 coins?
	jr   nz, .coinOk			; If not, don't cap it
	ld   a, $99
	ld   [sLevelCoins_Low], a
	ld   a, $09
	ld   [sLevelCoins_High], a
.coinOk:
	call StatusBar_DrawLevelCoins
	ld   a, SFX1_26
	ld   [sSFX1Set], a
	ret
	
; =============== Game_Add100Coins ===============
; This subroutine gives the player 100 coins, and redraws the status bar.
Game_Add100Coins:
	ld   a, [sLevelCoins_High]	; sLevelCoins += 100
	inc  a
	ld   [sLevelCoins_High], a
	;--
	; Enforce a cap of 999 coins, which triggers if we go past that number
	; [TCRF] Impossible to reach the cap without cheating
	cp   a, $0A				; Did we go past 999 coins?
	jr   nz, .coinOk		; If not, don't cap it
	ld   a, $99
	ld   [sLevelCoins_Low], a
	ld   a, $09
	ld   [sLevelCoins_High], a
.coinOk:
	call StatusBar_DrawLevelCoins
	ld   a, SFX1_24
	ld   [sSFX1Set], a
	ret
; =============== PlActColiId_Key ===============
; This is how the game handles picking up and throwing a key.
; When picking up a key, it deletes the existing actor and then immediately
; spawns a new one in the held state.
PlActColiId_Key:
	call SubCall_ActS_SpawnKeyHeld
	ret
; =============== PlActColiId_BigHeart ===============
PlActColiId_BigHeart:
	call Game_Add3UP
	ret
Game_Add10HeartsStub:
	call Game_Add10Hearts
	ret
; =============== PlActColiId_Star ===============
; Handle collision with an invincibility star.
PlActColiId_Star:
	ld   a, $64						
	ld   [sPlInvincibleTimer], a
	ld   a, BGM_INVINCIBILE					
	ld   [sBGMSet], a
	ret
; =============== PlActColiId_Treasure ===============
; Handles collision with a treasure item.
PlActColiId_Treasure:
	ld   a, [sActSlotPtr_High]			; Save slot info for later
	ld   [sTreasureActSlotPtr_High], a
	ld   a, [sActSlotPtr_Low]
	ld   [sTreasureActSlotPtr_Low], a
	ld   b, ACTRTN_SPEC_09				; Set special collection routine					
	call ActS_SetRoutineId
	ld   a, [sActTmpColiType]
	ld   [sTreasureId], a
; =============== Pl_SwitchToTreasureGet ===============
; Switches the player to the action used when collecting an hidden treasure.
Pl_SwitchToTreasureGet:
	xor  a							; Cancel every other sub-action
	ld   [sExActCount], a
	ld   [sPlDragonHatActive], a
	ld   [sPlJetDashTimer], a
	ld   a, PL_ACT_TREASUREGET		; Set action
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	ld   a, $1B						; Switch to fall state, if in the air
	ld   [sPlJumpYPathIndex], a
	; [TCRF] Overridden by another SFX
	ld   a, SFX1_04				; Play SFX
	ld   [sSFX1Set], a
	ret
; =============== ExActS_ExecuteAllAndWriteOBJLst ===============
; This subroutine executes the Extra Actor code for all slots and draws their sprite mappings.
; Used during main gameplay.
ExActS_ExecuteAllAndWriteOBJLst:
	ld   a, [sExActCount]
	and  a					; Are there any ExAct?
	ret  z					; If not, we have nothing to do here
	
	; Search along the ExAct area for OBJLst to draw.
	ld   [sExActLeft], a	
	ld   hl, sExAct			; HL = ExAct slot
.loop:
	; sExActCount does not include empty slots in the total, so we won't decrement it.
	ld   a, [hl]
	and  a					; Is the slot empty (id $00)?
	jr   z, .emptySlot		; If so, skip it
	;--
	push hl
	call ExActS_CopyFromSet
	
	call ExActS_Execute				; Execute code
	call HomeCall_WriteExActOBJLst	; Write OBJLst
	; Save back/update the calculated relative coords we got from WriteExActOBJLst
	ld   a, [sExActOBJYRel]
	ld   [sExActOBJFixY], a
	ld   a, [sExActOBJXRel]
	ld   [sExActOBJFixX], a
	
	; If we're on the dragon hat flame and it's set to cause damage,
	; handle its ExActor-to-Actor collision
	ld   a, [sPlDragonFlameDamage]
	and  a
	call nz, HomeCall_ExActActColi_DragonHatFlame
	xor  a
	ld   [sPlDragonFlameDamage], a
	pop  hl
	;--
	; Saving the ExAct data also sets HL to the next slot
	call ExActS_CopyToSet	; Save data, HL += $10
	
	ld   a, [sExActLeft]	; sExActLeft--
	dec  a
	ld   [sExActLeft], a	; Are there any actors left?
	ret  z					; If not, return
	jr   .loop
.emptySlot:
	; Skip to the next slot
	ld   a, l
	add  $10
	ld   l, a
	jr   .loop
	
; =============== ExActS_CopyFromSet ===============	
; Copies ExAct data from the 'Main' area to the 'Set' area (currently processed).
; IN
; - HL: Ptr to ExAct slot in 'Main' area
ExActS_CopyFromSet:
	ld   de, sExActSet	; DE = Ptr to destination
	ld   b, $10			; B = Bytes to copy (ExAct size)
.loop:
	ldi  a, [hl]		; Read byte from 'Main'
	ld   [de], a		; Copy to 'Set'
	inc  de
	dec  b
	jr   nz, .loop
	ret
; =============== ExActS_CopyToSet ===============	
; Copies ExAct data from the 'Set' area to the 'Main' area.
; IN
; - HL: Ptr to ExAct slot in 'Main' area
ExActS_CopyToSet:
	ld   de, sExActSet	; DE = Ptr to source
	ld   b, $10			; B = Bytes to copy (ExAct size)
.loop:
	ld   a, [de]		; Read byte from 'Set'
	ldi  [hl], a		; Copy to main
	inc  de
	dec  b
	jr   nz, .loop
	ret
	
; =============== ExActS_Execute ===============	
; Executes the code for the currently processed ExAct.
ExActS_Execute:
	ld   a, [sExActSet]		; Get the ExAct ID
	rst  $28				; Jump
	dw ExAct_None ; Blank slot
	dw ExAct_DeadHat
	dw ExAct_ItemBoxHit
	dw ExAct_JetHatFlame
	dw ExAct_DragonHatFlame
	dw ExAct_BlockSmash
	dw ExAct_WaterSplash
	dw ExAct_WaterBubble
	dw ExAct_SaveSel_NewHat
	dw ExAct_SaveSel_OldHat
	dw ExAct_TrRoom_Arrow
	dw ExAct_SaveSel_Cross
	dw ExAct_TreasureGet
	dw ExAct_TrRoom_Sparkle
	dw ExAct_Switch0Type0Hit
	dw ExAct_Switch0Type1Hit
	dw ExAct_Unused_Switch1Type0Hit ;X
	dw ExAct_BounceBlockHit
	dw ExAct_DeadCoinC
	dw ExAct_DeadCoinL
	dw ExAct_DeadCoinR
	dw ExAct_1UPMarker
	dw ExAct_TreasureEnding
	dw ExAct_Moneybag
	dw ExAct_MoneybagStack
	dw ExAct_SaveSel_Smoke
	dw ExAct_TreasureLost
	
; =============== ExAct_None ===============
; ID: $00
; [TCRF] Not used; not meant to be used.
ExAct_None:
	ret
	
; =============== ExAct_DeadHat ===============
; ID: $01
; Standalone hat shown when the player is instakilled while big.
; This is to allow the hat movement to be delayed.
ExAct_DeadHat:
	ld   a, [sExActRoutineId]
	dec  a
	jr   z, .wait
	dec  a
	jr   z, .moveDown
.moveUp:
	; Set the hat position to be in sync with the player's.
	; It will be set relative to the player pos:
	; - $16px up
	; - $00px right
	ld   bc, $1600
	call ExActS_SetRelUpRightPos
	
	; Until the player starts falling down in the death anim,
	; keep the previous relative pos.
	ld   a, [sPlJumpYPathIndex]
	cp   a, Pl_JumpYPath.down-Pl_JumpYPath
	ret  c
	; After that, wait for 6 frames
	ld   a, $01
	ld   [sExActRoutineId], a
	ld   a, $06
	ld   [sExActTimer], a
	ret
.wait:
	; Wait for the timer to elapse, keeping the hat in the same position
	; while the player falls down
	ld   a, [sExActTimer]	; sExActTimer--;
	dec  a
	ld   [sExActTimer], a
	ret  nz
	;--
	; For mode2, sExActTimer is used as jump Y table index
	ld   a, $02
	ld   [sExActRoutineId], a
	ld   a, Pl_JumpYPath.down-Pl_JumpYPath	; From the index used for downwards movement
	ld   [sExActTimer], a
	ret
.moveDown:
	call ExActS_MoveDownByJumpYTable
	ret
	
; =============== ExAct_Unused_6700 ===============
; [TCRF] Unreferenced code.
;        Possibly a dummy ExAct which just despawns immediately.
ExAct_Unused_6700: 
	call ExActS_Despawn
	ret
	
; =============== ExAct_ItemBoxHit ===============
; ID: $02
; White box which appears over hit item boxes.
ExAct_ItemBoxHit:

	; Action sequence for item box hit
	ld   a, [sExActRoutineId]
	dec  a
	jr   z, ExActS_MoveUp1For			; 01: Move up 1px/frame 4 times
	dec  a
	jr   z, ExActS_MoveDown1For			; 02: Move down 1px/frame 4 times, stop the stun effect
	dec  a
	jr   z, ExAct_ItemBoxHit_Despawn	; 03: Write block 8x8, despawn the actor
	
.init:
	ld   a, $01					; Act++
	ld   [sExActRoutineId], a
	ld   a, $04					; Execute 4 times action 01
	ld   [sExActTimer], a
	ret
	
; =============== ExActS_MoveUp1For ===============
; Moves the current ExAct upwards 1px/frame the specified amount of times.
; Once the movement is finished it switches to the second act (which may stub to ExActS_MoveDown1For).
;
; Meant to be used for box hit effects, which have a specific action sequence.
; IN
; - sExActTimer: Movement left
ExActS_MoveUp1For:
	ld   b, $01					; Move block up 1px
	call ExActS_MoveUp
	ld   a, [sExActTimer]		; MovesLeft--
	sub  a, b			
	ld   [sExActTimer], a		; Are we done yet?
	ret  nz						; If not, return
	ld   a, $02					; Otherwise, switch to action 02 (for moving the block down)
	ld   [sExActRoutineId], a
	ld   a, $04					; Do it 4 times
	ld   [sExActTimer], a
	ret
; =============== ExActS_MoveDown1For ===============
; Moves the current ExAct downwards 1px/frame the specified amount of times.
; Once the movement is finished it switches to the second act.
;
; Meant to be used for temporary white boxes.
; IN
; - sExActTimer: Movement left
ExActS_MoveDown1For:
	ld   b, $01					; Move block down 1px
	call ExActS_MoveDown
	ld   a, [sExActTimer]		; MovesLeft--
	sub  a, b
	ld   [sExActTimer], a		; Are we done yet?
	ret  nz						; If not, return
	ld   a, $03					; Otherwise, switch to action 03 (varies between actors)
	ld   [sExActRoutineId], a
	
	; Before spawning the actor, the block above the one we hit is set to auto-stun any actors.
	; End this effect now.
	xor  a							
	ld   [sActStunLevelLayoutPtr_High], a
	ret
ExAct_ItemBoxHit_Despawn:
	; To facilitate the item box effect, before the actor is spawned, 
	; the block it's spawned over is temporarily blanked out.
	; Now that we're despawning it, we restore the original block tiles.
	
	; As this is only a visual effect and the proper block ID is already there, 
	; we don't have to write it in the level layout data.
	; We also could have read the block ID in the level layout, but for speed
	; an hardcoded block ID is used.
	; This behaviour is almost identical for the switch blocks.
	
	ld   a, [sExActLevelLayoutPtr_High]		; HL = Ptr to block in level layout
	ld   h, a
	ld   a, [sExActLevelLayoutPtr_Low]
	ld   l, a
	call GetBGMapOffsetFromBlock			; HL = Ptr to tilemap		
	ld   a, BLOCKID_ITEMUSED				; A = Block ID to write
	call Level_WriteBlockToBG				; Write the 8x8 tiles of the 16x16 block
	call ExActS_Despawn						; Despawn the item box hit actor
	ret
	
; =============== ExAct_JetHatFlame ===============
; ID: $03
; Flame appearing behind the jet hat when dashing.
ExAct_JetHatFlame:
	; Should it kill itself?
	ld   a, [sPlPower]
	cp   a, $03				; Aren't Jet Wario anymore?
	jr   nz, .despawn		; If so, despawn it
	ld   a, [sTimeUp]
	and  a					; Time's up?
	jr   nz, .despawn		; If so, despawn it
	
	;--
	; Position it relative to the player:
	; - $10 px above the player's origin
	; - $16 px behind the player's origin
	ld   bc, $1016
	call ExActS_SetRelUpBackPos
	
	; Action sequence
	ld   a, [sExActRoutineId]
	dec  a					; 01: After the dash ends
	jr   z, .dashEnd
.anim:
	; Animate the flame as long as the dash isn't over
	ld   a, [sPlJetDashTimer]
	and  a						; Is the dash over?
	jr   z, .switchToEnd		; If so, jump
	call ExAct_JetHatFlame_DoAnim
	ret
.switchToEnd:
	ld   a, OBJ_JETHATFLAME2	
	ld   [sExActOBJLstId], a
	ld   a, $01					; Switch to end 1
	ld   [sExActRoutineId], a
.dashEnd:
	; Wait for 4 frames (initial switch included) before despawning it.
	; (this starts at $00)
	ld   a, [sExActTimer]		; sExActTimer++	
	inc  a
	ld   [sExActTimer], a		
	cp   a, $04					; Reached 4 yet?
	ret  nz						; If not, return
.despawn:
	xor  a						; Clear timer
	ld   [sPlJetDashTimer], a
	call ExActS_Despawn			; Despawn jet flame
	
	; End the jet flame SFX, *if* it's still playing.
	; Another SFX4 may have started playing while the jet was active,
	; and we don't want to interrupt the wrong SFX.
	ld   a, [sSFX4]
	cp   a, SFX4_0F		; Still playing the jet SFX?
	ret  nz					; If not, return
	ld   a, SFX_NONE		; If so, end it
	ld   [sSFX4Set], a
	ret
	
; =============== ExAct_DragonHatFlame ===============
; ID: $04
; Flame appearing when the dragon hat is active.
ExAct_DragonHatFlame:
	;--
	; Auto-despawn checks
	ld   a, [sPlDragonHatActive]
	and  a									; Is the flame active?
	jr   z, ExAct_DragonHatFlame_Despawn	; If not, despawn
	ld   a, [sTimeUp]
	and  a									; Time up?
	jr   nz, ExAct_DragonHatFlame_Despawn	; If so, despawn
	ld   a, [sPlPower]
	cp   a, PL_POW_DRAGON					; Still Dragon Wario?
	jr   nz, ExAct_DragonHatFlame_Despawn	; If not, despawn
	ld   a, [sPlAction]
	cp   a, PL_ACT_CLIMB					; Are we climbing? (one of the few actions done on the behind)
	jr   z, ExAct_DragonHatFlame_Despawn	; If so, despawn
	ld   a, [sPlGroundDashTimer]
	and  a									; Started a ground dash? (how is this even triggerable)
	jr   nz, ExAct_DragonHatFlame_Despawn	; If so, despawn
	;--
	; Pick the correct Rel.Y position (upwards) depending if we're ducking or not.
	; This also determines the final location of the collision box too.
	ld   b, $10								; B = Normal Y top offset
	ld   a, [sPlDuck]
	and  a									; Are we ducking?
	jr   nz, ExAct_DragonHatFlame_DuckPos	; If so, jump
	jr   ExAct_DragonHatFlame_SetColiV
	
ExAct_DragonHatFlame_Despawn:
	; Kill the effect and despawn
	xor  a
	ld   [sPlDragonFlameDamage], a
	ld   [sPlDragonHatActive], a
	call ExActS_Despawn
	; Stop the SFX only if any of the 4 for the effect is playing.
	ld   a, [sSFX4Set]
	and  a					; Anything new requested?
	ret  nz					; If so, return
	ld   a, [sSFX4]
	cp   a, SFX4_04	; SFX4 < First one?
	ret  c						; If so, return
	cp   a, SFX4_07+1	; SFX4 > Last one?
	ret  nc						; If so, return
	; Otherwise, we're playing one of the effect.
	; End it.
	ld   a, SFX_NONE
	ld   [sSFX4Set], a
	ret
ExAct_DragonHatFlame_DuckPos:
	ld   b, $08								; B = Ducking Y top offset
ExAct_DragonHatFlame_SetColiV:
	; Set vertical collision box, shared across all acts
	ld   a, -$08
	ld   [sPlDragonFlameColiBoxU], a
	ld   a, -$01
	ld   [sPlDragonFlameColiBoxD], a
	ld   a, [sPlFlags]						; Reuse same XFLIP flag as player
	ld   [sExActOBJFlags], a
	
	; Action sequence
	; This times the entire duration of the flame, picking different collision boxes, etc...
	ld   a, [sExActRoutineId]
	dec  a								; 01:
	jr   z, ExAct_DragonHatFlame_Act1
	dec  a								; 02:
	jp   z, ExAct_DragonHatFlame_Act2
	dec  a								; 03:
	jp   z, ExAct_DragonHatFlame_Act3
	dec  a								; 04:
	jp   z, ExAct_DragonHatFlame_Act4
	dec  a								; 05:
	jp   z, ExAct_DragonHatFlame_Act5
	dec  a								; 06:
	jp   z, ExAct_DragonHatFlame_Act6
	
	
; UTILITIES
; =============== mDragonHatFlame_SetHColi ===============
; Sets the horizontal borders of the collision box.
; IN
; - 1: Left collision border
; - 2: Right collision border
MACRO mDragonHatFlame_SetHColi
	ld   a, $01							; Only makes sense when the flame can damage actors
	ld   [sPlDragonFlameDamage], a
	ld   a, \1
	ld   [sPlDragonFlameColiBoxL], a
	ld   a, \2
	ld   [sPlDragonFlameColiBoxR], a
ENDM

; =============== mDragonHatFlame_Draw ===============
; Handles the animation of the dragon hat flame.
; IN
; - 1: Normal anim frame
; - 2: Frame used for swimming
MACRO mDragonHatFlame_Draw
	;--
	; Draw every other frame for a transparency effect
	ld   a, [sTimer]
	and  a, $01
	ret  nz
	
	; Pick different starting frames if we're swimming
	ld   b, \1						; B = Normal anim frame
	ld   a, [sPlAction]
	cp   a, PL_ACT_SWIM				; Are we swimming?
	jr   nz, .setFrame\@			; If not, jump
	ld   b, \2						; B = Swim anim frame
.setFrame\@:
	call ExActS_GetAnim3FrameIdx	; A = Updated anim timer
	add  b							; Add the base frame
	ld   [sExActOBJLstId], a		; Set the resulting anim frame
	;--
ENDM

; =============== mDragonHatFlame_WaitAnimTimer ===============
; Waits for the anim timer to be reset
MACRO mDragonHatFlame_WaitAnimTimer
	ld   a, [sExActAnimTimer]
	and  a						; Timer was reset?
	ret  nz						; If not, return
ENDM

; =============== mDragonHatFlame_SetSFX ===============
; Plays SFX, meant after the anim timer is reset
; IN
; - 1: SFX4 ID
MACRO mDragonHatFlame_SetSFX
	ld   a, \1
	ld   [sSFX4Set], a
ENDM

; =============== mDragonHatFlame_WaitNextAct ===============
; Switches to the next act when the previous steps are repeated a certain amount.
; IN
; - 1: Full loops to wait for
MACRO mDragonHatFlame_WaitNextAct
	ld   a, [sExActTimer]				; sExActTimer++
	inc  a
	ld   [sExActTimer], a
	cp   a, \1							; Reached the end?
	ret  nz								; If not, return
ENDM
	
ExAct_DragonHatFlame_Act0:
	ld   a, $01							; Next act
	ld   [sExActRoutineId], a
	ld   a, SFX4_04			; Set starting SFX
	ld   [sSFX4Set], a
	mDragonHatFlame_SetHColi -$04, +$04 ; L, R Coli box
	ld   c, $14							; Set flame pos 14px in front of the player
	call ExActS_SetRelUpFrontPos
	ret
	
ExAct_DragonHatFlame_Act1:
	; Same settings from act0
	mDragonHatFlame_SetHColi -$04, +$04 ; L, R Coli box
	ld   c, $14
	call ExActS_SetRelUpFrontPos
	call ExActBGColi_DragonHatFlame_08	; Do collision (low distance)
	
	mDragonHatFlame_Draw OBJ_DRAGONHATFLAME_A0, OBJ_DRAGONHATWATER_A0
	mDragonHatFlame_WaitAnimTimer
	mDragonHatFlame_SetSFX SFX4_04
	mDragonHatFlame_WaitNextAct $03 ; repeat 3 times before next act switch
	jp   ExAct_DragonHatFlame_NextAct
	
ExAct_DragonHatFlame_Act2:
	mDragonHatFlame_SetHColi -$08, +$08 ; L, R Coli box
	;--
	; To cover the entire range of the dragon hat flame, every other frame
	; a different X offset to the collision target is picked.
	; We don't check all positions in a single frame to save time.
	ld   c, $18
	call ExActS_SetRelUpFrontPos
	ld   a, [sTimer]
	and  a, $01
	jr   nz, .posM
.posS:
	call ExActBGColi_DragonHatFlame_08
	jr   .draw
.posM:
	call ExActBGColi_DragonHatFlame_18
.draw:
	;--
	mDragonHatFlame_Draw OBJ_DRAGONHATFLAME_B0, OBJ_DRAGONHATWATER_B0
	mDragonHatFlame_WaitAnimTimer
	mDragonHatFlame_SetSFX SFX4_05
	mDragonHatFlame_WaitNextAct $03
	jp   ExAct_DragonHatFlame_NextAct
	
ExAct_DragonHatFlame_Act3:
	mDragonHatFlame_SetHColi -$10, +$10 ; L, R Coli box
	ld   c, $20
	call ExActS_SetRelUpFrontPos
	
	;--
	; Like in Act2, except the flame is longer.
	; So now we alternate between 3 positions.
	
	; ...though because the timer is and'ed, it ends up being a multiple of 2.
	; This leaves an extra position where no collision is checked.
.chkS:
	ld   a, [sTimer]
	and  a, $03							; == 0?
	jr   nz, .chkM						; If not, jump
	call ExActBGColi_DragonHatFlame_08
	jr   .draw
.chkM:
	dec  a								; == 1?
	jr   nz, .chkH						; If not, jump
	call ExActBGColi_DragonHatFlame_18
	jr   .draw
.chkH:
	dec  a								; == 2?
	jr   nz, .draw						; If not, jump
	call ExActBGColi_DragonHatFlame_28
	; no collision check on == 4
.draw:
	;--
	mDragonHatFlame_Draw OBJ_DRAGONHATFLAME_C0, OBJ_DRAGONHATWATER_C0
	mDragonHatFlame_WaitAnimTimer
	mDragonHatFlame_SetSFX SFX4_06
	mDragonHatFlame_WaitNextAct $18
	
ExAct_DragonHatFlame_NextAct:
	xor  a					; sExActTimer = 0
	ld   [sExActTimer], a
	ld   a, [sExActRoutineId]	; Next act 
	inc  a
	ld   [sExActRoutineId], a
	
	; Shortcut for playing the correct SFX4 while reusing the subroutine for all acts.
	
	; There are 4 consecutive SFX4 with IDs $04-$07:
	; - $04: SFX4_DRAGONFLAME0 | Act1 SFX (doesn't get played here)
	; - $05: SFX4_DRAGONFLAME1 | Act2 SFX
	; - $06: SFX4_DRAGONFLAME2 | Act3 SFX
	; - $07: SFX4_DRAGONFLAME3 | Act4 SFX (only here, not set in the actual act since it's the rev-down)
	; By adding the act number and a predefined constant, we know which SFX to play.
	; The duplicate SFX4 definitions at $06-$07 exist to accomodate this.
	
	cp   a, $05					; New act >= 5?
	ret  nc						; If so, there isn't any SFX to play
	add  SFX4_04-1
	ld   [sSFX4Set], a
	ret
	
; Acts 4-6 During rev-down -- no damage given
ExAct_DragonHatFlame_Act4:
	ld   c, $20
	call ExActS_SetRelUpFrontPos
	mDragonHatFlame_Draw OBJ_DRAGONHATFLAME_D0, OBJ_DRAGONHATWATER_D0
	mDragonHatFlame_WaitAnimTimer
	mDragonHatFlame_WaitNextAct $04
	jr   ExAct_DragonHatFlame_NextAct
	
ExAct_DragonHatFlame_Act5:
	ld   c, $18
	call ExActS_SetRelUpFrontPos
	mDragonHatFlame_Draw OBJ_DRAGONHATFLAME_E0, OBJ_DRAGONHATWATER_E0
	mDragonHatFlame_WaitAnimTimer
	mDragonHatFlame_WaitNextAct $04
	jr   ExAct_DragonHatFlame_NextAct
	
ExAct_DragonHatFlame_Act6:
	ld   c, $14
	call ExActS_SetRelUpFrontPos
	mDragonHatFlame_Draw OBJ_DRAGONHATFLAME_F0, OBJ_DRAGONHATWATER_F0
	mDragonHatFlame_WaitAnimTimer
	mDragonHatFlame_WaitNextAct $04
	jp   ExAct_DragonHatFlame_Despawn
	
; =============== ExActS_GetAnim3FrameIdx ===============
; This subroutine is used to update/get the index to a 3 frame animation cycle.
; The value this returns is expected to be added over base OBJLst frame (ie: OBJ_DRAGONHATFLAME_A0).
; OUT
; - A: Anim frame index
ExActS_GetAnim3FrameIdx:
	ld   a, [sExActAnimTimer]	; Index++
	inc  a
	ld   [sExActAnimTimer], a
	cp   a, $03					; Going past the last index?
	ret  nz						; If not, return
	xor  a						; If so, reset it
	ld   [sExActAnimTimer], a
	ret
	
; =============== ExAct_BlockSmash ===============
; ID: $05
; Destroyable block debris, appears after one is destroyed.
; Expects sExActOBJLstId to start at OBJ_BLOCKSMASH0
ExAct_BlockSmash:
	; Every other frame
	ld   a, [sTimer]
	and  a, $01
	ret  nz
	; Increase the anim frame until the target is reached
	; This works since the OBJLst table places them one after the other, in the proper order.
	ld   a, [sExActOBJLstId]
	inc  a
	ld   [sExActOBJLstId], a
	; [TCRF] This could have ended on OBJ_UNUSED_BLOCKSMASH9+1, so the last one goes unused
	;        Possible off by one?
	cp   a, OBJ_BLOCKSMASH8+1	; Target reached?
	ret  nz						; If not, return
	; Otherwise despawn the actor
	call ExActS_Despawn
	ld   hl, sPlBreakCombo
	dec  [hl]
	ret
; =============== ExAct_WaterSplash ===============
; ID: $06
; Appears when entering water.
ExAct_WaterSplash:
	; Basically the same as ExAct_BlockSmash.
	
	; Every 4 frames
	ld   a, [sTimer]
	and  a, $03
	ret  nz
	; Increase the anim frame until the target is reached
	ld   a, [sExActOBJLstId]
	inc  a
	ld   [sExActOBJLstId], a
	cp   a, OBJ_WATERSPLASH2+1
	ret  nz
	; Then despawn the actor
	call ExActS_Despawn
	ret
	
; =============== ExAct_WaterSplash ===============
; Bubble which moves upwards underwater.
; ID: $07
ExAct_WaterBubble:
	; Despawn when going too much offscreen
	ld   a, [sExActOBJFixX]
	cp   a, SCREEN_H+$20		; sExActOBJFixX >= $C0?
	jr   nc, .despawn			; If so, despawn it
	ld   a, [sExActOBJFixY]
	cp   a, SCREEN_V+$30		; sExActOBJFixY >= $C0?
	jr   nc, .despawn			; If so, despawn it
	
	; Every other frame
	ld   a, [sTimer]
	and  a, $01
	ret  nz
	
	; Get the block ID the bubble is colliding with
	; B = -$04 (X offset)
	; C = -$0F (Y offset)
	ld   bc, $FCF1
	call ExActBGColi_GetBlockId
	
	; $4A is the first water block
	; If the bubble is colliding with anything before, it should despawn
	cp   a, BLOCKID_WATER_START
	jr   c, .despawn
	; Same for anything >= $5C, which is after the last water block
	cp   a, BLOCKID_WATER_END
	jr   nc, .despawn
	
	; Otherwise move bubble upwards
	ld   b, $01
	call ExActS_MoveUp
	ret
.despawn:
	call ExActS_Despawn
	ret
	
; =============== ExAct_SaveSel_NewHat ===============
; ID: $08
; The sideways hat in the save select screen.
ExAct_SaveSel_NewHat:
	; Despawn when Wario gets it
	ld   a, [sSaveAnimAct]
	cp   a, $02
	ret  nz
	jp   ExActS_Despawn
	
; =============== ExAct_SaveSel_OldHat ===============
; ID: $09
; The hat which flies away after Wario hits the wall.
ExAct_SaveSel_OldHat:
	; Update position every other frame
	ld   a, [sTimer]
	and  a, $01
	ret  nz
	;--
	
	ld   a, [sExAct09_TblIndex]
	ld   e, a
	; When it reaches a certain index, change OBJ frame
	cp   a, $06					; Is the index $06?
	jr   nz, .checkFr2			
	ld   a, OBJ_SAVESEL_OLDHAT1	; If so, switch to the second frame
	ld   [sExActOBJLstId], a	
	jr   .setNewPos
.checkFr2:
	cp   a, $0C					; Is the index $0C?
	jr   nz, .setNewPos
	ld   a, OBJ_SAVESEL_OLDHAT2	; If so, switch to the third frame
	ld   [sExActOBJLstId], a
	
.setNewPos:
	; Index the hat offset table
	ld   d, $00
	ld   hl, SaveSel_OldHatYOffTable
	add  hl, de
	ld   a, [hl]				; Get the Y offset
	
	cp   a, $80					; Did we reach the end separator?
	jp   z, ExActS_Despawn		; If so, despawn the actor
	
	ld   b, a					; Add the offset to the hat Y pos
	ld   a, [sExActOBJFixY]
	add  b
	ld   [sExActOBJFixY], a
	
	ld   a, [sExActOBJFixX]		; Move hat 1px to the right
	inc  a
	ld   [sExActOBJFixX], a
	
	ld   a, [sExAct09_TblIndex]	; Next index
	inc  a
	ld   [sExAct09_TblIndex], a
	ret
	
SaveSel_OldHatYOffTable:
	db -$04
	db -$04
	db -$04
	db -$04
	db -$02
	db -$02
	db +$00 ; $06
	db +$00
	db +$00
	db +$00
	db +$02
	db +$02
	db +$04 ; $0C
	db +$04
	db +$06
	db +$06
	db +$06
	db +$06
	db +$06
	db +$06
	db $80

; =============== ExAct_TrRoom_Arrow ===============
; ID: $0A
; The blinking arrow near when counting down money in the treasure room.
ExAct_TrRoom_Arrow:
	; If we signaled the arrow to despawn, do that
	ld   a, [sExActTrRoomArrowDespawn]
	and  a
	jr   nz, .despawn
	
	;
	; Wait for Mode_LevelClear_TrRoomCoinCount to start actually counting down
	; the coins before flashing the arrow.
	; Mode_LevelClear_TrRoomCoinCount will wait $A0-$02 frames, as the delay is set
	; initially to $A0, and it starts to actually decrement coins when it ticks down to $02.
	;
	ld   a, [sTrRoomCoinDecDelay]
	cp   a, $03					; sTrRoomCoinDecDelay >= $03?
	ret  nc						; If so, we aren't counting down the coins yet
	
	;
	; Animate the arrow by flashing it every 8 frames.
	;
	
	; Every 8 frames...
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	
	; Alternate between OBJ_BLANK_36 ($36) and OBJ_TRROOM_ARROW ($37)
	ld   a, [sExActOBJLstId]
	xor  $01
	ld   [sExActOBJLstId], a
	ret
.despawn:
	xor  a
	ld   [sExActTrRoomArrowDespawn], a
	jp   ExActS_Despawn
; =============== ExAct_SaveSel_Cross ===============
; ID: $0B
; [TCRF] A wooden cross shown over the save file marked as bad.
ExAct_SaveSel_Cross: 
	; Despawn automatically when outside of the error screen.
	ld   a, [sSubMode]
	cp   a, GM_TITLE_SAVEERROR
	jp   nz, ExActS_Despawn
	ret
	
; =============== ExAct_TreasureGet ===============
; ID: $0C
; The collected treasure when placing it in the treasure room.
ExAct_TreasureGet:
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .chkMoveType
	ld   a, [sExActOBJLstId]
	xor  $01
	ld   [sExActOBJLstId], a
.chkMoveType:
	
	ld   a, [sTreasureTrRoomMode]
	cp   a, $02						; Are we moving while holding the treasure?
	jr   nc, .putPath				; If not, jump
	
.syncToPlPos:
	;
	; Since we're holding the treasure, sync horizontal and vertical position of 
	; the treasure relative to the player's position.
	;
	
	; Place treasure to the right of of player
	; (since we're currently facing right)
	ld   a, [sPlXRel]			; actorX = sPlXRel + $0C
	add  $0C
	ld   [sExActOBJFixX], a
	
	; Wario ducks if he adds a treasure from the last row.
	; In that case, the treasure is obviously held from a different height.
	ld   a, [sPlDuck]
	and  a						; Ducking?
	jr   nz, .duck				; If so, jump
.stand:
	ld   a, [sPlYRel]			; actorY = sPlYRel - $18
	sub  a, $18
	ld   [sExActOBJFixY], a
	ret
.duck:
	ld   a, [sPlYRel]			; actorY = sPlYRel - $10
	sub  a, $10
	ld   [sExActOBJFixY], a
	ret
.putPath:
	;
	; Each treasure takes a different path, starting from its location
	; when held by the player, and ending inside the treasure box.
	;
	ld   a, [sTreasureId]
	dec  a
	rst  $28
	dw .treasureC
	dw .treasureI
	dw .treasureF
	dw .treasureO
	dw .treasureA
	dw .treasureN
	dw .treasureH
	dw .treasureM
	dw .treasureL
	dw .treasureK
	dw .treasureB
	dw .treasureD
	dw .treasureG
	dw .treasureJ
	dw .treasureE
	
; =============== mDefTreasurePath ===============
; IN
; - 1: Target X position for the actor
; - 2: Tilemap ptr to the 16x16 block
; - 3: Block ID to write to /2.
MACRO mDefTreasurePath
	; Move treasure to the right at 1px/frame
	ld   a, [sExActOBJFixX]
	inc  a
	ld   [sExActOBJFixX], a
	
	; When reaching the target X location, despawn
	; and write the 16x16 block for the treasure inside the box.
	cp   a, \1
	ret  nz
	ld   hl, \2
	ld   a, \3
ENDM	
	
;                       X TARGET             VRAMPTR                    BLOCKID
; Row 1
.treasureA: mDefTreasurePath $50, vBGTrRoomTreasureA, TRROOM_BLOCKID_TREASURE_A
	jr .writeBlock
.treasureB: mDefTreasurePath $60, vBGTrRoomTreasureB, TRROOM_BLOCKID_TREASURE_B
	jr .writeBlock
.treasureC: mDefTreasurePath $70, vBGTrRoomTreasureC, TRROOM_BLOCKID_TREASURE_C
	jr .writeBlock
.treasureD: mDefTreasurePath $80, vBGTrRoomTreasureD, TRROOM_BLOCKID_TREASURE_D
	jr .writeBlock
.treasureE: mDefTreasurePath $90, vBGTrRoomTreasureE, TRROOM_BLOCKID_TREASURE_E
	jr .writeBlock
; Row 2
.treasureF: mDefTreasurePath $50, vBGTrRoomTreasureF, TRROOM_BLOCKID_TREASURE_F
	jr .writeBlock
.treasureG: mDefTreasurePath $60, vBGTrRoomTreasureG, TRROOM_BLOCKID_TREASURE_G
	jr .writeBlock
.treasureH: mDefTreasurePath $70, vBGTrRoomTreasureH, TRROOM_BLOCKID_TREASURE_H
;--
.writeBlock:
	call Level_WriteBlockToBG	; Write treasure block to VRAM
	ld   a, SFX4_0E				; Play "treasure collected" SFX
	ld   [sSFX4Set], a
	jp   ExActS_Despawn			; Despawn actor 
;--
.treasureI: mDefTreasurePath $80, vBGTrRoomTreasureI, TRROOM_BLOCKID_TREASURE_I
	jr .writeBlock
.treasureJ: mDefTreasurePath $90, vBGTrRoomTreasureJ, TRROOM_BLOCKID_TREASURE_J
	jr .writeBlock
; Row 3
.treasureK: mDefTreasurePath $50, vBGTrRoomTreasureK, TRROOM_BLOCKID_TREASURE_K
	jr .writeBlock
.treasureL: mDefTreasurePath $60, vBGTrRoomTreasureL, TRROOM_BLOCKID_TREASURE_L
	jr .writeBlock
.treasureM: mDefTreasurePath $70, vBGTrRoomTreasureM, TRROOM_BLOCKID_TREASURE_M
	jr .writeBlock
.treasureN: mDefTreasurePath $80, vBGTrRoomTreasureN, TRROOM_BLOCKID_TREASURE_N
	jr .writeBlock
.treasureO: mDefTreasurePath $90, vBGTrRoomTreasureO, TRROOM_BLOCKID_TREASURE_O
	jp .writeBlock

	
; =============== ExAct_TrRoom_Sparkle ===============
; ID: $0D
; The sparkle which randomly spawns over collected treasures in the Treasure Room.
ExAct_TrRoom_Sparkle:
	
	; Animate every 8 frames
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	ld   a, [sExActOBJLstId]		; Frame++
	inc  a
	ld   [sExActOBJLstId], a
	ld   a, [sExActSparkle_FrameId]	; as well as the internal counter
	inc  a
	ld   [sExActSparkle_FrameId], a
	
	; All sparkle animations are 4 frames long, so if we go out of range,
	; reset the animation and register the loop.
	cp   a, $04							; Timer == $04?
	ret  nz								; If not, return
	
	; Otherwise, reset the frame back to $00
	xor  a								
	ld   [sExActSparkle_FrameId], a
	ld   a, [sExActOBJLstId]			
	sub  a, $04
	ld   [sExActOBJLstId], a
	
	; Make the sparkle loop its animation twice
	ld   a, [sExActSparkle_LoopCount]	; LoopCount++
	inc  a
	ld   [sExActSparkle_LoopCount], a
	cp   a, $02							; LoopCount == $02?
	ret  nz								; If not, return
.despawn:
	; Mark sparkle as despawned to TrRoom_ChkSpawnSparkle
	xor  a
	ld   [sTrRoomSparkleActive], a
	
	; Randomize how much to "jump ahead" in the list of sparkle indexes.
	ldh  a, [rDIV]
	and  a, $1F
	ld   [sTrRoomSparkleIndexAdd], a
	
	; Actually despawn the actor
	jp   ExActS_Despawn
	
; =============== ExAct_Switch0Type0Hit ===============
; For the white box which appears over hit switch boxes.
; The three switch blocks have basically identical code.
; IN
; - 1: 16x16 fixed block location
; - 2: Block ID to write
MACRO mExAct_SwitchHit
	; Action sequence
	ld   a, [sExActRoutineId]
	dec  a
	jp   z, ExActS_MoveUp1For		; 01: Move up 1px/frame 4 times
	dec  a
	jp   z, ExActS_MoveDown1For		; 02: Move down 1px/frame 4 times, stop the stun effect
	dec  a
	jr   z, .despawn				; 03: Write block 8x8, despawn the actor

.init:
	ld   a, $01						; Act++
	ld   [sExActRoutineId], a
	ld   a, $04						; Execute 4 times next action
	ld   [sExActTimer], a
	ret
.despawn:
	; Invert switch status
	ld   a, [sLvlBlockSwitch]
	xor  $01
	ld   [sLvlBlockSwitch], a
	
	; Patch the 16x16 block for the switch block
	; to switch between the active and inactive defn.
	ld   hl, \1
	ld   a, [hl]					; Read top-left tile id of block
	cp   a, TILEID_SWITCHBLOCK		; Is it for the inactive switch?
	jr   z, .setActive				; If so, replace it with the active switch
.setInactive:
	ld   a, TILEID_SWITCHBLOCK
	jr   .setBlock16
.setActive:
	ld   a, TILEID_SWITCHBLOCKACTIVE
.setBlock16:
	; The other tile IDs are stored sequentially
	ldi  [hl], a	; Top-left
	inc  a
	ldi  [hl], a	; Top-right
	inc  a
	ldi  [hl], a	; Bottom-left
	inc  a
	ldi  [hl], a	; Botton-right
	
	; Update the 8x8 tilemap tiles too,
	; otherwise the changes wouldn't be seen immediately
	ld   a, [sExActLevelLayoutPtr_High]		; HL = Ptr to block in level layout
	ld   h, a
	ld   a, [sExActLevelLayoutPtr_Low]
	ld   l, a
	call GetBGMapOffsetFromBlock			; HL = Ptr to tilemap
	ld   a, \2								; A = Block ID to write
	call Level_WriteBlockToBG				; Write the 8x8 tiles of the 16x16 block
	call ExActS_Despawn						; Despawn the switch block hit actor
	ret
ENDM

; =============== ExAct_Switch0Type0Hit ===============
; ID: $0E
ExAct_Switch0Type0Hit: mExAct_SwitchHit sLevelBlock_Switch2, BLOCKID_SWITCH0T0
; =============== ExAct_Switch0Type1Hit ===============
; ID: $0F
ExAct_Switch0Type1Hit: mExAct_SwitchHit sLevelBlock_Switch0, BLOCKID_SWITCH0T1
; =============== ExAct_Unused_Switch1Type0Hit ===============
; ID: $10
ExAct_Unused_Switch1Type0Hit: mExAct_SwitchHit sLevelBlock_Switch1, BLOCKID_UNUSED_SWITCH1T1

; =============== ExAct_BounceBlockHit ===============
; ID: $11
; White box which appears after landing on a bounce block.
ExAct_BounceBlockHit:
	; Action sequence
	; Almost identical to the one used in ExAct_ItemBoxHit, except the block moves up first.
	ld   a, [sExActRoutineId]
	dec  a
	jr   z, .moveDown			; 01: Move down 1px/frame 4 times
	dec  a
	jr   z, .moveUp				; 02: Move up 1px/frame 4 times, stop the stun effect
	dec  a
	jr   z, .despawn			; 03: Write block 8x8, despawn the actor
.init:
	ld   a, $01					; Act++
	ld   [sExActRoutineId], a
	ld   a, $04					; Execute 4 times action 01
	ld   [sExActTimer], a
	ret
.moveDown:
	ld   b, $01					; Move block down 1px
	call ExActS_MoveDown
	ld   a, [sExActTimer]		; MovesLeft--
	sub  a, b			
	ld   [sExActTimer], a		; Are we done yet?
	ret  nz						; If not, return
	ld   a, $02					; Otherwise, switch to action 02
	ld   [sExActRoutineId], a
	ld   a, $04					; Do it 4 times
	ld   [sExActTimer], a
	ret
.moveUp:
	ld   b, $01					; Move block up 1px
	call ExActS_MoveUp
	ld   a, [sExActTimer]		; MovesLeft--
	sub  a, b
	ld   [sExActTimer], a		; Are we done yet?
	ret  nz						; If not, return
	ld   a, $03					; Otherwise, switch to action 03
	ld   [sExActRoutineId], a
	;--
	; Result of copy/paste -- this doesn't actually get set here
	xor  a
	ld   [sActStunLevelLayoutPtr_High], a
	ret
.despawn:
	ld   a, [sExActLevelLayoutPtr_High]		; HL = Ptr to block in level layout
	ld   h, a
	ld   a, [sExActLevelLayoutPtr_Low]
	ld   l, a
	call GetBGMapOffsetFromBlock			; HL = Ptr to tilemap	
	ld   a, BLOCKID_BOUNCE					; A = Block ID to write
	call Level_WriteBlockToBG				; Write the 8x8 tiles of the 16x16 block
	call ExActS_Despawn						; Despawn the item box hit actor
	ret
	
; =============== ExAct_DeadCoinC ===============
; ID: $12
; Center coin flying out of the player in the death anim.
ExAct_DeadCoinC:
	call ExAct_DeadCoin_DoAnim
	
	; Action sequence
	ld   a, [sExActRoutineId]
	dec  a					; $01: Move coin down		
	jr   z, .moveDown
							; $00: Move coin up
.moveUp:
	ld   hl, ExAct_DeadCoinC_MoveUpOffTbl
	jr   ExAct_DeadCoin_MoveUp
.moveDown:
	ld   hl, ExAct_DeadCoinC_MoveDownOffTbl
	jr   ExAct_DeadCoin_MoveDown
; =============== ExAct_DeadCoinL ===============
; ID: $13
; Left coin flying out of the player in the death anim.
ExAct_DeadCoinL:
	call ExAct_DeadCoin_DoAnim
	ld   b, $01
	call ExActS_MoveLeft					; Always move left 1px
	
	; Action sequence
	ld   a, [sExActRoutineId]
	dec  a									; $01: Move coin down
	jr   z, ExAct_DeadCoinL_MoveDown
	ld   hl, ExAct_DeadCoinLR_MoveUpOffTbl	; $00: Move coin up
; =============== ExAct_DeadCoin_MoveUp ===============
; Moves the flying coin upwards.
; This expects to be executed as part of the first action,
; since once it's done it sets the second action.
; IN
; - HL: Movement offset table
ExAct_DeadCoin_MoveUp:
	; Check for off-screen
	;
	; The specific $10-range check is to avoid accidentally despawning
	; the coins when they immediately go off-screen. 
	; Usually these checks simply go by Y >= $C0.
	ld   a, [sExActOBJFixY]
	and  a, $F0
	cp   a, SCREEN_V+$30		; Y >= $C0 && Y < $D0?
	jp   z, ExActS_Despawn		; If so, despawn it
	
	; Use the same table offset system as the JumpY table.
	ld   a, [sExActTimer]		; DE = sExActTimer
	ld   e, a
	ld   d, $00
	add  hl, de					; Index the offset table
	ld   a, [hl]				; A = Amount to move up
	cp   a, $80					; Reached the end of the table?
	jr   z, .nextAct			; If so, switch to the next action
	ld   b, a					; Otherwise, move coin up by that amount
	call ExActS_MoveUp
	ld   hl, sExActTimer		; Index++
	inc  [hl]
	ret
.nextAct:
	xor  a
	ld   [sExActTimer], a
	ld   a, $01
	ld   [sExActRoutineId], a
	ld   a, SFX1_10			; Synched with pause in death BGM
	ld   [sSFX1Set], a
	ret
ExAct_DeadCoinL_MoveDown:
	ld   hl, ExAct_DeadCoinLR_MoveDownOffTbl
	
; =============== ExAct_DeadCoin_MoveUp ===============
; Moves the flying coin downwards.
; The coin is moved downwards until it despawns.
; IN
; - HL: Movement offset table
ExAct_DeadCoin_MoveDown:
	; Off screen check
	ld   a, [sExActOBJFixY]
	and  a, $F0
	cp   a, SCREEN_V+$30
	jp   z, ExActS_Despawn
	
	; Index the Y offset table by timer
	ld   a, [sExActTimer]
	ld   e, a
	ld   d, $00
	add  hl, de
	ld   a, [hl]
	; Check for end separator
	; Once reached, keep using the previous entry
	cp   a, $80
	jr   z, .endOfTbl
	
	; Otherwise, move down by the specified amount
	ld   b, a
	call ExActS_MoveDown
	ld   hl, sExActTimer	; Timer--
	inc  [hl]
	ret
.endOfTbl:
	; By keeping the previous entry, we'll eventually
	; go over the area where the coin is considered off-screen (and will be despawned)
	dec  hl
	ld   b, [hl]
	call ExActS_MoveDown
	ret
	
; =============== ExAct_DeadCoinR ===============
; ID: $14
; Right coin flying out of the player in the death anim.
ExAct_DeadCoinR:
	call ExAct_DeadCoin_DoAnim
	ld   b, $02						; Always move right 2px
	call ExActS_MoveRight
	
	; Action sequence
	ld   a, [sExActRoutineId]
	dec  a					; $01: Move coin down		
	jr   z, .moveDown
							; $00: Move coin up
.moveUp:
	ld   hl, ExAct_DeadCoinLR_MoveUpOffTbl
	jr   ExAct_DeadCoin_MoveUp
.moveDown:
	ld   hl, ExAct_DeadCoinLR_MoveDownOffTbl
	jr   ExAct_DeadCoin_MoveDown
	
; Y movement offset tables for the coins
ExAct_DeadCoinC_MoveUpOffTbl: 
	db $05,$05,$04,$05,$04,$04,$03,$04,$03,$03,$02,$03,$02,$02,$01,$02
	db $01,$01,$00,$01,$00,$00
	db $80

ExAct_DeadCoinC_MoveDownOffTbl: 
	db $00,$00,$01,$00,$01,$01,$02,$01,$02,$02,$03,$02,$03,$03,$04,$03
	db $04,$04,$05,$04,$05,$05
	db $80

ExAct_DeadCoinLR_MoveUpOffTbl: 
	db $04,$04,$03,$04,$03,$03,$02,$03,$02,$02,$01,$02,$01,$01,$00,$01
	db $00,$00
	db $80

ExAct_DeadCoinLR_MoveDownOffTbl: 
	db $00,$00,$01,$00,$01,$01,$02,$01,$02,$02,$03,$02,$03,$03,$04,$03
	db $04,$04
	db $80
; =============== ExAct_DeadCoin_DoAnim ===============
; Animates the coins flying out of the player.
ExAct_DeadCoin_DoAnim:
	; Animate every 3 frames
	ld   a, [sTimer]
	and  a, $03
	ret  nz
	
	; Cycle between frames OBJ_COIN0 - OBJ_COIN3
	ld   a, [sExActOBJLstId]	; Frame++
	inc  a
	ld   [sExActOBJLstId], a
	
	cp   a, OBJ_COIN3+1			; Reached the end?
	ret  nz						; If not, return
	ld   a, OBJ_COIN0			; Otherwise, reset it
	ld   [sExActOBJLstId], a
	ret
; =============== ExAct_1UPMarker ===============
; ID: $15
; Floating text after getting a 1UP / 3UP.
ExAct_1UPMarker:;I
	; This is static "text" that just stays still, but alternates the palette.
	; The OBJ frame to use (1UP or 3UP) is set when spawning the actor.
	
	; Invert palette every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .decTimer
	ld   a, [sExActOBJFlags]
	xor  $10
	ld   [sExActOBJFlags], a
.decTimer:
	; Despawn when timer expires
	ld   a, [sExActTimer]
	inc  a
	ld   [sExActTimer], a
	cp   a, $20
	ret  nz
	jp   ExActS_Despawn
	
	
; =============== ExAct_TreasureEnding ===============
; ID: $16
; The treasure moving left as it appears in the ending where
; Wario collects the treasures before counting down the total coins.
ExAct_TreasureEnding:
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .moveL
	; ...by alternating between OBJ_TRROOM_TREASURE_*0 and OBJ_TRROOM_TREASURE_*1
	; This requires the first frame ID to be aligned to an even value.
	ld   a, [sExActOBJLstId]
	xor  $01					
	ld   [sExActOBJLstId], a
.moveL:
	; Move the treasure left.
	ld   a, [sExActOBJFixX]		; X--
	dec  a
	ld   [sExActOBJFixX], a
	; When the treasure gets close to the player, signal out to the ending code
	; to make the player either jump or duck in the "hold" position.
	cp   a, $38					; X == $38?
	jr   z, .reqPlReact			; If so, jump
	
	; When the treasure reaches this position, it's exactly over the player.
	; Make the treasure despawn.
	cp   a, $28					; X == $28?
	ret  nz						; If not, return
	jp   ExActS_Despawn			; If so, despawn
.reqPlReact:
	ld   a, $01
	ld   [sExActTrRoomTreasureNear], a
	ret
	
; =============== ExAct_Moneybag ===============
; ID: $17
; Moneybag falling in the Treasure Room during the ending sequence.
ExAct_Moneybag:

	; Move every other frame
	ld   a, [sTimer]
	and  a, $01
	ret  nz
	
	;
	; Determine target position for each moneybag.
	; The first moneybag's target is at Y pos. $80.
	; For each other moneybag, the target is moved 8px above, so:
	;
	; TargetY = $80 - (MoneyBagCount * $08) 
	; 
	;
	; This position is consistent with the "moneybag stack" sprite mappings.
	;
	ld   c, $80			; C = Base target
	ld   a, [sTrRoomMoneybagCount]
	and  a				; MoneybagCount == 0?
	jr   z, .moveDown	; If so, skip
	ld   b, a			; B = LoopCount
.calcLoop:
	ld   a, c			; C -= 8
	sub  a, $08
	ld   c, a
	dec  b				; B != 0?
	jr   nz, .calcLoop	; If so, loop
	
.moveDown:
	ld   a, [sExActOBJFixY]		; Move moneybag down 1px
	inc  a
	ld   [sExActOBJFixY], a
	cp   a, c					; Reached target?
	ret  nz						; If not, return
	
.despawn:
	ld   a, SFX1_01				; Land
	ld   [sSFX1Set], a
	
	;
	; If only one ExActor is currently active, it means we're the only
	; actor, and there's no stack of moneybags yet.
	; In this case, convert the single moneybag to a stack of moneybags.
	;
	; If a stack of moneybags is already active instead (ActorCount != 1),
	; then just despawn and signal out to add one moneybag to the stack.
	;
	
	ld   a, [sExActCount]
	cp   a, $01					; ActorCount == 1?
	jr   z, .convertToStack		; If so, jump
	
	ld   a, MONEYBAGSTACK_ADDITEM	; Otherwise, add 1 to the stack
	ld   [sExActMoneybagStackMode], a
	jp   ExActS_Despawn
	
.convertToStack:
	xor  a						; Init
	ld   [sExActMoneybagStackMode], a
	ld   hl, sExActSet			; Seek to current ExActor slot
	ld   a, EXACT_MONEYBAGSTACK	; Actor ID
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ld   a, $01					; Init moneybag count
	ld   [sTrRoomMoneybagCount], a
	ld   a, OBJ_TRROOM_MONEYBAGS1	; Set initial frame
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	; Positioned to make it look like it's being held by the player
	ld   a, $80		; Y pos
	ldi  [hl], a
	ld   a, $38		; X pos
	ldi  [hl], a
	xor  a
	ldi  [hl], a
	ldi  [hl], a
	ld   [hl], a
	ret
	
; =============== ExAct_MoneybagStack ===============
; ID $18
; The stack of moneybags in the Treasure Room during the ending sequence.
ExAct_MoneybagStack:

	; Nothing to do on mode $00
	ld   a, [sExActMoneybagStackMode]
	and  a								; Mode == $00?
	ret  z								; If so, return
	
	; When walking left with the moneybag stack
	cp   a, MONEYBAGSTACK_SYNCPOS		; Sync with the player position?
	jr   z, .syncPos					; If so, jump
	
	; Otherwise, add 1 to stack
.addMoneybag:
	xor  a								; Reset mode
	ld   [sExActMoneybagStackMode], a
	ld   a, [sTrRoomMoneybagCount]		; MoneybagCount++
	inc  a
	ld   [sTrRoomMoneybagCount], a
	; Update stack frame
	add  OBJ_TRROOM_MONEYBAGS1 - $01						
	ld   [sExActOBJLstId], a
	ret
.syncPos:
	; Set the moneybag position to be relative to the player.
	; (the player is facing left when we get here)
	ld   a, [sPlYRel]		; ActorY = PlY - $10
	sub  a, $10
	ld   [sExActOBJFixY], a
	ld   a, [sPlXRel]		; ActorX = PlX - $10
	sub  a, $10
	ld   [sExActOBJFixX], a
	ret
	
; =============== ExAct_SaveSel_Smoke ===============
; ID: $19
; Smoke over a pipe after a save file is cleared.
ExAct_SaveSel_Smoke:
	; Switch frame every $08 frames
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	
	; NOTE: This starts at OBJ_SAVESEL_SMOKE0
	ld   a, [sExActOBJLstId]
	inc  a							; Switch to next frame
	ld   [sExActOBJLstId], a
	cp   a, OBJ_SAVESEL_SMOKE2+1	; Did we went past the last frame?
	ret  nz							; If not, return
	jp   ExActS_Despawn				; If so, despawn the actor
	
; =============== ExAct_TreasureLost ===============
; ID: $1A
; The treasure flying up when losing one in the game over screen.
ExAct_TreasureLost:
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	jr   nz, .moveUp
	; ...by alternating between OBJ_TRROOM_TREASURE_*0 and OBJ_TRROOM_TREASURE_*1
	; This requires the first frame ID to be aligned to an even value.
	ld   a, [sExActOBJLstId]
	xor  $01				
	ld   [sExActOBJLstId], a
.moveUp:
	; Move the treasure up until it goes off screen.
	; When that happens, signal out that we've despawned.
	ld   a, [sExActOBJFixY]		; Move treasure up
	dec  a
	ld   [sExActOBJFixY], a
	cp   a, $10					; XPos >= $10?
	ret  nc						; If so, return
.despawn:
	ld   a, $01					; Mark as despawned for other code
	ld   [sExActTrRoomTreasureDespawn], a
	jp   ExActS_Despawn			; and despawn
	
; =============== ExActS_SetRelUpBackPos ===============
; Sets the position for the current ExAct to be in front of the player.
; The Rel.X position will be to the opposite direction the player's facing.
; IN
; - B: Rel. Y position (up) 
; - C: Rel. X position (back)
ExActS_SetRelUpBackPos:
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a					; Player facing right?
	jr   nz, ExActS_SetRelUpLeftPosStub		; If so, set it relative to the left
	jr   ExActS_SetRelUpRightPosStub		; Otherwise, set it relative to the right
; =============== ExActS_SetRelUpFrontPos ===============
; Sets the position for the current ExAct to be in front of the player.
; The Rel.X position will be to the same direction the player's facing.
; IN
; - B: Rel. Y position (up) 
; - C: Rel. X position (front)
ExActS_SetRelUpFrontPos:
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a					; Player facing right?
	jr   nz, ExActS_SetRelUpRightPosStub	; If so, set it relative to the right
	
ExActS_SetRelUpLeftPosStub:
	call ExActS_SetRelUpLeftPos
	ret
	
ExActS_SetRelUpRightPosStub:
	call ExActS_SetRelUpRightPos
	ret
; =============== ExActS_SetRelUpRightPos ===============
; Sets the position for the current ExAct, relative to the player position.
; Goes off the PlTarget UP/RIGHT position.
; IN
; - B: Rel. Y position (up) 
; - C: Rel. X position (right)
ExActS_SetRelUpRightPos:
	; sExActOBJY = sPlY - B
	call PlTarget_SetUpPos
	ld   a, [sTarget_High]
	ld   [sExActOBJY_High], a
	ld   a, [sTarget_Low]
	ld   [sExActOBJY_Low], a
	; sExActOBJX = sPlX + C
	ld   b, c
	call PlTarget_SetRightPos
	ld   a, [sTarget_High]
	ld   [sExActOBJX_High], a
	ld   a, [sTarget_Low]
	ld   [sExActOBJX_Low], a
	ret
; =============== ExActS_SetRelUpLeftPos ===============
; Sets the position for the current ExAct, relative to the player position.
; Goes off the PlTarget UP/LEFT position.
; IN
; - B: Rel. Y position (up) 
; - C: Rel. X position (left)
ExActS_SetRelUpLeftPos:
	; sExActOBJY = sPlY - B
	call PlTarget_SetUpPos
	ld   a, [sTarget_High]
	ld   [sExActOBJY_High], a
	ld   a, [sTarget_Low]
	ld   [sExActOBJY_Low], a
	ld   b, c
	; sExActOBJX = sPlX - C
	call PlTarget_SetLeftPos
	ld   a, [sTarget_High]
	ld   [sExActOBJX_High], a
	ld   a, [sTarget_Low]
	ld   [sExActOBJX_Low], a
	ret
; =============== ExActS_MoveDownByJumpYTable ===============
; Moves the actor downwards based on the value indexed from the JumpY table.
;
; As it only moves the player downwards, this subroutine expects the initial 
; index to be the first one used for downwards movement.
ExActS_MoveDownByJumpYTable:
	; Index the jump Y table by timer
	ld   hl, Pl_JumpYPath		; HL = Jump table
	ld   a, [sExActTimer]		; DE = sExActTimer
	ld   e, a
	ld   d, $00
	add  hl, de					; Offset it
	ld   b, [hl]				; Get the movement
	call ExActS_MoveDown		; Move the hat down by that speed
	
	; sExActTimer++ until we reached the end of the table
	ld   a, [sExActTimer]		; Index++
	inc  a
	cp   a, Pl_JumpYPath.end-Pl_JumpYPath	; Reached the end?
	ret  z						; If so, don't update the index
	ld   [sExActTimer], a
	ret
	
; =============== ExActS_Move* ===============
; These are sets of subroutines to move the currently processed ExAct to a certain direction.
; All of these are for the 2-byte coord mode used during main gameplay.
; IN
; - B: How much to move

; =============== ExActS_MoveDown ===============
ExActS_MoveDown:
	ld   a, [sExActOBJY_Low]		; sExActOBJY += B 
	add  b
	ld   [sExActOBJY_Low], a
	ld   a, [sExActOBJY_High]
	adc  a, $00
	ld   [sExActOBJY_High], a
	ret
; =============== ExActS_MoveUp ===============
ExActS_MoveUp:
	ld   a, [sExActOBJY_Low]		; sExActOBJY -= B 
	sub  a, b
	ld   [sExActOBJY_Low], a
	ld   a, [sExActOBJY_High]
	sbc  a, $00
	ld   [sExActOBJY_High], a
	ret
; =============== ExActS_MoveRight ===============
ExActS_MoveRight:
	ld   a, [sExActOBJX_Low]		; sExActOBJX += B 
	add  b
	ld   [sExActOBJX_Low], a
	ld   a, [sExActOBJX_High]
	adc  a, $00
	ld   [sExActOBJX_High], a
	ret
; =============== ExActS_MoveLeft ===============
ExActS_MoveLeft:
	ld   a, [sExActOBJX_Low]		; sExActOBJX -= B 
	sub  a, b
	ld   [sExActOBJX_Low], a
	ld   a, [sExActOBJX_High]
	sbc  a, $00
	ld   [sExActOBJX_High], a
	ret

; =============== ExActS_Despawn ===============
; Despawns the currently processed Extra Actor.
; This will overwrite all $10 bytes used by the actor.
ExActS_Despawn:
	xor  a
	ld   hl, sExActSet
	ld   b, $10
.loop:
	ldi  [hl], a
	dec  b
	jr   nz, .loop
	ld   hl, sExActCount
	dec  [hl]
	ret
	
; =============== ExActS_Unused_* ===============
; [TCRF] Set of unreferenced functions for increasing/decreasing
;        variables of the current ExAct by a certain amount.
;
;        One thing these all have in common is that they increase
;        the ExActor routine/mode id by $02.

; =============== ExActS_Unused_MoveRightAndIncRtn ===============
; Like ExActS_MoveRight, except it also increses the routine ID by 2.
; IN
; - B: How much to move
ExActS_Unused_MoveRightAndIncRtn:
	ld   a, [sExActOBJX_Low]
	add  b
	ld   [sExActOBJX_Low], a
	ld   a, [sExActOBJX_High]
	adc  a, $00
	ld   [sExActOBJX_High], a
	jr   ExActS_Unused_IncRtnBy2
	
; =============== ExActS_Unused_MoveLeftAndIncRtn ===============
; Like ExActS_MoveLeft, except it also increses the routine ID by 2.
; IN
; - B: How much to move
ExActS_Unused_MoveLeftAndIncRtn:
	ld   a, [sExActOBJX_Low]
	sub  b
	ld   [sExActOBJX_Low], a
	ld   a, [sExActOBJX_High]
	sbc  a, $00
	ld   [sExActOBJX_High], a
	jr   ExActS_Unused_IncRtnBy2
	
; =============== ExActS_Unused_IncOBJLstIdAndIncRtn ===============
; Increases the current animation frame by the specified amount,
; then it also increses the routine ID by 2.
; IN
; - B: Number added to the anim. frame id
ExActS_Unused_IncOBJLstIdAndIncRtn:
	ld   a, [sExActOBJLstId]
	add  b
	ld   [sExActOBJLstId], a
	
; =============== ExActS_Unused_IncRtnBy2 ===============
; Increases the routine ID of the current ExActor by $02.
ExActS_Unused_IncRtnBy2:
	ld   a, [sExActRoutineId]
	add  $02
	ld   [sExActRoutineId], a
	ret  
	
; =============== ExActS_Unused_DecOBJLstIdAndIncRtn ===============
; Decreases the current animation frame by the specified amount,
; then it also increses the routine ID by 2.
; IN
; - B: Number renoved to the anim. frame id
ExActS_Unused_DecOBJLstIdAndIncRtn:
	ld   a, [sExActOBJLstId]
	sub  b
	ld   [sExActOBJLstId], a
	jr   ExActS_Unused_IncRtnBy2
	
; =============== ExActS_Unused_IncTimerToValAndIncRtn ===============
; Increases the timer by 1.
; When it reaches the specified target, it resets the timer and
; increses the routine ID by 2.
;
; IN
; - B: Max value for timer
ExActS_Unused_IncTimerToValAndIncRtn:
	ld   a, [sExActTimer]		; Timer++
	inc  a
	ld   [sExActTimer], a
	cp   b						; Timer == B?
	ret  nz						; If not, return
	xor  a						; Otherwise, reset it
	ld   [sExActTimer], a
	jr   ExActS_Unused_IncRtnBy2 ; And increase routine id

; =============== ExActBGColi_GetBlockId ===============
; Gets the active block ID the current ExAct is colliding with.
; Unlike most other BGColi subroutines, the target offsets have to be manually specified.
; IN
;  - B: X pos offset (signed)
;  - C: Y pos offset (signed)
; OUT
;  - A: Block ID
ExActBGColi_GetBlockId:
	; Set X component
	call ExActOBJTarget_SetHorzPos
	call PlBGColi_GetXBlockOffset	; L = Low byte of offset (and level layout ptr)
	ld   a, l
	ld   [sBlockTopLeftPtr_Low], a
	
	; Set Y component
	ld   b, c
	call ExActOBJTarget_SetVertPos
	call PlBGColi_GetYBlockOffset
	; Calculate level layout ptr
	ld   a, h						; H = High byte of offset
	ld   [sBlockTopLeftPtr_High], a
	ld   a, [sBlockTopLeftPtr_Low]	; L = Low byte of offset
	ld   l, a
	ld   de, wLevelLayout			; Add wLevelLayout base to get block ptr
	add  hl, de
	; Read the block ID
	ld   a, [hl]					
	and  a, $7F						; Remove actor flag
	ret
	
; =============== ExActOBJTarget_SetHorzPos ===============
; Sets the target pointer relative to the currently processed ExAct.
; See also: ExActOBJTarget_SetVertPos
; IN
; - B: Amount to add or remove (signed)
ExActOBJTarget_SetHorzPos:

	; Make sure to pass a positive number
	
	; If it's positive, move target right (+= value)
	bit  7, b									; Is the value negative?
	jr   z, ExActOBJTarget_Unused_SetRightPos	; If not, jump
	
	; Otherwise, move target left (-= value)
	; Convert from signed negative to positive
	ld   a, b
	cpl				; Invert bits
	inc  a			; Account for $FF -> $01 instead of $00, etc...
	ld   b, a
	jr   ExActOBJTarget_SetLeftPos
	
; =============== ExActOBJTarget_Unused_SetRightPos ===============
; [TCRF] This ended up not being used.
; IN
; - B: Amount to subtract
ExActOBJTarget_Unused_SetRightPos:;R
	ld   a, [sExActOBJX_Low]
	add  b
	ld   [sTarget_Low], a
	ld   a, [sExActOBJX_High]
	adc  a, $00					; account for carry
	ld   [sTarget_High], a
	ret
	
; =============== ExActOBJTarget_SetLeftPos ===============
; IN
; - B: Amount to subtract
ExActOBJTarget_SetLeftPos:;R
	ld   a, [sExActOBJX_Low]
	sub  a, b
	ld   [sTarget_Low], a
	ld   a, [sExActOBJX_High]
	sbc  a, $00					; account for carry
	ld   [sTarget_High], a
	ret
	
; =============== ExActS_ExecuteAll ===============
; Processes all used Extra Actor slots.
ExActS_ExecuteAll:
	; If there are no ExAct, ignore
	ld   a, [sExActCount]
	and  a
	ret  z
	
	; Loop through the ExAct and draw them.
	ld   [sExActLeft], a ; ExAct left to process (excluding empty slots)
	ld   hl, sExAct
.loop:
	; If the first byte is $00, the slot is blank.
	; Blank slots should be ignored.
	ld   a, [hl]
	and  a
	jr   z, .blankSlot
	;--
	push hl
	call ExActS_CopyFromSet
	;--
	; Main processing
	call ExActS_Execute
	call HomeCall_NonGame_WriteExActOBJLst
	;--
	pop  hl
	call ExActS_CopyToSet
	;--
	ld   a, [sExActLeft]	
	dec  a							; SlotsLeft--;
	ld   [sExActLeft], a	; Are there any ExAct left to process?
	ret  z							; If not, return
	jr   .loop
.blankSlot:
	; Switch to the next slot
	ld   a, l
	add  $10
	ld   l, a
	jr   .loop
	
; =============== ExAct_JetHatFlame_DoAnim ===============
; Animates the Jet Hat flame by switching between different anim frames.
ExAct_JetHatFlame_DoAnim:
	; Animate every 4 frames
	ld   a, [sTimer]
	and  a, $03
	ret  nz
	
	; Do the anim by adding values to sExActOBJLstId
	ld   hl, OBJLstAnimOff_JetHatFlame	; HL = OBJLst anim offset table
	;--
	; Update the index
	ld   a, [sExActAnimTimer]			; Index++
	inc  a
	; If we've reached the end of the table, reset the index
	cp   a, OBJLstAnimOff_JetHatFlame.end-OBJLstAnimOff_JetHatFlame
	jr   nz, .setFrame
	xor  a
.setFrame:
	ld   [sExActAnimTimer], a
	;--
	; Index the table
	ld   e, a					; DE = sExActAnimTimer
	ld   d, $00
	add  hl, de					; Index it
	ld   a, [sExActOBJLstId]	; Add the indexed value to the current ExAct anim frame
	add  [hl]
	ld   [sExActOBJLstId], a
	ret
	
OBJLstAnimOff_JetHatFlame:
	db -$02
	db +$01
	db +$01
.end:

; =============== Parallax_Do ===============
; This handles all "parallax effects" during gameplay (and in the credits),
; mostly used to move bosses in the foreground layer.
; 
; Generally this works through three definitions in 3 memory addresses:
; 
; - Y Scroll position
; - X Scroll position
; - LYC target (to mark at which Y position to stop the effect, and trigger the next one)
; 
; Different modes can use different memory addresses.
;
; Each mode only sets specific scrolling settings, so to have different parts of the
; screen scroll in different ways, modes are cycled through during the frame.
; This is done by changing the parallax mode at the end of the subroutine,
; and marking a different LYC target, which will trigger this parallax routine on the next LCDC interrupt.
Parallax_Do:
	ld   a, [sParallaxMode]
	rst  $28
	
	; Group: Train levels (level scrolling right)
	dw Parallax_TrainR_Mountains
	dw Parallax_TrainR_Main
	dw Parallax_TrainR_Tracks
	; [TCRF] Single unused modes, not connected to anything.
	;        Possibly placeholders since they aren't part of a group.
	dw Parallax_Unused0
	dw Parallax_Unused1
	; Group: Bosses on background layer
	dw Parallax_Boss0
	dw Parallax_Boss1
	dw Parallax_Boss2
	dw Parallax_Boss3
	; Group: Train levels (level scrolling left)
	dw Parallax_TrainL_Mountains
	dw Parallax_TrainL_Main
	dw Parallax_TrainL_Tracks
	; Credits group
	dw Parallax_CreditsMain
	dw Parallax_CreditsRow1
	dw Parallax_CreditsRow2
; =============== Parallax_TrainR_Mountains ===============
; Parallax for train levels autoscrolling to the right.
; Mountain background
; Speed: 0.5px / frame; Direction: left
Parallax_TrainR_Mountains:
	; Scroll the background to the left every other frame
	ld   a, [sTimer]
	and  a, $01
	jr   nz, .noScroll
	ld   a, [sParallaxX0]
	dec  a
	ld   [sParallaxX0], a
.noScroll:;R
	ld   a, [sParallaxX0]
	ldh  [rSCX], a
	; Switch to Parallax_TrainR_Main on LY $2F
	ld   a, PRX_TRAINMAINR
	ld   [sParallaxMode], a
	ld   a, $2F
	ldh  [rLYC], a
	ret
; =============== Parallax_TrainR_Main ===============
; Scroll the main level section
Parallax_TrainR_Main:
	; No special effect
	ld   a, [sScrollX]
	ldh  [rSCX], a
	
	ld   a, PRX_TRAINTRACKR
	ld   [sParallaxMode], a
	ld   a, $80
	ldh  [rLYC], a
	ret
; =============== Parallax_TrainR_Tracks ===============
; Tracks at the bottom of the level.
; Speed: 2px / frame; Direction: left
Parallax_TrainR_Tracks:
	ld   a, [sParallaxX1]
	sub  a, $02
	ld   [sParallaxX1], a
	ld   a, [sParallaxX1]
	ldh  [rSCX], a
	
	xor  a ; PRX_TRAINMOUNTR
	ld   [sParallaxMode], a
	ldh  [rLYC], a
	ret
	
; =============== Parallax_Unused0 ===============
; [TCRF]
; Unused var0 scroll mode.
Parallax_Unused0:
	ld   a, [sParallaxY0]
	ldh  [rSCY], a
	ld   a, [sParallaxX0]
	ldh  [rSCX], a
	ld   a, PRX_UNUSED0
	ld   [sParallaxMode], a
	ld   a, [sParallaxNextLY1]
	ldh  [rLYC], a
	ret
; =============== Parallax_Unused1 ===============
; [TCRF]
; Unused var1 scroll mode.
Parallax_Unused1: 
	ld   a, [sParallaxY1]
	ldh  [rSCY], a
	ld   a, [sParallaxX1]
	ldh  [rSCX], a
	ld   a, PRX_UNUSED1
	ld   [sParallaxMode], a
	ld   a, [sParallaxNextLY0]
	ldh  [rLYC], a
	ret
; =============== Parallax_Boss0 ===============
; Parallax for foreground-based bosses.
; 
; [POI]/[BUG]
; All of the bosses use this chain of 4 parallax modes, even though not all are needed.
; Using more modes (at the wrong scanline) than needed actually causes some minor artifacts during boss battles.
Parallax_Boss0:
	ld   a, [sParallaxY0]
	ldh  [rSCY], a
	ld   a, [sParallaxX0]
	ldh  [rSCX], a
	ld   a, PRX_BOSS1
	ld   [sParallaxMode], a
	ld   a, [sParallaxNextLY1]
	ldh  [rLYC], a
	ret
; =============== Parallax_Boss1 ===============
Parallax_Boss1:
	ld   a, [sParallaxY1]
	ldh  [rSCY], a
	ld   a, [sParallaxX1]
	ldh  [rSCX], a
	ld   a, PRX_BOSS2
	ld   [sParallaxMode], a
	ld   a, [sParallaxNextLY2]
	ldh  [rLYC], a
	ret
; =============== Parallax_Boss2 ===============
Parallax_Boss2:
	ld   a, [sParallaxY2]
	ldh  [rSCY], a
	ld   a, [sParallaxX2]
	ldh  [rSCX], a
	ld   a, PRX_BOSS3
	ld   [sParallaxMode], a
	ld   a, [sParallaxNextLY3]
	ldh  [rLYC], a
	ret
; =============== Parallax_Boss3 ===============
Parallax_Boss3:
	ld   a, [sParallaxY3]
	ldh  [rSCY], a
	ld   a, [sParallaxX3]
	ldh  [rSCX], a
	ld   a, PRX_BOSS0
	ld   [sParallaxMode], a
	ld   a, [sParallaxNextLY0]
	ldh  [rLYC], a
	ret
; =============== Parallax_TrainL_Mountains ===============
; Parallax for train levels autoscrolling to the left
; Mountain background
; Speed: 0.5px / frame; Direction: right
Parallax_TrainL_Mountains:
	ld   a, [sTimer]
	and  a, $01
	jr   nz, .noBgScroll
	ld   a, [sParallaxX0]
	inc  a
	ld   [sParallaxX0], a
.noBgScroll:
	ld   a, [sParallaxX0]
	ldh  [rSCX], a
	ld   a, PRX_TRAINMAINL
	ld   [sParallaxMode], a
	ld   a, $2F
	ldh  [rLYC], a
	ret
; =============== Parallax_TrainL_Main ===============
; Main level.
; This simply updates the scroll X position for this horizontal strip to keep it aligned.
Parallax_TrainL_Main:
	ld   a, [sScrollX]
	ldh  [rSCX], a
	ld   a, PRX_TRAINTRACKL
	ld   [sParallaxMode], a
	ld   a, $80
	ldh  [rLYC], a
	ret
; =============== Parallax_TrainL_Tracks ===============
; Train tracks
; Speed: 2px / frame; Direction: right
Parallax_TrainL_Tracks:
	ld   a, [sParallaxX1]
	add  $02
	ld   [sParallaxX1], a
	ldh  [rSCX], a
	ld   a, PRX_TRAINMOUNTL
	ld   [sParallaxMode], a
	xor  a
	ldh  [rLYC], a
	ret
; =============== Parallax_CreditsMain ===============
; Main credits scene
; No parallax used.
Parallax_CreditsMain:
	ldh  a, [hScrollY]
	ldh  [rSCY], a
	ld   a, [sScrollX]
	ldh  [rSCX], a
	ld   a, $68
	ldh  [rLYC], a
	ld   a, PRX_CREDROW1
	ld   [sParallaxMode], a
	ret
; =============== Parallax_CreditsRow1 ===============
; First text row; horizontal scroll effect.
; Note: The game alternates between two different scroll positions every other frame
; to do the "transparency" effect.
Parallax_CreditsRow1:
	ld   a, [sParallaxY0]
	ldh  [rSCY], a
	ld   a, [sParallaxX0]
	ldh  [rSCX], a
	ld   a, $78
	ldh  [rLYC], a
	ld   a, PRX_CREDROW2
	ld   [sParallaxMode], a
	ret
; =============== Parallax_CreditsRow2 ===============
; Second text row, for the vertical scroll effect
Parallax_CreditsRow2:
	ld   a, [sParallaxY1]
	ldh  [rSCY], a
	ld   a, [sParallaxX1]
	ldh  [rSCX], a
	xor  a
	ldh  [rLYC], a
	ld   a, PRX_CREDMAIN
	ld   [sParallaxMode], a
	ret
	
; =============== Level_AnimTiles ===============
; Performs tile animation in a level.
; This will update the VRAM area at $9200-$923F by copying the current frames.
Level_AnimTiles:

	; First of all, we need to check if we're in a mode/submode combination which takes place in a level
	; These are:
	; - Normal gameplay
	; - Entering a normal door (except when it's loading GFX)
	; - Level end mode (the submodes before the course clear)
	; - Level init mode (except for the first submode, when it's loading the level data as the screen is disabled and it'd be pointless)
	; [BUG] Mode GM_LEVELENTRANCE isn't checked, so tiles aren't animated when exiting the level through the first door
	; ------------------------------------------
	
	; Initial obvious check for the 
	ld   a, [sGameMode]				
	cp   a, GM_LEVEL 				; Are we in normal gameplay?
	jr   z, .animTiles				; If so, animate the tiles
IF FIX_BUGS == 1
	cp   a, GM_LEVELENTRANCE 		; Are we exiting the level from the entrance door?
	jr   z, .animTiles				; If so, animate the tiles
ENDC
	
	; Chained game mode checks. 
	; For each of these, if the game mode doesn't match, it will skip to the next label.
	; If none match, we don't animate the tiles.
	
.checkLevelClear
	cp   a, GM_LEVELCLEAR
	jr   nz, .checkDoorEntry
	;--
	ld   a, [sSubMode] 				; In level clear mode, only the first three submodes take place during gameplay
	cp   a, GM_LEVELCLEAR_CLEARINIT ; As such, avoid doing it when in the course clear or treasure screen
	jr   c, .animTiles
	ret

.checkDoorEntry:
	cp   a, GM_LEVELDOOR
	jr   nz, .checkLevelStart
	;--
	ld   a, [sSubMode]				
	cp   a, GM_LEVELDOOR_ROOMLOAD	; Is the room GFX loading? (between fade-out and fade-in; display disabled)
	jr   nz, .animTiles				; If not, animate the tiles
	ret

.checkLevelStart:
	cp   a, GM_LEVELINIT	
	ret  nz
	;--	
	ld   a, [sSubMode]				
	and  a							; Is the level loading? (display disabled)
	jr   nz, .animTiles				; If not, animate the tiles
	ret
;--

.animTiles:
	; Check if tile animation is disabled (speed = 0)
	ld   a, [sLevelAnimSpeed] 				
	and  a
	ret  z
	;--
	; Check if we can update the next animated tiles to use the next frame.
	;
	; The "animation speed" is more like a mask for when to update the animated tiles based on the game timer.
	; CanAnimateNextFrame = sTimer & sLevelAnimSpeed
	;
	; In practice the speed is set to 7, which give a constant speed of 1 tile every 8 frames,
	; as anything but a constant tile animation will look odd.
	ld   b, a
	ld   a, [sTimer]
	and  a, b
	ret  nz
	;--
	ld   hl, sLevelAnimGFX	; HL = Table of animated GFX data
	ld   a, [sLevelAnimFrame]	; Increase the frame ID
	inc  a
	;--
	cp   a, $04					; Did we just went past the last valid frame ID?
	jr   nz, .calcTileOffset	; If not, don't reset it back to 0
	xor  a				
	
.calcTileOffset:

	; Calculate the offset to the area where the GFX data for this frame is stored
	
	;--
	; An animated tile is made of 4 tiles (frames)
	; Each of these takes $10 bytes.
	; Offset = FrameId * 40
	; The next four tiles ($40 bytes) will be copied over to VRAM from the $100 byte RAM area
	; containing all the frames for the current animated tiles.
	; 
	; To make this work, the source GFX data is stored so that given 4 animated tiles,
	; all first frames are stored first, then all second frames, etc...
	; With this all the necessary data to copy is in one contiguous block.
	; 
	ld   [sLevelAnimFrame], a 	; A = FrameId
	add  a 						; *2
	add  a 						; *2
	swap a						; << 4 (*$10) ; Size of a tile
	
	; Add this offset to the start of the GFX data
	ld   e, a					; DE = 00
	ld   d, $00
	add  hl, de 				; Get the start of the GFX data to use
	
	;--
	; Copy operation during HBLANK
	
	ld   de, $9200				; DE = Target area in VRAM
								; Since every iteration copies 4 bytes (see REPT below)...
	ld   b, $10					; ...perform the copy operation $10 times to copy all the tiles
	
	;--
	
	; HBlank waiting time
	; This is what will take a considerable amount of time
.waitTransfer: mWaitForNewHBlank
	;--
	
	; Copy 4 bytes at a time (of the total $40)
	; This is the most we can do, since timing is very strict.
	REPT 4
	ldi  a, [hl]
	ld   [de], a
	inc  e
	ENDR
	;--
	
	dec  b
	jr   nz, .waitTransfer
	ret
	
	mIncJunk "L0D72F5"

; =============== INPUT DEMO DATA ($80 bytes each) ===============
; Demo format:
; Input demos are tables and must be exactly $80 bytes long.
; Each entry takes 2 bytes, in the order:
; - Key held (see KEY_* enum)
; - How many frames to hold the key

Demo_InputTable:
INCBIN "data/lvl/c01a/demo.bin"
INCBIN "data/lvl/c04/demo.bin"
INCBIN "data/lvl/c09/demo.bin"
INCBIN "data/lvl/c10/demo.bin"
INCBIN "data/lvl/c22/demo.bin"
INCBIN "data/lvl/c18/demo.bin"

; ================ END OF BANK =================
	mIncJunk "L0D7B00"
