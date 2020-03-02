      function mcoma(ibuf,ich)

! AEM 20050112 implicit none, list variables
      implicit none
      
      integer*2 ibuf(*)
      integer mcoma,ich,ichmv_ch

C     MOVE A COMMA INTO CHARACTER ICH OF IBUF 
C     RETURNS THE NEXT AVAILABLE CHARACTER (ICH+1)

      mcoma = ichmv_ch(ibuf,ich,',')

! AEM 20050112 commented return
!      return
      end 
