      subroutine snap_ReadTime(lbuf,itime_vec,kvalid)
      implicit none
! Read in the time.
! on entry
      character*40 lbuf
! on exit
      integer itime_vec(5)      !time vector
      logical kvalid            !got a valid time?
! local
      character*40 lformat
      integer iyear,iday,ihour,imin,isec

! initialize
      kvalid=.true.

      if (index(lbuf,'.').ne.0) then ! punctuation
        lformat='(i4,1x,i3,3(1x,i2))'
        read(lbuf(2:40),lformat,err=100) iyear,iday,ihour,imin,isec
        itime_vec(1)=iyear
      else ! numbers only
        lformat='(i3,3i2)'
        read(lbuf(2:40),lformat,err=100) iday,ihour,imin,isec
      endif ! punctuation/numbers
      itime_vec(2)=iday
      itime_vec(3)=ihour
      itime_vec(4)=imin
      itime_vec(5)=isec
      return

100   continue
      kvalid=.false.
      return
      end
