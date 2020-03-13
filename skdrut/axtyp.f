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
C
      subroutine axtyp(caxis,iaxis,ix)
      implicit none

C     AXTYP converts between the hollerith names
C     of axis type and the code number used in SKED

C  History
C  900125 NRV Created to replace duplicated code in several routines.
C  2004Feb04 JMGipson. Changed to string instead of holerith
!  2006Nov16 JMGipson. Changed  to use list. 
      

C  Input
!      integer*2 laxis(2) !  axis type name
      character*4 caxis
      integer iaxis    !  axis type code
      integer ix       ! 1=convert name-->code     
C                          2=convert code-->name
C  Output
C     Either laxis or iaxis is output, depending on ix
C  Local
! funciton
      integer iwhere_in_string_list
      integer num_axis
      parameter (num_axis=8)
      character*4  caxis_list(num_axis)
      data caxis_list/"HADC","XYEW","AZEL","XYNS","RICH","SEST","ALGO",
     >  "----"/

C     1. Name --> code
      if(ix .eq. 1) then
        iaxis=iwhere_in_string_list(caxis_list,num_axis,caxis)
      else 
        if(iaxis .ge. 1 .and. iaxis .le. num_axis) then
          caxis=caxis_list(iaxis)
        else
         caxis="----"
        endif
      endif
      
      return
      end
