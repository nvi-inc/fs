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
      character*30 ctemp   !temporary array.
      integer nch 
    
      if(kdbbc_rack) then
        cnamep="dbbc"
      else if(kbbc) then
        cnamep="bbc"
      else if(kifp) then
        cnamep="ifp"
      elseif (kvc) then
        cnamep="vc"      
      endif   

      ctemp=cnamep//code//cband_char(vcband)
      call squeezeleft(ctemp,nch)
      nch=nch+1
      cnamep=ctemp   
      if (kk4vcab.and.krec_append) cnamep(nch:nch)=crec(irec)
      call lowercase(cnamep)
      return
      end

