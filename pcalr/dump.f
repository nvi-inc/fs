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
      subroutine dump(ctype,resp)
c
c  Request, read, and convert numeric values from the spectrum analyzer.
c
      dimension resp(1)                     !  list of numeric responses
      character*2 ctype                     !  2nd and 3rd letters of command
      include '../include/fscom.i'
c
      parameter (lenbuf=2560)
      dimension lcmd(2)                     !  complete command buffer
      dimension lresp(lenbuf/2)             !  ascii response buffer
c
      if (ctype.eq.'ds') then
        nvals = 256                         !  number of parameters expected
        length = lenbuf                     !  # of characters in response
      else if (ctype.eq.'mk') then
        nvals = 2
        length = 20
      else
        nvals = 1
      endif
      call char2hol('l-- ',lcmd,1,4)
      call ichmv_ch(lcmd,2,ctype)
cxx      call exec(2,lusa,lcmd,-3)
cxx      call exec(1,lusa,lresp,-length)
      iplace = 1                            !  placeholder in lresp
      do i=1,nvals
        call gtprm(lresp,iplace,length,2,resp(i),ierr)
      enddo

      return
      end
