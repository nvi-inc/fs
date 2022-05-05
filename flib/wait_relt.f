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
      subroutine wait_relt(name,ip,ires,imul)
      implicit none
      character*(*) name
      integer*4 ip(5)
      integer ires,imul
c
      integer centisec
c
      if(ires.eq.1) then
       centisec=imul
      else if(ires.eq.2) then
       centisec=imul*100
      else if(ires.eq.3) then
       centisec=imul*60*100
      else if(ires.eq.4) then
       centisec=imul*60*60*100
      else if(ires.eq.5) then
       centisec=imul*24*60*60*100
      else
       centisec=0
      endif
      call fc_skd_wait(name,ip,centisec)
c
      return
      end
