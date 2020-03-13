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
      logical function kreof(lut,ierr,len,irec,ipbuf)

      logical kfmp
      character*(*) ipbuf
C
      integer*2 lpeof(23),lred(16)
C
      data lpeof  /  44,2Hpr,2Hem,2Hat,2Hur,2He ,2Heo,2Hf ,2Hbe,2Hfo,
     /             2Hre,2H r,2Hea,2Hdi,2Hng,2H r,2Hec,2Hor,2Hd ,2Hxx,
     /             2Hxx,2H i,2Hn_/
C          premature eof before reading record xxxx in_
      data lred   /  30,2Hbe,2Hfo,2Hre,2H r,2Hea,2Hdi,2Hng,2H r,2Hec,
     /             2Hor,2Hd ,2Hxx,2Hxx,2H i,2Hn_/
C          before reading record xxxx in_

      kreof=.false.
      if (len.ge.0) goto 10
      ifc=37
      ifc=ifc+ib2as(irec,lpeof(2),ifc,o'100000'+4)
      ifc=ichmv_ch(lpeof(2),ifc,' in_')
      kreof=kfmp(lut,ierr,lpeof(2),ifc-1,ipbuf,0,1)
      return
C
10    continue
      if (ierr.eq.0) return
      ifc=23
      ifc=ib2as(irec,lred(2),ifc,o'100000'+4)
      ifc=ichmv_ch(lred(2),ifc,' in_')
      kreof=kfmp(lut,ierr,lred(2),ifc-1,ipbuf,0,1)
C
      return
      end
