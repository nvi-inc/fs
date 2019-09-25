      subroutine delete_file(lfilnam,lutmp)
! Delete a file, and write an error message if a problem.
! 2017Dec04.  JMGipson. Some cleanup
      integer lutmp
      character*(*) lfilnam

! local
      logical kexist   
     
      inquire(file=lfilnam,exist=kexist)
      if(.not. kexist) return
   
      OPEN (lutmp,  file=lfilnam,iostat=ierr)
      IF (ierr.NE.0) then
         WRITE(*,"('delete_file: I/O error ',i3, ' opening file ',a)")
     >    ierr,trim(lfilnam) 
         return
      endif

      CLOSE (lutmp,status='delete',iostat=ierr)
      IF (ierr.NE.0) then
         WRITE(*,"('delete_file: I/O error ',i3, ' purging file ',a)")
     >    ierr,trim(lfilnam)         
      endif


      return
      end
