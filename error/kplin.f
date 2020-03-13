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
      logical function kplin(lut,idcb,parr,np,qarr,nq,imdl,it,ipar,
     + phi,iobuf,lst,ibuf,il)
C
      dimension parr(np),qarr(nq),it(6),ipar(np)
      integer*2 ibuf(1)
      character*(*) iobuf
      double precision parr,qarr,phi
      include '../include/dpi.i'
C
      logical kpout,kpout_ch
C
      data nline/5/
C
      kplin=.false.
C
      if (np.le.0) return
C
      kplin=kpout_ch(lut,idcb,'* ',iobuf,lst)
      if (kplin) return
C
      inext=1
      inext=ichmv_ch(ibuf,1,'  ')
      inext=inext+ib2as(imdl,ibuf,inext,o'40000'+o'400'*5+5)
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+ib2as(it(6),ibuf,inext,o'40000'+o'400'*4+4)
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+ib2as(it(5),ibuf,inext,o'40000'+o'400'*3+3)
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+ib2as(it(4),ibuf,inext,o'40000'+o'400'*2+2)
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+ib2as(it(3),ibuf,inext,o'40000'+o'400'*2+2)
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+ib2as(it(2),ibuf,inext,o'40000'+o'400'*2+2)
      inext=ichmv_ch(ibuf,inext,' ')
C
      kplin=kpout(lut,idcb,ibuf,inext,iobuf,lst)
      if (kplin) return
C
      kplin=kpout_ch(lut,idcb,'* ',iobuf,lst)
      if (kplin) return
C
      inext=1
      inext=ichmv_ch(ibuf,inext,'  ')
      inext=inext+jr2as(sngl(phi*rad2deg),ibuf,inext,-8,4,il)
      inext=ichmv_ch(ibuf,inext,' ')
      do i=1,np
        inext=ichmv_ch(ibuf,inext,' ')
        inext=inext+ib2as(abs(ipar(i)),ibuf,inext,1)
        if (mod(i,5).eq.0.and.i.ne.np) inext=ichmv_ch(ibuf,inext,' ')
      enddo
C
      if (0.eq.mod(inext,2)) inext=ichmv_ch(ibuf,inext,' ')
  
      kplin=kpout(lut,idcb,ibuf,inext-1,iobuf,lst)
      if (kplin) return
C
      kplin=kpout_ch(lut,idcb,'* ',iobuf,lst)
      if (kplin) return
C
      do j=1,np,nline
        inext=1
        do i=j,min0(j+nline-1,np)
          inext=ichmv_ch(ibuf,inext,'  ')
          inext=inext+jr2as(sngl(parr(i)*rad2deg),ibuf,inext,-13,10,il)
        enddo
C
        if (0.eq.mod(inext,2)) inext=ichmv_ch(ibuf,inext,' ')
        kplin=kpout(lut,idcb,ibuf,inext-1,iobuf,lst)
        if (kplin) return
        if (nq.le.0) goto 25
C
        inext=1
        do i=j,min0(j+nline-1,nq)
          inext=ichmv_ch(ibuf,inext,'  ')
          inext=inext+jr2as(sngl(qarr(i)*rad2deg),ibuf,inext,-13,10,il)
        enddo
C
        if (0.eq.mod(inext,2)) inext=ichmv_ch(ibuf,inext,' ')
        kplin=kpout(lut,idcb,ibuf,inext-1,iobuf,lst)
        if (kplin) return
C
25      continue
        kplin=kpout_ch(lut,idcb,'* ',iobuf,lst)
        if (kplin) return
      enddo
C
      return
      end
