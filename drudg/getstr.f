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
      Subroutine getstr(instring,ix,outstring)
C     Scans "instring" and returns the next blank-delimited field
C     as "outstring".  Similar to LNFCH's GTFLD.
C   Input:
      character*128 instring
      integer ix ! which character to start with in instring
C       NOTE: the value of ix is CHANGED by this routine
C   Output:
      character*128 outstring
C     ix  ! index of next character after the end of outstring
c                   (used for subsequent scans)
C
      outstring=''
      i=ix
      do while (index(instring(i:),' ').ne.1)
        i=i+1
      enddo
      i1=i
      ix=index(instring(i1:),' ')
      if (ix.eq.0) ix=len(instring)+1
      outstring=instring(i1:ix-1)
      return
      end
