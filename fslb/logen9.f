      subroutine logen9(ibuf,nch,lmessg,nchar,lsor,lprocn,ierr,lwho,
     .                 lwhat)

      dimension lmessg(1)
      dimension lprocn(1) 
      integer*2 ibuf(1) 
      call logen(ibuf,nch,lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,9)

      return
      end 
