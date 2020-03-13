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
      subroutine depnt(jbuf,ifc,ilc,ipos,tim,pos,temp,n,ier,nd) 
C
      dimension tim(nd),pos(nd),temp(nd),ipos(nd) 
C
      integer*2 jbuf(1)
C 
      ifield=0
      iferr=1 
C 
C  INDEX NUMBER 
C 
      ipt=igtbn(jbuf,ifc,ilc,ifield,iferr)
C 
C  TIME SINCE MIDNIGHT
C 
      tima=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C  OFFSET 
C 
      posa=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C  TEMPERATURE
C 
      tempa=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C  CHECK FOR ERRORS 
C 
      if (iferr.gt.0) goto 100
      ier=ier+1 
      return
C 
100   continue
      n=n+1 
      if (n.gt.nd) return
      ipos(n)=ipt 
      tim(n)=tima 
      pos(n)=posa 
      temp(n)=tempa 
C 
      return
      end 
