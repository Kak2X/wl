; ====================================
; =============== VRAM ===============
; ====================================
; As a rule of thumb, anything marked as vGFX should be remapped if its tiles are rerranged

; =============== Main ===============
DEF vGFXHatPrimary             EQU $8000
DEF vGFXHatSecondary           EQU $83B0

; Shared sprites
DEF vGFXLevelSharedOBJ         EQU $8000
DEF vGFXLevelSharedOBJ_Size    EQU $0B00

; Status bar (+ misc OBJ which got thrown here for lack of space)
DEF vGFXStatusBar              EQU $8B00
DEF vGFXStatusBar_Size         EQU $0200
DEF vGFXStatusBar_End          EQU vGFXStatusBar + vGFXStatusBar_Size

DEF vGFXActors                 EQU $8D00
DEF vGFXActors_End             EQU $9000
DEF vGFXActorsSec              EQU $8A00 ; Overlaps with end of SharedOBJ

DEF vGFXStunStar               EQU $8FF0

; Main level tiles
DEF vGFXLevelMain              EQU $9200
DEF vGFXLevelMain_Size         EQU $0600

; Common blocks
DEF vGFXLevelSharedBlocks      EQU $9000
DEF vGFXLevelSharedBlocks_Size EQU $0200


; =============== Title Screen ===============

; all frames are already in the tilemap
DEF vGFXTitleWaterAnimGFX0     EQU $8DC0
DEF vGFXTitleWaterAnimGFX1     EQU $8DE0
; and get copied to this area
DEF vGFXTitleWaterAnim         EQU $8920

; =============== Map Screen ===============
DEF vGFXMapOverworldAnim       EQU $8AA0

; Animated 1bpp tiles locations for Rice Beach
DEF vGFXMapRiceBeachAnim0      EQU $9500
DEF vGFXMapRiceBeachAnim1      EQU $9510
DEF vGFXMapRiceBeachAnim2      EQU $9600
DEF vGFXMapRiceBeachAnim3      EQU $9610
DEF vGFXMapRiceBeachAnim4      EQU $9620
DEF vGFXMapRiceBeachAnim5      EQU $9700
DEF vGFXMapRiceBeachAnim6      EQU $9710
DEF vGFXMapRiceBeachAnim7      EQU $9720
DEF vGFXMapRiceBeachAnim8      EQU $9730
DEF vGFXMapRiceBeachAnim9      EQU $9740

; 2x2 area essentially
; code in Map_StoveCanyon_ScreenEvent assumes the graphics data is organized like this
DEF vGFXMapStoveCanyonAnim0    EQU $94A0 ; top left
DEF vGFXMapStoveCanyonAnim1    EQU $94B0 ; top right
DEF vGFXMapStoveCanyonAnim2    EQU $95A0 ; bottom left
DEF vGFXMapStoveCanyonAnim3    EQU $95B0 ; bottom right

DEF vGFXMapSSTeacupAnim0       EQU $8B50
DEF vGFXMapSSTeacupAnim1       EQU $8B60

DEF vBGCourseText0             EQU $98E7 ; "COURSE"
DEF vBGCourseText1             EQU $9928 ; "No."
DEF vBGCourseNum0              EQU $992A ; High digit of course number
DEF vBGCourseNum1              EQU $992B ; Low digit of course
DEF vBGCourseLvlId0            EQU $9A11 ; High digit of level id (debug mode only)
DEF vBGCourseLvlId1            EQU $9A12 ; Low digit of level id (debug mode only)

; =============== Gameplay ===============
DEF vBGStatusBarRow0           EQU $9C00
DEF vBGStatusBarRow1           EQU $9C20
DEF vBGStatusBarCourseNum      EQU $9C23
DEF vBGLives                   EQU $9C03
DEF vBGLevelCoins              EQU $9C08
DEF vBGHearts                  EQU $9C0D

DEF vBGLevelTime               EQU $9C11
DEF vBGTotalCoins              EQU $9C2F

; SS Teacup Boss parts
DEF vBGSSTeacupBossBody        EQU $9992
DEF vBGSSTeacupBossWing        EQU $9A33
DEF vBGSSTeacupBossBeak        EQU $9A14
DEF vBGSSTeacupBossEyes        EQU $9994
DEF vBGSSTeacupBossClaws       EQU $9A51

; Stove Canyon Boss parts
DEF vBGStoveCanyonBossBody     EQU $99B4
DEF vBGStoveCanyonBossMouth    EQU $9A54

; Genie Boss
DEF vGFXGenieBoss              EQU $8A00
DEF vBGGenieBossGround0        EQU $9BC0 ; Upper 8x8 tiles
DEF vBGGenieBossGround1        EQU vBGGenieBossGround0 + BG_TILECOUNT_H ; Lower 8x8 tiles
DEF vBGGenieBossBody           EQU $99D2
DEF vBGGenieBossHandL          EQU $9A10
DEF vBGGenieBossHandR          EQU $9A19
DEF vBGGenieBossFootL          EQU $9AB2
DEF vBGGenieBossFootR          EQU $9AB7
DEF vBGGenieBossFace           EQU $99D5

; Heart game
DEF vGFXBigHeart0              EQU $8D00
DEF vGFXBigHeart1              EQU $8E90


; =============== Save Select ===============
DEF vBGSavePipe                EQU $99A2

; =============== Treasure Room ===============
DEF vBGTrRoomLevelCoinsSep     EQU $984E
DEF vBGTrRoomLevelCoins        EQU $984F

DEF vBGTrRoomTotalCoinIcon     EQU $98A3
DEF vBGTrRoomTotalCoinsDigit0  EQU $98A7+($02*0)
DEF vBGTrRoomTotalCoinsDigit1  EQU $98A7+($02*1)
DEF vBGTrRoomTotalCoinsDigit2  EQU $98A7+($02*2)
DEF vBGTrRoomTotalCoinsDigit3  EQU $98A7+($02*3)
DEF vBGTrRoomTotalCoinsDigit4  EQU $98A7+($02*4)

DEF vBGTrRoomTreasureA         EQU $9928
DEF vBGTrRoomTreasureB         EQU $992A
DEF vBGTrRoomTreasureC         EQU $992C
DEF vBGTrRoomTreasureD         EQU $992E
DEF vBGTrRoomTreasureE         EQU $9930
DEF vBGTrRoomTreasureF         EQU $9968
DEF vBGTrRoomTreasureG         EQU $996A
DEF vBGTrRoomTreasureH         EQU $996C
DEF vBGTrRoomTreasureI         EQU $996E
DEF vBGTrRoomTreasureJ         EQU $9970
DEF vBGTrRoomTreasureK         EQU $99A8
DEF vBGTrRoomTreasureL         EQU $99AA
DEF vBGTrRoomTreasureM         EQU $99AC
DEF vBGTrRoomTreasureN         EQU $99AE
DEF vBGTrRoomTreasureO         EQU $99B0


; =============== Bonus Games ===============
DEF vGFXBonusGamePlHat         EQU $8010 ; GFX offset for Wario's hat. Expected to be in this location in the compressed GFX.

DEF vGFXHeartBonusAnimGFX0     EQU $96D0
DEF vGFXHeartBonusAnimGFX1     EQU $96E0
DEF vGFXHeartBonusAnim         EQU $96B0

DEF vBGCoinBonusBucketL        EQU $98A5
DEF vBGCoinBonusBucketR        EQU $98AC

DEF vBGCoinBonusRoundNum       EQU $9845

DEF vBGHeartBonusResultsDifficulty EQU $9809
DEF vBGHeartBonusResultsPrizes     EQU $984B

; =============== Time Up Screen ===============
DEF vBGTimeUpHandFingerBlock0  EQU $9968
DEF vBGTimeUpHandFingerBlock1  EQU $996A

DEF vBGTimeUpWarioBlock0       EQU $9C28
DEF vBGTimeUpWarioBlock1       EQU $9C2A

; =============== Game Over Screen ===============

DEF vBGGameOverWarioBlock0     EQU $98A8
DEF vBGGameOverWarioBlock1     EQU $98AA

; =============== Ending ===============
DEF vBGEndGenieHandL           EQU $9846
DEF vBGEndGenieHandR           EQU $986F

DEF vBGEndBalloon              EQU $9861

; =============== Credits ===============

DEF vGFXCreditsFlagsSAnimGFX0  EQU $8DE0
DEF vGFXCreditsFlagsSAnimGFX1  EQU $8DF0
DEF vGFXCreditsFlagsSAnim      EQU $8920
DEF vGFXCreditsFlagsLAnimGFX0  EQU $8BC0
DEF vGFXCreditsFlagsLAnimGFX1  EQU $8BE0
DEF vGFXCreditsFlagsLAnim      EQU $8E20

DEF vGFXCreditsPlanet          EQU $8BC0
DEF vGFXCreditsText            EQU $9400
DEF vGFXCreditsPagoda          EQU $9100

DEF vBGCreditsGround           EQU $99C0
DEF vBGCreditsBox              EQU $99C0 ; Replaces ground
DEF vBGCreditsRow1             EQU $99E0+$14 ; Initial coord for first row
DEF vBGCreditsBoxBlankRow2     EQU $9A00 ; When blanking the second row, it starts here
DEF vBGCreditsRow2             EQU $9A81
DEF vBGCreditsBoxBlankRow2_End EQU $9B00
DEF vBGCreditsBox_End          EQU $9C00

; The game only uses the first $100 bytes of the WINDOW map
DEF MyWINDOWMap_End            EQU $9D00



; ====================================
; ================ RAM ===============
; ====================================

; SAVEDATA




SECTION "Save Data", SRAM[$A000]
sSave1                                     :ds $20 ; EQU $A000
sSave1Bak                                  :ds $20 ; EQU $A020
sSave2                                     :ds $20 ; EQU $A040
sSave2Bak                                  :ds $20 ; EQU $A060
sSave3                                     :ds $20 ; EQU $A080
sSave3Bak                                  :ds $20 ; EQU $A0A0
sSave1Checksum                             :db     ; EQU $A0C0
sSave2Checksum                             :db     ; EQU $A0C1
sSave3Checksum                             :db     ; EQU $A0C2
sLastSave                                  :db     ; EQU $A0C3 ; Last entered pipe
sDemoId                                    :db     ; EQU $A0C4 ; Marks the demo to play

DEF sSaveData_End                                    EQU $A100
SECTION "Currently processed actor", SRAM[$A100]
sActSetStatus                              :db     ; EQU $A100 ; On-screen status
sActSetX_Low                               :db     ; EQU $A101 ; 2 byte coord mode
sActSetX_High                              :db     ; EQU $A102
sActSetY_Low                               :db     ; EQU $A103 ; 2 byte coord mode
sActSetY_High                              :db     ; EQU $A104
sActSetColiType                            :db     ; EQU $A105 ; Collision type
sActSetColiBoxU                            :db     ; EQU $A106 ; Collision box - up extend. Generally negative.
sActSetColiBoxD                            :db     ; EQU $A107 ; Collision box - down extend. Generally negative.
sActSetColiBoxL                            :db     ; EQU $A108 ; Collision box - left extend. Generally negative.
sActSetColiBoxR                            :db     ; EQU $A109 ; Collision box - right extend. Generally positive.
sActSetRelY                                :db     ; EQU $A10A ; Collision box Y origin. Box position is shifted down by this amount. Also used for 1 byte coord mode.
sActSetRelX                                :db     ; EQU $A10B ; Collision box X origin. Box position is shifted right by this amount. Also used for 1 byte coord mode.
sActSetOBJLstPtrTablePtr                   :ds $02 ; EQU $A10C ; Ptr to the currently drawn OBJLstPtrTable.
sActSetDir                                 :db     ; EQU $A10E ; Movement direction (*not* OBJ flags)
sActSetOBJLstId                            :db     ; EQU $A10F
sActSetId                                  :db     ; EQU $A110
sActSetRoutineId                           :db     ; EQU $A111 ; or sActSetPlIntMode -- Player interaction mode basically -- and in the upper nybble the "interaction direction" is stored (ACTINT_*)). When something is thrown at, the upper nybble contains the slot number of the actor which was thrown.
sActSetCodePtr                             :ds $02 ; EQU $A112
sActSetTimer                               :db     ; EQU $A114 ; Main execution timer
sActSetTimer2                              :db     ; EQU $A115 ; Custom.
sActSetTimer3                              :db     ; EQU $A116 ; Custom.
sActSetTimer4                              :db     ; EQU $A117 ; Custom.
sActSetTimer5                              :db     ; EQU $A118 ; Custom.
sActSetTimer6                              :db     ; EQU $A119 ; Custom.
sActSetTimer7                              :db     ; EQU $A11A ; Custom.
sActSetOpts                                :db     ; EQU $A11B ; Misc flags (ACTFLAGB_*)
sActSetLevelLayoutPtr                      :ds $02 ; EQU $A11C ; For permanent despawns mostly
sActSetOBJLstSharedTablePtr                :ds $02 ; EQU $A11E ; Ptr to the "shared table", so common subroutines (like the stunned actor) know which OBJLstPtrTable to apply. Each entry to this should be a valid OBJLstPtrTable.
DEF sActSet                                          EQU sActSetStatus ; Currently processed actor area
DEF sActSet_End                                      EQU sActSetStatus + $20

;--
; Timer assignments for actors

; COMMON USES
DEF sActModeTimer                                    EQU sActSetTimer2
DEF sActSetYSpeed_Low                                EQU sActSetTimer3
DEF sActSetYSpeed_High                               EQU sActSetTimer4
DEF sActLocalRoutineId                               EQU sActSetTimer5

; SHARED ACTORS
DEF sActHeldDelay                                    EQU sActSetTimer5
DEF sActThrowHSpeed                                  EQU sActSetTimer5
DEF sActThrowDead                                    EQU sActSetTimer6
DEF sActThrowNoColiTimer                             EQU sActSetTimer7
DEF sActStunDrop                                     EQU sActSetTimer7 ; Marks the actor as dropped
DEF sActBumpSoftAltHSpeed                            EQU sActSetTimer7
DEF sActStunGroundMoveAltHSpeed                      EQU sActSetTimer7
DEF sActStunStarParentSlot                           EQU sActSetTimer5 ; Slot number for the stunned actor -- to keep position in sync
DEF sActCoinGroundTimer                              EQU sActSetTimer2 ; Increases when a coin is on the ground
DEF sActStunPlatformHSpeed                           EQU sActSetTimer7 ; For the unused variant

