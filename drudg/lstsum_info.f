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
      subroutine lstsum_info(kskd)

C LSTSUM_INFO gets the information for the lstsum routine.
C Information is retrieved from common or by reading the
C .snp file directly.
C 
      include 'hardware.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'

      include 'lstsum.ftni'

C History
C 991103 nrv New. Removed from LSTSUM.
C 000611 nrv Add KSCAN to call.
C 020923 nrv Add kmk5 to set_type call.
C 021111 jfq Add klrack to set_type call.
C 032002 JMGipson. Let reading from snap file override sked file reading.

C Calls: READ_SNAP1, READ_SNAP6, SET_TYPE

C Input
      logical kskd
C Output
      integer ierr ! non-zero means some failure
C Local
      integer nline,ix
      character*128 cbuf_in
      character*20 c1,c2,c3
      integer trimlen

C 4.1 Whether we have a .skd file or not, read line 1 of SNAP file
C     Read first line of SNAP file to get year, experiment name, station.
C     If the first line in the SNAP file is a comment, then all the header 
C     lines are probably there.

      ierr=-1
      read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in
      nline=1
      call c2upper(cbuf_in,cbuf_in)
      if (cbuf_in(1:1).eq.'"') then
        call read_snap1(cbuf_in,cexpername,iyear,cstn,cid1,cid,ierr)
      else
        ierr = -1
      endif
      if (ierr.lt.0) then ! set defaults instead
        if (ierr.ge.-1) cexpername='XXX'
        if (ierr.ge.-2) iyear=0
        if (ierr.ge.-3) cstn='        '
        if (ierr.ge.-4) cid1=' '
        if (ierr.ge.-5) cid='  '
      endif
      ierr=0

C 4.2  Get axis type and station position
      if (kskd) then
        xpos = stnxyz(1,istn)
        ypos = stnxyz(2,istn)
        zpos = stnxyz(3,istn)
        kazel = .true.
        kwrap=.false.
        if (iaxis(istn).eq.3.or.iaxis(istn).eq.6.or.iaxis(istn)
     .       .eq.7) kwrap=.true.
C    Read line 2 to get axis type
      else ! read axis type and position from .snp
        read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in !A line
        nline=2
        call c2upper(cbuf_in,cbuf_in)
        read(cbuf_in(2:),*) c1,c2,c3
        if (c3.eq.'AZEL'.or.c3.eq.'SEST'.or.c3.eq.'ALGO') then
          kwrap=.true.
        else
          kwrap=.false.
        endif
C    Read line 3 to get XYZ position
        read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in !P line
        nline=3
        call c2upper(cbuf_in,cbuf_in)
        if (trimlen(cbuf_in).lt.40) then ! not there
          write(luscn,9002)
9002      format(' SNAP file does not contain station position ',
     .    'data on line 3, therefore '/,
     .    ' az, el will not be calculated for this listing.')
          kazel = .false.
        else ! it's there
          ix=index(cbuf_in(6:),' ')
          read(cbuf_in(6+ix:),*,err=991,end=990,iostat=IERR) 
     .    xpos,ypos,zpos
          kazel = .true.
        endif
      endif ! common/read axis type and position

C 4.3  Find out the equipment.
      if (kskd.and.cstrack(istn).ne.'unknown'. and.
     >             cstrec(istn,1).ne. 'unknown') then ! got it
        crack=cstrack(istn)
        creca=cstrec(istn,1)
        crecb=cstrec(istn,2)

        call init_hardware_common(istn)
C NOTE: This logic means that you can't mix (K4,S2) with (VLBA,Mk4)
C       because the "kk4" or "ks2" flag gets set.
        kk4 = kk41rec(1).or.kk42rec(1).or.kk41rec(2).or.kk42rec(2)
        ks2 = ks2rec(1).or.ks2rec(2)
!       km5A = km5Arec(1) .or. km5Arec(2)   !These are done in
!       km5P = km5prec(1) .or. km5prec(2)   !   init_hardware_common
      endif
! Got defaults from Sked file. Now readwhat snap file says, and overwrite defaults.
!      else ! read .snp file
        do while (nline.lt.3)
          nline=nline+1
          read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in
        enddo
C       Read line 4 (T line)
        read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in !T line
C       Read line 5 (drudg version comment)
        read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in 
C       Read line 6 (equipment)
        read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in
        call read_snap6(cbuf_in,crack,creca,crecb,ierr)
        if (ierr.eq.0) then !
C NOTE: This logic means that you can't mix (K4,S2) with (VLBA,Mk4)
          kk4 =  creca(1:2).eq.'K4'.or.crecb(1:2).eq.'K4'
          ks2 =  creca(1:2).eq.'S2'.or.crecb(1:2).eq.'S2'
          km5A = creca(1:6).eq.'Mark5A' .or. crecb(1:6).eq.'Mark5A' .or.
     >           creca(1:8).eq.'Mk5APigW' .or. crecb(1:8) .eq.'Mk5APigW'
          km5p = creca(1:6).eq.'Mark5P' .or. crecb(1:6) .eq. 'Mark5P'       !note the capital P
        else
C    Couldn't figure out the equipment from the .snp file header,
C    so look at the actual commands.
          nline=0
          ks2=.false.
          kk4=.false.
          km5A=.false.
          do while (nline.lt.50.and..not.(kk4.or. ks2 .or. km5A))
            read(lu_infile,'(a)',err=991,end=990,iostat=IERR) cbuf_in
            nline=nline+1
            call c2upper(cbuf_in,cbuf_in)
            km5A = cbuf_in(1:4) .eq. "DISK"
            kk4 = index(cbuf_in,'STA=RECORD').ne.0.or.
     .            index(cbuf_in,'STB=RECORD').ne.0
            ks2 = index(cbuf_in,'FOR,SLP').ne.0.or.
     .            index(cbuf_in,'FOR,LP').ne.0 
!            kscan = index(cbuf_in,'SCAN_NAME').ne.0
          enddo
        endif ! decode header line 6/read .snp
 !     endif ! common/read .snp

990   continue
991   continue
      return
      end
