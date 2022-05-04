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
      subroutine spdstr(spd,cspd_out,nspd)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C SPDSTR returns a Hollerith "lspd" with the appropriate speed for
C the value of "spd". "nspd" is the number of characters in lspd.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'

C History
C 960116 nrv New.
C 960815 nrv Add 80, 160 speeds.
C 960923 nrv Add 320 ips
C 961121 nrv Add 66.66 speed
C 970103 nrv Add 40 speed
C 970118 nrv Add the rest of the valid speeds.
! 030211 JMG Changed so that all speeds are actual, not nominal.
! 050426 JMG Changed to return ASCII, not hollerith.

C INPUT:
      real spd ! speed in inches per second, e.g. 133.33

C OUTPUT:
      character*8 cspd_out
      integer nspd ! number of characters in lspd, -1 if no match

C Local
      integer i,maxspd
      real sp(23)
      character*8 csp(23)
      integer trimlen

C INITIALIZED:
C     Organized according to types:
C       Both   VLBA    Mk3/4
C        thin  thick   thick
C         2.5   4.44    4.21875
C         5     8.88    8.4375
C        10    16.66   16.875
C        20    33.33   33.375
C        40    66.66   67.5
C        80   133.33  135
C       160   266.66  270
C       320
      data maxspd/23/
      data sp/0.0, 2.5, 4.21875,4.44,
     .             5.0, 8.4375, 8.88,
     .            10.0, 16.66, 16.875,
     .            20.0, 33.33, 33.75,
     .            40.0, 66.66, 67.5,
     .            80.0,133.33,135.0,
     .           160.0,266.66,270.0,320.0/
      data csp/'0','2.5','4.21875','4.44',
     .               '5','8.4375' ,'8.88',
     .              '10','16.66' ,'16.875',
     .              '20','33.33' ,'33.75',
     .              '40','66.66' ,'67.5',
     .              '80','133.33','135',
     .             '160','266.66','270','320'/

      i=1
      do i=1,maxspd
!        write(*,'("spd",3f8.5)') spd,sp(i), abs(spd-sp(i))
        if(abs(spd-sp(i)) .le. 0.05) goto 100
      end do
      nspd=-1
      return

100   continue
      cspd_out=csp(i)
      nspd=trimlen(cspd_out)

      return
      end
