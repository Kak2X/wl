Door_C37_16:
	dc $0150,$0F68	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $00E0,$0F08	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C37_Room1F		; Actor Setup code
Door_C37_1F:
	dc $01D0,$0678	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0618	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Forest		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0C		; Animated tiles GFX
	dw LevelBlock_Forest		; 16x16 Blocks
	dw ActGroup_C37_Room10		; Actor Setup code
Door_C37_1D:
	dc $00E0,$0C78	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0C18	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C37_Room0C		; Actor Setup code
Door_C37_0C:
	dc $01B0,$0DC8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0160,$0D50	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Forest		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0C		; Animated tiles GFX
	dw LevelBlock_Forest		; 16x16 Blocks
	dw ActGroup_C37_Room10		; Actor Setup code
Door_C37_1E:
	dc $00E0,$0E28	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0E00	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $63			; Palette
	dp GFX_Level_Treasure		; Main GFX
	dw GFX_LevelShared_07		; Shared Block GFX
	dw GFX_StatusBar_03		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Treasure		; 16x16 Blocks
	dw ActGroup_TreasureN		; Actor Setup code
Door_C37_0E:
	dc $01F0,$0E88	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0E28	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Forest		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0C		; Animated tiles GFX
	dw LevelBlock_Forest		; 16x16 Blocks
	dw ActGroup_C37_Room10		; Actor Setup code
