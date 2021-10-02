	dp GFX_Level_StoneCave	; Main GFX
	dw GFX_LevelShared_03	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_08	; Animated tiles GFX
	dlvl LevelLayoutPtr_C17	; Level Layout ID	
	dw LevelBlock_StoneCave	; 16x16 Blocks 
	db $00,$90	; Player X
	db $0C,$98	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db OBJLST_XFLIP	; OBJLst Flags (Face Right)
	db $00,$40	; Scroll Y
	db $0C,$38	; Scroll X
	db DIR_NONE		; Screen Lock Flags
	db LVLSCROLL_FREE	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C17_Room1C	; Actor Setup code
