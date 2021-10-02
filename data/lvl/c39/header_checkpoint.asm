	dp GFX_Level_DarkCastle	; Main GFX
	dw GFX_LevelShared_01	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_02	; Animated tiles GFX
	dlvl LevelLayoutPtr_C39	; Level Layout ID	
	dw LevelBlock_DarkCastle	; 16x16 Blocks 
	db $00,$E0	; Player X
	db $02,$D8	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $00		; OBJLst Flags (Face Left)
	db $00,$60	; Scroll Y
	db $02,$50	; Scroll X
	db DIR_R		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C39_Room02	; Actor Setup code
