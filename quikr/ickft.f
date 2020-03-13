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
      function ickft(ibrk,inewft,icurft,idir,ip)
C  check footage status   .c#870115:04:34# 
C 
C    READ FOOTAGE COUNTER AND RETURN REMAINING FEET TO GO.
C 
      integer*2 ibuf(10)
      dimension ip(5)
      dimension ireg(2)
      integer get_buf
      data ilen/20/ 
C 
      ibrk = 1
cxx      if(ifbrk(idum).lt.0) return 
      ibrk = 0  
cxx      call susp(1,50)   
      call susp(2,1)   
      ibuf(1) = -3
      call char2hol('tp',ibuf(2),1,2)
      iclass = 0
      call put_buf(iclass,ibuf,-4,'fs','  ') 
      call run_matcn(iclass,1) 
      call rmpar(ip)
      iclass = ip(1)
89    format("iclass, ip ",6i10)
      if (ip(3).ge.0) goto 150
        call clrcl(iclass)
        ip(1) = 0 
        ip(2) = 0 
        goto 990
150   ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum) 
      icurft = ias2b(ibuf,7,4)
      if(icurft.gt.10000) icurft = icurft - 20000 
      ickft = icurft - inewft 
      if(idir.eq.0.and.ickft.lt.0) ickft = 0
      if(idir.eq.1.and.ickft.gt.0) ickft = 0
      ickft = iabs(ickft) 
990   return
      end 
