      subroutine logen6(ibuf,nch,lmessg,nchar,lsor,lprocn)

      dimension lmessg(1)
      dimension lprocn(1) 
      integer*2 ibuf(1) 

      lwhat=0
      lwho=0
      ierr=0
      call logen(ibuf,nch,lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,6)

      return
      end 
