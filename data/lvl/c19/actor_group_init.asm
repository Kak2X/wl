ActGroup_C19_Room11:
	mActGroup C19_Room11
	ret
ActGroup_C19_Room06:
	mActGroup C19_Room06
	ret
ActGroup_C19_Room07:
	mActGroup C19_Room07
	ret
ActGroup_C19_Room1B:
	mActGroup C19_Room1B
	ret
ActGroup_C19_Room00:
	; Sherbet Land boss can be re-fought
	mActGroup C19_Room00
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
ActGroup_C19_Room1D:
	mActGroup C19_Room1D
	ret
ActGroup_C19_Room1E:
	mActGroup C19_Room1E
	ret
