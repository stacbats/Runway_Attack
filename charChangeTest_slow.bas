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
10064 data 255,129,173,173,173,173,173,129: rem 1st data for The Building 65 ?
10066 for j=0 to 7
10068 read d
10070 poke base+char+j,d
10072 next j
10074 char=250*8 : rem offset for ?
10076 data 126,114,114,102,102,102,78,78: rem 2st data for The Building 37 %
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
 