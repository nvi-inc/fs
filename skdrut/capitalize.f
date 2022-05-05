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
!     Last change:  JMG  23 Sep 1999   11:19 am
!***********************************************************************
      subroutine capitalize(lstring)

      CHARACTER*(*) lstring
      idiff=ICHAR("a")-ICHAR("A")
      ilen=LEN(lstring)
      do i=1,ilen
         IF(lstring(i:i) .GE. "a" .AND. lstring(i:i) .LE. "z") then
                 lstring(i:i)=CHAR(ICHAR(lstring(i:i))-idiff)
          endif
      END do
      return
      end
