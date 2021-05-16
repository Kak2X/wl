	dp GFX_Level_Lava	; Main GFX
	dw GFX_LevelShared_04	; Block GFX
	dw GFX_StatusBar_00	; Status Bar GFX
	dw GFX_LevelAnim_09	; Animated tiles GFX
	db $16,$03	; Level Layout ID	
	dw LevelBlock_Lava	; 16x16 Blocks 
	db $01,$E0	; Player X
	db $00,$18	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $20		; OBJLst Flags
	db $01,$60	; Scroll Y
	db $00,$00	; Scroll X
	db $02		; Screen Lock Flags
	db $00		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E4		; BG Palette
	dw ActGroup_C22_Room10	; Actor Setup code
