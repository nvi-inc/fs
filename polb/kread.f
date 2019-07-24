      logical function kread(lu,ierr,ipbuf)

      logical kfmp
      character*(*) ipbuf
C
      integer*2 lread(5)
C
      data lread /8,2Hre,2Had,2Hin,2Hg_/
C          reading_

      kread=kfmp(lu,ierr,lread(2),lread(1),ipbuf,0,0)

      return
      end
