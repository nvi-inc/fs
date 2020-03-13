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
      subroutine bsort(istart,length,ncode,bufr)
C
C  Sort bar codes by length and ASCII order        Lloyd Rawley    March 1988
C
C  Calls COPIN and character subroutines, called by RWAND.
C
C  Input parameters:
      integer istart(1),length(1),ncode
      integer*2 bufr(1)
C   bufr:    ASCII array containing all of the bar codes
C   ncode:   Number of bar codes            
C   istart:  Array of indexes within bufr of the beginning of a bar code
C   length:  Array of lengths of the bar codes
C
C  On output, ncode and bufr are unchanged.  The other arrays are reorganized
C   so that the shortest strings come first, and each group of strings of the
C   same length is alphabetized by ASCII collating sequence.  In addition, if
C   more than one tape label (distinguished from other bar codes by its
C   length) is present in the list, all except the last one are considered
C   errors and are replaced with the last value.  This value is sent to the
C   LABEL command for logging.
      parameter (lentap=10)          !  8 characters plus space plus checksum
C
      logical changes         !  used to determine when the sort is complete
      integer lmess(8)        !  ersatz message from operator to boss
C
C  1. Make all tape label references refer to the last label.
C
      lasttap = 0
      do i=ncode,1,-1
        if (length(i).eq.lentap) then
          if (lasttap.eq.0) then
            lasttap = i
          else
            istart(i) = istart(lasttap)
          endif
        endif
      enddo
C
C  2. Send the tape label (if any) to the QUIKR LABEL command via COPIN.
C
      if (lasttap.ne.0) then
        call ichmv_ch(lmess,1,'label=')
        call ichmv(lmess,7,bufr,istart(lasttap),lentap)
        call mcoma(lmess,17)
        call copin(lmess,7+lentap)
      endif
C
C  3. Bubble sort
C
      changes = .true.
      do while(changes)
        changes = .false.
        do i=2,ncode
          lendif = length(i)-length(i-1)
          if (lendif.lt.0) then        !  if shorter string comes later, swap
            itmp = length(i)
            length(i) = length(i-1)
            length(i-1) = itmp
            itmp = istart(i)
            istart(i) = istart(i-1)
            istart(i-1) = itmp
            changes = .true.
C    Don't sort 8-character codes so that VC's can be displayed in order
          else if (lendif.eq.0 .and. length(i).ne.8 .and. !  ascii comparison
     &    ichcm(bufr,istart(i),bufr,istart(i-1),length(i)).gt.0) then
            itmp = istart(i)                      !  swap
            istart(i) = istart(i-1)
            istart(i-1) = itmp
            changes = .true.
          endif
        enddo
      enddo
C
      return
      end
