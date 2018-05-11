	include exec/types.i
	include exec/libraries.i
	INCLUDE "exec/exec_lib.i"
    	INCLUDE "graphics/graphics_lib.i"
    	
	SECTION MAINCODE,CODE

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
	
CHECKMOUSEDX MACRO
	btst #2,$dff016
	bne.s \1
	bsr.s \2
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

	MOVE.L	#PIC2_1,d0	; point playfield 2
	LEA	BPLPOINTERS2,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	addq.w	#8,a1

	MOVE.L	#PIC2_2,d0	; point playfield 4
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	addq.w	#8,a1

	MOVE.L	#PIC2_3,d0	; point playfield 6
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0

	; Start Sprite init (the skull)
	; Sprite 0 init
	MOVE.L	#MYSPRITE2,d0		
	LEA	SpritePointers,a1	; SpritePointers is in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	; Sprite 1 init (right side of sprite 0)	
	MOVE.L	#MYSPRITE3,d0		
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
	move.w #$83a0,$dff096

	bsr.w   mt_init ; init music
		
mouse	
	WAITVEND mouse; Wait for 255th row
	
	bsr.w MoveSprite ; Move the skull sprite on the X axis
	bsr.w MoveSpriteY ; Move the skull sprite on the Y Axis	
	bsr.w MuoviCopper ; Move the background banner up and down
	bsr.w mt_music
	
vwait	WAITVEND vwait

	; wait for left mouse click
lclick	btst #6,$bfe001
	bne mouse

	bsr.w   mt_end ; end music
	
	move.l OldCop,$dff080
	move.w d0,$dff088
	DISOWNBLITTER
	CLOSEGRAPHICS
	ENABLE
	clr.l d0
	rts

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
		MOVE.b	d0,VSTART2	; copy Y position at VSTART
		move.b	d0,VSTART3	; Same thing for sprite1 (both same height)
		btst.l	#8,d0		; if position grater than  255 ($FF)
		beq.s	NonVSTARTSET	; if not clear bit 2
		bset.b	#2,MYSPRITE2+3	; Set VSTART 8th bit
		bset.b  #2,MYSPRITE3+3  ; Same for sprite 1
		bra.s	ToVSTOP		; Force Jump to ToVstop routine

NonVSTARTSET
		bclr.b	#2,MYSPRITE2+3  ; bit clearing
		bclr.b  #2,MYSPRITE3+3  ; bit clearing

ToVSTOP
		ADD.w	#26,D0		; Add height of the sprite to
					; calculate vstop, in this case
					; the skull is 26 pixel high
					
		move.b	d0,VSTOP2	; VSTOP setting on both sprites
		move.b  d0,VSTOP3
					; Like vstart we must tell if Y>255
					; but in this case we set/clear bit 1
					; of the sprite control byte 
		btst.l	#8,d0
		beq.s	NonVSTOPSET
		bset.b	#1,MYSPRITE2+3
		bset.b  #1,MYSPRITE3+3
		bra.w	VstopFIN
NonVSTOPSET
		bclr.b	#1,MYSPRITE2+3
		bclr.b  #1,MYSPRITE3+3

VstopFIN
		rts

TABYPOINT
		dc.l	TABY-2

MoveSprite
		ADDQ.L	#2,TABXPOINT
		MOVE.L	TABXPOINT(PC),A0
		CMP.L	#FINETABX-2,A0
		BNE.S	NOBSTARTX
		MOVE.L	#TABX-2,TABXPOINT


; Routine to move the sprite along the X AXIS
NOBSTARTX
	moveq	#0,d0
	move.w  (a0),d0
	btst	#0,D0
	beq.s	BitBassoZERO
	bset	#0,MYSPRITE2+3
	bset    #0,MYSPRITE3+3
	bra.s	PlaceCoords

BitBassoZERO
	bclr	#0,MYSPRITE2+3
	bclr    #0,MYSPRITE3+3
PlaceCoords
	lsr.w	#1,D0
	MOVE.b	d0,HSTART2
	MOVE.b	d0,HSTART3
	addi.b  #8,HSTART3
	rts


TABXPOINT
		dc.l	TABX-2

