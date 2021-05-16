	dp GFX_Level_Cave	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_05	; Animated tiles GFX
	db $16,$03	; Level Layout ID	
	dw LevelBlock_Cave	; 16x16 Blocks 
	db $00,$E0	; Player X
	db $00,$98	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $00		; OBJLst Flags
	db $00,$60	; Scroll Y
	db $00,$38	; Scroll X
	db $00		; Screen Lock Flags
	db $00		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C22_Room00	; Actor Setup code
