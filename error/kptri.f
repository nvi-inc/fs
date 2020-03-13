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
      logical function kptri(lut,idcb,a,np,iobuf,lst,ibuf,il)
C
      integer*2 ibuf(1)
      character*(*) iobuf
      double precision a(1)
C
      logical kpout,kpout_ch
C
      data nline/10/
C
      kptri=.false.
C
      if (np.le.0) return
C
      kptri=kpout_ch(lut,idcb,'* ',iobuf,lst)
      if (kptri) return
C
      nxpnt=0
      do k=1,np
        do j=1,k,nline
          inext=1
          do i=j,min0(j+nline-1,k)
            inext=ichmv_ch(ibuf,inext,' ')
            nxpnt=nxpnt+1
            inext=inext+jr2as(sngl(a(nxpnt)),ibuf,inext,-6,3,il)
          enddo
C
          if (0.eq.mod(inext,2)) inext=ichmv_ch(ibuf,inext,' ')
          kptri=kpout(lut,idcb,ibuf,inext,iobuf,lst)
          if (kptri) return
        enddo
        kptri=kpout_ch(lut,idcb,'* ',iobuf,lst)
        if (kptri) return
      enddo
C
      return
      end
