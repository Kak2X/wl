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
L097F32: db $0A;X
L097F33: db $88;X
L097F34: db $AA;X
L097F35: db $AA;X
L097F36: db $A2;X
L097F37: db $82;X
L097F38: db $8A;X
L097F39: db $82;X
L097F3A: db $A8;X
L097F3B: db $A8;X
L097F3C: db $08;X
L097F3D: db $A0;X
L097F3E: db $0A;X
L097F3F: db $A2;X
L097F40: db $AA;X
L097F41: db $02;X
L097F42: db $AA;X
L097F43: db $A2;X
L097F44: db $AA;X
L097F45: db $A0;X
L097F46: db $AA;X
L097F47: db $28;X
L097F48: db $82;X
L097F49: db $2A;X
L097F4A: db $AA;X
L097F4B: db $2A;X
L097F4C: db $2A;X
L097F4D: db $22;X
L097F4E: db $A8;X
L097F4F: db $2A;X
L097F50: db $A8;X
L097F51: db $22;X
L097F52: db $AA;X
L097F53: db $22;X
L097F54: db $28;X
L097F55: db $AA;X
L097F56: db $02;X
L097F57: db $A2;X
L097F58: db $AA;X
L097F59: db $AA;X
L097F5A: db $88;X
L097F5B: db $82;X
L097F5C: db $82;X
L097F5D: db $2A;X
L097F5E: db $A2;X
L097F5F: db $AA;X
L097F60: db $8A;X
L097F61: db $8A;X
L097F62: db $22;X
L097F63: db $2A;X
L097F64: db $2A;X
L097F65: db $AA;X
L097F66: db $AA;X
L097F67: db $88;X
L097F68: db $A8;X
L097F69: db $AA;X
L097F6A: db $8A;X
L097F6B: db $00;X
L097F6C: db $88;X
L097F6D: db $08;X
L097F6E: db $0A;X
L097F6F: db $80;X
L097F70: db $A2;X
L097F71: db $A2;X
L097F72: db $28;X
L097F73: db $A8;X
L097F74: db $8A;X
L097F75: db $82;X
L097F76: db $8A;X
L097F77: db $08;X
L097F78: db $A2;X
L097F79: db $A2;X
L097F7A: db $8A;X
L097F7B: db $20;X
L097F7C: db $A8;X
L097F7D: db $8A;X
L097F7E: db $AA;X
L097F7F: db $22;X
L097F80: db $BA;X
L097F81: db $EA;X
L097F82: db $AE;X
L097F83: db $AE;X
L097F84: db $BE;X
L097F85: db $EE;X
L097F86: db $FA;X
L097F87: db $EE;X
L097F88: db $EA;X
L097F89: db $BA;X
L097F8A: db $AA;X
L097F8B: db $BE;X
L097F8C: db $EE;X
L097F8D: db $EE;X
L097F8E: db $AA;X
L097F8F: db $BE;X
L097F90: db $AE;X
L097F91: db $AA;X
L097F92: db $AF;X
L097F93: db $AA;X
L097F94: db $AB;X
L097F95: db $AE;X
L097F96: db $AA;X
L097F97: db $EB;X
L097F98: db $AE;X
L097F99: db $BA;X
L097F9A: db $AA;X
L097F9B: db $AE;X
L097F9C: db $AA;X
L097F9D: db $AF;X
L097F9E: db $AF;X
L097F9F: db $AA;X
L097FA0: db $BA;X
L097FA1: db $EE;X
L097FA2: db $AE;X
L097FA3: db $EF;X
L097FA4: db $AA;X
L097FA5: db $EA;X
L097FA6: db $AB;X
L097FA7: db $AE;X
L097FA8: db $EE;X
L097FA9: db $AE;X
L097FAA: db $BA;X
L097FAB: db $FE;X
L097FAC: db $AB;X
L097FAD: db $EF;X
L097FAE: db $AF;X
L097FAF: db $EB;X
L097FB0: db $AE;X
L097FB1: db $AB;X
L097FB2: db $EA;X
L097FB3: db $BE;X
L097FB4: db $EA;X
L097FB5: db $EE;X
L097FB6: db $AA;X
L097FB7: db $AA;X
L097FB8: db $AA;X
L097FB9: db $AA;X
L097FBA: db $EA;X
L097FBB: db $BA;X
L097FBC: db $BE;X
L097FBD: db $EA;X
L097FBE: db $EA;X
L097FBF: db $BA;X
L097FC0: db $AA;X
L097FC1: db $BE;X
L097FC2: db $AA;X
L097FC3: db $AE;X
L097FC4: db $AE;X
L097FC5: db $BA;X
L097FC6: db $AF;X
L097FC7: db $FA;X
L097FC8: db $EF;X
L097FC9: db $EE;X
L097FCA: db $AA;X
L097FCB: db $AA;X
L097FCC: db $AA;X
L097FCD: db $EA;X
L097FCE: db $AA;X
L097FCF: db $BA;X
L097FD0: db $AB;X
L097FD1: db $AE;X
L097FD2: db $AA;X
L097FD3: db $BE;X
L097FD4: db $AF;X
L097FD5: db $AE;X
L097FD6: db $AF;X
L097FD7: db $FF;X
L097FD8: db $BB;X
L097FD9: db $AB;X
L097FDA: db $EA;X
L097FDB: db $BA;X
L097FDC: db $AE;X
L097FDD: db $BA;X
L097FDE: db $AA;X
L097FDF: db $AF;X
L097FE0: db $EA;X
L097FE1: db $AF;X
L097FE2: db $AF;X
L097FE3: db $EA;X
L097FE4: db $EE;X
L097FE5: db $FE;X
L097FE6: db $AA;X
L097FE7: db $AE;X
L097FE8: db $EA;X
L097FE9: db $BA;X
L097FEA: db $EA;X
L097FEB: db $AA;X
L097FEC: db $AB;X
L097FED: db $AA;X
L097FEE: db $AB;X
L097FEF: db $FA;X
L097FF0: db $AA;X
L097FF1: db $AE;X
L097FF2: db $FE;X
L097FF3: db $BA;X
L097FF4: db $AA;X
L097FF5: db $AA;X
L097FF6: db $EE;X
L097FF7: db $AF;X
L097FF8: db $EE;X
L097FF9: db $AA;X
L097FFA: db $AA;X
L097FFB: db $FA;X
L097FFC: db $AA;X
L097FFD: db $EB;X
L097FFE: db $AE;X
L097FFF: db $AE;X