; THE REST
DEF sActItemYSpeed                                   EQU sActSetTimer3
DEF sActItemRiseTimer                                EQU sActSetTimer4
DEF sActGoomTurnDelay                                EQU sActSetTimer2
DEF sActSparkAntiClockwise                           EQU sActSetTimer4
DEF sActSparkStepsLeft                               EQU sActSetTimer6
DEF sActSparkDir                                     EQU sActSetTimer7
DEF sActBigFruitDropTimer                            EQU sActSetTimer4
DEF sActBigFruitMoveDelay                            EQU sActSetTimer2
DEF sActBigFruitLandTimer                            EQU sActSetTimer7
DEF sActSpikeBallDropTimer                           EQU sActSetTimer4
DEF sActSpikeBallMoveDelay                           EQU sActSetTimer2
DEF sActSpikeBallLandTimer                           EQU sActSetTimer7
DEF sActSpearGoomTurnDelay                           EQU sActSetTimer2
DEF sActSpearGoomColiDelay                           EQU sActSetTimer5
DEF sActHelmutVDir                                   EQU sActSetTimer5 ; 0: Down; 1: Up
DEF sActSSTeacupBossModeTimer                        EQU sActSetTimer2
DEF sActSSTeacupBossRelXTarget                       EQU sActSetTimer4 ; Target X position compared against sActSetRelX
DEF sActSSTeacupBossRoutineId                        EQU sActSetTimer5 ; Movement mode for the boss
DEF sActSSTeacupBossHitCount                         EQU sActSetTimer6 ; Times the boss has been hit
DEF sActSSTeacupBossSpawnCount                       EQU sActSetTimer7 ; Number of spawned birds
DEF sActPouncerDropMoveUMask                         EQU sActSetTimer2 ; Movement mask when moving up.
DEF sActPouncerDropYTarget                           EQU sActSetTimer4
DEF sActPouncerDropPostDropDelay                     EQU sActSetTimer6
DEF sActPouncerDropPreDropDelay                      EQU sActSetTimer7
DEF sActPouncerFollowDir                             EQU sActSetTimer6 ; Direction value PCFW_DIR_*
DEF sActPouncerFollowDownDelay                       EQU sActSetTimer7 ; Cooldown timer before being able to move down again
DEF sActDrillerTurnTimer                             EQU sActSetTimer2 ; When it elapses, the actor turns
DEF sActDrillerSafeTouch                             EQU sActSetTimer5
DEF sActPuffYSpeed                                   EQU sActSetTimer3 ; Not normally used
DEF sActPuffRoutineId                                EQU sActSetTimer5
DEF sActLavaBubbleJumpDelay                          EQU sActSetTimer7
DEF sActCoinLockUnlockTimer                          EQU sActSetTimer2
DEF sActCoinLockOpenStatus                           EQU sActSetTimer5
DEF sActCartTrainCanMove                             EQU sActSetTimer5
DEF sActCartCanMove                                  EQU sActSetTimer5
DEF sActWolfTurnDelay                                EQU sActSetTimer2 ; When it elapses, the actor turns
DEF sActWolfModeTimer                                EQU sActSetTimer2 ; Times a mode before switching to the next
DEF sActWolfKnifeDelay                               EQU sActSetTimer3 ; Cooldown timer before throwing another knife
DEF sActWolfYSpeed                                   EQU sActSetTimer4
DEF sActWolfRoutineId                                EQU sActSetTimer5
DEF sActWolfMoveDelay                                EQU sActSetTimer6 ; Until it elapses, the actor can't move
DEF sActWolfKnifeTimer                               EQU sActSetTimer2
DEF sActPenguinTurnDelay                             EQU sActSetTimer2 ; When it elapses, the actor turns
DEF sActPenguinModeTimer                             EQU sActSetTimer2 ; Times a mode before switching to the next
DEF sActPenguinPostKickDelay                         EQU sActSetTimer3
DEF sActPenguinYSpeed                                EQU sActSetTimer4
DEF sActPenguinRoutineId                             EQU sActSetTimer5
DEF sActPenguinAlertDelay                            EQU sActSetTimer6 ; Until it elapses, the actor can't move
DEF sActPenguinSpawnDelay                            EQU sActSetTimer7
DEF sActPenguinSpikeTimer                            EQU sActSetTimer2
DEF sActDDTurnDelay                                  EQU sActSetTimer2 ; When it elapses, the actor turns
DEF sActDDModeTimer                                  EQU sActSetTimer2 ; Times a mode before switching to the next
DEF sActDDThrowDelay                                 EQU sActSetTimer3 ; Cooldown timer before throwing another boomerang
DEF sActDDYSpeed                                     EQU sActSetTimer4
DEF sActDDRoutineId                                  EQU sActSetTimer5
DEF sActDDMoveDelay                                  EQU sActSetTimer6 ; Until it elapses, the actor can't move
DEF sActCheckPointStatus                             EQU sActSetTimer5
DEF sActTreasureChestLidRoutineId                    EQU sActSetTimer5
DEF sActTreasurePopUpTimer                           EQU sActSetTimer2
DEF sActTreasureShineParentSlot                      EQU sActSetTimer5
DEF sActWatchRoutineId                               EQU sActSetTimer5
DEF sActChickenDuckModeTimer                         EQU sActSetTimer2
DEF sActChickenDuckRoutineId                         EQU sActSetTimer5
DEF sActMtTeapotBossModeTimer                        EQU sActSetTimer2
DEF sActMtTeapotBossCoinGameStarted                  EQU sActSetTimer2
DEF sActMtTeapotBossRoutineId                        EQU sActSetTimer5
DEF sActSherbetLandBossModeTimer                     EQU sActSetTimer2
DEF sActSherbetLandBossHeartGameStarted              EQU sActSetTimer2
DEF sActSherbetLandBossRoutineId                     EQU sActSetTimer5
DEF sActSherbetLandBossHitCount                      EQU sActSetTimer6 ; Times the boss has been hit
DEF sActRiceBeachBossModeTimer                       EQU sActSetTimer2
DEF sActRiceBeachBossHSpeed_Low                      EQU sActSetTimer3
DEF sActRiceBeachBossHSpeed_High                     EQU sActSetTimer4
DEF sActRiceBeachBossRoutineId                       EQU sActSetTimer5
DEF sActRiceBeachBossHitCount                        EQU sActSetTimer6 ; Times the boss has been hit
DEF sActRiceBeachBossDropSpeed                       EQU sActSetTimer7
DEF sActParsleyWoodsBossModeTimer                    EQU sActSetTimer2
DEF sActParsleyWoodsBossHSpeed_Low                   EQU sActSetTimer3
DEF sActParsleyWoodsBossHSpeed_High                  EQU sActSetTimer4
DEF sActParsleyWoodsBossRoutineId                    EQU sActSetTimer5
DEF sActParsleyWoodsBossHitCount                     EQU sActSetTimer6 ; Times the boss has been hit
DEF sActParsleyWoodsBossVSpeed                       EQU sActSetTimer7
DEF sActParsleyWoodsBossGhostModeTimer               EQU sActSetTimer2
DEF sActParsleyWoodsBossGhostGoomRoutineId           EQU sActSetTimer5
DEF sActStoveCanyonBossModeTimer                     EQU sActSetTimer2
DEF sActStoveCanyonBossUpMove                        EQU sActSetTimer2
DEF sActStoveCanyonBossRoutineId                     EQU sActSetTimer5
DEF sActStoveCanyonBossBallDelay                     EQU sActSetTimer6 ; If set, the boss throws a snot ball when the timer expires
DEF sActStoveCanyonBossHitCount                      EQU sActSetTimer7
DEF sActStoveCanyonBossBallModeTimer                 EQU sActSetTimer2
DEF sActStoveCanyonBossBallRoutineId                 EQU sActSetTimer5
DEF sActFloaterModeTimer                             EQU sActSetTimer2
DEF sActFloaterIdleIndex                             EQU sActSetTimer2 ; Indexes a movement table when the actor is idle (floating in circles)
DEF sActFloaterRoutineId                             EQU sActSetTimer5
DEF sActFloaterDir                                   EQU sActSetTimer6
DEF sActFloaterArrowParentSlot                       EQU sActSetTimer7
DEF sActKeyLockUnlockTimer                           EQU sActSetTimer2
DEF sActKeyLockOpenStatus                            EQU sActSetTimer5 ; sActKeyLockRoutineId
DEF sActBridgeModeTimer                              EQU sActSetTimer2
DEF sActBridgeRoutineId                              EQU sActSetTimer5
DEF sActSnowmanTurnDelay                             EQU sActSetTimer2
DEF sActSnowmanPostKickDelay                         EQU sActSetTimer3
DEF sActSnowmanYSpeed                                EQU sActSetTimer4 ; FIX_BUGS only
DEF sActSnowmanRoutineId                             EQU sActSetTimer5
DEF sActSnowmanShootDelay                            EQU sActSetTimer6
DEF sActSnowman_Unused_SpawnDelay                    EQU sActSetTimer7
DEF sActBigSwitchBlockModeTimer                      EQU sActSetTimer2
DEF sActBigSwitchBlockRoutineId                      EQU sActSetTimer5
DEF sActLavaWallRowsLeft                             EQU sActSetTimer2
DEF sActLavaWallTileIdU                              EQU sActSetTimer6
DEF sActLavaWallTileIdD                              EQU sActSetTimer7
DEF sActHermitCrabTurnDelay                          EQU sActSetTimer2
DEF sActHermitCrabRoutineId                          EQU sActSetTimer5
DEF sActSeahorseModeTimer                            EQU sActSetTimer2
DEF sActSeahorseRoutineId                            EQU sActSetTimer5
DEF sActSeahorseOrigY_Low                            EQU sActSetTimer3 ; Original spawn pos
DEF sActSeahorseOrigY_High                           EQU sActSetTimer4
DEF sActBigItemBoxModeTimer                          EQU sActSetTimer2
DEF sActBigItemBoxRoutineId                          EQU sActSetTimer5
DEF sActBombRoutineId                                EQU sActSetTimer5
DEF sActBombBlockExplIndex                           EQU sActSetTimer2
DEF sActBombThrown                                   EQU sActSetTimer6
DEF sActBombExplTimer                                EQU sActSetTimer7
DEF sActSyrupCastleBossYPathIndex                    EQU sActSetTimer2
DEF sActSyrupCastleBossBGYSpeed                      EQU sActSetTimer3 ; Mode 0f onlu
DEF sActSyrupCastleBossActYSpeed                     EQU sActSetTimer4 ; Mode 0f only
DEF sActSyrupCastleBossClearTimer                    EQU sActSetTimer2
DEF sActSyrupCastleBossModeIncTimer                  EQU sActSetTimer6 ; Set to a certain value and incremented by a common helper subroutine. Once it reaches a target value, the local rtn. id is increased.
DEF sActSyrupCastleBossSubRoutineId                  EQU sActSetTimer7
DEF sActLampStopDelay                                EQU sActSetTimer2 ; Lamp will not stop moving if != 0, for the min slide delay
DEF sActLampSmokeDespawnTimer                        EQU sActSetTimer2
DEF sActMiniGenieBlinkTimer                          EQU sActSetTimer2
DEF sActPelicanMoveTimer                             EQU sActSetTimer2
DEF sActPelicanThrowTimer                            EQU sActSetTimer6
DEF sActSpikePillarMoveTimer                         EQU sActSetTimer2
DEF sActCoinCrabAnimTimer                            EQU sActSetTimer2
DEF sActCoinCrabModeTimer                            EQU sActSetTimer2
DEF sActCoinCrabYOrig_Low                            EQU sActSetTimer6 ; Backup copy of the original spawn Y pos
DEF sActCoinCrabYOrig_High                           EQU sActSetTimer7
DEF sActStoveCanyonPlatformMoveTimer                 EQU sActSetTimer2
DEF sActStoveCanyonMinY                              EQU sActSetTimer3
DEF sActTogemaruBounceCount                          EQU sActSetTimer7
DEF sActThunderCloudShootTimer                       EQU sActSetTimer2
DEF sActThunderCloudHSpeed_Low                       EQU sActSetTimer3
DEF sActThunderCloudHSpeed_High                      EQU sActSetTimer4
DEF sActThunderCloudYOrig_Low                        EQU sActSetTimer5
DEF sActThunderCloudYOrig_High                       EQU sActSetTimer6
DEF sActMoleTurnDelay                                EQU sActSetTimer2 ; When it elapses, the actor turns
DEF sActMoleModeTimer                                EQU sActSetTimer2 ; Times a mode before switching to the next
DEF sActMoleThrowDelay                               EQU sActSetTimer3 ; Cooldown timer before throwing the spike
DEF sActMoleYSpeed                                   EQU sActSetTimer4
DEF sActMoleSpikeAction                              EQU sActSetTimer6 ; Used to send commands between parent and child
DEF sActMoleMoveDelay                                EQU sActSetTimer7 ; Until it elapses, the actor can't move
DEF sActMoleSpikePathIndex                           EQU sActSetTimer2
DEF sActMoleSpikeParentSlot                          EQU sActSetTimer5
DEF sActMoleSpikeMode                                EQU sActSetTimer6
DEF sActCrocJumpDelay                                EQU sActSetTimer2
DEF sActCrocJumpTimer                                EQU sActSetTimer6
DEF sActSealTurnTimer                                EQU sActSetTimer2
DEF sActSealRangeCheckDelay                          EQU sActSetTimer6 ; When it elapses, the actor checks if the player is in H range
DEF sActSealModeTimer                                EQU sActSetTimer2
DEF sActSealSpearTimer                               EQU sActSetTimer2
DEF sActBigHeartPopUpTimer                           EQU sActSetTimer6 ; Once
DEF sActSpiderTurnDelay                              EQU sActSetTimer2
DEF sActHedgehogTurnDelay                            EQU sActSetTimer2
DEF sActHedgehogSpikeTimer                           EQU sActSetTimer4 ; Times the attack sequence
DEF sActMoleCutsceneModeTimer                        EQU sActSetTimer2
DEF sActFireMissileModeTimer                         EQU sActSetTimer2
DEF sActStickBombModeTimer                           EQU sActSetTimer2
DEF sActStickBombPlRelY                              EQU sActSetTimer6 ; Stick distance to player
DEF sActStickBombPlRelX                              EQU sActSetTimer7 ; Stick distance to player
DEF sActKnightTurnDelay                              EQU sActSetTimer2
DEF sActKnightHitCount                               EQU sActSetTimer6 ; Times the boss has been hit
DEF sActKnightModeTimer                              EQU sActSetTimer7
DEF sActMiniBossLockUnlockTimer                      EQU sActSetTimer2
DEF sActFlyModeTimer                                 EQU sActSetTimer2
DEF sActBatRoutineId                                 EQU sActSetTimer5
;--

