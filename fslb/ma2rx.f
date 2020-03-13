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
      subroutine ma2rx(ibuf,ilo,ical,idcal,ibox,iadc,val)

C  convert mat buffer to rx data c#870115:04:03#  
C 
C     This routine converts the buffers returned from the MAT 
C     into the receiver status and A/D readings.
C 
C  INPUT: 
C 
      integer*2 ibuf(1) ,iadc
C      - buffer as returned from MATCN
C 
C  OUTPUT:
C 
C     Buffers from MATCN look like: 
C                     lnnnvvvv
C     where each character means
C                   l    - LO status in lower bit 
C                   nnn  - messy noise, heaters, A/D address
C                   vvvv - A/D value
C 
      logical kbit
C 
C  LO status 
      ia = ia2hx(ibuf,1)    
      ilo = 0 
      if (kbit(ia,1)) ilo=1 
C  Cal on/off
      ia = ia2hx(ibuf,2)    
      ical = 1
      if (kbit(ia,4)) ical = 0
C  Heaters 
      idcal = 1 
      if (kbit(ia,3)) idcal = 0 
      ibox = 1
      if (kbit(ia,1)) ibox = -1 
      ia = ia2hx(ibuf,3)    
      if (kbit(ia,3)) ibox=0
C  A/D channel address 
      call ichmv(iadc,2,ibuf,4,1) 
C  Pick up second char of address 
      call sbit(ia,2,0) 
      call sbit(ia,3,0) 
      call sbit(ia,4,0) 
      call ichmv(iadc,1,ihx2a(ia),2,1)
C  A/D value in volts
C     IA = ISHFT(IA22H(IBUF(3)),-8)  + IA22H(IBUF(4)) 
      ia = ia2hx(ibuf,7) + ia2hx(ibuf,6)*16+ ia2hx(ibuf,5)*256
C     VAL = 2.5 - FLOAT(ISHFT(IA,4))*(5.0/4095.0) 
      val = 2.5 - float(ia)*(5.0/4095.0)  
C 
      return
      end 
