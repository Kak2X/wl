Door_C40_1C:
	dc $00E0,$0158	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0100	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_Castle		; 16x16 Blocks
	dw ActGroup_C40_Room01		; Actor Setup code
Door_C40_01:
	dc $01D0,$0CB8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0160,$0C50	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_SkyCastle		; Main GFX
	dw GFX_LevelShared_05		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_SkyCastle		; 16x16 Blocks
	dw ActGroup_C40_Room10		; Actor Setup code
Door_C40_02:
	dc $01E0,$0F78	; Player pos (Y / X)
	db $08			; Scroll lock
	dc $0150,$0F18	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C40_Room1F		; Actor Setup code
Door_C40_1F:
	dc $00E0,$02A8	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0248	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_Castle		; 16x16 Blocks
	dw ActGroup_C40_Room01		; Actor Setup code
Door_C40_0F:
	dc $00E0,$0358	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0300	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_Castle		; 16x16 Blocks
	dw ActGroup_C40_Room03		; Actor Setup code
Door_C40_03:
	dc $0050,$0F98	; Player pos (Y / X)
	db $04			; Scroll lock
	dc $0000,$0F38	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C40_Room1F		; Actor Setup code
Door_C40_04:
	dc $00F0,$0038	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0000	; Scroll pos (Y / X)
	db $FF			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_SyrupCastleBoss		; Main GFX
	dw GFX_LevelShared_0F		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_SyrupCastleBoss		; 16x16 Blocks
	dw ActGroup_C40_Room00		; Actor Setup code
Door_C40_17:
	dc $0160,$0D68	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $00E0,$0D08	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C40_Room1D		; Actor Setup code
Door_C40_1D:
	dc $01A0,$0788	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0728	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_SkyCastle		; Main GFX
	dw GFX_LevelShared_05		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_SkyCastle		; 16x16 Blocks
	dw ActGroup_C40_Room10		; Actor Setup code
