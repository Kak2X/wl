	dp GFX_Level_WaterCave	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_06	; Animated tiles GFX
	dlvl LevelLayoutPtr_C08	; Level Layout ID	
	dw LevelBlock_WaterCave	; 16x16 Blocks 
	db $01,$C0	; Player Y
	db $00,$38	; Player X
	db OBJ_WARIO_STAND ; OBJLst Frame
	db OBJLST_XFLIP	; OBJLst Flags (Face Right)
	db $01,$60	; Scroll Y
	db $00,$00	; Scroll X
	db DIR_L		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C08_Room10	; Actor Setup code
