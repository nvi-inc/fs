      logical function ktimedif(itime1,itime2)
! Return true if the times are different.
      integer itime1(5),itime2(5)          !iyear,iday,ihour,imin,isec

      ktimedif= (itime1(1) .ne. itime2(1)) .or.
     >          (itime1(2) .ne. itime2(2)) .or.
     >          (itime1(3) .ne. itime2(3)) .or.
     >          (itime1(4) .ne. itime2(4)) .or.
     >          (itime1(5) .ne. itime2(5))
      return
      end
