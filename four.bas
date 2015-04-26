REM 
REM version 4.5 bigger decaying average
REM version 4.28 310 CDS
REM feb 2008 complete overhaul
REM 26/2/2006 no GOSUBS in normal running
REM coil dwell controlled by line staments
REM output loops scaled to input loops
REM 24/2/2006 recalibrated input loops now 422226 per sec
REM 30/5/2005 for toshiba 310CDT
REM 29/1/2006
REM rehashed program display added adjustments
REM removed data on rpm lookup file
REM added bar graphs
REM WRITE #3, rpm, t, ((tickdeg# * (maxadv - (mecadv(rpm) + vac!))) * inputscale#) - 26

CLEAR , , 4000: DEFLNG A-Z: OPTION BASE 0
SCREEN 12
COLOR 15
OPEN "c:\qb\logs\four.csv" FOR OUTPUT AS #3
WRITE #3, "RPM", "t", "ta"
DIM mecadv(16383) AS SINGLE
DIM inc(16383) AS SINGLE
'******************************Hardcoded values******************************
revstall = 60: revlimit = 6200: revstop = 6500
'****************************************************************************
'More Hardcoded values
lowrpm = 600: highrpm = 10000: highdeg! = 50: nospin! = -4
maxadv = 63: vachigh! = 10: absvac! = 10: idlespin = -4
inputscale# = 2.249: progoffset = 581: rpmscale = 370700: rpmoffset = 0
donkcold = 10: mecramp = 10: timinglight = 8: absvaclimit = 400
up = 1: incsize% = 25
REM remove to use defaults
'GOSUB savedata
GOSUB enablekeys
GOSUB menu1
GOSUB loaddata
SOUND 1000, 2
SOUND 1900, 2
SOUND 1200, 2
GOSUB display

