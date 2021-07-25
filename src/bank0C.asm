;
; BANK $0C - Level / Room Headers
;

; =============== Scroll Lock Definitions ===============
; This table defines the scroll locks for all levels.
;
; FORMAT:
; Every level uses $20 bytes for its scroll lock definitions,
; as each level sector uses its own byte, and every level has $20 sectors.
;
; Each of these bytes is a bitmask:
; ------LR
; -> R: If set, the right border is locked
; -> L: If set, the leftmost border is locked
;
; In theory bit 2 (up border lock) and bit 3 (down border lock) also exist,
; but they are auto-generated for freeroaming mode (and not used elsewhere) so any value would get overridden.
;
Level_ScrollLocks:
ScrollLocks_C26: INCBIN "data/lvl/c26/scroll_locks.bin"
ScrollLocks_C33: INCBIN "data/lvl/c33/scroll_locks.bin"
ScrollLocks_C15: INCBIN "data/lvl/c15/scroll_locks.bin"
ScrollLocks_C20: INCBIN "data/lvl/c20/scroll_locks.bin"
ScrollLocks_C16: INCBIN "data/lvl/c16/scroll_locks.bin"
ScrollLocks_C10: INCBIN "data/lvl/c10/scroll_locks.bin"
ScrollLocks_C07: INCBIN "data/lvl/c07/scroll_locks.bin"
ScrollLocks_C01A: INCBIN "data/lvl/c01a/scroll_locks.bin"
ScrollLocks_C17: INCBIN "data/lvl/c17/scroll_locks.bin"
ScrollLocks_C12: INCBIN "data/lvl/c12/scroll_locks.bin"
ScrollLocks_C13: INCBIN "data/lvl/c13/scroll_locks.bin"
ScrollLocks_C29: INCBIN "data/lvl/c29/scroll_locks.bin"
ScrollLocks_C04: INCBIN "data/lvl/c04/scroll_locks.bin"
ScrollLocks_C09: INCBIN "data/lvl/c09/scroll_locks.bin"
ScrollLocks_C03A: INCBIN "data/lvl/c03a/scroll_locks.bin"
ScrollLocks_C02: INCBIN "data/lvl/c02/scroll_locks.bin"
ScrollLocks_C08: INCBIN "data/lvl/c08/scroll_locks.bin"
ScrollLocks_C11: INCBIN "data/lvl/c11/scroll_locks.bin"
ScrollLocks_C35: INCBIN "data/lvl/c35/scroll_locks.bin"
ScrollLocks_C34: INCBIN "data/lvl/c34/scroll_locks.bin"
ScrollLocks_C30: INCBIN "data/lvl/c30/scroll_locks.bin"
ScrollLocks_C21: INCBIN "data/lvl/c21/scroll_locks.bin"
ScrollLocks_C22: INCBIN "data/lvl/c22/scroll_locks.bin"
ScrollLocks_C01B: INCBIN "data/lvl/c01b/scroll_locks.bin"
ScrollLocks_C19: INCBIN "data/lvl/c19/scroll_locks.bin"
ScrollLocks_C05: INCBIN "data/lvl/c05/scroll_locks.bin"
ScrollLocks_C36: INCBIN "data/lvl/c36/scroll_locks.bin"
ScrollLocks_C24: INCBIN "data/lvl/c24/scroll_locks.bin"
ScrollLocks_C25: INCBIN "data/lvl/c25/scroll_locks.bin"
ScrollLocks_C32: INCBIN "data/lvl/c32/scroll_locks.bin"
ScrollLocks_C27: INCBIN "data/lvl/c27/scroll_locks.bin"
ScrollLocks_C28: INCBIN "data/lvl/c28/scroll_locks.bin"
ScrollLocks_C18: INCBIN "data/lvl/c18/scroll_locks.bin"
ScrollLocks_C14: INCBIN "data/lvl/c14/scroll_locks.bin"
ScrollLocks_C38: INCBIN "data/lvl/c38/scroll_locks.bin"
ScrollLocks_C39: INCBIN "data/lvl/c39/scroll_locks.bin"
ScrollLocks_C03B: INCBIN "data/lvl/c03b/scroll_locks.bin"
ScrollLocks_C37: INCBIN "data/lvl/c37/scroll_locks.bin"
ScrollLocks_C31A: INCBIN "data/lvl/c31a/scroll_locks.bin"
ScrollLocks_C23: INCBIN "data/lvl/c23/scroll_locks.bin"
ScrollLocks_C40: INCBIN "data/lvl/c40/scroll_locks.bin"
ScrollLocks_C06: INCBIN "data/lvl/c06/scroll_locks.bin"
ScrollLocks_C31B: INCBIN "data/lvl/c31b/scroll_locks.bin"

