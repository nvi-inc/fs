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
      logical function kgpnt(lu,idcb,kuse,lonr,latr,lnofr,ltofr,wlnr,
     +  wltr,mc,len,inp,iibuf,jbuf,il)
C
      include '../include/dpi.i'
C
      character*(*) iibuf
      logical kuse
      real lnofr,ltofr
      dimension idcb(1)
      integer*2 jbuf(il)
      integer ichcm_ch
      double precision gtdbl,lonr,latr
C
      logical kfild,kglin,kfound,kfmp
C
      integer*2 lnfond(13)
C
      data lnfond /  24,2h$d,2hat,2ha ,2hse,2hct,2hio,2hn ,2hno,2ht ,
     /             2hfo,2hun,2hd_/
C          $data section not found
      data kfound/.false./
C
      kgpnt=.false.
C
      if (kfound) goto 100
50    continue
      kgpnt=kglin(lu,idcb,ierr,jbuf,il,len,iibuf) 
      if (kgpnt) return
      if (len.ge.0) goto 55 
      kgpnt=kfmp(lu,0,lnfond(2),lnfond(1),iibuf,0,1)
      return
C 
55    continue
      if (ichcm_ch(jbuf,1,'$data').ne.0) goto 50
      kfound=.true.
C
100   continue
      kgpnt=kglin(lu,idcb,ierr,jbuf,il,len,iibuf)
      if (kgpnt) return
      if (len.lt.0) return
      if (ichcm_ch(jbuf,1,'$').ne.0) goto 105
      call unget(jbuf,ierr,len)
      return
C
105   continue
      ifc=1
      ifield=0
      iferr=0
      ilc=len*2
C
      kuse=igtbn(jbuf,ifc,ilc,ifield,iferr).eq.1
      lonr=gtdbl(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      latr=gtdbl(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      lnofr=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      ltofr=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      wlnr=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
      wltr=gtrel(jbuf,ifc,ilc,ifield,iferr)*deg2rad
C
      kgpnt=kfild(lu,iferr,-iferr,inp+1,iibuf)
C
      return
      end
