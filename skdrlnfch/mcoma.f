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
      function mcoma(ibuf,ich)

! AEM 20050112 implicit none, list variables
      implicit none
      
      integer*2 ibuf(*)
      integer mcoma,ich,ichmv_ch

C     MOVE A COMMA INTO CHARACTER ICH OF IBUF 
C     RETURNS THE NEXT AVAILABLE CHARACTER (ICH+1)

      mcoma = ichmv_ch(ibuf,ich,',')

! AEM 20050112 commented return
!      return
      end 
