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

      integer MAX_SRC
      parameter (MAX_SRC=200)
C
      double precision cra(MAX_SRC), cdec(MAX_SRC)
      double precision tra(MAX_SRC), tdec(MAX_SRC)
      double precision ora(MAX_SRC), odec(MAX_SRC)
      real cepoch(MAX_SRC)
      real oepoch(MAX_SRC)
      real tepoch(MAX_SRC)
      character*16 names(MAX_SRC),tnames(MAX_SRC)
      integer nsourc,i,iepoch,tsourc
      character*128 c1950, ctest, compare
c
      call get_command_argument(1,c1950)
      if(c1950.eq.'') then
        write(6,*) 'no input file'
        stop
      endif
c
      call kgetc(c1950,names,cra,cdec,cepoch,nsourc,MAX_SRC)
c
      if(nsourc.eq.0) then
        write(6,*) 'no input sources'
        stop
      endif
c
      write(6,*) 'input from ', c1950
      call kputc(names,cra,cdec,cepoch,nsourc,MAX_SRC,' ')
c
      call get_command_argument(3,compare)
      if(compare(1:7).eq.'compare') then
        do i=1,nsourc
          ora(i)=cra(i)
          odec(i)=cdec(i)
          oepoch(i)=cepoch(i)
        enddo
      else
        do i=1,nsourc
          iepoch=int(cepoch(i)+0.5)
          call PREFR(cra(i),cdec(i),iepoch,
     &          ora(i),odec(i))
          if(iepoch.eq.1950) then
            oepoch(i)=2000.
          else if (iepoch.eq.2000) then
            oepoch(i)=1950.
          endif
        enddo
        write(6,*) 'output'
        call kputc(names,ora,odec,oepoch,nsourc,MAX_SRC,' ')
      endif
c
      call get_command_argument(2,ctest)
      if(ctest.eq.'') then
        stop
      endif
c        
      call kgetc(ctest,tnames,tra,tdec,tepoch,tsourc,MAX_SRC)
      if(tsourc.gt.0) then
        write(6,*) 'input from ', ctest
        call kputc(tnames,tra,tdec,tepoch,tsourc,MAX_SRC,' ')
        if(nsourc.ne.tsourc) then
           write(6,*) ' number of sources don''t match'
           write(6,*) nsourc,' in ',c1950
           write(6,*) tsourc,' in ',ctest
           stop
        endif
        do i=1,nsourc
          if(names(i).ne.tnames(i)) then
             write(6,*) ' sources ', i, ' doesn''t match'
             write(6,*) names(i),' in ',c1950
             write(6,*) tnames(i),' in ',ctest
             stop
          endif
          ora(i)=tra(i)-ora(i)
          odec(i)=tdec(i)-odec(i)
          if(compare(1:7).eq.'compare') then
            oepoch(i)=tepoch(i)-oepoch(i)
          else if (abs(tepoch(i)-oepoch(i)).gt.0.5) then
            oepoch(i)=tepoch(i)-oepoch(i)
          endif
        enddo
      endif
      if(compare(1:7).eq.'compare') then
        write(6,*) 'comparison'
      else
        write(6,*) 'difference'
      endif
      call kputc(names,ora,odec,oepoch,nsourc,MAX_SRC,'+')
c
      end
