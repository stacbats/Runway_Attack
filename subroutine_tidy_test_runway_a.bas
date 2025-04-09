30 poke 53281,14:poke53280,12:?"loading.."
35 gosub 15000
40 gosub 10000
95 print"{clear}","{blue}{down}{right*2}{red}?{white} runway attack {red}?{black}"
98 print""
99 print""
100 rem                 ***     DISPLAY BUILDINGS
102 sc = 1024:rem               1st Screen Address
105 for c0 = 0 to 39
106 bu = int(rnd(5)*7)+18
107 bl = int(rnd(7)*2)*88+162
108 for ro = bu to 24
109 pl =sc+ro*40+c0
111 poke pl,bl
113 poke pl+54272,11
115 next:next
125 for f = 1984 to 2023:pokef,160:pokef+54272,11:next
200 rem                 ***     PLANE MOVEMENT
202 ro =4:c0=0
204 pl = sc+ro*40+c0
214 poke pl-1,32:poke pl,32:pl = pl+1: rem double ship
215 ke = peek(197):if ke=62 then pl=pl-40
216 if pl<1024 then pl=pl+40
217 if ke = 12 then pl = pl+40
220 if peek (pl)<>32 then 600
240 poke pl,0:poke pl-1,35
242 poke pl+54272,0:pokepl+54272-1,0
250 if peek (pl+40)<>160 then 300
260 ta=ta+1:rem                                         TAXI COUNT
261 rem ADD this line to increase TAXI time every level for f=1 to 20*ta:next
262 if ta <15 then 300:rem                              Change Number for landing
269 print"{red}{home}{down*6}{right*13}{reverse on}            {reverse off}"
270 print"{black}{right*13}nice landing" 
271 print"{red}{right*13}{reverse on}            {reverse off}":goto 800
300 REM *** OUR BOMB
302 if bo = 0 then 350
304 if dr then bp = pl:dr = 0:rem set bomb position
306 if bp <> pl then poke bp-40,32:rem clear previous bomb position
310 poke bp,63:poke bp+54272,1:rem place bomb and set color to white
314 bp = bp + 40:rem move bomb down one row
317 if peek(bp) = 160 then bo = 0:poke bp-40,32:rem hit ground, clear bomb
318 if bp > 2023 then bo = 0:poke bp-40,32:rem off screen, clear bomb
319 goto 350
320 poke bp,63:poke bp+54272,0
350 rem                 ***     CHECK CONTROLS
356 ke=peek(197)
360 if ke = 3 and bo=0 then dr=1:bo=1: rem              F7 for bombs
400 goto 214:return
600 rem                 ***     CRASH
602 if pl<1500 then goto 240
605 poke pl,65:poke pl+54272,0:rem explode symbol
610 print"boom noise"
615 print"crashed!"
800 rem end
9999 end: 


10000 rem  *****************************************************************
10002 rem  ** SUBROUTINE                     LOAD CHARACTERS      
10004 rem  *****************************************************************
10006 poke 56334,0 : rem disable interrupts
10008 poke 1,peek(1)and251 : rem map character rom to ram
10010 for i=0 to 2047 : rem copy all characters from $d000 to $3000
10012 poke 12288+i,peek(53248+i)
10014 next i
10016 poke 1,peek(1)or4 : rem restore rom
10018 poke 56334,1 : rem enable interrupts
10020 rem ** modify character @ (char 0) **
10022 base=12288 : rem start of set at $3000
10024 char=0*8 : rem offset for @
10026 data 240,33,93,254,253,225,32,16 : rem data for @ front of plane
10028 for j=0 to 7
10030 read d
10032 poke base+char+j,d
10034 next j
10036 rem ** modify character ? (char 63) **
10038 char=35*8 : rem offset for ?
10040 data 7,129,194,255,113,31,7,8 : rem data for # back of plane
10042 for j=0 to 7
10044 read d
10046 poke base+char+j,d
10048 next j
10050 char=63*8 : rem offset for ?
10052 data 60,24,60,60,126,126,60,24 : rem data for ? The BOMB
10054 for j=0 to 7
10056 read d
10058 poke base+char+j,d
10060 next j
10062 char=162*8 : rem offset for ?
10064 data 255,129,173,173,173,173,173,129: rem 1st data for The Building 162
10066 for j=0 to 7
10068 read d
10070 poke base+char+j,d
10072 next j
10074 char=250*8 : rem offset for ?
10076 data 126,114,114,102,102,102,78,78: rem 2st data for The Building 250
10078 for j=0 to 7
10080 read d
10082 poke base+char+j,d
10084 next 
10086 rem ** set vic-ii to use $3000 **
10088 poke 53265,peek(53265)and251 : rem bank 0
10090 poke 53272,28 : rem point to $3000
10092 print "character set loaded successfully!"
10094 return
10096 rem ***********  END SUBROUTINE ******************************

15000 rem  *****************************************************************
15001 rem  **   SUNROUTINE              TITLE SCREEN     
15002 rem  *****************************************************************
15003 print ""
15005 print "          {yellow}please wait- loading"
15007 print ""
15009 print ""
15011 print "  {reverse on}{black}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}"
15013 print "  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}"
15015 print "  {reverse on}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{reverse off}  {reverse on}{sh space}"
15017 print "  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}"
15019 print "  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}"
15021 print ""
15023 print "         {reverse on}{red}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}"
15025 print "         {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off} {reverse on}{sh space}"
15027 print "         {reverse on}{sh space}{sh space}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{sh space}"
15029 print "         {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off} {reverse on}{sh space}"
15031 print "         {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off}   {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{reverse off} {reverse on}{sh space}{reverse off}  {reverse on}{sh space}{sh space}{reverse off} {reverse on}{sh space}{reverse off} {reverse on}{sh space}"
15033 print ""
15035 print ""
15037 print "  {white}the game will start shortly {yellow}....."
15039 print ""
15041 print ""
15043 print "  f7 to drop bombs "
15045 print "  a  to go up"
15047 print "  b  to go down"
15049 print ""
15051 print "{black}"
15053 return
15063 rem ***********  END SUBROUTINE ******************************

 
