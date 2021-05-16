	dp GFX_Level_Train	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_07	; Animated tiles GFX
	db $0A,$01	; Level Layout ID	
	dw LevelBlock_Train	; 16x16 Blocks 
	db $00,$E0	; Player X
	db $01,$D8	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $00		; OBJLst Flags
	db $00,$60	; Scroll Y
	db $01,$50	; Scroll X
	db $01		; Screen Lock Flags
	db $00		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C33_Room00	; Actor Setup code
