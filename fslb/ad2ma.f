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
      subroutine ad2ma(ibuf,iosc,igain,ichan)
      implicit none
      integer iosc,igain,ichan
      integer*2 ibuf(1)
cxx      integer ibuf(1)
C
C  ad2ma: encode MAT buffer for A/D control
C
C  INPUT:
C     IOSC: oscillator control, 0 = on, 1 = off
C     IGAIN: gain control, 0 = high, 1 = low
C     ICHAN: channel select:
C            1 - head 0 position
C            2 - head 1 position
C            3 - head 0 temperature
C            4 - head 1 temperature
C            5 - vacuum sensor
C            6 -  odd reproduce power
C            7 - even reproduce power
C            8 - reference voltage (5.46 Volts)
C
C OUTPUT:
C    IBUF:  8 characters holding MAT buffer
  
      integer inext,ichmv,ihx2a,ichmv_ch
C
      inext=1
      inext=ichmv_ch(ibuf,inext,'000')
      inext=ichmv(ibuf,inext,ihx2a(iosc),2,1)
      inext=ichmv(ibuf,inext,ihx2a(igain),2,1)
      inext=ichmv_ch(ibuf,inext,'00')
      inext=ichmv(ibuf,inext,ihx2a(ichan-1),2,1)
C
      return
      end
