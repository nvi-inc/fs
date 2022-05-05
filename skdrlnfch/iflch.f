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
      function iflch(ibuf,ilen)

! AEM 20050112 add implicit none
      implicit none

C     IFLCH - finds the last character in the buffer
C             by lopping off trailing blanks
C
C
C  INPUT:
C
!      dimension ibuf(1)
! AEM 20050112 list variables
      integer iflch,ilen
      integer*2 ibuf(*)

      integer nb,i
C     ILEN - length of IBUF in CHARACTERS 
C 
C 
C  OUTPUT:
C 
C     IFLCH - number of characters in IBUF
C 
C 
C  LOCAL:
! AEM 20050112 char->char*1
      character*1 cjchar
C 
C     LTERM - termination character 
C 
C 
C  INITIALIZED: 
C
C 
C  PROGRAMMER:  NRV 
C  LAST MODIFIED 800825 
C 
C 
C     1. Step backwards through the buffer, deleting any
C     blanks as we come to them.
C 
      nb = 0
      do 100 i=ilen,1,-1
        if (cjchar(ibuf,i).eq.' ') nb = nb + 1 
        if (cjchar(ibuf,i).ne.' ') goto 101
100     continue
101   iflch = ilen - nb 

! AEM 20050112 commented return
!      return
      end 
