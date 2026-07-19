	dp GFX_Level_Ship	; Main GFX
	dw GFX_LevelShared_00	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_00	; Animated tiles GFX
	dlvl LevelLayoutPtr_C30	; Level Layout ID	
	dw LevelBlock_Ship	; 16x16 Blocks 
	db $01,$60	; Player Y
	db $05,$78	; Player X
	db SPR_WARIO_STAND ; Player sprite
	db $00		; Player sprite flags (Face Left)
	db $00,$E0	; Scroll Y
	db $05,$18	; Scroll X
	db DIR_NONE		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C30_Room15	; Actor Setup code
