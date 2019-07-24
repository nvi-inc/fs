      subroutine vlbarack(ichecks,lwho,kall)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer ichecks(1)
      integer*2 lwho
      logical kall !true to check everyting every 20 sec
C 
C 
C  SUBROUTINES CALLED:
C 
C
C  LOCAL VARIABLES: 
      integer nbbc
      integer*2 lmodna(16)
      integer*2 ldistna(2)
      integer icherr(10)
      integer nbbcerr, niferr
C
C
C  INITIALIZED:
      data nbbc/16/
      data nbbcerr/10/  !! number of possible bbc errors 
      data niferr/5/    !! number of possible if errors 
      data lmodna /2Hb1,2Hb2,2Hb3,2Hb4,2Hb5,2Hb6,2Hb7,2Hb8,2Hb9,2Hba,
     /             2Hbb,2Hbc,2Hbd,2Hbe,2Hbf,2Hbg/
      data ldistna /2Hia,2Hic/
C
C  First loop through the array checking the BaseBand Converters (BBC)
C
      if (.not.kall) return
      do ibbc=1,nbbc
        do j=1,nbbcerr
          icherr(j)=0
        enddo
        call fs_get_ichvlba(ichvlba(ibbc),ibbc)
        if(ichvlba(ibbc).le.0.or.ichecks(ibbc).ne.ichvlba(ibbc))
     .     goto 199
        ierr=0
        call bbchk(ibbc,icherr,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,0,ierr,lwho,lmodna(ibbc))
          goto 199
        endif
        do j=1,nbbcerr
          if (icherr(j).ne.0) then
            call logit7(0,0,0,0,-201-j,lwho,lmodna(ibbc))
          endif
        enddo
199     continue
      enddo
C
C Check the if distributors
C
      do idist=1,2
        do j=1,nbbcerr
          icherr(j)=0
        enddo
        call fs_get_ichvlba(ichvlba(nbbc+idist),nbbc+idist)
        if(ichvlba(idist+nbbc).le.0.or.ichecks(idist+nbbc).ne.
     .             ichvlba(idist+nbbc))
     .     goto 299
        ierr=0
        call distchk(idist,icherr,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,0,ierr,lwho,ldistna(idist))
          return
        endif
        do j=1,niferr
          if (icherr(j).ne.0) then
            call logit7(0,0,0,0,-201-j-nbbcerr,lwho,ldistna(idist))
          endif
        enddo
299     continue
      enddo
C
C Check the formatter
C
      do j=1,5
        icherr(j)=0
      enddo
      call fs_get_ichvlba(ichvlba(19),19)
      if(ichvlba(19).le.0.or.ichecks(19).ne.ichvlba(19)) goto 399
      ierr=0
      call vformchk(icherr,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,0,ierr,lwho,2Hvf)
      endif
      do j=1,5
        if (icherr(j).ne.0) then
          call logit7(0,0,0,0,-201-j-nbbcerr-niferr,lwho,2Hvf)
        endif
      enddo
C check the formatter time with the computer time
      ierr=0
      ierror=0
      call timechk(ierror,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,0,ierr,lwho,2Hvf)
      endif
      if (ierror.ne.0) then
        call logit7(0,0,0,0,-329,lwho,2Hvf)
      endif
399   continue
C
      return
      end
