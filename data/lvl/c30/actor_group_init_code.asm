ActGroup_C30_Room10:
	mActGroup C30_Room10
	mActGroup_CheckTreasure TREASURE_K
	ret
ActGroup_C30_Room01:
	mActGroup C30_Room01
	ret
ActGroup_C30_Room15:
	mActGroup C30_Room15
	ret
ActGroup_C30_Room16:
	mActGroup C30_Room16
	mActGroup_CheckTreasure TREASURE_K
	ret
ActGroup_C30_Room1B:
	mActGroup C30_Room16
	ret
ActGroup_TreasureK:
	mActGroup TreasureK
	mActGroup_CheckTreasure TREASURE_K
	ret
ActGroup_C30_Room00:
	mActGroup_CheckBoss sMapSSTeacupCompletion, 4
	mActGroup C30_Room00
	ld   a, BGM_BOSS
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	call Pl_SetDirRight
	ret
