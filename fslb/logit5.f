      subroutine logit5(lmessg,nchar,lsor,lprocn,ierr)

      include '../include/fscom.i'

      dimension lmessg(1)
      dimension lprocn(1)
      lwhat=0
      lwho=0
      call logit(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,5)
      return
      end 
