	dp GFX_Level_StoneCave	; Main GFX
	dw GFX_LevelShared_03	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_00	; Animated tiles GFX
	db $10,$04	; Level Layout ID	
	dw LevelBlock_StoneCave	; 16x16 Blocks 
	db $01,$40	; Player X
	db $08,$C8	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $20		; OBJLst Flags
	db $00,$E0	; Scroll Y
	db $08,$50	; Scroll X
	db $01		; Screen Lock Flags
	db $00		; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C13_Room18	; Actor Setup code
