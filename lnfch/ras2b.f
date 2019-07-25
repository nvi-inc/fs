      REAL*4 FUNCTION RAS2B(IAS,IC1,NCH,IERR)
C
C     THIS FUNCTION CONVERTS AN ASCII STRING TO REAL
C
      implicit none

C  INPUT PARAMETERS:
      integer*2 IAS(1)
      integer ic1,nch
C       INPUT STRING WITH ASCII CHARACTERS
C     IC1 - FIRST CHARACTER TO USE IN IAS
C     NCH - NUMBER OF CHARACTERS TO CONVERT
C
C  OUTPUT:
      integer ierr
C     IERR - ERROR RETURN, 0 IF OK, -1 IF ANY CHARACTER IS NOT A NUMBER
C
C  LOCAL VARIABLES
C
      double precision das2b
C
      ras2b=das2b(ias,ic1,nch,ierr)
C
      return
      end




