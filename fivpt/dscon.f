      subroutine dscon(dtpi,ierr) 
      double precision dtpi
      integer ierr
C 
C read total power from an lba detector
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
      data lwho/2Hfp/,lwhat/2Hds/,ntry/2/ 
C 
      iter=ntry
12    continue
      iter=iter-1
      if (iter.lt.0) goto 80000
      if (kbreak('fivpt')) goto 80010
c
      call fc_dscon_v(dtpi,ip)
C
C      CHECK FOR TIME OUT
C
      if (ip(3).ne.-120.and.ip(3).ne.-123) goto 15
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
