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
      logical function kpcon(lut,idcb,cond,scale,np,iobuf,lst,ibuf,il)
C
      integer*2 ibuf(1)
      double precision scale(1)
      character*(*) iobuf
C
      character*10 cbuf
      integer*2 ib(5)
      equivalence (cbuf,ib(1))
      logical kpout,kpout_ch
C
      data nline/10/
C
      kpcon=.false.
C
      if(np.le.0) return
C
      kpcon=kpout_ch(lut,idcb,'* ',iobuf,lst)
      if(kpcon) return
C
      write(cbuf,'(2x,1pe8.2)') cond
      inext=1
      inext=ichmv_ch(ibuf,inext,' ')
      inext=ichmv(ibuf,inext,ib,1,10)
      if (0.eq.mod(inext,2)) inext=ichmv_ch(ibuf,inext,' ')
      kpcon=kpout(lut,idcb,ibuf,inext,iobuf,lst)
C
      kpcon=kpout_ch(lut,idcb,'* ',iobuf,lst)
      if (kpcon) return
C
      do k=1,np,nline
        inext=1
        do i=k,min0(k+nline-1,np)
          inext=ichmv_ch(ibuf,inext,' ')
          inext=inext+jr2as(sngl(scale(i)),ibuf,inext,-6,1,il)
        enddo
C
        if (0.eq.mod(inext,2)) inext=ichmv_ch(ibuf,inext,' ')
        kpcon=kpout(lut,idcb,ibuf,inext,iobuf,lst)
        if (kpcon) return
        kpcon=kpout_ch(lut,idcb,'* ',iobuf,lst)
        if (kpcon) return
      enddo
C
      return
      end
