Door_C21_15:
	dc $00E0,$0058	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0000	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C21_Room00		; Actor Setup code
Door_C21_00:
	dc $01E0,$05B8	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0558	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E4			; Palette
	dp GFX_Level_Lava		; Main GFX
	dw GFX_LevelShared_04		; Shared Block GFX
	dw GFX_StatusBar_00		; Status Bar GFX
	dw GFX_LevelAnim_09		; Animated tiles GFX
	dw LevelBlock_Lava		; 16x16 Blocks
	dw ActGroup_C21_Room10		; Actor Setup code
Door_C21_1B:
	dc $00B0,$0178	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0118	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C21_Room01		; Actor Setup code
Door_C21_01:
	dc $01C0,$0BD8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0160,$0B50	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E4			; Palette
	dp GFX_Level_Lava		; Main GFX
	dw GFX_LevelShared_04		; Shared Block GFX
	dw GFX_StatusBar_00		; Status Bar GFX
	dw GFX_LevelAnim_09		; Animated tiles GFX
	dw LevelBlock_Lava		; 16x16 Blocks
	dw ActGroup_C21_Room10		; Actor Setup code
