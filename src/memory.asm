; Ram map would go here

;UNION
;NEXTU
;ENDU

; ====================================
; =============== VRAM ===============
; ====================================
; As a rule of thumb, anything marked as vGFX should be remapped if its tiles are rerranged

; =============== Main ===============
vGFXHatPrimary EQU $8000
vGFXHatSecondary EQU $83B0

; Shared sprites
vGFXLevelSharedOBJ EQU $8000
vGFXLevelSharedOBJ_Size EQU $0B00

; Status bar (+ misc OBJ which got thrown here for lack of space)
vGFXStatusBar EQU $8B00
vGFXStatusBar_Size EQU $0200
vGFXStatusBar_End EQU vGFXStatusBar + vGFXStatusBar_Size

vGFXActors EQU $8D00
vGFXActors_End EQU $9000
vGFXActorsSec EQU $8A00 ; Overlaps with end of SharedOBJ

vGFXStunStar EQU $8FF0

; Main level tiles
vGFXLevelMain EQU $9200
vGFXLevelMain_Size EQU $0600

; Common blocks
vGFXLevelSharedBlocks EQU $9000
vGFXLevelSharedBlocks_Size EQU $0200


; =============== Title Screen ===============

; all frames are already in the tilemap
vGFXTitleWaterAnimGFX0 EQU $8DC0
vGFXTitleWaterAnimGFX1 EQU $8DE0
; and get copied to this area
vGFXTitleWaterAnim     EQU $8920

; =============== Map Screen ===============
vGFXMapOverworldAnim  EQU $8AA0

; Animated 1bpp tiles locations for Rice Beach
vGFXMapRiceBeachAnim0 EQU $9500
vGFXMapRiceBeachAnim1 EQU $9510
vGFXMapRiceBeachAnim2 EQU $9600
vGFXMapRiceBeachAnim3 EQU $9610
vGFXMapRiceBeachAnim4 EQU $9620
vGFXMapRiceBeachAnim5 EQU $9700
vGFXMapRiceBeachAnim6 EQU $9710
vGFXMapRiceBeachAnim7 EQU $9720
vGFXMapRiceBeachAnim8 EQU $9730
vGFXMapRiceBeachAnim9 EQU $9740

; 2x2 area essentially
; code in Map_StoveCanyon_ScreenEvent assumes the graphics data is organized like this
vGFXMapStoveCanyonAnim0 EQU $94A0 ; top left
vGFXMapStoveCanyonAnim1 EQU $94B0 ; top right
vGFXMapStoveCanyonAnim2 EQU $95A0 ; bottom left
vGFXMapStoveCanyonAnim3 EQU $95B0 ; bottom right

vGFXMapSSTeacupAnim0 EQU $8B50
vGFXMapSSTeacupAnim1 EQU $8B60

vBGCourseText0 EQU $98E7 ; "COURSE"
vBGCourseText1 EQU $9928 ; "No."
vBGCourseNum0 EQU $992A ; High digit of course number
vBGCourseNum1 EQU $992B ; Low digit of course
vBGCourseLvlId0 EQU $9A11 ; High digit of level id (debug mode only)
vBGCourseLvlId1 EQU $9A12 ; Low digit of level id (debug mode only)

; =============== Gameplay ===============
vBGStatusBarRow0 EQU $9C00
vBGStatusBarRow1 EQU $9C20
vBGStatusBarCourseNum EQU $9C23
vBGLives EQU $9C03
vBGLevelCoins EQU $9C08
vBGHearts EQU $9C0D

vBGLevelTime EQU $9C11
vBGTotalCoins EQU $9C2F

; SS Teacup Boss parts
vBGSSTeacupBossBody EQU $9992
vBGSSTeacupBossWing EQU $9A33
vBGSSTeacupBossBeak EQU $9A14
vBGSSTeacupBossEyes EQU $9994
vBGSSTeacupBossClaws EQU $9A51

; Stove Canyon Boss parts
vBGStoveCanyonBossBody EQU $99B4
vBGStoveCanyonBossMouth EQU $9A54

; Genie Boss
vGFXGenieBoss EQU $8A00
vBGGenieBossGround0 EQU $9BC0 ; Upper 8x8 tiles
vBGGenieBossGround1 EQU vBGGenieBossGround0 + BG_TILECOUNT_H ; Lower 8x8 tiles
vBGGenieBossBody EQU $99D2
vBGGenieBossHandL EQU $9A10
vBGGenieBossHandR EQU $9A19
vBGGenieBossFootL EQU $9AB2
vBGGenieBossFootR EQU $9AB7
vBGGenieBossFace EQU $99D5

; Heart game
vGFXBigHeart0 EQU $8D00
vGFXBigHeart1 EQU $8E90


; =============== Save Select ===============
vBGSavePipe EQU $99A2

; =============== Treasure Room ===============
vBGTrRoomLevelCoinsSep EQU $984E
vBGTrRoomLevelCoins EQU $984F

vBGTrRoomTotalCoinIcon EQU $98A3
vBGTrRoomTotalCoinsDigit0 EQU $98A7+($02*0)
vBGTrRoomTotalCoinsDigit1 EQU $98A7+($02*1)
vBGTrRoomTotalCoinsDigit2 EQU $98A7+($02*2)
vBGTrRoomTotalCoinsDigit3 EQU $98A7+($02*3)
vBGTrRoomTotalCoinsDigit4 EQU $98A7+($02*4)

vBGTrRoomTreasureA EQU $9928
vBGTrRoomTreasureB EQU $992A
vBGTrRoomTreasureC EQU $992C
vBGTrRoomTreasureD EQU $992E
vBGTrRoomTreasureE EQU $9930
vBGTrRoomTreasureF EQU $9968
vBGTrRoomTreasureG EQU $996A
vBGTrRoomTreasureH EQU $996C
vBGTrRoomTreasureI EQU $996E
vBGTrRoomTreasureJ EQU $9970
vBGTrRoomTreasureK EQU $99A8
vBGTrRoomTreasureL EQU $99AA
vBGTrRoomTreasureM EQU $99AC
vBGTrRoomTreasureN EQU $99AE
vBGTrRoomTreasureO EQU $99B0


; =============== Bonus Games ===============
vGFXBonusGamePlHat EQU $8010 ; GFX offset for Wario's hat. Expected to be in this location in the compressed GFX.

vGFXHeartBonusAnimGFX0 EQU $96D0
vGFXHeartBonusAnimGFX1 EQU $96E0
vGFXHeartBonusAnim EQU $96B0

vBGCoinBonusBucketL EQU $98A5
vBGCoinBonusBucketR EQU $98AC

vBGCoinBonusRoundNum EQU $9845

vBGHeartBonusResultsDifficulty EQU $9809
vBGHeartBonusResultsPrizes EQU $984B

; =============== Time Up Screen ===============
vBGTimeUpHandFingerBlock0 EQU $9968
vBGTimeUpHandFingerBlock1 EQU $996A

vBGTimeUpWarioBlock0 EQU $9C28
vBGTimeUpWarioBlock1 EQU $9C2A

; =============== Game Over Screen ===============

vBGGameOverWarioBlock0 EQU $98A8
vBGGameOverWarioBlock1 EQU $98AA

; =============== Ending ===============
vBGEndGenieHandL EQU $9846
vBGEndGenieHandR EQU $986F

vBGEndBalloon EQU $9861

; =============== Credits ===============

vGFXCreditsFlagsSAnimGFX0 EQU $8DE0
vGFXCreditsFlagsSAnimGFX1 EQU $8DF0
vGFXCreditsFlagsSAnim EQU $8920
vGFXCreditsFlagsLAnimGFX0 EQU $8BC0
vGFXCreditsFlagsLAnimGFX1 EQU $8BE0
vGFXCreditsFlagsLAnim EQU $8E20

vGFXCreditsPlanet EQU $8BC0
vGFXCreditsText EQU $9400
vGFXCreditsPagoda EQU $9100

vBGCreditsGround EQU $99C0
vBGCreditsBox EQU $99C0 ; Replaces ground
vBGCreditsRow1 EQU $99E0+$14 ; Initial coord for first row
vBGCreditsBoxBlankRow2 EQU $9A00 ; When blanking the second row, it starts here
vBGCreditsRow2 EQU $9A81
vBGCreditsBoxBlankRow2_End EQU $9B00
vBGCreditsBox_End EQU $9C00






; The game only uses the first $100 bytes of the WINDOW map
MyWINDOWMap_End    EQU $9D00

; SAVEDATA

sSave1 EQU $A000
sSave1LevelsCleared EQU $A00D
sSave1AllClear      EQU $A017
sSave1Bak EQU $A020
sSave2 EQU $A040
sSave2LevelsCleared EQU $A04D
sSave2AllClear      EQU $A057
sSave2Bak EQU $A060
sSave3 EQU $A080
sSave3LevelsCleared EQU $A08D
sSave3AllClear      EQU $A097
sSave3Bak EQU $A0A0
sSave1Checksum EQU $A0C0
sSave2Checksum EQU $A0C1
sSave3Checksum EQU $A0C2
sLastSave EQU $A0C3 ; Last entered pipe

sDemoId EQU $A0C4 ; Marks the demo to play

sActSet EQU $A100 ; Currently processed actor area
sActSetActive EQU $A100
sActSetX_Low EQU $A101 ; 2 byte coord mode
sActSetX_High EQU $A102
sActSetY_Low EQU $A103 ; 2 byte coord mode
sActSetY_High EQU $A104
sActSetColiType EQU $A105 ; Collision type
sActSetColiBoxU EQU $A106 ; Collision box - up extend. Generally negative.
sActSetColiBoxD EQU $A107 ; Collision box - down extend. Generally negative.
sActSetColiBoxL EQU $A108 ; Collision box - left extend. Generally negative.
sActSetColiBoxR EQU $A109 ; Collision box - right extend. Generally positive.
sActSetRelY EQU $A10A ; Collision box Y origin. Box position is shifted down by this amount. Also used for 1 byte coord mode.
sActSetRelX EQU $A10B ; Collision box X origin. Box position is shifted right by this amount. Also used for 1 byte coord mode.
sActSetOBJLstPtrTablePtr_Low EQU $A10C ; Ptr to the currently drawn OBJLstPtrTable.
sActSetOBJLstPtrTablePtr_High EQU $A10D
sActSetDir EQU $A10E ; Movement direction (*not* OBJ flags)
sActSetOBJLstId EQU $A10F
sActSetId EQU $A110
sActSetRoutineId EQU $A111 ; or sActSetPlIntMode -- Player interaction mode basically -- and in the upper nybble the "interaction direction" is stored (ACTINT_*)). When something is thrown at, the upper nybble contains the slot number of the actor which was thrown.
sActSetCodePtr EQU $A112
sActSetTimer EQU $A114 ; Main execution timer
sActSetTimer2 EQU $A115 ; Custom.
sActSetTimer3 EQU $A116 ; Custom.
sActSetTimer4 EQU $A117 ; Custom.
sActSetTimer5 EQU $A118 ; Custom.
sActSetTimer6 EQU $A119 ; Custom.
sActSetTimer7 EQU $A11A ; Custom.
sActSetOpts EQU $A11B ; Misc flags (ACTFLAGB_*)
sActSetLevelLayoutPtr EQU $A11C ; For permanent despawns mostly
sActSetOBJLstSharedTablePtr EQU $A11E ; Ptr to the "shared table", so common subroutines (like the stunned actor) know which OBJLstPtrTable to apply. Each entry to this should be a valid OBJLstPtrTable.
sActSet_End EQU $A120

;--
; Timer assignments for actors

