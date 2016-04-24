      subroutine ldrivem(name,lsor,indxtp)
      integer indxtp,lsor
      character*(*) name
c
      integer nch
      integer*2 ib(50)
c
      include '../include/fscom.i'
c
      nch=1
      nch=ichmv_ch(ib,nch,name)
      nch=ichmv_ch(ib,nch,'1')
c
      call ldriveall(ib,nch,indxtp)
c
      call logit3(ib,nch-1,lsor)
      nch=1
      nch=ichmv_ch(ib,nch,name)
      nch=ichmv_ch(ib,nch,'2')
c
      nch=mcoma(ib,nch)
      nch = nch + ib2as(iacttp(indxtp),ib,nch,z'8003')
      call logit3(ib,nch-1,lsor)
c
      return
      end





