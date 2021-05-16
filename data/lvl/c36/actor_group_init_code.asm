ActGroup_C36_Room10:
	mActGroup C36_Room10
	ret
ActGroup_C36_Room02:
	mActGroup C36_Room02
	mActGroup_BigItem BIGITEM_HEART
	ret
ActGroup_C36_Room01:
	mActGroup C36_Room01
	ret
ActGroup_C36_Room00:
	mActGroup_CheckBoss sMapParsleyWoodsCompletion, 5
	mActGroup C36_Room00
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
