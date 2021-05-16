	dp GFX_Level_Tree	; Main GFX
	dw GFX_LevelShared_00	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_06	; Animated tiles GFX
	db $16,$00	; Level Layout ID	
	dw LevelBlock_Tree	; 16x16 Blocks 
	db $01,$D0	; Player X
	db $07,$28	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $20		; OBJLst Flags
	db $01,$50	; Scroll Y
	db $06,$C8	; Scroll X
	db $08		; Screen Lock Flags
	db $10		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C34_Room17	; Actor Setup code
