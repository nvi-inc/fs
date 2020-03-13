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
      subroutine gnext(lut,idcb,ierr,jbuf,il,len,ifc,ilc) 
C
      dimension idcb(1)
      integer*2 jbuf(1)
      integer fmpread,ichcm_ch
C 
10    continue
      len=fmpread(idcb,ierr,jbuf,il*2)
      if (len.gt.0) then
        if (mod(len,2).eq.1) then
          len=len+1
          idum=ichmv_ch(jbuf,len,' ')
        endif
      endif
      if(ierr.ne.0.or.len.lt.0) return
C
      call lower(jbuf,len)
      ilc=len
      ifc=1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      if (ic1.le.0) goto 10
      if (ichcm_ch(jbuf,1,'*').eq.0) goto 10
      if (ichcm_ch(jbuf,11,'fivpt#').eq.0) goto 100
      if (ichcm_ch(jbuf,15,'fivpt#').eq.0) goto 200
C not Y10K compliant
      if (ichcm_ch(jbuf,22,'fivpt#').eq.0) goto 300
C
C  MAKE SURE THIS IS IN LOG ENTRY FORMAT
C
C    IF NOT, JUST RETURN IT
C 
      if (ias2b(jbuf,1,4).ne.-32768.and.ias2b(jbuf,5,4).ne.-32768
     +   .and.ias2b(jbuf,9,2).ne.-32768) goto 10 
      ifc=1 
      goto 1000
C 
100   continue
      ifc=17
      goto 1000
C 
 200  continue
      ifc=21
      goto 1000
C
 300  continue
C not Y10K compliant
      ifc=28
      goto 1000
c
1000  continue
      ilc=len 
C 
      return
      end 
