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
      subroutine wait_abstd(name,ip,id,ih,im,is,ics)
      implicit none
      character*(*) name
      integer*4 ip(5)
      integer id,ih,im,is,ics
c
      integer it(6), ileap
      integer*4 centisec
c
      call fc_rte_time(it,it(6))
      centisec=ics-it(1)
      centisec=centisec+(is-it(2))*100
      centisec=centisec+(im-it(3))*60*100
      centisec=centisec+(ih-it(4))*60*60*100
      centisec=centisec+(id-it(5))*24*60*60*100
C
c if the calculated wait is less than zero, check for wrapping
c around the year, and try to fix it we are on the last day
c otherwise return because the time must be past
c
      if(centisec.le.0) then
        if(mod(it(5),4).eq.0) then
          ileap=1
        else
          ileap=0
        endif
        if(it(5).eq.365+ileap.and.id.eq.0) then
          centisec=centisec+it(5)*86400*100
        else
          return
        endif
      endif
      call fc_skd_wait(name,ip,centisec)
c
      return
      end