; SPRITE COORDINATES (ABSOLUTES, NO NEED TO ADD SCREEN DISPLACEMENTS)
TABX
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
	dc.w $198,$199,$19a,$19b,$19c,$19d,$19e,$19f,$1a0,$1a1
	dc.w $1a2,$1a3,$1a4,$1a5,$1a6,$1a7,$1a8,$1a9,$1aa,$1ab
	dc.w $1ac,$1ad,$1ae,$1af,$1b0,$1b1,$1b2,$1b3,$1b4,$1b5
	dc.w $1b6,$1b7,$1b8,$1b9,$1ba,$1bb,$1bc,$1bd,$1be,$1bf
	dc.w $1bf,$1bf,$1bf,$1be,$1bd,$1bb,$1b8,$1b3,$1a9,$199
	dc.w $182,$169,$156,$147,$127,$11c,$fc,$e3,$cd,$b9
	dc.w $af,$af,$a9,$ae,$af,$ac,$b0
FINETABX

TABY
	dc.w $126,$126,$126,$126,$126,$125,$125,$125,$125,$124
	dc.w $124,$124,$124,$123,$123,$123,$122,$122,$122,$122
	dc.w $121,$121,$121,$120,$120,$120,$11f,$11f,$11f,$11e
	dc.w $11e,$11e,$11d,$11d,$11d,$11c,$11c,$11c,$11b,$11b
	dc.w $11a,$11a,$11a,$119,$119,$119,$118,$118,$117,$117
	dc.w $116,$116,$116,$115,$115,$114,$114,$113,$113,$113
	dc.w $112,$112,$111,$111,$110,$110,$10f,$10f,$10e,$10e
	dc.w $10d,$10d,$10c,$10c,$10b,$10b,$10a,$10a,$109,$109
	dc.w $108,$108,$107,$106,$106,$105,$105,$104,$104,$103
	dc.w $102,$102,$101,$101,$100,$100,$ff,$fe,$fe,$fd
	dc.w $fc,$fc,$fb,$fb,$fa,$f9,$f9,$f8,$f7,$f7
	dc.w $f6,$f5,$f5,$f4,$f3,$f3,$f2,$f1,$f1,$f0
	dc.w $ef,$ef,$ee,$ed,$ec,$ec,$eb,$ea,$ea,$e9
	dc.w $e8,$e7,$e7,$e6,$e5,$e4,$e4,$e3,$e2,$e1
	dc.w $e0,$e0,$df,$de,$dd,$dd,$dc,$db,$da,$d9
	dc.w $d8,$d8,$d7,$d6,$d5,$d4,$d4,$d3,$d2,$d1
	dc.w $d0,$cf,$ce,$ce,$cd,$cc,$cb,$ca,$c9,$c8
	dc.w $c7,$c6,$c5,$c5,$c4,$c3,$c2,$c1,$c0,$bf
	dc.w $be,$bd,$bc,$bb,$ba,$b9,$b8,$b7,$b6,$b5
	dc.w $b4,$b4,$b3,$b2,$b1,$b0,$af,$ae,$ad,$ac
	dc.w $aa,$a9,$a8,$a7,$a6,$a5,$a4,$a3,$a2,$a1
	dc.w $a0,$9f,$9e,$9d,$9c,$9b,$9a,$99,$97,$96
	dc.w $95,$94,$93,$92,$91,$90,$8f,$8e,$8c,$8b
	dc.w $8a,$89,$88,$87,$86,$84,$83,$82,$81,$80
	dc.w $7e,$7d,$7c,$7b,$7a,$79,$77,$76,$75,$74
	dc.w $72,$71,$70,$6f,$6e,$6c,$6b,$6a,$69,$67
	dc.w $66,$65,$64,$62,$61,$60,$5e,$5d,$5c,$5b
	dc.w $5a,$59,$58,$58,$58,$58,$58,$58,$58,$58
	dc.w $58,$57,$57,$57,$58,$59,$5a,$60,$6b,$7f
	dc.w $97,$ac,$c5,$df,$101,$115,$126
FINETABY

; ROUTINE TO MOVE PLAYFIELD 2 UP AND DOWN	
MuoviCopper

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
	BLTCPY #JAWLOPEN,#JAW2,BLTWAIT12,#(64*1)+14
	BLTCPY #JAWROPEN,#JAW3,BLTWAIT10,#(64*1)+14

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
	BLTCPY #JAWLCLOSED,#JAW2,BLTWAIT11,#(64*1)+14
	BLTCPY #JAWRCLOSED,#JAW3,BLTWAIT9,#(64*1)+14
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
		
	
; Some variables
	
