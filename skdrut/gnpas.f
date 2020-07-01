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
       SUBROUTINE gnpas(luscn,ierr)
       implicit none
C
C     GNPAS derives the number of sub-passes in each frequency code
C and checks for compatibility between track assignments and head
C subpasses.
C     GNPAS also counts the number of total passes per tape MAXPAS. 
C  GNPAS also determines if it's a Mark3 mode and modifies LMODE.
C
C GNPAS should determine the superset of recorded channels
C and re-arrange the numbering and indexing for stations that
C are not going to record all channels. This situation is occurs
C for the CORE-1 sessions in which Tsukuba records 14 channels
C and the other stations record 16 channels.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'

      integer itras
C
C  Input
      integer luscn ! for error messages
C  Output
      integer ierr ! non-zero if inconsistent track counts per pass

C  LOCAL VARIABLES:
      integer ih,ip(max_headstack),is
      integer it(max_headstack),np(max_headstack)
      integer j,k,l,itrk(max_subpass,max_headstack),ic1,maxp(max_frq)
      integer ix,iprr,ipmax(max_headstack),ic,m,nvc
      logical kmiss,kfirst

! Now put recent changes on top
! 2020Jun30. Got rid of argument iserr which is no longer used. 
C
C     880310 NRV DE-COMPC'D
C     930225 nrv implicit none
C 951019 nrv New frequency code common variables, handles VLBA modes
C 951213 nrv More effective tracks for 2-bit sampling.
C 960208 nrv Don't count effective tracks here. Add check for
C            consistency between track assignments and head positions.
C 960209 nrv Add error return by station
C 960219 nrv Check for LOs present also.
C 960610 nrv Change loop to nchan instead of max_chan for counting tracks.
C 960817 nrv Skip track checks for S2
C 961101 nrv Skip checks if the mode is not defined for this station.
C 961107 nrv Skip ALL checks for undefined modes.
C 961112 nrv Set MAXPAS to the value for the first code for this station,
C            not for the first code.
C 961115 nrv If there is only 1 mode, IC1 would remain at zero!
C 970206 nrv Remove itra2, ihddi2 and add headstack index to all.
C 970206 nrv Change max_pass to max_subpass
C 980907 nrv Change max_subpass as an index into inddir to max_pass.
C 000905 nrv If the second headstack isn't used, don't check it. If
C            it is used, remember it.
C 001011 nrv Initialize number of headstacks found in this code.
C 010817 nrv Not for K4 either.
! 2003Jul25  JMG  Changed itras to be a function.
! 2006Oct16 JMG. At start of ncodes loop, remove test for Mark5. We need this test because
!            this loop sets up various parameters such as ntrakf that we need elsewhere  
! 2006Nov29 Put the Mark5 test back in. With it removed, drudged failed for v215a.skd
! 2006Nov30. Use cstrec(istn,irec)
! 2007Jul18 JMG. Modified Mark5 test so that it is now called.
! 2010.06.15 JMG.  Modified to work with K5
C
C
C     1. For each code, go through all possible passes and add
C     up the total number of tracks used. 
C     Use itras(u/l,s/m,head,max_subpass,max_chan,station,code)
C     Use ihddir(head,max_pass,station,code)
C
      ierr=0
      IF (NCODES.LE.0) RETURN     
!      pause 
C     
      do ic=1,ncodes
      do is=1,nstatn
        npassf(is,ic)=1
      end do
      end do

! 2020Jun06. Got rid of a bunch of obsolete code deallng with headstacks, passes. 
     
C 3. Check for LOs present and issue warning if not.
300   continue

      do ic=1,ncodes
        do is=1,nstatn
          if (nchan(is,ic).gt.0) then ! this station has this mode defined
            kmiss=.false.
            kfirst=.true. 
            do ix=1,nchan(is,ic)
              nvc=invcx(ix,is,ic)
              if ( cifinp(nvc,is,ic) .eq. "  ") then
                if(kfirst) then
                  kfirst=.false. 
                  write(luscn,9906) ccode(ic),cstnna(is)
9906     format('GNPAS06: Warning: ',a,' LO information missing for ',a)
                endif              
              endif
            enddo                
          endif ! defined
        enddo
      enddo

      RETURN
      END
