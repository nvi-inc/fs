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
      function ivc2t(ivc,is)
C   finds track given vc#870115:04:51   # 
C 
C     Given a VC number as input, IVC2T finds the tracks
C     associated with that VC, and checks which one has 
C     phase cal., by calling PHCAL
C     INPUT:
C       IVC - VC number 
C 
C     OUTPUT: 
C       IVC2T - track number with phase cal 
C 
C     LOCAL:
      double precision pcal 
      include '../include/fscom.i'
C 
      ist = is
      if (ist.eq.0) ist = 1 
      call fs_get_imodfm(imodfm)
      do 100 i = ist,28 
          if (ivc.ne.iabs(itr2vc(i,imodfm+1))) goto 100 
          call phcal(pcal,i,iv) 
          if (pcal.le.50000.) goto 980
100       continue
      ivc2t = 0 
      return
980   ivc2t = i 
      end 
