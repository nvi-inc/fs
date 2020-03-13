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
      FUNCTION IHXW2AS(IN,IOUT,IC,NC)
      character*16 lhex
      data lhex/'0123456789abcdef'/
c
      ins=in
      DO I=NC,1,-1
        iv=and(ins,15)        
        call char2hol(lhex(iv+1:iv+1),iout,ic+i-1,ic+i-1)
        ins=ishft(ins,-4)
      enddo
      do i=ic,ic+nc-2
         if(ichcm_ch(iout,i,"0").ne.0) return
         idum=ichmv_ch(iout,i," ")
      enddo
      
      IHXW2AS=IC+NC   
      RETURN
      END
