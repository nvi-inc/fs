      character*1 function pnum(i)
C  Return the character corresponding to the pass index.
C 960527 nrv New.

      integer i
      character*61 cp ! pass numbers
      character*1 cc

      data cp/'123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcedfghijklmnopqrstuv
     .wxyz'/

      cc = cp(i:i)
      pnum=cc
      return
      end