; COMMON USES
sActModeTimer EQU sActSetTimer2
sActSetYSpeed_Low EQU sActSetTimer3
sActSetYSpeed_High EQU sActSetTimer4
sActLocalRoutineId EQU sActSetTimer5

; SHARED ACTORS
sActHeldDelay EQU sActSetTimer5
sActThrowHSpeed EQU sActSetTimer5
sActThrowDead EQU sActSetTimer6
sActThrowNoColiTimer EQU sActSetTimer7
sActStunDrop EQU sActSetTimer7 ; Marks the actor as dropped
sActBumpSoftAltHSpeed EQU sActSetTimer7
sActStunGroundMoveAltHSpeed EQU sActSetTimer7
sActStunStarParentSlot EQU sActSetTimer5 ; Slot number for the stunned actor -- to keep position in sync
sActCoinGroundTimer EQU sActSetTimer2 ; Increases when a coin is on the ground
sActStunPlatformHSpeed EQU sActSetTimer7 ; For the unused variant

; THE REST
sActItemYSpeed EQU sActSetTimer3
sActItemRiseTimer EQU sActSetTimer4
sActGoomTurnDelay EQU sActSetTimer2
sActSparkAntiClockwise EQU sActSetTimer4
sActSparkStepsLeft EQU sActSetTimer6
sActSparkDir EQU sActSetTimer7
sActBigFruitDropTimer EQU sActSetTimer4
sActBigFruitMoveDelay EQU sActSetTimer2
sActBigFruitLandTimer EQU sActSetTimer7
sActSpikeBallDropTimer EQU sActSetTimer4
sActSpikeBallMoveDelay EQU sActSetTimer2
sActSpikeBallLandTimer EQU sActSetTimer7
sActSpearGoomTurnDelay EQU sActSetTimer2
sActSpearGoomColiDelay EQU sActSetTimer5
sActHelmutVDir EQU sActSetTimer5 ; 0: Down; 1: Up
sActSSTeacupBossModeTimer EQU sActSetTimer2
sActSSTeacupBossRelXTarget EQU sActSetTimer4 ; Target X position compared against sActSetRelX
sActSSTeacupBossRoutineId EQU sActSetTimer5 ; Movement mode for the boss
sActSSTeacupBossHitCount EQU sActSetTimer6 ; Times the boss has been hit
sActSSTeacupBossSpawnCount EQU sActSetTimer7 ; Number of spawned birds
sActPouncerDropMoveUMask EQU sActSetTimer2 ; Movement mask when moving up.
sActPouncerDropYTarget EQU sActSetTimer4
sActPouncerDropPostDropDelay EQU sActSetTimer6
sActPouncerDropPreDropDelay EQU sActSetTimer7
sActPouncerFollowDir EQU sActSetTimer6 ; Direction value PCFW_DIR_*
sActPouncerFollowDownDelay EQU sActSetTimer7 ; Cooldown timer before being able to move down again
sActDrillerTurnTimer EQU sActSetTimer2 ; When it elapses, the actor turns
sActDrillerSafeTouch EQU sActSetTimer5
sActPuffYSpeed EQU sActSetTimer3 ; Not normally used
sActPuffRoutineId EQU sActSetTimer5
sActLavaBubbleJumpDelay EQU sActSetTimer7
sActCoinLockUnlockTimer EQU sActSetTimer2
sActCoinLockOpenStatus EQU sActSetTimer5
sActCartTrainCanMove EQU sActSetTimer5
sActCartCanMove EQU sActSetTimer5
sActWolfTurnDelay EQU sActSetTimer2 ; When it elapses, the actor turns
sActWolfModeTimer EQU sActSetTimer2 ; Times a mode before switching to the next
sActWolfKnifeDelay EQU sActSetTimer3 ; Cooldown timer before throwing another knife
sActWolfYSpeed EQU sActSetTimer4
sActWolfRoutineId EQU sActSetTimer5
sActWolfMoveDelay EQU sActSetTimer6 ; Until it elapses, the actor can't move
sActWolfKnifeTimer EQU sActSetTimer2
sActPenguinTurnDelay EQU sActSetTimer2 ; When it elapses, the actor turns
sActPenguinModeTimer EQU sActSetTimer2 ; Times a mode before switching to the next
sActPenguinPostKickDelay EQU sActSetTimer3
sActPenguinYSpeed EQU sActSetTimer4
sActPenguinRoutineId EQU sActSetTimer5
sActPenguinAlertDelay EQU sActSetTimer6 ; Until it elapses, the actor can't move
sActPenguinSpawnDelay EQU sActSetTimer7
sActPenguinSpikeTimer EQU sActSetTimer2
sActDDTurnDelay EQU sActSetTimer2 ; When it elapses, the actor turns
sActDDModeTimer EQU sActSetTimer2 ; Times a mode before switching to the next
sActDDThrowDelay EQU sActSetTimer3 ; Cooldown timer before throwing another boomerang
sActDDYSpeed EQU sActSetTimer4
sActDDRoutineId EQU sActSetTimer5
sActDDMoveDelay EQU sActSetTimer6 ; Until it elapses, the actor can't move
sActCheckPointStatus EQU sActSetTimer5
sActTreasureChestLidRoutineId EQU sActSetTimer5
sActTreasurePopUpTimer EQU sActSetTimer2
sActTreasureShineParentSlot EQU sActSetTimer5
sActWatchRoutineId EQU sActSetTimer5
sActChickenDuckModeTimer EQU sActSetTimer2
sActChickenDuckRoutineId EQU sActSetTimer5
sActMtTeapotBossModeTimer EQU sActSetTimer2
sActMtTeapotBossCoinGameStarted EQU sActSetTimer2
sActMtTeapotBossRoutineId EQU sActSetTimer5
sActSherbetLandBossModeTimer EQU sActSetTimer2
sActSherbetLandBossHeartGameStarted EQU sActSetTimer2
sActSherbetLandBossRoutineId EQU sActSetTimer5
sActSherbetLandBossHitCount EQU sActSetTimer6 ; Times the boss has been hit
sActRiceBeachBossModeTimer EQU sActSetTimer2
sActRiceBeachBossHSpeed_Low EQU sActSetTimer3
sActRiceBeachBossHSpeed_High EQU sActSetTimer4
sActRiceBeachBossRoutineId EQU sActSetTimer5
sActRiceBeachBossHitCount EQU sActSetTimer6 ; Times the boss has been hit
sActRiceBeachBossDropSpeed EQU sActSetTimer7
sActParsleyWoodsBossModeTimer EQU sActSetTimer2
sActParsleyWoodsBossHSpeed_Low EQU sActSetTimer3
sActParsleyWoodsBossHSpeed_High EQU sActSetTimer4
sActParsleyWoodsBossRoutineId EQU sActSetTimer5
sActParsleyWoodsBossHitCount EQU sActSetTimer6 ; Times the boss has been hit
sActParsleyWoodsBossVSpeed EQU sActSetTimer7
sActParsleyWoodsBossGhostModeTimer EQU sActSetTimer2
sActParsleyWoodsBossGhostGoomRoutineId EQU sActSetTimer5
sActStoveCanyonBossModeTimer EQU sActSetTimer2
sActStoveCanyonBossUpMove EQU sActSetTimer2
sActStoveCanyonBossRoutineId EQU sActSetTimer5
sActStoveCanyonBossBallDelay EQU sActSetTimer6 ; If set, the boss throws a snot ball when the timer expires
sActStoveCanyonBossHitCount EQU sActSetTimer7
sActStoveCanyonBossBallModeTimer EQU sActSetTimer2
sActStoveCanyonBossBallRoutineId EQU sActSetTimer5
sActFloaterModeTimer EQU sActSetTimer2
sActFloaterIdleIndex EQU sActSetTimer2 ; Indexes a movement table when the actor is idle (floating in circles)
sActFloaterRoutineId EQU sActSetTimer5
sActFloaterDir EQU sActSetTimer6
sActFloaterArrowParentSlot EQU sActSetTimer7
sActKeyLockUnlockTimer EQU sActSetTimer2
sActKeyLockOpenStatus EQU sActSetTimer5 ; sActKeyLockRoutineId
sActBridgeModeTimer EQU sActSetTimer2
sActBridgeRoutineId EQU sActSetTimer5
sActSnowmanTurnDelay EQU sActSetTimer2
sActSnowmanPostKickDelay EQU sActSetTimer3
sActSnowmanRoutineId EQU sActSetTimer5
sActSnowmanShootDelay EQU sActSetTimer6
sActSnowman_Unused_SpawnDelay EQU sActSetTimer7
sActBigSwitchBlockModeTimer EQU sActSetTimer2
sActBigSwitchBlockRoutineId EQU sActSetTimer5
sActLavaWallRowsLeft EQU sActSetTimer2 
sActLavaWallTileIdU EQU sActSetTimer6
sActLavaWallTileIdD EQU sActSetTimer7
sActHermitCrabTurnDelay EQU sActSetTimer2
sActHermitCrabRoutineId EQU sActSetTimer5
sActSeahorseModeTimer EQU sActSetTimer2
sActSeahorseRoutineId EQU sActSetTimer5
sActSeahorseOrigY_Low EQU sActSetTimer3 ; Original spawn pos
sActSeahorseOrigY_High EQU sActSetTimer4
sActBigItemBoxModeTimer EQU sActSetTimer2
sActBigItemBoxRoutineId EQU sActSetTimer5
sActBombRoutineId EQU sActSetTimer5
sActBombBlockExplIndex EQU sActSetTimer2
sActBombThrown EQU sActSetTimer6
sActBombExplTimer EQU sActSetTimer7
sActSyrupCastleBossYPathIndex EQU sActSetTimer2
sActSyrupCastleBossBGYSpeed EQU sActSetTimer3 ; Mode 0f onlu
sActSyrupCastleBossActYSpeed EQU sActSetTimer4 ; Mode 0f only
sActSyrupCastleBossClearTimer EQU sActSetTimer2
sActSyrupCastleBossModeIncTimer EQU sActSetTimer6 ; Set to a certain value and incremented by a common helper subroutine. Once it reaches a target value, the local rtn. id is increased. 
sActSyrupCastleBossSubRoutineId EQU sActSetTimer7
sActLampStopDelay EQU sActSetTimer2 ; Lamp will not stop moving if != 0, for the min slide delay
sActLampSmokeDespawnTimer EQU sActSetTimer2
sActMiniGenieBlinkTimer EQU sActSetTimer2
sActPelicanMoveTimer EQU sActSetTimer2
sActPelicanThrowTimer EQU sActSetTimer6
sActSpikePillarMoveTimer EQU sActSetTimer2
sActCoinCrabAnimTimer EQU sActSetTimer2
sActCoinCrabModeTimer EQU sActSetTimer2
sActCoinCrabYOrig_Low EQU sActSetTimer6 ; Backup copy of the original spawn Y pos
sActCoinCrabYOrig_High EQU sActSetTimer7
sActStoveCanyonPlatformMoveTimer EQU sActSetTimer2
sActStoveCanyonMinY EQU sActSetTimer3
sActTogemaruBounceCount EQU sActSetTimer7
sActThunderCloudShootTimer EQU sActSetTimer2
sActThunderCloudHSpeed_Low EQU sActSetTimer3
sActThunderCloudHSpeed_High EQU sActSetTimer4
sActThunderCloudYOrig_Low EQU sActSetTimer5
sActThunderCloudYOrig_High EQU sActSetTimer6
sActMoleTurnDelay EQU sActSetTimer2 ; When it elapses, the actor turns
sActMoleModeTimer EQU sActSetTimer2 ; Times a mode before switching to the next
sActMoleThrowDelay EQU sActSetTimer3 ; Cooldown timer before throwing the spike
sActMoleYSpeed EQU sActSetTimer4
sActMoleSpikeAction EQU sActSetTimer6 ; Used to send commands between parent and child
sActMoleMoveDelay EQU sActSetTimer7 ; Until it elapses, the actor can't move
sActMoleSpikePathIndex EQU sActSetTimer2
sActMoleSpikeParentSlot EQU sActSetTimer5
sActMoleSpikeMode EQU sActSetTimer6
sActCrocJumpDelay EQU sActSetTimer2
sActCrocJumpTimer EQU sActSetTimer6
sActSealTurnTimer EQU sActSetTimer2
sActSealRangeCheckDelay EQU sActSetTimer6 ; When it elapses, the actor checks if the player is in H range
sActSealModeTimer EQU sActSetTimer2
sActSealSpearTimer EQU sActSetTimer2
sActBigHeartPopUpTimer EQU sActSetTimer6 ; Once
sActSpiderTurnDelay EQU sActSetTimer2
sActHedgehogTurnDelay EQU sActSetTimer2
sActHedgehogSpikeTimer EQU sActSetTimer4 ; Times the attack sequence
sActMoleCutsceneModeTimer EQU sActSetTimer2
sActFireMissileModeTimer EQU sActSetTimer2
sActStickBombModeTimer EQU sActSetTimer2
sActStickBombPlRelY EQU sActSetTimer6 ; Stick distance to player
sActStickBombPlRelX EQU sActSetTimer7 ; Stick distance to player
sActKnightTurnDelay EQU sActSetTimer2
sActKnightHitCount EQU sActSetTimer6 ; Times the boss has been hit
sActKnightModeTimer EQU sActSetTimer7
sActMiniBossLockUnlockTimer EQU sActSetTimer2
sActFlyModeTimer EQU sActSetTimer2
sActBatRoutineId EQU sActSetTimer5
;--

