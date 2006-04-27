      subroutine fopen(idcb,filename,ierr)

C Subroutine to open a file

C INPUT:
C  IDCB: Control Block of File

C OUTPUT:
C  IERR: Error value, returns negative if an error is detected

      integer IDCB
      character*(*) filename
      integer IERR
      integer permissions
      integer ilen, trimlen
      logical kexist
     
      INQUIRE(FILE=filename,EXIST=kexist,IOSTAT=IERR)
      IF (IERR.GT.0) THEN
        IERR=-1                   !  Indicates that an error has occured
        return
      END IF
      OPEN(IDCB,FILE=filename,IOSTAT=IERR)
      IF (IERR.GT.0) THEN
        IERR=-1                   !  Indicates that an error has occured
        return
      END IF
      IF(.not.kexist) then
         permissions = o'0666'
         ilen=trimlen(filename)
         call fc_chmod(filename,permissions,ilen,ierr)
      endif

      return
      end
