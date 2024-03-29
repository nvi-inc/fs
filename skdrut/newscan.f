*
* Copyright (c) 2020-2021 NVI, Inc.
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
      subroutine newscan(istn,isor,icod,istart,
     .      idstart,idend,ifeet,ipas,idrive,cbl,ierr)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C   NEWSCAN forms the inputs into a standard sked/drudg hollerith
C   observation. This routine and ADDSCAN determine the internal
C   format for the observation.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'

C Called by: VOBINP, VOB1INP
C History
! 2021-12-03 JMGipson. Got rid of some calls to ib2as. Was causing problems in some compilers.
C 960527 nrv New.
C 970114 nrv change 8 to max_sorlen
C 970721 nrv Add IDRIVE to call, if 0 set direction to 0.
C 970721 nrv Add idstart fields following durations
C 970721 nrv Remove footage, duration, and good data to subroutines
C 000106 nrv Check the year before converting to 2-digit internal year.
C 001030 nrv Need one more space before the flag field.
! 2006Jul17 JMG.  Got rid of some holerith.  Cleaned up.

C Input:
      integer istn ! first station in this scan
      integer isor ! source index
      integer icod ! freq code index
      integer istart(5) ! year, doy, hour, min, sec
      integer idstart ! start of good data
      integer idend ! duration of scan
      integer ifeet ! footage counter at start
      integer ipas ! pass number, calculate F/R from even/oddness
      integer idrive ! which drive to record on, 0=no recording
      character*1 cbl ! cable wrap

C Output:
      integer ierr ! if anything went wrong
! function
      integer trimlen

C Local
      integer*2 ibuf(ibuf_len)
      character*(2*ibuf_len) cbuf
      equivalence (ibuf,cbuf)

      integer ical,nch,idl,iyr
      integer ichmv,ichmv_ch,ib2as

C Initialized for leading zeros, left justified
C     First clear out the entire buffer

      cbuf=csorna(isor)
      nch=trimlen(cbuf)+1

C     Cal time. Define as 10 for now
      ical = 10
      nch = nch + 1 + IB2AS(ICAL,IBUF,NCH+1,3)
C     Freq code
      NCH = ICHMV(IBUF,NCH+1,LCODE(ICOD),1,2)
C     Preob
      NCH = 1 + ICHMV_ch(IBUF,NCH+1,'PREOB ')
C     Start time
      if (istart(1).ge.2000) iyr = istart(1)-2000
      if (istart(1).lt.2000) iyr = istart(1)-1900

      write(cbuf(nch:nch+11),'(i2.2,i3.3,3i2.2)')
     >  iyr,istart(2),istart(3),istart(4),istart(5)

      nch=nch+12

C     Duration. Use first station's.
      NCH = NCH + 1+IB2AS(idend,IBUF,NCH+1,5)
C     Midob procedure
      NCH = ICHMV_ch(IBUF,NCH+1,'MIDOB ')
C     Idle time
      idl = 0
      NCH = NCH + 1+IB2AS(IDL,IBUF,NCH+1,5)
      NCH = NCH + 1
C     Postob proc
      NCH = ICHMV_ch(IBUF,NCH,'POSTOB')
      NCH = NCH + 1
C     Station code
      cbuf(nch:nch+1)=cstcod(istn)//cbl
      nch=nch+1
C   Insert blanks for other stations' codes
      nch = nch + nstatn*2
C   Tape pass, direction, footage for each station
!      nch = feetscan(ibuf,nch,ipas,ifeet,idrive,istn,icod)
      write(cbuf(nch+1:nch+3),'(a)') '1F0'
      nch = nch + nstatn*8 ! (1)pass(1)dur(5)footage(1)space
C  Procedure flags
      nch=nch+1
      nch = ichmv_ch(ibuf,nch,'YNNN')
C  Duration
      nch=nch+1
      write(cbuf(nch:nch+5),'(i5)') idend   
!      nch = durscan(ibuf,nch,idend)
C     NCH = 1 + NCH + IB2AS(idend,IBUF,NCH+1,5)
C   Insert blanks for other stations' durations
      nch = nch + nstatn*6 ! (5)dur(1)space
C  Good data offset
!      nch = gdscan(ibuf,nch,idstart)
      write(cbuf(nch:nch+5),'(i5)') idstart 
C     nch = 1 + nch + ib2as(idstart,ibuf,nch+1,5)
C   Insert blanks for other stations' good data offsets
      nch = nch + nstatn*6 ! (5)dur(1)space
C
C Store the record in common

      ierr=0
      if (nobs+1.gt.max_obs) then ! too many
        ierr=max_obs
        return
      endif
      NOBS = NOBS + 1
C     write(6,'(i5)') nobs
      ISKREC(NOBS) = nobs
      cskobs(iskrec(nobs))=cbuf
!      write(*,*) trim(cbuf)

      return
      end