SECTION "Other Actors", SRAM[$A200]
sAct                                       :ds $20*7 ; EQU $A200 ; Actor area
ds $20
DEF sAct_End                                         EQU sAct+$100

SECTION "Actor Handler / Shared actor addresses", SRAM[$A300]
sActNumProc                                :db     ; EQU $A300 ; Currently processed actor number

; Used when loading actor GFX
UNION
sActSetRelX_High                           :db     ; EQU $A301
NEXTU
sActGFXMaxTileCount                        :db     ; EQU $A301
NEXTU
sActStoveCanyonBossBallDir                 :db     ; EQU $A301
ENDU

UNION
sActSetStatus_Tmp                          :db     ; EQU $A302
NEXTU
sActGFXTileCopyCount                       :db     ; EQU $A302
ENDU
sActGFXActorNum                            :db     ; EQU $A303
sActGFXBankNum                             :db     ; EQU $A304
sActGFXTileCount                           :db     ; EQU $A305
ds $03
sActLevelLayoutOffset_Low                  :db     ; EQU $A309 ; X component
sActLevelLayoutOffset_High                 :db     ; EQU $A30A ; Y component
sActLevelLayoutPtr_Low                     :db     ; EQU $A30B
sActLevelLayoutPtr_High                    :db     ; EQU $A30C
ds $0B
sActStunBProc                              :db     ; EQU $A318 ; Currently processed actor for ActS_StunByLevelLayoutPtr
sActDummyBlock2                            :db     ; EQU $A319
sActTileBase                               :db     ; EQU $A31A ; Current starting tile count
sActTileBaseTbl                            :ds ACT_DEFAULT_BASE ; EQU $A31B ; List of starting tile counts, for each actor in an actgroup
ds $0D
sActGroupCodePtrTable                      :ds $02 ; EQU $A32F
sActTileBaseIndexTbl                       :ds ACT_DEFAULT_BASE ; EQU $A331
ds $15
sActHeld                                   :db     ; EQU $A34D ; If an actor is held
sActHeldId                                 :db     ; EQU $A34E
sActHeldOBJLstTablePtr_Low                 :db     ; EQU $A34F
sActHeldOBJLstTablePtr_High                :db     ; EQU $A350
sActHeldColiType                           :db     ; EQU $A351
sActHeldTreasure                           :db     ; EQU $A352 ; Marks if we're holding a treasure
sActColiSaveTbl                            :ds ACTSLOT_COUNT*2 ; EQU $A353 ; Table for storing temporary collision types. Mysteriously uses two bytes for each entry, but only the first is used.
ds $06
; -- ActHeldActColi_Do vars --
; Absolute collision box values (relative to the screen),
; for the held actor to actor box collision check
sActTmpAbsColiBoxU                         :db     ; EQU $A367
sActTmpAbsColiBoxD                         :db     ; EQU $A368
sActTmpAbsColiBoxL                         :db     ; EQU $A369
sActTmpAbsColiBoxR                         :db     ; EQU $A36A
sActTmpCurSlotNum                          :db     ; EQU $A36B ; Current slot number
sActTmpHeldNum                             :db     ; EQU $A36C ; Held slot number
;--
sActTimer                                  :db     ; EQU $A36D ; Global timer increased every frame the actor handler is called
sSubCallTmpA                               :db     ; EQU $A36E ; Used by SubCall to save/restore the A register
sActDummyBlock                             :db     ; EQU $A36F
sActFlags                                  :db     ; EQU $A370
sActFlagsRes                               :db     ; EQU $A371 ; Calculated flags for writing (temp var)
sRandom                                    :db     ; EQU $A372 ; Contains the random number generated by Rand
sActHoldHeavy                              :db     ; EQU $A373
ds $01
sLvlSpecClear                              :db     ; EQU $A375 ; Level exit (special)
sLvlExitDoor                               :db     ; EQU $A376
sLvlTreasureDoor                           :db     ; EQU $A377
sActOBJLstBank                             :ds ACTSLOT_COUNT ; EQU $A378 ; Bank numbers for the sprite mapping, for each actor slot.
ds $03
sActTreasureId                             :db     ; EQU $A382 ; ID of the treasure the room has
sActHeldColiRoutineId                      :db     ; EQU $A383 ; Routine ID set when the held actor collides with another actor
sPlFreezeTimer                             :db     ; EQU $A384 ; Freezes the player until the timer elapses
sActLastProc                               :db     ; EQU $A385  ; Last processed actor slot
sActProcCount                              :db     ; EQU $A386 ; Processed actors in the current frame
sAct_Unused_InitDone                       :db     ; EQU $A387 ; Set to $01 when the actor layout is read, and then after loading an actor group, but never read back
sActRespawnTypeTbl                         :ds ACT_DEFAULT_BASE ; EQU $A388 ; Table indexed by actor id. for each entry: 0 -> use last position; 1 -> always use initial
ds $03
sActHeldKey                                :db     ; EQU $A392
sActHeldSlotNum                            :db     ; EQU $A393
sAct_Unused_SpawnId                        :db     ; EQU $A394 ; [TCRF] Determines the actor ID spawned by Act_Unused_SpawnCustom
; For the syrup castle boss, when it overwrites the room GFX with the genie GFX.
; These keep track of the src/dest reached since it's done 1tile/frame
sCopyGFXDestPtr_Low                        :db     ; EQU $A395
sCopyGFXDestPtr_High                       :db     ; EQU $A396
sCopyGFXSourcePtr_Low                      :db     ; EQU $A397
sCopyGFXSourcePtr_High                     :db     ; EQU $A398
sActSyrupCastleBossWaveXOffset             :db     ; EQU $A399 ; Will be added to the wave effect offsets

; Separate for easy updating by Act_SyrupCastleBoss
sActLampRoutineId                          :db     ; EQU $A39A
sActLampSmokeRoutineId                     :db     ; EQU $A39B

;##
; [TCRF] Referenced only in suspicious unreferenced code
sActLamp_Unused_ActSetYLast_Low            :db     ; EQU $A39C
sActLamp_Unused_ActSetYLast_High           :db     ; EQU $A39D
sActLamp_Unused_ActSetXLast_Low            :db     ; EQU $A39E
sActLamp_Unused_ActSetXLast_High           :db     ; EQU $A39F
sActLamp_Unused_Y0ParallaxLast             :db     ; EQU $A3A0
sActLamp_Unused_X0ParallaxLast             :db     ; EQU $A3A1
;##
sActSyrupCastleBossFireTimer               :db     ; EQU $A3A2 ; For delays before firing

;--
; Global area for position sync across actors
sActStoveCanyonBossXSync_Low               :db     ; EQU $A3A3
sActStoveCanyonBossXSync_High              :db     ; EQU $A3A4
sActStoveCanyonBossYSync_Low               :db     ; EQU $A3A5
sActStoveCanyonBossYSync_High              :db     ; EQU $A3A6

;--
sLvlClearOnDeath                           :db     ; EQU $A3A7 ; If set, dying sets sLvlSpecClear instead of starting the death sequence
sCoinGameColiType                          :db     ; EQU $A3A8
sCoinGameOBJLstPtrTablePtr_Low             :db     ; EQU $A3A9
sCoinGameOBJLstPtrTablePtr_High            :db     ; EQU $A3AA
sActStoveCanyonBossTongueRoutineId         :db     ; EQU $A3AB
sActStoveCanyonBossTongueBlockHit          :db     ; EQU $A3AC ; If set, the tongue tried to hit a block this pass
sActLYLimit                                :db     ; EQU $A3AD ; Actor code will be executed only if LY is less than this
sActLastDraw                               :db     ; EQU $A3AE
ds $01
sActLevelLayoutOffsetLast_Low              :db     ; EQU $A3B0 ; Copy of sActLevelLayoutOffsetLast for the last frame
sActLevelLayoutOffsetLast_High             :db     ; EQU $A3B1
sActBossParallaxFlashTimer                 :db     ; EQU $A3B2 ; Seems to be used for other bosses too... and for the exact same purpose!
                                                               ; Even the code seems like it was copy/pasted.
sActBossParallaxX                          :db     ; EQU $A3B3 ; X coord for SSTeacup boss
sActBossParallaxY                          :db     ; EQU $A3B4 ; Y coord for SSTeacup boss
sActBigItemBoxUsed                         :db     ; EQU $A3B5 ; Determines if the big item box has been hit already. This implies a limit of one big item box/level.
sActBigItemBoxType                         :db     ; EQU $A3B6 ; Determines item inside the giant item box
sActBombLevelExplPtr_Low                   :db     ; EQU $A3B7  ; Level layout ptr for block destruction effect
sActBombLevelExplPtr_High                  :db     ; EQU $A3B8
sActRiceBeachBossDAttackDelay              :db     ; EQU $A3B9 ; The boss spins in place until it expires -- after that it attacks upside down
sActSyrupCastleBossHitAnimTimer            :db     ; EQU $A3BA ; Set sfter the final boss is hit. The boss returns to normal when it elapses
sActSyrupCastleBossHitCount                :db     ; EQU $A3BB
sPlPowerBak                                :db     ; EQU $A3BC ; Backup of the actual powerup state, used for faking the powerup during calls to ExActBGColi_DragonHatFlame_CheckBlockId
sUnused_A3BD                               :db     ; EQU $A3BD ; [TCRF] Only initialized to $00 once after the actor layout is loaded and never read back
sActSlotTransparent                        :db     ; EQU $A3BE ; Performs transparency effect for the actor
sActSyrupCastleBossDead                    :db     ; EQU $A3BF ; Used as an indicator for the ending cutscene.
;--
sActLampEndingOk                           :db     ; EQU $A3C0 ; If set, the lamp is ready for the ending cutscene. The cutscene won't start if it isn't.
sActLampRelXCopy                           :db     ; EQU $A3C1 ; Copy of Act_Lamp's sActSetRelX. Used to track the lamp's position outside of Act_Lamp.
;--
sActKnightDead                             :db     ; EQU $A3C2 ; sActMiniBossLockOpen Signals the miniboss door to open itself
; Set of variables tracked by the boss hat
sActSherbetLandBossX_Low                   :db     ; EQU $A3C3
sActSherbetLandBossX_High                  :db     ; EQU $A3C4
sActSherbetLandBossY_Low                   :db     ; EQU $A3C5
sActSherbetLandBossY_High                  :db     ; EQU $A3C6
sActSherbetLandBossDir                     :db     ; EQU $A3C7
sActSherbetLandBossHatStatus               :db     ; EQU $A3C8 ; $00: none; $01: has hat; $02: trigger drop

sActSyrupCastleBoss_Unused_A3C9            :db     ; EQU $A3C9 ; [TCRF] Only xor a'd
sActSyrupCastleBossXBak_Low                :db     ; EQU $A3CA
sActSyrupCastleBossXBak_High               :db     ; EQU $A3CB
sActSyrupCastleBossYBak_Low                :db     ; EQU $A3CC
sActSyrupCastleBossYBak_High               :db     ; EQU $A3CD
sActBossDead                               :db     ; EQU $A3CE ; Set when some bosses die.
ds $01
sActSyrupCastleBossBlankBG                 :db     ; EQU $A3D0 ; Blanks the parallax section for the boss if set
sActCoinGameTimer_Low                      :db     ; EQU $A3D1
sActCoinGameTimer_High                     :db     ; EQU $A3D2
sActMtTeapotBossEscapeKeyCount             :db     ; EQU $A3D3 ; Counts A presses for escaping from the boss when held
sActRiceBeachBossDashStunTimer             :db     ; EQU $A3D4


SECTION "Map - Blinking dots", SRAM[$A5E0]
; Mark the levels where the blinking dot effect should be active
sMapRiceBeachBlink                         :ds $02 ; EQU $A5E0
sMapMtTeapotBlink                          :ds $03 ; EQU $A5E2
sMapSherbetLandBlink                       :ds $04 ; EQU $A5E5
sMapStoveCanyonBlink                       :ds $03 ; EQU $A5E9
sMapSSTeacupBlink                          :ds $04 ; EQU $A5EC
sMapParsleyWoodsBlink                      :ds $03 ; EQU $A5F0
sMapSyrupCastleBlink                       :ds $02 ; EQU $A5F3

SECTION "Sound Memory", SRAM[$A600]
; SOUND SETS
; The different sets are used to mute specific sound channels in BGM playback (see sBGMCh?SFX)
sSFX1Set                                   :db     ; EQU $A600
sSFX1                                      :db     ; EQU $A601
ds $01
sSFX1Len                                   :db     ; EQU $A603 ; Frames left to continue playback
ds $01
sSFX1DivFreq                               :db     ; EQU $A605 ; holds pseudo random frequency value for SFX1 $32
ds $01
sSFX2Set                                   :db     ; EQU $A607
sSFX2                                      :db     ; EQU $A608
ds $01
sSFX2Len                                   :db     ; EQU $A60A
ds $03
sSFX3Set                                   :db     ; EQU $A60E ; Empty set
sSFX3                                      :db     ; EQU $A60F ; Empty set
ds $01
sSFX3Len                                   :db     ; EQU $A611 ; Unused
ds $03
sSFX4Set                                   :db     ; EQU $A615
sSFX4                                      :db     ; EQU $A616
ds $01
sSFX4Len                                   :db     ; EQU $A618
ds $03
sBGMSet                                    :db     ; EQU $A61C
sBGM                                       :db     ; EQU $A61D
sBGMActSet                                 :db     ; EQU $A61E
sBGMAct                                    :db     ; EQU $A61F
ds $04
; Marks (with SFX IDs) BGM channels which should be muted
; to avoid interfering with SFX playback
sBGMChSFX1                                 :db     ; EQU $A624
sBGMChSFX2                                 :db     ; EQU $A625
sBGMChSFX3                                 :db     ; EQU $A626 ; Always 0
sBGMChSFX4                                 :db     ; EQU $A627
ds $01
sSFX1SetLast                               :db     ; EQU $A629 ; Holds last sSFX1Set value
ds $06
sBGMPitch                                  :db     ; EQU $A630 ; Should always be even.
sBGMLenPtr                                 :ds $02 ; EQU $A631 ; Ptr to current BGM length option
sBGMCurProc                                :db     ; EQU $A633 ; Marks if a BGM command has been processed for the current sound channel.
                                                               ; If this isn't the case, it can mean the end of the BGM chunk was reached.

; Enabled sound channels for BGM Playback only
sBGMCh1On                                  :db     ; EQU $A634
sBGMCh2On                                  :db     ; EQU $A635
sBGMCh3On                                  :db     ; EQU $A636
sBGMCh4On                                  :db     ; EQU $A637

; # sBGMCurCh could be renamed to sBGMTmp

