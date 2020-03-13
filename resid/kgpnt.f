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
      logical function kgpnt(lu,idcb,kuse,lonr,latr,lnofr,ltofr,len,inp,
     + iibuf,jbuf,il,lstrng,ic)
C
      real lonr,lnofr,latr,ltofr
      character*(*) iibuf
      integer*2 idcb(1)
      integer*2 jbuf(1),lstrng(1)
      integer ichcm_ch
C
      logical kfild,kglin,kfound,kfmp,kuse
C
      integer*2 lnfond(11)
C
      data lnfond/19,2h s,2hec,2hti,2hon,2h n,2hot,2h f,2hou,2hnd,2h_ /
C           section not found
      data kfound/.false./
C
      kgpnt=.false.
C
      if (kfound) goto 100
50    continue
      kgpnt=kglin(lu,idcb,ierr,jbuf,il,len,iibuf)
      if (kgpnt) return
      if (len.ge.0) goto 55 
      inext=1 
      inext=ichmv(jbuf,inext,lstrng,1,min0(ic,il*2-lnfond(1)))
      inext=ichmv(jbuf,inext,lnfond(2),1,lnfond(1)) 
      kgpnt=kfmp(lu,0,jbuf,inext-1,iibuf,0,1) 
      return
C 
55    continue
      if (ichcm(jbuf,1,lstrng,1,ic).ne.0) goto 50 
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
      ilc=len*2 
      ifield=0
      iferr=0 
C 
      kuse=igtbn(jbuf,ifc,ilc,ifield,iferr).eq.1
      lonr=gtrel(jbuf,ifc,ilc,ifield,iferr) 
      latr=gtrel(jbuf,ifc,ilc,ifield,iferr) 
      lnofr=gtrel(jbuf,ifc,ilc,ifield,iferr)
      ltofr=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
      kgpnt=kfild(lu,iferr,-iferr,inp+1,iibuf)
C
      return
      end
