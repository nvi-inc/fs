      SUBROUTINE idchk(inum,istnid,luscn)
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
C
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
C     include 'skcom.ftni'
C
C  INPUT:
C
      integer luscn,inum
      character istnid(max_stn)
C     inum - number of entries in array
C     istnid - array with entries
C
C   SUBROUTINES
C     CALLED BY: AWRST
C     CALLED: CHAR2HOL,HOL2CHAR
C
C  LOCAL VARIABLES
      LOGICAL lchange
      INTEGER j
      integer*2 lch 
      character xch
C
      lchange = .false.
      xch = istnid(inum)
      j = 1
      do while(j.lt.inum)
        if (istnid(j).eq.istnid(inum)) then
          lchange = .true.
          if (istnid(inum).eq.'Z') then
            istnid(inum) = 'A'
          else
            call char2hol(istnid(inum),lch,1,1)
            lch = lch + 1
            call hol2char(lch,1,1,istnid(inum))
          end if
          j = 0
        end if
        j = j + 1
      end do
      if (lchange) then
        write(luscn,9100) xch,istnid(inum)
9100    format(' Changing id code from ',A,' to ',A,' ') 
      end if

C
      RETURN
      END
