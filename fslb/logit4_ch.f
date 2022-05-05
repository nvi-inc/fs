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
      subroutine logit4_ch(cmessg,lsor,lprocn)
      character*(*) cmessg

      include '../include/fscom.i'

      integer*2 lmessg(128)
      dimension lprocn(1)
      lwhat=0
      lwho=0
      ierr=0
      nchar=len(cmessg)
      if(nchar.gt.256) then
         call put_stderr('logit4_ch message length >256\n'//char(0))
         stop 999
      endif
      call char2hol(cmessg,lmessg,1,nchar)
      call logit(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,4)
      return
      end 
