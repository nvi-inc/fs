
      subroutine FClose(IDCB,IERR)

C Subroutine to close a file

C INPUT:
C  IDCB: Control Block of File

C OUTPUT:
C  IERR: Error value, returns negative if an error is detected

      integer IDCB
      integer IERR
     
      CLOSE(IDCB,IOSTAT=IERR)
      IF (IERR.GT.0) THEN
        IERR=-2                         !  Indicates that an error has occured
      END IF

      return
      end
