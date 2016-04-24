      subroutine lhead(name,lsor,indxtp)
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
      nch=ichmv_ch(ib,nch,'0')
c
      do i=1,4
        nch=mcoma(ib,nch)
        if (i.eq.1) then
           call fs_get_wrhd_fs(wrhd_fs,indxtp)
          idum=wrhd_fs(indxtp)
        else if(i.eq.2) then
           call fs_get_rdhd_fs(rdhd_fs,indxtp)
          idum=rdhd_fs(indxtp)
        else if(i.eq.3) then
          idum=rpro_fs(indxtp)
        else
          idum=rpdt_fs(indxtp)
        endif
        if(idum.eq.0) then
          nch=ichmv_ch(ib,nch,'all')
        else if(idum.eq.1) then
          nch=ichmv_ch(ib,nch,'odd')
        else if(idum.eq.2) then ! no else so illegal value is blank
          nch=ichmv_ch(ib,nch,'even')
        endif
      enddo
c
      nch=mcoma(ib,nch)
      if(kadapt_fs(indxtp)) then
        nch=ichmv_ch(ib,nch,'adaptive')
      else
        nch=ichmv_ch(ib,nch,'fixed')
      endif
c
      nch=mcoma(ib,nch)
      if(kiwslw_fs(indxtp)) then
        nch=ichmv_ch(ib,nch,'yes')
      else
        nch=ichmv_ch(ib,nch,'no')
      endif
c
      nch=mcoma(ib,nch)
      nch=nch+ir2as(lvbosc_fs(indxtp),ib,nch,6,4)
c
      nch=mcoma(ib,nch)
      nch=nch+ib2as(ilvtl_fs(indxtp),ib,nch,o'100000'+5)
      call logit3(ib,nch-1,lsor)
C
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      if((drive(indxtp).eq.VLBA.and.drive_type(indxtp).eq.VLBA2).or.
     &     (drive(indxtp).eq.VLBA4.and.drive_type(indxtp).eq.VLBA42)
     &     )then
         ipr=5
      else
         ipr=2
      endif
c
      do i=1,2
         nch=1
         nch=ichmv_ch(ib,nch,name)
         nch = nch + ib2as(i,ib,nch,1)
         nch=mcoma(ib,nch)
         nch = nch + ir2as(fastfw(i,indxtp),ib,nch,7,1)
         nch=mcoma(ib,nch)
         nch = nch + ir2as(slowfw(i,indxtp),ib,nch,5,1)
         nch=mcoma(ib,nch)
         nch = nch + ir2as(foroff(i,indxtp),ib,nch,6,1)
         nch=mcoma(ib,nch)
         nch = nch + ir2as(fastrv(i,indxtp),ib,nch,7,1)
         nch=mcoma(ib,nch)
         nch = nch + ir2as(slowrv(i,indxtp),ib,nch,5,1)
         nch=mcoma(ib,nch)
         nch = nch + ir2as(revoff(i,indxtp),ib,nch,6,1)
         nch=mcoma(ib,nch)
         nch = nch + ir2as(pslope(i,indxtp),ib,nch,8,ipr)
         nch=mcoma(ib,nch)
         nch = nch + ir2as(rslope(i,indxtp),ib,nch,8,ipr)
         call logit3(ib,nch-1,lsor)
      enddo
c
      return
      end





