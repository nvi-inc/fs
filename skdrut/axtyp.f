C
      subroutine axtyp(laxis,iaxis,ix)

C     AXTYP converts between the hollerith names
C     of axis type and the code number used in SKED

C  History
C  900125 NRV Created to replace duplicated code in several routines.
C  2004Feb04 JMGipson. Changed to string instead of holerith

C  Input
!      integer*2 laxis(2) !  axis type name
      character*4 laxis
      integer iaxis    !  axis type code
      integer ix       ! 1=convert name-->code
C                          2=convert code-->name
C  Output
C     Either laxis or iaxis is output, depending on ix
C  Local
      integer idum


C      1. Name --> code
 
      if (ix.eq.1) then
        if (laxis .eq.'HADC') then
          iaxis=1
        else if (laxis .eq.'XYEW') then
          iaxis=2
        else if (laxis .eq.'AZEL') then
          iaxis=3
        else if (laxis .eq.'XYNS') then
          iaxis=4
        else if (laxis .eq.'RICH') then
          iaxis=5
        else if (laxis .eq.'SEST') then
          iaxis=6
        else if (laxis .eq.'ALGO') then
          iaxis=7
        else 
          iaxis=0
        endif

C      2. Code --> name

      else
        if (iaxis.eq.1) then
          laxis='HADC'
        else if (iaxis.eq.2) then
          laxis='XYEW'
        else if (iaxis.eq.3) then
          laxis='AZEL'
        else if (iaxis.eq.4) then
          laxis='XYNS'
        else if (iaxis.eq.5) then
          laxis='RICH'
        else if (iaxis.eq.6) then
          laxis='SEST'
        else if (iaxis.eq.7) then
          laxis='ALGO'
        else
          laxis='----'
        endif
      endif

      return
      end
