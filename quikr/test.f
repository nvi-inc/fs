      program test

      integer*2 ibuf(8)
      integer iposn(2), ipas(2)
      logical koffset


      iposn(1)= -295
      iposn(2)= 0
      ipas(1)= 3
      ipas(2)= 0
cxx      koffset=.true.
      koffset=.false.
     
      write(6,8000) iposn(1), iposn(2)
8000  format(1x,"TEST: iposn1=",i4," iposn2=",i4)
      write(6,9000) ipas(1), ipas(2), koffset
9000  format(1x,"TEST: ipas1=",i4," ipas2=",i4," koffset=",l)
      call frmaux4(ibuf,iposn,ipas,koffset)

      write(6,9100) ibuf
9100  format(1x,"TEST: ibuf=",8a2)

      end
