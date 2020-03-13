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
      logical function kidnam(ibuf,idbuf)

      character*(*) ibuf,idbuf
C
      character*63 dirpath,dirpathd,ds,dsd
      character*16 name,named
      character*4 typex,typexd,typexf
      character*40 qual,quald
      integer sc,scd,type,typed,size,sized,rl,rld
c
cxx      call fmpparsepath(ibuf,dirpath,name,typex,qual,sc,type,size,rl,ds)
cxx      call fmpparsepath(idbuf,dirpathd,named,typexd,quald,scd,typed,
cxx     &                  sized,rld,dsd)
c
      if (dirpath.eq.' ') dirpath=dirpathd
      if (name   .eq.' ') name   =named
      if (typex  .eq.' ') typex  =typexd
      if (qual   .eq.' ') qual   =quald
      if (sc     .eq.0  ) sc     =scd
      if (type   .eq.0  ) type   =typed
      if (size   .eq.0  ) size   =sized
      if (rl     .eq.0  ) rl     =rld
      if (ds     .eq.' ') ds     =dsd
c
      typexf=typex
cxx      call casefold(typexf)
      kidnam=name.ne.' '.and.typexf.ne.'dir'
c
cxx      call fmpbuildpath(ibuf,dirpath,name,typex,qual,sc,type,size,rl,ds)
C
      return
      end
