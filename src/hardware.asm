; From https://raw.githubusercontent.com/pret/pokered/master/constants/hardware_constants.asm / http://nocash.emubase.de/pandocs.htm.

DEF GBC EQU $11

; memory map
DEF VRAM_Begin  EQU $8000
DEF VRAM_End    EQU $a000
DEF Tiles_Begin      EQU $8000
DEF Tiles_End        EQU $9800
DEF BGMap_Begin      EQU $9800
DEF BGMap_End        EQU $9C00
DEF WINDOWMap_Begin  EQU $9C00
DEF WINDOWMap_End    EQU $A000
DEF SRAM_Begin  EQU $a000
DEF SRAM_End    EQU $c000
DEF WRAM_Begin EQU $c000
;DEF WRAM0_End   EQU $d000
;DEF WRAM1_Begin EQU $d000
DEF WRAM_End   EQU $e000
DEF OAM_Begin EQU $fe00
DEF OAM_End   EQU $fea0
; hardware registers $ff00-$ff80 (see below)
DEF HRAM_Begin  EQU $ff80
DEF HRAM_End    EQU $ffff

; MBC1
DEF MBC1SRamEnable      EQU $0000
DEF MBC1RomBank         EQU $2100 ; Why, just why
DEF MBC1RomBank2        EQU $2000
DEF MBC1SRamBank        EQU $4000
DEF MBC1SRamBankingMode EQU $6000

DEF SRAM_DISABLE EQU $00
DEF SRAM_ENABLE  EQU $0a

;DEF NUM_SRAM_BANKS EQU 4

; screen pos without wrap, relative to the top left corner of the screen
DEF SCREEN_XMIN EQU $00
DEF SCREEN_XMAX EQU $60
DEF SCREEN_YMIN EQU $00
DEF SCREEN_YMAX EQU $70
; screen size
DEF SCREEN_H EQU $A0 ; Right border
DEF SCREEN_V EQU $90 ; Top border
; Number of tiles in tilemap
DEF BG_TILECOUNT_H EQU $20
DEF BG_TILECOUNT_V EQU $20
DEF TILE_H EQU $08
DEF TILE_V EQU $08
; Total tilemap size
DEF TILEMAP_H EQU BG_TILECOUNT_H * TILE_H ; $100
DEF TILEMAP_V EQU BG_TILECOUNT_V * TILE_V ; $100
; Bytes in a tile
DEF TILESIZE EQU $10

DEF OBJ_SIZE     EQU 4		; Size of one OBJ
DEF OBJCOUNT_MAX EQU $28	; Max number of OBJ
; The hardware subtracts these from the object positions before displaying them.
DEF OBJ_OFFSET_X EQU $08
DEF OBJ_OFFSET_Y EQU $10

; interrupt flags
DEF IB_VBLANK        EQU 0
DEF IB_STAT          EQU 1
DEF IB_TIMER         EQU 2
DEF IB_SERIAL        EQU 3
DEF IB_JOYPAD        EQU 4
DEF I_VBLANK         EQU 1 << IB_VBLANK
DEF I_STAT           EQU 1 << IB_STAT
DEF I_TIMER          EQU 1 << IB_TIMER
DEF I_SERIAL         EQU 1 << IB_SERIAL
DEF I_JOYPAD         EQU 1 << IB_JOYPAD

; DMG palette indexes
DEF COL_WHITE        equ 0
DEF COL_LTGRAY       equ 1
DEF COL_DKGRAY       equ 2
DEF COL_BLACK        equ 3


DEF LY_VBLANK EQU $90

; rLCDC Flags
DEF LCDCB_PRIORITY    equ 0
DEF LCDCB_OBJENABLE   equ 1
DEF LCDCB_OBJSIZE     equ 2
DEF LCDCB_BGTILEMAP   equ 3
DEF LCDCB_TILEDATA    equ 4
DEF LCDCB_WENABLE     equ 5
DEF LCDCB_WTILEMAP    equ 6
DEF LCDCB_ENABLE      equ 7

DEF LCDC_PRIORITY    equ 1
DEF LCDC_OBJENABLE   equ %10
DEF LCDC_OBJSIZE     equ %100
DEF LCDC_BGTILEMAP   equ %1000
DEF LCDC_TILEDATA    equ %10000
DEF LCDC_WENABLE     equ %100000
DEF LCDC_WTILEMAP    equ %1000000
DEF LCDC_ENABLE      equ %10000000

