ActGroup_C13_Room10:
	mActGroup C13_Room10
	ret
ActGroup_C13_Room18:
	mActGroup C13_Room18
	ret
ActGroup_C13_Room1A:
	mActGroup C13_Room1A
	ret
ActGroup_C13_Room19:
	mActGroup_CheckBoss sMapMtTeapotCompletion, 7
	mActGroup C13_Room19
	; Start boss music
	ld   a, BGM_BOSS
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	xor  a
	ld   hl, sActTileBaseIndexTbl
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	call Pl_SetDirRight
	ret
ActGroup_C13_Unused_Room19:
; [TCRF] Unused Actor Group
;        Identical to ActGroup_C13_Room19, but does not do any extra processing.
	mActGroup C13_Room19
	ret
