;
; BANK $03 - Level GFX
;
GFX_Level_Mountain:		INCBIN "data/gfx/level/level_mountain.bin"
GFX_Level_Forest:		INCBIN "data/gfx/level/level_forest.bin"
GFX_Level_SkyCastle:	INCBIN "data/gfx/level/level_skycastle.bin"
GFX_Level_Beach:		INCBIN "data/gfx/level/level_beach.bin"
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L035800.asm"
ENDC
