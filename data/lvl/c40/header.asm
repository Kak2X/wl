	dp GFX_Level_SkyCastle	; Main GFX
	dw GFX_LevelShared_05	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_00	; Animated tiles GFX
	dlvl LevelLayoutPtr_C40	; Level Layout ID	
	dw LevelBlock_SkyCastle	; 16x16 Blocks 
	db $01,$D0	; Player X
	db $00,$38	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db OBJLST_XFLIP	; OBJLst Flags (Face Right)
	db $01,$60	; Scroll Y
	db $00,$00	; Scroll X
	db DIR_L		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C40_Room10	; Actor Setup code
