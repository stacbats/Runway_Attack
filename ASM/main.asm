#import "Constants.asm"
#import "longBranchMacros.asm"

.label CharSetAddr = $3000
.label CharSetStartAddr = CharSetAddr + (27 * 8)

.label ScreenRAMRowHi = $D9
.label ScreenRAMRowLo = $ECF0

BasicUpstart2(Start)

.encoding "petscii_mixed"
LoadingTXT:
    .byte $05
    .text "loading.."
    .byte $00

TitleTXT:
    //"{clear}","{blue}{down}{right*2}{red}]{white} runway attack {red}]{black}"
    .byte $93, $11
    .byte $1C
    .fill 12, $1D
    .text "]"
    .byte $05
    .text " runway attack "
    .byte $1C
    .text "]"
    .byte $13, $13, $0

NiceLandingTXT:
    //"{red}{home}{down*6}{right*15}{reverse on}            {reverse off}"
    .byte $1C
    .byte $13
    .fill 6, $11
    .fill 15, $1D
    .byte $12
    .fill 12, $20
    .byte $92, $0D

    //"{black}{right*15}nice landing"
    .byte $90
    .fill 15, $1D
    .text "nice landing"
    .byte $0D

    //"{red}{right*15}{reverse on}            {reverse off}"
    .byte $1C
    .fill 15, $1D
    .byte $12
    .fill 12, $20
    .byte $92, $00

CrashedTXT:
    //"{right*17}crashed!"
    .byte $90
    .fill 4, $11
    .fill 17, $1D
    .text "crashed"
    .byte $00

HiScoreTXT:
//"{green}{down*2}{right*3}high score ="
    .byte $0D
    .byte $11, $11
    .byte $1E
    .byte $1D, $1D, $1D
    .text "high score ="
    .byte 0

ScoreTXT:
//"{down*2}{red}{right*3}your score ="
    .byte $0D
    .byte $11, $11
    .byte $1C
    .byte $1D, $1D, $1D
    .text "your score ="
    .byte 0

PlayAgainTXT:
//"{red}{down*2}{right*10}press c to play again"
    .byte $0D
    .byte $1C
    .byte $11, $11
    .fill 10, $1D
    .text "press c to play again"
    .byte 0

BuildingHeight: .byte 0
BuildingChar:   .byte 0

PlayerRow:      .byte 0     // = ro
PlayerCol:      .byte 0     // = c0
PlayerKey:      .byte 0     // = ke

Score:          .word 0     // = lo
HiScore:        .word 0
TaxiCount:      .byte 0     // = ta

BombReleased:   .byte 0     // = bo
BombRow:        .byte 0
BombCol:        .byte 0
BombWhine:      .byte 0     // = wh
BombFired:      .byte 0     // = dr

LooperVar:      .byte 0

Start:
// 30 poke 53281,14:poke53280,12:?"loading.."
    lda #14
    sta BGCOL0
    lda #12
    sta EXTCOL

    lda #<LoadingTXT
    ldy #>LoadingTXT
    jsr basicjmp_PrintString

    jsr Init_Random

// 35 gosub 15000:rem                              *** START SCREEN
    ldy #0
!Loop:
    lda TitleScreenChars,y
    sta SCREENRAM,y
    lda TitleScreenChars + $100,y
    sta SCREENRAM + $100,y
    lda TitleScreenChars + $200,y
    sta SCREENRAM + $200,y
    lda TitleScreenChars + $300,y
    sta SCREENRAM + $300,y

    lda TitleScreenColrs,y
    sta COLOURRAM,y
    lda TitleScreenColrs + $100,y
    sta COLOURRAM + $100,y
    lda TitleScreenColrs + $200,y
    sta COLOURRAM + $200,y
    lda TitleScreenColrs + $300,y
    sta COLOURRAM + $300,y

    iny
    bne !Loop-

// 40 gosub 10000:rem                              *** LOAD CHARCTERS
    jsr loadCharsSet

!KeyLooper:
    lda krljmpLSTX
    cmp #scanCode_NO_KEY
    beq !KeyLooper-

