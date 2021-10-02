Door_C29_11:
	dc $01E0,$0238	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0200	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C29_Room12		; Actor Setup code
Door_C29_12:
	dc $01D0,$01C8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0160,$0150	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C29_Room10		; Actor Setup code
Door_C29_04:
	dc $00B0,$07B8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0060,$0750	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C29_Room07		; Actor Setup code
Door_C29_07:
	dc $00B0,$04B8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0060,$0450	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C29_Room12		; Actor Setup code
Door_C29_16:
	dc $0150,$0368	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0310	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C29_Room12		; Actor Setup code
Door_C29_05:
	dc $01E0,$0858	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0800	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C29_Room18		; Actor Setup code
Door_C29_18:
	dc $00B0,$0548	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0500	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C29_Room07		; Actor Setup code
Door_C29_1B:
	dc $01E0,$0C58	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0C00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C29_Room1C		; Actor Setup code
Door_C29_1C:
	dc $0160,$0B78	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0B20	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C29_Room18		; Actor Setup code
Door_C29_03:
	dc $00E0,$0C38	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0C00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C29_Room0C		; Actor Setup code
Door_C29_0C:
	dc $00E0,$03B8	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0360	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C29_Room12		; Actor Setup code
Door_C29_17:
	dc $00F0,$0D58	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0D00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Castle2		; 16x16 Blocks
	dw ActGroup_C29_Room0D		; Actor Setup code
Door_C29_0D:
	dc $01C0,$0758	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0700	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C29_Room07		; Actor Setup code
Door_C29_19:
	dc $0160,$0F48	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $00E0,$0F00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C29_Room1F		; Actor Setup code
Door_C29_1F:
	dc $0160,$0978	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0920	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C29_Room18		; Actor Setup code
Door_C29_1A:
	dc $01F0,$0E48	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0E00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_Castle		; 16x16 Blocks
	dw ActGroup_C29_Room1E		; Actor Setup code
Door_C29_1E:
	dc $0160,$0A78	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0A20	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C29_Room18		; Actor Setup code
Door_C29_02:
	dc $00E0,$0128	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0100	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $63			; Palette
	dp GFX_Level_Treasure		; Main GFX
	dw GFX_LevelShared_07		; Shared Block GFX
	dw GFX_StatusBar_03		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Treasure		; 16x16 Blocks
	dw ActGroup_TreasureJ		; Actor Setup code
Door_C29_01:
	dc $00E0,$02B8	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0258	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ship		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Ship		; 16x16 Blocks
	dw ActGroup_C29_Room12		; Actor Setup code
