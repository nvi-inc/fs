      subroutine logit6c(lmessg,nchar,lsor,lprocn,ierr,cwho)
      character*(*) cwho

      include '../include/fscom.i'

      dimension lmessg(1)
      dimension lprocn(1)
      integer*2 lwho
      lwhat=0
      call char2hol(cwho,lwho,1,2)
      call logit(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,6)

      return
      end 
