Door_C08_14:
	dc $01D0,$0688	; Player pos (Y / X)
	db $08			; Scroll lock
	dc $0150,$0628	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C08_Room16		; Actor Setup code
Door_C08_16:
	dc $01F0,$04B8	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0458	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_WaterCave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_06		; Animated tiles GFX
	dw LevelBlock_WaterCave		; 16x16 Blocks
	dw ActGroup_C08_Room10		; Actor Setup code
Door_C08_06:
	dc $01A0,$0738	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0160,$0700	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $01			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_MountainCave		; 16x16 Blocks
	dw ActGroup_C08_Room17		; Actor Setup code
Door_C08_17:
	dc $0050,$0668	; Player pos (Y / X)
	db $04			; Scroll lock
	dc $0000,$0608	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C08_Room16		; Actor Setup code
Door_C08_19:
	dc $01D0,$0A38	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0160,$0A00	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_WaterCave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_06		; Animated tiles GFX
	dw LevelBlock_WaterCave		; 16x16 Blocks
	dw ActGroup_C08_Room1A		; Actor Setup code
Door_C08_1A:
	dc $01D0,$0998	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0938	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $01			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_MountainCave		; 16x16 Blocks
	dw ActGroup_C08_Room17		; Actor Setup code
Door_C08_1C:
	dc $0170,$0D68	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $00E0,$0D08	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C08_Room1D		; Actor Setup code
Door_C08_1D:
	dc $01D0,$0CE8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0160,$0C50	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_WaterCave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_06		; Animated tiles GFX
	dw LevelBlock_WaterCave		; 16x16 Blocks
	dw ActGroup_C08_Room1A		; Actor Setup code