; =============== Level Headers ===============
; This table defines the level headers for all levels in the game.
; NOTE: If a checkpoint is active, Level_HeaderCheckpointPtrTable is used instead.
;
; Table entry format ($1D bytes):
;   |- $00    : Bank number for level GFX
;  1|- $01-$02: Ptr to level GFX
;  2|- $03-$04: Ptr to block GFX (Bank $11)
;  3|- $05-$06: Ptr to status bar GFX (Bank $11)
;  4|- $07-$08: Ptr to animated tile GFX (Bank $11)
;  5|- $09    : Bank number for level layout
;  5|- $0A    : Level layout ID (to a ptr table at the top of the specified bank number)
;  6|- $0B-$0C: Ptr to 16x16 block definitions (Bank $0B)
;  7|- $0D-$0E: Player Y pos
;  8|- $0F-$10: Player X pos
;  9|- $11    : Initial animation frame (OBJLst Id) 
; 10|- $12    : Player flags for OAMWrite
; 11|- $13-$14: Scroll Y pos (without offset)
; 12|- $15-$16: Scroll X pos (without offset)
; 13|- $17    : Initial scroll lock
; 14|- $18    : Initial scroll mode
; 15|- $19    : If set, the player spawns swimming
; 16|- $1A    : Level tile animation speed
; 17|- $1B    : Level Palette
; 18|- $1C-$1D: Ptr to Actor setup routine (Bank $07)

Level_HeaderPtrTable: 
	dw LevelHeader_C26 
	dw LevelHeader_C33 
	dw LevelHeader_C15 
	dw LevelHeader_C20 
	dw LevelHeader_C16 
	dw LevelHeader_C10 
	dw LevelHeader_C07 
	dw LevelHeader_C01A
	dw LevelHeader_C17 
	dw LevelHeader_C12 
	dw LevelHeader_C13 
	dw LevelHeader_C29 
	dw LevelHeader_C04 
	dw LevelHeader_C09 
	dw LevelHeader_C03A
	dw LevelHeader_C02 
	dw LevelHeader_C08 
	dw LevelHeader_C11 
	dw LevelHeader_C35 
	dw LevelHeader_C34 
	dw LevelHeader_C30 
	dw LevelHeader_C21 
	dw LevelHeader_C22 
	dw LevelHeader_C01B
	dw LevelHeader_C19 
	dw LevelHeader_C05 
	dw LevelHeader_C36 
	dw LevelHeader_C24 
	dw LevelHeader_C25 
	dw LevelHeader_C32 
	dw LevelHeader_C27 
	dw LevelHeader_C28 
	dw LevelHeader_C18 
	dw LevelHeader_C14 
	dw LevelHeader_C38 
	dw LevelHeader_C39 
	dw LevelHeader_C03B
	dw LevelHeader_C37 
	dw LevelHeader_C31A
	dw LevelHeader_C23 
	dw LevelHeader_C40 
	dw LevelHeader_C06 
	dw LevelHeader_C31B

; The non-alt entries in this table are not used (levels without checkpoint)
; [POI] This being right after the normal entries is the reason why "duplicate levels"
;       exist when going out of range.
Level_HeaderCheckpointPtrTable: 
	dw LevelHeader_C26  	
	dw LevelHeader_C33Alt  
	dw LevelHeader_C15Alt  
	dw LevelHeader_C20  	
	dw LevelHeader_C16Alt  
	dw LevelHeader_C10Alt  
	dw LevelHeader_C07Alt  
	dw LevelHeader_C01A  	
	dw LevelHeader_C17Alt  
	dw LevelHeader_C12  	
	dw LevelHeader_C13Alt  
	dw LevelHeader_C29Alt  
	dw LevelHeader_C04  	
	dw LevelHeader_C09Alt  
	dw LevelHeader_C03AAlt 
	dw LevelHeader_C02Alt  
	dw LevelHeader_C08Alt  
	dw LevelHeader_C11Alt  
	dw LevelHeader_C35Alt  
	dw LevelHeader_C34Alt  
	dw LevelHeader_C30Alt  
	dw LevelHeader_C21Alt  
	dw LevelHeader_C22Alt  
	dw LevelHeader_C01B 	
	dw LevelHeader_C19Alt  
	dw LevelHeader_C05Alt  
	dw LevelHeader_C36Alt  
	dw LevelHeader_C24  	
	dw LevelHeader_C25Alt  
	dw LevelHeader_C32 		
	dw LevelHeader_C27Alt  
	dw LevelHeader_C28Alt  
	dw LevelHeader_C18Alt  
	dw LevelHeader_C14Alt  
	dw LevelHeader_C38Alt  
	dw LevelHeader_C39Alt  
	dw LevelHeader_C03BAlt 
	dw LevelHeader_C37Alt  
	dw LevelHeader_C31AAlt 
	dw LevelHeader_C23Alt  
	dw LevelHeader_C40Alt  
	dw LevelHeader_C06  	
	dw LevelHeader_C31BAlt 