; OAM
DEF OAM_Y     EQU $00
DEF OAM_X     EQU $01
DEF OAM_TILE  EQU $02
DEF OAM_FLAGS EQU $03

; OAM Sprite Flags
DEF SPRB_OBP1       EQU 4
DEF SPRB_XFLIP      EQU 5
DEF SPRB_YFLIP      EQU 6
DEF SPRB_BGPRIORITY EQU 7
DEF SPR_OBP0        EQU $00
DEF SPR_OBP1        EQU 1 << SPRB_OBP1     
DEF SPR_XFLIP       EQU 1 << SPRB_XFLIP    
DEF SPR_YFLIP       EQU 1 << SPRB_YFLIP    
DEF SPR_BGPRIORITY  EQU 1 << SPRB_BGPRIORITY 

; NR*2 Flags
DEF SNDENVB_INC EQU 3 ; If set, it's an increasing envelope sweep
DEF SNDENV_INC EQU 1 << SNDENVB_INC
DEF SNDENV_DEC EQU 0 ; Macro purpose only

; NR*4 Flags
DEF SNDCHFB_RESTART EQU 7 ; If set, triggers/restarts the channel (to apply certain types of changes)
DEF SNDCHFB_LENSTOP EQU 6 ; If set, the channel kills itself when the length expires.
DEF SNDCHF_RESTART EQU 1 << SNDCHFB_RESTART
DEF SNDCHF_LENSTOP EQU 1 << SNDCHFB_LENSTOP


; NR30 Flags
DEF SNDCH3B_ON       EQU 7
DEF SNDCH3_ON        EQU 1 << SNDCH3B_ON
DEF SNDCH3_OFF       EQU $0

; NR51 Flags
; Used to select the specific sound channels to output, for both the left and right speaker.
DEF SNDOUTB_CH1R     equ 0
DEF SNDOUTB_CH2R     equ 1
DEF SNDOUTB_CH3R     equ 2
DEF SNDOUTB_CH4R     equ 3
DEF SNDOUTB_CH1L     equ 4
DEF SNDOUTB_CH2L     equ 5
DEF SNDOUTB_CH3L     equ 6
DEF SNDOUTB_CH4L     equ 7

DEF SNDOUT_CH1R      equ 1 << SNDOUTB_CH1R
DEF SNDOUT_CH2R      equ 1 << SNDOUTB_CH2R
DEF SNDOUT_CH3R      equ 1 << SNDOUTB_CH3R
DEF SNDOUT_CH4R      equ 1 << SNDOUTB_CH4R
DEF SNDOUT_CH1L      equ 1 << SNDOUTB_CH1L
DEF SNDOUT_CH2L      equ 1 << SNDOUTB_CH2L
DEF SNDOUT_CH3L      equ 1 << SNDOUTB_CH3L
DEF SNDOUT_CH4L      equ 1 << SNDOUTB_CH4L
DEF SNDOUT_CHALL     equ $FF ; Shorthand for playing every channel on every speaker

; NR52 - Sound control
; Used to select the channels to enable
DEF SNDCTRL_CH1      equ 1                  ; Get the on/off status for individual sound channels
DEF SNDCTRL_CH2      equ %10
DEF SNDCTRL_CH3      equ %100
DEF SNDCTRL_CH4      equ %1000
DEF SNDCTRL_ON       equ %10000000          ; Enables all sound processing

; rSTAT MODE flag
; For knowing which mode we are in
DEF ST_HBLANK        EQU 0
DEF ST_VBLANK        EQU 1
DEF ST_OAMSEARCH     EQU 2
DEF ST_TRANSFER      EQU 3

DEF STAT_LYC         EQU $40
DEF STATB_LYC        EQU 6

; Constants related to Hardware joypad keys
DEF HKEY_SEL_BTN     EQU %10000
DEF HKEY_SEL_DPAD    EQU %100000

;--

; serial
DEF START_TRANSFER_EXTERNAL_CLOCK EQU $80
DEF START_TRANSFER_INTERNAL_CLOCK EQU $81

