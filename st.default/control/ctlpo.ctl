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
 3C84       031629.54  411951.7 1950 PREP    -1 10  0  0 POSTP    -2
 3C123      043355.2   293414.  1950 PREP    -1 10  5  0 POSTP    -2
 0521M365   052113.2  -363019.  1950 PREP    -1 10  5  0 POSTP    -2
 TAURUSA    053131     215900   1950 PREP    -1 10  5  0 POSTP    -2
 ORIONA     053249.   -052515   1950 PREP    -1 10  5  0 POSTP    -2
 3C147      053843.52 +494942.2 1950 PREP    -1 10  5  0 POSTP    -2
 0552P398   055201.4   394822   1950 PREP    -1 10  0  0 POSTP    -2
 3C161      062443.2  -055112.  1950 PREP    -1 10  5  0 POSTP    -2
 OJ287      085157.2   201759   1950 PREP    -1 10  0  0 POSTP    -2
 3C218      091541.2  -115305.  1950 PREP    -1 10  5  0 POSTP    -2
 4c39d25    092355.3  +391524.  1950 PREP    -1 10  0  0 POSTP    -2
 3C273B     122633.25  021943.5 1950 PREP    -1 10  0  0 POSTP    -2
 VIRGOA     122817.57  124002.0 1950 PREP    -1 10  5  0 POSTP    -2
 3C279      125335.83 -053107.9 1950 PREP    -1 10  0  0 POSTP    -2
 3C286      132849.66 +304558.7 1950 PREP    -1 10  5  0 POSTP    -2
 3C295      140933.5  +522613.  1950 PREP    -1 10  5  0 POSTP    -2
 3C345      164117.64  395411.0 1950 PREP    -1 10  0  0 POSTP    -2
 3C348      164840.0  +050435.  1950 PREP    -1 10  5  0 POSTP    -2
 3C353      171753.3  -005550.  1950 PREP    -1 10  5  0 POSTP    -2
 3C380      182813.47 +484241.0 1950 PREP    -1 10  5  0 POSTP    -2
 3C391      184648.5  -005858.  1950 PREP    -1 10  5  0 POSTP    -2
 1921M293   192142.18 -292024.9 1950 PREP    -1 10  0  0 POSTP    -2
 CYGNUSA    195744.4   403546   1950 PREP    -1 10  5  0 POSTP    -2
 2134P004   213405.23  002825.0 1950 PREP    -1 10  0  0 POSTP    -2
 3C454D3    225129.53 +155254.2 1950 PREP    -1 10  0  0 POSTP    -2
 CASA       232109.    583230   1950 PREP    -1 10  5  0 POSTP    -2
*SUN        000000.    000000   1950 PRESUN  -1 10  5  0 POSTSUN  -1
*MOON       000000.    000000   1950 PREMOON -1 10  5  0 POSTMOON -2