LevelHeader_C26: INCLUDE "data/lvl/c26/header.asm"
; [TCRF] Unused level header, possibly for testing.
;        Identical to C26 except you spawn in the treasure room.
LevelHeader_C26_Unused: INCLUDE "data/lvl/c26/header_unused.asm"
LevelHeader_C33: INCLUDE "data/lvl/c33/header.asm"
LevelHeader_C33Alt: INCLUDE "data/lvl/c33/header_checkpoint.asm"
LevelHeader_C15: INCLUDE "data/lvl/c15/header.asm"
LevelHeader_C15Alt: INCLUDE "data/lvl/c15/header_checkpoint.asm"
LevelHeader_C20: INCLUDE "data/lvl/c20/header.asm"
LevelHeader_C16: INCLUDE "data/lvl/c16/header.asm"
LevelHeader_C16Alt: INCLUDE "data/lvl/c16/header_checkpoint.asm"
LevelHeader_C10: INCLUDE "data/lvl/c10/header.asm"
LevelHeader_C10Alt: INCLUDE "data/lvl/c10/header_checkpoint.asm"
LevelHeader_C07: INCLUDE "data/lvl/c07/header.asm"
LevelHeader_C07Alt: INCLUDE "data/lvl/c07/header_checkpoint.asm"
LevelHeader_C01A: INCLUDE "data/lvl/c01a/header.asm"
LevelHeader_C17: INCLUDE "data/lvl/c17/header.asm"
LevelHeader_C17Alt: INCLUDE "data/lvl/c17/header_checkpoint.asm"
LevelHeader_C12: INCLUDE "data/lvl/c12/header.asm"
LevelHeader_C13: INCLUDE "data/lvl/c13/header.asm"
LevelHeader_C13Alt: INCLUDE "data/lvl/c13/header_checkpoint.asm"
LevelHeader_C29: INCLUDE "data/lvl/c29/header.asm"
LevelHeader_C29Alt: INCLUDE "data/lvl/c29/header_checkpoint.asm"
LevelHeader_C04: INCLUDE "data/lvl/c04/header.asm"
LevelHeader_C09: INCLUDE "data/lvl/c09/header.asm"
LevelHeader_C09Alt: INCLUDE "data/lvl/c09/header_checkpoint.asm"
LevelHeader_C03A: INCLUDE "data/lvl/c03a/header.asm"
LevelHeader_C03AAlt: INCLUDE "data/lvl/c03a/header_checkpoint.asm"
LevelHeader_C02: INCLUDE "data/lvl/c02/header.asm"
LevelHeader_C02Alt: INCLUDE "data/lvl/c02/header_checkpoint.asm"
LevelHeader_C08: INCLUDE "data/lvl/c08/header.asm"
LevelHeader_C08Alt: INCLUDE "data/lvl/c08/header_checkpoint.asm"
LevelHeader_C11: INCLUDE "data/lvl/c11/header.asm"
LevelHeader_C11Alt: INCLUDE "data/lvl/c11/header_checkpoint.asm"
LevelHeader_C35: INCLUDE "data/lvl/c35/header.asm"
LevelHeader_C35Alt: INCLUDE "data/lvl/c35/header_checkpoint.asm"
LevelHeader_C34: INCLUDE "data/lvl/c34/header.asm"
LevelHeader_C34Alt: INCLUDE "data/lvl/c34/header_checkpoint.asm"
LevelHeader_C30: INCLUDE "data/lvl/c30/header.asm"
LevelHeader_C30Alt: INCLUDE "data/lvl/c30/header_checkpoint.asm"
LevelHeader_C21: INCLUDE "data/lvl/c21/header.asm"
LevelHeader_C21Alt: INCLUDE "data/lvl/c21/header_checkpoint.asm"
LevelHeader_C22: INCLUDE "data/lvl/c22/header.asm"
LevelHeader_C22Alt: INCLUDE "data/lvl/c22/header_checkpoint.asm"
LevelHeader_C01B: INCLUDE "data/lvl/c01b/header.asm"
LevelHeader_C19: INCLUDE "data/lvl/c19/header.asm"
LevelHeader_C19Alt: INCLUDE "data/lvl/c19/header_checkpoint.asm"
LevelHeader_C05: INCLUDE "data/lvl/c05/header.asm"
LevelHeader_C05Alt: INCLUDE "data/lvl/c05/header_checkpoint.asm"
LevelHeader_C36: INCLUDE "data/lvl/c36/header.asm"
LevelHeader_C36Alt: INCLUDE "data/lvl/c36/header_checkpoint.asm"
LevelHeader_C24: INCLUDE "data/lvl/c24/header.asm"
LevelHeader_C25: INCLUDE "data/lvl/c25/header.asm"
LevelHeader_C25Alt: INCLUDE "data/lvl/c25/header_checkpoint.asm"
LevelHeader_C32: INCLUDE "data/lvl/c32/header.asm"
LevelHeader_C27: INCLUDE "data/lvl/c27/header.asm"
LevelHeader_C27Alt: INCLUDE "data/lvl/c27/header_checkpoint.asm"
LevelHeader_C28: INCLUDE "data/lvl/c28/header.asm"
LevelHeader_C28Alt: INCLUDE "data/lvl/c28/header_checkpoint.asm"
LevelHeader_C18: INCLUDE "data/lvl/c18/header.asm"
LevelHeader_C18Alt: INCLUDE "data/lvl/c18/header_checkpoint.asm"
LevelHeader_C14: INCLUDE "data/lvl/c14/header.asm"
LevelHeader_C14Alt: INCLUDE "data/lvl/c14/header_checkpoint.asm"
LevelHeader_C38: INCLUDE "data/lvl/c38/header.asm"
LevelHeader_C38Alt: INCLUDE "data/lvl/c38/header_checkpoint.asm"
LevelHeader_C39: INCLUDE "data/lvl/c39/header.asm"
LevelHeader_C39Alt: INCLUDE "data/lvl/c39/header_checkpoint.asm"
LevelHeader_C03B: INCLUDE "data/lvl/c03b/header.asm"
LevelHeader_C03BAlt: INCLUDE "data/lvl/c03b/header_checkpoint.asm"
LevelHeader_C37: INCLUDE "data/lvl/c37/header.asm"
LevelHeader_C37Alt: INCLUDE "data/lvl/c37/header_checkpoint.asm"
LevelHeader_C31A: INCLUDE "data/lvl/c31a/header.asm"
LevelHeader_C31AAlt: INCLUDE "data/lvl/c31a/header_checkpoint.asm"
LevelHeader_C23: INCLUDE "data/lvl/c23/header.asm"
LevelHeader_C23Alt: INCLUDE "data/lvl/c23/header_checkpoint.asm"
LevelHeader_C40: INCLUDE "data/lvl/c40/header.asm"
LevelHeader_C40Alt: INCLUDE "data/lvl/c40/header_checkpoint.asm"
LevelHeader_C06: INCLUDE "data/lvl/c06/header.asm"
LevelHeader_C31B: INCLUDE "data/lvl/c31b/header.asm"
LevelHeader_C31BAlt: INCLUDE "data/lvl/c31b/header_checkpoint.asm"