;--
; sgb

DEF SGB_BIT_RESET	EQU $00 ; Reset signal at the start of a packet
DEF SGB_BIT_1 		EQU $10 ; Sends a set bit
DEF SGB_BIT_0		EQU $20 ; Sends a cleared bit
DEF SGB_BIT_SEP		EQU $30 ; Separator between bits


DEF SGB_PACKET_PAL01    EQU $00 ; Set SGB Palette 0,1 Data
DEF SGB_PACKET_PAL23    EQU $01 ; Set SGB Palette 2,3 Data
DEF SGB_PACKET_PAL03    EQU $02 ; Set SGB Palette 0,3 Data
DEF SGB_PACKET_PAL12    EQU $03 ; Set SGB Palette 1,2 Data
DEF SGB_PACKET_ATTR_BLK EQU $04 ; "Block" Area Designation Mode
DEF SGB_PACKET_ATTR_LIN EQU $05 ; "Line" Area Designation Mode
DEF SGB_PACKET_ATTR_DIV EQU $06 ; "Divide" Area Designation Mode
DEF SGB_PACKET_ATTR_CHR EQU $07 ; "1CHR" Area Designation Mode
DEF SGB_PACKET_SOUND    EQU $08 ; Sound On/Off
DEF SGB_PACKET_SOU_TRN  EQU $09 ; Transfer Sound PRG/DATA
DEF SGB_PACKET_PAL_SET  EQU $0A ; Set SGB Palette Indirect
DEF SGB_PACKET_PAL_TRN  EQU $0B ; Set System Color Palette Data
DEF SGB_PACKET_ATRC_EN  EQU $0C ; Enable/disable Attraction Mode
DEF SGB_PACKET_TEST_EN  EQU $0D ; Speed Function
DEF SGB_PACKET_ICON_EN  EQU $0E ; SGB Function
DEF SGB_PACKET_DATA_SND EQU $0F ; SUPER NES WRAM Transfer 1
DEF SGB_PACKET_DATA_TRN EQU $10 ; SUPER NES WRAM Transfer 2
DEF SGB_PACKET_MLT_REQ  EQU $11 ; Controller 2 Request
DEF SGB_PACKET_JUMP     EQU $12 ; Set SNES Program Counter
DEF SGB_PACKET_CHR_TRN  EQU $13 ; Transfer Character Font Data
DEF SGB_PACKET_PCT_TRN  EQU $14 ; Set Screen Data Color Data
DEF SGB_PACKET_ATTR_TRN EQU $15 ; Set Attribute from ATF
DEF SGB_PACKET_ATTR_SET EQU $16 ; Set Data to ATF
DEF SGB_PACKET_MASK_EN  EQU $17 ; Game Boy Window Mask
DEF SGB_PACKET_OBJ_TRN  EQU $18 ; Super NES OBJ Mode

