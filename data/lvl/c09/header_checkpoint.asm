	dp GFX_Level_StoneCave	; Main GFX
	dw GFX_LevelShared_03	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_00	; Animated tiles GFX
	dlvl LevelLayoutPtr_C09	; Level Layout ID	
	dw LevelBlock_StoneCave	; 16x16 Blocks 
	db $01,$E0	; Player Y
	db $05,$B8	; Player X
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $00		; OBJLst Flags (Face Left)
	db $01,$60	; Scroll Y
	db $05,$50	; Scroll X
	db DIR_R		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C09_Room15	; Actor Setup code
