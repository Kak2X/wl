	dp GFX_Level_Cave	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_0A	; Animated tiles GFX
	db $13,$04	; Level Layout ID	
	dw LevelBlock_Cave	; 16x16 Blocks 
	db $00,$70	; Player X
	db $06,$A8	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $20		; OBJLst Flags
	db $00,$20	; Scroll Y
	db $06,$48	; Scroll X
	db $00		; Screen Lock Flags
	db $10		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C08_Room16	; Actor Setup code
