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
      subroutine obs_sort(luscn,num_obs)
C OBS_SORT sorts the index array for observations by time.
C 000606 nrv New. Algorithm from Numerical Methods.
C 000616 nrv Add calls to SNAME to generate scan names.
C 000725 nrv Check NOBS and don't try to sort 0 or 1 obs!
C 001109 nrv scan_name is character now.
C 010102 nrv Stop if error parsing an observation.
C 03July11 JMG Modified to use sktime.
! 04Oct15  JMGipson. Completely rewritten.
! 2005Nov30. Made the num_obs an argument. Previously used nobs.
! 2006OCt03. Modified to use ctime2dmjd to find djday
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
C Input
      integer luscn
      integer num_obs
! functions
      double precision ctime2dmjd
C Local

      character*12 ctim1

      integer j,i,irec_top,irec_bot
      double precision djday(Max_obs)

      integer iptr,iptr_old
      integer ndup
      character*26 lextra
      data lextra/"abcdefghijklmnopqrstuvwxyz"/

      if (num_obs.eq.0) return

!  1. Sort the obs by time and then by source_name.

      do i=1,num_obs
        iptr=iskrec(i)
        call sktime(cskobs(iptr),ctim1)
        djday(iptr)=ctime2dmjd(ctim1)
      end do

      write(luscn,'("OBS_SORT00 - Sorting scans by time.")')
! Do insertion sort, starting at 2nd element.
      do j=2,num_obs
        do i=j,2,-1
          irec_top=iskrec(i)                !if in order(djday(irec_top))>djday(irec_bot))
          irec_bot=iskrec(i-1)              ! if not, swap them.
          if(djday(irec_top) .gt. djday(irec_bot)) goto 10
          if(djday(irec_top) .eq. djday(irec_bot) .and.
     >      cskobs(irec_top)(1:10) .gt. cskobs(irec_bot)(1:10)) goto 10
! Not in order. Swap them.
          iskrec(i)=irec_bot
          iskrec(i-1)=irec_top
        end do
10      continue
      end do


C  2. Generate scan names
      iptr=iskrec(1)
      call sktime(cskobs(iptr),ctim1)
      scan_name(iptr)=ctim1(3:5)//"-"//ctim1(6:9)
      ndup=0
      iptr_old=iptr

      do i=2,num_obs
        iptr=iskrec(i)
        call sktime(cskobs(iptr),ctim1)
        scan_name(iptr)=ctim1(3:5)//"-"//ctim1(6:9)
        if(scan_name(iptr)(1:8).eq.scan_name(iptr_old)(1:8))then
          if(ndup .eq. 0) then
            ndup=ndup+1
            scan_name(iptr_old)(9:9)=lextra(ndup:ndup)
          endif
          ndup=ndup+1
          if(ndup .le. 26) then
            scan_name(iptr)(9:9)=lextra(ndup:ndup)
          else
            write(luscn,'("OBS_SORT: Ran out of scan letters!")')
            stop
          endif
        else
          ndup=0
        endif
        iptr_old=iptr
      end do

      return
      end
