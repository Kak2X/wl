;
; BANK 04 - Sound Engine
; 

; Trampoline stub area
; [POI] This appears to exist to facilitate the reuse of the sound engine across games.
;       For example, in Metroid II, Sound_Init doesn't come immediately after Sound_InitStub,
;       but these stubs keep this exact position.
Sound_DoStub:
	jp   Sound_Do
Sound_StopAllStub:
	jp   Sound_StopAll
Sound_InitStub:
	jp   Sound_Init

; =============== Sound_Init ===============
; Initializes the sound hardware
Sound_Init:
	ld   a, SNDCTRL_ON		; Enable sound hardware
	ldh  [rNR52], a
	ld   a, %1110111		; Set max volume for both left/right speakers
	ldh  [rNR50], a
	ld   a, SNDOUT_CHALL	; Enable all channels in left/right speakers
	ldh  [rNR51], a
	
; Clear the memory range at sSFX1Set-$A6FF
; This, as expected, is the sound memory.
	ld   hl, sSFX1Set			; HL = Starting address
.loop:
	ld   [hl], $00			; Overwrite byte
	inc  hl					; next byte
	ld   a, h
	cp   a, $A7				; Have we reached $A700 yet?
	jr   nz, .loop			; If not, loop
	ret

; =============== Sound_StopAll ===============
; Stops all currently playing sound effects and music without disabling the entire sound playback.
Sound_StopAll:
	
	ld   a, SNDOUT_CHALL ; Enable every sound channel
	ldh  [rNR51], a
	; Reset all memory related to the currently played music / SFX
	xor  a
	ld   [sSFX1Set], a
	ld   [sSFX2Set], a
	ld   [sSFX3Set], a 	; [TCRF] SFX3 isn't used in any way, and it's empty.
						; There isn't even code to update the SFX when this changes, unlike the others.
	ld   [sSFX4Set], a
	ld   [sSFX1], a
	ld   [sSFX2], a
	ld   [sSFX3], a
	ld   [sSFX4], a
	
	ld   a, BGM_NONE
	ld   [sBGMSet], a
	ld   [sBGM], a
	xor  a
	ld   [sBGMActSet], a
	ld   [sBGMAct], a
	ld   [sSndPauseTimer], a
	ld   [sSndPauseActSet], a
	
; To clear the currently played sounds from the registers (for this frame, unless playback is also stopped)
Sound_StopAllRegs:
	; Set volume envelope
	ld   a, %00001000
	ldh  [rNR12], a
	ldh  [rNR22], a
	ldh  [rNR42], a
	; Set channel frequency
	ld   a, %10000000 ; restart
	ldh  [rNR14], a
	ldh  [rNR24], a
	ldh  [rNR44], a
	; Set sweep
	xor  a
	ldh  [rNR10], a
	ldh  [rNR30], a
	ret
	
; =============== Sound_Do ===============
; Entry point of the main sound code.
Sound_Do:
	ld   a, [sDemoFlag]		; Are we in demo mode?
	and  a
	jp   nz, Sound_StopAll	; If so, stop and ignore all sound processing.
	
	; Check if there are any *newly requested* pause/unpause commands
	ld   a, [sSndPauseActSet]
	cp   a, SNDPAUSE_PAUSE
	jp   z, Sound_StartPause
	cp   a, SNDPAUSE_PAUSE | SNDPAUSE_NOPAUSESFX
	jp   z, Sound_StartPause
	cp   a, SNDPAUSE_UNPAUSE
	jp   z, Sound_StartUnpause
	cp   a, SNDPAUSE_UNPAUSE | SNDPAUSE_NOPAUSESFX
	jp   z, Sound_StartUnpause
	
	; Check if the standard sound pause (during gameplay, but in theory anywhere else) is active.
	; If so, we need to handle its timing.
	ld   a, [sSndPauseTimer] 			; Is there any active pause commands?
	and  a
	jp   nz, Sound_DoGamePause	; If so, jump
	
; =============== Sound_DoMain ===============	
; Handles sound when BGM and SFX playback is enabled.
; This is the normal code path.
Sound_DoMain:
	; Check if any new or existing fade out is set
	ld   a, [sBGMActSet]
	and  a					; Any fade out requested?
	jr   z, .noSetCmd		; If not, check for an existing one.
	;--
	; BGM Actions list -- init
	cp   a, BGMACT_FADEOUT
	jp   z, .startFadeOut
	;--
.noSetCmd:
	ld   a, [sBGMAct]		; Any existing fade out to continue?
	and  a					
	jr   z, .main			; If not, continue nornally
	;--
	; BGM Actions list -- existing
	cp   a, BGMACT_FADEOUT
	jp   z, .fadeOut
	;--
.main:
	; Process BGM first, then all sound effects
	; This order makes sure SFX can override BGM but not vice versa.
	call Sound_DoBGM ; Also means BGM handling can stop all registers without caring about SFX
	call Sound_DoSFX4
	call Sound_DoSFX1
	call Sound_DoSFX2
	; Invalidate sound playback requests
	xor  a
	ld   [sSFX1Set], a
	ld   [sSFX2Set], a
	ld   [sSFX3Set], a
	ld   [sSFX4Set], a
	ld   [sSndPauseActSet], a
	ld   [sBGMActSet], a
	ld   [sBGMSet], a
	ret
	
; ==
; Sound fade out code
.startFadeOut:
	; Fade out initialization
	ld   [sBGMAct], a ; Copy action byte over
	call Sound_ResetFadeOutTimer
	xor  a
	ld   [sBGMCh4On], a		; Channel 4 isn't faded out -- kill channel immediately
	jr   .checkFadeOutCh1	; Fade out CH1 by one level to have an immediate effect
.fadeOut:
	; Main fade out code handler.
	
	; The fade out speed depends on the decrementing.
	; If the timer hasn't reached 0, we leave the volume as-is and continue normally.
	ld   a, [sFadeOutTimer]
	dec  a
	ld   [sFadeOutTimer], a
	jp   nz, .main
	call Sound_ResetFadeOutTimer
	;--
	
; Progressively fade out the volume of all sound channels
; Each iteration will reduce the volume by $10 for all channels.
; This can't be done with Ch4 (noise) so that will be left as-is.
.checkFadeOutCh1: 
	ld   a, [sBGMCh1Vol]			
	and  a						; Is Ch1 fully faded out?
	jr   z, .checkFadeOutCh2	; If so, jump
	;--
	call Sound_DecChVol
	ld   [sBGMCh1Vol], a
.checkFadeOutCh2:
	ld   a, [sBGMCh2Vol]
	and  a						; Is Ch2 fully faded out?
	jr   z, .checkFadeOutCh3	; If so, jump
	;--
	call Sound_DecChVol
	ld   [sBGMCh2Vol], a
.checkFadeOutCh3:
	ld   a, [sBGMCh3Vol]			
	and  a						; Is Ch3 fully faded out?
	jr   z, .endFadeOut			; If so, jump
;--
; Channel 3 fade out
; This fade out works differently -- instead of removing $10 from the volume,
; it will switch to predetermined values:
; $20 -> $40 -> $60 -> 0
	cp   a, $20					
	jr   nz, .check40
	ld   a, $40			; 1			
	jr   .setCh3
.check40:
	cp   a, $40
	jr   nz, .clearCh3
	ld   a, $60			; 2
	jr   .setCh3
.clearCh3:
	xor  a				; 3
.setCh3:
	ld   [sBGMCh3Vol], a
;--
.endFadeOut:
	; Continue only if the volume for all channels is 0
	; This doesn't happen very often as you'd think
	ld   a, [sBGMCh1Vol]
	and  a
	jp   nz, .main
	ld   a, [sBGMCh2Vol]
	and  a
	jp   nz, .main
	ld   a, [sBGMCh3Vol]
	and  a
	jp   nz, .main
	; Completely stop BGM playback
	xor  a
	ld   [sBGM], a
	ld   [sBGMAct], a
	ld   [sBGMActSet], a
	jp   Sound_StopChannels ; Sound_StopChannels
; =============== Sound_DecChVol ===============
; Decrements the channel volume by $10, without underflowing it.
; IN
; - A: Sound channel volume
Sound_DecChVol:
	sub  a, $10
	ret  nc
	xor  a
	ret
; =============== Sound_ResetFadeOutTimer ===============	
; Sets the fade out timer to the initial value.
; This should be done when it reaches 0.
Sound_ResetFadeOutTimer:
	ld   a, $08
	ld   [sFadeOutTimer], a
	ret
; =============== Sound_DoSFX1 ===============
; Entry point for handling SFX1.
; These make use sound channel 1.
Sound_DoSFX1:
	ld   a, [sSFX1Set]			
	and  a							; Is there any newly requested SFX1?
	jr   z, Sound_DoCurrentSFX1		; If not, jump
	
	cp   a, SFX_NONE				; Is this the magic mute value?
	jp   z, Sound_StopSFX1Stub		; If so, jump
	cp   a, $34						; Is this an invalid SFX4 request? (val >= $34)
	jr   nc, Sound_DoCurrentSFX1	; If so, ignore and continue playing the current SFX
	
	;--
	; Handle SFX priority
	; This follows these rules:
	; - sSFX1Set replace the current SFX...
	; - ...unless the current sSFX1 is one which does not allow to be interrupted (hardcoded)
	
	ld   a, [sSFX1]					; Is another SFX1 already playing?					
	and  a
	jr   z, .setNew					; If not, jump
	
	; These SFX have to play regardless of priority
	ld   a, [sSFX1Set]
	cp   a, SFX1_09
	jr   z, .setNew
	cp   a, SFX1_2C
	jr   z, .setNew
	cp   a, SFX1_2A
	jr   z, .setNew
	cp   a, SFX1_2B
	jr   z, .setNew
	cp   a, SFX1_06
	jr   z, .setNew
	cp   a, SFX1_25
	jr   z, .setNew
	cp   a, SFX1_08
	jr   z, .setNew
	cp   a, SFX1_04
	jr   z, .setNew
	cp   a, SFX1_24
	jr   z, .setNew
	cp   a, SFX1_26
	jr   z, .setNew
	cp   a, SFX1_10
	jr   z, .setNew
	
	; If the requested SFX was not in the previous list, it has low priority
	; This means it should not play if any of these SFX is currently playing:
	ld   a, [sSFX1]
	cp   a, $09
	jr   z, Sound_DoCurrentSFX1
	cp   a, $2C
	jr   z, Sound_DoCurrentSFX1
	cp   a, $2B
	jr   z, Sound_DoCurrentSFX1
	cp   a, $2A
	jr   z, Sound_DoCurrentSFX1
	cp   a, $24
	jr   z, Sound_DoCurrentSFX1
	cp   a, $26
	jr   z, Sound_DoCurrentSFX1
	jr   .setNew
	
.setNew:
	ld   a, [sSFX1Set]
	ld   [sSFX1SetLast], a				; [TCRF] This doesn't appear to be read anywhere
	ld   hl, Sound_SFX1PtrTable
	call Sound_IndexPtrTable
	jp   hl
; =============== Sound_DoCurrentSFX1 ===============
; Handles the currently playing SFX1.
Sound_DoCurrentSFX1:
	ld   a, [sSFX1] 		; Is SFX1 currently playing?
	and  a
	ret  z					; If not, return
	cp   a, $34				; Are we trying to play a valid SFX1?
	jr   nc, .invalid		; If not, stop the playback
	;--
	ld   hl, Sound_SFX1NextPtrTable
	call Sound_IndexPtrTable
	jp   hl
	; [TCRF] Handler for invalid SFX1 requests.
.invalid:
	xor  a
	ld  [sSFX1], a
	ret
	
; =============== Sound_DoSFX2 ===============
; Entry point for handling SFX2.
; These make use sound channel 2.
Sound_DoSFX2:
	ld   a, [sSFX2Set]
	and  a							; Is there any newly requested SFX1?
	jr   z, Sound_DoCurrentSFX2		; If not, jump
	
	cp   a, SFX_NONE				; Is this the magic mute value?
	jp   z, Sound_StopSFX2Stub		; If so, jump
	cp   a, $07						; Is this an invalid SFX2 request? (val >= $07)
	jr   nc, Sound_DoCurrentSFX2	; If so, ignore and continue playing the current SFX
	;--
	ld   hl, Sound_SFX2PtrTable
	call Sound_IndexPtrTable
	jp   hl
; =============== Sound_DoCurrentSFX2 ===============
; Handles the currently playing SFX2.
Sound_DoCurrentSFX2:;R
	ld   a, [sSFX2]					
	and  a							; Is SFX2 currently playing?
	ret  z							; If not, return
	cp   a, $07						; Are we trying to play a valid SFX2?
	jr   nc, .invalid				; If not, stop the playback
	;--
	ld   hl, Sound_SFX2NextPtrTable
	call Sound_IndexPtrTable
	jp   hl
	; [TCRF] Handler for invalid SFX2 requests.
.invalid:
	xor  a
	ld  [sSFX2], a
	ret
	
; =============== Sound_DoSFX4 ===============
; Entry point for handling SFX4.
; These make use of the noise channel, and will mute the BGM Ch4 while playing.
Sound_DoSFX4:
	ld   a, [sSFX4Set]	
	and  a							; Is there any SFX4 set?
	jr   z, Sound_DoCurrentSFX4		; If not, branch
	
	cp   a, SFX_NONE				; Is this the magic mute value?
	jp   z, Sound_StopSFX4Stub		; If so, jump
	cp   a, $1C						; Is this an invalid SFX4 request? (val >= $1C)
	jr   nc, Sound_DoCurrentSFX4	; If so, ignore and continue playing the current SFX
	;--
	ld   a, [sSFX4Set]
	ld   hl, Sound_SFX4PtrTable
	call Sound_IndexPtrTable
	jp   hl
	; [TCRF] Unreachable code.
	; This is not necessary, as it's done automatically by Sound_DoMain.
	xor  a
	ld   [sSFX4Set], a
	ret
; =============== Sound_DoCurrentSFX4 ===============
; Handles the currently playing SFX4.
Sound_DoCurrentSFX4:
	ld   a, [sSFX4]		; Is there an existing SFX4?
	and  a
	ret  z				; If not, return
.handle
	cp   a, $1C			; Are we trying to play an invalid SFX? (>= last valid one + 1)
	jr   nc, .invalid	; If so, jump
	ld   hl, Sound_SFX4NextPtrTable
	call Sound_IndexPtrTable
	jp   hl
	; [TCRF] Handler for invalid SFX4 requests.
.invalid:
	xor  a
IF FIX_BUGS == 1
	ld  [sSFX4], a ; [BUG] should have been sSFX4 instead
ELSE
	ld  [$420B], a ; [BUG] should have been sSFX4 instead
ENDC
	ret
	
; =============== Sound_UseHurryUp ===============
; Sets the BGM options for the hurry up version of the requested track.
; As a result, this should only be used when starting a new track.
;
Sound_UseHurryUp:
	; Hurry up variations always have an higher pitch
	ld   a, [sBGMPitch]		
	add  $02
	ld   [sBGMPitch], a
	ld   [sBGMPitchOrig], a
	;--
	push hl
	; Find the pointer to the sound length table to use.
	; We don't need to index the table; just the ptr for the current BGMId
	; HL = *(Sound_BGMHurryUpLenPtrTable[sBGMSet - 1])
	
	; BGMSet to BGMId
	ld   a, [sBGMSet]		; A = BGMSet - 1
	dec  a
	; Get ptr. table offset
	add  a					; DE = BGMId*2
	ld   e, a
	ld   d, $00
	; Index the ptr table
	ld   hl, Sound_BGMHurryUpLenPtrTable
	add  hl, de
	;--
	; Replace the BGM length ptr
	ldi  a, [hl]
	ld   [sBGMLenPtr+1], a
	ldi  a, [hl]
	ld   [sBGMLenPtr], a
	pop  hl
	;--
	ret
; =============== Sound_DoBGM ===============
; Entry point for handling BGM.
Sound_DoBGM:
	ld   a, [sBGMSet]				; Is there any new BGM requested?
	and  a
	jr   z, Sound_DoCurrentBGM		; If not, continue with the current BGM.
	;--
	
	; Check for the special value to stop BGM playback
	cp   a, BGM_NONE
	jr   z, Sound_StopChannels
	
	ld   [sBGM], a	; Copy over the BGM Value
	;--
	; Set the actual BGMId to DE
	dec  a			; But remember this is offset by 1 compared to the BGM ID
					; because sBGMSet $00 marks "no change"
	ld   e, a
	ld   d, $00		
	;--
	; Offset the stereo panning table
	ld   hl, BGM_PanningTable	; HL = Base address for panning table
	add  hl, de
	; Set the stereo panning for this BGM
	ld   a, [hl]
	ld   [sBGMNR51], a
	ldh  [rNR51], a
	;--
	; Index the BGM header we need from the ptr table
	ld   a, [sBGMSet]			
	ld   hl, BGMHeader_PtrTable
	call Sound_IndexPtrTable
	; Parse the header and prepare sound data
	jp   Sound_ParseBGMHeader			
; =============== Sound_StopChannels ===============
; Does essentially the same thing as Sound_StopAllRegs
; Except here, for good measure, all BGM channels get also muted.
Sound_StopChannels:
	; Mute all BGM channels
	xor  a
	ld   [sBGMCh1On], a
	ld   [sBGMCh2On], a
	ld   [sBGMCh3On], a
	ld   [sBGMCh4On], a
	; Calling the one after the other is essentially identical to calling Sound_StopAllRegs
	; except this won't touch rNR10, but it doesn't even matter as the channel gets disabled
	; jp Sound_StopAllRegs
	call Sound_StopCh1Regs
	call Sound_StopCh2Regs
	call Sound_StopCh3Regs
	jp   Sound_StopCh4Regs
	
; =============== Sound_Unused_StopBGM ===============
; [TCRF] Unreferenced subroutine.
; Stops music playback in an "unsafe" way.
; You're meant to set sBGMSet to BGM_NONE to stop music playback normally.
Sound_Unused_StopBGM:
	xor  a
	ld   [sBGM], a
	ret
	
; =============== Sound_DoCurrentBGM ===============
; Handles the currently playing BGM.
Sound_DoCurrentBGM:
	; Stop if nothing's playing
	ld   a, [sBGM]
	and  a
	ret  z
	
; Channel handling
; Generally, sound registers for a channel will remain untouched until its respective "length left" value becomes 1.
; The channel can still be muted by sound effects while this happens.
Sound_DoCurrentBGM_Ch1:
	xor  a							; Reset extra register marker
	ld   [sBGMCurChRegType], a
	
	ld   a, [sBGMCh1On]				; Is the BGM sound channel enabled?
	and  a
	jr   z, Sound_DoCurrentBGM_Ch2	; If not, skip to channel 2
	
	ld   a, $01						; Mark channel 1 as being currently processed
	ld   [sBGMCurProc], a
	;--
	ld   a, [sBGMCh1Len]			; Copy over
	ld   [sBGMCurChLen], a
	cp   a, $01						; Are there any frames left of playback with these settings?
	jp   z, Sound_SetBGMCh1			; If not (well, if 1 frame is left), set the new data
	dec  a							; FramesLeft--;
	ld   [sBGMCh1Len], a
	;--
	ld   a, [sBGMChSFX1]			; Is there SFX playing which should mute the channel?
	and  a
	jr   nz, Sound_DoCurrentBGM_Ch2	; If so, skip to channel 2
	
	;--
	; Handle any pitch change commands
	ld   a, [sBGMCh1PitchCmd]			
	ld   [sBGMCurChPitchCmd], a	
	and  a							; Is there any command requested?
	jr   z, Sound_DoCurrentBGM_Ch2	; If not, skip to ch2
									; [TCRF] This is never called for channel 1!
	ld   a, [sBGMNR13]				; BC = Ch1 frequency
	ld   c, a
	ld   a, [sBGMNR14]
	ld   b, a
	call Sound_DoBGMPitchCmd
	
	ld   a, [sBGMCurChReg3]			; Copy the modified frequency back
	ldh  [rNR13], a
	ld   a, [sBGMCurChReg4]
	ldh  [rNR14], a
	;--
Sound_DoCurrentBGM_Ch2:
	xor  a							; Reset extra register marker
	ld   [sBGMCurChRegType], a
	
	ld   a, [sBGMCh2On]				; Is the BGM sound channel enabled?
	and  a
	jr   z, Sound_DoCurrentBGM_Ch3	; If not, skip to channel 3
	
	ld   a, $02						; Mark channel 3 as being currently processed
	ld   [sBGMCurProc], a
	;--
	ld   a, [sBGMCh2Len]			; Copy over
	ld   [sBGMCurChLen], a
	cp   a, $01						; Are there any frames left of playback with these sound settings?
	jp   z, Sound_SetBGMCh2			; If not (well, if 1 frame is left), set the new data
	dec  a							; FramesLeft--
	ld   [sBGMCh2Len], a
	;--
	ld   a, [sBGMChSFX2]			; Is there SFX playing which should mute the channel?
	and  a
	jr   nz, Sound_DoCurrentBGM_Ch3 ; If so, skip to channel 3
	
	;--
	; Handle any pitch change commands
	ld   a, [sBGMCh2PitchCmd]
	ld   [sBGMCurChPitchCmd], a
	and  a							; Is there any command requested?
	jr   z, Sound_DoCurrentBGM_Ch3	; If not, skip to ch3
	
	ld   a, [sBGMNR23]				; BC = Ch2 frequency
	ld   c, a
	ld   a, [sBGMNR24]
	ld   b, a
	call Sound_DoBGMPitchCmd
	
	ld   a, [sBGMCurChReg3]			; Copy the modified frequency back
	ldh  [rNR23], a
	ld   a, [sBGMCurChReg4]
	ldh  [rNR24], a
	;--
Sound_DoCurrentBGM_Ch3:
	xor  a							; Reset extra register marker
	ld   [sBGMCurChRegType], a
	
	ld   a, [sBGMCh3On]				; Is the BGM sound channel enabled?
	and  a
	jr   z, Sound_DoCurrentBGM_Ch4	; If not, skip to channel 4
	
	ld   a, $03						; Mark channel 3 as being currently processed
	ld   [sBGMCurProc], a
	;--
	ld   a, [sBGMCh3Len]			; Copy over
	ld   [sBGMCurChLen], a			
	cp   a, $01						; Are there any frames left of playback with these sound settings?
	jp   z, Sound_SetBGMCh3			; If not (well, if 1 frame is left), set the new data
	dec  a							; FramesLeft--
	ld   [sBGMCh3Len], a
	;--
	ld   a, [sBGMChSFX3]			; Is there SFX playing which should mute the channel?
	and  a
	jr   nz, Sound_DoCurrentBGM_Ch4	; If so, skip to channel 3
	
	;--
	; Handle any pitch change commands
	ld   a, [sBGMCh3PitchCmd]
	ld   [sBGMCurChPitchCmd], a
	and  a							; Is there any command requested?
	jr   z, Sound_DoCurrentBGM_Ch4	; If not, skip to ch4
	
	ld   a, [sBGMNR33]				; BC = Ch3 frequency
	ld   c, a
	ld   a, [sBGMNR34]
	ld   b, a
	call Sound_DoBGMPitchCmd
	
	ld   a, [sBGMCurChReg3]			; Copy the modified frequency back
	ldh  [rNR33], a
	ld   a, [sBGMCurChReg4]
	res  7, a
	ldh  [rNR34], a
	;--
Sound_DoCurrentBGM_Ch4:
	xor  a								; Reset extra register marker
	ld   [sBGMCurChRegType], a
	
	ld   a, [sBGMCh4On]					; Is the BGM sound channel enabled?
	and  a
	jr   z, Sound_StopBGMOnAllMutedCh	; If not, skip
	
	ld   a, $04							; Mark channel 4 as being currently processed
	ld   [sBGMCurProc], a
	
	ld   a, [sBGMCh4Len]				; Copy over
	ld   [sBGMCurChLen], a				
	cp   a, $01							; Are there any frames left of playback with these sound settings?
	jp   z, Sound_SetBGMCh4				; If not (well, if 1 frame is left), set the new data
	dec  a								; FramesLeft--
	ld   [sBGMCh4Len], a
	ret
; =============== Sound_StopBGMOnAllMutedCh ===============
; This subroutines silences BGM entirely if all BGM sound channels are muted.
Sound_StopBGMOnAllMutedCh:
	ld   a, [sBGMCh1On]
	and  a
	ret  nz
	ld   a, [sBGMCh2On]
	and  a
	ret  nz
	ld   a, [sBGMCh3On]
	and  a
	ret  nz
	ld   a, [sBGMCh4On]
	and  a
	ret  nz
	xor  a
	ld   [sBGM], a
	ld   [sBGMAct], a
	ret
; =============== Sound_IndexPtrTable ===============
; Indexes a generic pointer table with the specified ID.
; IN
; -  A: BGM/SFX Id. 
;       This is expected to come from a BGMSet or SFX?Set variable, which is offset by 1.
; - HL: Ptr to the table indexed with the above
; OUT
; - HL: A pointer (result from HL[A])
Sound_IndexPtrTable:
	dec  a			; Offset the id correctly
	add  a			;
	ld   b, $00		; BC = A*2 (table offset)
	ld   c, a
	add  hl, bc		; Offset the index table
	ld   c, [hl]	; Temporarily store the value to CB
	inc  hl
	ld   b, [hl]
	ld   l, c		; And then copy it to the intended HL register
	ld   h, b
	ret
; =============== Sound_DoSFX1Timer ===============
; Elapses the SFX1 timer (decrementing it by 1).
; This should be done once per frame.
;
; If there aren't any frames of playback left, the sound channel will be stopped.
; Subroutines for SFX2 and SFX4 are also present.
Sound_DoSFX1Timer:
	ld   a, [sSFX1Len]	
	and  a
	jr   z, Sound_StopSFX1Stub
	dec  a
	ld   [sSFX1Len], a
	ret
Sound_StopSFX1Stub:
	jr   Sound_StopSFX1
; =============== Sound_DoSFX2Timer ===============
Sound_DoSFX2Timer:
	ld   a, [sSFX2Len]
	and  a
	jr   z, Sound_StopSFX2Stub
	dec  a
	ld   [sSFX2Len], a
	ret
Sound_StopSFX2Stub:
	jr   Sound_StopSFX2
; =============== Sound_DoSFX4Timer ===============
Sound_DoSFX4Timer:
	ld   a, [sSFX4Len]
	and  a
	jr   z, Sound_StopSFX4Stub
	dec  a
	ld   [sSFX4Len], a
	ret
Sound_StopSFX4Stub:
	jr   Sound_StopSFX4
; =============== Sound_Unused_DoStopAllTimer ===============
; [TCRF] Unreferenced code.
;
; This is done in a similar style to the DoSFX?Timer subroutines,
; except if it elapses, all sound playback is stopped.
; Additionally, this one does not have a specific memory address for the timer.
; IN
; - A: Number of frames left
; OUT
; - A: Updated number of frames left
Sound_Unused_DoStopAllTimer:
	and  a
	jp   z, Sound_StopAll
	dec  a
	ret

; =============== Sound_StopSFX1 ===============
; Called when stopping SFX1 playback.
; This makes sure to resume BGM ch1 and stop anything in the registers
; Equivalent subroutines exist for all channels.
;
Sound_StopSFX1:
	xor  a
	ld   [sSFX1], a			; Stop SFX
	ld   [sBGMChSFX1], a	; Unmark mute flag
Sound_StopCh1Regs:
	ld   a, %00001000		; Reset regs
	ldh  [rNR12], a
	ld   a, %10000000
	ldh  [rNR14], a
	xor  a
	ret
; =============== Sound_StopSFX2 ===============
Sound_StopSFX2:;R
	xor  a
	ld   [sSFX2], a
	ld   [sBGMChSFX2], a
Sound_StopCh2Regs:;C
	ld   a, %00001000
	ldh  [rNR22], a
	ld   a, %10000000
	ldh  [rNR24], a
	xor  a
	ret
; =============== Sound_Unused_StopSFX3 ===============
Sound_Unused_StopSFX3: ; [TCRF] Unused, as there's no SFX3
	xor  a
	ld   [sBGMChSFX3], a
Sound_StopCh3Regs:
	xor  a
	ldh  [rNR30], a
	xor  a
	ret
; =============== Sound_StopSFX4 ===============
Sound_StopSFX4:
	xor  a
	ld   [sSFX4], a
	ld   [sBGMChSFX4], a
Sound_StopCh4Regs:;J
	ld   a, %00001000
	ldh  [rNR42], a
	ld   a, %10000000
	ldh  [rNR44], a
	xor  a
	ret
	
; =============== Sound_ClearSfxSet ===============
; Clears the status of all SfxSet values.
; This needs to be done every frame to avoid (re)starting SFX play commands.
Sound_ClearSfxSet:
	xor  a
	ld   [sSFX1Set], a
	ld   [sSFX2Set], a
	ld   [sSFX3Set], a
	ld   [sSFX4Set], a
	ld   [sSndPauseActSet], a
	ret
; =============== Sound_CopyWavePattern ===============
; Copies a wave pattern to the sound register area.
; IN
; - DE: Wave data
Sound_CopyWavePattern:
	push bc
	push de
	;--
	ld   c, LOW(rWave)		; C = Starting address ($FF30)
.loop:;R
	; Copy the byte over
	ld   a, [de]			
	ld   [c], a				
	inc  de					
	inc  c
	
	ld   a, c				
	cp   a, LOW(rWave)+$10	; Have we reached the end of the Wave Pattern RAM? 
	jr   nz, .loop			; If not, loop
	;--
	pop  de
	pop  bc
	ret
	
; =============== mSound_SetCh ===============
; Generates code to call Sound_SetCh.
; This should be used to force update all sound registers for a specific channel.
; For SFX only.
; IN
; -  1: Ptr to first hardware register (destination 1)
; -  2: Ptr to SRAM mirror of the above (destination 2)
; -  3: Registers for the sound channel (bytes to copy)
; - DE: Ptr to sound data, in the register order. (source data)
mSound_SetCh: MACRO
	push hl
	ld   hl, \1	; HL = Ptr to first reg
	ld   bc, \2	; BC = Ptr to first sound register copy for SFX
	ld   a, \3	; Bytes to copy
	ld   [sNRSize], a
	jr   Sound_SetCh
ENDM

;                             TO    FROM     Reg.Count
Sound_SetSFXCh1: mSound_SetCh rNR10,sSFXNR10,$05
Sound_SetSFXCh2: mSound_SetCh rNR21,sSFXNR21,$04
Sound_SetSFXCh3: mSound_SetCh rNR30,sSFXNR30,$05 ; [TCRF] No SFX3, so nothing calls it
Sound_SetSFXCh4: mSound_SetCh rNR41,sSFXNR41,$04
	
; =============== Sound_SetCh ===============
; Updates all the registers for the specified channel with the provided data.
;
; Note that before calling this you are expected to manually
; push HL to stack.

; IN:
; - HL: Ptr to first sound register of a channel
; - BC: Ptr to the SRAM copy of the above
; - DE: Ptr to channel data
; - sNRSize: Data size (depends on how many registers a channel has)
Sound_SetCh:
	ld   a, [de]			; Get snd data byte
	ldi  [hl], a			; Copy it over to the register
	ld   [bc], a			; and the SRAM mirror
	inc  de					; Ptr++
	inc  bc
	
	ld   a, [sNRSize]		; BytesLeft--
	dec  a
	ld   [sNRSize], a
	jr   nz, Sound_SetCh	; Copy next if we haven't finished
	;--
	pop  hl
	ret
; =============== Sound_StartPause ===============
; This subroutine handles the sound at the beginning of a game pause.
Sound_StartPause:
	; For debug mode
	ld   a, [sHurryUp]
	ld   [sHurryUpOrig], a
	
	; Stop all currently playing SFX
	call Sound_StopAllRegs
	xor  a
	ld   [sSFX1], a
	ld   [sSFX2], a
	ld   [sSFX3], a
	ld   [sSFX4], a
	
	; Initialize the sound timer
	ld   a, $40
	ld   [sSndPauseTimer], a
	
	; Check for the flag SNDPAUSE_NOPAUSESFX
	; If set, the sound played at the start of a pause will be skipped.
	ld   a, [sSndPauseActSet]
	bit  SNDPAUSEB_NOPAUSESFX, a
	ret  nz
	
; ==============================
Sound_DoPauseSnd0:
	ld   de, SFX_Pause0

; =============== Sound_SetSFXCh4Only ===============
; Sets the sound data for channel 4.
; All other SFX play requests will be canceled.
Sound_SetSFXCh4Only:
	call Sound_SetSFXCh4
	jp   Sound_ClearSfxSet
	
; ==============================
Sound_DoPauseSnd2:
	ld   de, SFX_Pause2
	jr   Sound_SetSFXCh4Only
Sound_DoPauseSnd4:
	ld   de, SFX_Pause4
	jr   Sound_SetSFXCh4Only
Sound_DoPauseSnd6:
	ld   de, SFX_Pause6
	jr   Sound_SetSFXCh4Only
Sound_DoPauseSnd1:
	ld   de, SFX_Pause1
	
; =============== Sound_SetSFXCh1Only ===============
; Sets the sound data for channel 1.
; All other SFX play requests will be canceled.
Sound_SetSFXCh1Only:
	call Sound_SetSFXCh1
	jp   Sound_ClearSfxSet
Sound_DoPauseSnd3:
	ld   de, SFX_Pause3
	jr   Sound_SetSFXCh1Only
Sound_DoPauseSnd5:
	ld   de, SFX_Pause5
	jr   Sound_SetSFXCh1Only
Sound_DoPauseSnd7:
	ld   de, SFX_Pause7
	jr   Sound_SetSFXCh1Only
; =============== Sound_StartUnpause ===============
; Handles the sound during the pause sequence.
;
Sound_StartUnpause:
	xor  a							; Clear pause timer
	ld   [sSndPauseTimer], a
	; For debug mode
	;--
	; Avoid restarting the invincibility music
	ld   a, [sBGM]					
	cp   a, BGM_INVINCIBILE						
	jr   z, .noReset	
	
	; Detect if the hurry up status was changed in debug mode.
	; This works because editing the time in debug mode and crossing over the 100 second mark
	; will change the sHurryUp value.
	; (this is the only way it can change while the game is paused)
	ld   a, [sHurryUp]		; B = HurryUp
	ld   b, a
	ld   a, [sHurryUpOrig]	; A = Copy Flag
	cp   a, b				; Are they different?
	jr   z, .noReset		; If not, don't reset the music
	call Sound_RestartBGM
	;--
.noReset:
	; Check for the flag SNDPAUSE_NOPAUSESFX
	; If set, the sound played at the start of an unpause will be skipped.
	ld   a, [sSndPauseActSet]		
	bit  SNDPAUSEB_NOPAUSESFX, a
	jp   nz, Sound_DoMain
	ld   a, SFX1_1E
	ld   [sSFX1Set], a
	jp   Sound_DoMain
	
; =============== Sound_DoGamePause ===============
; Handles the sound during the pause sequence.
; This does *not* return back to the main playback code, so normal SFX won't be processed.
;
Sound_DoGamePause:
	; Timer starts at $40
	ld   hl, sSndPauseTimer ; Timer--;
	dec  [hl]
	
	; Pause & unpause timing script.
	
	;--
	; The pause sound is handled similarly to some other SFX.
	; At specific timer values, specific bytes are copied to the set of registers of a single sound channel.
	;
	; However, this one isn't part of a normal SFX set, so it can (and does) use multiple channels
	; over the course of the playback.
	ld   a, [hl]			
	cp   a, $3F
	jr   z, Sound_DoPauseSnd1
	cp   a, $3D
	jr   z, Sound_DoPauseSnd2
	cp   a, $3A
	jr   z, Sound_DoPauseSnd3
	cp   a, $32
	jr   z, Sound_DoPauseSnd4
	cp   a, $2F
	jr   z, Sound_DoPauseSnd5
	cp   a, $27
	jr   z, Sound_DoPauseSnd6
	cp   a, $24
	jr   z, Sound_DoPauseSnd7
	; If we reached $10, prevent the value from decreasing further
	; This means the value will stay at $11 and the music will remain paused
	cp   a, $10
	jp   nz, Sound_ClearSfxSet
	inc  [hl]
	jp   Sound_ClearSfxSet
	
; =============== Sound_RestartBGM ===============
; Restarts the currently playing track.
Sound_RestartBGM:
	ld   a, [sBGM]
	ld   [sBGMSet], a
	ret
	

SFX_Pause:
;INCLUDE "data/sfx/pause.asm";
SFX_Pause0:
	db $00
	db $87
	db $31
	db $80
SFX_Pause2:
	db $00
	db $83
	db $5D
	db $80
SFX_Pause1:
	db $1D
	db $80
	db $F7
	db $C0
	db $87
SFX_Pause3:
	db $1D
	db $80
	db $C7
	db $D0
	db $87
SFX_Pause4:
	db $00
	db $53
	db $5C
	db $80
SFX_Pause5:
	db $1D
	db $80
	db $77
	db $D5
	db $87
SFX_Pause6:
	db $00
	db $36
	db $5B
	db $80
SFX_Pause7:
	db $1D
	db $80
	db $47
	db $D9
	db $87

; =============== Sound_SFX1SetEnv ===============
; Sets a new envelope for the currently playing SFX1.
; Meant to be called by SFX1 code.
; IN:
; - A: Envelope option
Sound_SFX1SetEnv:
	ld   [sSFXNR12], a
	ldh  [rNR12], a
	jr   Sound_SFX1CopyRegs
; =============== Sound_SFX1SetFreq ===============
; Sets a new frequency for the currently playing SFX1.
; Meant to be called by SFX1 code.
; IN:
; - A: Frequency value (low byte)
Sound_SFX1SetFreq:
	ld   [sSFXNR13], a
	ldh  [rNR13], a
; =============== Sound_SFX1CopyRegs ===============
; Copies the temporary SFX1 sound registers.
; This works because when SFX1 is active, BGM playback for channel 1 is disabled,
; meaning the original 
Sound_SFX1CopyRegs:
	ld   a, [sSFXNR10]
	ldh  [rNR10], a
	ld   a, [sSFXNR11]
	ldh  [rNR11], a
	ld   a, [sSFXNR12]
	ldh  [rNR12], a
	ld   a, [sSFXNR13]
	ldh  [rNR13], a
	ld   a, [sSFXNR14]
	ldh  [rNR14], a
	ret
	
SFX1_2B_Next:
	call Sound_DoSFX1Timer
	
; =============== Sound_SFX1AlternatePitch ===============
; This alternates the frequency between by adding and removing the same frequency
; offset on odd/even frames.
; To work properly the frequency offset must be an odd value.
Sound_SFX1AlternatePitch:
	ld   a, [sSFX1FreqOffset]	; B = Freq offset
	ld   b, a
	;--
	; Alternate add/removal on odd/even values
	ld   a, [sSFXNR13]			
	bit  0, a		
	
	jr   z, .remove
	add  b
	jr   .setFreq
.remove:
	sub  a, b
	;--
.setFreq:
	ld   [sSFXNR13], a
	ldh  [rNR13], a
	ret
	
; =============== Sound_SFX1PitchFromDIV_1F ===============
; Applies a low loop upwards pitch bend, using the DIV register % $1F.
Sound_SFX1PitchFromDIV_1F:
	ldh  a, [rDIV]
	and  a, $1F
	jr   Sound_SFX1PitchFromDIV
; =============== Sound_SFX1PitchFromDIV_1F ===============
; Applies a high loop upwards pitch bend, using the DIV register % $7F.
Sound_SFX1PitchFromDIV_7F:
	ldh  a, [rDIV]
	and  a, $7F
; =============== Sound_SFX1PitchFromDIV ===============
Sound_SFX1PitchFromDIV:
	ld   e, a			; DE = Frequency offset from DIV register
	xor  a
	ld   d, a
	ld   a, [sSFXNR13]	; HL = Current frequency
	ld   l, a
	ld   a, [sSFXNR14]
	ld   h, a
	add  hl, de			; Apply the frequency and save regs
	jp   Sound_SFX1ApplyPitchBend_setRegs
	
SFX1_29_Next:
	call Sound_DoSFX1Timer
	
; =============== Sound_SFX1ApplyPitchBend ===============
; Applies a previously specified frequency offset for the currently playing SFX1.
; This offset can be either positive or negative.
;
; The frequency offset is useful for creating SFX1 pitch bends, as
; this would be called every frame, progressively reducing or increasing
; the channel frequency.
;
Sound_SFX1ApplyPitchBend:
	ld   a, [sSFX1FreqOffsetHigh]	; HL = Frequency offset
	ld   h, a
	ld   a, [sSFX1FreqOffset]
	ld   l, a
	ld   a, [sSFXNR13]				; BC = Current frequency
	ld   c, a
	ld   a, [sSFXNR14]
	ld   b, a
	
	; The MSB is not treated as restart flag in this frequency data.
	bit  7, h			; Is the MSB set?
	jr   z, .signedDec  ; If not, jump
.signedAdd:
	; If the MSB is set, the frequency offset is added to the current frequency
	add  hl, bc
	jr   Sound_SFX1ApplyPitchBend_setRegs
.signedDec:
	; If the MSB is clear, the low byte is subtracted from the frequency as usual
	; But the high byte is copied to the frequency data directly.
	ld   a, c			; Subtract lower byte
	sub  a, l
	jr   nc, .noUndF	; If it underflowed, decrement the high byte
	dec  b 				; [TCRF] which never happens
.noUndF:
	ld   l, a			; Set it
	ld   a, b			; Copy B directly
	ld   h, a
	;--
	
Sound_SFX1ApplyPitchBend_setRegs:
	; Save the low byte
	ld   a, l			
	ld   [sSFXNR13], a
	ldh  [rNR13], a
	; Save the high byte
	res  7, h ; 		; Always clear the aforemented MSB to avoid a restart
	ld   a, h
	; Bit 3 is not part of the frequency values.
	; If it's set, the sum overflowed and the volume bits are all zeroed out now.
	; (this works because the offset can only lead to +1 or -1 ops)
	bit  3, a			
	jr   z, .noOver
	dec  a				; Fix the overflow
.noOver:
	ld   [sSFXNR14], a
	ldh  [rNR14], a
	ret
; =============== Sound_ParseBGMHeader ===============
; Parses header data, to prepare playback of a new BGM.
; This will copy the header data to RAM and set up the BGM chunk and command table pointers.
; IN
; - HL: Ptr to BGM header
Sound_ParseBGMHeader:
	call Sound_ClearBGMRAM
	;--
	; Byte 0 -- Pitch options
	ldi  a, [hl]		
	bit  0, a					; Bit 0 marks a special pitch increase for channel 2
	jr   z, .noCh2ExtraPitch
	push af
	ld   a, $01
	ld   [sBGMCh2PitchExtra], a
	pop  af
.noCh2ExtraPitch:
	; Set the base pitch offset
	res  0, a
	ld   [sBGMPitch], a
	ld   [sBGMPitchOrig], a
	;--
	; Bytes 1-2 -- Sound settings
	; These are for the normal variations
	ldi  a, [hl]
	ld   [sBGMLenPtr+1], a
	ldi  a, [hl]
	ld   [sBGMLenPtr], a
	; Check if to replace the ptr with the hurry up variation
	call Sound_ChkHurryUp
	;--
	; Bytes 3-4 -- Channel 1 Chunk Ptr (ptr to the first CmdTbl ptr)
	ldi  a, [hl]
	ld   [sBGMCh1ChunkPtr+1], a
	ldi  a, [hl]
	ld   [sBGMCh1ChunkPtr], a
	;--
	; Bytes 5-6 -- Channel 2 Chunk Ptr
	ldi  a, [hl]
	ld   [sBGMCh2ChunkPtr+1], a
	ldi  a, [hl]
	ld   [sBGMCh2ChunkPtr], a
	;--
	; Bytes 7-8 -- Channel 3 Chunk Ptr
	ldi  a, [hl]
	ld   [sBGMCh3ChunkPtr+1], a
	ldi  a, [hl]
	ld   [sBGMCh3ChunkPtr], a
	;--
	; Bytes 9-A -- Channel 4 Chunk Ptr
	ldi  a, [hl]
	ld   [sBGMCh4ChunkPtr+1], a
	ld   a, [hl]
	ld   [sBGMCh4ChunkPtr], a
;--
; Each sound channel is handled basically the same
; Check if the chunkTable ptr != 0, and if so, copy its first chunk(data) ptr over.
; ----------------------------------------

; mBGMHeader_ChkChunk
; Checks if the specified channel chunk pointer isn't null.
; If it isn't, it will jump to the specified label.
; IN:
; -  1: Ptr to the (SRAM) address the sound channel chunk ptr is stored
; -  2: Target label in case the chunk isn't null
; OUT:
; - HL: Ptr to the sound channel chunk ptr
mBGMHeader_ChkChunk: MACRO
	ld   a, [\1] 			; HL = Ptr to channel chunk list
	ld   h, a
	ld   a, [\1+1]
	ld   l, a
	
	ld   a, l			 	; Is the chunk ptr null?
	or   a, h
	jr   nz, \2 			; If not, handle it
ENDM

; mBGMHeader_SetDataPtr
; Sets initial command table ptr for the BGM channel
; IN:
; - 1: Ptr to the SRAM address of the BGM command table ptr
; - 2: Ptr to BGMCh?On flag, to allow playback on that sound channel
; - 3: Sound channel number
;  HL: Ptr to the sound channel chunk ptr
mBGMHeader_SetCmdTblPtr: MACRO
	ld   a, \3				; Mark the channel as enabled
	ld   [\2], a
	ldi  a, [hl]			; Store to the address the first CmdTbl pointer of the chunk
	ld   [\1+1], a
	ld   a, [hl]
	ld   [\1], a
ENDM

; ----------------------------------------
.ch1: ; If the chunk isn't null, jump to .setCh1CmdTbl
	mBGMHeader_ChkChunk sBGMCh1ChunkPtr, .setCh1CmdTbl
.setCh1None:
	xor  a					; Assume blank and mute the channel
	ld   [sBGMCh1On], a
	ld   a, $08
	ldh  [rNR12], a
	ld   a, $80
	ldh  [rNR14], a
	jr   .ch2
.setCh1CmdTbl:
	mBGMHeader_SetCmdTblPtr sBGMCh1CmdPtr, sBGMCh1On, $01
; ----------------------------------------
.ch2:
	mBGMHeader_ChkChunk sBGMCh2ChunkPtr, .setCh2CmdTbl
.setCh2None:
	xor  a
	ld   [sBGMCh2On], a
	ld   a, $08
	ldh  [rNR22], a
	ld   a, $80
	ldh  [rNR24], a
	jr   .ch3
.setCh2CmdTbl:
	mBGMHeader_SetCmdTblPtr sBGMCh2CmdPtr, sBGMCh2On, $02
; ----------------------------------------
.ch3:
	mBGMHeader_ChkChunk sBGMCh3ChunkPtr, .setCh3CmdTbl
.setCh3None:
	xor  a
	ld   [sBGMCh3On], a
	xor  a
	ldh  [rNR30], a
	jr   .ch4
.setCh3CmdTbl:
	mBGMHeader_SetCmdTblPtr sBGMCh3CmdPtr, sBGMCh3On, $03
; ----------------------------------------
.ch4:
	mBGMHeader_ChkChunk sBGMCh4ChunkPtr, .setCh4CmdTbl
.setCh4None:
	xor  a
	ld   [sBGMCh4On], a
	jr   .end
.setCh4CmdTbl:
	mBGMHeader_SetCmdTblPtr sBGMCh4CmdPtr, sBGMCh4On, $04
; ----------------------------------------
.end:
	; Signal the next data fetch to happen on the next frame
	ld   a, $01
	ld   [sBGMCh1Len], a
	ld   [sBGMCh2Len], a
	ld   [sBGMCh3Len], a
	ld   [sBGMCh4Len], a
	ret
; =============== Sound_SetBGMCh1 ===============
; Parses BGM commands and updates the sound registers for channel 1.
; This template is followed similarly for the other sound channels.
Sound_SetBGMCh1:
	; The subroutines called here work on a single shared RAM range.
	; We need to copy the RAM range with the channel 1 data to this temporary area.
	; Once the changes are done, it can be copied back.
	ld   de, sBGMCh1ChunkPtr 	; DE = Ptr to start of BGM channel state
	ld   hl, sBGMCurChArea		; HL = Where to copy the channel state
	call Sound_CopyBGMChArea
	; Get the ptr to the current command from the "BGM Command Table"
	ld   a, [sBGMCh1CmdPtr]		; HL = Ptr to current command
	ld   h, a
	ld   a, [sBGMCh1CmdPtr+1]
	ld   l, a
	ld   a, $01					; To identify the current channel
	call Sound_ParseBGMCommand
	
	; The sound channel should be enabled only if a new command has been processed
	ld   a, [sBGMCurProc]
	ld   [sBGMCh1On], a				
	and  a							; Is there a new command?
	jp   z, Sound_SetBGMCh1_MuteCh1 ; If not, mute the channel
	
	;--
	; Save current data pointer
	ld   a, h
	ld   [sBGMCh1CmdPtr], a
	ld   a, l
	ld   [sBGMCh1CmdPtr+1], a
	
	; Copy Sound_ParseBGMCommand temporary area to channel specific area
	ld   hl, sBGMCh1ChunkPtr
	ld   de, sBGMCurChArea
	call Sound_CopyBGMChArea
	
	; Save temporary registers to the channel-specific copy
	ld   a, [sBGMCurChRegType]
	cp   a, $01					; Were the optional registers updated? (BGMCMD_SETOPTREG command hit)
	jr   nz, .skipOptRegs		; If not, skip them
	ld   a, [sBGMCurChReg0]
	ld   [sBGMNR10], a
	ld   a, [sBGMCurChReg1]
	ld   [sBGMNR11], a
.skipOptRegs:
	ld   a, [sBGMCurChReg2]
	ld   [sBGMNR12], a
	ld   a, [sBGMCurChReg3]
	ld   [sBGMNR13], a
	ld   a, [sBGMCurChReg4]
	ld   [sBGMNR14], a
	
	; Copy sBGMNR** to the actual sound registers
	; Sound_CopyBGMCh1ToRegs:
	ld   a, [sBGMChSFX1]				
	and  a								; Is any SFX playing on this channel?
	jp   nz, Sound_DoCurrentBGM_Ch2		; If not, don't copy them
	ld   a, [sBGMNR10]
	ldh  [rNR10], a
	ld   a, [sBGMNR11]
	ldh  [rNR11], a
	ld   a, [sBGMNR12]
	ldh  [rNR12], a
	ld   a, [sBGMNR13]
	ldh  [rNR13], a
	ld   a, [sBGMNR14]
	ldh  [rNR14], a
	jp   Sound_DoCurrentBGM_Ch2
; =============== Sound_SetBGMCh2 ===============
; Parses BGM commands and updates the sound registers for channel 2
Sound_SetBGMCh2:
	; Copy channel data to temporary area
	ld   de, sBGMCh2ChunkPtr
	ld   hl, sBGMCurChArea
	call Sound_CopyBGMChArea
	
	; Get the ptr to the current command
	ld   a, [sBGMCh2CmdPtr]
	ld   h, a
	ld   a, [sBGMCh2CmdPtr+1]
	ld   l, a
	ld   a, $02
	call Sound_ParseBGMCommand
	
	; Mute channel if nothing's been processed
	ld   a, [sBGMCurProc]
	ld   [sBGMCh2On], a
	and  a
	jp   z, Sound_SetBGMCh2_MuteCh2
	
	;--
	; Save current data pointer
	ld   a, h
	ld   [sBGMCh2CmdPtr], a
	ld   a, l
	ld   [sBGMCh2CmdPtr+1], a
	
	; Copy back data from the temporary area
	ld   hl, sBGMCh2ChunkPtr
	ld   de, sBGMCurChArea
	call Sound_CopyBGMChArea
	
	; Save temporary registers to the channel-specific copy
	ld   a, [sBGMCurChRegType]
	cp   a, $02
	jr   nz, .skipOptRegs
	ld   a, [sBGMCurChReg1]
	ld   [sBGMNR21], a
.skipOptRegs:
	ld   a, [sBGMCurChReg2]
	ld   [sBGMNR22], a
	ld   a, [sBGMCurChReg3]
	ld   [sBGMNR23], a
	ld   a, [sBGMCurChReg4]
	ld   [sBGMNR24], a
	
	; Copy sBGMNR* to the actual sound registers
	ld   a, [sBGMChSFX2]
	and  a							; Is there any SFX2 playing?
	jp   nz, Sound_DoCurrentBGM_Ch3	; If so, skip the copy
	ld   a, [sBGMNR21]
	ldh  [rNR21], a
	
	;--
	; Channel 2 pitch increase option.
	; Some songs request the channel 2 pitch to be slightly higher compared to other channels.
	;
	ld   a, [sBGMCh2PitchExtra]
	cp   a, $01			; Is this option enabled?
	jr   nz, .copyRegs	; if not, skip it
	ld   a, [sBGMNR23] 
	ld   l, a
	ld   a, [sBGMNR24]
	ld   h, a
	
	cp   a, $87			; Are the frequency bits of the high byte at the highest possible value?
	jr   nc, .highFreq	; if so, increase the pitch by 1
	inc  hl				; Otherwise increase it by 2
	inc  hl
	jr   .setFreq
.highFreq:
	inc  hl
.setFreq:
	ld   a, l			; Set the new frequency
	ld   [sBGMNR23], a
	ld   a, h
	ld   [sBGMNR24], a
	;--
	
.copyRegs:;R
	ld   a, [sBGMNR22]
	ldh  [rNR22], a
	ld   a, [sBGMNR23]
	ldh  [rNR23], a
	ld   a, [sBGMNR24]
	ldh  [rNR24], a
	jp   Sound_DoCurrentBGM_Ch3
; =============== Sound_SetBGMCh3 ===============
; Parses BGM commands and updates the sound registers for channel 3
Sound_SetBGMCh3:
	; Copy channel data to temporary area
	ld   de, sBGMCh3ChunkPtr
	ld   hl, sBGMCurChArea
	call Sound_CopyBGMChArea
	
	; Get the ptr to the current command
	ld   a, [sBGMCh3CmdPtr]
	ld   h, a
	ld   a, [sBGMCh3CmdPtr+1]
	ld   l, a
	
	; Process it
	ld   a, $03
	call Sound_ParseBGMCommand
	
	; Mute channel if nothing's been processed
	ld   a, [sBGMCurProc]
	ld   [sBGMCh3On], a
	and  a
	
	;--
	; Save current data pointer
	jp   z, Sound_SetBGMCh3_MuteCh3
	ld   a, h
	ld   [sBGMCh3CmdPtr], a
	ld   a, l
	ld   [sBGMCh3CmdPtr+1], a
	
	; Copy back data from the temporary area
	ld   hl, sBGMCh3ChunkPtr
	ld   de, sBGMCurChArea
	call Sound_CopyBGMChArea
	
	; Save temporary registers to the channel-specific copy
	ld   a, [sBGMCurChReg0]
	ld   [sBGMNR30], a
	ld   a, [sBGMCurChReg1]
	ld   [sBGMNR31], a
	ld   a, [sBGMCurChReg2]
	ld   [sBGMNR32], a
	ld   a, [sBGMCurChReg3]
	ld   [sBGMNR33], a
	ld   a, [sBGMCurChReg4]
	ld   [sBGMNR34], a
	
	; Copy sBGMNR** to the actual sound registers
	ld   a, [sBGMChSFX3]
	and  a								; [TCRF] Is there any SFX3 playing?
	jp   nz, Sound_DoCurrentBGM_Ch4 	; If so, skip the copy
	xor  a
	ldh  [rNR30], a
	ld   a, [sBGMNR30]
	ldh  [rNR30], a
	ld   a, [sBGMNR31]
	ldh  [rNR31], a
	ld   a, [sBGMNR32]
	ldh  [rNR32], a
	ld   a, [sBGMNR33]
	ldh  [rNR33], a
	ld   a, [sBGMNR34]
	ldh  [rNR34], a
	jp   Sound_DoCurrentBGM_Ch4
; =============== Sound_SetBGMCh4 ===============
; Parses BGM commands and updates the sound registers for channel 4
Sound_SetBGMCh4:
	; Copy channel data to temporary area
	ld   de, sBGMCh4ChunkPtr
	ld   hl, sBGMCurChArea
	call Sound_CopyBGMChArea
	
	; Get the ptr to the current command
	ld   a, [sBGMCh4CmdPtr]
	ld   h, a
	ld   a, [sBGMCh4CmdPtr+1]
	ld   l, a
	
	; Process it
	ld   a, $04
	call Sound_ParseBGMCommand
	
	; Mute channel if nothing's been processed
	ld   a, [sBGMCurProc]
	ld   [sBGMCh4On], a
	and  a
	jp   z, Sound_SetBGMCh4_MuteCh4
	
	;--
	; Save current data pointer
	ld   a, h
	ld   [sBGMCh4CmdPtr], a
	ld   a, l
	ld   [sBGMCh4CmdPtr+1], a
	
	; Copy back data from the temporary area
	ld   hl, sBGMCh4ChunkPtr
	ld   de, sBGMCurChArea
	call Sound_CopyBGMChArea
	
	; Copy temporary registers directly to the actual sound registers
	ld   a, [sBGMChSFX4] 	
	and  a					; Is there any SFX4 playing?
	ret  nz					; If so, skip the copy
	ld   a, [sBGMCurChReg1]
	ldh  [rNR41], a
	ld   a, [sBGMCurChReg2]
	ldh  [rNR42], a
	ld   a, [sBGMCurChReg3]
	ldh  [rNR43], a
	ld   [sBGM_Unused_CurChReg3Copy], a
	ld   a, [sBGMCurChReg4]
	ldh  [rNR44], a
	ld   [sBGM_Unused_CurChReg4Copy], a
	ret
; =============== Sound_ParseBGMCommand ===============
; Decodes the custom BGM sound format and generates the
; output data for the sound registers. 
; IN:
; -  A: Indicates the sound channel we're handling (1-4)
; - HL: Ptr to the current sound command from the BGM CmdTbl
; OUT:
; - HL: Pointer to a sound command from the BGM CmdTbl, if present 
;       (usually the next command)
; - sBGMCurProc: != 0 if a command has been parsed
Sound_ParseBGMCommand:
	ld   [sBGMCurProc], a ; Mark the currently processed channel
	
	ld   a, [hl]		; Read the byte from the command table
	and  a				; Have we reached the end separator? (BGMCMD_END)
	jp   nz, .handleCmd	; If not, handle the command
.endOfCmdTable:
	; Marked between '==' the area where HL doesn't point to a command byte	
	;==
	; We've processed all of the entries of command table.
	; Switch to the next command table of the chunk.
	; sBGMCurChChunkPtr += 2
	ld   a, [sBGMCurChChunkPtr]		
	ld   h, a
	ld   a, [sBGMCurChChunkPtr+1]
	ld   l, a
	inc  hl
	inc  hl
	ld   a, h
	ld   [sBGMCurChChunkPtr], a
	ld   a, l
	ld   [sBGMCurChChunkPtr+1], a
	;--
	; Check if we've reached the last table of the chunk.
	; To determine this, we check if the next 2 bytes are both $00 (BGMTBL_END)
	; Note that since most BGMs loop, very few of them actually have this $0000 sequence.
	ld   a, [hl]		
	and  a					; Is the first byte 0?
	jr   nz, .chkLoopTbl	; If not, there's a new command table
	inc  hl				
	ldd  a, [hl]			; Is the second byte 0? (restoring the orig hl value)
	and  a
	jr   nz, .chkLoopTbl 	; If not, there's a new command table
	;--
	; We reached the end of the chunk.
	; Signal this.
	xor  a
	ld   [sBGMCurProc], a
	ret
.chkLoopTbl:
	
	; Now we know that there's another command table pointer in the current chunk.
	; This pointer may be actually a chunk loop command though (BGMTBLCMD_REDIR).
	;
	; If we get the sequence of bytes $F0,$00, instead of attempting to use
	; the invalid BGMTable L0000F0, handle the special redirect command.
	ld   a, [hl]						; A = First byte of the command table.
	cp   a, LOW(BGMTBLCMD_REDIR)	    ; Is it $F0?
	jr   nz, .setNewTblPtr				; If not, jump
	inc  hl
	ldd  a, [hl]		
	and  a								; Is the second byte $00?
	call z, Sound_DoBGMTblCmd_Redir		; If so, redirect the chunk pointer
.setNewTblPtr:

	; Now the chunk table ptr is pointing to an (hopefully) valid BGM command table pointer.
	;
	; When we get to .handleCmd, HL should point to a command table, but now it's pointing
	; to an entry in the chunk table.
	;
	; Read that entry out -- and with that we're pointing to the start of a BGM command table.
	ldi  a, [hl]	; Get the data pointer from the current location
	ld   b, a
	ld   a, [hl]
	ld   h, a		; HL = command data pointer
	ld   l, b
	;==
	
.handleCmd:
	ld   a, [hl]		; Read the command
	; Check if it's a special command
	cp   a, BGMCMD_SETOPTREG
	call z, Sound_DoBGMCmd_SetOpt
	cp   a, BGMCMD_SETLENGTHPTR
	call z, Sound_DoBGMCmd_SetLengthPtr
	cp   a, BGMCMD_SETPITCH
	call z, Sound_DoBGMCmd_SetPitch
	cp   a, BGMCMD_SETLOOP
	call z, Sound_DoBGMCmd_SetLoop
	cp   a, BGMCMD_LOOP
	call z, Sound_DoBGMCmd_Loop
	
	and  a ; BGMCMD_END
	jp   z, .endOfCmdTable
	cp   a, BGMCMD_STOPALL
	jp   nc, Sound_StopAll
	cp   a, BGMCMD_NOP
	jr   nc, .handleCmd
	
	; Commands $9F-$F0 will be treated as an index to the BGM length table
	; for a length change command.
	
	; So if it's < $9F skip this part.
	cp   a, BGMCMD_SETLENGTHID
	jp   c, Sound_DoBGMDataCmd
	
; =============== Length change command ===============
; Sets a new playback length for the current sound channel.
; This means that from now on, playback commands for this channel will
; last the amount of frames determined by the indexed table.
; Command format: <cmd>
; - Cmd: Value used to create an index to the table sBGMLenPtr points to.
Sound_DoBGMCmd_SetLength:
	; A = (Cmd ! $A0)
	res  7, a
	res  5, a
	;--
	; BC = Ptr to BGM length table
	; Note: this ptr can be altered with the BGMCMD_SETLENGTHPTR command
	push af
	ld   a, [sBGMLenPtr]
	ld   b, a
	ld   a, [sBGMLenPtr+1]
	ld   c, a
	pop  af
	;--
	; Index the BGM length table
	; A = sBGMLenPtr[A]
	push hl
	ld   l, a			; HL = A
	ld   h, $00
	add  hl, bc			; 
	ld   a, [hl]
	pop  hl
	;--
	; Set the length of the playback settings for the channel,
	; as well as a backup copy in case it needs to be reset.
	ld   [sBGMCurChLen], a
	ld   [sBGMCurChLenOrig], a
	inc  hl
	
; =============== Sound_DoBGMDataCmd ===============
; Handles the next data command from the sound data.
; This will set values in the temporary sound register area.
; IN
; - HL: Ptr to sound data
Sound_DoBGMDataCmd:
	; Use previously set length for this new command (get it from the backup copy)
	ld   a, [sBGMCurChLenOrig]
	ld   [sBGMCurChLen], a
	
	; The sound data generated depends on a combination of:
	; - Current sound channel (sBGMCurProc)
	; - The sound data itself (the first byte determines the action)
	
	; Handle channel 4 in a separate way
	ld   a, [sBGMCurProc]
	cp   a, $04
	jp   z, Sound_DoBGMDataCmd_Ch4
	
	; Read the next byte from the BGM data.
	
	; Check if it's a special command first.
	ldi  a, [hl]						; Read the same command from before
	cp   a, BGMDATACMD_MUTECH
	jr   z, Sound_DoBGMDataCmd_MuteCh
	cp   a, BGMDATACMD_HIGHENV
	jp   z, Sound_DoBGMDataCmd_HighEnv
	cp   a, BGMDATACMD_LOWENV
	jp   z, Sound_DoBGMDataCmd_LowEnv
	
	; Otherwise...
	
; =============== Sound_DoBGMDataCmd_Pitch ===============
; Default data command.
; The data byte is interpreted as an offset to the current pitch value.
; Because the pitch is an offset to a table with 2 byte entries (low and high freq.),
; this value should always be even.
; IN
; - A: Pitch offset
Sound_DoBGMDataCmd_Pitch:
	push hl
	;--
	; If ch3 is being handled, make sure its output is enabled.
	; (the wave channel is special in that it's muted when not needed)
	push af
	ld   a, [sBGMCurProc]
	cp   a, $03				; Are we handling ch3?
	jr   nz, .notCh3		; If not, skip this
	
	ld   a, [sBGMChSFX3]	; There's no SFX3 so this won't ever jump
	and  a					
	jr   nz, .notCh3		
	
	ld   hl, rNR51			; Enable ch3 output
	set  SNDOUTB_CH3L, [hl]
	set  SNDOUTB_CH3R, [hl]
	ld   a, SNDCH3_ON
	ld   [sBGMCurChReg0], a ; NR30
.notCh3:
	pop  af
	;--
	
	ld   b, a				; B = Pitch offset
	; [TCRF] There's no pitch option for channel 4, so we use the hardcoded pitch offset $4
	;        However, channel 4 is handled separately at Sound_DoBGMDataCmd_Ch4, so this will never happen.
	;        This also means the different offset calculation never happens.
	ld   a, [sBGMCurProc]	
	cp   a, $04
	jr   z, .noPitch
	
	;--
	; Calculate the pitch offset.
	; BC = Pitch + PitchOffset
	;
	ld   a, [sBGMPitch]		; Base pitch
	add  b					; Add offset
.noPitch:
	ld   c, a			
	ld   b, $00
	;--
	; Offset the pitch table
	ld   hl, Sound_BGMPitchTable
	add  hl, bc
	; Get the raw register data out of it
	ld   a, [sBGMCurChVol]
	ld   [sBGMCurChReg2], a
	ldi  a, [hl]
	ld   [sBGMCurChReg3], a
	ld   a, [hl]
	ld   [sBGMCurChReg4], a
	pop  hl
	ret
	
; =============== Sound_DoBGMDataCmd_MuteCh ===============
; Data command $01.
; Silences the current channel.
Sound_DoBGMDataCmd_MuteCh:
	; sound channel 3 does it different
	ld   a, [sBGMCurProc]
	cp   a, $03
	jr   z, .ch3
	; silence ch1 or ch2
	ld   a, $08
	ld   [sBGMCurChReg2], a
	ld   a, $80
	ld   [sBGMCurChReg4], a
	ret
.ch3:
	; silence ch3
	xor  a
	ld   [sBGMCurChReg0], a
	ld   [sBGMCurChReg2], a
	ret
; =============== Sound_DoBGMDataCmd_Ch4 ===============
; Handles the next data command from the sound data for channel 4.
; IN
; - HL: Ptr to sound data
Sound_DoBGMDataCmd_Ch4:
	; Read the same command from before
	ldi  a, [hl]
	
	;--
	; Check if it's a special command
	; The noise channel supports only the mute command
	cp   a, BGMDATACMD_MUTECH
	jr   z, Sound_DoBGMDataCmd_MuteCh
	
	;--
	; Otherwise, it's an offset to a separate table of raw ch4 register data.
	; This offset must be a multiple of 4 as that's the length of an entry.
	push hl
	ld   c, a							; BC = Offset
	ld   b, $00
	; Point to the table entry we need
	ld   hl, Sound_BGMNoiseTable		; HL = BaseTable + Offset
	add  hl, bc
	; And copy the rNR4? data over
	ldi  a, [hl]
	ld   [sBGMCurChReg1], a
	ldi  a, [hl]
	ld   [sBGMCurChReg2], a
	ldi  a, [hl]
	ld   [sBGMCurChReg3], a
	ld   a, [hl]
	ld   [sBGMCurChReg4], a
	pop  hl
	ret
; =============== Sound_DoBGMDataCmd_HighEnv ===============
; Data command $03
; Sets the high envelop sweep if a fade out isn't active.
Sound_DoBGMDataCmd_HighEnv:
	ld   a, %1110110
	ld   [sBGMCurChReg2], a ; Set high envelope
	jr   Sound_DoBGMDataCmd_CopyNRData
	
; =============== Sound_DoBGMDataCmd_LowEnv ===============
; Data command $05
; Sets the low envelop sweep if a fade out isn't active.
Sound_DoBGMDataCmd_LowEnv:
	ld   a, %1000110
	ld   [sBGMCurChReg2], a ; Set low envelope
	jr   Sound_DoBGMDataCmd_CopyNRData
	
; =============== Sound_DoBGMDataCmd_LowEnv ===============
; Essentially copies the NR data from the previous frame to the current frame.
; The only difference will be the different envelope settings.
;
; This has to be done to avoid using bad sBGMCurChReg? values since, unlike the BGM commands, 
; the data commands don't return back to the main code path.
Sound_DoBGMDataCmd_CopyNRData:
	ld   a, [sBGMAct]		
	cp   a, BGMACT_FADEOUT	; Is a fade out active?
	jr   nz, .copyPrevData	; If not, jump
	ld   a, %00001000		; Otherwise disable the envelope
	ld   [sBGMCurChReg2], a
.copyPrevData:
	; Each channel has their own BGMNR registers, so...
	ld   a, [sBGMCurProc]
	cp   a, $01
	jr   z, .ch1
	cp   a, $02
	jr   z, .ch2
	cp   a, $03
	jr   z, .ch3
	; [TCRF] This would ignore the command for ch4, but we can't get there.
	ret
.ch1:
	ld   a, [sBGMNR13]
	ld   [sBGMCurChReg3], a
	ld   a, [sBGMNR14]
	ld   [sBGMCurChReg4], a
	ret
.ch2:
	ld   a, [sBGMNR23]
	ld   [sBGMCurChReg3], a
	ld   a, [sBGMNR24]
	ld   [sBGMCurChReg4], a
	ret
.ch3:
	;--
	; [TCRF] Ch3 is never muted as there's no SFX3
	ld   a, [sBGMChSFX3]
	and  a
	ret  nz
	;--
	ld   a, $80
	ld   [sBGMCurChReg0], a
	ld   a, [sBGMNR33]
	ld   [sBGMCurChReg3], a
	ld   a, [sBGMNR34]
	ld   [sBGMCurChReg4], a
	ret
; =============== Sound_ChkHurryUp ===============
; Checks if the sound options from Hurry Up mode should be used.
; Curiously, the boss and invincibility BGM are unaffected by this.
;
Sound_ChkHurryUp:
	; As this is only for the hurry up mode...
	ld   a, [sHurryUp]
	and  a
	ret  z
	; Curiously, both the invincibility and boss track won't ever use the hurry up variation.
	ld   a, [sBGMSet]		; Is the invincibility or boss music playing?
	cp   a, BGM_INVINCIBILE
	ret  z					; If so, return
	cp   a, BGM_BOSS		
	ret  z					; "" 
	jp   Sound_UseHurryUp
; =============== Sound_DoBGMCmd_SetOpt ===============
; BGM Command $F1
; Changes the sound registers a normal data command can't modify.
; Basically every register except hi/lo frequency from ch1,ch2 and ch3.
;
; Format: <CID><Volume><Sweep><Duty>
;    CID: Id of this command
; Volume: Channel Volume
;  Sweep: Sweep Options (rNR?0)
;   Duty: Sound Wave Duty/Length (rNR?1)
;
; Channel 3 uses a different format, see Sound_DoBGMCmd_SetOptCh3.
Sound_DoBGMCmd_SetOpt:
	inc  hl
	; Mark that we changing the other registers options
	ld   a, [sBGMCurProc]
	ld   [sBGMCurChRegType], a
	; Handle channel 3 elsewhere, since it uses different registers
	cp   a, $03
	jr   z, Sound_DoBGMCmd_SetOptCh3	
	
	ld   a, [sBGMAct]
	cp   a, BGMACT_FADEOUT
	jr   nz, .fadeOut
	;--
	; Copy volume
	ldi  a, [hl]				
	ld   [sBGMCurChReg2], a
	jr   .setRegs01
.fadeOut:
	ldi  a, [hl]
	ld   [sBGMCurChReg2], a
	ld   [sBGMCurChVol], a ; Decrease the volume more
.setRegs01:
	ldi  a, [hl]				; Copy sweep
	ld   [sBGMCurChReg0], a
	ld   a, [hl]				; Copy duty
	ld   [sBGMCurChReg1], a
	
	; For NR11/NR21, the bitmask doesn't completely map to what it's supposed to be.
	; Only bits 6-7 correspond to actual sound register data (which is why we're removing them),
	; the other bits contain instead the BGMPP / PitchCmd command ID to change pitch settings.
	; This feature is rarely used -- most of the data commands have those bits set to 0.
	res  6, a
	res  7, a

; =============== Sound_SetBGMReg_SetBGMPitchCmd ===============
; Sets the post-parse pitch change command, if any. 
; This will be handled elsewhere, away from all other normal BGM commands.
;
; IN
; - A: Command ID
Sound_SetBGMReg_SetBGMPitchCmd:
	;-- 
	; this does nothing; ignore
	and  a					
	jr   nz, .notBlank 	
	xor  a  				
	.notBlank:	
	;--
	ld   [sBGMCurChPitchCmd], a
	
; =============== Sound_BGMCommandRet ===============
; BGMCommand handlers will jump here after they are done.
; This will get the first byte of the next command.
; This is done to potentially save time with multiple special commands,
; though this requires a specific command order.
;
; IN
; - HL: Ptr to first byte of next command
; OUT
; -  A: First byte of next command
Sound_BGMCommandRet:
	inc  hl
Sound_BGMCommandRet2:
	ld   a, [hl]
	ret
	
; =============== Sound_DoBGMCmd_SetOptCh3 ===============
; BGM Command $F1
; Changes the sound registers a normal data command can't modify.
; Basically every register from channel 3, including wave data.
;
; CH3 Format: <CID><WavePtr><Volume>
;     CID: Id of this command
; WavePtr: Ptr to Wave data (2 bytes)
;  Volume: Channel Volume
;
Sound_DoBGMCmd_SetOptCh3:
	; Store the ptr to wave data both to RAM and DE
	ldi  a, [hl]
	ld   [sBGMCurChWavePtr], a
	ld   [sBGMCurChWavePtrOrig], a
	ld   e, a
	ldi  a, [hl]
	ld   [sBGMCurChWavePtr+1], a
	ld   [sBGMCurChWavePtrOrig+1], a
	ld   d, a
	
	ld   a, [sBGMAct]		; Is there a fade out in progress?
	cp   a, BGMACT_FADEOUT
	jr   nz, .ch3FadeOut	; If so, jump
	
	ld   a, [hl]
	ld   [sBGMCurChReg2], a
	jr   .chkCopyWave
.ch3FadeOut:
	ld   a, [hl]
	ld   [sBGMCurChReg2], a
	ld   [sBGMCurChVol], a ; Decrease the volume more
.chkCopyWave:
	; Copy the wave data to the registers
	
	; [TCRF] Don't interfere if a SFX3 is playing (though there aren't any)
	ld   a, [sBGMChSFX3]
	and  a
	jr   nz, .setVolReg    
	
	xor  a						; Stop CH3 playback while data is copied over
	ldh  [rNR30], a
	call Sound_CopyWavePattern	; Copy data over
.setVolReg:
	; Get the pitch change command id
	; Similar thing to what's done for ch1 and ch2
	ld   a, [sBGMCurChReg2]
	res  5, a					
	res  6, a
	jr   Sound_SetBGMReg_SetBGMPitchCmd
; =============== Sound_DoBGMCmd_SetLengthPtr ===============
; Command $F2
; Sets a new BGM length table pointer.
;
; Format: <CID><LengthPtr>
; - CID: Command Id
; - LengthPtr: Ptr to the length table
Sound_DoBGMCmd_SetLengthPtr:
	inc  hl					; Skip command id
	
	ldi  a, [hl]			; Set the length ptr
	ld   [sBGMLenPtr+1], a
	ldi  a, [hl]
	ld   [sBGMLenPtr], a
	jr   Sound_BGMCommandRet2
; =============== Sound_DoBGMCmd_SetPitch ===============
; Command $F3
; Sets a new pitch base offset, relative to the song's default pitch option.
;
; Format: <CID><Pitch>
; - CID: Command Id
; - Pitch: Pitch offset value
Sound_DoBGMCmd_SetPitch:
	inc  hl 				; Skip command id
	
	ld   a, [sBGMPitchOrig] ; As the pitch is relative to the original untouched pitch value,
	ld   [sBGMPitch], a		; the backup value should be copied over
	
	add  [hl]			; Only then, add the new offset value
	inc  hl
	ld   [sBGMPitch], a
	
	jr   Sound_BGMCommandRet2
; =============== Sound_DoBGMTblCmd_Redir ===============
; Chunk table entry $F0,$00
; Sets the chunk pointer to a new value, generally used to loop certain chunks over and over for looping BGMs.
;
; Command format: <CID><Ptr>
; - CID: Command identifier. This the sequence of bytes $F0,$00. However, this is checked elsewhere.
;        (when we get here we've already r
; - Ptr: New Chunk pointer location
;
;--
; EXAMPLE USAGE
;
; BGMChunk_Sample_Ch1:
; .loop:
; 	dw $5AE1           ; Table 0
; 	dw $5ED4           ; Table 1
; 	dw BGMTBLCMD_REDIR ; Loop command (dw $00F0)
; 	dw .loop           ; Where to loop (go back to Table 0)
;--
; IN
; - HL: Points to the beginning of the command marker ($F0,$00 sequence).
; OUT
; - HL: Points to the a "BGMTbl pointer" in the chunk table
Sound_DoBGMTblCmd_Redir:
	inc  hl							; Skip 2-byte command identifier
	inc  hl
	
	; Now we're pointing to a BGMChunk pointer.
	; Replace the current one with this new one.
	ldi  a, [hl]					; Set low byte to SRAM ptr
	ld   [sBGMCurChChunkPtr+1], a
	ld   b, a
	ld   a, [hl]					; Set high byte to SRAM ptr
	ld   [sBGMCurChChunkPtr], a
	ld   h, a						; Also return said pointer to HL
	ld   l, b
	ret
	
; =============== Sound_DoBGMCmd_SetLoop ===============
; Command $F4
; This sets the current data ptr (HL) as the loop point 
; for the current BGM channel, and how many times it should loop.
;
; Command format: <CID><Len>
; - CID: Command identifier.
; - Len: Loop count
Sound_DoBGMCmd_SetLoop:
	inc  hl
	; Save the loop count
	ldi  a, [hl]
	ld   [sBGMCurChLoopCount], a
	; Save the current ptr
	ld   a, h
	ld   [sBGMCurChLoopPtr], a
	ld   a, l
	ld   [sBGMCurChLoopPtr+1], a
	jr   Sound_BGMCommandRet2

; =============== Sound_DoBGMCmd_Loop ===============
; Command $F5
;
; Command format: <CID>
; - CID: Command identifier.
;
; This loops the BGM to the previously set loop point, 
; if there are any loops left.
;
Sound_DoBGMCmd_Loop:
	ld   a, [sBGMCurChLoopCount] 	; Decrement the loops left
	dec  a
	ld   [sBGMCurChLoopCount], a
	and  a							; Are there any loops left?
	jr   z, Sound_BGMCommandRet 	; If not, don't loop.
	ld   a, [sBGMCurChLoopPtr]		; Otherwise restore the data ptr
	ld   h, a
	ld   a, [sBGMCurChLoopPtr+1]
	ld   l, a
	jp   Sound_BGMCommandRet2
; =============== Sound_CopyBGMChArea ===============	
; Copies $0B bytes from the specified address to the specified destination.
; This is strictly used to copy the RAM area of a sound channel 
; to a shared temporary range and vice versa.
; IN:
; - DE: Starting address of channel RAM area, or sBGMCurChArea (the start of the temporary shared area)
; - HL: Destination address
Sound_CopyBGMChArea:
	ld   a, [Sound_CopyBGMChArea_0B]	; A = $0B (how did this happen??)
	ld   b, a								; B = $0B
.loop:
	ld   a, [de]	; Standard copy loop
	ldi  [hl], a	
	inc  de			
	dec  b
	ld   a, b		; .
	and  a
	jr   nz, .loop
	ret
	
; =============== Sound_DoBGMPitchCmd ===============
; Handles a BGMPP command to change the song pitch.
; This is done at the very end of the sound channel handler,
; after the registers are copied over.
;
; As such, this expects the proper data in the same format
; as the rNR* registers to be present.
;
; IN
; - BC: Current frequency
Sound_DoBGMPitchCmd:
	ld   a, [sBGMCurChPitchCmd]	
	and  a						; Is any command requested?
	ret  z						; If not, jump
	
	; [TCRF] More than half of these are unused.
	;        And they aren't used that much to begin with.
	cp   a, $01
	jr   z, Sound_Unused_DoBGMPitchCmd_PitchBend0
	cp   a, $02
	jr   z, Sound_Unused_DoBGMPitchCmd_PitchBend1
	cp   a, $03
	jr   z, Sound_DoBGMPitchCmd_PitchBend2
	cp   a, $04
	jr   z, Sound_Unused_DoBGMPitchCmd_PitchBend3
	cp   a, $05
	jr   z, Sound_Unused_DoBGMPitchCmd_PitchBend4
	cp   a, $06
	jr   z, Sound_Unused_DoBGMPitchCmd_AddFreq
	cp   a, $07
	jp   z, Sound_DoBGMPitchCmd_AddFreq
	cp   a, $08
	jp   z, Sound_Unused_DoBGMPitchCmd_RemFreq
	cp   a, $09
	jp   z, Sound_DoBGMPitchCmd_PitchBend5
	cp   a, $0A
	jp   z, Sound_Unused_DoBGMPitchCmd_PitchBend6
	ret
	
; =============== Sound_DoBGMPitchCmd_SetPitchBend ===============
; Handles pitch bends for the current BGM channel.
; 
; IN
; - BC: Current frequency value
; - HL: Ptr to frequency offset table
Sound_DoBGMPitchCmd_SetPitchBend:
	; Calculate the index to use
	
	; Decrement the timer each frame
	; This will be used as the decrementing table offset
	ld   a, [sBGMPPCmdPitchIndex]	; Was the timer initialized?
	and  a
	jr   nz, .hasTimer				; If so, jump
IF FIX_BUGS == 1
	ld   a, $10
ELSE
	ld   a, $11						; [BUG] Taking the 'dec a' into account, this initializes it to $10
ENDC
	ld   [sBGMPPCmdPitchIndex], a   ;       This is 1 byte after the end of the pitch table.
.hasTimer:
	dec  a				
	ld   [sBGMPPCmdPitchIndex], a
	;--
	ld   e, a
	xor  a
	ld   d, a			; DE = Timer (the offset)
	
	; Offset the table to get the frequency offset
	add  hl, de			
	ld   a, [hl]		
	ld   e, a			; DE = frequency offset
	
	; Add it to the current frequency value
	ld   a, c			; HL = Current frequency
	ld   l, a
	ld   a, b
	ld   h, a
	add  hl, de			; += frequency offset
	
	; Save the modified frequency back to the registers
	ld   a, l					; Low byte
	ld   [sBGMCurChReg3], a
	ld   a, h					; High byte
	res  7, a					; Do not restart sound
	ld   [sBGMCurChReg4], a		
	ret
	
; =============== BGMPP Pitch command handlers ===============
; Each points to a different pitch bend table.
Sound_Unused_DoBGMPitchCmd_PitchBend0: ; BGMPP Command: $01
	ld   hl, Sound_BGMPitchCmdTable0
	jr   Sound_DoBGMPitchCmd_SetPitchBend
Sound_Unused_DoBGMPitchCmd_PitchBend1: ; BGMPP Command: $02
	ld   hl, Sound_BGMPitchCmdTable1
	jr   Sound_DoBGMPitchCmd_SetPitchBend
Sound_DoBGMPitchCmd_PitchBend2: ; BGMPP Command: $03
	ld   hl, Sound_BGMPitchCmdTable2
	jr   Sound_DoBGMPitchCmd_SetPitchBend
Sound_Unused_DoBGMPitchCmd_PitchBend3: ; BGMPP Command: $06
	ld   hl, Sound_BGMPitchCmdTable3
	jr   Sound_DoBGMPitchCmd_SetPitchBend
Sound_Unused_DoBGMPitchCmd_PitchBend4: ; BGMPP Command: $08
	ld   hl, Sound_BGMPitchCmdTable4
	jr   Sound_DoBGMPitchCmd_SetPitchBend
Sound_DoBGMPitchCmd_PitchBend5: ; BGMPP Command: $09
	ld   hl, Sound_BGMPitchCmdTable5
	jr   Sound_DoBGMPitchCmd_SetPitchBend
; [TCRF] This also doesn't point to the correct table
Sound_Unused_DoBGMPitchCmd_PitchBend6: ; BGMPP Command: $0A
	ld   hl, Sound_BGMPitchCmdTable5
	jr   Sound_DoBGMPitchCmd_SetPitchBend
; =============== Sound_Unused_DoBGMPitchCmd_AddFreq ===============
; BGMPP Command: $06
; Increases the channel frequency by 1.
Sound_Unused_DoBGMPitchCmd_AddFreq: 
	inc  bc					; Frequency++
	ld   a, c				; Save data
	ld   [sBGMCurChReg3], a
	ld   a, b
	res  7, a
	res  6, a
	ld   [sBGMCurChReg4], a
; =============== Sound_DoBGMPitchCmd_SaveRegs ===============
; Common return point for non pitch-bend options.
; This copies frequency registers from the temporary channel area
; to the channel-specific sBGMNR register copies. 
; [TCRF] This is only called for ch2, but ch1 and ch3 are also supported.
Sound_DoBGMPitchCmd_SaveRegs:
	; Determine the currently processed channel.
	ld   a, [sBGMCurProc]
	cp   a, $01				; Are we processing ch1?
	jr   nz, .chkCh2		; If not, jump
.unused_ch1:
	ld   a, [sBGMCurChReg3]
	ld   [sBGMNR13], a
	ld   a, [sBGMCurChReg4]
	ld   [sBGMNR14], a
	ret
.chkCh2:
	cp   a, $02				; Are we processing ch2?
	jr   nz, .unused_chkCh3	; If not, jump
.ch2:
	ld   a, [sBGMCurChReg3]
	ld   [sBGMNR23], a
	ld   a, [sBGMCurChReg4]
	ld   [sBGMNR24], a
	ret
.unused_chkCh3:
	cp   3					; Are we processing ch3?
	ret  nz					; If not, return
.unused_ch3:
	ld   a, [sBGMCurChReg3]
	ld   [sBGMNR33], a
	ld   a, [sBGMCurChReg4]
	res  7, a
	ld   [sBGMNR34], a
	ret
; =============== Sound_DoBGMPitchCmd_AddFreq ===============
; BGMPP Command: $07
; Increases the channel frequency by 4.
Sound_DoBGMPitchCmd_AddFreq:
	inc  bc					; Frequency += 4
	inc  bc
	inc  bc
	inc  bc
	
	ld   a, c				; Update current channel registers
	ld   [sBGMCurChReg3], a
	ld   a, b
	res  7, a				; Keep existing sound
	res  6, a
	ld   [sBGMCurChReg4], a
	jr   Sound_DoBGMPitchCmd_SaveRegs
; =============== Sound_Unused_DoBGMPitchCmd_RemFreq ===============
; BGMPP Command: $07
; Increases the channel frequency by 3.
Sound_Unused_DoBGMPitchCmd_RemFreq:
	dec  bc					; Frequency -= 3
	dec  bc
	dec  bc
	
	ld   a, c				; Update current channel registers
	ld   [sBGMCurChReg3], a
	ld   a, b
	res  7, a
	res  6, a
	ld   [sBGMCurChReg4], a
	jr   Sound_DoBGMPitchCmd_SaveRegs
; =============== Sound_SetBGMCh1_MuteCh1 ===============
Sound_SetBGMCh1_MuteCh1:
	xor  a
	ld   [sBGMCh1On], a
	ld   a, $08
	ldh  [rNR12], a
	ld   [sBGMNR12], a
	ld   a, $80
	ldh  [rNR14], a
	ld   [sBGMNR14], a
	jp   Sound_DoCurrentBGM_Ch2
; =============== Sound_SetBGMCh2_MuteCh2 ===============
Sound_SetBGMCh2_MuteCh2:
	xor  a
	ld   [sBGMCh2On], a
	ld   a, $08
	ldh  [rNR22], a
	ld   [sBGMNR22], a
	ld   a, $80
	ldh  [rNR24], a
	ld   [sBGMNR24], a
	jp   Sound_DoCurrentBGM_Ch3
; =============== Sound_SetBGMCh3_MuteCh3 ===============
Sound_SetBGMCh3_MuteCh3:
	xor  a
	ld   [sBGMCh3On], a
	xor  a
	ldh  [rNR30], a
	ld   [sBGMNR30], a
	jp   Sound_DoCurrentBGM_Ch4
; =============== Sound_SetBGMCh4_MuteCh4 ===============
Sound_SetBGMCh4_MuteCh4:
	xor  a
	ld   [sBGMCh4On], a
	ld   a, $08
	ldh  [rNR42], a
	ld   [sBGM_Unused_NR42Copy], a
	ld   a, $80
	ldh  [rNR44], a
	ld   [sBGM_Unused_CurChReg4Copy], a
	ret
; =============== Sound_ClearBGMRAM ===============
; Clears the area of SRAM dedicated to BGM playback.
Sound_ClearBGMRAM:
	push hl
	;--
	; Clear the RAM area at sBGMCurChArea-$A68B
	; (why not call ClearRAMRange_Mini instead?)
	;
	; ld   hl, sBGMCurChArea
	; ld   b, $2D
	; xor a
	; call ClearRAMRange_Mini
	;
	ld   hl, sBGMCurChArea					; HL = Starting address to clear.
	ld   a, [Sound_ClearBGMRAM_2D]	; A = $2D
	ld   b, a						; B = $2D
.loop:
	ld   [hl], $00		; Clear the byte
	inc  hl				; HL++
	dec  b				; BytesLeft--;
	ld   a, b			; (why)
	and  a				; (why)
	jr   nz, .loop		; Are there any bytes left? If so, loop
	;--
	pop  hl
	; Clear the registers and other BGM playback vars
	xor  a
	ld   [sBGMChSFX1], a
	ld   [sBGMChSFX2], a
	ld   [sBGMChSFX3], a ; [TCRF] This is the only place this gets set. It still gets checked and will mute BGM Ch3 if non-zero.
	ld   [sBGMChSFX4], a
	ld   [sBGMCh2PitchExtra], a
	ldh  [rNR10], a
	ldh  [rNR30], a
	ld   [sBGMAct], a
	ld   a, $08
	ldh  [rNR12], a
	ldh  [rNR22], a
	ldh  [rNR42], a
	ld   a, $80
	ldh  [rNR14], a
	ldh  [rNR24], a
	ldh  [rNR44], a
	ret
; =============== Sound_SFX1PtrTable ===============
; SFX logic assignment tables.
;
; Format:
; 2 Pointer tables in this order:
; - SFX Init code (for starting SFX playback)
; - SFX Next code (for continuing playback of a SFX)
;
; Each table is indexed by SFX ID.
; These kinds of table groups are also used for SFX2 and SFX4 and are in the very same format.
;
; Unlike BGMs, there's no header or sound format of any kind.
; What goes in the registers is directly determined by the SFX-specific code,
; which copy over raw register data depending on the decrementing SFX timer.
; Common helper functions exist to cut down on the code amount though.
;
; [TCRF] Some of the entries point to the same address, which is suspicious.

Sound_SFX1PtrTable: 
	dw SFX1_01_Init
	dw SFX1_02_Init
	dw SFX1_03_Init
	dw SFX1_04_Init
	dw SFX1_05_Init
	dw SFX1_06_Init
	dw SFX1_07_Init
	dw SFX1_08_Init
	dw SFX1_09_Init
	dw SFX1_0A_Init
	dw SFX1_0B_Init
	dw SFX1_0C_Init
	dw SFX1_0D_Init
	dw SFX1_0B_Init ; SFX1_Unused_GrabLoud_Init
	dw SFX1_0F_Init
	dw SFX1_10_Init
	dw SFX1_11_Init
	dw SFX1_12_Init
	dw SFX1_13_Init
	dw SFX1_14_Init
	dw SFX1_0A_Init
	dw SFX1_16_Init
	dw SFX1_17_Init
	dw SFX1_18_Init
	dw SFX1_19_Init
	dw SFX1_1A_Init
	dw SFX1_1B_Init
	dw SFX1_0C_Init
	dw SFX1_1D_Init
	dw SFX1_1E_Init
	dw SFX1_1F_Init
	dw SFX1_20_Init
	dw SFX1_21_Init
	dw SFX1_0C_Init
	dw SFX1_23_Init
	dw SFX1_24_Init
	dw SFX1_25_Init
	dw SFX1_26_Init
	dw SFX1_27_Init
	dw SFX1_28_Init
	dw SFX1_29_Init
	dw SFX1_2A_Init
	dw SFX1_2B_Init
	dw SFX1_2C_Init
	dw SFX1_2D_Init
	dw SFX1_2E_Init
	dw SFX1_2F_Init
	dw SFX1_30_Init
	dw SFX1_31_Init
	dw SFX1_32_Init
	dw SFX1_33_Init

Sound_SFX1NextPtrTable: 
	dw SFX1_01_Next
	dw SFX1_02_Next
	dw SFX1_03_Next
	dw SFX1_04_Next
	dw Sound_SFX1Next
	dw SFX1_06_Next
	dw SFX1_07_Next
	dw SFX1_08_Next
	dw SFX1_09_Next
	dw SFX1_0A_Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw SFX1_10_Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw SFX1_13_Next
	dw Sound_SFX1Next
	dw SFX1_0A_Next
	dw SFX1_16_Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw SFX1_1E_Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw Sound_SFX1Next
	dw SFX1_23_Next
	dw SFX1_24_Next
	dw SFX1_25_Next
	dw SFX1_26_Next
	dw SFX1_27_Next
	dw Sound_SFX1Next
	dw SFX1_29_Next
	dw SFX1_2A_Next
	dw SFX1_2B_Next
	dw SFX1_2C_Next
	dw SFX1_2B_Next
	dw SFX1_2B_Next
	dw SFX1_2F_Next
	dw SFX1_30_Next
	dw SFX1_29_Next
	dw SFX1_32_Next
	dw SFX1_29_Next

; =============== SFX1 Code & Data ===============
; SFX do not have a specific format.
; Each Each SFX defines its own timing loop.
; By convention these only play on one register, but there's nothing.
; preventing you to also use other sound registers (at the cost of sounding "off" when BGM cuts the sound off)
; ================================================
; SFX1 $01
SFX1_01_Init:
	ld   a, $0D
	ld   de, SFX1_010
	jp   Sound_SFX1Init
SFX1_01_Next:
	call Sound_DoSFX1Timer
	cp   a, $03
	ret  nz
	ld   de, SFX1_011
	jp   Sound_SetSFXCh1
SFX1_010: 
	db $2A
	db $00
	db $F7
	db $00
	db $86
SFX1_011: 
	db $15
	db $80
	db $57
	db $00
	db $86

; ================================================
; SFX1 $02
SFX1_02_Init:
	ld   a, $08
	ld   de, SFX1_020
	jp   Sound_SFX1Init
SFX1_02_Next:
	call Sound_DoSFX1Timer
	cp   a, $06
	ret  nz
	ld   de, SFX1_021
	jp   Sound_SetSFXCh1
SFX1_020: 
	db $15
	db $00
	db $C1
	db $00
	db $84
SFX1_021: 
	db $1D
	db $00
	db $C1
	db $D0
	db $87

; ================================================
; SFX1 $03
SFX1_03_Init:
	ld   a, $0E
	ld   de, SFX1_030
	jp   Sound_SFX1Init
SFX1_03_Next:
	call Sound_DoSFX1Timer
	cp   a, $0A
	jr   z, .set1
	cp   a, $03
	jr   z, .set2
	ret
.set1:
	ld   de, SFX1_031
	jp   Sound_SetSFXCh1
.set2:
	ld   de, SFX1_032
	jp   Sound_SetSFXCh1
SFX1_030:
	db $43
	db $80
	db $F7
	db $00
	db $87
SFX1_031:
	db $45
	db $80
	db $F7
	db $A2
	db $87
SFX1_032: 
	db $45
	db $80
	db $57
	db $A2
	db $87

; ================================================
; SFX1 $04
SFX1_04_Init:
	ld   a, $0F
	ld   de, SFX1_040
	jp   Sound_SFX1Init
SFX1_04_Next:
	call Sound_DoSFX1Timer
	cp   a, $0A
	jr   z, .set1
	cp   a, $03
	jr   z, .set2
	ret
.set1:
	ld   de, SFX1_041
	jp   Sound_SetSFXCh1
.set2:
	ld   de, SFX1_042
	jp   Sound_SetSFXCh1
SFX1_040: 
	db $5C
	db $80
	db $E7
	db $80
	db $87
SFX1_041: 
	db $45
	db $80
	db $87
	db $82
	db $87
SFX1_042: 
	db $45
	db $80
	db $57
	db $82
	db $87
; ================================================
; SFX1 $05
SFX1_05_Init:
	; Do not interrupt an existing Jump SFX
	call Sound_SFX1ChkRestartAndJumpSFXPriority
	ret  nz
	
	ld   a, $0B
	ld   de, SFX1_050
	jp   Sound_SFX1Init
SFX1_050: 
	db $15
	db $80
	db $84
	db $00
	db $82
; ================================================
; SFX1 $06
SFX1_06_Init:
	ld   a, $40
	ld   de, SFX1_060
	jp   Sound_SFX1Init
SFX1_06_Next:
	call Sound_DoSFX1Timer
	; To perform the pitch bend, this sets the channel frequency based off the timer.
	; As the timer gets close to 0, the pitch is set higher.
	cp   a, $38
	jr   z, .freq40
	cp   a, $30
	jr   z, .freq80
	cp   a, $28
	jr   z, .freqC0
	cp   a, $20
	jr   z, .freqFF
	ret
.freq40:
	ld   a, $40
	jr   .setFreq
.freq80:
	ld   a, $80
	jr   .setFreq
.freqC0:
	ld   a, $C0
	jr   .setFreq
.freqFF:
	ld   a, $FF
.setFreq:
	jp   Sound_SFX1SetFreq
SFX1_060:
	db $26
	db $80
	db $D1
	db $00
	db $86

; ================================================
; SFX1 $07
SFX1_07_Init:
	ld   a, $20
	ld   de, SFX1_070
	jp   Sound_SFX1Init
SFX1_07_Next:
	call Sound_DoSFX1Timer
	cp   a, $18
	jr   z, .set0
	cp   a, $10
	jr   z, .set0
	cp   a, $08
	jr   z, .set0
	ret
.set0:
	ld   de, SFX1_070
	jp   Sound_SetSFXCh1
SFX1_070:
	db $1C
	db $80
	db $D1
	db $00
	db $87
; ================================================
; SFX1 $08
SFX1_08_Init:
	ld   a, $30
	ld   de, SFX1_080
	jp   Sound_SFX1Init
SFX1_08_Next:
	call Sound_DoSFX1Timer
	cp   a, $28
	jr   z, .set1
	cp   a, $20
	jr   z, .set2
	cp   a, $18
	jr   z, .set3
	ret
.set1:
	ld   de, SFX1_081
	jp   Sound_SetSFXCh1
.set2:
	ld   de, SFX1_082
	jp   Sound_SetSFXCh1
.set3:
	ld   de, SFX1_083
	jp   Sound_SetSFXCh1
SFX1_080: 
	db $55
	db $80
	db $F5
	db $B5
	db $87
SFX1_081: 
	db $66
	db $80
	db $F5
	db $B5
	db $87
SFX1_082:
	db $55
	db $80
	db $F5
	db $B5
	db $87
SFX1_083: 
	db $66
	db $80
	db $85
	db $B5
	db $87
; ================================================
; SFX1 $09
SFX1_09_Init:
	; [TCRF] This address is never used anywhere else.
	;        The fact that this SFX is used specifically when a boss dies
	;        only raises further questions.
	ld   a, $D0
	ld   [sBossDeadSFXInit], a      
	;--
	call Sound_SFX1SetPitchBendMinus
	ld   a, $60
	ld   de, SFX1_090
	jp   Sound_SFX1Init
SFX1_09_Next:
	call Sound_DoSFX1Timer
	; Every frame from $60 to $2D, decrease the pitch
	cp   a, $2D							
	jp   nc, Sound_SFX1ApplyPitchBend
	cp   a, $28
	jp   z, .set1
	cp   a, $18
	jr   z, .set2
	ret
.set1:
	ld   de, SFX1_091
	jp   Sound_SetSFXCh1
.set2:
	ld   de, SFX1_092
	jp   Sound_SetSFXCh1
SFX1_090: 
	db $7F
	db $80
	db $A0
	db $D0
	db $87
SFX1_091: 
	db $37
	db $80
	db $C1
	db $83
	db $87
SFX1_092: 
	db $2D
	db $80
	db $C1
	db $C1
	db $87
; ================================================
; SFX1 $0A
SFX1_0A_Init:
	call Sound_SFX1ChkRestartAndJumpSFXPriority
	ret  nz
	ld   a, $20
	ld   de, SFX1_0A0
	jp   Sound_SFX1Init
SFX1_0A_Next:
	call Sound_DoSFX1Timer
	cp   a, $18
	jr   z, .set1
	cp   a, $10
	jr   z, .set2
	cp   a, $08
	jr   z, .set3
	ret
.set1:
	ld   de, SFX1_0A1
	jp   Sound_SetSFXCh1
.set2:
	ld   de, SFX1_0A2
	jp   Sound_SetSFXCh1
.set3:
	ld   de, SFX1_0A3
	jp   Sound_SetSFXCh1
SFX1_0A0: 
	db $1D
	db $AF
	db $E0
	db $90
	db $C7
SFX1_0A1: 
	db $1D
	db $AF
	db $E0
	db $90
	db $C7
SFX1_0A2: 
	db $1D
	db $AF
	db $60
	db $90
	db $C7
SFX1_0A3: 
	db $1D
	db $AF
	db $60
	db $90
	db $C7
; ================================================
; SFX1 $0B
SFX1_0B_Init:
	call Sound_SFX1ChkRestartAndJumpSFXPriority
	ret  nz
	ld   a, $08
	ld   de, SFX1_0B0
	jp   Sound_SFX1Init
SFX1_0B0:
	db $1D
	db $AF
	db $70
	db $90
	db $C7
; ================================================
; SFX1 $0D
SFX1_0D_Init:
	ld   a, $10
	ld   de, SFX1_0D0
	jp   Sound_SFX1Init
SFX1_0D0:
	db $1D
	db $00
	db $A3
	db $90
	db $87
; ================================================
; [TCRF] Unreferenced alternate actor grab SFX.
;        Likely the original slot for $0E.
;
;        While slot $0E is used, it points to a copy of $0B, the normal enemy grab SFX.        
;        This almost identical to $0B except it plays at a higher volume.
SFX1_Unused_GrabLoud_Init:
	ld   a, $10
	ld   de, SFX1_Unused_GrabLoud0
	jp   Sound_SFX1Init
SFX1_Unused_GrabLoud0:
	db $1D
	db $AF
	db $A0
	db $90
	db $C7
; ================================================
; SFX1 $0F
SFX1_0F_Init:
	ld   a, [sSFX1]
	cp   a, $21
	jr   z, .set0
	call Sound_SFX1ChkRestartAndJumpSFXPriority
	ret  nz
.set0:
	ld   a, $0A
	ld   de, SFX1_0F0
	jp   Sound_SFX1Init
SFX1_0F0:
	db $1E
	db $80
	db $97
	db $90
	db $87
; ================================================
; SFX1 $10
SFX1_10_Init:
	call Sound_SFX1SetPitchBend_05
	ld   a, $1C
	ld   de, SFX1_100
	jp   Sound_SFX1Init
SFX1_10_Next:
	call Sound_DoSFX1Timer
	cp   a, $18
	jr   z, .set1
	cp   a, $10
	jr   z, .setEnv
	jp   Sound_SFX1AlternatePitch
.set1:
	ld   de, SFX1_101
	jp   Sound_SetSFXCh1
.setEnv:
	ld   a, $57
	jp   Sound_SFX1SetEnv
SFX1_100:
	db $00
	db $B0
	db $87
	db $83
	db $C7
SFX1_101:
	db $00
	db $80
	db $F0
	db $A0
	db $87
; ================================================
; SFX1 $11
SFX1_11_Init:
	call Sound_SFX1ChkRestartAndJumpSFXPriority
	ret  nz
	ld   a, $03
	ld   de, SFX1_110
	jp   Sound_SFX1Init
SFX1_110: 
	db $14
	db $80
	db $63
	db $00
	db $85
; ================================================
; SFX1 $12
SFX1_12_Init:
	call Sound_SFX1ChkRestartAndJumpSFXPriority
	ret  nz
	ld   a, $02
	ld   de, SFX1_120
	jp   Sound_SFX1InitDIV_7F
SFX1_120: 
	db $16
	db $BD
	db $65
	db $50
	db $87
; ================================================
; SFX1 $13
SFX1_13_Init:
	call Sound_SFX1ChkRestartAndJumpSFXPriority
	ret  nz
	ld   a, $18
	ld   de, SFX1_130
	jp   Sound_SFX1Init
SFX1_13_Next:
	call Sound_DoSFX1Timer
	cp   a, $10
	ret  nz
	ld   de, SFX1_131
	jp   Sound_SetSFXCh1
SFX1_130:
	db $45
	db $00
	db $A7
	db $A0
	db $87
SFX1_131:
	db $00
	db $00
	db $53
	db $D0
	db $87
; ================================================
; SFX1 $14
SFX1_14_Init:
	ld   a, $0A
	ld   de, SFX1_140
	jp   Sound_SFX1Init
SFX1_140:
	db $3C
	db $80
	db $C2
	db $80
	db $87
; ================================================
; SFX1 $16
SFX1_16_Init:
	ld   a, $20
	ld   de, SFX1_160
	jp   Sound_SFX1Init
SFX1_16_Next:
	call Sound_DoSFX1Timer
	cp   a, $1E
	jr   z, .set1
	cp   a, $1C
	jr   z, .set2
	cp   a, $1A
	jr   z, .set3
	cp   a, $18
	jr   z, .set4
	cp   a, $14
	jr   z, .set5
	cp   a, $10
	jr   z, .set6
	ret
.set1:
	ld   de, SFX1_161
	jp   Sound_SetSFXCh1
.set2:
	ld   de, SFX1_162
	jp   Sound_SetSFXCh1
.set3:
	ld   de, SFX1_163
	jp   Sound_SetSFXCh1
.set4:
	ld   de, SFX1_164
	jp   Sound_SetSFXCh1
.set5:
	ld   de, SFX1_165
	jp   Sound_SetSFXCh1
.set6:
	ld   de, SFX1_166
	jp   Sound_SetSFXCh1
SFX1_160:  
	db $15
	db $80
	db $A7
	db $A0
	db $85
SFX1_161:  
	db $15
	db $80
	db $C7
	db $C0
	db $85
SFX1_162:  
	db $15
	db $80
	db $D7
	db $F0
	db $85
SFX1_163:  
	db $15
	db $80
	db $E7
	db $10
	db $86
SFX1_164: 
	db $1E
	db $80
	db $F3
	db $C0
	db $87
SFX1_165: 
	db $1E
	db $80
	db $A3
	db $C0
	db $87
SFX1_166: 
	db $1E
	db $80
	db $63
	db $C0
	db $87
; ================================================
; SFX1 $17
SFX1_17_Init:
	ld   a, $06
	ld   de, SFX1_170
	jp   Sound_SFX1InitDIV_1F
SFX1_170:
	db $34
	db $80
	db $63
	db $A0
	db $86
; ================================================
; SFX1 $18
SFX1_18_Init:
	ld   a, $06
	ld   de, SFX1_180
	jp   Sound_SFX1InitDIV_7F
SFX1_180:
	db $37
	db $80
	db $74
	db $80
	db $86
; ================================================
; SFX1 $19
SFX1_19_Init:
	ld   a, $06
	ld   de, SFX1_190
	jp   Sound_SFX1InitDIV_1F
SFX1_190:
	db $3F
	db $80
	db $75
	db $00
	db $86
; ================================================
; SFX1 $1A
SFX1_1A_Init:
	ld   a, $10
	ld   de, SFX1_1A0
	jp   Sound_SFX1InitDIV_1F
SFX1_1A0:
	db $46
	db $00
	db $47
	db $00
	db $87
; ================================================
; SFX1 $1B
SFX1_1B_Init:
	ld   a, $30
	ld   de, SFX1_1B0
	jp   Sound_SFX1Init
SFX1_1B0:
	db $6F
	db $00
	db $75
	db $00
	db $87
; ================================================
; SFX1 $0C
SFX1_0C_Init:
	ld   a, $06
	ld   de, SFX1_0C0
	jp   Sound_SFX1InitDIV_7F
SFX1_0C0:
	db $2C
	db $80
	db $A1
	db $80
	db $86
; ================================================
; SFX1 $1D
SFX1_1D_Init:
	ld   a, $10
	ld   de, SFX1_1D0
	jp   Sound_SFX1InitDIV_1F
SFX1_1D0:
	db $7F
	db $80
	db $74
	db $00
	db $87
; ================================================
; SFX1 $1E
SFX1_1E_Init:
	ld   a, $38
	ld   de, SFX1_1E0
	jp   Sound_SFX1Init
SFX1_1E_Next:
	call Sound_DoSFX1Timer
	cp   a, $28
	ret  nz
	ld   de, SFX1_1E1
	jp   Sound_SetSFXCh1
SFX1_1E0:
	db $15
	db $00
	db $A7
	db $00
	db $83
SFX1_1E1:
	db $4F
	db $80
	db $A7
	db $80
	db $86
; ================================================
; SFX1 $1F
SFX1_1F_Init:
	ld   a, $40
	ld   de, SFX1_1F0
	jp   Sound_SFX1Init
SFX1_1F0:
	db $1F
	db $80
	db $0C
	db $FF
	db $87
; ================================================
; SFX1 $20
SFX1_20_Init:
	call Sound_SFX1ChkRestartAndJumpSFXPriority
	ret  nz
	ld   a, $04
	ld   de, SFX1_200
	jp   Sound_SFX1InitDIV_7F
SFX1_200:
	db $24
	db $80
	db $83
	db $80
	db $86
; ================================================
; SFX1 $21
SFX1_21_Init:
	call Sound_SFX1ChkRestartAndJumpSFXPriority
	ret  nz
	ld   a, $03
	ld   de, SFX1_210
	jp   Sound_SFX1InitDIV_7F
SFX1_210:
	db $2A
	db $00
	db $77
	db $00
	db $86
; ================================================
; SFX1 $23
SFX1_23_Init:
	ld   a, $0C
	ld   de, SFX1_230
	jp   Sound_SFX1Init
SFX1_23_Next:
	call Sound_DoSFX1Timer
	cp   a, $08
	ret  nz
	ld   a, $57
	jp   Sound_SFX1SetEnv
SFX1_230:
	db $55
	db $80
	db $A7
	db $80
	db $87
; ================================================
; SFX1 $24
SFX1_24_Init:
	ld   a, $30
	ld   de, SFX1_240
	jp   Sound_SFX1Init
SFX1_24_Next:
	call Sound_DoSFX1Timer
	cp   a, $2C
	jr   z, .freq40
	cp   a, $28
	jr   z, .freq80
	cp   a, $24
	jr   z, .freqC0
	cp   a, $20
	jr   z, .playSfx2
	cp   a, $1A
	jp   z, SFX1_26_Next1
	ret
.freq40:
	ld   a, $40
	jp   Sound_SFX1SetFreq
.freq80:
	ld   a, $80
	jp   Sound_SFX1SetFreq
.freqC0:
	ld   a, $C0
	jp   Sound_SFX1SetFreq
.freqFF:
	; [TCRF] Unreferenced frequency option
	ld   a, $FF
	jp   Sound_SFX1SetFreq
.playSfx2:
	ld   de, SFX1_100
	call Sound_SetSFXCh1
	; As this ends like the 10coin SFX, also
	; play the final SFX2 part.
	ld   a, SFX2_02
	ld   [sSFX2Set], a
	ret
SFX1_240:
	db $33
	db $80
	db $F3
	db $00
	db $85
; ================================================
; SFX1 $25
SFX1_25_Init:
	ld   a, $24
	ld   de, SFX1_250
	jp   Sound_SFX1Init
SFX1_25_Next:
	call Sound_DoSFX1Timer
	cp   a, $20
	jr   z, .freqC0
	cp   a, $1C
	jr   z, .freq80
	cp   a, $18
	jr   z, .freq40
	cp   a, $14
	jr   z, .freq00
	cp   a, $10
	jr   z, .set1
	ret
.freqC0:
	ld   a, $C0
	jp   Sound_SFX1SetFreq
.freq80:
	ld   a, $80
	jp   Sound_SFX1SetFreq
.freq40:
	ld   a, $40
	jp   Sound_SFX1SetFreq
.freq00:
	ld   a, $00
	jp   Sound_SFX1SetFreq
.set1:
	ld   de, SFX1_251
	jp   Sound_SetSFXCh1
SFX1_250:
	db $26
	db $80
	db $D1
	db $FF
	db $86
SFX1_251:
	db $3B
	db $80
	db $F1
	db $00
	db $86
; ================================================
; SFX1 $26
SFX1_26_Init:
	ld   a, $1E
	ld   de, SFX1_260
	jp   Sound_SFX1Init
SFX1_26_Next:
	call Sound_DoSFX1Timer
	cp   a, $1C
	ret  nz
	ld   a, SFX2_02
	ld   [sSFX2Set], a
SFX1_26_Next1:
	ld   de, SFX1_261
	jp   Sound_SetSFXCh1
SFX1_260:
	db $00
	db $80
	db $F7
	db $81
	db $87
SFX1_261:
	db $00
	db $80
	db $F3
	db $9E
	db $87
; ================================================
; SFX1 $27
SFX1_27_Init:
	ld   a, $70
	ld   de, SFX1_Blank
	jp   Sound_SFX1Init
SFX1_27_Next:
	call Sound_DoSFX1Timer
	cp   a, $50
	jr   z, .set0
	cp   a, $20
	jr   z, .set1
	ret
.set0:;R
	ld   de, SFX1_270
	jp   Sound_SetSFXCh1
.set1:;R
	ld   de, SFX1_271
	jp   Sound_SetSFXCh1
SFX1_270:
	db $77
	db $80
	db $1C
	db $50
	db $86
SFX1_271:	
	db $7F
	db $80
	db $A5
	db $00
	db $87
; ================================================
; SFX1 $28
SFX1_28_Init:
	call Sound_SFX1ChkRestartAndJumpSFXPriority
	ret  nz
	ld   a, $08
	ld   de, SFX1_280
	jp   Sound_SFX1InitDIV_1F
SFX1_280:
	db $22
	db $80
	db $A7
	db $00
	db $83
; ================================================
; SFX1 $29
SFX1_29_Init:
	call Sound_SFX1ChkRestartAndJumpSFXPriority
	ret  nz
	call Sound_SFX1SetPitchBendMinus
	ld   a, $20
	ld   de, SFX1_290
	jp   Sound_SFX1InitDIV_1F
SFX1_290:
	db $00
	db $80
	db $83
	db $A0
	db $87
; ================================================
; SFX1 $2A
SFX1_2A_Init:
	call Sound_StopChannels
	ld   a, SFX2_05
	ld   [sSFX2Set], a
	ld   a, $2C
	ld   de, SFX1_2A0
	jp   Sound_SFX1Init
SFX1_2A_Next:
	call Sound_DoSFX1Timer
	cp   a, $1C
	jr   z, .set0
	cp   a, $0C
	jr   z, .set0
	ret
.set0:
	ld   de, SFX1_2A0
	jp   Sound_SetSFXCh1
SFX1_2A0:
	db $00
	db $40
	db $F1
	db $AA
	db $87
; ================================================
; SFX1 $2B
SFX1_2B_Init:
	call Sound_SFX1SetPitchBend_05
	ld   a, $60
	ld   de, SFX1_2B0
	jp   Sound_SFX1Init
SFX1_2B0:
	db $00
	db $40
	db $F7
	db $FF
	db $86
; ================================================
; SFX1 $2C
SFX1_2C_Init:
	ld   a, $30
	ld   de, SFX1_2C0
	call Sound_SFX1Init
	; Initial frequency should be pseudo random
	ldh  a, [rDIV]
	swap a				
	set  7, a	; But still loud enough
	set  6, a	
	set  5, a
	res  1, a
	ld   [sSFXNR13], a
	ret
SFX1_2C_Next:
	; - Increase freq for $10 frames by $06
	; - Decrease freq for $20 frames by $01
	call Sound_DoSFX1Timer
	cp   a, $20				; Is the SFX timer < $20?
	jr   c, .decFreq		; If so, reduce the frequency
.addFreq:
	ld   a, [sSFXNR13]
	add  $06
	jr   .setFreq
.decFreq:
	ld   a, [sSFXNR13]
	dec  a
.setFreq:
	ldh  [rNR13], a
	ld   [sSFXNR13], a
	ret
SFX1_2C0:
	db $5F
	db $00
	db $C6
	db $F0
	db $87
; ================================================
; SFX1 $2D
SFX1_2D_Init:
	call Sound_SFX1SetPitchBend_05
	ld   a, $20
	ld   de, SFX1_2D0
	jp   Sound_SFX1Init
SFX1_2D0:
	db $00
	db $80
	db $76
	db $FF
	db $87
; ================================================
; SFX1 $2E
SFX1_2E_Init:
	call Sound_SFX1SetPitchBend_05
	ld   a, $28
	ld   de, SFX1_2E0
	jp   Sound_SFX1Init
SFX1_2E0:
	db $00
	db $40
	db $A4
	db $00
	db $86
; ================================================
; SFX1 $2F
SFX1_2F_Init:
	; Always override the bomb grab SFX
	ld   a, [sSFX1]		
	cp   a, $29
	jr   z, .init		
	
	call Sound_SFX1ChkRestartAndJumpSFXPriority
	ret  nz
.init:
	ld   a, $10
	ld   de, SFX1_2F0
	jp   Sound_SFX1Init
SFX1_2F_Next:
	call Sound_DoSFX1Timer
	cp   a, $03
	ret  nz
.set1:
	ld   de, SFX1_2F1
	jp   Sound_SetSFXCh1
SFX1_2F0:
	db $1A
	db $A0
	db $F1
	db $00
	db $C6
SFX1_2F1:
	db $14
	db $60
	db $D7
	db $00
	db $C6
; ================================================
; SFX1 $30
SFX1_30_Init:
	ld   a, SFX2_06
	ld   [sSFX2Set], a
	ld   a, $38
	ld   de, SFX1_300
	jp   Sound_SFX1Init
SFX1_30_Next:
	call Sound_DoSFX1Timer
	cp   a, $30
	ret  nz
	ld   de, SFX1_301
	jp   Sound_SetSFXCh1
SFX1_300:
	db $00
	db $80
	db $F1
	db $70
	db $87
SFX1_301:
	db $00
	db $40
	db $F3
	db $90
	db $87
; ================================================
; SFX1 $31
SFX1_31_Init:
	call Sound_SFX1ChkRestartAndJumpSFXPriority
	ret  nz
	call Sound_SFX1SetPitchBendPlus
	ld   a, $20
	ld   de, SFX1_310
	jp   Sound_SFX1InitDIV_1F
SFX1_310:
	db $00
	db $80
	db $75
	db $A0
	db $87
; ================================================
; SFX1 $32
SFX1_32_Init:
	call Sound_SFX1SetPitchBend_05
	ld   de, SFX1_320
	jp   Sound_SFX1InitDIV_1F
SFX1_32_Next:
	ld   a, [sSFX1Len]
	and  a
	jr   z, .sfxEnd
	
	dec  a					; Length--;
	ld   [sSFX1Len], a
	ld   a, [sSFX1DivFreq]	; Frequency -= 3;
	sub  a, $03
	ld   [sSFX1DivFreq], a
	ldh  [rNR13], a
	ld   [sSFXNR13], a
	ret
.sfxEnd:
	; When the timer expires, pick a new length and frequency high value.
	ldh  a, [rDIV]			; Pick new base freq
	swap a
	ld   [sSFX1DivFreq], a
	and  a, $1F				; Generate length and upper volume frequency bits from it
	ld   [sSFX1Len], a
	ld   a, [sSFXNR14]
	; Restart the sound
	set  7, a
	ldh  [rNR14], a
	ret
SFX1_320:
	db $36
	db $80
	db $83
	db $00
	db $85
; ================================================
; SFX1 $33
SFX1_33_Init:
	call Sound_SFX1SetPitchBendPlus
	ld   a, $1C
	ld   [sSFX1FreqOffset], a
	ld   a, $50
	ld   de, SFX1_330
	jp   Sound_SFX1InitDIV_1F
SFX1_330:
	db $00
	db $80
	db $A7
	db $00
	db $85
; =============== Utility subroutines for SFX1 ===============
; =============== Sound_SFX1Init ===============
; Default SFX1 initializer.
; Starts the specified sound effect on channel 1.
; IN:
; - A: Sound length
; - DE: Ptr to raw channel 1 data
Sound_SFX1Init:
	ld   [sSFX1Len], a
	ld   a, [sSFX1Set]
	ld   [sSFX1], a
	ld   [sBGMChSFX1], a
	jp   Sound_SetSFXCh1
; =============== Sound_SFX1Next ===============
; Default handler for continuing SFX1 playback.
; If called directly from the ptr table, it will keep playing the SFX
; with the same settings until its timer runs out.
Sound_SFX1Next:
	jp   Sound_DoSFX1Timer
	
; =============== Sound_SFX1SetPitchBendPlus ===============
; Sets up an upwards SFX1 pitch bend progressively increasing frequency by 1.
Sound_SFX1SetPitchBendPlus:
	ld   a, $80						
	jr   Sound_SFX1SetPitchBend
	
; =============== Sound_SFX1SetPitchBendMinus ===============
; Sets up a downwards SFX1 pitch bend progressively decreasing frequency by 1.
Sound_SFX1SetPitchBendMinus:
	xor  a		

; =============== Sound_SFX1SetPitchBend ===============
; IN
;	-A: High byte of the pitch bend indicator. Always $80 or $00.
;       MSB Set -> Upwards pitch bend
;       MSB Clr -> Downwards pitch bend
Sound_SFX1SetPitchBend:
	ld   [sSFX1FreqOffsetHigh], a ; contains both offset and type
	ld   a, $01
	ld   [sSFX1FreqOffset], a
	ret
	
; =============== Sound_SFX1SetPitchBendPlus ===============
; Sets up an pitch bend progressively changing frequency by 5.
; Pitch direction isn't specified here.
Sound_SFX1SetPitchBend_05:
	ld   a, $05
	ld   [sSFX1FreqOffset], a
	ret
	
; =============== Sound_SFX1ChkRestartAndJumpSFXPriority ===============
; Checks if the requested SFX1 can be started.
;
; OUT
; - A: If the requested SFX1 should be started
Sound_SFX1ChkRestartAndJumpSFXPriority:
	; Restarting the same SFX should be ignored
	ld   a, [sSFX1Set]	
	ld   b, a			; B = Requested SFX
	ld   a, [sSFX1]
	cp   a, b			; Is it the same as the currently playing SFX?
	ret  z				; If not, return 0
	
	; Prevent jump sfx from being interrupted
	ld   a, [sSFX1]		; Is the jump SFX currently playing?
	cp   a, SFX1_05
	jr   nz, .allowPlay	; If not, allow playback
	and  a, $00
	ret
.allowPlay:
	and  a
	ret
	
; =============== Sound_SFX1InitDIV_1F ===============
Sound_SFX1InitDIV_1F:
	call Sound_SFX1Init
	jp   Sound_SFX1PitchFromDIV_1F
; =============== Sound_SFX1InitDIV_7F ===============
Sound_SFX1InitDIV_7F:
	call Sound_SFX1Init
	jp   Sound_SFX1PitchFromDIV_7F
	
SFX1_Blank:
	db $00
	db $00
	db $00
	db $00
	db $00

; =============== Sound_SFX2PtrTable ===============
; SFX2 assignment tables.
; See Sound_SFX1PtrTable for more info.
Sound_SFX2PtrTable:
	dw SFX2_01_Init
	dw SFX2_02_Init
	dw SFX2_03_Init
	dw SFX2_04_Init
	dw SFX2_05_Init
	dw SFX2_06_Init
Sound_SFX2NextPtrTable:
	dw SFX2_01_Next
	dw SFX2_02_Next
	dw SFX2_03_Next
	dw SFX2_04_Next
	dw SFX2_05_Next
	dw SFX2_06_Next
; =============== SFX2 Code & Data ===============
; ================================================
; SFX2 $01
SFX2_01_Init:
	ld   a, $20
	ld   de, SFX2_010
	jp   Sound_SFX2Init
SFX2_01_Next:
	call Sound_DoSFX2Timer
	cp   a, $10
	ret  nz
	ld   de, SFX2_010
	jp   Sound_SetSFXCh2
SFX2_010:
	db $90
	db $F0
	db $80
	db $C4
; ================================================
; SFX2 $02
SFX2_02_Init:
	ld   a, [sBGM]
	cp   a, BGM_SHERBETLAND		; SherbetLand music playing? (we're in the ending)
	jr   z, .endingTotal		; If so, jump
.norm:
	ld   a, $28
	ld   de, SFX2_020
	jp   Sound_SFX2Init
.endingTotal:
	; Special case when decrementing the coin total in the ending
	;--
	; Every other frame, increase the frequency until it reaches value $DB 
	ld   a, [sSFX2CoinTimer]	; timer update
	inc  a
	ld   [sSFX2CoinTimer], a	
	bit  0, a					; is this an even frame?
	jr   z, .set1				; if so, skip the increase
	
	ld   a, [sSFX2CoinFreq]		; Has the frequency reached the target value?
	cp   a, $D8					
	jr   nc, .set1				; If so, stop increasing it
	
	inc  a
	ld   [sSFX2CoinFreq], a
	;--
.set1:
	; Play set1 with the frequency value from CoinFreq
	ld   a, $28
	ld   de, SFX2_021
	call Sound_SFX2Init
	jp   Sound_SFX2ApplyCoinFreq
SFX2_02_Next:
	call Sound_DoSFX2Timer
	cp   a, $26
	jr   z, .set2
	cp   a, $24
	jr   z, .set3
	ret
.set2:
	ld   de, SFX2_022
	jp   Sound_SetSFXCh2
.set3:
	xor  a
	ld   [sSFX2CoinFreq], a
	ld   de, SFX2_023
	jp   Sound_SetSFXCh2
SFX2_020:
	db $BA
	db $61
	db $80
	db $C7
SFX2_021:
	db $BA
	db $61
	db $00
	db $C7
SFX2_022:
	db $80
	db $A7
	db $80
	db $87
SFX2_023:
	db $80
	db $F3
	db $9D
	db $87
; ================================================
; SFX2 $03
SFX2_03_Init:
	ld   a, $20
	ld   de, SFX2_030
	jp   Sound_SFX2Init
SFX2_03_Next:
	call Sound_DoSFX2Timer
	cp   a, $18
	ret  nz
	ld   de, SFX2_031
	jp   Sound_SetSFXCh2
SFX2_030:
	db $80
	db $F0
	db $9D
	db $87
SFX2_031:
	db $80
	db $50
	db $9D
	db $87
; ================================================
; SFX2 $04
SFX2_04_Init:
	ld   a, $20
	ld   de, SFX2_040
	jp   Sound_SFX2Init
SFX2_04_Next:
	call Sound_DoSFX2Timer
	cp   a, $18
	ret  nz
	ld   de, SFX2_041
	jp   Sound_SetSFXCh2
SFX2_040:
	db $80
	db $F0
	db $B6
	db $87
SFX2_041:
	db $80
	db $57
	db $B6
	db $87
; ================================================
; SFX2 $05
SFX2_05_Init:
	ld   a, $2C
	ld   de, SFX2_050
	jp   Sound_SFX2Init
SFX2_05_Next:
	call Sound_DoSFX2Timer
	cp   a, $1C
	jr   z, .set0
	cp   a, $0C
	jr   z, .set0
	ret
.set0:
	ld   de, SFX2_050
	jp   Sound_SetSFXCh2
SFX2_050:
	db $40
	db $F1
	db $A9
	db $87
; ================================================
; SFX2 $06
SFX2_06_Init:
	ld   a, $38
	ld   de, SFX2_060
	jp   Sound_SFX2Init
SFX2_06_Next:
	call Sound_DoSFX2Timer
	cp   a, $30
	ret  nz
	ld   de, SFX2_061
	jp   Sound_SetSFXCh2
SFX2_060:
	db $80
	db $F1
	db $90
	db $87
SFX2_061:
	db $00
	db $F3
	db $91
	db $87
; =============== Utility subroutines for SFX2 ===============
; =============== Sound_SFX2Init ===============
; Default SFX2 initializer.
; Starts the specified sound effect on channel 2.
; IN:
; - A: Sound length
; - DE: Ptr to raw channel 2 data
Sound_SFX2Init:
	ld   [sSFX2Len], a
	ld   a, [sSFX2Set]
	ld   [sSFX2], a
	ld   [sBGMChSFX2], a
	jp   Sound_SetSFXCh2

; =============== Sound_SFX2Next ===============
; [TCRF] This just happens to never be called.
;
; Default handler for continuing SFX2 playback.
; If called directly from the ptr table, it will keep playing the SFX
; with the same settings until its timer runs out.
Sound_SFX2Next:
	jp   Sound_DoSFX2Timer
	
; =============== Sound_SFX2ApplyCoinFreq ===============
; Code specific to SFX2_02 for setting the frequency based off a timer.
Sound_SFX2ApplyCoinFreq:
	ld   a, [sSFX2CoinFreq]
	ld   [sSFXNR23], a
	ldh  [rNR23], a
	ret
	
; =============== Sound_SFX4PtrTable ===============
; SFX4 assignment tables.
; See Sound_SFX1PtrTable for more info.
;
; [TCRF] Some entries in the init table point to the same address,
;        while others are outright unused.
Sound_SFX4PtrTable:
	dw SFX4_01_Init 
	dw SFX4_02_Init 
	dw SFX4_03_Init 
	dw SFX4_04_Init 
	dw SFX4_05_Init 
	dw SFX4_05_Init ; copy for convenience
	dw SFX4_04_Init ; copy for convenience
	dw SFX4_08_Init
	dw SFX4_09_Init 
	dw SFX4_0A_Init 
	dw SFX4_0B_Init 
	dw SFX4_0C_Init
	dw SFX4_0D_Init
	dw SFX4_0E_Init
	dw SFX4_0F_Init
	dw SFX4_10_Init
	dw SFX4_11_Init
	dw SFX4_12_Init
	dw SFX4_13_Init
	dw SFX4_14_Init
	dw SFX4_15_Init
	dw SFX4_16_Init
	dw SFX4_17_Init
	dw SFX4_18_Init
	dw SFX4_19_Init
	dw SFX4_Unused_1A_Init
	dw SFX4_Unused_1B_Init
; ------
Sound_SFX4NextPtrTable:
	dw SFX4_01_Next
	dw SFX4_02_Next
	dw SFX4_03_Next
	dw Sound_SFX4Next
	dw Sound_SFX4Next
	dw Sound_SFX4Next
	dw Sound_SFX4Next
	dw Sound_SFX4Next
	dw Sound_SFX4Next
	dw SFX4_0A_Next
	dw SFX4_0B_Next
	dw SFX4_0C_Next
	dw SFX4_0D_Next
	dw SFX4_0E_Next
	dw SFX4_0F_Next
	dw Sound_SFX4Next
	dw Sound_SFX4Next
	dw SFX4_12_Next
	dw Sound_SFX4Next
	dw Sound_SFX4Next
	dw Sound_SFX4Next
	dw Sound_SFX4Next;X
	dw SFX4_17_Next
	dw Sound_SFX4Next
	dw Sound_SFX4Next
	dw Sound_SFX4Next;X
	dw Sound_SFX4Next;X

; =============== SFX4 Code & Data ===============

; ================================================
; SFX4 $01
SFX4_01_Init:
	ld   a, $38
	ld   de, SFX4_010
	jp   Sound_SFX4Init
	
SFX4_01_Next:
	; Stop the SFX when the dash stops
	ld   a, [sPlGroundDashTimer]
	and  a
	jp   z, Sound_StopSFX4
	; Depending on how many dash frames are left, play the appropriate sfx chunk
	call Sound_DoSFX4Timer
	cp   a, $34
	jr   z, .set1
	cp   a, $30
	jr   z, .set0
	cp   a, $2C
	jr   z, .set2
	cp   a, $28
	jr   z, .set0
	cp   a, $24
	jr   z, .set3
	cp   a, $20
	jr   z, .set0
	cp   a, $1C
	jr   z, .set4
	cp   a, $18
	jr   z, .set0
	cp   a, $14
	jr   z, .set3
	cp   a, $11
	jr   z, .set5
	ret
.set0:
	ld   de, SFX4_010
	jp   Sound_SetSFXCh4
.set1:
	ld   de, SFX4_011
	jp   Sound_SetSFXCh4
.set2:
	ld   de, SFX4_012
	jp   Sound_SetSFXCh4
.set3:
	ld   de, SFX4_013
	jp   Sound_SetSFXCh4
.set4:
	ld   de, SFX4_014
	jp   Sound_SetSFXCh4
.set5:
	ld   de, SFX4_015
	jp   Sound_SetSFXCh4
SFX4_010:
	db $00
	db $39
	db $4C
	db $80
SFX4_011: 
	db $00
	db $92
	db $23
	db $80
SFX4_012: 
	db $00
	db $92
	db $22
	db $80
SFX4_013: 
	db $00
	db $C2
	db $21
	db $80
SFX4_014: 
	db $00
	db $C2
	db $20
	db $80
SFX4_015: 
	db $20
	db $59
	db $40
	db $C0
	
; ================================================
; SFX4 $02
SFX4_02_Init:
	; Don't play the SFX is the cling sfx is currently playing
	ld   a, [sSFX4]
	cp   a, SFX4_0E
	ret  z
	
	ld   a, $28
	ld   de, SFX4_021
	jp   Sound_SFX4Init
	
SFX4_02_Next:
	call Sound_DoSFX4Timer
	cp   a, $20
	jr   z, .set1
	cp   a, $18
	jr   z, .set0
	cp   a, $10
	jr   z, .set1
	cp   a, $08
	jr   z, .set0
	ret
.set1:
	ld   de, SFX4_021
	jp   Sound_SetSFXCh4
.set0:
	ld   de, SFX4_020
	jp   Sound_SetSFXCh4
SFX4_020:
	db $00
	db $19
	db $22
	db $80
SFX4_021:
	db $00
	db $F1
	db $55
	db $80
	
; ================================================
; SFX4 $03
SFX4_03_Init:
	ld   a, $28
	ld   de, SFX4_031
	jp   Sound_SFX4Init
SFX4_03_Next:
	call Sound_DoSFX4Timer
	cp   a, $20
	jr   z, .set1
	cp   a, $18
	jr   z, .set0
	cp   a, $10
	jr   z, .set2
	ret
.set1:
	ld   de, SFX4_031
	jp   Sound_SetSFXCh4
.set0:
	ld   de, SFX4_030
	jp   Sound_SetSFXCh4
.set2:
	ld   de, SFX4_032
	jp   Sound_SetSFXCh4
SFX4_030:
	db $00
	db $18
	db $22
	db $80
SFX4_031:
	db $00
	db $F2
	db $55
	db $80
SFX4_032:
	db $00
	db $38
	db $55
	db $80
; ================================================
; SFX4 $04
SFX4_04_Init:
	; should kill itself if (for some reason) the dash sfx is playing
	ld   a, [sSFX4]
	cp   a, $01
	ret  z
	
	ld   a, [sPlAction]	; Is the player swimming?
	cp   a, PL_ACT_SWIM
	jr   z, .setWater		; If so, use the underwater stream set
	
	ld   a, $20
	ld   de, SFX4_040
	jp   Sound_SFX4Init
.setWater:
	ld   a, $20
	ld   de, SFX4_041
	jp   Sound_SFX4Init
SFX4_040:
	db $00
	db $D4
	db $66
	db $80
SFX4_041:	
	db $00
	db $C4
	db $7E
	db $80
; ================================================
; SFX4 $05
SFX4_05_Init:
	ld   a, [sPlAction]
	cp   a, PL_ACT_SWIM
	jr   z, .setWater
	
	ld   a, $20
	ld   de, SFX4_050
	jp   Sound_SFX4Init
.setWater:
	ld   a, $20
	ld   de, SFX4_051
	jp   Sound_SFX4Init
SFX4_050:
	db $00
	db $F3
	db $02
	db $80
SFX4_051:
	db $00
	db $C7
	db $7C
	db $80
; ================================================
; SFX4 $08
SFX4_08_Init:
	
	call Sound_SFX4IsOtherPlaying
	ret  nz
	
	ld   a, $01
	ld   de, SFX4_080
	jp   Sound_SFX4Init
SFX4_080:
	db $00
	db $71
	db $54
	db $80
; ================================================
; SFX4 $09
SFX4_09_Init:
	call Sound_SFX4IsOtherPlaying
	ret  nz
	ld   a, $01
	ld   de, SFX4_090
	jp   Sound_SFX4Init
SFX4_090:
	db $00
	db $41
	db $51
	db $80
; ================================================
; SFX4 $0A
SFX4_0A_Init:
	ld   a, $07
	ld   de, SFX4_0B0
	jp   Sound_SFX4Init
SFX4_0A_Next:
	call Sound_DoSFX4Timer
	cp   a, $04
	jr   z, .set0
	ret
.set0:
	ld   de, SFX4_0A0
	jp   Sound_SetSFXCh4
SFX4_0A0:
	db $37
	db $67
	db $5B
	db $C0
; ================================================
; SFX4 $0B
SFX4_0B_Init:
	ld   a, $1C
	ld   de, SFX4_0B0
	jp   Sound_SFX4Init
SFX4_0B_Next:
	call Sound_DoSFX4Timer
	cp   a, $18
	jr   z, .set0
	cp   a, $14
	jr   z, .set1
	ret
.set0:
	ld   de, SFX4_0B0
	jp   Sound_SetSFXCh4
.set1:
	ld   de, SFX4_0B1
	jp   Sound_SetSFXCh4
SFX4_0B0:
	db $3A
	db $E7
	db $4A
	db $C0
SFX4_0B1:
	db $00
	db $C2
	db $12
	db $80
; ================================================
; SFX4 $0C
SFX4_0C_Init:
	call Sound_SFX4IsOtherPlaying
	ret  nz
	ld   a, SFX1_12
	ld   [sSFX1Set], a
	ld   a, $20
	ld   de, SFX4_0C0
	jp   Sound_SFX4Init
SFX4_0C_Next:
	call Sound_DoSFX4Timer
	cp   a, $1C
	jr   z, .set1
	ret
.set1:
	ld   de, SFX4_0C1
	jp   Sound_SetSFXCh4
SFX4_0C0:
	db $00
	db $47
	db $43
	db $80
SFX4_0C1:
	db $00
	db $63
	db $64
	db $80
; ================================================
; SFX4 $0D
SFX4_0D_Init:
	call Sound_SFX4IsOtherPlaying
	ret  nz
	ld   a, SFX1_12
	ld   [sSFX1Set], a
	ld   a, $20
	ld   de, SFX4_0D0
	jp   Sound_SFX4Init
SFX4_0D_Next:
	call Sound_DoSFX4Timer
	cp   a, $1C
	jr   z, .set1
	ret
.set1:
	ld   de, SFX4_0D1
	jp   Sound_SetSFXCh4
SFX4_0D0:
	db $00
	db $47
	db $44
	db $80
SFX4_0D1:
	db $00
	db $44
	db $22
	db $80
; ================================================
; SFX4 $0E
SFX4_0E_Init:
	ld   a, SFX1_13
	ld   [sSFX1Set], a
	ld   a, $08
	ld   de, SFX4_0E0
	jp   Sound_SFX4Init
SFX4_0E_Next:
	call Sound_DoSFX4Timer
	cp   a, $04
	jr   z, .set1
	ret
.set1:
	ld   de, SFX4_0E1
	jp   Sound_SetSFXCh4
SFX4_0E0:
	db $00
	db $F7
	db $55
	db $80
SFX4_0E1:
	db $00
	db $A7
	db $33
	db $80
; ================================================
; SFX4 $0F
SFX4_0F_Init:
	ld   a, $98
	ld   de, SFX4_0F0
	jp   Sound_SFX4Init
SFX4_0F_Next:
	call Sound_DoSFX4Timer
	cp   a, $90
	jr   z, .set1
	cp   a, $88
	jr   z, .set2
	cp   a, $80
	jr   z, .set3
	cp   a, $40
	jr   z, .set4
	ret
.set1:
	ld   de, SFX4_0F1
	jp   Sound_SetSFXCh4
.set2:
	ld   de, SFX4_0F2
	jp   Sound_SetSFXCh4
.set3:
	ld   de, SFX4_0F3
	jp   Sound_SetSFXCh4
.set4:
	ld   de, SFX4_0F4
	jp   Sound_SetSFXCh4
SFX4_0F0: 
	db $00
	db $60
	db $31
	db $80
SFX4_0F1: 
	db $00
	db $60
	db $32
	db $80
SFX4_0F2: 
	db $00
	db $60
	db $33
	db $80
SFX4_0F3: 
	db $00
	db $60
	db $44
	db $80
SFX4_0F4: 
	db $00
	db $67
	db $45
	db $80
; ================================================
; SFX4 $10
SFX4_10_Init:
	call Sound_SFX4IsOtherPlaying
	ret  nz
	ld   a, $10
	ld   de, SFX4_100
	jp   Sound_SFX4Init
SFX4_100:
	db $00
	db $47
	db $45
	db $80
; ================================================
; SFX4 $11
SFX4_11_Init:
	call Sound_SFX4IsOtherPlaying
	ret  nz
	ld   a, $10
	ld   de, SFX4_111
	jp   Sound_SFX4Init
SFX4_111:
	db $00
	db $37
	db $43
	db $80
; ================================================
; SFX4 $12
SFX4_12_Init:
	ld   a, SFX1_1F
	ld   [sSFX1Set], a
	ld   a, $90
	ld   de, SFX4_Empty
	jp   Sound_SFX4Init
SFX4_12_Next:
	call Sound_DoSFX4Timer
	cp   a, $70
	jp   z, .set0
	cp   a, $6D
	jp   z, .freq67
	cp   a, $6A
	jp   z, .freq66
	cp   a, $67
	jp   z, .freq65
	cp   a, $64
	jp   z, .freq57
	cp   a, $61
	jp   z, .freq55
	cp   a, $5E
	jp   z, .freq47
	cp   a, $5B
	jp   z, .freq45
	cp   a, $59
	jp   z, .freq37
	cp   a, $56
	jp   z, .freq35
	cp   a, $53
	jp   z, .freq27
	cp   a, $50
	jr   z, .set1
	ret
.set1:
	ld   de, SFX4_121
	jp   Sound_SetSFXCh4
.freq27:
	ld   a, $27
	ldh  [rNR43], a
	ret
.freq35:
	ld   a, $35
	ldh  [rNR43], a
	ret
.freq37:
	ld   a, $37
	ldh  [rNR43], a
	ret
.freq45:
	ld   a, $45
	ldh  [rNR43], a
	ret
.freq47:
	ld   a, $47
	ldh  [rNR43], a
	ret
.freq55:
	ld   a, $55
	ldh  [rNR43], a
	ret
.freq57:
	ld   a, $57
	ldh  [rNR43], a
	ret
.freq65:
	ld   a, $65
	ldh  [rNR43], a
	ret
.freq66:
	ld   a, $66
	ldh  [rNR43], a
	ret
.freq67:
	ld   a, $67
	ldh  [rNR43], a
	ret
.set0:
	ld   de, SFX4_120
	jp   Sound_SetSFXCh4
SFX4_120:
	db $00
	db $F0
	db $43
	db $80
SFX4_121:
	db $00
	db $F6
	db $65
	db $80
; ================================================
; SFX4 $13
SFX4_13_Init:
	; Do not play if the Jet SFX is currently playing
	call Sound_SFX4IsNotJet
	ret  z
	ld   a, $18
	ld   de, SFX4_130
	jp   Sound_SFX4Init
SFX4_130:
	db $00
	db $84
	db $22
	db $80
; ================================================
; SFX4 $14
SFX4_14_Init:
	call Sound_SFX4IsOtherPlaying
	ret  nz
	ld   a, $01
	ld   de, SFX4_140
	jp   Sound_SFX4Init
SFX4_140:
	db $3E
	db $D7
	db $12
	db $C0
; ================================================
; SFX4 $15
SFX4_15_Init:
	call Sound_SFX4IsOtherPlaying
	ret  nz
	ld   a, $08
	ld   de, SFX4_150
	jp   Sound_SFX4Init
SFX4_150:
	db $00
	db $3A
	db $22
	db $80
; ================================================
; SFX4 $16
SFX4_16_Init:
	ld   a, [sSFX4]
	cp   a, SFX4_15			; Of course this should always play over the initial boomerang SFX playing.
	jr   z, .canPlay				; As this is its direct successor.
	call Sound_SFX4IsOtherPlaying	; Otherwise check that we aren't playing another SFX4
	ret  nz
.canPlay:
	ld   a, SFX1_27
	ld   [sSFX1Set], a
	jr   SFX4_15_Init
; ================================================
; SFX4 $17
SFX4_17_Init:
	ld   a, [sSFX4]
	cp   a, $08
	jr   z, .canPlay
	cp   a, $09
	jr   z, .canPlay
	call Sound_SFX4IsOtherPlaying
	ret  nz
.canPlay:
	ld   a, $26
	ld   de, SFX4_170
	jp   Sound_SFX4Init
SFX4_17_Next:
	call Sound_DoSFX4Timer
	cp   a, $22
	jr   z, .set1
	cp   a, $14
	jr   z, .set0
	cp   a, $10
	jr   z, .set1
	ret
.set0:
	ld   de, SFX4_170
	jp   Sound_SetSFXCh4
.set1:
	ld   de, SFX4_171
	jp   Sound_SetSFXCh4
SFX4_170: 
	db $36
	db $D0
	db $71
	db $C0
SFX4_171: 
	db $00
	db $B1
	db $72
	db $80
; ================================================
; SFX4 $18
SFX4_18_Init:
	ld   a, $0A
	ld   de, SFX4_180
	jp   Sound_SFX4Init
SFX4_180:
	db $00
	db $B1
	db $3F
	db $80
; ================================================
; SFX4 $19
SFX4_19_Init:
	ld   a, [sSFX4]
	cp   a, $01
	ret  z
	cp   a, $03
	ret  z
	cp   a, $0F
	ret  z
	ld   a, $08
	ld   de, SFX4_190
	jp   Sound_SFX4Init
SFX4_190:
	db $36
	db $F0
	db $63
	db $C0
; ================================================
; SFX4 $1A
; [TCRF] Unused sound effect, but assigned to an ID.
SFX4_Unused_1A_Init: 
	call Sound_SFX4IsOtherPlaying
	ret  nz
	ld   a, $0A
	ld   de, SFX4_Unused_1A0
	jp   Sound_SFX4Init
SFX4_Unused_1A0:
	db $00
	db $72
	db $46
	db $80
; ================================================
; SFX4 $1B
; [TCRF] Unused sound effect, but assigned to an ID.
SFX4_Unused_1B_Init: 
	call Sound_SFX4IsOtherPlaying
	ret  nz
	ld   a, $04
	ld   de, SFX4_Unused_1B0
	jp   Sound_SFX4Init
SFX4_Unused_1B0:
	db $30
	db $C0
	db $22
	db $C0

; =============== Utility subroutines for SFX4 ===============
; =============== Sound_SFX4Init ===============
; Default SFX4 initializer.
; Starts the specified sound effect on channel 4.
; IN:
; - A: Sound length
; - DE: Ptr to raw channel 4 data
Sound_SFX4Init:
	ld   [sSFX4Len], a
	ld   a, [sSFX4Set]
	ld   [sSFX4], a
	ld   [sBGMChSFX4], a
	jp   Sound_SetSFXCh4
; =============== Sound_SFX4Next ===============
; Default handler for continuing SFX4 playback.
; If called directly from the ptr table, it will keep playing the SFX
; with the same settings until its timer runs out.
Sound_SFX4Next:
	jp   Sound_DoSFX4Timer

; =============== Sound_SFX4IsOtherPlaying ===============
; Determines if there is a different SFX4 currently playing.
;
; This is used for low priority SFX4, which should silently
; kill themselves if any other SFX is currently playing.
; OUT:
; - A: If 0, there isn't any currently playing sound, or there's a restart request.
Sound_SFX4IsOtherPlaying:
	ld   a, [sSFX4Set]	; B = Requested SFX4
	ld   b, a
	ld   a, [sSFX4]		; A = Current SFX
	cp   a, b			; Are they the same?
	ret  z				; If so, return 0
	and  a				; Otherwise, return if there's any SFX playing.
	ret
; =============== Sound_SFX4IsNotJet ===============
; Determines if the Jet Hat SFX isn't currently playing
; OUT:
; - A: If 0, it is playing
Sound_SFX4IsNotJet:
	ld   a, [sSFX4]
	cp   a, SFX4_0F
	ret
; =============== SFX4_Empty ===============
SFX4_Empty:
	db $00
	db $00
	db $00
	db $80
; =============== Sound_BGMNoiseTable ===============
; This table defines the noise settings BGM data can request.
; Each table entry is $04 bytes large and contains, in the correct order,
; raw data for all rNR4? regisrers.
;
; As a result, this is the format of an entry:
; 0: rNR41 data
; 1: rNR42 data
; 2: rNR43 data
; 3: rNR44 data
;
; [TCRF] Table marked with ;X are unused
;
Sound_BGMNoiseTable:
	db $00,$00,$00,$C0;X ; [TCRF] Unused for the same reason as Sound_BGMPitchTable
	db $38,$09,$34,$C0;X
	db $38,$19,$33,$C0;X
	db $13,$46,$10,$C0
	db $00,$80,$10,$C0
	db $00,$57,$60,$80;X
	db $09,$31,$40,$C0
	db $00,$23,$40,$80
	db $00,$51,$07,$80;X
	db $00,$71,$18,$80;X
	db $00,$A2,$18,$80
	db $3A,$81,$10,$C0
	db $3A,$91,$1F,$C0

; =============== Sound_BGMPitchCmdTable ===============
; Frequency offset tables for BGMPP commands.
; Set of $10 byte tables tables with frequency offset values added over the current frequency.
;
; The byte order used is actually reversed, as
; these tables are offset through a timer which decrements every frame.
; This allows for pitch bends.
;
; The index actually starts at $10 (which is 1 byte after the intended end of the table),
; but because the values at the edges of the table are similar, there
; isn't any noticeable effect caused by this.
;
; [TCRF] Table marked with ;X are unused
Sound_BGMPitchCmdTable0:
	db $01,$00,$01,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$01,$00,$00 ;X
Sound_BGMPitchCmdTable1:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01 ;X
Sound_BGMPitchCmdTable2:
	db $08,$10,$18,$20,$28,$30,$38,$40,$38,$30,$28,$20,$18,$10,$08,$00
Sound_BGMPitchCmdTable3:
	db $00,$05,$00,$05,$00,$05,$00,$05,$05,$00,$05,$00,$05,$00,$05,$00 ;X
Sound_BGMPitchCmdTable4:
	db $04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00 ;X
Sound_BGMPitchCmdTable5:
	db $00,$10,$20,$30,$40,$50,$60,$70,$80,$90,$40,$10,$00,$10,$00,$10
Sound_BGMPitchCmdTable6:
	db $00,$10,$20,$30,$40,$50,$60,$70,$80,$90,$A0,$B0,$C0,$E0,$F0,$10 ;X (completely unreferenced)

; I have no idea how did this happen
Sound_CopyBGMChArea_0B: db $0B
Sound_ClearBGMRAM_2D: db $2D
Sound_Unused_61: db $61;X
; =============== Sound_BGMPitchTable ===============
; This is table defines the pitch/frequency settings for BGM.
; Because all sound channels except the 4th have registers to set the frequency, this data is shared between channels unaltered.
; However unused code would make channel 4 pick entry $02 in the table.

; Each table entry is 2 bytes large:
; 0: Frequency low (NR13/NR23/NR33 raw data) 
; 1: Frequency high (NR14/NR24/NR34 raw data) 
Sound_BGMPitchTable:
	db $00,$80 	; [TCRF] The pitch setting of 0 can't be used,
				;        because pitch settings are commands, and command $00 marks the end of a data table
	db $2C,$80
	db $9C,$80
	db $06,$81
	db $6B,$81
	db $C9,$81
	db $23,$82
	db $77,$82
	db $C6,$82
	db $12,$83
	db $56,$83
	db $9B,$83
	db $DA,$83
	db $16,$84
	db $4E,$84
	db $83,$84
	db $B5,$84
	db $E5,$84
	db $11,$85
	db $3B,$85
	db $63,$85
	db $89,$85
	db $AC,$85
	db $CE,$85
	db $ED,$85
	db $0A,$86
	db $27,$86
	db $42,$86
	db $5B,$86
	db $72,$86
	db $89,$86
	db $9E,$86
	db $B2,$86
	db $C4,$86
	db $D6,$86
	db $E7,$86
	db $F7,$86
	db $06,$87
	db $14,$87
	db $21,$87
	db $2D,$87
	db $39,$87
	db $44,$87
	db $4F,$87
	db $59,$87
	db $62,$87
	db $6B,$87
	db $73,$87
	db $7B,$87
	db $83,$87
	db $8A,$87
	db $90,$87
	db $97,$87
	db $9D,$87
	db $A2,$87
	db $A7,$87
	db $AC,$87
	db $B1,$87
	db $B6,$87
	db $BA,$87
	db $BE,$87
	db $C1,$87
	db $C4,$87
	db $C8,$87
	db $CB,$87
	db $CE,$87
	db $D1,$87
	db $D4,$87
	db $D6,$87
	db $D9,$87
	db $DB,$87
	db $DD,$87
	db $DF,$87
; =============== SOUND LENGTH TABLES ===============
; These tables determine how long (in frames) to play sound playback commands.
; Each table contains $0F entries, where each byte is a value that can be set to sBGMCurChLen.
;
; Each BGM specifies one of these tables as part of the header.
; A song can use a command to use a different entry in the table by specifying an ID.
; Alternatively, it can also choose to set a new table.
;
; [TCRF] There are some unused tables -- and unused values in the used tables.
;        These are marked by ";X".
;
BGMLenTable_Unused_59B3: 
	db $01;X
	db $01;X
	db $02;X
	db $04;X
	db $08;X
	db $10;X
	db $03;X
	db $06;X
	db $0C;X
	db $01;X
	db $03;X
	db $01;X
	db $18;X
	db $01;X
	db $01;X
BGMLenTable_Unused_59C2:
	db $01;X
	db $02;X
	db $04;X
	db $08;X
	db $10;X
	db $20;X
	db $06;X
	db $0C;X
	db $18;X
	db $02;X
	db $05;X
	db $01;X
	db $30;X
	db $01;X
	db $01;X
BGMLenTable_59D1: 
	db $02;X
	db $03;X
	db $06
	db $0C
	db $18
	db $30
	db $09;X
	db $12;X
	db $24;X
	db $04;X
	db $08;X
	db $01;X
	db $48
	db $01;X
	db $02;X
BGMLenTable_59E0:
	db $02;X
	db $04
	db $08
	db $10
	db $20
	db $40
	db $0C
	db $18
	db $30;X
	db $05;X
	db $0A;X
	db $01;X
	db $60
	db $01;X
	db $02;X
BGMLenTable_59EF:
	db $03
	db $05
	db $0A
	db $14
	db $28
	db $50
	db $0F
	db $1E
	db $3C
	db $07;X
	db $0E;X
	db $01;X
	db $78
	db $02;X
	db $03;X
BGMLenTable_59FE:
	db $03
	db $06
	db $0C
	db $18
	db $30
	db $60
	db $12
	db $24
	db $48
	db $08
	db $10;X
	db $02;X
	db $90
	db $03
	db $04
BGMLenTable_5A0D:
	db $03;X
	db $07
	db $0E
	db $1C
	db $38
	db $70
	db $15
	db $2A
	db $54
	db $09
	db $12;X
	db $02;X
	db $A8;X
	db $04;X
	db $04;X
BGMLenTable_5A1C:
	db $04;X
	db $08
	db $10
	db $20
	db $40
	db $80
	db $18
	db $30
	db $60
	db $0A;X
	db $14;X
	db $02;X
	db $C0
	db $04;X
	db $05;X
BGMLenTable_5A2B:
	db $04;X
	db $09
	db $12
	db $24
	db $48
	db $90
	db $1B
	db $36
	db $6C
	db $0C;X
	db $1A;X
	db $02;X
	db $D8;X
	db $04;X
	db $06;X
BGMLenTable_5A3A:
	db $05;X
	db $0A
	db $14
	db $28
	db $50;X
	db $A0
	db $1E;X
	db $3C
	db $78;X
	db $0D;X
	db $01;X
	db $01;X
	db $F0
	db $01;X
	db $06;X
; =============== BGM Command Tables (part 1) ===============
; Sets of commands sent to the sound driver during BGM playback.
; Some of these tables aren't used.
;
; For more details on the commands themselves, see Sound_ParseBGMCommand.
BGMCmdTable_5A49: 
	sndlentbl BGMLenTable_59EF
	sndend
BGMCmdTable_5A4D: 
	sndlentbl BGMLenTable_59FE
	sndend
BGMCmdTable_5A51: 
	sndlentbl BGMLenTable_5A0D
	sndend
BGMCmdTable_5A55: 
	sndpitchbase $00
	sndend
BGMCmdTable_5A58: 
	sndpitchbase $02
	sndend
BGMCmdTable_5A5B: 
	sndpitchbase $06
	sndend
BGMCmdTable_5A5E: 
	sndpitchbase $0A
	sndend
BGMCmdTable_Unused_5A61: 
	sndpitchbase $F6
	sndend
BGMCmdTable_5A64: 
	sndregex $40,$00,$00,BGMPP_NONE
	sndend
BGMCmdTable_5A69: 
	sndregex $60,$00,$00,BGMPP_NONE
	sndend
BGMCmdTable_5A6E: 
	sndregex $61,$00,$00,BGMPP_NONE
	sndend
BGMCmdTable_5A73: 
	sndregex $80,$00,$00,BGMPP_NONE
	sndend
BGMCmdTable_5A78: 
	sndregex $81,$00,$00,BGMPP_NONE
	sndend
BGMCmdTable_Unused_5A7D:
	sndregex $82,$00,$00,BGMPP_NONE
	sndend
BGMCmdTable_5A82: 
	sndregex $89,$00,$00,BGMPP_NONE
	sndend
BGMCmdTable_5A87: 
	sndregex $A1,$00,$00,BGMPP_NONE
	sndend
BGMCmdTable_5A8C: 
	sndregex $60,$00,$40,BGMPP_NONE
	sndend
BGMCmdTable_5A91: 
	sndregex $62,$00,$40,BGMPP_NONE
	sndend
BGMCmdTable_5A96: 
	sndregex $72,$00,$40,BGMPP_NONE
	sndend
BGMCmdTable_5A9B: 
	sndregex $81,$00,$40,BGMPP_NONE
	sndend
BGMCmdTable_5AA0: 
	sndregex $80,$00,$40,BGMPP_NONE
	sndend
BGMCmdTable_5AA5: 
	sndregex $90,$00,$40,BGMPP_NONE
	sndend
BGMCmdTable_Unused_5AAA:
	sndregex $92,$00,$40,BGMPP_NONE
	sndend
BGMCmdTable_5AAF: 
	sndregex $A1,$00,$40,BGMPP_NONE
	sndend
BGMCmdTable_5AB4: 
	sndregex $D1,$00,$40,BGMPP_NONE
	sndend
BGMCmdTable_5AB9: 
	sndregex $D3,$00,$40,BGMPP_NONE
	sndend
BGMCmdTable_5ABE: 
	sndregex $10,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5AC3: 
	sndregex $26,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5AC8: 
	sndregex $31,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5ACD: 
	sndregex $32,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5AD2: 
	sndregex $30,$6F,$80,BGMPP_NONE
	sndend
BGMCmdTable_5AD7: 
	sndregex $42,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5ADC: 
	sndregex $46,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5AE1: 
	sndregex $51,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5AE6: 
	sndregex $52,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5AEB: 
	sndregex $62,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5AF0: 
	sndregex $66,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5AF5: 
	sndregex $60,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_Unused_5AFA:
	sndregex $80,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5AFF: 
	sndregex $81,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5B04: 
	sndregex $82,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5B09: 
	sndregex $83,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5B0E: 
	sndregex $A1,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5B13: 
	sndregex $D1,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5B18: 
	sndregex $A0,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_5B1D: 
	sndregex3 BGMWaveTable_5C06,$20
	sndend
BGMCmdTable_5B22: 
	sndregex3 BGMWaveTable_5C06,$40
	sndend
BGMCmdTable_Unused_5B27: 
	sndregex3 BGMWaveTable_Unused_5C16,$20
	sndend
BGMCmdTable_Unused_5B2C: 
	sndregex3 BGMWaveTable_Unused_5C16,$40
	sndend
BGMCmdTable_Unused_5B31: 
	sndregex3 BGMWaveTable_Unused_5C26,$20
	sndend
BGMCmdTable_5B36: 
	sndregex3 BGMWaveTable_5BD6,$20
	sndend
BGMCmdTable_Unused_5B3B: 
	sndregex3 BGMWaveTable_5BD6,$40
	sndend
BGMCmdTable_Unused_5B40: 
	sndregex3 BGMWaveTable_5BD6,$60
	sndend
BGMCmdTable_Unused_5B45: 
	sndregex3 BGMWaveTable_5BE6,$20
	sndend
BGMCmdTable_5B4A: 
	sndregex3 BGMWaveTable_5BE6,$40
	sndend
BGMCmdTable_5B4F: 
	sndregex3 BGMWaveTable_5BE6,$60
	sndend
BGMCmdTable_5B54: 
	sndregex3 BGMWaveTable_5BF6,$20
	sndend
BGMCmdTable_5B59: 
	sndregex3 BGMWaveTable_5C36,$20
	sndend
BGMCmdTable_5B5E: 
	sndregex3 BGMWaveTable_5C56,$20
	sndend
BGMCmdTable_Unused_5B63: 
	sndregex3 BGMWaveTable_5C56,$40
	sndend
BGMCmdTable_5B68: 
	sndregex3 BGMWaveTable_5C66,$20
	sndend
BGMCmdTable_5B6D: 
	sndregex3 BGMWaveTable_5C76,$20
	sndend
BGMCmdTable_5B72: 
	sndregex3 BGMWaveTable_5C46,$20
	sndend
BGMCmdTable_5B77: 
	sndregex3 BGMWaveTable_5C46,$40
	sndend
BGMCmdTable_5B7C: 
	sndregex3 BGMWaveTable_5C96,$20
	sndend
BGMCmdTable_5B81: 
	sndregex3 BGMWaveTable_5C86,$40
	sndend
BGMCmdTable_5B86: 
	sndsetloop $08
	sndlenid $6
	sndmutech
	sndloop
	sndend
BGMCmdTable_5B8C: 
	sndsetloop $04
	sndlenid $6
	sndmutech
	sndloop
	sndend
BGMCmdTable_Unused_5B92: 
	sndsetloop $03
	sndlenid $6
	sndmutech
	sndloop
	sndend
BGMCmdTable_5B98: 
	sndsetloop $02
	sndlenid $6
	sndmutech
	sndloop
	sndend
BGMCmdTable_5B9E: 
	sndlenid $6
	sndmutech
	sndend
BGMCmdTable_5BA1: 
	sndsetloop $04
	sndlenid $9
	sndmutech
	sndloop
	sndend
BGMCmdTable_5BA7: 
	sndlenid $8
	sndmutech
	sndend
BGMCmdTable_5BAA: 
	sndlenid $4
	sndmutech
	sndend
BGMCmdTable_5BAD: 
	sndlenid $7
	sndmutech
	sndend
BGMCmdTable_5BB0: 
	sndlenid $3
	sndmutech
	sndend
BGMCmdTable_5BB3: 
	sndlenid $2
	sndmutech
	sndend
BGMCmdTable_Unused_5BB6: 
	sndlenid $9
	sndmutech
	sndend
BGMCmdTable_5BB9: 
	sndlenid $5
	sndmutech
	sndend
BGMCmdTable_5BBC: 
	sndlenid $6
	sndmutech
	sndmutech
	sndend
BGMCmdTable_5BC0: 
	sndlenid $6
	sndmutech
	sndend
BGMCmdTable_Unused_5BC3: 
	sndlenid $9
	sndmutech
	sndend
BGMCmdTable_Unused_5BC6: 
	sndlenid $9
	sndmutech
	sndmutech
	sndend
BGMCmdTable_Unused_5BCA: 
	sndlenid $3
	sndmutech
	sndend
BGMCmdTable_5BCD: 
	sndlenid $4
	sndmutech
	sndend
BGMCmdTable_Unused_5BD0: 
	sndlenid $5
	sndmutech
	sndend
BGMCmdTable_5BD3: 
	sndlenid $2
	sndmutech
	sndend
	
; =============== CHANNEL 3 WAVE DATA TABLES ===============
; These have raw wave data that's copied directly to the registers.
; A BGM can choose to pick any of these, through sndregex3.
BGMWaveTable_5BD6: db $88,$88,$88,$88,$88,$88,$88,$88,$00,$00,$00,$00,$00,$00,$00,$00
BGMWaveTable_5BE6: db $88,$88,$88,$88,$00,$00,$00,$00,$88,$88,$88,$88,$00,$00,$00,$00
BGMWaveTable_5BF6: db $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC,$00,$00,$00,$00,$00,$00,$00,$00
BGMWaveTable_5C06: db $88,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
BGMWaveTable_Unused_5C16: db $88,$88,$00,$00,$00,$00,$00,$00,$88,$88,$00,$00,$00,$00,$00,$00
BGMWaveTable_Unused_5C26: db $DD,$DD,$DD,$DD,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
BGMWaveTable_5C36: db $11,$11,$11,$11,$00,$00,$00,$00,$11,$11,$11,$11,$00,$00,$00,$00
BGMWaveTable_5C46: db $CC,$CC,$82,$C3,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
BGMWaveTable_5C56: db $77,$77,$51,$A2,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
BGMWaveTable_5C66: db $55,$55,$31,$91,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
BGMWaveTable_5C76: db $77,$51,$A2,$00,$00,$00,$00,$00,$77,$51,$A2,$00,$00,$00,$00,$00
BGMWaveTable_5C86: db $AA,$AA,$AA,$00,$00,$00,$AA,$AA,$AA,$00,$00,$00,$AA,$00,$AA,$00
BGMWaveTable_5C96: db $77,$77,$77,$00,$00,$00,$77,$77,$77,$00,$00,$00,$77,$00,$77,$00
; =============== BGMHeader_PtrTable ===============
; This table contains pointers to the BGM header data for all BGMs.
;
; Each header is $B bytes large and is composed of the following:
; 0:
;   -> bits (7-1): Base pitch pitch
;   -> bit 0: ; If set, channel 2 will have a pitch increase
; 1: Sound Length Table Ptr (high byte)
; 2: Sound Length Table Ptr (low byte)
; 3: Channel 1 ChunkPtr (high byte)
; 4: Channel 1 ChunkPtr (low byte)
; 5: Channel 2 ChunkPtr (high byte)
; 6: Channel 2 ChunkPtr (low byte)
; 7: Channel 3 ChunkPtr (high byte)
; 8: Channel 3 ChunkPtr (low byte)
; 9: Channel 4 ChunkPtr (high byte)
; A: Channel 4 ChunkPtr (low byte)
;--
; The chunk format itself is based off nested pointers.
;
; BGMHeader
;  |- ChunkPtr -> Chunk
;  |               |- CmdTblPtr -> CmdTbl
;  |               |              |-BGM Command 1 (entry)
;  |               |              |-BGM Command 2 (entry)
;  |               |              ...
;  |               |- CmdTblPtr -> CmdTbl
;  |               ...
;  |- ...
;
; A BGMHeader has pointers for 4 chunks, one for each channel.
; Each chunk contains a list of pointers to BGM command tables.
; Each BGM command table has a list of BGM commands parsed by the BGM sound engine, which are converted to rNR** register values. 
;
; Command tables themselves are reused several times in multiple songs at different points, so there isn't a good way to detail them. 
;
; If sHurryUp mode is active and the track isn't blacklisted, the ptr to the normal command playback length will not be used.
; Instead, the ptr will be pulled from the table Sound_BGMHurryUpLenPtrTable.
; 
; A chunk ptr can also contain two special commands:
; - BGMTBLCMD_END - Marks the end of a non-looping chunk, and the entire sound channel will be muted.
; - BGMTBLCMD_REDIR - The next entry is set as the new chunk pointer (for looping BGMs)
;
BGMHeader_PtrTable:
	dw BGMHeader_Title ; BGM_TITLE
	dw BGMHeader_Overworld ; BGM_OVERWORLD
	dw BGMHeader_Water ; BGM_WATER
	dw BGMHeader_Course1 ; BGM_COURSE1
	dw BGMHeader_CoinVault ; BGM_COINVAULT
	dw BGMHeader_Invincible ; BGM_INVINCIBILE
	dw BGMHeader_CoinGame ; BGM_COINGAME
	dw BGMHeader_LifeLost ; BGM_LIFELOST
	dw BGMHeader_Ship ; BGM_SHIP
	dw BGMHeader_Lava ; BGM_LAVA
	dw BGMHeader_Train ; BGM_TRAIN
	dw BGMHeader_CoinBonus ; BGM_COINBONUS
	dw BGMHeader_LevelClear ; BGM_LEVELCLEAR
	dw BGMHeader_BossLevel ; BGM_BOSSLEVEL
	dw BGMHeader_Treasure ; BGM_TREASURE
	dw BGMHeader_Lava2 ; BGM_LAVA2
	dw BGMHeader_Boss ; BGM_BOSS
	dw BGMHeader_BossClear ; BGM_BOSSCLEAR
	dw BGMHeader_MtTeapot ; BGM_MTTEAPOT
	dw BGMHeader_SherbetLand ; BGM_SHERBETLAND
	dw BGMHeader_RiceBeach ; BGM_RICEBEACH
	dw BGMHeader_Cave ; BGM_CAVE
	dw BGMHeader_Course3 ; BGM_COURSE3
	dw BGMHeader_HeartBonus ; BGM_HEARTBONUS
	dw BGMHeader_FinalBossIntro ; BGM_FINALBOSSINTRO
	dw BGMHeader_WorldClear ; BGM_WORLDCLEAR
	dw BGMHeader_Ambient ; BGM_AMBIENT
	dw BGMHeader_TreasureGet ; BGM_TREASUREGET
	dw BGMHeader_SyrupCastle ; BGM_SYRUPCASTLE
	dw BGMHeader_FinalLevel ; BGM_FINALLEVEL
	dw BGMHeader_ParsleyWoods ; BGM_PARSLEYWOODS
	dw BGMHeader_Intro ; BGM_INTRO
	dw BGMHeader_StoveCanyon ; BGM_STOVECANYON
	dw BGMHeader_Course32 ; BGM_COURSE32
	dw BGMHeader_SSTeacup ; BGM_SSTEACUP
	dw BGMHeader_GameOver ; BGM_GAMEOVER
	dw BGMHeader_TimeOver ; BGM_TIMEOVER
	dw BGMHeader_SaveSelect ; BGM_SAVESELECT
	dw BGMHeader_Ice ; BGM_ICE
	dw BGMHeader_FinalBoss ; BGM_FINALBOSS
	dw BGMHeader_Credits ; BGM_CREDITS
	dw BGMHeader_SelectBonus ; BGM_SELECTBONUS
	dw BGMHeader_LevelEnter ; BGM_LEVELENTER
	dw BGMHeader_Cutscene ; BGM_CUTSCENE
	dw BGMHeader_EndingGenie ; BGM_ENDINGGENIE
	dw BGMHeader_GameOver2 ; BGM_GAMEOVER2
	dw BGMHeader_EndingStatue ; BGM_ENDINGSTATUE
	dw BGMHeader_FinalBossOutro ; BGM_FINALBOSSOUTRO
; =============== BGM_PanningTable ===============
; This table contains the rNR51 values for each BGM.
; These are used to configure stereo panning on per-song basis.
BGM_PanningTable:
	db $E7 ; BGM_TITLE 
	db $FF ; BGM_OVERWORLD 
	db $FF ; BGM_WATER 
	db $FF ; BGM_COURSE1 
	db $FF ; BGM_COINVAULT 
	db $FF ; BGM_INVINCIBILE 
	db $FF ; BGM_COINGAME 
	db $FF ; BGM_LIFELOST 
	db $FF ; BGM_SHIP 
	db $FF ; BGM_LAVA 
	db $FF ; BGM_TRAIN 
	db $FF ; BGM_COINBONUS 
	db $BE ; BGM_LEVELCLEAR 
	db $FF ; BGM_BOSSLEVEL 
	db $FF ; BGM_TREASURE 
	db $FF ; BGM_LAVA2 
	db $FF ; BGM_BOSS 
	db $BE ; BGM_BOSSCLEAR 
	db $FF ; BGM_MTTEAPOT 
	db $FF ; BGM_SHERBETLAND 
	db $FF ; BGM_RICEBEACH 
	db $FF ; BGM_CAVE 
	db $FF ; BGM_COURSE3 
	db $FF ; BGM_HEARTBONUS 
	db $FF ; BGM_FINALBOSSINTRO 
	db $FF ; BGM_WORLDCLEAR 
	db $FF ; BGM_AMBIENT 
	db $FF ; BGM_TREASUREGET 
	db $FF ; BGM_SYRUPCASTLE 
	db $FF ; BGM_FINALLEVEL 
	db $FF ; BGM_PARSLEYWOODS 
	db $FF ; BGM_INTRO 
	db $FF ; BGM_STOVECANYON 
	db $FF ; BGM_COURSE32 
	db $FF ; BGM_SSTEACUP 
	db $FF ; BGM_GAMEOVER 
	db $FF ; BGM_TIMEOVER 
	db $FF ; BGM_SAVESELECT 
	db $FF ; BGM_ICE 
	db $FF ; BGM_FINALBOSS 
	db $FF ; BGM_CREDITS 
	db $FF ; BGM_SELECTBONUS 
	db $FF ; BGM_LEVELENTER 
	db $ED ; BGM_CUTSCENE 
	db $FF ; BGM_ENDINGGENIE 
	db $FF ; BGM_GAMEOVER2 
	db $DB ; BGM_ENDINGSTATUE 
	db $FF ; BGM_FINALBOSSOUTRO 
; =============== Sound_BGMHurryUpLenPtrTable ===============
; Pointers to sound length for the hurry up variations.
; Each points to a $0E byte data block.
; Songs marked as ;X can't go in hurry up mode and are *almost* all identical to their normal counterpart in the BGMHeader.
Sound_BGMHurryUpLenPtrTable:
	dw BGMLenTable_5A0D ; BGM_TITLE  ;X
	dw BGMLenTable_5A1C ; BGM_OVERWORLD  ;X
	dw BGMLenTable_59FE ; BGM_WATER  
	dw BGMLenTable_59FE ; BGM_COURSE1  
	dw BGMLenTable_5A2B ; BGM_COINVAULT  ;X
	dw BGMLenTable_59FE ; BGM_INVINCIBILE  ;X
	dw BGMLenTable_59EF ; BGM_COINGAME  
	dw BGMLenTable_59FE ; BGM_LIFELOST  ;X
	dw BGMLenTable_5A1C ; BGM_SHIP  
	dw BGMLenTable_59FE ; BGM_LAVA  
	dw BGMLenTable_59EF ; BGM_TRAIN  
	dw BGMLenTable_5A0D ; BGM_COINBONUS  ;X
	dw BGMLenTable_59FE ; BGM_LEVELCLEAR  ;X
	dw BGMLenTable_59E0 ; BGM_BOSSLEVEL  
	dw BGMLenTable_59FE ; BGM_TREASURE  
	dw BGMLenTable_5A0D ; BGM_LAVA2  
	dw BGMLenTable_59FE ; BGM_BOSS  ;X
	dw BGMLenTable_59FE ; BGM_BOSSCLEAR  
	dw BGMLenTable_5A1C ; BGM_MTTEAPOT  ;X
	dw BGMLenTable_5A1C ; BGM_SHERBETLAND  ;X
	dw BGMLenTable_5A1C ; BGM_RICEBEACH  ;X
	dw BGMLenTable_5A0D ; BGM_CAVE  
	dw BGMLenTable_59FE ; BGM_COURSE3  
	dw BGMLenTable_59FE ; BGM_HEARTBONUS  ;X
	dw BGMLenTable_59FE ; BGM_FINALBOSSINTRO  
	dw BGMLenTable_59EF ; BGM_WORLDCLEAR  
	dw BGMLenTable_59FE ; BGM_AMBIENT  
	dw BGMLenTable_59EF ; BGM_TREASUREGET  
	dw BGMLenTable_5A0D ; BGM_SYRUPCASTLE  ;X
	dw BGMLenTable_59D1 ; BGM_FINALLEVEL  
	dw BGMLenTable_59FE ; BGM_PARSLEYWOODS  ;X
	dw BGMLenTable_59FE ; BGM_INTRO  ;X
	dw BGMLenTable_5A1C ; BGM_STOVECANYON  ;X
	dw BGMLenTable_5A0D ; BGM_COURSE32  
	dw BGMLenTable_5A0D ; BGM_SSTEACUP  ;X
	dw BGMLenTable_5A1C ; BGM_GAMEOVER  ;X
	dw BGMLenTable_59E0 ; BGM_TIMEOVER  ;X
	dw BGMLenTable_59FE ; BGM_SAVESELECT  ;X
	dw BGMLenTable_59EF ; BGM_ICE  
	dw BGMLenTable_59FE ; BGM_FINALBOSS  
	dw BGMLenTable_5A1C ; BGM_CREDITS  ;X
	dw BGMLenTable_59FE ; BGM_SELECTBONUS  ;X
	; [TCRF] This song can't be hurry up'd, but uses an unique entry for it.
	dw BGMLenTable_59FE ; BGM_LEVELENTER  ;X
	dw BGMLenTable_59FE ; BGM_CUTSCENE  ;X
	dw BGMLenTable_5A1C ; BGM_ENDINGGENIE  ;X
	dw BGMLenTable_59FE ; BGM_GAMEOVER2  ;X
	dw BGMLenTable_5A2B ; BGM_ENDINGSTATUE  ;X
	dw BGMLenTable_59FE ; BGM_FINALBOSSOUTRO  ;X
	
; =============== SONG HEADER AND CHUNK DEFINITIONS ===============
; And the second part of the BGM Command Tables
; See BGMHeader_PtrTable for more details on the format.
BGMHeader_Intro:
	db $00					; Pitch bitmask
	dw BGMLenTable_59FE		; Command length
	dw $0000				; Sound Channel 1 Chunk -- nothing
	dw BGMChunk_Intro_Ch2	; Sound Channel 2 Chunk
	dw BGMChunk_Intro_Ch3	; Sound Channel 3 Chunk
	dw $0000				; Sound Channel 4 Chunk -- nothing
BGMChunk_Intro_Ch2:
	dw BGMCmdTable_5BB9
	dw BGMCmdTable_5B8C
	dw BGMCmdTable_5A82
	dw BGMCmdTable_5DED
	dw BGMCmdTable_5A69
	dw BGMCmdTable_5DED
	dw BGMCmdTable_5DFC
	dw BGMCmdTable_5A49
	dw BGMCmdTable_5E0A
	dw BGMCmdTable_5A6E
	dw BGMCmdTable_5E10
	dw BGMCmdTable_5E10
	dw BGMCmdTable_5AF5
	dw BGMCmdTable_5E17
	dw BGMCmdTable_5A6E
	dw BGMCmdTable_5E10
	dw BGMCmdTable_5AF5
	dw BGMCmdTable_5E17
	dw BGMCmdTable_5A4D
	dw BGMCmdTable_5B09
	dw BGMCmdTable_5E32
	dw BGMCmdTable_5BAD
	dw BGMCmdTable_5B9E
	dw $0000
BGMChunk_Intro_Ch3:
	dw BGMCmdTable_5BB9
	dw BGMCmdTable_5B68
	dw BGMCmdTable_5E46
	dw BGMCmdTable_5A49
	dw BGMCmdTable_5E6A
	dw BGMCmdTable_5B5E
	dw BGMCmdTable_5E74
	dw BGMCmdTable_5E74
	dw BGMCmdTable_5A4D
	dw BGMCmdTable_5B4A
	dw BGMCmdTable_5BAD
	dw BGMCmdTable_5E32
	dw BGMCmdTable_5B9E
	dw $0000

BGMCmdTable_5DED: 
	sndlenid $2
	snddb $32
	snddb $28
	snddb $22
	snddb $1a
	snddb $1c
	sndmutech
	snddb $20
	snddb $24
	sndlenid $3
	snddb $28
	sndmutech
	snddb $40
	sndmutech
	sndend
BGMCmdTable_5DFC: 
	sndlenid $2
	snddb $26
	snddb $24
	snddb $26
	snddb $2c
	snddb $36
	sndmutech
	snddb $3e
	sndmutech
	snddb $44
	sndmutech
	sndlenid $9
	sndmutech
	sndend
BGMCmdTable_5E0A: 
	sndlenid $2
	snddb $48
	snddb $46
	snddb $44
	snddb $42
	sndend
BGMCmdTable_5E10: 
	sndsetloop $08
	sndlenid $3
	snddb $40
	snddb $58
	sndloop
	sndend
BGMCmdTable_5E17: 
	sndsetloop $02
	sndlenid $2
	snddb $40
	snddb $48
	snddb $4e
	snddb $58
	snddb $54
	sndmutech
	snddb $54
	sndmutech
	sndloop
	snddb $58
	snddb $56
	snddb $54
	snddb $52
	snddb $50
	snddb $4e
	snddb $4c
	snddb $4a
	snddb $48
	snddb $46
	snddb $44
	snddb $42
	sndlenid $4
	snddb $40
	sndend
BGMCmdTable_5E32: 
	sndlenid $2
	snddb $28
	snddb $30
	snddb $38
	snddb $3c
	snddb $40
	snddb $48
	snddb $50
	snddb $54
	snddb $58
	snddb $60
	snddb $68
	snddb $6c
	snddb $70
	snddb $78
	snddb $80
	snddb $84
	sndlenid $4
	snddb $88
	sndend
BGMCmdTable_5E46: 
	sndsetloop $04
	sndlenid $3
	snddb $1a
	sndmutech
	snddb $28
	sndmutech
	snddb $20
	sndmutech
	snddb $2e
	sndmutech
	sndloop
	sndsetloop $02
	sndlenid $3
	snddb $1a
	sndmutech
	snddb $28
	sndmutech
	snddb $20
	sndmutech
	snddb $56
	sndmutech
	sndloop
	snddb $1e
	sndmutech
	sndlenid $2
	snddb $4c
	sndmutech
	snddb $54
	sndmutech
	snddb $5a
	sndmutech
	sndlenid $9
	sndmutech
	sndend
BGMCmdTable_5E6A: 
	sndlenid $4
	snddb $1c
	sndlenid $3
	snddb $28
	sndmutech
	sndlenid $9
	sndmutech
	sndlenid $6
	sndmutech
	sndend
BGMCmdTable_5E74: 
	sndlenid $2
	snddb $1e
	sndmutech
	snddb $28
	sndmutech
	snddb $30
	sndmutech
	snddb $36
	sndmutech
	sndlenid $3
	snddb $3c
	sndlenid $2
	snddb $3a
	snddb $38
	sndlenid $3
	snddb $36
	sndmutech
	sndlenid $2
	snddb $32
	sndmutech
	snddb $3a
	sndmutech
	snddb $40
	sndmutech
	snddb $4a
	sndmutech
	snddb $42
	snddb $46
	snddb $4a
	snddb $42
	sndlenid $3
	snddb $40
	sndmutech
	sndsetloop $02
	sndlenid $2
	snddb $28
	sndmutech
	snddb $40
	sndmutech
	snddb $2a
	sndmutech
	snddb $42
	sndmutech
	sndloop
	sndlenid $2
	snddb $6c
	snddb $6a
	snddb $68
	snddb $66
	snddb $64
	snddb $62
	snddb $60
	snddb $5e
	snddb $5c
	snddb $5a
	snddb $58
	snddb $56
	snddb $54
	snddb $4c
	snddb $42
	sndmutech
	sndend
;--
BGMHeader_Title:
	db $00
	dw BGMLenTable_5A0D
	dw BGMChunk_Title_Ch1
	dw BGMChunk_Title_Ch2
	dw BGMChunk_Title_Ch3
	dw BGMChunk_Title_Ch4
BGMChunk_Title_Ch1:
BGMChunk_Ice_Ch1:
.loop:
	dw BGMCmdTable_5AE1
	dw BGMCmdTable_5ED4
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Title_Ch2:
.loop:
	dw BGMCmdTable_5ED8
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Title_Ch3:
.loop:
	dw BGMCmdTable_5B7C
	dw BGMCmdTable_5F14
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_5ED4: 
	sndlenid $4
	snddb $8c
	sndmutech
	sndend
BGMCmdTable_5ED8: 
	sndregex $C0,$00,$40,BGMPP_NONE
	sndlenid $2
	snddb $4a
	sndmutech
	snddb $40
	sndmutech
	snddb $3a
	sndmutech
	snddb $32
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $34
	sndlenid $7
	sndmutech
	sndlenid $4
	snddb $36
	sndlenid $2
	snddb $34
	sndmutech
	snddb $36
	sndmutech
	snddb $44
	sndmutech
	sndlenid $5
	sndmutech
	sndlenid $2
	snddb $48
	sndmutech
	snddb $3c
	sndmutech
	snddb $3a
	sndmutech
	snddb $36
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $3c
	sndlenid $7
	sndmutech
	sndlenid $4
	snddb $3a
	sndlenid $2
	snddb $3c
	sndmutech
	snddb $3e
	sndmutech
	snddb $40
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $5c
	sndmutech
	snddb $58
	sndlenid $7
	sndmutech
	sndend
BGMCmdTable_5F14: 
	sndlenid $2
	snddb $52
	sndmutech
	snddb $52
	sndmutech
	snddb $4a
	sndmutech
	snddb $3a
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $3a
	sndlenid $7
	sndmutech
	sndlenid $4
	snddb $3c
	sndlenid $2
	snddb $3a
	sndmutech
	snddb $3c
	sndmutech
	snddb $54
	sndmutech
	sndlenid $5
	sndmutech
	sndlenid $2
	snddb $4e
	sndmutech
	snddb $4e
	sndmutech
	snddb $4a
	sndmutech
	snddb $48
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $4e
	sndlenid $7
	sndmutech
	sndlenid $4
	snddb $4a
	sndlenid $2
	snddb $4e
	sndmutech
	snddb $50
	sndmutech
	snddb $52
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $72
	sndmutech
	snddb $6e
	sndlenid $7
	sndmutech
	sndend
;--
BGMHeader_SaveSelect:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_SaveSelect_Ch1
	dw BGMChunk_SaveSelect_Ch2
	dw $0000
	dw BGMChunk_SaveSelect_Ch4
BGMChunk_SaveSelect_Ch1:
.loop:
	dw BGMCmdTable_5A96
	dw BGMCmdTable_5FA0
	dw BGMCmdTable_5FAE
	dw BGMCmdTable_5FA0
	dw BGMCmdTable_5FB9
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_SaveSelect_Ch2:
.loop:
	dw BGMCmdTable_5A96
	dw BGMCmdTable_5F79
	dw BGMCmdTable_5F86
	dw BGMCmdTable_5F79
	dw BGMCmdTable_5F93
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_SaveSelect_Ch4:
.loop:
	dw BGMCmdTable_5FC4
	dw BGMTBLCMD_REDIR, .loop
BGMCmdTable_5F79: 
	sndlenid $a
	snddb $48
	snddb $46
	snddb $48
	snddb $40
	sndmutech
	snddb $3a
	snddb $30
	sndmutech
	snddb $48
	sndmutech
	sndmutech
	sndend
BGMCmdTable_5F86: 
	snddb $4a
	sndmutech
	snddb $42
	snddb $3c
	snddb $34
	snddb $38
	snddb $3c
	snddb $40
	sndmutech
	snddb $58
	sndlenid $4
	sndmutech
	sndend
BGMCmdTable_5F93: 
	snddb $4a
	sndmutech
	snddb $42
	snddb $3c
	snddb $34
	snddb $32
	snddb $30
	snddb $32
	sndmutech
	snddb $62
	sndlenid $4
	sndmutech
	sndend
BGMCmdTable_5FA0: 
	sndlenid $4
	snddb $1a
	sndlenid $a
	sndmutech
	sndmutech
	snddb $1a
	sndlenid $4
	snddb $28
	sndlenid $a
	sndmutech
	sndmutech
	sndlenid $4
	snddb $1c
	sndend
BGMCmdTable_5FAE: 
	sndlenid $a
	sndmutech
	snddb $2a
	snddb $2e
	snddb $32
	snddb $30
	sndmutech
	snddb $56
	sndlenid $4
	sndmutech
	sndend
BGMCmdTable_5FB9: 
	sndlenid $a
	sndmutech
	snddb $28
	snddb $26
	snddb $24
	snddb $22
	sndmutech
	snddb $60
	sndlenid $4
	sndmutech
	sndend
BGMCmdTable_5FC4: 
	sndlenid $4
	snddb $18
	sndlenid $7
	snddb $18
	sndlenid $2
	snddb $18
	sndlenid $4
	snddb $1c
	sndlenid $7
	snddb $18
	sndlenid $2
	snddb $18
	sndlenid $4
	snddb $18
	sndlenid $a
	snddb $18
	snddb $18
	snddb $18
	sndlenid $7
	snddb $1c
	sndlenid $2
	snddb $1c
	sndlenid $7
	snddb $18
	sndlenid $2
	snddb $18
	sndend
;--
BGMHeader_Overworld:
	db $00
	dw BGMLenTable_5A1C
	dw BGMChunk_Overworld_Ch1
	dw BGMChunk_Overworld_Ch2
	dw BGMChunk_Overworld_Ch3
	dw BGMChunk_Overworld_Ch4
BGMChunk_Overworld_Ch1:
.loop:
	dw BGMCmdTable_5AA0
	dw BGMCmdTable_5A55
	dw BGMCmdTable_601E
	dw BGMCmdTable_601E
	dw BGMCmdTable_5A5E
	dw BGMCmdTable_601E
	dw BGMCmdTable_601E
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Overworld_Ch2:
.loop:
	dw BGMCmdTable_5AA0
	dw BGMCmdTable_6054
	dw BGMCmdTable_6054
	dw BGMCmdTable_6054
	dw BGMCmdTable_6054
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Overworld_Ch3:
.loop:
	dw BGMCmdTable_5B5E
	dw BGMCmdTable_608A
	dw BGMCmdTable_608A
	dw BGMCmdTable_608A
	dw BGMCmdTable_608A
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Title_Ch4:
.loop:
BGMChunk_Overworld_Ch4:
.loop:
	dw BGMCmdTable_609F
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_601E: 
	sndlenid $2
	snddb $22
	sndmutech
	snddb $22
	sndmutech
	snddb $28
	sndmutech
	snddb $2a
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $28
	sndmutech
	snddb $24
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $22
	sndmutech
	snddb $22
	sndmutech
	snddb $28
	sndmutech
	snddb $2a
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $2e
	sndmutech
	snddb $2a
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $22
	sndmutech
	snddb $22
	sndmutech
	snddb $28
	sndmutech
	snddb $2a
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $28
	sndmutech
	snddb $24
	sndlenid $7
	sndmutech
	sndlenid $3
	snddb $22
	sndmutech
	sndlenid $9
	sndmutech
	sndend
BGMCmdTable_6054: 
	sndlenid $2
	snddb $28
	sndmutech
	snddb $32
	sndmutech
	snddb $3a
	sndmutech
	snddb $3c
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $3a
	sndmutech
	snddb $36
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $28
	sndmutech
	snddb $32
	sndmutech
	snddb $3a
	sndmutech
	snddb $3c
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $40
	sndmutech
	snddb $3c
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $28
	sndmutech
	snddb $32
	sndmutech
	snddb $3a
	sndmutech
	snddb $3c
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $3a
	sndmutech
	snddb $36
	sndlenid $7
	sndmutech
	sndlenid $3
	snddb $32
	sndmutech
	sndlenid $9
	sndmutech
	sndend
BGMCmdTable_608A: 
	sndsetloop $03
	sndlenid $3
	snddb $1a
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $1a
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $1a
	sndmutech
	snddb $1a
	sndmutech
	sndloop
	sndlenid $4
	snddb $1a
	sndlenid $9
	sndmutech
	sndend
BGMCmdTable_609F: 
	sndlenid $3
	snddb $30
	sndlenid $2
	snddb $2c
	snddb $2c
	sndlenid $3
	snddb $2c
	snddb $30
	snddb $2c
	snddb $2c
	snddb $30
	snddb $2c
	sndend
BGMHeader_RiceBeach:
	db $00
	dw BGMLenTable_5A1C
	dw BGMChunk_RiceBeach_Ch1
	dw BGMChunk_RiceBeach_Ch2
	dw BGMChunk_RiceBeach_Ch3
	dw BGMChunk_RiceBeach_Ch4
BGMChunk_RiceBeach_Ch1:
.loop:
	dw BGMCmdTable_5AE1
	dw BGMCmdTable_60D9
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_RiceBeach_Ch2:
	dw BGMCmdTable_5B98
.loop:
	dw BGMCmdTable_5AA0
	dw BGMCmdTable_60E3
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_RiceBeach_Ch3:
	dw BGMCmdTable_5B98
.loop:
	dw BGMCmdTable_5B77
	dw BGMCmdTable_60FB
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Ship_Ch4:
BGMChunk_Lava2_Ch4:
BGMChunk_RiceBeach_Ch4:
.loop:
	dw BGMCmdTable_6113
	dw BGMTBLCMD_REDIR, .loop
	
BGMCmdTable_60D9: 
	sndlenid $8
	snddb $8c
	snddb $8c
	sndlenid $4
	snddb $8c
	sndmutech
	snddb $8c
	snddb $8c
	sndmutech
	sndend
BGMCmdTable_60E3: 
	sndlenid $3
	snddb $1a
	sndmutech
	sndlenid $2
	snddb $10
	sndmutech
	snddb $10
	sndmutech
	snddb $1a
	sndmutech
	snddb $16
	sndmutech
	sndlenid $3
	sndmutech
	snddb $1a
	sndmutech
	snddb $1a
	snddb $10
	sndmutech
	snddb $1a
	sndmutech
	snddb $16
	sndmutech
	sndend
BGMCmdTable_60FB: 
	sndlenid $3
	snddb $22
	sndmutech
	sndlenid $2
	snddb $1a
	sndmutech
	snddb $1a
	sndmutech
	snddb $22
	sndmutech
	snddb $20
	sndmutech
	sndlenid $3
	sndmutech
	snddb $22
	sndmutech
	snddb $22
	snddb $1a
	sndmutech
	snddb $22
	sndmutech
	snddb $20
	sndmutech
	sndend
BGMCmdTable_6113: 
	sndlenid $3
	snddb $2c
	sndlenid $2
	snddb $1c
	snddb $1c
	sndlenid $3
	snddb $c
	snddb $2c
	snddb $18
	snddb $18
	snddb $2c
	snddb $18
	sndend
BGMHeader_MtTeapot:
	db $00
	dw BGMLenTable_5A1C
	dw BGMChunk_MtTeapot_Ch1
	dw BGMChunk_MtTeapot_Ch2
	dw BGMChunk_MtTeapot_Ch3
	dw BGMChunk_MtTeapot_Ch4
BGMChunk_MtTeapot_Ch1:
.loop:
	dw BGMCmdTable_5AC8
	dw BGMCmdTable_6151
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_MtTeapot_Ch2:
.loop:
	dw BGMCmdTable_5AC8
	dw BGMCmdTable_615B
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_MtTeapot_Ch3:
	dw BGMCmdTable_5B98
.loop:
	dw BGMCmdTable_5B5E
	dw BGMCmdTable_6165
	dw BGMCmdTable_617F
	dw BGMCmdTable_6165
	dw BGMCmdTable_6199
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_MtTeapot_Ch4:
.loop:
	dw BGMCmdTable_61AC
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_6151: 
	sndlenid $3
	snddb $6e
	sndmutech
	snddb $64
	snddb $64
	snddb $6e
	snddb $64
	snddb $64
	sndmutech
	sndend
BGMCmdTable_615B: 
	sndlenid $3
	snddb $7c
	sndmutech
	snddb $72
	snddb $72
	snddb $7c
	snddb $72
	snddb $72
	sndmutech
	sndend
BGMCmdTable_6165: 
	sndlenid $2
	snddb $28
	sndmutech
	snddb $2c
	sndmutech
	snddb $32
	sndmutech
	sndsetloop $02
	sndlenid $3
	snddb $3c
	sndmutech
	sndloop
	snddb $3c
	sndlenid $2
	snddb $3a
	sndmutech
	snddb $38
	sndmutech
	snddb $3a
	sndmutech
	snddb $40
	sndmutech
	sndlenid $5
	sndmutech
	sndend
BGMCmdTable_617F: 
	sndlenid $2
	snddb $24
	sndmutech
	snddb $28
	sndmutech
	snddb $30
	sndmutech
	sndsetloop $02
	sndlenid $3
	snddb $36
	sndmutech
	sndloop
	snddb $36
	sndlenid $2
	snddb $32
	sndmutech
	snddb $3a
	sndmutech
	snddb $44
	sndmutech
	snddb $40
	sndmutech
	sndlenid $5
	sndmutech
	sndend
BGMCmdTable_6199: 
	sndlenid $2
	snddb $24
	sndmutech
	snddb $28
	sndmutech
	snddb $30
	sndmutech
	snddb $36
	sndlenid $7
	sndmutech
	sndlenid $3
	snddb $36
	snddb $32
	snddb $30
	sndlenid $4
	snddb $32
	sndlenid $9
	sndmutech
	sndend
BGMCmdTable_61AC: 
	sndlenid $3
	snddb $2c
	sndmutech
	snddb $18
	snddb $18
	snddb $2c
	snddb $18
	snddb $18
	sndmutech
	sndend
BGMHeader_SherbetLand:
	db $00
	dw BGMLenTable_5A1C
	dw BGMChunk_SherbetLand_Ch1
	dw BGMChunk_SherbetLand_Ch2
	dw $0000
	dw $0000
BGMChunk_SherbetLand_Ch1:
.loop:
	dw BGMCmdTable_5AE1
	dw BGMCmdTable_61EB
	dw BGMCmdTable_61EB
	dw BGMCmdTable_61FB
	dw BGMCmdTable_61EB
	dw BGMCmdTable_61EB
	dw BGMCmdTable_61FB
	dw BGMCmdTable_61EB
	dw BGMCmdTable_61EB
	dw BGMCmdTable_6212
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_SherbetLand_Ch2:
.loop:
	dw BGMCmdTable_5AE1
	dw BGMCmdTable_6230
	dw BGMCmdTable_623E
	dw BGMCmdTable_6230
	dw BGMCmdTable_623E
	dw BGMCmdTable_6230
	dw BGMCmdTable_6253
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_61EB: 
	sndsetloop $02
	sndlenid $3
	snddb $7a
	snddb $70
	snddb $6a
	snddb $62
	sndloop
	sndsetloop $02
	snddb $78
	snddb $6e
	snddb $68
	snddb $60
	sndloop
	sndend
BGMCmdTable_61FB: 
	sndsetloop $02
	sndlenid $3
	snddb $74
	snddb $6c
	snddb $66
	snddb $5c
	sndloop
	sndsetloop $02
	snddb $72
	snddb $6c
	snddb $66
	snddb $5a
	sndloop
	sndsetloop $04
	snddb $70
	snddb $6c
	snddb $66
	snddb $60
	sndloop
	sndend
BGMCmdTable_6212: 
	sndsetloop $02
	sndlenid $3
	snddb $74
	snddb $6c
	snddb $66
	snddb $5c
	sndloop
	sndsetloop $02
	snddb $72
	snddb $6c
	snddb $66
	snddb $5a
	sndloop
	sndsetloop $02
	snddb $70
	snddb $6c
	snddb $66
	snddb $60
	sndloop
	snddb $70
	snddb $60
	snddb $66
	snddb $70
	sndlenid $4
	snddb $78
	sndmutech
	sndend
BGMCmdTable_6230: 
	sndsetloop $02
	sndlenid $8
	snddb $52
	snddb $4a
	sndlenid $4
	snddb $52
	sndlenid $8
	snddb $50
	snddb $48
	sndlenid $4
	snddb $50
	sndloop
	sndend
BGMCmdTable_623E: 
	sndlenid $8
	snddb $4e
	snddb $44
	sndlenid $4
	snddb $4e
	sndlenid $8
	snddb $4e
	snddb $42
	sndlenid $4
	snddb $4e
	sndlenid $8
	snddb $4a
	snddb $48
	sndlenid $4
	snddb $44
	sndlenid $8
	snddb $40
	snddb $44
	sndlenid $4
	snddb $48
	sndend
BGMCmdTable_6253: 
	sndlenid $8
	snddb $4e
	snddb $44
	sndlenid $4
	snddb $4e
	sndlenid $8
	snddb $4e
	snddb $42
	sndlenid $4
	snddb $4e
	sndlenid $8
	snddb $4a
	snddb $48
	sndlenid $4
	snddb $44
	sndlenid $3
	snddb $40
	snddb $36
	snddb $40
	snddb $48
	sndlenid $4
	snddb $4e
	sndlenid $2
	snddb $58
	snddb $5c
	snddb $58
	snddb $54
	sndend
BGMHeader_StoveCanyon:
	db $00
	dw BGMLenTable_5A1C
	dw BGMChunk_StoveCanyon_Ch1
	dw BGMChunk_StoveCanyon_Ch2
	dw $0000
	dw BGMChunk_StoveCanyon_Ch4
BGMChunk_StoveCanyon_Ch1:
	dw BGMCmdTable_5B98
.loop:
	dw BGMCmdTable_5A87
	dw BGMCmdTable_5A55
	dw BGMCmdTable_62AC
	dw BGMCmdTable_62AC
	dw BGMCmdTable_62AC
	dw BGMCmdTable_5A5B
	dw BGMCmdTable_62AC
	dw BGMCmdTable_5B8C
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_StoveCanyon_Ch2:
	dw BGMCmdTable_5B98
.loop:
	dw BGMCmdTable_5A87
	dw BGMCmdTable_62D1
	dw BGMCmdTable_62D1
	dw BGMCmdTable_62D1
	dw BGMCmdTable_62D1
	dw BGMCmdTable_5B8C
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_StoveCanyon_Ch4:
	dw BGMCmdTable_62F6
	dw BGMCmdTable_62F6
.loop:
	dw BGMCmdTable_6301
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_62AC: 
	sndlenid $4
	snddb $2
	sndmutech
	sndlenid $3
	snddb $2
	snddb $2
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $8
	snddb $6
	snddb $8
	snddb $6
	sndlenid $3
	snddb $2
	snddb $2
	sndlenid $5
	sndmutech
	sndlenid $4
	snddb $2
	sndmutech
	sndlenid $3
	snddb $2
	snddb $2
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $8
	snddb $6
	snddb $8
	snddb $6
	sndlenid $3
	snddb $c
	snddb $c
	sndlenid $5
	sndmutech
	sndend
BGMCmdTable_62D1: 
	sndlenid $4
	snddb $10
	sndmutech
	sndlenid $3
	snddb $10
	snddb $10
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $16
	snddb $14
	snddb $16
	snddb $14
	sndlenid $3
	snddb $10
	snddb $10
	sndlenid $5
	sndmutech
	sndlenid $4
	snddb $10
	sndmutech
	sndlenid $3
	snddb $10
	snddb $10
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $16
	snddb $14
	snddb $16
	snddb $14
	sndlenid $3
	snddb $1a
	snddb $1a
	sndlenid $5
	sndmutech
	sndend
BGMCmdTable_62F6: 
	sndsetloop $04
	sndlenid $2
	snddb $18
	sndloop
	sndlenid $3
	snddb $18
	snddb $18
	sndlenid $5
	sndmutech
	sndend
BGMCmdTable_6301: 
	sndsetloop $04
	sndlenid $2
	snddb $18
	sndloop
	sndlenid $3
	snddb $18
	snddb $18
	sndlenid $5
	sndmutech
	sndsetloop $04
	sndlenid $2
	snddb $18
	sndloop
	sndsetloop $04
	sndlenid $3
	snddb $18
	sndloop
	sndsetloop $04
	sndlenid $2
	snddb $18
	sndloop
	sndend
BGMHeader_ParsleyWoods:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_ParsleyWoods_Ch1
	dw BGMChunk_ParsleyWoods_Ch2
	dw $0000
	dw BGMChunk_ParsleyWoods_Ch4
BGMChunk_ParsleyWoods_Ch1:
	dw BGMCmdTable_5ABE
	dw BGMCmdTable_5BAD
.loop:
	dw BGMCmdTable_5A55
	dw BGMCmdTable_6342
	dw BGMCmdTable_5A58
	dw BGMCmdTable_6342
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_ParsleyWoods_Ch2:
	dw BGMCmdTable_5AC3
	dw BGMTBLCMD_REDIR, BGMChunk_ParsleyWoods_Ch1.loop
BGMChunk_ParsleyWoods_Ch4:
.loop:
	dw BGMCmdTable_6380
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_6342: 
	sndsetloop $04
	sndlenid $2
	snddb $50
	snddb $58
	sndloop
	sndsetloop $04
	snddb $4e
	snddb $56
	sndloop
	sndsetloop $04
	snddb $50
	snddb $58
	sndloop
	sndsetloop $04
	snddb $56
	snddb $5e
	sndloop
	sndsetloop $04
	snddb $54
	snddb $5c
	sndloop
	sndsetloop $04
	snddb $52
	snddb $5a
	sndloop
	sndsetloop $04
	snddb $50
	snddb $58
	sndloop
	sndsetloop $04
	snddb $56
	snddb $5e
	sndloop
	sndsetloop $04
	snddb $5c
	snddb $64
	sndloop
	sndsetloop $04
	snddb $62
	snddb $6a
	sndloop
	sndsetloop $04
	snddb $68
	snddb $70
	sndloop
	sndsetloop $04
	snddb $60
	snddb $68
	sndloop
	sndend
BGMCmdTable_6380: 
	sndlenid $4
	snddb $18
	snddb $18
	sndsetloop $08
	sndmutech
	sndloop
	sndlenid $3
	snddb $18
	snddb $18
	sndsetloop $08
	sndlenid $1
	snddb $18
	sndloop
	sndend
BGMHeader_SSTeacup:
	db $00
	dw BGMLenTable_5A0D
	dw BGMChunk_SSTeacup_Ch1
	dw BGMChunk_SSTeacup_Ch2
	dw BGMChunk_SSTeacup_Ch3
	dw $0000
BGMChunk_SSTeacup_Ch1:
.loop:
	dw BGMCmdTable_5A55
	dw BGMCmdTable_5ADC
	dw BGMCmdTable_63CB
	dw BGMCmdTable_5AC3
	dw BGMCmdTable_63CB
	dw BGMCmdTable_5A5E
	dw BGMCmdTable_5ADC
	dw BGMCmdTable_63CB
	dw BGMCmdTable_5AC3
	dw BGMCmdTable_63CB
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_SSTeacup_Ch2:
.loop:
	dw BGMCmdTable_5AEB
	dw BGMCmdTable_63D7
	dw BGMCmdTable_5AD7
	dw BGMCmdTable_63D7
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_SSTeacup_Ch3:
	dw BGMCmdTable_5BAD
.loop:
	dw BGMCmdTable_5B4F
	dw BGMCmdTable_63CB
	dw BGMCmdTable_63CB
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_63CB: 
	sndsetloop $08
	sndlenid $3
	snddb $26
	snddb $2a
	sndloop
	sndsetloop $08
	snddb $26
	snddb $2c
	sndloop
	sndend
BGMCmdTable_63D7: 
	sndsetloop $04
	sndlenid $2
	snddb $32
	snddb $32
	snddb $38
	snddb $38
	snddb $3e
	snddb $3e
	snddb $42
	snddb $42
	sndloop
	sndsetloop $04
	snddb $32
	snddb $32
	snddb $38
	snddb $38
	snddb $3e
	snddb $3e
	snddb $44
	snddb $44
	sndloop
	sndend
BGMHeader_SyrupCastle:
	db $00
	dw BGMLenTable_5A0D
	dw BGMChunk_SyrupCastle_Ch1
	dw BGMChunk_SyrupCastle_Ch2
	dw BGMChunk_SyrupCastle_Ch3
	dw $0000
BGMChunk_SyrupCastle_Ch1:
	dw BGMCmdTable_5ADC
	dw BGMCmdTable_5BAD
.loop:
	dw BGMCmdTable_6414
	dw BGMCmdTable_6421
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_SyrupCastle_Ch2:
	dw BGMCmdTable_5AEB
	dw BGMTBLCMD_REDIR, BGMChunk_SyrupCastle_Ch1.loop
BGMChunk_SyrupCastle_Ch3:
.loop:
	dw BGMCmdTable_5B77
	dw BGMCmdTable_642E
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_6414: 
	sndsetloop $04
	sndlenid $3
	snddb $36
	snddb $40
	snddb $4a
	snddb $54
	snddb $32
	snddb $3c
	snddb $46
	snddb $50
	sndloop
	sndend
BGMCmdTable_6421: 
	sndsetloop $04
	sndlenid $3
	snddb $38
	snddb $42
	snddb $4c
	snddb $56
	snddb $34
	snddb $3e
	snddb $48
	snddb $52
	sndloop
	sndend
BGMCmdTable_642E: 
	sndlenid $5
	snddb $32
	snddb $28
	snddb $26
	snddb $20
	snddb $1e
	snddb $2a
	snddb $28
	sndlenid $4
	sndhienv
	snddb $28
	sndlenid $5
	snddb $2a
	snddb $20
	snddb $1e
	snddb $20
	sndlenid $6
	snddb $1c
	snddb $28
	sndend
BGMHeader_Course1:
	db $00
	dw BGMLenTable_5A0D
	dw BGMChunk_Course1_Ch1
	dw BGMChunk_Course1_Ch2
	dw BGMChunk_Course1_Ch3
	dw BGMChunk_Course1_Ch4
BGMChunk_Course1_Ch1:
	dw BGMCmdTable_5A8C
	dw BGMCmdTable_64AD
.loop:
	dw BGMCmdTable_5A91
	dw BGMCmdTable_64CC
	dw BGMCmdTable_64E7
	dw BGMCmdTable_64FD
	dw BGMCmdTable_64E7
	dw BGMCmdTable_5AFF
	dw BGMCmdTable_6531
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Course1_Ch2:
	dw BGMCmdTable_5AA0
	dw BGMCmdTable_6551
	dw BGMCmdTable_5A8C
	dw BGMCmdTable_6568
.loop:
	dw BGMCmdTable_5A9B
	dw BGMCmdTable_6572
	dw BGMCmdTable_65A5
	dw BGMCmdTable_65BE
	dw BGMCmdTable_5B0E
	dw BGMCmdTable_660B
	dw BGMCmdTable_5AFF
	dw BGMCmdTable_6617
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Course1_Ch3:
	dw BGMCmdTable_5B1D
	dw BGMCmdTable_6631
.loop:
	dw BGMCmdTable_5B5E
	dw BGMCmdTable_6650
	dw BGMCmdTable_5B1D
	dw BGMCmdTable_66A6
	dw BGMCmdTable_5B5E
	dw BGMCmdTable_66AD
	dw BGMCmdTable_5B6D
	dw BGMCmdTable_6650
	dw BGMCmdTable_5B1D
	dw BGMCmdTable_66A6
	dw BGMCmdTable_5BA7
	dw BGMCmdTable_5B36
	dw BGMCmdTable_66D9
	dw BGMCmdTable_5B1D
	dw BGMCmdTable_670B
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Course1_Ch4:
	dw BGMCmdTable_671B
.loop:
	dw BGMCmdTable_672A
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_64AD: 
	sndlenid $2
	snddb $30
	sndmutech
	snddb $28
	sndmutech
	snddb $1e
	sndmutech
	snddb $18
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $1a
	sndmutech
	snddb $1e
	sndmutech
	snddb $1a
	sndmutech
	snddb $18
	sndlenid $7
	sndmutech
	sndlenid $3
	sndmutech
	sndlenid $2
	snddb $56
	sndmutech
	snddb $6e
	sndlenid $7
	sndmutech
	sndlenid $4
	sndmutech
	sndend
BGMCmdTable_64CC: 
	sndsetloop $02
	sndlenid $4
	sndmutech
	snddb $28
	sndloop
	sndsetloop $02
	sndmutech
	snddb $2c
	sndloop
	sndsetloop $02
	sndmutech
	snddb $24
	sndloop
	sndsetloop $04
	sndlenid $3
	snddb $32
	sndloop
	sndmutech
	sndlenid $4
	snddb $38
	sndlenid $3
	sndmutech
	sndend
BGMCmdTable_64E7: 
	sndsetloop $02
	sndlenid $4
	sndmutech
	snddb $28
	sndloop
	sndsetloop $02
	sndmutech
	snddb $24
	sndloop
	snddb $22
	sndlenid $3
	sndmutech
	sndlenid $8
	snddb $24
	sndlenid $4
	sndmutech
	snddb $22
	sndlenid $9
	sndmutech
	sndend
BGMCmdTable_64FD: 
	sndlenid $4
	snddb $2a
	snddb $2a
	snddb $36
	snddb $36
	snddb $32
	snddb $32
	sndlenid $3
	sndmutech
	sndlenid $8
	snddb $3a
	sndlenid $4
	snddb $3e
	sndmutech
	sndmutech
	snddb $44
	sndlenid $3
	snddb $48
	snddb $4a
	snddb $4c
	snddb $4e
	sndmutech
	snddb $6e
	snddb $56
	sndmutech
	sndsetloop $02
	sndlenid $4
	sndmutech
	snddb $28
	sndloop
	sndmutech
	snddb $2c
	sndlenid $5
	sndmutech
	sndsetloop $02
	sndlenid $4
	sndmutech
	snddb $36
	sndloop
	sndsetloop $04
	sndlenid $3
	snddb $4a
	sndloop
	sndmutech
	sndlenid $4
	snddb $50
	sndlenid $3
	sndmutech
	sndend
BGMCmdTable_6531: 
	sndlenid $4
	snddb $36
	snddb $30
	snddb $28
	snddb $1e
	sndlenid $3
	snddb $1a
	snddb $24
	snddb $2c
	sndlenid $4
	snddb $32
	sndlenid $8
	sndmutech
	sndlenid $4
	snddb $30
	sndlenid $3
	snddb $48
	snddb $48
	snddb $4a
	sndlenid $4
	snddb $4c
	sndlenid $3
	snddb $4e
	sndlenid $9
	sndmutech
	sndlenid $4
	snddb $56
	snddb $60
	snddb $28
	sndmutech
	snddb $28
	sndend
BGMCmdTable_6551: 
	sndlenid $2
	snddb $40
	sndmutech
	snddb $36
	sndmutech
	snddb $30
	sndmutech
	snddb $28
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $2a
	sndmutech
	snddb $2e
	sndmutech
	snddb $2a
	sndmutech
	snddb $28
	sndlenid $7
	sndmutech
	sndlenid $4
	sndmutech
	sndend
BGMCmdTable_6568: 
	sndlenid $2
	snddb $28
	sndmutech
	snddb $24
	sndmutech
	snddb $22
	sndmutech
	snddb $1e
	sndmutech
	sndend
BGMCmdTable_6572: 
	sndlenid $4
	snddb $32
	snddb $3a
	snddb $28
	snddb $3a
	snddb $36
	snddb $3c
	snddb $2c
	snddb $3c
	snddb $28
	snddb $36
	snddb $28
	snddb $36
	sndlenid $3
	snddb $32
	snddb $36
	snddb $38
	snddb $3a
	sndmutech
	sndlenid $4
	snddb $48
	sndlenid $3
	snddb $28
	sndlenid $4
	snddb $32
	snddb $3a
	snddb $2e
	snddb $3a
	snddb $2c
	snddb $32
	snddb $2a
	snddb $32
	sndlenid $4
	snddb $28
	sndlenid $3
	sndmutech
	sndlenid $8
	snddb $28
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $32
	sndmutech
	sndlenid $4
	snddb $2a
	sndlenid $3
	snddb $28
	snddb $1a
	sndlenid $8
	sndmutech
	sndend
BGMCmdTable_65A5: 
	sndlenid $4
	snddb $3a
	snddb $3a
	snddb $42
	snddb $42
	snddb $44
	snddb $44
	sndlenid $3
	sndmutech
	sndlenid $4
	snddb $4a
	sndlenid $3
	snddb $52
	sndlenid $4
	snddb $4e
	sndmutech
	sndmutech
	snddb $56
	sndlenid $3
	snddb $58
	snddb $5c
	snddb $5e
	snddb $60
	sndmutech
	sndend
BGMCmdTable_65BE: 
	sndlenid $3
	snddb $28
	snddb $2c
	snddb $30
	sndlenid $4
	snddb $32
	snddb $3a
	snddb $28
	snddb $3a
	snddb $36
	snddb $3c
	sndlenid $3
	sndmutech
	snddb $36
	snddb $3a
	snddb $3c
	sndsetloop $02
	snddb $40
	sndmutech
	snddb $48
	sndmutech
	sndloop
	sndlenid $2
	snddb $32
	sndmutech
	snddb $36
	sndmutech
	snddb $38
	sndmutech
	snddb $3a
	sndlenid $7
	sndmutech
	sndlenid $4
	snddb $48
	sndlenid $3
	snddb $28
	snddb $32
	sndmutech
	snddb $3a
	sndmutech
	snddb $2e
	sndmutech
	snddb $3a
	sndmutech
	snddb $2c
	sndmutech
	snddb $32
	sndmutech
	snddb $2a
	sndmutech
	snddb $32
	sndmutech
	sndlenid $4
	snddb $28
	sndlenid $3
	sndmutech
	sndlenid $8
	snddb $28
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $32
	sndlenid $4
	snddb $2a
	sndlenid $3
	snddb $28
	sndlenid $2
	snddb $1a
	sndmutech
	snddb $4a
	sndmutech
	snddb $48
	sndmutech
	snddb $44
	sndmutech
	sndend
BGMCmdTable_660B: 
	sndlenid $4
	snddb $40
	snddb $36
	snddb $30
	snddb $28
	sndlenid $3
	snddb $24
	snddb $2c
	snddb $32
	sndlenid $4
	snddb $3c
	sndend
BGMCmdTable_6617: 
	sndlenid $3
	snddb $3a
	snddb $3c
	snddb $3e
	sndlenid $4
	snddb $40
	sndlenid $3
	snddb $58
	snddb $58
	snddb $5c
	sndlenid $4
	snddb $5e
	sndlenid $3
	snddb $60
	sndmutech
	snddb $42
	snddb $40
	snddb $2a
	snddb $28
	sndmutech
	sndlenid $4
	snddb $58
	snddb $62
	sndlenid $9
	sndmutech
	sndend
BGMCmdTable_6631: 
	sndlenid $2
	snddb $36
	sndmutech
	snddb $30
	sndmutech
	snddb $28
	sndmutech
	snddb $1e
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $20
	sndmutech
	snddb $24
	sndmutech
	snddb $20
	sndmutech
	snddb $1e
	sndlenid $7
	sndmutech
	sndlenid $3
	sndmutech
	sndlenid $2
	snddb $70
	sndmutech
	snddb $88
	sndlenid $7
	sndmutech
	sndlenid $4
	sndmutech
	sndend
BGMCmdTable_6650: 
	sndlenid $3
	snddb $4a
	sndmutech
	snddb $40
	sndmutech
	snddb $3a
	sndmutech
	snddb $32
	snddb $34
	sndlenid $2
	snddb $36
	sndmutech
	snddb $34
	sndmutech
	snddb $36
	sndmutech
	snddb $44
	sndmutech
	sndlenid $5
	sndmutech
	sndlenid $3
	snddb $48
	sndmutech
	snddb $3c
	sndmutech
	snddb $36
	snddb $34
	sndlenid $2
	snddb $36
	sndmutech
	snddb $3c
	sndmutech
	snddb $3a
	sndmutech
	snddb $3c
	sndmutech
	snddb $3e
	sndmutech
	snddb $40
	sndlenid $7
	sndmutech
	sndlenid $4
	snddb $40
	sndlenid $3
	sndmutech
	sndlenid $3
	snddb $4a
	sndmutech
	snddb $40
	sndmutech
	snddb $3a
	sndmutech
	snddb $32
	snddb $34
	sndlenid $2
	snddb $36
	sndmutech
	snddb $34
	sndmutech
	snddb $36
	sndmutech
	sndlenid $3
	snddb $42
	sndmutech
	snddb $42
	snddb $46
	snddb $42
	sndlenid $2
	snddb $40
	sndmutech
	snddb $4a
	sndmutech
	snddb $52
	sndmutech
	sndlenid $4
	snddb $54
	sndlenid $2
	snddb $4e
	sndmutech
	snddb $44
	sndmutech
	snddb $48
	sndmutech
	snddb $4a
	sndmutech
	sndend
BGMCmdTable_66A6: 
	sndlenid $4
	snddb $2a
	sndlenid $3
	snddb $28
	sndlenid $3
	snddb $1a
	sndend
BGMCmdTable_66AD: 
	sndlenid $3
	snddb $32
	snddb $36
	snddb $38
	sndlenid $3
	snddb $3a
	sndmutech
	snddb $30
	sndmutech
	snddb $2a
	sndmutech
	snddb $22
	sndmutech
	snddb $2c
	snddb $2e
	sndlenid $2
	snddb $30
	sndmutech
	snddb $32
	sndlenid $7
	sndmutech
	sndlenid $3
	snddb $32
	snddb $30
	snddb $2c
	snddb $36
	sndmutech
	snddb $34
	sndmutech
	snddb $36
	snddb $3a
	snddb $3c
	snddb $3e
	sndlenid $3
	snddb $40
	sndlenid $5
	sndmutech
	sndlenid $2
	snddb $88
	sndmutech
	snddb $70
	sndlenid $7
	sndmutech
	sndend
BGMCmdTable_66D9: 
	sndlenid $2
	snddb $48
	sndmutech
	snddb $28
	sndmutech
	snddb $40
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $36
	sndmutech
	snddb $28
	sndmutech
	snddb $30
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $2c
	sndmutech
	snddb $32
	sndmutech
	snddb $3c
	sndmutech
	snddb $44
	sndmutech
	snddb $28
	sndlenid $7
	sndmutech
	sndlenid $4
	sndmutech
	snddb $28
	sndmutech
	sndlenid $2
	snddb $24
	sndmutech
	sndlenid $3
	snddb $26
	sndmutech
	sndlenid $2
	snddb $28
	sndmutech
	sndlenid $3
	sndmutech
	snddb $42
	snddb $40
	snddb $2a
	sndlenid $2
	snddb $28
	sndmutech
	sndend
BGMCmdTable_670B: 
	snddb $10
	sndmutech
	snddb $14
	sndmutech
	snddb $18
	sndmutech
	sndlenid $3
	snddb $1a
	sndmutech
	snddb $3a
	sndmutech
	snddb $28
	sndmutech
	snddb $3a
	sndmutech
	sndend
BGMCmdTable_671B: 
	sndlenid $4
	snddb $1c
	sndlenid $6
	sndmutech
	sndlenid $3
	sndmutech
	sndlenid $2
	snddb $1c
	snddb $1c
	sndsetloop $04
	sndlenid $3
	snddb $1c
	sndloop
	sndend
BGMCmdTable_672A: 
	sndsetloop $04
	sndlenid $3
	snddb $2c
	sndloop
	snddb $1c
	snddb $2c
	snddb $2c
	snddb $2c
	sndsetloop $04
	sndlenid $3
	snddb $2c
	sndloop
	snddb $1c
	snddb $2c
	snddb $2c
	snddb $1c
	sndend
BGMHeader_Cave:
	db $00
	dw BGMLenTable_5A2B
	dw BGMChunk_Cave_Ch1
	dw BGMChunk_Cave_Ch2
	dw BGMChunk_Cave_Ch3
	dw BGMChunk_Cave_Ch4
BGMChunk_Cave_Ch1:
	dw BGMCmdTable_5AC3
	dw BGMCmdTable_5BAD
.loop:
	dw BGMCmdTable_676C
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Cave_Ch2:
	dw BGMCmdTable_5AE6
	dw BGMTBLCMD_REDIR, BGMChunk_Cave_Ch1.loop
BGMChunk_Cave_Ch3:
	dw BGMCmdTable_5BA1
.loop:
	dw BGMCmdTable_5B5E
	dw BGMCmdTable_679E
	dw BGMCmdTable_67A4
	dw BGMCmdTable_679E
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Cave_Ch4:
.loop:
	dw BGMCmdTable_67FF
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_676C: 
	sndlenid $3
	snddb $50
	snddb $4a
	snddb $48
	snddb $4a
	snddb $50
	snddb $4a
	snddb $54
	snddb $4a
	snddb $48
	snddb $4a
	snddb $54
	snddb $4a
	snddb $56
	snddb $4a
	snddb $48
	snddb $4a
	snddb $56
	snddb $4a
	snddb $58
	snddb $4a
	snddb $48
	snddb $4a
	snddb $58
	snddb $4a
	snddb $5a
	snddb $4a
	snddb $48
	snddb $4a
	snddb $5a
	snddb $4a
	snddb $58
	snddb $4a
	snddb $48
	snddb $4a
	snddb $58
	snddb $4a
	snddb $56
	snddb $4a
	snddb $48
	snddb $4a
	snddb $56
	snddb $4a
	snddb $54
	snddb $4a
	snddb $48
	snddb $4a
	snddb $54
	snddb $4a
	sndend
BGMCmdTable_679E: 
	sndsetloop $03
	sndlenid $9
	sndmutech
	sndloop
	sndend
BGMCmdTable_67A4: 
	sndlenid $5
	sndmutech
	sndlenid $3
	sndmutech
	sndlenid $2
	snddb $2e
	snddb $30
	sndlenid $3
	snddb $32
	sndlenid $8
	sndmutech
	sndlenid $2
	snddb $28
	sndmutech
	snddb $20
	sndmutech
	sndlenid $3
	snddb $1a
	sndlenid $8
	sndmutech
	sndlenid $3
	snddb $1c
	sndmutech
	snddb $1e
	sndmutech
	sndmutech
	sndlenid $2
	snddb $2a
	sndmutech
	snddb $2e
	sndmutech
	snddb $2a
	sndmutech
	snddb $28
	sndmutech
	snddb $26
	sndmutech
	sndlenid $3
	snddb $28
	sndmutech
	sndmutech
	snddb $28
	snddb $26
	sndmutech
	sndmutech
	sndlenid $2
	snddb $32
	sndmutech
	snddb $36
	sndmutech
	snddb $32
	sndmutech
	sndlenid $3
	snddb $30
	sndlenid $2
	snddb $2c
	snddb $2a
	sndlenid $3
	snddb $28
	sndmutech
	sndmutech
	snddb $28
	snddb $2a
	sndmutech
	sndmutech
	sndlenid $2
	snddb $20
	sndmutech
	snddb $1e
	sndmutech
	snddb $1a
	sndmutech
	snddb $18
	snddb $1a
	snddb $1c
	snddb $1e
	sndlenid $3
	snddb $2a
	sndlenid $2
	snddb $28
	sndmutech
	snddb $10
	sndmutech
	snddb $14
	snddb $18
	sndlenid $3
	snddb $1a
	sndmutech
	sndlenid $5
	sndmutech
	sndend
BGMCmdTable_67FF: 
	sndlenid $4
	snddb $28
	sndsetloop $04
	sndlenid $3
	snddb $1c
	sndloop
	sndlenid $4
	snddb $28
	snddb $18
	snddb $1c
	sndend
BGMHeader_Lava:
	db $00
	dw BGMLenTable_5A1C
	dw BGMChunk_Lava_Ch1
	dw BGMChunk_Lava_Ch2
	dw BGMChunk_Lava_Ch3
	dw $0000
BGMChunk_Lava2_Ch1:
BGMChunk_Lava_Ch1:
	dw BGMCmdTable_5ADC
	dw BGMCmdTable_5BAD
.loop:
	dw BGMCmdTable_6834
	dw BGMCmdTable_6834
	dw BGMCmdTable_6862
	dw BGMCmdTable_6862
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Lava2_Ch2:
BGMChunk_Lava_Ch2:
	dw BGMCmdTable_5AEB
	dw BGMTBLCMD_REDIR, BGMChunk_Lava_Ch1.loop
BGMChunk_Lava2_Ch3:
BGMChunk_Lava_Ch3:
	dw BGMCmdTable_5B4F
	dw BGMCmdTable_7A66
	dw BGMTBLCMD_REDIR, BGMChunk_Lava_Ch1.loop

BGMCmdTable_6834: 
	sndsetloop $02
	sndlenid $3
	snddb $30
	snddb $34
	snddb $48
	snddb $34
	snddb $30
	snddb $34
	snddb $30
	snddb $34
	sndloop
	sndsetloop $02
	snddb $2e
	snddb $36
	snddb $4a
	snddb $36
	snddb $2e
	snddb $36
	snddb $2e
	snddb $36
	sndloop
	sndsetloop $02
	snddb $2c
	snddb $38
	snddb $4c
	snddb $38
	snddb $2c
	snddb $38
	snddb $2c
	snddb $38
	sndloop
	sndsetloop $02
	snddb $2e
	snddb $36
	snddb $4a
	snddb $36
	snddb $2e
	snddb $36
	snddb $2e
	snddb $36
	sndloop
	sndend
BGMCmdTable_6862: 
	sndsetloop $02
	snddb $3e
	snddb $46
	snddb $5a
	snddb $46
	snddb $3e
	snddb $46
	snddb $3e
	snddb $46
	sndloop
	sndsetloop $02
	snddb $3c
	snddb $44
	snddb $58
	snddb $44
	snddb $3c
	snddb $44
	snddb $3c
	snddb $44
	sndloop
	sndend
BGMHeader_Lava2:
	db $FC
	dw BGMLenTable_5A2B
	dw BGMChunk_Lava2_Ch1
	dw BGMChunk_Lava2_Ch2
	dw BGMChunk_Lava2_Ch3
	dw BGMChunk_Lava2_Ch4
	
BGMHeader_Water:
	db $00
	dw BGMLenTable_5A1C
	dw BGMChunk_Water_Ch1
	dw BGMChunk_Water_Ch2
	dw BGMChunk_Water_Ch3
	dw $0000
BGMChunk_Water_Ch1:
	dw BGMCmdTable_5ADC
	dw BGMCmdTable_5BAD
	dw BGMCmdTable_68C3
.loop:
	dw BGMCmdTable_68C3
	dw BGMCmdTable_68C3
	dw BGMCmdTable_68D8
	dw BGMCmdTable_68E3
	dw BGMCmdTable_68D8
	dw BGMCmdTable_68EE
	dw BGMCmdTable_68C3
	dw BGMCmdTable_68FD
	dw BGMCmdTable_68C3
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Water_Ch2:
	dw BGMCmdTable_5B04
	dw BGMCmdTable_68C3
	dw BGMTBLCMD_REDIR, BGMChunk_Water_Ch1.loop
BGMChunk_Water_Ch3:
	dw BGMCmdTable_5B4A
	dw BGMCmdTable_691C
.loop:
	dw BGMCmdTable_6922
	dw BGMCmdTable_6916
	dw BGMCmdTable_691C
	dw BGMCmdTable_691C
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_68C3: 
	sndsetloop $02
	sndlenid $3
	snddb $1a
	snddb $28
	snddb $30
	snddb $3a
	sndlenid $4
	snddb $48
	sndloop
	sndsetloop $02
	sndlenid $3
	snddb $1c
	snddb $2a
	snddb $32
	snddb $3c
	sndlenid $4
	snddb $4a
	sndloop
	sndend
BGMCmdTable_68D8: 
	sndsetloop $02
	sndlenid $3
	snddb $12
	snddb $20
	snddb $28
	snddb $32
	sndlenid $4
	snddb $40
	sndloop
	sndend
BGMCmdTable_68E3: 
	sndsetloop $02
	sndlenid $3
	snddb $e
	snddb $1c
	snddb $24
	snddb $2e
	sndlenid $4
	snddb $3c
	sndloop
	sndend
BGMCmdTable_68EE: 
	sndlenid $3
	snddb $e
	snddb $1c
	snddb $24
	snddb $2e
	sndlenid $4
	snddb $3c
	sndlenid $3
	snddb $c
	snddb $1a
	snddb $22
	snddb $30
	snddb $3a
	snddb $36
	sndend
BGMCmdTable_68FD: 
	sndsetloop $02
	sndlenid $3
	snddb $1a
	snddb $28
	snddb $30
	snddb $3a
	sndlenid $4
	snddb $48
	sndloop
	sndlenid $3
	snddb $1c
	snddb $2a
	snddb $32
	snddb $3c
	sndlenid $4
	snddb $4a
	sndlenid $3
	snddb $10
	snddb $1e
	snddb $24
	snddb $30
	snddb $3a
	snddb $36
	sndend
BGMCmdTable_6916: 
	sndsetloop $03
	sndlenid $9
	sndmutech
	sndloop
	sndend
BGMCmdTable_691C: 
	sndsetloop $04
	sndlenid $9
	sndmutech
	sndloop
	sndend
BGMCmdTable_6922: 
	sndlenid $8
	snddb $62
	sndlenid $3
	sndhienv
	sndlenid $4
	snddb $58
	sndlenid $8
	snddb $52
	sndlenid $3
	sndhienv
	sndlenid $4
	snddb $4a
	sndlenid $8
	snddb $4c
	sndlenid $3
	sndhienv
	sndlenid $4
	snddb $42
	sndlenid $5
	snddb $5a
	sndlenid $4
	sndhienv
	sndlenid $8
	snddb $58
	sndlenid $3
	sndhienv
	sndlenid $4
	snddb $62
	sndlenid $8
	snddb $6a
	sndlenid $3
	sndhienv
	sndlenid $4
	snddb $70
	sndlenid $8
	snddb $72
	sndlenid $3
	sndhienv
	snddb $6c
	snddb $64
	sndlenid $8
	snddb $5a
	sndlenid $3
	sndhienv
	sndlenid $4
	snddb $5e
	sndlenid $8
	snddb $62
	sndlenid $3
	sndhienv
	sndlenid $4
	snddb $58
	sndlenid $5
	snddb $70
	sndlenid $4
	sndhienv
	sndlenid $8
	snddb $6c
	sndlenid $3
	sndhienv
	sndlenid $4
	snddb $64
	sndlenid $8
	snddb $5a
	sndlenid $3
	sndhienv
	sndlenid $4
	snddb $5e
	sndlenid $8
	snddb $62
	sndlenid $3
	sndhienv
	sndlenid $4
	snddb $58
	sndlenid $5
	snddb $70
	sndlenid $4
	sndhienv
	sndlenid $5
	snddb $6c
	sndlenid $4
	sndhienv
	sndlenid $8
	snddb $6a
	sndlenid $3
	sndhienv
	sndlenid $4
	snddb $66
	sndlenid $5
	snddb $6a
	sndlenid $4
	sndhienv
	sndend
BGMHeader_Ship:
	db $00
	dw BGMLenTable_5A3A
	dw BGMChunk_Ship_Ch1
	dw BGMChunk_Ship_Ch2
	dw $0000
	dw BGMChunk_Ship_Ch4
BGMChunk_Ship_Ch1:
	dw BGMCmdTable_5A78
	dw BGMCmdTable_69AA
.loop:
	dw BGMCmdTable_69B8
	dw BGMCmdTable_69C4
	dw BGMCmdTable_69B8
	dw BGMCmdTable_69CE
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Ship_Ch2:
	dw BGMCmdTable_5B98
.loop:
	dw BGMCmdTable_5A78
	dw BGMCmdTable_6A03
	dw BGMCmdTable_6A0F
	dw BGMCmdTable_6A03
	dw BGMCmdTable_6A15
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_69AA: 
	sndsetloop $02
	sndlenid $8
	snddb $1a
	sndlenid $3
	snddb $10
	sndlenid $3
	snddb $16
	sndlenid $4
	snddb $16
	sndlenid $3
	snddb $18
	sndloop
	sndend
BGMCmdTable_69B8: 
	sndlenid $8
	snddb $1a
	sndlenid $2
	snddb $22
	snddb $24
	sndlenid $8
	snddb $26
	sndlenid $3
	snddb $28
	sndlenid $3
	snddb $2a
	sndend
BGMCmdTable_69C4: 
	sndmutech
	sndlenid $4
	snddb $3e
	snddb $3c
	sndlenid $2
	snddb $28
	snddb $24
	snddb $22
	snddb $1e
	sndend
BGMCmdTable_69CE: 
	sndlenid $4
	snddb $3e
	sndlenid $3
	snddb $3e
	sndlenid $4
	snddb $3c
	sndlenid $2
	snddb $28
	snddb $24
	snddb $22
	snddb $1e
	sndlenid $8
	snddb $1a
	sndlenid $2
	snddb $22
	snddb $24
	sndlenid $8
	snddb $26
	sndlenid $3
	snddb $28
	sndlenid $4
	snddb $2a
	sndmutech
	sndlenid $3
	snddb $2a
	snddb $2a
	snddb $2e
	snddb $2a
	sndlenid $4
	snddb $28
	sndlenid $3
	snddb $56
	snddb $56
	sndlenid $4
	sndmutech
	sndlenid $2
	sndmutech
	snddb $24
	snddb $1c
	snddb $12
	sndlenid $3
	snddb $10
	sndlenid $2
	snddb $1a
	snddb $1c
	sndlenid $4
	snddb $28
	sndlenid $3
	sndmutech
	snddb $10
	snddb $14
	snddb $18
	sndend
BGMCmdTable_6A03: 
	sndlenid $8
	snddb $32
	sndlenid $2
	snddb $3a
	snddb $3c
	sndlenid $8
	snddb $3e
	sndlenid $3
	snddb $40
	sndlenid $3
	snddb $42
	sndend
BGMCmdTable_6A0F: 
	sndmutech
	sndlenid $4
	snddb $4a
	snddb $48
	sndmutech
	sndend
BGMCmdTable_6A15: 
	snddb $50
	snddb $4e
	snddb $4a
	sndlenid $4
	snddb $48
	sndmutech
	sndlenid $8
	snddb $4a
	sndlenid $2
	snddb $40
	snddb $3a
	sndlenid $8
	snddb $32
	sndlenid $3
	snddb $34
	sndlenid $8
	snddb $36
	sndlenid $2
	snddb $34
	snddb $36
	sndlenid $3
	snddb $42
	snddb $42
	snddb $46
	snddb $42
	sndlenid $4
	snddb $40
	sndlenid $3
	snddb $58
	snddb $58
	sndlenid $d
	sndmutech
	sndend
BGMHeader_Train:
	db $01
	dw BGMLenTable_59FE
	dw BGMChunk_Train_Ch1
	dw BGMChunk_Train_Ch2
	dw BGMChunk_Train_Ch3
	dw BGMChunk_Train_Ch4
BGMChunk_Train_Ch2:
BGMChunk_Train_Ch1:
.loop:
	dw BGMCmdTable_5AEB
	dw BGMCmdTable_6A5D
	dw BGMCmdTable_6A67
	dw BGMCmdTable_6A77
	dw BGMCmdTable_6A67
	dw BGMCmdTable_6A91
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Train_Ch3:
.loop:
	dw BGMCmdTable_6B07
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Train_Ch4:
.loop:
	dw BGMCmdTable_6BCC
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_6A5D: 
	sndlenid $3
	sndmutech
	snddb $70
	snddb $70
	sndmutech
	sndmutech
	snddb $54
	snddb $52
	snddb $4e
	sndend
BGMCmdTable_6A67: 
	sndlenid $8
	snddb $4a
	sndlenid $2
	snddb $40
	snddb $3a
	sndlenid $8
	snddb $32
	sndlenid $2
	snddb $30
	snddb $32
	sndlenid $8
	snddb $36
	sndlenid $2
	snddb $34
	snddb $36
	sndend
BGMCmdTable_6A77: 
	sndlenid $4
	snddb $44
	sndmutech
	sndlenid $8
	snddb $48
	sndlenid $2
	snddb $3c
	snddb $36
	sndlenid $8
	snddb $30
	sndlenid $2
	snddb $36
	snddb $3c
	sndlenid $3
	snddb $3a
	snddb $3a
	sndlenid $7
	snddb $3c
	sndlenid $2
	snddb $3e
	sndlenid $3
	snddb $40
	snddb $70
	sndlenid $4
	snddb $70
	sndend
BGMCmdTable_6A91: 
	sndlenid $4
	snddb $42
	sndlenid $2
	sndmutech
	snddb $42
	snddb $46
	snddb $42
	sndlenid $8
	snddb $40
	sndlenid $2
	snddb $4a
	snddb $52
	sndlenid $3
	snddb $54
	snddb $4e
	snddb $44
	snddb $48
	snddb $4a
	snddb $42
	sndlenid $2
	snddb $40
	snddb $3c
	snddb $3a
	snddb $36
	snddb $32
	sndmutech
	snddb $62
	sndmutech
	sndlenid $4
	snddb $62
	sndlenid $2
	sndmutech
	sndsetloop $03
	snddb $44
	snddb $4a
	snddb $4e
	sndloop
	snddb $44
	snddb $4a
	sndlenid $3
	snddb $4e
	snddb $4a
	sndlenid $2
	sndmutech
	sndsetloop $03
	snddb $42
	snddb $4a
	snddb $4e
	sndloop
	snddb $42
	snddb $4a
	sndlenid $3
	snddb $4e
	snddb $4a
	sndlenid $2
	sndmutech
	sndsetloop $03
	snddb $40
	snddb $48
	snddb $4e
	sndloop
	snddb $40
	snddb $48
	sndlenid $3
	snddb $4e
	snddb $48
	sndlenid $2
	sndmutech
	sndsetloop $03
	snddb $44
	snddb $4c
	snddb $52
	sndloop
	snddb $44
	snddb $4c
	sndlenid $3
	snddb $52
	snddb $44
	sndlenid $2
	sndmutech
	sndsetloop $03
	snddb $44
	snddb $4a
	snddb $54
	sndloop
	snddb $44
	snddb $4a
	sndlenid $3
	snddb $54
	snddb $4a
	sndlenid $2
	sndmutech
	sndsetloop $04
	snddb $42
	snddb $4a
	snddb $54
	sndloop
	snddb $52
	snddb $4e
	snddb $4a
	snddb $48
	snddb $58
	snddb $54
	snddb $4e
	snddb $48
	snddb $46
	snddb $44
	snddb $42
	sndlenid $4
	snddb $40
	sndmutech
	sndend
BGMCmdTable_6B07: 
	sndregex3 BGMWaveTable_5BF6,$40
	sndlenid $2
	snddb $28
	sndmutech
	snddb $86
	sndmutech
	snddb $86
	sndmutech
	snddb $34
	snddb $3c
	sndsetloop $02
	snddb $28
	sndmutech
	sndloop
	snddb $2c
	sndmutech
	snddb $30
	sndmutech
	sndsetloop $02
	snddb $32
	sndmutech
	snddb $40
	sndmutech
	snddb $28
	sndmutech
	snddb $40
	sndmutech
	sndloop
	sndsetloop $02
	snddb $36
	sndmutech
	snddb $44
	sndmutech
	snddb $2c
	sndmutech
	snddb $44
	sndmutech
	sndloop
	sndsetloop $02
	snddb $36
	sndmutech
	snddb $40
	sndmutech
	snddb $28
	sndmutech
	snddb $40
	sndmutech
	sndloop
	snddb $32
	sndmutech
	snddb $4a
	sndmutech
	sndlenid $7
	snddb $4e
	sndlenid $2
	snddb $50
	snddb $52
	sndmutech
	snddb $86
	sndmutech
	snddb $86
	snddb $28
	snddb $2c
	snddb $30
	sndsetloop $02
	snddb $32
	sndmutech
	snddb $40
	sndmutech
	sndloop
	sndsetloop $02
	snddb $2e
	sndmutech
	snddb $40
	sndmutech
	sndloop
	sndsetloop $02
	snddb $2c
	sndmutech
	snddb $3c
	sndmutech
	sndloop
	sndsetloop $02
	snddb $2a
	sndmutech
	snddb $3c
	sndmutech
	sndloop
	sndsetloop $02
	snddb $28
	sndmutech
	snddb $3a
	sndmutech
	sndloop
	sndsetloop $02
	snddb $28
	sndmutech
	snddb $3c
	sndmutech
	sndloop
	snddb $1a
	sndmutech
	snddb $42
	sndmutech
	snddb $40
	snddb $3c
	snddb $3a
	snddb $36
	snddb $32
	sndmutech
	snddb $78
	sndmutech
	snddb $78
	snddb $1a
	snddb $1e
	snddb $22
	sndsetloop $04
	snddb $24
	sndmutech
	snddb $24
	sndmutech
	snddb $1a
	sndmutech
	snddb $1a
	sndmutech
	sndloop
	sndsetloop $02
	snddb $22
	sndmutech
	snddb $22
	sndmutech
	snddb $18
	sndmutech
	snddb $18
	sndmutech
	sndloop
	sndsetloop $02
	snddb $14
	sndmutech
	snddb $14
	sndmutech
	snddb $22
	sndmutech
	snddb $22
	sndmutech
	sndloop
	sndsetloop $02
	snddb $1e
	sndmutech
	snddb $1e
	sndmutech
	snddb $2c
	sndmutech
	snddb $2c
	sndmutech
	sndloop
	sndsetloop $02
	snddb $1e
	sndmutech
	snddb $1e
	sndmutech
	snddb $2a
	sndmutech
	snddb $2a
	sndmutech
	sndloop
	sndlenid $4
	snddb $28
	sndmutech
	sndlenid $2
	sndmutech
	snddb $40
	snddb $3c
	snddb $36
	snddb $30
	snddb $2e
	snddb $2c
	snddb $2a
	sndend
BGMCmdTable_6BCC: 
	sndlenid $3
	snddb $2c
	sndlenid $2
	snddb $2c
	snddb $2c
	sndend
BGMHeader_BossLevel:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_BossLevel_Ch1
	dw BGMChunk_BossLevel_Ch2
	dw BGMChunk_BossLevel_Ch3
	dw BGMChunk_BossLevel_Ch4
BGMChunk_BossLevel_Ch1:
	dw BGMCmdTable_5B8C
	dw BGMCmdTable_5A64
	dw BGMCmdTable_5BAD
.loop:
	dw BGMCmdTable_5A55
	dw BGMCmdTable_6C37
	dw BGMCmdTable_5A5E
	dw BGMCmdTable_6C37
	dw BGMCmdTable_5B86
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_BossLevel_Ch2:
	dw BGMCmdTable_5A78
	dw BGMCmdTable_5B8C
	dw BGMTBLCMD_REDIR, BGMChunk_BossLevel_Ch1.loop
BGMChunk_BossLevel_Ch3:
	dw BGMCmdTable_5B8C
.loop:
	dw BGMCmdTable_5A55
	dw BGMCmdTable_5B1D
	dw BGMCmdTable_6C17
	dw BGMCmdTable_6C17
	dw BGMCmdTable_5A5E
	dw BGMCmdTable_6C17
	dw BGMCmdTable_6C17
	dw BGMCmdTable_5A55
	dw BGMCmdTable_6C17
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_FinalLevel_Ch4:
BGMChunk_BossLevel_Ch4:
.loop:
	dw BGMCmdTable_6C65
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_6C17: 
	sndsetloop $02
	sndlenid $2
	snddb $1a
	sndmutech
	sndlenid $3
	snddb $1a
	sndmutech
	sndlenid $2
	snddb $1a
	sndmutech
	sndlenid $6
	sndmutech
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $16
	sndmutech
	snddb $18
	sndmutech
	snddb $1a
	sndmutech
	sndlenid $3
	snddb $1a
	sndmutech
	sndlenid $2
	snddb $1a
	sndmutech
	sndlenid $d
	sndmutech
	sndloop
	sndend
BGMCmdTable_6C37: 
	sndsetloop $02
	sndlenid $4
	snddb $32
	snddb $28
	snddb $22
	snddb $1a
	sndlenid $3
	snddb $1c
	snddb $1a
	snddb $1c
	snddb $2a
	sndmutech
	snddb $2a
	snddb $2e
	snddb $2a
	snddb $28
	snddb $10
	sndmutech
	snddb $10
	sndlenid $6
	sndmutech
	sndlenid $3
	sndmutech
	snddb $10
	snddb $e
	snddb $10
	snddb $12
	snddb $1c
	sndmutech
	snddb $2a
	sndlenid $6
	sndmutech
	sndlenid $3
	sndmutech
	snddb $2a
	snddb $2e
	snddb $2a
	snddb $28
	snddb $32
	sndmutech
	snddb $40
	sndlenid $d
	sndmutech
	sndloop
	sndend
BGMCmdTable_6C65: 
	sndsetloop $04
	sndlenid $3
	snddb $18
	sndloop
	snddb $1c
	sndsetloop $05
	snddb $18
	sndloop
	snddb $1c
	sndsetloop $05
	snddb $18
	sndloop
	sndend
BGMHeader_Course3:
	db $00
	dw BGMLenTable_5A0D
	dw BGMChunk_Course3_Ch1
	dw BGMChunk_Course3_Ch2
	dw BGMChunk_Course3_Ch3
	dw BGMChunk_Course3_Ch4
BGMChunk_Course3_Ch1:
.loop:
	dw BGMCmdTable_5AE1
	dw BGMCmdTable_60D9
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Course3_Ch2:
.loop:
	dw BGMCmdTable_5A87
	dw BGMCmdTable_6CD2
	dw BGMCmdTable_6CDB
	dw BGMCmdTable_6D01
	dw BGMCmdTable_6CDB
	dw BGMCmdTable_6D0F
	dw BGMCmdTable_6D23
	dw BGMCmdTable_5A87
	dw BGMCmdTable_6D4B
	dw BGMCmdTable_6CDB
	dw BGMCmdTable_6D01
	dw BGMCmdTable_6CDB
	dw BGMCmdTable_6D0F
	dw BGMCmdTable_6D51
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Course3_Ch3:
.loop:
	dw BGMCmdTable_5B98
	dw BGMCmdTable_5B5E
	dw BGMCmdTable_6D6E
	dw BGMCmdTable_6DBB
	dw BGMCmdTable_6D6E
	dw BGMCmdTable_6DDB
	dw BGMCmdTable_5B36
	dw BGMCmdTable_6DF6
	dw BGMCmdTable_5B5E
	dw BGMCmdTable_6E1A
	dw BGMCmdTable_6D6E
	dw BGMCmdTable_6DBB
	dw BGMCmdTable_6D6E
	dw BGMCmdTable_6DDB
	dw BGMCmdTable_5B36
	dw BGMCmdTable_6E24
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Course3_Ch4:
.loop:
	dw BGMCmdTable_6113
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_6CD2: 
	sndsetloop $02
	sndlenid $8
	snddb $2
	snddb $a
	sndlenid $4
	snddb $10
	sndloop
	sndend
BGMCmdTable_6CDB: 
	sndlenid $8
	snddb $2
	snddb $a
	sndlenid $4
	snddb $10
	sndlenid $8
	snddb $6
	snddb $c
	sndlenid $4
	snddb $14
	sndlenid $8
	snddb $10
	snddb $18
	sndlenid $4
	snddb $1e
	sndlenid $3
	snddb $1a
	snddb $1e
	snddb $20
	snddb $22
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $10
	sndlenid $2
	snddb $14
	snddb $18
	sndlenid $8
	snddb $1a
	snddb $16
	sndlenid $4
	snddb $16
	sndlenid $8
	snddb $14
	snddb $12
	sndlenid $4
	snddb $12
	sndend
BGMCmdTable_6D01: 
	sndlenid $8
	snddb $10
	snddb $14
	sndlenid $4
	sndmutech
	sndlenid $8
	snddb $6
	sndlenid $3
	sndmutech
	snddb $10
	snddb $5a
	snddb $56
	sndmutech
	sndend
BGMCmdTable_6D0F: 
	sndlenid $8
	snddb $10
	snddb $10
	sndlenid $4
	sndmutech
	sndregex $80,$00,$00,BGMPP_NONE
	sndlenid $2
	snddb $2
	sndmutech
	sndlenid $4
	snddb $12
	sndlenid $3
	snddb $10
	sndlenid $2
	snddb $1a
	sndmutech
	sndend
BGMCmdTable_6D23: 
	sndlenid $2
	snddb $1a
	sndmutech
	snddb $1e
	sndmutech
	snddb $20
	sndmutech
	sndlenid $3
	snddb $22
	snddb $20
	snddb $22
	snddb $2a
	sndmutech
	snddb $30
	snddb $36
	snddb $34
	sndlenid $4
	snddb $32
	sndmutech
	sndlenid $2
	snddb $5c
	sndmutech
	snddb $5c
	sndmutech
	sndlenid $3
	snddb $5c
	sndmutech
	snddb $1e
	snddb $1c
	snddb $1e
	snddb $26
	sndmutech
	snddb $2c
	snddb $3a
	snddb $38
	sndlenid $4
	snddb $36
	sndlenid $5
	sndmutech
	sndend
BGMCmdTable_6D4B: 
	sndlenid $2
	snddb $10
	snddb $c
	snddb $a
	snddb $6
	sndend
BGMCmdTable_6D51: 
	sndlenid $2
	snddb $1a
	sndmutech
	snddb $18
	sndmutech
	snddb $14
	sndmutech
	sndlenid $3
	snddb $10
	snddb $e
	snddb $10
	sndlenid $2
	snddb $18
	sndlenid $7
	sndmutech
	sndlenid $3
	snddb $1e
	snddb $28
	sndmutech
	snddb $30
	snddb $2e
	snddb $30
	snddb $36
	sndlenid $2
	snddb $56
	sndmutech
	sndlenid $8
	sndmutech
	sndend
BGMCmdTable_6D6E: 
	sndlenid $3
	snddb $4a
	sndmutech
	sndlenid $2
	snddb $40
	sndmutech
	snddb $3a
	sndmutech
	sndlenid $3
	snddb $32
	snddb $34
	sndmutech
	snddb $36
	sndmutech
	snddb $34
	snddb $36
	sndlenid $2
	snddb $44
	sndmutech
	snddb $6c
	snddb $70
	snddb $6c
	snddb $6a
	sndlenid $3
	snddb $6c
	sndmutech
	snddb $48
	sndmutech
	sndlenid $2
	snddb $3c
	sndmutech
	snddb $3a
	sndmutech
	sndlenid $3
	snddb $36
	snddb $3c
	sndmutech
	snddb $3a
	sndmutech
	snddb $3c
	snddb $3e
	sndlenid $2
	snddb $40
	sndmutech
	snddb $70
	snddb $6c
	snddb $6a
	snddb $66
	snddb $62
	snddb $60
	snddb $5c
	snddb $58
	sndlenid $3
	snddb $4a
	sndmutech
	sndlenid $2
	snddb $40
	sndmutech
	snddb $3a
	sndmutech
	sndlenid $3
	snddb $32
	snddb $34
	sndmutech
	snddb $36
	sndmutech
	snddb $34
	snddb $36
	sndlenid $2
	snddb $42
	sndlenid $7
	sndmutech
	sndlenid $3
	snddb $42
	snddb $46
	snddb $42
	sndend
BGMCmdTable_6DBB: 
	sndlenid $2
	snddb $40
	sndmutech
	snddb $4a
	sndmutech
	snddb $52
	sndmutech
	snddb $58
	sndlenid $7
	sndmutech
	sndlenid $3
	snddb $58
	snddb $54
	snddb $52
	sndlenid $2
	snddb $54
	sndmutech
	snddb $54
	sndmutech
	snddb $52
	sndmutech
	snddb $4e
	sndmutech
	sndlenid $3
	sndmutech
	sndlenid $2
	snddb $74
	sndmutech
	snddb $70
	sndlenid $7
	sndmutech
	sndend
BGMCmdTable_6DDB: 
	sndlenid $2
	snddb $40
	sndmutech
	snddb $4a
	sndmutech
	snddb $52
	sndmutech
	snddb $54
	sndlenid $7
	sndmutech
	sndlenid $3
	snddb $4e
	sndlenid $2
	snddb $44
	sndmutech
	snddb $48
	sndmutech
	snddb $4a
	sndmutech
	sndlenid $4
	snddb $42
	sndlenid $3
	snddb $40
	snddb $4a
	sndlenid $8
	sndmutech
	sndend
BGMCmdTable_6DF6: 
	sndlenid $3
	snddb $30
	snddb $2e
	snddb $30
	snddb $3a
	sndmutech
	snddb $42
	snddb $48
	snddb $46
	sndlenid $4
	snddb $44
	sndmutech
	sndlenid $2
	snddb $72
	sndmutech
	snddb $72
	sndmutech
	sndlenid $3
	snddb $72
	sndmutech
	snddb $2c
	snddb $2a
	snddb $2c
	snddb $36
	sndmutech
	sndlenid $2
	snddb $3e
	sndmutech
	snddb $36
	sndmutech
	snddb $3a
	snddb $3e
	sndlenid $4
	snddb $40
	sndmutech
	sndend
BGMCmdTable_6E1A: 
	sndlenid $2
	snddb $40
	snddb $3e
	snddb $40
	snddb $42
	snddb $44
	snddb $42
	snddb $44
	snddb $48
	sndend
BGMCmdTable_6E24: 
	sndlenid $2
	snddb $30
	sndmutech
	snddb $2e
	sndmutech
	snddb $30
	sndmutech
	snddb $36
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $40
	sndmutech
	snddb $48
	sndlenid $7
	sndmutech
	sndlenid $3
	snddb $4e
	snddb $4c
	sndlenid $2
	snddb $4e
	sndmutech
	snddb $58
	sndmutech
	snddb $70
	sndmutech
	sndlenid $8
	sndmutech
	sndend
BGMHeader_Ambient:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_Ambient_Ch1
	dw BGMChunk_Ambient_Ch2
	dw BGMChunk_Ambient_Ch3
	dw $0000
BGMChunk_Ambient_Ch1:
	dw BGMCmdTable_5ACD
	dw BGMCmdTable_5BAD
.loop:
	dw BGMCmdTable_6E64
	dw BGMTBLCMD_REDIR, BGMChunk_Ambient_Ch1.loop
BGMChunk_Ambient_Ch2:
	dw BGMCmdTable_5AE6
	dw BGMTBLCMD_REDIR, BGMChunk_Ambient_Ch1.loop
BGMChunk_Ambient_Ch3:
	dw BGMCmdTable_5B59
	dw BGMCmdTable_7A66
	dw BGMTBLCMD_REDIR, BGMChunk_Ambient_Ch1.loop

BGMCmdTable_6E64: 
	sndsetloop $02
	sndlenid $1
	snddb $88
	snddb $82
	snddb $86
	snddb $80
	snddb $84
	snddb $7e
	snddb $82
	snddb $7c
	sndloop
	sndlenid $6
	sndmutech
	sndlenid $2
	snddb $1a
	snddb $28
	snddb $30
	snddb $3a
	snddb $40
	snddb $48
	snddb $52
	snddb $58
	sndlenid $4
	snddb $60
	sndlenid $5
	sndmutech
	sndsetloop $02
	sndlenid $1
	snddb $8a
	snddb $84
	snddb $88
	snddb $82
	snddb $86
	snddb $80
	snddb $84
	snddb $7e
	sndloop
	sndlenid $6
	sndmutech
	sndlenid $2
	snddb $1c
	snddb $2a
	snddb $32
	snddb $3c
	snddb $42
	snddb $4a
	snddb $54
	snddb $5a
	sndlenid $4
	snddb $62
	sndlenid $5
	sndmutech
	sndend
BGMHeader_Course32:
	db $00
	dw BGMLenTable_5A2B
	dw $0000
	dw BGMChunk_Course32_Ch2
	dw BGMChunk_Course32_Ch3
	dw BGMChunk_Course32_Ch4
BGMChunk_Course32_Ch2:
.loop:
	dw BGMCmdTable_5B98
	dw BGMCmdTable_5A55
	dw BGMCmdTable_5A73
	dw BGMCmdTable_6EDA
	dw BGMCmdTable_5A5E
	dw BGMCmdTable_6EDA
	dw BGMCmdTable_5A55
	dw BGMCmdTable_6EDA
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Course32_Ch3:
.loop:
	dw BGMCmdTable_5B98
	dw BGMCmdTable_5B5E
	dw BGMCmdTable_6EFE
	dw BGMCmdTable_6EFE
	dw BGMCmdTable_6EFE
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Course32_Ch4:
.loop:
	dw BGMCmdTable_6F3B
	dw BGMCmdTable_6F22
	dw BGMCmdTable_6F22
	dw BGMCmdTable_6F22
	dw BGMCmdTable_6F22
	dw BGMCmdTable_6F22
	dw BGMCmdTable_6F22
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_6EDA: 
	sndsetloop $02
	sndlenid $2
	snddb $10
	sndmutech
	snddb $16
	sndmutech
	snddb $16
	sndmutech
	snddb $10
	sndmutech
	snddb $16
	sndmutech
	snddb $16
	sndmutech
	sndlenid $3
	snddb $14
	sndmutech
	sndlenid $2
	snddb $10
	sndmutech
	snddb $16
	sndmutech
	snddb $16
	sndmutech
	snddb $10
	sndmutech
	snddb $16
	sndmutech
	snddb $16
	snddb $1a
	sndlenid $3
	snddb $1e
	sndmutech
	sndloop
	sndend
BGMCmdTable_6EFE: 
	sndsetloop $02
	sndlenid $2
	snddb $1c
	sndmutech
	snddb $26
	sndmutech
	snddb $26
	sndmutech
	snddb $1c
	sndmutech
	snddb $26
	sndmutech
	snddb $26
	sndmutech
	sndlenid $3
	snddb $24
	sndmutech
	sndlenid $2
	snddb $1c
	sndmutech
	snddb $26
	sndmutech
	snddb $26
	sndmutech
	snddb $1c
	sndmutech
	snddb $26
	sndmutech
	snddb $26
	snddb $2a
	sndlenid $3
	snddb $2e
	sndmutech
	sndloop
	sndend
BGMCmdTable_6F22: 
	sndsetloop $03
	sndlenid $3
	snddb $30
	sndlenid $2
	snddb $2c
	snddb $2c
	sndloop
	sndlenid $3
	snddb $30
	snddb $2c
	sndsetloop $03
	sndlenid $3
	snddb $30
	sndlenid $2
	snddb $2c
	snddb $2c
	sndloop
	sndsetloop $04
	sndlenid $2
	snddb $30
	sndloop
	sndend
BGMCmdTable_6F3B: 
	sndsetloop $06
	sndlenid $3
	snddb $30
	sndlenid $2
	snddb $2c
	snddb $2c
	sndloop
	sndsetloop $08
	sndlenid $2
	snddb $30
	sndloop
	sndend
BGMHeader_Ice:
	db $00
	dw BGMLenTable_5A1C
	dw BGMChunk_Ice_Ch1
	dw BGMChunk_Ice_Ch2
	dw BGMChunk_Ice_Ch3
	dw BGMChunk_Ice_Ch4
BGMChunk_Ice_Ch2:
	dw BGMCmdTable_5AFF
	dw BGMTBLCMD_REDIR, BGMChunk_Ice_Ch3.loop
BGMChunk_Ice_Ch3:
	dw BGMCmdTable_5B4F
	dw BGMCmdTable_5BAD
.loop:
	dw BGMCmdTable_5B98
	dw BGMCmdTable_6F6C
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Ice_Ch4:
.loop:
	dw BGMCmdTable_6FB6
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_6F6C: 
	sndlenid $4
	snddb $4a
	snddb $40
	snddb $3a
	sndlenid $3
	snddb $32
	snddb $34
	snddb $36
	snddb $34
	snddb $36
	snddb $44
	sndlenid $5
	sndmutech
	sndlenid $3
	snddb $4e
	snddb $4c
	snddb $4e
	snddb $5c
	sndlenid $d
	sndmutech
	sndlenid $4
	snddb $48
	snddb $3c
	snddb $36
	sndlenid $3
	snddb $36
	snddb $3c
	snddb $3a
	snddb $3c
	snddb $3e
	snddb $40
	snddb $52
	snddb $54
	snddb $56
	snddb $58
	snddb $6a
	snddb $6c
	snddb $6e
	snddb $70
	sndlenid $d
	sndmutech
	sndlenid $4
	snddb $4a
	snddb $40
	snddb $3a
	sndlenid $3
	snddb $32
	snddb $34
	snddb $36
	snddb $34
	snddb $36
	snddb $42
	sndmutech
	snddb $42
	snddb $46
	snddb $42
	snddb $40
	snddb $4a
	snddb $52
	snddb $54
	sndmutech
	snddb $4e
	snddb $44
	snddb $48
	snddb $4a
	sndmutech
	snddb $62
	snddb $62
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $7a
	snddb $7a
	sndend
BGMCmdTable_6FB6: 
	sndlenid $4
	snddb $2c
	sndlenid $3
	snddb $2c
	snddb $2c
	sndlenid $4
	snddb $18
	sndlenid $3
	snddb $2c
	snddb $2c
	sndsetloop $04
	sndlenid $3
	snddb $2c
	sndloop
	sndlenid $4
	snddb $18
	snddb $c
	sndend
BGMHeader_FinalLevel:
	db $00
	dw BGMLenTable_59E0
	dw BGMChunk_FinalLevel_Ch1
	dw BGMChunk_FinalLevel_Ch2
	dw BGMChunk_FinalLevel_Ch3
	dw BGMChunk_FinalLevel_Ch4
BGMChunk_FinalLevel_Ch1:
.loop:
	dw BGMCmdTable_5A87
	dw BGMCmdTable_5B86
	dw BGMCmdTable_7000
	dw BGMCmdTable_5B86
	dw BGMCmdTable_7000
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_FinalLevel_Ch2:
.loop:
	dw BGMCmdTable_5B86
	dw BGMCmdTable_7017
	dw BGMCmdTable_7017
	dw BGMCmdTable_5B86
	dw BGMCmdTable_7017
	dw BGMCmdTable_7017
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_FinalLevel_Ch3:
.loop:
	dw BGMCmdTable_5A55
	dw BGMCmdTable_5B1D
	dw BGMCmdTable_7040
	dw BGMCmdTable_5A5E
	dw BGMCmdTable_7040
	dw BGMTBLCMD_REDIR, .loop
BGMCmdTable_7000: 
	sndsetloop $02
	sndlenid $5
	snddb $1c
	snddb $1a
	snddb $1c
	snddb $1e
	snddb $24
	snddb $22
	snddb $24
	snddb $26
	sndlenid $d
	sndmutech
	sndmutech
	sndlenid $5
	sndmutech
	sndlenid $3
	snddb $4e
	snddb $50
	snddb $4e
	snddb $50
	sndloop
	sndend
BGMCmdTable_7017: 
	sndregex $A1,$00,$00,BGMPP_NONE
	sndlenid $5
	snddb $26
	snddb $24
	snddb $26
	snddb $28
	snddb $2e
	snddb $2c
	snddb $2e
	snddb $30
	sndlenid $d
	sndmutech
	sndlenid $3
	snddb $4a
	snddb $40
	snddb $3a
	snddb $32
	snddb $34
	sndlenid $4
	snddb $42
	sndlenid $3
	snddb $40
	sndregex $60,$00,$00,BGMPP_NONE
	snddb $4a
	snddb $4e
	snddb $50
	snddb $5e
	sndlenid $5
	snddb $56
	sndlenid $3
	snddb $54
	snddb $56
	snddb $54
	snddb $56
	sndend
BGMCmdTable_7040: 
	sndsetloop $06
	sndlenid $3
	snddb $1a
	sndloenv
	snddb $1a
	sndloenv
	sndlenid $6
	sndmutech
	sndlenid $3
	snddb $32
	snddb $28
	snddb $22
	snddb $1c
	snddb $1a
	sndloenv
	snddb $1a
	sndloenv
	sndlenid $d
	sndmutech
	sndloop
	sndend
BGMHeader_Boss:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_Boss_Ch1
	dw BGMChunk_Boss_Ch2
	dw BGMChunk_Boss_Ch3
	dw BGMChunk_Boss_Ch4
BGMChunk_Boss_Ch1:
	dw BGMCmdTable_5B18
	dw BGMCmdTable_70A9
	dw BGMCmdTable_5BB3
	dw BGMCmdTable_5A87
	dw BGMCmdTable_70D3
.loop:
	dw BGMCmdTable_70D3
	dw BGMCmdTable_70EE
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Boss_Ch2:
	dw BGMCmdTable_5B18
	dw BGMCmdTable_5BB3
	dw BGMCmdTable_70A9
	dw BGMCmdTable_5A87
	dw BGMCmdTable_7109
.loop:
	dw BGMCmdTable_7109
	dw BGMCmdTable_7126
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Boss_Ch3:
	dw BGMCmdTable_5B9E
	dw BGMCmdTable_5BAA
	dw BGMCmdTable_5BB3
	dw BGMCmdTable_5B8C
	dw BGMCmdTable_5B1D
	dw BGMCmdTable_7143
.loop:
	dw BGMCmdTable_717B
	dw BGMCmdTable_7199
	dw BGMCmdTable_717B
	dw BGMCmdTable_719C
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Boss_Ch4:
	dw BGMCmdTable_5BC0
	dw BGMCmdTable_5BCD
	dw BGMCmdTable_5BD3
.loop:
	dw BGMCmdTable_71D9
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_70A9: 
	sndlenid $1
	snddb $3a
	snddb $4a
	snddb $3c
	snddb $4c
	snddb $3e
	snddb $4e
	snddb $40
	snddb $50
	snddb $42
	snddb $52
	snddb $44
	snddb $54
	snddb $46
	snddb $56
	snddb $48
	snddb $58
	snddb $4a
	snddb $5a
	snddb $4c
	snddb $5c
	snddb $4e
	snddb $5e
	snddb $50
	snddb $60
	snddb $52
	snddb $62
	snddb $54
	snddb $64
	snddb $56
	snddb $66
	snddb $58
	snddb $68
	snddb $5a
	snddb $6a
	snddb $5c
	snddb $6c
	snddb $5e
	snddb $6e
	snddb $60
	snddb $70
	sndend
BGMCmdTable_70D3: 
	sndsetloop $02
	sndlenid $4
	sndmutech
	sndlenid $7
	snddb $1a
	sndlenid $2
	snddb $1a
	sndmutech
	snddb $1a
	sndlenid $3
	sndmutech
	sndlenid $4
	snddb $16
	sndmutech
	sndlenid $7
	snddb $1a
	sndlenid $2
	snddb $1a
	sndmutech
	snddb $1a
	sndlenid $3
	sndmutech
	sndlenid $4
	snddb $1c
	sndloop
	sndend
BGMCmdTable_70EE: 
	sndsetloop $02
	sndlenid $4
	sndmutech
	sndlenid $7
	snddb $1e
	sndlenid $2
	snddb $1e
	sndmutech
	snddb $1e
	sndlenid $3
	sndmutech
	sndlenid $4
	snddb $1a
	sndmutech
	sndlenid $7
	snddb $1e
	sndlenid $2
	snddb $1e
	sndmutech
	snddb $1e
	sndlenid $3
	sndmutech
	sndlenid $4
	snddb $20
	sndloop
	sndend
BGMCmdTable_7109: 
	sndsetloop $02
	sndlenid $3
	snddb $2
	snddb $2
	snddb $10
	sndlenid $2
	snddb $2
	snddb $10
	snddb $2
	snddb $10
	sndlenid $3
	snddb $2
	snddb $c
	snddb $4
	snddb $2
	snddb $2
	snddb $10
	sndlenid $2
	snddb $2
	snddb $10
	snddb $2
	snddb $10
	sndlenid $3
	snddb $2
	snddb $12
	snddb $4
	sndloop
	sndend
BGMCmdTable_7126: 
	sndsetloop $02
	sndlenid $3
	snddb $6
	snddb $6
	snddb $14
	sndlenid $2
	snddb $6
	snddb $14
	snddb $6
	snddb $14
	sndlenid $3
	snddb $6
	snddb $10
	snddb $8
	snddb $6
	snddb $6
	snddb $14
	sndlenid $2
	snddb $6
	snddb $14
	snddb $6
	snddb $14
	sndlenid $3
	snddb $6
	snddb $16
	snddb $8
	sndloop
	sndend
BGMCmdTable_7143: 
	sndlenid $2
	snddb $62
	sndmutech
	snddb $58
	sndmutech
	snddb $52
	sndmutech
	snddb $4a
	sndmutech
	snddb $4c
	snddb $4a
	snddb $4c
	snddb $5a
	sndmutech
	snddb $5a
	snddb $5e
	snddb $5a
	snddb $58
	sndmutech
	snddb $4a
	sndlenid $5
	sndmutech
	sndlenid $2
	snddb $40
	snddb $46
	snddb $44
	snddb $42
	snddb $40
	snddb $62
	sndmutech
	snddb $58
	sndmutech
	snddb $52
	sndmutech
	snddb $4a
	sndmutech
	snddb $4c
	snddb $4a
	snddb $4c
	snddb $5a
	sndmutech
	snddb $5a
	snddb $5e
	snddb $5a
	snddb $58
	sndmutech
	snddb $62
	sndlenid $3
	sndmutech
	sndlenid $5
	sndmutech
	sndlenid $2
	snddb $5c
	snddb $5e
	snddb $60
	sndend
BGMCmdTable_717B: 
	sndlenid $2
	snddb $62
	snddb $64
	snddb $66
	snddb $6c
	sndmutech
	snddb $66
	sndmutech
	snddb $5c
	snddb $62
	sndmutech
	snddb $60
	sndmutech
	snddb $58
	sndmutech
	snddb $5c
	sndmutech
	snddb $62
	snddb $64
	snddb $66
	snddb $6c
	sndmutech
	snddb $66
	sndmutech
	snddb $66
	snddb $70
	sndmutech
	snddb $66
	sndmutech
	sndend
BGMCmdTable_7199: 
	sndlenid $4
	snddb $6c
	sndend
BGMCmdTable_719C: 
	sndlenid $2
	snddb $6c
	snddb $70
	snddb $74
	snddb $78
	sndlenid $2
	snddb $7a
	sndmutech
	snddb $70
	sndmutech
	snddb $6a
	sndmutech
	snddb $62
	sndmutech
	snddb $64
	snddb $62
	snddb $64
	snddb $72
	sndmutech
	snddb $72
	snddb $76
	snddb $72
	snddb $70
	sndmutech
	snddb $62
	sndlenid $5
	sndmutech
	sndlenid $2
	snddb $58
	snddb $5e
	snddb $5c
	snddb $5a
	snddb $58
	snddb $7a
	sndmutech
	snddb $70
	sndmutech
	snddb $6a
	sndmutech
	snddb $62
	sndmutech
	snddb $64
	snddb $62
	snddb $64
	snddb $72
	sndmutech
	snddb $72
	snddb $76
	snddb $72
	snddb $70
	snddb $7a
	sndmutech
	snddb $88
	sndlenid $5
	sndmutech
	sndlenid $2
	sndmutech
	snddb $5c
	snddb $5e
	snddb $60
	sndend
BGMCmdTable_71D9: 
	sndlenid $7
	snddb $2c
	sndlenid $2
	snddb $2c
	sndlenid $3
	snddb $18
	snddb $2c
	sndsetloop $02
	sndlenid $2
	snddb $18
	snddb $c
	sndloop
	sndlenid $3
	snddb $18
	snddb $2c
	sndend
BGMHeader_FinalBossIntro:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_FinalBossIntro_Ch1
	dw BGMChunk_FinalBossIntro_Ch2
	dw $0000
	dw BGMChunk_FinalBossIntro_Ch4
BGMChunk_FinalBossIntro_Ch1:
.loop:
	dw BGMCmdTable_5B98
	dw BGMCmdTable_7213
	dw BGMCmdTable_5AD2
	dw BGMTBLCMD_REDIR, BGMChunk_FinalBossIntro_Ch2.loopCh1
BGMChunk_FinalBossIntro_Ch2:
	dw BGMCmdTable_5B98
	dw BGMCmdTable_7217
.loopCh1:
	dw BGMCmdTable_721C
.loop:
	dw BGMCmdTable_723E
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_FinalBossIntro_Ch4:
	dw BGMCmdTable_7244
.loop:
	dw BGMCmdTable_5BC0
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_7213: 
	sndlenid $e
	sndmutech
	sndmutech
	sndend
BGMCmdTable_7217: 
	sndregex $60,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_721C: 
	sndlenid $3
	snddb $40
	snddb $44
	snddb $40
	snddb $3e
	snddb $40
	snddb $4a
	snddb $52
	snddb $58
	snddb $5a
	sndmutech
	snddb $54
	sndmutech
	snddb $4c
	sndmutech
	snddb $42
	sndmutech
	snddb $40
	snddb $42
	snddb $44
	snddb $46
	snddb $48
	sndmutech
	snddb $50
	sndmutech
	snddb $58
	snddb $5a
	snddb $5c
	snddb $5e
	snddb $60
	sndmutech
	snddb $68
	sndmutech
	sndend
BGMCmdTable_723E: 
	sndlenid $1
	snddb $70
	snddb $74
	snddb $70
	snddb $6e
	sndend
BGMCmdTable_7244: 
	sndsetloop $03
	sndlenid $5
	snddb $2c
	snddb $2c
	snddb $2c
	sndlenid $4
	snddb $2c
	snddb $c
	sndloop
	sndend
BGMHeader_FinalBoss:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_FinalBoss_Ch1
	dw BGMChunk_FinalBoss_Ch2
	dw BGMChunk_FinalBoss_Ch3
	dw BGMChunk_FinalBoss_Ch4
BGMChunk_FinalBoss_Ch1:
	dw BGMCmdTable_5B18
	dw BGMCmdTable_70A9
	dw BGMCmdTable_5BB3
	dw BGMCmdTable_5A49
	dw BGMCmdTable_5B8C
.loop:
	dw BGMCmdTable_72EC
	dw BGMCmdTable_7306
	dw BGMCmdTable_730F
	dw BGMCmdTable_72EC
	dw BGMCmdTable_731C
	dw BGMCmdTable_730F
	dw BGMCmdTable_72EC
	dw BGMCmdTable_7306
	dw BGMCmdTable_730F
	dw BGMCmdTable_72EC
	dw BGMCmdTable_731C
	dw BGMCmdTable_5BB9
	dw BGMCmdTable_7325
	dw BGMCmdTable_733A
	dw BGMCmdTable_7325
	dw BGMCmdTable_7351
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_FinalBoss_Ch2:
	dw BGMCmdTable_5B18
	dw BGMCmdTable_5BB3
	dw BGMCmdTable_70A9
	dw BGMCmdTable_5B8C
.loop:
	dw BGMCmdTable_7378
	dw BGMCmdTable_7392
	dw BGMCmdTable_739B
	dw BGMCmdTable_7378
	dw BGMCmdTable_73A8
	dw BGMCmdTable_739B
	dw BGMCmdTable_7378
	dw BGMCmdTable_7392
	dw BGMCmdTable_739B
	dw BGMCmdTable_7378
	dw BGMCmdTable_73A8
	dw BGMCmdTable_5BB9
	dw BGMCmdTable_73B1
	dw BGMCmdTable_73C6
	dw BGMCmdTable_73B1
	dw BGMCmdTable_73DD
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_FinalBoss_Ch3:
	dw BGMCmdTable_5B9E
	dw BGMCmdTable_5BAA
	dw BGMCmdTable_5BB3
	dw BGMCmdTable_5B72
	dw BGMCmdTable_7404
	dw BGMCmdTable_7404
.loop:
	dw BGMCmdTable_7404
	dw BGMCmdTable_7404
	dw BGMCmdTable_7404
	dw BGMCmdTable_7404
	dw BGMCmdTable_7404
	dw BGMCmdTable_7404
	dw BGMCmdTable_7404
	dw BGMCmdTable_7404
	dw BGMCmdTable_7419
	dw BGMCmdTable_7404
	dw BGMCmdTable_7419
	dw BGMCmdTable_7426
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_FinalBoss_Ch4:
	dw BGMCmdTable_5BC0
	dw BGMCmdTable_5BCD
	dw BGMCmdTable_5BD3
	dw BGMCmdTable_5BBC
	dw BGMCmdTable_609F
.loop:
	dw BGMCmdTable_609F
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_72EC: 
	sndregex $D1,$00,$00,BGMPP_NONE
	sndlenid $3
	snddb $40
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $36
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $30
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $28
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $2a
	snddb $28
	snddb $2a
	snddb $38
	sndend
BGMCmdTable_7306: 
	sndlenid $3
	snddb $36
	sndlenid $4
	snddb $1e
	sndlenid $3
	snddb $1e
	sndlenid $6
	sndmutech
	sndend
BGMCmdTable_730F: 
	sndregex $A0,$00,$00,BGMPP_NONE
	sndsetloop $02
	sndlenid $2
	snddb $42
	snddb $46
	snddb $48
	snddb $4a
	sndloop
	sndend
BGMCmdTable_731C: 
	sndlenid $3
	snddb $36
	sndlenid $4
	snddb $40
	sndlenid $3
	snddb $4e
	sndlenid $6
	sndmutech
	sndend
BGMCmdTable_7325: 
	sndregex $A0,$00,$00,BGMPP_NONE
	sndsetloop $02
	sndlenid $2
	snddb $1c
	sndmutech
	snddb $28
	sndmutech
	snddb $30
	sndmutech
	snddb $1a
	sndmutech
	snddb $26
	sndmutech
	snddb $2e
	sndmutech
	sndloop
	sndend
BGMCmdTable_733A: 
	sndlenid $2
	snddb $32
	snddb $34
	snddb $36
	snddb $38
	snddb $3a
	snddb $38
	snddb $3a
	snddb $3c
	sndregex $D1,$00,$00,BGMPP_NONE
	sndlenid $8
	snddb $40
	sndlenid $3
	snddb $36
	sndlenid $4
	sndmutech
	snddb $36
	sndlenid $6
	sndmutech
	sndend
BGMCmdTable_7351: 
	sndlenid $2
	snddb $4c
	snddb $50
	snddb $54
	snddb $58
	snddb $5a
	snddb $5e
	snddb $62
	snddb $64
	sndsetloop $02
	snddb $66
	sndmutech
	snddb $6
	sndmutech
	snddb $6
	sndmutech
	sndloop
	snddb $66
	sndmutech
	snddb $6
	sndmutech
	snddb $7e
	snddb $7c
	snddb $66
	snddb $64
	snddb $4e
	snddb $4c
	snddb $36
	snddb $34
	snddb $36
	snddb $38
	snddb $3a
	snddb $3c
	snddb $3e
	snddb $3c
	snddb $3e
	snddb $42
	sndend
BGMCmdTable_7378: 
	sndregex $D1,$00,$00,BGMPP_NONE
	sndlenid $3
	snddb $4a
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $40
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $3a
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $32
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $34
	snddb $32
	snddb $34
	snddb $42
	sndend
BGMCmdTable_7392: 
	sndlenid $3
	snddb $40
	sndlenid $4
	snddb $28
	sndlenid $3
	snddb $28
	sndlenid $6
	sndmutech
	sndend
BGMCmdTable_739B: 
	sndregex $A0,$00,$00,BGMPP_NONE
	sndsetloop $02
	sndlenid $2
	snddb $4c
	snddb $50
	snddb $52
	snddb $54
	sndloop
	sndend
BGMCmdTable_73A8: 
	sndlenid $3
	snddb $40
	sndlenid $4
	snddb $4a
	sndlenid $3
	snddb $58
	sndlenid $6
	sndmutech
	sndend
BGMCmdTable_73B1: 
	sndregex $A0,$00,$00,BGMPP_NONE
	sndsetloop $02
	sndlenid $2
	snddb $28
	sndmutech
	snddb $34
	sndmutech
	snddb $3c
	sndmutech
	snddb $26
	sndmutech
	snddb $32
	sndmutech
	snddb $3a
	sndmutech
	sndloop
	sndend
BGMCmdTable_73C6: 
	sndlenid $2
	snddb $3c
	snddb $3e
	snddb $40
	snddb $42
	snddb $44
	snddb $42
	snddb $44
	snddb $48
	sndregex $D1,$00,$00,BGMPP_NONE
	sndlenid $8
	snddb $4a
	sndlenid $3
	snddb $40
	sndlenid $4
	sndmutech
	snddb $40
	sndlenid $6
	sndmutech
	sndend
BGMCmdTable_73DD: 
	sndlenid $2
	snddb $54
	snddb $58
	snddb $5a
	snddb $5e
	snddb $62
	snddb $64
	snddb $68
	snddb $6c
	sndsetloop $02
	snddb $70
	sndmutech
	snddb $10
	sndmutech
	snddb $10
	sndmutech
	sndloop
	snddb $6e
	sndmutech
	snddb $10
	sndmutech
	snddb $88
	snddb $86
	snddb $70
	snddb $6e
	snddb $58
	snddb $56
	snddb $40
	snddb $3e
	snddb $40
	snddb $42
	snddb $44
	snddb $46
	snddb $48
	snddb $46
	snddb $48
	snddb $4c
	sndend
BGMCmdTable_7404: 
	sndsetloop $02
	sndlenid $2
	snddb $1a
	sndmutech
	snddb $32
	sndmutech
	snddb $28
	sndmutech
	snddb $22
	sndmutech
	snddb $1a
	sndmutech
	snddb $1c
	sndmutech
	snddb $2a
	sndmutech
	snddb $28
	sndmutech
	sndloop
	sndend
BGMCmdTable_7419: 
	sndsetloop $04
	sndlenid $2
	snddb $1c
	sndmutech
	snddb $34
	sndmutech
	snddb $2a
	sndmutech
	snddb $24
	sndmutech
	sndloop
	sndend
BGMCmdTable_7426: 
	sndsetloop $02
	sndlenid $2
	snddb $72
	sndmutech
	snddb $10
	sndmutech
	snddb $10
	sndmutech
	sndloop
	snddb $70
	sndmutech
	snddb $10
	sndmutech
	snddb $8a
	snddb $88
	snddb $72
	snddb $70
	snddb $5a
	snddb $58
	snddb $42
	snddb $40
	snddb $42
	snddb $44
	snddb $46
	snddb $48
	snddb $4a
	snddb $48
	snddb $4a
	snddb $36
	sndend
;--
BGMHeader_CoinVault:
	db $00
	dw BGMLenTable_5A2B
	dw BGMChunk_CoinVault_Ch1
	dw BGMChunk_CoinVault_Ch2
	dw BGMChunk_CoinVault_Ch3
	dw BGMChunk_CoinVault_Ch4
BGMChunk_CoinVault_Ch1:
.loop:
	dw BGMCmdTable_5B13
	dw BGMCmdTable_7468
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_CoinVault_Ch2:
.loop:
	dw BGMCmdTable_5B0E
	dw BGMCmdTable_7483
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_CoinVault_Ch3:
.loop:
	dw BGMCmdTable_5B36
	dw BGMCmdTable_749E
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_7468: 
	sndlenid $3
	snddb $4a
	snddb $40
	snddb $3a
	snddb $32
	sndlenid $2
	snddb $30
	snddb $2e
	snddb $30
	snddb $40
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $44
	snddb $48
	sndlenid $2
	snddb $4a
	snddb $4e
	snddb $52
	snddb $4e
	sndmutech
	snddb $58
	snddb $56
	snddb $58
	sndlenid $4
	snddb $40
	sndend
BGMCmdTable_7483: 
	sndlenid $3
	snddb $3a
	snddb $3a
	snddb $32
	snddb $28
	sndlenid $2
	snddb $28
	snddb $26
	snddb $28
	snddb $3a
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $3c
	snddb $3c
	sndlenid $2
	snddb $3e
	snddb $44
	snddb $4a
	snddb $48
	sndmutech
	snddb $48
	snddb $46
	snddb $48
	sndlenid $4
	snddb $30
	sndend
BGMCmdTable_749E: 
	sndlenid $2
	snddb $32
	sndmutech
	snddb $40
	sndmutech
	snddb $28
	sndmutech
	snddb $40
	sndmutech
	snddb $3a
	sndmutech
	snddb $48
	sndmutech
	snddb $30
	sndmutech
	snddb $48
	sndmutech
	snddb $3c
	sndmutech
	snddb $4a
	sndmutech
	snddb $3e
	sndmutech
	snddb $4a
	sndmutech
	snddb $40
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $40
	snddb $3c
	snddb $3a
	snddb $36
	sndend
BGMHeader_SelectBonus:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_SelectBonus_Ch1
	dw BGMChunk_SelectBonus_Ch2
	dw BGMChunk_SelectBonus_Ch3
	dw BGMChunk_SelectBonus_Ch4
BGMChunk_SelectBonus_Ch1:
	dw BGMCmdTable_5AB4
	dw BGMCmdTable_74E1
	dw BGMTBLCMD_END
BGMChunk_SelectBonus_Ch2:
	dw BGMCmdTable_5AB4
	dw BGMCmdTable_74F2
	dw BGMTBLCMD_END
BGMChunk_SelectBonus_Ch3:
	dw BGMCmdTable_5B54
	dw BGMCmdTable_7503
	dw BGMTBLCMD_END
BGMChunk_SelectBonus_Ch4:
	dw BGMCmdTable_7513
	dw BGMTBLCMD_END

BGMCmdTable_74E1: 
	sndlenid $3
	snddb $28
	sndmutech
	sndmutech
	snddb $2c
	sndmutech
	snddb $42
	snddb $5a
	sndmutech
	snddb $40
	snddb $3e
	snddb $3c
	snddb $3a
	sndlenid $4
	sndmutech
	snddb $52
	sndend
BGMCmdTable_74F2: 
	sndlenid $3
	snddb $3a
	snddb $38
	snddb $3a
	snddb $3c
	sndmutech
	snddb $44
	snddb $5c
	sndmutech
	snddb $40
	snddb $44
	snddb $48
	snddb $4a
	sndlenid $4
	sndmutech
	snddb $62
	sndend
BGMCmdTable_7503: 
	sndlenid $3
	snddb $32
	sndmutech
	sndmutech
	snddb $36
	sndlenid $5
	sndmutech
	sndlenid $3
	snddb $40
	snddb $3e
	snddb $40
	snddb $32
	sndlenid $4
	sndmutech
	snddb $1a
	sndend
BGMCmdTable_7513: 
	sndlenid $4
	snddb $18
	sndmutech
	sndmutech
	sndlenid $3
	snddb $18
	sndlenid $2
	snddb $18
	snddb $18
	sndsetloop $04
	sndlenid $3
	snddb $18
	sndloop
	sndmutech
	sndsetloop $04
	sndlenid $1
	snddb $18
	sndloop
	sndlenid $4
	snddb $18
	sndend
BGMHeader_LevelClear:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_LevelClear_Ch1
	dw BGMChunk_LevelClear_Ch2
	dw BGMChunk_LevelClear_Ch3
	dw BGMChunk_LevelClear_Ch4
BGMChunk_LevelClear_Ch1:
	dw BGMCmdTable_5AAF
	dw BGMCmdTable_754B
	dw BGMTBLCMD_END
BGMChunk_LevelClear_Ch2:
	dw BGMCmdTable_5AAF
	dw BGMCmdTable_7559
	dw BGMTBLCMD_END
BGMChunk_LevelClear_Ch3:
	dw BGMCmdTable_5B54
	dw BGMCmdTable_7567
	dw BGMTBLCMD_END
BGMChunk_LevelClear_Ch4:
	dw BGMCmdTable_7577
	dw BGMTBLCMD_END

BGMCmdTable_754B: 
	sndlenid $a
	snddb $32
	snddb $3a
	snddb $44
	snddb $40
	sndmutech
	snddb $50
	sndregex $80,$00,$40,BGMPP_NONE
	sndlenid $9
	snddb $50
	sndend
BGMCmdTable_7559: 
	sndlenid $a
	snddb $40
	snddb $4a
	snddb $54
	snddb $50
	sndmutech
	snddb $5e
	sndregex $80,$00,$40,BGMPP_NONE
	sndlenid $9
	snddb $5e
	sndend
BGMCmdTable_7567: 
	sndlenid $f
	snddb $3a
	sndmutech
	snddb $40
	sndmutech
	snddb $4a
	sndmutech
	sndlenid $a
	snddb $46
	sndmutech
	sndlenid $f
	snddb $58
	sndmutech
	sndlenid $9
	snddb $58
	sndend
BGMCmdTable_7577: 
	sndlenid $5
	sndmutech
	sndsetloop $18
	sndlenid $1
	snddb $18
	sndloop
	sndend
BGMHeader_BossClear:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_BossClear_Ch1
	dw BGMChunk_BossClear_Ch2
	dw BGMChunk_BossClear_Ch3
	dw BGMChunk_BossClear_Ch4
BGMChunk_BossClear_Ch1:
	dw BGMCmdTable_5AB4
	dw BGMCmdTable_75A0
	dw BGMTBLCMD_END
BGMChunk_BossClear_Ch2:
	dw BGMCmdTable_5AB4
	dw BGMCmdTable_75B4
	dw BGMTBLCMD_END
BGMChunk_BossClear_Ch3:
	dw BGMCmdTable_5B54
	dw BGMCmdTable_75C8
	dw BGMTBLCMD_END
BGMChunk_BossClear_Ch4:
	dw BGMCmdTable_75E4
	dw BGMTBLCMD_END
BGMCmdTable_75A0: 
	sndlenid $3
	snddb $3a
	snddb $32
	snddb $3a
	snddb $40
	snddb $38
	snddb $40
	snddb $44
	snddb $3c
	snddb $44
	snddb $4a
	snddb $4e
	snddb $50
	sndregex $A0,$00,$40,BGMPP_NONE
	sndlenid $6
	snddb $52
	sndend
BGMCmdTable_75B4: 
	sndlenid $3
	snddb $4a
	snddb $40
	snddb $4a
	snddb $50
	snddb $46
	snddb $50
	snddb $54
	snddb $4a
	snddb $54
	snddb $5a
	snddb $5e
	snddb $60
	sndregex $A0,$00,$40,BGMPP_NONE
	sndlenid $6
	snddb $62
	sndend
BGMCmdTable_75C8: 
	sndlenid $2
	snddb $40
	sndmutech
	snddb $3a
	sndmutech
	snddb $40
	sndmutech
	snddb $46
	sndmutech
	snddb $40
	sndmutech
	snddb $46
	sndmutech
	snddb $4a
	sndmutech
	snddb $44
	sndmutech
	snddb $4a
	sndmutech
	snddb $50
	sndmutech
	snddb $54
	sndmutech
	snddb $56
	sndmutech
	sndlenid $6
	snddb $4a
	sndend
BGMCmdTable_75E4: 
	sndlenid $6
	sndmutech
	sndlenid $3
	sndmutech
	snddb $2c
	snddb $2c
	snddb $2c
	sndsetloop $18
	sndlenid $f
	snddb $2c
	sndloop
	sndend
BGMHeader_LifeLost:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_LifeLost_Ch1
	dw BGMChunk_LifeLost_Ch2
	dw $0000
	dw $0000
BGMChunk_LifeLost_Ch1:
	dw BGMCmdTable_5ABE
	dw BGMCmdTable_5BAD
	dw BGMCmdTable_7627
	dw BGMCmdTable_5A51
	dw BGMCmdTable_5AB9
	dw BGMCmdTable_761A
	dw BGMCmdTable_5B8C
	dw BGMTBLCMD_END;X
BGMChunk_LifeLost_Ch2:
	dw BGMCmdTable_5B09
	dw BGMCmdTable_7627
	dw BGMCmdTable_5BAD
	dw BGMCmdTable_5AB9
	dw BGMCmdTable_7632
	dw BGMCmdTable_5B8C
	dw BGMTBLCMD_END;X

BGMCmdTable_761A: 
	sndlenid $a
	snddb $10
	snddb $e
	snddb $10
	snddb $c
	snddb $a
	snddb $6
	sndlenid $3
	snddb $2
	sndmutech
	snddb $52
	sndmutech
	sndend
BGMCmdTable_7627: 
	sndlenid $1
	snddb $70
	snddb $80
	snddb $6e
	snddb $66
	snddb $84
	snddb $64
	snddb $58
	sndlenid $4
	sndmutech
	sndend
BGMCmdTable_7632: 
	sndlenid $a
	snddb $28
	snddb $26
	snddb $28
	snddb $2a
	snddb $2c
	snddb $30
	sndlenid $3
	snddb $32
	sndmutech
	snddb $62
	sndmutech
	sndend
BGMHeader_TimeOver:
	db $00
	dw BGMLenTable_59E0
	dw BGMChunk_TimeOver_Ch1
	dw BGMChunk_TimeOver_Ch2
	dw BGMChunk_TimeOver_Ch3
	dw $0000
BGMChunk_TimeOver_Ch1:
	dw BGMCmdTable_7658
	dw BGMTBLCMD_END
BGMChunk_TimeOver_Ch2:
	dw BGMCmdTable_7669
	dw BGMTBLCMD_END
BGMChunk_TimeOver_Ch3:
	dw BGMCmdTable_5B1D
	dw BGMCmdTable_767E
	dw BGMTBLCMD_END

BGMCmdTable_7658: 
	sndregex $60,$00,$00,BGMPP_NONE
	sndlenid $4
	snddb $10
	sndmutech
	snddb $12
	sndmutech
	sndmutech
	sndlenid $3
	snddb $24
	sndmutech
	snddb $22
	sndlenid $8
	sndmutech
	sndend
BGMCmdTable_7669: 
	sndregex $70,$00,$00,BGMPP_NONE
	sndlenid $3
	snddb $4a
	snddb $40
	snddb $3a
	snddb $32
	snddb $34
	snddb $32
	snddb $34
	snddb $42
	snddb $40
	sndmutech
	snddb $30
	sndmutech
	snddb $32
	sndlenid $8
	sndmutech
	sndend
BGMCmdTable_767E: 
	sndlenid $4
	snddb $1a
	sndmutech
	snddb $1c
	sndmutech
	sndmutech
	sndlenid $3
	snddb $28
	sndmutech
	snddb $1a
	sndlenid $8
	sndmutech
	sndend
BGMHeader_GameOver:
	db $00
	dw BGMLenTable_5A1C
	dw BGMChunk_GameOver_Ch1
	dw BGMChunk_GameOver_Ch2
	dw $0000
	dw $0000
BGMChunk_GameOver_Ch1:
	dw BGMCmdTable_5AE1
	dw BGMCmdTable_76A2
	dw BGMTBLCMD_END
BGMChunk_GameOver_Ch2:
	dw BGMCmdTable_5A78
	dw BGMCmdTable_76AF
	dw BGMTBLCMD_END

BGMCmdTable_76A2: 
	sndsetloop $02
	sndlenid $3
	snddb $52
	snddb $4a
	snddb $40
	sndloop
	snddb $54
	snddb $48
	sndlenid $4
	snddb $4a
	snddb $62
	sndend
BGMCmdTable_76AF: 
	sndsetloop $02
	sndlenid $3
	snddb $1a
	sndmutech
	snddb $10
	snddb $a
	snddb $2
	snddb $4
	snddb $6
	sndlenid $2
	snddb $12
	snddb $10
	sndlenid $4
	snddb $1a
	snddb $52
	sndend
BGMHeader_Invincible:
	db $02
	dw BGMLenTable_59FE
	dw BGMChunk_Invincible_Ch1
	dw BGMChunk_Invincible_Ch2
	dw BGMChunk_Invincible_Ch3
	dw BGMChunk_Invincible_Ch4
BGMChunk_Invincible_Ch1:
	dw BGMCmdTable_5AE1
	dw BGMCmdTable_76E9
	dw BGMTBLCMD_END
BGMChunk_Invincible_Ch2:
	dw BGMCmdTable_5AA5
	dw BGMCmdTable_7701
	dw BGMCmdTable_771F
	dw BGMCmdTable_5AA5
	dw BGMCmdTable_7701
	dw BGMCmdTable_7748
	dw BGMTBLCMD_END
BGMChunk_Invincible_Ch3:
	dw BGMCmdTable_5B54
	dw BGMCmdTable_776A
	dw BGMTBLCMD_END
BGMChunk_Invincible_Ch4:
	dw BGMCmdTable_7780
	dw BGMTBLCMD_END

BGMCmdTable_76E9: 
	sndsetloop $07
	sndlenid $3
	snddb $8e
	snddb $8e
	sndlenid $7
	snddb $84
	sndlenid $3
	snddb $8e
	snddb $8e
	sndlenid $2
	snddb $8c
	sndlenid $4
	snddb $84
	sndloop
	sndlenid $3
	snddb $84
	sndlenid $7
	snddb $8e
	snddb $8e
	sndlenid $4
	snddb $8e
	sndmutech
	sndend
BGMCmdTable_7701: 
	sndlenid $2
	snddb $28
	snddb $26
	snddb $28
	snddb $32
	snddb $30
	snddb $32
	snddb $3a
	snddb $38
	snddb $3a
	snddb $40
	snddb $3e
	snddb $40
	snddb $4a
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $2a
	snddb $28
	snddb $2a
	snddb $34
	snddb $32
	snddb $34
	snddb $3c
	snddb $3a
	snddb $3c
	snddb $42
	snddb $40
	snddb $42
	sndend
BGMCmdTable_771F: 
	snddb $4c
	sndlenid $7
	sndmutech
	sndlenid $2
	snddb $2c
	snddb $2a
	snddb $2c
	snddb $36
	snddb $34
	snddb $36
	snddb $3e
	sndmutech
	snddb $2e
	snddb $2c
	snddb $2e
	snddb $38
	snddb $36
	snddb $38
	snddb $40
	sndmutech
	snddb $30
	snddb $3a
	snddb $42
	snddb $32
	snddb $3c
	snddb $44
	snddb $34
	snddb $3e
	snddb $46
	snddb $36
	snddb $40
	snddb $48
	sndregex $70,$00,$40,BGMPP_07
	sndlenid $7
	snddb $58
	sndlenid $2
	sndmutech
	sndend
BGMCmdTable_7748: 
	snddb $4c
	snddb $50
	snddb $54
	snddb $56
	snddb $58
	snddb $4e
	snddb $48
	snddb $4e
	snddb $48
	snddb $40
	snddb $48
	snddb $40
	snddb $36
	snddb $40
	snddb $36
	snddb $30
	snddb $28
	snddb $2a
	snddb $2c
	snddb $30
	snddb $32
	sndmutech
	snddb $62
	sndmutech
	sndmutech
	snddb $62
	sndmutech
	sndmutech
	snddb $62
	sndlenid $7
	sndmutech
	sndlenid $4
	sndmutech
	sndend
BGMCmdTable_776A: 
	sndsetloop $1C
	sndlenid $2
	snddb $10
	sndmutech
	snddb $28
	sndmutech
	sndloop
	snddb $32
	sndmutech
	snddb $6a
	sndmutech
	sndmutech
	snddb $6a
	sndmutech
	sndmutech
	snddb $6a
	sndlenid $7
	sndmutech
	sndlenid $4
	sndmutech
	sndend
BGMCmdTable_7780: 
	sndsetloop $06
	sndlenid $3
	snddb $2c
	snddb $2c
	snddb $18
	sndlenid $2
	snddb $2c
	snddb $2c
	sndmutech
	snddb $2c
	sndmutech
	snddb $2c
	sndlenid $3
	snddb $18
	snddb $2c
	sndloop
	sndlenid $3
	snddb $2c
	snddb $2c
	snddb $18
	sndlenid $2
	snddb $2c
	snddb $2c
	sndmutech
	snddb $2c
	sndmutech
	snddb $2c
	snddb $18
	snddb $18
	snddb $18
	snddb $18
	sndlenid $3
	snddb $2c
	sndlenid $7
	snddb $18
	snddb $18
	sndlenid $4
	snddb $18
	sndmutech
	sndend
BGMHeader_CoinBonus:
	db $00
	dw BGMLenTable_5A0D
	dw BGMChunk_CoinBonus_Ch1
	dw BGMChunk_CoinBonus_Ch2
	dw BGMChunk_CoinBonus_Ch3
	dw BGMChunk_CoinBonus_Ch4
BGMChunk_CoinBonus_Ch1:
.loop:
	dw BGMCmdTable_5A78
	dw BGMCmdTable_780E
	dw BGMCmdTable_77E4
	dw BGMCmdTable_780E
	dw BGMCmdTable_7823
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_CoinBonus_Ch2:
.loop:
	dw BGMCmdTable_5A87
	dw BGMCmdTable_77E4
	dw BGMCmdTable_77F9
	dw BGMCmdTable_77E4
	dw BGMCmdTable_780E
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_CoinBonus_Ch3:
.loop:
	dw BGMCmdTable_5B22
	dw BGMCmdTable_7838
	dw BGMCmdTable_7845
	dw BGMCmdTable_7838
	dw BGMCmdTable_7852
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_CoinGame_Ch4:
.loop:
BGMChunk_CoinBonus_Ch4:
.loop:
	dw BGMCmdTable_785F
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_77E4: 
	sndsetloop $02
	sndlenid $3
	sndmutech
	snddb $4a
	sndlenid $2
	sndmutech
	sndlenid $3
	snddb $44
	sndlenid $2
	snddb $40
	sndmutech
	snddb $40
	sndmutech
	snddb $3a
	snddb $40
	snddb $44
	sndlenid $3
	snddb $4a
	sndloop
	sndend
BGMCmdTable_77F9: 
	sndsetloop $02
	sndlenid $3
	sndmutech
	snddb $54
	sndlenid $2
	sndmutech
	sndlenid $3
	snddb $4e
	sndlenid $2
	snddb $4a
	sndmutech
	snddb $4a
	sndmutech
	snddb $44
	snddb $4a
	snddb $4e
	sndlenid $3
	snddb $54
	sndloop
	sndend
BGMCmdTable_780E: 
	sndsetloop $02
	sndlenid $3
	sndmutech
	snddb $40
	sndlenid $2
	sndmutech
	sndlenid $3
	snddb $3a
	sndlenid $2
	snddb $36
	sndmutech
	snddb $36
	sndmutech
	snddb $30
	snddb $36
	snddb $3a
	sndlenid $3
	snddb $40
	sndloop
	sndend
BGMCmdTable_7823: 
	sndsetloop $02
	sndlenid $3
	sndmutech
	snddb $36
	sndlenid $2
	sndmutech
	sndlenid $3
	snddb $30
	sndlenid $2
	snddb $2c
	sndmutech
	snddb $2c
	sndmutech
	snddb $26
	snddb $2c
	snddb $30
	sndlenid $3
	snddb $36
	sndloop
	sndend
BGMCmdTable_7838: 
	sndsetloop $04
	sndlenid $3
	snddb $32
	sndlenid $2
	sndmutech
	snddb $3a
	snddb $40
	sndmutech
	snddb $44
	sndmutech
	sndloop
	sndend
BGMCmdTable_7845: 
	sndsetloop $04
	sndlenid $3
	snddb $3c
	sndlenid $2
	sndmutech
	snddb $44
	snddb $4a
	sndmutech
	snddb $4e
	sndmutech
	sndloop
	sndend
BGMCmdTable_7852: 
	sndsetloop $04
	sndlenid $3
	snddb $28
	sndlenid $2
	sndmutech
	snddb $30
	snddb $36
	sndmutech
	snddb $3a
	sndmutech
	sndloop
	sndend
BGMCmdTable_785F: 
	sndsetloop $1F
	sndlenid $2
	snddb $30
	snddb $2c
	snddb $10
	snddb $2c
	sndloop
	sndsetloop $04
	snddb $30
	sndloop
	sndend
BGMHeader_HeartBonus:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_HeartBonus_Ch1
	dw BGMChunk_HeartBonus_Ch2
	dw BGMChunk_HeartBonus_Ch3
	dw BGMChunk_HeartBonus_Ch4
BGMChunk_HeartBonus_Ch1:
.loop:
	dw BGMCmdTable_5A6E
	dw BGMCmdTable_7895
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_HeartBonus_Ch2:
.loop:
	dw BGMCmdTable_5AA0
	dw BGMCmdTable_78E2
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_HeartBonus_Ch3:
.loop:
	dw BGMCmdTable_5B81
	dw BGMCmdTable_7917
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_HeartBonus_Ch4:
.loop:
	dw BGMCmdTable_7960
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_7895: 
	sndsetloop $02
	sndlenid $a
	snddb $3c
	snddb $44
	snddb $3c
	snddb $36
	snddb $3c
	snddb $36
	snddb $32
	snddb $36
	snddb $32
	snddb $2c
	snddb $32
	snddb $2c
	snddb $24
	snddb $2c
	snddb $24
	snddb $1e
	snddb $24
	snddb $1e
	snddb $1a
	snddb $1e
	snddb $1a
	snddb $14
	snddb $1a
	snddb $14
	sndloop
	snddb $46
	snddb $4e
	snddb $46
	snddb $40
	snddb $46
	snddb $40
	snddb $3c
	snddb $40
	snddb $3c
	snddb $36
	snddb $3c
	snddb $36
	snddb $2e
	snddb $36
	snddb $2e
	snddb $28
	snddb $2e
	snddb $28
	snddb $24
	snddb $28
	snddb $24
	snddb $1e
	snddb $24
	snddb $1e
	snddb $46
	snddb $4c
	snddb $46
	snddb $40
	snddb $46
	snddb $40
	snddb $3c
	snddb $40
	snddb $3c
	snddb $34
	snddb $3c
	snddb $34
	snddb $2e
	snddb $34
	snddb $2e
	snddb $28
	snddb $2e
	snddb $28
	snddb $24
	snddb $28
	snddb $24
	snddb $1c
	snddb $24
	snddb $1c
	sndend
BGMCmdTable_78E2: 
	sndsetloop $02
	sndlenid $3
	snddb $c
	sndmutech
	snddb $14
	sndmutech
	snddb $1a
	sndmutech
	snddb $1e
	sndmutech
	snddb $24
	sndmutech
	snddb $1e
	sndmutech
	snddb $1a
	sndmutech
	snddb $14
	sndmutech
	sndloop
	snddb $16
	sndmutech
	snddb $1e
	sndmutech
	snddb $24
	sndmutech
	snddb $28
	sndmutech
	snddb $2a
	sndmutech
	snddb $28
	sndmutech
	snddb $24
	sndmutech
	snddb $1e
	sndmutech
	snddb $16
	sndmutech
	snddb $1c
	sndmutech
	snddb $24
	sndmutech
	snddb $28
	sndmutech
	snddb $2a
	sndmutech
	snddb $28
	sndmutech
	snddb $24
	sndmutech
	snddb $1c
	sndmutech
	sndend
BGMCmdTable_7917: 
	sndsetloop $02
	sndlenid $a
	sndmutech
	sndmutech
	sndlenid $4
	snddb $6c
	sndlenid $a
	sndmutech
	sndlenid $3
	snddb $66
	sndmutech
	snddb $62
	sndmutech
	snddb $5c
	sndmutech
	snddb $5c
	sndmutech
	sndlenid $a
	snddb $58
	sndmutech
	sndlenid $4
	snddb $54
	sndlenid $a
	sndmutech
	sndloop
	sndlenid $a
	sndmutech
	sndmutech
	sndlenid $4
	snddb $76
	sndlenid $a
	sndmutech
	sndlenid $3
	snddb $70
	sndmutech
	snddb $6c
	sndmutech
	snddb $66
	sndmutech
	snddb $66
	sndmutech
	sndlenid $a
	snddb $62
	sndmutech
	sndlenid $4
	snddb $5e
	sndlenid $a
	sndmutech
	sndlenid $a
	sndmutech
	sndmutech
	sndlenid $4
	snddb $76
	sndlenid $a
	sndmutech
	sndlenid $3
	snddb $70
	sndmutech
	snddb $6c
	sndmutech
	snddb $64
	sndmutech
	snddb $64
	sndmutech
	sndlenid $a
	snddb $62
	sndmutech
	sndlenid $4
	snddb $5e
	sndlenid $a
	sndmutech
	sndend
BGMCmdTable_7960: 
	sndsetloop $10
	sndlenid $4
	snddb $c
	sndlenid $a
	snddb $30
	sndmutech
	snddb $2c
	sndloop
	sndend
;--
BGMHeader_CoinGame:
	db $00
	dw BGMLenTable_59EF
	dw $0000
	dw BGMChunk_CoinGame_Ch2
	dw BGMChunk_CoinGame_Ch3
	dw BGMChunk_CoinGame_Ch4
BGMChunk_CoinGame_Ch2:
.loop:
	dw BGMCmdTable_5A87
	dw BGMCmdTable_7985
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_CoinGame_Ch3:
.loop:
	dw BGMCmdTable_5B5E
	dw BGMCmdTable_79B8
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_7985: 
	sndlenid $3
	snddb $3a
	snddb $32
	snddb $28
	snddb $22
	sndlenid $2
	snddb $24
	snddb $22
	snddb $24
	snddb $3c
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $3e
	snddb $36
	snddb $2c
	snddb $26
	sndlenid $2
	snddb $28
	snddb $26
	snddb $28
	snddb $40
	sndlenid $4
	sndmutech
	sndlenid $3
	snddb $42
	snddb $3a
	snddb $30
	snddb $2a
	sndlenid $2
	snddb $2c
	snddb $2a
	snddb $2c
	snddb $44
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $2e
	snddb $2c
	snddb $2e
	snddb $46
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $30
	snddb $2e
	snddb $30
	snddb $48
	sndlenid $4
	sndmutech
	sndend
BGMCmdTable_79B8: 
	sndlenid $2
	snddb $62
	sndmutech
	snddb $58
	sndmutech
	snddb $52
	sndmutech
	snddb $4a
	sndmutech
	snddb $4c
	snddb $4a
	snddb $4c
	snddb $5a
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $66
	sndmutech
	snddb $5c
	sndmutech
	snddb $56
	sndmutech
	snddb $4e
	sndmutech
	snddb $50
	snddb $4e
	snddb $50
	snddb $5e
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $6a
	sndmutech
	snddb $60
	sndmutech
	snddb $5a
	sndmutech
	snddb $52
	sndmutech
	snddb $54
	snddb $52
	snddb $54
	snddb $62
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $56
	snddb $54
	snddb $56
	snddb $64
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $58
	snddb $56
	snddb $58
	snddb $66
	snddb $58
	snddb $54
	snddb $52
	snddb $4e
	sndend
BGMHeader_LevelEnter:
	db $00
	dw BGMLenTable_59EF
	dw BGMChunk_LevelEnter_Ch1
	dw BGMChunk_LevelEnter_Ch2
	dw BGMChunk_LevelEnter_Ch3
	dw $0000
BGMChunk_LevelEnter_Ch1:
	dw BGMCmdTable_5B0E
	dw BGMCmdTable_5BB0
	dw BGMCmdTable_7A15
	dw BGMTBLCMD_END
BGMChunk_LevelEnter_Ch2:
	dw BGMCmdTable_5B13
	dw BGMCmdTable_7A15
	dw BGMTBLCMD_END
BGMChunk_LevelEnter_Ch3:
	dw BGMCmdTable_5B1D
	dw BGMCmdTable_7A15
	dw BGMTBLCMD_END

BGMCmdTable_7A15: 
	sndlenid $1
	snddb $48
	sndloenv
	snddb $4a
	sndloenv
	snddb $58
	sndloenv
	snddb $60
	sndloenv
	snddb $62
	sndloenv
	snddb $70
	sndloenv
	sndlenid $3
	snddb $7a
	sndloenv
	sndend
BGMHeader_TreasureGet:
	db $00
	dw BGMLenTable_59EF
	dw BGMChunk_TreasureGet_Ch1
	dw BGMChunk_TreasureGet_Ch2
	dw BGMChunk_TreasureGet_Ch3
	dw $0000
BGMChunk_TreasureGet_Ch1:
	dw BGMCmdTable_5B04
	dw BGMCmdTable_5BAD
	dw BGMCmdTable_7A4B
	dw BGMCmdTable_5BB0
	dw BGMTBLCMD_END
BGMChunk_TreasureGet_Ch2:
	dw BGMCmdTable_7A96
	dw BGMCmdTable_7A4B
	dw BGMCmdTable_7A66
	dw BGMTBLCMD_END
BGMChunk_TreasureGet_Ch3:
	dw BGMCmdTable_5B4A
	dw BGMCmdTable_7A66
	dw BGMCmdTable_7A4B
	dw BGMTBLCMD_END
BGMCmdTable_7A4B: 
	sndlenid $2
	snddb $2c
	snddb $3a
	snddb $40
	snddb $44
	snddb $48
	snddb $58
	snddb $52
	snddb $2e
	snddb $3c
	snddb $42
	snddb $46
	snddb $4a
	snddb $5a
	snddb $54
	snddb $30
	snddb $3e
	snddb $44
	snddb $48
	snddb $4c
	snddb $5c
	snddb $56
	snddb $64
	snddb $5c
	sndlenid $4
	snddb $78
	sndend
BGMCmdTable_7A66: 
	sndlenid $4
	sndmutech
	sndlenid $2
	sndmutech
	sndend
BGMHeader_Treasure:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_Treasure_Ch1
	dw BGMChunk_Treasure_Ch2
	dw BGMChunk_Treasure_Ch3
	dw $0000
BGMChunk_Treasure_Ch1:
	dw BGMCmdTable_5BAD
	dw BGMCmdTable_5ADC
	dw BGMCmdTable_5BAD
	dw BGMCmdTable_7A9B
	dw BGMCmdTable_5BB0
	dw BGMTBLCMD_END
BGMChunk_Treasure_Ch2:
	dw BGMCmdTable_5BAD
	dw BGMCmdTable_5AEB
	dw BGMCmdTable_7A9B
	dw BGMCmdTable_7A66
	dw BGMTBLCMD_END
BGMChunk_Treasure_Ch3:
	dw BGMCmdTable_5BAD
	dw BGMCmdTable_5B4F
	dw BGMCmdTable_7A66
	dw BGMCmdTable_7A9B
	dw BGMTBLCMD_END

BGMCmdTable_7A96: 
	sndregex $F1,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_7A9B: 
	sndlenid $2
	snddb $28
	snddb $3c
	snddb $34
	snddb $30
	snddb $2c
	snddb $38
	snddb $40
	snddb $3c
	snddb $34
	snddb $48
	sndlenid $3
	snddb $44
	snddb $50
	snddb $58
	sndend
BGMHeader_WorldClear:
	db $00
	dw BGMLenTable_59EF
	dw BGMChunk_WorldClear_Ch1
	dw BGMChunk_WorldClear_Ch2
	dw BGMChunk_WorldClear_Ch3
	dw $0000
BGMChunk_WorldClear_Ch1:
	dw BGMCmdTable_5ADC
	dw BGMCmdTable_5BAD
	dw BGMCmdTable_7AD0
	dw BGMCmdTable_5BB0
	dw BGMTBLCMD_END
BGMChunk_WorldClear_Ch2:
	dw BGMCmdTable_5B09
	dw BGMCmdTable_7AD0
	dw BGMCmdTable_7A66
	dw BGMTBLCMD_END
BGMChunk_WorldClear_Ch3:
	dw BGMCmdTable_5B4F
	dw BGMCmdTable_7A66
	dw BGMCmdTable_7AD0
	dw BGMTBLCMD_END

BGMCmdTable_7AD0: 
	sndlenid $2
	snddb $32
	snddb $3a
	snddb $40
	snddb $48
	snddb $4a
	snddb $52
	snddb $58
	snddb $60
	snddb $62
	snddb $6a
	snddb $70
	snddb $78
	sndlenid $3
	snddb $7a
	sndend
BGMHeader_Cutscene:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_Cutscene_Ch1
	dw BGMChunk_Cutscene_Ch2
	dw $0000
	dw $0000
BGMChunk_Cutscene_Ch1:
	dw BGMCmdTable_5AC3
	dw BGMCmdTable_5BAD
.loop:
	dw BGMCmdTable_7AFB
	dw BGMTBLCMD_REDIR, .loop
BGMChunk_Cutscene_Ch2:
	dw BGMCmdTable_5ADC
	dw BGMTBLCMD_REDIR, BGMChunk_Cutscene_Ch1.loop

BGMCmdTable_7AFB: 
	sndlenid $2
	snddb $7a
	snddb $70
	snddb $6a
	snddb $62
	snddb $64
	snddb $62
	snddb $64
	snddb $72
	sndend
BGMHeader_FinalBossOutro:
	db $00
	dw BGMLenTable_59FE
	dw $0000
	dw $0000
	dw $0000
	dw BGMChunk_FinalBossOutro_Ch4
; [TCRF] The chunk loops, but it never plays long enough to reach the end of the chunk
BGMChunk_FinalBossOutro_Ch4:
.loop:
	dw BGMCmdTable_7244
	dw BGMTBLCMD_REDIR, .loop;X
BGMHeader_EndingGenie:
	db $03
	dw BGMLenTable_5A1C
	dw BGMChunk_EndingGenie_Ch1
	dw BGMChunk_EndingGenie_Ch2
	dw BGMChunk_EndingGenie_Ch3
	dw $0000
;--
; Loops to the same chunk of the map cutscene music
BGMChunk_EndingGenie_Ch2:
BGMChunk_EndingGenie_Ch1:
	dw BGMCmdTable_5BAD
	dw BGMCmdTable_5ADC
	dw BGMTBLCMD_REDIR, BGMChunk_Cutscene_Ch1.loop
BGMChunk_EndingGenie_Ch3:
	dw BGMCmdTable_5BAD
	dw BGMCmdTable_5B4F
	dw BGMCmdTable_5BAD
	dw BGMTBLCMD_REDIR, BGMChunk_Cutscene_Ch1.loop
	
BGMHeader_Credits:
	db $00
	dw BGMLenTable_5A1C
	dw BGMChunk_Credits_Ch1
	dw BGMChunk_Credits_Ch2
	dw BGMChunk_Credits_Ch3
	dw BGMChunk_Credits_Ch4
BGMChunk_Credits_Ch1:
	dw BGMCmdTable_5AF0
	dw BGMCmdTable_5BB0
	dw BGMCmdTable_7C8F
	dw BGMCmdTable_5BAA
	dw BGMCmdTable_7BBC
	dw BGMCmdTable_7C19
	dw BGMCmdTable_7BBC
	dw BGMCmdTable_7C19
	dw BGMCmdTable_7BBC
	dw BGMCmdTable_7C19
	dw BGMCmdTable_7BBC
	dw BGMCmdTable_7C6C
	dw BGMTBLCMD_END
BGMChunk_Credits_Ch2:
	dw BGMCmdTable_7C8A
	dw BGMCmdTable_7C8F
	dw BGMCmdTable_7CCB
	dw BGMCmdTable_7CCF
	dw BGMCmdTable_5BB0
	dw BGMCmdTable_7D38
	dw BGMCmdTable_7D64
	dw BGMCmdTable_7D38
	dw BGMCmdTable_7D78
	dw BGMCmdTable_7CCF
	dw BGMCmdTable_5BB0
	dw BGMCmdTable_7D38
	dw BGMCmdTable_7D64
	dw BGMCmdTable_7D38
	dw BGMCmdTable_7D78
	dw BGMCmdTable_7CCF
	dw BGMCmdTable_5BB0
	dw BGMCmdTable_7D38
	dw BGMCmdTable_7D64
	dw BGMCmdTable_7D38
	dw BGMCmdTable_7D78
	dw BGMCmdTable_7CCF
	dw BGMCmdTable_7D93
	dw BGMTBLCMD_END
BGMChunk_Credits_Ch3:
	dw BGMCmdTable_5B36
	dw BGMCmdTable_7DAC
	dw BGMCmdTable_7DCA
	dw BGMCmdTable_7E54
	dw BGMCmdTable_7E6C
	dw BGMCmdTable_7EB5
	dw BGMCmdTable_7E6C
	dw BGMCmdTable_7EDF
	dw BGMCmdTable_7DCA
	dw BGMCmdTable_7E54
	dw BGMCmdTable_7E6C
	dw BGMCmdTable_7EB5
	dw BGMCmdTable_7E6C
	dw BGMCmdTable_7EDF
	dw BGMCmdTable_7DCA
	dw BGMCmdTable_7E54
	dw BGMCmdTable_7E6C
	dw BGMCmdTable_7EB5
	dw BGMCmdTable_7E6C
	dw BGMCmdTable_7EDF
	dw BGMCmdTable_7DCA
	dw BGMCmdTable_7F14
	dw BGMTBLCMD_END
BGMChunk_CoinVault_Ch4:
BGMChunk_Credits_Ch4:
	dw BGMCmdTable_7F47
	dw BGMCmdTable_7F54
	dw BGMTBLCMD_END

BGMCmdTable_7BBC: 
	sndregex $86,$00,$80,BGMPP_NONE
	sndlenid $5
	snddb $3a
	snddb $3a
	snddb $30
	sndlenid $4
	snddb $48
	snddb $46
	sndlenid $5
	snddb $44
	snddb $48
	snddb $4a
	snddb $4c
	sndregex $92,$00,$80,BGMPP_NONE
	sndlenid $3
	snddb $4e
	snddb $54
	snddb $5c
	snddb $66
	sndlenid $4
	snddb $6c
	sndmutech
	sndlenid $3
	sndmutech
	snddb $54
	snddb $5a
	snddb $62
	sndlenid $4
	snddb $6c
	sndmutech
	sndlenid $3
	snddb $48
	sndlenid $4
	snddb $48
	sndlenid $3
	snddb $48
	snddb $46
	sndlenid $4
	snddb $46
	sndlenid $3
	snddb $46
	snddb $44
	sndlenid $4
	snddb $44
	sndlenid $3
	snddb $46
	sndlenid $4
	snddb $48
	sndmutech
	sndregex $86,$00,$80,BGMPP_NONE
	sndlenid $5
	snddb $3a
	snddb $3a
	snddb $30
	sndlenid $4
	snddb $48
	snddb $46
	sndlenid $5
	snddb $44
	snddb $48
	snddb $4a
	snddb $4c
	sndregex $92,$00,$80,BGMPP_NONE
	sndlenid $3
	sndmutech
	snddb $54
	snddb $5a
	snddb $62
	sndlenid $4
	snddb $6c
	sndmutech
	sndlenid $3
	sndmutech
	snddb $52
	snddb $58
	snddb $60
	sndmutech
	snddb $5c
	snddb $6a
	snddb $74
	sndend
BGMCmdTable_7C19: 
	sndregex $86,$00,$80,BGMPP_NONE
	snddb $3c
	snddb $44
	snddb $4e
	snddb $54
	snddb $58
	snddb $56
	snddb $54
	sndlenid $6
	snddb $52
	sndlenid $3
	sndmutech
	sndsetloop $04
	sndlenid $6
	sndmutech
	sndloop
	sndlenid $5
	snddb $3c
	sndlenid $3
	sndmutech
	snddb $32
	snddb $3c
	snddb $40
	sndlenid $5
	snddb $42
	sndlenid $3
	sndmutech
	snddb $3c
	snddb $46
	snddb $42
	sndlenid $8
	snddb $40
	sndlenid $3
	snddb $40
	sndlenid $8
	snddb $3c
	sndlenid $3
	snddb $3c
	sndlenid $8
	snddb $38
	sndlenid $3
	snddb $38
	sndlenid $4
	snddb $34
	sndmutech
	sndsetloop $04
	sndlenid $6
	sndmutech
	sndloop
	sndlenid $5
	snddb $3c
	sndlenid $3
	sndmutech
	snddb $32
	snddb $3c
	snddb $38
	sndlenid $4
	snddb $34
	snddb $42
	snddb $40
	sndlenid $3
	snddb $50
	snddb $4c
	sndregex $80,$00,$80,BGMPP_NONE
	sndlenid $5
	snddb $4a
	snddb $4c
	sndlenid $9
	snddb $4a
	sndlenid $2
	snddb $48
	snddb $44
	snddb $40
	snddb $3c
	sndend
BGMCmdTable_7C6C: 
	sndregex $80,$00,$80,BGMPP_NONE
	snddb $3c
	snddb $44
	snddb $4e
	snddb $54
	snddb $58
	snddb $56
	snddb $54
	snddb $4e
	sndlenid $6
	snddb $50
	sndlenid $5
	snddb $54
	sndlenid $2
	sndmutech
	snddb $54
	sndmutech
	snddb $54
	snddb $52
	sndmutech
	snddb $54
	sndmutech
	sndlenid $6
	snddb $58
	sndlenid $9
	sndmutech
	sndend
BGMCmdTable_7C8A: 
	sndregex $A3,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_7C8F: 
	sndlenid $2
	sndmutech
	snddb $2c
	snddb $32
	snddb $3c
	snddb $44
	snddb $3c
	snddb $32
	snddb $2c
	sndmutech
	snddb $44
	snddb $4a
	snddb $54
	snddb $5c
	snddb $54
	snddb $4a
	snddb $44
	sndmutech
	snddb $30
	snddb $36
	snddb $40
	snddb $48
	snddb $40
	snddb $36
	snddb $30
	sndmutech
	snddb $48
	snddb $4e
	snddb $58
	snddb $60
	snddb $58
	snddb $4e
	snddb $48
	sndmutech
	snddb $32
	snddb $3c
	snddb $44
	snddb $4a
	snddb $44
	snddb $3c
	snddb $32
	sndmutech
	snddb $4a
	snddb $54
	snddb $5c
	snddb $62
	snddb $5c
	snddb $54
	snddb $4a
	sndmutech
	snddb $36
	snddb $40
	snddb $48
	snddb $4e
	snddb $58
	snddb $60
	snddb $66
	sndlenid $3
	snddb $70
	sndend
BGMCmdTable_7CCB: 
	snddb $40
	snddb $44
	snddb $48
	sndend
BGMCmdTable_7CCF: 
	sndregex $90,$00,$80,BGMPP_NONE
	sndlenid $5
	snddb $4a
	snddb $40
	sndlenid $3
	sndmutech
	snddb $44
	snddb $48
	snddb $4a
	snddb $4e
	snddb $52
	snddb $58
	snddb $56
	sndlenid $d
	snddb $54
	sndlenid $3
	sndmutech
	sndlenid $2
	snddb $4e
	sndmutech
	snddb $4e
	sndmutech
	snddb $52
	sndmutech
	sndlenid $5
	snddb $54
	sndlenid $2
	sndmutech
	sndmutech
	snddb $4e
	sndmutech
	snddb $4e
	sndmutech
	snddb $52
	sndmutech
	sndlenid $8
	snddb $54
	sndlenid $3
	sndmutech
	snddb $54
	snddb $52
	snddb $4e
	snddb $4a
	sndlenid $d
	snddb $40
	sndlenid $3
	sndmutech
	snddb $40
	snddb $44
	snddb $48
	sndlenid $5
	snddb $4a
	snddb $40
	sndlenid $3
	sndmutech
	snddb $44
	snddb $48
	snddb $4a
	snddb $4e
	snddb $52
	snddb $58
	snddb $56
	sndlenid $d
	snddb $54
	sndlenid $3
	sndmutech
	sndlenid $2
	snddb $4e
	sndmutech
	snddb $4e
	sndmutech
	snddb $52
	sndmutech
	sndlenid $8
	snddb $54
	sndlenid $3
	sndmutech
	snddb $54
	snddb $52
	snddb $4e
	snddb $4a
	snddb $48
	snddb $46
	snddb $48
	snddb $4a
	sndmutech
	sndlenid $2
	snddb $4a
	sndmutech
	sndlenid $3
	snddb $4a
	snddb $48
	snddb $44
	snddb $4e
	snddb $54
	snddb $5c
	snddb $60
	snddb $5c
	snddb $60
	sndlenid $6
	snddb $62
	sndend
BGMCmdTable_7D38: 
	sndregex $B2,$00,$40,BGMPP_NONE
	sndlenid $3
	snddb $4a
	snddb $4c
	snddb $50
	sndlenid $2
	snddb $54
	snddb $50
	sndlenid $3
	sndmutech
	snddb $50
	snddb $54
	snddb $58
	sndlenid $4
	snddb $5a
	snddb $4a
	sndlenid $3
	sndmutech
	snddb $4a
	snddb $46
	snddb $42
	sndlenid $4
	snddb $50
	snddb $4c
	sndlenid $3
	sndmutech
	snddb $4a
	snddb $4c
	snddb $4a
	sndlenid $5
	snddb $46
	sndregex $90,$00,$80,BGMPP_NONE
	sndlenid $3
	sndmutech
	snddb $4c
	snddb $4a
	snddb $46
	sndend
BGMCmdTable_7D64: 
	snddb $42
	snddb $4a
	snddb $54
	snddb $58
	sndlenid $5
	snddb $5a
	sndlenid $3
	snddb $46
	snddb $4a
	snddb $54
	snddb $5a
	snddb $5e
	snddb $5a
	snddb $58
	snddb $54
	sndlenid $d
	snddb $50
	sndlenid $5
	sndmutech
	sndend
BGMCmdTable_7D78: 
	sndlenid $3
	snddb $42
	snddb $4a
	snddb $54
	snddb $58
	sndlenid $5
	snddb $5a
	sndlenid $3
	snddb $42
	snddb $4c
	snddb $54
	snddb $5a
	snddb $5e
	snddb $5a
	snddb $58
	sndlenid $6
	snddb $5a
	sndlenid $9
	snddb $5a
	sndlenid $3
	sndmutech
	sndlenid $2
	snddb $58
	snddb $54
	snddb $52
	snddb $4e
	sndend
BGMCmdTable_7D93: 
	sndlenid $3
	sndmutech
	sndlenid $5
	snddb $66
	sndlenid $2
	sndmutech
	snddb $66
	sndmutech
	snddb $66
	snddb $62
	sndmutech
	snddb $66
	sndmutech
	sndlenid $6
	snddb $6a
	sndlenid $4
	sndmutech
	sndlenid $2
	snddb $26
	snddb $28
	snddb $20
	snddb $22
	sndlenid $4
	snddb $1a
	sndend
BGMCmdTable_7DAC: 
	sndsetloop $02
	sndlenid $3
	snddb $28
	sndhienv
	sndmutech
	sndlenid $2
	snddb $28
	sndhienv
	sndlenid $3
	snddb $28
	sndlenid $8
	sndmutech
	sndloop
	sndsetloop $06
	sndlenid $3
	snddb $28
	sndhienv
	sndloop
	sndlenid $2
	snddb $40
	sndmutech
	snddb $3c
	sndmutech
	snddb $3a
	sndmutech
	snddb $36
	sndmutech
	sndend
BGMCmdTable_7DCA: 
	sndsetloop $02
	sndlenid $2
	snddb $32
	sndmutech
	snddb $40
	sndmutech
	snddb $28
	sndmutech
	snddb $40
	sndmutech
	sndloop
	sndsetloop $02
	snddb $3a
	sndmutech
	snddb $48
	sndmutech
	snddb $30
	sndmutech
	snddb $48
	sndmutech
	sndloop
	sndsetloop $06
	snddb $36
	sndmutech
	snddb $44
	sndmutech
	snddb $2c
	sndmutech
	snddb $44
	sndmutech
	sndloop
	sndsetloop $02
	snddb $3c
	sndmutech
	snddb $4a
	sndmutech
	snddb $32
	sndmutech
	snddb $4a
	sndmutech
	sndloop
	sndsetloop $02
	snddb $3a
	sndmutech
	snddb $48
	sndmutech
	sndloop
	sndsetloop $02
	snddb $38
	sndmutech
	snddb $46
	sndmutech
	sndloop
	sndsetloop $02
	snddb $36
	sndmutech
	snddb $44
	sndmutech
	sndloop
	sndlenid $4
	snddb $40
	sndmutech
	sndsetloop $02
	sndlenid $2
	snddb $32
	sndmutech
	snddb $40
	sndmutech
	snddb $28
	sndmutech
	snddb $40
	sndmutech
	sndloop
	sndsetloop $02
	snddb $3a
	sndmutech
	snddb $48
	sndmutech
	snddb $30
	sndmutech
	snddb $48
	sndmutech
	sndloop
	sndsetloop $04
	snddb $36
	sndmutech
	snddb $44
	sndmutech
	snddb $2c
	sndmutech
	snddb $44
	sndmutech
	sndloop
	sndsetloop $02
	sndlenid $2
	snddb $3c
	sndmutech
	snddb $4a
	sndmutech
	snddb $32
	sndmutech
	snddb $4a
	sndmutech
	sndloop
	sndsetloop $02
	snddb $3a
	sndmutech
	snddb $48
	sndmutech
	sndloop
	snddb $44
	sndmutech
	snddb $52
	sndmutech
	snddb $44
	sndmutech
	snddb $2c
	sndmutech
	sndsetloop $02
	snddb $36
	sndmutech
	snddb $44
	sndmutech
	sndloop
	sndend
BGMCmdTable_7E54: 
	snddb $40
	sndmutech
	snddb $28
	sndmutech
	snddb $2c
	sndmutech
	snddb $30
	sndmutech
	sndsetloop $02
	snddb $32
	sndmutech
	snddb $40
	sndmutech
	sndloop
	snddb $32
	sndmutech
	snddb $4a
	sndhienv
	snddb $4a
	sndhienv
	snddb $46
	sndhienv
	sndend
BGMCmdTable_7E6C: 
	sndlenid $2
	snddb $42
	sndloenv
	snddb $4a
	sndloenv
	snddb $50
	sndloenv
	snddb $4a
	sndloenv
	snddb $40
	sndloenv
	snddb $46
	sndloenv
	snddb $50
	sndloenv
	snddb $46
	sndloenv
	snddb $3c
	sndloenv
	snddb $42
	sndloenv
	snddb $4a
	sndloenv
	snddb $42
	sndloenv
	snddb $38
	sndloenv
	snddb $42
	sndloenv
	snddb $4a
	sndloenv
	snddb $42
	sndloenv
	snddb $34
	sndloenv
	snddb $3c
	sndloenv
	snddb $42
	sndloenv
	snddb $3c
	sndloenv
	snddb $32
	sndloenv
	snddb $38
	sndloenv
	snddb $42
	sndloenv
	snddb $38
	sndloenv
	snddb $2e
	sndloenv
	snddb $34
	sndloenv
	snddb $3c
	sndloenv
	snddb $34
	sndloenv
	snddb $32
	sndmutech
	snddb $32
	sndmutech
	snddb $36
	sndmutech
	snddb $3a
	sndmutech
	sndsetloop $02
	snddb $3c
	sndmutech
	snddb $4a
	sndmutech
	sndloop
	sndend
BGMCmdTable_7EB5: 
	sndsetloop $02
	snddb $3a
	sndmutech
	snddb $4a
	sndmutech
	sndloop
	sndsetloop $02
	snddb $38
	sndmutech
	snddb $4a
	sndmutech
	sndloop
	snddb $2e
	sndmutech
	snddb $2e
	sndmutech
	snddb $32
	sndmutech
	snddb $36
	sndmutech
	sndlenid $4
	snddb $38
	sndlenid $3
	sndmutech
	snddb $50
	sndlenid $4
	snddb $4c
	sndlenid $3
	sndmutech
	snddb $4c
	sndlenid $4
	snddb $4a
	sndlenid $3
	sndmutech
	snddb $4a
	snddb $46
	snddb $38
	snddb $3c
	snddb $40
	sndend
BGMCmdTable_7EDF: 
	sndsetloop $02
	snddb $38
	sndmutech
	snddb $4a
	sndmutech
	sndloop
	snddb $34
	sndmutech
	snddb $42
	sndmutech
	snddb $2a
	sndmutech
	snddb $42
	sndmutech
	snddb $38
	sndmutech
	snddb $38
	sndmutech
	snddb $3c
	sndmutech
	snddb $40
	sndmutech
	snddb $42
	sndmutech
	snddb $50
	sndmutech
	snddb $4a
	sndmutech
	snddb $50
	sndmutech
	snddb $42
	sndmutech
	snddb $54
	sndmutech
	snddb $4c
	sndmutech
	snddb $54
	sndmutech
	snddb $42
	sndmutech
	snddb $50
	sndmutech
	snddb $4a
	sndmutech
	snddb $50
	sndmutech
	sndlenid $3
	snddb $42
	sndmutech
	snddb $40
	sndmutech
	sndend
BGMCmdTable_7F14: 
	sndsetloop $02
	snddb $40
	sndmutech
	snddb $4e
	sndmutech
	sndloop
	sndsetloop $02
	snddb $42
	sndmutech
	snddb $50
	sndmutech
	snddb $38
	sndmutech
	snddb $50
	sndmutech
	sndloop
	sndsetloop $02
	snddb $46
	sndmutech
	snddb $54
	sndmutech
	snddb $3c
	sndmutech
	snddb $54
	sndmutech
	sndloop
	sndsetloop $02
	snddb $4a
	sndmutech
	snddb $58
	sndmutech
	snddb $40
	sndmutech
	snddb $58
	sndmutech
	sndloop
	sndlenid $3
	snddb $4a
	sndmutech
	sndlenid $2
	snddb $26
	snddb $28
	snddb $20
	snddb $22
	sndlenid $4
	snddb $1a
	sndend
BGMCmdTable_7F47: 
	sndsetloop $EC
	sndlenid $2
	snddb $2c
	snddb $2c
	snddb $2c
	snddb $2c
	snddb $30
	snddb $2c
	snddb $2c
	snddb $2c
	sndloop
	sndend
BGMCmdTable_7F54: 
	sndlenid $4
	snddb $30
	sndlenid $5
	sndmutech
	sndend
BGMHeader_GameOver2:
	db $00
	dw BGMLenTable_59FE
	dw BGMChunk_GameOver2_Ch1
	dw BGMChunk_GameOver2_Ch2
	dw BGMChunk_GameOver2_Ch3
	dw $0000
BGMChunk_GameOver2_Ch1:
	dw BGMCmdTable_7F70
	dw BGMTBLCMD_END
BGMChunk_GameOver2_Ch2:
	dw BGMCmdTable_7F83
	dw BGMTBLCMD_END
BGMChunk_GameOver2_Ch3:
	dw BGMCmdTable_7F97
	dw BGMTBLCMD_END

BGMCmdTable_7F70: 
	sndregex $A1,$00,$80,BGMPP_NONE
	sndlenid $a
	snddb $62
	snddb $60
	snddb $5e
	snddb $5c
	sndloenv
	snddb $58
	snddb $56
	sndloenv
	snddb $48
	snddb $4a
	sndloenv
	sndloenv
	sndloenv
	sndend
BGMCmdTable_7F83: 
	sndregex $A1,$00,$80,BGMPP_09
	sndlenid $a
	snddb $38
	snddb $3a
	snddb $3c
	snddb $30
	snddb $32
	snddb $34
	snddb $36
	sndloenv
	snddb $40
	snddb $32
	sndloenv
	sndloenv
	sndlenid $6
	snddb $4a
	sndend
BGMCmdTable_7F97: 
	sndregex3 BGMWaveTable_5C56,$43
	sndlenid $a
	snddb $4a
	snddb $48
	snddb $46
	snddb $44
	sndloenv
	snddb $40
	snddb $3e
	sndloenv
	snddb $30
	snddb $32
	sndloenv
	sndloenv
	snddb $60
	sndloenv
	sndend
BGMHeader_EndingStatue:
	db $02
	dw BGMLenTable_5A2B
	dw $0000
	dw BGMChunk_EndingStatue_Ch2
	dw BGMChunk_EndingStatue_Ch3
	dw $0000
BGMChunk_EndingStatue_Ch2:
	dw BGMCmdTable_7FC6
	dw BGMTBLCMD_REDIR, BGMChunk_EndingStatue_Ch3.loop
BGMChunk_EndingStatue_Ch3:
	dw BGMCmdTable_5B4A
	dw BGMCmdTable_5BAD
.loop:
	dw BGMCmdTable_7FCB
	dw BGMTBLCMD_REDIR, .loop

BGMCmdTable_7FC6: 
	sndregex $A7,$00,$80,BGMPP_NONE
	sndend
BGMCmdTable_7FCB: 
	sndsetloop $02
	sndlenid $4
	snddb $88
	snddb $7a
	snddb $82
	snddb $7e
	snddb $7a
	snddb $6a
	snddb $70
	snddb $62
	sndloop
	sndsetloop $02
	snddb $8a
	snddb $7c
	snddb $84
	snddb $80
	snddb $7c
	snddb $6c
	snddb $72
	snddb $64
	sndloop
	sndend
; =============== END OF BANK ===============
	mIncJunk "L047FE3"
