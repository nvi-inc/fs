      subroutine logen8(ibuf,nch,lmessg,nchar,lsor,lprocn,ierr,lwho)

      dimension lmessg(1)
      dimension lprocn(1) 
      integer*2 ibuf(1) 
      lwhat=0
      call logen(ibuf,nch,lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,8)

      return
      end 
