30 poke 53281,14:poke53280,12:?"loading.."
35 gosub 15000:rem                              *** START SCREEN
40 gosub 10000:rem                              *** LOAD CHARCTERS

49 rem                                          *** Sound variables
50 v1 = 54296  : p1 = 54273
52 d1 = 54277  : g1 = 54276
54 ba=53281      :br=53280
56 poke v1,15:poke d1,15

95 print"{clear}","{blue}{down}{right*2}{red}]{white} runway attack {red}]{black}"
98 print""
99 print""

100 rem                                         ***     DISPLAY BUILDINGS
102 sc = 1024:rem                               1st Screen Address
105 for c0 = 0 to 39
106 bu = int(rnd(5)*7)+18
107 bl = int(rnd(7)*2) + 30:rem                 random blocks, either char 30 or 31
108 for ro = bu to 24
109 pl = sc + ro*40 + c0
111 poke pl, bl : rem                            building blocks
113 poke pl+54272,11
115 next:next
125 for f = 1984 to 2023:pokef,160:pokef+54272,11:next

200 rem                                         ***     PLANE MOVEMENT
202 ro =4:c0=0
204 pl = sc+ro*40+c0
214 poke pl-1,32:poke pl,32:pl = pl+1: rem      double ship
215 ke = peek(197):if ke=62 then pl=pl-40
216 if pl<1024 then pl=pl+40
217 if ke = 12 then pl = pl+40
218 lo=lo+1:rem                                 loop counter for score
220 if peek (pl)<>32 then 600
240 poke pl,28:poke pl-1,27
242 poke pl+54272,0:pokepl+54272-1,0
250 if peek (pl+40)<>160 then 300

260 ta=ta+1:rem                                 ***     TAXI COUNT
261 rem ADD this line to increase TAXI time every level-         for f=1 to 20*ta:next
262 if ta <15 then 300:rem                      15 spaces - Change Number for landing
269 print"{red}{home}{down*6}{right*15}{reverse on}            {reverse off}"
270 print"{black}{right*15}nice landing" 
271 print"{red}{right*15}{reverse on}            {reverse off}":goto 800

300 REM                                         ***     OUR BOMB
302 if bo = 0 then 350
304 if dr then bp = pl:dr = 0:rem               set bomb position
306 if bp <> pl then poke bp-40,32:rem          clear previous bomb position
310 poke bp,29:poke bp+54272,1:rem              place bomb and set color to white
314 bp = bp + 40:rem                            move bomb down one row
315 wh=wh-2:poke p1,wh
317 if peek(bp)=160thenbo=0:pokebp-40,32:poke g1,32:poked1,15:rem hit ground, clear bomb
318 if bo=0 then poke ba,14:pokebg,12:goto 350:rem:if bp > 2023 then bo = 0:poke bp-40,32:rem off screen, clear bomb
319 goto 350
320 poke bp,63:poke bp+54272,0

350 rem                                         ***     CHECK CONTROLS
356 ke=peek(197)
360 if ke = 21 and bo=0 then dr=1:bo=1: rem     F for bombs
362 if dr then wh=130:poke p1,wh:poke g1,33

400 goto 214:return

600 rem                                         ***     CRASH
602 if pl<1500 then goto 240
605 poke pl,42:poke pl+54272,0:rem              explode symbol *
612 gosub 7000
615 print"{right*17}crashed!":goto 807

800 rem                                         *** Game over ?? 
801 hi=peek(830):print"{green}{down*2}{right*3}high score ="hi
802 pa=int(lo/40): rem                          1 pass will equal 40 loops
804 print"{down*2}{red}{right*3}your score = " (40-pa)+le 
805 if(40=pa)+le>hi then hi=(40-pa)+le:poke830,hi
807 print"{red}{down*2}{right*10}press c to play again"
810 get a$:if a$<>"c" then 810
820 run
840 for f = 1944 to 183:rem                     Screen Address loop
844 if peek(f)<>32 the le=le+1
846 next:le=le-2:return

5000 end

