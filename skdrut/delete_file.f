      subroutine delete_file(lfilnam,lutmp)
! Delete a file, and write an error message if a problem.
      integer lutmp
      character*(*) lfilnam
! function
      integer trimlen

! local
      logical kexist
      integer nch

      inquire(file=lfilnam,exist=kexist)
      if(kexist) then
        OPEN (lutmp,status='unknown',file=lfilnam,iostat=ierr)
        CLOSE (lutmp,status='delete')
      else
        return
      endif

      IF (ierr.NE.0) then
        nch=trimlen(lfilnam)
        WRITE(*,9170) ierr,lfilnam(1:nch)
9170    FORMAT('delete_file: Error ',I3,' purging old file ',A)
      endif
      return
      end
