;
; BANK $1C - Level Layouts
;
LevelLayoutPtr_C03B: dw LevelLayout_C03B
LevelLayoutPtr_C37: dw LevelLayout_C37
LevelLayoutPtr_C31A: dw LevelLayout_C31A
LevelLayoutPtr_C23: dw LevelLayout_C23
LevelLayoutPtr_C40: dw LevelLayout_C40
LevelLayoutPtr_C06: dw LevelLayout_C06
LevelLayoutPtr_C31B: dw LevelLayout_C31B
	mIncJunk "L1C400E"
LevelLayout_C03B: INCBIN "data/lvl/c03b/level_layout.bin"
LevelLayout_C37: INCBIN "data/lvl/c37/level_layout.bin"
LevelLayout_C31A: INCBIN "data/lvl/c31a/level_layout.bin"
LevelLayout_C23: INCBIN "data/lvl/c23/level_layout.bin"
LevelLayout_C40: INCBIN "data/lvl/c40/level_layout.bin"
LevelLayout_C06: INCBIN "data/lvl/c06/level_layout.bin"
LevelLayout_C31B: INCBIN "data/lvl/c31b/level_layout.bin"
; =============== END OF BANK ===============
	mIncJunk "L1C79C5"
