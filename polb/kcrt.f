      logical function kcrt(lut,ierr,ipbuf,jerr)

      logical kfmp
      character*(*) ipbuf
C
      integer*2 lcret(6)
C
      data lcret  /   9,2Hcr,2Hea,2Hti,2Hng,2H_ /
C          creating_

      kcrt=.false.
      if (jerr.eq.ierr) return
      kcrt=kfmp(lut,ierr,lcret(2),lcret(1),ipbuf,1,0)

      return
      end