7000 rem  *****************************************************************
7002 rem  ** SUBROUTINE                     SOUNDS     
7004 rem  *****************************************************************
7006 poke d1,11:poke p1,3:poke g1,129
7008 for f= 1to8
7010 poke br,0:pokeba,2
7012 for q=1to50:next
7014 poke br,5:pokeba,14
7016 for q=1to50:next
7018 next f:poke g1,128
7020 return


10000 rem  *****************************************************************
10002 rem  ** SUBROUTINE                     SPEED LOAD CHARACTERS      
10003 rem  ** Thanks to https://www.c64-wiki.de/wiki/Zeichen#Zeichenprogrammierung
10004 rem  *****************************************************************
10008 for i=0 to 26: read x: poke 828+i,x: next i
10010 data 169,000,160,208,133,095,132,096 : rem lda #0; ldy #$d0; sta 95, sty 96
10012 data 169,000,160,224,133,090,132,091 : rem lda #0; ldy #$e0; sta 90; sty 91
10014 data 169,000,160,064,133,088,132,089 : rem lda #0; ldy #$40; sta 88; sty 89
10016 data 076,191,163 : rem jmp $a3bf
10018 rem copy $d000-$dfff -> $3000-$3fff
10020 rem Transfer character set to RAM
10022 poke 56334,peek(56334) and 254 : rem interrupt OFF
10024 poke 1,peek(1) and 251 : rem zs rom einblenden
10026 sys 828 : rem COPY
10028 poke 1,peek(1) or 4 : rem HIDE ROM
10030 poke 56334,peek(56334) or 1 : rem interrupt ON
10032 poke 53272,peek(53272) and 240 or 12 : rem $d018 set, character set in RAM at $3000
10034 rem new characters set
10036 for a=12504 to 12543: read ze: poke a,ze: poke a+1024,255-ze: next a
10038 data 7,129,194,255,113,31,7,8 : rem new character back of plane (91 -27)
10040 data 240,33,93,254,253,225,32,16 : rem front of the plane (92-28)
10042 data 60,24,60,60,126,126,60,24 : rem bomb (93-29)
10044 data 255,129,173,173,173,173,173,129 : rem building (94-30)
10046 data 126,114,114,102,102,102,78,78 : rem b2 (95-31)
10047 return
10048 rem ***********  END SUBROUTINE ******************************

15000 rem  *****************************************************************
15002 rem  **   SUNROUTINE              TITLE SCREEN     
15004 rem  *****************************************************************
15006 PRINT ""
15008 PRINT " {reverse on}{red}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}"
15010 PRINT " {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}             {reverse on}{black}{sh pound}"
15012 PRINT " {reverse on}{red}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}             {reverse on}{black}{sh pound}{sh space}"
15014 PRINT " {reverse on}{red}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}            {reverse on}{black}{sh pound}{sh space}{sh space}"
15016 PRINT " {reverse on}{red}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}           {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}"
15018 PRINT "                                  {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}"
15020 PRINT "  {reverse on}{red}{sh space}{reverse off}  {reverse on}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}         {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}"
15022 PRINT " {reverse on}{red}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}        {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}"
15024 PRINT " {reverse on}{red}{sh space}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{sh space}{reverse off}        {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}"
15026 PRINT " {reverse on}{red}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}      {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}"
15028 PRINT " {reverse on}{red}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}     {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}"
15030 PRINT "                            {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}"
15032 PRINT "                           {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}"
15034 PRINT "                          {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}"
15036 PRINT "                         {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}"
15038 PRINT "  {yellow}up   =  {pink}q             {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}"
15040 PRINT "  {yellow}down =  {pink}z            {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}"
15042 PRINT "  {yellow}fire =  {pink}f           {reverse on}{black}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}"
15044 PRINT "                     {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}"
15046 PRINT "                    {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}"
15048 PRINT "                   {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}"
15050 PRINT "                  {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}"
15052 PRINT "                 {reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}{reverse on}{sh pound}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{sh space}{reverse off}{sh pound}"
15054 PRINT ""
15064 for i= 1to 1000:
15074 next i
15156 return
15158 rem ***********  END SUBROUTINE ******************************
