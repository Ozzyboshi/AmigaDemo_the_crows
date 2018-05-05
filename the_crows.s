	include exec/types.i
	include exec/libraries.i
	include exec/exec_lib.i
	include graphics/graphics_lib.i

	SECTION Ciribiri,CODE
	
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
	move.l	#PIC,d0
    	MOVEQ	#3,D1
	lea	BPLPOINTERS,a1
POINTBP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap 	d0
    	ADD.L	#40*256,d0
    	addq.w	#8,a1
    	dbra	d1,POINTBP
    	
    	; Point the banner into the 5th bitplane
    	move.l  #PIC2,d0
    	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap 	d0

	; Start Prite init (the skull)
	; Sprite 0 init
	MOVE.L	#MYSPRITE2,d0		
	LEA	SpritePointers,a1	; SpritePointers is in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	; Sprite 1 init (attached)	
	MOVE.L	#MYSPRITE3,d0		
	addq.w	#8,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	
	; let's start our custom copperlist
	move.l #COPPERLIST,$dff080
	move.l d0,$dff088
	move.l #0,$dff1fc
	move.l $c00,$dff106
	
	; enable dma sprite
	move.w #$83a0,$dff096

	bsr.w   mt_init ; init music
		
mouse	
	WAITVEND mouse; Wait for 255th row
	
	bsr.w MoveSprite ; Move the skull sprite	
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
	
MuoviCopper
	lea	BPLPOINTERS5,a1
	move.w	2(a1),d0
	swap d0
	move.w	6(a1),d0
	tst.b	SuGiu
	beq.w	VAIGIU
	cmp.l	#PIC2-(40*50),d0
	beq.s MettiGiu
	sub.l	#40,d0
	bra.w	Finito

MettiGiu
	; Change the skull jaw pasting data with the blitter - the jaw will be opened	
	BLTCPY #JAWLOPEN,#JAW2,BLTWAIT12,#(64*1)+14
	BLTCPY #JAWROPEN,#JAW3,BLTWAIT10,#(64*1)+14

	; SuGiu flag is now 0
	clr.b	SuGiu
	bra.w Finito
	
VAIGIU
	cmpi.l	#PIC2+(40*50),d0
	beq.s MettiSu
	add.l #40,d0
	bra.w Finito
	
MettiSu
	; Change the skull jaw pasting data with the blitter - the jaw will be closed
	BLTCPY #JAWLCLOSED,#JAW2,BLTWAIT11,#(64*1)+14
	BLTCPY #JAWRCLOSED,#JAW3,BLTWAIT9,#(64*1)+14
	move.b #$ff,SuGiu
	rts
	
Finito
	lea	BPLPOINTERS5,a1
	move.w	d0,6(a1)
	swap d0
	move.w	d0,2(a1)
	rts
	
	
SuGiu
	dc.b 0,0
		
; Ruotine to move the skull according to a pre calculated path
MoveSprite
		ADDQ.L	#1,TABXPOINT
		MOVE.L	TABXPOINT(PC),A0
		CMP.L	#FINETABX-1,A0
		BNE.S	NOBSTART
		MOVE.L	#TABX-1,TABXPOINT

NOBSTART:
	MOVE.b  (A0),HSTART2
        MOVE.b  (A0),HSTART3
        addi.b  #8,HSTART3
	rts


TABXPOINT
		dc.l	TABX-1

TABX
        dc.b    $41,$43,$46,$48,$4A,$4C,$4f,$51,$53,$55,$58,$5a
        dc.b    $5C,$5E,$61,$63,$65,$67,$69,$6B,$6E,$70,$72,$74
        dc.b    $76,$78,$7A,$7C,$7E,$80,$82,$84,$86,$88,$8A,$8C
        dc.b    $8E,$90,$92,$94,$96,$97,$99,$9B,$9D,$9E,$A0,$A2
        dc.b    $A3,$A5,$A7,$A8,$AA,$AB,$AD,$AE,$B0,$B1,$B2,$B4
        dc.b    $B5,$B6,$B8,$B9,$BA,$BB,$BD,$BE,$BF,$C0,$C1,$C2
        dc.b    $C3,$C4,$C5,$C5,$C6,$C7,$C8,$C9,$C9,$CA,$CB,$CB
        dc.b    $CC,$CC,$CD,$CD,$CE,$CE,$CE,$CF,$CF,$CF,$CF,$D0
        dc.b    $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0
        dc.b    $d0,$d0,$d0,$d0,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF
        dc.b    $CF,$CE,$CE,$CE,$CD,$CD,$CC,$CC,$CB,$CB,$CA,$C9
        dc.b    $C9,$C8,$C7,$C6,$C5,$C5,$C4,$C3,$C2,$C1,$C0,$BF
        dc.b    $BE,$BD,$BB,$BA,$B9,$B8,$B6,$B5,$B4,$B2,$B1,$B0
        dc.b    $AE,$AD,$AB,$AA,$A8,$A7,$A5,$A3,$A2,$A0,$9E,$9D
        dc.b    $9B,$99,$97,$96,$94,$92,$90,$8E,$8C,$8A,$88,$86
        dc.b    $84,$82,$80,$7E,$7C,$7A,$78,$76,$74,$72,$70,$6E
        dc.b    $6B,$69,$67,$65,$63,$61,$5E,$5C,$5A,$58,$55,$53
        dc.b    $51,$4F,$4C,$4A,$48,$46,$43,$41
