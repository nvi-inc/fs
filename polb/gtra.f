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
      real function gtra(jbuf,ifc,ilc,ifield,iferr)
C
      double precision das2b
C
      include '../include/dpi.i'
C
      integer ichcm_ch
C
      ifield=ifield+1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      irh=ias2b(jbuf,ic1,2)
      irm=ias2b(jbuf,ic1+2,2)
      ras=das2b(jbuf,ic1+4,ic2-(ic1+4)+1,jerr)
      if ((ic1.le.0 .or.
     +   irh .eq. -32768 .or.
     +   irm .eq. -32768 .or.
     +   irs .eq. -32768 .or.
     +   jerr.ne.      0 .or.
     +   (ic2 .ne. ic1+5  .and. ichcm_ch(jbuf,ic1+6,'.').ne.0)
     +   ) .and.iferr.ge.0) iferr=-ifield
      ra=float(irh)*3600.d0+float(irm)*60.d0+
     +   ras*1.0d0
      gtra=ra*sec2rad

      return
      end
