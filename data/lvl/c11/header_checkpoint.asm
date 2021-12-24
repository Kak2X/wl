	dp GFX_Level_Sand	; Main GFX
	dw GFX_LevelShared_02	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_00	; Animated tiles GFX
	dlvl LevelLayoutPtr_C11	; Level Layout ID	
	dw LevelBlock_Sand	; 16x16 Blocks 
	db $01,$90	; Player Y
	db $05,$58	; Player X
	db OBJ_WARIO_STAND ; OBJLst Frame
	db OBJLST_XFLIP	; OBJLst Flags (Face Right)
	db $01,$60	; Scroll Y
	db $04,$F8	; Scroll X
	db DIR_NONE		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $1F		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C11_Room14	; Actor Setup code