; =============== Room Headers ===============
; This pointer table defines *all* the room transitions for all screens in the levels.
; To each sector of a level is assigned either a normal entry or a special value.
;
; Table entry format ($18 bytes):
;  1|- $00#HI : Player Y High (screen num)
;  1|- $00#LOW: Player X High (screen num)
;  1|- $01    : Player Y Low
;  1|- $02    : Player X Low
;  2|- $03    : Scroll lock
;  3|- $04#HI : Scroll Y High (without offset; screen num)
;  3|- $04#LOW: Scroll X High (without offset; screen num)
;  3|- $05    : Scroll Y Low (without offset)
;  3|- $06    : Scroll X Low (without offset)
;  4|- $07    : Scroll mode
;  5|- $08    : BG Priority option
;  6|- $09    : Tile animation speed
;  7|- $0A    : Palette
;  8|- $0B    : Bank number for level GFX
;  8|- $0C-$0D: Ptr to level GFX
;  9|- $0E-$0F: Ptr to shared block GFX (Bank $11)
;  A|- $10-$11: Ptr to status bar GFX (Bank $11)
;  B|- $12-$13: Ptr to animated tile GFX (Bank $11)
;  C|- $14-$15: Ptr to 16x16 block definitions (Bank $0B)
;  D|- $16-$17: Ptr to Actor setup routine (Bank $07)
Level_DoorHeaderPtrTable:
;      Door Ptr             ; Sector number
DoorHeaderPtrs_C26: INCLUDE "data/lvl/c26/doors_section_assoc.asm"
DoorHeaderPtrs_C33: INCLUDE "data/lvl/c33/doors_section_assoc.asm"
DoorHeaderPtrs_C15: INCLUDE "data/lvl/c15/doors_section_assoc.asm"
DoorHeaderPtrs_C20: INCLUDE "data/lvl/c20/doors_section_assoc.asm"
DoorHeaderPtrs_C16: INCLUDE "data/lvl/c16/doors_section_assoc.asm"
DoorHeaderPtrs_C10: INCLUDE "data/lvl/c10/doors_section_assoc.asm"
DoorHeaderPtrs_C07: INCLUDE "data/lvl/c07/doors_section_assoc.asm"
DoorHeaderPtrs_C01A: INCLUDE "data/lvl/c01a/doors_section_assoc.asm"
DoorHeaderPtrs_C17: INCLUDE "data/lvl/c17/doors_section_assoc.asm"
DoorHeaderPtrs_C12: INCLUDE "data/lvl/c12/doors_section_assoc.asm"
DoorHeaderPtrs_C13: INCLUDE "data/lvl/c13/doors_section_assoc.asm"
DoorHeaderPtrs_C29: INCLUDE "data/lvl/c29/doors_section_assoc.asm"
DoorHeaderPtrs_C04: INCLUDE "data/lvl/c04/doors_section_assoc.asm"
DoorHeaderPtrs_C09: INCLUDE "data/lvl/c09/doors_section_assoc.asm"
DoorHeaderPtrs_C03A: INCLUDE "data/lvl/c03a/doors_section_assoc.asm"
DoorHeaderPtrs_C02: INCLUDE "data/lvl/c02/doors_section_assoc.asm"
DoorHeaderPtrs_C08: INCLUDE "data/lvl/c08/doors_section_assoc.asm"
DoorHeaderPtrs_C11: INCLUDE "data/lvl/c11/doors_section_assoc.asm"
DoorHeaderPtrs_C35: INCLUDE "data/lvl/c35/doors_section_assoc.asm"
DoorHeaderPtrs_C34: INCLUDE "data/lvl/c34/doors_section_assoc.asm"
DoorHeaderPtrs_C30: INCLUDE "data/lvl/c30/doors_section_assoc.asm"
DoorHeaderPtrs_C21: INCLUDE "data/lvl/c21/doors_section_assoc.asm"
DoorHeaderPtrs_C22: INCLUDE "data/lvl/c22/doors_section_assoc.asm"
DoorHeaderPtrs_C01B: INCLUDE "data/lvl/c01b/doors_section_assoc.asm"
DoorHeaderPtrs_C19: INCLUDE "data/lvl/c19/doors_section_assoc.asm"
DoorHeaderPtrs_C05: INCLUDE "data/lvl/c05/doors_section_assoc.asm"
DoorHeaderPtrs_C36: INCLUDE "data/lvl/c36/doors_section_assoc.asm"
DoorHeaderPtrs_C24: INCLUDE "data/lvl/c24/doors_section_assoc.asm"
DoorHeaderPtrs_C25: INCLUDE "data/lvl/c25/doors_section_assoc.asm"
DoorHeaderPtrs_C32: INCLUDE "data/lvl/c32/doors_section_assoc.asm"
DoorHeaderPtrs_C27: INCLUDE "data/lvl/c27/doors_section_assoc.asm"
DoorHeaderPtrs_C28: INCLUDE "data/lvl/c28/doors_section_assoc.asm"
DoorHeaderPtrs_C18: INCLUDE "data/lvl/c18/doors_section_assoc.asm"
DoorHeaderPtrs_C14: INCLUDE "data/lvl/c14/doors_section_assoc.asm"
DoorHeaderPtrs_C38: INCLUDE "data/lvl/c38/doors_section_assoc.asm"
DoorHeaderPtrs_C39: INCLUDE "data/lvl/c39/doors_section_assoc.asm"
DoorHeaderPtrs_C03B: INCLUDE "data/lvl/c03b/doors_section_assoc.asm"
DoorHeaderPtrs_C37: INCLUDE "data/lvl/c37/doors_section_assoc.asm"
DoorHeaderPtrs_C31A: INCLUDE "data/lvl/c31a/doors_section_assoc.asm"
DoorHeaderPtrs_C23: INCLUDE "data/lvl/c23/doors_section_assoc.asm"
DoorHeaderPtrs_C40: INCLUDE "data/lvl/c40/doors_section_assoc.asm"
DoorHeaderPtrs_C06: INCLUDE "data/lvl/c06/doors_section_assoc.asm"
DoorHeaderPtrs_C31B: INCLUDE "data/lvl/c31b/doors_section_assoc.asm"

	
; =============== Level_DoorHeaders_TreasurePtrs ===============
; These are for the special spawn locations after returning from the treasure room.
Level_DoorHeaders_TreasurePtrs:
	dw Door_TreasureC
	dw Door_TreasureI
	dw Door_TreasureF
	dw Door_TreasureO
	dw Door_TreasureA
	dw Door_TreasureN
	dw Door_TreasureH
	dw Door_TreasureM
	dw Door_TreasureL
	dw Door_TreasureK
	dw Door_TreasureB
	dw Door_TreasureD
	dw Door_TreasureG
	dw Door_TreasureJ
	dw Door_TreasureE
	
