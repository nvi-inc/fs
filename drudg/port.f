*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      SUBROUTINE PORT

C   This routine will change the printer output destination and
C   the printer type and the output width.

C  COMMON BLOCKS:
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
C
C  History:
C  901018 NRV Changed variable name, changed logic to leave port
C             set if user types <return>.
C  901205 NRV Moved width option in here from main program.
C  911127 NRV Added EPSON24 option
C  940725 nrv Add dos/ux option
C  950829 nrv linux version, copied from PC-DRUDG
C 970207 nrv Change prompt to use the word "destination"
C 970207 nrv Remove FILE option in printer type. This is the
C            same as using a file name in printer port.
C 970301 nrv Add font size prompt.
! 2006Jul20 JMGipson. Fixed problem with setting file name for short file names.
!          If lenght of filename<len(PRINT), then trailing letters of PRINT would be appended.
!          e.g., instead of dum, would get dumNT.
! 2006Sep26. Removed call to gtrsp. Now just use fortran read

C
C  Local:
      character*128 ctemp
      integer trimlen
      integer nch,l,ierr
C

C  1.0  Read the input from user and set port appropriatly.

      l=trimlen(cprport)
      write(luscn,'("Output destination set to: ",A)') cprport(1:l)
      write(luscn,'(a)')
     > "<RET>=no change, else enter in filename or PRINT."

      read(luusr,'(a)') cbuf
      nch=trimlen(cbuf)
      if(nch .gt. 0) cprport=cbuf

      if (cprport(1:5).eq.'print') cprport='PRINT'

C  2.0  Now get printer type.

      ierr=1
      l=trimlen(cprttyp)
      do while (ierr.ne.0)
        write(luscn,'("Printer type set to: ",A)') cprttyp(1:l)
        write(luscn,'(a)')
     >  "<RET>=no change, else LASER, EPSON or EPSON24"

        read(luusr,'(a)') cbuf
        nch=trimlen(cbuf)

        if (nch.gt.0) then
          ctemp=cbuf(1:nch)
          if (ctemp.eq.'EPSON'.or.ctemp.eq.'LASER' .or.
     >        ctemp.eq.'EPSON24') then
            cprttyp=ctemp
            ierr=0
          else
            write(luscn,'(a)') " Invalid printer type.  Only LASER, "//
     >        "EPSON, or EPSON24 allowed.  Try again."
          endif
        else
          ierr=0
        endif
      enddo

C  3. Now get printer output orientation.

      if(cpaper_size(1:1) .eq. "D") then
        ctemp="DEFAULT"
      else if(cpaper_size(1:1) .eq. "P") then
        ctemp="Portrait"
      else if(cpaper_size(1:1) .eq. "L") then
        ctemp="Landscape"
      endif

      l=trimlen(ctemp)
      ierr=1
      do while (ierr.ne.0)
        write(luscn,'("Output orientation set to ", a)') ctemp(1:l)
        write(luscn,'(a)')
     >   "<Ret>=no change (P)ortrait (L)andscape or (D)efault"

        read(luusr,'(a)') cbuf
        nch=trimlen(cbuf)

        if (nch.gt.0) then
          call capitalize(cbuf)
          if(cbuf(1:1) .eq. "L" .or. cbuf(1:1) .eq. "P" .or.
     >       cbuf(1:1) .eq. "D") then
             cpaper_size(1:1)=cbuf(1:1)
             ierr=0
          else
            write(luscn,'(a)') "' Invalid output width. "//
     >         "Only P, L, or D allowed.  Try again."
          endif
        else
          ierr=0
        endif
      enddo

C  4. Now get font size.
      if(cpaper_size(1:1) .eq. "D") then
        ctemp="DEFAULT"
      else if(cpaper_size(1:1) .eq. "S") then
        ctemp="Small"
      else if(cpaper_size(1:1) .eq. "L") then
        ctemp="Large"
      endif
      ierr=1
      l=trimlen(ctemp)
      do while (ierr.ne.0)
        write(luscn,'("Output font size set to: ",a)') ctemp(1:l)
        write(luscn,'(a)')
     >  "<Ret>=no change or (S)mall, (L)arge, (D)efault."

        read(luusr,'(a)') cbuf
        nch=trimlen(cbuf)

        if (nch.gt.0) then
          call capitalize(cbuf)
          if(cbuf(1:1) .eq. "L" .or. cbuf(1:1) .eq. "S" .or.
     >       cbuf(1:1) .eq. "D") then
             cpaper_size(2:2)=cbuf(1:1)
             ierr=0
          else
            write(luscn,'(a)') "' Invalid output width. "//
     >         "Only L, S, or D allowed.  Try again."
          endif
        else
          ierr=0
        endif
      enddo

      RETURN
      END
