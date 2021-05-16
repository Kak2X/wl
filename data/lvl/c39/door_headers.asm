Door_C39_16:
	dc $00E0,$0058	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0008	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_Castle2		; 16x16 Blocks
	dw ActGroup_C39_Room00		; Actor Setup code
Door_C39_00:
	dc $01E0,$06A8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0160,$0650	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_SkyCastle		; Main GFX
	dw GFX_LevelShared_05		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_SkyCastle		; 16x16 Blocks
	dw ActGroup_C39_Room10		; Actor Setup code
Door_C39_01:
	dc $01E0,$0938	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0160,$0900	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_SkyCastle		; Main GFX
	dw GFX_LevelShared_05		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_SkyCastle		; 16x16 Blocks
	dw ActGroup_C39_Room19		; Actor Setup code
Door_C39_19:
	dc $00E0,$01B8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0060,$0150	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_Castle2		; 16x16 Blocks
	dw ActGroup_C39_Room00		; Actor Setup code
Door_C39_1A:
	dc $00E0,$0248	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0200	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C39_Room02		; Actor Setup code
Door_C39_02:
	dc $01E0,$0A58	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0A08	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_SkyCastle		; Main GFX
	dw GFX_LevelShared_05		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_SkyCastle		; 16x16 Blocks
	dw ActGroup_C39_Room19		; Actor Setup code
Door_C39_1D:
	dc $0130,$0848	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $00E0,$07E8	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_Castle2		; 16x16 Blocks
	dw ActGroup_C39_Room18		; Actor Setup code
Door_C39_18:
	dc $0160,$0D98	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $00E0,$0D48	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_SkyCastle		; Main GFX
	dw GFX_LevelShared_05		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_SkyCastle		; 16x16 Blocks
	dw ActGroup_C39_Room19		; Actor Setup code
Door_C39_07:
	dc $00E0,$0F28	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0F00	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $63			; Palette
	dp GFX_Level_Treasure		; Main GFX
	dw GFX_LevelShared_07		; Shared Block GFX
	dw GFX_StatusBar_03		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Treasure		; 16x16 Blocks
	dw ActGroup_TreasureO		; Actor Setup code
Door_C39_0F:
	dc $0070,$0748	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0020,$0700	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_Castle2		; 16x16 Blocks
	dw ActGroup_C39_Room18		; Actor Setup code
Door_C39_0D:
	dc $01E0,$0F68	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0F18	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Castle		; 16x16 Blocks
	dw ActGroup_C39_Room1F		; Actor Setup code
Door_C39_Unused_1F:
	; [TCRF] Unused exit in the ! Block Room of C39
	dc $00E0,$0D78	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0D28	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_SkyCastle		; Main GFX
	dw GFX_LevelShared_05		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_SkyCastle		; 16x16 Blocks
	dw ActGroup_C39_Room0C		; Actor Setup code
Door_C39_1E:
	dc $00E0,$0358	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0308	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Castle		; 16x16 Blocks
	dw ActGroup_C39_Room03		; Actor Setup code
Door_C39_03:
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
	dw ActGroup_C39_Room19		; Actor Setup code
Door_C39_06:
	dc $00E0,$0C88	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0C38	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_SkyCastle		; Main GFX
	dw GFX_LevelShared_05		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_SkyCastle		; 16x16 Blocks
	dw ActGroup_C39_Room0C		; Actor Setup code
Door_C39_0C:
	dc $00E0,$0668	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0618	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Castle		; 16x16 Blocks
	dw ActGroup_C39_Room03		; Actor Setup code
