      subroutine logit7(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat)

      include '../include/fscom.i'

      dimension lmessg(1)
      dimension lprocn(1)
      call logit(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,7)

      return
      end 