DEF SGB_SND_A_DUMMY        EQU $00	;Dummy flag, re-trigger	-	2
DEF SGB_SND_A_NINTENDO     EQU $01	;Nintendo	3	1
DEF SGB_SND_A_GAMEOVER     EQU $02	;Game Over	3	2
DEF SGB_SND_A_DROP         EQU $03	;Drop	3	1
DEF SGB_SND_A_OK_A         EQU $04	;OK … A	3	2
DEF SGB_SND_A_OK_B         EQU $05	;OK … B	3	2
DEF SGB_SND_A_SELECT_A     EQU $06	;Select…A	3	2
DEF SGB_SND_A_SELECT_B     EQU $07	;Select…B	3	1
DEF SGB_SND_A_SELECT_C     EQU $08	;Select…C	2	2
DEF SGB_SND_A_BUZZ         EQU $09	;Mistake…Buzzer	2	1
DEF SGB_SND_A_ITEMGET      EQU $0A	;Catch Item	2	2
DEF SGB_SND_A_GATE         EQU $0B	;Gate squeaks 1 time	2	2
DEF SGB_SND_A_EXPL_SM      EQU $0C	;Explosion…small	1	2
DEF SGB_SND_A_EXPL_MD      EQU $0D	;Explosion…medium	1	2
DEF SGB_SND_A_EXPL_LG      EQU $0E	;Explosion…large	1	2
DEF SGB_SND_A_ATTACK_A     EQU $0F	;Attacked…A	3	1
DEF SGB_SND_A_ATTACK_B     EQU $10	;Attacked…B	3	2
DEF SGB_SND_A_PUNCH_A      EQU $11	;Hit (punch)…A	0	2
DEF SGB_SND_A_PUNCH_B      EQU $12	;Hit (punch)…B	0	2
DEF SGB_SND_A_BREATH       EQU $13	;Breath in air	3	2
DEF SGB_SND_A_JETPROJ_A    EQU $14	;Rocket Projectile…A	3	2
DEF SGB_SND_A_JETPROJ_B    EQU $15	;Rocket Projectile…B	3	2
DEF SGB_SND_A_ESCBUBL      EQU $16	;Escaping Bubble	2	1
DEF SGB_SND_A_JUMP         EQU $17	;Jump	3	1
DEF SGB_SND_A_FASTJUMP     EQU $18	;Fast Jump	3	1
DEF SGB_SND_A_JETSTART     EQU $19	;Jet (rocket) takeoff	0	1
DEF SGB_SND_A_JETLAND      EQU $1A	;Jet (rocket) landing	0	1
DEF SGB_SND_A_CUPBREAK     EQU $1B	;Cup breaking	2	2
DEF SGB_SND_A_GLASSBREAK   EQU $1C	;Glass breaking	1	2
DEF SGB_SND_A_LEVELUP      EQU $1D	;Level UP	2	2
DEF SGB_SND_A_INSERTAIR    EQU $1E	;Insert air	1	1
DEF SGB_SND_A_SWORDSWING   EQU $1F	;Sword swing	1	1
DEF SGB_SND_A_WATERFALL    EQU $20	;Water falling	2	1
DEF SGB_SND_A_FIRE         EQU $21	;Fire	1	1
DEF SGB_SND_A_WALLCOLLAPSE EQU $22	;Wall collapsing	1	2
DEF SGB_SND_A_CANCEL       EQU $23	;Cancel	1	2
DEF SGB_SND_A_WALK         EQU $24	;Walking	1	2
DEF SGB_SND_A_BLOCKSTRIKE  EQU $25	;Blocking strike	1	2
DEF SGB_SND_A_PICTFLOAT    EQU $26	;Picture floats on & off	3	2
DEF SGB_SND_A_FADEIN       EQU $27	;Fade in	0	2
DEF SGB_SND_A_FADEOUT      EQU $28	;Fade out	0	2
DEF SGB_SND_A_WINOPEN      EQU $29	;Window being opened	1	2
DEF SGB_SND_A_WINCLOSE     EQU $2A	;Window being closed	0	2
DEF SGB_SND_A_LASER_LG     EQU $2B	;Big Laser	3	2
DEF SGB_SND_A_STONEGATE    EQU $2C	;Stone gate closes/opens	0	2
DEF SGB_SND_A_TELEPORT     EQU $2D	;Teleportation	3	1
DEF SGB_SND_A_LIGHTNING    EQU $2E	;Lightning	0	2
DEF SGB_SND_A_EARTHQUAKE   EQU $2F	;Earthquake	0	2
DEF SGB_SND_A_LASER_SM     EQU $30	;Small Laser	2	2
DEF SGB_SND_A_STOP         EQU $80	;Effect A, stop/silent	-

