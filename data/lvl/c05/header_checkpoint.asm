	dp GFX_Level_StoneCastle	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_0B	; Animated tiles GFX
	db $19,$00	; Level Layout ID	
	dw LevelBlock_StoneCastle	; 16x16 Blocks 
	db $01,$E0	; Player X
	db $07,$98	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $00		; OBJLst Flags
	db $01,$60	; Scroll Y
	db $07,$38	; Scroll X
	db $00		; Screen Lock Flags
	db $00		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C05_Room16	; Actor Setup code
