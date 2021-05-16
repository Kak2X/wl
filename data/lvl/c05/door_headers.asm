Door_C05_11:
	dc $01E0,$0248	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0160,$0200	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C05_Room12		; Actor Setup code
Door_C05_12:
	dc $01E0,$01B8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0160,$0150	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Beach		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Beach		; 16x16 Blocks
	dw ActGroup_C05_Room10		; Actor Setup code
Door_C05_15:
	dc $01E0,$0688	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0630	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCastle		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_StoneCastle		; 16x16 Blocks
	dw ActGroup_C05_Room16		; Actor Setup code
Door_C05_16:
	dc $01D0,$05B8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0160,$0550	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C05_Room12		; Actor Setup code
Door_C05_17:
	dc $01E0,$0858	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0160,$0800	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C05_Room18		; Actor Setup code
Door_C05_18:
	dc $01E0,$0778	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0720	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCastle		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_StoneCastle		; 16x16 Blocks
	dw ActGroup_C05_Room16		; Actor Setup code
Door_C05_1A:
	dc $01E0,$0C58	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0160,$0C00	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCastle		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_StoneCastle		; 16x16 Blocks
	dw ActGroup_C05_Room1C		; Actor Setup code
Door_C05_1C:
	dc $01E0,$0A88	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0A30	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C05_Room18		; Actor Setup code
Door_C05_1B:
	dc $00D0,$0028	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0000	; Scroll pos (Y / X)
	db $FF			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_RiceBeachBoss		; Main GFX
	dw GFX_LevelShared_0B		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0F		; Animated tiles GFX
	dw LevelBlock_Boss0		; 16x16 Blocks
	dw ActGroup_C05_Room00		; Actor Setup code