GfxBase	dc.l 0 ; Holds the gfx base address
OldCop	dc.l 0 ; Holds the old copper address
GfxName	dc.b 'graphics.library',0,0 ; Name of the graphics library

	include "music.s" ; Code for playing a mod file




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
		dc.w	$104,$0009 	; replace $0009 here with $0039 to print the banner OVER the image (exploiting a well known bug
				   			; that lets you print color 16 where in the fifth bitplane there's a 1 - works only on ocs/ecs (A500/A600)
		dc.w	$108,0
		dc.w	$10a,0
		
		dc.w $100,%0110011000000000	; bit 10 on = dual playfield
						;  6 planes = 8 colors per playfield 

		dc.w $106,$c00			; Very important, set BPLCON3 to c00
						; PF2OFx bits must be equal to 011, otherwise
						; playfield 2 will use the same color palette
						; of playfield 1 on AGA machines	
; Bitplane 1 pointers
BPLPOINTERS1
	dc.w $e0,0,$e2,0	; BPLPT1
	dc.w $e8,0,$ea,0	; BPLPT3
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
		dc.w    $180,$511    ; color0 (transparency for bitplane 1)
		dc.w    $182,$000    ; color1
		dc.w    $184,$532    ; color2
		dc.w    $186,$fff    ; color3
		dc.w    $188,$840    ; color4
		dc.w    $18a,$c75    ; color5
		dc.w    $18c,$a00    ; color6
		dc.w    $18e,$f96    ; color7

		; Colors for bitplane 2
		dc.w    $192,$300    ; color9
		dc.w    $194,$920    ; color10
		dc.w    $196,$fff    ; color11
		dc.w    $198,$600    ; color12
		dc.w    $19a,$f00    ; color13
		dc.w    $19c,$d62    ; color14
		dc.w    $19e,$fa6    ; color15



		;sprite colors;
		dc.w    $1a2,$222    ; skull color 1
		dc.w    $1a4,$999    ; skull color 2
		dc.w    $1a6,$eee    ; skull color 3

		dc.w    $1a8,$070    ; color4 - unused (useful for attached sprites in the future)
		dc.w    $1aa,$000    ; color5 - unused (useful for attached sprites in the future)
		dc.w    $1ac,$0b0    ; color6 - unused (useful for attached sprites in the future)
		dc.w    $1ae,$222    ; color7 - unused (useful for attached sprites in the future)
		dc.w    $1b0,$444    ; color8 - unused (useful for attached sprites in the future)
		
		; unused for now
		dc.w    $1b2,$e95    ; color25
		dc.w    $1b4,$d84    ; color26
		dc.w    $1b6,$686    ; color27
		dc.w    $1b8,$4a7    ; color28
		dc.w    $1ba,$175    ; color29
		dc.w    $1bc,$333    ; color30
		dc.w    $1be,$444    ; color31
		
		dc.w $FFFF,$FFFE
; ------------------------------------------------------------------
;  ---- COPPERLIST END ---------------------------------------------
; ------------------------------------------------------------------

;
; Image of the left skull jaw opened (sprite 0)
JAWLOPEN
                dc.w $0080,$0080 ; line 20
                dc.w $0080,$0080
                dc.w $00FF,$0080
                dc.w $00E3,$009E
                dc.w $005F,$003F
                dc.w $003F,$003F
                dc.w $0007,$0000

; Image of the left skull jaw closed (sprite 0)
JAWLCLOSED      dc.w $00FF,$0080 ;20
                dc.w $00E3,$009E ;21
                dc.w $005F,$003F ;22
                dc.w $003F,$003F ;23
                dc.w $0007,$0000 ;24
                dc.w $0000,$0000 ;25
                dc.w $0000,$0000 ;26

; Image of the right skull jaw closed (sprite 1) - sprite side by side
JAWRCLOSED      dc.w $FC00,$0300 ;20
                dc.w $5400,$EB00 ;21
                dc.w $FA00,$FC00 ;22
                dc.w $FC00,$FC00 ;23
                dc.w $F000,$0000 ;24
                dc.w $0000,$0000 ;25
                dc.w $0000,$0000 ;26

; Image of the right skull jaw opened (sprite 1) - sprite side by side
JAWROPEN
                dc.w $0000,$0100 ; line 20
                dc.w $0000,$0100 ; line 21
                dc.w $FC00,$0300 ; line 22
                dc.w $5400,$EB00 ; line 23
                dc.w $FA00,$FC00 ; line 24
                dc.w $FC00,$FC00 ; line 25
                dc.w $F000,$0000 ; line 26

; Right Image of the skull (SPRITE1)
MYSPRITE3
VSTART3 dc.b $50
HSTART3 dc.b $90
VSTOP3  dc.b $6a,$00
        dc.w $0000,$0000 ; line 1
        dc.w $F000,$0000 ; line 2
        dc.w $EC00,$F000 ; line 3
        dc.w $FF80,$FF00 ; line 4
        dc.w $FFC0,$FF80 ; line 5
        dc.w $FFE0,$FFE0 ; line 6
        dc.w $FFF0,$FFE0 ; line 7
        dc.w $FFE0,$FFF0 ; line 8
        dc.w $FFE0,$FFF0 ; line 9
        dc.w $FFE0,$FFB0 ; line 10
        dc.w $B7E0,$CFB0 ; line 11
        dc.w $FEE0,$FF70 ; line 12
        dc.w $BF80,$C040 ; line 13
        dc.w $5FE0,$E060 ; line 14
        dc.w $B7E0,$78E0 ; line 15
        dc.w $B7E0,$78E0 ; line 16
        dc.w $37E0,$FBC0 ; line 17
        dc.w $F780,$F800 ; line 18
        dc.w $4600,$F900 ; line 19
JAW3
        dc.w $0000,$0100 ; line 20
        dc.w $0000,$0100 ; line 21
        dc.w $FC00,$0300 ; line 22
        dc.w $5400,$EB00 ; line 23
        dc.w $FA00,$FC00 ; line 24
        dc.w $FC00,$FC00 ; line 25
        dc.w $F000,$0000 ; line 26
        dc.w 0,0

; Left Image of the skull (SPRITE0)
MYSPRITE2
VSTART2 dc.b $50
HSTART2 dc.b $90
VSTOP2  dc.b $6a,$00
        dc.w $0000,$0000 ;1
        dc.w $000F,$0000 ;2
        dc.w $0037,$000F ;3
        dc.w $01FF,$00FF ;4
        dc.w $03FF,$01FF ;5
        dc.w $07FF,$07FF ;6
        dc.w $0FFF,$07FF ;7
        dc.w $0FFF,$0FFF ;8
        dc.w $0FFF,$0FFF ;9
        dc.w $0EFF,$0DFF ;10
        dc.w $0EFD,$0DE3 ;11
        dc.w $07FF,$0EFF ;12
        dc.w $03FD,$0203 ;13
        dc.w $07FF,$0606 ;14
        dc.w $07ED,$071E ;15
        dc.w $07ED,$071E ;16
        dc.w $07EC,$03DF ;17
        dc.w $01EF,$001F ;18
        dc.w $00E2,$009F ;19
JAW2    dc.w $0080,$0080 ;20
        dc.w $0080,$0080 ;21
        dc.w $00FF,$0080 ;22
        dc.w $00E3,$009E ;23
        dc.w $005F,$003F ;24 
        dc.w $003F,$003F ;25
        dc.w $0007,$0000 ;26
        dc.w 0,0

; Image of the crow man
PIC	incbin	"crow_img_8.raw"
; Image of the banner
PIC2_1_BEFORE  dcb.b 40*256,$00
PIC2
PIC2_1	incbin "crow_banner_8_1.raw"
PIC2_1_AFTER  dcb.b 40*256,$00

PIC2_2_BEFORE  dcb.b 40*256,$00
PIC2_2	incbin "crow_banner_8_2.raw"
PIC2_2_AFTER  dcb.b 40*256,$00

PIC2_3_BEFORE  dcb.b 40*256,$00
PIC2_3	incbin "crow_banner_8_3.raw"
PIC2_3_AFTER  dcb.b 40*256,$00

mt_data	incbin  "inkazzato.mod"

	end
