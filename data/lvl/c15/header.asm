	dp GFX_Level_StoneCave	; Main GFX
	dw GFX_LevelShared_03	; Block GFX
	dw GFX_StatusBar_01	; Status Bar GFX
	dw GFX_LevelAnim_00	; Animated tiles GFX
	dlvl LevelLayoutPtr_C15	; Level Layout ID	
	dw LevelBlock_StoneCave	; 16x16 Blocks 
	db $00,$E0	; Player Y
	db $00,$38	; Player X
	db SPR_WARIO_STAND ; Player sprite
	db SPRMAP_XFLIP	; Player sprite flags (Face Right)
	db $00,$60	; Scroll Y
	db $00,$00	; Scroll X
	db DIR_L		; Screen Lock Flags
	db LVLSCROLL_SEGSCRL	; Screen Scroll Mode
	db $00		; Spawn in swim action
	db $00		; Tile animation speed
	db $E1		; BG Palette
	dw ActGroup_C15_Room11	; Actor Setup code
