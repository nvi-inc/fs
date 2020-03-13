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
      subroutine wait_abst(name,ip,ih,im,is,ics)
      implicit none
      character*(*) name
      integer*4 ip(5)
      integer ih,im,is,ics
c
      integer it(6)
      integer*4 centisec
c
      call fc_rte_time(it,it(6))
      centisec=ics-it(1)
      centisec=centisec+(is-it(2))*100
      centisec=centisec+(im-it(3))*60*100
      centisec=centisec+(ih-it(4))*60*60*100
      if(centisec.lt.0) centisec=centisec+24*60*60*100
      call fc_skd_wait(name,ip,centisec)
c
      return
      end