// 49 rem                                          *** Sound variables
// 50 v1 = 54296  : p1 = 54273
// 52 d1 = 54277  : g1 = 54276
// 54 ba=53281      :br=53280
// 56 poke v1,15:poke d1,15
    lda #15
    sta SIGVOL // = V1
    sta ATDCY1 // = d1

// 95 print"{clear}","{blue}{down}{right*2}{red}]{white} runway attack {red}]{black}"
// 98 print""
// 99 print""
    lda #<TitleTXT
    ldy #>TitleTXT
    jsr basicjmp_PrintString

// 100 rem                                         ***     DISPLAY BUILDINGS
// 102 sc = 1024:rem                               1st Screen Address
// 105 for c0 = 0 to 39
    ldy #0
    //jmp Line125
!LooperBuilding:

// 106 bu = int(rnd(5)*7)+18
    jsr Rand
    and #%00000111
    cmp #7
    beq !LooperBuilding-
    clc
    //lda #0
    adc #18
    sta BuildingHeight

// 107 bl = int(rnd(7)*2) + 30:rem                 random blocks, either char 30 or 31
!Retry:
    jsr Rand
    and #%00000001
    clc
    adc #30
    sta BuildingChar

// 108 for ro = bu to 24
    ldx BuildingHeight
!BuildBuilding:
// 109 pl = sc + ro*40 + c0
    lda ScreenRAMRowLo,x
    sta ZeroPageTemp1Lo
    sta ZeroPageTemp2Lo
    lda ScreenRAMRowHi,x
    and #%01111111
    sta ZeroPageTemp1Hi
    clc
    adc #>COLOURRAMDifference
    sta ZeroPageTemp2Hi

// 111 poke pl, bl : rem                            building blocks
    lda BuildingChar
    sta (ZeroPageTemp1Lo),y

// 113 poke pl+54272,11
    lda #11
    sta (ZeroPageTemp2Lo),y

// 115 next:next
    inx
    cpx #25
    bne !BuildBuilding-

    iny
    cpy #40
    bne !LooperBuilding-

// 125 for f = 1984 to 2023:pokef,160:pokef+54272,11:next
Line125:
    ldx #24
    lda ScreenRAMRowLo,x
    sta ZeroPageTemp1Lo
    sta ZeroPageTemp2Lo
    lda ScreenRAMRowHi,x
    and #%01111111
    sta ZeroPageTemp1Hi
    clc
    adc #>COLOURRAMDifference
    sta ZeroPageTemp2Hi

    ldy #0
!Loop:
    lda #160
    sta (ZeroPageTemp1Lo),y

    lda #11
    sta (ZeroPageTemp2Lo),y
    iny
    cpy #40
    bne !Loop-

// 200 rem                                         ***     PLANE MOVEMENT
// 202 ro =4:c0=0
    ldx #4
    stx PlayerRow
    ldy #1
    sty PlayerCol
    ldy #0
    sty TaxiCount
    sty BombReleased
    sty BombFired
    sty Score
    sty Score+1

// 204 pl = sc+ro*40+c0
Line204:
    jsr WaitForRasterLine
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jsr WaitForRasterLine
    jsr WorkOutPlayerLocation

// 214 poke pl-1,32:poke pl,32:pl = pl+1: rem      double ship
    dey
    lda #32
    sta (ZeroPageTemp1Lo),y
    iny
    sta (ZeroPageTemp1Lo),y
    inc PlayerCol
    lda PlayerCol
    cmp #40
    beq !GoDownARow+
    jmp Line215

!GoDownARow:
    lda #1
    sta PlayerCol
    inc PlayerRow
    
// 215 ke = peek(197):if ke=62 then pl=pl-40
Line215:
    lda 197
    sta PlayerKey

    cmp #scanCode_Q
    bne !TestOffTopScreen+
    dec PlayerRow

// 216 if pl<1024 then pl=pl+40
!TestOffTopScreen:
    lda PlayerRow
    bpl !TryDown+
    inc PlayerRow

// 217 if ke = 12 then pl = pl+40
!TryDown:
    lda PlayerKey
    cmp #scanCode_Z
    bne !Continue+
    inc PlayerRow

