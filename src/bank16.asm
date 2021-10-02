;
; BANK $16 - Level Layouts
;
LevelLayoutPtr_C34: dw LevelLayout_C34
LevelLayoutPtr_C30: dw LevelLayout_C30
LevelLayoutPtr_C21: dw LevelLayout_C21
LevelLayoutPtr_C22: dw LevelLayout_C22
LevelLayoutPtr_C01B: dw LevelLayout_C01B
LevelLayoutPtr_C19: dw LevelLayout_C19
; =============== START OF ALIGN JUNK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L16400C.asm"
ENDC
; =============== END OF ALIGN JUNK ===============
LevelLayout_C34: INCBIN "data/lvl/c34/level_layout.bin"
LevelLayout_C30: INCBIN "data/lvl/c30/level_layout.bin"
LevelLayout_C21: INCBIN "data/lvl/c21/level_layout.bin"
LevelLayout_C22: INCBIN "data/lvl/c22/level_layout.bin"
LevelLayout_C01B: INCBIN "data/lvl/c01b/level_layout.bin"
LevelLayout_C19: INCBIN "data/lvl/c19/level_layout.bin"
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L167CF9.asm"
ENDC
