      double precision function hms2seconds(ih,im,is)
      integer ih,im,is
! convert time in hours, minutes,seconds format to seconds
      hms2seconds=ih*3600+im*60.+is
      return
      end
