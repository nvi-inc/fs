C include file time array passing between setcl and matcn
C
      integer*4 centisec(6),unixsec(2),unixhs(2),iarr4(6)
      equivalence (centisec(1),iarr4(1)),(unixsec(1),iarr4(3))
      equivalence (unixhs(1),iarr4(5))
      common/time_arrays/iarr4
