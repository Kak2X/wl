ActGroup_C25_Room10:
	mActGroup C25_Room10
	ret
ActGroup_C25_Room1D:
	mActGroup C25_Room1D
	ret
ActGroup_C25_Room00:
	mActGroup_CheckBoss sMapStoveCanyonCompletion, 6
	mActGroup C25_Room00
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
