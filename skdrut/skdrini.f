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
      SUBROUTINE SKDRINI
      implicit none
C
C  SKDRINI initializes common variables used by SKED and DRUDG
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/broadband.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'

!Updates. Most recent at top
! 2021-01-31 JMG Get rid of roll init 
! 2021-01-05 JMG Replaced max_frq by max_code. (Max_frq was confusing and led to coding errors.)
! 2020-06-08 JMG Initialized various broadband values. 
! 2020-06-08 JMG Added reference to broadband.ftni 

! 2019-11-20 WEH Fixed bug in index
! 2019-08-22 JMG. Initialized lcode here and not in frinit. 
C
C 990921 nrv New. Copied from skini. Code moved here from fdrudg.f
C            Generally these are variables that have fixed values
C            but can't be set in parameter statements.
C 991110 nrv Initialize lmode_cat to blank.
C 991118 nrv Initialize nominal start/end times.
C 991208 nrv Add 'unused' rec type.
C 000126 nrv Add initialization of ntrkn.
C 000607 nrv Initialize tape_allocation to SCHEDULED.
C 000913 nrv Initialize roll tables here.
C 010622 nrv Move roll table initialization to skini because only
C            sked needs these to write VEX files.
C 020111 nrv Move roll table initialization back here because drudg
C            needs them to read and check roll_defs from VEX files.
C            But remove the DATA statement which seems to balloon the
C            program size.
C 020713 nrv Add Mk5 recorder type
C 021111 jfq Add LBA rack type
C 2003Apr17  JMG   Added Mark5p
C 2003Jul23  JMG   Added Mk5PigW
! 2007May25  JMG   Added Mark5B recorder, MK4V and VLAB4V racks.
! 2007Jul02  JMG. Removed initialization of fluxes. Done elsewhere.
! 2007Aug07  JMG. Moved rack, recorder type initialization to block data statement in
!                 "valid_hardware.f"

C
C LOCAL
      integer i,j,l

      vex_version = '' ! initialize to null
      cexper=" "
      cexperdes='tbd'
      cpiname='tbd'
      ccorname='tbd'
C
C  In skobs.ftni
      NOBS = 0
      ISETTM=0
      IPARTM=0
      ITAPTM=0
      ISORTM=0
      IHDTM=0
      iyr_start=0
      ida_start=0
      ihr_start=0
      imin_start=0
      isc_start=0
      iyr_end=0
      ida_end=0
      ihr_end=0
      imin_end=0
      isc_end=0
C  In statn.ftni
      DO  I=1,MAX_STN   ! Initialize current variables
        itearl(i)=0
        itlate(i)=0
        itgap(i)=0
        tape_motion_type(i)='START&STOP'
        tape_allocation(i)='SCHEDULED'
        tape_length(i)=0
        ibitden_save(i)=0.0
        do j=1,max_code
          bitdens(i,j)=0.0
          tape_dens(i,j)=0.0
          do l=1,max_bbc
             ibbc_present(l,i,j)=0
          end do
        enddo
        cstcod(i)=" "
        cterna(i)=" "
        cantna(i)=" "
      END DO  ! Initialize current variables

! Initialize BB values
      do i=1,max_stn
         bb_bw(i) =0.0       !set these all to 0. 
         idata_mbps(i)=0
         isink_mbps(i)=0
         ibb_off(i)=0 
      end do 


C  Number of selected sources, stations, codes
      NSOURC = 0
      NSTATN = 0
C  In freqs.ftni
      call freq_init
      NCELES = 0
      NSATEL = 0
      nband = 0

      do i=1,max_code
        lcode(i)=0
      enddo

      call valid_hardware_blk

      return
      end
