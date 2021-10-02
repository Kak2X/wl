;
; BANK $1A - Level Layouts
;
	dw LevelLayout_C28
	dw LevelLayout_C18
	dw LevelLayout_C14
	dw LevelLayout_C38
	dw LevelLayout_C39
	
; =============== START OF ALIGN JUNK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L1A400A.asm"
ENDC
; =============== END OF ALIGN JUNK ===============
LevelLayout_C28: INCBIN "data/lvl/c28/level_layout.bin"
LevelLayout_C18: INCBIN "data/lvl/c18/level_layout.bin"
LevelLayout_C14: INCBIN "data/lvl/c14/level_layout.bin"
LevelLayout_C38: INCBIN "data/lvl/c38/level_layout.bin"
LevelLayout_C39: INCBIN "data/lvl/c39/level_layout.bin"
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L1A7EA6.asm"
ENDC
