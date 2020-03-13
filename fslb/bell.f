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
      subroutine bell(lui,ieb)  
      implicit none
      integer i,itime,lui,ieb

C  HISTORY:
C  WHO  WHEN    WHAT
C  gag  920904  Added print and commented out put_cons_raw.
C  CAK is credited with this discovery.
C
C  Using put_cons_raw to output the bell, the susp call would
C  suspend the process before the bell was actually rung. What
C  ended up happening was all the bell ringing was stuck in a buffer
C  until all of the suspends were finished suspending. What you would
C  get was a delay and a one second spurt of dings. Using the print
C  statement works.  gag
C
      print 9100
9100  format('',$)
      call fc_play_wav(2)
        if (ieb.eq.0) itime=25-2*i 
        if (ieb.ne.0) itime=5+2*i
        call susp(1,itime) 
100   continue

      return
      end 
