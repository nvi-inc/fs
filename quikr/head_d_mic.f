      subroutine head_d_mic(ihead,micmov,tmove,ispdhd,ip)
      integer ihead,ispdhd,ip(5)
      real*4 tmove
      real*4 micmov,fast,slow
C
C  HEAD_D_MIC: move a head a delta in microns
C
C  INPUT:
C     IHEAD: Head index 1 or 2
C     MICMOV: distance to move
C
C  OUTPUT:
C     TMOVE - seconds the head moved for
C     IP - Field System Parameters
C     IP(3) = 0 if no errors
C
      include '../include/fscom.i'
C
      integer idir
      real*4 timmov
C
      if(micmov.lt.0) then
        idir=1   ! out, burleighs call it forward
        fast=fastfw(ihead)
        slow=slowfw(ihead)
      else
        idir=0   ! in, burleighs call it reverse
        fast=fastrv(ihead)
        slow=slowrv(ihead)
      endif
C
      timmov=abs(micmov)/slow
      ispdhd=0
      if(timmov.gt.1.0.or..not.kiwslw_fs) then
        timmov=abs(micmov)/fast
        ispdhd=1
      endif
C
      tmove=min(timmov,1.0)
      call head_move(ihead,idir,ispdhd,tmove,ip)
      return
      end
