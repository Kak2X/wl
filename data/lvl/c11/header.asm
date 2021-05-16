	dp GFX_Level_Cave	; Main GFX
	dw GFX_LevelShared_03	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_05	; Animated tiles GFX
	db $13,$05	; Level Layout ID	
	dw LevelBlock_Cave	; 16x16 Blocks 
	db $00,$60	; Player X
	db $00,$38	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $20		; OBJLst Flags
	db $00,$10	; Scroll Y
	db $00,$00	; Scroll X
	db $02		; Screen Lock Flags
	db $10		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C11_Room00	; Actor Setup code
