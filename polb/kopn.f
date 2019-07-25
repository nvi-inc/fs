      logical function kopn(lut,ierr,ipbuf,jerr)

      logical kfmp
      character*(*) ipbuf
c
      integer*2 iarr(4)
C
      kopn=.false.
      if (jerr.eq.ierr) return
      call char2hol('opening_',iarr,1,8)
      kopn=kfmp(lut,ierr,iarr,8,ipbuf,1,0)

      return
      end
