      subroutine head_vlt(ihead,volt,ip,mictolin,indxtp)
      integer ihead,ip(5),indxtp
      real*4 volt,mictolin
C
C  HEAD_VLT: position a head by voltage, try at most 50 times
C
C  INPUT:
C     IHEAD - head to move, 1 or 2
C     VOLT  - target position in voltage
C     MICTOLIN - tolerance for positioning in microns @ NOMINAL 150uM/V
C
C  OUTPUT:
C     IP - Field System retrun parameters
C     IP(3) - error return, 0 if no error
C
      include '../include/fscom.i'
C
      integer i,ispdhd
      logical kbreak
      real*4 tmove
      real*4 micdst,micnow,micoff,vltnow,miclst,vltlst,vltoth
      real*4 spdnew,spdraw,spdold,vltlim,scale,mictol
C
C vlba2 drive
C
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      if(drive(indxtp).eq.VLBA.and.drive_type(indxtp).eq.VLBA2) then
        call fc_v2_head_vmov(ihead,volt,ip,indxtp)
        return
      endif
C
C all others
C
      if(volt.lt.-0.010) then
       scale=rslope(ihead,indxtp)
      else if(volt.gt.0.010) then
       scale=pslope(ihead,indxtp)
      else
       scale=max(rslope(ihead,indxtp),pslope(ihead,indxtp))
      endif
      mictol=(mictolin/150.)*scale
      mictol=max(mictol,(ilvtl_fs(indxtp)*0.0049+0.0026)*scale)
C
      call vlt2mic(ihead,0,.true.,volt,micdst,ip,indxtp)
      if(ip(3).ne.0) return
C
      call vlt_head(ihead,vltnow,ip,indxtp)
      if(ip(3).ne.0) return
C
      call vlt2mic(ihead,0,.true.,vltnow,micnow,ip,indxtp)
      if(ip(3).ne.0) return
C
      vltlst=vltnow
      miclst=micnow
      micoff=micdst-micnow
      i=0
      ilimit=0
      vltlim=0.0
C
      do while (abs(micoff).gt.mictol.and.i.lt.50)
        call head_d_mic(ihead,micoff,tmove,ispdhd,ip,indxtp)
        if(ip(3).ne.0) return
C
        call vlt_head(ihead,vltnow,ip,indxtp)
        if(ip(3).ne.0) return
C
        call vlt2mic(ihead,0,.true.,vltnow,micnow,ip,indxtp)
        if(ip(3).ne.0) return
C
        if(khecho_fs) then
          write(lu,91) ihead,miclst,micoff,micnow-miclst
        endif
91      format(i4,3f8.1)
C
C if we aren't there yet, see if we can adapt the speed, FAST only
c
        if(kadapt_fs(indxtp).and.abs(micdst-micnow).gt.mictol.
     $       and.ispdhd.eq.1) then
           if((VLBA.eq.drive(indxtp).and.VLBAB.eq.drive_type(indxtp))
     $          .or.VLBA4.eq.drive(indxtp).or.MK4.eq.drive(indxtp).or.
     &          (drive(indxtp).eq.MK4.and.drive_type(indxtp).ne.MK4B)
     &          ) then
C !make sure other head is on scale
             call vlt_head(3-ihead,vltoth,ip,indxtp)
             if(ip(3).ne.0) return
             if(abs(vltoth).ge.9.989) go to 20
          endif
C
C are we within the know range of reachable positions?
C
          if(vltlst.gt.lmtn_fs(ihead,indxtp).and.
     $         vltlst.lt.lmtp_fs(ihead,indxtp).and.
     &         vltnow.gt.lmtn_fs(ihead,indxtp).and.
     $         vltnow.lt.lmtp_fs(ihead,indxtp)) then
C
C but did we move more than 20 microns, can so we get a reasonable estimate?
C
             if(abs(micnow-miclst).gt.20.) then
              if(micoff.gt.0.0) then              !get the old speed
                spdold=fastrv(ihead,indxtp)
              else
                spdold=fastfw(ihead,indxtp)
              endif
              spdraw=abs(micnow-miclst)/tmove     !get the measured speed
C
C if the difference is less than 5% use it otherwise, decrease or
C  increase the speed by 5% so that we slowly converge to the
C  the correct speed without being jerked around by anomoulous values
C
              if(abs(spdraw-spdold).lt.0.05*spdold)then
                spdnew=spdraw
              else if(spdraw.gt.spdold) then
                spdnew=spdold*1.05
              else
                spdnew=spdold*0.95
              endif
C
C and limit the range of speeds to [5,5000] microns/seconds]
C  again for reasonableness
C
              spdnew=min(max(5.,spdnew),5000.)
              if(micoff.gt.0.0) then                ! update the speed
                fastrv(ihead,indxtp)=spdnew
              else
                fastfw(ihead,indxtp)=spdnew
              endif
            endif
            ilimit=0              !we know we aren't stuck
            vltlim=0.0
C
C we also check to see if we are stuck (or at the limit) in either
C  direction
C
          else if(micoff.gt.0.0.and.
     $           vltnow.gt.lmtp_fs(ihead,indxtp)) then
            if(ilimit.le.0.or.
     $            abs(vltlim-lmtp_fs(ihead,indxtp)).gt.0.003) then
              vltlim=lmtp_fs(ihead,indxtp)
              ilimit=1
            else
              ilimit=ilimit+1
            endif
          else if(micoff.lt.0.0.and.
     $           vltnow.lt.lmtn_fs(ihead,indxtp)) then
            if(ilimit.ge.0.or.
     $            abs(vltlim-lmtn_fs(ihead,indxtp)).gt.0.003) then
              vltlim=lmtn_fs(ihead,indxtp)
              ilimit=-1
            else
              ilimit=ilimit-1
            endif
C
C in this case we know we aren't stuck
C
          else
            ilimit=0
            vltlim=0.0
          endif
C
C we must have been stuck at least 5 times in one direction so give-up
C   this error trap is defeat for 'FIXED' posiitoning
C
          if(abs(ilimit).ge.5) then
            ip(3)=-407
            call char2hol('q@',ip(4),1,2)
            if(ihead.eq.1) then
               call char2hol(' 1',ip(5),1,2)
            else
               call char2hol(' 2',ip(5),1,2)
            endif
            return
          endif
C
C  update the range, being conserative
C
          lmtp_fs(ihead,indxtp)=max(lmtp_fs(ihead,indxtp),vltnow-0.010)
          lmtn_fs(ihead,indxtp)=min(lmtn_fs(ihead,indxtp),vltnow+0.010)
20        continue
        endif
C
C now finally, where were going?
C
        vltlst=vltnow
        miclst=micnow
        micoff=micdst-micnow
C
        i=i+1
        if(kbreak('quikr')) then
          ip(3)=-405
          call char2hol('q@',ip(4),1,2)
          return
        endif
      enddo
C
      if(abs(micoff).lt.mictol) return
      ip(3)=-404
      call char2hol('q@',ip(4),1,2)
      return
      end