// 218 lo=lo+1:rem                                 loop counter for score
!Continue:
    inc Score
    bne !ByPass+
    inc Score+1

!ByPass:
// 220 if peek (pl)<>32 then 600
    jsr WorkOutPlayerLocation
    lda (ZeroPageTemp1Lo),y
    cmp #32
    jne(Line600)

// 240 poke pl,28:poke pl-1,27
Line240:
    lda #28
    sta (ZeroPageTemp1Lo),y
    dey
    lda #27
    sta (ZeroPageTemp1Lo),y

// 242 pokepl+54272-1,0:poke pl+54272,0
    lda #0
    sta (ZeroPageTemp2Lo),y
    iny
    sta (ZeroPageTemp2Lo),y

// 250 if peek (pl+40)<>160 then 300
    ldx PlayerRow
    inx                  // X = PlayerRow at the Moment
    jsr WorkOutPlayerLocation.UsingRegsAsIs
    lda (ZeroPageTemp1Lo),y
    cmp #160
    bne Line300

// 260 ta=ta+1:rem                                 ***     TAXI COUNT
    inc TaxiCount
// 261 rem ADD this line to increase TAXI time every level-         for f=1 to 20*ta:next
// 262 if ta <15 then 300:rem                      15 spaces - Change Number for landing
    lda TaxiCount
    cmp #15
    bcc Line300

// 269 print"{red}{home}{down*6}{right*15}{reverse on}            {reverse off}"
// 270 print"{black}{right*15}nice landing" 
// 271 print"{red}{right*15}{reverse on}            {reverse off}":goto 800
    lda #<NiceLandingTXT
    ldy #>NiceLandingTXT
    jsr basicjmp_PrintString
    jmp Line800


// 300 REM                                         ***     OUR BOMB
Line300:
// 302 if bo = 0 then 350
    lda BombReleased
    jeq(Line350)

// 304 if dr then bp = pl:dr = 0:rem               set bomb position
    lda BombFired
    beq !Next+
    lda PlayerRow
    sta BombRow
    lda PlayerCol
    sta BombCol
    lda #0
    sta BombFired

// 306 if bp <> pl then poke bp-40,32:rem          clear previous bomb position
!Next:
    lda BombRow
    cmp PlayerRow
    beq !NoWhereNear+
    lda BombCol
    cmp PlayerCol
    beq !NoWhereNear+
    
    ldx BombRow
    dex
    ldy BombCol
    jsr WorkOutPlayerLocation.UsingRegsAsIs
    lda #32
    sta (ZeroPageTemp1Lo),y

!NoWhereNear:
// 310 poke bp,29:poke bp+54272,1:rem              place bomb and set color to white
    ldx BombRow
    ldy BombCol
    jsr WorkOutPlayerLocation.UsingRegsAsIs
    lda #29
    sta (ZeroPageTemp1Lo),y
    lda #WHITE
    sta (ZeroPageTemp2Lo),y

// 314 bp = bp + 40:rem                            move bomb down one row
    inc BombRow
// 315 wh=wh-2:poke p1,wh
    dec BombWhine
    dec BombWhine

    //sec
    //lda BombWhine
    //sbc #2
    //sta BombWhine

    lda BombWhine
    sta FREHI1

// 317 if peek(bp)=160thenbo=0:pokebp-40,32:poke g1,32:poked1,15:rem hit ground, clear bomb
    ldx BombRow
    ldy BombCol
    jsr WorkOutPlayerLocation.UsingRegsAsIs
    lda (ZeroPageTemp1Lo),y
    cmp #160
    bne !NotTheRunway+
    lda #0
    sta BombReleased

    ldx BombRow
    dex
    ldy BombCol
    jsr WorkOutPlayerLocation.UsingRegsAsIs
    lda #32
    sta (ZeroPageTemp1Lo),y
    sta VCREG1
    lda #15
    sta ATDCY1

!NotTheRunway:
// 318 if bo=0 then poke ba,14:pokebg,12:goto 350:rem:if bp > 2023 then bo = 0:poke bp-40,32:rem off screen, clear bomb
    lda BombReleased
    bne Line350
    lda #14
    sta BGCOL0
    lda #12
    sta EXTCOL

