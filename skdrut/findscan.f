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
      subroutine findscan(isor,icod,istart,irec)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C   FINDSCAN looks through the list of scans for a match
C   on the source, code, and start time.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'

C History
C 960527 nrv New.
C 970114 nrv Chane 8 to max_sorlen
C 970131 nrv Don't check using exact columns, but get fields.
C 000106 nrv Check the year before converting to 2-digit internal year.
C 001108 nrv Use nsorlen array instead of finding the last character
C            in the source name each time we are called.
C 001108 nrv Remove GTFLDs and use known values for field lengths.
C 001108 nrv Use the input irec value, if non-zero, as the record
C            to start checking. If nothing is found, check the
C            scans behind us.
! 2006Dec01  JMG Rewritten to get rid of holeriths.

C Input
      integer isor,icod ! indices for source and freq code
      integer istart(5) ! start year, doy, hr, min, sec

C Output
      integer irec ! non-zero is record number

C Local
      integer iob
      integer iob_start,iob_end,itry
      integer iyr
      character*12 cstart

! Used to extrac tokens from
      integer MaxToken
      integer NumToken
      parameter(MaxToken=5)           !Only need the first 4 tokens.
      character*12 ltoken(MaxToken)

!    Convert start time to ASCII
      if (istart(1).ge.2000) iyr = istart(1)-2000
      if (istart(1).lt.2000) iyr = istart(1)-1900
      write(cstart,'(i2.2,i3.3,3(i2.2))') iyr,istart(2),istart(3),
     >  istart(4),istart(5)

C 1. Loop through all observations so far.  Check source, code, and time.
C     source   cal code preob start
C     Example:
C     3C84      120 SX PREOB 80092120000
C                            yydddhhmmss
C iob is the observation to start with in the existing scan array.

! Do test twice.
! First time starting from current position forward. If match, exit.
! Second time, start from beginning, going forward.
! Second time
      do itry=1,2
        if(itry .eq. 1) then
          iob_start=1
          if(irec .gt. 0) then
            iob_start= irec+1 ! start looking where we left off
          else
            iob_start = 1
          endif
          iob_end=nobs
        else
          iob_end=iob_start-1
          iob_start=1
        endif
        do iob=iob_start,iob_end
          call splitNtokens(cskobs(iskrec(iob)),ltoken,
     >        Maxtoken,NumToken)
          if(csorna(isor).eq.ltoken(1) .and. ccode(icod).eq.ltoken(3)
     >     .and. cstart .eq. ltoken(5)) then
            irec=iob
           return
         endif
        end do
      end do  !itry
! didn't find match first go round.
      RETURN
      END