; Sound_DoCurrentBGM locals
; (values get copied here to allow handling through a generic subroutine)
sBGMCurChRegType                           :db     ; EQU $A638 ; Marks if all sound registers have been updated. This can only happen if a specific command is hit.
sBGMCurChWavePtr                           :ds $02 ; EQU $A639 ; Ptr to channel 3 wave data
sBGMCurChReg0                              :db     ; EQU $A63B ;
sBGMCurChReg1                              :db     ; EQU $A63C ;
sBGMCurChReg2                              :db     ; EQU $A63D ;
sBGMCurChReg3                              :db     ; EQU $A63E ;
sBGMCurChReg4                              :db     ; EQU $A63F ;

; Sound register copies of the final result for BGM info
;--
sBGMNR10                                   :db     ; EQU $A640 ; Channel 1 Sweep register (R/W)
sBGMNR11                                   :db     ; EQU $A641 ; Channel 1 Sound length/Wave pattern duty (R/W)
sBGMNR12                                   :db     ; EQU $A642 ; Channel 1 Volume Envelope (R/W)
sBGMNR13                                   :db     ; EQU $A643 ; Channel 1 Frequency lo (Write Only)
sBGMNR14                                   :db     ; EQU $A644 ; Channel 1 Frequency hi (R/W)
ds $01
sBGMNR21                                   :db     ; EQU $A646 ; Channel 2 Sound Length/Wave Pattern Duty (R/W)
sBGMNR22                                   :db     ; EQU $A647 ; Channel 2 Volume Envelope (R/W)
sBGMNR23                                   :db     ; EQU $A648 ; Channel 2 Frequency lo data (W)
sBGMNR24                                   :db     ; EQU $A649 ; Channel 2 Frequency hi data (R/W)
sBGMNR30                                   :db     ; EQU $A64A ; Channel 3 Sound on/off (R/W)
sBGMNR31                                   :db     ; EQU $A64B ; Channel 3 Sound Length
sBGMNR32                                   :db     ; EQU $A64C ; Channel 3 Select output level (R/W)
sBGMNR33                                   :db     ; EQU $A64D ; Channel 3 Frequency's lower data (W)
sBGMNR34                                   :db     ; EQU $A64E ; Channel 3 Frequency's higher data (R/W)
ds $02

; [TCRF] Contain copies of registers value which are never read back, set occasionally by certain subroutines
sBGM_Unused_NR42Copy                       :db     ; EQU $A651
sBGM_Unused_CurChReg3Copy                  :db     ; EQU $A652
sBGM_Unused_CurChReg4Copy                  :db     ; EQU $A653
ds $02

; Sound_SetBGMCh1
; BGM Command Table pointer (for current chunk)
sBGMCh1CmdPtr                              :ds $02 ; EQU $A656
sBGMCh2CmdPtr                              :ds $02 ; EQU $A658
sBGMCh3CmdPtr                              :ds $02 ; EQU $A65A
sBGMCh4CmdPtr                              :ds $02 ; EQU $A65C

sBGMPPCmdPitchIndex                        :db     ; EQU $A65E ; Index of the pitch bend table for BGMPPCmds

; Shared multi-channel temporary area used in subroutines like Sound_ParseBGMData
; Data from specific channels (sBGMCh1?*/$A66C) needs to be copied here and back out again.


sBGMCurChChunkPtr                          :ds $02 ; EQU $A65F
sBGMCurChLoopPtr                           :ds $02 ; EQU $A661 ; Ptr to data command the song should loop to, if a loop is requested
sBGMCurChLoopCount                         :db     ; EQU $A663 ; Loops left before the loop command is ignored
sBGMCurChLenOrig                           :db     ; EQU $A664 ; Backup copy of sBGMCurChLen when needed to reset it.
sBGMCurChVol                               :db     ; EQU $A665 ; Volume
sBGMCurChLen                               :db     ; EQU $A666 ; Length (frames left to continue playback with same register settings)
sBGMCurChPitchCmd                          :db     ; EQU $A667 ; Frequency offset command, done as the very last step, after channel registers have been already set.
ds $04
DEF sBGMCurChArea                                    EQU sBGMCurChChunkPtr ; Base address for currently handled chunk (the data inside it)

; BGM Sound channel playback
sBGMCh1ChunkPtr                            :ds $02 ; EQU $A66C
sBGMCh1LoopPtr                             :ds $02 ; EQU $A66E ; Loop target
sBGMCh1LoopCount                           :db     ; EQU $A670 ; Loops left
sBGMCh1Spd                                 :db     ; EQU $A671 ; Speed
sBGMCh1Vol                                 :db     ; EQU $A672 ; Volume
sBGMCh1Len                                 :db     ; EQU $A673 ; Length (frames left to continue playback with same register settings)
sBGMCh1PitchCmd                            :db     ; EQU $A674
ds $03
sBGMCh2ChunkPtr                            :ds $02 ; EQU $A678
sBGMCh2LoopPtr                             :ds $02 ; EQU $A67A ; Loop target
sBGMCh2LoopCount                           :db     ; EQU $A67C ; Loops left
sBGMCh2Spd                                 :db     ; EQU $A67D ; Speed
sBGMCh2Vol                                 :db     ; EQU $A67E ; Volume
sBGMCh2Len                                 :db     ; EQU $A67F ; Length
sBGMCh2PitchCmd                            :db     ; EQU $A680
ds $03
sBGMCh3ChunkPtr                            :ds $02 ; EQU $A684
sBGMCh3LoopPtr                             :ds $02 ; EQU $A686 ; Loop target
sBGMCh3LoopCount                           :db     ; EQU $A688 ; Loops left
sBGMCh3Spd                                 :db     ; EQU $A689 ; Speed
sBGMCh3Vol                                 :db     ; EQU $A68A ; Volume
sBGMCh3Len                                 :db     ; EQU $A68B ; Length
sBGMCh3PitchCmd                            :db     ; EQU $A68C
ds $03
sBGMCh4ChunkPtr                            :ds $02 ; EQU $A690
sBGMCh4LoopPtr                             :ds $02 ; EQU $A692 ; Loop target
sBGMCh4LoopCount                           :db     ; EQU $A694 ; Loops left
sBGMCh4Spd                                 :db     ; EQU $A695 ; Speed
ds $01
sBGMCh4Len                                 :db     ; EQU $A697 ; Length
ds $01
ds $07

sFadeOutTimer                              :db     ; EQU $A6A0 ; Decrements with an active fade out. When it reaches 0, the fade out "advances"
ds $02
sBGMCh2PitchExtra                          :db     ; EQU $A6A3 ; If set, it will always increase the pitch level for sound channel 2 only
ds $06
sSndPauseActSet                            :db     ; EQU $A6AA ; Pause/unpause sound action
sSndPauseTimer                             :db     ; EQU $A6AB ; Used for timing the above (ie: when to play the pause sfx; when to resume playback; etc...)
ds $03
sBGMPitchOrig                              :db     ; EQU $A6AF ; Backup copy of the original BGM pitch
ds $13
sBGMCurChWavePtrOrig                       :ds $02 ; EQU $A6C3 ; Backup copy of sBGMCurChWavePtr
sBossDeadSFXInit                           :db     ; EQU $A6C5 ; Set to $D0 when SFX1_09 is played, which is the *boss dead* SFX, not used otherwise.
ds $06
sBGMNR51                                   :db     ; EQU $A6CC ; Backup copy of rNR51 with the current BGM panning option
ds $06

; Sound register copies for temporary register changes on the SFX side
sSFXNR10                                   :db     ; EQU $A6D3 ; Channel 1 Sweep register (R/W)
sSFXNR11                                   :db     ; EQU $A6D4 ; Channel 1 Sound length/Wave pattern duty (R/W)
sSFXNR12                                   :db     ; EQU $A6D5 ; Channel 1 Volume Envelope (R/W)
sSFXNR13                                   :db     ; EQU $A6D6 ; Channel 1 Frequency lo (Write Only)
sSFXNR14                                   :db     ; EQU $A6D7 ; Channel 1 Frequency hi (R/W)
sSFXNR21                                   :db     ; EQU $A6D8 ; Channel 2 Sound Length/Wave Pattern Duty (R/W)
sSFXNR22                                   :db     ; EQU $A6D9 ; Channel 2 Volume Envelope (R/W)
sSFXNR23                                   :db     ; EQU $A6DA ; Channel 2 Frequency lo data (W)
sSFXNR24                                   :db     ; EQU $A6DB ; Channel 2 Frequency hi data (R/W)
sSFXNR30                                   :db     ; EQU $A6DC ; Channel 3 Sound on/off (R/W)
sSFXNR31                                   :db     ; EQU $A6DD ; Channel 3 Sound Length
sSFXNR32                                   :db     ; EQU $A6DE ; Channel 3 Select output level (R/W)
sSFXNR33                                   :db     ; EQU $A6DF ; Channel 3 Frequency's lower data (W)
sSFXNR34                                   :db     ; EQU $A6E0 ; Channel 3 Frequency's higher data (R/W)
sSFXNR41                                   :db     ; EQU $A6E1 ; Channel 4 Sound Length (R/W)
sSFXNR42                                   :db     ; EQU $A6E2 ; Channel 4 Volume Envelope (R/W)
sSFXNR43                                   :db     ; EQU $A6E3 ; Channel 4 Polynomial Counter (R/W)
sSFXNR44                                   :db     ; EQU $A6E4 ; Channel 4 Counter/consecutive; Initial (R/W)
sNRSize                                    :db     ; EQU $A6E5 ; Bytes to copy to a sound channel (temporary var)
sHurryUpOrig                               :db     ; EQU $A6E6 ; Copy value to detect if the hurry up status was changed in debug mode
sSFX1FreqOffsetHigh                        :db     ; EQU $A6E7 ; "signed" offset
sSFX1FreqOffset                            :db     ; EQU $A6E8 ; "signed" offset
sSFX2CoinFreq                              :db     ; EQU $A6E9
sSFX2CoinTimer                             :db     ; EQU $A6EA
;--

SECTION "Map - Animated tiles", SRAM[$A700]
sMapAnimGFX0                               :ds $08 ; EQU $A700
sMapAnimGFX1                               :ds $08 ; EQU $A708
sMapAnimGFX2                               :ds $08 ; EQU $A710
sMapAnimGFX3                               :ds $08 ; EQU $A718
sMapAnimGFX4                               :ds $08 ; EQU $A720
sMapAnimGFX5                               :ds $08 ; EQU $A728
sMapAnimGFX6                               :ds $08 ; EQU $A730
sMapAnimGFX7                               :ds $08 ; EQU $A738
sMapAnimGFX8                               :ds $08 ; EQU $A740
sMapAnimGFX9                               :ds $08 ; EQU $A748
sMapAnimGFXA                               :ds $08 ; EQU $A750
sMapAnimGFXB                               :ds $08 ; EQU $A758

SECTION "Map - Main", SRAM[$A790]
sMapMtTeapotAutoMove                       :db     ; EQU $A790
UNION
sMapSubmapEnterTime                        :db     ; EQU $A791
NEXTU
sTempA791                                  :db     ; EQU $A791
ENDU
sMapSubmapEnter                            :db     ; EQU $A792
sMapWorldClear                             :db     ; EQU $A793

sMapLevelClear                             :db     ; EQU $A794 ; if set, level clear mode (path reveal) is active

; Copy values used to detect the newly completed level
; and with that, determine which path should be processed for the path reveal anim
sMapRiceBeachCompletionLast                :db     ; EQU $A795
sMapMtTeapotCompletionLast                 :db     ; EQU $A796
sMapStoveCanyonCompletionLast              :db     ; EQU $A797
sMapSSTeacupCompletionLast                 :db     ; EQU $A798
sMapParsleyWoodsCompletionLast             :db     ; EQU $A799
sMapSherbetLandCompletionLast              :db     ; EQU $A79A
sMapSyrupCastleCompletionLast              :db     ; EQU $A79B

sMapId                                     :db     ; EQU $A79C ; current map mode
ds $01
sMapLevelId                                :db     ; EQU $A79E
sMapWorldId                                :db     ; EQU $A79F
sMapLevelIdSel                             :db     ; EQU $A7A0

; This value is a generic "return value" that signals to whoever is calling HomeCall_Map_CheckMapId
; that the map screen is done (ie: started a level, map cutscene finished, ...) and the
; game should switch to somewhere else.
;
; How this value is used depends on the code calling the map screen code.
; For example, the main map mode switches to the Course Intro/Level Select screen.
sMapRetVal                                 :db     ; EQU $A7A1
sMapTimer_High                             :db     ; EQU $A7A2
sMapRiceBeachFlooded                       :db     ; EQU $A7A3
sMapTimer_Low                              :db     ; EQU $A7A4
sMapBridgeAutoMove                         :db     ; EQU $A7A5
sMapSyrupCastleCutscene                    :db     ; EQU $A7A6 ; active cutscene id
sMapLevelStartTimer                        :db     ; EQU $A7A7
ds $28

