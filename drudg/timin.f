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
      subroutine timin(cbuf,cti,ctiformat,cctiformat,iyear)
      include '../skdrincl/skparm.ftni'
C Decode time commands read from the SNAP file.
C 980916 nrv Extracted from lstsum
C 000601 nrv Initialize the format to blank so that it can be
C            check for validity on return.
C 000606 nrv Don't re-initialize these, don't save cti if it's not valid.

C Input
      character*(*) cbuf
      integer iyear ! from SNAP file, modified on output if
C                     the time field contains the year
C Output
      character*(*) cti ! time field 
      character*(*) ctiformat ! its appropriate format statement
      character*(*) cctiformat ! format for reading characters
C Local

C     ctiformat=' '
C     cctiformat=' '
      if (cbuf(2:2).ge.'0'.and.cbuf(2:2).le.'9') then ! absolute time
        if (index(cbuf,'.').ne.0) then ! punctuation
          ctiformat='(4x,1x,i3,3(1x,i2))'
          cctiformat='(4x,1x,a3,3(1x,a2))'
          cti = cbuf(2:18)
          read(cti,'(i4)') iyear
        else ! numbers only
          ctiformat='(i3,3i2)'
          cctiformat='(a3,3a2)'
          cti = cbuf(2:10)
        endif ! punctuation/numbers
      endif ! absolute time
      return
      end
