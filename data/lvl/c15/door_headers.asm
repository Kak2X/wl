Door_C15_11:
	dc $00E0,$0258	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0200	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C15_Room02		; Actor Setup code
Door_C15_02:
	dc $01E0,$01A8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0160,$0150	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C15_Room11		; Actor Setup code
Door_C15_15:
	dc $01E0,$0638	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0160,$0600	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCastle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCastle		; 16x16 Blocks
	dw ActGroup_C15_Room16		; Actor Setup code
Door_C15_16:
	dc $01E0,$05B8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0160,$0550	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C15_Room02		; Actor Setup code
Door_C15_17:
	dc $01E0,$0858	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0160,$0800	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C15_Room18		; Actor Setup code
Door_C15_18:
	dc $01E0,$0758	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0700	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCastle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCastle		; 16x16 Blocks
	dw ActGroup_C15_Room16		; Actor Setup code
Door_C15_1D:
	dc $00E0,$0D48	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0D00	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCastle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCastle		; 16x16 Blocks
	dw ActGroup_C15_Room18		; Actor Setup code
Door_C15_0D:
	dc $01E0,$0D58	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0D00	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C15_Room18		; Actor Setup code
Door_C15_08:
	dc $00E0,$0A78	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0A20	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C15_Room0A		; Actor Setup code
Door_C15_0A:
	dc $00E0,$0898	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0840	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C15_Room18		; Actor Setup code
Door_C15_0B:
	dc $00A0,$0558	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0500	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C15_Room05		; Actor Setup code
Door_C15_05:
	dc $00E0,$0B88	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0B30	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C15_Room0A		; Actor Setup code
Door_C15_07:
	dc $00E0,$0C38	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0060,$0C00	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCastle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_StoneCastle		; 16x16 Blocks
	dw ActGroup_C15_Room05		; Actor Setup code
Door_C15_0C:
	dc $00A0,$0778	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0720	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C15_Room05		; Actor Setup code
