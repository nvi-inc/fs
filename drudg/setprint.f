      SUBROUTINE SETPRINT(ierr,iopt)

C  Set up printer with proper escape sequences or
C  open up output print file. This routine only opens the
C  file but puts nothing in it if the user specified scripts 
C  to be used for printing output.

C NRV 910306 Added IOPT to call for landscape orientation of list
C 960122 nrv Added some comments only.
C 960226 nrv Leftover I*2 !!!
C 970207 nrv Use iopt instead of iwidth
C 970301 nrv Add IOPT=2 and 3.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

C  iopt  0 = portrait,  12 point (large)
C  iopt  1 = landscape, 8.5 point (small)
C  iopt  2 = portrait,  12 point (large)
C  iopt  3 = landscape, 8.5 point (small)

      integer l,ierr,trimlen,iopt
      character*50 CLASER
        character*128 cout

       if (cprport.eq.'PRINT') then ! temp file name
        cout = tmpname 
       else ! specified file name
        cout = cprport
       endif

      if (klab) cout = labname

      open(unit=luprt,file=cout,iostat=ierr)
      IF (IERR.NE.0) THEN
        WRITE(LUSCN,9061) IERR,cout
9061    FORMAT(' SETPRINT01 - ERROR ',I5,' trying to open ',a,'. ')
        RETURN
      ENDIF

      if (klab) return

      if (cprttyp.eq.'LASER') then !set up laser printer
        claser=''
        if (iopt.eq.0.and.cprtpor.eq.' ') then ! portrait, (large)
          CLASER=' '
     .    //CHAR(27)//'&l0O'       ! portrait orientation
     .    //CHAR(27)//'(8U'        ! primary character set
     .    //CHAR(27)//'(s10H'      ! 12 point
     .    //CHAR(27)//'&l6D'       ! lines per inch
C    .    //CHAR(27)//'&a2L'       ! left margin column number
        else if (iopt.eq.2.and.cprtpor.eq.' ') then ! portrait, ( small)
          CLASER=   ' '
     .     //CHAR(27)//'&l0O'    ! portrait orientation
     .     //CHAR(27)//'(8U'        ! primary character set
     .     //CHAR(27)//'(s16.66H'      ! 10 point
     .     //CHAR(27)//'&l8.5D'     ! lines per inch
C    .     //CHAR(27)//'&a2L'       ! left margin column number
        else if (iopt.eq.1.and.cprtlan.eq.' ') then ! landscape, (large)
          CLASER=' '
     .     //CHAR(27)//'&l1O'       ! landscape orientation
     .     //CHAR(27)//'(8U'        ! primary character set
     .     //CHAR(27)//'(s10H'      ! 12 point
     .     //CHAR(27)//'&l6D'       ! lines per inch
C    .     //CHAR(27)//'&a2L'       ! left margin column number
        else if (iopt.eq.3.and.cprtlan.eq.' ') then ! landscape, (small)
          CLASER=' '
     .     //CHAR(27)//'&l1O'       ! landscape orientation
     .     //CHAR(27)//'(8U'        ! primary character set
     .     //CHAR(27)//'(s16.66H'      ! 10 point
     .     //CHAR(27)//'&l8.5D'     ! lines per inch
C    .     //CHAR(27)//'&a2L'       ! left margin column number
        end if
        l = trimlen(claser)
        if (l.gt.2) WRITE(luprt,'(a)') CLASER(1:l)
      else if (cprttyp.eq.'EPSON'.or.cprttyp.eq.'EPSON24') then
        if (iopt.eq.1.or.iopt.eq.3) then
          claser = ' '//char(15) ! compressed
        else
          claser = ' '//char(18) ! normal
        endif
        write(luprt,'(a)') claser(1:2)
      endif !set up printer

      RETURN
      END