// 319 goto 350
    jmp Line350

// 320 poke bp,63:poke bp+54272,0
    ldx BombRow
    ldy BombCol
    jsr WorkOutPlayerLocation.UsingRegsAsIs
    lda #63
    sta (ZeroPageTemp1Lo),y
    lda #0
    sta (ZeroPageTemp2Lo),y

// 350 rem                                         ***     CHECK CONTROLS
Line350:
// 356 ke=peek(197)
    lda 197
    sta PlayerKey

// 360 if ke = 21 and bo=0 then dr=1:bo=1: rem     F for bombs
    cmp #scanCode_F
    bne !Next+
    lda BombReleased
    bne !Next+
    lda #1
    sta BombFired
    sta BombReleased

!Next:
// 362 if dr then wh=130:poke p1,wh:poke g1,33
    lda BombFired
    beq !Next+
    lda #130
    sta BombWhine
    sta FREHI1
    lda #33
    sta VCREG1

!Next:
// 400 goto 214:return
    jmp Line204
    rts

// 600 rem                                         ***     CRASH
Line600:
// 602 if pl<1500 then goto 240
    jsr WorkOutPlayerLocation
    lda PlayerRow
    cmp #11
    jcc(Line240)

!ByPass:
// 605 poke pl,42:poke pl+54272,0:rem              explode symbol *
    lda #42
    sta (ZeroPageTemp1Lo),y
    lda #BLACK
    sta (ZeroPageTemp2Lo),y

// 612 gosub 7000
    jsr Line7000
// 615 print"{right*17}crashed!":goto 807
    // lda #$0D
    // jsr krljmp_CHROUT

    lda #<CrashedTXT
    ldy #>CrashedTXT
    jsr basicjmp_PrintString
    jmp Line807


// 800 rem                                         *** Game over ?? 
Line800:
// 801 hi=peek(830):print"{green}{down*2}{right*3}high score ="hi
    // lda #$0D
    // jsr krljmp_CHROUT

    lda #<HiScoreTXT
    ldy #>HiScoreTXT
    jsr basicjmp_PrintString

    lda HiScore + 1
    ldx HiScore
    jsr basicjmp_PrintWordInt

// 802 pa=int(lo/40): rem                          1 pass will equal 40 loops
// 804 print"{down*2}{red}{right*3}your score = " (40-pa)+le 
    lda #<ScoreTXT
    ldy #>ScoreTXT
    jsr basicjmp_PrintString

    lda Score + 1
    ldx Score
    jsr basicjmp_PrintWordInt

// 805 if(40=pa)+le>hi then hi=(40-pa)+le:poke830,hi
    lda Score + 1
    cmp HiScore + 1
    bcc Line807
    beq !TestLoByte+

SetHiScore:
    lda Score
    sta HiScore
    lda Score + 1
    sta HiScore + 1
    jmp Line807

!TestLoByte:
    lda Score
    cmp HiScore
    bcc Line807
    jmp SetHiScore

Line807:
// 807 print"{red}{down*2}{right*10}press c to play again"
    lda #<PlayAgainTXT
    ldy #>PlayAgainTXT
    jsr basicjmp_PrintString

// 810 get a$:if a$<>"c" then 810
Line810:
    lda 197
    cmp #scanCode_C
    bne Line810
    
// 820 run
    jmp Start

// 840 for f = 1944 to 183:rem                     Screen Address loop
// 844 if peek(f)<>32 the le=le+1
// 846 next:le=le-2:return

// 5000 end

// 7000 rem  *****************************************************************
// 7002 rem  ** SUBROUTINE                     SOUNDS     
// 7004 rem  *****************************************************************
Line7000:
// 7006 poke d1,11:poke p1,3:poke g1,129
    lda #11
    sta ATDCY1
    lda #3
    sta FREHI1
    lda #129
    sta VCREG1

// 7008 for f= 1to8
    ldx #8
    stx LooperVar

