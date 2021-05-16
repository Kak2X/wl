Door_C22_15:
	dc $00E0,$0058	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0000	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C22_Room00		; Actor Setup code
Door_C22_00:
	dc $01D0,$0568	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0508	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E4			; Palette
	dp GFX_Level_Lava		; Main GFX
	dw GFX_LevelShared_04		; Shared Block GFX
	dw GFX_StatusBar_00		; Status Bar GFX
	dw GFX_LevelAnim_09		; Animated tiles GFX
	dw LevelBlock_Lava		; 16x16 Blocks
	dw ActGroup_C22_Room10		; Actor Setup code
Door_C22_1B:
	dc $00E0,$0158	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0100	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C22_Room01		; Actor Setup code
Door_C22_01:
	dc $01B0,$0BD8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0160,$0B50	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E4			; Palette
	dp GFX_Level_Lava		; Main GFX
	dw GFX_LevelShared_04		; Shared Block GFX
	dw GFX_StatusBar_00		; Status Bar GFX
	dw GFX_LevelAnim_09		; Animated tiles GFX
	dw LevelBlock_Lava		; 16x16 Blocks
	dw ActGroup_C22_Room10		; Actor Setup code