FINETABX

	
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
		dc.w	$104,$0009 ; replace $0009 here with $0039 to print the banner OVER the image (exploiting a well known bug
				   ; that lets you print color 16 where in the fifth bitplane there's a 1 - works only on ocs/ecs (A500/A600)
		dc.w	$108,0
		dc.w	$10a,0
		
		dc.w $100,%0101001000000000 ; BPLCON0 copperlist 

BPLPOINTERS	dc.w $00e0,$0000 ; BPL1PTH (WORD) hi ptr
		dc.w $00e2,$0000 ; BPL1PTL low ptr
		dc.w $e4,$0000,$e6,$0000	;second bitplane - BPL1PT
		dc.w $e8,$0000,$ea,$0000	;third	 bitplane - BPL2PT
		dc.w $ec,$0000,$ee,$0000	;fourth	 bitplane - BPL3PT
BPLPOINTERS5	dc.w $f0,$0000,$f2,$0000	;fifth	 bitplane - BPL4PT
		
COLORS	
		dc.w    $180,$511    ; color0
		dc.w    $182,$000    ; color1
		dc.w    $184,$422    ; color2
		dc.w    $186,$fff    ; color3
		dc.w    $188,$444    ; color4
		dc.w    $18a,$632    ; color5
		dc.w    $18c,$832    ; color6
		dc.w    $18e,$920    ; color7
		dc.w    $190,$a60    ; color8
		dc.w    $192,$c75    ; color9
		dc.w    $194,$d73    ; color10
		dc.w    $196,$686    ; color11
		dc.w    $198,$f96    ; color12
		dc.w    $19a,$ea8    ; color13
		dc.w    $19c,$4a7    ; color14
		dc.w    $19e,$175    ; color15
		dc.w	$1a0,$f00    ; color of the "the crows" banner font

		;sprite colors;
		dc.w    $1a2,$222    ; skull color 1
                dc.w    $1a4,$999    ; skull color 2
                dc.w    $1a6,$eee    ; skull color 3

		dc.w    $1a8,$070    ; color4 - unused (useful for attached sprites in the future)
		dc.w    $1aa,$000    ; color5 - unused (useful for attached sprites in the future)
		dc.w    $1ac,$0b0    ; color6 - unused (useful for attached sprites in the future)
		dc.w    $1ae,$222    ; color7 - unused (useful for attached sprites in the future)
		dc.w    $1b0,$444    ; color8 - unused (useful for attached sprites in the future)
		
		; pic colors
		dc.w    $1b2,$e95    ; color25
		dc.w    $1b4,$d84    ; color26
		dc.w    $1b6,$686    ; color27
		dc.w    $1b8,$4a7    ; color28
		dc.w    $1ba,$175    ; color29
		dc.w    $1bc,$333    ; color30
		dc.w    $1be,$444    ; color31


		dc.w 	$4a07,$FFFE	; WAIT - wait for line 4a (under the skull sprite)
		; Mirror colors 1-15 of the image to do not affect the banner overlay, in this way the banner will be behind the man
		dc.w    $1a2,$000    ; color17
		dc.w    $1a4,$422    ; color18
		dc.w    $1a6,$fff    ; color19
		dc.w    $1a8,$444    ; color20
		dc.w    $1aa,$632    ; color21
		dc.w    $1ac,$832    ; color22
		dc.w    $1ae,$920    ; color23
		dc.w    $1b0,$a60    ; color24
		dc.w    $1b2,$c75    ; color25
		dc.w    $1b4,$d73    ; color26
		dc.w    $1b6,$686    ; color27
		dc.w    $1b8,$f96    ; color28
		dc.w    $1ba,$ea8    ; color29
		dc.w    $1bc,$4a7    ; color30
		dc.w    $1be,$175    ; color31

		
		dc.w $FFFF,$FFFE

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
VSTART3 dc.b $30
HSTART3 dc.b $90
VSTOP3  dc.b $4a,$00
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
VSTART2 dc.b $30
HSTART2 dc.b $90
VSTOP2  dc.b $4a,$00
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
PIC	incbin	"crow_img_16.raw"
PATCH   dcb.b 40*256,$00

; Image of the banner
PIC2	incbin "crow_banner_2.raw"
PATCH2  dcb.b 40*256,$00
mt_data	incbin  "inkazzato.mod"

	end
