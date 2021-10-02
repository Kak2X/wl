;
; BANK $0A - Level Layouts
;
	dw LevelLayout_C26
	dw LevelLayout_C33
	dw LevelLayout_C15
	dw LevelLayout_C20
	dw LevelLayout_C16
	dw LevelLayout_C10
; =============== START OF ALIGN JUNK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L0A400C.asm"
ENDC
; =============== END OF ALIGN JUNK ===============
LevelLayout_C26: INCBIN "data/lvl/c26/level_layout.bin"
LevelLayout_C33: INCBIN "data/lvl/c33/level_layout.bin"
LevelLayout_C15: INCBIN "data/lvl/c15/level_layout.bin"
LevelLayout_C20: INCBIN "data/lvl/c20/level_layout.bin"
LevelLayout_C16: INCBIN "data/lvl/c16/level_layout.bin"
LevelLayout_C10: INCBIN "data/lvl/c10/level_layout.bin"
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L0A7A02.asm"
ENDC