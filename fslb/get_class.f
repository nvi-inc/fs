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
      subroutine get_class(ibuf,ilen,ip,nchar)

      implicit none
      integer*2 ibuf(1)
      integer ilen,nchar,ip(1)
C
C  get_class: retreive class record
C
C  input:
C     ILEN: size of IBUF, +WORDS or -BYTES
C     IP: field system parameters
C         IP(1): class #
C         IP(2): number of class records available on entry
C
C  output:
C     IBUF: buffer containing at most ILEN +WORDS or -BYTES
C     NCHAR: number of characters (bytes) actually returned in IBUF
C     IP: field system parameters
C        IP(1): unmodifed
C        IP(2): number of class records remaining on return
C
      integer get_buf,idum
      integer ireg(2)
      real*4 reg
      equivalence (ireg(1),reg)
C
      if(ip(2).le.0) then
        ip(3)=-402
        call char2hol('q@',ip(4),1,2)
        return
      endif
C
      ireg(2)=get_buf(ip(1),ibuf,ilen,idum,idum)
      nchar=-ilen
      if(ilen.gt.0) nchar=2*ilen
      nchar = min0(ireg(2),nchar)
      ip(2)=ip(2)-1
C
      return
      end
