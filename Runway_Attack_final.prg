'  53281,14:53280,12:"LOADING.." c#  15000:                              *** START SCREEN ¡(  10000:                              *** LOAD CHARCTERS ä1                                           *** SOUND VARIABLES 	2 V1 ² 54296  : P1 ² 54273 	4 D1 ² 54277  : G1 ² 54276 :	6 BA²53281      :BR²53280 N	8  V1,15: D1,15 s	_ "","] RUNWAY ATTACK ]" {	b "" 	c "" Ë	d                                          ***     DISPLAY BUILDINGS 
f SC ² 1024:                               1ST SCREEN ADDRESS 
i  C0 ² 0 ¤ 39 4
j BU ² µ(»(5)¬7)ª18 
k BL ² µ(»(7)¬2) ª 30:                 RANDOM BLOCKS, EITHER CHAR 30 OR 31 
l  RO ² BU ¤ 24 ®
m PL ² SC ª RO¬40 ª C0 ê
o  PL, BL :                             BUILDING BLOCKS ü
q  PLª54272,11 s : /}  F ² 1984 ¤ 2023:F,160:Fª54272,11: tÈ                                          ***     PLANE MOVEMENT Ê RO ²4:C0²0 Ì PL ² SCªRO¬40ªC0 ÌÖ  PL«1,32: PL,32:PL ² PLª1:       DOUBLE SHIP ï× KE ² Â(197): KE²62 § PL²PL«40 Ø  PL³1024 § PL²PLª40 #Ù  KE ² 12 § PL ² PLª40 hÚ LO²LOª1:                                 LOOP COUNTER FOR SCORE Ü  Â (PL)³±32 § 600 ð  PL,28: PL«1,27 ´ò  PLª54272,0:PLª54272«1,0 Ïú  Â (PLª40)³±160 § 300 TA²TAª1:                                 ***     TAXI COUNT e ADD THIS LINE TO INCREASE TAXI TIME EVERY LEVEL-         FOR F=1 TO 20*TA:NEXT µ TA ³15 § 300:                      15 SPACES - CHANGE NUMBER FOR LANDING â"            " "NICE LANDING" 2"            ": 800 q,                                         ***     OUR BOMB . BO ² 0 § 350 À0 DR § BP ² PL:DR ² 0:               SET BOMB POSITION 2 BP ³± PL §  BP«40,32:          CLEAR PREVIOUS BOMB POSITION N6 BP,29: BPª54272,1:              PLACE BOMB AND SET COLOR TO WHITE :BP ² BP ª 40:                            MOVE BOMB DOWN ONE ROW §;WH²WH«2: P1,WH î= Â(BP)²160§BO²0:BP«40,32: G1,32:D1,15: HIT GROUND, CLEAR BOMB T> BO²0 §  BA,14:BG,12: 350::IF BP > 2023 THEN BO = 0:POKE BP-40,32:REM OFF SCREEN, CLEAR BOMB ^? 350 w@ BP,63: BPª54272,0 ¼^                                         ***     CHECK CONTROLS ÊdKE²Â(197) þh KE ² 21 ¯ BO²0 § DR²1:BO²1:      F FOR BOMBS  j DR § WH²130: P1,WH: G1,33 , 214: hX                                         ***     CRASH ~Z PL³1500 §  240 ·] PL,42: PLª54272,0:              EXPLODE SYMBOL * Âd 7000 ég"CRASHED!": 807 (                                          *** GAME OVER ?? N!HI²Â(830):"HIGH SCORE ="HI "PA²µ(LO­40):                           1 PASS WILL EQUAL 40 LOOPS »$"YOUR SCORE = " (40«PA)ªLE æ%(40²PA)ªLE±HI § HI²(40«PA)ªLE:830,HI '"PRESS C TO PLAY AGAIN" )*¡ A$: A$³±"C" § 810 /4 nH F ² 1944 ¤ 183:                     SCREEN ADDRESS LOOP L Â(F)³±32 THE LE²LEª1 N:LE²LE«2:  èX  ***************************************************************** Z  ** SUBROUTINE                     SOUNDS a\  ***************************************************************** }^ D1,11: P1,3: G1,129 ` F² 1¤8 b BR,0:BA,2 ªd Q²1¤50: ¼f BR,5:BA,14 Ëh Q²1¤50: Üj F: G1,128 âl +'  ***************************************************************** j'  ** SUBROUTINE                     SPEED LOAD CHARACTERS ¹'  ** THANKS TO HTTPS://WWW.C64-WIKI.DE/WIKI/ZEICHEN#ZEICHENPROGRAMMIERUNG '  ***************************************************************** &' I²0 ¤ 26:  X:  828ªI,X:  I q' 169,000,160,208,133,095,132,096 :  LDA #0; LDY #$D0; STA 95, STY 96 ¼' 169,000,160,224,133,090,132,091 :  LDA #0; LDY #$E0; STA 90; STY 91 ' 169,000,160,064,133,088,132,089 :  LDA #0; LDY #$40; STA 88; STY 89 ' ' 076,191,163 :  JMP $A3BF M"' COPY $D000-$DFFF -> $3000-$3FFF q$' TRANSFER CHARACTER SET TO RAM &' 56334,Â(56334) ¯ 254 :  INTERRUPT OFF Ç(' 1,Â(1) ¯ 251 :  ZS ROM EINBLENDEN Ú*' 828 :  COPY ø,' 1,Â(1) ° 4 :  HIDE ROM ".' 56334,Â(56334) ° 1 :  INTERRUPT ON o0' 53272,Â(53272) ¯ 240 ° 12 :  $D018 SET, CHARACTER SET IN RAM AT $3000 2' NEW CHARACTERS SET Â4' A²12504 ¤ 12543:  ZE:  A,ZE:  Aª1024,255«ZE:  A 
6' 7,129,194,255,113,31,7,8 :  NEW CHARACTER BACK OF PLANE (91 -27) K8' 240,33,93,254,253,225,32,16 :  FRONT OF THE PLANE (92-28) |:' 60,24,60,60,126,126,60,24 :  BOMB (93-29) ·<' 255,129,173,173,173,173,173,129 :  BUILDING (94-30) ê>' 126,114,114,102,102,102,78,78 :  B2 (95-31) ð?' 1@' ***********  END SUBROUTINE ****************************** z:  ***************************************************************** «:  **   SUNROUTINE              TITLE SCREEN ô:  ***************************************************************** ý: "" 3 : "                         " }¢: "                                      ©" À¤: "                                     © " ¦: "                                    ©  " N¨: "                                   ©   " ª: "                                  ©    " À¬: "                                 ©     " ®: "                                ©      " D°: "                               ©       " ²: "                              ©     ©© " Ò´: "                             ©     ©©  " ¶: "                            ©     ©©   " 6¸: "                           ©           " iº: "                          ©     ©©     " ¼: "                         ©     ©©      " Ò¾: "  UP   =  Q             ©     ©©       " À: "  DOWN =  Z            ©               " =Â: "  FIRE =  F           ©     ©©        ©" pÄ: "                     ©     ©©        ©" ¢Æ: "                    ©     ©©        ©" ÑÈ: "                   ©               ©"  Ê: "                  ©     ©©        ©" 0 Ì: "                 ©     ©©        ©" 9 Î: "" K Ø: I² 1¤ 1000: S â: I Y 4;  6; ***********  END SUBROUTINE ******************************   