DEF SGB_SND_B_DUMMY        EQU $00 ;Dummy flag, re-trigger	-	4
DEF SGB_SND_B_APPLAUSE_SM  EQU $01 ;Applause…small group	2	1
DEF SGB_SND_B_APPLAUSE_MD  EQU $02 ;Applause…medium group	2	2
DEF SGB_SND_B_APPLAUSE_LG  EQU $03 ;Applause…large group	2	4
DEF SGB_SND_B_WIND         EQU $04 ;Wind	1	2
DEF SGB_SND_B_RAIN         EQU $05 ;Rain	1	1
DEF SGB_SND_B_STORM        EQU $06 ;Storm	1	3
DEF SGB_SND_B_STORM_ALL    EQU $07 ;Storm with wind/thunder	2	4
DEF SGB_SND_B_LIGHTNING    EQU $08 ;Lightning	0	2
DEF SGB_SND_B_EARTHQUAKE   EQU $09 ;Earthquake	0	2
DEF SGB_SND_B_AVALANCHE    EQU $0A ;Avalanche	0	2
DEF SGB_SND_B_WAVE         EQU $0B ;Wave	0	1
DEF SGB_SND_B_RIVER        EQU $0C ;River	3	2
DEF SGB_SND_B_WATERFALL    EQU $0D ;Waterfall	2	2
DEF SGB_SND_B_RUNMAN       EQU $0E ;Small character running	3	1
DEF SGB_SND_B_RUNHORSE     EQU $0F ;Horse running	3	1
DEF SGB_SND_B_WARNING      EQU $10 ;Warning sound	1	1
DEF SGB_SND_B_CAR          EQU $11 ;Approaching car	0	1
DEF SGB_SND_B_JET          EQU $12 ;Jet flying	1	1
DEF SGB_SND_B_UFO          EQU $13 ;UFO flying	2	1
DEF SGB_SND_B_ELECWAVE     EQU $14 ;Electromagnetic waves	0	1
DEF SGB_SND_B_SCOREUP      EQU $15 ;Score UP	3	1
DEF SGB_SND_B_FIRE         EQU $16 ;Fire	2	1
DEF SGB_SND_B_CAMERA       EQU $17 ;Camera shutter, formanto	3	4
DEF SGB_SND_B_WRITE        EQU $18 ;Write, formanto	0	1
DEF SGB_SND_B_TITLE        EQU $19 ;Show up title, formanto	0	1
DEF SGB_SND_B_STOP         EQU $80 ;Effect B, stop/silent	-	4

; Hardware registers
DEF rJOYP       EQU $ff00 ; Joypad (R/W)
DEF rSB         EQU $ff01 ; Serial transfer data (R/W)
DEF rSC         EQU $ff02 ; Serial Transfer Control (R/W)
DEF rSC_ON    EQU 7
DEF rSC_CGB   EQU 1
DEF rSC_CLOCK EQU 0

