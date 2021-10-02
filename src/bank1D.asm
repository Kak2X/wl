;
; BANK $1D - Level GFX
;
GFX_Level_Unused_BoboBoss: INCBIN "data/gfx/level/level_unused_boboboss.bin"
GFX_Level_MtTeapotBoss: INCBIN "data/gfx/level/level_mtteapotboss.bin"
GFX_Level_SherbetLandBoss: INCBIN "data/gfx/level/level_sherbetlandboss.bin"
GFX_Level_RiceBeachBoss: INCBIN "data/gfx/level/level_ricebeachboss.bin"
GFX_Level_ParsleyWoodsBoss: INCBIN "data/gfx/level/level_parsleywoodsboss.bin"
GFX_Level_StoveCanyonBoss: INCBIN "data/gfx/level/level_stovecanyonboss.bin"
GFX_Level_SSTeacupBoss: INCBIN "data/gfx/level/level_ssteacupboss.bin"
GFX_Level_SyrupCastleBoss: INCBIN "data/gfx/level/level_syrupcastleboss.bin"
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L1D7000.asm"
ENDC
