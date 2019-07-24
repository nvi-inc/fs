      subroutine unpsk(ibufsk,iskbw,lsn,lst,iyr,idayr,ihr,min,isc,idur, 
     .nstn)
C 
C UNPSK -  unpacks the record found in IBUFSK and puts the data into
C           the output variables. 
C 
C  INPUT: 
C 
      integer*2 ibufsk(1) 
C      - buffer holding the schedule entry
C     ISKBW - length of the record in IBUFSK IN WORDS 
C 
C 
C  OUTPUT:
C 
      integer*2 lsn(1),lpre(3),lmid(3),lst(1),icb(10)
      integer*2 lpst(3) 
      dimension ift(10),ipas(10),ldir(10) 
      double precision ut,gst 
C     LSN - source name 
C     LPRE - pre-obs proc 
C     LMID - mid-obs proc 
C     LST - station IDs 
C     ICB - cable wrap
C     IYR, IHR, MIN, ISC - start time of obs 
C     IDUR - duration 
C     LPST - post-obs proc
C     ICAL - set-up time
C     LFRQ - frequency code 
C     IPAS - pass number
C     LDIR - direction of tape motion 
C     IFT - footage counter at start
C     NSTN - number of stations in LST
C     MJD - modified Julian date
C     UT - UT of start
C     GST - GST of start
C     KERR   - Error returned non-zero if problems. 
C 
C 
C   COMMON BLOCKS USED
C 
C 
C     CALLING SUBROUTINES: UTILITY FOR SKED, DRUDG
C 
C 
C  LOCAL VARIABLES
C 
      double precision st0,frac 
C                    - for GST and SIDTM calculations 
C 
C  PROGRAMMER: NRV
C     LAST MODIFIED:  820422
C 
C 
C     1. We decode all of the entries in the buffer.
C     **CAUTION** No error checking is done.  It is assumed 
C                 that the schedule entries were written by 
C                 SKED originally and so should not have to 
C                 be checked. 
C     The format of the entries is the following:
C
C source cal code preob start duration midob idle postob scscsc... pdfoot ...
C     Example:
C     3C84      120 SX2B PREOB 800923120000  780 MIDOB   0 POSTOB K-F-G-OW 1F0000 1F0000 1F0000 1F0000
C*********NOTE: idle is decoded but not returned ****************
C     where all items are not restricted to specific columns.
C
      kerr = 0
      ich = 1
      iskbw2=iskbw*2
      call gtfld(ibufsk,ich,iskbw2,ic1,ic2)
      call ifill_ch(lsn,1,8,' ')
      call ichmv(lsn,1,ibufsk,ic1,min0(ic2-ic1+1,8))
      call gtfld(ibufsk,ich,iskbw2,ic1,ic2)
      ical = ias2b(ibufsk,ic1,ic2-ic1+1)
      call gtfld(ibufsk,ich,iskbw2,ic1,ic2)
      call ichmv(lfrq,1,ibufsk,ic1,2)
      call gtfld(ibufsk,ich,iskbw2,ic1,ic2)
      call ifill_ch(lpre,1,6,' ')
      call ichmv(lpre,1,ibufsk,ic1,ic2-ic1+1)
      call gtfld(ibufsk,ich,iskbw2,ic1,ic2)
      iyr = ias2b(ibufsk,ic1,2)
      idayr = ias2b(ibufsk,ic1+2,3)
      ihr = ias2b(ibufsk,ic1+5,2)
      min = ias2b(ibufsk,ic1+7,2)
      isc = ias2b(ibufsk,ic1+9,2)
      mjd = julda(1,idayr,iyr)
      ut = ihr*3600.d0+min*60.d0+isc
      call sidtm(mjd,st0,frac)
      gst = dmod(st0 + ut*frac, 2.0d0*10)
      call gtfld(ibufsk,ich,iskbw2,ic1,ic2)
      idur = ias2b(ibufsk,ic1,ic2-ic1+1)
      call gtfld(ibufsk,ich,iskbw2,ic1,ic2)
      call ifill_ch(lmid,1,6,' ')
      call ichmv(lmid,1,ibufsk,ic1,ic2-ic1+1)
      call gtfld(ibufsk,ich,iskbw2,ic1,ic2)
      idle = ias2b(ibufsk,ic1,ic2-ic1+1)
      call gtfld(ibufsk,ich,iskbw2,ic1,ic2)
      call ifill_ch(lpst,1,6,' ')
      call ichmv(lpst,1,ibufsk,ic1,ic2-ic1+1)
      call gtfld(ibufsk,ich,iskbw2,ic1,ic2)
C
      do i=1,10
        if ((i-1)*2+ic1.gt.ic2) goto 111
        call char2hol('  ',lst,(i-1)*2+1,i*2)
        call ichmv(lst(i),1,ibufsk,ic1+(i-1)*2,1)
        call char2hol('  ',icb,(i-1)*2+1,i*2)
        call ichmv(icb(i),1,ibufsk,ic1+1+(i-1)*2,1)
      end do
C
111   nstn= i-1
C
      do i=1,nstn
        call gtfld(ibufsk,ich,iskbw2,ic1,ic2)
        ipas(i) = ias2b(ibufsk,ic1,1)
        call char2hol('  ',ldir,(i-1)*2+1,i*2)
        call ichmv(ldir(i),1,ibufsk,ic1+1,1)
        ift(i) = ias2b(ibufsk,ic1+2,4)
      end do
C
      return
      end
