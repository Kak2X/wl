	dp GFX_Level_Train	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_07	; Animated tiles GFX
	dlvl LevelLayoutPtr_C33	; Level Layout ID	
	dw LevelBlock_Train	; 16x16 Blocks 
	db $00,$A0	; Player Y
	db $05,$08	; Player X
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $00		; OBJLst Flags (Face Left)
	db $00,$60	; Scroll Y
	db $04,$A8	; Scroll X
	db DIR_NONE		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C33_Room04	; Actor Setup code
