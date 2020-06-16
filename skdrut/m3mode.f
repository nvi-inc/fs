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
      SUBROUTINE m3mode(istn,icode)
      implicit none  !2020Jun15 JMGipson automatically inserted.

C  M3MODE looks at the track assignments and determines if they
C  correspond to any of the standard Mark3 modes.
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'

! function
      integer itras

C INPUT
      integer istn,icode

C OUTPUT
C     LMODE in common is modified with the Mk3 mode.
c LOCAL
      integer ntra,nhead,nbits,npass

C History
C 020909 nrv If a station has all the tracks of a standard mode
C            plus some others, it should not be classified as a
C            standard mode.  Count tracks in itras and compare
C            to 28.
C 25Jul2003 JMG  Changed itras to be a function.
!           JMG  Quick exit if ntra<>28
! 2004Feb16 JMG  Got rid of all holleriths.
! 2005Nov16 JMG. Got rid of extra IFILL, and some comments.
! 2005Nov17 JMG. itras now gives Mark4 track assignments. Modify accordingly.

C     itras(bit,sb,max_headstack,MAX_CHAN,MAX_subPASS,max_stn,max_frq)

C  Count the tracks

      call itras_params(istn,icode,npass,ntra,nhead,nbits)

      if(ntra.ne.28 .or. nbits .ne. 1 .or. nhead .ne. 1) return

