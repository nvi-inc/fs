      subroutine vlbadrive(lwho,indxtp)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer*2 lwho
C 
C 
C  SUBROUTINES CALLED:
C 
C
C  LOCAL VARIABLES: 
      integer icherr(8)
C
C
C  INITIALIZED:
      do j=1,8
        icherr(j)=0
      enddo
      call fs_get_ichvlba(ichvlba(18+indxtp-1),18+indxtp-1)
      ichecks=ichvlba(18+indxtp-1)
      if(ichvlba(18+indxtp-1).le.0) goto 199
      ierr=0
      call recchk(icherr,ierr,indxtp,0)
      if (ierr.ne.0) then
         if(indxtp.eq.1) then
            call logit7ic(0,0,0,0,ierr,lwho,'r1')
         else
            call logit7ic(0,0,0,0,ierr,lwho,'r2')
         endif
      endif
      call fs_get_ichvlba(ichvlba(18+indxtp-1),18+indxtp-1)
      if(ichvlba(18+indxtp-1).le.0.or.
     $     ichecks.ne.ichvlba(18+indxtp-1)) goto 199
      do j=1,8
        if (icherr(j).ne.0) then
           if(indxtp.eq.1) then
              call logit7ic(0,0,0,0,-231-j,lwho,'r1')
           else
              call logit7ic(0,0,0,0,-231-j,lwho,'r2')
           endif
        endif
      enddo
199   continue
C
      return
      end