sMapFadeOutRetVal                          :db     ; EQU $A7D0 ; tells the game to apply its value to sMapRetVal after a fade out
sMapScrollX                                :db     ; EQU $A7D1
sMapScrollY                                :db     ; EQU $A7D2
ds $01
; OAMWrite parameters
sMapOAMWriteY                              :db     ; EQU $A7D4 ; Origin Y position of sprite list
sMapOAMWriteX                              :db     ; EQU $A7D5 ; Origin X position of sprite list
sMapOAMWriteFlags                          :db     ; EQU $A7D6 ; Sprite list flags
sMapOAMWriteLstId                          :db     ; EQU $A7D7 ; Index to a table of sprite lists
sMapWarioYRes                              :db     ; EQU $A7D8
sMapWarioX                                 :db     ; EQU $A7D9
sMapWarioFlags                             :db     ; EQU $A7DA
sMapWarioLstId                             :db     ; EQU $A7DB
sMapWarioYOscillateMask                    :db     ; EQU $A7DC
sMapWarioAnimTimer                         :db     ; EQU $A7DD
sMapWarioY                                 :db     ; EQU $A7DE
sMapAnimFrame                              :db     ; EQU $A7DF
ds $01
sMapFreeViewReturn                         :db     ; EQU $A7E1
sMapPathDirSel                             :db     ; EQU $A7E2
sMapPathOffset                             :db     ; EQU $A7E3
sMapInPath                                 :db     ; EQU $A7E4
sMapWarioAnimId                            :db     ; EQU $A7E5
UNION
sMapPathCtrl                               :db     ; EQU $A7E6
NEXTU
sMapPathTestCtrl                           :db     ; EQU $A7E6
ENDU
sMapStepsLeft                              :db     ; EQU $A7E7
sMapTimer0                                 :db     ; EQU $A7E8
sMapSyrupCastleWaveLines                   :db     ; EQU $A7E9
sMapSyrupCastleWaveShift                   :db     ; EQU $A7EA
sMap_Unused_LevelIdAlt                     :db     ; EQU $A7EB
sMap_Unused_UseLevelIdAlt                  :db     ; EQU $A7EC
UNION
sMapEvIndex                                :db     ; EQU $A7ED
NEXTU
sMapEndingHeliSpeed                        :db     ; EQU $A7ED
NEXTU
sMapEndingSparkleTblIdx                    :db     ; EQU $A7ED
ENDU
sMapNextId                                 :db     ; EQU $A7EE
sMapEvOffsetTablePtr_High                  :db     ; EQU $A7EF ; Nice big endian pointer
sMapEvOffsetTablePtr_Low                   :db     ; EQU $A7F0
sMapPathDirSel_Copy                        :db     ; EQU $A7F1 ; Copy value used for "validation"... that doesn't do anything
sMap_Unused_CopyLinkedTbl                  :db     ; EQU $A7F2
IF IMPROVE
sMapLastId                                 :db     ; EQU $A7F3 
ENDC
SECTION "Active Save Slot", SRAM[$A800]
ds $04 ; Skipped, would be the checksum
sLevelId                                   :db     ; EQU $A804
sTotalCoins_High                           :db     ; EQU $A805
sTotalCoins_Mid                            :db     ; EQU $A806
sTotalCoins_Low                            :db     ; EQU $A807
sHearts                                    :db     ; EQU $A808
sLives                                     :db     ; EQU $A809
sPlPower                                   :db     ; EQU $A80A ; Current powerup state
sMapRiceBeachCompletion                    :db     ; EQU $A80B
sMapMtTeapotCompletion                     :db     ; EQU $A80C
sLevelsCleared                             :db     ; EQU $A80D
sTreasures                                 :ds $02 ; EQU $A80E ; 16 bits
sMapStoveCanyonCompletion                  :db     ; EQU $A810
sMapSSTeacupCompletion                     :db     ; EQU $A811
sMapParsleyWoodsCompletion                 :db     ; EQU $A812
sMapSherbetLandCompletion                  :db     ; EQU $A813
sMapSyrupCastleCompletion                  :db     ; EQU $A814
sCheckpoint                                :db     ; EQU $A815 ; if checkpoint is enabled
sCheckpointLevelId                         :db     ; EQU $A816 ; the level the checkpoint is for
sGameCompleted                             :db     ; EQU $A817

SECTION "Main", SRAM[$A820]
sDemoWriterBuffer                          :ds $40*2 ; EQU $A820 ; [TCRF] $80 bytes ($A820-$A89F) are reserved for generating an input demo
ds $23
sGameMode                                  :db     ; EQU $A8C3
sSubMode                                   :db     ; EQU $A8C4
sROMBank                                   :db     ; EQU $A8C5 ; Currently loaded ROM bank
sDemoMode                                  :db     ; EQU $A8C6 ;
sDebugMode                                 :db     ; EQU $A8C7 ; [TCRF] Enables the hidden debug mode

ds $38
; Level scroll coordinates, offset to the center of the screen (LVLSCROLL_XOFFSET/LVLSCROLL_YOFFSET) to get around underflow issues.
; Of course, this means that to get the real hardware scroll position, those must be subtracted to it.
sLvlScrollY_High                           :db     ; EQU $A900
sLvlScrollY_Low                            :db     ; EQU $A901
sLvlScrollX_High                           :db     ; EQU $A902
sLvlScrollX_Low                            :db     ; EQU $A903
sLvlScrollDir                              :db     ; EQU $A904 ; Holds screen scroll direction for updating the tilemap
sTimer                                     :db     ; EQU $A905 ; Global timer
sBGTmpPtr                                  :ds $02 ; EQU $A906 ; temporary ptr with VRAM tilemap offset, used for multiple purposes
sPaused                                    :db     ; EQU $A908
sScreenUpdateMode                          :db     ; EQU $A909 ; Screen modes
sLvlScrollSourcePtr_High                   :db     ; EQU $A90A ; Temporary address for saving ptr to sLvlScrollTileIdWriteTable
sLvlScrollSourcePtr_Low                    :db     ; EQU $A90B
sWorkOAMPos                                :db     ; EQU $A90C ; OAM Copy index/offset

; OAMWrite parameters
sOAMWriteY                                 :db     ; EQU $A90D
sOAMWriteX                                 :db     ; EQU $A90E
sOAMWriteLstId                             :db     ; EQU $A90F
sOAMWriteFlags                             :db     ; EQU $A910

; Wario m
sPlY_High                                  :db     ; EQU $A911
sPlY_Low                                   :db     ; EQU $A912
sPlX_High                                  :db     ; EQU $A913
sPlX_Low                                   :db     ; EQU $A914
sPlLstId                                   :db     ; EQU $A915
sPlFlags                                   :db     ; EQU $A916

UNION
sPlAnimTimer                               :db     ; EQU $A917 ; Player animation timer
NEXTU
sCreditsTextTimer                          :db     ; EQU $A917 ; Used to generate the index
ENDU
sBlockTopLeftPtr_High                      :db     ; EQU $A918
sBlockTopLeftPtr_Low                       :db     ; EQU $A919

sPlAction                                  :db     ; EQU $A91A ; Current player action (moving, jump, ...)
sPlJumpYPathIndex                          :db     ; EQU $A91B ; Y increment / decrement
sPlYRel                                    :db     ; EQU $A91C ; Wario's relative Y coord. Matches what goes into OAMWrite.
UNION
sPlXRel                                    :db     ; EQU $A91D ; Wario's relative X coord. Matches what goes into OAMWrite.
NEXTU
sCreditsRowEffectTimer                     :db     ; EQU $A91D ; Times the "pseudo transparency" effect for the first row of the credits text.
ENDU

; Working area certain slot bytes are copied to
sActTmpRelY                                :db     ; EQU $A91E
sActTmpRelX                                :db     ; EQU $A91F
sPlColiBoxL                                :db     ; EQU $A920 ; Player collision box
sPlColiBoxR                                :db     ; EQU $A921
sPlColiBoxU                                :db     ; EQU $A922
sPlColiBoxD                                :db     ; EQU $A923
sActTmpColiBoxL                            :db     ; EQU $A924 ; Current actor collision box
sActTmpColiBoxR                            :db     ; EQU $A925
sActTmpColiBoxU                            :db     ; EQU $A926
sActTmpColiBoxD                            :db     ; EQU $A927
sExActTreasureRow                          :db     ; EQU $A928 ; Row number of the treasure in the treasure box
sDemoInputOffset                           :db     ; EQU $A929 ; Offset to the demo input table
sDemoLastKey                               :db     ; EQU $A92A ; [TCRF] Keeps track of the last keypress when writing a demo.
sDemoInputLength                           :db     ; EQU $A92B ; Current length of pressed input (to detect when to switch; resets on new input)
sHighJump                                  :db     ; EQU $A92C
sDemoFlag                                  :db     ; EQU $A92D ; Demo mode flag, in practice used to prevent saving and disable sounds
sUnused_BossAlreadyDead                    :db     ; EQU $A92E ; [TCRF] Set when entering a boss room when the boss was already defeated. Not read anywhere.
; Holds the single digit (0-9 range) when halving the total coin count
sGameOverCoinDigit0                        :db     ; EQU $A92F
sGameOverCoinDigit1                        :db     ; EQU $A930
sGameOverCoinDigit2                        :db     ; EQU $A931
sGameOverCoinDigit3                        :db     ; EQU $A932
sGameOverCoinDigit4                        :db     ; EQU $A933
sSaveAllClear                              :db     ; EQU $A934 ; Bitmask with save files all cleared
sTarget_High                               :db     ; EQU $A935
sTarget_Low                                :db     ; EQU $A936
ds $01
sLvlScrollLockCur                          :db     ; EQU $A938 ; Current screen scroll locks
sPlSlowJump                                :db     ; EQU $A939 ; Generally if sActHoldHeavy is set
sScreenShakeTimer                          :db     ; EQU $A93A ; Screen shake timer for hitting small and big switch blocks
sActTmpColiDir                             :db     ; EQU $A93B ; Marks from which collision box border the actor is being interacted with
sActTmpColiType                            :db     ; EQU $A93C
sPlInvincibleTimer                         :db     ; EQU $A93D ; Timer
sPlDuck                                    :db     ; EQU $A93E
sPlBGColiBlockId                           :db     ; EQU $A93F ; Block ID indexed for collision
sPlBGColiLadderType                        :db     ; EQU $A940 ; Current ladder collision type result
sLvlScrollTimer                            :db     ; EQU $A941
sLvlScrollLevel                            :db     ; EQU $A942 ; Full scroll number
sLvlScrollDirAct                           :db     ; EQU $A943 ; Holds screen scroll direction for spawning actors
sPlSwimUpTimer                             :db     ; EQU $A944
sPlSwimGround                              :db     ; EQU $A945 ; For standing/walking on the ground in water
sPlHurtType                                :db     ; EQU $A946 ;
sActSlotPtr_High                           :db     ; EQU $A947 ; For L0D606F and others
sActSlotPtr_Low                            :db     ; EQU $A948
sPlBumpYPathIndex                          :db     ; EQU $A949 ; Bump effect offset table index
ds $01
sPlPostHitInvulnTimer                      :db     ; EQU $A94B
sPlHatSwitchTimer                          :db     ; EQU $A94C ; Frames left for the hat sequence effect
sPlDashHitTimer                            :db     ; EQU $A94D ; Frames left for the delay after defeating an enemy with a dash
sPlHardBumpGround                          :db     ; EQU $A94E
sLvlScrollVAmount                          :db     ; EQU $A94F

sLvlScrollColsLeft                         :db     ; EQU $A950
; Temporary values containing raw level header data
; Only used during level loading
sLvlScrollYRaw_High                        :db     ; EQU $A951
sLvlScrollYRaw_Low                         :db     ; EQU $A952
sLvlScrollXRaw_High                        :db     ; EQU $A953
sLvlScrollXRaw_Low                         :db     ; EQU $A954
sPlHatSwitchDrawMode                       :db     ; EQU $A955 ; Determines what should be drawn generally
sSmallWario                                :db     ; EQU $A956 ; If set, the player is Small Wario
sLvlScrollSet                              :db     ; EQU $A957
sPlPowerSet                                :db     ; EQU $A958 ; Target powerup before the hat switch sequence
sTrRoomMoneybagCount                       :db     ; EQU $A959 ; Number of moneybags given out
sMapVBlankMode                             :db     ; EQU $A95A ; Tells the VBlank handler to handle the map screen (which has its own subroutine for handling vblank)
sSavePipeAnimId                            :db     ; EQU $A95B ; Current "frame" of pipe anim
sHurryUpBGM                                :db     ; EQU $A95C
sPlActSolid_Bak                            :db     ; EQU $A95D ; Temp var
sCredits_Unused_ReachedLine2C              :db     ; EQU $A95E ; Only written to once
sLvlAutoScrollDir                          :db     ; EQU $A95F ; Conveyor belt direction, or autoscroll direction for autoscrollers. Directly determines sLvlScrollMode
sLvlScrollHAmount                          :db     ; EQU $A960
sPlBgColiBlockEq                           :db     ; EQU $A961 ; If set, the player is colliding with the same block ID in the top
sPlMovingJump                              :db     ; EQU $A962 ; it's a feature :(
sPlHardBumpDir                             :db     ; EQU $A963
sLevelTime_High                            :db     ; EQU $A964
sLevelTime_Low                             :db     ; EQU $A965
ds $01
sPlDashSolidHit                            :db     ; EQU $A967 ; Set to 1 when hitting a solid wall during a dash
sPlBGColi_Unused_LastBlockId               :db     ; EQU $A968 ; [TCRF] Only set, but never read back
sParallaxY0                                :db     ; EQU $A969
sParallaxX0                                :db     ; EQU $A96A
sParallaxNextLY0                           :db     ; EQU $A96B
sParallaxY1                                :db     ; EQU $A96C
sParallaxX1                                :db     ; EQU $A96D
sParallaxNextLY1                           :db     ; EQU $A96E
sParallaxY2                                :db     ; EQU $A96F
sParallaxX2                                :db     ; EQU $A970
sParallaxNextLY2                           :db     ; EQU $A971
sParallaxY3                                :db     ; EQU $A972
sParallaxX3                                :db     ; EQU $A973
sParallaxNextLY3                           :db     ; EQU $A974
sEndTotalCoins_High                        :db     ; EQU $A975 ; Total coins -- high byte (after decrementing the total coin count in the ending)
sEndTotalCoins_Mid                         :db     ; EQU $A976 ; ""
sEndTotalCoins_Low                         :db     ; EQU $A977 ; ""
sCreditsNextRow1Mode                       :db     ; EQU $A978
sTmp_Unused_A979                           :db     ; EQU $A979 ; Used only in unused code
sLevelCoins_High                           :db     ; EQU $A97A
sLevelCoins_Low                            :db     ; EQU $A97B
sPlGroundDashTimer                         :db     ; EQU $A97C ; Frames left for a dash attack from the ground
sLvlLayoutPtrActId                         :db     ; EQU $A97D ; Actor ID in the specified level layout ptr
sPlBGColiBlockOffset1_High                 :db     ; EQU $A97E
sPlBGColiBlockOffset1_Low                  :db     ; EQU $A97F
sPlBGColiBlockOffset2_High                 :db     ; EQU $A980
sPlBGColiBlockOffset2_Low                  :db     ; EQU $A981
sActStunLevelLayoutPtr_High                :db     ; EQU $A982 ; Actors in this location will be stunned
sActStunLevelLayoutPtr_Low                 :db     ; EQU $A983
sDelayTimer                                :db     ; EQU $A984 ; Generic delay countdown/timer
DEF sPlDelayTimer                                    EQU sDelayTimer ; Player delay countdown/timer
DEF sCourseScrTimer                                  EQU sDelayTimer ; Frames before course screen transitions to level load
DEF sSaveWarioTimer                                  EQU sDelayTimer
DEF sLevelClearTimer                                 EQU sDelayTimer
DEF sTrRoomCoinDecDelay                              EQU sDelayTimer ; Delays the coin countdown until it gets to $02. Also used to signal the
DEF sTrRoomWaitTimer                                 EQU sDelayTimer
DEF sTimeUpWaitTimer                                 EQU sDelayTimer
DEF sGameOverWaitTimer                               EQU sDelayTimer
DEF sEndingWaitTimer                                 EQU sDelayTimer

