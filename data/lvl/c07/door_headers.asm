Door_C07_19:
	dc $01B0,$0C38	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0C00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_WaterCave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_06		; Animated tiles GFX
	dw LevelBlock_WaterCave		; 16x16 Blocks
	dw ActGroup_C07_Room1C		; Actor Setup code
Door_C07_1C:
	dc $0130,$09D8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $00E0,$0950	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_Mountain		; 16x16 Blocks
	dw ActGroup_C07_Room10		; Actor Setup code
Door_C07_14:
	dc $01D0,$0A88	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0A38	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C07_Room0A		; Actor Setup code
Door_C07_1A:
	dc $0190,$04B8	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0140,$0458	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_Mountain		; 16x16 Blocks
	dw ActGroup_C07_Room10		; Actor Setup code
Door_C07_04:
	dc $00D0,$0A88	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0A38	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C07_Room0A		; Actor Setup code
Door_C07_0A:
	dc $00A0,$04B8	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0050,$0458	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_Mountain		; 16x16 Blocks
	dw ActGroup_C07_Room10		; Actor Setup code
Door_C07_13:
	dc $01E0,$0B58	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0B08	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C07_Room1B		; Actor Setup code
Door_C07_1B:
	dc $01D0,$0368	; Player pos (Y / X)
	db $08			; Scroll lock
	dc $0150,$0308	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_Mountain		; 16x16 Blocks
	dw ActGroup_C07_Room10		; Actor Setup code
