;
; BANK $19 - Level Layouts
;
	dw LevelLayout_C05
	dw LevelLayout_C36
	dw LevelLayout_C24
	dw LevelLayout_C25
	dw LevelLayout_C32
	dw LevelLayout_C27
; =============== START OF ALIGN JUNK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L19400C.asm"
ENDC
; =============== END OF ALIGN JUNK ===============
LevelLayout_C05: INCBIN "data/lvl/c05/level_layout.bin"
LevelLayout_C36: INCBIN "data/lvl/c36/level_layout.bin"
LevelLayout_C24: INCBIN "data/lvl/c24/level_layout.bin"
LevelLayout_C25: INCBIN "data/lvl/c25/level_layout.bin"
LevelLayout_C32: INCBIN "data/lvl/c32/level_layout.bin"
LevelLayout_C27: INCBIN "data/lvl/c27/level_layout.bin"
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L1973FB.asm"
ENDC