; =============== Treasure Room Transitions ===============
Door_TreasureC: INCLUDE "data/lvl/c11/door_treasure.asm"
Door_TreasureI: INCLUDE "data/lvl/c26/door_treasure.asm"
Door_TreasureF: INCLUDE "data/lvl/c18/door_treasure.asm"
Door_TreasureO: INCLUDE "data/lvl/c39/door_treasure.asm"
Door_TreasureA: INCLUDE "data/lvl/c03b/door_treasure.asm"
Door_TreasureN: INCLUDE "data/lvl/c37/door_treasure.asm"
Door_TreasureH: INCLUDE "data/lvl/c24/door_treasure.asm"
Door_TreasureM: INCLUDE "data/lvl/c34/door_treasure.asm"
Door_TreasureL: INCLUDE "data/lvl/c31b/door_treasure.asm"
Door_TreasureK: INCLUDE "data/lvl/c30/door_treasure.asm"
Door_TreasureB: INCLUDE "data/lvl/c09/door_treasure.asm"
Door_TreasureD: INCLUDE "data/lvl/c16/door_treasure.asm"
Door_TreasureG: INCLUDE "data/lvl/c20/door_treasure.asm"
Door_TreasureJ: INCLUDE "data/lvl/c29/door_treasure.asm"
Door_TreasureE: INCLUDE "data/lvl/c17/door_treasure.asm"

