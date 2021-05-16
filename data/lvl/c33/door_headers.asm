Door_C33_00:
	dc $00E0,$03C8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0060,$0350	; Scroll pos (Y / X)
	db $01			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_07		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C33_Room03		; Actor Setup code
Door_C33_02:
	dc $01E0,$05B8	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0550	; Scroll pos (Y / X)
	db $31			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0F		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C33_Room15		; Actor Setup code
Door_C33_10:
	dc $00E0,$05A8	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0060,$0548	; Scroll pos (Y / X)
	db $01			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_07		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C33_Room04		; Actor Setup code
Door_C33_04:
	dc $01E0,$0BB8	; Player pos (Y / X)
	db $00			; Scroll lock
	dc $0160,$0B50	; Scroll pos (Y / X)
	db $31			; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0F		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C33_Room16		; Actor Setup code
Door_C33_16:
	dc $00F0,$07C8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0060,$0750	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_07		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C33_Room06		; Actor Setup code
Door_C33_06:
	dc $00D0,$09D8	; Player pos (Y / X)
	db $01			; Scroll lock
	dc $0060,$0950	; Scroll pos (Y / X)
	db $00			; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_07		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C33_Room08		; Actor Setup code
