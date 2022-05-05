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
      subroutine gtrsp(ibuf,iblen,luusr,nch)
C
C     get response from user c#870407:11:59# 
C 
      integer*2 ibuf(1) 
C 
      call ifill_ch(ibuf,1,iblen*2,' ')
      read(luusr,'(512a2)') (ibuf(i),i=1,iblen)
      ich = 1 
      call gtfld(ibuf,ich,iblen*2,ic1,ic2)
      nch = ic2-ic1+1 
      if (ic1.eq.0) then
        nch = 0 
        return
      endif
      call ichmv(ibuf,1,ibuf,ic1,nch) 
      call ifill_ch(ibuf,nch+1,iblen*2-nch,' ')

      return
      end 
