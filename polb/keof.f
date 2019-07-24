      logical function keof(lu,len,ipbuf)

      logical kfmp
      character*(*) ipbuf
C
      integer*2 leof(5)
C
      data leof   /   7,2Heo,2Hf ,2Hon,2H_ /
C          eof on_ /

      keof=.false.
      if (len.ge.0) return
C
      keof=kfmp(lu,0,leof(2),leof(1),ipbuf,0,1)

      return
      end
