;
; BANK $1C - Level Layouts
;
	dw LevelLayout_C03B
	dw LevelLayout_C37
	dw LevelLayout_C31A
	dw LevelLayout_C23
	dw LevelLayout_C40
	dw LevelLayout_C06
	dw LevelLayout_C31B
; =============== START OF ALIGN JUNK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L1C400E.asm"
ENDC
; =============== END OF ALIGN JUNK ===============
LevelLayout_C03B: INCBIN "data/lvl/c03b/level_layout.bin"
LevelLayout_C37: INCBIN "data/lvl/c37/level_layout.bin"
LevelLayout_C31A: INCBIN "data/lvl/c31a/level_layout.bin"
LevelLayout_C23: INCBIN "data/lvl/c23/level_layout.bin"
LevelLayout_C40: INCBIN "data/lvl/c40/level_layout.bin"
LevelLayout_C06: INCBIN "data/lvl/c06/level_layout.bin"
LevelLayout_C31B: INCBIN "data/lvl/c31b/level_layout.bin"
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L1C79C5.asm"
ENDC
