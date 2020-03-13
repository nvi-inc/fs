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
      subroutine ma2ad(ibuf,imove,itest,icount)

      implicit none
cxx      integer ibuf(1)
      integer*2 ibuf(1)
      integer imove,itest,icount
C
C  MA2AD: decode head MAT buffer for AD information
C
C  INPUT:
C     IBUF: hollerith buffer contain MAT response
C
C  OUTPUT:
C     IMOVE: 0 = idle, 1 = moving
C     ITEST: auto test results, 0000 no error
C                               1xxx unassigned
C                               x1xx converter data not available
C                               xx1x converter busy
C                               xxx1 illegal channel number
C     ICOUNT: A/D data in binary counts: 2047 =  +9.9951 volts
C                                        0000 =  +0.0000 volts
C                                       -2048 = -10.0000 volts
C                                    1 count is  +0.0049 volts
C
C
      integer ia2hx,ia22h
      integer*2 icount2
C
      imove=ia2hx(ibuf,3)/8
      itest=ia2hx(ibuf,4)
      icount2=ia22h(ibuf(4))*256+ia22h(ibuf(5))
      icount=icount2
C
      return
      end
