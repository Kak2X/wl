;
; BANK $1A - Level Layouts
;
LevelLayoutPtr_C28: dw LevelLayout_C28
LevelLayoutPtr_C18: dw LevelLayout_C18
LevelLayoutPtr_C14: dw LevelLayout_C14
LevelLayoutPtr_C38: dw LevelLayout_C38
LevelLayoutPtr_C39: dw LevelLayout_C39
	mIncJunk "L1A400A"
LevelLayout_C28: INCBIN "data/lvl/c28/level_layout.bin"
LevelLayout_C18: INCBIN "data/lvl/c18/level_layout.bin"
LevelLayout_C14: INCBIN "data/lvl/c14/level_layout.bin"
LevelLayout_C38: INCBIN "data/lvl/c38/level_layout.bin"
LevelLayout_C39: INCBIN "data/lvl/c39/level_layout.bin"
; =============== END OF BANK ===============
	mIncJunk "L1A7EA6"
