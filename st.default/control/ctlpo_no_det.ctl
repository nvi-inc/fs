* ctlpo.ctl control file for aquir
*
*  This file is free format with blanks as delimiters. Completely
*  blank lines ans lines with a star '*' in column 1 are ignored.
*
*  Data formats:
*
*   Procedure names:  12 character Field System procedure or command
*                     name.
*
*   Waits: minutes for corresponding procedure to complete
*          maximum of 32767
*          -2 => don't execute this procedure, its just a place holder
*          -1 => self suspend after entering command, expect an rte_go aquir
*                in order to continue
*
*          for fivpt, onoff, and peakf waits:
*           0 -> don't execute this command
*          >0 -> wait that many minutes for fivpt, onoff, or peakf program
*                to complete, brk'ing them if they aren't done
*
*   Elevations: degrees
*
*   Source names:  10 characters
*
*   Right Ascension: hhmmss.s
*
*   Declination: ddmmss
*
*   Epoch:  yyyy.y
*
*  First data record:
*
*   Setup procedure, Setup wait, Terminate procedure, Terminate wait,
*
*                    Upper elevation limit, Onsource wait,
*
*                    Amount to lead source when calculating what's up
*
*         Sources outside elevation limits are considered 'down'
*
   initp  -1 initp -2 91 180 180
*
* Elevation mask for lower elvation limit: AZ EL AZ EL ... AZ
* may contain multiple lines, an incomplete line ends with an EL
*
   0 10 360
*
*  Source records:
*
*    Name, R.A., Dec., Epoch, Preob procedure, Preob wait,
*
*          fivpt wait, onoff wait, peakf wait,
*
*          Postob procedure, Postob wait
*
*  The nominal maximum number of sources is 200, but it may vary.
*  If there are too many in the file, the program will print a
*  message with the current number.
*
 3c84       031948.16 +413042.1 2000 prep    -1 10  0  0 postp    -2
 3c123      043704.17 +294015.1 2000 prep    -1 10  5  0 postp    -2
 0521m365   052257.98 -362730.9 2000 prep    -1 10  5  0 postp    -2
 taurusa    053432.   +220058   2000 prep    -1 10  5  0 postp    -2
 oriona     053516.   -052322.  2000 prep    -1 10  5  0 postp    -2
 3c147      054236.14 +495107.2 2000 prep    -1 10  5  0 postp    -2
 0552p398   055530.8  +394849.  2000 prep    -1 10  0  0 postp    -2
 3c161      062710.10 -055304.8 2000 prep    -1 10  5  0 postp    -2
 oj287      085448.9  +200631.  2000 prep    -1 10  0  0 postp    -2
 3c218      091805.7  -120544.  2000 prep    -1 10  5  0 postp    -2
 4c39d25    092703.0  +390221.  2000 prep    -1 10  0  0 postp    -2
 3c273b     122906.70 +020308.6 2000 prep    -1 10  0  0 postp    -2
 virgoa     123049.42 +122328.0 2000 prep    -1 10  5  0 postp    -2
 3c279      125611.17 -054721.5 2000 prep    -1 10  0  0 postp    -2
 3c286      133108.29 +303033.0 2000 prep    -1 10  5  0 postp    -2
 3c295      141120.65 +521209.1 2000 prep    -1 10  5  0 postp    -2
 3c345      164258.81 +394837.0 2000 prep    -1 10  0  0 postp    -2
 3c348      165108.2  +045933.  2000 prep    -1 10  5  0 postp    -2
 3c353      172028.2  -005848.  2000 prep    -1 10  5  0 postp    -2
 3c380      182931.72 +484447.0 2000 prep    -1 10  5  0 postp    -2
 3c391      184923.4  -005529.  2000 prep    -1 10  5  0 postp    -2
 1921m293   192451.06 -291430.1 2000 prep    -1 10  0  0 postp    -2
 cygnusa    195928.4  +404402.  2000 prep    -1 10  5  0 postp    -2
 2134p004   213638.59 +004154.2 2000 prep    -1 10  0  0 postp    -2
 3c454d3    225357.75 +160853.6 2000 prep    -1 10  0  0 postp    -2
 casa       232324.8  +584859.  2000 prep    -1 10  5  0 postp    -2
*sun        000000.    000000   2000 presun  -1 10  5  0 postsun  -1
*moon       000000.    000000   2000 premoon -1 10  5  0 postmoon -2
