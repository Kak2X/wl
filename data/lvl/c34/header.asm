	dp GFX_Level_Tree	; Main GFX
	dw GFX_LevelShared_00	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_06	; Animated tiles GFX
	dlvl LevelLayoutPtr_C34	; Level Layout ID	
	dw LevelBlock_Tree	; 16x16 Blocks 
	db $01,$E0	; Player Y
	db $00,$28	; Player X
	db OBJ_WARIO_STAND ; OBJLst Frame
	db OBJLST_XFLIP	; OBJLst Flags (Face Right)
	db $01,$50	; Scroll Y
	db $00,$00	; Scroll X
	db $0A		; Screen Lock Flags
	db LVLSCROLL_FREE	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $07		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C34_Room10	; Actor Setup code
