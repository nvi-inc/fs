      subroutine seconds2hms(rsecond,ihr,imin,isec)
      double precision rsecond
      integer ihr,imin,isec
      ihr =rsecond/3600.d0
      imin=(rsecond-ihr*3600.d0)/60.d0
      isec =(rsecond-ihr*3600.d0-imin*60.d0)
      return
      end

