;
; BANK $10 - Level Layouts
;
LevelLayoutPtr_C07: dw LevelLayout_C07
LevelLayoutPtr_C01A: dw LevelLayout_C01A
LevelLayoutPtr_C17: dw LevelLayout_C17
LevelLayoutPtr_C12: dw LevelLayout_C12
LevelLayoutPtr_C13: dw LevelLayout_C13
LevelLayoutPtr_C29: dw LevelLayout_C29
	mIncJunk "L10400C"
LevelLayout_C07: INCBIN "data/lvl/c07/level_layout.bin"
LevelLayout_C01A: INCBIN "data/lvl/c01a/level_layout.bin"
LevelLayout_C17: INCBIN "data/lvl/c17/level_layout.bin"
LevelLayout_C12: INCBIN "data/lvl/c12/level_layout.bin"
LevelLayout_C13: INCBIN "data/lvl/c13/level_layout.bin"
LevelLayout_C29: INCBIN "data/lvl/c29/level_layout.bin"
; =============== END OF BANK ===============
	mIncJunk "L107FC9"
