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
      subroutine snap_ready(ntape,kfirst_tape)
! write out ready commands
      include 'hardware.ftni'
      integer ntape
! local
! History
!  2019Aug25  Replace squeezewrite by drudg_write
      character*7 lprefix
      integer nch
      character*40 ldum
      logical kfirst_tape

      lprefix="ready"             !lprefix:   readyX=    , where "= and "X" is optional
      if(krec_append) then
        lprefix(6:6)=crec(irec)
        nch=6
      else
        nch=5
      endif

      if(.not.km5disk) then
        ntape=ntape+1
      endif

      if((km5disk .or. km5a_piggy.or.km5p_piggy).and.kfirst_tape) then
        write(luFile,'(a)') 'ready_disk'
        kfirst_tape=.false.
      endif
      
      if(km6disk) then
         kfirst_tape=.false.
         return
      endif 

      if(km5disk) then
         return              !don't need to do tape ready.
      else if(kk4) then
        nch=nch+1
        lprefix(nch:nch)="="
        write(ldum,'(a,i3)') lprefix(1:nch),ntape
        call drudg_write(lufile,ldum)
      else
        write(lufile,'(a)') lprefix(1:nch)
      endif

      return
      end
