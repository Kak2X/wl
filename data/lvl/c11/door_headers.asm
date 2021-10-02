Door_C11_11:
	dc $01A0,$0648	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0600	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $01			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_MountainCave		; 16x16 Blocks
	dw ActGroup_C11_Room16		; Actor Setup code
Door_C11_16:
	dc $0180,$0138	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0130,$00D8	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C11_Room00		; Actor Setup code
Door_C11_17:
	dc $0050,$0258	; Player pos (Y / X)
	db $06			; Scroll lock
	dc $0000,$0200	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C11_Room02		; Actor Setup code
Door_C11_02:
	dc $01A0,$07B8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0160,$0750	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $01			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_MountainCave		; 16x16 Blocks
	dw ActGroup_C11_Room16		; Actor Setup code
Door_C11_03:
	dc $00E0,$0428	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0400	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $63			; Palette
	dp GFX_Level_Treasure		; Main GFX
	dw GFX_LevelShared_07		; Shared Block GFX
	dw GFX_StatusBar_03		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Treasure		; 16x16 Blocks
	dw ActGroup_TreasureC		; Actor Setup code
Door_C11_04:
	dc $0070,$0388	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0020,$0328	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C11_Room02		; Actor Setup code
Door_C11_13:
	dc $01E0,$0478	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0418	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $1F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Sand		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Sand		; 16x16 Blocks
	dw ActGroup_C11_Room14		; Actor Setup code
Door_C11_14:
	dc $01E0,$0318	; Player pos (Y / X)
	db $08			; Scroll lock
	dc $0150,$02B8	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C11_Room02		; Actor Setup code
Door_C11_15:
	dc $01E0,$0958	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0900	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C11_Room19		; Actor Setup code
Door_C11_19:
	dc $01E0,$0588	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0528	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $1F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Sand		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Sand		; 16x16 Blocks
	dw ActGroup_C11_Room14		; Actor Setup code
Door_C11_1B:
	dc $00B0,$0868	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0808	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C11_Room08		; Actor Setup code
Door_C11_08:
	dc $01E0,$0BA8	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0B48	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C11_Room19		; Actor Setup code
Door_C11_18:
	dc $00E0,$0638	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0600	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E4			; Palette
	dp GFX_Level_Lava		; Main GFX
	dw GFX_LevelShared_04		; Shared Block GFX
	dw GFX_StatusBar_00		; Status Bar GFX
	dw GFX_LevelAnim_09		; Animated tiles GFX
	dw LevelBlock_Lava		; 16x16 Blocks
	dw ActGroup_C11_Room06		; Actor Setup code
Door_C11_06:
	dc $01D0,$0848	; Player pos (Y / X)
	db $0A			; Scroll lock
	dc $0150,$0800	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_05		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C11_Room08		; Actor Setup code
