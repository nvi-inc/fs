      subroutine ldriveall(ib,nch,indxtp)
      integer*2 ib(1)
      integer nch,indxtp
c
c
      include '../include/fscom.i'

      nch=mcoma(ib,nch)
      call fs_get_imaxtpsd(imaxtpsd,indxtp)
      if (imaxtpsd(indxtp).eq.-2) then
        nch = nch + ib2as(360,ib,nch,3)
      else if (imaxtpsd(indxtp).eq.-1) then
        nch = nch + ib2as(330,ib,nch,3)
      else if (imaxtpsd(indxtp).eq.7) then
        nch = nch + ib2as(270,ib,nch,3)
      endif
c
      nch=mcoma(ib,nch)
      call fs_get_iskdtpsd(iskdtpsd,indxtp)
      if (iskdtpsd(indxtp).eq.-2) then
        nch = nch + ib2as(360,ib,nch,3)
      else if (iskdtpsd(indxtp).eq.-1) then
        nch = nch + ib2as(330,ib,nch,3)
      else if (iskdtpsd(indxtp).eq.7) then
        nch = nch + ib2as(270,ib,nch,3)
      endif
c
      nch=mcoma(ib,nch)
      call fs_get_vacsw(vacsw,indxtp)
      if (vacsw(indxtp).eq.1) then
         nch=ichmv_ch(ib,nch,'yes')
      else if (vacsw(indxtp).eq.0) then
         nch=ichmv_ch(ib,nch,'no')
      endif
c
      return
      end
