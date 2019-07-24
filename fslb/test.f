      program test

      integer lu
      double precision dpi

      dpi = 3.141 592 653 589 793 238 46D0

      write(6,9200) '           dpi = 3.141 592 653 589 793 238 46D0'
9200  format(1x,a)
      write(6,9100) dpi
9100  format(1x,"TEST: dpi = ",D25.20)


      return
      end
