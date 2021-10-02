Door_C28_13:
	dc $00E0,$0278	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0220	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C28_Room18		; Actor Setup code
Door_C28_02:
	dc $01C0,$03C8	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0370	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C28_Room10		; Actor Setup code
Door_C28_18:
	dc $00E0,$0868	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0810	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C28_Room08		; Actor Setup code
Door_C28_08:
	dc $01F0,$0868	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0810	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C28_Room10		; Actor Setup code
Door_C28_1C:
	dc $01C0,$0D38	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0D00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_WaterCave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_06		; Animated tiles GFX
	dw LevelBlock_WaterCave		; 16x16 Blocks
	dw ActGroup_C28_Room18		; Actor Setup code
Door_C28_1D:
	dc $01E0,$0CD8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0160,$0C50	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C28_Room10		; Actor Setup code
