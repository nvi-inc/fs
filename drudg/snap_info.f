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
      subroutine snap_info(cr2,maxchk,dopre)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C SNAP_INFO sets the parity check and prepass flags.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

C Input
      character*(*) cr2
C Output
      character*1 maxchk,dopre
C Local
      character*1 upper
      integer ierr
      character*4 response
      integer trimlen

       if (kbatch) then ! batch
         maxchk = upper(cr2)
         if (maxchk.ne.'Y'.and.maxchk.ne.'N') then
           write(luscn,9104) maxchk
           return
         endif
       else ! interactive
        write(luscn,9112) cepoch(1:trimlen(cepoch))
9112    format(' Source commands will be written with epoch ',a,'.')
        if (kparity) then
          write(luscn,9102)
9102      format(/' Parity checks will be inserted after the first ',
     .    'scan of each pass,'/' if there is enough time to do them.')
        else
          write(luscn,9101)
9101      format(' No parity checks will be inserted unless you ',
     .    'request them ',/' with the following response.')
        endif
        ierr=1
        do while (ierr.ne.0)
          if (kparity) then
            write(luscn,9103)
9103        format(' Add more parity checks whenever there is ',
     .      'enough time?'/' Enter Y or N, 0 to quit ? [default N] ',$)
          else
            write(luscn,9105)
9105        format(' Insert parity checks whenever there is ',
     .      'enough time?'/' Enter Y or N, 0 to quit ? [default N] ',$)
          endif
          read(luusr,'(a)') response
          if (response(1:1).eq.'0') return
          response(1:1) = upper(response(1:1))
          if (response(1:1).eq.' ') response(1:1) = 'N'
          if (response(1:1).ne.'Y'.and.response(1:1).ne.'N') then
            write(luscn,9104) response(1:1)
9104      format(' Invalid parity check response ',a,'. Enter Y or N.')
          else
            maxchk = response(1:1)
            ierr=0
          endif
        enddo
        if (kprepass) then ! prepass
          write(luscn,9107)
9107      format(/' Prepassing tapes is specified in this schedule. ',
     .    /' Please confirm whether you want do to this.')
          ierr=1
          do while (ierr.ne.0)
            if (kprepass) then
              write(luscn,9106)
9106          format(' Do prepasses during the session? ',
     .        ' Enter Y or N, 0 to quit ? [default N] ',$)
            endif
            read(luusr,'(a)') response
            if (response(1:1).eq.'0') return
            response(1:1) = upper(response(1:1))
            if (response(1:1).eq.' ') response(1:1) = 'N'
            if (response(1:1).ne.'Y'.and.response(1:1).ne.'N') then
              write(luscn,9108) response(1:1)
9108        format(' Invalid prepass response ',a,'. Enter Y or N.')
            else
              dopre = response(1:1)
              ierr=0
            endif
          enddo
        endif ! prepass
      endif ! batch/interactive

      return
      end
