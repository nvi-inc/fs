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
      subroutine en2ma(ibuf,iena,itrk,ltrk)
C     convert en data to mat buffer c#870407:12:39#
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer to be formatted 
      dimension itrk(1) 
C      - tracks to be encoded 
      dimension ltrk(1) 
C      - optional already-encoded tracks
C***NOTE*** LTRK will be used instead of ITRK if ITRK=-1
C     IENA - record-enable bit
C 
C  LOCAL: 
C 
      dimension ibit(28)
C               - which bit in control word corresponds to track
      data ibit/0,8,1,9,2,10,3,11,4,12,5,13,6,14, 
     .          16,24,17,25,18,26,19,27,20,28,21,29,22,30/
C 
C 
C     Format the buffer for the controller. 
C     The buffer is set up as follows:
C                   %xxxxxxxx 
C     where each x represents a group of tracks.
C 
      call ichmv_ch(ibuf,1,'%') 
C                   The strobe character for this control word
      if (itrk(1).eq.-1) goto 150
C 
      call ichmv_ch(ibuf,2,'00000000') 
C                   Fill buffer with zeros to start 
      do 100 i=1,28 
        if (itrk(i).ne.1) goto 100
        ia = ia2hx(ibuf,9-ibit(i)/4)
C                   Pick out the proper character for this track
        ib = 2**(ibit(i)-(ibit(i)/4)*4) 
        ia = or(ia,ib) 
        call ichmv(ibuf,9-ibit(i)/4,ihx2a(ia),2,1)
C                   Put back into place 
100     continue
      goto 200
C 
150   call ichmv(ibuf,2,ltrk,1,8) 
C 
200   ia = or(ia2hx(ibuf,2),iena*8)
      call ichmv(ibuf,2,ihx2a(ia),2,1)
C                   Add in top bit with general enable
C 
      return
      end 
