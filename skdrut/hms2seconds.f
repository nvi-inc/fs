      double precision function hms2seconds(ih,im,is)
      integer ih,im,is
! convert time in hours, minutes,seconds format to seconds
!      hms2seconds=ih*3600+im*60.+is
! AEM 20041227 
      hms2seconds=ih*3600.d0+im*60.d0+is
      return
      end
