	dp GFX_Level_StoneCave	; Main GFX
	dw GFX_LevelShared_03	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_08	; Animated tiles GFX
	dlvl LevelLayoutPtr_C02	; Level Layout ID	
	dw LevelBlock_StoneCave	; 16x16 Blocks 
	db $01,$60	; Player X
	db $0F,$98	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $00		; OBJLst Flags (Face Left)
	db $00,$E0	; Scroll Y
	db $0F,$40	; Scroll X
	db DIR_NONE		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C02_Room0D	; Actor Setup code
