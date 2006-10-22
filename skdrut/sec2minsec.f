      subroutine sec2minsec(isec_in,imin_out,isec_out)
! convert seconds to minutes and seconds.
      integer isec_in
      integer imin_out,isec_out

      imin_out=isec_in/60
      isec_out=mod(isec_in,60)
      return
      end
