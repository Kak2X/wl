Door_C17_13:
	dc $01E0,$0B98	; Player pos (Y / X)
	db $08			; Scroll lock
	dc $0150,$0B38	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C17_Room0B		; Actor Setup code
Door_C17_1B:
	dc $01E0,$0378	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0318	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C17_Room10		; Actor Setup code
Door_C17_0B:
	dc $01F0,$0E88	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0E28	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCastle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCastle		; 16x16 Blocks
	dw ActGroup_C17_Room1E		; Actor Setup code
Door_C17_1E:
	dc $0050,$0B78	; Player pos (Y / X)
	db $04			; Scroll lock
	dc $0000,$0B18	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C17_Room0B		; Actor Setup code
Door_C17_16:
	dc $01D0,$0C58	; Player pos (Y / X)
	db $0A			; Scroll lock
	dc $0150,$0C00	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C17_Room1C		; Actor Setup code
Door_C17_1C:
	dc $01E0,$0688	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0628	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C17_Room10		; Actor Setup code
Door_C17_19:
	dc $01B0,$0D78	; Player pos (Y / X)
	db $08			; Scroll lock
	dc $0150,$0D18	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C17_Room1E		; Actor Setup code
Door_C17_1D:
	dc $01E0,$0968	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0908	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C17_Room10		; Actor Setup code
Door_C17_0D:
	dc $00E0,$0028	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0000	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $63			; Palette
	dp GFX_Level_Treasure		; Main GFX
	dw GFX_LevelShared_07		; Shared Block GFX
	dw GFX_StatusBar_03		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Treasure		; 16x16 Blocks
	dw ActGroup_TreasureE		; Actor Setup code
Door_C17_00:
	dc $0070,$0D78	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0020,$0D18	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C17_Room1E		; Actor Setup code
Door_C17_1A:
	dc $00E0,$0F38	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0090,$0F00	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C17_Room0F		; Actor Setup code
Door_C17_0F:
	dc $01C0,$0AD8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0160,$0A50	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C17_Room10		; Actor Setup code
Door_C17_1F:
	dc $00E0,$0188	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0128	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C17_Room01		; Actor Setup code
Door_C17_01:
	dc $01E0,$0F58	; Player pos (Y / X)
	db $0A			; Scroll lock
	dc $0150,$0F00	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C17_Room0F		; Actor Setup code
