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
      subroutine reftm(itref,itime,char)  !  handle reference times
C 
C     MANIPULATES REFERENCE TIME AND TIME OFFSETS 
C 
C  INPUT: 
C 
      character char
      dimension itref(3)
C     - current reference time
      dimension itime(3)
C     - time array from parsing routine 
C     CHAR  - control character
C            - R set ITREF to ITIME
C            - * add ITIME to ITREF and replace in ITIME
C            - ! add ITIME to current time and replace ITIME
C 
C  OUTPUT:
C 
C     New values of ITREF and ITIME depending on CHAR
C 
C  LOCAL: 
C 
      dimension inow(6) 
C     - holds current time
  
C     IT1,IT2,IT3 - current time in SNAP units
C 
C  SUBROUTINES CALLED:
C 
C     TWRAP - unwraps ITIME if any part overflows 
C     EXEC(11) - to get current time
C 
C  PROGRAMMER: NRV            FILE CREATED 791010
C  LAST MODIFIED:  LAR  <890123.1909>
C 
C 
C     1. First get the current time in case we need it later. 
C 
      call fc_rte_time(inow,inow(6))
      it1 = (inow(6)-1970)*1024 + inow(5)
      it2 = inow(4)*60 + inow(3)
      it3 = inow(2)*100 + inow(1)
C
C     2. First for CHAR=R, establish ITIME as the new ITREF.
C
      if (char.eq.'r') then
        if (itime(1).eq.-1) then
          itref(1) = it1
          itref(2) = it2
          itref(3) = it3
        else
          itref(1) = itime(1)
          itref(2) = itime(2)
          itref(3) = itime(3)
        endif
C
C     3. For CHAR=*, replace ITIME with ITIME+ITREF.
C
      else if (char.eq.'*') then
        itime(1) = itref(1)
        itime(2) = itime(2) + itref(2)
        itime(3) = itime(3) + itref(3) + 1
        call twrap(itime)
      else
C
C     4. Finally, for CHAR=!, replace ITIME with ITIME+current time.
C
        itime(1) = it1
        itime(2) = itime(2) + it2
        itime(3) = itime(3) + it3 + 1
        call twrap(itime)
      endif
C
      return
      end
