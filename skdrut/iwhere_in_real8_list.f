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
C     Last change:  JG    9 Nov 2006    9:19 am
!     Last change:  JG   24 Oct 2005   11:34 am
!*************************************************************************
      function iwhere_in_real8_list(r8list,num_list,value)
      implicit none  !2020Jun15 JMGipson automatically inserted.
      INTEGER iwhere_in_real8_list
      INTEGER num_list
      real*8 r8list(*),value

      do iwhere_in_real8_list=1,num_list
        IF(value .EQ. r8list(iwhere_in_real8_list)) return
      end do
      iwhere_in_real8_list=0
      return
      END

