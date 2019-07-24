      subroutine vlbadrive(lwho)
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
      call fs_get_ichvlba(ichvlba(18),18)
      ichecks=ichvlba(18)
      if(ichvlba(18).le.0) goto 199
      ierr=0
      call recchk(icherr,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,0,ierr,lwho,2Hrc)
      endif
      call fs_get_ichvlba(ichvlba(18),18)
      if(ichvlba(18).le.0.or.ichecks.ne.ichvlba(18)) goto 199
      do j=1,8
        if (icherr(j).ne.0) then
          call logit7(0,0,0,0,-231-j,lwho,2Hrc)
        endif
      enddo
199   continue
C
      return
      end
