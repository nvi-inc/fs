      subroutine logit2(lmessg,nchar)

      include '../include/fscom.i'

      dimension lmessg(1)
      dimension lprocn(1)
      lwhat=0
      lwho=0
      ierr=0
      lprocn(1)=0
      lsor=0
      call logit(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,2)
      return
      end 