sTimeUp                                    :db     ; EQU $A985 ; If set, dying results in the time up screen showing up
sGameOver                                  :db     ; EQU $A986 ; If set, dying results in the game over screen showing up
IF IMPROVE
sPlBGColiIgnoreLadders                     :db     ; EQU $A987 ; Good workaround
ELSE
ds $01
ENDC
sActInteractDir                            :db     ; EQU $A988 ; Bitmask which marks from which direction the actor is being interacted with
sActColiBoxDistanceD                       :db     ; EQU $A989 ; Distance between pl up colibox and actor down colibox
sActColiBoxDistanceU                       :db     ; EQU $A98A
sActColiBoxDistanceL                       :db     ; EQU $A98B
sActColiBoxDistanceR                       :db     ; EQU $A98C

sPlActSolid                                :db     ; EQU $A98D ; If set, the player's standing top of a solid actor
sLvlDoorPtr                                :ds $02 ; EQU $A98E ; Set when entering doors (high; low)
sParallaxMode                              :db     ; EQU $A990
ds $02
sScrollX_High                              :db     ; EQU $A993
sScrollX                                   :db     ; EQU $A994 ;
sBossRoom                                  :db     ; EQU $A995 ; If set, the current room is handled as a boss room. This disables the lag reduction feature and prevents actors from spawning when scrolling
s_Unused_LvlBGPriority                     :db     ; EQU $A996 ; Only written to with value from header; never read back
sBGP                                       :db     ; EQU $A997 ; For levels
sPlJetDashTimer                            :db     ; EQU $A998
sPlScreenShake                             :db     ; EQU $A999 ; Marks a screen-shake caused by the player
ds $03
sLvlScrollMode                             :db     ; EQU $A99D
; Collision box for dragon hat flame
sPlDragonFlameColiBoxL                     :db     ; EQU $A99E
sPlDragonFlameColiBoxR                     :db     ; EQU $A99F
sPlDragonFlameColiBoxU                     :db     ; EQU $A9A0
sPlDragonFlameColiBoxD                     :db     ; EQU $A9A1
sPlDragonFlameDamage                       :db     ; EQU $A9A2 ; Set when the dragon hat flame can cause damage
s_Unused_PlNoGroundPound                   :db     ; EQU $A9A3
sPlDragonHatActive                         :db     ; EQU $A9A4
sActHeldLast                               :db     ; EQU $A9A5
sPlJumpThrowTimer                          :db     ; EQU $A9A6
sNoReset                                   :db     ; EQU $A9A7 ; For some reason they bothered with this
sPauseActors                               :db     ; EQU $A9A8
sScrollYOffset                             :db     ; EQU $A9A9 ; Y scroll offset for screen shake effects. it's why hScrollY exists.
sTrRoomCoinFrameId                         :db     ; EQU $A9AA ; $0A + this value is the block ID for the coin
sLevelAnimSpeed                            :db     ; EQU $A9AB ; Animated tile speed (0 = no anim)
sSaveBlockBreakDone                        :db     ; EQU $A9AC ;
sSpecSubmode                               :db     ; EQU $A9AD
DEF sSaveAnimAct                                     EQU sSpecSubmode
DEF sCourseClrMode                                   EQU sSpecSubmode
DEF sEndingTrRoomMode                                EQU sSpecSubmode
DEF sTreasureTrRoomMode                              EQU sSpecSubmode
DEF sGameOverTrRoomMode                              EQU sSpecSubmode
DEF sCreditsMode                                     EQU sSpecSubmode
sSaveWarioYTblIndex                        :db     ; EQU $A9AE ; Index to Y offset table for Wario's jump in the save screen
sSaveTargetX                               :db     ; EQU $A9AF
sSavePlAct                                 :db     ; EQU $A9B0 ; Player action
sSaveBombWario                             :db     ; EQU $A9B1 ; If set, Wario is in the bomb form
sPlSand                                    :db     ; EQU $A9B2
sPlSandJump                                :db     ; EQU $A9B3
sPlHatSwitchEndMode                        :db     ; EQU $A9B4
sPlWaterAction                             :db     ; EQU $A9B5 ; Marks an underwater action so that when we return to the swimming act, the water splash won't spawn
; Top left coordinates of the level scroll positions
; These are treated as the row/col
sLvlScrollUpdR0Y_High                      :db     ; EQU $A9B6
sLvlScrollUpdR0Y_Low                       :db     ; EQU $A9B7
sLvlScrollUpdR0X_High                      :db     ; EQU $A9B8
sLvlScrollUpdR0X_Low                       :db     ; EQU $A9B9
sLvlScrollUpdL0Y_High                      :db     ; EQU $A9BA
sLvlScrollUpdL0Y_Low                       :db     ; EQU $A9BB
sLvlScrollUpdL0X_High                      :db     ; EQU $A9BC
sLvlScrollUpdL0X_Low                       :db     ; EQU $A9BD
sLvlScrollUpdU0Y_High                      :db     ; EQU $A9BE
sLvlScrollUpdU0Y_Low                       :db     ; EQU $A9BF
sLvlScrollUpdU0X_High                      :db     ; EQU $A9C0
sLvlScrollUpdU0X_Low                       :db     ; EQU $A9C1
sLvlScrollUpdD0Y_High                      :db     ; EQU $A9C2
sLvlScrollUpdD0Y_Low                       :db     ; EQU $A9C3
sLvlScrollUpdD0X_High                      :db     ; EQU $A9C4
sLvlScrollUpdD0X_Low                       :db     ; EQU $A9C5
sLvlScrollUpdR1Y_High                      :db     ; EQU $A9C6
sLvlScrollUpdR1Y_Low                       :db     ; EQU $A9C7
sLvlScrollUpdR1X_High                      :db     ; EQU $A9C8
sLvlScrollUpdR1X_Low                       :db     ; EQU $A9C9
sLvlScrollUpdL1Y_High                      :db     ; EQU $A9CA
sLvlScrollUpdL1Y_Low                       :db     ; EQU $A9CB
sLvlScrollUpdL1X_High                      :db     ; EQU $A9CC
sLvlScrollUpdL1X_Low                       :db     ; EQU $A9CD
sLvlScrollUpdU1Y_High                      :db     ; EQU $A9CE
sLvlScrollUpdU1Y_Low                       :db     ; EQU $A9CF
sLvlScrollUpdU1X_High                      :db     ; EQU $A9D0
sLvlScrollUpdU1X_Low                       :db     ; EQU $A9D1
sLvlScrollUpdD1Y_High                      :db     ; EQU $A9D2
sLvlScrollUpdD1Y_Low                       :db     ; EQU $A9D3
sLvlScrollUpdD1X_High                      :db     ; EQU $A9D4
sLvlScrollUpdD1X_Low                       :db     ; EQU $A9D5
sStaticScreenMode                          :db     ; EQU $A9D6 ; If set, the current screen is single-screen and unscrollable. Not all are like this.
sRetVal                                    :db     ; EQU $A9D7 ; Return value for certain nested submodes
DEF sTitleRetVal                                     EQU sRetVal ; Return value for the title screen code
DEF sCourseClrBonusEnd                               EQU sRetVal ; Reminder to switch to the Treasure Room once the bonus games return to the Course Clear screen
DEF sEndingRetVal                                    EQU sRetVal ; Marks the ending code as being finished
sPl_Unused_DragonFlameBGColiSolid          :db     ; EQU $A9D8
sSaveFileError                             :db     ; EQU $A9D9 ; Bitmask with save files marked as bad
sSaveFileErrorCharId                       :db     ; EQU $A9DA ; Offset to current letter in SAVE FILE RRROR message
sSaveBrickPosIndex                         :db     ; EQU $A9DB
sLvlAutoScrollSpeed                        :db     ; EQU $A9DC ; Timer bitmask format for conveyor belts/autoscrollers. In practice only set to $01
sTreasureId                                :db     ; EQU $A9DD ; ID of the treasure collected
sTreasureActSlotPtr_High                   :db     ; EQU $A9DE ; Ptr to actor slot with the treasure
sTreasureActSlotPtr_Low                    :db     ; EQU $A9DF ; Ptr to actor slot with the treasure
sTrRoomSparkleActive                       :db     ; EQU $A9E0 ; If set, a ExAct_TrRoom_Sparkle is currently active
sTrRoomSparkleIndex                        :db     ; EQU $A9E1 ; Index for the above, to cycle between treasures to spawn over
sTrRoomSparkleIndexAdd                     :db     ; EQU $A9E2 ; Index will be increased by this amount
sLvlBlockSwitchReq                         :db     ; EQU $A9E3 ; If set ($01 or $10) triggers the block replacement effect on the next door transition.
sCourseNum                                 :db     ; EQU $A9E4
sAltLevelClear                             :db     ; EQU $A9E5 ; If set, marks a level clear for the alternate exit
sPlNewAction                               :db     ; EQU $A9E6 ; Set when starting a new action
sTrainShakeTimer                           :db     ; EQU $A9E7
sPlIce                                     :db     ; EQU $A9E8
sPlIceDelayTimer                           :db     ; EQU $A9E9 ; Timer before the player movement is updated (for the delayed movement on ice)
sPlIceDelayDir                             :db     ; EQU $A9EA ; Enables the ice delay timer
sHurryUp                                   :db     ; EQU $A9EB ; Hurry up status. 0: None; 1:Playing chime,fast music; 2:Fast music
sPlBreakCombo                              :db     ; EQU $A9EC ; Bricks destroyed at the same time
sLvl_Unused_BlockSwitch1Req                :db     ; EQU $A9ED
sTmp_A9EE                                  :db     ; EQU $A9EE ; Temporary variable to save the 'a' register
;--
sExActCount                                :db     ; EQU $A9EF
sExActLeft                                 :db     ; EQU $A9F0 ; Copy of sExActCount which gets decremented as ExOBJ are processed
sExActOBJYRel                              :db     ; EQU $A9F1 ; Relative Y pos
sExActOBJXRel                              :db     ; EQU $A9F2 ; Relative X pos
sExActSignal                               :db     ; EQU $A9F3 ; Hardcoded address used by some ExActors to communicate with the game mode code.
DEF sExActTrRoomArrowDespawn                         EQU sExActSignal
DEF sExActTrRoomTreasureDespawn                      EQU sExActSignal
DEF sExActTrRoomTreasureNear                         EQU sExActSignal ; The treasure signals that it's near the player
DEF sExActMoneybagStackMode                          EQU sExActSignal ; Signals out to add another moneybag to the stack
;--
sCreditsRow1LineId                         :db     ; EQU $A9F4 ; ID of the line to display in the first row of the credits
sCreditsRow2LineId                         :db     ; EQU $A9F5 ; ID of the line to display in the second row of the credits
sPlBGColiBlockIdNext                       :db     ; EQU $A9F6 ; Block ID with less priority (to check later down the frame)
sPlBGColiBlockOffset1Next_High             :db     ; EQU $A9F7 ; High byte (Y pos) of block with less priority
sPlSuperJumpSet                            :db     ; EQU $A9F8 ; If set, requests the next jump to be a super jump (and determines jump SFX played)
sPlSuperJump                               :db     ; EQU $A9F9 ; Marks a currently active super jump
sStatusEdit                                :db     ; EQU $A9FA ; Enables "debug mode" (status bar editor)
sStatusEditY                               :db     ; EQU $A9FB ; Cursor position
sStatusEditX                               :db     ; EQU $A9FC ; Cursor position
sPlBGColiSolidReadOnly                     :db     ; EQU $A9FD ; Read-only flag for solid blocks for collision check subroutines ; sPlBGColiSolidReadOnly
sLvlBlockSwitch                            :db     ; EQU $A9FE ; Determines if the ! block is pressed or unpressed. Determines the block tiles the ! block uses.
sDebugToggleCount                          :db     ; EQU $A9FF ;

;--
sExAct                                     :ds $10*$0E ; EQU $AA00
UNION
sExActStatus                               :db     ; EQU $AAE0
sExActOBJY_High                            :db     ; EQU $AAE1 ; 2 byte coord mode
sExActOBJY_Low                             :db     ; EQU $AAE2
sExActOBJX_High                            :db     ; EQU $AAE3
sExActOBJX_Low                             :db     ; EQU $AAE4
sExActOBJLstId                             :db     ; EQU $AAE5
sExActOBJFlags                             :db     ; EQU $AAE6
sExActLevelLayoutPtr_High                  :db     ; EQU $AAE7
sExActLevelLayoutPtr_Low                   :db     ; EQU $AAE8
sExActRoutineId                            :db     ; EQU $AAE9
sExActTimer                                :db     ; EQU $AAEA ; Timer before ending an action
sExActOBJFixY                              :db     ; EQU $AAEB ; 1 byte coord mode
sExActOBJFixX                              :db     ; EQU $AAEC
sExActAnimTimer                            :db     ; EQU $AAED ; Timer used for indexing OBJLstAnimOff tables
NEXTU
sExActSet                                  :ds $10 ; EQU $AAE0
sExActSet2                                 :ds $10 ; EQU $AAF0 ; Secodary set; can't be used directly
ENDU
;-------
; Custom properties, ExAct-specific
DEF sActBridgeSpawned                                EQU sExActOBJX_Low
DEF sExAct09_TblIndex                                EQU sExActTimer
DEF sExActSparkle_FrameId                            EQU sExActTimer
DEF sExActSparkle_LoopCount                          EQU sExActRoutineId
;--
DEF sExActArea_End                                   EQU sExActSet2+$10 ; End of the Extra Actor area.
;--

SECTION "Animated Level Tiles", SRAM[$AB00]
sLevelAnimGFX                              :ds $04*$04*TILESIZE ; EQU $AB00 ; Where all frames of the animated tiles are stored ($100 bytes / $10 frames / 4 tiles with 4 frames each)
SECTION "Scroll buffers", SRAM[$AC00]
sLvlScrollBlockTable                       :ds $10*$01 ; EQU $AC00 ; Block IDs, then split into tile IDs (see below)
sLvlScrollBGPtrWriteTable                  :ds $10*$02 ; EQU $AC10 ; VRAM Ptrs to blocks (total $20 bytes)
sLvlScrollTileIdWriteTable                 :ds $10*BG_BLOCK_LENGTH ; EQU $AC30 ; Tile IDs to write for the above (4 tiles/block, total $40 bytes)
DEF sEndingText                                      EQU sLvlScrollTileIdWriteTable ; Tile IDs to display for the current frame
DEF sSavePipeAnimTiles                               EQU sLvlScrollTileIdWriteTable ; Where the tile IDs are stored
ds $13

