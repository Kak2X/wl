;
; BANK $13 - Level Layouts
;
LevelLayoutPtr_C04: dw LevelLayout_C04
LevelLayoutPtr_C09: dw LevelLayout_C09
LevelLayoutPtr_C03A: dw LevelLayout_C03A
LevelLayoutPtr_C02: dw LevelLayout_C02
LevelLayoutPtr_C08: dw LevelLayout_C08
LevelLayoutPtr_C11: dw LevelLayout_C11
LevelLayoutPtr_C35: dw LevelLayout_C35
	
; =============== START OF ALIGN JUNK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L13400E.asm"
ENDC
; =============== END OF ALIGN JUNK ===============
LevelLayout_C04: INCBIN "data/lvl/c04/level_layout.bin"
LevelLayout_C09: INCBIN "data/lvl/c09/level_layout.bin"
LevelLayout_C03A: INCBIN "data/lvl/c03a/level_layout.bin"
LevelLayout_C02: INCBIN "data/lvl/c02/level_layout.bin"
LevelLayout_C08: INCBIN "data/lvl/c08/level_layout.bin"
LevelLayout_C11: INCBIN "data/lvl/c11/level_layout.bin"
LevelLayout_C35: INCBIN "data/lvl/c35/level_layout.bin"
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L137F1A.asm"
ENDC
