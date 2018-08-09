    include exec/types.i
    include exec/libraries.i
    INCLUDE "exec/exec_lib.i"
    INCLUDE "graphics/graphics_lib.i"
    	
    	
    SECTION MAINCODE,CODE
	
	;include "DaWorkBench.s"

_FONT_HBYTES EQU 2

; PADDERS+VPIXELS MUST BE EQUAL 32
_FONT_HPADDER EQU 6
_FONT_VPIXELS EQU 20
_FONT_LPADDER EQU 6

_SCREEN_HBYTES EQU 40
_SCREEN_VRES EQU 256
_SCROLLPLAYFIELDSPEED equ 3 ; Playfield vertical scrolling speed, value must be higher of zero
_FADEDELAY equ 7 ; Fade speed, decrease to get a faster speed

DISABLE	MACRO
	LINKLIB _LVODisable,_AbsExecBase
	ENDM
	
ENABLE	MACRO
	LINKLIB _LVOEnable,_AbsExecBase
	ENDM
	
OPENGRAPHICS MACRO
	lea GfxName,a1
	LINKLIB _LVOOldOpenLibrary,_AbsExecBase
	move.l d0,GfxBase
	ENDM
	
CLOSEGRAPHICS MACRO
	move.l GfxBase,a1
	LINKLIB _LVOCloseLibrary,_AbsExecBase
	ENDM

WAITVEND MACRO
	cmpi.b #$ff,$dff006
	bne \1
	ENDM
	
WAITVOUT MACRO
	cmpi.b #$ff,$dff006
	beq \1
	ENDM
	
	
LOADBITPLANE MACRO
	MOVE.L	\1,d0
	LEA	\2,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	ENDM

OWNBLITTER MACRO
	LINKLIB _LVOOwnBlitter,GfxBase
	ENDM
	
DISOWNBLITTER MACRO
	LINKLIB _LVODisownBlitter,GfxBase
	ENDM
	
BLTCPY MACRO
        btst #6,$dff002
\3
        btst #6,$dff002
        bne.s \3
        move.w #$FFFF,$dff044 ; BLTAFWM - Blitter first word mask for source A
        move.w #$FFFF,$dff046 ; BLTALWM - Blitter last word mask for source A
        move.w #$09f0,$dff040 ; BLTCON0 - Use A D DMA Channels
        move.w #$0000,$dff042 ; BLTCON1
        move.w #$0000,$dff064 ; BLTAMOD
        move.w #$0000,$dff066 ; BLTDMOD
        move.l \1,$dff050     ; BLTAPT - Data Source
        move.l \2,$dff054     ; BLTDPT - Destination
        move.w \4,$dff058 ; BLTSIZE
        ENDM
        
BLTCPY2 MACRO
        btst #6,$dff002
\3
        btst #6,$dff002
        bne.s \3
        move.w #$FFFF,$dff044 ; BLTAFWM - Blitter first word mask for source A
        move.w #$FFFF,$dff046 ; BLTALWM - Blitter last word mask for source A
        move.w #$09f0,$dff040 ; BLTCON0 - Use A D DMA Channels
        move.w #$0000,$dff042 ; BLTCON1
        ;move.w #120-2,$dff064 ; BLTAMOD
        move.w #0,$dff064
        move.w #40-2,$dff066 ; BLTDMOD
        move.l \1,$dff050     ; BLTAPT - Data Source
        move.l \2,$dff054     ; BLTDPT - Destination
        move.w \4,$dff058 ; BLTSIZE
        ENDM
        
BLTCPY3 MACRO
	bsr.w waitblitter
        move.w #$FFFF,$dff044 ; BLTAFWM - Blitter first word mask for source A
        move.w #$FFFF,$dff046 ; BLTALWM - Blitter last word mask for source A
        move.w #$09f0,$dff040 ; BLTCON0 - Use A D DMA Channels
        move.w #$0000,$dff042 ; BLTCON1
        move.w #$0000,$dff064 ; BLTAMOD
        move.w #$0000,$dff066 ; BLTDMOD
        move.l \1,$dff050     ; BLTAPT - Data Source
        move.l \2,$dff054     ; BLTDPT - Destination
        move.w \3,$dff058 ; BLTSIZE
        ENDM

BLTCLEAR MACRO
	bsr.w waitblitter
        move.w #$FFFF,$dff044 ; BLTAFWM - Blitter first word mask for source A
        move.w #$FFFF,$dff046 ; BLTALWM - Blitter last word mask for source A
        move.w #$0100,$dff040 ; BLTCON0 - Use A D DMA Channels
        move.w #$0000,$dff042 ; BLTCON1
        move.w #$0000,$dff064 ; BLTAMOD
        move.w #$0000,$dff066 ; BLTDMOD
        move.l \1,$dff050     ; BLTAPT - Data Source
        move.l \2,$dff054     ; BLTDPT - Destination
        move.w \3,$dff058 ; BLTSIZE
        ENDM

        
PRINT_EYES_TOP_RIGHT MACRO
	move.l #$cf9e377f,LEFTSKULLEYES1
	move.l #$afde57ff,LEFTSKULLEYES2
	move.l #$7cf1fbee,RIGHTSKULLEYES1
	move.l #$7ef1ffee,RIGHTSKULLEYES2
	ENDM
	
PRINT_EYES_TOP_LEFT MACRO
	move.l #$cf3e37df,LEFTSKULLEYES1
	move.l #$af7e57ff,LEFTSKULLEYES2
	move.l #$79f1feee,RIGHTSKULLEYES1
	move.l #$7bf1ffee,RIGHTSKULLEYES2
	ENDM
	
PRINT_EYES_BOTTOM_LEFT MACRO
	move.l #$cf7e37ff,LEFTSKULLEYES1
	move.l #$af3e57df,LEFTSKULLEYES2
	move.l #$7bf1ffee,RIGHTSKULLEYES1
	move.l #$79f1feee,RIGHTSKULLEYES2
	ENDM
	
PRINT_EYES_BOTTOM_RIGHT MACRO
	move.l #$cfde37ff,LEFTSKULLEYES1
	move.l #$af9e577f,LEFTSKULLEYES2
	move.l #$7ef1ffee,RIGHTSKULLEYES1
	move.l #$7cf1ffee,RIGHTSKULLEYES2
	ENDM
	
LOAD_OLD_SPRITE_POS MACRO
	MOVE.L	\1,A0
	subq #2,a0
	moveq	#0,d0
	move.w  (a0),\2
	ENDM

REDUCE_COPPERLIST MACRO
	lea CHKBOARD_COPPERLIST,a0
	move.l #$fffffffe,(a0)
	ENDM
	
BALLOBJ MACRO
	dc.w 220,128    ; x,y
        dc.l ballpic
        dc.l ballpicmsk
        dc.l BALLBITPLANE_1
        dc.w 0
        dc.w 32*64+6/2  ; bltsize
	ENDM
	
_AbsExecBase EQU 4
 
START
	DISABLE	; Disable interrupts 
	OPENGRAPHICS	; Got on GfxBase variable the base of graphics lib
	OWNBLITTER	; Get exclusive use of the blitter
	move d0,a6
	move.l $26(a6),OldCop ; Save oldcopperlist addr

	; Bitplane pointing - load fromt crowman raw image

	MOVE.L	#PIC,d0	; store address playfield 1 (bitplanes 1-3-5)
	LEA	BPLPOINTERS1,A1
	MOVEQ	#3-1,D1
POINTBP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0
	addq.w	#8,a1
	dbra	d1,POINTBP

	; Point second playfield
	LOADBITPLANE #PIC2_1,BPLPOINTERS2
	LOADBITPLANE #PIC2_2,BPLPOINTERS2_1
	LOADBITPLANE #PIC2_3,BPLPOINTERS2_2
	
	; Init Checkboard (set horizontal waits and fill bitplane 6 with 1)
	bsr.w InitCheckboard

	; Start Sprite init (the skull)
	; Sprite 0 init
	MOVE.L	#LEFTSKULL,d0		
	LEA	SpritePointers,a1	; SpritePointers is in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	; Sprite 1 init (right side of sprite 0)	
	MOVE.L	#RIGHTSKULL,d0		
	addq.w	#8,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	
	; Sprite 2 init (starfield)
	MOVE.L	#STARFIELDSPRITE,d0		
	addq.w	#8,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	
	; let's start our custom copperlist
	move.l #COPPERLIST,$dff080
	move.l d0,$dff088
	move.l #0,$dff1fc
	move.l $0c00,$dff106 ; BPLCON3
	
	; enable dma sprite
	move.w #$87a0,$dff096

	bsr.w   mt_init ; init music
	
	; Init ball coordinates and image+mask
	bsr.w BobsCoords
	bsr.w BobsNewPos
	lea ballpic,a0
	move.l a0,ball
	lea ballpicmsk,a0
	move.l a0,ballmask
mouse	
.loop; Wait for vblank
	move.l $dff004,d0
	and.l #$1ff00,d0
	cmp.l #303<<8,d0
	bne.b .loop
	
	bsr.w FadeInBitplane1 ; Fade in the crowman
	bsr.w FadeInBitplane2 ; Fade in the banner
	
	bsr.w MoveSprite ; Move the skull sprite on the X axis
	bsr.w MoveSpriteY ; Move the skull sprite on the Y Axis	
	bsr.w MoveSpriteEyes ; Move the skull sprite eyes according to
			     ; the screen position
			     
	; Checkboard starts at 25
	cmpi.w #25,BannerCont
	bls.w .continue1 ; if Bannercont<=25
	cmpi.w #26,BannerCont 
	bne.s .noinitcheckboard ; if Bannercont!=26 dont init checkboard
	bclr.b #6,BPLCON2	; Force crowman on top during checkboard
	bsr.w InitBITCHKBOARD
.noinitcheckboard
	bsr.w MovChecker
	addq.l #1,timerMovGrad
	bra.w .nomovbanner

	
	;move.w	#$511,COLORS+2; Uncomment to enable background flash
