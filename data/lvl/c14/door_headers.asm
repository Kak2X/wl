Door_C14_16:
	dc $00E0,$0078	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0028	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C14_Room00		; Actor Setup code
Door_C14_00:
	dc $01E0,$0658	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0608	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_SkyCastle		; Main GFX
	dw GFX_LevelShared_05		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_SkyCastle		; 16x16 Blocks
	dw ActGroup_C14_Room10		; Actor Setup code
Door_C14_1E:
	dc $00E0,$0158	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0108	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C14_Room01		; Actor Setup code
Door_C14_01:
	dc $01E0,$0EA8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0160,$0E50	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_SkyCastle		; Main GFX
	dw GFX_LevelShared_05		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_SkyCastle		; 16x16 Blocks
	dw ActGroup_C14_Room10		; Actor Setup code
