	SUBROUTINE SETPRINT(ierr,iwid,iopt)

C  Set up printer with proper escape sequences or
C  open up output print file, with unit LUPRT.

C NRV 910306 Added IOPT to call for landscape orientation of list
C NRV 910703 NEW version for UX version: open "luprt"

      INCLUDE 'skparm.ftni'
      INCLUDE 'drcom.ftni'

      integer ic,ierr,iwid,trimlen,iopt
      character*50 cout
      character*4 response
      character upper
      logical*4 kdone,ex
      character*4 stat

       if (cprport.eq.'PRINT') then
        cout = tmpname
       else
        cout = cprport
       endif

C     check to see if the file exists first

      ic=trimlen(cout)
      stat='unknown'
      inquire(file=cout,exist=ex,iostat=ierr)
C     if (ex) then
C       kdone = .false.
C       do while (.not.kdone)
C         write(luscn,9130) cout(1:ic)
C9130      format(' OK to purge existing file ',A,' (Y/N) ? ',$)
C         read(luusr,'(A)') response
C         response(1:1) = upper(response(1:1))
C         if (response(1:1).eq.'N') then
C           ierr=-1
C           return
C         else if (response(1:1).eq.'Y') then
C           open(lu_outfile,file=cout)
C           close(lu_outfile,status='delete')
C           kdone = .true.
C           stat='new'
C         end if
C       end do
C     end if
C
	open(unit=luprt,status=stat,file=cout,iostat=ierr)
      IF (IERR.NE.0) THEN
        WRITE(LUSCN,9061) IERR,cout
9061    FORMAT(' SETPRINT01 - ERROR ',I5,' ACCESSING output device ',
     .  A,'.')
        RETURN
      ENDIF

      RETURN
      END