Line7010:
// 7010 poke br,0:pokeba,2
    lda #0
    sta EXTCOL
    lda #2
    sta BGCOL0

// 7012 for q=1to50:next
    ldx #90
    ldy #$FF
    jsr OSKDelay

// 7014 poke br,5:pokeba,14
    lda #5
    sta EXTCOL
    lda #14
    sta BGCOL0

// 7016 for q=1to50:next
    ldx #90
    ldy #$FF
    jsr OSKDelay

// 7018 next f:poke g1,128
    dec LooperVar
    bne Line7010

    lda #128
    sta VCREG1

// 7020 return
    rts

loadCharsSet:
// 10000 rem  *****************************************************************
// 10002 rem  ** SUBROUTINE                     SPEED LOAD CHARACTERS      
// 10003 rem  ** Thanks to https://www.c64-wiki.de/wiki/Zeichen#Zeichenprogrammierung
// 10004 rem  *****************************************************************
// 10008 for i=0 to 26: read x: poke 828+i,x: next i
// 10010 data 169,000,160,208,133,095,132,096 : rem lda #0; ldy #$d0; sta 95, sty 96
    // lda #0
    // ldy #$D0
    // sta 95
    // sta 96

// 10012 data 169,000,160,224,133,090,132,091 : rem lda #0; ldy #$e0; sta 90; sty 91
    // lda #0
    // ldy #$E0
    // sta 90
    // sta 91

// 10014 data 169,000,160,064,133,088,132,089 : rem lda #0; ldy #$40; sta 88; sty 89
    // lda #0
    // ldy #$40
    // sta 88
    // sta 89

// 10016 data 076,191,163 : rem jmp $a3bf
    // jmp basicjmp_MoveBytes

// 10018 rem copy $d000-$dfff -> $3000-$3fff
// 10020 rem Transfer character set to RAM
// 10022 poke 56334,peek(56334) and 254 : rem interrupt OFF
    sei

// 10024 poke 1,peek(1) and 251 : rem zs rom einblenden
    lda 1
    and #251
    sta 1

// 10026 sys 828 : rem COPY
    lda #0
    ldy #$D0
    sta 95
    sty 96

    lda #0
    ldy #$E0
    sta 90
    sty 91

    lda #0
    ldy #$40
    sta 88
    sty 89
    jsr basicjmp_MoveBytes

// 10028 poke 1,peek(1) or 4 : rem HIDE ROM
    lda 1
    ora #4
    sta 1

// 10030 poke 56334,peek(56334) or 1 : rem interrupt ON
    cli

// 10032 poke 53272,peek(53272) and 240 or 12 : rem $d018 set, character set in RAM at $3000
    lda VMCSB
    and #%11110000      // 240 / $F0
    ora #%00001100      // 12 / $0C
    sta VMCSB

// 10034 rem new characters set
// 10036 for a=12504 to 12543: read ze: poke a,ze: poke a+1024,255-ze: next a
    ldy #0
!Looper:
    lda ModdedChars,y
    sta CharSetStartAddr,y
    eor #255
    sta CharSetStartAddr + $0400,y
    iny
    cpy #40
    bne !Looper-
    rts

// 10038 data 7,129,194,255,113,31,7,8 : rem new character back of plane (91 -27)
// 10040 data 240,33,93,254,253,225,32,16 : rem front of the plane (92-28)
// 10042 data 60,24,60,60,126,126,60,24 : rem bomb (93-29)
// 10044 data 255,129,173,173,173,173,173,129 : rem building (94-30)
// 10046 data 126,114,114,102,102,102,78,78 : rem b2 (95-31)

ModdedChars:
	.byte	$07,$81,$C2,$FF,$71,$1F,$07,$08
	.byte	$F0,$21,$5D,$FE,$FD,$E1,$20,$10
	.byte	$3C,$18,$3C,$3C,$7E,$7E,$3C,$18
	.byte	$FF,$81,$AD,$AD,$AD,$AD,$AD,$81
	.byte	$7E,$72,$72,$66,$66,$66,$4E,$4E

// 10047 return
// 10048 rem ***********  END SUBROUTINE ******************************

