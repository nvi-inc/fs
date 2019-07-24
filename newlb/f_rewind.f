      subroutine F_REWIND(IDCB,IERR)

C INPUT:
C  IDCB: Control Block

C OUTPUT:
C  IERR: Error value

      integer IDCB
      integer IERR

C The following line resets the marker to the beginning of the file or returns an error
      rewind(IDCB,IOSTAT=IERR)

      return
      end