sAct EQU $A200 ; Actor area
sAct_End EQU $A300

sActNumProc EQU $A300 ; Currently processed actor number

; Used when loading actor GFX
sActSetRelX_High EQU $A301
sActGFXMaxTileCount EQU $A301
sActStoveCanyonBossBallDir EQU $A301 ; Reused
sActSetActive_Tmp EQU $A302
sActGFXTileCopyCount EQU $A302
sActGFXActorNum EQU $A303
sActGFXBankNum EQU $A304
sActGFXTileCount EQU $A305 

sActLevelLayoutOffset_Low EQU $A309 ; X component
sActLevelLayoutOffset_High EQU $A30A ; Y component

sActLevelLayoutPtr_Low EQU $A30B
sActLevelLayoutPtr_High EQU $A30C
sActStunBProc EQU $A318 ; Currently processed actor for ActS_StunByLevelLayoutPtr
sActDummyBlock2 EQU $A319
sActTileBase EQU $A31A ; Current starting tile count
sActTileBaseTbl EQU $A31B ; List of starting tile counts, for each actor in an actgroup
sActGroupCodePtrTable EQU $A32F
sActTileBaseIndexTbl EQU $A331
sActHeld EQU $A34D ; If an actor is held
sActHeldId EQU $A34E
sActHeldOBJLstTablePtr_Low EQU $A34F
sActHeldOBJLstTablePtr_High EQU $A350
sActHeldColiType EQU $A351
sActHeldTreasure EQU $A352 ; Marks if we're holding a treasure
sActColiSaveTbl EQU $A353 ; Table for storing temporary collision types

; -- ActHeldActColi_Do vars --
; Absolute collision box values (relative to the screen),
; for the held actor to actor box collision check
sActTmpAbsColiBoxU EQU $A367
sActTmpAbsColiBoxD EQU $A368
sActTmpAbsColiBoxL EQU $A369
sActTmpAbsColiBoxR EQU $A36A
sActTmpCurSlotNum EQU $A36B ; Current slot number
sActTmpHeldNum EQU $A36C ; Held slot number
;--
sActTimer EQU $A36D ; Global timer increased every frame the actor handler is called
sSubCallTmpA EQU $A36E ; Used by SubCall to save/restore the A register
sActDummyBlock EQU $A36F
sActFlags EQU $A370
sActFlagsRes EQU $A371 ; Calculated flags for writing (temp var)
sRandom EQU $A372 ; Contains the random number generated by Rand
sActHoldHeavy EQU $A373
sLvlSpecClear EQU $A375 ; Level exit (special)
sLvlExitDoor EQU $A376
sLvlTreasureDoor EQU $A377
sActOBJLstBank EQU $A378
sActTreasureId EQU $A382 ; ID of the treasure the room has
sActHeldColiRoutineId EQU $A383 ; Routine ID set when the held actor collides with another actor
sPlFreezeTimer EQU $A384 ; Freezes the player until the timer elapses
sActLastProc EQU $A385	; Last processed actor slot
sActProcCount EQU $A386 ; Processed actors in the current frame
sAct_Unused_InitDone EQU $A387 ; Set to $01 when the actor layout is read, and then after loading an actor group, but never read back
sActRespawnTypeTbl EQU $A388 ; Table indexed by actor id. for each entry: 0 -> use last position; 1 -> always use initial
sActHeldKey EQU $A392
sActHeldSlotNum EQU $A393
sAct_Unused_SpawnId EQU $A394 ; [TCRF] Determines the actor ID spawned by Act_Unused_SpawnCustom
; For the syrup castle boss, when it overwrites the room GFX with the genie GFX.
; These keep track of the src/dest reached since it's done 1tile/frame
sCopyGFXDestPtr_Low EQU $A395
sCopyGFXDestPtr_High EQU $A396
sCopyGFXSourcePtr_Low EQU $A397
sCopyGFXSourcePtr_High EQU $A398
sActSyrupCastleBossWaveXOffset EQU $A399 ; Will be added to the wave effect offsets

; Separate for easy updating by Act_SyrupCastleBoss
sActLampRoutineId EQU $A39A
sActLampSmokeRoutineId EQU $A39B

;##
; [TCRF] Referenced only in suspicious unreferenced code
sActLamp_Unused_ActSetYLast_Low EQU $A39C 
sActLamp_Unused_ActSetYLast_High EQU $A39D
sActLamp_Unused_ActSetXLast_Low EQU $A39E 
sActLamp_Unused_ActSetXLast_High EQU $A39F
sActLamp_Unused_Y0ParallaxLast EQU $A3A0
sActLamp_Unused_X0ParallaxLast EQU $A3A1
;##
sActSyrupCastleBossFireTimer EQU $A3A2 ; For delays before firing

;--
; Global area for position sync across actors
sActStoveCanyonBossXSync_Low EQU $A3A3
sActStoveCanyonBossXSync_High EQU $A3A4
sActStoveCanyonBossYSync_Low EQU $A3A5
sActStoveCanyonBossYSync_High EQU $A3A6

;--
sLvlClearOnDeath EQU $A3A7 ; If set, dying sets sLvlSpecClear instead of starting the death sequence
sCoinGameColiType EQU $A3A8
sCoinGameOBJLstPtrTablePtr_Low EQU $A3A9
sCoinGameOBJLstPtrTablePtr_High EQU $A3AA
sActStoveCanyonBossTongueRoutineId EQU $A3AB
sActStoveCanyonBossTongueBlockHit EQU $A3AC ; If set, the tongue tried to hit a block this pass
sActLYLimit EQU $A3AD ; Actor code will be executed only if LY is less than this
sActLastDraw EQU $A3AE
sActLevelLayoutOffsetLast_Low EQU $A3B0 ; Copy of sActLevelLayoutOffsetLast for the last frame
sActLevelLayoutOffsetLast_High EQU $A3B1
sActBossParallaxFlashTimer EQU $A3B2 ; Seems to be used for other bosses too... and for the exact same purpose!
												; Even the code seems like it was copy/pasted.
sActBossParallaxX EQU $A3B3 ; X coord for SSTeacup boss
sActBossParallaxY EQU $A3B4 ; Y coord for SSTeacup boss
sActBigItemBoxUsed EQU $A3B5 ; Determines if the big item box has been hit already. This implies a limit of one big item box/level.
sActBigItemBoxType EQU $A3B6 ; Determines item inside the giant item box
sActBombLevelExplPtr_Low EQU $A3B7	; Level layout ptr for block destruction effect
sActBombLevelExplPtr_High EQU $A3B8
sActRiceBeachBossDAttackDelay EQU $A3B9 ; The boss spins in place until it expires -- after that it attacks upside down
sActSyrupCastleBossHitAnimTimer EQU $A3BA ; Set sfter the final boss is hit. The boss returns to normal when it elapses
sActSyrupCastleBossHitCount EQU $A3BB
sPlPowerBak EQU $A3BC ; Backup of the actual powerup state, used for faking the powerup during calls to ExActBGColi_DragonHatFlame_CheckBlockId
sUnused_A3BD EQU $A3BD ; [TCRF] Only initialized to $00 once after the actor layout is loaded and never read back
sActSlotTransparent EQU $A3BE ; Performs transparency effect for the actor
sActSyrupCastleBossDead EQU $A3BF ; Used as an indicator for the ending cutscene.
;--
sActLampEndingOk EQU $A3C0 ; If set, the lamp is ready for the ending cutscene. The cutscene won't start if it isn't.
sActLampRelXCopy EQU $A3C1 ; Copy of Act_Lamp's sActSetRelX. Used to track the lamp's position outside of Act_Lamp.
;--
sActKnightDead EQU $A3C2 ; sActMiniBossLockOpen Signals the miniboss door to open itself
; Set of variables tracked by the boss hat
sActSherbetLandBossX_Low EQU $A3C3
sActSherbetLandBossX_High EQU $A3C4
sActSherbetLandBossY_Low EQU $A3C5
sActSherbetLandBossY_High EQU $A3C6
sActSherbetLandBossDir EQU $A3C7
sActSherbetLandBossHatStatus EQU $A3C8 ; $00: none; $01: has hat; $02: trigger drop

sActSyrupCastleBoss_Unused_A3C9 EQU $A3C9 ; [TCRF] Only xor a'd
sActSyrupCastleBossXBak_Low EQU $A3CA
sActSyrupCastleBossXBak_High EQU $A3CB
sActSyrupCastleBossYBak_Low EQU $A3CC
sActSyrupCastleBossYBak_High EQU $A3CD
sActBossDead EQU $A3CE ; Set when some bosses die.
sActSyrupCastleBossBlankBG EQU $A3D0 ; Blanks the parallax section for the boss if set
sActCoinGameTimer_Low EQU $A3D1
sActCoinGameTimer_High EQU $A3D2
sActMtTeapotBossEscapeKeyCount EQU $A3D3 ; Counts A presses for escaping from the boss when held
sActRiceBeachBossDashStunTimer EQU $A3D4


; Mark the levels where the blinking dot effect should be active
sMapRiceBeachBlink EQU $A5E0
sMapMtTeapotBlink EQU $A5E2
sMapSherbetLandBlink EQU $A5E5
sMapStoveCanyonBlink EQU $A5E9
sMapSSTeacupBlink EQU $A5EC
sMapParsleyWoodsBlink EQU $A5F0
sMapSyrupCastleBlink EQU $A5F3

