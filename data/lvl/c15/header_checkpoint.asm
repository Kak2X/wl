	dp GFX_Level_StoneCastle	; Main GFX
	dw GFX_LevelShared_00	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_00	; Animated tiles GFX
	dlvl LevelLayoutPtr_C15	; Level Layout ID	
	dw LevelBlock_StoneCastle	; 16x16 Blocks 
	db $01,$A0	; Player X
	db $06,$D8	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db OBJLST_XFLIP	; OBJLst Flags (Face Right)
	db $01,$60	; Scroll Y
	db $06,$78	; Scroll X
	db DIR_NONE		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C15_Room16	; Actor Setup code
