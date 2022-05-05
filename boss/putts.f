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
      subroutine putts(itscb,ntscb,it,itype,index,iclass,lsor,ierr)
C 
C     PUTTS puts information into the time-schedule list
C 
C  INPUT: 
C 
C     ITSCB - array holding time-schedule information 
C     NTSCB - maximum number of entries in ITSCB
C     IT - time parameters with this command
C     ITYPE, INDEX - type, index of this command
C     ICLASS - class with complete command, sans time info
C     LSOR - source of this command 
      dimension itscb(13,1),it(9) 
C 
C  OUTPUT:
C 
C     IERR - error return 
C 
C 
C  LOCAL: 
C 
      dimension inow(5) 
C 
      if (it(1).eq.-2) then
        call cants(itscb,ntscb,5,index,-1)  
        call clrcl(iclass)
        return
      endif
C 
      if (it(1).eq.-1) then   !!NOW WAS SPECIFIED, CONVERT TO ACTUAL HMS
        call fc_rte_time(inow,iyd)
        it(1) = (iyd-1970)*1024 + inow(5) 
        it(2) = inow(4)*60 + inow(3)
        it(3) = inow(2)*100 + inow(1)  !! Put NOW + 1 sec into block
      endif
C 
C     NOW FIND A SLOT TO PUT THIS TIME-SCHEDULING INTO
      do i=1,ntscb
        if (itscb(1,i).eq.-1) goto 320
      enddo
      ierr = -1 
      return          !!! NO ROOM AT THE INN
C 
320   ind = i 
      do i=1,9
        itscb(i,ind) = it(i)
      enddo
      itscb(10,ind) = itype 
      itscb(11,ind) = index 
      itscb(12,ind) = iclass
      idummy = ichmv_ch(lsor,1,'@') 
      itscb(13,ind) = lsor
C
      return
      end 
