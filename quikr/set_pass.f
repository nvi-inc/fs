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
      subroutine set_pass(ihead,ipass,kauto,micpas,ip,tol,indxtp)
      implicit none
      integer ihead,ipass(2),ip(5),indxtp
      real*4 micpas(2),tol
      logical kauto
C
C POS_HEAD: position heads, by pass or micron
C
C  This routine will position the heads by pass number or uncorrected
C  micron position and/or return the current head position.
C
C INPUT ARGUMENTS:
C
C  IHEAD  Head to position 1=write, 2=read, 3=both.
C  IPASS  The pass numbers each head is to positioned to. If zero, then
C         position by uncorrected microns according to MICPAS, is desired.
C  KAUTO  true if the write head offset should be auto-adjusted
C  MICPAS The uncorrected micron positions to place the heads at if
C         IPASS is zero.
C
C OUTPUT ARGUMENTS:
C
C  MICPAS The micron position that the pass numbers in IPASS correspond
C         to if IPASS was nonzero.
C  IP     Field System error return array.
C
C HISTORY:
C
C  WHO WHEN   WHAT
C  --- ------ ----
C  WEH 880928 CREATED
C
      integer i
C
      do i=1,2
        if((ihead.eq.i.or.ihead.eq.3).and.ipass(i).gt.0) then
          call pas2mic(i,ipass(i),micpas(i),ip,indxtp)
          if(ip(3).ne.0) return
        endif
      enddo
C
      call set_mic(ihead,ipass,kauto,micpas,ip,tol,indxtp)
C
      return
      end
