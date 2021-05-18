; =============== RESET VECTOR $00 ===============
	jp GameInit
	
; =============== START OF ALIGN JUNK ===============
L000003: db $EE;X
L000004: db $AB;X
L000005: db $AA;X
L000006: db $EA;X
L000007: db $AA;X
L000008: db $AA;X ; RESET VECTOR $08 - Not used
L000009: db $AA;X
L00000A: db $AA;X
L00000B: db $AA;X
L00000C: db $EA;X
L00000D: db $A6;X
L00000E: db $AB;X
L00000F: db $AA;X
L000010: db $AE;X ; RESET VECTOR $10 - Not used
L000011: db $AA;X
L000012: db $AE;X
L000013: db $AE;X
L000014: db $AE;X
L000015: db $AB;X
L000016: db $EF;X
L000017: db $AA;X
L000018: db $AE;X ; RESET VECTOR $18 - Not used
L000019: db $AA;X
L00001A: db $AA;X
L00001B: db $AB;X
L00001C: db $BE;X
L00001D: db $AA;X
L00001E: db $AA;X
L00001F: db $AE;X
L000020: db $AA;X ; RESET VECTOR $20 - Not used
L000021: db $AA;X
L000022: db $AA;X
L000023: db $AA;X
L000024: db $AF;X
L000025: db $AF;X
L000026: db $AE;X
L000027: db $EA;X
; =============== END OF ALIGN JUNK ===============

; =============== RESET VECTOR $28 ===============
; This subroutine takes the value in A to index a table of address pointers.
; It will then jump to the address specified there.
;
; The pointer table must be stored exactly after the "rst $28" instruction used to call this subroutine. 
; Because of this, HL will automatically point to the correct address when calling this.
;
; The code which calls this reset vector is always structured in a manner similar to this:
; ld   a wSomeAddress
; rst  $28
; MyPtrTable:
; 	dw DoSomething
; 	dw DoSomethingElse
; DoSomething:
;	... ; code goes here
; DoSomethingElse:
;	... ; other code goes here
;
; IN
; - A: Index to a table of pointers
;
DynJump:
	add  a			; Index *= 2 since the address table is obviously a table of words
	pop  hl			; HL = Base address of ptr table
	ld   e, a		; DE = A
	ld   d, $00
	add  hl, de		; Index the pointer table (HL += Index*2)
	
	; Store the resulting address to HL (using DE as temp reg)
	ld   e, [hl]	
	inc  hl
	ld   d, [hl]
	ld   h, d
	ld   l, e
	
	jp   hl			; and jump to it
	
; =============== START OF ALIGN JUNK ===============
L000034: db $E9;X
L000035: db $AA;X
L000036: db $AF;X
L000037: db $BA;X
L000038: db $AA;X
L000039: db $EA;X
L00003A: db $EA;X
L00003B: db $AE;X
L00003C: db $AF;X
L00003D: db $AE;X
L00003E: db $FE;X
L00003F: db $EE;X
; =============== END OF ALIGN JUNK ===============

; =============== VBLANK INTERRUPT ===============
VBlankInt:
	jp   VBlankHandler
	
; =============== START OF ALIGN JUNK ===============
L000043: db $EE;X
L000044: db $EF;X
L000045: db $AA;X
L000046: db $EA;X
L000047: db $EA;X
; =============== END OF ALIGN JUNK ===============

; =============== LCDC/STAT INTERRUPT ===============
LCDCInt:
	jp   LCDCHandler
	
; =============== START OF ALIGN JUNK ===============
L00004B: db $EE;X
L00004C: db $EA;X
L00004D: db $AE;X
L00004E: db $AA;X
L00004F: db $AA;X
L000050: db $EB;X ; TIMER INTERRUPT (not used)
L000051: db $AE;X
L000052: db $AA;X
L000053: db $AE;X
L000054: db $BE;X
L000055: db $EA;X
L000056: db $AE;X
L000057: db $BA;X
L000058: db $EE;X ; SERIAL INTERRUPT (not used)
L000059: db $EE;X
L00005A: db $EA;X
L00005B: db $EE;X
L00005C: db $EA;X
L00005D: db $EA;X
L00005E: db $AA;X
L00005F: db $FA;X
L000060: db $EE;X ; JOYPAD INTERRUPT (not used)
L000061: db $FB;X
L000062: db $AE;X
L000063: db $AE;X
L000064: db $AE;X
L000065: db $AA;X
L000066: db $AE;X
L000067: db $EB;X
L000068: db $EB;X
L000069: db $EE;X
L00006A: db $AF;X
L00006B: db $AE;X
L00006C: db $AA;X
L00006D: db $AA;X
L00006E: db $AA;X
L00006F: db $AA;X
L000070: db $FE;X
L000071: db $AE;X
L000072: db $AE;X
L000073: db $AA;X
L000074: db $AF;X
L000075: db $EE;X
L000076: db $EA;X
L000077: db $AA;X
L000078: db $AA;X
L000079: db $AE;X
L00007A: db $EA;X
L00007B: db $A8;X
L00007C: db $EF;X
L00007D: db $EA;X
L00007E: db $AB;X
L00007F: db $EE;X
L000080: db $88;X
L000081: db $A8;X
L000082: db $02;X
L000083: db $82;X
L000084: db $2A;X
L000085: db $A0;X
L000086: db $AE;X
L000087: db $8A;X
L000088: db $2A;X
L000089: db $AA;X
L00008A: db $A0;X
L00008B: db $08;X
L00008C: db $AC;X
L00008D: db $82;X
L00008E: db $AA;X
L00008F: db $8A;X
L000090: db $82;X
L000091: db $AA;X
L000092: db $80;X
L000093: db $80;X
L000094: db $8A;X
L000095: db $0A;X
L000096: db $AA;X
L000097: db $A2;X
L000098: db $20;X
L000099: db $8A;X
L00009A: db $AA;X
L00009B: db $AA;X
L00009C: db $26;X
L00009D: db $28;X
L00009E: db $AA;X
L00009F: db $A8;X
L0000A0: db $82;X
L0000A1: db $88;X
L0000A2: db $A0;X
L0000A3: db $08;X
L0000A4: db $22;X
L0000A5: db $82;X
L0000A6: db $A0;X
L0000A7: db $A2;X
L0000A8: db $28;X
L0000A9: db $88;X
L0000AA: db $A0;X
L0000AB: db $A8;X
L0000AC: db $02;X
L0000AD: db $AA;X
L0000AE: db $AA;X
L0000AF: db $A0;X
L0000B0: db $AA;X
L0000B1: db $A2;X
L0000B2: db $0A;X
L0000B3: db $22;X
L0000B4: db $22;X
L0000B5: db $A2;X
L0000B6: db $09;X
L0000B7: db $2A;X
L0000B8: db $A0;X
L0000B9: db $A2;X
L0000BA: db $A0;X
L0000BB: db $8A;X
L0000BC: db $0A;X
L0000BD: db $88;X
L0000BE: db $A8;X
L0000BF: db $20;X
L0000C0: db $8A;X
L0000C1: db $88;X
L0000C2: db $A2;X
L0000C3: db $A2;X
L0000C4: db $20;X
L0000C5: db $A0;X
L0000C6: db $82;X
L0000C7: db $AA;X
L0000C8: db $88;X
L0000C9: db $02;X
L0000CA: db $A8;X
L0000CB: db $AA;X
L0000CC: db $8A;X
L0000CD: db $08;X
L0000CE: db $A2;X
L0000CF: db $A0;X
L0000D0: db $2A;X
L0000D1: db $88;X
L0000D2: db $AA;X
L0000D3: db $0A;X
L0000D4: db $AA;X
L0000D5: db $A8;X
L0000D6: db $80;X
L0000D7: db $AA;X
L0000D8: db $28;X
L0000D9: db $28;X
L0000DA: db $AA;X
L0000DB: db $00;X
L0000DC: db $00;X
L0000DD: db $AA;X
L0000DE: db $A8;X
L0000DF: db $A8;X
L0000E0: db $80;X
L0000E1: db $28;X
L0000E2: db $AA;X
L0000E3: db $22;X
L0000E4: db $A2;X
L0000E5: db $AA;X
L0000E6: db $22;X
L0000E7: db $80;X
L0000E8: db $20;X
L0000E9: db $2A;X
L0000EA: db $AA;X
L0000EB: db $AA;X
L0000EC: db $82;X
L0000ED: db $8A;X
L0000EE: db $0A;X
L0000EF: db $20;X
; This is marked as used by the CDL as a side-effect of the sound driver.
; L0000F0 appears as a pointer to a BGM Table inside the various chunks...
; ...but it's not actually a real table pointer as it just points to uninitialized junk.
;
; Instead, it's treated as the loop command BGMTBLCMD_REDIR ($F0,£00)
; The code recognizes the command instead of parsing out the chunk... but evidently the CDL marks this as used anyway???
L0000F0: db $80		
L0000F1: db $2A
L0000F2: db $80
L0000F3: db $8A
L0000F4: db $A2
L0000F5: db $28
L0000F6: db $8A
L0000F7: db $AA
L0000F8: db $88
L0000F9: db $A2
L0000FA: db $22
L0000FB: db $28
L0000FC: db $A2
L0000FD: db $28
L0000FE: db $80
L0000FF: db $08
; =============== END OF ALIGN JUNK ===============

; =============== HW ENTRY POINT ===============
_ENTRY_POINT:
	nop
	jp   EntryPoint
	
; =============== GAME HEADER ===============
	; Logo
	db $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
	db $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
	db $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E
	db "SUPERMARIOLAND3" ; Game title
	db $00		; DMG - classic gameboy
	dw $0000	; new license
	db $00		; SGB flag: not SGB capable
	db $03		; cart type: MBC1+RAM+BATTERY
	db $04		; rom size: 512 KiB
	db $02		; ram size: 8 KiB
	db $00		; destination code: Japanese
	db $01		; old license: not SGB capable
	db $00		; mask ROM version number
	db $84		; header checksum
	dw $A5F4 	; global checksum

; =============== EntryPoint ===============
EntryPoint:
	jp   GameInit
	
; =============== VBlankHandler ===============
VBlankHandler:
	push af
	push bc
	push de
	push hl
	; Determine which type of screen we're running the handler for
	ld   a, [sStaticScreenMode]
	and  a
	jr   nz, .static
	ld   a, [sMapVBlankMode]
	and  a
	jr   nz, .map
	
.main:
	; Copy the scroll register copies to the real registers
	ld   a, [sScrollYOffset]	; rSCY = sScrollYOffset + hScrollY
	ld   b, a					; this has an offset for screen shake effects
	ldh  a, [hScrollY]			
	add  b
	ldh  [rSCY], a				
	
	ld   a, [sScrollX]			; No offset for ScrollX
	ldh  [rSCX], a				
	;--
	mHomeCall ScreenEvent_Do ; BANK $05
	call hOAMDMA
	jr   .end
.map:
	call hOAMDMA
	call HomeCall_Map_ScreenEvent
	jr   .end
.static:
	call hOAMDMA
	
	; Looks like an homecall, but it isn't!
	; Because of how code is setup, this is also pointless as ScreenEvent_StaticDo could be just called directly.
	ld   a, [sROMBank]
	push af
	ld   a, $12
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call ScreenEvent_StaticDo
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	
	; If we are in the save select screen, perform the pipe animation
	ld   a, [sTitleRetVal]	
	cp   a, TITLE_NEXT_SAVE			; Did we transition from title screen to save select?
	jr   nz, .end					; If not, skip
	mHomeCall ScreenEvent_Do ; BANK $05
	
.end:
	; Mark a successful return
	ld   a, $01
	ldh  [hVBlankDone], a
	
	pop  hl
	pop  de
	pop  bc
	pop  af
	reti
	
; =============== LCDCHandler ===============
LCDCHandler:
	push af
	push bc
	push de
	push hl
	;--
	mHomeCall Parallax_Do ; BANK $0D
	;--
	pop  hl
	pop  de
	pop  bc
	pop  af
	reti

; ========================================
; =============== GameInit ===============
; ========================================
; Performs the game initiation
; Performing a soft reset will cause a jump to here.
GameInit:
	di					; Prevent interrupts from firing
	ld   sp, $AFFF		; Set up stack pointer
	ld   a, $0A			; Enable SRAM
	ld   [$0000], a

;
; Clear RAM range sActSet-$E000 with $00
; This will clear everything in RAM except for SRAM data
	xor  a				
	ld   hl, sActSet		; HL = Starting address
	ld   bc, $3F00		; BC = Bytes to clear
.clearCRAM:
	ldi  [hl], a		; Overwrite byte
;--
	dec  c				; BC--
	jr   nz, .clearCRAM
	dec  b
	jr   nz, .clearCRAM
;--

; Reset hardware registers
.resetRegisters
	xor  a
	ldh  [rIF], a
	ldh  [rIE], a
	xor  a
	ldh  [rSCY], a
	ldh  [rSCX], a
	ldh  [rSTAT], a
	ld   a, LCDC_ENABLE
	ldh  [rLCDC], a
; Wait for the VBlank before editing the video register

.vblankWait:
	ldh  a, [rLY] 
	cp   a, LY_VBLANK + $4
	jr   nz, .vblankWait
	
	ld   a, LCDC_PRIORITY|LCDC_OBJENABLE ; Disable the screen
	ldh  [rLCDC], a
	; Set the default palettes
	ld   a, $E1 
	ldh  [rBGP], a
	ldh  [rOBP1], a
	ld   a, $1C
	ldh  [rOBP0], a
	
	; Initialize the sound engine
	mHomeCall Sound_InitStub ; BANK 04
	
	; Clear GFX
	ld   hl, $8000 
	ld   bc, $1800
	xor  a
	call ClearRAMRange 
	; Clear WINDOW (partially)
	ld   hl, $9C00 
	ld   bc, $0100
	ld   a, $7F
	call ClearRAMRange
	; Clear OAM
	ld   hl, $FE00 
	ld   bc, $0100
	call ClearRAMRange
	
;--
	; Clear HRAM up until the location of the OAMDMA code
	ld   hl, hJoyKeys  
	ld   b, $7E
	call ClearRAMRange_Mini 
	; Copy the OAMDMA code to HRAM
	ld   c, LOW(hOAMDMA) 				; C  = Starting address for the OAMDMA code in HRAM ($FFB6)
	ld   b, OAMDMACode_End - OAMDMACode	; B  = Size of the OAMDMA code 
	ld   hl, OAMDMACode  				; HL = Ptr to the OAMDMA code
.cpLoop:
	ldi  a, [hl]
	ld   [c], a
	inc  c
	dec  b
	jr   nz, .cpLoop
;--
	
	call ClearBGMap
	
	ld   a, $01 			; Set the default bank
	ld   [sROMBank], a
	
	; Stop whatever we were playing previously, in case of a soft-reset
	mHomeCall Sound_StopAllStub ; BANK 04
	
	xor  a					; Enable display
	ldh  [rIF], a 
	ld   a, I_VBLANK
	ldh  [rIE], a
	ld   a, LCDC_ENABLE
	ldh  [rLCDC], a
	; Set the initial game mode (title screen)
	xor  a
	ld   [sGameMode], a
	ld   [sSubMode], a
	ld   [sScreenUpdateMode], a
	ld   [sTitleRetVal], a
	xor  a					; Initialize new key status
	ldh  [hJoyNewKeys], a
	ei						; Enable the interrupts just before entering the main loop
	
; =========================================
; =============== MAIN LOOP ===============
; =========================================
MainLoop:
	; Poll for input
	call JoyKeys_Get
	
	; Soft reset check
	ld   a, [sNoReset]			; Is it disabled?
	and  a
	jr   nz, .skipResetChk		; If so, skip this
	ldh  a, [hJoyKeys] 			; Have we pressed *exactly* A+B+Start+Select?
	and  a, KEY_A|KEY_B|KEY_SELECT|KEY_START
	cp   a, KEY_A|KEY_B|KEY_SELECT|KEY_START
	jp   z, GameInit			; If so, reset the game
	
.skipResetChk:
	call CheckMode				; Do the game logic
	call FinalizeWorkOAM		; Clear unused OAM
	
	; Check if we have enough time before VBLANK to animate the tiles during gameplay
	; Because this is done during HBlank, this ends up taking a considerable amount of cycles
	; (which is why tile animation stops with lag)
	ldh  a, [rLY]
	cp   a, $80					; Do we have enough time (LY < $80)?
	jr   nc, .waitVBlank		; If not, skip this
	call HomeCall_Level_AnimTiles
	
	; Waiting for the VBlank handler to be processed.
	; This game holds the honour of... not using the halt instruction before this loop.
	; Yes, this game uses 100% of the CPU all the time.
	;
	; It's possible to fix this, but we have to take into considerations two things:
	; - The VBLANK handler may execute before we even get here.
	;   If we blindly halted before .waitVBlank, we could be waiting an extra frame.
	; - 'halt' also resumes execution when other interrupts are triggered (like LYC/LCDC for parallax effects).
	;   Most games wait in a loop for all parallax effects to be executed before getting here,
	;   but this one doesn't (since we aren't halt'ing to begin with).
	;   
	; To account for all of this, replace .waitVBlank with this:
	;.waitVBlank:
	;	ldh  a, [hVBlankDone]
	;	and  a
	;	jr   nz, .vBlankDone
	;	halt
	;	jr   .waitVBlank		; In case something other than VBLANK occurred
	;.vBlankDone:
	;
	
.waitVBlank:
	ldh  a, [hVBlankDone]
	and  a
	jr   z, .waitVBlank
	; Reset the vblank indicator and OAM pos immediately
	xor  a
	ldh  [hVBlankDone], a
	ld   [sWorkOAMPos], a
	
	; Increase global timer
	ld   hl, sTimer
	inc  [hl]
	
	; Execute the sound code immediately, so it won't be affected by any possible lag
	; Though it does mean rSX effects may occasionally look "wrong" near the top of the screen
	; Since every so often (generally around 7 frames) the sound engine will do its thing and take away cycles
	mHomeCall Sound_DoStub ; BANK 04
	
	;--
	; Handle the screen update reset.
	; Normally screen updates are valid for only 1 frame.
	;
	; HOWEVER, the "hat" modes are special as they switch to a different mode when they are done.
	; Both primary and secondary modes take multiple frames to complete, so they handle the reset in their own way.
	; We have to prevent the reset from happening in those cases.
	ld   a, [sScreenUpdateMode]
	cp   a, SCRUPD_NORMHAT 		; mode < SCRUPD_NORMHAT
	jr   c, .resetScrMode
	cp   a, SCRUPD_CREDITSBOX 	; mode <= SCRUPD_DRAGHAT_SEC
	jr   c, MainLoop
.resetScrMode:
	xor  a
	ld   [sScreenUpdateMode], a
	jr   MainLoop
	
; =============== Map_LevelIdCompletionAssocTbl ===============
; This table maps all levels in the game to a specific bit in a map completion bitmask.
;
; Note that, while the entries in the completion table are indexed by Level ID,
; a level may have a secondary exit which has its own completion bit.
; To account for this, the completion bit of a secondary exit is assumed to be
; one bit after the bit specified in this table for the main exit.
;
; This is accounted for in Map_SetLevelCompletionBitToMask.
;--
; Example: The exit for C03A defined as
;   lvlbcomp MAP_CLRB_RICEBEACH, 2
; The main level exit will use bit 2 of sMapRiceBeachCompletion,
; while its secondary level exit will implicitly use bit 3.
;--
;
; FORMAT:
; Each entry is one byte long with this format:
; - HIGH NYBBLE: Marks the "ID" of the bitmask, as used by Map_SetLevelCleared.
;                The ID values expected by the subroutine match the ones in MAP_CLRB_*
; - LOW NYBBLE: The bit number for the level, to mark in the specified bitmask.
;
; If the byte is $FF, no completion bit is associated (and the amount of cleared levels doesn't increase)
;
; [TCRF] Much like other tables dealing with maps, it contains entries for nonexisting levels,
;        up to $2F.
; 

; =============== lvlbcomp ===============
; Defines a bit in the level completion bitmask for above.
; IN
; - 1: Map completion bitmask id
; - 2: Bit number marking the level
lvlbcomp: MACRO
	db (\1 * $10)|(\2)
ENDM

Map_LevelIdCompletionAssocTbl: 
	lvlbcomp MAP_CLRB_SSTEACUP, 0		 ; LVL_C26      					
	lvlbcomp MAP_CLRB_PARSLEYWOODS, 2	 ; LVL_C33      
	lvlbcomp MAP_CLRB_SHERBETLAND, 1     ; LVL_C15      
	lvlbcomp MAP_CLRB_STOVECANYON, 0     ; LVL_C20      
	lvlbcomp MAP_CLRB_SHERBETLAND, 3     ; LVL_C16      
	lvlbcomp MAP_CLRB_MTTEAPOT, 4        ; LVL_C10      
	lvlbcomp MAP_CLRB_MTTEAPOT, 0        ; LVL_C07      
	lvlbcomp MAP_CLRB_RICEBEACH, 0       ; LVL_C01A     
	lvlbcomp MAP_CLRB_SHERBETLAND, 5     ; LVL_C17      
	lvlbcomp MAP_CLRB_MTTEAPOT, 6        ; LVL_C12      
	lvlbcomp MAP_CLRB_MTTEAPOT, 7        ; LVL_C13      
	lvlbcomp MAP_CLRB_SSTEACUP, 3        ; LVL_C29      
	lvlbcomp MAP_CLRB_RICEBEACH, 4       ; LVL_C04      
	lvlbcomp MAP_CLRB_MTTEAPOT, 3        ; LVL_C09      
	lvlbcomp MAP_CLRB_RICEBEACH, 2       ; LVL_C03A     
	lvlbcomp MAP_CLRB_RICEBEACH, 1       ; LVL_C02      
	lvlbcomp MAP_CLRB_MTTEAPOT, 1        ; LVL_C08      
	lvlbcomp MAP_CLRB_MTTEAPOT, 5        ; LVL_C11      
	lvlbcomp MAP_CLRB_PARSLEYWOODS, 4    ; LVL_C35      
	lvlbcomp MAP_CLRB_PARSLEYWOODS, 3    ; LVL_C34      
	lvlbcomp MAP_CLRB_SSTEACUP, 4        ; LVL_C30      
	lvlbcomp MAP_CLRB_STOVECANYON, 1     ; LVL_C21      
	lvlbcomp MAP_CLRB_STOVECANYON, 2     ; LVL_C22      
	db $FF                               ; LVL_C01B     
	lvlbcomp MAP_CLRB_SHERBETLAND, 7     ; LVL_C19      
	lvlbcomp MAP_CLRB_RICEBEACH, 5       ; LVL_C05      
	lvlbcomp MAP_CLRB_PARSLEYWOODS, 5    ; LVL_C36      
	lvlbcomp MAP_CLRB_STOVECANYON, 5     ; LVL_C24      
	lvlbcomp MAP_CLRB_STOVECANYON, 6     ; LVL_C25      
	lvlbcomp MAP_CLRB_PARSLEYWOODS, 1    ; LVL_C32      
	lvlbcomp MAP_CLRB_SSTEACUP, 1        ; LVL_C27      
	lvlbcomp MAP_CLRB_SSTEACUP, 2        ; LVL_C28      
	lvlbcomp MAP_CLRB_SHERBETLAND, 6     ; LVL_C18      
	lvlbcomp MAP_CLRB_SHERBETLAND, 0     ; LVL_C14      
	lvlbcomp MAP_CLRB_SYRUPCASTLE, 1     ; LVL_C38      
	lvlbcomp MAP_CLRB_SYRUPCASTLE, 2     ; LVL_C39      
	lvlbcomp MAP_CLRB_RICEBEACH, 2       ; LVL_C03B     
	lvlbcomp MAP_CLRB_SYRUPCASTLE, 0     ; LVL_C37      
	lvlbcomp MAP_CLRB_PARSLEYWOODS, 0    ; LVL_C31A     
	lvlbcomp MAP_CLRB_STOVECANYON, 3     ; LVL_C23      
	db $FF;X                             ; LVL_C40	; [TCRF] Course 40 can't be cleared normally,  but it wouldn't do anything special as-is since it doesn't go through the same level clear mode.  
	lvlbcomp MAP_CLRB_RICEBEACH, 6       ; LVL_C06      
	lvlbcomp MAP_CLRB_PARSLEYWOODS, 0    ; LVL_C31B     
	db $FF;X                             ; LVL_UNUSED_2B
	db $FF;X                             ; LVL_UNUSED_2C
	db $FF;X                             ; LVL_UNUSED_2D
	db $FF;X                             ; LVL_UNUSED_2E
	db $FF;X                             ; LVL_UNUSED_2F

; =============== Save_CopyAllToSave ===============
; This subroutine saves the game.
; It copies all data from memory to the the entered save file.
Save_CopyAllToSave:
	; Avoid saving the game in demo mode
	; (sSoundDisable is only set there during level loading)
	ld   a, [sSoundDisable]
	and  a
	ret  nz
	
	ld   a, $01
	ld   [sNoReset], a
	
	call SaveSel_GetSaveDataPtr		
	push hl							
	;--
	; Skip signature
	inc  hl
	inc  hl
	inc  hl
	inc  hl
	; Copy all data to the save
	ld   a, [sLevelId]
	ldi  [hl], a
	ld   a, [sTotalCoins_High]
	ldi  [hl], a
	ld   a, [sTotalCoins_Mid]
	ldi  [hl], a
	ld   a, [sTotalCoins_Low]
	ldi  [hl], a
	ld   a, [sHearts]
	ldi  [hl], a
	ld   a, [sLives]
	ldi  [hl], a
	ld   a, [sPlPower]
	ldi  [hl], a
	ld   a, [sMapRiceBeachCompletion]
	ldi  [hl], a
	ld   a, [sMapMtTeapotCompletion]
	ldi  [hl], a
	ld   a, [sLevelsCleared]
	ldi  [hl], a
	ld   a, [sTreasures]
	ldi  [hl], a
	ld   a, [sTreasures+1]
	ldi  [hl], a
	ld   a, [sMapStoveCanyonCompletion]
	ldi  [hl], a
	ld   a, [sMapSSTeacupCompletion]
	ldi  [hl], a
	ld   a, [sMapParsleyWoodsCompletion]
	ldi  [hl], a
	ld   a, [sMapSherbetLandCompletion]
	ldi  [hl], a
	ld   a, [sMapSyrupCastleCompletion]
	ldi  [hl], a
	ld   a, [sCheckpoint]
	ldi  [hl], a
	ld   a, [sCheckpointLevelId]
	ldi  [hl], a
	ld   a, [sGameCompleted]
	ldi  [hl], a
	pop  hl
	
	
	push hl
	;--
	; Sync the backup save
	ld   b, $20		; B = Bytes to copy
	ld   d, h		; DE = Destination (HL + $20, the backup save)
	ld   a, l		
	add  b			; (e = l + $20)
	ld   e, a
	call CopyBytes
	;--
	pop  hl
	
	call SaveSel_UpdateChecksum
	xor  a
	ld   [sNoReset], a
	ret
	
; =============== Game_SetFinalBossDoorPtr ===============
; Forces the last entered door to be the final boss door.
; [POI] What's the point of this again?
;       This is only called after defeating the final boss, and to get
;       there we must have entered the boss door before.
;       The level door ptr is already the correct Door_C40_04 as a result.
Game_SetFinalBossDoorPtr:
	; [POI] There's no reason to bankswitch just for this.
	ld   a, [sROMBank]
	push af
	ld   a, BANK(Door_C40_04)
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	;--
	ld   a, HIGH(Door_C40_04)
	ld   [sLvlDoorPtr], a
	ld   a, LOW(Door_C40_04)
	ld   [sLvlDoorPtr+1], a
	;--
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	ret
	
; =============== Game_Add10Hearts ===============
; This subroutine gives the player 10 hearts, and redraws the status bar.
Game_Add10Hearts:
	ld   a, SFX1_04				; Play heart SFX
	ld   [sSFX1Set], a
	
	ld   a, [sHearts]			; sHearts += 10
	add  $0A
	daa
	ld   [sHearts], a
	
	call c, Game_Add1UP			; If we went past 99, give 1up
	call StatusBar_DrawHearts
	ret
; =============== Game_Add1Heart ===============
; This subroutine gives the player 1 heart, and redraws the status bar.
; Used when defeating an enemy, which already plays another SFX.
Game_Add1Heart:
	ld   a, [sHearts]			; sHearts++
	add  $01
	daa
	ld   [sHearts], a
	
	call c, Game_Add1UP			; If we went past 99, give 1up
	call StatusBar_DrawHearts
	ret
; =============== Game_Add1UP ===============
; This subroutine gives the player 1 life, and redraws the status bar.
Game_Add1UP:
	ld   a, [sLives]			; sLives++
	add  $01
	daa
	ld   [sLives], a
	
	jr   c, .capLives			; If we went past 99, cap it
	call StatusBar_DrawLives
	
	ld   a, SFX1_08				; Play 1-up SFX (will override other SFX)
	ld   [sSFX1Set], a
	;--
	; Spawn "1UP" indicator
	ld   a, EXACT_1UPMARKER		; ExActor ID
	ld   [sExActSet], a
	ld   b, 2*BLOCK_HEIGHT		; Y Pos: 20px (or 2 blocks) above player
	call PlTarget_SetUpPos
	ld   a, [sTarget_High]
	ld   [sExActOBJY_High], a
	ld   a, [sTarget_Low]
	ld   [sExActOBJY_Low], a
	ld   a, [sPlX_High]		; X Pos: Same as player
	ld   [sExActOBJX_High], a
	ld   a, [sPlX_Low]
	ld   [sExActOBJX_Low], a
	ld   a, OBJ_1UP				; OBJ Frame	
	ld   [sExActOBJLstId], a
	xor  a						; Flags
	ld   [sExActOBJFlags], a
	; Clear rest of space
	ld   hl, sExActLevelLayoutPtr_High
	xor  a
	ld   b, $09
	call ClearRAMRange_Mini
	call ExActS_Spawn
	;--
	ret
.capLives:
	ld   a, $99					; Cap to 99 hearts
	ld   [sHearts], a
	call StatusBar_DrawHearts
	ld   a, $99					; Cap to 99 lives
	ld   [sLives], a
	call StatusBar_DrawLives
	ret
; =============== Game_Add3UP ===============
; This subroutine gives the player 3 lives, and redraws the status bar.
Game_Add3UP:
	ld   a, [sLives]		; sLives += $03
	add  $03
	daa
	ld   [sLives], a
	
	jr   nc, .draw			; If we didn't go past 99 lives, jump
.capLives:
	ld   a, $99				; Cap to 99 hearts
	ld   [sHearts], a
	call StatusBar_DrawHearts
	ld   a, $99				; Cap to 99 lives
	ld   [sLives], a
.draw:
	call StatusBar_DrawLives
	ld   a, SFX1_08			; Play 1-up SFX
	ld   [sSFX1Set], a
	;--
	; Spawn "3UP" indicator
	; Same ExActor ID as 1UP indicator, except with a different frame
	ld   a, EXACT_1UPMARKER		; ExActor ID
	ld   [sExActSet], a
	ld   b, 2*BLOCK_HEIGHT		; Y Pos: 20px (or 2 blocks) above player
	call PlTarget_SetUpPos
	ld   a, [sTarget_High]
	ld   [sExActOBJY_High], a
	ld   a, [sTarget_Low]
	ld   [sExActOBJY_Low], a
	ld   a, [sPlX_High]		; X Pos: Same as player
	ld   [sExActOBJX_High], a
	ld   a, [sPlX_Low]
	ld   [sExActOBJX_Low], a
	ld   a, $C4
	ld   [sExActOBJLstId], a
	xor  a
	ld   [sExActOBJFlags], a
	; Clear rest of space
	ld   hl, sExActLevelLayoutPtr_High
	xor  a
	ld   b, $09
	call ClearRAMRange_Mini
	call ExActS_Spawn
	;--
	ret
; =============== ActS_SpawnBlockBreak ===============
; Spawns the actors (debris; optional coin) after destroying a block.
ActS_SpawnBlockBreak:
	;--
	; If somehow three blocks are destroyed at once, don't spawn anything
	ld   a, [sPlBreakCombo]
	inc  a				; Combo++
	cp   a, $03
	jr   z, .end
	ld   [sPlBreakCombo], a
	;--
	
	call ExActS_CopySetToSet2
	; Spawn the debris based on the block's coords
	ld   a, EXACT_BLOCKSMASH
	ld   [sExActSet], a
	
	mExActS_SetCenterBlock
	
	ld   a, OBJ_BLOCKSMASH0
	ld   [sExActOBJLstId], a
	ld   a, $00
	ld   [sExActOBJFlags], a
	ld   a, [sBlockTopLeftPtr_High]
	ld   [sExActLevelLayoutPtr_High], a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   [sExActLevelLayoutPtr_Low], a
	; Clear rest of ExActSet
	ld   hl, sExActRoutineId
	xor  a
	ld   b, $07
	call ClearRAMRange_Mini
	call ExActS_Spawn
	; Only occasionally spawn a coin (50% chance, 25% timer chance)
	ld   a, [sTimer]
	and  a, $03				; Timer % 4 != 0?
	jr   nz, .noCoin		; If so, skip
	ldh  a, [rDIV]
	and  a, $01				; 50% chance
	jr   nz, .noCoin
	call SubCall_ActS_SpawnCoinFromBlock
.noCoin:
	call ExActS_CopySet2ToSet
.end:
	; Play the block smash SFX (replacing any SFX4_0A in the process).
	; The placement of this operation is weird; suggesting it was done later.
	ld   a, SFX4_0B
	ld   [sSFX4Set], a
	ret
; =============== ExActS_CopySetToSet2 ===============	
; Copies ExAct data from the main 'Set' area to the secondary 'Set' area.
ExActS_CopySetToSet2:
	ld   hl, sExActSet		; HL = Source
	ld   de, sExActSet2		; DE = Destination
	ld   b, $10
	call CopyBytes
	ret
; =============== ExActS_CopySet2ToSet ===============	
; Copies ExAct data from the secondary 'Set' area to the main 'Set' area.
ExActS_CopySet2ToSet:
	ld   hl, sExActSet2
	ld   de, sExActSet
	ld   b, $10
	call CopyBytes
	ret
	
; =============== GetCourseNum ===============
; Gets the course number for the current level ID.
;
; This subroutine maps course numbers for all valid level IDs.
;
; There is an unnecessary use of rst $28 (could have been directly a table)
; which not only is a waste of space/time, but invalid levels will instantly 
; crash the game when trying to get their course number (which leaves out
; certain other failsafes impossible to trigger)
;
; OUT
; - A: Course number in BCD format
GetCourseNum:
	ld   a, [sLevelId]
	rst  $28
	dw .c26
	dw .c33
	dw .c15
	dw .c20
	dw .c16
	dw .c10
	dw .c07
	dw .c01
	dw .c17
	dw .c12
	dw .c13
	dw .c29
	dw .c04
	dw .c09
	dw .c03
	dw .c02
	dw .c08
	dw .c11
	dw .c35
	dw .c34
	dw .c30
	dw .c21
	dw .c22
	dw .c01
	dw .c19
	dw .c05
	dw .c36
	dw .c24
	dw .c25
	dw .c32
	dw .c27
	dw .c28
	dw .c18
	dw .c14
	dw .c38
	dw .c39
	dw .c03
	dw .c37
	dw .c31
	dw .c23
	dw .c40
	dw .c06
	dw .c31
.c01:
	ld   a, $01
	ret
.c02:
	ld   a, $02
	ret
.c03:
	ld   a, $03
	ret
.c04:
	ld   a, $04
	ret
.c05:
	ld   a, $05
	ret
.c06:
	ld   a, $06
	ret
.c07:
	ld   a, $07
	ret
.c08:
	ld   a, $08
	ret
.c09:
	ld   a, $09
	ret
.c10:
	ld   a, $10
	ret
.c11:
	ld   a, $11
	ret
.c12:
	ld   a, $12
	ret
.c13:
	ld   a, $13
	ret
.c14:
	ld   a, $14
	ret
.c15:
	ld   a, $15
	ret
.c16:
	ld   a, $16
	ret
.c17:
	ld   a, $17
	ret
.c18:
	ld   a, $18
	ret
.c19:
	ld   a, $19
	ret
.c20:
	ld   a, $20
	ret
.c21:
	ld   a, $21
	ret
.c22:
	ld   a, $22
	ret
.c23:
	ld   a, $23
	ret
.c24:
	ld   a, $24
	ret
.c25:
	ld   a, $25
	ret
.c26:
	ld   a, $26
	ret
.c27:
	ld   a, $27
	ret
.c28:
	ld   a, $28
	ret
.c29:
	ld   a, $29
	ret
.c30:
	ld   a, $30
	ret
.c31:
	ld   a, $31
	ret
.c32:
	ld   a, $32
	ret
.c33:
	ld   a, $33
	ret
.c34:
	ld   a, $34
	ret
.c35:
	ld   a, $35
	ret
.c36:
	ld   a, $36
	ret
.c37:
	ld   a, $37
	ret
.c38:
	ld   a, $38
	ret
.c39:
	ld   a, $39
	ret
.c40:
	ld   a, $40
	ret
	
; =============== Level_Scroll_AddBGPtrCol ===============
; This subroutine adds BG ptrs for a column of $0D blocks.
; Meant to be used for level scrolling.
;
; IN
; - HL: Ptr to VRAM address
Level_Scroll_AddBGPtrCol:
	ld   b, $0D				; B = Blocks ptrs to write
	
; =============== Level_Scroll_AddBGPtrCol2 ===============
; IN
; - HL: Ptr to VRAM address
; -  B: Block count in column
Level_Scroll_AddBGPtrCol2:
	ld   d, h		; DE = Source
	ld   e, l
	ld   hl, sLvlScrollBGPtrWriteTable ; HL = Destination
.nextBlock:
	; Copy directly the pointer
	ld   a, d
	ldi  [hl], a
	ld   a, e
	ldi  [hl], a
	
	;--
	; DE += $40
	; Add 2 full rows of tiles to move down
	add  $40			
	ld   e, a			
	jr   nc, .checkNext	; Did we overflow?
	; If so, ccount for it
	inc  d
	ld   a, d
	;--
	
	; TILEMAP Y WRAPPING
	
	; Did we go past the bottom of the BG tilemap?
	cp   a, HIGH(BGMap_End)
	jr   nz, .checkNext
	; If so, wrap it back to the top
	ld   d, HIGH(BGMap_Begin)
.checkNext:
	dec  b					; Did we copy all ptrs?
	jr   nz, .nextBlock		; If not, loop
	ld   [hl], $FF			; Otherwise write the end separator to the table
	ret
	
; =============== Level_Scroll_AddColPtrsAndApply ===============
; Adds a column of $0D blocks to the level layout and writes the updated tiles.
; Meant to be used after Level_Scroll_AddColumnTileId.
; IN
; - HL: BGMap ptr for the block passed to Level_Scroll_AddColumnTileId
Level_Scroll_AddColPtrsAndApply:
	call Level_Scroll_AddBGPtrCol
	call HomeCall_ScreenEvent_Mode_LevelScroll
	ret
	
; =============== Level_Scroll_AddBlockIDsCol ===============
; This subroutine adds a column of $0D block IDs to the block ID write list.
; Meant to be used for level scrolling.
;
; Note that this data cannot be used directly.
; The subroutine which updates the level scroll, ScreenEvent_Mode_LevelScroll
; only deals with 8x8 tiles.
; Call Level_Scroll_CreateTileIdList to generate the 8x8 tiles from this block list.
;
; IN
; - HL: Ptr to the level layout
Level_Scroll_AddBlockIDsCol:
	ld   b, $0D		; B  = Blocks to copy
; =============== Level_Scroll_AddBlockIDsCol2 ===============
; IN
; - HL: Ptr to the level layout
; -  B: Blocks to copy
Level_Scroll_AddBlockIDsCol2:
	ld   de, sLvlScrollBlockTable
.loop:
	ld   a, [hl]	; Copy block ID over (without actor flag)
	and  a, $7F
	ld   [de], a
	inc  e			; Next table entry
	inc  h			; Move 1 block down in the level layout ($100 bytes)
	
	dec  b			; Are we done yet?
	jr   nz, .loop	; If not, loop
	ld   a, $FF		; Add the end terminator
	ld   [de], a
	ret
	
; =============== Level_Scroll_CreateTileIdList ===============
; This subroutine converts the block ID list in sLvlScrollBlockTable
; to a list of 8x8 tiles for the screen event code.
Level_Scroll_CreateTileIdList:
	; Set the ptr to the start of the tile id table
	ld   a, HIGH(sLvlScrollTileIdWriteTable)
	ld   [sLvlScrollSourcePtr_High], a
	ld   a, LOW(sLvlScrollTileIdWriteTable)
	ld   [sLvlScrollSourcePtr_Low], a
	
	ld   bc, sLvlScrollBlockTable
	ld   a, [bc]					; A = Block ID
.nextBlock:
	; Get the index to the 16x16 block defn array,
	; A block has 4 tiles, so multiply it by that
	
	; DE = BlockId * 4
	ld   d, $00						
	ld   e, a						
	sla  e
	rl   d
	sla  e
	rl   d
	
	; Offset the block defn
	ld   hl, sLevelBlocks
	add  hl, de
	
	; DE = >= sLvlScrollTileIdWriteTable
	ld   a, [sLvlScrollSourcePtr_High]
	ld   d, a
	ld   a, [sLvlScrollSourcePtr_Low]
	ld   e, a
	add  $04							; We're adding 4 tiles
	ld   [sLvlScrollSourcePtr_Low], a
	jr   nc, .copyTiles
	; [TCRF] We never get here; there's no way to reach $AD00
	inc  d
	ld   a, d
	ld   [sLvlScrollSourcePtr_High], a
.copyTiles:
	; Copy the 4 tiles from the block def in order
	ldi  a, [hl]	; Top-left
	ld   [de], a
	inc  de
	ldi  a, [hl]	; Top-right
	ld   [de], a
	inc  de
	ldi  a, [hl]	; Bottom-left
	ld   [de], a
	inc  de
	ldi  a, [hl]	; Bottom-right
	ld   [de], a
	inc  bc				; Read the next block ID
	ld   a, [bc]		
	cp   a, $FF			; Is it the end separator?
	jr   nz, .nextBlock	; If not, loop
	
	; Request screen update
	ld   a, SCRUPD_SCROLL
	ld   [sScreenUpdateMode], a
	ret

; =============== Level_Scroll_AddColumnTileId ===============
; Adds a column of $0D blocks to the tile update list.
; IN
; - HL: Ptr to the topmost block of the column from the level layout
Level_Scroll_AddColumnTileId:
	call Level_Scroll_AddBlockIDsCol
	call Level_Scroll_CreateTileIdList
	ret
	
; =============== GetBGMapOffsetFromBlock ===============
; This subroutine calculates the tilemap offset (top left corner) for any given
; 16x16 block in the level layout.
;
; For this whole thing to work, the game uses a very specific level size.
; which allows a ptr to the level layout (-$C000) to act as a set of coordinates.
; As a result:
; - H: Y pos of block (total 16x16 blocks above)
; - L: X pos of block (total 16x16 blocks to the left)
;
; To calculate the tilemap offset, we need to multiply each of these coordinates
; by a certain amount, then add the result together.
;
; IN
; - HL: Ptr to a block in the level layout
; OUT
; - HL: Ptr to tilemap
; - sBGTmpPtr: Same as HL
GetBGMapOffsetFromBlock:
	;
	; Y OFFSET
	; 
	
	; Multiplier: $40 ($20 * $02)
	;
	; $20 -> tilemap width
	; $02 -> block height
	;
	; To avoid the result from overflowing, this will be later be % $400
	
	
	; First remove the wLevelLayout base to get the actual coordinate
	ld   a, h					
	sub  a, HIGH(wLevelLayout)
	ld   h, a
	xor  a			
	
	; DE = BlockOffsetHigh * $40
	; while passing through A since we need the carry
	ld   d, a		; D = 0
	ld   b, $06		; B = Loop count
.shiftLoop:
	sla  a			; (carry) << 1
	sla  h			; << 1
	adc  a, d		; add carry
	dec  b
	jr   nz, .shiftLoop
	ld   d, a		
	ld   e, h
	
	
	;
	; X OFFSET
	;
	
	; Multiplier: $2
	; - $02: block is 2 tiles large
	;
	; We only care about the relative X position over a $20 tile boundary.
	; Since a block is 2 tiles large, every $10 blocks we reach a new Y offset.
	;
	;
	; L = (BlockOffset & $0F) * 2
	ld   a, l
	and  a, $0F
	add  a
	ld   l, a
	
	; Sum all together
	ld   h, HIGH(BGMap_Begin)		; += $9800
	add  hl, de
	
	; The Y coord multiplication can bring the ptr out of range.
	; Decrement it by $400 (size of a full tilemap) until it gets back in range.
.fixLoop:
	ld   a, h
	cp   a, HIGH(BGMap_End)	; Is HL > $9C00?
	jr   c, .end			; If not, we're done
	sub  a, $04				; Otherwise, decrement by $04 and check again
	ld   h, a
	jr   .fixLoop
.end:
	ld   [sBGTmpPtr], a		; Save the ptr
	ld   a, l
	ld   [sBGTmpPtr+1], a
	ret
	
; =============== Level_DrawFullScreen ===============
; This subroutine draws the entire visible screen to the tilemap.
; Used for room transitions.
;
Level_DrawFullScreen:
	; Calculate the offset to the block in the level layout
	; This block is the first (top-left) block which can be seen with the scroll position
	
	; Since a single block is 16x16px, to get the amount of blocks on the left or on the top:
	; sLvlScrollRaw / 16
	; To work as-is with both coordinates, this requires a fixed level width of $1000 px ($100 blocks).
	
	
	; Y BLOCK COUNT
	
	; We need to divide the entire word value by 16 and fit it into a single byte.
	; Dividing by 16 (sLvlScrollYRaw_Low >> 4) gets rid of a nybble in the low byte
	ld   a, [sLvlScrollYRaw_Low]		
	swap a								; H = SYLow >> 4
	and  a, $0F
	ld   h, a
	; While in the high byte, only the low nybble is usable since levels aren't that tall.
	ld   a, [sLvlScrollYRaw_High]		
	and  a, $0F							; A = SYHigh << 4
	swap a
	; Merge the two remaining nybbles together and we have the Y block count in H
	add  h
	ld   h, a
	
	; X BLOCK COUNT
	; Do the same thing
	ld   a, [sLvlScrollXRaw_Low]
	swap a								; L = SXLow >> 4
	and  a, $0F
	ld   l, a
	; Since levels have fixed $1000 size, block X coords go from $0000-$0FFF
	; so the upper nybble of sLvlScrollXRaw_High can be ignored
	ld   a, [sLvlScrollXRaw_High]
	and  a, $0F							; A = SXHigh << 4
	swap a
	add  l
	ld   l, a
	
	; Index the first block seen in the top-left corner of the screen
	ld   de, wLevelLayout
	add  hl, de
	
	; Get the tilemap from the level layout offset
	ld   a, h			
	ld   [sBlockTopLeftPtr_High], a
	ld   a, l
	ld   [sBlockTopLeftPtr_Low], a
	call GetBGMapOffsetFromBlock
	
	; By default, write $0C columns when loading a new room
	ld   a, $0C
	ld   [sLvlScrollColsLeft], a
	
	
	; Check if the scroll mode is an autoscrolling mode with special parallax ($30 or $31)
	ld   a, [sLvlScrollMode]
	cp   a, $30					; Scroll mode < $30?
	jr   c, .loop				; If so, jump
	cp   a, $40					; Scroll mode >= $40?
	jr   nc, .loop				; If so, jump
.autoscroll:
	; The autoscrolling modes $30 and $31 have a parallax layer at the top of the screen
	; which scrolls the same row over and over.
	;
	; Because of this, the top left coordinate should always point
	; at the beginning of a $20 tile boundary ($10 blocks)
	ld   a, $10						; Copy full width worth of blocks immediately
	ld   [sLvlScrollColsLeft], a
	
	ld   a, [sBlockTopLeftPtr_Low]	; Align it to the boundary
	and  a, $F0
	ld   [sBlockTopLeftPtr_Low], a
	ld   l, a
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a							
	call GetBGMapOffsetFromBlock	; Update the value too
.loop:
	; Request screen update of a column of $0D tiles
	; starting from the specified top left corner
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	call Level_Scroll_AddColumnTileId
	
	; Set the VRAM ptrs for the above column
	; Starting from the BGMap ptr the above top-left block points to
	ld   a, [sBGTmpPtr]
	ld   h, a
	ld   a, [sBGTmpPtr+1]
	ld   l, a
	call Level_Scroll_AddColPtrsAndApply
	
	ld   a, [sLvlScrollColsLeft]		; ColumnsLeft--;
	dec  a
	ld   [sLvlScrollColsLeft], a		
	ret  z								; Are we done?
	
	; If not, prepare next column
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	ld   a, [sBlockTopLeftPtr_Low]
	inc  a
	ld   [sBlockTopLeftPtr_Low], a
	ld   l, a
	call GetBGMapOffsetFromBlock
	jr   .loop
; =============== Level_EnterDoor ===============
; This subroutine gets the pointer to the room header, then triggers the room transition.
; This is determined by the current scroll location in the level.
Level_EnterDoor:
	;------------------
	ld   a, [sROMBank]
	push af
	ld   a, $0C
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	;------------------
	
	; Generate the base index for the level in the ptr table
	
	; The ptr table must allow all sectors in the level layout to have a room transition assigned.
	;
	; The level size is $1000 * $200, so the sector count is $10 * 2 = 32.
	; The ptr table adds a *2 multiplier, so the final result is:
	; DE = sLevelId << 6  (*64)
	ld   d, $00
	ld   a, [sLevelId]
	ld   e, a
REPT 6
	sla  e
	rl   d
ENDR
	; Index the first room of the level
	ld   hl, Level_DoorHeaderPtrTable
	add  hl, de
	
	;--
	; Offset the current room based on scroll coordinates
	;
	; What this does is merge the "nybbles" together
	; since both high coords are assumed to be in range $0-$F.
	; E = (sLvlScrollY)(sLvlScrollX)
	
	; [BUG] This should really be based on Wario's coordinates like in later games
	;       Which would kill off any attempts at wrong warping.
	
	; [BUG2] While obviously you aren't intended to go there,
	;        this does not account for going into the loopback area.
	;		 The Y and X positions are assumed to be in range, so they don't get and'ed unlike other places.
	
	ld   a, [sLvlScrollY_High]	; Y: High nybble
	swap a						; << 4
	ld   b, a
	ld   a, [sLvlScrollX_High]	; X: Low nybble
	add  b
	add  a						; *2 for ptr table
	ld   e, a
	ld   d, $00
	add  hl, de					; Index the actual room ptr
	
	ldi  a, [hl]				; And store it to HL
	ld   h, [hl]
	ld   l, a
	ld   b, [hl]				; B = First byte
	;------------------
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	;------------------
	
	; Normally the first byte in the header determines Wario's X high position.
	; It can also be a special value if it is any of these:
	; (NOTE: see "Magic Transitions" in bank $0C for the origin of these constants)
	ld   a, b
	cp   a, DOORSPEC_ENTRANCE	; Door_LevelEntrance
	jr   z, Level_EnterEntranceDoor
	cp   a, DOORSPEC_LVLCLEAR ; Door_LevelClear
	jp   z, Level_EnterClearDoor
	cp   a, DOORSPEC_LVLCLEARALT ; Door_LevelClearAlt
	jr   z, Level_EnterAltClearDoor
	cp   a, DOORSPEC_INVALID				; Don't do anything for values > $23
	ret  nc
.normal:
	ld   a, h				; Save the room ptr
	ld   [sLvlDoorPtr], a
	ld   a, l
	ld   [sLvlDoorPtr+1], a
	ld   a, GM_LEVELDOOR	; Set room transition
	ld   [sGameMode], a
	xor  a
	ld   [sPlDragonHatActive], a
	ld   hl, sPlFlags		; Reset palette if we're flashing
	res  4, [hl]
	ret
	
; =============== Level_GetTreasureDoorPtr ===============
; This subroutine gets the pointer to the room header used when returning from the treasure room.
; These room headers always place Wario on top of the treasure chest.
Level_GetTreasureDoorPtr:
	ld   a, [sROMBank]
	push af
	ld   a, $0C
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	;------------------
	; Index the room ptr table by treasure id
	ld   hl, Level_DoorHeaders_TreasurePtrs
	ld   a, [sTreasureId]	; DE = (sTreasureId-1)*2
	dec  a
	add  a
	ld   e, a
	ld   d, $00
	add  hl, de				; Offset the ptr table
	
	ldi  a, [hl]			; HL = Ptr to room header
	ld   h, [hl]
	ld   l, a
	
	ld   a, h				; Store it
	ld   [sLvlDoorPtr], a	
	ld   a, l
	ld   [sLvlDoorPtr+1], a
	;--
	; Restore the player's status from the opt table
	ld   hl, Game_PowerupStatePtrTbl
	ld   a, [sPlPower]
	add  a					; DE = sPlPower * 2
	ld   e, a
	ld   d, $00
	add  hl, de
	
	ldi  a, [hl]			; HL = Ptr to powerup data
	ld   h, [hl]
	ld   l, a
	
	ldi  a, [hl]			; Import the data over
	ld   [sSmallWario], a
	ldi  a, [hl]
	ld   [sPlLstId], a
	;--
	xor  a
	ld   [s_X_A917], a
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	ret
; =============== Level_EnterEntranceDoor ===============
; This subroutine starts the level exit transition for entering the entrance door.
Level_EnterEntranceDoor:
	; Stop flashing if we're flashing
	ld   a, [sPlFlags]		
	res  OBJLSTB_OBP1, a
	ld   [sPlFlags], a
	
	; Kill dragon flame
	xor  a
	ld   [sPlDragonHatActive], a
	ld   [sHurryUp], a
	; New mode
	ld   a, GM_LEVELENTRANCE
	ld   [sGameMode], a
	xor  a
	ld   [sSubMode], a
	; Fade out music
	ld   a, BGMACT_FADEOUT
	ld   [sBGMActSet], a
	ret
	
; =============== Level_EnterAltClearDoor ===============
; This subroutine starts the level clear transition for entering the skull door.
; This is for entering the door for the alternate exit.
Level_EnterAltClearDoor:
	ld   a, $01
	ld   [sAltLevelClear], a
; =============== Level_EnterClearDoor ===============
; This subroutine starts the level clear transition for entering the skull door.
Level_EnterClearDoor:
	ld   a, [sPlFlags]
	res  OBJLSTB_OBP1, a		; Reset pal
	ld   [sPlFlags], a
	xor  a
	ld   [sPlDragonHatActive], a
	ld   [sCheckpoint], a
	ld   [sHurryUp], a
	ld   [sExActCount], a
	xor  a
	ld   [sSubMode], a
	ld   a, GM_LEVELCLEAR
	ld   [sGameMode], a
	ld   a, BGM_LEVELCLEAR
	ld   [sBGMSet], a
	
	; If we are in a boss room, play the special SFX for clearing a boss
	; (ie: Sherbet Land boss door)
	ld   a, [sLvlSpecClear]
	cp   a, LVLCLEAR_BOSS
	ret  nz
	ld   a, BGM_BOSSCLEAR
	ld   [sBGMSet], a
	ret
	
; =============== Pl_SwitchToActBumpAction ===============
; Switches the player to the (ground) bump action.
Pl_SwitchToActBumpAction:
	ld   a, OBJ_WARIO_BUMP
	ld   [sPlLstId], a
; =============== Pl_SwitchToActBumpAction2 ===============
; Same as above, but without updating the frame.
; Used when bumping against an actor during a dash.
Pl_SwitchToActBumpAction2:
	ld   a, $10
	ld   [sPlDashHitTimer], a
	ld   a, PL_ACT_ACTMAIN
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	ret
; =============== Level_ScreenLock_IndexScreen ===============
; Indexes the specified screen lock data for the current screen number. 
; IN
; - HL: Ptr to screen lock data
; OUT
; - HL: Ptr to current screen lock value
Level_ScreenLock_IndexScreen:
	; Generate the screen number from the high coordinates
	ld   a, [sLvlScrollY_High]	; high nybble
	swap a						; << 4 (Expected range: $0-1)
	ld   b, a
	ld   a, [sLvlScrollX_High]	; low nybble (Expected range: $0-F)
	add  b				
	
	; Offset the screen lock table
	ld   e, a					
	ld   d, $00
	add  hl, de					
	ret
	
; =============== Level_Unused_Scroll_GetXBlockOffset ===============
; [TCRF] Happens to be unreferenced.
; Gets the X component (low byte) of the offset to the level layout data,
; based on the player's scroll position.
Level_Unused_Scroll_GetXBlockOffset:
	ld   hl, sPlX_High
	jr   Level_GetXBlockOffset
	
; =============== Level_Scroll_GetXBlockOffset ===============
; Gets the X component (low byte) of the offset to the level layout data,
; based on the current scroll position.
Level_Scroll_GetXBlockOffset:
	ld   hl, sLvlScrollX_High
	jr   Level_GetXBlockOffset
	
; =============== PlBGColi_GetXBlockOffset ===============
; Gets the X component (low byte) of the offset to the level layout data,
; based on the tile collision check position.
PlBGColi_GetXBlockOffset:
	ld   hl, sTarget_High
	
; =============== Level_GetXBlockOffset ===============
; Standalone subroutine for getting the X component (low byte) 
; of an offset to the level layout data.
; This divides by 16 the data pointed to by HL.
;
; Meant to be used with Level_GetYBlockOffset to get the full offset.
; See also: Level_DrawFullScreen.
;
; IN
; - HL: Ptr to a 2-byte X pos
; OUT
; - L: Low byte of a block offset to level layout data
Level_GetXBlockOffset:
	; Read the X coordinate to DE
	ldi  a, [hl]	; high byte
	ld   d, a
	ld   e, [hl]	; low byte
	ld   a, e
	
	; Divide by 16 the coord. to get the offset
	swap a
	and  a, $0F		; L = E >> 4
	ld   l, a
	ld   a, d		; A = D << 4
	and  a, $0F		
	swap a
	add  l		; Sum the nybbles
	ld   l, a
	ret
; =============== Level_Unused_Scroll_GetYBlockOffset ===============
; [TCRF] Happens to be unreferenced.
; Gets the Y component (high byte) of the offset to the level layout data,
; based on the player's scroll position.
Level_Unused_Scroll_GetYBlockOffset:
	ld   hl, sPlY_High
	jr   Level_GetYBlockOffset
	
; =============== Level_Scroll_GetYBlockOffset ===============
; Gets the Y component (high byte) of the offset to the level layout data,
; based on the current scroll position.
Level_Scroll_GetYBlockOffset:
	ld   hl, sLvlScrollY_High
	jr   Level_GetYBlockOffset
	
; =============== PlBGColi_GetYBlockOffset ===============
; Gets the Y component (high byte) of the offset to the level layout data,
; based on the tile collision check position.
PlBGColi_GetYBlockOffset:
	ld   hl, sTarget_High
	
; =============== Level_GetYBlockOffset ===============
; Standalone subroutine for getting the Y component (high byte) 
; of an offset to the level layout data.
; This divides by 16 the data pointed to by HL.
;
; See also: Level_DrawFullScreen.
;
; IN
; - HL: Ptr to a 2-byte Y pos
; OUT
; - H: High byte of a block offset to level layout data
Level_GetYBlockOffset:
	; Read the Y coordinate to DE
	ldi  a, [hl]	; high byte
	ld   d, a
	ld   e, [hl]	; low byte
	ld   a, e
	
	; Divide the entire word value by 16 and fit it into a single byte.
	; We're doing this since a block is 16px tall.
	
	; Dividing by 16 gets rid of a nybble in the low byte
	swap a				; H = E >> 4
	and  a, $0F
	ld   h, a
	; While in the high byte, only the low nybble is usable since levels aren't that tall.
	ld   a, d			; A = D << 4
	and  a, $0F
	swap a
	; Merge the two remaining nybbles together and we have the Y block count in H
	add  h
	ld   h, a
	ret
	
; =============== PlTarget_Set***Pos ===============
; These are sets of subroutines to set a target pointer relative to the player.
; This can be used for anything relative to the player, but is mostly used
; to set a temporary "collision spot" address,
; which is then used to get the block ID for checking its collision.
;
; Each subroutine adds or subtracts a value from a player coordinate.
; =============== PlTarget_SetRightPos ===============
; IN
; - B: Amount to subtract
PlTarget_SetRightPos:
	; sTarget = sPlX + B
	ld   a, [sPlX_Low]
	add  b
	ld   [sTarget_Low], a
	ld   a, [sPlX_High]
	adc  a, $00					; account for carry
	ld   [sTarget_High], a
	ret
; =============== PlTarget_SetLeftPos ===============
; IN
; - B: Amount to subtract
PlTarget_SetLeftPos:
	; sTarget = sPlX - B
	ld   a, [sPlX_Low]
	sub  a, b
	ld   [sTarget_Low], a
	ld   a, [sPlX_High]
	sbc  a, $00					; account for carry
	ld   [sTarget_High], a
	ret
	
; =============== PlTarget_SetDownPos ===============
; IN
; - B: Amount to add
PlTarget_SetDownPos:
	; sTarget = sPlY + B
	ld   a, [sPlY_Low]
	add  b
	ld   [sTarget_Low], a
	ld   a, [sPlY_High]
	adc  a, $00					; account for carry
	ld   [sTarget_High], a
	ret
; =============== PlTarget_SetUpPos ===============
; IN
; - B: Amount to add
PlTarget_SetUpPos:
	; sTarget = sPlY - B
	ld   a, [sPlY_Low]		
	sub  a, b
	ld   [sTarget_Low], a
	ld   a, [sPlY_High]
	sbc  a, $00					; account for carry
	ld   [sTarget_High], a
	ret
	
; =============== ExActOBJTarget_Set***Pos ===============
; Like PlTarget_Set***Pos, except it goes off the ExAct OBJ position.
; The horizontal variations are in BANK $0D.

; =============== ExActOBJTarget_SetVertPos ===============
; Sets the target pointer relative to the currently processed ExAct.
; IN:
; - B: Amount to add or remove (signed)
ExActOBJTarget_SetVertPos:

	; Because the target is a 16bit value, **and the source is 8bit**, it requires special accounting for the carry
	; so we can't simply add the number as-is (adc $00 after adding a negative value wouldn't work).
	; To cut down on the number of subroutines, we always make sure to pass a positive number.
	
	; If it's already positive, the value will be added to the Y pos.
	; [TCRF] And this never ends up happening since this is only called for 
	;        underwater bubbles, which only checks in a single position.
	bit  7, b									; Is the value negative?
	jr   z, ExActOBJTarget_Unused_SetDownPos	; If not, jump
	
	; Otherwise, the value will be subtracted from the Y pos.
	; Requires a positive number, so convert from signed negative to positive.
	ld   a, b									
	cpl			; Invert bits							
	inc  a		; Account for $FF -> $01 instead of $00, etc...
	ld   b, a
	jr   ExActOBJTarget_SetUpPos
	
; =============== ExActOBJTarget_Unused_SetDownPos ===============
; [TCRF] This ended up not being used.
; IN
; - B: Amount to add
ExActOBJTarget_Unused_SetDownPos:
	; sTarget = sExActOBJY + B
	ld   a, [sExActOBJY_Low]
	add  b
	ld   [sTarget_Low], a
	ld   a, [sExActOBJY_High]
	adc  a, $00					; account for carry
	ld   [sTarget_High], a
	ret
	
; =============== ExActOBJTarget_SetUpPos ===============
; IN
; - B: Amount to subtract
ExActOBJTarget_SetUpPos:
	; sTarget = sExActOBJY - B
	ld   a, [sExActOBJY_Low]
	sub  a, b
	ld   [sTarget_Low], a
	ld   a, [sExActOBJY_High]
	sbc  a, $00					; account for carry
	ld   [sTarget_High], a
	ret
	
; =============== Pl_Unused_FlashPalFast ===============
; [TCRF] Unreferenced code.
; Like Pl_FlashPal, except the palette flashes twice as fast.
Pl_Unused_FlashPalFast:
	; Every 4 frames
	ld   a, [sTimer]
	and  a, $03
	ret  nz
	jr   Pl_DoFlashPal

; =============== Pl_FlashPal ===============
; Flashes the player palette, to indicate the player's invulnerable.
; Used for both invincibility and after taking damage.
Pl_FlashPal:
	; Every 8 frames
	ld   a, [sTimer]
	and  a, $07
	ret  nz
Pl_DoFlashPal:
	; Alternate OBP0 and OBP1  to invert it
	ld   a, [sPlFlags]
	xor  $10
	ld   [sPlFlags], a
	ret
; =============== Pl_MoveRight ===============
; Moves the player to the right.
; IN
; - B: Pixels of movement
Pl_MoveRight:
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_CHKAUTO	; Is the scroll mode < $20?
	jr   c, .noAutoScroll		; If so, we aren't in an autoscroll/fixed screen mode
	; In those modes, prevent moving off the right border
	ld   a, [sPlXRel]
	cp   a, SCREEN_H - $08
	ret  nc
.noAutoScroll:
	; sPlX += B
	ld   a, [sPlX_Low]
	add  b
	ld   [sPlX_Low], a
	ld   a, [sPlX_High]
	adc  a, $00
	ld   [sPlX_High], a
	ret
; =============== Pl_MoveRight ===============
; Moves the player to the left.
; IN
; - B: Pixels of movement
Pl_MoveLeft:
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_CHKAUTO	; Is the scroll mode < $20?
	jr   c, .noAutoScroll		; If so, we aren't in an autoscroll/fixed screen mode
	; In those modes, prevent moving off the left border
	ld   a, [sPlXRel]
	cp   a, $08
	ret  c
.noAutoScroll:
	; sPlX -= B
	ld   a, [sPlX_Low]
	sub  a, b
	ld   [sPlX_Low], a
	ld   a, [sPlX_High]
	sbc  a, $00
	ld   [sPlX_High], a
	ret
; =============== Pl_MoveDown ===============
; Moves the player down.
; This also handles the instant-kill pit at the edge of the level.
; IN
; - B: Pixels of movement
Pl_MoveDown:
	; sPlY += B
	ld   a, [sPlY_Low]
	add  b
	ld   [sPlY_Low], a
	ld   a, [sPlY_High]
	adc  a, $00
	ld   [sPlY_High], a
	
	; If we went past the lower edge of the level, instakill the player
	cp   a, HIGH(LEVEL_HEIGHT)
	jr   z, .plKill
	
	; Are we in freescroll mode? 
	; (sLvlScrollMode >= LVLSCROLL_FREE && sLvlScrollMode <= LVLSCROLL_CHKAUTO)
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_FREE		
	ret  c
	cp   a, LVLSCROLL_CHKAUTO
	ret  nc
.freeScroll:
	; Update vertical screen lock
	call Level_ScreenLock_DoBottom
	; Is a vertical scroll lock active?
	ld   a, [sLvlScrollLockCur]
	and  a, SCRLOCK_U|SCRLOCK_D
	ret  nz
	; If not, mark the screen movement offset
	ld   a, [sLvlScrollVAmount]
	add  b
	ld   [sLvlScrollVAmount], a
	ret
.plKill:
	ld   a, [sPlAction]
	cp   a, PL_ACT_DEAD			; Is the player already dead?
	ret  z						; If so, return
	jp   Pl_StartDeathAnim
; =============== Pl_MoveUp ===============
; Moves the player up.
; IN
; - B: Pixels of movement
Pl_MoveUp:
	; sPlY -= B
	ld   a, [sPlY_Low]
	sub  a, b
	ld   [sPlY_Low], a
	ld   a, [sPlY_High]
	sbc  a, $00
	ld   [sPlY_High], a
	
	; Are we in freescroll mode? 
	; (sLvlScrollMode >= LVLSCROLL_FREE && sLvlScrollMode <= LVLSCROLL_CHKAUTO)
	ld   a, [sLvlScrollMode]
	cp   a, LVLSCROLL_FREE
	ret  c
	cp   a, LVLSCROLL_CHKAUTO
	ret  nc
.freeScroll:
	; Update vertical screen lock
	call Level_ScreenLock_DoTop
	; Is a vertical scroll lock active?
	ld   a, [sLvlScrollLockCur]
	and  a, SCRLOCK_U|SCRLOCK_D
	ret  nz
	; If not, mark the screen movement offset
	ld   a, [sLvlScrollVAmount]
	sub  a, b
	ld   [sLvlScrollVAmount], a
	ret
; =============== Level_Screen_MoveRight ===============
; Scrolls the screen right during gameplay.
; IN
; - B: Pixels of movement
Level_Screen_MoveRight:
	; sLvlScrollX += B
	ld   a, [sLvlScrollX_Low]
	add  b
	ld   [sLvlScrollX_Low], a
	ld   a, [sLvlScrollX_High]
	adc  a, $00					; account carry
	ld   [sLvlScrollX_High], a
	ret
; =============== Level_Screen_MoveLeft ===============
; Scrolls the screen left during gameplay.
; IN
; - B: Pixels of movement
Level_Screen_MoveLeft:
	; sLvlScrollX -= B
	ld   a, [sLvlScrollX_Low]
	sub  a, b
	ld   [sLvlScrollX_Low], a
	ld   a, [sLvlScrollX_High]
	sbc  a, $00
	ld   [sLvlScrollX_High], a
	ret
; =============== Level_Screen_MoveDown ===============
; Scrolls the screen down during gameplay.
; IN
; - B: Pixels of movement
Level_Screen_MoveDown:
	; sLvlScrollY += B
	ld   a, [sLvlScrollY_Low]
	add  b
	ld   [sLvlScrollY_Low], a
	ld   a, [sLvlScrollY_High]
	adc  a, $00
	ld   [sLvlScrollY_High], a
	ret
; =============== Level_Screen_MoveUp ===============
; Scrolls the screen up during gameplay.
; IN
; - B: Pixels of movement
Level_Screen_MoveUp:
	; sLvlScrollY -= B
	ld   a, [sLvlScrollY_Low]
	sub  a, b
	ld   [sLvlScrollY_Low], a
	ld   a, [sLvlScrollY_High]
	sbc  a, $00
	ld   [sLvlScrollY_High], a
	ret
; =============== Level_ScreenLock_DoRight ===============
; Handles the right screen lock when moving right.
Level_ScreenLock_DoRight:
	ld   a, [sLvlScrollLockCur]		
	bit  SCRLOCKB_L, a              ; Is the left border (opposite) lock set?
	jr   nz, .checkRemoveLeft		; If so, don't scroll the screen right
.checkSet:
	; Determine if the current screen has a right screen lock
	ld   hl, sLvlScrollLocks
	call Level_ScreenLock_IndexScreen
	bit  SCRLOCKB_R, [hl]			; Does it have one?
	ret  z							; If not, return
	
	; Trigger the screen lock if we're close to the border
	ld   a, [sLvlScrollX_Low]		
	cp   a, $100-$50				; Is the player $50px close to the right border? 
	ret  c
	
	ld   a, $100-$50				; Snap the scroll pos
	ld   [sLvlScrollX_Low], a
	ld   hl, sLvlScrollLockCur
	set  SCRLOCKB_R, [hl]			; Enable the right lock
	ret
.checkRemoveLeft:
	ld   a, [sPlX_Low]
	cp   a, $61						; Is sPlX_Low <= $60?
	ret  c							; If so, return
	ld   hl, sLvlScrollLockCur		; Otherwise, clear the screen lock
	res  SCRLOCKB_L, [hl]
	ret
; =============== Level_ScreenLock_DoLeft ===============
; Handles the left screen lock when moving left.
Level_ScreenLock_DoLeft:
	ld   a, [sLvlScrollLockCur]
	bit  SCRLOCKB_R, a				; Is the left border (opposite) lock set?
	jr   nz, .checkRemoveRight		; If so, don't scroll the screen right
	
	; Determine if the current screen has a left screen lock
	ld   hl, sLvlScrollLocks
	call Level_ScreenLock_IndexScreen
	bit  SCRLOCKB_L, [hl]			; Does it have one?
	ret  z							; If not, return
	
	; Trigger the screen lock if we're close to the border
	ld   a, [sLvlScrollX_Low]		; Is the player $60px close to the right border? 
	cp   a, $61						; (<= $60)
	ret  nc							; If not, return
	
	ld   a, $60						; Snap the scroll pos
	ld   [sLvlScrollX_Low], a
	ld   hl, sLvlScrollLockCur
	set  SCRLOCKB_L, [hl]			; Enable the left lock
	ret
.checkRemoveRight:
	ld   a, [sPlX_Low]
	cp   a, $100-$50				; Is sPlX_Low > $B0?
	ret  nc							; If so, return
	ld   hl, sLvlScrollLockCur		; Otherwise, clear the screen lock
	res  SCRLOCKB_R, [hl]
	ret
; =============== Level_ScreenLock_DoBottom ===============
; Autogenerates the bottom screen lock flag for freescroll mode, when moving down.
Level_ScreenLock_DoBottom:
	ld   a, [sLvlScrollLockCur]
	bit  SCRLOCKB_U, a			; Is the upper screen (opposite) lock set?
	jr   nz, .checkRemoveUp		; If so, don't scroll the screen downwards
.checkSet:
	; Should the screen lock be set?
	ld   a, [sLvlScrollY_High]
	cp   a, HIGH(LEVEL_HEIGHT) - 1	; Are we on a lowest sector of the level?
	ret  nz							; If not, return
	
	; [BUG?] For some reason, freescroll triggers the bottom screen lock a full
	;        block ($10) above the normal limit.
	;        Remove the - $10 to show the normal range like in segscrl mode.
	
	ld   a, [sLvlScrollY_Low]		
	cp   a, ($100-LVLSCROLL_YOFFSET)-$10	; Is the screen fully scrolled to the bottom (or over the limit)?
	ret  c									; If not (< $A8), return
	
	ld   a, ($100-LVLSCROLL_YOFFSET)-$10	; Otherwise, snap it back to the lower border
	ld   [sLvlScrollY_Low], a
	ld   hl, sLvlScrollLockCur
	set  SCRLOCKB_D, [hl]					; And mark the scroll lock
	ret
.checkRemoveUp:
	; Unmark the upper screen lock only if the screen isn't fully scrolled up
	ld   a, [sPlY_Low]					
	cp   a, LVLSCROLL_YOFFSET				; Is the screen still fully scrolled up?
	ret  c									; If so, don't unmark the scroll lock
	
	ld   hl, sLvlScrollLockCur
	res  SCRLOCKB_U, [hl]					
	ret

; =============== Level_ScreenLock_DoTop ===============
; Autogenerates the top screen lock flag for freescroll mode, when moving up.
Level_ScreenLock_DoTop:
	ld   a, [sLvlScrollLockCur]
	bit  SCRLOCKB_D, a						; Is the lower screen (opposite) lock set?
	jr   nz, .checkRemoveDown				; If so, don't scroll the screen upwards
	
.checkSet:
	; Should the screen lock be set?
	ld   a, [sLvlScrollY_High]				
	and  a									; Are we on a upper sector of the level? (sectorY $00)
	ret  nz									; If not, return
	
	; Account for hw scroll offset
	ld   a, [sLvlScrollY_Low]				
	cp   a, LVLSCROLL_YOFFSET				; Is the screen fully scrolled to the top (or over the limit)?		
	ret  nc
	ld   a, LVLSCROLL_YOFFSET				; If so, snap the screen to the top border
	ld   [sLvlScrollY_Low], a
	ld   hl, sLvlScrollLockCur
	set  SCRLOCKB_U, [hl]					; And mark the upper scroll lock
	ret
.checkRemoveDown:
	; [BUG?] See Level_ScreenLock_DoBottom
	
	; Unmark the down screen lock only if the screen isn't fully scrolled down
	ld   a, [sPlY_Low]
	cp   a, ($100-LVLSCROLL_YOFFSET)-$10	
	ret  nc
	
	ld   hl, sLvlScrollLockCur
	res  SCRLOCKB_D, [hl]					
	ret
	

; =============== Pl_JumpYPath ===============
; This is a table of Y offsets used to determine how much to increase/decrease
; Wario's Y position during a jump.
;
; When the jump starts, the index is set to $00 and is incremented every frame.
; Indexes < $1B are for upwards movement; the others for downwards movement.
; When falling off something, the index is set immediately to $1B.
;
; This table is used for normal jumps (not holding UP).
;
Pl_JumpYPath:
	; Upwards movement ($00-$1A)
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01
.down:
	; Downwards movement ($1B-$47)
	db $00,$00,$00,$00,$01,$01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
.end:
; =============== Wario_HighJumpYPath ===============
; The table used when performing an high jump.
Wario_HighJumpYPath:
	; Upwards movement ($00-$21)
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$01
.down:
	; Downwards movement ($22-$47)
	db $00,$00,$00,$00,$00,$00,$00,$01,$01,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02
.end:	
; =============== Level_SetScrollLevel ===============
; Updates the scroll level for segmented scrolling mode.
Level_SetScrollLevel:
	call Level_GetScrollLevel
	ld   a, c
	ld   [sLvlScrollLevel], a
	ret
	
; =============== Level_GetScrollLevel ===============
; Calculates the scroll level for segmented scrolling mode.
; This number is $01 for the lowest screen (where going down results in instant death)
; and increases for each scrolling level.
; OUT
; - C: Scroll level
Level_GetScrollLevel:
	ld   c, $01				; Starting value: ground floor
	
	ld   a, [sPlY_High]	; Is the player on the lowest screen?
	dec  a
	jr   z, .lowLevel		; If so, jump
	
	; Otherwise, Wario is in one of the two top levels
	
	; NOTE: The $80 value is the result of a scroll level
	;       taking half height of the BG Map.
	
	ld   c, $03
	
	ld   a, [sPlY_Low]	
	cp   a, $80				; Is the player Y low <= $80?
	ret  nc					; If not, we're definitely in the lower level (of the higher screen)
	inc  c					; Otherwise we're on level 4, which is never seen normally in segscrl mode.
	ret
.lowLevel:
	ld   a, [sPlY_Low]
	cp   a, $80				; Is the player Y low <= $80?
	ret  nc					; If not, we're definitely in the lower level
	inc  c					; Otherwise we're on level 2
	ret
	
; =============== Pl_StartDeathAnim ===============
; This subroutine starts the death sequence for the player.
Pl_StartDeathAnim:
	; If we're overriding the death sequence, start the level clear anim instead.
	;
	; This is set after beating a boss to make sure that you won't die from going into the lava.
	; Doing that should clear the level early, therefore ending early the coin game.
	ld   a, [sLvlClearOnDeath]
	and  a						; Is the override enabled?
	jr   z, .startDeath			; If not, kill the player
.override:
	ld   a, LVLCLEAR_BOSS		; Otherwise, end the (boss) level
	ld   [sLvlSpecClear], a
	ret
.startDeath:
	ld   a, $01					; lol
	ld   [sNoReset], a
	;--
	; Set death anim
	ld   a, $80
	ld   [s_X_A984_Timer], a
	ld   a, PL_ACT_DEAD
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	ld   a, $01
	ld   [sPauseActors], a
	ld   a, OBJ_WARIO_DEAD
	ld   [sPlLstId], a
	xor  a
	ld   [sHurryUp], a
	ld   [sPlJumpYPathIndex], a
	ld   [sLvlScrollMode], a
	ld   a, BGM_LIFELOST
	ld   [sBGMSet], a
	
	;--
	; Spawn the coins flying out, depending on how many you have
	ld   a, [sPlY_High]
	ld   [sExActOBJY_High], a
	ld   a, [sPlY_Low]
	ld   [sExActOBJY_Low], a
	ld   a, [sPlX_High]
	ld   [sExActOBJX_High], a
	ld   a, [sPlX_Low]
	ld   [sExActOBJX_Low], a
	ld   a, OBJ_COIN0
	ld   [sExActOBJLstId], a
	xor  a
	ld   [sExActOBJFlags], a
	
	; Clear exact area
	ld   hl, sExActSet + $07			
	xor  a
	ld   b, $09
	call ClearRAMRange_Mini
	
	; How many coins show up directly matches the coin count, capped at 3.
	; Each coin is its own extra actor.
	ld   a, [sLevelCoins_High]
	and  a						; More than 100 coins?
	jr   nz, .coin3				; If so, spawn 3
	ld   a, [sLevelCoins_Low]
	and  a						; 0 coins?
	jr   z, .noCoins
	dec  a						; 1 coin?
	jr   z, .coin1
	dec  a						; 2 coins?
	jr   z, .coin2
.coin3:
	ld   a, EXACT_DEADCOINC
	ld   [sExActSet], a
	call ExActS_Spawn
.coin2:
	ld   a, EXACT_DEADCOINL
	ld   [sExActSet], a
	call ExActS_Spawn
.coin1:
	ld   a, EXACT_DEADCOINR
	ld   [sExActSet], a
	call ExActS_Spawn
.noCoins:
	
	; Spawn the hat actor if we aren't small
	ld   a, [sSmallWario]
	and  a
	ret  nz
	ld   a, EXACT_DEADHAT
	ld   [sExActSet], a
	; Reuse this to set the initial Wario's hat pos
	ld   b, $16					; Set hat 16px above Wario
	call PlTarget_SetUpPos
	ld   a, [sTarget_High]
	ld   [sExActOBJY_High], a
	ld   a, [sTarget_Low]
	ld   [sExActOBJY_Low], a
	ld   a, [sPlX_High]
	ld   [sExActOBJX_High], a
	ld   a, [sPlX_Low]
	ld   [sExActOBJX_Low], a
	ld   a, OBJ_HAT
	ld   [sExActOBJLstId], a
	ld   a, [sPlFlags]
	ld   [sExActOBJFlags], a
	; Clear exact area
	ld   hl, sExActSet + $07
	xor  a
	ld   b, $09
	call ClearRAMRange_Mini
	
	call ExActS_Spawn
	ret
; =============== ExActS_Spawn ===============
; Spawns an ExAct (Extra Actor) by copying over its data from the request area
; to the proper ExAct area.
;
; Note that the "request area" doubles as area containing the currently processed ExAct.
; By convention new ExAct are created in that area, then moved to the main section through this subroutine.
;
; ExAct Format: 16 bytes
; - $00: ExAct ID. If $00, the slot is considered empty.
; - $01: Y coord (high) 
; - $02: Y coord (low) 
; - $03: X coord (high)
; - $04: X coord (low)
; - $05: OBJLst Id (sprite mapping ID)
; - $06: OBJ Flags
; - $0B: Y Coord (relative)
; - $0C: X Coord (relative)
;
; Depending on where it's used, the actor should define either relative or 2-byte coordinates.
; If there aren't free slots the actor won't spawn.
ExActS_Spawn:
	; Find the first free slot in the ExAct area
	ld   hl, sExAct		; HL = Where to search
.searchSlot:
	; Free slots have their first byte set as 00
	ld   a, [hl]		
	and  a				
	jr   z, .slotFound	
	
	; Otherwise, search in the next slot and try again
	ld   a, l			
	add  $10
	cp   a, LOW(sExActSet)	; Are we past the ExAct area?
	ret  z					; If so, return and don't spawn it
	ld   l, a
	jr   .searchSlot
.slotFound:
	ld   a, [sExActCount]	; Update stats
	inc  a
	ld   [sExActCount], a
	
	; Copy the actor data from the request area as-is
	ld   b, $10
	ld   de, sExActSet
.loop:
	ld   a, [de]
	ldi  [hl], a
	inc  de
	dec  b
	jr   nz, .loop
	ret
	
; =============== Pl_SwitchToHardBump ===============
; Switches the player to the hard bump state.
; This is used for all types of hard bumps to perform the actual start
; of the knockback effect, including the one after getting hit.
Pl_SwitchToHardBump:
	; Mark the proper start
	ld   a, PL_HT_BUMP
	ld   [sPlHurtType], a
	; Reset bump index in case we were in the middle of another one
	; (ie: taking damage during a knockback)
	xor  a
	ld   [sPlBumpYPathIndex], a
	
	; Always start the normal airborne bump, unless we're ducking
	ld   a, [sPlAction]
	cp   a, PL_ACT_DUCK
	jr   nz, Pl_SwitchToHardBumpAir
	
	; In that case, set the flag to bump on the ground without moving vertically
	ld   a, [sPlAction]
	ld   [sPlHardBumpGround], a
	
; =============== Pl_SwitchToHardBump ===============
; Switches the player to the hard bump state in the air.
Pl_SwitchToHardBumpAir:
	ld   a, PL_ACT_HARDBUMP
	ld   [sPlAction], a
	ld   a, $01
	ld   [sPlNewAction], a
	xor  a
	
	ld   [sPlTimer], a
	ld   [sPlBGColiLadderType], a
	ld   [sPlSuperJump], a
	ld   [sPlMovingJump], a
	
	; There's no bump frame for Small Wario.
	; He ends up staying in whatever frame he was on for the entire duration of the bump.
	ld   a, [sSmallWario]
	and  a
	jr   nz, .noFrame
	ld   a, OBJ_WARIO_BUMPAIR
	ld   [sPlLstId], a
.noFrame:
	; Set the bump direction based on the value of the "actor interaction direction" mask.
	; ie: when the actor is being interacted on the left, the player is bumped left. 
	
	; It works since the only way to get bumped is interacting with an actor 
	; (though nothing would prevent you from faking the value.
	
	ld   a, [sActInteractDir]
	bit  ACTINTB_R, a				; Interacted on the right?
	jr   nz, .right					; If so, bump the player right.
.left:
	ld   a, DIR_L
	ld   [sPlHardBumpDir], a
	ret
.right:
	ld   a, DIR_R
	ld   [sPlHardBumpDir], a
	ret
; =============== Game_AddCoin ===============
; This subroutine adds a single coin to the level coin counter,
; and redraws the status bar.
Game_AddCoin:
	; sLevelCoins_Low++
	ld   a, [sLevelCoins_Low]
	add  $01
	daa							; adjust for bcd
	ld   [sLevelCoins_Low], a
	ld   a, [sLevelCoins_High]
	adc  a, $00					; account carry
	ld   [sLevelCoins_High], a
	; Enforce a cap of 999 coins, which triggers at exactly 1000 coins
	; [TCRF] Impossible to reach the cap without cheating
	cp   a, $0A
	jr   nz, .coinOk
	ld   a, $99
	ld   [sLevelCoins_Low], a
	ld   a, $09
	ld   [sLevelCoins_High], a
.coinOk:
	call StatusBar_DrawLevelCoins
	ld   a, SFX1_10					; Play coin SFX
	ld   [sSFX1Set], a
	ret
; =============== StatusBar_DrawLevelCoins ===============
; Draws/updates the coin counter in the status bar.
StatusBar_DrawLevelCoins:
	ld   a, [sLevelCoins_High]
	ld   b, a
	ld   hl, vBGLevelCoins
	call StatusBar_WriteLowNybble
	ld   a, [sLevelCoins_Low]
	ld   b, a
	inc  l
	call StatusBar_WriteNybbles
	ret
; =============== StatusBar_DrawHearts ===============
; Draws/updates the hearts counter in the status bar.
StatusBar_DrawHearts:
	ld   a, [sHearts]
	ld   b, a
	ld   hl, vBGHearts
	call StatusBar_WriteNybbles
	ret
; =============== StatusBar_DrawLives ===============
; Draws/updates the lives counter in the status bar.
StatusBar_DrawLives:
	ld   a, [sLives]
	ld   b, a
	ld   hl, vBGLives
	call StatusBar_WriteNybbles
	ret
; =============== StatusBar_DrawTime ===============
; Draws/updates the time in the status bar.
StatusBar_DrawTime:
	ld   a, [sLevelTime_High]
	ld   b, a
	ld   hl, vBGLevelTime
	call StatusBar_WriteLowNybble
	ld   a, [sLevelTime_Low]
	ld   b, a
	inc  l
	call StatusBar_WriteNybbles
	ret
	
; =============== StatusBar_WriteNybbles ===============
; Writes the two nybbles of a number to the specified location in the status bar.
;
; The number is expected to be in decimal format, and each digit takes up a nybble.
;
; This works on the assumption that the GFX in VRAM have the digits stored
; in order from 0 to 9, making them selectable by simply doing (base tile id + digit).
;
; IN
; -  B: Number in BCD format
; - HL: Ptr to WINDOW tilemap location in the status bar
StatusBar_WriteNybbles:
	mWaitForNewHBlank
	; Left Digit: (B >> 4)	
	ld   a, b
	swap a
	and  a, $0F
	add  TILEID_DIGITS		; Add the base tile ID for digits
	ldi  [hl], a
	; Right Digit: (B & $0F)	
	ld   a, b
	and  a, $0F
	add  TILEID_DIGITS
	ld   [hl], a
	ret
; =============== StatusBar_WriteLowNybble ===============
; Identical to StatusBar_WriteNybbles, except it only writes the digit in the low nybble.
; IN
; -  B: Number in BCD format
; - HL: Ptr to WINDOW tilemap location in the status bar
StatusBar_WriteLowNybble:
	mWaitForNewHBlank
	; Right Digit: (B & $0F)
	ld   a, b
	and  a, $0F
	add  TILEID_DIGITS
	ld   [hl], a
	ret

; =============== Game_InitHatSwitch ===============
; Initializes the hat switch animation.
Game_InitHatSwitch:
	; Ignore if there's already an hat switch sequence in progress
	ld   a, [sPlHatSwitchTimer]
	and  a
	ret  nz
	; Don't interrupt vertical scrolling in SEGSCRL mode
	ld   a, [sLvlScrollTimer]
	and  a
	ret  nz
	; Pointless if Wario's already dead
	ld   a, [sPlAction]
	cp   a, PL_ACT_DEAD
	ret  z
	cp   a, PL_ACT_TREASUREGET	; Or for this
	ret  z
	
	;--
	ld   a, SFX1_06				; Play powerup SFX
	ld   [sSFX1Set], a
	; Are we powering up or down?
	ld   a, [sPlPowerSet]
	and  a
	jr   nz, .powerUp
	ld   a, SFX1_25				; Play powerdown SFX
	ld   [sSFX1Set], a
.powerUp:
	;--
	ld   a, $10						; Perform the effect 10 times
	ld   [sPlHatSwitchTimer], a
	xor  a
	ld   [sPlHatSwitchDrawMode], a
	ld   a, $01
	ld   [sPauseActors], a
	
	; Apply the target powerup status
	; sPlPower = (sPlPower_Unused_Copy >> 4) + sPlPowerSet
	ld   a, [sPlPowerSet]		
	ld   b, a
	ld   a, [sPlPower]		
	ld   [sPlPower_Unused_Copy], a
	swap a	; Move to the upper nybble the previous powerup state
	add  b	; In the lower nybble put the new state
	ld   [sPlPower], a
	ret
; =============== Level_LoadData ===============
; Loads the data for currently selected level (sLevelId).
Level_LoadData:
	ld   a, [sROMBank]
	push af
	ld   a, $0C
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	;-------------------------------------
	
	; For some reason this is not part of the level header
	call Level_SetBGM
	
	call Level_GetHeader	; HL = Level header
	
	;
	; LEVEL GFX
	;
	
	ld   b, [hl]			; B = Byte 0 (Bank number for level GFX)
	inc  hl
	
	; Read bytes 1-2 (Ptr to level GFX)
	;#
	ldi  a, [hl]			; A = Byte 1 (GFX ptr, low)
	;--
	push hl				
	ld   h, [hl]			; H = Byte 2 (GFX ptr, high)	
	ld   l, a				; HL = Ptr to level GFX
	;#
	
	ld   a, [sROMBank]
	push af
	ld   a, b				; Set the requested bank number
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call Level_CopyLevelGFX	; Copy the GFX over
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	pop  hl
	;--
	inc  hl	
	
	;
	; BLOCK GFX
	;
	
	; Read bytes 3-4 (Ptr to block GFX)
	;#
	ldi  a, [hl]			; A = Byte 3 (block GFX ptr, low)
	;--
	push hl
	ld   h, [hl]			; H = Byte 4 (block GFX ptr, high)
	ld   l, a				; HL = Ptr to block GFX
	;#
	
	ld   a, [sROMBank]
	push af
	ld   a, $11				; Block GFX are all in bank $11
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call Level_CopySharedBlockGFX	; Copy them over
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	pop  hl
	;--
	inc  hl
	
	;
	; STATUS BAR GFX
	;
	
	; Read bytes 5-6 (Ptr to status bar GFX)
	;#
	ldi  a, [hl]			; A = Byte 5 (status GFX ptr, low)
	;--
	push hl
	ld   h, [hl]			; H = Byte 6 (status GFX ptr, high)
	ld   l, a				; HL = Ptr to block GFX
	;#
	
	ld   a, [sROMBank]
	push af
	ld   a, $11				; Always in Bank $11
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call Level_CopyStatusBarGFX
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	pop  hl
	;--
	inc  hl
	
	;
	; ANIMATED TILES GFX
	;
	
	; Read bytes 7-8 (Ptr to anim tiles GFX)
	;#
	ldi  a, [hl]		; 7
	;--
	push hl
	ld   h, [hl]		; 8
	ld   l, a			; HL = Ptr to anim tiles
	;#
	ld   a, [sROMBank]
	push af
	ld   a, $11
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call Level_CopyAnimGFX
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	pop  hl
	;--
	
	;
	; WARIO GFX + OTHER SHARED
	;
	
	; Copy the shared GFX from a fixed location
	;--
	push hl
	ld   a, [sROMBank]
	push af
	ld   a, $05
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	ld   hl, GFX_Level_SharedOBJ
	call Level_CopySharedOBJGFX
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	pop  hl
	;--
	inc  hl
	
	;
	; LEVEL LAYOUT & ACTOR LAYOUT
	;
	ld   b, [hl]			; B = Byte 9 (Bank number)
	inc  hl
	ld   c, [hl]			; C = Byte A (Layout ID)
	inc  hl
	
	;--
	push hl
	ld   a, [sROMBank]
	push af
	ld   a, b				; Switch the bank
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	ld   a, c				; A = Layout ID
	call Level_DecompressLayout
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call SubCall_Level_LoadActLayout
	pop  hl
	;--
	
	;
	; 16x16 BLOCKS
	;
	
	; Read bytes B-C (Ptr to block data)
	;#
	ldi  a, [hl]			
	push hl
	;--
	ld   h, [hl]
	ld   l, a
	;#
	mHomeCall Level_CopyBlockData ; BANK $0B
	pop  hl
	;--
	inc  hl
	
	;
	; WARIO OBJ FLAGS / Starting coords
	;
	
	; Copy bytes D-12
	ld   de, sPlY_High
	ld   b, $06
	call CopyBytes
	
	;
	; SCREEN SCROLL COORDS
	;
	
	; Copy bytes 13-16
	ld   de, sLvlScrollYRaw_High	
	ld   b, $04
	call CopyBytes
	
	; Generate the actual scroll coords from those 
	; The raw values from the header point to the top-left corner of the screen.
	; They need to be offsetted to point to (more or less) the center of the screen instead.
	;--
	push hl
	
	; Scroll Y
	ld   a, [sLvlScrollYRaw_Low]
	ld   l, a						
	add  $10						; ScrollY = sLvlScrollYRaw_Low + $10			
	ldh  [rSCY], a					
	ldh  [hScrollY], a
	
	; LvlScroll Y
	ld   a, [sLvlScrollYRaw_High]
	ld   h, a
	ld   de, $0058					; LvlScroll = sLvlScrollYRaw + $58
	add  hl, de						
	ld   a, h
	ld   [sLvlScrollY_High], a
	ld   a, l
	ld   [sLvlScrollY_Low], a
	
	; Scroll X
	ld   a, [sLvlScrollXRaw_Low]
	ld   l, a
	add  $10						; ScrollX = sLvlScrollX_Low + $10	
	ldh  [rSCX], a					
	ld   [sScrollX], a
	
	; LvlScroll X
	ld   a, [sLvlScrollXRaw_High]
	ld   h, a
	ld   de, $0060					; LvlScroll = sLvlScrollYRaw + $60
	add  hl, de
	ld   a, h
	ld   [sLvlScrollX_High], a
	ld   a, l
	ld   [sLvlScrollX_Low], a
	pop  hl
	;--
	
	; 17: Initial scroll lock; should match with the screen lock def
	ldi  a, [hl]
	ld   [sLvlScrollLockCur], a
	
	; 18: Initial scroll mode; should match with door defn
	ldi  a, [hl]
	ld   [sLvlScrollMode], a
	
	; 19: If set, Wario should spawn swimming
	ldi  a, [hl]
	ld   [sPlSwimGround], a
	and  a
	jr   z, .noSwim
	; Set the appropriate action
	ld   a, PL_ACT_SWIM
	ld   [sPlAction], a
.noSwim:

	; 1A: Level tile animation speed
	ldi  a, [hl]
	ld   [sLevelAnimSpeed], a
	
	; 1B: Level Palette
	ldi  a, [hl]
	ld   [sBGP], a
	ldh  [rOBP1], a
	
	;
	; ACTOR POINTER ROUTINE
	;
	; This determines what the Actor IDs point to.
	
	; Read bytes 1C-1D (Ptr to actor routine)
	ldi  a, [hl]	; HL = Ptr to level routine?
	ld   h, [hl]
	ld   l, a
	;--
	ld   a, [sROMBank]
	push af
	ld   a, $07
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call JumpHL
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call Level_SetScrollLevel
	
	;------------------------
	
	;
	; PLAYER PROPERTIES
	;
	; Set the correct properties depending on Wario's powerup status
	
	; Index the Ptr table
	ld   hl, Game_PowerupStatePtrTbl
	ld   a, [sPlPower]
	add  a
	ld   e, a	; DE = sPlPower * 2
	ld   d, $00
	add  hl, de
	; Set the ptr to HL
	ldi  a, [hl]
	ld   h, [hl]
	ld   l, a
	
	ldi  a, [hl]			; Set flags and frame ID
	ld   [sSmallWario], a
	ldi  a, [hl]
	ld   [sPlLstId], a
	
	; Copy the hat GFX over from the specified ptr
	ldi  a, [hl]			; HL = Ptr to GFX data
	ld   h, [hl]
	ld   l, a
	;--
	ld   a, [sROMBank]
	push af
	ld   a, $05					; All are in BANK $05
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	push hl
	; Copy primary set
	ld   de, vGFXHatPrimary
	ld   b, $40					
	call CopyBytes
	pop  hl
	; Copy secondary set
	ld   de, $0040 				; which is stored right after the primary set
	add  hl, de
	ld   de, vGFXHatSecondary
	ld   b, $40
	call CopyBytes

	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	
	;-------------------------------------
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	ret
	
; =============== Level_GetHeader ===============
; Gets the level header for the currently loaded level.
; OUT
; - HL: Ptr to level header
Level_GetHeader:
	; This info is stored off a ptr table indexed by level id.
	; If a checkpoint is active, a different table is used.	
	
	; Is a checkpoint active?
	ld   a, [sCheckpoint]
	and  a
	jr   z, .noCheckpoint
	; If so, is it for the level we're loading?
	ld   a, [sCheckpointLevelId]
	ld   b, a
	ld   a, [sLevelId]
	cp   a, b
	jr   z, .withCheckpoint	; If so, jump
	xor  a					; Otherwise reset the checkpoint status
	ld   [sCheckpoint], a
.noCheckpoint:
	; Index the ptr table
	ld   hl, Level_HeaderPtrTable
	ld   a, [sLevelId]		
	add  a			; DE = LevelId * 2
	ld   e, a
	ld   d, $00
	add  hl, de		; Offset it
	ldi  a, [hl]	; Get the ptr to the header
	ld   h, [hl]
	ld   l, a
	ret
.withCheckpoint:
	ld   hl, Level_HeaderCheckpointPtrTable
	ld   a, [sLevelId]
	add  a				; DE = LevelId * 2
	ld   e, a
	ld   d, $00
	add  hl, de			; Offset it
	ldi  a, [hl]		; Get the ptr to the header
	ld   h, [hl]
	ld   l, a
	ret
	
	
; =============== Level_LoadRoomData ===============
; This subroutine loads the data for the new room (door transition).
; This is very similar to Level_LoadData.
Level_LoadRoomData:
	; Replace blocks if needed
	call Level_DoBlockSwitch
	
	ld   a, [sROMBank]
	push af
	ld   a, $0C
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	;-------------------------------------
	
	call Level_SetBGM
	
	; HL = Ptr to room data
	ld   a, [sLvlDoorPtr]
	ld   h, a
	ld   a, [sLvlDoorPtr+1]
	ld   l, a
	
	; Apply the room header
	
	
	;
	; WARIO COORDS
	;
	
	ld   a, [hl]			; 0 (low nybble): Wario X high
	and  a, $0F
	ld   [sPlX_High], a
	ldi  a, [hl]			; 0 (high nybble): Wario Y high
	swap a
	and  a, $0F
	ld   [sPlY_High], a
	
	ldi  a, [hl]					; 1: Wario Y low
	ld   [sPlY_Low], a
	ldi  a, [hl]					; 2: Wario X low
	ld   [sPlX_Low], a
	ldi  a, [hl]					; 3: Scroll lock option
	ld   [sLvlScrollLockCur], a
	
	ld   a, [hl]					; 4 (low nybble): Scroll X high (raw)
	and  a, $0F
	ld   [sLvlScrollXRaw_High], a
	ldi  a, [hl]					; 4 (high nybble): Scroll Y high (raw)
	swap a
	and  a, $0F
	ld   [sLvlScrollYRaw_High], a
	
	; Offset like in level loading
	ldi  a, [hl]					; 5: Scroll Y low (raw)
	ld   [sLvlScrollYRaw_Low], a
	add  $10						; +$10
	ldh  [rSCY], a
	ldh  [hScrollY], a
	ldi  a, [hl]					; 6: Scroll X low (raw)
	ld   [sLvlScrollXRaw_Low], a
	add  $10						; +$10
	ldh  [rSCX], a
	ld   [sScrollX], a
	
	;--
	; Apply the raw values to the proper scroll pos
	
	; LvlScrollY
	push hl
	ld   a, [sLvlScrollYRaw_High]	; HL = LvlScrollYRaw + $0058
	ld   h, a
	ld   a, [sLvlScrollYRaw_Low]
	ld   l, a
	ld   de, $0058					
	add  hl, de
	ld   a, h						; Save the offsetted scroll value
	ld   [sLvlScrollY_High], a
	ld   a, l
	ld   [sLvlScrollY_Low], a
	
	; LvlScrollX
	ld   a, [sLvlScrollXRaw_High]	; HL = LvlScrollXRaw + $0060
	ld   h, a
	ld   a, [sLvlScrollXRaw_Low]
	ld   l, a
	ld   de, $0060
	add  hl, de
	ld   a, h						; Save the offsetted scroll value
	ld   [sLvlScrollX_High], a
	ld   a, l
	ld   [sLvlScrollX_Low], a
	pop  hl
	;--
	
	ldi  a, [hl]					; 7: Scroll mode
	ld   [sLvlScrollMode], a
	
	;
	; BG PRIORITY
	;
	ldi  a, [hl]					; 8: Room BG priority
	ld   [s_Unused_LvlBGPriority], a; This is not actually read anywhere else
	
	;--
	push hl
	ld   hl, sPlFlags
	; Set or unset BG priority flag depending on value
	and  a							
	jr   z, .noPriority				
.bgpriority:
	set  7, [hl]
	jr   .cont0
.noPriority:
	res  7, [hl]
.cont0:
	pop  hl
	;--
	
	ldi  a, [hl]					; 9: Tile anim speed
	ld   [sLevelAnimSpeed], a
	
	ldi  a, [hl]					; A: Room Palette
	ld   [sBGP], a
	ldh  [rOBP1], a
	
	;
	; LEVEL GFX
	;
	
	ld   b, [hl]					; B: Bank number for level GFX
	inc  hl
	
	; HL = Ptr to level GFX (bytes C-D)
	;#
	ldi  a, [hl]
	;--
	push hl
	ld   h, [hl]
	ld   l, a
	;#
	
	ld   a, [sROMBank]
	push af
	ld   a, b						; Set the requested bank number
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call Level_CopyLevelGFX			; Copy the GFX over
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	pop  hl
	;--
	inc  hl
	
	;
	; BLOCK GFX
	;
	
	; HL = Ptr to shared block GFX (bytes E-F)
	;#
	ldi  a, [hl]
	;--
	push hl
	ld   h, [hl]
	ld   l, a
	;#
	ld   a, [sROMBank]
	push af
	ld   a, $11						; Block GFX are all in bank $11
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call Level_CopySharedBlockGFX
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	pop  hl
	;--
	inc  hl
	
	;
	; STATUS BAR GFX
	;
	
	; HL = Ptr to status bar GFX (bytes 10-11)
	;#
	ldi  a, [hl]
	;--
	push hl
	ld   h, [hl]
	ld   l, a
	;#
	ld   a, [sROMBank]
	push af
	ld   a, $11
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call Level_CopyStatusBarGFX
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	pop  hl
	;--
	inc  hl
	
	;
	; ANIMATED TILES GFX
	;
	
	; HL = Ptr to anim tiles GFX (bytes 12-13)
	;#
	ldi  a, [hl]
	;--
	push hl
	ld   h, [hl]
	ld   l, a
	;#
	ld   a, [sROMBank]
	push af
	ld   a, $11
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call Level_CopyAnimGFX
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	pop  hl
	;--
	inc  hl
	
	;
	; 16x16 BLOCKS
	;
	
	; HL = Ptr to 16x16 block data (bytes 14-15)
	;#
	ldi  a, [hl]
	;--
	push hl
	ld   h, [hl]
	ld   l, a
	;#
	ld   a, [sROMBank]
	push af
	ld   a, BANK(Level_CopyBlockData) ; BANK $0B
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call Level_CopyBlockData
	
	; If the switch block is active, use its 16x16 block data
	ld   a, [sLvlBlockSwitch]
	and  a
	call nz, Level_UseActiveSwitchBlock
	
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	pop  hl
	;--
	inc  hl
	
	;--
	; Draw the tiles for the visible screen
	push hl
	call Level_DrawFullScreen
	pop  hl
	;--
	
	;
	; ACTOR POINTER ROUTINE
	;
	
	; HL = Ptr to actor setup routine (bytes 16-17)
	ldi  a, [hl]
	ld   h, [hl]
	ld   l, a
	;--
	ld   a, [sROMBank]
	push af
	ld   a, $07
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call JumpHL
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	;--
	
	;-------------------------------------
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	ret
; =============== JumpHL ===============
JumpHL:
	jp   hl
	ret

; =============== Level_DoBlockSwitch ===============
; This subroutine performs the block replacement effect of ! Blocks.
; This is called during room transitions.
Level_DoBlockSwitch:
	; Is the block switch active?
	ld   a, [sLvlBlockSwitchReq]
	and  a
	ret  z
	
	; Two distinct (read: different block IDs) ! Blocks exist, for switching two different sets of tiles.
	; The two set the blockswitch flag in different ways.
	; Which one did we hit?
	cp   a, $01
	jr   z, Level_DoBlockSwitchType0
	cp   a, $10			
	jr   z, Level_DoBlockSwitchType1
	ret ; We never get here
	
; =============== mLvlReplaceBlock ===============	
; This macro generates code to replace the current block ID.
; IN
; - HL: Ptr to block ID in level layout
; -  1: New block ID
; -  2: Where to jump after the code is executed
mLvlReplaceBlock: MACRO
	dec  hl			; Rewind from ldi
	ld   a, [hl]	; Read back the block again
	and  a, $80		; Filter everything but the actor flag 
					; (we don't want to accidentaly delete actors over the block)
	add  \1		; Add the new tile value over.
	ldi  [hl], a
	jr   \2
ENDM
; =============== Level_DoBlockSwitchType0 ===============
; Type 0 Switch Block
; 
; $27 -> $7C
; $7C -> $27
; $7A -> $44
; $79 -> $45
Level_DoBlockSwitchType0:
	ld   hl, wLevelLayout
.loop:
	; Did we reach the end of the layout data?
	ld   a, h
	cp   a, HIGH(wLevelLayout_End)
	ret  z
	
	; Read the next block ID
	ldi  a, [hl]		; A = Block ID
	and  a, $7F			; Remove actor flag
	
	; If it's among these, replace it
	cp   a, $27
	jr   z, .block27
	cp   a, $7C
	jr   z, .block7C
	cp   a, $7A
	jr   z, .block7A
	cp   a, $79
	jr   nz, .loop
	
.block79: mLvlReplaceBlock $45, .loop
.block7C: mLvlReplaceBlock $27, .loop
.block27: mLvlReplaceBlock $7C, .loop
.block7A: mLvlReplaceBlock $44, .loop
	
; =============== Level_DoBlockSwitchType1 ===============
; Type 1 Switch Block
; 
; $55 -> $7C
; $7C -> $55
; $7A -> $7B
; $7B -> $7A
; $59 -> $5D [Never placed]
; $5D -> $59 [Never placed]
Level_DoBlockSwitchType1:
	ld   hl, wLevelLayout
.loop:
	; Did we reach the end of the layout data?
	ld   a, h
	cp   a, HIGH(wLevelLayout_End)
	ret  z
	
	; Read the next block ID
	ldi  a, [hl]
	and  a, $7F
	
	; Is it any of these blocks?
	cp   a, $7C
	jr   z, .block7C
	cp   a, $55
	jr   z, .block55
	cp   a, $7A
	jr   z, .block7A
	cp   a, $7B
	jr   z, .block7B
	
	; [TCRF] This switch block can replace block $5D into $59 and vice versa.
	;        But none are placed in level layouts with the Type1 ! Block.
	cp   a, $59
	jr   z, .block59
	cp   a, $5D
	jr   nz, .loop
.block5D: mLvlReplaceBlock $59, .loop
.block55: mLvlReplaceBlock $7C, .loop
.block7C: mLvlReplaceBlock $55, .loop
.block7B: mLvlReplaceBlock $7A, .loop
.block7A: mLvlReplaceBlock $7B, .loop
.block59: mLvlReplaceBlock $5D, .loop

; =============== Level_UseActiveSwitchBlock ===============
; Replaces the 16x16 block definition for the normal switch with
; the active one.
;
; This is done during room transitions after copying over the 16x16 blocks,
; since those only contain the un-active switch definition.
Level_UseActiveSwitchBlock:
	ld   hl, sLevelBlock_Switch2
	ld   a, TILE_SWITCH				; First tile ID with switch
	ldi  [hl], a
	inc  a
	ldi  [hl], a
	inc  a
	ldi  [hl], a
	inc  a
	ld   [hl], a
	
	ld   hl, sLevelBlock_Switch0
	ld   a, TILE_SWITCH
	ldi  [hl], a
	inc  a
	ldi  [hl], a
	inc  a
	ldi  [hl], a
	inc  a
	ld   [hl], a
	
	ld   hl, sLevelBlock_Switch1
	ld   a, TILE_SWITCH
	ldi  [hl], a
	inc  a
	ldi  [hl], a
	inc  a
	ldi  [hl], a
	inc  a
	ld   [hl], a
	
	ret
	
; =============== Level_CopyLevelGFX ===============
; Copies the main level GFX to VRAM.
; IN:
; - HL: Ptr to uncompressed GFX
Level_CopyLevelGFX:
	ld   de, vGFXLevelMain		; Fixed destination
	ld   bc, vGFXLevelMain_Size	; Always $600 bytes to copy
	call CopyBytesEx
	ret
	
; =============== Level_CopyStatusBarGFX ===============
; Copies the GFX for the status bar and misc OBJ (spinning coins, ...)
; IN:
; - HL: Ptr to uncompressed GFX
Level_CopyStatusBarGFX:
	ld   de, vGFXStatusBar
	ld   bc, vGFXStatusBar_Size
	call CopyBytesEx
	ret
	
; =============== Level_CopySharedBlockGFX ===============
; Copies the special block GFX (breakable bricks, coins, ! blocks, ...) to VRAM.
; IN:
; - HL: Ptr to uncompressed GFX
Level_CopySharedBlockGFX:
	ld   de, vGFXLevelSharedBlocks
	ld   bc, vGFXLevelSharedBlocks_Size
	call CopyBytesEx
	ret
; =============== LoadGFX_WarioWithPowerHat ===============
; Writes the necessary graphics to draw Wario's gameplay sprites with the current powerup status.
; This is meant to be used outside of the main gameplay mode that need to draw
; the correct hat (eg. Course Clear screen).
LoadGFX_WarioWithPowerHat:
	ld   a, [sROMBank]
	push af
	ld   a, BANK(GFX_Level_SharedOBJ)
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	ld   hl, GFX_Level_SharedOBJ
	call Level_CopySharedOBJGFX			; Draw Wario
	call LoadGFX_WarioPowerHat			; Draw correct hat
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	ret
	
; =============== Level_CopySharedOBJGFX ===============
; Copies the shared OBJ GFX for levels.
; This includes Wario, pots, hearts, ....
; [POI] This subroutine accepts an input paramrter, but it's always GFX_Level_SharedOBJ.
;       It may or may not imply this came from SML2, which did allow custom SharedOBJ.

; IN:
; - HL: Ptr to uncompressed GFX
Level_CopySharedOBJGFX:
	ld   de, vGFXLevelSharedOBJ
	ld   bc, vGFXLevelSharedOBJ_Size
	call CopyBytesEx
	ret

; =============== StopLCDOperation ===============
; Disables the screen output in a safe way.
;
; This will wait for VBlank before stopping the LCD.
StopLCDOperation:
	ldh  a, [rIE]			; Backup the interrupt enable flag
	ldh  [hIntEnable], a
	res  0, a				; And then disable all interrupts to prevent VBlank from triggering
	ldh  [rIE], a
.waitVBlank:
	ldh  a, [rLY]
	cp   a, $91
	jr   nz, .waitVBlank
	
	ldh  a, [rLCDC]			; Disable the LCD
	and  a, $FF ^ LCDC_ENABLE
	ldh  [rLCDC], a
	xor  a
	ldh  [rIF], a
	ldh  a, [hIntEnable]	; Restore interrupts
	ldh  [rIE], a
	ret

; =============== ClearBGMap ===============
; Clear the main tilemap at 0x9800 with tile 0x7F.
; If the hardcoded value isn't correct, ClearBGMapWithVal can be used to specify a custom tile ID.

ClearBGMap:
	ld   a, $7F
	
; =============== ClearBGMapWithVal ===============
; Clear the main tilemap at $9800 using the specified tile ID
; IN
; - A: Tile ID for overwriting
ClearBGMapWithVal:
	ld   hl, $9800		; HL = Ptr to VRAM Tilemap
	ld   bc, $0400		; BC = Bytes to clear
	call ClearRAMRange
	ret
	
; =============== ClearBGMap2F ===============
; Clear the main tilemap at 0x9800 with tile 0x2F.
; When this is called, it's expected to have a tileset loaded
; where tile 0x2F is a blank space.
ClearBGMap2F:
	ld   a, $2F
	jr   ClearBGMapWithVal
	
; =============== ClearWorkOAM ===============
; Clears the OAM copy area at 0xAF00-0xAF9F
ClearWorkOAM:
	ld   hl, sWorkOAM
	ld   b, $A0
	xor  a
.loop:
	ldi  [hl], a
	dec  b
	jr   nz, .loop
	ret
	
; =============== FinalizeWorkOAM ===============
; Blanks the leftover parts of the OAM copy.
; This is to make sure leftovers from the previous frame don't get drawn on screen.
FinalizeWorkOAM:
	ld   a, [sWorkOAMPos] ; L = WorkOAM offset
	ld   l, a
	ld   h, $AF ; Start HL setup for later
	ld   a, $A0 ; WorkOAM ends at 0xAFA0
	sub  a, l	; Get the amount of unused bytes to blank ($A0 - sWorkOAMPos)
				; If there aren't any, we can immediately return.
	ret  z

	ld   b, a   ; B = Bytes to clear.
	xor  a		
.loop:
	ldi  [hl], a
	dec  b
	jr   nz, .loop ; And clear them all until we've reached 0xAFA0
	ret
	
; =============== JoyKeys_Get ===============
; Performs input polling.
; Updates the values of hJoyKeys and hJoyNewKeys in the standard way.
;
; This also controls demo mode. 
; If demo mode is enabled, the demo input will be used instead of the joypad.
;
JoyKeys_Get:

	; Start off by creating the bitmask.
	
	; Get the directional key status
	ld   a, HKEY_SEL_DPAD 
	ldh  [rJOYP], a
	ldh  a, [rJOYP] ; Stabilize the inputs.
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	cpl				; Reverse the bits as the hardware marks pressed keys as '0'. We need the opposite.
	and  a, %1111	; ----DULR | Only use the actual keypress values (stored in the lower nybble)
	swap a			; DULR---- | And put them in the upper nybble for hJoyKeys
	ld   b, a		; Save to B the pressed D-Pad keys
	
	; Get the button status
	ld   a, HKEY_SEL_BTN
	ldh  [rJOYP], a
	ldh  a, [rJOYP] ; Stabilize the inputs.
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	ldh  a, [rJOYP]
	cpl
	and  a, %1111	; ----SCBA
	or   a, b		; DULRSCBA
	
	;--
	; Check for demo mode (which requires value $04)
	ld   c, a
	ld   a, [sDemoMode]
	cp   a, $04					; Are we in demo mode proper?
	jr   nz, .setKeys			; If not, store the real inputs into the addresses
	ld   a, c
	;--
	
	and  a, KEY_A|KEY_START 	; Are we stopping demo mode prematurely?
	jr   nz, .endDemo 			; If so, end it
	
	call HomeCall_Demo_GetInput ; If not, handle
	
	ld   a, [sDemoInputOffset]  ; Did we reach the end of the demo input table?
	cp   a, $80					
	ret  nz						; If not, return
	
	; Otherwise, end it
.endDemo:
	xor  a 										; Enable sound again
	ld   [sSoundDisable], a
	ld   a, [sDemoId] 							; Increase the demo index (which interestingly persists in SRAM)
	inc  a
	ld   [sDemoId], a
	ld   a, KEY_A|KEY_B|KEY_SELECT|KEY_START	; Trigger a soft reset to return to the title screen
	ldh  [hJoyKeys], a							; It will be processed just after returning
	ret
	
.setKeys:
	; Before setting updating the button status, calculate the newly pressed keys
	; C = hJoyKeys[new];
	ldh  a, [hJoyKeys]  ; A = hJoyKeys[old]
	; hJoyNewKeys = (hJoyKeys[old] ^ hJoyKeys[new]) & hJoyKeys[new]
	xor  a, c			
	and  a, c
	ldh  [hJoyNewKeys], a ; Save the new key status
	ld   a, c
	ldh  [hJoyKeys], a ; Save the key status
	
	ld   a, HKEY_SEL_BTN|HKEY_SEL_DPAD ; ?
	ldh  [rJOYP], a
	
	ret
	
; ========================================
; OAMDMA routine.
; Copied in HRAM during init (don't use this directly).
OAMDMACode:                             
	ld   a, $AF 	; Start DMA copy from WorkOAM (0xAF00) to OAM
	ldh  [rDMA], a
	ld   a, $28 	; Wait 0x28 ticks
.wait:                                
	dec  a
	jr   nz, .wait
	ret
OAMDMACode_End:	
; =============== ClearRAMRange_Mini ===============
; Lightweight RAM clear subroutine.
; Used for clearing less than 0xFF bytes of RAM.
;
; IN
; -  A: Overwrite with this value
; - HL: Start address
; -  B: Bytes to overwrite
ClearRAMRange_Mini:;CR
	ldi  [hl], a
	dec  b
	jr   nz, ClearRAMRange_Mini
	ret
	
; =============== ClearRAMRange ===============
; Clears a RAM range with the specified value.
;
; IN
; -  A: Overwrite with this value
; - HL: Start address
; - BC: Bytes to overwrite
ClearRAMRange:;C
	ld   d, a 			; Save for later
	
	; --
	; [TCRF] 
	; Because of the way decrementing BC works (decrement low byte, then check if $00),
	; when the amount of bytes to clear isn't a multiple of $100, we have to compensate for it by adding $100
	; However this is never the case! Calls to this subroutine always have the low byte $00.
	ld   a, c
	and  a
	jr   z, .noAdd100 	
	inc  b		
	;--

.noAdd100:;R
	ld   a, d
.loop:;R
	ldi  [hl], a
	dec  c 				; Decrement the low byte, then check.
						; When it's 0x00, it becomes 0xFF and counts as 0x100 extra bytes.
	jr   nz, .loop 	
	dec  b				; Decrement the high byte, then check
	jr   nz, .loop
	ret
	
; =============== CopyBytesEx ===============
; A copy loop for copying more than 256 bytes.
; IN:
; - HL: Source Ptr
; - DE: Destination Ptr
; - BC: Bytes to copy
CopyBytesEx:
	; [TCRF] Account for the pre-decrement
	;        if we aren't copying a multiple of $100 bytes.
	ld   a, c
	and  a
	jr   z, .loop
	inc  b 			; However it's never the case
.loop:
	ldi  a, [hl]
	ld   [de], a
	inc  de
	dec  c
	jr   nz, .loop
	dec  b
	jr   nz, .loop
	ret
	
; =============== CopyBytes ===============
; A simple copy loop for copying less than 256 bytes.
; IN:
; - HL: Source Ptr
; - DE: Destination Ptr
; -  B: Bytes to copy
;
; A typical use would be:
; - HL: Ptr to Uncompressed Graphics
; - DE: Ptr to tile data in VRAM
; -  B: Tiles to copy
CopyBytes:
	ldi  a, [hl]
	ld   [de], a
	inc  de
	dec  b
	jr   nz, CopyBytes
	ret
; =============== Level_CopyAnimGFX ===============
; Copies the entire animated tiles a level uses to RAM.
; The specific tiles/frames will be later copied to VRAM from that area.
; Called when loading a room.
;
; IN
; - HL: Ptr to animated graphics
Level_CopyAnimGFX:
	ld   b, $00 				; Copy $10 tiles ($100 bytes)
	ld   de, sLevelAnimGFX
	call CopyBytes
	ret
	
; =============== Wario_DoDashAfterimages ===============
; Performs the afterimage effect while dashing on the ground.
; Used for both main gameplay and the save select screen.
;
; This is handled through a table (Wario_DashAfterimageTbl) which allows 
; cycling through the seven different sprite mappings.
; Every entry in the table is an offset that gets added to the current anim frame,
; so it can be used with anything as long as there are seven frames.
;
; When the effect is first started, the currently visible frame should *always* be the last one:
; - For normal gameplay, this is OBJ_WARIO_DASH6
; - For the save screen, this is OBJ_SAVESEL_WARIO_DASH6
Wario_DoDashAfterimages:
	ld   hl, Wario_DashAfterimageTbl
	; Index++
	ld   a, [sPlTimer]	
	inc  a
	; Have we reached the end of the table? If so, reset the index.
	cp   a, (Wario_DashAfterimageTbl_End - Wario_DashAfterimageTbl)
	jr   nz, .setFrame
	xor  a
.setFrame:
	ld   [sPlTimer], a
	; Offset the table
	ld   e, a				; DE = Tbl index
	ld   d, $00
	add  hl, de				
	; Add the offset to the current frame id
	ld   a, [sPlLstId]	
	add  [hl]
	ld   [sPlLstId], a
	ret

; =============== Wario_DashAfterimageTbl ===============
; List of offsets to the current anim frame.
Wario_DashAfterimageTbl:
	db -$06
	db +$00
	db +$04
	db -$03
	db +$00
	db +$04
	db -$03
	db +$00
	db +$04
	db -$06
	db +$00
	db +$04
	db -$01
	db +$00
	db +$02
	db -$03
	db +$00
	db +$04
Wario_DashAfterimageTbl_End:

; =============== Wario_PlayWalkSFX ===============
; Two subroutines for plays the walking SFX every N number of frames.

Wario_PlayWalkSFX_Fast:
	; For fast movement (ie: walking with jet hat)
	ld   a, [sTimer]	; Do this every $08 frames
	and  a, $07
	ret  nz
	jr   Wario_PlayWalkSFX
Wario_PlayWalkSFX_Norm:
	; For normal movement
	ld   a, [sTimer]	; Do this every $0F frames
	and  a, $0F
	ret  nz
Wario_PlayWalkSFX:
	ld   a, SFX4_08
	ld   [sSFX4Set], a
	; Small Wario has its own SFX
	ld   a, [sSmallWario]
	and  a
	ret  z
	ld   a, SFX4_09
	ld   [sSFX4Set], a
	ret
	
; =============== ExActS_ClearRAM ===============
; This subroutine blanks the RAM range for extra actors ($AA00-$AAFF).
ExActS_ClearRAM:
	ld   hl, sExAct					; HL = Source
	ld   bc, sExActArea_End-sExAct	; BC = Bytes to clear
	xor  a							; Overwrite with $00
	call ClearRAMRange
	xor  a							; Reset actor count
	ld   [sExActCount], a
	ret
	
; =============== Map_ClearRAMInit ===============
; Clears all memory for the map screen.
; To be used only when the first initializing the map after selecting a save.
Map_ClearRAMInit:
	; Clear RAM range sLvlScrollY_High-A9FF
	ld   hl, sLvlScrollY_High
	ld   bc, $0100
	xor  a
	call ClearRAMRange
	; Clear map blink status (arrays with treasure ids marking uncollected treasures)
	; Replace all entries with the "no blink" $FF value.
	ld   hl, sMapRiceBeachBlink
	ld   b, $20
	ld   a, $FF
	call ClearRAMRange_Mini
	ret
	
; =============== Level_DecompressLayout ===============
; This subroutine decompresses the level layout.
; NOTE: While the layout data starts as $C000, the level data also
;       writes to the $B000-$DFFF area.
; IN
; - A: ID of level layout (relative to the currently loaded bank)
Level_DecompressLayout:
	; This subroutine expects a layout data bank to be loaded.
	; These banks must always contain at $4000 a ptr table which indexes the layout data ptrs.
	
	; Index the ptr table
	add  a			
	ld   e, a			; DE = LayoutID * 2
	ld   d, $00
	ld   hl, $4000		; HL = Layout ptr table
	add  hl, de
	
	; DE = Ptr to RLE-compressed level layout data
	ldi  a, [hl]
	ld   e, a
	ld   d, [hl]
	
	ld   hl, $B000		; HL = Destination
	
.nextCmd:
	ld   a, [de]		; Read the byte
	; If the byte has the MSB set, it's a copy command
	bit  7, a			
	jr   nz, .copyCmd	
	; Otherwise it's raw data
	ldi  [hl], a	
	
.checkEnd:
	; If we reached ECHO RAM, we're done
	ld   a, h			
	cp   a, HIGH($E000)
	ret  z
	
	inc  de				; Next value
	jr   .nextCmd
.copyCmd:
	; Copy command
	
	; The the current byte (minus MSB) is treated as the value to repeat
	and  a, $7F			; Clear MSB
	ld   b, a			; B = Value used
	
	; The next byte is treated as the amount of times to repeat the copy
	inc  de				
	ld   a, [de]
	ld   c, a			; C = CopyCount + 1
	inc  c
	; Perform the repeated copy
	ld   a, b
.repeatCopy:
	ldi  [hl], a
	dec  c
	jr   nz, .repeatCopy
	jr   .checkEnd
	
; =============== ExActBGColi_DragonHatFlame* ===============
; Sets of wrappers to the subroutine for handling block collision
; for the dragon hat flame.
;
; Each of these is used to check at a different distance in front of the player,
; because the flame grows and shrinks near the start and the end of the action.
ExActBGColi_DragonHatFlame_08:
	ld   b, $08						; $08px in front (start/end)
	jr   ExActBGColi_DragonHatFlame
ExActBGColi_DragonHatFlame_18:
	ld   b, $18						; $18px in front (start/end)
	jr   ExActBGColi_DragonHatFlame
ExActBGColi_DragonHatFlame_28:
	ld   b, $28						; $28px in front (normal)
	jr   ExActBGColi_DragonHatFlame
	
; =============== ExActBGColi_DragonHatFlame ===============
; Handles block collision for the dragon hat flame against blocks.
; This is used to destroy blocks in front of the player and trigger item boxes.
; IN
; - B: X target in front of the player
; OUT
; - A: If set, the block was solid (not used)
ExActBGColi_DragonHatFlame:
	xor  a
	ld   [sPl_Unused_DragonFlameBGColiSolid], a
	
	
	; Set collision target for the flame, and get the level layout ptr for it.
	
	;
	; X COORD
	;
	
	; Determine where the front of the player is, so we can set the appropriate target.
	; This is the same direction the current ExAct (the dragon flame) is facing.
	ld   a, [sExActOBJFlags]	
	bit  OBJLSTB_XFLIP, a		; Player facing right?
	jr   z, .setLeft			; If not, check for coli on left
	call PlTarget_SetRightPos
	jr   .setXOffset
.setLeft:
	call PlTarget_SetLeftPos
.setXOffset:
	call PlBGColi_GetXBlockOffset	; L = Low byte of level layout ptr
	ld   a, l						; Save it
	ld   [sBlockTopLeftPtr_Low], a
	;--
	
	;
	; Y COORD
	;
	; The value is relative to the ExAct Y pos, which is for the dragon hat flame.
	; This is to make sure it always uses the correct Y position, even when crouching.
	ld   b, $04						; 4px above the hat
	call ExActOBJTarget_SetUpPos
	call PlBGColi_GetYBlockOffset	; H = Offset to high byte of level layout ptr
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	
	;
	; LEVEL LAYOUT PTR
	;
	; Get the pointer to the level layout by adding it to the level layout base ptr
	ld   de, wLevelLayout
	add  hl, de						; HL = Level layout ptr
	ld   a, h						; H = High byte of level layout ptr
	ld   [sBlockTopLeftPtr_High], a	; Save it
	;--
	call ExActBGColi_DragonHatFlame_CheckBlockId
	; [TCRF] The return value is never used anywhere.
	;        Just calling the previous subroutine performs the block smash effect.
	and  a				; Is the block empty?
	jr   z, .end		; If so, jump
	ld   a, $01
	ld   [sPl_Unused_DragonFlameBGColiSolid], a
.end:
	ret
	
; =============== ExActBGColi_DragonHatFlame_CheckBlockId ===============
; Performs the actual block collision check for the dragon hat flame.
; IN
; - HL: Ptr to level layout
; OUT
; - A: Base collision type (COLI_*)
ExActBGColi_DragonHatFlame_CheckBlockId:
	ld   a, [hl]							; Read the block ID
	and  a, $7F								; Clear actor flag
	ld   [sPlBGColi_Unused_LastBlockId], a
	; Perform standard block ID check
	cp   a, BLOCKID_SOLID_END				; < $28?
	jp   c, BGColi_Solid					; If so, all fully solid
	cp   a, BLOCKID_EMPTY					; < $60?
	jr   c, .checkDetail					; If so, *check more*
	jp   BGColi_Empty						; Otherwise, all fully empty
.checkDetail:
	sub  a, BLOCKID_SOLID_END				; - $28
	rst  $28
	dw BGColi_HitItemBox ; 28 
	dw BGColi_BreakHardToEmpty7F ; 29 
	dw BGColi_BreakToEmpty7F ; 2A 
	dw BGColi_BreakHardToEmpty7E ; 2B 
	dw BGColi_BreakToEmpty7E ; 2C 
	dw BGColi_BreakToDoorTop7D ; 2D 
	dw BGColi_BreakToDoor48 ; 2E 
	dw BGColi_Solid ; 2F ;X
	dw BGColi_Solid ; 30 ;X
	dw BGColi_Solid ; 31 ;X
	dw BGColi_Solid ; 32 ;X
	dw BGColi_Empty ; 33 ;X
	dw BGColi_Solid ; 34 
	dw BGColi_Solid ; 35 ;X
	dw BGColi_Solid ; 36 
	dw BGColi_HitItemBox ; 37 ;X
	dw BGColi_Solid ; 38 ;X
	dw BGColi_Solid ; 39 ;X
	dw BGColi_Solid ; 3A 
	dw BGColi_Solid ; 3B ;X
	dw BGColi_Solid ; 3C 
	dw BGColi_Empty ; 3D ;X
	dw BGColi_Empty ; 3E 
	dw BGColi_Empty ; 3F 
	dw BGColi_Empty ; 40 
	dw BGColi_Empty ; 41 
	dw BGColi_Empty ; 42 
	dw BGColi_Empty ; 43 
	dw BGColi_Empty ; 44 
	dw BGColi_Empty ; 45 
	dw BGColi_Empty ; 46 
	dw BGColi_Empty ; 47 
	dw BGColi_Empty ; 48 
	dw BGColi_HitItemBox ; 49 
	dw BGColi_Empty ; 4A ;X
	dw BGColi_Empty ; 4B 
	dw BGColi_Empty ; 4C ;X
	dw BGColi_Empty ; 4D ;X
	dw BGColi_Empty ; 4E 
	dw BGColi_Empty ; 4F 
	dw BGColi_BreakHardToWater58 ; 50 
	dw BGColi_BreakToWater58 ; 51 
	dw BGColi_BreakToWaterDoorTop5B ; 52 
	dw BGColi_Empty ; 53 
	dw BGColi_BreakToWaterDoor4B ; 54 
	dw BGColi_Empty ; 55 
	dw BGColi_Empty ; 56 ;X
	dw BGColi_Empty ; 57 
	dw BGColi_Empty ; 58 
	dw BGColi_Empty ; 59 ;X
	dw BGColi_Empty ; 5A ;X
	dw BGColi_Empty ; 5B 
	dw BGColi_Empty ; 5C ;X
	dw BGColi_Empty ; 5D ;X
	dw BGColi_Empty ; 5E ;X
	dw BGColi_Empty ; 5F ;X
; =============== PlBGColi_GetBlockIdLow ===============
; Gets the active block ID the player is colliding with in the low part of the body.
; See also: PlBGColi_CheckLadderLow
; OUT
; - A: Block ID (with priority)
; - sPlBgColiBlockEq: If intersecting two blocks with the same ID
PlBGColi_GetBlockIdLow:
	xor  a
	ld   [sPlBgColiBlockEq], a
	
	;--
	; Get the block ID for the normal-left player location

	; Save the block X offset to sBlockTopLeftPtr_Low
	ld   b, $03					; 3px left
	call PlTarget_SetLeftPos
	call PlBGColi_GetXBlockOffset
	ld   a, l					; Save offset
	ld   [sBlockTopLeftPtr_Low], a
	
	; Save the block's Y offset to sBlockTopLeftPtr_High
	ld   b, $04					; 4px up, which is enough to not be at ground level
	call PlTarget_SetUpPos
	call PlBGColi_GetYBlockOffset
	ld   a, h
	ld   [sBlockTopLeftPtr_High], a
	
	; Offset the block pointer
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	ld   de, wLevelLayout
	add  hl, de
	ld   a, [hl]
	and  a, $7F
	ld   [sPlBGColiBlockId], a
	;--
	; Do the same thing for the normal-right corner.
	; (with same Y coord; so H is not updated)
	
	; Save the block X offset to sBlockTopLeftPtr_Low
	ld   b, $03 					; 3px right
	call PlTarget_SetRightPos
	call PlBGColi_GetXBlockOffset
	ld   a, l
	ld   [sBlockTopLeftPtr_Low], a
	; HL = Index to level layout
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	; Get the pointer to the level layout by adding it to the level layout base ptr
	ld   de, wLevelLayout
	add  hl, de
	; Get the block ID for the top-right corner
	ld   a, [hl]
	and  a, $7F			; Remove actor flag
	;--
	
	; Is it the same block ID as the top-left corner?
	ld   b, a
	ld   a, [sPlBGColiBlockId]		; A = top-left  block id		
	cp   a, b						; B = top-right block id
	jr   z, .blockEq
	
	; Pick the block with the lower ID, which generally gives priority to solid blocks
	; Is A < B?
	jr   c, .end
.blockGt:
	ld   a, b		; If not, pick B
	jr   .end
.blockEq:
	ld   a, $01		; Flag equality
	ld   [sPlBgColiBlockEq], a
	ld   a, b
.end:
	ret
	
; =============== PlBGColi_DoDash ===============
; Handles block collision when ground dashing or jet dashing.
; OUT
; - sPlDashSolidHit: If the dash should be over
PlBGColi_DoDash:
	xor  a
	ld   [sPlDashSolidHit], a
	
	; Get the block IDs for the blocks in front of the player.
	; Unlike most other subroutines for handling collision, this one will handle
	; two blocks at once, which is necessary because of how the dash works.
	
	;--
	;
	; LOWER BLOCK
	;
	
	; Calculate and save the block X offset sBlockTopLeftPtr_Low (shared across lower/higher blocks)
	; Depending on which direction we're facing, pick a different X pos.
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a
	jr   z, .left
.right:
	ld   b, $08						; 8px right	
	call PlTarget_SetRightPos
	jr   .setXTarget
.left:
	ld   b, $08						; 8px left
	call PlTarget_SetLeftPos
.setXTarget:
	call PlBGColi_GetXBlockOffset
	ld   a, l						; Save val
	ld   [sBlockTopLeftPtr_Low], a
	
	; Calculate and save the block Y offset sBlockTopLeftPtr_High
	; Y target 
	ld   b, $04						; 4px up
	call PlTarget_SetUpPos
	call PlBGColi_GetYBlockOffset
	ld   a, [sBlockTopLeftPtr_Low]	; Save val
	ld   l, a
	; Get the pointer to the level layout by adding it to the level layout base ptr
	; We also need it to know the proper sBlockTopLeftPtr_High value
	ld   de, wLevelLayout
	add  hl, de
	ld   a, h
	ld   [sBlockTopLeftPtr_High], a
	
	;--
	push hl
	; Handle the block collision for the block
	call PlBGColi_DoDash_CheckBlock
	cp   a, COLI_SOLID		; Is there a solid block?
	jr   nz, .noSolidD		; If not, skip this
	ld   a, $01				; Otherwise, signal the dash to be over
	ld   [sPlDashSolidHit], a
.noSolidD:
	pop  hl
	;--
	
	;
	; HIGHER BLOCK
	;
	; Decrement the H coordinate of the block ptr.
	; This results in selecting the block above, because of the level width of $100 blocks.
	dec  h				
	ld   a, h
	ld   [sBlockTopLeftPtr_High], a
	; Handle the collision for that too
	call PlBGColi_DoDash_CheckBlock
	cp   a, COLI_SOLID	; Is there a solid block?
	jr   nz, .noSolidU	; If not, skip this
	ld   a, $01			; Otherwise, signal the dash to be over
	ld   [sPlDashSolidHit], a
.noSolidU:
	ret
	
; Top solid block collision when falling
BGColi_TopSolid:
	ld   a, [sPlY_Low]
	and  a, BLOCK_HEIGHT-1	; Values relative to the block height
	cp   a, $04				; Is the player 3px or less near the top of the block?
	jr   nc, BGColi_Empty	; If not, treat as an empty block.

; =============== Collision type results ===============
; Target subroutines usually for block collision jump tables indexed by block ID.
;
; Multiple jump tables are defined for different actions (jumping; falling down/ground pound, swim, etc...).
; Picking a combination of different target subroutines for the different jump tables
; allows for special effects, like those which are solid on top only.
; OUT
; - A: Collision type
BGColi_Solid:
	ld   a, COLI_SOLID
	ret
	
BGColi_Empty:
	xor  a ; COLI_EMPTY
	ret
	
; Collision for disappearing/reapparing platform.
; These are aligned with the $00-$03 tile anim frames.
BGColi_TimedSolid0:
	; Frame 0 is the empty one
	ld   a, [sLevelAnimFrame]
	and  a
	jr   z, BGColi_Empty
	; Otherwise treat like a normal platform
	jr   BGColi_TopSolid
BGColi_TimedSolid1:
	; Frame 2 is the empty one
	ld   a, [sLevelAnimFrame]
	cp   a, $02
	jr   z, BGColi_Empty
	; Otherwise treat like a normal platform
	jr   BGColi_TopSolid
	
; =============== PlBGColi_DoDash_CheckBlock ===============
; Performs the actual collision check for a single block during a dash.
; This will be called twice, since a dash interacts with two blocks at once.
; IN
; - HL: Ptr to block ID
; OUT
; - A: Base collision type (COLI_*)
; - (many other flags): For the detailed collision types, like sand or ice
PlBGColi_DoDash_CheckBlock:
	ld   a, [hl]		; Read the block ID
	and  a, $7F			; Remove actor flag
	ld   [sPlBGColi_Unused_LastBlockId], a ; [TCRF] Not read anywhere
	
	; Usual rules for handling block collision
	cp   a, BLOCKID_SOLID_END	; < $28?
	jr   c, BGColi_Solid		; If so, all solid
	cp   a, BLOCKID_EMPTY		; < $60?
	jr   c, .checkMisc			; If so, it depends
	jr   BGColi_Empty			; The rest is all empty
.checkMisc:
	sub  a, BLOCKID_SOLID_END
	rst  $28
	
	; [BUG] This list has problems.
	;       The spike blocks are set as "empty", which is why dashing on spikes
	;       is perfectly safe.
	
	dw BGColi_HitItemBox ; 28 
	dw BGColi_BreakHardToEmpty7F ; 29 
	dw BGColi_BreakToEmpty7F ; 2A 
	dw BGColi_BreakHardToEmpty7E ; 2B 
	dw BGColi_BreakToEmpty7E ; 2C 
	dw BGColi_BreakToDoorTop7D ; 2D 
	dw BGColi_BreakToDoor48 ; 2E 
	dw BGColi_Solid ; 2F ;X
	dw BGColi_Solid ; 30 
	dw BGColi_Solid ; 31 ;X
	dw BGColi_Solid ; 32 ;X
	dw BGColi_Empty ; 33 ;X
	dw BGColi_Solid ; 34 
	dw BGColi_Solid ; 35 ;X
	dw BGColi_Solid ; 36 
	dw BGColi_HitItemBox ; 37 ;X
	dw BGColi_Solid ; 38 ;X
	dw BGColi_Solid ; 39 ;X
	dw BGColi_TimedSolid0 ; 3A 
	dw BGColi_TimedSolid1 ; 3B 
	dw BGColi_Solid ; 3C 
	dw BGColi_Empty ; 3D ;X
	dw BGColi_Empty ; 3E 
	dw BGColi_Empty ; 3F 
	dw BGColi_Empty ; 40 
	dw BGColi_Empty ; 41 
	dw BGColi_Empty ; 42 
	dw BGColi_Empty ; 43 
	dw BGColi_Empty ; 44 
	dw BGColi_Empty ; 45 
	dw BGColi_CoinToEmpty7F ; 46 
	dw BGColi_CoinToEmpty7E ; 47 
	dw BGColi_Empty ; 48 
	dw BGColi_HitItemBox ; 49 
	dw BGColi_Empty ; 4A ;X
	dw BGColi_Empty ; 4B 
	dw BGColi_Empty ; 4C 
	dw BGColi_Empty ; 4D 
	dw BGColi_Empty ; 4E 
	dw BGColi_Empty ; 4F 
	dw BGColi_BreakHardToWater58 ; 50 
	dw BGColi_BreakToWater58 ; 51 
	dw BGColi_BreakToWaterDoorTop5B ; 52 
	dw BGColi_CoinToWater58 ; 53 
	dw BGColi_BreakToWaterDoor4B ; 54 
	dw BGColi_Empty ; 55 
	dw BGColi_Empty ; 56 
	dw BGColi_Empty ; 57 
	dw BGColi_Empty ; 58 
	dw BGColi_Empty ; 59 
	dw BGColi_Empty ; 5A ;X
	dw BGColi_Empty ; 5B 
	dw BGColi_Empty ; 5C ;X
	dw BGColi_Empty ; 5D 
	dw BGColi_Empty ; 5E ;X
	dw BGColi_Empty ; 5F ;X
; =============== BGColi_HitItemBox ===============
; This subroutine is called when hitting an item box.
; It replaces the block with the used item box, and optionally spawns a coin.
BGColi_HitItemBox:
	; HL = Level layout ptr for the hit item box
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	; Get the actor ID inside the block (if any).
	; Note that the MSB which normally marks in the *level layout* if there's an actor
	; (in this case, an item) inside the item box can't be used.
	; Like all other actors, it gets removed while it's on-screen, even when hidden.
	; So to detect if the box has an item, we have to read it from the *actor layout* in RAM.
	push hl
	call HomeCall_ActS_GetIdByLevelLayoutPtr2
	pop  hl
	;--
	
	; Preserve the actor flag if there's one.
	; (only difference between branches)
	ld   a, [sLvlLayoutPtrActId]
	and  a							; Is there any actor in the box?
	jr   z, .noActor				; If not, jump
	
	; Write the new block ID over.
	; Also, set the MSB of the block ID to mark the item box as being hit.
	; This signals out to Act_ItemInBox (the code for the actor hidden in the box)
	; to make the item visible.
	ld   a, BLOCKID_ITEMUSED		; Used item box
	add  $80						; Make item appear
	ld   [hl], a
	call GetBGMapOffsetFromBlock
	
	; However, draw the block as empty to hide it while the hit anim plays
	ld   a, $7F						
	call Level_WriteBlockToBG
	
.writeExAct:
	; Spawn the actor for the hit block anim
	call ExActS_CopySetToSet2
	ld   a, EXACT_ITEMBOXHIT
	ld   [sExActSet], a
	mExActS_SetCenterBlock
	ld   a, OBJ_HITBLOCK
	ld   [sExActOBJLstId], a
	ld   a, $00
	ld   [sExActOBJFlags], a
	ld   a, [sBlockTopLeftPtr_High]
	ld   [sExActLevelLayoutPtr_High], a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   [sExActLevelLayoutPtr_Low], a
	; Clear rest of unused space
	ld   hl, sExActRoutineId
	xor  a
	ld   b, $07
	call ClearRAMRange_Mini
	call ExActS_Spawn
	
	; If there isn't an actor in the box, default to spawning a single coin.
	; The actors (hearts, powerups, ...) will handle the popup anim by themselves,
	; so we don't need to do anyhing for those here.
	ld   a, [sLvlLayoutPtrActId]
	and  a									; Is there an actor?
	jr   nz, .noCoinBox						; If so, jump
	call SubCall_ActS_SpawnCoinFromBlock
.noCoinBox:
	call ExActS_CopySet2ToSet
	ld   a, $01
	ret
.noActor:
	ld   a, BLOCKID_ITEMUSED
	ld   [hl], a
	call GetBGMapOffsetFromBlock
	ld   a, $7F
	call Level_WriteBlockToBG
	jr   .writeExAct
	
; =============== Breakable block handler macros ===============
	
; =============== mBGColi_BreakGroundPound ===============
; Generates code to check if we're ground pounding on a breakable block.
; IN
; - 1: Label to subroutine for breaking the block.
mBGColi_BreakGroundPound: MACRO
	; Is the player ground pounding?
	ld   a, [sPlLstId]
	cp   a, OBJ_WARIO_GROUNDPOUND
	jr   z, \1
	cp   a, OBJ_WARIO_HOLDGROUNDPOUND
	jr   z, \1
	; If not, treat as solid
	ld   a, COLI_SOLID
	ret
ENDM

; =============== mBGColi_BreakHardToEmpty ===============
; Generates code to check if we can directly break an hard breakable block.
; If we're Bull Wario, execution falls through the macro, so this 
; should only be placed before invoking mBGColi_BreakToBlockId.
mBGColi_BreakHardToEmpty: MACRO
	; If we aren't Bull Wario, we can't instantly break the block
	ld   a, [sPlPower]
	cp   a, PL_POW_BULL
	jr   nz, BGColi_BreakHardToNext
ENDM

; =============== mBGColi_BreakToBlockId ===============
; Generates code for breaking a breakable block.
; IN
; - 1: New block ID
mBGColi_BreakToBlockId: MACRO
	; Get the ptr to the block we're destroying
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	; Replace with empty block ID $7F, preserving any actors
	ld   a, [hl]
	and  a, $80		; A = Block ID with actor flag
	add  \1
	ld   [hl], a
	
	; Get the tilemap offset and write to it the 8x8 tiles of the new block
	ld   [sTmp_A9EE], a
	call GetBGMapOffsetFromBlock	; HL = Tilemap offset
	ld   a, [sTmp_A9EE]				; A  = Block ID
	call Level_WriteBlockToBG
	
	; [TCRF] Always replaced by a SFX4_0B in ActS_SpawnBlockBreak
	ld   a, SFX4_0A
	ld   [sSFX4Set], a
	
	call ActS_SpawnBlockBreak
	; Treat the destroyed block as solid.
	; This prevents the the dash from continuing
	ld   a, COLI_SOLID
	ret
ENDM
	
BGColi_BreakToEmpty7FGroundPound:	mBGColi_BreakGroundPound BGColi_BreakToEmpty7F
BGColi_BreakHardToEmpty7F:			mBGColi_BreakHardToEmpty
BGColi_BreakToEmpty7F:				mBGColi_BreakToBlockId $7F
BGColi_BreakToEmpty7EGroundPound:	mBGColi_BreakGroundPound BGColi_BreakToEmpty7E
BGColi_BreakHardToEmpty7E:			mBGColi_BreakHardToEmpty
BGColi_BreakToEmpty7E:				mBGColi_BreakToBlockId $7E
; =============== BGColi_BreakHardToNext ===============
; Updates the breakable block to its cracked variant by increasing the block ID.
; This is generic reused for multiple blocks, since they hall put the cracked block
; after the hard breakable block.
BGColi_BreakHardToNext:
	; Get the ptr to the block we're destroying
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	; BlockID++ (to switch to the cracked block)
	ld   a, [hl]
	inc  a
	ld   [hl], a
	; Get the tilemap offset and write to it the 8x8 tiles of the new block
	ld   [sTmp_A9EE], a
	call GetBGMapOffsetFromBlock
	ld   a, [sTmp_A9EE]
	call Level_WriteBlockToBG
	
	ld   a, SFX4_0A
	ld   [sSFX4Set], a
	
	ld   a, COLI_SOLID
	ret
BGColi_BreakHardToWater58:			mBGColi_BreakHardToEmpty
BGColi_BreakToWater58: 				mBGColi_BreakToBlockId $58
BGColi_BreakToWaterDoor4B:			mBGColi_BreakToBlockId $4B
BGColi_BreakToDoor48GroundPound:	mBGColi_BreakGroundPound BGColi_BreakToDoor48
BGColi_BreakToDoor48: 				mBGColi_BreakToBlockId $48
BGColi_BreakToDoorTop7DGroundPound:	mBGColi_BreakGroundPound BGColi_BreakToDoorTop7D
BGColi_BreakToDoorTop7D:			mBGColi_BreakToBlockId $7D
BGColi_BreakToWaterDoorTop5B:		mBGColi_BreakToBlockId $5B

BGColi_Switch0Type0:
	; Handler for hitting a switch
	ld   a, $20						; Shake for $20 frames
	ld   [sScreenShakeTimer], a
	ld   a, SFX4_18		; Play SFX
	ld   [sSFX4Set], a
	ld   a, $01
	ld   [sPlScreenShake], a
	ld   a, [sLvlBlockSwitchReq]	; Reverse the switch block status
	xor  $01
	ld   [sLvlBlockSwitchReq], a
	; HL = Level layout ptr
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	; Replace with empty block $7F (to hide the block while the hit anim plays)
	call GetBGMapOffsetFromBlock
	ld   a, $7F
	call Level_WriteBlockToBG
	ld   a, EXACT_SWITCH0TYPE0HIT
	ld   [sExActSet], a
	
; =============== ExActS_SpawnSwitchHit ===============
; This subroutine spawns the actor which performs the "switch hit" animation (the white box),
; similarly to what's done for item boxes and bounce blocks.
; Like those, during the time this actor is active, the original block shouldn't be visible.
; So the block should appear as blank ($7F), but not actually be a blank block.
;
; NOTE: The actor ID should have been set previously to sExActSet, since
;       it changes depending on which block was hit.
ExActS_SpawnSwitchHit:
	mExActS_SetCenterBlock
	
	ld   a, OBJ_HITBLOCK
	ld   [sExActOBJLstId], a
	ld   a, $00
	ld   [sExActOBJFlags], a
	ld   a, [sBlockTopLeftPtr_High]
	ld   [sExActLevelLayoutPtr_High], a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   [sExActLevelLayoutPtr_Low], a
	; Clear rest of exact space
	ld   hl, sExActRoutineId
	xor  a
	ld   b, $07
	call ClearRAMRange_Mini
	call ExActS_Spawn
	ld   a, COLI_SOLID
	ret
; [TCRF] Secondary switch block.
;        This could have been used to have two separate switch effects in a single level,
;        since its status is saved in an otherwise unused variable.
;        However, there's no code for handling that variable so it won't work.
BGColi_Unused_Switch1Type1: 
	; Handler for hitting a switch
	ld   a, $20						; Shake for $20 frames
	ld   [sScreenShakeTimer], a
	ld   a, SFX4_18		; Play SFX
	ld   [sSFX4Set], a
	ld   a, $01
	ld   [sPlScreenShake], a
	ld   a, [sLvl_Unused_BlockSwitch1Req]	; Reverse the switch block status
	xor  $01
	ld   [sLvl_Unused_BlockSwitch1Req], a
	; HL = Level layout ptr
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	; Replace with empty block $7F (to hide the block while the hit anim plays)
	call GetBGMapOffsetFromBlock
	ld   a, $7F
	call Level_WriteBlockToBG
	; It also uses its own OBJ for the hit effect
	; This is the only indicator that it triggers something different.
	ld   a, EXACT_UNUSED_SWITCH1TYPE0HIT
	ld   [sExActSet], a
	jr   ExActS_SpawnSwitchHit

BGColi_Switch0Type1:
	; Handler for hitting a switch
	ld   a, $20						; Shake for $20 frames
	ld   [sScreenShakeTimer], a
	ld   a, SFX4_18		; Play SFX
	ld   [sSFX4Set], a
	ld   a, $01
	ld   [sPlScreenShake], a
	ld   a, [sLvlBlockSwitchReq]	; Reverse the switch block status
	xor  $10
	ld   [sLvlBlockSwitchReq], a
	; HL = Level layout ptr
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	; Replace with empty block $7F (to hide the block while the hit anim plays)
	call GetBGMapOffsetFromBlock
	ld   a, $7F
	call Level_WriteBlockToBG
	ld   a, EXACT_SWITCH0TYPE1HIT
	ld   [sExActSet], a
	jp   ExActS_SpawnSwitchHit
	
BGColi_CoinToEmpty7F:
	; HL = Level layout ptr
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	; Replace with empty block $7F
	ld   a, [hl]
	and  a, $80
	add  $7F
	ld   [hl], a
	; Write the updated 8x8 tiles
	ld   [sTmp_A9EE], a
	call GetBGMapOffsetFromBlock
	ld   a, [sTmp_A9EE]
	call Level_WriteBlockToBG
	; Collect the coin
	call Game_AddCoin
	xor  a ; COLI_EMPTY
	ret
BGColi_CoinToEmpty7E:
	; HL = Level layout ptr
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	; Replace with empty block $7E
	ld   a, [hl]
	and  a, $80
	add  $7E
	ld   [hl], a
	; Write the updated 8x8 tiles
	ld   [sTmp_A9EE], a
	call GetBGMapOffsetFromBlock
	ld   a, [sTmp_A9EE]
	call Level_WriteBlockToBG
	; Collect the coin
	call Game_AddCoin
	xor  a ; COLI_EMPTY
	ret
BGColi_CoinToWater58:
	; HL = Level layout ptr
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	; Replace with water block $58
	ld   a, [hl]
	and  a, $80
	add  $58
	ld   [hl], a
	; Write the updated 8x8 tiles
	ld   [sTmp_A9EE], a
	call GetBGMapOffsetFromBlock
	ld   a, [sTmp_A9EE]
	call Level_WriteBlockToBG
	; Collect the coin
	call Game_AddCoin
	ld   a, COLI_WATER
	ret
; =============== PlBGColi_CheckLadderLow ===============
; This determines the collision type for ladders, based on the block the lower part of the player collides with.
; As a general note across all block collision checking, if the player stands between two blocks, 
; the one with less priority is ignored.
; In this one is slightly different, since if any of said two blocks
; is a ladder, you are allowed to climb it (ignoring the other value, unless it's solid).
; OUT
; - A: Ladder collision type. If != 0, there's a ladder.
; - sPlBGColiBlockId: Block ID collided with (ground-left)
; - B: Block ID collided with (ground-right)
PlBGColi_CheckLadderLow:

	; We need to pick the target coordinates, relative to the player, used to check for collision.
	; With the coordinates known, we can determine the block ID they are over.
	
	; The coordinates for the ladder check are in the bottom-left and bottom-right corners of the level.
	; 
	; What's needed here is the block IDs for the player's bottom-left and bottom-right corners fall in.
	; Only the two corners are needed, since the player's width is less than the block width
	; and as such can only collide with two blocks horizontally at most.

	; Save the block X offset to sBlockTopLeftPtr_Low
	ld   b, $04					; 4px left
	call PlTarget_SetLeftPos
	call PlBGColi_GetXBlockOffset
	ld   a, l					; Save offset
	ld   [sBlockTopLeftPtr_Low], a
	
	; Save the block's Y offset to sBlockTopLeftPtr_High
	ld   b, $02					; 2px up, which is enough to not be at ground level
	call PlTarget_SetUpPos
	call PlBGColi_GetYBlockOffset
	ld   a, h
	ld   [sBlockTopLeftPtr_High], a
	
	; HL = Index to level layout
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	
	; Offset the level layout base with it
	ld   de, wLevelLayout
	add  hl, de
	
	; Save the block ID for the bottom-left corner
	ld   a, [hl]
	and  a, $7F			; Remove actor flag
	ld   [sPlBGColiBlockId], a
	;--
	
	; Do the same thing for the bottom-right corner.
	; (with same Y coord; so H is not updated)
	
	; Save the block X offset to sBlockTopLeftPtr_Low
	ld   b, $04						; 4px right
	call PlTarget_SetRightPos
	call PlBGColi_GetXBlockOffset
	ld   a, l
	ld   [sBlockTopLeftPtr_Low], a
	; HL = Index to level layout
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	; Get the pointer to the level layout by adding it to the level layout base ptr
	ld   de, wLevelLayout
	add  hl, de
	; Get the block ID for the bottom-right corner
	ld   a, [hl]
	and  a, $7F			; Remove actor flag
	ld   b, a
	
	; Is it the same block ID as the bottom-left corner?
	ld   a, [sPlBGColiBlockId]		; A = bottom-left  block id		
	cp   a, b						; B = bottom-right block id
	jr   z, .blockEq
	
	; Is A < B?
	; This is for the general case also used elsewhere to pick the block ID lower in value, 
	; which gives higher priority to solid blocks.
	; This also works partially for ladder collision, when close to an empty block (which have an higher ID),
	; but *not* when close to top-solid blocks (see .solidTop).
	jr   c, .blockLt	
.blockGt:
	ld   a, b			; A > B, so pick B
.blockLt:
	; Depending on the block ID, report the collision type.
	cp   a, BLOCKID_MISCSOLID_END	; < $40?
	jr   c, .solid		
	cp   a, BLOCKID_LADDER			; < $44?
	jr   c, .solidTop
	jr   z, .ladder					; == $44?
	cp   a, BLOCKID_LADDERTOP
	jr   z, .ladderTop				; == $45?
	jr   .solid
.solidTop:
	; Ladders are a special case since they should have more priority than top-solid platforms,
	; even though ladders have higher block ID than those.
	; This is because you should be able to always grab on a ladder next to empty space, regardless of block ID priority.
	
	; So we do the same thing as the last time, except pick the higher block ID instead.
	; If the higher block ID is a ladder, the collision type will be set to that.
	ld   a, [sPlBGColiBlockId]
	cp   a, b
	jr   nc, .chkNearLadder
	ld   a, b
.chkNearLadder:
	cp   a, BLOCKID_LADDER
	jr   z, .ladder
	cp   a, BLOCKID_LADDERTOP
	jr   z, .ladderTop
	; Otherwise fall back to solid
.solid:
	xor  a ; COLILD_SOLID
	ld   [sPlBGColiLadderType], a
	ret
.ladder:
	ld   a, COLILD_LADDER
	ld   [sPlBGColiLadderType], a
	ret
.ladderTop:
	ld   a, COLILD_LADDERTOP
	ld   [sPlBGColiLadderType], a
	ret
.blockEq:
	; When both blocks are the same
	cp   a, BLOCKID_LADDER
	jr   z, .ladderDouble
	cp   a, BLOCKID_LADDERTOP
	jr   z, .ladderTopDouble
	jr   .solid
.ladderDouble:
	ld   a, COLILD_LADDER2
	ld   [sPlBGColiLadderType], a
	ret
.ladderTopDouble:
	ld   a, COLILD_LADDERTOP2
	ld   [sPlBGColiLadderType], a
	ret
; =============== PlBGColi_DoGround ===============
; Handles block collision for the block the player is over/standing on.
;
; This actually checks the lowest Y pos in the collision box, but since
; the player stands 1px into the ground, and the Y coord is relative
; to the bottom of the player's collision box, this ends up checking for the collision at ground level.
; OUT
; - A: Base collision type (COLI_*)
; - sPlBGColiBlockId: Block ID collided with (ground-left)
; - B: Block ID collided with (ground-right)
; - (many other flags): For the detailed collision types, like sand or ice
PlBGColi_DoGround:
	xor  a
	ld   [sPlBGColiLadderType], a
	ld   [sLvlAutoScrollDir], a
	ld   [sLvlAutoScrollSpeed], a
	ld   [sPlIce], a
	
	; Like for PlBGColi_CheckLadderLow get the block IDs for the two
	; blocks adjacent to the player.
	; This time it's for the even lower blocks (same Y as the player).
	;--
	; Left coordinate.
	
	; Save the block X offset to sBlockTopLeftPtr_Low
	ld   b, $04						; 4px left
	call PlTarget_SetLeftPos
	call PlBGColi_GetXBlockOffset
	ld   a, l
	ld   [sPlBGColiBlockOffset1_Low], a
	ld   b, $00						; 0px down
	call PlTarget_SetDownPos
	call PlBGColi_GetYBlockOffset
	; HL = Index to level layout
	ld   a, [sPlBGColiBlockOffset1_Low]
	ld   l, a
	; Get the pointer to the level layout by adding it to the level layout base ptr
	ld   de, wLevelLayout
	add  hl, de
	
	; Save the calculated high byte (Y coord) of the address
	; (it will be reused later for the other block ptr)
	ld   a, h
	ld   [sPlBGColiBlockOffset1_High], a
	
	; Get the block ID for the left corner
	ld   a, [hl]
	and  a, $7F
	ld   [sPlBGColiBlockId], a
	
	;--
	; Right coordinate.
	ld   b, $04						; 4px right
	call PlTarget_SetRightPos
	call PlBGColi_GetXBlockOffset
	ld   a, l
	ld   [sPlBGColiBlockOffset2_Low], a
	; Reuse the Y coord from before (0px down)
	ld   a, [sPlBGColiBlockOffset1_High]
	ld   [sPlBGColiBlockOffset2_High], a
	ld   h, a
	; Get the block ID for the right corner
	ld   a, [hl]
	and  a, $7F
	ld   b, a
	;--
	
	; Is A < B?
	; Like before, we use the lower block ID to give priority to solid blocks.
	ld   a, [sPlBGColiBlockId]	; A = left  block id	
	cp   a, b					; B = right block id
	jr   c, .blockLt
.blockGt:
	; A > B, so pick B
	; Copy to the shared ptrs the level layout ptr and block id
	ld   a, b			
	ld   [sPlBGColiBlockId], a
	ld   a, [sPlBGColiBlockOffset2_High]
	ld   [sBlockTopLeftPtr_High], a
	ld   a, [sPlBGColiBlockOffset2_Low]
	ld   [sBlockTopLeftPtr_Low], a
	jr   .chkBlockId
.blockLt:
	; Copy to the shared ptrs the level layout ptr
	ld   a, [sPlBGColiBlockOffset1_High]
	ld   [sBlockTopLeftPtr_High], a
	ld   a, [sPlBGColiBlockOffset1_Low]
	ld   [sBlockTopLeftPtr_Low], a
.chkBlockId:
	; Depending on the block ID, report the collision type.
	; The only ones which need manual checking are block IDs $29-$5F.
	; As everything before $28 is solid, and everything after $5F is empty.
	ld   a, [sPlBGColiBlockId]
	cp   a, BLOCKID_SOLID_END		; < $28?
	jr   c, .coli_solid			; If so, all fully solid
	
	cp   a, BLOCKID_EMPTY			; < $60?
	jr   c, .checkDetail	; If so, *check more*
	
.coli_empty:
	; Empty block, except if we're standing on a solid actor
	ld   a, [sPlActSolid]
	and  a
	jr   nz, .coli_solid
	xor  a
	ret
.coli_solid:
	ld   a, $01
	ret
.checkDetail:
	; Is the read-only mode for solid blocks active?
	ld   a, [sPlBGColiSolidReadOnly]
	and  a
	jr   nz, .checkDetailAlt
	
	; Since we only get here when the block ID > $28 (and < $60)
	ld   a, [sPlBGColiBlockId]
	sub  a, BLOCKID_SOLID_END
	rst  $28
	dw BGColi_Solid ; 28     
	dw BGColi_BreakToEmpty7FGroundPound ; 29 
	dw BGColi_BreakToEmpty7FGroundPound ; 2A 
	dw BGColi_BreakToEmpty7EGroundPound ; 2B 
	dw BGColi_BreakToEmpty7EGroundPound ; 2C 
	dw BGColi_BreakToDoorTop7DGroundPound ; 2D 
	dw BGColi_BreakToDoor48GroundPound ; 2E 
	dw BGColi_BounceUp ; 2F 
	dw BGColi_ConveyorLeft ; 30 
	dw BGColi_ConveyorRight ; 31 ;X
	dw BGColi_Solid ; 32 
	dw BGColi_BridgeFall ; 33 
	dw BGColi_Ice ; 34 
	dw BGColi_Ice ; 35 
	dw BGColi_Ice ; 36 
	dw BGColi_Solid ; 37 ;X
	dw BGColi_Solid ; 38 ;X
	dw BGColi_Solid ; 39 
	dw BGColi_TimedSolid0 ; 3A 
	dw BGColi_TimedSolid1 ; 3B 
	dw BGColi_Solid ; 3C 
	dw BGColi_Solid ; 3D ;X
	dw BGColi_Sand ; 3E 
	dw BGColi_SandSpike ; 3F 
	dw BGColi_TopSolid ; 40 
	dw BGColi_TopSolid ; 41 
	dw BGColi_TopSolid ; 42 
	dw BGColi_TopSolid ; 43 
	dw BGColi_Ladder ; 44 
	dw BGColi_LadderTop ; 45 
	dw BGColi_CoinToEmpty7F ; 46 
	dw BGColi_CoinToEmpty7E ; 47 
	dw .coli_empty ; 48
	dw .coli_empty ; 49
	dw BGColi_Water ; 4A 
	dw BGColi_Water ; 4B 
	dw BGColi_WaterCurrentUp ; 4C 
	dw BGColi_WaterCurrentDown ; 4D 
	dw BGColi_WaterCurrentLeft ; 4E 
	dw BGColi_WaterCurrentRight ; 4F 
	dw BGColi_Solid ; 50 
	dw BGColi_Solid ; 51 
	dw BGColi_Solid ; 52 ;X
	dw BGColi_CoinToWater58 ; 53 
	dw BGColi_Solid ; 54 ;X
	dw BGColi_Water ; 55 
	dw BGColi_Water ; 56 
	dw BGColi_Water ; 57 
	dw BGColi_Water ; 58 
	dw BGColi_WaterSpike ; 59 
	dw BGColi_WaterSpike ; 5A ;X
	dw BGColi_Water ; 5B 
	dw BGColi_InstaDeath ; 5C 
	dw BGColi_Spike ; 5D 
	dw BGColi_Spike ; 5E 
	dw BGColi_Spike ; 5F ;X
	
.checkDetailAlt:
	; Alternate mode used to avoid triggering certain blocks
	ld   a, [sPlBGColiBlockId]
	sub  a, BLOCKID_SOLID_END
	rst  $28
	dw BGColi_Solid ; 28 ;X
	dw BGColi_Solid ; 29 ;X
	dw BGColi_Solid ; 2A ;X
	dw BGColi_Solid ; 2B ;X
	dw BGColi_Solid ; 2C ;X
	dw BGColi_Solid ; 2D ;X
	dw BGColi_Solid ; 2E ;X
	dw BGColi_BounceUp ; 2F ;X
	dw BGColi_ConveyorLeft ; 30 ;X
	dw BGColi_ConveyorRight ; 31 ;X
	dw BGColi_Solid ; 32 ;X
	dw BGColi_Solid ; 33 
	dw BGColi_Ice ; 34 ;X
	dw BGColi_Ice ; 35 ;X
	dw BGColi_Ice ; 36 ;X
	dw BGColi_Solid ; 37 ;X
	dw BGColi_Solid ; 38 ;X
	dw BGColi_Solid ; 39 ;X
	dw BGColi_TimedSolid0 ; 3A ;X
	dw BGColi_TimedSolid1 ; 3B ;X
	dw BGColi_Solid ; 3C ;X
	dw BGColi_Solid ; 3D ;X
	dw BGColi_Sand ; 3E ;X
	dw BGColi_SandSpike ; 3F ;X
	dw BGColi_TopSolid ; 40 
	dw BGColi_TopSolid ; 41 
	dw BGColi_TopSolid ; 42 
	dw BGColi_TopSolid ; 43 
	dw BGColi_Ladder ; 44 
	dw BGColi_LadderTop ; 45 ;X
	dw BGColi_CoinToEmpty7F ; 46 
	dw BGColi_CoinToEmpty7E ; 47 ;X
	dw .coli_empty ; 48;X
	dw .coli_empty ; 49;X
	dw BGColi_Water ; 4A ;X
	dw BGColi_Water ; 4B ;X
	dw BGColi_WaterCurrentUp ; 4C ;X
	dw BGColi_WaterCurrentDown ; 4D 
	dw BGColi_WaterCurrentLeft ; 4E ;X
	dw BGColi_WaterCurrentRight ; 4F ;X
	dw BGColi_Solid ; 50 ;X
	dw BGColi_Solid ; 51 ;X
	dw BGColi_Solid ; 52 ;X
	dw BGColi_CoinToWater58 ; 53 ;X
	dw BGColi_Solid ; 54 ;X
	dw BGColi_Water ; 55 ;X
	dw BGColi_Water ; 56 ;X
	dw BGColi_Water ; 57 
	dw BGColi_Water ; 58 ;X
	dw BGColi_WaterSpike ; 59 ;X
	dw BGColi_WaterSpike ; 5A ;X
	dw BGColi_Water ; 5B ;X
	dw BGColi_InstaDeath ; 5C ;X
	dw BGColi_Spike ; 5D ;X
	dw BGColi_Spike ; 5E ;X
	dw BGColi_Spike ; 5F ;X
	
BGColi_InstaDeath:
	call Pl_StartDeathAnim
	ld   a, COLI_WATER
	ret

BGColi_BounceUp:
	; Start a super jump
	ld   a, $01
	ld   [sPlSuperJumpSet], a
	call HomeCall_Pl_StartJump
	;--
	; Replace block ID with a generic solid white block
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	ld   a, $2F
	ld   [hl], a
	call GetBGMapOffsetFromBlock
	ld   a, $7F
	call Level_WriteBlockToBG
	;--
	; Spawn white block
	ld   a, EXACT_BOUNCEBLOCKHIT
	ld   [sExActSet], a
	
	mExActS_SetCenterBlock
	
	ld   a, OBJ_HITBLOCK
	ld   [sExActOBJLstId], a
	ld   a, $00
	ld   [sExActOBJFlags], a
	ld   a, [sBlockTopLeftPtr_High]
	ld   [sExActLevelLayoutPtr_High], a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   [sExActLevelLayoutPtr_Low], a
	; Clear rest
	ld   hl, sExActRoutineId
	xor  a
	ld   b, $07
	call ClearRAMRange_Mini
	call ExActS_Spawn
	;--
	ld   a, COLI_SOLID
	ret
	
BGColi_Ice:
	ld   a, $01
	ld   [sPlIce], a
	ld   a, COLI_SOLID
	ret
BGColi_Ladder:
	ld   a, COLILD_LADDER
	ld   [sPlBGColiLadderType], a
	ld   a, COLI_SOLID
	ret
BGColi_LadderTop:
	; If the player is less than 4px close to the top of the block, treat it as a solid platform.
	ld   a, [sPlY_Low]
	and  a, $0F
	cp   a, $04				; < 4px?
	jr   nc, BGColi_Ladder	; If not, jump
	
	ld   a, COLILD_LADDERTOP
	ld   [sPlBGColiLadderType], a
	ld   a, COLI_SOLID
	ret
BGColi_ConveyorLeft:
	ld   a, DIR_L
	ld   [sLvlAutoScrollDir], a
	ld   a, $01
	ld   [sLvlAutoScrollSpeed], a
	ld   a, COLI_SOLID
	ret
BGColi_ConveyorLeftCheckCling:
	ld   a, [sPlAction]
	cp   a, PL_ACT_CLING
	jp   nz, BGColi_Solid
	jr   BGColi_ConveyorLeft
; [TCRF] This also handles the block collision for the top of the right-moving conveyor belt.
;        However, in the only place this block is used you can't stand on top of it.
;        Its effect is used though when clinging to the bottom of a left-moving conveyor belt.
BGColi_ConveyorRight:
	ld   a, DIR_R
	ld   [sLvlAutoScrollDir], a
	ld   a, $01
	ld   [sLvlAutoScrollSpeed], a
	ld   a, COLI_SOLID
	ret
BGColi_ConveyorRightCheckCling:
	ld   a, [sPlAction]
	cp   a, PL_ACT_CLING
	jp   nz, BGColi_Solid
	jr   BGColi_ConveyorRight
; =============== Pl_BGHurt ===============
; This subroutine starts the damage sequence when hurt by a spike/muncher.
Pl_BGHurt:
	; If the invincibility effect is active, ignore the effect
	ld   a, [sPlInvincibleTimer]
	and  a
	ret  nz
	; If in post-hit invulnerability, ignore the effect
	ld   a, [sPlPostHitInvulnTimer]
	and  a
	ret  nz
	; If the player is already small, start the death sequence
	ld   a, [sSmallWario]
	and  a
	jr   nz, .kill
	
	; Mark hit from block
	ld   a, PL_HT_BGHURT
	ld   [sPlHurtType], a
	
	ld   a, PL_POW_NONE
	ld   [sPlPowerSet], a
	call Game_InitHatSwitch
	ret
.kill:
	call Pl_StartDeathAnim
	ret
	
BGColi_BridgeFall:
	mExActS_SetCenterBlock
	
	; Try to spawn the falling bridge actor.
	; If it didn't, treat the block as solid and don't do anything else.
	call SubCall_ActS_SpawnBridge
	ld   a, [sActBridgeSpawned]
	and  a
	jr   nz, .notSpawned
	
	; If it did spawn, we can replace the block with an empty one
	; HL = Level layout ptr
	ld   a, [sBlockTopLeftPtr_High]
	ld   h, a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   l, a
	; Replace with empty block
	ld   a, [hl]
	and  a, $80
	add  $7F
	ld   [hl], a
	; Write the updated 8x8 tiles to the tilemap
	ld   [sTmp_A9EE], a
	call GetBGMapOffsetFromBlock
	ld   a, [sTmp_A9EE]
	call Level_WriteBlockToBG
.notSpawned:
	ld   a, COLI_SOLID
	ret
	
BGColi_Spike:
	call Pl_BGHurt
	xor  a ; COLI_EMPTY
	ret
BGColi_WaterCurrentRight:
	ld   a, DIR_R
	ld   [sLvlAutoScrollDir], a
	ld   [sLvlAutoScrollSpeed], a
	jr   BGColi_Water
BGColi_WaterCurrentLeft:
	ld   a, DIR_L
	ld   [sLvlAutoScrollDir], a
	ld   a, $01
	ld   [sLvlAutoScrollSpeed], a
	jr   BGColi_Water
BGColi_WaterCurrentUp:
	ld   a, DIR_U
	ld   [sLvlAutoScrollDir], a
	ld   a, $01
	ld   [sLvlAutoScrollSpeed], a
	jr   BGColi_Water
BGColi_WaterCurrentDown:
	ld   a, DIR_D
	ld   [sLvlAutoScrollDir], a
	ld   a, $01
	ld   [sLvlAutoScrollSpeed], a
BGColi_Water:
	ld   a, COLI_WATER
	ret
BGColi_WaterSpike:
	call Pl_BGHurt
	ld   a, COLI_WATER
	ret
BGColi_Sand:
	ld   a, $01
	ld   [sPlSand], a
	jr   BGColi_Water
BGColi_SandSpike:
	ld   a, $01
	ld   [sPlSand], a
	jr   BGColi_WaterSpike
; =============== PlBGColi_DoTop ===============
; Handles block collision for the upper part of the player's collision box.
; OUT
; - A: Base collision type (COLI_*)
; - sPlBGColiBlockId: Block ID collided with (ground-left)
; - B: Block ID collided with (ground-right)
; - (many other flags): For the detailed collision types, like sand or ice
PlBGColi_DoTop:

	; Setup the collision target relative to the player pos
	;--
	; Top-left block
	ld   b, $04							; 4px left
	call PlTarget_SetLeftPos
	call PlBGColi_GetXBlockOffset
	ld   a, l
	ld   [sPlBGColiBlockOffset1_Low], a
	
	; The player's height isn't always the same
	ld   b, $1C							; Normal: 28px up
	ld   a, [sPlDuck]
	and  a								; Are we ducking?
	jr   nz, .isShort					; If so, we are short
	ld   a, [sSmallWario]
	and  a								; Are we Small Wario?
	jr   z, .setYTarget					; If not, we aren't short
.isShort:
	ld   b, $10							; Short: 16px up
.setYTarget:
	call PlTarget_SetUpPos
	call PlBGColi_GetYBlockOffset
	ld   a, [sPlBGColiBlockOffset1_Low]
	ld   l, a
	; HL = Ptr to block ID
	ld   de, wLevelLayout
	add  hl, de
	
	; Save the Y component for reuse when getting the block ID on the right
	ld   a, h
	ld   [sPlBGColiBlockOffset1_High], a
	
	; Get the block ID for the top left corner
	ld   a, [hl]
	and  a, $7F
	ld   [sPlBGColiBlockId], a
	
	;--
	; Top-right block.
	ld   b, $04							; 4px right
	call PlTarget_SetRightPos
	call PlBGColi_GetXBlockOffset
	ld   a, l
	ld   [sPlBGColiBlockOffset2_Low], a
	; Reuse the aforemented Y component
	ld   a, [sPlBGColiBlockOffset1_High]
	ld   [sPlBGColiBlockOffset2_High], a
	ld   h, a
	; B = Block ID for the top-right corner
	ld   a, [hl]
	and  a, $7F
	ld   b, a
	
	; Pick the block ID with a lower value
	ld   a, [sPlBGColiBlockId]	; A = left  block id	
	cp   a, b					; B = right block id
	jr   c, .blockLt			; A < B?
.blockGt:
	; A > B, so pick B
	ld   a, b
	ld   [sPlBGColiBlockId], a
	ld   a, [sPlBGColiBlockOffset2_High]
	ld   [sBlockTopLeftPtr_High], a
	ld   a, [sPlBGColiBlockOffset2_Low]
	ld   [sBlockTopLeftPtr_Low], a
	jr   .chkBlockId
.blockLt:
	ld   a, [sPlBGColiBlockOffset1_High]
	ld   [sBlockTopLeftPtr_High], a
	ld   a, [sPlBGColiBlockOffset1_Low]
	ld   [sBlockTopLeftPtr_Low], a
.chkBlockId:
	; Get the collision type for the block IDs
	ld   a, [sPlBGColiBlockId]	; < $28 all solid
	cp   a, BLOCKID_SOLID_END
	jp   c, BGColi_Solid
	
	cp   a, BLOCKID_EMPTY		; $28-$5F is mixed
	jr   c, .checkDetail
	
	xor  a						; >= $60 all empty
	ret
	
.checkDetail:
	ld   a, [sPlBGColiSolidReadOnly]
	and  a
	jr   nz, .checkDetailAlt
	; Subtract all solid blocks
	ld   a, [sPlBGColiBlockId]
	sub  a, BLOCKID_SOLID_END
	rst  $28
	dw BGColi_ItemBox ; 28 
	dw BGColi_BreakHardToEmpty7FJump ; 29 
	dw BGColi_BreakToEmpty7FJump ; 2A 
	dw BGColi_BreakHardToEmpty7EJump ; 2B 
	dw BGColi_BreakToEmpty7EJump ; 2C 
	dw BGColi_BreakToDoorTop7DJump ; 2D ;X
	dw BGColi_BreakToDoor48Jump ; 2E 
	dw BGColi_Solid ; 2F ;X
	dw BGColi_ConveyorRightCheckCling ; 30 
	dw BGColi_ConveyorLeftCheckCling ; 31 
	dw BGColi_Switch0Type1 ; 32 
	dw BGColi_Empty ; 33 
	dw BGColi_Solid ; 34 ;X
	dw BGColi_Solid ; 35 ;X
	dw BGColi_Solid ; 36 
	dw BGColi_ItemBox ; 37 ;X ; [TCRF] Unused item box block, appears as empty but it's solid like then normal block
	dw BGColi_Unused_Switch1Type1 ; 38 ;X
	dw BGColi_Switch0Type0 ; 39 
	dw BGColi_Empty ; 3A 
	dw BGColi_Empty ; 3B 
	dw BGColi_Solid ; 3C 
	dw BGColi_Solid ; 3D ;X
	dw BGColi_Sand ; 3E 
	dw BGColi_SandSpike ; 3F 
	dw BGColi_Empty ; 40 
	dw BGColi_Empty ; 41 
	dw BGColi_Empty ; 42 
	dw BGColi_Empty ; 43 
	dw BGColi_Empty ; 44 
	dw BGColi_Empty ; 45 
	dw BGColi_CoinToEmpty7F ; 46 
	dw BGColi_CoinToEmpty7E ; 47 
	dw BGColi_Empty ; 48 
	dw BGColi_ItemBox ; 49 
	dw BGColi_ItemBox ; 4A 
	dw BGColi_Water ; 4B 
	dw BGColi_WaterCurrentUp ; 4C 
	dw BGColi_WaterCurrentDown ; 4D 
	dw BGColi_WaterCurrentLeft ; 4E 
	dw BGColi_WaterCurrentRight ; 4F 
	dw BGColi_BreakHardToWater58Jump ; 50 
	dw BGColi_BreakToWater58Jump ; 51 
	dw BGColi_BreakToWaterDoorTop5BJump ; 52 ;X
	dw BGColi_CoinToWater58 ; 53 
	dw BGColi_BreakToWaterDoor4BJump ; 54 ;X
	dw BGColi_Water ; 55 
	dw BGColi_Water ; 56 
	dw BGColi_Water ; 57 
	dw BGColi_Water ; 58 
	dw BGColi_WaterSpike ; 59 
	dw BGColi_WaterSpike ; 5A ;X
	dw BGColi_Water ; 5B 
	dw BGColi_InstaDeath ; 5C 
	dw BGColi_Spike ; 5D 
	dw BGColi_Spike ; 5E 
	dw BGColi_Spike ; 5F ;X
	
.checkDetailAlt:
	ld   a, [sPlBGColiBlockId]
	sub  a, BLOCKID_SOLID_END
	rst  $28
	dw BGColi_Solid ; 28 
	dw BGColi_Solid ; 29 
	dw BGColi_Solid ; 2A 
	dw BGColi_Solid ; 2B 
	dw BGColi_Solid ; 2C 
	dw BGColi_Solid ; 2D ;X
	dw BGColi_Solid ; 2E ;X
	dw BGColi_Solid ; 2F ;X
	dw BGColi_ConveyorRightCheckCling ; 30 ;X
	dw BGColi_ConveyorLeftCheckCling ; 31 ;X
	dw BGColi_Solid ; 32 ;X
	dw BGColi_Empty ; 33 ;X
	dw BGColi_Solid ; 34 ;X
	dw BGColi_Solid ; 35 ;X
	dw BGColi_Solid ; 36 
	dw BGColi_Solid ; 37 ;X
	dw BGColi_Solid ; 38 ;X
	dw BGColi_Solid ; 39 ;X
	dw BGColi_Empty ; 3A ;X
	dw BGColi_Empty ; 3B ;X
	dw BGColi_Solid ; 3C 
	dw BGColi_Solid ; 3D ;X
	dw BGColi_Sand ; 3E ;X
	dw BGColi_SandSpike ; 3F ;X
	dw BGColi_Empty ; 40 
	dw BGColi_Empty ; 41 
	dw BGColi_Empty ; 42 
	dw BGColi_Empty ; 43 
	dw BGColi_Empty ; 44 
	dw BGColi_Empty ; 45 ;X
	dw BGColi_CoinToEmpty7F ; 46 
	dw BGColi_CoinToEmpty7E ; 47 ;X
	dw BGColi_Empty ; 48 ;X
	dw BGColi_Solid ; 49 ;X
	dw BGColi_Solid ; 4A ;X
	dw BGColi_Water ; 4B ;X
	dw BGColi_WaterCurrentUp ; 4C 
	dw BGColi_WaterCurrentDown ; 4D 
	dw BGColi_WaterCurrentLeft ; 4E ;X
	dw BGColi_WaterCurrentRight ; 4F 
	dw BGColi_Water ; 50 ;X
	dw BGColi_Water ; 51 
	dw BGColi_Water ; 52 ;X
	dw BGColi_CoinToWater58 ; 53 
	dw BGColi_Water ; 54 ;X
	dw BGColi_Water ; 55 
	dw BGColi_Water ; 56 ;X
	dw BGColi_Water ; 57 ;X
	dw BGColi_Water ; 58 
	dw BGColi_WaterSpike ; 59 ;X
	dw BGColi_WaterSpike ; 5A ;X
	dw BGColi_Water ; 5B 
	dw BGColi_InstaDeath ; 5C 
	dw BGColi_Spike ; 5D ;X
	dw BGColi_Spike ; 5E ;X
	dw BGColi_Spike ; 5F ;X
	
BGColi_ItemBox:
	ld   a, [sBlockTopLeftPtr_High]
	ld   [sActStunLevelLayoutPtr_High], a
	ld   a, [sBlockTopLeftPtr_Low]
	ld   [sActStunLevelLayoutPtr_Low], a
	call BGColi_HitItemBox
	ld   a, SFX1_0E			; [TCRF] Removed unique SFX?
	ld   [sSFX1Set], a
	ld   a, COLI_SOLID
	ret
	
; =============== mBGColi_BreakHardToEmptyJump ===============
; Generates code to check if we can directly break an hard breakable block.
; If we're Bull Wario, execution falls through the macro, so this 
; should only be placed before invoking mBGColi_BreakToBlockIdJump.
mBGColi_BreakHardToEmptyJump: MACRO
	; If we aren't Bull Wario, we can't instantly break the block
	ld   a, [sPlPower]
	cp   a, PL_POW_BULL
	jr   nz, BGColi_BreakHardToNextJump
ENDM
; =============== mBGColi_BreakToBlockIdJump ===============
; Generates code for a wrapper for breaking a breakable block.
; IN
; - 1: Label to subroutine for breaking the block
mBGColi_BreakToBlockIdJump: MACRO
	xor  a
	ld   [sPlSwimUpTimer], a
	jp   \1
ENDM
	
BGColi_BreakToDoor48Jump: mBGColi_BreakToBlockIdJump BGColi_BreakToDoor48
BGColi_BreakToDoorTop7DJump: mBGColi_BreakToBlockIdJump BGColi_BreakToDoorTop7D
; [TCRF] Technically possible, but not with the used level designs
BGColi_BreakToWaterDoorTop5BJump: mBGColi_BreakToBlockIdJump BGColi_BreakToWaterDoorTop5B
BGColi_BreakHardToNextJump:
	xor  a
	ld   [sPlSwimUpTimer], a
	jp   BGColi_BreakHardToNext
BGColi_BreakHardToEmpty7FJump: mBGColi_BreakHardToEmptyJump
BGColi_BreakToEmpty7FJump: mBGColi_BreakToBlockIdJump BGColi_BreakToEmpty7F
BGColi_BreakHardToEmpty7EJump: mBGColi_BreakHardToEmptyJump
BGColi_BreakToEmpty7EJump: mBGColi_BreakToBlockIdJump BGColi_BreakToEmpty7E
BGColi_BreakHardToWater58Jump: mBGColi_BreakHardToEmptyJump
BGColi_BreakToWater58Jump: mBGColi_BreakToBlockIdJump BGColi_BreakToWater58
; [TCRF] Technically possible, but not with the used level designs (and it wouldn't make sense)
BGColi_BreakToWaterDoor4BJump: mBGColi_BreakToBlockIdJump BGColi_BreakToWaterDoor4B
; =============== PlBGColi_DoFront ===============
; Handles block collision for the blocks in front of the player (both low and top portions).
; Calling this will autodetect the correct X target position, but this can be ignored by calling directly PlBGColi_DoRight/PlBGColi_DoLeft.
; OUT
; - A: Base collision type (COLI_*)
; - sPlBGColiBlockId: Block ID collided with
; - sPlBGColiBlockIdNext: Block ID to collide with when called through the other subroutine
; - B: Same as sPlBGColiBlockIdNext
; - (many other flags): For the detailed collision types, like sand or ice
PlBGColi_DoFront:
	;--
	; Autodetect the X target depending on the OBJLst direction.
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a		; Are we facing right?
	jr   z, PlBGColi_DoLeft	; If not, jump
PlBGColi_DoRight:
	ld   b, $08					; 8px right
	call PlTarget_SetRightPos
	jr   PlBGColi_DoHorz
PlBGColi_DoLeft:
	ld   b, $08					; 8px left
	call PlTarget_SetLeftPos
	;--
PlBGColi_DoHorz:

	;--
	; A player is less than 2 blocks tall, so at most can interact with 3 blocks vertically.
	; 2 block IDs will be calculated for the lower box, and one for the higher box.
	; The block ID with highest priority will be picked.
	
	;
	; LOWER BOX, LOW CORNER
	;
	
	; Save what will be the low byte of the level layout ptr
	; Since the level width is $100 blocks, the low byte is already correct
	call PlBGColi_GetXBlockOffset
	ld   a, l											
	ld   [sPlBGColiBlockOffset1_Low], a
	
	; Reset secondary call args
	xor  a
	ld   [sPlBGColiBlockIdNext], a
	
	; Calculate the Y offset to the block
	ld   b, $02								; 2px up (low block)
	call PlTarget_SetUpPos
	call PlBGColi_GetYBlockOffset
	; To get the proper high byte of the level layout ptr, add wLevelLayout to it.
	; We take advantage of this since we also need the block ID.
	ld   a, [sPlBGColiBlockOffset1_Low]		
	ld   l, a								
	ld   de, wLevelLayout					; Add the level layout base
	add  hl, de
	ld   a, h								; With the block indexed, we have the proper high byte
	ld   [sPlBGColiBlockOffset1_High], a	
	
	; Save the block ID for the low block
	ld   a, [hl]
	and  a, $7F
	ld   [sPlBGColiBlockId], a
	
	;
	; LOWER BOX, HIGH CORNER
	;
	
	; (same 8px left/right X offset)
	; Calculate the Y offset to the block
	ld   b, $0E								; $0Epx up, very close to the edge of the lower box
	call PlTarget_SetUpPos
	call PlBGColi_GetYBlockOffset			; H = Y offset
	ld   a, [sPlBGColiBlockOffset1_Low]		; L = Reused X offset
	ld   l, a
	ld   de, wLevelLayout
	add  hl, de
	; B = Block ID
	ld   a, [hl]
	and  a, $7F
	ld   b, a
	
	;
	; LOWER BOX PRIORITY
	;
	
	; This follows the normal priority rules.
	; The block with lower ID has more priority, so this gives priority to solid blocks.
	ld   a, [sPlBGColiBlockId]		; A = LL Block ID
	cp   a, b						; B = LH Block ID
	jr   c, .blockLtLow	; A < B?
.blockGtLow:
	; If not, pick B
	ld   a, b
	ld   [sPlBGColiBlockId], a
	ld   a, h
	ld   [sPlBGColiBlockOffset1_High], a
	jr   .blockLtLow
.blockLtLow:

	;
	; HIGHER BOX, HIGH CORNER
	;
	
	; As usual the higher collision box isn't necessarily there.
	; When ducking or as Small Wario, the player's height fits into a single block,
	; so we don't need to get other block IDs.
	
	;--
	ld   a, [sPlDuck]
	and  a
	jr   nz, .blockLt
	ld   a, [sSmallWario]
	and  a
	jr   nz, .blockLt
	;--
	

	; Calculate the Y offset to the block
	ld   b, $1A					; $1A px up (higher part of high corner)
	call PlTarget_SetUpPos
	call PlBGColi_GetYBlockOffset		; H = Y offset
	ld   a, [sPlBGColiBlockOffset1_Low]	; L = Reused X offset
	ld   l, a
	ld   de, wLevelLayout
	add  hl, de
	; And get the block ID.
	ld   a, [hl]
	and  a, $7F
	ld   b, a					; B = BlockH
	
	;
	; GLOBAL PRIORITY
	;
	
	; [BUG] There's a a problem with this.
	; This collision code, like many others, gets multiple block IDs but in the end
	; only handles the one with more priority (read: with a lower block ID).
	;
	; For horizontal movement this isn't really enough since the player can be two blocks tall.
	; The game keeps track of the block ID discarded in order to be checked later through PlBGColi_DoHorzNext...
	; ...except this later check doesn't always happen (like when underwater, which allows you to walk on rows of spikes unharmed).
	;
	; A trick they did here was to only set the lower priority block if the block ID with more priority is in the upper part.
	; It was done to save time when checking for autoducking -- since 1 block gaps fit this description:
	; a solid block (highest priority) on top, and something else on the bottom.
	; By just checking if the lower priority block is empty we know if we can duck under there.
	
	; Calculate the priority as usual.
	ld   a, [sPlBGColiBlockId]	; A = BlockL
	cp   a, b					; A < B?
	jr   c, .blockLt			; If so, pick A
.blockGt:
	; If not, pick B, and queue the other block ID for later
	ld   [sPlBGColiBlockIdNext], a
	ld   a, [sPlBGColiBlockOffset1_High]
	ld   [sPlBGColiBlockOffset1Next_High], a
	ld   a, b
	ld   [sPlBGColiBlockId], a
	ld   a, h								; the X coord is the same, so replace Y only
	ld   [sPlBGColiBlockOffset1_High], a
	jr   .blockLt
.blockLt:
	ld   a, [sPlBGColiBlockOffset1_High]
	ld   [sBlockTopLeftPtr_High], a
	ld   a, [sPlBGColiBlockOffset1_Low]
	ld   [sBlockTopLeftPtr_Low], a
	ld   a, [sPlBGColiBlockId]
	
PlBGColi_DoHorz_BlockType:
	cp   a, BLOCKID_SOLID_END	; < $28 for always solid
	jp   c, BGColi_Solid
	cp   a, BLOCKID_EMPTY		; in-between is misc
	jr   c, PlBGColi_DoHorz_CheckType
	xor  a						; >= $60 for always empty 
	ret
	
; =============== PlBGColi_DoHorzNext ===============
; Performs the collision check for the previously set block with less priority.
; Ideally should be always called, but it isn't...
; OUT
; - A: Base collision type (COLI_*)
PlBGColi_DoHorzNext:
	; Restore saved values
	ld   a, [sPlBGColiBlockOffset1Next_High]
	ld   [sBlockTopLeftPtr_High], a
	ld   a, [sPlBGColiBlockOffset1_Low]			; Reuse existing X component as usual
	ld   [sBlockTopLeftPtr_Low], a
	ld   a, [sPlBGColiBlockIdNext]
	ld   [sPlBGColiBlockId], a
	jr   PlBGColi_DoHorz_BlockType
PlBGColi_DoHorz_CheckType:;R
	sub  a, BLOCKID_SOLID_END
	rst  $28
	dw BGColi_Solid ; 28 
	dw BGColi_Solid ; 29 
	dw BGColi_Solid ; 2A 
	dw BGColi_Solid ; 2B 
	dw BGColi_Solid ; 2C 
	dw BGColi_Solid ; 2D 
	dw BGColi_Solid ; 2E 
	dw BGColi_Solid ; 2F 
	dw BGColi_Solid ; 30 
	dw BGColi_Solid ; 31 ;X
	dw BGColi_Solid ; 32 
	dw BGColi_Empty ; 33 
	dw BGColi_Solid ; 34 
	dw BGColi_Solid ; 35 ;X
	dw BGColi_Solid ; 36 
	dw BGColi_Solid ; 37 ;X
	dw BGColi_Solid ; 38 ;X
	dw BGColi_Solid ; 39 
	dw BGColi_Empty ; 3A 
	dw BGColi_Empty ; 3B 
	dw BGColi_Solid ; 3C 
	dw BGColi_Solid ; 3D ;X
	dw BGColi_Sand ; 3E 
	dw BGColi_SandSpike ; 3F 
	dw BGColi_Empty ; 40 
	dw BGColi_Empty ; 41 
	dw BGColi_Empty ; 42 
	dw BGColi_Empty ; 43 
	dw BGColi_Empty ; 44 
	dw BGColi_Empty ; 45 
	dw BGColi_CoinToEmpty7F ; 46 
	dw BGColi_CoinToEmpty7E ; 47 
	dw BGColi_Empty ; 48 
	dw BGColi_Empty ; 49 
	dw BGColi_Water ; 4A 
	dw BGColi_Water ; 4B 
	dw BGColi_WaterCurrentUp ; 4C 
	dw BGColi_WaterCurrentDown ; 4D 
	dw BGColi_WaterCurrentLeft ; 4E 
	dw BGColi_WaterCurrentRight ; 4F 
	dw BGColi_Solid ; 50 
	dw BGColi_Solid ; 51 
	dw BGColi_Solid ; 52 
	dw BGColi_CoinToWater58 ; 53 
	dw BGColi_Solid ; 54 ;X
	dw BGColi_Water ; 55 
	dw BGColi_Water ; 56 
	dw BGColi_Water ; 57 
	dw BGColi_Water ; 58 
	dw BGColi_WaterSpike ; 59 
	dw BGColi_WaterSpike ; 5A ;X
	dw BGColi_Water ; 5B 
	dw BGColi_InstaDeath ; 5C ;X
	dw BGColi_Spike ; 5D 
	dw BGColi_Spike ; 5E 
	dw BGColi_Spike ; 5F ;X
; =============== Level_WriteBlockToBG ===============
; Writes a single 16x16 block to the specified tilemap offset.
; This doesn't update the actual block ID.
; Meant to be used for visually replacing a single block (ie: after destroying blocks; hitting item boxes,...)
; IN
; - HL: Tilemap offset
; -  A: Block ID
Level_WriteBlockToBG:
	; Get the ptr to the block16 definition for this block ID
	;--
	push hl
	ld   d, $00	; DE = BlockID * 4 (as a 16x16 block has 4 tiles)
	and  a, $7F
	ld   e, a
REPT 2
	sla  e	; << 2
	rl   d
ENDR
	ld   hl, sLevelBlocks	; Offset the block data
	add  hl, de				; HL = block16 def
	pop  de					; DE = Tilemap offset
	mWaitForNewHBlank
	; HBlank time is short, so we can only replace 2 tiles at once
	ldi  a, [hl]	; Top-left
	ld   [de], a
	inc  e			; Move right
	
	ldi  a, [hl]	; Top-right
	ld   [de], a
	ld   a, e		; Move 1 row below the top-left pos
	add  (BG_TILECOUNT_H-1)
	ld   e, a
	
	mWaitForNewHBlank
	ldi  a, [hl]	; Bottom-left
	ld   [de], a
	inc  e			; Move right
	
	ld   a, [hl]	; Bottom-right
	ld   [de], a
	ret
	
; =============== HOMECALL AREA ===============
; Use these to switch to code in different banks

HomeCall_Demo_GetInput: mHomeCallRet Demo_GetInput ; BANK 0D
HomeCall_Credits_WriteLineForRow1ToBuffer: mHomeCallRet Credits_WriteLineForRow1ToBuffer ; BANK 0D
HomeCall_Credits_WriteLineForRow2ToBuffer: mHomeCallRet Credits_WriteLineForRow2ToBuffer ; BANK 0D
HomeCall_SaveSel_AnimPipes: mHomeCallRet SaveSel_AnimPipes ; BANK $0D
HomeCall_LoadGFX_CourseAlpha: mHomeCallRet LoadGFX_CourseAlpha ; BANK $05
; =============== Level_CopyStatusBar00GFX ===============
; Copies the default status bar GFX to VRAM.
Level_CopyStatusBar00GFX:
	ld   a, [sROMBank]
	push af
	ld   a, BANK(GFX_StatusBar_00)
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	ld   hl, GFX_StatusBar_00
	call Level_CopyStatusBarGFX
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	ret
HomeCall_Level_AnimTiles: mHomeCallRet Level_AnimTiles ; BANK $0D
HomeCall_Game_StartEnding: mHomeCallRet Game_StartEnding ; BANK $01
HomeCall_Ending_Do: mHomeCallRet Ending_Do ; BANK $1F
HomeCall_HeartBonus_Do: mHomeCallRet HeartBonus_Do ; BANK $1E
HomeCall_CoinBonus_Do: mHomeCallRet CoinBonus_Do ; BANK $1E
HomeCall_LoadVRAM_Ending_TreasureRoom: mHomeCallRet LoadVRAM_Ending_TreasureRoom ; BANK $06
HomeCall_LoadVRAM_CourseClr: mHomeCallRet LoadVRAM_CourseClr ; BANK $05
HomeCall_WriteExActOBJLst: mHomeCallRet WriteExActOBJLst ; BANK $05
HomeCall_NonGame_WriteWarioOBJLst: mHomeCallRet NonGame_WriteWarioOBJLst ; BANK $05
HomeCall_WriteWarioOBJLst: mHomeCallRet WriteWarioOBJLst ; BANK $05
HomeCall_NonGame_WriteExActOBJLst: mHomeCallRet NonGame_WriteExActOBJLst ; BANK $05
HomeCall_Pl_StartJump: mHomeCallRet Pl_StartJump ; BANK $0D
HomeCall_ExActS_ExecuteAllAndWriteOBJLst: mHomeCallRet ExActS_ExecuteAllAndWriteOBJLst ; BANK $0D
HomeCall_ExActS_ExecuteAll: mHomeCallRet ExActS_ExecuteAll ; BANK $0D
HomeCall_LoadVRAM_Treasure_TreasureRoom: mHomeCallRet LoadVRAM_Treasure_TreasureRoom ; BANK $06
HomeCall_SaveSel_InitOBJ: mHomeCallRet SaveSel_InitOBJ ; BANK $06
HomeCall_LoadGFX_WarioPowerHat: mHomeCallRet LoadGFX_WarioPowerHat ;BANK $05
HomeCall_Level_LoadScrollLocks: mHomeCallRet Level_LoadScrollLocks ; BANK $0C
HomeCall_Level_SetBGM: mHomeCallRet Level_SetBGM ; BANK $0C
HomeCall_LoadVRAM_SaveSelect: mHomeCallRet LoadVRAM_SaveSelect ; BANK $06
HomeCall_Title_CheckMode: mHomeCallRet Title_CheckMode ; BANK $12
HomeCall_ExActActColi_DragonHatFlame: mHomeCallRet ExActActColi_DragonHatFlame ; BANK $0D
HomeCall_PlActColi_Do: mHomeCallRet PlActColi_Do ; BANK $0D

PlBGColi_DoTopStub:
	call PlBGColi_DoTop
	ret
PlBGColi_DoRightStub:
	call PlBGColi_DoRight
	ret
PlBGColi_DoLeftStub:
	call PlBGColi_DoLeft
	ret
; =============== HomeCall_Game_Do ===============
HomeCall_Game_Do: mHomeCallRet Game_Do ; BANK $0D
HomeCall_Pl_HatSwitchAnim_SetNextAction: mHomeCallRet Pl_HatSwitchAnim_SetNextAction ; BANK $0D
; [TCRF] Unreferenced HomeCall to used code.
;        ActS_InitScreenActors is only called by ActS_InitGroup, through an inline SubCall instead.
;        Calling this would have been faster...
HomeCall_Unused_ActS_InitScreenActors: mHomeCallRet ActS_InitScreenActors ; BANK $02
HomeCall_LoadVRAM_TimeOver: mHomeCallRet LoadVRAM_TimeOver ; BANK $05
HomeCall_LoadVRAM_GameOver: mHomeCallRet LoadVRAM_GameOver ; BANK $05
HomeCall_Sound_StopAllStub: mHomeCallRet Sound_StopAllStub ; BANK $04
HomeCall_ActS_GetIdByLevelLayoutPtr2:
	ld   a, [sROMBank]
	push af
	ld   a, BANK(ActS_GetIdByLevelLayoutPtr2)
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	call ActS_GetIdByLevelLayoutPtr2
	ld   [sLvlLayoutPtrActId], a ; Save the actor ID we found at that slot
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank], a
	ret
HomeCall_ScreenEvent_Mode_LevelScroll: mHomeCallRet ScreenEvent_Mode_LevelScroll ; BANK $05
HomeCall_LoadVRAM_TreasureRoom: mHomeCallRet LoadVRAM_TreasureRoom ; BANK $06
HomeCall_ActS_Do: mHomeCallRet ActS_Do ; BANK $02
HomeCall_Map_CheckMapId: mHomeCallRet Map_CheckMapId ; BANK $08
HomeCall_Map_ScreenEvent: mHomeCallRet Map_ScreenEvent ; BANK $08
; =============== START OF ALIGN JUNK ===============
L0022E4: db $00;X
L0022E5: db $21;X
L0022E6: db $CD;X
L0022E7: db $18;X
L0022E8: db $7E;X
L0022E9: db $F1;X
L0022EA: db $EA;X
L0022EB: db $C5;X
L0022EC: db $A8;X
L0022ED: db $EA;X
L0022EE: db $00;X
L0022EF: db $21;X
L0022F0: db $C9;X
L0022F1: db $28;X
L0022F2: db $A2;X
L0022F3: db $8A;X
L0022F4: db $AA;X
L0022F5: db $A2;X
L0022F6: db $8A;X
L0022F7: db $22;X
L0022F8: db $82;X
L0022F9: db $22;X
L0022FA: db $A2;X
L0022FB: db $2A;X
L0022FC: db $AA;X
L0022FD: db $22;X
L0022FE: db $AA;X
L0022FF: db $AA;X
L002300: db $EA;X
L002301: db $AA;X
L002302: db $AB;X
L002303: db $AA;X
L002304: db $AA;X
L002305: db $BA;X
L002306: db $AE;X
L002307: db $AA;X
L002308: db $AA;X
L002309: db $EA;X
L00230A: db $AA;X
L00230B: db $AA;X
L00230C: db $BF;X
L00230D: db $AB;X
L00230E: db $BA;X
L00230F: db $EA;X
L002310: db $BF;X
L002311: db $AA;X
L002312: db $EA;X
L002313: db $AA;X
L002314: db $BE;X
L002315: db $AA;X
L002316: db $AE;X
L002317: db $AA;X
L002318: db $EA;X
L002319: db $FA;X
L00231A: db $AF;X
L00231B: db $AE;X
L00231C: db $AA;X
L00231D: db $BB;X
L00231E: db $AB;X
L00231F: db $EB;X
L002320: db $BA;X
L002321: db $AB;X
L002322: db $BE;X
L002323: db $AE;X
L002324: db $AA;X
L002325: db $FA;X
L002326: db $FA;X
L002327: db $AA;X
L002328: db $EA;X
L002329: db $BA;X
L00232A: db $FB;X
L00232B: db $AA;X
L00232C: db $AF;X
L00232D: db $AB;X
L00232E: db $EE;X
L00232F: db $AA;X
L002330: db $AA;X
L002331: db $AA;X
L002332: db $AB;X
L002333: db $BE;X
L002334: db $AB;X
L002335: db $AA;X
L002336: db $BE;X
L002337: db $BE;X
L002338: db $AA;X
L002339: db $BA;X
L00233A: db $AA;X
L00233B: db $AB;X
L00233C: db $AA;X
L00233D: db $AE;X
L00233E: db $FE;X
L00233F: db $EA;X
L002340: db $EA;X
L002341: db $EB;X
L002342: db $AA;X
L002343: db $BA;X
L002344: db $EA;X
L002345: db $BA;X
L002346: db $BF;X
L002347: db $BE;X
L002348: db $AE;X
L002349: db $BA;X
L00234A: db $AA;X
L00234B: db $AA;X
L00234C: db $BA;X
L00234D: db $EE;X
L00234E: db $FA;X
L00234F: db $AA;X
L002350: db $AB;X
L002351: db $BB;X
L002352: db $AA;X
L002353: db $AA;X
L002354: db $AA;X
L002355: db $EA;X
L002356: db $AA;X
L002357: db $AA;X
L002358: db $BA;X
L002359: db $AE;X
L00235A: db $BA;X
L00235B: db $AA;X
L00235C: db $AB;X
L00235D: db $BA;X
L00235E: db $AA;X
L00235F: db $AA;X
L002360: db $AB;X
L002361: db $AE;X
L002362: db $BB;X
L002363: db $AE;X
L002364: db $AE;X
L002365: db $AA;X
L002366: db $EA;X
L002367: db $EA;X
L002368: db $EA;X
L002369: db $AA;X
L00236A: db $AA;X
L00236B: db $EA;X
L00236C: db $AA;X
L00236D: db $AA;X
L00236E: db $BB;X
L00236F: db $FB;X
L002370: db $AA;X
L002371: db $AA;X
L002372: db $BA;X
L002373: db $AA;X
L002374: db $BB;X
L002375: db $EF;X
L002376: db $EB;X
L002377: db $BA;X
L002378: db $AA;X
L002379: db $EA;X
L00237A: db $EA;X
L00237B: db $AB;X
L00237C: db $EA;X
L00237D: db $AB;X
L00237E: db $BB;X
L00237F: db $AB;X
L002380: db $AA;X
L002381: db $20;X
L002382: db $2A;X
L002383: db $A2;X
L002384: db $82;X
L002385: db $02;X
L002386: db $22;X
L002387: db $0A;X
L002388: db $A0;X
L002389: db $A2;X
L00238A: db $22;X
L00238B: db $2A;X
L00238C: db $88;X
L00238D: db $82;X
L00238E: db $00;X
L00238F: db $0A;X
L002390: db $2A;X
L002391: db $AA;X
L002392: db $22;X
L002393: db $80;X
L002394: db $A8;X
L002395: db $A2;X
L002396: db $82;X
L002397: db $2A;X
L002398: db $2A;X
L002399: db $20;X
L00239A: db $82;X
L00239B: db $02;X
L00239C: db $A2;X
L00239D: db $A2;X
L00239E: db $A0;X
L00239F: db $AA;X
L0023A0: db $2A;X
L0023A1: db $AA;X
L0023A2: db $AA;X
L0023A3: db $08;X
L0023A4: db $AA;X
L0023A5: db $02;X
L0023A6: db $AA;X
L0023A7: db $28;X
L0023A8: db $28;X
L0023A9: db $82;X
L0023AA: db $A2;X
L0023AB: db $0A;X
L0023AC: db $2A;X
L0023AD: db $22;X
L0023AE: db $2A;X
L0023AF: db $A2;X
L0023B0: db $00;X
L0023B1: db $A0;X
L0023B2: db $8A;X
L0023B3: db $02;X
L0023B4: db $A2;X
L0023B5: db $A0;X
L0023B6: db $2A;X
L0023B7: db $2A;X
L0023B8: db $AA;X
L0023B9: db $AA;X
L0023BA: db $8A;X
L0023BB: db $AA;X
L0023BC: db $02;X
L0023BD: db $2A;X
L0023BE: db $2A;X
L0023BF: db $AA;X
L0023C0: db $AA;X
L0023C1: db $02;X
L0023C2: db $A2;X
L0023C3: db $2A;X
L0023C4: db $28;X
L0023C5: db $2A;X
L0023C6: db $20;X
L0023C7: db $22;X
L0023C8: db $8A;X
L0023C9: db $AA;X
L0023CA: db $2A;X
L0023CB: db $AA;X
L0023CC: db $22;X
L0023CD: db $28;X
L0023CE: db $0A;X
L0023CF: db $00;X
L0023D0: db $28;X
L0023D1: db $22;X
L0023D2: db $2A;X
L0023D3: db $2A;X
L0023D4: db $82;X
L0023D5: db $A2;X
L0023D6: db $8A;X
L0023D7: db $AA;X
L0023D8: db $A0;X
L0023D9: db $8A;X
L0023DA: db $22;X
L0023DB: db $A2;X
L0023DC: db $A2;X
L0023DD: db $8A;X
L0023DE: db $28;X
L0023DF: db $AA;X
L0023E0: db $28;X
L0023E1: db $2A;X
L0023E2: db $2A;X
L0023E3: db $2A;X
L0023E4: db $A2;X
L0023E5: db $A2;X
L0023E6: db $02;X
L0023E7: db $A2;X
L0023E8: db $A2;X
L0023E9: db $AA;X
L0023EA: db $88;X
L0023EB: db $20;X
L0023EC: db $AA;X
L0023ED: db $A8;X
L0023EE: db $82;X
L0023EF: db $0A;X
L0023F0: db $02;X
L0023F1: db $A2;X
L0023F2: db $AA;X
L0023F3: db $0A;X
L0023F4: db $AA;X
L0023F5: db $28;X
L0023F6: db $A0;X
L0023F7: db $2A;X
L0023F8: db $20;X
L0023F9: db $22;X
L0023FA: db $0A;X
L0023FB: db $20;X
L0023FC: db $22;X
L0023FD: db $22;X
L0023FE: db $80;X
L0023FF: db $A8;X
; =============== END OF ALIGN JUNK ===============

; =============== DecompressGFX Stubs ===============
DecompressGFXStub:
	call DecompressGFX
	ret
DecompressBG_ToBGMap:
	ld   bc, BGMap_Begin
	call DecompressBG
	ret
DecompressBG_ToWINDOWMap:
	ld   bc, WINDOWMap_Begin
	call DecompressBG
	ret

; =============== ClearBGMapEx ===============
; Clears with $00 the entirety of the BG tilemap and part of the tiles area.
; Specifically called by "static modes" only, which all use tile $00 as empty space.
ClearBGMapEx:
	ld   hl, BGMap_End-1	; HL = End Address
	ld   bc, $0800			; BC = Bytes to clear
.loop:
	xor  a					; Overwrite source
	ldd  [hl], a			; ptr--
	dec  bc
	ld   a, b				; Are there any bytes left? (BC != 0)
	or   a, c
	jr   nz, .loop			; If so, loop
	ret
; =============== ScreenEvent_StaticDo ===============
; Handles tile animation for misc static screens outside of the map.
ScreenEvent_StaticDo:
	ld   a, [wStaticAnimMode]
	rst  $28
	dw HomeCall_Title_AnimWaterGFX
	dw HomeCall_Bonus_ScreenEvent_Do
	dw HomeCall_End_ScreenEvent_Do
HomeCall_Title_AnimWaterGFX: mHomeCallRet Title_AnimWaterGFX ; BANK $12
HomeCall_Bonus_ScreenEvent_Do: mHomeCallRet Bonus_ScreenEvent_Do ; BANK $1E
HomeCall_End_ScreenEvent_Do: mHomeCallRet End_ScreenEvent_Do ; BANK $1F
; ==============================
HomeCall_Static_WriteWarioOBJLst: mHomeCallRet Static_WriteWarioOBJLst ; BANK $12
HomeCall_Sound_DoStub: mHomeCallRet Sound_DoStub ; BANK $04
	
; =============== Static_WriteOBJLst ===============
; Writes an entire OBJ list (sprite mappings) for use in the title screen, bonus games, and ending.
; These are stored as a list of OAM OBJ (sprites).
;
; As a result an OBJLst is made of several entries one after the other, with each entry having:
; - Y Coord (relative to the origin)
; - X Coord (relative to the origin)
; - Tile ID
; - Flags
;
; This is similar to Map_WriteOBJLst, but:
; - doesn't support flipping entire OBJLst.
; - input comes from different addresses.
; - a value is treated as end separator if it is a multiple of $10
;
; IN
; - DE: Ptr to OBJLst
; -  B: Always 0
;
Static_WriteOBJLst:
	ld   hl, sWorkOAM
	; Determine the WorkOAM offset from the OBJCount
	; Not too sure why wStaticOBJCount is used instead of sWorkOAMPos like elsewhere,...
	; it is more annoying to deal with and is slower.
	ld   a, [wStaticOBJCount]
	sla  a						; Offset = OBJCount * 4
	sla  a
	ld   c, a					
	add  hl, bc					; HL = Correct OAM Entry
.loop:
	; The OAM area is $A0 bytes big; a single OBJ takes 4 bytes
	; $A0 / 4 = $28
	ld   a, [wStaticOBJCount]
	cp   a, $28					; Have we hit the OBJ limit?
	ret  z						; If so, return
	;--
	inc  a						; OBJCount++
	ld   [wStaticOBJCount], a
	;--
	
	; Write the Y coord
.doYCoord:
	ld   a, [sOAMWriteY]		; C = Base Y position		
	ld   c, a
	ld   a, [de]				; Get the OBJ relative Y pos
	add  c					; Add the base Y pos
	ldi  [hl], a				; Write it to OAM
	inc  de						; OAMLstPtr++;
	
	; Do the same for the X coord
.doXCoord:
	ld   a, [sOAMWriteX]		; C = Base Y position	
	ld   c, a					
	ld   a, [de]				; Get the OBJ relative X pos
	add  c					; Add the base X pos
	ldi  [hl], a				; Write it to OAM
	inc  de						; OAMLstPtr++;
	
	; Write the Tile ID
.writeTileID:
	ld   a, [de]
	ldi  [hl], a
	inc  de
	
	; Write the flags as-is
	; as there's no support here for custom flags
.writeFlags:
	ld   a, [de]
	ldi  [hl], a
	inc  de
	
	and  a, $0F					; Have we reached an end separator?
	jr   z, .loop				; If not, loop
	ret
	
; =============== Static_FinalizeWorkOAM ===============
; Blanks the leftover parts of the OAM copy.
; This is to make sure leftovers from the previous frame don't get drawn on screen.
;
; This is specific to the "static" modes since it uses wStaticOBJCount.
;
; See also: FinalizeWorkOAM
Static_FinalizeWorkOAM:
	ld   hl, sWorkOAM
	; Determine the WorkOAM offset from the OBJCount
	ld   a, [wStaticOBJCount]
	sla  a						; Offset = OBJCount * 4
	sla  a
	ld   c, a
	add  hl, bc					; HL = Correct OAM Entry
.loop:
	ld   a, [wStaticOBJCount]	
	cp   a, $28					; Have we reached the OBJ limit (end of WorkOAM)?
	ret  z						; If so, we're done
	
	inc  a						; OBJCount++
	ld   [wStaticOBJCount], a
	
	; Write $00 to all OAM fields
	xor  a
	ldi  [hl], a
	inc  de
	ldi  [hl], a
	inc  de
	ldi  [hl], a
	inc  de
	ldi  [hl], a
	inc  de
	jr   .loop
; =============== Static_Pl_WalkAnim ===============
; Handles the timing for Wario's standard walking animation in a static screen (ie: Bonus games).
Static_Pl_WalkAnim:
	ld   a, [wStaticPlAnimTimer]	; Timer++
	inc  a
	ld   [wStaticPlAnimTimer], a
	; Time the sequence
	cp   a, $01
	jr   z, .useFrame0
	cp   a, $04
	jr   z, .useFrame1
	cp   a, $08
	jr   z, .useFrame3
	cp   a, $0C
	jr   z, .playWalkSFX
	cp   a, $10
	jr   z, .useFrame2
	cp   a, $14
	jr   z, .useFrame3
	; When reaching $18, reset the timer
	cp   a, $18
	ret  nz
	xor  a
	ld   [wStaticPlAnimTimer], a
.playWalkSFX:
	ld   a, SFX4_08			; Play walk SFX
	ld   [sSFX4Set], a
.useFrame0:
	ld   a, OBJ_WARIO_WALK0
	ld   [wStaticPlLstId], a
	ret
.useFrame1:
	ld   a, OBJ_WARIO_WALK1
	ld   [wStaticPlLstId], a
	ret
.useFrame3:
	ld   a, OBJ_WARIO_WALK3
	ld   [wStaticPlLstId], a
	ret
.useFrame2:
	ld   a, OBJ_WARIO_WALK2
	ld   [wStaticPlLstId], a
	ret
; =============== START OF ALIGN JUNK ===============
L002532: db $BE;X
L002533: db $EA;X
L002534: db $AB;X
L002535: db $AA;X
L002536: db $BE;X
L002537: db $AE;X
L002538: db $AE;X
L002539: db $EA;X
L00253A: db $EB;X
L00253B: db $AA;X
L00253C: db $AE;X
L00253D: db $BB;X
L00253E: db $AA;X
L00253F: db $AA;X
L002540: db $EA;X
L002541: db $AB;X
L002542: db $BA;X
L002543: db $BB;X
L002544: db $AA;X
L002545: db $AE;X
L002546: db $EB;X
L002547: db $AE;X
L002548: db $EA;X
L002549: db $BA;X
L00254A: db $AE;X
L00254B: db $AB;X
L00254C: db $AF;X
L00254D: db $BB;X
L00254E: db $AB;X
L00254F: db $AA;X
L002550: db $AA;X
L002551: db $AB;X
L002552: db $AA;X
L002553: db $FB;X
L002554: db $BA;X
L002555: db $AB;X
L002556: db $AE;X
L002557: db $AA;X
L002558: db $BE;X
L002559: db $AB;X
L00255A: db $AA;X
L00255B: db $AA;X
L00255C: db $BF;X
L00255D: db $AA;X
L00255E: db $AA;X
L00255F: db $BA;X
L002560: db $AE;X
L002561: db $AE;X
L002562: db $AA;X
L002563: db $AE;X
L002564: db $AA;X
L002565: db $AE;X
L002566: db $AA;X
L002567: db $EA;X
L002568: db $EA;X
L002569: db $BA;X
L00256A: db $EA;X
L00256B: db $AA;X
L00256C: db $AA;X
L00256D: db $AB;X
L00256E: db $BA;X
L00256F: db $AB;X
L002570: db $AA;X
L002571: db $EE;X
L002572: db $BE;X
L002573: db $AA;X
L002574: db $EE;X
L002575: db $AE;X
L002576: db $AB;X
L002577: db $EB;X
L002578: db $AE;X
L002579: db $BB;X
L00257A: db $AE;X
L00257B: db $AA;X
L00257C: db $AB;X
L00257D: db $EA;X
L00257E: db $AB;X
L00257F: db $AA;X
L002580: db $AB;X
L002581: db $2A;X
L002582: db $A2;X
L002583: db $AA;X
L002584: db $8A;X
L002585: db $02;X
L002586: db $AA;X
L002587: db $A8;X
L002588: db $2A;X
L002589: db $22;X
L00258A: db $A8;X
L00258B: db $AA;X
L00258C: db $82;X
L00258D: db $A0;X
L00258E: db $A0;X
L00258F: db $A8;X
L002590: db $88;X
L002591: db $AA;X
L002592: db $AA;X
L002593: db $88;X
L002594: db $8A;X
L002595: db $2A;X
L002596: db $A2;X
L002597: db $A2;X
L002598: db $8A;X
L002599: db $AA;X
L00259A: db $A8;X
L00259B: db $AA;X
L00259C: db $A2;X
L00259D: db $A0;X
L00259E: db $AA;X
L00259F: db $A2;X
L0025A0: db $88;X
L0025A1: db $08;X
L0025A2: db $2A;X
L0025A3: db $A0;X
L0025A4: db $2A;X
L0025A5: db $AA;X
L0025A6: db $AA;X
L0025A7: db $AA;X
L0025A8: db $AA;X
L0025A9: db $2A;X
L0025AA: db $8A;X
L0025AB: db $88;X
L0025AC: db $A2;X
L0025AD: db $0A;X
L0025AE: db $A8;X
L0025AF: db $88;X
L0025B0: db $A2;X
L0025B1: db $82;X
L0025B2: db $28;X
L0025B3: db $88;X
L0025B4: db $AA;X
L0025B5: db $AA;X
L0025B6: db $AA;X
L0025B7: db $9A;X
L0025B8: db $A2;X
L0025B9: db $2A;X
L0025BA: db $08;X
L0025BB: db $8A;X
L0025BC: db $A8;X
L0025BD: db $0A;X
L0025BE: db $2A;X
L0025BF: db $22;X
L0025C0: db $A0;X
L0025C1: db $22;X
L0025C2: db $8A;X
L0025C3: db $AA;X
L0025C4: db $AA;X
L0025C5: db $AA;X
L0025C6: db $0A;X
L0025C7: db $88;X
L0025C8: db $2A;X
L0025C9: db $AA;X
L0025CA: db $8A;X
L0025CB: db $08;X
L0025CC: db $8A;X
L0025CD: db $8A;X
L0025CE: db $A8;X
L0025CF: db $A0;X
L0025D0: db $AA;X
L0025D1: db $2A;X
L0025D2: db $A2;X
L0025D3: db $A2;X
L0025D4: db $AA;X
L0025D5: db $2A;X
L0025D6: db $A0;X
L0025D7: db $A8;X
L0025D8: db $A2;X
L0025D9: db $8A;X
L0025DA: db $A2;X
L0025DB: db $02;X
L0025DC: db $AA;X
L0025DD: db $2A;X
L0025DE: db $AA;X
L0025DF: db $AA;X
L0025E0: db $AA;X
L0025E1: db $AA;X
L0025E2: db $A8;X
L0025E3: db $8A;X
L0025E4: db $22;X
L0025E5: db $AA;X
L0025E6: db $2A;X
L0025E7: db $AA;X
L0025E8: db $A2;X
L0025E9: db $2A;X
L0025EA: db $AA;X
L0025EB: db $8A;X
L0025EC: db $A0;X
L0025ED: db $88;X
L0025EE: db $8A;X
L0025EF: db $22;X
L0025F0: db $AA;X
L0025F1: db $AA;X
L0025F2: db $88;X
L0025F3: db $8A;X
L0025F4: db $2A;X
L0025F5: db $AA;X
L0025F6: db $2A;X
L0025F7: db $A8;X
L0025F8: db $02;X
L0025F9: db $A2;X
L0025FA: db $AA;X
L0025FB: db $A2;X
L0025FC: db $0A;X
L0025FD: db $8A;X
L0025FE: db $08;X
L0025FF: db $8A;X
L002600: db $EA;X
L002601: db $AB;X
L002602: db $BF;X
L002603: db $AE;X
L002604: db $BA;X
L002605: db $EB;X
L002606: db $BA;X
L002607: db $AF;X
L002608: db $AA;X
L002609: db $EA;X
L00260A: db $AA;X
L00260B: db $AA;X
L00260C: db $AA;X
L00260D: db $AE;X
L00260E: db $AE;X
L00260F: db $EB;X
L002610: db $AA;X
L002611: db $AB;X
L002612: db $FF;X
L002613: db $BB;X
L002614: db $AF;X
L002615: db $AA;X
L002616: db $AE;X
L002617: db $AE;X
L002618: db $AA;X
L002619: db $BE;X
L00261A: db $AA;X
L00261B: db $EA;X
L00261C: db $BA;X
L00261D: db $AF;X
L00261E: db $AA;X
L00261F: db $BA;X
L002620: db $EA;X
L002621: db $FA;X
L002622: db $AA;X
L002623: db $AE;X
L002624: db $BA;X
L002625: db $AA;X
L002626: db $BE;X
L002627: db $BA;X
L002628: db $AE;X
L002629: db $AA;X
L00262A: db $AA;X
L00262B: db $EA;X
L00262C: db $EA;X
L00262D: db $AA;X
L00262E: db $FA;X
L00262F: db $AA;X
L002630: db $BA;X
L002631: db $AA;X
L002632: db $AA;X
L002633: db $BA;X
L002634: db $AF;X
L002635: db $BA;X
L002636: db $BA;X
L002637: db $AA;X
L002638: db $AA;X
L002639: db $AA;X
L00263A: db $FF;X
L00263B: db $AA;X
L00263C: db $BF;X
L00263D: db $EB;X
L00263E: db $BB;X
L00263F: db $EA;X
L002640: db $EE;X
L002641: db $EA;X
L002642: db $EB;X
L002643: db $EA;X
L002644: db $AA;X
L002645: db $AA;X
L002646: db $BA;X
L002647: db $AA;X
L002648: db $BA;X
L002649: db $BA;X
L00264A: db $AE;X
L00264B: db $AB;X
L00264C: db $FA;X
L00264D: db $AA;X
L00264E: db $AE;X
L00264F: db $BE;X
L002650: db $BB;X
L002651: db $EE;X
L002652: db $AA;X
L002653: db $AA;X
L002654: db $EE;X
L002655: db $BA;X
L002656: db $BA;X
L002657: db $AA;X
L002658: db $AA;X
L002659: db $AA;X
L00265A: db $EA;X
L00265B: db $BA;X
L00265C: db $EB;X
L00265D: db $AA;X
L00265E: db $EE;X
L00265F: db $AB;X
L002660: db $AA;X
L002661: db $BA;X
L002662: db $FA;X
L002663: db $AA;X
L002664: db $AB;X
L002665: db $BE;X
L002666: db $EF;X
L002667: db $AA;X
L002668: db $AF;X
L002669: db $BE;X
L00266A: db $AF;X
L00266B: db $FA;X
L00266C: db $AA;X
L00266D: db $BA;X
L00266E: db $BA;X
L00266F: db $FB;X
L002670: db $EA;X
L002671: db $AE;X
L002672: db $FA;X
L002673: db $BE;X
L002674: db $EF;X
L002675: db $AE;X
L002676: db $AE;X
L002677: db $AA;X
L002678: db $BE;X
L002679: db $BE;X
L00267A: db $EA;X
L00267B: db $AA;X
L00267C: db $AA;X
L00267D: db $BA;X
L00267E: db $AA;X
L00267F: db $AA;X
L002680: db $A2;X
L002681: db $80;X
L002682: db $AA;X
L002683: db $A8;X
L002684: db $AA;X
L002685: db $2A;X
L002686: db $AA;X
L002687: db $A0;X
L002688: db $8A;X
L002689: db $82;X
L00268A: db $A0;X
L00268B: db $2A;X
L00268C: db $A8;X
L00268D: db $28;X
L00268E: db $A8;X
L00268F: db $A2;X
L002690: db $2A;X
L002691: db $2A;X
L002692: db $AA;X
L002693: db $AA;X
L002694: db $AA;X
L002695: db $A2;X
L002696: db $A2;X
L002697: db $2A;X
L002698: db $28;X
L002699: db $2A;X
L00269A: db $22;X
L00269B: db $A0;X
L00269C: db $A0;X
L00269D: db $AA;X
L00269E: db $AA;X
L00269F: db $AA;X
L0026A0: db $8A;X
L0026A1: db $2A;X
L0026A2: db $AA;X
L0026A3: db $A2;X
L0026A4: db $8A;X
L0026A5: db $AA;X
L0026A6: db $2A;X
L0026A7: db $88;X
L0026A8: db $AA;X
L0026A9: db $A2;X
L0026AA: db $A8;X
L0026AB: db $2A;X
L0026AC: db $82;X
L0026AD: db $AA;X
L0026AE: db $AA;X
L0026AF: db $28;X
L0026B0: db $8A;X
L0026B1: db $8A;X
L0026B2: db $8A;X
L0026B3: db $20;X
L0026B4: db $8A;X
L0026B5: db $AA;X
L0026B6: db $AA;X
L0026B7: db $A8;X
L0026B8: db $8A;X
L0026B9: db $22;X
L0026BA: db $AA;X
L0026BB: db $AA;X
L0026BC: db $AA;X
L0026BD: db $22;X
L0026BE: db $AA;X
L0026BF: db $AA;X
L0026C0: db $8A;X
L0026C1: db $8A;X
L0026C2: db $22;X
L0026C3: db $A0;X
L0026C4: db $8A;X
L0026C5: db $22;X
L0026C6: db $AA;X
L0026C7: db $AA;X
L0026C8: db $A2;X
L0026C9: db $80;X
L0026CA: db $22;X
L0026CB: db $A2;X
L0026CC: db $2A;X
L0026CD: db $AA;X
L0026CE: db $8A;X
L0026CF: db $20;X
L0026D0: db $8A;X
L0026D1: db $AA;X
L0026D2: db $A2;X
L0026D3: db $82;X
L0026D4: db $0A;X
L0026D5: db $88;X
L0026D6: db $22;X
L0026D7: db $0A;X
L0026D8: db $8A;X
L0026D9: db $88;X
L0026DA: db $8A;X
L0026DB: db $A2;X
L0026DC: db $AA;X
L0026DD: db $8A;X
L0026DE: db $8A;X
L0026DF: db $2A;X
L0026E0: db $A2;X
L0026E1: db $AA;X
L0026E2: db $20;X
L0026E3: db $AA;X
L0026E4: db $0A;X
L0026E5: db $A8;X
L0026E6: db $00;X
L0026E7: db $22;X
L0026E8: db $AA;X
L0026E9: db $2A;X
L0026EA: db $82;X
L0026EB: db $22;X
L0026EC: db $AA;X
L0026ED: db $08;X
L0026EE: db $0A;X
L0026EF: db $00;X
L0026F0: db $2A;X
L0026F1: db $8A;X
L0026F2: db $0A;X
L0026F3: db $A8;X
L0026F4: db $AA;X
L0026F5: db $28;X
L0026F6: db $0A;X
L0026F7: db $2A;X
L0026F8: db $A8;X
L0026F9: db $AA;X
L0026FA: db $2A;X
L0026FB: db $A0;X
L0026FC: db $88;X
L0026FD: db $00;X
L0026FE: db $08;X
L0026FF: db $A2;X
L002700: db $AA;X
L002701: db $AE;X
L002702: db $BA;X
L002703: db $AA;X
L002704: db $EE;X
L002705: db $AA;X
L002706: db $EB;X
L002707: db $AE;X
L002708: db $EA;X
L002709: db $AB;X
L00270A: db $AB;X
L00270B: db $AA;X
L00270C: db $AA;X
L00270D: db $EA;X
L00270E: db $EA;X
L00270F: db $AE;X
L002710: db $AE;X
L002711: db $AA;X
L002712: db $AB;X
L002713: db $AA;X
L002714: db $AA;X
L002715: db $AE;X
L002716: db $AA;X
L002717: db $EA;X
L002718: db $AA;X
L002719: db $AA;X
L00271A: db $AA;X
L00271B: db $AB;X
L00271C: db $BF;X
L00271D: db $AA;X
L00271E: db $AB;X
L00271F: db $AB;X
L002720: db $BA;X
L002721: db $EA;X
L002722: db $EA;X
L002723: db $EA;X
L002724: db $FB;X
L002725: db $EB;X
L002726: db $AA;X
L002727: db $AA;X
L002728: db $AA;X
L002729: db $AE;X
L00272A: db $AE;X
L00272B: db $EE;X
L00272C: db $AA;X
L00272D: db $AF;X
L00272E: db $AE;X
L00272F: db $AA;X
L002730: db $EB;X
L002731: db $AA;X
L002732: db $BB;X
L002733: db $EA;X
L002734: db $FF;X
L002735: db $BA;X
L002736: db $EB;X
L002737: db $EE;X
L002738: db $FB;X
L002739: db $BA;X
L00273A: db $EA;X
L00273B: db $AA;X
L00273C: db $AA;X
L00273D: db $BA;X
L00273E: db $BF;X
L00273F: db $AB;X
L002740: db $EB;X
L002741: db $BE;X
L002742: db $BB;X
L002743: db $AE;X
L002744: db $EE;X
L002745: db $AA;X
L002746: db $EA;X
L002747: db $AA;X
L002748: db $BE;X
L002749: db $AA;X
L00274A: db $AB;X
L00274B: db $BA;X
L00274C: db $AA;X
L00274D: db $AF;X
L00274E: db $EA;X
L00274F: db $EA;X
L002750: db $AE;X
L002751: db $BA;X
L002752: db $AB;X
L002753: db $AE;X
L002754: db $AE;X
L002755: db $EE;X
L002756: db $AB;X
L002757: db $AA;X
L002758: db $AB;X
L002759: db $AA;X
L00275A: db $AB;X
L00275B: db $BE;X
L00275C: db $AE;X
L00275D: db $EE;X
L00275E: db $AA;X
L00275F: db $AE;X
L002760: db $BE;X
L002761: db $AA;X
L002762: db $EA;X
L002763: db $AA;X
L002764: db $BA;X
L002765: db $AA;X
L002766: db $AE;X
L002767: db $EB;X
L002768: db $EB;X
L002769: db $BA;X
L00276A: db $AB;X
L00276B: db $AB;X
L00276C: db $EE;X
L00276D: db $EA;X
L00276E: db $AA;X
L00276F: db $BA;X
L002770: db $AB;X
L002771: db $AB;X
L002772: db $AA;X
L002773: db $AF;X
L002774: db $FA;X
L002775: db $AA;X
L002776: db $AA;X
L002777: db $FA;X
L002778: db $EA;X
L002779: db $AE;X
L00277A: db $AB;X
L00277B: db $AA;X
L00277C: db $BB;X
L00277D: db $AA;X
L00277E: db $AA;X
L00277F: db $AA;X
L002780: db $A8;X
L002781: db $20;X
L002782: db $AA;X
L002783: db $A8;X
L002784: db $AA;X
L002785: db $0A;X
L002786: db $A2;X
L002787: db $AA;X
L002788: db $28;X
L002789: db $A0;X
L00278A: db $A8;X
L00278B: db $AA;X
L00278C: db $A2;X
L00278D: db $AA;X
L00278E: db $28;X
L00278F: db $A0;X
L002790: db $AA;X
L002791: db $82;X
L002792: db $AA;X
L002793: db $8A;X
L002794: db $E2;X
L002795: db $A2;X
L002796: db $AA;X
L002797: db $A0;X
L002798: db $26;X
L002799: db $A2;X
L00279A: db $88;X
L00279B: db $AA;X
L00279C: db $A8;X
L00279D: db $AA;X
L00279E: db $88;X
L00279F: db $0A;X
L0027A0: db $22;X
L0027A1: db $2A;X
L0027A2: db $0A;X
L0027A3: db $82;X
L0027A4: db $2A;X
L0027A5: db $28;X
L0027A6: db $AA;X
L0027A7: db $A2;X
L0027A8: db $A8;X
L0027A9: db $AA;X
L0027AA: db $AA;X
L0027AB: db $AA;X
L0027AC: db $A8;X
L0027AD: db $A2;X
L0027AE: db $A8;X
L0027AF: db $82;X
L0027B0: db $AA;X
L0027B1: db $8A;X
L0027B2: db $AA;X
L0027B3: db $82;X
L0027B4: db $8A;X
L0027B5: db $A2;X
L0027B6: db $AA;X
L0027B7: db $22;X
L0027B8: db $AA;X
L0027B9: db $AA;X
L0027BA: db $AA;X
L0027BB: db $8A;X
L0027BC: db $AA;X
L0027BD: db $2A;X
L0027BE: db $0A;X
L0027BF: db $0A;X
L0027C0: db $28;X
L0027C1: db $22;X
L0027C2: db $2A;X
L0027C3: db $A0;X
L0027C4: db $AA;X
L0027C5: db $AA;X
L0027C6: db $A2;X
L0027C7: db $08;X
L0027C8: db $AA;X
L0027C9: db $88;X
L0027CA: db $AA;X
L0027CB: db $82;X
L0027CC: db $A2;X
L0027CD: db $2A;X
L0027CE: db $8A;X
L0027CF: db $0A;X
L0027D0: db $A2;X
L0027D1: db $8A;X
L0027D2: db $88;X
L0027D3: db $AA;X
L0027D4: db $AA;X
L0027D5: db $2A;X
L0027D6: db $A2;X
L0027D7: db $A8;X
L0027D8: db $2A;X
L0027D9: db $82;X
L0027DA: db $88;X
L0027DB: db $0A;X
L0027DC: db $82;X
L0027DD: db $88;X
L0027DE: db $8A;X
L0027DF: db $0A;X
L0027E0: db $80;X
L0027E1: db $88;X
L0027E2: db $A2;X
L0027E3: db $A8;X
L0027E4: db $0A;X
L0027E5: db $08;X
L0027E6: db $82;X
L0027E7: db $AA;X
L0027E8: db $22;X
L0027E9: db $82;X
L0027EA: db $A2;X
L0027EB: db $22;X
L0027EC: db $A8;X
L0027ED: db $A8;X
L0027EE: db $8A;X
L0027EF: db $A2;X
L0027F0: db $88;X
L0027F1: db $A8;X
L0027F2: db $AA;X
L0027F3: db $A8;X
L0027F4: db $A2;X
L0027F5: db $0A;X
L0027F6: db $AA;X
L0027F7: db $8A;X
L0027F8: db $A2;X
L0027F9: db $AA;X
L0027FA: db $AA;X
L0027FB: db $AA;X
L0027FC: db $8A;X
L0027FD: db $0A;X
L0027FE: db $A0;X
L0027FF: db $0A;X
; =============== END OF ALIGN JUNK ===============

; =============== MAP SCREEN IMPORTS ===============
HomeCall_LoadGFX_Overworld: mHomeCallRet LoadGFX_Overworld ; BANK $14
HomeCall_LoadGFX_MtTeapot_RiceBeach: mHomeCallRet LoadGFX_MtTeapot_RiceBeach ; BANK $14
HomeCall_LoadGFX_StoveCanyon_SSTeacup: mHomeCallRet LoadGFX_StoveCanyon_SSTeacup ; BANK $09
HomeCall_LoadGFX_SyrupCastle: mHomeCallRet LoadGFX_SyrupCastle ; BANK $09
HomeCall_LoadGFX_ParsleyWoods_SherbetLand: mHomeCallRet LoadGFX_ParsleyWoods_SherbetLand ; BANK $14
HomeCall_LoadGFX_SubmapOBJ: mHomeCallRet LoadGFX_SubmapOBJ ; BANK $09
HomeCall_LoadBG_RiceBeach: mHomeCallRet LoadBG_RiceBeach ; BANK $09
HomeCall_LoadBG_MtTeapot: mHomeCallRet LoadBG_MtTeapot ; BANK $09
HomeCall_LoadBG_StoveCanyon: mHomeCallRet LoadBG_StoveCanyon ; BANK $09
HomeCall_LoadBG_SSTeacup: mHomeCallRet LoadBG_SSTeacup ; BANK $09
HomeCall_LoadBG_ParsleyWoods: mHomeCallRet LoadBG_ParsleyWoods ; BANK $14
HomeCall_LoadBG_SherbetLand: mHomeCallRet LoadBG_SherbetLand ; BANK $14
HomeCall_LoadBG_SyrupCastle: mHomeCallRet LoadBG_SyrupCastle ; BANK $09
HomeCall_LoadBG_RiceBeachFlooded: mHomeCallRet LoadBG_RiceBeachFlooded ; BANK $09
HomeCall_LoadBG_SyrupCastleEnding: mHomeCallRet LoadBG_SyrupCastleEnding ; BANK $09
HomeCall_LoadBG_Overworld: mHomeCallRet LoadBG_Overworld ; BANK $09
HomeCall_Map_Unused_ReplaceBGMap: mHomeCallRet Map_Unused_ReplaceBGMap ; BANK $14 | [TCRF] Not used.
HomeCall_Map_Overworld_AnimFlags: mHomeCallRet Map_Overworld_AnimFlags ; BANK $14
HomeCall_Map_InitWorldClearFlags: mHomeCallRet Map_InitWorldClearFlags ; BANK $14
HomeCall_Map_LoadPalette: mHomeCallRet Map_LoadPalette ; BANK $08
HomeCall_Map_ClearRAM: mHomeCallRet Map_ClearRAM ; BANK $08
HomeCall_Map_InitMisc: mHomeCallRet Map_InitMisc ; BANK $08
HomeCall_Map_Overworld_WriteEv: mHomeCallRet Map_Overworld_WriteEv ; BANK $08
HomeCall_Map_Overworld_AnimTiles: mHomeCallRet Map_Overworld_AnimTiles ; BANK $08
HomeCall_Map_C32ClearCutscene_Init: mHomeCallRet Map_C32ClearCutscene_Init ; BANK $14
HomeCall_Map_C32ClearCutscene_Do: mHomeCallRet Map_C32ClearCutscene_Do ; BANK $14
HomeCall_Map_MoveMtTeapotLid: mHomeCallRet Map_MoveMtTeapotLid ; BANK $14
HomeCall_Map_MtTeapotLidSetPos: mHomeCallRet Map_MtTeapotLidSetPos ; BANK $14
HomeCall_Map_NoMoveMtTeapotLid: mHomeCallRet Map_NoMoveMtTeapotLid ; BANK $14
HomeCall_Map_MtTeapotLidSetPosCutscene: mHomeCallRet Map_MtTeapotLidSetPosCutscene ; BANK $14
HomeCall_Map_C12ClearCutscene_Do: mHomeCallRet Map_C12ClearCutscene_Do ; BANK $14
HomeCall_Map_SyrupCastle_DoEffects: mHomeCallRet Map_SyrupCastle_DoEffects ; BANK $14
HomeCall_Map_DrawFreeViewArrows: mHomeCallRet Map_DrawFreeViewArrows ; BANK $14
HomeCall_Map_InitFreeViewArrows: mHomeCallRet Map_InitFreeViewArrows ; BANK $14
HomeCall_Map_DrawOpenPathsArrows: mHomeCallRet Map_DrawOpenPathsArrows ; BANK $14
HomeCall_Map_Ending_Do: mHomeCallRet Map_Ending_Do ; BANK $14
HomeCall_Map_Ending_DrawOBJ: mHomeCallRet Map_Ending_DrawOBJ ; BANK $14
HomeCall_Map_WriteWarioOBJLst: mHomeCallRet Map_WriteWarioOBJLst ; BANK $08
HomeCall_Map_SyrupCastle_DoCutscenes: mHomeCallRet Map_SyrupCastle_DoCutscenes ; BANK $14
HomeCall_Map_SyrupCastle_RemovePath: mHomeCallRet Map_SyrupCastle_RemovePath ; BANK $14
HomeCall_Map_BlinkLevel_Do mHomeCallRet Map_BlinkLevel_Do ; BANK $14

; =============== Map_UpdateOBJRelCoord ===============
; Updates the relative scroll coordinate of an overworld OBJLst.
; This can be used for both coordinates.
;
; This is used to keep in sync sprites positions (which are relative to the screen)
; in the overworld when the screen scrollling changes.
;
; IN
; - HL: Ptr to current screen scroll coord
; - BC: Ptr to last screen scroll coord
; - DE: Ptr to OBJLst coord to be updated (relative to screen)
Map_UpdateOBJRelCoord:
	; Get the amount of px the screen was scrolled
	ld   a, [bc]
	sub  a, [hl]	; Get the movement offset
	ld   b, a		; B = LastMapScroll - MapScroll
	; Add that offset to the OBJLst coord
	ld   a, [de]	
	add  b			; Apply it to the current mapping coord to allow movement.
	ld   [de], a	; ItemCoord += LastMapScroll - MapScroll
	ret
; =============== Map_WriteOBJLst ===============
; Writes an entire OBJ list for use in map screens.
;
; This is exactly the same as WriteOBJLst (in BANK $05),
; except it uses different memory addresses.
Map_WriteOBJLst:
	; Index the sprite mappings table
	ld   a, [sMapOAMWriteLstId]
	ld   d, $00		; DE = A * 2
	ld   e, a
	sla  e			; do *2 from here, in case A would have overflowed for high mapping IDs
	rl   d			; and preserve the carry
	add  hl, de
	
	ldi  a, [hl]			; DE = Ptr to sprite mapping
	ld   e, a
	ld   a, [hl]
	ld   d, a
	
	ld   h, HIGH(sWorkOAM)	; HL = Current OAM mirror position
	ld   a, [sWorkOAMPos]
	ld   l, a
	
	ld   a, [sMapOAMWriteY]	; B = Base Y position
	ld   b, a
	ld   a, [sMapOAMWriteX]	; C = Base X position
	ld   c, a
.loop:
	ld   a, l					
	cp   a, LOW(sWorkOAM_End)	; Have we gone past the end of the OAM mirror? (HL >= $AFA0)
	ret  nc						; If so, return. We don't want glitchy sprites.
	
	ld   a, [de]				
	cp   a, $80					; Have we reached the end separator? (first byte of entry $80)
	ret  z						; If so, return
	;--
.doYCoord:
	ld   a, [sMapOAMWriteFlags]	; Check for Y flip
	bit  6, a
	jr   z, .noYFlip
	ld   a, [de]				; A = Relative Y position
	cpl							; Invert the Y position
	sub  a, $07					; And fix the alignment since the Y origin should be on the top
	jr   .writeY
.noYFlip:
	ld   a, [de]				; A = Relative Y position
.writeY:
	add  b						; Add the base Y position
	ldi  [hl], a				; Write it the OAM copy
	inc  de						; OAMLstPtr++
	
	; Do the same for the X coord
.doXCoord:
	ld   a, [sMapOAMWriteFlags]	; Check for X flip
	bit  5, a
	jr   z, .noXFlip
	ld   a, [de]				; A = Relative X position
	cpl							; Invert the X position
	sub  a, $07					; And fix the alignment since the X origin should be on the left
	jr   .writeX
.noXFlip:
	ld   a, [de]				; A = Relative X position
.writeX:
	add  c					; Add the base X offset
	ldi  [hl], a				; Write it the OAM copy
	inc  de						; OAMLstPtr++

.writeTileId:
	ld   a, [de]				; Set the tile ID to use
	ldi  [hl], a
	inc  de
	
.writeFlags:
	push hl
	ld   hl, sMapOAMWriteFlags
	; A = DefaultFlags v CustomFlags
	ld   a, [de]
	xor  a, [hl]				; Reverse the requested OAM flag bits
	pop  hl
	ldi  [hl], a				; Save the flags
	
	ld   a, l					; Update the cursor
	ld   [sWorkOAMPos], a
	inc  de
	jr   .loop
	
; =============== OBJLstPtrTable_MapWario ===============
; Sprite mappings for Wario in the Map Screen
; $2C0F
OBJLstPtrTable_MapWario:
	; [TCRF] The way these are laid out suggest that animations were intended 
	;        at some point to be 4 frames instead of 3.
	;        However, with the exception of the first one, all point to unused dummt OBJLst.
	dw OBJLst_Unused_MapWarioWalk0
	dw OBJLst_MapWarioWalk1
	dw OBJLst_MapWarioWalk2
	dw OBJLst_MapWarioWalk3
	dw OBJLst_MapWarioStand0
	dw OBJLst_MapWarioStand1
	dw OBJLst_MapWarioStand2
	dw OBJLst_Unused_MapWarioNone ; [TCRF] Unused dummy mapping with no sprites assigned.
	dw OBJLst_MapWarioWalkBack0
	dw OBJLst_MapWarioWalkBack1
	dw OBJLst_MapWarioWalkBack2
	dw OBJLst_Unused_MapWarioNone
	dw OBJLst_MapWarioWaterFront
	dw OBJLst_MapWarioWaterBack
	dw OBJLst_MapWarioHide ; What's used when Wario is hidden. Why didn't this reuse MapWarioNone?

OBJLst_Unused_MapWarioNone: INCBIN "data/objlst/map/wario_unused_none.bin"
OBJLst_Unused_MapWarioWalk0: INCBIN "data/objlst/map/wario_unused_walk0.bin"
OBJLst_MapWarioWalk1: INCBIN "data/objlst/map/wario_walk1.bin"
OBJLst_MapWarioWalk2: INCBIN "data/objlst/map/wario_walk2.bin"
OBJLst_MapWarioWalk3: INCBIN "data/objlst/map/wario_walk3.bin"
OBJLst_MapWarioStand0: INCBIN "data/objlst/map/wario_stand0.bin"
OBJLst_MapWarioStand1: INCBIN "data/objlst/map/wario_stand1.bin"
OBJLst_MapWarioStand2: INCBIN "data/objlst/map/wario_stand2.bin"
OBJLst_MapWarioWalkBack0: INCBIN "data/objlst/map/wario_walkback0.bin"
OBJLst_MapWarioWalkBack1: INCBIN "data/objlst/map/wario_walkback1.bin"
OBJLst_MapWarioWalkBack2: INCBIN "data/objlst/map/wario_walkback2.bin"
OBJLst_MapWarioWaterFront: INCBIN "data/objlst/map/wario_waterfront.bin"
OBJLst_MapWarioWaterBack: INCBIN "data/objlst/map/wario_waterback.bin"
OBJLst_MapWarioHide: INCBIN "data/objlst/map/wario_hide.bin"

; =============== START OF ALIGN JUNK ===============
L002CFB: db $A8;X
L002CFC: db $A2;X
L002CFD: db $8A;X
L002CFE: db $2A;X
L002CFF: db $2A;X
L002D00: db $AA;X
L002D01: db $AE;X
L002D02: db $AE;X
L002D03: db $EA;X
L002D04: db $AE;X
L002D05: db $AA;X
L002D06: db $EA;X
L002D07: db $AA;X
L002D08: db $AE;X
L002D09: db $EA;X
L002D0A: db $AA;X
L002D0B: db $AE;X
L002D0C: db $EE;X
L002D0D: db $AB;X
L002D0E: db $AA;X
L002D0F: db $BA;X
L002D10: db $AA;X
L002D11: db $EA;X
L002D12: db $EA;X
L002D13: db $EA;X
L002D14: db $EA;X
L002D15: db $AA;X
L002D16: db $AA;X
L002D17: db $AA;X
L002D18: db $AA;X
L002D19: db $AE;X
L002D1A: db $AA;X
L002D1B: db $EA;X
L002D1C: db $AE;X
L002D1D: db $AA;X
L002D1E: db $AE;X
L002D1F: db $AA;X
L002D20: db $AA;X
L002D21: db $AE;X
L002D22: db $AA;X
L002D23: db $AA;X
L002D24: db $EA;X
L002D25: db $AA;X
L002D26: db $AA;X
L002D27: db $AA;X
L002D28: db $AA;X
L002D29: db $AE;X
L002D2A: db $AA;X
L002D2B: db $AA;X
L002D2C: db $AF;X
L002D2D: db $AA;X
L002D2E: db $AA;X
L002D2F: db $EF;X
L002D30: db $EA;X
L002D31: db $AA;X
L002D32: db $EE;X
L002D33: db $AA;X
L002D34: db $AA;X
L002D35: db $AA;X
L002D36: db $EB;X
L002D37: db $EE;X
L002D38: db $AA;X
L002D39: db $AA;X
L002D3A: db $AA;X
L002D3B: db $AE;X
L002D3C: db $AE;X
L002D3D: db $EA;X
L002D3E: db $EA;X
L002D3F: db $AA;X
L002D40: db $EA;X
L002D41: db $AE;X
L002D42: db $AA;X
L002D43: db $EA;X
L002D44: db $EE;X
L002D45: db $AA;X
L002D46: db $EA;X
L002D47: db $AA;X
L002D48: db $AA;X
L002D49: db $BE;X
L002D4A: db $AE;X
L002D4B: db $EA;X
L002D4C: db $AA;X
L002D4D: db $AA;X
L002D4E: db $AA;X
L002D4F: db $AE;X
L002D50: db $AE;X
L002D51: db $EE;X
L002D52: db $EA;X
L002D53: db $EA;X
L002D54: db $AA;X
L002D55: db $AA;X
L002D56: db $AB;X
L002D57: db $AB;X
L002D58: db $AA;X
L002D59: db $AA;X
L002D5A: db $AA;X
L002D5B: db $AE;X
L002D5C: db $AA;X
L002D5D: db $EA;X
L002D5E: db $FA;X
L002D5F: db $AA;X
L002D60: db $EE;X
L002D61: db $AE;X
L002D62: db $EA;X
L002D63: db $AE;X
L002D64: db $EA;X
L002D65: db $AA;X
L002D66: db $AA;X
L002D67: db $BA;X
L002D68: db $AE;X
L002D69: db $EA;X
L002D6A: db $AA;X
L002D6B: db $AA;X
L002D6C: db $AA;X
L002D6D: db $EA;X
L002D6E: db $AA;X
L002D6F: db $AA;X
L002D70: db $AE;X
L002D71: db $AA;X
L002D72: db $AA;X
L002D73: db $AA;X
L002D74: db $AA;X
L002D75: db $AE;X
L002D76: db $AE;X
L002D77: db $AE;X
L002D78: db $BA;X
L002D79: db $8E;X
L002D7A: db $AA;X
L002D7B: db $EE;X
L002D7C: db $AA;X
L002D7D: db $AA;X
L002D7E: db $AA;X
L002D7F: db $AA;X
L002D80: db $AA;X
L002D81: db $A8;X
L002D82: db $2A;X
L002D83: db $A8;X
L002D84: db $2A;X
L002D85: db $22;X
L002D86: db $0A;X
L002D87: db $A0;X
L002D88: db $88;X
L002D89: db $8A;X
L002D8A: db $A8;X
L002D8B: db $0A;X
L002D8C: db $82;X
L002D8D: db $AA;X
L002D8E: db $A2;X
L002D8F: db $28;X
L002D90: db $2A;X
L002D91: db $AA;X
L002D92: db $AA;X
L002D93: db $2A;X
L002D94: db $A2;X
L002D95: db $AA;X
L002D96: db $AA;X
L002D97: db $A0;X
L002D98: db $22;X
L002D99: db $8A;X
L002D9A: db $8A;X
L002D9B: db $28;X
L002D9C: db $A2;X
L002D9D: db $88;X
L002D9E: db $88;X
L002D9F: db $A0;X
L002DA0: db $AA;X
L002DA1: db $A2;X
L002DA2: db $88;X
L002DA3: db $AA;X
L002DA4: db $82;X
L002DA5: db $A2;X
L002DA6: db $22;X
L002DA7: db $8A;X
L002DA8: db $AA;X
L002DA9: db $AA;X
L002DAA: db $AA;X
L002DAB: db $AA;X
L002DAC: db $A8;X
L002DAD: db $28;X
L002DAE: db $AA;X
L002DAF: db $A8;X
L002DB0: db $AA;X
L002DB1: db $AA;X
L002DB2: db $8A;X
L002DB3: db $AA;X
L002DB4: db $A2;X
L002DB5: db $22;X
L002DB6: db $2A;X
L002DB7: db $AA;X
L002DB8: db $02;X
L002DB9: db $AA;X
L002DBA: db $AA;X
L002DBB: db $8A;X
L002DBC: db $2A;X
L002DBD: db $00;X
L002DBE: db $2A;X
L002DBF: db $A2;X
L002DC0: db $A2;X
L002DC1: db $A8;X
L002DC2: db $8A;X
L002DC3: db $AA;X
L002DC4: db $AA;X
L002DC5: db $8A;X
L002DC6: db $AA;X
L002DC7: db $08;X
L002DC8: db $8A;X
L002DC9: db $8A;X
L002DCA: db $AA;X
L002DCB: db $2A;X
L002DCC: db $2A;X
L002DCD: db $AA;X
L002DCE: db $8A;X
L002DCF: db $AA;X
L002DD0: db $28;X
L002DD1: db $A2;X
L002DD2: db $A2;X
L002DD3: db $AA;X
L002DD4: db $02;X
L002DD5: db $00;X
L002DD6: db $A8;X
L002DD7: db $A8;X
L002DD8: db $A2;X
L002DD9: db $8A;X
L002DDA: db $AA;X
L002DDB: db $8A;X
L002DDC: db $0A;X
L002DDD: db $AA;X
L002DDE: db $A8;X
L002DDF: db $88;X
L002DE0: db $88;X
L002DE1: db $A0;X
L002DE2: db $8A;X
L002DE3: db $0A;X
L002DE4: db $22;X
L002DE5: db $8A;X
L002DE6: db $A8;X
L002DE7: db $AA;X
L002DE8: db $A8;X
L002DE9: db $A0;X
L002DEA: db $28;X
L002DEB: db $A8;X
L002dec: db $A2;X
L002DED: db $A8;X
L002DEE: db $A8;X
L002DEF: db $82;X
L002DF0: db $88;X
L002DF1: db $82;X
L002DF2: db $8A;X
L002DF3: db $A8;X
L002DF4: db $22;X
L002DF5: db $A8;X
L002DF6: db $8A;X
L002DF7: db $AA;X
L002DF8: db $AA;X
L002DF9: db $82;X
L002DFA: db $AA;X
L002DFB: db $08;X
L002DFC: db $AA;X
L002DFD: db $A2;X
L002DFE: db $AA;X
L002DFF: db $AA;X
L002E00: db $AA;X
L002E01: db $EA;X
L002E02: db $EA;X
L002E03: db $EA;X
L002E04: db $EA;X
L002E05: db $AA;X
L002E06: db $AA;X
L002E07: db $EA;X
L002E08: db $AA;X
L002E09: db $AA;X
L002E0A: db $AA;X
L002E0B: db $AA;X
L002E0C: db $AA;X
L002E0D: db $AA;X
L002E0E: db $FA;X
L002E0F: db $BA;X
L002E10: db $AA;X
L002E11: db $AA;X
L002E12: db $EA;X
L002E13: db $AF;X
L002E14: db $AA;X
L002E15: db $EA;X
L002E16: db $EE;X
L002E17: db $AA;X
L002E18: db $AA;X
L002E19: db $FA;X
L002E1A: db $AB;X
L002E1B: db $AA;X
L002E1C: db $BA;X
L002E1D: db $EA;X
L002E1E: db $AB;X
L002E1F: db $EA;X
L002E20: db $EE;X
L002E21: db $BE;X
L002E22: db $AA;X
L002E23: db $AE;X
L002E24: db $BA;X
L002E25: db $EE;X
L002E26: db $EA;X
L002E27: db $EE;X
L002E28: db $AA;X
L002E29: db $FA;X
L002E2A: db $AA;X
L002E2B: db $AA;X
L002E2C: db $AE;X
L002E2D: db $EA;X
L002E2E: db $BA;X
L002E2F: db $AA;X
L002E30: db $AA;X
L002E31: db $AE;X
L002E32: db $EA;X
L002E33: db $EE;X
L002E34: db $AB;X
L002E35: db $AA;X
L002E36: db $AA;X
L002E37: db $EA;X
L002E38: db $EA;X
L002E39: db $AA;X
L002E3A: db $AA;X
L002E3B: db $AE;X
L002E3C: db $AA;X
L002E3D: db $AE;X
L002E3E: db $AA;X
L002E3F: db $AA;X
L002E40: db $AA;X
L002E41: db $AA;X
L002E42: db $EF;X
L002E43: db $AA;X
L002E44: db $EA;X
L002E45: db $EA;X
L002E46: db $BA;X
L002E47: db $AE;X
L002E48: db $EA;X
L002E49: db $AA;X
L002E4A: db $AA;X
L002E4B: db $AA;X
L002E4C: db $AA;X
L002E4D: db $AA;X
L002E4E: db $EA;X
L002E4F: db $AE;X
L002E50: db $AF;X
L002E51: db $AA;X
L002E52: db $EA;X
L002E53: db $AA;X
L002E54: db $AA;X
L002E55: db $EA;X
L002E56: db $EA;X
L002E57: db $AA;X
L002E58: db $AA;X
L002E59: db $EA;X
L002E5A: db $BA;X
L002E5B: db $AA;X
L002E5C: db $AA;X
L002E5D: db $AA;X
L002E5E: db $AA;X
L002E5F: db $EA;X
L002E60: db $EA;X
L002E61: db $EA;X
L002E62: db $AA;X
L002E63: db $AA;X
L002E64: db $AA;X
L002E65: db $EA;X
L002E66: db $AE;X
L002E67: db $AB;X
L002E68: db $AF;X
L002E69: db $AA;X
L002E6A: db $AE;X
L002E6B: db $AE;X
L002E6C: db $AA;X
L002E6D: db $EA;X
L002E6E: db $AA;X
L002E6F: db $AA;X
L002E70: db $EA;X
L002E71: db $EA;X
L002E72: db $AE;X
L002E73: db $AA;X
L002E74: db $AA;X
L002E75: db $AA;X
L002E76: db $AE;X
L002E77: db $AA;X
L002E78: db $AE;X
L002E79: db $EA;X
L002E7A: db $AA;X
L002E7B: db $8A;X
L002E7C: db $AA;X
L002E7D: db $AA;X
L002E7E: db $AE;X
L002E7F: db $AA;X
L002E80: db $22;X
L002E81: db $AA;X
L002E82: db $AA;X
L002E83: db $88;X
L002E84: db $AA;X
L002E85: db $88;X
L002E86: db $82;X
L002E87: db $0A;X
L002E88: db $A8;X
L002E89: db $AA;X
L002E8A: db $AA;X
L002E8B: db $02;X
L002E8C: db $08;X
L002E8D: db $8A;X
L002E8E: db $A8;X
L002E8F: db $82;X
L002E90: db $A2;X
L002E91: db $2A;X
L002E92: db $8A;X
L002E93: db $22;X
L002E94: db $80;X
L002E95: db $8A;X
L002E96: db $8A;X
L002E97: db $AA;X
L002E98: db $AA;X
L002E99: db $8A;X
L002E9A: db $88;X
L002E9B: db $A0;X
L002E9C: db $2A;X
L002E9D: db $08;X
L002E9E: db $2A;X
L002E9F: db $A0;X
L002EA0: db $22;X
L002EA1: db $AA;X
L002EA2: db $AA;X
L002EA3: db $A2;X
L002EA4: db $AA;X
L002EA5: db $08;X
L002EA6: db $2A;X
L002EA7: db $22;X
L002EA8: db $28;X
L002EA9: db $A2;X
L002EAA: db $8A;X
L002EAB: db $20;X
L002EAC: db $2A;X
L002EAD: db $A2;X
L002EAE: db $AA;X
L002EAF: db $AA;X
L002EB0: db $22;X
L002EB1: db $AA;X
L002EB2: db $AA;X
L002EB3: db $AA;X
L002EB4: db $02;X
L002EB5: db $8A;X
L002EB6: db $2A;X
L002EB7: db $2A;X
L002EB8: db $8A;X
L002EB9: db $22;X
L002EBA: db $8A;X
L002EBB: db $AA;X
L002EBC: db $88;X
L002EBD: db $AA;X
L002EBE: db $8A;X
L002EBF: db $2A;X
L002EC0: db $88;X
L002EC1: db $2A;X
L002EC2: db $A8;X
L002EC3: db $00;X
L002EC4: db $0A;X
L002EC5: db $88;X
L002EC6: db $AA;X
L002EC7: db $BA;X
L002EC8: db $AA;X
L002EC9: db $20;X
L002ECA: db $8A;X
L002ECB: db $08;X
L002ECC: db $8A;X
L002ECD: db $8A;X
L002ECE: db $AA;X
L002ECF: db $22;X
L002ED0: db $20;X
L002ED1: db $88;X
L002ED2: db $2A;X
L002ED3: db $A2;X
L002ED4: db $20;X
L002ED5: db $AA;X
L002ED6: db $AA;X
L002ED7: db $20;X
L002ED8: db $A2;X
L002ED9: db $2A;X
L002EDA: db $2A;X
L002EDB: db $80;X
L002EDC: db $2A;X
L002EDD: db $A2;X
L002EDE: db $AA;X
L002EDF: db $A0;X
L002EE0: db $22;X
L002EE1: db $02;X
L002EE2: db $A8;X
L002EE3: db $82;X
L002EE4: db $AA;X
L002EE5: db $A2;X
L002EE6: db $28;X
L002EE7: db $AA;X
L002EE8: db $AA;X
L002EE9: db $A2;X
L002EEA: db $AA;X
L002EEB: db $8A;X
L002EEC: db $AA;X
L002EED: db $A8;X
L002EEE: db $2A;X
L002EEF: db $A8;X
L002EF0: db $00;X
L002EF1: db $8A;X
L002EF2: db $02;X
L002EF3: db $20;X
L002EF4: db $2A;X
L002EF5: db $88;X
L002EF6: db $0A;X
L002EF7: db $AA;X
L002EF8: db $88;X
L002EF9: db $22;X
L002EFA: db $AA;X
L002EFB: db $AA;X
L002EFC: db $AA;X
L002EFD: db $AA;X
L002EFE: db $2A;X
L002EFF: db $0A;X
L002F00: db $EE;X
L002F01: db $AB;X
L002F02: db $AE;X
L002F03: db $AA;X
L002F04: db $EA;X
L002F05: db $AA;X
L002F06: db $EA;X
L002F07: db $AA;X
L002F08: db $AE;X
L002F09: db $AA;X
L002F0A: db $6B;X
L002F0B: db $FE;X
L002F0C: db $AE;X
L002F0D: db $EA;X
L002F0E: db $AA;X
L002F0F: db $AA;X
L002F10: db $AE;X
L002F11: db $AE;X
L002F12: db $AE;X
L002F13: db $AA;X
L002F14: db $AE;X
L002F15: db $AE;X
L002F16: db $AE;X
L002F17: db $AE;X
L002F18: db $AA;X
L002F19: db $AA;X
L002F1A: db $AB;X
L002F1B: db $AE;X
L002F1C: db $AA;X
L002F1D: db $AA;X
L002F1E: db $AE;X
L002F1F: db $AE;X
L002F20: db $AE;X
L002F21: db $AA;X
L002F22: db $AE;X
L002F23: db $AE;X
L002F24: db $AA;X
L002F25: db $AE;X
L002F26: db $AA;X
L002F27: db $AA;X
L002F28: db $FE;X
L002F29: db $AA;X
L002F2A: db $AA;X
L002F2B: db $AA;X
L002F2C: db $AE;X
L002F2D: db $EA;X
L002F2E: db $AA;X
L002F2F: db $AE;X
L002F30: db $EA;X
L002F31: db $AA;X
L002F32: db $AA;X
L002F33: db $AA;X
L002F34: db $AE;X
L002F35: db $AA;X
L002F36: db $EB;X
L002F37: db $AA;X
L002F38: db $AA;X
L002F39: db $AA;X
L002F3A: db $EE;X
L002F3B: db $AA;X
L002F3C: db $EE;X
L002F3D: db $AE;X
L002F3E: db $AA;X
L002F3F: db $AA;X
L002F40: db $AA;X
L002F41: db $AE;X
L002F42: db $EE;X
L002F43: db $AA;X
L002F44: db $AA;X
L002F45: db $AA;X
L002F46: db $EA;X
L002F47: db $EA;X
L002F48: db $AA;X
L002F49: db $AE;X
L002F4A: db $AE;X
L002F4B: db $AA;X
L002F4C: db $AA;X
L002F4D: db $AA;X
L002F4E: db $EE;X
L002F4F: db $AA;X
L002F50: db $AA;X
L002F51: db $8A;X
L002F52: db $AE;X
L002F53: db $AE;X
L002F54: db $AF;X
L002F55: db $AA;X
L002F56: db $AE;X
L002F57: db $BA;X
L002F58: db $AA;X
L002F59: db $EA;X
L002F5A: db $AE;X
L002F5B: db $EF;X
L002F5C: db $AE;X
L002F5D: db $EA;X
L002F5E: db $AA;X
L002F5F: db $AA;X
L002F60: db $AA;X
L002F61: db $AA;X
L002F62: db $AA;X
L002F63: db $BA;X
L002F64: db $EE;X
L002F65: db $EA;X
L002F66: db $BE;X
L002F67: db $AA;X
L002F68: db $FA;X
L002F69: db $AA;X
L002F6A: db $EA;X
L002F6B: db $AE;X
L002F6C: db $EE;X
L002F6D: db $AF;X
L002F6E: db $EE;X
L002F6F: db $AA;X
L002F70: db $EE;X
L002F71: db $AA;X
L002F72: db $AA;X
L002F73: db $AB;X
L002F74: db $AE;X
L002F75: db $AE;X
L002F76: db $EA;X
L002F77: db $AE;X
L002F78: db $AB;X
L002F79: db $AE;X
L002F7A: db $AA;X
L002F7B: db $AA;X
L002F7C: db $AA;X
L002F7D: db $AE;X
L002F7E: db $AA;X
L002F7F: db $AA;X
L002F80: db $80;X
L002F81: db $A8;X
L002F82: db $08;X
L002F83: db $00;X
L002F84: db $A2;X
L002F85: db $88;X
L002F86: db $A2;X
L002F87: db $AA;X
L002F88: db $A8;X
L002F89: db $A0;X
L002F8A: db $0A;X
L002F8B: db $AA;X
L002F8C: db $88;X
L002F8D: db $AA;X
L002F8E: db $AA;X
L002F8F: db $08;X
L002F90: db $A2;X
L002F91: db $A2;X
L002F92: db $A0;X
L002F93: db $28;X
L002F94: db $AA;X
L002F95: db $A8;X
L002F96: db $28;X
L002F97: db $88;X
L002F98: db $22;X
L002F99: db $0A;X
L002F9A: db $28;X
L002F9B: db $28;X
L002F9C: db $88;X
L002F9D: db $20;X
L002F9E: db $AA;X
L002F9F: db $88;X
L002FA0: db $A8;X
L002FA1: db $80;X
L002FA2: db $88;X
L002FA3: db $A8;X
L002FA4: db $00;X
L002FA5: db $0A;X
L002FA6: db $8A;X
L002FA7: db $8A;X
L002FA8: db $82;X
L002FA9: db $AA;X
L002FAA: db $A2;X
L002FAB: db $28;X
L002FAC: db $82;X
L002FAD: db $0A;X
L002FAE: db $0A;X
L002FAF: db $A2;X
L002FB0: db $A8;X
L002FB1: db $0A;X
L002FB2: db $88;X
L002FB3: db $A8;X
L002FB4: db $A8;X
L002FB5: db $AA;X
L002FB6: db $A2;X
L002FB7: db $AA;X
L002FB8: db $A0;X
L002FB9: db $A2;X
L002FBA: db $A2;X
L002FBB: db $2A;X
L002FBC: db $2A;X
L002FBD: db $88;X
L002FBE: db $AA;X
L002FBF: db $AA;X
L002FC0: db $08;X
L002FC1: db $A8;X
L002FC2: db $A2;X
L002FC3: db $AA;X
L002FC4: db $AA;X
L002FC5: db $AA;X
L002FC6: db $8A;X
L002FC7: db $AA;X
L002FC8: db $A8;X
L002FC9: db $0A;X
L002FCA: db $A2;X
L002FCB: db $A8;X
L002FCC: db $0A;X
L002FCD: db $8A;X
L002FCE: db $AA;X
L002FCF: db $AA;X
L002FD0: db $A2;X
L002FD1: db $8A;X
L002FD2: db $AA;X
L002FD3: db $A2;X
L002FD4: db $A0;X
L002FD5: db $22;X
L002FD6: db $AA;X
L002FD7: db $AA;X
L002FD8: db $A2;X
L002FD9: db $AA;X
L002FDA: db $20;X
L002FDB: db $A0;X
L002FDC: db $AA;X
L002FDD: db $28;X
L002FDE: db $8A;X
L002FDF: db $A2;X
L002FE0: db $A0;X
L002FE1: db $A8;X
L002FE2: db $A8;X
L002FE3: db $A2;X
L002FE4: db $80;X
L002FE5: db $82;X
L002FE6: db $A0;X
L002FE7: db $A8;X
L002FE8: db $2A;X
L002FE9: db $8A;X
L002FEA: db $AA;X
L002FEB: db $22;X
L002FEC: db $A2;X
L002FED: db $22;X
L002FEE: db $0A;X
L002FEF: db $0A;X
L002FF0: db $AA;X
L002FF1: db $20;X
L002FF2: db $A2;X
L002FF3: db $A2;X
L002FF4: db $88;X
L002FF5: db $A2;X
L002FF6: db $AA;X
L002FF7: db $AA;X
L002FF8: db $AA;X
L002FF9: db $AA;X
L002FFA: db $2A;X
L002FFB: db $22;X
L002FFC: db $88;X
L002FFD: db $88;X
L002FFE: db $A8;X
L002FFF: db $A0;X
; =============== END OF ALIGN JUNK ===============

SubCall_ActS_SetOBJLstTableForDefault: mSubCallRet ActS_SetOBJLstTableForDefault ; BANK $0F
; =============== ActS_GetPlDirHRel ===============
; This subroutine gets the player's horizontal position (as a direction value) 
; relative to the current actor's position.
;
; It can be used, for example, to make an actor move torwards the player.
; 
; OUT
; - A: Direction value (DIR_*)
ActS_GetPlDirHRel:

	; Get the two X positions we'll be comparing. 
	;
	; We're adding $40 to both values (even though it cancels itself out in the end)
	; just in case one of these positions is negative, to force them back to positive.
	; $40 is high enough that the actor will have already despawned by the time it gets that far.
	;
	; Player's X pos
	; BC = sPlX + $40
	ld   a, [sPlX_Low]		
	add  $40
	ld   c, a
	ld   a, [sPlX_High]
	adc  a, $00
	ld   b, a
	
	; Actor's X pos
	; HL = sActSetX + $40
	ld   a, [sActSetX_Low]
	add  $40
	ld   l, a
	ld   a, [sActSetX_High]
	adc  a, $00
	ld   h, a
	
	;
	; Determine if the player is to the left of the actor (BC < HL).
	; This can be done by checking if HL - BC > 0.
	;
	; However, since we don't need the result of this subtraction,
	; so we can take a shortcut by only making sure the carry flag is preserved.
	;
	
	; BC <= HL?
	ld   a, l	; A = Actor's low byte
	sub  a, c	; Subtract the player's low byte to get the carry
	ld   a, h	; A = Actor's high byte
	sbc  a, b	; Subtract the player's high byte, along with the previous carry
				; to get the actual carry value we need.
	
	; If the carry flag isn't set, BC <= HL, so the player is considered to be at the left of the actor.
	; No special case for the exact center, not like it's really needed for this anyway.
	jr   nc, .dirL
.dirR:
	ld   a, DIR_R
	ret
.dirL:
	ld   a, DIR_L
	ret
	
; =============== Pl_ActHurt ===============
; This subroutine starts the damage sequence when hurt by an actor.
;
; This is the closest equivalent to Pl_BGHurt, through actors generally don't call this subroutine,
; opting instead to set the collision box and let PlActColiMask_CheckType_Damage deal damage.
;
; In fact, this is used only once, and in practice only during post-hit invulnerability.
Pl_ActHurt:
	ld   a, [sPlPostHitInvulnTimer]
	and  a							; Is the player in the post-hit invulnerability?
	ret  nz							; If so, return
	;--
	; [TCRF] Technically possible to get here (but only in a very specific condition with debug mode)
	xor  a
	ld   [sPlGroundDashTimer], a
	ld   [sPlJetDashTimer], a
	ld   [sPlFreezeTimer], a
	ld   [sPlSuperJump], a
	
	ld   a, [sSmallWario]
	and  a									; Are we Small Wario?
	jr   nz, .kill							; If so, kill the player
	
	ld   a, PL_HT_ACTHURT					; Otherwise, register damage from an actor
	ld   [sPlHurtType], a
	xor  a									; Curiously, this uses "xor a" unlike PlActColiMask_CheckType_Damage
	ld   [sPlPowerSet], a					; Switch to Small Wario
	call Game_InitHatSwitch
	ret
.kill:
	call Pl_StartDeathAnim
	ret  
	
; =============== Pl_SetDirRight ===============
; Sets the player direction to the right. 
Pl_SetDirRight:
	ld   a, [sPlFlags]
	set  OBJLSTB_XFLIP, a
	ld   [sPlFlags], a
	ret
; =============== ActS_DespawnAllNormExceptCur_Broken ===============
; This subroutine tries to despawn active non-default actors except for the one being currently executed.
;
; This is meant to be called by the boss code, when a boss is marked as dead, to get 
; rid of anything which can damage the player.
; For example, the SS Teacup boss calls this to get rid of any on-screen Watches.
;
; [BUG] ...except it doesn't work!
; Due to a bug it attempts to despawn only the actor in the first slot. 
; The boss is always the first actor loaded in, which gets skipped, so this ends up doing nothing at all!
;
; Keep in mind that the spawned actors themselves check themselves if the boss is dead (for example, see Act_SSTeacupBossWatch),
; and triggers the "jump dead" routine, which is a better effect than what this was meant to do.
; Maybe this was disabled intentionally?
;
ActS_DespawnAllNormExceptCur_Broken:
	ld   a, [sActNumProc]	; E = Slot to not despawn
	ld   e, a
	ld   hl, sAct+(sActSetId-sActSet)	; HL = Start of actor area (seek to actor ID)
	ld   d, $00				; D = Slot num
.checkSlot:
	;
	; Check if we can despawn the actor in this slot
	;
	ld   a, d				
	cp   e					; Is this the slot we aren't despawning?
	jr   z, .nextSlot			; If so, skip this slot
	ld   a, [hl]			; Read the actor ID
	and  a, $0F				; Filter upper nybble
	cp   a, $07				; Is this a default actor (id >= $07)?
	jr   nc, .nextSlot		; If so, skip this slot
.freeSlot:
	; Seek to BC the active status
	ld   b, h				; BC = HL - $10
	ld   a, l
	sub  a, (sActSetId-sActSet)
	ld   c, a
	; Mark the slot as freed
	xor  a					
	ld   [bc], a
.nextSlot:
	; HL += $20 (slot size)
	ld   a, l
	add  (sActSet_End-sActSet)
	ld   l, a
	inc  d					; SlotNum++
	;ld   a, d
	; [BUG] Somehow a "ld a, d" is missing.
	;		This is obviously meant to check if we reached the last slot (which we just incremented),
	;		but it ends up checking the low byte of HL instead, which will always be $30 in the first loop.
	;		$30 > $07, so it returns immediately.
	; [NOTE] Also, only default actors (which we don't want to remove) can spawn in slots $05-$06.
	;        This could have been "cp   a, $05"
	cp   a, $07				; Have we reached the last slot?
	jr   c, .checkSlot 		; If not, loop
	ret
; =============== ActS_SetOBJLstSharedTablePtr ===============
; Updates the shared OBJLstPtrTable pointer of the currently processed actor.
; IN
; - BC: Updated shared table ptr
ActS_SetOBJLstSharedTablePtr:
	ld   a, c
	ld   [sActSetOBJLstSharedTablePtr], a
	ld   a, b
	ld   [sActSetOBJLstSharedTablePtr+1], a
	ret
; =============== ActS_SetCodePtr ===============
; Updates the code pointer of the currently processed actor.
; IN
; - BC: Updated code ptr, which must point to BANK $02 or BANK $00
ActS_SetCodePtr:
	ld   a, c
	ld   [sActSetCodePtr], a
	ld   a, b
	ld   [sActSetCodePtr+1], a
	ret
; =============== ActS_ClearRoutineId ===============
; Resets the routine id/interaction mode for the current actor back to $00,
; while keeping the "interaction direction" fields.
ActS_ClearRoutineId:
	ld   a, [sActSetRoutineId]
	and  a, $F0
	ld   [sActSetRoutineId], a
	ret
	
; =============== ActS_SetOBJLstPtr ===============
; Sets the specified OBJLst for the currently processed actor.
; IN
; - BC: Ptr to OBJLstPtrTable
ActS_SetOBJLstPtr:
	ld   a, c
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, b
	ld   [sActSetOBJLstPtrTablePtr_High], a
	xor  a
	ld   [sActSetOBJLstId], a
	ret
; =============== ActS_IncOBJLstIdEvery8 ===============
; Increases the OBJLstId for the currently processed actor every 8 frames.
ActS_IncOBJLstIdEvery8:
	; Every 8 frames
	ld   a, [sTimer]
	and  a, $07
	ret  nz
	ld   a, [sActSetOBJLstId] 	; sActSetOBJLstId++
	inc  a
	ld   [sActSetOBJLstId], a
	ret
	
; =============== Rand ===============
; This subroutine generates a random 16bit number.
;
; Generally, the global timer (or another timer) is used as-is for getting a quick "random" value,
; but when more randomness is required you should use this instead.
;
; OUT
; - A: Number generated
; - sRandom: Same as above
Rand:
	push bc
	; To have a bit of randomness we're using:
	; - the rDIV register (random value essentially)
	; - the previously generated random variable
	; - the global timer
	;
	; To generate the new random number, these values are added together like this.
	; sRandom += SWAP(rDIV) + rDIV + sTimer
	;--
	ldh  a, [rDIV]		
	ld   b, a			; B = rDIV
	swap a				; B += (rDIV << 4 | rDIV >> 4)
	add  b				
	ld   b, a

	ld   a, [sRandom]	; B += sRandom	
	add  b				
	ld   b, a

	ld   a, [sTimer]	; B += sTimer
	add  b
	
	ld   [sRandom], a	; Save the result
	;--
	pop  bc
	ret
	
; =============== SubCall ===============
; This subroutine performs a bankswitch to the specified code.
;
; This acts like the HomeCall macros, except the input parameters come from registers.
; This is used when there isn't enough space for an HomeCall, but we still want a lot of bankswitch stubs.
; Almost all actor code (both init and loop code) passes through SubCalls, for example.
;
; IN
; -  D: Bank number
; - HL: Ptr to code to code to execute
;
SubCall:
	ld   [sSubCallTmpA], a		; Save A for later
	ld   a, [sROMBank]			; Save the bank
	;--
	push af
	ld   a, d					; Switch to the specified bank number
	ld   [sROMBank], a
	ld   [MBC1RomBank2], a 
	;#
	ld   a, [sSubCallTmpA]		; Restore A
	call .callHL				; Call the requested code
	ld   [sSubCallTmpA], a		; Save back the modified result
	;#
	pop  af
	;--
	ld   [sROMBank], a
	ld   [MBC1RomBank2], a		; Restore the old bank
	ld   a, [sSubCallTmpA]		; Restore A
	ret
.callHL:
	jp   hl
	
; =============== ActS_JumpToCodePtr ===============
; Jumps to the subroutine sActSetCodePtr points to.
; This expects BANK $02 to be loaded.
ActS_JumpToCodePtr:
	ld   a, [sActSetCodePtr]	; HL = sActSetCodePtr
	ld   l, a
	ld   a, [sActSetCodePtr+1]
	ld   h, a
	jp   hl						; Go there

; =============== ActS_ReloadInitial ===============
; Reloads the current actor in its initial state.
; Starting from the next frame, the init code will be executed.
ActS_ReloadInitial:
	;--
	; Load bank $07, since it has actor group definitions
	ld   [sSubCallTmpA], a	; Save A (useless)
	ld   a, [sROMBank]
	;##
	push af					; Save bank
	ld   a, $07				; Set new bank		
	ld   [sROMBank], a		
	ld   [MBC1RomBank2], a
	ld   a, [sSubCallTmpA]	; Restore A (useless)
	;--
	; Reset the code ptr to its initial state
	call ActS_SetCodePtrFromGroup	; HL = Ptr to flags
	
	;
	; ACTOR FLAGS
	;
	
	ldi  a, [hl]					; C = Default flags	
	ld   c, a
	; Copy the lower nybble of the option flags over
	; sActSetOpts = (sActSetOpts & $F0) | (DefaultFlags & $0F)
	ld   a, [sActSetOpts]			
	and  a, $F0				; A = sActSetOpts & $F0
	ld   b, a
	ld   a, c				; B = DefaultFlags & $0F
	and  a, $0F
	or   a, b
	ld   [sActSetOpts], a	; sActSetOpts = A | B
	
	;
	; OBJLST BANK NUM
	;
	ld   a, [hl]				; B = OBJLst bank num
	ld   b, a
	; There's a table for saving OBJLst bank numbers, indexed by actor ID
	; Save this info there.
	ld   hl, sActOBJLstBank		; HL = Bank num table
	ld   a, [sActNumProc]		; DE = current actor id
	ld   d, $00
	ld   e, a
	add  hl, de					; Index the table
	ld   [hl], b				; Store the bank num
	
	;--
	; Restore the previously loaded bank (bank $02 likely)
	ld   [sSubCallTmpA], a		; Save A		
	pop  af						; A = Previous bank number
	;##
	ld   [sROMBank], a			; Restore last bank
	ld   [MBC1RomBank2], a
	ld   a, [sSubCallTmpA]		; Restore A
	;--
	ret
	
; =============== ActS_SyncHeldPos ===============
; Standalone subroutine for updating the actor's position (sActSetY and sActSetX),
; to make sure it stays in sync with the player.
; This is meant to be used for actors which can be held, but handle it by itself (those which don't go through the standard ActS_Held).
; Because of this, some unnecessary code paths for default actors aren't included here (like holding while climbing).
;
; See also: relevant code in ActS_Held.
ActS_SyncHeldPos:

	;
	; Y OFFSET: Will be stored in B and subtracted to the player's Y position.
	; X OFFSET: Will be stored in DE and added to the player's X position.
	;
	
	; Pick a different Y offset depending on the duck status
	ld   b, $1B					; B = Y offset when not ducking
	ld   a, [sPlDuck]
	or   a						; Is the player ducking?
	jr   z, .chkDir				; If not, jump
	ld   b, $13					; B = Y offset when ducking
	
.chkDir:
	; Pick a different X offset depending the direction the player's facing
	ld   de, +$0C				; DE = when facing right
	ld   a, [sPlFlags]
	bit  OBJLSTB_XFLIP, a		; Is the player facing right?
	jr   nz, .chkSmall			; If so, jump
	ld   de, -$0C				; DE = when facing left
	
.chkSmall:
	ld   a, [sPlPower]
	and  a, $0F					; Is the player small?
	jr   nz, .setOffsets		; If not, jump
	ld   b, $0F					; B = Y offset when small
	
.setOffsets:
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
	ret
	
; =============== ActS_CheckOffScreenNoDespawn ===============
; Performs the off-screen check for an held actor.
; Calling this prevents the actor from being despawned.
ActS_CheckOffScreenNoDespawn:
	ld   a, $01
	ld   [sActSetActive_Tmp], a
	jr   ActS_CheckOffScreen.setRelPos
; =============== ActS_CheckOffScreen ===============
; Performs the off-screen check for the currently loaded actor.
; This calculates the actor's relative X and Y coords and sets the active status.
; The possible statuses are:
; 0: Off-screen; should be despawned
; 1: Off-screen (don't draw) 
; 2: On-screen
; 3: Same as on-screen, but actors spawned by moving the screen get this value
ActS_CheckOffScreen:
	
	; Set the default value for the active option
	; All actors except the key default to $00, which will cause the slot to be considered free.
	
	; Is a key being held?
	ld   a, [sActHeldKey]
	or   a					
	jr   z, .noKeyHeld
	; Is the current slot the one being held?
	ld   a, [sActNumProc]
	ld   b, a				
	ld   a, [sActHeldSlotNum] 
	cp   a, b
	; If so, we're processing a key
	; A key should never be despawned by off-screen, so its default status is $01
	jr   z, ActS_CheckOffScreenNoDespawn
.noKeyHeld:
	xor  a
	ld   [sActSetActive_Tmp], a
.setRelPos:
	; Calculate the relative X/Y positions
	; These will be used for performing the off-screen check

	;--
	; Set the relative actor X position
	; sActSetRelX = ActX - ScrollX + $58
	
	; HL = X pos
	ld   a, [sActSetX_Low]
	ld   l, a
	ld   a, [sActSetX_High]
	ld   h, a
	; DE = X scroll
	ld   a, [sLvlScrollX_Low]
	ld   e, a
	ld   a, [sLvlScrollX_High]
	ld   d, a
	
	; XPos += $58 (actor offset)
	ld   bc, $0058
	add  hl, bc
	
	; ActX - ScrollX
	; HL -= DE
	ld   a, l	; L -= E
	sub  a, e	
	ld   l, a
	ld   a, h	; H -= D (-carry)
	sbc  a, d
	ld   h, a
	; Store it
	ld   a, l
	ld   [sActSetRelX], a
	ld   a, h
	ld   [sActSetRelX_High], a
	
	;--
	; Set the relative actor Y position
	; sActSetRelY = ActY - ScrollY + $58
	
	; HL = Y pos
	ld   a, [sActSetY_Low]
	ld   l, a
	ld   a, [sActSetY_High]
	ld   h, a
	; DE = Scroll Y
	ld   a, [sLvlScrollY_Low]
	ld   e, a
	ld   a, [sLvlScrollY_High]
	ld   d, a
	; YPos += $58 (actor offset)
	add  hl, bc
	; ActY - ScrollY
	; HL -= DE
	ld   a, l	; L -= E
	sub  a, e
	ld   l, a
	ld   a, h	; H -= D (-carry)
	sbc  a, d
	ld   h, a
	
	; Store the low byte
	ld   a, l
	ld   [sActSetRelY], a
	
	; Copy (default?) active status
	ld   a, [sActSetActive_Tmp]
	ld   [sActSetActive], a
	
	;--
	
.checkYLevel:
	; Check if the actor Y pos is in range. 
	; If it isn't, it's considered inactive and the actor is despawned.
	
	; If the actor on the top off-screen area? (ActYRel < $00)
	bit  7, h					
	jr   nz, .checkYTopLevel	; If so, jump
	
	
	; We're either on the current level, or in the bottom off-screen area
	; Subtract $00D0 to determine if we're too far off-screen to the bottom
	; HL -= $D0
	ld   bc, $00D0
	ld   a, l
	sub  a, c
	ld   l, a
	ld   a, h
	sbc  a, b
	ld   h, a
	
	; Is the relative Y still > 0?
	; If so, the actor is below the limit for the scroll level below, and can be despawned.
	ret  nc
	
	; If not, it's on the current screen
	jr   .checkXLevel
.checkYTopLevel:
	; Is ActYRel + $40 > $00?
	ld   bc, $0040
	add  hl, bc
	bit  7, h
	
	; If not, the actor is too high up from the screen pos
	; and should be despawned
	ret  nz
.checkXLevel:
	; Check if the actor X pos is in range. 
	;
	; Required ActXRel active range: $FFD0-$00D0 ($100 px)

	; HL = Scroll high
	ld   a, [sActSetRelX_High]
	ld   h, a
	ld   a, [sActSetRelX]
	ld   l, a
	
	
	bit  7, h			; If the actor on the left off-screen area?
	jr   nz, .checkRight	; If so, jump
	
	; We're either on-screen or in the right off-screen area
	; Subtract $00D0 to determine if we're too far off-screen to the right
	ld   bc, $00D0
	ld   a, l
	sub  a, c
	ld   l, a
	ld   a, h
	sbc  a, b
	ld   h, a
	; Is the relative X still > 0?
	; If so, the actor can be despawned
	ret  nc
	jr   .isActive
.checkRight:
	; Is ActXRel + $30 > $00?
	ld   bc, $0030
	add  hl, bc
	bit  7, h
	; If not, the actor is too much on the right from the screen pos
	; and should be despawned
	ret  nz
.isActive:
	; If we got here, the actor is definitely active
	ld   a, $01
	ld   [sActSetActive], a
	; Check if it's actually on-screen (so we can avoid drawing it if it isn't)
	; Required ActXRel range: $FFF0-$00C0
	ld   a, [sActSetRelX]
	add  $10				; extra area on the left
	cp   a, $D0				; sActSetRelX + 10 > $D0? (and implicitly sActSetRelX < 0?)
	ret  nc					; If so, we're off screen
	; Required ActYRel range: $FFF0-$00B0
	ld   a, [sActSetRelY]
	add  $10				; extra area on the top
	cp   a, $C0
	ret  nc
.isOnScreen:
	ld   a, $02
	ld   [sActSetActive], a
	ret
	
; =============== ActS_GetPlDistance ===============
; This subroutine is used to get the distance between coords of an actor and the player.
; 
; What is does is decrement HL by BC. 
; When the result is negative, it will be converted to positive.
;
; IN
; - HL: The actor's X or Y position
; - BC: The player's X or Y position
; OUT
; - HL: Distance between player and actor
ActS_GetPlDistance:
	;--
	; HL -= BC
	
	; L -= C
	ld   a, l	
	sub  a, c
	ld   l, a
	
	; H -= B
	ld   a, h
	sbc  a, b
	ld   h, a
	;--
	; If we underflowed, convert the negative number back to positive
	bit  7, a		; 16bit underflow?
	ret  z			; If not, return
	; If so, invert the bits in the upper byte
	cpl				
	ld   h, a
	; Then invert the bits in the lower byte
	ld   a, l
	cpl
	ld   l, a
	; And remember to offset by 1
	inc  hl
	ret
; =============== ActS_MoveRight ===============	
; Moves the current actor's absolute position to the right by the specified amount.
; This can be also used to move left, by using a negative coord.
; IN
; - BC: Px to move down
ActS_MoveRight:
	; sActSetX_Low += BC
	ld   a, [sActSetX_Low]
	add  c
	ld   [sActSetX_Low], a
	ld   a, [sActSetX_High]
	adc  a, b
	ld   [sActSetX_High], a
	ret
; =============== ActS_MoveLeft ===============	
; Moves the current actor's absolute position to the left by the specified amount.
; Barely ever used, since ActS_MoveRight is used almost every time for this purpose.
; IN
; - BC: Px to move left
ActS_MoveLeft:
	; sActSetX_Low -= BC
	ld   a, [sActSetX_Low]
	sub  a, c
	ld   [sActSetX_Low], a
	ld   a, [sActSetX_High]
	sbc  a, b
	ld   [sActSetX_High], a
	ret
; =============== ActS_MoveDown ===============	
; Moves the current actor's absolute position to the bottom by the specified amount.
; IN
; - BC: Px to move down
ActS_MoveDown:
	; sActSetY_Low += BC
	ld   a, [sActSetY_Low]
	add  c
	ld   [sActSetY_Low], a
	ld   a, [sActSetY_High]
	adc  a, b
	ld   [sActSetY_High], a
	ret
	
; =============== ActColi_GetBlockId_* ===============	
; Sets of subroutines to get the block ID the actor relative to the current position.
;
; Each of these offsets the source coords by specific values, 
; in order to detect the various borders the actor is colliding with (ie: top, top-right, ...).
;
; What's important here is that the actor's origin is at the very bottom of the collision box.
; Much like the player, this overlaps with the block the actor is standing on because ground
; collision is active when that origin overlaps with solid ground.
; So, much like what happens for the player, checking directly the block at the actor's position
; gives the block the actor is currently standing on.

; Since all of these have an almost identical structure with various tricks/shortcuts, these use helper macros.

; =============== ActColi_GetBlockId_Low ===============
; Gets the block ID the actor is overlapping with.
; This is more or less at the center of the actor, and matches with the block above ground level ("low" block).
; OUT
; - HL: Ptr to level layout
; -  A: Block ID
ActColi_GetBlockId_Low:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetYOffset -$08
	mActColi_GetBlockId_GetLevelLayoutPtr	; HL = Level layout ptr
	; Read the block ID
	; [BUG?] Doesn't remove actor flag unlike eveything else. Intentional?
	ld   a, [hl]								
	ret
	
; =============== ActColi_GetBlockId_LowR ===============
; Gets the block ID the actor is overlapping with on the right side.
; OUT
; - HL: Ptr to level layout
; -  A: Block ID	
ActColi_GetBlockId_LowR:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetXOffset +$08
	mActColi_GetBlockId_SetYOffset -$08
	mActColi_GetBlockId_GetLevelLayoutPtr
	; Read the block ID
	ld   a, [hl]
	and  a, $7F				; Remove MSB
	ret
	
; =============== ActColi_GetBlockId_LowR2 ===============
; Very slight variation of ActColi_GetBlockId_LowR -- the X target is 1px more to the right.
; OUT
; - HL: Ptr to level layout
; -  A: Block ID	
ActColi_GetBlockId_LowR2:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetXOffset +$09
	mActColi_GetBlockId_SetYOffset -$08
	mActColi_GetBlockId_GetLevelLayoutPtr
	; Read the block ID
	ld   a, [hl]
	and  a, $7F
	ret
	
; =============== ActColi_GetBlockId_LowL ===============
; Gets the block ID the actor is overlapping with on the left side.
; OUT
; - HL: Ptr to level layout
; -  A: Block ID	
ActColi_GetBlockId_LowL:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetXOffset -$08
	mActColi_GetBlockId_SetYOffset -$08
	mActColi_GetBlockId_GetLevelLayoutPtr
	; Read the block ID
	ld   a, [hl]
	and  a, $7F
	ret
	
; =============== ActColi_GetBlockId_LowL2 ===============
; Very slight variation of ActColi_GetBlockId_LowL -- the X target is 1px more to the left.
; OUT
; - HL: Ptr to level layout
; -  A: Block ID	
ActColi_GetBlockId_LowL2:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetXOffset -$09
	mActColi_GetBlockId_SetYOffset -$08
	mActColi_GetBlockId_GetLevelLayoutPtr
	; Read the block ID
	ld   a, [hl]
	and  a, $7F
	ret
	
; =============== ActColi_GetBlockId_BottomR ===============
; OUT
; - HL: Ptr to level layout
; -  A: Block ID	
ActColi_GetBlockId_BottomR:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetXOffset +$08
	mActColi_GetBlockId_SetYOffset +$08
	mActColi_GetBlockId_GetLevelLayoutPtr
	
	; [BUG?] No instakill check unlike everything that comes after. Is this intended?
	; Read the block ID
	ld   a, [hl]
	and  a, $7F
	ret
	
; =============== ActColi_GetBlockId_BottomL ===============
; OUT
; - HL: Ptr to level layout
; -  A: Block ID	
ActColi_GetBlockId_BottomL:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetXOffset -$08
	mActColi_GetBlockId_SetYOffset +$08
	mActColi_GetBlockId_GetLevelLayoutPtr
	
	; If actors are below the level, ignore the actual block and always return the instakill one.
	;
	; Since the player is automatically killed when going below the level,
	; it's only fair this happens to actors too.
	ld   a, h
	cp   a, HIGH(wLevelLayout_End)
	jr   nc, ActColi_GetInstaKillBlockId
	
	; Otherwise read the block ID we got
	ld   a, [hl]
	and  a, $7F
	ret
	
; =============== ActColi_GetBlockId_Ground ===============
; Direct position, with no offsets applied.
; This target matches with the pixel the actor is touching the ground, much like with the player.
; OUT
; - HL: Ptr to level layout
; -  A: Block ID
ActColi_GetBlockId_Ground:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_GetLevelLayoutPtr
	
	; Check for going past the level bottom border
	ld   a, h
	cp   a, HIGH(wLevelLayout_End)
	jr   nc, ActColi_GetInstaKillBlockId
	
	; Read the block ID
	ld   a, [hl]
	and  a, $7F
	ret
	
; =============== ActColi_GetInstaKillBlockId ===============
; The block ID returned when an actor is below the bottom border of a level.
; OUT
; -  A: Block ID
ActColi_GetInstaKillBlockId:
	ld   a, BLOCKID_INSTAKILL
	ret
	
; =============== ActColi_GetBlockId_Ground2 ===============
; Variation of ActColi_GetBlockId_Ground which checks 1px below.
; OUT
; - HL: Ptr to level layout
; -  A: Block ID
ActColi_GetBlockId_Ground2:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetYOffset +$01
	mActColi_GetBlockId_GetLevelLayoutPtr
	
	; Check for going past the level bottom border
	ld   a, h
	cp   a, HIGH(wLevelLayout_End)
	jr   nc, ActColi_GetInstaKillBlockId
	
	; Read the block ID
	ld   a, [hl]
	and  a, $7F
	ret
	
; =============== ActColi_GetBlockId_GroundHorz ===============
; Gets *two* block IDs based on the horizontal position the actor is currently standing on.
; Used for detecting ground collision with actors which are larger than one block.
; OUT
; - HL: Ptr to level layout (for C)
; -  B: Block ID on the left
; -  C: Block ID on the right
ActColi_GetBlockId_GroundHorz:
	;
	; LEFT BLOCK
	; 
	
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetXOffset -$08
	mActColi_GetBlockId_GetLevelLayoutPtr
	
	; Check for going past the level bottom border
	ld   a, h
	cp   a, HIGH(wLevelLayout_End)
	jr   nc, .instakill
	
	; B = Block ID (left)
	ld   a, [hl]
	and  a, $7F
	ld   b, a
	;--
	;
	; RIGHT BLOCK
	; 
	
	push bc ; Save B
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetXOffset +$08
	mActColi_GetBlockId_GetLevelLayoutPtr
	pop  bc
	;--
	
	; Useless check.
	; If the previous instakill check has passed, this one will always succeed as well!
	; This block has the same Y coord as the one we checked before, and the high byte (H) can only change with that.
	ld   a, h
	cp   a, HIGH(wLevelLayout_End)
	jr   nc, .instakill
	;--
	; C = Block ID (right)
	ld   a, [hl]
	and  a, $7F
	ld   c, a
	ret
.instakill:
	ld   bc, (BLOCKID_INSTAKILL<<8)|BLOCKID_INSTAKILL
	ret
	
; =============== ActColi_GetBlockId_Top ===============
; Reads a block ID far above ActColi_GetBlockId_Low.
; OUT
; - HL: Ptr to level layout
; -  A: Block ID
ActColi_GetBlockId_Top:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetYOffset -$14
	mActColi_GetBlockId_GetLevelLayoutPtr
	; Read the block ID
	ld   a, [hl]
	and  a, $7F
	ret
	
; =============== ActColi_GetBlockId_Top2 ===============
; [POI] Completely identical to ActColi_GetBlockId_Top... but why?
; OUT
; - HL: Ptr to level layout
; -  A: Block ID
ActColi_GetBlockId_Top2:
	mActColi_GetBlockId_GetPos
	mActColi_GetBlockId_SetYOffset -$14
	mActColi_GetBlockId_GetLevelLayoutPtr
	; Read the block ID
	ld   a, [hl]
	and  a, $7F
	ret
	
; =============== ActS_InitToSlot ===============
; Initializes all fields of the actor to the specified slot.
; This is *exclusively* meant to spawn actors after scrolling the screen,
; or when loading a new room.
; IN
; -  A: Slot number
ActS_InitToSlot:
	ld   [sActNumProc], a
	
	; Set the layout ptr for the actor data
	; HL = LayoutPtr
	ld   a, [sActLevelLayoutPtr_Low]
	ld   [sActSetLevelLayoutPtr], a
	ld   l, a
	ld   a, [sActLevelLayoutPtr_High]
	ld   [sActSetLevelLayoutPtr+1], a
	ld   h, a
	
	; Remove existing actor flag (otherwise permanent despawns won't work).
	;
	; [POI] This is the exact point the game can break everything when loading actors in out of range areas (with the scroll bug).
	;       In those cases, HL will point to an area around the beginning of ROM.
	;		Doing this with HL pointing there will disable SRAM, which is where the stack is.
	;
	;		Code that sets the actor flag (ie: ActS_SavePos) will cause the same problem too.
	;		The code ptrs are actually never broken because of how actor IDs are handled. 
	res  7, [hl]
	
	;--
	ld   [sSubCallTmpA], a	; Save A
	ld   a, [sROMBank]
	push af
	ld   a, $07				
	ld   [sROMBank], a
	ld   [MBC1RomBank2], a
	ld   a, [sSubCallTmpA]	; Restore A
	;;;
	call ActS_SetCodePtrFromGroup
	
	ldi  a, [hl]			; 2: Misc flags
	ld   [sActSetOpts], a
	
	ld   a, [hl]			; 3: Bank number for OBJLst (not used yet; since all actors are set the blank objlst)
	ld   b, a
	; Index the table by actor number
	ld   hl, sActOBJLstBank
	ld   a, [sActNumProc]	; DE = sActNumProc
	ld   d, $00
	ld   e, a
	add  hl, de
	ld   [hl], b			; Write the value
	
	;;;
	ld   [sSubCallTmpA], a
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank2], a
	ld   a, [sSubCallTmpA]
	;--
	
	;
	; Set the full 16-bit coordinate from the location in the level layout
	;
	; This is the opposite of what's done in Level_DrawFullScreen to get the level layout ptr 
	; from a coordinate, so the same rules apply.
	; As a result, we need to multiply the low (X) and high (Y) bytes by 16 and add an offset (optionally)
	; to make sure the actors spawn at the center of the block.
	;
	
	;--
	; X COORD
	; sActSetX = (sActLevelLayoutPtr_Low * 16) + $08
	
	; C = sActLevelLayoutPtr_Low
	ld   a, [sActLevelLayoutPtr_Low]	
	ld   c, a
	
	; sActSetX_Low = (C << 4) | $08
	and  a, $0F
	swap a
	or   a, $08				; +8 to spawn at the center of a 16x16 block
	ld   [sActSetX_Low], a
	
	; sActSetX_High = C >> 4
	ld   a, c
	and  a, $F0
	swap a
	ld   [sActSetX_High], a
	
	;--
	; Y COORD
	; sActSetY = (sActLevelLayoutPtr_High + 1) * 16
	
	; C = sActLevelLayoutPtr_High + 1
	ld   a, [sActLevelLayoutPtr_High]
	inc  a
	ld   c, a
	
	; sActSetY_Low = C << 4
	and  a, $0F
	swap a
	ld   [sActSetY_Low], a
	
	; sActSetY_High = (C & $30) >> 4
	ld   a, c
	and  a, $30 			; -$C0 to remove level layout address base (upper two bits)
	swap a
	ld   [sActSetY_High], a
	
	; Init vars & custom vars
	ld   a, $00
	ld   [sActSetRoutineId], a
	ld   [sActSetColiType], a
	xor  a
	ld   [sActSetTimer], a
	ld   [sActSetTimer2], a
	ld   [sActSetTimer3], a
	ld   [sActSetTimer4], a
	ld   [sActLocalRoutineId], a
	ld   [sActSetTimer6], a
	ld   [sActSetTimer7], a
	
	call ActS_CheckOffScreen
	mActS_SetBlankFrame
	
	; Choose the initial direction based on where the actor is located
	
	; Is it on the left half of the screen?
	ld   a, [sActSetRelX]
	add  $20					
	cp   a, $30+$20	; X range: $FFE0-$002F
	call c, ActS_SetRightDir	; If so, choose the left direction
	; Is it on the middle or right half of the screen?
	ld   a, [sActSetRelX]
	add  $20
	cp   a, $30+$20	; X >= $0030
	call nc, ActS_SetLeftDir	; If so, choose the right direction
	
	; [POI] When an actor is spawned by moving it on-screen, it's marked by
	;       this special value as "active status"... which is treated identically
	;       to status $02 (many checks for "visible & active" do >= $02).
	;       This gets overwritten almost immediately as soon as the game performs
	;       an off-screen check on the actor the next frame.
	ld   a, $03
	ld   [sActSetActive], a
	
	call ActS_CopyFromSet
	ret
; =============== ActS_Set***Dir ===============
; Sets the direction the currently processed actor moves to.
ActS_SetRightDir:
	ld   a, $01
	ld   [sActSetDir], a
	ret
ActS_SetLeftDir:
	ld   a, $02
	ld   [sActSetDir], a
	ret
; =============== ActS_SetCodePtrFromGroup ===============
; Sets the code pointer from the current ActGroupCode table.
; OUT
; - HL: Ptr to "flags" of the ActGroupCodeDef
;       This is the third byte.
ActS_SetCodePtrFromGroup:
	ld   a, [sActSetId]
	and  a, $0F					; Filter away no-respawn flag
	cp   a, ACT_DEFAULT_BASE	; Is this a default actor?
	jr   nc, .defaultAct		; If so, use the shared table
.normalAct:
	; Index the code ptr table
	add  a								; DE = ActorId * 2
	ld   e, a
	ld   d, $00
	ld   a, [sActGroupCodePtrTable]		; HL = sActGroupCodePtrTable
	ld   l, a
	ld   a, [sActGroupCodePtrTable+1]
	ld   h, a
	add  hl, de							; Offset the table
	; Read the ptr from the entry
	ldi  a, [hl]
	ld   e, a
	ld   h, [hl]
	ld   l, e
	
	; Which itself is another pointer
	; This one is the code ptr
	ldi  a, [hl]
	ld   [sActSetCodePtr], a
	ldi  a, [hl]
	ld   [sActSetCodePtr+1], a
	ret
.defaultAct:
	; All default actors run under the same actor code
	ld   hl, ActGroupCodeDef_Default
	ldi  a, [hl]
	ld   [sActSetCodePtr], a
	ldi  a, [hl]
	ld   [sActSetCodePtr+1], a
	ret
	
ActGroupCodeDef_Default:
	mActCodeDef SubCall_ActInit_Default, $20, $0F

SubCall_ActS_GetIdByLevelLayoutPtr:	mSubCallRet ActS_GetIdByLevelLayoutPtr ; BANK $02
; =============== ActS_CopyGFXFromList ===============
; This subroutine copies to VRAM all of the GFX data requested in the actor group.
; This is performed during room initialization.
; IN:
; - BC: Ptr to actor group GFX (table)
ActS_CopyGroupGFX:
	ld   h, b						; HL = Ptr to actor group GFX definition
	ld   l, c
	
	ld   a, $40						; Setup the max allowed tiles
	ld   [sActGFXMaxTileCount], a
	ld   de, vGFXActors				; Starting offset for actor GFX data
	
	; The index for the currently processed actor number in the group, only
	; used to index "starting tile" table for all actors in a group.
	
	; This starts from $02 since $00 is not used,
	; and the first actor $01 always starts with the first tile.
	; hence, this valur points to the next processed actor number.
	ld   a, $02			
	ld   [sActGFXActorNum], a
	xor  a
	ld   [sActGFXTileCopyCount], a
.loop:
	;
	; Read the (next) entry in the group definition
	;
	
	; Byte 0: Bank number
	ldi  a, [hl]		
	ld   [sActGFXBankNum], a
	
	; Byte 1-2: Ptr to GFX data
	ldi  a, [hl]		; Store it to BC
	ld   c, a
	ldi  a, [hl]
	ld   b, a
	
	; Byte 3: Tile count
	ldi  a, [hl]		
	ld   [sActGFXTileCount], a
	
	; Each table ends with a dummy $000000FF entry.
	cp   a, $FF			; Reached the end separator?
	jr   z, .end		; If so, we're done. Write the stun star GFX.
	
	or   a				; Does this actor have GFX data assigned?
	jr   z, .loop		; If not, skip to the next entry
	;--
	push hl
	ld   a, [sROMBank]
	push af
	ld   a, [sActGFXBankNum]	; Load the requested bank
	ld   [sROMBank], a
	ld   [MBC1RomBank2], a
	call ActS_CopyGFX			; Copy the GFX over
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank2], a
	pop  hl
	;--
	jr   .loop
.end:
	ld   hl, GFX_Act_StunStar	; HL = Ptr to GFX data
	ld   de, vGFXStunStar		; DE = Ptr to VRAM (fixed slot)
	ld   b, (GFX_Act_StunStar.end - GFX_Act_StunStar) ; B = GFX size ($10 bytes/1 tile)
.loopStarCopy:
	ldi  a, [hl]				; Copy over the byte
	ld   [de], a
	inc  de
	dec  b						; Are we done yet?
	jr   nz, .loopStarCopy		; If not, loop
	ret
; =============== ActS_CopyGFX ===============
; This subroutine copies the uncompressed GFX for a single actor, and
; marks the tile number the next actor should point at.
;
; A max of $40 tiles in total can be written with this.
; The main area the GFX are written to is $8D00-$8FFF ($30 tiles); 
; if that's full it overwrites the powerup GFX at $8A00-$8AFF ($10 tiles).
;
; IN
; - BC: Ptr to actor GFX
; - DE: Ptr to VRAM
ActS_CopyGFX:
	ld   l, c					; HL = Initial source GFX data	
	ld   h, b
	ld   a, [sActGFXTileCount]	; C = Tile count
	ld   c, a					
.copyNextTile:
	; Verify we haven't gone over the max tile count
	; [TCRF] This only happens if we went past $8AFF, which never happens
	ld   a, [sActGFXMaxTileCount]
	or   a
	jr   z, .end
	
	; Copy over a full tile
	ld   b, $10
.loop:
	ldi  a, [hl]
	ld   [de], a
	inc  de
	dec  b
	jr   nz, .loop
	
	; Have we reached the end of the main actor area?
	ld   a, d
	cp   a, HIGH(vGFXActors_End)
	jr   c, .checkEnd					; If not, skip
	
	; If so, overwrite the very end of the shared GFX block with the new tiles.
	; This area contains powerups, hearts and other items.
	; This is safe to do for bosses, where those GFX are never used.
	ld   de, vGFXActorsSec				
.checkEnd:
	ld   a, [sActGFXMaxTileCount]	; MaxTilesLeft--
	dec  a
	ld   [sActGFXMaxTileCount], a
	
	ld   a, [sActGFXTileCopyCount]	; TileDone++
	inc  a
	ld   [sActGFXTileCopyCount], a
	
	dec  c							; Have we copied all actor tiles?
	jr   nz, .copyNextTile			; If not, loop
.endStat:
	; Since GFX can be loaded in variable slots, 
	; we need to report something that tells where an actor should look for GFX data.
	
	ld   a, [sActGFXActorNum]		
	ld   b, $00						; BC = sActGFXActorNum
	ld   c, a
	inc  a							; ActorsDone++
	ld   [sActGFXActorNum], a	
	ld   hl, sActTileBaseTbl	
	add  hl, bc						; Index the actor->tilenum table
	ld   a, [sActGFXTileCopyCount]	; Store the first tile number for the next actor.
	ld   [hl], a
.end:
	ret
; =============== ActS_LoadAndWriteOBJLst ===============
; This subroutine prepares the call to ActS_WriteOBJLst, 
; setting up the neede actor data and OBJLst pointers.
ActS_LoadAndWriteOBJLst:
	; Perform a cut down version of ActS_CopyFromSet.
	; Cut down in the sense that we only copy the needed bytes for the OBJLst copy.
	
	; Get the ptr to the current actor slot
	ld   h, HIGH(sAct)
	ld   a, [sActNumProc] ; L = sActNumProc * $20
	and  a, $07
	swap a
	rlca
	ld   l, a 
	
	; Draw the sprite mapping only if it's visible on-screen
	ld   a, [hl]
	cp   a, $02
	ret  nz
	
	; Point to the rel coord
	ld   a, l
	add  $0A
	ld   l, a
	
	; Copy the needed values to the Set area
	ldi  a, [hl]
	ld   [sActSetRelY], a
	ldi  a, [hl]
	ld   [sActSetRelX], a
	ldi  a, [hl]
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ldi  a, [hl]
	ld   [sActSetOBJLstPtrTablePtr_High], a
	inc  hl
	ldi  a, [hl]
	ld   [sActSetOBJLstId], a
	ldd  a, [hl]
	ld   [sActSetId], a
	;--
	push hl
	
	; Pick the bank to load the OBJLst from, as set in the table
	ld   hl, sActOBJLstBank
	ld   a, [sActNumProc] ; DE = sActNumProc
	ld   d, $00
	ld   e, a
	add  hl, de				; Index the table
	ld   a, [hl]
	ld   d, a				; D = Bank number

	ld   [sSubCallTmpA], a	; Save A
	ld   a, [sROMBank]
	push af
	ld   a, d				; Switch the bank
	ld   [sROMBank], a
	ld   [MBC1RomBank2], a
	ld   a, [sSubCallTmpA]	; Restore A
	;@@
	
	; Index the OBJLst ptr table
	ld   a, [sActSetOBJLstPtrTablePtr_Low]		; DE = Ptr to OBJLst pointer table
	ld   e, a
	ld   a, [sActSetOBJLstPtrTablePtr_High]
	ld   d, a
	ld   a, [sActSetOBJLstId]				; HL = sActSetOBJLstId * 2
	add  a
	ld   l, a									
	ld   h, $00
	add  hl, de								; Offset the ptr table
	ld   c, [hl]							; BC = Ptr to OBJLst proper
	inc  hl
	ld   b, [hl]
	
	; Verify that the indexed OBJLst pointer isn't out of range / null.
	
	; Is the OBJLst pointer null?
	ld   a, b								
	or   a, c
	jr   z, .nullPtr ; If so, jump

	; If it isn't null, use the pointer as normal 
	ld   e, c		; DE = OBJLst Ptr
	ld   d, b
	jr   .writeOBJ
.nullPtr:
	; If it is, disregard the sActSetOBJLstId index and always use the first entry of the ptr table.
	; This is used in practice to loop animations.
	; OBJLst for actors always contain at least one null entry, which will trigger this anim frame reset.
	xor  a
	ld   [sActSetOBJLstId], a
	ld   h, d		; Restore sActSetOBJLstPtrTablePtr
	ld   l, e
	ld   e, [hl]	; DE = First OBJLst ptr of the table
	inc  hl
	ld   d, [hl]
.writeOBJ:
	call ActS_WriteOBJLst
	; Restore the original bank
	ld   [sSubCallTmpA], a
	pop  af
	ld   [sROMBank], a
	ld   [MBC1RomBank2], a
	ld   a, [sSubCallTmpA]
	
	pop  hl
	;--
	; This does... nothing! 
	; HL = sActSetOBJLstId when we get here.
	ld   a, [sActSetOBJLstId]
	ld   [hl], a
	ret
	
; =============== ActS_WriteOBJLst ===============
; Writes an entire OBJ list (sprite mappings) for the currently handled actor.
; Unlike other OAM writer subroutines, this is handled substantially differently and it's in a slightly different format.
; To save space each OBJ entry is 3 bytes large instead of the usual 4.
;
; The format for this is:
; 0: <global flags>
; 1: <OBJ#0 Rel. Y> X Position
; 2: <OBJ#0 Rel. X> Y Position
; 3: <OBJ#0 X>		Tile ID + Local flags (in one single byte)
; ...
; X: $80 end separator
; 
; The OBJLst for actors include an extra byte at the beginning, which specifies
; global flags *set* for all OBJ.
;
; Since actors can be potentially loaded at any location in VRAM, the OBJLst data
; for actors has "tile IDs" relative to the start of their GFX data.
; This frees up enough bits to store the local flags in the third byte.
;
; See also: WriteOBJLst
; 
; IN
; - DE: Ptr to OBJLst
ActS_WriteOBJLst:
	;--
	; Set the default tile offset for actors without a valid ID
	ld   a, $99
	ld   [sActTileBase], a
	
	; Determine the tile offset for written tiles.
	; Two tables need to be indexed for this.
	; The first table is (indexed by actor ID) contains the index for
	; the actual tile offset value table.
	
	; If the actor ID is out of range, ignore all of this and use the previously
	; set default tile base.
	ld   a, [sActSetId]
	and  a, $7F				; Filter away no-respawn flag
	cp   a, $07				; Is this a valid actor slot? (< $07)
	jr   nc, .setGlobal		; If not, jump (don't use an out of bounds index)
	
	; Index the first table
	ld   b, $00						; BC = sActSetId
	ld   c, a
	ld   hl, sActTileBaseIndexTbl	; HL = Table
	add  hl, bc						; Index it
	; BC = Index for the second table
	ld   a, [hl]					
	ld   b, $00
	ld   c, a
	
	; The second table contains the proper tile 
	ld   hl, sActTileBaseTbl
	add  hl, bc					; Index it
	ld   a, [hl]				; Get the tile offset
	add  $D0					; += $D0 (actor tile numbers start at this)
	ld   [sActTileBase], a
	;--
.setGlobal:
	ld   a, [sWorkOAMPos]
	cp   a, LOW(sWorkOAM_End)	; Have we gone past the end of the OAM mirror? (HL >= $AFA0)
	ret  nc						; If so, return.
	
	ld   l, a					; HL = Current WorkOAM location (destination)
	ld   h, HIGH(sWorkOAM)
	
.calcGlobalFlags:
	; Calculate the global flags to set on every OBJ tile.
	;
	; A = (DefaultGlobFlags v CustomGlobFlags) & $90
	ld   a, [de]			; B = Normal OBJ Flags
	inc  de
	ld   b, a
	
	ld   a, [sActFlags]		; Reverse the requested OAM flag bits
	xor  a, b
	and  a, $90				; ???
	ld   [sActFlagsRes], a	; Save this for later
	;--
	ld   a, [sActSetRelY] ; B = Base Y coord
	ld   b, a
	ld   a, [sActSetRelX] ; C = Base X coord
	ld   c, a
	
	;
	; OBJLst write loop
	;
.loop:
	;--
.writeY:
	; BYTE 0 -- Rel. Y
	ld   a, [de]			; A = Relative Y pos
	cp   a, $80				; Have we reached the end separator? (first byte of entry $80)
	ret  z					; If so, return
	
	inc  de					
	add  b					; Add the base Y position
	ldi  [hl], a
	;--
.writeX:
	; BYTE 1 -- Rel. X
	ld   a, [de]			; A = Relative X pos
	inc  de
	add  c				; Add the base X position
	ldi  [hl], a
	;--
.writeTileId:
	; BYTE 3 -- Tile ID
	push bc					; Save the base coords
	ld   a, [de]			; Keep the tile ID in the $40 tile range reserved to actors
	and  a, $3F
	ld   b, a
	
	; If the tile ID is > $30, we're using the extra $10 tiles.
	; These are only used in bosses, and aren't stored after the normal $30 tiles.
	cp   a, $30				
	jr   nc, .tileIdBoss
.tileIdNormal:
	ld   a, [sActTileBase]
	add  b
.setTileId:
	ldi  [hl], a
	;--

.writeLocalFlags:
	; BYTE 3 -- Local flags
	ld   a, [de]			; B = (LocalFlags & $C0 >> 1)
	inc  de
	and  a, $C0
	rrca
	ld   b, a
	ld   a, [sActFlagsRes]	; A = Custom global flags
	or   a, b				; *Merge* them together
	ldi  [hl], a
	pop  bc
	
	ld   a, l				; Advance the OAM offset
	ld   [sWorkOAMPos], a
	;--
	cp   a, LOW(sWorkOAM_End) ; Have we reached the end of OAM?
	jr   c, .loop			; If not, write the next tile
	ret
.tileIdBoss:
	; The extra $10 tile IDs do not support a custom sActTileBase.
	add  $70		; Starting tile ID of boss-only actor tiles (which overwrite common actor GFX)
	jr   .setTileId
	
SubCall_ActHeldOrThrownActColi_Do: mSubCallRet ActHeldOrThrownActColi_Do ; BANK $02
SubCall_Level_LoadActLayout: mSubCallRet Level_LoadActLayout ; BANK $07
	ret

; =============== Empty OBJLst ===============
; This is the default "empty" OBJLst, which is the default OBJ representation of an actor.
OBJLst_Act_None: db $00,$80
OBJLstPtrTable_Act_None: 
	dw OBJLst_Act_None
	dw $0000
; As well as the shared table. None of the entries are used directly.
OBJLstSharedPtrTable_Act_None:
	dw OBJLstPtrTable_Act_None;X
	dw OBJLstPtrTable_Act_None;X
	dw OBJLstPtrTable_Act_None;X
	dw OBJLstPtrTable_Act_None;X
	dw OBJLstPtrTable_Act_None;X
	dw OBJLstPtrTable_Act_None;X
	dw OBJLstPtrTable_Act_None;X
	dw OBJLstPtrTable_Act_None;X
	
; ==============================	
SubCall_ActS_OnPlColiH: mSubCallRet ActS_OnPlColiH ; BANK $02
SubCall_ActS_OnPlColiTop: mSubCallRet ActS_OnPlColiTop ; BANK $02
SubCall_ActS_StartStarKill: mSubCallRet ActS_StartStarKill ; BANK $02
SubCall_ActS_StartStarKill_NoHeart: mSubCallRet ActS_StartStarKill_NoHeart ; BANK $02
SubCall_ActS_OnPlColiBelow: mSubCallRet ActS_OnPlColiBelow ; BANK $02
SubCall_ActS_StartDashKill: mSubCallRet ActS_StartDashKill ; BANK $02
SubCall_ActS_StartSwitchDir: mSubCallRet ActS_StartSwitchDir ; BANK $02
SubCall_ActS_StartJumpDeadSameColi: mSubCallRet ActS_StartJumpDeadSameColi ; BANK $02
SubCall_ActS_StartJumpDead: mSubCallRet ActS_StartJumpDead ; BANK $02
SubCall_ActS_StartJumpDead_NoHeart: mSubCallRet ActS_StartJumpDead_NoHeart ; BANK $02
SubCall_ActS_StartGroundPoundStun: mSubCallRet ActS_StartGroundPoundStun ; BANK $02
; [TCRF] Unreferenced SubCalls to otherwise used code (though the first one bypassed the collision change)
SubCall_Unused_ActS_StartGroundPoundStun_NoChgColi mSubCallRet ActS_StartGroundPoundStun_NoChgColi ; BANK $02
SubCall_Unused_ActS_StartStun:  mSubCallRet ActS_StartStun ; BANK $02
SubCall_ActInitS_StunFloatingPlatform: mSubCallRet ActInitS_StunFloatingPlatform ; BANK $02 
SubCall_ActS_StartHeld: mSubCallRet ActS_StartHeld ; BANK $02 
SubCall_ActS_StartHeldForce: mSubCallRet ActS_StartHeldForce ; BANK $02 
SubCall_ActS_DoStartJumpDead: mSubCallRet ActS_DoStartJumpDead ; BANK $02 
SubCall_ActS_PlStand_MoveLeft: mSubCallRet ActS_PlStand_MoveLeft ; BANK $02 
SubCall_ActS_PlStand_MoveRight: mSubCallRet ActS_PlStand_MoveRight ; BANK $02 
SubCall_PlBGColi_DoTopAndMove: mSubCallRet PlBGColi_DoTopAndMove ; BANK $01 
SubCall_PlBGColi_CheckGroundSolidOrMove: mSubCallRet PlBGColi_CheckGroundSolidOrMove ; BANK $01
SubCall_ActColi_SetForDefault: mSubCallRet ActColi_SetForDefault ; BANK $0F
; =============== ActS_PlStand_MoveLeft_NoScroll ===============
; Tries to move the player left, while also handling collision detection.
; This should be used when being moved by an actor, since while standing
; this kind of collision detection isn't performed.
;
; NOTE: This is specifically meant for autoscrolling mode, since it does not
;		scroll the screen like the normal ActS_PlStand_MoveRight.
;
; IN
; - B: Pixels of movement
ActS_PlStand_MoveLeft_NoScroll:
	;--
	ld   c, b
	call PlBGColi_DoLeft	; Check for collision on the left
	cp   a, COLI_SOLID		; Is there a solid block?
	ret  z					; If so, return
	ld   b, c
	;--
	; Why is this a subcall?
	ld   d, $01
	ld   hl, Pl_MoveLeft	; Otherwise, move the player left
	call SubCall
	ret
	
; =============== ActS_PlStand_MoveRight_NoScroll ===============
; Tries to move the player right, while also handling collision detection.
; This should be used when being moved by an actor, since while standing
; this kind of collision detection isn't performed.
;
; NOTE: This is specifically meant for autoscrolling mode, since it does not
;		scroll the screen like the normal.
;
; IN
; - B: Pixels of movement
ActS_PlStand_MoveRight_NoScroll:
	;--
	ld   c, b
	call PlBGColi_DoRight	; Check for collision on the right
	cp   a, $01				; Is there a solid block?
	ret  z					; If so, return
	ld   b, c
	;--
	; Why is this a subcall?
	ld   d, $01
	ld   hl, Pl_MoveRight	; Otherwise, move the player right
	call SubCall
	ret
	
; =============== ActS_Unused_PlStand_MoveUp_NoScroll ===============
; Tries to move the player up, while also handling collision detection.
; This should be used when being moved by an actor, since while standing
; this kind of collision detection isn't performed.
;
; [TCRF] Unreferenced subroutine, but it's structured and stored right 
;        after ActS_PlStand_MoveRight_NoScroll, so it can be assumed 
;        this was for a similar purpose.
;
; IN
; - B: Pixels of movement
ActS_Unused_PlStand_MoveUp_NoScroll:
	;--
	ld   c, b
	call PlBGColi_DoTop		; Check for collision on the top
	ld   b, c
	;--
	cp   a, $01				; Is there a solid block?
	ret  z					; If so, return
	; Why is this a subcall?
	ld   d, $01
	ld   hl, Pl_MoveUp		; Otherwise, move the player up 1px
	call SubCall
	ret 
; =============== Pl_Unused_MoveDown_NoScroll ===============
; [TCRF] Unreferenced subroutine.
; This is the last direction in the set of ActS_PlStand_Move*_NoScroll
; ...but it apppears to be incomplete.
; There's no collision check done -- it always moves the player down.
Pl_Unused_MoveDown_NoScroll:  
	ld   d, $01				; move the player down 1px
	ld   hl, Pl_MoveDown
	call SubCall
	ret 
	
SubCall_ActS_SpawnBigCoin: mSubCallRet ActS_SpawnBigCoin ; BANK $0F
SubCall_ActInit_BigCoin: mSubCallRet ActInit_BigCoin ; BANK $0F
SubCall_Act_BigCoin: mSubCallRet Act_BigCoin ; BANK $0F
SubCall_ActS_SpawnStunStar: mSubCallRet ActS_SpawnStunStar ; BANK $0F
SubCall_Act_StunStar: mSubCallRet Act_StunStar ; BANK $0F
SubCall_ActS_SpawnHeartInvincible: mSubCallRet ActS_SpawnHeartInvincible ; BANK $0F
SubCall_Act_HeartInvincible: mSubCallRet Act_HeartInvincible ; BANK $0F
SubCall_ActInit_BigHeart: mSubCallRet ActInit_BigHeart ; BANK $0F
SubCall_ActS_SpawnBigHeart: mSubCallRet ActS_SpawnBigHeart ; BANK $0F
SubCall_ActS_HeartGame: mSubCallRet ActS_HeartGame ; BANK $0F
SubCall_Act_BigHeart: mSubCallRet Act_BigHeart ; BANK $0F
SubCall_ActInit_Checkpoint: mSubCallRet ActInit_Checkpoint ; BANK $0F
SubCall_Act_Checkpoint: mSubCallRet Act_Checkpoint ; BANK $0F
SubCall_ActInit_TreasureChestLid: mSubCallRet ActInit_TreasureChestLid ; BANK $0F
SubCall_Act_TreasureChestLid: mSubCallRet Act_TreasureChestLid ; BANK $0F
SubCall_ActInit_TorchFlame: mSubCallRet ActInit_TorchFlame ; BANK $0F
SubCall_Act_TorchFlame: mSubCallRet Act_TorchFlame ; BANK $0F
SubCall_ActInit_Treasure: mSubCallRet ActInit_Treasure ; BANK $0F
SubCall_Act_Treasure: mSubCallRet Act_Treasure ; BANK $0F
SubCall_ActInit_TreasureShine: mSubCallRet ActInit_TreasureShine ; BANK $0F
SubCall_Act_TreasureShine: mSubCallRet Act_TreasureShine ; BANK $0F
SubCall_ActS_Held: mSubCallRet ActS_Held ; BANK $02
SubCall_ActS_Throw: mSubCallRet ActS_Throw ; BANK $02
SubCall_ActS_ThrowDelay3C: mSubCallRet ActS_ThrowDelay3C ; BANK $02
SubCall_ActS_DashKill: mSubCallRet ActS_DashKill ; BANK $02
SubCall_ActS_BumpSoft: mSubCallRet ActS_BumpSoft ; BANK $02
SubCall_ActS_StunBumpNorm: mSubCallRet ActS_StunBumpNorm ; BANK $02
SubCall_ActS_StunBumpFar: mSubCallRet ActS_StunBumpFar ; BANK $02
SubCall_ActS_StunGroundMove: mSubCallRet ActS_StunGroundMove ; BANK $02
SubCall_ActS_DoJumpDead1: mSubCallRet ActS_DoJumpDead1 ; BANK $02
SubCall_ActS_DoJumpDead2: mSubCallRet ActS_DoJumpDead2 ; BANK $02
SubCall_ActS_Unused_DoJumpDead3: mSubCallRet ActS_Unused_DoJumpDead3 ; BANK $02
SubCall_ActS_StunBump: mSubCallRet ActS_StunBump ; BANK $02
SubCall_ActS_StarKill: mSubCallRet ActS_StarKill ; BANK $02
SubCall_ActS_DoGroundPoundStun: mSubCallRet ActS_DoGroundPoundStun ; BANK $02
SubCall_ActS_Stun: mSubCallRet ActS_Stun ; BANK $02
SubCall_ActS_StunDefault: mSubCallRet ActS_StunDefault ; BANK $02
SubCall_ActS_SwitchDir: mSubCallRet ActS_SwitchDir ; BANK $02
; =============== SubCall_ActS_Unused_StunFloatingMovingPlatform ===============
; [TCRF] Unused SubCall only used in unreferenced code, pointing to unused code.
SubCall_ActS_Unused_StunFloatingMovingPlatform: mSubCallRet ActS_Unused_StunFloatingMovingPlatform ; BANK $02
SubCall_ActS_DoStunRecover: mSubCallRet ActS_DoStunRecover ; BANK $02
SubCall_ActS_StunFloatingPlatform: mSubCallRet ActS_StunFloatingPlatform ; BANK $02
SubCall_Act_ItemGround: mSubCallRet Act_ItemGround ; BANK $0F
SubCall_ActInit_Default: mSubCallRet ActInit_Default ; BANK $0F
SubCall_Act_ItemInBox: mSubCallRet Act_ItemInBox ; BANK $0F
SubCall_ActS_DefaultStand: mSubCallRet ActS_DefaultStand ; BANK $0F
SubCall_Act_Coin: mSubCallRet Act_Coin ; BANK $0F
SubCall_Act_CoinGame_Coin: mSubCallRet Act_CoinGame_Coin ; BANK $0F
SubCall_ActS_SpawnCoinFromDash: mSubCallRet ActS_SpawnCoinFromDash ; BANK $0F
SubCall_ActS_Spawn10Coin: mSubCallRet ActS_Spawn10Coin ; BANK $0F
SubCall_ActS_CoinGame: mSubCallRet ActS_CoinGame ; BANK $0F
SubCall_ActS_Spawn10CoinHeld: mSubCallRet ActS_Spawn10CoinHeld ; BANK $0F
SubCall_ActS_SpawnKeyHeld: mSubCallRet ActS_SpawnKeyHeld ; BANK $0F
SubCall_ActS_SpawnCoinFromBlock: mSubCallRet ActS_SpawnCoinFromBlock ; BANK $0F
SubCall_ActS_SpawnBridge: mSubCallRet ActS_SpawnBridge ; BANK $18
; =============== ActS_SetIndexedOBJLstPtrTable ===============
; Sets a new OBJLstPtrTable for the currently processed actor.
; 
; How it works:
; Each actor has a table of pointers to *other* OBJLstPtrTable.
; After indexing this shared table (with BC), the pointer is read and stored to the actor slot,
; replacing the current OBJLstPtrTable.
;
; This shared table system exists since the game uses different OBJLstPtrTable depending on the different actions.
; To know which to apply for certain shared actions (like the death anim), using an indexed table makes
; it easy since all that's necessary is to have the entries in a specific order.
;
; The default offsets used are defined in the constants ACTOLP_*,
; but an actor may use custom values.
; These custom values have indexes past the normal value.
;
; IN
; - BC: Offset to this shared table (must be always even)
ActS_SetIndexedOBJLstPtrTable:
	;--
	; Switch to the bank the current actor's OBJLst is stored.
	
	; Get the bank number from the table
	ld   hl, sActOBJLstBank		; HL = sActOBJLstBank
	ld   a, [sActNumProc]		; DE = sActNumProc
	ld   d, $00
	ld   e, a
	add  hl, de					; Index the table
	ld   a, [hl]				; D = Bank number
	ld   d, a
	
	;--
	ld   [sSubCallTmpA], a		; Save A
	ld   a, [sROMBank]			; A = Current bank num
	;##
	push af						; Save bank num
	ld   a, d					; Switch to bank the OBJLst is in
	ld   [sROMBank], a
	ld   [MBC1RomBank2], a
	ld   a, [sSubCallTmpA]		; Restore A
	;--
	
	;--
	; Set the new OBJLst ptr.
	
	; sActSetOBJLstSharedTablePtr points to a table of pointers to *other* OBJLstPtrTbl.
	; BC has the index to this shared table.	
	ld   a, [sActSetOBJLstSharedTablePtr]		; HL = Ptr to secondary OBJLst (for death/stun?)
	ld   l, a
	ld   a, [sActSetOBJLstSharedTablePtr+1]
	ld   h, a
	add  hl, bc								; Offset it with BC
	; Set the indexed pointer as OBJLstPtrTable.
	ldi  a, [hl]
	ld   [sActSetOBJLstPtrTablePtr_Low], a
	ld   a, [hl]
	ld   [sActSetOBJLstPtrTablePtr_High], a
	; Reset the OBJLstId 
	xor  a
	ld   [sActSetOBJLstId], a
	; Restore the previous values
	ld   [sSubCallTmpA], a
	pop  af						; A = Previous bank number
	;##
	ld   [sROMBank], a			; Restore it
	ld   [MBC1RomBank2], a
	ld   a, [sSubCallTmpA]		; Restore value in A
	ret
	
; =============== ActS_FallDownMax4SpeedChkSolid ===============	
; This subroutine moves the actor at an increasing downwards speed peaking at 4px/frame.
; If the actor lands on a solid block, it stops falling.
; 
; See also: ActS_FallDownMax4Speed
ActS_FallDownMax4SpeedChkSolid:
	ld   a, [sActSetYSpeed_High]	
	bit  7, a							; Speed < 0?
	jr   nz, ActS_FallDownMax4Speed		; If so, skip
	
	; Otherwise, check if the actor landed on a solid block.
	call ActColi_GetBlockId_Ground
	mSubCall ActBGColi_IsSolidOnTop		
	or   a								; Is it on one?
	ret  nz								; If so, don't fall down
	
; =============== ActS_FallDownMax4Speed ===============
; This subroutine moves the actor at an increasing downwards speed peaking at 4px/frame.
;
; How this works is by always moving the actor down by a certain amount.
; This "certain amount" is part of the actor slot info and increases over time.
;
; Because the jump should first move the actor upwards, the starting value is generally negative.
; The negative to positive speed increase also makes for a smooth jump arc.
ActS_FallDownMax4Speed:
	; Move actor vertically as specified in sActSetYSpeed_Low
	; This can be either a negative (upwards move) or positive (downwards move) value.
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed_Low
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown
	
	; Every 4 frames increase the sActSetYSpeed value
	ld   a, [sActSetTimer]
	and  a, $03
	ret  nz
	
	; Increase the speed until it reaches 4px/frame.
	ld   a, [sActSetYSpeed_High]
	bit  7, a							; Is the speed negative?
	jr   nz, .incSpeed					; If so, ignore the limit
	
	ld   a, [sActSetYSpeed_Low]
	cp   a, $04							; Is it > 4px/frame
	ret  nc								; If so, return
.incSpeed:
	; Otherwise, sActSetYSpeed++
	ld   a, [sActSetYSpeed_Low]
	add  $01							
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00
	ld   [sActSetYSpeed_High], a
	ret
; =============== ActS_FallDownEvery8 ===============
; This subroutine moves the actor at an increasing downwards speed.
ActS_FallDownEvery8:
	; Move actor vertically as specified in sActSetYSpeed_Low
	; This can be either a negative (upwards move) or positive (downwards move) value.
	ld   a, [sActSetYSpeed_Low]		; BC = sActSetYSpeed_Low
	ld   c, a
	ld   a, [sActSetYSpeed_High]
	ld   b, a
	call ActS_MoveDown					; Move down by that
	
.incSpeed:
	; Increase the speed every 8 frames, with no upper bound.
	ld   a, [sActSetTimer]
	and  a, $07
	ret  nz
	; Otherwise, sActSetYSpeed++
	ld   a, [sActSetYSpeed_Low]
	add  $01
	ld   [sActSetYSpeed_Low], a
	ld   a, [sActSetYSpeed_High]
	adc  a, $00
	ld   [sActSetYSpeed_High], a
	ret
; =============== ActS_MoveRight1 ===============	
; Moves the current actor's absolute position to the right by 1px.
ActS_MoveRight1:
	ld   bc, $01
	call ActS_MoveRight
	ret
; =============== ActS_MoveLeft1 ===============	
; Moves the current actor's absolute position to the left by 1px.
ActS_MoveLeft1:
	ld   bc, -$01
	call ActS_MoveRight
	ret
	
; ==============================
; RLE Decompression section
;
; This game compresses tilemaps and a few graphics using RLE.
; There are slight variations between GFX and Tilemap compression but generally:

; ==============================
	
; =============== DecompressBG ===============
; Decompresses tilemaps for static screens.
; A simplified version of the GFX decompressor, since the data is not interleaved.
;
; IN
; - HL: Ptr to compressed tilemap
; - BC: Ptr to destination
DecompressBG:
	ldi  a, [hl]			; Get the command byte
	or   a					; Is this the $00 end separator?
	ret  z					; If so, we're done
	bit  7, a				; MSB determines how to handle this command byte
	jr   nz, .noRepeat
;
; MSB CLEAR - Copy next byte D times
;
	ld   d, a				; D = Times to copy the next byte
	ldi  a, [hl]
	ld   e, a				; E = Byte to copy
.repeatCopy:
	ld   a, e				; Simple standard copy
	ld   [bc], a
	inc  bc
	dec  d					; Are we done?
	jr   nz, .repeatCopy	; If not, loop
	jr   DecompressBG

;
; MSB SET - Treat next D bytes as raw data
;
.noRepeat:
	and  a, $7F				; Clear MSB
	ld   d, a				; D = Bytes to copy directly
.copyNextByte:
	ldi  a, [hl]			; Direct copy
	ld   [bc], a
	inc  bc
	dec  d					; Are we done?
	jr   nz, .copyNextByte	; If not, loop
	jr   DecompressBG
	
; =============== DecompressGFX ===============
; Decompresses an *entire VRAM block* of RLE compressed graphics.
; Almost everything non-gameplay side (ie: map screen, endings, ...) uses this to decompress its graphics.
;
; The compressed data is interleaved (all high bytes are stored first, then low bytes) to have an higher compression ratio. 
; This is what accounts for the changes compared to the tilemap decompression 
; as it starts at $8000, waits for $9800, then restart at $8001 and ends when it crosses $9800 again.
; To cut down on padding data, the end of the compressed graphics is marked by a '00' separator.
;
; When fetching a command byte (noted here as $CNT):
; - if it's $00, we reached the end
; - if the MSB is set, copy directly the next $CNT values
; - if the MSB is clear, copy the next byte $CNT times
;
; IN
; - HL: Ptr to compressed graphics
DecompressGFX:
	ld   bc, Tiles_Begin
.nextCmd:
	; Determine the decompression command
	ldi  a, [hl]			; Get the decompression command
	or   a					; Is it the end separator ($00)?
	ret  z					; If so, return
	
	bit  7, a				; Is the MSB set?
	jr   nz, .noRepeat		; If so, treat the next bytes as raw data
	
;
; MSB CLEAR - Copy next byte D times
;
.withRepeat:				
	ld   d, a				; D = Amount of times to copy
	ldi  a, [hl]
	ld   e, a				; E = Byte to copy
.repeatCopy:
	ld   a, e				; Copy over the interleaved GFX data
	ld   [bc], a
	inc  bc
	inc  bc
	
	; Check for start/end
	ld   a, b
	cp   a, HIGH(Tiles_End)	; Have we reached the end of the tile data? (BC = $98**)
	jr   nz, .nextByte		; If not, skip the 2nd pass check
	
	ld   a, c				; Determine which decomp pass we're on. On the first pass it ends exactly at $9800.
	cp   a, LOW(Tiles_End)	; Have we reached exactly $9800?
	ret  nz					; If not, we've finished the second pass and we're done
	ld   bc, Tiles_Begin+1	; Otherwise, start the second pass
	
.nextByte:
	dec  d					; Is the repeated copy done?
	jr   nz, .repeatCopy	; If not, re-copy the byte again
	jr   .nextCmd
	
;
; MSB SET - Treat next D bytes as raw data
;
.noRepeat:
	and  a, $7F				; Clear MSB
	ld   d, a				; D = Bytes to copy over
.copyNextByte:
	; Interleave copy the byte, then move to the next
	ldi  a, [hl]			
	ld   [bc], a
	inc  bc
	inc  bc
	
	; Check if we've crossed the end of the VRAM tile data
	ld   a, b
	cp   a, HIGH(Tiles_End)
	jr   nz, .nextByte2		; If we haven't, jump
	; Check for end of second pass
	ld   a, c
	cp   a, LOW(Tiles_End)	; The pass we've finished was the second?
	ret  nz					; If so, we're done
	ld   bc, Tiles_Begin+1	; Otherwise start again with odd bytes
.nextByte2:
	dec  d					; Is the raw chunk copy done?
	jr   nz, .copyNextByte	; If not, copy the next byte
	jr   .nextCmd
	
; =============== CopyGFX_MultiFrame ===============
; Copies GFX data to VRAM spanning the entire level GFX area, one tile at a time,
; skipping over the area containing the status bar GFX.
;
; This meant to be used only when the display isn't disabled,
; which is only the case when copying the Genie's graphics for the final boss.
;
; IN
; - sCopyGFXSourcePtr: Source pointer. Should be set before the main loop.
; - sCopyGFXDestPtr: Destination pointer. Should be set before the main loop.
; OUT
; - A: If 0, the copy operation finished.
CopyGFX_MultiFrame:
	; Read the current source/destination pointers we've reached last time.
	ld   a, [sCopyGFXDestPtr_Low]
	ld   c, a
	ld   a, [sCopyGFXDestPtr_High]
	ld   b, a
	ld   a, [sCopyGFXSourcePtr_Low]
	ld   l, a
	ld   a, [sCopyGFXSourcePtr_High]
	ld   h, a
	;--
	; Copy over one tile
	ld   d, TILESIZE	; D = Bytes to copy
.loop:
	ldi  a, [hl]		; HL to BC
	ld   [bc], a
	inc  bc
	dec  d				; Are we done?
	jr   nz, .loop		; If not, loop
	;--
	
	; Don't overwrite the status bar GFX
	ld   a, b
	cp   a, HIGH(vGFXStatusBar)	; Is the VRAM ptr pointing to the status bar GFX?
	call z, .skipStatusBar		; If so, skip ahead
	
	; If we reached the end of the GFX area in VRAM, stop copying
	ld   a, b
	cp   a, HIGH(Tiles_End)		; Reached the end?
	jr   nz, .savePtr			; If not, jump
.end:
	;--
	; [POI] It isn't necessary to check for the low byte.
	;       When we get here, we're always pointing to $9800
	ld   a, c
	cp   a, LOW(Tiles_End)
	ret  z
	;--
.savePtr:
	; Save back the updated pointers
	ld   a, c								
	ld   [sCopyGFXDestPtr_Low], a
	ld   a, b
	ld   [sCopyGFXDestPtr_High], a
	ld   a, l										
	ld   [sCopyGFXSourcePtr_Low], a
	ld   a, h
	ld   [sCopyGFXSourcePtr_High], a
	ld   a, $01
	ret
.skipStatusBar:
	ld   bc, vGFXStatusBar_End
	ret
	
; =============== END OF BANK ===============
L003BF3: db $04;X
L003BF4: db $79;X
L003BF5: db $FE;X
L003BF6: db $00;X
L003BF7: db $C8;X
L003BF8: db $79;X
L003BF9: db $EA;X
L003BFA: db $95;X
L003BFB: db $A3;X
L003BFC: db $78;X
L003BFD: db $EA;X
L003BFE: db $96;X
L003BFF: db $A3;X
L003C00: db $7D;X
L003C01: db $EA;X
L003C02: db $97;X
L003C03: db $A3;X
L003C04: db $7C;X
L003C05: db $EA;X
L003C06: db $98;X
L003C07: db $A3;X
L003C08: db $3E;X
L003C09: db $01;X
L003C0A: db $C9;X
L003C0B: db $01;X
L003C0C: db $00;X
L003C0D: db $8D;X
L003C0E: db $C9;X
L003C0F: db $A8;X
L003C10: db $A2;X
L003C11: db $22;X
L003C12: db $88;X
L003C13: db $82;X
L003C14: db $2A;X
L003C15: db $A8;X
L003C16: db $08;X
L003C17: db $AA;X
L003C18: db $AA;X
L003C19: db $AA;X
L003C1A: db $AA;X
L003C1B: db $80;X
L003C1C: db $A2;X
L003C1D: db $8A;X
L003C1E: db $2A;X
L003C1F: db $88;X
L003C20: db $A2;X
L003C21: db $8A;X
L003C22: db $A0;X
L003C23: db $AA;X
L003C24: db $82;X
L003C25: db $80;X
L003C26: db $2A;X
L003C27: db $AA;X
L003C28: db $8A;X
L003C29: db $A8;X
L003C2A: db $AA;X
L003C2B: db $8A;X
L003C2C: db $A8;X
L003C2D: db $20;X
L003C2E: db $20;X
L003C2F: db $82;X
L003C30: db $A8;X
L003C31: db $AA;X
L003C32: db $A0;X
L003C33: db $28;X
L003C34: db $A8;X
L003C35: db $AA;X
L003C36: db $8A;X
L003C37: db $AA;X
L003C38: db $AA;X
L003C39: db $A2;X
L003C3A: db $02;X
L003C3B: db $A8;X
L003C3C: db $A8;X
L003C3D: db $AA;X
L003C3E: db $2A;X
L003C3F: db $8A;X
L003C40: db $2A;X
L003C41: db $20;X
L003C42: db $AA;X
L003C43: db $A8;X
L003C44: db $82;X
L003C45: db $AA;X
L003C46: db $A2;X
L003C47: db $2A;X
L003C48: db $28;X
L003C49: db $8A;X
L003C4A: db $8A;X
L003C4B: db $80;X
L003C4C: db $AA;X
L003C4D: db $80;X
L003C4E: db $A0;X
L003C4F: db $AA;X
L003C50: db $A8;X
L003C51: db $AA;X
L003C52: db $2A;X
L003C53: db $AA;X
L003C54: db $AA;X
L003C55: db $0A;X
L003C56: db $8A;X
L003C57: db $2A;X
L003C58: db $22;X
L003C59: db $0A;X
L003C5A: db $AA;X
L003C5B: db $20;X
L003C5C: db $22;X
L003C5D: db $AA;X
L003C5E: db $AA;X
L003C5F: db $08;X
L003C60: db $82;X
L003C61: db $A2;X
L003C62: db $8A;X
L003C63: db $88;X
L003C64: db $A2;X
L003C65: db $82;X
L003C66: db $A8;X
L003C67: db $A2;X
L003C68: db $AA;X
L003C69: db $8A;X
L003C6A: db $8A;X
L003C6B: db $A8;X
L003C6C: db $88;X
L003C6D: db $08;X
L003C6E: db $28;X
L003C6F: db $02;X
L003C70: db $A0;X
L003C71: db $A2;X
L003C72: db $8A;X
L003C73: db $A2;X
L003C74: db $88;X
L003C75: db $28;X
L003C76: db $AA;X
L003C77: db $2A;X
L003C78: db $2A;X
L003C79: db $AA;X
L003C7A: db $AA;X
L003C7B: db $82;X
L003C7C: db $2A;X
L003C7D: db $AA;X
L003C7E: db $22;X
L003C7F: db $A8;X
L003C80: db $AA;X
L003C81: db $EE;X
L003C82: db $EA;X
L003C83: db $FA;X
L003C84: db $AA;X
L003C85: db $EE;X
L003C86: db $AB;X
L003C87: db $AA;X
L003C88: db $AA;X
L003C89: db $AA;X
L003C8A: db $AE;X
L003C8B: db $AA;X
L003C8C: db $BA;X
L003C8D: db $AA;X
L003C8E: db $AE;X
L003C8F: db $AA;X
L003C90: db $AA;X
L003C91: db $EA;X
L003C92: db $AA;X
L003C93: db $AE;X
L003C94: db $AE;X
L003C95: db $FA;X
L003C96: db $EA;X
L003C97: db $AA;X
L003C98: db $AE;X
L003C99: db $AA;X
L003C9A: db $AA;X
L003C9B: db $AA;X
L003C9C: db $AA;X
L003C9D: db $AA;X
L003C9E: db $AA;X
L003C9F: db $AE;X
L003CA0: db $AA;X
L003CA1: db $AA;X
L003CA2: db $AA;X
L003CA3: db $AA;X
L003CA4: db $AA;X
L003CA5: db $AA;X
L003CA6: db $EA;X
L003CA7: db $AE;X
L003CA8: db $AA;X
L003CA9: db $EA;X
L003CAA: db $AE;X
L003CAB: db $BA;X
L003CAC: db $AA;X
L003CAD: db $EA;X
L003CAE: db $EA;X
L003CAF: db $AA;X
L003CB0: db $AE;X
L003CB1: db $EA;X
L003CB2: db $AA;X
L003CB3: db $AA;X
L003CB4: db $EA;X
L003CB5: db $AE;X
L003CB6: db $AA;X
L003CB7: db $EA;X
L003CB8: db $EE;X
L003CB9: db $AA;X
L003CBA: db $EA;X
L003CBB: db $EE;X
L003CBC: db $AA;X
L003CBD: db $AA;X
L003CBE: db $AE;X
L003CBF: db $EA;X
L003CC0: db $BA;X
L003CC1: db $BE;X
L003CC2: db $AE;X
L003CC3: db $AA;X
L003CC4: db $AA;X
L003CC5: db $AA;X
L003CC6: db $AA;X
L003CC7: db $EA;X
L003CC8: db $AA;X
L003CC9: db $EA;X
L003CCA: db $AA;X
L003CCB: db $AA;X
L003CCC: db $EA;X
L003CCD: db $AA;X
L003CCE: db $E2;X
L003CCF: db $AB;X
L003CD0: db $EA;X
L003CD1: db $AA;X
L003CD2: db $AA;X
L003CD3: db $EA;X
L003CD4: db $AE;X
L003CD5: db $AA;X
L003CD6: db $AA;X
L003CD7: db $AA;X
L003CD8: db $AA;X
L003CD9: db $BA;X
L003CDA: db $EA;X
L003CDB: db $AA;X
L003CDC: db $AB;X
L003CDD: db $AA;X
L003CDE: db $AB;X
L003CDF: db $EA;X
L003CE0: db $AE;X
L003CE1: db $AE;X
L003CE2: db $AA;X
L003CE3: db $EA;X
L003CE4: db $AE;X
L003CE5: db $EE;X
L003CE6: db $AB;X
L003CE7: db $AE;X
L003CE8: db $AE;X
L003CE9: db $AA;X
L003CEA: db $AA;X
L003CEB: db $AA;X
L003CEC: db $AE;X
L003CED: db $EA;X
L003CEE: db $AE;X
L003CEF: db $AA;X
L003CF0: db $AA;X
L003CF1: db $AA;X
L003CF2: db $EE;X
L003CF3: db $AE;X
L003CF4: db $BE;X
L003CF5: db $AE;X
L003CF6: db $AA;X
L003CF7: db $EA;X
L003CF8: db $AE;X
L003CF9: db $AA;X
L003CFA: db $AA;X
L003CFB: db $EA;X
L003CFC: db $AA;X
L003CFD: db $BA;X
L003CFE: db $AE;X
L003CFF: db $AA;X
L003D00: db $AA;X
L003D01: db $8A;X
L003D02: db $AA;X
L003D03: db $22;X
L003D04: db $A2;X
L003D05: db $AA;X
L003D06: db $AA;X
L003D07: db $A0;X
L003D08: db $AA;X
L003D09: db $0A;X
L003D0A: db $8A;X
L003D0B: db $AA;X
L003D0C: db $AA;X
L003D0D: db $8A;X
L003D0E: db $AA;X
L003D0F: db $A0;X
L003D10: db $AA;X
L003D11: db $A2;X
L003D12: db $A2;X
L003D13: db $A2;X
L003D14: db $AA;X
L003D15: db $A2;X
L003D16: db $AA;X
L003D17: db $2A;X
L003D18: db $A8;X
L003D19: db $82;X
L003D1A: db $A8;X
L003D1B: db $0A;X
L003D1C: db $8A;X
L003D1D: db $2A;X
L003D1E: db $8A;X
L003D1F: db $A2;X
L003D20: db $A2;X
L003D21: db $AA;X
L003D22: db $A2;X
L003D23: db $2A;X
L003D24: db $82;X
L003D25: db $08;X
L003D26: db $A2;X
L003D27: db $8A;X
L003D28: db $82;X
L003D29: db $A2;X
L003D2A: db $2A;X
L003D2B: db $82;X
L003D2C: db $0A;X
L003D2D: db $8A;X
L003D2E: db $28;X
L003D2F: db $AA;X
L003D30: db $AA;X
L003D31: db $00;X
L003D32: db $8A;X
L003D33: db $8A;X
L003D34: db $A0;X
L003D35: db $A2;X
L003D36: db $22;X
L003D37: db $A2;X
L003D38: db $8A;X
L003D39: db $AA;X
L003D3A: db $22;X
L003D3B: db $88;X
L003D3C: db $AA;X
L003D3D: db $A2;X
L003D3E: db $28;X
L003D3F: db $A8;X
L003D40: db $AA;X
L003D41: db $8A;X
L003D42: db $22;X
L003D43: db $AA;X
L003D44: db $88;X
L003D45: db $AA;X
L003D46: db $AA;X
L003D47: db $AA;X
L003D48: db $AA;X
L003D49: db $A8;X
L003D4A: db $0A;X
L003D4B: db $22;X
L003D4C: db $8A;X
L003D4D: db $2A;X
L003D4E: db $A2;X
L003D4F: db $A8;X
L003D50: db $A8;X
L003D51: db $20;X
L003D52: db $AA;X
L003D53: db $A8;X
L003D54: db $82;X
L003D55: db $A2;X
L003D56: db $A0;X
L003D57: db $A2;X
L003D58: db $8A;X
L003D59: db $AA;X
L003D5A: db $8A;X
L003D5B: db $2A;X
L003D5C: db $22;X
L003D5D: db $82;X
L003D5E: db $80;X
L003D5F: db $A2;X
L003D60: db $AA;X
L003D61: db $8A;X
L003D62: db $A0;X
L003D63: db $20;X
L003D64: db $02;X
L003D65: db $AA;X
L003D66: db $A8;X
L003D67: db $2A;X
L003D68: db $A0;X
L003D69: db $22;X
L003D6A: db $A2;X
L003D6B: db $8A;X
L003D6C: db $A8;X
L003D6D: db $AA;X
L003D6E: db $A8;X
L003D6F: db $A8;X
L003D70: db $82;X
L003D71: db $20;X
L003D72: db $20;X
L003D73: db $A2;X
L003D74: db $20;X
L003D75: db $02;X
L003D76: db $A2;X
L003D77: db $AA;X
L003D78: db $2A;X
L003D79: db $AA;X
L003D7A: db $A8;X
L003D7B: db $AC;X
L003D7C: db $8A;X
L003D7D: db $20;X
L003D7E: db $AA;X
L003D7F: db $8A;X
L003D80: db $EA;X
L003D81: db $AB;X
L003D82: db $EA;X
L003D83: db $AA;X
L003D84: db $AA;X
L003D85: db $AE;X
L003D86: db $AA;X
L003D87: db $AA;X
L003D88: db $EE;X
L003D89: db $AA;X
L003D8A: db $EE;X
L003D8B: db $AA;X
L003D8C: db $EA;X
L003D8D: db $AA;X
L003D8E: db $EE;X
L003D8F: db $AE;X
L003D90: db $AB;X
L003D91: db $AA;X
L003D92: db $EF;X
L003D93: db $AA;X
L003D94: db $AA;X
L003D95: db $AB;X
L003D96: db $AA;X
L003D97: db $AA;X
L003D98: db $BA;X
L003D99: db $AA;X
L003D9A: db $AA;X
L003D9B: db $EA;X
L003D9C: db $AE;X
L003D9D: db $AA;X
L003D9E: db $AA;X
L003D9F: db $EE;X
L003DA0: db $AA;X
L003DA1: db $AB;X
L003DA2: db $AE;X
L003DA3: db $AA;X
L003DA4: db $AA;X
L003DA5: db $AE;X
L003DA6: db $AA;X
L003DA7: db $AA;X
L003DA8: db $AA;X
L003DA9: db $AA;X
L003DAA: db $EE;X
L003DAB: db $AE;X
L003DAC: db $AE;X
L003DAD: db $AA;X
L003DAE: db $AA;X
L003DAF: db $AA;X
L003DB0: db $AE;X
L003DB1: db $EA;X
L003DB2: db $AA;X
L003DB3: db $AA;X
L003DB4: db $AE;X
L003DB5: db $AA;X
L003DB6: db $BA;X
L003DB7: db $EA;X
L003DB8: db $AF;X
L003DB9: db $AA;X
L003DBA: db $AE;X
L003DBB: db $EA;X
L003DBC: db $AF;X
L003DBD: db $BA;X
L003DBE: db $BA;X
L003DBF: db $AA;X
L003DC0: db $AA;X
L003DC1: db $EE;X
L003DC2: db $AA;X
L003DC3: db $AA;X
L003DC4: db $AE;X
L003DC5: db $BE;X
L003DC6: db $AE;X
L003DC7: db $EA;X
L003DC8: db $AA;X
L003DC9: db $AA;X
L003DCA: db $AA;X
L003DCB: db $AA;X
L003DCC: db $AE;X
L003DCD: db $AB;X
L003DCE: db $BA;X
L003DCF: db $EA;X
L003DD0: db $AA;X
L003DD1: db $AA;X
L003DD2: db $EA;X
L003DD3: db $AE;X
L003DD4: db $AE;X
L003DD5: db $AB;X
L003DD6: db $AA;X
L003DD7: db $AA;X
L003DD8: db $AE;X
L003DD9: db $AE;X
L003DDA: db $AA;X
L003DDB: db $AA;X
L003DDC: db $AA;X
L003DDD: db $EA;X
L003DDE: db $EA;X
L003DDF: db $AE;X
L003DE0: db $EE;X
L003DE1: db $FE;X
L003DE2: db $EE;X
L003DE3: db $AE;X
L003DE4: db $AA;X
L003DE5: db $BA;X
L003DE6: db $AE;X
L003DE7: db $AA;X
L003DE8: db $AA;X
L003DE9: db $EA;X
L003DEA: db $EA;X
L003DEB: db $AA;X
L003dec: db $AA;X
L003DED: db $AA;X
L003DEE: db $AA;X
L003DEF: db $AA;X
L003DF0: db $AA;X
L003DF1: db $AF;X
L003DF2: db $AA;X
L003DF3: db $AA;X
L003DF4: db $AF;X
L003DF5: db $AA;X
L003DF6: db $EA;X
L003DF7: db $AA;X
L003DF8: db $EA;X
L003DF9: db $AA;X
L003DFA: db $AF;X
L003DFB: db $AA;X
L003DFC: db $AA;X
L003DFD: db $EE;X
L003DFE: db $AA;X
L003DFF: db $EA;X
L003E00: db $A8;X
L003E01: db $0A;X
L003E02: db $2A;X
L003E03: db $8A;X
L003E04: db $A8;X
L003E05: db $8A;X
L003E06: db $AA;X
L003E07: db $2A;X
L003E08: db $AA;X
L003E09: db $80;X
L003E0A: db $0A;X
L003E0B: db $AA;X
L003E0C: db $02;X
L003E0D: db $AA;X
L003E0E: db $8A;X
L003E0F: db $0A;X
L003E10: db $8A;X
L003E11: db $AA;X
L003E12: db $A0;X
L003E13: db $A8;X
L003E14: db $A8;X
L003E15: db $0A;X
L003E16: db $A8;X
L003E17: db $8A;X
L003E18: db $82;X
L003E19: db $0A;X
L003E1A: db $AA;X
L003E1B: db $82;X
L003E1C: db $A8;X
L003E1D: db $2A;X
L003E1E: db $AA;X
L003E1F: db $AA;X
L003E20: db $A0;X
L003E21: db $AA;X
L003E22: db $2A;X
L003E23: db $A8;X
L003E24: db $AA;X
L003E25: db $A8;X
L003E26: db $AA;X
L003E27: db $A8;X
L003E28: db $A0;X
L003E29: db $82;X
L003E2A: db $AA;X
L003E2B: db $22;X
L003E2C: db $A0;X
L003E2D: db $A2;X
L003E2E: db $AA;X
L003E2F: db $A2;X
L003E30: db $80;X
L003E31: db $A8;X
L003E32: db $88;X
L003E33: db $A0;X
L003E34: db $28;X
L003E35: db $0A;X
L003E36: db $8A;X
L003E37: db $A2;X
L003E38: db $22;X
L003E39: db $AA;X
L003E3A: db $A0;X
L003E3B: db $2A;X
L003E3C: db $A2;X
L003E3D: db $AA;X
L003E3E: db $88;X
L003E3F: db $2A;X
L003E40: db $88;X
L003E41: db $2A;X
L003E42: db $AA;X
L003E43: db $AA;X
L003E44: db $A8;X
L003E45: db $2A;X
L003E46: db $28;X
L003E47: db $AA;X
L003E48: db $8A;X
L003E49: db $2A;X
L003E4A: db $28;X
L003E4B: db $8A;X
L003E4C: db $AA;X
L003E4D: db $AA;X
L003E4E: db $AA;X
L003E4F: db $A2;X
L003E50: db $AA;X
L003E51: db $AA;X
L003E52: db $8A;X
L003E53: db $A0;X
L003E54: db $A8;X
L003E55: db $AA;X
L003E56: db $2A;X
L003E57: db $AA;X
L003E58: db $80;X
L003E59: db $AA;X
L003E5A: db $AA;X
L003E5B: db $AA;X
L003E5C: db $AA;X
L003E5D: db $AA;X
L003E5E: db $A0;X
L003E5F: db $A8;X
L003E60: db $AA;X
L003E61: db $88;X
L003E62: db $0A;X
L003E63: db $A2;X
L003E64: db $AA;X
L003E65: db $2A;X
L003E66: db $82;X
L003E67: db $A8;X
L003E68: db $AA;X
L003E69: db $AA;X
L003E6A: db $2A;X
L003E6B: db $A2;X
L003E6C: db $A0;X
L003E6D: db $AA;X
L003E6E: db $AA;X
L003E6F: db $8A;X
L003E70: db $AA;X
L003E71: db $AA;X
L003E72: db $8A;X
L003E73: db $AA;X
L003E74: db $AA;X
L003E75: db $A2;X
L003E76: db $82;X
L003E77: db $28;X
L003E78: db $8A;X
L003E79: db $A0;X
L003E7A: db $A2;X
L003E7B: db $0A;X
L003E7C: db $2A;X
L003E7D: db $82;X
L003E7E: db $A0;X
L003E7F: db $2A;X
L003E80: db $EA;X
L003E81: db $EA;X
L003E82: db $EA;X
L003E83: db $AA;X
L003E84: db $AA;X
L003E85: db $AE;X
L003E86: db $AA;X
L003E87: db $EA;X
L003E88: db $AE;X
L003E89: db $AA;X
L003E8A: db $EA;X
L003E8B: db $AA;X
L003E8C: db $FA;X
L003E8D: db $AA;X
L003E8E: db $AA;X
L003E8F: db $AA;X
L003E90: db $AA;X
L003E91: db $AA;X
L003E92: db $AE;X
L003E93: db $AE;X
L003E94: db $AB;X
L003E95: db $AA;X
L003E96: db $AB;X
L003E97: db $AA;X
L003E98: db $AA;X
L003E99: db $AE;X
L003E9A: db $AA;X
L003E9B: db $AB;X
L003E9C: db $AE;X
L003E9D: db $AA;X
L003E9E: db $AA;X
L003E9F: db $AA;X
L003EA0: db $AA;X
L003EA1: db $EA;X
L003EA2: db $AA;X
L003EA3: db $AA;X
L003EA4: db $AE;X
L003EA5: db $EE;X
L003EA6: db $AE;X
L003EA7: db $AE;X
L003EA8: db $EE;X
L003EA9: db $AE;X
L003EAA: db $AA;X
L003EAB: db $AA;X
L003EAC: db $BB;X
L003EAD: db $EA;X
L003EAE: db $AE;X
L003EAF: db $EA;X
L003EB0: db $AA;X
L003EB1: db $AA;X
L003EB2: db $AA;X
L003EB3: db $AA;X
L003EB4: db $AE;X
L003EB5: db $AA;X
L003EB6: db $AA;X
L003EB7: db $AE;X
L003EB8: db $AA;X
L003EB9: db $EA;X
L003EBA: db $AA;X
L003EBB: db $EA;X
L003EBC: db $AE;X
L003EBD: db $AA;X
L003EBE: db $FA;X
L003EBF: db $AA;X
L003EC0: db $AA;X
L003EC1: db $AA;X
L003EC2: db $EE;X
L003EC3: db $AA;X
L003EC4: db $EE;X
L003EC5: db $A2;X
L003EC6: db $AA;X
L003EC7: db $AE;X
L003EC8: db $AE;X
L003EC9: db $AA;X
L003ECA: db $AA;X
L003ECB: db $AA;X
L003ECC: db $AA;X
L003ECD: db $AA;X
L003ECE: db $AE;X
L003ECF: db $AA;X
L003ED0: db $AE;X
L003ED1: db $AA;X
L003ED2: db $AA;X
L003ED3: db $AA;X
L003ED4: db $AA;X
L003ED5: db $AA;X
L003ED6: db $EA;X
L003ED7: db $EA;X
L003ED8: db $BA;X
L003ED9: db $AA;X
L003EDA: db $AE;X
L003EDB: db $AA;X
L003EDC: db $EE;X
L003EDD: db $EE;X
L003EDE: db $AA;X
L003EDF: db $AA;X
L003EE0: db $AE;X
L003EE1: db $AB;X
L003EE2: db $AA;X
L003EE3: db $AA;X
L003EE4: db $AA;X
L003EE5: db $AA;X
L003EE6: db $AA;X
L003EE7: db $AA;X
L003EE8: db $AA;X
L003EE9: db $EA;X
L003EEA: db $AE;X
L003EEB: db $AE;X
L003EEC: db $AA;X
L003EED: db $AA;X
L003EEE: db $EE;X
L003EEF: db $AA;X
L003EF0: db $EA;X
L003EF1: db $EA;X
L003EF2: db $AE;X
L003EF3: db $AA;X
L003EF4: db $AE;X
L003EF5: db $AA;X
L003EF6: db $AA;X
L003EF7: db $AA;X
L003EF8: db $AE;X
L003EF9: db $AA;X
L003EFA: db $EA;X
L003EFB: db $EA;X
L003EFC: db $AE;X
L003EFD: db $EA;X
L003EFE: db $AA;X
L003EFF: db $AA;X
L003F00: db $88;X
L003F01: db $A0;X
L003F02: db $A0;X
L003F03: db $AA;X
L003F04: db $2A;X
L003F05: db $A8;X
L003F06: db $2A;X
L003F07: db $22;X
L003F08: db $A2;X
L003F09: db $88;X
L003F0A: db $A2;X
L003F0B: db $82;X
L003F0C: db $A8;X
L003F0D: db $2A;X
L003F0E: db $AA;X
L003F0F: db $28;X
L003F10: db $A0;X
L003F11: db $0A;X
L003F12: db $22;X
L003F13: db $8A;X
L003F14: db $2A;X
L003F15: db $A8;X
L003F16: db $A2;X
L003F17: db $A8;X
L003F18: db $AA;X
L003F19: db $88;X
L003F1A: db $08;X
L003F1B: db $A8;X
L003F1C: db $22;X
L003F1D: db $8A;X
L003F1E: db $22;X
L003F1F: db $0A;X
L003F20: db $A2;X
L003F21: db $AA;X
L003F22: db $88;X
L003F23: db $8A;X
L003F24: db $88;X
L003F25: db $08;X
L003F26: db $AA;X
L003F27: db $A0;X
L003F28: db $A2;X
L003F29: db $A8;X
L003F2A: db $80;X
L003F2B: db $80;X
L003F2C: db $A8;X
L003F2D: db $A8;X
L003F2E: db $2A;X
L003F2F: db $A8;X
L003F30: db $AA;X
L003F31: db $2A;X
L003F32: db $2A;X
L003F33: db $AA;X
L003F34: db $A8;X
L003F35: db $AA;X
L003F36: db $0A;X
L003F37: db $82;X
L003F38: db $8A;X
L003F39: db $AA;X
L003F3A: db $28;X
L003F3B: db $2A;X
L003F3C: db $AA;X
L003F3D: db $A8;X
L003F3E: db $A0;X
L003F3F: db $22;X
L003F40: db $08;X
L003F41: db $22;X
L003F42: db $A2;X
L003F43: db $82;X
L003F44: db $AA;X
L003F45: db $A0;X
L003F46: db $A8;X
L003F47: db $AA;X
L003F48: db $A2;X
L003F49: db $A8;X
L003F4A: db $A8;X
L003F4B: db $8A;X
L003F4C: db $00;X
L003F4D: db $AA;X
L003F4E: db $AA;X
L003F4F: db $A2;X
L003F50: db $AA;X
L003F51: db $A8;X
L003F52: db $2A;X
L003F53: db $8A;X
L003F54: db $A8;X
L003F55: db $88;X
L003F56: db $AA;X
L003F57: db $2A;X
L003F58: db $AA;X
L003F59: db $0A;X
L003F5A: db $A2;X
L003F5B: db $AA;X
L003F5C: db $AA;X
L003F5D: db $0A;X
L003F5E: db $28;X
L003F5F: db $A0;X
L003F60: db $8A;X
L003F61: db $20;X
L003F62: db $A8;X
L003F63: db $2A;X
L003F64: db $2A;X
L003F65: db $A8;X
L003F66: db $A8;X
L003F67: db $A2;X
L003F68: db $28;X
L003F69: db $AA;X
L003F6A: db $AA;X
L003F6B: db $2A;X
L003F6C: db $AA;X
L003F6D: db $A8;X
L003F6E: db $AA;X
L003F6F: db $AA;X
L003F70: db $2A;X
L003F71: db $8A;X
L003F72: db $AA;X
L003F73: db $A0;X
L003F74: db $02;X
L003F75: db $2A;X
L003F76: db $A8;X
L003F77: db $0A;X
L003F78: db $A8;X
L003F79: db $2A;X
L003F7A: db $8A;X
L003F7B: db $AA;X
L003F7C: db $0A;X
L003F7D: db $2A;X
L003F7E: db $A8;X
L003F7F: db $08;X
L003F80: db $BA;X
L003F81: db $AA;X
L003F82: db $AE;X
L003F83: db $BA;X
L003F84: db $AB;X
L003F85: db $AA;X
L003F86: db $AA;X
L003F87: db $EA;X
L003F88: db $EA;X
L003F89: db $EA;X
L003F8A: db $EA;X
L003F8B: db $BE;X
L003F8C: db $AA;X
L003F8D: db $AA;X
L003F8E: db $AE;X
L003F8F: db $AA;X
L003F90: db $AA;X
L003F91: db $AA;X
L003F92: db $EA;X
L003F93: db $AA;X
L003F94: db $AA;X
L003F95: db $AE;X
L003F96: db $AE;X
L003F97: db $AA;X
L003F98: db $AA;X
L003F99: db $AA;X
L003F9A: db $EA;X
L003F9B: db $AB;X
L003F9C: db $AA;X
L003F9D: db $AA;X
L003F9E: db $EA;X
L003F9F: db $AA;X
L003FA0: db $AA;X
L003FA1: db $EA;X
L003FA2: db $BA;X
L003FA3: db $EE;X
L003FA4: db $AA;X
L003FA5: db $AB;X
L003FA6: db $AA;X
L003FA7: db $AA;X
L003FA8: db $EA;X
L003FA9: db $AA;X
L003FAA: db $EA;X
L003FAB: db $EA;X
L003FAC: db $AB;X
L003FAD: db $AA;X
L003FAE: db $AF;X
L003FAF: db $AB;X
L003FB0: db $AA;X
L003FB1: db $AA;X
L003FB2: db $AE;X
L003FB3: db $EB;X
L003FB4: db $AE;X
L003FB5: db $EA;X
L003FB6: db $AA;X
L003FB7: db $AE;X
L003FB8: db $AA;X
L003FB9: db $AA;X
L003FBA: db $AA;X
L003FBB: db $EA;X
L003FBC: db $AA;X
L003FBD: db $AE;X
L003FBE: db $AF;X
L003FBF: db $AA;X
L003FC0: db $AA;X
L003FC1: db $EA;X
L003FC2: db $AA;X
L003FC3: db $AA;X
L003FC4: db $EA;X
L003FC5: db $AA;X
L003FC6: db $AA;X
L003FC7: db $AA;X
L003FC8: db $AE;X
L003FC9: db $AA;X
L003FCA: db $EE;X
L003FCB: db $EE;X
L003FCC: db $AA;X
L003FCD: db $AA;X
L003FCE: db $AA;X
L003FCF: db $EE;X
L003FD0: db $EE;X
L003FD1: db $AE;X
L003FD2: db $AE;X
L003FD3: db $AA;X
L003FD4: db $EA;X
L003FD5: db $FE;X
L003FD6: db $BA;X
L003FD7: db $AA;X
L003FD8: db $BA;X
L003FD9: db $AA;X
L003FDA: db $AA;X
L003FDB: db $EE;X
L003FDC: db $AE;X
L003FDD: db $AA;X
L003FDE: db $AE;X
L003FDF: db $FA;X
L003FE0: db $AE;X
L003FE1: db $EE;X
L003FE2: db $EE;X
L003FE3: db $EA;X
L003FE4: db $EA;X
L003FE5: db $AA;X
L003FE6: db $AA;X
L003FE7: db $AA;X
L003FE8: db $AE;X
L003FE9: db $AA;X
L003FEA: db $EA;X
L003FEB: db $AA;X
L003FEC: db $AE;X
L003FED: db $AA;X
L003FEE: db $AA;X
L003FEF: db $AA;X
L003FF0: db $EA;X
L003FF1: db $AA;X
L003FF2: db $AE;X
L003FF3: db $AE;X
L003FF4: db $AB;X
L003FF5: db $AA;X
L003FF6: db $AA;X
L003FF7: db $AA;X
L003FF8: db $AA;X
L003FF9: db $AA;X
L003FFA: db $AA;X
L003FFB: db $EA;X
L003FFC: db $AE;X
L003FFD: db $AE;X
L003FFE: db $AE;X
L003FFF: db $AA;X
