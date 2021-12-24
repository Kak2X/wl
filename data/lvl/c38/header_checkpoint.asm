	dp GFX_Level_Castle	; Main GFX
	dw GFX_LevelShared_00	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_0D	; Animated tiles GFX
	dlvl LevelLayoutPtr_C38	; Level Layout ID	
	dw LevelBlock_Castle	; 16x16 Blocks 
	db $01,$E0	; Player Y
	db $0C,$98	; Player X
	db OBJ_WARIO_STAND ; OBJLst Frame
	db OBJLST_XFLIP	; OBJLst Flags (Face Right)
	db $01,$60	; Scroll Y
	db $0C,$38	; Scroll X
	db DIR_NONE		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $0F		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C38_Room1C	; Actor Setup code