; =============== Magic Transitions ===============
Door_None:			db DOORSPEC_NONE
Door_LevelEntrance:	db DOORSPEC_ENTRANCE
Door_LevelClear:	db DOORSPEC_LVLCLEAR
Door_LevelClearAlt:	db DOORSPEC_LVLCLEARALT

; =============== Room Transitions ===============
INCLUDE "data/lvl/c26/door_headers.asm"
INCLUDE "data/lvl/c33/door_headers.asm"
INCLUDE "data/lvl/c15/door_headers.asm"
INCLUDE "data/lvl/c20/door_headers.asm"
INCLUDE "data/lvl/c16/door_headers.asm"
INCLUDE "data/lvl/c10/door_headers.asm"
INCLUDE "data/lvl/c07/door_headers.asm"
INCLUDE "data/lvl/c01a/door_headers.asm"
INCLUDE "data/lvl/c17/door_headers.asm"
INCLUDE "data/lvl/c12/door_headers.asm"
INCLUDE "data/lvl/c13/door_headers.asm"
INCLUDE "data/lvl/c29/door_headers.asm"
INCLUDE "data/lvl/c04/door_headers.asm"
INCLUDE "data/lvl/c09/door_headers.asm"
INCLUDE "data/lvl/c03a/door_headers.asm"
INCLUDE "data/lvl/c02/door_headers.asm"
INCLUDE "data/lvl/c08/door_headers.asm"
INCLUDE "data/lvl/c11/door_headers.asm"
INCLUDE "data/lvl/c35/door_headers.asm"
INCLUDE "data/lvl/c34/door_headers.asm"
INCLUDE "data/lvl/c30/door_headers.asm"
INCLUDE "data/lvl/c21/door_headers.asm"
INCLUDE "data/lvl/c22/door_headers.asm"
INCLUDE "data/lvl/c01b/door_headers.asm"
INCLUDE "data/lvl/c19/door_headers.asm"
INCLUDE "data/lvl/c05/door_headers.asm"
INCLUDE "data/lvl/c36/door_headers.asm"
INCLUDE "data/lvl/c24/door_headers.asm"
INCLUDE "data/lvl/c25/door_headers.asm"
INCLUDE "data/lvl/c32/door_headers.asm"
INCLUDE "data/lvl/c27/door_headers.asm"
INCLUDE "data/lvl/c28/door_headers.asm"
INCLUDE "data/lvl/c18/door_headers.asm"
INCLUDE "data/lvl/c14/door_headers.asm"
INCLUDE "data/lvl/c38/door_headers.asm"
INCLUDE "data/lvl/c39/door_headers.asm"
INCLUDE "data/lvl/c03b/door_headers.asm"
INCLUDE "data/lvl/c37/door_headers.asm"
INCLUDE "data/lvl/c31a/door_headers.asm"
INCLUDE "data/lvl/c23/door_headers.asm"
INCLUDE "data/lvl/c40/door_headers.asm"
INCLUDE "data/lvl/c06/door_headers.asm"
INCLUDE "data/lvl/c31b/door_headers.asm"

; =============== Game_PowerupStatePtrTbl ===============
; Defines the options for all of Wario's states.
; For each state these options are defined:
; - Small Wario flag
; - Initial animation frame
; - Ptr to GFX (in Bank $05)
Game_PowerupStatePtrTbl: 
	dw .small
	dw .garlic
	dw .bull
	dw .jet
	dw .dragon
.small:		
	db $01
	db OBJ_SMALLWARIO_STAND
	dw GFX_NormalHat
.garlic:	
	db $00
	db OBJ_WARIO_STAND
	dw GFX_NormalHat
