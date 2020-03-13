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
      subroutine scmd(lcmd,iwcmd,mcmd,ierr)
C
      integer it(5)
      integer*2 lcmd(1)
c      integer*4 ip(5)
      logical kbreak,rn_test
      double precision tim, tim2
C
      if (kbreak('aquir')) goto 200
      if (iwcmd.le.-2) goto 100
      nchars=iflch(lcmd,mcmd*2)
c      if(iwcmd.eq.-1) call clear_prog('aquir')
      call copin(lcmd,nchars)
      if(iwcmd.eq.-1) goto 110
      call susp(2,2)
C
      call fc_rte_time(it,idum)
      tim=float(it(4))*3600.+float(it(3))*60.+float(it(2))
C
10    continue
      if (kbreak('aquir')) goto 200
      if(.not.rn_test('fs   ')) then
         ierr=-2
         return
      endif
C
      call fc_rte_time(it,idum)
      tim2=float(it(4))*3600.+float(it(3))*60.+float(it(2)) 
      if (tim2.lt.tim) tim2=tim2+86400.
      if (tim2.ge.tim+iwcmd*60.) goto 100
      call susp(2,2)
      goto 10
C
100   continue
      ierr=0
      return
C
110   continue
c      call wait_prog('aquir',ip)
      call suspend('aquir')
      goto 100
c
200   continue
      ierr=-1
C
      return
      end


