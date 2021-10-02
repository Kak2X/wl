Door_C09_12:
	dc $01A0,$0358	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0308	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C09_Room13		; Actor Setup code
Door_C09_13:
	dc $01C0,$02C8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0160,$0250	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $01			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_MountainCave		; 16x16 Blocks
	dw ActGroup_C09_Room10		; Actor Setup code
Door_C09_02:
	dc $00B0,$0378	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0328	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C09_Room13		; Actor Setup code
Door_C09_03:
	dc $00D0,$02C8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0060,$0250	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $01			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_MountainCave		; 16x16 Blocks
	dw ActGroup_C09_Room02		; Actor Setup code
Door_C09_00:
	dc $01E0,$0468	; Player pos (Y / X)
	db $08			; Scroll lock
	dc $0150,$0408	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C09_Room14		; Actor Setup code
Door_C09_14:
	dc $00D0,$0048	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0000	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $01			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_MountainCave		; 16x16 Blocks
	dw ActGroup_C09_Room02		; Actor Setup code
Door_C09_04:
	dc $01D0,$0658	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0608	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $01			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_MountainCave		; 16x16 Blocks
	dw ActGroup_C09_Room16		; Actor Setup code
Door_C09_16:
	dc $0040,$0458	; Player pos (Y / X)
	db $06			; Scroll lock
	dc $0000,$0400	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C09_Room14		; Actor Setup code
Door_C09_18:
	dc $01A0,$0968	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0918	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCastle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCastle		; 16x16 Blocks
	dw ActGroup_C09_Room19		; Actor Setup code
Door_C09_19:
	dc $01D0,$08B8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0160,$0850	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $01			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_MountainCave		; 16x16 Blocks
	dw ActGroup_C09_Room16		; Actor Setup code
Door_C09_01:
	dc $01E0,$0568	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0518	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C09_Room15		; Actor Setup code
Door_C09_15:
	dc $0090,$0178	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0128	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $01			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_MountainCave		; 16x16 Blocks
	dw ActGroup_C09_Room02		; Actor Setup code
Door_C09_17:
	dc $00E0,$0568	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0518	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C09_Room05		; Actor Setup code
Door_C09_05:
	dc $0190,$0778	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0728	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $01			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Mountain		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_04		; Animated tiles GFX
	dw LevelBlock_MountainCave		; 16x16 Blocks
	dw ActGroup_C09_Room16		; Actor Setup code
Door_C09_06:
	dc $00E0,$0728	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0700	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $63			; Palette
	dp GFX_Level_Treasure		; Main GFX
	dw GFX_LevelShared_07		; Shared Block GFX
	dw GFX_StatusBar_03		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Treasure		; 16x16 Blocks
	dw ActGroup_TreasureB		; Actor Setup code
Door_C09_07:
	dc $00E0,$0668	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0608	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C09_Room05		; Actor Setup code
