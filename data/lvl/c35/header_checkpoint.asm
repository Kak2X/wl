	dp GFX_Level_Train	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_07	; Animated tiles GFX
	dlvl LevelLayoutPtr_C35	; Level Layout ID	
	dw LevelBlock_Train	; 16x16 Blocks 
	db $00,$B0	; Player Y
	db $03,$68	; Player X
	db OBJ_WARIO_STAND ; OBJLst Frame
	db OBJLST_XFLIP	; OBJLst Flags (Face Right)
	db $00,$60	; Scroll Y
	db $03,$08	; Scroll X
	db DIR_NONE		; Screen Lock Flags
	db LVLSCROLL_TRAIN	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C35_Room03	; Actor Setup code
