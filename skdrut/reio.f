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
C      subroutine reio (mode,idevice,ibuf,length)
       real*4 function reio(mode,idevice,ibuf,length)

       implicit none
C  input
      integer mode,idevice,length
      integer*2 ibuf(*)
C
C      real*4 function reio (mode,idevice,ibuf,length)
C Replacement for REIO exec call on A900.  Reads in a character string and
C passes it back as a Hollerith string.  The function value returned is
C a real*4 with an integer representing the number of characters read in
C saved in the lower 2 bytes.  Devices: stdin = 5, stdout = 6.
C
C      -P. Ryan    12.5.88
C

       character*256 cr
C        - cr   : character string
       character     tc
C        - tc   : character for I/O
       integer     i,trimlen,icrl,ios,ifc
       integer*2 ir(2)
       real*4        rex

       equivalence(ir(1),rex)

C  check whether the length is in words or characters
C  + for words, - for characters

       if (length .lt. 0) then ! characters
         icrl = -length
       else
         icrl = length*2 ! words
       end if

C  read or write?    1=read, 2=write

       if (mode .eq. 1) then
         ios = -1
         do while (ios .ne. 0)
           read(idevice,'(A)',iostat=ios) cr
           if (ios .ne. 0) then
             print*, 'error: ABORTING, error number',ios
             STOP
           end if
         end do
         i = trimlen(cr)
         call char2hol(cr,ibuf,1,i)
       else ! mode == 2
         ifc = 1
         call hol2char (ibuf,ifc,icrl,cr)
         do i=1,icrl
           tc = cr(i:i)
           write(idevice,10) tc
10         format (A,$)
         end do
         write(idevice,20) ! write out newline character
20       format (A)
       end if
       ir(2) = i
       reio  = rex
       end

