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
      subroutine rp2ma(ibuf,iby,ieq,ibw,ita,itb)

C  convert repro data to mat buffer c#870407:12:39# 
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer for the formatted message for MATCN.
C        There are 9 characters returned
C     IBY - bypass code 
C     IEQ - equalizer selection 
C     IBW - bandwidth selection code
C     ITA - track A to be reproduced
C     ITB - track B to be rrproduced
C 
C 
C     1. The format of the tape drive control word which sets 
C     up the tracks to be reproduced is:
C 
C                   !rdebtbta 
C     where r = reset bit (??)
C           d = bypass bit and disable tracks 
C           e = equalizer choice
C           b = bandwidth choice AND EQ=BW bit
C          tb = track B 
C          ta = track A 
C 
      nch = ichmv_ch(ibuf,1,'!')
C                   The strobe character
      nch = ichmv_ch(ibuf,nch,'0')
      nch = nch + ib2as(iby*2,ibuf,nch,1) 
      nch = nch + ib2as(ieq,ibuf,nch,1) 
      nch = nch + ib2as(ibw,ibuf,nch,1) 
      nch = nch + ib2as(itb,ibuf,nch,2+o'40000'+o'400'*2) 
      nch = nch + ib2as(ita,ibuf,nch,2+o'40000'+o'400'*2) 
C 
      return
      end 
