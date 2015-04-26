REM ********** Ver 8 *** 310 CDS
REM 12/6/2007  7/2/2008
REM Pluse Generator and Reciver program for setting up program timing....
REM Rpm will self correct just give a little time!
REM 1/8/2006  14/05/2007
REM CHECK input loops for 0 and 1 output from xover cable first.
CLEAR , , 500: ON ERROR GOTO 0: OPTION BASE 0
SCREEN 12
CLS
DEFLNG A-Z
COLOR 15
TIMER ON
ON TIMER(1) GOSUB health
'OPEN "c:\qb\logs\cpu.csv" FOR OUTPUT AS #1 LEN = 11000
'WRITE #1, "Index", "RPM", "Deg adv"
DIM x1(1011)
DIM x2(1011)
DIM tq(5011) AS LONG
DIM yq(5011) AS LONG
' 86500 old pc 440000  438520 310 cds=295300
rpmcal = 295300
' cds=4400000
tickcal = 6000000
rhz# = 50
avestep% = 1
tick = 10000
GOSUB enablekeys
GOSUB menu

starting:
REM 192 128 64 0 =g2 198 134 70 6 =game  135 199 7 71=TOSHIBA 135 71 199
ta& = 0
ya& = 0
REM t& > must be smaller than the rpm stall
trigger:
OUT 888, 0
DO
t& = t& + 1
IF t& > 100000 THEN EXIT DO
LOOP UNTIL 135 = INP(&H379)
OUT 888, 1
DO
y& = y& + 1
IF y& > tick THEN EXIT DO
LOOP UNTIL 199 = INP(&H379)
tt& = t& + y&
rpm& = ((rpmcal / tt&) * 30)
tickdeg# = tt& / 180
hz# = rpm& / 30
deg# = t& / tickdeg#
IF t& > 100000 THEN
deg# = 360
END IF
rhz# = 1 + rhz#
t& = 0: y& = 0
GOTO trigger

