      subroutine logit7ic(lmessg,nchar,lsor,lprocn,ierr,lwho,cwhat)
      character*(*) cwhat

      include '../include/fscom.i'

      dimension lmessg(1)
      dimension lprocn(1)
c
      call char2hol(cwhat,lwhat,1,2)
      call logit(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,7)

      return
      end 
