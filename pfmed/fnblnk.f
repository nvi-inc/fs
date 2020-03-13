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
      integer function fnblnk(string,ipos)
c
c  Finds the first nonblank character in string at IPOS or after
c
      character*(*) string
      data iblank/32/
c
      ilen = len(string)
      if(ipos.gt.ilen) then
          fnblnk = 0
          return
      endif
      do 10 i = ipos,ilen
          if(ichar(string(i:i)).ne.iblank) then
              fnblnk = i
              return
          endif
 10   continue
c  Did not find it
      fnblnk = 0
      return
      end
