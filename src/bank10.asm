;
; BANK $10 - Level Layouts
;
	dw LevelLayout_C07
	dw LevelLayout_C01A
	dw LevelLayout_C17
	dw LevelLayout_C12
	dw LevelLayout_C13
	dw LevelLayout_C29
	
; =============== START OF ALIGN JUNK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L10400C.asm"
ENDC
; =============== END OF ALIGN JUNK ===============
LevelLayout_C07: INCBIN "data/lvl/c07/level_layout.bin"
LevelLayout_C01A: INCBIN "data/lvl/c01a/level_layout.bin"
LevelLayout_C17: INCBIN "data/lvl/c17/level_layout.bin"
LevelLayout_C12: INCBIN "data/lvl/c12/level_layout.bin"
LevelLayout_C13: INCBIN "data/lvl/c13/level_layout.bin"
LevelLayout_C29: INCBIN "data/lvl/c29/level_layout.bin"
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L107FC9.asm"
ENDC