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
      function ivcat(ivc,it,itn,irep) 
C 
C  INPUT: 
C     IVC - VC #
C     ITN - track counter (not used if IREP=-1) 
C 
C  OUTPUT:
C     IT - array with tracks
C     ITN - updated for next track
C 
      include '../include/fscom.i'
C 
      dimension it(1),inum(5) 
      data inum/1,2,2,28,4/ 
C 
      ivcat = 1 
      call fs_get_imodfm(imodfm)
      nmod = inum(imodfm+1) 
      if (irep.eq.3) nmod = 1 
      is = 0
      itrem = itn 
      do 110 i = 1,nmod 
          ichk = ivc2t(ivc,is)
          if (ichk.eq.0) goto 120 
          if (irep.eq.-1) then
            it(ichk) = 100
          else
            it (itn) = ichk 
            if (i.ne.nmod) itn = itn+1
          end if
          is = ichk+1 
110       continue
      return
120   if (is.eq.0) ivcat = 0
      if (is.ne.0.and.irep.ne.-1) itn = itn-1 
      return
      end 