// 15000 rem  *****************************************************************
// 15002 rem  **   SUNROUTINE              TITLE SCREEN     
// 15004 rem  *****************************************************************
// 15006 PRINT ""
// 15008 PRINT " {reverse on}{red}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}"
// 15010 PRINT " {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}             {reverse on}{black}{sh pound}"
// 15012 PRINT " {reverse on}{red}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}             {reverse on}{black}{sh pound}{sh space}"
// 15014 PRINT " {reverse on}{red}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}            {reverse on}{black}{sh pound}{sh space}{sh space}"
// 15016 PRINT " {reverse on}{red}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}           {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}"
// 15018 PRINT "                                  {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}"
// 15020 PRINT "  {reverse on}{red}{sh space}{reverse off}  {reverse on}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}         {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}"
// 15022 PRINT " {reverse on}{red}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}        {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}"
// 15024 PRINT " {reverse on}{red}{sh space}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{sh space}{reverse off}        {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}"
// 15026 PRINT " {reverse on}{red}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}      {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}"
// 15028 PRINT " {reverse on}{red}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}     {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}"
// 15030 PRINT "                            {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}"
// 15032 PRINT "                           {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}"
// 15034 PRINT "                          {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}"
// 15036 PRINT "                         {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}"
// 15038 PRINT "  {yellow}up   =  {pink}q             {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}"
// 15040 PRINT "  {yellow}down =  {pink}z            {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}"
// 15042 PRINT "  {yellow}fire =  {pink}f           {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}"
// 15044 PRINT "                     {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}"
// 15046 PRINT "                    {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}"
// 15048 PRINT "                   {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}"
// 15050 PRINT "                  {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}"
// 15052 PRINT "                 {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}"
// 15054 PRINT ""
// 15064 for i= 1to 1500:
// 15074 next i
// 15156 return

