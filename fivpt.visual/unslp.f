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
      subroutine unslp(tmplin,timlin,temp,tim,npts,slope,const) 
      dimension tmplin(2),timlin(2),temp(npts),tim(npts)
C 
C   REMOVE A LINEAR SLOPE AND A CONSTANT, DETERMINED FROM TMPLIN, 
C       FROM THE DATA IN TEMP 
C 
C  INPUT: 
C 
C      TMPLIN - ARRAY HOLDING THE TEMPERATURE DRIFT INFORMATION 
C 
C      TIMLIN - THE TIME COORDIANTE OF THE TMPLIN DATA
C 
C      TEMP   - THE DATA TO BE CORRECTED
C 
C      TIM    - THE TIME COORDINATE OF THE DATA 
C 
C      NPTS   - NUMBER OF POINTS IN TEMP AND TIM
C 
      slope=(tmplin(2)-tmplin(1))/(timlin(2)-timlin(1)) 
      tmid=tim((npts+1)/2)
      const=tmplin(1)+slope*(tmid-timlin(1))
      do i=1,npts
        temp(i)=temp(i)-((tim(i)-tmid)*slope+const)  
      enddo

      return
      end 
