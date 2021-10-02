;
; BANK $0E - Level GFX
;
GFX_Level_Cave: INCBIN "data/gfx/level/level_cave.bin"
GFX_Level_Sand: INCBIN "data/gfx/level/level_sand.bin"
GFX_Level_WaterCave: INCBIN "data/gfx/level/level_watercave.bin"
GFX_Level_Train: INCBIN "data/gfx/level/level_train.bin"
GFX_Level_Tree: INCBIN "data/gfx/level/level_tree.bin"
GFX_Level_Treasure: INCBIN "data/gfx/level/level_treasure.bin"
GFX_Level_Ship: INCBIN "data/gfx/level/level_ship.bin"
GFX_Level_Lava: INCBIN "data/gfx/level/level_lava.bin"
GFX_Level_Castle: INCBIN "data/gfx/level/level_castle.bin"
GFX_Level_DarkCastle: INCBIN "data/gfx/level/level_darkcastle.bin"
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L0E7C00.asm"
ENDC