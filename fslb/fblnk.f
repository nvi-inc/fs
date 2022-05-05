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
      integer function fblnk(ibuf,ifc,ilc)
c
      implicit none
cxx      integer ibuf(1)
      integer*2 ibuf(1)
      integer ifc,ilc
      integer i,inext,ilen,ichmv,ichcm_ch,ichmv_ch
      logical kfirst
c
      fblnk=0
      ilen = ilc-ifc+1
      if (ilen.le.0) then
        return
      endif
c
c delete leading blanks
c
      inext=ifc
      kfirst=.false.
      do i = ifc,ilc
        if(ichcm_ch(ibuf,i,' ').ne.0.or.kfirst) then
          kfirst=.true.
          inext=ichmv(ibuf,inext,ibuf,i,1)
        endif
      end do
c
C   return the length of array minus what was taken off.
c
      fblnk = inext-ifc
C
C  BLANK PAD TO THE END
c
      do while(inext.le.ilc)
        inext=ichmv_ch(ibuf,inext,'  ')
      enddo
      return
      end
