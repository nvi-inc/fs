* CTLPO.CTL control file for AQUIR
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
*          -1 => self suspend after entering command, expect a GO,AQUIR
*                in order to continue
*
*          for FIVPT, ONOFF, and PEAKF waits:
*           0 -> don't execute this command
*          >0 -> wait that many minutes for FIVPT, ONOFF, or PEAKF program
*                to complete, OF'ing them if they aren't done
*
*   Elevations: degrees 
* 
*   Source Names:  10 characters
* 
*   Right Ascension: hhmmss.s 
* 
*   Declination: ddmmss 
* 
*   Epoch:  yyyy.y
* 
*  First data record: 
* 
*   Setup procedure, Setup wait, Terminate Procedure, Terminate wait, 
* 
*                    Upper elevation Limit, ONSOURCE Wait,
* 
*                    Amount to lead source when calculating what's up 
*
*         Sources outside elevation limits are considered 'down'
*
   INITP  -1 INITP -2 91 180 180
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
*          FIVPT wait, ONOFF wait, PEAKF wait,
*
*          Postob procedure, Postob Wait
*
*  The nominal maximum number of sources is 200, but it may vary.
*  If there are too many in the file, the program will print a
*  message with the current number.
*
 3C84       031948.16 +413042.1 2000 PREP    -1 10  0  0 POSTP    -2
 3C123      043704.17 +294015.1 2000 PREP    -1 10  5  0 POSTP    -2
 0521M365   052257.98 -362730.9 2000 PREP    -1 10  5  0 POSTP    -2
 TAURUSA    053432.   +220058   2000 PREP    -1 10  5  0 POSTP    -2
 ORIONA     053516.   -052322.  2000 PREP    -1 10  5  0 POSTP    -2
 3C147      054236.14 +495107.2 2000 PREP    -1 10  5  0 POSTP    -2
 0552P398   055530.8  +394849.  2000 PREP    -1 10  0  0 POSTP    -2
 3C161      062710.10 -055304.8 2000 PREP    -1 10  5  0 POSTP    -2
 OJ287      085448.9  +200631.  2000 PREP    -1 10  0  0 POSTP    -2
 3C218      091805.7  -120544.  2000 PREP    -1 10  5  0 POSTP    -2
 4c39d25    092703.0  +390221.  2000 PREP    -1 10  0  0 POSTP    -2
 3C273B     122906.70 +020308.6 2000 PREP    -1 10  0  0 POSTP    -2
 VIRGOA     123049.42 +122328.0 2000 PREP    -1 10  5  0 POSTP    -2
 3C279      125611.17 -054721.5 2000 PREP    -1 10  0  0 POSTP    -2
 3C286      133108.29 +303033.0 2000 PREP    -1 10  5  0 POSTP    -2
 3C295      141120.65 +521209.1 2000 PREP    -1 10  5  0 POSTP    -2
 3C345      164258.81 +394837.0 2000 PREP    -1 10  0  0 POSTP    -2
 3C348      165108.2  +045933.  2000 PREP    -1 10  5  0 POSTP    -2
 3C353      172028.2  -005848.  2000 PREP    -1 10  5  0 POSTP    -2
 3C380      182931.72 +484447.0 2000 PREP    -1 10  5  0 POSTP    -2
 3C391      184923.4  -005529.  2000 PREP    -1 10  5  0 POSTP    -2
 1921M293   192451.06 -291430.1 2000 PREP    -1 10  0  0 POSTP    -2
 CYGNUSA    195928.4  +404402.  2000 PREP    -1 10  5  0 POSTP    -2
 2134P004   213638.59 +004154.2 2000 PREP    -1 10  0  0 POSTP    -2
 3C454D3    225357.75 +160853.6 2000 PREP    -1 10  0  0 POSTP    -2
 CASA       232324.8  +584859.  2000 PREP    -1 10  5  0 POSTP    -2
 SUN        000000.    000000   2000 PRESUN  -1 10  5  0 POSTSUN  -1
 MOON       000000.    000000   2000 PREMOON -1 10  5  0 POSTMOON -2