TitleScreenChars:
	.byte	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$E9,$20,$20
	.byte	$20,$E0,$E0,$20,$20,$E0,$20,$E0,$20,$E0,$20,$20,$E0,$20,$E0,$20,$E0,$20,$20,$E0,$20,$20,$E0,$20,$E0,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$E9,$E9,$A0,$20,$20
	.byte	$20,$E0,$20,$E0,$20,$E0,$20,$E0,$20,$E0,$E0,$20,$E0,$20,$E0,$20,$E0,$20,$E0,$20,$E0,$20,$E0,$20,$E0,$20,$20,$20,$20,$20,$20,$20,$20,$20,$E9,$A0,$A0,$A0,$20,$20
	.byte	$20,$E0,$E0,$20,$20,$E0,$20,$E0,$20,$E0,$E0,$E0,$E0,$20,$E0,$20,$E0,$20,$E0,$E0,$E0,$20,$20,$E0,$20,$20,$20,$20,$20,$20,$20,$E9,$20,$20,$A0,$A0,$A0,$69,$E9,$20
	.byte	$20,$E0,$20,$E0,$20,$E0,$20,$E0,$20,$E0,$20,$E0,$E0,$20,$E0,$E0,$E0,$20,$E0,$20,$E0,$20,$20,$E0,$20,$20,$20,$20,$20,$20,$E9,$A0,$20,$E9,$A0,$A0,$20,$E9,$E0,$20
	.byte	$20,$E0,$20,$E0,$20,$20,$E0,$20,$20,$E0,$20,$20,$E0,$20,$E0,$20,$E0,$20,$E0,$20,$E0,$20,$20,$E0,$20,$20,$20,$20,$20,$20,$A0,$A0,$E9,$A0,$A0,$69,$E9,$E0,$E0,$20
	.byte	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$A0,$A0,$A0,$A0,$20,$E9,$E0,$E0,$E0,$20
	.byte	$20,$20,$E0,$20,$20,$E0,$E0,$E0,$20,$E0,$E0,$E0,$20,$20,$E0,$20,$20,$20,$E0,$E0,$20,$E0,$20,$E0,$20,$20,$20,$20,$20,$20,$A0,$A0,$A0,$69,$E9,$E0,$E0,$E0,$E0,$20
	.byte	$20,$E0,$20,$E0,$20,$20,$E0,$20,$20,$20,$E0,$20,$20,$E0,$20,$E0,$20,$E0,$20,$20,$20,$E0,$20,$E0,$20,$20,$20,$20,$20,$20,$A0,$A0,$20,$E9,$E0,$E0,$E0,$E0,$E0,$20
	.byte	$20,$E0,$E0,$E0,$20,$20,$E0,$20,$20,$20,$E0,$20,$20,$E0,$E0,$E0,$20,$E0,$20,$20,$20,$E0,$E0,$20,$20,$20,$20,$E9,$20,$E9,$A0,$20,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$20
	.byte	$20,$E0,$20,$E0,$20,$20,$E0,$20,$20,$20,$E0,$20,$20,$E0,$20,$E0,$20,$E0,$20,$20,$20,$E0,$20,$E0,$20,$20,$E9,$A0,$E9,$A0,$20,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$20
	.byte	$20,$E0,$20,$E0,$20,$20,$E0,$20,$20,$20,$E0,$20,$20,$E0,$20,$E0,$20,$20,$E0,$E0,$20,$E0,$20,$E0,$E9,$A0,$A0,$A0,$A0,$69,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$E9,$20
	.byte	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$A0,$A0,$A0,$A0,$20,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$E9,$E0,$20
	.byte	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$E9,$A0,$A0,$A0,$69,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$20
	.byte	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$E9,$A0,$A0,$A0,$20,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$E9,$E0,$E0,$E0,$20
	.byte	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$A0,$A0,$A0,$69,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$E9,$E0,$E0,$E0,$E0,$20
	.byte	$20,$20,$15,$10,$20,$20,$20,$3D,$20,$20,$11,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$A0,$A0,$20,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$E9,$E0,$E0,$E0,$E0,$E0,$20
	.byte	$20,$20,$04,$0F,$17,$0E,$20,$3D,$20,$20,$1A,$20,$20,$20,$20,$20,$20,$20,$20,$E9,$20,$E9,$A0,$20,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$20
	.byte	$20,$20,$06,$09,$12,$05,$20,$3D,$20,$20,$06,$20,$20,$20,$20,$20,$20,$20,$E9,$A0,$E9,$A0,$20,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$20
	.byte	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$A0,$A0,$A0,$69,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$20,$20
	.byte	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$A0,$A0,$20,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$20,$20,$20
	.byte	$20,$10,$12,$05,$13,$13,$20,$01,$20,$0B,$05,$19,$20,$20,$20,$20,$20,$20,$A0,$69,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$69,$20,$20,$20,$20
	.byte	$20,$14,$0F,$20,$03,$0F,$0E,$14,$09,$0E,$15,$05,$20,$20,$20,$20,$20,$20,$20,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$20,$20,$20,$20,$20
	.byte	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$E9,$E0,$E0,$E0,$E0,$E0,$E0,$69,$20,$20,$20,$20,$20,$20
	.byte	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20

