Door_C38_11:
	dc $00E0,$0878	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0818	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_Castle		; 16x16 Blocks
	dw ActGroup_C38_Room08		; Actor Setup code
Door_C38_08:
	dc $0160,$01B8	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $00E0,$0158	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C38_Room10		; Actor Setup code
Door_C38_12:
	dc $00E0,$0458	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0400	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Castle2		; 16x16 Blocks
	dw ActGroup_C38_Room04		; Actor Setup code
Door_C38_04:
	dc $01E0,$0278	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0218	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C38_Room10		; Actor Setup code
Door_C38_05:
	dc $01D0,$0E48	; Player pos (Y / X)
	db $08			; Scroll lock
	dc $0150,$0DE8	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C38_Room1E		; Actor Setup code
Door_C38_1E:
	dc $00E0,$05A8	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0548	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Castle2		; 16x16 Blocks
	dw ActGroup_C38_Room04		; Actor Setup code
Door_C38_0E:
	dc $00E0,$0668	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0608	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_Castle		; 16x16 Blocks
	dw ActGroup_C38_Room06		; Actor Setup code
Door_C38_06:
	dc $0060,$0EC8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0010,$0E50	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C38_Room1E		; Actor Setup code
Door_C38_07:
	dc $01E0,$0448	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0160,$0400	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C38_Room14		; Actor Setup code
Door_C38_14:
	dc $00E0,$0798	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0738	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_Castle		; 16x16 Blocks
	dw ActGroup_C38_Room06		; Actor Setup code
Door_C38_18:
	dc $00E0,$0A68	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0A08	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Castle2		; 16x16 Blocks
	dw ActGroup_C38_Room0A		; Actor Setup code
Door_C38_0A:
	dc $01E0,$08A8	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0848	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C38_Room14		; Actor Setup code
Door_C38_0B:
	dc $01E0,$0938	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0160,$0900	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C38_Room19		; Actor Setup code
Door_C38_19:
	dc $00E0,$0B98	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0B38	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Castle2		; 16x16 Blocks
	dw ActGroup_C38_Room0A		; Actor Setup code
Door_C38_09:
	dc $01E0,$0A58	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0160,$0A00	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_Castle		; 16x16 Blocks
	dw ActGroup_C38_Room1A		; Actor Setup code
Door_C38_1A:
	dc $00B0,$09D8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0060,$0950	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C38_Room19		; Actor Setup code
Door_C38_0D:
	dc $01E0,$0C68	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0C08	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_Castle		; 16x16 Blocks
	dw ActGroup_C38_Room1C		; Actor Setup code
Door_C38_1C:
	dc $0060,$0DA8	; Player pos (Y / X)
	db $04			; Scroll lock
	dc $0000,$0D48	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_DarkCastle		; Main GFX
	dw GFX_LevelShared_01		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_02		; Animated tiles GFX
	dw LevelBlock_DarkCastle		; 16x16 Blocks
	dw ActGroup_C38_Room1E		; Actor Setup code
