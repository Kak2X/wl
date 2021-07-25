ActGroup_C05_Room10:
	mActGroup C05_Room10
	ret
ActGroup_C05_Room12:
	mActGroup C05_Room12
	ret
ActGroup_C05_Room16:
	mActGroup C05_Room16
	ret
ActGroup_C05_Room18:
	mActGroup C05_Room18
	ret
ActGroup_C05_Room1C:
	mActGroup C05_Room18
	ret
ActGroup_C05_Room00:
	mActGroup_CheckBoss sMapRiceBeachCompletion, 5
	mActGroup C05_Room00
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
