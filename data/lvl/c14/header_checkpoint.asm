	dp GFX_Level_StoneCave	; Main GFX
	dw GFX_LevelShared_03	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_00	; Animated tiles GFX
	dlvl LevelLayoutPtr_C14	; Level Layout ID	
	dw LevelBlock_StoneCave	; 16x16 Blocks 
	db $00,$E0	; Player X
	db $00,$B8	; Player Y
	db OBJ_WARIO_STAND ; OBJLst Frame
	db $00		; OBJLst Flags (Face Left)
	db $00,$60	; Scroll Y
	db $00,$50	; Scroll X
	db DIR_R		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C14_Room00	; Actor Setup code