C  Check the tracks
      if ( itras(1,1,1, 1,1,istn,icode).eq.15 +3 .and.
     .     itras(1,1,1, 2,1,istn,icode).eq. 1 +3 .and.
     .     itras(1,1,1, 3,1,istn,icode).eq.17 +3 .and.
     .     itras(1,1,1, 4,1,istn,icode).eq. 3 +3 .and.
     .     itras(1,1,1, 5,1,istn,icode).eq.19 +3 .and.
     .     itras(1,1,1, 6,1,istn,icode).eq. 5 +3 .and.
     .     itras(1,1,1, 7,1,istn,icode).eq.21 +3 .and.
     .     itras(1,1,1, 8,1,istn,icode).eq. 7 +3 .and.
     .     itras(1,1,1, 9,1,istn,icode).eq.23 +3 .and.
     .     itras(1,1,1,10,1,istn,icode).eq. 9 +3 .and.
     .     itras(1,1,1,11,1,istn,icode).eq.25 +3 .and.
     .     itras(1,1,1,12,1,istn,icode).eq.11 +3 .and.
     .     itras(1,1,1,13,1,istn,icode).eq.27 +3 .and.
     .     itras(1,1,1,14,1,istn,icode).eq.13 +3 .and.
     .     itras(1,1,1, 1,2,istn,icode).eq.16 +3 .and.
     .     itras(1,1,1, 2,2,istn,icode).eq. 2 +3 .and.
     .     itras(1,1,1, 3,2,istn,icode).eq.18 +3 .and.
     .     itras(1,1,1, 4,2,istn,icode).eq. 4 +3 .and.
     .     itras(1,1,1, 5,2,istn,icode).eq.20 +3 .and.
     .     itras(1,1,1, 6,2,istn,icode).eq. 6 +3 .and.
     .     itras(1,1,1, 7,2,istn,icode).eq.22 +3 .and.
     .     itras(1,1,1, 8,2,istn,icode).eq. 8 +3 .and.
     .     itras(1,1,1, 9,2,istn,icode).eq.24 +3 .and.
     .     itras(1,1,1,10,2,istn,icode).eq.10 +3 .and.
     .     itras(1,1,1,11,2,istn,icode).eq.26 +3 .and.
     .     itras(1,1,1,12,2,istn,icode).eq.12 +3 .and.
     .     itras(1,1,1,13,2,istn,icode).eq.28 +3 .and.
     .     itras(1,1,1,14,2,istn,icode).eq.14 +3 .and.
     .     nchan(istn,icode).eq.14 .and.
     .     npassf(istn,icode).eq.2 ) then ! mode C
        cmode(istn,icode)="C"
      endif ! mode C

      if ( itras(1,1,1, 1,1,istn,icode).eq. 1 +3 .and.
     .     itras(1,1,1, 2,1,istn,icode).eq. 2 +3 .and.
     .     itras(1,1,1, 3,1,istn,icode).eq. 3 +3 .and.
     .     itras(1,1,1, 4,1,istn,icode).eq. 4 +3 .and.
     .     itras(1,1,1, 5,1,istn,icode).eq. 5 +3 .and.
     .     itras(1,1,1, 6,1,istn,icode).eq. 6 +3 .and.
     .     itras(1,1,1, 7,1,istn,icode).eq. 7 +3 .and.
     .     itras(1,1,1, 8,1,istn,icode).eq. 8 +3 .and.
     .     itras(1,1,1, 9,1,istn,icode).eq. 9 +3 .and.
     .     itras(1,1,1,10,1,istn,icode).eq.10 +3 .and.
     .     itras(1,1,1,11,1,istn,icode).eq.11 +3 .and.
     .     itras(1,1,1,12,1,istn,icode).eq.12 +3 .and.
     .     itras(1,1,1,13,1,istn,icode).eq.13 +3 .and.
     .     itras(1,1,1,14,1,istn,icode).eq.14 +3 .and.
     .     itras(2,1,1, 1,1,istn,icode).eq.15 +3 .and.
     .     itras(2,1,1, 2,1,istn,icode).eq.16 +3 .and.
     .     itras(2,1,1, 3,1,istn,icode).eq.17 +3 .and.
     .     itras(2,1,1, 4,1,istn,icode).eq.18 +3 .and.
     .     itras(2,1,1, 5,1,istn,icode).eq.19 +3 .and.
     .     itras(2,1,1, 6,1,istn,icode).eq.20 +3 .and.
     .     itras(2,1,1, 7,1,istn,icode).eq.21 +3 .and.
     .     itras(2,1,1, 8,1,istn,icode).eq.22 +3 .and.
     .     itras(2,1,1, 9,1,istn,icode).eq.23 +3 .and.
     .     itras(2,1,1,10,1,istn,icode).eq.24 +3 .and.
     .     itras(2,1,1,11,1,istn,icode).eq.25 +3 .and.
     .     itras(2,1,1,12,1,istn,icode).eq.26 +3 .and.
     .     itras(2,1,1,13,1,istn,icode).eq.27 +3 .and.
     .     itras(2,1,1,14,1,istn,icode).eq.28 +3 .and.
     .     nchan(istn,icode).eq.28 .and.
     .     npassf(istn,icode).eq.1 ) then ! mode A
        cmode(istn,icode)="A"
      endif ! mode A

      if ( itras(1,1,1, 1,1,istn,icode).eq. 1 +3 .and.
     .     itras(1,1,1, 2,1,istn,icode).eq. 3 +3 .and.
     .     itras(1,1,1, 3,1,istn,icode).eq. 5 +3 .and.
     .     itras(1,1,1, 4,1,istn,icode).eq. 7 +3 .and.
     .     itras(1,1,1, 5,1,istn,icode).eq. 9 +3 .and.
     .     itras(1,1,1, 6,1,istn,icode).eq.11 +3 .and.
     .     itras(1,1,1, 7,1,istn,icode).eq.13 +3 .and.
     .     itras(2,1,1, 8,1,istn,icode).eq.15 +3 .and.
     .     itras(2,1,1, 9,1,istn,icode).eq.17 +3 .and.
     .     itras(2,1,1,10,1,istn,icode).eq.19 +3 .and.
     .     itras(2,1,1,11,1,istn,icode).eq.21 +3 .and.
     .     itras(2,1,1,12,1,istn,icode).eq.23 +3 .and.
     .     itras(2,1,1,13,1,istn,icode).eq.25 +3 .and.
     .     itras(2,1,1,14,1,istn,icode).eq.27 +3 .and.
     .     itras(1,1,1, 1,2,istn,icode).eq. 2 +3 .and.
     .     itras(1,1,1, 2,2,istn,icode).eq. 4 +3 .and.
     .     itras(1,1,1, 3,2,istn,icode).eq. 6 +3 .and.
     .     itras(1,1,1, 4,2,istn,icode).eq. 8 +3 .and.
     .     itras(1,1,1, 5,2,istn,icode).eq.10 +3 .and.
     .     itras(1,1,1, 6,2,istn,icode).eq.12 +3 .and.
     .     itras(1,1,1, 7,2,istn,icode).eq.14 +3 .and.
     .     itras(2,1,1, 8,2,istn,icode).eq.16 +3 .and.
     .     itras(2,1,1, 9,2,istn,icode).eq.18 +3 .and.
     .     itras(2,1,1,10,2,istn,icode).eq.20 +3 .and.
     .     itras(2,1,1,11,2,istn,icode).eq.22 +3 .and.
     .     itras(2,1,1,12,2,istn,icode).eq.24 +3 .and.
     .     itras(2,1,1,13,2,istn,icode).eq.26 +3 .and.
     .     itras(2,1,1,14,2,istn,icode).eq.28 +3 .and.
     .     nchan(istn,icode).eq.14 .and.
     .     npassf(istn,icode).eq.2 ) then ! mode B
        cmode(istn,icode)="B"
      endif ! mode B
      if ( itras(1,1,1, 1,1,istn,icode).eq. 1 +3 .and.
     .     itras(1,1,1, 2,1,istn,icode).eq. 3 +3 .and.
     .     itras(1,1,1, 3,1,istn,icode).eq. 5 +3 .and.
     .     itras(1,1,1, 4,1,istn,icode).eq. 7 +3 .and.
     .     itras(1,1,1, 5,1,istn,icode).eq. 9 +3 .and.
     .     itras(1,1,1, 6,1,istn,icode).eq.11 +3 .and.
     .     itras(1,1,1, 7,1,istn,icode).eq.13 +3 .and.
     .     itras(1,1,1, 1,2,istn,icode).eq.15 +3 .and.
     .     itras(1,1,1, 2,2,istn,icode).eq.17 +3 .and.
     .     itras(1,1,1, 3,2,istn,icode).eq.19 +3 .and.
     .     itras(1,1,1, 4,2,istn,icode).eq.21 +3 .and.
     .     itras(1,1,1, 5,2,istn,icode).eq.23 +3 .and.
     .     itras(1,1,1, 6,2,istn,icode).eq.25 +3 .and.
     .     itras(1,1,1, 7,2,istn,icode).eq.27 +3 .and.
     .     itras(1,1,1, 1,3,istn,icode).eq. 2 +3 .and.
     .     itras(1,1,1, 2,3,istn,icode).eq. 4 +3 .and.
     .     itras(1,1,1, 3,3,istn,icode).eq. 6 +3 .and.
     .     itras(1,1,1, 4,3,istn,icode).eq. 8 +3 .and.
     .     itras(1,1,1, 5,3,istn,icode).eq.10 +3 .and.
     .     itras(1,1,1, 6,3,istn,icode).eq.12 +3 .and.
     .     itras(1,1,1, 7,3,istn,icode).eq.14 +3 .and.
     .     itras(1,1,1, 1,4,istn,icode).eq.16 +3 .and.
     .     itras(1,1,1, 2,4,istn,icode).eq.18 +3 .and.
     .     itras(1,1,1, 3,4,istn,icode).eq.20 +3 .and.
     .     itras(1,1,1, 4,4,istn,icode).eq.22 +3 .and.
     .     itras(1,1,1, 5,4,istn,icode).eq.24 +3 .and.
     .     itras(1,1,1, 6,4,istn,icode).eq.26 +3 .and.
     .     itras(1,1,1, 7,4,istn,icode).eq.28 +3 .and.
     .     nchan(istn,icode).eq. 7 .and.
     .     npassf(istn,icode).eq.4 ) then ! mode E
        cmode(istn,icode)="E"
      endif ! mode E

      return
      end
