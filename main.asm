; Include the basics
INCLUDE "src/hardware.asm"
INCLUDE "src/constants.asm"
INCLUDE "src/macro.asm"
INCLUDE "src/memory.asm"

;IF DEBUG == 1
;	printt "HEH"
;ENDC

; Common code, HomeCall targets (a bit of everything)
SECTION "bank00", ROM0
INCLUDE "src/bank00.asm"

; Mode/Submode Jump & Gameplay mode + other misc modes (Course Clear, Treasure Room, Credits Text...)
SECTION "bank01", ROMX, BANK[$01]
INCLUDE "src/bank01.asm"

; Actor handler, SubCall targets for actor code, Shared Actors, Actor code
SECTION "bank02", ROMX, BANK[$02]
INCLUDE "src/bank02.asm"

; Level GFX
SECTION "bank03", ROMX, BANK[$03]
INCLUDE "src/bank03.asm"

; Sound driver
SECTION "bank04", ROMX, BANK[$04]
INCLUDE "src/bank04.asm"

; Screen event (tile update), Main Sprite Mappings ("OBJLst") set
SECTION "bank05", ROMX, BANK[$05]
INCLUDE "src/bank05.asm"

; Compressed GFX / Tilemaps
SECTION "bank06", ROMX, BANK[$06]
INCLUDE "src/bank06.asm"

; Actor layouts, Actor groups, Actor code
SECTION "bank07", ROMX, BANK[$07]
INCLUDE "src/bank07.asm"

; Map screen code
SECTION "bank08", ROMX, BANK[$08]
INCLUDE "src/bank08.asm"

; Compressed GFX / Tilemaps for Map Screen
SECTION "bank09", ROMX, BANK[$09]
INCLUDE "src/bank09.asm"

; Level layouts
SECTION "bank0A", ROMX, BANK[$A]
INCLUDE "src/bank0A.asm"

; 16x16 Block Data ("block16")
SECTION "bank0B", ROMX, BANK[$B]
INCLUDE "src/bank0B.asm"

; Level / Room Headers
SECTION "bank0C", ROMX, BANK[$C]
INCLUDE "src/bank0C.asm"

; Gameplay, Player Controls, ExActor handler + code, Screen event (tile update) and Parallax modes
SECTION "bank0D", ROMX, BANK[$D]
INCLUDE "src/bank0D.asm"

; Level GFX
SECTION "bank0E", ROMX, BANK[$E]
INCLUDE "src/bank0E.asm"

; Actor code
SECTION "bank0F", ROMX, BANK[$F]
INCLUDE "src/bank0F.asm"

; Level Layouts
SECTION "bank10", ROMX, BANK[$10]
INCLUDE "src/bank10.asm"

; Shared level GFX, Animated Level GFX
SECTION "bank11", ROMX, BANK[$11]
INCLUDE "src/bank11.asm"

; Title screen, Actor code
SECTION "bank12", ROMX, BANK[$12]
INCLUDE "src/bank12.asm"

; Level Layouts
SECTION "bank13", ROMX, BANK[$13]
INCLUDE "src/bank13.asm"

; Compressed GFX / Tilemaps for Map Screen, Cutscenes, OBJ Drawing
SECTION "bank14", ROMX, BANK[$14]
INCLUDE "src/bank14.asm"

; Actor code
SECTION "bank15", ROMX, BANK[$15]
INCLUDE "src/bank15.asm"

; Level Layouts
SECTION "bank16", ROMX, BANK[$16]
INCLUDE "src/bank16.asm"

; Actor code
SECTION "bank17", ROMX, BANK[$17]
INCLUDE "src/bank17.asm"

; Actor code
SECTION "bank18", ROMX, BANK[$18]
INCLUDE "src/bank18.asm"

; Level Layouts
SECTION "bank19", ROMX, BANK[$19]
INCLUDE "src/bank19.asm"

; Level Layouts
SECTION "bank1A", ROMX, BANK[$1A]
INCLUDE "src/bank1A.asm"

; Actor code
SECTION "bank1B", ROMX, BANK[$1B]
INCLUDE "src/bank1B.asm"

; Level Layouts
SECTION "bank1C", ROMX, BANK[$1C]
INCLUDE "src/bank1C.asm"

; Level GFX
SECTION "bank1D", ROMX, BANK[$1D]
INCLUDE "src/bank1D.asm"

; Bonus Games
SECTION "bank1E", ROMX, BANK[$1E]
INCLUDE "src/bank1E.asm"

; Ending and Credits Cutscenes
SECTION "bank1F", ROMX, BANK[$1F]
INCLUDE "src/bank1F.asm"
