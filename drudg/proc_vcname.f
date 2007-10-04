      subroutine proc_vcname(kk4vcab,code,vcband,cnamep)
      include 'hardware.ftni'

! passed
      logical kk4vcab
      character*2 code          !code
      real vcband               !Bandwidth
! returned
      character*12 cnamep
! funcions
      character*1 cband_char

! local
      integer nch
      integer nco

      nch=4
      if(kbbc) then
        cnamep="bbc"
      else if(kifp) then
        cnamep="ifp"
      elseif (kvc) then
        cnamep="vc"
        nch=3
      endif

      if(code(2:2) .eq. " ") then
        nco=1
      else
        nco=2
      endif

      cnamep(nch:nch+nch)=code//cband_char(vcband)

      nch=nch+1+nco
      if (kk4vcab.and.krec_append) cnamep(nch:nch)=crec(irec)
      call lowercase(cnamep)
      return
      end

