      subroutine antcn(ip1,ierr)
C 
C ANTCN SCHEDULING SUBROUTINE 
C 
C INPUT:
C 
C       IP1 = THE FIRST PARAMETER IN THE RUN STRING 
C 
      include '../include/fscom.i'
C 
C OUTPUT: 
C 
C       IERR = 0 IF NO ERROR OCCURRED 
C 
      integer*4 ip(5) 
      logical kbreak
C 
      data ntry/2/,idum/0/
C 
      itry=ntry 
15    continue
      if (kbreak('onoff')) goto 80010
      call run_prog('antcn','wait',ip1,0,0,0,0)
      call rmpar(ip)
      if (ip(3).ge.0) return 
      call logit7ic(idum,idum,idum,-1,ip(3),ip(4),'nf')
      itry=itry-1 
      if (itry.gt.0) goto 15
      goto 80020 
C 
C BREAK DETECTED
C 
80010 continue
      ierr=-1 
      return
C 
C FAILED COMMUNICATION
C 
80020 continue
      ierr=-30
      return
      end 