health:
a$ = INKEY$
IF a$ = CHR$(27) THEN END
LOCATE 12, 30
PRINT USING "######.#"; rpm&;
LOCATE 14, 30
PRINT USING "######.#"; deg#;
LOCATE 16, 30
PRINT USING "######.#"; tickdeg#;
LOCATE 18, 31
PRINT USING "######.##"; hz#;
LOCATE 20, 31
PRINT USING "######.##"; rhz#;
IF up = 0 THEN GOTO noadjust
IF rhz# > hz# + .001 THEN rpmcal = rpmcal + 100
IF rhz# < hz# - .001 THEN rpmcal = rpmcal - 100
noadjust:
up = 1
LINE (rpm& / 16, 35)-(640, 35), 0
LINE (1, 35)-(rpm& / 16, 35), 15
LINE (rpm& / 16, 36)-(640, 36), 0
LINE (1, 36)-(rpm& / 16, 36), 15
LINE (deg# * 3.3, 66)-(640, 66), 0
LINE (1, 66)-(deg# * 3.3, 66), 14
LINE (deg# * 3.3, 67)-(640, 67), 0
LINE (1, 67)-(deg# * 3.3, 67), 14
LINE (deg# * 3.3, 68)-(640, 68), 0
LINE (1, 68)-(deg# * 3.3, 68), 14
rhz# = 0
RETURN

menu:
LOCATE 2, 1
PRINT "0      1       2       3       4       5      6       7       8       9      10";
LOCATE 6, 1
PRINT "0...1   2   3   4   5   6   7   8...9....10  11  12  13  14  15  16  17  18#####";
LOCATE 8, 1
PRINT "F1   F2   F3    F4    F5    F6    F7    F8    F9   F10   F11   F12";
LOCATE 9, 1
PRINT "INC  DEC  500  1000  2000  3000  4000  5000  6000  7000  8000  9500";
LOCATE 12, 20
PRINT " Rpm    ";
LOCATE 14, 20
PRINT " Timing ";
LOCATE 16, 20
PRINT " Tickdeg";
LOCATE 18, 20
PRINT " Hz Calc";
LOCATE 20, 20
PRINT " Hz Real";
a = 0
b = 10
DO
IF b = 20 THEN b = 0
b = b + 10
LINE (a, 36)-(a, 36 + b), 15
LINE (a + 1, 36)-(a + 1, 36 + b), 15
a = a + 31
LOOP UNTIL a > 640
a = 0: b = 5
DO
IF b = 10 THEN b = 0
b = b + 5
LINE (a, 68)-(a, 78), 14
LINE (a + 1, 68)-(a + 1, 78), 14
a = a + 33
LOOP UNTIL a > 610
RETURN

enablekeys:
FOR i = 1 TO 14
KEY(i) ON
NEXT
KEY(30) ON
KEY(31) ON
ON KEY(1) GOSUB decrpm
ON KEY(2) GOSUB incrpm
ON KEY(3) GOSUB rpm1
ON KEY(4) GOSUB rpm2
ON KEY(5) GOSUB rpm3
ON KEY(6) GOSUB rpm4
ON KEY(7) GOSUB rpm5
ON KEY(8) GOSUB rpm6
ON KEY(9) GOSUB rpm7
ON KEY(10) GOSUB rpm8
ON KEY(11) GOSUB timoff
ON KEY(14) GOSUB timon
ON KEY(30) GOSUB rpm9
ON KEY(31) GOSUB rpm10
RETURN
timoff:
TIMER STOP
LOCATE 20, 30
PRINT "Timer Stuffed Please Standby ";
RETURN
timon:
TIMER ON
LOCATE 20, 30
PRINT "Timer OK                     ";

decrpm:
setrpm = setrpm - 100
IF setrpm < 100 THEN setrpm = 100
tick = 1 / ((1 / tickcal) / (1 / setrpm))
RETURN
incrpm:
setrpm = setrpm + 100
IF setrpm > 25000 THEN setrpm = 25000
tick = 1 / ((1 / tickcal) / (1 / setrpm))
RETURN
rpm1:
setrpm = 500
tick = 1 / ((1 / tickcal) / (1 / setrpm))
RETURN
rpm2:
setrpm = 1000
tick = 1 / ((1 / tickcal) / (1 / setrpm))
RETURN
rpm3:
setrpm = 2000
tick = 1 / ((1 / tickcal) / (1 / setrpm))
RETURN
rpm4:
setrpm = 3000
tick = 1 / ((1 / tickcal) / (1 / setrpm))
RETURN
rpm5:
setrpm = 4000
tick = 1 / ((1 / tickcal) / (1 / setrpm))
RETURN
rpm6:
setrpm = 5000
tick = 1 / ((1 / tickcal) / (1 / setrpm))
RETURN
rpm7:
setrpm = 6000
tick = 1 / ((1 / tickcal) / (1 / setrpm))
RETURN
rpm8:
setrpm = 7000
tick = 1 / ((1 / tickcal) / (1 / setrpm))
RETURN
rpm9:
setrpm = 8000
tick = 1 / ((1 / tickcal) / (1 / setrpm))
RETURN
rpm10:
setrpm = 9500
tick = 1 / ((1 / tickcal) / (1 / setrpm))
RETURN

logging:

t& = 5000
y& = 5000

g = 0
DO
g = g + 1
c = c + 1
WRITE #1, c, x1(g), x2(g)
LOOP UNTIL g = 5000
IF c > 20000 THEN
CLOSE #1
GOSUB extract
CLOSE #1
CLOSE #2
END

END IF
g = 0
RETURN

extract:

OPEN "c:\qb\cpu.csv" FOR INPUT AS #1 LEN = 5000
OPEN "c:\qb\cput.csv" FOR OUTPUT AS #2 LEN = 5000


     INPUT #1, a$, a$, a$
     INPUT #1, index, rpm&, deg
     IF rpm& / 2 = 0 THEN GOTO goloop
     rpm& = rpm& - 1

goloop:
     DO WHILE NOT EOF(1)
    
     INPUT #1, index1, rpm1, deg1
     IF rpm1 > rpm& + 2 THEN
    
     WRITE #2, rpm&, deg1
     rpm& = rpm1
     INPUT #1, index, rpm&, deg1
     PRINT rpm&; deg1
     END IF

     LOOP

     CLOSE #1
     CLOSE #2
     GOSUB convert
RETURN

convert:
        ERASE x1
        OPEN "c:\qb\cput.csv" FOR INPUT AS #1 LEN = 5000
        OPEN "c:\qb\rpmdata.csv" FOR OUTPUT AS #2 LEN = 5000
        INPUT #1, aa, bb

        DO WHILE NOT EOF(1)
        INPUT #1, rpm, deg
        IF x1(rpm) <> 0 THEN
        degtemp = ((x1(rpm) + deg) / 2) / 5
        x1(rpm) = degtemp
        
        END IF
       
        IF x1(rpm) = 0 THEN
        x1(rpm) = deg / 5
        END IF

        LOOP

        CLOSE #1
        a = 0
        DO
        a = a + 1
        WRITE #2, a * 2, x1(a), 7
        LOOP UNTIL a = 5000
        CLOSE #2

RETURN

ave:
tq(1) = t&
FOR i% = avestep% TO 1 STEP -1
tq(i% + 1) = tq(i%)
NEXT
ts# = 0
FOR i% = 1 TO avestep%
ts# = ts# + tq(i%)
NEXT
yq(1) = y&
FOR i% = avestep% TO 1 STEP -1
yq(i% + 1) = yq(i%)
NEXT
ys# = 0
FOR i% = 1 TO avestep%
ys# = ys# + yq(i%)
NEXT
ta& = ts# / avestep%
ya& = ys# / avestep%
tt& = tt& + 3.9
noave:

