Door_C31A_17:
	dc $0160,$0F98	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0F38	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C31A_Room1F		; Actor Setup code
Door_C31A_1F:
	dc $01E0,$07B8	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0758	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Forest		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Forest		; 16x16 Blocks
	dw ActGroup_C31A_Room10		; Actor Setup code