; SOUND SETS
; The different sets are used to mute specific sound channels in BGM playback (see sBGMCh?SFX)
sSFX1Set EQU $A600
sSFX1 EQU $A601
sSFX1Len EQU $A603 ; Frames left to continue playback
sSFX1DivFreq EQU $A605 ; holds pseudo random frequency value for SFX1 $32
sSFX2Set EQU $A607
sSFX2 EQU $A608 
sSFX2Len EQU $A60A
sSFX3Set EQU $A60E ; Empty set
sSFX3 EQU $A60F ; Empty set
sSFX3Len EQU $A611 ; Unused
sSFX4Set EQU $A615 
sSFX4 EQU $A616
sSFX4Len EQU $A618
sBGMSet EQU $A61C
sBGM EQU $A61D
sBGMActSet EQU $A61E 
sBGMAct EQU $A61F

; Marks (with SFX IDs) BGM channels which should be muted 
; to avoid interfering with SFX playback
sBGMChSFX1 EQU $A624
sBGMChSFX2 EQU $A625
sBGMChSFX3 EQU $A626 ; Always 0
sBGMChSFX4 EQU $A627
sSFX1SetLast EQU $A629 ; Holds last sSFX1Set value
	
sBGMPitch EQU $A630 ; Should always be even.
sBGMLenPtr EQU $A631 ; Ptr to current BGM length option
sBGMCurProc EQU $A633 ; Marks if a BGM command has been processed for the current sound channel.
                      ; If this isn't the case, it can mean the end of the BGM chunk was reached.

; Enabled sound channels for BGM Playback only
sBGMCh1On EQU $A634
sBGMCh2On EQU $A635
sBGMCh3On EQU $A636
sBGMCh4On EQU $A637

; # sBGMCurCh could be renamed to sBGMTmp

; Sound_DoCurrentBGM locals
; (values get copied here to allow handling through a generic subroutine)
sBGMCurChRegType EQU $A638 ; Marks if all sound registers have been updated. This can only happen if a specific command is hit.
sBGMCurChWavePtr EQU $A639 ; Ptr to channel 3 wave data
sBGMCurChReg0     EQU $A63B ;
sBGMCurChReg1     EQU $A63C ;
sBGMCurChReg2     EQU $A63D ;
sBGMCurChReg3     EQU $A63E ;
sBGMCurChReg4     EQU $A63F ;

; Sound register copies of the final result for BGM info
;--
sBGMNR10     EQU $A640 ; Channel 1 Sweep register (R/W)
sBGMNR11     EQU $A641 ; Channel 1 Sound length/Wave pattern duty (R/W)
sBGMNR12     EQU $A642 ; Channel 1 Volume Envelope (R/W)
sBGMNR13     EQU $A643 ; Channel 1 Frequency lo (Write Only)
sBGMNR14     EQU $A644 ; Channel 1 Frequency hi (R/W)
sBGMNR21     EQU $A646 ; Channel 2 Sound Length/Wave Pattern Duty (R/W)
sBGMNR22     EQU $A647 ; Channel 2 Volume Envelope (R/W)
sBGMNR23     EQU $A648 ; Channel 2 Frequency lo data (W)
sBGMNR24     EQU $A649 ; Channel 2 Frequency hi data (R/W)
sBGMNR30     EQU $A64A ; Channel 3 Sound on/off (R/W)
sBGMNR31     EQU $A64B ; Channel 3 Sound Length
sBGMNR32     EQU $A64C ; Channel 3 Select output level (R/W)
sBGMNR33     EQU $A64D ; Channel 3 Frequency's lower data (W)
sBGMNR34     EQU $A64E ; Channel 3 Frequency's higher data (R/W)

; [TCRF] Contain copies of registers value which are never read back, set occasionally by certain subroutines
sBGM_Unused_NR42Copy EQU $A651
sBGM_Unused_CurChReg3Copy EQU $A652
sBGM_Unused_CurChReg4Copy EQU $A653

; Sound_SetBGMCh1
; BGM Command Table pointer (for current chunk)
sBGMCh1CmdPtr EQU $A656 
sBGMCh2CmdPtr EQU $A658 
sBGMCh3CmdPtr EQU $A65A 
sBGMCh4CmdPtr EQU $A65C

sBGMPPCmdPitchIndex EQU $A65E ; Index of the pitch bend table for BGMPPCmds

; Shared multi-channel temporary area used in subroutines like Sound_ParseBGMData
; Data from specific channels (sBGMCh1?*/$A66C) needs to be copied here and back out again.
sBGMCurChArea EQU $A65F ; Base address for currently handled chunk (the data inside it)
sBGMCurChChunkPtr EQU $A65F
sBGMCurChLoopPtr EQU $A661 ; Ptr to data command the song should loop to, if a loop is requested
sBGMCurChLoopCount EQU $A663 ; Loops left before the loop command is ignored
sBGMCurChLenOrig EQU $A664 ; Backup copy of sBGMCurChLen when needed to reset it.
sBGMCurChVol EQU $A665 ; Volume
sBGMCurChLen EQU $A666 ; Length (frames left to continue playback with same register settings)
sBGMCurChPitchCmd EQU $A667 ; Frequency offset command, done as the very last step, after channel registers have been already set.

; BGM Sound channel playback
sBGMCh1ChunkPtr EQU $A66C
sBGMCh1LoopPtr EQU $A66E ; Loop target
sBGMCh1LoopCount EQU $A670 ; Loops left
sBGMCh1Spd EQU $A671 ; Speed
sBGMCh1Vol EQU $A672 ; Volume
sBGMCh1Len EQU $A673 ; Length (frames left to continue playback with same register settings)
sBGMCh1PitchCmd EQU $A674
sBGMCh2ChunkPtr EQU $A678
sBGMCh2LoopPtr EQU $A67A ; Loop target
sBGMCh2LoopCount EQU $A67C ; Loops left
sBGMCh2Spd EQU $A67D ; Speed
sBGMCh2Vol EQU $A67E ; Volume
sBGMCh2Len EQU $A67F ; Length
sBGMCh2PitchCmd EQU $A680
sBGMCh3ChunkPtr EQU $A684
sBGMCh3LoopPtr EQU $A686 ; Loop target
sBGMCh3LoopCount EQU $A688 ; Loops left
sBGMCh3Spd EQU $A689 ; Speed
sBGMCh3Vol EQU $A68A ; Volume
sBGMCh3Len EQU $A68B ; Length
sBGMCh3PitchCmd EQU $A68C
sBGMCh4ChunkPtr EQU $A690
sBGMCh4LoopPtr EQU $A692 ; Loop target
sBGMCh4LoopCount EQU $A694 ; Loops left
sBGMCh4Spd EQU $A695 ; Speed
;sBGMCh4Vol EQU $A696 ; Volume (no volume control over the noise)
sBGMCh4Len EQU $A697 ; Length

sFadeOutTimer EQU $A6A0 ; Decrements with an active fade out. When it reaches 0, the fade out "advances" 
sBGMCh2PitchExtra EQU $A6A3 ; If set, it will always increase the pitch level for sound channel 2 only
sSndPauseActSet EQU $A6AA ; Pause/unpause sound action
sSndPauseTimer EQU $A6AB ; Used for timing the above (ie: when to play the pause sfx; when to resume playback; etc...)
sBGMPitchOrig EQU $A6AF ; Backup copy of the original BGM pitch
sBGMCurChWavePtrOrig EQU $A6C3 ; Backup copy of sBGMCurChWavePtr
sBossDeadSFXInit EQU $A6C5 ; Set to $D0 when SFX1_09 is played, which is the *boss dead* SFX.
sBGMNR51   EQU $A6CC ; Backup copy of rNR51 with the current BGM panning option

; Sound register copies for temporary register changes on the SFX side
sSFXNR10    EQU $A6D3 ; Channel 1 Sweep register (R/W)
sSFXNR11    EQU $A6D4 ; Channel 1 Sound length/Wave pattern duty (R/W)
sSFXNR12    EQU $A6D5 ; Channel 1 Volume Envelope (R/W)
sSFXNR13    EQU $A6D6 ; Channel 1 Frequency lo (Write Only)
sSFXNR14    EQU $A6D7 ; Channel 1 Frequency hi (R/W)
sSFXNR21    EQU $A6D8 ; Channel 2 Sound Length/Wave Pattern Duty (R/W)
sSFXNR22    EQU $A6D9 ; Channel 2 Volume Envelope (R/W)
sSFXNR23    EQU $A6DA ; Channel 2 Frequency lo data (W)
sSFXNR24    EQU $A6DB ; Channel 2 Frequency hi data (R/W)
sSFXNR30    EQU $A6DC ; Channel 3 Sound on/off (R/W)
sSFXNR31    EQU $A6DD ; Channel 3 Sound Length
sSFXNR32    EQU $A6DE ; Channel 3 Select output level (R/W)
sSFXNR33    EQU $A6DF ; Channel 3 Frequency's lower data (W)
sSFXNR34    EQU $A6E0 ; Channel 3 Frequency's higher data (R/W)
sSFXNR41    EQU $A6E1 ; Channel 4 Sound Length (R/W)
sSFXNR42    EQU $A6E2 ; Channel 4 Volume Envelope (R/W)
sSFXNR43    EQU $A6E3 ; Channel 4 Polynomial Counter (R/W)
sSFXNR44    EQU $A6E4 ; Channel 4 Counter/consecutive; Initial (R/W)
sNRSize     EQU $A6E5 ; Bytes to copy to a sound channel (temporary var)
sHurryUpOrig EQU $A6E6 ; Copy value to detect if the hurry up status was changed in debug mode
sSFX1FreqOffsetHigh EQU $A6E7 ; "signed" offset
sSFX1FreqOffset EQU $A6E8 ; "signed" offset
sSFX2CoinFreq EQU $A6E9
sSFX2CoinTimer EQU $A6EA
;--

sMapAnimGFX0 EQU $A700
sMapAnimGFX1 EQU $A708
sMapAnimGFX2 EQU $A710
sMapAnimGFX3 EQU $A718
sMapAnimGFX4 EQU $A720
sMapAnimGFX5 EQU $A728
sMapAnimGFX6 EQU $A730
sMapAnimGFX7 EQU $A738
sMapAnimGFX8 EQU $A740
sMapAnimGFX9 EQU $A748
sMapAnimGFXA EQU $A750
sMapAnimGFXB EQU $A758

sMapMtTeapotAutoMove           EQU $A790
sTempA791                      EQU $A791
sMapSubmapEnterTime            EQU $A791
sMapSubmapEnter                EQU $A792
sMapWorldClear                 EQU $A793

sMapLevelClear EQU $A794 ; if set, level clear mode (path reveal) is active

; Copy values used to detect the newly completed level
; and with that, determine which path should be processed for the path reveal anim
sMapRiceBeachCompletionLast         EQU $A795
sMapMtTeapotCompletionLast          EQU $A796
sMapStoveCanyonCompletionLast       EQU $A797
sMapSSTeacupCompletionLast          EQU $A798
sMapParsleyWoodsCompletionLast      EQU $A799
sMapSherbetLandCompletionLast       EQU $A79A
sMapSyrupCastleCompletionLast       EQU $A79B

sMapId                              EQU $A79C ; current map mode
sMapLevelId                         EQU $A79E
sMapWorldId                         EQU $A79F
sMapLevelIdSel                      EQU $A7A0

; This value is a generic "return value" that signals to whoever is calling HomeCall_Map_CheckMapId
; that the map screen is done (ie: started a level, map cutscene finished, ...) and the
; game should switch to somewhere else.
;
; How this value is used depends on the code calling the map screen code.
; For example, the main map mode switches to the Course Intro/Level Select screen.
sMapRetVal                         	EQU $A7A1
sMapTimer_High                      EQU $A7A2
sMapRiceBeachFlooded                EQU $A7A3
sMapTimer_Low                       EQU $A7A4
sMapBridgeAutoMove                  EQU $A7A5
sMapSyrupCastleCutscene             EQU $A7A6 ; active cutscene id
sMapLevelStartTimer                 EQU $A7A7

