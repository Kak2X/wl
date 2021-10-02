;
; BANK $0B - 16x16 Block Data
;

; =============== Level_CopyBlockData ===============
; This subroutine copies the 16x16 block data to RAM.
; Block data must be exactly $0200 bytes large, which is $80 blocks.
; IN
; - HL: Ptr to block data
Level_CopyBlockData:
	ld   de, sLevelBlocks
	ld   bc, $0200
	call CopyBytesEx
	ret
	
LevelBlock_Forest: INCBIN "data/block16/forest.bin"
LevelBlock_Mountain: INCBIN "data/block16/mountain.bin"
LevelBlock_SkyCastle: INCBIN "data/block16/skycastle.bin"
LevelBlock_Beach: INCBIN "data/block16/beach.bin"
LevelBlock_Unused_BoboBoss: INCBIN "data/block16/unused_boboboss.bin"
LevelBlock_Cave: INCBIN "data/block16/cave.bin"
LevelBlock_MountainCave: INCBIN "data/block16/mountaincave.bin"
LevelBlock_Sand: INCBIN "data/block16/sand.bin"
LevelBlock_WaterCave: INCBIN "data/block16/watercave.bin"
LevelBlock_Train: INCBIN "data/block16/train.bin"
LevelBlock_Tree: INCBIN "data/block16/tree.bin"
LevelBlock_Treasure: INCBIN "data/block16/treasure.bin"
LevelBlock_Ship: INCBIN "data/block16/ship.bin"
LevelBlock_Lava: INCBIN "data/block16/lava.bin"
LevelBlock_StoneCastle: INCBIN "data/block16/stonecastle.bin"
LevelBlock_Boss0: INCBIN "data/block16/boss0.bin"
LevelBlock_Boss1: INCBIN "data/block16/boss1.bin"
LevelBlock_Ice: INCBIN "data/block16/ice.bin"
LevelBlock_StoneCave: INCBIN "data/block16/stonecave.bin"
LevelBlock_Castle: INCBIN "data/block16/castle.bin"
LevelBlock_Castle2: INCBIN "data/block16/castle2.bin"
LevelBlock_SyrupCastleBoss: INCBIN "data/block16/syrupcastleboss.bin"
LevelBlock_DarkCastle: INCBIN "data/block16/darkcastle.bin"
; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L0B6E0A.asm"
ENDC