TitleScreenColrs:
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0C,$00,$00
	.byte	$00,$02,$02,$02,$00,$02,$00,$02,$00,$02,$07,$02,$02,$07,$02,$07,$02,$07,$07,$02,$07,$07,$02,$07,$02,$07,$07,$07,$07,$07,$00,$00,$00,$00,$00,$0F,$0C,$0C,$00,$00
	.byte	$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$02,$02,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$0F,$0C,$0C,$00,$00
	.byte	$00,$02,$02,$00,$00,$02,$00,$02,$00,$02,$02,$02,$02,$00,$02,$00,$02,$00,$02,$02,$02,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$0B,$00,$00,$0F,$0F,$0C,$0C,$00,$00
	.byte	$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$02,$02,$02,$00,$02,$02,$02,$00,$02,$00,$02,$00,$00,$02,$00,$00,$00,$00,$00,$00,$0B,$0B,$00,$0C,$0F,$0F,$00,$00,$00,$00
	.byte	$00,$02,$00,$02,$00,$00,$02,$00,$00,$02,$00,$02,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$00,$02,$00,$00,$00,$00,$00,$00,$0B,$0B,$0C,$0C,$0F,$0F,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0B,$0B,$0C,$0C,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$02,$00,$00,$02,$02,$02,$00,$02,$02,$02,$00,$00,$02,$00,$00,$00,$02,$02,$00,$02,$00,$02,$00,$00,$00,$00,$00,$00,$0B,$0B,$0C,$0C,$00,$00,$00,$00,$00,$00
	.byte	$00,$02,$00,$02,$00,$00,$02,$00,$00,$00,$02,$00,$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$00,$00,$00,$00,$00,$0B,$0B,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$02,$02,$02,$00,$00,$02,$00,$00,$00,$02,$00,$00,$02,$02,$02,$00,$02,$00,$00,$00,$02,$02,$00,$00,$00,$00,$0C,$00,$0F,$0B,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$02,$00,$02,$00,$00,$02,$00,$00,$02,$02,$02,$00,$02,$02,$02,$00,$02,$02,$02,$00,$02,$02,$02,$00,$00,$0C,$0C,$0F,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$02,$00,$02,$00,$00,$02,$00,$00,$02,$02,$02,$00,$02,$02,$02,$00,$00,$02,$02,$00,$02,$00,$02,$0F,$0F,$0C,$0C,$0F,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$00,$00,$02,$00,$00,$00,$02,$00,$00,$02,$02,$02,$0F,$0F,$0C,$0C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$02,$00,$00,$02,$00,$00,$00,$02,$00,$00,$02,$00,$0B,$0F,$0F,$0C,$0C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$02,$00,$00,$02,$00,$00,$00,$02,$00,$00,$02,$0B,$0B,$0F,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0B,$0B,$0F,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$07,$07,$00,$00,$00,$07,$00,$00,$0A,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0B,$0B,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$07,$07,$07,$07,$01,$07,$01,$01,$0A,$01,$01,$01,$01,$00,$01,$01,$01,$0C,$01,$0F,$0B,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$07,$07,$07,$07,$00,$07,$00,$00,$0A,$00,$00,$00,$00,$00,$00,$00,$0C,$0C,$0F,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0C,$0C,$0F,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$07,$07,$00,$07,$07,$00,$07,$07,$07,$07,$00,$07,$07,$07,$07,$07,$0C,$0C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0C,$0C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

// 15158 rem ***********  END SUBROUTINE ******************************


//******************************************************************************
//*                                                                             *
//* G^Ray Defender - Randomiser Code from G-Pac Clone Game                      *
//*                                                                             *
//*******************************************************************************

//============================================================
Init_Random:
    lda #$FF                // maximum frequency value
    sta FRELO3              // voice 3 frequency low byte
    sta FREHI3              // voice 3 frequency high byte
    lda #$80                // noise SIRENform, gate bit off
    sta VCREG3              // voice 3 control register
    rts

Rand:
    lda WAVOUT3             // get random value from 0-255
    rts
//============================================================


//******************************************************************************* */
WorkOutPlayerLocation:
{
// Inputs:  None
// OutPuts: yreg = Players Col
//        : ZP ZeroPageTemp1Lo = Screen Location
//        : ZP ZeroPageTemp2Lo = Colour Location

// Registers destroyed are X, Y and Acc
    ldy PlayerCol
    ldx PlayerRow
UsingRegsAsIs:
    lda ScreenRAMRowLo,x
    sta ZeroPageTemp1Lo
    sta ZeroPageTemp2Lo
    lda ScreenRAMRowHi,x
    and #%01111111
    sta ZeroPageTemp1Hi
    clc
    adc #>COLOURRAMDifference
    sta ZeroPageTemp2Hi
    rts
}

// *****************************************************************************
// OSK Famous DelayFunction

// Input : X = Number Of Complete Cycles
//       : Y = The Complete Cycle Delay
OSKDelay:
{
    sty InitCycleCounter

Outer:
    ldy InitCycleCounter: #$00

Inner:
    dey
    bne Inner

    dex
    bne Outer
    rts
}

WaitForRasterLine:
    lda RASTER
    cmp #250
    bne WaitForRasterLine
    rts