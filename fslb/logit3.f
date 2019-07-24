      subroutine logit3(lmessg,nchar,lsor)

      include '../include/fscom.i'

      dimension lmessg(1)
      dimension lprocn(1)
      lwhat=0
      lwho=0
      ierr=0
      call logit(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,3)
      return
      end 
