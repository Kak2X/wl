Door_C02_13:
	dc $00E0,$0D48	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0D00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C02_Room0D		; Actor Setup code
Door_C02_0D:
	dc $0190,$0388	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0330	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $1F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Sand		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Sand		; 16x16 Blocks
	dw ActGroup_C02_Room10		; Actor Setup code
Door_C02_1F:
	dc $01E0,$0668	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0610	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $1F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Sand		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Sand		; 16x16 Blocks
	dw ActGroup_C02_Room10		; Actor Setup code
Door_C02_16:
	dc $0160,$0F68	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0F20	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C02_Room0D		; Actor Setup code
Door_C02_15:
	dc $00B0,$0068	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0010	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C02_Room00		; Actor Setup code
Door_C02_00:
	dc $0160,$0568	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0510	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $1F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Sand		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Sand		; 16x16 Blocks
	dw ActGroup_C02_Room10		; Actor Setup code
Door_C02_03:
	dc $0130,$0878	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $00E0,$0820	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $1F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Sand		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Sand		; 16x16 Blocks
	dw ActGroup_C02_Room10		; Actor Setup code
Door_C02_18:
	dc $00E0,$0378	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0320	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C02_Room00		; Actor Setup code
Door_C02_1C:
	dc $00E0,$0648	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0600	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCastle		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0B		; Animated tiles GFX
	dw LevelBlock_StoneCastle		; 16x16 Blocks
	dw ActGroup_C02_Room06		; Actor Setup code
Door_C02_06:
	dc $01E0,$0CC8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0160,$0C50	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $1F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Sand		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_00		; Animated tiles GFX
	dw LevelBlock_Sand		; 16x16 Blocks
	dw ActGroup_C02_Room10		; Actor Setup code
