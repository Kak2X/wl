;
; BANK $0A - Level Layouts
;
LevelLayoutPtr_C26: dw LevelLayout_C26
LevelLayoutPtr_C33: dw LevelLayout_C33
LevelLayoutPtr_C15: dw LevelLayout_C15
LevelLayoutPtr_C20: dw LevelLayout_C20
LevelLayoutPtr_C16: dw LevelLayout_C16
LevelLayoutPtr_C10: dw LevelLayout_C10
	mIncJunk "L0A400C"
LevelLayout_C26: INCBIN "data/lvl/c26/level_layout.bin"
LevelLayout_C33: INCBIN "data/lvl/c33/level_layout.bin"
LevelLayout_C15: INCBIN "data/lvl/c15/level_layout.bin"
LevelLayout_C20: INCBIN "data/lvl/c20/level_layout.bin"
LevelLayout_C16: INCBIN "data/lvl/c16/level_layout.bin"
LevelLayout_C10: INCBIN "data/lvl/c10/level_layout.bin"
; =============== END OF BANK ===============
	mIncJunk "L0A7A02"
