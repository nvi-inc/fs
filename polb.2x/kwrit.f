      logical function kwrit(lu,ierr,ipbuf)

      logical kfmp
      character*(*) ipbuf
C
      integer*2 lwrit(5)
C
      data lwrit  /8,2Hwr,2Hit,2Hin,2Hg_/
C          writing_

      kwrit=kfmp(lu,ierr,lwrit(2),lwrit(1),ipbuf,0,0)

      return
      end
