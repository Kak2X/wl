Door_C32_1D:
	dc $00E0,$0E58	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0090,$0E00	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C32_Room0E		; Actor Setup code
Door_C32_0E:
	dc $01D0,$0DD8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0160,$0D50	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C32_Room10		; Actor Setup code
