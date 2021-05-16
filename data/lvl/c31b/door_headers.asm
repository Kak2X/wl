Door_C31B_17:
	dc $0160,$0F98	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $00E0,$0F38	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C31B_Room1F		; Actor Setup code
Door_C31B_1F:
	dc $0160,$07B8	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $00E0,$0758	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Forest		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0C		; Animated tiles GFX
	dw LevelBlock_Forest		; 16x16 Blocks
	dw ActGroup_C31B_Room10		; Actor Setup code
Door_C31B_1C:
	dc $01E0,$0E28	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0160,$0E00	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $63			; Palette
	dp GFX_Level_Treasure		; Main GFX
	dw GFX_LevelShared_07		; Shared Block GFX
	dw GFX_StatusBar_03		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Treasure		; 16x16 Blocks
	dw ActGroup_TreasureL		; Actor Setup code
Door_C31B_1E:
	dc $01E0,$0CB8	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0C58	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Forest		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0C		; Animated tiles GFX
	dw LevelBlock_Forest		; 16x16 Blocks
	dw ActGroup_C31B_Room10		; Actor Setup code