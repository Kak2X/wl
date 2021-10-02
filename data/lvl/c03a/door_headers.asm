Door_C03A_15:
	dc $01B0,$0C28	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0C00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C03A_Room1C		; Actor Setup code
Door_C03A_1C:
	dc $01E0,$0578	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0520	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_01		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C03A_Room10		; Actor Setup code
Door_C03A_1D:
	dc $01E0,$0848	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0800	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_01		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C03A_Room10		; Actor Setup code
Door_C03A_18:
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
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C03A_Room1C		; Actor Setup code
Door_C03A_16:
	dc $01E0,$0E98	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0E40	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_WaterCave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_06		; Animated tiles GFX
	dw LevelBlock_WaterCave		; 16x16 Blocks
	dw ActGroup_C03A_Room1E		; Actor Setup code
Door_C03A_1E:
	dc $0160,$0698	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0640	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_01		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C03A_Room10		; Actor Setup code
Door_C03A_17:
	dc $01E0,$0F68	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0F10	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_WaterCave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_06		; Animated tiles GFX
	dw LevelBlock_WaterCave		; 16x16 Blocks
	dw ActGroup_C03A_Room1E		; Actor Setup code
Door_C03A_1F:
	dc $0160,$0768	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0710	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_01		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C03A_Room10		; Actor Setup code
Door_C03A_1B:
	dc $00E0,$0C28	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0C00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCastle		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_01		; Animated tiles GFX
	dw LevelBlock_StoneCastle		; 16x16 Blocks
	dw ActGroup_C03A_Room0C		; Actor Setup code
Door_C03A_0C:
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
	dw GFX_LevelAnim_01		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C03A_Room10		; Actor Setup code
