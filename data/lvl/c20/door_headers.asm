Door_C20_18:
	dc $0160,$0948	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $00E0,$0900	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C20_Room19		; Actor Setup code
Door_C20_09:
	dc $01E0,$0B28	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0B00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $63			; Palette
	dp GFX_Level_Treasure		; Main GFX
	dw GFX_LevelShared_07		; Shared Block GFX
	dw GFX_StatusBar_03		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Treasure		; 16x16 Blocks
	dw ActGroup_TreasureG		; Actor Setup code
Door_C20_1B:
	dc $00E0,$0988	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0928	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C20_Room19		; Actor Setup code
