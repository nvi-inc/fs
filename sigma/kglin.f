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
      logical function kglin(lu,idcb,ierr,jbuf,il,len,iibuf)
C
      integer leng, ierrg
      integer*2 jbufg(100)
      logical kgot
      common/got/leng,ierrg,jbufg,kgot
C
      integer*2 jbuf(1)
      character*(*) iibuf
C
      logical kread
      integer fmpread,ichcm_ch
C
      kglin=.false.
      if (.not.kgot) goto 10
      kgot=.false.
      len=leng
      ierr=ierrg
      do i=1,min0(il,leng)
        jbuf(i)=jbufg(i)
      enddo
      return
C
10    continue
      call ifill_ch(jbuf,1,il*2,' ')
      len = fmpread(idcb,ierr,jbuf,il*2)
      if (len.gt.0) then
        if(mod(len,2).eq.1) then
          len=len+1
          idum=ichmv_ch(jbuf,len,' ')
        endif
      endif
      if (len.lt.0) return
      kglin=kread(lu,ierr,iibuf)
      if (kglin) return
      ilc=len
      ifc=1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      if (ic1.le.0) goto 10
      if (ichcm_ch(jbuf,1,'*').eq.0) goto 10
C
      return
      end
