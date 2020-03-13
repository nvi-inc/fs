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
c@ldsrt.f 

      subroutine ldsrt(ibsrt,nprc,idcb3,ierr) 
C
C 010819 PB V1.0 - Load the pfmed sort buffer. 
C
C     DL - list procedures in active procedure file.

       implicit none

       character*12 ibsrt(1)
       character*80 ibcd
       character*74 ibc2

       integer ix,nprc,ierr,idcb3,nch,len
       integer scanp,trimlen
  
        ix=1
        nprc = 1
        call f_rewind(idcb3,ierr)

        if (ierr.ne.0) goto 990
        ibcd = ' '
        len = 0

        do while (len.ge.0)

          call f_readstring(idcb3,ierr,ibc2,len)
          if(ierr.lt.0.or.len.lt.0) go to 130

C     Check for DEFINE:

          if (ibc2(1:6).eq.'define') then

C     Move name to print buffer.

            ibcd(ix:ix+11) = ibc2(9:20)
            ix=ix+13
            if(ix.lt.79) go to 120

            nch = trimlen(ibcd)
            nprc = scanp(ibcd,ibsrt,nprc)
            ibcd = ' '
            ix=1
          endif
120     end do

C       Write last line.

130     if(ix.gt.1) then
          nch = trimlen(ibcd)
          nprc = scanp(ibcd,ibsrt,nprc)
         endif 

        call sortq(ibsrt,nprc)
cc        write (6,'("ldsrt: Loaded ",i3," procedures.")') nprc 
c
990   continue 
      return 

      end
