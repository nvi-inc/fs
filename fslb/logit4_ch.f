      subroutine logit4_ch(cmessg,lsor,lprocn)
      character*(*) cmessg

      include '../include/fscom.i'

      integer*2 lmessg(128)
      dimension lprocn(1)
      lwhat=0
      lwho=0
      ierr=0
      nchar=len(cmessg)
      if(nchar.gt.256) stop 999
      call char2hol(cmessg,lmessg,1,nchar)
      call logit(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,4)
      return
      end 
