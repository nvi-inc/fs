      subroutine logit4(lmessg,nchar,lsor,lprocn)

      include '../include/fscom.i'

      dimension lmessg(1)
      dimension lprocn(1)
      integer*2 lsor
      lwhat=0
      lwho=0
      ierr=0
      call logit(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,4)
      return
      end 
