      SUBROUTINE idchk(inum,cstnid,luscn)
C
C  This subroutine checks for identical station id characters and
C  replaces the second with the next character alphabetically.
C
C
C   HISTORY:
C
C     WHO   WHEN   WHAT
C     gag   900104 created
C 960206 nrv Variable holding station id must be i*2
C 970513 nrv Remove printout because it's confusing and not
C            really needed with 2-letter code usage.
C
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
C     include 'skcom.ftni'
C
C  INPUT:
C
      integer luscn,inum
      character cstnid(max_stn)
! function
      integer iwhere_in_string_list

C     inum - number of entries in array
C     cstnid - array with entries
C
C   SUBROUTINES
C     CALLED BY: AWRST
C     CALLED: CHAR2HOL,HOL2CHAR
C
C  LOCAL VARIABLES
      integer iwhere

      if(inum .le. 1) then
        return
      else
        iwhere=1
! search for match among earlier entries
        do while(iwhere .ne. 0)
          iwhere=iwhere_in_string_list(cstnid,inum-1,cstnid(inum))
          if(iwhere .ne. 0) then                        !A match.
             cstnid(inum)=char(ichar(cstnid(inum))+1)   !Change the 1 char ID.
          endif
        end do
      endif

      RETURN
      END
