      integer function iTimeDifSec(itime1,itime2)
! on entry
      implicit none
      integer itime1(5),itime2(5)       !iyr,idoy,ihr,imin,isec
!
      double precision DelTime

      DelTime=itime1(5)-itime2(5)+60.*(itime1(4)-itime2(4))
     >  +3600.*(itime1(3)-itime2(3))
! this may happen at year end.
      if(itime1(1)-itime2(1) .eq. 1) then
         DelTime=DelTime+86400.d0
      else
         DelTime=DelTime+86400.d0*(itime1(2)-itime2(2))
      endif
      iTimeDifSec=DelTime

      return
      end
