ActGroup_C40_Room10:
	mActGroup C40_Room10
	ret
ActGroup_C40_Room01:
	mActGroup C40_Room01
	ret
ActGroup_C40_Room1F:
	mActGroup C40_Room1F
	ret
ActGroup_C40_Room03:
	mActGroup C40_Room03
	ret
ActGroup_C40_Room1D:
	mActGroup C40_Room1D
	ret
ActGroup_C40_Room00:
	; Final boss can be re-fought
	mActGroup C40_Room00
	; The VRAM location of actors is fixed for boss rooms
	xor  a
	ld   hl, sActTileBaseIndexTbl
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	ldi  [hl], a
	call Pl_SetDirRight
	; If sActSyrupCastleBossDead is set, we're reloading the room after defeating the final boss.
	; The BGM is handled elsewhere in this case.
	;
	; We are doing this here since music plays during the fade-in, which is before actors are processed.
	ld   a, [sActSyrupCastleBossDead]
	or   a
	jr   nz, .customMusic
	ld   a, BGM_FINALBOSSINTRO
	ld   [sBGMSet], a
	ld   [sHurryUpBGM], a
	ret
.customMusic:
	ret
