Door_C30_11:
	dc $00E0,$0158	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0100	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C30_Room01		; Actor Setup code
Door_C30_01:
	dc $01E0,$0158	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$00F8	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C30_Room10		; Actor Setup code
Door_C30_13:
	dc $00E0,$0378	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0318	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C30_Room01		; Actor Setup code
Door_C30_03:
	dc $01E0,$0378	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0318	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C30_Room10		; Actor Setup code
Door_C30_14:
	dc $01E0,$0558	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0500	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C30_Room15		; Actor Setup code
Door_C30_15:
	dc $01E0,$0478	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0418	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C30_Room10		; Actor Setup code
Door_C30_05:
	dc $01B0,$0658	; Player pos (Y / X)
	db $0A			; Scroll lock
	dc $0150,$0600	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C30_Room16		; Actor Setup code
Door_C30_16:
	dc $00E0,$05A8	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0548	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C30_Room15		; Actor Setup code
Door_C30_18:
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
	dw ActGroup_TreasureK		; Actor Setup code
Door_C30_04:
	dc $01B0,$0888	; Player pos (Y / X)
	db $08			; Scroll lock
	dc $0150,$0828	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C30_Room16		; Actor Setup code
Door_C30_08:
	dc $01B0,$0B88	; Player pos (Y / X)
	db $08			; Scroll lock
	dc $0150,$0B28	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Tree		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Tree		; 16x16 Blocks
	dw ActGroup_C30_Room1B		; Actor Setup code
Door_C30_1B:
	dc $00A0,$0888	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0050,$0828	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C30_Room16		; Actor Setup code
Door_C30_0B:
	dc $00E0,$0028	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0000	; Scroll pos (Y / X)
	db LVLSCROLL_NONE	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E4			; Palette
	dp GFX_Level_SSTeacupBoss		; Main GFX
	dw GFX_LevelShared_0E		; Shared Block GFX
	dw GFX_StatusBar_00		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Boss1		; 16x16 Blocks
	dw ActGroup_C30_Room00		; Actor Setup code