sMapFadeOutRetVal                   EQU $A7D0 ; tells the game to apply its value to sMapRetVal after a fade out
sMapScrollX                         EQU $A7D1
sMapScrollY                         EQU $A7D2
; OAMWrite parameters
sMapOAMWriteY                       EQU $A7D4 ; Origin Y position of sprite list
sMapOAMWriteX                       EQU $A7D5 ; Origin X position of sprite list
sMapOAMWriteFlags                   EQU $A7D6 ; Sprite list flags
sMapOAMWriteLstId                   EQU $A7D7 ; Index to a table of sprite lists
sMapWarioYRes                       EQU $A7D8 
sMapWarioX                          EQU $A7D9 
sMapWarioFlags                      EQU $A7DA  
sMapWarioLstId                      EQU $A7DB 
sMapWarioYOscillateMask             EQU $A7DC 
sMapWarioAnimTimer                  EQU $A7DD 
sMapWarioY                          EQU $A7DE 
sMapAnimFrame                       EQU $A7DF 
sMapFreeViewReturn                  EQU $A7E1 
sMapPathDirSel                      EQU $A7E2 
sMapPathOffset                      EQU $A7E3 
sMapInPath                          EQU $A7E4 
sMapWarioAnimId                     EQU $A7E5 
sMapPathCtrl                        EQU $A7E6
sMapPathTestCtrl                    EQU $A7E6
sMapStepsLeft                       EQU $A7E7 
sMapTimer0                          EQU $A7E8
sMapSyrupCastleWaveLines            EQU $A7E9  
sMapSyrupCastleWaveShift            EQU $A7EA  
sMap_Unused_LevelIdAlt              EQU $A7EB 
sMap_Unused_UseLevelIdAlt           EQU $A7EC 
sMapEvIndex                         EQU $A7ED 
sMapEndingHeliSpeed                 EQU $A7ED 
sMapEndingSparkleTblIdx             EQU $A7ED 
sMapNextId                          EQU $A7EE
sMapEvOffsetTablePtr_High           EQU $A7EF 
sMapEvOffsetTablePtr_Low            EQU $A7F0 
sMapPathDirSel_Copy                 EQU $A7F1 ; Copy value used for "validation"... that doesn't do anything
sMap_Unused_CopyLinkedTbl           EQU $A7F2 

;--
sLevelId                            EQU $A804
sTotalCoins_High                    EQU $A805
sTotalCoins_Mid                     EQU $A806
sTotalCoins_Low                     EQU $A807
sHearts                             EQU $A808
sLives                              EQU $A809
sPlPower                            EQU $A80A ; Current powerup state
sMapRiceBeachCompletion             EQU $A80B
sMapMtTeapotCompletion              EQU $A80C
sLevelsCleared                      EQU $A80D
sTreasures                    		EQU $A80E ; 16 bits
sMapStoveCanyonCompletion           EQU $A810
sMapSSTeacupCompletion              EQU $A811
sMapParsleyWoodsCompletion          EQU $A812
sMapSherbetLandCompletion           EQU $A813
sMapSyrupCastleCompletion           EQU $A814
sCheckpoint                         EQU $A815 ; if checkpoint is enabled
sCheckpointLevelId                  EQU $A816 ; the level the checkpoint is for
sGameCompleted                      EQU $A817
;--
sDemoWriterBuffer                   EQU $A820 ; [TCRF] $80 bytes ($A820-$A89F) are reserved for generating an input demo

sGameMode EQU $A8C3
sSubMode EQU $A8C4
sROMBank EQU $A8C5 ; Currently loaded ROM bank
sDemoMode EQU $A8C6 ; 
sDebugMode EQU $A8C7 ; [TCRF] Enables the hidden debug mode

; Level scroll coordinates, offset to the center of the screen (LVLSCROLL_XOFFSET/LVLSCROLL_YOFFSET) to get around underflow issues.
; Of course, this means that to get the real hardware scroll position, those must be subtracted to it.
sLvlScrollY_High EQU $A900
sLvlScrollY_Low  EQU $A901
sLvlScrollX_High EQU $A902
sLvlScrollX_Low  EQU $A903
sLvlScrollDir EQU $A904 ; Holds screen scroll direction for updating the tilemap
sTimer EQU $A905 ; Global timer
sBGTmpPtr EQU $A906 ; temporary ptr with VRAM tilemap offset, used for multiple purposes
sPaused EQU $A908
sScreenUpdateMode EQU $A909 ; Screen modes
sLvlScrollSourcePtr_High EQU $A90A	; Temporary address for saving ptr to sLvlScrollTileIdWriteTable
sLvlScrollSourcePtr_Low EQU $A90B
sWorkOAMPos EQU $A90C ; OAM Copy index/offset

; OAMWrite parameters
sOAMWriteY     EQU $A90D
sOAMWriteX     EQU $A90E
sOAMWriteLstId EQU $A90F
sOAMWriteFlags EQU $A910

; Wario m
sPlY_High   EQU $A911
sPlY_Low    EQU $A912
sPlX_High   EQU $A913
sPlX_Low    EQU $A914
sPlLstId    EQU $A915
sPlFlags    EQU $A916

s_X_A917 EQU $A917
sPlTimer EQU $A917 ; Player animation timer
sCreditsTextTimer EQU $A917 ; Used to generate the index
sBlockTopLeftPtr_High EQU $A918
sBlockTopLeftPtr_Low EQU $A919

sPlAction EQU $A91A ; Current player action (moving, jump, ...)
sPlJumpYPathIndex EQU $A91B ; Y increment / decrement
sPlYRel EQU $A91C ; Wario's relative Y coord. Matches what goes into OAMWrite.
sPlXRel EQU $A91D ; Wario's relative X coord. Matches what goes into OAMWrite.
sCreditsRowEffectTimer EQU $A91D ; Times the "pseudo transparency" effect for the first row of the credits text.

; Working area certain slot bytes are copied to
sActTmpRelY EQU $A91E
sActTmpRelX EQU $A91F
sPlColiBoxL EQU $A920 ; Player collision box
sPlColiBoxR EQU $A921
sPlColiBoxU EQU $A922
sPlColiBoxD EQU $A923
sActTmpColiBoxL EQU $A924 ; Current actor collision box
sActTmpColiBoxR EQU $A925
sActTmpColiBoxU EQU $A926
sActTmpColiBoxD EQU $A927
sExActTreasureRow EQU $A928 ; Row number of the treasure in the treasure box
sDemoInputOffset EQU $A929 ; Offset to the demo input table
sDemoLastKey EQU $A92A ; [TCRF] Keeps track of the last keypress when writing a demo.
sDemoInputLength EQU $A92B ; Current length of pressed input (to detect when to switch; resets on new input)
sHighJump EQU $A92C
sDemoFlag EQU $A92D ; Demo mode flag, in practice used to prevent saving and disable sounds
sUnused_BossAlreadyDead EQU $A92E ; [TCRF] Set when entering a boss room when the boss was already defeated. Not read anywhere.
; Holds the single digit (0-9 range) when halving the total coin count
sGameOverCoinDigit0 EQU $A92F
sGameOverCoinDigit1 EQU $A930
sGameOverCoinDigit2 EQU $A931
sGameOverCoinDigit3 EQU $A932
sGameOverCoinDigit4 EQU $A933
sSaveAllClear EQU $A934 ; Bitmask with save files all cleared 
sTarget_High EQU $A935
sTarget_Low EQU $A936

sLvlScrollLockCur EQU $A938 ; Current screen scroll locks
sPlSlowJump EQU $A939 ; Generally if sActHoldHeavy is set
sScreenShakeTimer EQU $A93A ; Screen shake timer for hitting small and big switch blocks
sActTmpColiDir EQU $A93B ; Marks from which collision box border the actor is being interacted with
sActTmpColiType EQU $A93C
sPlInvincibleTimer EQU $A93D ; Timer
sPlDuck          EQU $A93E
sPlBGColiBlockId EQU $A93F ; Block ID indexed for collision
sPlBGColiLadderType EQU $A940 ; Current ladder collision type result
sLvlScrollTimer EQU $A941
sLvlScrollLevel EQU $A942 ; Full scroll number
sLvlScrollDirAct EQU $A943 ; Holds screen scroll direction for spawning actors 
sPlSwimUpTimer EQU $A944
sPlSwimGround EQU $A945 ; For standing/walking on the ground in water
sPlHurtType EQU $A946 ;
sActSlotPtr_High EQU $A947 ; For L0D606F and others
sActSlotPtr_Low EQU $A948
s_X_A949 EQU $A949
sPlBumpYPathIndex EQU $A949 ; Bump effect offset table index
sSaveWarioBumpYPathIndex EQU $A949 ; Bump effect offset table index
sPlPostHitInvulnTimer EQU $A94B
sPlHatSwitchTimer EQU $A94C ; Frames left for the hat sequence effect
sPlDashHitTimer EQU $A94D ; Frames left for the delay after defeating an enemy with a dash
sPlHardBumpGround EQU $A94E
sLvlScrollVAmount EQU $A94F

sLvlScrollColsLeft EQU $A950
; Temporary values containing raw level header data
; Only used during level loading
sLvlScrollYRaw_High EQU $A951
sLvlScrollYRaw_Low  EQU $A952
sLvlScrollXRaw_High EQU $A953
sLvlScrollXRaw_Low  EQU $A954
sPlHatSwitchDrawMode EQU $A955 ; Determines what should be drawn generally
sSmallWario EQU $A956 ; If set, the player is Small Wario
sLvlScrollSet EQU $A957
sPlPowerSet EQU $A958 ; Target powerup before the hat switch sequence
sTrRoomMoneybagCount EQU $A959 ; Number of moneybags given out
sMapVBlankMode EQU $A95A ; Tells the VBlank handler to handle the map screen (which has its own subroutine for handling vblank)
sSavePipeAnimId EQU $A95B ; Current "frame" of pipe anim
sHurryUpBGM EQU $A95C
sPlActSolid_Bak EQU $A95D ; Temp var
sCredits_Unused_ReachedLine2C EQU $A95E ; Only written to once
sLvlAutoScrollDir EQU $A95F ; Conveyor belt direction, or autoscroll direction for autoscrollers. Directly determines sLvlScrollMode
sLvlAutoScrollSpeed EQU $A9DC ; Timer bitmask format for conveyor belts/autoscrollers. In practice only set to $01
sLvlScrollHAmount EQU $A960
sPlBgColiBlockEq EQU $A961 ; If set, the player is colliding with the same block ID in the top
sPlMovingJump EQU $A962 ; it's a feature :(
sPlHardBumpDir EQU $A963
sLevelTime_High EQU $A964
sLevelTime_Low EQU $A965
sPlDashSolidHit EQU $A967 ; Set to 1 when hitting a solid wall during a dash
sPlBGColi_Unused_LastBlockId EQU $A968 ; [TCRF] Only set, but never read back
sParallaxY0 EQU $A969
sParallaxX0 EQU $A96A
sParallaxNextLY0 EQU $A96B
sParallaxY1 EQU $A96C
sParallaxX1 EQU $A96D
sParallaxNextLY1 EQU $A96E
sParallaxY2 EQU $A96F
sParallaxX2 EQU $A970
sParallaxNextLY2 EQU $A971
sParallaxY3 EQU $A972
sParallaxX3 EQU $A973
sParallaxNextLY3 EQU $A974
sEndTotalCoins_High EQU $A975 ; Total coins -- high byte (after decrementing the total coin count in the ending)
sEndTotalCoins_Mid EQU $A976 ; ""
sEndTotalCoins_Low EQU $A977 ; ""
sCreditsNextRow1Mode EQU $A978
sTmp_Unused_A979 EQU $A979 ; Used only in unused code
sLevelCoins_High EQU $A97A
sLevelCoins_Low EQU $A97B
sPlGroundDashTimer EQU $A97C ; Frames left for a dash attack from the ground
sLvlLayoutPtrActId EQU $A97D ; Actor ID in the specified level layout ptr
sPlBGColiBlockOffset1_High EQU $A97E
sPlBGColiBlockOffset1_Low EQU $A97F
sPlBGColiBlockOffset2_High EQU $A980
sPlBGColiBlockOffset2_Low EQU $A981
sActStunLevelLayoutPtr_High EQU $A982 ; Actors in this location will be stunned
sActStunLevelLayoutPtr_Low EQU $A983
s_X_A984_Timer EQU $A984
sPlTimer2 EQU $A984
sCourseScrTimer EQU $A984 ; Frames before course screen transitions to level load
sSaveWarioTimer EQU $A984
sLevelClearTimer EQU $A984
sTrRoomCoinDecDelay EQU $A984 ; Delays the coin countdown until it gets to $02. Also used to signal the 
sTrRoomWaitTimer EQU $A984
sTimeUpWaitTimer EQU $A984
sGameOverWaitTimer EQU $A984
sEndingWaitTimer EQU $A984
;sTrRoomTreasureOutDelay EQU $A984

