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
      subroutine pcalx(smprat,iblokn,rsinb,rcosb,rnbitb,rsina,rcosa,
     . rnbita,idata,ilog,pcal,pcala,ksplit)
C 
C     This routine accumulates RSIN, RCOS and RNBIT over all
C     the words in a block. 
C 
C    MAH DEC `81 - based on algorithm by CAK
C 
      logical ksplit
C 
      integer*2 idata(1)
C 
      double precision pcal,pcala,bfact,afact 
      double precision rsina,rsinb,rcosa,rcosb,rnbita,rnbitb
C 
C 
      nt = ilog/2 
      if (ksplit) nt = nt/2 
      ib = 2
      if (ksplit) ib = 1
      indx = 0
      bfact = (2048.*8.*float(ib*iblokn))/(9.*smprat) 
      afact = 128./(9.*smprat)
      tcal = 1.d0/pcal
100   rsin = 0.0
      rcos = 0.0
      rnbit = 0.0 
      afc = afact 
      a = -0.5
      do 150 nw=1,nt
          a = a+1.0 
          time = afc*a+bfact
          rem = (amod(time,tcal))/tcal
          n1 = i1bit(idata(indx+nw))
          rnbit = rnbit+16
          if (rem.lt.0.5) goto 110
          rsin = rsin+(16-n1) 
          goto 111
110       rsin = rsin+n1
111       if (rem.gt.0.25.and.rem.le.0.75) goto 112 
          rcos = rcos+n1
          goto 150
112       rcos = rcos+(16-n1) 
150       continue
C 
      if (indx.ne.0) goto 200 
      rsinb = rsin+rsinb
      rcosb = rcos+rcosb
      rnbitb = rnbit+rnbitb 
      if (.not.ksplit) goto 990 
      indx = nt 
      tcal = 1.d0/pcala 
      goto 100
200   rsina = rsin+rsina
      rcosa = rcos+rcosa
      rnbita = rnbit+rnbita 
990   continue

      return
      end 
