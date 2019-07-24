      subroutine logen4(ibuf,nch,lmessg,nchar)
      dimension lmessg(1)
      dimension lprocn(1) 
      integer*2 ibuf(1) 
      lwhat=0
      lwho=0
      ierr=0
      lprocn(1)=0
      lsor=0
      call logen(ibuf,nch,lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,4)
900   return
      end 