sTimeUp EQU $A985 ; If set, dying results in the time up screen showing up
sGameOver EQU $A986 ; If set, dying results in the game over screen showing up
sActInteractDir EQU $A988 ; Bitmask which marks from which direction the actor is being interacted with
sActColiBoxDistanceD EQU $A989 ; Distance between pl up colibox and actor down colibox
sActColiBoxDistanceU EQU $A98A
sActColiBoxDistanceL EQU $A98B
sActColiBoxDistanceR EQU $A98C

sPlActSolid EQU $A98D ; If set, the player's standing top of a solid actor
sLvlDoorPtr EQU $A98E ; Set when entering doors (high; low)
sParallaxMode EQU $A990
sScrollX_High EQU $A993
sScrollX EQU $A994 ;
sBossRoom EQU $A995 ; If set, the current room is handled as a boss room. This disables the lag reduction feature and prevents actors from spawning when scrolling
s_Unused_LvlBGPriority EQU $A996 ; Only written to with value from header; never read back
sBGP EQU $A997 ; For levels
sPlJetDashTimer EQU $A998
sPlScreenShake EQU $A999 ; Marks a screen-shake caused by the player
sPlDragonFlameDamage EQU $A9A2 ; Set when the dragon hat flame can cause damage
sNoReset EQU $A9A7 ; For some reason they bothered with this
sLvlScrollMode EQU $A99D
; Collision box for dragon hat flame
sPlDragonFlameColiBoxL EQU $A99E
sPlDragonFlameColiBoxR EQU $A99F
sPlDragonFlameColiBoxU EQU $A9A0
sPlDragonFlameColiBoxD EQU $A9A1
s_Unused_PlNoGroundPound EQU $A9A3
sPlDragonHatActive EQU $A9A4
sActHeldLast EQU $A9A5
sPlJumpThrowTimer EQU $A9A6
sPauseActors EQU $A9A8
sScrollYOffset EQU $A9A9 ; Y scroll offset for screen shake effects. it's why hScrollY exists.
sTrRoomCoinFrameId EQU $A9AA ; $0A + this value is the block ID for the coin
sLevelAnimSpeed EQU $A9AB ; Animated tile speed (0 = no anim)
sSaveBlockBreakDone EQU $A9AC ;
sSaveAnimAct EQU $A9AD
sCourseClrMode EQU $A9AD
sEndingTrRoomMode EQU $A9AD
sTreasureTrRoomMode EQU $A9AD
sGameOverTrRoomMode EQU $A9AD
sCreditsMode EQU $A9AD
s_X_IndexA9AE EQU $A9AE
sSaveWarioYTblIndex EQU $A9AE ; Index to Y offset table for Wario's jump in the save screen
sSaveTargetX EQU $A9AF
sSavePlAct EQU $A9B0 ; Player action
sSaveBombWario EQU $A9B1 ; If set, Wario is in the bomb form
sPlSand EQU $A9B2
sPlSandJump EQU $A9B3
sPlHatSwitchEndMode EQU $A9B4
sPlWaterAction EQU $A9B5 ; Marks an underwater action so that when we return to the swimming act, the water splash won't spawn
; Top left coordinates of the level scroll positions
; These are treated as the row/col 
sLvlScrollUpdR0Y_High EQU $A9B6
sLvlScrollUpdR0Y_Low  EQU $A9B7
sLvlScrollUpdR0X_High EQU $A9B8
sLvlScrollUpdR0X_Low  EQU $A9B9
sLvlScrollUpdL0Y_High EQU $A9BA
sLvlScrollUpdL0Y_Low  EQU $A9BB
sLvlScrollUpdL0X_High EQU $A9BC
sLvlScrollUpdL0X_Low  EQU $A9BD
sLvlScrollUpdU0Y_High EQU $A9BE
sLvlScrollUpdU0Y_Low  EQU $A9BF
sLvlScrollUpdU0X_High EQU $A9C0
sLvlScrollUpdU0X_Low  EQU $A9C1
sLvlScrollUpdD0Y_High EQU $A9C2
sLvlScrollUpdD0Y_Low  EQU $A9C3
sLvlScrollUpdD0X_High EQU $A9C4
sLvlScrollUpdD0X_Low  EQU $A9C5
sLvlScrollUpdR1Y_High EQU $A9C6
sLvlScrollUpdR1Y_Low  EQU $A9C7
sLvlScrollUpdR1X_High EQU $A9C8
sLvlScrollUpdR1X_Low  EQU $A9C9
sLvlScrollUpdL1Y_High EQU $A9CA
sLvlScrollUpdL1Y_Low  EQU $A9CB
sLvlScrollUpdL1X_High EQU $A9CC
sLvlScrollUpdL1X_Low  EQU $A9CD
sLvlScrollUpdU1Y_High EQU $A9CE
sLvlScrollUpdU1Y_Low  EQU $A9CF
sLvlScrollUpdU1X_High EQU $A9D0
sLvlScrollUpdU1X_Low  EQU $A9D1
sLvlScrollUpdD1Y_High EQU $A9D2
sLvlScrollUpdD1Y_Low  EQU $A9D3
sLvlScrollUpdD1X_High EQU $A9D4
sLvlScrollUpdD1X_Low  EQU $A9D5
sStaticScreenMode EQU $A9D6 ; If set, the current screen is single-screen and unscrollable. Not all are like this.
sTitleRetVal EQU $A9D7 ; Return value for the title screen code
s_X_TitleNext EQU $A9D7
sCourseClrBonusEnd EQU $A9D7 	; Reminder to switch to the Treasure Room once the bonus games return to the Course Clear screen
								; This is because
sEndingRetVal EQU $A9D7 ; Marks the ending code as being finished
sPl_Unused_DragonFlameBGColiSolid EQU $A9D8
sSaveFileError EQU $A9D9 ; Bitmask with save files marked as bad
sSaveFileErrorCharId EQU $A9DA ; Offset to current letter in SAVE FILE RRROR message
sSaveBrickPosIndex EQU $A9DB
s_Index_A9DD EQU $A9DD
sMapBlinkLevelCur EQU $A9DD
sTreasureId EQU $A9DD ; ID of the treasure collected
sTreasureActSlotPtr_High EQU $A9DE ; Ptr to actor slot with the treasure
sTreasureActSlotPtr_Low EQU $A9DF ; Ptr to actor slot with the treasure
sTrRoomSparkleActive EQU $A9E0 ; If set, a ExAct_TrRoom_Sparkle is currently active 
sTrRoomSparkleIndex EQU $A9E1 ; Index for the above, to cycle between treasures to spawn over
sTrRoomSparkleIndexAdd EQU $A9E2 ; Index will be increased by this amount
sLvlBlockSwitchReq EQU $A9E3 ; If set ($01 or $10) triggers the block replacement effect on the next door transition.
sCourseNum EQU $A9E4
sAltLevelClear EQU $A9E5 ; If set, marks a level clear for the alternate exit
sPlNewAction EQU $A9E6 ; Set when starting a new action
sTrainShakeTimer EQU $A9E7
sPlIce EQU $A9E8
sPlIceDelayTimer EQU $A9E9 ; Timer before the player movement is updated (for the delayed movement on ice)
sPlIceDelayDir EQU $A9EA ; Enables the ice delay timer
sHurryUp EQU $A9EB ; Hurry up status. 0: None; 1:Playing chime,fast music; 2:Fast music
sPlBreakCombo EQU $A9EC ; Bricks destroyed at the same time
sLvl_Unused_BlockSwitch1Req EQU $A9ED
sTmp_A9EE EQU $A9EE	; Temporary variable to save the 'a' register
sExActCount EQU $A9EF
sExActLeft  EQU $A9F0 ; Copy of sExActCount which gets decremented as ExOBJ are processed
sExActOBJYRel EQU $A9F1 ; Relative Y pos
sExActOBJXRel EQU $A9F2 ; Relative X pos
;--
sExAct_X_A9F3 EQU $A9F3 
sExActTrRoomArrowDespawn EQU $A9F3 
sExActTrRoomTreasureDespawn EQU $A9F3 
sExActTrRoomTreasureNear EQU $A9F3 ; The treasure signals that it's near the player
sExActMoneybagStackMode EQU $A9F3 ; Signals out to add another moneybag to the stack
;--
sCreditsRow1LineId EQU $A9F4 ; ID of the line to display in the first row of the credits
sCreditsRow2LineId EQU $A9F5 ; ID of the line to display in the second row of the credits
sPlBGColiBlockIdNext EQU $A9F6 ; Block ID with less priority (to check later down the frame)
sPlBGColiBlockOffset1Next_High EQU $A9F7 ; High byte (Y pos) of block with less priority
sPlSuperJumpSet EQU $A9F8 ; If set, requests the next jump to be a super jump (and determines jump SFX played)
sPlSuperJump EQU $A9F9 ; Marks a currently active super jump
sStatusEdit EQU $A9FA ; Enables "debug mode" (status bar editor)
sStatusEditY EQU $A9FB ; Cursor position
sStatusEditX EQU $A9FC ; Cursor position
sPlBGColiSolidReadOnly EQU $A9FD ; Read-only flag for solid blocks for collision check subroutines ; sPlBGColiSolidReadOnly
sLvlBlockSwitch EQU $A9FE ; Determines if the ! block is pressed or unpressed. Determines the block tiles the ! block uses.
sDebugToggleCount EQU $A9FF ; 

;--
sExAct EQU $AA00
sExActSet EQU $AAE0

sExActOBJY_High EQU $AAE1 ; 2 byte coord mode
sExActOBJY_Low EQU $AAE2
sExActOBJX_High EQU $AAE3
sActBridgeSpawned EQU $AAE4
sExActOBJX_Low EQU $AAE4
sExActOBJLstId EQU $AAE5
sExActOBJFlags EQU $AAE6
sExActLevelLayoutPtr_High EQU $AAE7
sExActLevelLayoutPtr_Low EQU $AAE8
sExActRoutineId EQU $AAE9
sExActTimer EQU $AAEA ; Timer before ending an action
sExActOBJFixY EQU $AAEB	; 1 byte coord mode
sExActOBJFixX EQU $AAEC
sExActAnimTimer EQU $AAED ; Timer used for indexing OBJLstAnimOff tables
;-------
; Custom properties, ExAct-specific
sExAct09_TblIndex EQU $AAEA
sExActSparkle_FrameId EQU $AAEA
sExActSparkle_LoopCount EQU $AAE9
;--
sExActSet2 EQU $AAF0 ; Secodary set; can't be used directly
sExActArea_End EQU $AB00 ; End of the Extra Actor area. 
;--

