       integer FUNCTION ICHMV_CH (LOUT,IFC,CINPUT)

       IMPLICIT NONE
       integer IFC
! AEM 20041230 int->int*2
       integer*2 LOUT(*)
       character*(*) CINPUT
C
C ICHMV: Hollerith character string mover
C
C Input:
C        LOUT: destination array
C        IFC: first character to fill in LOUT
C        CINPUT: source array
C
C Output:
C         ICHMV: IFC+LEN(CINPUT) (next available character)
C         LOUT: characters starting at IFC contain
C               characters from CINPUT
C
C Warning:
C         Negative and zero values of IFC are not support
C
      integer NCHAR
C
      IF(IFC.LE.0) THEN
	  WRITE(6,*) ' ICHMV_CH: Illegal argument',IFC
        STOP
      ENDIF
C
      NCHAR=LEN(CINPUT)
      call char2hol(CINPUT,LOUT,IFC,IFC+NCHAR-1)
C
      ICHMV_CH=IFC+NCHAR
C
! AEM 20041230 commented return
!      RETURN
      END
