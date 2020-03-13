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
      subroutine bpset(ihold,ibypch,itrk,ksplit,itka,itkb,iskip)
C
C     This routine sets up IBYPAS and the A and B tracks
C     for the tape recorder, according to the mode specified
C     in the common variables IREPPC and IBYPPC.  Before
C     changing ITRAKA, ITRAKB and IBYPAS, uncheck the tape
C     recorder and remember the check value in IHOLD.
C     Also check if RAW and track not enabled, then don't do track.
C
      include '../include/fscom.i'
C
      logical ksplit
C
      call fs_get_icheck(icheck(18),18)
100   ihold = icheck(18)
      icheck(18) = 0
      call fs_set_icheck(icheck(18),18)
      itrakb(1) = itrk
      call fs_set_itrakb(itrakb,1)
      ksplit = .false.
C      - uncheck tape recorder whilst changing tracks 
700   goto (701,702,702,704) ireppc+1 
701   ibyppc = ibypas(1) 
      if (itrkpc(itrk).ge.1.and.itrkpc(itrk).le.28.and.ibyppc.gt.0) 
     . ksplit = .true.
      goto 705
702   continue
      ibypas(1) = ibyppc 
      goto 705
704   continue
      ibypas(1) = ibyppc 
      if (itrkpc(itrk).ge.1.and.itrkpc(itrk).le.28) ksplit = .true. 
705   ibypch = ibyppc 
      if (ksplit) then
        itraka(1) = itrkpc(itrk) 
        call fs_set_itraka(itraka,1)
      endif
      call fs_get_itraka(itraka,1)
      itka = itraka(1) 
      call fs_get_itrakb(itrakb,1)
      itkb = itrakb(1) 
      if (ibypch.eq.0.and.itrken(itrk,1).eq.0) iskip = -1 

      return
      end 