.bull:		
	db $00
	db OBJ_WARIO_STAND
	dw GFX_BullHat
.jet:		
	db $00
	db OBJ_WARIO_STAND
	dw GFX_JetHat
.dragon:	
	db $00
	db OBJ_WARIO_STAND
	dw GFX_DragonHat
	
; =============== Level_LoadScrollLocks ===============
; This subroutine copies to RAM the scroll lock info for the current level.
Level_LoadScrollLocks:
	; Scroll lock info is always $20 bytes.
	ld   d, $00			; DE = sLevelId * 20
	ld   a, [sLevelId]
	ld   e, a
REPT 5
	sla  e				; << 1
	rl   d
ENDR

	ld   hl, Level_ScrollLocks	; HL = Start of table
	add  hl, de					; Offset it
	
	; Copy the data over
	ld   de, sLvlScrollLocks
	ld   b, $20
	call CopyBytes
	ret
	
	
; =============== mLvlBGM ===============
; Generates code to start a BGM if it isn't already playing.
; IN
; - 1: BGM Id
mLvlBGM: MACRO
	ld   a, [sBGM]		; Is the BGM playing already?
	cp   a, \1
	ret  z				; If so, return
	ld   a, \1			; Otherwise, request the BGM
	ld   [sBGMSet], a
	ret
ENDM
	
; =============== Level_SetBGM ===============
; This subroutine starts the current BGM track to what's assigned for the current level.
; but only if it isn't playing already.
;
; This maps all level IDs to their assigned BGM.
Level_SetBGM:
	ld   a, [sLevelId]
	rst  $28
	dw .ship     ; LVL_C26 
	dw .train    ; LVL_C33 
	dw .cave     ; LVL_C15 
	dw .course32 ; LVL_C20 
	dw .ice      ; LVL_C16 
	dw .ambient  ; LVL_C10 
	dw .water    ; LVL_C07 
	dw .course1  ; LVL_C01A
	dw .ice      ; LVL_C17 
	dw .ship     ; LVL_C12 
	dw .boss     ; LVL_C13 
	dw .ship     ; LVL_C29 
	dw .lava     ; LVL_C04 
	dw .ambient  ; LVL_C09 
	dw .course3  ; LVL_C03A
	dw .course1  ; LVL_C02 
	dw .water    ; LVL_C08 
	dw .cave     ; LVL_C11 
	dw .train    ; LVL_C35 
	dw .course3  ; LVL_C34 
	dw .boss     ; LVL_C30 
	dw .lava2    ; LVL_C21 
	dw .cave     ; LVL_C22 
	dw .water    ; LVL_C01B
	dw .boss     ; LVL_C19 
	dw .boss     ; LVL_C05 
	dw .boss     ; LVL_C36 
	dw .ship     ; LVL_C24 
	dw .boss     ; LVL_C25 
	dw .course32 ; LVL_C32 
	dw .ambient  ; LVL_C27 
	dw .course3  ; LVL_C28 
	dw .course3  ; LVL_C18 
	dw .ice      ; LVL_C14 
	dw .course32 ; LVL_C38 
	dw .ship     ; LVL_C39 
	dw .water    ; LVL_C03B
	dw .course1  ; LVL_C37 
	dw .ambient  ; LVL_C31A
	dw .course32 ; LVL_C23 
	dw .final    ; LVL_C40 
	dw .course1  ; LVL_C06 
	dw .course1  ; LVL_C31B
	
.water:    mLvlBGM BGM_WATER
.course1:  mLvlBGM BGM_COURSE1
.ship:     mLvlBGM BGM_SHIP
.lava:     mLvlBGM BGM_LAVA
.train:    mLvlBGM BGM_TRAIN
.boss:     mLvlBGM BGM_BOSSLEVEL
.lava2:    mLvlBGM BGM_LAVA2
.cave:     mLvlBGM BGM_CAVE
.course3:  mLvlBGM BGM_COURSE3
.ambient:  mLvlBGM BGM_AMBIENT
.final:    mLvlBGM BGM_FINALLEVEL
.course32: mLvlBGM BGM_COURSE32
.ice:      mLvlBGM BGM_ICE

