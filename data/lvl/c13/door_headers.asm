Door_C13_06:
	dc $0140,$0858	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $00E0,$0808	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C13_Room18		; Actor Setup code
Door_C13_18:
	dc $00C0,$0648	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$05F8	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C13_Room10		; Actor Setup code
Door_C13_16:
	dc $01A0,$0A88	; Player pos (Y / X)
	db $08			; Scroll lock
	dc $0150,$0A28	; Scroll pos (Y / X)
	db $10			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C13_Room1A		; Actor Setup code
Door_C13_1A:
	dc $01E0,$0678	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0628	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C13_Room10		; Actor Setup code
Door_C13_0C:
	dc $01D0,$0938	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0900	; Scroll pos (Y / X)
	db $FF			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_MtTeapotBoss		; Main GFX
	dw GFX_LevelShared_09		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_09		; Animated tiles GFX
	dw LevelBlock_Boss0		; 16x16 Blocks
	dw ActGroup_C13_Room19		; Actor Setup code
