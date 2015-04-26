REM 26/4/2015 not sure if is the right prog to setup pcset.bas
REM 1/8/2006  14/05/2007
REM CHECK input loops
CLEAR , , 500
SCREEN 12

CLS
DEFLNG A-Z
COLOR 15
ON ERROR GOTO 0
TIMER ON
ON TIMER(1) GOSUB health
'OPEN "c:\qb\logs\cpu.csv" FOR OUTPUT AS #1 LEN = 11000
'WRITE #1, "Index", "RPM", "Deg adv"
DIM x1(1011)
DIM x2(1011)
DIM tq(5011) AS LONG
DIM yq(5011) AS LONG
GOSUB menu
'86500 old pc 440000
rpmcal = 490000
rhz# = 50
avestep% = 1
starting:
REM 192 128 64 0 =g2 198 134 70 6 =game
ta& = 0
ya& = 0
trigger:
DO
t& = t& + 1
LOOP UNTIL 192 = INP(&H379)
DO
d& = d& + 1
LOOP UNTIL 128 = INP(&H379)
DO
y& = y& + 1
LOOP UNTIL 64 = INP(&H379)
DO
e& = e& + 1
LOOP UNTIL 0 = INP(&H379)
ta& = t& + d&
ya& = y& + e&
IF t& > 1200000 OR y& > 1200000 THEN GOTO starting
tt& = ta& + ya&
rpm! = ((rpmcal / tt&) * 30)
tickdeg# = tt& / 180
hz# = rpm! / 30
deg# = y& / tickdeg#
rhz# = 1 + rhz#
d& = 0: e& = 0: t& = 0: y& = 0
GOTO trigger
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


health:
tt& = tt& + 1
a$ = INKEY$
IF a$ = CHR$(27) THEN END

LOCATE 2, 10
PRINT rpm!;
LOCATE 4, 10
PRINT USING "######.##"; deg#;
LOCATE 8, 10
PRINT USING "######.##"; tickdeg#;
LOCATE 10, 10
PRINT USING "######.###"; hz#;
LOCATE 12, 10
PRINT USING "######.###"; rhz#;
LINE (rpm! / 17, 35)-(640, 35), 0
LINE (1, 35)-(rpm! / 17, 35), 15
LINE (rpm! / 17, 36)-(640, 36), 0
LINE (1, 36)-(rpm! / 17, 36), 15
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
PRINT " RPM    ";
LOCATE 4, 1
PRINT " Timing ";
LOCATE 6, 1
PRINT "0...1   2   3   4   5   6   7   8...9....10  11  12  13  14  15  16  17  18";
LOCATE 8, 1
PRINT " Tickdeg";
LOCATE 10, 1
PRINT " Hz Calc";
LOCATE 12, 1
PRINT " Hz Real";
a = 0: b = 5
DO
IF b = 10 THEN b = 0
b = b + 5
LINE (a, 36)-(a, 36 + b), 15
LINE (a + 1, 36)-(a + 1, 36 + b), 15
a = a + 30
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

REM spare
LOCATE 12, 20
PRINT USING "######.#############"; 1 / rhz#;

LOCATE 14, 10
PRINT 1 / ((1 / rpmcal) / (1 / rhz#));
PRINT 1 / ((1 / rpmcal) / (1 / 1024));

LINE (tickdeg# * 10, 100)-(640, 100), 0
LINE (1, 100)-(tickdeg# * 10, 100), 13
LINE (hz# * 2.5, 130)-(640, 130), 0
LINE (1, 130)-(hz# * 2.5, 130), 13
LINE (rhz# * 2.4, 160)-(640, 160), 0
LINE (1, 160)-(rhz# * 2.4, 160), 13




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
     INPUT #1, index, rpm!, deg
     IF rpm! / 2 = 0 THEN GOTO goloop
     rpm! = rpm! - 1

goloop:
     DO WHILE NOT EOF(1)
    
     INPUT #1, index1, rpm1, deg1
     IF rpm1 > rpm! + 2 THEN
    
     WRITE #2, rpm!, deg1
     rpm! = rpm1
     INPUT #1, index, rpm!, deg1
     PRINT rpm!; deg1
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

