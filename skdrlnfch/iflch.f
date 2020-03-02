      function iflch(ibuf,ilen)

! AEM 20050112 add implicit none
      implicit none

C     IFLCH - finds the last character in the buffer
C             by lopping off trailing blanks
C
C
C  INPUT:
C
!      dimension ibuf(1)
! AEM 20050112 list variables
      integer iflch,ilen
      integer*2 ibuf(*)

      integer nb,i
C     ILEN - length of IBUF in CHARACTERS 
C 
C 
C  OUTPUT:
C 
C     IFLCH - number of characters in IBUF
C 
C 
C  LOCAL:
! AEM 20050112 char->char*1
      character*1 cjchar
C 
C     LTERM - termination character 
C 
C 
C  INITIALIZED: 
C
C 
C  PROGRAMMER:  NRV 
C  LAST MODIFIED 800825 
C 
C 
C     1. Step backwards through the buffer, deleting any
C     blanks as we come to them.
C 
      nb = 0
      do 100 i=ilen,1,-1
        if (cjchar(ibuf,i).eq.' ') nb = nb + 1 
        if (cjchar(ibuf,i).ne.' ') goto 101
100     continue
101   iflch = ilen - nb 

! AEM 20050112 commented return
!      return
      end 
