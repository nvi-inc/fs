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
      subroutine cants(itscb,ntscb,iflag,index,indts) 
C 
C  CANTS cancels entries depending on IFLAG 
C      1=cancel all procs from the station library
C      2=cancel all procs from the schedule library 
C      3=cancel everything initiated by the operator
C      4=cancel everything initiated by the schedule
C      5=cancel particular command as specified in INDEX,INDTS
C 
      dimension itscb(13,1) 
C 
      do 100 i=1,ntscb
        if (itscb(1,i).eq.-1) goto 100
        ilib = jchar(itscb(10,i),2) 
        isor = jchar(itscb(13,i),2) 
        go to (10,20,30,40,50) iflag
10      if (ichcm_ch(ilib,1,'Q').eq.0) goto 90
          go to 100 
20      if (ichcm_ch(ilib,1,'P').eq.0) goto 90
          go to 100 
30      if (ichcm_ch(isor,1,';').eq.0) goto 90
          go to 100 
40      if (ichcm_ch(isor,1,':').eq.0) goto 90
          go to 100 
50      if(itscb(11,i).ne.index) goto 100 
        if(indts.ne.-1.and.i.ne.indts) goto 100 
90      itscb(1,i) = -1 
        call clrcl(itscb(12,i)) 
100   continue
      return
      end 
