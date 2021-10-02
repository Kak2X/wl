	dp GFX_Level_Cave	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_05	; Animated tiles GFX
	dlvl LevelLayoutPtr_C04	; Level Layout ID	
	dw LevelBlock_Cave	; 16x16 Blocks 
	db $01,$70	; Player X
	db $00,$38	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db OBJLST_XFLIP	; OBJLst Flags (Face Right)
	db $00,$E0	; Scroll Y
	db $00,$00	; Scroll X
	db DIR_L		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C04_Room10	; Actor Setup code
