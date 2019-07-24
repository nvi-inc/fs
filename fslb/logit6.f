      subroutine logit6(lmessg,nchar,lsor,lprocn,ierr,lwho)

      include '../include/fscom.i'

      dimension lmessg(1)
      dimension lprocn(1)
      lwhat=0
      call logit(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,6)

      return
      end 