; =============== END OF BANK ===============
L0C7F65: db $FF;X
L0C7F66: db $BF;X
L0C7F67: db $FF;X
L0C7F68: db $FF;X
L0C7F69: db $FF;X
L0C7F6A: db $FF;X
L0C7F6B: db $FF;X
L0C7F6C: db $FF;X
L0C7F6D: db $FF;X
L0C7F6E: db $FB;X
L0C7F6F: db $FF;X
L0C7F70: db $EF;X
L0C7F71: db $FB;X
L0C7F72: db $FF;X
L0C7F73: db $FF;X
L0C7F74: db $FF;X
L0C7F75: db $FF;X
L0C7F76: db $FF;X
L0C7F77: db $FF;X
L0C7F78: db $FF;X
L0C7F79: db $FF;X
L0C7F7A: db $FF;X
L0C7F7B: db $FF;X
L0C7F7C: db $FF;X
L0C7F7D: db $FF;X
L0C7F7E: db $FF;X
L0C7F7F: db $FF;X
L0C7F80: db $00;X
L0C7F81: db $1A;X
L0C7F82: db $81;X
L0C7F83: db $00;X
L0C7F84: db $A4;X
L0C7F85: db $03;X
L0C7F86: db $40;X
L0C7F87: db $41;X
L0C7F88: db $04;X
L0C7F89: db $00;X
L0C7F8A: db $00;X
L0C7F8B: db $08;X
L0C7F8C: db $92;X
L0C7F8D: db $0E;X
L0C7F8E: db $80;X
L0C7F8F: db $02;X
L0C7F90: db $00;X
L0C7F91: db $00;X
L0C7F92: db $05;X
L0C7F93: db $00;X
L0C7F94: db $80;X
L0C7F95: db $08;X
L0C7F96: db $81;X
L0C7F97: db $09;X
L0C7F98: db $01;X
L0C7F99: db $20;X
L0C7F9A: db $20;X
L0C7F9B: db $41;X
L0C7F9C: db $02;X
L0C7F9D: db $08;X
L0C7F9E: db $01;X
L0C7F9F: db $00;X
L0C7FA0: db $05;X
L0C7FA1: db $24;X
L0C7FA2: db $00;X
L0C7FA3: db $00;X
L0C7FA4: db $00;X
L0C7FA5: db $29;X
L0C7FA6: db $02;X
L0C7FA7: db $04;X
L0C7FA8: db $0B;X
L0C7FA9: db $A9;X
L0C7FAA: db $06;X
L0C7FAB: db $01;X
L0C7FAC: db $00;X
L0C7FAD: db $00;X
L0C7FAE: db $0A;X
L0C7FAF: db $21;X
L0C7FB0: db $09;X
L0C7FB1: db $01;X
L0C7FB2: db $01;X
L0C7FB3: db $03;X
L0C7FB4: db $10;X
L0C7FB5: db $00;X
L0C7FB6: db $D2;X
L0C7FB7: db $A0;X
L0C7FB8: db $62;X
L0C7FB9: db $00;X
L0C7FBA: db $00;X
L0C7FBB: db $C1;X
L0C7FBC: db $00;X
L0C7FBD: db $21;X
L0C7FBE: db $81;X
L0C7FBF: db $01;X
L0C7FC0: db $00;X
L0C7FC1: db $65;X
L0C7FC2: db $4A;X
L0C7FC3: db $00;X
L0C7FC4: db $80;X
L0C7FC5: db $01;X
L0C7FC6: db $20;X
L0C7FC7: db $02;X
L0C7FC8: db $81;X
L0C7FC9: db $00;X
L0C7FCA: db $80;X
L0C7FCB: db $88;X
L0C7FCC: db $00;X
L0C7FCD: db $00;X
L0C7FCE: db $60;X
L0C7FCF: db $50;X
L0C7FD0: db $00;X
L0C7FD1: db $48;X
L0C7FD2: db $00;X
L0C7FD3: db $82;X
L0C7FD4: db $80;X
L0C7FD5: db $20;X
L0C7FD6: db $02;X
L0C7FD7: db $01;X
L0C7FD8: db $06;X
L0C7FD9: db $41;X
L0C7FDA: db $80;X
L0C7FDB: db $03;X
L0C7FDC: db $02;X
L0C7FDD: db $00;X
L0C7FDE: db $05;X
L0C7FDF: db $90;X
L0C7FE0: db $08;X
L0C7FE1: db $40;X
L0C7FE2: db $00;X
L0C7FE3: db $20;X
L0C7FE4: db $20;X
L0C7FE5: db $00;X
L0C7FE6: db $01;X
L0C7FE7: db $06;X
L0C7FE8: db $40;X
L0C7FE9: db $08;X
L0C7FEA: db $00;X
L0C7FEB: db $80;X
L0C7FEC: db $01;X
L0C7FED: db $81;X
L0C7FEE: db $00;X
L0C7FEF: db $80;X
L0C7FF0: db $80;X
L0C7FF1: db $01;X
L0C7FF2: db $01;X
L0C7FF3: db $21;X
L0C7FF4: db $80;X
L0C7FF5: db $20;X
L0C7FF6: db $00;X
L0C7FF7: db $41;X
L0C7FF8: db $04;X
L0C7FF9: db $02;X
L0C7FFA: db $45;X
L0C7FFB: db $88;X
L0C7FFC: db $02;X
L0C7FFD: db $85;X
L0C7FFE: db $01;X
L0C7FFF: db $C1;X
