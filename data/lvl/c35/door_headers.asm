Door_C35_01:
	dc $00E0,$0838	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0800	; Scroll pos (Y / X)
	db LVLSCROLL_TRAIN	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_07		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C35_Room08		; Actor Setup code
Door_C35_09:
	dc $01E0,$0038	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0000	; Scroll pos (Y / X)
	db LVLSCROLL_AUTOR	; Scroll mode
	db $00			; BG Priority
	db $03			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_07		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C35_Room10		; Actor Setup code
Door_C35_14:
	dc $00E0,$0338	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0300	; Scroll pos (Y / X)
	db LVLSCROLL_TRAIN	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_07		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C35_Room03		; Actor Setup code
Door_C35_05:
	dc $01E0,$0668	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0600	; Scroll pos (Y / X)
	db LVLSCROLL_AUTOR	; Scroll mode
	db $00			; BG Priority
	db $03			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_07		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C35_Room16		; Actor Setup code
Door_C35_1F:
	dc $00E0,$0A38	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0A00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_07		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C35_Room0A		; Actor Setup code
Door_C35_0B:
	dc $00E0,$0638	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0600	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_07		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C35_Room06		; Actor Setup code
