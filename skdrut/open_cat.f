      subroutine open_cat(cat_name,ierr)
      include '../skdrincl/skparm.ftni'
      include 'skcom.ftni'
! Check to see if a catalog is there.
! If it is open it.
! If not, return with error message
! History
! 2005Nov21  JMGipson


      open(lucat,file=cat_name,status='old',iostat=ierr)
      nch = trimlen(cat_name)
      if (ierr.ne.0) then
        write(luscn,9011) ierr,cat_name(1:nch)
9011    format('Error ',i5,' opening catalog ',a)
        call flush(6)
        close(lucat)
        close(lutmp)
        return
      endif
      write(luscn,'(A,": ",$)') cat_name(1:nch)
      call flush(6)
      return
      end





