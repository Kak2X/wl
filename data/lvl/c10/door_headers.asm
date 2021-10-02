Door_C10_06:
	dc $0140,$0C58	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0C08	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C10_Room1C		; Actor Setup code
Door_C10_1C:
	dc $00C0,$0648	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$05F8	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_Mountain		; 16x16 Blocks
	dw ActGroup_C10_Room10		; Actor Setup code
Door_C10_1B:
	dc $01B0,$0D78	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0D18	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C10_Room1D		; Actor Setup code
Door_C10_1D:
	dc $01A0,$0BD8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0160,$0B50	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_Mountain		; 16x16 Blocks
	dw ActGroup_C10_Room10		; Actor Setup code
