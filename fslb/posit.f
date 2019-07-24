      subroutine posit(ihd,ipass,pnowx,ip,new)
C
C  SKELETON SUBROUTINE WHICH CALLS POSHD
C     LAST MODIFIED:   LAR  880228     ADD IPASS TO CALLING PARAMETERS
C
      dimension ip(1)
      logical new
C
      call poshd(ihd,ipass,pnowx,ip)
      if (new.and.ip(3).ge.0) then
        call susp(1,25)
        call poshd(ihd,ipass,pnowx,ip)
        new = .false.
      endif

      return
      end
