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
      SUBROUTINE snap_fast(idirSpin,ISPM,SPS,nrec)
! write out commands:
!    sfastf, fastf, fastr, sfastr
!
!    JMGipson   2002Jan02  V1.00  output command to move tape fast forward or reverse.
      include 'hardware.ftni'

C Input:
      integer iDirSpin      !direction, speed
      integer ispm      !time to spin in minutes
      real sps          !time to spin in seconds
      integer nrec      !number of recorders.
! internal
      character*10 lcommand
      integer  isec     !integer part of seconds
      double precision sfrac    !fractional part
      integer is100     !100ths of second
      integer nch

! Taken from lspin
      if (iDirSpin.eq.0) return

      if(iDirSpin .eq. +2) then
         lcommand="sfastf"
      else if(iDirSpin .eq. +1) then
         lcommand="fastf"
      else if(iDirSpin .eq. -1) then
         lcommand="fastr"
      else if(iDirSpin .eq. -2) then
         lcommand="sfastr"
      endif

      if(iabs(iDirSpin) .eq. 2) then
        nch=6
      else
        nch=5
      endif

      if(nrec .gt. 1) then
        nch=nch+1
        lcommand(nch:nch)=crec(irec)
      endif

      isec=int(sps)
      sfrac=sps-float(isec)
      is100=nint(sfrac*100.d0)
      if(is100 .eq. 100) then
         isec=isec+1
         is100=0
      endif
      if(isec .eq. 60) then
         ispm=ispm+1
         isec=0
      endif

      if(ispm .lt. 10) then
        write(luFile,"(a,'=',i1,'m',i2.2,'.',i2.2,'s')")
     >     lcommand(1:nch), ISPM,isec,is100
      else
        write(luFile,"(a,'=',i2,'m',i2.2,'.',i2.2,'s')")
     >     lcommand(1:nch), ISPM,isec,is100
      endif
      kspin = .true. !Just wrote a FASTx command

      return
      end
