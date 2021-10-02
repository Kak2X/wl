Door_C26_13:
	dc $01E0,$0448	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0400	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C26_Room14		; Actor Setup code
Door_C26_14:
	dc $01E0,$03D8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0160,$0350	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Forest		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0C		; Animated tiles GFX
	dw LevelBlock_Forest		; 16x16 Blocks
	dw ActGroup_C26_Room10		; Actor Setup code
Door_C26_15:
	dc $01E0,$0628	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0160,$0600	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_WaterCave		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_06		; Animated tiles GFX
	dw LevelBlock_WaterCave		; 16x16 Blocks
	dw ActGroup_C26_Room16		; Actor Setup code
Door_C26_16:
	dc $01E0,$05B8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0160,$0550	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C26_Room14		; Actor Setup code
Door_C26_05:
	dc $00E0,$0628	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0600	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Forest		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0C		; Animated tiles GFX
	dw LevelBlock_Forest		; 16x16 Blocks
	dw ActGroup_C26_Room06		; Actor Setup code
Door_C26_06:
	dc $00E0,$0588	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0530	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C26_Room14		; Actor Setup code
Door_C26_07:
	dc $01F0,$0C98	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0C40	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C26_Room1C		; Actor Setup code
Door_C26_1C:
	dc $00E0,$07D8	; Player pos (Y / X)
	db DIR_R		; Scroll lock
	dc $0060,$0750	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $0F			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Forest		; Main GFX
	dw GFX_LevelShared_00		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0C		; Animated tiles GFX
	dw LevelBlock_Forest		; 16x16 Blocks
	dw ActGroup_C26_Room06		; Actor Setup code
Door_C26_1E:
	dc $0170,$0AA8	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0120,$0A48	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C26_Room1C		; Actor Setup code
Door_C26_1A:
	dc $01B0,$0E68	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0E10	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C26_Room1C		; Actor Setup code
Door_C26_1B:
	dc $00E0,$0878	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0820	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C26_Room1C		; Actor Setup code
Door_C26_08:
	dc $0170,$0B58	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0120,$0AF8	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C26_Room1C		; Actor Setup code
Door_C26_0B:
	dc $00E0,$0988	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0060,$0930	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C26_Room1C		; Actor Setup code
Door_C26_09:
	dc $0070,$0B58	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0020,$0AF8	; Scroll pos (Y / X)
	db LVLSCROLL_FREE	; Scroll mode
	db $00			; BG Priority
	db $07			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_Train		; Main GFX
	dw GFX_LevelShared_02		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_08		; Animated tiles GFX
	dw LevelBlock_Train		; 16x16 Blocks
	dw ActGroup_C26_Room1C		; Actor Setup code
Door_C26_1D:
	dc $00E0,$0C28	; Player pos (Y / X)
	db DIR_L		; Scroll lock
	dc $0060,$0C00	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $63			; Palette
	dp GFX_Level_Treasure		; Main GFX
	dw GFX_LevelShared_07		; Shared Block GFX
	dw GFX_StatusBar_03		; Status Bar GFX
	dw GFX_LevelAnim_0F		; Animated tiles GFX
	dw LevelBlock_Treasure		; 16x16 Blocks
	dw ActGroup_TreasureI		; Actor Setup code
Door_C26_0C:
	dc $01C0,$0D78	; Player pos (Y / X)
	db DIR_NONE		; Scroll lock
	dc $0160,$0D20	; Scroll pos (Y / X)
	db LVLSCROLL_SEGSCRL	; Scroll mode
	db $00			; BG Priority
	db $00			; Tile animation speed
	db $E1			; Palette
	dp GFX_Level_StoneCave		; Main GFX
	dw GFX_LevelShared_03		; Shared Block GFX
	dw GFX_StatusBar_01		; Status Bar GFX
	dw GFX_LevelAnim_0D		; Animated tiles GFX
	dw LevelBlock_StoneCave		; 16x16 Blocks
	dw ActGroup_C26_Room1C		; Actor Setup code
