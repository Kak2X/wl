	dp GFX_Level_StoneCastle	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_0B	; Animated tiles GFX
	dlvl LevelLayoutPtr_C05	; Level Layout ID	
	dw LevelBlock_StoneCastle	; 16x16 Blocks 
	db $01,$E0	; Player Y
	db $07,$98	; Player X
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $00		; OBJLst Flags (Face Left)
	db $01,$60	; Scroll Y
	db $07,$38	; Scroll X
	db DIR_NONE		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C05_Room16	; Actor Setup code
