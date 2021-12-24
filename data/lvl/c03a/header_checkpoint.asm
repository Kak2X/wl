	dp GFX_Level_WaterCave	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_06	; Animated tiles GFX
	dlvl LevelLayoutPtr_C03A	; Level Layout ID	
	dw LevelBlock_WaterCave	; 16x16 Blocks 
	db $01,$A0	; Player Y
	db $0F,$18	; Player X
	db OBJ_WARIO_STAND ; OBJLst Frame
	db OBJLST_XFLIP	; OBJLst Flags (Face Right)
	db $01,$60	; Scroll Y
	db $0E,$B0	; Scroll X
	db DIR_NONE		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C03A_Room1E	; Actor Setup code
