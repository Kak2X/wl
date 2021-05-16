	dp GFX_Level_DarkCastle	; Main GFX
	dw GFX_LevelShared_01	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_02	; Animated tiles GFX
	db $1C,$04	; Level Layout ID	
	dw LevelBlock_DarkCastle	; 16x16 Blocks 
	db $01,$E0	; Player X
	db $0D,$68	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $20		; OBJLst Flags
	db $01,$60	; Scroll Y
	db $0D,$08	; Scroll X
	db $00		; Screen Lock Flags
	db $00		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C40_Room1D	; Actor Setup code
