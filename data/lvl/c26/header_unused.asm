	dp GFX_Level_Treasure	; Main GFX
	dw GFX_LevelShared_07	; Block GFX
	dw GFX_StatusBar_03	; Status Bar GFX
	dw GFX_LevelAnim_0F	; Animated tiles GFX
	db $0A,$00	; Level Layout ID	
	dw LevelBlock_Treasure	; 16x16 Blocks 
	db $00,$E0	; Player X
	db $0C,$28	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $20		; OBJLst Flags
	db $00,$60	; Scroll Y
	db $0C,$00	; Scroll X
	db $02		; Screen Lock Flags
	db $00		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $63		; BG Palette
	dw ActGroup_TreasureI	; Actor Setup code
