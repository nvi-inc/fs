*
* Copyright (c) 2021 NVI, Inc.
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
      subroutine kputc(names,cra,cdec,cepoch,icount,max_src,ra_plus)
      implicit none
      integer max_src, icount
      character(*) names(max_src),ra_plus
      double precision cra(max_src), cdec(max_src)
      real cepoch(max_src)
c
      include '../../include/dpi.i'
c
      character*16 name
      integer rah, ram, decd, decm, i
      double precision ras, decs, cdum
      real epoch
      character*1 sra,sdec
c
      if(icount.gt.0) then
        write(6,
     &   "(' source',13x,'R.A.(hms)',7x,'Dec.(dms)',5x,'Epoch')")
      endif
      do i=1,icount
        cdum=cra(i)*RAD2SEC
        sra=ra_plus
        if(cdum.lt.0.0d0) then
          sra='-'
          cdum=-cdum
        endif
        rah=cdum/3600.0d0
        cdum=cdum-dble(rah)*3600.0d0
        ram=cdum/60.0d0
        ras=cdum-dble(ram)*60.0d0
        if(ras.lt.0.0d0) ras=0.0d0
        if(ras.gt.59.9995d0) then
           ras=0.0d0
           ram=ram+1
           if(ram.gt.59) then
             ram=0
             rah=rah+1
           endif
        endif
c
        cdum=cdec(i)*RAD2DEG
        sdec='+'
        if(cdum.lt.0.0d0) then
          sdec='-'
          cdum=-cdum
        endif
        decd=cdum
        cdum=(cdum-dble(decd))*60.0d0
        decm=cdum
        cdum=(cdum-dble(decm))*60.0d0
        decs=cdum
        if(decs.lt.0.0d0) decs=0.0d0
        if(decs.gt.59.995d0) then
           decs=0.0d0
           decm=decm+1
           if(decm.gt.59) then
             decm=0
             decd=decd+1
           endif
        endif
        name=names(i)
        epoch=cepoch(i)
        write(6,'(a,a,2i3,f7.3,3x,a,2i3,f6.2,f10.3)')
     &   name, sra, rah, ram, ras, sdec ,decd, decm, decs, epoch
      enddo
c
      end
