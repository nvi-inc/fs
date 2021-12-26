*
* Copyright (c) 2021 NVI, Inc.
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
      subroutine kgetc(fname,names,cra,cdec,cepoch,icount,max_src)
      implicit none
      integer max_src, icount
      character*(*) names(max_src), fname
      double precision cra(max_src), cdec(max_src)
      real cepoch(max_src)
c
      include '../../include/dpi.i'
c
      character*16 name
      integer rah, ram, decd, decm
      double precision ras, decs
      real epoch
      character*1 sign
c
      open(10,file=fname)
      icount=0
      do while(icount.lt.max_src)
      read(10,*,end=99)
     &      name, rah, ram, ras, sign, decd, decm, decs, epoch
c
c      write(6,'(a,2i3,f8.2,3x,a,2i3,f8.1,f8.1)')
c     &             name, rah, ram, ras, sign ,decd, decm, decs, epoch
c
      icount=icount+1
      cra(icount)=(dble(rah)*60.d0+dble(ram))*60.d0+ras
      cra(icount)=cra(icount)*SEC2RAD
      cdec(icount)=(decs/60.d0+dble(decm))/60.d0+dble(decd)
      cdec(icount)=cdec(icount)*DEG2RAD
      if(sign.eq.'-') cdec(icount)=-cdec(icount)
      names(icount)=name
      cepoch(icount)=epoch
      enddo
      write(6,*) 'Too many sources'
      stop
c
99    continue
      close(10)
      end
