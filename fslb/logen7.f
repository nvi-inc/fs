      subroutine logen7(ibuf,nch,lmessg,nchar,lsor,lprocn,ierr)

      dimension lmessg(1)
      dimension lprocn(1) 
      integer*2 ibuf(1) 
      lwhat=0
      lwho=0
      call logen(ibuf,nch,lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,7)

      return
      end 
