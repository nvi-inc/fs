	SUBROUTINE SETPRINT(ierr,iwid,iopt)

C  Set up printer with proper escape sequences or
C  open up output print file.

C NRV 910306 Added IOPT to call for landscape orientation of list
C               IOPT=0 for portrait, =1 for landscape
C 960122 nrv Added some comments only.
C 960226 nrv Leftover I*2 !!!

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

	integer l,ierr,iwid,trimlen,iopt
      character*50 CLASER
        character*128 cout

       if (cprport.eq.'PRINT') then ! temp file name
        cout = tmpname 
       else ! specified file name
        cout = cprport
       endif

	open(unit=luprt,file=cout,iostat=ierr)
      IF (IERR.NE.0) THEN
        WRITE(LUSCN,9061) IERR,cout
9061    FORMAT(' SETPRINT01 - ERROR ',I5,' trying to open ',a,'. ')
        RETURN
      ENDIF

      if (cprtpor.eq.' '.and.cprtlan.eq.' ') then ! set up printers here
C                                                   instead of using scripts
        if (cprttyp.eq.'LASER') then !set up laser printer
	  if (iwid.eq.137.and.iopt.eq.0) then ! portrait
	    CLASER=' '
     .     //CHAR(27)//'&l0O'       ! portrait orientation
     .     //CHAR(27)//'(8U'        ! primary character set
     .     //CHAR(27)//'(s16.66H'   ! primary pitch
     .     //CHAR(27)//'&l8.5D'     ! lines per inch
     .     //CHAR(27)//'&a8L'       ! left margin column number
	  else if (iwid.eq.80) then
	    CLASER=   ' '
     .     //CHAR(27)//'&l0O'    ! portrait orientation
     .     //CHAR(27)//'(8U'        ! primary character set
     .     //CHAR(27)//'(s10H'      ! primary pitch
     .     //CHAR(27)//'&l6D'       ! lines per inch
     .     //CHAR(27)//'&a2L'       ! left margin column number
	  else if (iwid.eq.137.and.iopt.eq.1) then ! landscape
	    CLASER=' '
     .     //CHAR(27)//'&l1O'       ! landscape orientation
     .     //CHAR(27)//'(8U'        ! primary character set
     .     //CHAR(27)//'(s16.66H'   ! primary pitch
     .     //CHAR(27)//'&l8.5D'     ! lines per inch
     .     //CHAR(27)//'&a8L'       ! left margin column number
	  end if

	  l = trimlen(claser)
	  WRITE(luprt,9104) CLASER(1:l)
9104      FORMAT(A)
	else if (cprttyp.eq.'EPSON'.or.cprttyp.eq.'EPSON24') then
	  if (iwid.eq.137) then
	    claser = ' '//char(15)
	  else
	    claser = ' '//char(18)
	  endif
	  write(luprt,9104) claser(1:2)
	endif !set up printer
      else ! use scripts provided by user
      endif

      RETURN
      END
