      subroutine vlbadrive(ichecks,lwho)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer ichecks(1)
      integer*2 lwho
C 
C 
C  SUBROUTINES CALLED:
C 
C
C  LOCAL VARIABLES: 
      integer icherr(7)
C
C
C  INITIALIZED:
      do j=1,7
        icherr(j)=0
      enddo
      call fs_get_ichvlba(ichvlba(20),20)
      if(ichvlba(20).le.0.or.ichecks(20).ne.ichvlba(20)) goto 199
      ierr=0
      call recchk(icherr,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,0,ierr,lwho,2Hrc)
      endif
      do j=1,7
        if (icherr(j).ne.0) then
          call logit7(0,0,0,0,-221-j,lwho,2Hrc)
        endif
      enddo
199   continue
C
      return
      end