sUnused_AC83                               :db     ; EQU $AC83
sAct_Unused_LastSetRoutineId               :db     ; EQU $AC84 ; [TCRF] Never read back
sAct_Unused_InteractDirType                :db     ; EQU $AC85 ; [TCRF] Never read back
sStatusEditToggleCount                     :db     ; EQU $AC86 ; Toggle count for status bar editor (debug)
sPlPower_Unused_Copy                       :db     ; EQU $AC87 ; [TCRF] Only written to
sLevelAnimFrame                            :db     ; EQU $AC88 ; Currently displayed frame number (0-3)
ds $57
sLvlScrollLocks                            :ds $20 ; EQU $ACE0 ; $20 byte area with scroll lock info of all $20 sectors

sLevelBlocks                               :ds $80*BG_BLOCK_LENGTH ; EQU $AD00 ; 16x16 block defs ($200 bytes)
;--
; 16x16 fixed blocks (expected to always be there)
DEF sLevelBlock_Switch0T1                            EQU sLevelBlocks+BLOCKID_SWITCH0T1*BG_BLOCK_LENGTH
DEF sLevelBlock_Unused_Switch1T1                     EQU sLevelBlocks+BLOCKID_UNUSED_SWITCH1T1*BG_BLOCK_LENGTH
DEF sLevelBlock_Switch0T0                            EQU sLevelBlocks+BLOCKID_SWITCH0T0*BG_BLOCK_LENGTH
;--
SECTION "OAM Mirror", SRAM[$AF00]
sWorkOAM                                   :ds OBJCOUNT_MAX*OBJ_SIZE ; EQU $AF00 ; Position of the OAM copy ($A0 bytes)
sStack                                     :ds $60
DEF sWorkOAM_End                                     EQU sWorkOAM+OBJCOUNT_MAX*OBJ_SIZE
DEF sStack_End                                       EQU sStack+$60
;--
; Fixed WorkOAM addresses
; for OBJ which are expected to be in specific slots.
DEF sSaveDigit0                                      EQU sWorkOAM+$00*OBJ_SIZE
DEF sSaveDigit1                                      EQU sWorkOAM+$01*OBJ_SIZE
DEF sSaveDigit2                                      EQU sWorkOAM+$02*OBJ_SIZE
DEF sSaveDigit3                                      EQU sWorkOAM+$03*OBJ_SIZE
DEF sSaveDigit4                                      EQU sWorkOAM+$04*OBJ_SIZE
DEF sSaveDigit5                                      EQU sWorkOAM+$05*OBJ_SIZE
DEF sSaveBrick0                                      EQU sWorkOAM+$06*OBJ_SIZE
DEF sSaveBrick1                                      EQU sWorkOAM+$07*OBJ_SIZE
DEF sSaveBrick2                                      EQU sWorkOAM+$08*OBJ_SIZE
DEF sSaveBrick3                                      EQU sWorkOAM+$09*OBJ_SIZE
DEF sSaveBrick4                                      EQU sWorkOAM+$0A*OBJ_SIZE
DEF sSaveBrick5                                      EQU sWorkOAM+$0B*OBJ_SIZE
;--

SECTION "Actor Layout / Temporary Map Vars", SRAM[$B000]
UNION
sActLayout                                 :ds LEVEL_LAYOUT_LENGTH/2 ; EQU $B000
DEF sActLayout_End                                   EQU sActLayout+(LEVEL_LAYOUT_LENGTH/2)
NEXTU
ds $40
sMapEvTileId                               :db     ; EQU $B040 ; Next tile ID to place for the map event
sMapEvBGPtr                                :db     ; EQU $B041 ; Where to place the tile ID from above. Ptr to the tilemap.

ds $E9

IF IMPROVE
; Teapot steam sprout (working)
sMapMtTeapotSproutAnimTimer                :db     ; EQU $B12B
sMapMtTeapotSproutY                        :db     ; EQU $B12C
sMapMtTeapotSproutX                        :db     ; EQU $B12D
sMapMtTeapotSproutFlags                    :db     ; EQU $B12E
sMapMtTeapotSproutLstId                    :db     ; EQU $B12F
ELSE
ds $05
ENDC
;--
; Teapot lid
sMapMtTeapotLidY                           :db     ; EQU $B130
sMapMtTeapotLidScrollYLast                 :db     ; EQU $B131
sMapMtTeapotLidScrollXLast                 :db     ; EQU $B132
sMapMtTeapotLidX                           :db     ; EQU $B133
sMapMtTeapotLidFlags                       :db     ; EQU $B134
sMapMtTeapotLidLstId                       :db     ; EQU $B135
; Teapot steam sprout
sMap_Unused_MtTeapotSproutY                :db     ; EQU $B136
sMap_Unused_MtTeapotSproutX                :db     ; EQU $B137
sMap_Unused_MtTeapotSproutFlags            :db     ; EQU $B138
sMap_Unused_MtTeapotSproutLstId            :db     ; EQU $B139
; World clear flags and anim timers
sMapRiceBeachFlagY                         :db     ; EQU $B13A
sMapRiceBeachFlagScrollYLast               :db     ; EQU $B13B
sMapRiceBeachFlagScrollXLast               :db     ; EQU $B13C
sMapRiceBeachFlagX                         :db     ; EQU $B13D
sMapOverworldFlagFlags                     :db     ; EQU $B13E
sMapRiceBeachFlagLstId                     :db     ; EQU $B13F
sMapMtTeapotFlagLstId                      :db     ; EQU $B140
sMapStoveCanyonFlagLstId                   :db     ; EQU $B141
sMapSSTeacupFlagLstId                      :db     ; EQU $B142
sMapParsleyWoodsFlagLstId                  :db     ; EQU $B143
sMapSherbetLandFlagLstId                   :db     ; EQU $B144
sMap_Unused_SyrupCastleFlagLstId           :db     ; EQU $B145
UNION
sMapRiceBeachFlagTimer                     :db     ; EQU $B146
sMapMtTeapotFlagTimer                      :db     ; EQU $B147
sMapStoveCanyonFlagTimer                   :db     ; EQU $B148
NEXTU
sMapC32CutsceneTimerTarget                 :db     ; EQU $B146
sMapLakeSproutAnimTimer                    :db     ; EQU $B147
sMapLakeDrainAnimTimer                     :db     ; EQU $B148
ENDU
sMapSSTeacupFlagTimer                      :db     ; EQU $B149
sMapParsleyWoodsFlagTimer                  :db     ; EQU $B14A
sMapSherbetLandFlagTimer                   :db     ; EQU $B14B
sMap_Unused_SyrupCastleFlagTimer           :db     ; EQU $B14C
sMapMtTeapotFlagY                          :db     ; EQU $B14D
sMapMtTeapotFlagScrollYLast                :db     ; EQU $B14E
sMapMtTeapotFlagScrollXLast                :db     ; EQU $B14F
sMapMtTeapotFlagX                          :db     ; EQU $B150
sMapStoveCanyonFlagY                       :db     ; EQU $B151
sMapStoveCanyonFlagScrollYLast             :db     ; EQU $B152
sMapStoveCanyonFlagScrollXLast             :db     ; EQU $B153
sMapStoveCanyonFlagX                       :db     ; EQU $B154
sMapSSTeacupFlagY                          :db     ; EQU $B155
sMapSSTeacupFlagScrollYLast                :db     ; EQU $B156
sMapSSTeacupFlagScrollXLast                :db     ; EQU $B157
sMapSSTeacupFlagX                          :db     ; EQU $B158
sMapParsleyWoodsFlagY                      :db     ; EQU $B159
sMapParsleyWoodsFlagScrollYLast            :db     ; EQU $B15A
sMapParsleyWoodsFlagScrollXLast            :db     ; EQU $B15B
sMapParsleyWoodsFlagX                      :db     ; EQU $B15C
sMapSherbetLandFlagY                       :db     ; EQU $B15D
sMapSherbetLandFlagScrollYLast             :db     ; EQU $B15E
sMapSherbetLandFlagScrollXLast             :db     ; EQU $B15F
sMapSherbetLandFlagX                       :db     ; EQU $B160
sMap_Unused_SyrupCastleFlagY               :db     ; EQU $B161
sMap_Unused_SyrupCastleFlagScrollYLast     :db     ; EQU $B162
sMap_Unused_SyrupCastleFlagScrollXLast     :db     ; EQU $B163
sMap_Unused_SyrupCastleFlagX               :db     ; EQU $B164
sMapFlagLstIdPtr_High                      :db     ; EQU $B165
sMapFlagLstIdPtr_Low                       :db     ; EQU $B166
UNION
sMapFadeTimer                              :db     ; EQU $B167
sMapMtTeapotLidYTimer                      :db     ; EQU $B168
NEXTU
sMapCutsceneEndTimer                       :db     ; EQU $B167
NEXTU
sMapLakeDrainLstIdTarget                   :db     ; EQU $B167
sMapC32CutsceneTimer                       :db     ; EQU $B168
ENDU
sMapPathsPtr_High                          :db     ; EQU $B169
sMapPathsPtr_Low                           :db     ; EQU $B16A
sMapValidPaths                             :db     ; EQU $B16B
ds $02
sMapTileCopyCounter                        :db     ; EQU $B16E
; For maps with more than 8 exits, which don't exist. These arent't saved anyway.
sMap_Unused_RiceBeachCompletionHigh        :db     ; EQU $B16F
sMap_Unused_RiceBeachCompletionHighLast    :db     ; EQU $B170
sMap_Unused_MtTeapotCompletionHigh         :db     ; EQU $B171
sMap_Unused_MtTeapotCompletionHighLast     :db     ; EQU $B172
sMap_Unused_StoveCanyonCompletionHigh      :db     ; EQU $B173
sMap_Unused_StoveCanyonCompletionHighLast  :db     ; EQU $B174
sMap_Unused_SSTeacupCompletionHigh         :db     ; EQU $B175
sMap_Unused_SSTeacupCompletionHighLast     :db     ; EQU $B176
sMap_Unused_ParsleyWoodsCompletionHigh     :db     ; EQU $B177
sMap_Unused_ParsleyWoodsCompletionHighLast :db     ; EQU $B178
sMap_Unused_SherbetLandCompletionHigh      :db     ; EQU $B179
sMap_Unused_SherbetLandCompletionHighLast  :db     ; EQU $B17A
sMap_Unused_SyrupCastleCompletionHigh      :db     ; EQU $B17B
sMap_Unused_SyrupCastleCompletionHighLast  :db     ; EQU $B17C
sMapOverworldCompletion                    :db     ; EQU $B17D
sMapShake                                  :db     ; EQU $B17E ; screen shake effect flag
sMapOverworldCutsceneScript                :db     ; EQU $B17F
sMapScrollYShake                           :db     ; EQU $B180 ; alternate ScrollY value used on screen shake effect
sMap_Unused_LakeSproutYCopy                :db     ; EQU $B181
sMap_Unused_LakeSproutXCopy                :db     ; EQU $B182
sMapLakeSproutY                            :db     ; EQU $B183
sMapLakeSproutX                            :db     ; EQU $B184
sMapLakeSproutLstId                        :db     ; EQU $B185
sMapLakeSproutFlags                        :db     ; EQU $B186
sMap_Unused_LakeDrainYCopy                 :db     ; EQU $B187
sMap_Unused_LakeDrainXCopy                 :db     ; EQU $B188
sMapLakeDrainY                             :db     ; EQU $B189
sMapLakeDrainX                             :db     ; EQU $B18A
sMapLakeDrainLstId                         :db     ; EQU $B18B
sMapLakeDrainFlags                         :db     ; EQU $B18C
ds $04
sMap_Unused_VMove                          :db     ; EQU $B191
sMap_Unused_HMove                          :db     ; EQU $B192
sMap_Unknown_TimerLowCopy                  :db     ; EQU $B193
ds $02
sMap_Unused_ExplTimer                      :db     ; EQU $B196
ds $01
sMapC32ClearFlag                           :db     ; EQU $B198
ds $02
sMapSyrupCastleInvertPal                   :db     ; EQU $B19B
; Extra sprites
sMapExOBJ0Y                                :db     ; EQU $B19C
sMapExOBJ0X                                :db     ; EQU $B19D
sMapExOBJ1Y                                :db     ; EQU $B19E
sMapExOBJ1X                                :db     ; EQU $B19F
sMapExOBJ2Y                                :db     ; EQU $B1A0
sMapExOBJ2X                                :db     ; EQU $B1A1
sMapExOBJ3Y                                :db     ; EQU $B1A2
sMapExOBJ3X                                :db     ; EQU $B1A3
sMapExOBJ0LstId                            :db     ; EQU $B1A4
sMapExOBJ1LstId                            :db     ; EQU $B1A5
sMapExOBJ2LstId                            :db     ; EQU $B1A6
sMapExOBJ3LstId                            :db     ; EQU $B1A7
sMapExOBJ0Flags                            :db     ; EQU $B1A8
sMapExOBJ1Flags                            :db     ; EQU $B1A9
sMapExOBJ2Flags                            :db     ; EQU $B1AA
sMapExOBJ3Flags                            :db     ; EQU $B1AB
sMapVisibleArrows                          :db     ; EQU $B1AC
sMapCurArrow                               :db     ; EQU $B1AD
; Explosion sprites and others
UNION
sMapExplOBJ0Y                              :db     ; EQU $B1AE
sMapExplOBJ0X                              :db     ; EQU $B1AF
sMapExplOBJ0LstId                          :db     ; EQU $B1B0
sMapExplOBJ0Flags                          :db     ; EQU $B1B1
NEXTU
sMapEndingHeliY                            :db     ; EQU $B1AE
sMapEndingHeliX                            :db     ; EQU $B1AF
sMapEndingHeliLstId                        :db     ; EQU $B1B0
sMapEndingHeliFlags                        :db     ; EQU $B1B1
ENDU
sMapExplOBJ1Y                              :db     ; EQU $B1B2
sMapExplOBJ1X                              :db     ; EQU $B1B3
sMapExplOBJ1LstId                          :db     ; EQU $B1B4
sMapExplOBJ1Flags                          :db     ; EQU $B1B5
sMapExplOBJ2Y                              :db     ; EQU $B1B6
sMapExplOBJ2X                              :db     ; EQU $B1B7
sMapExplOBJ2LstId                          :db     ; EQU $B1B8
sMapExplOBJ2Flags                          :db     ; EQU $B1B9
sMapExplOBJ3Y                              :db     ; EQU $B1BA
sMapExplOBJ3X                              :db     ; EQU $B1BB
sMapExplOBJ3LstId                          :db     ; EQU $B1BC
sMapExplOBJ3Flags                          :db     ; EQU $B1BD
sMapSyrupCastleCutsceneTimer               :db     ; EQU $B1BE
sMapSyrupCastleWaveTablePtr_High           :db     ; EQU $B1BF
sMapSyrupCastleWaveTablePtr_Low            :db     ; EQU $B1C0
sMapAutoEnterOnPathEnd                     :db     ; EQU $B1C1
sMapEndingStatueHighY                      :db     ; EQU $B1C2
sMapEndingStatueHighX                      :db     ; EQU $B1C3
sMapEndingStatueHighLstId                  :db     ; EQU $B1C4
sMapEndingStatueHighFlags                  :db     ; EQU $B1C5
sMapEndingStatueLowY                       :db     ; EQU $B1C6
sMapEndingStatueLowX                       :db     ; EQU $B1C7
sMapEndingStatueLowLstId                   :db     ; EQU $B1C8
sMapEndingStatueLowFlags                   :db     ; EQU $B1C9
sMapEndingSparkleY                         :db     ; EQU $B1CA
sMapEndingSparkleX                         :db     ; EQU $B1CB
sMapEndingSparkleLstId                     :db     ; EQU $B1CC
sMapEndingSparkleFlags                     :db     ; EQU $B1CD
sMapFreeView                               :db     ; EQU $B1CE
sMapEndingLampY                            :db     ; EQU $B1CF
sMapEndingLampX                            :db     ; EQU $B1D0
sMapEndingLampLstId                        :db     ; EQU $B1D1
sMapEndingLampFlags                        :db     ; EQU $B1D2
sMapSyrupCastleCutsceneAct                 :db     ; EQU $B1D3
ds $01
sMapBlinkLevelPtr_High                     :db     ; EQU $B1D5
sMapBlinkLevelPtr_Low                      :db     ; EQU $B1D6
sMapBlinkId                                :db     ; EQU $B1D7
sMapBlinkDoneFlags                         :db     ; EQU $B1D8
sMapWorldClearTimer                        :db     ; EQU $B1D9
sMapAnimFrame_Misc                         :db     ; EQU $B1DA
ENDU
;--

