	dp GFX_Level_Train	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_07	; Animated tiles GFX
	db $13,$06	; Level Layout ID	
	dw LevelBlock_Train	; 16x16 Blocks 
	db $00,$B0	; Player X
	db $03,$68	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $20		; OBJLst Flags
	db $00,$60	; Scroll Y
	db $03,$08	; Scroll X
	db $00		; Screen Lock Flags
	db $01		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C35_Room03	; Actor Setup code
