      subroutine logit2_ch(cmessg)
      character*(*) cmessg

      include '../include/fscom.i'

      integer*2 lmessg(128)
      dimension lprocn(1)
      lwhat=0
      lwho=0
      ierr=0
      lprocn(1)=0
      lsor=0
      nchar=len(cmessg)
      if(nchar.gt.256) then
         call put_stderr('logit2_ch message length >256\n'//char(0))
         stop 999
      endif
       call char2hol(cmessg,lmessg,1,nchar)
      call logit(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,2)
      return
      end 
