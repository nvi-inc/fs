C
      subroutine axtyp(laxis,iaxis,ix)

C     AXTYP converts between the hollerith names
C     of axis type and the code number used in SKED

C  History
C  900125 NRV Created to replace duplicated code in several routines.

C  Input
      integer*2 laxis(2) !  axis type name
      integer iaxis    !  axis type code
      integer ix       ! 1=convert name-->code
C                          2=convert code-->name
C  Output
C     Either laxis or iaxis is output, depending on ix
C  Local
      integer idum


C      1. Name --> code
 
      if (ix.eq.1) then
        if (ichcm_ch(laxis,1,'HADC').eq.0) then
          iaxis=1
        else if (ichcm_ch(laxis,1,'XYEW').EQ.0) then
          iaxis=2
        else if (ichcm_ch(laxis,1,'AZEL').eq.0) then
          iaxis=3
        else if (ichcm_ch(laxis,1,'XYNS').eq.0) then
          iaxis=4
        else if (ichcm_ch(laxis,1,'RICH').eq.0) then
          iaxis=5
        else if (ichcm_ch(laxis,1,'SEST').eq.0) then
          iaxis=6
        else if (ichcm_ch(laxis,1,'ALGO').eq.0) then
          iaxis=7
        else 
          iaxis=0
        endif

C      2. Code --> name

      else
        if (iaxis.eq.1) then
          idum= ichmv_ch(laxis,1,'HADC')
        else if (iaxis.eq.2) then
          idum= ichmv_ch(laxis,1,'XYEW')
        else if (iaxis.eq.3) then
          idum= ichmv_ch(laxis,1,'AZEL')
        else if (iaxis.eq.4) then
          idum= ichmv_ch(laxis,1,'XYNS')
        else if (iaxis.eq.5) then
          idum= ichmv_ch(laxis,1,'RICH')
        else if (iaxis.eq.6) then
          idum= ichmv_ch(laxis,1,'SEST')
        else if (iaxis.eq.7) then
          idum= ichmv_ch(laxis,1,'ALGO')
        else 
          idum= ichmv_ch(laxis,1,'----')
        endif
      endif

      return
      end
