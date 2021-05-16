	dp GFX_Level_Mountain	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_04	; Animated tiles GFX
	db $10,$00	; Level Layout ID	
	dw LevelBlock_Mountain	; 16x16 Blocks 
	db $01,$30	; Player X
	db $00,$28	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $20		; OBJLst Flags
	db $00,$E0	; Scroll Y
	db $00,$00	; Scroll X
	db $02		; Screen Lock Flags
	db $10		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C07_Room10	; Actor Setup code
