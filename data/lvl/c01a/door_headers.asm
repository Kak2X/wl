Door_C01A_1A:
	dc $01E0,$0C48	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0C00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCastle		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_StoneCastle		; 16x16 Blocks
	dw ActGroup_C01A_Room1C		; Actor Setup code
Door_C01A_1C:
	dc $01F0,$0A88	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0A30	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C01A_Room10		; Actor Setup code
Door_C01A_1B:
	dc $01E0,$0E68	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0E08	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C01A_Room1E		; Actor Setup code
Door_C01A_1E:
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
	dw ActGroup_C01A_Room10		; Actor Setup code
