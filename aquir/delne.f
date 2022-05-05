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
      subroutine delne(jbuf,ifc,ilc,lsorna,ra,dec,epoch,lcpre,iwpre,
     +                 iwfiv,iwonof,iwpeak,lcpos,iwpos,mc,mprc,iferr)
C
      integer*2 jbuf(1),lsorna(mc),lcpre(mprc),lcpos(mprc)
C
      iferr=1
      ifield=0
C
C SOURCE NAME
C
      call gtchr(lsorna,1,mc*2,jbuf,ifc,ilc,ifield,iferr)
      call lower(lsorna,mc*2)
C
C  RA
C
      ra=gtra(jbuf,ifc,ilc,ifield,iferr)
C
C DEC
C
      dec=gtdc(jbuf,ifc,ilc,ifield,iferr)
C
C  EPOCH
C
      epoch=gtrel(jbuf,ifc,ilc,ifield,iferr)
C
C  PRE OB PROCEDURE
C
      call gtchr(lcpre,1,mprc*2,jbuf,ifc,ilc,ifield,iferr)
C
C  PRE OB WAIT
C
      iwpre=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C FIVEPT POINT WAIT
C
      iwfiv=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C ONOFF WAIT
C
      iwonof=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C PEAKF WAIT
C
      iwpeak=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
C  POST OB PROCEDURE
C
      call gtchr(lcpos,1,mprc*2,jbuf,ifc,ilc,ifield,iferr)
C
C  POST OB WAIT
C
      iwpos=igtbn(jbuf,ifc,ilc,ifield,iferr)
C
      return
      end
