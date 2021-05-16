ActGroup_C20_Room10:
	mActGroup C20_Room10
	mActGroup_CheckTreasure TREASURE_G
	ret
ActGroup_C20_Room19:
	mActGroup C20_Room19
	mActGroup_OpenExit
	mActGroup_CheckTreasure TREASURE_G
	ret
ActGroup_TreasureG:
	mActGroup TreasureG
	mActGroup_Treasure TREASURE_G
	ret
