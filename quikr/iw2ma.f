      subroutine iw2ma(ibuf,ispeed,idir,ihead,jdur)
      implicit none
      integer ispeed,idir,ihead
      integer*2 ibuf(4)
      integer*4 jdur
C
C  IW2MA: build inchworm buffer for MAT
C
C  INPUT:
C     ISPEED: speed, 0=slow or 1=fast
C     IDIR: direction, 0=in or 1=out
C     IHEAD: head, 1 or 2
C     JDUR: move duration, 0 to 65535 (units 40 usecs)
C
C  OUTPUT:
C     IBUF: hollerith buffer holding eight characters for MAT
C
      integer inext,ichmv,ihx2a,ih22a,idum,ibyte
C
      inext=1
      inext=ichmv(ibuf,inext,2h00,1,1)
      inext=ichmv(ibuf,inext,ihx2a(ispeed),2,1)
      inext=ichmv(ibuf,inext,ihx2a(idir),2,1)
      inext=ichmv(ibuf,inext,ihx2a(ihead-1),2,1)
C
      ibyte=jdur/256
c     idum=ichmv(ibyte,2,jdur,3,1)
      inext=ichmv(ibuf,inext,ih22a(ibyte),1,2)
      ibyte=jdur
c     idum=ichmv(ibyte,2,jdur,4,1)
      inext=ichmv(ibuf,inext,ih22a(ibyte),1,2)
C
      return
      end
