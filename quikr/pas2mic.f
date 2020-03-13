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
      subroutine pas2mic(ihead,ipass,micron,ip,indxtp)
      integer ihead,ipass,ip(5)
      real*4 micron
C
C  PAS2MIC: convert pass number to micron position
C
C  INPUT:
C     IHEAD: head to convert pass to microns: 1 or 2
C     IPASS: pass to look up position of: positive integer less than
C            or equal to maximum defined pass number
C
C  OUTPUT:
C     MICRON: determined position
C     IP: Field System return parameters
C     IP(3) = 0 if no error
C           = -403 if pass number is undefined
C
      include '../include/fscom.i'
C
      if(itapof(ipass,indxtp).gt.-13000) then
        micron=itapof(ipass,indxtp)
      else
        ip(3)=-403
        call char2hol('q@',ip(4),1,2)
        return
      endif
C
      return
      end
