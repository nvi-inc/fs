      logical function kopn(lut,ierr,ipbuf,jerr)

      logical kfmp
      character*(*) ipbuf
C
      kopn=.false.
      if (jerr.eq.ierr) return
      kopn=kfmp(lut,ierr,8Hopening_,8,ipbuf,1,0)

      return
      end
