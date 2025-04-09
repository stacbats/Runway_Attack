10000 rem  *****************************************************************
10002 rem  ** SUBROUTINE                     LOAD CHARACTERS      
10004 rem  *****************************************************************
10006 rem kopierroutine
10008 for i=0 to 26: read x: poke 828+i,x: next i
10010 data 169,000,160,208,133,095,132,096 : rem lda #0; ldy #$d0; sta 95, sty 96
10012 data 169,000,160,224,133,090,132,091 : rem lda #0; ldy #$e0; sta 90; sty 91
10014 data 169,000,160,064,133,088,132,089 : rem lda #0; ldy #$40; sta 88; sty 89
10016 data 076,191,163 : rem jmp $a3bf
10018 rem kopiert $d000-$dfff -> $3000-$3fff
10020 rem zeichensatz ins ram transferieren
10022 poke 56334,peek(56334) and 254 : rem interrupt aus
10024 poke 1,peek(1) and 251 : rem zs rom einblenden
10026 sys 828 : rem kopieren
10028 poke 1,peek(1) or 4 : rem zs rom ausblenden
10030 poke 56334,peek(56334) or 1 : rem interrupt ein
10032 poke 53272,peek(53272) and 240 or 12 : rem $d018 setzen, zeichensatz im ram bei $3000
10034 rem new characters setzen
10036 for a=12504 to 12543: read ze: poke a,ze: poke a+1024,255-ze: next a
10038 data 7,129,194,255,113,31,7,8 : rem new character back of plane (91 -27)
10040 data 240,33,93,254,253,225,32,16 : rem front of the plane (92-28)
10042 data 60,24,60,60,126,126,60,24 : rem bomb (93-29)
10044 data 255,129,173,173,173,173,173,129 : rem building (94-30)
10046 data 126,114,114,102,102,102,78,78 : rem b2 (95-31)
