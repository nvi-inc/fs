      subroutine logit7ci(lmessg,nchar,lsor,lprocn,ierr,cwho,lwhat)
      character*(*) cwho

      include '../include/fscom.i'

      dimension lmessg(1)
      dimension lprocn(1)
c
      call char2hol(cwho,lwho,1,2)
      call logit(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,7)

      return
      end 
