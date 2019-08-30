      subroutine r2dbcn(dtpi,dtpi2,ierr,icont,isamples) 
      double precision dtpi,dtpi2
      integer ierr,icont,isamples
C 
C read total power from an dbbc detector
c
C        dtpi = returned total power
C 
C  OUTPUT:
C 
C        IERR = 0 IF NO ERROR 
C 
      include '../include/fscom.i'
C 
      integer*2 lwho,lwhat
      integer*4 ip(5)
      logical kbreak
C 
      data lwho/2Hfp/,lwhat/2Hrb/,ntry/2/ 
C 
      ierr=0
      iter=ntry
12    continue
      iter=iter-1
      if (iter.lt.0) goto 80000
      if (kbreak('fivpt')) goto 80010
c
      call fc_r2dbcn_v(dtpi,dtpi2,ip,icont,isamples)
CC
C      CHECK FOR TIME OUT
C
      if (ip(3).ne.-104) goto 15
      call logit7(idum,idum,idum,-1,-70,lwho,lwhat)
      goto 12
C
C  other errors
C
15    continue
      if(ip(3).ge.0) goto 90000
      call logit7(idum,idum,idum,-1,ip(3),ip(4),ip(5))
      goto 12
C 
C  FAILED 
C 
80000 continue
      ierr=-72
      goto 90000 
C 
C BREAK DETECTED
C 
80010 continue
      ierr=1 
      goto 90000 
C 
C CLEAN UP AND EXIT 
C 
90000 continue

      return
      end 
