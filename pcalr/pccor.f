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
      subroutine pccor(ivc,ivc2,itrk,kcorel,idata,ilog,r1bit, 
     . nzero)
C 
C     This routine first checks to see that the split mode data 
C     comes from VC's on the same frequency and side band, and
C     then checks to see if the data streams are the same.
C 
C  INPUT: 
C     IVC - first VC
C     IVC2 - second VC
C     ITRK - track on first VC
      logical kcorel
C      - true if data was correlated
      dimension idata(1)
C      - holds the data 
C     ILOG - length of IDATA in chars 
C 
C  OUTPUT:
C     R1BIT - number of bits counted
C     NZERO - number of non-matching bits 
C 
      include '../include/fscom.i'
C 
      kcorel = .false.
      call fs_get_freqvc(freqvc)
      if (freqvc(ivc).ne.freqvc(ivc2)) goto 990 
      call fs_get_imodfm(imodfm)
      lsb1 = itr2vc(itrk,imodfm+1)
      lsb2 = itr2vc(itrkpc(itrk),imodfm+1)
      if ((lsb1.gt.0.and.lsb2.lt.0).or.(lsb1.lt.0.and.lsb2.gt.0)) 
     . goto 990 
C 
      do 150 i = 1,ilog/4 
          r1bit = r1bit+16
          if (idata(i).eq.idata(i+128)) goto 150
          ibit = and(idata(i),idata(i+128))
          nzero = nzero+(16-i1bit(ibit))
150       continue
      kcorel = .true. 
C 
990   continue

      return
      end 
