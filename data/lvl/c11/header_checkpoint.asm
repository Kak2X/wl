	dp GFX_Level_Sand	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_00	; Animated tiles GFX
	db $13,$05	; Level Layout ID	
	dw LevelBlock_Sand	; 16x16 Blocks 
	db $01,$90	; Player X
	db $05,$58	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $20		; OBJLst Flags
	db $01,$60	; Scroll Y
	db $04,$F8	; Scroll X
	db $00		; Screen Lock Flags
	db $00		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $1F		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C11_Room14	; Actor Setup code