start:
OUT (&H378), 255
OUT (&H378), 255
OUT (&H378), 255
OUT (&H378), 255
OUT (&H379), 0
starting:
t = 0: ti = 0:  u% = 0
trigger:
OUT (&H378), 255
OUT (&H378), 255
OUT (&H378), 255
OUT (&H378), 255
u% = u% + 1
IF u% > 30000 THEN u% = 500
DO: ti = ti + 1
LOOP UNTIL 199 = INP(889)
DO: ti = ti + 1
LOOP UNTIL 199 = INP(889)
DO: ti = ti + 1
LOOP UNTIL 199 = INP(889)
DO: ti = ti + 1
LOOP UNTIL 199 = INP(889)
DO: ti = ti + 1
LOOP UNTIL 135 = INP(889)
DO: ti = ti + 1
LOOP UNTIL 135 = INP(889)
DO: ti = ti + 1
LOOP UNTIL 135 = INP(889)
DO: ti = ti + 1
LOOP UNTIL 135 = INP(889)
IF cutout THEN t = (s / inputscale#) + progoffset
cutout = 0
t = t + ti
t5 = t4
t4 = t3
t3 = t2
t2 = t1
t1 = t
ta1 = ta1
ta1 = ta
ta = (t + ((t + t1 + t2 + t3) * .25) + ((ta1 + ta2) * .5) * .5) * .4
IF u% < 200 THEN
tickdeg# = t / 180
rpm = ((rpmscale / t) * 30) + rpmoffset
END IF
IF u% > 199 THEN
tickdeg# = ta / 180
rpm = ((rpmscale / ta) * 30) + rpmoffset
END IF
IF rpm < revstall THEN GOTO starting
s = ((tickdeg# * (maxadv - (mecadv(rpmadv) + vac!))) * inputscale#) - 55
ss = ((tickdeg# * 90) * inputscale#) - 55
IF rpm > revlimit THEN GOTO softlimit
IF rpm > revstop THEN GOTO revcutout
IF rpm > rpmadv + mecramp THEN rpmadv = rpmadv + mecramp
IF rpm < rpmadv + mecramp THEN rpmadv = rpmadv - (mecramp * 8)
IF s < 1 THEN s = 1
DO
d = d + 1
LOOP UNTIL d = s
IF u% < 5 THEN GOTO skipign
OUT (&H378), 0
OUT (&H378), 0
OUT (&H378), 0
OUT (&H378), 0
skipign:
d = 0
ti = 0
IF slcal THEN
slup = incsize% * -1
slcal = 0
up = 1
GOTO slcrunch
END IF
IF slup THEN
slup = slup + 1
GOTO slcal
END IF
gtiming = (maxadv - (maxadv - (mecadv(rpmadv) + vac!))) * 6.7
LINE (1, 16)-(640, 16), 0
LINE (1, 16)-(rpm / 15, 16), 15
LINE (1, 17)-(640, 17), 0
LINE (1, 17)-(rpm / 15, 17), 15
LINE (1, 18)-(640, 18), 0
LINE (1, 18)-(rpm / 15, 18), 15
LINE (1, 19)-(640, 19), 0
LINE (1, 19)-(rpmadv / 15, 19), 15
LINE (1, 20)-(640, 20), 0
LINE (1, 20)-(rpmadv / 15, 20), 15
LINE (1, 27)-(640, 27), 0
LINE (1, 27)-(gtiming, 27), 14
LINE (1, 28)-(640, 28), 0
LINE (1, 28)-(gtiming, 28), 14
LINE (1, 29)-(640, 29), 0
LINE (1, 29)-(gtiming, 29), 14
LINE (1, 49)-(640, 49), 0
LINE (1, 49)-(trate# * 6.7, 49), 14
LINE (1, 50)-(640, 50), 0
LINE (1, 50)-(trate# * 6.7, 50), 14
LINE (1, 51)-(640, 51), 0
LINE (1, 51)-(trate# * 6.7, 51), 14
LINE (1, 80)-(640, 80), 0
LINE (1, 80)-(revlimit / 15, 80), 14
LINE (1, 81)-(640, 81), 0
LINE (1, 81)-(revlimit / 15, 81), 14
LINE (1, 84)-(640, 84), 0
LINE (1, 84)-(vachigh! * 6.7, 84), 14
LINE (1, 85)-(640, 85), 0
LINE (1, 85)-(vachigh! * 6.7, 85), 14
LINE (1, 128)-(640, 128), 0
LINE (1, 128)-(lowrpm / 15, 128), 12
LINE (1, 129)-(640, 129), 0
LINE (1, 129)-(lowrpm / 15, 129), 12
LINE (1, 132)-(640, 132), 0
LINE (1, 132)-(highrpm / 15, 132), 12
LINE (1, 133)-(640, 133), 0
LINE (1, 133)-(highrpm / 15, 133), 12
LINE (1, 136)-(640, 136), 0
LINE (1, 136)-(highdeg * 6.7, 136), 12
LINE (1, 137)-(640, 137), 0
LINE (1, 137)-(highdeg * 6.7, 137), 12
LINE (1, 140)-(640, 140), 0
LINE (1, 140)-(nospin! * 6.7, 140), 12
LINE (1, 141)-(640, 141), 0
LINE (1, 141)-(nospin! * 6.7, 141), 12
slret:
port% = INP(&H379)
OUT (&H378), 255
OUT (&H379), 0
IF port% = 247 THEN
vac! = donkcold% + absvac! + vachigh!
END IF
IF port% = 199 THEN
vac! = 0
END IF
IF port% = 215 THEN
vac! = absvac! + vachigh!
END IF
IF port% = 103 THEN
vac! = donkcold% + absvac!
END IF
IF port% = 119 THEN
vac! = donkcold% + absvac!
END IF
IF port% = 71 THEN
vac! = 0
END IF
IF port% = 87 THEN
vac! = absvac!
END IF
IF port% = 143 THEN
vac! = vachigh!
END IF
IF port% = 207 THEN
vac! = vachigh!
END IF
IF port% = 135 THEN
vac! = vachigh!
END IF
IF port% = 7 THEN
vac! = 0
END IF
IF port% = 23 THEN
vac! = absvac!
END IF
IF port% = 39 THEN
vac! = donkcold%
END IF
IF port% = 151 THEN
vac! = absvac! + vachigh!
END IF
IF port% = 138 THEN
vac! = vachigh! + donkcold%
END IF
IF port% = 55 THEN
vac! = absvac! + donkcold%
END IF
IF port% = 167 THEN
vac! = vachigh! + donkcold%
END IF
IF rpm < absvaclimit THEN
vac! = 0
temp! = 0
END IF
t = (s / inputscale#) + progoffset
GOTO health
rhealth:
OUT &H378, 255
GOTO trigger

revcutout:
PRINT "rev cutout"
DO
p% = INP(&H379)
LOOP UNTIL p% = 199
DO
p% = INP(&H379)
LOOP UNTIL p% = 135
DO
p% = INP(&H379)
LOOP UNTIL p% = 199
DO
p% = INP(&H379)
LOOP UNTIL p% = 135
cutout = 1
GOTO starting

softlimit:
PRINT "Soft Limit"
ti = 0
cutout = 1
GOTO trigger


health:
c = INP(96)
a$ = INKEY$
IF a$ = "" THEN GOTO uprpm
t = t + 800
IF a$ = CHR$(27) THEN GOSUB shutdown
IF a$ = "1" THEN GOTO slopecalc
IF a$ = "2" THEN GOTO timedist
IF a$ = "3" THEN GOTO settiming
IF a$ = "4" THEN GOTO savedata
IF a$ = "5" THEN GOSUB loaddata
IF a$ = "6" THEN GOTO exportdata
IF a$ = "7" THEN GOTO importdata
IF a$ = "8" THEN GOTO gettiming
IF a$ = "9" THEN GOTO initdata
IF a$ = "q" THEN GOTO inctrs
IF a$ = "a" THEN GOTO dectrs
IF a$ = "w" THEN GOTO inctrl
IF a$ = "s" THEN GOTO dectrl
IF a$ = "e" THEN GOTO incmr
IF a$ = "d" THEN GOTO decmr
IF a$ = "r" THEN GOTO incabs
IF a$ = "f" THEN GOTO decabs
IF a$ = "t" THEN GOTO incrs
IF a$ = "g" THEN GOTO decrs
IF a$ = "y" THEN GOTO incro
IF a$ = "h" THEN GOTO decro
IF a$ = "u" THEN GOTO incdc
IF a$ = "j" THEN GOTO decdc
IF a$ = "z" THEN GOTO incrl
IF a$ = "x" THEN GOTO decrl
GOTO rhealth

display:
t = t + 500
up = 0
LOCATE 1, 6
PRINT USING "#####"; rpm;
LOCATE 1, 18
PRINT USING "######"; s;
LOCATE 1, 34
PRINT USING "##.##"; maxadv - (maxadv - (mecadv(rpmadv) + vac!));
LOCATE 1, 49
PRINT USING "##.##"; mecadv(rpmadv);
LOCATE 1, 69
PRINT USING "##.#"; idlespin;
LOCATE 3, 10
PRINT USING "##.##"; trate#;
LOCATE 3, 27
PRINT USING "###.#"; vac!;
LOCATE 3, 46
PRINT USING "###"; port%;
LOCATE 3, 56
PRINT USING "##.#"; donkcold;
LOCATE 5, 11
PRINT USING "####"; revlimit;
LOCATE 5, 52
PRINT USING "###.#"; vachigh!;
LOCATE 7, 9
PRINT USING "####"; lowrpm;
LOCATE 7, 28
PRINT USING "#####"; highrpm;
LOCATE 7, 45
PRINT USING "###.#"; highdeg!;
LOCATE 7, 64
PRINT USING "###.#"; nospin!
LOCATE 10, 13
PRINT USING "##.##"; tratescale#;
LOCATE 10, 33
PRINT USING "##.##"; tratelimit;
LOCATE 10, 49
PRINT USING "##.#"; mecramp;
LOCATE 10, 65
PRINT USING "###.#"; absvac!
LOCATE 13, 11
PRINT USING "##.####"; inputscale#;
LOCATE 13, 27
PRINT USING "######"; progoffset;
LOCATE 13, 46
PRINT USING "########"; rpmscale;
LOCATE 13, 62
PRINT USING "###.##"; rpmoffset;
OUT &H378, 255
GOTO rhealth

uprpm:
LOCATE 1, 6
PRINT USING "#####"; rpm;
LOCATE 1, 18
PRINT USING "######"; s;
LOCATE 1, 34
PRINT USING "##.##"; maxadv - (maxadv - (mecadv(rpmadv) + vac!));
LOCATE 3, 46
PRINT USING "###"; port%;
IF up = 1 THEN GOTO display
GOTO rhealth
update:
GOTO rhealth

menu1:
LOCATE 1, 1
PRINT "RPM "; : PRINT USING "#####"; rpm;
PRINT "  Ticks"; : PRINT USING "######"; s;
PRINT "   Timing "; : PRINT USING "###.##"; maxadv - (maxadv - (mecadv(rpm) + vac!));
PRINT "  Mecadv "; : PRINT USING "###.##"; mecadv(rev);
PRINT "      Idle Deg  "; : PRINT USING "##.#"; idlespin;
LOCATE 3, 1
PRINT "Rate Acc "; : PRINT USING "##.##"; trate#;
PRINT "  Vac Total "; : PRINT USING "###.##"; vac!;
PRINT "  Port Input "; : PRINT USING "###"; port%;
PRINT "  Temp "; : PRINT USING "###"; donkcold; : PRINT "    U / J";

LOCATE 5, 1
PRINT "Rev Limit "; : PRINT USING "#######"; revlimit;
PRINT " Z / X  ";
PRINT "                vachigh! "; : PRINT USING "###.##"; vachigh!;
LOCATE 5, 60
PRINT " F7 /F8 ";
LOCATE 7, 1
PRINT "Low RPM"; : PRINT USING "#####"; lowrpm;
PRINT "    High RPM   "; : PRINT USING "#####"; highrpm;
PRINT "    Mech Deg "; : PRINT USING "###.##"; highdeg!;
PRINT "  Static Deg "; : PRINT USING "###.##"; nospin!
LOCATE 8, 1
PRINT "F1+ F2-          F3+ F4-           F5+ F6-          F9+ F10-"
LOCATE 10, 1
PRINT "Trate Scale "; : PRINT USING "##.##"; tratescale#;
PRINT "   Trate Limit "; : PRINT USING "##.##"; tratelimit;
PRINT "   Mecramp "; : PRINT USING "##.##"; mecramp;
PRINT "   Abs Vac "; : PRINT USING "###.##"; absvac!
LOCATE 11, 1
PRINT "Q / A               W / S               E / D           R / F";
LOCATE 13, 1
PRINT "Input Loop"; : PRINT USING "##.####"; inputscale#;
PRINT " Prog Off"; : PRINT USING "######"; progoffset;
PRINT "   Rpm Scale "; : PRINT USING "########"; rpmscale;
PRINT " Rpm Off"; : PRINT USING "###"; rpmoffset;
LOCATE 14, 1
PRINT "Num keys  6 / 4          8 / 2                     T / G         Y / H"
LOCATE 16, 15
PRINT "1 = Set Smooth slope low Rpm!"; "   ESC to Emergency Shutdown";
LOCATE 17, 15
PRINT "2 = Set Timing at TDC  ";
LOCATE 18, 15
PRINT "3 = Set timing  at 8 BTDC";
LOCATE 19, 15
PRINT "4 = Save Timing to fourdata.csv ";
LOCATE 20, 15
PRINT "5 = load Timing from fourdata.csv ";
LOCATE 21, 15
PRINT "6 = Export Timing to Fdd ";
LOCATE 22, 15
PRINT "7 = Import Timing from Fdd ";
LOCATE 23, 15
PRINT "8 = Run At Max ADVANCE  ";
LOCATE 24, 15
PRINT "9 = Initalize Timing Data AT 0 ";
LOCATE 25, 15
PRINT "0 = Turn Off Function Keys ";
LOCATE 26, 15
PRINT "- = Turn On Function Keys ";
a = 1
DO
a = a + 66.7
LINE (a, 21)-(a, 32), 15
LINE (a + 1, 21)-(a + 1, 32), 15
LINE (a, 50)-(a, 58), 15
LINE (a + 1, 50)-(a + 1, 58), 15
LINE (a, 81)-(a, 90), 15
LINE (a + 1, 81)-(a + 1, 90), 15
LINE (a, 129)-(a, 138), 15
LINE (a + 1, 129)-(a + 1, 138), 15
LOOP UNTIL a > 600
RETURN

disablekeys:
FOR i = 1 TO 14
KEY(i) STOP
NEXT
KEY(30) STOP
KEY(31) STOP
RETURN


enablekeys:
FOR i = 1 TO 14
KEY(i) ON
NEXT
KEY(30) ON
KEY(31) ON
ON KEY(1) GOSUB declowrpm
ON KEY(2) GOSUB inclowrpm
ON KEY(3) GOSUB dechighrpm
ON KEY(4) GOSUB inchighrpm
ON KEY(5) GOSUB dechighdeg
ON KEY(6) GOSUB inchighdeg
ON KEY(7) GOSUB decvac
ON KEY(8) GOSUB incvac
ON KEY(9) GOSUB decnospin
ON KEY(10) GOSUB incnospin
ON KEY(11) GOSUB incprogoffset
ON KEY(12) GOSUB decinputscale
ON KEY(13) GOSUB incinputscale
ON KEY(14) GOSUB decprogoffset
ON KEY(30) GOSUB decidlespin
ON KEY(31) GOSUB incidlespin
RETURN

incmr:
mecramp = mecramp + 1
GOTO display
decmr:
mecramp = mecramp - 1
GOTO display

incrs:
rpmscale = rpmscale + 250
GOTO display
decrs:
rpmscale = rpmscale - 250
GOTO display

incro:
rpmoffset = rpmoffset + 1
GOTO display
decro:
rpmoffset = rpmoffset - 1
GOTO display

incrl:
revlimit = revlimit - 100
IF revlimit < 1000 THEN revlimit = 1000
GOTO display
decrl:
revlimit = revlimit + 100
GOTO display

inctrs:
tratescale# = tratescale# + .05
GOTO display
dectrs:
tratescale# = tratescale# - .05
GOTO display


inctrl:
tratelimit = tratelimit + 1
GOTO display
dectrl:
tratelimit = tratelimit - 1
GOTO display

incabs:
absvac! = absvac! + .1
GOTO display
decabs:
absvac! = absvac! - .1
GOTO display

incdc:
donkcold = donkcold + 1
GOTO display
decdc:
donkcold = donkcold - 1
GOTO display


incprogoffset:
progoffset = progoffset + 1
up = 1
RETURN
decprogoffset:
progoffset = progoffset - 1
up = 1
RETURN
incinputscale:
inputscale# = inputscale# + .001
up = 1
RETURN
decinputscale:
inputscale# = inputscale# - .001
up = 1
RETURN

incvac:
vachigh! = vachigh! + .2
IF vac > 20 THEN vac = 20
up = 1
RETURN

decvac:
vachigh! = vachigh! - .2
IF vachigh! < 0 THEN vachigh! = 0
up = 1
RETURN

inclowrpm:
lowrpm = lowrpm + 2
IF lowrpm > 9975 THEN lowrpm = 9975
IF lowrpm >= highrpm THEN highrpm = highrpm + 20
slcal = -1
up = 1
RETURN

declowrpm:
lowrpm = lowrpm - 2
IF lowrpm < 2 THEN lowrpm = 2
slcal = -1
up = 1
RETURN

inchighrpm:
highrpm = highrpm + 20
IF highrpm > 10000 THEN highrpm = 10000
slcal = -1
up = 1
RETURN
dechighrpm:
highrpm = highrpm - 20
IF highrpm <= 20 THEN highrpm = 20
IF highrpm <= lowrpm THEN lowrpm = lowrpm - 20
slcal = -1
up = 1
RETURN

incidlespin:
idlespin = idlespin + 1
slcal = -1
up = 1
RETURN

decidlespin:
idlespin = idlespin - 1
slcal = -1
up = 1
RETURN

inchighdeg:
highdeg! = highdeg! + .1
slcal = -1
up = 1
RETURN

dechighdeg:
highdeg! = highdeg! - .1
slcal = -1
up = 1
RETURN

incnospin:
nospin! = nospin! + .1
highdeg! = highdeg! - .1
slcal = -1
up = 1
RETURN

decnospin:
nospin! = nospin! - .1
highdeg! = highdeg! + .1
slcal = -1
up = 1
RETURN

initdata:
up = 1
INPUT "Are YOU Sure ?", a$
IF a$ <> "Y" OR a$ <> "y" THEN RETURN
OPEN "c:\qb\fourdata.csv" FOR OUTPUT AS #1 LEN = 5009
OPEN "c:\qb\fourcalc.csv" FOR OUTPUT AS #2 LEN = 52
DO UNTIL a% = 10011
WRITE #1, 0
a% = a% + 1
LOOP
a% = 1
WRITE #2, 0, 0, 0, 0, 0, 0
WRITE #2, 0, 0, 0, 0, 0
WRITE #2, 0, 0, 0, 0, 0
WRITE #2, 0, 0, 0, 0, 0
CLOSE #1
CLOSE #2
GOTO starting
RETURN
savedata:
up = 1
OPEN "c:\qb\fourdata.csv" FOR OUTPUT AS #1 LEN = 5009
OPEN "c:\qb\fourcalc.csv" FOR OUTPUT AS #2 LEN = 52
a% = 0
DO UNTIL a% = 10011
WRITE #1, mecadv(a%)
a% = a% + 1
LOOP
WRITE #2, lowrpm, highrpm, highdeg!, nospin!, maxadv, vachigh!
WRITE #2, tratescale#, tratelimit, mecramp, absvac!, idlespin
WRITE #2, inputscale#, progoffset, rpmscale, rpmoffset, donkcold
WRITE #2, timinglight, 0, 0, 0, 0, 0
CLOSE #1
CLOSE #2
GOTO starting
RETURN

exportdata:
up = 1
OPEN "A:\fourdata.csv" FOR OUTPUT AS #1 LEN = 5009
OPEN "A:\fourcalc.csv" FOR OUTPUT AS #2 LEN = 52
a% = 0
DO UNTIL a% = 10011
WRITE #1, mecadv(a%)
a% = a% + 1
LOOP
WRITE #2, lowrpm, highrpm, highdeg!, nospin!, maxadv, vachigh!
WRITE #2, tratescale#, tratelimit, mecramp, absvac!, idlespin
WRITE #2, inputscale#, progoffset, rpmscale, rpmoffset, donkcold
WRITE #2, timinglight, 0, 0, 0, 0, 0
CLOSE #1
CLOSE #2
RETURN

loaddata:
up = 1
OPEN "c:\qb\fourdata.csv" FOR INPUT AS #1
OPEN "c:\qb\fourcalc.csv" FOR INPUT AS #2
a% = 0
DO UNTIL a% = 10011
INPUT #1, mecadv(a%)
a% = a% + 1
LOOP
INPUT #2, lowrpm, highrpm, highdeg!, nospin!, maxadv, vachigh!
INPUT #2, tratescale#, tratelimit, mecramp, absvac!, idlespin
INPUT #2, inputscale#, progoffset, rpmscale, rpmoffset, donkcold
INPUT #2, timinglight
CLOSE #1
CLOSE #2

RETURN

importdata:
up = 1
OPEN "a:\fourdata.csv" FOR INPUT AS #1
OPEN "c:\qb\fourdata.csv" FOR OUTPUT AS #2 LEN = 5009
a% = 0
DO UNTIL a% = 10011
INPUT #1, mecadv(a%)
WRITE #2, mecadv(a%)
a% = a% + 1
LOOP
CLOSE #1
CLOSE #2
OPEN "a:\fourcalc.csv" FOR INPUT AS #1
OPEN "c:\qb\fourcalc.csv" FOR OUTPUT AS #2 LEN = 52
INPUT #1, lowrpm, highrpm, highdeg!, nospin!, maxadv, vachigh!
INPUT #1, tratescale#, tratelimit, mecramp, absvac!, idlespin
INPUT #1, inputscale#, progoffset, rpmscale, rpmoffset, donkcold
INPUT #1, timinglight

WRITE #2, lowrpm, highrpm, highdeg!, nospin!, maxadv, vachigh!
WRITE #2, tratescale#, tratelimit, mecramp, absvac!, idlespin
WRITE #2, inputscale#, programoffset, rpmscale, rpmoffset, donkcold
WRITE #2, timinglight, 0, 0, 0, 0, 0
CLOSE #1
CLOSE #2
RETURN

gettiming:
up = 1
vachigh! = 0
absvac! = 0
a% = 0
DO UNTIL a% = 10011
mecadv(a%) = maxadv
a% = a% + 1
LOOP
GOTO trigger

slopecalc:
up = 1
GOSUB disablekeys
t = t + 2109
degchange# = highdeg!
rpmchange# = (highrpm - lowrpm)
IF degchange# = 0 OR rpmchange# = 0 THEN
incdeg# = 0
GOTO subcalc
END IF
incdeg# = degchange# / rpmchange#
subcalc:
b# = 0: d% = 0
d% = -1
DO
d% = d% + 1
DO
IF d% > highrpm - 1 THEN EXIT DO
IF d% > lowrpm - 2 THEN
b# = b# + incdeg#
mecadv(d%) = b#
END IF
d% = d% + 1
LOOP UNTIL d% > highrpm + 1
IF d% > highrpm - 2 THEN mecadv(d%) = highdeg!
LOOP UNTIL d% = 10011
d% = 0
DO
d% = d% + 1
IF d% <= lowrpm THEN
mecadv(d%) = 0
END IF
LOOP UNTIL d% = lowrpm
d% = 0
FOR d% = 0 TO 10001
mecadv(d%) = mecadv(d%) + nospin!
NEXT
FOR d% = 0 TO 499
mecadv(d%) = idlespin
NEXT
GOSUB enablekeys
GOTO rhealth


slcrunch:
lowrpmcal% = lowrpm
highrpmcal% = highrpm - 1
degchange# = highdeg!
rpmchange% = (highrpmcal% - lowrpmcal%)
IF degchange# = 0 OR rpmchange% = 0 THEN
incdeg! = 0
GOTO slcal
END IF
incdeg# = degchange# / rpmchange%
csl% = 0

slcal:
csl% = csl% + 1
b# = 0
FOR d% = lowrpmcal% TO highrpmcal% STEP incsize%
inc(d%) = b# * incsize%
b# = b# + incdeg#
NEXT
FOR d% = lowrpmcal% TO highrpmcal% STEP incsize%
mecadv(d%) = inc(d%) + nospin!
NEXT
totaldeg! = highdeg! + nospin!
lowrpmcal% = lowrpmcal% + 1
highrpmcal% = highrpmcal% + 1
FOR d% = highrpmcal% TO 10018 STEP incsize%
mecadv(d%) = totaldeg!
NEXT
nosp% = 500 + csl%
lowspin% = lowrpmcal% - (incsize% / 1)
FOR d% = nosp% TO lowspin% STEP incsize%
mecadv(d%) = nospin!
NEXT
FOR d% = csl% - 1 TO 500 STEP incsize%
mecadv(d%) = idlespin
NEXT
GOTO slret


timedist:
up = 1
vachigh! = 0
absvac! = 0
temp! = 0
a% = 1
DO
mecadv(a%) = 0
a% = a% + 1
LOOP UNTIL a% = 10011
GOTO trigger

settiming:
up = 1
vac! = 0
vachigh! = 0
absvac! = 0
temp! = 0
trate# = 0
a% = 1
DO
mecadv(a%) = timinglight
a% = a% + 1
LOOP UNTIL a% = 10011
GOTO trigger

cpucal:
up = 1
maxadv = 90
vac! = 0
vachigh! = 0
absvac! = 0
temp! = 0
mecramp = 100
revstall = .00001
revlimit = 20000
revstop = p = 20000
mecadv(5) = 0
nostartslope = 1

a% = 1
DO
mecadv(a%) = 0
a% = a% + 1
LOOP UNTIL a% = 10011

GOTO trigger

shutdown:
OUT &H378, 255
OUT &H379, 0
CLOSE #1
CLOSE #2
CLOSE #3
END
RETURN

