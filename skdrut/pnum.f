      character*1 function pnum(i)
C  Return the character corresponding to the pass index.
C 960527 nrv New.
C 970530 nrv "d" and "e" reversed!

      integer i
      character*61 cp ! pass numbers
      character*1 cc

      data cp/'123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv
     .wxyz'/

      cc = cp(i:i)
      pnum=cc
      return
      end
