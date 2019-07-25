      logical function kerr(ierr,who,what,fname,iner,jner)
      implicit none
C
C  This function writes an error message to the users terminal.
C
C  WHO  WHEN    DESCRIPTION
C  WEH  901101  CREATED
C
C  INPUT VARIABLES
      integer ierr,iner,jner
      character*(*) who,what,fname
C
C  LOCAL VARIABLES
C
C
      kerr=.false.
      if(ierr.eq.0) return
      if(iner.eq.ierr) return
      if(jner.gt.0.and.ierr.gt.0) return
      kerr=.true.
C
      write(6,1) who,ierr,what,fname
1     format('pfmed'/' ',a,': error ',i7,' ',a,' ',a)
      return
      end
