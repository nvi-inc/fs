      subroutine ldrivev(name,lsor,indxtp)
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
      call fs_get_reccpu(reccpu,indxtp)
      if(reccpu(indxtp).eq.117) then
         nch=ichmv_ch(ib,nch,"mvme117")
      else if(reccpu(indxtp).eq.162) then
         nch=ichmv_ch(ib,nch,"mvme162")
      endif
c
      nch=mcoma(ib,nch)
      call fs_get_ihdmndel(ihdmndel,indxtp)
      nch = nch + ib2as(ihdmndel(indxtp),ib,nch,o'100000'+6)
c
      nch=mcoma(ib,nch)
      call fs_get_motorv(motorv,indxtp)
      nch=nch+ir2as(motorv(indxtp),ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_inscint(inscint,indxtp)
      nch=nch+ir2as(inscint(indxtp),ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_inscsl(inscsl,indxtp)
      nch=nch+ir2as(inscsl(indxtp),ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_outscint(outscint,indxtp)
      nch=nch+ir2as(outscint(indxtp),ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_outscsl(outscsl,indxtp)
      nch=nch+ir2as(outscsl(indxtp),ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_itpthick(itpthick,indxtp)
      nch=nch+ib2as(itpthick(indxtp),ib,nch,z'8000'+10)
c
      nch=mcoma(ib,nch)
      call fs_get_wrvolt(wrvolt,indxtp)
      nch=nch+ir2as(wrvolt(indxtp),ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_capstan(capstan,indxtp)
      nch=nch+ib2as(capstan(indxtp),ib,nch,z'8000'+10)
c
      call logit3(ib,nch-1,lsor)
      nch=1
      nch=ichmv_ch(ib,nch,name)
      nch=ichmv_ch(ib,nch,'3')
c
      nch=mcoma(ib,nch)
      call fs_get_motorv2(motorv2,indxtp)
      nch=nch+ir2as(motorv2(indxtp),ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_itpthick2(itpthick2,indxtp)
      nch=nch+ib2as(itpthick2(indxtp),ib,nch,z'8000'+10)
c
      nch=mcoma(ib,nch)
      call fs_get_wrvolt2(wrvolt2,indxtp)
      nch=nch+ir2as(wrvolt2(indxtp),ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_wrvolt4(wrvolt4,indxtp)
      nch=nch+ir2as(wrvolt4(indxtp),ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_wrvolt42(wrvolt42,indxtp)
      nch=nch+ir2as(wrvolt42(indxtp),ib,nch,12,3)
c
      call logit3(ib,nch-1,lsor)
c
      return
      end





