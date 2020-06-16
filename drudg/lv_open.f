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
      subroutine lv_open(ierr)
      implicit none  !2020Jun15 JMGipson automatically inserted.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

! 2007Jul07  JMGipson.  Added "q" option for quitting.

C OUTPUT
      integer ierr
C LOCAL
      character*128 cfile
      character*256 inbuf
      character*3 cans
      integer il,trimlen
      logical ex

C  1. Prompt for output file name cfile=''

      ierr=-1
      cfile=''
      do while (cfile.eq.'')
        write(luscn,'("Enter name of output file, :: or q to quit ",$)')
        read (luusr,'(a)') cfile
        il = trimlen(cfile)
        if (cfile(1:2).eq.'::' .or. cfile(1:2) .eq. "q") return
        inquire(file=cfile,exist=ex,iostat=ierr)
        if (ex) then ! file exists
          do while (cans(1:1).ne.'o'.and.cans(1:1).ne.'a')
            write(luscn,'("Output file already exists, (o)verwrite",
     .      " or (a)ppend, q or :: to quit  ",$)')
            read (luusr,'(a)') cans
            if (cans(1:2).eq.'::' .or. cans(1:2) .eq. "q") return
          enddo
          open(unit=LU_outfile,file=cfile,status='old',iostat=IERR)
          if (cans(1:1).eq.'a') then ! read to end
            do while (.true.)
              read(lu_outfile,'(A)',end=777,iostat=ierr) inbuf
            enddo
777         if (ierr.ne.0.and.ierr.ne.-1) then
              write(luscn,9060) ierr,cfile(1:il)
9060          format(' LV_OPEN - Error ',i5,' positioning file ',A)
              return
            endif
          endif
        else ! new file
          open(unit=LU_outfile,file=cfile,status='new',iostat=IERR)
          if (ierr.ne.0) then
            write(luscn,'("LVOPEN01 - Error ",i5," opening file ",
     .      a)') cfile(1:il)
            return
          endif
        endif ! file exists/new file
      enddo
      return
      end
