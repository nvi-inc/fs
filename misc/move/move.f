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
      program main
c
      include '../../include/dpi.i'
c
      integer MAX_SRC
      parameter (MAX_SRC=200)
C
      double precision cra(MAX_SRC), cdec(MAX_SRC)
      double precision ora(MAX_SRC), odec(MAX_SRC)
      double precision oaz(MAX_SRC), oel(MAX_SRC)
      double precision alat,wlong,ht
      real cepoch(MAX_SRC),oepoch(MAX_SRC)
      character*16 names(MAX_SRC)
      integer nsourc,i,it(6),il
      character*128 catalog,position,time
      real ep
c
      call get_command_argument(1,catalog)
      if(catalog.eq.'') then
        write(6,*) 'no input catalog file'
        stop
      endif
c
      call kgetc(catalog,names,cra,cdec,cepoch,nsourc,MAX_SRC)
c
      if(nsourc.eq.0) then
        write(6,*) 'no input sources'
        stop
      endif
c
      write(6,*) 'input from ', catalog
      call kputc(names,cra,cdec,cepoch,nsourc,MAX_SRC,' ')
c
      call get_command_argument(2,time)
      if(time.eq.'') then
         call get_rte_time(it,it(6))
      else
c        read(time,*) (it(il),il=6,1,-1)
         read(time,*) it(6),it(5),it(4),it(3),it(2),it(1)
      endif
      do i=1,nsourc
         call move2(it,cra(i),cdec(i),cepoch(i),ora(i),odec(i))
         oepoch(i)=it(6)+it(5)/366.d0
      enddo
      write(6,*) 'output apparent'
      write(6,
     & "(' Year',i5,' DOY',i4,' Hour',i3,' Minute',i3,' Second',i3,
     &   ' Centisecond',i3)") it(6),it(5),it(4),it(3),it(2),it(1)
      call kputc(names,ora,odec,oepoch,nsourc,MAX_SRC,' ')
c
      call get_command_argument(3,position)
      if(position.ne.'') then
        read(position,*) wlong,alat,ht
        write(6,*) 'output topocentric'
        write(6,'(a,F9.4,a,F7.4,a,F10.4)')
     &  ' W. Long.(deg) ',wlong,' N. Lat.(deg) ',alat,' Height(m)',ht
        wlong=wlong*DEG2RAD
        alat=alat*DEG2RAD
        do i=1,nsourc
           call move2t(it,wlong,alat,ht,cra(i),cdec(i),cepoch(i),
     &    ora(i),odec(i))
           oepoch(i)=it(6)+it(5)/366.d0
           call cnvrt(1,ora(i),odec(i),oaz(i),oel(i),it,alat,wlong)
        enddo
      write(6,
     & "(' Year',i5,' DOY',i4,' Hour',i3,' Minute',i3,' Second',i3,
     &   ' Centisecond',i3)") it(6),it(5),it(4),it(3),it(2),it(1)
        call kputcae(names,ora,odec,oepoch,nsourc,MAX_SRC,' ',oaz,oel)
      endif
c
      end