SECTION "Level Layout / Static Screen memory", WRAM0[$C000]
UNION
wLevelLayout                               :ds LEVEL_LAYOUT_LENGTH ; EQU $C000
DEF wLevelLayout_End                                 EQU wLevelLayout+LEVEL_LAYOUT_LENGTH
NEXTU

; From this point on, some variables are marked as "wStatic"
; These are used in "Static Screen" modes, like the Title screen and bonus game.
; [NOTE] Some of these named "wTitle" should probably be renamed to "wStatic", since they are common.
;        (and chances are, "Static Screen Mode" is just a VBlank handler hack around the two
;         very different programming conventions used between intro/ending/bonus games and *everything else*)
ds $A0
wStaticMode                                :db     ; EQU $C0A0 ; Main submode
DEF wTitleMode                                       EQU wStaticMode
DEF wHeartBonusMode                                  EQU wStaticMode
DEF wCoinBonusMode                                   EQU wStaticMode
DEF wEndingMode                                      EQU wStaticMode

wStaticAnimMode                            :db     ; EQU $C0A1 ; Tile animation mode for static screens
wStaticOBJCount                            :db     ; EQU $C0A2 ; Number of OBJ written to OAM (for static screens that call Static_WriteOBJLst)

wStaticPlLstId                             :db     ; EQU $C0A3
wStaticPlX                                 :db     ; EQU $C0A4
wStaticPlY                                 :db     ; EQU $C0A5
wStaticPlFlags                             :db     ; EQU $C0A6
UNION
wStaticPlAnimTimer                         :db     ; EQU $C0A7
NEXTU
wHeartBonusResultsTimer                    :db     ; EQU $C0A7
ENDU

wStaticSubMode                             :db     ; EQU $C0A8 ; Secondary submode / phase
DEF wIntroAct                                        EQU wStaticSubMode
DEF wCoinBonusAct                                    EQU wStaticSubMode
DEF wHeartBonusAct                                   EQU wStaticSubMode
DEF wEndAct                                          EQU wStaticSubMode

wStaticLoopsLeft                           :db     ; EQU $C0A9 ; Countdown timers
DEF wIntroWarioAnimCycleLeft                         EQU wStaticLoopsLeft
DEF wEndLoopsLeft                                    EQU wStaticLoopsLeft ; Counts down how long to play certain animations
DEF wEndLampRubLoopsLeft                             EQU wStaticLoopsLeft

wStaticTileAnimTimer                       :db     ; EQU $C0AA 
DEF wHeartBonusTileAnim                              EQU wStaticTileAnimTimer ; Marks if tile animations should be enabled in the Heart Bonus game

wStaticTileAnimTimer2                      :db     ; EQU $C0AB
DEF wTitleTileAnimTimer                              EQU wStaticTileAnimTimer2
DEF wIntroWaterOscillationTimer                      EQU wStaticTileAnimTimer2
DEF wBonusAnimTimer                                  EQU wStaticTileAnimTimer2
ds $01

wStaticDelayTimer                          :db     ; EQU $C0AD
DEF wTitleActTimer                                   EQU wStaticDelayTimer
DEF wIntroActTimer1                                  EQU wStaticDelayTimer
DEF wCoinBonusModeTimer                              EQU wStaticDelayTimer ; After hitting moneybag or 10ton
DEF wHeartBonusModeTimer                             EQU wStaticDelayTimer ; Multiple purposes -- generally waits to switch to the next mode/submode
DEF wEndPlMoveLDelay                                 EQU wStaticDelayTimer ; Before walking left to the treasure room

wIntroShipLstId                            :db     ; EQU $C0AE
wIntroShipX                                :db     ; EQU $C0AF
wIntroShipY                                :db     ; EQU $C0B0
wIntroActTimer                             :db     ; EQU $C0B1 ; General act timer / ship anim timer?

wIntroWaterSplash                          :db     ; EQU $C0B2
wIntroWaterSplashY                         :db     ; EQU $C0B3

; Sprite options for the actor held by the player
; In the first part (Ending0) it's a lamp.
; In the second part (Ending1) it's the moneybags.
wEndHeldLstId                              :db     ; EQU $C0B4
wEndHeldX                                  :db     ; EQU $C0B5
wEndHeldY                                  :db     ; EQU $C0B6
wEndLampThrowTimer                         :db     ; EQU $C0B7

UNION
wEndCloudLstId                             :db     ; EQU $C0B8
; wEndCloud0X also used for the "thinking" cloud
wEndCloud0X                                :db     ; EQU $C0B9   ; Coords for first cloud
wEndCloud0Y                                :db     ; EQU $C0BA
wEndCloud1Show                             :db     ; EQU $C0BB ; Set to 1 when the second cloud is visible
wEndCloud1X                                :db     ; EQU $C0BC   ; Coords for second cloud
wEndCloud1Y                                :db     ; EQU $C0BD
wEndCloudAnimTimer                         :db     ; EQU $C0BE
NEXTU
wEndWLogoLstId                             :db     ; EQU $C0B8 ; Same sprite mapping table as wEndCloudLstId technically
wEndWLogoX                                 :db     ; EQU $C0B9
wEndWLogoY                                 :db     ; EQU $C0BA
ds $03
wEndWLogoTimer                             :db     ; EQU $C0BE ; For the "W" mark before the credits start
ENDU

wEndGenieFaceLstId                         :db     ; EQU $C0BF
UNION
wEndBGFlashTimer                           :db     ; EQU $C0C0
NEXTU
wEndThrowDelay                             :db     ; EQU $C0C0 ; Wait before throwing moneybags
NEXTU
wEndGenieTimer                             :db     ; EQU $C0C0
ENDU
wEndBGWaveOffset                           :db     ; EQU $C0C1 ; Offset to wave effect tables, increased at the end of the frame to make the waves look like they're moving up
wEndBalloonLstId                           :db     ; EQU $C0C2 ; Marks who's speaking, placed on the edge of the balloon tilemap
wEndBalloonFrameSet                        :db     ; EQU $C0C3
wEndGenieHandLFrameSet                     :db     ; EQU $C0C4 ; Requested frame for genie's hands
wEndGenieHandRFrameSet                     :db     ; EQU $C0C5
wEndFlagAnimType                           :db     ; EQU $C0C6 ; Flag animation type
wEndFlagAnimTimer                          :db     ; EQU $C0C7 ; Flag animation timer

; The two bonus games
UNION
wHeartBonusShowCursor                      :db     ; EQU $C0C8 ; If set, it shows the cursor in the select screen
wHeartBonusDifficultySel                   :db     ; EQU $C0C9 ; Doubles as menu cursor (with $03 being the exit)
wHeartBonusShowResultFlash                 :db     ; EQU $C0CA ; If set, enables the black line flashing on the prize won in the result screen

wHeartBonusHudBombLstId                    :db     ; EQU $C0CB ; Temporary value for the frame id of the currently drawn Bomb in the HUD.
wHeartBonusHudBomb0LstId                   :db     ; EQU $C0CC ; 1st bomb
wHeartBonusHudBomb1LstId                   :db     ; EQU $C0CD ; 2nd bomb
wHeartBonusHudBomb2LstId                   :db     ; EQU $C0CE ; ...
wHeartBonusHudBomb3LstId                   :db     ; EQU $C0CF ; ...
wHeartBonusHudBomb4LstId                   :db     ; EQU $C0D0 ; ...
ds $01
wHeartBonusHitCount                        :db     ; EQU $C0D2 ; Number of hit enemies
wHeartBonusBombLstId                       :db     ; EQU $C0D3 ; OBJLst frame id - bomb
wHeartBonusBombX                           :db     ; EQU $C0D4 ; X pos of explosion
wHeartBonusBombY                           :db     ; EQU $C0D5 ; Y pos of explosion
UNION
wHeartBonusBombThrowPathIndex              :db     ; EQU $C0D6 ; Index to the "HeartBonus_ThrowPath*" tables
NEXTU
wHeartBonusExplTimer                       :db     ; EQU $C0D6
ENDU

wHeartBonusRoundNum                        :db     ; EQU $C0D7 ; Round number
wHeartBonusTextLstId                       :db     ; EQU $C0D8 ; Text type
wHeartBonusBombLightLstId                  :db     ; EQU $C0D9 ; for the fire on the bomb fuse, aligned so it reaches the bomb when the timer ticks 0
wHeartBonusBombLightX                      :db     ; EQU $C0DA ;
wHeartBonusBombLightY                      :db     ; EQU $C0DB ;
wHeartBonusBombLightTimer                  :db     ; EQU $C0DC ; Anim timer
wHeartBonusShowTime                        :db     ; EQU $C0DD ; Shows the time limit in the hud
wHeartBonusTimeDecTimer                    :db     ; EQU $C0DE ; Time limit -- "subseconds". Once it reaches $46, wHeartBonusTime decreases by 1.
UNION
wHeartBonusTime                            :db     ; EQU $C0DF ; Time limit -- doubles as OBJLst id of digit
NEXTU
wHeartBonusDigitLstId                      :db     ; EQU $C0DF ; ...and it's used for other types of digits as well (just not during main game)
ENDU

wHeartBonusEnemyLstId                      :db     ; EQU $C0E0 ; Enemy to hit with the bomb
wHeartBonusEnemyX                          :db     ; EQU $C0E1
wHeartBonusEnemyY                          :db     ; EQU $C0E2
wHeartBonusEnemyFlags                      :db     ; EQU $C0E3 ; Determines X flip
wHeartBonusEnemyTimer                      :db     ; EQU $C0E4 ; Animation timer

wHeartBonusShowPowerSel                    :db     ; EQU $C0E5 ; If set, shows the arrow above the current throw power in the HUD
wHeartBonusPowerSelX                       :db     ; EQU $C0E6
UNION
wHeartBonusThrowPower                      :db     ; EQU $C0E7 ; When reaches a certain value, the X pos resets
NEXTU
wHeartBonusThrowPathId                     :db     ; EQU $C0E7 ; The actual throw power of the bomb ($00-$07)
ENDU
ds $03
wHeartBonusShowHudLivesHearts              :db     ; EQU $C0EB
wHeartBonus_Unused_C0EC                    :db     ; EQU $C0EC
ds $01
wHeartBonusShowCoinCount                   :db     ; EQU $C0EE
wHeartBonusPlMode                          :db     ; EQU $C0EF ; 0: can move; 1: locked; 2: throw

UNION
wHeartBonusCoinDec                         :db     ; EQU $C0F0 ; Set when the game decrements coins after selecting a difficulty. Reset to $00 when it's done.
NEXTU
wHeartBonusEnemyHit                        :db     ; EQU $C0F0 ; If set, the enemy moves vertically and is marked as hit.
ENDU
wHeartBonusLivesChange                     :db     ; EQU $C0F1 ; Amount of hearts to add
wHeartBonusHeartsChange                    :db     ; EQU $C0F2 ; Amount of lives to add (effectively treated like the low byte)

NEXTU
ds $01
wCoinBonusPlayerPos                        :db     ; EQU $C0C9 ; Player position in coin bonus game
ds $09
wCoinBonusItemLstId                        :db     ; EQU $C0D3 ; OBJLst frame id
wCoinBonusItemX                            :db     ; EQU $C0D4 ; X pos of spawned item
wCoinBonusItemY                            :db     ; EQU $C0D5 ; Y pos of spawned item

ds $12
wCoinBonusBucketFrameSet                   :db     ; EQU $C0E8 ; Requested tilemap update type in coin bonus game
wCoinBonusRoundBGChg                       :db     ; EQU $C0E9 ; If a tilemap change is requested for updating the round number text
wCoinBonusRound                            :db     ; EQU $C0EA ; Bonus game round number
ds $05
wCoinBonusItemType                         :db     ; EQU $C0F0 ; The actual item spawned
wBonusGameCoinChange_High                  :db     ; EQU $C0F1 ; Amount of coins to add or remove
wBonusGameCoinChange_Low                   :db     ; EQU $C0F2
wCoinBonusItemTypeR                        :db     ; EQU $C0F3  ; COINBONUS_ITEM_* on the right bucket
wCoinBonusItemTypeL                        :db     ; EQU $C0F4  ; COINBONUS_ITEM_* on the left bucket
ENDU ; Bonus games end

ENDU

SECTION "HRAM", HRAM
hJoyKeys                                   :db     ; EQU $FF80 ; Held keys
hJoyNewKeys                                :db     ; EQU $FF81 ; Newly pressed keys
hVBlankDone                                :db     ; EQU $FF82 ; Set by the VBlank handler when it finishes
hIntEnable                                 :db     ; EQU $FF83 ; Backup for rIE when stopping the LCD
ds $03
hScrollY                                   :db     ; EQU $FF87 ; Base Y scroll position

; ====================================
; ============= STRUCTS ==============
; ====================================

DEF iSaveLevelsCleared     EQU $0D
DEF iSaveAllClear          EQU $17