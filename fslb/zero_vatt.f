      subroutine get_vatt(name,lwho,ierr,ichain1,ichain2) 
      character*(*) name
      integer*2 lwho
      integer ierr,ichain1,ichain2
C 
C  get vlba rack attenuator settings
C 
C  OUTPUT:
C 
C        IERR = 0 IF NO ERROR 
C 
      include '../include/fscom.i'
C 
      integer*2 lwhat
      integer*4 ip(5)
      logical kbreak
C 
      data lwhat/2Hmc/,ntry/2/ 
C 
      iter=ntry
12    continue
      iter=iter-1
      if (iter.lt.0) goto 80000
      if (kbreak(name)) goto 80010

      call fc_vget_att(lwho,ip,ichain1,ichain2)
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
      subroutine zero_vatt(name,lwho,ierr) 
      character*(*) name
      integer*2 lwho
      integer ierr
C 
C  zero vlba rack attenuators
C 
C  OUTPUT:
C 
C        IERR = 0 IF NO ERROR 
C 
      include '../include/fscom.i'
C 
      integer*2 lwhat
      integer*4 ip(5)
      logical kbreak
C 
      data lwhat/2Hmc/,ntry/2/ 
  
C 
      iter=ntry
12    continue
      iter=iter-1
      if (iter.lt.0) goto 80000
      if (kbreak(name)) goto 80010

      call fc_vset_zero(lwho,ip)
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
      subroutine rst_vatt(name,lwho,ierr) 
      character*(*) name
      integer*2 lwho
      integer ierr
C 
C  restore vlba rack attenuator settings
C 
C  OUTPUT:
C 
C        IERR = 0 IF NO ERROR 
C 
      include '../include/fscom.i'
C 
      integer*2 lwhat
      integer*4 ip(5)
      logical kbreak
C 
      data lwhat/2Hmc/,ntry/2/ 
C 
      iter=ntry
12    continue
      iter=iter-1
      if (iter.lt.0) goto 80000
      if (kbreak(name)) goto 80010

      call fc_vrst_att(lwho,ip)
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
