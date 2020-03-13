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
      subroutine nrmlz(kfield,ksplit,rsinb,rcosb,rnbitb,rsina,rcosa,
     . rnbita,ivc,ivc2,itrk,kcorel,nzero,r1bit)
C 
      include '../include/fscom.i'
      include '../include/dpi.i'
C 
      double precision rnbita,rnbitb,rsina,rcosa,rsinb,rcosb,fnbit
C 
      logical ksplit,kfield,kcorel
C 
C  Normalize
C 
C 
      if (.not.kcorel) goto 110 
      correl = nzero*100./r1bit 
C 
110   fnbit = 0.5*rnbitb
      rsin = (rsinb-fnbit)/fnbit
      rcos = (rcosb-fnbit)/fnbit
      brsin = sin(rsin*dpi/2)
      brcos = sin(rcos*dpi/2)
      ampb = 100.*sqrt(brsin*brsin+brcos*brcos) 
      phaseb = -atan2(rsin,rcos)*180./dpi
C 
      if (.not.ksplit) goto 990 
      fnbit = 0.5*rnbita
      rsin = (rsina-fnbit)/fnbit
      rcos = (rcosa-fnbit)/fnbit
      arsin = sin(rsin*dpi/2)
      arcos = sin(rcos*dpi/2)
      ampa = 100.*sqrt(arsin*arsin+arcos*arcos) 
      phasea = -atan2(rsin,rcos)*180./dpi
C 
C      - Calculate delay
C 
      if (.not.kfield) goto 990 
      dlyab = phasea-phaseb 
      if (dlyab.lt.-180.) dlyab = 360.+dlyab
      if (dlyab.gt.180.) dlyab = 360.-dlyab 
      call fs_get_freqvc(freqvc)
      dlyab = abs(dlyab/(freqvc(ivc)-freqvc(ivc2))) 
990   continue
C 
C     Call MESSG to log the calculated values 
C 
      call messg(kfield,ksplit,ampa,phasea,ampb,phaseb,dlyab,itrk,
     . ivc,ivc2,kcorel,correl)

      return
      end 
