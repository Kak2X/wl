Door_C36_15:
	dc $00E0,$0248	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0200	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C36_Room02		; Actor Setup code
Door_C36_02:
	dc $01C0,$0568	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0508	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Forest		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0C		; Animated tiles GFX
	dw LevelBlock_Forest		; 16x16 Blocks
	dw ActGroup_C36_Room10		; Actor Setup code
Door_C36_16:
	dc $00E0,$0168	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0108	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C36_Room01		; Actor Setup code
Door_C36_01:
	dc $01E0,$06A8	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0648	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Forest		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0C		; Animated tiles GFX
	dw LevelBlock_Forest		; 16x16 Blocks
	dw ActGroup_C36_Room10		; Actor Setup code
Door_C36_1F:
	dc $00F0,$0028	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0000	; Scroll pos (Y / X)
	db $FF			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_ParsleyWoodsBoss		; Main GFX
	dw GFX_LevelShared_0C		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Boss1		; 16x16 Blocks
	dw ActGroup_C36_Room00		; Actor Setup code
