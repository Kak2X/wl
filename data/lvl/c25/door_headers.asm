Door_C25_15:
	dc $01E0,$0D48	; Player pos (Y / X)
	db $02			; Scroll lock
	dc $0160,$0D00	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C25_Room1D		; Actor Setup code
Door_C25_1D:
	dc $01D0,$05A8	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0548	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E4			; Palette
	dp GFX_Level_Lava		; Main GFX
	dw GFX_LevelShared_04		; Shared Block GFX
	dw GFX_StatusBar_00		; Status Bar GFX
	dw GFX_LevelAnim_09		; Animated tiles GFX
	dw LevelBlock_Lava		; 16x16 Blocks
	dw ActGroup_C25_Room10		; Actor Setup code
Door_C25_1C:
	dc $00E0,$0028	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0000	; Scroll pos (Y / X)
	db $FF			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $D2			; Palette
	dp GFX_Level_StoveCanyonBoss		; Main GFX
	dw GFX_LevelShared_0D		; Shared Block GFX
	dw GFX_StatusBar_02		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Boss1		; 16x16 Blocks
	dw ActGroup_C25_Room00		; Actor Setup code
