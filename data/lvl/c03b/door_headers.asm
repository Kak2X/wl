Door_C03B_15:
	dc $01B0,$0C28	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0C00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C03B_Room1C		; Actor Setup code
Door_C03B_1C:
	dc $01E0,$0578	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0528	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C03B_Room10		; Actor Setup code
Door_C03B_1D:
	dc $01E0,$0848	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$07F8	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C03B_Room10		; Actor Setup code
Door_C03B_18:
	dc $01E0,$0DD8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0160,$0D50	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C03B_Room1C		; Actor Setup code
Door_C03B_16:
	dc $01E0,$0E98	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0E48	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_WaterCave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_WaterCave		; 16x16 Blocks
	dw ActGroup_C03B_Room1E		; Actor Setup code
Door_C03B_1E:
	dc $0160,$0698	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0648	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C03B_Room10		; Actor Setup code
Door_C03B_17:
	dc $01E0,$0F68	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0F18	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_WaterCave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_WaterCave		; 16x16 Blocks
	dw ActGroup_C03B_Room1E		; Actor Setup code
Door_C03B_1F:
	dc $0160,$0768	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0718	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C03B_Room10		; Actor Setup code
Door_C03B_1B:
	dc $00E0,$0C28	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0C00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCastle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCastle		; 16x16 Blocks
	dw ActGroup_C03B_Room0C		; Actor Setup code
Door_C03B_0C:
	dc $0160,$0BD8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $00E0,$0B50	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C03B_Room10		; Actor Setup code
Door_C03B_11:
	dc $00E0,$0F28	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0F00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $63			; Palette
	dp GFX_Level_Treasure		; Main GFX
	dw GFX_LevelShared_07		; Shared Block GFX
	dw GFX_StatusBar_03		; Status Bar GFX
	dw GFX_LevelAnim_0E		; Animated tiles GFX
	dw LevelBlock_Treasure		; 16x16 Blocks
	dw ActGroup_TreasureA		; Actor Setup code
Door_C03B_0F:
	dc $0160,$01C8	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0178	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C03B_Room10		; Actor Setup code
