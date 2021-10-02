Door_C18_11:
	dc $00E0,$0028	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0000	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $63			; Palette
	dp GFX_Level_Treasure		; Main GFX
	dw GFX_LevelShared_07		; Shared Block GFX
	dw GFX_StatusBar_03		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Treasure		; 16x16 Blocks
	dw ActGroup_TreasureF		; Actor Setup code
Door_C18_00:
	dc $01E0,$0178	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0128	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C18_Room10		; Actor Setup code
Door_C18_12:
	dc $00E0,$0C88	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0C38	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C18_Room0C		; Actor Setup code
Door_C18_0C:
	dc $01E0,$0288	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0238	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C18_Room10		; Actor Setup code
Door_C18_13:
	dc $00E0,$0D78	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0D28	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C18_Room0C		; Actor Setup code
Door_C18_0D:
	dc $01E0,$0378	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0328	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C18_Room10		; Actor Setup code
Door_C18_14:
	dc $01E0,$0C48	; Player pos (Y / X)
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
	dw ActGroup_C18_Room1C		; Actor Setup code
Door_C18_1C:
	dc $0140,$0478	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0428	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C18_Room10		; Actor Setup code
Door_C18_1D:
	dc $0070,$0EA8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0020,$0E50	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C18_Room0E		; Actor Setup code
Door_C18_0E:
	dc $01E0,$0DC8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0160,$0D50	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C18_Room1C		; Actor Setup code
Door_C18_1E:
	dc $01E0,$0F78	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0F28	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Castle		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Castle2		; 16x16 Blocks
	dw ActGroup_C18_Room1F		; Actor Setup code
Door_C18_1F:
	dc $01B0,$0E88	; Player pos (Y / X)
	db $08			; Scroll lock
	dc $0150,$0E28	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C18_Room0E		; Actor Setup code
Door_C18_17:
	dc $00E0,$0758	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0708	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C18_Room07		; Actor Setup code
Door_C18_07:
	dc $01B0,$0778	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0728	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C18_Room10		; Actor Setup code
Door_C18_1B:
	dc $00E0,$0A98	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0A48	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Cave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Cave		; 16x16 Blocks
	dw ActGroup_C18_Room0A		; Actor Setup code
Door_C18_0A:
	dc $01E0,$0BC8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0160,$0B50	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Ice		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0A		; Animated tiles GFX
	dw LevelBlock_Ice		; 16x16 Blocks
	dw ActGroup_C18_Room10		; Actor Setup code