sLevelAnimGFX EQU $AB00 ; Where all frames of the animated tiles are stored ($100 bytes / $10 frames / 4 tiles with 4 frames each)
;	sLevelAnimTiles_Size EQU $0100;
sLvlScrollBlockTable EQU $AC00
sLvlScrollBGPtrWriteTable EQU $AC10 ; VRAM Ptrs to blocks
s_X_ScreenUpdateData EQU $AC30 ; DELETEME
sLvlScrollTileIdWriteTable EQU $AC30 ; Tile IDs to write for the above
sEndingText EQU $AC30 ; Tile IDs to display for the current frame
sSavePipeAnimTiles EQU $AC30 ; Where the tile IDs are stored
sUnused_AC83 EQU $AC83
sAct_Unused_LastSetRoutineId EQU $AC84 ; [TCRF] Never read back
sAct_Unused_InteractDirType EQU $AC85 ; [TCRF] Never read back
sStatusEditToggleCount EQU $AC86 ; Toggle count for status bar editor (debug)
sPlPower_Unused_Copy EQU $AC87 ; [TCRF] Only written to
sLevelAnimFrame EQU $AC88 ; Currently displayed frame number (0-3)
sLvlScrollLocks EQU $ACE0 ; $20 byte area with scroll lock info of all $20 sectors
sLevelBlocks EQU $AD00 ; 16x16 block defs

;--
; 16x16 fixed blocks (expected to always be there)
sLevelBlock_Switch0 EQU $ADC8
sLevelBlock_Switch1 EQU $ADE0
sLevelBlock_Switch2 EQU $ADE4
;--
sWorkOAM EQU $AF00 ; Position of the OAM copy ($9F bytes)
sWorkOAM_End EQU $AFA0
;--
; Fixed WorkOAM addresses
; for OBJ which are expected to be in specific slots.

sSaveDigit0 EQU $AF00
sSaveDigit1 EQU $AF04
sSaveDigit2 EQU $AF08
sSaveDigit3 EQU $AF0C
sSaveDigit4 EQU $AF10
sSaveDigit5 EQU $AF14

sSaveBrick0 EQU $AF18
sSaveBrick1 EQU $AF1C
sSaveBrick2 EQU $AF20
sSaveBrick3 EQU $AF24
sSaveBrick4 EQU $AF28
sSaveBrick5 EQU $AF2C



sActLayout EQU $B000
sActLayout_End EQU $C000

sMapEvTileId EQU $B040 ; Next tile ID to place for the map event
sMapEvBGPtr EQU $B041 ; Where to place the tile ID from above. Ptr to the tilemap.


;--

; Teapot lid
sMapMtTeapotLidY                           EQU $B130
sMapMtTeapotLidScrollYLast                 EQU $B131
sMapMtTeapotLidScrollXLast                 EQU $B132
sMapMtTeapotLidX                           EQU $B133
sMapMtTeapotLidFlags                       EQU $B134
sMapMtTeapotLidLstId                       EQU $B135
; Teapot steam sprout
sMap_Unused_MtTeapotSproutY                EQU $B136
sMap_Unused_MtTeapotSproutX                EQU $B137
sMap_Unused_MtTeapotSproutFlags            EQU $B138
sMap_Unused_MtTeapotSproutLstId            EQU $B139
; World clear flags and anim timers
sMapRiceBeachFlagY                         EQU $B13A
sMapRiceBeachFlagScrollYLast               EQU $B13B
sMapRiceBeachFlagScrollXLast               EQU $B13C
sMapRiceBeachFlagX                         EQU $B13D
sMapOverworldFlagFlags                     EQU $B13E
sMapRiceBeachFlagLstId                     EQU $B13F
sMapMtTeapotFlagLstId                      EQU $B140
sMapStoveCanyonFlagLstId                   EQU $B141
sMapSSTeacupFlagLstId                      EQU $B142
sMapParsleyWoodsFlagLstId                  EQU $B143
sMapSherbetLandFlagLstId                   EQU $B144
sMap_Unused_SyrupCastleFlagLstId           EQU $B145
sMapRiceBeachFlagTimer                     EQU $B146
sMapC32CutsceneTimerTarget                 EQU $B146
sMapMtTeapotFlagTimer                      EQU $B147
sMapLakeSproutAnimTimer                    EQU $B147
sMapStoveCanyonFlagTimer                   EQU $B148
sMapLakeDrainAnimTimer                     EQU $B148
sMapSSTeacupFlagTimer                      EQU $B149
sMapParsleyWoodsFlagTimer                  EQU $B14A
sMapSherbetLandFlagTimer                   EQU $B14B
sMap_Unused_SyrupCastleFlagTimer           EQU $B14C
sMapMtTeapotFlagY                          EQU $B14D
sMapMtTeapotFlagScrollYLast                EQU $B14E
sMapMtTeapotFlagScrollXLast                EQU $B14F
sMapMtTeapotFlagX                          EQU $B150
sMapStoveCanyonFlagY                       EQU $B151
sMapStoveCanyonFlagScrollYLast             EQU $B152
sMapStoveCanyonFlagScrollXLast             EQU $B153
sMapStoveCanyonFlagX                       EQU $B154
sMapSSTeacupFlagY                          EQU $B155
sMapSSTeacupFlagScrollYLast                EQU $B156
sMapSSTeacupFlagScrollXLast                EQU $B157
sMapSSTeacupFlagX                          EQU $B158
sMapParsleyWoodsFlagY                      EQU $B159
sMapParsleyWoodsFlagScrollYLast            EQU $B15A
sMapParsleyWoodsFlagScrollXLast            EQU $B15B
sMapParsleyWoodsFlagX                      EQU $B15C
sMapSherbetLandFlagY                       EQU $B15D
sMapSherbetLandFlagScrollYLast             EQU $B15E
sMapSherbetLandFlagScrollXLast             EQU $B15F
sMapSherbetLandFlagX                       EQU $B160
sMap_Unused_SyrupCastleFlagY               EQU $B161
sMap_Unused_SyrupCastleFlagScrollYLast     EQU $B162
sMap_Unused_SyrupCastleFlagScrollXLast     EQU $B163
sMap_Unused_SyrupCastleFlagX               EQU $B164
sMapFlagLstIdPtr_High                      EQU $B165
sMapFlagLstIdPtr_Low                       EQU $B166
sMapFadeTimer                              EQU $B167
sMapCutsceneEndTimer                       EQU $B167
sMapLakeDrainLstIdTarget                   EQU $B167
sMapMtTeapotLidYTimer                      EQU $B168
sMapC32CutsceneTimer                       EQU $B168
sMapPathsPtr_High                          EQU $B169
sMapPathsPtr_Low                           EQU $B16A
sMapValidPaths                             EQU $B16B
sMapTileCopyCounter                        EQU $B16E
; For maps with more than 8 exits, which don't exist. These arent't saved anyway.
sMap_Unused_RiceBeachCompletionHigh        EQU $B16F
sMap_Unused_RiceBeachCompletionHighLast    EQU $B170
sMap_Unused_MtTeapotCompletionHigh         EQU $B171
sMap_Unused_MtTeapotCompletionHighLast     EQU $B172
sMap_Unused_StoveCanyonCompletionHigh      EQU $B173
sMap_Unused_StoveCanyonCompletionHighLast  EQU $B174
sMap_Unused_SSTeacupCompletionHigh         EQU $B175
sMap_Unused_SSTeacupCompletionHighLast     EQU $B176
sMap_Unused_ParsleyWoodsCompletionHigh     EQU $B177
sMap_Unused_ParsleyWoodsCompletionHighLast EQU $B178
sMap_Unused_SherbetLandCompletionHigh      EQU $B179
sMap_Unused_SherbetLandCompletionHighLast  EQU $B17A
sMap_Unused_SyrupCastleCompletionHigh      EQU $B17B
sMap_Unused_SyrupCastleCompletionHighLast  EQU $B17C
sMapOverworldCompletion                    EQU $B17D
sMapShake                                  EQU $B17E ; screen shake effect flag
sMapOverworldCutsceneScript                EQU $B17F
sMapScrollYShake                           EQU $B180 ; alternate ScrollY value used on screen shake effect
sMap_Unused_LakeSproutYCopy                EQU $B181
sMap_Unused_LakeSproutXCopy                EQU $B182
sMapLakeSproutY                            EQU $B183
sMapLakeSproutX                            EQU $B184
sMapLakeSproutLstId                        EQU $B185
sMapLakeSproutFlags                        EQU $B186
sMap_Unused_LakeDrainYCopy                 EQU $B187
sMap_Unused_LakeDrainXCopy                 EQU $B188
sMapLakeDrainY                             EQU $B189
sMapLakeDrainX                             EQU $B18A
sMapLakeDrainLstId                         EQU $B18B
sMapLakeDrainFlags                         EQU $B18C
sMap_Unused_VMove                          EQU $B191
sMap_Unused_HMove                          EQU $B192
sMap_Unknown_TimerLowCopy                  EQU $B193
sMap_Unused_ExplTimer                      EQU $B196
sMapC32ClearFlag                           EQU $B198
sMapSyrupCastleInvertPal                   EQU $B19B
; Extra sprites                            
sMapExOBJ0Y                                EQU $B19C
sMapExOBJ0X                                EQU $B19D
sMapExOBJ1Y                                EQU $B19E
sMapExOBJ1X                                EQU $B19F
sMapExOBJ2Y                                EQU $B1A0
sMapExOBJ2X                                EQU $B1A1
sMapExOBJ3Y                                EQU $B1A2
sMapExOBJ3X                                EQU $B1A3
sMapExOBJ0LstId                            EQU $B1A4
sMapExOBJ1LstId                            EQU $B1A5
sMapExOBJ2LstId                            EQU $B1A6
sMapExOBJ3LstId                            EQU $B1A7
sMapExOBJ0Flags                            EQU $B1A8
sMapExOBJ1Flags                            EQU $B1A9
sMapExOBJ2Flags                            EQU $B1AA
sMapExOBJ3Flags                            EQU $B1AB
sMapVisibleArrows                          EQU $B1AC
sMapCurArrow                               EQU $B1AD
; Explosion sprites and others                    
sMapExplOBJ0Y                              EQU $B1AE
sMapEndingHeliY                            EQU $B1AE
sMapExplOBJ0X                              EQU $B1AF
sMapEndingHeliX                            EQU $B1AF
sMapExplOBJ0LstId                          EQU $B1B0
sMapEndingHeliLstId                        EQU $B1B0
sMapExplOBJ0Flags                          EQU $B1B1
sMapEndingHeliFlags                        EQU $B1B1
sMapExplOBJ1Y                              EQU $B1B2
sMapExplOBJ1X                              EQU $B1B3
sMapExplOBJ1LstId                          EQU $B1B4
sMapExplOBJ1Flags                          EQU $B1B5
sMapExplOBJ2Y                              EQU $B1B6
sMapExplOBJ2X                              EQU $B1B7
sMapExplOBJ2LstId                          EQU $B1B8
sMapExplOBJ2Flags                          EQU $B1B9
sMapExplOBJ3Y                              EQU $B1BA
sMapExplOBJ3X                              EQU $B1BB
sMapExplOBJ3LstId                          EQU $B1BC
sMapExplOBJ3Flags                          EQU $B1BD
sMapSyrupCastleCutsceneTimer               EQU $B1BE
sMapSyrupCastleWaveTablePtr_High           EQU $B1BF
sMapSyrupCastleWaveTablePtr_Low            EQU $B1C0
sMapAutoEnterOnPathEnd                     EQU $B1C1
sMapEndingStatueHighY                      EQU $B1C2
sMapEndingStatueHighX                      EQU $B1C3
sMapEndingStatueHighLstId                  EQU $B1C4
sMapEndingStatueHighFlags                  EQU $B1C5
sMapEndingStatueLowY                       EQU $B1C6
sMapEndingStatueLowX                       EQU $B1C7
sMapEndingStatueLowLstId                   EQU $B1C8
sMapEndingStatueLowFlags                   EQU $B1C9
sMapEndingSparkleY                         EQU $B1CA
sMapEndingSparkleX                         EQU $B1CB
sMapEndingSparkleLstId                     EQU $B1CC
sMapEndingSparkleFlags                     EQU $B1CD
sMapFreeView                               EQU $B1CE
sMapEndingLampY                            EQU $B1CF
sMapEndingLampX                            EQU $B1D0
sMapEndingLampLstId                        EQU $B1D1
sMapEndingLampFlags                        EQU $B1D2
sMapSyrupCastleCutsceneAct                 EQU $B1D3
sMapBlinkLevelPtr_High                     EQU $B1D5
sMapBlinkLevelPtr_Low                      EQU $B1D6
sMapBlinkId                                EQU $B1D7
sMapBlinkDoneFlags                         EQU $B1D8
sMapWorldClearTimer                        EQU $B1D9
sMapAnimFrame_Misc                         EQU $B1DA
;--

