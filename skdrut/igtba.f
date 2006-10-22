      integer FUNCTION IGTBA(cband_in)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
C     Check through all bands for a match with the first character of cband_in
C     RETURN INDEX IN igtba, else a 0.
      character*(*) cband_in

      DO Igtba=1,NBAND
        if(cband_in(1:1) .eq. cband(igtba)(1:1)) return
      end do
      igtba=0
      RETURN
      END
