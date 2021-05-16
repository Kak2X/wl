Door_C19_15:
	dc $0060,$06C8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0010,$0650	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C19_Room06		; Actor Setup code
Door_C19_06:
	dc $0150,$0558	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $00E0,$0508	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C19_Room11		; Actor Setup code
Door_C19_16:
	dc $0060,$0738	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0010,$0700	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C19_Room07		; Actor Setup code
Door_C19_07:
	dc $01D0,$0638	; Player pos (Y / X)
	db $0A			; Scroll lock
	dc $0150,$0600	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C19_Room06		; Actor Setup code
Door_C19_0A:
	dc $01E0,$0B68	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0B18	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C19_Room1B		; Actor Setup code
Door_C19_1B:
	dc $0080,$0A78	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0000,$0A18	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C19_Room07		; Actor Setup code
Door_C19_1C:
	dc $00E0,$0028	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0000	; Scroll pos (Y / X)
	db $FF			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_SherbetLandBoss		; Main GFX
	dw GFX_LevelShared_0A		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Boss0		; 16x16 Blocks
	dw ActGroup_C19_Room00		; Actor Setup code
Door_C19_18:
	dc $01E0,$0D58	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0D08	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C19_Room1D		; Actor Setup code
Door_C19_1D:
	dc $0170,$0888	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0120,$0828	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C19_Room07		; Actor Setup code
Door_C19_13:
	dc $01E0,$0E58	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0E08	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C19_Room1E		; Actor Setup code
Door_C19_1E:
	dc $01F0,$0378	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0328	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C19_Room11		; Actor Setup code