; From this point on, some variables are marked as "wStatic"
; These are used in "Static Screen" modes, like the Title screen and bonus game.
; [NOTE] Some of these named "wTitle" should probably be renamed to "wStatic", since they are common.
;        (and chances are, "Static Screen Mode" is just a VBlank handler hack around the two
;         very different programming conventions used between intro/ending/bonus games and *everything else*)

wLevelLayout    EQU $C000
wLevelLayout_End EQU $E000

wTitleMode      EQU $C0A0 ; Title screen mode
wHeartBonusMode EQU $C0A0
wCoinBonusMode EQU $C0A0
wEndingMode EQU $C0A0

wStaticAnimMode EQU $C0A1 ; Tile animation mode for static screens

wStaticOBJCount      EQU $C0A2 ; Number of OBJ written to OAM (for static screens that call Static_WriteOBJLst)

wStaticPlLstId     EQU $C0A3
wStaticPlX         EQU $C0A4
wStaticPlY         EQU $C0A5
wStaticPlFlags     EQU $C0A6
wStaticPlAnimTimer EQU $C0A7
wHeartBonusResultsTimer EQU $C0A7

wIntroWarioLstId     EQU $C0A3
wIntroWarioX         EQU $C0A4
wIntroWarioY         EQU $C0A5
wIntroWarioFlags     EQU $C0A6
wIntroWarioAnimTimer EQU $C0A7

w_X_C0A8_Act    EQU $C0A8
wIntroAct  EQU $C0A8
wCoinBonusAct  EQU $C0A8
wHeartBonusAct EQU $C0A8
wEndAct EQU $C0A8

wIntroWarioAnimCycleLeft EQU $C0A9
wEndLoopsLeft EQU $C0A9 ; Counts down how long to play certain animations
wEndLampRubLoopsLeft EQU $C0A9
wHeartBonusTileAnim EQU $C0AA ; Marks if tile animations should be enabled in the Heart Bonus game
w_X_C0AB_Timer EQU $C0AB
wTitleTileAnimTimer EQU $C0AB
wIntroWaterOscillationTimer EQU $C0AB
wBonusAnimTimer EQU $C0AB

wTitleActTimer EQU $C0AD
wIntroActTimer1 EQU $C0AD
wCoinBonusModeTimer EQU $C0AD ; After hitting moneybag or 10ton
wHeartBonusModeTimer EQU $C0AD ; Multiple purposes -- generally waits to switch to the next mode/submode
wEndPlMoveLDelay EQU $C0AD ; Before walking left to the treasure room

wIntroShipLstId EQU $C0AE
wIntroShipX EQU $C0AF
wIntroShipY EQU $C0B0
wIntroActTimer EQU $C0B1 ; General act timer / ship anim timer?

wIntroWaterSplash EQU $C0B2
wIntroWaterSplashY EQU $C0B3

; Sprite options for the actor held by the player
; In the first part (Ending0) it's a lamp.
; In the second part (Ending1) it's the moneybags.
wEndHeldLstId EQU $C0B4
wEndHeldX EQU $C0B5
wEndHeldY EQU $C0B6
wEndLampThrowTimer EQU $C0B7

wEndCloudLstId EQU $C0B8
wEndWLogoLstId EQU $C0B8 ; Same sprite mapping table as wEndCloudLstId technically

; wEndCloud0X also used for the "thinking" cloud
wEndCloud0X EQU $C0B9	; Coords for first cloud
wEndWLogoX EQU $C0B9
wEndCloud0Y EQU $C0BA
wEndWLogoY EQU $C0BA
wEndCloud1Show EQU $C0BB ; Set to 1 when the second cloud is visible
wEndCloud1X EQU $C0BC	; Coords for second cloud
wEndCloud1Y EQU $C0BD


wEndCloudAnimTimer EQU $C0BE 
wEndWLogoTimer EQU $C0BE ; For the "W" mark before the credits start

wEndGenieFaceLstId EQU $C0BF

wEnd_Unknown_C0C0_AnimDelay EQU $C0C0
wEndBGFlashTimer EQU $C0C0
wEndGenieTimer EQU $C0C0
wEndThrowDelay EQU $C0C0 ; Wait before throwing moneybags
wEndBGWaveOffset EQU $C0C1 ; Offset to wave effect tables, increased at the end of the frame to make the waves look like they're moving up

wEndBalloonLstId EQU $C0C2 ; Marks who's speaking, placed on the edge of the balloon tilemap
wEndBalloonFrameSet EQU $C0C3
wEndGenieHandLFrameSet EQU $C0C4 ; Requested frame for genie's hands
wEndGenieHandRFrameSet EQU $C0C5
wEndFlagAnimType EQU $C0C6 ; Flag animation type
wEndFlagAnimTimer EQU $C0C7 ; Flag animation timer
 
wHeartBonusShowCursor EQU $C0C8 ; If set, it shows the cursor in the select screen
wCoinBonusPlayerPos EQU $C0C9 ; Player position in coin bonus game
wHeartBonusDifficultySel EQU $C0C9 ; Doubles as menu cursor (with $03 being the exit)
wHeartBonusShowResultFlash EQU $C0CA ; If set, enables the black line flashing on the prize won in the result screen

wHeartBonusHudBombLstId EQU $C0CB ; Temporary value for the frame id of the currently drawn Bomb in the HUD.
wHeartBonusHudBomb0LstId EQU $C0CC ; 1st bomb
wHeartBonusHudBomb1LstId EQU $C0CD ; 2nd bomb
wHeartBonusHudBomb2LstId EQU $C0CE ; ...
wHeartBonusHudBomb3LstId EQU $C0CF ; ...
wHeartBonusHudBomb4LstId EQU $C0D0 ; ...

wHeartBonusHitCount EQU $C0D2 ; Number of hit enemies
wCoinBonusItemLstId EQU $C0D3 ; OBJLst frame id
wHeartBonusBombLstId EQU $C0D3 ; OBJLst frame id - bomb
wCoinBonusItemX EQU $C0D4 ; X pos of spawned item
wHeartBonusBombX EQU $C0D4 ; X pos of explosion
wCoinBonusItemY EQU $C0D5 ; Y pos of spawned item
wHeartBonusBombY EQU $C0D5 ; Y pos of explosion
wHeartBonusBombThrowPathIndex EQU $C0D6 ; Index to the "HeartBonus_ThrowPath*" tables 
wHeartBonusExplTimer EQU $C0D6

wHeartBonusRoundNum EQU $C0D7 ; Round number
wHeartBonusTextLstId EQU $C0D8 ; Text type
wHeartBonusBombLightLstId EQU $C0D9 ; for the fire on the bomb fuse, aligned so it reaches the bomb when the timer ticks 0
wHeartBonusBombLightX EQU $C0DA ;
wHeartBonusBombLightY EQU $C0DB ;
wHeartBonusBombLightTimer EQU $C0DC ; Anim timer
wHeartBonusShowTime EQU $C0DD ; Shows the time limit in the hud
wHeartBonusTimeDecTimer EQU $C0DE ; Time limit -- "subseconds". Once it reaches $46, wHeartBonusTime decreases by 1.
wHeartBonusTime EQU $C0DF ; Time limit -- doubles as OBJLst id of digit
wHeartBonusDigitLstId EQU $C0DF ; ...and it's used for other types of digits as well (just not during main game)

wHeartBonusEnemyLstId EQU $C0E0 ; Enemy to hit with the bomb
wHeartBonusEnemyX EQU $C0E1 
wHeartBonusEnemyY EQU $C0E2
wHeartBonusEnemyFlags EQU $C0E3 ; Determines X flip
wHeartBonusEnemyTimer EQU $C0E4 ; Animation timer

wHeartBonusShowPowerSel EQU $C0E5 ; If set, shows the arrow above the current throw power in the HUD
wHeartBonusPowerSelX EQU $C0E6
wHeartBonusThrowPower EQU $C0E7 ; When reaches a certain value, the X pos resets
wHeartBonusThrowPathId EQU $C0E7 ; The actual throw power of the bomb ($00-$07)

wHeartBonusShowHudLivesHearts EQU $C0EB
wHeartBonus_Unused_C0EC EQU $C0EC
wHeartBonusShowCoinCount EQU $C0EE

wHeartBonusPlMode EQU $C0EF ; 0: can move; 1: locked; 2: throw

wHeartBonusCoinDec EQU $C0F0 ; Set when the game decrements coins after selecting a difficulty. Reset to $00 when it's done.
wHeartBonusEnemyHit EQU $C0F0 ; If set, the enemy moves vertically and is marked as hit.

wCoinBonusItemType EQU $C0F0 ; The actual item spawned
wHeartBonus_Unknown_EnemyType EQU $C0F0 ; seems similar to above, verify
wBonusGameCoinChange_High EQU $C0F1 ; Amount of coins to add or remove
wHeartBonusLivesChange EQU $C0F1 ; Amount of hearts to add
wBonusGameCoinChange_Low EQU $C0F2
wHeartBonusHeartsChange EQU $C0F2 ; Amount of lives to add (effectively treated like the low byte)
wCoinBonusItemTypeR EQU $C0F3	; COINBONUS_ITEM_* on the right bucket
wCoinBonusItemTypeL EQU $C0F4	; COINBONUS_ITEM_* on the left bucket

wCoinBonusBucketFrameSet EQU $C0E8 ; Requested tilemap update type in coin bonus game
wCoinBonusRoundBGChg EQU $C0E9 ; If a tilemap change is requested for updating the round number text
wCoinBonusRound EQU $C0EA ; Bonus game round number



hJoyKeys EQU $FF80
hJoyNewKeys EQU $FF81
hVBlankDone EQU $FF82
hIntEnable EQU $FF83
hScrollY EQU $FF87
hOAMDMA EQU $FFB6 ; Location of the OAMDMA code in HRAM

SECTION "VRAM", VRAM

SECTION "SRAM", SRAM

SECTION "WRAM", WRAM0

SECTION "HRAM", HRAM