DEF rDIV        EQU $ff04 ; Divider Register (R/W)
DEF rTIMA       EQU $ff05 ; Timer counter (R/W)
DEF rTMA        EQU $ff06 ; Timer Modulo (R/W)
DEF rTAC        EQU $ff07 ; Timer Control (R/W)
DEF rTAC_ON        EQU 2
DEF rTAC_4096_HZ   EQU 0
DEF rTAC_262144_HZ EQU 1
DEF rTAC_65536_HZ  EQU 2
DEF rTAC_16384_HZ  EQU 3
DEF rIF         EQU $ff0f ; Interrupt Flag (R/W)
DEF rNR10       EQU $ff10 ; Channel 1 Sweep register (R/W)
DEF rNR11       EQU $ff11 ; Channel 1 Sound length/Wave pattern duty (R/W)
DEF rNR12       EQU $ff12 ; Channel 1 Volume Envelope (R/W)
DEF rNR13       EQU $ff13 ; Channel 1 Frequency lo (Write Only)
DEF rNR14       EQU $ff14 ; Channel 1 Frequency hi (R/W)
DEF rNR21       EQU $ff16 ; Channel 2 Sound Length/Wave Pattern Duty (R/W)
DEF rNR22       EQU $ff17 ; Channel 2 Volume Envelope (R/W)
DEF rNR23       EQU $ff18 ; Channel 2 Frequency lo data (W)
DEF rNR24       EQU $ff19 ; Channel 2 Frequency hi data (R/W)
DEF rNR30       EQU $ff1a ; Channel 3 Sound on/off (R/W)
DEF rNR31       EQU $ff1b ; Channel 3 Sound Length
DEF rNR32       EQU $ff1c ; Channel 3 Select output level (R/W)
DEF rNR33       EQU $ff1d ; Channel 3 Frequency's lower data (W)
DEF rNR34       EQU $ff1e ; Channel 3 Frequency's higher data (R/W)
DEF rNR41       EQU $ff20 ; Channel 4 Sound Length (R/W)
DEF rNR42       EQU $ff21 ; Channel 4 Volume Envelope (R/W)
DEF rNR43       EQU $ff22 ; Channel 4 Polynomial Counter (R/W)
DEF rNR44       EQU $ff23 ; Channel 4 Counter/consecutive; Initial (R/W)
DEF rNR50       EQU $ff24 ; Channel control / ON-OFF / Volume (R/W)
DEF rNR51       EQU $ff25 ; Selection of Sound output terminal (R/W)
DEF rNR52       EQU $ff26 ; Sound on/off
DEF rWave       EQU $ff30
DEF rWave_0     EQU $ff30
DEF rWave_1     EQU $ff31
DEF rWave_2     EQU $ff32
DEF rWave_3     EQU $ff33
DEF rWave_4     EQU $ff34
DEF rWave_5     EQU $ff35
DEF rWave_6     EQU $ff36
DEF rWave_7     EQU $ff37
DEF rWave_8     EQU $ff38
DEF rWave_9     EQU $ff39
DEF rWave_a     EQU $ff3a
DEF rWave_b     EQU $ff3b
DEF rWave_c     EQU $ff3c
DEF rWave_d     EQU $ff3d
DEF rWave_e     EQU $ff3e
DEF rWave_f     EQU $ff3f
DEF rWave_End   EQU $ff40
DEF rLCDC       EQU $ff40 ; LCD Control (R/W)
DEF rSTAT       EQU $ff41 ; LCDC Status (R/W)
DEF rSCY        EQU $ff42 ; Scroll Y (R/W)
DEF rSCX        EQU $ff43 ; Scroll X (R/W)
DEF rLY         EQU $ff44 ; LCDC Y-Coordinate (R)
DEF rLYC        EQU $ff45 ; LY Compare (R/W)
DEF rDMA        EQU $ff46 ; DMA Transfer and Start Address (W)
DEF rBGP        EQU $ff47 ; BG Palette Data (R/W) - Non CGB Mode Only
DEF rOBP0       EQU $ff48 ; Object Palette 0 Data (R/W) - Non CGB Mode Only
DEF rOBP1       EQU $ff49 ; Object Palette 1 Data (R/W) - Non CGB Mode Only
DEF rWY         EQU $ff4a ; Window Y Position (R/W)
DEF rWX         EQU $ff4b ; Window X Position minus 7 (R/W)
DEF rKEY1       EQU $ff4d ; CGB Mode Only - Prepare Speed Switch
DEF rVBK        EQU $ff4f ; CGB Mode Only - VRAM Bank
DEF rHDMA1      EQU $ff51 ; CGB Mode Only - New DMA Source, High
DEF rHDMA2      EQU $ff52 ; CGB Mode Only - New DMA Source, Low
DEF rHDMA3      EQU $ff53 ; CGB Mode Only - New DMA Destination, High
DEF rHDMA4      EQU $ff54 ; CGB Mode Only - New DMA Destination, Low
DEF rHDMA5      EQU $ff55 ; CGB Mode Only - New DMA Length/Mode/Start
DEF rRP         EQU $ff56 ; CGB Mode Only - Infrared Communications Port
DEF rBGPI       EQU $ff68 ; CGB Mode Only - Background Palette Index
DEF rBGPD       EQU $ff69 ; CGB Mode Only - Background Palette Data
DEF rOBPI       EQU $ff6a ; CGB Mode Only - Sprite Palette Index
DEF rOBPD       EQU $ff6b ; CGB Mode Only - Sprite Palette Data
DEF rUNKNOWN1   EQU $ff6c ; (FEh) Bit 0 (Read/Write) - CGB Mode Only
DEF rSVBK       EQU $ff70 ; CGB Mode Only - WRAM Bank
DEF rUNKNOWN2   EQU $ff72 ; (00h) - Bit 0-7 (Read/Write)
DEF rUNKNOWN3   EQU $ff73 ; (00h) - Bit 0-7 (Read/Write)
DEF rUNKNOWN4   EQU $ff74 ; (00h) - Bit 0-7 (Read/Write) - CGB Mode Only
DEF rUNKNOWN5   EQU $ff75 ; (8Fh) - Bit 4-6 (Read/Write)
DEF rUNKNOWN6   EQU $ff76 ; (00h) - Always 00h (Read Only)
DEF rUNKNOWN7   EQU $ff77 ; (00h) - Always 00h (Read Only)
DEF rIE         EQU $ffff ; Interrupt Enable (R/W)