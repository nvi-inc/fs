      real*4 FUNCTION SPEED(ICODE,is)

C   SPEED returns the actual tape speed in feet per second
C   Restrictions: Single digit for fan/in factor, from the
C      mode name. Channel bandwidth for BBC 1 is used.
C      Speed is scaled via channel bandwidth and
c      bit density from 135.00 ips and 333333 bpi.
C
C History
C 951213 nrv Modified to use bit density and other factors.

      INCLUDE 'skparm.ftni'
      INCLUDE 'freqs.ftni'
      INCLUDE 'statn.ftni'
C
C  INPUT:
      integer icode ! code index in common
      integer is ! station index
C
C  OUTPUT:
C     SPEED - tape speed, fps
C
C  LOCAL:
      integer n,ix,iy
      real fac
      integer iscn_ch,ias2b
C
C
      fac=1.0
      ix = iscn_ch(lmode(1,is,icode),1,8,'1:') 
      iy = iscn_ch(lmode(1,is,icode),1,8,':1') 
      if (ix.ne.0) then ! possible fan-out
        n=ias2b(lmode(1,is,icode),ix+2,1)
        if (n.gt.0) fac=1/real(n)
      else if (iy.ne.0) then ! possible fan-in
        n=ias2b(lmode(1,is,icode),iy+2,1)
        if (n.gt.0) fac=n
      endif
      SPEED = 135.0 * (vcband(1,is,icode)/2.0)
     .              * 33333.0/bitdens(is)
     .              * fac
      speed=speed/12.0 ! convert to fps
C
      RETURN
      END
