;
; BANK $09 - Map Graphics & Tilemaps
;

; =============== LoadGFX_SubmapOBJ ===============
; Copies the shared submap OBJ graphics to VRAM.
; The upper portion of the compressed submap GFX is left empty to make space for these tiles.
LoadGFX_SubmapOBJ:
	ld   hl, GFX_SubmapOBJ	; HL = Ptr to uncompressed GFX
	ld   de, Tiles_Begin	; DE = Destination (start of tile data in VRAM)
	ld   bc, (GFX_SubmapOBJ_End - GFX_SubmapOBJ) ; BC = Bytes to copy
.loop:
	ldi  a, [hl]			; Perform the copy
	ld   [de], a
	inc  de
	dec  bc
	ld   a, b				; If we aren't done (BC != 0), copy the next byte
	or   a, c
	jr   nz, .loop
	ret
LoadGFX_SyrupCastle:
	ld   hl, GFXRLE_SyrupCastle
	call DecompressGFX
	jr   LoadGFX_SubmapOBJ
LoadGFX_MtTeapot_RiceBeach:
	ld   hl, GFXRLE_MtTeapot_RiceBeach
	call DecompressGFX
	jr   LoadGFX_SubmapOBJ
LoadGFX_StoveCanyon_SSTeacup:
	ld   hl, GFXRLE_StoveCanyon_SSTeacup
	call DecompressGFX
	jr   LoadGFX_SubmapOBJ
LoadBG_RiceBeach:
	ld   hl, BGRLE_RiceBeach
	ld   bc, BGMap_Begin
	call DecompressBG
	ret
LoadBG_Overworld:
	ld   hl, BGRLE_Overworld
	ld   bc, BGMap_Begin
	call DecompressBG
	ret
LoadBG_MtTeapot:
	ld   hl, BGRLE_MtTeapot
	ld   bc, BGMap_Begin
	call DecompressBG
	ret
LoadBG_StoveCanyon:
	ld   hl, BGRLE_StoveCanyon
	ld   bc, BGMap_Begin
	call DecompressBG
	ret
LoadBG_SSTeacup:
	ld   hl, BGRLE_SSTeacup
	ld   bc, BGMap_Begin
	call DecompressBG
	ret
LoadBG_SyrupCastle:
	ld   hl, BGRLE_SyrupCastle
	ld   bc, BGMap_Begin
	call DecompressBG
	ret
LoadBG_RiceBeachFlooded:
	ld   hl, BGRLE_RiceBeachFlooded
	ld   bc, BGMap_Begin
	call DecompressBG
	ret
LoadBG_SyrupCastleEnding:
	ld   hl, BGRLE_SyrupCastleEnding
	ld   bc, BGMap_Begin
	call DecompressBG
	ret
	
GFXRLE_MtTeapot_RiceBeach: INCBIN "data/gfx/maps/mtteapot_ricebeach.rlc"
GFXRLE_StoveCanyon_SSTeacup: INCBIN "data/gfx/maps/stovecanyon_ssteacup.rlc"
GFXRLE_SyrupCastle: INCBIN "data/gfx/maps/syrupcastle.rlc"
BGRLE_Overworld: INCBIN "data/bg/maps/overworld.rls"
BGRLE_RiceBeach: INCBIN "data/bg/maps/ricebeach.rls"
BGRLE_MtTeapot: INCBIN "data/bg/maps/mtteapot.rls"
BGRLE_StoveCanyon: INCBIN "data/bg/maps/stovecanyon.rls"
BGRLE_SSTeacup: INCBIN "data/bg/maps/ssteacup.rls"
BGRLE_SyrupCastle: INCBIN "data/bg/maps/syrupcastle.rls"
BGRLE_RiceBeachFlooded: INCBIN "data/bg/maps/ricebeach_flood.rls"
BGRLE_SyrupCastleEnding: INCBIN "data/bg/maps/syrupcastle_ending.rls"
GFX_SubmapOBJ: INCBIN "data/gfx/maps/submap_obj.bin"
GFX_SubmapOBJ_End:

; =============== END OF BANK ===============
IF SKIP_JUNK == 0
	INCLUDE "src/align_junk/L097F32.asm"
ENDC