.continue1
	; if Bannercont>=5  switch planes (crowman to 2nd playfield and
	; empty bitplanes on first playfield to print bobs balls
	cmpi.w #15,BannerCont
	bls.w .continue	; if Bannercont<=5
	cmpi.w #16,BannerCont ; if Bannercont==6 (first time only) switch playfield
	bne.s .moveballs
	
	; switch the playfield, the crowman on the back, the balls take the main scene
	LOADBITPLANE #BALLBITPLANE_1,BPLPOINTERS2
        LOADBITPLANE #BALLBITPLANE_2,BPLPOINTERS2_1
        LOADBITPLANE #BALLBITPLANE_3,BPLPOINTERS2_2
	lea COLORSBITPLANE2,a1
	move.w #$fff,2(a1)
        move.w #$f00,6(a1)
        move.w #$800,10(a1)
	bchg.b #6,BPLCON2

	addq #1,BannerCont
.moveballs
	bsr.w BobsClear
	bsr.w BobsMove
	bsr.w BobsNewPos
	bsr.w BlitBobs
	bra.s .nomovbanner
	
.continue
	bsr.w MoveBanner ; Move the background banner up and down
.nomovbanner	
	bsr.w PrintChar   ; Print a new character every 16 shifts
	bsr.w MoveText    ; Move the text from left to right
	bsr.w MoveStars   ; Move the background stars
	bsr.w mt_music
	
.loopend ; Wait to exit vblank row (for faster processors like 68040)
	move.l $dff004,d0
	and.l #$1ff00,d0
	cmp.l #303<<8,d0
	beq.b .loopend

	; wait for left mouse click
lclick	btst #6,$bfe001
	bne mouse

	;bra.s enddemo
;debouncer
mousedown
	btst #6,$bfe001
	beq mousedown
	
spritedisable1	
	move.l $dff004,d0
	and.l #$1ff00,d0
	cmp.l #303<<8,d0
	bne.b spritedisable1
	move.w #$20,$dff096

	; Setup credit scene
	bsr.w SetupCreditScene
	
mouse2
	WAITVEND mouse2
	bsr.w mt_music
	bsr.w ScrollPlayfield

vwait2	WAITVOUT vwait2
lclickexit
	btst #6,$bfe001
	bne mouse2

	; Exit of the demo
enddemo
	move.w #$8020,$dff096
	bsr.w mt_end
	move.l OldCop,$dff080
	move.w d0,$dff088
	DISOWNBLITTER
	CLOSEGRAPHICS
	ENABLE
	clr.l d0
	rts

; Calculate distance between bobs
ptBOBTabXY	dc.w	0
BOBTabX		dc.w 0,10,20,30,40,50,60,70,80
BOBTabY		dc.w 0,10,20,30,40,50,60,70,80

BobsCoords
	lea	BOBTabX(pc),a0
	lea	BOBTabY(pc),a1
	;adda.w	ptBOBTabXY(pc),a0
	;adda.w	ptBOBTabXY(pc),a1
	lea	X1,a2
	lea	Y1,a3
	move.w	nbBobs(pc),d5
.loopbob1
	move.w	(a0)+,(a2)+
	move.w	(a1)+,(a3)+
	dbf	d5,.loopbob1
	rts

waitblitter	
	btst	#6,$dff002
.wait	btst	#6,$dff002
	bne.s	.wait
	rts

;  Update x and y position on the bobs data structure
X1		ds.w	1 ; add bobs
X2		ds.w	1
X3		ds.w	1
X4		ds.w	1
X5		ds.w	1
X6		ds.w	1
X7		ds.w	1
X8		ds.w	1
X9		ds.w	1
Y1		ds.w	1
Y2		ds.w	1
Y3		ds.w	1
Y4		ds.w	1
Y5		ds.w	1
Y6		ds.w	1
Y7		ds.w	1
Y8		ds.w	1
Y9		ds.w	1

MoveX	dcb.w 3,260
	dc.w 259, 258, 257, 256, 254, 252, 250,	248, 245, 243
	dc.w 240, 236, 233, 230, 226, 222, 218,	214, 210, 205
	dc.w 201, 196, 192, 187, 182, 177, 172,	167, 162, 157
	dc.w 152, 147, 142, 137, 132, 128, 123,	118, 114, 110
	dc.w 105, 101, 97, 93, 90, 86, 83, 80, 77, 74, 72, 70
	dc.w 68, 66, 64, 63, 62, 61
	dcb.w 4,60
	dcb.w 2,61
	dc.w 62, 63, 65, 66, 68, 70, 73, 75, 78, 81, 84, 87, 91
	dc.w 95, 98, 103, 107, 111, 115, 120, 125, 129,	134, 139
	dc.w 144, 149, 154, 159, 164, 169, 174,	179, 184, 188
SWITCH1
	dc.w 193, 198, 202, 207, 211, 215, 220,	223, 227, 231
	dc.w 234, 238, 241, 243, 246, 249, 251,	253, 255, 256
	dc.w 257, 258, 259
	dcb.w 5,260
	dc.w 259, 258, 257, 256, 254, 252, 250,	248, 245, 243
	dc.w 240, 236, 233, 230, 226, 222, 218,	214, 210, 205
	dc.w 201, 196, 192, 187, 182, 177, 172,	167, 162, 157
	dc.w 152, 147, 142, 137, 132, 128, 123,	118, 114, 110
	dc.w 105, 101, 97, 93, 90, 86, 83, 80, 77, 74, 72, 70
	dc.w 68, 66, 64, 63, 62, 61
	dcb.w 4,60
	dcb.w 2,61
	dc.w 62, 63, 65, 66, 68, 70, 73, 75, 78, 81, 84, 87, 91
	dc.w 95, 98, 103, 107, 111, 115, 120, 125, 129,	134, 139
	dc.w 144, 149, 154, 159, 164, 169, 174,	179, 184, 188
SWITCH1_1
	dc.w 193, 198, 202, 207, 211, 215, 220,	223, 227, 231
	dc.w 234, 238, 241, 243, 246, 249, 251,	253, 255, 256
	dc.w 257, 258, 259
	dcb.w 5,260
SWITCH2_1
	dc.w 259, 258, 257, 256, 254, 252, 250,	248, 245, 243
	dc.w 240, 236, 233, 230, 226, 222, 218,	214, 210, 205
	dc.w 201, 196, 192, 187, 182, 177, 172,	167, 162, 157
	dc.w 152, 147, 142, 137, 132, 128, 123,	118, 114, 110
	dc.w 105, 101, 97, 93, 90, 86, 83, 80, 77, 74, 72, 70
	dc.w 68, 66, 64, 63, 62, 61
SWITCH1_2
	dcb.w 4,60
	dcb.w 2,61
	dc.w 62, 63, 65, 66, 68, 70, 73, 75, 78, 81, 84, 87, 91
	dc.w 95, 98, 103, 107, 111, 115, 120, 125, 129,	134, 139
	dc.w 144, 149, 154, 159, 164, 169, 174,	179, 184, 188
SWITCH2
	dc.w 193, 198, 202, 207, 211, 215, 220,	223, 227, 231
	dc.w 234, 238, 241, 243, 246, 249, 251,	253, 255, 256
	dc.w 257, 258, 259
SWITCH2_2
	dcb.w 3,260
	dc.w -1

MoveY
	dc.w 100, 102, 105, 107, 110, 112, 115,	117, 119, 122
	dc.w 124, 126, 128, 130, 132, 134, 136,	138, 139, 141
	dc.w 142, 143, 145, 146
	dcb.w 2,147
	dc.w 148
	dcb.w 2,149
	dcb.w 6,150
	dcb.w 2,149
	dc.w 148, 147, 146, 145, 144, 143, 142,	140, 139, 137
	dc.w 136, 134, 132, 130, 128, 126, 124,	121, 119, 117
	dc.w 114, 112, 110, 107, 105, 102, 100,	97, 95,	92, 90
	dc.w 87, 85, 82, 80, 78, 76, 74, 71, 69, 67, 66, 64, 62
	dc.w 61, 59, 58, 56, 55, 54, 53
	dcb.w 2,52
	dcb.w 2,51
	dcb.w 6,50
	dcb.w 2,51
	dc.w 52, 53, 54, 55, 56, 57, 58, 60, 61, 63, 65, 67, 68
	dc.w 70, 72, 75, 77, 79, 81, 84, 86, 88, 91, 93, 96, 98
	dc.w 100, 102, 105, 107, 110, 112, 115,	117, 119, 122
	dc.w 124, 126, 128, 130, 132, 134, 136,	138, 139, 141
	dc.w 142, 143, 145, 146
	dcb.w 2,147
	dc.w 148
	dcb.w 2,149
	dcb.w 6,150
	dcb.w 2,149
	dc.w 148, 147, 146, 145, 144, 143, 142,	140, 139, 137
	dc.w 136, 134, 132, 130, 128, 126, 124,	121, 119, 117
	dc.w 114, 112, 110, 107, 105, 102, 100,	97, 95,	92, 90
	dc.w 87, 85, 82, 80, 78, 76, 74, 71, 69, 67, 66, 64, 62
	dc.w 61, 59, 58, 56, 55, 54, 53
	dcb.w 2,52
	dcb.w 2,51
	dcb.w 6,50
	dcb.w 2,51
	dc.w 52, 53, 54, 55, 56, 57, 58, 60, 61, 63, 65, 67, 68
	dc.w 70, 72, 75, 77, 79, 81, 84, 86, 88, 91, 93, 96, 98
	dc.w 100, 105, 110, 115, 119, 124, 128,	132, 136, 139
	dc.w 142, 145, 147, 148, 149
	dcb.w 3,150
	dc.w 149, 147, 145, 143, 140, 137, 134,	130, 126, 121
	dc.w 117, 112, 107, 102, 97, 92, 87, 82, 78, 74, 69, 66
	dc.w 62, 59, 56, 54, 52, 51
	dcb.w 3,50
	dc.w 51, 52, 54, 56, 58, 61, 65, 68, 72, 77, 81, 86, 91
	dc.w 96, 101, 106, 111,	116, 120, 125, 129, 133, 136, 140
	dc.w 143, 145, 147, 148, 149
	dcb.w 2,150
	dc.w 149, 148, 147, 145, 143, 140, 137,	133, 129, 125
	dc.w 121, 116, 111, 106, 101, 96, 91, 86, 82, 77, 73, 69
	dc.w 65, 62, 59, 56, 54, 52, 51
	dcb.w 3,50
	dc.w 51, 52, 54, 56, 59, 62, 65, 69, 73, 78, 82, 87, 92
	dc.w 97, 98, -1

BobsMove
	lea	MoveX(pc),a2
	lea	MoveY(pc),a3
	lea	DataBobs(pc),a0
	
	lea	SWITCH1(pc),a4
	lea	SWITCH2(pc),a6

; iterate until moveX+counter different from -1 then reset
.loop	addi.w	#2,X1
	moveq #0,d0
	move.w	X1,d0
	
	; If we are processing switch1 invert playfields
	lea     MoveX(pc),a1
	adda.l d0,a1
	cmp.l  a4,a1
	bne.w	.checkfromdxtosx
	bchg.b #6,BPLCON2
	; Change the skull jaw pasting data with the blitter - the jaw will be opened   
        BLTCPY3 #JAWLCLOSED,#LEFTSKULLJAW,#(64*1)+56
        BLTCPY3 #JAWRCLOSED,#RIGHTSKULLJAW,#(64*1)+56
	bra.w .continue;

; if the ball reaches the far left end than the crowman is on top
.checkfromdxtosx
	cmp.l  a6,a1
	bne.w .checkfromsxtodx2

	bchg.b #6,BPLCON2
	
	bra.w .continue

.checkfromsxtodx2
	cmp.l  #SWITCH1_1,a1
	;bne.w .checkfromdxtosx2
	bne.w .continue
	bchg.b #6,BPLCON2
	; Change the skull jaw pasting data with the blitter - the jaw will be opened   
        BLTCPY3 #JAWLOPEN,#LEFTSKULLJAW,#(64*1)+56
        BLTCPY3 #JAWROPEN,#RIGHTSKULLJAW,#(64*1)+56
        bra.w .continue

.checkfromdxtosx2
        cmp.l  #SWITCH2_1,a1
        bne.w .checkfromsxtodx3
        bchg.b #6,BPLCON2
        bra.w .continue

.checkfromsxtodx3
        cmp.l  #SWITCH1_2,a1
        bne.w .checkfromdxtosx3
        bchg.b #6,BPLCON2
	; Change the skull jaw pasting data with the blitter - the jaw will be closed
        BLTCPY3 #JAWLCLOSED,#LEFTSKULLJAW,#(64*1)+56
        BLTCPY3 #JAWRCLOSED,#RIGHTSKULLJAW,#(64*1)+56
        bra.w .continue

.checkfromdxtosx3
        cmp.l  #SWITCH2_1,a1
        bne.w .continue
        bchg.b #6,BPLCON2
        bra.w .continue

.continue
	cmpi.w	#-1,(a2,d0.w)
	bne.s	.nx1
	clr.w	X1
	addq #1,BannerCont
;	clr.w	flagChange
;	move.w	#1,flagBobs2
	bra.w	.loop

; Bob number 1
.nx1	move.w	(a2,d0.w),(a0) ; Set new X for Bob 1
	
.Y1	addi.w	#2,Y1
	move.w	Y1,d0
	cmpi.w	#-1,(a3,d0.w)
	bne.s	.ny1
	clr.w	Y1
	bra.s	.Y1

.ny1	move.w	(a3,d0.w),2(a0) ; Set new Y
	lea	20(a0),a0	; Go to bob number 2
	
	; Bob number 2
.x2	addi.w	#2,X2
	move.w	X2,d0
	cmpi.w	#-1,(a2,d0.w)
	bne.s	.nx2
	clr.w	X2
	bra.s	.x2

.nx2	move.w	(a2,d0.w),(a0) 	; Set new X for Bob 2

.y2	addi.w	#2,Y2
	move.w	Y2,d0
	cmpi.w	#-1,(a3,d0.w)
	bne.s	.ny2
	clr.w	Y2
	bra.s	.y2

.ny2	move.w	(a3,d0.w),2(a0) ; Set new Y for Bob 1
	lea	20(a0),a0
	

.x3	addi.w	#2,X3
	move.w	X3,d0
	cmpi.w	#-1,(a2,d0.w)
	bne.s	.nx3
	clr.w	X3
	bra.s	.x3

; Bob number 3
.nx3	move.w	(a2,d0.w),(a0)

.y3	addi.w	#2,Y3
	move.w	Y3,d0
	cmpi.w	#-1,(a3,d0.w)
	bne.s	.ny3
	clr.w	Y3
	bra.s	.y3

.ny3	move.w	(a3,d0.w),2(a0)
	lea	20(a0),a0

; Bob number 4
.x4	addi.w	#2,X4
	move.w	X4,d0
	cmpi.w	#-1,(a2,d0.w)
	bne.s	.nx4
	clr.w	X4
	bra.s	.x4

.nx4	
	move.w	(a2,d0.w),(a0)
.y4	addi.w	#2,Y4
	move.w	Y4,d0
	cmpi.w	#-1,(a3,d0.w)
	bne.s	.ny4
	clr.w	Y4
	bra.s	.y4

.ny4	
	move.w	(a3,d0.w),2(a0)
	lea     20(a0),a0
	
.x5	addi.w	#2,X5
	move.w	X5,d0
	cmpi.w	#-1,(a2,d0.w)
	bne.s	.nx5
	clr.w	X5
	bra.s	.x5

.nx5	move.w	(a2,d0.w),(a0)

.y5	addi.w	#2,Y5
	move.w	Y5,d0
	cmpi.w	#-1,(a3,d0.w)
	bne.s	.ny5
	clr.w	Y5
	bra.s	.y5

.ny5	move.w	(a3,d0.w),2(a0)
	lea	20(a0),a0

.x6	addi.w	#2,X6
	move.w	X6,d0
	cmpi.w	#-1,(a2,d0.w)
	bne.s	.nx6
	clr.w	X6
	bra.s	.x6

.nx6	move.w	(a2,d0.w),(a0)

.y6	addi.w	#2,Y6
	move.w	Y6,d0
	cmpi.w	#-1,(a3,d0.w)
	bne.s	.ny6
	clr.w	Y6
	bra.s	.y6

.ny6	move.w	(a3,d0.w),2(a0)
	lea	20(a0),a0

.x7	addi.w	#2,X7
	move.w	X7,d0
	cmpi.w	#-1,(a2,d0.w)
	bne.s	.nx7
	clr.w	X7
	bra.s	.x7

.nx7	move.w	(a2,d0.w),(a0)

.y7	addi.w	#2,Y7
	move.w	Y7,d0
	cmpi.w	#-1,(a3,d0.w)
	bne.s	.ny7
	clr.w	Y7
	bra.s	.y7

.ny7	move.w	(a3,d0.w),2(a0)
	lea	20(a0),a0

.x8	addi.w	#2,X8
	move.w	X8,d0
	cmpi.w	#-1,(a2,d0.w)
	bne.s	.nx8
	clr.w	X8
	bra.s	.x8

.nx8	move.w	(a2,d0.w),(a0)

.y8	addi.w	#2,Y8
	move.w	Y8,d0
	cmpi.w	#-1,(a3,d0.w)
	bne.s	.ny8
	clr.w	Y8
	bra.s	.y8

.ny8	move.w	(a3,d0.w),2(a0)
	lea	20(a0),a0

.x9	addi.w	#2,X9
	move.w	X9,d0
	cmpi.w	#-1,(a2,d0.w)
	bne.s	.nx9
	clr.w	X9
	bra.s	.x9

.nx9	move.w	(a2,d0.w),(a0)

.y9	addi.w	#2,Y9
	move.w	Y9,d0
	cmpi.w	#-1,(a3,d0.w)
	bne.s	.ny9
	clr.w	Y9
	bra.s	.y9

.ny9	move.w	(a3,d0.w),2(a0)
	lea	20(a0),a0


	rts


; Blit all bobs drawing the picture

ball		ds.l	1
ballmask	ds.l	1

BlitBobs
	lea	DataBobs(pc),a0 ; load the address of the bobs in a0
	;bsr.w	waitblitter
	;move.l	#$220022,$dff060 ; module for C and B channels at 34 ball
	;move.l	#$220022,$dff064 ; module for A and D channels at 34 ball
	move.l #$00220000,$dff060
	move.l #$00000022,$dff064
	move.w	nbBobs(pc),d6    ; for each bob
.loopbobs
	move.l	ball,4(a0)  ; load the bob pointer into the bobs data
	move.l	ballmask,8(a0) ; load the mask pointer into the bobs data

	; Copy bltcon0-1 from the bob to the blitter register
	move.w	16(a0),d0
	move.w	d0,$dff042
	ori.w	#$fca,d0
	move.w	d0,$dff040

	; Copy the ball data address into a1
	movea.l	4(a0),a1

	; copy screen data address into a2
	movea.l	12(a0),a2

	moveq	#2-1,d5	; for each bitplane
.loopbpl
	move.l	8(a0),$dff050 	; A channel address (MASK)
	move.l	a1,$dff04c    	; B channel address (ptBob)
	move.l	a2,$dff048    	; C channel address  (Screen)
	move.l	a2,$dff054    	; D channel address  (Dest Screen)
	move.w	18(a0),$dff058	; Blit the ball!!!
	bsr	waitblitter
;	lea	40*256(a1),a1 ball
	lea	32*6(a1),a1
	lea	40*256(a2),a2
	dbf	d5,.loopbpl

	; go to next bob
	lea	20(a0),a0
	dbf	d6,.loopbobs
	rts

; Clear all bobs replacing the picture with zeros
BobsClear

	move.w #$FFFF,$dff044 ; BLTAFWM - Blitter first word mask for source A
        move.w #$FFFF,$dff046 ; BLTALWM - Blitter last word mask for source A
        move.w #$0000,$dff042 ; BLTCON1

	lea	DataBobs(pc),a0 ; load the address of the bobs in a0
	bsr.w	waitblitter     ; wait for the blitter to be available
	move.w	#40-6,$dff066   ; set blitter module for channel D to 34 (1 row 40 bytes - bob width 3 words aka 6 bytes)

	move.w	nbBobs(pc),d6   ; for each bob
.loopbobs
	move.w	#$100,$dff040   ; set bltcon0 to use source 'D' and no minterms (to force zeroing the memory)
	move.l	12(a0),d1	; calculate destination address on the screen

	moveq	#2-1,d5		; for each bitplane 
.loopbpl
	move.l	d1,$dff054	; set channel D address for the blitter
	move.w	18(a0),$dff058	; BLIT!!!!! the bltsize is at databobs+18
	bsr.w	waitblitter

	; get address of the next bitplane
	addi.l	#40*256,d1
	dbf	d5,.loopbpl ; end of foreach bitplane loop


	lea	20(a0),a0
	dbf	d6,.loopbobs ; end of foreach bob loop

	rts
	
BobsNewPos
	lea	DataBobs(pc),a0 ; load the address of the bobs in a0
	move.w	nbBobs(pc),d5   ; for each bob
.loopbobs
	; Get the y screen position multiplying by 40 the y value of each
	; databob
;	lea	PIC,a1 ball2
	lea	BALLBITPLANE_1,a1
	move.w	2(a0),d0
	mulu.w	#40,d0
	add.w	d0,a1 ; a1 now holds the screen position at row 'y'

	
	move.w	(a0),d0
	asl.w	#4,d0
	move.w	d0,d1
	asr.w	#7,d0
	adda.w	d0,a1 ; a1 now holds the screen position at row 'y' and	colum 'x'

	move.l	a1,12(a0) ; Store the new screen address into the bob at byte 12

	; Stores information for  bltcon0 and bltcon1 (shift bits and
	; ascending / discending mode 
	asl.w	#8,d1
	move.w	d1,16(a0)

	; go to next bob
	lea	20(a0),a0
	dbf	d5,.loopbobs
	rts

nbBobs	dc.w	8-1 ; add bobs
DataBobs
	dc.w 100,128	; x,y
	dc.l ballpic
	dc.l ballpicmsk
	dc.l BALLBITPLANE_1
	dc.w 0
	dc.w 32*64+6/2	; bltsize
	
	dc.w 140,128	; x,y
	dc.l ballpic	; $26192
	dc.l ballpicmsk
;	dc.l PIC	ball2
	dc.l BALLBITPLANE_1
	dc.w 0
	dc.w 32*64+6/2	; bltsize

	dc.w 180,128    ; x,y
        dc.l ballpic    ; $26192
        dc.l ballpicmsk
;       dc.l PIC        ball2
        dc.l BALLBITPLANE_1
        dc.w 0
        dc.w 32*64+6/2  ; bltsize

	BALLOBJ ; Bob 4
	BALLOBJ ; Bob 5
	BALLOBJ ; Bob 6
	BALLOBJ ; Bob 7
	BALLOBJ ; Bob 8
	BALLOBJ ; Bob 9  

	
InitBITCHKBOARD
	LOADBITPLANE #CHECKER_RAW_1,BPLPOINTERS2
	LOADBITPLANE #CHECKER_RAW_2,BPLPOINTERS2_1
	LOADBITPLANE #CHECKER_RAW_3,BPLPOINTERS2_2
	lea CHKBOARD_COPPERLIST,a0
	move.l #$a903fffe,(a0)
	addq #1,BannerCont
	rts
	
InitCheckboard
	move.l #$2000,dirposChecker
	bsr.w initCheckerH
	;lea CHECKER_RAW_3+40*128,a0
	;move.w #40*158-1,d0
;.fill	move.b #-1,(a0)+
;	dbf d0,.fill
	
initCheckerH
	lea	BufHL(pc),a0
	move.w	#768,d4
	move.w	#64-1,d3
.loop1	move.w	#26-1,d2
	move.w	d4,d0
.loop2	move.w	d0,d1
	asr.w	#1,d1
	addi.w	#128,d1
	move.l	#$4b00,d5
	divu.w	d1,d5
	addi.w	#133,d5
	move.b	d5,(a0)+
	subi.w	#32,d0
	dbf	d2,.loop2
	subi.w	#1,d4
	dbf	d3,.loop1
	rts
	
BufHL		ds.b	64*26

posChecker	ds.l	1
incposChecker	ds.l	1
dirposChecker	ds.l	1

chkval1		ds.l	1
chkval2		ds.l	1
chkval3		ds.w	1
chkval4		ds.w	1

flagPal 	ds.w	1
timerMovGrad	ds.l	1

CheckerColTab
	dc.w $000f,$0000,$0008,$0000,$0000,$000f,$0000,$0008,$000f,$0000
	dc.w $0008,$0000,$0000,$000f,$0000,$0008,$000f,$0000,$0008,$0000
	dc.w $0000,$000f,$0000,$0008,$000f,$0000,$0008,$0000,$0000,$000f
	dc.w $0000,$0008,$000f,$0000,$0008,$0000,$0000,$000f,$0000,$0008
	dc.w $000f,$0000,$0008,$0000,$0000,$000f,$0000,$0008,$000f,$0000
	dc.w $0008,$0000,$0000,$000f,$0000,$0008,$001f,$0000,$0018,$0000
	dc.w $0000,$002f,$0000,$0018,$003f,$0000,$0028,$0000,$0000,$004f
	dc.w $0000,$0028,$005f,$0000,$0038,$0000,$0000,$006f,$0000,$0038
	dc.w $007f,$0000,$0048,$0000,$0000,$008f,$0000,$0048,$009f,$0000
	dc.w $0058,$0000,$0000,$00af,$0000,$0058,$00bf,$0000,$0068,$0000
	dc.w $0000,$00cf,$0000,$0068,$00df,$0000,$0078,$0000,$0000,$00ef
	dc.w $0000,$0078,$00ff,$0000,$0088,$0000,$0000,$00ff,$0000,$0088
	dc.w $00ef,$0000,$0078,$0000,$0000,$00df,$0000,$0078,$00cf,$0000
	dc.w $0068,$0000,$0000,$00bf,$0000,$0068,$00af,$0000,$0058,$0000
	dc.w $0000,$009f,$0000,$0058,$008f,$0000,$0048,$0000,$0000,$007f
	dc.w $0000,$0048,$006f,$0000,$0038,$0000,$0000,$005f,$0000,$0038
	dc.w $004f,$0000,$0028,$0000,$0000,$003f,$0000,$0028,$002f,$0000
	dc.w $0018,$0000,$0000,$001f,$0000,$0018,$000f,$0000,$0008,$0000
	dc.w $0000,$000f,$0000,$0008,$010f,$0000,$0108,$0000,$0000,$020f
	dc.w $0000,$0108,$030f,$0000,$0208,$0000,$0000,$040f,$0000,$0208
	dc.w $050f,$0000,$0308,$0000,$0000,$060f,$0000,$0308,$070f,$0000
	dc.w $0408,$0000,$0000,$080f,$0000,$0408,$090f,$0000,$0508,$0000
	dc.w $0000,$0a0f,$0000,$0508,$0b0f,$0000,$0608,$0000,$0000,$0c0f
	dc.w $0000,$0608,$0d0f,$0000,$0708,$0000,$0000,$0e0f,$0000,$0708
	dc.w $0f0f,$0000,$0808,$0000,$0000,$0f0f,$0000,$0808,$0e0f,$0000
	dc.w $0708,$0000,$0000,$0d0f,$0000,$0708,$0c0f,$0000,$0608,$0000
	dc.w $0000,$0c0f,$0000,$0608,$0a0f,$0000,$0508,$0000,$0000,$090f
	dc.w $0000,$0508,$080f,$0000,$0408,$0000,$0000,$070f,$0000,$0408
	dc.w $060f,$0000,$0308,$0000,$0000,$050f,$0000,$0308,$040f,$0000
	dc.w $0208,$0000,$0000,$030f,$0000,$0208,$020f,$0000,$0108,$0000
	dc.w $0000,$010f,$0000,$0108,$000f,$0000,$0008,$0000,$0000,$000f
	dc.w $0000,$0008,$011e,$0000,$0008,$0000,$0000,$022d,$0000,$0117
	dc.w $033c,$0000,$0117,$0000,$0000,$044b,$0000,$0226,$055a,$0000
	dc.w $0226,$0000,$0000,$0669,$0000,$0335,$0778,$0000,$0335,$0000
	dc.w $0000,$0887,$0000,$0444,$0996,$0000,$0444,$0000,$0000,$0aa5
	dc.w $0000,$0553,$0bb4,$0000,$0553,$0000,$0000,$0cc3,$0000,$0662
	dc.w $0dd2,$0000,$0662,$0000,$0000,$0ee1,$0000,$0771,$0ff0,$0000
	dc.w $0771,$0000,$0000,$0ff0,$0000,$0880,$0ee1,$0000,$0771,$0000
	dc.w $0000,$0dd2,$0000,$0771,$0cc3,$0000,$0662,$0000,$0000,$0bb4
	dc.w $0000,$0662,$0aa5,$0000,$0553,$0000,$0000,$0996,$0000,$0553
	dc.w $0887,$0000,$0444,$0000,$0000,$0778,$0000,$0444,$0669,$0000
	dc.w $0335,$0000,$0000,$055a,$0000,$0335,$044b,$0000,$0226,$0000
	dc.w $0000,$033c,$0000,$0226,$022d,$0000,$0117,$0000,$0000,$011e
	dc.w $0000,$0117,$000f,$0000,$0008,$0000,$0000,$000f,$0000,$0008
	dc.w $000f,$0000,$0008,$0000,$0000,$000f,$0000,$0008,$000f,$0000
	dc.w $0008,$0000,$0000,$000f,$0000,$0008,$000f,$0000,$0008,$0000
	dc.w $0000,$000f,$0000,$0008,$000f,$0000,$0008,$0000,$0000,$000f
	dc.w $0000,$0008,$000f,$0000,$0008,$0000,$0000,$000f,$0000,$0008
	dc.w $000f,$0000,$0008,$0000,$0000,$000f,$0000,$0008,$000f,$0000
	dc.w $0008,$0000,$0000,$000f,$0000,$0008,$000f,$0000,$0008,$0000
	dc.w $0000,$000f,$0000,$0008,$000f,$0000,$0008,$0000,$0000,$000f
	dc.w $0000,$0008
CheckerColTabEnd


MovChecker
	move.w	posChecker,d0
	andi.w	#63,d0
	mulu.w	#26,d0
	lea	BufHL(pc),a0
	adda.l	d0,a0
	move.w	posChecker,d0
	andi.l	#$1FC0,d0
	asr.l	#3,d0
	lea	CheckerColTabEnd(pc),a1
	suba.l	d0,a1
	tst.w	d0
	bne.s	.cont
	lea	CheckerColTab(pc),a1
.cont	lea	CLChecker,a2
	move.w	(a1)+,CLcol+2
	move.w	(a1)+,CLcol2+2
	adda.l	#4,a1
	cmpa.l	#CheckerColTabEnd,a1
	bne.s	.notyet
	lea	CheckerColTab(pc),a1
.notyet	
	move.w	#13-1,d0
	clr.w	d1
	clr.w	flagPal
.loop
	clr.w	d1
	move.b	(a0)+,d1
	move.b	(a0)+,d7
	cmpi.w	#144,d1
	bgt.s	.nopal
	tst.w	flagPal
	bne.s	.nopal
	move.w	#255,flagPal
	move.l	#$FFDFFFFE,(a2)+
.nopal	move.b	d1,(a2)+
	move.b	#1,(a2)+
	move.w	#$FF00,(a2)+
	move.w	#$198,(a2)+
	move.w	(a1)+,(a2)+
	move.w	#$19C,(a2)+
	move.w	(a1)+,(a2)+
	move.w	#$19A,(a2)+
	move.w	(a1)+,(a2)+
	move.w	#$19E,(a2)+
	move.w	(a1)+,(a2)+
	cmpa.l	#CheckerColTabEnd,a1
	blt.s	.notyet2
	lea	CheckerColTab(pc),a1
.notyet2
	dbf	d0,.loop

	move.l	incposChecker,d0
	add.l	d0,posChecker
	cmpi.l	#200,timerMovGrad
	blt.s	timer200
	move.l	dirposChecker,d0
	add.l	d0,incposChecker
	cmpi.w	#8,incposChecker
	bne.s	.pos
	cmpi.l	#600,timerMovGrad
	bgt.s	timer600
	neg.l	dirposChecker
.pos
	cmpi.w	#-8,incposChecker
	bne.s	.skip
	neg.l	dirposChecker
.skip
	bra.s	timer200

timer600:
	clr.l	dirposChecker

timer200:
	tst.w	flagPal
	bne.s	.nopal
	move.l	#$FFDFFFFE,(a2)+
.nopal	
	move.l	#$4b01FF00,(a2)+
	move.l	#$1900000,(a2)+
	move.l	#$1920000,(a2)+
	move.l	#$1940000,(a2)+
	move.l	#$1980000,(a2)+
	move.l	#$19A0000,(a2)+
	move.l	#$19B0000,(a2)+
	move.l	#$19C0000,(a2)+
	move.l	#$19E0000,(a2)+
	move.l	#$1080000,(a2)+
	move.l	#$1800000,(a2)+
	move.l	#$10A0000,(a2)+
	move.l	#-2,(a2)+
	rts

	
FadeInBitplane1
        ; Delay
        cmp.w #_FADEDELAY,FadeDelayCounter
        bne.s EndFadeIn
        move.w  #0,FadeDelayCounter

        ; Do not perform fade after FadeIn has been called 16 times
        cmp.w   #17,FadeCounter
        beq.s   EndFadeIn

        ; Put FadeCounter in d0
        moveq   #0,d0
        move.w  FadeCounter(PC),d0

        moveq   #7-1,d7 ; Number of colors
        lea     TabColorsPic(PC),a0 ; Load colors table in a0
        lea     COLORS+6,a1         ; Load copperlist colors in a1 (color 0 is skipped)
        
        bsr.s   Fade    ; Call the fade routine
        addq.w  #1,FadeCounter  ; Increase Fade counter by one
EndFadeIn
        addq.w  #1,FadeDelayCounter
        rts

FadeDelayCounter
        dc.w 0

; Fade counter - expected to contain values from 0 to 17
FadeCounter
        dc.w 0

TabColorsPic
        dc.w $004    ; color1
        dc.w $532    ; color2
        dc.w $fff    ; color3
        dc.w $840    ; color4
        dc.w $c75    ; color5
        dc.w $a00    ; color6
        dc.w $f96    ; color7
        
FadeInBitplane2
	; Delay
	cmp.w #_FADEDELAY,FadeDelayCounter2
	bne.s EndFadeIn2
	move.w  #0,FadeDelayCounter2

	; Do not perform fade after FadeIn has been called 16 times
	cmp.w	#17,FadeCounter2
	beq.s	EndFadeIn2

	; Put FadeCounter in d0
	moveq	#0,d0
	move.w	FadeCounter2(PC),d0

	moveq	#7-1,d7	; Number of colors
	lea	TabColorsBanner(PC),a0 ; Load colors table in a0
	lea	COLORSBITPLANE2+2,a1	    ; Load copperlist colors in a1
	
	bsr.s	Fade	; Call the fade routine
	addq.w	#1,FadeCounter2	; Increase Fade counter by one
EndFadeIn2
	addq.w  #1,FadeDelayCounter2
	rts

FadeDelayCounter2
	dc.w 0

; Fade counter - expected to contain values from 0 to 17
FadeCounter2
	dc.w 0

TabColorsBanner
	dc.w $0000
	dc.w $0811
	dc.w $0faf
	dc.w $0400
	dc.w $0d11
	dc.w $0f47
	dc.w $0f6d

; Actual fade routine
Fade
ColorLoop
        moveq   #0,d1           ; clear d1
        moveq   #0,d2           ; clear d2

; Get red value of the final color, multiply it for the fade counter
        ; and divide by 16, store the result in the copperlist
        move.b  (a0)+,d1
        mulu.w  d0,d1
        lsr.w   #4,d1
        move.b  d1,(a1)+

        ; Get green value of the final color, multiply it for the fade counter
        ; and divide by 16
        move.b  (a0),d1
        lsr.b   #4,d1
        mulu.w  d0,d1
        and.b   #$f0,d1

        ; Get blu value of the final color, multiply it for the fade counter
        ; and divide by 16
        move.b  (a0)+,d2
        and.b   #$0f,d2
        mulu.w  d0,d2
        lsr.w   #4,d2

        ; join blu and green in d1 and store them in copperlist
        or.w    d2,d1
        move.b  d1,(a1)+

        ; Point next color in copperlist
        addq.w  #2,a1
        dbra    d7,ColorLoop    ; Loop for each color
        rts


SetupCreditScene

	REDUCE_COPPERLIST ; Exlude checkerboard copperlist
	
	; Change background color
	lea COLORS,a1
	move.w #$555,2(a1)
	
	; Change foreground font color
	move.w #$fff,6(a1)
	move.w #$fff,10(a1)
	move.w #$fff,14(a1)
	move.w #$fff,18(a1)
	move.w #$fff,22(a1)
	move.w #$fff,26(a1)
	move.w #$fff,30(a1)
	
	; Change colors for bitplane 2
	lea COLORSBITPLANE2,a1
	move.w #$444,2(a1)
	move.w #$666,6(a1)
	move.w #$888,10(a1)
	move.w #$ccc,14(a1)
	move.w #$555,18(a1)
	move.w #$bbb,22(a1)
	move.w #$666,26(a1)
	
	; Clear bitplanes
	BLTCLEAR #BALLBITPLANE_1,#BALLBITPLANE_1,#$c014

	LOADBITPLANE #GREETINGS_SCREEN2,BPLPOINTERS1
	LOADBITPLANE #GREETINGS_SCREEN2,BPLPOINTERS1_1 
	LOADBITPLANE #SCREEN_1,BPLPOINTERS1_2
	
	
	MOVE.L	#CORVO5,d0	; store address playfield 1 (bitplanes 1-3-5)
	LEA	BPLPOINTERS2,A1
	MOVEQ	#3-1,D1
POINTBPCORVO5
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0
	addq.w	#8,a1
	dbra	d1,POINTBPCORVO5
	
	move.l #SCREEN_2,a1
	add.l #_FONT_HPADDER*_SCREEN_HBYTES,a1
	
	moveq #48-1,d3
ROWCYCLE	
	
	moveq #20-1,d1
TEXTCYCLE
	
    move.l GREETINGSCHARADDRESS_1,a0
    moveq #0,d2
    move.b (a0),d2
    sub.b #$20,d2
    mulu.w #_FONT_HBYTES*_FONT_VPIXELS,d2
    move.l d2,a2
    add.l #FONT,a2 ; a2 now contains the address of the character into the fonts file

    move.w (a2),(a1)
    move.w 2(a2),40(a1)
    move.w 4(a2),80(a1)
    move.w 6(a2),120(a1)
    move.w 8(a2),160(a1)
    move.w 10(a2),200(a1)
    move.w 12(a2),240(a1)
	
    move.w 14(a2),280(a1)
    move.w 16(a2),320(a1)
    move.w 18(a2),360(a1)
    move.w 20(a2),400(a1)
    move.w 22(a2),440(a1)
    move.w 24(a2),480(a1)
    move.w 26(a2),520(a1)
	
    move.w 28(a2),560(a1)
    move.w 30(a2),600(a1)
    move.w 32(a2),640(a1)
    move.w 34(a2),680(a1)
	
    move.w 36(a2),720(a1)
    move.w 38(a2),760(a1)
	
    addq #2,a1
    add.l #1,GREETINGSCHARADDRESS_1
	
    dbra d1,TEXTCYCLE
	
    add.l #(25*40),a1
    dbra d3,ROWCYCLE
	
    ; Init new music (fordentino)
    move.l	#mt_data2,mt_data
    bsr.w   mt_init ; init music
    rts

    ; This routine increases the bitplane pointer each 16 iterations
ScrollPlayfield
    cmp.w #0,SCROLLPLAYFIELDCOUNTER
    bne.w NoScrollPlayfield
    
    ; Move bitplane pointer up
    lea	BPLPOINTERS1_2,a1
    move.w	2(a1),d0
    swap d0
    move.w	6(a1),d0
    add.l	#40,d0
    lea	BPLPOINTERS1_2,a1
    move.w	d0,6(a1)
    swap d0
    move.w	d0,2(a1)
    swap d0
    
    move.l d0,a1
    cmp.l #SCREEN_3,a1
    bne NoScrollPlayfield
    LOADBITPLANE #SCREEN_1,BPLPOINTERS1_2

    addq #1,SCROLLCOUNTER
    cmp.w #_FONT_VPIXELS+_FONT_HPADDER+_FONT_LPADDER-1,SCROLLCOUNTER
    bne NoScrollPlayfield
    move.w #0,SCROLLCOUNTER
      
NoScrollPlayfield
    addq #1,SCROLLPLAYFIELDCOUNTER
    cmp.w #_SCROLLPLAYFIELDSPEED,SCROLLPLAYFIELDCOUNTER
    bne.w ExitScrollPlayfield
    move.w #0,SCROLLPLAYFIELDCOUNTER
ExitScrollPlayfield
    rts

; Pointer to the text to print (previous row)
GREETINGSCHARADDRESS_1 
    dc.l WSTART

; Pointer to the row in the bitplane where to print
ROWPTR
    dc.l SCREEN_1

; How many times the rows have been been printed (starts from 0)
SCROLLCOUNTER
    dc.b 0,0

SCROLLPLAYFIELDCOUNTER
    dc.b 0,0
	
MoveStars
	lea STARFIELDSPRITE,a0
stars_loop
	; FAST STARS
	cmpi.b #$f0,1(a0)	; 1(a0) points to the star vsprite
				; and $f0 = 240 , so we check if
				; the sprite has reached screen width (256)
				; minus sprite width (16px)
				
	bne	no_border1	; If not we have not reached the right of
				; the screen and we branch to no_border
				
	; If we are here we have to reset the star position since the star
	; reached the right border of the screen
	move.b #30,1(a0)
	
no_border1
	; Here we move the star to the right
	addq.b #1,1(a0)
	
	; process the next star
	addq.w #8,a0
	
	; SLOW STARS
	cmpi.b #$f0,1(a0)
	bne	no_border2
	move.b #30,1(a0)
no_border2
	bchg #0,3(a0)
	beq.s star_even
	addq.b #1,1(a0)
star_even
	; process the next star
	addq.w #8,a0
	
	; FASTEST STARS
	cmpi.b #$f0,1(a0)
	bne.s no_border3
	move.b #30,1(a0)
no_border3
	addq.b #2,1(a0)	
	; process the next star
	addq.w #8,a0
	
	; check if we are processing the last star, if this is the case do rts
	cmp.l #STARFIELDSPRITEEND,a0
	blo.s stars_loop
	rts 	
	
	
MoveSpriteEyes
	LOAD_OLD_SPRITE_POS TABXPOINT(PC),d0
	cmp.w SKULLCURRENTXPOSITION,d0
	bhi.s PrintLeftEyes
	
	LOAD_OLD_SPRITE_POS TABYPOINT(PC),d0
	cmp.w SKULLCURRENTYPOSITION,d0
	bhi.s PrintTopRightEyes
	
	; Print skull's eyes pointing to bottom right
	PRINT_EYES_BOTTOM_RIGHT 
	bra.w MoveSpriteEyesEnd

; Print skull's eyes pointing to top right	
PrintTopRightEyes
	PRINT_EYES_TOP_RIGHT
	bra.s MoveSpriteEyesEnd

PrintLeftEyes
	LOAD_OLD_SPRITE_POS TABYPOINT(PC),d0
	cmp.w SKULLCURRENTYPOSITION,d0
	bhi.s PrintTopLeftEyes
	PRINT_EYES_BOTTOM_LEFT
	bra.s MoveSpriteEyesEnd
	
; Print skull's eyes pointing to top left
PrintTopLeftEyes
	PRINT_EYES_TOP_LEFT

MoveSpriteEyesEnd
	rts
	
	
; Routine to print a a character on the first bitplane
PrintChar
	subq.w #1,printcharcounter ; We perform this routine only after
	bne.w	noprint		   ; we shifted the text 16 times to make
				   ; some space for the new character on the
				   ; screen, to do this we use a counter
	
	; if we are here we must print a new character, so we reset the
	; counter to 16
	move.w	#16,printcharcounter
	
	move.l charaddress,a0 ; Load address to the char to print in a0
	addq.l #1,charaddress ; next time we will point at the next char
	moveq #0,d2	 ; Clean d2
	move.b (a0),d2	 ; Copy character pointed by a0 in d2
	bne.s noreset	 ; if we are pointing a 0 character we are at the end
			 ; in this case we start over from the beginning
	
	; start of reset section (return to the first character)
	
	; force move to next demo section
	bra.w spritedisable1
	
	lea TEXT(pc),a0
	move.l #TEXT,charaddress
	move.b (a0),d2
	addq.l #1,charaddress
	;end of reset section
	
noreset		 
	sub.b #$20,d2	 ; Subtract 32 decimal because font file starts with
			 ; space (ascii 32)
	
	;add.l d2,d2	 ; Fonts are 16px wide so we need to double d2
			 ; to get the correct displacement
	
	mulu.w #40,d2	 ; each font is 16X20 so the displacement is 2bytes
			 ; for 20 rows = 40 bytes
			 
	move.l d2,a2	 ; Now we have the displacement, lets copy the font
			 ; address in a2 and then add the displacement
	add.l #FONT,a2	 ; to get the real font address in a2
	
	; From now we use the blitter to copy the font on the first bitplane
	BLTCPY2 a2,#PIC+38,BLTWAIT13,#(20<<6)+1
	
noprint
	rts
	
printcharcounter
	dc.w 16
	
charaddress
	dc.l TEXT
; End of printchar routine

; Routine to copy and paste the text from and to the first bitplane
; Each time the bits will be left shifted giving the illusion of the text
; moving from right to left
MoveText
	move.l #PIC+((20*(0+20))-1)*2,d0
	btst #6,$dff002
waitblitmovetext
	btst #6,$dff002
	bne.s waitblitmovetext
	
	move.l #$19f00002,$dff040 ; BLTCON0 and BLTCON1
				  ; copy from chan A to chan D
				  ; with 1 pixel left shift
	
	move.l #$ffff7fff,$dff044 ; delete leftmost pixel
	
	move.l d0,$dff050	  ; load source
	move.l d0,$dff054	  ; load destination
	
	move.l #$00000000,$dff064 ; BTLAMOD and BTLDMOD will be zeroed
				  ; because the blitter operation will take
				  ; the whole screen width
				  
	move.w #(20*64)+20,$dff058 ; the rectangle we are blitting it is 20px
				  ; high (like the font heght) and
				  ; 20 bytes wide (the whole screen)
	
	rts
	
; End of movetext routine --------------------	-----------
	
TEXT
;	dc.b "TANTI SALUTI AMIGOSI A DR PROCTON, MCK, CIPPO, "
;	dc.b "ALEGHID, CGUGL, TRANTOR, IL GRUPPO RAMJAM, "
;	dc.b "SUKKOPERA, MISANTHROPIXEL, DIVINA, FAROX68, AMIWELL79, "
;	dc.b "SCHIUMACAL, DANYPPC, MAK73, SEIYA, Z3K E A TUTTI GLI UTENTI DI AMIGAPAGE.IT         "
	dc.b "THE CROWS AMIGADEMO BY OZZYBOSHI AND DR.PROCTON, CLICK LEFT MOUSE BUTTON TO CONTINUE...     "
	dc.b "MUSIC BY FABIO 'BOVE' BOVELACCI AKA FRATER SINISTER - "
	dc.b " 1-3-1976/7-9-2014    R.I.P.                          "
	dc.b "@BOVELACCI TWEETFEED:                "
	dc.b "21 AGOSTO 2014   -   IO NON HO #ORECCHIE PER #INTENDERE NE #MENTE PER #CAPIRE                         "
	dc.b "#PENSATE UN PO QUEL CHE #CAZZO VI PARE - NON ESISTE MORTE #INDOLORE - NE TANTOMENO VITA               "
	dc.b "NON ESISTE #INTEGRAZIONE, MA SOLO #INVASIONE #SOPRAFFAZIONE E #SCHIAVITU                              "
	dc.b "20 AGOSTO 2014   -   AVENDO GIA RICEVUTO L'#UNZIONE DEGLI #INFERMI, MI E GARANTITA UNA #VISITA DI #GES"
	dc.b "U PRIMA DI #MORIRE : PROBABILMENTE MI RIEMPIRA DI #BOTTE                     "
	dc.b "19 AGOSTO 2014   -   NON E' UN COMPUTER SE NON HA UN #MONITOR NON PIU' GRANDE DI 14 POLLICI A FOSFORI VERDI            "
	dc.b "19 AGOSTO 2104   -   FORLI' DI NOTTE - IN #PIAZZA CI SONO I #MIGLIORI : IO E GLI #EXTRACOMUNITARI                   ",0    
	
; Routine to move the skull along the Y AXIS
MoveSpriteY
		ADDQ.L	#2,TABYPOINT	 ; Point to the next array element
					 ; TABYPOINT is a word so we need a
					 ; 2 bytes jump
					 
		MOVE.L	TABYPOINT(PC),A0 ; copy TABXPOINT address in a0

		CMP.L	#FINETABY-2,A0  ; Check if we are at the end of the array
		BNE.S	NOBSTARTY	; If not goto NOBSTARTY to move 
		MOVE.L	#TABY-2,TABYPOINT ; Restart at the first array element

NOBSTARTY
		moveq	#0,d0		; Clean d0
		MOVE.w	(A0),d0		; copy Y position in d0
		move.w	d0,SKULLCURRENTYPOSITION; save the current Y POSITION
		;MOVE.b	d0,VSTART2	; copy Y position at VSTART
		move.b  d0,LEFTSKULLVSTART
		;move.b	d0,VSTART3	; Same thing for sprite1 (both same height)
		move.b  d0,RIGHTSKULLVSTART
		btst.l	#8,d0		; if position grater than  255 ($FF)
		beq.s	NonVSTARTSET	; if not clear bit 2
		bset    #2,LEFTSKULL+3  ; Set VSTART 8th bit  
		bset.b	#2,RIGHTSKULL+3 ; Same for sprite 1
		bra.s	ToVSTOP		; Force Jump to ToVstop routine

NonVSTARTSET
		;bclr.b	#2,MYSPRITE2+3  ; bit clearing
		bclr.b  #2,LEFTSKULL+3
		;bclr.b  #2,MYSPRITE3+3  ; bit clearing
		bclr.b  #2,RIGHTSKULL+3

ToVSTOP
					; Add height of the sprite to
		add.w   #52,d0		; calculate vstop, in this case
					; the skull is 50 pixel high
					
					; VSTOP setting on both sprites
		move.b  d0,LEFTSKULLVSTOP
		move.b  d0,RIGHTSKULLVSTOP
					; Like vstart we must tell if Y>255
					; but in this case we set/clear bit 1
					; of the sprite control byte 
		btst.l	#8,d0
		beq.s	NonVSTOPSET
		bset.b  #1,LEFTSKULL+3
		bset.b   #1,RIGHTSKULL+3
		bra.w	VstopFIN
NonVSTOPSET
		bclr.b	#1,LEFTSKULL+3
		bclr.b	#1,RIGHTSKULL+3

VstopFIN
		rts

TABYPOINT
		dc.l	TABY-2

; Routine to move the sprite along the X AXIS
MoveSprite
		ADDQ.L	#2,TABXPOINT
		MOVE.L	TABXPOINT(PC),A0
		CMP.L	#FINETABX-2,A0
		BNE.S	NOBSTARTX
		MOVE.L	#TABX-2,TABXPOINT


NOBSTARTX
	moveq	#0,d0
	move.w  (a0),d0
	move.w	d0,SKULLCURRENTXPOSITION; save the current X POSITION
	btst	#0,D0
	beq.s	BitBassoZERO
	bset    #0,LEFTSKULL+3
	bset 	#0,RIGHTSKULL+3
	bra.s	PlaceCoords

BitBassoZERO
	bclr	#0,LEFTSKULL+3
	bclr	#0,RIGHTSKULL+3
PlaceCoords
	lsr.w	#1,D0
	move.b	d0,LEFTSKULLHSTART
	move.b	d0,RIGHTSKULLHSTART
	addi.b	#8,RIGHTSKULLHSTART
	rts

SKULLCURRENTXPOSITION
	dc.w 0
SKULLCURRENTYPOSITION
	dc.w 0
	
TABXPOINT
		dc.l	TABX-2
		
; f(x) = 80sin((1/-45.8599)x)+130

TABX
	dc.w $80,$81,$82,$83,$84,$85,$86,$87,$88,$89
	dc.w $8a,$8b,$8c,$8d,$8e,$8f,$90,$91,$92,$93
	dc.w $94,$95,$96,$97,$98,$99,$9a,$9b,$9c,$9d
	dc.w $9e,$9f,$a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7
	dc.w $a8,$a9,$aa,$ab,$ac,$ad,$ae,$af,$b0,$b1
	dc.w $b2,$b3,$b4,$b5,$b6,$b7,$b8,$b9,$ba,$bb
	dc.w $bc,$bd,$be,$bf,$c0,$c1,$c2,$c3,$c4,$c5
	dc.w $c6,$c7,$c8,$c9,$ca,$cb,$cc,$cd,$ce,$cf
	dc.w $d0,$d1,$d2,$d3,$d4,$d5,$d6,$d7,$d8,$d9
	dc.w $da,$db,$dc,$dd,$de,$df,$e0,$e1,$e2,$e3
	dc.w $e4,$e5,$e6,$e7,$e8,$e9,$ea,$eb,$ec,$ed
	dc.w $ee,$ef,$f0,$f1,$f2,$f3,$f4,$f5,$f6,$f7
	dc.w $f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff,$100,$101
	dc.w $102,$103,$104,$105,$106,$107,$108,$109,$10a,$10b
	dc.w $10c,$10d,$10e,$10f,$110,$111,$112,$113,$114,$115
	dc.w $116,$117,$118,$119,$11a,$11b,$11c,$11d,$11e,$11f
	dc.w $120,$121,$122,$123,$124,$125,$126,$127,$128,$129
	dc.w $12a,$12b,$12c,$12d,$12e,$12f,$130,$131,$132,$133
	dc.w $134,$135,$136,$137,$138,$139,$13a,$13b,$13c,$13d
	dc.w $13e,$13f,$140,$141,$142,$143,$144,$145,$146,$147
	dc.w $148,$149,$14a,$14b,$14c,$14d,$14e,$14f,$150,$151
	dc.w $152,$153,$154,$155,$156,$157,$158,$159,$15a,$15b
	dc.w $15c,$15d,$15e,$15f,$160,$161,$162,$163,$164,$165
	dc.w $166,$167,$168,$169,$16a,$16b,$16c,$16d,$16e,$16f
	dc.w $170,$171,$172,$173,$174,$175,$176,$177,$178,$179
	dc.w $17a,$17b,$17c,$17d,$17e,$17f,$180,$181,$182,$183
	dc.w $184,$185,$186,$187,$188,$189,$18a,$18b,$18c,$18d
	dc.w $18e,$18f,$190,$191,$192,$193,$194,$195,$196,$197
	dc.w $198,$199,$19a,$19b,$19c,$19d,$19e,$19f,$1a0
TABXMIRROR
	dc.w $1a0,$19f,$19e,$19d,$19c,$19b,$19a,$199,$198,$197
	dc.w $196,$195,$194,$193,$192,$191,$190,$18f,$18e,$18d
	dc.w $18c,$18b,$18a,$189,$188,$187,$186,$185,$184,$183
	dc.w $182,$181,$180,$17f,$17e,$17d,$17c,$17b,$17a,$179
	dc.w $178,$177,$176,$175,$174,$173,$172,$171,$170,$16f
	dc.w $16e,$16d,$16c,$16b,$16a,$169,$168,$167,$166,$165
	dc.w $164,$163,$162,$161,$160,$15f,$15e,$15d,$15c,$15b
	dc.w $15a,$159,$158,$157,$156,$155,$154,$153,$152,$151
	dc.w $150,$14f,$14e,$14d,$14c,$14b,$14a,$149,$148,$147
	dc.w $146,$145,$144,$143,$142,$141,$140,$13f,$13e,$13d
	dc.w $13c,$13b,$13a,$139,$138,$137,$136,$135,$134,$133
	dc.w $132,$131,$130,$12f,$12e,$12d,$12c,$12b,$12a,$129
	dc.w $128,$127,$126,$125,$124,$123,$122,$121,$120,$11f
	dc.w $11e,$11d,$11c,$11b,$11a,$119,$118,$117,$116,$115
	dc.w $114,$113,$112,$111,$110,$10f,$10e,$10d,$10c,$10b
	dc.w $10a,$109,$108,$107,$106,$105,$104,$103,$102,$101
	dc.w $100,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$f8,$f7
	dc.w $f6,$f5,$f4,$f3,$f2,$f1,$f0,$ef,$ee,$ed
	dc.w $ec,$eb,$ea,$e9,$e8,$e7,$e6,$e5,$e4,$e3
	dc.w $e2,$e1,$e0,$df,$de,$dd,$dc,$db,$da,$d9
	dc.w $d8,$d7,$d6,$d5,$d4,$d3,$d2,$d1,$d0,$cf
	dc.w $ce,$cd,$cc,$cb,$ca,$c9,$c8,$c7,$c6,$c5
	dc.w $c4,$c3,$c2,$c1,$c0,$bf,$be,$bd,$bc,$bb
	dc.w $ba,$b9,$b8,$b7,$b6,$b5,$b4,$b3,$b2,$b1
	dc.w $b0,$af,$ae,$ad,$ac,$ab,$aa,$a9,$a8,$a7
	dc.w $a6,$a5,$a4,$a3,$a2,$a1,$a0,$9f,$9e,$9d
	dc.w $9c,$9b,$9a,$99,$98,$97,$96,$95,$94,$93
	dc.w $92,$91,$90,$8f,$8e,$8d,$8c,$8b,$8a,$89
	dc.w $88,$87,$86,$85,$84,$83,$82,$81,$80
FINETABX

TABY
	dc.w $aa,$ac,$ae,$b0,$b1,$b3,$b5,$b7,$b8,$ba
	dc.w $bc,$be,$bf,$c1,$c3,$c4,$c6,$c7,$c9,$cb
	dc.w $cc,$ce,$cf,$d1,$d2,$d4,$d5,$d7,$d8,$da
	dc.w $db,$dd,$de,$df,$e1,$e2,$e3,$e4,$e5,$e7
	dc.w $e8,$e9,$ea,$eb,$ec,$ed,$ee,$ef,$f0,$f1
	dc.w $f1,$f2,$f3,$f4,$f4,$f5,$f6,$f6,$f7,$f7
	dc.w $f8,$f8,$f9,$f9,$f9,$fa,$fa,$fa,$fa,$fa
	dc.w $fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa
	dc.w $f9,$f9,$f9,$f8,$f8,$f7,$f7,$f6,$f6,$f5
	dc.w $f4,$f4,$f3,$f2,$f1,$f1,$f0,$ef,$ee,$ed
	dc.w $ec,$eb,$ea,$e9,$e8,$e7,$e6,$e4,$e3,$e2
	dc.w $e1,$df,$de,$dd,$db,$da,$d8,$d7,$d6,$d4
	dc.w $d3,$d1,$d0,$ce,$cc,$cb,$c9,$c8,$c6,$c4
	dc.w $c3,$c1,$bf,$be,$bc,$ba,$b9,$b7,$b5,$b3
	dc.w $b2,$b0,$ae,$ac,$ab,$a9,$a7,$a5,$a4,$a2
	dc.w $a0,$9e,$9d,$9b,$99,$98,$96,$94,$93,$91
	dc.w $8f,$8e,$8c,$8a,$89,$87,$86,$84,$83,$81
	dc.w $80,$7e,$7d,$7b,$7a,$79,$77,$76,$75,$73
	dc.w $72,$71,$70,$6e,$6d,$6c,$6b,$6a,$69,$68
	dc.w $67,$66,$65,$64,$64,$63,$62,$61,$61,$60
	dc.w $5f,$5f,$5e,$5e,$5d,$5d,$5c,$5c,$5c,$5b
	dc.w $5b,$5b,$5b,$5b,$5b,$5b,$5b,$5b,$5b,$5b
	dc.w $5b,$5b,$5b,$5b,$5c,$5c,$5c,$5d,$5d,$5e
	dc.w $5e,$5f,$5f,$60,$61,$61,$62,$63,$63,$64
	dc.w $65,$66,$67,$68,$69,$6a,$6b,$6c,$6d,$6e
	dc.w $6f,$71,$72,$73,$74,$76,$77,$78,$7a,$7b
	dc.w $7c,$7e,$7f,$81,$82,$84,$85,$87,$88,$8a
	dc.w $8c,$8d,$8f,$91,$92,$94,$96,$97,$99,$9b
	dc.w $9c,$9e,$a0,$a2,$a3,$a5,$a7,$a9,$aa

TABYMIRROR
	dc.w $aa,$a9,$a7,$a5,$a3,$a2,$a0,$9e,$9c,$9b
	dc.w $99,$97,$96,$94,$92,$91,$8f,$8d,$8c,$8a
	dc.w $88,$87,$85,$84,$82,$81,$7f,$7e,$7c,$7b
	dc.w $7a,$78,$77,$76,$74,$73,$72,$71,$6f,$6e
	dc.w $6d,$6c,$6b,$6a,$69,$68,$67,$66,$65,$64
	dc.w $63,$63,$62,$61,$61,$60,$5f,$5f,$5e,$5e
	dc.w $5d,$5d,$5c,$5c,$5c,$5b,$5b,$5b,$5b,$5b
	dc.w $5b,$5b,$5b,$5b,$5b,$5b,$5b,$5b,$5b,$5b
	dc.w $5c,$5c,$5c,$5d,$5d,$5e,$5e,$5f,$5f,$60
	dc.w $61,$61,$62,$63,$64,$64,$65,$66,$67,$68
	dc.w $69,$6a,$6b,$6c,$6d,$6e,$70,$71,$72,$73
	dc.w $75,$76,$77,$79,$7a,$7b,$7d,$7e,$80,$81
	dc.w $83,$84,$86,$87,$89,$8a,$8c,$8e,$8f,$91
	dc.w $93,$94,$96,$98,$99,$9b,$9d,$9e,$a0,$a2
	dc.w $a4,$a5,$a7,$a9,$ab,$ac,$ae,$b0,$b2,$b3
	dc.w $b5,$b7,$b9,$ba,$bc,$be,$bf,$c1,$c3,$c4
	dc.w $c6,$c8,$c9,$cb,$cc,$ce,$d0,$d1,$d3,$d4
	dc.w $d6,$d7,$d8,$da,$db,$dd,$de,$df,$e1,$e2
	dc.w $e3,$e4,$e6,$e7,$e8,$e9,$ea,$eb,$ec,$ed
	dc.w $ee,$ef,$f0,$f1,$f1,$f2,$f3,$f4,$f4,$f5
	dc.w $f6,$f6,$f7,$f7,$f8,$f8,$f9,$f9,$f9,$fa
	dc.w $fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa
	dc.w $fa,$fa,$fa,$fa,$f9,$f9,$f9,$f8,$f8,$f7
	dc.w $f7,$f6,$f6,$f5,$f4,$f4,$f3,$f2,$f1,$f1
	dc.w $f0,$ef,$ee,$ed,$ec,$eb,$ea,$e9,$e8,$e7
	dc.w $e5,$e4,$e3,$e2,$e1,$df,$de,$dd,$db,$da
	dc.w $d8,$d7,$d5,$d4,$d2,$d1,$cf,$ce,$cc,$cb
	dc.w $c9,$c7,$c6,$c4,$c3,$c1,$bf,$be,$bc,$ba
	dc.w $b8,$b7,$b5,$b3,$b1,$b0,$ae,$ac,$aa
FINETABY

; ROUTINE TO MOVE PLAYFIELD 2 UP AND DOWN	
MoveBanner

	; Change only pointers relative of PLAYFIELD2 (even ones)
	lea	BPLPOINTERS2,a1
	move.w	2(a1),d0
	swap d0
	move.w	6(a1),d0

	lea	BPLPOINTERS2_1,a1
	move.w	2(a1),d1
	swap d1
	move.w	6(a1),d1

	lea	BPLPOINTERS2_2,a2
	move.w	2(a2),d2
	swap d2
	move.w	6(a2),d2

	tst.b	SuGiu
	beq.w	VAIGIU
	cmp.l	#PIC2_1-(40*90),d0
	beq.s MettiGiu
	sub.l	#40,d0
	sub.l	#40,d1
	sub.l	#40,d2
	bra.w	Finito

MettiGiu
	; Change the skull jaw pasting data with the blitter - the jaw will be opened	
	BLTCPY #JAWLOPEN,#LEFTSKULLJAW,BLTWAIT12,#(64*1)+56
	BLTCPY #JAWROPEN,#RIGHTSKULLJAW,BLTWAIT10,#(64*1)+56

	; SuGiu flag is now 0
	clr.b	SuGiu
	bra.w Finito
	
VAIGIU
	cmpi.l	#PIC2_1+(40*0),d0
	beq.s MettiSu
	add.l #40,d0
	add.l #40,d1
	add.l #40,d2
	bra.w Finito
	
MettiSu
	; Change the skull jaw pasting data with the blitter - the jaw will be closed
	BLTCPY #JAWLCLOSED,#LEFTSKULLJAW,BLTWAIT11,#(64*1)+56
	BLTCPY #JAWRCLOSED,#RIGHTSKULLJAW,BLTWAIT9,#(64*1)+56
	
	;move.w	#$fff,COLORS+2 ; Uncomment to enable background flash
	
	addq.w #1,BannerCont
	move.b #$ff,SuGiu
	rts
	
Finito
	lea	BPLPOINTERS2,a1
	move.w	d0,6(a1)
	swap d0
	move.w	d0,2(a1)

	lea	BPLPOINTERS2_1,a2
	move.w	d1,6(a2)
	swap d1
	move.w	d1,2(a2)

	lea	BPLPOINTERS2_2,a3
	move.w	d2,6(a3)
	swap d2
	move.w	d2,2(a3)
	rts
	
; Flag - 0 = the banner is going down, $ff is going up	
SuGiu
	dc.b 0,0
BannerCont
	dc.b 0,0		
	
; Some variables
	
GfxBase	dc.l 0 ; Holds the gfx base address
OldCop	dc.l 0 ; Holds the old copper address
GfxName	dc.b 'graphics.library',0,0 ; Name of the graphics library

	include "music_ptr.s" ; Code for playing a mod file pointer version




;--------------------------------------------------------------------
; --------- COPPERLIST START ----------------------------------------
;--------------------------------------------------------------------
	SECTION GRAPHIC,DATA_C
	
COPPERLIST	
SpritePointers	dc.w $120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000
		dc.w $12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
		dc.w $134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
		dc.w $13e,$0000
		
		dc.w	$8e,$2c81
		dc.w	$90,$2cc1
		dc.w	$92,$0038
		dc.w	$94,$00d0
		dc.w	$102,0
		dc.w	$104
		dc.b	$00
BPLCON2		dc.b	$09 	; replace $0009 here with $0039 to print the banner OVER the image (exploiting a well known bug
				   	; that lets you print color 16 where in the fifth bitplane there's a 1 - works only on ocs/ecs (A500/A600)
		dc.w	$108,0
		dc.w	$10a,0
		
		dc.w $100,%0110011000000000	; bit 10 on = dual playfield
						;  6 planes = 8 colors per playfield 

		dc.w $106,$c00			; Very important, set BPLCON3 to c00
						; PF2OFx bits must be equal to 011, otherwise
						; playfield 2 will use the same color palette
						; of playfield 1 on AGA machines	

		dc.w $01fc,$0000		; vampire fix

; Bitplane 1 pointers
BPLPOINTERS1
	dc.w $e0,0,$e2,0	; BPLPT1
BPLPOINTERS1_1
	dc.w $e8,0,$ea,0	; BPLPT3
BPLPOINTERS1_2
	dc.w $f0,0,$f2,0	; BPLPT5


; Bitplane 2 pointers
BPLPOINTERS2
	dc.w $e4,0,$e6,0	; BPLPT2
BPLPOINTERS2_1
	dc.w $ec,0,$ee,0	; BPLPT4
BPLPOINTERS2_2
	dc.w $f4,0,$f6,0	; BPLPT6
		
COLORS	
		; Colors for bitplane 1
		dc.w    $180,$622    ; color0 (transparency for bitplane 1)
		dc.w    $182,$000    ; color1
		dc.w    $184,$000    ; color2
		dc.w    $186,$000    ; color3
		dc.w    $188,$000    ; color4
		dc.w    $18a,$000    ; color5
		dc.w    $18c,$000    ; color6
		dc.w    $18e,$000    ; color7

		; Colors for bitplane 2
COLORSBITPLANE2	
		dc.w    $192,$0    ; color9
		dc.w    $194,$0    ; color10
		dc.w    $196,$0    ; color11
		dc.w    $198,$0    ; color12
		dc.w    $19a,$0    ; color13
		dc.w    $19c,$0    ; color14
		dc.w    $19e,$0    ; color15

		;sprite colors;
		dc.w    $1a2,$333    ; skull color 1
		dc.w    $1a4,$fff    ; skull color 2
		dc.w    $1a6,$000    ; skull color 3

		dc.w    $1a8,$070    ; color4 - unused (useful for attached sprites in the future)
		dc.w    $1aa,$faa    ; color21 - starfield color 0 - color of the star
		dc.w    $1ac,$0b0    ; color6 - unused (useful for attached sprites in the future)
		dc.w    $1ae,$f00    ; color7 - unused (useful for attached sprites in the future)
		dc.w    $1b0,$444    ; color8 - unused (useful for attached sprites in the future)
		
		; unused for now
		dc.w    $1b2,$e95    ; color25
		dc.w    $1b4,$d84    ; color26
		dc.w    $1b6,$686    ; color27
		dc.w    $1b8,$4a7    ; color28
		dc.w    $1ba,$175    ; color29
		dc.w    $1bc,$333    ; color30
		dc.w    $1be,$444    ; color31
		
		; text gradient
		dc.w	$3107,$FFFE
TXTGRADCOL1
		dc.w    $182,$009
		dc.w	$3607,$FFFE
TXTGRADCOL2
		dc.w    $182,$06f
		dc.w	$3b07,$FFFE
TXTGRADCOL3
		dc.w    $182,$0af
		
		dc.w	$4a07,$FFFE  ; Wait to differentiate color of the text
TXTGRADCOL4		
		dc.w    $182,$000    ; color1
		
; CHECKBOARD START
CHKBOARD_COPPERLIST 
	dc.w 	$FFFF,$FFFE
	dc.w    $a903,$fffe,$1a0,$0ff0
	dc.w    $190,$0000,$192,$0000,$194,$0000,$196,$0000,$198,$0000
        dc.w    $19A,$0222,$19C,$0E0E,$19E,$0505

	dc.w    $Aa01,$ff00     ; skip

CLcol   dc.w    $198,$0
CLcol2  dc.w    $19C,$0

CLChecker
	dc.w	$ab01,$fffe,$19c,$000f,$198,0000
	dc.w	$ac01,$fffe,$198,$000e,$19c,0000
	dc.w	$ad01,$fffe,$19c,$000f,$198,0000
	dc.w	$ae01,$fffe,$198,$000e,$19c,0000
	dc.w	$b001,$fffe,$19c,$000f,$198,0000
	dc.w	$b101,$fffe,$198,$000e,$19c,0000
	dc.w	$b301,$fffe,$19c,$000f,$198,0000
	dc.w	$b501,$fffe,$198,$000e,$19c,0000
	dc.w	$b701,$fffe,$19c,$000f,$198,0000
	dc.w	$b901,$fffe,$198,$000e,$19c,0000
	dc.w	$bb01,$fffe,$19c,$000f,$198,0000
	dc.w	$be01,$fffe,$198,$000e,$19c,0000
	dc.w	$c101,$fffe,$19c,$000f,$198,0000
	dc.w	$c401,$fffe,$198,$000e,$19c,0000
	dc.w	$c801,$fffe,$19c,$000d,$198,0000
	dc.w	$cb01,$fffe,$198,$000c,$19c,0000
	dc.w	$d001,$fffe,$19c,$000b,$198,0000
	dc.w	$d501,$fffe,$198,$000a,$19c,0000
	dc.w	$db01,$fffe,$19c,$0009,$198,0000
	dc.w	$e101,$fffe,$198,$0008,$19c,0000
	dc.w	$e901,$fffe,$19c,$0007,$198,0000

	dc.w	$f201,$fffe,$198,6,$19a,3,$19e,0,$19c,0
	dc.w	$fd01,$fffe,$19c,5,$19e,3,$19a,0,$198,0
	dc.w	$ffdf,$fffe		; pal
	dc.w	$0a01,$fffe,$19a,5,$198,3,$19c,0,$19e,0
	dc.w	$1b01,$fffe,$19a,0,$198,0,$19c,0,$19e,0

	dc.w	$108,0,$180,0,$10a,0
	dc.l	-2
	dcb.l	112,$ffffffff	
; CHECKBOARD END

; ------------------------------------------------------------------
;  ---- COPPERLIST END ---------------------------------------------
; ------------------------------------------------------------------

;
; Image of the left skull jaw opened (sprite 0)
JAWLOPEN
	dc.w $034A,$02B5 ; line 1
	dc.w $0288,$0377 ; line 2
	dc.w $0358,$00A7 ; line 3
	dc.w $06A7,$0558 ; line 4
	dc.w $0765,$049A ; line 5
	dc.w $06E7,$0118 ; line 6
	dc.w $05E5,$025B ; line 7
	dc.w $06E6,$015A ; line 8
	dc.w $0DE4,$065C ; line 9
	dc.w $1BE4,$079C ; line 10
	dc.w $1074,$0C68 ; line 11
	dc.w $1014,$0C0C ; line 12
	dc.w $001E,$0E12 ; line 13
	dc.w $080E,$0606 ; line 14
	dc.w $010E,$060E ; line 15
	dc.w $0536,$0200 ; line 16
	dc.w $06EF,$0151 ; line 17
	dc.w $056D,$02D2 ; line 18
	dc.w $0667,$0198 ; line 19
	dc.w $0325,$00DA ; line 20
	dc.w $02B7,$0148 ; line 21
	dc.w $0359,$00A6 ; line 22
	dc.w $0288,$0177 ; line 23
	dc.w $014A,$00B5 ; line 24
	dc.w $0040,$003F ; line 25
	dc.w $0010,$000F ; line 26
	dc.w $0007,$0000 ; line 27
	dc.w $0000,$0000 ; line 28

; Image of the left skull jaw closed (sprite 0)
JAWLCLOSED
	dc.w $074A,$02B5 ; line 1
	dc.w $0E88,$0377 ; line 2
	dc.w $1B58,$04A7 ; line 3
	dc.w $16A7,$0D58 ; line 4
	dc.w $1765,$0C9A ; line 5
	dc.w $06E7,$0918 ; line 6
	dc.w $0DE5,$025B ; line 7
	dc.w $06E6,$015A ; line 8
	dc.w $05E6,$065C ; line 9
	dc.w $07E7,$039D ; line 10
	dc.w $0575,$02EA ; line 11
	dc.w $0677,$018C ; line 12
	dc.w $033D,$00D2 ; line 13
	dc.w $02BF,$0144 ; line 14
	dc.w $035D,$00AE ; line 15
	dc.w $0288,$0177 ; line 16
	dc.w $014A,$00B5 ; line 17
	dc.w $0040,$003F ; line 18
	dc.w $0010,$000F ; line 19
	dc.w $0007,$0000 ; line 20
	dc.w $0000,$0000 ; line 21
	dc.w $0000,$0000 ; line 22
	dc.w $0000,$0000 ; line 23
	dc.w $0000,$0000 ; line 24
	dc.w $0000,$0000 ; line 25
	dc.w $0000,$0000 ; line 26
	dc.w $0000,$0000 ; line 27
	dc.w $0000,$0000 ; line 28    

; Image of the right skull jaw closed (sprite 1) - sprite side by side
JAWRCLOSED      
	dc.w $50E0,$AF40 ; line 1
	dc.w $1070,$EF80 ; line 2
	dc.w $9A58,$65A0 ; line 3
	dc.w $E568,$1AB0 ; line 4
	dc.w $A668,$59B0 ; line 5
	dc.w $E720,$18D0 ; line 6
	dc.w $A730,$DAC0 ; line 7
	dc.w $6720,$5AC0 ; line 8
	dc.w $67A0,$3A60 ; line 9
	dc.w $E7E0,$B9C0 ; line 10
	dc.w $AEA0,$D740 ; line 11
	dc.w $EE60,$3180 ; line 12
	dc.w $BCC0,$4B00 ; line 13
	dc.w $FD40,$2280 ; line 14
	dc.w $3AC0,$F500 ; line 15
	dc.w $1140,$EE80 ; line 16
	dc.w $5280,$AD00 ; line 17
	dc.w $0200,$FC00 ; line 18
	dc.w $0800,$F000 ; line 19
	dc.w $E000,$0000 ; line 20
	dc.w $0000,$0000 ; line 21
	dc.w $0000,$0000 ; line 22
	dc.w $0000,$0000 ; line 23
	dc.w $0000,$0000 ; line 24
	dc.w $0000,$0000 ; line 25
	dc.w $0000,$0000 ; line 26
	dc.w $0000,$0000 ; line 27
	dc.w $0000,$0000 ; line 28

; Image of the right skull jaw opened (sprite 1) - sprite side by side
JAWROPEN
	dc.w $50C0,$AF40 ; line 1
	dc.w $1040,$EF80 ; line 2
	dc.w $9A40,$6580 ; line 3
	dc.w $E560,$1AA0 ; line 4
	dc.w $A660,$59A0 ; line 5
	dc.w $E720,$18C0 ; line 6
	dc.w $A720,$DAC0 ; line 7
	dc.w $6720,$5AC0 ; line 8
	dc.w $27B0,$3A60 ; line 9
	dc.w $27D8,$39E0 ; line 10
	dc.w $2E08,$1630 ; line 11
	dc.w $2808,$3030 ; line 12
	dc.w $7800,$4870 ; line 13
	dc.w $7010,$6060 ; line 14
	dc.w $7080,$7060 ; line 15
	dc.w $6CA0,$0040 ; line 16
	dc.w $F760,$8A80 ; line 17
	dc.w $B6A0,$CB40 ; line 18
	dc.w $E660,$1980 ; line 19
	dc.w $A4C0,$5B00 ; line 20
	dc.w $ED40,$1280 ; line 21
	dc.w $1AC0,$E500 ; line 22
	dc.w $1140,$EE80 ; line 23
	dc.w $5280,$AD00 ; line 24
	dc.w $0200,$FC00 ; line 25
	dc.w $0800,$F000 ; line 26
	dc.w $E000,$0000 ; line 27
	dc.w $0000,$0000 ; line 28

; Left Image of the skull (SPRITE0)
LEFTSKULL
LEFTSKULLVSTART	dc.b $30
LEFTSKULLHSTART	dc.b $90
LEFTSKULLVSTOP	dc.b $62,$00
		dc.w $007F,$0000 ; line 1
		dc.w $01E0,$001F ; line 2
		dc.w $0758,$00A7 ; line 3
		dc.w $0E84,$017B ; line 4
		dc.w $1D02,$02FD ; line 5
		dc.w $3A03,$05FC ; line 6
		dc.w $3501,$0AFE ; line 7
		dc.w $6A81,$157E ; line 8
		dc.w $5F01,$20FE ; line 9
		dc.w $ED01,$12FE ; line 10
		dc.w $C7C1,$383E ; line 11
		dc.w $A7B2,$5B4D ; line 12
		dc.w $CFEC,$33F3 ; line 13
		dc.w $AFFE,$57FD ; line 14
LEFTSKULLEYES1	dc.w $CF7E,$37FF ; line 15
LEFTSKULLEYES2	dc.w $AF3E,$57DF ; line 16
		dc.w $CFF8,$31E7 ; line 17
		dc.w $E3F0,$1C0F ; line 18
		dc.w $5401,$2BFF ; line 19
		dc.w $3865,$079E ; line 20
		dc.w $15CD,$0A33 ; line 21
		dc.w $1F4D,$10B3 ; line 22
		dc.w $018D,$0072 ; line 23
LEFTSKULLJAW	dc.w $034A,$02B5 ; line 24
		dc.w $0288,$0377 ; line 25
		dc.w $0358,$00A7 ; line 26
		dc.w $06A7,$0558 ; line 27
		dc.w $0765,$049A ; line 28
		dc.w $06E7,$0118 ; line 29
		dc.w $05E5,$025B ; line 30
		dc.w $06E6,$015A ; line 31
		dc.w $05E4,$065C ; line 32
		dc.w $03E4,$039C ; line 33
		dc.w $0074,$0068 ; line 34
		dc.w $0014,$000C ; line 35
		dc.w $001C,$0010 ; line 36
		dc.w $000C,$0004 ; line 37
		dc.w $000C,$000C ; line 38
		
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,40000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w 0,0
		
RIGHTSKULL
RIGHTSKULLVSTART	dc.b $30
RIGHTSKULLHSTART	dc.b $90
RIGHTSKULLVSTOP	dc.b $64,$00
		dc.w $FF00,$0000 ; line 1
		dc.w $0180,$FE00 ; line 2
		dc.w $A0E0,$5F00 ; line 3
		dc.w $4030,$BFC0 ; line 4
		dc.w $8018,$7FE0 ; line 5
		dc.w $800C,$7FF0 ; line 6
		dc.w $0004,$FFF8 ; line 7
		dc.w $0006,$FFF8 ; line 8
		dc.w $0012,$FFEC ; line 9
		dc.w $0033,$FFCC ; line 10
		dc.w $01E1,$FE1E ; line 11
		dc.w $0EE1,$F1DE ; line 12
		dc.w $37F1,$CFCE ; line 13
		dc.w $7FF1,$BFEE ; line 14
RIGHTSKULLEYES1	dc.w $7BF1,$FFEE ; line 15
RIGHTSKULLEYES2	dc.w $79F1,$FEEE ; line 16
		dc.w $1FF1,$E78E ; line 17
		dc.w $0FC3,$F03C ; line 18
		dc.w $8002,$FFFC ; line 19
		dc.w $A60C,$79F0 ; line 20
		dc.w $B388,$CC70 ; line 21
		dc.w $B0F8,$4F10 ; line 22
		dc.w $B080,$CF00 ; line 23
RIGHTSKULLJAW	dc.w $50C0,$AF40 ; line 24
		dc.w $1040,$EF80 ; line 25
		dc.w $9A40,$6580 ; line 26
		dc.w $E560,$1AA0 ; line 27
		dc.w $A660,$59A0 ; line 28
		dc.w $E720,$18C0 ; line 29
		dc.w $A720,$DAC0 ; line 30
		dc.w $6720,$5AC0 ; line 31
		dc.w $27A0,$3A60 ; line 32
		dc.w $27C0,$39C0 ; line 33
		dc.w $2E00,$1600 ; line 34
		dc.w $2800,$3000 ; line 35
		dc.w $3800,$0800 ; line 36
		dc.w $3000,$2000 ; line 37
		dc.w $3000,$3000 ; line 38
		
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000
		dc.w $0000,$0000

		
		dc.w 0,0

; Recycled sprite for the starfield		
STARFIELDSPRITE
	dc.w    $307A,$3100,$1000,$0000,$3220,$3300,$1000,$0000
	dc.w    $34C0,$3500,$1000,$0000,$3650,$3700,$1000,$0000
	dc.w    $3842,$3900,$1000,$0000,$3A6D,$3B00,$1000,$0000
	dc.w    $3CA2,$3D00,$1000,$0000,$3E9C,$3F00,$1000,$0000
	dc.w    $40DA,$4100,$1000,$0000,$4243,$4300,$1000,$0000
	dc.w    $445A,$4500,$1000,$0000,$4615,$4700,$1000,$0000
	dc.w    $4845,$4900,$1000,$0000,$4A68,$4B00,$1000,$0000
	dc.w    $4CB8,$4D00,$1000,$0000,$4EB4,$4F00,$1000,$0000
	dc.w    $5082,$5100,$1000,$0000,$5292,$5300,$1000,$0000
	dc.w    $54D0,$5500,$1000,$0000,$56D3,$5700,$1000,$0000
	dc.w    $58F0,$5900,$1000,$0000,$5A6A,$5B00,$1000,$0000
	dc.w    $5CA5,$5D00,$1000,$0000,$5E46,$5F00,$1000,$0000
	dc.w    $606A,$6100,$1000,$0000,$62A0,$6300,$1000,$0000
	dc.w    $64D7,$6500,$1000,$0000,$667C,$6700,$1000,$0000
	dc.w    $68C4,$6900,$1000,$0000,$6AC0,$6B00,$1000,$0000
	dc.w    $6C4A,$6D00,$1000,$0000,$6EDA,$6F00,$1000,$0000
	dc.w    $70D7,$7100,$1000,$0000,$7243,$7300,$1000,$0000
	dc.w    $74A2,$7500,$1000,$0000,$7699,$7700,$1000,$0000
	dc.w    $7872,$7900,$1000,$0000,$7A77,$7B00,$1000,$0000
	dc.w    $7CC2,$7D00,$1000,$0000,$7E56,$7F00,$1000,$0000
	dc.w    $805A,$8100,$1000,$0000,$82CC,$8300,$1000,$0000
	dc.w    $848F,$8500,$1000,$0000,$8688,$8700,$1000,$0000
	dc.w    $88B9,$8900,$1000,$0000,$8AAF,$8B00,$1000,$0000
	dc.w    $8C48,$8D00,$1000,$0000,$8E68,$8F00,$1000,$0000
	dc.w    $90DF,$9100,$1000,$0000,$924F,$9300,$1000,$0000
	dc.w    $9424,$9500,$1000,$0000,$96D7,$9700,$1000,$0000
	dc.w    $9859,$9900,$1000,$0000,$9A4F,$9B00,$1000,$0000
	dc.w    $9C4A,$9D00,$1000,$0000,$9E5C,$9F00,$1000,$0000
	dc.w    $A046,$A100,$1000,$0000,$A2A6,$A300,$1000,$0000
	dc.w    $A423,$A500,$1000,$0000,$A6FA,$A700,$1000,$0000
	dc.w    $A86C,$A900,$1000,$0000,$AA44,$AB00,$1000,$0000
	dc.w    $AC88,$AD00,$1000,$0000,$AE9A,$AF00,$1000,$0000
	dc.w    $B06C,$B100,$1000,$0000,$B2D4,$B300,$1000,$0000
	dc.w    $B42A,$B500,$1000,$0000,$B636,$B700,$1000,$0000
	dc.w    $B875,$B900,$1000,$0000,$BA89,$BB00,$1000,$0000
	dc.w    $BC45,$BD00,$1000,$0000,$BE24,$BF00,$1000,$0000
	dc.w    $C0A3,$C100,$1000,$0000,$C29D,$C300,$1000,$0000		
	dc.w    $C43F,$C500,$1000,$0000,$C634,$C700,$1000,$0000		
	dc.w    $C87C,$C900,$1000,$0000,$CA1D,$CB00,$1000,$0000		
	dc.w    $CC6B,$CD00,$1000,$0000,$CEAC,$CF00,$1000,$0000
	dc.w    $D0CF,$D100,$1000,$0000,$D2FF,$D300,$1000,$0000		
	dc.w    $D4A5,$D500,$1000,$0000,$D6D6,$D700,$1000,$0000		
	dc.w    $D8EF,$D900,$1000,$0000,$DAE1,$DB00,$1000,$0000		
	dc.w    $DCD9,$DD00,$1000,$0000,$DEA6,$DF00,$1000,$0000		
	dc.w    $E055,$E100,$1000,$0000,$E237,$E300,$1000,$0000		
	dc.w    $E47D,$E500,$1000,$0000,$E62E,$E700,$1000,$0000
	dc.w    $E8AF,$E900,$1000,$0000,$EA46,$EB00,$1000,$0000
	dc.w	$EC65,$ED00,$1000,$0000,$EE87,$EF00,$1000,$0000
	dc.w	$F0D4,$F100,$1000,$0000,$F2F5,$F300,$1000,$0000
	dc.w	$F4FA,$F500,$1000,$0000,$F62C,$F700,$1000,$0000
	dc.w	$F84D,$F900,$1000,$0000,$FAAC,$FB00,$1000,$0000
	dc.w	$FCB2,$FD00,$1000,$0000,$FE9A,$FF00,$1000,$0000
	dc.w	$009A,$0106,$1000,$0000,$02DF,$0306,$1000,$0000
	dc.w	$0446,$0506,$1000,$0000,$0688,$0706,$1000,$0000
	dc.w	$0899,$0906,$1000,$0000,$0ADD,$0B06,$1000,$0000
	dc.w	$0CEE,$0D06,$1000,$0000,$0EFF,$0F06,$1000,$0000
	dc.w	$10CD,$1106,$1000,$0000,$1267,$1306,$1000,$0000
	dc.w	$1443,$1506,$1000,$0000,$1664,$1706,$1000,$0000
	dc.w	$1823,$1906,$1000,$0000,$1A6D,$1B06,$1000,$0000
	dc.w	$1C4F,$1D06,$1000,$0000,$1E5F,$1F06,$1000,$0000
	dc.w	$2055,$2106,$1000,$0000,$2267,$2306,$1000,$0000
	dc.w	$2445,$2506,$1000,$0000,$2623,$2706,$1000,$0000
	dc.w	$2834,$2906,$1000,$0000,$2AF0,$2B06,$1000,$0000

STARFIELDSPRITEEND
	dc.w	$0000,$0000


; Image of the crow man
PIC	incbin	"crow_img_8.raw"
; Image of the banner
PIC2_1_BEFORE  dcb.b 40*256,$00
;PIC2
PIC2_1	incbin "crow2_8col_3_1.raw"
PIC2_1_AFTER  dcb.b 40*256,$00

PIC2_2_BEFORE  dcb.b 40*256,$00
PIC2_2	incbin "crow2_8col_3_2.raw"
PIC2_2_AFTER  dcb.b 40*256,$00

PIC2_3_BEFORE  dcb.b 40*256,$00
PIC2_3	incbin "crow2_8col_3_3.raw""
PIC2_3_AFTER  dcb.b 40*256,$00

; CHECKBOARD BITPLANES
CHECKER_RAW_1
	dcb.b 40*256,$00
CHECKER_RAW_2
	incbin "check.raw"
CHECKER_RAW_3
	dcb.b 40*128,$00
	dcb.b 40*128,$ff

;Mod files
mt_data			dc.l mt_data1
mt_data1		incbin "proud2bneanderthal.mod"
mt_data2		incbin "forden.mod"

FONT	incbin "fonts.fnt"
CORVO5
	incbin corvo9.raw

; SCREEN BUFFERS
; Buffer UP
BUFFER_UP
    dcb.b _SCREEN_HBYTES*(_FONT_HPADDER+_FONT_LPADDER+_FONT_VPIXELS),$00

; First screen
SCREEN_1
    dcb.b _SCREEN_HBYTES*(_SCREEN_VRES-0),$00

; Second screen
SCREEN_2
    dcb.b _SCREEN_HBYTES*_SCREEN_VRES,$00
    
    dcb.b _SCREEN_HBYTES*_SCREEN_VRES,$00
BALLBITPLANE_1
    dcb.b _SCREEN_HBYTES*_SCREEN_VRES,$00
BALLBITPLANE_2
    dcb.b _SCREEN_HBYTES*_SCREEN_VRES,$00
BALLBITPLANE_3
    dcb.b _SCREEN_HBYTES*_SCREEN_VRES,$00
SCREEN_3

; Buffer DOWN
BUFFER_DOWN
    dcb.b _SCREEN_HBYTES*(_FONT_HPADDER+_FONT_LPADDER+_FONT_VPIXELS),$00
    
GREETINGS_SCREEN2
	dcb.b 40*256,$00
GREETINGS_SCREEN3
	dcb.b 40*256,$00
    
; WORDS_BUFFERS (each row 20 char)
    dc.b '...AND THE RAVEN,   '
WSTART_MSG
    dc.b '   NEVER FLITTING,  '
    dc.b '  STILL IS SITTING  '
    dc.b '   ON THE PALLID    '
    dc.b '   BUST OF PALLAS   '
    dc.b '     JUST ABOVE     '
    dc.b '  MY CHAMBER DOOR   '
    dc.b '                    '
    dc.b '    AND HIS EYES    '
    dc.b 'HAVE ALL THE SEEMING'
    dc.b '    OF A DAEMON     '
    dc.b 'THAT IS DREAMING... '
WSTART
    dc.b '                    '
    dc.b '     THE CROWS      '
    dc.b '     AMIGADEMO      '
    dc.b '                    '
    dc.b ' RELEASED IN 2018   '
    dc.b ' AND PRODUCED ONLY  '
    dc.b ' WITH TRUE AMIGAS   '
    dc.b '                    '
    dc.b 'ASM CODE: OZZYBOSHI '
    dc.b 'GRAPHICS: DR.PROCTON'
    dc.b 'MODS:FRATER SINISTER'
    dc.b '                    '
    dc.b '    IN MEMORY OF    '
    dc.b '   FABIO BOVELACCI  '
    dc.b '1/3/1976 - 7/9/2014 '
    dc.b '       R.I.P.       '
    dc.b '                    '
    dc.b '                    '
    dc.b 'THX TO AMIGAPAGE.IT '
    dc.b 'AND ITS MEMBERS FOR '
    dc.b 'THEIR SUPPORT:      '
    dc.b '                    '
    dc.b '            ALEGHID '
    dc.b '          AMIWELL78 '
    dc.b '            DANYPPC '
    dc.b '             DIVINA '
    dc.b '            FAROK68 '
    dc.b '              MAK73 '
    dc.b '                MCK '   
    dc.b '             RAMJAM '
    dc.b '         SCHIUMACAL '
    dc.b '              SEIYA '
    dc.b '          SUKKOPERA '
    dc.b '            TRANTOR '
    dc.b '                Z3K '
    dc.b '                    '
    dc.b ' SPECIAL THANKS TO: '
    dc.b '              CGUGL '
    dc.b '             CIP060 '
    dc.b '     MISANTHROPIXEL '
    dc.b '     THE DARK CODER '
    dc.b '                    '
    dc.b ' SOURCE CODE AT:    '
    dc.b 'GITHUB.COM/OZZYBOSHI'
    dc.b '                    '
    dc.b 'DEVELOPEMENT THREAD '
    dc.b 'AT AMIGAPAGE.IT     '
    dc.b '                    '
    dc.b 'THANKS FOR WATCHING '
    
ballpic	incbin "ballbrush.raw"
ballpicmsk incbin "ballbrush.msk"


	end
