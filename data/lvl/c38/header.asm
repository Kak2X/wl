	dp GFX_Level_DarkCastle	; Main GFX
	dw GFX_LevelShared_01	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_02	; Animated tiles GFX
	db $1A,$03	; Level Layout ID	
	dw LevelBlock_DarkCastle	; 16x16 Blocks 
	db $01,$60	; Player X
	db $00,$48	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $20		; OBJLst Flags
	db $00,$E0	; Scroll Y
	db $00,$00	; Scroll X
	db $02		; Screen Lock Flags
	db $00		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C38_Room10	; Actor Setup code
