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
      subroutine incsm(luse,lonsum,lonrms,wlnsum,lnofr,wln,latsum,
     +                 latrms,wltsum,ltofr,wlt,dirms,wdisum,distr,
     +                 crssum,crsrms,wcrsum,np,igp,feclon,feclat,coslt,
     +                 iflags)
C
      double precision lonsum,lonrms,wlnsum,latsum,latrms,wltsum,dirms
      double precision ddisr,dwln,dwlt,wdisum,dwdi,crssum,crsrms
      double precision dlnof,dltof,wcrsum,dwcr
      real lnofr,ltofr,distr,coslt
      logical kbit
C
      if (.not.kbit(luse,np)) return
      igp=igp+1
      dlnof=dble(lnofr)
      dltof=dble(ltofr)
      ddisr=dble(distr)
      dwlt=dble(wlt*wlt+sign(feclat*feclat,feclat))
      if(and(iflags,1).eq.1) then
         dwln=dble(wln*wln
     +        +sign(feclon*feclon/(coslt*coslt),feclon))
         dwcr=dble(wln*wln*coslt*coslt+sign(feclon*feclon,feclon))
      else
         dwln=dble(wln*wln+sign(feclon*feclon,feclon))
         dwcr=dble(wln*wln+sign(feclon*feclon,feclon))*coslt*coslt
      endif
      dwdi=dwln*coslt*coslt+dwlt
      dwln=1.0d0/dwln
      dwlt=1.0d0/dwlt
      dwdi=1.0d0/dwdi
      dwcr=1.0d0/dwcr
C
      lonsum=lonsum+dlnof*dwln
      latsum=latsum+dltof*dwlt
      crssum=crssum+dlnof*coslt*dwcr
C
      lonrms=lonrms+(dlnof*dlnof)*dwln
      latrms=latrms+(dltof*dltof)*dwlt
      dirms= dirms+(distr*distr)*dwdi
      crsrms=crsrms+(dlnof*dlnof*coslt*coslt)*dwcr
C
      wlnsum=wlnsum+dwln
      wltsum=wltsum+dwlt
      wdisum=wdisum+dwdi
      wcrsum=wcrsum+dwcr
C
      return
      end
