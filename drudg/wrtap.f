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
      SUBROUTINE wrtap(cspdir,ispin,ihead,lu,iwr,ktape,irec,kauto)
C
C  WRTAP writes the tape lines for the VLBA pointing schedules.
C
C   HISTORY:
C     WHO   WHEN   WHAT
C     gag   900724 CREATED
c     gag   901025 added ktape logical for NEXT writing
C     nrv   930709 Now "ihead" is the actual head position in microns,
C                  removed the hard-coded array.
C 970321 nrv Re-write for more flexibility.
C 980728 nrv Remove the HEAD command, for dynamic tape allocation.
C 980910 nrv Remove REWIND and just STOP at the end of a pass.
C 980924 nrv Replace the HEAD command for RDV11.
C 981208 nrv Remove it again.
C 011011 nrv Add KAUTO to the call.
! 2006Sep28 JMGipson. Removed all hollerith
C
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
C
C  INPUT:
      character cspdir
      integer ispin,ihead,lu,iwr,irec
      logical ktape,kauto
C
C     CALLED BY: vlbat
C
C  LOCAL VARIABLES
! Make string   tape=(1,
      write(lu,'("tape=(",i1,",",$ )') irec

      if(ispin .eq. 0 .or. ispin .eq. 330) then
        write(lu,'(a,$)') "STOP)"
      else
        write(lu,'(a,$)') cspdir//"RUN) "
      endif

      write(lu,'(" write=(",i1,",",$)') irec

      if (iwr.eq.0) then
       write(lu,'("off)",$)')
      else
       write(lu,'("on)",$)')
      end if

      if (.not.kauto) then ! head commands
        write(lu,"(' head=(',i1,',',i4,')',$)")
      endif

      if (ktape) then
         write(lu,'(a)') "  !NEXT!"
      else
         write(lu,'(a)') " "
      endif

      RETURN
      END
