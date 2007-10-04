      integer function igetstatnum2(cid)
! Check 1 or 2 character station ID, and return station #,  0 if not found, -1 if duplicates.
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'

      character*(*) cid    !Station ID

      integer istringminmatch

      igetstatnum2=istringminmatch(cpocod,nstatn,cid)
!      write(*,*) "igetstatnum2", cpocod(1:nstatn), cid
      return
      end
